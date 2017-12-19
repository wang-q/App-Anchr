# Bacteria 2+3

[TOC levels=1-3]: # " "
- [Bacteria 2+3](#bacteria-23)
- [Vibrio parahaemolyticus ATCC BAA-239, 副溶血弧菌](#vibrio-parahaemolyticus-atcc-baa-239-副溶血弧菌)
    - [Vpar: download](#vpar-download)
    - [Vpar: run](#vpar-run)
- [Legionella pneumophila subsp. pneumophila ATCC 33152D-5; Philadelphia-1, 嗜肺军团菌](#legionella-pneumophila-subsp-pneumophila-atcc-33152d-5-philadelphia-1-嗜肺军团菌)
    - [Lpne: download](#lpne-download)
    - [Lpne: run](#lpne-run)
- [Neisseria gonorrhoeae FDAARGOS_207, 淋病奈瑟氏菌](#neisseria-gonorrhoeae-fdaargos-207-淋病奈瑟氏菌)
    - [Ngon: download](#ngon-download)
    - [Ngon: run](#ngon-run)
- [Neisseria meningitidis FDAARGOS_209, 脑膜炎奈瑟氏菌](#neisseria-meningitidis-fdaargos-209-脑膜炎奈瑟氏菌)
    - [Nmen: download](#nmen-download)
    - [Nmen: run](#nmen-run)
- [Bordetella pertussis FDAARGOS_195, 百日咳博德特氏杆菌](#bordetella-pertussis-fdaargos-195-百日咳博德特氏杆菌)
    - [Bper: download](#bper-download)
    - [Bper: run](#bper-run)
- [Corynebacterium diphtheriae FDAARGOS_197, 白喉杆菌](#corynebacterium-diphtheriae-fdaargos-197-白喉杆菌)
    - [Cdip: download](#cdip-download)
    - [Cdip: run](#cdip-run)
- [Francisella tularensis FDAARGOS_247, 土拉热弗朗西斯氏菌](#francisella-tularensis-fdaargos-247-土拉热弗朗西斯氏菌)
    - [Ftul: download](#ftul-download)
    - [Ftul: run](#ftul-run)
- [Shigella flexneri NCTC0001, 福氏志贺氏菌](#shigella-flexneri-nctc0001-福氏志贺氏菌)
    - [Sfle: download](#sfle-download)
    - [Sfle: run](#sfle-run)
- [Haemophilus influenzae FDAARGOS_199, 流感嗜血杆菌](#haemophilus-influenzae-fdaargos-199-流感嗜血杆菌)
    - [Hinf: download](#hinf-download)
    - [Hinf: run](#hinf-run)
- [Listeria monocytogenes FDAARGOS_351, 单核细胞增生李斯特氏菌](#listeria-monocytogenes-fdaargos-351-单核细胞增生李斯特氏菌)
    - [Lmon: download](#lmon-download)
    - [Lmon: run](#lmon-run)
- [Clostridioides difficile 630](#clostridioides-difficile-630)
    - [Cdif: download](#cdif-download)
    - [Cdif: run](#cdif-run)
- [Campylobacter jejuni subsp. jejuni ATCC 700819, 空肠弯曲杆菌](#campylobacter-jejuni-subsp-jejuni-atcc-700819-空肠弯曲杆菌)
    - [Cjej: download](#cjej-download)
    - [Cjej: run](#cjej-run)
- [Escherichia virus Lambda](#escherichia-virus-lambda)
    - [lambda: download](#lambda-download)
    - [lambda: preprocess Illumina reads](#lambda-preprocess-illumina-reads)
    - [lambda: preprocess PacBio reads](#lambda-preprocess-pacbio-reads)
    - [lambda: reads stats](#lambda-reads-stats)
    - [lambda: spades](#lambda-spades)
    - [lambda: platanus](#lambda-platanus)
    - [lambda: quorum](#lambda-quorum)
    - [lambda: adapter filtering](#lambda-adapter-filtering)
    - [lambda: down sampling](#lambda-down-sampling)
    - [lambda: k-unitigs and anchors (sampled)](#lambda-k-unitigs-and-anchors-sampled)
    - [lambda: merge anchors](#lambda-merge-anchors)
    - [lambda: 3GS](#lambda-3gs)
    - [lambda: final stats](#lambda-final-stats)
    - [lambda: clear intermediate files](#lambda-clear-intermediate-files)


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

cp ~/data/anchr/paralogs/otherbac/Results/Vpar/Vpar.multi.fas paralogs.fas

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

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 5165770 \
    --trim2 "--uniq --shuffle " \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --cov3 "80 all" \
    --qual3 "trim" \
    --parallel 24

# run
bsub -q mpi -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "done(${BASE_NAME}-0_master)" \
    -q mpi -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

```

| Name      |     N50 |     Sum |        # |
|:----------|--------:|--------:|---------:|
| Genome    | 3288558 | 5165770 |        2 |
| Paralogs  |    3333 |  155714 |       62 |
| Illumina  |     101 |   1.37G | 13551762 |
| uniq      |     101 |   1.36G | 13483004 |
| shuffle   |     101 |   1.36G | 13483004 |
| scythe    |     101 |   1.34G | 13483004 |
| Q25L60    |     101 |    1.2G | 12011424 |
| Q30L60    |     101 |   1.14G | 11613013 |
| PacBio    |   11771 |   1.23G |   143537 |
| X80.raw   |   11822 | 413.26M |    48766 |
| X80.trim  |   10678 | 355.44M |    41795 |
| Xall.raw  |   11771 |   1.23G |   143537 |
| Xall.trim |   10770 |   1.08G |   125808 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 232.3 |  216.3 |   6.910% |     100 | "71" | 5.17M | 5.48M |     1.06 | 0:02'15'' |
| Q30L60 | 221.1 |  207.1 |   6.299% |      99 | "71" | 5.17M | 5.42M |     1.05 | 0:02'09'' |

| Name          | CovCor | N50Anchor |   Sum |   # | N50Others |    Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|------:|----:|----------:|-------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |     86651 | 5.04M | 104 |       784 | 34.27K | 46 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'58'' |
| Q25L60X40P001 |   40.0 |     82844 | 5.04M | 112 |       710 | 27.27K | 39 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'57'' |
| Q25L60X40P002 |   40.0 |     91439 | 5.05M | 105 |       745 | 25.48K | 36 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'57'' |
| Q25L60X40P003 |   40.0 |     99617 | 5.04M | 102 |       770 | 30.01K | 41 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'56'' |
| Q25L60X40P004 |   40.0 |     95315 | 5.04M | 106 |       721 | 27.68K | 40 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'55'' |
| Q25L60X80P000 |   80.0 |     65575 | 5.04M | 147 |       762 | 18.59K | 26 |   78.0 | 8.0 |  18.0 | 153.0 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'51'' |
| Q25L60X80P001 |   80.0 |     75731 | 5.05M | 136 |       729 | 19.23K | 27 |   78.0 | 8.0 |  18.0 | 153.0 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'51'' |
| Q30L60X40P000 |   40.0 |    105193 | 5.04M |  86 |       763 | 32.79K | 44 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:01'03'' |
| Q30L60X40P001 |   40.0 |    139690 | 5.04M |  84 |       749 | 32.32K | 44 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:01'04'' |
| Q30L60X40P002 |   40.0 |    105203 | 5.04M |  81 |       710 | 35.06K | 50 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'51'' | 0:01'07'' |
| Q30L60X40P003 |   40.0 |    128439 | 5.04M |  83 |       710 |  26.7K | 38 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:01'03'' |
| Q30L60X40P004 |   40.0 |    105203 | 5.04M |  89 |       762 | 23.93K | 33 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:01'01'' |
| Q30L60X80P000 |   80.0 |    104258 | 5.04M |  95 |       710 | 19.57K | 28 |   76.0 | 8.0 |  17.3 | 150.0 | "31,41,51,61,71,81" | 0:01'17'' | 0:01'03'' |
| Q30L60X80P001 |   80.0 |     99705 | 5.05M |  95 |       762 | 20.08K | 28 |   77.0 | 8.0 |  17.7 | 151.5 | "31,41,51,61,71,81" | 0:01'16'' | 0:01'00'' |

| Name                |     N50 |     Sum |     # |
|:--------------------|--------:|--------:|------:|
| Genome              | 3288558 | 5165770 |     2 |
| Paralogs            |    3333 |  155714 |    62 |
| X80.trim.corrected  |   11981 | 201.86M | 17420 |
| Xall.trim.corrected |   19088 | 201.72M | 10514 |
| X80.trim.contig     | 3316838 | 5204553 |     2 |
| Xall.trim.contig    | 3292632 | 5188352 |     2 |

| Name                   |     N50 |     Sum |    # |
|:-----------------------|--------:|--------:|-----:|
| Genome                 | 3288558 | 5165770 |    2 |
| Paralogs               |    3333 |  155714 |   62 |
| anchors                |  179336 | 5060549 |   71 |
| others                 |     837 |   98682 |  128 |
| anchorLong             |  208183 | 5059783 |   59 |
| anchorFill             |  561554 | 5107574 |   15 |
| canu_X80-trim          | 3316838 | 5204553 |    2 |
| canu_Xall-trim         | 3292632 | 5188352 |    2 |
| spades.contig          |  256618 | 6578108 | 3933 |
| spades.scaffold        |  373514 | 6587153 | 3680 |
| spades.non-contained   |  288633 | 5166143 |  126 |
| platanus.contig        |  196706 | 5152580 |  619 |
| platanus.scaffold      |  339534 | 5134547 |  434 |
| platanus.non-contained |  426844 | 5061526 |   34 |


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

cp ~/data/anchr/paralogs/otherbac/Results/Lpne/Lpne.multi.fas paralogs.fas

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

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 3397754 \
    --trim2 "--uniq " \
    --sample 300 \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --cov3 "80 all" \
    --qual3 "trim" \
    --parallel 24

# run
bsub -q mpi -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "done(${BASE_NAME}-0_master)" \
    -q mpi -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

```

| Name      |     N50 |     Sum |        # |
|:----------|--------:|--------:|---------:|
| Genome    | 3397754 | 3397754 |        1 |
| Paralogs  |    2793 |  100722 |       43 |
| Illumina  |     101 |   1.06G | 10498482 |
| uniq      |     101 |   1.06G | 10458252 |
| shuffle   |     101 |   1.06G | 10458252 |
| sample    |     101 |   1.02G | 10092338 |
| scythe    |     101 |   1.01G | 10092338 |
| Q25L60    |     101 | 876.86M |  8805342 |
| Q30L60    |     101 | 804.43M |  8293117 |
| PacBio    |    8538 | 287.32M |    56763 |
| X80.raw   |    8542 | 271.82M |    53600 |
| X80.trim  |    8354 | 232.88M |    39020 |
| Xall.raw  |    8538 | 287.32M |    56763 |
| Xall.trim |    8357 | 246.63M |    41404 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 258.1 |  238.1 |   7.748% |      99 | "71" |  3.4M | 3.43M |     1.01 | 0:01'39'' |
| Q30L60 | 236.9 |  222.0 |   6.289% |      98 | "71" |  3.4M | 3.41M |     1.00 | 0:01'32'' |

| Name          | CovCor | N50Anchor |   Sum |   # | N50Others |    Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|------:|----:|----------:|-------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |    101461 | 3.36M |  78 |       874 | 39.55K | 47 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'46'' |
| Q25L60X40P001 |   40.0 |     95305 | 3.36M |  82 |       874 | 45.62K | 52 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'48'' |
| Q25L60X40P002 |   40.0 |     79418 | 3.36M |  78 |       912 | 37.59K | 42 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'46'' |
| Q25L60X40P003 |   40.0 |     78859 | 3.35M |  73 |       864 |  44.7K | 54 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'44'' |
| Q25L60X40P004 |   40.0 |     77744 | 3.36M |  82 |       763 | 37.56K | 47 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'46'' |
| Q25L60X80P000 |   80.0 |     40955 | 3.36M | 126 |      1776 | 63.28K | 47 |   78.0 | 3.0 |  23.0 | 130.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'40'' |
| Q25L60X80P001 |   80.0 |     57937 | 3.37M | 115 |      3850 | 65.16K | 37 |   78.0 | 3.0 |  23.0 | 130.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'43'' |
| Q30L60X40P000 |   40.0 |    107125 | 3.36M |  61 |       839 | 36.82K | 44 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'47'' |
| Q30L60X40P001 |   40.0 |    120743 | 3.36M |  65 |       964 | 43.39K | 47 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'48'' |
| Q30L60X40P002 |   40.0 |    118594 | 3.35M |  62 |       848 | 43.51K | 50 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'49'' |
| Q30L60X40P003 |   40.0 |    142178 | 3.36M |  60 |       813 | 35.57K | 43 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'49'' |
| Q30L60X40P004 |   40.0 |    118512 | 3.36M |  62 |       839 | 38.13K | 47 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'45'' |
| Q30L60X80P000 |   80.0 |     91387 | 3.36M |  73 |      2043 | 61.06K | 44 |   78.0 | 4.0 |  22.0 | 135.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'48'' |
| Q30L60X80P001 |   80.0 |     96162 | 3.36M |  67 |      1762 | 52.37K | 38 |   78.0 | 4.0 |  22.0 | 135.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'49'' |

| Name                |     N50 |     Sum |     # |
|:--------------------|--------:|--------:|------:|
| Genome              | 3397754 | 3397754 |     1 |
| Paralogs            |    2793 |  100722 |    43 |
| X80.trim.corrected  |    9535 | 135.09M | 14652 |
| Xall.trim.corrected |    9848 |  135.1M | 13992 |
| X80.trim.contig     | 3403179 | 3403179 |     1 |
| Xall.trim.contig    | 3417657 | 3431477 |     2 |

| Name                   |     N50 |     Sum |   # |
|:-----------------------|--------:|--------:|----:|
| Genome                 | 3397754 | 3397754 |   1 |
| Paralogs               |    2793 |  100722 |  43 |
| anchors                |  248586 | 3357856 |  38 |
| others                 |    1037 |  157285 | 132 |
| anchorLong             |  261851 | 3355839 |  32 |
| anchorFill             | 1750060 | 3379069 |   6 |
| canu_X80-trim          | 3403179 | 3403179 |   1 |
| canu_Xall-trim         | 3417657 | 3431477 |   2 |
| spades.contig          |  363158 | 3481811 | 291 |
| spades.scaffold        |  363158 | 3481911 | 290 |
| spades.non-contained   |  363158 | 3406998 |  28 |
| platanus.contig        |  198660 | 3392651 | 209 |
| platanus.scaffold      |  363087 | 3385715 | 144 |
| platanus.non-contained |  363087 | 3364434 |  22 |

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

cp ~/data/anchr/paralogs/otherbac/Results/Ngon/Ngon.multi.fas paralogs.fas

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

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 2153922 \
    --trim2 "--uniq " \
    --sample 300 \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --cov3 "80 all" \
    --qual3 "trim" \
    --parallel 24

# run
bsub -q mpi -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "done(${BASE_NAME}-0_master)" \
    -q mpi -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

```

| Name      |     N50 |     Sum |        # |
|:----------|--------:|--------:|---------:|
| Genome    | 2153922 | 2153922 |        1 |
| Paralogs  |    4318 |  142093 |       53 |
| Illumina  |     101 |   1.49G | 14768158 |
| uniq      |     101 |   1.49G | 14707416 |
| shuffle   |     101 |   1.49G | 14707416 |
| sample    |     101 | 646.18M |  6397788 |
| scythe    |     101 | 632.67M |  6397788 |
| Q25L60    |     101 | 462.08M |  4729016 |
| Q30L60    |     101 | 385.02M |  4141949 |
| PacBio    |   11808 |   1.19G |   137516 |
| X80.raw   |   11668 | 172.32M |    20331 |
| X80.trim  |    9976 | 136.79M |    17440 |
| Xall.raw  |   11808 |   1.19G |   137516 |
| Xall.trim |   10448 | 985.14M |   119743 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 214.5 |  196.9 |   8.194% |      98 | "51" | 2.15M | 2.07M |     0.96 | 0:00'58'' |
| Q30L60 | 179.1 |  167.8 |   6.337% |      95 | "47" | 2.15M | 2.05M |     0.95 | 0:00'47'' |

| Name          | CovCor | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |     14803 | 1.95M | 205 |       935 | 120.27K | 130 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'40'' |
| Q25L60X40P001 |   40.0 |     14424 | 1.93M | 199 |       942 | 136.59K | 141 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'22'' | 0:00'40'' |
| Q25L60X40P002 |   40.0 |     15734 | 1.94M | 204 |       904 | 135.75K | 144 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'22'' | 0:00'40'' |
| Q25L60X40P003 |   40.0 |     14216 | 1.96M | 212 |       902 | 136.35K | 151 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'38'' |
| Q25L60X80P000 |   80.0 |     13659 | 1.94M | 219 |      1024 |  82.57K |  82 |   75.0 | 6.0 |  19.0 | 139.5 | "31,41,51,61,71,81" | 0:00'32'' | 0:00'38'' |
| Q25L60X80P001 |   80.0 |     15012 | 1.96M | 221 |       983 |   72.2K |  74 |   76.0 | 7.0 |  18.3 | 145.5 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'37'' |
| Q30L60X40P000 |   40.0 |     15645 | 1.85M | 201 |       924 | 204.57K | 213 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'43'' |
| Q30L60X40P001 |   40.0 |     14272 | 1.82M | 203 |       947 | 219.54K | 223 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'42'' |
| Q30L60X40P002 |   40.0 |     14804 | 1.83M | 198 |       902 | 199.38K | 205 |   36.0 | 5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'22'' | 0:00'41'' |
| Q30L60X40P003 |   40.0 |     14413 | 1.92M | 202 |       871 | 231.37K | 258 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'22'' | 0:00'42'' |
| Q30L60X80P000 |   80.0 |     17020 | 1.85M | 173 |      1096 | 106.16K |  98 |   73.0 | 8.0 |  16.3 | 145.5 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'42'' |
| Q30L60X80P001 |   80.0 |     19975 | 1.92M | 166 |       912 | 108.29K | 111 |   75.0 | 7.0 |  18.0 | 144.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'42'' |

| Name                |     N50 |     Sum |    # |
|:--------------------|--------:|--------:|-----:|
| Genome              | 2153922 | 2153922 |    1 |
| Paralogs            |    4318 |  142093 |   53 |
| X80.trim.corrected  |   10333 |  81.38M | 8342 |
| Xall.trim.corrected |   19826 |  80.18M | 4138 |
| X80.trim.contig     | 2205541 | 2205541 |    1 |
| Xall.trim.contig    | 2207006 | 2207006 |    1 |

| Name                   |     N50 |     Sum |   # |
|:-----------------------|--------:|--------:|----:|
| Genome                 | 2153922 | 2153922 |   1 |
| Paralogs               |    4318 |  142093 |  53 |
| anchors                |   23012 | 1975640 | 138 |
| others                 |     972 |  469746 | 460 |
| anchorLong             |   38593 | 1405602 |  78 |
| anchorFill             |   63364 | 1452098 |  56 |
| canu_X80-trim          | 2205541 | 2205541 |   1 |
| canu_Xall-trim         | 2207006 | 2207006 |   1 |
| spades.contig          |   48627 | 2131951 | 422 |
| spades.scaffold        |   50390 | 2132001 | 417 |
| spades.non-contained   |   50390 | 2057475 |  80 |
| platanus.contig        |   18587 | 2142101 | 954 |
| platanus.scaffold      |   44069 | 2109271 | 548 |
| platanus.non-contained |   46744 | 2035498 |  88 |

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

cp ~/data/anchr/paralogs/otherbac/Results/Nmen/Nmen.multi.fas paralogs.fas

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

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 2272360 \
    --trim2 "--uniq  " \
    --sample 300 \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --cov3 "80 all" \
    --qual3 "trim" \
    --parallel 24

# run
bsub -q mpi -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "done(${BASE_NAME}-0_master)" \
    -q mpi -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

```

| Name      |     N50 |     Sum |        # |
|:----------|--------:|--------:|---------:|
| Genome    | 2272360 | 2272360 |        1 |
| Paralogs  |       0 |       0 |        0 |
| Illumina  |     101 |    1.4G | 13814390 |
| uniq      |     101 |   1.39G | 13758358 |
| shuffle   |     101 |   1.39G | 13758358 |
| sample    |     101 | 681.71M |  6749584 |
| scythe    |     101 | 668.08M |  6749584 |
| Q25L60    |     101 | 495.41M |  5064564 |
| Q30L60    |     101 | 416.64M |  4469142 |
| PacBio    |    9603 | 402.17M |    58711 |
| X80.raw   |    9605 | 181.79M |    26345 |
| X80.trim  |    9133 | 163.29M |    21467 |
| Xall.raw  |    9603 | 402.17M |    58711 |
| Xall.trim |    9188 | 364.96M |    47561 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 218.0 |  200.7 |   7.929% |      98 | "71" | 2.27M | 3.45M |     1.52 | 0:01'03'' |
| Q30L60 | 183.7 |  172.2 |   6.256% |      95 | "65" | 2.27M | 3.24M |     1.42 | 0:00'52'' |

| Name          | CovCor | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |      7417 | 1.93M | 356 |       913 | 246.89K | 257 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'24'' | 0:00'42'' |
| Q25L60X40P001 |   40.0 |      7748 | 1.91M | 339 |       906 | 236.65K | 254 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'24'' | 0:00'44'' |
| Q25L60X40P002 |   40.0 |      7779 | 1.92M | 345 |       889 | 258.51K | 281 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'24'' | 0:00'42'' |
| Q25L60X40P003 |   40.0 |      7822 | 1.91M | 339 |       932 | 259.97K | 268 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'24'' | 0:00'41'' |
| Q25L60X40P004 |   40.0 |      8021 | 1.91M | 335 |       912 | 230.72K | 244 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'24'' | 0:00'42'' |
| Q25L60X80P000 |   80.0 |      7306 | 1.97M | 386 |       906 | 142.87K | 156 |   72.0 | 7.0 |  17.0 | 139.5 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'38'' |
| Q25L60X80P001 |   80.0 |      6819 | 1.97M | 393 |       960 | 130.88K | 138 |   72.0 | 7.0 |  17.0 | 139.5 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'38'' |
| Q30L60X40P000 |   40.0 |      7800 | 1.85M | 327 |       919 | 362.48K | 378 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'24'' | 0:00'44'' |
| Q30L60X40P001 |   40.0 |      8184 | 1.84M | 310 |       935 | 392.17K | 405 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'44'' |
| Q30L60X40P002 |   40.0 |      8087 | 1.84M | 311 |       935 | 368.92K | 381 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'24'' | 0:00'45'' |
| Q30L60X40P003 |   40.0 |      8270 | 1.94M | 324 |       907 |    371K | 413 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'44'' |
| Q30L60X80P000 |   80.0 |      8421 | 1.83M | 285 |       936 | 205.02K | 210 |   69.0 | 9.0 |  14.0 | 138.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'43'' |
| Q30L60X80P001 |   80.0 |      9232 |  1.9M | 281 |       963 | 181.34K | 181 |   72.0 | 7.0 |  17.0 | 139.5 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'44'' |

| Name                |     N50 |     Sum |    # |
|:--------------------|--------:|--------:|-----:|
| Genome              | 2272360 | 2272360 |    1 |
| Paralogs            |       0 |       0 |    0 |
| X80.trim.corrected  |   10334 |  90.08M | 8603 |
| Xall.trim.corrected |   13769 |  90.06M | 6451 |
| X80.trim.contig     | 2196486 | 2196486 |    1 |
| Xall.trim.contig    | 2196899 | 2196899 |    1 |

| Name                   |     N50 |     Sum |    # |
|:-----------------------|--------:|--------:|-----:|
| Genome                 | 2272360 | 2272360 |    1 |
| Paralogs               |       0 |       0 |    0 |
| anchors                |   10008 | 2033312 |  281 |
| others                 |     945 |  817066 |  845 |
| anchorLong             |    7003 |  638163 |  145 |
| anchorFill             |    7003 |  638163 |  145 |
| canu_X80-trim          | 2196486 | 2196486 |    1 |
| canu_Xall-trim         | 2196899 | 2196899 |    1 |
| spades.contig          |    5434 | 4265303 | 2273 |
| spades.scaffold        |    6292 | 4269939 | 2005 |
| spades.non-contained   |   11953 | 3668996 |  878 |
| platanus.contig        |    8377 | 2275487 | 1692 |
| platanus.scaffold      |   42294 | 2205877 |  827 |
| platanus.non-contained |   42337 | 2085352 |   99 |

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

cp ~/data/anchr/paralogs/otherbac/Results/Bper/Bper.multi.fas paralogs.fas

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

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 4086189 \
    --trim2 "--uniq " \
    --sample 300 \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --parallel 24

# run
bsub -q mpi -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "done(${BASE_NAME}-0_master)" \
    -q mpi -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

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
| Q30L60 | 153.0 |  142.2 |   7.026% |      91 | "31" | 4.09M | 4.21M |     1.03 | 0:01'15'' |

| Name          | CovCor | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |      2297 |  2.1M |  999 |      1049 |   1.24M | 1164 |   40.0 | 11.0 |   2.3 |  80.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'44'' |
| Q25L60X40P001 |   40.0 |      2223 | 2.06M |  994 |      1030 |   1.28M | 1198 |   40.0 | 11.0 |   2.3 |  80.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'44'' |
| Q25L60X40P002 |   40.0 |      2279 | 2.07M |  987 |      1092 |   1.33M | 1227 |   40.0 | 11.0 |   2.3 |  80.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'43'' |
| Q25L60X40P003 |   40.0 |      2648 | 2.37M | 1023 |       996 | 956.85K |  924 |   41.0 | 11.0 |   2.7 |  82.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'45'' |
| Q25L60X80P000 |   80.0 |      2347 | 2.21M | 1041 |      1059 |   1.29M | 1197 |   77.0 | 22.0 |   3.7 | 154.0 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'48'' |
| Q25L60X80P001 |   80.0 |      2435 | 2.32M | 1054 |      1077 |   1.14M | 1076 |   77.0 | 22.0 |   3.7 | 154.0 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'48'' |
| Q30L60X40P000 |   40.0 |      1832 | 1.48M |  817 |      1298 |   1.59M | 1356 |   40.0 | 13.0 |   2.0 |  80.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'40'' |
| Q30L60X40P001 |   40.0 |      1943 |  1.6M |  855 |      1213 |   1.42M | 1262 |   40.0 | 12.0 |   2.0 |  80.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'42'' |
| Q30L60X40P002 |   40.0 |      1913 | 1.58M |  839 |      1259 |   1.38M | 1192 |   41.0 | 11.0 |   2.7 |  82.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'41'' |
| Q30L60X80P000 |   80.0 |      2132 | 1.82M |  922 |      1341 |   1.36M | 1127 |   78.0 | 25.0 |   2.0 | 156.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'44'' |

| Name                   |     N50 |     Sum |    # |
|:-----------------------|--------:|--------:|-----:|
| Genome                 | 4086189 | 4086189 |    1 |
| Paralogs               |    1033 |  322667 |  278 |
| anchors                |    3256 | 3027003 | 1130 |
| others                 |    1360 | 3942224 | 3201 |
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

cp ~/data/anchr/paralogs/otherbac/Results/Cdip/Cdip.multi.fas paralogs.fas

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

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 2488635 \
    --trim2 "--uniq " \
    --sample 300 \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --cov3 "80 all" \
    --qual3 "trim" \
    --parallel 24

# run
bsub -q mpi -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "done(${BASE_NAME}-0_master)" \
    -q mpi -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

```

| Name      |     N50 |     Sum |        # |
|:----------|--------:|--------:|---------:|
| Genome    | 2488635 | 2488635 |        1 |
| Paralogs  |    5635 |   56210 |       18 |
| Illumina  |     101 |   1.12G | 11128812 |
| uniq      |     101 |   1.12G | 11095816 |
| shuffle   |     101 |   1.12G | 11095816 |
| sample    |     101 | 746.59M |  7391986 |
| scythe    |     101 | 731.12M |  7391986 |
| Q25L60    |     101 | 540.25M |  5523366 |
| Q30L60    |     101 | 449.21M |  4842910 |
| PacBio    |    8966 |  665.8M |   110317 |
| X80.raw   |    8781 | 199.09M |    33954 |
| X80.trim  |    7824 | 153.76M |    25880 |
| Xall.raw  |    8966 |  665.8M |   110317 |
| Xall.trim |    8046 | 524.96M |    85915 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 217.1 |  198.2 |   8.695% |      98 | "51" | 2.49M | 2.48M |     1.00 | 0:01'07'' |
| Q30L60 | 180.8 |  169.0 |   6.525% |      95 | "47" | 2.49M | 2.46M |     0.99 | 0:00'57'' |

| Name          | CovCor | N50Anchor |   Sum |   # | N50Others |    Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|------:|----:|----------:|-------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |     54038 | 2.45M |  88 |       886 | 25.42K | 27 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'24'' | 0:00'41'' |
| Q25L60X40P001 |   40.0 |     50732 | 2.45M |  94 |       868 | 30.37K | 34 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'25'' | 0:00'42'' |
| Q25L60X40P002 |   40.0 |     53077 | 2.45M |  88 |       880 | 25.52K | 29 |   38.0 | 3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:00'24'' | 0:00'40'' |
| Q25L60X40P003 |   40.0 |     53329 | 2.45M |  91 |       852 | 33.51K | 39 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'25'' | 0:00'40'' |
| Q25L60X80P000 |   80.0 |     33008 | 2.44M | 123 |       843 | 17.31K | 21 |   75.0 | 6.0 |  19.0 | 139.5 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'39'' |
| Q25L60X80P001 |   80.0 |     34205 | 2.44M | 110 |       843 | 12.83K | 14 |   75.0 | 5.0 |  20.0 | 135.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'38'' |
| Q30L60X40P000 |   40.0 |     91001 | 2.44M |  69 |       897 | 42.86K | 48 |   36.5 | 4.5 |   7.7 |  73.0 | "31,41,51,61,71,81" | 0:00'25'' | 0:00'45'' |
| Q30L60X40P001 |   40.0 |     61798 | 2.44M |  75 |       865 | 43.65K | 49 |   36.0 | 4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'26'' | 0:00'45'' |
| Q30L60X40P002 |   40.0 |     55395 | 2.44M |  74 |       851 | 33.05K | 38 |   36.0 | 5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'26'' | 0:00'44'' |
| Q30L60X40P003 |   40.0 |     60248 | 2.45M |  77 |       890 | 49.99K | 55 |   38.0 | 3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:00'25'' | 0:00'42'' |
| Q30L60X80P000 |   80.0 |     97954 | 2.44M |  56 |       937 | 17.98K | 18 |   73.0 | 8.0 |  16.3 | 145.5 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'47'' |
| Q30L60X80P001 |   80.0 |     61780 | 2.44M |  64 |       880 | 18.73K | 19 |   74.0 | 7.0 |  17.7 | 142.5 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'46'' |

| Name                |     N50 |     Sum |     # |
|:--------------------|--------:|--------:|------:|
| Genome              | 2488635 | 2488635 |     1 |
| Paralogs            |    5635 |   56210 |    18 |
| X80.trim.corrected  |    7383 |  96.03M | 15940 |
| Xall.trim.corrected |   13283 |  96.86M |  7200 |
| X80.trim.contig     | 2502151 | 2502151 |     1 |
| Xall.trim.contig    | 2505675 | 2505675 |     1 |

| Name                   |     N50 |     Sum |   # |
|:-----------------------|--------:|--------:|----:|
| Genome                 | 2488635 | 2488635 |   1 |
| Paralogs               |    5635 |   56210 |  18 |
| anchors                |  115949 | 2440991 |  43 |
| others                 |     894 |  124203 | 138 |
| anchorLong             |  125030 | 2440419 |  34 |
| anchorFill             |  420817 | 2458339 |   7 |
| canu_X80-trim          | 2502151 | 2502151 |   1 |
| canu_Xall-trim         | 2505675 | 2505675 |   1 |
| spades.contig          |  309919 | 2538260 | 294 |
| spades.scaffold        |  309919 | 2538290 | 291 |
| spades.non-contained   |  309919 | 2455656 |  21 |
| platanus.contig        |   97950 | 2469017 | 189 |
| platanus.scaffold      |  177063 | 2463898 | 122 |
| platanus.non-contained |  177063 | 2446231 |  23 |

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

cp ~/data/anchr/paralogs/otherbac/Results/Ftul/Ftul.multi.fas paralogs.fas

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

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 1892775 \
    --trim2 "--uniq " \
    --sample 300 \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --cov3 "80 all" \
    --qual3 "trim" \
    --parallel 24

# run
bsub -q mpi -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "done(${BASE_NAME}-0_master)" \
    -q mpi -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

```

| Name      |     N50 |     Sum |        # |
|:----------|--------:|--------:|---------:|
| Genome    | 1892775 | 1892775 |        1 |
| Paralogs  |   33912 |   93531 |       10 |
| Illumina  |     101 |   2.14G | 21230270 |
| uniq      |     101 |   2.12G | 21019000 |
| shuffle   |     101 |   2.12G | 21019000 |
| sample    |     101 | 567.83M |  5622104 |
| scythe    |     101 | 564.76M |  5622104 |
| Q25L60    |     101 |  537.2M |  5345076 |
| Q30L60    |     101 | 523.23M |  5260747 |
| PacBio    |   10022 |   1.16G |   151564 |
| X80.raw   |   10012 | 151.42M |    19828 |
| X80.trim  |    9130 | 133.37M |    17725 |
| Xall.raw  |   10022 |   1.16G |   151564 |
| Xall.trim |    9626 |   1.07G |   137266 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG | EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|-----:|---------:|----------:|
| Q25L60 | 283.8 |  271.6 |   4.301% |     100 | "71" | 1.89M | 1.8M |     0.95 | 0:01'02'' |
| Q30L60 | 276.5 |  266.9 |   3.491% |      99 | "71" | 1.89M | 1.8M |     0.95 | 0:01'03'' |

| Name          | CovCor | N50Anchor |   Sum |  # | N50Others |    Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|------:|---:|----------:|-------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |     32813 | 1.76M | 69 |     17652 | 61.43K | 15 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'37'' |
| Q25L60X40P001 |   40.0 |     32813 | 1.76M | 70 |     17652 | 64.62K | 17 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'37'' |
| Q25L60X40P002 |   40.0 |     32813 | 1.76M | 69 |     11459 | 62.11K | 13 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'36'' |
| Q25L60X40P003 |   40.0 |     32813 | 1.76M | 70 |     17652 | 67.44K | 11 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'37'' |
| Q25L60X40P004 |   40.0 |     32798 | 1.76M | 73 |     17652 | 75.21K | 21 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'37'' |
| Q25L60X40P005 |   40.0 |     32751 | 1.76M | 71 |     17652 | 72.33K | 18 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'38'' |
| Q25L60X80P000 |   80.0 |     32813 | 1.76M | 74 |     17652 |  57.1K | 10 |   80.0 | 1.0 |  25.7 | 124.5 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'34'' |
| Q25L60X80P001 |   80.0 |     32813 | 1.76M | 71 |     11459 | 55.33K |  9 |   80.0 | 1.0 |  25.7 | 124.5 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'34'' |
| Q25L60X80P002 |   80.0 |     32751 | 1.76M | 80 |      8386 | 48.81K |  9 |   80.0 | 1.0 |  25.7 | 124.5 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'33'' |
| Q30L60X40P000 |   40.0 |     32813 | 1.76M | 69 |     27554 | 44.45K | 15 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'37'' |
| Q30L60X40P001 |   40.0 |     32813 | 1.76M | 70 |     27554 | 45.49K | 17 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'35'' |
| Q30L60X40P002 |   40.0 |     32813 | 1.76M | 70 |     21361 | 42.15K | 14 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'37'' |
| Q30L60X40P003 |   40.0 |     35238 | 1.76M | 69 |     27554 | 40.02K | 10 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'36'' |
| Q30L60X40P004 |   40.0 |     32813 | 1.76M | 72 |     27554 | 43.17K | 15 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'37'' |
| Q30L60X40P005 |   40.0 |     32751 | 1.76M | 72 |     27554 | 43.97K | 15 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'36'' |
| Q30L60X80P000 |   80.0 |     32813 | 1.76M | 72 |     27554 | 36.53K |  6 |   80.0 | 1.0 |  25.7 | 124.5 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'33'' |
| Q30L60X80P001 |   80.0 |     32813 | 1.76M | 71 |     21361 | 35.22K |  5 |   80.0 | 1.0 |  25.7 | 124.5 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'33'' |
| Q30L60X80P002 |   80.0 |     32404 | 1.76M | 75 |     27554 | 36.18K |  5 |   80.0 | 1.0 |  25.7 | 124.5 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'33'' |

| Name                |     N50 |     Sum |    # |
|:--------------------|--------:|--------:|-----:|
| Genome              | 1892775 | 1892775 |    1 |
| Paralogs            |   33912 |   93531 |   10 |
| X80.trim.corrected  |   11079 |  73.28M | 6735 |
| Xall.trim.corrected |   22080 |  72.99M | 3284 |
| X80.trim.contig     | 1884029 | 1884029 |    1 |
| Xall.trim.contig    | 1579468 | 1978055 |    3 |

| Name                   |     N50 |     Sum |   # |
|:-----------------------|--------:|--------:|----:|
| Genome                 | 2488635 | 2488635 |   1 |
| Paralogs               |    5635 |   56210 |  18 |
| anchors                |  115949 | 2440991 |  43 |
| others                 |     894 |  124203 | 138 |
| anchorLong             |  125030 | 2440419 |  34 |
| anchorFill             |  420817 | 2458339 |   7 |
| canu_X80-trim          | 2502151 | 2502151 |   1 |
| canu_Xall-trim         | 2505675 | 2505675 |   1 |
| spades.contig          |  309919 | 2538260 | 294 |
| spades.scaffold        |  309919 | 2538290 | 291 |
| spades.non-contained   |  309919 | 2455656 |  21 |
| platanus.contig        |   97950 | 2469017 | 189 |
| platanus.scaffold      |  177063 | 2463898 | 122 |
| platanus.non-contained |  177063 | 2446231 |  23 |

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

cp ~/data/anchr/paralogs/otherbac/Results/Sfle/Sfle.multi.fas paralogs.fas

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

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 4828820 \
    --trim2 "--uniq --shuffle " \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --cov3 "all" \
    --qual3 "trim" \
    --parallel 24

# run
bsub -q mpi -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "done(${BASE_NAME}-0_master)" \
    -q mpi -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

```

| Name     |     N50 |       Sum |       # |
|:---------|--------:|----------:|--------:|
| Genome   | 4607202 |   4828820 |       2 |
| Paralogs |    1377 |    543111 |     334 |
| Illumina |     150 | 346446900 | 2309646 |
| PacBio   |    3333 | 432566566 |  170957 |
| uniq     |     150 | 346176600 | 2307844 |
| scythe   |     150 | 346111063 | 2307844 |
| Q20L60   |     150 | 333654543 | 2241618 |
| Q20L90   |     150 | 330186360 | 2210410 |
| Q25L60   |     150 | 318498288 | 2147972 |
| Q25L90   |     150 | 313056345 | 2098682 |
| Q30L60   |     150 | 299305225 | 2026998 |
| Q30L90   |     150 | 292247140 | 1962820 |

| Name   |   SumFq | CovFq | AvgRead |               Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:-------|--------:|------:|--------:|-------------------:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| Q20L60 | 333.65M |  72.4 |     148 | "41,61,81,101,121" | 307.96M |   7.702% | 4.61M | 4.22M |     0.92 | 4.26M |     0 | 0:04'30'' |
| Q20L90 | 330.19M |  71.7 |     149 | "41,61,81,101,121" | 305.44M |   7.493% | 4.61M | 4.21M |     0.91 | 4.26M |     0 | 0:04'36'' |
| Q25L60 |  318.5M |  69.1 |     148 | "41,61,81,101,121" | 301.45M |   5.353% | 4.61M | 4.19M |     0.91 | 4.22M |     0 | 0:04'29'' |
| Q25L90 | 313.06M |  67.9 |     149 | "41,61,81,101,121" | 296.68M |   5.230% | 4.61M | 4.19M |     0.91 | 4.22M |     0 | 0:05'02'' |
| Q30L60 | 299.31M |  65.0 |     147 | "41,61,81,101,121" | 287.19M |   4.047% | 4.61M | 4.18M |     0.91 | 4.22M |     0 | 0:04'58'' |
| Q30L90 | 292.25M |  63.4 |     148 | "41,61,81,101,121" | 280.53M |   4.009% | 4.61M | 4.18M |     0.91 | 4.22M |     0 | 0:04'49'' |

| Name   | N50SR |   Sum |   # | N50Anchor |   Sum |   # | N50Others |    Sum |   # |   RunTime |
|:-------|------:|------:|----:|----------:|------:|----:|----------:|-------:|----:|----------:|
| Q20L60 |  8637 | 4.26M | 778 |      8821 | 4.17M | 660 |       765 | 87.11K | 118 | 0:00'51'' |
| Q20L90 |  9406 | 4.26M | 725 |      9482 | 4.18M | 615 |       766 | 80.73K | 110 | 0:00'53'' |
| Q25L60 | 19847 | 4.22M | 398 |     20462 | 4.18M | 337 |       770 | 44.81K |  61 | 0:00'58'' |
| Q25L90 | 21495 | 4.22M | 378 |     21517 | 4.18M | 321 |       765 | 41.64K |  57 | 0:00'56'' |
| Q30L60 | 29285 | 4.22M | 316 |     29285 | 4.18M | 264 |       760 | 37.42K |  52 | 0:00'57'' |
| Q30L90 | 29285 | 4.22M | 314 |     29570 | 4.18M | 261 |       760 | 37.88K |  53 | 0:00'56'' |

| Name         |     N50 |     Sum |   # |
|:-------------|--------:|--------:|----:|
| Genome       | 4607202 | 4828820 |   2 |
| Paralogs     |    1377 |  543111 | 334 |
| anchor.merge |   29718 | 4177514 | 258 |
| others.merge |    1013 |    5268 |   5 |
| anchor.cover |   21445 | 4065033 | 337 |
| anchorLong   |   21727 | 4064559 | 333 |
| contigTrim   |   59768 | 4286051 | 140 |

# Haemophilus influenzae FDAARGOS_199, 流感嗜血杆菌

* Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

* Other name: ATCC 51907D; Rd KW20

* BioSample: [SAMN04875536](https://www.ncbi.nlm.nih.gov/biosample/SAMN04875536)

## Hinf: download

* Settings

```bash
BASE_NAME=Hinf
REAL_G=1830138
IS_EUK="false"
SAMPLE2=
COVERAGE2="40 80"
COVERAGE3="40 80"
READ_QUAL="25 30"
READ_LEN="60"
EXPAND_WITH="80"

```

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

cp ~/data/anchr/paralogs/otherbac/Results/Hinf/Hinf.multi.fas paralogs.fas

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

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 1830138 \
    --trim2 "--uniq " \
    --sample 300 \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --cov3 "80 all" \
    --qual3 "trim" \
    --parallel 24

# run
bsub -q mpi -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "done(${BASE_NAME}-0_master)" \
    -q mpi -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

```

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 1830138 |    1830138 |        1 |
| Paralogs |    5432 |      95358 |       29 |
| Illumina |     101 | 1235356048 | 12231248 |
| uniq     |     101 | 1226542990 | 12143990 |
| sample   |     101 |  366027636 |  3624036 |
| Q25L60   |     101 |  336197323 |  3361918 |
| Q30L60   |     101 |  319321429 |  3256068 |
| PacBio   |   11870 |  407419334 |   163475 |
| X40.raw  |   10606 |   73205571 |    31846 |
| X40.trim |   11036 |   31223296 |     3571 |
| X80.raw  |   11062 |  146420707 |    62532 |
| X80.trim |   12100 |   70301992 |     7562 |


| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead | Kmer | RealG | EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|-----:|------:|-----:|---------:|----------:|
| Q25L60 |  336.2M | 183.7 | 319.81M |  174.7 |   4.876% |     100 | "71" | 1.83M | 1.8M |     0.98 | 0:01'03'' |
| Q30L60 | 319.47M | 174.6 | 307.56M |  168.1 |   3.728% |      98 | "71" | 1.83M | 1.8M |     0.98 | 0:01'08'' |


| Name          |  SumCor | CovCor | N50Anchor |   Sum |  # | N50Others |    Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|--------:|-------:|----------:|------:|---:|----------:|-------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |  73.21M |   40.0 |     60057 | 1.77M | 51 |       992 | 24.28K | 20 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'41'' |
| Q25L60X40P001 |  73.21M |   40.0 |     55173 | 1.77M | 58 |       839 | 17.66K | 21 |   39.5 | 3.5 |   9.7 |  75.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'43'' |
| Q25L60X40P002 |  73.21M |   40.0 |     58199 | 1.77M | 49 |      1019 | 22.88K | 20 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'42'' |
| Q25L60X40P003 |  73.21M |   40.0 |     54671 | 1.77M | 61 |      1009 | 23.28K | 22 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'42'' |
| Q25L60X80P000 | 146.41M |   80.0 |     54823 | 1.77M | 61 |       948 | 13.74K | 15 |   80.5 | 6.5 |  20.3 | 150.0 | "31,41,51,61,71,81" | 0:01'22'' | 0:00'39'' |
| Q25L60X80P001 | 146.41M |   80.0 |     54671 | 1.77M | 62 |      1561 | 18.29K | 15 |   81.0 | 6.0 |  21.0 | 148.5 | "31,41,51,61,71,81" | 0:01'21'' | 0:00'39'' |
| Q30L60X40P000 |  73.21M |   40.0 |     57131 | 1.77M | 52 |       965 | 30.63K | 28 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'59'' | 0:00'42'' |
| Q30L60X40P001 |  73.21M |   40.0 |     58229 | 1.77M | 53 |       860 |  23.3K | 26 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'59'' | 0:00'43'' |
| Q30L60X40P002 |  73.21M |   40.0 |     60057 | 1.77M | 52 |      1634 | 21.06K | 17 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'43'' |
| Q30L60X40P003 |  73.21M |   40.0 |     58229 | 1.77M | 52 |       851 |  17.2K | 18 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'42'' |
| Q30L60X80P000 | 146.41M |   80.0 |     58229 | 1.77M | 52 |      1634 | 18.55K | 14 |   78.0 | 7.0 |  19.0 | 148.5 | "31,41,51,61,71,81" | 0:01'26'' | 0:00'42'' |
| Q30L60X80P001 | 146.41M |   80.0 |     58229 | 1.77M | 49 |      3503 | 17.15K | 12 |   79.5 | 7.5 |  19.0 | 153.0 | "31,41,51,61,71,81" | 0:01'26'' | 0:00'42'' |


| Name               |     N50 |      Sum |    # |
|:-------------------|--------:|---------:|-----:|
| Genome             | 1830138 |  1830138 |    1 |
| Paralogs           |    5432 |    95358 |   29 |
| X40.raw.corrected  |         |          |      |
| X40.trim.corrected |   11014 | 30760163 | 3520 |
| X80.raw.corrected  |         |          |      |
| X80.trim.corrected |   11133 | 58801690 | 6431 |
| X40.raw            |         |          |      |
| X40.trim           |  435588 |  1788708 |    6 |
| X80.raw            |         |          |      |
| X80.trim           | 1838071 |  1851226 |    2 |


| Name                   |     N50 |     Sum |   # |
|:-----------------------|--------:|--------:|----:|
| Genome                 | 1830138 | 1830138 |   1 |
| Paralogs               |    5432 |   95358 |  29 |
| anchor                 |   60057 | 1773239 |  49 |
| others                 |     851 |   54675 |  62 |
| anchorLong             |   99572 | 1772561 |  39 |
| contigTrim             |  376410 | 1791701 |   8 |
| canu-X80-raw           |         |         |     |
| canu-X80-trim          | 1838071 | 1851226 |   2 |
| spades.contig          |  127782 | 1822232 | 120 |
| spades.scaffold        |  131566 | 1822382 | 114 |
| spades.non-contained   |  127782 | 1797190 |  29 |
| platanus.contig        |   77817 | 1807137 | 154 |
| platanus.scaffold      |  161477 | 1799094 |  83 |
| platanus.non-contained |  161477 | 1789782 |  21 |


# Listeria monocytogenes FDAARGOS_351, 单核细胞增生李斯特氏菌

Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Lmon: download

* Settings

```bash
BASE_NAME=Lmon
REAL_G=2944528
IS_EUK="false"
SAMPLE2=
COVERAGE2="40 80"
COVERAGE3="40 80"
READ_QUAL="25 30"
READ_LEN="60"
EXPAND_WITH="80"

```

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

cp ~/data/anchr/paralogs/otherbac/Results/Lmon/Lmon.multi.fas paralogs.fas

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

## Lmon: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Lmon

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 2944528 \
    --trim2 "--uniq " \
    --sample 300 \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --parallel 24

# run
bsub -q mpi -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "done(${BASE_NAME}-0_master)" \
    -q mpi -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

```

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 2944528 |    2944528 |        1 |
| Paralogs |         |            |          |
| Illumina |     151 | 2590175480 | 17153480 |
| uniq     |     151 | 2462888218 | 16310518 |
| sample   |     151 |  588905436 |  3900036 |
| Q25L60   |     151 |  457352457 |  3268580 |
| Q30L60   |     151 |  442570581 |  3281099 |


| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG | EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|------:|------:|-----:|---------:|----------:|
| Q25L60 | 457.35M | 155.3 | 362.25M |  123.0 |  20.794% |     143 | "105" | 2.94M | 5.5M |     1.87 | 0:01'17'' |
| Q30L60 | 443.02M | 150.5 | 378.29M |  128.5 |  14.611% |     139 |  "91" | 2.94M | 5.4M |     1.84 | 0:01'17'' |


| Name          |  SumCor | CovCor | N50Anchor |    Sum |   # | N50Others |    Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|--------:|-------:|----------:|-------:|----:|----------:|-------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 | 117.78M |   40.0 |     29355 |  2.79M | 163 |       627 | 89.82K |  135 |   30.0 | 14.0 |   2.0 |  60.0 | "31,41,51,61,71,81" | 0:01'55'' | 0:00'50'' |
| Q25L60X40P001 | 117.78M |   40.0 |     27529 |  2.91M | 189 |       610 | 71.74K |  113 |   32.0 | 12.0 |   2.0 |  64.0 | "31,41,51,61,71,81" | 0:01'49'' | 0:00'50'' |
| Q25L60X40P002 | 117.78M |   40.0 |     24151 |  2.93M | 216 |       665 | 70.48K |  103 |   34.0 |  8.0 |   3.3 |  68.0 | "31,41,51,61,71,81" | 0:01'58'' | 0:00'51'' |
| Q25L60X80P000 | 235.56M |   80.0 |      1225 | 47.67K |  38 |      8370 |   3.6M | 1349 |    4.0 |  1.0 |   2.0 |   8.0 | "31,41,51,61,71,81" | 0:02'35'' | 0:00'50'' |
| Q30L60X40P000 | 117.78M |   40.0 |      1987 | 30.56K |  15 |     58920 |  3.25M |  205 |   14.0 | 12.0 |   2.0 |  28.0 | "31,41,51,61,71,81" | 0:01'56'' | 0:00'48'' |
| Q30L60X40P001 | 117.78M |   40.0 |      2534 | 37.38K |  17 |     58800 |  3.02M |  216 |   14.0 | 12.0 |   2.0 |  28.0 | "31,41,51,61,71,81" | 0:01'50'' | 0:00'47'' |
| Q30L60X40P002 | 117.78M |   40.0 |     57689 |  2.93M |  99 |       603 | 51.95K |   81 |   31.5 | 13.5 |   2.0 |  63.0 | "31,41,51,61,71,81" | 0:01'56'' | 0:00'44'' |
| Q30L60X80P000 | 235.56M |   80.0 |      1168 | 57.15K |  46 |     21762 |   3.6M | 1055 |    4.0 |  1.0 |   2.0 |   8.0 | "31,41,51,61,71,81" | 0:02'06'' | 0:00'44'' |

| Name                   |     N50 |     Sum |    # |
|:-----------------------|--------:|--------:|-----:|
| Genome                 | 2944528 | 2944528 |    1 |
| Paralogs               |         |         |      |
| anchor                 |  369542 | 3064639 |  115 |
| others                 |   57936 | 5487724 | 1458 |
| anchorLong             |         |         |      |
| contigTrim             |         |         |      |
| canu-X80-raw           |         |         |      |
| canu-X80-trim          |         |         |      |
| spades.contig          |    4582 | 8294104 | 8792 |
| spades.scaffold        |    4584 | 8294154 | 8787 |
| spades.non-contained   |  225033 | 5340540 |  714 |
| platanus.contig        |  289999 | 2969795 |  101 |
| platanus.scaffold      |  557585 | 2960623 |   32 |
| platanus.non-contained |  557585 | 2956610 |   15 |

# Clostridioides difficile 630

Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Cdif: download

* Settings

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Cdif
REAL_G=4298133
IS_EUK="false"
TRIM2="--uniq --shuffle --scythe "
SAMPLE2=200
COVERAGE2="40 80"
READ_QUAL="25 30"
READ_LEN="60"
COVERAGE3="40 80"
EXPAND_WITH="80"

```

* Reference genome

    * Strain: Clostridioides difficile 630
    * Taxid: [272563](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=272563)
    * RefSeq assembly accession:
      [GCF_000009205.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/009/205/GCF_000009205.1_ASM920v1/GCF_000009205.1_ASM920v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0661

```bash
mkdir -p ${WORKING_DIR}/${BASE_NAME}/1_genome
cd ${WORKING_DIR}/${BASE_NAME}/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/009/205/GCF_000009205.1_ASM920v1/GCF_000009205.1_ASM920v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_009089.1${TAB}1
NC_008226.1${TAB}pCD630
EOF

faops replace GCF_000009205.1_ASM920v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Cdif/Cdif.multi.fas paralogs.fas

```

* Illumina

    * [SRX2107163](https://www.ncbi.nlm.nih.gov/sra/SRX2107163) SRR4125185

```bash
mkdir -p ${WORKING_DIR}/${BASE_NAME}/2_illumina
cd ${WORKING_DIR}/${BASE_NAME}/2_illumina

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

## Cdif: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Cdif

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 4298133 \
    --trim2 "--uniq " \
    --sample 300 \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --parallel 24

# run
bsub -q mpi -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "done(${BASE_NAME}-0_master)" \
    -q mpi -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

```

| Name     |     N50 |     Sum |        # |
|:---------|--------:|--------:|---------:|
| Genome   | 4290252 | 4298133 |        2 |
| Illumina |     101 |   1.33G | 13190786 |
| uniq     |     101 |   1.32G | 13029692 |
| shuffle  |     101 |   1.32G | 13029692 |
| sample   |     101 | 859.63M |  8511154 |
| scythe   |     101 | 850.77M |  8511154 |
| Q25L60   |     101 |  787.8M |  7855952 |
| Q30L60   |     101 | 771.97M |  7785648 |


| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead | Kmer | RealG | EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|-----:|------:|-----:|---------:|----------:|
| Q25L60 |  787.8M | 183.3 | 740.76M |  172.3 |   5.971% |     100 | "71" |  4.3M | 4.2M |     0.98 | 0:03'34'' |
| Q30L60 | 772.47M | 179.7 | 736.69M |  171.4 |   4.631% |      99 | "71" |  4.3M | 4.2M |     0.98 | 0:03'18'' |


| Name          |  SumCor | CovCor | N50Anchor |   Sum |   # | N50Others |    Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|--------:|-------:|----------:|------:|----:|----------:|-------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 | 171.93M |   40.0 |    102986 | 4.14M | 109 |      7659 |  65.9K | 44 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:03'14'' | 0:01'34'' |
| Q25L60X40P001 | 171.93M |   40.0 |     86904 | 4.15M | 116 |      1043 | 58.84K | 47 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:03'10'' | 0:01'36'' |
| Q25L60X40P002 | 171.93M |   40.0 |     88796 | 4.15M | 113 |      1367 |  56.7K | 44 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:03'08'' | 0:01'38'' |
| Q25L60X40P003 | 171.93M |   40.0 |     91606 | 4.15M | 116 |      1367 | 56.37K | 42 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:02'55'' | 0:01'26'' |
| Q25L60X80P000 | 343.85M |   80.0 |     85314 | 4.15M | 122 |      7145 |  40.5K | 24 |   80.0 | 7.0 |  19.7 | 151.5 | "31,41,51,61,71,81" | 0:04'20'' | 0:01'45'' |
| Q25L60X80P001 | 343.85M |   80.0 |     80207 | 4.15M | 119 |      2859 | 39.31K | 24 |   80.0 | 7.0 |  19.7 | 151.5 | "31,41,51,61,71,81" | 0:04'21'' | 0:01'41'' |
| Q30L60X40P000 | 171.93M |   40.0 |    104088 | 4.15M | 108 |      1367 | 53.69K | 40 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:03'18'' | 0:01'27'' |
| Q30L60X40P001 | 171.93M |   40.0 |     85713 | 4.15M | 110 |      1102 | 58.35K | 46 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:03'08'' | 0:01'42'' |
| Q30L60X40P002 | 171.93M |   40.0 |     86799 | 4.15M | 110 |      1102 |  56.5K | 45 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:03'10'' | 0:01'47'' |
| Q30L60X40P003 | 171.93M |   40.0 |     86240 | 4.15M | 109 |      1017 | 63.11K | 52 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:03'06'' | 0:01'43'' |
| Q30L60X80P000 | 343.85M |   80.0 |    105540 | 4.14M | 103 |      7659 | 41.42K | 23 |   78.0 | 8.0 |  18.0 | 153.0 | "31,41,51,61,71,81" | 0:04'15'' | 0:02'01'' |
| Q30L60X80P001 | 343.85M |   80.0 |    105540 | 4.15M | 104 |      5646 | 39.41K | 22 |   79.0 | 7.0 |  19.3 | 150.0 | "31,41,51,61,71,81" | 0:04'20'' | 0:01'52'' |

| Name                   |     N50 |     Sum |   # |
|:-----------------------|--------:|--------:|----:|
| Genome                 | 4290252 | 4298133 |   2 |
| Paralogs               |         |         |     |
| anchor                 |  108261 | 4145958 |  89 |
| others                 |     953 |  138134 | 124 |
| spades.contig          |  227529 | 4237854 | 241 |
| spades.scaffold        |  227529 | 4237894 | 237 |
| spades.non-contained   |  227529 | 4200680 |  50 |
| platanus.contig        |  104398 | 4271640 | 680 |
| platanus.scaffold      |  225728 | 4236396 | 416 |
| platanus.non-contained |  225728 | 4181483 |  49 |

# Campylobacter jejuni subsp. jejuni ATCC 700819, 空肠弯曲杆菌

Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Cjej: download

* Settings

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Cjej
REAL_G=1641481
IS_EUK="false"
TRIM2="--uniq "
SAMPLE2=200
COVERAGE2="40 80"
READ_QUAL="25 30"
READ_LEN="60"
COVERAGE3="40 80"
EXPAND_WITH="80"

```

* Reference genome

    * Strain: Campylobacter jejuni subsp. jejuni NCTC 11168 = ATCC 700819
    * Taxid:
      [192222](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=192222&lvl=3&lin=f&keep=1&srchmode=1&unlock)
    * RefSeq assembly accession:
      [GCF_000009085.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/009/085/GCF_000009085.1_ASM908v1/GCF_000009085.1_ASM908v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0196

```bash
mkdir -p ${WORKING_DIR}/${BASE_NAME}/1_genome
cd ${WORKING_DIR}/${BASE_NAME}/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/009/085/GCF_000009085.1_ASM908v1/GCF_000009085.1_ASM908v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_002163.1${TAB}1
EOF

faops replace GCF_000009085.1_ASM908v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Cjej/Cjej.multi.fas paralogs.fas

```

* Illumina

    * [SRX2107012](https://www.ncbi.nlm.nih.gov/sra/SRX2107012) SRR4125016

```bash
mkdir -p ${WORKING_DIR}/${BASE_NAME}/2_illumina
cd ${WORKING_DIR}/${BASE_NAME}/2_illumina

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

## Cjej: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=Cjej

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 1641481 \
    --trim2 "--uniq " \
    --sample 300 \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --parallel 24

# run
bsub -q mpi -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "done(${BASE_NAME}-0_master)" \
    -q mpi -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

```

| Name     |     N50 |     Sum |        # |
|:---------|--------:|--------:|---------:|
| Genome   | 1641481 | 1641481 |        1 |
| Paralogs |    6093 |   33281 |       13 |
| Illumina |     101 |   1.55G | 15393600 |
| uniq     |     101 |   1.54G | 15284366 |
| sample   |     101 |  328.3M |  3250458 |
| Q25L60   |     101 | 307.44M |  3062540 |
| Q30L60   |     101 | 296.61M |  2990738 |


| Name   |   SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|--------:|------:|-------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 307.44M | 187.3 | 291.4M |  177.5 |   5.218% |     100 | "71" | 1.64M | 1.62M |     0.99 | 0:02'44'' |
| Q30L60 | 296.72M | 180.8 | 284.1M |  173.1 |   4.253% |      99 | "71" | 1.64M | 1.62M |     0.99 | 0:02'31'' |


| Name          |  SumCor | CovCor | N50Anchor |  Sum |  # | N50Others |    Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|--------:|-------:|----------:|-----:|---:|----------:|-------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |  65.66M |   40.0 |     80002 | 1.6M | 43 |       803 | 17.45K | 15 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:02'15'' | 0:01'06'' |
| Q25L60X40P001 |  65.66M |   40.0 |     75238 | 1.6M | 48 |       837 | 21.69K | 21 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:02'14'' | 0:01'04'' |
| Q25L60X40P002 |  65.66M |   40.0 |     64806 | 1.6M | 46 |      2340 | 16.24K | 13 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:02'34'' | 0:01'03'' |
| Q25L60X40P003 |  65.66M |   40.0 |     80035 | 1.6M | 44 |      1016 | 19.79K | 17 |   38.0 | 2.5 |  10.2 |  68.2 | "31,41,51,61,71,81" | 0:02'33'' | 0:01'09'' |
| Q25L60X80P000 | 131.32M |   80.0 |     78388 | 1.6M | 54 |      2340 | 16.11K | 13 |   77.0 | 4.0 |  21.7 | 133.5 | "31,41,51,61,71,81" | 0:03'41'' | 0:01'08'' |
| Q25L60X80P001 | 131.32M |   80.0 |     68939 | 1.6M | 51 |      2340 | 16.21K | 13 |   78.0 | 4.0 |  22.0 | 135.0 | "31,41,51,61,71,81" | 0:03'32'' | 0:01'08'' |
| Q30L60X40P000 |  65.66M |   40.0 |     79979 | 1.6M | 43 |       802 | 17.29K | 15 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:02'36'' | 0:01'00'' |
| Q30L60X40P001 |  65.66M |   40.0 |     71607 | 1.6M | 44 |       852 | 20.89K | 19 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:02'41'' | 0:01'03'' |
| Q30L60X40P002 |  65.66M |   40.0 |     80036 | 1.6M | 41 |       972 | 20.54K | 17 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:02'11'' | 0:00'59'' |
| Q30L60X40P003 |  65.66M |   40.0 |     71610 | 1.6M | 42 |       871 | 20.89K | 18 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:02'10'' | 0:00'56'' |
| Q30L60X80P000 | 131.32M |   80.0 |     79987 | 1.6M | 47 |      2340 | 14.82K | 11 |   76.0 | 4.0 |  21.3 | 132.0 | "31,41,51,61,71,81" | 0:02'54'' | 0:00'56'' |
| Q30L60X80P001 | 131.32M |   80.0 |     80036 | 1.6M | 43 |      1122 | 16.86K | 13 |   77.0 | 4.0 |  21.7 | 133.5 | "31,41,51,61,71,81" | 0:02'57'' | 0:00'57'' |


| Name                   |     N50 |     Sum |   # |
|:-----------------------|--------:|--------:|----:|
| Genome                 | 1641481 | 1641481 |   1 |
| Paralogs               |    6093 |   33281 |  13 |
| anchor                 |  104218 | 1597792 |  31 |
| others                 |     873 |   37620 |  39 |
| spades.contig          |  153957 | 1628987 |  36 |
| spades.scaffold        |  189386 | 1629007 |  34 |
| spades.non-contained   |  153957 | 1622178 |  18 |
| platanus.contig        |  112542 | 1629204 | 124 |
| platanus.scaffold      |  153889 | 1622715 |  70 |
| platanus.non-contained |  153889 | 1611433 |  20 |

# Escherichia virus Lambda

Project [SRP055199](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP055199)

## lambda: download

* Settings

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=lambda
REAL_G=48502
IS_EUK="false"
TRIM2="--uniq --scythe "
SAMPLE2=200
COVERAGE2="40 80"
READ_QUAL="25 30"
READ_LEN="60"
COVERAGE3="40 80"
EXPAND_WITH="80"

cat <<EOF > ${WORKING_DIR}/${BASE_NAME}/2_illumina/illumina_adapters.fa
>multiplexing-forward
GATCGGAAGAGCACACGTCT
>truseq-forward-contam
AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
>truseq-reverse-contam
AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTA

>TruSeq_Adapter_Index_1
AGATCGGAAGAGCACACGTCTGAACTCCAGTCACATGAGCATCTCGTATG
>No_Hit
AGGTCGCCGCCCCGTAACCTGTCGGATCACCGGAAAGGACCCGTAAAGTG

>Illumina_Single_End_PCR_Primer_1
AGATCGGAAGAGCACACGTCTGAACTCCAGTCACATGAGCATCTCGTATG

EOF

```

* Reference genome

    * Strain: Escherichia virus Lambda (viruses)
    * Taxid:
      [10710](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=10710&lvl=3&lin=f&keep=1&srchmode=1&unlock)
    * RefSeq assembly accession:
      [GCF_000840245.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/840/245/GCF_000840245.1_ViralProj14204/GCF_000840245.1_ViralProj14204_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0

```bash
mkdir -p ${WORKING_DIR}/${BASE_NAME}/1_genome
cd ${WORKING_DIR}/${BASE_NAME}/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/840/245/GCF_000840245.1_ViralProj14204/GCF_000840245.1_ViralProj14204_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_001416.1${TAB}1
EOF

faops replace GCF_000840245.1_ViralProj14204_genomic.fna.gz replace.tsv genome.fa

#cp ~/data/anchr/paralogs/otherbac/Results/lambda/lambda.multi.fas paralogs.fas
touch paralogs.fas

```

* Illumina

    * [SRX2365802](https://www.ncbi.nlm.nih.gov/sra/SRR5042715)

```bash
mkdir -p ${WORKING_DIR}/${BASE_NAME}/2_illumina
cd ${WORKING_DIR}/${BASE_NAME}/2_illumina

aria2c -x 9 -s 3 -c https://sra-download.ncbi.nlm.nih.gov/traces/sra16/SRR/004924/SRR5042715
fastq-dump --split-files ./SRR5042715

find . -type f -name "*.fastq" | parallel -j 2 pigz -p 8 

ln -s SRR5042715_1.fastq.gz R1.fq.gz
ln -s SRR5042715_2.fastq.gz R2.fq.gz

```

* PacBio

```bash
mkdir -p ${WORKING_DIR}/${BASE_NAME}/3_pacbio
cd ${WORKING_DIR}/${BASE_NAME}/3_pacbio

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

## lambda: preprocess Illumina reads

## lambda: preprocess PacBio reads

## lambda: reads stats

| Name     |   N50 |    Sum |        # |
|:---------|------:|-------:|---------:|
| Genome   | 48502 |  48502 |        1 |
| Paralogs |     0 |      0 |        0 |
| Illumina |   108 |  3.57G | 33080474 |
| uniq     |   108 |  2.98G | 27609894 |
| sample   |   108 |   9.7M |    89820 |
| scythe   |   108 |  9.45M |    89820 |
| Q25L60   |   108 |   7.9M |    75110 |
| Q30L60   |   108 |   7.5M |    74201 |
| PacBio   |  1325 | 11.95M |     9796 |
| X40.raw  |  1363 |  1.94M |     1536 |
| X40.trim |  1456 |  1.51M |     1050 |
| X80.raw  |  1361 |  3.88M |     3084 |
| X80.trim |  1453 |  3.06M |     2133 |

## lambda: spades

## lambda: platanus

## lambda: quorum

| Name   | SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|------:|-------:|-------:|---------:|--------:|-----:|------:|-------:|---------:|----------:|
| Q25L60 |  7.9M | 163.0 |  7.56M |  155.9 |   4.367% |     105 | "75" | 48.5K | 48.48K |     1.00 | 0:00'50'' |
| Q30L60 | 7.51M | 154.8 |  7.26M |  149.8 |   3.240% |     102 | "75" | 48.5K | 48.48K |     1.00 | 0:00'18'' |

## lambda: adapter filtering

## lambda: down sampling

## lambda: k-unitigs and anchors (sampled)

| Name          | SumCor | CovCor | N50Anchor |    Sum | # | N50Others |  Sum | # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|-------:|----------:|-------:|--:|----------:|-----:|--:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |  1.94M |   40.0 |     29275 | 48.33K | 2 |         0 |    0 | 0 |   38.0 | 0.0 |  12.7 |  57.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'31'' |
| Q25L60X40P001 |  1.94M |   40.0 |     48447 | 48.45K | 1 |         0 |    0 | 0 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'30'' |
| Q25L60X40P002 |  1.94M |   40.0 |     48358 | 48.36K | 1 |         0 |    0 | 0 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'31'' |
| Q25L60X40P003 |  1.94M |   40.0 |     47199 | 48.33K | 2 |       957 |  957 | 1 |   32.5 | 5.0 |   5.8 |  65.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'30'' |
| Q25L60X40P004 |  1.94M |   40.0 |     45503 | 47.99K | 2 |         0 |    0 | 0 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'31'' |
| Q25L60X40P005 |  1.94M |   40.0 |     29387 | 48.47K | 2 |         0 |    0 | 0 |   41.0 | 1.0 |  12.7 |  66.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'30'' |
| Q25L60X40P006 |  1.94M |   40.0 |     46323 |    49K | 2 |         0 |    0 | 0 |   39.5 | 0.5 |  12.7 |  61.5 | "31,41,51,61,71,81" | 0:00'07'' | 0:00'32'' |
| Q25L60X80P000 |  3.88M |   80.0 |     29388 | 48.53K | 2 |         0 |    0 | 0 |   77.0 | 1.0 |  24.7 | 120.0 | "31,41,51,61,71,81" | 0:00'09'' | 0:00'31'' |
| Q25L60X80P001 |  3.88M |   80.0 |      3127 |  3.13K | 1 |      1236 | 2.2K | 2 |   58.0 | 1.0 |  18.3 |  91.5 | "31,41,51,61,71,81" | 0:00'07'' | 0:00'30'' |
| Q25L60X80P002 |  3.88M |   80.0 |     26384 | 48.32K | 3 |         0 |    0 | 0 |   78.0 | 5.0 |  21.0 | 139.5 | "31,41,51,61,71,81" | 0:00'07'' | 0:00'30'' |
| Q30L60X40P000 |  1.94M |   40.0 |     48264 | 48.26K | 1 |         0 |    0 | 0 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'29'' |
| Q30L60X40P001 |  1.94M |   40.0 |     48419 | 48.42K | 1 |         0 |    0 | 0 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'07'' | 0:00'29'' |
| Q30L60X40P002 |  1.94M |   40.0 |     48256 | 48.26K | 1 |         0 |    0 | 0 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'05'' | 0:00'30'' |
| Q30L60X40P003 |  1.94M |   40.0 |     48202 |  48.2K | 1 |         0 |    0 | 0 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'28'' |
| Q30L60X40P004 |  1.94M |   40.0 |     48268 | 48.27K | 1 |         0 |    0 | 0 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'29'' |
| Q30L60X40P005 |  1.94M |   40.0 |     48386 | 48.39K | 1 |         0 |    0 | 0 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'05'' | 0:00'26'' |
| Q30L60X40P006 |  1.94M |   40.0 |     48355 | 48.36K | 1 |         0 |    0 | 0 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'27'' |
| Q30L60X80P000 |  3.88M |   80.0 |     48448 | 48.45K | 1 |         0 |    0 | 0 |   80.0 | 0.0 |  26.7 | 120.0 | "31,41,51,61,71,81" | 0:00'07'' | 0:00'28'' |
| Q30L60X80P001 |  3.88M |   80.0 |     48491 | 48.49K | 1 |         0 |    0 | 0 |   80.0 | 0.0 |  26.7 | 120.0 | "31,41,51,61,71,81" | 0:00'07'' | 0:00'28'' |
| Q30L60X80P002 |  3.88M |   80.0 |     48388 | 48.39K | 1 |         0 |    0 | 0 |   80.0 | 0.0 |  26.7 | 120.0 | "31,41,51,61,71,81" | 0:00'06'' | 0:00'27'' |

## lambda: merge anchors

## lambda: 3GS

| Name               |   N50 |     Sum |    # |
|:-------------------|------:|--------:|-----:|
| Genome             | 48502 |   48502 |    1 |
| Paralogs           |     0 |       0 |    0 |
| X40.raw.corrected  |  1459 | 1516012 | 1048 |
| X40.trim.corrected |  1448 | 1478749 | 1027 |
| X80.raw.corrected  |  1638 | 1934295 | 1165 |
| X80.trim.corrected |  1624 | 1937656 | 1175 |
| X40.raw            | 50619 |   50619 |    1 |
| X40.trim           | 45657 |   45657 |    1 |
| X80.raw            | 48497 |   50960 |    2 |
| X80.trim           | 48489 |   48489 |    1 |

## lambda: final stats

* Stats

| Name                   |   N50 |   Sum | # |
|:-----------------------|------:|------:|--:|
| Genome                 | 48502 | 48502 | 1 |
| Paralogs               |     0 |     0 | 0 |
| anchor                 | 48512 | 48512 | 1 |
| others                 |     0 |     0 | 0 |
| canu-X80-raw           | 48497 | 50960 | 2 |
| canu-X80-trim          | 48489 | 48489 | 1 |
| spades.contig          | 48514 | 48514 | 1 |
| spades.scaffold        | 48514 | 48514 | 1 |
| spades.non-contained   | 48514 | 48514 | 1 |
| platanus.contig        | 46367 | 48480 | 2 |
| platanus.scaffold      | 48424 | 48424 | 1 |
| platanus.non-contained | 48424 | 48424 | 1 |

* quast

## lambda: clear intermediate files

