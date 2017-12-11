# Bacteria 2+3

[TOC levels=1-3]: # " "
- [Bacteria 2+3](#bacteria-23)
- [Vibrio parahaemolyticus ATCC BAA-239, 副溶血弧菌](#vibrio-parahaemolyticus-atcc-baa-239-副溶血弧菌)
    - [Vpar: download](#vpar-download)
    - [Vpar: preprocess Illumina reads](#vpar-preprocess-illumina-reads)
    - [Vpar: preprocess PacBio reads](#vpar-preprocess-pacbio-reads)
    - [Vpar: reads stats](#vpar-reads-stats)
    - [Vpar: spades](#vpar-spades)
    - [Vpar: platanus](#vpar-platanus)
    - [Vpar: quorum](#vpar-quorum)
    - [Vpar: adapter filtering](#vpar-adapter-filtering)
    - [Vpar: down sampling](#vpar-down-sampling)
    - [Vpar: k-unitigs and anchors (sampled)](#vpar-k-unitigs-and-anchors-sampled)
    - [Vpar: merge anchors](#vpar-merge-anchors)
    - [Vpar: 3GS](#vpar-3gs)
    - [Vpar: expand anchors](#vpar-expand-anchors)
    - [Vpar: final stats](#vpar-final-stats)
    - [Vpar: clear intermediate files](#vpar-clear-intermediate-files)
- [Legionella pneumophila subsp. pneumophila ATCC 33152D-5; Philadelphia-1, 嗜肺军团菌](#legionella-pneumophila-subsp-pneumophila-atcc-33152d-5-philadelphia-1-嗜肺军团菌)
    - [Lpne: download](#lpne-download)
    - [Lpne: preprocess Illumina reads](#lpne-preprocess-illumina-reads)
    - [Lpne: preprocess PacBio reads](#lpne-preprocess-pacbio-reads)
    - [Lpne: reads stats](#lpne-reads-stats)
    - [Lpne: spades](#lpne-spades)
    - [Lpne: platanus](#lpne-platanus)
    - [Lpne: quorum](#lpne-quorum)
    - [Lpne: down sampling](#lpne-down-sampling)
    - [Lpne: k-unitigs and anchors (sampled)](#lpne-k-unitigs-and-anchors-sampled)
    - [Lpne: merge anchors](#lpne-merge-anchors)
    - [Lpne: 3GS](#lpne-3gs)
    - [Lpne: expand anchors](#lpne-expand-anchors)
    - [Lpne: final stats](#lpne-final-stats)
    - [Lpne: clear intermediate files](#lpne-clear-intermediate-files)
- [Neisseria gonorrhoeae FDAARGOS_207, 淋病奈瑟氏菌](#neisseria-gonorrhoeae-fdaargos-207-淋病奈瑟氏菌)
    - [Ngon: download](#ngon-download)
    - [Ngon: preprocess Illumina reads](#ngon-preprocess-illumina-reads)
    - [Ngon: preprocess PacBio reads](#ngon-preprocess-pacbio-reads)
    - [Ngon: reads stats](#ngon-reads-stats)
    - [Ngon: spades](#ngon-spades)
    - [Ngon: platanus](#ngon-platanus)
    - [Ngon: quorum](#ngon-quorum)
    - [Ngon: adapter filtering](#ngon-adapter-filtering)
    - [Ngon: down sampling](#ngon-down-sampling)
    - [Ngon: k-unitigs and anchors (sampled)](#ngon-k-unitigs-and-anchors-sampled)
    - [Ngon: merge anchors](#ngon-merge-anchors)
    - [Ngon: 3GS](#ngon-3gs)
    - [Ngon: expand anchors](#ngon-expand-anchors)
    - [Ngon: final stats](#ngon-final-stats)
    - [Ngon: clear intermediate files](#ngon-clear-intermediate-files)
- [Neisseria meningitidis FDAARGOS_209, 脑膜炎奈瑟氏菌](#neisseria-meningitidis-fdaargos-209-脑膜炎奈瑟氏菌)
    - [Nmen: download](#nmen-download)
    - [Nmen: preprocess Illumina reads](#nmen-preprocess-illumina-reads)
    - [Nmen: preprocess PacBio reads](#nmen-preprocess-pacbio-reads)
    - [Nmen: reads stats](#nmen-reads-stats)
    - [Nmen: spades](#nmen-spades)
    - [Nmen: platanus](#nmen-platanus)
    - [Nmen: quorum](#nmen-quorum)
    - [Nmen: adapter filtering](#nmen-adapter-filtering)
    - [Nmen: down sampling](#nmen-down-sampling)
    - [Nmen: k-unitigs and anchors (sampled)](#nmen-k-unitigs-and-anchors-sampled)
    - [Nmen: merge anchors](#nmen-merge-anchors)
    - [Nmen: 3GS](#nmen-3gs)
    - [Nmen: expand anchors](#nmen-expand-anchors)
    - [Nmen: final stats](#nmen-final-stats)
    - [Nmen: clear intermediate files](#nmen-clear-intermediate-files)
- [Bordetella pertussis FDAARGOS_195, 百日咳博德特氏杆菌](#bordetella-pertussis-fdaargos-195-百日咳博德特氏杆菌)
    - [Bper: download](#bper-download)
    - [Bper: preprocess Illumina reads](#bper-preprocess-illumina-reads)
    - [Bper: reads stats](#bper-reads-stats)
    - [Bper: quorum](#bper-quorum)
    - [Bper: adapter filtering](#bper-adapter-filtering)
    - [Bper: down sampling](#bper-down-sampling)
    - [Bper: k-unitigs and anchors (sampled)](#bper-k-unitigs-and-anchors-sampled)
    - [Bper: merge anchors](#bper-merge-anchors)
    - [Bper: final stats](#bper-final-stats)
    - [Bper: clear intermediate files](#bper-clear-intermediate-files)
- [Corynebacterium diphtheriae FDAARGOS_197, 白喉杆菌](#corynebacterium-diphtheriae-fdaargos-197-白喉杆菌)
    - [Cdip: download](#cdip-download)
    - [Cdip: preprocess Illumina reads](#cdip-preprocess-illumina-reads)
    - [Cdip: preprocess PacBio reads](#cdip-preprocess-pacbio-reads)
    - [Cdip: reads stats](#cdip-reads-stats)
    - [Cdip: spades](#cdip-spades)
    - [Cdip: platanus](#cdip-platanus)
    - [Cdip: quorum](#cdip-quorum)
    - [Cdip: adapter filtering](#cdip-adapter-filtering)
    - [Cdip: down sampling](#cdip-down-sampling)
    - [Cdip: k-unitigs and anchors (sampled)](#cdip-k-unitigs-and-anchors-sampled)
    - [Cdip: merge anchors](#cdip-merge-anchors)
    - [Cdip: 3GS](#cdip-3gs)
    - [Cdip: expand anchors](#cdip-expand-anchors)
    - [Cdip: final stats](#cdip-final-stats)
    - [Cdip: clear intermediate files](#cdip-clear-intermediate-files)
- [Francisella tularensis FDAARGOS_247, 土拉热弗朗西斯氏菌](#francisella-tularensis-fdaargos-247-土拉热弗朗西斯氏菌)
    - [Ftul: download](#ftul-download)
    - [Ftul: preprocess Illumina reads](#ftul-preprocess-illumina-reads)
    - [Ftul: preprocess PacBio reads](#ftul-preprocess-pacbio-reads)
    - [Ftul: reads stats](#ftul-reads-stats)
    - [Ftul: spades](#ftul-spades)
    - [Ftul: platanus](#ftul-platanus)
    - [Ftul: quorum](#ftul-quorum)
    - [Ftul: down sampling](#ftul-down-sampling)
    - [Ftul: k-unitigs and anchors (sampled)](#ftul-k-unitigs-and-anchors-sampled)
    - [Ftul: merge anchors](#ftul-merge-anchors)
    - [Ftul: 3GS](#ftul-3gs)
    - [Ftul: expand anchors](#ftul-expand-anchors)
    - [Ftul: final stats](#ftul-final-stats)
    - [Ftul: clear intermediate files](#ftul-clear-intermediate-files)
- [Shigella flexneri NCTC0001, 福氏志贺氏菌](#shigella-flexneri-nctc0001-福氏志贺氏菌)
    - [Sfle: download](#sfle-download)
    - [Sfle: combinations of different quality values and read lengths](#sfle-combinations-of-different-quality-values-and-read-lengths)
    - [Sfle: down sampling](#sfle-down-sampling)
    - [Sfle: generate super-reads](#sfle-generate-super-reads)
    - [Sfle: create anchors](#sfle-create-anchors)
    - [Sfle: results](#sfle-results)
    - [Sfle: merge anchors](#sfle-merge-anchors)
    - [Sfle: 3GS](#sfle-3gs)
    - [Sfle: expand anchors](#sfle-expand-anchors)
- [Haemophilus influenzae FDAARGOS_199, 流感嗜血杆菌](#haemophilus-influenzae-fdaargos-199-流感嗜血杆菌)
    - [Hinf: download](#hinf-download)
    - [Hinf: preprocess Illumina reads](#hinf-preprocess-illumina-reads)
    - [Hinf: preprocess PacBio reads](#hinf-preprocess-pacbio-reads)
    - [Hinf: reads stats](#hinf-reads-stats)
    - [Hinf: spades](#hinf-spades)
    - [Hinf: platanus](#hinf-platanus)
    - [Hinf: quorum](#hinf-quorum)
    - [Hinf: adapter filtering](#hinf-adapter-filtering)
    - [Hinf: down sampling](#hinf-down-sampling)
    - [Hinf: k-unitigs and anchors (sampled)](#hinf-k-unitigs-and-anchors-sampled)
    - [Hinf: merge anchors](#hinf-merge-anchors)
    - [Hinf: 3GS](#hinf-3gs)
    - [Hinf: expand anchors](#hinf-expand-anchors)
    - [Hinf: final stats](#hinf-final-stats)
    - [Hinf: clear intermediate files](#hinf-clear-intermediate-files)
- [Listeria monocytogenes FDAARGOS_351, 单核细胞增生李斯特氏菌](#listeria-monocytogenes-fdaargos-351-单核细胞增生李斯特氏菌)
    - [Lmon: download](#lmon-download)
    - [Lmon: preprocess Illumina reads](#lmon-preprocess-illumina-reads)
    - [Lmon: reads stats](#lmon-reads-stats)
    - [Lmon: spades](#lmon-spades)
    - [Lmon: platanus](#lmon-platanus)
    - [Lmon: quorum](#lmon-quorum)
    - [Lmon: adapter filtering](#lmon-adapter-filtering)
    - [Lmon: down sampling](#lmon-down-sampling)
    - [Lmon: k-unitigs and anchors (sampled)](#lmon-k-unitigs-and-anchors-sampled)
    - [Lmon: merge anchors](#lmon-merge-anchors)
    - [Lmon: final stats](#lmon-final-stats)
    - [Lmon: clear intermediate files](#lmon-clear-intermediate-files)
- [Clostridioides difficile 630](#clostridioides-difficile-630)
    - [Cdif: download](#cdif-download)
    - [Cdif: preprocess Illumina reads](#cdif-preprocess-illumina-reads)
    - [Cdif: reads stats](#cdif-reads-stats)
    - [Cdif: spades](#cdif-spades)
    - [Cdif: platanus](#cdif-platanus)
    - [Cdif: quorum](#cdif-quorum)
    - [Cdif: adapter filtering](#cdif-adapter-filtering)
    - [Cdif: down sampling](#cdif-down-sampling)
    - [Cdif: k-unitigs and anchors (sampled)](#cdif-k-unitigs-and-anchors-sampled)
    - [Cdif: merge anchors](#cdif-merge-anchors)
    - [Cdif: final stats](#cdif-final-stats)
    - [Cdif: clear intermediate files](#cdif-clear-intermediate-files)
- [Campylobacter jejuni subsp. jejuni ATCC 700819, 空肠弯曲杆菌](#campylobacter-jejuni-subsp-jejuni-atcc-700819-空肠弯曲杆菌)
    - [Cjej: download](#cjej-download)
- [Escherichia virus Lambda](#escherichia-virus-lambda)
    - [lambda: download](#lambda-download)
    - [lambda: preprocess PacBio reads](#lambda-preprocess-pacbio-reads)
    - [lambda: reads stats](#lambda-reads-stats)
    - [lambda: 3GS](#lambda-3gs)


# Vibrio parahaemolyticus ATCC BAA-239, 副溶血弧菌

Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Vpar: download

* Settings

```bash
BASE_NAME=Vpar
REAL_G=5165770
IS_EUK="false"
COVERAGE2="40 80"
COVERAGE3="40 80"
READ_QUAL="25 30"
READ_LEN="60"
EXPAND_WITH="40"

```

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

* FastQC

* kmergenie

## Vpar: preprocess Illumina reads

## Vpar: preprocess PacBio reads

## Vpar: reads stats

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 3288558 |    5165770 |        2 |
| Paralogs |    3333 |     155714 |       62 |
| Illumina |     101 | 1368727962 | 13551762 |
| uniq     |     101 | 1361783404 | 13483004 |
| shuffle  |     101 | 1361783404 | 13483004 |
| scythe   |     101 | 1344854680 | 13483004 |
| Q25L60   |     101 | 1200258254 | 12011424 |
| Q30L60   |     101 | 1141298554 | 11613013 |
| PacBio   |   11771 | 1228497092 |   143537 |
| X40.raw  |   11816 |  206635364 |    24145 |
| X40.trim |   10545 |  173840405 |    20555 |
| X80.raw  |   11822 |  413261717 |    48766 |
| X80.trim |   10678 |  355440531 |    41795 |

## Vpar: spades

## Vpar: platanus

## Vpar: quorum

| Name   | SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|------:|-------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 |  1.2G | 232.3 |  1.12G |  216.3 |   6.910% |     100 | "71" | 5.17M | 5.48M |     1.06 | 0:02'41'' |
| Q30L60 | 1.14G | 221.1 |  1.07G |  207.1 |   6.299% |      99 | "71" | 5.17M | 5.42M |     1.05 | 0:02'36'' |

## Vpar: adapter filtering

## Vpar: down sampling

## Vpar: k-unitigs and anchors (sampled)

| Name          |  SumCor | CovCor | N50Anchor |   Sum |   # | N50Others |    Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|--------:|-------:|----------:|------:|----:|----------:|-------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 | 206.63M |   40.0 |     81937 | 5.04M | 112 |       789 | 29.24K | 39 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:02'16'' | 0:01'09'' |
| Q25L60X40P001 | 206.63M |   40.0 |     82846 | 5.05M | 104 |       713 | 31.81K | 44 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:02'15'' | 0:01'06'' |
| Q25L60X40P002 | 206.63M |   40.0 |     95853 | 5.04M | 106 |       784 | 31.33K | 42 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:02'13'' | 0:01'12'' |
| Q25L60X40P003 | 206.63M |   40.0 |     96694 | 5.04M | 105 |       762 | 27.37K | 37 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'09'' | 0:01'06'' |
| Q25L60X40P004 | 206.63M |   40.0 |     95833 | 5.04M | 102 |       735 |  27.7K | 39 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:02'23'' | 0:01'07'' |
| Q25L60X80P000 | 413.26M |   80.0 |     63768 | 5.04M | 138 |       750 | 20.82K | 29 |   77.5 | 8.5 |  17.3 | 154.5 | "31,41,51,61,71,81" | 0:03'09'' | 0:00'59'' |
| Q25L60X80P001 | 413.26M |   80.0 |     65072 | 5.05M | 149 |       729 | 18.28K | 26 |   78.0 | 8.0 |  18.0 | 153.0 | "31,41,51,61,71,81" | 0:03'02'' | 0:01'02'' |
| Q30L60X40P000 | 206.63M |   40.0 |    143227 | 5.04M |  84 |       790 |  30.4K | 41 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:02'20'' | 0:01'13'' |
| Q30L60X40P001 | 206.63M |   40.0 |    123767 | 5.04M |  82 |       754 | 27.56K | 38 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:02'10'' | 0:01'09'' |
| Q30L60X40P002 | 206.63M |   40.0 |    143237 | 5.04M |  83 |       762 | 27.68K | 38 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:02'12'' | 0:01'09'' |
| Q30L60X40P003 | 206.63M |   40.0 |    142864 | 5.04M |  88 |       697 | 23.22K | 34 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:02'09'' | 0:01'12'' |
| Q30L60X40P004 | 206.63M |   40.0 |    146947 | 5.04M |  84 |       804 | 30.12K | 40 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:02'12'' | 0:01'11'' |
| Q30L60X80P000 | 413.26M |   80.0 |    104258 | 5.04M |  96 |       710 | 19.32K | 27 |   75.0 | 7.0 |  18.0 | 144.0 | "31,41,51,61,71,81" | 0:03'09'' | 0:01'06'' |
| Q30L60X80P001 | 413.26M |   80.0 |    104258 | 5.04M |  95 |       710 |  19.7K | 28 |   76.0 | 7.0 |  18.3 | 145.5 | "31,41,51,61,71,81" | 0:03'12'' | 0:01'09'' |

## Vpar: merge anchors

## Vpar: 3GS

| Name               |     N50 |       Sum |     # |
|:-------------------|--------:|----------:|------:|
| Genome             | 3288558 |   5165770 |     2 |
| Paralogs           |    3333 |    155714 |    62 |
| X40.raw.corrected  |   10645 | 142920341 | 16613 |
| X40.trim.corrected |   10455 | 139373803 | 16359 |
| X80.raw.corrected  |   12302 | 202279213 | 17129 |
| X80.trim.corrected |   11981 | 201858628 | 17420 |
| X40.raw            | 1697538 |   5188544 |     7 |
| X40.trim           | 1697335 |   5182144 |     6 |
| X80.raw            | 3318284 |   5205189 |     2 |
| X80.trim           | 3316838 |   5204553 |     2 |

## Vpar: expand anchors

* anchorLong

* contigTrim

## Vpar: final stats

* Stats

| Name                   |     N50 |     Sum |    # |
|:-----------------------|--------:|--------:|-----:|
| Genome                 | 3288558 | 5165770 |    2 |
| Paralogs               |    3333 |  155714 |   62 |
| anchor                 |  179336 | 5051715 |   72 |
| others                 |     823 |   89935 |  114 |
| anchorLong             |  208183 | 5041631 |   57 |
| contigTrim             | 1017789 | 5086016 |   15 |
| canu-X40-raw           | 1697538 | 5188544 |    7 |
| canu-X40-trim          | 1697335 | 5182144 |    6 |
| spades.contig          |  256618 | 6556836 | 3899 |
| spades.scaffold        |  373514 | 6566166 | 3637 |
| spades.non-contained   |  288633 | 5164547 |  125 |
| platanus.contig        |  196706 | 5152580 |  619 |
| platanus.scaffold      |  339534 | 5134547 |  434 |
| platanus.non-contained |  426844 | 5061526 |   34 |

* quast

## Vpar: clear intermediate files

# Legionella pneumophila subsp. pneumophila ATCC 33152D-5; Philadelphia-1, 嗜肺军团菌

Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Lpne: download

* Settings

```bash
BASE_NAME=Lpne
REAL_G=3397754
COVERAGE2="40 80"
COVERAGE3="40 80"
READ_QUAL="25 30"
READ_LEN="60"
EXPAND_WITH="40"

```

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

* FastQC

* kmergenie

## Lpne: preprocess Illumina reads

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

cd 2_illumina

anchr trim \
    --uniq \
    --sample $(( ${REAL_G} * 200 )) \
    --nosickle \
    R1.fq.gz R2.fq.gz \
    -o trim.sh
bash trim.sh

parallel --no-run-if-empty --linebuffer -k -j 3 "
    mkdir -p Q{1}L{2}
    cd Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        -q {1} -l {2} \
        \$(
            if [ -e ../R1.scythe.fq.gz ]; then
                echo '../R1.scythe.fq.gz ../R2.scythe.fq.gz'
            elif [ -e ../R1.sample.fq.gz ]; then
                echo '../R1.sample.fq.gz ../R2.sample.fq.gz'
            elif [ -e ../R1.shuffle.fq.gz ]; then
                echo '../R1.shuffle.fq.gz ../R2.shuffle.fq.gz'
            elif [ -e ../R1.uniq.fq.gz ]; then
                echo '../R1.uniq.fq.gz ../R2.uniq.fq.gz'
            else
                echo '../R1.fq.gz ../R2.fq.gz'
            fi
        ) \
         \
        -o stdout \
        | bash
    " ::: ${READ_QUAL} ::: ${READ_LEN}

```

## Lpne: preprocess PacBio reads

## Lpne: reads stats

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 3397754 |    3397754 |        1 |
| Paralogs |    2793 |     100722 |       43 |
| Illumina |     101 | 1060346682 | 10498482 |
| uniq     |     101 | 1056283452 | 10458252 |
| sample   |     101 |  679550826 |  6728226 |
| Q25L60   |     101 |  585067867 |  5874622 |
| Q30L60   |     101 |  536510199 |  5530505 |
| PacBio   |    8538 |  287320468 |    56763 |
| X40.raw  |    8671 |  135913310 |    26008 |
| X40.trim |    8378 |  114584028 |    18809 |
| X80.raw  |    8542 |  271822256 |    53600 |
| X80.trim |    8354 |  232880224 |    39020 |

## Lpne: spades

## Lpne: platanus

## Lpne: quorum

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 585.07M | 172.2 | 539.55M |  158.8 |   7.779% |      99 | "71" |  3.4M | 3.41M |     1.00 | 0:01'20'' |
| Q30L60 | 536.95M | 158.0 | 503.09M |  148.1 |   6.306% |      97 | "71" |  3.4M | 3.41M |     1.00 | 0:01'15'' |

## Lpne: down sampling

## Lpne: k-unitigs and anchors (sampled)

| Name          |  SumCor | CovCor | N50Anchor |   Sum |   # | N50Others |    Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|--------:|-------:|----------:|------:|----:|----------:|-------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 | 135.91M |   40.0 |     72356 | 3.36M |  75 |       768 | 41.85K | 55 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'27'' | 0:00'54'' |
| Q25L60X40P001 | 135.91M |   40.0 |    105396 | 3.36M |  71 |       801 | 38.91K | 49 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'26'' | 0:00'55'' |
| Q25L60X40P002 | 135.91M |   40.0 |    103006 | 3.36M |  70 |       801 | 34.63K | 41 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'42'' | 0:00'54'' |
| Q25L60X80P000 | 271.82M |   80.0 |     64229 | 3.36M | 101 |      1834 | 60.85K | 48 |   78.0 | 3.0 |  23.0 | 130.5 | "31,41,51,61,71,81" | 0:01'56'' | 0:00'48'' |
| Q30L60X40P000 | 135.91M |   40.0 |    118569 | 3.36M |  61 |       839 | 39.87K | 49 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'57'' |
| Q30L60X40P001 | 135.91M |   40.0 |    177814 | 3.36M |  58 |       847 | 46.05K | 55 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'54'' |
| Q30L60X40P002 | 135.91M |   40.0 |     98154 | 3.36M |  62 |       839 | 42.17K | 52 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'28'' | 0:00'55'' |
| Q30L60X80P000 | 271.82M |   80.0 |    132984 | 3.35M |  60 |      1776 | 59.61K | 45 |   78.0 | 4.0 |  22.0 | 135.0 | "31,41,51,61,71,81" | 0:01'37'' | 0:00'54'' |

## Lpne: merge anchors

## Lpne: 3GS

## Lpne: expand anchors

* anchorLong

* contigTrim

## Lpne: final stats

* Stats

| Name                   |     N50 |     Sum |   # |
|:-----------------------|--------:|--------:|----:|
| Genome                 | 3397754 | 3397754 |   1 |
| Paralogs               |    2793 |  100722 |  43 |
| anchor                 |  248586 | 3357462 |  39 |
| others                 |     948 |  123612 | 119 |
| anchorLong             |  261851 | 3355708 |  32 |
| contigTrim             |  479110 | 1448795 |   4 |
| canu-X40-raw           | 3415718 | 3415718 |   1 |
| canu-X40-trim          | 3393633 | 3393633 |   1 |
| spades.contig          |  431777 | 3485427 | 293 |
| spades.scaffold        |  431777 | 3485527 | 292 |
| spades.non-contained   |  431777 | 3408065 |  28 |
| platanus.contig        |  198660 | 3392691 | 209 |
| platanus.scaffold      |  363087 | 3385711 | 144 |
| platanus.non-contained |  363087 | 3364434 |  22 |

* quast

## Lpne: clear intermediate files

# Neisseria gonorrhoeae FDAARGOS_207, 淋病奈瑟氏菌

Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Ngon: download

* Settings

```bash
BASE_NAME=Ngon
REAL_G=2153922
IS_EUK="false"
COVERAGE2="40 80"
COVERAGE3="40 80"
READ_QUAL="25 30"
READ_LEN="60"
EXPAND_WITH="80"

```

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

## Ngon: preprocess Illumina reads

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

cd 2_illumina

anchr trim \
    --uniq \
    --sample $(( ${REAL_G} * 200 )) \
    --nosickle \
    R1.fq.gz R2.fq.gz \
    -o trim.sh
bash trim.sh

parallel --no-run-if-empty --linebuffer -k -j 3 "
    mkdir -p Q{1}L{2}
    cd Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        -q {1} -l {2} \
        \$(
            if [ -e ../R1.scythe.fq.gz ]; then
                echo '../R1.scythe.fq.gz ../R2.scythe.fq.gz'
            elif [ -e ../R1.sample.fq.gz ]; then
                echo '../R1.sample.fq.gz ../R2.sample.fq.gz'
            elif [ -e ../R1.shuffle.fq.gz ]; then
                echo '../R1.shuffle.fq.gz ../R2.shuffle.fq.gz'
            elif [ -e ../R1.uniq.fq.gz ]; then
                echo '../R1.uniq.fq.gz ../R2.uniq.fq.gz'
            else
                echo '../R1.fq.gz ../R2.fq.gz'
            fi
        ) \
         \
        -o stdout \
        | bash
    " ::: ${READ_QUAL} ::: ${READ_LEN}

```

## Ngon: preprocess PacBio reads

## Ngon: reads stats

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 2153922 |    2153922 |        1 |
| Paralogs |    4318 |     142093 |       53 |
| Illumina |     101 | 1491583958 | 14768158 |
| uniq     |     101 | 1485449016 | 14707416 |
| scythe   |     101 | 1460356291 | 14707416 |
| Q25L60   |     101 | 1062429395 | 10873960 |
| Q30L60   |     101 |  884852448 |  9519518 |
| PacBio   |   11808 | 1187845820 |   137516 |
| X40.raw  |   11588 |   86161380 |    10392 |
| X40.trim |   10011 |   68381718 |     8716 |
| X80.raw  |   11668 |  172317459 |    20331 |
| X80.trim |    9976 |  136791162 |    17440 |

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 2153922 |    2153922 |        1 |
| Paralogs |    4318 |     142093 |       53 |
| Illumina |     101 | 1491583958 | 14768158 |
| uniq     |     101 | 1485449016 | 14707416 |
| sample   |     101 |  430784392 |  4265192 |
| Q25L60   |     101 |  308531626 |  3157908 |
| Q30L60   |     101 |  256799891 |  2762357 |
| PacBio   |   11808 | 1187845820 |   137516 |
| X40.raw  |   11588 |   86161380 |    10392 |
| X40.trim |   10011 |   68381718 |     8716 |
| X80.raw  |   11668 |  172317459 |    20331 |
| X80.trim |    9976 |  136791162 |    17440 |

## Ngon: spades

## Ngon: platanus

## Ngon: quorum

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 308.53M | 143.2 | 282.93M |  131.4 |   8.299% |      97 | "51" | 2.15M | 2.05M |     0.95 | 0:00'44'' |
| Q30L60 | 257.31M | 119.5 | 240.89M |  111.8 |   6.381% |      93 | "59" | 2.15M | 2.04M |     0.95 | 0:00'40'' |

## Ngon: adapter filtering

## Ngon: down sampling

## Ngon: k-unitigs and anchors (sampled)

| Name          |  SumCor | CovCor | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|--------:|-------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |  86.16M |   40.0 |     15975 | 1.91M | 198 |       890 | 145.19K | 158 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'45'' |
| Q25L60X40P001 |  86.16M |   40.0 |     15416 | 1.94M | 193 |       932 | 118.75K | 127 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'46'' |
| Q25L60X40P002 |  86.16M |   40.0 |     18560 | 1.95M | 175 |       948 | 133.59K | 132 |   38.0 | 3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'45'' |
| Q25L60X80P000 | 172.31M |   80.0 |     16569 | 1.94M | 196 |      1096 |  79.09K |  79 |   76.0 | 6.0 |  19.3 | 141.0 | "31,41,51,61,71,81" | 0:01'11'' | 0:00'45'' |
| Q30L60X40P000 |  86.16M |   40.0 |     13959 | 1.82M | 208 |       920 | 221.97K | 231 |   37.0 | 5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'48'' |
| Q30L60X40P001 |  86.16M |   40.0 |     17714 | 1.87M | 192 |       986 | 212.44K | 206 |   36.0 | 4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'47'' |
| Q30L60X80P000 | 172.31M |   80.0 |     19456 | 1.85M | 165 |      1052 | 117.38K | 110 |   73.0 | 9.0 |  15.3 | 146.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'50'' |

## Ngon: merge anchors

## Ngon: 3GS

| Name               |     N50 |      Sum |    # |
|:-------------------|--------:|---------:|-----:|
| Genome             | 2153922 |  2153922 |    1 |
| Paralogs           |    4318 |   142093 |   53 |
| X40.raw.corrected  |    9847 | 55682989 | 7133 |
| X40.trim.corrected |    9713 | 54697518 | 7101 |
| X80.raw.corrected  |   10551 | 81435212 | 8177 |
| X80.trim.corrected |   10333 | 81378927 | 8342 |
| X40.raw            | 2199421 |  2199421 |    1 |
| X40.trim           | 2201340 |  2201340 |    1 |
| X80.raw            | 2201886 |  2201886 |    1 |
| X80.trim           | 2205541 |  2205541 |    1 |

## Ngon: expand anchors

* anchorLong

* contigTrim

## Ngon: final stats

* Stats

| Name                   |     N50 |     Sum |    # |
|:-----------------------|--------:|--------:|-----:|
| Genome                 | 2153922 | 2153922 |    1 |
| Paralogs               |    4318 |  142093 |   53 |
| anchor                 |   22866 | 1959665 |  139 |
| others                 |     951 |  353848 |  353 |
| anchorLong             |   37026 | 1401673 |   76 |
| contigTrim             |   63364 | 1408234 |   54 |
| canu-X80-raw           | 2201886 | 2201886 |    1 |
| canu-X80-trim          | 2205541 | 2205541 |    1 |
| spades.contig          |   46882 | 2420345 | 1298 |
| spades.scaffold        |   49686 | 2420777 | 1263 |
| spades.non-contained   |   57178 | 2062870 |   84 |
| platanus.contig        |   20636 | 2140482 |  845 |
| platanus.scaffold      |   46754 | 2104640 |  513 |
| platanus.non-contained |   46992 | 2038450 |   86 |

* quast

## Ngon: clear intermediate files

# Neisseria meningitidis FDAARGOS_209, 脑膜炎奈瑟氏菌

Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Nmen: download

* Settings

```bash
BASE_NAME=Nmen
REAL_G=2272360
IS_EUK="false"
COVERAGE2="40 80"
COVERAGE3="40 80"
READ_QUAL="25 30"
READ_LEN="60"
EXPAND_WITH="40"

```

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

* FastQC

* kmergenie

## Nmen: preprocess Illumina reads

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

cd 2_illumina

anchr trim \
    --uniq \
    --sample $(( ${REAL_G} * 200 )) \
    --nosickle \
    R1.fq.gz R2.fq.gz \
    -o trim.sh
bash trim.sh

parallel --no-run-if-empty --linebuffer -k -j 3 "
    mkdir -p Q{1}L{2}
    cd Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        -q {1} -l {2} \
        \$(
            if [ -e ../R1.scythe.fq.gz ]; then
                echo '../R1.scythe.fq.gz ../R2.scythe.fq.gz'
            elif [ -e ../R1.sample.fq.gz ]; then
                echo '../R1.sample.fq.gz ../R2.sample.fq.gz'
            elif [ -e ../R1.shuffle.fq.gz ]; then
                echo '../R1.shuffle.fq.gz ../R2.shuffle.fq.gz'
            elif [ -e ../R1.uniq.fq.gz ]; then
                echo '../R1.uniq.fq.gz ../R2.uniq.fq.gz'
            else
                echo '../R1.fq.gz ../R2.fq.gz'
            fi
        ) \
         \
        -o stdout \
        | bash
    " ::: ${READ_QUAL} ::: ${READ_LEN}

```

## Nmen: preprocess PacBio reads

## Nmen: reads stats

* Stats

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 2272360 |    2272360 |        1 |
| Paralogs |       0 |          0 |        0 |
| Illumina |     101 | 1395253390 | 13814390 |
| uniq     |     101 | 1389594158 | 13758358 |
| sample   |     101 |  454472124 |  4499724 |
| Q25L60   |     101 |  330689337 |  3380444 |
| Q30L60   |     101 |  277862500 |  2980708 |
| PacBio   |    9603 |  402166610 |    58711 |
| X40.raw  |    9572 |   90903934 |    12719 |
| X40.trim |    9017 |   80424232 |    10580 |
| X80.raw  |    9605 |  181790161 |    26345 |
| X80.trim |    9133 |  163286173 |    21467 |

## Nmen: spades

## Nmen: platanus

## Nmen: quorum

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 330.69M | 145.5 |  302.6M |  133.2 |   8.493% |      97 | "71" | 2.27M | 2.77M |     1.22 | 0:00'47'' |
| Q30L60 | 278.38M | 122.5 | 259.45M |  114.2 |   6.801% |      93 | "61" | 2.27M | 2.63M |     1.16 | 0:00'42'' |

## Nmen: adapter filtering

## Nmen: down sampling

## Nmen: k-unitigs and anchors (sampled)

| Name          |  SumCor | CovCor | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|--------:|-------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |  90.89M |   40.0 |      8236 | 1.91M | 320 |       924 | 262.31K | 281 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'49'' |
| Q25L60X40P001 |  90.89M |   40.0 |      8387 | 1.94M | 311 |       907 | 218.09K | 238 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'49'' |
| Q25L60X40P002 |  90.89M |   40.0 |      8369 | 1.93M | 309 |       949 | 227.07K | 230 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:00'59'' | 0:00'50'' |
| Q25L60X80P000 | 181.79M |   80.0 |      8730 | 1.94M | 310 |       981 | 138.14K | 138 |   73.0 | 6.0 |  18.3 | 136.5 | "31,41,51,61,71,81" | 0:01'17'' | 0:00'44'' |
| Q30L60X40P000 |  90.89M |   40.0 |      7791 |  1.8M | 322 |       965 |  440.2K | 439 |   35.0 | 5.0 |   6.7 |  70.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'50'' |
| Q30L60X40P001 |  90.89M |   40.0 |      8194 | 1.89M | 304 |       932 |  310.3K | 328 |   36.0 | 4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'49'' |
| Q30L60X80P000 | 181.79M |   80.0 |      8591 | 1.85M | 285 |       946 | 193.68K | 199 |   70.0 | 9.0 |  14.3 | 140.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'53'' |

## Nmen: merge anchors

## Nmen: 3GS

| Name               |     N50 |      Sum |    # |
|:-------------------|--------:|---------:|-----:|
| Genome             | 2272360 |  2272360 |    1 |
| Paralogs           |       0 |        0 |    0 |
| X40.raw.corrected  |    9195 | 70449230 | 8878 |
| X40.trim.corrected |    9030 | 68464011 | 8818 |
| X80.raw.corrected  |   10640 | 90338570 | 8406 |
| X80.trim.corrected |   10334 | 90084457 | 8603 |
| X40.raw            | 2187325 |  2187325 |    1 |
| X40.trim           | 2187256 |  2187256 |    1 |
| X80.raw            | 2196467 |  2196467 |    1 |
| X80.trim           | 2196486 |  2196486 |    1 |

## Nmen: expand anchors

* anchorLong

* contigTrim

## Nmen: final stats

* Stats

| Name                   |     N50 |     Sum |    # |
|:-----------------------|--------:|--------:|-----:|
| Genome                 | 2272360 | 2272360 |    1 |
| Paralogs               |       0 |       0 |    0 |
| anchor                 |   10021 | 2049680 |  284 |
| others                 |     849 |  456918 |  545 |
| anchorLong             |    6354 |  614844 |  139 |
| contigTrim             |    6354 |  614844 |  139 |
| canu-X40-raw           | 2187325 | 2187325 |    1 |
| canu-X40-trim          | 2187256 | 2187256 |    1 |
| spades.contig          |   31700 | 4457403 |  686 |
| spades.scaffold        |   46528 | 4458223 |  626 |
| spades.non-contained   |   31959 | 4374230 |  227 |
| platanus.contig        |    8599 | 2277767 | 1568 |
| platanus.scaffold      |   42293 | 2207891 |  819 |
| platanus.non-contained |   42882 | 2094123 |   95 |

* quast

## Nmen: clear intermediate files

# Bordetella pertussis FDAARGOS_195, 百日咳博德特氏杆菌

* Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

* Other name: ATCC BAA-589D-5; Tohama 1;

* BioSample: [SAMN04875532](https://www.ncbi.nlm.nih.gov/biosample/SAMN04875532)

## Bper: download

* Settings

```bash
BASE_NAME=Bper
REAL_G=4086189
IS_EUK="false"
COVERAGE2="40 80"
READ_QUAL="25 30"
READ_LEN="60"

```

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

* FastQC

* kmergenie

## Bper: preprocess Illumina reads

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

cd 2_illumina

anchr trim \
    --uniq \
    --sample $(( ${REAL_G} * 200 )) \
    --nosickle \
    R1.fq.gz R2.fq.gz \
    -o trim.sh
bash trim.sh

parallel --no-run-if-empty --linebuffer -k -j 3 "
    mkdir -p Q{1}L{2}
    cd Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        -q {1} -l {2} \
        \$(
            if [ -e ../R1.scythe.fq.gz ]; then
                echo '../R1.scythe.fq.gz ../R2.scythe.fq.gz'
            elif [ -e ../R1.sample.fq.gz ]; then
                echo '../R1.sample.fq.gz ../R2.sample.fq.gz'
            elif [ -e ../R1.shuffle.fq.gz ]; then
                echo '../R1.shuffle.fq.gz ../R2.shuffle.fq.gz'
            elif [ -e ../R1.uniq.fq.gz ]; then
                echo '../R1.uniq.fq.gz ../R2.uniq.fq.gz'
            else
                echo '../R1.fq.gz ../R2.fq.gz'
            fi
        ) \
         \
        -o stdout \
        | bash
    " ::: ${READ_QUAL} ::: ${READ_LEN}

```

## Bper: reads stats

* Stats

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 4086189 |    4086189 |        1 |
| Paralogs |    1033 |     322667 |      278 |
| Illumina |     101 | 1673028438 | 16564638 |
| uniq     |     101 | 1655310614 | 16389214 |
| sample   |     101 |  817237864 |  8091464 |
| Q25L60   |     101 |  521485739 |  5386482 |
| Q30L60   |     101 |  415585395 |  4569799 |

## Bper: quorum

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 521.49M | 127.6 | 476.13M |  116.5 |   8.696% |      97 | "33" | 4.09M |  3.9M |     0.95 | 0:01'19'' |
| Q30L60 | 416.83M | 102.0 | 386.41M |   94.6 |   7.298% |      91 | "31" | 4.09M | 3.78M |     0.93 | 0:01'10'' |

## Bper: adapter filtering

## Bper: down sampling

## Bper: k-unitigs and anchors (sampled)

| Name          |  SumCor | CovCor | N50Anchor |   Sum |   # | N50Others |   Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|--------:|-------:|----------:|------:|----:|----------:|------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 | 163.45M |   40.0 |      2265 | 2.01M | 964 |      1029 | 1.18M | 1124 |   40.0 | 11.0 |   2.3 |  80.0 | "31,41,51,61,71,81" | 0:01'34'' | 0:00'51'' |
| Q25L60X40P001 | 163.45M |   40.0 |      2449 | 2.19M | 996 |       995 |  1.1M | 1064 |   41.0 | 11.0 |   2.7 |  82.0 | "31,41,51,61,71,81" | 0:01'32'' | 0:00'52'' |
| Q25L60X80P000 |  326.9M |   80.0 |      2468 | 2.24M | 992 |      1143 | 1.18M | 1064 |   78.0 | 22.0 |   4.0 | 156.0 | "31,41,51,61,71,81" | 0:02'19'' | 0:00'53'' |
| Q30L60X40P000 | 163.45M |   40.0 |      1840 | 1.44M | 801 |      1330 | 1.67M | 1392 |   40.0 | 13.0 |   2.0 |  80.0 | "31,41,51,61,71,81" | 0:01'31'' | 0:00'48'' |
| Q30L60X40P001 | 163.45M |   40.0 |      2009 | 1.68M | 856 |      1219 | 1.36M | 1192 |   41.0 | 11.0 |   2.7 |  82.0 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'49'' |
| Q30L60X80P000 |  326.9M |   80.0 |      2155 |  1.8M | 898 |      1516 | 1.37M | 1077 |   78.0 | 24.0 |   2.0 | 156.0 | "31,41,51,61,71,81" | 0:01'30'' | 0:00'52'' |

## Bper: merge anchors

## Bper: final stats

* Stats

| Name     |     N50 |     Sum |    # |
|:---------|--------:|--------:|-----:|
| Genome   | 4086189 | 4086189 |    1 |
| Paralogs |    1033 |  322667 |  278 |
| anchor   |    2886 | 2719158 | 1095 |
| others   |    1392 | 2874462 | 2343 |

## Bper: clear intermediate files


# Corynebacterium diphtheriae FDAARGOS_197, 白喉杆菌

* Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

* Other name: ATCC 700971D-5; NCTC 13129;

* BioSample: [SAMN04875534](https://www.ncbi.nlm.nih.gov/biosample/SAMN04875534)

## Cdip: download

* Settings

```bash
BASE_NAME=Cdip
REAL_G=2488635
IS_EUK="false"
COVERAGE2="40 80"
COVERAGE3="40 80"
READ_QUAL="25 30"
READ_LEN="60"
EXPAND_WITH="40"

```

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

* FastQC

* kmergenie

## Cdip: preprocess Illumina reads

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

cd 2_illumina

anchr trim \
    --uniq \
    --sample $(( ${REAL_G} * 200 )) \
    --nosickle \
    R1.fq.gz R2.fq.gz \
    -o trim.sh
bash trim.sh

parallel --no-run-if-empty --linebuffer -k -j 3 "
    mkdir -p Q{1}L{2}
    cd Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        -q {1} -l {2} \
        \$(
            if [ -e ../R1.scythe.fq.gz ]; then
                echo '../R1.scythe.fq.gz ../R2.scythe.fq.gz'
            elif [ -e ../R1.sample.fq.gz ]; then
                echo '../R1.sample.fq.gz ../R2.sample.fq.gz'
            elif [ -e ../R1.shuffle.fq.gz ]; then
                echo '../R1.shuffle.fq.gz ../R2.shuffle.fq.gz'
            elif [ -e ../R1.uniq.fq.gz ]; then
                echo '../R1.uniq.fq.gz ../R2.uniq.fq.gz'
            else
                echo '../R1.fq.gz ../R2.fq.gz'
            fi
        ) \
         \
        -o stdout \
        | bash
    " ::: ${READ_QUAL} ::: ${READ_LEN}

```

## Cdip: preprocess PacBio reads

## Cdip: reads stats

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 2488635 |    2488635 |        1 |
| Paralogs |    5635 |      56210 |       18 |
| Illumina |     101 | 1124010012 | 11128812 |
| uniq     |     101 | 1120677416 | 11095816 |
| sample   |     101 |  497726990 |  4927990 |
| Q25L60   |     101 |  360559369 |  3686168 |
| Q30L60   |     101 |  299516087 |  3228595 |
| PacBio   |    8966 |  665803465 |   110317 |
| X40.raw  |    8711 |   99551858 |    17164 |
| X40.trim |    7701 |   73822092 |    12668 |
| X80.raw  |    8781 |  199091231 |    33954 |
| X80.trim |    7824 |  153762465 |    25880 |

## Cdip: spades

## Cdip: platanus

## Cdip: quorum

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 360.56M | 144.9 | 328.88M |  132.2 |   8.785% |      97 | "51" | 2.49M | 2.46M |     0.99 | 0:00'54'' |
| Q30L60 | 300.05M | 120.6 | 280.32M |  112.6 |   6.578% |      93 | "43" | 2.49M | 2.45M |     0.99 | 0:00'46'' |

## Cdip: adapter filtering

## Cdip: down sampling

## Cdip: k-unitigs and anchors (sampled)

| Name          |  SumCor | CovCor | N50Anchor |   Sum |  # | N50Others |    Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|--------:|-------:|----------:|------:|---:|----------:|-------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |  99.55M |   40.0 |     57061 | 2.45M | 79 |       866 | 31.36K | 37 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:00'59'' | 0:00'46'' |
| Q25L60X40P001 |  99.55M |   40.0 |     63796 | 2.45M | 80 |       875 | 29.67K | 34 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'04'' | 0:00'47'' |
| Q25L60X40P002 |  99.55M |   40.0 |     63796 | 2.44M | 73 |       880 | 22.99K | 27 |   38.0 | 3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:01'08'' | 0:00'46'' |
| Q25L60X80P000 | 199.09M |   80.0 |     49194 | 2.44M | 93 |       844 |  9.96K | 11 |   75.0 | 6.0 |  19.0 | 139.5 | "31,41,51,61,71,81" | 0:01'22'' | 0:00'46'' |
| Q30L60X40P000 |  99.55M |   40.0 |     96144 | 2.37M | 85 |       879 | 48.37K | 52 |   36.0 | 5.0 |   7.0 |  72.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'47'' |
| Q30L60X40P001 |  99.55M |   40.0 |     93641 | 2.44M | 67 |       886 |  34.7K | 37 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'49'' |
| Q30L60X80P000 | 199.09M |   80.0 |     97954 | 2.44M | 58 |       880 | 15.41K | 15 |   73.0 | 8.0 |  16.3 | 145.5 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'55'' |

## Cdip: merge anchors

## Cdip: 3GS

| Name               |     N50 |      Sum |     # |
|:-------------------|--------:|---------:|------:|
| Genome             | 2488635 |  2488635 |     1 |
| Paralogs           |    5635 |    56210 |    18 |
| X40.raw.corrected  |    7257 | 56265507 | 10159 |
| X40.trim.corrected |    7453 | 63171010 | 11168 |
| X80.raw.corrected  |    7478 | 95381095 | 15600 |
| X80.trim.corrected |    7383 | 96029619 | 15940 |
| X40.raw            | 2485569 |  2485569 |     1 |
| X40.trim           | 2500316 |  2500316 |     1 |
| X80.raw            | 2502286 |  2502286 |     1 |
| X80.trim           | 2502151 |  2502151 |     1 |

## Cdip: expand anchors

* anchorLong

* contigTrim

## Cdip: final stats

* Stats

| Name                   |     N50 |     Sum |   # |
|:-----------------------|--------:|--------:|----:|
| Genome                 | 2488635 | 2488635 |   1 |
| Paralogs               |    5635 |   56210 |  18 |
| anchor                 |  115949 | 2442001 |  45 |
| others                 |     900 |   86389 |  94 |
| anchorLong             |  125030 | 2440328 |  35 |
| contigTrim             |  755593 | 2458291 |   6 |
| canu-X40-raw           | 2485569 | 2485569 |   1 |
| canu-X40-trim          | 2500316 | 2500316 |   1 |
| spades.contig          |  309919 | 2497126 | 168 |
| spades.scaffold        |  309919 | 2497136 | 167 |
| spades.non-contained   |  309919 | 2453973 |  16 |
| platanus.contig        |   95840 | 2468965 | 207 |
| platanus.scaffold      |  177061 | 2463217 | 123 |
| platanus.non-contained |  177061 | 2445888 |  23 |

* quast

## Cdip: clear intermediate files

# Francisella tularensis FDAARGOS_247, 土拉热弗朗西斯氏菌

* Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

* Other name: SHU-S4

* BioSample: [SAMN04875573](https://www.ncbi.nlm.nih.gov/biosample/SAMN04875573)

## Ftul: download

* Settings

```bash
BASE_NAME=Ftul
REAL_G=1892775
IS_EUK="false"
COVERAGE2="40 80"
COVERAGE3="40 80"
READ_QUAL="25 30"
READ_LEN="60"
EXPAND_WITH="40"

```

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

* FastQC

* kmergenie

## Ftul: preprocess Illumina reads

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

cd 2_illumina

anchr trim \
    --uniq \
    --sample $(( ${REAL_G} * 200 )) \
    --nosickle \
    R1.fq.gz R2.fq.gz \
    -o trim.sh
bash trim.sh

parallel --no-run-if-empty --linebuffer -k -j 3 "
    mkdir -p Q{1}L{2}
    cd Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        -q {1} -l {2} \
        \$(
            if [ -e ../R1.scythe.fq.gz ]; then
                echo '../R1.scythe.fq.gz ../R2.scythe.fq.gz'
            elif [ -e ../R1.sample.fq.gz ]; then
                echo '../R1.sample.fq.gz ../R2.sample.fq.gz'
            elif [ -e ../R1.shuffle.fq.gz ]; then
                echo '../R1.shuffle.fq.gz ../R2.shuffle.fq.gz'
            elif [ -e ../R1.uniq.fq.gz ]; then
                echo '../R1.uniq.fq.gz ../R2.uniq.fq.gz'
            else
                echo '../R1.fq.gz ../R2.fq.gz'
            fi
        ) \
         \
        -o stdout \
        | bash
    " ::: ${READ_QUAL} ::: ${READ_LEN}

```

## Ftul: preprocess PacBio reads

## Ftul: reads stats

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 1892775 |    1892775 |        1 |
| Paralogs |   33912 |      93531 |       10 |
| Illumina |     101 | 2144257270 | 21230270 |
| uniq     |     101 | 2122919000 | 21019000 |
| sample   |     101 |  378555070 |  3748070 |
| Q25L60   |     101 |  358292488 |  3564518 |
| Q30L60   |     101 |  348963702 |  3508222 |
| PacBio   |   10022 | 1161069478 |   151564 |
| X40.raw  |   10119 |   75716038 |     9860 |
| X40.trim |    9181 |   66146846 |     8769 |
| X80.raw  |   10012 |  151423072 |    19828 |
| X80.trim |    9130 |  133365407 |    17725 |

## Ftul: spades

## Ftul: platanus

## Ftul: quorum

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead | Kmer | RealG | EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|-----:|------:|-----:|---------:|----------:|
| Q25L60 | 358.29M | 189.3 | 342.66M |  181.0 |   4.363% |     100 | "71" | 1.89M | 1.8M |     0.95 | 0:01'35'' |
| Q30L60 | 349.08M | 184.4 | 336.67M |  177.9 |   3.554% |      99 | "71" | 1.89M | 1.8M |     0.95 | 0:01'15'' |

## Ftul: down sampling

## Ftul: k-unitigs and anchors (sampled)

| Name          |  SumCor | CovCor | N50SR |   Sum |  # | N50Anchor |   Sum |  # | N50Others |    Sum | # |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|--------:|-------:|------:|------:|---:|----------:|------:|---:|----------:|-------:|--:|--------------------:|----------:|:----------|
| Q25L60X40P000 |  75.71M |   40.0 | 35248 |  1.8M | 72 |     35248 |  1.8M | 71 |       865 |    865 | 1 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'52'' |
| Q25L60X40P001 |  75.71M |   40.0 | 32751 |  1.8M | 75 |     32751 | 1.79M | 72 |      4293 |  9.43K | 3 | "31,41,51,61,71,81" | 0:01'15'' | 0:00'52'' |
| Q25L60X40P002 |  75.71M |   40.0 | 32751 |  1.8M | 76 |     32751 | 1.79M | 73 |      4293 |  9.45K | 3 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'54'' |
| Q25L60X40P003 |  75.71M |   40.0 | 32751 | 1.82M | 75 |     32803 | 1.77M | 72 |     23232 | 47.32K | 3 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'47'' |
| Q25L60X80P000 | 151.42M |   80.0 | 32751 |  1.8M | 78 |     32751 |  1.8M | 74 |       645 |  2.58K | 4 | "31,41,51,61,71,81" | 0:01'48'' | 0:01'09'' |
| Q25L60X80P001 | 151.42M |   80.0 | 31667 |  1.8M | 79 |     31667 |  1.8M | 77 |       865 |  1.44K | 2 | "31,41,51,61,71,81" | 0:01'49'' | 0:01'12'' |
| Q30L60X40P000 |  75.71M |   40.0 | 35248 |  1.8M | 72 |     35248 |  1.8M | 71 |       855 |    855 | 1 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'56'' |
| Q30L60X40P001 |  75.71M |   40.0 | 32751 | 1.84M | 76 |     32813 | 1.76M | 71 |     32374 | 74.19K | 5 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'45'' |
| Q30L60X40P002 |  75.71M |   40.0 | 32751 |  1.8M | 73 |     32751 |  1.8M | 72 |       855 |    855 | 1 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'44'' |
| Q30L60X40P003 |  75.71M |   40.0 | 32741 |  1.8M | 75 |     32741 |  1.8M | 74 |       865 |    865 | 1 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'45'' |
| Q30L60X80P000 | 151.42M |   80.0 | 32751 |  1.8M | 74 |     32751 |  1.8M | 73 |       865 |    865 | 1 | "31,41,51,61,71,81" | 0:01'49'' | 0:01'08'' |
| Q30L60X80P001 | 151.42M |   80.0 | 32751 |  1.8M | 74 |     32751 |  1.8M | 73 |       865 |    865 | 1 | "31,41,51,61,71,81" | 0:01'50'' | 0:01'12'' |

## Ftul: merge anchors

## Ftul: 3GS

## Ftul: expand anchors

* anchorLong

* contigTrim

## Ftul: final stats

* Stats

| Name                   |     N50 |     Sum |   # |
|:-----------------------|--------:|--------:|----:|
| Genome                 | 1892775 | 1892775 |   1 |
| Paralogs               |   33912 |   93531 |  10 |
| anchor                 |   35248 | 1763619 |  68 |
| others                 |    1021 |   79391 |  58 |
| anchorLong             |   36720 | 1760250 |  65 |
| contigTrim             | 1398718 | 1814408 |   3 |
| canu-X40-raw           | 1018516 | 1859029 |   2 |
| canu-X40-trim          | 1018500 | 1858183 |   2 |
| spades.contig          |   37811 | 1808598 |  81 |
| spades.scaffold        |   37811 | 1808608 |  80 |
| spades.non-contained   |   37811 | 1804933 |  67 |
| platanus.contig        |   35258 | 1807536 | 121 |
| platanus.scaffold      |   37800 | 1804173 |  92 |
| platanus.non-contained |   37800 | 1798153 |  65 |

* quast

## Ftul: clear intermediate files

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

## Sfle: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60 and 90

```bash
BASE_DIR=$HOME/data/anchr/Sfle

cd ${BASE_DIR}
if [ ! -e 2_illumina/R1.uniq.fq.gz ]; then
    tally \
        --pair-by-offset --with-quality --nozip --unsorted \
        -i 2_illumina/R1.fq.gz \
        -j 2_illumina/R2.fq.gz \
        -o 2_illumina/R1.uniq.fq \
        -p 2_illumina/R2.uniq.fq
    
    parallel --no-run-if-empty -j 2 "
            pigz -p 4 2_illumina/{}.uniq.fq
        " ::: R1 R2
fi

cd ${BASE_DIR}
if [ ! -e 2_illumina/R1.scythe.fq.gz ]; then
    parallel --no-run-if-empty -j 2 "
        scythe \
            2_illumina/{}.uniq.fq.gz \
            -q sanger \
            -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
            --quiet \
            | pigz -p 4 -c \
            > 2_illumina/{}.scythe.fq.gz
        " ::: R1 R2
fi

cd ${BASE_DIR}
parallel --no-run-if-empty -j 4 "
    mkdir -p 2_illumina/Q{1}L{2}
    cd 2_illumina/Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        --noscythe \
        -q {1} -l {2} \
        ../R1.scythe.fq.gz ../R2.scythe.fq.gz \
        -o stdout \
        | bash
    " ::: 20 25 30 ::: 60 90

```

* Stats

```bash
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Paralogs";   faops n50 -H -S -C 1_genome/paralogs.fas;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "PacBio";   faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";   faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md

for qual in 20 25 30; do
    for len in 60 90; do
        DIR_COUNT="${BASE_DIR}/2_illumina/Q${qual}L${len}"

        printf "| %s | %s | %s | %s |\n" \
            $(echo "Q${qual}L${len}"; faops n50 -H -S -C ${DIR_COUNT}/R1.fq.gz  ${DIR_COUNT}/R2.fq.gz;) \
            >> stat.md
    done
done

cat stat.md
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

## Sfle: down sampling

```bash
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

ARRAY=(
    "2_illumina/Q20L60:Q20L60"
    "2_illumina/Q20L90:Q20L90"
    "2_illumina/Q25L60:Q25L60"
    "2_illumina/Q25L90:Q25L90"
    "2_illumina/Q30L60:Q30L60"
    "2_illumina/Q30L90:Q30L90"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    printf "==> %s \t %s\n" "$GROUP_DIR" "$GROUP_ID"

    echo "==> Group ${GROUP_ID}"
    DIR_COUNT="${BASE_DIR}/${GROUP_ID}"
    mkdir -p ${DIR_COUNT}
    
    if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
        continue     
    fi
    
    ln -s ${BASE_DIR}/${GROUP_DIR}/R1.fq.gz ${DIR_COUNT}/R1.fq.gz
    ln -s ${BASE_DIR}/${GROUP_DIR}/R2.fq.gz ${DIR_COUNT}/R2.fq.gz

done
```

```bash
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

head -n 160000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.40x.fasta
faops n50 -S -C 3_pacbio/pacbio.40x.fasta

head -n 320000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.80x.fasta
faops n50 -S -C 3_pacbio/pacbio.80x.fasta

```

## Sfle: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L60 Q20L90
        Q25L60 Q25L90
        Q30L60 Q30L90
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel --no-run-if-empty -j 3 "
        echo '==> Group {}'
        
        if [ ! -d ${BASE_DIR}/{} ]; then
            echo '    directory not exists'
            exit;
        fi        

        if [ -e ${BASE_DIR}/{}/k_unitigs.fasta ]; then
            echo '    k_unitigs.fasta already presents'
            exit;
        fi

        cd ${BASE_DIR}/{}
        anchr superreads \
            R1.fq.gz R2.fq.gz \
            --nosr -p 8 \
            --kmer 41,61,81,101,121 \
           -o superreads.sh
        bash superreads.sh
    "

```

Clear intermediate files.

```bash
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## Sfle: create anchors

```bash
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L60 Q20L90
        Q25L60 Q25L90
        Q30L60 Q30L90
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel --no-run-if-empty -j 3 "
        echo '==> Group {}'

        if [ -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        rm -fr ${BASE_DIR}/{}/anchor
        bash ~/Scripts/cpan/App-Anchr/share/anchor.sh ${BASE_DIR}/{} 8 false
    "

```

## Sfle: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

REAL_G=4607202

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

perl -e '
    for my $n (
        qw{
        Q20L60 Q20L90
        Q25L60 Q25L90
        Q30L60 Q30L90
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 4 "
        if [ ! -d ${BASE_DIR}/{} ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${BASE_DIR}/{} ${REAL_G}
    " >> ${BASE_DIR}/stat1.md

cat stat1.md
```

* Stats of anchors

```bash
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

perl -e '
    for my $n (
        qw{
        Q20L60 Q20L90
        Q25L60 Q25L90
        Q30L60 Q30L90
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 8 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

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

## Sfle: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L60/anchor/pe.anchor.fa \
    Q20L90/anchor/pe.anchor.fa \
    Q25L60/anchor/pe.anchor.fa \
    Q25L90/anchor/pe.anchor.fa \
    Q30L60/anchor/pe.anchor.fa \
    Q30L90/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
anchr contained \
    Q20L60/anchor/pe.others.fa \
    Q20L90/anchor/pe.others.fa \
    Q25L60/anchor/pe.others.fa \
    Q25L90/anchor/pe.others.fa \
    Q30L60/anchor/pe.others.fa \
    Q30L90/anchor/pe.others.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.merge.fasta

# sort on ref
bash ~/Scripts/cpan/App-Anchr/share/sort_on_ref.sh merge/anchor.merge.fasta 1_genome/genome.fa merge/anchor.sort
nucmer -l 200 1_genome/genome.fa merge/anchor.sort.fa
mummerplot -png out.delta -p anchor.sort --large

# mummerplot files
rm *.[fr]plot
rm out.delta
rm *.gp

mv anchor.sort.png merge/

# quast
rm -fr 9_qa
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "merge,others,paralogs" \
    -o 9_qa

```

## Sfle: 3GS

```bash
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

canu \
    -p Sfle -d canu-raw-40x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=4.8m \
    -pacbio-raw 3_pacbio/pacbio.40x.fasta

canu \
    -p Sfle -d canu-raw-80x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=4.8m \
    -pacbio-raw 3_pacbio/pacbio.80x.fasta

faops n50 -S -C canu-raw-40x/Sfle.trimmedReads.fasta.gz
faops n50 -S -C canu-raw-80x/Sfle.trimmedReads.fasta.gz

```

## Sfle: expand anchors

* anchorLong

```bash
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

anchr cover \
    --parallel 16 \
    -c 2 -m 40 \
    -b 20 --len 1000 --idt 0.9 \
    merge/anchor.merge.fasta \
    canu-raw-40x/Sfle.trimmedReads.fasta.gz \
    -o merge/anchor.cover.fasta

rm -fr anchorLong
anchr overlap2 \
    --parallel 16 \
    merge/anchor.cover.fasta \
    canu-raw-40x/Sfle.trimmedReads.fasta.gz \
    -d anchorLong \
    -b 20 --len 1000 --idt 0.98

anchr overlap \
    merge/anchor.cover.fasta \
    --serial --len 10 --idt 0.9999 \
    -o stdout \
    | perl -nla -e '
        BEGIN {
            our %seen;
            our %count_of;
        }

        @F == 13 or next;
        $F[3] > 0.9999 or next;

        my $pair = join( "-", sort { $a <=> $b } ( $F[0], $F[1], ) );
        next if $seen{$pair};
        $seen{$pair} = $_;

        $count_of{ $F[0] }++;
        $count_of{ $F[1] }++;

        END {
            for my $pair ( keys %seen ) {
                my ($f_id, $g_id) = split "-", $pair;
                next if $count_of{$f_id} > 2;
                next if $count_of{$g_id} > 2;
                print $seen{$pair};
            }
        }
    ' \
    | sort -k 1n,1n -k 2n,2n \
    > anchorLong/anchor.ovlp.tsv

ANCHOR_COUNT=$(faops n50 -H -N 0 -C anchorLong/anchor.fasta)
echo ${ANCHOR_COUNT}

rm -fr anchorLong/group
anchr group \
    anchorLong/anchorLong.db \
    anchorLong/anchorLong.ovlp.tsv \
    --oa anchorLong/anchor.ovlp.tsv \
    --parallel 16 \
    --range "1-${ANCHOR_COUNT}" --len 1000 --idt 0.98 --max "-14" -c 4 --png

pushd ${BASE_DIR}/anchorLong
cat group/groups.txt \
    | parallel --no-run-if-empty -j 8 '
        echo {};
        anchr orient \
            --len 1000 --idt 0.98 \
            group/{}.anchor.fasta \
            group/{}.long.fasta \
            -r group/{}.restrict.tsv \
            -o group/{}.strand.fasta;

        anchr overlap --len 1000 --idt 0.98 \
            group/{}.strand.fasta \
            -o stdout \
            | anchr restrict \
                stdin group/{}.restrict.tsv \
                -o group/{}.ovlp.tsv;

        anchr overlap --len 10 --idt 0.9999 \
            group/{}.strand.fasta \
            -o stdout \
            | perl -nla -e '\''
                @F == 13 or next;
                $F[3] > 0.98 or next;
                $F[9] == 0 or next;
                $F[5] > 0 and $F[6] == $F[7] or next;
                /anchor.+anchor/ or next;
                print;
            '\'' \
            > group/{}.anchor.ovlp.tsv
            
        anchr layout \
            group/{}.ovlp.tsv \
            group/{}.relation.tsv \
            group/{}.strand.fasta \
            --oa group/{}.anchor.ovlp.tsv \
            --png \
            -o group/{}.contig.fasta
    '
popd

# false strand
cat anchorLong/group/*.ovlp.tsv \
    | perl -nla -e '/anchor.+long/ or next; print $F[0] if $F[8] == 1;' \
    | sort | uniq -c

cat \
   anchorLong/group/non_grouped.fasta\
   anchorLong/group/*.contig.fasta \
   | faops filter -l 0 -a 1000 stdin anchorLong/contig.fasta

```

* contigTrim

```bash
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

rm -fr contigTrim
anchr overlap2 \
    --parallel 16 \
    anchorLong/contig.fasta \
    canu-raw-40x/Sfle.contigs.fasta \
    -d contigTrim \
    -b 20 --len 1000 --idt 0.98 --all

CONTIG_COUNT=$(faops n50 -H -N 0 -C contigTrim/anchor.fasta)
echo ${CONTIG_COUNT}

rm -fr contigTrim/group
anchr group \
    --parallel 16 \
    --keep \
    contigTrim/anchorLong.db \
    contigTrim/anchorLong.ovlp.tsv \
    --range "1-${CONTIG_COUNT}" --len 1000 --idt 0.98 --max 20000 -c 1

pushd ${BASE_DIR}/contigTrim
cat group/groups.txt \
    | parallel --no-run-if-empty -j 8 '
        echo {};
        anchr orient \
            --len 1000 --idt 0.98 \
            group/{}.anchor.fasta \
            group/{}.long.fasta \
            -r group/{}.restrict.tsv \
            -o group/{}.strand.fasta;

        anchr overlap --len 1000 --idt 0.98 \
            group/{}.strand.fasta \
            -o stdout \
            | anchr restrict \
                stdin group/{}.restrict.tsv \
                -o group/{}.ovlp.tsv;

        anchr layout \
            group/{}.ovlp.tsv \
            group/{}.relation.tsv \
            group/{}.strand.fasta \
            -o group/{}.contig.fasta
    '
popd

cat \
    contigTrim/group/non_grouped.fasta \
    contigTrim/group/*.contig.fasta \
    >  contigTrim/contig.fasta

```

* quast

```bash
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

rm -fr 9_qa_contig
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/anchor.cover.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-raw-40x/Sfle.contigs.fasta \
    canu-raw-80x/Sfle.contigs.fasta \
    1_genome/paralogs.fas \
    --label "merge,cover,contig,contigTrim,canu-40x,canu-80x,paralogs" \
    -o 9_qa_contig

```

* Stats

```bash
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat3.md
printf "|:--|--:|--:|--:|\n" >> stat3.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Paralogs";   faops n50 -H -S -C 1_genome/paralogs.fas;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "anchor.merge"; faops n50 -H -S -C merge/anchor.merge.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "others.merge"; faops n50 -H -S -C merge/others.merge.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "anchor.cover"; faops n50 -H -S -C merge/anchor.cover.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "anchorLong"; faops n50 -H -S -C anchorLong/contig.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "contigTrim"; faops n50 -H -S -C contigTrim/contig.fasta;) >> stat3.md

cat stat3.md
```

| Name         |     N50 |     Sum |   # |
|:-------------|--------:|--------:|----:|
| Genome       | 4607202 | 4828820 |   2 |
| Paralogs     |    1377 |  543111 | 334 |
| anchor.merge |   29718 | 4177514 | 258 |
| others.merge |    1013 |    5268 |   5 |
| anchor.cover |   21445 | 4065033 | 337 |
| anchorLong   |   21727 | 4064559 | 333 |
| contigTrim   |   59768 | 4286051 | 140 |

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

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

* FastQC

* kmergenie

## Hinf: preprocess Illumina reads

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

cd 2_illumina

anchr trim \
    --uniq \
    --sample $(( ${REAL_G} * 200 )) \
    --nosickle \
    R1.fq.gz R2.fq.gz \
    -o trim.sh
bash trim.sh

parallel --no-run-if-empty --linebuffer -k -j 3 "
    mkdir -p Q{1}L{2}
    cd Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        -q {1} -l {2} \
        \$(
            if [ -e ../R1.scythe.fq.gz ]; then
                echo '../R1.scythe.fq.gz ../R2.scythe.fq.gz'
            elif [ -e ../R1.sample.fq.gz ]; then
                echo '../R1.sample.fq.gz ../R2.sample.fq.gz'
            elif [ -e ../R1.shuffle.fq.gz ]; then
                echo '../R1.shuffle.fq.gz ../R2.shuffle.fq.gz'
            elif [ -e ../R1.uniq.fq.gz ]; then
                echo '../R1.uniq.fq.gz ../R2.uniq.fq.gz'
            else
                echo '../R1.fq.gz ../R2.fq.gz'
            fi
        ) \
         \
        -o stdout \
        | bash
    " ::: ${READ_QUAL} ::: ${READ_LEN}

```

## Hinf: preprocess PacBio reads

## Hinf: reads stats

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

## Hinf: spades

## Hinf: platanus

## Hinf: quorum

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead | Kmer | RealG | EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|-----:|------:|-----:|---------:|----------:|
| Q25L60 |  336.2M | 183.7 | 319.81M |  174.7 |   4.876% |     100 | "71" | 1.83M | 1.8M |     0.98 | 0:01'03'' |
| Q30L60 | 319.47M | 174.6 | 307.56M |  168.1 |   3.728% |      98 | "71" | 1.83M | 1.8M |     0.98 | 0:01'08'' |

## Hinf: adapter filtering

## Hinf: down sampling

## Hinf: k-unitigs and anchors (sampled)

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

## Hinf: merge anchors

## Hinf: 3GS

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

## Hinf: expand anchors

* anchorLong

* contigTrim

## Hinf: final stats

* Stats

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

* quast

## Hinf: clear intermediate files

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

* FastQC

* kmergenie

## Lmon: preprocess Illumina reads

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

cd 2_illumina

anchr trim \
    --uniq \
    --sample $(( ${REAL_G} * 200 )) \
    --nosickle \
    R1.fq.gz R2.fq.gz \
    -o trim.sh
bash trim.sh

parallel --no-run-if-empty --linebuffer -k -j 3 "
    mkdir -p Q{1}L{2}
    cd Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        -q {1} -l {2} \
        \$(
            if [ -e ../R1.scythe.fq.gz ]; then
                echo '../R1.scythe.fq.gz ../R2.scythe.fq.gz'
            elif [ -e ../R1.sample.fq.gz ]; then
                echo '../R1.sample.fq.gz ../R2.sample.fq.gz'
            elif [ -e ../R1.shuffle.fq.gz ]; then
                echo '../R1.shuffle.fq.gz ../R2.shuffle.fq.gz'
            elif [ -e ../R1.uniq.fq.gz ]; then
                echo '../R1.uniq.fq.gz ../R2.uniq.fq.gz'
            else
                echo '../R1.fq.gz ../R2.fq.gz'
            fi
        ) \
         \
        -o stdout \
        | bash
    " ::: ${READ_QUAL} ::: ${READ_LEN}

```

## Lmon: reads stats

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 2944528 |    2944528 |        1 |
| Paralogs |         |            |          |
| Illumina |     151 | 2590175480 | 17153480 |
| uniq     |     151 | 2462888218 | 16310518 |
| sample   |     151 |  588905436 |  3900036 |
| Q25L60   |     151 |  457352457 |  3268580 |
| Q30L60   |     151 |  442570581 |  3281099 |

## Lmon: spades

## Lmon: platanus

## Lmon: quorum

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG | EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|------:|------:|-----:|---------:|----------:|
| Q25L60 | 457.35M | 155.3 | 362.25M |  123.0 |  20.794% |     143 | "105" | 2.94M | 5.5M |     1.87 | 0:01'17'' |
| Q30L60 | 443.02M | 150.5 | 378.29M |  128.5 |  14.611% |     139 |  "91" | 2.94M | 5.4M |     1.84 | 0:01'17'' |

## Lmon: adapter filtering

```text
#File	2_illumina/Q25L60/pe.cor.raw
#Total	2563156
#Matched	828	0.03230%
#Name	Reads	ReadsPct
Reverse_adapter	824	0.03215%
PCR_Primers	2	0.00008%
TruSeq_Adapter_Index_3	1	0.00004%
pcr_dimer	1	0.00004%
```

## Lmon: down sampling

## Lmon: k-unitigs and anchors (sampled)

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

## Lmon: merge anchors

## Lmon: final stats

* Stats

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

* quast

## Lmon: clear intermediate files

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

* FastQC

* kmergenie

## Cdif: preprocess Illumina reads

## Cdif: reads stats

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

## Cdif: spades

## Cdif: platanus

## Cdif: quorum

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead | Kmer | RealG | EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|-----:|------:|-----:|---------:|----------:|
| Q25L60 |  787.8M | 183.3 | 740.76M |  172.3 |   5.971% |     100 | "71" |  4.3M | 4.2M |     0.98 | 0:03'34'' |
| Q30L60 | 772.47M | 179.7 | 736.69M |  171.4 |   4.631% |      99 | "71" |  4.3M | 4.2M |     0.98 | 0:03'18'' |

## Cdif: adapter filtering

## Cdif: down sampling

## Cdif: k-unitigs and anchors (sampled)

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

## Cdif: merge anchors

## Cdif: final stats

* Stats

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

* quast

## Cdif: clear intermediate files

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
mkdir -p ~/data/anchr/Cjej/1_genome
cd ~/data/anchr/Cjej/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/009/085/GCF_000009085.1_ASM908v1/GCF_000009085.1_ASM908v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_002163.1${TAB}1
EOF

faops replace GCF_000009085.1_ASM908v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Cjej/Cjej.multi.fas paralogs.fas

```

SRX2107012

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
mkdir -p ~/data/anchr/lambda/1_genome
cd ~/data/anchr/lambda/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/840/245/GCF_000840245.1_ViralProj14204/GCF_000840245.1_ViralProj14204_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_001416.1${TAB}1
EOF

faops replace GCF_000840245.1_ViralProj14204_genomic.fna.gz replace.tsv genome.fa

#cp ~/data/anchr/paralogs/otherbac/Results/lambda/lambda.multi.fas paralogs.fas

```

* PacBio

```bash
mkdir -p ~/data/anchr/lambda/3_pacbio
cd ~/data/anchr/lambda/3_pacbio

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

## lambda: preprocess PacBio reads

```bash
BASE_NAME=lambda
cd ${HOME}/data/anchr/${BASE_NAME}

head -n 3000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.40x.fasta

anchr trimlong --parallel 16 -v \
    3_pacbio/pacbio.40x.fasta \
    -o 3_pacbio/pacbio.40x.trim.fasta

```

## lambda: reads stats

```bash
BASE_NAME=lambda
cd ${HOME}/data/anchr/${BASE_NAME}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat.md
#printf "| %s | %s | %s | %s |\n" \
#    $(echo "Paralogs"; faops n50 -H -S -C 1_genome/paralogs.fas;) >> stat.md
#
#printf "| %s | %s | %s | %s |\n" \
#    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
#printf "| %s | %s | %s | %s |\n" \
#    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
#
#parallel -k --no-run-if-empty -j 3 "
#    printf \"| %s | %s | %s | %s |\n\" \
#        \$( 
#            echo Q{1}L{2};
#            if [[ {1} -ge '30' ]]; then
#                faops n50 -H -S -C \
#                    2_illumina/Q{1}L{2}/R1.fq.gz \
#                    2_illumina/Q{1}L{2}/R2.fq.gz \
#                    2_illumina/Q{1}L{2}/Rs.fq.gz;
#            else
#                faops n50 -H -S -C \
#                    2_illumina/Q{1}L{2}/R1.fq.gz \
#                    2_illumina/Q{1}L{2}/R2.fq.gz;
#            fi
#        )
#    " ::: 20 25 30 35 ::: 60 \
#    >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "PacBio";    faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md

parallel -k --no-run-if-empty -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo PacBio.{};
            faops n50 -H -S -C \
                3_pacbio/pacbio.{}.fasta;
        )
    " ::: 40x 40x.trim \
    >> stat.md

cat stat.md

```

| Name            |   N50 |      Sum |    # |
|:----------------|------:|---------:|-----:|
| Genome          | 48502 |    48502 |    1 |
| PacBio          |  1325 | 11945526 | 9796 |
| PacBio.40x      |  1365 |  1896887 | 1500 |
| PacBio.40x.trim |  1452 |  1509584 | 1054 |

## lambda: 3GS

* miniasm

```bash
BASE_NAME=lambda
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p miniasm

minimap -Sw5 -L100 -m0 -t16 \
    ~/data/anchr/e_coli/anchorLong/group/11_2.long.fasta ~/data/anchr/e_coli/anchorLong/group/11_2.long.fasta \
    > miniasm/pacbio.40x.paf

sftp://wangq@wq.nju.edu.cn

miniasm miniasm/pacbio.40x.paf > miniasm/utg.noseq.gfa

miniasm -f 3_pacbio/pacbio.40x.fasta miniasm/pacbio.40x.paf \
    > miniasm/utg.gfa

awk '/^S/{print ">"$2"\n"$3}' miniasm/utg.gfa > miniasm/utg.fa

minimap 1_genome/genome.fa miniasm/utg.fa | minidot - > miniasm/utg.eps

```

