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
- [*Vibrio cholerae* CP1032(5) HiSeq](#vibrio-cholerae-cp10325-hiseq)
    - [VchoH: download](#vchoh-download)
    - [VchoH: template](#vchoh-template)
    - [VchoH: run](#vchoh-run)
- [*Rhodobacter sphaeroides* 2.4.1 Full](#rhodobacter-sphaeroides-241-full)
    - [RsphF: download](#rsphf-download)
    - [RsphF: template](#rsphf-template)
    - [RsphF: run](#rsphf-run)
- [*Mycobacterium abscessus* 6G-0125-R Full](#mycobacterium-abscessus-6g-0125-r-full)
    - [MabsF: download](#mabsf-download)
    - [MabsF: template](#mabsf-template)
    - [MabsF: run](#mabsf-run)
- [*Vibrio cholerae* CP1032(5) Full](#vibrio-cholerae-cp10325-full)
    - [VchoF: download](#vchof-download)
    - [VchoF: template](#vchof-template)
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

## Bcer: template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Bcer

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 5432652 \
    --trim2 "--dedupe --tile" \
    --cov2 "40 50 60 all" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,2,3" \
    --insertsize \
    --sgapreqc \
    --fillanchor \
    --parallel 24

```

## Bcer: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Bcer

cd ${WORKING_DIR}/${BASE_NAME}

bash 0_bsub.sh
#bash 0_master.sh

bsub -w "ended(${BASE_NAME}-9_statFinal)" \
    -q mpi -n 24 -J "${BASE_NAME}-9_quast_competitor" \
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

#bash 0_cleanup.sh

```

Table: statInsertSize

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| genome.bbtools  | 578.3 |    578 | 706.0 |                         49.48% |
| tadpole.bbtools | 557.0 |    570 | 165.2 |                         44.61% |
| genome.picard   | 582.1 |    585 | 146.5 |                             FR |
| tadpole.picard  | 573.7 |    577 | 147.3 |                             FR |


Table: statSgaPreQC

| Item           |  Value |
|:---------------|-------:|
| incorrectBases |  0.11% |
| perfectReads   | 87.97% |
| overlapDepth   | 107.87 |


Table: statReads

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 5224283 | 5432652 |       2 |
| Paralogs |    2295 |  223889 |     103 |
| Illumina |     251 | 481.02M | 2080000 |
| trim     |     250 | 404.33M | 1808956 |
| Q20L60   |     250 | 396.56M | 1758297 |
| Q25L60   |     250 | 379.29M | 1705442 |
| Q30L60   |     250 | 343.98M | 1610253 |


Table: statTrimReads

| Name           | N50 |     Sum |       # |
|:---------------|----:|--------:|--------:|
| clumpify       | 251 | 480.99M | 2079856 |
| filteredbytile | 251 | 463.18M | 2004292 |
| trim           | 250 | 404.49M | 1809642 |
| filter         | 250 | 404.33M | 1808956 |
| R1             | 250 | 209.25M |  904478 |
| R2             | 247 | 195.08M |  904478 |
| Rs             |   0 |       0 |       0 |


```text
#trim
#Matched	5536	0.27621%
#Name	Reads	ReadsPct
Reverse_adapter	4605	0.22976%
```

```text
#filter
#Matched	396	0.02188%
#Name	Reads	ReadsPct
contam_250	299	0.01652%
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 250 | 404.33M | 1808956 |
| ecco          | 250 | 404.33M | 1808956 |
| eccc          | 250 | 404.33M | 1808956 |
| ecct          | 250 | 400.23M | 1787134 |
| extended      | 290 | 470.81M | 1787134 |
| merged        | 586 | 316.27M |  583607 |
| unmerged.raw  | 285 | 149.87M |  619920 |
| unmerged.trim | 285 | 149.86M |  619894 |
| U1            | 290 |  80.03M |  309947 |
| U2            | 270 |  69.83M |  309947 |
| Us            |   0 |       0 |       0 |
| pe.cor        | 518 | 466.71M | 1787108 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 362.0 |    388 |  97.6 |         19.48% |
| ihist.merge.txt  | 541.9 |    564 | 120.0 |         65.31% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q0L0   |  74.4 |   64.7 |   13.04% |     223 | "127" | 5.43M | 5.35M |     0.98 | 0:00'42'' |
| Q20L60 |  73.0 |   64.6 |   11.50% |     226 | "127" | 5.43M | 5.35M |     0.98 | 0:00'40'' |
| Q25L60 |  69.8 |   63.7 |    8.72% |     224 | "127" | 5.43M | 5.34M |     0.98 | 0:00'39'' |
| Q30L60 |  63.3 |   59.7 |    5.75% |     216 | "127" | 5.43M | 5.34M |     0.98 | 0:00'37'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|-------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  97.59% |     25032 | 5.29M | 329 |        78 | 50.83K |  950 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'56'' |
| Q0L0X50P000    |   50.0 |  97.53% |     23982 | 5.29M | 340 |        74 | 51.37K |  956 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'57'' |
| Q0L0X60P000    |   60.0 |  97.51% |     23668 | 5.29M | 347 |        78 | 56.61K | 1002 |   57.5 | 6.5 |  12.7 | 115.0 | "31,41,51,61,71,81" | 0:01'30'' | 0:00'57'' |
| Q0L0XallP000   |   64.7 |  97.49% |     23583 | 5.29M | 348 |        78 | 57.26K | 1000 |   62.0 | 7.0 |  13.7 | 124.0 | "31,41,51,61,71,81" | 0:01'35'' | 0:00'58'' |
| Q20L60X40P000  |   40.0 |  97.71% |     26264 | 5.29M | 313 |        92 | 58.63K |  939 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:01'08'' | 0:00'56'' |
| Q20L60X50P000  |   50.0 |  97.67% |     26264 | 5.29M | 316 |        82 | 52.95K |  924 |   49.0 | 6.0 |  10.3 |  98.0 | "31,41,51,61,71,81" | 0:01'20'' | 0:00'58'' |
| Q20L60X60P000  |   60.0 |  97.61% |     26228 | 5.29M | 315 |        79 | 53.33K |  927 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:01'30'' | 0:00'57'' |
| Q20L60XallP000 |   64.6 |  97.60% |     26227 | 5.29M | 311 |        78 | 52.87K |  929 |   62.0 | 7.0 |  13.7 | 124.0 | "31,41,51,61,71,81" | 0:01'36'' | 0:00'58'' |
| Q25L60X40P000  |   40.0 |  97.91% |     34491 | 5.29M | 268 |       100 | 53.32K |  858 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:01'08'' | 0:00'58'' |
| Q25L60X50P000  |   50.0 |  97.92% |     35379 |  5.3M | 258 |        75 |  45.8K |  857 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'57'' |
| Q25L60X60P000  |   60.0 |  97.91% |     34472 |  5.3M | 258 |        76 | 48.38K |  864 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:01'30'' | 0:01'01'' |
| Q25L60XallP000 |   63.7 |  97.92% |     34816 |  5.3M | 259 |        78 | 50.02K |  858 |   61.0 | 7.0 |  13.3 | 122.0 | "31,41,51,61,71,81" | 0:01'35'' | 0:01'00'' |
| Q30L60X40P000  |   40.0 |  98.32% |     35048 |  5.3M | 256 |        74 | 41.05K |  807 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:01'08'' | 0:00'58'' |
| Q30L60X50P000  |   50.0 |  98.34% |     37670 |  5.3M | 243 |        77 | 43.49K |  816 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'58'' |
| Q30L60XallP000 |   59.7 |  98.36% |     39853 |  5.3M | 234 |        74 | 44.67K |  818 |   57.0 | 7.0 |  12.0 | 114.0 | "31,41,51,61,71,81" | 0:01'29'' | 0:00'58'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  98.42% |     31114 |  5.3M | 284 |        87 | 55.95K | 909 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'59'' |
| Q0L0X50P000    |   50.0 |  98.37% |     31113 |  5.3M | 288 |        78 | 52.78K | 899 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'57'' |
| Q0L0X60P000    |   60.0 |  98.30% |     29454 | 5.29M | 296 |        81 | 54.87K | 909 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'57'' |
| Q0L0XallP000   |   64.7 |  98.25% |     28631 |  5.3M | 306 |        74 | 52.45K | 924 |   63.0 | 8.0 |  13.0 | 126.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'58'' |
| Q20L60X40P000  |   40.0 |  98.41% |     29853 |  5.3M | 289 |        81 | 50.35K | 887 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'57'' |
| Q20L60X50P000  |   50.0 |  98.36% |     31969 | 5.29M | 285 |        81 | 52.51K | 875 |   49.0 | 6.0 |  10.3 |  98.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'57'' |
| Q20L60X60P000  |   60.0 |  98.34% |     31103 | 5.29M | 287 |        83 | 55.67K | 891 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'57'' |
| Q20L60XallP000 |   64.6 |  98.32% |     31103 |  5.3M | 288 |        74 | 49.62K | 886 |   63.0 | 8.0 |  13.0 | 126.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'56'' |
| Q25L60X40P000  |   40.0 |  98.52% |     32309 | 5.29M | 280 |       112 | 55.51K | 854 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'56'' |
| Q25L60X50P000  |   50.0 |  98.53% |     32711 |  5.3M | 266 |        77 | 47.52K | 861 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'58'' |
| Q25L60X60P000  |   60.0 |  98.51% |     37502 |  5.3M | 261 |        84 | 53.62K | 867 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'58'' |
| Q25L60XallP000 |   63.7 |  98.53% |     37499 |  5.3M | 259 |        85 | 54.23K | 865 |   61.0 | 7.0 |  13.3 | 122.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:01'00'' |
| Q30L60X40P000  |   40.0 |  98.62% |     32211 |  5.3M | 271 |        76 |  44.2K | 838 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'55'' |
| Q30L60X50P000  |   50.0 |  98.64% |     34816 |  5.3M | 255 |        77 |  45.7K | 818 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'57'' |
| Q30L60XallP000 |   59.7 |  98.65% |     34816 |  5.3M | 249 |        77 | 47.68K | 819 |   57.0 | 7.0 |  12.0 | 114.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'57'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  97.90% |     39501 |  5.3M | 237 |       120 |  35.2K | 525 |   38.0 |  5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'54'' |
| MRX40P001  |   40.0 |  97.92% |     42344 | 5.29M | 241 |       161 | 41.34K | 531 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:01'15'' | 0:00'54'' |
| MRX50P000  |   50.0 |  97.86% |     37773 |  5.3M | 242 |        98 | 32.32K | 540 |   48.0 |  6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:01'27'' | 0:00'52'' |
| MRX60P000  |   60.0 |  97.85% |     37761 |  5.3M | 245 |        89 | 29.83K | 543 |   57.0 |  8.0 |  11.0 | 114.0 | "31,41,51,61,71,81" | 0:01'40'' | 0:00'53'' |
| MRXallP000 |   85.9 |  97.78% |     34261 |  5.3M | 250 |        93 | 32.89K | 559 |   82.0 | 11.0 |  16.3 | 164.0 | "31,41,51,61,71,81" | 0:02'12'' | 0:00'52'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  98.20% |     42116 |  5.3M | 223 |       335 | 32.91K | 450 |   38.0 |  5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'50'' |
| MRX40P001  |   40.0 |  98.21% |     44343 |  5.3M | 224 |       780 | 39.17K | 449 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'52'' |
| MRX50P000  |   50.0 |  98.18% |     42121 |  5.3M | 225 |       152 | 29.88K | 458 |   48.0 |  6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'50'' |
| MRX60P000  |   60.0 |  98.16% |     42119 |  5.3M | 228 |       144 | 30.55K | 469 |   57.0 |  7.0 |  12.0 | 114.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'49'' |
| MRXallP000 |   85.9 |  98.11% |     41638 | 5.31M | 233 |       131 | 34.94K | 500 |   82.0 | 10.0 |  17.3 | 164.0 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'52'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |  # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|------:|----:|----------:|-------:|---:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |  85.76% |     54782 | 5.33M | 196 |      1071 | 70.74K | 57 |   35.0 | 4.0 |   7.7 |  70.0 | 0:01'00'' |
| 7_mergeKunitigsAnchors   |  86.82% |     44266 | 5.28M | 240 |      1134 | 38.68K | 33 |   34.0 | 4.0 |   7.3 |  68.0 | 0:01'05'' |
| 7_mergeMRKunitigsAnchors |  86.25% |     44167 | 5.28M | 239 |      1138 | 31.15K | 27 |   34.0 | 4.0 |   7.3 |  68.0 | 0:01'00'' |
| 7_mergeMRTadpoleAnchors  |  86.20% |     46060 | 5.29M | 226 |      1152 | 42.52K | 34 |   33.0 | 5.0 |   6.0 |  66.0 | 0:01'00'' |
| 7_mergeTadpoleAnchors    |  86.89% |     41602 |  5.3M | 247 |      1071 | 42.67K | 39 |   34.0 | 4.0 |   7.3 |  68.0 | 0:01'06'' |


Table: statFinal

| Name                   |     N50 |     Sum |   # |
|:-----------------------|--------:|--------:|----:|
| Genome                 | 5224283 | 5432652 |   2 |
| Paralogs               |    2295 |  223889 | 103 |
| 7_mergeAnchors.anchors |   54782 | 5331374 | 196 |
| 7_mergeAnchors.others  |    1071 |   70741 |  57 |
| anchorLong             |   54782 | 5330884 | 195 |
| anchorFill             |  175315 | 5610196 |  60 |
| spades.contig          |  207660 | 5371823 | 190 |
| spades.scaffold        |  362667 | 5372267 | 174 |
| spades.non-contained   |  207660 | 5348387 |  60 |
| spades.anchor          |  207555 | 5331146 |  62 |
| megahit.contig         |   60414 | 5368154 | 274 |
| megahit.non-contained  |   60414 | 5331299 | 173 |
| megahit.anchor         |   60380 | 5286903 | 194 |
| platanus.contig        |   18749 | 5414853 | 646 |
| platanus.scaffold      |  269317 | 5373828 | 243 |
| platanus.non-contained |  269317 | 5326667 |  42 |
| platanus.anchor        |  269267 | 5312079 |  56 |


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

## Rsph: template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Rsph

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
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
    --sgapreqc \
    --fillanchor \
    --parallel 24

```

## Rsph: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Rsph

cd ${WORKING_DIR}/${BASE_NAME}

bash 0_bsub.sh
#bash 0_master.sh

bsub -w "ended(${BASE_NAME}-9_statFinal)" \
    -q mpi -n 24 -J "${BASE_NAME}-9_quast_competitor" \
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

#bash 0_cleanup.sh

```

Table: statInsertSize

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| genome.bbtools  | 440.0 |    422 | 958.8 |                         15.58% |
| tadpole.bbtools | 407.5 |    420 |  83.1 |                         32.41% |
| genome.picard   | 412.9 |    422 |  39.3 |                             FR |
| tadpole.picard  | 408.4 |    421 |  46.7 |                             FR |


Table: statSgaPreQC

| Item           |  Value |
|:---------------|-------:|
| incorrectBases |  2.24% |
| perfectReads   | 13.22% |
| overlapDepth   |  41.80 |


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
#Matched	113823	6.38381%
#Name	Reads	ReadsPct
Reverse_adapter	81598	4.57646%
pcr_dimer	14481	0.81217%
PCR_Primers	8081	0.45323%
TruSeq_Universal_Adapter	5665	0.31772%
```

```text
#filter
#Matched	4	0.00028%
#Name	Reads	ReadsPct
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 148 | 199.61M | 1448452 |
| ecco          | 148 | 198.73M | 1448452 |
| ecct          | 148 | 197.43M | 1438691 |
| extended      | 186 | 254.27M | 1438691 |
| merged        | 180 |    6.4M |   37514 |
| unmerged.raw  | 186 | 241.97M | 1363662 |
| unmerged.trim | 186 | 241.94M | 1363013 |
| U1            | 187 | 103.43M |  579263 |
| U2            | 187 | 103.48M |  579263 |
| Us            | 181 |  35.02M |  204487 |
| pe.cor        | 186 | 248.58M | 1642528 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 131.0 |    131 |  36.4 |          5.12% |
| ihist.merge.txt  | 170.7 |    171 |  40.0 |          5.21% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q0L0   |  43.5 |   38.7 |   11.10% |     143 | "39" |  4.6M | 4.55M |     0.99 | 0:00'26'' |
| Q20L60 |  42.1 |   37.9 |    9.98% |     144 | "39" |  4.6M | 4.55M |     0.99 | 0:00'26'' |
| Q25L60 |  36.8 |   34.9 |    5.03% |     135 | "35" |  4.6M | 4.54M |     0.99 | 0:00'23'' |
| Q30L60 |  27.2 |   26.6 |    2.20% |     115 | "31" |  4.6M | 4.52M |     0.98 | 0:00'20'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X30P000    |   30.0 |  97.86% |     24620 | 4.07M | 300 |      6186 | 673.09K | 1200 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'55'' |
| Q0L0XallP000   |   38.7 |  97.75% |     26511 | 4.07M | 266 |      6644 | 669.06K | 1155 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'57'' |
| Q20L60X30P000  |   30.0 |  97.88% |     25317 | 4.06M | 301 |      7556 | 666.58K | 1157 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'54'' |
| Q20L60XallP000 |   37.9 |  97.86% |     27660 | 4.05M | 256 |      7524 |  609.8K | 1050 |   33.0 | 2.0 |   9.0 |  58.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'54'' |
| Q25L60X30P000  |   30.0 |  98.49% |     17909 | 4.05M | 367 |     11695 | 796.17K | 1303 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'53'' |
| Q25L60XallP000 |   34.9 |  98.53% |     20240 | 4.06M | 335 |     12569 | 753.61K | 1210 |   30.0 | 2.0 |   8.0 |  54.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'55'' |
| Q30L60XallP000 |   26.6 |  97.99% |      9432 | 3.97M | 613 |      8800 | 769.77K | 1673 |   23.0 | 2.0 |   5.7 |  43.5 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'48'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X30P000    |   30.0 |  98.39% |     17653 | 4.05M | 377 |     10141 | 834.24K | 1401 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'53'' |
| Q0L0XallP000   |   38.7 |  98.48% |     23115 | 4.06M | 308 |     10138 | 808.42K | 1287 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'56'' |
| Q20L60X30P000  |   30.0 |  98.23% |     16241 | 4.04M | 413 |      9579 | 811.18K | 1459 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'53'' |
| Q20L60XallP000 |   37.9 |  98.45% |     21303 | 4.05M | 336 |     11794 | 822.44K | 1290 |   33.0 | 2.0 |   9.0 |  58.5 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'55'' |
| Q25L60X30P000  |   30.0 |  98.14% |     12305 |    4M | 530 |      9933 | 811.37K | 1663 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'51'' |
| Q25L60XallP000 |   34.9 |  98.32% |     13908 | 4.01M | 472 |     10922 | 798.04K | 1517 |   30.0 | 2.0 |   8.0 |  54.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'51'' |
| Q30L60XallP000 |   26.6 |  96.88% |      6620 | 3.86M | 845 |      5721 | 800.77K | 2213 |   23.0 | 2.0 |   5.7 |  43.5 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'47'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX30P000  |   30.0 |  97.96% |     16286 | 4.04M | 414 |      9523 | 588.28K | 1075 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'48'' |
| MRXallP000 |   54.0 |  97.87% |     16596 | 4.03M | 415 |     11818 | 558.27K | 1041 |   47.0 | 3.0 |  12.7 |  84.0 | "31,41,51,61,71,81" | 0:01'08'' | 0:00'49'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX30P000  |   30.0 |  98.23% |     16334 | 4.05M | 419 |     11818 | 606.59K | 1156 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'50'' |
| MRXallP000 |   54.0 |  98.22% |     17812 | 4.05M | 387 |     12962 | 605.53K | 1063 |   47.0 | 3.0 |  12.7 |  84.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'51'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |  64.87% |      5577 | 3.63M | 888 |      8202 |   1.43M | 537 |   16.0 | 1.0 |   4.3 |  28.5 | 0:00'46'' |
| 7_mergeKunitigsAnchors   |  75.89% |      5476 | 3.73M | 927 |      8481 |   1.22M | 427 |   16.0 | 1.0 |   4.3 |  28.5 | 0:00'55'' |
| 7_mergeMRKunitigsAnchors |  73.30% |      5006 | 3.67M | 982 |      6743 |  880.5K | 344 |   16.0 | 1.0 |   4.3 |  28.5 | 0:00'48'' |
| 7_mergeMRTadpoleAnchors  |  73.45% |      5112 | 3.69M | 971 |      7674 | 883.39K | 335 |   16.0 | 1.0 |   4.3 |  28.5 | 0:00'49'' |
| 7_mergeTadpoleAnchors    |  75.40% |      5384 | 3.72M | 928 |      9950 |   1.33M | 466 |   16.0 | 1.0 |   4.3 |  28.5 | 0:00'53'' |


Table: statFinal

| Name                   |     N50 |     Sum |    # |
|:-----------------------|--------:|--------:|-----:|
| Genome                 | 3188524 | 4602977 |    7 |
| Paralogs               |    2337 |  147155 |   66 |
| 7_mergeAnchors.anchors |    5577 | 3633663 |  888 |
| 7_mergeAnchors.others  |    8202 | 1428030 |  537 |
| anchorLong             |    5608 | 3632544 |  886 |
| anchorFill             |   75158 | 3965278 |   88 |
| spades.contig          |  164079 | 4576492 |  125 |
| spades.scaffold        |  173327 | 4576612 |  122 |
| spades.non-contained   |  164079 | 4561084 |   70 |
| spades.anchor          |    9401 | 3937600 |  605 |
| megahit.contig         |   56435 | 4574152 |  253 |
| megahit.non-contained  |   56435 | 4538822 |  179 |
| megahit.anchor         |   10872 | 3917215 |  577 |
| platanus.contig        |    9448 | 4614992 | 2362 |
| platanus.scaffold      |   73051 | 4546782 |  640 |
| platanus.non-contained |   73051 | 4454805 |  144 |
| platanus.anchor        |    4305 | 3555309 | 1087 |

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

## Mabs: template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Mabs

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 5090491 \
    --trim2 "--dedupe --tile" \
    --cov2 "40 all" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,2,3" \
    --insertsize \
    --sgapreqc \
    --fillanchor \
    --parallel 24

```

## Mabs: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Mabs

cd ${WORKING_DIR}/${BASE_NAME}

bash 0_bsub.sh
#bash 0_master.sh

bsub -w "ended(${BASE_NAME}-9_statFinal)" \
    -q mpi -n 24 -J "${BASE_NAME}-9_quast_competitor" \
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

#bash 0_cleanup.sh

```


Table: statInsertSize

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 458.7 |    277 | 2523.9 |                          7.42% |
| tadpole.bbtools | 266.7 |    266 |   50.0 |                         35.20% |
| genome.picard   | 295.7 |    279 |   47.4 |                             FR |
| genome.picard   | 287.1 |    271 |   33.8 |                             RF |
| tadpole.picard  | 268.0 |    267 |   49.1 |                             FR |
| tadpole.picard  | 251.4 |    255 |   48.0 |                             RF |


Table: statReads

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 5067172 | 5090491 |       2 |
| Paralogs |    1580 |   83364 |      53 |
| Illumina |     251 |    512M | 2039840 |
| trim     |     176 | 284.05M | 1732490 |
| Q20L60   |     177 | 274.85M | 1661693 |
| Q25L60   |     174 | 250.42M | 1561494 |
| Q30L60   |     165 | 206.07M | 1382046 |


Table: statTrimReads

| Name           | N50 |     Sum |       # |
|:---------------|----:|--------:|--------:|
| clumpify       | 251 | 511.87M | 2039328 |
| filteredbytile | 251 | 489.76M | 1951224 |
| trim           | 177 | 285.03M | 1737136 |
| filter         | 176 | 284.05M | 1732490 |
| R1             | 187 | 151.75M |  866245 |
| R2             | 167 | 132.29M |  866245 |
| Rs             |   0 |       0 |       0 |


```text
#trim
#Matched	1427021	73.13466%
#Name	Reads	ReadsPct
Reverse_adapter	739825	37.91594%
pcr_dimer	395785	20.28393%
TruSeq_Universal_Adapter	117907	6.04272%
PCR_Primers	100489	5.15005%
TruSeq_Adapter_Index_1_6	47133	2.41556%
Nextera_LMP_Read2_External_Adapter	14308	0.73328%
TruSeq_Adapter_Index_11	6047	0.30991%
```

```text
#filter
#Matched	4639	0.26705%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	4633	0.26670%
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 177 | 282.38M | 1721474 |
| ecco          | 177 | 282.33M | 1721474 |
| eccc          | 177 | 282.33M | 1721474 |
| ecct          | 176 | 272.49M | 1665324 |
| extended      | 214 | 338.69M | 1665324 |
| merged        | 235 | 191.41M |  823300 |
| unmerged.raw  | 207 |    3.4M |   18724 |
| unmerged.trim | 207 |    3.4M |   18716 |
| U1            | 228 |   1.93M |    9358 |
| U2            | 185 |   1.46M |    9358 |
| Us            |   0 |       0 |       0 |
| pe.cor        | 234 | 195.63M | 1665316 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 190.3 |    186 |  46.7 |         92.45% |
| ihist.merge.txt  | 232.5 |    226 |  51.6 |         98.88% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q0L0   |  55.8 |   44.9 |   19.61% |     160 | "45" | 5.09M | 5.22M |     1.03 | 0:00'32'' |
| Q20L60 |  54.0 |   44.2 |   18.14% |     163 | "45" | 5.09M | 5.21M |     1.02 | 0:00'31'' |
| Q25L60 |  49.2 |   41.8 |   15.07% |     160 | "43" | 5.09M |  5.2M |     1.02 | 0:00'31'' |
| Q30L60 |  40.5 |   35.7 |   11.90% |     151 | "39" | 5.09M | 5.18M |     1.02 | 0:00'27'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  96.40% |      7645 | 4.83M |  964 |       872 | 309.94K | 2275 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'52'' |
| Q0L0XallP000   |   44.9 |  96.04% |      6814 | 4.78M | 1044 |       839 | 338.52K | 2354 |   42.0 | 3.0 |  11.0 |  76.5 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'52'' |
| Q20L60X40P000  |   40.0 |  96.61% |      7645 | 4.82M |  958 |       769 | 310.79K | 2187 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'54'' |
| Q20L60XallP000 |   44.2 |  96.35% |      7335 | 4.79M | 1002 |       866 | 339.22K | 2238 |   41.0 | 3.0 |  10.7 |  75.0 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'52'' |
| Q25L60X40P000  |   40.0 |  97.44% |      9647 | 4.89M |  814 |       782 | 269.24K | 2054 |   38.0 | 3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'55'' |
| Q25L60XallP000 |   41.8 |  97.38% |      9073 | 4.89M |  840 |       784 | 272.07K | 2061 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'53'' |
| Q30L60XallP000 |   35.7 |  98.53% |     12537 | 4.84M |  785 |       985 | 473.39K | 2154 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'59'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  98.43% |     14286 | 4.89M | 701 |       872 | 412.14K | 2017 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:01'00'' |
| Q0L0XallP000   |   44.9 |  98.14% |     11914 | 4.81M | 829 |       924 | 467.49K | 2083 |   43.0 | 2.0 |  12.3 |  73.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'57'' |
| Q20L60X40P000  |   40.0 |  98.42% |     13961 | 4.85M | 746 |      1003 | 452.85K | 2065 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'59'' |
| Q20L60XallP000 |   44.2 |  98.19% |     12337 | 4.83M | 815 |       952 | 464.22K | 2080 |   42.0 | 2.0 |  12.0 |  72.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'56'' |
| Q25L60X40P000  |   40.0 |  98.68% |     15571 | 4.86M | 704 |      1007 | 458.59K | 2098 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:01'00'' |
| Q25L60XallP000 |   41.8 |  98.59% |     14829 | 4.86M | 733 |       939 | 435.92K | 2070 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:01'00'' |
| Q30L60XallP000 |   35.7 |  99.02% |     16158 | 4.91M | 685 |      1016 | 494.72K | 2274 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:01'01'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor | Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|----:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   38.4 |  97.33% |     11693 |  5M | 655 |       118 | 128.54K | 1350 |   36.0 | 2.0 |  10.0 |  63.0 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'49'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   38.4 |  99.33% |     82667 | 5.09M | 139 |       204 | 35.21K | 306 |   37.0 | 1.0 |  11.3 |  60.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'54'' |


Table: statFinal

| Name                             |     N50 |     Sum |    # |
|:---------------------------------|--------:|--------:|-----:|
| Genome                           | 5067172 | 5090491 |    2 |
| Paralogs                         |    1580 |   83364 |   53 |
| 7_mergeKunitigsAnchors.anchors   |   16631 | 5057541 |  553 |
| 7_mergeKunitigsAnchors.others    |    1194 |  490259 |  431 |
| 7_mergeTadpoleAnchors.anchors    |   28930 | 5071844 |  391 |
| 7_mergeTadpoleAnchors.others     |    1293 |  676321 |  563 |
| 7_mergeMRKunitigsAnchors.anchors |   11693 | 4996696 |  655 |
| 7_mergeMRKunitigsAnchors.others  |    1120 |   50532 |   47 |
| 7_mergeMRTadpoleAnchors.anchors  |   82667 | 5085989 |  139 |
| 7_mergeMRTadpoleAnchors.others   |    1481 |   13976 |   11 |
| 7_mergeAnchors.anchors           |  107248 | 5108589 |  113 |
| 7_mergeAnchors.others            |    1233 |  865210 |  729 |
| spades.contig                    |  166677 | 5234521 |  319 |
| spades.scaffold                  |  201029 | 5234651 |  315 |
| spades.non-contained             |  166677 | 5124748 |   48 |
| spades.anchor                    |    4125 | 4531765 | 1389 |
| megahit.contig                   |   87942 | 5149197 |  186 |
| megahit.non-contained            |   87942 | 5121866 |  106 |
| megahit.anchor                   |    4685 | 4650919 | 1273 |
| platanus.contig                  |   28112 | 5155040 |  519 |
| platanus.scaffold                |   53978 | 5129462 |  264 |
| platanus.non-contained           |   53978 | 5104596 |  187 |
| platanus.anchor                  |    4263 | 4547131 | 1343 |


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

## Vcho: template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Vcho

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 4033464 \
    --trim2 "--dedupe --tile" \
    --cov2 "40 50 all" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,2,3" \
    --insertsize \
    --sgapreqc \
    --fillanchor \
    --parallel 24

```

## Vcho: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Vcho

cd ${WORKING_DIR}/${BASE_NAME}

bash 0_bsub.sh
#bash 0_master.sh

bsub -w "ended(${BASE_NAME}-9_statFinal)" \
    -q mpi -n 24 -J "${BASE_NAME}-9_quast_competitor" \
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

#bash 0_cleanup.sh

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

# MIN_Q_CHAR 64
# NOT gzipped tar
tar xvf V_cholerae_HiSeq.tar.gz raw/reads_1.fastq
tar xvf V_cholerae_HiSeq.tar.gz raw/reads_2.fastq

# convert to ASCII-33
testformat.sh \
    in=raw/reads_1.fastq \
    in2=raw/reads_2.fastq

reformat.sh \
    in=raw/reads_1.fastq \
    in2=raw/reads_2.fastq \
    out=R1.fq.gz \
    out2=R2.fq.gz \
    qin=auto qout=33

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

## VchoH: template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=VchoH

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 4033464 \
    --trim2 "--dedupe --tile" \
    --cov2 "40 50 all" \
    --qual2 "25" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,2,3" \
    --insertsize \
    --sgapreqc \
    --fillanchor \
    --parallel 24

```

## VchoH: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=VchoH

cd ${WORKING_DIR}/${BASE_NAME}

bash 0_bsub.sh
#bash 0_master.sh

bsub -w "ended(${BASE_NAME}-9_statFinal)" \
    -q mpi -n 24 -J "${BASE_NAME}-9_quast_competitor" \
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

#bash 0_cleanup.sh

```

Table: statInsertSize

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 246.2 |    193 | 1278.2 |                         46.93% |
| tadpole.bbtools | 196.5 |    189 |   53.4 |                         39.77% |
| genome.picard   | 199.2 |    193 |   47.4 |                             FR |
| tadpole.picard  | 193.5 |    188 |   44.6 |                             FR |


Table: statSgaPreQC

| Item           |  Value |
|:---------------|-------:|
| incorrectBases |  0.54% |
| perfectReads   | 71.39% |
| overlapDepth   |  86.49 |


Table: statReads

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 2961149 | 4033464 |       2 |
| Paralogs |    3483 |  114707 |      48 |
| Illumina |     100 | 392.01M | 3920090 |
| trim     |     100 | 272.91M | 2879164 |
| Q25L60   |     100 | 247.02M | 2641800 |


Table: statTrimReads

| Name           | N50 |     Sum |       # |
|:---------------|----:|--------:|--------:|
| clumpify       | 100 | 362.86M | 3628564 |
| filteredbytile | 100 | 337.36M | 3373576 |
| trim           | 100 | 272.92M | 2879306 |
| filter         | 100 | 272.91M | 2879164 |
| R1             | 100 | 139.32M | 1439582 |
| R2             | 100 | 133.59M | 1439582 |
| Rs             |   0 |       0 |       0 |


```text
#trim
#Matched	5577	0.16531%
#Name	Reads	ReadsPct
Reverse_adapter	1999	0.05925%
TruSeq_Universal_Adapter	1322	0.03919%
```

```text
#filter
#Matched	142	0.00493%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	142	0.00493%
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 100 | 271.56M | 2864018 |
| ecco          | 100 | 271.55M | 2864018 |
| eccc          | 100 | 271.55M | 2864018 |
| ecct          | 100 | 268.45M | 2830216 |
| extended      | 140 | 379.75M | 2830216 |
| merged        | 237 | 321.72M | 1364088 |
| unmerged.raw  | 140 |  12.95M |  102040 |
| unmerged.trim | 140 |  12.95M |  102038 |
| U1            | 140 |   6.68M |   51019 |
| U2            | 134 |   6.27M |   51019 |
| Us            |   0 |       0 |       0 |
| pe.cor        | 235 | 336.04M | 2830214 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 158.3 |    161 |  18.3 |         30.46% |
| ihist.merge.txt  | 235.8 |    231 |  41.6 |         96.39% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q0L0   |  67.7 |   59.2 |   12.52% |      94 | "65" | 4.03M | 3.96M |     0.98 | 0:00'33'' |
| Q25L60 |  61.3 |   56.7 |    7.54% |      93 | "63" | 4.03M | 3.93M |     0.97 | 0:00'31'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  93.66% |      3708 | 3.72M | 1261 |      1006 | 239.59K | 3998 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'50'' |
| Q0L0X50P000    |   50.0 |  93.42% |      3500 | 3.71M | 1297 |      1004 | 240.71K | 4038 |   47.0 | 6.0 |   9.7 |  94.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'51'' |
| Q0L0XallP000   |   59.2 |  93.09% |      3516 | 3.68M | 1287 |      1005 | 230.35K | 4008 |   56.0 | 7.0 |  11.7 | 112.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'51'' |
| Q25L60X40P000  |   40.0 |  95.14% |      4799 | 3.69M | 1050 |      1003 | 283.81K | 3575 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'52'' |
| Q25L60X50P000  |   50.0 |  95.12% |      4783 | 3.75M | 1056 |       928 | 202.52K | 3547 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'52'' |
| Q25L60XallP000 |   56.7 |  95.09% |      4772 | 3.73M | 1052 |       803 | 206.26K | 3598 |   54.5 | 6.5 |  11.7 | 109.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'53'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  95.67% |      5726 | 3.76M |  918 |       848 | 207.28K | 3415 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'51'' |
| Q0L0X50P000    |   50.0 |  95.32% |      4949 | 3.79M | 1025 |       708 | 201.62K | 3675 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'53'' |
| Q0L0XallP000   |   59.2 |  94.97% |      4477 | 3.78M | 1115 |       729 | 219.59K | 3907 |   56.0 | 7.0 |  11.7 | 112.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'53'' |
| Q25L60X40P000  |   40.0 |  95.66% |      6066 | 3.71M |  872 |       992 | 198.31K | 3140 |   38.0 | 5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'50'' |
| Q25L60X50P000  |   50.0 |  95.51% |      5238 | 3.74M |  971 |       842 | 202.33K | 3484 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'52'' |
| Q25L60XallP000 |   56.7 |  95.36% |      4939 | 3.73M | 1025 |       826 | 235.13K | 3648 |   55.0 | 6.0 |  12.3 | 109.5 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'52'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  94.93% |     12044 | 3.75M | 489 |       623 | 107.52K | 1043 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'44'' |
| MRX40P001  |   40.0 |  95.34% |     13535 | 3.78M | 460 |       302 |  93.74K | 1003 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'45'' |
| MRX50P000  |   50.0 |  94.53% |     11232 | 3.74M | 521 |       534 | 107.49K | 1101 |   46.0 | 6.0 |   9.3 |  92.0 | "31,41,51,61,71,81" | 0:01'11'' | 0:00'43'' |
| MRXallP000 |   83.3 |  93.57% |      8755 | 3.72M | 637 |       129 | 110.34K | 1332 |   77.0 | 9.0 |  16.7 | 154.0 | "31,41,51,61,71,81" | 0:01'44'' | 0:00'44'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  96.56% |     21807 | 3.82M | 299 |       814 | 78.76K | 729 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'47'' |
| MRX40P001  |   40.0 |  96.30% |     21715 | 3.82M | 314 |       334 | 69.39K | 746 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'46'' |
| MRX50P000  |   50.0 |  96.14% |     19450 | 3.81M | 324 |       659 | 75.87K | 756 |   47.0 | 6.0 |   9.7 |  94.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'45'' |
| MRXallP000 |   83.3 |  95.46% |     14753 |  3.8M | 422 |       155 | 80.35K | 913 |   78.0 | 9.0 |  17.0 | 156.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'45'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |  85.68% |     29448 | 3.82M | 296 |      1066 |  665.8K | 580 |   30.0 | 4.0 |   6.0 |  60.0 | 0:00'48'' |
| 7_mergeKunitigsAnchors   |  86.14% |      5497 | 3.78M | 977 |      1069 | 434.85K | 383 |   30.0 | 4.0 |   6.0 |  60.0 | 0:00'57'' |
| 7_mergeMRKunitigsAnchors |  87.23% |     17005 | 3.77M | 414 |      1074 | 154.22K | 146 |   30.0 | 4.0 |   6.0 |  60.0 | 0:00'54'' |
| 7_mergeMRTadpoleAnchors  |  87.57% |     26541 | 3.78M | 323 |      1102 | 123.47K | 109 |   29.0 | 4.0 |   5.7 |  58.0 | 0:00'54'' |
| 7_mergeTadpoleAnchors    |  87.23% |      7337 | 3.78M | 743 |      1052 | 381.24K | 341 |   30.0 | 4.0 |   6.0 |  60.0 | 0:00'56'' |


Table: statFinal

| Name                   |     N50 |     Sum |    # |
|:-----------------------|--------:|--------:|-----:|
| Genome                 | 2961149 | 4033464 |    2 |
| Paralogs               |    3483 |  114707 |   48 |
| 7_mergeAnchors.anchors |   29448 | 3818010 |  296 |
| 7_mergeAnchors.others  |    1066 |  665799 |  580 |
| anchorLong             |   30672 | 3798157 |  263 |
| anchorFill             |  175803 | 3863046 |   62 |
| spades.contig          |  198954 | 3951387 |  169 |
| spades.scaffold        |  246373 | 3951617 |  164 |
| spades.non-contained   |  198954 | 3920941 |   62 |
| spades.anchor          |  198944 | 3851444 |  136 |
| megahit.contig         |   84615 | 3945585 |  197 |
| megahit.non-contained  |   84615 | 3905002 |  108 |
| megahit.anchor         |   83484 | 3828999 |  197 |
| platanus.contig        |   11093 | 3999233 | 1539 |
| platanus.scaffold      |   95194 | 3926993 |  213 |
| platanus.non-contained |   95194 | 3895206 |   89 |
| platanus.anchor        |   61450 | 3756836 |  341 |


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

## RsphF: template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=RsphF

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 4602977 \
    --trim2 "--dedupe" \
    --cov2 "40 80" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,3" \
    --insertsize \
    --sgapreqc \
    --fillanchor \
    --parallel 24

```

## RsphF: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=RsphF

cd ${WORKING_DIR}/${BASE_NAME}

bash 0_bsub.sh
#bash 0_master.sh

bsub -w "ended(${BASE_NAME}-9_statFinal)" \
    -q mpi -n 24 -J "${BASE_NAME}-9_quast_competitor" \
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

#bash 0_cleanup.sh

```

Table: statInsertSize

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 461.7 |    422 | 1296.7 |                         17.09% |
| tadpole.bbtools | 406.2 |    420 |   63.6 |                         32.73% |
| genome.picard   | 413.0 |    422 |   39.3 |                             FR |
| tadpole.picard  | 407.7 |    421 |   47.4 |                             FR |


Table: statReads

| Name     |     N50 |     Sum |        # |
|:---------|--------:|--------:|---------:|
| Genome   | 3188524 | 4602977 |        7 |
| Paralogs |    2337 |  147155 |       66 |
| Illumina |     251 |   4.24G | 16881336 |
| trim     |     149 |    1.7G | 12278062 |
| Q20L60   |     149 |   1.66G | 11937455 |
| Q25L60   |     140 |   1.46G | 11212115 |
| Q30L60   |     119 |   1.09G |  9751362 |


Table: statTrimReads

| Name     | N50 |     Sum |        # |
|:---------|----:|--------:|---------:|
| clumpify | 251 |    4.2G | 16724610 |
| trim     | 149 |    1.7G | 12278092 |
| filter   | 149 |    1.7G | 12278062 |
| R1       | 164 | 938.85M |  6139031 |
| R2       | 133 | 763.84M |  6139031 |
| Rs       |   0 |       0 |        0 |


```text
#trim
#Matched	1067196	6.38099%
#Name	Reads	ReadsPct
Reverse_adapter	762778	4.56081%
pcr_dimer	135661	0.81115%
PCR_Primers	75219	0.44975%
TruSeq_Universal_Adapter	54684	0.32697%
TruSeq_Adapter_Index_1_6	7437	0.04447%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N702	5544	0.03315%
TruSeq_Adapter_Index_12	2735	0.01635%
RNA_PCR_Primer_Index_21_(RPI21)	2344	0.01402%
I5_Nextera_Transposase_2	2219	0.01327%
I7_Nextera_Transposase_1	1640	0.00981%
TruSeq_Adapter_Index_2	1622	0.00970%
I5_Nextera_Transposase_1	1508	0.00902%
I5_Adapter_Nextera	1406	0.00841%
I5_Primer_Nextera_XT_Index_Kit_v2_S511	1129	0.00675%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	1056	0.00631%
```

```text
#filter
#Matched	16	0.00013%
#Name	Reads	ReadsPct
```


Table: statMergeReads

| Name          | N50 |     Sum |        # |
|:--------------|----:|--------:|---------:|
| clumped       | 149 |    1.7G | 12277870 |
| ecco          | 149 |    1.7G | 12277870 |
| ecct          | 149 |   1.69G | 12180566 |
| extended      | 187 |   2.17G | 12180566 |
| merged        | 459 |   2.06G |  4874951 |
| unmerged.raw  | 157 | 363.95M |  2430664 |
| unmerged.trim | 157 | 363.88M |  2430196 |
| U1            | 169 | 194.68M |  1215098 |
| U2            | 145 |  169.2M |  1215098 |
| Us            |   0 |       0 |        0 |
| pe.cor        | 456 |   2.42G | 12180098 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 189.2 |    185 |  65.3 |         10.72% |
| ihist.merge.txt  | 421.6 |    457 |  87.1 |         80.05% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q0L0   | 369.9 |  333.3 |    9.89% |     145 | "39" |  4.6M | 5.11M |     1.11 | 0:02'53'' |
| Q20L60 | 360.1 |  326.4 |    9.35% |     145 | "39" |  4.6M |  4.8M |     1.04 | 0:02'52'' |
| Q25L60 | 316.9 |  301.4 |    4.90% |     137 | "35" |  4.6M | 4.59M |     1.00 | 0:02'39'' |
| Q30L60 | 236.3 |  231.2 |    2.16% |     116 | "31" |  4.6M | 4.55M |     0.99 | 0:02'02'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  89.17% |      6301 |    4M |  878 |      1483 | 455.56K | 2963 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'53'' |
| Q0L0X40P001   |   40.0 |  89.09% |      5945 | 3.99M |  922 |      1439 | 460.65K | 3111 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'54'' |
| Q0L0X40P002   |   40.0 |  89.07% |      6149 | 3.99M |  880 |      1477 |  457.7K | 2978 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'53'' |
| Q0L0X40P003   |   40.0 |  89.32% |      6120 |    4M |  900 |      1488 | 458.28K | 3004 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'52'' |
| Q0L0X40P004   |   40.0 |  88.73% |      6081 | 3.98M |  929 |      1386 | 451.18K | 3044 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'53'' |
| Q0L0X40P005   |   40.0 |  88.71% |      6231 | 3.99M |  906 |      1454 | 459.96K | 3012 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'54'' |
| Q0L0X40P006   |   40.0 |  88.80% |      6383 | 3.99M |  868 |      1368 | 450.07K | 2964 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'53'' |
| Q0L0X40P007   |   40.0 |  89.39% |      6396 |    4M |  887 |      1427 | 460.82K | 3080 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'53'' |
| Q0L0X80P000   |   80.0 |  75.17% |      2774 |  3.5M | 1428 |      1041 | 371.14K | 3584 |   64.0 | 6.0 |  15.3 | 123.0 | "31,41,51,61,71,81" | 0:01'22'' | 0:00'47'' |
| Q0L0X80P001   |   80.0 |  75.55% |      2763 | 3.53M | 1443 |      1056 | 358.97K | 3596 |   64.0 | 6.0 |  15.3 | 123.0 | "31,41,51,61,71,81" | 0:01'22'' | 0:00'49'' |
| Q0L0X80P002   |   80.0 |  74.53% |      2607 | 3.46M | 1481 |      1039 |  376.7K | 3648 |   64.0 | 6.0 |  15.3 | 123.0 | "31,41,51,61,71,81" | 0:01'22'' | 0:00'48'' |
| Q0L0X80P003   |   80.0 |  74.93% |      2854 | 3.53M | 1438 |      1025 | 333.73K | 3597 |   64.0 | 6.0 |  15.3 | 123.0 | "31,41,51,61,71,81" | 0:01'23'' | 0:00'48'' |
| Q20L60X40P000 |   40.0 |  92.67% |      8735 | 4.02M |  697 |      1710 | 541.21K | 2611 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'55'' |
| Q20L60X40P001 |   40.0 |  92.41% |      8644 | 4.02M |  682 |      1857 |  515.1K | 2511 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'54'' |
| Q20L60X40P002 |   40.0 |  92.51% |      9533 | 4.04M |  653 |      1787 | 521.86K | 2456 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'55'' |
| Q20L60X40P003 |   40.0 |  92.59% |      8898 | 4.04M |  689 |      1806 | 509.16K | 2542 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'55'' |
| Q20L60X40P004 |   40.0 |  92.45% |      9184 | 4.02M |  682 |      1639 | 515.53K | 2469 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'55'' |
| Q20L60X40P005 |   40.0 |  91.74% |      8564 | 4.01M |  685 |      1888 | 530.47K | 2545 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'55'' |
| Q20L60X40P006 |   40.0 |  92.46% |      8965 | 4.02M |  672 |      1889 | 514.22K | 2409 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'54'' |
| Q20L60X40P007 |   40.0 |  92.76% |      9102 | 4.03M |  695 |      1893 | 534.68K | 2545 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'55'' |
| Q20L60X80P000 |   80.0 |  83.87% |      4358 | 3.88M | 1137 |      1159 | 382.62K | 3204 |   66.0 | 6.0 |  16.0 | 126.0 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'52'' |
| Q20L60X80P001 |   80.0 |  84.37% |      4287 | 3.87M | 1134 |      1167 | 387.83K | 3184 |   66.0 | 6.0 |  16.0 | 126.0 | "31,41,51,61,71,81" | 0:01'22'' | 0:00'51'' |
| Q20L60X80P002 |   80.0 |  84.13% |      4232 | 3.86M | 1148 |      1176 | 388.11K | 3221 |   66.0 | 6.0 |  16.0 | 126.0 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'52'' |
| Q20L60X80P003 |   80.0 |  84.32% |      4439 | 3.85M | 1119 |      1179 | 386.59K | 3063 |   66.0 | 6.0 |  16.0 | 126.0 | "31,41,51,61,71,81" | 0:01'23'' | 0:00'50'' |
| Q25L60X40P000 |   40.0 |  97.48% |     18529 | 4.06M |  415 |      4793 | 655.48K | 1553 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'55'' |
| Q25L60X40P001 |   40.0 |  97.44% |     17434 | 4.06M |  397 |      4463 |  692.3K | 1551 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'57'' |
| Q25L60X40P002 |   40.0 |  97.28% |     16877 | 4.07M |  397 |      5269 | 645.57K | 1472 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'54'' |
| Q25L60X40P003 |   40.0 |  97.55% |     17936 | 4.06M |  389 |      4380 | 650.65K | 1506 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'56'' |
| Q25L60X40P004 |   40.0 |  97.52% |     17056 | 4.04M |  394 |      5613 | 675.56K | 1491 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'55'' |
| Q25L60X40P005 |   40.0 |  97.74% |     17443 | 4.07M |  390 |      5811 | 645.97K | 1455 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'53'' |
| Q25L60X40P006 |   40.0 |  97.34% |     16054 | 4.05M |  418 |      4766 |  649.2K | 1517 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'53'' |
| Q25L60X80P000 |   80.0 |  96.03% |     17682 | 4.07M |  415 |      2810 | 553.18K | 1719 |   70.0 | 6.0 |  17.3 | 132.0 | "31,41,51,61,71,81" | 0:01'23'' | 0:00'59'' |
| Q25L60X80P001 |   80.0 |  96.27% |     18303 | 4.06M |  384 |      3353 | 604.91K | 1599 |   70.0 | 5.0 |  18.3 | 127.5 | "31,41,51,61,71,81" | 0:01'23'' | 0:00'58'' |
| Q25L60X80P002 |   80.0 |  96.34% |     17006 | 4.07M |  395 |      3679 | 593.78K | 1689 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:01'23'' | 0:00'58'' |
| Q30L60X40P000 |   40.0 |  98.33% |     12870 |    4M |  500 |      7823 | 783.61K | 1533 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'51'' |
| Q30L60X40P001 |   40.0 |  98.09% |     12962 | 3.99M |  526 |      8065 | 776.35K | 1631 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'54'' |
| Q30L60X40P002 |   40.0 |  98.26% |     12729 | 3.99M |  523 |      8131 | 751.29K | 1598 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'52'' |
| Q30L60X40P003 |   40.0 |  98.10% |     12622 | 3.99M |  518 |      8974 | 740.38K | 1558 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'51'' |
| Q30L60X40P004 |   40.0 |  98.03% |     12702 |    4M |  513 |      7879 | 693.11K | 1564 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'53'' |
| Q30L60X80P000 |   80.0 |  98.41% |     18471 | 4.04M |  380 |      9002 | 780.23K | 1317 |   70.0 | 6.0 |  17.3 | 132.0 | "31,41,51,61,71,81" | 0:01'17'' | 0:00'58'' |
| Q30L60X80P001 |   80.0 |  98.42% |     18252 | 4.03M |  395 |      9826 | 771.46K | 1348 |   70.0 | 5.0 |  18.3 | 127.5 | "31,41,51,61,71,81" | 0:01'17'' | 0:00'55'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  97.81% |     20982 | 4.04M | 343 |      6863 | 726.41K | 1413 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'57'' |
| Q0L0X40P001   |   40.0 |  97.75% |     21080 | 4.06M | 351 |      8267 | 798.78K | 1444 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'56'' |
| Q0L0X40P002   |   40.0 |  97.73% |     21294 | 4.06M | 349 |      7885 |  748.6K | 1397 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'55'' |
| Q0L0X40P003   |   40.0 |  97.82% |     20560 | 4.04M | 346 |      7824 | 786.62K | 1348 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'56'' |
| Q0L0X40P004   |   40.0 |  97.68% |     20324 | 4.03M | 365 |      7804 | 755.91K | 1390 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'54'' |
| Q0L0X40P005   |   40.0 |  97.66% |     21121 | 4.06M | 353 |      6019 | 748.33K | 1421 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'56'' |
| Q0L0X40P006   |   40.0 |  97.68% |     19016 | 4.06M | 356 |      6510 | 725.16K | 1335 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'53'' |
| Q0L0X40P007   |   40.0 |  97.78% |     18203 | 4.04M | 361 |      7557 | 754.71K | 1418 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'56'' |
| Q0L0X80P000   |   80.0 |  97.75% |     19560 |  4.1M | 357 |      4825 | 791.35K | 1716 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:01'01'' |
| Q0L0X80P001   |   80.0 |  97.71% |     19936 | 4.08M | 350 |      5693 |  775.6K | 1679 |   68.0 | 5.0 |  17.7 | 124.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:01'01'' |
| Q0L0X80P002   |   80.0 |  97.71% |     19787 | 4.08M | 362 |      5149 | 676.88K | 1710 |   68.0 | 5.0 |  17.7 | 124.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:01'01'' |
| Q0L0X80P003   |   80.0 |  97.70% |     20578 | 4.08M | 343 |      4767 | 727.35K | 1718 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:01'01'' |
| Q20L60X40P000 |   40.0 |  98.01% |     20324 | 4.04M | 364 |      8600 | 775.69K | 1371 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'54'' |
| Q20L60X40P001 |   40.0 |  98.02% |     16823 | 4.05M | 395 |      8632 | 714.33K | 1412 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'54'' |
| Q20L60X40P002 |   40.0 |  98.03% |     19400 | 4.05M | 378 |      8448 | 770.24K | 1465 |   34.5 | 2.5 |   9.0 |  63.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'56'' |
| Q20L60X40P003 |   40.0 |  98.12% |     18949 | 4.03M | 376 |      7728 | 792.71K | 1376 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'55'' |
| Q20L60X40P004 |   40.0 |  98.02% |     19600 | 4.05M | 367 |      7764 | 736.26K | 1376 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'55'' |
| Q20L60X40P005 |   40.0 |  98.09% |     19618 | 4.05M | 387 |      8479 | 793.02K | 1385 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'54'' |
| Q20L60X40P006 |   40.0 |  97.93% |     18995 | 4.04M | 376 |      7296 | 741.76K | 1375 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'55'' |
| Q20L60X40P007 |   40.0 |  97.97% |     19121 | 4.05M | 375 |      8852 | 792.33K | 1387 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'54'' |
| Q20L60X80P000 |   80.0 |  98.14% |     21451 | 4.07M | 339 |      6717 | 735.49K | 1581 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:01'01'' |
| Q20L60X80P001 |   80.0 |  98.09% |     19759 | 4.09M | 334 |      5235 | 781.69K | 1590 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:01'00'' |
| Q20L60X80P002 |   80.0 |  98.11% |     20540 | 4.08M | 350 |      6003 | 709.37K | 1588 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:01'01'' |
| Q20L60X80P003 |   80.0 |  98.09% |     21464 | 4.07M | 337 |      6090 | 795.76K | 1537 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:01'00'' |
| Q25L60X40P000 |   40.0 |  98.31% |     14303 | 4.03M | 469 |      8978 | 739.87K | 1506 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'53'' |
| Q25L60X40P001 |   40.0 |  98.27% |     14291 | 4.01M | 472 |     10624 | 736.97K | 1496 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'53'' |
| Q25L60X40P002 |   40.0 |  98.18% |     13920 | 4.01M | 472 |      9577 | 752.63K | 1511 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'51'' |
| Q25L60X40P003 |   40.0 |  98.34% |     13930 | 4.04M | 467 |      8989 | 760.97K | 1496 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'53'' |
| Q25L60X40P004 |   40.0 |  98.21% |     14636 |    4M | 466 |      7800 | 749.06K | 1537 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'53'' |
| Q25L60X40P005 |   40.0 |  98.29% |     13593 |    4M | 470 |     11818 |  794.2K | 1544 |   34.5 | 2.5 |   9.0 |  63.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'52'' |
| Q25L60X40P006 |   40.0 |  98.23% |     14162 | 4.02M | 468 |      8798 | 694.49K | 1495 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'51'' |
| Q25L60X80P000 |   80.0 |  98.65% |     22132 | 4.06M | 315 |     11830 | 701.65K | 1262 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:01'00'' |
| Q25L60X80P001 |   80.0 |  98.55% |     22583 | 4.06M | 324 |     10122 |  726.1K | 1233 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'58'' |
| Q25L60X80P002 |   80.0 |  98.64% |     21401 | 4.06M | 314 |     10924 | 699.01K | 1258 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'56'' |
| Q30L60X40P000 |   40.0 |  97.84% |      8523 | 3.92M | 680 |      6287 | 810.36K | 1977 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'51'' |
| Q30L60X40P001 |   40.0 |  97.82% |      8456 | 3.95M | 709 |      6681 | 723.45K | 1970 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'51'' |
| Q30L60X40P002 |   40.0 |  97.83% |      8273 | 3.93M | 710 |      6219 | 788.98K | 1994 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'51'' |
| Q30L60X40P003 |   40.0 |  97.82% |      8540 | 3.93M | 683 |      6319 | 760.72K | 1932 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'50'' |
| Q30L60X40P004 |   40.0 |  97.77% |      8129 | 3.92M | 700 |      6612 | 772.05K | 1972 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'52'' |
| Q30L60X80P000 |   80.0 |  98.47% |     14097 | 4.02M | 477 |      8852 | 771.27K | 1558 |   69.0 | 6.0 |  17.0 | 130.5 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'56'' |
| Q30L60X80P001 |   80.0 |  98.41% |     13695 | 4.02M | 477 |      8137 |    727K | 1559 |   70.0 | 6.0 |  17.3 | 132.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'55'' |


Table: statMRKunitigsAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  97.72% |     44580 | 4.08M | 184 |     12964 | 537.19K | 475 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'54'' |
| MRX40P001 |   40.0 |  97.75% |     47955 | 4.08M | 178 |     12720 | 529.66K | 481 |   35.0 | 2.0 |   9.7 |  61.5 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'54'' |
| MRX40P002 |   40.0 |  97.68% |     51792 | 4.08M | 176 |     11980 | 493.06K | 487 |   35.0 | 2.0 |   9.7 |  61.5 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'54'' |
| MRX40P003 |   40.0 |  97.65% |     43330 | 4.08M | 183 |     13091 | 543.34K | 491 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'54'' |
| MRX40P004 |   40.0 |  97.69% |     50166 | 4.07M | 162 |     10442 | 486.48K | 436 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'52'' |
| MRX40P005 |   40.0 |  97.72% |     46706 | 4.07M | 174 |     12964 | 492.73K | 471 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'54'' |
| MRX40P006 |   40.0 |  97.69% |     42032 | 4.07M | 170 |     12821 | 522.55K | 448 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'53'' |
| MRX40P007 |   40.0 |  97.70% |     46727 | 4.07M | 182 |     12285 | 481.08K | 474 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'52'' |
| MRX40P008 |   40.0 |  97.70% |     50153 | 4.08M | 181 |     10046 | 491.92K | 472 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'54'' |
| MRX40P009 |   40.0 |  97.80% |     46814 | 4.08M | 171 |     12089 | 514.97K | 449 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'54'' |
| MRX40P010 |   40.0 |  97.72% |     52424 | 4.08M | 174 |     12964 | 497.68K | 480 |   35.0 | 2.0 |   9.7 |  61.5 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'57'' |
| MRX40P011 |   40.0 |  97.68% |     45395 | 4.07M | 169 |     12964 | 515.31K | 459 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'52'' |
| MRX40P012 |   40.0 |  97.59% |     54166 | 4.09M | 171 |     13166 | 474.15K | 467 |   34.5 | 2.5 |   9.0 |  63.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'54'' |
| MRX80P000 |   80.0 |  97.34% |     36961 | 4.07M | 217 |      9285 | 506.18K | 535 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:01'54'' | 0:00'52'' |
| MRX80P001 |   80.0 |  97.25% |     35814 | 4.09M | 226 |     10044 | 472.15K | 542 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:01'55'' | 0:00'51'' |
| MRX80P002 |   80.0 |  97.23% |     40775 | 4.09M | 213 |      9533 | 467.47K | 529 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:01'54'' | 0:00'53'' |
| MRX80P003 |   80.0 |  97.24% |     30945 | 4.07M | 232 |     10050 | 483.05K | 556 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:01'54'' | 0:00'51'' |
| MRX80P004 |   80.0 |  97.35% |     34066 | 4.08M | 227 |      8977 |  493.7K | 579 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:01'55'' | 0:00'53'' |
| MRX80P005 |   80.0 |  97.40% |     34119 | 4.08M | 207 |     10625 | 499.29K | 512 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:01'54'' | 0:00'51'' |


Table: statMRTadpoleAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  97.98% |     53167 | 4.08M | 161 |     15923 |  510.9K | 427 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'53'' |
| MRX40P001 |   40.0 |  98.11% |     58660 | 4.08M | 155 |     13276 | 547.51K | 434 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'54'' |
| MRX40P002 |   40.0 |  98.00% |     58645 | 4.08M | 152 |     11886 | 557.96K | 432 |   35.0 | 2.0 |   9.7 |  61.5 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'54'' |
| MRX40P003 |   40.0 |  98.07% |     50694 | 4.08M | 164 |     20954 | 524.41K | 442 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'53'' |
| MRX40P004 |   40.0 |  98.00% |     53179 | 4.08M | 156 |     13682 | 499.16K | 420 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'53'' |
| MRX40P005 |   40.0 |  98.07% |     58715 | 4.08M | 151 |     17980 | 523.18K | 415 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'53'' |
| MRX40P006 |   40.0 |  98.01% |     60477 | 4.08M | 155 |     18985 | 533.33K | 410 |   35.0 | 2.0 |   9.7 |  61.5 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'53'' |
| MRX40P007 |   40.0 |  98.03% |     53214 | 4.08M | 160 |     13139 |  456.5K | 433 |   35.0 | 2.0 |   9.7 |  61.5 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'54'' |
| MRX40P008 |   40.0 |  98.08% |     66008 | 4.09M | 146 |     13502 |  488.4K | 408 |   35.0 | 2.0 |   9.7 |  61.5 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'55'' |
| MRX40P009 |   40.0 |  98.08% |     58635 | 4.08M | 147 |     16134 | 535.75K | 407 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'05'' | 0:00'57'' |
| MRX40P010 |   40.0 |  98.03% |     58578 | 4.07M | 160 |     13168 | 495.76K | 441 |   35.0 | 2.0 |   9.7 |  61.5 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'55'' |
| MRX40P011 |   40.0 |  98.02% |     58650 | 4.08M | 148 |     13682 | 508.93K | 427 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'55'' |
| MRX40P012 |   40.0 |  97.96% |     58805 | 4.07M | 152 |     16263 | 509.53K | 431 |   34.5 | 1.5 |  10.0 |  58.5 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'53'' |
| MRX80P000 |   80.0 |  98.04% |     63881 | 4.09M | 151 |     13113 | 479.21K | 394 |   70.0 | 4.0 |  19.3 | 123.0 | "31,41,51,61,71,81" | 0:01'05'' | 0:00'57'' |
| MRX80P001 |   80.0 |  98.01% |     72867 | 4.08M | 144 |     12962 | 530.54K | 389 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:01'05'' | 0:00'56'' |
| MRX80P002 |   80.0 |  98.03% |     62604 | 4.08M | 143 |     13252 | 465.33K | 393 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'56'' |
| MRX80P003 |   80.0 |  97.91% |     60921 | 4.07M | 140 |     16480 | 490.25K | 381 |   69.0 | 3.0 |  20.0 | 117.0 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'54'' |
| MRX80P004 |   80.0 |  98.06% |     84348 | 4.09M | 132 |     12962 | 461.04K | 369 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'56'' |
| MRX80P005 |   80.0 |  98.03% |     84399 | 4.09M | 138 |     13564 | 501.64K | 381 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'57'' |


Table: statFinal

| Name                             |     N50 |     Sum |    # |
|:---------------------------------|--------:|--------:|-----:|
| Genome                           | 3188524 | 4602977 |    7 |
| Paralogs                         |    2337 |  147155 |   66 |
| 7_mergeKunitigsAnchors.anchors   |   71989 | 4193926 |  195 |
| 7_mergeKunitigsAnchors.others    |    2171 | 2320447 | 1184 |
| 7_mergeTadpoleAnchors.anchors    |   57021 | 4216148 |  201 |
| 7_mergeTadpoleAnchors.others     |   10305 | 1714013 |  525 |
| 7_mergeMRKunitigsAnchors.anchors |  139785 | 4186473 |  154 |
| 7_mergeMRKunitigsAnchors.others  |   18227 |  899760 |  116 |
| 7_mergeMRTadpoleAnchors.anchors  |  131428 | 4178994 |  157 |
| 7_mergeMRTadpoleAnchors.others   |   19204 |  712752 |   95 |
| 7_mergeAnchors.anchors           |  150989 | 4287283 |  172 |
| 7_mergeAnchors.others            |    1593 | 2101010 | 1197 |
| spades.contig                    |  315956 | 4592241 |  127 |
| spades.scaffold                  |  384710 | 4592461 |  123 |
| spades.non-contained             |  315956 | 4566716 |   43 |
| spades.anchor                    |  315879 | 4123665 |   47 |
| megahit.contig                   |  131525 | 4576036 |  184 |
| megahit.non-contained            |  131525 | 4541205 |  113 |
| megahit.anchor                   |  141488 | 4120676 |  108 |
| platanus.contig                  |    4915 | 4785248 | 2537 |
| platanus.scaffold                |   92293 | 4689321 | 1158 |
| platanus.non-contained           |   92293 | 4537841 |  119 |
| platanus.anchor                  |   96617 | 4156006 |  113 |


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

## MabsF: template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=MabsF

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 5090491 \
    --trim2 "--dedupe" \
    --cov2 "40 80" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,3" \
    --insertsize \
    --sgapreqc \
    --fillanchor \
    --parallel 24

```

## MabsF: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=MabsF

cd ${WORKING_DIR}/${BASE_NAME}

bash 0_bsub.sh
#bash 0_master.sh

bsub -w "ended(${BASE_NAME}-9_statFinal)" \
    -q mpi -n 24 -J "${BASE_NAME}-9_quast_competitor" \
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

#bash 0_cleanup.sh

```

Table: statInsertSize

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 443.2 |    277 | 2401.1 |                          7.34% |
| tadpole.bbtools | 263.4 |    264 |   49.5 |                         33.70% |
| genome.picard   | 295.6 |    279 |   47.2 |                             FR |
| genome.picard   | 287.3 |    271 |   33.9 |                             RF |
| tadpole.picard  | 263.8 |    264 |   49.2 |                             FR |
| tadpole.picard  | 243.6 |    249 |   47.4 |                             RF |


Table: statReads

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 5067172 | 5090491 |       2 |
| Paralogs |    1580 |   83364 |      53 |
| Illumina |     251 |   2.19G | 8741140 |
| trim     |     176 |   1.33G | 8149736 |
| Q20L60   |     178 |   1.28G | 7732323 |
| Q25L60   |     174 |   1.15G | 7186318 |
| Q30L60   |     165 |  932.5M | 6274893 |


Table: statTrimReads

| Name     | N50 |     Sum |       # |
|:---------|----:|--------:|--------:|
| clumpify | 251 |   2.19G | 8732340 |
| trim     | 177 |   1.33G | 8171567 |
| filter   | 176 |   1.33G | 8149736 |
| R1       | 187 |    678M | 3854206 |
| R2       | 166 | 585.92M | 3854206 |
| Rs       | 167 |  64.39M |  441324 |


```text
#trim
#Matched	6348302	72.69875%
#Name	Reads	ReadsPct
Reverse_adapter	3297457	37.76144%
pcr_dimer	1741885	19.94752%
TruSeq_Universal_Adapter	535660	6.13421%
PCR_Primers	444158	5.08636%
TruSeq_Adapter_Index_1_6	211263	2.41932%
Nextera_LMP_Read2_External_Adapter	63039	0.72190%
TruSeq_Adapter_Index_11	28985	0.33193%
PhiX_read2_adapter	4649	0.05324%
Bisulfite_R2	3062	0.03507%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]517	2557	0.02928%
I5_Primer_Nextera_XT_Index_Kit_v2_S513	2059	0.02358%
I5_Primer_Nextera_XT_Index_Kit_v2_S511	1410	0.01615%
I5_Primer_Nextera_XT_Index_Kit_v2_S516	1227	0.01405%
Nextera_LMP_Read1_External_Adapter	1213	0.01389%
PhiX_read1_adapter	1207	0.01382%
TruSeq_Adapter_Index_6	1110	0.01271%
```

```text
#filter
#Matched	21831	0.26716%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	21784	0.26658%
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 177 |   1.24G | 7588272 |
| ecco          | 177 |   1.24G | 7588272 |
| ecct          | 176 |   1.18G | 7303838 |
| extended      | 214 |   1.47G | 7303838 |
| merged        | 207 |  13.19M |   69298 |
| unmerged.raw  | 214 |   1.45G | 7165242 |
| unmerged.trim | 214 |   1.45G | 7163920 |
| U1            | 215 | 630.19M | 3090258 |
| U2            | 215 | 630.87M | 3090258 |
| Us            | 206 | 188.89M |  983404 |
| pe.cor        | 214 |   1.46G | 8285920 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 155.4 |    149 |  58.5 |          1.82% |
| ihist.merge.txt  | 190.4 |    182 |  63.8 |          1.90% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q0L0   | 261.0 |  206.3 |   20.98% |     158 | "43" | 5.09M | 5.93M |     1.16 | 0:02'05'' |
| Q20L60 | 250.7 |  202.2 |   19.35% |     160 | "45" | 5.09M | 5.83M |     1.14 | 0:02'02'' |
| Q25L60 | 225.9 |  189.7 |   16.04% |     157 | "43" | 5.09M | 5.66M |     1.11 | 0:01'52'' |
| Q30L60 | 183.4 |  159.8 |   12.87% |     148 | "39" | 5.09M | 5.41M |     1.06 | 0:01'35'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  79.71% |      2324 | 3.73M | 1778 |      1029 | 640.62K | 3952 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'46'' |
| Q0L0X40P001   |   40.0 |  78.77% |      2101 | 3.56M | 1788 |      1045 | 742.95K | 3955 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'47'' |
| Q0L0X40P002   |   40.0 |  78.81% |      2224 | 3.68M | 1794 |      1029 |    635K | 3935 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'46'' |
| Q0L0X40P003   |   40.0 |  79.51% |      2270 | 3.68M | 1774 |      1039 | 662.09K | 3919 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'44'' |
| Q0L0X40P004   |   40.0 |  78.59% |      2174 | 3.55M | 1778 |      1046 | 764.54K | 3949 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'45'' |
| Q0L0X80P000   |   80.0 |  52.28% |      1551 | 2.28M | 1466 |      1035 | 540.04K | 3276 |   67.0 | 6.0 |  16.3 | 127.5 | "31,41,51,61,71,81" | 0:01'30'' | 0:00'40'' |
| Q0L0X80P001   |   80.0 |  52.61% |      1565 | 2.29M | 1466 |      1034 | 542.14K | 3285 |   67.0 | 6.0 |  16.3 | 127.5 | "31,41,51,61,71,81" | 0:01'30'' | 0:00'40'' |
| Q20L60X40P000 |   40.0 |  81.15% |      2300 | 3.77M | 1798 |      1031 |  673.9K | 4003 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'46'' |
| Q20L60X40P001 |   40.0 |  80.50% |      2326 | 3.76M | 1784 |      1020 | 637.19K | 3891 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'46'' |
| Q20L60X40P002 |   40.0 |  80.54% |      2307 | 3.77M | 1776 |      1035 | 646.95K | 3978 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'47'' |
| Q20L60X40P003 |   40.0 |  80.77% |      2344 | 3.79M | 1777 |      1021 |  633.5K | 3884 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'46'' |
| Q20L60X40P004 |   40.0 |  81.09% |      2304 | 3.77M | 1783 |      1042 | 675.53K | 3977 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'47'' |
| Q20L60X80P000 |   80.0 |  55.54% |      1643 | 2.41M | 1496 |      1040 | 591.11K | 3385 |   67.0 | 6.0 |  16.3 | 127.5 | "31,41,51,61,71,81" | 0:01'30'' | 0:00'41'' |
| Q20L60X80P001 |   80.0 |  55.74% |      1572 | 2.35M | 1486 |      1048 | 657.38K | 3377 |   67.0 | 5.0 |  17.3 | 123.0 | "31,41,51,61,71,81" | 0:01'30'' | 0:00'40'' |
| Q25L60X40P000 |   40.0 |  85.85% |      2714 | 4.05M | 1703 |      1015 |  632.8K | 3765 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'49'' |
| Q25L60X40P001 |   40.0 |  85.90% |      2620 | 4.09M | 1744 |      1019 | 611.88K | 3920 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'48'' |
| Q25L60X40P002 |   40.0 |  85.76% |      2516 | 4.07M | 1785 |      1013 | 622.56K | 3946 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'48'' |
| Q25L60X40P003 |   40.0 |  85.63% |      2671 | 4.04M | 1724 |      1015 | 622.59K | 3842 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'48'' |
| Q25L60X80P000 |   80.0 |  68.07% |      1822 | 3.14M | 1782 |      1022 | 533.47K | 3908 |   69.0 | 6.0 |  17.0 | 130.5 | "31,41,51,61,71,81" | 0:01'30'' | 0:00'44'' |
| Q25L60X80P001 |   80.0 |  67.71% |      1828 | 3.07M | 1733 |      1030 | 593.72K | 3863 |   68.0 | 6.0 |  16.7 | 129.0 | "31,41,51,61,71,81" | 0:01'30'' | 0:00'44'' |
| Q30L60X40P000 |   40.0 |  97.61% |      9071 |  4.8M |  924 |      1010 | 442.66K | 2433 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'57'' |
| Q30L60X40P001 |   40.0 |  97.61% |      8601 | 4.82M |  936 |       965 | 416.68K | 2400 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'56'' |
| Q30L60X40P002 |   40.0 |  97.71% |      9021 | 4.81M |  912 |       991 | 438.72K | 2417 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'56'' |
| Q30L60X80P000 |   80.0 |  94.74% |      5102 | 4.74M | 1270 |       816 | 341.47K | 3003 |   74.0 | 5.0 |  19.7 | 133.5 | "31,41,51,61,71,81" | 0:01'29'' | 0:00'53'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  97.80% |     18490 | 4.99M |  504 |       803 | 218.32K | 1574 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'58'' |
| Q0L0X40P001   |   40.0 |  97.71% |     15385 | 4.93M |  627 |       981 | 336.36K | 1711 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'55'' |
| Q0L0X40P002   |   40.0 |  97.76% |     17374 | 4.99M |  522 |       670 | 217.47K | 1591 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'58'' |
| Q0L0X40P003   |   40.0 |  97.96% |     18661 | 5.01M |  502 |       804 | 222.22K | 1556 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'57'' |
| Q0L0X40P004   |   40.0 |  97.74% |     13956 | 4.91M |  691 |       858 | 358.44K | 1902 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'58'' |
| Q0L0X80P000   |   80.0 |  95.41% |      6528 | 4.88M | 1053 |       641 | 289.73K | 2714 |   74.0 | 5.0 |  19.7 | 133.5 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'54'' |
| Q0L0X80P001   |   80.0 |  95.70% |      6910 | 4.91M | 1045 |       394 | 262.98K | 2689 |   74.0 | 5.0 |  19.7 | 133.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'55'' |
| Q20L60X40P000 |   40.0 |  97.99% |     17875 | 4.99M |  506 |       799 | 236.27K | 1616 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:01'01'' |
| Q20L60X40P001 |   40.0 |  97.90% |     17201 | 4.96M |  563 |       914 | 263.92K | 1673 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'56'' |
| Q20L60X40P002 |   40.0 |  97.89% |     17685 | 4.99M |  504 |       837 | 238.22K | 1626 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'59'' |
| Q20L60X40P003 |   40.0 |  97.85% |     14164 | 4.89M |  712 |       977 | 384.36K | 1901 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'57'' |
| Q20L60X40P004 |   40.0 |  97.84% |     16090 |    5M |  536 |       743 | 229.36K | 1624 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'57'' |
| Q20L60X80P000 |   80.0 |  95.70% |      6645 | 4.88M | 1033 |       804 | 307.26K | 2755 |   74.0 | 5.0 |  19.7 | 133.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'56'' |
| Q20L60X80P001 |   80.0 |  95.52% |      6979 | 4.88M | 1034 |       545 | 271.99K | 2694 |   74.0 | 5.0 |  19.7 | 133.5 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'56'' |
| Q25L60X40P000 |   40.0 |  98.33% |     19016 | 4.98M |  513 |       880 |  276.9K | 1752 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:01'00'' |
| Q25L60X40P001 |   40.0 |  98.24% |     16989 | 4.99M |  521 |       818 | 251.84K | 1676 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:01'00'' |
| Q25L60X40P002 |   40.0 |  98.30% |     16480 | 4.98M |  564 |       879 | 277.32K | 1800 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'59'' |
| Q25L60X40P003 |   40.0 |  98.12% |     15140 | 4.96M |  592 |       855 |  274.5K | 1786 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'59'' |
| Q25L60X80P000 |   80.0 |  96.44% |      7571 | 4.92M |  947 |       609 |  285.4K | 2671 |   74.0 | 5.0 |  19.7 | 133.5 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'57'' |
| Q25L60X80P001 |   80.0 |  96.32% |      7085 | 4.86M | 1018 |       842 | 350.85K | 2723 |   75.0 | 4.0 |  20.0 | 130.5 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'57'' |
| Q30L60X40P000 |   40.0 |  99.10% |     26154 | 5.01M |  414 |       984 | 228.86K | 1447 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:01'00'' |
| Q30L60X40P001 |   40.0 |  99.07% |     24296 | 5.01M |  456 |       842 | 241.96K | 1517 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:01'01'' |
| Q30L60X40P002 |   40.0 |  99.15% |     26597 | 4.99M |  416 |      1079 | 257.36K | 1411 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:01'03'' |
| Q30L60X80P000 |   80.0 |  98.75% |     18192 | 5.04M |  512 |       679 | 169.97K | 1734 |   76.0 | 4.0 |  20.0 | 132.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:01'01'' |


Table: statMRKunitigsAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  94.68% |      5812 |  4.8M | 1138 |       635 | 280.44K | 2396 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'50'' |
| MRX40P001 |   40.0 |  94.55% |      5725 | 4.76M | 1163 |       829 | 321.57K | 2469 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'50'' |
| MRX40P002 |   40.0 |  94.57% |      6206 | 4.79M | 1094 |       556 |  280.9K | 2353 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'49'' |
| MRX40P003 |   40.0 |  94.32% |      6257 | 4.81M | 1087 |       285 | 245.34K | 2328 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'50'' |
| MRX40P004 |   40.0 |  94.58% |      6005 | 4.81M | 1130 |       472 | 251.29K | 2357 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'51'' |
| MRX40P005 |   40.0 |  94.51% |      5992 | 4.79M | 1141 |       582 | 289.82K | 2432 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'49'' |
| MRX40P006 |   40.0 |  94.19% |      5935 | 4.78M | 1155 |       575 | 276.98K | 2464 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'50'' |
| MRX80P000 |   80.0 |  87.73% |      3358 | 4.43M | 1606 |       613 | 358.23K | 3405 |   71.0 | 6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:01'39'' | 0:00'48'' |
| MRX80P001 |   80.0 |  87.51% |      3184 | 4.38M | 1613 |       834 | 406.55K | 3412 |   71.0 | 5.0 |  18.7 | 129.0 | "31,41,51,61,71,81" | 0:01'39'' | 0:00'49'' |
| MRX80P002 |   80.0 |  87.32% |      3186 | 4.36M | 1625 |       710 | 400.08K | 3398 |   71.0 | 5.0 |  18.7 | 129.0 | "31,41,51,61,71,81" | 0:01'39'' | 0:00'50'' |


Table: statMRTadpoleAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  99.22% |     69300 | 5.09M | 158 |       130 | 47.73K | 497 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'58'' |
| MRX40P001 |   40.0 |  99.16% |     59940 | 5.08M | 174 |       353 | 66.43K | 527 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'57'' |
| MRX40P002 |   40.0 |  99.20% |     63250 | 5.09M | 144 |        99 | 41.82K | 494 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'58'' |
| MRX40P003 |   40.0 |  99.17% |     61116 | 5.08M | 177 |       141 | 53.61K | 512 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'58'' |
| MRX40P004 |   40.0 |  99.19% |     64572 | 5.09M | 156 |       139 |  50.8K | 512 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:01'00'' |
| MRX40P005 |   40.0 |  99.19% |     63824 | 5.09M | 155 |       122 |  45.9K | 488 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'58'' |
| MRX40P006 |   40.0 |  99.19% |     60778 | 5.09M | 150 |       108 | 44.54K | 505 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'59'' |
| MRX80P000 |   80.0 |  98.88% |     33908 | 5.08M | 278 |        85 | 59.12K | 740 |   77.0 | 3.0 |  20.0 | 129.0 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'56'' |
| MRX80P001 |   80.0 |  98.89% |     34674 | 5.09M | 254 |        83 | 52.99K | 675 |   78.0 | 3.0 |  20.0 | 130.5 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'55'' |
| MRX80P002 |   80.0 |  98.83% |     30627 | 5.08M | 283 |        83 |  57.5K | 722 |   77.0 | 3.0 |  20.0 | 129.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'56'' |


Table: statFinal

| Name                             |     N50 |     Sum |    # |
|:---------------------------------|--------:|--------:|-----:|
| Genome                           | 5067172 | 5090491 |    2 |
| Paralogs                         |    1580 |   83364 |   53 |
| 7_mergeKunitigsAnchors.anchors   |   55955 | 5214855 |  206 |
| 7_mergeKunitigsAnchors.others    |    1222 | 4692404 | 3835 |
| 7_mergeTadpoleAnchors.anchors    |  144359 | 5121073 |   80 |
| 7_mergeTadpoleAnchors.others     |    1247 | 1912830 | 1569 |
| 7_mergeMRKunitigsAnchors.anchors |   88665 | 5139223 |  116 |
| 7_mergeMRKunitigsAnchors.others  |    1088 | 1138400 | 1041 |
| 7_mergeMRTadpoleAnchors.anchors  |  144411 | 5116825 |   75 |
| 7_mergeMRTadpoleAnchors.others   |    1197 |  119961 |  100 |
| 7_mergeAnchors.anchors           |  149382 | 5157456 |   73 |
| 7_mergeAnchors.others            |    1246 | 5735641 | 4569 |
| spades.contig                    |  261101 | 5702235 | 1270 |
| spades.scaffold                  |  365101 | 5702385 | 1264 |
| spades.non-contained             |  278521 | 5140811 |   43 |
| spades.anchor                    |  278377 | 5106837 |   75 |
| megahit.contig                   |  116933 | 5298830 |  512 |
| megahit.non-contained            |  137327 | 5121658 |   72 |
| megahit.anchor                   |  101179 | 5067141 |  216 |
| platanus.contig                  |   25021 | 5174227 |  486 |
| platanus.scaffold                |  102410 | 5133538 |  129 |
| platanus.non-contained           |  102410 | 5121464 |   98 |
| platanus.anchor                  |   61491 | 5013475 |  402 |


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

## VchoF: template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=VchoF

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 4033464 \
    --trim2 "--dedupe" \
    --cov2 "40 80" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,3" \
    --insertsize \
    --sgapreqc \
    --fillanchor \
    --parallel 24

```

## VchoF: run


```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=VchoF

cd ${WORKING_DIR}/${BASE_NAME}

bash 0_bsub.sh
#bash 0_master.sh

bsub -w "ended(${BASE_NAME}-9_statFinal)" \
    -q mpi -n 24 -J "${BASE_NAME}-9_quast_competitor" \
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

#bash 0_cleanup.sh

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
| trim     |     188 |   1.21G | 6713772 |
| Q20L60   |     189 |   1.19G | 6543179 |
| Q25L60   |     187 |   1.12G | 6272829 |
| Q30L60   |     181 | 983.88M | 5769965 |


Table: statTrimReads

| Name     | N50 |     Sum |       # |
|:---------|----:|--------:|--------:|
| clumpify | 251 |   1.73G | 6883006 |
| trim     | 189 |   1.22G | 6751634 |
| filter   | 188 |   1.21G | 6713772 |
| R1       | 194 | 616.87M | 3301532 |
| R2       | 183 | 577.43M | 3301532 |
| Rs       | 179 |   17.9M |  110708 |


```text
#trim
#Matched	5589809	81.21174%
#Name	Reads	ReadsPct
Reverse_adapter	2713329	39.42070%
pcr_dimer	1554664	22.58699%
PCR_Primers	797469	11.58606%
TruSeq_Universal_Adapter	219469	3.18856%
TruSeq_Adapter_Index_1_6	203266	2.95316%
Nextera_LMP_Read2_External_Adapter	83758	1.21688%
TruSeq_Adapter_Index_5	3286	0.04774%
RNA_PCR_Primer_Index_36_(RPI36)	2773	0.04029%
Bisulfite_R2	1704	0.02476%
PhiX_read2_adapter	1377	0.02001%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N705	1329	0.01931%
TruSeq_Adapter_Index_11	1087	0.01579%
```

```text
#filter
#Matched	37862	0.56078%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	37661	0.55781%
Reverse_adapter	188	0.00278%
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 191 |   1.03G | 5688251 |
| ecco          | 190 |   1.03G | 5688250 |
| ecct          | 190 | 996.03M | 5514047 |
| extended      | 228 |   1.22G | 5514047 |
| merged        | 229 |   9.45M |   44017 |
| unmerged.raw  | 228 |    1.2G | 5426012 |
| unmerged.trim | 228 |    1.2G | 5425732 |
| U1            | 229 | 517.18M | 2330045 |
| U2            | 230 | 517.72M | 2330045 |
| Us            | 221 | 162.97M |  765642 |
| pe.cor        | 228 |   1.21G | 6279408 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 177.5 |    175 |  54.0 |          1.55% |
| ihist.merge.txt  | 214.7 |    210 |  60.2 |          1.60% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q0L0   | 300.6 |  244.5 |   18.65% |     183 | "111" | 4.03M | 4.58M |     1.14 | 0:01'53'' |
| Q20L60 | 294.3 |  243.0 |   17.44% |     185 | "113" | 4.03M | 4.52M |     1.12 | 0:01'51'' |
| Q25L60 | 277.3 |  236.4 |   14.76% |     182 | "109" | 4.03M | 4.38M |     1.09 | 0:01'44'' |
| Q30L60 | 244.0 |  215.1 |   11.85% |     175 | "105" | 4.03M | 4.15M |     1.03 | 0:01'36'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  80.34% |      2632 | 3.02M | 1293 |      1048 | 415.12K | 2827 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'42'' |
| Q0L0X40P001   |   40.0 |  81.30% |      2711 | 3.01M | 1293 |      1054 | 465.41K | 2813 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'42'' |
| Q0L0X40P002   |   40.0 |  80.11% |      2682 | 2.99M | 1279 |      1044 | 422.33K | 2776 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'42'' |
| Q0L0X40P003   |   40.0 |  80.92% |      2708 | 3.08M | 1313 |      1026 | 359.23K | 2795 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'42'' |
| Q0L0X40P004   |   40.0 |  79.41% |      2616 | 3.01M | 1297 |      1035 | 382.09K | 2795 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'41'' |
| Q0L0X40P005   |   40.0 |  80.41% |      2665 | 2.98M | 1270 |      1035 | 447.76K | 2717 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'41'' |
| Q0L0X80P000   |   80.0 |  60.59% |      1782 | 2.24M | 1300 |      1042 |  387.3K | 2791 |   68.0 | 8.0 |  14.7 | 136.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'39'' |
| Q0L0X80P001   |   80.0 |  60.91% |      1787 | 2.25M | 1290 |      1030 | 385.86K | 2772 |   68.0 | 8.0 |  14.7 | 136.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'39'' |
| Q0L0X80P002   |   80.0 |  60.35% |      1807 |  2.2M | 1258 |      1039 |  410.6K | 2743 |   68.0 | 8.0 |  14.7 | 136.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'38'' |
| Q20L60X40P000 |   40.0 |  81.20% |      2766 | 3.08M | 1279 |      1027 |  387.2K | 2726 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'42'' |
| Q20L60X40P001 |   40.0 |  81.66% |      2874 | 3.06M | 1247 |      1047 | 401.85K | 2711 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'42'' |
| Q20L60X40P002 |   40.0 |  80.45% |      2690 | 3.02M | 1268 |      1041 | 417.98K | 2757 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'41'' |
| Q20L60X40P003 |   40.0 |  81.83% |      2748 | 3.04M | 1286 |      1040 | 453.81K | 2806 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'41'' |
| Q20L60X40P004 |   40.0 |  80.67% |      2694 | 3.04M | 1261 |      1040 | 400.26K | 2727 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'42'' |
| Q20L60X40P005 |   40.0 |  81.97% |      2788 | 3.05M | 1271 |      1041 | 442.18K | 2753 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'42'' |
| Q20L60X80P000 |   80.0 |  63.06% |      1896 | 2.34M | 1306 |      1040 | 389.01K | 2800 |   68.0 | 8.0 |  14.7 | 136.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'38'' |
| Q20L60X80P001 |   80.0 |  63.04% |      1817 | 2.32M | 1317 |      1033 |    411K | 2855 |   68.0 | 8.0 |  14.7 | 136.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'38'' |
| Q20L60X80P002 |   80.0 |  62.15% |      1825 | 2.29M | 1290 |      1035 |  379.7K | 2775 |   68.0 | 8.0 |  14.7 | 136.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'39'' |
| Q25L60X40P000 |   40.0 |  84.06% |      2982 | 3.24M | 1287 |      1027 | 330.99K | 2765 |   36.0 | 5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'42'' |
| Q25L60X40P001 |   40.0 |  84.30% |      3101 | 3.25M | 1235 |      1018 | 314.59K | 2638 |   36.0 | 5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'42'' |
| Q25L60X40P002 |   40.0 |  83.23% |      2975 | 3.18M | 1239 |      1054 | 346.28K | 2684 |   36.0 | 5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'43'' |
| Q25L60X40P003 |   40.0 |  83.33% |      2991 |  3.1M | 1202 |      1048 | 437.72K | 2592 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'42'' |
| Q25L60X40P004 |   40.0 |  83.38% |      2944 | 3.13M | 1253 |      1052 | 410.53K | 2680 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'43'' |
| Q25L60X80P000 |   80.0 |  68.87% |      2028 | 2.58M | 1358 |      1033 | 373.65K | 2912 |   70.0 | 9.0 |  14.3 | 140.0 | "31,41,51,61,71,81" | 0:01'11'' | 0:00'40'' |
| Q25L60X80P001 |   80.0 |  67.89% |      2012 | 2.52M | 1331 |      1041 | 392.37K | 2854 |   69.0 | 8.0 |  15.0 | 138.0 | "31,41,51,61,71,81" | 0:01'11'' | 0:00'41'' |
| Q30L60X40P000 |   40.0 |  93.11% |      7470 | 3.61M |  731 |      1031 | 225.01K | 1642 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'45'' |
| Q30L60X40P001 |   40.0 |  93.49% |      6991 | 3.64M |  751 |      1003 | 213.84K | 1654 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'44'' |
| Q30L60X40P002 |   40.0 |  93.42% |      6927 | 3.63M |  784 |      1015 | 228.03K | 1728 |   36.0 | 5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'44'' |
| Q30L60X40P003 |   40.0 |  93.18% |      6473 | 3.61M |  782 |      1023 | 227.06K | 1723 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'44'' |
| Q30L60X40P004 |   40.0 |  93.35% |      7187 | 3.64M |  728 |      1014 | 202.22K | 1642 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'44'' |
| Q30L60X80P000 |   80.0 |  89.09% |      4274 |  3.5M | 1046 |      1002 | 218.54K | 2183 |   74.0 | 9.0 |  15.7 | 148.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'44'' |
| Q30L60X80P001 |   80.0 |  88.98% |      4145 | 3.47M | 1081 |      1012 | 242.16K | 2259 |   73.0 | 9.0 |  15.3 | 146.0 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'44'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  95.88% |     18859 | 3.75M | 391 |      1062 | 153.99K | 1019 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'47'' |
| Q0L0X40P001   |   40.0 |  95.98% |     15098 | 3.76M | 408 |      1042 | 161.14K | 1043 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'48'' |
| Q0L0X40P002   |   40.0 |  95.76% |     17842 | 3.74M | 399 |      1181 | 157.92K |  999 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'47'' |
| Q0L0X40P003   |   40.0 |  95.84% |     17563 | 3.75M | 373 |      1032 | 148.86K |  975 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'46'' |
| Q0L0X40P004   |   40.0 |  95.92% |     17063 | 3.76M | 404 |       906 | 138.72K | 1026 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'49'' |
| Q0L0X40P005   |   40.0 |  95.95% |     16505 | 3.75M | 410 |      1079 | 187.57K | 1092 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'48'' |
| Q0L0X80P000   |   80.0 |  94.58% |      8109 | 3.76M | 672 |      1016 | 190.36K | 1722 |   75.0 | 10.0 |  15.0 | 150.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'48'' |
| Q0L0X80P001   |   80.0 |  94.28% |      8400 | 3.73M | 666 |      1015 | 195.78K | 1773 |   74.0 | 10.0 |  14.7 | 148.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'50'' |
| Q0L0X80P002   |   80.0 |  94.29% |      8427 | 3.75M | 685 |       923 |  173.2K | 1769 |   74.0 | 10.0 |  14.7 | 148.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'48'' |
| Q20L60X40P000 |   40.0 |  95.89% |     16498 | 3.73M | 439 |      1026 | 180.83K | 1107 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'47'' |
| Q20L60X40P001 |   40.0 |  95.80% |     16431 | 3.75M | 416 |       881 | 142.84K | 1065 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'47'' |
| Q20L60X40P002 |   40.0 |  95.93% |     17402 | 3.74M | 412 |      1037 | 173.41K | 1068 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'48'' |
| Q20L60X40P003 |   40.0 |  95.94% |     17195 | 3.74M | 405 |      1011 |  163.9K | 1061 |   36.0 |  4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'47'' |
| Q20L60X40P004 |   40.0 |  95.96% |     16850 | 3.71M | 414 |      1124 | 218.34K | 1061 |   36.0 |  4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'48'' |
| Q20L60X40P005 |   40.0 |  95.95% |     17438 | 3.73M | 401 |      1065 | 192.37K | 1071 |   36.0 |  4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'46'' |
| Q20L60X80P000 |   80.0 |  94.41% |      8726 | 3.74M | 673 |      1015 | 192.38K | 1800 |   75.0 | 10.0 |  15.0 | 150.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'48'' |
| Q20L60X80P001 |   80.0 |  94.17% |      7847 | 3.71M | 697 |      1000 | 208.78K | 1779 |   74.0 |  9.0 |  15.7 | 148.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'49'' |
| Q20L60X80P002 |   80.0 |  94.42% |      8464 | 3.73M | 659 |      1006 | 192.61K | 1738 |   74.0 | 10.0 |  14.7 | 148.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'48'' |
| Q25L60X40P000 |   40.0 |  96.46% |     22179 | 3.76M | 338 |      1068 | 161.78K |  990 |   36.0 |  4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'50'' |
| Q25L60X40P001 |   40.0 |  96.27% |     17862 | 3.75M | 380 |      1032 | 156.89K | 1012 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'47'' |
| Q25L60X40P002 |   40.0 |  96.15% |     17729 | 3.76M | 395 |      1089 | 162.31K | 1034 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'46'' |
| Q25L60X40P003 |   40.0 |  96.07% |     17784 | 3.73M | 398 |      1090 | 171.22K |  994 |   36.0 |  4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'48'' |
| Q25L60X40P004 |   40.0 |  96.30% |     17347 | 3.76M | 402 |      1042 | 153.09K | 1059 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'47'' |
| Q25L60X80P000 |   80.0 |  95.00% |     10105 | 3.76M | 579 |      1025 | 151.49K | 1542 |   75.0 | 10.0 |  15.0 | 150.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'47'' |
| Q25L60X80P001 |   80.0 |  94.83% |      8974 | 3.74M | 630 |       960 | 159.07K | 1657 |   75.0 | 10.0 |  15.0 | 150.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'48'' |
| Q30L60X40P000 |   40.0 |  97.21% |     31623 | 3.78M | 297 |      1066 | 147.16K |  879 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'50'' |
| Q30L60X40P001 |   40.0 |  97.12% |     24633 | 3.76M | 320 |      1068 | 147.61K |  911 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'49'' |
| Q30L60X40P002 |   40.0 |  97.12% |     30174 | 3.78M | 299 |      1045 | 142.66K |  904 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'50'' |
| Q30L60X40P003 |   40.0 |  97.07% |     27666 | 3.76M | 297 |      1202 |  160.4K |  896 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'49'' |
| Q30L60X40P004 |   40.0 |  97.13% |     33372 | 3.78M | 266 |      1152 | 123.45K |  781 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'50'' |
| Q30L60X80P000 |   80.0 |  96.60% |     14457 | 3.79M | 405 |      1109 | 137.23K | 1109 |   76.0 |  9.0 |  16.3 | 152.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'51'' |
| Q30L60X80P001 |   80.0 |  96.37% |     15653 |  3.8M | 412 |      1018 | 120.39K | 1074 |   75.0 | 10.0 |  15.0 | 150.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'48'' |


Table: statMRKunitigsAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  95.85% |     18098 | 3.74M | 386 |      1046 | 155.41K |  885 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'46'' |
| MRX40P001 |   40.0 |  95.69% |     15996 | 3.72M | 425 |      1018 | 157.44K |  911 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'44'' |
| MRX40P002 |   40.0 |  95.89% |     13579 | 3.73M | 462 |      1036 | 169.19K | 1022 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'44'' |
| MRX40P003 |   40.0 |  96.03% |     16387 | 3.73M | 399 |      1047 | 149.98K |  859 |   37.0 |  4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'45'' |
| MRX40P004 |   40.0 |  95.38% |     15517 | 3.72M | 421 |      1023 | 149.67K |  916 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'45'' |
| MRX40P005 |   40.0 |  95.70% |     15656 | 3.73M | 415 |      1055 |  162.4K |  898 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'44'' |
| MRX40P006 |   40.0 |  95.80% |     16417 | 3.76M | 379 |      1009 | 124.46K |  833 |   38.0 |  5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'44'' |
| MRX80P000 |   80.0 |  94.21% |     10129 | 3.72M | 580 |       986 | 140.96K | 1198 |   75.0 |  9.0 |  16.0 | 150.0 | "31,41,51,61,71,81" | 0:01'21'' | 0:00'45'' |
| MRX80P001 |   80.0 |  94.42% |      9285 | 3.71M | 602 |      1013 | 150.78K | 1243 |   74.0 |  9.0 |  15.7 | 148.0 | "31,41,51,61,71,81" | 0:01'21'' | 0:00'44'' |
| MRX80P002 |   80.0 |  93.65% |      9320 |  3.7M | 596 |       966 | 135.93K | 1244 |   75.0 | 10.0 |  15.0 | 150.0 | "31,41,51,61,71,81" | 0:01'21'' | 0:00'44'' |


Table: statMRTadpoleAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  97.44% |     46948 | 3.81M | 195 |      1066 |  92.65K | 513 |   36.0 |  6.0 |   6.0 |  72.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'50'' |
| MRX40P001 |   40.0 |  97.42% |     45688 | 3.77M | 252 |      1206 | 161.89K | 589 |   35.0 |  6.0 |   5.7 |  70.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'48'' |
| MRX40P002 |   40.0 |  97.42% |     53759 | 3.79M | 198 |      1161 | 127.37K | 514 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'47'' |
| MRX40P003 |   40.0 |  97.43% |     43186 | 3.78M | 252 |      1195 | 115.33K | 560 |   35.0 |  6.0 |   5.7 |  70.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'48'' |
| MRX40P004 |   40.0 |  97.46% |     52329 | 3.78M | 256 |      1084 | 131.74K | 597 |   35.0 |  6.0 |   5.7 |  70.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'48'' |
| MRX40P005 |   40.0 |  97.38% |     59342 | 3.79M | 191 |      1055 | 104.36K | 463 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'48'' |
| MRX40P006 |   40.0 |  97.48% |     58788 | 3.82M | 175 |      1010 |  80.64K | 495 |   36.0 |  6.0 |   6.0 |  72.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'48'' |
| MRX80P000 |   80.0 |  97.24% |     45982 | 3.84M | 178 |      1046 |  74.74K | 449 |   75.0 | 12.0 |  13.0 | 150.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'47'' |
| MRX80P001 |   80.0 |  97.24% |     43838 | 3.84M | 169 |      1025 |  65.08K | 417 |   75.0 | 10.0 |  15.0 | 150.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'47'' |
| MRX80P002 |   80.0 |  97.13% |     42107 | 3.82M | 166 |      1130 |  71.69K | 428 |   77.0 | 11.0 |  14.7 | 154.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'48'' |


Table: statFinal

| Name                             |     N50 |     Sum |    # |
|:---------------------------------|--------:|--------:|-----:|
| Genome                           | 2961149 | 4033464 |    2 |
| Paralogs                         |    3483 |  114707 |   48 |
| 7_mergeKunitigsAnchors.anchors   |   69258 | 3913311 |  175 |
| 7_mergeKunitigsAnchors.others    |    1248 | 2862621 | 2224 |
| 7_mergeTadpoleAnchors.anchors    |  105204 | 3880539 |   97 |
| 7_mergeTadpoleAnchors.others     |    1479 | 1012517 |  711 |
| 7_mergeMRKunitigsAnchors.anchors |   92370 | 3862879 |  120 |
| 7_mergeMRKunitigsAnchors.others  |    1313 |  449238 |  336 |
| 7_mergeMRTadpoleAnchors.anchors  |  105213 | 3882569 |  104 |
| 7_mergeMRTadpoleAnchors.others   |    1626 |  348460 |  244 |
| 7_mergeAnchors.anchors           |  121204 | 3884864 |   90 |
| 7_mergeAnchors.others            |    1303 | 3217872 | 2401 |
| spades.contig                    |  176446 | 5097383 | 2327 |
| spades.scaffold                  |  199415 | 5097593 | 2324 |
| spades.non-contained             |  199415 | 4049347 |  159 |
| megahit.contig                   |   62704 | 4405275 | 1204 |
| megahit.non-contained            |   71383 | 3911537 |  140 |
| megahit.anchor                   |   70799 | 3843263 |  123 |
| platanus.contig                  |   76027 | 3997650 |  328 |
| platanus.scaffold                |  112733 | 3949528 |  194 |
| platanus.non-contained           |  112733 | 3921056 |  101 |
| platanus.anchor                  |  113741 | 3868642 |  136 |

