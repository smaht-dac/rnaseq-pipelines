#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/pigeon:VERSION

baseCommand: [pigeon_filter.sh]

inputs:
  - id: input_classification_txt
    type: File
    inputBinding:
      position: 1
    doc: Classification file from pigeon classify

  - id: input_junctions_txt
    type: File
    inputBinding:
      position: 2
    doc: Junctions file from pigeon classify

  - id: input_file_gff
    type: File
    inputBinding:
      position: 3
    secondaryFiles:
      - .pgi
    doc: Output file from pigeon prepare in GFF format with the corresponding index files

  - id: output_prefix
    type: string
    default: "out"
    inputBinding:
      position: 4
    doc: Prefix for output files

outputs:
  - id: output_reasons_txt
    type: File
    outputBinding:
      glob: '*.filtered_lite_reasons.txt'

  - id: output_classification_txt
    type: File
    outputBinding:
      glob: '*.filtered_lite_classification.txt'

  - id: output_junctions_txt
    type: File
    outputBinding:
      glob: '*.filtered_lite_junctions.txt'

  - id: output_file_gff
    type: File
    outputBinding:
      glob: '*.filtered_lite.gff'

  - id: output_summary_txt
    type: File
    outputBinding:
      glob: '*.filtered.summary.txt'

  - id: output_report_json
    type: File
    outputBinding:
      glob: '*.filtered.report.json'

doc: |
  Run pigeon filter
