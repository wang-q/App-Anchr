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

Table: statInsertSize

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| genome.bbtools  | 578.3 |    578 | 703.8 |                         49.48% |
| tadpole.bbtools | 557.0 |    570 | 165.2 |                         44.58% |
| genome.picard   | 582.1 |    585 | 146.5 |                             FR |
| tadpole.picard  | 573.7 |    577 | 147.2 |                             FR |


Table: statReads

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 5224283 | 5432652 |       2 |
| Paralogs |    2295 |  223889 |     103 |
| Illumina |     251 | 481.02M | 2080000 |
| uniq     |     251 | 480.99M | 2079856 |
| shuffle  |     251 | 480.99M | 2079856 |
| bbduk    |     250 | 476.24M | 2069782 |
| Q20L60   |     250 | 437.79M | 1938590 |
| Q25L60   |     250 | 412.88M | 1871789 |
| Q30L60   |     250 | 370.48M | 1750227 |

```text
#trimmedReads
#Matched        6539    0.31440%
#Name   Reads   ReadsPct
Reverse_adapter 5231    0.25151%
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 251 | 480.99M | 2079856 |
| trimmed       | 250 | 418.06M | 1875124 |
| filtered      | 250 |  417.9M | 1874410 |
| ecco          | 250 |  417.9M | 1874410 |
| eccc          | 250 |  417.9M | 1874410 |
| ecct          | 250 | 413.42M | 1850394 |
| extended      | 290 | 486.48M | 1850394 |
| merged        | 585 | 325.44M |  600468 |
| unmerged.raw  | 285 | 156.61M |  649458 |
| unmerged.trim | 255 | 124.52M |  592544 |
| U1            | 286 |  69.53M |  296272 |
| U2            | 209 |  54.98M |  296272 |
| Us            |   0 |       0 |       0 |
| pe.cor        | 533 | 450.55M | 1793480 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 361.9 |    387 |  97.4 |         19.20% |
| ihist.merge.txt  | 542.0 |    564 | 119.8 |         64.90% |

```text
#trimmedReads
#Matched        5776    0.27771%
#Name   Reads   ReadsPct
Reverse_adapter 4806    0.23107%
```

```text
#filteredReads
#Matched        413     0.02203%
#Name   Reads   ReadsPct
contam_250      311     0.01659%
```


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q20L60 |  80.6 |   68.8 |   14.68% |     227 | "127" | 5.43M | 5.36M |     0.99 | 0:00'52'' |
| Q25L60 |  76.0 |   68.6 |    9.75% |     222 | "127" | 5.43M | 5.34M |     0.98 | 0:00'49'' |
| Q30L60 |  68.2 |   64.2 |    5.98% |     215 | "127" | 5.43M | 5.34M |     0.98 | 0:00'45'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|-------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000  |   40.0 |  97.26% |     22153 | 5.27M | 384 |       130 | 82.25K | 1068 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'53'' |
| Q20L60X50P000  |   50.0 |  97.16% |     22095 | 5.28M | 389 |        85 | 65.96K | 1074 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:01'17'' | 0:00'56'' |
| Q20L60X60P000  |   60.0 |  97.14% |     22138 | 5.28M | 397 |        82 | 69.49K | 1100 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:01'28'' | 0:00'56'' |
| Q20L60XallP000 |   68.8 |  97.09% |     20983 | 5.28M | 403 |        75 |  64.1K | 1109 |   67.0 | 8.0 |  14.3 | 134.0 | "31,41,51,61,71,81" | 0:01'37'' | 0:00'56'' |
| Q25L60X40P000  |   40.0 |  97.90% |     35048 | 5.28M | 259 |       763 | 79.74K |  870 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:01'06'' | 0:01'01'' |
| Q25L60X50P000  |   50.0 |  97.87% |     40824 |  5.3M | 245 |        74 | 43.25K |  822 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'05'' |
| Q25L60X60P000  |   60.0 |  97.83% |     35046 |  5.3M | 253 |        81 | 49.35K |  845 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:01'26'' | 0:01'00'' |
| Q25L60XallP000 |   68.6 |  97.80% |     34816 |  5.3M | 251 |        78 | 48.13K |  835 |   66.0 | 8.0 |  14.0 | 132.0 | "31,41,51,61,71,81" | 0:01'35'' | 0:00'59'' |
| Q30L60X40P000  |   40.0 |  98.03% |     38021 |  5.3M | 239 |       117 | 55.19K |  811 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'53'' |
| Q30L60X50P000  |   50.0 |  98.07% |     41471 | 5.31M | 233 |        73 | 43.37K |  808 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:01'18'' | 0:01'00'' |
| Q30L60X60P000  |   60.0 |  98.08% |     42755 |  5.3M | 226 |        75 | 46.23K |  821 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:01'28'' | 0:00'58'' |
| Q30L60XallP000 |   64.2 |  98.09% |     41788 |  5.3M | 224 |        76 |    47K |  812 |   62.0 | 7.0 |  13.7 | 124.0 | "31,41,51,61,71,81" | 0:01'33'' | 0:01'00'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|-------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000  |   40.0 |  97.87% |     28853 | 5.29M | 306 |       140 |  71.7K |  922 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'54'' |
| Q20L60X50P000  |   50.0 |  97.83% |     26545 |  5.3M | 310 |        78 | 53.88K |  948 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'55'' |
| Q20L60X60P000  |   60.0 |  97.74% |     25427 | 5.29M | 344 |        85 |  64.3K | 1019 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'58'' |
| Q20L60XallP000 |   68.8 |  97.67% |     23858 | 5.29M | 354 |        85 | 63.49K | 1033 |   66.0 | 8.0 |  14.0 | 132.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'56'' |
| Q25L60X40P000  |   40.0 |  98.50% |     32284 | 5.29M | 274 |       985 | 79.65K |  867 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'51'' |
| Q25L60X50P000  |   50.0 |  98.15% |     34778 |  5.3M | 255 |       843 | 73.36K |  849 |   48.0 | 5.0 |  11.0 |  94.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'55'' |
| Q25L60X60P000  |   60.0 |  98.46% |     39155 |  5.3M | 247 |       118 | 56.48K |  829 |   57.0 | 7.0 |  12.0 | 114.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:01'02'' |
| Q25L60XallP000 |   68.6 |  98.45% |     39508 | 5.31M | 251 |        90 | 51.99K |  836 |   66.0 | 8.0 |  14.0 | 132.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:01'03'' |
| Q30L60X40P000  |   40.0 |  98.60% |     32333 |  5.3M | 267 |       116 | 59.97K |  870 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'55'' |
| Q30L60X50P000  |   50.0 |  98.63% |     34543 | 5.31M | 253 |        73 | 46.13K |  850 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:01'03'' |
| Q30L60X60P000  |   60.0 |  98.62% |     37669 |  5.3M | 241 |        74 | 45.95K |  816 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'55'' |
| Q30L60XallP000 |   64.2 |  98.63% |     37668 |  5.3M | 238 |        76 |  47.5K |  819 |   62.0 | 7.0 |  13.7 | 124.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'57'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |  Sum |   # | N50Others |    Sum |   # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-----:|----:|----------:|-------:|----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  98.41% |     45267 | 5.3M | 211 |       138 | 34.12K | 486 |   38.0 |  5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'00'' |
| MRX40P001  |   40.0 |  98.26% |     46741 | 5.3M | 206 |       109 | 30.37K | 484 |   38.0 |  5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'00'' |
| MRX50P000  |   50.0 |  98.42% |     45282 | 5.3M | 210 |       131 | 33.88K | 483 |   48.0 |  6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:01'26'' | 0:00'57'' |
| MRX60P000  |   60.0 |  98.20% |     44844 | 5.3M | 212 |       119 | 34.05K | 500 |   57.0 |  7.5 |  11.5 | 114.0 | "31,41,51,61,71,81" | 0:01'39'' | 0:00'59'' |
| MRXallP000 |   82.9 |  98.17% |     44826 | 5.3M | 215 |       101 | 30.58K | 509 |   78.0 | 11.0 |  15.0 | 156.0 | "31,41,51,61,71,81" | 0:02'07'' | 0:00'49'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  98.40% |     44394 |  5.3M | 210 |       200 | 30.17K | 433 |   38.0 |  5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'56'' |
| MRX40P001  |   40.0 |  98.45% |     46084 |  5.3M | 203 |       259 | 30.01K | 429 |   38.0 |  5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'56'' |
| MRX50P000  |   50.0 |  98.42% |     46109 |  5.3M | 206 |       199 | 30.33K | 433 |   48.0 |  6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'55'' |
| MRX60P000  |   60.0 |  98.41% |     46545 | 5.31M | 205 |       221 | 28.84K | 429 |   57.0 |  8.0 |  11.0 | 114.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'57'' |
| MRXallP000 |   82.9 |  98.42% |     47349 | 5.31M | 200 |       150 | 27.66K | 436 |   79.5 | 10.5 |  16.0 | 159.0 | "31,41,51,61,71,81" | 0:01'04'' | 0:00'48'' |


Table: statFinal

| Name                             |     N50 |     Sum |   # |
|:---------------------------------|--------:|--------:|----:|
| Genome                           | 5224283 | 5432652 |   2 |
| Paralogs                         |    2295 |  223889 | 103 |
| 7_mergeKunitigsAnchors.anchors   |   46118 | 5317899 | 210 |
| 7_mergeKunitigsAnchors.others    |    1222 |   46697 |  38 |
| 7_mergeTadpoleAnchors.anchors    |   44419 | 5311765 | 224 |
| 7_mergeTadpoleAnchors.others     |    1271 |   50466 |  38 |
| 7_mergeMRKunitigsAnchors.anchors |   47362 | 5311763 | 194 |
| 7_mergeMRKunitigsAnchors.others  |    1224 |   18009 |  16 |
| 7_mergeMRTadpoleAnchors.anchors  |   48555 | 5317330 | 196 |
| 7_mergeMRTadpoleAnchors.others   |    1222 |   17975 |  16 |
| 7_mergeAnchors.anchors           |   60106 | 5325774 | 173 |
| 7_mergeAnchors.others            |    1224 |   65369 |  53 |
| spades.contig                    |  207648 | 5370433 | 168 |
| spades.scaffold                  |  284294 | 5370573 | 154 |
| spades.non-contained             |  207648 | 5350580 |  59 |
| spades.anchor                    |  207555 | 5326470 |  67 |
| megahit.contig                   |   60414 | 5365010 | 256 |
| megahit.non-contained            |   60414 | 5332072 | 170 |
| megahit.anchor                   |   60380 | 5289962 | 187 |
| platanus.contig                  |   18759 | 5417970 | 652 |
| platanus.scaffold                |  485201 | 5351371 | 248 |
| platanus.non-contained           |  485201 | 5304311 |  38 |
| platanus.anchor                  |  284426 | 5285166 |  49 |


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


Table: statInsertSize

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| genome.bbtools  | 440.0 |    422 | 958.8 |                         15.58% |
| tadpole.bbtools | 407.5 |    420 |  84.1 |                         32.42% |
| genome.picard   | 412.9 |    422 |  39.3 |                             FR |
| tadpole.picard  | 408.4 |    421 |  46.7 |                             FR |


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


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 251 | 447.53M | 1782994 |
| trimmed       | 148 |  200.1M | 1452706 |
| filtered      | 148 |  200.1M | 1452702 |
| ecco          | 148 |    200M | 1452702 |
| ecct          | 148 | 198.77M | 1443484 |
| extended      | 186 | 255.85M | 1443484 |
| merged        | 456 | 170.62M |  405196 |
| unmerged.raw  | 175 | 105.21M |  633092 |
| unmerged.trim | 158 |  86.22M |  591429 |
| U1            | 167 |  29.27M |  189475 |
| U2            | 145 |  25.48M |  189475 |
| Us            | 162 |  31.47M |  212479 |
| pe.cor        | 439 | 257.46M | 1614300 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 196.1 |    194 |  63.4 |          7.05% |
| ihist.merge.txt  | 421.1 |    453 |  81.0 |         56.14% |

```text
#trimmedReads
#Matched        113823  6.38381%
#Name   Reads   ReadsPct
Reverse_adapter 81598   4.57646%
pcr_dimer       14481   0.81217%
PCR_Primers     8081    0.45323%
TruSeq_Universal_Adapter        5665    0.31772%
```

```text
#filteredReads
#Matched        4       0.00028%
#Name   Reads   ReadsPct
```


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q20L60 |  41.9 |   37.3 |   10.87% |     136 | "37" |  4.6M | 4.55M |     0.99 | 0:00'27'' |
| Q25L60 |  36.1 |   34.5 |    4.50% |     127 | "35" |  4.6M | 4.54M |     0.99 | 0:00'25'' |
| Q30L60 |  27.4 |   26.8 |    2.21% |     112 | "31" |  4.6M | 4.52M |     0.98 | 0:00'20'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X30P000  |   30.0 |  97.79% |     23401 | 4.07M | 316 |      7053 | 664.33K | 1262 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:01'05'' |
| Q20L60XallP000 |   37.3 |  97.73% |     27317 | 4.06M | 271 |      6646 | 688.37K | 1171 |   32.0 | 2.0 |   8.7 |  57.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:01'06'' |
| Q25L60X30P000  |   30.0 |  98.46% |     17766 | 4.04M | 373 |     11705 | 710.66K | 1284 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'53'' |
| Q25L60XallP000 |   34.5 |  98.48% |     20185 | 4.05M | 339 |     11765 | 684.72K | 1199 |   30.0 | 2.0 |   8.0 |  54.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'51'' |
| Q30L60XallP000 |   26.8 |  98.02% |      9521 | 3.96M | 606 |      7245 | 830.37K | 1764 |   23.0 | 2.0 |   5.7 |  43.5 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'44'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X30P000  |   30.0 |  98.43% |     15542 | 4.06M | 433 |      8450 | 733.55K | 1525 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:01'02'' |
| Q20L60XallP000 |   37.3 |  98.52% |     21826 | 4.05M | 336 |     10294 |  785.9K | 1364 |   32.0 | 2.0 |   8.7 |  57.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:01'05'' |
| Q25L60X30P000  |   30.0 |  98.15% |     12055 | 4.01M | 543 |     10921 | 784.44K | 1686 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'56'' |
| Q25L60XallP000 |   34.5 |  98.31% |     14251 | 4.02M | 474 |     10346 | 760.95K | 1562 |   30.0 | 2.0 |   8.0 |  54.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'56'' |
| Q30L60XallP000 |   26.8 |  96.89% |      6439 | 3.85M | 852 |      5804 | 854.41K | 2296 |   23.0 | 2.0 |   5.7 |  43.5 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'49'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX30P000  |   30.0 |  97.95% |     19498 | 4.06M | 345 |     12285 | 517.33K | 783 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'44'' |
| MRXallP000 |   55.9 |  97.91% |     22224 | 4.04M | 312 |     13119 | 524.97K | 720 |   48.0 | 3.0 |  13.0 |  85.5 | "31,41,51,61,71,81" | 0:01'17'' | 0:00'55'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX30P000  |   30.0 |  98.06% |     18786 | 4.05M | 369 |     12285 | 495.25K | 892 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'47'' |
| MRXallP000 |   55.9 |  98.08% |     20978 | 4.04M | 323 |     13119 | 506.53K | 779 |   48.0 | 3.0 |  13.0 |  85.5 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'45'' |


Table: statFinal

| Name                             |     N50 |     Sum |    # |
|:---------------------------------|--------:|--------:|-----:|
| Genome                           | 3188524 | 4602977 |    7 |
| Paralogs                         |    2337 |  147155 |   66 |
| 7_mergeKunitigsAnchors.anchors   |   33876 | 4081289 |  230 |
| 7_mergeKunitigsAnchors.others    |   11798 |  869117 |  179 |
| 7_mergeTadpoleAnchors.anchors    |   22437 | 4068458 |  320 |
| 7_mergeTadpoleAnchors.others     |   11705 |  886751 |  200 |
| 7_mergeMRKunitigsAnchors.anchors |   22142 | 4067147 |  325 |
| 7_mergeMRKunitigsAnchors.others  |   13119 |  519026 |   72 |
| 7_mergeMRTadpoleAnchors.anchors  |   20709 | 4062502 |  333 |
| 7_mergeMRTadpoleAnchors.others   |   13119 |  483416 |   67 |
| 7_mergeAnchors.anchors           |   39425 | 4100304 |  217 |
| 7_mergeAnchors.others            |   12964 |  897019 |  204 |
| spades.contig                    |   86457 | 4571770 |  159 |
| spades.scaffold                  |  130378 | 4572405 |  136 |
| spades.non-contained             |   88009 | 4556507 |  104 |
| spades.anchor                    |    4355 | 3646752 | 1079 |
| megahit.contig                   |   28867 | 4570304 |  361 |
| megahit.non-contained            |   29619 | 4531514 |  282 |
| megahit.anchor                   |    4238 | 3618689 | 1094 |
| platanus.contig                  |    4863 | 4603873 | 3435 |
| platanus.scaffold                |   37803 | 4533935 |  888 |
| platanus.non-contained           |   38632 | 4403868 |  229 |
| platanus.anchor                  |    4143 | 3520281 | 1102 |


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

Table: statInsertSize

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 458.8 |    277 | 2524.0 |                          7.42% |
| tadpole.bbtools | 266.8 |    266 |   50.7 |                         35.15% |
| genome.picard   | 295.7 |    279 |   47.4 |                             FR |
| genome.picard   | 287.1 |    271 |   33.8 |                             RF |
| tadpole.picard  | 268.0 |    267 |   49.1 |                             FR |
| tadpole.picard  | 251.5 |    255 |   48.0 |                             RF |


Table: statReads

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 5067172 | 5090491 |       2 |
| Paralogs |    1580 |   83364 |      53 |
| Illumina |     251 |    512M | 2039840 |
| uniq     |     251 | 511.87M | 2039330 |
| shuffle  |     251 | 511.87M | 2039330 |
| bbduk    |     197 | 384.97M | 2038412 |
| Q20L60   |     178 | 307.84M | 1876182 |
| Q25L60   |     172 | 273.08M | 1737142 |
| Q30L60   |     163 | 220.91M | 1503261 |

```text
#trimmedReads
#Matched        1485488 72.84196%
#Name   Reads   ReadsPct
Reverse_adapter 771275  37.82002%
pcr_dimer       408982  20.05472%
TruSeq_Universal_Adapter        124751  6.11725%
PCR_Primers     103991  5.09927%
TruSeq_Adapter_Index_1_6        49154   2.41030%
Nextera_LMP_Read2_External_Adapter      14785   0.72499%
TruSeq_Adapter_Index_11 6630    0.32511%
PhiX_read2_adapter      1008    0.04943%
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 251 | 511.87M | 2039328 |
| trimmed       | 176 | 295.71M | 1807284 |
| filtered      | 176 | 294.68M | 1802402 |
| ecco          | 176 | 294.62M | 1802402 |
| eccc          | 176 | 294.62M | 1802402 |
| ecct          | 176 | 284.44M | 1744078 |
| extended      | 214 | 353.74M | 1744078 |
| merged        | 235 | 200.26M |  862093 |
| unmerged.raw  | 207 |   3.58M |   19892 |
| unmerged.trim | 200 |   2.73M |   15680 |
| U1            | 214 |    1.5M |    7840 |
| U2            | 182 |   1.23M |    7840 |
| Us            |   0 |       0 |       0 |
| pe.cor        | 234 | 203.85M | 1739866 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 190.1 |    185 |  46.6 |         92.25% |
| ihist.merge.txt  | 232.3 |    226 |  51.5 |         98.86% |

