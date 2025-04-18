#!/usr/bin/env bash

# *******************************************
# Run isoseq cluster2 to collapse isoforms
# from PacBio Iso-Seq data.
# *******************************************

# Usage function
usage() {
    echo "Usage: $0 [--singletons] <output_prefix> <input_bam1> [<input_bam2> ...]"
    echo
    echo "Arguments:"
    echo "  --singletons      (Optional) Include singleton isoforms in clustering"
    echo "  output_prefix     Prefix for output files"
    echo "  input_bam1        Path to the first FLNC (Full-length non-chimeric) BAM file"
    echo "  input_bam2 ...    Paths to additional FLNC BAM files (optional)"
    exit 1
}

# Parse optional flag --singletons
singletons_flag=""
if [[ $1 == "--singletons" ]]; then
    singletons_flag="--singletons"
    shift 1
fi

# Validate arguments
if [[ $# -lt 2 ]]; then
    echo "Error: Prefix for output files and at least one BAM file must be provided."
    usage
fi

# Input arguments
output_prefix=$1  # First argument is the output prefix
shift 1           # Shift arguments so $@ contains only the BAM files to use

# Reset the FOFN file (truncate if it exists, or create a new one)
: > flnc.fofn

# Append each argument to the FOFN file
for file in $@; do
    if [ -f $file ] && [[ $file == *.bam ]]; then
        echo $file >> flnc.fofn
    else
        echo "Error: File '$file' does not exist or is not a BAM file. Exiting."
        exit 1
    fi
done

# Run isoseq cluster2
echo "Running isoseq cluster2..."
isoseq cluster2 $singletons_flag flnc.fofn ${output_prefix}.bam || {
    echo "Error: isoseq cluster2 failed!"
    exit 1
}

# Output files:
# <output_prefix>.bam
# <output_prefix>.bam.pbi
# <output_prefix>.cluster_report.csv
