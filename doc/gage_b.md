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

for D in Bcer Rsph Mabs Vcho VchoH RsphF MabsF VchoF; do
    rsync -avP \
        wangq@202.119.37.251:data/anchr/${D}/ \
        ~/data/anchr/${D}
done

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
    --sgastats \
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


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|----------:|
| 8_spades     |  86.85% |    207555 | 5.33M |  62 |      1141 | 17.24K | 122 |   36.0 | 5.0 |   7.0 |  72.0 | 0:00'53'' |
| 8_spades_MR  |  87.13% |     99993 | 5.34M | 110 |      1223 | 22.59K | 209 |   35.0 | 5.0 |   6.7 |  70.0 | 0:01'06'' |
| 8_megahit    |  86.49% |     60380 | 5.29M | 193 |       757 |  44.3K | 364 |   34.0 | 4.0 |   7.3 |  68.0 | 0:00'52'' |
| 8_megahit_MR |  87.16% |     60033 | 5.33M | 184 |      1072 | 35.11K | 355 |   34.0 | 4.0 |   7.3 |  68.0 | 0:00'54'' |
| 8_platanus   |  90.11% |    269267 | 5.31M |  56 |       649 | 14.59K |  98 |   32.5 | 4.5 |   6.3 |  65.0 | 0:00'54'' |


Table: statFinal

| Name                     |     N50 |     Sum |   # |
|:-------------------------|--------:|--------:|----:|
| Genome                   | 5224283 | 5432652 |   2 |
| Paralogs                 |    2295 |  223889 | 103 |
| 7_mergeAnchors.anchors   |   54782 | 5331374 | 196 |
| 7_mergeAnchors.others    |    1071 |   70741 |  57 |
| anchorLong               |   54782 | 5330884 | 195 |
| anchorFill               |  136629 | 5612053 |  73 |
| spades.contig            |  207660 | 5371823 | 190 |
| spades.scaffold          |  362667 | 5372267 | 174 |
| spades.non-contained     |  207660 | 5348387 |  60 |
| spades_MR.contig         |  100015 | 5367309 | 124 |
| spades_MR.scaffold       |  381272 | 5374057 |  62 |
| spades_MR.non-contained  |  100015 | 5360894 | 103 |
| megahit.contig           |   60414 | 5367784 | 272 |
| megahit.non-contained    |   60414 | 5331229 | 172 |
| megahit_MR.contig        |   60113 | 5417932 | 302 |
| megahit_MR.non-contained |   60113 | 5367234 | 173 |
| platanus.contig          |   18749 | 5414853 | 646 |
| platanus.scaffold        |  269317 | 5373828 | 243 |
| platanus.non-contained   |  269317 | 5326667 |  42 |


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


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|----------:|
| 8_spades     |  89.56% |      9401 | 3.94M |  605 |     19573 | 623.48K |  675 |   17.0 | 1.0 |   4.7 |  30.0 | 0:00'48'' |
| 8_spades_MR  |  89.63% |      5574 | 3.78M |  918 |     13383 | 779.64K | 1080 |   16.0 | 1.0 |   4.3 |  28.5 | 0:00'46'' |
| 8_megahit    |  89.01% |     10872 | 3.92M |  577 |     12571 | 622.46K |  755 |   17.0 | 1.0 |   4.7 |  30.0 | 0:00'48'' |
| 8_megahit_MR |  89.65% |      5358 | 3.77M |  944 |      9065 |  789.8K | 1213 |   16.0 | 1.0 |   4.3 |  28.5 | 0:00'47'' |
| 8_platanus   |  92.42% |      4305 | 3.56M | 1087 |      2070 |  899.5K | 1230 |   14.0 | 1.0 |   3.7 |  25.5 | 0:00'45'' |


Table: statFinal

| Name                     |     N50 |     Sum |    # |
|:-------------------------|--------:|--------:|-----:|
| Genome                   | 3188524 | 4602977 |    7 |
| Paralogs                 |    2337 |  147155 |   66 |
| 7_mergeAnchors.anchors   |    5577 | 3633663 |  888 |
| 7_mergeAnchors.others    |    8202 | 1428030 |  537 |
| anchorLong               |    5608 | 3632544 |  886 |
| anchorFill               |   55165 | 3951165 |  110 |
| spades.contig            |  164079 | 4576492 |  125 |
| spades.scaffold          |  173327 | 4576612 |  122 |
| spades.non-contained     |  164079 | 4561084 |   70 |
| spades_MR.contig         |   47760 | 4576256 |  231 |
| spades_MR.scaffold       |   73098 | 4577253 |  187 |
| spades_MR.non-contained  |   47760 | 4557601 |  165 |
| megahit.contig           |   56435 | 4573765 |  251 |
| megahit.non-contained    |   56435 | 4539677 |  179 |
| megahit_MR.contig        |   27816 | 4587064 |  332 |
| megahit_MR.non-contained |   28244 | 4556863 |  274 |
| platanus.contig          |    9448 | 4614992 | 2362 |
| platanus.scaffold        |   73051 | 4546782 |  640 |
| platanus.non-contained   |   73051 | 4454805 |  144 |


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
| genome.bbtools  | 458.7 |    277 | 2524.0 |                          7.42% |
| tadpole.bbtools | 266.7 |    266 |   50.0 |                         35.23% |
| genome.picard   | 295.7 |    279 |   47.4 |                             FR |
| genome.picard   | 287.1 |    271 |   33.8 |                             RF |
| tadpole.picard  | 268.0 |    267 |   49.2 |                             FR |
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
| filteredbytile | 251 | 485.16M | 1932904 |
| trim           | 177 |  282.7M | 1722046 |
| filter         | 177 | 281.73M | 1717448 |
| R1             | 187 | 150.47M |  858724 |
| R2             | 167 | 131.25M |  858724 |
| Rs             |   0 |       0 |       0 |


```text
#trim
#Matched	1414644	73.18749%
#Name	Reads	ReadsPct
Reverse_adapter	733236	37.93442%
pcr_dimer	393025	20.33339%
TruSeq_Universal_Adapter	116478	6.02606%
PCR_Primers	99705	5.15830%
TruSeq_Adapter_Index_1_6	46640	2.41295%
Nextera_LMP_Read2_External_Adapter	14178	0.73351%
TruSeq_Adapter_Index_11	5946	0.30762%
```

