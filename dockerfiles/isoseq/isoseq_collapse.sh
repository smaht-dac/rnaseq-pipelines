#!/usr/bin/env bash

# *******************************************
# Run isoseq collapse to collapse redundant transcripts 
# from clustered PacBio Iso-Seq data into unique isoforms 
# based on their exonic structures.
# *******************************************

# Usage function
usage() {
    echo "Usage: $0 <input_bam> <output_prefix>"
    echo
    echo "Arguments:"
    echo "  input_bam      Iso-Seq reads after clustering and alignment with pbmm2"
    echo "  output_prefix  Prefix for the output files"
    exit 1
}

# Check if the correct number of arguments is provided
if [[ $# -ne 2 ]]; then
    echo "Error: Incorrect number of arguments provided."
    usage
fi

# Input arguments
input_bam=$1
output_prefix=$2

# Run isoseq collapse
echo "Running isoseq collapse..."
isoseq collapse --do-not-collapse-extra-5exons $input_bam ${output_prefix}.gff || {
    echo "Error: isoseq collapse failed!"
    exit 1
}

# Rename the FASTA output file to .fa
mv ${output_prefix}.fasta ${output_prefix}.fa || {
    echo "Error: Failed to rename the FASTA output file!"
    exit 1
}

# Final output:
# <output_prefix>.group.txt
# <output_prefix>.gff
# <output_prefix>.flnc_count.txt
# <output_prefix>.fa
# <output_prefix>.abundance.txt

# Output for QC:
# <output_prefix>.report.json
# <output_prefix>.read_stat.txt
