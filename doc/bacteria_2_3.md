# Bacteria 2+3

[TOC levels=1-3]: # " "
- [Bacteria 2+3](#bacteria-23)
- [Vibrio parahaemolyticus ATCC BAA-239, 副溶血弧菌](#vibrio-parahaemolyticus-atcc-baa-239-副溶血弧菌)
    - [Vpar: download](#vpar-download)
    - [Vpar: run](#vpar-run)
- [Legionella pneumophila subsp. pneumophila ATCC 33152D-5; Philadelphia-1, 嗜肺军团菌](#legionella-pneumophila-subsp-pneumophila-atcc-33152d-5-philadelphia-1-嗜肺军团菌)
    - [Lpne: download](#lpne-download)
    - [Lpne: run](#lpne-run)
- [Neisseria gonorrhoeae FDAARGOS_207, 淋病奈瑟氏菌](#neisseria-gonorrhoeae-fdaargos_207-淋病奈瑟氏菌)
    - [Ngon: download](#ngon-download)
    - [Ngon: run](#ngon-run)
- [Neisseria meningitidis FDAARGOS_209, 脑膜炎奈瑟氏菌](#neisseria-meningitidis-fdaargos_209-脑膜炎奈瑟氏菌)
    - [Nmen: download](#nmen-download)
    - [Nmen: run](#nmen-run)
- [Bordetella pertussis FDAARGOS_195, 百日咳博德特氏杆菌](#bordetella-pertussis-fdaargos_195-百日咳博德特氏杆菌)
    - [Bper: download](#bper-download)
    - [Bper: run](#bper-run)
- [Corynebacterium diphtheriae FDAARGOS_197, 白喉杆菌](#corynebacterium-diphtheriae-fdaargos_197-白喉杆菌)
    - [Cdip: download](#cdip-download)
    - [Cdip: run](#cdip-run)
- [Francisella tularensis FDAARGOS_247, 土拉热弗朗西斯氏菌](#francisella-tularensis-fdaargos_247-土拉热弗朗西斯氏菌)
    - [Ftul: download](#ftul-download)
    - [Ftul: run](#ftul-run)
- [Shigella flexneri NCTC0001, 福氏志贺氏菌](#shigella-flexneri-nctc0001-福氏志贺氏菌)
    - [Sfle: download](#sfle-download)
    - [Sfle: run](#sfle-run)
- [Haemophilus influenzae FDAARGOS_199, 流感嗜血杆菌](#haemophilus-influenzae-fdaargos_199-流感嗜血杆菌)
    - [Hinf: download](#hinf-download)
    - [Hinf: run](#hinf-run)
- [Listeria monocytogenes FDAARGOS_351, 单核细胞增生李斯特氏菌](#listeria-monocytogenes-fdaargos_351-单核细胞增生李斯特氏菌)
    - [Lmon: download](#lmon-download)
    - [Lmon: template](#lmon-template)
    - [Lmon: run](#lmon-run)
- [Clostridioides difficile 630](#clostridioides-difficile-630)
    - [Cdif: download](#cdif-download)
    - [Cdif: template](#cdif-template)
    - [Cdif: run](#cdif-run)
- [Campylobacter jejuni subsp. jejuni ATCC 700819, 空肠弯曲杆菌](#campylobacter-jejuni-subsp-jejuni-atcc-700819-空肠弯曲杆菌)
    - [Cjej: download](#cjej-download)
    - [Cjej: template](#cjej-template)
    - [Cjej: run](#cjej-run)
- [Escherichia virus Lambda](#escherichia-virus-lambda)
    - [lambda: download](#lambda-download)
    - [lambda: run](#lambda-run)


* Rsync to hpc

```bash
#for D in Vpar Lpne Ngon Nmen Bper Cdip Ftul Sfle Hinf Lmon Cdif Cjej; do
for D in Cdif; do
    rsync -avP \
        --exclude="*_hdf5.tgz" \
        ~/data/anchr/${D}/ \
        wangq@202.119.37.251:data/anchr/${D}
done

for D in Vpar Lpne Ngon Nmen Bper Cdip Ftul Sfle Hinf Lmon Cdif Cjej; do
    rsync -avP \
        wangq@202.119.37.251:data/anchr/${D}/ \
        ~/data/anchr/${D}
done

```

# Vibrio parahaemolyticus ATCC BAA-239, 副溶血弧菌

Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Vpar: download

* Reference genome

    * Strain: Vibrio parahaemolyticus RIMD 2210633
    * Taxid: [223926](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=223926)
    * RefSeq assembly accession:
      [GCF_000196095.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/196/095/GCF_000196095.1_ASM19609v1/GCF_000196095.1_ASM19609v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0225

```bash
mkdir -p ~/data/anchr/Vpar/1_genome
cd ~/data/anchr/Vpar/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/196/095/GCF_000196095.1_ASM19609v1/GCF_000196095.1_ASM19609v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_004603.1${TAB}1
NC_004605.1${TAB}2
EOF

faops replace GCF_000196095.1_ASM19609v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Vpar/Vpar.multi.fas paralogs.fa

```

* Illumina

    * [SRX2165170](https://www.ncbi.nlm.nih.gov/sra/SRX2165170)

```bash
mkdir -p ~/data/anchr/Vpar/2_illumina
cd ~/data/anchr/Vpar/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR424/005/SRR4244665/SRR4244665_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR424/005/SRR4244665/SRR4244665_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
e18d81e9d1e6776e3af8a7c077ca68c8 SRR4244665_1.fastq.gz
d1c22a57ff241fef3c8e98a2b1f51441 SRR4244665_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s SRR4244665_1.fastq.gz R1.fq.gz
ln -s SRR4244665_2.fastq.gz R2.fq.gz

```

* PacBio

```bash
mkdir -p ~/data/anchr/Vpar/3_pacbio
cd ~/data/anchr/Vpar/3_pacbio

# download from sra
cat <<EOF > hdf5.txt
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR4244666_SRR4244666_hdf5.tgz
EOF
aria2c -x 9 -s 3 -c -i hdf5.txt

# untar
mkdir -p ~/data/anchr/Vpar/3_pacbio/untar
cd ~/data/anchr/Vpar/3_pacbio
tar xvfz SRR4244666_SRR4244666_hdf5.tgz --directory untar

# convert .bax.h5 to .subreads.bam
mkdir -p ~/data/anchr/Vpar/3_pacbio/bam
cd ~/data/anchr/Vpar/3_pacbio/bam

source ~/share/pitchfork/deployment/setup-env.sh
for movie in m150515;
do 
    bax2bam ~/data/anchr/Vpar/3_pacbio/untar/${movie}*.bax.h5
done

# convert .subreads.bam to fasta
mkdir -p ~/data/anchr/Vpar/3_pacbio/fasta

for movie in m150515;
do
    if [ ! -e ~/data/anchr/Vpar/3_pacbio/bam/${movie}*.subreads.bam ]; then
        continue
    fi

    samtools fasta \
        ~/data/anchr/Vpar/3_pacbio/bam/${movie}*.subreads.bam \
        > ~/data/anchr/Vpar/3_pacbio/fasta/${movie}.fasta
done

cd ~/data/anchr/Vpar
cat 3_pacbio/fasta/*.fasta > 3_pacbio/pacbio.fasta

faops n50 3_pacbio/pacbio.fasta

rm -fr ~/data/anchr/Vpar/3_pacbio/untar
```

## Vpar: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Vpar
QUEUE_NAME=mpi

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 5165770 \
    --trim2 "--uniq --bbduk" \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,artifact" \
    --tadpole \
    --cov3 "80 all" \
    --qual3 "trim" \
    --mergereads \
    --ecphase "1,2,3" \
    --insertsize \
    --parallel 24

# run
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

```

Table: statInsertSize

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 507.5 |    385 | 2113.5 |                         49.20% |
| tadpole.bbtools | 392.1 |    383 |  110.6 |                         46.18% |
| genome.picard   | 394.0 |    385 |  110.5 |                             FR |
| tadpole.picard  | 391.8 |    383 |  110.2 |                             FR |


Table: statReads

| Name      |     N50 |     Sum |        # |
|:----------|--------:|--------:|---------:|
| Genome    | 3288558 | 5165770 |        2 |
| Paralogs  |    3333 |  155714 |       62 |
| Illumina  |     101 |   1.37G | 13551762 |
| uniq      |     101 |   1.36G | 13483004 |
| bbduk     |     100 |   1.35G | 13482890 |
| Q25L60    |     100 |   1.23G | 12517690 |
| Q30L60    |     100 |   1.13G | 11613864 |
| PacBio    |   11771 |   1.23G |   143537 |
| X80.raw   |   11822 | 413.26M |    48766 |
| X80.trim  |   10678 | 355.44M |    41795 |
| Xall.raw  |   11771 |   1.23G |   143537 |
| Xall.trim |   10770 |   1.08G |   125808 |

```text
#trimmedReads
#Matched	6840	0.05073%
#Name	Reads	ReadsPct
Reverse_adapter	1124	0.00834%
```


Table: statMergeReads

| Name         | N50 |     Sum |        # |
|:-------------|----:|--------:|---------:|
| clumped      | 101 |   1.36G | 13482770 |
| trimmed      | 100 |   1.27G | 12822004 |
| filtered     | 100 |   1.27G | 12811962 |
| ecco         | 100 |   1.27G | 12811962 |
| eccc         | 100 |   1.27G | 12811962 |
| ecct         | 100 |   1.26G | 12669698 |
| extended     | 140 |   1.76G | 12669698 |
| merged       | 374 |   1.15G |  3286513 |
| unmerged.raw | 140 | 844.72M |  6096672 |
| unmerged     | 140 | 791.92M |  5830084 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 156.4 |    161 |  22.6 |          2.39% |
| ihist.merge.txt  | 351.3 |    365 |  60.0 |         51.88% |

```text
#trimmedReads
#Matched	6840	0.05073%
#Name	Reads	ReadsPct
Reverse_adapter	1124	0.00834%
```

```text
#filteredReads
#Matched	9817	0.07656%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	9592	0.07481%
contam_239	223	0.00174%
```


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 239.2 |  222.6 |    6.91% |      99 | "71" | 5.17M | 5.51M |     1.07 | 0:02'48'' |
| Q30L60 | 219.2 |  205.7 |    6.14% |      98 | "71" | 5.17M | 5.41M |     1.05 | 0:02'32'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |  98.13% |    104237 | 5.04M |  98 |        27 | 13.92K | 540 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'58'' |
| Q25L60X40P001 |   40.0 |  98.15% |     99544 | 5.04M | 100 |        26 | 13.11K | 546 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:01'00'' |
| Q25L60X40P002 |   40.0 |  98.26% |     99575 | 5.04M | 104 |        26 | 14.04K | 586 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:01'03'' |
| Q25L60X40P003 |   40.0 |  98.27% |     93484 | 5.04M | 101 |        27 |  13.7K | 567 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:01'05'' |
| Q25L60X40P004 |   40.0 |  98.29% |    104235 | 5.04M |  91 |        25 |  11.9K | 538 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'52'' | 0:01'04'' |
| Q25L60X80P000 |   80.0 |  97.94% |     82786 | 5.04M | 126 |        25 |   7.2K | 315 |   76.0 | 7.0 |  18.3 | 145.5 | "31,41,51,61,71,81" | 0:01'17'' | 0:00'55'' |
| Q25L60X80P001 |   80.0 |  97.89% |     76009 | 5.04M | 130 |        25 |  7.02K | 318 |   77.0 | 8.0 |  17.7 | 151.5 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'56'' |
| Q30L60X40P000 |   40.0 |  98.40% |    143191 | 5.04M |  82 |        26 | 13.54K | 534 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:01'05'' |
| Q30L60X40P001 |   40.0 |  98.35% |    105136 | 5.04M |  90 |        31 | 18.09K | 581 |   38.0 | 3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:00'51'' | 0:01'03'' |
| Q30L60X40P002 |   40.0 |  98.30% |    152439 | 5.04M |  83 |        28 |  13.4K | 523 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:01'04'' |
| Q30L60X40P003 |   40.0 |  98.45% |    152464 | 5.04M |  84 |        29 | 16.59K | 561 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:01'08'' |
| Q30L60X40P004 |   40.0 |  98.45% |    143132 | 5.04M |  85 |        29 | 15.62K | 551 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:01'06'' |
| Q30L60X80P000 |   80.0 |  98.25% |    105166 | 5.04M |  96 |        24 |  7.38K | 327 |   77.0 | 8.0 |  17.7 | 151.5 | "31,41,51,61,71,81" | 0:01'18'' | 0:01'02'' |
| Q30L60X80P001 |   80.0 |  98.25% |    119254 | 5.04M |  90 |        26 |  7.36K | 322 |   77.0 | 8.0 |  17.7 | 151.5 | "31,41,51,61,71,81" | 0:01'19'' | 0:01'03'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |  # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|---:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |  98.43% |    152458 | 5.04M | 82 |        32 | 17.55K | 533 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:01'04'' |
| Q25L60X40P001 |   40.0 |  98.27% |    104228 | 5.04M | 84 |        28 | 14.15K | 498 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:01'03'' |
| Q25L60X40P002 |   40.0 |  98.24% |    140910 | 5.04M | 86 |        29 | 14.41K | 507 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:01'03'' |
| Q25L60X40P003 |   40.0 |  98.23% |    152459 | 5.04M | 85 |        31 | 15.89K | 520 |   38.5 | 3.5 |   9.3 |  73.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:01'01'' |
| Q25L60X40P004 |   40.0 |  98.22% |    143024 | 5.04M | 86 |        28 | 13.42K | 477 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:01'04'' |
| Q25L60X80P000 |   80.0 |  98.18% |    155679 | 5.04M | 80 |        36 | 13.39K | 319 |   74.5 | 6.5 |  18.3 | 141.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:01'01'' |
| Q25L60X80P001 |   80.0 |  98.06% |    123817 | 5.04M | 86 |        26 |  7.96K | 324 |   74.0 | 6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:01'03'' | 0:01'00'' |
| Q30L60X40P000 |   40.0 |  98.35% |    152449 | 5.04M | 80 |        29 | 16.33K | 551 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:01'05'' |
| Q30L60X40P001 |   40.0 |  98.42% |    152465 | 5.03M | 82 |        29 | 15.94K | 568 |   38.0 | 3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:00'45'' | 0:01'07'' |
| Q30L60X40P002 |   40.0 |  98.39% |    143017 | 5.04M | 86 |        33 | 18.74K | 542 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:01'05'' |
| Q30L60X40P003 |   40.0 |  98.48% |    174954 | 5.04M | 80 |        31 | 18.65K | 581 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:01'11'' |
| Q30L60X40P004 |   40.0 |  98.40% |    155659 | 5.03M | 78 |        27 | 15.02K | 559 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:01'05'' |
| Q30L60X80P000 |   80.0 |  98.23% |    143199 | 5.04M | 81 |        28 |  9.62K | 357 |   77.0 | 7.0 |  18.7 | 147.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:01'01'' |
| Q30L60X80P001 |   80.0 |  98.35% |    174953 | 5.04M | 74 |        27 |  9.42K | 381 |   76.0 | 7.0 |  18.3 | 145.5 | "31,41,51,61,71,81" | 0:00'54'' | 0:01'07'' |


Table: statCanu

| Name                |     N50 |     Sum |     # |
|:--------------------|--------:|--------:|------:|
| Genome              | 3288558 | 5165770 |     2 |
| Paralogs            |    3333 |  155714 |    62 |
| X80.trim.corrected  |   11981 | 201.86M | 17420 |
| Xall.trim.corrected |   19088 | 201.72M | 10514 |
| X80.trim.contig     | 3316838 | 5204553 |     2 |
| Xall.trim.contig    | 3292632 | 5188352 |     2 |


Table: statFinal

| Name                           |     N50 |     Sum |    # |
|:-------------------------------|--------:|--------:|-----:|
| Genome                         | 3288558 | 5165770 |    2 |
| Paralogs                       |    3333 |  155714 |   62 |
| 7_mergeKunitigsAnchors.anchors |  179401 | 5048362 |   73 |
| 7_mergeKunitigsAnchors.others  |    1026 |   19526 |   19 |
| 7_mergeTadpoleAnchors.anchors  |  179401 | 5071318 |   74 |
| 7_mergeTadpoleAnchors.others   |    1026 |   52540 |   44 |
| 7_mergeAnchors.anchors         |  179401 | 5071506 |   74 |
| 7_mergeAnchors.others          |    1026 |   52540 |   44 |
| anchorLong                     |  208156 | 5069045 |   63 |
| anchorFill                     |  561544 | 5117884 |   15 |
| canu_X80-trim                  | 3316838 | 5204553 |    2 |
| canu_Xall-trim                 | 3292632 | 5188352 |    2 |
| spades.contig                  |  168229 | 6511092 | 3811 |
| spades.scaffold                |  288633 | 6520047 | 3554 |
| spades.non-contained           |  288633 | 5155371 |  118 |
| megahit.contig                 |  175010 | 5153632 |  322 |
| megahit.non-contained          |  179337 | 5060443 |   78 |
| megahit.anchor                 |  179311 | 5043964 |   72 |
| platanus.contig                |  196704 | 5150830 |  612 |
| platanus.scaffold              |  339534 | 5133136 |  431 |
| platanus.non-contained         |  426844 | 5060747 |   35 |
| platanus.anchor                |  426811 | 5058049 |   38 |


# Legionella pneumophila subsp. pneumophila ATCC 33152D-5; Philadelphia-1, 嗜肺军团菌

Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Lpne: download

* Reference genome

    * Strain: Legionella pneumophila subsp. pneumophila str. Philadelphia 1
    * Taxid:
      [272624](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=272624&lvl=3&lin=f&keep=1&srchmode=1&unlock)
    * RefSeq assembly accession:
      [GCF_000008485.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/485/GCF_000008485.1_ASM848v1/GCF_000008485.1_ASM848v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0264

```bash
mkdir -p ~/data/anchr/Lpne/1_genome
cd ~/data/anchr/Lpne/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/485/GCF_000008485.1_ASM848v1/GCF_000008485.1_ASM848v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_002942.5${TAB}1
EOF

faops replace GCF_000008485.1_ASM848v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Lpne/Lpne.multi.fas paralogs.fa

```

* Illumina

    * [SRX2179279](https://www.ncbi.nlm.nih.gov/sra/SRX2179279) SRR4272054

```bash
mkdir -p ~/data/anchr/Lpne/2_illumina
cd ~/data/anchr/Lpne/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR427/004/SRR4272054/SRR4272054_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR427/004/SRR4272054/SRR4272054_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
6391a189c30acde364eb553e1f592a81 SRR4272054_1.fastq.gz
67ec48fd2c37e09b35f232f262c46d15 SRR4272054_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s SRR4272054_1.fastq.gz R1.fq.gz
ln -s SRR4272054_2.fastq.gz R2.fq.gz

```

* PacBio

```bash
mkdir -p ~/data/anchr/Lpne/3_pacbio
cd ~/data/anchr/Lpne/3_pacbio

# download from sra
cat <<EOF > hdf5.txt
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR4272055_SRR4272055_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR4272056_SRR4272056_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR4272057_SRR4272057_hdf5.tgz
EOF
aria2c -x 9 -s 3 -c -i hdf5.txt

# untar
mkdir -p ~/data/anchr/Lpne/3_pacbio/untar
cd ~/data/anchr/Lpne/3_pacbio
tar xvfz SRR4272055_SRR4272055_hdf5.tgz --directory untar
tar xvfz SRR4272056_SRR4272056_hdf5.tgz --directory untar
tar xvfz SRR4272057_SRR4272057_hdf5.tgz --directory untar

# convert .bax.h5 to .subreads.bam
mkdir -p ~/data/anchr/Lpne/3_pacbio/bam
cd ~/data/anchr/Lpne/3_pacbio/bam

source ~/share/pitchfork/deployment/setup-env.sh
for movie in m141027 m141028 m150113;
do 
    bax2bam ~/data/anchr/Lpne/3_pacbio/untar/${movie}*.bax.h5
done

# convert .subreads.bam to fasta
mkdir -p ~/data/anchr/Lpne/3_pacbio/fasta

for movie in m141027 m141028 m150113;
do
    if [ ! -e ~/data/anchr/Lpne/3_pacbio/bam/${movie}*.subreads.bam ]; then
        continue
    fi

    samtools fasta \
        ~/data/anchr/Lpne/3_pacbio/bam/${movie}*.subreads.bam \
        > ~/data/anchr/Lpne/3_pacbio/fasta/${movie}.fasta
done

cd ~/data/anchr/Lpne
cat 3_pacbio/fasta/*.fasta > 3_pacbio/pacbio.fasta

```

## Lpne: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Lpne
QUEUE_NAME=mpi

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 3397754 \
    --trim2 "--uniq --bbduk" \
    --sample 300 \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,artifact" \
    --tadpole \
    --cov3 "80 all" \
    --qual3 "trim" \
    --mergereads \
    --ecphase "1,2,3" \
    --insertsize \
    --parallel 24

# run
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

```

Table: statInsertSize

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 449.5 |    346 | 1919.3 |                         49.31% |
| tadpole.bbtools | 353.6 |    344 |   99.1 |                         46.60% |
| genome.picard   | 355.7 |    346 |   98.8 |                             FR |
| tadpole.picard  | 353.4 |    344 |   98.5 |                             FR |


Table: statReads

| Name      |     N50 |     Sum |        # |
|:----------|--------:|--------:|---------:|
| Genome    | 3397754 | 3397754 |        1 |
| Paralogs  |    2793 |  100722 |       43 |
| Illumina  |     101 |   1.06G | 10498482 |
| uniq      |     101 |   1.06G | 10458252 |
| sample    |     101 |   1.02G | 10092338 |
| bbduk     |     100 |   1.01G | 10092230 |
| Q25L60    |     100 | 907.94M |  9240917 |
| Q30L60    |     100 | 798.07M |  8295278 |
| PacBio    |    8538 | 287.32M |    56763 |
| X80.raw   |    8542 | 271.82M |    53600 |
| X80.trim  |    8354 | 232.88M |    39020 |
| Xall.raw  |    8538 | 287.32M |    56763 |
| Xall.trim |    8357 | 246.63M |    41404 |

```text
#trimmedReads
#Matched	6820	0.06758%
#Name	Reads	ReadsPct
PhiX_read2_adapter	2764	0.02739%
```


Table: statMergeReads

| Name         | N50 |     Sum |        # |
|:-------------|----:|--------:|---------:|
| clumped      | 101 |   1.06G | 10456998 |
| trimmed      | 100 |  990.3M | 10002664 |
| filtered     | 100 |  990.3M | 10002662 |
| ecco         | 100 |  990.3M | 10002662 |
| eccc         | 100 |  990.3M | 10002662 |
| ecct         | 100 | 981.59M |  9913290 |
| extended     | 140 |   1.38G |  9913290 |
| merged       | 357 |   1.09G |  3205041 |
| unmerged.raw | 140 | 483.39M |  3503208 |
| unmerged     | 140 | 434.19M |  3253696 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 155.6 |    160 |  22.7 |          2.70% |
| ihist.merge.txt  | 340.4 |    348 |  57.5 |         64.66% |

```text
#trimmedReads
#Matched	7066	0.06757%
#Name	Reads	ReadsPct
PhiX_read2_adapter	2878	0.02752%
```

```text
#filteredReads
#Matched	1	0.00001%
#Name	Reads	ReadsPct
```


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 267.3 |  246.4 |    7.83% |      98 | "71" |  3.4M | 3.45M |     1.02 | 0:02'02'' |
| Q30L60 | 235.1 |  220.7 |    6.12% |      96 | "71" |  3.4M | 3.41M |     1.00 | 0:01'52'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |  99.15% |     63574 | 3.36M |  96 |        48 | 27.41K | 536 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'49'' |
| Q25L60X40P001 |   40.0 |  99.21% |     89596 | 3.36M |  87 |        42 | 25.04K | 546 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'50'' |
| Q25L60X40P002 |   40.0 |  99.20% |     78450 | 3.36M |  80 |        87 | 28.44K | 497 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'48'' |
| Q25L60X40P003 |   40.0 |  99.25% |     84750 | 3.36M |  85 |        57 | 29.14K | 505 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'49'' |
| Q25L60X40P004 |   40.0 |  99.15% |     77488 | 3.36M |  90 |        48 | 26.71K | 509 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'48'' |
| Q25L60X40P005 |   40.0 |  99.23% |     85009 | 3.36M |  82 |        52 |    30K | 559 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'49'' |
| Q25L60X80P000 |   80.0 |  99.06% |     43517 | 3.35M | 133 |      1795 | 46.01K | 383 |   78.0 | 2.0 |  20.0 | 126.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'46'' |
| Q25L60X80P001 |   80.0 |  99.02% |     55814 | 3.35M | 124 |      2146 | 46.97K | 359 |   79.0 | 2.0 |  20.0 | 127.5 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'45'' |
| Q25L60X80P002 |   80.0 |  99.00% |     39679 | 3.35M | 124 |      2478 | 46.68K | 347 |   79.0 | 2.0 |  20.0 | 127.5 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'45'' |
| Q30L60X40P000 |   40.0 |  99.42% |    116634 | 3.35M |  62 |      1033 | 31.84K | 474 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'55'' |
| Q30L60X40P001 |   40.0 |  99.38% |    131554 | 3.36M |  66 |      1023 | 32.15K | 471 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'52'' |
| Q30L60X40P002 |   40.0 |  99.35% |    118490 | 3.35M |  62 |      1000 | 24.78K | 422 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'50'' |
| Q30L60X40P003 |   40.0 |  99.39% |    103147 | 3.35M |  56 |        61 |  22.9K | 408 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'53'' |
| Q30L60X40P004 |   40.0 |  99.41% |    133041 | 3.35M |  57 |      1029 |  25.4K | 420 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'51'' |
| Q30L60X80P000 |   80.0 |  99.37% |    102240 | 3.35M |  66 |      2483 | 49.27K | 279 |   79.0 | 3.0 |  20.0 | 132.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'51'' |
| Q30L60X80P001 |   80.0 |  99.39% |    142134 | 3.35M |  57 |      1814 | 45.79K | 285 |   79.0 | 2.0 |  20.0 | 127.5 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'54'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |  # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|---:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |  99.28% |    106639 | 3.35M | 58 |      1069 | 23.22K | 337 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'50'' |
| Q25L60X40P001 |   40.0 |  99.24% |    115888 | 3.35M | 55 |        58 | 18.52K | 344 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'50'' |
| Q25L60X40P002 |   40.0 |  99.31% |    132915 | 3.35M | 53 |        72 |  19.8K | 346 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'50'' |
| Q25L60X40P003 |   40.0 |  99.23% |    116635 | 3.35M | 53 |        59 | 19.21K | 341 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'51'' |
| Q25L60X40P004 |   40.0 |  99.30% |    145180 | 3.35M | 51 |        45 | 16.64K | 328 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'51'' |
| Q25L60X40P005 |   40.0 |  99.28% |    114153 | 3.36M | 62 |        50 |  19.4K | 372 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'49'' |
| Q25L60X80P000 |   80.0 |  99.26% |    132942 | 3.35M | 49 |      1658 | 34.94K | 243 |   79.0 | 2.0 |  20.0 | 127.5 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'50'' |
| Q25L60X80P001 |   80.0 |  99.28% |    132955 | 3.36M | 49 |      1645 | 32.74K | 230 |   79.0 | 2.0 |  20.0 | 127.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'52'' |
| Q25L60X80P002 |   80.0 |  99.29% |    138915 | 3.35M | 50 |      1430 | 28.76K | 258 |   79.0 | 1.0 |  20.0 | 123.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'52'' |
| Q30L60X40P000 |   40.0 |  99.36% |    145157 | 3.35M | 55 |      1007 | 24.57K | 400 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'51'' |
| Q30L60X40P001 |   40.0 |  99.36% |    145148 | 3.35M | 52 |       223 | 23.61K | 391 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'52'' |
| Q30L60X40P002 |   40.0 |  99.40% |    114134 | 3.35M | 52 |        67 | 23.68K | 381 |   40.0 | 1.0 |  12.3 |  64.5 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'51'' |
| Q30L60X40P003 |   40.0 |  99.38% |    132336 | 3.35M | 54 |      1013 | 25.89K | 420 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'51'' |
| Q30L60X40P004 |   40.0 |  99.36% |    145152 | 3.35M | 54 |        70 | 19.95K | 375 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'50'' |
| Q30L60X80P000 |   80.0 |  99.42% |    145171 | 3.35M | 49 |      1329 | 37.98K | 291 |   79.0 | 3.0 |  20.0 | 132.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'53'' |
| Q30L60X80P001 |   80.0 |  99.45% |    145182 | 3.35M | 48 |      1331 | 32.28K | 291 |   79.0 | 2.0 |  20.0 | 127.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'54'' |


Table: statCanu

| Name                |     N50 |     Sum |     # |
|:--------------------|--------:|--------:|------:|
| Genome              | 3397754 | 3397754 |     1 |
| Paralogs            |    2793 |  100722 |    43 |
| X80.trim.corrected  |    9535 | 135.09M | 14652 |
| Xall.trim.corrected |    9848 |  135.1M | 13992 |
| X80.trim.contig     | 3403179 | 3403179 |     1 |
| Xall.trim.contig    | 3417657 | 3431477 |     2 |


Table: statFinal

| Name                           |     N50 |     Sum |   # |
|:-------------------------------|--------:|--------:|----:|
| Genome                         | 3397754 | 3397754 |   1 |
| Paralogs                       |    2793 |  100722 |  43 |
| 7_mergeKunitigsAnchors.anchors |  248548 | 3355322 |  36 |
| 7_mergeKunitigsAnchors.others  |    2901 |  101579 |  47 |
| 7_mergeTadpoleAnchors.anchors  |  248548 | 3356138 |  36 |
| 7_mergeTadpoleAnchors.others   |    1856 |  127488 |  70 |
| 7_mergeAnchors.anchors         |  248548 | 3356138 |  36 |
| 7_mergeAnchors.others          |    1856 |  127488 |  70 |
| anchorLong                     |  261825 | 3355296 |  32 |
| anchorFill                     | 1750022 | 3379331 |   6 |
| canu_X80-trim                  | 3403179 | 3403179 |   1 |
| canu_Xall-trim                 | 3417657 | 3431477 |   2 |
| spades.contig                  |  431777 | 3473649 | 255 |
| spades.scaffold                |  431777 | 3473749 | 254 |
| spades.non-contained           |  431777 | 3407506 |  27 |
| spades.anchor                  |  274711 | 3361548 |  21 |
| megahit.contig                 |  248588 | 3411179 |  84 |
| megahit.non-contained          |  248588 | 3395922 |  50 |
| megahit.anchor                 |  248556 | 3351597 |  40 |
| platanus.contig                |  198659 | 3392547 | 210 |
| platanus.scaffold              |  363086 | 3385624 | 144 |
| platanus.non-contained         |  363086 | 3364451 |  22 |
| platanus.anchor                |  274641 | 3357774 |  19 |


# Neisseria gonorrhoeae FDAARGOS_207, 淋病奈瑟氏菌

Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Ngon: download

* Reference genome

    * Strain: Neisseria gonorrhoeae FA 1090
    * Taxid: [242231](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=242231)
    * RefSeq assembly accession:
      [GCF_000006845.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/845/GCF_000006845.1_ASM684v1/GCF_000006845.1_ASM684v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0546

```bash
mkdir -p ~/data/anchr/Ngon/1_genome
cd ~/data/anchr/Ngon/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/845/GCF_000006845.1_ASM684v1/GCF_000006845.1_ASM684v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_002946.2${TAB}1
EOF

faops replace GCF_000006845.1_ASM684v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Ngon/Ngon.multi.fas paralogs.fa

```

SRX2179294 SRX2179295

* Illumina

    * [SRX2179294](https://www.ncbi.nlm.nih.gov/sra/SRX2179294) SRR4272072

```bash
mkdir -p ~/data/anchr/Ngon/2_illumina
cd ~/data/anchr/Ngon/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR427/002/SRR4272072/SRR4272072_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR427/002/SRR4272072/SRR4272072_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
0e6b38963276a1fdc256eb1f843025bc SRR4272072_1.fastq.gz
532bbf1672dec3316a868774f411d50e SRR4272072_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s SRR4272072_1.fastq.gz R1.fq.gz
ln -s SRR4272072_2.fastq.gz R2.fq.gz

```

* PacBio

```bash
mkdir -p ~/data/anchr/Ngon/3_pacbio
cd ~/data/anchr/Ngon/3_pacbio

# download from sra
cat <<EOF > hdf5.txt
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR4272071_SRR4272071_hdf5.tgz
EOF
aria2c -x 9 -s 3 -c -i hdf5.txt

# untar
mkdir -p ~/data/anchr/Ngon/3_pacbio/untar
cd ~/data/anchr/Ngon/3_pacbio
tar xvfz SRR4272071_SRR4272071_hdf5.tgz --directory untar

# convert .bax.h5 to .subreads.bam
mkdir -p ~/data/anchr/Ngon/3_pacbio/bam
cd ~/data/anchr/Ngon/3_pacbio/bam

source ~/share/pitchfork/deployment/setup-env.sh
for movie in m150115;
do 
    bax2bam ~/data/anchr/Ngon/3_pacbio/untar/${movie}*.bax.h5
done

# convert .subreads.bam to fasta
mkdir -p ~/data/anchr/Ngon/3_pacbio/fasta

for movie in m150115;
do
    if [ ! -e ~/data/anchr/Ngon/3_pacbio/bam/${movie}*.subreads.bam ]; then
        continue
    fi

    samtools fasta \
        ~/data/anchr/Ngon/3_pacbio/bam/${movie}*.subreads.bam \
        > ~/data/anchr/Ngon/3_pacbio/fasta/${movie}.fasta
done

cd ~/data/anchr/Ngon
cat 3_pacbio/fasta/*.fasta > 3_pacbio/pacbio.fasta

```

## Ngon: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Ngon
QUEUE_NAME=mpi

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 2153922 \
    --trim2 "--uniq --bbduk" \
    --sample 300 \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,artifact" \
    --tadpole \
    --cov3 "80 all" \
    --qual3 "trim" \
    --mergereads \
    --ecphase "1,2,3" \
    --insertsize \
    --parallel 24

# run
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

```

Table: statInsertSize

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 461.5 |    327 | 2205.0 |                         48.97% |
| tadpole.bbtools | 328.8 |    319 |   92.8 |                         38.66% |
| genome.picard   | 337.3 |    327 |   94.3 |                             FR |
| tadpole.picard  | 328.6 |    319 |   92.8 |                             FR |


Table: statReads

| Name      |     N50 |     Sum |        # |
|:----------|--------:|--------:|---------:|
| Genome    | 2153922 | 2153922 |        1 |
| Paralogs  |    4318 |  142093 |       53 |
| Illumina  |     101 |   1.49G | 14768158 |
| uniq      |     101 |   1.49G | 14707416 |
| sample    |     101 | 646.18M |  6397788 |
| bbduk     |     100 | 639.56M |  6397728 |
| Q25L60    |     100 | 503.81M |  5246923 |
| Q30L60    |     100 | 382.38M |  4141307 |
| PacBio    |   11808 |   1.19G |   137516 |
| X80.raw   |   11668 | 172.32M |    20331 |
| X80.trim  |    9976 | 136.79M |    17440 |
| Xall.raw  |   11808 |   1.19G |   137516 |
| Xall.trim |   10448 | 985.14M |   119743 |

```text
#trimmedReads
#Matched	5702	0.08912%
#Name	Reads	ReadsPct
```


Table: statMergeReads

| Name         | N50 |     Sum |        # |
|:-------------|----:|--------:|---------:|
| clumped      | 101 |   1.49G | 14705318 |
| trimmed      | 100 |   1.28G | 13120174 |
| filtered     | 100 |   1.28G | 13120174 |
| ecco         | 100 |   1.28G | 13120174 |
| eccc         | 100 |   1.28G | 13120174 |
| ecct         | 100 |   1.27G | 13009802 |
| extended     | 140 |   1.79G | 13009802 |
| merged       | 345 |    1.5G |  4562159 |
| unmerged.raw | 140 | 524.43M |  3885484 |
| unmerged     | 140 | 432.11M |  3399148 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 155.1 |    160 |  23.7 |          3.42% |
| ihist.merge.txt  | 329.5 |    334 |  58.3 |         70.13% |

```text
#trimmedReads
#Matched	12856	0.08742%
#Name	Reads	ReadsPct
I5_Nextera_Transposase_1	1848	0.01257%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	1580	0.01074%
Reverse_adapter	1429	0.00972%
TruSeq_Adapter_Index_1_6	1257	0.00855%
```

```text
#filteredReads
#Matched	0	0.00000%
#Name	Reads	ReadsPct
```


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 234.1 |  214.8 |    8.24% |      96 | "51" | 2.15M | 2.08M |     0.96 | 0:01'12'' |
| Q30L60 | 177.9 |  167.1 |    6.05% |      92 | "61" | 2.15M | 2.05M |     0.95 | 0:00'57'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |  96.23% |     14486 | 1.97M | 226 |      1323 | 102.27K | 1108 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'43'' |
| Q25L60X40P001 |   40.0 |  96.43% |     14767 | 1.97M | 217 |      1305 | 111.27K | 1166 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'45'' |
| Q25L60X40P002 |   40.0 |  96.11% |     14765 | 1.96M | 215 |      1095 |  98.35K | 1102 |   38.0 | 3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'42'' |
| Q25L60X40P003 |   40.0 |  96.22% |     15352 | 1.96M | 216 |      1175 |  99.73K | 1059 |   38.0 | 3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'42'' |
| Q25L60X40P004 |   40.0 |  96.32% |     14296 | 1.96M | 219 |      1226 | 107.15K | 1136 |   38.0 | 3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'42'' |
| Q25L60X80P000 |   80.0 |  95.40% |     14826 | 1.96M | 229 |      1361 |   71.5K |  823 |   75.0 | 5.0 |  20.0 | 135.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'42'' |
| Q25L60X80P001 |   80.0 |  95.20% |     13855 | 1.95M | 225 |      1142 |  64.49K |  709 |   76.0 | 5.0 |  20.0 | 136.5 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'40'' |
| Q30L60X40P000 |   40.0 |  96.69% |     14554 | 1.93M | 220 |      1268 | 176.03K | 1288 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'22'' | 0:00'45'' |
| Q30L60X40P001 |   40.0 |  96.71% |     16197 | 1.95M | 210 |      1434 | 177.45K | 1297 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'45'' |
| Q30L60X40P002 |   40.0 |  96.70% |     16347 | 1.94M | 218 |      1335 | 168.31K | 1245 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'22'' | 0:00'45'' |
| Q30L60X40P003 |   40.0 |  96.75% |     16866 | 1.94M | 212 |      1429 |    185K | 1262 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'22'' | 0:00'45'' |
| Q30L60X80P000 |   80.0 |  96.81% |     18526 | 1.93M | 187 |      1265 | 132.46K | 1021 |   75.0 | 7.0 |  18.0 | 144.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'46'' |
| Q30L60X80P001 |   80.0 |  96.78% |     17969 | 1.92M | 193 |      1669 | 187.74K | 1037 |   74.0 | 6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'45'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |  96.50% |     17966 | 1.97M | 200 |      1238 | 103.99K | 1144 |   38.0 | 3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'43'' |
| Q25L60X40P001 |   40.0 |  96.50% |     18450 | 1.97M | 189 |      1176 |   88.5K | 1173 |   37.5 | 3.5 |   9.0 |  72.0 | "31,41,51,61,71,81" | 0:00'27'' | 0:00'43'' |
| Q25L60X40P002 |   40.0 |  96.59% |     18079 | 1.96M | 194 |      1105 | 102.89K | 1144 |   38.0 | 3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'44'' |
| Q25L60X40P003 |   40.0 |  96.49% |     17230 | 1.96M | 202 |      1140 | 112.05K | 1153 |   38.0 | 3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'45'' |
| Q25L60X40P004 |   40.0 |  96.64% |     18806 | 1.99M | 192 |      1201 | 111.15K | 1188 |   38.0 | 3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'44'' |
| Q25L60X80P000 |   80.0 |  96.41% |     20405 | 1.98M | 159 |      1361 |  63.85K |  818 |   76.0 | 6.0 |  19.3 | 141.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'44'' |
| Q25L60X80P001 |   80.0 |  96.46% |     18836 | 1.97M | 171 |      1226 |  79.63K |  823 |   76.0 | 5.0 |  20.0 | 136.5 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'44'' |
| Q30L60X40P000 |   40.0 |  96.39% |     13598 | 1.92M | 256 |      1382 | 185.46K | 1442 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'27'' | 0:00'43'' |
| Q30L60X40P001 |   40.0 |  96.54% |     13697 | 1.93M | 247 |      1304 | 200.32K | 1463 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'27'' | 0:00'44'' |
| Q30L60X40P002 |   40.0 |  96.52% |     11895 | 1.89M | 269 |      1315 | 278.21K | 1464 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'45'' |
| Q30L60X40P003 |   40.0 |  96.57% |     13341 | 1.93M | 263 |      1406 | 194.74K | 1419 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'45'' |
| Q30L60X80P000 |   80.0 |  96.82% |     16216 | 1.94M | 206 |      1397 | 159.63K | 1194 |   75.0 | 7.0 |  18.0 | 144.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'47'' |
| Q30L60X80P001 |   80.0 |  96.87% |     16877 | 1.94M | 199 |      1488 |  168.2K | 1163 |   75.0 | 7.0 |  18.0 | 144.0 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'47'' |


Table: statCanu

| Name                |     N50 |     Sum |    # |
|:--------------------|--------:|--------:|-----:|
| Genome              | 2153922 | 2153922 |    1 |
| Paralogs            |    4318 |  142093 |   53 |
| X80.trim.corrected  |   10333 |  81.38M | 8342 |
| Xall.trim.corrected |   19826 |  80.18M | 4138 |
| X80.trim.contig     | 2205541 | 2205541 |    1 |
| Xall.trim.contig    | 2207006 | 2207006 |    1 |


Table: statFinal

| Name                           |     N50 |     Sum |   # |
|:-------------------------------|--------:|--------:|----:|
| Genome                         | 2153922 | 2153922 |   1 |
| Paralogs                       |    4318 |  142093 |  53 |
| 7_mergeKunitigsAnchors.anchors |   22842 | 1981872 | 144 |
| 7_mergeKunitigsAnchors.others  |    1434 |  312662 | 220 |
| 7_mergeTadpoleAnchors.anchors  |   24281 | 2015557 | 137 |
| 7_mergeTadpoleAnchors.others   |    1365 |  444634 | 317 |
| 7_mergeAnchors.anchors         |   24281 | 2015557 | 137 |
| 7_mergeAnchors.others          |    1365 |  444634 | 317 |
| anchorLong                     |   27506 | 1375927 |  92 |
| anchorFill                     |   47734 | 1459828 |  64 |
| canu_X80-trim                  | 2205541 | 2205541 |   1 |
| canu_Xall-trim                 | 2207006 | 2207006 |   1 |
| spades.contig                  |   50390 | 2133395 | 422 |
| spades.scaffold                |   52412 | 2133435 | 418 |
| spades.non-contained           |   55104 | 2058511 |  79 |
| spades.anchor                  |   40454 | 1991733 |  95 |
| megahit.contig                 |   22866 | 2073891 | 287 |
| megahit.non-contained          |   23014 | 2023720 | 154 |
| megahit.anchor                 |   22979 | 1962652 | 144 |
| platanus.contig                |   19452 | 2140588 | 936 |
| platanus.scaffold              |   44073 | 2108470 | 547 |
| platanus.non-contained         |   46751 | 2033789 |  88 |
| platanus.anchor                |   41937 | 1977787 |  92 |


# Neisseria meningitidis FDAARGOS_209, 脑膜炎奈瑟氏菌

Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Nmen: download

* Reference genome

    * Strain: Neisseria meningitidis MC58
    * Taxid: [122586](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=122586)
    * RefSeq assembly accession:
      [GCF_000008805.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/805/GCF_000008805.1_ASM880v1/GCF_000008805.1_ASM880v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0

```bash
mkdir -p ~/data/anchr/Nmen/1_genome
cd ~/data/anchr/Nmen/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/805/GCF_000008805.1_ASM880v1/GCF_000008805.1_ASM880v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_003112.2${TAB}1
EOF

faops replace GCF_000008805.1_ASM880v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Nmen/Nmen.multi.fas paralogs.fa

```

* Illumina

    * [SRX2179304](https://www.ncbi.nlm.nih.gov/sra/SRX2179304) SRR4272082

```bash
mkdir -p ~/data/anchr/Nmen/2_illumina
cd ~/data/anchr/Nmen/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR427/002/SRR4272082/SRR4272082_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR427/002/SRR4272082/SRR4272082_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
72eda37b3158f5668d6fe8ce62c6db7a SRR4272082_1.fastq.gz
4db52e50a273945315af9aa4582c6dc2 SRR4272082_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s SRR4272082_1.fastq.gz R1.fq.gz
ln -s SRR4272082_2.fastq.gz R2.fq.gz

```

* PacBio

```bash
mkdir -p ~/data/anchr/Nmen/3_pacbio
cd ~/data/anchr/Nmen/3_pacbio

# download from sra
cat <<EOF > hdf5.txt
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR4272081_SRR4272081_hdf5.tgz
EOF
aria2c -x 9 -s 3 -c -i hdf5.txt

# untar
mkdir -p ~/data/anchr/Nmen/3_pacbio/untar
cd ~/data/anchr/Nmen/3_pacbio
tar xvfz SRR4272081_SRR4272081_hdf5.tgz --directory untar

# convert .bax.h5 to .subreads.bam
mkdir -p ~/data/anchr/Nmen/3_pacbio/bam
cd ~/data/anchr/Nmen/3_pacbio/bam

source ~/share/pitchfork/deployment/setup-env.sh
for movie in m150116;
do 
    bax2bam ~/data/anchr/Nmen/3_pacbio/untar/${movie}*.bax.h5
done

# convert .subreads.bam to fasta
mkdir -p ~/data/anchr/Nmen/3_pacbio/fasta

for movie in m150116;
do
    if [ ! -e ~/data/anchr/Nmen/3_pacbio/bam/${movie}*.subreads.bam ]; then
        continue
    fi

    samtools fasta \
        ~/data/anchr/Nmen/3_pacbio/bam/${movie}*.subreads.bam \
        > ~/data/anchr/Nmen/3_pacbio/fasta/${movie}.fasta
done

cd ~/data/anchr/Nmen
cat 3_pacbio/fasta/*.fasta > 3_pacbio/pacbio.fasta

faops n50 3_pacbio/pacbio.fasta

rm -fr ~/data/anchr/Nmen/3_pacbio/untar
```

## Nmen: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Nmen
QUEUE_NAME=mpi

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 2272360 \
    --trim2 "--uniq --bbduk" \
    --sample 300 \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,artifact" \
    --tadpole \
    --cov3 "80 all" \
    --qual3 "trim" \
    --mergereads \
    --ecphase "1,2,3" \
    --insertsize \
    --parallel 24

# run
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

```

Table: statInsertSize

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 447.4 |    328 | 2075.8 |                         48.55% |
| tadpole.bbtools | 327.5 |    318 |   93.4 |                         36.79% |
| genome.picard   | 337.8 |    328 |   95.3 |                             FR |
| tadpole.picard  | 327.2 |    318 |   93.4 |                             FR |


Table: statReads

| Name      |     N50 |     Sum |        # |
|:----------|--------:|--------:|---------:|
| Genome    | 2272360 | 2272360 |        1 |
| Paralogs  |       0 |       0 |        0 |
| Illumina  |     101 |    1.4G | 13814390 |
| uniq      |     101 |   1.39G | 13758358 |
| sample    |     101 | 681.71M |  6749584 |
| bbduk     |     100 | 674.62M |  6749500 |
| Q25L60    |     100 | 537.81M |  5592581 |
| Q30L60    |     100 | 413.88M |  4469471 |
| PacBio    |    9603 | 402.17M |    58711 |
| X80.raw   |    9605 | 181.79M |    26345 |
| X80.trim  |    9133 | 163.29M |    21467 |
| Xall.raw  |    9603 | 402.17M |    58711 |
| Xall.trim |    9188 | 364.96M |    47561 |

```text
#trimmedReads
#Matched	5640	0.08356%
#Name	Reads	ReadsPct
```


Table: statMergeReads

| Name         | N50 |     Sum |        # |
|:-------------|----:|--------:|---------:|
| clumped      | 101 |   1.39G | 13756310 |
| trimmed      | 100 |   1.21G | 12337302 |
| filtered     | 100 |   1.21G | 12337300 |
| ecco         | 100 |   1.21G | 12337300 |
| eccc         | 100 |   1.21G | 12337300 |
| ecct         | 100 |   1.19G | 12161288 |
| extended     | 140 |   1.66G | 12161288 |
| merged       | 344 |   1.35G |  4126799 |
| unmerged.raw | 140 | 524.51M |  3907690 |
| unmerged     | 140 | 436.92M |  3445080 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 154.8 |    160 |  24.3 |          3.68% |
| ihist.merge.txt  | 327.8 |    333 |  59.6 |         67.87% |

```text
#trimmedReads
#Matched	11555	0.08400%
#Name	Reads	ReadsPct
Reverse_adapter	1510	0.01098%
I5_Nextera_Transposase_1	1403	0.01020%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	1256	0.00913%
TruSeq_Adapter_Index_1_6	1076	0.00782%
```

```text
#filteredReads
#Matched	1	0.00001%
#Name	Reads	ReadsPct
```


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 236.9 |  218.1 |    7.95% |      96 | "71" | 2.27M | 3.51M |     1.55 | 0:01'15'' |
| Q30L60 | 182.5 |  171.5 |    6.03% |      93 | "61" | 2.27M | 3.21M |     1.41 | 0:00'59'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |  93.51% |      8057 | 1.99M | 355 |      1059 | 135.49K | 1600 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'44'' |
| Q25L60X40P001 |   40.0 |  93.62% |      8190 |    2M | 356 |      1035 | 123.94K | 1600 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'22'' | 0:00'44'' |
| Q25L60X40P002 |   40.0 |  93.32% |      8053 | 1.99M | 354 |      1108 | 136.65K | 1546 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'43'' |
| Q25L60X40P003 |   40.0 |  93.54% |      7773 | 1.99M | 356 |      1061 | 131.79K | 1619 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'43'' |
| Q25L60X40P004 |   40.0 |  93.63% |      7625 | 1.99M | 376 |      1069 | 143.04K | 1676 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'44'' |
| Q25L60X80P000 |   80.0 |  92.19% |      7580 | 1.97M | 375 |      1312 | 104.63K | 1074 |   74.0 | 5.0 |  19.7 | 133.5 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'41'' |
| Q25L60X80P001 |   80.0 |  92.25% |      7350 | 1.98M | 371 |      1366 | 104.68K | 1060 |   74.0 | 5.0 |  19.7 | 133.5 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'41'' |
| Q30L60X40P000 |   40.0 |  94.03% |      8005 | 1.93M | 332 |      1514 | 248.89K | 1812 |   36.0 | 4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'46'' |
| Q30L60X40P001 |   40.0 |  94.01% |      7899 | 1.94M | 340 |      1512 |  252.1K | 1785 |   36.0 | 4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'22'' | 0:00'45'' |
| Q30L60X40P002 |   40.0 |  94.03% |      7986 | 1.91M | 333 |      1514 | 292.36K | 1809 |   36.5 | 3.5 |   8.7 |  70.5 | "31,41,51,61,71,81" | 0:00'22'' | 0:00'46'' |
| Q30L60X40P003 |   40.0 |  94.00% |      8130 | 1.92M | 326 |      1521 | 253.63K | 1771 |   36.0 | 4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'22'' | 0:00'45'' |
| Q30L60X80P000 |   80.0 |  94.22% |      8572 | 1.94M | 311 |      1706 | 210.05K | 1504 |   73.0 | 7.0 |  17.3 | 141.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'48'' |
| Q30L60X80P001 |   80.0 |  94.02% |      8399 | 1.91M | 300 |      1644 | 228.02K | 1449 |   72.0 | 6.0 |  18.0 | 135.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'46'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |  93.79% |      8321 | 1.98M | 326 |      1303 |    153K | 1693 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'45'' |
| Q25L60X40P001 |   40.0 |  93.76% |      8333 | 1.98M | 323 |      1078 | 150.71K | 1597 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'27'' | 0:00'43'' |
| Q25L60X40P002 |   40.0 |  93.84% |      8268 | 1.96M | 320 |      1149 | 159.94K | 1590 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'43'' |
| Q25L60X40P003 |   40.0 |  93.80% |      8614 | 1.98M | 316 |      1191 | 145.16K | 1612 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'44'' |
| Q25L60X40P004 |   40.0 |  93.90% |      8337 | 1.97M | 326 |      1087 | 158.89K | 1655 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'45'' |
| Q25L60X80P000 |   80.0 |  93.87% |      8928 | 1.98M | 300 |      1365 | 131.42K | 1271 |   73.0 | 5.0 |  19.3 | 132.0 | "31,41,51,61,71,81" | 0:00'32'' | 0:00'44'' |
| Q25L60X80P001 |   80.0 |  94.04% |      8936 | 1.98M | 293 |      1365 |  123.4K | 1278 |   74.0 | 5.0 |  19.7 | 133.5 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'44'' |
| Q30L60X40P000 |   40.0 |  93.74% |      7358 | 1.92M | 362 |      1514 | 276.13K | 1965 |   36.0 | 4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'44'' |
| Q30L60X40P001 |   40.0 |  93.75% |      7377 | 1.92M | 356 |      1481 | 279.32K | 1941 |   36.0 | 4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'46'' |
| Q30L60X40P002 |   40.0 |  93.69% |      7443 | 1.92M | 359 |      1468 | 288.02K | 1911 |   36.0 | 4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'45'' |
| Q30L60X40P003 |   40.0 |  93.78% |      7544 | 1.92M | 358 |      1393 | 274.98K | 1902 |   36.0 | 4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'27'' | 0:00'45'' |
| Q30L60X80P000 |   80.0 |  94.27% |      8236 | 1.95M | 315 |      1584 | 216.17K | 1707 |   73.0 | 8.0 |  16.3 | 145.5 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'47'' |
| Q30L60X80P001 |   80.0 |  94.24% |      8345 | 1.93M | 312 |      1518 | 238.46K | 1697 |   73.0 | 7.0 |  17.3 | 141.0 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'48'' |


Table: statCanu

| Name                |     N50 |     Sum |    # |
|:--------------------|--------:|--------:|-----:|
| Genome              | 2272360 | 2272360 |    1 |
| Paralogs            |       0 |       0 |    0 |
| X80.trim.corrected  |   10334 |  90.08M | 8603 |
| Xall.trim.corrected |   13769 |  90.06M | 6451 |
| X80.trim.contig     | 2196486 | 2196486 |    1 |
| Xall.trim.contig    | 2196899 | 2196899 |    1 |


Table: statFinal

| Name                           |     N50 |     Sum |    # |
|:-------------------------------|--------:|--------:|-----:|
| Genome                         | 2272360 | 2272360 |    1 |
| Paralogs                       |       0 |       0 |    0 |
| 7_mergeKunitigsAnchors.anchors |    9988 | 2028270 |  282 |
| 7_mergeKunitigsAnchors.others  |    1710 |  427182 |  271 |
| 7_mergeTadpoleAnchors.anchors  |    9988 | 2035373 |  283 |
| 7_mergeTadpoleAnchors.others   |    1595 |  562180 |  365 |
| 7_mergeAnchors.anchors         |   10000 | 2034055 |  282 |
| 7_mergeAnchors.others          |    1595 |  562180 |  365 |
| anchorLong                     |    6970 |  634918 |  145 |
| anchorFill                     |    6970 |  643399 |  144 |
| canu_X80-trim                  | 2196486 | 2196486 |    1 |
| canu_Xall-trim                 | 2196899 | 2196899 |    1 |
| spades.contig                  |    5204 | 4248976 | 2262 |
| spades.scaffold                |    5981 | 4253207 | 2016 |
| spades.non-contained           |   13238 | 3658353 |  890 |
| megahit.contig                 |    5708 | 3318801 | 2434 |
| megahit.non-contained          |    8969 | 2322895 |  467 |
| megahit.anchor                 |   10006 | 1988721 |  280 |
| platanus.contig                |    8375 | 2277939 | 1749 |
| platanus.scaffold              |   38878 | 2208111 |  842 |
| platanus.non-contained         |   42273 | 2084986 |   99 |
| platanus.anchor                |   38839 | 2030192 |  117 |


# Bordetella pertussis FDAARGOS_195, 百日咳博德特氏杆菌

* Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

* Other name: ATCC BAA-589D-5; Tohama 1;

* BioSample: [SAMN04875532](https://www.ncbi.nlm.nih.gov/biosample/SAMN04875532)

## Bper: download

* Reference genome

    * Strain: Bordetella pertussis Tohama I
    * Taxid: [257313](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=257313)
    * RefSeq assembly accession:
      [GCF_000195715.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/195/715/GCF_000195715.1_ASM19571v1/GCF_000195715.1_ASM19571v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0201

```bash
mkdir -p ~/data/anchr/Bper/1_genome
cd ~/data/anchr/Bper/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/195/715/GCF_000195715.1_ASM19571v1/GCF_000195715.1_ASM19571v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_002929.2${TAB}1
EOF

faops replace GCF_000195715.1_ASM19571v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Bper/Bper.multi.fas paralogs.fa

```

* Illumina

    * [SRX2179101](https://www.ncbi.nlm.nih.gov/sra/SRX2179101) SRR4271511
    * [SRX2179104](https://www.ncbi.nlm.nih.gov/sra/SRX2179104) SRR4271510

```bash
mkdir -p ~/data/anchr/Bper/2_illumina
cd ~/data/anchr/Bper/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR427/001/SRR4271511/SRR4271511_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR427/001/SRR4271511/SRR4271511_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR427/000/SRR4271510/SRR4271510_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR427/000/SRR4271510/SRR4271510_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
0177ba6d05bfbf8a77f47b56cceb7c2e SRR4271511_1.fastq.gz
bf80b95eef4b86ad09cddec0c323415a SRR4271511_2.fastq.gz
1e52042a69c78ad7e3cd4dde3cc36721 SRR4271510_1.fastq.gz
b4d60d4ec59cc7c6dcd12e235981dfda SRR4271510_2.fastq.gz
EOF

md5sum --check sra_md5.txt

gzip -d -c SRR427151{1,0}_1.fastq.gz | pigz -p 8 -c > R1.fq.gz
gzip -d -c SRR427151{1,0}_2.fastq.gz | pigz -p 8 -c > R2.fq.gz

```

## Bper: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Bper
QUEUE_NAME=mpi

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 4086189 \
    --trim2 "--uniq --bbduk" \
    --sample 300 \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,2,3" \
    --insertsize \
    --parallel 24

# run
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

```

| Name     |     N50 |     Sum |        # |
|:---------|--------:|--------:|---------:|
| Genome   | 4086189 | 4086189 |        1 |
| Paralogs |    1033 |  322667 |      278 |
| Illumina |     101 |   1.67G | 16564638 |
| uniq     |     101 |   1.66G | 16389214 |
| sample   |     101 |   1.23G | 12137196 |
| Q25L60   |     101 | 782.04M |  8077226 |
| Q30L60   |     101 | 623.12M |  6851640 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 191.4 |  175.3 |   8.424% |      97 | "33" | 4.09M | 4.36M |     1.07 | 0:01'32'' |
| Q30L60 | 153.0 |  142.2 |   7.026% |      91 | "31" | 4.09M | 4.21M |     1.03 | 0:01'14'' |

| Name          | CovCor | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |      2297 |  2.1M |  999 |      1049 |   1.24M | 1164 |   40.0 | 11.0 |   2.3 |  80.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'43'' |
| Q25L60X40P001 |   40.0 |      2220 | 2.06M |  994 |      1030 |   1.28M | 1198 |   40.0 | 11.0 |   2.3 |  80.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'43'' |
| Q25L60X40P002 |   40.0 |      2279 | 2.07M |  986 |      1092 |   1.33M | 1227 |   40.0 | 11.0 |   2.3 |  80.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'43'' |
| Q25L60X40P003 |   40.0 |      2648 | 2.37M | 1023 |       996 | 956.89K |  924 |   41.0 | 11.0 |   2.7 |  82.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'43'' |
| Q25L60X80P000 |   80.0 |      2347 | 2.21M | 1041 |      1059 |   1.29M | 1197 |   77.0 | 22.0 |   3.7 | 154.0 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'47'' |
| Q25L60X80P001 |   80.0 |      2435 | 2.32M | 1054 |      1077 |   1.14M | 1076 |   77.0 | 22.0 |   3.7 | 154.0 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'47'' |
| Q30L60X40P000 |   40.0 |      1831 | 1.48M |  817 |      1297 |   1.59M | 1357 |   40.0 | 13.0 |   2.0 |  80.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'40'' |
| Q30L60X40P001 |   40.0 |      1943 |  1.6M |  854 |      1210 |   1.42M | 1263 |   40.0 | 12.0 |   2.0 |  80.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'41'' |
| Q30L60X40P002 |   40.0 |      1913 | 1.58M |  839 |      1259 |   1.38M | 1192 |   41.0 | 11.0 |   2.7 |  82.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'42'' |
| Q30L60X80P000 |   80.0 |      2132 | 1.82M |  922 |      1341 |   1.36M | 1127 |   78.0 | 25.0 |   2.0 | 156.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'44'' |

| Name                   |     N50 |     Sum |    # |
|:-----------------------|--------:|--------:|-----:|
| Genome                 | 4086189 | 4086189 |    1 |
| Paralogs               |    1033 |  322667 |  278 |
| anchors                |    3256 | 3024694 | 1129 |
| others                 |    1358 | 3944701 | 3204 |
| anchorLong             |       0 |       0 |    0 |
| anchorFill             |       0 |       0 |    0 |
| spades.contig          |    3345 | 5552943 | 5020 |
| spades.scaffold        |    3347 | 5558630 | 4612 |
| spades.non-contained   |    6046 | 3859296 |  998 |
| platanus.contig        |    1843 | 3316879 | 4540 |
| platanus.scaffold      |    2930 | 3148318 | 2094 |
| platanus.non-contained |    3494 | 2699210 |  938 |


# Corynebacterium diphtheriae FDAARGOS_197, 白喉杆菌

* Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

* Other name: ATCC 700971D-5; NCTC 13129;

* BioSample: [SAMN04875534](https://www.ncbi.nlm.nih.gov/biosample/SAMN04875534)

## Cdip: download

* Reference genome

    * Strain: Corynebacterium diphtheriae NCTC 13129 (high GC Gram+)
    * Taxid: [257309](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=257309)
    * RefSeq assembly accession:
      [GCF_000195815.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/195/815/GCF_000195815.1_ASM19581v1/GCF_000195815.1_ASM19581v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0180

```bash
mkdir -p ~/data/anchr/Cdip/1_genome
cd ~/data/anchr/Cdip/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/195/815/GCF_000195815.1_ASM19581v1/GCF_000195815.1_ASM19581v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_002935.2${TAB}1
EOF

faops replace GCF_000195815.1_ASM19581v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Cdip/Cdip.multi.fas paralogs.fa

```

* Illumina

    * [SRX2179108](https://www.ncbi.nlm.nih.gov/sra/SRX2179108) SRR4271515

```bash
mkdir -p ~/data/anchr/Cdip/2_illumina
cd ~/data/anchr/Cdip/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR427/005/SRR4271515/SRR4271515_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR427/005/SRR4271515/SRR4271515_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
abb1c4a0140d13fa9513e445ebcb97c6 SRR4271515_1.fastq.gz
0910e7ae9d75f37a08e3b24aa75326ed SRR4271515_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s SRR4271515_1.fastq.gz R1.fq.gz
ln -s SRR4271515_2.fastq.gz R2.fq.gz

```

* PacBio

```bash
mkdir -p ~/data/anchr/Cdip/3_pacbio
cd ~/data/anchr/Cdip/3_pacbio

# download from sra
cat <<EOF > hdf5.txt
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR4271514_SRR4271514_hdf5.tgz
EOF
aria2c -x 9 -s 3 -c -i hdf5.txt

# untar
mkdir -p ~/data/anchr/Cdip/3_pacbio/untar
cd ~/data/anchr/Cdip/3_pacbio
tar xvfz SRR4271514_SRR4271514_hdf5.tgz --directory untar

# convert .bax.h5 to .subreads.bam
mkdir -p ~/data/anchr/Cdip/3_pacbio/bam
cd ~/data/anchr/Cdip/3_pacbio/bam

source ~/share/pitchfork/deployment/setup-env.sh
for movie in m141028;
do 
    bax2bam ~/data/anchr/Cdip/3_pacbio/untar/${movie}*.bax.h5
done

# convert .subreads.bam to fasta
mkdir -p ~/data/anchr/Cdip/3_pacbio/fasta

for movie in m141028;
do
    if [ ! -e ~/data/anchr/Cdip/3_pacbio/bam/${movie}*.subreads.bam ]; then
        continue
    fi

    samtools fasta \
        ~/data/anchr/Cdip/3_pacbio/bam/${movie}*.subreads.bam \
        > ~/data/anchr/Cdip/3_pacbio/fasta/${movie}.fasta
done

cd ~/data/anchr/Cdip
cat 3_pacbio/fasta/*.fasta > 3_pacbio/pacbio.fasta

```

## Cdip: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Cdip
QUEUE_NAME=mpi

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 2488635 \
    --trim2 "--uniq --bbduk" \
    --sample 300 \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,artifact" \
    --tadpole \
    --cov3 "80 all" \
    --qual3 "trim" \
    --mergereads \
    --ecphase "1,2,3" \
    --insertsize \
    --parallel 24

# run
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

```

Table: statInsertSize

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 470.5 |    340 | 2188.3 |                         48.50% |
| tadpole.bbtools | 337.8 |    330 |   99.4 |                         37.50% |
| genome.picard   | 347.7 |    339 |  100.0 |                             FR |
| tadpole.picard  | 337.2 |    329 |   99.2 |                             FR |


Table: statReads

| Name     |     N50 |     Sum |        # |
|:---------|--------:|--------:|---------:|
| Genome   | 4086189 | 4086189 |        1 |
| Paralogs |    1033 |  322667 |      278 |
| Illumina |     101 |   1.67G | 16564638 |
| uniq     |     101 |   1.66G | 16389214 |
| sample   |     101 |   1.23G | 12137196 |
| bbduk    |     100 |   1.21G | 12136812 |
| Q25L60   |     100 | 891.32M |  9365090 |
| Q30L60   |     100 | 619.46M |  6850328 |

```text
#trimmedReads
#Matched	14346	0.11820%
#Name	Reads	ReadsPct
Reverse_adapter	2118	0.01745%
I5_Adapter_Nextera	1539	0.01268%
TruSeq_Adapter_Index_1_6	1510	0.01244%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	1476	0.01216%
I5_Nextera_Transposase_1	1112	0.00916%
```


Table: statMergeReads

| Name         | N50 |     Sum |        # |
|:-------------|----:|--------:|---------:|
| clumped      | 101 |   1.65G | 16379240 |
| trimmed      | 100 |   1.35G | 13912474 |
| filtered     | 100 |   1.35G | 13910130 |
| ecco         | 100 |   1.35G | 13910130 |
| eccc         | 100 |   1.35G | 13910130 |
| ecct         | 100 |   1.33G | 13696356 |
| extended     | 140 |   1.87G | 13696356 |
| merged       | 349 |    1.5G |  4553985 |
| unmerged.raw | 140 | 618.28M |  4588386 |
| unmerged     | 140 | 513.88M |  4075086 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 152.7 |    156 |  23.1 |          3.96% |
| ihist.merge.txt  | 330.4 |    338 |  60.9 |         66.50% |

```text
#trimmedReads
#Matched	19416	0.11854%
#Name	Reads	ReadsPct
Reverse_adapter	2870	0.01752%
I5_Adapter_Nextera	2091	0.01277%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	2005	0.01224%
TruSeq_Adapter_Index_1_6	1996	0.01219%
I5_Nextera_Transposase_1	1524	0.00930%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N701	1170	0.00714%
I7_Nextera_Transposase_2	1161	0.00709%
pcr_dimer	1158	0.00707%
```

```text
#filteredReads
#Matched	2339	0.01681%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	2334	0.01678%
```


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 218.4 |  200.8 |    8.09% |      96 | "33" | 4.09M | 4.43M |     1.08 | 0:02'03'' |
| Q30L60 | 152.1 |  142.1 |    6.58% |      91 | "31" | 4.09M | 4.19M |     1.02 | 0:01'28'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |  89.54% |      2756 | 2.69M | 1113 |      1053 | 512.35K | 3231 |   45.0 |  9.0 |   6.0 |  90.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'47'' |
| Q25L60X40P001 |   40.0 |  89.61% |      2608 | 2.58M | 1113 |      1131 | 661.57K | 3074 |   44.0 |  9.0 |   5.7 |  88.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'44'' |
| Q25L60X40P002 |   40.0 |  89.75% |      2721 | 2.61M | 1099 |      1106 | 586.53K | 3148 |   44.0 |  9.0 |   5.7 |  88.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'47'' |
| Q25L60X40P003 |   40.0 |  89.94% |      2701 | 2.69M | 1119 |      1059 | 507.84K | 3179 |   45.0 |  9.0 |   6.0 |  90.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'45'' |
| Q25L60X40P004 |   40.0 |  89.52% |      2646 | 2.58M | 1102 |      1117 | 642.05K | 3113 |   44.0 |  9.0 |   5.7 |  88.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'45'' |
| Q25L60X80P000 |   80.0 |  89.49% |      2556 | 2.66M | 1166 |      1095 | 722.29K | 3382 |   84.0 | 19.0 |   9.0 | 168.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'50'' |
| Q25L60X80P001 |   80.0 |  90.09% |      2649 | 2.65M | 1138 |      1134 | 805.14K | 3404 |   84.0 | 18.0 |  10.0 | 168.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'49'' |
| Q30L60X40P000 |   40.0 |  88.73% |      2125 | 2.04M | 1039 |      1422 |   1.14M | 2792 |   45.0 |  9.0 |   6.0 |  90.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'42'' |
| Q30L60X40P001 |   40.0 |  88.36% |      2088 | 2.07M | 1044 |      1320 |   1.07M | 2738 |   45.0 |  9.0 |   6.0 |  90.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'44'' |
| Q30L60X40P002 |   40.0 |  88.83% |      2113 | 2.12M | 1068 |      1365 |   1.09M | 2793 |   45.0 |  9.0 |   6.0 |  90.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'43'' |
| Q30L60X80P000 |   80.0 |  90.76% |      2167 | 2.11M | 1043 |      1494 |   1.44M | 2877 |   86.0 | 19.0 |   9.7 | 172.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'46'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |  88.79% |      2731 | 2.58M | 1064 |      1092 | 426.95K | 2883 |   45.0 |  9.0 |   6.0 |  90.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'45'' |
| Q25L60X40P001 |   40.0 |  88.69% |      2775 | 2.56M | 1045 |      1090 | 483.15K | 2816 |   45.0 |  9.0 |   6.0 |  90.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'44'' |
| Q25L60X40P002 |   40.0 |  88.58% |      2772 | 2.51M | 1034 |      1035 | 434.97K | 2886 |   46.0 |  8.0 |   7.3 |  92.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'44'' |
| Q25L60X40P003 |   40.0 |  88.71% |      2778 | 2.52M | 1019 |      1049 | 475.42K | 2835 |   46.0 |  8.0 |   7.3 |  92.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'44'' |
| Q25L60X40P004 |   40.0 |  88.47% |      2732 | 2.51M | 1037 |      1073 | 484.02K | 2803 |   45.0 |  8.0 |   7.0 |  90.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'44'' |
| Q25L60X80P000 |   80.0 |  91.12% |      3027 | 2.74M | 1079 |      1058 | 569.05K | 3179 |   87.0 | 18.0 |  11.0 | 174.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'51'' |
| Q25L60X80P001 |   80.0 |  91.02% |      2948 | 2.69M | 1051 |      1056 | 619.88K | 3166 |   87.0 | 17.0 |  12.0 | 174.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'49'' |
| Q30L60X40P000 |   40.0 |  85.79% |      2022 | 1.96M | 1015 |      1296 | 900.25K | 2672 |   47.0 |  8.0 |   7.7 |  94.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'41'' |
| Q30L60X40P001 |   40.0 |  85.88% |      1970 | 1.99M | 1031 |      1202 | 868.15K | 2680 |   47.0 |  8.0 |   7.7 |  94.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'41'' |
| Q30L60X40P002 |   40.0 |  85.81% |      2092 | 2.07M | 1048 |      1228 | 810.35K | 2672 |   47.0 |  9.0 |   6.7 |  94.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'42'' |
| Q30L60X80P000 |   80.0 |  89.64% |      2240 | 2.18M | 1055 |      1394 |   1.12M | 2916 |   90.0 | 19.0 |  11.0 | 180.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'47'' |


Table: statFinal

| Name                           |     N50 |     Sum |    # |
|:-------------------------------|--------:|--------:|-----:|
| Genome                         | 4086189 | 4086189 |    1 |
| Paralogs                       |    1033 |  322667 |  278 |
| 7_mergeKunitigsAnchors.anchors |    3951 | 3090266 | 1002 |
| 7_mergeKunitigsAnchors.others  |    1466 | 2794181 | 2016 |
| 7_mergeTadpoleAnchors.anchors  |    4140 | 3084002 |  958 |
| 7_mergeTadpoleAnchors.others   |    1439 | 3195405 | 2337 |
| 7_mergeAnchors.anchors         |    4140 | 3084002 |  958 |
| 7_mergeAnchors.others          |    1439 | 3195405 | 2337 |
| spades.contig                  |    3382 | 5503940 | 4947 |
| spades.scaffold                |    3388 | 5509714 | 4546 |
| spades.non-contained           |    6098 | 3838791 |  983 |
| spades.anchor                  |    1947 | 1801183 |  959 |
| megahit.contig                 |    4868 | 3879440 | 1796 |
| megahit.non-contained          |    5403 | 3457291 |  888 |
| megahit.anchor                 |    2367 | 2360592 | 1081 |
| platanus.contig                |    1855 | 3386247 | 4914 |
| platanus.scaffold              |    2988 | 3190417 | 2199 |
| platanus.non-contained         |    3523 | 2730255 |  936 |
| platanus.anchor                |    2755 | 2399236 |  986 |


# Francisella tularensis FDAARGOS_247, 土拉热弗朗西斯氏菌

* Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

* Other name: SHU-S4

* BioSample: [SAMN04875573](https://www.ncbi.nlm.nih.gov/biosample/SAMN04875573)

## Ftul: download

* Reference genome

    * Strain: Francisella tularensis subsp. tularensis SCHU S4 (g-proteobacteria)
    * Taxid: [177416](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=177416)
    * RefSeq assembly accession:
      [GCF_000008985.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/985/GCF_000008985.1_ASM898v1/GCF_000008985.1_ASM898v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0438

```bash
mkdir -p ~/data/anchr/Ftul/1_genome
cd ~/data/anchr/Ftul/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/985/GCF_000008985.1_ASM898v1/GCF_000008985.1_ASM898v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_006570.2${TAB}1
EOF

faops replace GCF_000008985.1_ASM898v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Ftul/Ftul.multi.fas paralogs.fa

```

* Illumina

    * [SRX2105481](https://www.ncbi.nlm.nih.gov/sra/SRX2179108) SRR4124773

```bash
mkdir -p ~/data/anchr/Ftul/2_illumina
cd ~/data/anchr/Ftul/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR412/003/SRR4124773/SRR4124773_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR412/003/SRR4124773/SRR4124773_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
f24d93fab957c01c8501d7b60c1f0e99 SRR4124773_1.fastq.gz
6cdca7f1fb3bbbb811a3c8b9c63dcd3b SRR4124773_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s SRR4124773_1.fastq.gz R1.fq.gz
ln -s SRR4124773_2.fastq.gz R2.fq.gz

```

* PacBio

```bash
mkdir -p ~/data/anchr/Ftul/3_pacbio
cd ~/data/anchr/Ftul/3_pacbio

# download from sra
cat <<EOF > hdf5.txt
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR4124774_SRR4124774_hdf5.tgz
EOF
aria2c -x 9 -s 3 -c -i hdf5.txt

# untar
mkdir -p ~/data/anchr/Ftul/3_pacbio/untar
cd ~/data/anchr/Ftul/3_pacbio
tar xvfz SRR4124774_SRR4124774_hdf5.tgz --directory untar

# convert .bax.h5 to .subreads.bam
mkdir -p ~/data/anchr/Ftul/3_pacbio/bam
cd ~/data/anchr/Ftul/3_pacbio/bam

source ~/share/pitchfork/deployment/setup-env.sh
for movie in m150419;
do 
    bax2bam ~/data/anchr/Ftul/3_pacbio/untar/${movie}*.bax.h5
done

# convert .subreads.bam to fasta
mkdir -p ~/data/anchr/Ftul/3_pacbio/fasta

for movie in m150419;
do
    if [ ! -e ~/data/anchr/Ftul/3_pacbio/bam/${movie}*.subreads.bam ]; then
        continue
    fi

    samtools fasta \
        ~/data/anchr/Ftul/3_pacbio/bam/${movie}*.subreads.bam \
        > ~/data/anchr/Ftul/3_pacbio/fasta/${movie}.fasta
done

cd ~/data/anchr/Ftul
cat 3_pacbio/fasta/*.fasta > 3_pacbio/pacbio.fasta

```

## Ftul: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Ftul
QUEUE_NAME=mpi

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 1892775 \
    --trim2 "--uniq --bbduk" \
    --sample 300 \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,artifact" \
    --tadpole \
    --cov3 "80 all" \
    --qual3 "trim" \
    --mergereads \
    --ecphase "1,2,3" \
    --insertsize \
    --parallel 24

# run
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

```


Table: statInsertSize

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 550.6 |    365 | 2622.0 |                         48.72% |
| tadpole.bbtools | 374.1 |    363 |  122.4 |                         47.60% |
| genome.picard   | 375.5 |    365 |  108.9 |                             FR |
| tadpole.picard  | 373.9 |    363 |  109.1 |                             FR |


Table: statReads

| Name      |     N50 |     Sum |        # |
|:----------|--------:|--------:|---------:|
| Genome    | 1892775 | 1892775 |        1 |
| Paralogs  |   33912 |   93531 |       10 |
| Illumina  |     101 |   2.14G | 21230270 |
| uniq      |     101 |   2.12G | 21019000 |
| sample    |     101 | 567.83M |  5622104 |
| bbduk     |     100 | 562.11M |  5622066 |
| Q25L60    |     100 | 542.62M |  5457418 |
| Q30L60    |     100 | 518.69M |  5262060 |
| PacBio    |   10022 |   1.16G |   151564 |
| X80.raw   |   10012 | 151.42M |    19828 |
| X80.trim  |    9130 | 133.37M |    17725 |
| Xall.raw  |   10022 |   1.16G |   151564 |
| Xall.trim |    9626 |   1.07G |   137266 |

```text
#trimmedReads
#Matched	3691	0.06565%
#Name	Reads	ReadsPct
PhiX_read2_adapter	1195	0.02126%
```


Table: statMergeReads

| Name         | N50 |   Sum |        # |
|:-------------|----:|------:|---------:|
| clumped      | 101 | 2.12G | 21017824 |
| trimmed      | 100 | 2.05G | 20601948 |
| filtered     | 100 | 2.05G | 20601948 |
| ecco         | 100 | 2.05G | 20601948 |
| eccc         | 100 | 2.05G | 20601948 |
| ecct         | 100 | 2.04G | 20503664 |
| extended     | 140 | 2.86G | 20503664 |
| merged       | 361 | 2.06G |  6034675 |
| unmerged.raw | 140 | 1.17G |  8434314 |
| unmerged     | 140 | 1.14G |  8265852 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 154.2 |    159 |  23.7 |          2.74% |
| ihist.merge.txt  | 341.6 |    350 |  59.3 |         58.86% |

```text
#trimmedReads
#Matched	13781	0.06557%
#Name	Reads	ReadsPct
PhiX_read2_adapter	4370	0.02079%
Reverse_adapter	2236	0.01064%
TruSeq_Adapter_Index_1_6	1994	0.00949%
```

```text
#filteredReads
#Matched	0	0.00000%
#Name	Reads	ReadsPct
```


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 286.7 |  274.2 |    4.37% |      99 | "71" | 1.89M | 1.81M |     0.95 | 0:01'16'' |
| Q30L60 | 274.1 |  264.8 |    3.41% |      98 | "71" | 1.89M |  1.8M |     0.95 | 0:01'12'' |


Table: statAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |  # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|---:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |  98.26% |     35201 | 1.76M | 73 |     27554 | 46.55K | 396 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'40'' |
| Q25L60X40P001 |   40.0 |  98.22% |     32764 | 1.76M | 72 |     17331 | 74.99K | 408 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'40'' |
| Q25L60X40P002 |   40.0 |  98.16% |     35064 | 1.76M | 70 |      8386 |  46.6K | 366 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'39'' |
| Q25L60X40P003 |   40.0 |  98.20% |     32334 | 1.76M | 74 |     27554 | 48.95K | 412 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'39'' |
| Q25L60X40P004 |   40.0 |  98.19% |     32740 | 1.76M | 74 |     27554 | 47.25K | 384 |   40.0 | 1.0 |  12.3 |  64.5 | "31,41,51,61,71,81" | 0:00'22'' | 0:00'39'' |
| Q25L60X40P005 |   40.0 |  98.14% |     35184 | 1.76M | 71 |     27554 | 47.38K | 407 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'38'' |
| Q25L60X80P000 |   80.0 |  97.81% |     32691 | 1.76M | 73 |     27554 |  38.6K | 169 |   80.0 | 1.0 |  20.0 | 124.5 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'36'' |
| Q25L60X80P001 |   80.0 |  97.82% |     32159 | 1.76M | 75 |      8386 | 38.69K | 179 |   80.0 | 1.0 |  20.0 | 124.5 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'36'' |
| Q25L60X80P002 |   80.0 |  97.72% |     32355 | 1.76M | 75 |     27554 | 38.14K | 177 |   80.0 | 1.0 |  20.0 | 124.5 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'36'' |
| Q30L60X40P000 |   40.0 |  98.17% |     32754 | 1.76M | 71 |     27554 | 47.07K | 399 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'39'' |
| Q30L60X40P001 |   40.0 |  98.18% |     32350 | 1.76M | 75 |     27554 | 49.61K | 405 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'39'' |
| Q30L60X40P002 |   40.0 |  98.10% |     32767 | 1.76M | 76 |     27554 | 46.83K | 361 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'37'' |
| Q30L60X40P003 |   40.0 |  98.18% |     32742 | 1.76M | 72 |     27554 | 45.82K | 395 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'38'' |
| Q30L60X40P004 |   40.0 |  98.18% |     35190 | 1.76M | 69 |     10361 | 59.45K | 388 |   40.0 | 1.0 |  12.3 |  64.5 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'39'' |
| Q30L60X40P005 |   40.0 |  98.20% |     32771 | 1.76M | 72 |     27554 | 48.26K | 414 |   40.0 | 1.0 |  12.3 |  64.5 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'39'' |
| Q30L60X80P000 |   80.0 |  97.82% |     32716 | 1.76M | 71 |     12575 | 38.12K | 180 |   80.0 | 2.0 |  20.0 | 129.0 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'37'' |
| Q30L60X80P001 |   80.0 |  97.81% |     32712 | 1.76M | 74 |      6354 | 38.82K | 179 |   80.0 | 1.0 |  20.0 | 124.5 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'36'' |
| Q30L60X80P002 |   80.0 |  97.80% |     32775 | 1.76M | 70 |     27554 | 38.66K | 177 |   80.0 | 1.0 |  20.0 | 124.5 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'36'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |  # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|---:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |  98.26% |     35201 | 1.76M | 73 |     27554 | 46.55K | 396 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'40'' |
| Q25L60X40P001 |   40.0 |  98.22% |     32764 | 1.76M | 72 |     17331 | 74.99K | 408 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'40'' |
| Q25L60X40P002 |   40.0 |  98.16% |     35064 | 1.76M | 70 |      8386 |  46.6K | 366 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'39'' |
| Q25L60X40P003 |   40.0 |  98.20% |     32334 | 1.76M | 74 |     27554 | 48.95K | 412 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'39'' |
| Q25L60X40P004 |   40.0 |  98.19% |     32740 | 1.76M | 74 |     27554 | 47.25K | 384 |   40.0 | 1.0 |  12.3 |  64.5 | "31,41,51,61,71,81" | 0:00'22'' | 0:00'39'' |
| Q25L60X40P005 |   40.0 |  98.14% |     35184 | 1.76M | 71 |     27554 | 47.38K | 407 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'38'' |
| Q25L60X80P000 |   80.0 |  97.81% |     32691 | 1.76M | 73 |     27554 |  38.6K | 169 |   80.0 | 1.0 |  20.0 | 124.5 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'36'' |
| Q25L60X80P001 |   80.0 |  97.82% |     32159 | 1.76M | 75 |      8386 | 38.69K | 179 |   80.0 | 1.0 |  20.0 | 124.5 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'36'' |
| Q25L60X80P002 |   80.0 |  97.72% |     32355 | 1.76M | 75 |     27554 | 38.14K | 177 |   80.0 | 1.0 |  20.0 | 124.5 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'36'' |
| Q30L60X40P000 |   40.0 |  98.17% |     32754 | 1.76M | 71 |     27554 | 47.07K | 399 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'39'' |
| Q30L60X40P001 |   40.0 |  98.18% |     32350 | 1.76M | 75 |     27554 | 49.61K | 405 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'39'' |
| Q30L60X40P002 |   40.0 |  98.10% |     32767 | 1.76M | 76 |     27554 | 46.83K | 361 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'37'' |
| Q30L60X40P003 |   40.0 |  98.18% |     32742 | 1.76M | 72 |     27554 | 45.82K | 395 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'38'' |
| Q30L60X40P004 |   40.0 |  98.18% |     35190 | 1.76M | 69 |     10361 | 59.45K | 388 |   40.0 | 1.0 |  12.3 |  64.5 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'39'' |
| Q30L60X40P005 |   40.0 |  98.20% |     32771 | 1.76M | 72 |     27554 | 48.26K | 414 |   40.0 | 1.0 |  12.3 |  64.5 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'39'' |
| Q30L60X80P000 |   80.0 |  97.82% |     32716 | 1.76M | 71 |     12575 | 38.12K | 180 |   80.0 | 2.0 |  20.0 | 129.0 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'37'' |
| Q30L60X80P001 |   80.0 |  97.81% |     32712 | 1.76M | 74 |      6354 | 38.82K | 179 |   80.0 | 1.0 |  20.0 | 124.5 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'36'' |
| Q30L60X80P002 |   80.0 |  97.80% |     32775 | 1.76M | 70 |     27554 | 38.66K | 177 |   80.0 | 1.0 |  20.0 | 124.5 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'36'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |  # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|---:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |  98.13% |     32742 | 1.76M | 72 |     27554 | 48.25K | 349 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'30'' | 0:00'39'' |
| Q25L60X40P001 |   40.0 |  98.13% |     32737 | 1.76M | 72 |     17331 | 75.45K | 348 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'26'' | 0:00'38'' |
| Q25L60X40P002 |   40.0 |  98.10% |     35064 | 1.76M | 73 |     21827 | 74.49K | 336 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'26'' | 0:00'37'' |
| Q25L60X40P003 |   40.0 |  98.04% |     32772 | 1.76M | 76 |     20928 | 77.55K | 343 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'26'' | 0:00'37'' |
| Q25L60X40P004 |   40.0 |  98.15% |     35015 | 1.76M | 73 |     27554 | 48.48K | 330 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'27'' | 0:00'39'' |
| Q25L60X40P005 |   40.0 |  98.06% |     35178 | 1.77M | 77 |     27554 | 47.83K | 333 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'25'' | 0:00'38'' |
| Q25L60X80P000 |   80.0 |  97.85% |     32771 | 1.76M | 69 |     27554 | 38.74K | 175 |   80.0 | 1.0 |  20.0 | 124.5 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'35'' |
| Q25L60X80P001 |   80.0 |  97.80% |     32764 | 1.76M | 70 |     27554 | 38.24K | 163 |   80.0 | 1.0 |  20.0 | 124.5 | "31,41,51,61,71,81" | 0:00'30'' | 0:00'35'' |
| Q25L60X80P002 |   80.0 |  97.86% |     35191 | 1.76M | 68 |     27554 | 38.53K | 173 |   80.0 | 1.0 |  20.0 | 124.5 | "31,41,51,61,71,81" | 0:00'32'' | 0:00'36'' |
| Q30L60X40P000 |   40.0 |  98.11% |     35013 | 1.76M | 75 |     19591 | 75.78K | 351 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'27'' | 0:00'37'' |
| Q30L60X40P001 |   40.0 |  98.06% |     32759 | 1.76M | 75 |     27554 | 47.87K | 343 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'38'' |
| Q30L60X40P002 |   40.0 |  98.14% |     32759 | 1.76M | 71 |     27554 |  46.9K | 334 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'39'' |
| Q30L60X40P003 |   40.0 |  98.12% |     32723 | 1.76M | 74 |     20299 | 74.96K | 352 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'26'' | 0:00'38'' |
| Q30L60X40P004 |   40.0 |  98.11% |     33315 | 1.78M | 74 |     17267 | 78.57K | 352 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'37'' |
| Q30L60X40P005 |   40.0 |  98.09% |     32745 | 1.76M | 75 |     27554 | 46.47K | 384 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'27'' | 0:00'37'' |
| Q30L60X80P000 |   80.0 |  97.97% |     32757 | 1.76M | 69 |     27554 | 38.64K | 181 |   80.0 | 1.0 |  20.0 | 124.5 | "31,41,51,61,71,81" | 0:00'30'' | 0:00'38'' |
| Q30L60X80P001 |   80.0 |  97.98% |     32772 | 1.76M | 69 |     27554 | 39.12K | 191 |   80.0 | 1.0 |  20.0 | 124.5 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'38'' |
| Q30L60X80P002 |   80.0 |  98.06% |     32775 | 1.76M | 70 |     27554 | 39.91K | 227 |   80.0 | 1.0 |  20.0 | 124.5 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'38'' |


Table: statCanu

| Name                |     N50 |     Sum |    # |
|:--------------------|--------:|--------:|-----:|
| Genome              | 1892775 | 1892775 |    1 |
| Paralogs            |   33912 |   93531 |   10 |
| X80.trim.corrected  |   11079 |  73.28M | 6735 |
| Xall.trim.corrected |   22080 |  72.99M | 3284 |
| X80.trim.contig     | 1884029 | 1884029 |    1 |
| Xall.trim.contig    | 1579468 | 1978055 |    3 |


Table: statFinal

| Name                           |     N50 |     Sum |   # |
|:-------------------------------|--------:|--------:|----:|
| Genome                         | 1892775 | 1892775 |   1 |
| Paralogs                       |   33912 |   93531 |  10 |
| 7_mergeKunitigsAnchors.anchors |   35248 | 1801042 |  72 |
| 7_mergeKunitigsAnchors.others  |   27554 |   54112 |  22 |
| 7_mergeTadpoleAnchors.anchors  |   35248 | 1816760 |  72 |
| 7_mergeTadpoleAnchors.others   |    1051 |   83652 |  51 |
| 7_mergeAnchors.anchors         |   35248 | 1801042 |  72 |
| 7_mergeAnchors.others          |   27554 |   54112 |  22 |
| anchorLong                     |   35248 | 1793972 |  70 |
| anchorFill                     | 1427076 | 1849806 |   5 |
| canu_X80-trim                  | 1884029 | 1884029 |   1 |
| canu_Xall-trim                 | 1579468 | 1978055 |   3 |
| spades.contig                  |   37811 | 1808720 |  82 |
| spades.scaffold                |   37811 | 1808740 |  80 |
| spades.non-contained           |   37811 | 1804957 |  67 |
| spades.anchor                  |   37783 | 1761658 |  65 |
| megahit.contig                 |   35249 | 1808047 |  80 |
| megahit.non-contained          |   35249 | 1803464 |  71 |
| megahit.anchor                 |   36686 | 1761564 |  67 |
| platanus.contig                |   35264 | 1808204 | 122 |
| platanus.scaffold              |   37805 | 1805074 |  97 |
| platanus.non-contained         |   37805 | 1798488 |  65 |
| platanus.anchor                |   37777 | 1761617 |  64 |


# Shigella flexneri NCTC0001, 福氏志贺氏菌

Project [ERP005470](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=ERP005470)

## Sfle: download

* Reference genome

    * Strain: Shigella flexneri 2a str. 301
    * Taxid: [198214](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=198214)
    * RefSeq assembly accession:
      [GCF_000006925.2](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/925/GCF_000006925.2_ASM692v2/GCF_000006925.2_ASM692v2_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0870

```bash
mkdir -p ~/data/anchr/Sfle/1_genome
cd ~/data/anchr/Sfle/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/925/GCF_000006925.2_ASM692v2/GCF_000006925.2_ASM692v2_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_004337.2${TAB}1
NC_004851.1${TAB}pCP301
EOF

faops replace GCF_000006925.2_ASM692v2_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Sfle/Sfle.multi.fas paralogs.fa

```

* Illumina

    * [ERX518562](https://www.ncbi.nlm.nih.gov/sra/ERX518562)

```bash
mkdir -p ~/data/anchr/Sfle/2_illumina
cd ~/data/anchr/Sfle/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR559/ERR559526/ERR559526_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR559/ERR559526/ERR559526_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
b79fa3fd3b2fb0370e12b8eb910c0268    ERR559526_1.fastq.gz
30c98d66d10d194c62ace652e757c0f3    ERR559526_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s ERR559526_1.fastq.gz R1.fq.gz
ln -s ERR559526_2.fastq.gz R2.fq.gz

```

* PacBio

```bash
mkdir -p ~/data/anchr/Sfle/3_pacbio
cd ~/data/anchr/Sfle/3_pacbio

# download from sra
cat <<EOF > hdf5.txt
http://sra-download.ncbi.nlm.nih.gov/srapub_files/ERR569654_ERR569654_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/ERR569655_ERR569655_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/ERR569656_ERR569656_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/ERR569657_ERR569657_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/ERR569658_ERR569658_hdf5.tgz
EOF
aria2c -x 9 -s 3 -c -i hdf5.txt

# untar
mkdir -p ~/data/anchr/Sfle/3_pacbio/untar
cd ~/data/anchr/Sfle/3_pacbio
tar xvfz ERR569654_ERR569654_hdf5.tgz --directory untar

# convert .bax.h5 to .subreads.bam
mkdir -p ~/data/anchr/Sfle/3_pacbio/bam
cd ~/data/anchr/Sfle/3_pacbio/bam

source ~/share/pitchfork/deployment/setup-env.sh
for movie in m140529;
do 
    bax2bam ~/data/anchr/Sfle/3_pacbio/untar/${movie}*.bax.h5
done

# convert .subreads.bam to fasta
mkdir -p ~/data/anchr/Sfle/3_pacbio/fasta

for movie in m140529;
do
    if [ ! -e ~/data/anchr/Sfle/3_pacbio/bam/${movie}*.subreads.bam ]; then
        continue
    fi

    samtools fasta \
        ~/data/anchr/Sfle/3_pacbio/bam/${movie}*.subreads.bam \
        > ~/data/anchr/Sfle/3_pacbio/fasta/${movie}.fasta
done

cd ~/data/anchr/Sfle
cat 3_pacbio/fasta/*.fasta > 3_pacbio/pacbio.fasta

rm -fr ~/data/anchr/Sfle/3_pacbio/untar
```

## Sfle: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Sfle
QUEUE_NAME=mpi

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 4828820 \
    --trim2 "--uniq --bbduk" \
    --cov2 "40 80 all" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,artifact" \
    --tadpole \
    --cov3 "all" \
    --qual3 "trim" \
    --mergereads \
    --ecphase "1,2,3" \
    --insertsize \
    --parallel 24

# run
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"


```

Table: statInsertSize

| Group           |   Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|-------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 1375.4 |    500 | 5747.9 |                         47.92% |
| tadpole.bbtools |  499.9 |    482 |  149.7 |                         37.35% |
| genome.picard   |  513.4 |    497 |  152.8 |                             FR |
| tadpole.picard  |  499.4 |    482 |  149.8 |                             FR |


Table: statReads

| Name      |     N50 |     Sum |       # |
|:----------|--------:|--------:|--------:|
| Genome    | 4607202 | 4828820 |       2 |
| Paralogs  |    1377 |  543111 |     334 |
| Illumina  |     150 | 346.45M | 2309646 |
| uniq      |     150 | 346.18M | 2307844 |
| bbduk     |     150 | 346.05M | 2307490 |
| Q25L60    |     150 | 328.13M | 2216360 |
| Q30L60    |     150 | 313.85M | 2131750 |
| PacBio    |    3333 | 432.57M |  170957 |
| Xall.raw  |    3333 | 432.57M |  170957 |
| Xall.trim |    2882 | 257.76M |   95845 |

```text
#trimmedReads
#Matched	1717	0.07440%
#Name	Reads	ReadsPct
```


Table: statMergeReads

| Name         | N50 |     Sum |       # |
|:-------------|----:|--------:|--------:|
| clumped      | 150 | 346.18M | 2307844 |
| trimmed      | 150 | 344.36M | 2304164 |
| filtered     | 150 | 344.36M | 2304156 |
| ecco         | 150 | 344.36M | 2304156 |
| eccc         | 150 | 344.36M | 2304156 |
| ecct         | 150 | 328.88M | 2197576 |
| extended     | 190 | 415.52M | 2197576 |
| merged       | 449 | 213.54M |  499096 |
| unmerged.raw | 190 | 226.17M | 1199384 |
| unmerged     | 190 | 212.79M | 1148716 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 256.7 |    262 |  24.7 |          3.84% |
| ihist.merge.txt  | 427.8 |    437 |  67.2 |         45.42% |

```text
#trimmedReads
#Matched	1717	0.07440%
#Name	Reads	ReadsPct
```

```text
#filteredReads
#Matched	4	0.00017%
#Name	Reads	ReadsPct
```


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 |  68.0 |   64.2 |    5.57% |     148 | "75" | 4.83M | 4.19M |     0.87 | 0:00'44'' |
| Q30L60 |  65.0 |   62.3 |    4.15% |     147 | "75" | 4.83M | 4.19M |     0.87 | 0:00'41'' |


Table: statAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  93.69% |     19616 | 4.06M | 353 |      1055 | 79.82K | 805 |   40.0 | 4.0 |   9.3 |  78.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'49'' |
| Q25L60XallP000 |   64.2 |  93.62% |     18537 | 4.07M | 383 |      1033 | 74.29K | 857 |   65.0 | 6.0 |  15.7 | 124.5 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'47'' |
| Q30L60X40P000  |   40.0 |  94.13% |     28543 | 4.08M | 283 |      1435 | 86.93K | 703 |   40.0 | 4.0 |   9.3 |  78.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'49'' |
| Q30L60XallP000 |   62.3 |  94.06% |     28543 | 4.08M | 284 |      1045 | 67.48K | 669 |   62.0 | 6.0 |  14.7 | 120.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'50'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  93.69% |     19616 | 4.06M | 353 |      1055 | 79.82K | 805 |   40.0 | 4.0 |   9.3 |  78.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'49'' |
| Q25L60XallP000 |   64.2 |  93.62% |     18537 | 4.07M | 383 |      1033 | 74.29K | 857 |   65.0 | 6.0 |  15.7 | 124.5 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'47'' |
| Q30L60X40P000  |   40.0 |  94.13% |     28543 | 4.08M | 283 |      1435 | 86.93K | 703 |   40.0 | 4.0 |   9.3 |  78.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'49'' |
| Q30L60XallP000 |   62.3 |  94.06% |     28543 | 4.08M | 284 |      1045 | 67.48K | 669 |   62.0 | 6.0 |  14.7 | 120.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'50'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  93.78% |     26727 | 4.06M | 299 |      1485 | 77.94K | 673 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'49'' |
| Q25L60XallP000 |   64.2 |  93.48% |     20663 | 4.07M | 341 |      1085 | 72.39K | 714 |   64.0 | 6.0 |  15.3 | 123.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'46'' |
| Q30L60X40P000  |   40.0 |  94.06% |     28731 | 4.08M | 280 |      1433 | 83.16K | 712 |   40.0 | 4.0 |   9.3 |  78.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'49'' |
| Q30L60XallP000 |   62.3 |  93.77% |     28543 | 4.08M | 283 |      1527 | 79.04K | 617 |   62.0 | 6.0 |  14.7 | 120.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'48'' |


Table: statCanu

| Name                |     N50 |     Sum |     # |
|:--------------------|--------:|--------:|------:|
| Genome              | 4607202 | 4828820 |     2 |
| Paralogs            |    1377 |  543111 |   334 |
| Xall.trim.corrected |    2849 | 178.54M | 62704 |
| Xall.trim.contig    |  461950 | 4542043 |    22 |


Table: statFinal

| Name                           |     N50 |     Sum |    # |
|:-------------------------------|--------:|--------:|-----:|
| Genome                         | 4607202 | 4828820 |    2 |
| Paralogs                       |    1377 |  543111 |  334 |
| 7_mergeKunitigsAnchors.anchors |   29020 | 4095467 |  284 |
| 7_mergeKunitigsAnchors.others  |    1741 |   83190 |   46 |
| 7_mergeTadpoleAnchors.anchors  |   29020 | 4097267 |  279 |
| 7_mergeTadpoleAnchors.others   |    1741 |   86439 |   47 |
| 7_mergeAnchors.anchors         |   29020 | 4095467 |  284 |
| 7_mergeAnchors.others          |    1741 |   83190 |   46 |
| anchorLong                     |   29141 | 4079903 |  266 |
| anchorFill                     |  398656 | 4357089 |   29 |
| canu_Xall-trim                 |  461950 | 4542043 |   22 |
| spades.contig                  |   31191 | 4259922 |  562 |
| spades.scaffold                |   34624 | 4260182 |  554 |
| spades.non-contained           |   33440 | 4179156 |  249 |
| spades.anchor                  |   31261 | 4084010 |  265 |
| megahit.contig                 |   29206 | 4221486 |  426 |
| megahit.non-contained          |   29386 | 4148263 |  275 |
| megahit.anchor                 |   29300 | 4060696 |  287 |
| platanus.contig                |   28552 | 4348295 | 1322 |
| platanus.scaffold              |   35092 | 4324965 | 1079 |
| platanus.non-contained         |   35257 | 4171060 |  222 |
| platanus.anchor                |   34548 | 4082129 |  259 |


# Haemophilus influenzae FDAARGOS_199, 流感嗜血杆菌

* Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

* Other name: ATCC 51907D; Rd KW20

* BioSample: [SAMN04875536](https://www.ncbi.nlm.nih.gov/biosample/SAMN04875536)

## Hinf: download

* Reference genome

    * Strain: Haemophilus influenzae Rd KW20 (g-proteobacteria)
    * Taxid: [71421](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=71421)
    * RefSeq assembly accession:
      [GCF_000027305.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/027/305/GCF_000027305.1_ASM2730v1/GCF_000027305.1_ASM2730v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0324

```bash
mkdir -p ~/data/anchr/Hinf/1_genome
cd ~/data/anchr/Hinf/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/027/305/GCF_000027305.1_ASM2730v1/GCF_000027305.1_ASM2730v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_000907.1${TAB}1
EOF

faops replace GCF_000027305.1_ASM2730v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Hinf/Hinf.multi.fas paralogs.fa

```

* Illumina

    * [SRX2104758](https://www.ncbi.nlm.nih.gov/sra/SRX2104758) SRR4123928

```bash
mkdir -p ~/data/anchr/Hinf/2_illumina
cd ~/data/anchr/Hinf/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR412/008/SRR4123928/SRR4123928_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR412/008/SRR4123928/SRR4123928_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
52f3219360843923b3ecf15cef65fd33 SRR4123928_1.fastq.gz
6232cce4e5ac6c608bdf2f58bf5563ea SRR4123928_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s SRR4123928_1.fastq.gz R1.fq.gz
ln -s SRR4123928_2.fastq.gz R2.fq.gz

```

* PacBio

    * [SRX2104759](https://www.ncbi.nlm.nih.gov/sra/SRX2104759) SRR4123929

```bash
mkdir -p ~/data/anchr/Hinf/3_pacbio
cd ~/data/anchr/Hinf/3_pacbio

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR412/009/SRR4123929
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
dea1a26fe2bd72256c29950cfd53f7c9 SRR4123929
EOF

md5sum --check sra_md5.txt

fastq-dump --fasta 0 SRR4123929

ln -s SRR4123929.fasta pacbio.fasta

```

## Hinf: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Hinf
QUEUE_NAME=mpi

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 1830138 \
    --trim2 "--uniq --bbduk" \
    --sample 300 \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,artifact" \
    --tadpole \
    --cov3 "80 all" \
    --qual3 "trim" \
    --mergereads \
    --ecphase "1,2,3" \
    --insertsize \
    --parallel 24

# run
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "ended(${BASE_NAME}-0_master)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

```

Table: statInsertSize

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 393.3 |    266 | 2160.4 |                         48.60% |
| tadpole.bbtools | 273.5 |    265 |   77.8 |                         47.43% |
| genome.picard   | 274.8 |    266 |   77.4 |                             FR |
| tadpole.picard  | 273.5 |    265 |   77.2 |                             FR |


Table: statReads

| Name      |     N50 |     Sum |        # |
|:----------|--------:|--------:|---------:|
| Genome    | 1830138 | 1830138 |        1 |
| Paralogs  |    5432 |   95358 |       29 |
| Illumina  |     101 |   1.24G | 12231248 |
| uniq      |     101 |   1.23G | 12143990 |
| sample    |     101 | 549.04M |  5436052 |
| bbduk     |     100 | 543.45M |  5436004 |
| Q25L60    |     100 | 512.02M |  5181411 |
| Q30L60    |     100 | 474.77M |  4882601 |
| PacBio    |   11870 | 407.42M |   163475 |
| X80.raw   |   11062 | 146.42M |    62532 |
| X80.trim  |   12100 |   70.3M |     7562 |
| Xall.raw  |   11870 | 407.42M |   163475 |
| Xall.trim |   15209 |  241.8M |    22124 |

```text
#trimmedReads
#Matched	4076	0.07498%
#Name	Reads	ReadsPct
PhiX_read2_adapter	1055	0.01941%
```


Table: statMergeReads

| Name         | N50 |     Sum |        # |
|:-------------|----:|--------:|---------:|
| clumped      | 101 |   1.23G | 12143648 |
| trimmed      | 100 |   1.17G | 11780482 |
| filtered     | 100 |   1.17G | 11778418 |
| ecco         | 100 |   1.17G | 11778418 |
| eccc         | 100 |   1.17G | 11778418 |
| ecct         | 100 |   1.16G | 11703532 |
| extended     | 140 |   1.63G | 11703532 |
| merged       | 311 |   1.59G |  5303977 |
| unmerged.raw | 140 | 150.92M |  1095578 |
| unmerged     | 140 | 139.55M |  1036210 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 158.2 |    163 |  21.9 |         10.37% |
| ihist.merge.txt  | 299.2 |    297 |  61.2 |         90.64% |

```text
#trimmedReads
#Matched	9066	0.07466%
#Name	Reads	ReadsPct
PhiX_read2_adapter	2410	0.01985%
Reverse_adapter	1927	0.01587%
TruSeq_Adapter_Index_1_6	1481	0.01220%
```

```text
#filteredReads
#Matched	2062	0.01750%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	2061	0.01750%
```


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG | EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|-----:|---------:|----------:|
| Q25L60 | 279.8 |  266.7 |    4.68% |      99 | "71" | 1.83M | 1.8M |     0.98 | 0:01'11'' |
| Q30L60 | 259.5 |  250.6 |    3.46% |      97 | "71" | 1.83M | 1.8M |     0.98 | 0:01'04'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |  # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|---:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |  99.18% |     55098 | 1.77M | 57 |      1032 | 19.36K | 319 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'39'' |
| Q25L60X40P001 |   40.0 |  99.19% |     54599 | 1.77M | 65 |      1017 | 22.11K | 374 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'40'' |
| Q25L60X40P002 |   40.0 |  99.23% |     44410 | 1.77M | 66 |      1012 | 21.57K | 391 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'39'' |
| Q25L60X40P003 |   40.0 |  99.19% |     55101 | 1.77M | 59 |      1014 | 22.24K | 356 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'37'' |
| Q25L60X40P004 |   40.0 |  99.20% |     58141 | 1.77M | 56 |      1026 | 20.89K | 321 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'38'' |
| Q25L60X40P005 |   40.0 |  99.17% |     54600 | 1.77M | 61 |      1012 | 21.68K | 349 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'38'' |
| Q25L60X80P000 |   80.0 |  98.92% |     48673 | 1.77M | 71 |      1561 | 14.34K | 184 |   80.0 | 7.0 |  19.7 | 151.5 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'36'' |
| Q25L60X80P001 |   80.0 |  98.75% |     44181 | 1.77M | 71 |      2561 | 14.44K | 187 |   80.0 | 6.0 |  20.0 | 147.0 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'36'' |
| Q25L60X80P002 |   80.0 |  98.96% |     44188 | 1.77M | 68 |      1022 | 12.82K | 175 |   81.0 | 6.0 |  20.0 | 148.5 | "31,41,51,61,71,81" | 0:00'30'' | 0:00'36'' |
| Q30L60X40P000 |   40.0 |  99.27% |     58106 | 1.77M | 54 |       912 | 20.58K | 362 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'40'' |
| Q30L60X40P001 |   40.0 |  99.29% |     58127 | 1.77M | 51 |      1634 | 20.22K | 368 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'41'' |
| Q30L60X40P002 |   40.0 |  99.27% |     54612 | 1.77M | 58 |      1012 | 19.35K | 355 |   40.0 | 4.0 |   9.3 |  78.0 | "31,41,51,61,71,81" | 0:00'19'' | 0:00'40'' |
| Q30L60X40P003 |   40.0 |  99.32% |     58200 | 1.77M | 55 |      1056 | 23.05K | 360 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'41'' |
| Q30L60X40P004 |   40.0 |  99.29% |     57086 | 1.77M | 55 |      1044 | 23.27K | 372 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'19'' | 0:00'42'' |
| Q30L60X40P005 |   40.0 |  99.33% |     60957 | 1.77M | 52 |      1032 | 22.77K | 380 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'42'' |
| Q30L60X80P000 |   80.0 |  99.23% |     58128 | 1.77M | 53 |      1634 | 14.78K | 181 |   80.0 | 6.0 |  20.0 | 147.0 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'38'' |
| Q30L60X80P001 |   80.0 |  99.21% |     55125 | 1.77M | 52 |      3503 | 15.98K | 182 |   80.0 | 6.0 |  20.0 | 147.0 | "31,41,51,61,71,81" | 0:00'30'' | 0:00'39'' |
| Q30L60X80P002 |   80.0 |  99.30% |     58184 | 1.77M | 56 |       973 |    13K | 223 |   80.0 | 6.0 |  20.0 | 147.0 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'41'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |  # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|---:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |  99.19% |     54569 | 1.77M | 61 |      1020 | 19.79K | 343 |   39.5 | 3.5 |   9.7 |  75.0 | "31,41,51,61,71,81" | 0:00'27'' | 0:00'41'' |
| Q25L60X40P001 |   40.0 |  99.20% |     57096 | 1.77M | 57 |      1032 | 22.64K | 348 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'41'' |
| Q25L60X40P002 |   40.0 |  99.07% |     55095 | 1.77M | 56 |      1020 | 18.63K | 345 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'39'' |
| Q25L60X40P003 |   40.0 |  99.12% |     55114 | 1.77M | 56 |      1043 | 22.76K | 334 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'27'' | 0:00'38'' |
| Q25L60X40P004 |   40.0 |  99.15% |     55105 | 1.77M | 59 |      1007 | 18.27K | 324 |   40.0 | 4.0 |   9.3 |  78.0 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'39'' |
| Q25L60X40P005 |   40.0 |  99.15% |     54586 | 1.77M | 56 |      1026 | 20.77K | 315 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'27'' | 0:00'38'' |
| Q25L60X80P000 |   80.0 |  99.23% |     58163 | 1.77M | 53 |      3501 | 15.51K | 209 |   78.5 | 7.5 |  18.7 | 151.5 | "31,41,51,61,71,81" | 0:00'30'' | 0:00'39'' |
| Q25L60X80P001 |   80.0 |  99.16% |     59997 | 1.77M | 50 |      1339 | 15.74K | 171 |   79.5 | 6.5 |  20.0 | 148.5 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'38'' |
| Q25L60X80P002 |   80.0 |  99.23% |     60015 | 1.77M | 52 |      1020 | 14.41K | 209 |   79.5 | 6.5 |  20.0 | 148.5 | "31,41,51,61,71,81" | 0:00'32'' | 0:00'40'' |
| Q30L60X40P000 |   40.0 |  99.16% |     55087 | 1.77M | 58 |       848 | 20.09K | 385 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'41'' |
| Q30L60X40P001 |   40.0 |  99.25% |     58115 | 1.77M | 57 |      1632 | 20.42K | 380 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'40'' |
| Q30L60X40P002 |   40.0 |  99.15% |     54598 | 1.77M | 60 |      1007 | 17.68K | 352 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'40'' |
| Q30L60X40P003 |   40.0 |  99.23% |     53991 | 1.77M | 62 |        54 | 19.63K | 378 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'27'' | 0:00'41'' |
| Q30L60X40P004 |   40.0 |  99.16% |     58117 | 1.77M | 55 |      1044 | 21.61K | 394 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'39'' |
| Q30L60X40P005 |   40.0 |  99.25% |     55092 | 1.77M | 59 |      1023 |  25.3K | 396 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'27'' | 0:00'41'' |
| Q30L60X80P000 |   80.0 |  99.26% |     68716 | 1.77M | 49 |      1632 | 15.89K | 227 |   78.0 | 7.0 |  19.0 | 148.5 | "31,41,51,61,71,81" | 0:00'30'' | 0:00'40'' |
| Q30L60X80P001 |   80.0 |  99.24% |     68718 | 1.77M | 48 |      1632 | 18.54K | 235 |   80.0 | 6.0 |  20.0 | 147.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'40'' |
| Q30L60X80P002 |   80.0 |  99.25% |     68731 | 1.77M | 49 |       969 | 13.53K | 247 |   78.0 | 7.0 |  19.0 | 148.5 | "31,41,51,61,71,81" | 0:00'32'' | 0:00'39'' |


Table: statCanu

| Name                |     N50 |     Sum |    # |
|:--------------------|--------:|--------:|-----:|
| Genome              | 1830138 | 1830138 |    1 |
| Paralogs            |    5432 |   95358 |   29 |
| X80.trim.corrected  |   11133 |   58.8M | 6431 |
| Xall.trim.corrected |   23701 |  60.34M | 3215 |
| X80.trim.contig     | 1838071 | 1851226 |    2 |
| Xall.trim.contig    | 1846774 | 1846774 |    1 |


Table: statFinal

| Name                           |     N50 |     Sum |   # |
|:-------------------------------|--------:|--------:|----:|
| Genome                         | 1830138 | 1830138 |   1 |
| Paralogs                       |    5432 |   95358 |  29 |
| 7_mergeKunitigsAnchors.anchors |   68737 | 1777760 |  51 |
| 7_mergeKunitigsAnchors.others  |    1052 |   24097 |  16 |
| 7_mergeTadpoleAnchors.anchors  |   68737 | 1777932 |  51 |
| 7_mergeTadpoleAnchors.others   |    1052 |   38937 |  26 |
| 7_mergeAnchors.anchors         |   68737 | 1777932 |  51 |
| 7_mergeAnchors.others          |    1052 |   38937 |  26 |
| anchorLong                     |   79186 | 1770807 |  40 |
| anchorFill                     |  398530 | 1790284 |   8 |
| canu_X80-trim                  | 1838071 | 1851226 |   2 |
| canu_Xall-trim                 | 1846774 | 1846774 |   1 |
| spades.contig                  |  131566 | 1842362 | 191 |
| spades.scaffold                |  131568 | 1842512 | 185 |
| spades.non-contained           |  131566 | 1797398 |  28 |
| spades.anchor                  |  131550 | 1781667 |  26 |
| megahit.contig                 |   60051 | 1802106 |  80 |
| megahit.non-contained          |   60051 | 1791321 |  52 |
| megahit.anchor                 |   60030 | 1774109 |  48 |
| platanus.contig                |  107683 | 1806151 | 133 |
| platanus.scaffold              |  161481 | 1800030 |  77 |
| platanus.non-contained         |  161481 | 1791276 |  18 |
| platanus.anchor                |  161439 | 1783217 |  16 |


# Listeria monocytogenes FDAARGOS_351, 单核细胞增生李斯特氏菌

Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Lmon: download

* Reference genome

    * Strain: Listeria monocytogenes EGD-e
    * Taxid: [169963](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=169963)
    * RefSeq assembly accession:
      [GCF_000196035.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/196/035/GCF_000196035.1_ASM19603v1/GCF_000196035.1_ASM19603v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0133

```bash
mkdir -p ~/data/anchr/Lmon/1_genome
cd ~/data/anchr/Lmon/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/196/035/GCF_000196035.1_ASM19603v1/GCF_000196035.1_ASM19603v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_003210.1${TAB}1
EOF

faops replace GCF_000196035.1_ASM19603v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Lmon/Lmon.multi.fas paralogs.fa

```

* Illumina

    * [SRX2717967](https://www.ncbi.nlm.nih.gov/sra/SRX2717967) SRR5427943

```bash
mkdir -p ~/data/anchr/Lmon/2_illumina
cd ~/data/anchr/Lmon/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR542/003/SRR5427943/SRR5427943_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR542/003/SRR5427943/SRR5427943_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
6a8f391d5836e3a5aada44fa19df14a4 SRR5427943_1.fastq.gz
759c755f5e6653d4b0495e72db87cbe8 SRR5427943_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s SRR5427943_1.fastq.gz R1.fq.gz
ln -s SRR5427943_2.fastq.gz R2.fq.gz

```

* PacBio

    * [SRX2717966](https://www.ncbi.nlm.nih.gov/sra/SRX2717966) SRR5427942

## Lmon: template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Lmon

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 2944528 \
    --trim2 "--dedupe" \
    --sample 300 \
    --cov2 "40 80" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,2,3" \
    --insertsize \
    --sgapreqc \
    --fillanchor \
    --parallel 24

```

## Lmon: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Lmon

cd ${WORKING_DIR}/${BASE_NAME}

bash 0_bsub.sh
#bash 0_master.sh

#bash 0_cleanup.sh

```


Table: statInsertSize

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 286.1 |    252 | 1075.3 |                         38.97% |
| tadpole.bbtools | 256.1 |    251 |   75.6 |                         48.14% |
| genome.picard   | 257.0 |    252 |   52.8 |                             FR |
| tadpole.picard  | 256.4 |    252 |   53.4 |                             FR |


Table: statSgaStats

| Item           |  Value |
|:---------------|-------:|
| incorrectBases |  0.23% |
| perfectReads   | 83.88% |
| overlapDepth   | 744.44 |


Table: statReads

| Name     |     N50 |     Sum |        # |
|:---------|--------:|--------:|---------:|
| Genome   | 2944528 | 2944528 |        1 |
| Paralogs |    5116 |   68585 |       22 |
| Illumina |     151 |   2.59G | 17153480 |
| trim     |     150 |  781.5M |  5485154 |
| Q20L60   |     150 | 755.76M |  5304659 |
| Q25L60   |     150 | 707.41M |  5073393 |
| Q30L60   |     150 | 633.52M |  4705241 |


Table: statTrimReads

| Name     | N50 |     Sum |        # |
|:---------|----:|--------:|---------:|
| clumpify | 151 |   2.46G | 16305332 |
| sample   | 151 | 883.36M |  5850056 |
| trim     | 150 | 782.09M |  5489714 |
| filter   | 150 |  781.5M |  5485154 |
| R1       | 150 | 406.67M |  2742577 |
| R2       | 149 | 374.83M |  2742577 |
| Rs       |   0 |       0 |        0 |


```text
#trim
#Matched	51519	0.88066%
#Name	Reads	ReadsPct
Reverse_adapter	15415	0.26350%
TruSeq_Adapter_Index_1_6	14394	0.24605%
pcr_dimer	8086	0.13822%
Nextera_LMP_Read2_External_Adapter	5359	0.09161%
PCR_Primers	4505	0.07701%
PhiX_read2_adapter	1357	0.02320%
TruSeq_Universal_Adapter	1187	0.02029%
```

```text
#filter
#Matched	4097	0.07463%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	3556	0.06478%
contam_250	325	0.00592%
contam_23	213	0.00388%
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 150 | 781.09M | 5482308 |
| ecco          | 150 | 781.09M | 5482308 |
| eccc          | 150 | 781.09M | 5482308 |
| ecct          | 150 | 738.39M | 5168270 |
| extended      | 190 | 942.63M | 5168270 |
| merged        | 298 | 740.95M | 2531288 |
| unmerged.raw  | 188 |  15.91M |  105694 |
| unmerged.trim | 188 |  15.91M |  105682 |
| U1            | 190 |   9.58M |   52841 |
| U2            | 145 |   6.33M |   52841 |
| Us            |   0 |       0 |       0 |
| pe.cor        | 296 |  759.4M | 5168258 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 224.0 |    227 |  34.6 |         56.50% |
| ihist.merge.txt  | 292.7 |    289 |  52.7 |         97.95% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q0L0   | 265.4 |  195.5 |   26.33% |     142 | "103" | 2.94M |  6.9M |     2.34 | 0:01'14'' |
| Q20L60 | 256.7 |  196.1 |   23.61% |     142 | "103" | 2.94M | 6.78M |     2.30 | 0:01'11'' |
| Q25L60 | 240.4 |  197.6 |   17.79% |     138 | "101" | 2.94M | 6.54M |     2.22 | 0:01'08'' |
| Q30L60 | 215.3 |  189.1 |   12.21% |     134 |  "87" | 2.94M | 6.23M |     2.12 | 0:01'05'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  91.24% |      7305 | 2.85M |  561 |        45 |  53.02K | 1151 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'38'' |
| Q0L0X40P001   |   40.0 |  91.11% |      7134 | 2.84M |  574 |        59 |  69.53K | 1180 |   37.0 |  4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'38'' |
| Q0L0X40P002   |   40.0 |  91.11% |      7186 | 2.84M |  562 |        61 |  62.99K | 1151 |   36.0 |  4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'37'' |
| Q0L0X40P003   |   40.0 |  91.41% |      7354 | 2.84M |  569 |        59 |  68.81K | 1165 |   37.0 |  4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'38'' |
| Q0L0X80P000   |   80.0 |  77.47% |      2824 | 2.39M |  970 |      1088 |  248.3K | 2104 |   67.0 | 10.0 |  12.3 | 134.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'38'' |
| Q0L0X80P001   |   80.0 |  78.29% |      2675 | 2.42M | 1021 |      1093 | 238.09K | 2190 |   68.0 |  9.0 |  13.7 | 136.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'37'' |
| Q20L60X40P000 |   40.0 |  92.90% |      9736 | 2.89M |  435 |        49 |  42.96K |  887 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'37'' |
| Q20L60X40P001 |   40.0 |  93.09% |      9349 |  2.9M |  467 |        48 |  47.27K |  953 |   37.0 |  4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'38'' |
| Q20L60X40P002 |   40.0 |  93.08% |      9313 | 2.89M |  448 |        55 |  50.01K |  921 |   37.0 |  4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'39'' |
| Q20L60X40P003 |   40.0 |  93.05% |     10305 | 2.89M |  446 |        50 |  45.07K |  913 |   37.0 |  4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'38'' |
| Q20L60X80P000 |   80.0 |  84.25% |      3410 | 2.61M |  914 |      1073 | 206.91K | 1958 |   69.0 |  9.0 |  14.0 | 138.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'38'' |
| Q20L60X80P001 |   80.0 |  84.62% |      3507 | 2.61M |  896 |      1106 | 233.56K | 1941 |   70.0 |  9.0 |  14.3 | 140.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'39'' |
| Q25L60X40P000 |   40.0 |  95.05% |     21375 | 2.93M |  225 |       773 |  32.85K |  473 |   38.0 |  4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'38'' |
| Q25L60X40P001 |   40.0 |  95.05% |     22825 | 2.94M |  217 |        68 |  25.05K |  466 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'38'' |
| Q25L60X40P002 |   40.0 |  95.19% |     23572 | 2.93M |  211 |      1031 |  30.25K |  444 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'38'' |
| Q25L60X40P003 |   40.0 |  95.14% |     24443 | 2.94M |  230 |        55 |  23.26K |  491 |   38.0 |  5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'39'' |
| Q25L60X80P000 |   80.0 |  92.94% |      8037 | 2.89M |  533 |      1158 | 164.91K | 1171 |   72.0 | 11.0 |  13.0 | 144.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'39'' |
| Q25L60X80P001 |   80.0 |  93.46% |      8030 |  2.9M |  527 |      1152 | 159.28K | 1167 |   72.0 | 11.0 |  13.0 | 144.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'39'' |
| Q30L60X40P000 |   40.0 |  96.04% |     58618 | 2.94M |   91 |        94 |  12.64K |  225 |   38.0 |  6.0 |   6.7 |  76.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'41'' |
| Q30L60X40P001 |   40.0 |  96.05% |     73391 | 2.95M |   77 |        86 |   9.64K |  202 |   38.0 |  7.0 |   5.7 |  76.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'41'' |
| Q30L60X40P002 |   40.0 |  96.11% |     61970 | 2.94M |   96 |      1000 |  16.83K |  224 |   39.0 |  6.0 |   7.0 |  78.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'39'' |
| Q30L60X40P003 |   40.0 |  95.78% |     56263 | 2.94M |  102 |       916 |  15.77K |  227 |   34.0 |  7.0 |   4.3 |  68.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'39'' |
| Q30L60X80P000 |   80.0 |  95.61% |     25780 | 2.95M |  198 |      1219 |  117.6K |  490 |   70.0 | 17.0 |   6.3 | 140.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'41'' |
| Q30L60X80P001 |   80.0 |  95.55% |     24809 | 2.99M |  231 |      1076 |  82.12K |  489 |   64.0 | 23.0 |   3.0 | 128.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'39'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  95.96% |    180798 | 2.95M |  33 |      1639 |   7.72K | 135 |   32.0 | 10.0 |   3.0 |  64.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'44'' |
| Q0L0X40P001   |   40.0 |  95.96% |    163934 | 2.94M |  51 |      1408 |  17.53K | 172 |   32.0 | 10.0 |   3.0 |  64.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'45'' |
| Q0L0X40P002   |   40.0 |  95.67% |    329811 | 2.93M |  46 |      1947 |  27.16K | 127 |   31.0 | 12.0 |   3.0 |  62.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'41'' |
| Q0L0X40P003   |   40.0 |  95.83% |    277424 | 2.95M |  35 |      1005 |   8.61K | 137 |   34.0 |  8.0 |   3.3 |  68.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'45'' |
| Q0L0X80P000   |   80.0 |  95.34% |     97446 | 2.97M |  80 |      1092 |  16.41K | 205 |   68.0 | 21.0 |   3.0 | 136.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'40'' |
| Q0L0X80P001   |   80.0 |  95.16% |     88048 | 2.95M |  63 |      1181 |  35.16K | 184 |   69.5 | 18.0 |   5.2 | 139.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'39'' |
| Q20L60X40P000 |   40.0 |  96.01% |    262626 | 2.93M |  47 |      3983 |  32.82K | 130 |   30.5 | 10.5 |   3.0 |  61.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'42'' |
| Q20L60X40P001 |   40.0 |  96.11% |    191965 | 2.95M |  48 |      1038 |  13.39K | 143 |   33.0 |  9.0 |   3.0 |  66.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'44'' |
| Q20L60X40P002 |   40.0 |  96.13% |    342318 | 2.95M |  33 |      2518 |   4.43K | 126 |   33.0 |  9.0 |   3.0 |  66.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'44'' |
| Q20L60X40P003 |   40.0 |  95.86% |    164115 | 2.95M |  38 |      1072 |   4.99K | 123 |   33.0 |  9.5 |   3.0 |  66.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'41'' |
| Q20L60X80P000 |   80.0 |  95.70% |    139770 | 2.95M |  63 |      1205 |  31.79K | 176 |   70.0 | 18.0 |   5.3 | 140.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'40'' |
| Q20L60X80P001 |   80.0 |  95.46% |    110449 | 2.98M |  76 |      1149 |  18.31K | 175 |   66.0 | 23.0 |   3.0 | 132.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'39'' |
| Q25L60X40P000 |   40.0 |  96.38% |    164109 | 2.95M |  34 |        81 |   5.51K | 136 |   34.0 |  8.0 |   3.3 |  68.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'42'' |
| Q25L60X40P001 |   40.0 |  96.27% |    180811 | 2.95M |  50 |       991 |  14.56K | 134 |   32.0 | 11.0 |   3.0 |  64.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'41'' |
| Q25L60X40P002 |   40.0 |  96.55% |    166600 | 2.94M |  48 |      2237 |  24.62K | 154 |   31.0 | 12.0 |   3.0 |  62.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'43'' |
| Q25L60X40P003 |   40.0 |  96.56% |    180804 | 2.95M |  37 |      1018 |   6.25K | 137 |   32.0 | 11.0 |   3.0 |  64.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'45'' |
| Q25L60X80P000 |   80.0 |  96.05% |    180830 | 2.96M |  50 |      1042 |  10.83K | 131 |   67.5 | 24.0 |   3.0 | 135.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'40'' |
| Q25L60X80P001 |   80.0 |  96.21% |    136551 | 2.98M |  56 |      1408 |  13.67K | 140 |   67.0 | 25.5 |   3.0 | 134.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'39'' |
| Q30L60X40P000 |   40.0 |  97.10% |    342321 | 2.95M |  29 |      1408 |   6.86K | 144 |   32.5 | 10.5 |   3.0 |  65.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'47'' |
| Q30L60X40P001 |   40.0 |  96.93% |    342317 | 2.96M |  37 |      1072 |    4.8K | 152 |   33.0 | 10.0 |   3.0 |  66.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'46'' |
| Q30L60X40P002 |   40.0 |  96.87% |    342326 | 2.94M |  52 |      1408 |  15.52K | 154 |   32.0 | 10.0 |   3.0 |  64.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'44'' |
| Q30L60X40P003 |   40.0 |  96.58% |    180815 | 2.94M |  45 |      1917 |  42.39K | 166 |   32.0 | 11.0 |   3.0 |  64.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'43'' |
| Q30L60X80P000 |   80.0 |  96.54% |    180830 | 2.58M | 289 |      3678 | 507.87K | 420 |   51.0 | 32.0 |   3.0 | 102.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'44'' |
| Q30L60X80P001 |   80.0 |  96.49% |      5476 | 1.34M | 362 |     35254 |   1.78M | 441 |   41.0 | 35.0 |   3.0 |  82.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'41'' |


Table: statMRKunitigsAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  97.29% |    254431 | 2.94M |  30 |      1173 |  71.78K |  611 |   35.0 |  5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'54'' |
| MRX40P001 |   40.0 |  97.32% |    254456 | 2.94M |  36 |       128 |  63.26K |  628 |   37.5 |  5.5 |   7.0 |  75.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'55'' |
| MRX40P002 |   40.0 |  97.28% |    237877 | 2.94M |  32 |       215 |  62.93K |  604 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'53'' |
| MRX40P003 |   40.0 |  97.28% |    227957 | 2.94M |  31 |       124 |  68.52K |  664 |   35.0 |  5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'54'' |
| MRX40P004 |   40.0 |  97.32% |    209619 | 2.94M |  37 |       903 |  65.32K |  663 |   36.0 |  6.0 |   6.0 |  72.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'55'' |
| MRX40P005 |   40.0 |  97.37% |    254349 | 2.94M |  32 |       495 |  68.06K |  632 |   35.0 |  5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'54'' |
| MRX80P000 |   80.0 |  97.41% |     25834 | 3.08M | 219 |      1117 | 472.46K | 3736 |   66.0 | 10.0 |  12.0 | 132.0 | "31,41,51,61,71,81" | 0:01'07'' | 0:01'00'' |
| MRX80P001 |   80.0 |  97.41% |     26599 | 3.07M | 207 |      1128 | 526.82K | 3798 |   65.0 |  9.0 |  12.7 | 130.0 | "31,41,51,61,71,81" | 0:01'08'' | 0:01'01'' |
| MRX80P002 |   80.0 |  97.39% |     25551 | 3.07M | 221 |      1091 | 482.68K | 3733 |   67.0 | 10.0 |  12.3 | 134.0 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'58'' |


Table: statMRTadpoleAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |   # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|-----:|----------:|--------:|----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |  0.00% |  342338 |     2.95M |    30 | 1176 |    13.63K |      91 |  37 |   21.0 |  3.0 |  74.0 |   0.0 |                     |           |           |
| MRX40P001 |   40.0 |  95.31% |    342336 | 2.95M |   28 |      1137 |  16.72K |  89 |   38.0 | 22.0 |   3.0 |  76.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'39'' |
| MRX40P002 |   40.0 |  95.31% |    342305 | 2.96M |   30 |      1140 |  13.98K |  91 |   37.0 | 21.0 |   3.0 |  74.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'40'' |
| MRX40P003 |   40.0 |  95.25% |    342333 | 2.96M |   34 |      1230 |  18.06K |  94 |   37.0 | 20.0 |   3.0 |  74.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'40'' |
| MRX40P004 |   40.0 |  95.22% |    227912 | 2.96M |   33 |      1408 |     18K |  99 |   37.0 | 19.0 |   3.0 |  74.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'39'' |
| MRX40P005 |   40.0 |  95.30% |    342328 | 2.97M |   33 |      1371 |  21.06K |  95 |   37.0 | 20.0 |   3.0 |  74.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'40'' |
| MRX80P000 |   80.0 |  95.52% |    342347 | 3.02M |   66 |      1129 | 103.12K | 229 |   74.0 | 70.0 |   3.0 | 148.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'43'' |
| MRX80P001 |   80.0 |  95.54% |    342335 | 3.01M |   64 |      1142 | 112.49K | 232 |   74.0 | 70.0 |   3.0 | 148.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'42'' |
| MRX80P002 |   80.0 |  95.50% |    227927 | 3.01M |   74 |      1110 |  99.88K | 245 |   74.0 | 70.0 |   3.0 | 148.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'42'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |   Sum |  # | N50Others |     Sum |    # | median |   MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|------:|---:|----------:|--------:|-----:|-------:|------:|------:|------:|----------:|
| 7_mergeAnchors           |  69.05% |    342339 | 3.05M | 55 |      1495 |   1.83M | 1014 |  104.0 |  95.0 |   3.0 | 208.0 | 0:00'53'' |
| 7_mergeKunitigsAnchors   |   0.00% |    342277 | 2.96M | 31 |      1232 | 837.15K |  639 |  108.0 |  18.0 |  18.0 | 216.0 | 0:01'13'' |
| 7_mergeMRKunitigsAnchors |   0.00% |    342242 | 2.96M | 31 |      1336 | 770.89K |  542 |  106.0 |  17.0 |  18.3 | 212.0 | 0:45'05'' |
| 7_mergeMRTadpoleAnchors  |   0.00% |    342344 | 3.03M | 56 |      1170 | 379.43K |  302 |  107.0 | 102.0 |   3.0 | 214.0 | 0:00'55'' |
| 7_mergeTadpoleAnchors    |  76.15% |    342330 |    3M | 51 |     19512 | 608.88K |  133 |  108.0 |  74.5 |   3.0 | 216.0 | 0:00'58'' |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |    Sum |   # | N50Others |     Sum |   # | median |  MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|-------:|----:|----------:|--------:|----:|-------:|-----:|------:|------:|----------:|
| 8_spades     |  70.02% |      1367 | 376.6K | 265 |     44110 |   5.72M | 981 |    8.0 |  5.0 |   3.0 |  16.0 | 0:01'00'' |
| 8_spades_MR  |  69.12% |    296062 |  3.27M | 231 |      1476 |   1.03M | 983 |   94.0 | 90.0 |   3.0 | 188.0 | 0:00'57'' |
| 8_megahit    |  69.57% |    139915 |  3.24M | 365 |      5143 |   2.18M | 804 |   79.0 | 76.0 |   3.0 | 158.0 | 0:01'00'' |
| 8_megahit_MR |  69.03% |    258140 |  3.24M | 222 |      1472 | 932.25K | 923 |   95.0 | 91.0 |   3.0 | 190.0 | 0:00'57'' |
| 8_platanus   |  80.52% |    557548 |  2.95M |  12 |      2406 |   4.36K |  26 |  100.5 | 18.5 |  15.0 | 201.0 | 0:00'45'' |


Table: statFinal

| Name                     |     N50 |     Sum |     # |
|:-------------------------|--------:|--------:|------:|
| Genome                   | 2944528 | 2944528 |     1 |
| Paralogs                 |    5116 |   68585 |    22 |
| 7_mergeAnchors.anchors   |  342339 | 3052484 |    55 |
| 7_mergeAnchors.others    |    1495 | 1827103 |  1014 |
| anchorLong               |  342339 | 3046447 |    47 |
| anchorFill               |  342339 | 3049266 |    38 |
| spades.contig            |    8723 | 9884704 | 10581 |
| spades.scaffold          |    8811 | 9885064 | 10572 |
| spades.non-contained     |   52288 | 6099099 |   716 |
| spades_MR.contig         |  254622 | 4684215 |  1243 |
| spades_MR.scaffold       |  254622 | 4684345 |  1239 |
| spades_MR.non-contained  |  257690 | 4298196 |   755 |
| megahit.contig           |   18077 | 6785525 |  3362 |
| megahit.non-contained    |   46434 | 5425351 |   445 |
| megahit_MR.contig        |  144488 | 5064048 |  2271 |
| megahit_MR.non-contained |  225412 | 4175852 |   710 |
| platanus.contig          |  225202 | 2966201 |    95 |
| platanus.scaffold        |  557592 | 2957064 |    28 |
| platanus.non-contained   |  557592 | 2953473 |    14 |


# Clostridioides difficile 630

Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Cdif: download

* Reference genome

    * Strain: Clostridioides difficile 630
    * Taxid: [272563](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=272563)
    * RefSeq assembly accession:
      [GCF_000009205.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/009/205/GCF_000009205.1_ASM920v1/GCF_000009205.1_ASM920v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0661

```bash
mkdir -p ${HOME}/data/anchr/Cdif/1_genome
cd ${HOME}/data/anchr/Cdif/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/009/205/GCF_000009205.1_ASM920v1/GCF_000009205.1_ASM920v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_009089.1${TAB}1
NC_008226.1${TAB}pCD630
EOF

faops replace GCF_000009205.1_ASM920v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Cdif/Cdif.multi.fas paralogs.fa

```

* Illumina

    * [SRX2107163](https://www.ncbi.nlm.nih.gov/sra/SRX2107163) SRR4125185

```bash
mkdir -p ${HOME}/data/anchr/Cdif/2_illumina
cd ${HOME}/data/anchr/Cdif/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR412/005/SRR4125185/SRR4125185_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR412/005/SRR4125185/SRR4125185_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
abfbf6a3f7a8251ea7184b872c8ecb32 SRR4125185_1.fastq.gz
2a7a667cbe598dff97da27d96f7cae1b SRR4125185_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s SRR4125185_1.fastq.gz R1.fq.gz
ln -s SRR4125185_2.fastq.gz R2.fq.gz

```

* PacBio

    * [SRX2104759](https://www.ncbi.nlm.nih.gov/sra/SRX2104759) SRR4125184

## Cdif: template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Cdif

cd ${WORKING_DIR}/${BASE_NAME}

rm *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 4298133 \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --sgastats \
    --trim2 "--dedupe --cutoff 5 --cutk 31" \
    --sample 300 \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,artifact" \
    --mergereads \
    --ecphase "1,2,3" \
    --cov2 "40 80" \
    --tadpole \
    --statp 3 \
    --redoanchors \
    --fillanchor \
    --parallel 24 \
    --xmx 110g

```

## Cdif: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Cdif

cd ${WORKING_DIR}/${BASE_NAME}
#rm -fr 4_*/ 6_*/ 7_*/ 8_*/ && rm -fr 2_illumina/trim 2_illumina/mergereads statReads.md 

bash 0_bsub.sh
#bkill -J "${BASE_NAME}-*"

#bash 0_master.sh
#bash 0_cleanup.sh

```


Table: statInsertSize

| Group             |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:------------------|------:|-------:|-------:|-------------------------------:|
| R.genome.bbtools  | 694.0 |    320 | 3766.0 |                         49.19% |
| R.tadpole.bbtools | 328.9 |    317 |   98.1 |                         46.06% |
| R.genome.picard   | 330.2 |    319 |   87.9 |                             FR |
| R.tadpole.picard  | 328.6 |    317 |   88.0 |                             FR |


Table: statSgaStats

| Library | incorrectBases | perfectReads | overlapDepth |
|:--------|---------------:|-------------:|-------------:|
| R       |          0.12% |       92.15% |       291.83 |


Table: statReads

| Name       |     N50 |     Sum |        # |
|:-----------|--------:|--------:|---------:|
| Genome     | 4290252 | 4298133 |        2 |
| Paralogs   |    3242 |  328828 |      121 |
| Illumina.R |     101 |   1.33G | 13190786 |
| trim.R     |     100 |   1.23G | 12339578 |
| Q20L60     |     100 |   1.22G | 12231291 |
| Q25L60     |     100 |   1.19G | 12028208 |
| Q30L60     |     100 |   1.14G | 11542641 |


Table: statTrimReads

| Name     | N50 |     Sum |        # |
|:---------|----:|--------:|---------:|
| clumpify | 101 |   1.32G | 13028932 |
| highpass | 101 |   1.31G | 12947346 |
| sample   | 101 |   1.29G | 12766732 |
| trim     | 100 |   1.23G | 12341232 |
| filter   | 100 |   1.23G | 12339578 |
| R1       | 100 | 615.66M |  6169789 |
| R2       | 100 | 610.94M |  6169789 |
| Rs       |   0 |       0 |        0 |


```text
#R.trim
#Matched	6588	0.05160%
#Name	Reads	ReadsPct
```

```text
#R.filter
#Matched	1368	0.01108%
#Name	Reads	ReadsPct
```

```text
#R.peaks
#k	31
#unique_kmers	23197050
#main_peak	187
#genome_size	4317299
#haploid_genome_size	4317299
#fold_coverage	187
#haploid_fold_coverage	187
#ploidy	1
#percent_repeat	4.165
#start	center	stop	max	volume
```


Table: statMergeReads

| Name          | N50 |     Sum |        # |
|:--------------|----:|--------:|---------:|
| clumped       | 100 |   1.23G | 12338996 |
| ecco          | 100 |   1.23G | 12338996 |
| eccc          | 100 |   1.23G | 12338996 |
| ecct          | 100 |   1.22G | 12276108 |
| extended      | 140 |   1.71G | 12276108 |
| merged.raw    | 343 |   1.52G |  4604728 |
| unmerged.raw  | 140 |  423.3M |  3066652 |
| unmerged.trim | 140 | 423.29M |  3066606 |
| M1            | 343 |   1.52G |  4582829 |
| U1            | 140 | 213.64M |  1533303 |
| U2            | 140 | 209.65M |  1533303 |
| Us            |   0 |       0 |        0 |
| M.cor         | 321 |   1.95G | 12232264 |

| Group              |  Mean | Median | STDev | PercentOfPairs |
|:-------------------|------:|-------:|------:|---------------:|
| M.ihist.merge1.txt | 165.4 |    170 |  18.1 |          1.95% |
| M.ihist.merge.txt  | 331.1 |    333 |  54.3 |         75.02% |


Table: statQuorum

| Name     | CovIn | CovOut | Discard% | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:---------|------:|-------:|---------:|-----:|------:|------:|---------:|----------:|
| Q0L0.R   | 285.4 |  266.1 |    6.76% | "71" |  4.3M | 4.22M |     0.98 | 0:02'11'' |
| Q20L60.R | 283.1 |  265.5 |    6.23% | "71" |  4.3M | 4.21M |     0.98 | 0:02'07'' |
| Q25L60.R | 278.0 |  263.1 |    5.35% | "71" |  4.3M |  4.2M |     0.98 | 0:02'10'' |
| Q30L60.R | 264.4 |  253.6 |    4.10% | "71" |  4.3M |  4.2M |     0.98 | 0:02'04'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  98.31% |     63825 | 4.14M | 142 |      1102 | 57.29K | 653 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'44'' |
| Q0L0X40P001   |   40.0 |  98.32% |     72934 | 4.14M | 118 |      7659 | 48.33K | 644 |   40.0 | 4.0 |   9.3 |  78.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'47'' |
| Q0L0X40P002   |   40.0 |  98.26% |     58756 | 4.14M | 154 |      1367 | 53.41K | 717 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'44'' |
| Q0L0X40P003   |   40.0 |  98.31% |     72276 | 4.15M | 135 |      7659 |  49.9K | 681 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'45'' |
| Q0L0X80P000   |   80.0 |  97.90% |     61091 | 4.14M | 137 |      7155 | 38.81K | 362 |   79.0 | 7.0 |  19.3 | 150.0 | "31,41,51,61,71,81" | 0:01'02'' | 0:00'44'' |
| Q0L0X80P001   |   80.0 |  97.83% |     64966 | 4.14M | 139 |      4487 | 38.57K | 379 |   77.0 | 7.0 |  18.7 | 147.0 | "31,41,51,61,71,81" | 0:01'02'' | 0:00'42'' |
| Q0L0X80P002   |   80.0 |  97.87% |     58758 | 4.14M | 142 |      7659 | 39.21K | 378 |   78.0 | 7.0 |  19.0 | 148.5 | "31,41,51,61,71,81" | 0:01'02'' | 0:00'44'' |
| Q20L60X40P000 |   40.0 |  98.34% |     68082 | 4.14M | 138 |      2784 | 50.21K | 660 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'45'' |
| Q20L60X40P001 |   40.0 |  98.32% |     62110 | 4.14M | 133 |      5574 | 45.58K | 639 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'43'' |
| Q20L60X40P002 |   40.0 |  98.27% |     63823 | 4.15M | 152 |      1367 |  51.6K | 701 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'44'' |
| Q20L60X40P003 |   40.0 |  98.42% |     69398 | 4.15M | 132 |      7659 | 45.79K | 663 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'46'' |
| Q20L60X80P000 |   80.0 |  97.79% |     58774 | 4.14M | 139 |      2859 | 36.67K | 370 |   78.0 | 8.0 |  18.0 | 153.0 | "31,41,51,61,71,81" | 0:01'02'' | 0:00'43'' |
| Q20L60X80P001 |   80.0 |  98.00% |     66190 | 4.14M | 139 |      7659 | 38.54K | 377 |   78.0 | 7.0 |  19.0 | 148.5 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'44'' |
| Q20L60X80P002 |   80.0 |  97.98% |     60979 | 4.14M | 136 |      5980 |  38.2K | 372 |   78.0 | 7.0 |  19.0 | 148.5 | "31,41,51,61,71,81" | 0:01'02'' | 0:00'45'' |
| Q25L60X40P000 |   40.0 |  98.59% |     80161 | 4.14M | 135 |      1367 | 54.77K | 660 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'48'' |
| Q25L60X40P001 |   40.0 |  98.40% |     66521 | 4.14M | 128 |      7659 | 47.07K | 603 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'45'' |
| Q25L60X40P002 |   40.0 |  98.49% |     90127 | 4.14M | 121 |      7659 | 49.97K | 603 |   39.0 | 3.5 |   9.5 |  74.2 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'46'' |
| Q25L60X40P003 |   40.0 |  98.49% |     75230 | 4.15M | 123 |      1890 | 44.91K | 655 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'47'' |
| Q25L60X80P000 |   80.0 |  98.13% |     67637 | 4.14M | 127 |      4376 | 39.56K | 352 |   78.0 | 7.0 |  19.0 | 148.5 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'46'' |
| Q25L60X80P001 |   80.0 |  98.18% |     79301 | 4.14M | 129 |      4486 | 38.64K | 346 |   77.0 | 7.0 |  18.7 | 147.0 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'48'' |
| Q25L60X80P002 |   80.0 |  98.01% |     64978 | 4.14M | 130 |      2867 | 39.48K | 367 |   78.0 | 7.0 |  19.0 | 148.5 | "31,41,51,61,71,81" | 0:01'02'' | 0:00'44'' |
| Q30L60X40P000 |   40.0 |  98.48% |     58685 | 4.14M | 154 |      1698 | 53.45K | 695 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'45'' |
| Q30L60X40P001 |   40.0 |  98.64% |     67553 | 4.14M | 135 |      1367 | 52.82K | 687 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'49'' |
| Q30L60X40P002 |   40.0 |  98.62% |     67345 | 4.14M | 151 |      1367 | 63.12K | 717 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'48'' |
| Q30L60X40P003 |   40.0 |  98.52% |     86128 | 4.15M | 130 |      7659 | 47.26K | 664 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'47'' |
| Q30L60X80P000 |   80.0 |  98.42% |     69395 | 4.14M | 127 |      5246 | 39.33K | 389 |   78.0 | 7.0 |  19.0 | 148.5 | "31,41,51,61,71,81" | 0:01'02'' | 0:00'50'' |
| Q30L60X80P001 |   80.0 |  98.46% |     85680 | 4.14M | 118 |      5646 |  43.8K | 375 |   78.0 | 6.5 |  19.5 | 146.2 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'50'' |
| Q30L60X80P002 |   80.0 |  98.27% |     85255 | 4.14M | 118 |      5174 |  39.2K | 376 |   77.0 | 7.0 |  18.7 | 147.0 | "31,41,51,61,71,81" | 0:01'02'' | 0:00'47'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  98.22% |     77798 | 4.14M | 140 |      7922 |  97.52K | 606 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'44'' |
| Q0L0X40P001   |   40.0 |  98.19% |     85233 | 4.15M | 126 |      7932 |  83.94K | 591 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'44'' |
| Q0L0X40P002   |   40.0 |  98.29% |     61796 | 4.14M | 150 |      7922 |  89.74K | 632 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'43'' |
| Q0L0X40P003   |   40.0 |  98.26% |     85680 | 4.15M | 131 |      7922 |   86.3K | 574 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'44'' |
| Q0L0X80P000   |   80.0 |  98.11% |    105458 | 4.14M |  96 |      7932 |  69.37K | 299 |   78.0 | 7.0 |  19.0 | 148.5 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'45'' |
| Q0L0X80P001   |   80.0 |  98.24% |    104927 | 4.14M |  97 |      7932 |  79.42K | 312 |   79.0 | 6.0 |  20.3 | 145.5 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'48'' |
| Q0L0X80P002   |   80.0 |  98.24% |    105469 | 4.14M | 100 |      7932 |  78.59K | 327 |   79.0 | 7.0 |  19.3 | 150.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'46'' |
| Q20L60X40P000 |   40.0 |  98.39% |     82812 | 4.14M | 132 |      7922 |   88.8K | 595 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'44'' |
| Q20L60X40P001 |   40.0 |  98.27% |     67571 | 4.15M | 135 |      7922 |  81.17K | 609 |   39.0 | 3.5 |   9.5 |  74.2 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'44'' |
| Q20L60X40P002 |   40.0 |  98.31% |     62604 | 4.14M | 148 |      7922 |  89.57K | 667 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'44'' |
| Q20L60X40P003 |   40.0 |  98.30% |     67528 | 4.14M | 154 |      7922 |  87.89K | 618 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'44'' |
| Q20L60X80P000 |   80.0 |  98.25% |    105483 | 4.14M |  93 |      7932 |  81.97K | 319 |   78.0 | 7.0 |  19.0 | 148.5 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'47'' |
| Q20L60X80P001 |   80.0 |  98.33% |    105481 | 4.14M |  97 |      7932 |  78.25K | 352 |   79.0 | 7.0 |  19.3 | 150.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'47'' |
| Q20L60X80P002 |   80.0 |  98.33% |    105462 | 4.14M |  97 |      7932 |   69.9K | 340 |   79.0 | 7.0 |  19.3 | 150.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'47'' |
| Q25L60X40P000 |   40.0 |  98.41% |     85211 | 4.14M | 138 |      7922 |  96.78K | 633 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'46'' |
| Q25L60X40P001 |   40.0 |  98.30% |     85203 | 4.14M | 126 |      7932 |  83.54K | 580 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'45'' |
| Q25L60X40P002 |   40.0 |  98.38% |     85647 | 4.14M | 122 |      7922 |  90.16K | 612 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'46'' |
| Q25L60X40P003 |   40.0 |  98.26% |     85658 | 4.14M | 137 |      7922 |  87.86K | 568 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'43'' |
| Q25L60X80P000 |   80.0 |  98.32% |    108184 | 4.14M |  93 |      7932 |  80.74K | 320 |   79.0 | 6.0 |  20.3 | 145.5 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'47'' |
| Q25L60X80P001 |   80.0 |  98.41% |    108211 | 4.14M |  91 |      7932 |  79.87K | 326 |   79.0 | 6.0 |  20.3 | 145.5 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'49'' |
| Q25L60X80P002 |   80.0 |  98.28% |     96056 | 4.14M |  97 |      7932 |  79.19K | 338 |   78.0 | 7.0 |  19.0 | 148.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'46'' |
| Q30L60X40P000 |   40.0 |  98.51% |     59915 | 4.14M | 163 |      7922 |  95.76K | 681 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'46'' |
| Q30L60X40P001 |   40.0 |  98.49% |     67389 | 4.14M | 143 |      7922 |  90.98K | 630 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'46'' |
| Q30L60X40P002 |   40.0 |  98.42% |     80054 | 4.13M | 127 |      7922 |  91.12K | 617 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'45'' |
| Q30L60X40P003 |   40.0 |  98.40% |     67574 | 4.14M | 150 |      7913 | 102.75K | 667 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'44'' |
| Q30L60X80P000 |   80.0 |  98.45% |     85674 | 4.14M | 103 |      7932 |  80.37K | 395 |   79.0 | 7.0 |  19.3 | 150.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'48'' |
| Q30L60X80P001 |   80.0 |  98.58% |    105472 | 4.14M | 103 |      7932 |  83.45K | 386 |   79.0 | 6.0 |  20.3 | 145.5 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'51'' |
| Q30L60X80P002 |   80.0 |  98.37% |     88764 | 4.14M | 102 |      7932 |  81.34K | 401 |   79.0 | 7.0 |  19.3 | 150.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'48'' |


Table: statMRKunitigsAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  96.93% |     88697 | 4.13M | 105 |      1113 |  43.1K | 286 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'40'' |
| MRX40P001 |   40.0 |  96.84% |     96752 | 4.13M | 105 |      1215 | 40.29K | 277 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'41'' |
| MRX40P002 |   40.0 |  97.43% |    105461 | 4.13M | 106 |      7659 | 45.65K | 278 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'41'' |
| MRX40P003 |   40.0 |  97.52% |     85135 | 4.13M | 108 |      7659 | 49.84K | 281 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'41'' |
| MRX80P000 |   80.0 |  96.69% |     84431 | 4.13M | 112 |      1113 | 41.82K | 298 |   78.0 | 7.0 |  19.0 | 148.5 | "31,41,51,61,71,81" | 0:01'32'' | 0:00'43'' |
| MRX80P001 |   80.0 |  97.34% |     80134 | 4.13M | 113 |      1735 |  48.5K | 295 |   78.0 | 7.0 |  19.0 | 148.5 | "31,41,51,61,71,81" | 0:01'33'' | 0:00'44'' |
| MRX80P002 |   80.0 |  97.22% |     80247 | 4.13M | 118 |      7659 | 49.97K | 301 |   77.0 | 7.5 |  18.2 | 149.2 | "31,41,51,61,71,81" | 0:01'33'' | 0:00'43'' |
| MRX80P003 |   80.0 |  97.41% |     80274 | 4.13M | 115 |      7659 | 50.32K | 303 |   78.0 | 7.0 |  19.0 | 148.5 | "31,41,51,61,71,81" | 0:01'33'' | 0:00'44'' |


Table: statMRTadpoleAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |  # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|---:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  96.82% |    100626 | 4.13M | 95 |      7932 | 76.25K | 198 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'35'' |
| MRX40P001 |   40.0 |  96.79% |    108098 | 4.13M | 89 |      7932 | 80.79K | 189 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'35'' |
| MRX40P002 |   40.0 |  96.75% |    108184 | 4.13M | 92 |      7932 | 79.56K | 194 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'35'' |
| MRX40P003 |   40.0 |  96.76% |    108152 | 4.13M | 88 |      7932 | 80.33K | 193 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'35'' |
| MRX80P000 |   80.0 |  96.76% |    108150 | 4.13M | 92 |      7932 | 82.89K | 199 |   79.0 | 7.0 |  19.3 | 150.0 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'37'' |
| MRX80P001 |   80.0 |  96.71% |    108163 | 4.13M | 92 |      7932 | 81.71K | 198 |   79.0 | 7.0 |  19.3 | 150.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'37'' |
| MRX80P002 |   80.0 |  96.69% |     88664 | 4.13M | 96 |      7932 | 82.99K | 207 |   79.0 | 8.0 |  18.3 | 154.5 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'36'' |
| MRX80P003 |   80.0 |  96.74% |    108153 | 4.13M | 93 |      7932 | 83.16K | 201 |   79.0 | 7.0 |  19.3 | 150.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'36'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |   Sum |  # | N50Others |     Sum |   # | median |  MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|------:|---:|----------:|--------:|----:|-------:|-----:|------:|------:|----------:|
| 7_mergeAnchors           |  96.61% |    108123 | 4.15M | 82 |      7942 |   1.83M | 281 |  265.0 | 16.5 |  71.8 | 471.8 | 0:01'02'' |
| 7_mergeKunitigsAnchors   |  98.36% |    108184 |  4.2M | 89 |      7961 | 147.43K |  52 |  259.0 | 20.0 |  66.3 | 478.5 | 0:01'46'' |
| 7_mergeMRKunitigsAnchors |  98.19% |    108153 | 4.13M | 86 |      7961 |  69.99K |  18 |  261.0 | 18.0 |  69.0 | 472.5 | 0:01'35'' |
| 7_mergeMRTadpoleAnchors  |  98.29% |    108153 | 4.15M | 83 |      7942 |  697.8K |  96 |  261.0 | 19.0 |  68.0 | 477.0 | 0:01'40'' |
| 7_mergeTadpoleAnchors    |  98.22% |    108177 | 4.14M | 88 |      7942 |   1.33M | 207 |  266.0 | 16.5 |  72.2 | 473.2 | 0:01'37'' |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |   Sum |  # | N50Others |    Sum |   # | median |  MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|------:|---:|----------:|-------:|----:|-------:|-----:|------:|------:|----------:|
| 8_spades     |  98.94% |    227374 | 4.15M | 46 |      7659 | 43.07K |  93 |  263.0 | 27.0 |  60.7 | 516.0 | 0:00'53'' |
| 8_spades_MR  |  98.74% |    225840 | 4.17M | 35 |      7659 | 39.13K |  75 |  447.0 | 45.0 | 104.0 | 873.0 | 0:00'53'' |
| 8_megahit    |  98.46% |    108206 | 4.14M | 90 |      7659 | 42.29K | 191 |  262.0 | 19.0 |  68.3 | 478.5 | 0:00'54'' |
| 8_megahit_MR |  99.06% |    142615 | 4.17M | 77 |      2804 | 51.48K | 167 |  447.0 | 36.5 | 112.5 | 834.8 | 0:00'57'' |
| 8_platanus   |  97.84% |    224881 | 4.15M | 51 |      7970 | 34.66K |  99 |  263.0 | 25.5 |  62.2 | 509.2 | 0:00'53'' |


Table: statFinal

| Name                     |     N50 |     Sum |   # |
|:-------------------------|--------:|--------:|----:|
| Genome                   | 4290252 | 4298133 |   2 |
| Paralogs                 |    3242 |  328828 | 121 |
| 7_mergeAnchors.anchors   |  108123 | 4151021 |  82 |
| 7_mergeAnchors.others    |    7942 | 1825633 | 281 |
| anchorLong               |  137644 | 4150358 |  81 |
| anchorFill               |  108123 | 1171243 |  26 |
| spades.contig            |  227405 | 4223931 | 207 |
| spades.scaffold          |  227405 | 4223951 | 205 |
| spades.non-contained     |  227405 | 4194335 |  47 |
| spades_MR.contig         |  225584 | 4221395 |  84 |
| spades_MR.scaffold       |  225921 | 4221405 |  83 |
| spades_MR.non-contained  |  225584 | 4204908 |  40 |
| megahit.contig           |  108263 | 4207110 | 166 |
| megahit.non-contained    |  108263 | 4181897 | 101 |
| megahit_MR.contig        |  142854 | 4302719 | 302 |
| megahit_MR.non-contained |  142854 | 4223517 |  90 |
| platanus.contig          |  122109 | 4271525 | 619 |
| platanus.scaffold        |  225740 | 4239248 | 410 |
| platanus.non-contained   |  225740 | 4184470 |  48 |


# Campylobacter jejuni subsp. jejuni ATCC 700819, 空肠弯曲杆菌

Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Cjej: download

* Reference genome

    * Strain: Campylobacter jejuni subsp. jejuni NCTC 11168 = ATCC 700819
    * Taxid:
      [192222](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=192222&lvl=3&lin=f&keep=1&srchmode=1&unlock)
    * RefSeq assembly accession:
      [GCF_000009085.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/009/085/GCF_000009085.1_ASM908v1/GCF_000009085.1_ASM908v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0196

```bash
mkdir -p ${HOME}/data/anchr/Cjej/1_genome
cd ${HOME}/data/anchr/Cjej/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/009/085/GCF_000009085.1_ASM908v1/GCF_000009085.1_ASM908v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_002163.1${TAB}1
EOF

faops replace GCF_000009085.1_ASM908v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Cjej/Cjej.multi.fas paralogs.fa

```

* Illumina

    * [SRX2107012](https://www.ncbi.nlm.nih.gov/sra/SRX2107012) SRR4125016

```bash
mkdir -p ${HOME}/data/anchr/Cjej/2_illumina
cd ${HOME}/data/anchr/Cjej/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR412/006/SRR4125016/SRR4125016_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR412/006/SRR4125016/SRR4125016_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
445c3f44b04c52168409a4274d346b22 SRR4125016_1.fastq.gz
95f3fa6259c4684601f039b79c23648c SRR4125016_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s SRR4125016_1.fastq.gz R1.fq.gz
ln -s SRR4125016_2.fastq.gz R2.fq.gz

```

* PacBio

    * [SRX2107011](https://www.ncbi.nlm.nih.gov/sra/SRX2107011) SRR4125017

## Cjej: template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Cjej

cd ${WORKING_DIR}/${BASE_NAME}

rm *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 1641481 \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --sgastats \
    --trim2 "--dedupe --cutoff 5 --cutk 31" \
    --sample 300 \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,artifact" \
    --mergereads \
    --ecphase "1,2,3" \
    --cov2 "40 80" \
    --tadpole \
    --statp 3 \
    --redoanchors \
    --fillanchor \
    --parallel 24 \
    --xmx 110g

```

## Cjej: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Cjej

cd ${WORKING_DIR}/${BASE_NAME}
#rm -fr 4_*/ 6_*/ 7_*/ 8_*/ && rm -fr 2_illumina/trim 2_illumina/mergereads statReads.md 

bash 0_bsub.sh
#bkill -J "${BASE_NAME}-*"

#bash 0_master.sh
#bash 0_cleanup.sh

```

Table: statInsertSize

| Group             |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:------------------|------:|-------:|-------:|-------------------------------:|
| R.genome.bbtools  | 434.6 |    300 | 2204.8 |                         49.43% |
| R.tadpole.bbtools | 310.2 |    299 |  103.9 |                         48.24% |
| R.genome.picard   | 310.8 |    300 |   86.6 |                             FR |
| R.tadpole.picard  | 309.9 |    299 |   86.5 |                             FR |


Table: statSgaStats

| Library | incorrectBases | perfectReads | overlapDepth |
|:--------|---------------:|-------------:|-------------:|
| R       |          0.10% |       93.40% |       774.86 |


Table: statReads

| Name       |     N50 |     Sum |        # |
|:-----------|--------:|--------:|---------:|
| Genome     | 1641481 | 1641481 |        1 |
| Paralogs   |    6093 |   33281 |       13 |
| Illumina.R |     101 |   1.55G | 15393600 |
| trim.R     |     100 | 475.35M |  4775762 |
| Q20L60     |     100 |    472M |  4740866 |
| Q25L60     |     100 | 462.93M |  4661322 |
| Q30L60     |     100 | 439.28M |  4466590 |


Table: statTrimReads

| Name     | N50 |     Sum |        # |
|:---------|----:|--------:|---------:|
| clumpify | 101 |   1.54G | 15283902 |
| highpass | 101 |   1.54G | 15227606 |
| sample   | 101 | 492.44M |  4875686 |
| trim     | 100 | 475.45M |  4776800 |
| filter   | 100 | 475.35M |  4775762 |
| R1       | 100 | 237.94M |  2387881 |
| R2       | 100 |  237.4M |  2387881 |
| Rs       |   0 |       0 |        0 |


```text
#R.trim
#Matched	3609	0.07402%
#Name	Reads	ReadsPct
```

```text
#R.filter
#Matched	1038	0.02173%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	1038	0.02173%
```

```text
#R.peaks
#k	31
#unique_kmers	7493598
#main_peak	197
#genome_size	1640040
#haploid_genome_size	1640040
#fold_coverage	197
#haploid_fold_coverage	197
#ploidy	1
#percent_repeat	2.500
#start	center	stop	max	volume
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 100 | 475.34M | 4775694 |
| ecco          | 100 | 475.34M | 4775694 |
| eccc          | 100 | 475.34M | 4775694 |
| ecct          | 100 | 472.68M | 4748666 |
| extended      | 140 | 662.24M | 4748666 |
| merged.raw    | 333 | 618.27M | 1931684 |
| unmerged.raw  | 140 | 122.85M |  885298 |
| unmerged.trim | 140 | 122.85M |  885290 |
| M1            | 333 | 617.76M | 1930108 |
| U1            | 140 |  61.63M |  442645 |
| U2            | 140 |  61.22M |  442645 |
| Us            |   0 |       0 |       0 |
| M.cor         | 317 | 742.54M | 4745506 |

| Group              |  Mean | Median | STDev | PercentOfPairs |
|:-------------------|------:|-------:|------:|---------------:|
| M.ihist.merge1.txt | 159.4 |    164 |  20.8 |          4.69% |
| M.ihist.merge.txt  | 320.1 |    321 |  58.6 |         81.36% |


Table: statQuorum

| Name     | CovIn | CovOut | Discard% | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:---------|------:|-------:|---------:|-----:|------:|------:|---------:|----------:|
| Q0L0.R   | 289.6 |  273.0 |    5.72% | "71" | 1.64M | 1.62M |     0.99 | 0:00'54'' |
| Q20L60.R | 287.6 |  272.2 |    5.35% | "71" | 1.64M | 1.62M |     0.99 | 0:00'53'' |
| Q25L60.R | 282.1 |  268.9 |    4.66% | "71" | 1.64M | 1.62M |     0.99 | 0:00'52'' |
| Q30L60.R | 267.7 |  257.5 |    3.79% | "71" | 1.64M | 1.62M |     0.99 | 0:00'52'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |  # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|---:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  98.80% |     79960 | 1.59M | 52 |      2340 | 16.35K | 239 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'39'' |
| Q0L0X40P001   |   40.0 |  98.82% |     48841 | 1.59M | 60 |      1035 |  18.6K | 242 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'19'' | 0:00'38'' |
| Q0L0X40P002   |   40.0 |  98.75% |     60147 | 1.59M | 49 |      1060 |  19.1K | 233 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'38'' |
| Q0L0X40P003   |   40.0 |  98.71% |     56877 |  1.6M | 56 |      2340 | 15.14K | 250 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'19'' | 0:00'37'' |
| Q0L0X80P000   |   80.0 |  98.36% |     55870 | 1.59M | 59 |      2340 | 12.44K | 135 |   80.0 | 4.0 |  22.7 | 138.0 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'35'' |
| Q0L0X80P001   |   80.0 |  98.33% |     50152 | 1.59M | 62 |      2340 | 12.39K | 144 |   79.0 | 4.0 |  22.3 | 136.5 | "31,41,51,61,71,81" | 0:00'27'' | 0:00'37'' |
| Q0L0X80P002   |   80.0 |  98.40% |     68587 | 1.59M | 55 |      2340 | 12.39K | 135 |   80.0 | 4.0 |  22.7 | 138.0 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'37'' |
| Q20L60X40P000 |   40.0 |  98.86% |     67405 | 1.59M | 55 |       683 | 16.86K | 252 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'40'' |
| Q20L60X40P001 |   40.0 |  98.95% |     60495 | 1.59M | 54 |      2340 | 16.57K | 252 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'39'' |
| Q20L60X40P002 |   40.0 |  98.83% |     70809 |  1.6M | 51 |      2340 |  15.1K | 242 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'19'' | 0:00'38'' |
| Q20L60X40P003 |   40.0 |  98.79% |     70827 | 1.59M | 45 |      2340 | 14.94K | 222 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'38'' |
| Q20L60X80P000 |   80.0 |  98.43% |     57916 | 1.59M | 54 |      6071 | 12.11K | 129 |   80.0 | 4.0 |  22.7 | 138.0 | "31,41,51,61,71,81" | 0:00'27'' | 0:00'37'' |
| Q20L60X80P001 |   80.0 |  98.35% |     71543 | 1.59M | 54 |      2340 | 12.23K | 131 |   80.0 | 4.0 |  22.7 | 138.0 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'37'' |
| Q20L60X80P002 |   80.0 |  98.32% |     56898 | 1.59M | 57 |      2340 | 12.49K | 135 |   80.0 | 4.0 |  22.7 | 138.0 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'36'' |
| Q25L60X40P000 |   40.0 |  98.89% |     61065 | 1.59M | 54 |      2340 | 15.63K | 244 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'19'' | 0:00'39'' |
| Q25L60X40P001 |   40.0 |  98.79% |     66832 |  1.6M | 50 |      2340 | 15.38K | 220 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'37'' |
| Q25L60X40P002 |   40.0 |  98.86% |     60513 | 1.59M | 55 |      1032 | 16.88K | 239 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'38'' |
| Q25L60X40P003 |   40.0 |  98.74% |     57877 |  1.6M | 53 |      2340 | 14.52K | 225 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'19'' | 0:00'37'' |
| Q25L60X80P000 |   80.0 |  98.38% |     71550 | 1.59M | 49 |      2340 |  11.9K | 124 |   80.0 | 4.0 |  22.7 | 138.0 | "31,41,51,61,71,81" | 0:00'27'' | 0:00'37'' |
| Q25L60X80P001 |   80.0 |  98.45% |     69724 | 1.59M | 55 |      2340 | 12.71K | 146 |   80.0 | 4.0 |  22.7 | 138.0 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'37'' |
| Q25L60X80P002 |   80.0 |  98.35% |     78345 | 1.59M | 51 |      6071 | 11.81K | 126 |   80.0 | 4.0 |  22.7 | 138.0 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'37'' |
| Q30L60X40P000 |   40.0 |  98.87% |     70810 | 1.59M | 48 |      2340 | 16.56K | 236 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'19'' | 0:00'38'' |
| Q30L60X40P001 |   40.0 |  98.83% |     62520 | 1.59M | 58 |       851 | 17.63K | 249 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'38'' |
| Q30L60X40P002 |   40.0 |  98.86% |     63298 | 1.59M | 53 |      2340 | 15.03K | 249 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'19'' | 0:00'39'' |
| Q30L60X40P003 |   40.0 |  98.94% |     56890 | 1.59M | 54 |       761 | 17.79K | 240 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'39'' |
| Q30L60X80P000 |   80.0 |  98.48% |     71552 | 1.59M | 48 |      2340 | 12.73K | 136 |   79.0 | 4.0 |  22.3 | 136.5 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'38'' |
| Q30L60X80P001 |   80.0 |  98.53% |     68577 | 1.59M | 49 |      2340 |  12.3K | 140 |   80.0 | 5.0 |  21.7 | 142.5 | "31,41,51,61,71,81" | 0:00'27'' | 0:00'38'' |
| Q30L60X80P002 |   80.0 |  98.61% |     66767 | 1.59M | 50 |      2340 | 13.23K | 144 |   79.0 | 4.0 |  22.3 | 136.5 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'37'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |  # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|---:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  98.89% |     71555 | 1.59M | 47 |      2338 | 16.52K | 202 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'25'' | 0:00'39'' |
| Q0L0X40P001   |   40.0 |  98.88% |     53648 |  1.6M | 61 |      1074 | 17.87K | 232 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'26'' | 0:00'39'' |
| Q0L0X40P002   |   40.0 |  98.82% |     71529 | 1.59M | 41 |      1053 | 18.02K | 183 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'25'' | 0:00'39'' |
| Q0L0X40P003   |   40.0 |  99.02% |     79903 |  1.6M | 41 |      2338 | 15.63K | 200 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'27'' | 0:00'39'' |
| Q0L0X80P000   |   80.0 |  98.72% |     84057 | 1.59M | 40 |      2338 | 13.42K | 130 |   80.0 | 4.5 |  22.2 | 140.2 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'38'' |
| Q0L0X80P001   |   80.0 |  98.74% |     79993 | 1.59M | 41 |      2338 | 12.47K | 142 |   80.0 | 6.0 |  20.7 | 147.0 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'39'' |
| Q0L0X80P002   |   80.0 |  98.77% |     80007 | 1.59M | 40 |      6069 | 12.11K | 119 |   79.0 | 3.0 |  23.3 | 132.0 | "31,41,51,61,71,81" | 0:00'27'' | 0:00'39'' |
| Q20L60X40P000 |   40.0 |  98.90% |     56890 |  1.6M | 57 |      1051 | 18.62K | 252 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'24'' | 0:00'39'' |
| Q20L60X40P001 |   40.0 |  98.88% |     74873 |  1.6M | 44 |      2338 | 16.52K | 199 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'26'' | 0:00'37'' |
| Q20L60X40P002 |   40.0 |  99.01% |     70806 |  1.6M | 53 |      2338 |  15.3K | 211 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'26'' | 0:00'38'' |
| Q20L60X40P003 |   40.0 |  98.76% |     71554 | 1.59M | 41 |      2338 | 13.56K | 182 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'25'' | 0:00'38'' |
| Q20L60X80P000 |   80.0 |  98.72% |     70888 | 1.59M | 45 |      2338 | 12.21K | 128 |   79.0 | 4.0 |  22.3 | 136.5 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'39'' |
| Q20L60X80P001 |   80.0 |  98.55% |     79985 | 1.59M | 43 |      6069 | 11.86K | 120 |   79.0 | 4.0 |  22.3 | 136.5 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'37'' |
| Q20L60X80P002 |   80.0 |  98.55% |     80754 | 1.59M | 41 |      6069 | 11.87K | 108 |   80.0 | 4.0 |  22.7 | 138.0 | "31,41,51,61,71,81" | 0:00'30'' | 0:00'37'' |
| Q25L60X40P000 |   40.0 |  98.92% |     60516 | 1.59M | 50 |      2710 | 15.69K | 210 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'26'' | 0:00'38'' |
| Q25L60X40P001 |   40.0 |  98.93% |     71580 |  1.6M | 47 |      2338 | 14.89K | 202 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'26'' | 0:00'37'' |
| Q25L60X40P002 |   40.0 |  98.78% |     71529 |  1.6M | 45 |      2338 | 13.76K | 196 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'25'' | 0:00'38'' |
| Q25L60X40P003 |   40.0 |  98.89% |     80748 |  1.6M | 44 |      2338 | 14.89K | 200 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'26'' | 0:00'39'' |
| Q25L60X80P000 |   80.0 |  98.78% |     80747 | 1.59M | 38 |      6069 | 11.96K | 123 |   79.0 | 4.5 |  21.8 | 138.8 | "31,41,51,61,71,81" | 0:00'30'' | 0:00'39'' |
| Q25L60X80P001 |   80.0 |  98.75% |     81895 | 1.59M | 39 |      2338 | 12.16K | 124 |   80.0 | 4.0 |  22.7 | 138.0 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'39'' |
| Q25L60X80P002 |   80.0 |  98.92% |     79931 | 1.59M | 40 |      2338 | 12.71K | 142 |   80.0 | 4.0 |  22.7 | 138.0 | "31,41,51,61,71,81" | 0:00'30'' | 0:00'40'' |
| Q30L60X40P000 |   40.0 |  98.93% |     51906 | 1.59M | 60 |      1005 | 20.93K | 248 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'24'' | 0:00'39'' |
| Q30L60X40P001 |   40.0 |  98.85% |     79953 | 1.59M | 43 |      2338 | 15.66K | 218 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'39'' |
| Q30L60X40P002 |   40.0 |  99.04% |     71545 | 1.59M | 48 |      1039 | 16.89K | 221 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'25'' | 0:00'38'' |
| Q30L60X40P003 |   40.0 |  98.80% |     70887 | 1.59M | 46 |      2338 | 15.45K | 198 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'26'' | 0:00'37'' |
| Q30L60X80P000 |   80.0 |  98.81% |     75176 | 1.59M | 44 |      2338 | 13.78K | 164 |   79.0 | 4.0 |  22.3 | 136.5 | "31,41,51,61,71,81" | 0:00'30'' | 0:00'40'' |
| Q30L60X80P001 |   80.0 |  98.64% |     79919 | 1.59M | 44 |      2338 | 12.52K | 142 |   80.0 | 5.0 |  21.7 | 142.5 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'38'' |
| Q30L60X80P002 |   80.0 |  98.76% |     75169 | 1.59M | 43 |      2338 | 13.11K | 142 |   80.0 | 4.5 |  22.2 | 140.2 | "31,41,51,61,71,81" | 0:00'30'' | 0:00'38'' |


Table: statMRKunitigsAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |  # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|---:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  97.87% |     79879 | 1.59M | 44 |      2340 | 14.06K | 101 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'27'' | 0:00'35'' |
| MRX40P001 |   40.0 |  97.94% |     79901 | 1.59M | 46 |      2340 | 14.91K | 109 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'26'' | 0:00'36'' |
| MRX40P002 |   40.0 |  98.05% |     79894 | 1.59M | 46 |      2340 | 14.56K | 113 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'27'' | 0:00'36'' |
| MRX40P003 |   40.0 |  97.95% |     79807 | 1.59M | 45 |      2340 | 14.12K | 105 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'26'' | 0:00'35'' |
| MRX80P000 |   80.0 |  97.72% |     71530 | 1.59M | 55 |      2340 | 14.51K | 122 |   79.0 | 6.0 |  20.3 | 145.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'36'' |
| MRX80P001 |   80.0 |  97.78% |     78351 | 1.59M | 53 |      2340 | 14.71K | 120 |   79.0 | 5.0 |  21.3 | 141.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'36'' |
| MRX80P002 |   80.0 |  97.88% |     70513 | 1.59M | 55 |      2340 | 14.97K | 128 |   80.0 | 6.0 |  20.7 | 147.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'36'' |
| MRX80P003 |   80.0 |  97.77% |     64688 | 1.59M | 55 |      2340 | 15.28K | 126 |   79.0 | 5.0 |  21.3 | 141.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'36'' |


Table: statMRTadpoleAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |  # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|---:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  98.07% |     90148 | 1.59M | 35 |      2338 | 12.86K |  83 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'36'' |
| MRX40P001 |   40.0 |  98.06% |     81863 | 1.59M | 35 |      2338 | 13.11K |  84 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'30'' | 0:00'36'' |
| MRX40P002 |   40.0 |  98.06% |     64192 | 1.59M | 44 |      2338 | 13.85K | 103 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'35'' |
| MRX40P003 |   40.0 |  98.09% |     80600 | 1.59M | 37 |      2338 | 13.07K |  87 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'26'' | 0:00'35'' |
| MRX80P000 |   80.0 |  97.79% |     79890 | 1.59M | 39 |      2338 | 12.64K |  81 |   79.0 | 5.0 |  21.3 | 141.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'36'' |
| MRX80P001 |   80.0 |  97.88% |     80588 | 1.59M | 40 |      2338 | 12.91K |  86 |   79.0 | 4.5 |  21.8 | 138.8 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'34'' |
| MRX80P002 |   80.0 |  97.92% |     80675 | 1.59M | 41 |      2338 | 12.75K |  86 |   79.0 | 5.0 |  21.3 | 141.0 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'36'' |
| MRX80P003 |   80.0 |  97.82% |     79894 | 1.59M | 45 |      2338 | 13.44K |  92 |   79.0 | 5.0 |  21.3 | 141.0 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'36'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |   Sum |  # | N50Others |    Sum |  # | median |  MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|------:|---:|----------:|-------:|---:|-------:|-----:|------:|------:|----------:|
| 7_mergeAnchors           |  97.41% |    104590 |  1.6M | 27 |      2710 | 65.86K | 34 |  270.0 | 11.0 |  79.0 | 454.5 | 0:00'44'' |
| 7_mergeKunitigsAnchors   |  99.00% |    104631 |  1.6M | 29 |      1071 | 22.46K | 16 |  274.0 | 14.0 |  77.3 | 474.0 | 0:01'05'' |
| 7_mergeMRKunitigsAnchors |  98.96% |     81827 | 1.59M | 33 |     15743 | 49.65K |  7 |  272.0 | 15.0 |  75.7 | 475.5 | 0:01'06'' |
| 7_mergeMRTadpoleAnchors  |  98.98% |    104129 | 1.59M | 29 |      7299 | 43.31K |  6 |  273.0 | 15.0 |  76.0 | 477.0 | 0:01'07'' |
| 7_mergeTadpoleAnchors    |  99.08% |    104145 |  1.6M | 29 |      1253 | 44.63K | 27 |  272.0 | 14.0 |  76.7 | 471.0 | 0:01'10'' |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |   Sum |  # | N50Others |    Sum |  # | median |  MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|------:|---:|----------:|-------:|---:|-------:|-----:|------:|------:|----------:|
| 8_spades     |  99.36% |    115704 |  1.6M | 22 |      2420 | 16.34K | 39 |  272.0 | 18.0 |  72.7 | 489.0 | 0:00'41'' |
| 8_spades_MR  |  99.48% |    153954 | 1.61M | 14 |      2340 | 12.87K | 30 |  450.0 | 34.0 | 116.0 | 828.0 | 0:00'44'' |
| 8_megahit    |  98.60% |    112475 |  1.6M | 26 |      6071 | 10.89K | 54 |  272.0 | 16.5 |  74.2 | 482.2 | 0:00'47'' |
| 8_megahit_MR |  99.26% |    115896 | 1.61M | 24 |      2340 | 13.16K | 52 |  449.0 | 35.0 | 114.7 | 831.0 | 0:00'43'' |
| 8_platanus   |  98.79% |    153834 |  1.6M | 24 |      5981 |  9.86K | 44 |  272.0 | 15.5 |  75.2 | 477.8 | 0:00'43'' |


Table: statFinal

| Name                     |     N50 |     Sum |   # |
|:-------------------------|--------:|--------:|----:|
| Genome                   | 1641481 | 1641481 |   1 |
| Paralogs                 |    6093 |   33281 |  13 |
| 7_mergeAnchors.anchors   |  104590 | 1595929 |  27 |
| 7_mergeAnchors.others    |    2710 |   65859 |  34 |
| anchorLong               |  112382 | 1594022 |  24 |
| anchorFill               |  153835 | 1606897 |  13 |
| spades.contig            |  153957 | 1622832 |  32 |
| spades.scaffold          |  189386 | 1622852 |  30 |
| spades.non-contained     |  153957 | 1616721 |  17 |
| spades_MR.contig         |  189483 | 1624523 |  20 |
| spades_MR.scaffold       |  189483 | 1624523 |  20 |
| spades_MR.non-contained  |  189483 | 1623085 |  16 |
| megahit.contig           |  112536 | 1623229 |  68 |
| megahit.non-contained    |  112536 | 1606528 |  28 |
| megahit_MR.contig        |  115984 | 1637855 |  65 |
| megahit_MR.non-contained |  115984 | 1622232 |  28 |
| platanus.contig          |  112552 | 1629712 | 117 |
| platanus.scaffold        |  153893 | 1622171 |  69 |
| platanus.non-contained   |  153893 | 1610857 |  20 |


# Escherichia virus Lambda

Project [SRP055199](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP055199)

## lambda: download

* Reference genome

    * Strain: Escherichia virus Lambda (viruses)
    * Taxid:
      [10710](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=10710&lvl=3&lin=f&keep=1&srchmode=1&unlock)
    * RefSeq assembly accession:
      [GCF_000840245.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/840/245/GCF_000840245.1_ViralProj14204/GCF_000840245.1_ViralProj14204_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0

```bash
mkdir -p${HOME}/data/anchr/lambda/1_genome
cd ${HOME}/data/anchr/lambda/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/840/245/GCF_000840245.1_ViralProj14204/GCF_000840245.1_ViralProj14204_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_001416.1${TAB}1
EOF

faops replace GCF_000840245.1_ViralProj14204_genomic.fna.gz replace.tsv genome.fa

#cp ~/data/anchr/paralogs/otherbac/Results/lambda/lambda.multi.fas paralogs.fa
touch paralogs.fa

```

* Illumina

    * [SRX2365802](https://www.ncbi.nlm.nih.gov/sra/SRR5042715)

```bash
mkdir -p ${HOME}/data/anchr/lambda/2_illumina
cd ${HOME}/data/anchr/lambda/2_illumina

aria2c -x 9 -s 3 -c https://sra-download.ncbi.nlm.nih.gov/traces/sra16/SRR/004924/SRR5042715
fastq-dump --split-files ./SRR5042715

find . -type f -name "*.fastq" | parallel -j 2 pigz -p 8 

ln -s SRR5042715_1.fastq.gz R1.fq.gz
ln -s SRR5042715_2.fastq.gz R2.fq.gz

```

* PacBio

```bash
mkdir -p ${HOME}/data/anchr/lambda/3_pacbio
cd ${HOME}/data/anchr/lambda/3_pacbio

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR179/005/SRR1796325/SRR1796325.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
2c663d7ea426eea0aaba9017e1a9168c SRR1796325.fastq.gz
EOF

md5sum --check sra_md5.txt

cd ~/data/anchr/lambda
faops filter -l 0 3_pacbio/SRR1796325.fastq.gz 3_pacbio/pacbio.fasta

```

## lambda: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=lambda

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 48502 \
    --trim2 "--uniq --bbduk" \
    --sample 300 \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,artifact" \
    --tadpole \
    --cov3 "80 all" \
    --qual3 "trim" \
    --mergereads \
    --ecphase "1,3" \
    --insertsize \
    --parallel 16

# run
bash 0_master.sh

bash 0_cleanup.sh

```

Table: statInsertSize

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| genome.bbtools  | 431.5 |    413 | 373.8 |                         47.89% |
| tadpole.bbtools | 419.3 |    408 | 101.7 |                         40.68% |
| genome.picard   | 425.5 |    413 | 103.2 |                             FR |
| tadpole.picard  | 419.1 |    407 | 101.5 |                             FR |


Table: statReads

| Name      |   N50 |    Sum |        # |
|:----------|------:|-------:|---------:|
| Genome    | 48502 |  48502 |        1 |
| Paralogs  |     0 |      0 |        0 |
| Illumina  |   108 |  3.57G | 33080474 |
| uniq      |   108 |  2.98G | 27609894 |
| sample    |   108 | 14.55M |   134728 |
| bbduk     |   105 | 13.81M |   131544 |
| Q25L60    |   105 | 12.34M |   120685 |
| Q30L60    |   105 | 11.02M |   111211 |
| PacBio    |  1325 | 11.95M |     9796 |
| X80.raw   |  1361 |  3.88M |     3084 |
| X80.trim  |  1453 |  3.06M |     2133 |
| Xall.raw  |  1325 | 11.95M |     9796 |
| Xall.trim |  1427 |  9.23M |     6538 |

```text
#trimmedReads
#Matched        3257    2.41746%
#Name   Reads   ReadsPct
Reverse_adapter 1613    1.19723%
TruSeq_Universal_Adapter        1560    1.15789%
```


Table: statMergeReads

| Name         | N50 |     Sum |       # |
|:-------------|----:|--------:|--------:|
| clumped      | 108 | 510.22M | 4724265 |
| trimmed      | 105 | 292.52M | 3029361 |
| filtered     | 105 | 292.52M | 3029328 |
| ecco         | 105 | 292.24M | 3029328 |
| ecct         | 105 | 282.38M | 2918223 |
| extended     | 145 | 392.98M | 2918223 |
| merged       | 157 |   6.73M |   42741 |
| unmerged.raw | 145 | 381.53M | 2832740 |
| unmerged     | 145 | 327.38M | 2585807 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 114.2 |    111 |  24.9 |          2.20% |
| ihist.merge.txt  | 157.4 |    152 |  36.4 |          2.93% |

```text
#trimmedReads
#Matched        639099  13.52801%
#Name   Reads   ReadsPct
Reverse_adapter 319828  6.76990%
TruSeq_Universal_Adapter        309202  6.54498%
pcr_dimer       2152    0.04555%
TruSeq_Adapter_Index_1_6        1512    0.03200%
PCR_Primers     1439    0.03046%
RNA_PCR_Primer_Index_26_(RPI26) 1357    0.02872%
```

```text
#filteredReads
#Matched        33      0.00109%
#Name   Reads   ReadsPct
```


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|-------:|---------:|----------:|
| Q25L60 | 254.6 |  244.1 |    4.15% |     102 | "73" | 48.5K | 48.52K |     1.00 | 0:00'07'' |
| Q30L60 | 227.4 |  220.6 |    3.02% |     100 | "73" | 48.5K | 48.48K |     1.00 | 0:00'06'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |    Sum | # | N50Others |   Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|-------:|--:|----------:|------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |  99.97% |     48044 | 48.04K | 1 |       212 |   360 |  2 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'04'' | 0:00'18'' |
| Q25L60X40P001 |   40.0 |  99.98% |     47937 | 47.94K | 1 |       210 |   389 |  2 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'04'' | 0:00'17'' |
| Q25L60X40P002 |   40.0 |  99.96% |     47994 | 47.99K | 1 |       248 |   352 |  2 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'04'' | 0:00'17'' |
| Q25L60X40P003 |   40.0 |  99.96% |     29109 | 48.05K | 2 |      2710 | 3.41K | 11 |   39.0 | 0.0 |  13.0 |  58.5 | "31,41,51,61,71,81" | 0:00'04'' | 0:00'19'' |
| Q25L60X40P004 |   40.0 |  99.93% |     47974 | 47.97K | 1 |       258 |   385 |  2 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'04'' | 0:00'17'' |
| Q25L60X40P005 |   40.0 |  99.97% |     48080 | 48.08K | 1 |       205 |   304 |  2 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'04'' | 0:00'17'' |
| Q25L60X80P000 |   80.0 |  99.99% |     48053 | 48.05K | 1 |       206 |   355 |  2 |   80.0 | 0.0 |  20.0 | 120.0 | "31,41,51,61,71,81" | 0:00'05'' | 0:00'18'' |
| Q25L60X80P001 |   80.0 |  99.97% |     29132 | 48.11K | 2 |       214 |   607 |  8 |   80.0 | 2.0 |  20.0 | 129.0 | "31,41,51,61,71,81" | 0:00'04'' | 0:00'18'' |
| Q25L60X80P002 |   80.0 |  99.99% |     48093 | 48.09K | 1 |       227 |   422 |  2 |   79.0 | 0.0 |  20.0 | 118.5 | "31,41,51,61,71,81" | 0:00'05'' | 0:00'18'' |
| Q30L60X40P000 |   40.0 |  99.98% |     48013 | 48.01K | 1 |       228 |   588 |  4 |   41.0 | 1.0 |  12.7 |  66.0 | "31,41,51,61,71,81" | 0:00'05'' | 0:00'18'' |
| Q30L60X40P001 |   40.0 |  99.99% |     48104 |  48.1K | 1 |       189 |   657 |  6 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'04'' | 0:00'18'' |
| Q30L60X40P002 |   40.0 |  99.99% |     47995 |    48K | 1 |       220 |   660 |  6 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'04'' | 0:00'18'' |
| Q30L60X40P003 |   40.0 |  99.97% |     48028 | 48.03K | 1 |       181 |   571 |  4 |   39.5 | 0.5 |  12.7 |  61.5 | "31,41,51,61,71,81" | 0:00'04'' | 0:00'18'' |
| Q30L60X40P004 |   40.0 |  99.96% |     47990 | 47.99K | 1 |       202 |   266 |  2 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'04'' | 0:00'18'' |
| Q30L60X80P000 |   80.0 |  99.99% |     48101 |  48.1K | 1 |       219 |   413 |  2 |   79.0 | 0.0 |  20.0 | 118.5 | "31,41,51,61,71,81" | 0:00'04'' | 0:00'18'' |
| Q30L60X80P001 |   80.0 |  99.99% |     48057 | 48.06K | 1 |       254 |   457 |  2 |   79.0 | 0.0 |  20.0 | 118.5 | "31,41,51,61,71,81" | 0:00'04'' | 0:00'18'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |    Sum | # | N50Others | Sum | # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|-------:|--:|----------:|----:|--:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |  99.96% |     48044 | 48.04K | 1 |       148 | 273 | 2 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'15'' | 0:00'17'' |
| Q25L60X40P001 |   40.0 |  99.96% |     47937 | 47.94K | 1 |       210 | 280 | 2 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'15'' | 0:00'17'' |
| Q25L60X40P002 |   40.0 |  99.95% |     47986 | 47.99K | 1 |       153 | 248 | 2 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'15'' | 0:00'17'' |
| Q25L60X40P003 |   40.0 |  99.95% |     48027 | 48.03K | 1 |       218 | 352 | 2 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'15'' | 0:00'17'' |
| Q25L60X40P004 |   40.0 |  99.93% |     47974 | 47.97K | 1 |       258 | 357 | 2 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'14'' | 0:00'17'' |
| Q25L60X40P005 |   40.0 |  99.93% |     48080 | 48.08K | 1 |        99 | 198 | 2 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'14'' | 0:00'17'' |
| Q25L60X80P000 |   80.0 |  99.99% |     48053 | 48.05K | 1 |       206 | 355 | 2 |   80.0 | 0.0 |  20.0 | 120.0 | "31,41,51,61,71,81" | 0:00'16'' | 0:00'18'' |
| Q25L60X80P001 |   80.0 |  99.98% |     48076 | 48.08K | 1 |       224 | 438 | 2 |   79.0 | 0.0 |  20.0 | 118.5 | "31,41,51,61,71,81" | 0:00'15'' | 0:00'18'' |
| Q25L60X80P002 |   80.0 |  99.99% |     48093 | 48.09K | 1 |       227 | 422 | 2 |   79.0 | 0.0 |  20.0 | 118.5 | "31,41,51,61,71,81" | 0:00'15'' | 0:00'17'' |
| Q30L60X40P000 |   40.0 |  99.94% |     47991 | 47.99K | 1 |       163 | 245 | 2 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'14'' | 0:00'17'' |
| Q30L60X40P001 |   40.0 |  99.94% |     48078 | 48.08K | 1 |       114 | 211 | 2 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'14'' | 0:00'18'' |
| Q30L60X40P002 |   40.0 |  99.93% |     47973 | 47.97K | 1 |        99 | 171 | 2 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'13'' | 0:00'18'' |
| Q30L60X40P003 |   40.0 |  99.95% |     48023 | 48.02K | 1 |       183 | 269 | 2 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'14'' | 0:00'18'' |
| Q30L60X40P004 |   40.0 |  99.96% |     47990 | 47.99K | 1 |       202 | 266 | 2 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'15'' | 0:00'19'' |
| Q30L60X80P000 |   80.0 |  99.99% |     48101 |  48.1K | 1 |       219 | 413 | 2 |   79.0 | 0.0 |  20.0 | 118.5 | "31,41,51,61,71,81" | 0:00'14'' | 0:00'18'' |
| Q30L60X80P001 |   80.0 |  99.99% |     48057 | 48.06K | 1 |       254 | 457 | 2 |   79.0 | 0.0 |  20.0 | 118.5 | "31,41,51,61,71,81" | 0:00'15'' | 0:00'18'' |


Table: statCanu

| Name                |   N50 |   Sum |    # |
|:--------------------|------:|------:|-----:|
| Genome              | 48502 | 48502 |    1 |
| Paralogs            |     0 |     0 |    0 |
| X80.trim.corrected  |  1624 | 1.94M | 1175 |
| Xall.trim.corrected |  1950 | 1.94M |  984 |
| X80.trim.contig     | 48489 | 48489 |    1 |
| Xall.trim.contig    | 50623 | 50623 |    1 |


Table: statFinal

| Name                           |   N50 |   Sum | # |
|:-------------------------------|------:|------:|--:|
| Genome                         | 48502 | 48502 | 1 |
| Paralogs                       |     0 |     0 | 0 |
| 7_mergeKunitigsAnchors.anchors | 48122 | 48122 | 1 |
| 7_mergeKunitigsAnchors.others  |  2710 |  2710 | 1 |
| 7_mergeTadpoleAnchors.anchors  | 48122 | 48122 | 1 |
| 7_mergeTadpoleAnchors.others   |  2710 |  2710 | 1 |
| 7_mergeAnchors.anchors         | 48122 | 48122 | 1 |
| 7_mergeAnchors.others          |  2710 |  2710 | 1 |
| anchorLong                     | 48122 | 48122 | 1 |
| anchorFill                     | 48122 | 48122 | 1 |
| canu_X80-trim                  | 48489 | 48489 | 1 |
| canu_Xall-trim                 | 50623 | 50623 | 1 |
| spades.contig                  | 48516 | 48516 | 1 |
| spades.scaffold                | 48516 | 48516 | 1 |
| spades.non-contained           | 48516 | 48516 | 1 |
| spades.anchor                  | 48142 | 48142 | 1 |
| megahit.contig                 | 48514 | 48514 | 1 |
| megahit.non-contained          | 48514 | 48514 | 1 |
| megahit.anchor                 | 48142 | 48142 | 1 |
| platanus.contig                | 46380 | 48496 | 2 |
| platanus.scaffold              | 48438 | 48438 | 1 |
| platanus.non-contained         | 48438 | 48438 | 1 |
| platanus.anchor                | 48142 | 48142 | 1 |
