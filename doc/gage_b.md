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
    --trim2 "--dedupe" \
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
| genome.bbtools  | 578.3 |    578 | 706.0 |                         49.48% |
| tadpole.bbtools | 557.2 |    571 | 165.2 |                         44.61% |
| genome.picard   | 582.1 |    585 | 146.5 |                             FR |
| tadpole.picard  | 573.8 |    577 | 147.3 |                             FR |


Table: statReads

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 5224283 | 5432652 |       2 |
| Paralogs |    2295 |  223889 |     103 |
| Illumina |     251 | 481.02M | 2080000 |
| clumpify |     251 | 480.99M | 2079856 |
| trim     |     250 | 418.06M | 1875124 |
| filter   |     250 |  417.9M | 1874410 |
| trimmed  |     250 |  417.9M | 1874410 |
| Q20L60   |     250 | 409.44M | 1819194 |
| Q25L60   |     250 | 390.62M | 1761166 |
| Q30L60   |     250 | 352.61M | 1657090 |

```text
#trim
#Matched        5776    0.27771%
#Name   Reads   ReadsPct
Reverse_adapter 4806    0.23107%
```

```text
#filter
#Matched        413     0.02203%
#Name   Reads   ReadsPct
contam_250      311     0.01659%
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 250 |  417.9M | 1874408 |
| ecco          | 250 |  417.9M | 1874408 |
| eccc          | 250 |  417.9M | 1874408 |
| ecct          | 250 | 413.42M | 1850392 |
| extended      | 290 | 486.48M | 1850392 |
| merged        | 585 | 325.44M |  600467 |
| unmerged.raw  | 285 | 156.61M |  649458 |
| unmerged.trim | 285 | 156.61M |  649432 |
| U1            | 290 |  83.78M |  324716 |
| U2            | 269 |  72.83M |  324716 |
| Us            |   0 |       0 |       0 |
| pe.cor        | 516 | 482.64M | 1850366 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 361.9 |    387 |  97.4 |         19.20% |
| ihist.merge.txt  | 542.0 |    564 | 119.8 |         64.90% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q20L60 |  75.4 |   66.5 |   11.83% |     227 | "127" | 5.43M | 5.35M |     0.98 | 0:00'50'' |
| Q25L60 |  71.9 |   65.5 |    8.89% |     224 | "127" | 5.43M | 5.34M |     0.98 | 0:00'51'' |
| Q30L60 |  64.9 |   61.2 |    5.78% |     217 | "127" | 5.43M | 5.34M |     0.98 | 0:00'47'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000  |   40.0 |  97.60% |     27135 | 5.29M | 327 |        84 | 52.25K | 912 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'58'' |
| Q20L60X50P000  |   50.0 |  97.59% |     24575 | 5.29M | 327 |        76 | 53.77K | 942 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'00'' |
| Q20L60X60P000  |   60.0 |  97.56% |     24573 | 5.29M | 325 |        75 | 53.11K | 945 |   57.0 | 7.0 |  12.0 | 114.0 | "31,41,51,61,71,81" | 0:01'27'' | 0:01'00'' |
| Q20L60XallP000 |   66.5 |  97.56% |     24573 | 5.29M | 321 |        81 | 58.39K | 950 |   64.0 | 7.0 |  14.3 | 127.5 | "31,41,51,61,71,81" | 0:01'33'' | 0:01'04'' |
| Q25L60X40P000  |   40.0 |  97.93% |     33201 | 5.29M | 272 |       132 | 62.15K | 893 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:01'09'' | 0:00'56'' |
| Q25L60X50P000  |   50.0 |  97.90% |     34816 |  5.3M | 259 |        79 | 46.29K | 845 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:01'19'' | 0:01'05'' |
| Q25L60X60P000  |   60.0 |  97.93% |     34000 |  5.3M | 261 |        80 | 50.29K | 867 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:01'30'' | 0:01'03'' |
| Q25L60XallP000 |   65.5 |  97.93% |     34485 |  5.3M | 257 |        73 | 47.41K | 866 |   63.0 | 8.0 |  13.0 | 126.0 | "31,41,51,61,71,81" | 0:01'36'' | 0:01'04'' |
| Q30L60X40P000  |   40.0 |  98.34% |     34527 |  5.3M | 260 |       124 | 57.87K | 847 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:01'09'' | 0:00'56'' |
| Q30L60X50P000  |   50.0 |  98.37% |     35353 | 5.31M | 242 |        89 | 50.29K | 841 |   48.0 | 5.0 |  11.0 |  94.5 | "31,41,51,61,71,81" | 0:01'18'' | 0:01'04'' |
| Q30L60X60P000  |   60.0 |  98.39% |     39507 |  5.3M | 233 |        77 | 47.13K | 845 |   57.0 | 7.0 |  12.0 | 114.0 | "31,41,51,61,71,81" | 0:01'30'' | 0:01'02'' |
| Q30L60XallP000 |   61.2 |  98.39% |     39507 |  5.3M | 233 |        78 |  48.6K | 841 |   59.0 | 7.0 |  12.7 | 118.0 | "31,41,51,61,71,81" | 0:01'31'' | 0:01'02'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000  |   40.0 |  98.11% |     32685 | 5.29M | 281 |       138 | 63.79K | 876 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'56'' |
| Q20L60X50P000  |   50.0 |  98.38% |     31679 |  5.3M | 290 |       103 |  61.3K | 909 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:01'05'' |
| Q20L60X60P000  |   60.0 |  98.33% |     31105 |  5.3M | 295 |        83 | 54.75K | 910 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:01'00'' |
| Q20L60XallP000 |   66.5 |  98.29% |     29676 |  5.3M | 302 |        81 |  54.8K | 911 |   64.0 | 8.0 |  13.3 | 128.0 | "31,41,51,61,71,81" | 0:00'59'' | 0:01'00'' |
| Q25L60X40P000  |   40.0 |  98.51% |     34817 | 5.29M | 271 |       139 | 61.17K | 878 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'55'' |
| Q25L60X50P000  |   50.0 |  98.51% |     37193 |  5.3M | 264 |        79 | 48.38K | 852 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:01'03'' |
| Q25L60X60P000  |   60.0 |  98.52% |     35049 |  5.3M | 262 |        81 | 51.03K | 863 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'59'' |
| Q25L60XallP000 |   65.5 |  98.52% |     39507 |  5.3M | 260 |        81 | 50.57K | 868 |   63.0 | 8.0 |  13.0 | 126.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:01'03'' |
| Q30L60X40P000  |   40.0 |  98.84% |     32223 |  5.3M | 277 |        84 | 48.61K | 842 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'56'' |
| Q30L60X50P000  |   50.0 |  98.86% |     34532 |  5.3M | 262 |        87 | 52.11K | 855 |   48.0 | 5.0 |  11.0 |  94.5 | "31,41,51,61,71,81" | 0:00'51'' | 0:01'01'' |
| Q30L60X60P000  |   60.0 |  98.67% |     37011 |  5.3M | 248 |        82 | 50.04K | 841 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:01'01'' |
| Q30L60XallP000 |   61.2 |  98.67% |     37011 |  5.3M | 246 |        80 | 49.06K | 826 |   59.0 | 7.0 |  12.7 | 118.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'58'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |  Sum |   # | N50Others |    Sum |   # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-----:|----:|----------:|-------:|----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  97.88% |     44206 | 5.3M | 232 |       123 | 35.36K | 503 |   38.0 |  5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:01'15'' | 0:00'57'' |
| MRX40P001  |   40.0 |  98.10% |     41643 | 5.3M | 237 |       104 | 32.73K | 540 |   38.0 |  5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:01'16'' | 0:00'55'' |
| MRX50P000  |   50.0 |  97.84% |     37585 | 5.3M | 240 |       108 | 35.62K | 531 |   48.0 |  6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:01'27'' | 0:00'55'' |
| MRX60P000  |   60.0 |  97.83% |     40827 | 5.3M | 238 |       111 | 34.76K | 531 |   58.0 |  8.0 |  11.3 | 116.0 | "31,41,51,61,71,81" | 0:01'40'' | 0:00'57'' |
| MRXallP000 |   88.8 |  97.78% |     36326 | 5.3M | 243 |        95 |  33.2K | 559 |   85.0 | 11.0 |  17.3 | 170.0 | "31,41,51,61,71,81" | 0:02'14'' | 0:00'55'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |  Sum |   # | N50Others |    Sum |   # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-----:|----:|----------:|-------:|----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  98.19% |     44344 | 5.3M | 214 |       403 | 32.11K | 424 |   38.0 |  5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'54'' |
| MRX40P001  |   40.0 |  98.18% |     44396 | 5.3M | 213 |       128 | 26.22K | 438 |   38.0 |  5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'52'' |
| MRX50P000  |   50.0 |  98.13% |     44394 | 5.3M | 216 |       224 | 31.09K | 425 |   48.0 |  6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:01'02'' | 0:00'50'' |
| MRX60P000  |   60.0 |  98.12% |     44391 | 5.3M | 223 |       139 | 33.33K | 462 |   58.0 |  7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:01'08'' | 0:00'58'' |
| MRXallP000 |   88.8 |  98.08% |     44343 | 5.3M | 228 |       107 | 30.04K | 483 |   85.0 | 11.0 |  17.3 | 170.0 | "31,41,51,61,71,81" | 0:01'27'' | 0:00'52'' |


Table: statFinal

| Name                             |     N50 |     Sum |   # |
|:---------------------------------|--------:|--------:|----:|
| Genome                           | 5224283 | 5432652 |   2 |
| Paralogs                         |    2295 |  223889 | 103 |
| 7_mergeKunitigsAnchors.anchors   |   44415 | 5313462 | 213 |
| 7_mergeKunitigsAnchors.others    |    1154 |   35849 |  29 |
| 7_mergeTadpoleAnchors.anchors    |   42802 | 5311308 | 226 |
| 7_mergeTadpoleAnchors.others     |    1220 |   36656 |  30 |
| 7_mergeMRKunitigsAnchors.anchors |   44829 | 5309085 | 217 |
| 7_mergeMRKunitigsAnchors.others  |    1222 |   15402 |  15 |
| 7_mergeMRTadpoleAnchors.anchors  |   47267 | 5312894 | 197 |
| 7_mergeMRTadpoleAnchors.others   |    1062 |   19630 |  19 |
| 7_mergeAnchors.anchors           |   60278 | 5316754 | 171 |
| 7_mergeAnchors.others            |    1222 |   55362 |  46 |
| spades.contig                    |  207648 | 5369686 | 170 |
| spades.scaffold                  |  363888 | 5369999 | 153 |
| spades.non-contained             |  207648 | 5349647 |  60 |
| spades.anchor                    |  207549 | 5323936 |  65 |
| megahit.contig                   |   60414 | 5364907 | 261 |
| megahit.non-contained            |   60414 | 5332053 | 175 |
| megahit.anchor                   |   60380 | 5286253 | 200 |
| platanus.contig                  |   18758 | 5413472 | 633 |
| platanus.scaffold                |  485142 | 5346535 | 230 |
| platanus.non-contained           |  485142 | 5300740 |  39 |
| platanus.anchor                  |  283614 | 5286690 |  47 |

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
    --trim2 "--dedupe" \
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
| tadpole.bbtools | 407.5 |    420 |  84.9 |                         32.42% |
| genome.picard   | 412.9 |    422 |  39.3 |                             FR |
| tadpole.picard  | 408.4 |    421 |  46.7 |                             FR |


Table: statReads

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 3188524 | 4602977 |       7 |
| Paralogs |    2337 |  147155 |      66 |
| Illumina |     251 |  451.8M | 1800000 |
| trim     |     148 |  200.1M | 1452702 |
| Q20L60   |     148 | 193.66M | 1401462 |
| Q25L60   |     139 | 169.12M | 1304625 |
| Q30L60   |     119 | 125.02M | 1123192 |


Table: statTrimReads

| Name     | N50 |     Sum |       # |
|:---------|----:|--------:|--------:|
| clumpify | 251 | 447.53M | 1782994 |
| trim     | 148 |  200.1M | 1452706 |
| filter   | 148 |  200.1M | 1452702 |
| R1       | 164 | 100.24M |  655186 |
| R2       | 133 |  81.51M |  655186 |
| Rs       | 141 |  18.34M |  142330 |


```text
#trim
#Matched        113823  6.38381%
#Name   Reads   ReadsPct
Reverse_adapter 81598   4.57646%
pcr_dimer       14481   0.81217%
PCR_Primers     8081    0.45323%
TruSeq_Universal_Adapter        5665    0.31772%
```

```text
#filter
#Matched        4       0.00028%
#Name   Reads   ReadsPct
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 148 | 199.61M | 1448452 |
| ecco          | 148 | 198.74M | 1448452 |
| ecct          | 148 | 197.43M | 1438685 |
| extended      | 186 | 254.26M | 1438685 |
| merged        | 179 |   6.43M |   37672 |
| unmerged.raw  | 186 | 241.93M | 1363340 |
| unmerged.trim | 186 | 241.89M | 1362656 |
| U1            | 187 |  103.4M |  578890 |
| U2            | 187 | 103.37M |  578890 |
| Us            | 181 |  35.12M |  204876 |
| pe.cor        | 186 | 248.56M | 1642876 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 130.9 |    131 |  36.6 |          5.12% |
| ihist.merge.txt  | 170.6 |    170 |  40.3 |          5.24% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q0L0   |  43.5 |   38.7 |   11.10% |     142 | "39" |  4.6M | 4.55M |     0.99 | 0:00'26'' |
| Q20L60 |  42.1 |   37.9 |    9.98% |     143 | "39" |  4.6M | 4.55M |     0.99 | 0:00'26'' |
| Q25L60 |  36.8 |   34.9 |    5.03% |     135 | "35" |  4.6M | 4.54M |     0.99 | 0:00'24'' |
| Q30L60 |  27.2 |   26.6 |    2.20% |     115 | "31" |  4.6M | 4.52M |     0.98 | 0:00'20'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X30P000    |   30.0 |  97.80% |     22595 | 4.06M | 301 |      6685 | 667.17K | 1190 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'50'' |
| Q0L0XallP000   |   38.7 |  97.75% |     26511 | 4.07M | 266 |      6644 | 669.06K | 1155 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'50'' |
| Q20L60X30P000  |   30.0 |  97.82% |     24355 | 4.06M | 295 |      6975 | 643.36K | 1139 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'48'' |
| Q20L60XallP000 |   37.9 |  97.86% |     27660 | 4.05M | 256 |      7524 |  609.8K | 1050 |   33.0 | 2.0 |   9.0 |  58.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'49'' |
| Q25L60X30P000  |   30.0 |  98.46% |     18199 | 4.05M | 374 |     10922 | 743.29K | 1286 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'47'' |
| Q25L60XallP000 |   34.9 |  98.53% |     20240 | 4.06M | 335 |     12569 | 753.61K | 1210 |   30.0 | 2.0 |   8.0 |  54.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'48'' |
| Q30L60XallP000 |   26.6 |  97.99% |      9432 | 3.97M | 613 |      8800 | 769.77K | 1673 |   23.0 | 2.0 |   5.7 |  43.5 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'43'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X30P000    |   30.0 |  98.38% |     17612 | 4.04M | 379 |      8591 | 767.38K | 1429 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'48'' |
| Q0L0XallP000   |   38.7 |  98.48% |     23115 | 4.06M | 308 |     10138 |  808.3K | 1285 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'50'' |
| Q20L60X30P000  |   30.0 |  98.33% |     16544 | 4.05M | 408 |     10644 | 808.28K | 1466 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'49'' |
| Q20L60XallP000 |   37.9 |  98.45% |     21303 | 4.05M | 336 |     11794 | 822.44K | 1290 |   33.0 | 2.0 |   9.0 |  58.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'49'' |
| Q25L60X30P000  |   30.0 |  98.12% |     11706 |    4M | 538 |      9933 | 770.09K | 1630 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'46'' |
| Q25L60XallP000 |   34.9 |  98.32% |     13908 | 4.01M | 472 |     10922 | 798.04K | 1517 |   30.0 | 2.0 |   8.0 |  54.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'45'' |
| Q30L60XallP000 |   26.6 |  96.88% |      6620 | 3.86M | 845 |      5721 | 800.81K | 2215 |   23.0 | 2.0 |   5.7 |  43.5 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'43'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX30P000  |   30.0 |  97.98% |     17257 | 4.04M | 407 |     11321 | 565.94K | 1034 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'44'' |
| MRXallP000 |   54.0 |  97.86% |     16468 | 4.03M | 413 |     11818 | 556.15K | 1041 |   47.0 | 3.0 |  12.7 |  84.0 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'45'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX30P000  |   30.0 |  98.19% |     16879 | 4.05M | 413 |     11321 | 598.94K | 1127 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'44'' |
| MRXallP000 |   54.0 |  98.21% |     17801 | 4.05M | 385 |     12962 | 602.41K | 1043 |   47.0 | 3.0 |  12.7 |  84.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'46'' |