```text
#filter
#Matched	4592	0.26666%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	4586	0.26631%
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 177 | 280.09M | 1706578 |
| ecco          | 177 | 280.03M | 1706578 |
| eccc          | 177 | 280.03M | 1706578 |
| ecct          | 176 |  270.3M | 1651058 |
| extended      | 214 | 335.93M | 1651058 |
| merged        | 235 | 189.76M |  816252 |
| unmerged.raw  | 207 |   3.37M |   18554 |
| unmerged.trim | 207 |   3.37M |   18546 |
| U1            | 228 |   1.92M |    9273 |
| U2            | 185 |   1.45M |    9273 |
| Us            |   0 |       0 |       0 |
| pe.cor        | 234 | 193.94M | 1651050 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 190.3 |    186 |  46.7 |         92.50% |
| ihist.merge.txt  | 232.5 |    226 |  51.6 |         98.88% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q0L0   |  55.3 |   44.5 |   19.61% |     159 | "45" | 5.09M | 5.22M |     1.03 | 0:00'31'' |
| Q20L60 |  53.6 |   43.9 |   18.15% |     162 | "47" | 5.09M | 5.21M |     1.02 | 0:00'30'' |
| Q25L60 |  48.8 |   41.5 |   15.10% |     159 | "43" | 5.09M |  5.2M |     1.02 | 0:00'28'' |
| Q30L60 |  40.2 |   35.4 |   11.94% |     150 | "39" | 5.09M | 5.18M |     1.02 | 0:00'26'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  96.45% |      7377 |  4.8M |  989 |       873 | 344.32K | 2291 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'50'' |
| Q0L0XallP000   |   44.5 |  96.12% |      6944 | 4.77M | 1046 |       894 | 356.64K | 2342 |   41.0 | 3.0 |  10.7 |  75.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'50'' |
| Q20L60X40P000  |   40.0 |  96.59% |      7776 | 4.82M |  941 |       826 | 319.42K | 2170 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'50'' |
| Q20L60XallP000 |   43.9 |  96.41% |      7425 |  4.8M |  984 |       869 | 329.24K | 2218 |   41.0 | 3.0 |  10.7 |  75.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'51'' |
| Q25L60X40P000  |   40.0 |  97.51% |      7582 | 4.71M | 1018 |       981 |  510.8K | 2279 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'52'' |
| Q25L60XallP000 |   41.5 |  97.41% |      9393 | 4.91M |  831 |       760 | 253.51K | 2053 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'54'' |
| Q30L60XallP000 |   35.4 |  98.53% |     13171 | 4.86M |  766 |       946 |  431.4K | 2093 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'55'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  98.42% |     13966 | 4.88M | 701 |       931 | 404.87K | 1945 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'57'' |
| Q0L0XallP000   |   44.5 |  98.19% |     12221 | 4.81M | 819 |       938 | 465.43K | 2065 |   42.0 | 2.0 |  12.0 |  72.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'55'' |
| Q20L60X40P000  |   40.0 |  98.45% |     14161 | 4.86M | 750 |       946 | 433.82K | 2048 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'56'' |
| Q20L60XallP000 |   43.9 |  98.22% |     13092 | 4.86M | 765 |       942 | 418.46K | 2002 |   42.0 | 2.0 |  12.0 |  72.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'55'' |
| Q25L60X40P000  |   40.0 |  98.62% |     15924 | 4.87M | 718 |       981 | 443.24K | 2037 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'57'' |
| Q25L60XallP000 |   41.5 |  98.60% |     13753 |  4.8M | 812 |      1011 | 535.57K | 2178 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'56'' |
| Q30L60XallP000 |   35.4 |  99.02% |     16457 | 4.93M | 655 |       975 | 444.35K | 2200 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:01'00'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor | Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|----:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   38.1 |  97.36% |     11723 |  5M | 647 |       107 | 122.05K | 1340 |   36.0 | 2.0 |  10.0 |  63.0 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'47'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   38.1 |  99.32% |     82659 | 5.09M | 145 |       135 | 32.11K | 313 |   37.0 | 1.0 |  11.3 |  60.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'51'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |   0.00% |    102662 | 5.11M | 114 |      1259 | 853.69K | 712 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeKunitigsAnchors   |   0.00% |     16846 | 5.05M | 560 |      1186 | 563.15K | 492 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRKunitigsAnchors |   0.00% |     11723 |    5M | 647 |      1149 |  42.97K |  39 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRTadpoleAnchors  |   0.00% |     82659 | 5.09M | 145 |      1165 |  10.43K |   9 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeTadpoleAnchors    |   0.00% |     27868 | 5.08M | 408 |      1306 | 642.23K | 531 |    0.0 | 0.0 |   0.0 |   0.0 |           |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|----------:|
| 8_spades     |  81.43% |      5012 | 4.69M | 1210 |       973 | 430.24K | 1258 |   22.0 | 1.0 |   6.3 |  37.5 | 0:00'49'' |
| 8_spades_MR  |  81.50% |      5091 |  4.7M | 1202 |       968 | 428.62K | 1275 |   22.0 | 1.0 |   6.3 |  37.5 | 0:00'50'' |
| 8_megahit    |  81.29% |      4871 | 4.67M | 1225 |       967 | 448.86K | 1333 |   22.0 | 1.0 |   6.3 |  37.5 | 0:00'50'' |
| 8_megahit_MR |  81.60% |      5035 |  4.7M | 1203 |       967 | 435.29K | 1294 |   22.0 | 1.0 |   6.3 |  37.5 | 0:00'49'' |
| 8_platanus   |  85.56% |      4343 | 4.57M | 1337 |      1030 | 535.96K | 1512 |   19.0 | 1.0 |   5.3 |  33.0 | 0:00'49'' |


Table: statFinal

| Name                     |     N50 |     Sum |   # |
|:-------------------------|--------:|--------:|----:|
| Genome                   | 5067172 | 5090491 |   2 |
| Paralogs                 |    1580 |   83364 |  53 |
| 7_mergeAnchors.anchors   |  102662 | 5107356 | 114 |
| 7_mergeAnchors.others    |    1259 |  853685 | 712 |
| anchorLong               |  107250 | 5104324 | 108 |
| anchorFill               |  213187 | 5113851 |  55 |
| spades.contig            |  166677 | 5234267 | 318 |
| spades.scaffold          |  185863 | 5234397 | 314 |
| spades.non-contained     |  180172 | 5124688 |  48 |
| spades_MR.contig         |  122348 | 5132660 |  84 |
| spades_MR.scaffold       |  166841 | 5132690 |  81 |
| spades_MR.non-contained  |  122348 | 5126282 |  73 |
| megahit.contig           |   87942 | 5148562 | 186 |
| megahit.non-contained    |   87942 | 5122074 | 108 |
| megahit_MR.contig        |  118610 | 5140714 | 107 |
| megahit_MR.non-contained |  118610 | 5133702 |  91 |
| platanus.contig          |   30030 | 5154895 | 516 |
| platanus.scaffold        |   55979 | 5129462 | 253 |
| platanus.non-contained   |   55979 | 5106153 | 175 |


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

| Name           | N50 |     Sum |       # |
|:---------------|----:|--------:|--------:|
| clumpify       | 251 | 397.98M | 1585566 |
| filteredbytile | 251 | 376.18M | 1498742 |
| trim           | 189 | 262.55M | 1449166 |
| filter         | 189 | 260.92M | 1441476 |
| R1             | 193 | 134.13M |  720738 |
| R2             | 184 | 126.79M |  720738 |
| Rs             |   0 |       0 |       0 |


```text
#trim
#Matched	1216962	81.19890%
#Name	Reads	ReadsPct
Reverse_adapter	589549	39.33626%
pcr_dimer	340009	22.68629%
PCR_Primers	174531	11.64517%
TruSeq_Universal_Adapter	45570	3.04055%
TruSeq_Adapter_Index_1_6	45065	3.00686%
Nextera_LMP_Read2_External_Adapter	18448	1.23090%
```

```text
#filter
#Matched	7687	0.53044%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	7685	0.53031%
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 189 | 255.24M | 1406720 |
| ecco          | 189 | 255.21M | 1406720 |
| eccc          | 189 | 255.21M | 1406720 |
| ecct          | 189 | 252.25M | 1390548 |
| extended      | 228 | 307.63M | 1390548 |
| merged        | 239 | 165.28M |  690338 |
| unmerged.raw  | 226 |   2.03M |    9872 |
| unmerged.trim | 226 |   2.03M |    9870 |
| U1            | 238 |    1.1M |    4935 |
| U2            | 214 | 928.68K |    4935 |
| Us            |   0 |       0 |       0 |
| pe.cor        | 238 |    168M | 1390546 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 197.3 |    191 |  44.7 |         95.15% |
| ihist.merge.txt  | 239.4 |    232 |  51.5 |         99.29% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q0L0   |  64.7 |   54.4 |   15.98% |     181 | "109" | 4.03M | 3.96M |     0.98 | 0:00'31'' |
| Q20L60 |  63.5 |   54.1 |   14.84% |     182 | "109" | 4.03M | 3.95M |     0.98 | 0:00'30'' |
| Q25L60 |  60.2 |   52.7 |   12.47% |     180 | "109" | 4.03M | 3.94M |     0.98 | 0:00'29'' |
| Q30L60 |  53.4 |   48.2 |    9.73% |     174 | "103" | 4.03M | 3.93M |     0.97 | 0:00'26'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  94.50% |      8954 | 3.69M | 638 |       822 | 176.27K | 1385 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'44'' |
| Q0L0X50P000    |   50.0 |  93.96% |      8446 | 3.69M | 659 |       844 | 170.96K | 1425 |   47.0 | 6.0 |   9.7 |  94.0 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'43'' |
| Q0L0XallP000   |   54.4 |  93.82% |      7874 | 3.71M | 673 |       761 | 150.43K | 1458 |   51.0 | 7.0 |  10.0 | 102.0 | "31,41,51,61,71,81" | 0:01'05'' | 0:00'45'' |
| Q20L60X40P000  |   40.0 |  94.67% |     10194 | 3.68M | 587 |      1059 | 209.55K | 1320 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'44'' |
| Q20L60X50P000  |   50.0 |  94.22% |      8944 | 3.71M | 623 |      1017 | 166.96K | 1366 |   47.0 | 6.0 |   9.7 |  94.0 | "31,41,51,61,71,81" | 0:01'02'' | 0:00'44'' |
| Q20L60XallP000 |   54.1 |  94.13% |      8771 | 3.72M | 628 |       998 | 142.35K | 1368 |   51.0 | 7.0 |  10.0 | 102.0 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'44'' |
| Q25L60X40P000  |   40.0 |  96.92% |     32519 | 3.76M | 294 |      1027 | 130.17K |  736 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'46'' |
| Q25L60X50P000  |   50.0 |  96.62% |     24324 | 3.77M | 303 |      1110 |  117.7K |  724 |   47.0 | 6.0 |   9.7 |  94.0 | "31,41,51,61,71,81" | 0:00'59'' | 0:00'46'' |
| Q25L60XallP000 |   52.7 |  96.50% |     23630 | 3.79M | 303 |      1003 |  96.42K |  730 |   50.0 | 7.0 |   9.7 | 100.0 | "31,41,51,61,71,81" | 0:01'02'' | 0:00'45'' |
| Q30L60X40P000  |   40.0 |  96.97% |     30456 | 3.77M | 269 |      1073 | 126.36K |  691 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'46'' |
| Q30L60XallP000 |   48.2 |  96.81% |     27882 | 3.78M | 267 |      1062 | 103.74K |  673 |   46.0 | 6.0 |   9.3 |  92.0 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'45'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  96.78% |     19643 | 3.78M | 364 |       865 | 134.23K |  963 |   37.0 | 4.5 |   7.8 |  74.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'48'' |
| Q0L0X50P000    |   50.0 |  96.22% |     16642 | 3.77M | 434 |      1010 | 148.23K | 1012 |   46.0 | 6.0 |   9.3 |  92.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'45'' |
| Q0L0XallP000   |   54.4 |  95.99% |     14699 | 3.77M | 458 |      1010 | 135.95K | 1040 |   51.0 | 6.0 |  11.0 | 102.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'44'' |
| Q20L60X40P000  |   40.0 |  96.63% |     19665 | 3.75M | 396 |      1039 | 164.73K |  984 |   36.0 | 5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'46'' |
| Q20L60X50P000  |   50.0 |  96.25% |     16807 | 3.76M | 436 |      1031 | 156.03K | 1017 |   46.0 | 6.0 |   9.3 |  92.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'46'' |
| Q20L60XallP000 |   54.1 |  96.04% |     15915 | 3.79M | 450 |       922 | 117.15K | 1030 |   51.0 | 7.0 |  10.0 | 102.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'44'' |
| Q25L60X40P000  |   40.0 |  97.60% |     46715 | 3.79M | 241 |      1099 |  156.2K |  756 |   36.0 | 5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'49'' |
| Q25L60X50P000  |   50.0 |  97.55% |     55083 | 3.82M | 201 |      1068 |   96.2K |  582 |   46.0 | 7.0 |   8.3 |  92.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'50'' |
| Q25L60XallP000 |   52.7 |  97.55% |     57567 | 3.82M | 195 |      1069 |  96.99K |  566 |   48.0 | 7.0 |   9.0 |  96.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'49'' |
| Q30L60X40P000  |   40.0 |  97.63% |     47166 | 3.76M | 226 |      1052 | 183.12K |  751 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'51'' |
| Q30L60XallP000 |   48.2 |  97.67% |     55074 |  3.8M | 190 |      1181 | 135.84K |  626 |   44.5 | 5.5 |   9.3 |  89.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'50'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |  Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-----:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  96.42% |     27485 | 3.8M | 258 |      1046 | 74.67K | 548 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'44'' |
| MRXallP000 |   41.7 |  96.39% |     27485 | 3.8M | 263 |      1046 | 72.86K | 559 |   38.5 | 5.5 |   7.3 |  77.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'43'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  97.22% |     65642 | 3.85M | 149 |      1034 | 36.83K | 320 |   36.0 | 7.0 |   5.0 |  72.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'46'' |
| MRXallP000 |   41.7 |  97.19% |     65613 | 3.84M | 151 |      1039 | 45.73K | 319 |   37.0 | 7.0 |   5.3 |  74.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'44'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |   0.00% |     92817 | 3.87M | 116 |      1418 | 371.55K | 285 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeKunitigsAnchors   |   0.00% |     48037 | 3.83M | 201 |      1393 | 267.41K | 204 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRKunitigsAnchors |   0.00% |     27485 |  3.8M | 257 |      1383 |  48.12K |  36 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRTadpoleAnchors  |   0.00% |     65642 | 3.85M | 148 |      1181 |  31.94K |  26 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeTadpoleAnchors    |   0.00% |     75411 | 3.85M | 144 |      1508 |  280.1K | 210 |    0.0 | 0.0 |   0.0 |   0.0 |           |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|----------:|
| 8_spades     |  83.96% |    198941 | 3.84M | 179 |      1339 |   83.5K | 244 |   24.0 | 5.0 |   3.0 |  48.0 | 0:00'46'' |
| 8_spades_MR  |  84.21% |    112709 | 3.83M | 222 |      1187 |  96.18K | 313 |   24.0 | 4.0 |   4.0 |  48.0 | 0:00'45'' |
| 8_megahit    |  83.03% |     64680 | 3.78M | 261 |      1197 | 108.62K | 380 |   24.0 | 4.0 |   4.0 |  48.0 | 0:00'44'' |
| 8_megahit_MR |  84.04% |     71707 | 3.83M | 244 |      1197 | 101.12K | 372 |   24.0 | 5.0 |   3.0 |  48.0 | 0:00'45'' |
| 8_platanus   |  86.03% |     36372 |  3.7M | 356 |      1137 | 176.81K | 541 |   22.0 | 3.0 |   4.3 |  44.0 | 0:00'45'' |


