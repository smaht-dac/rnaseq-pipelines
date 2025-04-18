#!/usr/bin/env python3

################################################
#
#   Import IsoSeq and Pigeon annotations to the
#   FLNC BAM file as tags.
#
#   The following tags are added:
#       isoform (in:Z:)
#       structural_category (sc:Z:)
#       associated_gene (gn:Z:)
#       associated_transcript (tn:Z:)
#       subcategory (sb:Z:)
#       count (ct:i:)
#       group (gr:Z:) (optional)
#
#   Michele Berselli
#   berselli.michele@gmail.com
#
################################################


################################################
#   Libraries
################################################
import sys, argparse
import pysam
from typing import Dict, Tuple


################################################
#   Arguments
################################################
def parse_arguments():
    """Parse the command line arguments.
    """
    parser = argparse.ArgumentParser(description="Import IsoSeq and Pigeon annotations to the FLNC BAM file as tags.")

    parser.add_argument("--input_flnc", required=True, help="Input FLNC BAM file")
    parser.add_argument("--output_flnc", required=True, help="Output modified FLNC BAM file")
    parser.add_argument("--read_stat", required=True, help="IsoSeq collapse 'read_stat' output file")
    parser.add_argument("--classification", required=True, help="Pigeon classify (or filter) 'classification' output file")
    parser.add_argument("--add_group", action="store_true", help="Add (gr:Z:) tag listing other reads in the same isoform group (comma-separated)")
    parser.add_argument("--threads", type=int, default=1, help="Number of threads to use for compression/decompression (default: 1)")
    parser.add_argument("--verbose", action="store_true", help="Print verbose warnings")
    parser.add_argument("--index", action="store_true", help="Index the output FLNC BAM file. Requires sorted reads")

    return parser.parse_args()


################################################
#   Functions
################################################
def map_read_to_isoform(inputfile: str) -> Tuple[Dict[str, str], Dict[str, set]]:
    """Map the read identifiers to the isoform identifiers.

    Args:
        inputfile (str): IsoSeq collapse read_stat output file.
    """
    read_mapping, isoform_groups = {}, {}

    with open(inputfile, "r") as fi:
        fi.readline() # Skip the header
        for line in fi:
            read_id, _, isoform_id = line.strip().split("\t")
            read_mapping[read_id] = isoform_id
            isoform_groups.setdefault(isoform_id, set()).add(read_id)

    return read_mapping, isoform_groups

def load_isoform_annotations(inputfile: str) -> Dict[str, Tuple[str, str, str, str]]:
    """Load the isoform annotations.

    Args:
        inputfile (str): Pigeon classify classification output file.
    """
    isoform_annotations = {}

    with open(inputfile, "r") as fi:
        fi.readline() # Skip the header
        for line in fi:
            line = line.strip().split("\t")
            isoform_id = line[0]
            structural_category = line[5]
            associated_gene = line[6]
            # if associated_gene.startswith("novelGene_"):
            #     associated_gene = "novelGene"
            associated_transcript = line[7]
            subcategory = line[14]
            isoform_annotations[isoform_id] = (structural_category, associated_gene, associated_transcript, subcategory)

    return isoform_annotations

def main():
    args = parse_arguments()

    # Open the input and output files
    samfile = pysam.AlignmentFile(args.input_flnc, "rb", check_sq=False, threads=args.threads)
    bamfile = pysam.AlignmentFile(args.output_flnc, "wb", template=samfile, threads=args.threads)

    # Load the lookup tables and annotations
    read_mapping, isoform_groups = map_read_to_isoform(args.read_stat)
    isoform_annotations = load_isoform_annotations(args.classification)

    # Iterate over the reads
    for read in samfile.fetch(until_eof=True):
        read_id = read.query_name

        # Get the isoform identifier
        isoform_id = read_mapping.get(read_id)
        if isoform_id is None: # The read is not in the lookup tables
            if args.verbose:
                sys.stderr.write(f"WARNING: Read not found in the lookup tables. Skipping read {read_id}.\n")
            # The read is not annotated. Write the read as is and continue
            bamfile.write(read)
            continue

        # Get the isoform annotations
        isoform_annotation = isoform_annotations.get(isoform_id)
        if isoform_annotation is None: # The isoform is not in the annotations file
            if args.verbose:
                sys.stderr.write(f"WARNING: Isoform {isoform_id} not found in the annotations file. Skipping read {read_id}.\n")
            # The read is not annotated. Write the read as is and continue
            bamfile.write(read)
            continue

        # Unpack the annotations
        structural_category, associated_gene, associated_transcript, subcategory = isoform_annotation

        # Add the annotation-based tags
        read.set_tag("in", isoform_id, "Z")
        read.set_tag("sc", structural_category, "Z")
        read.set_tag("gn", associated_gene, "Z")
        read.set_tag("tn", associated_transcript, "Z")
        read.set_tag("sb", subcategory, "Z")

        # Add the count tag
        read_count = len(isoform_groups[isoform_id])
        read.set_tag("ct", read_count, "i")

        # Add the group tag
        if args.add_group:
            isoform_group = isoform_groups[isoform_id] - {read_id}
            if isoform_group:
                read.set_tag("gr", ",".join(isoform_group), "Z")

        # Write the modified read
        bamfile.write(read)

    # Close the input and output files
    bamfile.close()
    samfile.close()

    # Index the output file if requested
    if args.index:
        pysam.index(args.output_flnc, threads=args.threads)


################################################
#   Main
################################################
if __name__ == "__main__":

    main()
