#!/usr/bin/env bash

# *******************************************
# Run pigeon classify
# to classify isoforms into categories.
# *******************************************

# Usage function
usage() {
    echo "Usage: $0 <collapsed_sorted_gff> <annotations_gtf> <reference_fasta>"
    echo
    echo "Arguments:"
    echo "  collapsed_sorted_gff   Path to the GFF file from pigeon prepare"
    echo "  annotations_gtf        Path to the GTF file from pigeon prepare"
    echo "  reference_fasta        Path to the genome reference FASTA file"
    exit 1
}

# Validate arguments
if [[ $# -ne 3 ]]; then
    echo "Error: Incorrect number of arguments."
    usage
fi

# Input arguments
collapsed_sorted_gff=$1
annotations_gtf=$2
reference_fasta=$3

# Run pigeon classify
echo "Running pigeon classify..."
pigeon classify $collapsed_sorted_gff $annotations_gtf $reference_fasta || {
    echo "Error: pigeon classify failed!"
    exit 1
}

# Final output:
# <gff_prefix>_junctions.txt
# <gff_prefix>_classification.txt

# Output for QC:
# <gff_prefix>.report.json
# <gff_prefix>.summary.txt