```text
#trimmedReads
#Matched        1485487 72.84199%
#Name   Reads   ReadsPct
Reverse_adapter 771274  37.82001%
pcr_dimer       408982  20.05474%
TruSeq_Universal_Adapter        124751  6.11726%
PCR_Primers     103991  5.09928%
TruSeq_Adapter_Index_1_6        49154   2.41030%
Nextera_LMP_Read2_External_Adapter      14785   0.72499%
TruSeq_Adapter_Index_11 6630    0.32511%
PhiX_read2_adapter      1008    0.04943%
```

```text
#filteredReads
#Matched        4875    0.26974%
#Name   Reads   ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome  4869    0.26941%
```


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q20L60 |  60.5 |   47.3 |   21.87% |     165 | "45" | 5.09M | 5.23M |     1.03 | 0:00'39'' |
| Q25L60 |  53.7 |   45.0 |   16.18% |     159 | "43" | 5.09M | 5.21M |     1.02 | 0:00'33'' |
| Q30L60 |  43.4 |   38.1 |   12.18% |     150 | "39" | 5.09M | 5.19M |     1.02 | 0:00'29'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000  |   40.0 |  96.29% |      7385 | 4.86M |  976 |       757 |  260.1K | 2226 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:01'02'' |
| Q20L60XallP000 |   47.3 |  95.46% |      6324 | 4.78M | 1112 |       813 | 314.19K | 2393 |   44.0 | 3.0 |  11.7 |  79.5 | "31,41,51,61,71,81" | 0:00'57'' | 0:01'00'' |
| Q25L60X40P000  |   40.0 |  97.52% |      8011 | 4.73M |  997 |       954 |  490.8K | 2234 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'54'' |
| Q25L60XallP000 |   45.0 |  97.33% |      9072 | 4.92M |  853 |       784 | 236.76K | 2031 |   42.0 | 3.0 |  11.0 |  76.5 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'54'' |
| Q30L60XallP000 |   38.1 |  98.46% |     13943 | 4.89M |  709 |       995 | 350.45K | 1943 |   36.0 | 2.0 |  10.0 |  63.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'50'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000  |   40.0 |  98.57% |     17449 | 4.97M | 545 |      1058 | 299.04K | 1613 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:01'01'' |
| Q20L60XallP000 |   47.3 |  98.11% |     12751 | 4.89M | 729 |       937 | 365.54K | 1800 |   45.0 | 2.0 |  13.0 |  76.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'59'' |
| Q25L60X40P000  |   40.0 |  98.72% |     17853 | 4.96M | 563 |       871 | 285.24K | 1752 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'55'' |
| Q25L60XallP000 |   45.0 |  98.61% |     16600 | 4.92M | 647 |       914 | 331.14K | 1790 |   43.0 | 2.0 |  12.3 |  73.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'55'' |
| Q30L60XallP000 |   38.1 |  99.07% |     19777 | 5.01M | 513 |       885 | 308.89K | 1881 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'54'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  96.99% |     10334 | 4.95M | 737 |       217 | 169.84K | 1517 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'47'' |
| MRXallP000 |   40.0 |  96.99% |     10530 | 4.99M | 725 |       110 | 136.94K | 1503 |   37.0 | 2.5 |   9.8 |  66.8 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'45'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  99.33% |     82667 | 5.08M | 146 |       226 |  36.7K | 312 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'46'' |
| MRXallP000 |   40.0 |  99.33% |     82667 | 5.08M | 146 |       226 | 36.71K | 312 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'47'' |