Table: statFinal

| Name                     |     N50 |     Sum |   # |
|:-------------------------|--------:|--------:|----:|
| Genome                   | 2961149 | 4033464 |   2 |
| Paralogs                 |    3483 |  114707 |  48 |
| 7_mergeAnchors.anchors   |   92817 | 3865418 | 116 |
| 7_mergeAnchors.others    |    1418 |  371546 | 285 |
| anchorLong               |   98338 | 3864997 | 107 |
| anchorFill               |  195172 | 3875072 |  60 |
| spades.contig            |  246446 | 4137365 | 620 |
| spades.scaffold          |  259375 | 4137565 | 618 |
| spades.non-contained     |  246446 | 3922347 |  65 |
| spades_MR.contig         |  115058 | 3946042 | 138 |
| spades_MR.scaffold       |  115058 | 3946162 | 135 |
| spades_MR.non-contained  |  115058 | 3926095 |  91 |
| megahit.contig           |   87638 | 3955281 | 265 |
| megahit.non-contained    |   87638 | 3887171 | 119 |
| megahit_MR.contig        |   92296 | 3974537 | 234 |
| megahit_MR.non-contained |   92931 | 3927106 | 129 |
| platanus.contig          |   43440 | 3985117 | 557 |
| platanus.scaffold        |   47258 | 3931736 | 332 |
| platanus.non-contained   |   47258 | 3875937 | 185 |


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


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|----------:|
| 8_spades     |  87.77% |    198944 | 3.85M | 136 |      1337 |   69.5K | 198 |   29.0 | 4.5 |   5.2 |  58.0 | 0:00'45'' |
| 8_spades_MR  |  88.11% |     60481 | 3.76M | 327 |      1366 | 171.46K | 421 |   28.0 | 3.0 |   6.3 |  55.5 | 0:00'45'' |
| 8_megahit    |  87.33% |     83484 | 3.83M | 197 |      1209 |  76.03K | 305 |   29.0 | 4.0 |   5.7 |  58.0 | 0:00'45'' |
| 8_megahit_MR |  88.08% |     66266 | 3.81M | 248 |      1164 | 125.33K | 386 |   29.0 | 3.5 |   6.2 |  58.0 | 0:00'45'' |
| 8_platanus   |  90.88% |     61450 | 3.76M | 341 |      1184 | 138.37K | 430 |   25.0 | 4.0 |   4.3 |  50.0 | 0:00'45'' |


Table: statFinal

| Name                     |     N50 |     Sum |    # |
|:-------------------------|--------:|--------:|-----:|
| Genome                   | 2961149 | 4033464 |    2 |
| Paralogs                 |    3483 |  114707 |   48 |
| 7_mergeAnchors.anchors   |   29448 | 3818010 |  296 |
| 7_mergeAnchors.others    |    1066 |  665799 |  580 |
| anchorLong               |   30672 | 3798157 |  263 |
| anchorFill               |       0 |       0 |    0 |
| spades.contig            |  198954 | 3951387 |  169 |
| spades.scaffold          |  246373 | 3951617 |  164 |
| spades.non-contained     |  198954 | 3920941 |   62 |
| spades_MR.contig         |   80992 | 3955866 |  151 |
| spades_MR.scaffold       |   92096 | 3957333 |  141 |
| spades_MR.non-contained  |   80992 | 3932000 |   95 |
| megahit.contig           |   84615 | 3945505 |  197 |
| megahit.non-contained    |   84615 | 3904976 |  108 |
| megahit_MR.contig        |   67019 | 3990253 |  250 |
| megahit_MR.non-contained |   67826 | 3939329 |  138 |
| platanus.contig          |   11093 | 3999233 | 1539 |
| platanus.scaffold        |   95194 | 3926993 |  213 |
| platanus.non-contained   |   95194 | 3895206 |   89 |


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


Table: statSgaPreQC

