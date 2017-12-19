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
    - [lambda: run](#lambda-run)


* Rsync to hpc

```bash
for D in Vpar Lpne Ngon Nmen Bper Cdif Cdip Cjej Ftul Hinf Lmon Ngon Nmen Sfle; do
    rsync -avP \
        --exclude="*_hdf5.tgz" \
        ~/data/anchr/${D}/ \
        wangq@202.119.37.251:data/anchr/${D}
done

# rsync -avP wangq@202.119.37.251:data/anchr/ ~/data/anchr

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
| Q25L60    |     101 |    1.2G | 12017922 |
| Q30L60    |     101 |   1.14G | 11614756 |
| PacBio    |   11771 |   1.23G |   143537 |
| X80.raw   |   11822 | 413.26M |    48766 |
| X80.trim  |   10678 | 355.44M |    41795 |
| Xall.raw  |   11771 |   1.23G |   143537 |
| Xall.trim |   10770 |   1.08G |   125808 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 232.5 |  216.4 |   6.918% |     100 | "71" | 5.17M | 5.48M |     1.06 | 0:02'16'' |
| Q30L60 | 221.1 |  207.2 |   6.305% |      99 | "71" | 5.17M | 5.42M |     1.05 | 0:02'12'' |

| Name          | CovCor | N50Anchor |   Sum |   # | N50Others |    Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|------:|----:|----------:|-------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |     91099 | 5.04M | 102 |       708 |  26.4K | 37 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'57'' |
| Q25L60X40P001 |   40.0 |    105193 | 5.04M |  96 |       773 | 25.24K | 34 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'54'' |
| Q25L60X40P002 |   40.0 |     85815 | 5.05M | 106 |       745 | 25.74K | 36 |   38.0 | 3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'58'' |
| Q25L60X40P003 |   40.0 |     99705 | 5.04M |  92 |       721 | 25.48K | 36 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'59'' |
| Q25L60X40P004 |   40.0 |    101959 | 5.04M | 104 |       745 | 27.89K | 39 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'59'' |
| Q25L60X80P000 |   80.0 |     81937 | 5.04M | 126 |       710 | 18.91K | 27 |   77.0 | 8.0 |  17.7 | 151.5 | "31,41,51,61,71,81" | 0:01'16'' | 0:00'53'' |
| Q25L60X80P001 |   80.0 |     75731 | 5.04M | 133 |       710 | 17.49K | 25 |   77.5 | 8.5 |  17.3 | 154.5 | "31,41,51,61,71,81" | 0:01'16'' | 0:00'51'' |
| Q30L60X40P000 |   40.0 |    115357 | 5.04M |  83 |       729 | 28.65K | 40 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:01'04'' |
| Q30L60X40P001 |   40.0 |    139690 | 5.04M |  82 |       762 | 23.36K | 32 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:01'03'' |
| Q30L60X40P002 |   40.0 |     99705 | 5.04M |  91 |       693 | 26.81K | 39 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:01'05'' |
| Q30L60X40P003 |   40.0 |    152507 | 5.04M |  83 |       762 | 27.11K | 37 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:01'07'' |
| Q30L60X40P004 |   40.0 |    119300 | 5.04M |  88 |       799 | 32.35K | 45 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:01'02'' |
| Q30L60X80P000 |   80.0 |    115357 | 5.04M |  91 |       697 | 17.96K | 26 |   75.0 | 7.0 |  18.0 | 144.0 | "31,41,51,61,71,81" | 0:01'19'' | 0:01'01'' |
| Q30L60X80P001 |   80.0 |     95833 | 5.05M |  99 |       697 | 16.72K | 24 |   76.0 | 7.0 |  18.3 | 145.5 | "31,41,51,61,71,81" | 0:01'19'' | 0:01'01'' |

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
| anchors                |  179419 | 5052828 |   72 |
| others                 |     825 |   83632 |  108 |
| anchorLong             |  208183 | 5051243 |   61 |
| anchorFill             |  561553 | 5099400 |   15 |
| canu_X80-trim          | 3316838 | 5204553 |    2 |
| canu_Xall-trim         | 3292632 | 5188352 |    2 |
| spades.contig          |  256618 | 6579379 | 3934 |
| spades.scaffold        |  373514 | 6588350 | 3681 |
| spades.non-contained   |  288633 | 5166146 |  126 |
| platanus.contig        |  196706 | 5152490 |  618 |
| platanus.scaffold      |  339534 | 5134546 |  434 |
| platanus.non-contained |  426844 | 5061525 |   34 |

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
| sample    |     101 |   1.02G | 10092338 |
| Q25L60    |     101 | 877.57M |  8811868 |
| Q30L60    |     101 | 804.77M |  8295746 |
| PacBio    |    8538 | 287.32M |    56763 |
| X80.raw   |    8542 | 271.82M |    53600 |
| X80.trim  |    8354 | 232.88M |    39020 |
| Xall.raw  |    8538 | 287.32M |    56763 |
| Xall.trim |    8357 | 246.63M |    41404 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 258.3 |  238.2 |   7.766% |      99 | "71" |  3.4M | 3.43M |     1.01 | 0:01'43'' |
| Q30L60 | 237.0 |  222.1 |   6.305% |      97 | "71" |  3.4M | 3.41M |     1.00 | 0:01'36'' |

| Name          | CovCor | N50Anchor |   Sum |   # | N50Others |    Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|------:|----:|----------:|-------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |     73659 | 3.36M |  82 |       821 | 42.55K | 50 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'46'' |
| Q25L60X40P001 |   40.0 |     79418 | 3.36M |  83 |       873 | 36.66K | 44 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'47'' |
| Q25L60X40P002 |   40.0 |     80214 | 3.36M |  73 |       828 | 40.01K | 50 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'47'' |
| Q25L60X40P003 |   40.0 |     96726 | 3.36M |  75 |       880 | 39.41K | 46 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'47'' |
| Q25L60X40P004 |   40.0 |     92462 | 3.36M |  73 |       881 | 42.14K | 47 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'47'' |
| Q25L60X80P000 |   80.0 |     46694 | 3.36M | 133 |      2827 | 71.09K | 46 |   78.0 | 3.0 |  23.0 | 130.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'41'' |
| Q25L60X80P001 |   80.0 |     59253 | 3.36M | 111 |      1151 | 53.98K | 46 |   78.0 | 3.0 |  23.0 | 130.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'43'' |
| Q30L60X40P000 |   40.0 |    132985 | 3.36M |  62 |       869 | 52.56K | 61 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'50'' |
| Q30L60X40P001 |   40.0 |    117571 | 3.36M |  61 |       894 | 40.27K | 46 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'49'' |
| Q30L60X40P002 |   40.0 |     91377 | 3.36M |  60 |       839 | 49.26K | 60 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'48'' |
| Q30L60X40P003 |   40.0 |    117588 | 3.38M |  56 |       952 |  41.3K | 47 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'49'' |
| Q30L60X40P004 |   40.0 |    122898 | 3.36M |  55 |       930 |  46.8K | 53 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'49'' |
| Q30L60X80P000 |   80.0 |    120743 | 3.36M |  67 |      1814 |  59.5K | 44 |   78.0 | 3.0 |  23.0 | 130.5 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'50'' |
| Q30L60X80P001 |   80.0 |     92790 | 3.35M |  68 |      1703 | 54.45K | 41 |   79.0 | 3.0 |  23.3 | 132.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'48'' |

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
| anchors                |  248594 | 3377664 |  37 |
| others                 |    1065 |  166068 | 137 |
| anchorLong             |  261851 | 3376822 |  32 |
| anchorFill             |  658232 | 3105800 |   7 |
| canu_X80-trim          | 3403179 | 3403179 |   1 |
| canu_Xall-trim         | 3417657 | 3431477 |   2 |
| spades.contig          |  431777 | 3480647 | 280 |
| spades.scaffold        |  431777 | 3480757 | 278 |
| spades.non-contained   |  431777 | 3407583 |  28 |
| platanus.contig        |  198660 | 3392629 | 208 |
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
| sample    |     101 | 646.18M |  6397788 |
| Q25L60    |     101 | 462.78M |  4736452 |
| Q30L60    |     101 | 385.05M |  4142102 |
| PacBio    |   11808 |   1.19G |   137516 |
| X80.raw   |   11668 | 172.32M |    20331 |
| X80.trim  |    9976 | 136.79M |    17440 |
| Xall.raw  |   11808 |   1.19G |   137516 |
| Xall.trim |   10448 | 985.14M |   119743 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 214.9 |  197.2 |   8.239% |      97 | "51" | 2.15M | 2.07M |     0.96 | 0:00'59'' |
| Q30L60 | 179.1 |  167.7 |   6.358% |      93 | "61" | 2.15M | 2.05M |     0.95 | 0:00'49'' |

| Name          | CovCor | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |     13096 | 1.97M | 233 |       883 | 154.38K | 178 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'40'' |
| Q25L60X40P001 |   40.0 |     13870 | 1.93M | 224 |       932 | 132.14K | 143 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'42'' |
| Q25L60X40P002 |   40.0 |     14625 | 1.94M | 206 |       925 | 133.17K | 138 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'24'' | 0:00'40'' |
| Q25L60X40P003 |   40.0 |     16784 | 1.94M | 192 |       897 | 128.43K | 141 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'40'' |
| Q25L60X80P000 |   80.0 |     13056 | 1.95M | 245 |       925 |  80.82K |  91 |   75.0 | 7.0 |  18.0 | 144.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'38'' |
| Q25L60X80P001 |   80.0 |     13341 | 1.95M | 211 |       957 |  79.29K |  80 |   76.0 | 6.0 |  19.3 | 141.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'37'' |
| Q30L60X40P000 |   40.0 |     12518 | 1.73M | 225 |       978 | 285.85K | 276 |   36.0 | 5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'41'' |
| Q30L60X40P001 |   40.0 |     15386 | 1.83M | 197 |       922 | 201.95K | 209 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'22'' | 0:00'42'' |
| Q30L60X40P002 |   40.0 |     16897 | 1.82M | 183 |       943 | 186.67K | 189 |   36.0 | 4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'41'' |
| Q30L60X40P003 |   40.0 |     16750 | 1.95M | 195 |       916 | 216.42K | 240 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'22'' | 0:00'43'' |
| Q30L60X80P000 |   80.0 |     16312 | 1.82M | 182 |      1095 | 128.25K | 120 |   73.0 | 9.0 |  15.3 | 146.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'43'' |
| Q30L60X80P001 |   80.0 |     19446 | 1.91M | 158 |      1037 | 103.72K | 100 |   75.0 | 6.0 |  19.0 | 139.5 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'42'' |

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
| anchors                |   24297 | 1984570 | 136 |
| others                 |     979 |  501884 | 490 |
| anchorLong             |   38369 | 1399492 |  78 |
| anchorFill             |   69946 | 1589914 |  58 |
| canu_X80-trim          | 2205541 | 2205541 |   1 |
| canu_Xall-trim         | 2207006 | 2207006 |   1 |
| spades.contig          |   50390 | 2138131 | 442 |
| spades.scaffold        |   52499 | 2138209 | 435 |
| spades.non-contained   |   55104 | 2057924 |  79 |
| platanus.contig        |   19297 | 2142351 | 957 |
| platanus.scaffold      |   44073 | 2109515 | 552 |
| platanus.non-contained |   46751 | 2034470 |  88 |

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
| sample    |     101 | 681.71M |  6749584 |
| Q25L60    |     101 | 496.17M |  5071942 |
| Q30L60    |     101 | 416.94M |  4471387 |
| PacBio    |    9603 | 402.17M |    58711 |
| X80.raw   |    9605 | 181.79M |    26345 |
| X80.trim  |    9133 | 163.29M |    21467 |
| Xall.raw  |    9603 | 402.17M |    58711 |
| Xall.trim |    9188 | 364.96M |    47561 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 218.4 |  200.9 |   7.975% |      97 | "71" | 2.27M | 3.45M |     1.52 | 0:01'04'' |
| Q30L60 | 183.8 |  172.2 |   6.310% |      93 | "61" | 2.27M | 3.23M |     1.42 | 0:00'55'' |

| Name          | CovCor | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|------:|----:|----------:|--------:|----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |      7563 | 1.91M | 370 |       913 | 259.64K | 281 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'42'' |
| Q25L60X40P001 |   40.0 |      7201 | 1.98M | 372 |       855 | 235.14K | 277 |   36.0 |  4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'24'' | 0:00'41'' |
| Q25L60X40P002 |   40.0 |      7978 | 1.94M | 330 |       926 | 227.74K | 236 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'24'' | 0:00'42'' |
| Q25L60X40P003 |   40.0 |      8031 | 1.92M | 326 |       935 |  231.2K | 235 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'24'' | 0:00'42'' |
| Q25L60X40P004 |   40.0 |      8239 | 1.94M | 323 |       907 | 212.64K | 225 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'24'' | 0:00'42'' |
| Q25L60X80P000 |   80.0 |      7210 | 1.97M | 390 |       888 | 138.31K | 157 |   72.0 |  8.0 |  16.0 | 144.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'39'' |
| Q25L60X80P001 |   80.0 |      7398 | 1.94M | 361 |       981 | 146.37K | 145 |   72.0 |  6.0 |  18.0 | 135.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'38'' |
| Q30L60X40P000 |   40.0 |      7601 | 1.79M | 336 |       972 |  448.2K | 453 |   35.0 |  5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'44'' |
| Q30L60X40P001 |   40.0 |      8194 | 1.87M | 306 |       895 | 347.57K | 368 |   36.0 |  5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'24'' | 0:00'44'' |
| Q30L60X40P002 |   40.0 |      8184 | 1.87M | 306 |       935 | 329.05K | 339 |   35.0 |  4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:00'24'' | 0:00'44'' |
| Q30L60X40P003 |   40.0 |      8663 | 1.96M | 307 |       907 | 352.61K | 388 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'43'' |
| Q30L60X80P000 |   80.0 |      8369 | 1.82M | 288 |       945 | 231.96K | 235 |   69.0 | 10.0 |  13.0 | 138.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'46'' |
| Q30L60X80P001 |   80.0 |      8814 | 1.89M | 283 |      1029 | 179.32K | 167 |   72.0 |  6.0 |  18.0 | 135.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'44'' |

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
| anchors                |   10021 | 2057653 |  284 |
| others                 |     965 |  853858 |  849 |
| anchorLong             |    7003 |  637071 |  148 |
| anchorFill             |    7003 |  637071 |  148 |
| canu_X80-trim          | 2196486 | 2196486 |    1 |
| canu_Xall-trim         | 2196899 | 2196899 |    1 |
| spades.contig          |    5084 | 4260387 | 2266 |
| spades.scaffold        |    5920 | 4264602 | 2021 |
| spades.non-contained   |   11959 | 3691953 |  903 |
| platanus.contig        |    8727 | 2275427 | 1683 |
| platanus.scaffold      |   40822 | 2207397 |  832 |
| platanus.non-contained |   42294 | 2085723 |   99 |


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
| sample    |     101 | 746.59M |  7391986 |
| Q25L60    |     101 | 540.97M |  5530296 |
| Q30L60    |     101 | 449.33M |  4843518 |
| PacBio    |    8966 |  665.8M |   110317 |
| X80.raw   |    8781 | 199.09M |    33954 |
| X80.trim  |    7824 | 153.76M |    25880 |
| Xall.raw  |    8966 |  665.8M |   110317 |
| Xall.trim |    8046 | 524.96M |    85915 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 217.4 |  198.4 |   8.725% |      97 | "51" | 2.49M | 2.48M |     1.00 | 0:01'15'' |
| Q30L60 | 180.9 |  169.0 |   6.551% |      93 | "43" | 2.49M | 2.46M |     0.99 | 0:00'59'' |

| Name          | CovCor | N50Anchor |   Sum |   # | N50Others |    Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|------:|----:|----------:|-------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |     39431 | 2.47M | 111 |       833 | 36.41K | 44 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'25'' | 0:00'40'' |
| Q25L60X40P001 |   40.0 |     42408 | 2.46M | 110 |       887 | 34.85K | 38 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'25'' | 0:00'40'' |
| Q25L60X40P002 |   40.0 |     48583 | 2.45M |  92 |       813 | 22.72K | 28 |   38.0 | 3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:00'26'' | 0:00'40'' |
| Q25L60X40P003 |   40.0 |     64124 | 2.44M |  71 |       832 | 28.27K | 33 |   38.0 | 3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:00'26'' | 0:00'42'' |
| Q25L60X80P000 |   80.0 |     32637 | 2.44M | 130 |       789 | 18.56K | 23 |   74.0 | 7.0 |  17.7 | 142.5 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'40'' |
| Q25L60X80P001 |   80.0 |     37088 | 2.44M | 108 |       748 | 13.16K | 17 |   76.0 | 6.0 |  19.3 | 141.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'37'' |
| Q30L60X40P000 |   40.0 |     60932 | 2.41M |  81 |       880 |  42.6K | 48 |   36.0 | 6.0 |   6.0 |  72.0 | "31,41,51,61,71,81" | 0:00'25'' | 0:00'43'' |
| Q30L60X40P001 |   40.0 |     61760 | 2.44M |  76 |       915 | 36.09K | 40 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'25'' | 0:00'43'' |
| Q30L60X40P002 |   40.0 |     89696 | 2.44M |  66 |       880 | 33.35K | 36 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'26'' | 0:00'44'' |
| Q30L60X40P003 |   40.0 |     61694 | 2.43M |  66 |       880 | 46.32K | 50 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'25'' | 0:00'42'' |
| Q30L60X80P000 |   80.0 |     69794 | 2.44M |  61 |       844 | 17.16K | 19 |   72.0 | 9.0 |  15.0 | 144.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'47'' |
| Q30L60X80P001 |   80.0 |     89696 | 2.44M |  54 |       881 | 18.13K | 18 |   75.0 | 6.0 |  19.0 | 139.5 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'45'' |

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
| anchors                |  115947 | 2441291 |  43 |
| others                 |     896 |  125146 | 139 |
| anchorLong             |  125030 | 2440600 |  33 |
| anchorFill             |  420817 | 2385598 |   7 |
| canu_X80-trim          | 2502151 | 2502151 |   1 |
| canu_Xall-trim         | 2505675 | 2505675 |   1 |
| spades.contig          |  309919 | 2537469 | 293 |
| spades.scaffold        |  309919 | 2537479 | 292 |
| spades.non-contained   |  309919 | 2457577 |  23 |
| platanus.contig        |   97950 | 2468689 | 184 |
| platanus.scaffold      |  177069 | 2463911 | 122 |
| platanus.non-contained |  177069 | 2446243 |  23 |


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
| sample    |     101 | 567.83M |  5622104 |
| Q25L60    |     101 | 537.49M |  5347212 |
| Q30L60    |     101 | 523.45M |  5262273 |
| PacBio    |   10022 |   1.16G |   151564 |
| X80.raw   |   10012 | 151.42M |    19828 |
| X80.trim  |    9130 | 133.37M |    17725 |
| Xall.raw  |   10022 |   1.16G |   151564 |
| Xall.trim |    9626 |   1.07G |   137266 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 284.0 |  271.6 |   4.347% |     100 | "71" | 1.89M | 1.81M |     0.95 | 0:01'10'' |
| Q30L60 | 276.6 |  266.9 |   3.535% |      99 | "71" | 1.89M |  1.8M |     0.95 | 0:01'06'' |

| Name          | CovCor | N50Anchor |   Sum |  # | N50Others |    Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|------:|---:|----------:|-------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |     32813 | 1.76M | 71 |      8457 | 51.02K | 25 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'37'' |
| Q25L60X40P001 |   40.0 |     32741 | 1.76M | 72 |     27554 | 41.97K | 12 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'38'' |
| Q25L60X40P002 |   40.0 |     32751 | 1.76M | 74 |      8386 | 50.25K | 24 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'36'' |
| Q25L60X40P003 |   40.0 |     32813 | 1.76M | 73 |     27554 | 42.25K | 13 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'35'' |
| Q25L60X40P004 |   40.0 |     32813 | 1.76M | 72 |     27554 | 40.44K | 11 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'36'' |
| Q25L60X40P005 |   40.0 |     32813 | 1.76M | 72 |     27554 |  40.4K | 10 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'35'' |
| Q25L60X80P000 |   80.0 |     32404 | 1.76M | 75 |     19177 | 37.36K |  8 |   80.0 | 1.0 |  25.7 | 124.5 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'33'' |
| Q25L60X80P001 |   80.0 |     31667 | 1.76M | 79 |     19248 | 37.97K |  9 |   80.0 | 1.0 |  25.7 | 124.5 | "31,41,51,61,71,81" | 0:00'30'' | 0:00'35'' |
| Q25L60X80P002 |   80.0 |     32751 | 1.76M | 77 |     27554 | 37.49K |  6 |   79.5 | 1.5 |  25.0 | 126.0 | "31,41,51,61,71,81" | 0:00'30'' | 0:00'35'' |
| Q30L60X40P000 |   40.0 |     32813 | 1.76M | 71 |      8457 |  52.3K | 26 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'37'' |
| Q30L60X40P001 |   40.0 |     32751 | 1.76M | 70 |     27554 | 41.38K | 12 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'38'' |
| Q30L60X40P002 |   40.0 |     32813 | 1.76M | 70 |     27554 | 45.88K | 17 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'39'' |
| Q30L60X40P003 |   40.0 |     32751 | 1.76M | 73 |     27554 | 40.68K | 11 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'36'' |
| Q30L60X40P004 |   40.0 |     32813 | 1.76M | 72 |     27554 |  44.5K | 16 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'38'' |
| Q30L60X40P005 |   40.0 |     32813 | 1.76M | 72 |     10425 | 43.88K | 16 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'37'' |
| Q30L60X80P000 |   80.0 |     32404 | 1.76M | 76 |     19177 | 35.65K |  6 |   80.0 | 1.0 |  25.7 | 124.5 | "31,41,51,61,71,81" | 0:00'32'' | 0:00'33'' |
| Q30L60X80P001 |   80.0 |     32813 | 1.76M | 72 |     19248 | 35.22K |  5 |   80.0 | 1.0 |  25.7 | 124.5 | "31,41,51,61,71,81" | 0:00'30'' | 0:00'35'' |
| Q30L60X80P002 |   80.0 |     32751 | 1.76M | 74 |     10425 | 35.65K |  6 |   80.0 | 1.0 |  25.7 | 124.5 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'33'' |

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
| Genome                 | 1892775 | 1892775 |   1 |
| Paralogs               |   33912 |   93531 |  10 |
| anchors                |   32813 | 1764208 |  69 |
| others                 |    1006 |   99143 |  80 |
| anchorLong             |   36720 | 1763301 |  67 |
| anchorFill             | 1398728 | 1818343 |   3 |
| canu_X80-trim          | 1884029 | 1884029 |   1 |
| canu_Xall-trim         | 1579468 | 1978055 |   3 |
| spades.contig          |   37811 | 1808720 |  82 |
| spades.scaffold        |   37811 | 1808740 |  80 |
| spades.non-contained   |   37811 | 1804957 |  67 |
| platanus.contig        |   35266 | 1808488 | 123 |
| platanus.scaffold      |   37806 | 1805198 |  97 |
| platanus.non-contained |   37806 | 1798589 |  65 |


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
    --cov2 "40 80 all" \
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

| Name      |     N50 |     Sum |       # |
|:----------|--------:|--------:|--------:|
| Genome    | 4607202 | 4828820 |       2 |
| Paralogs  |    1377 |  543111 |     334 |
| Illumina  |     150 | 346.45M | 2309646 |
| uniq      |     150 | 346.18M | 2307844 |
| shuffle   |     150 | 346.18M | 2307844 |
| Q25L60    |     150 | 318.54M | 2148046 |
| Q30L60    |     150 | 313.92M | 2131978 |
| PacBio    |    3333 | 432.57M |  170957 |
| Xall.raw  |    3333 | 432.57M |  170957 |
| Xall.trim |    2882 | 257.76M |   95845 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 |  66.0 |   62.4 |   5.359% |     148 | "75" | 4.83M | 4.19M |     0.87 | 0:00'41'' |
| Q30L60 |  65.0 |   62.3 |   4.213% |     147 | "75" | 4.83M | 4.19M |     0.87 | 0:00'40'' |

| Name           | CovCor | N50Anchor |   Sum |   # | N50Others |    Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|----------:|------:|----:|----------:|-------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |     19469 | 4.07M | 354 |       866 | 68.92K | 81 |   39.0 | 5.0 |   8.0 |  78.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'45'' |
| Q25L60XallP000 |   62.4 |     18704 | 4.07M | 370 |       863 |  76.7K | 91 |   61.0 | 7.0 |  13.3 | 122.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'46'' |
| Q30L60X40P000  |   40.0 |     28565 | 4.05M | 274 |       854 | 63.07K | 76 |   39.0 | 5.0 |   8.0 |  78.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'47'' |
| Q30L60XallP000 |   62.3 |     28526 | 4.06M | 274 |       854 | 62.94K | 76 |   61.0 | 7.0 |  13.3 | 122.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'47'' |

| Name                |     N50 |     Sum |     # |
|:--------------------|--------:|--------:|------:|
| Genome              | 4607202 | 4828820 |     2 |
| Paralogs            |    1377 |  543111 |   334 |
| Xall.trim.corrected |    2849 | 178.54M | 62704 |
| Xall.trim.contig    |  461950 | 4542043 |    22 |

| Name                   |     N50 |     Sum |    # |
|:-----------------------|--------:|--------:|-----:|
| Genome                 | 4607202 | 4828820 |    2 |
| Paralogs               |    1377 |  543111 |  334 |
| anchors                |   28831 | 4089757 |  278 |
| others                 |     866 |   82240 |   94 |
| anchorLong             |   29384 | 4062956 |  248 |
| anchorFill             |  285176 | 4325565 |   29 |
| canu_Xall-trim         |  461950 | 4542043 |   22 |
| spades.contig          |   33440 | 4260570 |  560 |
| spades.scaffold        |   34624 | 4260820 |  553 |
| spades.non-contained   |   33691 | 4180045 |  248 |
| platanus.contig        |   28552 | 4348392 | 1323 |
| platanus.scaffold      |   35092 | 4324965 | 1079 |
| platanus.non-contained |   35257 | 4171060 |  222 |


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

| Name      |     N50 |     Sum |        # |
|:----------|--------:|--------:|---------:|
| Genome    | 1830138 | 1830138 |        1 |
| Paralogs  |    5432 |   95358 |       29 |
| Illumina  |     101 |   1.24G | 12231248 |
| uniq      |     101 |   1.23G | 12143990 |
| sample    |     101 | 549.04M |  5436052 |
| Q25L60    |     101 | 504.18M |  5041502 |
| Q30L60    |     101 | 478.93M |  4883199 |
| PacBio    |   11870 | 407.42M |   163475 |
| X80.raw   |   11062 | 146.42M |    62532 |
| X80.trim  |   12100 |   70.3M |     7562 |
| Xall.raw  |   11870 | 407.42M |   163475 |
| Xall.trim |   15209 |  241.8M |    22124 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG | EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|-----:|---------:|----------:|
| Q25L60 | 275.5 |  262.1 |   4.875% |     100 | "71" | 1.83M | 1.8M |     0.98 | 0:01'03'' |
| Q30L60 | 261.8 |  252.0 |   3.737% |      98 | "71" | 1.83M | 1.8M |     0.98 | 0:01'01'' |

| Name          | CovCor | N50Anchor |   Sum |  # | N50Others |    Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|------:|---:|----------:|-------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |     55173 | 1.77M | 60 |      1019 | 25.67K | 22 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'36'' |
| Q25L60X40P001 |   40.0 |     58229 | 1.77M | 56 |       959 | 26.08K | 24 |   40.0 | 3.5 |   9.8 |  75.8 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'35'' |
| Q25L60X40P002 |   40.0 |     54061 | 1.77M | 64 |       941 | 26.49K | 25 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'36'' |
| Q25L60X40P003 |   40.0 |     53208 | 1.77M | 63 |      1012 | 25.06K | 22 |   40.0 | 3.5 |   9.8 |  75.8 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'37'' |
| Q25L60X40P004 |   40.0 |     54104 | 1.78M | 69 |      1028 | 19.77K | 17 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'36'' |
| Q25L60X40P005 |   40.0 |     55173 | 1.77M | 59 |       839 | 19.93K | 24 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'35'' |
| Q25L60X80P000 |   80.0 |     47320 | 1.77M | 70 |       937 | 12.37K | 14 |   81.0 | 7.0 |  20.0 | 153.0 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'34'' |
| Q25L60X80P001 |   80.0 |     40492 | 1.77M | 76 |      1634 | 17.58K | 15 |   81.0 | 6.0 |  21.0 | 148.5 | "31,41,51,61,71,81" | 0:00'30'' | 0:00'33'' |
| Q25L60X80P002 |   80.0 |     53274 | 1.77M | 72 |       795 | 15.62K | 20 |   81.5 | 6.5 |  20.7 | 151.5 | "31,41,51,61,71,81" | 0:00'30'' | 0:00'34'' |
| Q30L60X40P000 |   40.0 |     55173 | 1.77M | 57 |       965 | 26.45K | 28 |   40.0 | 4.0 |   9.3 |  78.0 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'39'' |
| Q30L60X40P001 |   40.0 |     58219 | 1.77M | 56 |       981 | 24.74K | 21 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'19'' | 0:00'37'' |
| Q30L60X40P002 |   40.0 |     58229 | 1.77M | 51 |       915 | 30.56K | 29 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'36'' |
| Q30L60X40P003 |   40.0 |     60193 | 1.77M | 49 |      1634 | 20.89K | 17 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'38'' |
| Q30L60X40P004 |   40.0 |     57131 | 1.77M | 53 |      1026 | 25.03K | 21 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'19'' | 0:00'37'' |
| Q30L60X40P005 |   40.0 |     58219 | 1.77M | 50 |      1022 | 24.14K | 21 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'38'' |
| Q30L60X80P000 |   80.0 |     57141 | 1.77M | 58 |       851 | 12.31K | 12 |   81.0 | 6.0 |  21.0 | 148.5 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'36'' |
| Q30L60X80P001 |   80.0 |     58229 | 1.77M | 53 |       856 | 13.79K | 14 |   82.0 | 6.0 |  21.3 | 150.0 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'36'' |
| Q30L60X80P002 |   80.0 |     55173 | 1.77M | 55 |       864 | 13.88K | 14 |   80.0 | 6.0 |  20.7 | 147.0 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'34'' |

| Name                |     N50 |     Sum |    # |
|:--------------------|--------:|--------:|-----:|
| Genome              | 1830138 | 1830138 |    1 |
| Paralogs            |    5432 |   95358 |   29 |
| X80.trim.corrected  |   11133 |   58.8M | 6431 |
| Xall.trim.corrected |   23701 |  60.34M | 3215 |
| X80.trim.contig     | 1838071 | 1851226 |    2 |
| Xall.trim.contig    | 1846774 | 1846774 |    1 |

| Name                   |     N50 |     Sum |   # |
|:-----------------------|--------:|--------:|----:|
| Genome                 | 1830138 | 1830138 |   1 |
| Paralogs               |    5432 |   95358 |  29 |
| anchors                |   68766 | 1776082 |  49 |
| others                 |     907 |   72246 |  79 |
| anchorLong             |   79242 | 1771470 |  38 |
| anchorFill             |  376408 | 1785353 |   9 |
| canu_X80-trim          | 1838071 | 1851226 |   2 |
| canu_Xall-trim         | 1846774 | 1846774 |   1 |
| spades.contig          |  131566 | 1846087 | 202 |
| spades.scaffold        |  131568 | 1846237 | 196 |
| spades.non-contained   |  131566 | 1797398 |  28 |
| platanus.contig        |  107685 | 1806861 | 139 |
| platanus.scaffold      |  161483 | 1799615 |  73 |
| platanus.non-contained |  161483 | 1791400 |  18 |


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

| Name     |     N50 |     Sum |        # |
|:---------|--------:|--------:|---------:|
| Genome   | 2944528 | 2944528 |        1 |
| Paralogs |    5116 |   68585 |       22 |
| Illumina |     151 |   2.59G | 17153480 |
| uniq     |     151 |   2.46G | 16310518 |
| sample   |     151 | 883.36M |  5850056 |
| Q25L60   |     151 | 685.63M |  4900096 |
| Q30L60   |     151 | 663.59M |  4918968 |

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q25L60 | 232.8 |  185.2 |  20.447% |     143 | "105" | 2.94M |  6.5M |     2.21 | 0:01'20'' |
| Q30L60 | 225.6 |  193.3 |  14.306% |     139 |  "91" | 2.94M | 6.36M |     2.16 | 0:01'16'' |

| Name          | CovCor | N50Anchor |     Sum |   # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|--------:|----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |     19553 |   2.93M | 248 |       657 | 104.64K |  154 |   34.0 |  9.0 |   2.3 |  68.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'36'' |
| Q25L60X40P001 |   40.0 |     20067 |   2.93M | 231 |       627 |  89.71K |  131 |   34.0 |  9.0 |   2.3 |  68.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'35'' |
| Q25L60X40P002 |   40.0 |     18317 |   2.93M | 265 |       657 |  81.44K |  117 |   34.0 |  7.0 |   4.3 |  68.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'37'' |
| Q25L60X40P003 |   40.0 |     17067 |   2.93M | 276 |       606 |  83.38K |  126 |   34.0 |  8.0 |   3.3 |  68.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'36'' |
| Q25L60X80P000 |   80.0 |      1191 |   93.4K |  74 |      5169 |   3.53M | 1511 |    5.0 |  3.0 |   2.0 |  10.0 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'37'' |
| Q25L60X80P001 |   80.0 |      1181 |  66.22K |  54 |      5360 |   3.56M | 1550 |    5.0 |  3.0 |   2.0 |  10.0 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'37'' |
| Q30L60X40P000 |   40.0 |      3405 |  91.97K |  35 |     30918 |   1.57M |  184 |   18.5 | 16.5 |   2.0 |  37.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'36'' |
| Q30L60X40P001 |   40.0 |    111213 | 443.92K |  58 |     39801 | 866.58K |  155 |   21.0 | 18.0 |   2.0 |  42.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'36'' |
| Q30L60X40P002 |   40.0 |     59920 |   1.39M |  89 |      8817 | 210.67K |  139 |   24.5 | 20.5 |   2.0 |  49.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'37'' |
| Q30L60X40P003 |   40.0 |     42512 |   2.72M | 126 |       631 |  66.96K |  101 |   30.0 | 14.0 |   2.0 |  60.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'37'' |
| Q30L60X80P000 |   80.0 |      1214 |  63.52K |  50 |     15764 |   3.54M | 1061 |    4.0 |  1.0 |   2.0 |   8.0 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'37'' |
| Q30L60X80P001 |   80.0 |      1158 |  57.16K |  48 |     14562 |   3.55M | 1078 |    4.0 |  1.0 |   2.0 |   8.0 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'36'' |

| Name                   |     N50 |     Sum |    # |
|:-----------------------|--------:|--------:|-----:|
| Genome                 | 2944528 | 2944528 |    1 |
| Paralogs               |    5116 |   68585 |   22 |
| anchors                |  254532 | 3213380 |  222 |
| others                 |   21972 | 6172048 | 2510 |
| anchorLong             |       0 |       0 |    0 |
| anchorFill             |       0 |       0 |    0 |
| spades.contig          |   10941 | 9583767 | 9983 |
| spades.scaffold        |   10941 | 9583947 | 9974 |
| spades.non-contained   |   86840 | 5950635 |  631 |
| platanus.contig        |  369702 | 2966097 |   92 |
| platanus.scaffold      |  557592 | 2957060 |   32 |
| platanus.non-contained |  557592 | 2952879 |   14 |


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

cp ~/data/anchr/paralogs/otherbac/Results/Cdif/Cdif.multi.fas paralogs.fas

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
| Paralogs |    3242 |  328828 |      121 |
| Illumina |     101 |   1.33G | 13190786 |
| uniq     |     101 |   1.32G | 13029692 |
| sample   |     101 |   1.29G | 12766730 |
| Q25L60   |     101 |   1.18G | 11792532 |
| Q30L60   |     101 |   1.16G | 11682317 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 275.1 |  258.7 |   5.967% |     100 | "71" |  4.3M | 4.21M |     0.98 | 0:02'14'' |
| Q30L60 | 269.7 |  257.2 |   4.625% |      99 | "71" |  4.3M |  4.2M |     0.98 | 0:02'07'' |

| Name          | CovCor | N50Anchor |   Sum |   # | N50Others |    Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|------:|----:|----------:|-------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |     85723 | 4.15M | 122 |      7659 | 48.02K | 33 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'57'' |
| Q25L60X40P001 |   40.0 |     70800 | 4.15M | 114 |      3688 | 47.83K | 33 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'57'' |
| Q25L60X40P002 |   40.0 |     78965 | 4.15M | 113 |      7155 | 49.47K | 35 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'56'' |
| Q25L60X40P003 |   40.0 |     85294 | 4.15M | 121 |      1215 | 54.57K | 45 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'55'' |
| Q25L60X40P004 |   40.0 |     88806 | 4.15M | 114 |      1367 | 52.27K | 39 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'55'' |
| Q25L60X40P005 |   40.0 |     85713 | 4.15M | 116 |      1052 | 59.55K | 48 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'58'' |
| Q25L60X80P000 |   80.0 |     70800 | 4.15M | 126 |      7659 |  38.5K | 20 |   79.0 | 7.0 |  19.3 | 150.0 | "31,41,51,61,71,81" | 0:01'04'' | 0:00'54'' |
| Q25L60X80P001 |   80.0 |     78965 | 4.15M | 132 |      4376 | 40.98K | 26 |   79.0 | 8.0 |  18.3 | 154.5 | "31,41,51,61,71,81" | 0:01'05'' | 0:00'51'' |
| Q25L60X80P002 |   80.0 |     59990 | 4.15M | 140 |      5108 | 43.96K | 26 |   79.0 | 7.0 |  19.3 | 150.0 | "31,41,51,61,71,81" | 0:01'05'' | 0:00'50'' |
| Q30L60X40P000 |   40.0 |     85723 | 4.15M | 117 |      1058 | 57.26K | 44 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'58'' |
| Q30L60X40P001 |   40.0 |     79402 | 4.16M | 122 |      1033 | 60.49K | 48 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'55'' |
| Q30L60X40P002 |   40.0 |    104088 | 4.14M | 109 |      1051 | 60.51K | 47 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'57'' |
| Q30L60X40P003 |   40.0 |    104539 | 4.15M | 118 |      1053 | 57.88K | 46 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'55'' |
| Q30L60X40P004 |   40.0 |     88806 | 4.15M | 113 |      1102 | 58.25K | 44 |   39.0 | 4.0 |   9.0 |  76.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:01'01'' |
| Q30L60X40P005 |   40.0 |     85723 | 4.15M | 111 |      1031 | 62.25K | 54 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'57'' |
| Q30L60X80P000 |   80.0 |     85314 | 4.15M | 111 |      7659 | 39.16K | 21 |   79.0 | 7.0 |  19.3 | 150.0 | "31,41,51,61,71,81" | 0:01'04'' | 0:00'53'' |
| Q30L60X80P001 |   80.0 |     85314 | 4.15M | 120 |      7659 | 41.22K | 24 |   78.0 | 8.0 |  18.0 | 153.0 | "31,41,51,61,71,81" | 0:01'04'' | 0:00'55'' |
| Q30L60X80P002 |   80.0 |     85314 | 4.15M | 121 |      2793 | 40.08K | 26 |   79.0 | 8.0 |  18.3 | 154.5 | "31,41,51,61,71,81" | 0:01'05'' | 0:00'53'' |

| Name                   |     N50 |     Sum |   # |
|:-----------------------|--------:|--------:|----:|
| Genome                 | 4290252 | 4298133 |   2 |
| Paralogs               |    3242 |  328828 | 121 |
| anchors                |  108261 | 4146604 |  90 |
| others                 |     989 |  194739 | 167 |
| anchorLong             |       0 |       0 |   0 |
| anchorFill             |       0 |       0 |   0 |
| spades.contig          |  225813 | 4246199 | 266 |
| spades.scaffold        |  227405 | 4246239 | 262 |
| spades.non-contained   |  225813 | 4201223 |  51 |
| platanus.contig        |  108275 | 4272304 | 645 |
| platanus.scaffold      |  225732 | 4238787 | 415 |
| platanus.non-contained |  225732 | 4184100 |  48 |


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

cp ~/data/anchr/paralogs/otherbac/Results/Cjej/Cjej.multi.fas paralogs.fas

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
| sample   |     101 | 492.44M |  4875686 |
| Q25L60   |     101 | 461.31M |  4595440 |
| Q30L60   |     101 | 444.88M |  4485825 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 281.0 |  266.4 |   5.211% |     100 | "71" | 1.64M | 1.63M |     0.99 | 0:01'03'' |
| Q30L60 | 271.1 |  259.6 |   4.245% |      99 | "71" | 1.64M | 1.62M |     0.99 | 0:00'53'' |

| Name          | CovCor | N50Anchor |  Sum |  # | N50Others |    Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|-----:|---:|----------:|-------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |     80807 | 1.6M | 44 |       974 | 18.32K | 15 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'35'' |
| Q25L60X40P001 |   40.0 |     60104 | 1.6M | 47 |       949 | 22.88K | 21 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'34'' |
| Q25L60X40P002 |   40.0 |     79976 | 1.6M | 44 |       817 | 21.19K | 21 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'34'' |
| Q25L60X40P003 |   40.0 |     71607 | 1.6M | 46 |       925 |  21.3K | 19 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'34'' |
| Q25L60X40P004 |   40.0 |     66155 | 1.6M | 53 |      1009 | 18.33K | 16 |   38.0 | 3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'35'' |
| Q25L60X40P005 |   40.0 |     80777 | 1.6M | 44 |       779 | 17.99K | 17 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'35'' |
| Q25L60X80P000 |   80.0 |     61000 | 1.6M | 54 |      1515 | 17.41K | 15 |   78.5 | 5.5 |  20.7 | 142.5 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'33'' |
| Q25L60X80P001 |   80.0 |     66731 | 1.6M | 54 |       963 | 16.57K | 14 |   77.0 | 4.0 |  21.7 | 133.5 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'33'' |
| Q25L60X80P002 |   80.0 |     66155 | 1.6M | 60 |       763 | 17.07K | 16 |   77.0 | 5.0 |  20.7 | 138.0 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'33'' |
| Q30L60X40P000 |   40.0 |     76635 | 1.6M | 41 |       844 | 20.74K | 19 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'38'' |
| Q30L60X40P001 |   40.0 |     66861 | 1.6M | 45 |      2340 | 16.79K | 13 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'34'' |
| Q30L60X40P002 |   40.0 |     70694 | 1.6M | 44 |       773 | 17.23K | 15 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'19'' | 0:00'35'' |
| Q30L60X40P003 |   40.0 |     71670 | 1.6M | 45 |       894 | 19.94K | 18 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'35'' |
| Q30L60X40P004 |   40.0 |     79250 | 1.6M | 44 |       807 | 19.75K | 18 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'35'' |
| Q30L60X40P005 |   40.0 |     66891 | 1.6M | 44 |       830 | 21.06K | 19 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'35'' |
| Q30L60X80P000 |   80.0 |     76635 | 1.6M | 44 |      2340 |  15.3K | 12 |   78.0 | 4.0 |  22.0 | 135.0 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'33'' |
| Q30L60X80P001 |   80.0 |     70613 | 1.6M | 47 |       831 | 17.58K | 15 |   75.0 | 3.5 |  21.5 | 128.2 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'32'' |
| Q30L60X80P002 |   80.0 |     70613 | 1.6M | 48 |       812 | 16.86K | 14 |   77.0 | 4.0 |  21.7 | 133.5 | "31,41,51,61,71,81" | 0:00'29'' | 0:00'31'' |

| Name                   |     N50 |     Sum |   # |
|:-----------------------|--------:|--------:|----:|
| Genome                 | 1641481 | 1641481 |   1 |
| Paralogs               |    6093 |   33281 |  13 |
| anchors                |   90287 | 1606652 |  33 |
| others                 |     807 |   50548 |  58 |
| anchorLong             |       0 |       0 |   0 |
| anchorFill             |       0 |       0 |   0 |
| spades.contig          |  153957 | 1629803 |  39 |
| spades.scaffold        |  189386 | 1629823 |  37 |
| spades.non-contained   |  153957 | 1622173 |  18 |
| platanus.contig        |  112550 | 1629907 | 124 |
| platanus.scaffold      |  153893 | 1622339 |  71 |
| platanus.non-contained |  153893 | 1612675 |  23 |


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

#cp ~/data/anchr/paralogs/otherbac/Results/lambda/lambda.multi.fas paralogs.fas
touch paralogs.fas

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
    --trim2 "--uniq " \
    --sample 300 \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --cov3 "80 all" \
    --qual3 "trim" \
    --parallel 16

# run
bash 0_master.sh

bash 0_cleanup.sh

```

| Name      |   N50 |    Sum |        # |
|:----------|------:|-------:|---------:|
| Genome    | 48502 |  48502 |        1 |
| Paralogs  |     0 |      0 |        0 |
| Illumina  |   108 |  3.57G | 33080474 |
| uniq      |   108 |  2.98G | 27609894 |
| sample    |   108 | 14.55M |   134728 |
| Q25L60    |   108 | 12.06M |   115550 |
| Q30L60    |   108 | 11.41M |   113678 |
| PacBio    |  1325 | 11.95M |     9796 |
| X80.raw   |  1361 |  3.88M |     3084 |
| X80.trim  |  1453 |  3.06M |     2133 |
| Xall.raw  |  1325 | 11.95M |     9796 |
| Xall.trim |  1427 |  9.23M |     6538 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|-------:|---------:|----------:|
| Q25L60 | 248.7 |  233.8 |   6.012% |     104 | "75" | 48.5K | 48.52K |     1.00 | 0:00'12'' |
| Q30L60 | 235.5 |  224.4 |   4.705% |     101 | "75" | 48.5K | 48.52K |     1.00 | 0:00'08'' |

| Name          | CovCor | N50Anchor |    Sum | # | N50Others | Sum | # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|-------:|--:|----------:|----:|--:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |     48408 | 48.41K | 1 |         0 |   0 | 0 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'04'' | 0:00'17'' |
| Q25L60X40P001 |   40.0 |     48514 | 48.51K | 1 |         0 |   0 | 0 |   39.0 | 0.0 |  13.0 |  58.5 | "31,41,51,61,71,81" | 0:00'04'' | 0:00'18'' |
| Q25L60X40P002 |   40.0 |     40723 | 48.46K | 2 |         0 |   0 | 0 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'03'' | 0:00'17'' |
| Q25L60X40P003 |   40.0 |     48471 | 48.47K | 1 |         0 |   0 | 0 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'04'' | 0:00'17'' |
| Q25L60X40P004 |   40.0 |     48274 | 48.27K | 1 |         0 |   0 | 0 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'04'' | 0:00'17'' |
| Q25L60X80P000 |   80.0 |     48514 | 48.51K | 1 |         0 |   0 | 0 |   79.0 | 0.0 |  26.3 | 118.5 | "31,41,51,61,71,81" | 0:00'05'' | 0:00'17'' |
| Q25L60X80P001 |   80.0 |     40733 | 48.59K | 2 |         0 |   0 | 0 |   81.0 | 0.0 |  27.0 | 121.5 | "31,41,51,61,71,81" | 0:00'05'' | 0:00'17'' |
| Q30L60X40P000 |   40.0 |     48302 |  48.3K | 1 |         0 |   0 | 0 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'04'' | 0:00'16'' |
| Q30L60X40P001 |   40.0 |     10528 | 10.53K | 1 |         0 |   0 | 0 |   39.0 | 0.0 |  13.0 |  58.5 | "31,41,51,61,71,81" | 0:00'04'' | 0:00'16'' |
| Q30L60X40P002 |   40.0 |     48368 | 48.37K | 1 |         0 |   0 | 0 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'04'' | 0:00'17'' |
| Q30L60X40P003 |   40.0 |     48511 | 48.51K | 1 |         0 |   0 | 0 |   39.0 | 0.0 |  13.0 |  58.5 | "31,41,51,61,71,81" | 0:00'04'' | 0:00'17'' |
| Q30L60X40P004 |   40.0 |     48271 | 48.27K | 1 |         0 |   0 | 0 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'04'' | 0:00'16'' |
| Q30L60X80P000 |   80.0 |     48514 | 48.51K | 1 |         0 |   0 | 0 |   79.0 | 0.0 |  26.3 | 118.5 | "31,41,51,61,71,81" | 0:00'04'' | 0:00'17'' |
| Q30L60X80P001 |   80.0 |     48514 | 48.51K | 1 |         0 |   0 | 0 |   79.0 | 0.0 |  26.3 | 118.5 | "31,41,51,61,71,81" | 0:00'04'' | 0:00'17'' |

| Name                |   N50 |   Sum |    # |
|:--------------------|------:|------:|-----:|
| Genome              | 48502 | 48502 |    1 |
| Paralogs            |     0 |     0 |    0 |
| X80.trim.corrected  |  1624 | 1.94M | 1175 |
| Xall.trim.corrected |  1950 | 1.94M |  984 |
| X80.trim.contig     | 48489 | 48489 |    1 |
| Xall.trim.contig    | 50623 | 50623 |    1 |

| Name                   |   N50 |   Sum | # |
|:-----------------------|------:|------:|--:|
| Genome                 | 48502 | 48502 | 1 |
| Paralogs               |     0 |     0 | 0 |
| anchors                | 48514 | 48514 | 1 |
| others                 |     0 |     0 | 0 |
| anchorLong             | 48514 | 48514 | 1 |
| anchorFill             | 48514 | 48514 | 1 |
| canu_X80-trim          | 48489 | 48489 | 1 |
| canu_Xall-trim         | 50623 | 50623 | 1 |
| spades.contig          | 48516 | 48516 | 1 |
| spades.scaffold        | 48516 | 48516 | 1 |
| spades.non-contained   | 48516 | 48516 | 1 |
| platanus.contig        | 46383 | 48498 | 2 |
| platanus.scaffold      | 48438 | 48438 | 1 |
| platanus.non-contained | 48438 | 48438 | 1 |