Table: statFinal

| Name                             |     N50 |     Sum |    # |
|:---------------------------------|--------:|--------:|-----:|
| Genome                           | 3188524 | 4602977 |    7 |
| Paralogs                         |    2337 |  147155 |   66 |
| 7_mergeKunitigsAnchors.anchors   |   33881 | 4098875 |  227 |
| 7_mergeKunitigsAnchors.others    |   13125 |  909256 |  185 |
| 7_mergeTadpoleAnchors.anchors    |   24935 | 4097605 |  297 |
| 7_mergeTadpoleAnchors.others     |   12962 | 1048794 |  210 |
| 7_mergeMRKunitigsAnchors.anchors |   17358 | 4051917 |  404 |
| 7_mergeMRKunitigsAnchors.others  |   12569 |  545008 |   81 |
| 7_mergeMRTadpoleAnchors.anchors  |   17802 | 4063610 |  393 |
| 7_mergeMRTadpoleAnchors.others   |   13345 |  553295 |   77 |
| 7_mergeAnchors.anchors           |   33922 | 4124594 |  232 |
| 7_mergeAnchors.others            |   15760 | 1143183 |  224 |
| spades.contig                    |  164079 | 4576492 |  125 |
| spades.scaffold                  |  173327 | 4576612 |  122 |
| spades.non-contained             |  164079 | 4561084 |   70 |
| spades.anchor                    |    9401 | 3937600 |  605 |
| megahit.contig                   |   56435 | 4573673 |  250 |
| megahit.non-contained            |   56435 | 4538784 |  179 |
| megahit.anchor                   |   10872 | 3917215 |  577 |
| platanus.contig                  |    9448 | 4614992 | 2362 |
| platanus.scaffold                |   73051 | 4546782 |  640 |
| platanus.non-contained           |   73051 | 4454805 |  144 |
| platanus.anchor                  |    4305 | 3555309 | 1087 |

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
    --trim2 "--dedupe" \
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
| genome.bbtools  | 458.7 |    277 | 2524.0 |                          7.42% |
| tadpole.bbtools | 266.7 |    266 |   49.4 |                         35.13% |
| genome.picard   | 295.7 |    279 |   47.4 |                             FR |
| genome.picard   | 287.1 |    271 |   33.8 |                             RF |
| tadpole.picard  | 268.0 |    267 |   49.2 |                             FR |
| tadpole.picard  | 251.5 |    255 |   48.0 |                             RF |