| Item           |  Value |
|:---------------|-------:|
| incorrectBases |  2.31% |
| perfectReads   | 10.54% |
| overlapDepth   | 433.53 |


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
| merged        | 459 |   2.06G |  4874962 |
| unmerged.raw  | 157 | 363.94M |  2430642 |
| unmerged.trim | 157 | 363.88M |  2430174 |
| U1            | 169 | 194.67M |  1215087 |
| U2            | 145 |  169.2M |  1215087 |
| Us            |   0 |       0 |        0 |
| pe.cor        | 456 |   2.42G | 12180098 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 189.2 |    185 |  65.3 |         10.72% |
| ihist.merge.txt  | 421.6 |    457 |  87.1 |         80.05% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q0L0   | 369.9 |  333.3 |    9.89% |     141 | "39" |  4.6M | 5.11M |     1.11 | 0:02'53'' |
| Q20L60 | 360.1 |  326.4 |    9.35% |     143 | "39" |  4.6M |  4.8M |     1.04 | 0:02'50'' |
| Q25L60 | 316.9 |  301.4 |    4.90% |     134 | "37" |  4.6M | 4.59M |     1.00 | 0:02'33'' |
| Q30L60 | 236.3 |  231.2 |    2.16% |     116 | "31" |  4.6M | 4.55M |     0.99 | 0:02'01'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  89.88% |      6192 |    4M |  897 |      1472 | 471.58K | 3096 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'53'' |
| Q0L0X40P001   |   40.0 |  89.12% |      5996 | 3.97M |  894 |      1530 | 486.97K | 3049 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'52'' |
| Q0L0X40P002   |   40.0 |  89.63% |      6677 | 3.99M |  880 |      1388 |  483.6K | 3060 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'53'' |
| Q0L0X40P003   |   40.0 |  89.31% |      6511 |    4M |  889 |      1514 |  457.9K | 2966 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'51'' |
| Q0L0X40P004   |   40.0 |  89.88% |      6206 |    4M |  896 |      1550 | 478.48K | 3011 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'51'' |
| Q0L0X40P005   |   40.0 |  88.47% |      5685 | 3.97M |  952 |      1461 | 452.35K | 3069 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'52'' |
| Q0L0X40P006   |   40.0 |  89.26% |      5944 | 3.99M |  919 |      1459 | 478.78K | 3074 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'51'' |
| Q0L0X40P007   |   40.0 |  89.65% |      6191 | 3.99M |  887 |      1462 | 458.03K | 3014 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'52'' |
| Q0L0X80P000   |   80.0 |  75.96% |      2857 | 3.55M | 1435 |      1055 | 359.31K | 3624 |   64.0 | 6.0 |  15.3 | 123.0 | "31,41,51,61,71,81" | 0:01'17'' | 0:00'48'' |
| Q0L0X80P001   |   80.0 |  74.70% |      2777 |  3.5M | 1437 |      1048 |  359.3K | 3615 |   64.0 | 6.0 |  15.3 | 123.0 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'46'' |
| Q0L0X80P002   |   80.0 |  74.64% |      2631 |  3.5M | 1488 |      1042 |    355K | 3669 |   64.0 | 6.0 |  15.3 | 123.0 | "31,41,51,61,71,81" | 0:01'17'' | 0:00'47'' |
| Q0L0X80P003   |   80.0 |  75.08% |      2841 | 3.53M | 1459 |      1035 | 346.42K | 3592 |   64.0 | 6.0 |  15.3 | 123.0 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'47'' |
| Q20L60X40P000 |   40.0 |  92.89% |      9166 | 4.04M |  676 |      1941 | 545.27K | 2526 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'54'' |
| Q20L60X40P001 |   40.0 |  92.56% |      9440 | 4.03M |  638 |      1812 |  516.5K | 2417 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'54'' |
| Q20L60X40P002 |   40.0 |  92.33% |      9320 | 4.02M |  676 |      1867 | 503.95K | 2500 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'55'' |
| Q20L60X40P003 |   40.0 |  92.39% |      8147 | 4.04M |  695 |      1829 | 534.32K | 2587 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'54'' |
| Q20L60X40P004 |   40.0 |  92.73% |      8462 | 4.02M |  691 |      1796 | 546.39K | 2498 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'53'' |
| Q20L60X40P005 |   40.0 |  92.25% |      8602 | 4.02M |  711 |      1787 | 543.45K | 2607 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'54'' |
| Q20L60X40P006 |   40.0 |  92.48% |      9009 | 4.03M |  665 |      1827 | 545.17K | 2473 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'53'' |
| Q20L60X40P007 |   40.0 |  92.18% |      9297 | 4.02M |  675 |      1645 | 508.59K | 2532 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'53'' |
| Q20L60X80P000 |   80.0 |  84.14% |      4460 | 3.87M | 1106 |      1120 | 384.62K | 3136 |   66.0 | 6.0 |  16.0 | 126.0 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'50'' |
| Q20L60X80P001 |   80.0 |  83.55% |      4442 | 3.86M | 1131 |      1159 | 378.62K | 3154 |   66.0 | 5.0 |  17.0 | 121.5 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'51'' |
| Q20L60X80P002 |   80.0 |  83.78% |      4248 | 3.84M | 1143 |      1188 | 408.04K | 3214 |   66.0 | 6.0 |  16.0 | 126.0 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'50'' |
| Q20L60X80P003 |   80.0 |  84.02% |      4419 | 3.83M | 1126 |      1161 | 405.78K | 3170 |   67.0 | 6.0 |  16.3 | 127.5 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'51'' |
| Q25L60X40P000 |   40.0 |  97.39% |     16178 | 4.06M |  418 |      4584 | 642.88K | 1553 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'52'' |
| Q25L60X40P001 |   40.0 |  97.75% |     18947 | 4.07M |  385 |      4900 | 688.76K | 1487 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'52'' |
| Q25L60X40P002 |   40.0 |  97.33% |     17211 | 4.07M |  407 |      4778 | 647.64K | 1565 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'54'' |
| Q25L60X40P003 |   40.0 |  97.37% |     16773 | 4.05M |  402 |      5440 | 687.23K | 1456 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'52'' |
| Q25L60X40P004 |   40.0 |  97.52% |     17146 | 4.06M |  405 |      3842 | 652.52K | 1522 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'54'' |
| Q25L60X40P005 |   40.0 |  97.68% |     17351 | 4.06M |  407 |      5242 | 678.43K | 1496 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'53'' |
| Q25L60X40P006 |   40.0 |  97.40% |     15396 | 4.05M |  420 |      5055 | 679.84K | 1550 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'53'' |
| Q25L60X80P000 |   80.0 |  96.09% |     16873 | 4.08M |  409 |      2964 | 576.53K | 1663 |   70.0 | 6.0 |  17.3 | 132.0 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'56'' |
| Q25L60X80P001 |   80.0 |  95.86% |     17041 | 4.07M |  395 |      3441 | 632.67K | 1675 |   69.0 | 5.5 |  17.5 | 128.2 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'58'' |
| Q25L60X80P002 |   80.0 |  96.22% |     18126 | 4.06M |  395 |      3616 | 624.01K | 1667 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'58'' |
| Q30L60X40P000 |   40.0 |  98.13% |     12638 |    4M |  518 |      8973 | 776.01K | 1610 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'51'' |
| Q30L60X40P001 |   40.0 |  98.16% |     13884 | 4.01M |  492 |      8026 | 766.37K | 1560 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'51'' |
| Q30L60X40P002 |   40.0 |  98.29% |     12713 |    4M |  520 |      7446 | 698.12K | 1611 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'51'' |
| Q30L60X40P003 |   40.0 |  98.27% |     12948 |    4M |  506 |      8881 | 759.27K | 1574 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'52'' |
| Q30L60X40P004 |   40.0 |  98.30% |     12488 | 3.99M |  525 |      7523 | 799.06K | 1587 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'51'' |
| Q30L60X80P000 |   80.0 |  98.45% |     18419 | 4.05M |  372 |     10923 | 821.87K | 1345 |   70.0 | 6.0 |  17.3 | 132.0 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'56'' |
| Q30L60X80P001 |   80.0 |  98.44% |     19290 | 4.05M |  372 |      9416 |  788.9K | 1336 |   70.0 | 6.0 |  17.3 | 132.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'55'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  97.86% |     20364 | 4.04M | 340 |      7393 | 769.86K | 1408 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:01'07'' |
| Q0L0X40P001   |   40.0 |  97.66% |     18766 | 4.03M | 350 |      7664 | 840.41K | 1432 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:01'08'' |
| Q0L0X40P002   |   40.0 |  97.80% |     21737 | 4.03M | 341 |      7761 | 760.24K | 1393 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:01'07'' |
| Q0L0X40P003   |   40.0 |  97.79% |     20282 | 4.04M | 355 |      8604 | 777.02K | 1434 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:01'08'' |
| Q0L0X40P004   |   40.0 |  97.66% |     20748 | 4.05M | 345 |      6274 | 737.39K | 1368 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'38'' | 0:01'07'' |
| Q0L0X40P005   |   40.0 |  97.70% |     20077 | 4.03M | 359 |      7130 | 807.38K | 1419 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:01'07'' |
| Q0L0X40P006   |   40.0 |  97.70% |     18791 | 4.05M | 361 |      8111 | 799.46K | 1427 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:01'07'' |
| Q0L0X40P007   |   40.0 |  97.72% |     17592 | 4.08M | 384 |      5218 | 682.16K | 1412 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:01'07'' |
| Q0L0X80P000   |   80.0 |  97.75% |     20188 | 4.09M | 348 |      5827 | 753.88K | 1695 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:01'14'' |
| Q0L0X80P001   |   80.0 |  97.78% |     20900 | 4.09M | 356 |      5884 | 732.95K | 1757 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:01'16'' |
| Q0L0X80P002   |   80.0 |  97.64% |     19646 | 4.08M | 348 |      5294 |  737.3K | 1689 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:01'14'' |
| Q0L0X80P003   |   80.0 |  97.58% |     22188 | 4.08M | 342 |      5572 | 729.59K | 1650 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:01'12'' |
| Q20L60X40P000 |   40.0 |  98.00% |     18041 | 4.05M | 381 |      7920 | 803.57K | 1428 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'38'' | 0:01'07'' |
| Q20L60X40P001 |   40.0 |  98.18% |     19497 | 4.07M | 379 |      6641 | 725.21K | 1368 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:01'06'' |
| Q20L60X40P002 |   40.0 |  98.04% |     17939 | 4.05M | 383 |      7809 | 814.51K | 1382 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:01'07'' |
| Q20L60X40P003 |   40.0 |  98.01% |     18427 | 4.06M | 372 |      7762 | 788.05K | 1388 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'38'' | 0:01'07'' |
| Q20L60X40P004 |   40.0 |  98.01% |     18246 | 4.06M | 375 |      6625 | 759.93K | 1434 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:01'08'' |
| Q20L60X40P005 |   40.0 |  97.95% |     18072 | 4.02M | 395 |      9214 | 801.15K | 1467 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:01'06'' |
| Q20L60X40P006 |   40.0 |  98.13% |     17140 | 4.06M | 384 |      6800 | 747.28K | 1379 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:01'07'' |
| Q20L60X40P007 |   40.0 |  98.01% |     19305 | 4.05M | 371 |      7152 | 683.79K | 1344 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'39'' | 0:01'06'' |
| Q20L60X80P000 |   80.0 |  98.12% |     19128 | 4.08M | 360 |      5986 | 727.36K | 1550 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:01'11'' |
| Q20L60X80P001 |   80.0 |  98.28% |     20803 |  4.1M | 338 |      7277 | 830.94K | 1585 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:01'14'' |
| Q20L60X80P002 |   80.0 |  98.08% |     20015 | 4.08M | 359 |      7267 | 788.46K | 1628 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:01'13'' |
| Q20L60X80P003 |   80.0 |  98.11% |     23787 | 4.07M | 310 |      5339 |  779.6K | 1493 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:01'13'' |
| Q25L60X40P000 |   40.0 |  98.15% |     13475 | 4.01M | 489 |     10345 | 772.12K | 1530 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:01'03'' |
| Q25L60X40P001 |   40.0 |  98.29% |     14312 | 4.03M | 457 |      9881 | 769.31K | 1458 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'38'' | 0:01'04'' |
| Q25L60X40P002 |   40.0 |  98.27% |     13984 | 4.04M | 483 |      8104 | 706.71K | 1512 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:01'04'' |
| Q25L60X40P003 |   40.0 |  98.28% |     14256 | 4.02M | 466 |     10993 | 772.01K | 1492 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'39'' | 0:01'03'' |
| Q25L60X40P004 |   40.0 |  98.31% |     13750 | 4.03M | 457 |      6850 | 741.79K | 1514 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:01'04'' |
| Q25L60X40P005 |   40.0 |  98.32% |     14406 | 4.02M | 459 |      9579 |  751.8K | 1508 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:01'03'' |
| Q25L60X40P006 |   40.0 |  98.20% |     13732 | 4.01M | 478 |      9586 | 747.84K | 1542 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:01'04'' |
| Q25L60X80P000 |   80.0 |  98.47% |     20978 | 4.06M | 332 |     10737 | 739.77K | 1273 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:01'09'' |
| Q25L60X80P001 |   80.0 |  98.59% |     21834 | 4.06M | 329 |     12243 | 727.15K | 1286 |   69.0 | 5.0 |  18.0 | 126.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:01'09'' |
| Q25L60X80P002 |   80.0 |  98.59% |     22067 | 4.05M | 321 |     10032 | 676.94K | 1221 |   70.0 | 5.0 |  18.3 | 127.5 | "31,41,51,61,71,81" | 0:00'46'' | 0:01'09'' |
| Q30L60X40P000 |   40.0 |  97.90% |      8287 | 3.92M | 715 |      6941 |  827.5K | 2004 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'37'' | 0:01'00'' |
| Q30L60X40P001 |   40.0 |  97.86% |      9014 | 3.95M | 679 |      6678 | 837.78K | 1951 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:01'03'' |
| Q30L60X40P002 |   40.0 |  97.82% |      8656 | 3.92M | 691 |      5574 | 779.15K | 2023 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'37'' | 0:01'01'' |
| Q30L60X40P003 |   40.0 |  97.76% |      8377 | 3.95M | 688 |      7523 | 776.53K | 1939 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:01'01'' |
| Q30L60X40P004 |   40.0 |  97.72% |      8563 | 3.93M | 705 |      6198 |  797.6K | 1978 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'37'' | 0:01'01'' |
| Q30L60X80P000 |   80.0 |  98.47% |     13902 | 4.03M | 465 |      8202 | 737.76K | 1527 |   70.0 | 6.0 |  17.3 | 132.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:01'06'' |
| Q30L60X80P001 |   80.0 |  98.39% |     13905 | 4.02M | 466 |      8889 | 740.71K | 1523 |   70.0 | 6.0 |  17.3 | 132.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:01'07'' |


Table: statMRKunitigsAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  97.69% |     52253 | 4.12M | 192 |      8200 | 456.62K | 478 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'53'' |
| MRX40P001 |   40.0 |  97.74% |     51081 | 4.08M | 168 |     11127 | 495.38K | 460 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'11'' | 0:00'53'' |
| MRX40P002 |   40.0 |  97.65% |     53612 | 4.08M | 168 |     12285 | 530.67K | 471 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'09'' | 0:00'55'' |
| MRX40P003 |   40.0 |  97.65% |     46831 | 4.07M | 171 |     12338 | 496.02K | 448 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'53'' |
| MRX40P004 |   40.0 |  97.76% |     44582 | 4.08M | 182 |     12285 | 490.99K | 477 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'53'' |
| MRX40P005 |   40.0 |  97.70% |     45039 | 4.08M | 187 |     12285 | 512.12K | 482 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'11'' | 0:00'50'' |
| MRX40P006 |   40.0 |  97.76% |     46738 | 4.08M | 180 |     10662 | 528.43K | 493 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'53'' |
| MRX40P007 |   40.0 |  97.80% |     53954 | 4.11M | 180 |      9105 | 473.08K | 471 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'54'' |
| MRX40P008 |   40.0 |  97.79% |     46815 | 4.08M | 173 |     12285 | 534.14K | 486 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'09'' | 0:00'56'' |
| MRX40P009 |   40.0 |  97.69% |     43952 | 4.08M | 187 |     10044 | 509.06K | 484 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'09'' | 0:00'51'' |
| MRX40P010 |   40.0 |  97.67% |     45114 | 4.08M | 184 |     12964 | 492.12K | 460 |   35.0 | 2.0 |   9.7 |  61.5 | "31,41,51,61,71,81" | 0:01'09'' | 0:00'52'' |
| MRX40P011 |   40.0 |  97.61% |     44584 | 4.08M | 177 |     11818 | 492.22K | 474 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'51'' |
| MRX40P012 |   40.0 |  97.74% |     54938 | 4.07M | 180 |     12285 | 505.92K | 474 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'53'' |
| MRX80P000 |   80.0 |  97.31% |     33518 | 4.07M | 232 |     10042 | 494.27K | 579 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:01'48'' | 0:00'52'' |
| MRX80P001 |   80.0 |  97.26% |     34804 | 4.07M | 215 |     11818 | 497.33K | 540 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:01'48'' | 0:00'52'' |
| MRX80P002 |   80.0 |  97.22% |     31267 | 4.08M | 241 |     11395 | 493.48K | 585 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:01'48'' | 0:00'50'' |
| MRX80P003 |   80.0 |  97.24% |     34957 | 4.07M | 214 |      9292 | 487.63K | 552 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:01'48'' | 0:00'51'' |
| MRX80P004 |   80.0 |  97.28% |     34075 | 4.08M | 233 |      9670 | 503.81K | 568 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:01'49'' | 0:00'51'' |
| MRX80P005 |   80.0 |  97.18% |     33628 | 4.07M | 228 |     10126 | 498.85K | 560 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:01'48'' | 0:00'51'' |


