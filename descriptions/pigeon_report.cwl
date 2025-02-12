#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/pigeon:VERSION

baseCommand: [pigeon_report.sh]

inputs:
  - id: input_classification_txt
    type: File
    inputBinding:
      position: 1
    doc: Classification TXT file from pigeon filter

  - id: output_prefix
    type: string
    default: "out"
    inputBinding:
      position: 2
    doc: Prefix for output files

outputs:
  - id: output_saturation_txt
    type: File
    outputBinding:
      glob: '*_saturation.txt'

doc: |
  Run pigeon report
