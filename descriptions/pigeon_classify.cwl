#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/pigeon:VERSION

baseCommand: [pigeon_classify.sh]

inputs:
  - id: input_file_gff
    type: File
    inputBinding:
      position: 1
    secondaryFiles:
      - .pgi
    doc: Output file from pigeon prepare in GFF format with the corresponding index files

  - id: input_file_gtf
    type: File
    inputBinding:
      position: 2
    secondaryFiles:
      - .pgi
    doc: Output file from pigeon prepare in GTF format with the corresponding index files

  - id: genome_reference_fasta
    type: File
    inputBinding:
      position: 3
    secondaryFiles:
      - ^.dict
      - .fai
    doc: Genome reference in FASTA format with the corresponding index files

outputs:
  - id: output_junctions_txt
    type: File
    outputBinding:
      glob: '*_junctions.txt'

  - id: output_classification_txt
    type: File
    outputBinding:
      glob: '*_classification.txt'

  - id: output_report_json
    type: File
    outputBinding:
      glob: '*.report.json'

  - id: output_summary_txt
    type: File
    outputBinding:
      glob: '*.summary.txt'

doc: |
  Run pigeon classify
