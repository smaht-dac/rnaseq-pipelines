#!/usr/bin/env bash

# *******************************************
# Run RSEM to quantify transcripts.
# *******************************************

## Command line arguments
# Input BAM file
transcriptome_bam=$1

# Reference data files
rsem_reference=$2
# expect a tar.gz file
# storing the inididual files

# Other arguments
is_stranded=$3 # 'true', 'false'

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
        --is_stranded $is_stranded \
        --threads $nt || exit 1

## Rename output
mv OUT.rsem.isoforms.results isoforms.tsv
mv OUT.rsem.genes.results genes.tsv
