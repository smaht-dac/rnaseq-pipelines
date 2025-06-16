#!/usr/bin/env bash

# *******************************************
# Run RSEM to quantify transcripts.
# *******************************************

## Command line arguments
# Input BAM file
transcriptome_bam=$1

# Reference index files
rsem_reference=$2
# expect a tar.gz archive
# storing the individual files

# Other arguments
strandedness=$3 # "rf" or "fr" or "unstranded"

## Other settings
nt=$(nproc) # number of threads to use in computation,
            # set to number of cores in the server

## Unpack the RSEM reference files to current directory
tar -xvzf $rsem_reference

## Run
/src/run_RSEM.py \
        . \
        $transcriptome_bam \
        OUT \
        --stranded $strandedness \
        --threads $nt || exit 1

## Rename output
mv OUT.rsem.isoforms.results isoforms.tsv
mv OUT.rsem.genes.results genes.tsv