Table: statFinal

| Name                             |     N50 |     Sum |    # |
|:---------------------------------|--------:|--------:|-----:|
| Genome                           | 5067172 | 5090491 |    2 |
| Paralogs                         |    1580 |   83364 |   53 |
| 7_mergeKunitigsAnchors.anchors   |   16942 | 5063964 |  536 |
| 7_mergeKunitigsAnchors.others    |    1208 |  539730 |  466 |
| 7_mergeTadpoleAnchors.anchors    |   35760 | 5085308 |  281 |
| 7_mergeTadpoleAnchors.others     |    1435 |  498238 |  374 |
| 7_mergeMRKunitigsAnchors.anchors |   10530 | 4985413 |  725 |
| 7_mergeMRKunitigsAnchors.others  |    1091 |   73536 |   68 |
| 7_mergeMRTadpoleAnchors.anchors  |   82667 | 5084662 |  146 |
| 7_mergeMRTadpoleAnchors.others   |    1476 |   15858 |   12 |
| 7_mergeAnchors.anchors           |  107245 | 5108183 |  110 |
| 7_mergeAnchors.others            |    1339 |  825040 |  648 |
| spades.contig                    |  174287 | 5220387 |  270 |
| spades.scaffold                  |  232956 | 5220517 |  266 |
| spades.non-contained             |  174287 | 5130469 |   46 |
| spades.anchor                    |    3164 | 4219251 | 1585 |
| megahit.contig                   |   87996 | 5153722 |  187 |
| megahit.non-contained            |   87996 | 5126071 |  108 |
| megahit.anchor                   |    4116 | 4493352 | 1396 |
| platanus.contig                  |   31929 | 5161063 |  460 |
| platanus.scaffold                |   72495 | 5137530 |  212 |
| platanus.non-contained           |   72495 | 5114644 |  140 |
| platanus.anchor                  |    3143 | 4201359 | 1591 |


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


Table: statInsertSize

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 391.1 |    274 | 1890.4 |                          8.53% |
| tadpole.bbtools | 270.9 |    268 |   53.1 |                         41.53% |
| genome.picard   | 294.0 |    277 |   48.0 |                             FR |
| genome.picard   | 280.2 |    268 |   29.0 |                             RF |
| tadpole.picard  | 272.0 |    268 |   48.1 |                             FR |
| tadpole.picard  | 260.4 |    262 |   44.9 |                             RF |


Table: statReads

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 2961149 | 4033464 |       2 |
| Paralogs |    3483 |  114707 |      48 |
| Illumina |     251 |    400M | 1593624 |
| uniq     |     251 | 397.99M | 1585616 |
| shuffle  |     251 | 397.99M | 1585616 |
| bbduk    |     197 | 304.63M | 1584348 |
| Q20L60   |     190 | 279.78M | 1541487 |
| Q25L60   |     186 | 261.44M | 1477548 |
| Q30L60   |     180 |  229.6M | 1354637 |

```text
#trimmedReads
#Matched        1285805 81.09183%
#Name   Reads   ReadsPct
Reverse_adapter 623379  39.31463%
pcr_dimer       357756  22.56259%
PCR_Primers     183855  11.59518%
TruSeq_Universal_Adapter        49636   3.13039%
TruSeq_Adapter_Index_1_6        47578   3.00060%
Nextera_LMP_Read2_External_Adapter      19457   1.22709%
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 251 | 397.98M | 1585566 |
| trimmed       | 189 | 276.54M | 1530194 |
| filtered      | 188 | 274.82M | 1521974 |
| ecco          | 188 | 274.78M | 1521974 |
| eccc          | 188 | 274.78M | 1521974 |
| ecct          | 188 | 271.61M | 1504506 |
| extended      | 227 | 331.51M | 1504506 |
| merged        | 238 | 178.17M |  746884 |
| unmerged.raw  | 225 |    2.2M |   10738 |
| unmerged.trim | 220 |   1.86M |    9318 |
| U1            | 228 | 983.24K |    4659 |
| U2            | 211 | 873.81K |    4659 |
| Us            |   0 |       0 |       0 |
| pe.cor        | 237 | 180.77M | 1503086 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 196.4 |    190 |  44.5 |         95.10% |
| ihist.merge.txt  | 238.6 |    231 |  51.2 |         99.29% |

```text
#trimmedReads
#Matched        1285780 81.09281%
#Name   Reads   ReadsPct
Reverse_adapter 623363  39.31486%
pcr_dimer       357752  22.56305%
PCR_Primers     183852  11.59535%
TruSeq_Universal_Adapter        49636   3.13049%
TruSeq_Adapter_Index_1_6        47577   3.00063%
Nextera_LMP_Read2_External_Adapter      19456   1.22707%
```

```text
#filteredReads
#Matched        8215    0.53686%
#Name   Reads   ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome  8211    0.53660%
```


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q20L60 |  69.4 |   57.1 |   17.74% |     182 | "109" | 4.03M | 3.97M |     0.98 | 0:00'34'' |
| Q25L60 |  64.8 |   56.0 |   13.58% |     178 | "107" | 4.03M | 3.95M |     0.98 | 0:00'32'' |
| Q30L60 |  56.9 |   51.2 |   10.16% |     172 | "103" | 4.03M | 3.94M |     0.98 | 0:00'30'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000  |   40.0 |  93.82% |      8658 | 3.68M | 659 |      1017 | 200.48K | 1463 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'38'' |
| Q20L60X50P000  |   50.0 |  93.15% |      7679 | 3.68M | 717 |       932 | 179.76K | 1531 |   46.0 | 6.0 |   9.3 |  92.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'39'' |
| Q20L60XallP000 |   57.1 |  92.92% |      7270 | 3.69M | 723 |       805 | 159.92K | 1544 |   53.0 | 7.0 |  10.7 | 106.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'39'' |
| Q25L60X40P000  |   40.0 |  96.66% |     24235 | 3.76M | 301 |      1174 | 140.62K |  737 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'41'' |
| Q25L60X50P000  |   50.0 |  96.36% |     23658 | 3.77M | 318 |      1167 | 121.12K |  765 |   46.0 | 6.0 |   9.3 |  92.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'40'' |
| Q25L60XallP000 |   56.0 |  96.20% |     20218 | 3.78M | 347 |      1066 | 114.86K |  811 |   52.0 | 7.0 |  10.3 | 104.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'40'' |
| Q30L60X40P000  |   40.0 |  96.62% |     27882 | 3.78M | 269 |      1058 | 113.21K |  733 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'42'' |
| Q30L60X50P000  |   50.0 |  96.84% |     24335 | 3.78M | 284 |      1143 | 118.27K |  727 |   46.0 | 6.0 |   9.3 |  92.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'40'' |
| Q30L60XallP000 |   51.2 |  96.77% |     23646 | 3.79M | 282 |      1067 | 107.73K |  725 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'40'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000  |   40.0 |  96.66% |     16787 | 3.76M | 398 |      1109 | 178.55K | 1010 |   36.0 | 5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'41'' |
| Q20L60X50P000  |   50.0 |  96.19% |     15220 | 3.77M | 443 |      1177 | 178.71K | 1037 |   46.0 | 6.0 |   9.3 |  92.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'40'' |
| Q20L60XallP000 |   57.1 |  95.83% |     13415 | 3.78M | 478 |      1181 | 160.92K | 1090 |   53.0 | 7.0 |  10.7 | 106.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'40'' |
| Q25L60X40P000  |   40.0 |  97.55% |     45975 | 3.78M | 237 |      1272 | 175.42K |  702 |   36.0 | 5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'45'' |
| Q25L60X50P000  |   50.0 |  97.55% |     55088 | 3.82M | 200 |      1265 | 132.56K |  591 |   45.0 | 7.0 |   8.0 |  90.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'44'' |
| Q25L60XallP000 |   56.0 |  97.52% |     54674 | 3.83M | 198 |      1330 | 115.54K |  555 |   51.0 | 8.0 |   9.0 | 102.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'44'' |
| Q30L60X40P000  |   40.0 |  97.71% |     46759 | 3.79M | 207 |      1450 |  177.3K |  698 |   36.0 | 5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'46'' |
| Q30L60X50P000  |   50.0 |  97.71% |     52294 | 3.81M | 188 |      1350 | 149.27K |  623 |   45.0 | 6.0 |   9.0 |  90.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'45'' |
| Q30L60XallP000 |   51.2 |  97.70% |     52294 | 3.82M | 182 |      1250 | 130.49K |  607 |   47.0 | 7.0 |   8.7 |  94.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'45'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  96.28% |     22622 | 3.79M | 286 |      1083 | 83.96K | 617 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'38'' |
| MRXallP000 |   44.8 |  96.17% |     21411 |  3.8M | 310 |      1059 | 76.92K | 661 |   42.0 | 6.0 |   8.0 |  84.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'38'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  97.18% |     63809 | 3.84M | 169 |      1031 |  48.5K | 344 |   35.0 | 7.0 |   4.7 |  70.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'39'' |
| MRXallP000 |   44.8 |  97.17% |     57284 | 3.83M | 166 |      1083 | 53.72K | 334 |   40.0 | 7.0 |   6.3 |  80.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'39'' |


Table: statFinal

| Name                             |     N50 |     Sum |   # |
|:---------------------------------|--------:|--------:|----:|
| Genome                           | 2961149 | 4033464 |   2 |
| Paralogs                         |    3483 |  114707 |  48 |
| 7_mergeKunitigsAnchors.anchors   |   40072 | 3826258 | 192 |
| 7_mergeKunitigsAnchors.others    |    1438 |  243747 | 181 |
| 7_mergeTadpoleAnchors.anchors    |   70403 | 3851672 | 141 |
| 7_mergeTadpoleAnchors.others     |    4860 |  469966 | 212 |
| 7_mergeMRKunitigsAnchors.anchors |   22629 | 3807036 | 286 |
| 7_mergeMRKunitigsAnchors.others  |    1389 |   64278 |  47 |
| 7_mergeMRTadpoleAnchors.anchors  |   63809 | 3844472 | 161 |
| 7_mergeMRTadpoleAnchors.others   |    1181 |   47670 |  39 |
| 7_mergeAnchors.anchors           |   93119 | 3865485 | 115 |
| 7_mergeAnchors.others            |    2620 |  577078 | 297 |
| spades.contig                    |  246446 | 4116141 | 558 |
| spades.scaffold                  |  259375 | 4116341 | 556 |
| spades.non-contained             |  246446 | 3929304 |  66 |
| spades.anchor                    |  198930 | 3819104 | 200 |
| megahit.contig                   |   87595 | 3962080 | 273 |
| megahit.non-contained            |   87595 | 3896252 | 120 |
| megahit.anchor                   |   65633 | 3794416 | 239 |
| platanus.contig                  |   49404 | 3992698 | 548 |
| platanus.scaffold                |   55222 | 3941539 | 351 |
| platanus.non-contained           |   58990 | 3880137 | 170 |
| platanus.anchor                  |   42784 | 3697431 | 338 |


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

Table: statInsertSize

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 246.4 |    193 | 1280.3 |                         46.93% |
| tadpole.bbtools | 196.5 |    189 |   53.4 |                         39.73% |
| genome.picard   | 199.2 |    193 |   47.4 |                             FR |
| tadpole.picard  | 193.5 |    188 |   44.6 |                             FR |

Table: statReads

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 2961149 | 4033464 |       2 |
| Paralogs |    3483 |  114707 |      48 |
| Illumina |     100 | 392.01M | 3920090 |
| uniq     |     100 |  362.9M | 3629044 |
| shuffle  |     100 |  362.9M | 3629044 |
| bbduk    |     100 | 362.48M | 3625978 |
| Q25L60   |     100 | 362.46M | 3625404 |

```text
#trimmedReads
#Matched        5987    0.16497%
#Name   Reads   ReadsPct
Reverse_adapter 2158    0.05946%
TruSeq_Universal_Adapter        1422    0.03918%
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 100 | 362.86M | 3628564 |
| trimmed       | 100 | 289.36M | 3064578 |
| filtered      | 100 | 289.35M | 3064430 |
| ecco          | 100 | 289.34M | 3064430 |
| eccc          | 100 | 289.34M | 3064430 |
| ecct          | 100 | 285.38M | 3020724 |
| extended      | 140 |    404M | 3020724 |
| merged        | 237 | 342.83M | 1453666 |
| unmerged.raw  | 139 |  14.27M |  113392 |
| unmerged.trim | 139 |  11.76M |   96504 |
| U1            | 140 |   6.08M |   48252 |
| U2            | 130 |   5.68M |   48252 |
| Us            |   0 |       0 |       0 |
| pe.cor        | 236 | 356.04M | 3003836 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 158.0 |    160 |  18.3 |         29.57% |
| ihist.merge.txt  | 235.8 |    231 |  41.6 |         96.25% |