Table: statMRTadpoleAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  98.01% |     64784 | 4.08M | 148 |     13134 | 499.87K | 419 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'02'' | 0:00'52'' |
| MRX40P001 |   40.0 |  98.05% |     63307 | 4.08M | 147 |     13674 | 494.43K | 423 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'55'' |
| MRX40P002 |   40.0 |  98.11% |     76095 | 4.08M | 144 |     13659 | 495.07K | 412 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'56'' |
| MRX40P003 |   40.0 |  98.07% |     64742 | 4.07M | 148 |     15571 | 520.07K | 406 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'55'' |
| MRX40P004 |   40.0 |  98.01% |     55492 | 4.08M | 157 |     12569 | 458.33K | 426 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'53'' |
| MRX40P005 |   40.0 |  98.07% |     55545 | 4.09M | 165 |     12569 | 564.55K | 456 |   35.0 | 2.0 |   9.7 |  61.5 | "31,41,51,61,71,81" | 0:01'11'' | 0:00'54'' |
| MRX40P006 |   40.0 |  98.09% |     58669 | 4.09M | 165 |     12569 | 528.11K | 462 |   35.0 | 2.0 |   9.7 |  61.5 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'54'' |
| MRX40P007 |   40.0 |  97.99% |     55854 | 4.08M | 149 |     13415 | 484.72K | 412 |   35.0 | 2.0 |   9.7 |  61.5 | "31,41,51,61,71,81" | 0:01'04'' | 0:00'54'' |
| MRX40P008 |   40.0 |  98.02% |     55461 | 4.09M | 165 |     12962 | 541.91K | 450 |   35.0 | 2.0 |   9.7 |  61.5 | "31,41,51,61,71,81" | 0:01'08'' | 0:00'53'' |
| MRX40P009 |   40.0 |  98.05% |     51356 | 4.08M | 166 |     13179 | 586.96K | 450 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'52'' |
| MRX40P010 |   40.0 |  97.99% |     55360 | 4.07M | 160 |     13221 | 486.65K | 427 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'54'' |
| MRX40P011 |   40.0 |  98.01% |     58660 | 4.08M | 159 |     12962 | 522.17K | 428 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'05'' | 0:00'53'' |
| MRX40P012 |   40.0 |  98.02% |     58557 | 4.08M | 165 |     12962 | 487.34K | 437 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'54'' |
| MRX80P000 |   80.0 |  98.04% |     77003 | 4.09M | 134 |     12285 | 462.04K | 389 |   70.0 | 4.0 |  19.3 | 123.0 | "31,41,51,61,71,81" | 0:01'16'' | 0:01'00'' |
| MRX80P001 |   80.0 |  97.98% |     74351 | 4.09M | 141 |     15382 | 510.24K | 395 |   70.0 | 4.5 |  18.8 | 125.2 | "31,41,51,61,71,81" | 0:01'15'' | 0:00'55'' |
| MRX80P002 |   80.0 |  97.99% |     60933 | 4.09M | 141 |     13167 | 453.48K | 382 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:01'17'' | 0:00'54'' |
| MRX80P003 |   80.0 |  97.98% |     71540 | 4.09M | 144 |     13756 | 523.76K | 372 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:01'16'' | 0:00'53'' |
| MRX80P004 |   80.0 |  97.96% |     58655 | 4.09M | 152 |     15941 | 526.74K | 400 |   69.0 | 4.0 |  19.0 | 121.5 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'55'' |
| MRX80P005 |   80.0 |  97.95% |     53189 | 4.09M | 151 |     12983 | 511.61K | 393 |   70.0 | 4.0 |  19.3 | 123.0 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'56'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |   Sum |   # | N50Others |   Sum |    # | median |  MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|------:|----:|----------:|------:|-----:|-------:|-----:|------:|------:|----------:|
| 7_mergeAnchors           |  75.60% |    150906 | 4.13M |  95 |     13681 | 3.23M | 1086 |  159.0 |  8.0 |  20.0 | 274.5 | 0:01'16'' |
| 7_mergeKunitigsAnchors   |  81.62% |     58901 | 4.09M | 142 |      4355 | 2.76M | 1221 |  156.0 |  9.0 |  20.0 | 274.5 | 0:01'50'' |
| 7_mergeMRKunitigsAnchors |  81.84% |    134754 |  4.1M | 106 |     19585 | 1.31M |  150 |  161.0 | 13.0 |  20.0 | 300.0 | 0:01'52'' |
| 7_mergeMRTadpoleAnchors  |  81.86% |    131376 | 4.09M | 109 |     26145 | 1.23M |  122 |  160.0 | 12.0 |  20.0 | 294.0 | 0:01'57'' |
| 7_mergeTadpoleAnchors    |  81.32% |     49373 |  4.1M | 161 |     10915 | 1.87M |  527 |  158.0 |  9.0 |  20.0 | 277.5 | 0:01'48'' |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median |   MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|------:|------:|------:|----------:|
| 8_spades     |  90.01% |    315879 | 4.12M |  47 |     26291 | 443.05K |  89 |  165.0 |  11.0 |  20.0 | 297.0 | 0:01'07'' |
| 8_spades_MR  |  90.17% |    315976 | 4.46M |  58 |      6098 | 122.02K |  80 |  277.5 | 119.0 |   3.0 | 555.0 | 0:01'09'' |
| 8_megahit    |  89.33% |    141488 | 4.12M | 108 |     12571 | 420.53K | 221 |  163.0 |  15.0 |  20.0 | 312.0 | 0:01'04'' |
| 8_megahit_MR |  90.18% |    252110 | 4.17M |  76 |     11460 | 413.45K | 141 |  167.0 |  15.0 |  20.0 | 318.0 | 0:01'06'' |
| 8_platanus   |  94.46% |     96617 | 4.16M | 113 |      6056 | 381.84K | 232 |  142.0 |  30.0 |  17.3 | 284.0 | 0:01'00'' |


Table: statFinal

| Name                     |     N50 |     Sum |    # |
|:-------------------------|--------:|--------:|-----:|
| Genome                   | 3188524 | 4602977 |    7 |
| Paralogs                 |    2337 |  147155 |   66 |
| 7_mergeAnchors.anchors   |  150906 | 4127348 |   95 |
| 7_mergeAnchors.others    |   13681 | 3227715 | 1086 |
| anchorLong               |  151565 | 4123813 |   90 |
| anchorFill               |  284424 | 4145382 |   44 |
| spades.contig            |  315956 | 4592241 |  127 |
| spades.scaffold          |  384710 | 4592461 |  123 |
| spades.non-contained     |  315956 | 4566716 |   43 |
| spades_MR.contig         |  315998 | 4586185 |   54 |
| spades_MR.scaffold       |  333559 | 4586285 |   53 |
| spades_MR.non-contained  |  315998 | 4578383 |   36 |
| megahit.contig           |  131525 | 4575784 |  183 |
| megahit.non-contained    |  131525 | 4541205 |  113 |
| megahit_MR.contig        |  201317 | 4604971 |  128 |
| megahit_MR.non-contained |  201317 | 4578809 |   65 |
| platanus.contig          |    4915 | 4785248 | 2537 |
| platanus.scaffold        |   92293 | 4689321 | 1158 |
| platanus.non-contained   |   92293 | 4537841 |  119 |


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


Table: statSgaPreQC

