#!/usr/bin/env python3
# Author: Francois Aguet
# Modified by: Michele Berselli
import argparse
import subprocess
from datetime import datetime
import os


parser = argparse.ArgumentParser(description='Wrapper for RNA-SeQC 2')
parser.add_argument('genes_gtf', type=str, help='Gene annotation GTF')
parser.add_argument('bam_file', type=str, help='BAM file')
parser.add_argument('prefix', type=str, default='Reads', help='Prefix for output files; usually sample_id')
parser.add_argument('-o', '--output_dir', default=os.getcwd(), help='Output directory')
# mod: --stranded argument modified to allow for unstranded
parser.add_argument('--stranded', type=str.lower, choices=['rf', 'fr', 'unstranded'], help='Strandedness for the library')
parser.add_argument('--bed', default=None, help='BED file with intervals for estimating insert size distribution')
args = parser.parse_args()

print('['+datetime.now().strftime("%b %d %H:%M:%S")+'] Running RNA-SeQC', flush=True)

cmd = 'rnaseqc {} {} {}'.format(args.genes_gtf, args.bam_file, args.output_dir) \
    + ' -s '+args.prefix \
    + ' -vv ' \
    + '--coverage' # mod: we also want the detailed coverage
# mod: added logic for unstranded option
if args.stranded != 'unstranded':
    if args.stranded in ['rf', 'fr']:
        cmd += ' --stranded '+args.stranded
    else:
        raise ValueError('Invalid strandedness option: '+args.stranded)
if args.bed is not None:
    cmd += ' --bed '+args.bed
print('  * command: "{}"'.format(cmd), flush=True)

# run RNA-SeQC
subprocess.check_call(cmd, shell=True)

# gzip GCTs
# mod: we dont need to compress the files anymore
# subprocess.check_call('gzip {0}.exon_reads.gct {0}.gene_tpm.gct {0}.gene_reads.gct'.format(args.prefix), shell=True)

# mod: archive and compress output
subprocess.check_call('tar -czvf {0}.all.tar.gz {0}.*'.format(args.prefix), shell=True)
# mod: change extension for tpm file to tsv
subprocess.check_call('mv {0}.gene_tpm.gct {0}.gene_tpm.tsv'.format(args.prefix), shell=True)

print('['+datetime.now().strftime("%b %d %H:%M:%S")+'] Finished RNA-SeQC', flush=True)
