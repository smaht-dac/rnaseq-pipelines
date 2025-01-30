#!/usr/bin/env bash

# *******************************************
# Run pigeon classify
# to classify isoforms into categories.
# *******************************************

# Usage function
usage() {
    echo "Usage: $0 -g <collapsed_sorted_gff> -a <annotations_gtf> -r <reference_fasta> [--cage-peak <refTSS_bed>] [--poly-a <polyA_txt>]"
    echo
    echo "Arguments:"
    echo "  -g, --gff         Path to the GFF file from pigeon prepare"
    echo "  -a, --gtf         Path to the GTF file from pigeon prepare"
    echo "  -r, --ref         Path to the genome reference FASTA file"
    echo "  --cage-peak       (Optional) Path to the CAGE peaks in BED format from pigeon prepare"
    echo "  --poly-a          (Optional) Path to the polyA motif list in custom TXT format"
    exit 1
}

# Default values
cage_peak=""
poly_a=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -g|--gff)
            collapsed_sorted_gff="$2"
            shift 2
            ;;
        -a|--gtf)
            annotations_gtf="$2"
            shift 2
            ;;
        -r|--ref)
            reference_fasta="$2"
            shift 2
            ;;
        --cage-peak)
            cage_peak="$2"
            shift 2
            ;;
        --poly-a)
            poly_a="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Error: Unknown argument: $1"
            usage
            ;;
    esac
done

# Validate required arguments
if [[ -z "$collapsed_sorted_gff" || -z "$annotations_gtf" || -z "$reference_fasta" ]]; then
    echo "Error: Missing required arguments."
    usage
fi

# Generate command
cmd="pigeon classify $collapsed_sorted_gff $annotations_gtf $reference_fasta"

# Add optional arguments
[[ -n "$cage_peak" ]] && cmd+=" --cage-peak $cage_peak"
[[ -n "$poly_a" ]] && cmd+=" --poly-a $poly_a"

# Execute command
echo "Running pigeon classify..."
eval $cmd || {
    echo "Error: pigeon classify failed!"
    exit 1
}

# Final output:
# <gff_prefix>_junctions.txt
# <gff_prefix>_classification.txt

# Output for QC:
# <gff_prefix>.report.json
# <gff_prefix>.summary.txt