```text
#trimmedReads
#Matched        5987    0.16500%
#Name   Reads   ReadsPct
Reverse_adapter 2158    0.05947%
TruSeq_Universal_Adapter        1422    0.03919%
```

```text
#filteredReads
#Matched        148     0.00483%
#Name   Reads   ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome  148     0.00483%
```


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 |  89.9 |   56.9 |   36.72% |      99 | "71" | 4.03M | 4.05M |     1.00 | 0:00'44'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  83.97% |      2280 |    3M | 1453 |      1032 |  523.4K | 4189 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'40'' |
| Q25L60X50P000  |   50.0 |  81.01% |      2203 | 2.89M | 1421 |      1031 | 436.06K | 3868 |   46.0 | 5.0 |  10.3 |  91.5 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'41'' |
| Q25L60XallP000 |   56.9 |  79.01% |      2131 | 2.82M | 1407 |      1025 | 380.56K | 3689 |   52.0 | 6.0 |  11.3 | 104.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'37'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  90.58% |      3308 | 3.37M | 1247 |      1016 | 440.83K | 3973 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'43'' |
| Q25L60X50P000  |   50.0 |  89.99% |      3089 |  3.4M | 1315 |      1016 | 392.37K | 4191 |   47.0 | 5.0 |  10.7 |  93.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'44'' |
| Q25L60XallP000 |   56.9 |  89.25% |      2953 | 3.38M | 1365 |      1015 | 373.09K | 4191 |   53.0 | 6.0 |  11.7 | 106.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'44'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  95.14% |     12542 | 3.74M | 475 |       908 | 129.78K | 1015 |   37.0 |  4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'38'' |
| MRX40P001  |   40.0 |  95.21% |     11926 | 3.77M | 465 |       745 |  97.84K |  984 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'37'' |
| MRX50P000  |   50.0 |  94.78% |     11310 | 3.75M | 523 |       742 | 112.39K | 1104 |   46.0 |  6.0 |   9.3 |  92.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'40'' |
| MRXallP000 |   88.3 |  93.46% |      8302 | 3.71M | 650 |       152 | 113.22K | 1341 |   82.0 | 10.0 |  17.3 | 164.0 | "31,41,51,61,71,81" | 0:01'28'' | 0:00'38'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  96.67% |     26289 | 3.82M | 270 |       528 | 65.83K | 672 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'41'' |
| MRX40P001  |   40.0 |  96.77% |     22715 | 3.82M | 295 |       818 | 78.27K | 715 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'39'' |
| MRX50P000  |   50.0 |  96.43% |     21606 | 3.81M | 308 |       504 | 74.88K | 729 |   46.0 |  6.0 |   9.3 |  92.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'41'' |
| MRXallP000 |   88.3 |  95.69% |     14280 | 3.79M | 427 |       157 | 83.24K | 930 |   83.0 | 10.0 |  17.7 | 166.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'40'' |


Table: statFinal

| Name                             |     N50 |     Sum |    # |
|:---------------------------------|--------:|--------:|-----:|
| Genome                           | 2961149 | 4033464 |    2 |
| Paralogs                         |    3483 |  114707 |   48 |
| 7_mergeKunitigsAnchors.anchors   |    2385 | 3145040 | 1462 |
| 7_mergeKunitigsAnchors.others    |    1076 |  491689 |  426 |
| 7_mergeTadpoleAnchors.anchors    |    3632 | 3577367 | 1242 |
| 7_mergeTadpoleAnchors.others     |    1067 |  438626 |  388 |
| 7_mergeMRKunitigsAnchors.anchors |   17405 | 3835279 |  362 |
| 7_mergeMRKunitigsAnchors.others  |    1117 |  127692 |  111 |
| 7_mergeMRTadpoleAnchors.anchors  |   37256 | 3854077 |  217 |
| 7_mergeMRTadpoleAnchors.others   |    1138 |   81838 |   74 |
| 7_mergeAnchors.anchors           |   38073 | 3877182 |  218 |
| 7_mergeAnchors.others            |    1088 |  782942 |  664 |
| spades.contig                    |  198954 | 3957851 |  185 |
| spades.scaffold                  |  246583 | 3958051 |  183 |
| spades.non-contained             |  198954 | 3923463 |   63 |
| spades.anchor                    |  198548 | 3840581 |  154 |
| megahit.contig                   |  129196 | 3950333 |  200 |
| megahit.non-contained            |  129196 | 3904091 |   95 |
| megahit.anchor                   |   71373 | 3811632 |  210 |
| platanus.contig                  |    6727 | 4047627 | 2326 |
| platanus.scaffold                |  117300 | 3910902 |  196 |
| platanus.non-contained           |  117300 | 3875124 |   97 |
| platanus.anchor                  |   58978 | 3706701 |  351 |


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


Table: statInsertSize

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 461.0 |    422 | 1286.1 |                         17.09% |
| tadpole.bbtools | 406.2 |    420 |   63.5 |                         32.67% |
| genome.picard   | 413.0 |    422 |   39.3 |                             FR |
| tadpole.picard  | 407.7 |    421 |   47.4 |                             FR |


Table: statReads

| Name     |     N50 |     Sum |        # |
|:---------|--------:|--------:|---------:|
| Genome   | 3188524 | 4602977 |        7 |
| Paralogs |    2337 |  147155 |       66 |
| Illumina |     251 |   4.24G | 16881336 |
| uniq     |     251 |    4.2G | 16731106 |
| shuffle  |     251 |    4.2G | 16731106 |
| bbduk    |     250 |    3.9G | 15985914 |
| Q20L60   |     144 |    1.8G | 13451710 |
| Q25L60   |     133 |   1.56G | 12529164 |
| Q30L60   |     116 |   1.18G | 10785603 |

```text
#trimmedReads
#Matched        1067201 6.37854%
#Name   Reads   ReadsPct
Reverse_adapter 762783  4.55907%
pcr_dimer       135661  0.81083%
PCR_Primers     75219   0.44958%
TruSeq_Universal_Adapter        54684   0.32684%
TruSeq_Adapter_Index_1_6        7437    0.04445%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N702        5544    0.03314%
TruSeq_Adapter_Index_12 2735    0.01635%
RNA_PCR_Primer_Index_21_(RPI21) 2344    0.01401%
I5_Nextera_Transposase_2        2219    0.01326%
I7_Nextera_Transposase_1        1640    0.00980%
TruSeq_Adapter_Index_2  1622    0.00969%
I5_Nextera_Transposase_1        1508    0.00901%
I5_Adapter_Nextera      1406    0.00840%
I5_Primer_Nextera_XT_Index_Kit_v2_S511  1129    0.00675%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501  1056    0.00631%
```


Table: statMergeReads

| Name          | N50 |     Sum |        # |
|:--------------|----:|--------:|---------:|
| clumped       | 251 |    4.2G | 16724610 |
| trimmed       | 149 |    1.7G | 12278092 |
| filtered      | 149 |    1.7G | 12278062 |
| ecco          | 149 |    1.7G | 12278062 |
| ecct          | 149 |   1.69G | 12180756 |
| extended      | 187 |   2.17G | 12180756 |
| merged        | 459 |   2.06G |  4875017 |
| unmerged.raw  | 157 | 363.95M |  2430722 |
| unmerged.trim | 142 | 262.88M |  1999076 |
| U1            | 153 |  141.1M |   999538 |
| U2            | 131 | 121.79M |   999538 |
| Us            |   0 |       0 |        0 |
| pe.cor        | 457 |   2.32G | 11749110 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 189.2 |    185 |  65.3 |         10.72% |
| ihist.merge.txt  | 421.6 |    457 |  87.1 |         80.05% |

```text
#trimmedReads
#Matched        1067196 6.38099%
#Name   Reads   ReadsPct
Reverse_adapter 762778  4.56081%
pcr_dimer       135661  0.81115%
PCR_Primers     75219   0.44975%
TruSeq_Universal_Adapter        54684   0.32697%
TruSeq_Adapter_Index_1_6        7437    0.04447%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N702        5544    0.03315%
TruSeq_Adapter_Index_12 2735    0.01635%
RNA_PCR_Primer_Index_21_(RPI21) 2344    0.01402%
I5_Nextera_Transposase_2        2219    0.01327%
I7_Nextera_Transposase_1        1640    0.00981%
TruSeq_Adapter_Index_2  1622    0.00970%
I5_Nextera_Transposase_1        1508    0.00902%
I5_Adapter_Nextera      1406    0.00841%
I5_Primer_Nextera_XT_Index_Kit_v2_S511  1129    0.00675%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501  1056    0.00631%
```

