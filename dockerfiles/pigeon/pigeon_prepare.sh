#!/usr/bin/env bash

# *******************************************
# Run pigeon prepare to generate the reference and 
# sort the transcript input data for pigeon.
# *******************************************

# Usage function
usage() {
    echo "Usage: $0 <gencode_annotation_gtf> <reference_fasta> <collapsed_gff> <output_prefix>"
    echo
    echo "Arguments:"
    echo "  gencode_annotation_gtf   Path to the GENCODE annotation GTF file"
    echo "  reference_fasta          Path to the genome reference FASTA file"
    echo "  collapsed_gff            Path to the GFF file from isoseq collapse"
    echo "  output_prefix            Prefix for the output files"
    exit 1
}

# Validate arguments
if [[ $# -ne 4 ]]; then
    echo "Error: Incorrect number of arguments."
    usage
fi

# Input arguments
gencode_annotation_gtf=$1
reference_fasta=$2
collapsed_gff=$3
output_prefix=$4

# Link the GTF and GFF files to the current directory
ln -s $gencode_annotation_gtf ${output_prefix}.gtf
ln -s $collapsed_gff ${output_prefix}.gff

# Run pigeon prepare
echo "Running pigeon prepare for GTF and FASTA..."
pigeon prepare ${output_prefix}.gtf $reference_fasta || {
    echo "Error: pigeon prepare failed for GTF and FASTA!"
    exit 1
}

echo "Running pigeon prepare for collapsed GFF..."
pigeon prepare ${output_prefix}.gff || {
    echo "Error: pigeon prepare failed for collapsed GFF!"
    exit 1
}

# Output:
# <output_prefix>.sorted.gtf
# <output_prefix>.sorted.gtf.pgi
# <output_prefix>.sorted.gff
# <output_prefix>.sorted.gff.pgi
