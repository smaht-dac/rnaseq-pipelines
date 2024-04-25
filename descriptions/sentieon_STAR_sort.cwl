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
  - id: input_files_r1_fastq_gz
    type:
      -
        items: File
        type: array
        inputBinding:
          prefix: -1
    inputBinding:
      position: 1
    doc: List of Read 1 input files. |
         Expect compressed FASTQ files

  - id: input_files_r2_fastq_gz
    type:
      -
        items: File
        type: array
        inputBinding:
          prefix: -2
    inputBinding:
      position: 2
    doc: List of Read 2 input files. |
         Expect compressed FASTQ files

  - id: genome_reference_star
    type: File
    inputBinding:
      position: 3
      prefix: -r
    doc: STAR reference index files. |
         Expect a compressed archive

  - id: sample_name
    type: string
    inputBinding:
      position: 4
      prefix: -s
    doc: Name of the sample

  - id: library_id
    type: string
    default: "LIBRARY"
    inputBinding:
      position: 5
      prefix: -l
    doc: Identifier for the sequencing library preparation

  - id: platform
    type: string
    default: "ILLUMINA"
    inputBinding:
      position: 6
      prefix: -p
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
      glob: OUT.Aligned.toTranscriptome.out.bam

  - id: output_tar_gz
    type: File
    outputBinding:
      glob: output.tar.gz

doc: |
  Run STAR for alignment