Table: statReads

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 5067172 | 5090491 |       2 |
| Paralogs |    1580 |   83364 |      53 |
| Illumina |     251 |    512M | 2039840 |
| trim     |     176 | 294.68M | 1802402 |
| Q20L60   |     177 | 284.68M | 1725072 |
| Q25L60   |     174 | 258.54M | 1616527 |
| Q30L60   |     164 | 211.65M | 1424177 |


Table: statTrimReads

| Name     | N50 |     Sum |       # |
|:---------|----:|--------:|--------:|
| clumpify | 251 | 511.87M | 2039328 |
| trim     | 176 | 295.71M | 1807284 |
| filter   | 176 | 294.68M | 1802402 |
| R1       | 186 | 157.61M |  901201 |
| R2       | 166 | 137.07M |  901201 |
| Rs       |   0 |       0 |       0 |


```text
#trim
#Matched	1485487	72.84199%
#Name	Reads	ReadsPct
Reverse_adapter	771274	37.82001%
pcr_dimer	408982	20.05474%
TruSeq_Universal_Adapter	124751	6.11726%
PCR_Primers	103991	5.09928%
TruSeq_Adapter_Index_1_6	49154	2.41030%
Nextera_LMP_Read2_External_Adapter	14785	0.72499%
TruSeq_Adapter_Index_11	6630	0.32511%
PhiX_read2_adapter	1008	0.04943%
```