```text
#filteredReads
#Matched        16      0.00013%
#Name   Reads   ReadsPct
```


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q20L60 | 392.4 |  353.2 |    9.98% |     136 | "37" |  4.6M | 5.17M |     1.12 | 0:03'56'' |
| Q25L60 | 338.6 |  323.6 |    4.44% |     126 | "35" |  4.6M |  4.6M |     1.00 | 0:03'17'' |
| Q30L60 | 256.6 |  250.9 |    2.22% |     112 | "31" |  4.6M | 4.55M |     0.99 | 0:02'42'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000 |   40.0 |  88.95% |      5987 | 3.95M |  909 |      1465 | 519.38K | 3121 |   33.0 | 2.0 |   9.0 |  58.5 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'48'' |
| Q20L60X40P001 |   40.0 |  89.24% |      5934 | 3.94M |  926 |      1445 | 549.79K | 3160 |   33.0 | 2.0 |   9.0 |  58.5 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'48'' |
| Q20L60X40P002 |   40.0 |  89.10% |      5826 | 3.91M |  952 |      1370 | 546.41K | 3200 |   33.0 | 2.0 |   9.0 |  58.5 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'48'' |
| Q20L60X40P003 |   40.0 |  89.30% |      5748 | 3.94M |  949 |      1471 | 537.82K | 3167 |   33.0 | 2.0 |   9.0 |  58.5 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'48'' |
| Q20L60X40P004 |   40.0 |  89.41% |      5767 | 3.95M |  927 |      1371 | 526.86K | 3117 |   33.0 | 2.0 |   9.0 |  58.5 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'47'' |
| Q20L60X40P005 |   40.0 |  89.41% |      5779 | 3.99M |  951 |      1487 | 478.92K | 3234 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'48'' |
| Q20L60X40P006 |   40.0 |  89.52% |      5755 | 3.93M |  944 |      1465 | 534.85K | 3183 |   33.0 | 2.0 |   9.0 |  58.5 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'48'' |
| Q20L60X40P007 |   40.0 |  89.13% |      6349 | 3.93M |  899 |      1505 | 538.15K | 3086 |   33.0 | 2.0 |   9.0 |  58.5 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'49'' |
| Q20L60X80P000 |   80.0 |  74.90% |      2661 | 3.47M | 1462 |      1037 | 400.51K | 3737 |   64.0 | 5.0 |  16.3 | 118.5 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'43'' |
| Q20L60X80P001 |   80.0 |  74.48% |      2603 | 3.45M | 1498 |      1038 | 371.68K | 3708 |   65.0 | 5.0 |  16.7 | 120.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'42'' |
| Q20L60X80P002 |   80.0 |  74.31% |      2571 | 3.42M | 1478 |      1039 | 401.73K | 3723 |   64.0 | 5.0 |  16.3 | 118.5 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'42'' |
| Q20L60X80P003 |   80.0 |  75.24% |      2722 | 3.45M | 1449 |      1042 | 389.31K | 3647 |   65.0 | 5.0 |  16.7 | 120.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'43'' |
| Q25L60X40P000 |   40.0 |  97.96% |     18175 | 4.04M |  385 |      5789 | 725.51K | 1494 |   35.0 | 2.0 |   9.7 |  61.5 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'49'' |
| Q25L60X40P001 |   40.0 |  97.86% |     19210 | 4.07M |  372 |      5225 | 721.84K | 1509 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'48'' |
| Q25L60X40P002 |   40.0 |  97.85% |     19649 | 4.07M |  357 |      4317 | 636.58K | 1543 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'50'' |
| Q25L60X40P003 |   40.0 |  97.74% |     20518 | 4.05M |  351 |      5451 | 715.74K | 1450 |   35.0 | 2.0 |   9.7 |  61.5 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'48'' |
| Q25L60X40P004 |   40.0 |  97.89% |     21004 | 4.04M |  357 |      5359 | 745.61K | 1489 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'49'' |
| Q25L60X40P005 |   40.0 |  97.67% |     18746 | 4.07M |  389 |      5311 | 695.48K | 1520 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'49'' |
| Q25L60X40P006 |   40.0 |  97.86% |     17940 | 4.05M |  368 |      4652 |  666.3K | 1547 |   35.0 | 2.0 |   9.7 |  61.5 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'50'' |
| Q25L60X40P007 |   40.0 |  97.96% |     18679 | 4.06M |  368 |      6355 | 729.53K | 1500 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'48'' |
| Q25L60X80P000 |   80.0 |  97.08% |     20191 | 4.07M |  352 |      3595 | 611.26K | 1660 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'53'' |
| Q25L60X80P001 |   80.0 |  96.52% |     19105 | 4.06M |  375 |      3778 | 640.59K | 1761 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'55'' |
| Q25L60X80P002 |   80.0 |  96.83% |     18691 | 4.08M |  367 |      3115 | 588.14K | 1737 |   70.0 | 5.0 |  18.3 | 127.5 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'53'' |
| Q25L60X80P003 |   80.0 |  96.72% |     17851 | 4.08M |  364 |      3393 | 560.09K | 1691 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'52'' |
| Q30L60X40P000 |   40.0 |  98.39% |     13901 | 4.03M |  488 |      9064 | 740.45K | 1572 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'47'' |
| Q30L60X40P001 |   40.0 |  98.45% |     13428 | 4.02M |  483 |      8972 |  747.1K | 1571 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'46'' |
| Q30L60X40P002 |   40.0 |  98.37% |     13856 |    4M |  479 |      8958 | 803.63K | 1565 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'46'' |
| Q30L60X40P003 |   40.0 |  98.43% |     14411 | 4.02M |  462 |      8200 | 736.66K | 1542 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'47'' |
| Q30L60X40P004 |   40.0 |  98.40% |     13615 | 4.02M |  479 |      9084 | 790.29K | 1557 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'48'' |
| Q30L60X40P005 |   40.0 |  98.33% |     14129 | 4.02M |  489 |      7830 | 754.47K | 1541 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'46'' |
| Q30L60X80P000 |   80.0 |  98.68% |     19985 | 4.05M |  354 |      9617 |  729.5K | 1298 |   70.0 | 5.0 |  18.3 | 127.5 | "31,41,51,61,71,81" | 0:01'08'' | 0:00'52'' |
| Q30L60X80P001 |   80.0 |  98.68% |     19455 | 4.04M |  352 |     11701 | 798.62K | 1292 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:01'08'' | 0:00'52'' |
| Q30L60X80P002 |   80.0 |  98.61% |     18256 | 4.04M |  374 |     11181 | 780.64K | 1298 |   70.0 | 5.0 |  18.3 | 127.5 | "31,41,51,61,71,81" | 0:01'08'' | 0:00'49'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000 |   40.0 |  97.85% |     21476 | 4.05M | 341 |      8667 | 764.83K | 1369 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'51'' |
| Q20L60X40P001 |   40.0 |  97.77% |     20338 | 4.04M | 350 |      8010 | 765.06K | 1419 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'49'' |
| Q20L60X40P002 |   40.0 |  97.70% |     20522 | 4.04M | 356 |      7880 | 751.61K | 1470 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'50'' |
| Q20L60X40P003 |   40.0 |  97.74% |     20559 | 4.04M | 326 |      8103 | 758.01K | 1375 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'49'' |
| Q20L60X40P004 |   40.0 |  97.82% |     20613 | 4.04M | 346 |      8959 | 807.13K | 1403 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'52'' |
| Q20L60X40P005 |   40.0 |  97.76% |     21278 | 4.06M | 351 |      8831 | 762.54K | 1401 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'51'' |
| Q20L60X40P006 |   40.0 |  97.82% |     19864 | 4.04M | 350 |      8087 | 774.46K | 1434 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'50'' |
| Q20L60X40P007 |   40.0 |  97.81% |     21154 | 4.04M | 349 |      7486 | 794.22K | 1419 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'50'' |
| Q20L60X80P000 |   80.0 |  97.84% |     20226 | 4.07M | 339 |      5483 | 810.57K | 1776 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'57'' |
| Q20L60X80P001 |   80.0 |  97.71% |     21484 | 4.07M | 340 |      6215 | 778.03K | 1629 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'55'' |
| Q20L60X80P002 |   80.0 |  97.93% |     22062 |  4.1M | 327 |      6037 | 817.55K | 1660 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'55'' |
| Q20L60X80P003 |   80.0 |  97.80% |     20572 | 4.06M | 335 |      6328 | 841.92K | 1694 |   68.0 | 4.0 |  18.7 | 120.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'57'' |
| Q25L60X40P000 |   40.0 |  98.37% |     13941 |    4M | 450 |      9914 | 707.96K | 1451 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'47'' |
| Q25L60X40P001 |   40.0 |  98.44% |     15127 | 4.03M | 449 |      9925 | 786.08K | 1546 |   35.0 | 2.0 |   9.7 |  61.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'48'' |
| Q25L60X40P002 |   40.0 |  98.27% |     15231 |    4M | 432 |      9337 | 768.42K | 1528 |   35.0 | 2.0 |   9.7 |  61.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'48'' |
| Q25L60X40P003 |   40.0 |  98.42% |     16846 | 4.03M | 413 |     10926 | 728.37K | 1418 |   35.0 | 2.0 |   9.7 |  61.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'47'' |
| Q25L60X40P004 |   40.0 |  98.38% |     15878 | 4.01M | 437 |     10614 | 786.07K | 1505 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'46'' |
| Q25L60X40P005 |   40.0 |  98.39% |     14369 | 4.01M | 445 |      9875 | 815.63K | 1533 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'47'' |
| Q25L60X40P006 |   40.0 |  98.39% |     14524 | 4.01M | 456 |      9843 | 739.12K | 1476 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'46'' |
| Q25L60X40P007 |   40.0 |  98.31% |     14397 |    4M | 445 |      9773 | 806.32K | 1507 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'48'' |
| Q25L60X80P000 |   80.0 |  98.62% |     23600 | 4.06M | 287 |     12962 | 711.22K | 1200 |   70.0 | 4.0 |  19.3 | 123.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'54'' |
| Q25L60X80P001 |   80.0 |  98.58% |     24391 | 4.05M | 280 |     13137 | 686.15K | 1158 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'52'' |
| Q25L60X80P002 |   80.0 |  98.70% |     24495 | 4.06M | 302 |     11918 | 770.41K | 1183 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'52'' |
| Q25L60X80P003 |   80.0 |  98.57% |     22054 | 4.05M | 297 |     12569 | 756.68K | 1192 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'52'' |
| Q30L60X40P000 |   40.0 |  97.98% |      8916 | 3.96M | 669 |      7466 | 804.67K | 1942 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'44'' |
| Q30L60X40P001 |   40.0 |  97.91% |      8957 | 3.96M | 659 |      8201 | 787.56K | 1906 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'46'' |
| Q30L60X40P002 |   40.0 |  97.87% |      9190 | 3.95M | 645 |      6623 | 764.12K | 1911 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'45'' |
| Q30L60X40P003 |   40.0 |  97.91% |      9163 | 3.96M | 640 |      7434 | 765.26K | 1911 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'47'' |
| Q30L60X40P004 |   40.0 |  97.92% |      8922 | 3.97M | 640 |      7820 | 749.66K | 1896 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'46'' |
| Q30L60X40P005 |   40.0 |  97.86% |      9155 | 3.96M | 645 |      7556 | 783.44K | 1909 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'47'' |
| Q30L60X80P000 |   80.0 |  98.56% |     14632 | 4.02M | 452 |      9069 | 814.89K | 1527 |   70.0 | 5.0 |  18.3 | 127.5 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'50'' |
| Q30L60X80P001 |   80.0 |  98.53% |     14716 | 4.02M | 446 |     10908 | 825.74K | 1528 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'50'' |
| Q30L60X80P002 |   80.0 |  98.50% |     15335 | 4.02M | 455 |      9822 | 839.17K | 1506 |   70.0 | 5.0 |  18.3 | 127.5 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'49'' |


