#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/isoseq:VERSION

baseCommand: [isoseq_cluster2.sh]

inputs:
  - id: input_files_bam
    type:
      -
        items: File
        type: array
    inputBinding:
      position: 2
    doc: List of FLNC input files in BAM format

  - id: output_prefix
    type: string
    default: "out"
    inputBinding:
      position: 1
    doc: Prefix for output files

outputs:
  - id: output_file_bam
    type: File
    outputBinding:
      glob: $(inputs.output_prefix + ".bam")
    secondaryFiles: 
      - .pbi

  - id: output_cluster_csv
    type: File
    outputBinding:
      glob: $(inputs.output_prefix + ".cluster_report.csv")

doc: |
  Run isoseq cluster2