| Item           | Value |
|:---------------|------:|
| incorrectBases | 0.00% |
| perfectReads   | 0.00% |
| overlapDepth   |       |


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
| ecct          | 176 |   1.18G | 7303933 |
| extended      | 214 |   1.47G | 7303933 |
| merged        | 207 |  13.18M |   69124 |
| unmerged.raw  | 214 |   1.45G | 7165684 |
| unmerged.trim | 214 |   1.45G | 7164492 |
| U1            | 215 | 629.78M | 3090555 |
| U2            | 215 | 631.39M | 3090555 |
| Us            | 206 | 188.84M |  983382 |
| pe.cor        | 214 |   1.46G | 8286122 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 155.1 |    149 |  58.4 |          1.80% |
| ihist.merge.txt  | 190.7 |    182 |  64.3 |          1.89% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q0L0   | 261.0 |  206.3 |   20.98% |     157 | "45" | 5.09M | 5.93M |     1.16 | 0:02'05'' |
| Q20L60 | 250.7 |  202.2 |   19.35% |     160 | "45" | 5.09M | 5.83M |     1.14 | 0:02'00'' |
| Q25L60 | 225.9 |  189.7 |   16.04% |     156 | "43" | 5.09M | 5.66M |     1.11 | 0:01'51'' |
| Q30L60 | 183.4 |  159.8 |   12.87% |     150 | "39" | 5.09M | 5.41M |     1.06 | 0:01'33'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  79.32% |      2255 |  3.7M | 1788 |      1026 | 640.53K | 3898 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'44'' |
| Q0L0X40P001   |   40.0 |  78.51% |      2111 | 3.56M | 1810 |      1038 | 742.01K | 3954 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'44'' |
| Q0L0X40P002   |   40.0 |  79.38% |      2247 | 3.69M | 1780 |      1033 |  651.6K | 3918 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'45'' |
| Q0L0X40P003   |   40.0 |  78.66% |      2181 | 3.66M | 1807 |      1028 | 646.34K | 3958 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'45'' |
| Q0L0X40P004   |   40.0 |  79.15% |      2189 | 3.72M | 1820 |      1025 | 634.97K | 3999 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'45'' |
| Q0L0X80P000   |   80.0 |  52.52% |      1560 | 2.28M | 1459 |      1040 | 555.53K | 3266 |   67.0 | 6.0 |  16.3 | 127.5 | "31,41,51,61,71,81" | 0:01'25'' | 0:00'39'' |
| Q0L0X80P001   |   80.0 |  52.16% |      1548 | 2.28M | 1465 |      1040 | 533.99K | 3272 |   67.0 | 6.0 |  16.3 | 127.5 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'40'' |
| Q20L60X40P000 |   40.0 |  80.48% |      2262 | 3.77M | 1813 |      1025 | 638.05K | 3958 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'45'' |
| Q20L60X40P001 |   40.0 |  80.34% |      2322 | 3.75M | 1765 |      1026 | 643.36K | 3861 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'46'' |
| Q20L60X40P002 |   40.0 |  80.69% |      2348 | 3.74M | 1753 |      1022 | 662.75K | 3890 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'45'' |
| Q20L60X40P003 |   40.0 |  80.88% |      2300 | 3.79M | 1776 |      1016 | 629.27K | 3911 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'45'' |
| Q20L60X40P004 |   40.0 |  81.37% |      2260 | 3.78M | 1802 |      1028 | 675.62K | 3975 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'45'' |
| Q20L60X80P000 |   80.0 |  55.28% |      1617 | 2.42M | 1506 |      1037 | 552.39K | 3364 |   67.0 | 6.0 |  16.3 | 127.5 | "31,41,51,61,71,81" | 0:01'25'' | 0:00'40'' |
| Q20L60X80P001 |   80.0 |  55.87% |      1627 | 2.33M | 1446 |      1050 | 683.81K | 3333 |   67.0 | 5.0 |  17.3 | 123.0 | "31,41,51,61,71,81" | 0:01'25'' | 0:00'41'' |
| Q25L60X40P000 |   40.0 |  86.44% |      2685 | 4.08M | 1734 |      1032 | 646.35K | 3848 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'49'' |
| Q25L60X40P001 |   40.0 |  86.53% |      2719 |  4.1M | 1717 |      1019 | 635.88K | 3888 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'46'' |
| Q25L60X40P002 |   40.0 |  86.02% |      2618 | 4.07M | 1731 |      1024 | 638.04K | 3824 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'46'' |
| Q25L60X40P003 |   40.0 |  86.09% |      2551 | 4.04M | 1763 |      1013 | 656.92K | 3895 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'48'' |
| Q25L60X80P000 |   80.0 |  68.66% |      1861 | 3.14M | 1754 |      1030 |  577.9K | 3906 |   69.0 | 6.0 |  17.0 | 130.5 | "31,41,51,61,71,81" | 0:01'25'' | 0:00'42'' |
| Q25L60X80P001 |   80.0 |  68.05% |      1788 | 3.11M | 1779 |      1029 | 573.92K | 3926 |   68.0 | 6.0 |  16.7 | 129.0 | "31,41,51,61,71,81" | 0:01'25'' | 0:00'44'' |
| Q30L60X40P000 |   40.0 |  97.64% |      9223 |  4.8M |  918 |      1003 | 448.04K | 2439 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'54'' |
| Q30L60X40P001 |   40.0 |  97.41% |      8033 | 4.75M |  974 |      1039 |  486.4K | 2467 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'54'' |
| Q30L60X40P002 |   40.0 |  97.72% |      7459 | 4.67M | 1072 |      1020 | 618.49K | 2676 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'56'' |
| Q30L60X80P000 |   80.0 |  94.65% |      5080 | 4.72M | 1251 |       848 | 359.65K | 2945 |   74.0 | 5.0 |  19.7 | 133.5 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'52'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  97.77% |     15395 | 4.92M |  616 |       934 | 353.55K | 1744 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'56'' |
| Q0L0X40P001   |   40.0 |  97.84% |     16453 | 4.99M |  567 |       740 | 232.04K | 1666 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'58'' |
| Q0L0X40P002   |   40.0 |  97.81% |     15943 | 4.92M |  604 |       924 | 328.64K | 1701 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'55'' |
| Q0L0X40P003   |   40.0 |  97.68% |     15523 | 4.91M |  614 |       935 | 338.64K | 1759 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'55'' |
| Q0L0X40P004   |   40.0 |  97.84% |     16475 | 4.93M |  635 |       925 | 344.28K | 1714 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'56'' |
| Q0L0X80P000   |   80.0 |  95.49% |      6355 | 4.88M | 1106 |       623 |  305.9K | 2893 |   74.0 | 5.0 |  19.7 | 133.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'53'' |
| Q0L0X80P001   |   80.0 |  95.36% |      6453 | 4.87M | 1065 |       708 |  309.4K | 2754 |   74.0 | 5.0 |  19.7 | 133.5 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'53'' |
| Q20L60X40P000 |   40.0 |  97.89% |     14578 | 4.91M |  651 |       845 |    344K | 1826 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'56'' |
| Q20L60X40P001 |   40.0 |  97.73% |     16940 | 4.99M |  533 |       839 | 222.98K | 1620 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'56'' |
| Q20L60X40P002 |   40.0 |  97.83% |     16866 | 4.96M |  576 |       836 | 278.61K | 1809 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'59'' |
| Q20L60X40P003 |   40.0 |  97.89% |     15965 | 4.99M |  567 |       714 |  240.5K | 1747 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'56'' |
| Q20L60X40P004 |   40.0 |  97.96% |     17600 |    5M |  532 |       747 | 214.23K | 1610 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'57'' |
| Q20L60X80P000 |   80.0 |  95.47% |      6180 | 4.86M | 1060 |       777 | 317.74K | 2805 |   74.0 | 5.0 |  19.7 | 133.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'53'' |
| Q20L60X80P001 |   80.0 |  95.58% |      7111 | 4.87M | 1022 |       589 | 290.86K | 2750 |   74.0 | 5.0 |  19.7 | 133.5 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'55'' |
| Q25L60X40P000 |   40.0 |  98.21% |     17024 | 4.96M |  613 |       781 | 282.12K | 1873 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'58'' |
| Q25L60X40P001 |   40.0 |  98.37% |     20837 | 4.99M |  513 |       959 | 283.28K | 1683 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'57'' |
| Q25L60X40P002 |   40.0 |  98.28% |     16954 | 4.98M |  572 |       721 | 257.02K | 1847 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'57'' |
| Q25L60X40P003 |   40.0 |  98.26% |     17695 | 4.98M |  528 |       839 | 275.51K | 1722 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'58'' |
| Q25L60X80P000 |   80.0 |  96.67% |      7647 | 4.88M |  967 |       834 | 349.73K | 2650 |   75.0 | 4.0 |  20.0 | 130.5 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'56'' |
| Q25L60X80P001 |   80.0 |  96.63% |      8134 | 4.92M |  931 |       765 | 290.68K | 2690 |   74.0 | 5.0 |  19.7 | 133.5 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'55'' |
| Q30L60X40P000 |   40.0 |  99.09% |     26190 | 4.97M |  430 |      1019 | 244.08K | 1389 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'57'' |
| Q30L60X40P001 |   40.0 |  99.13% |     26871 | 5.02M |  386 |       855 | 218.34K | 1454 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'38'' | 0:01'00'' |
| Q30L60X40P002 |   40.0 |  99.09% |     26992 |    5M |  424 |       760 | 227.31K | 1481 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'59'' |
| Q30L60X80P000 |   80.0 |  98.71% |     16873 | 5.03M |  489 |       682 | 165.31K | 1684 |   77.0 | 4.0 |  20.0 | 133.5 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'59'' |


Table: statMRKunitigsAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  94.76% |      6404 | 4.84M | 1070 |       342 | 242.28K | 2295 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'48'' |
| MRX40P001 |   40.0 |  94.48% |      6054 | 4.79M | 1156 |       698 | 288.65K | 2435 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'47'' |
| MRX40P002 |   40.0 |  94.19% |      5965 | 4.76M | 1139 |       767 | 302.52K | 2425 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'48'' |
| MRX40P003 |   40.0 |  94.59% |      6062 | 4.79M | 1120 |       565 | 276.57K | 2368 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'50'' |
| MRX40P004 |   40.0 |  95.00% |      6539 | 4.84M | 1048 |       304 |  241.1K | 2261 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'49'' |
| MRX40P005 |   40.0 |  94.33% |      5651 | 4.78M | 1182 |       586 |  286.1K | 2486 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'48'' |
| MRX40P006 |   40.0 |  94.71% |      6086 | 4.81M | 1086 |       447 |  259.8K | 2290 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'49'' |
| MRX80P000 |   80.0 |  87.47% |      3274 | 4.36M | 1597 |       850 | 424.56K | 3370 |   71.0 | 5.0 |  18.7 | 129.0 | "31,41,51,61,71,81" | 0:01'32'' | 0:00'48'' |
| MRX80P001 |   80.0 |  86.86% |      3149 | 4.38M | 1647 |       634 | 370.27K | 3469 |   71.0 | 6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:01'34'' | 0:00'48'' |
| MRX80P002 |   80.0 |  87.53% |      3387 | 4.42M | 1593 |       618 | 347.61K | 3394 |   71.0 | 6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:01'33'' | 0:00'50'' |


Table: statMRTadpoleAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  99.16% |     67364 | 5.09M | 162 |       109 |   49.2K | 542 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'59'' |
| MRX40P001 |   40.0 |  99.21% |     63662 | 5.08M | 183 |       303 |  71.83K | 579 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:01'00'' |
| MRX40P002 |   40.0 |  99.21% |     67915 | 5.05M | 214 |       963 | 126.22K | 608 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'57'' |
| MRX40P003 |   40.0 |  99.20% |     65396 | 5.07M | 190 |       604 |  78.23K | 547 |   39.0 | 1.5 |  11.5 |  65.2 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'58'' |
| MRX40P004 |   40.0 |  99.18% |     62956 | 5.09M | 178 |       112 |  49.71K | 534 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'58'' |
| MRX40P005 |   40.0 |  99.13% |     64149 | 5.09M | 169 |       135 |   51.6K | 516 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'55'' |
| MRX40P006 |   40.0 |  99.12% |     54767 | 5.02M | 271 |       821 | 134.24K | 644 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'55'' |
| MRX80P000 |   80.0 |  98.88% |     31672 | 5.08M | 265 |        81 |   53.4K | 697 |   77.0 | 3.0 |  20.0 | 129.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'54'' |
| MRX80P001 |   80.0 |  98.91% |     37489 | 5.08M | 247 |       101 |  62.03K | 700 |   78.0 | 3.0 |  20.0 | 130.5 | "31,41,51,61,71,81" | 0:01'02'' | 0:00'57'' |
| MRX80P002 |   80.0 |  98.89% |     35066 | 5.08M | 262 |        98 |  64.19K | 713 |   77.0 | 3.0 |  20.0 | 129.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'55'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |   0.00% |    149351 | 5.13M |  72 |      1215 |   5.88M | 4743 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeKunitigsAnchors   |   0.00% |     52563 | 5.21M | 224 |      1197 |   4.81M | 3981 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRKunitigsAnchors |   0.00% |    110655 | 5.13M |  98 |      1083 |    1.1M | 1012 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRTadpoleAnchors  |   0.00% |    129892 | 5.11M |  75 |      1283 | 233.26K |  186 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeTadpoleAnchors    |   0.00% |    147125 | 5.12M |  76 |      1184 |   2.02M | 1716 |    0.0 | 0.0 |   0.0 |   0.0 |           |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|----------:|
| 8_spades     |  79.45% |    278377 |  5.1M |  117 |      1040 |  40.09K |  160 |  100.0 | 3.0 |  20.0 | 163.5 | 0:01'00'' |
| 8_spades_MR  |  77.28% |      6725 | 4.95M | 1060 |       684 | 203.56K | 2018 |   95.0 | 6.0 |  20.0 | 169.5 | 0:00'59'' |
| 8_megahit    |  79.29% |    101179 | 5.07M |  216 |       762 |  54.55K |  288 |  100.0 | 3.0 |  20.0 | 163.5 | 0:01'01'' |
| 8_megahit_MR |  79.61% |    166886 | 5.08M |  202 |       850 |  52.34K |  244 |   99.0 | 3.0 |  20.0 | 162.0 | 0:00'58'' |
| 8_platanus   |  84.51% |     61491 | 5.01M |  402 |       740 | 107.99K |  500 |   86.0 | 3.0 |  20.0 | 142.5 | 0:00'58'' |


