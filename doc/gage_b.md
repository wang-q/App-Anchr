# Assemble four genomes from GAGE-B data sets by ANCHR

[TOC levels=1-3]: # " "
- [Assemble four genomes from GAGE-B data sets by ANCHR](#assemble-four-genomes-from-gage-b-data-sets-by-anchr)
- [*Bacillus cereus* ATCC 10987](#bacillus-cereus-atcc-10987)
    - [Bcer: download](#bcer-download)
    - [Bcer: run](#bcer-run)
- [*Rhodobacter sphaeroides* 2.4.1](#rhodobacter-sphaeroides-241)
    - [Rsph: download](#rsph-download)
    - [Rsph: run](#rsph-run)
- [*Mycobacterium abscessus* 6G-0125-R](#mycobacterium-abscessus-6g-0125-r)
    - [Mabs: download](#mabs-download)
    - [Mabs: run](#mabs-run)
- [*Vibrio cholerae* CP1032(5)](#vibrio-cholerae-cp10325)
    - [Vcho: download](#vcho-download)
    - [Vcho: run](#vcho-run)
- [*Rhodobacter sphaeroides* 2.4.1 Full](#rhodobacter-sphaeroides-241-full)
    - [RsphF: download](#rsphf-download)
    - [RsphF: run](#rsphf-run)
- [*Mycobacterium abscessus* 6G-0125-R Full](#mycobacterium-abscessus-6g-0125-r-full)
    - [MabsF: download](#mabsf-download)
    - [MabsF: run](#mabsf-run)
- [*Vibrio cholerae* CP1032(5) Full](#vibrio-cholerae-cp10325-full)
    - [VchoF: download](#vchof-download)
    - [VchoF: run](#vchof-run)


* Rsync to hpcc

```bash
for D in Bcer Rsph Mabs Vcho RsphF MabsF VchoF; do
    rsync -avP \
        --exclude="*_hdf5.tgz" \
        ~/data/anchr/${D}/ \
        wangq@202.119.37.251:data/anchr/${D}
done

# rsync -avP wangq@202.119.37.251:data/anchr/ ~/data/anchr

```

# *Bacillus cereus* ATCC 10987

## Bcer: download

* Reference genome

    * Strain: Bacillus cereus ATCC 10987
    * Taxid: [222523](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=222523)
    * RefSeq assembly accession:
      [GCF_000008005.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/005/GCF_000008005.1_ASM800v1/GCF_000008005.1_ASM800v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0797

```bash
mkdir -p ${HOME}/data/anchr/Bcer
cd ${HOME}/data/anchr/Bcer

mkdir -p 1_genome
cd 1_genome

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
cd ${HOME}/data/anchr/Bcer

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
cd ${HOME}/data/anchr/Bcer

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

## Bcer: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Bcer

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 5432652 \
    --trim2 "--uniq --shuffle --bbduk" \
    --cov2 "40 50 60 all" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,2,3" \
    --parallel 24

# run
bsub -q mpi -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

# quast
rm -fr 9_quast_competitor
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
    -o 9_quast_competitor

# bash 0_cleanup.sh

```

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 5224283 | 5432652 |       2 |
| Paralogs |    2295 |  223889 |     103 |
| Illumina |     251 | 481.02M | 2080000 |
| uniq     |     251 | 480.99M | 2079856 |
| shuffle  |     251 | 480.99M | 2079856 |
| bbduk    |     250 | 476.24M | 2069782 |
| Q20L60   |     250 | 411.77M | 1819870 |
| Q25L60   |     250 | 380.22M | 1713406 |
| Q30L60   |     250 | 370.48M | 1750227 |

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q20L60 | 549.4 |    561 | 153.2 |         32.76% |
| Q25L60 | 554.5 |    565 | 152.6 |         37.69% |
| Q30L60 | 552.1 |    563 | 150.9 |         41.36% |

| Name         | N50 |     Sum |       # |
|:-------------|----:|--------:|--------:|
| clumped      | 251 | 480.97M | 2079706 |
| trimmed      | 250 | 418.04M | 1875014 |
| filtered     | 250 | 417.87M | 1874300 |
| ecco         | 250 | 417.87M | 1874300 |
| eccc         | 250 | 417.87M | 1874300 |
| ecct         | 250 |  413.4M | 1850282 |
| extended     | 290 | 486.45M | 1850282 |
| merged       | 585 |  325.4M |  600407 |
| unmerged.raw | 285 | 156.62M |  649468 |
| unmerged     | 255 | 124.52M |  592564 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 361.9 |    387 |  97.4 |         19.20% |
| ihist.merge.txt  | 542.0 |    564 | 119.8 |         64.90% |

```text
#mergeReads
#Matched	413	0.02203%
#Name	Reads	ReadsPct
contam_250	311	0.01659%
```

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q20L60 |  75.8 |   64.8 |   14.46% |     226 | "127" | 5.43M | 5.35M |     0.99 | 0:00'46'' |
| Q25L60 |  70.0 |   63.3 |    9.59% |     222 | "127" | 5.43M | 5.34M |     0.98 | 0:00'42'' |
| Q30L60 |  68.2 |   64.1 |    6.05% |     215 | "127" | 5.43M | 5.34M |     0.98 | 0:00'42'' |

```text
#Q20L60
#Matched	0	0.00000%
#Name	Reads	ReadsPct

#Q25L60
#Matched	0	0.00000%
#Name	Reads	ReadsPct

#Q30L60
#Matched	0	0.00000%
#Name	Reads	ReadsPct

```

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|-------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000  |   40.0 |  97.36% |     22122 | 5.28M | 381 |        82 | 61.16K | 1033 |   38.0 | 4.5 |   8.2 |  76.0 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'58'' |
| Q20L60X50P000  |   50.0 |  97.32% |     22098 | 5.28M | 388 |        81 |    64K | 1060 |   48.0 | 5.0 |  11.0 |  94.5 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'56'' |
| Q20L60X60P000  |   60.0 |  97.25% |     22099 | 5.28M | 393 |        74 |  58.7K | 1064 |   57.0 | 7.0 |  12.0 | 114.0 | "31,41,51,61,71,81" | 0:01'35'' | 0:00'56'' |
| Q20L60XallP000 |   64.8 |  97.21% |     22094 | 5.27M | 394 |        81 | 64.74K | 1076 |   62.0 | 7.0 |  13.7 | 124.0 | "31,41,51,61,71,81" | 0:01'41'' | 0:00'58'' |
| Q25L60X40P000  |   40.0 |  97.91% |     35048 |  5.3M | 261 |        77 | 44.68K |  829 |   39.0 | 5.0 |   8.0 |  78.0 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'59'' |
| Q25L60X50P000  |   50.0 |  97.91% |     34816 |  5.3M | 256 |        80 | 46.64K |  820 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:01'25'' | 0:00'58'' |
| Q25L60X60P000  |   60.0 |  97.91% |     34490 |  5.3M | 256 |        78 | 46.23K |  813 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:01'35'' | 0:01'00'' |
| Q25L60XallP000 |   63.3 |  97.94% |     34474 |  5.3M | 254 |        82 | 48.83K |  824 |   61.0 | 7.0 |  13.3 | 122.0 | "31,41,51,61,71,81" | 0:01'40'' | 0:01'01'' |
| Q30L60X40P000  |   40.0 |  98.38% |     42728 |  5.3M | 241 |        89 | 48.37K |  814 |   38.5 | 4.5 |   8.3 |  77.0 | "31,41,51,61,71,81" | 0:01'13'' | 0:01'00'' |
| Q30L60X50P000  |   50.0 |  98.18% |     42856 |  5.3M | 237 |        77 | 44.33K |  804 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:01'23'' | 0:00'58'' |
| Q30L60X60P000  |   60.0 |  98.15% |     41788 |  5.3M | 229 |        77 | 46.46K |  817 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:01'35'' | 0:01'02'' |
| Q30L60XallP000 |   64.1 |  98.09% |     41788 |  5.3M | 224 |        76 |    47K |  812 |   62.0 | 7.0 |  13.7 | 124.0 | "31,41,51,61,71,81" | 0:01'40'' | 0:01'02'' |

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|-------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000  |   40.0 |  97.96% |     27947 | 5.29M | 296 |        88 |  53.7K |  891 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'58'' |
| Q20L60X50P000  |   50.0 |  97.90% |     27086 | 5.29M | 309 |        76 | 53.44K |  942 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'58'' |
| Q20L60X60P000  |   60.0 |  97.83% |     26520 | 5.29M | 333 |        77 | 57.11K |  990 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'57'' |
| Q20L60XallP000 |   64.8 |  97.76% |     24492 | 5.29M | 348 |        81 | 61.31K | 1019 |   62.0 | 7.0 |  13.7 | 124.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'59'' |
| Q25L60X40P000  |   40.0 |  98.54% |     34514 |  5.3M | 265 |        82 | 46.67K |  823 |   39.0 | 5.0 |   8.0 |  78.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'58'' |
| Q25L60X50P000  |   50.0 |  98.54% |     35363 |  5.3M | 255 |        85 | 49.42K |  831 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:01'00'' |
| Q25L60X60P000  |   60.0 |  98.55% |     38832 | 5.31M | 252 |        87 | 51.18K |  830 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:01'01'' |
| Q25L60XallP000 |   63.3 |  98.54% |     39501 |  5.3M | 253 |        94 | 54.03K |  830 |   61.0 | 7.0 |  13.3 | 122.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'58'' |
| Q30L60X40P000  |   40.0 |  98.69% |     32711 | 5.29M | 269 |        88 | 52.41K |  862 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'58'' |
| Q30L60X50P000  |   50.0 |  98.69% |     37011 |  5.3M | 250 |        76 | 46.33K |  832 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:01'00'' |
| Q30L60X60P000  |   60.0 |  98.69% |     39501 |  5.3M | 240 |        78 | 48.43K |  830 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:01'01'' |
| Q30L60XallP000 |   64.1 |  98.63% |     37668 |  5.3M | 238 |        76 |  47.5K |  819 |   62.0 | 7.0 |  13.7 | 124.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:01'00'' |

| Name                           |     N50 |     Sum |   # |
|:-------------------------------|--------:|--------:|----:|
| Genome                         | 5224283 | 5432652 |   2 |
| Paralogs                       |    2295 |  223889 | 103 |
| 6_mergeKunitigsAnchors.anchors |   46128 | 5311206 | 208 |
| 6_mergeKunitigsAnchors.others  |    1110 |   29935 |  28 |
| 6_mergeTadpoleAnchors.anchors  |   46698 | 5313267 | 200 |
| 6_mergeTadpoleAnchors.others   |    1093 |   34977 |  33 |
| 6_mergeAnchors.anchors         |   46698 | 5313267 | 200 |
| 6_mergeAnchors.others          |    1093 |   34977 |  33 |
| tadpole.Q20L60                 |   11462 | 5322724 | 949 |
| tadpole.Q25L60                 |   16956 | 5318749 | 755 |
| tadpole.Q30L60                 |   18156 | 5318705 | 727 |
| spades.contig                  |  207648 | 5370433 | 168 |
| spades.scaffold                |  284294 | 5370573 | 154 |
| spades.non-contained           |  207648 | 5350580 |  59 |
| platanus.contig                |   18759 | 5417970 | 652 |
| platanus.scaffold              |  485201 | 5351371 | 248 |
| platanus.non-contained         |  485201 | 5304311 |  38 |


# *Rhodobacter sphaeroides* 2.4.1

## Rsph: download

* Reference genome

    * Strain: Rhodobacter sphaeroides 2.4.1
    * Taxid: [272943](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=272943)
    * RefSeq assembly accession:
      [GCF_000012905.2](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/745/GCF_000006745.1_ASM674v1/GCF_000006745.1_ASM674v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0286

```bash
mkdir -p ${HOME}/data/anchr/Rsph
cd ${HOME}/data/anchr/Rsph

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
mkdir -p ${HOME}/data/anchr/Rsph

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
mkdir -p ${HOME}/data/anchr/Rsph

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

## Rsph: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Rsph

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 4602977 \
    --trim2 "--uniq --shuffle --bbduk" \
    --cov2 "30 all" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,3" \
    --parallel 24

# run
bsub -q mpi -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

# quast
rm -fr 9_quast_competitor
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
    -o 9_quast_competitor

# bash 0_cleanup.sh

```

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 3188524 | 4602977 |       7 |
| Paralogs |    2337 |  147155 |      66 |
| Illumina |     251 |  451.8M | 1800000 |
| uniq     |     251 |  447.9M | 1784446 |
| shuffle  |     251 |  447.9M | 1784446 |
| bbduk    |     250 | 415.69M | 1704576 |
| Q20L60   |     144 | 173.66M | 1285528 |
| Q25L60   |     133 |  144.6M | 1153408 |
| Q30L60   |     116 | 125.79M | 1150580 |

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q20L60 | 387.9 |    419 | 102.9 |         37.53% |
| Q25L60 | 389.1 |    419 |  98.7 |         42.10% |
| Q30L60 | 387.4 |    419 |  91.4 |         41.15% |

| Name         | N50 |     Sum |       # |
|:-------------|----:|--------:|--------:|
| clumped      | 251 | 447.19M | 1781618 |
| trimmed      | 148 |  200.1M | 1452703 |
| filtered     | 148 |  200.1M | 1452699 |
| ecco         | 148 |    200M | 1452698 |
| ecct         | 148 | 198.77M | 1443497 |
| extended     | 186 | 255.85M | 1443497 |
| merged       | 456 | 170.89M |  405820 |
| unmerged.raw | 175 | 104.98M |  631856 |
| unmerged     | 158 |  86.04M |  590349 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 197.9 |    197 |  63.5 |          6.91% |
| ihist.merge.txt  | 421.1 |    453 |  80.9 |         56.23% |

```text
#mergeReads
#Matched	4	0.00028%
#Name	Reads	ReadsPct
```

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q20L60 |  37.7 |   33.7 |   10.65% |     136 | "37" |  4.6M | 4.55M |     0.99 | 0:00'24'' |
| Q25L60 |  31.4 |   30.0 |    4.43% |     126 | "33" |  4.6M | 4.53M |     0.98 | 0:00'21'' |
| Q30L60 |  27.4 |   26.7 |    2.40% |     111 | "31" |  4.6M | 4.52M |     0.98 | 0:00'19'' |

```text
#Q20L60
#Matched	0	0.00000%
#Name	Reads	ReadsPct

#Q25L60
#Matched	0	0.00000%
#Name	Reads	ReadsPct

#Q30L60
#Matched	0	0.00000%
#Name	Reads	ReadsPct

```

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X30P000  |   30.0 |  97.88% |     22125 | 4.05M | 332 |      5435 | 647.52K | 1311 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'55'' |
| Q20L60XallP000 |   33.7 |  97.84% |     22587 | 4.05M | 310 |      7043 | 647.19K | 1251 |   29.0 | 2.0 |   7.7 |  52.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'54'' |
| Q25L60X30P000  |   30.0 |  98.30% |     16236 |    4M | 429 |      8835 | 759.77K | 1392 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'52'' |
| Q25L60XallP000 |   30.0 |  98.29% |     16279 |    4M | 428 |      8835 | 759.73K | 1391 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'52'' |
| Q30L60XallP000 |   26.7 |  98.02% |      9521 | 3.96M | 606 |      7245 | 830.37K | 1764 |   23.0 | 2.0 |   5.7 |  43.5 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'50'' |

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X30P000  |   30.0 |  98.29% |     14955 | 4.03M | 468 |      8046 |  797.7K | 1640 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'53'' |
| Q20L60XallP000 |   33.7 |  98.41% |     16866 | 4.02M | 418 |      7526 | 788.58K | 1567 |   29.0 | 2.0 |   7.7 |  52.5 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'55'' |
| Q25L60X30P000  |   30.0 |  97.88% |      9768 | 3.94M | 633 |      6632 | 818.91K | 1833 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'50'' |
| Q25L60XallP000 |   30.0 |  97.87% |      9776 | 3.94M | 633 |      6632 | 819.06K | 1836 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'50'' |
| Q30L60XallP000 |   26.7 |  96.89% |      6439 | 3.85M | 852 |      5804 | 854.41K | 2296 |   23.0 | 2.0 |   5.7 |  43.5 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'49'' |

| Name                           |     N50 |     Sum |    # |
|:-------------------------------|--------:|--------:|-----:|
| Genome                         | 3188524 | 4602977 |    7 |
| Paralogs                       |    2337 |  147155 |   66 |
| 6_mergeKunitigsAnchors.anchors |   29426 | 4082400 |  264 |
| 6_mergeKunitigsAnchors.others  |   12265 |  946155 |  212 |
| 6_mergeTadpoleAnchors.anchors  |   30353 | 4094404 |  263 |
| 6_mergeTadpoleAnchors.others   |   11818 | 1020180 |  263 |
| 6_mergeAnchors.anchors         |   30353 | 4094404 |  263 |
| 6_mergeAnchors.others          |   11818 | 1020180 |  263 |
| tadpole.Q20L60                 |    9813 | 4520272 | 1076 |
| tadpole.Q25L60                 |    7912 | 4515562 | 1304 |
| tadpole.Q30L60                 |    3644 | 4500715 | 2517 |
| spades.contig                  |   86457 | 4571770 |  159 |
| spades.scaffold                |  130378 | 4572405 |  136 |
| spades.non-contained           |   88009 | 4556507 |  104 |
| platanus.contig                |    4863 | 4603873 | 3435 |
| platanus.scaffold              |   37803 | 4533935 |  888 |
| platanus.non-contained         |   38632 | 4403868 |  229 |


# *Mycobacterium abscessus* 6G-0125-R

## Mabs: download

* Reference genome

    * *Mycobacterium abscessus* ATCC 19977
        * Taxid: [561007](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=561007)
        * RefSeq assembly accession:
          [GCF_000069185.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/069/185/GCF_000069185.1_ASM6918v1/GCF_000069185.1_ASM6918v1_assembly_report.txt)
        * Proportion of paralogs (> 1000 bp): 0.0168
    * *Mycobacterium abscessus* 6G-0125-R
        * RefSeq assembly accession: GCF_000270985.1

```bash
mkdir -p ${HOME}/data/anchr/Mabs
cd ${HOME}/data/anchr/Mabs

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
cd ${HOME}/data/anchr/Mabs

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
cd ${HOME}/data/anchr/Mabs

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

## Mabs: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Mabs

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 5090491 \
    --trim2 "--uniq --shuffle --bbduk" \
    --cov2 "40 all" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,2,3" \
    --parallel 24

# run
bsub -q mpi -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

# quast
rm -fr 9_quast_competitor
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
    -o 9_quast_competitor

# bash 0_cleanup.sh

```

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 5067172 | 5090491 |       2 |
| Paralogs |    1580 |   83364 |      53 |
| Illumina |     251 |    512M | 2039840 |
| uniq     |     251 | 511.87M | 2039330 |
| shuffle  |     251 | 511.87M | 2039330 |
| bbduk    |     197 | 384.97M | 2038412 |
| Q20L60   |     178 | 290.75M | 1757516 |
| Q25L60   |     173 | 250.53M | 1570422 |
| Q30L60   |     163 | 220.91M | 1503261 |

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q20L60 | 189.4 |    185 |  47.7 |         38.94% |
| Q25L60 | 191.4 |    187 |  51.8 |         44.04% |
| Q30L60 | 191.8 |    187 |  62.0 |         46.74% |

| Name         | N50 |     Sum |       # |
|:-------------|----:|--------:|--------:|
| clumped      | 251 | 510.77M | 2034942 |
| trimmed      | 176 | 294.81M | 1802912 |
| filtered     | 176 | 293.79M | 1798032 |
| ecco         | 176 | 293.73M | 1798032 |
| eccc         | 176 | 293.73M | 1798032 |
| ecct         | 176 | 283.54M | 1739676 |
| extended     | 213 | 352.67M | 1739676 |
| merged       | 235 | 199.69M |  859906 |
| unmerged.raw | 206 |   3.58M |   19864 |
| unmerged     | 200 |   2.73M |   15656 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 190.0 |    185 |  46.5 |         92.23% |
| ihist.merge.txt  | 232.2 |    226 |  51.6 |         98.86% |

```text
#mergeReads
#Matched	4873	0.27028%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	4867	0.26995%
```

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q20L60 |  57.1 |   44.7 |   21.65% |     165 | "45" | 5.09M | 5.23M |     1.03 | 0:00'36'' |
| Q25L60 |  49.2 |   41.3 |   16.13% |     160 | "43" | 5.09M | 5.21M |     1.02 | 0:00'31'' |
| Q30L60 |  43.4 |   38.0 |   12.55% |     151 | "39" | 5.09M | 5.19M |     1.02 | 0:00'29'' |

```text
#Q20L60
#Matched	3152	0.22690%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	3152	0.22690%

#Q25L60
#Matched	3239	0.24280%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	3239	0.24280%

#Q30L60
#Matched	3137	0.23477%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	3137	0.23477%

```

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000  |   40.0 |  96.05% |      6681 | 4.77M | 1053 |       948 |  378.5K | 2427 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'53'' |
| Q20L60XallP000 |   44.7 |  95.64% |      6025 |  4.7M | 1135 |       972 | 431.94K | 2506 |   41.0 | 3.0 |  10.7 |  75.0 | "31,41,51,61,71,81" | 0:00'59'' | 0:00'53'' |
| Q25L60X40P000  |   40.0 |  97.33% |      8852 | 4.83M |  893 |       891 | 350.27K | 2204 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'56'' |
| Q25L60XallP000 |   41.3 |  97.30% |      8919 | 4.86M |  891 |       803 | 297.37K | 2176 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'54'' |
| Q30L60XallP000 |   38.0 |  98.46% |     13943 |  4.9M |  710 |       988 | 345.07K | 1942 |   36.0 | 2.0 |  10.0 |  63.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'56'' |

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000  |   40.0 |  98.36% |     14262 | 4.85M | 735 |       999 | 464.65K | 2053 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:01'00'' |
| Q20L60XallP000 |   44.7 |  98.13% |     13013 | 4.95M | 685 |       792 |    275K | 1917 |   42.0 | 3.0 |  11.0 |  76.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'56'' |
| Q25L60X40P000  |   40.0 |  98.65% |     12984 | 4.78M | 808 |      1030 | 589.64K | 2253 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'58'' |
| Q25L60XallP000 |   41.3 |  98.56% |     12201 | 4.74M | 864 |      1040 | 643.26K | 2313 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:01'00'' |
| Q30L60XallP000 |   38.0 |  99.07% |     16495 | 4.83M | 727 |      1110 | 623.66K | 2212 |   36.5 | 1.5 |  10.7 |  61.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'59'' |

| Name                           |     N50 |     Sum |    # |
|:-------------------------------|--------:|--------:|-----:|
| Genome                         | 5067172 | 5090491 |    2 |
| Paralogs                       |    1580 |   83364 |   53 |
| 6_mergeKunitigsAnchors.anchors |   16594 | 5051518 |  589 |
| 6_mergeKunitigsAnchors.others  |    1176 |  514971 |  449 |
| 6_mergeTadpoleAnchors.anchors  |   28789 | 5114120 |  349 |
| 6_mergeTadpoleAnchors.others   |    1290 |  955594 |  789 |
| 6_mergeAnchors.anchors         |   28789 | 5114120 |  349 |
| 6_mergeAnchors.others          |    1290 |  955594 |  789 |
| tadpole.Q20L60                 |    5378 | 5238729 | 2113 |
| tadpole.Q25L60                 |    6795 | 5223678 | 1789 |
| tadpole.Q30L60                 |    8474 | 5201308 | 1454 |
| spades.contig                  |  174287 | 5220387 |  270 |
| spades.scaffold                |  232956 | 5220517 |  266 |
| spades.non-contained           |  174287 | 5130469 |   46 |
| platanus.contig                |   31929 | 5161063 |  460 |
| platanus.scaffold              |   72495 | 5137530 |  212 |
| platanus.non-contained         |   72495 | 5114644 |  140 |


# *Vibrio cholerae* CP1032(5)

## Vcho: download

* Reference genome

    * *Vibrio cholerae* O1 biovar El Tor str. N16961
        * Taxid: [243277](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=243277)
        * RefSeq assembly accession:
          [GCF_000006745.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/745/GCF_000006745.1_ASM674v1/GCF_000006745.1_ASM674v1_assembly_report.txt)
        * Proportion of paralogs (> 1000 bp): 0.0210
    * *Vibrio cholerae* CP1032(5)
        * RefSeq assembly accession: GCF_000279305.1

```bash
mkdir -p ${HOME}/data/anchr/Vcho
cd ${HOME}/data/anchr/Vcho

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
mkdir -p ${HOME}/data/anchr/Vcho

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
mkdir -p ${HOME}/data/anchr/Vcho

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

## Vcho: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Vcho

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 4033464 \
    --trim2 "--uniq --shuffle --bbduk" \
    --cov2 "40 50 all" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,2,3" \
    --parallel 24

# run
bsub -q mpi -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

# quast
rm -fr 9_quast_competitor
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
    -o 9_quast_competitor

# bash 0_cleanup.sh

```

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 2961149 | 4033464 |       2 |
| Paralogs |    3483 |  114707 |      48 |
| Illumina |     251 |    400M | 1593624 |
| uniq     |     251 | 397.99M | 1585616 |
| shuffle  |     251 | 397.99M | 1585616 |
| bbduk    |     197 | 304.63M | 1584348 |
| Q20L60   |     190 | 274.56M | 1507602 |
| Q25L60   |     187 | 252.78M | 1417550 |
| Q30L60   |     180 |  229.6M | 1354637 |

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q20L60 | 196.8 |    190 |  55.1 |         38.49% |
| Q25L60 | 198.5 |    192 |  52.1 |         42.39% |
| Q30L60 | 199.0 |    192 |  54.4 |         45.66% |

| Name         | N50 |     Sum |       # |
|:-------------|----:|--------:|--------:|
| clumped      | 251 | 390.94M | 1557536 |
| trimmed      | 188 | 270.78M | 1502346 |
| filtered     | 188 | 269.05M | 1494132 |
| ecco         | 188 | 269.02M | 1494132 |
| eccc         | 188 | 269.02M | 1494132 |
| ecct         | 188 | 265.86M | 1476714 |
| extended     | 226 | 324.66M | 1476714 |
| merged       | 237 | 174.53M |  733052 |
| unmerged.raw | 224 |   2.17M |   10610 |
| unmerged     | 219 |   1.82M |    9190 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 195.9 |    190 |  44.4 |         95.04% |
| ihist.merge.txt  | 238.1 |    230 |  51.2 |         99.28% |

```text
#mergeReads
#Matched	8209	0.54641%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	8205	0.54615%
```

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q20L60 |  68.1 |   55.9 |   17.92% |     182 | "109" | 4.03M | 3.96M |     0.98 | 0:00'32'' |
| Q25L60 |  62.7 |   54.0 |   13.76% |     178 | "107" | 4.03M | 3.95M |     0.98 | 0:00'29'' |
| Q30L60 |  56.9 |   50.9 |   10.65% |     172 | "103" | 4.03M | 3.94M |     0.98 | 0:00'28'' |

```text
#Q20L60
#Matched	5385	0.43234%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	5385	0.43234%

#Q25L60
#Matched	5505	0.44664%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	5505	0.44664%

#Q30L60
#Matched	5490	0.44878%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	5490	0.44878%

```

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000  |   40.0 |  93.97% |      8875 | 3.68M | 668 |       921 | 185.62K | 1436 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'46'' |
| Q20L60X50P000  |   50.0 |  93.55% |      8028 | 3.68M | 693 |       931 | 169.29K | 1476 |   47.0 | 6.0 |   9.7 |  94.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'45'' |
| Q20L60XallP000 |   55.9 |  93.23% |      7463 | 3.67M | 720 |       906 | 171.71K | 1513 |   52.0 | 7.0 |  10.3 | 104.0 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'44'' |
| Q25L60X40P000  |   40.0 |  96.58% |     25260 | 3.75M | 315 |      1056 | 137.06K |  782 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'48'' |
| Q25L60X50P000  |   50.0 |  96.42% |     21724 | 3.77M | 325 |      1084 | 117.51K |  796 |   47.0 | 6.0 |   9.7 |  94.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'46'' |
| Q25L60XallP000 |   54.0 |  96.30% |     20565 | 3.78M | 341 |      1034 |  114.1K |  832 |   51.0 | 6.5 |  10.5 | 102.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'48'' |
| Q30L60X40P000  |   40.0 |  96.97% |     28917 | 3.76M | 294 |      1047 | 135.35K |  747 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'48'' |
| Q30L60X50P000  |   50.0 |  96.75% |     23646 | 3.78M | 286 |      1047 | 105.58K |  727 |   47.0 | 6.0 |   9.7 |  94.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'48'' |
| Q30L60XallP000 |   50.9 |  96.77% |     23646 | 3.79M | 282 |      1057 | 102.24K |  722 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'47'' |

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000  |   40.0 |  96.66% |     20243 | 3.77M | 385 |      1010 | 156.12K | 1037 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'48'' |
| Q20L60X50P000  |   50.0 |  96.19% |     15734 | 3.77M | 431 |      1031 | 139.58K | 1059 |   47.0 | 6.0 |   9.7 |  94.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'48'' |
| Q20L60XallP000 |   55.9 |  95.84% |     13441 | 3.77M | 475 |      1010 | 132.39K | 1110 |   53.0 | 7.0 |  10.7 | 106.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'47'' |
| Q25L60X40P000  |   40.0 |  97.57% |     42267 | 3.77M | 242 |      1177 | 162.26K |  755 |   36.0 | 5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'51'' |
| Q25L60X50P000  |   50.0 |  97.55% |     52730 | 3.81M | 208 |      1065 | 111.75K |  614 |   46.0 | 7.0 |   8.3 |  92.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'52'' |
| Q25L60XallP000 |   54.0 |  97.56% |     51785 | 3.81M | 206 |      1060 | 109.94K |  597 |   49.0 | 7.0 |   9.3 |  98.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'52'' |
| Q30L60X40P000  |   40.0 |  97.74% |     46461 | 3.76M | 249 |      1167 | 185.25K |  793 |   36.0 | 5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'53'' |
| Q30L60X50P000  |   50.0 |  97.66% |     51785 |  3.8M | 186 |      1126 | 125.99K |  613 |   46.0 | 6.0 |   9.3 |  92.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'51'' |
| Q30L60XallP000 |   50.9 |  97.68% |     52291 | 3.81M | 181 |      1125 | 114.38K |  598 |   47.0 | 6.0 |   9.7 |  94.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'52'' |

| Name                           |     N50 |     Sum |    # |
|:-------------------------------|--------:|--------:|-----:|
| Genome                         | 2961149 | 4033464 |    2 |
| Paralogs                       |    3483 |  114707 |   48 |
| 6_mergeKunitigsAnchors.anchors |   33102 | 3816570 |  223 |
| 6_mergeKunitigsAnchors.others  |    1322 |  243213 |  192 |
| 6_mergeTadpoleAnchors.anchors  |   69128 | 3850738 |  150 |
| 6_mergeTadpoleAnchors.others   |    1399 |  318782 |  237 |
| 6_mergeAnchors.anchors         |   69128 | 3850738 |  150 |
| 6_mergeAnchors.others          |    1399 |  318782 |  237 |
| tadpole.Q20L60                 |    6611 | 3942532 | 1232 |
| tadpole.Q25L60                 |    7680 | 3937250 | 1096 |
| tadpole.Q30L60                 |    9965 | 3926036 |  893 |
| spades.contig                  |  246446 | 4116141 |  558 |
| spades.scaffold                |  259375 | 4116341 |  556 |
| spades.non-contained           |  246446 | 3929304 |   66 |
| platanus.contig                |   49404 | 3992698 |  548 |
| platanus.scaffold              |   55222 | 3941539 |  351 |
| platanus.non-contained         |   58990 | 3880137 |  170 |


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

## RsphF: run

```bash
cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 4602977 \
    --trim2 "--uniq --shuffle --scythe " \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --parallel 24

# run
bsub -q mpi -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

# quast
rm -fr 9_quast_competitor
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
    -o 9_quast_competitor

#bash 0_cleanup.sh

```

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
| Q25L60X40P000 |   40.0 |     19434 | 4.07M | 370 |      3627 |  504.3K | 223 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'52'' |
| Q25L60X40P001 |   40.0 |     18906 | 4.01M | 371 |      4313 | 662.85K | 261 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'54'' |
| Q25L60X40P002 |   40.0 |     19316 | 4.01M | 361 |      5366 | 606.14K | 219 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'54'' |
| Q25L60X40P003 |   40.0 |     17657 | 4.05M | 388 |      4329 | 567.83K | 242 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'52'' |
| Q25L60X40P004 |   40.0 |     17674 | 4.08M | 395 |      3964 | 494.73K | 216 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'51'' |
| Q25L60X40P005 |   40.0 |     17401 | 4.04M | 395 |      4781 | 643.51K | 240 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'53'' |
| Q25L60X40P006 |   40.0 |     18457 |    4M | 370 |      5506 | 659.47K | 246 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'53'' |
| Q25L60X80P000 |   80.0 |     23147 | 4.09M | 340 |      2826 | 560.86K | 280 |   70.0 | 7.0 |  16.3 | 136.5 | "31,41,51,61,71,81" | 0:01'22'' | 0:00'57'' |
| Q25L60X80P001 |   80.0 |     20101 | 4.07M | 347 |      3212 | 587.45K | 283 |   70.0 | 6.0 |  17.3 | 132.0 | "31,41,51,61,71,81" | 0:01'21'' | 0:00'57'' |
| Q25L60X80P002 |   80.0 |     18458 | 4.09M | 359 |      3005 | 531.51K | 276 |   69.0 | 7.0 |  16.0 | 135.0 | "31,41,51,61,71,81" | 0:01'22'' | 0:00'56'' |
| Q30L60X40P000 |   40.0 |     11753 | 3.93M | 511 |      6624 | 694.42K | 256 |   34.0 | 4.0 |   7.3 |  68.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'48'' |
| Q30L60X40P001 |   40.0 |     12538 | 3.94M | 498 |      6931 | 663.08K | 252 |   34.0 | 4.0 |   7.3 |  68.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'50'' |
| Q30L60X40P002 |   40.0 |     12203 | 3.94M | 496 |      7403 | 702.06K | 251 |   34.0 | 4.0 |   7.3 |  68.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'51'' |
| Q30L60X40P003 |   40.0 |     11427 | 3.93M | 535 |      7435 | 660.51K | 255 |   34.0 | 4.0 |   7.3 |  68.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'49'' |
| Q30L60X40P004 |   40.0 |     13076 | 3.95M | 502 |      7475 | 656.23K | 241 |   34.0 | 4.0 |   7.3 |  68.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'49'' |
| Q30L60X40P005 |   40.0 |      2485 | 1.34M | 559 |      2841 | 821.09K | 410 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'46'' |
| Q30L60X80P000 |   80.0 |     18709 | 3.99M | 358 |      8988 | 681.02K | 198 |   69.0 | 7.0 |  16.0 | 135.0 | "31,41,51,61,71,81" | 0:01'17'' | 0:00'54'' |
| Q30L60X80P001 |   80.0 |     17339 |    4M | 380 |      7523 | 668.36K | 205 |   69.0 | 7.0 |  16.0 | 135.0 | "31,41,51,61,71,81" | 0:01'17'' | 0:00'54'' |
| Q30L60X80P002 |   80.0 |     18900 | 3.63M | 351 |      9408 | 806.51K | 208 |   70.0 | 3.0 |  20.3 | 118.5 | "31,41,51,61,71,81" | 0:01'16'' | 0:00'54'' |

| Name     |     N50 |     Sum |   # |
|:---------|--------:|--------:|----:|
| Genome   | 3188524 | 4602977 |   7 |
| Paralogs |    2337 |  147155 |  66 |
| anchors  |   43717 | 4173866 | 231 |
| others   |    3458 | 1660354 | 742 |

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

## MabsF: run

```bash
cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 5090491 \
    --trim2 "--uniq --shuffle --scythe " \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --parallel 24

# run
bsub -q mpi -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

# quast
rm -fr 9_quast_competitor
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
    -o 9_quast_competitor

#bash 0_cleanup.sh

```

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
| Q25L60 | 210.7 |  176.0 |  16.486% |     159 | "43" | 5.09M | 5.49M |     1.08 | 0:01'56'' |
| Q30L60 | 185.9 |  161.9 |  12.893% |     151 | "39" | 5.09M | 5.41M |     1.06 | 0:01'43'' |

```text
#File	pe.cor.raw
#Total	5635562
#Matched	32	0.00057%
#Name	Reads	ReadsPct
Reverse_adapter	28	0.00050%
TruSeq_Adapter_Index_11	3	0.00005%
I7_Primer_Nextera_XT_Index_Kit_v2_N715	1	0.00002%

#File	pe.cor.raw
#Total	5660521
#Matched	89	0.00157%
#Name	Reads	ReadsPct
TruSeq_Adapter_Index_11	59	0.00104%
Reverse_adapter	29	0.00051%
RNA_PCR_Primer_Index_11_(RPI11)	1	0.00002%

```

| Name          | CovCor | N50Anchor |   Sum |    # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|------:|-----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |      5996 | 4.35M | 1028 |      1020 | 311.52K | 314 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'51'' |
| Q25L60X40P001 |   40.0 |      6252 | 4.32M |  994 |      1039 | 356.74K | 344 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'51'' |
| Q25L60X40P002 |   40.0 |      5970 |  4.3M | 1037 |      1015 | 321.27K | 318 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'50'' |
| Q25L60X40P003 |   40.0 |      6323 | 4.42M | 1028 |      1026 | 321.29K | 310 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'50'' |
| Q25L60X80P000 |   80.0 |      3611 | 4.39M | 1478 |       901 | 568.25K | 661 |   70.0 | 7.0 |  16.3 | 136.5 | "31,41,51,61,71,81" | 0:01'29'' | 0:00'49'' |
| Q25L60X80P001 |   80.0 |      3674 | 4.39M | 1502 |       929 | 595.02K | 668 |   70.0 | 7.0 |  16.3 | 136.5 | "31,41,51,61,71,81" | 0:01'30'' | 0:00'49'' |
| Q30L60X40P000 |   40.0 |      7737 | 4.39M |  840 |      1114 | 266.97K | 249 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'54'' |
| Q30L60X40P001 |   40.0 |      8381 | 4.36M |  833 |      1026 | 237.69K | 234 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'53'' |
| Q30L60X40P002 |   40.0 |      7820 | 4.31M |  854 |      1058 | 268.32K | 259 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'54'' |
| Q30L60X40P003 |   40.0 |     12190 |  4.8M |  615 |       944 | 118.77K | 121 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'54'' |
| Q30L60X80P000 |   80.0 |      4876 | 4.43M | 1221 |       949 | 409.66K | 446 |   73.0 | 6.0 |  18.3 | 136.5 | "31,41,51,61,71,81" | 0:01'28'' | 0:00'52'' |
| Q30L60X80P001 |   80.0 |      5832 | 4.85M | 1121 |       894 | 276.06K | 309 |   74.0 | 5.0 |  19.7 | 133.5 | "31,41,51,61,71,81" | 0:01'27'' | 0:00'54'' |

| Name     |     N50 |     Sum |    # |
|:---------|--------:|--------:|-----:|
| Genome   | 5067172 | 5090491 |    2 |
| Paralogs |    1580 |   83364 |   53 |
| anchors  |   66219 | 5243156 |  164 |
| others   |    1082 | 1735580 | 1604 |

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

## VchoF: run

```bash
cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 4033464 \
    --trim2 "--uniq --shuffle --scythe " \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --parallel 24

# run
bsub -q mpi -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

# quast
rm -fr 9_quast_competitor
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
    -o 9_quast_competitor

#bash 0_cleanup.sh

```

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
#Total	5269158
#Matched	85	0.00161%
#Name	Reads	ReadsPct
Reverse_adapter	58	0.00110%
TruSeq_Adapter_Index_6	20	0.00038%
TruSeq_Adapter_Index_5	6	0.00011%
I7_Primer_Nextera_XT_Index_Kit_v2_N715	1	0.00002%

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
| Q25L60X40P000 |   40.0 |      3067 | 2.97M | 1126 |       922 | 717.92K |  781 |   34.0 |  5.0 |   6.3 |  68.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'40'' |
| Q25L60X40P001 |   40.0 |      2981 | 2.98M | 1165 |       917 | 691.01K |  772 |   34.0 |  5.0 |   6.3 |  68.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'40'' |
| Q25L60X40P002 |   40.0 |      3086 | 2.97M | 1154 |       921 | 723.39K |  789 |   34.0 |  5.0 |   6.3 |  68.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'40'' |
| Q25L60X40P003 |   40.0 |      3040 | 2.98M | 1150 |       913 | 694.99K |  754 |   34.0 |  5.0 |   6.3 |  68.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'41'' |
| Q25L60X40P004 |   40.0 |      3058 | 2.99M | 1135 |       910 | 694.13K |  767 |   34.0 |  5.0 |   6.3 |  68.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'41'' |
| Q25L60X80P000 |   80.0 |      2085 | 2.46M | 1257 |       839 |   1.17M | 1448 |   65.0 |  9.0 |  12.7 | 130.0 | "31,41,51,61,71,81" | 0:01'15'' | 0:00'40'' |
| Q25L60X80P001 |   80.0 |      2179 | 2.45M | 1237 |       851 |   1.21M | 1448 |   65.0 |  9.0 |  12.7 | 130.0 | "31,41,51,61,71,81" | 0:01'15'' | 0:00'39'' |
| Q30L60X40P000 |   40.0 |      7099 | 3.54M |  709 |       994 | 256.83K |  245 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'43'' |
| Q30L60X40P001 |   40.0 |      7030 |  3.5M |  715 |       892 | 219.85K |  238 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'41'' |
| Q30L60X40P002 |   40.0 |      6980 | 3.44M |  722 |       921 | 235.97K |  251 |   35.0 |  5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'41'' |
| Q30L60X40P003 |   40.0 |      7268 | 3.56M |  712 |       894 | 225.02K |  240 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'40'' |
| Q30L60X40P004 |   40.0 |      7231 | 3.42M |  688 |       964 | 264.06K |  259 |   35.0 |  6.0 |   5.7 |  70.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'41'' |
| Q30L60X80P000 |   80.0 |      4369 | 3.46M | 1016 |       867 | 374.81K |  440 |   71.0 | 10.0 |  13.7 | 142.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'42'' |
| Q30L60X80P001 |   80.0 |      4268 | 3.47M | 1027 |       858 | 353.68K |  412 |   71.0 | 10.0 |  13.7 | 142.0 | "31,41,51,61,71,81" | 0:01'15'' | 0:00'41'' |

| Name     |     N50 |     Sum |    # |
|:---------|--------:|--------:|-----:|
| Genome   | 2961149 | 4033464 |    2 |
| Paralogs |    3483 |  114707 |   48 |
| anchors  |   52850 | 3920732 |  242 |
| others   |     984 | 2942347 | 2934 |
