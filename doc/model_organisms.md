# Assemble genomes of model organisms by ANCHR

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

* Filter, 151 bp

    * N50: 151
    * S: 371,039,918
    * C: 2,457,218

* Trimmed, 120-151 bp

    * N50: 151
    * S: 577,027,508
    * C: 3,871,323

### *E. coli*: download

```bash
# genome
mkdir -p ~/data/anchr/e_coli/1_genome
cd ~/data/anchr/e_coli/1_genome
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=U00096.3&rettype=fasta&retmode=txt" \
    > U00096.fa

# illumina
mkdir -p ~/data/anchr/e_coli/2_illumina
cd ~/data/anchr/e_coli/2GS
wget -N ftp://webdata:webdata@ussd-ftp.illumina.com/Data/SequencingRuns/MG1655/MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz
wget -N ftp://webdata:webdata@ussd-ftp.illumina.com/Data/SequencingRuns/MG1655/MiSeq_Ecoli_MG1655_110721_PF_R2.fastq.gz

# pacbio
mkdir -p ~/data/anchr/e_coli/3GS

# stats
cd ~/data/anchr/e_coli
faops n50 -S -C 1_genome/U00096.fa
faops n50 -S -C 2_illumina/MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz
```

### *E. coli*: trim illumina

```bash
mkdir -p ~/data/anchr/e_coli/2_illumina/trimmed
cd ~/data/anchr/e_coli/2_illumina/trimmed

anchr trim ../MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz ../MiSeq_Ecoli_MG1655_110721_PF_R2.fastq.gz

```
