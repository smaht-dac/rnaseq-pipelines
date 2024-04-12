#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

  - class: EnvVarRequirement
    envDef:
      -
        envName: SENTIEON_LICENSE
        envValue: LICENSEID

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/star_sentieon:VERSION

baseCommand: [sentieon_STAR_sort.sh]

inputs:
  - id: input_file_r1_fastq_gz
    type: File
    inputBinding:
      position: 1
    doc: Read 1 input file name.|
         Expect a compressed FASTQ file

  - id: input_file_r2_fastq_gz
    type: File
    inputBinding:
      position: 2
    doc: Read 2 input file name. |
         Expect a compressed FASTQ file

  - id: genome_reference_star
    type: File
    inputBinding:
      position: 3
    doc: STAR reference index files. |
         Expect a compressed archive

  - id: sample_name
    type: string
    inputBinding:
      position: 4
    doc: Name of the sample

  - id: library_id
    type: string
    default: "LIBRARY"
    inputBinding:
      position: 5
    doc: Identifier for the sequencing library preparation

  - id: platform
    type: string
    default: "ILLUMINA"
    inputBinding:
      position: 6
    doc: Name of the sequencing platform

outputs:
  - id: output_file_bam
    type: File
    outputBinding:
      glob: sorted.bam
    secondaryFiles:
      - .bai

  - id: output_transcriptome_bam
    type: File
    outputBinding:
      glob: star_out/OUT.Aligned.toTranscriptome.out.bam

  - id: output_tar_gz
    type: File
    outputBinding:
      glob: output.tar.gz

doc: |
  Run STAR for alignment