```text
#filter
#Matched	4875	0.26974%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	4869	0.26941%
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 176 | 292.95M | 1790942 |
| ecco          | 176 | 292.89M | 1790942 |
| eccc          | 176 | 292.89M | 1790942 |
| ecct          | 176 |  282.7M | 1732516 |
| extended      | 214 | 351.56M | 1732516 |
| merged        | 235 | 199.15M |  856335 |
| unmerged.raw  | 207 |   3.58M |   19846 |
| unmerged.trim | 207 |   3.57M |   19838 |
| U1            | 227 |   2.04M |    9919 |
| U2            | 184 |   1.53M |    9919 |
| Us            |   0 |       0 |       0 |
| pe.cor        | 234 | 203.58M | 1732508 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 190.3 |    186 |  46.6 |         92.20% |
| ihist.merge.txt  | 232.6 |    226 |  51.6 |         98.85% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q0L0   |  57.9 |   46.4 |   19.93% |     160 | "45" | 5.09M | 5.23M |     1.03 | 0:00'33'' |
| Q20L60 |  55.9 |   45.6 |   18.39% |     163 | "47" | 5.09M | 5.22M |     1.03 | 0:00'33'' |
| Q25L60 |  50.8 |   43.1 |   15.21% |     159 | "43" | 5.09M |  5.2M |     1.02 | 0:00'32'' |
| Q30L60 |  41.6 |   36.6 |   11.93% |     151 | "39" | 5.09M | 5.18M |     1.02 | 0:00'27'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  96.33% |      7340 |  4.8M |  993 |       843 | 327.62K | 2295 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'52'' |
| Q0L0XallP000   |   46.4 |  95.81% |      6443 | 4.72M | 1104 |       932 | 393.52K | 2422 |   43.0 | 3.0 |  11.3 |  78.0 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'51'' |
| Q20L60X40P000  |   40.0 |  96.55% |      7239 | 4.81M |  999 |       819 | 328.02K | 2301 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'52'' |
| Q20L60XallP000 |   45.6 |  96.20% |      6802 | 4.74M | 1060 |       942 | 390.98K | 2360 |   42.0 | 3.0 |  11.0 |  76.5 | "31,41,51,61,71,81" | 0:01'02'' | 0:00'53'' |
| Q25L60X40P000  |   40.0 |  97.41% |      9393 |  4.9M |  839 |       771 | 267.73K | 2080 |   38.0 | 3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'54'' |
| Q25L60XallP000 |   43.1 |  97.32% |      8545 | 4.83M |  900 |       916 | 350.87K | 2145 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'59'' | 0:00'53'' |
| Q30L60XallP000 |   36.6 |  98.50% |     12199 |  4.8M |  821 |      1018 | 508.46K | 2174 |   35.0 | 2.0 |   9.7 |  61.5 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'56'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  98.45% |     15047 | 4.88M | 690 |       890 | 417.01K | 1949 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'59'' |
| Q0L0XallP000   |   46.4 |  98.10% |     13424 | 4.95M | 663 |       699 | 244.38K | 1849 |   44.0 | 3.0 |  11.7 |  79.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'56'' |
| Q20L60X40P000  |   40.0 |  98.42% |     14712 | 4.86M | 699 |       947 | 450.65K | 2033 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'57'' |
| Q20L60XallP000 |   45.6 |  98.14% |     13877 | 4.95M | 674 |       787 | 267.83K | 1867 |   43.0 | 3.0 |  11.3 |  78.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'57'' |
| Q25L60X40P000  |   40.0 |  98.70% |     16328 | 4.87M | 697 |      1001 | 438.92K | 2067 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:01'01'' |
| Q25L60XallP000 |   43.1 |  98.57% |     14714 | 4.83M | 774 |      1012 | 486.26K | 2088 |   41.0 | 2.0 |  11.7 |  70.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'57'' |
| Q30L60XallP000 |   36.6 |  99.01% |     16158 | 4.88M | 707 |      1039 | 528.28K | 2278 |   35.0 | 2.0 |   9.7 |  61.5 | "31,41,51,61,71,81" | 0:00'39'' | 0:01'01'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   40.0 |  97.17% |     11228 | 4.97M | 692 |       181 | 154.17K | 1411 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'49'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   40.0 |  99.32% |     82667 | 5.09M | 134 |       173 | 32.04K | 294 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'52'' |


Table: statFinal

| Name                             |     N50 |     Sum |    # |
|:---------------------------------|--------:|--------:|-----:|
| Genome                           | 5067172 | 5090491 |    2 |
| Paralogs                         |    1580 |   83364 |   53 |
| 7_mergeKunitigsAnchors.anchors   |   16733 | 5063639 |  565 |
| 7_mergeKunitigsAnchors.others    |    1208 |  573957 |  491 |
| 7_mergeTadpoleAnchors.anchors    |   32260 | 5083938 |  342 |
| 7_mergeTadpoleAnchors.others     |    1258 |  679583 |  573 |
| 7_mergeMRKunitigsAnchors.anchors |   11228 | 4968261 |  692 |
| 7_mergeMRKunitigsAnchors.others  |    1141 |   64804 |   59 |
| 7_mergeMRTadpoleAnchors.anchors  |   82667 | 5088714 |  134 |
| 7_mergeMRTadpoleAnchors.others   |    1777 |   12577 |    9 |
| 7_mergeAnchors.anchors           |  110540 | 5106403 |  111 |
| 7_mergeAnchors.others            |    1240 |  903999 |  760 |
| spades.contig                    |  180172 | 5239234 |  329 |
| spades.scaffold                  |  232956 | 5239364 |  325 |
| spades.non-contained             |  232956 | 5124694 |   46 |
| spades.anchor                    |    5697 | 4756525 | 1125 |
| megahit.contig                   |   87942 | 5149473 |  185 |
| megahit.non-contained            |   87942 | 5121866 |  104 |
| megahit.anchor                   |    5566 | 4740409 | 1141 |
| platanus.contig                  |   28043 | 5155455 |  507 |
| platanus.scaffold                |   54673 | 5130026 |  256 |
| platanus.non-contained           |   54673 | 5106060 |  182 |
| platanus.anchor                  |    4476 | 4576516 | 1317 |


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
    --trim2 "--dedupe" \
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
| tadpole.bbtools | 270.7 |    267 |   53.6 |                         41.31% |
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
| trim     |     188 | 274.82M | 1521974 |
| Q20L60   |     189 | 269.59M | 1487422 |
| Q25L60   |     187 |  254.7M | 1429552 |
| Q30L60   |     181 |    225M | 1319873 |


Table: statTrimReads

| Name     | N50 |     Sum |       # |
|:---------|----:|--------:|--------:|
| clumpify | 251 | 397.98M | 1585566 |
| trim     | 189 | 276.54M | 1530194 |
| filter   | 188 | 274.82M | 1521974 |
| R1       | 193 | 141.39M |  760987 |
| R2       | 184 | 133.43M |  760987 |
| Rs       |   0 |       0 |       0 |


```text
#trim
#Matched	1285780	81.09281%
#Name	Reads	ReadsPct
Reverse_adapter	623363	39.31486%
pcr_dimer	357752	22.56305%
PCR_Primers	183852	11.59535%
TruSeq_Universal_Adapter	49636	3.13049%
TruSeq_Adapter_Index_1_6	47577	3.00063%
Nextera_LMP_Read2_External_Adapter	19456	1.22707%
```

```text
#filter
#Matched	8215	0.53686%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	8211	0.53660%
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 189 | 268.71M | 1484578 |
| ecco          | 189 | 268.68M | 1484578 |
| eccc          | 189 | 268.68M | 1484578 |
| ecct          | 189 | 265.51M | 1467106 |
| extended      | 227 | 323.93M | 1467106 |
| merged        | 239 | 174.34M |  728283 |
| unmerged.raw  | 225 |   2.16M |   10540 |
| unmerged.trim | 225 |   2.16M |   10538 |
| U1            | 238 |   1.17M |    5269 |
| U2            | 213 | 982.78K |    5269 |
| Us            |   0 |       0 |       0 |
| pe.cor        | 238 | 177.23M | 1467104 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 197.2 |    191 |  44.6 |         94.99% |
| ihist.merge.txt  | 239.4 |    232 |  51.4 |         99.28% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q0L0   |  68.1 |   56.9 |   16.50% |     179 | "107" | 4.03M | 3.96M |     0.98 | 0:00'32'' |
| Q20L60 |  66.8 |   56.6 |   15.29% |     180 | "109" | 4.03M | 3.96M |     0.98 | 0:00'30'' |
| Q25L60 |  63.2 |   55.1 |   12.79% |     178 | "107" | 4.03M | 3.94M |     0.98 | 0:00'30'' |
| Q30L60 |  55.8 |   50.3 |    9.91% |     171 | "103" | 4.03M | 3.93M |     0.98 | 0:00'27'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  94.30% |      8662 | 3.68M | 651 |      1032 | 200.69K | 1453 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'46'' |
| Q0L0X50P000    |   50.0 |  93.72% |      7766 | 3.68M | 702 |      1004 |  187.3K | 1519 |   47.0 | 6.0 |   9.7 |  94.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'44'' |
| Q0L0XallP000   |   56.9 |  93.41% |      7457 | 3.68M | 717 |       836 | 164.82K | 1524 |   53.0 | 7.0 |  10.7 | 106.0 | "31,41,51,61,71,81" | 0:00'59'' | 0:00'45'' |
| Q20L60X40P000  |   40.0 |  94.47% |      9584 |  3.7M | 613 |      1015 |    173K | 1372 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'45'' |
| Q20L60X50P000  |   50.0 |  94.04% |      8775 |  3.7M | 655 |      1003 | 172.62K | 1445 |   47.0 | 6.0 |   9.7 |  94.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'44'' |
| Q20L60XallP000 |   56.6 |  93.79% |      7872 |  3.7M | 677 |       902 | 163.74K | 1462 |   53.0 | 7.0 |  10.7 | 106.0 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'44'' |
| Q25L60X40P000  |   40.0 |  96.66% |     25353 | 3.75M | 309 |      1107 | 144.43K |  748 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'46'' |
| Q25L60X50P000  |   50.0 |  96.42% |     20515 | 3.77M | 325 |      1068 | 112.97K |  787 |   47.0 | 6.0 |   9.7 |  94.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'48'' |
| Q25L60XallP000 |   55.1 |  96.23% |     20515 | 3.78M | 331 |      1030 | 109.51K |  791 |   52.0 | 7.0 |  10.3 | 104.0 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'47'' |
| Q30L60X40P000  |   40.0 |  97.01% |     30733 | 3.79M | 268 |      1081 | 106.18K |  698 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'47'' |
| Q30L60X50P000  |   50.0 |  96.77% |     23647 | 3.79M | 288 |      1068 | 104.41K |  736 |   47.0 | 6.0 |   9.7 |  94.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'47'' |
| Q30L60XallP000 |   50.3 |  96.76% |     23647 | 3.78M | 289 |      1118 | 108.97K |  736 |   47.0 | 6.0 |   9.7 |  94.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'48'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  96.63% |     18868 | 3.74M | 381 |      1044 | 189.62K | 1023 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'48'' |
| Q0L0X50P000    |   50.0 |  96.25% |     15901 | 3.77M | 426 |       987 | 144.41K | 1059 |   47.0 | 6.0 |   9.7 |  94.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'48'' |
| Q0L0XallP000   |   56.9 |  95.89% |     13496 | 3.78M | 475 |       843 | 122.64K | 1101 |   54.0 | 7.0 |  11.0 | 108.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'45'' |
| Q20L60X40P000  |   40.0 |  96.77% |     20805 | 3.77M | 347 |      1010 | 145.07K |  975 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'49'' |
| Q20L60X50P000  |   50.0 |  96.21% |     16114 | 3.76M | 432 |      1010 | 146.75K | 1049 |   46.0 | 6.0 |   9.3 |  92.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'47'' |
| Q20L60XallP000 |   56.6 |  95.95% |     13571 | 3.78M | 479 |       807 | 130.56K | 1108 |   53.0 | 7.0 |  10.7 | 106.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'46'' |
| Q25L60X40P000  |   40.0 |  97.52% |     49233 | 3.74M | 244 |      1208 | 192.39K |  707 |   36.0 | 4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'50'' |
| Q25L60X50P000  |   50.0 |  97.51% |     50411 | 3.81M | 189 |      1210 | 114.43K |  547 |   46.0 | 6.0 |   9.3 |  92.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'50'' |
| Q25L60XallP000 |   55.1 |  97.53% |     50483 | 3.83M | 197 |      1060 |  81.02K |  562 |   51.0 | 8.0 |   9.0 | 102.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'52'' |
| Q30L60X40P000  |   40.0 |  97.71% |     46458 | 3.78M | 225 |      1089 | 146.71K |  747 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'53'' |
| Q30L60X50P000  |   50.0 |  97.66% |     55074 |  3.8M | 193 |      1165 | 129.44K |  623 |   46.0 | 6.0 |   9.3 |  92.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'51'' |
| Q30L60XallP000 |   50.3 |  97.66% |     55074 |  3.8M | 192 |      1171 | 130.14K |  621 |   46.0 | 6.0 |   9.3 |  92.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'54'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |  Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-----:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  96.48% |     30177 | 3.8M | 252 |      1115 | 80.03K | 541 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'44'' |
| MRXallP000 |   43.9 |  96.36% |     25558 | 3.8M | 263 |      1074 |  72.1K | 562 |   41.0 | 6.0 |   7.7 |  82.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'44'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  97.25% |     67197 | 3.85M | 139 |      1025 | 39.37K | 321 |   36.0 | 6.0 |   6.0 |  72.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'44'' |
| MRXallP000 |   43.9 |  97.21% |     65613 | 3.84M | 150 |      1046 | 42.08K | 310 |   39.0 | 7.5 |   5.5 |  78.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'45'' |


