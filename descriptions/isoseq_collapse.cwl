#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/isoseq:VERSION

baseCommand: [isoseq_collapse.sh]

inputs:
  - id: input_file_bam
    type: File
    secondaryFiles:
      - .bai
    inputBinding:
      position: 1
    doc: Input file in BAM format and corresponding index file. |
         Genome aligned reads from pbmm2

  - id: output_prefix
    type: string
    default: "out"
    inputBinding:
      position: 2
    doc: Prefix for output files

outputs:
  - id: output_file_gff
    type: File
    outputBinding:
      glob: $(inputs.output_prefix + ".gff")

  - id: output_file_fasta
    type: File
    outputBinding:
      glob: $(inputs.output_prefix + ".fa")

  - id: output_group_txt
    type: File
    outputBinding:
      glob: $(inputs.output_prefix + ".group.txt")

  - id: output_report_json
    type: File
    outputBinding:
      glob: $(inputs.output_prefix + ".report.json")

  - id: output_stat_txt
    type: File
    outputBinding:
      glob: $(inputs.output_prefix + ".read_stat.txt")

doc: |
  Run isoseq collapse
