# Assemble genomes of model organisms by ANCHR

[TOC]: # " "
- [*E. coli*](#e-coli)
    - [*E. coli*: download](#e-coli-download)
    - [*E. coli*: trim/filter](#e-coli-trimfilter)

## *E. coli*

*Escherichia coli* str. K-12 substr. MG1655

* INSDC: [U00096.3](https://www.ncbi.nlm.nih.gov/nuccore/U00096.3)
* paralogs: 0.0323

* Real:

    * S: 4,641,652

* Original:

    * N50: 151
    * S: 865,149,970
    * C: 5,729,470

* Trimmed, 120-151 bp

    * N50: 151
    * S: 577,015,664
    * C: 3,871,229

* Filter, 151 bp

    * N50: 151
    * S: 371,039,918
    * C: 2,457,218

### *E. coli*: download

```bash
# genome
mkdir -p ~/data/anchr/e_coli/1_genome
cd ~/data/anchr/e_coli/1_genome
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=U00096.3&rettype=fasta&retmode=txt" \
    > U00096.fa
ln -s U00096.fa genome.fa

# illumina
mkdir -p ~/data/anchr/e_coli/2_illumina
cd ~/data/anchr/e_coli/2_illumina
wget -N ftp://webdata:webdata@ussd-ftp.illumina.com/Data/SequencingRuns/MG1655/MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz
wget -N ftp://webdata:webdata@ussd-ftp.illumina.com/Data/SequencingRuns/MG1655/MiSeq_Ecoli_MG1655_110721_PF_R2.fastq.gz

ln -s MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz R1.fq.gz
ln -s MiSeq_Ecoli_MG1655_110721_PF_R2.fastq.gz R2.fq.gz

# pacbio
mkdir -p ~/data/anchr/e_coli/3_pacbio
```

### *E. coli*: trim/filter

* Trimmed: minimal length 120 bp.

```bash
mkdir -p ~/data/anchr/e_coli/2_illumina/trimmed
cd ~/data/anchr/e_coli/2_illumina/trimmed

anchr trim \
    -l 120 -q 20 \
    ../R1.fq.gz ../R2.fq.gz \
    | bash
```

* Filter: discard any reads with trimmed parts.

```bash
mkdir -p ~/data/anchr/e_coli/2_illumina/filter
cd ~/data/anchr/e_coli/2_illumina/filter

anchr trim \
    -l 151 -q 20 \
    ../R1.fq.gz ../R2.fq.gz \
    | bash
```

* Stats

```bash
cd ~/data/anchr/e_coli

faops n50 -S -C 1_genome/genome.fa
faops n50 -S -C 2_illumina/R1.fq.gz
faops n50 -S -C 2_illumina/trimmed/R1.fq.gz
faops n50 -S -C 2_illumina/filter/R1.fq.gz
```
