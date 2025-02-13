#!/usr/bin/env bash

# *******************************************
# Run pigeon filter to filter isoforms from classification output.
# Use --isoforms flag to also generate a filtered GFF file.
# *******************************************

# Usage function
usage() {
    echo "Usage: $0 <classification_txt> <junctions_txt> <collapsed_sorted_gff> <output_prefix>"
    echo
    echo "Arguments:"
    echo "  classification_txt   Path to the classification TXT file from pigeon classify"
    echo "  junctions_txt        Path to the junctions TXT file from pigeon classify"
    echo "  collapsed_sorted_gff Path to the GFF file from pigeon prepare"
    echo "  output_prefix        Prefix for the output files"
    exit 1
}

# Validate arguments
if [[ $# -ne 4 ]]; then
    echo "Error: Incorrect number of arguments."
    usage
fi

# Input arguments
classification_txt=$1
junctions_txt=$2
collapsed_sorted_gff=$3
output_prefix=$4

# Link input files from pigeon
ln -s $classification_txt ${output_prefix}_classification.txt
ln -s $junctions_txt ${output_prefix}_junctions.txt
ln -s $collapsed_sorted_gff ${output_prefix}.gff

# Run pigeon filter
echo "Running pigeon filter..."
pigeon filter ${output_prefix}_classification.txt --isoforms ${output_prefix}.gff || {
    echo "Error: pigeon filter failed!"
    exit 1
}

# Final output:
# <output_prefix>_classification.filtered_lite_reasons.txt
# <output_prefix>_classification.filtered_lite_classification.txt
# <output_prefix>_classification.filtered_lite_junctions.txt
# <output_prefix>.filtered_lite.gff

# Output for QC:
# <output_prefix>_classification.filtered.summary.txt
# <output_prefix>_classification.filtered.report.json
