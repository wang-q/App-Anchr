# Assemble four genomes from GAGE-B data sets by ANCHR

[TOC levels=1-3]: # " "
- [Assemble four genomes from GAGE-B data sets by ANCHR](#assemble-four-genomes-from-gage-b-data-sets-by-anchr)
- [*Bacillus cereus* ATCC 10987](#bacillus-cereus-atcc-10987)
    - [Bcer: download](#bcer-download)
    - [Bcer: template](#bcer-template)
    - [Bcer: run](#bcer-run)
- [*Rhodobacter sphaeroides* 2.4.1](#rhodobacter-sphaeroides-241)
    - [Rsph: download](#rsph-download)
    - [Rsph: template](#rsph-template)
    - [Rsph: run](#rsph-run)
- [*Mycobacterium abscessus* 6G-0125-R](#mycobacterium-abscessus-6g-0125-r)
    - [Mabs: download](#mabs-download)
    - [Mabs: template](#mabs-template)
    - [Mabs: run](#mabs-run)
- [*Vibrio cholerae* CP1032(5)](#vibrio-cholerae-cp10325)
    - [Vcho: download](#vcho-download)
    - [Vcho: template](#vcho-template)
    - [Vcho: run](#vcho-run)
- [*Mycobacterium abscessus* 6G-0125-R Full](#mycobacterium-abscessus-6g-0125-r-full)
    - [MabsF: download](#mabsf-download)
    - [MabsF: template](#mabsf-template)
    - [MabsF: run](#mabsf-run)
- [*Rhodobacter sphaeroides* 2.4.1 Full](#rhodobacter-sphaeroides-241-full)
    - [RsphF: download](#rsphf-download)
    - [RsphF: template](#rsphf-template)
    - [RsphF: run](#rsphf-run)
- [*Vibrio cholerae* CP1032(5) Full](#vibrio-cholerae-cp10325-full)
    - [VchoF: download](#vchof-download)
    - [VchoF: template](#vchof-template)
    - [VchoF: run](#vchof-run)


# *Bacillus cereus* ATCC 10987

## Bcer: download

* Settings

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Bcer

```

* Reference genome

    * Strain: Bacillus cereus ATCC 10987
    * Taxid: [222523](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=222523)
    * RefSeq assembly accession:
      [GCF_000008005.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/005/GCF_000008005.1_ASM800v1/GCF_000008005.1_ASM800v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0797

```bash
mkdir -p ${WORKING_DIR}/${BASE_NAME}/1_genome
cd ${WORKING_DIR}/${BASE_NAME}/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/005/GCF_000008005.1_ASM800v1/GCF_000008005.1_ASM800v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_003909.8${TAB}1
NC_005707.1${TAB}pBc10987
EOF

faops replace GCF_000008005.1_ASM800v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/gage/Results/Bcer/Bcer.multi.fas paralogs.fas

```

* Illumina

    Download from GAGE-B site.

```bash
cd ${WORKING_DIR}/${BASE_NAME}

mkdir -p 2_illumina
cd 2_illumina

aria2c -x 9 -s 3 -c http://ccb.jhu.edu/gage_b/datasets/B_cereus_MiSeq.tar.gz

# NOT gzipped tar
tar xvf B_cereus_MiSeq.tar.gz raw/frag_1__cov100x.fastq
tar xvf B_cereus_MiSeq.tar.gz raw/frag_2__cov100x.fastq

cat raw/frag_1__cov100x.fastq \
    | pigz -p 8 -c \
    > R1.fq.gz
cat raw/frag_2__cov100x.fastq \
    | pigz -p 8 -c \
    > R2.fq.gz

rm -fr raw
```

* GAGE-B assemblies

```bash
cd ${WORKING_DIR}/${BASE_NAME}

mkdir -p 8_competitor
cd 8_competitor

aria2c -x 9 -s 3 -c http://ccb.jhu.edu/gage_b/genomeAssemblies/B_cereus_MiSeq.tar.gz

tar xvfz B_cereus_MiSeq.tar.gz abyss_ctg.fasta
tar xvfz B_cereus_MiSeq.tar.gz cabog_ctg.fasta
tar xvfz B_cereus_MiSeq.tar.gz mira_ctg.fasta
tar xvfz B_cereus_MiSeq.tar.gz msrca_ctg.fasta
tar xvfz B_cereus_MiSeq.tar.gz sga_ctg.fasta
tar xvfz B_cereus_MiSeq.tar.gz soap_ctg.fasta
tar xvfz B_cereus_MiSeq.tar.gz spades_ctg.fasta
tar xvfz B_cereus_MiSeq.tar.gz velvet_ctg.fasta

```

## Bcer: template

```bash
cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 5432652 \
    --trim2 "--uniq --shuffle --scythe " \
    --coverage2 "40 50 60 all" \
    --qual2 "25 30" \
    --len2 "60" \
    --parallel 16

```

## Bcer: run

```bash
cd ${WORKING_DIR}/${BASE_NAME}

# Illumina QC
bash 2_fastqc.sh
bash 2_kmergenie.sh

# preprocess Illumina reads
bash 2_trim.sh

# reads stats
bash 9_statReads.sh

# quorum
bash 2_quorum.sh
bash 9_statQuorum.sh

# down sampling, k-unitigs and anchors
bash 4_downSampling.sh
bash 4_kunitigs.sh
bash 4_anchors.sh
bash 9_statAnchors.sh

# merge anchors
bash 6_mergeAnchors.sh 4_kunitigs_Q

# anchor sort on ref
bash ~/Scripts/cpan/App-Anchr/share/sort_on_ref.sh \
    6_mergeAnchors/anchor.merge.fasta 1_genome/genome.fa 6_mergeAnchors/anchor.sort
nucmer -l 200 1_genome/genome.fa 6_mergeAnchors/anchor.sort.fa
mummerplot --postscript out.delta -p anchor.sort --small

# mummerplot files
rm *.[fr]plot
rm out.delta
rm *.gp
mv anchor.sort.ps 6_mergeAnchors/

# minidot
minimap 6_mergeAnchors/anchor.sort.fa 1_genome/genome.fa \
    | minidot - > 6_mergeAnchors/anchor.minidot.eps

# quast
rm -fr 9_qa
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    8_competitor/abyss_ctg.fasta \
    8_competitor/cabog_ctg.fasta \
    8_competitor/mira_ctg.fasta \
    8_competitor/msrca_ctg.fasta \
    8_competitor/sga_ctg.fasta \
    8_competitor/soap_ctg.fasta \
    8_competitor/spades_ctg.fasta \
    8_competitor/velvet_ctg.fasta \
    6_mergeAnchors/anchor.merge.fasta \
    6_mergeAnchors/others.non-contained.fasta \
    1_genome/paralogs.fas \
    --label "abyss,cabog,mira,msrca,sga,soap,spades,velvet,merge,others,paralogs" \
    -o 9_qa

```

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 5224283 | 5432652 |       2 |
| Paralogs |    2295 |  223889 |     103 |
| Illumina |     251 | 481.02M | 2080000 |
| uniq     |     251 | 480.99M | 2079856 |
| shuffle  |     251 | 480.99M | 2079856 |
| scythe   |     251 | 479.49M | 2079856 |
| Q25L60   |     250 |  381.7M | 1713588 |
| Q30L60   |     250 | 371.69M | 1750674 |

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q25L60 |  70.3 |   63.2 |  10.016% |     222 | "127" | 5.43M | 5.34M |     0.98 | 0:00'57'' |
| Q30L60 |  68.5 |   64.1 |   6.318% |     214 | "127" | 5.43M | 5.34M |     0.98 | 0:00'53'' |

| Name           | CovCor | N50Anchor |   Sum |   # | N50Others |    Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|----------:|------:|----:|----------:|-------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |     34395 | 5.32M | 260 |       936 | 30.56K | 36 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:01'31'' | 0:00'54'' |
| Q25L60X50P000  |   50.0 |     35092 | 5.32M | 256 |       905 | 29.87K | 37 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:01'47'' | 0:00'54'' |
| Q25L60X60P000  |   60.0 |     34594 | 5.31M | 252 |       937 |  29.9K | 37 |   57.0 | 7.0 |  12.0 | 114.0 | "31,41,51,61,71,81" | 0:02'02'' | 0:00'54'' |
| Q25L60XallP000 |   63.2 |     34594 | 5.31M | 251 |       937 | 29.92K | 37 |   61.0 | 8.0 |  12.3 | 122.0 | "31,41,51,61,71,81" | 0:02'07'' | 0:00'56'' |
| Q30L60X40P000  |   40.0 |     39234 |  5.3M | 240 |       936 | 39.03K | 45 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:01'30'' | 0:00'53'' |
| Q30L60X50P000  |   50.0 |     42832 |  5.3M | 232 |       905 | 37.43K | 44 |   47.5 | 6.5 |   9.3 |  95.0 | "31,41,51,61,71,81" | 0:01'46'' | 0:00'52'' |
| Q30L60X60P000  |   60.0 |     41794 | 5.31M | 222 |       835 |  35.1K | 42 |   57.5 | 7.5 |  11.7 | 115.0 | "31,41,51,61,71,81" | 0:02'00'' | 0:00'53'' |
| Q30L60XallP000 |   64.1 |     42832 | 5.31M | 220 |       824 | 34.62K | 42 |   62.0 | 8.0 |  12.7 | 124.0 | "31,41,51,61,71,81" | 0:02'07'' | 0:00'54'' |

| Name         |     N50 |     Sum |   # |
|:-------------|--------:|--------:|----:|
| Genome       | 5224283 | 5432652 |   2 |
| Paralogs     |    2295 |  223889 | 103 |
| anchor.merge |   46591 | 5359287 | 204 |
| others.merge |   16184 |   68302 |   8 |

# *Rhodobacter sphaeroides* 2.4.1

## Rsph: download

* Settings

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Rsph

```

* Reference genome

    * Strain: Rhodobacter sphaeroides 2.4.1
    * Taxid: [272943](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=272943)
    * RefSeq assembly accession:
      [GCF_000012905.2](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/745/GCF_000006745.1_ASM674v1/GCF_000006745.1_ASM674v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0286

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 1_genome
cd 1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/012/905/GCF_000012905.2_ASM1290v2/GCF_000012905.2_ASM1290v2_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_007493.2${TAB}1
NC_007494.2${TAB}2
NC_009007.1${TAB}A
NC_007488.2${TAB}B
NC_007489.1${TAB}C
NC_007490.2${TAB}D
NC_009008.1${TAB}E
EOF

faops replace GCF_000012905.2_ASM1290v2_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/gage/Results/Rsph/Rsph.multi.fas paralogs.fas

```

* Illumina

    Download from GAGE-B site.

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina
cd 2_illumina

aria2c -x 9 -s 3 -c http://ccb.jhu.edu/gage_b/datasets/R_sphaeroides_MiSeq.tar.gz

# NOT gzipped tar
tar xvf R_sphaeroides_MiSeq.tar.gz raw/insert_540_1__cov100x.fastq
tar xvf R_sphaeroides_MiSeq.tar.gz raw/insert_540_2__cov100x.fastq

cat raw/insert_540_1__cov100x.fastq \
    | pigz -p 8 -c \
    > R1.fq.gz
cat raw/insert_540_2__cov100x.fastq \
    | pigz -p 8 -c \
    > R2.fq.gz

rm -fr raw
```

* GAGE-B assemblies

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 8_competitor
cd 8_competitor

aria2c -x 9 -s 3 -c http://ccb.jhu.edu/gage_b/genomeAssemblies/R_sphaeroides_MiSeq.tar.gz

tar xvfz R_sphaeroides_MiSeq.tar.gz abyss_ctg.fasta
tar xvfz R_sphaeroides_MiSeq.tar.gz cabog_ctg.fasta
tar xvfz R_sphaeroides_MiSeq.tar.gz mira_ctg.fasta
tar xvfz R_sphaeroides_MiSeq.tar.gz msrca_ctg.fasta
tar xvfz R_sphaeroides_MiSeq.tar.gz sga_ctg.fasta
tar xvfz R_sphaeroides_MiSeq.tar.gz soap_ctg.fasta
tar xvfz R_sphaeroides_MiSeq.tar.gz spades_ctg.fasta
tar xvfz R_sphaeroides_MiSeq.tar.gz velvet_ctg.fasta

```

## Rsph: template

```bash
cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 4602977 \
    --trim2 "--uniq --shuffle --scythe " \
    --coverage2 "all" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --parallel 16

```

## Rsph: run

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 3188524 | 4602977 |       7 |
| Paralogs |    2337 |  147155 |      66 |
| Illumina |     251 |  451.8M | 1800000 |
| uniq     |     251 |  447.9M | 1784446 |
| shuffle  |     251 |  447.9M | 1784446 |
| scythe   |     251 | 343.91M | 1784446 |
| Q20L60   |     145 | 174.27M | 1280932 |
| Q25L60   |     134 | 144.87M | 1149640 |
| Q30L60   |     117 | 126.09M | 1149405 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q20L60 |  37.9 |   33.7 |  11.120% |     137 | "37" |  4.6M | 4.55M |     0.99 | 0:00'29'' |
| Q25L60 |  31.5 |   30.1 |   4.500% |     127 | "35" |  4.6M | 4.53M |     0.99 | 0:00'25'' |
| Q30L60 |  27.4 |   26.8 |   2.454% |     112 | "31" |  4.6M | 4.52M |     0.98 | 0:00'24'' |

| Name           | CovCor | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60XallP000 |   33.7 |     22439 | 4.08M | 316 |      5013 | 502.59K | 188 |   29.0 | 3.0 |   6.7 |  57.0 | "31,41,51,61,71,81" | 0:01'02'' | 0:00'46'' |
| Q25L60XallP000 |   30.1 |     16602 | 4.04M | 392 |      9581 | 602.48K | 193 |   26.0 | 3.0 |   5.7 |  52.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'45'' |
| Q30L60XallP000 |   26.8 |      9711 | 3.95M | 593 |      7245 |  780.3K | 280 |   23.0 | 2.0 |   5.7 |  43.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'43'' |

# *Mycobacterium abscessus* 6G-0125-R

## Mabs: download

* Settings

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Mabs

```

* Reference genome

    * *Mycobacterium abscessus* ATCC 19977
        * Taxid: [561007](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=561007)
        * RefSeq assembly accession:
          [GCF_000069185.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/069/185/GCF_000069185.1_ASM6918v1/GCF_000069185.1_ASM6918v1_assembly_report.txt)
        * Proportion of paralogs (> 1000 bp): 0.0168
    * *Mycobacterium abscessus* 6G-0125-R
        * RefSeq assembly accession: GCF_000270985.1

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 1_genome
cd 1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/069/185/GCF_000069185.1_ASM6918v1/GCF_000069185.1_ASM6918v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_010397.1${TAB}1
NC_010394.1${TAB}unnamed
EOF

faops replace GCF_000069185.1_ASM6918v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/gage/Results/Mabs/Mabs.multi.fas paralogs.fas

```

* Illumina

    Download from GAGE-B site.

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina
cd 2_illumina

aria2c -x 9 -s 3 -c http://ccb.jhu.edu/gage_b/datasets/M_abscessus_MiSeq.tar.gz

# NOT gzipped tar
tar xvf M_abscessus_MiSeq.tar.gz raw/reads_1.fastq
tar xvf M_abscessus_MiSeq.tar.gz raw/reads_2.fastq

cat raw/reads_1.fastq \
    | pigz -p 8 -c \
    > R1.fq.gz
cat raw/reads_2.fastq \
    | pigz -p 8 -c \
    > R2.fq.gz

rm -fr raw
```

* GAGE-B assemblies

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 8_competitor
cd 8_competitor

aria2c -x 9 -s 3 -c http://ccb.jhu.edu/gage_b/genomeAssemblies/M_abscessus_MiSeq.tar.gz

tar xvfz M_abscessus_MiSeq.tar.gz abyss_ctg.fasta
tar xvfz M_abscessus_MiSeq.tar.gz cabog_ctg.fasta
tar xvfz M_abscessus_MiSeq.tar.gz mira_ctg.fasta
tar xvfz M_abscessus_MiSeq.tar.gz msrca_ctg.fasta
tar xvfz M_abscessus_MiSeq.tar.gz sga_ctg.fasta
tar xvfz M_abscessus_MiSeq.tar.gz soap_ctg.fasta
tar xvfz M_abscessus_MiSeq.tar.gz spades_ctg.fasta
tar xvfz M_abscessus_MiSeq.tar.gz velvet_ctg.fasta

```

## Mabs: template

```bash
cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 5090491 \
    --trim2 "--uniq --shuffle --scythe " \
    --coverage2 "40 all" \
    --qual2 "25 30" \
    --len2 "60" \
    --parallel 16

```

## Mabs: run

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 5067172 | 5090491 |       2 |
| Paralogs |    1580 |   83364 |      53 |
| Illumina |     251 |    512M | 2039840 |
| uniq     |     251 | 511.87M | 2039330 |
| shuffle  |     251 | 511.87M | 2039330 |
| scythe   |     194 | 368.23M | 2039330 |
| Q25L60   |     175 | 251.37M | 1563560 |
| Q30L60   |     164 | 221.98M | 1502163 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 |  49.4 |   41.4 |  16.151% |     160 | "43" | 5.09M | 5.21M |     1.02 | 0:00'37'' |
| Q30L60 |  43.6 |   38.2 |  12.517% |     152 | "39" | 5.09M | 5.19M |     1.02 | 0:00'34'' |

| Name           | CovCor | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |      9688 |  4.6M | 757 |      1016 | 187.48K | 183 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'11'' | 0:00'46'' |
| Q25L60XallP000 |   41.4 |      9149 | 4.46M | 770 |      1019 | 197.02K | 191 |   38.0 | 3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'47'' |
| Q30L60XallP000 |   38.2 |     14605 | 4.56M | 571 |      1080 | 120.77K | 113 |   36.0 | 2.0 |  10.0 |  63.0 | "31,41,51,61,71,81" | 0:01'08'' | 0:00'47'' |

| Name         |     N50 |     Sum |   # |
|:-------------|--------:|--------:|----:|
| Genome       | 5067172 | 5090491 |   2 |
| Paralogs     |    1580 |   83364 |  53 |
| anchor.merge |   17542 | 5133965 | 486 |
| others.merge |   22340 |  115063 |  13 |

# *Vibrio cholerae* CP1032(5)

## Vcho: download

* Settings

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Vcho

```

* Reference genome

    * *Vibrio cholerae* O1 biovar El Tor str. N16961
        * Taxid: [243277](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=243277)
        * RefSeq assembly accession:
          [GCF_000006745.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/745/GCF_000006745.1_ASM674v1/GCF_000006745.1_ASM674v1_assembly_report.txt)
        * Proportion of paralogs (> 1000 bp): 0.0210
    * *Vibrio cholerae* CP1032(5)
        * RefSeq assembly accession: GCF_000279305.1

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 1_genome
cd 1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/745/GCF_000006745.1_ASM674v1/GCF_000006745.1_ASM674v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_002505.1${TAB}I
NC_002506.1${TAB}II
EOF

faops replace GCF_000006745.1_ASM674v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/gage/Results/Vcho/Vcho.multi.fas paralogs.fas

```

* Illumina

    Download from GAGE-B site.

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina
cd 2_illumina

aria2c -x 9 -s 3 -c http://ccb.jhu.edu/gage_b/datasets/V_cholerae_MiSeq.tar.gz

# NOT gzipped tar
tar xvf V_cholerae_MiSeq.tar.gz raw/reads_1.fastq
tar xvf V_cholerae_MiSeq.tar.gz raw/reads_2.fastq

cat raw/reads_1.fastq \
    | pigz -p 8 -c \
    > R1.fq.gz
cat raw/reads_2.fastq \
    | pigz -p 8 -c \
    > R2.fq.gz

rm -fr raw
```

* GAGE-B assemblies

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 8_competitor
cd 8_competitor

aria2c -x 9 -s 3 -c http://ccb.jhu.edu/gage_b/genomeAssemblies/V_cholerae_MiSeq.tar.gz

tar xvfz V_cholerae_MiSeq.tar.gz abyss_ctg.fasta
tar xvfz V_cholerae_MiSeq.tar.gz cabog_ctg.fasta
tar xvfz V_cholerae_MiSeq.tar.gz mira_ctg.fasta
tar xvfz V_cholerae_MiSeq.tar.gz msrca_ctg.fasta
tar xvfz V_cholerae_MiSeq.tar.gz sga_ctg.fasta
tar xvfz V_cholerae_MiSeq.tar.gz soap_ctg.fasta
tar xvfz V_cholerae_MiSeq.tar.gz spades_ctg.fasta
tar xvfz V_cholerae_MiSeq.tar.gz velvet_ctg.fasta

```

## Vcho: template

```bash
cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 4033464 \
    --trim2 "--uniq --shuffle --scythe " \
    --coverage2 "40 50 all" \
    --qual2 "25 30" \
    --len2 "60" \
    --parallel 16

```

## Vcho: run

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 2961149 | 4033464 |       2 |
| Paralogs |    3483 |  114707 |      48 |
| Illumina |     251 |    400M | 1593624 |
| uniq     |     251 | 397.99M | 1585616 |
| shuffle  |     251 | 397.99M | 1585616 |
| scythe   |     198 | 303.22M | 1585616 |
| Q25L60   |     189 | 254.74M | 1415614 |
| Q30L60   |     182 | 231.42M | 1354982 |

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q25L60 |  63.2 |   53.9 |  14.590% |     180 | "107" | 4.03M | 3.95M |     0.98 | 0:01'32'' |
| Q30L60 |  57.4 |   50.9 |  11.268% |     174 | "103" | 4.03M | 3.94M |     0.98 | 0:01'08'' |

| Name           | CovCor | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |     24211 | 3.55M | 272 |       861 | 92.06K | 105 |   35.0 | 6.0 |   5.7 |  70.0 | "31,41,51,61,71,81" | 0:02'15'' | 0:00'50'' |
| Q25L60X50P000  |   50.0 |     20737 | 3.68M | 316 |       859 | 84.05K |  94 |   45.0 | 7.0 |   8.0 |  90.0 | "31,41,51,61,71,81" | 0:02'32'' | 0:00'49'' |
| Q25L60XallP000 |   53.9 |     19534 | 3.72M | 328 |       855 | 81.64K |  93 |   49.0 | 8.0 |   8.3 |  98.0 | "31,41,51,61,71,81" | 0:02'35'' | 0:00'51'' |
| Q30L60X40P000  |   40.0 |     26748 | 3.57M | 252 |       875 | 83.46K |  89 |   36.0 | 6.0 |   6.0 |  72.0 | "31,41,51,61,71,81" | 0:02'17'' | 0:00'52'' |
| Q30L60X50P000  |   50.0 |     21087 | 3.75M | 285 |       925 | 90.57K |  94 |   46.0 | 7.0 |   8.3 |  92.0 | "31,41,51,61,71,81" | 0:02'22'' | 0:00'50'' |
| Q30L60XallP000 |   50.9 |     21087 | 3.76M | 287 |       893 | 87.93K |  92 |   47.0 | 7.0 |   8.7 |  94.0 | "31,41,51,61,71,81" | 0:02'32'' | 0:00'49'' |

| Name         |     N50 |     Sum |   # |
|:-------------|--------:|--------:|----:|
| Genome       | 2961149 | 4033464 |   2 |
| Paralogs     |    3483 |  114707 |  48 |
| anchor.merge |   42416 | 3871733 | 183 |
| others.merge |   28886 |   51456 |  17 |

# *Mycobacterium abscessus* 6G-0125-R Full

## MabsF: download

* Settings

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=MabsF

```

* Reference genome

```bash
mkdir -p ${HOME}/data/anchr/${BASE_NAME}
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 1_genome
cd 1_genome

cp ~/data/anchr/Mabs/1_genome/genome.fa .
cp ~/data/anchr/Mabs/1_genome/paralogs.fas .

```

* Illumina

    SRX246890, SRR768269

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina
cd 2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR768/SRR768269
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
afcf09a85f0797ab893b05200b575b9d        SRR768269
EOF

md5sum --check sra_md5.txt

fastq-dump --split-files ./SRR768269  
find . -name "*.fastq" | parallel -j 2 pigz -p 8

ln -s SRR768269_1.fastq.gz R1.fq.gz
ln -s SRR768269_2.fastq.gz R2.fq.gz
```

* GAGE-B assemblies

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 8_competitor
cd 8_competitor

cp ~/data/anchr/Mabs/8_competitor/* .

```

## MabsF: template

```bash
cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 5090491 \
    --trim2 "--uniq --shuffle --scythe " \
    --coverage2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --parallel 16

```

## MabsF: run

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 5067172 | 5090491 |       2 |
| Paralogs |    1580 |   83364 |      53 |
| Illumina |     251 |   2.19G | 8741140 |
| uniq     |     251 |   2.19G | 8732398 |
| shuffle  |     251 |   2.19G | 8732398 |
| scythe   |     194 |   1.58G | 8732398 |
| Q25L60   |     174 |   1.07G | 6677670 |
| Q30L60   |     164 | 945.36M | 6407544 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 210.7 |  176.0 |  16.486% |     160 | "43" | 5.09M | 5.49M |     1.08 | 0:05'38'' |
| Q30L60 | 185.9 |  161.9 |  12.893% |     151 | "39" | 5.09M | 5.41M |     1.06 | 0:04'25'' |

```text
#File	pe.cor.raw
#Total	5635562
#Matched	32	0.00057%
#Name	Reads	ReadsPct
Reverse_adapter	28	0.00050%
TruSeq_Adapter_Index_11	3	0.00005%
I7_Primer_Nextera_XT_Index_Kit_v2_N715	1	0.00002%

```

| Name          | CovCor | N50Anchor |   Sum |    # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|------:|-----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |      5981 | 4.46M | 1050 |      1034 | 324.26K | 319 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'02'' | 0:00'56'' |
| Q25L60X40P001 |   40.0 |      5974 | 4.28M | 1036 |      1067 | 397.31K | 378 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'57'' | 0:00'56'' |
| Q25L60X40P002 |   40.0 |      6272 | 4.38M | 1007 |      1027 | 335.33K | 330 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'06'' | 0:00'57'' |
| Q25L60X40P003 |   40.0 |      6453 |  4.5M | 1035 |      1014 | 313.46K | 312 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'59'' | 0:00'57'' |
| Q25L60X80P000 |   80.0 |      3553 | 4.36M | 1517 |       917 | 605.17K | 691 |   70.0 | 7.0 |  16.3 | 136.5 | "31,41,51,61,71,81" | 0:03'04'' | 0:01'00'' |
| Q25L60X80P001 |   80.0 |      3665 | 4.26M | 1458 |       925 | 613.19K | 691 |   71.0 | 6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:03'02'' | 0:01'01'' |
| Q30L60X40P000 |   40.0 |      7930 | 4.37M |  874 |      1086 | 275.84K | 259 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'01'' | 0:01'00'' |
| Q30L60X40P001 |   40.0 |      7807 | 4.34M |  842 |      1020 | 257.99K | 259 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'05'' | 0:00'59'' |
| Q30L60X40P002 |   40.0 |      8291 | 4.41M |  847 |      1080 | 252.33K | 236 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'09'' | 0:01'02'' |
| Q30L60X40P003 |   40.0 |     12279 | 4.77M |  610 |       963 | 105.81K | 109 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:02'14'' | 0:01'03'' |
| Q30L60X80P000 |   80.0 |      5007 | 4.62M | 1240 |       928 | 394.71K | 443 |   72.0 | 7.0 |  17.0 | 139.5 | "31,41,51,61,71,81" | 0:03'01'' | 0:01'01'' |
| Q30L60X80P001 |   80.0 |      6397 | 4.82M | 1098 |       927 | 269.15K | 302 |   73.0 | 5.0 |  19.3 | 132.0 | "31,41,51,61,71,81" | 0:03'12'' | 0:01'02'' |

| Name         |     N50 |     Sum |   # |
|:-------------|--------:|--------:|----:|
| Genome       | 5067172 | 5090491 |   2 |
| Paralogs     |    1580 |   83364 |  53 |
| anchor.merge |  115518 | 5170962 |  91 |
| others.merge |   11421 |  353510 | 100 |

# *Rhodobacter sphaeroides* 2.4.1 Full

## RsphF: download

* Settings

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=RsphF

```

* Reference genome

```bash
mkdir -p ${HOME}/data/anchr/${BASE_NAME}
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 1_genome
cd 1_genome

cp ~/data/anchr/Rsph/1_genome/genome.fa .
cp ~/data/anchr/Rsph/1_genome/paralogs.fas .

```

* Illumina

    SRX160386, SRR522246

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina
cd 2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR522/SRR522246/SRR522246_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR522/SRR522246/SRR522246_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
a29e463504252388f9f381bd8659b084 SRR522246_1.fastq.gz
0e44d585f34c41681a7dcb25960ee273 SRR522246_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s SRR522246_1.fastq.gz R1.fq.gz
ln -s SRR522246_2.fastq.gz R2.fq.gz
```

* GAGE-B assemblies

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 8_competitor
cd 8_competitor

cp ~/data/anchr/Rsph/8_competitor/* .

```

## RsphF: template

```bash
cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 4602977 \
    --trim2 "--uniq --shuffle --scythe " \
    --coverage2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --parallel 16

```

## RsphF: run

| Name     |     N50 |     Sum |        # |
|:---------|--------:|--------:|---------:|
| Genome   | 3188524 | 4602977 |        7 |
| Paralogs |    2337 |  147155 |       66 |
| Illumina |     251 |   4.24G | 16881336 |
| uniq     |     251 |    4.2G | 16731106 |
| shuffle  |     251 |    4.2G | 16731106 |
| scythe   |     251 |   3.23G | 16731106 |
| Q25L60   |     134 |   1.36G | 10770880 |
| Q30L60   |     117 |   1.18G | 10775485 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 294.9 |  281.8 |   4.447% |     126 | "35" |  4.6M | 4.59M |     1.00 | 0:03'10'' |
| Q30L60 | 257.2 |  250.9 |   2.467% |     111 | "31" |  4.6M | 4.55M |     0.99 | 0:02'50'' |

```text
#File	pe.cor.raw
#Total	10535189
#Matched	23	0.00022%
#Name	Reads	ReadsPct
Reverse_adapter	18	0.00017%
TruSeq_Adapter_Index_2	5	0.00005%
```

| Name          | CovCor | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |     19163 | 4.08M | 375 |      4630 | 575.56K | 223 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'47'' |
| Q25L60X40P001 |   40.0 |     18719 | 4.01M | 363 |      5155 | 618.63K | 234 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'47'' |
| Q25L60X40P002 |   40.0 |     17655 | 3.99M | 364 |      6322 | 643.42K | 230 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'48'' |
| Q25L60X40P003 |   40.0 |     18618 | 4.08M | 380 |      4329 | 536.59K | 218 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'48'' |
| Q25L60X40P004 |   40.0 |     18719 | 4.07M | 388 |      4060 | 557.39K | 236 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:01'05'' | 0:00'49'' |
| Q25L60X40P005 |   40.0 |     17278 | 4.02M | 388 |      4329 | 554.12K | 238 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'47'' |
| Q25L60X40P006 |   40.0 |     18218 | 4.01M | 385 |      4736 | 586.36K | 239 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'48'' |
| Q25L60X80P000 |   80.0 |     19091 | 4.09M | 361 |      2945 | 549.67K | 281 |   70.0 | 7.0 |  16.3 | 136.5 | "31,41,51,61,71,81" | 0:01'45'' | 0:00'52'' |
| Q25L60X80P001 |   80.0 |     20844 | 4.09M | 340 |      3300 | 560.67K | 273 |   70.0 | 7.0 |  16.3 | 136.5 | "31,41,51,61,71,81" | 0:01'45'' | 0:00'53'' |
| Q25L60X80P002 |   80.0 |     18672 | 4.09M | 373 |      2889 | 460.52K | 252 |   70.0 | 7.0 |  16.3 | 136.5 | "31,41,51,61,71,81" | 0:01'45'' | 0:00'51'' |
| Q30L60X40P000 |   40.0 |     12244 | 3.93M | 510 |      8202 |  677.3K | 233 |   34.0 | 4.0 |   7.3 |  68.0 | "31,41,51,61,71,81" | 0:01'02'' | 0:00'45'' |
| Q30L60X40P001 |   40.0 |     11487 | 3.95M | 534 |      6099 | 603.96K | 230 |   34.0 | 4.0 |   7.3 |  68.0 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'46'' |
| Q30L60X40P002 |   40.0 |     11611 | 3.92M | 525 |      7444 |  727.9K | 262 |   34.0 | 4.0 |   7.3 |  68.0 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'45'' |
| Q30L60X40P003 |   40.0 |     11234 | 3.93M | 529 |      5247 | 595.93K | 251 |   34.0 | 4.0 |   7.3 |  68.0 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'44'' |
| Q30L60X40P004 |   40.0 |     11867 | 3.93M | 526 |      5221 |  554.6K | 245 |   34.0 | 4.0 |   7.3 |  68.0 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'45'' |
| Q30L60X40P005 |   40.0 |      2501 | 1.34M | 561 |      2795 | 816.68K | 396 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'42'' |
| Q30L60X80P000 |   80.0 |     17201 |    4M | 387 |      9830 | 601.35K | 182 |   69.0 | 7.0 |  16.0 | 135.0 | "31,41,51,61,71,81" | 0:01'39'' | 0:00'50'' |
| Q30L60X80P001 |   80.0 |     16490 | 3.99M | 391 |      7475 | 614.62K | 197 |   69.0 | 7.0 |  16.0 | 135.0 | "31,41,51,61,71,81" | 0:01'49'' | 0:00'51'' |
| Q30L60X80P002 |   80.0 |     18894 | 3.63M | 363 |      9846 | 750.56K | 203 |   70.0 | 3.0 |  20.3 | 118.5 | "31,41,51,61,71,81" | 0:01'38'' | 0:00'48'' |

| Name         |     N50 |     Sum |   # |
|:-------------|--------:|--------:|----:|
| Genome       | 3188524 | 4602977 |   7 |
| Paralogs     |    2337 |  147155 |  66 |
| anchor.merge |   45265 | 4419978 | 193 |
| others.merge |   13391 |  516209 |  92 |

# *Vibrio cholerae* CP1032(5) Full

## VchoF: download

* Settings

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=VchoF

```

* Reference genome

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 1_genome
cd 1_genome

cp ~/data/anchr/Vcho/1_genome/genome.fa .
cp ~/data/anchr/Vcho/1_genome/paralogs.fas .

```

* Illumina

    SRX247310, SRR769320

```bash
mkdir -p ~/data/anchr/Vcho/2_illumina
cd ~/data/anchr/Vcho/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR769/SRR769320
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
28f49ca6ae9a00c3a7937e00e04e8512        SRR769320
EOF

md5sum --check sra_md5.txt

fastq-dump --split-files ./SRR769320  
find . -name "*.fastq" | parallel -j 2 pigz -p 8

ln -s SRR769320_1.fastq.gz R1.fq.gz
ln -s SRR769320_2.fastq.gz R2.fq.gz
```

* GAGE-B assemblies

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 8_competitor
cd 8_competitor

cp ~/data/anchr/Vcho/8_competitor/* .

```

## VchoF: template

```bash
cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 4033464 \
    --trim2 "--uniq --shuffle --scythe " \
    --coverage2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --parallel 16

```

## VchoF: run

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 2961149 | 4033464 |       2 |
| Paralogs |    3483 |  114707 |      48 |
| Illumina |     251 |   1.76G | 7020550 |
| uniq     |     251 |   1.73G | 6883592 |
| shuffle  |     251 |   1.73G | 6883592 |
| scythe   |     198 |   1.31G | 6883592 |
| Q25L60   |     188 |    1.1G | 6131120 |
| Q30L60   |     181 | 997.78M | 5858935 |

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q25L60 | 272.6 |  232.9 |  14.578% |     179 | "107" | 4.03M | 4.37M |     1.08 | 0:02'21'' |
| Q30L60 | 247.5 |  218.8 |  11.586% |     173 | "103" | 4.03M | 4.16M |     1.03 | 0:02'10'' |

```text
#File	pe.cor.raw
#Total	5225156
#Matched	255	0.00488%
#Name	Reads	ReadsPct
TruSeq_Adapter_Index_6	101	0.00193%
TruSeq_Adapter_Index_11	102	0.00195%
Reverse_adapter	27	0.00052%
RNA_PCR_Primer_Index_36_(RPI36)	12	0.00023%
TruSeq_Adapter_Index_5	7	0.00013%
RNA_PCR_Primer_Index_11_(RPI11)	5	0.00010%
I7_Primer_Nextera_XT_Index_Kit_v2_N715	1	0.00002%

```

| Name          | CovCor | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |      3016 | 2.99M | 1165 |       921 | 674.57K |  747 |   34.0 |  5.0 |   6.3 |  68.0 | "31,41,51,61,71,81" | 0:00'59'' | 0:00'36'' |
| Q25L60X40P001 |   40.0 |      3246 | 2.93M | 1107 |       923 | 720.47K |  783 |   34.0 |  5.0 |   6.3 |  68.0 | "31,41,51,61,71,81" | 0:00'59'' | 0:00'35'' |
| Q25L60X40P002 |   40.0 |      3103 | 2.94M | 1140 |       936 | 732.92K |  791 |   34.0 |  5.0 |   6.3 |  68.0 | "31,41,51,61,71,81" | 0:00'59'' | 0:00'35'' |
| Q25L60X40P003 |   40.0 |      3106 | 2.98M | 1161 |       921 | 699.26K |  770 |   34.0 |  5.0 |   6.3 |  68.0 | "31,41,51,61,71,81" | 0:00'59'' | 0:00'36'' |
| Q25L60X40P004 |   40.0 |      2911 | 3.01M | 1197 |       901 | 689.38K |  757 |   34.0 |  5.0 |   6.3 |  68.0 | "31,41,51,61,71,81" | 0:00'59'' | 0:00'35'' |
| Q25L60X80P000 |   80.0 |      2119 | 2.48M | 1256 |       855 |   1.17M | 1415 |   65.0 |  9.0 |  12.7 | 130.0 | "31,41,51,61,71,81" | 0:01'37'' | 0:00'35'' |
| Q25L60X80P001 |   80.0 |      2141 | 2.44M | 1240 |       852 |   1.18M | 1430 |   65.0 |  9.0 |  12.7 | 130.0 | "31,41,51,61,71,81" | 0:01'37'' | 0:00'36'' |
| Q30L60X40P000 |   40.0 |      7054 | 3.42M |  716 |       916 |    258K |  272 |   35.0 |  5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'36'' |
| Q30L60X40P001 |   40.0 |      7414 | 3.45M |  672 |       914 | 250.05K |  258 |   35.0 |  6.0 |   5.7 |  70.0 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'36'' |
| Q30L60X40P002 |   40.0 |      6919 | 3.44M |  712 |      1011 |  280.6K |  269 |   35.5 |  4.5 |   7.3 |  71.0 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'36'' |
| Q30L60X40P003 |   40.0 |      6914 | 3.55M |  731 |       911 | 199.53K |  209 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'37'' |
| Q30L60X40P004 |   40.0 |      7142 | 3.43M |  709 |       932 | 239.48K |  249 |   35.0 |  5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'36'' |
| Q30L60X80P000 |   80.0 |      4316 |  3.4M |  991 |       875 | 411.15K |  471 |   70.0 | 10.0 |  13.3 | 140.0 | "31,41,51,61,71,81" | 0:01'35'' | 0:00'37'' |
| Q30L60X80P001 |   80.0 |      4132 | 3.46M | 1040 |       904 | 366.77K |  403 |   71.0 | 10.0 |  13.7 | 142.0 | "31,41,51,61,71,81" | 0:01'36'' | 0:00'37'' |

| Name     |     N50 |     Sum |    # |
|:---------|--------:|--------:|-----:|
| Genome   | 2961149 | 4033464 |    2 |
| Paralogs |    3483 |  114707 |   48 |
| anchor   |   48130 | 3919105 |  249 |
| others   |    1000 | 2951176 | 2904 |

