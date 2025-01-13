#!/usr/bin/env bash

# *******************************************
# Run pigeon report to report gene saturation 
# from filtered classification.
# *******************************************

# Usage function
usage() {
    echo "Usage: $0 <classification_txt> <output_prefix>"
    echo
    echo "Arguments:"
    echo "  classification_txt   Path to the filtered classification file from pigeon filter"
    echo "  output_prefix        Prefix for output files"
    exit 1
}

# Validate arguments
if [[ $# -ne 2 ]]; then
    echo "Error: Incorrect number of arguments."
    usage
fi

# Input arguments
classification_txt=$1
output_prefix=$2

# Run pigeon report
echo "Running pigeon report..."
pigeon report --exclude-singletons $classification_txt ${output_prefix}_saturation.txt || {
    echo "Error: pigeon report failed!"
    exit 1
}

# Output for QC:
# <output_prefix>_saturation.txt
