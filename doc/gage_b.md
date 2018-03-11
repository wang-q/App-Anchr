# Assemble four genomes from GAGE-B data sets by ANCHR

[TOC levels=1-3]: # " "
- [Assemble four genomes from GAGE-B data sets by ANCHR](#assemble-four-genomes-from-gage-b-data-sets-by-anchr)
- [*Bacillus cereus* ATCC 10987](#bacillus-cereus-atcc-10987)
    - [Bcer: download](#bcer-download)
    - [Bcer: template](#bcer-template)
    - [Bcer: run](#bcer-run)
- [*Mycobacterium abscessus* 6G-0125-R](#mycobacterium-abscessus-6g-0125-r)
    - [Mabs: download](#mabs-download)
    - [Mabs: template](#mabs-template)
    - [Mabs: run](#mabs-run)
- [*Rhodobacter sphaeroides* 2.4.1](#rhodobacter-sphaeroides-241)
    - [Rsph: download](#rsph-download)
    - [Rsph: template](#rsph-template)
    - [Rsph: run](#rsph-run)
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
for D in Bcer Mabs Rsph Vcho VchoH MabsF RsphF VchoF; do
#for D in VchoF; do
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

rm -f *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 5432652 \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --sgastats \
    --trim2 "--dedupe --tile" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,2,3" \
    --cov2 "40 50 60 all" \
    --tadpole \
    --redoanchors \
    --fillanchor \
    --parallel 24 \
    --xmx 110g

```

## Bcer: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Bcer

cd ${WORKING_DIR}/${BASE_NAME}
#rm -fr 4_*/ 6_*/ 7_*/ 8_*/ 2_illumina/trim 2_illumina/mergereads statReads.md 

bash 0_bsub.sh
#bkill -J "${BASE_NAME}-*"

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

| Group             |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:------------------|------:|-------:|------:|-------------------------------:|
| R.genome.bbtools  | 578.3 |    578 | 706.0 |                         49.48% |
| R.tadpole.bbtools | 557.2 |    570 | 165.2 |                         44.74% |
| R.genome.picard   | 582.1 |    585 | 146.5 |                             FR |
| R.tadpole.picard  | 573.7 |    577 | 147.3 |                             FR |


Table: statSgaStats

| Library | incorrectBases | perfectReads | overlapDepth |
|:--------|---------------:|-------------:|-------------:|
| R       |          0.31% |       76.36% |        96.77 |


Table: statReads

| Name       |     N50 |     Sum |       # |
|:-----------|--------:|--------:|--------:|
| Genome     | 5224283 | 5432652 |       2 |
| Paralogs   |    2295 |  223889 |     103 |
| Illumina.R |     251 | 481.02M | 2080000 |
| trim.R     |     250 |  404.2M | 1808256 |
| Q20L60     |     250 | 396.45M | 1757723 |
| Q25L60     |     250 | 379.19M | 1704883 |
| Q30L60     |     250 |  343.9M | 1609792 |


Table: statTrimReads

| Name           | N50 |     Sum |       # |
|:---------------|----:|--------:|--------:|
| clumpify       | 251 | 480.99M | 2079856 |
| filteredbytile | 251 | 462.85M | 2003004 |
| trim           | 250 | 404.24M | 1808444 |
| filter         | 250 |  404.2M | 1808256 |
| R1             | 250 | 209.18M |  904128 |
| R2             | 247 | 195.02M |  904128 |
| Rs             |   0 |       0 |       0 |


```text
#R.trim
#Matched	5509	0.27504%
#Name	Reads	ReadsPct
Reverse_adapter	4572	0.22826%
```

```text
#R.filter
#Matched	97	0.00536%
#Name	Reads	ReadsPct
```

```text
#R.peaks
#k	31
#unique_kmers	14116751
#main_peak	64
#genome_size	5317664
#haploid_genome_size	5317664
#fold_coverage	64
#haploid_fold_coverage	64
#ploidy	1
#percent_repeat	1.778
#start	center	stop	max	volume
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 250 |  404.2M | 1808254 |
| ecco          | 250 |  404.2M | 1808254 |
| eccc          | 250 |  404.2M | 1808254 |
| ecct          | 250 | 400.11M | 1786440 |
| extended      | 290 | 470.66M | 1786440 |
| merged.raw    | 586 | 316.29M |  583667 |
| unmerged.raw  | 285 | 149.69M |  619106 |
| unmerged.trim | 285 | 149.68M |  619082 |
| M1            | 586 | 316.26M |  583608 |
| U1            | 290 |  79.93M |  309541 |
| U2            | 270 |  69.76M |  309541 |
| Us            |   0 |       0 |       0 |
| M.cor         | 518 | 466.53M | 1786298 |

| Group              |  Mean | Median | STDev | PercentOfPairs |
|:-------------------|------:|-------:|------:|---------------:|
| M.ihist.merge1.txt | 361.9 |    388 |  97.6 |         19.49% |
| M.ihist.merge.txt  | 541.9 |    564 | 120.1 |         65.34% |


Table: statQuorum

| Name     | CovIn | CovOut | Discard% |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:---------|------:|-------:|---------:|------:|------:|------:|---------:|----------:|
| Q0L0.R   |  74.4 |   64.7 |   13.06% | "127" | 5.43M | 5.35M |     0.98 | 0:00'42'' |
| Q20L60.R |  73.0 |   64.6 |   11.51% | "127" | 5.43M | 5.35M |     0.98 | 0:00'41'' |
| Q25L60.R |  69.8 |   63.7 |    8.73% | "127" | 5.43M | 5.34M |     0.98 | 0:00'41'' |
| Q30L60.R |  63.3 |   59.7 |    5.76% | "127" | 5.43M | 5.34M |     0.98 | 0:00'39'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|-------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  97.43% |     21194 | 5.26M | 412 |       252 |  96.5K | 1077 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:01'08'' | 0:01'00'' |
| Q0L0X50P000    |   50.0 |  97.46% |     22530 | 5.28M | 375 |       102 | 71.91K | 1048 |   49.0 | 6.0 |  10.3 |  98.0 | "31,41,51,61,71,81" | 0:01'19'' | 0:01'02'' |
| Q0L0X60P000    |   60.0 |  97.43% |     22656 | 5.28M | 367 |        91 | 67.41K | 1034 |   59.0 | 7.0 |  12.7 | 118.0 | "31,41,51,61,71,81" | 0:01'30'' | 0:01'00'' |
| Q0L0XallP000   |   64.7 |  97.39% |     22623 | 5.28M | 372 |        92 | 69.91K | 1033 |   64.0 | 7.0 |  14.3 | 127.5 | "31,41,51,61,71,81" | 0:01'36'' | 0:01'02'' |
| Q20L60X40P000  |   40.0 |  97.55% |     27100 | 5.28M | 327 |       119 | 63.11K |  929 |   39.0 | 5.0 |   8.0 |  78.0 | "31,41,51,61,71,81" | 0:01'08'' | 0:01'00'' |
| Q20L60X50P000  |   50.0 |  97.56% |     25857 | 5.28M | 333 |       105 | 66.11K |  961 |   49.0 | 6.0 |  10.3 |  98.0 | "31,41,51,61,71,81" | 0:01'19'' | 0:01'01'' |
| Q20L60X60P000  |   60.0 |  97.56% |     25864 | 5.29M | 320 |        88 | 59.87K |  948 |   59.0 | 7.0 |  12.7 | 118.0 | "31,41,51,61,71,81" | 0:01'31'' | 0:01'02'' |
| Q20L60XallP000 |   64.6 |  97.51% |     25864 | 5.28M | 325 |       102 | 65.64K |  942 |   64.0 | 7.0 |  14.3 | 127.5 | "31,41,51,61,71,81" | 0:01'35'' | 0:01'03'' |
| Q25L60X40P000  |   40.0 |  97.96% |     31137 | 5.29M | 297 |       185 | 68.35K |  918 |   39.0 | 5.0 |   8.0 |  78.0 | "31,41,51,61,71,81" | 0:01'09'' | 0:01'03'' |
| Q25L60X50P000  |   50.0 |  97.96% |     31133 | 5.29M | 286 |       120 | 68.46K |  921 |   49.0 | 6.0 |  10.3 |  98.0 | "31,41,51,61,71,81" | 0:01'20'' | 0:01'02'' |
| Q25L60X60P000  |   60.0 |  97.99% |     32325 | 5.29M | 273 |        96 |  58.7K |  901 |   59.0 | 7.0 |  12.7 | 118.0 | "31,41,51,61,71,81" | 0:01'31'' | 0:01'04'' |
| Q25L60XallP000 |   63.7 |  97.98% |     33472 | 5.29M | 271 |        96 | 58.59K |  891 |   63.0 | 7.0 |  14.0 | 126.0 | "31,41,51,61,71,81" | 0:01'35'' | 0:01'05'' |
| Q30L60X40P000  |   40.0 |  98.26% |     34545 | 5.29M | 278 |       172 | 60.64K |  870 |   39.0 | 5.0 |   8.0 |  78.0 | "31,41,51,61,71,81" | 0:01'08'' | 0:01'01'' |
| Q30L60X50P000  |   50.0 |  98.34% |     35049 | 5.29M | 261 |       128 | 62.62K |  875 |   49.0 | 6.0 |  10.3 |  98.0 | "31,41,51,61,71,81" | 0:01'18'' | 0:01'04'' |
| Q30L60XallP000 |   59.7 |  98.36% |     39148 |  5.3M | 248 |        98 | 55.78K |  863 |   59.0 | 7.0 |  12.7 | 118.0 | "31,41,51,61,71,81" | 0:01'29'' | 0:01'05'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  98.34% |     28507 | 5.28M | 322 |       143 | 67.08K | 936 |   39.0 | 5.0 |   8.0 |  78.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:01'01'' |
| Q0L0X50P000    |   50.0 |  98.23% |     27033 | 5.29M | 323 |        94 | 62.61K | 949 |   49.0 | 6.0 |  10.3 |  98.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:01'01'' |
| Q0L0X60P000    |   60.0 |  98.19% |     28455 | 5.29M | 328 |        98 | 66.37K | 960 |   59.0 | 7.0 |  12.7 | 118.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:01'01'' |
| Q0L0XallP000   |   64.7 |  98.17% |     28631 | 5.29M | 329 |        96 |  65.1K | 953 |   64.0 | 7.0 |  14.3 | 127.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:01'01'' |
| Q20L60X40P000  |   40.0 |  98.32% |     31106 | 5.27M | 326 |       430 | 83.57K | 910 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'57'' |
| Q20L60X50P000  |   50.0 |  98.27% |     29451 | 5.31M | 307 |       113 | 63.77K | 894 |   49.0 | 5.5 |  10.8 |  98.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:01'00'' |
| Q20L60X60P000  |   60.0 |  98.26% |     29301 | 5.29M | 306 |        89 | 58.87K | 909 |   59.0 | 7.0 |  12.7 | 118.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:01'00'' |
| Q20L60XallP000 |   64.6 |  98.23% |     31103 | 5.29M | 307 |       101 | 61.62K | 911 |   64.0 | 8.0 |  13.3 | 128.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:01'02'' |
| Q25L60X40P000  |   40.0 |  98.46% |     32214 | 5.29M | 297 |       233 | 66.86K | 890 |   39.0 | 5.0 |   8.0 |  78.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:01'00'' |
| Q25L60X50P000  |   50.0 |  98.47% |     32780 | 5.29M | 284 |       118 | 64.88K | 892 |   49.0 | 6.0 |  10.3 |  98.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:01'02'' |
| Q25L60X60P000  |   60.0 |  98.50% |     33155 | 5.29M | 277 |        92 |  56.2K | 881 |   59.0 | 7.0 |  12.7 | 118.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:01'02'' |
| Q25L60XallP000 |   63.7 |  98.51% |     35052 |  5.3M | 268 |        97 |  56.2K | 867 |   63.0 | 8.0 |  13.0 | 126.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:01'03'' |
| Q30L60X40P000  |   40.0 |  98.63% |     30252 | 5.28M | 322 |       172 | 77.89K | 960 |   40.0 | 4.0 |   9.3 |  78.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:01'00'' |
| Q30L60X50P000  |   50.0 |  98.62% |     32572 | 5.29M | 274 |        96 | 55.78K | 865 |   50.0 | 6.0 |  10.7 | 100.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:01'03'' |
| Q30L60XallP000 |   59.7 |  98.59% |     34516 | 5.29M | 263 |        96 |  55.2K | 849 |   59.0 | 7.0 |  12.7 | 118.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:01'01'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  97.40% |     41640 | 5.29M | 246 |       152 | 40.48K | 527 |   39.0 |  5.0 |   8.0 |  78.0 | "31,41,51,61,71,81" | 0:01'15'' | 0:00'55'' |
| MRX40P001  |   40.0 |  97.81% |     36331 |  5.3M | 250 |       128 | 37.45K | 535 |   39.0 |  5.0 |   8.0 |  78.0 | "31,41,51,61,71,81" | 0:01'15'' | 0:00'55'' |
| MRX50P000  |   50.0 |  97.42% |     40265 | 5.29M | 245 |       120 | 37.89K | 538 |   49.0 |  6.0 |  10.3 |  98.0 | "31,41,51,61,71,81" | 0:01'28'' | 0:00'55'' |
| MRX60P000  |   60.0 |  97.43% |     37776 |  5.3M | 244 |       103 | 34.14K | 539 |   59.0 |  7.0 |  12.7 | 118.0 | "31,41,51,61,71,81" | 0:01'40'' | 0:00'56'' |
| MRXallP000 |   85.9 |  97.37% |     34152 |  5.3M | 248 |        97 | 32.47K | 549 |   84.0 | 11.0 |  17.0 | 168.0 | "31,41,51,61,71,81" | 0:02'12'' | 0:00'56'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |  Sum |   # | N50Others |    Sum |   # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-----:|----:|----------:|-------:|----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  97.67% |     42725 | 5.3M | 228 |      1034 | 38.14K | 445 |   39.0 |  5.0 |   8.0 |  78.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'52'' |
| MRX40P001  |   40.0 |  97.70% |     42070 | 5.3M | 228 |       233 | 33.16K | 439 |   39.0 |  5.0 |   8.0 |  78.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'52'' |
| MRX50P000  |   50.0 |  97.66% |     44341 | 5.3M | 226 |       219 | 35.69K | 450 |   49.0 |  6.0 |  10.3 |  98.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'52'' |
| MRX60P000  |   60.0 |  97.64% |     42660 | 5.3M | 225 |       133 | 31.37K | 456 |   59.0 |  7.0 |  12.7 | 118.0 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'54'' |
| MRXallP000 |   85.9 |  97.62% |     42660 | 5.3M | 229 |       123 | 31.99K | 481 |   84.0 | 10.5 |  17.5 | 168.0 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'55'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |  # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|------:|----:|----------:|-------:|---:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |  97.49% |     52674 | 5.31M | 190 |      1051 | 51.53K | 52 |   64.0 | 8.0 |  13.3 | 128.0 | 0:01'00'' |
| 7_mergeKunitigsAnchors   |  97.92% |     44276 |  5.3M | 226 |      1056 | 35.72K | 36 |   64.0 | 8.0 |  13.3 | 128.0 | 0:01'06'' |
| 7_mergeMRKunitigsAnchors |  97.73% |     41620 | 5.29M | 232 |      1222 | 21.67K | 18 |   64.0 | 8.0 |  13.3 | 128.0 | 0:01'02'' |
| 7_mergeMRTadpoleAnchors  |  97.76% |     45080 | 5.29M | 214 |      1166 | 21.27K | 18 |   64.0 | 8.0 |  13.3 | 128.0 | 0:01'03'' |
| 7_mergeTadpoleAnchors    |  97.94% |     42685 | 5.31M | 238 |      1040 | 42.28K | 43 |   64.0 | 8.0 |  13.3 | 128.0 | 0:01'07'' |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median |  MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|-----:|------:|------:|----------:|
| 8_spades     |  98.97% |    180265 | 5.33M |  63 |      1447 | 21.55K | 118 |   64.0 | 10.0 |  11.3 | 128.0 | 0:00'53'' |
| 8_spades_MR  |  98.79% |     89348 | 5.35M | 108 |      1606 | 14.78K | 205 |   84.0 | 12.0 |  16.0 | 168.0 | 0:00'54'' |
| 8_megahit    |  98.34% |     51377 |  5.3M | 197 |       252 | 36.69K | 380 |   64.0 |  8.0 |  13.3 | 128.0 | 0:00'53'' |
| 8_megahit_MR |  98.76% |     60018 | 5.35M | 171 |       904 | 19.98K | 332 |   84.0 | 11.0 |  17.0 | 168.0 | 0:01'07'' |
| 8_platanus   |  97.36% |     72541 | 5.32M | 126 |       196 | 26.34K | 166 |   64.0 |  8.5 |  12.8 | 128.0 | 0:00'53'' |


Table: statFinal

| Name                     |     N50 |     Sum |   # |
|:-------------------------|--------:|--------:|----:|
| Genome                   | 5224283 | 5432652 |   2 |
| Paralogs                 |    2295 |  223889 | 103 |
| 7_mergeAnchors.anchors   |   52674 | 5308534 | 190 |
| 7_mergeAnchors.others    |    1051 |   51528 |  52 |
| anchorLong               |   52674 | 5308534 | 190 |
| anchorFill               |  114810 | 5403298 |  78 |
| spades.contig            |  208869 | 5367456 | 151 |
| spades.scaffold          |  285416 | 5367643 | 139 |
| spades.non-contained     |  208869 | 5350211 |  55 |
| spades_MR.contig         |   95659 | 5368317 | 127 |
| spades_MR.scaffold       |  284286 | 5375236 |  64 |
| spades_MR.non-contained  |   95659 | 5362070 | 105 |
| megahit.contig           |   56494 | 5364200 | 262 |
| megahit.non-contained    |   56494 | 5333620 | 183 |
| megahit_MR.contig        |   60113 | 5419022 | 302 |
| megahit_MR.non-contained |   60113 | 5367986 | 171 |
| platanus.contig          |   18988 | 5421291 | 668 |
| platanus.scaffold        |  269289 | 5398510 | 269 |
| platanus.non-contained   |  269289 | 5345622 |  40 |


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

rm -f *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 5090491 \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --trim2 "--dedupe --tile" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,2,3" \
    --cov2 "40 all" \
    --tadpole \
    --fillanchor \
    --parallel 24 \
    --xmx 110g

```

## Mabs: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Mabs

cd ${WORKING_DIR}/${BASE_NAME}
#rm -fr 4_*/ 6_*/ 7_*/ 8_*/ 2_illumina/trim 2_illumina/mergereads statReads.md 

bash 0_bsub.sh
#bkill -J "${BASE_NAME}-*"

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

| Group             |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:------------------|------:|-------:|-------:|-------------------------------:|
| R.genome.bbtools  | 458.7 |    277 | 2524.0 |                          7.42% |
| R.tadpole.bbtools | 266.8 |    266 |   50.8 |                         35.21% |
| R.genome.picard   | 295.7 |    279 |   47.4 |                             FR |
| R.genome.picard   | 287.1 |    271 |   33.8 |                             RF |
| R.tadpole.picard  | 268.0 |    267 |   49.1 |                             FR |
| R.tadpole.picard  | 251.5 |    255 |   48.0 |                             RF |


Table: statReads

| Name       |     N50 |     Sum |       # |
|:-----------|--------:|--------:|--------:|
| Genome     | 5067172 | 5090491 |       2 |
| Paralogs   |    1580 |   83364 |      53 |
| Illumina.R |     251 |    512M | 2039840 |
| trim.R     |     176 | 283.22M | 1727224 |
| Q20L60     |     177 | 274.08M | 1656891 |
| Q25L60     |     174 | 249.79M | 1557368 |
| Q30L60     |     165 | 205.62M | 1378900 |


Table: statTrimReads

| Name           | N50 |     Sum |       # |
|:---------------|----:|--------:|--------:|
| clumpify       | 251 | 511.87M | 2039328 |
| filteredbytile | 251 | 488.06M | 1944454 |
| trim           | 177 |  284.2M | 1731850 |
| filter         | 176 | 283.22M | 1727224 |
| R1             | 186 |  151.3M |  863612 |
| R2             | 167 | 131.92M |  863612 |
| Rs             |   0 |       0 |       0 |


```text
#R.trim
#Matched	1422314	73.14722%
#Name	Reads	ReadsPct
Reverse_adapter	737308	37.91851%
pcr_dimer	394735	20.30056%
TruSeq_Universal_Adapter	117437	6.03959%
PCR_Primers	100119	5.14895%
TruSeq_Adapter_Index_1_6	46917	2.41286%
Nextera_LMP_Read2_External_Adapter	14269	0.73383%
TruSeq_Adapter_Index_11	6046	0.31094%
```

```text
#R.filter
#Matched	4625	0.26706%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	4625	0.26706%
```

```text
#R.peaks
#k	31
#unique_kmers	13548933
#main_peak	41
#genome_size	50186915
#haploid_genome_size	5018691
#fold_coverage	4
#haploid_fold_coverage	41
#ploidy	10
#het_rate	0.00075
#percent_repeat	0.044
#start	center	stop	max	volume
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 177 | 281.57M | 1716302 |
| ecco          | 177 | 281.51M | 1716302 |
| eccc          | 177 | 281.51M | 1716302 |
| ecct          | 176 | 271.71M | 1660356 |
| extended      | 214 | 337.72M | 1660356 |
| merged.raw    | 235 | 190.83M |  820837 |
| unmerged.raw  | 207 |   3.39M |   18682 |
| unmerged.trim | 207 |   3.39M |   18674 |
| M1            | 235 | 182.51M |  785185 |
| U1            | 228 |   1.93M |    9337 |
| U2            | 185 |   1.46M |    9337 |
| Us            |   0 |       0 |       0 |
| M.cor         | 234 | 186.68M | 1589044 |

| Group              |  Mean | Median | STDev | PercentOfPairs |
|:-------------------|------:|-------:|------:|---------------:|
| M.ihist.merge1.txt | 190.3 |    186 |  46.7 |         92.48% |
| M.ihist.merge.txt  | 232.5 |    226 |  51.6 |         98.88% |


Table: statQuorum

| Name     | CovIn | CovOut | Discard% | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:---------|------:|-------:|---------:|-----:|------:|------:|---------:|----------:|
| Q0L0.R   |  55.6 |   44.7 |   19.59% | "45" | 5.09M | 5.22M |     1.03 | 0:00'32'' |
| Q20L60.R |  53.9 |   44.1 |   18.13% | "45" | 5.09M | 5.21M |     1.02 | 0:00'31'' |
| Q25L60.R |  49.1 |   41.7 |   15.07% | "45" | 5.09M |  5.2M |     1.02 | 0:00'30'' |
| Q30L60.R |  40.4 |   35.6 |   11.89% | "39" | 5.09M | 5.18M |     1.02 | 0:00'26'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  96.11% |      4518 | 4.59M | 1299 |       900 | 599.77K | 2666 |   38.0 | 3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'54'' |
| Q0L0XallP000   |   44.7 |  95.69% |      4198 |  4.5M | 1365 |       938 | 657.24K | 2736 |   42.0 | 3.0 |  11.0 |  76.5 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'53'' |
| Q20L60X40P000  |   40.0 |  96.37% |      4763 | 4.58M | 1258 |       904 | 596.98K | 2564 |   38.0 | 3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'53'' |
| Q20L60XallP000 |   44.1 |  96.06% |      4468 | 4.56M | 1313 |       921 | 606.48K | 2635 |   42.0 | 3.0 |  11.0 |  76.5 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'55'' |
| Q25L60X40P000  |   40.0 |  97.40% |      3152 | 4.27M | 1563 |      1056 |   1.06M | 2981 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'55'' |
| Q25L60XallP000 |   41.7 |  97.29% |      5026 | 4.62M | 1236 |       910 | 620.48K | 2565 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'56'' |
| Q30L60XallP000 |   35.6 |  98.58% |      3343 | 4.35M | 1521 |      1069 |   1.13M | 3127 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'58'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  98.56% |      3722 | 4.48M | 1456 |      1009 | 990.55K | 3019 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:01'01'' |
| Q0L0XallP000   |   44.7 |  98.19% |      3523 | 4.39M | 1485 |      1038 |   1.05M | 2929 |   43.0 | 2.0 |  12.3 |  73.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'58'' |
| Q20L60X40P000  |   40.0 |  98.47% |      3778 | 4.46M | 1431 |      1003 | 982.34K | 2916 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:01'01'' |
| Q20L60XallP000 |   44.1 |  98.25% |      3779 | 4.44M | 1436 |      1025 | 981.07K | 2890 |   42.0 | 2.0 |  12.0 |  72.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'58'' |
| Q25L60X40P000  |   40.0 |  98.77% |      3586 | 4.42M | 1472 |      1068 |    1.1M | 3104 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:01'01'' |
| Q25L60XallP000 |   41.7 |  98.67% |      3603 | 4.41M | 1456 |      1054 |   1.09M | 3047 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:01'00'' |
| Q30L60XallP000 |   35.6 |  99.10% |      3578 | 4.43M | 1464 |      1112 |    1.2M | 3389 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:01'01'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   36.7 |  98.92% |     24365 | 5.04M | 406 |       224 | 103.24K | 741 |   36.0 | 1.5 |  10.5 |  60.8 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'54'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor | Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|----:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   36.7 |  99.22% |     21732 |  5M | 454 |       644 | 134.91K | 679 |   36.0 | 1.0 |  11.0 |  58.5 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'52'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |   # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|------:|-----:|----------:|--------:|----:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |   0.00% |     38392 | 5.09M |  273 |      1810 | 466.18K | 304 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeKunitigsAnchors   |   0.00% |      7766 | 4.93M |  983 |      1398 | 920.68K | 716 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRKunitigsAnchors |   0.00% |     24365 | 5.04M |  406 |      1412 |   41.8K |  35 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRTadpoleAnchors  |   0.00% |     21732 |    5M |  454 |      1101 |   64.2K |  59 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeTadpoleAnchors    |   0.00% |      6153 | 4.86M | 1089 |      1491 |   1.34M | 994 |    0.0 | 0.0 |   0.0 |   0.0 |           |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|----------:|
| 8_spades     |  99.19% |      2808 |  4.1M | 1678 |      1414 |   1.03M | 1728 |   43.0 | 1.0 |  13.3 |  69.0 | 0:00'49'' |
| 8_spades_MR  |  99.33% |     29078 | 5.03M |  376 |       598 |  94.06K |  456 |   36.0 | 1.0 |  11.0 |  58.5 | 0:00'50'' |
| 8_megahit    |  98.97% |      4026 | 4.52M | 1420 |      1039 | 600.83K | 1560 |   43.0 | 2.0 |  12.3 |  73.5 | 0:00'50'' |
| 8_megahit_MR |  99.57% |     28897 | 5.04M |  369 |       545 |  92.79K |  460 |   36.0 | 1.0 |  11.0 |  58.5 | 0:00'51'' |
| 8_platanus   |  98.78% |      4215 | 4.53M | 1389 |      1043 | 573.42K | 1538 |   43.0 | 2.0 |  12.3 |  73.5 | 0:00'50'' |


Table: statFinal

| Name                     |     N50 |     Sum |   # |
|:-------------------------|--------:|--------:|----:|
| Genome                   | 5067172 | 5090491 |   2 |
| Paralogs                 |    1580 |   83364 |  53 |
| 7_mergeAnchors.anchors   |   38392 | 5085488 | 273 |
| 7_mergeAnchors.others    |    1810 |  466178 | 304 |
| anchorLong               |   38624 | 5070821 | 243 |
| anchorFill               |  151726 | 5102740 |  62 |
| spades.contig            |  187242 | 5141078 |  92 |
| spades.scaffold          |  187242 | 5141098 |  90 |
| spades.non-contained     |  187242 | 5123240 |  50 |
| spades_MR.contig         |  119727 | 5136370 | 107 |
| spades_MR.scaffold       |  121484 | 5136500 | 103 |
| spades_MR.non-contained  |  119727 | 5123008 |  80 |
| megahit.contig           |   63519 | 5148822 | 213 |
| megahit.non-contained    |   65134 | 5122565 | 140 |
| megahit_MR.contig        |  107665 | 5140452 | 105 |
| megahit_MR.non-contained |  107665 | 5133957 |  91 |
| platanus.contig          |   50491 | 5151341 | 421 |
| platanus.scaffold        |   68190 | 5128231 | 226 |
| platanus.non-contained   |   68190 | 5104695 | 149 |


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

rm -f *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 4602977 \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --sgastats \
    --trim2 "--dedupe" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,3" \
    --cov2 "30 all" \
    --tadpole \
    --redoanchors \
    --fillanchor \
    --parallel 24 \
    --xmx 110g

```

## Rsph: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Rsph

cd ${WORKING_DIR}/${BASE_NAME}
#rm -fr 4_*/ 6_*/ 7_*/ 8_*/ 2_illumina/trim 2_illumina/mergereads statReads.md 

bash 0_bsub.sh
#bkill -J "${BASE_NAME}-*"

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

| Group             |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:------------------|------:|-------:|------:|-------------------------------:|
| R.genome.bbtools  | 440.0 |    422 | 958.8 |                         15.58% |
| R.tadpole.bbtools | 407.6 |    420 |  84.2 |                         32.42% |
| R.genome.picard   | 412.9 |    422 |  39.3 |                             FR |
| R.tadpole.picard  | 408.4 |    421 |  46.7 |                             FR |


Table: statSgaStats

| Library | incorrectBases | perfectReads | overlapDepth |
|:--------|---------------:|-------------:|-------------:|
| R       |          2.22% |       13.24% |        17.88 |


Table: statReads

| Name       |     N50 |     Sum |       # |
|:-----------|--------:|--------:|--------:|
| Genome     | 3188524 | 4602977 |       7 |
| Paralogs   |    2337 |  147155 |      66 |
| Illumina.R |     251 |  451.8M | 1800000 |
| trim.R     |     148 |  200.1M | 1452706 |
| Q20L60     |     148 | 193.66M | 1401466 |
| Q25L60     |     139 | 169.12M | 1304628 |
| Q30L60     |     119 | 125.02M | 1123194 |


Table: statTrimReads

| Name     | N50 |     Sum |       # |
|:---------|----:|--------:|--------:|
| clumpify | 251 | 447.53M | 1782994 |
| trim     | 148 |  200.1M | 1452706 |
| filter   | 148 |  200.1M | 1452706 |
| R1       | 164 | 100.24M |  655190 |
| R2       | 133 |  81.52M |  655190 |
| Rs       | 141 |  18.34M |  142326 |


```text
#R.trim
#Matched	113823	6.38381%
#Name	Reads	ReadsPct
Reverse_adapter	81598	4.57646%
pcr_dimer	14481	0.81217%
PCR_Primers	8081	0.45323%
TruSeq_Universal_Adapter	5665	0.31772%
```

```text
#R.filter
#Matched	0	0.00000%
#Name	Reads	ReadsPct
```

```text
#R.peaks
#k	31
#unique_kmers	8019347
#main_peak	30
#genome_size	4263517
#haploid_genome_size	4263517
#fold_coverage	30
#haploid_fold_coverage	30
#ploidy	1
#percent_repeat	0.415
#start	center	stop	max	volume
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 148 | 200.09M | 1452579 |
| ecco          | 148 | 199.84M | 1452578 |
| ecct          | 148 | 198.72M | 1443995 |
| extended      | 186 | 255.79M | 1443995 |
| merged.raw    | 455 | 197.87M |  476630 |
| unmerged.raw  | 171 |  79.64M |  490734 |
| unmerged.trim | 171 |  79.62M |  490390 |
| M1            | 455 | 197.68M |  476218 |
| U1            | 172 |  19.66M |  121643 |
| U2            | 151 |  17.52M |  121643 |
| Us            | 182 |  42.43M |  247104 |
| M.cor         | 443 | 278.02M | 1689930 |

| Group              |  Mean | Median | STDev | PercentOfPairs |
|:-------------------|------:|-------:|------:|---------------:|
| M.ihist.merge1.txt | 184.4 |    179 |  66.0 |         10.53% |
| M.ihist.merge.txt  | 415.1 |    452 |  88.9 |         66.02% |


Table: statQuorum

| Name     | CovIn | CovOut | Discard% | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:---------|------:|-------:|---------:|-----:|------:|------:|---------:|----------:|
| Q0L0.R   |  43.5 |   38.7 |   11.10% | "39" |  4.6M | 4.55M |     0.99 | 0:00'28'' |
| Q20L60.R |  42.1 |   37.9 |    9.98% | "39" |  4.6M | 4.55M |     0.99 | 0:00'27'' |
| Q25L60.R |  36.8 |   34.9 |    5.03% | "35" |  4.6M | 4.54M |     0.99 | 0:00'25'' |
| Q30L60.R |  27.2 |   26.6 |    2.20% | "31" |  4.6M | 4.52M |     0.98 | 0:00'21'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X30P000    |   30.0 |  97.66% |     23428 | 4.04M | 327 |      6293 | 666.36K | 1252 |   27.0 | 2.0 |   7.0 |  49.5 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'58'' |
| Q0L0XallP000   |   38.7 |  97.74% |     24762 | 4.06M | 285 |      6016 | 593.94K | 1180 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'59'' |
| Q20L60X30P000  |   30.0 |  97.83% |     23436 | 4.04M | 320 |      7319 | 654.55K | 1229 |   27.0 | 2.0 |   7.0 |  49.5 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'56'' |
| Q20L60XallP000 |   37.9 |  97.81% |     27281 | 4.05M | 281 |      7035 | 611.08K | 1093 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'56'' |
| Q25L60X30P000  |   30.0 |  98.32% |     18687 | 4.05M | 403 |      6614 | 722.07K | 1318 |   28.0 | 3.0 |   6.3 |  55.5 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'54'' |
| Q25L60XallP000 |   34.9 |  98.40% |     20219 | 4.04M | 352 |     11767 | 738.67K | 1216 |   32.0 | 3.0 |   7.7 |  61.5 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'56'' |
| Q30L60XallP000 |   26.6 |  97.66% |      9317 | 3.95M | 655 |      6252 | 767.64K | 1719 |   25.0 | 3.0 |   5.3 |  50.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'51'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X30P000    |   30.0 |  98.26% |     17425 | 4.07M | 419 |      6046 | 761.31K | 1463 |   28.0 | 3.0 |   6.3 |  55.5 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'56'' |
| Q0L0XallP000   |   38.7 |  98.46% |     22930 | 4.11M | 342 |      5245 | 704.45K | 1340 |   36.0 | 4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'58'' |
| Q20L60X30P000  |   30.0 |  98.24% |     16167 | 4.06M | 444 |      6040 | 714.63K | 1475 |   28.0 | 3.0 |   6.3 |  55.5 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'55'' |
| Q20L60XallP000 |   37.9 |  98.41% |     20580 | 4.04M | 354 |      9577 | 820.76K | 1321 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'58'' |
| Q25L60X30P000  |   30.0 |  97.98% |     11435 |    4M | 572 |      6644 | 769.78K | 1711 |   28.0 | 3.0 |   6.3 |  55.5 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'53'' |
| Q25L60XallP000 |   34.9 |  98.19% |     13496 | 4.08M | 521 |      5850 | 698.59K | 1582 |   33.0 | 4.0 |   7.0 |  66.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'54'' |
| Q30L60XallP000 |   26.6 |  96.30% |      6677 | 3.87M | 863 |      5146 |  770.5K | 2239 |   25.0 | 3.0 |   5.3 |  50.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'50'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX30P000  |   30.0 |  97.42% |     21304 | 4.04M | 341 |     12569 | 523.35K | 771 |   27.0 | 2.0 |   7.0 |  49.5 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'49'' |
| MRX30P001  |   30.0 |  97.48% |     21327 | 4.06M | 348 |      8044 | 483.44K | 767 |   27.0 | 2.0 |   7.0 |  49.5 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'50'' |
| MRXallP000 |   60.4 |  97.40% |     22080 | 4.06M | 337 |      9214 | 512.82K | 763 |   55.0 | 4.0 |  14.3 | 100.5 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'49'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX30P000  |   30.0 |  97.65% |     19206 | 4.05M | 357 |     12285 |  530.9K | 853 |   27.0 | 2.0 |   7.0 |  49.5 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'50'' |
| MRX30P001  |   30.0 |  97.59% |     20344 | 4.06M | 358 |     10142 | 493.14K | 835 |   27.0 | 2.0 |   7.0 |  49.5 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'51'' |
| MRXallP000 |   60.4 |  97.59% |     21839 | 4.06M | 335 |     11731 | 463.48K | 768 |   55.0 | 4.0 |  14.3 | 100.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'50'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |  82.11% |     29395 | 3.93M | 390 |     11767 |  1.05M | 291 |   34.0 | 1.0 |  10.3 |  55.5 | 0:00'52'' |
| 7_mergeKunitigsAnchors   |  86.50% |     33507 | 4.03M | 238 |     11818 | 894.2K | 200 |   34.0 | 2.0 |   9.3 |  60.0 | 0:00'59'' |
| 7_mergeMRKunitigsAnchors |  86.38% |     22424 | 4.01M | 319 |     12285 | 613.6K | 122 |   34.0 | 2.0 |   9.3 |  60.0 | 0:00'58'' |
| 7_mergeMRTadpoleAnchors  |  86.64% |     22025 | 4.01M | 326 |     12285 |   575K | 112 |   34.0 | 2.0 |   9.3 |  60.0 | 0:00'59'' |
| 7_mergeTadpoleAnchors    |  84.76% |     23306 | 4.02M | 310 |     10085 |  1.01M | 238 |   34.0 | 2.0 |   9.3 |  60.0 | 0:00'54'' |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|----------:|
| 8_spades     |  99.21% |     78234 | 4.09M | 101 |     44658 | 474.19K | 172 |   35.0 | 2.0 |   9.7 |  61.5 | 0:00'51'' |
| 8_spades_MR  |  99.21% |     50963 |  4.1M | 161 |     16556 | 456.24K | 307 |   55.0 | 3.5 |  14.8 |  98.2 | 0:00'49'' |
| 8_megahit    |  98.47% |     49549 | 4.08M | 192 |     12571 | 460.04K | 382 |   35.0 | 3.0 |   8.7 |  66.0 | 0:00'49'' |
| 8_megahit_MR |  98.98% |     26546 |  4.1M | 289 |     12742 |  457.8K | 573 |   55.0 | 4.0 |  14.3 | 100.5 | 0:00'49'' |
| 8_platanus   |  96.35% |     53216 | 4.04M | 163 |     10783 | 434.31K | 298 |   35.0 | 3.0 |   8.7 |  66.0 | 0:00'49'' |


Table: statFinal

| Name                     |     N50 |     Sum |    # |
|:-------------------------|--------:|--------:|-----:|
| Genome                   | 3188524 | 4602977 |    7 |
| Paralogs                 |    2337 |  147155 |   66 |
| 7_mergeAnchors.anchors   |   29395 | 3927561 |  390 |
| 7_mergeAnchors.others    |   11767 | 1045920 |  291 |
| anchorLong               |   29395 | 3925804 |  387 |
| anchorFill               |  103547 | 4034646 |   80 |
| spades.contig            |  150729 | 4576784 |  136 |
| spades.scaffold          |  172829 | 4576930 |  131 |
| spades.non-contained     |  150729 | 4562278 |   71 |
| spades_MR.contig         |   55603 | 4565569 |  166 |
| spades_MR.scaffold       |   89512 | 4566728 |  119 |
| spades_MR.non-contained  |   55603 | 4557081 |  148 |
| megahit.contig           |   49581 | 4574173 |  265 |
| megahit.non-contained    |   50790 | 4539362 |  192 |
| megahit_MR.contig        |   26703 | 4613989 |  432 |
| megahit_MR.non-contained |   27508 | 4556048 |  290 |
| platanus.contig          |   15555 | 4617410 | 1657 |
| platanus.scaffold        |   85196 | 4561389 |  574 |
| platanus.non-contained   |   89576 | 4473094 |  135 |


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

rm -f *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 4033464 \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --trim2 "--dedupe --tile" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,2,3" \
    --cov2 "40 50 all" \
    --tadpole \
    --redoanchors \
    --fillanchor \
    --parallel 24 \
    --xmx 110g

```

## Vcho: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Vcho

cd ${WORKING_DIR}/${BASE_NAME}
#rm -fr 4_*/ 6_*/ 7_*/ 8_*/ 2_illumina/trim 2_illumina/mergereads statReads.md 

bash 0_bsub.sh
#bkill -J "${BASE_NAME}-*"

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

| Group             |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:------------------|------:|-------:|-------:|-------------------------------:|
| R.genome.bbtools  | 391.1 |    274 | 1890.4 |                          8.53% |
| R.tadpole.bbtools | 270.9 |    268 |   53.0 |                         41.43% |
| R.genome.picard   | 294.0 |    277 |   48.0 |                             FR |
| R.genome.picard   | 280.2 |    268 |   29.0 |                             RF |
| R.tadpole.picard  | 271.9 |    268 |   48.0 |                             FR |
| R.tadpole.picard  | 260.4 |    262 |   44.9 |                             RF |


Table: statReads

| Name       |     N50 |     Sum |       # |
|:-----------|--------:|--------:|--------:|
| Genome     | 2961149 | 4033464 |       2 |
| Paralogs   |    3483 |  114707 |      48 |
| Illumina.R |     251 |    400M | 1593624 |
| trim.R     |     189 | 261.85M | 1446928 |
| Q20L60     |     189 |  257.1M | 1415659 |
| Q25L60     |     187 | 243.51M | 1363238 |
| Q30L60     |     181 |  216.1M | 1263276 |


Table: statTrimReads

| Name           | N50 |     Sum |       # |
|:---------------|----:|--------:|--------:|
| clumpify       | 251 | 397.98M | 1585566 |
| filteredbytile | 251 | 377.63M | 1504492 |
| trim           | 189 | 263.47M | 1454606 |
| filter         | 189 | 261.85M | 1446928 |
| R1             | 193 | 134.61M |  723464 |
| R2             | 184 | 127.24M |  723464 |
| Rs             |   0 |       0 |       0 |


```text
#R.trim
#Matched	1221652	81.20030%
#Name	Reads	ReadsPct
Reverse_adapter	591818	39.33673%
pcr_dimer	341302	22.68553%
PCR_Primers	175146	11.64154%
TruSeq_Universal_Adapter	45851	3.04761%
TruSeq_Adapter_Index_1_6	45230	3.00633%
Nextera_LMP_Read2_External_Adapter	18505	1.22998%
```

```text
#R.filter
#Matched	7676	0.52770%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	7676	0.52770%
```

```text
#R.peaks
#k	31
#unique_kmers	10361662
#main_peak	53
#genome_size	34510411
#haploid_genome_size	4313801
#fold_coverage	6
#haploid_fold_coverage	53
#ploidy	8
#het_rate	0.00007
#percent_repeat	2.363
#start	center	stop	max	volume
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 189 | 256.12M | 1411874 |
| ecco          | 189 | 256.09M | 1411874 |
| eccc          | 189 | 256.09M | 1411874 |
| ecct          | 189 | 253.12M | 1395672 |
| extended      | 228 |  308.7M | 1395672 |
| merged.raw    | 239 | 165.89M |  692890 |
| unmerged.raw  | 226 |   2.04M |    9892 |
| unmerged.trim | 226 |   2.04M |    9890 |
| M1            | 239 | 154.07M |  643964 |
| U1            | 239 |   1.11M |    4945 |
| U2            | 214 | 931.05K |    4945 |
| Us            |   0 |       0 |       0 |
| M.cor         | 238 | 156.75M | 1297818 |

| Group              |  Mean | Median | STDev | PercentOfPairs |
|:-------------------|------:|-------:|------:|---------------:|
| M.ihist.merge1.txt | 197.3 |    191 |  44.7 |         95.16% |
| M.ihist.merge.txt  | 239.4 |    232 |  51.5 |         99.29% |


Table: statQuorum

| Name     | CovIn | CovOut | Discard% |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:---------|------:|-------:|---------:|------:|------:|------:|---------:|----------:|
| Q0L0.R   |  64.9 |   54.6 |   15.96% | "109" | 4.03M | 3.96M |     0.98 | 0:00'31'' |
| Q20L60.R |  63.7 |   54.3 |   14.81% | "109" | 4.03M | 3.95M |     0.98 | 0:00'29'' |
| Q25L60.R |  60.4 |   52.9 |   12.44% | "109" | 4.03M | 3.94M |     0.98 | 0:00'28'' |
| Q30L60.R |  53.6 |   48.4 |    9.71% | "105" | 4.03M | 3.93M |     0.97 | 0:00'26'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  93.62% |      8327 | 3.63M | 696 |      1000 | 243.58K | 1465 |   39.0 | 5.0 |   8.0 |  78.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'46'' |
| Q0L0X50P000    |   50.0 |  93.02% |      7583 | 3.63M | 734 |       945 | 241.13K | 1502 |   49.0 | 6.0 |  10.3 |  98.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'46'' |
| Q0L0XallP000   |   54.6 |  92.76% |      7296 | 3.64M | 734 |       996 | 219.73K | 1500 |   53.0 | 7.0 |  10.7 | 106.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'46'' |
| Q20L60X40P000  |   40.0 |  93.83% |      8660 | 3.64M | 675 |      1023 | 251.19K | 1429 |   39.0 | 5.0 |   8.0 |  78.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'45'' |
| Q20L60X50P000  |   50.0 |  93.33% |      7721 | 3.64M | 701 |      1037 | 242.09K | 1443 |   49.0 | 6.0 |  10.3 |  98.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'46'' |
| Q20L60XallP000 |   54.3 |  93.15% |      7676 | 3.64M | 703 |      1032 | 239.16K | 1436 |   53.0 | 6.0 |  11.7 | 106.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'46'' |
| Q25L60X40P000  |   40.0 |  96.50% |     20567 | 3.71M | 369 |      1017 | 198.79K |  824 |   40.0 | 5.0 |   8.3 |  80.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'48'' |
| Q25L60X50P000  |   50.0 |  96.20% |     19419 | 3.75M | 356 |       999 | 145.84K |  804 |   50.0 | 7.0 |   9.7 | 100.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'49'' |
| Q25L60XallP000 |   52.9 |  96.21% |     18852 | 3.73M | 370 |      1116 | 172.27K |  826 |   52.0 | 7.0 |  10.3 | 104.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'47'' |
| Q30L60X40P000  |   40.0 |  96.82% |     28809 | 3.73M | 313 |      1121 | 179.78K |  731 |   40.0 | 5.0 |   8.3 |  80.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'49'' |
| Q30L60XallP000 |   48.4 |  96.50% |     21794 | 3.74M | 325 |      1050 |  151.4K |  750 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'48'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  96.58% |     15990 | 3.72M | 421 |      1049 | 207.76K | 1044 |   39.0 | 5.0 |   8.0 |  78.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'49'' |
| Q0L0X50P000    |   50.0 |  95.79% |     13408 | 3.71M | 505 |      1010 | 212.94K | 1096 |   49.0 | 6.0 |  10.3 |  98.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'48'' |
| Q0L0XallP000   |   54.6 |  95.59% |     11396 | 3.74M | 518 |      1025 |  188.9K | 1134 |   54.0 | 7.0 |  11.0 | 108.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'48'' |
| Q20L60X40P000  |   40.0 |  96.71% |     16528 | 3.71M | 444 |      1047 | 220.61K | 1101 |   39.0 | 5.0 |   8.0 |  78.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'50'' |
| Q20L60X50P000  |   50.0 |  95.99% |     13551 | 3.73M | 485 |      1010 | 201.24K | 1102 |   50.0 | 6.0 |  10.7 | 100.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'48'' |
| Q20L60XallP000 |   54.3 |  95.65% |     12277 | 3.73M | 508 |      1026 | 189.14K | 1116 |   54.0 | 7.0 |  11.0 | 108.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'47'' |
| Q25L60X40P000  |   40.0 |  97.68% |     37276 | 3.77M | 256 |      1065 | 167.84K |  725 |   40.0 | 6.0 |   7.3 |  80.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'52'' |
| Q25L60X50P000  |   50.0 |  97.59% |     40571 | 3.78M | 235 |      1056 | 145.87K |  634 |   50.0 | 7.0 |   9.7 | 100.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'53'' |
| Q25L60XallP000 |   52.9 |  97.63% |     43535 |  3.8M | 223 |      1050 | 123.42K |  605 |   53.0 | 8.0 |   9.7 | 106.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'53'' |
| Q30L60X40P000  |   40.0 |  97.71% |     39305 | 3.78M | 236 |      1031 | 141.74K |  714 |   40.0 | 6.0 |   7.3 |  80.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'52'' |
| Q30L60XallP000 |   48.4 |  97.78% |     41061 |  3.8M | 220 |      1046 | 126.82K |  651 |   48.0 | 7.0 |   9.0 |  96.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'53'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   38.9 |  96.75% |     45468 | 3.82M | 168 |      1032 | 57.95K | 372 |   40.0 | 7.0 |   6.3 |  80.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'47'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   38.9 |  96.92% |     67211 | 3.85M | 144 |      1025 | 42.83K | 317 |   39.0 | 7.0 |   6.0 |  78.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'46'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median |  MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|-----:|------:|------:|----------:|
| 7_mergeAnchors           |  96.12% |     69422 |  3.8M | 147 |      1569 | 257.72K | 178 |   55.0 | 10.0 |   8.3 | 110.0 | 0:00'51'' |
| 7_mergeKunitigsAnchors   |  96.91% |     31473 | 3.76M | 238 |      1452 | 285.85K | 210 |   55.0 |  8.0 |  10.3 | 110.0 | 0:01'00'' |
| 7_mergeMRKunitigsAnchors |  94.99% |     41004 | 3.78M | 197 |      1212 |  66.92K |  55 |   55.0 |  9.0 |   9.3 | 110.0 | 0:00'44'' |
| 7_mergeMRTadpoleAnchors  |  95.39% |     59490 | 3.79M | 169 |      1195 |  64.61K |  54 |   55.0 |  9.0 |   9.3 | 110.0 | 0:00'45'' |
| 7_mergeTadpoleAnchors    |  97.07% |     58625 | 3.81M | 172 |      1569 |  214.1K | 149 |   55.0 | 10.0 |   8.3 | 110.0 | 0:00'56'' |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median |  MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|-----:|------:|------:|----------:|
| 8_spades     |  98.41% |    125253 | 3.88M |  91 |      1197 | 39.49K | 155 |   55.0 | 12.0 |   6.3 | 110.0 | 0:00'47'' |
| 8_spades_MR  |  98.48% |    112671 | 3.89M | 108 |      1155 | 34.12K | 214 |   39.0 |  8.0 |   5.0 |  78.0 | 0:00'45'' |
| 8_megahit    |  97.02% |     55915 | 3.81M | 167 |      1208 | 72.43K | 286 |   55.0 | 10.0 |   8.3 | 110.0 | 0:00'45'' |
| 8_megahit_MR |  98.45% |     92833 | 3.89M | 128 |      1060 | 36.13K | 254 |   39.0 |  8.5 |   4.5 |  78.0 | 0:00'46'' |
| 8_platanus   |  96.58% |     53377 | 3.82M | 170 |      1051 | 60.05K | 336 |   55.0 | 10.0 |   8.3 | 110.0 | 0:00'46'' |


Table: statFinal

| Name                     |     N50 |     Sum |   # |
|:-------------------------|--------:|--------:|----:|
| Genome                   | 2961149 | 4033464 |   2 |
| Paralogs                 |    3483 |  114707 |  48 |
| 7_mergeAnchors.anchors   |   69422 | 3802341 | 147 |
| 7_mergeAnchors.others    |    1569 |  257720 | 178 |
| anchorLong               |   69422 | 3801134 | 144 |
| anchorFill               |  162983 | 3827674 |  61 |
| spades.contig            |  246446 | 3962902 | 185 |
| spades.scaffold          |  343744 | 3963102 | 183 |
| spades.non-contained     |  246446 | 3924352 |  64 |
| spades_MR.contig         |  112747 | 3957005 | 207 |
| spades_MR.scaffold       |  112747 | 3957135 | 203 |
| spades_MR.non-contained  |  112747 | 3920662 | 106 |
| megahit.contig           |   71376 | 3947519 | 264 |
| megahit.non-contained    |   73095 | 3879487 | 119 |
| megahit_MR.contig        |   92296 | 3976538 | 234 |
| megahit_MR.non-contained |   92931 | 3928069 | 126 |
| platanus.contig          |   53386 | 3985983 | 535 |
| platanus.scaffold        |   58949 | 3934428 | 325 |
| platanus.non-contained   |   58949 | 3878863 | 166 |


# *Vibrio cholerae* CP1032(5) HiSeq

## VchoH: download

* Reference genome

```bash
mkdir -p ${HOME}/data/anchr/VchoH/1_genome
cd ${HOME}/data/anchr/VchoH/1_genome

cp ~/data/anchr/Vcho/1_genome/genome.fa .
cp ~/data/anchr/Vcho/1_genome/paralogs.fas .

```

* Illumina

    Download from GAGE-B site.

```bash
mkdir -p ${HOME}/data/anchr/VchoH/2_illumina
cd ${HOME}/data/anchr/VchoH/2_illumina

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

rm -f *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 4033464 \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --trim2 "--dedupe --tile" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,2,3" \
    --cov2 "40 50 all" \
    --tadpole \
    --redoanchors \
    --fillanchor \
    --parallel 24 \
    --xmx 110g

```

## VchoH: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=VchoH

cd ${WORKING_DIR}/${BASE_NAME}
#rm -fr 4_*/ 6_*/ 7_*/ 8_*/ 2_illumina/trim 2_illumina/mergereads statReads.md 

bash 0_bsub.sh
#bkill -J "${BASE_NAME}-*"

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

| Group             |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:------------------|------:|-------:|-------:|-------------------------------:|
| R.genome.bbtools  | 246.3 |    193 | 1279.0 |                         46.93% |
| R.tadpole.bbtools | 196.4 |    189 |   53.4 |                         39.77% |
| R.genome.picard   | 199.2 |    193 |   47.4 |                             FR |
| R.tadpole.picard  | 193.5 |    188 |   44.6 |                             FR |


Table: statReads

| Name       |     N50 |     Sum |       # |
|:-----------|--------:|--------:|--------:|
| Genome     | 2961149 | 4033464 |       2 |
| Paralogs   |    3483 |  114707 |      48 |
| Illumina.R |     100 | 392.01M | 3920090 |
| trim.R     |     100 | 272.86M | 2878714 |
| Q20L60     |     100 |  264.8M | 2797895 |
| Q25L60     |     100 | 246.99M | 2641510 |
| Q30L60     |     100 | 212.84M | 2347183 |


Table: statTrimReads

| Name           | N50 |     Sum |       # |
|:---------------|----:|--------:|--------:|
| clumpify       | 100 | 362.86M | 3628564 |
| filteredbytile | 100 | 337.27M | 3372744 |
| trim           | 100 | 272.88M | 2878856 |
| filter         | 100 | 272.86M | 2878714 |
| R1             | 100 | 139.29M | 1439357 |
| R2             | 100 | 133.57M | 1439357 |
| Rs             |   0 |       0 |       0 |


```text
#R.trim
#Matched	5577	0.16535%
#Name	Reads	ReadsPct
```

```text
#R.filter
#Matched	142	0.00493%
#Name	Reads	ReadsPct
```

```text
#R.peaks
#k	31
#unique_kmers	11286697
#main_peak	45
#genome_size	3831223
#haploid_genome_size	3831223
#fold_coverage	45
#haploid_fold_coverage	45
#ploidy	1
#percent_repeat	2.187
#start	center	stop	max	volume
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 100 | 271.51M | 2863574 |
| ecco          | 100 | 271.51M | 2863574 |
| eccc          | 100 | 271.51M | 2863574 |
| ecct          | 100 |  268.4M | 2829700 |
| extended      | 140 | 379.68M | 2829700 |
| merged.raw    | 237 | 321.67M | 1363880 |
| unmerged.raw  | 140 |  12.94M |  101940 |
| unmerged.trim | 140 |  12.94M |  101938 |
| M1            | 238 | 283.01M | 1199199 |
| U1            | 140 |   6.68M |   50969 |
| U2            | 134 |   6.26M |   50969 |
| Us            |   0 |       0 |       0 |
| M.cor         | 235 | 297.15M | 2500336 |

| Group              |  Mean | Median | STDev | PercentOfPairs |
|:-------------------|------:|-------:|------:|---------------:|
| M.ihist.merge1.txt | 158.3 |    161 |  18.3 |         30.46% |
| M.ihist.merge.txt  | 235.8 |    231 |  41.6 |         96.40% |


Table: statQuorum

| Name     | CovIn | CovOut | Discard% | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:---------|------:|-------:|---------:|-----:|------:|------:|---------:|----------:|
| Q0L0.R   |  67.6 |   59.2 |   12.52% | "65" | 4.03M | 3.96M |     0.98 | 0:00'36'' |
| Q20L60.R |  65.7 |   58.6 |   10.73% | "65" | 4.03M | 3.95M |     0.98 | 0:00'33'' |
| Q25L60.R |  61.3 |   56.7 |    7.54% | "63" | 4.03M | 3.93M |     0.97 | 0:00'33'' |
| Q30L60.R |  52.8 |   50.5 |    4.39% | "59" | 4.03M | 3.92M |     0.97 | 0:00'30'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  92.93% |      3406 | 3.66M | 1310 |      1014 |  357.7K | 4083 |   39.0 | 5.0 |   8.0 |  78.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'54'' |
| Q0L0X50P000    |   50.0 |  92.41% |      3285 | 3.61M | 1302 |      1025 | 370.77K | 4079 |   49.0 | 6.0 |  10.3 |  98.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'53'' |
| Q0L0XallP000   |   59.2 |  92.10% |      3387 |  3.6M | 1291 |      1020 | 334.29K | 4063 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'55'' |
| Q20L60X40P000  |   40.0 |  93.87% |      3924 | 3.66M | 1187 |      1009 | 369.33K | 3902 |   40.0 | 5.0 |   8.3 |  80.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'55'' |
| Q20L60X50P000  |   50.0 |  93.30% |      3859 | 3.64M | 1200 |      1000 | 329.21K | 3942 |   49.0 | 6.0 |  10.3 |  98.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'57'' |
| Q20L60XallP000 |   58.6 |  93.13% |      3733 | 3.63M | 1217 |      1008 | 323.51K | 3971 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'57'' |
| Q25L60X40P000  |   40.0 |  94.57% |      4578 | 3.65M | 1070 |      1000 | 340.56K | 3583 |   40.0 | 5.0 |   8.3 |  80.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'55'' |
| Q25L60X50P000  |   50.0 |  94.49% |      4486 | 3.67M | 1077 |       960 | 298.93K | 3651 |   50.0 | 6.0 |  10.7 | 100.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'58'' |
| Q25L60XallP000 |   56.7 |  94.57% |      4409 | 3.65M | 1088 |       959 | 336.57K | 3714 |   56.0 | 6.0 |  12.7 | 111.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'58'' |
| Q30L60X40P000  |   40.0 |  95.57% |      5939 | 3.65M |  883 |      1005 |    321K | 2840 |   40.0 | 5.0 |   8.3 |  80.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'53'' |
| Q30L60X50P000  |   50.0 |  95.85% |      6178 | 3.68M |  861 |       989 | 297.52K | 2848 |   50.0 | 6.0 |  10.7 | 100.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'55'' |
| Q30L60XallP000 |   50.5 |  95.88% |      6167 | 3.68M |  861 |      1000 |  306.8K | 2852 |   50.0 | 6.0 |  10.7 | 100.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'55'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  94.86% |      5380 | 3.69M |  944 |       798 | 255.31K | 3347 |   40.0 | 5.0 |   8.3 |  80.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'57'' |
| Q0L0X50P000    |   50.0 |  94.61% |      4697 | 3.72M | 1049 |       860 | 265.52K | 3624 |   50.0 | 6.0 |  10.7 | 100.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'58'' |
| Q0L0XallP000   |   59.2 |  94.28% |      4388 | 3.72M | 1117 |       906 | 303.04K | 3907 |   59.0 | 7.0 |  12.7 | 118.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'57'' |
| Q20L60X40P000  |   40.0 |  95.46% |      6155 | 3.68M |  884 |       903 | 278.79K | 3271 |   40.0 | 5.0 |   8.3 |  80.0 | "31,41,51,61,71,81" | 0:00'32'' | 0:00'56'' |
| Q20L60X50P000  |   50.0 |  95.12% |      4995 | 3.72M | 1016 |       885 | 274.91K | 3590 |   50.0 | 6.0 |  10.7 | 100.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'56'' |
| Q20L60XallP000 |   58.6 |  94.77% |      4446 | 3.72M | 1106 |       927 | 311.22K | 3834 |   58.0 | 7.0 |  12.3 | 116.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'57'' |
| Q25L60X40P000  |   40.0 |  95.31% |      5938 | 3.65M |  891 |       886 | 275.06K | 3181 |   40.0 | 5.0 |   8.3 |  80.0 | "31,41,51,61,71,81" | 0:00'32'' | 0:00'55'' |
| Q25L60X50P000  |   50.0 |  95.07% |      5175 | 3.68M |  987 |       885 | 287.08K | 3497 |   50.0 | 6.0 |  10.7 | 100.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'56'' |
| Q25L60XallP000 |   56.7 |  94.85% |      4866 |  3.7M | 1040 |       871 | 270.05K | 3690 |   57.0 | 7.0 |  12.0 | 114.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'57'' |
| Q30L60X40P000  |   40.0 |  94.79% |      5444 | 3.59M |  938 |       965 | 304.69K | 2977 |   40.0 | 5.0 |   8.3 |  80.0 | "31,41,51,61,71,81" | 0:00'30'' | 0:00'53'' |
| Q30L60X50P000  |   50.0 |  95.18% |      5607 | 3.63M |  919 |       989 | 300.23K | 3049 |   50.0 | 6.0 |  10.7 | 100.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'55'' |
| Q30L60XallP000 |   50.5 |  95.19% |      5520 | 3.63M |  925 |       989 | 314.19K | 3057 |   50.0 | 6.0 |  10.7 | 100.0 | "31,41,51,61,71,81" | 0:00'32'' | 0:00'55'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  94.08% |     12092 | 3.76M | 498 |       623 | 103.14K | 1032 |   39.0 | 5.0 |   8.0 |  78.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'46'' |
| MRX50P000  |   50.0 |  93.43% |      9908 | 3.74M | 561 |       492 | 117.15K | 1153 |   49.0 | 6.0 |  10.3 |  98.0 | "31,41,51,61,71,81" | 0:00'59'' | 0:00'46'' |
| MRXallP000 |   73.7 |  92.40% |      8788 | 3.71M | 638 |       373 | 123.23K | 1309 |   73.0 | 9.0 |  15.3 | 146.0 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'46'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  95.72% |     19354 | 3.81M | 318 |       701 | 82.49K | 746 |   39.0 | 5.0 |   8.0 |  78.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'49'' |
| MRX50P000  |   50.0 |  95.31% |     17070 |  3.8M | 359 |       544 | 89.18K | 797 |   49.0 | 6.0 |  10.3 |  98.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'49'' |
| MRXallP000 |   73.7 |  94.67% |     14247 | 3.79M | 424 |       421 |    92K | 905 |   73.0 | 9.0 |  15.3 | 146.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'47'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |  96.38% |     23816 | 3.82M | 288 |      1263 | 341.61K | 266 |   60.0 | 7.0 |  13.0 | 120.0 | 0:00'56'' |
| 7_mergeKunitigsAnchors   |  96.63% |      7885 | 3.83M | 717 |      1243 | 477.73K | 373 |   59.0 | 7.0 |  12.7 | 118.0 | 0:01'08'' |
| 7_mergeMRKunitigsAnchors |  95.01% |     11909 | 3.73M | 490 |      1048 | 121.81K | 116 |   59.0 | 7.0 |  12.7 | 118.0 | 0:00'53'' |
| 7_mergeMRTadpoleAnchors  |  95.81% |     21313 | 3.79M | 311 |      1056 |  88.28K |  83 |   59.0 | 7.0 |  12.7 | 118.0 | 0:00'52'' |
| 7_mergeTadpoleAnchors    |  96.83% |      9276 | 3.82M | 621 |      1190 | 411.78K | 343 |   59.0 | 7.0 |  12.7 | 118.0 | 0:01'08'' |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median |  MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|-----:|------:|------:|----------:|
| 8_spades     |  98.13% |    112888 | 3.88M |  94 |      1174 | 39.72K | 160 |   59.0 |  9.0 |  10.7 | 118.0 | 0:00'47'' |
| 8_spades_MR  |  98.42% |     67692 |  3.9M | 112 |      1154 | 33.72K | 209 |   74.0 | 12.0 |  12.7 | 148.0 | 0:00'47'' |
| 8_megahit    |  97.55% |     63212 | 3.85M | 147 |      1143 | 49.65K | 263 |   59.0 |  8.0 |  11.7 | 118.0 | 0:00'45'' |
| 8_megahit_MR |  98.21% |     66583 |  3.9M | 139 |      1031 | 42.11K | 275 |   74.0 | 12.0 |  12.7 | 148.0 | 0:00'47'' |
| 8_platanus   |  96.21% |    104615 | 3.86M | 102 |       846 |    32K | 188 |   59.0 |  9.0 |  10.7 | 118.0 | 0:00'47'' |


Table: statFinal

| Name                     |     N50 |     Sum |    # |
|:-------------------------|--------:|--------:|-----:|
| Genome                   | 2961149 | 4033464 |    2 |
| Paralogs                 |    3483 |  114707 |   48 |
| 7_mergeAnchors.anchors   |   23816 | 3819579 |  288 |
| 7_mergeAnchors.others    |    1263 |  341609 |  266 |
| anchorLong               |   27782 | 3803073 |  253 |
| anchorFill               |  151451 | 3858250 |   67 |
| spades.contig            |  176446 | 3951907 |  178 |
| spades.scaffold          |  246617 | 3952147 |  172 |
| spades.non-contained     |  176446 | 3920647 |   66 |
| spades_MR.contig         |   78610 | 3957590 |  165 |
| spades_MR.scaffold       |   83072 | 3958969 |  152 |
| spades_MR.non-contained  |   80992 | 3935068 |  101 |
| megahit.contig           |   82015 | 3947562 |  215 |
| megahit.non-contained    |   82614 | 3904269 |  116 |
| megahit_MR.contig        |   66604 | 3990803 |  254 |
| megahit_MR.non-contained |   67821 | 3939230 |  139 |
| platanus.contig          |   15443 | 3995646 | 1339 |
| platanus.scaffold        |  109753 | 3927161 |  207 |
| platanus.non-contained   |  109753 | 3896261 |   86 |


# *Rhodobacter sphaeroides* 2.4.1 Full

## RsphF: download

* Reference genome

```bash
mkdir -p ${HOME}/data/anchr/RsphF/1_genome
cd ${HOME}/data/anchr/RsphF/1_genome

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

rm -f *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 4602977 \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --sgastats \
    --trim2 "--dedupe" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,3" \
    --cov2 "40 80" \
    --tadpole \
    --redoanchors \
    --fillanchor \
    --parallel 24 \
    --xmx 110g

```

## RsphF: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=RsphF

cd ${WORKING_DIR}/${BASE_NAME}
#rm -fr 4_*/ 6_*/ 7_*/ 8_*/ 2_illumina/trim 2_illumina/mergereads statReads.md 

bash 0_bsub.sh
#bkill -J "${BASE_NAME}-*"

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

rm -f *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 5090491 \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --trim2 "--dedupe" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,3" \
    --cov2 "40 80" \
    --tadpole \
    --redoanchors \
    --fillanchor \
    --parallel 24 \
    --xmx 110g

```

## MabsF: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=MabsF

cd ${WORKING_DIR}/${BASE_NAME}
#rm -fr 4_*/ 6_*/ 7_*/ 8_*/ 2_illumina/trim 2_illumina/mergereads statReads.md 

bash 0_bsub.sh
#bkill -J "${BASE_NAME}-*"

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

| Group             |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:------------------|------:|-------:|-------:|-------------------------------:|
| R.genome.bbtools  | 443.2 |    277 | 2401.1 |                          7.34% |
| R.tadpole.bbtools | 263.4 |    264 |   48.7 |                         33.74% |
| R.genome.picard   | 295.6 |    279 |   47.2 |                             FR |
| R.genome.picard   | 287.3 |    271 |   33.9 |                             RF |
| R.tadpole.picard  | 263.8 |    264 |   49.2 |                             FR |
| R.tadpole.picard  | 243.6 |    249 |   47.4 |                             RF |


Table: statReads

| Name       |     N50 |     Sum |       # |
|:-----------|--------:|--------:|--------:|
| Genome     | 5067172 | 5090491 |       2 |
| Paralogs   |    1580 |   83364 |      53 |
| Illumina.R |     251 |   2.19G | 8741140 |
| trim.R     |     175 |    1.3G | 8001572 |
| Q20L60     |     176 |   1.24G | 7584541 |
| Q25L60     |     173 |   1.12G | 7040290 |
| Q30L60     |     164 | 907.02M | 6136421 |


Table: statTrimReads

| Name     | N50 |     Sum |       # |
|:---------|----:|--------:|--------:|
| clumpify | 251 |   2.15G | 8581504 |
| trim     | 175 |    1.3G | 8020927 |
| filter   | 175 |    1.3G | 8001572 |
| R1       | 175 | 603.81M | 3714050 |
| R2       | 176 | 606.75M | 3714050 |
| Rs       | 173 |  86.42M |  573472 |


```text
#R.trim
#Matched	6246041	72.78492%
#Name	Reads	ReadsPct
Reverse_adapter	3209354	37.39850%
pcr_dimer	1740140	20.27780%
TruSeq_Universal_Adapter	535655	6.24197%
PCR_Primers	443712	5.17056%
TruSeq_Adapter_Index_1_6	199564	2.32551%
Nextera_LMP_Read2_External_Adapter	62851	0.73240%
TruSeq_Adapter_Index_11	28948	0.33733%
```

```text
#R.filter
#Matched	19355	0.24131%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	19355	0.24131%
```

```text
#R.peaks
#k	31
#unique_kmers	46626701
#main_peak	192
#genome_size	30509114
#haploid_genome_size	6101822
#fold_coverage	33
#haploid_fold_coverage	192
#ploidy	5
#het_rate	0.00002
#percent_repeat	0.251
#start	center	stop	max	volume
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 176 |   1.28G | 7868343 |
| ecco          | 176 |   1.28G | 7868342 |
| ecct          | 175 |   1.24G | 7658825 |
| extended      | 213 |   1.54G | 7658825 |
| merged.raw    | 233 | 763.08M | 3316956 |
| unmerged.raw  | 206 | 193.19M | 1024912 |
| unmerged.trim | 206 | 193.15M | 1024198 |
| M1            | 233 | 697.87M | 3028515 |
| U1            | 188 |  22.81M |  132284 |
| U2            | 203 |  24.89M |  132284 |
| Us            | 209 | 145.45M |  759630 |
| M.cor         | 228 | 894.81M | 7840858 |

| Group              |  Mean | Median | STDev | PercentOfPairs |
|:-------------------|------:|-------:|------:|---------------:|
| M.ihist.merge1.txt | 189.3 |    185 |  46.5 |         85.86% |
| M.ihist.merge.txt  | 230.1 |    224 |  51.5 |         86.62% |


Table: statQuorum

| Name     | CovIn | CovOut | Discard% | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:---------|------:|-------:|---------:|-----:|------:|------:|---------:|----------:|
| Q0L0.R   | 254.9 |  200.1 |   21.49% | "49" | 5.09M | 5.85M |     1.15 | 0:02'06'' |
| Q20L60.R | 244.6 |  196.1 |   19.83% | "49" | 5.09M | 5.76M |     1.13 | 0:02'01'' |
| Q25L60.R | 220.1 |  183.9 |   16.45% | "47" | 5.09M |  5.6M |     1.10 | 0:01'51'' |
| Q30L60.R | 178.4 |  155.0 |   13.13% | "41" | 5.09M | 5.38M |     1.06 | 0:01'35'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  81.78% |      2306 | 3.87M | 1842 |      1015 |  742.1K | 3917 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'49'' |
| Q0L0X40P001   |   40.0 |  81.17% |      2269 | 3.82M | 1803 |      1011 | 746.98K | 3897 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'48'' |
| Q0L0X40P002   |   40.0 |  81.83% |      2299 | 3.84M | 1815 |      1022 | 765.67K | 3929 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'48'' |
| Q0L0X40P003   |   40.0 |  81.83% |      2405 | 3.87M | 1793 |      1002 | 722.37K | 3834 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'50'' |
| Q0L0X40P004   |   40.0 |  82.31% |      2360 | 3.86M | 1793 |      1023 | 770.18K | 3862 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'51'' |
| Q0L0X80P000   |   80.0 |  56.59% |      1676 | 2.72M | 1647 |      1032 | 590.98K | 3657 |   71.0 | 6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:01'25'' | 0:00'44'' |
| Q0L0X80P001   |   80.0 |  57.29% |      1649 | 2.76M | 1676 |      1040 | 596.63K | 3730 |   71.0 | 6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:01'25'' | 0:00'46'' |
| Q20L60X40P000 |   40.0 |  83.27% |      2348 | 3.89M | 1799 |      1014 | 778.23K | 3871 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'50'' |
| Q20L60X40P001 |   40.0 |  84.21% |      2540 | 4.04M | 1783 |       978 | 663.21K | 3824 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'50'' |
| Q20L60X40P002 |   40.0 |  84.27% |      2406 | 3.94M | 1799 |      1025 | 760.93K | 3836 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'49'' |
| Q20L60X40P003 |   40.0 |  84.01% |      2407 | 3.93M | 1810 |      1019 | 771.56K | 3818 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'50'' |
| Q20L60X80P000 |   80.0 |  61.51% |      1766 | 2.94M | 1693 |      1031 | 611.18K | 3764 |   71.0 | 6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:01'25'' | 0:00'46'' |
| Q20L60X80P001 |   80.0 |  62.34% |      1746 | 3.02M | 1756 |      1028 | 591.38K | 3829 |   71.0 | 6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:01'25'' | 0:00'47'' |
| Q25L60X40P000 |   40.0 |  89.21% |      2953 | 4.25M | 1674 |       971 |  670.4K | 3651 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'51'' |
| Q25L60X40P001 |   40.0 |  89.03% |      2726 | 4.22M | 1730 |       995 | 700.52K | 3699 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'51'' |
| Q25L60X40P002 |   40.0 |  89.28% |      2834 | 4.17M | 1693 |      1017 | 781.68K | 3730 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'51'' |
| Q25L60X40P003 |   40.0 |  89.30% |      2684 | 4.25M | 1758 |       990 | 676.72K | 3741 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'52'' |
| Q25L60X80P000 |   80.0 |  73.79% |      2053 | 3.58M | 1846 |      1015 |  595.3K | 4024 |   73.0 | 6.0 |  18.3 | 136.5 | "31,41,51,61,71,81" | 0:01'25'' | 0:00'48'' |
| Q25L60X80P001 |   80.0 |  74.13% |      2047 | 3.56M | 1849 |      1023 | 654.41K | 4087 |   72.0 | 6.0 |  18.0 | 135.0 | "31,41,51,61,71,81" | 0:01'25'' | 0:00'50'' |
| Q30L60X40P000 |   40.0 |  98.26% |      4018 | 4.51M | 1386 |      1040 | 911.61K | 3057 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:01'00'' |
| Q30L60X40P001 |   40.0 |  98.32% |      3949 | 4.51M | 1416 |      1009 | 887.37K | 2976 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'57'' |
| Q30L60X40P002 |   40.0 |  98.21% |      3812 | 4.53M | 1434 |       967 | 871.37K | 3036 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'59'' |
| Q30L60X80P000 |   80.0 |  96.28% |      4959 | 4.74M | 1259 |       825 | 430.43K | 2876 |   76.0 | 5.0 |  20.0 | 136.5 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'59'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  98.22% |      5750 | 4.73M | 1116 |       888 |  612.2K | 2355 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'59'' |
| Q0L0X40P001   |   40.0 |  98.29% |      6488 | 4.78M | 1062 |       874 | 564.12K | 2349 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:01'01'' |
| Q0L0X40P002   |   40.0 |  98.34% |      6482 | 4.76M | 1059 |       935 | 620.52K | 2421 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:01'02'' |
| Q0L0X40P003   |   40.0 |  98.27% |      6517 | 4.75M | 1024 |       924 | 590.57K | 2264 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:01'01'' |
| Q0L0X40P004   |   40.0 |  98.24% |      6738 | 4.75M | 1039 |       925 | 561.57K | 2189 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:01'01'' |
| Q0L0X80P000   |   80.0 |  96.41% |      6070 | 4.82M | 1125 |       788 | 390.71K | 2659 |   76.0 | 4.0 |  20.0 | 132.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'58'' |
| Q0L0X80P001   |   80.0 |  96.48% |      6279 | 4.83M | 1092 |       788 | 411.07K | 2583 |   76.0 | 4.0 |  20.0 | 132.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'59'' |
| Q20L60X40P000 |   40.0 |  98.50% |      5732 | 4.73M | 1112 |       916 | 631.51K | 2369 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:01'01'' |
| Q20L60X40P001 |   40.0 |  98.30% |      6015 | 4.73M | 1084 |       925 | 588.05K | 2299 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'58'' |
| Q20L60X40P002 |   40.0 |  98.46% |      6800 | 4.75M | 1055 |       906 | 600.27K | 2336 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:01'02'' |
| Q20L60X40P003 |   40.0 |  98.46% |      5718 | 4.73M | 1136 |       896 | 623.67K | 2404 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:01'01'' |
| Q20L60X80P000 |   80.0 |  96.69% |      6172 | 4.82M | 1096 |       731 | 401.76K | 2590 |   76.0 | 4.0 |  20.0 | 132.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'59'' |
| Q20L60X80P001 |   80.0 |  96.86% |      6163 | 4.82M | 1110 |       795 | 420.38K | 2560 |   76.0 | 4.0 |  20.0 | 132.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'59'' |
| Q25L60X40P000 |   40.0 |  98.68% |      5732 | 4.72M | 1106 |       903 | 656.16K | 2460 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:01'01'' |
| Q25L60X40P001 |   40.0 |  98.78% |      5221 | 4.69M | 1169 |       986 |  726.6K | 2575 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:01'02'' |
| Q25L60X40P002 |   40.0 |  98.71% |      4997 | 4.67M | 1186 |      1012 | 759.48K | 2549 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:01'01'' |
| Q25L60X40P003 |   40.0 |  98.74% |      5219 | 4.71M | 1170 |       929 | 710.95K | 2623 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:01'03'' |
| Q25L60X80P000 |   80.0 |  97.64% |      7669 | 4.85M |  999 |       772 | 398.92K | 2497 |   77.0 | 4.0 |  20.0 | 133.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:01'01'' |
| Q25L60X80P001 |   80.0 |  97.50% |      6259 | 4.81M | 1082 |       867 | 447.06K | 2571 |   76.0 | 4.0 |  20.0 | 132.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'58'' |
| Q30L60X40P000 |   40.0 |  99.24% |      4719 | 4.64M | 1236 |      1037 | 761.41K | 2477 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:01'03'' |
| Q30L60X40P001 |   40.0 |  99.25% |      5860 | 4.73M | 1085 |       962 |  653.8K | 2345 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'39'' | 0:01'03'' |
| Q30L60X40P002 |   40.0 |  99.27% |      5783 | 4.74M | 1077 |       926 | 652.13K | 2389 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'39'' | 0:01'02'' |
| Q30L60X80P000 |   80.0 |  99.08% |      7092 |  4.8M |  994 |       949 | 550.46K | 2393 |   77.0 | 3.0 |  20.0 | 129.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:01'04'' |


Table: statMRKunitigsAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  94.28% |      6496 | 4.84M | 1057 |       203 | 253.12K | 2122 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'51'' |
| MRX40P001 |   40.0 |  94.06% |      5890 | 4.83M | 1137 |       133 | 257.52K | 2269 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'52'' |
| MRX40P002 |   40.0 |  94.24% |      6512 | 4.83M | 1067 |       231 | 255.64K | 2138 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'51'' |
| MRX40P003 |   40.0 |  94.27% |      5997 | 4.83M | 1091 |       252 | 260.76K | 2156 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'50'' |
| MRX80P000 |   80.0 |  83.49% |      3067 | 4.36M | 1676 |        96 | 346.99K | 3528 |   74.0 | 6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:01'41'' | 0:00'52'' |
| MRX80P001 |   80.0 |  83.38% |      3020 | 4.32M | 1656 |       479 | 382.01K | 3483 |   74.0 | 5.0 |  19.7 | 133.5 | "31,41,51,61,71,81" | 0:01'41'' | 0:00'51'' |


Table: statMRTadpoleAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  99.07% |     42221 | 5.06M | 252 |       415 |  86.2K | 493 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'57'' |
| MRX40P001 |   40.0 |  98.98% |     40797 | 5.06M | 266 |       364 | 78.87K | 456 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'55'' |
| MRX40P002 |   40.0 |  98.99% |     38003 | 5.06M | 232 |       282 |  70.1K | 413 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'54'' |
| MRX40P003 |   40.0 |  99.12% |     40020 | 5.05M | 259 |       466 | 89.42K | 480 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'56'' |
| MRX80P000 |   80.0 |  98.84% |     36210 | 5.08M | 254 |       122 | 56.98K | 567 |   78.0 | 2.0 |  20.0 | 126.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'58'' |
| MRX80P001 |   80.0 |  98.72% |     42535 | 5.09M | 229 |        85 | 41.35K | 496 |   78.0 | 3.0 |  20.0 | 130.5 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'56'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |  98.52% |     48563 | 5.11M | 198 |      1903 | 920.54K | 536 |  192.0 | 8.0 |  20.0 | 324.0 | 0:01'23'' |
| 7_mergeKunitigsAnchors   |  99.13% |     18969 | 5.18M | 490 |      1649 |    1.4M | 904 |  189.0 | 9.0 |  20.0 | 324.0 | 0:01'51'' |
| 7_mergeMRKunitigsAnchors |  98.97% |     26975 | 5.14M | 368 |      1108 | 248.11K | 220 |  191.0 | 9.0 |  20.0 | 327.0 | 0:01'30'' |
| 7_mergeMRTadpoleAnchors  |  99.07% |     46327 | 5.08M | 210 |      1230 |  87.16K |  73 |  193.0 | 7.0 |  20.0 | 321.0 | 0:01'30'' |
| 7_mergeTadpoleAnchors    |  99.23% |     41508 | 5.09M | 257 |      1745 | 886.58K | 592 |  192.0 | 8.0 |  20.0 | 324.0 | 0:01'55'' |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median |  MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|-----:|------:|------:|----------:|
| 8_spades     |  98.30% |     37551 | 5.07M |  250 |       267 |  53.95K |  285 |  194.0 |  5.0 |  20.0 | 313.5 | 0:01'00'' |
| 8_spades_MR  |  92.86% |      4899 | 4.98M | 1334 |        42 | 116.82K | 2692 |  167.0 | 11.0 |  20.0 | 300.0 | 0:00'56'' |
| 8_megahit    |  98.12% |     38065 | 5.08M |  250 |       171 |  42.54K |  312 |  193.0 |  6.0 |  20.0 | 316.5 | 0:01'00'' |
| 8_megahit_MR |  99.30% |    107093 | 5.13M |   82 |       164 |  10.26K |  124 |  171.0 |  4.0 |  20.0 | 274.5 | 0:00'56'' |
| 8_platanus   |  98.19% |     33665 | 5.07M |  304 |       394 |  54.32K |  423 |  194.0 |  6.0 |  20.0 | 318.0 | 0:01'01'' |


Table: statFinal

| Name                     |     N50 |     Sum |    # |
|:-------------------------|--------:|--------:|-----:|
| Genome                   | 5067172 | 5090491 |    2 |
| Paralogs                 |    1580 |   83364 |   53 |
| 7_mergeAnchors.anchors   |   48563 | 5105137 |  198 |
| 7_mergeAnchors.others    |    1903 |  920543 |  536 |
| anchorLong               |   56274 | 5096245 |  149 |
| anchorFill               |  275092 | 5114442 |   37 |
| spades.contig            |  278433 | 5270502 |  373 |
| spades.scaffold          |  313428 | 5270642 |  368 |
| spades.non-contained     |  280141 | 5128211 |   35 |
| spades_MR.contig         |    4472 | 5677874 | 3159 |
| spades_MR.scaffold       |    4493 | 5678194 | 3154 |
| spades_MR.non-contained  |    4934 | 5094833 | 1360 |
| megahit.contig           |  149450 | 5217972 |  332 |
| megahit.non-contained    |  149450 | 5119453 |   62 |
| megahit_MR.contig        |  166809 | 5156627 |   93 |
| megahit_MR.non-contained |  166809 | 5136199 |   45 |
| platanus.contig          |   24882 | 5184761 |  512 |
| platanus.scaffold        |   75636 | 5132291 |  156 |
| platanus.non-contained   |   79719 | 5119593 |  120 |


# *Vibrio cholerae* CP1032(5) Full

## VchoF: download

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

rm -f *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 4033464 \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --trim2 "--dedupe" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,3" \
    --cov2 "40 80" \
    --tadpole \
    --redoanchors \
    --fillanchor \
    --parallel 24 \
    --xmx 110g

```

## VchoF: run


```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=VchoF

cd ${WORKING_DIR}/${BASE_NAME}
#rm -fr 4_*/ 6_*/ 7_*/ 8_*/ 2_illumina/trim 2_illumina/mergereads statReads.md 

bash 0_bsub.sh
#bkill -J "${BASE_NAME}-*"

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

