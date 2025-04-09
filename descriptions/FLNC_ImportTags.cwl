#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/utils:VERSION

baseCommand: [FLNC_ImportTags.py]

inputs:
  - id: input_file_bam
    type: File
    secondaryFiles:
      - .bai
    inputBinding:
      prefix: --input_flnc
    doc: FLNC input file in BAM format. |
         The file must be sorted and indexed

  - id: output_file_bam
    type: File
    inputBinding:
      prefix: --output_flnc
    doc: Output FLNC file in BAM format. |
         The file will be sorted and indexed. |
         This is the annotated FLNC file

  - id: input_stat_txt
    type: File
    inputBinding:
      prefix: --read_stat
    doc: read_stat output file in TXT format from isoseq collapse

  - id: input_classification_txt
    type: File
    inputBinding:
      prefix: --classification
    doc: classification output file in TXT format from pigeon classify or filter

  - id: nthreads
    type: int
    default: null
    inputBinding:
      prefix: --threads
    doc: Number of threads to use for compression/decompression [1]

  - id: add_group
    type: boolean
    default: null
    inputBinding:
      prefix: --add_group
    doc: Flag to add (gr:Z:) tag listing other reads in the same isoform group (comma-separated) [False]

  - id: index
    type: boolean
    default: true
    inputBinding:
      prefix: --index
    doc: Flag to index the output BAM file [False]

outputs:
  - id: output_file_bam
    type: File
    outputBinding:
      glob: $(inputs.output_file_bam)
    secondaryFiles: 
      - .bai

doc: |
  Run FLNC_ImportTags.py to add tags to the FLNC BAM file.