Table: statFinal

| Name                     |     N50 |     Sum |    # |
|:-------------------------|--------:|--------:|-----:|
| Genome                   | 5067172 | 5090491 |    2 |
| Paralogs                 |    1580 |   83364 |   53 |
| 7_mergeAnchors.anchors   |  149351 | 5131460 |   72 |
| 7_mergeAnchors.others    |    1215 | 5875415 | 4743 |
| anchorLong               |  152664 | 5128688 |   66 |
| anchorFill               |  343635 | 5132688 |   35 |
| spades.contig            |  261101 | 5702235 | 1270 |
| spades.scaffold          |  365101 | 5702385 | 1264 |
| spades.non-contained     |  278521 | 5140811 |   43 |
| spades_MR.contig         |    7040 | 5697816 | 2913 |
| spades_MR.scaffold       |    7064 | 5697836 | 2911 |
| spades_MR.non-contained  |    7804 | 5153080 |  959 |
| megahit.contig           |  116933 | 5298815 |  512 |
| megahit.non-contained    |  137327 | 5121643 |   72 |
| megahit_MR.contig        |  215372 | 5155044 |   82 |
| megahit_MR.non-contained |  215372 | 5137160 |   42 |
| platanus.contig          |   25021 | 5174227 |  486 |
| platanus.scaffold        |  102410 | 5133538 |  129 |
| platanus.non-contained   |  102410 | 5121464 |   98 |


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
| ecct          | 190 | 996.04M | 5514124 |
| extended      | 228 |   1.22G | 5514124 |
| merged        | 229 |   9.52M |   44268 |
| unmerged.raw  | 228 |    1.2G | 5425588 |
| unmerged.trim | 228 |    1.2G | 5425284 |
| U1            | 229 | 517.01M | 2329618 |
| U2            | 230 | 517.68M | 2329618 |
| Us            | 221 | 163.08M |  766048 |
| pe.cor        | 228 |   1.21G | 6279868 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 177.7 |    175 |  54.1 |          1.56% |
| ihist.merge.txt  | 215.1 |    210 |  60.3 |          1.61% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q0L0   | 300.6 |  244.5 |   18.65% |     182 | "113" | 4.03M | 4.58M |     1.14 | 0:01'50'' |
| Q20L60 | 294.3 |  243.0 |   17.44% |     184 | "113" | 4.03M | 4.52M |     1.12 | 0:01'48'' |
| Q25L60 | 277.3 |  236.4 |   14.76% |     182 | "109" | 4.03M | 4.38M |     1.09 | 0:01'44'' |
| Q30L60 | 244.0 |  215.1 |   11.85% |     176 | "105" | 4.03M | 4.15M |     1.03 | 0:01'34'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  80.23% |      2631 | 2.99M | 1282 |      1037 | 446.43K | 2767 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'41'' |
| Q0L0X40P001   |   40.0 |  80.82% |      2836 | 3.06M | 1259 |      1025 | 372.06K | 2684 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'40'' |
| Q0L0X40P002   |   40.0 |  80.21% |      2721 | 3.01M | 1266 |      1034 | 411.41K | 2750 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'41'' |
| Q0L0X40P003   |   40.0 |  80.01% |      2764 | 2.98M | 1276 |      1051 | 437.24K | 2753 |   35.0 | 4.5 |   7.2 |  70.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'41'' |
| Q0L0X40P004   |   40.0 |  79.91% |      2631 | 2.98M | 1277 |      1046 |  433.7K | 2733 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'40'' |
| Q0L0X40P005   |   40.0 |  78.76% |      2620 | 2.98M | 1288 |      1034 | 394.68K | 2780 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'40'' |
| Q0L0X80P000   |   80.0 |  61.17% |      1787 | 2.24M | 1286 |      1036 | 410.68K | 2786 |   68.0 | 8.0 |  14.7 | 136.0 | "31,41,51,61,71,81" | 0:01'25'' | 0:00'38'' |
| Q0L0X80P001   |   80.0 |  60.17% |      1792 | 2.21M | 1253 |      1039 |  391.6K | 2719 |   68.0 | 8.0 |  14.7 | 136.0 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'38'' |
| Q0L0X80P002   |   80.0 |  59.31% |      1818 | 2.16M | 1247 |      1036 | 415.87K | 2716 |   68.0 | 8.0 |  14.7 | 136.0 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'37'' |
| Q20L60X40P000 |   40.0 |  81.23% |      2803 | 3.04M | 1250 |      1037 | 416.39K | 2702 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'41'' |
| Q20L60X40P001 |   40.0 |  80.65% |      2732 | 3.03M | 1255 |      1037 | 386.71K | 2698 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'41'' |
| Q20L60X40P002 |   40.0 |  81.34% |      2712 | 3.02M | 1275 |      1042 | 455.89K | 2795 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'40'' |
| Q20L60X40P003 |   40.0 |  81.63% |      2681 | 3.07M | 1311 |      1031 | 406.21K | 2808 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'39'' |
| Q20L60X40P004 |   40.0 |  80.61% |      2676 | 3.04M | 1297 |      1031 | 400.68K | 2813 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'41'' |
| Q20L60X40P005 |   40.0 |  81.45% |      2782 | 3.03M | 1248 |      1034 | 433.64K | 2700 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'41'' |
| Q20L60X80P000 |   80.0 |  63.26% |      1852 | 2.36M | 1316 |      1038 | 378.28K | 2831 |   68.0 | 8.0 |  14.7 | 136.0 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'37'' |
| Q20L60X80P001 |   80.0 |  62.96% |      1824 | 2.34M | 1330 |      1036 | 376.42K | 2856 |   68.0 | 9.0 |  13.7 | 136.0 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'38'' |
| Q20L60X80P002 |   80.0 |  62.10% |      1839 | 2.29M | 1283 |      1029 | 390.16K | 2773 |   68.5 | 8.5 |  14.3 | 137.0 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'37'' |
| Q25L60X40P000 |   40.0 |  83.70% |      3167 | 3.21M | 1228 |      1039 | 340.16K | 2629 |   36.0 | 5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'41'' |
| Q25L60X40P001 |   40.0 |  83.59% |      3054 | 3.16M | 1210 |      1047 | 380.11K | 2603 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'41'' |
| Q25L60X40P002 |   40.0 |  82.95% |      3003 | 3.13M | 1226 |      1041 | 372.37K | 2631 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'41'' |
| Q25L60X40P003 |   40.0 |  83.70% |      2913 | 3.12M | 1221 |      1052 | 423.82K | 2648 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'41'' |
| Q25L60X40P004 |   40.0 |  84.32% |      3075 | 3.18M | 1237 |      1027 | 385.85K | 2654 |   35.5 | 4.5 |   7.3 |  71.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'41'' |
| Q25L60X80P000 |   80.0 |  69.02% |      2090 |  2.6M | 1348 |      1029 | 365.32K | 2877 |   69.0 | 8.0 |  15.0 | 138.0 | "31,41,51,61,71,81" | 0:01'21'' | 0:00'38'' |
| Q25L60X80P001 |   80.0 |  67.36% |      2048 | 2.54M | 1337 |      1029 | 348.83K | 2866 |   69.0 | 9.0 |  14.0 | 138.0 | "31,41,51,61,71,81" | 0:01'21'' | 0:00'39'' |
| Q30L60X40P000 |   40.0 |  93.34% |      6983 | 3.66M |  747 |       964 |  185.2K | 1642 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'43'' |
| Q30L60X40P001 |   40.0 |  93.35% |      7296 | 3.62M |  732 |      1054 | 219.14K | 1607 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'43'' |
| Q30L60X40P002 |   40.0 |  93.35% |      7357 | 3.59M |  758 |      1030 | 249.58K | 1660 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'43'' |
| Q30L60X40P003 |   40.0 |  93.44% |      6728 |  3.6M |  771 |      1037 | 263.68K | 1672 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'44'' |
| Q30L60X40P004 |   40.0 |  93.43% |      6592 | 3.65M |  782 |       990 | 201.39K | 1710 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'43'' |
| Q30L60X80P000 |   80.0 |  89.01% |      4359 |  3.5M | 1053 |      1010 | 215.58K | 2186 |   73.0 | 9.0 |  15.3 | 146.0 | "31,41,51,61,71,81" | 0:01'25'' | 0:00'42'' |
| Q30L60X80P001 |   80.0 |  88.58% |      4126 | 3.45M | 1057 |      1014 | 237.43K | 2189 |   73.0 | 8.0 |  16.3 | 145.5 | "31,41,51,61,71,81" | 0:01'25'' | 0:00'43'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  95.97% |     19591 | 3.75M | 398 |      1025 | 170.99K | 1006 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'46'' |
| Q0L0X40P001   |   40.0 |  95.77% |     17256 | 3.73M | 424 |       928 | 166.01K | 1049 |   36.0 |  4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'45'' |
| Q0L0X40P002   |   40.0 |  95.99% |     19189 | 3.77M | 385 |       945 | 164.97K | 1060 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'48'' |
| Q0L0X40P003   |   40.0 |  95.87% |     17130 | 3.74M | 397 |      1160 | 191.71K | 1039 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'46'' |
| Q0L0X40P004   |   40.0 |  95.99% |     18044 | 3.74M | 395 |      1102 | 191.12K | 1049 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'47'' |
| Q0L0X40P005   |   40.0 |  95.81% |     15330 | 3.73M | 432 |      1078 | 188.93K | 1119 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'47'' |
| Q0L0X80P000   |   80.0 |  94.35% |      8733 | 3.72M | 641 |      1031 | 206.95K | 1721 |   74.0 |  9.0 |  15.7 | 148.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'49'' |
| Q0L0X80P001   |   80.0 |  94.39% |      8486 | 3.74M | 661 |       813 | 172.77K | 1699 |   74.0 |  9.0 |  15.7 | 148.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'49'' |
| Q0L0X80P002   |   80.0 |  94.48% |      7929 | 3.74M | 699 |      1022 | 209.95K | 1835 |   74.0 | 10.0 |  14.7 | 148.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'47'' |
| Q20L60X40P000 |   40.0 |  95.98% |     17325 | 3.77M | 389 |      1133 | 166.11K | 1027 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'47'' |
| Q20L60X40P001 |   40.0 |  96.07% |     18384 | 3.73M | 389 |      1052 | 174.11K |  982 |   37.0 |  4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'46'' |
| Q20L60X40P002 |   40.0 |  95.96% |     17945 | 3.74M | 410 |      1046 | 161.44K | 1054 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'47'' |
| Q20L60X40P003 |   40.0 |  95.80% |     17154 | 3.75M | 414 |      1021 | 153.55K | 1070 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'45'' |
| Q20L60X40P004 |   40.0 |  96.05% |     16030 | 3.76M | 430 |      1010 | 169.72K | 1100 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'46'' |
| Q20L60X40P005 |   40.0 |  96.01% |     16954 | 3.76M | 390 |       983 | 161.41K | 1034 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'46'' |
| Q20L60X80P000 |   80.0 |  94.39% |      8715 | 3.75M | 652 |       632 | 159.67K | 1733 |   74.0 | 10.0 |  14.7 | 148.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'48'' |
| Q20L60X80P001 |   80.0 |  94.54% |      8685 | 3.74M | 653 |      1001 | 180.98K | 1749 |   75.0 | 10.0 |  15.0 | 150.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'48'' |
| Q20L60X80P002 |   80.0 |  94.53% |      8433 | 3.73M | 691 |       813 | 182.88K | 1748 |   74.0 |  9.0 |  15.7 | 148.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'48'' |
| Q25L60X40P000 |   40.0 |  96.33% |     19712 | 3.77M | 378 |      1049 | 158.83K | 1031 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'46'' |
| Q25L60X40P001 |   40.0 |  96.26% |     18757 | 3.78M | 374 |      1113 | 155.49K | 1002 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'45'' |
| Q25L60X40P002 |   40.0 |  96.11% |     16865 | 3.76M | 383 |       863 | 136.66K | 1026 |   37.0 |  4.5 |   7.8 |  74.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'47'' |
| Q25L60X40P003 |   40.0 |  96.05% |     17443 | 3.75M | 404 |      1072 | 166.37K | 1056 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'45'' |
| Q25L60X40P004 |   40.0 |  96.38% |     18041 | 3.76M | 387 |      1009 | 166.42K | 1047 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'46'' |
| Q25L60X80P000 |   80.0 |  94.81% |      8499 | 3.74M | 645 |       858 | 171.06K | 1645 |   75.0 |  9.0 |  16.0 | 150.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'47'' |
| Q25L60X80P001 |   80.0 |  94.61% |      8841 | 3.74M | 648 |       872 | 167.67K | 1701 |   74.0 | 10.0 |  14.7 | 148.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'47'' |
| Q30L60X40P000 |   40.0 |  97.06% |     25858 | 3.76M | 313 |      1025 | 149.48K |  908 |   36.0 |  4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'48'' |
| Q30L60X40P001 |   40.0 |  97.12% |     25924 | 3.77M | 291 |      1100 | 138.55K |  806 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'47'' |
| Q30L60X40P002 |   40.0 |  96.99% |     26859 | 3.78M | 278 |      1052 | 142.16K |  839 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'46'' |
| Q30L60X40P003 |   40.0 |  97.19% |     29742 | 3.76M | 286 |      1044 | 155.81K |  874 |   36.0 |  4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'50'' |
| Q30L60X40P004 |   40.0 |  97.11% |     24627 | 3.75M | 317 |      1119 | 166.97K |  904 |   36.0 |  4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'47'' |
| Q30L60X80P000 |   80.0 |  96.54% |     17494 |  3.8M | 362 |      1031 | 116.51K | 1012 |   76.0 | 10.0 |  15.3 | 152.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'48'' |
| Q30L60X80P001 |   80.0 |  96.52% |     16221 |  3.8M | 394 |      1109 | 140.54K | 1069 |   75.0 |  9.0 |  16.0 | 150.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'49'' |


