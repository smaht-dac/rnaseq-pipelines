#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: ACCOUNT/gtex_v10:VERSION

baseCommand: [/src/run_RSEM.sh]

inputs:
  - id: input_transcriptome_bam
    type: File
    inputBinding:
      position: 1
    doc: Transcriptome alignment BAM file generated by STAR

  - id: genome_reference_rsem
    type: File
    inputBinding:
      position: 2
    doc: RSEM reference index files generated with rsem-prepare-reference. |
         Expect a compressed archive. |
         The file prefix inside the archive need to be rsem_reference

  - id: strandedness
    type: string
    default: "unstranded"
    inputBinding:
      position: 3
    doc: Strandedness for the library. |
         Accepted values are "rf" or "fr" or "unstranded"

outputs:
  - id: output_isoforms_tsv
    type: File
    outputBinding:
      glob: isoforms.tsv

  - id: output_genes_tsv
    type: File
    outputBinding:
      glob: genes.tsv

doc: |
  Run RSEM for isoform and gene quantification