Table: statFinal

| Name                             |     N50 |     Sum |   # |
|:---------------------------------|--------:|--------:|----:|
| Genome                           | 2961149 | 4033464 |   2 |
| Paralogs                         |    3483 |  114707 |  48 |
| 7_mergeKunitigsAnchors.anchors   |   44133 | 3835013 | 196 |
| 7_mergeKunitigsAnchors.others    |    1346 |  270527 | 211 |
| 7_mergeTadpoleAnchors.anchors    |   71165 | 3847870 | 137 |
| 7_mergeTadpoleAnchors.others     |    1545 |  301641 | 219 |
| 7_mergeMRKunitigsAnchors.anchors |   30194 | 3808752 | 248 |
| 7_mergeMRKunitigsAnchors.others  |    1413 |   57389 |  41 |
| 7_mergeMRTadpoleAnchors.anchors  |   67211 | 3852909 | 137 |
| 7_mergeMRTadpoleAnchors.others   |    1181 |   32489 |  26 |
| 7_mergeAnchors.anchors           |   93111 | 3866362 | 108 |
| 7_mergeAnchors.others            |    1447 |  388965 | 287 |
| spades.contig                    |  246446 | 4155089 | 653 |
| spades.scaffold                  |  259375 | 4155289 | 651 |
| spades.non-contained             |  246446 | 3924714 |  65 |
| spades.anchor                    |  246406 | 3881995 |  97 |
| megahit.contig                   |   87681 | 3957219 | 268 |
| megahit.non-contained            |   87681 | 3890527 | 121 |
| megahit.anchor                   |   70741 | 3802615 | 192 |
| platanus.contig                  |   45319 | 3987204 | 553 |
| platanus.scaffold                |   55684 | 3935409 | 355 |
| platanus.non-contained           |   55684 | 3877479 | 177 |
| platanus.anchor                  |   37197 | 3709019 | 344 |


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
    --trim2 "--dedupe" \
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
| tadpole.bbtools | 196.4 |    189 |   53.4 |                         39.75% |
| genome.picard   | 199.2 |    193 |   47.4 |                             FR |
| tadpole.picard  | 193.5 |    188 |   44.6 |                             FR |