Table: statMRKunitigsAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  97.86% |     55818 | 4.08M | 157 |     18031 | 547.48K | 415 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'11'' | 0:00'50'' |
| MRX40P001 |   40.0 |  98.03% |     60452 |  4.1M | 165 |     12569 | 513.41K | 424 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'50'' |
| MRX40P002 |   40.0 |  97.95% |     53236 | 4.08M | 155 |     13128 | 562.93K | 428 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'50'' |
| MRX40P003 |   40.0 |  97.92% |     66612 | 4.12M | 169 |     11883 | 487.86K | 407 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:01'11'' | 0:00'48'' |
| MRX40P004 |   40.0 |  97.82% |     50939 | 4.08M | 157 |     18227 | 509.07K | 428 |   35.0 | 2.0 |   9.7 |  61.5 | "31,41,51,61,71,81" | 0:01'11'' | 0:00'51'' |
| MRX40P005 |   40.0 |  97.93% |     53085 | 4.07M | 169 |     12569 | 510.34K | 461 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'48'' |
| MRX40P006 |   40.0 |  97.91% |     59751 | 4.08M | 163 |     12964 | 526.29K | 448 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'11'' | 0:00'48'' |
| MRX40P007 |   40.0 |  97.88% |     58315 | 4.08M | 162 |     11041 | 505.83K | 416 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'11'' | 0:00'49'' |
| MRX40P008 |   40.0 |  97.93% |     62987 | 4.08M | 147 |     14037 | 525.53K | 402 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'50'' |
| MRX40P009 |   40.0 |  97.84% |     55011 | 4.08M | 155 |     13737 |  550.4K | 424 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'47'' |
| MRX40P010 |   40.0 |  97.89% |     54965 | 4.07M | 159 |     12913 | 521.29K | 447 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'50'' |
| MRX40P011 |   40.0 |  97.80% |     58622 | 4.07M | 160 |     12285 | 519.21K | 424 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'11'' | 0:00'48'' |
| MRX80P000 |   80.0 |  97.62% |     50926 | 4.07M | 167 |     12964 | 527.22K | 422 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:01'49'' | 0:00'48'' |
| MRX80P001 |   80.0 |  97.67% |     52235 |  4.1M | 173 |     11888 | 520.97K | 425 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:01'50'' | 0:00'48'' |
| MRX80P002 |   80.0 |  97.61% |     47360 | 4.09M | 187 |     12115 | 499.52K | 466 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:01'49'' | 0:00'47'' |
| MRX80P003 |   80.0 |  97.71% |     53820 | 4.11M | 191 |     11888 |  504.4K | 471 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:01'49'' | 0:00'49'' |
| MRX80P004 |   80.0 |  97.62% |     54304 | 4.09M | 173 |     10356 | 499.73K | 433 |   70.0 | 5.0 |  18.3 | 127.5 | "31,41,51,61,71,81" | 0:01'50'' | 0:00'50'' |
| MRX80P005 |   80.0 |  97.55% |     45073 | 4.09M | 188 |     12749 | 516.63K | 454 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:01'48'' | 0:00'48'' |


Table: statMRTadpoleAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  98.15% |     63827 | 4.08M | 156 |     16289 | 541.27K | 428 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'50'' |
| MRX40P001 |   40.0 |  98.15% |     55520 | 4.08M | 159 |     13702 | 526.37K | 435 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'47'' |
| MRX40P002 |   40.0 |  98.05% |     50521 | 4.08M | 163 |     13128 | 501.24K | 441 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'51'' |
| MRX40P003 |   40.0 |  98.15% |     63844 | 4.09M | 153 |     15722 | 539.26K | 415 |   35.0 | 2.0 |   9.7 |  61.5 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'49'' |
| MRX40P004 |   40.0 |  98.02% |     58769 | 4.08M | 154 |     13669 | 496.26K | 441 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'51'' |
| MRX40P005 |   40.0 |  98.18% |     61369 | 4.07M | 156 |     12962 | 481.89K | 438 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'51'' |
| MRX40P006 |   40.0 |  98.06% |     58832 | 4.08M | 163 |     13168 | 563.44K | 458 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'50'' |
| MRX40P007 |   40.0 |  98.09% |     63816 | 4.08M | 161 |     12569 | 505.51K | 442 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'51'' |
| MRX40P008 |   40.0 |  98.17% |     55338 | 4.08M | 160 |     16964 |  531.8K | 460 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'50'' |
| MRX40P009 |   40.0 |  98.15% |     58609 | 4.08M | 152 |     13737 | 553.28K | 443 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'50'' |
| MRX40P010 |   40.0 |  98.09% |     55114 | 4.07M | 149 |     12962 | 500.03K | 430 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'50'' |
| MRX40P011 |   40.0 |  98.04% |     55818 | 4.07M | 156 |     12962 | 557.22K | 431 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'46'' |
| MRX80P000 |   80.0 |  98.15% |     85002 | 4.09M | 132 |     19036 | 552.31K | 362 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:01'11'' | 0:00'52'' |
| MRX80P001 |   80.0 |  98.14% |     87508 | 4.09M | 135 |     13684 | 514.71K | 364 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'51'' |
| MRX80P002 |   80.0 |  98.06% |     76954 | 4.09M | 137 |     13683 | 483.38K | 353 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:01'09'' | 0:00'51'' |
| MRX80P003 |   80.0 |  98.10% |     76931 | 4.09M | 140 |     12962 | 513.65K | 398 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:01'08'' | 0:00'53'' |
| MRX80P004 |   80.0 |  98.12% |     61274 | 4.09M | 144 |     12962 | 519.37K | 367 |   70.0 | 4.0 |  19.3 | 123.0 | "31,41,51,61,71,81" | 0:01'05'' | 0:00'50'' |
| MRX80P005 |   80.0 |  98.01% |     74694 | 4.09M | 146 |     13383 | 570.64K | 387 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'51'' |


Table: statFinal

| Name                             |     N50 |     Sum |    # |
|:---------------------------------|--------:|--------:|-----:|
| Genome                           | 3188524 | 4602977 |    7 |
| Paralogs                         |    2337 |  147155 |   66 |
| 7_mergeKunitigsAnchors.anchors   |   58951 | 4137482 |  178 |
| 7_mergeKunitigsAnchors.others    |    2027 | 2153392 | 1110 |
| 7_mergeTadpoleAnchors.anchors    |   46720 | 4183646 |  185 |
| 7_mergeTadpoleAnchors.others     |   10040 | 1437895 |  451 |
| 7_mergeMRKunitigsAnchors.anchors |  139618 | 4206659 |  162 |
| 7_mergeMRKunitigsAnchors.others  |   20955 |  997062 |  121 |
| 7_mergeMRTadpoleAnchors.anchors  |  131401 | 4188294 |  164 |
| 7_mergeMRTadpoleAnchors.others   |   19586 |  868183 |  114 |
| 7_mergeAnchors.anchors           |  134786 | 4317621 |  163 |
| 7_mergeAnchors.others            |    1766 | 2236837 | 1198 |
| spades.contig                    |  315956 | 4588009 |  122 |
| spades.scaffold                  |  333463 | 4588229 |  118 |
| spades.non-contained             |  315956 | 4566180 |   48 |
| spades.anchor                    |  315854 | 4183548 |   81 |
| megahit.contig                   |   97442 | 4577448 |  210 |
| megahit.non-contained            |   97442 | 4542447 |  133 |
| megahit.anchor                   |  117264 | 4115276 |  131 |
| platanus.contig                  |    6239 | 4729176 | 2060 |
| platanus.scaffold                |  128429 | 4661947 |  946 |
| platanus.non-contained           |  130274 | 4545102 |  103 |
| platanus.anchor                  |  130261 | 4409556 |   82 |


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


Table: statInsertSize

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 443.2 |    277 | 2401.1 |                          7.34% |
| tadpole.bbtools | 263.4 |    264 |   49.5 |                         33.70% |
| genome.picard   | 295.6 |    279 |   47.2 |                             FR |
| genome.picard   | 287.3 |    271 |   33.9 |                             RF |
| tadpole.picard  | 263.8 |    264 |   49.3 |                             FR |
| tadpole.picard  | 243.7 |    249 |   47.4 |                             RF |


Table: statReads

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 5067172 | 5090491 |       2 |
| Paralogs |    1580 |   83364 |      53 |
| Illumina |     251 |   2.19G | 8741140 |
| uniq     |     251 |   2.19G | 8732398 |
| shuffle  |     251 |   2.19G | 8732398 |
| bbduk    |     197 |   1.65G | 8728430 |
| Q20L60   |     178 |   1.32G | 8026247 |
| Q25L60   |     172 |   1.17G | 7424525 |
| Q30L60   |     163 | 940.59M | 6410845 |

