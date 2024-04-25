#!/usr/bin/env bash

# *******************************************
# Run STAR to generate alignment BAM files
# from paired FASTQ files for a single sample.
# The main alignment BAM file will be sorted by coordinates.
# *******************************************

# *******************************************
# COMMAND LINE
# *******************************************
# Default values
nt=$(nproc) # number of threads to use in computation,
            # set to number of cores in the server

# Parser
while getopts ":r:1:2:s:l:p:" opt; do
  case $opt in
    r )
      star_reference=$OPTARG
      # expect a tar.gz archive storing the individual files
      ;;
    1 )
      fastq_r1+=("$OPTARG")
      ;;
    2 )
      fastq_r2+=("$OPTARG")
      ;;
    s )
      sample=$OPTARG
      ;;
    l )
      library=$OPTARG
      ;;
    p )
      platform=$OPTARG
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      exit 1
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

# Check for required arguments
if [ ${#fastq_r1[@]} -eq 0 ] || [ ${#fastq_r2[@]} -eq 0 ] || [ -z $star_reference ] || [ -z $sample ] || [ -z $library ] || [ -z $platform ]; then
  echo "Usage: $0 -1 <fastq_1.r1> [-1 <fastq_2.r1>] -2 <fastq_1.r2> [-2 <fastq_2.r2>] -r <star_index> -s <sample_id> -l <library_id> -p <platform>" 1>&2
  exit 1
fi

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
# Convert array to comma-separated string
fastq_r1=$(IFS=,; echo "${fastq_r1[*]}")
fastq_r2=$(IFS=,; echo "${fastq_r2[*]}")

# Echo arguments
echo "FASTQ R1: ${fastq_r1}"
echo "FASTQ R2: ${fastq_r2}"
echo "STAR INDEX: $star_reference"
echo "RG: 'ID:${sample}.$(generate_random_string) SM:${sample} PL:${platform} LB:${sample}.${library}'"

# Run STAR
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

# Organize and compress output to extract
mv star_out/OUT.Aligned.toTranscriptome.out.bam OUT.Aligned.toTranscriptome.out.bam
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
sys.stderr.write('\nsorted.bam:\n')
check_EOF('sorted.bam')

# Transcriptome alignment
sys.stderr.write('\ntoTranscriptome.bam:\n')
check_EOF('OUT.Aligned.toTranscriptome.out.bam')
"

python -c "$py_script" || exit 1