Table: statReads

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 2961149 | 4033464 |       2 |
| Paralogs |    3483 |  114707 |      48 |
| Illumina |     100 | 392.01M | 3920090 |
| trim     |     100 | 289.35M | 3064430 |
| Q25L60   |     100 | 289.35M | 3064430 |


Table: statTrimReads

| Name     | N50 |     Sum |       # |
|:---------|----:|--------:|--------:|
| clumpify | 100 | 362.86M | 3628564 |
| trim     | 100 | 289.36M | 3064578 |
| filter   | 100 | 289.35M | 3064430 |
| R1       | 100 | 147.85M | 1532215 |
| R2       | 100 |  141.5M | 1532215 |
| Rs       |   0 |       0 |       0 |


```text
#trim
#Matched	5987	0.16500%
#Name	Reads	ReadsPct
Reverse_adapter	2158	0.05947%
TruSeq_Universal_Adapter	1422	0.03919%
```

```text
#filter
#Matched	148	0.00483%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	148	0.00483%
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 100 | 287.88M | 3047986 |
| ecco          | 100 | 287.87M | 3047986 |
| eccc          | 100 | 287.87M | 3047986 |
| ecct          | 100 | 283.92M | 3004410 |
| extended      | 140 | 401.94M | 3004410 |
| merged        | 237 | 341.07M | 1446046 |
| unmerged.raw  | 139 |  14.14M |  112318 |
| unmerged.trim | 139 |  14.14M |  112316 |
| U1            | 140 |   7.31M |   56158 |
| U2            | 133 |   6.83M |   56158 |
| Us            |   0 |       0 |       0 |
| pe.cor        | 235 | 356.65M | 3004408 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 158.1 |    160 |  18.3 |         29.61% |
| ihist.merge.txt  | 235.9 |    231 |  41.6 |         96.26% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q0L0   |  71.7 |   61.9 |   13.70% |      94 | "65" | 4.03M | 3.97M |     0.98 | 0:00'35'' |
| Q25L60 |  71.7 |   61.9 |   13.70% |      94 | "65" | 4.03M | 3.97M |     0.98 | 0:00'34'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  93.57% |      3517 | 3.71M | 1309 |      1006 | 260.95K | 4144 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'51'' |
| Q0L0X50P000    |   50.0 |  92.95% |      3429 | 3.67M | 1306 |      1010 | 255.73K | 4118 |   47.0 | 6.0 |   9.7 |  94.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'51'' |
| Q0L0XallP000   |   61.9 |  92.42% |      3316 | 3.62M | 1319 |      1005 |  245.6K | 4049 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'52'' |
| Q25L60X40P000  |   40.0 |  93.26% |      3528 | 3.71M | 1315 |      1001 | 225.74K | 3999 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'50'' |
| Q25L60X50P000  |   50.0 |  92.93% |      3348 | 3.69M | 1332 |      1000 | 234.24K | 4172 |   47.0 | 6.0 |   9.7 |  94.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'51'' |
| Q25L60XallP000 |   61.9 |  92.42% |      3316 | 3.62M | 1319 |      1005 |  245.6K | 4049 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'52'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  95.45% |      5698 | 3.75M |  939 |       848 | 202.59K | 3471 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'32'' | 0:00'52'' |
| Q0L0X50P000    |   50.0 |  95.11% |      4846 | 3.78M | 1047 |       864 | 214.41K | 3741 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'52'' |
| Q0L0XallP000   |   61.9 |  94.80% |      4386 | 3.76M | 1129 |       935 | 236.13K | 3938 |   59.0 | 7.0 |  12.7 | 118.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'53'' |
| Q25L60X40P000  |   40.0 |  95.52% |      6022 | 3.74M |  892 |       913 | 191.91K | 3387 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'32'' | 0:00'52'' |
| Q25L60X50P000  |   50.0 |  95.24% |      4977 | 3.79M | 1027 |       828 | 195.35K | 3665 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:00'32'' | 0:00'53'' |
| Q25L60XallP000 |   61.9 |  94.80% |      4386 | 3.76M | 1129 |       935 | 236.13K | 3938 |   59.0 | 7.0 |  12.7 | 118.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'53'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  94.93% |     11973 | 3.75M | 496 |       658 | 112.68K | 1067 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'43'' |
| MRX40P001  |   40.0 |  94.83% |     11718 | 3.77M | 471 |       247 |  91.13K | 1006 |   38.0 |  5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'43'' |
| MRX50P000  |   50.0 |  94.68% |     10517 | 3.73M | 546 |       576 | 129.92K | 1153 |   46.0 |  5.0 |  10.3 |  91.5 | "31,41,51,61,71,81" | 0:00'59'' | 0:00'45'' |
| MRXallP000 |   88.4 |  93.03% |      8091 |  3.7M | 665 |       136 | 116.47K | 1386 |   82.0 | 10.0 |  17.3 | 164.0 | "31,41,51,61,71,81" | 0:01'31'' | 0:00'45'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  96.39% |     22486 | 3.81M | 309 |       978 | 81.51K | 734 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'46'' |
| MRX40P001  |   40.0 |  96.27% |     22540 | 3.82M | 298 |       429 | 67.69K | 719 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'45'' |
| MRX50P000  |   50.0 |  96.11% |     19757 |  3.8M | 336 |       850 | 88.76K | 777 |   46.0 |  6.0 |   9.3 |  92.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'44'' |
| MRXallP000 |   88.4 |  95.29% |     13179 | 3.79M | 441 |       153 | 84.17K | 945 |   82.0 | 10.0 |  17.3 | 164.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'45'' |


Table: statFinal

| Name                             |     N50 |     Sum |    # |
|:---------------------------------|--------:|--------:|-----:|
| Genome                           | 2961149 | 4033464 |    2 |
| Paralogs                         |    3483 |  114707 |   48 |
| 7_mergeKunitigsAnchors.anchors   |    4413 | 3910112 | 1156 |
| 7_mergeKunitigsAnchors.others    |    1143 |  329072 |  276 |
| 7_mergeTadpoleAnchors.anchors    |    7934 | 3881707 |  737 |
| 7_mergeTadpoleAnchors.others     |    1050 |  267303 |  233 |
| 7_mergeMRKunitigsAnchors.anchors |   17103 | 3834619 |  374 |
| 7_mergeMRKunitigsAnchors.others  |    1099 |  110553 |   99 |
| 7_mergeMRTadpoleAnchors.anchors  |   30515 | 3856509 |  252 |
| 7_mergeMRTadpoleAnchors.others   |    1122 |   80645 |   72 |
| 7_mergeAnchors.anchors           |   32044 | 3892534 |  247 |
| 7_mergeAnchors.others            |    1070 |  502048 |  428 |
| spades.contig                    |  199415 | 3951677 |  172 |
| spades.scaffold                  |  246373 | 3951907 |  167 |
| spades.non-contained             |  199415 | 3920992 |   62 |
| spades.anchor                    |  199396 | 3856327 |  134 |
| megahit.contig                   |   83501 | 3946647 |  203 |
| megahit.non-contained            |   83501 | 3904781 |  109 |
| megahit.anchor                   |   81998 | 3829060 |  209 |
| platanus.contig                  |   13272 | 4002253 | 1377 |
| platanus.scaffold                |  118222 | 3924554 |  168 |
| platanus.non-contained           |  118222 | 3896512 |   78 |
| platanus.anchor                  |  108897 | 3806301 |  231 |


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

