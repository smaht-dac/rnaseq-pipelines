#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/pigeon:VERSION

baseCommand: [pigeon_prepare.sh]

inputs:
  - id: gencode_annotation_gtf
    type: File
    inputBinding:
      position: 1
    doc: GENCODE annotation file in GTF format

  - id: genome_reference_fasta
    type: File
    inputBinding:
      position: 2
    secondaryFiles:
      - ^.dict
      - .fai
    doc: Genome reference in FASTA format with the corresponding index files

  - id: input_file_gff
    type: File
    inputBinding:
      position: 3
    doc: Output file from isoseq collapse in GFF format

  - id: output_prefix
    type: string
    default: "out"
    inputBinding:
      position: 4
    doc: Prefix for output files

outputs:
  - id: output_file_gtf
    type: File
    outputBinding:
      glob: '*.sorted.gtf'
    secondaryFiles:
      - .pgi
    doc: Sorted GENCODE annotation file in GTF format

  - id: output_file_gff
    type: File
    outputBinding:
      glob: '*.sorted.gff'
    secondaryFiles:
      - .pgi
    doc: Sorted isoseq collapse file in GFF format

doc: |
  Run pigeon prepare