```text
#trimmedReads
#Matched        6348326 72.69854%
#Name   Reads   ReadsPct
Reverse_adapter 3297468 37.76131%
pcr_dimer       1741890 19.94744%
TruSeq_Universal_Adapter        535660  6.13417%
PCR_Primers     444159  5.08633%
TruSeq_Adapter_Index_1_6        211269  2.41937%
Nextera_LMP_Read2_External_Adapter      63040   0.72191%
TruSeq_Adapter_Index_11 28985   0.33192%
PhiX_read2_adapter      4649    0.05324%
Bisulfite_R2    3062    0.03506%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]517  2557    0.02928%
I5_Primer_Nextera_XT_Index_Kit_v2_S513  2059    0.02358%
I5_Primer_Nextera_XT_Index_Kit_v2_S511  1410    0.01615%
I5_Primer_Nextera_XT_Index_Kit_v2_S516  1227    0.01405%
Nextera_LMP_Read1_External_Adapter      1213    0.01389%
PhiX_read1_adapter      1207    0.01382%
TruSeq_Adapter_Index_6  1110    0.01271%
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 251 |   2.15G | 8581504 |
| trimmed       | 175 |    1.3G | 8020927 |
| filtered      | 175 |    1.3G | 8001516 |
| ecco          | 175 |    1.3G | 8001516 |
| ecct          | 174 |   1.24G | 7718052 |
| extended      | 212 |   1.55G | 7718052 |
| merged        | 247 |  18.14M |   78201 |
| unmerged.raw  | 212 |   1.52G | 7561650 |
| unmerged.trim | 194 |   1.25G | 7168768 |
| U1            | 196 | 549.09M | 3101812 |
| U2            | 196 | 549.94M | 3101812 |
| Us            | 180 | 153.88M |  965144 |
| pe.cor        | 195 |   1.27G | 8290314 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 187.9 |    189 |  55.6 |          1.80% |
| ihist.merge.txt  | 231.9 |    230 |  65.1 |          2.03% |

```text
#trimmedReads
#Matched        6246041 72.78492%
#Name   Reads   ReadsPct
Reverse_adapter 3209354 37.39850%
pcr_dimer       1740140 20.27780%
TruSeq_Universal_Adapter        535655  6.24197%
PCR_Primers     443712  5.17056%
TruSeq_Adapter_Index_1_6        199564  2.32551%
Nextera_LMP_Read2_External_Adapter      62851   0.73240%
TruSeq_Adapter_Index_11 28948   0.33733%
PhiX_read2_adapter      4649    0.05417%
Bisulfite_R2    3062    0.03568%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]517  2557    0.02980%
I5_Primer_Nextera_XT_Index_Kit_v2_S513  2059    0.02399%
I5_Primer_Nextera_XT_Index_Kit_v2_S511  1410    0.01643%
I5_Primer_Nextera_XT_Index_Kit_v2_S516  1227    0.01430%
Nextera_LMP_Read1_External_Adapter      1212    0.01412%
PhiX_read1_adapter      1207    0.01407%
TruSeq_Adapter_Index_6  1109    0.01292%
```

```text
#filteredReads
#Matched        19411   0.24200%
#Name   Reads   ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome  19364   0.24142%
```


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q20L60 | 258.6 |  203.0 |   21.50% |     165 | "45" | 5.09M | 5.95M |     1.17 | 0:02'35'' |
| Q25L60 | 229.2 |  192.1 |   16.16% |     160 | "43" | 5.09M | 5.68M |     1.11 | 0:02'11'' |
| Q30L60 | 185.0 |  161.8 |   12.54% |     151 | "39" | 5.09M | 5.41M |     1.06 | 0:01'51'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000 |   40.0 |  76.52% |      2090 | 3.49M | 1771 |      1041 | 711.54K | 3912 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'38'' |
| Q20L60X40P001 |   40.0 |  76.32% |      2056 | 3.41M | 1776 |      1040 | 785.41K | 3966 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'40'' |
| Q20L60X40P002 |   40.0 |  78.15% |      2072 | 3.54M | 1793 |      1044 | 773.13K | 3995 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'39'' |
| Q20L60X40P003 |   40.0 |  77.02% |      2078 | 3.47M | 1780 |      1045 | 771.72K | 3951 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'39'' |
| Q20L60X40P004 |   40.0 |  77.74% |      2105 | 3.53M | 1788 |      1040 | 747.89K | 3961 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'39'' |
| Q20L60X80P000 |   80.0 |  47.80% |      1524 | 2.04M | 1339 |      1038 | 542.91K | 3030 |   66.0 | 6.0 |  16.0 | 126.0 | "31,41,51,61,71,81" | 0:01'21'' | 0:00'34'' |
| Q20L60X80P001 |   80.0 |  48.42% |      1489 | 1.97M | 1307 |      1053 | 650.11K | 3048 |   66.0 | 5.0 |  17.0 | 121.5 | "31,41,51,61,71,81" | 0:01'21'' | 0:00'33'' |
| Q25L60X40P000 |   40.0 |  87.03% |      2733 | 4.12M | 1750 |      1024 | 649.89K | 3924 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'42'' |
| Q25L60X40P001 |   40.0 |  86.44% |      2856 |  4.1M | 1695 |      1022 | 608.55K | 3789 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'43'' |
| Q25L60X40P002 |   40.0 |  86.47% |      2621 | 4.09M | 1752 |      1020 | 633.32K | 3907 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'42'' |
| Q25L60X40P003 |   40.0 |  86.89% |      2868 | 4.12M | 1697 |      1016 | 617.95K | 3771 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'44'' |
| Q25L60X80P000 |   80.0 |  69.02% |      1832 | 3.14M | 1778 |      1040 |  605.1K | 3942 |   68.0 | 6.0 |  16.7 | 129.0 | "31,41,51,61,71,81" | 0:01'20'' | 0:00'38'' |
| Q25L60X80P001 |   80.0 |  69.51% |      1855 | 3.08M | 1720 |      1047 | 677.93K | 3862 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:01'21'' | 0:00'41'' |
| Q30L60X40P000 |   40.0 |  97.68% |      7309 | 4.69M | 1042 |      1076 | 615.66K | 2589 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'49'' |
| Q30L60X40P001 |   40.0 |  97.62% |      6730 | 4.67M | 1050 |      1061 | 639.41K | 2603 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'50'' |
| Q30L60X40P002 |   40.0 |  97.74% |      7285 | 4.71M | 1060 |      1022 | 603.21K | 2585 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'48'' |
| Q30L60X40P003 |   40.0 |  97.77% |      7691 | 4.69M | 1040 |      1011 | 607.71K | 2591 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'49'' |
| Q30L60X80P000 |   80.0 |  95.07% |      5195 | 4.75M | 1248 |       840 | 343.74K | 2970 |   74.0 | 5.0 |  19.7 | 133.5 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'47'' |
| Q30L60X80P001 |   80.0 |  95.15% |      5295 | 4.74M | 1230 |       946 | 356.38K | 2906 |   74.0 | 5.0 |  19.7 | 133.5 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'49'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000 |   40.0 |  97.68% |     17458 | 4.94M |  595 |       850 | 281.63K | 1669 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'52'' |
| Q20L60X40P001 |   40.0 |  97.62% |     16074 | 4.92M |  629 |       949 |  347.1K | 1828 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'51'' |
| Q20L60X40P002 |   40.0 |  97.65% |     14433 |  4.9M |  644 |      1016 | 386.33K | 1814 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'51'' |
| Q20L60X40P003 |   40.0 |  97.52% |     15838 | 4.92M |  614 |       902 | 320.69K | 1689 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'49'' |
| Q20L60X40P004 |   40.0 |  97.72% |     18282 | 4.99M |  520 |       854 | 232.72K | 1606 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'52'' |
| Q20L60X80P000 |   80.0 |  94.82% |      5731 | 4.84M | 1171 |       826 | 354.83K | 2994 |   73.0 | 5.0 |  19.3 | 132.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'49'' |
| Q20L60X80P001 |   80.0 |  94.92% |      6292 | 4.83M | 1110 |       876 | 348.08K | 2835 |   73.0 | 5.0 |  19.3 | 132.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'48'' |
| Q25L60X40P000 |   40.0 |  98.20% |     16908 | 5.03M |  529 |      1012 |  238.3K | 1716 |   37.5 | 2.5 |  10.0 |  67.5 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'51'' |
| Q25L60X40P001 |   40.0 |  98.32% |     18575 | 4.97M |  515 |       978 | 281.12K | 1699 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'53'' |
| Q25L60X40P002 |   40.0 |  98.48% |     19993 | 4.99M |  525 |       910 | 292.53K | 1782 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'54'' |
| Q25L60X40P003 |   40.0 |  98.42% |     19791 |    5M |  484 |       888 |  285.2K | 1699 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'55'' |
| Q25L60X80P000 |   80.0 |  96.65% |      7907 | 4.92M |  949 |       813 | 302.37K | 2610 |   74.0 | 5.0 |  19.7 | 133.5 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'51'' |
| Q25L60X80P001 |   80.0 |  96.91% |      7519 | 4.93M |  969 |       813 | 303.98K | 2602 |   75.0 | 4.0 |  20.0 | 130.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'51'' |
| Q30L60X40P000 |   40.0 |  99.09% |     25370 | 5.02M |  393 |       863 |  208.2K | 1421 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'53'' |
| Q30L60X40P001 |   40.0 |  99.13% |     27420 | 4.99M |  418 |       877 | 235.26K | 1512 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'57'' |
| Q30L60X40P002 |   40.0 |  99.07% |     23950 | 5.01M |  438 |       825 | 232.56K | 1461 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'55'' |
| Q30L60X40P003 |   40.0 |  99.09% |     24919 | 5.01M |  443 |       894 | 250.23K | 1518 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'53'' |
| Q30L60X80P000 |   80.0 |  98.71% |     17574 | 5.03M |  504 |       663 | 170.98K | 1721 |   76.0 | 4.0 |  20.0 | 132.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'57'' |
| Q30L60X80P001 |   80.0 |  98.78% |     17943 | 5.04M |  500 |       683 | 174.95K | 1672 |   76.0 | 4.0 |  20.0 | 132.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'54'' |


Table: statMRKunitigsAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  95.85% |      6893 | 4.86M | 1011 |       648 | 245.41K | 2283 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'47'' |
| MRX40P001 |   40.0 |  95.69% |      6898 | 4.85M | 1020 |       572 | 250.12K | 2339 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'46'' |
| MRX40P002 |   40.0 |  95.48% |      5725 | 4.67M | 1196 |       847 | 453.38K | 2536 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'45'' |
| MRX40P003 |   40.0 |  95.70% |      5864 | 4.68M | 1185 |       907 | 453.35K | 2501 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'45'' |
| MRX40P004 |   40.0 |  95.74% |      6899 | 4.88M | 1003 |       503 | 228.49K | 2294 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'47'' |
| MRX40P005 |   40.0 |  95.73% |      6910 | 4.87M | 1015 |       483 | 234.85K | 2292 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'44'' |
| MRX80P000 |   80.0 |  89.97% |      3593 | 4.47M | 1557 |       810 | 398.88K | 3335 |   72.0 | 5.0 |  19.0 | 130.5 | "31,41,51,61,71,81" | 0:01'27'' | 0:00'44'' |
| MRX80P001 |   80.0 |  89.71% |      3409 | 4.43M | 1566 |       980 | 422.11K | 3373 |   72.0 | 5.0 |  19.0 | 130.5 | "31,41,51,61,71,81" | 0:01'27'' | 0:00'45'' |
| MRX80P002 |   80.0 |  90.05% |      3745 | 4.48M | 1505 |       865 | 377.54K | 3208 |   72.0 | 5.0 |  19.0 | 130.5 | "31,41,51,61,71,81" | 0:01'27'' | 0:00'44'' |


Table: statMRTadpoleAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  99.23% |     55774 | 5.09M | 171 |       210 |  73.58K | 699 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'54'' |
| MRX40P001 |   40.0 |  99.24% |     63688 | 5.08M | 174 |       187 |  67.44K | 687 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'55'' |
| MRX40P002 |   40.0 |  99.27% |     60985 | 5.02M | 277 |       963 | 208.65K | 941 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'57'' |
| MRX40P003 |   40.0 |  99.17% |     52530 | 5.08M | 180 |       538 |  75.84K | 662 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'54'' |
| MRX40P004 |   40.0 |  99.24% |     62360 | 5.09M | 170 |       158 |  67.44K | 686 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'56'' |
| MRX40P005 |   40.0 |  99.26% |     54083 | 5.06M | 266 |       834 | 174.02K | 887 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'55'' |
| MRX80P000 |   80.0 |  98.98% |     33249 | 5.08M | 274 |        91 |  66.96K | 862 |   77.0 | 3.0 |  20.0 | 129.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'51'' |
| MRX80P001 |   80.0 |  98.92% |     31882 | 5.08M | 276 |        85 |  63.23K | 816 |   77.0 | 3.0 |  20.0 | 129.0 | "31,41,51,61,71,81" | 0:00'59'' | 0:00'52'' |
| MRX80P002 |   80.0 |  99.00% |     38212 | 5.08M | 251 |       101 |  64.17K | 805 |   77.0 | 3.0 |  20.0 | 129.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'52'' |


Table: statFinal

| Name                             |     N50 |     Sum |    # |
|:---------------------------------|--------:|--------:|-----:|
| Genome                           | 5067172 | 5090491 |    2 |
| Paralogs                         |    1580 |   83364 |   53 |
| 7_mergeKunitigsAnchors.anchors   |   47838 | 5212630 |  256 |
| 7_mergeKunitigsAnchors.others    |    1222 | 4409982 | 3617 |
| 7_mergeTadpoleAnchors.anchors    |  120275 | 5119031 |   90 |
| 7_mergeTadpoleAnchors.others     |    1217 | 1766534 | 1451 |
| 7_mergeMRKunitigsAnchors.anchors |   75932 | 5151785 |  135 |
| 7_mergeMRKunitigsAnchors.others  |    1087 | 1172602 | 1070 |
| 7_mergeMRTadpoleAnchors.anchors  |  129885 | 5114577 |   78 |
| 7_mergeMRTadpoleAnchors.others   |    1220 |  274877 |  230 |
| 7_mergeAnchors.anchors           |  149362 | 5131957 |   81 |
| 7_mergeAnchors.others            |    1256 | 5440201 | 4327 |
| spades.contig                    |  261101 | 5601697 | 1066 |
| spades.scaffold                  |  365083 | 5601847 | 1060 |
| spades.non-contained             |  278455 | 5140010 |   40 |
| spades.anchor                    |   16079 | 4988621 |  526 |
| megahit.contig                   |  116930 | 5251330 |  404 |
| megahit.non-contained            |  116930 | 5125565 |   73 |
| megahit.anchor                   |   67433 | 5002487 |  413 |
| platanus.contig                  |   24766 | 5179989 |  499 |
| platanus.scaffold                |   94955 | 5139198 |  125 |
| platanus.non-contained           |   94955 | 5129046 |   98 |
| platanus.anchor                  |   46384 | 5004003 |  443 |


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

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 406.3 |    274 | 2047.1 |                          8.47% |
| tadpole.bbtools | 275.3 |    269 |   92.1 |                         42.92% |
| genome.picard   | 293.8 |    277 |   47.8 |                             FR |
| genome.picard   | 280.5 |    268 |   29.3 |                             RF |
| tadpole.picard  | 275.2 |    270 |   46.1 |                             FR |
| tadpole.picard  | 268.0 |    267 |   42.2 |                             RF |

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 2961149 | 4033464 |       2 |
| Paralogs |    3483 |  114707 |      48 |
| Illumina |     251 |   1.76G | 7020550 |
| uniq     |     251 |   1.73G | 6883592 |
| shuffle  |     251 |   1.73G | 6883592 |
| bbduk    |     199 |   1.33G | 6878250 |
| Q20L60   |     191 |    1.2G | 6543446 |
| Q25L60   |     188 |    1.1G | 6145100 |
| Q30L60   |     181 |  997.2M | 5862451 |


| Name         | N50 |     Sum |       # |
|:-------------|----:|--------:|--------:|
| clumped      | 251 |   1.62G | 6446850 |
| trimmed      | 186 |   1.13G | 6316697 |
| filtered     | 186 |   1.12G | 6278920 |
| ecco         | 183 |   1.11G | 6278920 |
| ecct         | 183 |   1.09G | 6191735 |
| extended     | 221 |   1.34G | 6191735 |
| merged       | 235 |  629.6M | 2663718 |
| unmerged.raw | 214 | 178.35M |  864298 |
| unmerged     | 208 | 164.76M |  837849 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 193.6 |    187 |  43.2 |         82.01% |
| ihist.merge.txt  | 236.4 |    228 |  51.3 |         86.04% |

```text
#mergeReads
#Matched	37777	0.59805%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	37587	0.59504%
Reverse_adapter	178	0.00282%
```


| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q20L60 | 296.8 |  244.4 |   17.64% |     182 | "111" | 4.03M | 4.56M |     1.13 | 0:02'01'' |
| Q25L60 | 272.8 |  236.1 |   13.44% |     178 | "107" | 4.03M | 4.38M |     1.09 | 0:01'54'' |
| Q30L60 | 247.3 |  221.1 |   10.61% |     172 | "103" | 4.03M | 4.15M |     1.03 | 0:01'44'' |


| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000 |   40.0 |  80.21% |      2596 | 2.97M | 1291 |      1046 | 471.63K | 2815 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'42'' |
| Q20L60X40P001 |   40.0 |  79.96% |      2576 | 2.96M | 1300 |      1034 | 483.52K | 2819 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'42'' |
| Q20L60X40P002 |   40.0 |  79.71% |      2621 | 2.97M | 1270 |      1044 | 447.81K | 2758 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'41'' |
| Q20L60X40P003 |   40.0 |  79.17% |      2670 | 2.96M | 1271 |      1047 | 463.09K | 2773 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'42'' |
| Q20L60X40P004 |   40.0 |  79.25% |      2530 | 3.01M | 1341 |      1024 | 398.67K | 2872 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'41'' |
| Q20L60X40P005 |   40.0 |  78.64% |      2663 | 2.96M | 1269 |      1049 | 420.22K | 2771 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'41'' |
| Q20L60X80P000 |   80.0 |  60.00% |      1777 | 2.17M | 1247 |      1041 | 436.59K | 2722 |   67.0 | 8.0 |  14.3 | 134.0 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'39'' |
| Q20L60X80P001 |   80.0 |  59.64% |      1882 |  2.2M | 1227 |      1048 |  402.6K | 2671 |   68.0 | 8.0 |  14.7 | 136.0 | "31,41,51,61,71,81" | 0:01'11'' | 0:00'39'' |
| Q20L60X80P002 |   80.0 |  59.47% |      1790 | 2.17M | 1256 |      1037 |  427.7K | 2747 |   66.0 | 8.0 |  14.0 | 132.0 | "31,41,51,61,71,81" | 0:01'11'' | 0:00'39'' |
| Q25L60X40P000 |   40.0 |  83.42% |      2909 | 3.11M | 1252 |      1025 |  443.4K | 2730 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'43'' |
| Q25L60X40P001 |   40.0 |  83.59% |      2922 | 3.14M | 1260 |      1034 | 405.71K | 2725 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'42'' |
| Q25L60X40P002 |   40.0 |  83.53% |      3066 | 3.11M | 1212 |      1055 | 436.99K | 2631 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'42'' |
| Q25L60X40P003 |   40.0 |  83.01% |      3035 | 3.09M | 1215 |      1074 | 447.02K | 2653 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'41'' |
| Q25L60X40P004 |   40.0 |  82.83% |      2885 | 3.15M | 1264 |      1020 | 367.84K | 2681 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'42'' |
| Q25L60X80P000 |   80.0 |  68.20% |      1997 | 2.55M | 1346 |      1025 | 386.14K | 2887 |   69.0 | 8.0 |  15.0 | 138.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'40'' |
| Q25L60X80P001 |   80.0 |  68.28% |      2108 | 2.55M | 1304 |      1048 | 399.22K | 2818 |   69.0 | 8.0 |  15.0 | 138.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'40'' |
| Q30L60X40P000 |   40.0 |  92.86% |      6835 | 3.56M |  770 |      1017 | 278.85K | 1684 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'44'' |
| Q30L60X40P001 |   40.0 |  93.38% |      6820 | 3.61M |  774 |      1052 | 240.14K | 1715 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'44'' |
| Q30L60X40P002 |   40.0 |  93.16% |      7493 | 3.61M |  754 |      1046 | 241.07K | 1681 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'44'' |
| Q30L60X40P003 |   40.0 |  93.06% |      7143 | 3.61M |  764 |      1106 | 229.62K | 1660 |   36.0 | 5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'44'' |
| Q30L60X40P004 |   40.0 |  92.99% |      6866 | 3.61M |  759 |      1049 | 229.11K | 1682 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'47'' |
| Q30L60X80P000 |   80.0 |  88.16% |      4091 | 3.44M | 1057 |      1003 | 241.41K | 2202 |   73.0 | 9.0 |  15.3 | 146.0 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'47'' |
| Q30L60X80P001 |   80.0 |  88.39% |      4252 | 3.46M | 1047 |      1017 | 249.07K | 2185 |   73.0 | 9.0 |  15.3 | 146.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'49'' |

| Name          | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000 |   40.0 |  95.89% |     17427 | 3.75M | 417 |      1029 | 160.49K | 1078 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'48'' |
| Q20L60X40P001 |   40.0 |  95.80% |     17174 | 3.75M | 423 |      1177 |  205.7K | 1128 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'46'' |
| Q20L60X40P002 |   40.0 |  95.90% |     15183 | 3.72M | 420 |      1204 | 240.62K | 1101 |   36.0 |  4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'49'' |
| Q20L60X40P003 |   40.0 |  95.95% |     16869 | 3.75M | 410 |      1040 | 187.15K | 1106 |   36.0 |  4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'48'' |
| Q20L60X40P004 |   40.0 |  95.81% |     17154 | 3.73M | 413 |      1080 | 191.23K | 1079 |   35.0 |  5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'49'' |
| Q20L60X40P005 |   40.0 |  95.75% |     16151 | 3.76M | 410 |      1025 | 161.65K | 1101 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'46'' |
| Q20L60X80P000 |   80.0 |  94.34% |      8459 | 3.74M | 681 |       940 | 194.89K | 1804 |   74.0 | 10.0 |  14.7 | 148.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'48'' |
| Q20L60X80P001 |   80.0 |  94.22% |      7711 | 3.74M | 713 |      1119 | 238.82K | 1842 |   74.0 | 10.0 |  14.7 | 148.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'49'' |
| Q20L60X80P002 |   80.0 |  94.04% |      7620 | 3.73M | 698 |       884 |  179.7K | 1812 |   74.0 | 10.0 |  14.7 | 148.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'48'' |
| Q25L60X40P000 |   40.0 |  96.30% |     18548 | 3.76M | 408 |      1060 | 166.57K | 1109 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'49'' |
| Q25L60X40P001 |   40.0 |  96.19% |     16801 | 3.75M | 423 |      1084 | 190.27K | 1117 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'47'' |
| Q25L60X40P002 |   40.0 |  96.27% |     16901 | 3.72M | 411 |      1119 | 207.87K | 1124 |   36.0 |  4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'48'' |
| Q25L60X40P003 |   40.0 |  96.34% |     17078 | 3.74M | 397 |      1079 | 194.39K | 1092 |   36.0 |  4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'48'' |
| Q25L60X40P004 |   40.0 |  96.17% |     17464 | 3.72M | 419 |      1070 | 204.34K | 1117 |   35.0 |  4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'49'' |
| Q25L60X80P000 |   80.0 |  94.98% |      8979 | 3.75M | 647 |      1010 | 187.52K | 1726 |   74.0 | 10.0 |  14.7 | 148.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'48'' |
| Q25L60X80P001 |   80.0 |  94.97% |      8968 | 3.75M | 645 |      1012 | 177.24K | 1698 |   74.0 | 10.0 |  14.7 | 148.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'50'' |
| Q30L60X40P000 |   40.0 |  97.09% |     24910 | 3.75M | 338 |      1157 |  181.8K | 1006 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'50'' |
| Q30L60X40P001 |   40.0 |  97.06% |     20810 | 3.74M | 348 |      1734 |  236.8K | 1014 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'49'' |
| Q30L60X40P002 |   40.0 |  97.06% |     24070 | 3.74M | 333 |      1063 | 194.83K |  976 |   37.0 |  4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'49'' |
| Q30L60X40P003 |   40.0 |  97.22% |     29425 | 3.77M | 301 |      1589 | 203.58K |  938 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'51'' |
| Q30L60X40P004 |   40.0 |  97.12% |     24580 | 3.76M | 322 |      1191 | 191.36K |  998 |   36.0 |  4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'50'' |
| Q30L60X80P000 |   80.0 |  96.47% |     15684 |  3.8M | 417 |      1181 | 147.82K | 1112 |   75.0 | 10.0 |  15.0 | 150.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'49'' |
| Q30L60X80P001 |   80.0 |  96.44% |     15786 | 3.79M | 416 |      1195 |  157.1K | 1097 |   76.0 | 10.0 |  15.3 | 152.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'48'' |


| Name                           |     N50 |     Sum |    # |
|:-------------------------------|--------:|--------:|-----:|
| Genome                         | 2961149 | 4033464 |    2 |
| Paralogs                       |    3483 |  114707 |   48 |
| 7_mergeKunitigsAnchors.anchors |   65194 | 3899368 |  185 |
| 7_mergeKunitigsAnchors.others  |    1230 | 2223542 | 1740 |
| 7_mergeTadpoleAnchors.anchors  |  105317 | 3877896 |   97 |
| 7_mergeTadpoleAnchors.others   |    1364 | 2652558 | 1891 |
| 7_mergeAnchors.anchors         |  105317 | 3877896 |   97 |
| 7_mergeAnchors.others          |    1364 | 2652558 | 1891 |
| tadpole.Q20L60                 |   11044 | 4227237 | 2318 |
| tadpole.Q25L60                 |   15337 | 4186972 | 2005 |
| tadpole.Q30L60                 |   15397 | 4083922 | 1531 |
| spades.contig                  |  176446 | 4935867 | 2075 |
| spades.scaffold                |  246373 | 4936077 | 2072 |
| spades.non-contained           |  246373 | 4006059 |  119 |
| megahit.contig                 |   65594 | 4279268 |  961 |
| megahit.non-contained          |   71994 | 3896759 |  122 |
| megahit.anchor                 |   71891 | 3842292 |  116 |
| platanus.contig                |   76029 | 4005887 |  343 |
| platanus.scaffold              |  104811 | 3955460 |  196 |
| platanus.non-contained         |  104811 | 3927850 |  101 |
| platanus.anchor                |  104641 | 3875225 |  120 |
