#!/usr/bin/env bash

# *******************************************
# Run STAR to generate alignment BAM files
# from paired FASTQ files for a single sample.
# The main alignment BAM file will be sorted by coordinates.
# *******************************************

## Command line arguments
# Input FASTQ files
fastq_r1=$1
fastq_r2=$2

# Reference index files
star_reference=$3
# expect a tar.gz archive
# storing the individual files

# Read groups information
sample=$4
library=$5
platform=$6

## Other settings
nt=$(nproc) # number of threads to use in computation,
            # set to number of cores in the server

# *******************************************
# FUNCTIONS
# *******************************************
generate_random_string() {
    echo "$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 5 | head -n 1)"
}

# ******************************************
# 0. Upack reference index files
# to current directory.
# ******************************************
tar -xvzf $star_reference

# ******************************************
# 1. Mapping reads with STAR and
# sort main alignment by coordinates.
# ******************************************
sentieon STAR \
  --runThreadN $nt \
  --readFilesIn $fastq_r1 $fastq_r2 \
  --readFilesCommand zcat \
  --genomeDir . \
  --outSAMattrRGline ID:${sample}.$(generate_random_string) SM:${sample} PL:${platform} LB:${sample}.${library} \
  --twopassMode Basic \
  --twopass1readsN -1 \
  --outFilterMultimapNmax 20 \
  --alignSJoverhangMin 8 \
  --alignSJDBoverhangMin 1 \
  --outFilterMismatchNmax 999 \
  --outFilterMismatchNoverLmax 0.1 \
  --alignIntronMin 20 \
  --alignIntronMax 1000000 \
  --alignMatesGapMax 1000000 \
  --outFilterType BySJout \
  --outFilterScoreMinOverLread 0.33 \
  --outFilterMatchNmin 0 \
  --outFilterMatchNminOverLread 0.33 \
  --limitSjdbInsertNsj 1200000 \
  --outSAMstrandField intronMotif \
  --outFilterIntronMotifs None \
  --alignSoftClipAtReferenceEnds Yes \
  --quantMode TranscriptomeSAM GeneCounts \
  --outSAMtype BAM Unsorted \
  --outStd BAM_Unsorted \
  --outBAMcompression 0 \
  --outSAMunmapped Within \
  --genomeLoad NoSharedMemory \
  --chimSegmentMin 15 \
  --chimJunctionOverhangMin 15 \
  --chimOutType Junctions WithinBAM SoftClip \
  --chimMainSegmentMultNmax 1 \
  --chimOutJunctionFormat 0 \
  --outSAMattributes NH HI AS nM NM ch \
  --outFileNamePrefix star_out/OUT. \
  | samtools sort --no-PG -@ $nt -o sorted.bam - || exit 1

## This command will generate the following files:
#   .
#   ├── sorted.bam
#   └── star_out
#         ├── OUT.Aligned.toTranscriptome.out.bam
#         ├── OUT.Chimeric.out.junction
#         ├── OUT.ReadsPerGene.out.tab
#         ├── OUT.SJ.out.tab
#         ├── OUT._STARgenome/
#         └── OUT._STARpass1/

# Format output to extract
tar -czvf output.tar.gz star_out

# ******************************************
# 2. Index main alignment BAM.
# ******************************************
samtools index -@ $nt sorted.bam || exit 1

# ******************************************
# 3. Check BAM files integrity.
# ******************************************
py_script="
import sys, os

def check_EOF(filename):
    EOF_hex = b'\x1f\x8b\x08\x04\x00\x00\x00\x00\x00\xff\x06\x00\x42\x43\x02\x00\x1b\x00\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00'
    size = os.path.getsize(filename)
    fb = open(filename, 'rb')
    fb.seek(size - 28)
    EOF = fb.read(28)
    fb.close()
    if EOF != EOF_hex:
        sys.stderr.write('EOF is missing\n')
        sys.exit(1)
    else:
        sys.stderr.write('EOF is present\n')

# Main alignment
sys.stderr.write('sorted.bam:\n')
check_EOF('sorted.bam')

# Transcriptome alignment
sys.stderr.write('toTranscriptome.bam:\n')
check_EOF('star_out/OUT.Aligned.toTranscriptome.out.bam')
"

python -c "$py_script" || exit 1
