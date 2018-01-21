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
- [*Vibrio cholerae* CP1032(5) HiSeq](#vibrio-cholerae-cp10325-hiseq)
    - [VchoH: download](#vchoh-download)
    - [VchoH: run](#vchoh-run)
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
for D in Bcer Rsph Mabs Vcho VchoH RsphF MabsF VchoF; do
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
    * Taxid:
      [222523](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=222523)
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
QUEUE_NAME=mpi

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
    --insertsize \
    --parallel 24

# run
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_quast_competitor" \
    '
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
        7_mergeAnchors/anchor.merge.fasta \
        7_mergeAnchors/others.non-contained.fasta \
        1_genome/paralogs.fas \
        --label "abyss,cabog,mira,msrca,sga,soap,spades,velvet,merge,others,paralogs" \
        -o 9_quast_competitor
    '

```

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| genome.bbtools  | 578.4 |    578 | 708.2 |                         49.48% |
| tadpole.bbtools | 557.2 |    571 | 165.2 |                         44.69% |
| genome.picard   | 582.1 |    585 | 146.5 |                             FR |
| tadpole.picard  | 573.7 |    577 | 147.3 |                             FR |

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


| Name         | N50 |     Sum |       # |
|:-------------|----:|--------:|--------:|
| clumped      | 251 | 480.97M | 2079706 |
| trimmed      | 250 | 418.04M | 1875014 |
| filtered     | 250 | 417.87M | 1874300 |
| ecco         | 250 | 417.87M | 1874300 |
| eccc         | 250 | 417.87M | 1874300 |
| ecct         | 250 |  413.4M | 1850282 |
| extended     | 290 | 486.45M | 1850282 |
| merged       | 585 |  325.4M |  600410 |
| unmerged.raw | 285 | 156.61M |  649462 |
| unmerged     | 255 | 124.52M |  592542 |

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
| Q20L60 |  75.8 |   64.9 |   14.41% |     226 | "127" | 5.43M | 5.35M |     0.99 | 0:00'50'' |
| Q25L60 |  70.0 |   63.3 |    9.55% |     222 | "127" | 5.43M | 5.34M |     0.98 | 0:00'46'' |
| Q30L60 |  68.2 |   64.2 |    5.98% |     215 | "127" | 5.43M | 5.34M |     0.98 | 0:00'46'' |

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|-------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000  |   40.0 |  97.38% |     23791 | 5.28M | 368 |        90 | 60.85K | 1025 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'57'' |
| Q20L60X50P000  |   50.0 |  97.28% |     22812 | 5.28M | 383 |        79 | 61.61K | 1057 |   47.5 | 5.5 |  10.3 |  95.0 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'58'' |
| Q20L60X60P000  |   60.0 |  97.23% |     22475 | 5.28M | 390 |        78 | 60.35K | 1064 |   57.0 | 7.0 |  12.0 | 114.0 | "31,41,51,61,71,81" | 0:01'35'' | 0:00'58'' |
| Q20L60XallP000 |   64.9 |  97.21% |     22094 | 5.27M | 394 |        81 | 64.74K | 1076 |   62.0 | 7.0 |  13.7 | 124.0 | "31,41,51,61,71,81" | 0:01'40'' | 0:00'56'' |
| Q25L60X40P000  |   40.0 |  97.93% |     35031 | 5.29M | 261 |       105 | 54.73K |  830 |   38.5 | 4.5 |   8.3 |  77.0 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'59'' |
| Q25L60X50P000  |   50.0 |  97.92% |     38832 |  5.3M | 257 |        75 | 44.86K |  808 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:01'25'' | 0:00'59'' |
| Q25L60X60P000  |   60.0 |  97.95% |     39500 |  5.3M | 251 |        82 | 47.91K |  811 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:01'36'' | 0:01'03'' |
| Q25L60XallP000 |   63.3 |  97.94% |     34474 |  5.3M | 254 |        82 | 48.83K |  824 |   61.0 | 7.0 |  13.3 | 122.0 | "31,41,51,61,71,81" | 0:01'40'' | 0:01'01'' |
| Q30L60X40P000  |   40.0 |  98.15% |     41485 | 5.29M | 253 |       154 | 60.29K |  826 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'59'' |
| Q30L60X50P000  |   50.0 |  98.17% |     41788 | 5.29M | 236 |        89 | 48.74K |  797 |   48.0 | 5.0 |  11.0 |  94.5 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'59'' |
| Q30L60X60P000  |   60.0 |  98.15% |     41788 |  5.3M | 229 |        77 | 46.15K |  815 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:01'35'' | 0:01'03'' |
| Q30L60XallP000 |   64.2 |  98.09% |     41788 |  5.3M | 224 |        76 |    47K |  812 |   62.0 | 7.0 |  13.7 | 124.0 | "31,41,51,61,71,81" | 0:01'40'' | 0:01'02'' |

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|-------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000  |   40.0 |  97.96% |     29275 | 5.29M | 305 |        95 | 59.89K |  913 |   38.0 | 4.5 |   8.2 |  76.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'56'' |
| Q20L60X50P000  |   50.0 |  97.90% |     27032 | 5.29M | 322 |        82 | 57.39K |  958 |   47.0 | 6.0 |   9.7 |  94.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'58'' |
| Q20L60X60P000  |   60.0 |  97.79% |     24729 | 5.29M | 341 |        78 | 58.53K | 1001 |   57.0 | 7.0 |  12.0 | 114.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'58'' |
| Q20L60XallP000 |   64.9 |  97.76% |     24492 | 5.29M | 348 |        81 | 61.31K | 1019 |   62.0 | 7.0 |  13.7 | 124.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'59'' |
| Q25L60X40P000  |   40.0 |  98.54% |     32316 | 5.29M | 281 |       163 | 63.59K |  875 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'59'' |
| Q25L60X50P000  |   50.0 |  98.55% |     34259 |  5.3M | 263 |        96 | 55.42K |  843 |   47.5 | 5.5 |  10.3 |  95.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:01'00'' |
| Q25L60X60P000  |   60.0 |  98.55% |     35047 |  5.3M | 258 |        89 | 52.36K |  833 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'59'' |
| Q25L60XallP000 |   63.3 |  98.54% |     39501 |  5.3M | 253 |        94 | 54.03K |  830 |   61.0 | 7.0 |  13.3 | 122.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:01'00'' |
| Q30L60X40P000  |   40.0 |  98.67% |     32325 | 5.29M | 282 |       198 | 69.21K |  897 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'58'' |
| Q30L60X50P000  |   50.0 |  98.73% |     35146 | 5.29M | 254 |        97 | 57.47K |  858 |   48.0 | 5.0 |  11.0 |  94.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:01'01'' |
| Q30L60X60P000  |   60.0 |  98.68% |     39502 |  5.3M | 240 |        78 | 48.13K |  830 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:01'01'' |
| Q30L60XallP000 |   64.2 |  98.63% |     37668 |  5.3M | 238 |        76 |  47.5K |  819 |   62.0 | 7.0 |  13.7 | 124.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:01'00'' |

| Name                           |     N50 |     Sum |   # |
|:-------------------------------|--------:|--------:|----:|
| Genome                         | 5224283 | 5432652 |   2 |
| Paralogs                       |    2295 |  223889 | 103 |
| 7_mergeKunitigsAnchors.anchors |   46576 | 5312541 | 209 |
| 7_mergeKunitigsAnchors.others  |    1093 |   36933 |  32 |
| 7_mergeTadpoleAnchors.anchors  |   46669 | 5315022 | 205 |
| 7_mergeTadpoleAnchors.others   |    1110 |   48557 |  42 |
| 7_mergeAnchors.anchors         |   46669 | 5315022 | 205 |
| 7_mergeAnchors.others          |    1110 |   48557 |  42 |
| tadpole.Q20L60                 |   11462 | 5322724 | 949 |
| tadpole.Q25L60                 |   16956 | 5318749 | 755 |
| tadpole.Q30L60                 |   18156 | 5318705 | 727 |
| spades.contig                  |  207648 | 5370433 | 168 |
| spades.scaffold                |  284294 | 5370573 | 154 |
| spades.non-contained           |  207648 | 5350580 |  59 |
| spades.anchor                  |  207555 | 5326470 |  67 |
| megahit.contig                 |   60414 | 5365088 | 255 |
| megahit.non-contained          |   60414 | 5333403 | 171 |
| megahit.anchor                 |   60380 | 5291226 | 188 |
| platanus.contig                |   18759 | 5417970 | 652 |
| platanus.scaffold              |  485201 | 5351371 | 248 |
| platanus.non-contained         |  485201 | 5304311 |  38 |
| platanus.anchor                |  284426 | 5285166 |  49 |

# *Rhodobacter sphaeroides* 2.4.1

## Rsph: download

* Reference genome

    * Strain: Rhodobacter sphaeroides 2.4.1
    * Taxid:
      [272943](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=272943)
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
QUEUE_NAME=mpi

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
    --insertsize \
    --parallel 24

# run
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_quast_competitor" \
    '
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
        7_mergeAnchors/anchor.merge.fasta \
        7_mergeAnchors/others.non-contained.fasta \
        1_genome/paralogs.fas \
        --label "abyss,cabog,mira,msrca,sga,soap,spades,velvet,merge,others,paralogs" \
        -o 9_quast_competitor
    '

```

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| genome.bbtools  | 440.0 |    422 | 958.8 |                         15.58% |
| tadpole.bbtools | 407.5 |    420 |  84.2 |                         32.42% |
| genome.picard   | 412.9 |    422 |  39.3 |                             FR |
| tadpole.picard  | 408.5 |    421 |  46.7 |                             FR |

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


| Name         | N50 |     Sum |       # |
|:-------------|----:|--------:|--------:|
| clumped      | 251 | 447.19M | 1781618 |
| trimmed      | 148 |  200.1M | 1452703 |
| filtered     | 148 |  200.1M | 1452699 |
| ecco         | 148 |    200M | 1452698 |
| ecct         | 148 | 198.78M | 1443508 |
| extended     | 186 | 255.85M | 1443508 |
| merged       | 456 | 170.62M |  405209 |
| unmerged.raw | 175 |  105.2M |  633090 |
| unmerged     | 158 |   86.2M |  591474 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 198.0 |    197 |  63.5 |          6.92% |
| ihist.merge.txt  | 421.1 |    453 |  81.0 |         56.14% |

```text
#mergeReads
#Matched	4	0.00028%
#Name	Reads	ReadsPct
```

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q20L60 |  37.7 |   33.7 |   10.59% |     136 | "37" |  4.6M | 4.55M |     0.99 | 0:00'26'' |
| Q25L60 |  31.4 |   30.0 |    4.40% |     127 | "35" |  4.6M | 4.53M |     0.98 | 0:00'21'' |
| Q30L60 |  27.4 |   26.8 |    2.21% |     112 | "31" |  4.6M | 4.52M |     0.98 | 0:00'20'' |

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X30P000  |   30.0 |  97.92% |     20558 | 4.06M | 326 |      5895 | 646.14K | 1308 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'56'' |
| Q20L60XallP000 |   33.7 |  97.84% |     22587 | 4.06M | 310 |      7043 | 647.19K | 1251 |   29.0 | 2.0 |   7.7 |  52.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'56'' |
| Q25L60X30P000  |   30.0 |  98.29% |     16279 |    4M | 428 |      8835 | 759.05K | 1391 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'51'' |
| Q25L60XallP000 |   30.0 |  98.29% |     16279 |    4M | 428 |      8835 | 759.73K | 1391 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'53'' |
| Q30L60XallP000 |   26.8 |  98.02% |      9521 | 3.96M | 606 |      7245 | 830.37K | 1764 |   23.0 | 2.0 |   5.7 |  43.5 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'50'' |

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X30P000  |   30.0 |  98.28% |     14483 | 4.02M | 456 |      8450 | 759.57K | 1596 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'54'' |
| Q20L60XallP000 |   33.7 |  98.41% |     16866 | 4.02M | 418 |      7526 | 788.58K | 1567 |   29.0 | 2.0 |   7.7 |  52.5 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'54'' |
| Q25L60X30P000  |   30.0 |  97.87% |      9776 | 3.94M | 633 |      6632 |  818.4K | 1836 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'52'' |
| Q25L60XallP000 |   30.0 |  97.87% |      9776 | 3.94M | 633 |      6632 | 819.06K | 1836 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'50'' |
| Q30L60XallP000 |   26.8 |  96.89% |      6439 | 3.85M | 852 |      5804 | 854.41K | 2296 |   23.0 | 2.0 |   5.7 |  43.5 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'49'' |

| Name                           |     N50 |     Sum |    # |
|:-------------------------------|--------:|--------:|-----:|
| Genome                         | 3188524 | 4602977 |    7 |
| Paralogs                       |    2337 |  147155 |   66 |
| 7_mergeKunitigsAnchors.anchors |   30353 | 4088766 |  265 |
| 7_mergeKunitigsAnchors.others  |   12265 |  943298 |  211 |
| 7_mergeTadpoleAnchors.anchors  |   30353 | 4089181 |  263 |
| 7_mergeTadpoleAnchors.others   |   10910 |  988860 |  259 |
| 7_mergeAnchors.anchors         |   30353 | 4089181 |  263 |
| 7_mergeAnchors.others          |   10910 |  988860 |  259 |
| tadpole.Q20L60                 |    9813 | 4520272 | 1076 |
| tadpole.Q25L60                 |    7912 | 4515562 | 1304 |
| tadpole.Q30L60                 |    3644 | 4500715 | 2517 |
| spades.contig                  |   86457 | 4571770 |  159 |
| spades.scaffold                |  130378 | 4572405 |  136 |
| spades.non-contained           |   88009 | 4556507 |  104 |
| spades.anchor                  |    4355 | 3646752 | 1079 |
| megahit.contig                 |   28867 | 4570304 |  361 |
| megahit.non-contained          |   29619 | 4531514 |  282 |
| megahit.anchor                 |    4238 | 3618689 | 1094 |
| platanus.contig                |    4863 | 4603873 | 3435 |
| platanus.scaffold              |   37803 | 4533935 |  888 |
| platanus.non-contained         |   38632 | 4403868 |  229 |
| platanus.anchor                |    4143 | 3520281 | 1102 |


# *Mycobacterium abscessus* 6G-0125-R

## Mabs: download

* Reference genome

    * *Mycobacterium abscessus* ATCC 19977
        * Taxid:
          [561007](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=561007)
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
QUEUE_NAME=mpi

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
    --insertsize \
    --parallel 24

# run
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_quast_competitor" \
    '
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
        7_mergeAnchors/anchor.merge.fasta \
        7_mergeAnchors/others.non-contained.fasta \
        1_genome/paralogs.fas \
        --label "abyss,cabog,mira,msrca,sga,soap,spades,velvet,merge,others,paralogs" \
        -o 9_quast_competitor
    '

```

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 458.7 |    277 | 2524.0 |                          7.42% |
| tadpole.bbtools | 266.8 |    266 |   49.3 |                         35.20% |
| genome.picard   | 295.7 |    279 |   47.4 |                             FR |
| genome.picard   | 287.1 |    271 |   33.8 |                             RF |
| tadpole.picard  | 267.9 |    267 |   49.1 |                             FR |
| tadpole.picard  | 251.5 |    255 |   48.0 |                             RF |

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


| Name         | N50 |     Sum |       # |
|:-------------|----:|--------:|--------:|
| clumped      | 251 | 510.77M | 2034942 |
| trimmed      | 176 | 294.81M | 1802912 |
| filtered     | 176 | 293.79M | 1798032 |
| ecco         | 176 | 293.73M | 1798032 |
| eccc         | 176 | 293.73M | 1798032 |
| ecct         | 176 | 283.54M | 1739676 |
| extended     | 213 | 352.67M | 1739676 |
| merged       | 235 | 199.69M |  859911 |
| unmerged.raw | 206 |   3.58M |   19854 |
| unmerged     | 200 |   2.72M |   15642 |

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
| Q20L60 |  57.1 |   44.9 |   21.34% |     164 | "45" | 5.09M | 5.23M |     1.03 | 0:03'52'' |
| Q25L60 |  49.2 |   41.4 |   15.81% |     158 | "43" | 5.09M | 5.21M |     1.02 | 0:00'31'' |
| Q30L60 |  43.4 |   38.1 |   12.18% |     150 | "39" | 5.09M | 5.19M |     1.02 | 0:00'28'' |


| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000  |   40.0 |  96.00% |      6717 |  4.8M | 1058 |       832 | 348.79K | 2436 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'53'' |
| Q20L60XallP000 |   44.9 |  95.55% |      6025 |  4.7M | 1135 |       979 | 435.33K | 2508 |   41.0 | 3.0 |  10.7 |  75.0 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'51'' |
| Q25L60X40P000  |   40.0 |  97.39% |      8820 | 4.82M |  897 |       983 |  369.4K | 2220 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'55'' |
| Q25L60XallP000 |   41.4 |  97.30% |      8919 | 4.86M |  891 |       820 | 302.76K | 2177 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'53'' |
| Q30L60XallP000 |   38.1 |  98.46% |     13943 | 4.89M |  709 |       995 | 350.46K | 1943 |   36.0 | 2.0 |  10.0 |  63.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'55'' |

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000  |   40.0 |  98.42% |     15028 | 4.87M | 736 |      1004 | 457.59K | 2043 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'59'' |
| Q20L60XallP000 |   44.9 |  98.13% |     13013 | 4.95M | 685 |       921 | 307.65K | 1923 |   42.0 | 3.0 |  11.0 |  76.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'57'' |
| Q25L60X40P000  |   40.0 |  98.62% |     14578 | 4.82M | 783 |      1032 | 565.29K | 2253 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:01'29'' |
| Q25L60XallP000 |   41.4 |  98.57% |     12201 | 4.74M | 864 |      1058 | 665.05K | 2317 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:07'06'' |
| Q30L60XallP000 |   38.1 |  99.07% |     19777 | 5.01M | 513 |       885 | 308.89K | 1881 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:06'09'' |

| Name                           |     N50 |     Sum |    # |
|:-------------------------------|--------:|--------:|-----:|
| Genome                         | 5067172 | 5090491 |    2 |
| Paralogs                       |    1580 |   83364 |   53 |
| 7_mergeKunitigsAnchors.anchors |   16283 | 5032484 |  577 |
| 7_mergeKunitigsAnchors.others  |    1220 |  513486 |  437 |
| 7_mergeTadpoleAnchors.anchors  |   30965 | 5097276 |  316 |
| 7_mergeTadpoleAnchors.others   |    1405 |  957692 |  728 |
| 7_mergeAnchors.anchors         |   30965 | 5097276 |  316 |
| 7_mergeAnchors.others          |    1405 |  957692 |  728 |
| tadpole.Q20L60                 |    5378 | 5238729 | 2113 |
| tadpole.Q25L60                 |    6795 | 5223678 | 1789 |
| tadpole.Q30L60                 |    8474 | 5201308 | 1454 |
| spades.contig                  |  174287 | 5220387 |  270 |
| spades.scaffold                |  232956 | 5220517 |  266 |
| spades.non-contained           |  174287 | 5130469 |   46 |
| spades.anchor                  |    3164 | 4219251 | 1585 |
| megahit.contig                 |   87996 | 5153722 |  187 |
| megahit.non-contained          |   87996 | 5126071 |  108 |
| megahit.anchor                 |    4116 | 4493352 | 1396 |
| platanus.contig                |   31929 | 5161063 |  460 |
| platanus.scaffold              |   72495 | 5137530 |  212 |
| platanus.non-contained         |   72495 | 5114644 |  140 |
| platanus.anchor                |    3143 | 4201359 | 1591 |


# *Vibrio cholerae* CP1032(5)

## Vcho: download

* Reference genome

    * *Vibrio cholerae* O1 biovar El Tor str. N16961
        * Taxid:
          [243277](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=243277)
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
QUEUE_NAME=mpi

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
    --insertsize \
    --parallel 24

# run
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_quast_competitor" \
    '
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
        7_mergeAnchors/anchor.merge.fasta \
        7_mergeAnchors/others.non-contained.fasta \
        1_genome/paralogs.fas \
        --label "abyss,cabog,mira,msrca,sga,soap,spades,velvet,merge,others,paralogs" \
        -o 9_quast_competitor
    '

```

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 391.1 |    274 | 1890.4 |                          8.53% |
| tadpole.bbtools | 270.8 |    267 |   53.0 |                         41.32% |
| genome.picard   | 294.0 |    277 |   48.0 |                             FR |
| genome.picard   | 280.2 |    268 |   29.0 |                             RF |
| tadpole.picard  | 271.9 |    268 |   48.0 |                             FR |
| tadpole.picard  | 260.5 |    262 |   44.9 |                             RF |

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


| Name         | N50 |     Sum |       # |
|:-------------|----:|--------:|--------:|
| clumped      | 251 | 390.94M | 1557536 |
| trimmed      | 188 | 270.78M | 1502346 |
| filtered     | 188 | 269.05M | 1494132 |
| ecco         | 188 | 269.02M | 1494132 |
| eccc         | 188 | 269.02M | 1494132 |
| ecct         | 188 | 265.86M | 1476714 |
| extended     | 226 | 324.66M | 1476714 |
| merged       | 237 | 174.53M |  733053 |
| unmerged.raw | 224 |   2.16M |   10608 |
| unmerged     | 219 |   1.82M |    9182 |

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
| Q20L60 |  68.1 |   56.2 |   17.43% |     181 | "111" | 4.03M | 3.96M |     0.98 | 0:00'33'' |
| Q25L60 |  62.7 |   54.4 |   13.27% |     178 | "107" | 4.03M | 3.95M |     0.98 | 0:00'31'' |
| Q30L60 |  56.9 |   51.2 |   10.16% |     172 | "103" | 4.03M | 3.94M |     0.98 | 0:00'29'' |

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000  |   40.0 |  93.77% |      8742 | 3.67M | 663 |      1054 |  202.3K | 1441 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'45'' |
| Q20L60X50P000  |   50.0 |  93.25% |      7862 | 3.67M | 701 |       959 | 178.92K | 1491 |   46.0 | 6.0 |   9.3 |  92.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'45'' |
| Q20L60XallP000 |   56.2 |  92.91% |      7463 | 3.67M | 720 |       923 | 173.81K | 1515 |   52.0 | 7.0 |  10.3 | 104.0 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'44'' |
| Q25L60X40P000  |   40.0 |  96.72% |     23293 | 3.75M | 304 |      1076 | 149.07K |  802 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'48'' |
| Q25L60X50P000  |   50.0 |  96.42% |     21106 | 3.78M | 327 |      1032 | 120.21K |  816 |   47.0 | 6.0 |   9.7 |  94.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'47'' |
| Q25L60XallP000 |   54.4 |  96.30% |     20583 | 3.79M | 342 |      1010 | 103.89K |  832 |   51.0 | 7.0 |  10.0 | 102.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'47'' |
| Q30L60X40P000  |   40.0 |  97.01% |     25703 | 3.76M | 294 |      1129 | 161.52K |  802 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'48'' |
| Q30L60X50P000  |   50.0 |  96.75% |     23656 | 3.79M | 292 |      1066 | 103.57K |  738 |   46.5 | 6.5 |   9.0 |  93.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'47'' |
| Q30L60XallP000 |   51.2 |  96.77% |     23646 | 3.78M | 283 |      1067 | 110.84K |  730 |   47.5 | 6.5 |   9.3 |  95.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'47'' |

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000  |   40.0 |  96.73% |     17722 | 3.77M | 393 |      1130 | 179.41K | 1076 |   36.0 | 5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'49'' |
| Q20L60X50P000  |   50.0 |  96.15% |     15633 | 3.76M | 438 |      1171 |  188.6K | 1073 |   46.0 | 6.0 |   9.3 |  92.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'48'' |
| Q20L60XallP000 |   56.2 |  95.88% |     13441 | 3.77M | 475 |      1181 | 165.04K | 1116 |   53.0 | 7.0 |  10.7 | 106.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'46'' |
| Q25L60X40P000  |   40.0 |  97.66% |     45118 | 3.78M | 236 |      1182 | 174.59K |  760 |   36.0 | 5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'54'' |
| Q25L60X50P000  |   50.0 |  97.55% |     48558 | 3.82M | 210 |      1120 | 126.57K |  650 |   45.0 | 7.0 |   8.0 |  90.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'51'' |
| Q25L60XallP000 |   54.4 |  97.58% |     52730 | 3.82M | 201 |      1265 | 123.59K |  597 |   49.5 | 7.5 |   9.0 |  99.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'53'' |
| Q30L60X40P000  |   40.0 |  97.72% |     42361 | 3.79M | 207 |      1502 | 185.46K |  778 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'53'' |
| Q30L60X50P000  |   50.0 |  97.69% |     51810 | 3.82M | 179 |      1330 | 137.77K |  614 |   46.0 | 6.5 |   8.8 |  92.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'52'' |
| Q30L60XallP000 |   51.2 |  97.70% |     52294 | 3.82M | 182 |      1250 | 130.49K |  607 |   47.0 | 7.0 |   8.7 |  94.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'51'' |

| Name                           |     N50 |     Sum |    # |
|:-------------------------------|--------:|--------:|-----:|
| Genome                         | 2961149 | 4033464 |    2 |
| Paralogs                       |    3483 |  114707 |   48 |
| 7_mergeKunitigsAnchors.anchors |   34831 | 3824443 |  229 |
| 7_mergeKunitigsAnchors.others  |    1390 |  245308 |  182 |
| 7_mergeTadpoleAnchors.anchors  |   68220 | 3852346 |  148 |
| 7_mergeTadpoleAnchors.others   |    3646 |  566298 |  275 |
| 7_mergeAnchors.anchors         |   68220 | 3852347 |  148 |
| 7_mergeAnchors.others          |    3646 |  566298 |  275 |
| tadpole.Q20L60                 |    6611 | 3942532 | 1232 |
| tadpole.Q25L60                 |    7680 | 3937250 | 1096 |
| tadpole.Q30L60                 |    9965 | 3926036 |  893 |
| spades.contig                  |  246446 | 4116141 |  558 |
| spades.scaffold                |  259375 | 4116341 |  556 |
| spades.non-contained           |  246446 | 3929304 |   66 |
| spades.anchor                  |  198930 | 3819104 |  200 |
| megahit.contig                 |   87595 | 3962479 |  273 |
| megahit.non-contained          |   87595 | 3892965 |  117 |
| megahit.anchor                 |   65633 | 3792223 |  237 |
| platanus.contig                |   49404 | 3992698 |  548 |
| platanus.scaffold              |   55222 | 3941539 |  351 |
| platanus.non-contained         |   58990 | 3880137 |  170 |
| platanus.anchor                |   42784 | 3697431 |  338 |


# *Vibrio cholerae* CP1032(5) HiSeq

## VchoH: download

* Settings

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=VchoH

```

* Reference genome

```bash
mkdir -p ${HOME}/data/anchr/VchoH
cd ${HOME}/data/anchr/VchoH

mkdir -p 1_genome
cd 1_genome

cp ~/data/anchr/Vcho/1_genome/genome.fa .
cp ~/data/anchr/Vcho/1_genome/paralogs.fas .

```

* Illumina

    Download from GAGE-B site.

```bash
cd ${HOME}/data/anchr/VchoH

mkdir -p 2_illumina
cd 2_illumina

aria2c -x 9 -s 3 -c http://ccb.jhu.edu/gage_b/datasets/V_cholerae_HiSeq.tar.gz

# NOT gzipped tar
tar xvf V_cholerae_HiSeq.tar.gz raw/reads_1.fastq
tar xvf V_cholerae_HiSeq.tar.gz raw/reads_2.fastq

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
cd ${HOME}/data/anchr/VchoH

mkdir -p 8_competitor
cd 8_competitor

aria2c -x 9 -s 3 -c http://ccb.jhu.edu/gage_b/genomeAssemblies/V_cholerae_HiSeq.tar.gz

tar xvfz V_cholerae_HiSeq.tar.gz abyss_ctg.fasta
tar xvfz V_cholerae_HiSeq.tar.gz cabog_ctg.fasta
tar xvfz V_cholerae_HiSeq.tar.gz mira_ctg.fasta
tar xvfz V_cholerae_HiSeq.tar.gz msrca_ctg.fasta
tar xvfz V_cholerae_HiSeq.tar.gz sga_ctg.fasta
tar xvfz V_cholerae_HiSeq.tar.gz soap_ctg.fasta
tar xvfz V_cholerae_HiSeq.tar.gz spades_ctg.fasta
tar xvfz V_cholerae_HiSeq.tar.gz velvet_ctg.fasta

```

## VchoH: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=VchoH
QUEUE_NAME=mpi

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 4033464 \
    --trim2 "--uniq --shuffle --bbduk" \
    --cov2 "40 50 all" \
    --qual2 "25" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,2,3" \
    --insertsize \
    --parallel 24

# run
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_quast_competitor" \
    '
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
        7_mergeAnchors/anchor.merge.fasta \
        7_mergeAnchors/others.non-contained.fasta \
        1_genome/paralogs.fas \
        --label "abyss,cabog,mira,msrca,sga,soap,spades,velvet,merge,others,paralogs" \
        -o 9_quast_competitor
    '

```

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 246.4 |    193 | 1280.3 |                         46.93% |
| tadpole.bbtools | 196.5 |    189 |   53.4 |                         39.73% |
| genome.picard   | 199.2 |    193 |   47.4 |                             FR |
| tadpole.picard  | 193.5 |    188 |   44.6 |                             FR |

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 2961149 | 4033464 |       2 |
| Paralogs |    3483 |  114707 |      48 |
| Illumina |     100 | 392.01M | 3920090 |
| uniq     |     100 |  362.9M | 3629044 |
| shuffle  |     100 |  362.9M | 3629044 |
| bbduk    |     100 | 362.48M | 3625978 |
| Q20L60   |     100 | 362.46M | 3625404 |
| Q25L60   |     100 | 362.46M | 3625404 |
| Q30L60   |     100 | 362.46M | 3625404 |


| Name         | N50 |     Sum |       # |
|:-------------|----:|--------:|--------:|
| clumped      | 100 | 339.74M | 3397370 |
| trimmed      | 100 | 268.31M | 2839936 |
| filtered     | 100 |  268.3M | 2839788 |
| ecco         | 100 | 268.29M | 2839788 |
| eccc         | 100 | 268.29M | 2839788 |
| ecct         | 100 | 264.43M | 2797080 |
| extended     | 140 |  374.2M | 2797080 |
| merged       | 237 | 317.45M | 1345851 |
| unmerged.raw | 139 |  13.22M |  105378 |
| unmerged     | 139 |  10.84M |   89004 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 158.3 |    161 |  18.3 |         29.81% |
| ihist.merge.txt  | 235.9 |    231 |  41.5 |         96.23% |

```text
#mergeReads
#Matched	148	0.00521%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	148	0.00521%
```

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 |  89.9 |   56.9 |   36.72% |      99 | "71" | 4.03M | 4.05M |     1.00 | 0:00'45'' |


| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  83.42% |      2292 |    3M | 1428 |      1029 | 485.48K | 4135 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'47'' |
| Q25L60X50P000  |   50.0 |  80.82% |      2225 | 2.89M | 1421 |      1028 | 419.04K | 3851 |   46.0 | 5.0 |  10.3 |  91.5 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'45'' |
| Q25L60XallP000 |   56.9 |  79.01% |      2131 | 2.82M | 1407 |      1025 | 380.56K | 3689 |   52.0 | 6.0 |  11.3 | 104.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'43'' |

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  90.88% |      3305 | 3.38M | 1251 |      1023 | 437.57K | 4007 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'30'' | 0:00'51'' |
| Q25L60X50P000  |   50.0 |  89.85% |      3123 | 3.43M | 1342 |      1011 | 332.99K | 4151 |   47.0 | 6.0 |   9.7 |  94.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'50'' |
| Q25L60XallP000 |   56.9 |  89.25% |      2953 | 3.38M | 1365 |      1015 | 373.09K | 4191 |   53.0 | 6.0 |  11.7 | 106.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'51'' |


| Name                           |     N50 |     Sum |    # |
|:-------------------------------|--------:|--------:|-----:|
| Genome                         | 2961149 | 4033464 |    2 |
| Paralogs                       |    3483 |  114707 |   48 |
| 7_mergeKunitigsAnchors.anchors |    2500 | 3339437 | 1490 |
| 7_mergeKunitigsAnchors.others  |    1074 |  457162 |  397 |
| 7_mergeTadpoleAnchors.anchors  |    3712 | 3762024 | 1296 |
| 7_mergeTadpoleAnchors.others   |    1077 |  658948 |  565 |
| 7_mergeAnchors.anchors         |    3712 | 3762024 | 1296 |
| 7_mergeAnchors.others          |    1077 |  658948 |  565 |
| tadpole.Q25L60                 |    1097 | 4002159 | 5371 |
| spades.contig                  |  198954 | 3957851 |  185 |
| spades.scaffold                |  246583 | 3958051 |  183 |
| spades.non-contained           |  198954 | 3923463 |   63 |
| spades.anchor                  |  198548 | 3840581 |  154 |
| megahit.contig                 |  129196 | 3950124 |  199 |
| megahit.non-contained          |  129196 | 3904031 |   95 |
| megahit.anchor                 |   71373 | 3811565 |  210 |
| platanus.contig                |    6727 | 4047627 | 2326 |
| platanus.scaffold              |  117300 | 3910902 |  196 |
| platanus.non-contained         |  117300 | 3875124 |   97 |
| platanus.anchor                |   58978 | 3706701 |  351 |

# *Rhodobacter sphaeroides* 2.4.1 Full

## RsphF: download

* Reference genome

```bash
mkdir -p ${HOME}/data/anchr/RsphF
cd ${HOME}/data/anchr/RsphF

mkdir -p 1_genome
cd 1_genome

cp ~/data/anchr/Rsph/1_genome/genome.fa .
cp ~/data/anchr/Rsph/1_genome/paralogs.fas .

```

* Illumina

    SRX160386, SRR522246

```bash
cd ${HOME}/data/anchr/RsphF

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
cd ${HOME}/data/anchr/RsphF

mkdir -p 8_competitor
cd 8_competitor

cp ~/data/anchr/Rsph/8_competitor/* .

```

## RsphF: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=RsphF
QUEUE_NAME=mpi

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 4602977 \
    --trim2 "--uniq --shuffle --bbduk" \
    --cov2 "40 80" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,3" \
    --insertsize \
    --parallel 24

# run
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_quast_competitor" \
    '
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
        7_mergeAnchors/anchor.merge.fasta \
        7_mergeAnchors/others.non-contained.fasta \
        1_genome/paralogs.fas \
        --label "abyss,cabog,mira,msrca,sga,soap,spades,velvet,merge,others,paralogs" \
        -o 9_quast_competitor
    '

```

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 461.0 |    422 | 1286.1 |                         17.09% |
| tadpole.bbtools | 406.2 |    420 |   63.6 |                         32.72% |
| genome.picard   | 413.0 |    422 |   39.3 |                             FR |
| tadpole.picard  | 407.6 |    421 |   47.5 |                             FR |

| Name     |     N50 |     Sum |        # |
|:---------|--------:|--------:|---------:|
| Genome   | 3188524 | 4602977 |        7 |
| Paralogs |    2337 |  147155 |       66 |
| Illumina |     251 |   4.24G | 16881336 |
| uniq     |     251 |    4.2G | 16731106 |
| shuffle  |     251 |    4.2G | 16731106 |
| bbduk    |     250 |    3.9G | 15985914 |
| Q20L60   |     144 |   1.63G | 12042806 |
| Q25L60   |     133 |   1.35G | 10804424 |
| Q30L60   |     116 |   1.18G | 10785603 |

| Name         | N50 |     Sum |        # |
|:-------------|----:|--------:|---------:|
| clumped      | 251 |   4.19G | 16706344 |
| trimmed      | 149 |    1.7G | 12278084 |
| filtered     | 149 |    1.7G | 12278054 |
| ecco         | 149 |    1.7G | 12278054 |
| ecct         | 149 |   1.69G | 12180748 |
| extended     | 187 |   2.17G | 12180748 |
| merged       | 459 |   2.06G |  4874830 |
| unmerged.raw | 157 | 364.01M |  2431088 |
| unmerged     | 142 | 262.93M |  1999448 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 189.2 |    185 |  65.3 |         10.72% |
| ihist.merge.txt  | 421.6 |    457 |  87.1 |         80.04% |

```text
#mergeReads
#Matched	16	0.00013%
#Name	Reads	ReadsPct
```

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q20L60 | 353.5 |  318.9 |    9.77% |     136 | "37" |  4.6M | 5.07M |     1.10 | 0:02'57'' |
| Q25L60 | 294.3 |  281.5 |    4.34% |     126 | "35" |  4.6M | 4.59M |     1.00 | 0:02'32'' |
| Q30L60 | 256.6 |  250.9 |    2.22% |     111 | "31" |  4.6M | 4.55M |     0.99 | 0:02'16'' |


| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000 |   40.0 |  89.29% |      5742 | 3.97M |  955 |      1438 | 523.44K | 3288 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'55'' |
| Q20L60X40P001 |   40.0 |  89.15% |      5944 | 3.98M |  925 |      1453 | 482.98K | 3154 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'53'' |
| Q20L60X40P002 |   40.0 |  88.73% |      6117 | 3.97M |  914 |      1440 |  479.1K | 3149 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'53'' |
| Q20L60X40P003 |   40.0 |  89.00% |      6130 | 3.98M |  923 |      1481 |  462.9K | 3145 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'53'' |
| Q20L60X40P004 |   40.0 |  89.23% |      6120 |    4M |  927 |      1329 | 486.92K | 3228 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'54'' |
| Q20L60X40P005 |   40.0 |  89.01% |      5809 | 3.97M |  944 |      1361 | 489.63K | 3236 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'55'' |
| Q20L60X40P006 |   40.0 |  89.51% |      5994 | 3.97M |  934 |      1420 | 494.47K | 3108 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'52'' |
| Q20L60X80P000 |   80.0 |  75.47% |      2689 |  3.5M | 1474 |      1036 | 384.59K | 3764 |   65.0 | 6.0 |  15.7 | 124.5 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'48'' |
| Q20L60X80P001 |   80.0 |  74.92% |      2703 |  3.5M | 1466 |      1032 | 370.64K | 3727 |   64.0 | 6.0 |  15.3 | 123.0 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'49'' |
| Q20L60X80P002 |   80.0 |  75.10% |      2790 | 3.48M | 1441 |      1040 | 401.74K | 3678 |   64.0 | 6.0 |  15.3 | 123.0 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'49'' |
| Q25L60X40P000 |   40.0 |  97.80% |     17890 | 4.05M |  413 |      4002 | 649.07K | 1596 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'54'' |
| Q25L60X40P001 |   40.0 |  97.84% |     18875 | 4.06M |  391 |      4706 | 677.41K | 1541 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'55'' |
| Q25L60X40P002 |   40.0 |  97.95% |     19132 | 4.05M |  386 |      4739 | 682.43K | 1515 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'55'' |
| Q25L60X40P003 |   40.0 |  97.81% |     19292 | 4.05M |  392 |      4602 | 662.97K | 1560 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'55'' |
| Q25L60X40P004 |   40.0 |  97.64% |     17375 | 4.05M |  404 |      4512 |  655.5K | 1552 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'55'' |
| Q25L60X40P005 |   40.0 |  97.98% |     16232 | 4.05M |  422 |      4069 | 735.64K | 1666 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'56'' |
| Q25L60X40P006 |   40.0 |  98.12% |     17071 | 4.05M |  418 |      5139 | 699.67K | 1590 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'56'' |
| Q25L60X80P000 |   80.0 |  96.92% |     18974 | 4.08M |  361 |      2963 | 616.37K | 1677 |   70.0 | 6.0 |  17.3 | 132.0 | "31,41,51,61,71,81" | 0:01'35'' | 0:01'01'' |
| Q25L60X80P001 |   80.0 |  96.76% |     20128 | 4.08M |  362 |      3443 | 590.22K | 1621 |   70.0 | 6.0 |  17.3 | 132.0 | "31,41,51,61,71,81" | 0:01'21'' | 0:00'58'' |
| Q25L60X80P002 |   80.0 |  96.82% |     17703 | 4.07M |  385 |      2900 | 581.21K | 1657 |   70.0 | 6.0 |  17.3 | 132.0 | "31,41,51,61,71,81" | 0:01'21'' | 0:01'00'' |
| Q30L60X40P000 |   40.0 |  98.29% |     10805 | 3.95M |  575 |      6192 | 824.87K | 1707 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'51'' |
| Q30L60X40P001 |   40.0 |  98.33% |     10532 |    4M |  560 |      5240 | 693.71K | 1679 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'52'' |
| Q30L60X40P002 |   40.0 |  98.27% |     12311 | 3.97M |  550 |      7247 | 774.79K | 1671 |   34.5 | 3.5 |   8.0 |  67.5 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'53'' |
| Q30L60X40P003 |   40.0 |  98.24% |     11530 | 4.01M |  562 |      6307 | 742.57K | 1675 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'52'' |
| Q30L60X40P004 |   40.0 |  98.29% |     12030 |    4M |  555 |      7430 | 781.63K | 1693 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'53'' |
| Q30L60X40P005 |   40.0 |  97.98% |      2085 | 2.64M | 1311 |      1894 |   2.34M | 2622 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'50'' |
| Q30L60X80P000 |   80.0 |  98.62% |     16612 | 4.04M |  422 |      6300 | 720.03K | 1398 |   70.0 | 7.0 |  16.3 | 136.5 | "31,41,51,61,71,81" | 0:01'15'' | 0:00'55'' |
| Q30L60X80P001 |   80.0 |  98.62% |     18647 | 4.04M |  402 |      7168 |  781.9K | 1418 |   70.0 | 7.0 |  16.3 | 136.5 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'59'' |
| Q30L60X80P002 |   80.0 |  98.67% |     15442 | 3.89M |  512 |      7470 |   1.02M | 1517 |   70.0 | 3.0 |  20.0 | 118.5 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'56'' |

| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000 |   40.0 |  97.74% |     18823 | 4.06M |  375 |      7795 | 788.78K | 1423 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'56'' |
| Q20L60X40P001 |   40.0 |  97.75% |     17924 | 4.03M |  376 |      6684 | 785.93K | 1524 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'56'' |
| Q20L60X40P002 |   40.0 |  97.89% |     17902 | 4.05M |  378 |      6634 | 768.02K | 1487 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'55'' |
| Q20L60X40P003 |   40.0 |  97.83% |     18427 | 4.06M |  387 |      6863 | 727.95K | 1473 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'56'' |
| Q20L60X40P004 |   40.0 |  97.72% |     18001 | 4.07M |  378 |      7447 | 837.45K | 1478 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'56'' |
| Q20L60X40P005 |   40.0 |  97.80% |     18937 | 4.05M |  375 |      7427 | 824.76K | 1530 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'58'' |
| Q20L60X40P006 |   40.0 |  97.80% |     17600 | 4.07M |  384 |      6319 | 764.18K | 1506 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'55'' |
| Q20L60X80P000 |   80.0 |  97.73% |     18103 | 4.08M |  382 |      5858 | 802.05K | 1785 |   68.0 | 5.0 |  17.7 | 124.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:01'03'' |
| Q20L60X80P001 |   80.0 |  97.92% |     19483 | 4.07M |  358 |      4766 | 809.51K | 1762 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:01'03'' |
| Q20L60X80P002 |   80.0 |  97.74% |     17919 | 4.09M |  373 |      5158 | 730.86K | 1768 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:01'00'' |
| Q25L60X40P000 |   40.0 |  98.26% |     11920 |    4M |  521 |      6700 |  742.7K | 1638 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'52'' |
| Q25L60X40P001 |   40.0 |  98.22% |     12521 | 3.99M |  510 |      8086 | 759.32K | 1638 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'53'' |
| Q25L60X40P002 |   40.0 |  98.33% |     14365 | 4.04M |  483 |      8625 | 656.81K | 1536 |   34.5 | 3.5 |   8.0 |  67.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'54'' |
| Q25L60X40P003 |   40.0 |  98.29% |     13550 |    4M |  509 |      7543 | 829.27K | 1617 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'53'' |
| Q25L60X40P004 |   40.0 |  98.29% |     13614 | 4.01M |  491 |      9083 | 767.49K | 1641 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'53'' |
| Q25L60X40P005 |   40.0 |  98.32% |     13440 | 4.01M |  497 |      6916 | 772.16K | 1621 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'55'' |
| Q25L60X40P006 |   40.0 |  98.31% |     12314 | 4.02M |  504 |      8080 | 747.62K | 1617 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'54'' |
| Q25L60X80P000 |   80.0 |  98.58% |     20545 | 4.05M |  325 |      9577 | 707.72K | 1264 |   70.0 | 5.0 |  18.3 | 127.5 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'57'' |
| Q25L60X80P001 |   80.0 |  98.66% |     21827 | 4.05M |  318 |      9311 | 734.53K | 1274 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'59'' |
| Q25L60X80P002 |   80.0 |  98.63% |     22201 | 4.05M |  334 |      9339 | 735.62K | 1289 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'57'' |
| Q30L60X40P000 |   40.0 |  97.57% |      7709 |  3.9M |  752 |      5164 | 772.48K | 2061 |   34.0 | 4.0 |   7.3 |  68.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'50'' |
| Q30L60X40P001 |   40.0 |  97.79% |      7678 | 3.93M |  754 |      5212 |  769.1K | 2085 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'52'' |
| Q30L60X40P002 |   40.0 |  97.58% |      7954 |  3.9M |  755 |      6263 | 824.51K | 2067 |   34.0 | 4.0 |   7.3 |  68.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'51'' |
| Q30L60X40P003 |   40.0 |  97.59% |      7700 | 3.92M |  749 |      6105 | 805.96K | 2094 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'51'' |
| Q30L60X40P004 |   40.0 |  97.49% |      7524 | 3.91M |  755 |      5879 | 709.18K | 2077 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'50'' |
| Q30L60X40P005 |   40.0 |  96.64% |      2049 | 2.56M | 1290 |      1679 |   2.24M | 2819 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'49'' |
| Q30L60X80P000 |   80.0 |  98.45% |     11537 |    4M |  530 |      6547 |  810.9K | 1662 |   70.0 | 7.0 |  16.3 | 136.5 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'55'' |
| Q30L60X80P001 |   80.0 |  98.41% |     12325 |    4M |  513 |      7413 | 798.95K | 1643 |   70.0 | 7.0 |  16.3 | 136.5 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'57'' |
| Q30L60X80P002 |   80.0 |  98.54% |     13446 | 3.85M |  601 |      7437 |   1.06M | 1718 |   70.0 | 3.0 |  20.0 | 118.5 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'55'' |

| Name                           |     N50 |     Sum |    # |
|:-------------------------------|--------:|--------:|-----:|
| Genome                         | 3188524 | 4602977 |    7 |
| Paralogs                       |    2337 |  147155 |   66 |
| 7_mergeKunitigsAnchors.anchors |   55617 | 4238323 |  250 |
| 7_mergeKunitigsAnchors.others  |    1942 | 3294180 | 1844 |
| 7_mergeTadpoleAnchors.anchors  |   52328 | 4282818 |  249 |
| 7_mergeTadpoleAnchors.others   |    2057 | 3812397 | 2012 |
| 7_mergeAnchors.anchors         |   52328 | 4282818 |  249 |
| 7_mergeAnchors.others          |    2057 | 3813456 | 2013 |
| tadpole.Q20L60                 |    7739 | 4536125 | 1274 |
| tadpole.Q25L60                 |   13537 | 4524004 |  827 |
| tadpole.Q30L60                 |   11850 | 4523672 |  926 |
| spades.contig                  |  315956 | 4588009 |  122 |
| spades.scaffold                |  333463 | 4588229 |  118 |
| spades.non-contained           |  315956 | 4566180 |   48 |
| spades.anchor                  |  315854 | 4183548 |   81 |
| megahit.contig                 |   97442 | 4577412 |  209 |
| megahit.non-contained          |   97442 | 4542531 |  134 |
| megahit.anchor                 |  117264 | 4116703 |  132 |
| platanus.contig                |    6239 | 4729176 | 2060 |
| platanus.scaffold              |  128429 | 4661947 |  946 |
| platanus.non-contained         |  130274 | 4545102 |  103 |
| platanus.anchor                |  130261 | 4409556 |   82 |

# *Mycobacterium abscessus* 6G-0125-R Full

## MabsF: download

* Reference genome

```bash
mkdir -p ${HOME}/data/anchr/MabsF
cd ${HOME}/data/anchr/MabsF

mkdir -p 1_genome
cd 1_genome

cp ~/data/anchr/Mabs/1_genome/genome.fa .
cp ~/data/anchr/Mabs/1_genome/paralogs.fas .

```

* Illumina

    SRX246890, SRR768269

```bash
cd ${HOME}/data/anchr/MabsF

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
cd ${HOME}/data/anchr/MabsF

mkdir -p 8_competitor
cd 8_competitor

cp ~/data/anchr/Mabs/8_competitor/* .

```

## MabsF: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=MabsF
QUEUE_NAME=mpi

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 5090491 \
    --trim2 "--uniq --shuffle --bbduk" \
    --cov2 "40 80" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,3" \
    --insertsize \
    --parallel 24

# run
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_quast_competitor" \
    '
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
        7_mergeAnchors/anchor.merge.fasta \
        7_mergeAnchors/others.non-contained.fasta \
        1_genome/paralogs.fas \
        --label "abyss,cabog,mira,msrca,sga,soap,spades,velvet,merge,others,paralogs" \
        -o 9_quast_competitor
    '

```

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 443.2 |    277 | 2401.1 |                          7.34% |
| tadpole.bbtools | 263.4 |    264 |   49.5 |                         33.66% |
| genome.picard   | 295.6 |    279 |   47.2 |                             FR |
| genome.picard   | 287.3 |    271 |   33.9 |                             RF |
| tadpole.picard  | 263.8 |    264 |   49.2 |                             FR |
| tadpole.picard  | 243.7 |    249 |   47.4 |                             RF |

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 5067172 | 5090491 |       2 |
| Paralogs |    1580 |   83364 |      53 |
| Illumina |     251 |   2.19G | 8741140 |
| uniq     |     251 |   2.19G | 8732398 |
| shuffle  |     251 |   2.19G | 8732398 |
| bbduk    |     197 |   1.65G | 8728430 |
| Q20L60   |     178 |   1.24G | 7514512 |
| Q25L60   |     173 |   1.07G | 6707252 |
| Q30L60   |     163 | 940.59M | 6410845 |


| Name         | N50 |     Sum |       # |
|:-------------|----:|--------:|--------:|
| clumped      | 251 |   2.17G | 8662194 |
| trimmed      | 176 |   1.32G | 8101585 |
| filtered     | 176 |   1.31G | 8079769 |
| ecco         | 173 |    1.3G | 8079768 |
| ecct         | 173 |   1.26G | 7863441 |
| extended     | 211 |   1.57G | 7863441 |
| merged       | 235 | 734.93M | 3151395 |
| unmerged.raw | 201 | 295.01M | 1560650 |
| unmerged     | 192 | 255.88M | 1463313 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 190.0 |    185 |  45.4 |         74.27% |
| ihist.merge.txt  | 233.2 |    226 |  51.7 |         80.15% |

```text
#mergeReads
#Matched	21816	0.26928%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	21770	0.26871%
```


| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q20L60 | 244.0 |  192.9 |   20.97% |     165 | "45" | 5.09M |  5.9M |     1.16 | 0:02'03'' |
| Q25L60 | 210.0 |  176.1 |   16.16% |     159 | "43" | 5.09M | 5.49M |     1.08 | 0:01'53'' |
| Q30L60 | 185.0 |  161.8 |   12.54% |     150 | "39" | 5.09M | 5.41M |     1.06 | 0:01'41'' |


| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000 |   40.0 |  76.37% |      2055 | 3.32M | 1711 |      1061 | 893.66K | 3888 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'45'' |
| Q20L60X40P001 |   40.0 |  75.87% |      2007 | 3.32M | 1748 |      1067 | 866.58K | 3960 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'45'' |
| Q20L60X40P002 |   40.0 |  76.54% |      1994 | 3.34M | 1746 |      1055 | 882.87K | 3976 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'45'' |
| Q20L60X40P003 |   40.0 |  76.06% |      2015 | 3.33M | 1756 |      1059 | 871.62K | 3948 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'45'' |
| Q20L60X80P000 |   80.0 |  46.94% |      1515 | 1.97M | 1297 |      1053 | 568.48K | 2968 |   66.0 | 6.0 |  16.0 | 126.0 | "31,41,51,61,71,81" | 0:01'30'' | 0:00'39'' |
| Q20L60X80P001 |   80.0 |  47.63% |      1517 | 2.02M | 1337 |      1038 | 560.29K | 3037 |   66.0 | 6.0 |  16.0 | 126.0 | "31,41,51,61,71,81" | 0:01'29'' | 0:00'40'' |
| Q25L60X40P000 |   40.0 |  95.72% |      5804 | 4.73M | 1159 |       891 | 428.95K | 2752 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'53'' |
| Q25L60X40P001 |   40.0 |  95.55% |      6365 | 4.69M | 1130 |       920 | 456.24K | 2704 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'52'' |
| Q25L60X40P002 |   40.0 |  95.63% |      6195 |  4.7M | 1152 |       938 | 449.15K | 2736 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'54'' |
| Q25L60X40P003 |   40.0 |  95.71% |      5714 | 4.73M | 1173 |       865 | 442.11K | 2790 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'54'' |
| Q25L60X80P000 |   80.0 |  90.27% |      3362 |  4.3M | 1581 |      1014 | 603.99K | 3467 |   72.0 | 5.0 |  19.0 | 130.5 | "31,41,51,61,71,81" | 0:01'31'' | 0:00'50'' |
| Q25L60X80P001 |   80.0 |  89.88% |      3469 | 4.41M | 1554 |       978 | 456.15K | 3412 |   72.0 | 6.0 |  18.0 | 135.0 | "31,41,51,61,71,81" | 0:01'30'' | 0:00'51'' |
| Q30L60X40P000 |   40.0 |  97.39% |      7320 | 4.77M | 1041 |       910 | 538.82K | 2881 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'58'' |
| Q30L60X40P001 |   40.0 |  97.35% |      7388 | 4.75M | 1062 |       934 | 533.12K | 2832 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'56'' |
| Q30L60X40P002 |   40.0 |  97.28% |      7003 | 4.76M | 1047 |       995 | 524.98K | 2855 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'55'' |
| Q30L60X40P003 |   40.0 |  98.46% |     12711 | 4.94M |  682 |      1010 | 302.25K | 2038 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:01'01'' |
| Q30L60X80P000 |   80.0 |  94.24% |      4152 | 4.52M | 1419 |       974 | 589.17K | 3230 |   74.0 | 5.0 |  19.7 | 133.5 | "31,41,51,61,71,81" | 0:01'27'' | 0:01'13'' |
| Q30L60X80P001 |   80.0 |  95.59% |      5760 | 4.78M | 1164 |       958 |  339.8K | 2786 |   74.0 | 4.0 |  20.0 | 129.0 | "31,41,51,61,71,81" | 0:01'26'' | 0:01'11'' |

| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000 |   40.0 |  97.50% |     10108 | 4.75M |  894 |       979 | 624.53K | 2427 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'58'' |
| Q20L60X40P001 |   40.0 |  97.51% |     10203 | 4.78M |  880 |      1003 | 601.58K | 2430 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:01'00'' |
| Q20L60X40P002 |   40.0 |  97.54% |     10770 | 4.78M |  888 |      1017 | 643.39K | 2447 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'58'' |
| Q20L60X40P003 |   40.0 |  97.56% |     10287 | 4.79M |  875 |      1001 | 599.73K | 2371 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'58'' |
| Q20L60X80P000 |   80.0 |  94.70% |      5592 | 4.77M | 1177 |       884 | 436.19K | 3086 |   73.0 | 5.0 |  19.3 | 132.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'56'' |
| Q20L60X80P001 |   80.0 |  94.46% |      5545 | 4.75M | 1229 |       813 | 432.74K | 3164 |   73.0 | 5.0 |  19.3 | 132.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'55'' |
| Q25L60X40P000 |   40.0 |  98.80% |     18569 | 4.89M |  652 |       943 | 485.11K | 1929 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:01'01'' |
| Q25L60X40P001 |   40.0 |  98.85% |     22176 | 4.89M |  571 |      1003 | 429.81K | 1815 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:01'00'' |
| Q25L60X40P002 |   40.0 |  98.83% |     18723 | 4.87M |  639 |      1039 | 503.24K | 1956 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:01'00'' |
| Q25L60X40P003 |   40.0 |  98.81% |     20236 | 4.88M |  591 |       962 | 462.48K | 1894 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:01'02'' |
| Q25L60X80P000 |   80.0 |  98.16% |     12527 | 4.96M |  661 |       720 | 261.13K | 1958 |   76.0 | 4.0 |  20.0 | 132.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'59'' |
| Q25L60X80P001 |   80.0 |  98.04% |     12039 | 4.96M |  703 |       961 | 301.45K | 1977 |   76.0 | 4.0 |  20.0 | 132.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'59'' |
| Q30L60X40P000 |   40.0 |  98.96% |     14106 | 4.73M |  864 |      1030 | 683.25K | 2270 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:01'01'' |
| Q30L60X40P001 |   40.0 |  98.98% |     12722 | 4.71M |  833 |      1098 | 729.85K | 2231 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'59'' |
| Q30L60X40P002 |   40.0 |  98.95% |      9952 | 4.74M |  942 |      1061 | 742.43K | 2520 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:01'02'' |
| Q30L60X40P003 |   40.0 |  99.31% |     26478 | 4.96M |  471 |      1023 | 318.63K | 1415 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:01'00'' |
| Q30L60X80P000 |   80.0 |  98.57% |     13078 | 4.92M |  692 |       931 | 374.63K | 2122 |   76.0 | 4.0 |  20.0 | 132.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:01'02'' |
| Q30L60X80P001 |   80.0 |  98.88% |     19572 | 5.07M |  413 |       526 | 123.13K | 1480 |   76.0 | 4.0 |  20.0 | 132.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:01'02'' |

| Name                           |     N50 |     Sum |    # |
|:-------------------------------|--------:|--------:|-----:|
| Genome                         | 5067172 | 5090491 |    2 |
| Paralogs                       |    1580 |   83364 |   53 |
| 7_mergeKunitigsAnchors.anchors |   68014 | 5162923 |  153 |
| 7_mergeKunitigsAnchors.others  |    1219 | 3740446 | 3085 |
| 7_mergeTadpoleAnchors.anchors  |  131245 | 5122968 |   84 |
| 7_mergeTadpoleAnchors.others   |    1343 | 5150661 | 3905 |
| 7_mergeAnchors.anchors         |  131245 | 5122968 |   84 |
| 7_mergeAnchors.others          |    1343 | 5150661 | 3905 |
| tadpole.Q20L60                 |    5744 | 5487000 | 3197 |
| tadpole.Q25L60                 |    7433 | 5457978 | 2834 |
| tadpole.Q30L60                 |    5651 | 5410001 | 2875 |
| spades.contig                  |  261101 | 5601697 | 1066 |
| spades.scaffold                |  365083 | 5601847 | 1060 |
| spades.non-contained           |  278455 | 5140010 |   40 |
| spades.anchor                  |   16079 | 4988621 |  526 |
| megahit.contig                 |  116930 | 5251279 |  405 |
| megahit.non-contained          |  116930 | 5125565 |   73 |
| megahit.anchor                 |   67433 | 5002487 |  413 |
| platanus.contig                |   24766 | 5179989 |  499 |
| platanus.scaffold              |   94955 | 5139198 |  125 |
| platanus.non-contained         |   94955 | 5129046 |   98 |
| platanus.anchor                |   46384 | 5004003 |  443 |


# *Vibrio cholerae* CP1032(5) Full

## VchoF: download

* Settings

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=VchoF

```

* Reference genome

```bash
mkdir -p ${HOME}/data/anchr/VchoF
cd ${HOME}/data/anchr/VchoF

mkdir -p 1_genome
cd 1_genome

cp ~/data/anchr/Vcho/1_genome/genome.fa .
cp ~/data/anchr/Vcho/1_genome/paralogs.fas .

```

* Illumina

    SRX247310, SRR769320

```bash
cd ${HOME}/data/anchr/VchoF

mkdir -p 2_illumina
cd 2_illumina

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
cd ${HOME}/data/anchr/VchoF

mkdir -p 8_competitor
cd 8_competitor

cp ~/data/anchr/Vcho/8_competitor/* .

```

## VchoF: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=VchoF
QUEUE_NAME=mpi

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 4033464 \
    --trim2 "--uniq --shuffle --bbduk" \
    --cov2 "40 80" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,3" \
    --insertsize \
    --parallel 24

# run
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_quast_competitor" \
    '
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
        7_mergeAnchors/anchor.merge.fasta \
        7_mergeAnchors/others.non-contained.fasta \
        1_genome/paralogs.fas \
        --label "abyss,cabog,mira,msrca,sga,soap,spades,velvet,merge,others,paralogs" \
        -o 9_quast_competitor
    '

```

Table: statInsertSize

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 406.3 |    274 | 2047.0 |                          8.47% |
| tadpole.bbtools | 274.6 |    269 |   54.1 |                         43.03% |
| genome.picard   | 293.8 |    277 |   47.8 |                             FR |
| genome.picard   | 280.5 |    268 |   29.3 |                             RF |
| tadpole.picard  | 275.2 |    270 |   46.1 |                             FR |
| tadpole.picard  | 268.0 |    267 |   42.3 |                             RF |


Table: statReads

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 2961149 | 4033464 |       2 |
| Paralogs |    3483 |  114707 |      48 |
| Illumina |     251 |   1.76G | 7020550 |
| uniq     |     251 |   1.73G | 6883592 |
| shuffle  |     251 |   1.73G | 6883592 |
| bbduk    |     199 |   1.33G | 6878250 |
| Q20L60   |     191 |   1.22G | 6691188 |
| Q25L60   |     187 |   1.14G | 6409224 |
| Q30L60   |     181 |  997.2M | 5862451 |

```text
#trimmedReads
#Matched        5581849 81.08919%
#Name   Reads   ReadsPct
truseq-forward-contam   2686504 39.02765%
solexa-forward  2608264 37.89103%
Illumina_Multiplexing_Index_Sequencing_Primer   129274  1.87800%
Illumina_Paired_End_Adapter_2   86656   1.25888%
Illumina_Paried_End_PCR_Primer_1        49649   0.72127%
truseq-reverse-contam   5540    0.08048%
Illumina_PCR_Primer_Index_1     3679    0.05345%
TruSeq_Adapter_Index_5  3279    0.04764%
TruSeq_Adapter_Index_1  2830    0.04111%
solexa-reverse  1728    0.02510%
Illumina_PCR_Primer_Index_2     1257    0.01826%
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 251 |   1.73G | 6883006 |
| trimmed       | 189 |   1.22G | 6751634 |
| filtered      | 188 |   1.21G | 6713772 |
| ecco          | 186 |    1.2G | 6713772 |
| ecct          | 185 |   1.18G | 6625802 |
| extended      | 224 |   1.44G | 6625802 |
| merged        | 237 | 686.39M | 2878382 |
| unmerged.raw  | 214 | 179.41M |  869038 |
| unmerged.trim | 209 | 165.72M |  842534 |
| U1            | 208 |  48.93M |  247961 |
| U2            | 200 |  47.11M |  247961 |
| Us            | 215 |  69.68M |  346612 |
| pe.cor        | 232 | 855.33M | 6945910 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 195.8 |    190 |  43.5 |         83.09% |
| ihist.merge.txt  | 238.5 |    230 |  51.3 |         86.88% |

```text
#trimmedReads
#Matched        5589809 81.21174%
#Name   Reads   ReadsPct
Reverse_adapter 2713329 39.42070%
pcr_dimer       1554664 22.58699%
PCR_Primers     797469  11.58606%
TruSeq_Universal_Adapter        219469  3.18856%
TruSeq_Adapter_Index_1_6        203266  2.95316%
Nextera_LMP_Read2_External_Adapter      83758   1.21688%
TruSeq_Adapter_Index_5  3286    0.04774%
RNA_PCR_Primer_Index_36_(RPI36) 2773    0.04029%
Bisulfite_R2    1704    0.02476%
PhiX_read2_adapter      1377    0.02001%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N705        1329    0.01931%
TruSeq_Adapter_Index_11 1087    0.01579%
```

```text
#filteredReads
#Matched        37862   0.56078%
#Name   Reads   ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome  37661   0.55781%
Reverse_adapter 188     0.00278%
```


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q20L60 | 302.5 |  248.3 |   17.92% |     183 | "111" | 4.03M | 4.59M |     1.14 | 0:02'10'' |
| Q25L60 | 282.3 |  243.5 |   13.75% |     179 | "109" | 4.03M |  4.4M |     1.09 | 0:02'07'' |
| Q30L60 | 247.3 |  221.1 |   10.61% |     173 | "103" | 4.03M | 4.15M |     1.03 | 0:01'53'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000 |   40.0 |  79.75% |      2724 | 3.03M | 1281 |      1028 | 388.88K | 2755 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'35'' |
| Q20L60X40P001 |   40.0 |  79.21% |      2789 | 2.99M | 1252 |      1058 | 410.88K | 2710 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'35'' |
| Q20L60X40P002 |   40.0 |  79.45% |      2660 | 3.02M | 1276 |      1035 | 387.93K | 2743 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'37'' |
| Q20L60X40P003 |   40.0 |  79.62% |      2645 | 3.01M | 1293 |      1041 | 417.26K | 2824 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'36'' |
| Q20L60X40P004 |   40.0 |  79.15% |      2713 |    3M | 1275 |      1041 | 381.33K | 2750 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'36'' |
| Q20L60X40P005 |   40.0 |  78.88% |      2670 | 3.01M | 1278 |      1028 | 376.27K | 2746 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'35'' |
| Q20L60X80P000 |   80.0 |  60.24% |      1767 | 2.23M | 1289 |      1036 | 387.75K | 2771 |   68.0 | 8.0 |  14.7 | 136.0 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'34'' |
| Q20L60X80P001 |   80.0 |  60.28% |      1821 | 2.19M | 1235 |      1043 |  434.6K | 2708 |   67.0 | 8.0 |  14.3 | 134.0 | "31,41,51,61,71,81" | 0:01'08'' | 0:00'35'' |
| Q20L60X80P002 |   80.0 |  59.97% |      1817 | 2.21M | 1250 |      1028 | 401.38K | 2717 |   67.0 | 8.0 |  14.3 | 134.0 | "31,41,51,61,71,81" | 0:01'08'' | 0:00'32'' |
| Q25L60X40P000 |   40.0 |  83.50% |      3020 |  3.2M | 1249 |      1038 | 348.55K | 2722 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'36'' |
| Q25L60X40P001 |   40.0 |  83.22% |      3005 | 3.13M | 1223 |      1041 | 413.73K | 2646 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'38'' |
| Q25L60X40P002 |   40.0 |  83.56% |      3004 | 3.16M | 1235 |      1038 | 389.22K | 2669 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'37'' |
| Q25L60X40P003 |   40.0 |  83.35% |      3058 | 3.14M | 1201 |      1040 | 391.64K | 2592 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'35'' |
| Q25L60X40P004 |   40.0 |  83.22% |      3001 | 3.16M | 1229 |      1019 | 368.77K | 2652 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'36'' |
| Q25L60X40P005 |   40.0 |  83.62% |      3019 | 3.18M | 1223 |      1039 | 372.14K | 2665 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'37'' |
| Q25L60X80P000 |   80.0 |  68.14% |      2038 | 2.55M | 1324 |      1032 |  389.1K | 2869 |   69.0 | 8.0 |  15.0 | 138.0 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'35'' |
| Q25L60X80P001 |   80.0 |  68.72% |      2021 | 2.56M | 1343 |      1039 | 392.46K | 2885 |   69.0 | 8.0 |  15.0 | 138.0 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'34'' |
| Q25L60X80P002 |   80.0 |  69.17% |      2092 | 2.64M | 1356 |      1027 | 330.93K | 2882 |   69.0 | 9.0 |  14.0 | 138.0 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'35'' |
| Q30L60X40P000 |   40.0 |  93.57% |      6884 | 3.64M |  775 |      1016 | 220.89K | 1675 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'40'' |
| Q30L60X40P001 |   40.0 |  93.12% |      7366 | 3.63M |  745 |      1032 | 205.78K | 1632 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'40'' |
| Q30L60X40P002 |   40.0 |  93.23% |      7237 |  3.6M |  736 |      1065 | 248.34K | 1634 |   36.0 | 4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'39'' |
| Q30L60X40P003 |   40.0 |  93.16% |      6749 | 3.59M |  794 |      1056 | 260.48K | 1678 |   36.0 | 4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'38'' |
| Q30L60X40P004 |   40.0 |  93.51% |      7176 | 3.65M |  748 |       970 |  201.9K | 1628 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'38'' |
| Q30L60X80P000 |   80.0 |  88.97% |      4340 | 3.49M | 1038 |      1006 |  219.5K | 2157 |   73.0 | 9.0 |  15.3 | 146.0 | "31,41,51,61,71,81" | 0:01'08'' | 0:00'38'' |
| Q30L60X80P001 |   80.0 |  88.97% |      4187 | 3.49M | 1063 |      1024 | 233.87K | 2199 |   73.0 | 9.0 |  15.3 | 146.0 | "31,41,51,61,71,81" | 0:01'08'' | 0:00'38'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000 |   40.0 |  95.75% |     16420 | 3.71M | 435 |      1137 | 214.43K | 1120 |   35.0 |  5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'41'' |
| Q20L60X40P001 |   40.0 |  95.92% |     16497 | 3.75M | 426 |      1031 |  172.4K | 1068 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'41'' |
| Q20L60X40P002 |   40.0 |  95.65% |     17764 | 3.76M | 386 |      1060 | 163.39K | 1025 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'40'' |
| Q20L60X40P003 |   40.0 |  95.97% |     17667 | 3.74M | 401 |      1058 | 184.26K | 1068 |   36.0 |  4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'42'' |
| Q20L60X40P004 |   40.0 |  96.07% |     19491 | 3.73M | 400 |      1401 | 234.45K | 1027 |   35.0 |  5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'41'' |
| Q20L60X40P005 |   40.0 |  95.96% |     18159 | 3.77M | 378 |      1128 |  178.4K | 1012 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'42'' |
| Q20L60X80P000 |   80.0 |  94.15% |      7826 | 3.72M | 687 |      1006 | 184.15K | 1752 |   73.0 | 10.0 |  14.3 | 146.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'42'' |
| Q20L60X80P001 |   80.0 |  94.08% |      7838 | 3.72M | 686 |      1015 | 194.77K | 1788 |   74.0 |  9.0 |  15.7 | 148.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'43'' |
| Q20L60X80P002 |   80.0 |  94.22% |      8193 | 3.74M | 683 |      1043 | 203.31K | 1774 |   74.0 | 10.0 |  14.7 | 148.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'42'' |
| Q25L60X40P000 |   40.0 |  96.25% |     17476 | 3.75M | 374 |      1025 | 153.93K | 1041 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'41'' |
| Q25L60X40P001 |   40.0 |  96.34% |     17264 | 3.76M | 396 |      1095 | 191.76K | 1020 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'41'' |
| Q25L60X40P002 |   40.0 |  96.34% |     18163 | 3.76M | 372 |      1020 | 148.78K |  955 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'42'' |
| Q25L60X40P003 |   40.0 |  96.37% |     16429 | 3.74M | 383 |      1076 | 187.76K |  979 |   36.0 |  4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'42'' |
| Q25L60X40P004 |   40.0 |  96.02% |     17789 | 3.76M | 387 |      1031 | 162.32K | 1019 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'42'' |
| Q25L60X40P005 |   40.0 |  96.37% |     16601 | 3.74M | 388 |      1046 | 195.94K | 1068 |   36.0 |  4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'42'' |
| Q25L60X80P000 |   80.0 |  94.88% |      8319 | 3.75M | 650 |       923 | 179.95K | 1706 |   74.0 | 10.0 |  14.7 | 148.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'42'' |
| Q25L60X80P001 |   80.0 |  95.16% |      9570 | 3.74M | 617 |      1033 | 198.47K | 1597 |   74.0 |  9.0 |  15.7 | 148.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'44'' |
| Q25L60X80P002 |   80.0 |  94.73% |      8653 | 3.74M | 648 |       950 | 184.04K | 1681 |   74.0 |  9.5 |  15.2 | 148.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'45'' |
| Q30L60X40P000 |   40.0 |  97.15% |     27655 | 3.77M | 290 |      1263 | 164.92K |  836 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'44'' |
| Q30L60X40P001 |   40.0 |  97.13% |     26060 | 3.77M | 304 |      1032 | 155.98K |  847 |   36.0 |  4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'41'' |
| Q30L60X40P002 |   40.0 |  97.14% |     25449 | 3.77M | 304 |      1113 |  179.9K |  881 |   36.0 |  4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'44'' |
| Q30L60X40P003 |   40.0 |  96.94% |     23096 | 3.73M | 347 |      1195 | 204.55K |  906 |   36.0 |  4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'42'' |
| Q30L60X40P004 |   40.0 |  97.17% |     27053 | 3.77M | 293 |      1177 | 153.11K |  837 |   36.0 |  4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'44'' |
| Q30L60X80P000 |   80.0 |  96.52% |     16230 | 3.79M | 403 |      1031 | 140.72K | 1059 |   74.5 |  9.5 |  15.3 | 149.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'44'' |
| Q30L60X80P001 |   80.0 |  96.41% |     16899 | 3.79M | 400 |      1035 | 134.94K | 1068 |   74.5 |  9.5 |  15.3 | 149.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'44'' |


Table: statMRKunitigsAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  95.75% |     18735 | 3.77M | 330 |      1121 | 121.59K |  734 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'41'' |
| MRX40P001 |   40.0 |  95.99% |     22471 | 3.78M | 289 |      1237 | 108.62K |  640 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'40'' |
| MRX40P002 |   40.0 |  95.97% |     20200 | 3.79M | 322 |      1022 |  96.57K |  700 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'39'' |
| MRX40P003 |   40.0 |  96.00% |     20563 | 3.79M | 329 |       974 | 105.07K |  737 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'40'' |
| MRX40P004 |   40.0 |  95.96% |     20128 | 3.77M | 317 |      1054 | 105.33K |  695 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'40'' |
| MRX80P000 |   80.0 |  93.50% |      9082 | 3.71M | 593 |       801 | 132.88K | 1234 |   73.0 | 9.0 |  15.3 | 146.0 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'41'' |
| MRX80P001 |   80.0 |  93.88% |      9703 | 3.72M | 590 |       781 | 128.26K | 1211 |   74.0 | 9.0 |  15.7 | 148.0 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'37'' |


Table: statMRTadpoleAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  97.36% |     70768 | 3.84M | 151 |      1177 | 57.06K | 349 |   35.0 |  7.0 |   4.7 |  70.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'43'' |
| MRX40P001 |   40.0 |  97.45% |     68965 | 3.84M | 138 |      1020 | 64.68K | 389 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'47'' |
| MRX40P002 |   40.0 |  97.32% |     70778 | 3.84M | 139 |      1065 | 59.25K | 362 |   35.0 |  6.0 |   5.7 |  70.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'43'' |
| MRX40P003 |   40.0 |  97.39% |     71360 | 3.83M | 143 |      1052 | 74.76K | 396 |   35.0 |  6.0 |   5.7 |  70.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'46'' |
| MRX40P004 |   40.0 |  97.41% |     74012 | 3.83M | 155 |      1052 | 72.04K | 383 |   35.0 |  6.0 |   5.7 |  70.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'46'' |
| MRX80P000 |   80.0 |  97.08% |     61881 | 3.84M | 129 |      1068 |  56.9K | 295 |   73.0 |  9.0 |  15.3 | 146.0 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'43'' |
| MRX80P001 |   80.0 |  97.10% |     52324 | 3.84M | 143 |      1110 |  65.8K | 376 |   74.5 | 10.5 |  14.3 | 149.0 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'42'' |


Table: statFinal

| Name                             |     N50 |     Sum |    # |
|:---------------------------------|--------:|--------:|-----:|
| Genome                           | 2961149 | 4033464 |    2 |
| Paralogs                         |    3483 |  114707 |   48 |
| 7_mergeKunitigsAnchors.anchors   |   66189 | 3909580 |  168 |
| 7_mergeKunitigsAnchors.others    |    1214 | 2401693 | 1893 |
| 7_mergeTadpoleAnchors.anchors    |  112455 | 3880577 |  100 |
| 7_mergeTadpoleAnchors.others     |    1620 | 1063602 |  701 |
| 7_mergeMRKunitigsAnchors.anchors |   92828 | 3857344 |  107 |
| 7_mergeMRKunitigsAnchors.others  |    1378 |  233601 |  169 |
| 7_mergeMRTadpoleAnchors.anchors  |  105333 | 3879129 |   97 |
| 7_mergeMRTadpoleAnchors.others   |    1635 |  145506 |  101 |
| 7_mergeAnchors.anchors           |  121204 | 3884575 |   90 |
| 7_mergeAnchors.others            |    1327 | 2814071 | 2060 |
| spades.contig                    |  176446 | 4935867 | 2075 |
| spades.scaffold                  |  246373 | 4936077 | 2072 |
| spades.non-contained             |  246373 | 4006059 |  119 |
| megahit.contig                   |   65594 | 4278704 |  961 |
| megahit.non-contained            |   71994 | 3896559 |  122 |
| megahit.anchor                   |   71891 | 3842184 |  116 |
| platanus.contig                  |   76029 | 4005887 |  343 |
| platanus.scaffold                |  104811 | 3955460 |  196 |
| platanus.non-contained           |  104811 | 3927850 |  101 |
| platanus.anchor                  |  104641 | 3875225 |  120 |

