# Assemble four genomes from GAGE-B data sets by ANCHR

[TOC levels=1-3]: # " "
- [Assemble four genomes from GAGE-B data sets by ANCHR](#assemble-four-genomes-from-gage-b-data-sets-by-anchr)
- [*Bacillus cereus* ATCC 10987](#bacillus-cereus-atcc-10987)
    - [Bcer: download](#bcer-download)
    - [Bcer: template](#bcer-template)
    - [Bcer: run](#bcer-run)
- [*Rhodobacter sphaeroides* 2.4.1](#rhodobacter-sphaeroides-241)
    - [Rsph: download](#rsph-download)
    - [Rsph: preprocess Illumina reads](#rsph-preprocess-illumina-reads)
    - [Rsph: reads stats](#rsph-reads-stats)
    - [Rsph: quorum](#rsph-quorum)
    - [Rsph: down sampling](#rsph-down-sampling)
    - [Rsph: k-unitigs and anchors (sampled)](#rsph-k-unitigs-and-anchors-sampled)
    - [Rsph: merge anchors](#rsph-merge-anchors)
    - [Rsph: final stats](#rsph-final-stats)
    - [Rsph: clear intermediate files](#rsph-clear-intermediate-files)
- [*Mycobacterium abscessus* 6G-0125-R](#mycobacterium-abscessus-6g-0125-r)
    - [Mabs: download](#mabs-download)
    - [Mabs: preprocess Illumina reads](#mabs-preprocess-illumina-reads)
    - [Mabs: reads stats](#mabs-reads-stats)
    - [Mabs: quorum](#mabs-quorum)
    - [Mabs: down sampling](#mabs-down-sampling)
    - [Mabs: k-unitigs and anchors (sampled)](#mabs-k-unitigs-and-anchors-sampled)
    - [Mabs: merge anchors](#mabs-merge-anchors)
    - [Mabs: final stats](#mabs-final-stats)
    - [Mabs: clear intermediate files](#mabs-clear-intermediate-files)
- [*Vibrio cholerae* CP1032(5)](#vibrio-cholerae-cp10325)
    - [Vcho: download](#vcho-download)
    - [Vcho: preprocess Illumina reads](#vcho-preprocess-illumina-reads)
    - [Vcho: reads stats](#vcho-reads-stats)
    - [Vcho: quorum](#vcho-quorum)
    - [Vcho: down sampling](#vcho-down-sampling)
    - [Vcho: k-unitigs and anchors (sampled)](#vcho-k-unitigs-and-anchors-sampled)
    - [Vcho: merge anchors](#vcho-merge-anchors)
    - [Vcho: final stats](#vcho-final-stats)
    - [Vcho: clear intermediate files](#vcho-clear-intermediate-files)
- [*Mycobacterium abscessus* 6G-0125-R Full](#mycobacterium-abscessus-6g-0125-r-full)
    - [MabsF: download](#mabsf-download)
    - [MabsF: preprocess Illumina reads](#mabsf-preprocess-illumina-reads)
    - [MabsF: reads stats](#mabsf-reads-stats)
    - [MabsF: quorum](#mabsf-quorum)
    - [MabsF: down sampling](#mabsf-down-sampling)
    - [MabsF: k-unitigs and anchors (sampled)](#mabsf-k-unitigs-and-anchors-sampled)
    - [MabsF: merge anchors](#mabsf-merge-anchors)
    - [MabsF: final stats](#mabsf-final-stats)
    - [MabsF: clear intermediate files](#mabsf-clear-intermediate-files)
- [*Rhodobacter sphaeroides* 2.4.1 Full](#rhodobacter-sphaeroides-241-full)
    - [RsphF: download](#rsphf-download)
    - [RsphF: preprocess Illumina reads](#rsphf-preprocess-illumina-reads)
    - [RsphF: reads stats](#rsphf-reads-stats)
    - [RsphF: quorum](#rsphf-quorum)
    - [RsphF: down sampling](#rsphf-down-sampling)
    - [RsphF: k-unitigs and anchors (sampled)](#rsphf-k-unitigs-and-anchors-sampled)
    - [RsphF: merge anchors](#rsphf-merge-anchors)
    - [RsphF: final stats](#rsphf-final-stats)
    - [RsphF: clear intermediate files](#rsphf-clear-intermediate-files)
- [*Vibrio cholerae* CP1032(5) Full](#vibrio-cholerae-cp10325-full)
    - [VchoF: download](#vchof-download)
    - [VchoF: preprocess Illumina reads](#vchof-preprocess-illumina-reads)
    - [VchoF: reads stats](#vchof-reads-stats)
    - [VchoF: quorum](#vchof-quorum)
    - [VchoF: down sampling](#vchof-down-sampling)
    - [VchoF: k-unitigs and anchors (sampled)](#vchof-k-unitigs-and-anchors-sampled)
    - [VchoF: merge anchors](#vchof-merge-anchors)
    - [VchoF: final stats](#vchof-final-stats)
    - [VchoF: clear intermediate files](#vchof-clear-intermediate-files)


# *Bacillus cereus* ATCC 10987

## Bcer: download

* Settings

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Bcer
REAL_G=5432652
IS_EUK="false"

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
    --genome ${REAL_G} \
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
bash 5_kunitigs.sh
bash 5_anchors.sh
bash 9_statAnchors.sh

# merge anchors
bash 6_mergeAnchors.sh 5_kunitigs

# anchor sort on ref
bash ~/Scripts/cpan/App-Anchr/share/sort_on_ref.sh 6_mergeAnchors/anchor.merge.fasta 1_genome/genome.fa 6_mergeAnchors/anchor.sort
nucmer -l 200 1_genome/genome.fa 6_mergeAnchors/anchor.sort.fa
mummerplot -png out.delta -p anchor.sort --large

# mummerplot files
rm *.[fr]plot
rm out.delta
rm *.gp
mv anchor.sort.png 6_mergeAnchors/

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

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat3.md
printf "|:--|--:|--:|--:|\n" >> stat3.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Paralogs";   faops n50 -H -S -C 1_genome/paralogs.fas;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "anchor.merge"; faops n50 -H -S -C merge/anchor.merge.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "others.merge"; faops n50 -H -S -C merge/others.merge.fasta;) >> stat3.md

cat stat3.md

```

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
BASE_NAME=Rsph
REAL_G=4602977
COVERAGE2="26 30 33"
READ_QUAL="20 25 30"
READ_LEN="60"

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

* FastQC

* kmergenie

## Rsph: preprocess Illumina reads

## Rsph: reads stats

| Name     |     N50 |       Sum |       # |
|:---------|--------:|----------:|--------:|
| Genome   | 3188524 |   4602977 |       7 |
| Paralogs |    2337 |    147155 |      66 |
| Illumina |     251 | 451800000 | 1800000 |
| uniq     |     251 | 447895946 | 1784446 |
| shuffle  |     251 | 447895946 | 1784446 |
| scythe   |     243 | 341352824 | 1784446 |
| Q20L60   |     145 | 174386583 | 1281040 |
| Q25L60   |     134 | 144921317 | 1149546 |
| Q30L60   |     117 | 126132575 | 1149416 |

## Rsph: quorum

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q20L60 | 174.39M |  37.9 | 154.88M |   33.6 |  11.186% |     137 | "37" |  4.6M | 4.55M |     0.99 | 0:00'27'' |
| Q25L60 | 144.92M |  31.5 | 138.39M |   30.1 |   4.509% |     127 | "35" |  4.6M | 4.53M |     0.99 | 0:00'24'' |
| Q30L60 | 126.36M |  27.5 | 123.26M |   26.8 |   2.454% |     112 | "31" |  4.6M | 4.52M |     0.98 | 0:00'22'' |

## Rsph: down sampling

## Rsph: k-unitigs and anchors (sampled)

| Name          | SumCor  | CovCor | N50SR |   Sum |   # | N50Anchor |   Sum |   # | N50Others |     Sum |   # |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|:--------|-------:|------:|------:|----:|----------:|------:|----:|----------:|--------:|----:|--------------------:|----------:|----------:|
| Q20L60X26P000 | 119.68M |   26.0 | 16387 | 4.55M | 478 |     17883 |  4.2M | 356 |      7220 | 352.21K | 122 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'24'' |
| Q20L60X30P000 | 138.09M |   30.0 | 18769 | 4.56M | 449 |     21000 | 4.28M | 333 |      4745 | 279.58K | 116 | "31,41,51,61,71,81" | 0:01'26'' | 0:00'24'' |
| Q20L60X33P000 | 151.9M  |   33.0 | 20586 | 4.56M | 434 |     21857 | 4.23M | 314 |      6186 | 326.95K | 120 | "31,41,51,61,71,81" | 0:01'25'' | 0:00'24'' |
| Q25L60X26P000 | 119.68M |   26.0 | 16013 | 4.52M | 546 |     16320 | 4.15M | 436 |     12569 | 375.62K | 110 | "31,41,51,61,71,81" | 0:01'17'' | 0:00'24'' |
| Q25L60X30P000 | 138.09M |   30.0 | 17440 | 4.53M | 493 |     17665 | 4.18M | 388 |     12285 | 353.24K | 105 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'24'' |
| Q30L60X26P000 | 119.68M |   26.0 | 10294 | 4.51M | 747 |     10241 | 4.11M | 597 |     12285 | 402.75K | 150 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'23'' |

## Rsph: merge anchors

## Rsph: final stats

* Stats

| Name         |     N50 |     Sum |   # |
|:-------------|--------:|--------:|----:|
| Genome       | 3188524 | 4602977 |   7 |
| Paralogs     |    2337 |  147155 |  66 |
| anchor.merge |   27785 | 4284438 | 259 |
| others.merge |   13124 |  354828 |  53 |

## Rsph: clear intermediate files

# *Mycobacterium abscessus* 6G-0125-R

## Mabs: download

* Settings

```bash
BASE_NAME=Mabs
REAL_G=5090491
COVERAGE2="38 41 44"
READ_QUAL="20 25 30"
READ_LEN="60"

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

* FastQC

* kmergenie

## Mabs: preprocess Illumina reads

## Mabs: reads stats

| Name     |     N50 |       Sum |       # |
|:---------|--------:|----------:|--------:|
| Genome   | 5067172 |   5090491 |       2 |
| Paralogs |    1580 |     83364 |      53 |
| Illumina |     251 | 511999840 | 2039840 |
| uniq     |     251 | 511871830 | 2039330 |
| shuffle  |     251 | 511871830 | 2039330 |
| scythe   |     194 | 368228930 | 2039330 |
| Q20L60   |     180 | 291615493 | 1746436 |
| Q25L60   |     175 | 251369214 | 1563560 |
| Q30L60   |     164 | 221984844 | 1502163 |

## Mabs: quorum

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q20L60 | 291.62M |  57.3 | 228.25M |   44.8 |  21.728% |     166 | "45" | 5.09M | 5.23M |     1.03 | 0:00'42'' |
| Q25L60 | 251.37M |  49.4 | 210.77M |   41.4 |  16.150% |     160 | "43" | 5.09M | 5.21M |     1.02 | 0:00'35'' |
| Q30L60 |  222.2M |  43.6 | 194.39M |   38.2 |  12.516% |     152 | "39" | 5.09M | 5.19M |     1.02 | 0:00'33'' |

## Mabs: down sampling

## Mabs: k-unitigs and anchors (sampled)

| Name          |  SumCor | CovCor | N50SR |   Sum |    # | N50Anchor |   Sum |    # | N50Others |     Sum |   # |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|--------:|-------:|------:|------:|-----:|----------:|------:|-----:|----------:|--------:|----:|--------------------:|----------:|:----------|
| Q20L60X38P000 | 193.44M |   38.0 |  7337 | 5.22M | 1097 |      7432 | 5.05M |  943 |       927 | 173.92K | 154 | "31,41,51,61,71,81" | 0:01'45'' | 0:00'33'' |
| Q20L60X41P000 | 208.71M |   41.0 |  7052 | 5.22M | 1143 |      7155 | 5.05M |  984 |       926 | 177.88K | 159 | "31,41,51,61,71,81" | 0:01'50'' | 0:00'32'' |
| Q20L60X44P000 | 223.98M |   44.0 |  6652 | 5.22M | 1194 |      6730 | 5.04M | 1025 |       918 | 184.03K | 169 | "31,41,51,61,71,81" | 0:01'49'' | 0:00'33'' |
| Q25L60X38P000 | 193.44M |   38.0 |  9615 | 5.18M |  841 |      9733 | 5.11M |  753 |       775 |  68.05K |  88 | "31,41,51,61,71,81" | 0:01'49'' | 0:00'31'' |
| Q25L60X41P000 | 208.71M |   41.0 |  9230 |  5.2M |  876 |      9323 | 5.09M |  786 |       939 | 112.35K |  90 | "31,41,51,61,71,81" | 0:01'54'' | 0:00'30'' |
| Q30L60X38P000 | 193.44M |   38.0 | 14772 | 5.17M |  616 |     14869 | 5.08M |  558 |      7461 |   93.6K |  58 | "31,41,51,61,71,81" | 0:01'54'' | 0:00'29'' |

## Mabs: merge anchors

## Mabs: final stats

* Stats

| Name         |     N50 |     Sum |   # |
|:-------------|--------:|--------:|----:|
| Genome       | 5067172 | 5090491 |   2 |
| Paralogs     |    1580 |   83364 |  53 |
| anchor.merge |   17542 | 5133965 | 486 |
| others.merge |   22340 |  115063 |  13 |

## Mabs: clear intermediate files

# *Vibrio cholerae* CP1032(5)

## Vcho: download

* Settings

```bash
BASE_NAME=Vcho
REAL_G=4033464
COVERAGE2="30 40 50"
READ_QUAL="20 25 30"
READ_LEN="60"

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

* FastQC

* kmergenie

## Vcho: preprocess Illumina reads

## Vcho: reads stats

| Name     |     N50 |       Sum |       # |
|:---------|--------:|----------:|--------:|
| Genome   | 2961149 |   4033464 |       2 |
| Paralogs |    3483 |    114707 |      48 |
| Illumina |     251 | 399999624 | 1593624 |
| uniq     |     251 | 397989616 | 1585616 |
| shuffle  |     251 | 397989616 | 1585616 |
| scythe   |     198 | 303013908 | 1585616 |
| Q20L60   |     192 | 276631232 | 1503664 |
| Q25L60   |     189 | 254687912 | 1415292 |
| Q30L60   |     182 | 231390861 | 1354796 |

## Vcho: quorum

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q20L60 | 276.63M |  68.6 |  224.3M |   55.6 |  18.916% |     183 | "113" | 4.03M | 3.96M |     0.98 | 0:00'38'' |
| Q25L60 | 254.69M |  63.1 | 217.52M |   53.9 |  14.595% |     179 | "109" | 4.03M | 3.95M |     0.98 | 0:00'35'' |
| Q30L60 | 231.48M |  57.4 | 205.39M |   50.9 |  11.270% |     173 | "105" | 4.03M | 3.94M |     0.98 | 0:00'34'' |

## Vcho: down sampling

## Vcho: k-unitigs and anchors (sampled)

| Name          |  SumCor | CovCor | N50SR |   Sum |   # | N50Anchor |   Sum |   # | N50Others |     Sum |   # |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|--------:|-------:|------:|------:|----:|----------:|------:|----:|----------:|--------:|----:|--------------------:|----------:|:----------|
| Q20L60X30P000 |    121M |   30.0 |  9233 | 3.93M | 735 |      9454 | 3.82M | 591 |       789 |  110.4K | 144 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'22'' |
| Q20L60X40P000 | 161.34M |   40.0 |  7986 | 3.93M | 814 |      8203 | 3.83M | 667 |       781 | 109.64K | 147 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'23'' |
| Q20L60X50P000 | 201.67M |   50.0 |  7092 | 3.94M | 885 |      7363 | 3.81M | 720 |       791 | 124.43K | 165 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'23'' |
| Q25L60X30P000 |    121M |   30.0 | 28565 | 3.92M | 342 |     29036 | 3.83M | 247 |       838 |  91.98K |  95 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'22'' |
| Q25L60X40P000 | 161.34M |   40.0 | 25247 | 3.92M | 344 |     26748 | 3.86M | 264 |       799 |  63.73K |  80 | "31,41,51,61,71,81" | 0:01'28'' | 0:00'23'' |
| Q25L60X50P000 | 201.67M |   50.0 | 20404 | 3.96M | 397 |     21170 | 3.85M | 312 |      1116 | 111.14K |  85 | "31,41,51,61,71,81" | 0:01'28'' | 0:00'23'' |
| Q30L60X30P000 |    121M |   30.0 | 31346 | 3.91M | 315 |     31402 | 3.84M | 230 |       830 |  69.91K |  85 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'22'' |
| Q30L60X40P000 | 161.34M |   40.0 | 29100 | 3.92M | 326 |     29292 | 3.86M | 251 |       794 |   60.7K |  75 | "31,41,51,61,71,81" | 0:01'22'' | 0:00'22'' |
| Q30L60X50P000 | 201.67M |   50.0 | 20702 | 3.93M | 369 |     21005 | 3.87M | 296 |       838 |  61.03K |  73 | "31,41,51,61,71,81" | 0:01'16'' | 0:00'23'' |

## Vcho: merge anchors

## Vcho: final stats

* Stats

| Name         |     N50 |     Sum |   # |
|:-------------|--------:|--------:|----:|
| Genome       | 2961149 | 4033464 |   2 |
| Paralogs     |    3483 |  114707 |  48 |
| anchor.merge |   42416 | 3871733 | 183 |
| others.merge |   28886 |   51456 |  17 |

## Vcho: clear intermediate files

# *Mycobacterium abscessus* 6G-0125-R Full

## MabsF: download

* Settings

```bash
BASE_NAME=MabsF
REAL_G=5090491
COVERAGE2="30 40 50 60 80 120 160"
READ_QUAL="25 30"
READ_LEN="60"

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
BASE_NAME=MabsF
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 8_competitor
cd 8_competitor

cp ~/data/anchr/Mabs/8_competitor/* .

```

* FastQC

* kmergenie

## MabsF: preprocess Illumina reads

## MabsF: reads stats

| Name     |     N50 |        Sum |       # |
|:---------|--------:|-----------:|--------:|
| Genome   | 5067172 |    5090491 |       2 |
| Paralogs |    1580 |      83364 |      53 |
| Illumina |     251 | 2194026140 | 8741140 |
| uniq     |     251 | 2191831898 | 8732398 |
| shuffle  |     251 | 2191831898 | 8732398 |
| scythe   |     194 | 1576871211 | 8732398 |
| Q25L60   |     174 | 1072306601 | 6675988 |
| Q30L60   |     164 |  945213634 | 6406573 |

## MabsF: quorum

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 |   1.07G | 210.6 | 895.68M |  176.0 |  16.472% |     160 | "43" | 5.09M | 5.49M |     1.08 | 0:02'27'' |
| Q30L60 | 946.13M | 185.9 | 824.32M |  161.9 |  12.875% |     151 | "39" | 5.09M | 5.41M |     1.06 | 0:02'10'' |

## MabsF: down sampling

## MabsF: k-unitigs and anchors (sampled)

| Name           |  SumCor | CovCor | N50SR |   Sum |    # | N50Anchor |   Sum |    # | N50Others |     Sum |    # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|--------:|-------:|------:|------:|-----:|----------:|------:|-----:|----------:|--------:|-----:|--------------------:|----------:|:----------|
| Q25L60X30P000  | 152.71M |   30.0 |  7842 | 5.19M | 1053 |      8031 | 5.06M |  907 |       855 | 128.05K |  146 | "31,41,51,61,71,81" | 0:02'13'' | 0:00'47'' |
| Q25L60X30P001  | 152.71M |   30.0 |  8261 | 5.18M |  990 |      8319 | 5.08M |  870 |       782 | 103.59K |  120 | "31,41,51,61,71,81" | 0:02'13'' | 0:00'46'' |
| Q25L60X30P002  | 152.71M |   30.0 |  7662 | 5.18M | 1036 |      7834 | 5.08M |  914 |       824 |  99.19K |  122 | "31,41,51,61,71,81" | 0:02'13'' | 0:00'46'' |
| Q25L60X30P003  | 152.71M |   30.0 |  7697 | 5.21M | 1065 |      7835 | 5.07M |  927 |       901 | 144.19K |  138 | "31,41,51,61,71,81" | 0:02'10'' | 0:00'45'' |
| Q25L60X30P004  | 152.71M |   30.0 |  7601 |  5.2M | 1008 |      7624 | 5.06M |  887 |       929 | 134.94K |  121 | "31,41,51,61,71,81" | 0:02'12'' | 0:00'45'' |
| Q25L60X40P000  | 203.62M |   40.0 |  6605 |  5.2M | 1226 |      6826 | 5.05M | 1050 |       825 | 147.35K |  176 | "31,41,51,61,71,81" | 0:02'30'' | 0:00'46'' |
| Q25L60X40P001  | 203.62M |   40.0 |  6339 |  5.2M | 1254 |      6438 | 5.04M | 1064 |       808 | 159.81K |  190 | "31,41,51,61,71,81" | 0:02'34'' | 0:00'50'' |
| Q25L60X40P002  | 203.62M |   40.0 |  6007 | 5.22M | 1298 |      6202 | 5.03M | 1100 |       881 | 190.08K |  198 | "31,41,51,61,71,81" | 0:02'27'' | 0:00'51'' |
| Q25L60X40P003  | 203.62M |   40.0 |  6338 | 5.18M | 1209 |      6522 | 5.06M | 1052 |       804 | 122.07K |  157 | "31,41,51,61,71,81" | 0:02'36'' | 0:00'55'' |
| Q25L60X50P000  | 254.52M |   50.0 |  5316 |  5.2M | 1460 |      5409 |    5M | 1217 |       782 | 190.82K |  243 | "31,41,51,61,71,81" | 0:02'45'' | 0:00'53'' |
| Q25L60X50P001  | 254.52M |   50.0 |  5192 |  5.2M | 1512 |      5334 | 4.99M | 1244 |       778 | 204.22K |  268 | "31,41,51,61,71,81" | 0:03'18'' | 0:00'53'' |
| Q25L60X50P002  | 254.52M |   50.0 |  5090 | 5.19M | 1515 |      5280 |    5M | 1257 |       788 | 199.32K |  258 | "31,41,51,61,71,81" | 0:03'39'' | 0:00'59'' |
| Q25L60X60P000  | 305.43M |   60.0 |  4579 |  5.2M | 1690 |      4765 | 4.94M | 1356 |       779 | 261.91K |  334 | "31,41,51,61,71,81" | 0:04'19'' | 0:00'56'' |
| Q25L60X60P001  | 305.43M |   60.0 |  4386 | 5.19M | 1705 |      4641 | 4.94M | 1379 |       788 | 249.65K |  326 | "31,41,51,61,71,81" | 0:04'24'' | 0:00'53'' |
| Q25L60X80P000  | 407.24M |   80.0 |  3459 | 5.19M | 2095 |      3696 |  4.8M | 1590 |       779 | 381.75K |  505 | "31,41,51,61,71,81" | 0:05'42'' | 0:01'04'' |
| Q25L60X80P001  | 407.24M |   80.0 |  3496 |  5.2M | 2101 |      3734 | 4.82M | 1612 |       790 |  388.9K |  489 | "31,41,51,61,71,81" | 0:05'30'' | 0:01'03'' |
| Q25L60X120P000 | 610.86M |  120.0 |  2442 | 5.14M | 2753 |      2751 | 4.47M | 1852 |       775 | 672.18K |  901 | "31,41,51,61,71,81" | 0:08'29'' | 0:01'20'' |
| Q25L60X160P000 | 814.48M |  160.0 |  1942 | 5.06M | 3217 |      2314 | 4.16M | 1989 |       766 | 901.47K | 1228 | "31,41,51,61,71,81" | 0:08'47'' | 0:01'19'' |
| Q30L60X30P000  | 152.71M |   30.0 | 10078 | 5.21M |  822 |     10078 | 5.07M |  741 |     15243 | 141.59K |   81 | "31,41,51,61,71,81" | 0:04'39'' | 0:00'53'' |
| Q30L60X30P001  | 152.71M |   30.0 | 10183 |  5.2M |  799 |     10389 | 5.08M |  713 |      2266 | 118.88K |   86 | "31,41,51,61,71,81" | 0:04'13'' | 0:00'48'' |
| Q30L60X30P002  | 152.71M |   30.0 |  9069 | 5.18M |  878 |      9298 | 5.07M |  780 |       960 | 113.97K |   98 | "31,41,51,61,71,81" | 0:04'17'' | 0:00'47'' |
| Q30L60X30P003  | 152.71M |   30.0 |  9751 | 5.17M |  821 |      9955 | 5.09M |  739 |       845 |  71.59K |   82 | "31,41,51,61,71,81" | 0:03'40'' | 0:00'47'' |
| Q30L60X30P004  | 152.71M |   30.0 | 12149 | 5.22M |  667 |     12101 | 5.12M |  609 |     26940 |  98.82K |   58 | "31,41,51,61,71,81" | 0:04'09'' | 0:00'50'' |
| Q30L60X40P000  | 203.62M |   40.0 |  8663 | 5.22M |  939 |      8680 | 5.08M |  838 |       991 | 134.57K |  101 | "31,41,51,61,71,81" | 0:04'47'' | 0:00'48'' |
| Q30L60X40P001  | 203.62M |   40.0 |  8130 | 5.19M |  980 |      8220 | 5.08M |  878 |       885 | 109.54K |  102 | "31,41,51,61,71,81" | 0:04'27'' | 0:00'51'' |
| Q30L60X40P002  | 203.62M |   40.0 |  7852 |  5.2M |  984 |      7928 | 5.09M |  886 |       950 | 110.94K |   98 | "31,41,51,61,71,81" | 0:04'56'' | 0:00'49'' |
| Q30L60X40P003  | 203.62M |   40.0 | 12056 |  5.2M |  673 |     12056 | 5.11M |  614 |      5466 |  88.34K |   59 | "31,41,51,61,71,81" | 0:05'37'' | 0:00'49'' |
| Q30L60X50P000  | 254.52M |   50.0 |  7635 | 5.22M | 1077 |      7724 | 5.06M |  943 |       964 | 163.52K |  134 | "31,41,51,61,71,81" | 0:05'22'' | 0:00'54'' |
| Q30L60X50P001  | 254.52M |   50.0 |  6837 |  5.2M | 1143 |      6999 | 5.06M |  997 |       879 | 139.42K |  146 | "31,41,51,61,71,81" | 0:05'47'' | 0:00'56'' |
| Q30L60X50P002  | 254.52M |   50.0 |  8197 | 5.21M |  961 |      8238 | 5.09M |  859 |       953 | 122.02K |  102 | "31,41,51,61,71,81" | 0:04'29'' | 0:00'58'' |
| Q30L60X60P000  | 305.43M |   60.0 |  6482 | 5.23M | 1241 |      6540 | 5.02M | 1057 |       946 | 213.05K |  184 | "31,41,51,61,71,81" | 0:06'59'' | 0:00'58'' |
| Q30L60X60P001  | 305.43M |   60.0 |  5971 | 5.21M | 1313 |      6099 | 5.05M | 1135 |       852 | 157.41K |  178 | "31,41,51,61,71,81" | 0:05'58'' | 0:00'56'' |
| Q30L60X80P000  | 407.24M |   80.0 |  5009 |  5.2M | 1557 |      5186 | 4.97M | 1275 |       803 | 228.95K |  282 | "31,41,51,61,71,81" | 0:09'32'' | 0:01'03'' |
| Q30L60X80P001  | 407.24M |   80.0 |  5681 | 5.22M | 1354 |      5831 | 5.04M | 1166 |       863 | 182.33K |  188 | "31,41,51,61,71,81" | 0:08'14'' | 0:01'09'' |
| Q30L60X120P000 | 610.86M |  120.0 |  3424 | 5.18M | 2103 |      3611 | 4.81M | 1604 |       777 | 372.15K |  499 | "31,41,51,61,71,81" | 0:13'03'' | 0:01'15'' |
| Q30L60X160P000 | 814.48M |  160.0 |  2993 | 5.16M | 2344 |      3286 | 4.71M | 1728 |       766 | 456.67K |  616 | "31,41,51,61,71,81" | 0:12'38'' | 0:01'09'' |

## MabsF: merge anchors

## MabsF: final stats

* Stats

| Name         |     N50 |     Sum |   # |
|:-------------|--------:|--------:|----:|
| Genome       | 5067172 | 5090491 |   2 |
| Paralogs     |    1580 |   83364 |  53 |
| anchor.merge |  115518 | 5170962 |  91 |
| others.merge |   11421 |  353510 | 100 |

## MabsF: clear intermediate files

# *Rhodobacter sphaeroides* 2.4.1 Full

## RsphF: download

* Settings

```bash
BASE_NAME=RsphF
REAL_G=4602977
COVERAGE2="30 40 50 60 80 120 160"
READ_QUAL="25 30"
READ_LEN="60"

```

* Reference genome

```bash
BASE_NAME=RsphF
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
BASE_NAME=RsphF
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
BASE_NAME=RsphF
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 8_competitor
cd 8_competitor

cp ~/data/anchr/Rsph/8_competitor/* .

```

* FastQC

* kmergenie

## RsphF: preprocess Illumina reads

## RsphF: reads stats

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 3188524 |    4602977 |        7 |
| Paralogs |    2337 |     147155 |       66 |
| Illumina |     251 | 4237215336 | 16881336 |
| uniq     |     251 | 4199507606 | 16731106 |
| shuffle  |     251 | 4199507606 | 16731106 |
| scythe   |     243 | 3201347568 | 16731106 |
| Q25L60   |     134 | 1357758932 | 10768930 |
| Q30L60   |     117 | 1182181310 | 10774005 |

## RsphF: quorum

| Name   | SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|------:|-------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 1.36G | 295.0 |   1.3G |  281.8 |   4.452% |     127 | "35" |  4.6M | 4.59M |     1.00 | 0:09'54'' |
| Q30L60 | 1.18G | 257.3 |  1.16G |  251.0 |   2.466% |     112 | "31" |  4.6M | 4.55M |     0.99 | 0:07'58'' |

## RsphF: down sampling

## RsphF: k-unitigs and anchors (sampled)

| Name           | SumCor  | CovCor | N50SR |   Sum |    # | N50Anchor |   Sum |   # | N50Others |     Sum |   # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|:--------|-------:|------:|------:|-----:|----------:|------:|----:|----------:|--------:|----:|--------------------:|----------:|----------:|
| Q25L60X30P000  | 138.09M |   30.0 | 15797 | 4.54M |  552 |     16481 | 4.19M | 418 |      6227 | 352.34K | 134 | "31,41,51,61,71,81" | 0:04'02'' | 0:00'57'' |
| Q25L60X30P001  | 138.09M |   30.0 | 14119 | 4.54M |  573 |     15236 | 4.19M | 440 |      6677 | 351.87K | 133 | "31,41,51,61,71,81" | 0:04'06'' | 0:00'54'' |
| Q25L60X30P002  | 138.09M |   30.0 | 14801 | 4.54M |  562 |     15384 | 4.17M | 435 |      6590 | 362.12K | 127 | "31,41,51,61,71,81" | 0:03'54'' | 0:00'54'' |
| Q25L60X30P003  | 138.09M |   30.0 | 13943 | 4.54M |  590 |     14632 |  4.2M | 453 |      5059 | 338.17K | 137 | "31,41,51,61,71,81" | 0:03'54'' | 0:00'56'' |
| Q25L60X30P004  | 138.09M |   30.0 | 14618 | 4.54M |  555 |     15404 | 4.16M | 441 |      9135 |  378.2K | 114 | "31,41,51,61,71,81" | 0:03'49'' | 0:00'55'' |
| Q25L60X30P005  | 138.09M |   30.0 | 13926 | 4.54M |  576 |     14640 | 4.19M | 450 |      7861 | 350.79K | 126 | "31,41,51,61,71,81" | 0:03'38'' | 0:00'57'' |
| Q25L60X30P006  | 138.09M |   30.0 | 14376 | 4.54M |  555 |     14819 | 4.18M | 432 |      6186 | 360.83K | 123 | "31,41,51,61,71,81" | 0:03'43'' | 0:00'57'' |
| Q25L60X30P007  | 138.09M |   30.0 | 15302 | 4.54M |  552 |     16319 | 4.17M | 428 |      7902 | 367.51K | 124 | "31,41,51,61,71,81" | 0:03'41'' | 0:00'58'' |
| Q25L60X30P008  | 138.09M |   30.0 | 15074 | 4.53M |  544 |     16324 | 4.14M | 424 |      7330 | 394.65K | 120 | "31,41,51,61,71,81" | 0:03'43'' | 0:00'56'' |
| Q25L60X40P000  | 184.12M |   40.0 | 19317 | 4.55M |  493 |     20248 |  4.2M | 359 |      5632 | 348.14K | 134 | "31,41,51,61,71,81" | 0:04'21'' | 0:01'01'' |
| Q25L60X40P001  | 184.12M |   40.0 | 19311 | 4.55M |  497 |     20582 |  4.2M | 370 |      5222 | 345.42K | 127 | "31,41,51,61,71,81" | 0:04'01'' | 0:01'00'' |
| Q25L60X40P002  | 184.12M |   40.0 | 17097 | 4.55M |  524 |     17836 | 4.22M | 384 |      4371 | 324.33K | 140 | "31,41,51,61,71,81" | 0:03'55'' | 0:01'03'' |
| Q25L60X40P003  | 184.12M |   40.0 | 17665 | 4.55M |  500 |     18723 | 4.21M | 379 |      6186 | 338.69K | 121 | "31,41,51,61,71,81" | 0:04'17'' | 0:00'58'' |
| Q25L60X40P004  | 184.12M |   40.0 | 16491 | 4.55M |  495 |     17579 | 4.21M | 380 |      7861 | 332.87K | 115 | "31,41,51,61,71,81" | 0:04'25'' | 0:00'59'' |
| Q25L60X40P005  | 184.12M |   40.0 | 17886 | 4.54M |  498 |     18496 | 4.19M | 377 |      5854 | 351.39K | 121 | "31,41,51,61,71,81" | 0:04'25'' | 0:00'55'' |
| Q25L60X40P006  | 184.12M |   40.0 | 18475 | 4.54M |  487 |     19287 | 4.23M | 373 |      5319 |  312.3K | 114 | "31,41,51,61,71,81" | 0:04'22'' | 0:00'58'' |
| Q25L60X50P000  | 230.15M |   50.0 | 19317 | 4.55M |  484 |     20257 | 4.24M | 345 |      4103 | 313.64K | 139 | "31,41,51,61,71,81" | 0:04'54'' | 0:00'58'' |
| Q25L60X50P001  | 230.15M |   50.0 | 20426 | 4.55M |  495 |     21490 | 4.24M | 362 |      4137 | 309.73K | 133 | "31,41,51,61,71,81" | 0:04'53'' | 0:00'58'' |
| Q25L60X50P002  | 230.15M |   50.0 | 18727 | 4.55M |  490 |     19976 | 4.22M | 362 |      5340 |  335.1K | 128 | "31,41,51,61,71,81" | 0:04'54'' | 0:01'03'' |
| Q25L60X50P003  | 230.15M |   50.0 | 17413 | 4.55M |  483 |     18177 | 4.25M | 365 |      7571 |  302.5K | 118 | "31,41,51,61,71,81" | 0:05'09'' | 0:01'03'' |
| Q25L60X50P004  | 230.15M |   50.0 | 19181 | 4.55M |  488 |     20240 | 4.23M | 359 |      4632 | 321.64K | 129 | "31,41,51,61,71,81" | 0:04'47'' | 0:01'03'' |
| Q25L60X60P000  | 276.18M |   60.0 | 19995 | 4.55M |  490 |     20333 | 4.23M | 342 |      3800 | 325.27K | 148 | "31,41,51,61,71,81" | 0:05'34'' | 0:01'05'' |
| Q25L60X60P001  | 276.18M |   60.0 | 19659 | 4.56M |  501 |     20583 | 4.26M | 358 |      3169 | 292.96K | 143 | "31,41,51,61,71,81" | 0:05'43'' | 0:01'05'' |
| Q25L60X60P002  | 276.18M |   60.0 | 18001 | 4.56M |  505 |     19676 | 4.25M | 367 |      4030 | 311.36K | 138 | "31,41,51,61,71,81" | 0:05'40'' | 0:01'05'' |
| Q25L60X60P003  | 276.18M |   60.0 | 19247 | 4.55M |  483 |     20583 | 4.25M | 349 |      4463 | 306.08K | 134 | "31,41,51,61,71,81" | 0:05'54'' | 0:01'05'' |
| Q25L60X80P000  | 368.24M |   80.0 | 20018 | 4.56M |  502 |     20279 | 4.34M | 348 |      1860 | 215.74K | 154 | "31,41,51,61,71,81" | 0:06'51'' | 0:01'13'' |
| Q25L60X80P001  | 368.24M |   80.0 | 16913 | 4.57M |  564 |     17882 | 4.35M | 405 |      1860 | 219.66K | 159 | "31,41,51,61,71,81" | 0:06'59'' | 0:01'09'' |
| Q25L60X80P002  | 368.24M |   80.0 | 20052 | 4.56M |  509 |     20583 | 4.33M | 376 |      2602 | 230.68K | 133 | "31,41,51,61,71,81" | 0:07'00'' | 0:01'17'' |
| Q25L60X120P000 | 552.36M |  120.0 | 15043 | 4.56M |  605 |     15723 | 4.35M | 427 |      1195 | 203.66K | 178 | "31,41,51,61,71,81" | 0:09'31'' | 0:01'24'' |
| Q25L60X120P001 | 552.36M |  120.0 | 15550 | 4.56M |  602 |     16353 | 4.33M | 435 |      1753 | 228.42K | 167 | "31,41,51,61,71,81" | 0:09'29'' | 0:01'29'' |
| Q25L60X160P000 | 736.48M |  160.0 | 14045 | 4.56M |  688 |     14541 | 4.34M | 482 |      1001 | 214.96K | 206 | "31,41,51,61,71,81" | 0:11'28'' | 0:01'42'' |
| Q30L60X30P000  | 138.09M |   30.0 |  9591 |  4.5M |  774 |      9591 | 4.12M | 630 |     10323 | 380.62K | 144 | "31,41,51,61,71,81" | 0:03'31'' | 0:00'56'' |
| Q30L60X30P001  | 138.09M |   30.0 | 10272 | 4.51M |  782 |     10357 | 4.11M | 610 |      8202 | 400.09K | 172 | "31,41,51,61,71,81" | 0:03'38'' | 0:00'56'' |
| Q30L60X30P002  | 138.09M |   30.0 |  9448 | 4.51M |  796 |      9492 | 4.11M | 642 |      8199 | 408.11K | 154 | "31,41,51,61,71,81" | 0:03'16'' | 0:00'51'' |
| Q30L60X30P003  | 138.09M |   30.0 |  9464 | 4.51M |  801 |      9517 |  4.1M | 638 |      9100 | 406.59K | 163 | "31,41,51,61,71,81" | 0:03'32'' | 0:00'55'' |
| Q30L60X30P004  | 138.09M |   30.0 |  9550 | 4.51M |  769 |      9729 |  4.1M | 606 |      8202 | 403.91K | 163 | "31,41,51,61,71,81" | 0:03'27'' | 0:00'55'' |
| Q30L60X30P005  | 138.09M |   30.0 |  9323 | 4.51M |  794 |      9226 |  4.1M | 635 |      9706 |    407K | 159 | "31,41,51,61,71,81" | 0:03'26'' | 0:00'55'' |
| Q30L60X30P006  | 138.09M |   30.0 | 11704 | 4.53M |  674 |     11631 | 4.09M | 540 |     12285 | 440.73K | 134 | "31,41,51,61,71,81" | 0:03'29'' | 0:00'53'' |
| Q30L60X30P007  | 138.09M |   30.0 |  6701 | 4.51M | 1038 |      6748 | 4.24M | 849 |      2444 | 276.07K | 189 | "31,41,51,61,71,81" | 0:03'09'' | 0:00'51'' |
| Q30L60X40P000  | 184.12M |   40.0 | 12551 | 4.52M |  636 |     12635 | 4.15M | 510 |     11818 | 373.92K | 126 | "31,41,51,61,71,81" | 0:04'01'' | 0:01'01'' |
| Q30L60X40P001  | 184.12M |   40.0 | 12368 | 4.53M |  666 |     12486 | 4.14M | 536 |     10905 | 385.62K | 130 | "31,41,51,61,71,81" | 0:04'04'' | 0:01'00'' |
| Q30L60X40P002  | 184.12M |   40.0 | 11387 | 4.52M |  676 |     11567 | 4.14M | 540 |      9406 |  388.5K | 136 | "31,41,51,61,71,81" | 0:04'04'' | 0:00'56'' |
| Q30L60X40P003  | 184.12M |   40.0 | 12535 | 4.52M |  641 |     12623 | 4.14M | 514 |     11818 | 385.52K | 127 | "31,41,51,61,71,81" | 0:03'57'' | 0:00'57'' |
| Q30L60X40P004  | 184.12M |   40.0 | 12550 | 4.52M |  632 |     12550 | 4.13M | 511 |     12569 | 385.77K | 121 | "31,41,51,61,71,81" | 0:04'13'' | 0:00'58'' |
| Q30L60X40P005  | 184.12M |   40.0 | 10736 | 4.55M |  713 |     10763 | 4.21M | 583 |      8441 | 338.43K | 130 | "31,41,51,61,71,81" | 0:04'32'' | 0:01'03'' |
| Q30L60X50P000  | 230.15M |   50.0 | 15333 | 4.53M |  557 |     15600 | 4.15M | 443 |     12569 |  381.6K | 114 | "31,41,51,61,71,81" | 0:04'49'' | 0:01'03'' |
| Q30L60X50P001  | 230.15M |   50.0 | 13945 | 4.53M |  587 |     14188 | 4.17M | 474 |     10905 | 361.52K | 113 | "31,41,51,61,71,81" | 0:04'37'' | 0:01'03'' |
| Q30L60X50P002  | 230.15M |   50.0 | 14521 | 4.53M |  563 |     14812 | 4.16M | 449 |     10343 | 372.36K | 114 | "31,41,51,61,71,81" | 0:04'45'' | 0:01'01'' |
| Q30L60X50P003  | 230.15M |   50.0 | 14383 | 4.53M |  567 |     14479 | 4.15M | 455 |     12569 | 379.63K | 112 | "31,41,51,61,71,81" | 0:04'41'' | 0:01'01'' |
| Q30L60X50P004  | 230.15M |   50.0 | 12621 | 4.54M |  616 |     13137 | 4.23M | 504 |     10913 |  313.4K | 112 | "31,41,51,61,71,81" | 0:04'34'' | 0:01'05'' |
| Q30L60X60P000  | 276.18M |   60.0 | 17511 | 4.53M |  506 |     17858 | 4.16M | 402 |     12569 | 376.45K | 104 | "31,41,51,61,71,81" | 0:05'26'' | 0:01'08'' |
| Q30L60X60P001  | 276.18M |   60.0 | 14759 | 4.54M |  540 |     15502 | 4.16M | 433 |     11818 | 374.28K | 107 | "31,41,51,61,71,81" | 0:05'25'' | 0:01'10'' |
| Q30L60X60P002  | 276.18M |   60.0 | 15376 | 4.54M |  532 |     15577 | 4.16M | 424 |     12285 | 375.42K | 108 | "31,41,51,61,71,81" | 0:05'08'' | 0:01'09'' |
| Q30L60X60P003  | 276.18M |   60.0 | 17627 | 4.54M |  477 |     17627 | 4.07M | 375 |     15263 | 469.36K | 102 | "31,41,51,61,71,81" | 0:05'31'' | 0:01'04'' |
| Q30L60X80P000  | 368.24M |   80.0 | 18863 | 4.54M |  454 |     18972 | 4.17M | 360 |     12569 | 369.15K |  94 | "31,41,51,61,71,81" | 0:06'10'' | 0:01'16'' |
| Q30L60X80P001  | 368.24M |   80.0 | 18347 | 4.54M |  483 |     18492 | 4.17M | 381 |     12569 | 371.71K | 102 | "31,41,51,61,71,81" | 0:06'37'' | 0:01'18'' |
| Q30L60X80P002  | 368.24M |   80.0 | 20252 | 4.55M |  436 |     20515 | 4.06M | 335 |     13379 | 483.71K | 101 | "31,41,51,61,71,81" | 0:06'26'' | 0:01'15'' |
| Q30L60X120P000 | 552.36M |  120.0 | 21312 | 4.55M |  405 |     21408 | 4.18M | 319 |     13133 | 363.83K |  86 | "31,41,51,61,71,81" | 0:08'38'' | 0:01'36'' |
| Q30L60X120P001 | 552.36M |  120.0 | 22607 | 4.55M |  385 |     23176 | 4.14M | 297 |     13388 | 411.32K |  88 | "31,41,51,61,71,81" | 0:08'49'' | 0:01'38'' |
| Q30L60X160P000 | 736.48M |  160.0 | 23176 | 4.55M |  374 |     23824 | 4.19M | 290 |     13345 | 362.97K |  84 | "31,41,51,61,71,81" | 0:07'35'' | 0:01'33'' |

## RsphF: merge anchors

## RsphF: final stats

* Stats

| Name         |     N50 |     Sum |   # |
|:-------------|--------:|--------:|----:|
| Genome       | 3188524 | 4602977 |   7 |
| Paralogs     |    2337 |  147155 |  66 |
| anchor.merge |   45265 | 4419978 | 193 |
| others.merge |   13391 |  516209 |  92 |

## RsphF: clear intermediate files

# *Vibrio cholerae* CP1032(5) Full

## VchoF: download

* Settings

```bash
BASE_NAME=VchoF
REAL_G=4033464
COVERAGE2="30 40 50 60 80 120 160"
READ_QUAL="25 30"
READ_LEN="60"

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

* FastQC

* kmergenie

## VchoF: preprocess Illumina reads

## VchoF: reads stats

| Name     |     N50 |        Sum |       # |
|:---------|--------:|-----------:|--------:|
| Genome   | 2961149 |    4033464 |       2 |
| Paralogs |    3483 |     114707 |      48 |
| Illumina |     251 | 1762158050 | 7020550 |
| uniq     |     251 | 1727781592 | 6883592 |
| shuffle  |     251 | 1727781592 | 6883592 |
| scythe   |     198 | 1312851134 | 6883592 |
| Q25L60   |     188 | 1099728002 | 6131160 |
| Q30L60   |     181 |  997782199 | 5858946 |

## VchoF: quorum

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q25L60 |    1.1G | 272.7 | 939.43M |  232.9 |  14.576% |     178 | "109" | 4.03M | 4.37M |     1.08 | 0:06'16'' |
| Q30L60 | 998.18M | 247.5 | 882.57M |  218.8 |  11.582% |     172 | "105" | 4.03M | 4.16M |     1.03 | 0:05'00'' |

## VchoF: down sampling

## VchoF: k-unitigs and anchors (sampled)

| Name           |  SumCor | CovCor | N50SR |   Sum |    # | N50Anchor |   Sum |    # | N50Others |     Sum |    # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|--------:|-------:|------:|------:|-----:|----------:|------:|-----:|----------:|--------:|-----:|--------------------:|----------:|:----------|
| Q25L60X30P000  |    121M |   30.0 |  3496 | 3.94M | 1574 |      3812 | 3.61M | 1153 |       797 | 321.14K |  421 | "31,41,51,61,71,81" | 0:04'27'' | 0:00'30'' |
| Q25L60X30P001  |    121M |   30.0 |  3325 | 3.93M | 1656 |      3575 |  3.6M | 1222 |       779 | 324.35K |  434 | "31,41,51,61,71,81" | 0:04'25'' | 0:00'29'' |
| Q25L60X30P002  |    121M |   30.0 |  3409 | 3.92M | 1574 |      3732 | 3.62M | 1167 |       790 | 306.19K |  407 | "31,41,51,61,71,81" | 0:03'08'' | 0:00'29'' |
| Q25L60X30P003  |    121M |   30.0 |  3471 | 3.91M | 1578 |      3675 | 3.61M | 1165 |       779 |  307.9K |  413 | "31,41,51,61,71,81" | 0:03'46'' | 0:00'30'' |
| Q25L60X30P004  |    121M |   30.0 |  3367 | 3.93M | 1640 |      3616 |  3.6M | 1193 |       776 | 328.81K |  447 | "31,41,51,61,71,81" | 0:02'49'' | 0:00'29'' |
| Q25L60X30P005  |    121M |   30.0 |  3391 | 3.93M | 1612 |      3712 | 3.62M | 1200 |       806 | 312.16K |  412 | "31,41,51,61,71,81" | 0:03'23'' | 0:00'29'' |
| Q25L60X30P006  |    121M |   30.0 |  3359 | 3.94M | 1642 |      3664 | 3.61M | 1212 |       791 | 325.04K |  430 | "31,41,51,61,71,81" | 0:03'29'' | 0:00'29'' |
| Q25L60X40P000  | 161.34M |   40.0 |  2904 | 3.92M | 1871 |      3196 | 3.48M | 1291 |       792 | 435.05K |  580 | "31,41,51,61,71,81" | 0:03'37'' | 0:00'30'' |
| Q25L60X40P001  | 161.34M |   40.0 |  2667 | 3.92M | 1914 |      2992 | 3.48M | 1332 |       783 | 434.67K |  582 | "31,41,51,61,71,81" | 0:04'12'' | 0:00'30'' |
| Q25L60X40P002  | 161.34M |   40.0 |  2803 |  3.9M | 1848 |      3029 |  3.5M | 1304 |       772 | 405.43K |  544 | "31,41,51,61,71,81" | 0:04'19'' | 0:00'31'' |
| Q25L60X40P003  | 161.34M |   40.0 |  2735 | 3.92M | 1928 |      3051 | 3.47M | 1333 |       784 | 440.76K |  595 | "31,41,51,61,71,81" | 0:03'54'' | 0:00'30'' |
| Q25L60X40P004  | 161.34M |   40.0 |  2744 | 3.92M | 1898 |      2985 |  3.5M | 1342 |       788 | 416.94K |  556 | "31,41,51,61,71,81" | 0:04'08'' | 0:00'31'' |
| Q25L60X50P000  | 201.67M |   50.0 |  2403 |  3.9M | 2126 |      2775 | 3.36M | 1397 |       779 | 541.39K |  729 | "31,41,51,61,71,81" | 0:04'29'' | 0:00'31'' |
| Q25L60X50P001  | 201.67M |   50.0 |  2384 | 3.89M | 2127 |      2679 | 3.35M | 1392 |       768 |  540.7K |  735 | "31,41,51,61,71,81" | 0:04'59'' | 0:00'32'' |
| Q25L60X50P002  | 201.67M |   50.0 |  2353 | 3.88M | 2120 |      2664 | 3.35M | 1407 |       767 | 524.41K |  713 | "31,41,51,61,71,81" | 0:03'51'' | 0:00'31'' |
| Q25L60X50P003  | 201.67M |   50.0 |  2301 | 3.89M | 2152 |      2618 | 3.37M | 1449 |       788 | 523.24K |  703 | "31,41,51,61,71,81" | 0:04'53'' | 0:00'33'' |
| Q25L60X60P000  | 242.01M |   60.0 |  2063 | 3.86M | 2368 |      2405 | 3.18M | 1446 |       778 | 682.63K |  922 | "31,41,51,61,71,81" | 0:05'28'' | 0:00'33'' |
| Q25L60X60P001  | 242.01M |   60.0 |  2092 | 3.84M | 2305 |      2419 | 3.21M | 1445 |       770 | 632.08K |  860 | "31,41,51,61,71,81" | 0:05'54'' | 0:00'33'' |
| Q25L60X60P002  | 242.01M |   60.0 |  2089 | 3.86M | 2380 |      2427 | 3.19M | 1471 |       771 | 664.44K |  909 | "31,41,51,61,71,81" | 0:04'09'' | 0:00'32'' |
| Q25L60X80P000  | 322.68M |   80.0 |  1678 | 3.76M | 2674 |      2084 | 2.88M | 1466 |       771 | 885.68K | 1208 | "31,41,51,61,71,81" | 0:07'10'' | 0:00'33'' |
| Q25L60X80P001  | 322.68M |   80.0 |  1674 | 3.75M | 2657 |      2080 | 2.91M | 1500 |       756 | 843.39K | 1157 | "31,41,51,61,71,81" | 0:04'59'' | 0:00'33'' |
| Q25L60X120P000 | 484.02M |  120.0 |  1334 | 3.57M | 3031 |      1748 | 2.38M | 1379 |       755 |   1.19M | 1652 | "31,41,51,61,71,81" | 0:07'18'' | 0:00'35'' |
| Q25L60X160P000 | 645.35M |  160.0 |  1158 |  3.4M | 3209 |      1599 |    2M | 1248 |       729 |   1.39M | 1961 | "31,41,51,61,71,81" | 0:13'04'' | 0:00'36'' |
| Q30L60X30P000  |    121M |   30.0 |  8864 | 3.93M |  771 |      9084 | 3.81M |  619 |       825 | 121.55K |  152 | "31,41,51,61,71,81" | 0:04'33'' | 0:00'30'' |
| Q30L60X30P001  |    121M |   30.0 |  7426 | 3.94M |  859 |      7647 | 3.82M |  698 |       795 | 123.76K |  161 | "31,41,51,61,71,81" | 0:03'11'' | 0:00'29'' |
| Q30L60X30P002  |    121M |   30.0 |  8258 | 3.94M |  788 |      8710 | 3.81M |  629 |       806 | 130.78K |  159 | "31,41,51,61,71,81" | 0:02'33'' | 0:00'29'' |
| Q30L60X30P003  |    121M |   30.0 |  7695 | 3.94M |  834 |      7892 | 3.83M |  692 |       813 |  110.6K |  142 | "31,41,51,61,71,81" | 0:02'51'' | 0:00'28'' |
| Q30L60X30P004  |    121M |   30.0 |  7967 | 3.94M |  818 |      8275 | 3.81M |  653 |       776 | 125.12K |  165 | "31,41,51,61,71,81" | 0:02'10'' | 0:00'28'' |
| Q30L60X30P005  |    121M |   30.0 |  8247 | 3.94M |  809 |      8454 | 3.82M |  661 |       825 | 119.33K |  148 | "31,41,51,61,71,81" | 0:02'32'' | 0:00'30'' |
| Q30L60X30P006  |    121M |   30.0 |  8135 | 3.94M |  812 |      8489 | 3.82M |  655 |       794 | 121.94K |  157 | "31,41,51,61,71,81" | 0:02'33'' | 0:00'29'' |
| Q30L60X40P000  | 161.34M |   40.0 |  7090 | 3.95M |  925 |      7327 | 3.81M |  753 |       801 | 133.87K |  172 | "31,41,51,61,71,81" | 0:02'44'' | 0:00'30'' |
| Q30L60X40P001  | 161.34M |   40.0 |  6468 | 3.95M |  963 |      6719 | 3.81M |  781 |       791 | 138.51K |  182 | "31,41,51,61,71,81" | 0:02'55'' | 0:00'30'' |
| Q30L60X40P002  | 161.34M |   40.0 |  6976 | 3.96M |  951 |      7076 | 3.78M |  761 |       855 | 176.51K |  190 | "31,41,51,61,71,81" | 0:02'58'' | 0:00'30'' |
| Q30L60X40P003  | 161.34M |   40.0 |  6669 | 3.95M |  956 |      6840 |  3.8M |  760 |       794 | 149.34K |  196 | "31,41,51,61,71,81" | 0:02'55'' | 0:00'32'' |
| Q30L60X40P004  | 161.34M |   40.0 |  6771 | 3.95M |  948 |      6906 | 3.81M |  772 |       796 | 134.29K |  176 | "31,41,51,61,71,81" | 0:02'34'' | 0:00'30'' |
| Q30L60X50P000  | 201.67M |   50.0 |  5778 | 3.95M | 1079 |      6066 | 3.78M |  853 |       801 | 175.94K |  226 | "31,41,51,61,71,81" | 0:02'27'' | 0:00'32'' |
| Q30L60X50P001  | 201.67M |   50.0 |  5742 | 3.95M | 1086 |      5980 | 3.77M |  850 |       772 |  178.7K |  236 | "31,41,51,61,71,81" | 0:02'16'' | 0:00'32'' |
| Q30L60X50P002  | 201.67M |   50.0 |  5674 | 3.95M | 1080 |      5982 | 3.79M |  860 |       767 | 165.07K |  220 | "31,41,51,61,71,81" | 0:02'08'' | 0:00'32'' |
| Q30L60X50P003  | 201.67M |   50.0 |  5712 | 3.95M | 1068 |      5854 | 3.79M |  862 |       801 | 155.78K |  206 | "31,41,51,61,71,81" | 0:02'09'' | 0:00'31'' |
| Q30L60X60P000  | 242.01M |   60.0 |  4912 | 3.96M | 1232 |      5215 | 3.74M |  953 |       795 | 214.94K |  279 | "31,41,51,61,71,81" | 0:02'23'' | 0:00'33'' |
| Q30L60X60P001  | 242.01M |   60.0 |  4974 | 3.94M | 1210 |      5312 | 3.74M |  936 |       801 | 209.34K |  274 | "31,41,51,61,71,81" | 0:02'36'' | 0:00'34'' |
| Q30L60X60P002  | 242.01M |   60.0 |  5038 | 3.95M | 1202 |      5190 | 3.75M |  937 |       801 | 201.46K |  265 | "31,41,51,61,71,81" | 0:02'30'' | 0:00'33'' |
| Q30L60X80P000  | 322.68M |   80.0 |  3923 | 3.95M | 1466 |      4219 | 3.67M | 1101 |       795 | 277.99K |  365 | "31,41,51,61,71,81" | 0:03'02'' | 0:00'34'' |
| Q30L60X80P001  | 322.68M |   80.0 |  3920 | 3.95M | 1462 |      4160 | 3.67M | 1095 |       769 | 273.67K |  367 | "31,41,51,61,71,81" | 0:03'01'' | 0:00'34'' |
| Q30L60X120P000 | 484.02M |  120.0 |  2886 | 3.92M | 1874 |      3173 | 3.48M | 1277 |       774 | 443.32K |  597 | "31,41,51,61,71,81" | 0:04'19'' | 0:00'36'' |
| Q30L60X160P000 | 645.35M |  160.0 |  2349 | 3.88M | 2171 |      2661 |  3.3M | 1391 |       764 | 573.31K |  780 | "31,41,51,61,71,81" | 0:04'26'' | 0:00'35'' |

## VchoF: merge anchors

## VchoF: final stats

* Stats

| Name         |     N50 |     Sum |   # |
|:-------------|--------:|--------:|----:|
| Genome       | 2961149 | 4033464 |   2 |
| Paralogs     |    3483 |  114707 |  48 |
| anchor.merge |   98382 | 3911716 | 101 |
| others.merge |    1023 |  283179 | 236 |

## VchoF: clear intermediate files

