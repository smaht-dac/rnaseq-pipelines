# Preprocessing Steps

*The preprocessing steps are based on GTEx Consortium pipeline, as described in https://github.com/broadinstitute/gtex-pipeline.*

### 1. Genome Reference

##### Downloading the reference genome

```bash
wget https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta
```

##### ALT, HLA, and decoy contigs were excluded from the reference genome FASTA using the following Python code

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

##### Generating FASTA indexes

```bash
samtools faidx Homo_sapiens_assembly38_noALT_noHLA_noDecoy.fasta

java -jar picard.jar \
    CreateSequenceDictionary \
    R=Homo_sapiens_assembly38_noALT_noHLA_noDecoy.fasta \
    O=Homo_sapiens_assembly38_noALT_noHLA_noDecoy.dict
```

### 2. Gencode Annotation

##### Downloading comprehensive gene annotation

```bash
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_45/gencode.v45.annotation.gtf.gz
```

##### Collapsing gene annotation

```bash
python3 collapse_annotation.py \
    --collapse_only gencode.v45.annotation.gtf \
    gencode.v45.genes.gtf
```

### 3. STAR Index

##### Generating STAR index for 101bp

```bash
STAR \
  --runMode genomeGenerate \
  --genomeDir STARv2710b_assembly38_noALT_noHLA_noDecoy_v45_oh100 \
  --genomeFastaFiles Homo_sapiens_assembly38_noALT_noHLA_noDecoy.fasta \
  --sjdbGTFfile gencode.v45.annotation.gtf \
  --sjdbOverhang 100
```

### 4. RSEM Index

##### Generating RSEM index

```bash
rsem-prepare-reference \
    --gtf gencode.v45.annotation.gtf \
    Homo_sapiens_assembly38_noALT_noHLA_noDecoy.fasta \
    rsem_reference
```
