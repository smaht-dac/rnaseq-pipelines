# Preprocessing Steps

*The preprocessing steps are based on GTEx Consortium pipeline, as described in https://github.com/broadinstitute/gtex-pipeline.*

### 1. ALT, HLA, and Decoy contigs were excluded from the reference genome FASTA using the following Python code:

```python
with open('Homo_sapiens_assembly38.fasta', 'r') as fasta:
    contigs = fasta.read()
contigs = contigs.split('>')
contig_ids = [i.split(' ', 1)[0] for i in contigs]

# exclude ALT, HLA and decoy contigs
filtered_fasta = '>'.join([c for i,c in zip(contig_ids, contigs)
    if not (i[-4:]=='_alt' or i[:3]=='HLA' or i[-6:]=='_decoy')])

with open('Homo_sapiens_assembly38_noALT_noHLA_noDecoy.fasta', 'w') as fasta:
    fasta.write(filtered_fasta)
```

### 2.