Table: statMRKunitigsAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  95.59% |     15304 | 3.72M | 430 |      1027 | 158.89K |  938 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'44'' |
| MRX40P001 |   40.0 |  95.48% |     16622 | 3.72M | 394 |      1091 | 163.73K |  844 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'45'' |
| MRX40P002 |   40.0 |  95.69% |     15341 | 3.75M | 407 |      1037 | 135.33K |  860 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'43'' |
| MRX40P003 |   40.0 |  95.75% |     14671 | 3.74M | 409 |      1027 | 139.52K |  879 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'44'' |
| MRX40P004 |   40.0 |  95.55% |     16723 | 3.75M | 394 |       996 | 116.02K |  867 |   38.0 |  5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'45'' |
| MRX40P005 |   40.0 |  96.00% |     16328 | 3.74M | 413 |      1036 | 144.99K |  909 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'44'' |
| MRX40P006 |   40.0 |  95.72% |     17155 | 3.74M | 417 |      1026 | 143.67K |  900 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'44'' |
| MRX80P000 |   80.0 |  93.77% |      9401 |  3.7M | 596 |      1027 | 152.81K | 1230 |   76.0 |  9.0 |  16.3 | 152.0 | "31,41,51,61,71,81" | 0:01'17'' | 0:00'43'' |
| MRX80P001 |   80.0 |  94.08% |      9289 | 3.73M | 586 |       884 | 120.91K | 1207 |   75.0 | 10.0 |  15.0 | 150.0 | "31,41,51,61,71,81" | 0:01'17'' | 0:00'44'' |
| MRX80P002 |   80.0 |  94.23% |     10382 | 3.72M | 557 |       948 | 137.52K | 1174 |   76.0 |  9.0 |  16.3 | 152.0 | "31,41,51,61,71,81" | 0:01'17'' | 0:00'45'' |


Table: statMRTadpoleAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  97.42% |     50382 | 3.75M | 248 |      1182 | 173.86K | 614 |   35.0 |  5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'49'' |
| MRX40P001 |   40.0 |  97.41% |     61055 | 3.81M | 184 |      1009 |  93.32K | 492 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'47'' |
| MRX40P002 |   40.0 |  97.53% |     61820 | 3.82M | 194 |      1010 |  90.51K | 504 |   36.0 |  6.0 |   6.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'48'' |
| MRX40P003 |   40.0 |  97.48% |     60571 | 3.82M | 187 |      1052 |  97.02K | 480 |   36.0 |  6.0 |   6.0 |  72.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'47'' |
| MRX40P004 |   40.0 |  97.32% |     44953 |  3.8M | 196 |      1098 |  80.17K | 452 |   36.0 |  6.0 |   6.0 |  72.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'46'' |
| MRX40P005 |   40.0 |  97.51% |     47018 | 3.75M | 257 |      1050 | 173.32K | 612 |   35.0 |  5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'49'' |
| MRX40P006 |   40.0 |  97.48% |     51115 | 3.79M | 208 |      1065 |  123.5K | 540 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'48'' |
| MRX80P000 |   80.0 |  97.19% |     40720 | 3.83M | 166 |      1302 |  79.26K | 427 |   75.0 | 10.0 |  15.0 | 150.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'46'' |
| MRX80P001 |   80.0 |  97.24% |     49491 | 3.83M | 166 |      1177 |  84.33K | 441 |   75.5 | 10.5 |  14.7 | 151.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'46'' |
| MRX80P002 |   80.0 |  97.08% |     41223 | 3.84M | 182 |      1102 |  58.17K | 423 |   75.0 | 11.0 |  14.0 | 150.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'45'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |   0.00% |    130212 | 3.89M |  94 |      1301 |   3.23M | 2419 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeKunitigsAnchors   |   0.00% |     70792 |  3.9M | 164 |      1242 |   2.86M | 2240 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRKunitigsAnchors |   0.00% |     98365 | 3.86M | 121 |      1412 | 422.21K |  312 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRTadpoleAnchors  |   0.00% |    121209 | 3.89M | 106 |      1418 | 339.35K |  255 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeTadpoleAnchors    |   0.00% |    109839 | 3.88M | 100 |      1536 |   1.07M |  758 |    0.0 | 0.0 |   0.0 |   0.0 |           |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median |  MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|-----:|------:|------:|----------:|
| 8_spades     |  80.87% |    246348 |  3.9M |  50 |      1211 | 150.46K | 209 |  108.5 | 26.5 |   9.7 | 217.0 | 0:00'54'' |
| 8_spades_MR  |  80.44% |     32652 | 3.87M | 251 |      1061 |  63.44K | 486 |  112.0 | 15.0 |  20.0 | 224.0 | 0:00'54'' |
| 8_megahit    |  79.81% |     70731 | 3.83M | 113 |      1187 |  78.05K | 252 |  111.5 | 16.5 |  20.0 | 223.0 | 0:00'53'' |
| 8_megahit_MR |  81.21% |    166857 |  3.9M | 102 |      1273 |  45.08K | 178 |  102.5 | 19.0 |  15.2 | 205.0 | 0:00'53'' |
| 8_platanus   |  84.16% |    113741 | 3.87M | 136 |      1072 |  52.41K | 237 |   97.0 | 17.0 |  15.3 | 194.0 | 0:00'53'' |


Table: statFinal

| Name                     |     N50 |     Sum |    # |
|:-------------------------|--------:|--------:|-----:|
| Genome                   | 2961149 | 4033464 |    2 |
| Paralogs                 |    3483 |  114707 |   48 |
| 7_mergeAnchors.anchors   |  130212 | 3887972 |   94 |
| 7_mergeAnchors.others    |    1301 | 3227855 | 2419 |
| anchorLong               |  171231 | 3882952 |   77 |
| anchorFill               |  246218 | 3892851 |   45 |
| spades.contig            |  176446 | 5097383 | 2327 |
| spades.scaffold          |  199415 | 5097593 | 2324 |
| spades.non-contained     |  199415 | 4049347 |  159 |
| spades_MR.contig         |   32731 | 4113986 |  974 |
| spades_MR.scaffold       |   32731 | 4114386 |  970 |
| spades_MR.non-contained  |   35606 | 3930075 |  235 |
| megahit.contig           |   62704 | 4405144 | 1202 |
| megahit.non-contained    |   71383 | 3910363 |  139 |
| megahit_MR.contig        |  168671 | 4003973 |  214 |
| megahit_MR.non-contained |  168671 | 3945239 |   76 |
| platanus.contig          |   76027 | 3997650 |  328 |
| platanus.scaffold        |  112733 | 3949528 |  194 |
| platanus.non-contained   |  112733 | 3921056 |  101 |

