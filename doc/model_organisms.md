# Assemble genomes of model organisms by ANCHR

[TOC levels=1-3]: # " "
- [Assemble genomes of model organisms by ANCHR](#assemble-genomes-of-model-organisms-by-anchr)
- [More tools on downloading and preprocessing data](#more-tools-on-downloading-and-preprocessing-data)
    - [Extra external executables](#extra-external-executables)
    - [Other leading assemblers](#other-leading-assemblers)
    - [PacBio specific tools](#pacbio-specific-tools)
- [*Escherichia coli* str. K-12 substr. MG1655](#escherichia-coli-str-k-12-substr-mg1655)
    - [e_coli: download](#e-coli-download)
    - [e_coli: template](#e-coli-template)
    - [e_coli: run](#e-coli-run)
- [*Saccharomyces cerevisiae* S288c](#saccharomyces-cerevisiae-s288c)
    - [s288c: download](#s288c-download)
    - [s288c: template](#s288c-template)
    - [s288c: run](#s288c-run)
- [s288cH](#s288ch)
    - [s288cH: download](#s288ch-download)
    - [s288cH: template](#s288ch-template)
    - [s288cH: run](#s288ch-run)
- [*Drosophila melanogaster* iso-1](#drosophila-melanogaster-iso-1)
    - [iso_1: download](#iso-1-download)
    - [iso_1: template](#iso-1-template)
    - [iso_1: run](#iso-1-run)
- [*Caenorhabditis elegans* N2](#caenorhabditis-elegans-n2)
    - [n2: download](#n2-download)
    - [n2: template](#n2-template)
    - [n2: run](#n2-run)
- [*Arabidopsis thaliana* Col-0](#arabidopsis-thaliana-col-0)
    - [col_0: download](#col-0-download)
    - [col_0: template](#col-0-template)
    - [col_0: run](#col-0-run)
- [col_0H](#col-0h)
    - [col_0H: download](#col-0h-download)
    - [col_0H: template](#col-0h-template)
    - [col_0H: run](#col-0h-run)
- [*Oryza sativa* Japonica Group Nipponbare](#oryza-sativa-japonica-group-nipponbare)
    - [nip: download](#nip-download)
    - [nip: template](#nip-template)
    - [nip: run](#nip-run)


# More tools on downloading and preprocessing data

## Extra external executables

```bash
brew install aria2 curl                     # downloading tools

brew tap brewsci/bio
brew tap brewsci/science

brew install sratoolkit    # NCBI SRAToolkit

brew reinstall --build-from-source --without-webp gd # broken, can't find libwebp.so.6
brew reinstall --build-from-source lua@5.1
brew reinstall --build-from-source gnuplot@4
brew install mummer        # mummer need gnuplot4

brew install openblas                       # numpy

brew install python
brew install quast         # assembly quality assessment
quast --test                                # may recompile the bundled nucmer

# canu requires gnuplot 5 while mummer requires gnuplot 4
brew install --build-from-source canu

brew unlink gnuplot@4
brew install gnuplot
brew unlink gnuplot

brew link gnuplot@4 --force

brew install r
brew install kmergenie --with-maxkmer=200

brew install kmc --HEAD

brew install picard-tools
```

## Other leading assemblers

```bash
brew install spades
brew install megahit
brew install wang-q/tap/platanus

```

## PacBio specific tools

PacBio is switching its data format from `hdf5` to `bam`, but at now (early 2017) the majority of
public available PacBio data are still in formats of `.bax.h5` or `hdf5.tgz`. For dealing with these
files, PacBio releases some tools which can be installed by another specific tool, named
`pitchfork`.

Their tools *can* be compiled under macOS with Homebrew.

* Install some third party tools

```bash
brew install md5sha1sum
brew install zlib boost openblas
brew install python cmake ccache hdf5
brew install samtools

brew cleanup --force # only keep the latest version
```

* Compiling with `pitchfork`

```bash
mkdir -p ~/share/pitchfork
git clone https://github.com/PacificBiosciences/pitchfork ~/share/pitchfork
cd ~/share/pitchfork

cat <<EOF > settings.mk
HAVE_ZLIB     = $(brew --prefix)/Cellar/$(brew list --versions zlib     | sed 's/ /\//')
HAVE_BOOST    = $(brew --prefix)/Cellar/$(brew list --versions boost    | sed 's/ /\//')
HAVE_OPENBLAS = $(brew --prefix)/Cellar/$(brew list --versions openblas | sed 's/ /\//')

HAVE_PYTHON   = $(brew --prefix)/bin/python
HAVE_CMAKE    = $(brew --prefix)/bin/cmake
HAVE_CCACHE   = $(brew --prefix)/Cellar/$(brew list --versions ccache | sed 's/ /\//')/bin/ccache
HAVE_HDF5     = $(brew --prefix)/Cellar/$(brew list --versions hdf5   | sed 's/ /\//')

EOF

# fix several Makefiles
sed -i".bak" "/rsync/d" ~/share/pitchfork/ports/python/virtualenv/Makefile

sed -i".bak" "s/-- third-party\/cpp-optparse/--remote/" ~/share/pitchfork/ports/pacbio/bam2fastx/Makefile
sed -i".bak" "/third-party\/gtest/d" ~/share/pitchfork/ports/pacbio/bam2fastx/Makefile
sed -i".bak" "/ccache /d" ~/share/pitchfork/ports/pacbio/bam2fastx/Makefile

cd ~/share/pitchfork
make pip
deployment/bin/pip install --upgrade pip setuptools wheel virtualenv

make bax2bam
```

* Compiled binary files are in `~/share/pitchfork/deployment`. Run `source
  ~/share/pitchfork/deployment/setup-env.sh` will bring this path to your `$PATH`. This action would
  also pollute your bash environment, if anything went wrong, restart your terminal.

```bash
source ~/share/pitchfork/deployment/setup-env.sh

bax2bam --help
```


# *Escherichia coli* str. K-12 substr. MG1655

* Genome: INSDC [U00096.3](https://www.ncbi.nlm.nih.gov/nuccore/U00096.3)
* Taxonomy ID: [511145](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=511145)
* Proportion of paralogs (> 1000 bp): 0.0323

## e_coli: download

* Reference genome

```bash
mkdir -p ${HOME}/data/anchr/e_coli
cd ${HOME}/data/anchr/e_coli

mkdir -p 1_genome
cd 1_genome

curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=U00096.3&rettype=fasta&retmode=txt" \
    > U00096.fa
# simplify header, remove .3
cat U00096.fa \
    | perl -nl -e '
        /^>(\w+)/ and print qq{>$1} and next;
        print;
    ' \
    > genome.fa

cp ${HOME}/data/anchr/paralogs/model/Results/e_coli/e_coli.multi.fas paralogs.fas
```

* Illumina

```bash
cd ${HOME}/data/anchr/e_coli

mkdir -p 2_illumina
cd 2_illumina

aria2c -x 9 -s 3 -c ftp://webdata:webdata@ussd-ftp.illumina.com/Data/SequencingRuns/MG1655/MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz
aria2c -x 9 -s 3 -c ftp://webdata:webdata@ussd-ftp.illumina.com/Data/SequencingRuns/MG1655/MiSeq_Ecoli_MG1655_110721_PF_R2.fastq.gz

ln -s MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz R1.fq.gz
ln -s MiSeq_Ecoli_MG1655_110721_PF_R2.fastq.gz R2.fq.gz

```

* PacBio

    [Here](https://github.com/PacificBiosciences/DevNet/wiki/E.-coli-Bacterial-Assembly) PacBio
    provides a 7 GB file for *E. coli* (20 kb library), which is gathered with RS II and the P6C4
    reagent.

```bash
cd ${HOME}/data/anchr/e_coli

mkdir -p 3_pacbio
cd 3_pacbio

aria2c -x 9 -s 3 -c https://s3.amazonaws.com/files.pacb.com/datasets/secondary-analysis/e-coli-k12-P6C4/p6c4_ecoli_RSII_DDR2_with_15kb_cut_E01_1.tar.gz

tar xvfz p6c4_ecoli_RSII_DDR2_with_15kb_cut_E01_1.tar.gz

# Optional, a human readable .metadata.xml file
#xmllint --format E01_1/m141013_011508_sherri_c100709962550000001823135904221533_s1_p0.metadata.xml \
#    > m141013.metadata.xml

# convert .bax.h5 to .subreads.bam
mkdir -p ~/data/anchr/e_coli/3_pacbio/bam
cd ~/data/anchr/e_coli/3_pacbio/bam

source ~/share/pitchfork/deployment/setup-env.sh
bax2bam ../E01_1/Analysis_Results/*.bax.h5

# convert .subreads.bam to fasta
mkdir -p ~/data/anchr/e_coli/3_pacbio/fasta

samtools fasta \
    ~/data/anchr/e_coli/3_pacbio/bam/m141013*.subreads.bam \
    > ~/data/anchr/e_coli/3_pacbio/fasta/m141013.fasta

cd ~/data/anchr/e_coli/3_pacbio
cat fasta/m141013.fasta \
    | faops dazz -l 0 -p long stdin pacbio.fasta

```

## e_coli: template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=e_coli

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 4641652 \
    --trim2 "--dedupe --tile" \
    --sample2 300 \
    --cov2 "40 80" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --cov3 "40 80 all" \
    --qual3 "raw trim" \
    --mergereads \
    --ecphase "1,2,3" \
    --megahit \
    --spades \
    --insertsize \
    --parallel 16

```

## e_coli: run

* preprocessing

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=e_coli

cd ${WORKING_DIR}/${BASE_NAME}

# Illumina QC
bash 2_fastqc.sh
bash 2_kmergenie.sh

# insert sizes
bash 2_insertSize.sh

# preprocess Illumina reads
bash 2_trim.sh

# preprocess PacBio reads
bash 3_trimlong.sh

# reads stats
bash 9_statReads.sh

```

Table: statInsertSize

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| genome.bbtools  | 321.9 |    298 | 968.5 |                         47.99% |
| tadpole.bbtools | 295.6 |    296 |  21.1 |                         40.57% |
| genome.picard   | 298.2 |    298 |  18.0 |                             FR |
| tadpole.picard  | 294.9 |    296 |  21.7 |                             FR |

Table: statReads

| Name           |     N50 |     Sum |        # |
|:---------------|--------:|--------:|---------:|
| Genome         | 4641652 | 4641652 |        1 |
| Paralogs       |    1934 |  195673 |      106 |
| Illumina       |     151 |   1.73G | 11458940 |
| clumpify       |     151 |   1.73G | 11439000 |
| filteredbytile |     151 |   1.67G | 11057522 |
| sample         |     151 |   1.39G |  9221826 |
| trim           |     149 |   1.19G |  8654072 |
| filter         |     149 |   1.19G |  8653636 |
| trimmed        |     149 |   1.19G |  8653636 |
| Q20L60         |     149 |   1.17G |  8534030 |
| Q25L60         |     148 |    1.1G |  8293111 |
| Q30L60         |     128 | 922.36M |  7768475 |
| PacBio         |   13982 | 748.51M |    87225 |
| X40.raw        |   14030 | 185.68M |    22336 |
| X40.trim       |   13702 | 169.38M |    19468 |
| X80.raw        |   13990 | 371.34M |    44005 |
| X80.trim       |   13632 | 339.51M |    38725 |
| Xall.raw       |   13982 | 748.51M |    87225 |
| Xall.trim      |   13646 | 689.43M |    77693 |

```text
#trim
#Matched        15581   0.16896%
#Name   Reads   ReadsPct
pcr_dimer       7017    0.07609%
PCR_Primers     1238    0.01342%
```

```text
#filter
#Matched        436     0.00504%
#Name   Reads   ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome  434     0.00501%
```

* mergereads

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bash 2_mergereads.sh

```

Table: statMergeReads

| Name          | N50 |    Sum |       # |
|:--------------|----:|-------:|--------:|
| clumped       | 149 |  1.19G | 8652794 |
| ecco          | 149 |  1.19G | 8652794 |
| eccc          | 149 |  1.19G | 8652794 |
| ecct          | 149 |  1.18G | 8606874 |
| extended      | 189 |  1.53G | 8606874 |
| merged        | 339 |  1.43G | 4246486 |
| unmerged.raw  | 174 |  16.6M |  113902 |
| unmerged.trim | 174 | 16.59M |  113840 |
| U1            | 181 |  8.73M |   56920 |
| U2            | 168 |  7.86M |   56920 |
| Us            |   0 |      0 |       0 |
| pe.cor        | 338 |  1.45G | 8606812 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 271.6 |    277 |  23.9 |         10.85% |
| ihist.merge.txt  | 337.7 |    338 |  19.3 |         98.68% |


* quorum

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bash 2_quorum.sh
bash 9_statQuorum.sh

```

Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q20L60 | 252.8 |  236.5 |    6.44% |     138 | "95" | 4.64M | 4.61M |     0.99 | 0:02'45'' |
| Q25L60 | 237.0 |  227.7 |    3.91% |     134 | "87" | 4.64M | 4.57M |     0.98 | 0:02'36'' |
| Q30L60 | 198.8 |  194.7 |    2.08% |     122 | "71" | 4.64M | 4.56M |     0.98 | 0:02'21'' |

* down sampling, k-unitigs and anchors

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bash 4_downSampling.sh

bash 4_kunitigs.sh
bash 4_anchors.sh
bash 9_statAnchors.sh 4_kunitigs statKunitigsAnchors.md

bash 4_tadpole.sh
bash 4_tadpoleAnchors.sh
bash 9_statAnchors.sh 4_tadpole statTadpoleAnchors.md

```

Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000 |   40.0 |  97.10% |     10663 | 4.46M |  610 |        78 | 103.08K | 1629 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'07'' |
| Q20L60X40P001 |   40.0 |  97.12% |     12006 | 4.46M |  586 |        87 |  95.76K | 1529 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'11'' | 0:01'05'' |
| Q20L60X40P002 |   40.0 |  97.14% |     11982 | 4.47M |  584 |        73 |  88.13K | 1490 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'58'' |
| Q20L60X40P003 |   40.0 |  97.06% |     10969 | 4.47M |  621 |        79 |  93.33K | 1530 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'59'' |
| Q20L60X40P004 |   40.0 |  97.01% |     10969 | 4.45M |  616 |       102 | 105.04K | 1539 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'11'' | 0:00'58'' |
| Q20L60X80P000 |   80.0 |  95.17% |      6044 | 4.37M | 1005 |        59 | 103.39K | 2158 |   75.0 | 5.0 |  20.0 | 135.0 | "31,41,51,61,71,81" | 0:01'52'' | 0:01'01'' |
| Q20L60X80P001 |   80.0 |  95.12% |      6462 | 4.37M |  964 |        53 |  92.82K | 2060 |   76.0 | 5.0 |  20.0 | 136.5 | "31,41,51,61,71,81" | 0:01'51'' | 0:01'01'' |
| Q25L60X40P000 |   40.0 |  97.88% |     19064 | 4.49M |  395 |       102 |  90.09K | 1325 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'08'' | 0:01'10'' |
| Q25L60X40P001 |   40.0 |  98.00% |     17219 | 4.49M |  392 |        89 |   86.6K | 1317 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'08'' | 0:01'05'' |
| Q25L60X40P002 |   40.0 |  97.98% |     18726 |  4.5M |  388 |        75 |  78.53K | 1348 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'09'' | 0:01'08'' |
| Q25L60X40P003 |   40.0 |  98.01% |     17678 | 4.51M |  406 |        59 |  66.57K | 1391 |   38.5 | 2.5 |  10.3 |  69.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:01'00'' |
| Q25L60X40P004 |   40.0 |  98.02% |     19470 | 4.49M |  403 |       119 |  93.98K | 1355 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'11'' | 0:01'08'' |
| Q25L60X80P000 |   80.0 |  97.22% |     11544 | 4.48M |  581 |        58 |  66.39K | 1452 |   77.0 | 5.0 |  20.0 | 138.0 | "31,41,51,61,71,81" | 0:01'51'' | 0:01'05'' |
| Q25L60X80P001 |   80.0 |  97.30% |     11368 | 4.48M |  594 |        55 |  64.13K | 1480 |   77.0 | 5.0 |  20.0 | 138.0 | "31,41,51,61,71,81" | 0:01'53'' | 0:01'04'' |
| Q30L60X40P000 |   40.0 |  98.55% |     30917 | 4.48M |  252 |      1063 | 130.04K | 1312 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'12'' | 0:01'07'' |
| Q30L60X40P001 |   40.0 |  98.55% |     31093 |  4.5M |  246 |       900 | 129.92K | 1375 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'10'' |
| Q30L60X40P002 |   40.0 |  98.53% |     33961 | 4.49M |  246 |       962 | 135.76K | 1309 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'11'' | 0:01'07'' |
| Q30L60X40P003 |   40.0 |  98.52% |     32905 | 4.48M |  259 |       997 | 153.96K | 1345 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'16'' | 0:01'18'' |
| Q30L60X80P000 |   80.0 |  98.55% |     30968 | 4.51M |  234 |       789 |  73.73K | 1112 |   78.0 | 4.0 |  20.0 | 135.0 | "31,41,51,61,71,81" | 0:01'54'' | 0:01'23'' |
| Q30L60X80P001 |   80.0 |  98.49% |     32038 | 4.51M |  235 |        84 |  63.32K | 1107 |   78.0 | 4.0 |  20.0 | 135.0 | "31,41,51,61,71,81" | 0:01'57'' | 0:01'16'' |

Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|----:|----------:|-------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000 |   40.0 |  98.26% |     29350 | 4.51M | 252 |        69 | 83.13K | 1296 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'02'' | 0:01'11'' |
| Q20L60X40P001 |   40.0 |  98.30% |     34571 | 4.51M | 221 |        61 | 66.47K | 1165 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'01'' | 0:01'12'' |
| Q20L60X40P002 |   40.0 |  98.23% |     33404 | 4.51M | 242 |        61 | 65.54K | 1179 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'02'' | 0:01'16'' |
| Q20L60X40P003 |   40.0 |  98.26% |     31125 | 4.51M | 238 |        63 | 73.07K | 1261 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'03'' | 0:01'15'' |
| Q20L60X40P004 |   40.0 |  98.23% |     30952 | 4.51M | 246 |        60 | 65.17K | 1185 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'02'' | 0:01'15'' |
| Q20L60X80P000 |   80.0 |  97.72% |     17859 |  4.5M | 401 |        58 | 61.93K | 1153 |   77.0 | 4.0 |  20.0 | 133.5 | "31,41,51,61,71,81" | 0:01'30'' | 0:01'10'' |
| Q20L60X80P001 |   80.0 |  97.72% |     18115 | 4.51M | 407 |        52 | 54.77K | 1136 |   77.0 | 4.0 |  20.0 | 133.5 | "31,41,51,61,71,81" | 0:02'15'' | 0:01'02'' |
| Q25L60X40P000 |   40.0 |  98.41% |     31115 | 4.51M | 249 |        68 | 78.47K | 1302 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'03'' | 0:01'17'' |
| Q25L60X40P001 |   40.0 |  98.42% |     32503 |  4.5M | 233 |       100 | 93.08K | 1313 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'55'' | 0:01'07'' |
| Q25L60X40P002 |   40.0 |  98.48% |     34333 | 4.51M | 220 |        67 | 78.19K | 1326 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'59'' | 0:01'14'' |
| Q25L60X40P003 |   40.0 |  98.46% |     32529 | 4.52M | 240 |        66 | 81.72K | 1349 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'01'' | 0:01'07'' |
| Q25L60X40P004 |   40.0 |  98.45% |     37627 | 4.51M | 222 |        67 |  72.9K | 1240 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'58'' | 0:01'11'' |
| Q25L60X80P000 |   80.0 |  98.15% |     25654 |  4.5M | 297 |        66 | 68.38K | 1131 |   77.0 | 4.0 |  20.0 | 133.5 | "31,41,51,61,71,81" | 0:01'29'' | 0:01'11'' |
| Q25L60X80P001 |   80.0 |  98.18% |     25860 | 4.51M | 304 |        53 | 55.02K | 1139 |   78.0 | 4.0 |  20.0 | 135.0 | "31,41,51,61,71,81" | 0:01'59'' | 0:01'15'' |
| Q30L60X40P000 |   40.0 |  98.49% |     30894 | 4.52M | 256 |        77 |  80.6K | 1467 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:01'26'' | 0:01'11'' |
| Q30L60X40P001 |   40.0 |  98.51% |     28695 | 4.48M | 282 |       899 | 158.1K | 1561 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'31'' | 0:01'12'' |
| Q30L60X40P002 |   40.0 |  98.54% |     31115 | 4.52M | 239 |       396 | 90.37K | 1508 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:01'22'' | 0:01'10'' |
| Q30L60X40P003 |   40.0 |  98.49% |     31653 | 4.51M | 241 |       262 | 88.83K | 1514 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:01'19'' | 0:01'13'' |
| Q30L60X80P000 |   80.0 |  98.53% |     33941 | 4.51M | 225 |       789 | 78.83K | 1198 |   78.0 | 4.0 |  20.0 | 135.0 | "31,41,51,61,71,81" | 0:01'53'' | 0:01'22'' |
| Q30L60X80P001 |   80.0 |  98.57% |     36287 | 4.52M | 204 |        53 | 58.04K | 1195 |   78.0 | 5.0 |  20.0 | 139.5 | "31,41,51,61,71,81" | 0:01'57'' | 0:01'16'' |


* down sampling mergereads

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bash 6_downSampling.sh

bash 6_kunitigs.sh
bash 6_anchors.sh
bash 9_statMRAnchors.sh 6_kunitigs statMRKunitigsAnchors.md

bash 6_tadpole.sh
bash 6_tadpoleAnchors.sh
bash 9_statMRAnchors.sh 6_tadpole statMRTadpoleAnchors.md

bash 6_megahit.sh
bash 6_megahitAnchors.sh
bash 9_statMRAnchors.sh 6_megahit statMRMegahitAnchors.md

bash 6_spades.sh
bash 6_spadesAnchors.sh
bash 9_statMRAnchors.sh 6_spades statMRSpadesAnchors.md

```

Table: statMRKunitigsAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  97.19% |     43298 | 4.49M | 182 |       137 | 58.61K | 434 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'36'' | 0:01'02'' |
| MRX40P001 |   40.0 |  97.06% |     39097 | 4.49M | 199 |       124 |  52.2K | 467 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'30'' | 0:01'03'' |
| MRX40P002 |   40.0 |  97.11% |     41874 | 4.48M | 195 |       158 | 67.65K | 434 |   38.0 | 1.0 |  11.7 |  61.5 | "31,41,51,61,71,81" | 0:01'29'' | 0:01'05'' |
| MRX40P003 |   40.0 |  97.17% |     43017 | 4.48M | 194 |       148 | 63.21K | 451 |   38.0 | 1.0 |  11.7 |  61.5 | "31,41,51,61,71,81" | 0:01'28'' | 0:01'08'' |
| MRX40P004 |   40.0 |  97.25% |     43409 | 4.49M | 173 |       131 | 53.75K | 422 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'27'' | 0:01'07'' |
| MRX40P005 |   40.0 |  97.11% |     39010 | 4.49M | 194 |       137 | 59.21K | 459 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'28'' | 0:01'05'' |
| MRX40P006 |   40.0 |  97.18% |     47625 |  4.5M | 180 |       122 | 47.63K | 425 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'27'' | 0:01'02'' |
| MRX80P000 |   80.0 |  96.63% |     28757 | 4.48M | 279 |       114 | 63.21K | 617 |   77.0 | 3.0 |  20.0 | 129.0 | "31,41,51,61,71,81" | 0:02'29'' | 0:01'12'' |
| MRX80P001 |   80.0 |  96.68% |     27839 | 4.49M | 266 |       114 |  57.6K | 581 |   77.0 | 3.0 |  20.0 | 129.0 | "31,41,51,61,71,81" | 0:02'30'' | 0:01'06'' |
| MRX80P002 |   80.0 |  96.76% |     28530 | 4.49M | 251 |       119 | 60.29K | 571 |   77.0 | 3.0 |  20.0 | 129.0 | "31,41,51,61,71,81" | 0:02'28'' | 0:01'07'' |

Table: statMRTadpoleAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  97.33% |     63064 |  4.5M | 125 |       136 | 38.05K | 279 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'37'' | 0:01'02'' |
| MRX40P001 |   40.0 |  97.28% |     59495 |  4.5M | 129 |       129 | 32.47K | 267 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'38'' | 0:01'00'' |
| MRX40P002 |   40.0 |  97.31% |     60689 |  4.5M | 127 |       171 | 39.21K | 255 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'36'' | 0:00'59'' |
| MRX40P003 |   40.0 |  97.31% |     63096 |  4.5M | 125 |       152 | 38.33K | 270 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'22'' | 0:00'59'' |
| MRX40P004 |   40.0 |  97.31% |     67185 |  4.5M | 123 |       129 | 34.28K | 262 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'23'' | 0:00'58'' |
| MRX40P005 |   40.0 |  97.28% |     63497 |  4.5M | 123 |       146 | 36.11K | 256 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'33'' | 0:00'58'' |
| MRX40P006 |   40.0 |  97.35% |     63512 |  4.5M | 127 |       144 | 35.57K | 263 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'42'' | 0:00'59'' |
| MRX80P000 |   80.0 |  97.13% |     50672 |  4.5M | 153 |       114 | 36.09K | 322 |   78.0 | 2.0 |  20.0 | 126.0 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'05'' |
| MRX80P001 |   80.0 |  97.17% |     52149 | 4.51M | 152 |       105 | 31.71K | 312 |   78.0 | 3.0 |  20.0 | 130.5 | "31,41,51,61,71,81" | 0:02'16'' | 0:01'01'' |
| MRX80P002 |   80.0 |  97.14% |     53538 |  4.5M | 154 |       111 | 33.35K | 317 |   78.0 | 2.5 |  20.0 | 128.2 | "31,41,51,61,71,81" | 0:02'14'' | 0:01'13'' |

Table: statMRMegahitAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper | Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|-----:|----------:|----------:|
| MRX40P000 |   40.0 |  97.91% |     24891 | 4.45M | 320 |       567 | 91.87K | 452 |   39.0 | 1.0 |  12.0 |  63.0 | null | 0:00'59'' | 0:00'59'' |
| MRX40P001 |   40.0 |  97.91% |     28189 | 4.46M | 316 |       315 |  81.8K | 445 |   39.0 | 1.0 |  12.0 |  63.0 | null | 0:01'00'' | 0:01'05'' |
| MRX40P002 |   40.0 |  97.98% |     27929 | 4.46M | 281 |       618 | 85.89K | 411 |   39.0 | 1.0 |  12.0 |  63.0 | null | 0:01'01'' | 0:00'58'' |
| MRX40P003 |   40.0 |  97.97% |     28585 | 4.46M | 270 |       699 | 85.31K | 399 |   39.0 | 1.0 |  12.0 |  63.0 | null | 0:01'04'' | 0:01'04'' |
| MRX40P004 |   40.0 |  97.96% |     28865 | 4.47M | 275 |       413 | 77.05K | 404 |   39.0 | 1.0 |  12.0 |  63.0 | null | 0:01'04'' | 0:00'59'' |
| MRX40P005 |   40.0 |  97.93% |     34299 | 4.45M | 280 |       666 | 90.11K | 411 |   39.0 | 1.0 |  12.0 |  63.0 | null | 0:01'03'' | 0:01'04'' |
| MRX40P006 |   40.0 |  97.96% |     29244 | 4.46M | 293 |       534 | 84.31K | 427 |   39.0 | 1.0 |  12.0 |  63.0 | null | 0:01'05'' | 0:01'00'' |
| MRX80P000 |   80.0 |  97.94% |     48774 |  4.5M | 165 |       300 | 45.92K | 291 |   78.0 | 2.0 |  20.0 | 126.0 | null | 0:01'42'' | 0:01'06'' |
| MRX80P001 |   80.0 |  97.99% |     48693 |  4.5M | 153 |       992 | 47.09K | 277 |   78.0 | 2.0 |  20.0 | 126.0 | null | 0:01'42'' | 0:01'06'' |
| MRX80P002 |   80.0 |  97.94% |     49553 |  4.5M | 167 |       397 |  46.4K | 297 |   78.0 | 2.0 |  20.0 | 126.0 | null | 0:01'41'' | 0:01'05'' |

Table: statMRSpadesAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper | Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|-----:|----------:|----------:|
| MRX40P000 |   40.0 |  98.32% |     27959 | 4.47M | 282 |       664 | 84.16K | 375 |   39.0 | 1.0 |  12.0 |  63.0 | null | 0:25'01'' | 0:00'47'' |
| MRX40P001 |   40.0 |  98.28% |     31601 | 4.47M | 293 |       469 | 80.08K | 391 |   39.0 | 1.0 |  12.0 |  63.0 | null | 0:23'58'' | 0:00'47'' |
| MRX40P002 |   40.0 |  98.33% |     35035 | 4.48M | 253 |       661 | 79.51K | 352 |   39.0 | 1.0 |  12.0 |  63.0 | null | 0:25'49'' | 0:00'47'' |
| MRX40P003 |   40.0 |  98.33% |     35671 | 4.48M | 249 |       699 | 77.07K | 350 |   39.0 | 1.0 |  12.0 |  63.0 | null | 0:25'48'' | 0:00'45'' |
| MRX40P004 |   40.0 |  98.33% |     33504 | 4.48M | 249 |       627 | 71.97K | 344 |   39.0 | 1.0 |  12.0 |  63.0 | null | 0:24'15'' | 0:00'45'' |
| MRX40P005 |   40.0 |  98.34% |     39831 | 4.47M | 247 |       686 | 83.65K | 343 |   39.0 | 1.0 |  12.0 |  63.0 | null | 0:23'20'' | 0:00'46'' |
| MRX40P006 |   40.0 |  98.35% |     37582 | 4.48M | 247 |       583 | 75.15K | 344 |   39.0 | 1.0 |  12.0 |  63.0 | null | 0:26'02'' | 0:00'46'' |
| MRX80P000 |   80.0 |  98.32% |     64647 | 4.52M | 130 |       436 | 37.66K | 216 |   79.0 | 2.0 |  20.0 | 127.5 | null | 0:26'34'' | 0:00'49'' |
| MRX80P001 |   80.0 |  98.37% |     65291 | 4.52M | 125 |       714 | 39.64K | 217 |   79.0 | 2.0 |  20.0 | 127.5 | null | 0:21'13'' | 0:00'49'' |
| MRX80P002 |   80.0 |  98.29% |     78365 | 4.52M | 124 |       526 | 37.33K | 212 |   79.0 | 2.0 |  20.0 | 127.5 | null | 0:21'31'' | 0:00'50'' |

* merge anchors

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bash 7_mergeAnchors.sh 4_kunitigs 7_mergeKunitigsAnchors
bash 7_mergeAnchors.sh 4_tadpole 7_mergeTadpoleAnchors

bash 7_mergeAnchors.sh 6_kunitigs 7_mergeMRKunitigsAnchors
bash 7_mergeAnchors.sh 6_tadpole 7_mergeMRTadpoleAnchors

bash 7_mergeAnchors.sh 6_megahit 7_mergeMRMegahitAnchors
bash 7_mergeAnchors.sh 6_spades 7_mergeMRSpadesAnchors

bash 7_mergeAnchors.sh 7_merge 7_mergeAnchors

# anchor sort on ref
for D in 7_mergeAnchors 7_mergeKunitigsAnchors 7_mergeTadpoleAnchors 7_mergeMRKunitigsAnchors 7_mergeMRTadpoleAnchors 7_mergeMRMegahitAnchors 7_mergeMRSpadesAnchors; do
    if [ ! -d ${D} ]; then
        continue;
    fi
    if [ -e ${D}/anchor.sort.fa ]; then
        continue;
    fi
    bash ~/Scripts/cpan/App-Anchr/share/sort_on_ref.sh \
        ${D}/anchor.merge.fasta 1_genome/genome.fa ${D}/anchor.sort
    nucmer -l 200 1_genome/genome.fa ${D}/anchor.sort.fa
    mummerplot --postscript out.delta -p anchor.sort --small
    
    # mummerplot files
    rm *.[fr]plot
    rm out.delta
    rm *.gp
    mv anchor.sort.ps ${D}/
    
    # minidot
    minimap ${D}/anchor.sort.fa 1_genome/genome.fa \
        | minidot - > ${D}/anchor.minidot.eps
done

```

* canu

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bash 5_canu.sh
bash 9_statCanu.sh

```

Table: statCanu

| Name                |     N50 |     Sum |     # |
|:--------------------|--------:|--------:|------:|
| Genome              | 4641652 | 4641652 |     1 |
| Paralogs            |    1934 |  195673 |   106 |
| X40.raw.corrected   |   13465 |    151M | 17096 |
| X40.trim.corrected  |   13372 | 148.63M | 16928 |
| X80.raw.corrected   |   16977 | 174.46M | 10692 |
| X80.trim.corrected  |   16820 | 175.59M | 10873 |
| Xall.raw.corrected  |   20324 | 171.35M |  8305 |
| Xall.trim.corrected |   20143 | 173.96M |  8468 |
| X40.raw.contig      | 4674150 | 4674150 |     1 |
| X40.trim.contig     | 4674046 | 4674046 |     1 |
| X80.raw.contig      | 4658166 | 4658166 |     1 |
| X80.trim.contig     | 4657933 | 4657933 |     1 |
| Xall.raw.contig     | 4670118 | 4670118 |     1 |
| Xall.trim.contig    | 4670240 | 4670240 |     1 |

* expand anchors

三代 reads 里有一个常见的错误, 即单一 ZMW 里的测序结果中, 接头序列部分的测序结果出现了较多的错误,
因此并没有将接头序列去除干净, 形成的 subreads 里含有多份基因组上同一片段, 它们之间以接头序列为间隔.

`anchr group` 命令默认会将这种三代的 reads 去除. `--keep` 选项会留下这种 reads, 这适用于组装好的三代序列.

```text
      ===
------------>
             )
  <----------
      ===
```

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bash 7_anchorLong.sh 7_mergeAnchors/anchor.merge.fasta 5_canu_Xall-trim/${BASE_NAME}.correctedReads.fasta.gz

# false strand
cat 7_anchorLong/group/*.ovlp.tsv \
    | perl -nla -e '/anchor.+long/ or next; print $F[0] if $F[8] == 1;' \
    | sort | uniq -c

bash 7_anchorFill.sh 7_anchorLong/contig.fasta 5_canu_Xall-trim/${BASE_NAME}.contigs.fasta

```

* spades and platanus

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bash 8_spades.sh
bash 8_megahit.sh
bash 8_platanus.sh

```

* final stats

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bash 9_statFinal.sh
bash 9_quast.sh

# bash 0_cleanup.sh

```

Table: statFinal

| Name                             |     N50 |     Sum |    # |
|:---------------------------------|--------:|--------:|-----:|
| Genome                           | 4641652 | 4641652 |    1 |
| Paralogs                         |    1934 |  195673 |  106 |
| 7_mergeKunitigsAnchors.anchors   |   63202 | 4530942 |  127 |
| 7_mergeKunitigsAnchors.others    |    1085 |  310292 |  268 |
| 7_mergeTadpoleAnchors.anchors    |   65390 | 4529192 |  122 |
| 7_mergeTadpoleAnchors.others     |    1085 |  213165 |  175 |
| 7_mergeMRKunitigsAnchors.anchors |   67268 | 4519178 |  115 |
| 7_mergeMRKunitigsAnchors.others  |    1185 |   51691 |   45 |
| 7_mergeMRTadpoleAnchors.anchors  |   82715 | 4518529 |  106 |
| 7_mergeMRTadpoleAnchors.others   |    1236 |   29092 |   25 |
| 7_mergeMRMegahitAnchors.anchors  |   78519 | 4525631 |  110 |
| 7_mergeMRMegahitAnchors.others   |    1059 |  151466 |  149 |
| 7_mergeMRSpadesAnchors.anchors   |  122470 | 5186525 |   92 |
| 7_mergeMRSpadesAnchors.others    |    1118 |  148498 |  138 |
| 7_mergeAnchors.anchors           |  135551 | 5542510 |   91 |
| 7_mergeAnchors.others            |    1104 |  517469 |  435 |
| anchorLong                       |  148442 | 5435808 |   75 |
| anchorFill                       |  878510 | 7934304 |   20 |
| canu_X40-raw                     | 4674150 | 4674150 |    1 |
| canu_X40-trim                    | 4674046 | 4674046 |    1 |
| canu_X80-raw                     | 4658166 | 4658166 |    1 |
| canu_X80-trim                    | 4657933 | 4657933 |    1 |
| canu_Xall-raw                    | 4670118 | 4670118 |    1 |
| canu_Xall-trim                   | 4670240 | 4670240 |    1 |
| spades.contig                    |  117644 | 4665739 |  311 |
| spades.scaffold                  |  132608 | 4665779 |  307 |
| spades.non-contained             |  125617 | 4585700 |   91 |
| spades.anchor                    |  125552 | 4539555 |   69 |
| megahit.contig                   |   67382 | 4579520 |  205 |
| megahit.non-contained            |   67382 | 4553887 |  124 |
| megahit.anchor                   |   67325 | 4525248 |  114 |
| platanus.contig                  |   16464 | 4674383 | 1017 |
| platanus.scaffold                |  133012 | 4574920 |  142 |
| platanus.non-contained           |  133012 | 4556916 |   63 |
| platanus.anchor                  |  132960 | 4542760 |   67 |


# *Saccharomyces cerevisiae* S288c

* Genome: [Ensembl 82](http://sep2015.archive.ensembl.org/Saccharomyces_cerevisiae/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.058

## s288c: download

* Reference genome

```bash
mkdir -p ${HOME}/data/anchr/s288c
cd ${HOME}/data/anchr/s288c

mkdir -p 1_genome
cd 1_genome

wget -N ftp://ftp.ensembl.org/pub/release-82/fasta/saccharomyces_cerevisiae/dna/Saccharomyces_cerevisiae.R64-1-1.dna_sm.toplevel.fa.gz
faops order Saccharomyces_cerevisiae.R64-1-1.dna_sm.toplevel.fa.gz \
    <(for chr in {I,II,III,IV,V,VI,VII,VIII,IX,X,XI,XII,XIII,XIV,XV,XVI,Mito}; do echo $chr; done) \
    genome.fa

cp ~/data/anchr/paralogs/model/Results/s288c/s288c.multi.fas 1_genome/paralogs.fas
```

* Illumina MiSeq (PE150)

    [ERX1999216](https://www.ncbi.nlm.nih.gov/sra/ERX1999216) ERR1938683

    PRJEB19900

```bash
cd ${HOME}/data/anchr/s288c

mkdir -p 2_illumina
cd 2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR193/003/ERR1938683/ERR1938683_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR193/003/ERR1938683/ERR1938683_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
9a635e035371a81c8538698a54a24bfc ERR1938683_1.fastq.gz
48f362c1d7a95b996bc7931669b1d74b ERR1938683_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s ERR1938683_1.fastq.gz R1.fq.gz
ln -s ERR1938683_2.fastq.gz R2.fq.gz
```

* PacBio

    PacBio provides a dataset of *S. cerevisiae* strain
    [W303](https://github.com/PacificBiosciences/DevNet/wiki/Saccharomyces-cerevisiae-W303-Assembly-Contigs),
    while the reference strain S288c is not provided. So we use the dataset from
    [project PRJEB7245](https://www.ncbi.nlm.nih.gov/bioproject/PRJEB7245),
    [study ERP006949](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=ERP006949), and
    [sample SAMEA4461732](https://www.ncbi.nlm.nih.gov/biosample/SAMEA4461732). They're gathered
    with RS II and P6C4.

```bash
cd ${HOME}/data/anchr/s288c

mkdir -p 3_pacbio
cd 3_pacbio

# download from sra
cat <<EOF > hdf5.txt
http://sra-download.ncbi.nlm.nih.gov/srapub_files/ERR1655118_ERR1655118_hdf5.tgz
EOF

aria2c -x 9 -s 3 -c -i hdf5.txt

# untar
mkdir -p ~/data/anchr/s288c/3_pacbio/untar
cd ~/data/anchr/s288c/3_pacbio
tar xvfz ERR1655118_ERR1655118_hdf5.tgz --directory untar

# convert .bax.h5 to .subreads.bam
mkdir -p ~/data/anchr/s288c/3_pacbio/bam
cd ~/data/anchr/s288c/3_pacbio/bam

source ~/share/pitchfork/deployment/setup-env.sh
for movie in m150412;
do 
    bax2bam ~/data/anchr/s288c/3_pacbio/untar/${movie}*.bax.h5
done

# convert .subreads.bam to fasta
mkdir -p ~/data/anchr/s288c/3_pacbio/fasta

for movie in m150412;
do
    if [ ! -e ~/data/anchr/s288c/3_pacbio/bam/${movie}*.subreads.bam ]; then
        continue
    fi

    samtools fasta \
        ~/data/anchr/s288c/3_pacbio/bam/${movie}*.subreads.bam \
        > ~/data/anchr/s288c/3_pacbio/fasta/${movie}.fasta
done

cd ~/data/anchr/s288c
cat 3_pacbio/fasta/*.fasta \
    | faops dazz -l 0 -p long stdin 3_pacbio/pacbio.fasta

```

* 在酿酒酵母中, 有下列几组完全相同的序列, 它们都是新近发生的片段重复:

    * I:216563-218385, VIII:537165-538987
    * I:223713-224783, VIII:550350-551420
    * IV:528442-530427, IV:532327-534312, IV:536212-538197
    * IV:530324-531519, IV:534209-535404
    * IV:5645-7725, X:738076-740156
    * IV:7810-9432, X:736368-737990
    * IX:9683-11043, X:9666-11026
    * IV:1244112-1245373, XV:575980-577241
    * VIII:212266-214124, VIII:214264-216122
    * IX:11366-14953, X:11349-14936
    * XII:468935-470576, XII:472587-474228, XII:482167-483808, XII:485819-487460,
    * XII:483798-485798, XII:487450-489450

## s288c: template

* Rsync to hpcc

```bash
rsync -avP \
    --exclude="*_hdf5.tgz" \
    ~/data/anchr/s288c/ \
    wangq@202.119.37.251:data/anchr/s288c

#rsync -avP wangq@202.119.37.251:data/anchr/s288c/ ~/data/anchr/s288c

```

* template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=s288c
QUEUE_NAME=mpi

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 12157105 \
    --is_euk \
    --trim2 "--dedupe" \
    --cov2 "40 60 80 all" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --cov3 "all" \
    --qual3 "trim" \
    --mergereads \
    --ecphase "1,2,3" \
    --insertsize \
    --parallel 24

```

## s288c: run

```bash
# Illumina QC
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_fastqc" "bash 2_fastqc.sh"
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_kmergenie" "bash 2_kmergenie.sh"

# insert size
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_insertSize" "bash 2_insertSize.sh"

# preprocess Illumina reads
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_trim" "bash 2_trim.sh"

# preprocess PacBio reads
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-3_trimlong" "bash 3_trimlong.sh"

# reads stats
bsub -w "ended(${BASE_NAME}-2_trim) && ended(${BASE_NAME}-3_trimlong)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_statReads" "bash 9_statReads.sh"

# merge reads
bsub -w "done(${BASE_NAME}-2_trim)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_mergereads" "bash 2_mergereads.sh"

# spades, megahit, and platanus
bsub -w "done(${BASE_NAME}-2_trim)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-8_spades" "bash 8_spades.sh"

bsub -w "done(${BASE_NAME}-2_trim)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-8_megahit" "bash 8_megahit.sh"

bsub -w "done(${BASE_NAME}-2_trim)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-8_platanus" "bash 8_platanus.sh"

# quorum
bsub -w "done(${BASE_NAME}-2_trim)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_quorum" "bash 2_quorum.sh"
bsub -w "done(${BASE_NAME}-2_quorum)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_statQuorum" "bash 9_statQuorum.sh"

# down sampling, k-unitigs and anchors
bsub -w "done(${BASE_NAME}-2_quorum)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-4_downSampling" "bash 4_downSampling.sh"

bsub -w "done(${BASE_NAME}-4_downSampling)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-4_kunitigs" "bash 4_kunitigs.sh"
bsub -w "done(${BASE_NAME}-4_kunitigs)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-4_anchors" "bash 4_anchors.sh"
bsub -w "done(${BASE_NAME}-4_anchors)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_statAnchors_4_kunitigs" "bash 9_statAnchors.sh 4_kunitigs statKunitigsAnchors.md"

bsub -w "done(${BASE_NAME}-4_downSampling)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-4_tadpole" "bash 4_tadpole.sh"
bsub -w "done(${BASE_NAME}-4_tadpole)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-4_tadpoleAnchors" "bash 4_tadpoleAnchors.sh"
bsub -w "done(${BASE_NAME}-4_tadpoleAnchors)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_statAnchors_4_tadpole" "bash 9_statAnchors.sh 4_tadpole statTadpoleAnchors.md"

# down sampling mergereads
bsub -w "done(${BASE_NAME}-2_mergereads)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-6_downSampling" "bash 6_downSampling.sh"

bsub -w "done(${BASE_NAME}-6_downSampling)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-6_kunitigs" "bash 6_kunitigs.sh"
bsub -w "done(${BASE_NAME}-6_kunitigs)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-6_anchors" "bash 6_anchors.sh"
bsub -w "done(${BASE_NAME}-6_anchors)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_statAnchors_6_kunitigs" "bash 9_statMRAnchors.sh 6_kunitigs statMRKunitigsAnchors.md"

bsub -w "done(${BASE_NAME}-6_downSampling)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-6_tadpole" "bash 6_tadpole.sh"
bsub -w "done(${BASE_NAME}-6_tadpole)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-6_tadpoleAnchors" "bash 6_tadpoleAnchors.sh"
bsub -w "done(${BASE_NAME}-6_tadpoleAnchors)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_statAnchors_6_tadpole" "bash 9_statMRAnchors.sh 6_tadpole statMRTadpoleAnchors.md"

```

```bash
# merge anchors
bsub -w "done(${BASE_NAME}-4_anchors)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-7_mergeAnchors_4_kunitigs" "bash 7_mergeAnchors.sh 4_kunitigs 7_mergeKunitigsAnchors"
bsub -w "done(${BASE_NAME}-4_tadpoleAnchors)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-7_mergeAnchors_4_tadpole" "bash 7_mergeAnchors.sh 4_tadpole 7_mergeTadpoleAnchors"
bsub -w "done(${BASE_NAME}-6_anchors)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-7_mergeAnchors_6_kunitigs" "bash 7_mergeAnchors.sh 6_kunitigs 7_mergeMRKunitigsAnchors"
bsub -w "done(${BASE_NAME}-6_tadpoleAnchors)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-7_mergeAnchors_6_tadpole" "bash 7_mergeAnchors.sh 6_tadpole 7_mergeMRTadpoleAnchors"

bsub -w "done(${BASE_NAME}-7_mergeAnchors_4_kunitigs) && done(${BASE_NAME}-7_mergeAnchors_4_tadpole) && done(${BASE_NAME}-7_mergeAnchors_6_kunitigs) && done(${BASE_NAME}-7_mergeAnchors_6_tadpole)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-7_mergeAnchors" "bash 7_mergeAnchors.sh 7_merge 7_mergeAnchors"

# canu
bsub -w "done(${BASE_NAME}-3_trimlong)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-5_canu" "bash 5_canu.sh"
bsub -w "done(${BASE_NAME}-5_canu)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_statCanu" "bash 9_statCanu.sh"

# expand anchors
bsub -w "done(${BASE_NAME}-7_mergeAnchors) && done(${BASE_NAME}-5_canu)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-7_anchorLong" \
    "bash 7_anchorLong.sh 7_mergeAnchors/anchor.merge.fasta 5_canu_Xall-trim/${BASE_NAME}.correctedReads.fasta.gz"

bsub -w "done(${BASE_NAME}-7_anchorLong)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-7_anchorFill" \
    "bash 7_anchorFill.sh 7_anchorLong/contig.fasta 5_canu_Xall-trim/${BASE_NAME}.contigs.fasta"

```

```bash
# stats
bash 9_statFinal.sh

bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_quast" "bash 9_quast.sh"

# false strands of anchorLong
cat 7_anchorLong/group/*.ovlp.tsv \
    | perl -nla -e '/anchor.+long/ or next; print $F[0] if $F[8] == 1;' \
    | sort | uniq -c

# bash 0_cleanup.sh

```

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=s288c

cd ${WORKING_DIR}/${BASE_NAME}

mkdir -p 2_illumina/mergereads
cd 2_illumina/mergereads

fastqc -t 16 \
    merged.fq.gz unmerged.fq.gz \
    -o .

mkdir kmergenie
parallel --no-run-if-empty --linebuffer -k -j 2 "
    cd kmergenie
    kmergenie -l 21 -k 121 -s 10 -t 8 --one-pass ../{}.fq.gz -o {}
    " ::: merged unmerged

# spades
spades.py \
    -s merged.fq.gz --12 unmerged.fq.gz \
    --only-assembler \
    -k25,55,95,125 --phred-offset 33 \
    -o spades_out

anchr contained \
    spades_out/contigs.fasta \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin spades_out/spades.non-contained.fasta

# megahit
megahit \
    -r merged.fq.gz --12 unmerged.fq.gz \
    --k-min 45 --k-max 225 --k-step 26 \
    --min-count 2 \
    -o megahit_out

anchr contained \
    megahit_out/final.contigs.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin megahit_out/megahit.non-contained.fasta

# megahit2
megahit \
    -r merged.fq.gz --12 unmerged.fq.gz \
    --k-min 45 --k-max 225 --k-step 10 \
    --min-count 2 \
    -o megahit2_out

anchr contained \
    megahit2_out/final.contigs.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin megahit2_out/megahit.non-contained.fasta

# tadpole
for K in 25 55 95 125; do
    tadpole.sh in=merged.fq.gz,unmerged.fq.gz out=tadpole_out/contigs_K${K}.fa k=${K}
done

anchr contained \
    $(
        find tadpole_out -type f -name "contigs_K*" | sort -r
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin tadpole_out/tadpole.non-contained.fasta
anchr orient \
    tadpole_out/tadpole.non-contained.fasta \
    --len 1000 --idt 0.98 --parallel 16 \
    -o tadpole_out/anchor.orient.fasta
anchr merge \
    tadpole_out/anchor.orient.fasta \
    --len 1000 --idt 0.999 --parallel 16 \
    -o tadpole_out/anchor.merge0.fasta
anchr contained \
    tadpole_out/anchor.merge0.fasta \
    --len 1000 --idt 0.98 --proportion 0.99 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin tadpole_out/anchor.merge.fasta

rm -fr 9_quast_merge
quast --no-check --threads 16 \
    -R ../../1_genome/genome.fa \
    spades_out/spades.non-contained.fasta \
    megahit_out/megahit.non-contained.fasta \
    megahit2_out/megahit.non-contained.fasta \
    tadpole_out/tadpole.non-contained.fasta \
    tadpole_out/anchor.merge.fasta \
    ../../1_genome/paralogs.fas \
    --label "spades,megahit,megahit2,tadpole,tadpoleMerge,paralogs" \
    -o 9_quast_merge

```

Table: statInsertSize

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| genome.bbtools  | 407.5 |    367 | 464.6 |                         48.81% |
| tadpole.bbtools | 394.9 |    361 | 139.2 |                         42.85% |
| genome.picard   | 402.1 |    367 | 142.1 |                             FR |
| tadpole.picard  | 394.4 |    360 | 139.4 |                             FR |


Table: statReads

| Name      |    N50 |      Sum |       # |
|:----------|-------:|---------:|--------:|
| Genome    | 924431 | 12157105 |      17 |
| Paralogs  |   3851 |  1059148 |     366 |
| Illumina  |    150 |  995.54M | 6636934 |
| trim      |    150 |  990.84M | 6614920 |
| Q20L60    |    150 |  979.27M | 6566364 |
| Q25L60    |    150 |  947.81M | 6402072 |
| Q30L60    |    150 |  892.79M | 6089861 |
| PacBio    |   8412 |  820.96M |  177100 |
| Xall.raw  |   8412 |  820.96M |  177100 |
| Xall.trim |   7829 |  626.41M |  106381 |


Table: statTrimReads

| Name     | N50 |     Sum |       # |
|:---------|----:|--------:|--------:|
| clumpify | 150 | 992.93M | 6619558 |
| trim     | 150 |  990.9M | 6615308 |
| filter   | 150 | 990.84M | 6614920 |
| R1       | 150 | 495.64M | 3307460 |
| R2       | 150 |  495.2M | 3307460 |
| Rs       |   0 |       0 |       0 |


```text
#trim
#Matched	6050	0.09140%
#Name	Reads	ReadsPct
PhiX_read2_adapter	1220	0.01843%
```

```text
#filter
#Matched	198	0.00299%
#Name	Reads	ReadsPct
contam_135	131	0.00198%
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 150 | 990.83M | 6614852 |
| ecco          | 150 | 990.83M | 6614852 |
| eccc          | 150 | 990.83M | 6614852 |
| ecct          | 150 |  947.5M | 6321770 |
| extended      | 190 |    1.2G | 6321770 |
| merged        | 387 | 902.19M | 2398087 |
| unmerged.raw  | 190 | 287.32M | 1525596 |
| unmerged.trim | 190 | 287.32M | 1525592 |
| U1            | 190 | 144.08M |  762796 |
| U2            | 190 | 143.24M |  762796 |
| Us            |   0 |       0 |       0 |
| pe.cor        | 354 |   1.19G | 6321766 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 249.2 |    255 |  27.7 |         19.23% |
| ihist.merge.txt  | 376.2 |    371 |  72.7 |         75.87% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |  RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|-------:|-------:|---------:|----------:|
| Q0L0   |  81.5 |   73.5 |    9.82% |     149 | "105" | 12.16M | 11.92M |     0.98 | 0:01'38'' |
| Q20L60 |  80.6 |   73.6 |    8.64% |     148 | "105" | 12.16M | 11.86M |     0.98 | 0:01'38'' |
| Q25L60 |  78.0 |   73.2 |    6.10% |     147 | "105" | 12.16M | 11.66M |     0.96 | 0:01'36'' |
| Q30L60 |  73.5 |   70.7 |    3.76% |     145 | "105" | 12.16M |  11.6M |     0.95 | 0:01'32'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  82.90% |     10804 | 10.98M | 1564 |       353 | 347.19K | 3441 |   32.0 | 1.0 |   9.7 |  52.5 | "31,41,51,61,71,81" | 0:02'23'' | 0:01'20'' |
| Q0L0X60P000    |   60.0 |  82.19% |      8511 | 10.91M | 1893 |        86 | 347.02K | 4052 |   48.0 | 2.0 |  14.0 |  81.0 | "31,41,51,61,71,81" | 0:03'11'' | 0:01'19'' |
| Q0L0XallP000   |   73.5 |  81.74% |      7664 | 10.85M | 2009 |        82 | 356.94K | 4298 |   59.0 | 3.0 |  16.7 | 102.0 | "31,41,51,61,71,81" | 0:03'42'' | 0:01'22'' |
| Q20L60X40P000  |   40.0 |  83.02% |     11290 | 11.01M | 1482 |       219 | 310.53K | 3278 |   32.0 | 1.0 |   9.7 |  52.5 | "31,41,51,61,71,81" | 0:02'21'' | 0:01'18'' |
| Q20L60X60P000  |   60.0 |  82.34% |      8823 | 10.92M | 1805 |        85 | 335.52K | 3878 |   49.0 | 2.0 |  14.3 |  82.5 | "31,41,51,61,71,81" | 0:03'07'' | 0:01'20'' |
| Q20L60XallP000 |   73.6 |  82.05% |      8386 |  10.9M | 1929 |        79 | 326.45K | 4122 |   60.0 | 3.0 |  17.0 | 103.5 | "31,41,51,61,71,81" | 0:03'39'' | 0:01'23'' |
| Q25L60X40P000  |   40.0 |  84.77% |     18271 | 11.14M | 1012 |      1052 | 240.82K | 2445 |   33.0 | 1.0 |  10.0 |  54.0 | "31,41,51,61,71,81" | 0:02'19'' | 0:01'25'' |
| Q25L60X60P000  |   60.0 |  84.04% |     15331 | 11.11M | 1174 |      1038 |  245.1K | 2656 |   49.0 | 2.0 |  14.3 |  82.5 | "31,41,51,61,71,81" | 0:03'06'' | 0:01'22'' |
| Q25L60XallP000 |   73.2 |  83.85% |     14510 |  11.1M | 1237 |      1014 | 243.88K | 2746 |   60.0 | 2.0 |  18.0 |  99.0 | "31,41,51,61,71,81" | 0:03'37'' | 0:01'19'' |
| Q30L60X40P000  |   40.0 |  86.51% |     21356 | 11.17M |  856 |      1235 | 235.54K | 2257 |   33.0 | 1.0 |  10.0 |  54.0 | "31,41,51,61,71,81" | 0:02'21'' | 0:01'28'' |
| Q30L60X60P000  |   60.0 |  85.71% |     18958 | 11.15M |  978 |      1057 |  225.2K | 2336 |   50.0 | 2.0 |  14.7 |  84.0 | "31,41,51,61,71,81" | 0:03'08'' | 0:01'25'' |
| Q30L60XallP000 |   70.7 |  85.56% |     18122 | 11.14M | 1025 |      1054 |  229.9K | 2394 |   59.0 | 2.0 |  17.7 |  97.5 | "31,41,51,61,71,81" | 0:03'34'' | 0:01'26'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  91.85% |     24640 | 11.17M |  738 |      1234 | 294.19K | 2263 |   33.0 | 1.0 |  10.0 |  54.0 | "31,41,51,61,71,81" | 0:01'17'' | 0:01'34'' |
| Q0L0X60P000    |   60.0 |  91.08% |     19305 | 11.14M |  951 |      1260 | 295.08K | 2283 |   49.0 | 2.0 |  14.3 |  82.5 | "31,41,51,61,71,81" | 0:01'28'' | 0:01'26'' |
| Q0L0XallP000   |   73.5 |  90.76% |     15371 | 11.11M | 1143 |      1069 | 295.24K | 2549 |   60.0 | 2.0 |  18.0 |  99.0 | "31,41,51,61,71,81" | 0:01'34'' | 0:01'20'' |
| Q20L60X40P000  |   40.0 |  91.97% |     24825 | 11.18M |  739 |      1203 | 265.52K | 2263 |   33.0 | 1.0 |  10.0 |  54.0 | "31,41,51,61,71,81" | 0:01'17'' | 0:01'32'' |
| Q20L60X60P000  |   60.0 |  91.20% |     20487 | 11.15M |  907 |      1260 | 265.91K | 2188 |   49.0 | 2.0 |  14.3 |  82.5 | "31,41,51,61,71,81" | 0:01'26'' | 0:01'23'' |
| Q20L60XallP000 |   73.6 |  90.85% |     15636 | 11.12M | 1114 |      1110 | 281.64K | 2497 |   60.0 | 2.0 |  18.0 |  99.0 | "31,41,51,61,71,81" | 0:01'36'' | 0:01'22'' |
| Q25L60X40P000  |   40.0 |  92.48% |     31157 | 11.19M |  623 |      1671 | 261.37K | 1993 |   33.0 | 1.0 |  10.0 |  54.0 | "31,41,51,61,71,81" | 0:01'16'' | 0:01'40'' |
| Q25L60X60P000  |   60.0 |  91.96% |     25699 | 11.18M |  717 |      2403 | 272.44K | 1856 |   50.0 | 2.0 |  14.7 |  84.0 | "31,41,51,61,71,81" | 0:01'26'' | 0:01'26'' |
| Q25L60XallP000 |   73.2 |  91.61% |     22471 | 11.17M |  828 |      1710 | 246.42K | 1940 |   61.0 | 2.0 |  18.3 | 100.5 | "31,41,51,61,71,81" | 0:01'34'' | 0:01'22'' |
| Q30L60X40P000  |   40.0 |  92.98% |     30686 | 11.19M |  622 |      1713 | 257.61K | 2163 |   33.0 | 1.0 |  10.0 |  54.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:01'42'' |
| Q30L60X60P000  |   60.0 |  92.43% |     27431 | 11.19M |  668 |      1683 | 230.64K | 1928 |   50.0 | 2.0 |  14.7 |  84.0 | "31,41,51,61,71,81" | 0:01'25'' | 0:01'34'' |
| Q30L60XallP000 |   70.7 |  92.22% |     25565 | 11.18M |  709 |      1683 | 231.56K | 1922 |   59.0 | 2.0 |  17.7 |  97.5 | "31,41,51,61,71,81" | 0:01'33'' | 0:01'31'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  85.40% |     16932 | 11.07M | 1059 |       160 |  283.6K | 2278 |   32.0 | 2.0 |   8.7 |  57.0 | "31,41,51,61,71,81" | 0:02'50'' | 0:01'18'' |
| MRX40P001  |   40.0 |  87.51% |     17649 | 11.07M | 1069 |       147 | 280.76K | 2286 |   32.0 | 2.0 |   8.7 |  57.0 | "31,41,51,61,71,81" | 0:02'48'' | 0:01'21'' |
| MRX60P000  |   60.0 |  84.17% |     13485 | 11.01M | 1310 |       119 | 309.94K | 2761 |   48.0 | 3.0 |  13.0 |  85.5 | "31,41,51,61,71,81" | 0:03'50'' | 0:01'17'' |
| MRX80P000  |   80.0 |  83.38% |     12144 | 10.93M | 1452 |       115 | 364.69K | 3049 |   64.0 | 3.0 |  18.3 | 109.5 | "31,41,51,61,71,81" | 0:04'49'' | 0:01'20'' |
| MRXallP000 |   98.0 |  83.05% |     11042 | 10.94M | 1546 |       102 | 336.01K | 3232 |   78.0 | 5.0 |  20.0 | 139.5 | "31,41,51,61,71,81" | 0:05'43'' | 0:01'24'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  91.30% |     31992 | 11.15M |  570 |      1148 | 229.83K | 1256 |   33.0 | 1.0 |  10.0 |  54.0 | "31,41,51,61,71,81" | 0:01'23'' | 0:01'20'' |
| MRX40P001  |   40.0 |  91.34% |     35720 | 11.16M |  544 |      1275 | 226.74K | 1216 |   33.0 | 1.0 |  10.0 |  54.0 | "31,41,51,61,71,81" | 0:01'19'' | 0:01'21'' |
| MRX60P000  |   60.0 |  91.01% |     25629 | 11.14M |  706 |      1079 | 239.99K | 1501 |   49.0 | 2.0 |  14.3 |  82.5 | "31,41,51,61,71,81" | 0:01'36'' | 0:01'17'' |
| MRX80P000  |   80.0 |  90.72% |     20906 | 11.12M |  877 |      1039 | 254.67K | 1839 |   66.0 | 3.0 |  19.0 | 112.5 | "31,41,51,61,71,81" | 0:01'48'' | 0:01'21'' |
| MRXallP000 |   98.0 |  90.44% |     17986 | 11.11M | 1023 |      1039 | 251.23K | 2136 |   80.0 | 3.0 |  20.0 | 133.5 | "31,41,51,61,71,81" | 0:02'00'' | 0:01'23'' |


Table: statCanu

| Name                |    N50 |      Sum |     # |
|:--------------------|-------:|---------:|------:|
| Genome              | 924431 | 12157105 |    17 |
| Paralogs            |   3851 |  1059148 |   366 |
| Xall.trim.corrected |   7965 |   450.5M | 66099 |
| Xall.trim.contig    | 813374 | 12360766 |    26 |


Table: statFinal

| Name                             |    N50 |      Sum |    # |
|:---------------------------------|-------:|---------:|-----:|
| Genome                           | 924431 | 12157105 |   17 |
| Paralogs                         |   3851 |  1059148 |  366 |
| 7_mergeKunitigsAnchors.anchors   |  26556 | 11209555 |  697 |
| 7_mergeKunitigsAnchors.others    |   1423 |   287146 |  185 |
| 7_mergeTadpoleAnchors.anchors    |  37632 | 11224733 |  503 |
| 7_mergeTadpoleAnchors.others     |   4770 |   269205 |  110 |
| 7_mergeMRKunitigsAnchors.anchors |  22756 | 11186266 |  809 |
| 7_mergeMRKunitigsAnchors.others  |   1707 |   204103 |  121 |
| 7_mergeMRTadpoleAnchors.anchors  |  45406 | 11208662 |  467 |
| 7_mergeMRTadpoleAnchors.others   |   4400 |   192281 |   75 |
| 7_mergeAnchors.anchors           |  46366 | 11241414 |  445 |
| 7_mergeAnchors.others            |   1986 |   437891 |  240 |
| anchorLong                       |  47321 | 11218984 |  418 |
| anchorFill                       | 267740 | 11357318 |   74 |
| canu_Xall-trim                   | 813374 | 12360766 |   26 |
| spades.contig                    | 122875 | 11742788 | 1257 |
| spades.scaffold                  | 133886 | 11743508 | 1239 |
| spades.non-contained             | 125298 | 11531378 |  204 |
| spades.anchor                    | 122800 | 11305206 |  168 |
| megahit.contig                   |  49631 | 11651225 |  984 |
| megahit.non-contained            |  51277 | 11455395 |  455 |
| megahit.anchor                   |  51979 | 11215635 |  402 |
| platanus.contig                  |  37135 | 12071740 | 3954 |
| platanus.scaffold                | 160128 | 11921921 | 2948 |
| platanus.non-contained           | 176536 | 11510261 |  168 |
| platanus.anchor                  | 150088 | 11352513 |  152 |

| genome.bbtools  | 356.5 |    320 | 484.3 |                         45.78% |
| tadpole.bbtools | 339.1 |    309 | 144.4 |                         43.32% |
| genome.picard   | 352.1 |    322 | 142.5 |                             FR |
| tadpole.picard  | 342.9 |    313 | 141.4 |                             FR |


Table: statReads

| Name      |    N50 |      Sum |        # |
|:----------|-------:|---------:|---------:|
| Genome    | 924431 | 12157105 |       17 |
| Paralogs  |   3851 |  1059148 |      366 |
| Illumina  |    151 |    2.94G | 19464114 |
| clumpify  |    151 |    2.78G | 18397208 |
| trim      |    150 |    2.68G | 18163836 |
| filter    |    150 |    2.68G | 18162546 |
| trimmed   |    150 |    2.68G | 18162546 |
| Q20L60    |    150 |    2.63G | 17868322 |
| Q25L60    |    150 |    2.52G | 17274131 |
| Q30L60    |    150 |    2.37G | 16419895 |
| PacBio    |   8412 |  820.96M |   177100 |
| Xall.raw  |   8412 |  820.96M |   177100 |
| Xall.trim |   7829 |  626.41M |   106381 |

```text
#trim
#Matched	976734	5.30914%
#Name	Reads	ReadsPct
I5_Nextera_Transposase_1	571978	3.10905%
I7_Nextera_Transposase_1	393836	2.14074%
PhiX_read2_adapter	2061	0.01120%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N712	1470	0.00799%
Reverse_adapter	1096	0.00596%
```

```text
#filter
#Matched	716	0.00394%
#Name	Reads	ReadsPct
contam_135	539	0.00297%
contam_159	158	0.00087%
```


Table: statMergeReads

| Name          | N50 |     Sum |        # |
|:--------------|----:|--------:|---------:|
| clumped       | 150 |   2.68G | 18135506 |
| ecco          | 150 |   2.68G | 18135506 |
| eccc          | 150 |   2.68G | 18135506 |
| ecct          | 150 |   2.57G | 17413730 |
| extended      | 190 |   3.25G | 17413730 |
| merged        | 356 |    2.4G |  7288899 |
| unmerged.raw  | 190 | 527.63M |  2835932 |
| unmerged.trim | 190 | 527.63M |  2835924 |
| U1            | 190 | 267.14M |  1417962 |
| U2            | 190 |  260.5M |  1417962 |
| Us            |   0 |       0 |        0 |
| pe.cor        | 327 |   2.93G | 17413722 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 211.2 |    221 |  53.0 |         39.55% |
| ihist.merge.txt  | 328.9 |    326 |  95.0 |         83.71% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |  RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|-------:|-------:|---------:|----------:|
| Q20L60 | 216.0 |  197.7 |    8.46% |     139 | "105" | 12.16M | 12.14M |     1.00 | 0:04'31'' |
| Q25L60 | 207.2 |  195.1 |    5.84% |     139 | "105" | 12.16M | 11.84M |     0.97 | 0:13'38'' |
| Q30L60 | 195.2 |  186.0 |    4.71% |     141 | "105" | 12.16M | 11.72M |     0.96 | 0:08'28'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000  |   40.0 |  88.76% |     10516 | 10.29M | 1983 |      1020 |   1.39M | 5232 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'21'' | 0:01'37'' |
| Q20L60X40P001  |   40.0 |  88.47% |     10473 |  10.3M | 1927 |      1036 |   1.31M | 5013 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'21'' | 0:01'33'' |
| Q20L60X40P002  |   40.0 |  88.61% |      9784 | 10.23M | 1981 |      1047 |   1.37M | 5113 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'22'' | 0:01'35'' |
| Q20L60X40P003  |   40.0 |  88.60% |      9931 | 10.35M | 1898 |       993 |    1.2M | 5135 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'21'' | 0:01'33'' |
| Q20L60X80P000  |   80.0 |  87.87% |     10933 | 10.45M | 1871 |       933 | 976.11K | 4349 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:03'53'' | 0:01'32'' |
| Q20L60X80P001  |   80.0 |  87.82% |     10083 | 10.42M | 1909 |       990 |   1.02M | 4362 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:03'53'' | 0:01'32'' |
| Q20L60X120P000 |  120.0 |  87.09% |     10659 | 10.73M | 1747 |       791 | 545.97K | 3906 |  107.0 |  9.0 |  20.0 | 201.0 | "31,41,51,61,71,81" | 0:05'23'' | 0:01'31'' |
| Q20L60XallP000 |  197.7 |  86.48% |      9468 | 10.86M | 1813 |       900 | 339.06K | 4011 |  176.0 | 16.0 |  20.0 | 336.0 | "31,41,51,61,71,81" | 0:08'21'' | 0:01'34'' |
| Q25L60X40P000  |   40.0 |  89.33% |     10859 |  10.4M | 1855 |      1018 |   1.26M | 5146 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'20'' | 0:01'37'' |
| Q25L60X40P001  |   40.0 |  89.27% |     10326 | 10.36M | 1957 |      1026 |   1.38M | 5306 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'20'' | 0:01'36'' |
| Q25L60X40P002  |   40.0 |  89.12% |     10617 | 10.32M | 1935 |      1008 |   1.34M | 5160 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'20'' | 0:01'33'' |
| Q25L60X40P003  |   40.0 |  89.15% |     11290 | 10.42M | 1835 |       973 |    1.2M | 5079 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'20'' | 0:01'37'' |
| Q25L60X80P000  |   80.0 |  88.48% |     11222 | 10.48M | 1778 |      1005 | 998.28K | 4329 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:03'50'' | 0:01'37'' |
| Q25L60X80P001  |   80.0 |  88.30% |     11112 | 10.49M | 1802 |       981 | 984.59K | 4276 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:03'49'' | 0:01'30'' |
| Q25L60X120P000 |  120.0 |  87.63% |     11190 | 10.79M | 1667 |       882 | 529.13K | 3880 |  107.0 | 10.0 |  20.0 | 205.5 | "31,41,51,61,71,81" | 0:05'20'' | 0:01'34'' |
| Q25L60XallP000 |  195.1 |  87.01% |     10318 | 10.91M | 1695 |       991 | 317.56K | 3819 |  174.0 | 16.0 |  20.0 | 333.0 | "31,41,51,61,71,81" | 0:08'12'' | 0:01'36'' |
| Q30L60X40P000  |   40.0 |  89.58% |     11822 | 10.45M | 1758 |      1005 |   1.16M | 4943 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'22'' | 0:01'37'' |
| Q30L60X40P001  |   40.0 |  89.65% |     11965 | 10.41M | 1750 |      1016 |   1.25M | 4970 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'21'' | 0:01'36'' |
| Q30L60X40P002  |   40.0 |  89.84% |     11815 | 10.49M | 1714 |      1017 |   1.18M | 5002 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'22'' | 0:01'39'' |
| Q30L60X40P003  |   40.0 |  89.71% |     12130 | 10.45M | 1733 |      1032 |   1.22M | 4978 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'22'' | 0:01'38'' |
| Q30L60X80P000  |   80.0 |  88.79% |     12580 | 10.52M | 1666 |      1001 | 977.25K | 4195 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:03'50'' | 0:01'36'' |
| Q30L60X80P001  |   80.0 |  89.05% |     12347 | 10.54M | 1682 |       998 | 983.01K | 4274 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:03'51'' | 0:01'38'' |
| Q30L60X120P000 |  120.0 |  88.08% |     12684 | 10.85M | 1519 |       884 | 485.93K | 3710 |  107.0 | 10.0 |  20.0 | 205.5 | "31,41,51,61,71,81" | 0:05'22'' | 0:01'36'' |
| Q30L60XallP000 |  186.0 |  87.56% |     11568 | 10.98M | 1578 |       963 |  307.8K | 3621 |  166.0 | 15.0 |  20.0 | 316.5 | "31,41,51,61,71,81" | 0:07'51'' | 0:01'37'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000  |   40.0 |  92.31% |     11479 | 10.44M | 1793 |       987 |   1.21M | 5395 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'22'' | 0:02'02'' |
| Q20L60X40P001  |   40.0 |  92.10% |     10530 | 10.44M | 1822 |       994 |   1.18M | 5346 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'21'' | 0:01'55'' |
| Q20L60X40P002  |   40.0 |  92.10% |      9986 | 10.39M | 1853 |      1018 |   1.22M | 5338 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'20'' | 0:01'54'' |
| Q20L60X40P003  |   40.0 |  92.14% |     10118 | 10.43M | 1864 |       961 |   1.15M | 5405 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'17'' | 0:01'49'' |
| Q20L60X80P000  |   80.0 |  92.56% |     15274 |  10.7M | 1438 |       879 | 974.57K | 4351 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:01'42'' | 0:01'48'' |
| Q20L60X80P001  |   80.0 |  92.56% |     15227 | 10.64M | 1475 |       902 |   1.03M | 4562 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:01'36'' | 0:01'47'' |
| Q20L60X120P000 |  120.0 |  92.21% |     16357 | 10.93M | 1232 |       709 | 529.37K | 3590 |  107.0 |  9.0 |  20.0 | 201.0 | "31,41,51,61,71,81" | 0:01'59'' | 0:01'47'' |
| Q20L60XallP000 |  197.7 |  91.76% |     14170 | 11.05M | 1311 |       843 | 321.84K | 3380 |  177.0 | 15.0 |  20.0 | 333.0 | "31,41,51,61,71,81" | 0:02'59'' | 0:01'44'' |
| Q25L60X40P000  |   40.0 |  92.49% |     10551 | 10.47M | 1815 |      1006 |    1.2M | 5379 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'13'' | 0:01'36'' |
| Q25L60X40P001  |   40.0 |  92.45% |     10268 | 10.46M | 1848 |       980 |   1.17M | 5386 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'14'' | 0:01'35'' |
| Q25L60X40P002  |   40.0 |  92.47% |     10735 | 10.45M | 1830 |      1003 |   1.14M | 5374 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'27'' | 0:03'01'' |
| Q25L60X40P003  |   40.0 |  92.47% |     10494 | 10.46M | 1787 |       942 |   1.13M | 5314 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'34'' | 0:03'27'' |
| Q25L60X80P000  |   80.0 |  92.98% |     17287 | 10.73M | 1329 |       845 | 912.51K | 4375 |   72.0 |  6.0 |  18.0 | 135.0 | "31,41,51,61,71,81" | 0:02'03'' | 0:04'20'' |
| Q25L60X80P001  |   80.0 |  92.87% |     16511 | 10.74M | 1365 |       870 | 915.92K | 4380 |   72.0 |  6.0 |  18.0 | 135.0 | "31,41,51,61,71,81" | 0:01'40'' | 0:03'42'' |
| Q25L60X120P000 |  120.0 |  92.58% |     16803 | 10.93M | 1221 |       850 | 547.67K | 3660 |  107.0 |  9.0 |  20.0 | 201.0 | "31,41,51,61,71,81" | 0:01'59'' | 0:06'11'' |
| Q25L60XallP000 |  195.1 |  92.13% |     14605 | 11.07M | 1258 |       873 | 311.28K | 3362 |  175.0 | 15.0 |  20.0 | 330.0 | "31,41,51,61,71,81" | 0:02'51'' | 0:06'01'' |
| Q30L60X40P000  |   40.0 |  92.54% |     10378 | 10.48M | 1837 |       930 |   1.13M | 5360 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'34'' |
| Q30L60X40P001  |   40.0 |  92.62% |     10770 | 10.45M | 1802 |       981 |   1.19M | 5376 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'12'' | 0:01'38'' |
| Q30L60X40P002  |   40.0 |  92.59% |     10615 | 10.47M | 1775 |      1026 |   1.16M | 5362 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'35'' |
| Q30L60X40P003  |   40.0 |  92.68% |     11300 | 10.47M | 1769 |      1010 |   1.17M | 5366 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'12'' | 0:01'41'' |
| Q30L60X80P000  |   80.0 |  93.10% |     16738 | 10.75M | 1322 |       840 | 904.72K | 4347 |   72.0 |  6.0 |  18.0 | 135.0 | "31,41,51,61,71,81" | 0:01'39'' | 0:01'50'' |
| Q30L60X80P001  |   80.0 |  93.16% |     17824 | 10.75M | 1302 |       895 | 936.84K | 4442 |   72.0 |  6.0 |  18.0 | 135.0 | "31,41,51,61,71,81" | 0:01'37'' | 0:01'50'' |
| Q30L60X120P000 |  120.0 |  92.86% |     17713 | 10.98M | 1158 |       831 | 524.87K | 3687 |  108.0 |  9.0 |  20.0 | 202.5 | "31,41,51,61,71,81" | 0:02'01'' | 0:02'22'' |
| Q30L60XallP000 |  186.0 |  92.50% |     15974 | 11.07M | 1211 |       961 | 341.83K | 3419 |  168.0 | 13.0 |  20.0 | 310.5 | "31,41,51,61,71,81" | 0:02'42'' | 0:02'17'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  86.63% |     12822 | 10.38M | 1681 |      1018 | 991.32K | 3223 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'40'' | 0:01'20'' |
| MRX40P001  |   40.0 |  87.09% |     12421 | 10.39M | 1677 |      1005 | 993.87K | 3201 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'38'' | 0:01'23'' |
| MRX40P002  |   40.0 |  86.93% |     12303 |  10.4M | 1689 |      1023 | 992.08K | 3227 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'39'' | 0:01'19'' |
| MRX40P003  |   40.0 |  87.10% |     11727 | 10.36M | 1720 |      1027 |   1.03M | 3288 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'40'' | 0:01'21'' |
| MRX40P004  |   40.0 |  86.70% |     12750 |  10.4M | 1682 |      1024 | 978.56K | 3209 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'38'' | 0:01'21'' |
| MRX40P005  |   40.0 |  86.81% |     11889 | 10.38M | 1729 |      1018 |   1.04M | 3367 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'40'' | 0:01'21'' |
| MRX80P000  |   80.0 |  85.80% |     12283 | 10.59M | 1597 |       871 | 726.72K | 3148 |   70.0 |  7.0 |  16.3 | 136.5 | "31,41,51,61,71,81" | 0:04'33'' | 0:01'23'' |
| MRX80P001  |   80.0 |  85.83% |     11506 | 10.42M | 1724 |      1016 | 890.88K | 3226 |   70.0 |  6.0 |  17.3 | 132.0 | "31,41,51,61,71,81" | 0:04'32'' | 0:01'19'' |
| MRX80P002  |   80.0 |  85.84% |     12241 | 10.59M | 1598 |       907 | 720.32K | 3100 |   70.0 |  7.0 |  16.3 | 136.5 | "31,41,51,61,71,81" | 0:04'33'' | 0:01'20'' |
| MRX120P000 |  120.0 |  84.99% |     10973 | 10.66M | 1639 |       917 | 592.03K | 3327 |  104.0 | 10.0 |  20.0 | 201.0 | "31,41,51,61,71,81" | 0:06'27'' | 0:01'21'' |
| MRX120P001 |  120.0 |  85.28% |     11285 | 10.73M | 1602 |       749 | 524.69K | 3212 |  104.0 | 11.0 |  20.0 | 205.5 | "31,41,51,61,71,81" | 0:06'26'' | 0:01'22'' |
| MRXallP000 |  241.2 |  83.87% |      9050 | 10.83M | 1853 |       834 | 325.76K | 3842 |  209.0 | 22.0 |  20.0 | 412.5 | "31,41,51,61,71,81" | 0:12'09'' | 0:01'29'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  91.13% |     16991 |  10.6M | 1401 |       904 | 941.92K | 3342 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'26'' | 0:01'36'' |
| MRX40P001  |   40.0 |  91.12% |     15930 | 10.52M | 1471 |       971 |   1.08M | 3468 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:01'23'' | 0:01'33'' |
| MRX40P002  |   40.0 |  91.12% |     15387 | 10.52M | 1478 |       991 |   1.09M | 3573 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:01'22'' | 0:01'33'' |
| MRX40P003  |   40.0 |  91.12% |     16354 | 10.52M | 1435 |      1004 |   1.06M | 3467 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:01'30'' | 0:01'34'' |
| MRX40P004  |   40.0 |  91.14% |     16552 |  10.5M | 1474 |      1002 |   1.08M | 3572 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:01'31'' | 0:01'30'' |
| MRX40P005  |   40.0 |  91.03% |     15884 | 10.52M | 1507 |       952 |   1.03M | 3493 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:01'23'' | 0:01'33'' |
| MRX80P000  |   80.0 |  90.65% |     17873 | 10.67M | 1278 |       925 | 743.27K | 2569 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:01'50'' | 0:02'57'' |
| MRX80P001  |   80.0 |  90.54% |     18355 | 10.65M | 1244 |      1025 | 746.91K | 2520 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:01'49'' | 0:03'31'' |
| MRX80P002  |   80.0 |  90.61% |     18271 | 10.68M | 1263 |       930 | 735.84K | 2594 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:02'00'' | 0:02'02'' |
| MRX120P000 |  120.0 |  90.29% |     18585 |  10.9M | 1081 |       945 | 448.62K | 2294 |  107.0 |  9.0 |  20.0 | 201.0 | "31,41,51,61,71,81" | 0:02'19'' | 0:02'00'' |
| MRX120P001 |  120.0 |  90.28% |     18452 | 10.89M | 1117 |       841 | 458.98K | 2339 |  107.0 |  9.0 |  20.0 | 201.0 | "31,41,51,61,71,81" | 0:02'27'' | 0:01'27'' |
| MRXallP000 |  241.2 |  90.03% |     15237 | 11.06M | 1199 |       960 | 263.31K | 2538 |  214.0 | 19.0 |  20.0 | 406.5 | "31,41,51,61,71,81" | 0:04'03'' | 0:01'31'' |


Table: statCanu

| Name                |    N50 |      Sum |     # |
|:--------------------|-------:|---------:|------:|
| Genome              | 924431 | 12157105 |    17 |
| Paralogs            |   3851 |  1059148 |   366 |
| Xall.trim.corrected |   7965 |   450.5M | 66099 |
| Xall.trim.contig    | 813374 | 12360766 |    26 |


Table: statFinal

| Name                             |    N50 |      Sum |    # |
|:---------------------------------|-------:|---------:|-----:|
| Genome                           | 924431 | 12157105 |   17 |
| Paralogs                         |   3851 |  1059148 |  366 |
| 7_mergeKunitigsAnchors.anchors   |  30216 | 11402328 |  702 |
| 7_mergeKunitigsAnchors.others    |   1386 |  4231898 | 3351 |
| 7_mergeTadpoleAnchors.anchors    |  30402 | 11277945 |  677 |
| 7_mergeTadpoleAnchors.others     |   1356 |  3954327 | 3160 |
| 7_mergeMRKunitigsAnchors.anchors |  30219 | 11245688 |  720 |
| 7_mergeMRKunitigsAnchors.others  |   1354 |  2449380 | 1964 |
| 7_mergeMRTadpoleAnchors.anchors  |  31002 | 11232421 |  647 |
| 7_mergeMRTadpoleAnchors.others   |   1400 |  2222605 | 1764 |
| 7_mergeAnchors.anchors           |  37663 | 11524551 |  559 |
| 7_mergeAnchors.others            |   1430 |  5665872 | 4365 |
| anchorLong                       |  45492 | 11440293 |  459 |
| anchorFill                       | 309318 | 11460658 |   78 |
| canu_Xall-trim                   | 813374 | 12360766 |   26 |
| spades.contig                    |  93363 | 11747736 | 1444 |
| spades.scaffold                  | 106111 | 11748416 | 1421 |
| spades.non-contained             |  97714 | 11513927 |  261 |
| spades.anchor                    |   8667 | 10755810 | 1788 |
| megahit.contig                   |  43186 | 11624595 | 1018 |
| megahit.non-contained            |  44023 | 11432512 |  519 |
| megahit.anchor                   |   8209 | 10657918 | 1865 |
| platanus.contig                  |   7427 | 12170383 | 5342 |
| platanus.scaffold                |  67382 | 11891523 | 3166 |
| platanus.non-contained           |  71428 | 11408032 |  322 |
| platanus.anchor                  |   8215 | 10688304 | 1892 |


# s288cH

## s288cH: download

* Reference genome

```bash
mkdir -p ${HOME}/data/anchr/s288cH
cd ${HOME}/data/anchr/s288cH

mkdir -p 1_genome
cd 1_genome

cp ~/data/anchr/s288c/1_genome/genome.fa .
cp ~/data/anchr/s288c/1_genome/paralogs.fas .

```

* Illumina HiSeq 2500 (pe150, nextera)

    [SRX2058864](https://www.ncbi.nlm.nih.gov/sra/SRX2058864) SRR4074255

    PRJNA340312

```bash
cd ${HOME}/data/anchr/s288cH

mkdir -p 2_illumina
cd 2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR407/005/SRR4074255/SRR4074255_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR407/005/SRR4074255/SRR4074255_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
7ba93499d73cdaeaf50dd506e2c8572d SRR4074255_1.fastq.gz
aee9ec3f855796b6d30a3d191fc22345 SRR4074255_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s SRR4074255_1.fastq.gz R1.fq.gz
ln -s SRR4074255_2.fastq.gz R2.fq.gz
```

## s288cH: template

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/anchr/s288cH/ \
    wangq@202.119.37.251:data/anchr/s288cH

#rsync -avP wangq@202.119.37.251:data/anchr/s288cH/ ~/data/anchr/s288cH

```

* template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=s288cH
QUEUE_NAME=mpi

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 12157105 \
    --is_euk \
    --trim2 "--dedupe" \
    --cov2 "40 80 120 all" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,2,3" \
    --insertsize \
    --parallel 24

```

## s288cH: run

Same as [s288c: run](#s288c-run)

# *Drosophila melanogaster* iso-1

* Genome: [Ensembl 82](http://sep2015.archive.ensembl.org/Drosophila_melanogaster/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.0661

## iso_1: download

* Reference genome

```bash
mkdir -p ~/data/anchr/iso_1/1_genome
cd ~/data/anchr/iso_1/1_genome

wget -N ftp://ftp.ensembl.org/pub/release-82/fasta/drosophila_melanogaster/dna/Drosophila_melanogaster.BDGP6.dna_sm.toplevel.fa.gz
faops order Drosophila_melanogaster.BDGP6.dna_sm.toplevel.fa.gz \
    <(for chr in {2L,2R,3L,3R,4,X,Y,dmel_mitochondrion_genome}; do echo $chr; done) \
    genome.fa

cp ~/data/anchr/paralogs/model/Results/iso_1/iso_1.multi.fas 1_genome/paralogs.fas
```

* Illumina

    * [ERX645969](http://www.ebi.ac.uk/ena/data/view/ERX645969): ERR701706-ERR701711
    * SRR306628 labels ycnbwsp instead of iso-1.

```bash
mkdir -p ~/data/anchr/iso_1/2_illumina
cd ~/data/anchr/iso_1/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/err/ERR701/ERR701706
ftp://ftp.sra.ebi.ac.uk/vol1/err/ERR701/ERR701707
ftp://ftp.sra.ebi.ac.uk/vol1/err/ERR701/ERR701708
ftp://ftp.sra.ebi.ac.uk/vol1/err/ERR701/ERR701709
ftp://ftp.sra.ebi.ac.uk/vol1/err/ERR701/ERR701710
ftp://ftp.sra.ebi.ac.uk/vol1/err/ERR701/ERR701711
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
c0c877f8ba0bba7e26597e415d7591e1        ERR701706
8737074782482ced94418a579bc0e8db        ERR701707
e638730be88ee74102511c5091850359        ERR701708
d2bf01cb606e5d2ccad76bd1380e17a3        ERR701709
a51e6c1c09f225f1b6628b614c046ed0        ERR701710
dab2d1f14eff875f456045941a955b51        ERR701711
EOF

md5sum --check sra_md5.txt

for sra in ERR7017{06,07,08,09,10,11}; do
    echo ${sra}
    fastq-dump --split-files ./${sra}
done

cat ERR7017{06,07,08,09,10,11}_1.fastq > R1.fq
cat ERR7017{06,07,08,09,10,11}_2.fastq > R2.fq

find . -name "*.fq" | parallel -j 2 pigz -p 8
rm *.fastq
```

* PacBio

    PacBio provides a dataset of *D. melanogaster* strain
    [ISO1](https://github.com/PacificBiosciences/DevNet/wiki/Drosophila-sequence-and-assembly), the
    same stock used in the official BDGP reference assemblies. This is gathered with RS II and P5C3.

```bash
mkdir -p ~/data/anchr/iso_1/3_pacbio
cd ~/data/anchr/iso_1/3_pacbio

cat <<EOF > tgz.txt
https://s3.amazonaws.com/datasets.pacb.com/2014/Drosophila/raw/Dro1_24NOV2013_398.tgz
https://s3.amazonaws.com/datasets.pacb.com/2014/Drosophila/raw/Dro2_25NOV2013_399.tgz
https://s3.amazonaws.com/datasets.pacb.com/2014/Drosophila/raw/Dro3_26NOV2013_400.tgz
https://s3.amazonaws.com/datasets.pacb.com/2014/Drosophila/raw/Dro4_28NOV2013_401.tgz
https://s3.amazonaws.com/datasets.pacb.com/2014/Drosophila/raw/Dro5_29NOV2013_402.tgz
https://s3.amazonaws.com/datasets.pacb.com/2014/Drosophila/raw/Dro6_1DEC2013_403.tgz
EOF
aria2c -x 9 -s 3 -c -i tgz.txt

# untar
mkdir -p ~/data/anchr/iso_1/3_pacbio/untar
cd ~/data/anchr/iso_1/3_pacbio
tar xvfz Dro1_24NOV2013_398.tgz --directory untar
#tar xvfz Dro2_25NOV2013_399.tgz --directory untar
#tar xvfz Dro3_26NOV2013_400.tgz --directory untar
#tar xvfz Dro4_28NOV2013_401.tgz --directory untar
tar xvfz Dro5_29NOV2013_402.tgz --directory untar
tar xvfz Dro6_1DEC2013_403.tgz --directory untar

find . -type f -name "*.ba?.h5" | parallel -j 1 "mv {} untar" 

# convert .bax.h5 to .subreads.bam
mkdir -p ~/data/anchr/iso_1/3_pacbio/bam
cd ~/data/anchr/iso_1/3_pacbio/bam

source ~/share/pitchfork/deployment/setup-env.sh
for movie in m131124_190051 m131124_221952 m131125_013854 m131125_045830 m131130_054035 m131130_091217 m131130_124231 m131130_161213 m131130_194336 m131130_231441 m131201_024805 m131201_061903 m131201_223357 m131202_020424 m131202_053545 m131202_090545 m131202_123546 m131202_160616 m131202_193958 m131202_231109;
do 
    if [ -e ~/data/anchr/iso_1/3_pacbio/bam/${movie}*.subreads.bam ]; then
        continue
    fi
    bax2bam ~/data/anchr/iso_1/3_pacbio/untar/${movie}*.bax.h5
done

# convert .subreads.bam to fasta
mkdir -p ~/data/anchr/iso_1/3_pacbio/fasta
for movie in m131124_190051 m131124_221952 m131125_013854 m131125_045830 m131130_054035 m131130_091217 m131130_124231 m131130_161213 m131130_194336 m131130_231441 m131201_024805 m131201_061903 m131201_223357 m131202_020424 m131202_053545 m131202_090545 m131202_123546 m131202_160616 m131202_193958 m131202_231109;
do
    if [ ! -e ~/data/anchr/iso_1/3_pacbio/bam/${movie}*.subreads.bam ]; then
        continue
    fi

    samtools fasta \
        ~/data/anchr/iso_1/3_pacbio/bam/${movie}*.subreads.bam \
        > ~/data/anchr/iso_1/3_pacbio/fasta/${movie}.fasta
done

cd ~/data/anchr/iso_1
cat 3_pacbio/fasta/*.fasta > 3_pacbio/pacbio.fasta

```

## iso_1: template

* Rsync to hpcc

```bash
rsync -avP \
    --exclude="ERR70*" \
    --exclude="*.tgz" \
    ~/data/anchr/iso_1/ \
    wangq@202.119.37.251:data/anchr/iso_1

#rsync -avP wangq@202.119.37.251:data/anchr/iso_1/ ~/data/anchr/iso_1

```

* template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=iso_1
QUEUE_NAME=largemem

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 137567477 \
    --is_euk \
    --trim2 "--uniq --bbduk" \
    --cov2 "40 80 all" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --cov3 "all" \
    --qual3 "trim" \
    --mergereads \
    --ecphase "1,3" \
    --insertsize \
    --parallel 24

```

## iso_1: run

Same as [s288c: run](#s288c-run)

The `meryl` step of `canu` failed in hpcc, run it locally.

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 587.2 |    244 | 3424.7 |                         43.08% |
| tadpole.bbtools | 257.0 |    234 |  108.0 |                         34.81% |
| genome.picard   | 265.6 |    244 |  109.9 |                             FR |
| tadpole.picard  | 257.1 |    235 |  107.5 |                             FR |

| Name      |      N50 |       Sum |         # |
|:----------|---------:|----------:|----------:|
| Genome    | 25286936 | 137567477 |         8 |
| Paralogs  |     4031 |  13665900 |      4492 |
| Illumina  |      101 |    18.12G | 179363706 |
| uniq      |      101 |     17.6G | 174216504 |
| bbduk     |      100 |    17.19G | 172171728 |
| Q25L60    |      100 |    15.35G | 156287968 |
| Q30L60    |      100 |     13.8G | 142889881 |
| PacBio    |    13704 |     5.62G |    630193 |
| Xall.raw  |    13704 |     5.62G |    630193 |
| Xall.trim |    13572 |     5.22G |    541317 |

```text
#trimmedReads
#Matched	1603635	0.92048%
#Name	Reads	ReadsPct
Reverse_adapter	1142845	0.65599%
TruSeq_Adapter_Index_1_6	179124	0.10282%
Nextera_LMP_Read2_External_Adapter	65556	0.03763%
pcr_dimer	56653	0.03252%
TruSeq_Universal_Adapter	38420	0.02205%
PCR_Primers	27459	0.01576%
PhiX_read2_adapter	26653	0.01530%
TruSeq_Adapter_Index_5	11995	0.00689%
I5_Nextera_Transposase_1	7164	0.00411%
PhiX_read1_adapter	6300	0.00362%
RNA_Adapter_(RA5)_part_#_15013205	4605	0.00264%
I7_Nextera_Transposase_2	3780	0.00217%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	2970	0.00170%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	2904	0.00167%
Nextera_LMP_Read1_External_Adapter	2423	0.00139%
I5_Nextera_Transposase_2	1988	0.00114%
Bisulfite_R1	1929	0.00111%
I7_Adapter_Nextera_No_Barcode	1854	0.00106%
I5_Adapter_Nextera	1746	0.00100%
Bisulfite_R2	1576	0.00090%
RNA_PCR_Primer_(RP1)_part_#_15013198	1488	0.00085%
I7_Nextera_Transposase_1	1458	0.00084%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N701	1366	0.00078%
```

| Name         | N50 |     Sum |         # |
|:-------------|----:|--------:|----------:|
| clumped      | 101 |  14.38G | 142384532 |
| trimmed      | 100 |  12.92G | 130952807 |
| filtered     | 100 |  12.91G | 130895204 |
| ecco         | 100 |  12.87G | 130895204 |
| ecct         | 100 |  12.51G | 127176691 |
| extended     | 140 |  17.41G | 127176691 |
| merged       | 141 | 484.66M |   3482349 |
| unmerged.raw | 140 |  16.47G | 120211992 |
| unmerged     | 140 |  15.78G | 117386079 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 100.0 |    101 |  17.7 |          5.24% |
| ihist.merge.txt  | 139.2 |    141 |  24.9 |          5.48% |

```text
#trimmedReads
#Matched	1559087	1.09498%
#Name	Reads	ReadsPct
Reverse_adapter	1125442	0.79042%
TruSeq_Adapter_Index_1_6	172696	0.12129%
Nextera_LMP_Read2_External_Adapter	63296	0.04445%
pcr_dimer	53201	0.03736%
TruSeq_Universal_Adapter	37682	0.02646%
PCR_Primers	25826	0.01814%
PhiX_read2_adapter	21510	0.01511%
TruSeq_Adapter_Index_5	11966	0.00840%
I5_Nextera_Transposase_1	5773	0.00405%
PhiX_read1_adapter	5422	0.00381%
RNA_Adapter_(RA5)_part_#_15013205	3768	0.00265%
I7_Nextera_Transposase_2	3237	0.00227%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	2566	0.00180%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	2386	0.00168%
Nextera_LMP_Read1_External_Adapter	2132	0.00150%
I5_Nextera_Transposase_2	1778	0.00125%
I7_Adapter_Nextera_No_Barcode	1515	0.00106%
Bisulfite_R1	1405	0.00099%
I5_Adapter_Nextera	1348	0.00095%
RNA_PCR_Primer_(RP1)_part_#_15013198	1268	0.00089%
I7_Nextera_Transposase_1	1249	0.00088%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N701	1240	0.00087%
Bisulfite_R2	1216	0.00085%
```

```text
#filteredReads
#Matched	57603	0.04399%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	57365	0.04381%
```

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|--------:|--------:|---------:|----------:|
| Q25L60 | 111.6 |  101.2 |    9.35% |      98 | "71" | 137.57M |  127.2M |     0.92 | 0:41'30'' |
| Q30L60 | 100.4 |   94.0 |    6.43% |      98 | "71" | 137.57M | 126.25M |     0.92 | 0:37'57'' |

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  82.70% |     14495 | 114.47M | 14458 |      1047 | 4.46M | 52408 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:31'04'' | 0:17'11'' |
| Q25L60X40P001  |   40.0 |  82.74% |     14898 | 114.56M | 14339 |      1046 | 4.36M | 52049 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:30'52'' | 0:17'15'' |
| Q25L60X80P000  |   80.0 |  81.69% |     11717 | 114.12M | 16426 |      1055 | 4.39M | 47937 |   71.0 | 5.0 |  18.7 | 129.0 | "31,41,51,61,71,81" | 0:48'39'' | 0:16'18'' |
| Q25L60XallP000 |  101.2 |  81.08% |     10534 | 114.36M | 17672 |      1052 | 3.49M | 48040 |   90.0 | 6.0 |  20.0 | 162.0 | "31,41,51,61,71,81" | 0:58'20'' | 0:15'41'' |
| Q30L60X40P000  |   40.0 |  82.50% |     14611 | 113.56M | 14947 |      1058 | 4.74M | 51381 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:30'12'' | 0:16'38'' |
| Q30L60X40P001  |   40.0 |  82.52% |     14433 | 113.43M | 14953 |      1064 | 4.78M | 51043 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:30'28'' | 0:16'42'' |
| Q30L60X80P000  |   80.0 |  82.50% |     13057 | 113.82M | 15505 |      1067 | 4.72M | 48989 |   71.0 | 5.0 |  18.7 | 129.0 | "31,41,51,61,71,81" | 0:48'11'' | 0:17'44'' |
| Q30L60XallP000 |   94.0 |  82.27% |     12433 | 114.32M | 15869 |      1066 | 3.91M | 48462 |   83.0 | 7.0 |  20.0 | 156.0 | "31,41,51,61,71,81" | 0:54'02'' | 0:17'26'' |

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  83.75% |     19012 | 113.58M | 12566 |      1060 | 3.86M | 41856 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:14'16'' | 0:15'56'' |
| Q25L60X40P001  |   40.0 |  83.86% |     19198 | 113.62M | 12528 |      1058 | 3.92M | 42269 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:14'42'' | 0:16'17'' |
| Q25L60X80P000  |   80.0 |  84.52% |     19664 |  114.9M | 11756 |      1090 | 3.89M | 40430 |   71.0 | 5.0 |  18.7 | 129.0 | "31,41,51,61,71,81" | 0:20'34'' | 0:18'07'' |
| Q25L60XallP000 |  101.2 |  84.29% |     18477 | 115.46M | 12096 |      1241 | 3.15M | 39945 |   90.0 | 7.0 |  20.0 | 166.5 | "31,41,51,61,71,81" | 0:23'24'' | 0:18'14'' |
| Q30L60X40P000  |   40.0 |  83.29% |     15137 | 112.93M | 14705 |      1072 | 3.57M | 45904 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:14'09'' | 0:14'50'' |
| Q30L60X40P001  |   40.0 |  83.29% |     15296 | 112.88M | 14700 |      1068 | 3.59M | 45867 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:14'11'' | 0:14'50'' |
| Q30L60X80P000  |   80.0 |  84.32% |     17179 | 114.33M | 13047 |      1078 | 3.89M | 43817 |   71.0 | 6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:20'33'' | 0:17'42'' |
| Q30L60XallP000 |   94.0 |  84.36% |     17018 | 114.71M | 13079 |      1100 | 3.64M | 43728 |   83.0 | 7.0 |  20.0 | 156.0 | "31,41,51,61,71,81" | 0:23'13'' | 0:18'11'' |

| Name                |      N50 |       Sum |      # |
|:--------------------|---------:|----------:|-------:|
| Genome              | 25286936 | 137567477 |      8 |
| Paralogs            |     4031 |  13665900 |   4492 |
| Xall.trim.corrected |    13405 |     4.25G | 433377 |
| Xall.trim.contig    | 18542648 | 151436172 |    598 |

| Name                           |      N50 |       Sum |      # |
|:-------------------------------|---------:|----------:|-------:|
| Genome                         | 25286936 | 137567477 |      8 |
| Paralogs                       |     4031 |  13665900 |   4492 |
| 7_mergeKunitigsAnchors.anchors |    30271 | 116586070 |   9044 |
| 7_mergeKunitigsAnchors.others  |     1113 |   8739127 |   6698 |
| 7_mergeTadpoleAnchors.anchors  |    27248 | 116101033 |   9682 |
| 7_mergeTadpoleAnchors.others   |     1132 |   5764066 |   4165 |
| 7_mergeAnchors.anchors         |    30271 | 116598902 |   9045 |
| 7_mergeAnchors.others          |     1113 |   8739127 |   6698 |
| anchorLong                     |    33528 | 113050865 |   7860 |
| anchorFill                     |   258828 | 114990399 |   1813 |
| canu_Xall-trim                 | 18542648 | 151436172 |    598 |
| tadpole.Q25L60                 |     5353 | 117631504 |  56066 |
| tadpole.Q30L60                 |     6538 | 117555167 |  50957 |
| spades.contig                  |   122182 | 135283007 | 116485 |
| spades.scaffold                |   134548 | 135289047 | 116223 |
| spades.non-contained           |   134912 | 121320053 |   3707 |
| spades.anchor                  |   134895 | 118603503 |   3271 |
| megahit.contig                 |    51685 | 124597364 |  21279 |
| megahit.non-contained          |    54298 | 119025148 |   6488 |
| megahit.anchor                 |    55742 | 116412446 |   6175 |
| platanus.contig                |    11660 | 156689969 | 363019 |
| platanus.scaffold              |   145407 | 129336562 |  74119 |
| platanus.non-contained         |   160953 | 119874436 |   3213 |
| platanus.anchor                |   159200 | 117498506 |   3627 |


# *Caenorhabditis elegans* N2

* Genome: [Ensembl 82](http://sep2015.archive.ensembl.org/Caenorhabditis_elegans/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.0472

## n2: download

* Reference genome

```bash
mkdir -p ~/data/anchr/n2/1_genome
cd ~/data/anchr/n2/1_genome

wget -N ftp://ftp.ensembl.org/pub/release-82/fasta/caenorhabditis_elegans/dna/Caenorhabditis_elegans.WBcel235.dna_sm.toplevel.fa.gz
faops order Caenorhabditis_elegans.WBcel235.dna_sm.toplevel.fa.gz \
    <(for chr in {I,II,III,IV,V,X,MtDNA}; do echo $chr; done) \
    genome.fa

cp ~/data/anchr/paralogs/model/Results/n2/n2.multi.fas 1_genome/paralogs.fas
```

* Illumina

    * Other SRA
        * SRX770040 - [insert size](https://www.ncbi.nlm.nih.gov/sra/SRX770040[accn]) is 500-600 bp
        * ERR1039478 - adaptor contamination "ACTTCCAGGGATTTATAAGCCGATGACGTCATAACATCCCTGACCCTTTA"
        * DRR008443 - GA II
        * SRR065390 - GA II

```bash
# Downloading from ena with aria2
mkdir -p ~/data/anchr/n2/2_illumina
cd ~/data/anchr/n2/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR157/009/SRR1571299
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR157/002/SRR1571322
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
8b6c83b413af32eddb58c12044c5411b        SRR1571299
1951826a35d31272615afa19ea9a552c        SRR1571322
EOF

md5sum --check sra_md5.txt

for sra in SRR1571{299,322}; do
    echo ${sra}
    fastq-dump --split-files ./${sra}
done

cat SRR1571{299,322}_1.fastq > R1.fq
cat SRR1571{299,322}_2.fastq > R2.fq

find . -name "*.fq" | parallel -j 2 pigz -p 8
rm *.fastq

```

* PacBio

https://github.com/PacificBiosciences/DevNet/wiki/C.-elegans-data-set

```bash
mkdir -p ~/data/anchr/n2/3_pacbio/fasta
cd ~/data/anchr/n2/3_pacbio/fasta

perl -MMojo::UserAgent -e '
    my $url = q{http://datasets.pacb.com.s3.amazonaws.com/2014/c_elegans/wget.html};

    my $ua   = Mojo::UserAgent->new->max_redirects(10);
    my $tx   = $ua->get($url);
    my $base = $tx->req->url;

    $tx->res->dom->find(q{a})->map( sub { $base->new( $_->{href} )->to_abs($base) } )
        ->each( sub                     { print shift . "\n" } );
' \
    | grep subreads.fasta \
    > s3.url.txt

aria2c -x 9 -s 3 -c -i s3.url.txt
find . -type f -name "*.fasta" | parallel -j 2 pigz -p 8

cd ~/data/anchr/n2/3_pacbio
find fasta -type f -name "*.subreads.fasta.gz" \
    | sort \
    | xargs gzip -d -c \
    | faops filter -l 0 stdin pacbio.fasta

```

## n2: template

* Rsync to hpcc

```bash
rsync -avP \
    --exclude="SRR15*" \
    --exclude="*.tgz" \
    ~/data/anchr/n2/ \
    wangq@202.119.37.251:data/anchr/n2

#rsync -avP wangq@202.119.37.251:data/anchr/n2/ ~/data/anchr/n2

```

* template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=n2
QUEUE_NAME=largemem

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 100286401 \
    --is_euk \
    --trim2 "--uniq --bbduk" \
    --cov2 "40 50 60 all" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --cov3 "all" \
    --qual3 "trim" \
    --mergereads \
    --ecphase "1,3" \
    --insertsize \
    --parallel 24

```

## n2: run

Same as [s288c: run](#s288c-run)

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 253.4 |    207 | 1037.1 |                         41.49% |
| tadpole.bbtools | 210.3 |    202 |   71.2 |                         40.98% |
| genome.picard   | 214.1 |    207 |   68.3 |                             FR |
| tadpole.picard  | 211.2 |    203 |   68.7 |                             FR |

| Name      |      N50 |       Sum |         # |
|:----------|---------:|----------:|----------:|
| Genome    | 17493829 | 100286401 |         7 |
| Paralogs  |     2013 |   5313653 |      2637 |
| Illumina  |      100 |    11.56G | 115608926 |
| uniq      |      100 |    11.39G | 113889072 |
| bbduk     |      100 |    11.35G | 113795548 |
| Q25L60    |      100 |    10.27G | 106270873 |
| Q30L60    |      100 |      8.8G |  99242361 |
| PacBio    |    16572 |     8.12G |    740776 |
| Xall.raw  |    16572 |     8.12G |    740776 |
| Xall.trim |    16237 |     7.68G |    674732 |

```text
#trimmedReads
#Matched	957419	0.84066%
#Name	Reads	ReadsPct
TruSeq_Adapter_Index_1_6	393679	0.34567%
Reverse_adapter	225018	0.19758%
Nextera_LMP_Read2_External_Adapter	141451	0.12420%
pcr_dimer	81608	0.07166%
PCR_Primers	37756	0.03315%
PhiX_read2_adapter	26231	0.02303%
TruSeq_Universal_Adapter	19867	0.01744%
PhiX_read1_adapter	5849	0.00514%
I5_Nextera_Transposase_1	3884	0.00341%
RNA_Adapter_(RA5)_part_#_15013205	3554	0.00312%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	3036	0.00267%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	1942	0.00171%
I5_Adapter_Nextera	1798	0.00158%
Nextera_LMP_Read1_External_Adapter	1625	0.00143%
I7_Nextera_Transposase_2	1405	0.00123%
Bisulfite_R1	1363	0.00120%
```

| Name         | N50 |     Sum |        # |
|:-------------|----:|--------:|---------:|
| clumped      | 100 |    9.5G | 94973958 |
| trimmed      | 100 |   5.91G | 61619529 |
| filtered     | 100 |   5.91G | 61619401 |
| ecco         | 100 |   5.89G | 61619400 |
| ecct         | 100 |   5.77G | 60382317 |
| extended     | 140 |   7.94G | 60382317 |
| merged       | 140 | 213.25M |  1580218 |
| unmerged.raw | 140 |   7.52G | 57221880 |
| unmerged     | 140 |   7.33G | 55973436 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt |  97.4 |    100 |  15.0 |          5.02% |
| ihist.merge.txt  | 134.9 |    139 |  27.4 |          5.23% |

```text
#trimmedReads
#Matched	939865	0.98960%
#Name	Reads	ReadsPct
TruSeq_Adapter_Index_1_6	389471	0.41008%
Reverse_adapter	221692	0.23342%
Nextera_LMP_Read2_External_Adapter	140122	0.14754%
pcr_dimer	81254	0.08555%
PCR_Primers	37583	0.03957%
PhiX_read2_adapter	23219	0.02445%
TruSeq_Universal_Adapter	19612	0.02065%
PhiX_read1_adapter	5039	0.00531%
I5_Nextera_Transposase_1	3313	0.00349%
RNA_Adapter_(RA5)_part_#_15013205	3116	0.00328%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	2687	0.00283%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	1500	0.00158%
Nextera_LMP_Read1_External_Adapter	1380	0.00145%
I5_Adapter_Nextera	1350	0.00142%
I7_Nextera_Transposase_2	1082	0.00114%
Bisulfite_R1	1075	0.00113%
```

```text
#filteredReads
#Matched	128	0.00021%
#Name	Reads	ReadsPct
contam_43	103	0.00017%
```

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer |   RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|--------:|-------:|---------:|----------:|
| Q25L60 | 102.4 |   69.1 |   32.56% |      96 | "71" | 100.29M | 98.94M |     0.99 | 0:24'29'' |
| Q30L60 |  87.9 |   75.5 |   14.05% |      91 | "63" | 100.29M | 98.78M |     0.99 | 0:22'55'' |

| Name           | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  91.63% |     11455 | 86.67M | 14388 |      3482 |  9.1M | 59724 |   29.0 | 3.0 |   6.7 |  57.0 | "31,41,51,61,71,81" | 0:25'45'' | 0:19'52'' |
| Q25L60X50P000  |   50.0 |  91.68% |     11829 | 87.41M | 13912 |      3613 | 8.84M | 57306 |   36.0 | 4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:30'07'' | 0:20'06'' |
| Q25L60X60P000  |   60.0 |  91.77% |     12119 | 87.32M | 13548 |      2830 |  9.3M | 53456 |   43.0 | 5.0 |   9.3 |  86.0 | "31,41,51,61,71,81" | 0:33'54'' | 0:20'39'' |
| Q25L60XallP000 |   69.1 |  91.65% |     12041 | 87.54M | 13479 |      2896 | 9.13M | 49673 |   50.0 | 6.0 |  10.7 | 100.0 | "31,41,51,61,71,81" | 0:36'49'' | 0:20'05'' |
| Q30L60X40P000  |   40.0 |  91.94% |     11571 | 86.42M | 14665 |      5044 | 8.63M | 61402 |   30.0 | 3.0 |   7.0 |  58.5 | "31,41,51,61,71,81" | 0:23'59'' | 0:20'10'' |
| Q30L60X50P000  |   50.0 |  92.26% |     12311 | 86.95M | 13947 |      3686 | 9.29M | 59277 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:27'43'' | 0:20'40'' |
| Q30L60X60P000  |   60.0 |  92.43% |     12541 | 87.54M | 13527 |      4445 | 9.12M | 56973 |   44.0 | 5.0 |   9.7 |  88.0 | "31,41,51,61,71,81" | 0:31'44'' | 0:21'30'' |
| Q30L60XallP000 |   75.5 |  92.48% |     12971 | 87.57M | 12987 |      3280 | 9.47M | 52090 |   55.0 | 6.0 |  12.3 | 109.5 | "31,41,51,61,71,81" | 0:36'43'' | 0:21'41'' |

| Name           | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  91.84% |     11672 | 85.08M | 14624 |      8643 | 8.25M | 60612 |   29.0 | 3.0 |   6.7 |  57.0 | "31,41,51,61,71,81" | 0:13'48'' | 0:19'33'' |
| Q25L60X50P000  |   50.0 |  92.24% |     12609 | 86.51M | 14025 |      8727 | 8.11M | 56746 |   36.0 | 4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:16'33'' | 0:20'19'' |
| Q25L60X60P000  |   60.0 |  92.50% |     13200 | 87.07M | 13503 |      6643 | 8.74M | 55425 |   44.0 | 5.0 |   9.7 |  88.0 | "31,41,51,61,71,81" | 0:18'41'' | 0:20'54'' |
| Q25L60XallP000 |   69.1 |  92.69% |     13678 | 87.47M | 13089 |      6195 | 8.73M | 54417 |   50.0 | 6.0 |  10.7 | 100.0 | "31,41,51,61,71,81" | 0:20'52'' | 0:21'29'' |
| Q30L60X40P000  |   40.0 |  91.73% |     10766 | 84.49M | 15583 |     11057 | 8.12M | 64127 |   30.0 | 3.0 |   7.0 |  58.5 | "31,41,51,61,71,81" | 0:12'18'' | 0:18'57'' |
| Q30L60X50P000  |   50.0 |  92.32% |     11878 | 85.53M | 14442 |      8094 | 8.27M | 60153 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:14'30'' | 0:19'55'' |
| Q30L60X60P000  |   60.0 |  92.69% |     12678 | 86.59M | 14016 |      8082 | 8.28M | 58045 |   44.0 | 5.0 |   9.7 |  88.0 | "31,41,51,61,71,81" | 0:16'12'' | 0:21'16'' |
| Q30L60XallP000 |   75.5 |  93.01% |     13362 | 87.22M | 13321 |      4912 | 8.84M | 56401 |   56.0 | 6.0 |  12.7 | 111.0 | "31,41,51,61,71,81" | 0:19'52'' | 0:21'28'' |

| Name                |      N50 |       Sum |      # |
|:--------------------|---------:|----------:|-------:|
| Genome              | 17493829 | 100286401 |      7 |
| Paralogs            |     2013 |   5313653 |   2637 |
| Xall.trim.corrected |    18340 |     3.86G | 207189 |
| Xall.trim.contig    |  2859614 | 107313895 |    109 |

| Name                           |      N50 |       Sum |      # |
|:-------------------------------|---------:|----------:|-------:|
| Genome                         | 17493829 | 100286401 |      7 |
| Paralogs                       |     2013 |   5313653 |   2637 |
| 7_mergeKunitigsAnchors.anchors |    15054 |  88875682 |  12131 |
| 7_mergeKunitigsAnchors.others  |     1676 |  15368215 |   8379 |
| 7_mergeTadpoleAnchors.anchors  |    14496 |  88532967 |  12846 |
| 7_mergeTadpoleAnchors.others   |     1733 |  11210853 |   5841 |
| 7_mergeAnchors.anchors         |    15965 |  89499082 |  11834 |
| 7_mergeAnchors.others          |     1674 |  15381901 |   8394 |
| anchorLong                     |    19121 |  88485194 |   9739 |
| anchorFill                     |   291112 |  94506949 |    706 |
| canu_Xall-trim                 |  2859614 | 107313895 |    109 |
| tadpole.Q25L60                 |     3837 |  94593564 |  69582 |
| tadpole.Q30L60                 |     4271 |  94469980 |  66996 |
| spades.contig                  |    29673 | 105876756 |  61471 |
| spades.scaffold                |    30950 | 105884603 |  61199 |
| spades.non-contained           |    33095 |  97926489 |   7021 |
| spades.anchor                  |    31899 |  90290943 |   7064 |
| megahit.contig                 |    17406 | 100576603 |  21324 |
| megahit.non-contained          |    18749 |  96036564 |  10792 |
| megahit.anchor                 |    18189 |  88164063 |  10373 |
| platanus.contig                |     9539 | 108793136 | 144048 |
| platanus.scaffold              |    27945 |  99675198 |  36258 |
| platanus.non-contained         |    30361 |  94028598 |   7681 |
| platanus.anchor                |    31537 |  88191088 |   7247 |

# *Arabidopsis thaliana* Col-0

* Genome: [Ensembl Genomes](http://plants.ensembl.org/Arabidopsis_thaliana/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.1158

## col_0: download

* Reference genome

```bash
mkdir -p ~/data/anchr/col_0/1_genome
cd ~/data/anchr/col_0/1_genome

wget -N ftp://ftp.ensemblgenomes.org/pub/release-29/plants/fasta/arabidopsis_thaliana/dna/Arabidopsis_thaliana.TAIR10.29.dna_sm.toplevel.fa.gz
faops order Arabidopsis_thaliana.TAIR10.29.dna_sm.toplevel.fa.gz \
    <(for chr in {1,2,3,4,5,Mt,Pt}; do echo $chr; done) \
    genome.fa
```

* Illumina MiSeq

    [SRX2527206](https://www.ncbi.nlm.nih.gov/sra/SRX2527206[accn]) SRR5216995

```bash
BASE_NAME=col_0
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina
cd 2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR521/005/SRR5216995/SRR5216995_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR521/005/SRR5216995/SRR5216995_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
ce4a92a9364a6773633223ff7a807810 SRR5216995_1.fastq.gz
5c6672124a628ea0020c88e74eff53a3 SRR5216995_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s SRR5216995_1.fastq.gz R1.fq.gz
ln -s SRR5216995_2.fastq.gz R2.fq.gz

```

* PacBio

Chin, C.-S. *et al.* Phased diploid genome assembly with single-molecule real-time sequencing.
*Nature Methods* (2016). doi:10.1038/nmeth.4035

P4C2 is not supported in newer version of SMRTAnalysis.

https://www.ncbi.nlm.nih.gov/biosample/4539665

[SRX1715692](https://www.ncbi.nlm.nih.gov/sra/SRX1715692)

```bash
mkdir -p ~/data/anchr/col_0/3_pacbio
cd ~/data/anchr/col_0/3_pacbio

cat <<EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/002/SRR3405242
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/003/SRR3405243
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/004/SRR3405244
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/006/SRR3405246
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/008/SRR3405248
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/000/SRR3405250
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/002/SRR3405252
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/003/SRR3405253
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/004/SRR3405254
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/005/SRR3405255
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/006/SRR3405256
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/007/SRR3405257
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/008/SRR3405258
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/009/SRR3405259
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/005/SRR3405245
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/007/SRR3405247
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/009/SRR3405249
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/001/SRR3405251
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/000/SRR3405260
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/003/SRR3405263
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/005/SRR3405265
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/007/SRR3405267
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/009/SRR3405269
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/001/SRR3405271
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/004/SRR3405274
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/005/SRR3405275
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/006/SRR3405276
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/007/SRR3405277
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/008/SRR3405278
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/009/SRR3405279
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/000/SRR3405280
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/001/SRR3405281
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/002/SRR3405282
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/003/SRR3405283
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/004/SRR3405284
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/005/SRR3405285
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/006/SRR3405286
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/007/SRR3405287
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/008/SRR3405288
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/009/SRR3405289
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/000/SRR3405290
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/001/SRR3405261
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/002/SRR3405262
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/004/SRR3405264
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/006/SRR3405266
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/008/SRR3405268
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/000/SRR3405270
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/002/SRR3405272
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/003/SRR3405273
EOF

aria2c -x 6 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
be9c803f847ff1c81d153110cc699390        SRR3405242
c68a2c3b62245a697722fd3f8fda7a2d        SRR3405243
7116e8a0de87b1acd016d9b284e4795c        SRR3405244
51f8e5ee4565aace4e5a5cba73e3e597        SRR3405246
f339f580e86aad3a5487b5cec8ae80d4        SRR3405248
1a8246ed1f7c38801cfc603e088abb70        SRR3405250
a0ce8435a7fa2e7ddbd6ac181902f751        SRR3405252
8754f69a1c8c1f00b58b48454c1c01ad        SRR3405253
367508500303325e855666133505a5af        SRR3405254
d250f69fcf2975c89ceab5a4f9425b36        SRR3405255
badd9b2d23f94d1c98263d2e786742ae        SRR3405256
6c5cbd3bce9459283a415d8a5c05c86e        SRR3405257
32da7a364c8cbda5cf76b87f7c51b475        SRR3405258
eb3819adf483451ac670f89d1ea6b76e        SRR3405259
5337862eeb0945f932de74e8f7b9ec4f        SRR3405245
4545ce4666878fcbcda1e7737be1896b        SRR3405247
71d61bc64e3ca9b91f08b1c6b1389f16        SRR3405249
b9a911b8eb4fbfe29dff8cf920429f18        SRR3405251
99bae070fa90d53c8f15b9cf42c634f6        SRR3405260
830e02f1f3cb66b9e085803a21ad8040        SRR3405263
86d28c63f00095ae0ff1151e7e0bf7b4        SRR3405265
3e048ad8dbb526d4a533ee1d5ec10a43        SRR3405267
1b73ed3a1124f5f025c511672c1e18d3        SRR3405269
fa07c85b9e6258abcef8bdb730ab812f        SRR3405271
aeb6ab7edfa42e5e27704b7625c659c1        SRR3405274
0eb24fcc9b40f6fe0f013fe79dd7edf7        SRR3405275
f051e0065602477e0a1d13a6d0a42d3d        SRR3405276
178540e33e9f4f76adc8509b147d7ff6        SRR3405277
6fdfa97e2eacf0ac186b5333e97c334b        SRR3405278
a6bb6b57db82eb6e4161847f9d35a608        SRR3405279
8399b8e8e4d48c7374a414a9585efa5b        SRR3405280
e725278a3837775e214b39093a900927        SRR3405281
fab9120bfa1130b300f7e82b74d23173        SRR3405282
33929263f09811d7f7360a9675e82cdd        SRR3405283
7f9e58c6fa43e8f2f3fa2496e149d2cb        SRR3405284
b9a469affbff1bdcb1b299c106c2c1b9        SRR3405285
688ab23dbfe7977f9de780486a8d5c6b        SRR3405286
fadc273d324413017e45570e3bf0ee6e        SRR3405287
6f4b0eb22cb523ddecb842042d500ceb        SRR3405288
03a4581c1b951dba3bb9e295e9113bf3        SRR3405289
51fa78f451a33bd44f985ac220e17efe        SRR3405290
fac8c4c2a862a4d572d77d0deb4b0abc        SRR3405261
3fd1a3d8140cfa96a0287e9e2b6055c4        SRR3405262
f908e6194fb3a0026b5263acadbd2600        SRR3405264
e04a7d96ba91ebb11772c019981ea9eb        SRR3405266
784e28febf413c6dfa842802aa106a55        SRR3405268
05b91a051fc52417858e93ce3b22fe2e        SRR3405270
07bca433005313a4a2c8050e32952f58        SRR3405272
a9bbee29c3d507760c4c33fbbe436fa6        SRR3405273
EOF

md5sum --check sra_md5.txt

for sra in SRR34052{42,43,44,46,48,50,52,53,54,55,56,57,58,59,45,47,49,51,60,63,65,67,69,71,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,61,62,64,66,68,70,72,73}; do
    echo ${sra}
    fastq-dump ./${sra}
done

cat SRR34052{42,43,44,46,48,50,52,53,54,55,56,57,58,59,45,47,49,51,60,63,65,67,69,71,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,61,62,64,66,68,70,72,73}.fastq \
    > pacbio.fq

find . -name "*.fq" | parallel -j 2 pigz -p 8
rm *.fastq

faops filter -l 0 pacbio.fq.gz pacbio.fasta

```

## col_0: template

* Rsync to hpcc

```bash
rsync -avP \
    --exclude="SRR340*" \
    --exclude="SRR61*" \
    --exclude="*.tgz" \
    ~/data/anchr/col_0/ \
    wangq@202.119.37.251:data/anchr/col_0

#rsync -avP wangq@202.119.37.251:data/anchr/col_0/ ~/data/anchr/col_0

```

* template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=col_0
QUEUE_NAME=largemem

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 119667750 \
    --is_euk \
    --trim2 "--uniq --bbduk" \
    --cov2 "40 50 60 all" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --cov3 "all" \
    --qual3 "trim" \
    --mergereads \
    --ecphase "1,3" \
    --insertsize \
    --parallel 24

```

## col_0: run

Same as [s288c: run](#s288c-run)

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 419.7 |    340 | 1245.4 |                         48.78% |
| tadpole.bbtools | 340.6 |    324 |  115.1 |                         39.56% |
| genome.picard   | 396.4 |    377 |  110.0 |                             FR |
| genome.picard   | 255.3 |    268 |   52.6 |                             RF |
| tadpole.picard  | 378.7 |    363 |  109.1 |                             FR |
| tadpole.picard  | 245.0 |    255 |   51.5 |                             RF |

| Name      |      N50 |       Sum |        # |
|:----------|---------:|----------:|---------:|
| Genome    | 23459830 | 119667750 |        7 |
| Paralogs  |     2007 |  16447809 |     8055 |
| Illumina  |      301 |    15.53G | 53786130 |
| uniq      |      301 |    15.53G | 53779068 |
| bbduk     |      300 |    15.28G | 53573488 |
| Q25L60    |      258 |    12.15G | 51410292 |
| Q30L60    |      239 |    10.34G | 48039949 |
| PacBio    |     6754 |    18.77G |  5721958 |
| Xall.raw  |     6754 |    18.77G |  5721958 |
| Xall.trim |     7329 |     7.72G |  1353993 |

```text
#trimmedReads
#Matched	1037986	1.93009%
#Name	Reads	ReadsPct
Reverse_adapter	431006	0.80144%
TruSeq_Universal_Adapter	286704	0.53311%
pcr_dimer	92502	0.17200%
Nextera_LMP_Read2_External_Adapter	60004	0.11158%
PCR_Primers	53364	0.09923%
TruSeq_Adapter_Index_1_6	44957	0.08360%
PhiX_read2_adapter	14145	0.02630%
Bisulfite_R2	6805	0.01265%
Bisulfite_R1	5582	0.01038%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]517	4327	0.00805%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	4235	0.00787%
PhiX_read1_adapter	4144	0.00771%
Nextera_LMP_Read1_External_Adapter	4047	0.00753%
I5_Primer_Nextera_XT_Index_Kit_v2_S516	3235	0.00602%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]506	2749	0.00511%
I5_Primer_Nextera_XT_Index_Kit_v2_S513	2552	0.00475%
I5_Nextera_Transposase_1	1895	0.00352%
I5_Primer_Nextera_XT_Index_Kit_v2_S511	1387	0.00258%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]502	1332	0.00248%
RNA_Adapter_(RA5)_part_#_15013205	1324	0.00246%
```

| Name         | N50 |     Sum |        # |
|:-------------|----:|--------:|---------:|
| clumped      | 301 |  15.52G | 53765032 |
| trimmed      | 276 |  13.42G | 52867014 |
| filtered     | 276 |  13.42G | 52866548 |
| ecco         | 276 |  13.41G | 52866548 |
| ecct         | 280 |  10.96G | 42167194 |
| extended     | 319 |  12.59G | 42167194 |
| merged       | 413 |   8.03G | 20179118 |
| unmerged.raw | 289 | 440.19M |  1808958 |
| unmerged     | 242 | 279.88M |  1395008 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 336.0 |    334 |  86.3 |         64.83% |
| ihist.merge.txt  | 397.7 |    387 | 104.7 |         95.71% |

```text
#trimmedReads
#Matched	1037654	1.92998%
#Name	Reads	ReadsPct
Reverse_adapter	430777	0.80122%
TruSeq_Universal_Adapter	286644	0.53314%
pcr_dimer	92485	0.17202%
Nextera_LMP_Read2_External_Adapter	60003	0.11160%
PCR_Primers	53353	0.09923%
TruSeq_Adapter_Index_1_6	44955	0.08361%
PhiX_read2_adapter	14140	0.02630%
Bisulfite_R2	6805	0.01266%
Bisulfite_R1	5581	0.01038%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]517	4327	0.00805%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	4235	0.00788%
PhiX_read1_adapter	4144	0.00771%
Nextera_LMP_Read1_External_Adapter	4047	0.00753%
I5_Primer_Nextera_XT_Index_Kit_v2_S516	3235	0.00602%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]506	2749	0.00511%
I5_Primer_Nextera_XT_Index_Kit_v2_S513	2552	0.00475%
I5_Nextera_Transposase_1	1895	0.00352%
I5_Primer_Nextera_XT_Index_Kit_v2_S511	1387	0.00258%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]502	1332	0.00248%
RNA_Adapter_(RA5)_part_#_15013205	1324	0.00246%
```

```text
#filteredReads
#Matched	260	0.00049%
#Name	Reads	ReadsPct
```

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|--------:|--------:|---------:|----------:|
| Q25L60 | 101.6 |   73.8 |   27.37% |     236 | "127" | 119.67M | 126.08M |     1.05 | 0:23'54'' |
| Q30L60 |  86.4 |   73.9 |   14.53% |     217 | "127" | 119.67M | 119.08M |     1.00 | 0:21'24'' |

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  69.12% |     17907 | 105.04M | 11666 |       749 | 3.88M | 30420 |   27.0 | 2.0 |   7.0 |  49.5 | "31,41,51,61,71,81" | 0:36'14'' | 0:12'17'' |
| Q25L60X50P000  |   50.0 |  68.91% |     16378 | 104.61M | 12273 |       633 | 4.34M | 31854 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:42'17'' | 0:12'09'' |
| Q25L60X60P000  |   60.0 |  68.86% |     15449 | 105.31M | 12388 |       130 | 3.49M | 33328 |   41.0 | 3.0 |  10.7 |  75.0 | "31,41,51,61,71,81" | 0:47'31'' | 0:13'00'' |
| Q25L60XallP000 |   73.8 |  68.84% |     14232 | 105.24M | 13059 |       110 | 3.61M | 36399 |   50.0 | 4.0 |  12.7 |  93.0 | "31,41,51,61,71,81" | 0:55'47'' | 0:13'48'' |
| Q30L60X40P000  |   40.0 |  73.88% |     22004 | 105.95M | 10103 |       710 | 3.33M | 28577 |   29.0 | 2.0 |   7.7 |  52.5 | "31,41,51,61,71,81" | 0:35'00'' | 0:13'16'' |
| Q30L60X50P000  |   50.0 |  73.80% |     22009 | 105.84M | 10148 |       804 | 3.44M | 28452 |   36.0 | 2.0 |  10.0 |  63.0 | "31,41,51,61,71,81" | 0:40'49'' | 0:13'06'' |
| Q30L60X60P000  |   60.0 |  73.70% |     21765 | 106.22M |  9944 |       366 | 2.94M | 28129 |   44.0 | 3.0 |  11.7 |  79.5 | "31,41,51,61,71,81" | 0:47'54'' | 0:13'26'' |
| Q30L60XallP000 |   73.9 |  73.59% |     21256 | 106.01M | 10117 |       732 | 3.24M | 28605 |   54.0 | 3.0 |  15.0 |  94.5 | "31,41,51,61,71,81" | 0:54'37'' | 0:13'46'' |

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  80.83% |     21789 | 105.58M | 10351 |       970 |    4M | 29218 |   27.0 | 2.0 |   7.0 |  49.5 | "31,41,51,61,71,81" | 0:16'14'' | 0:12'59'' |
| Q25L60X50P000  |   50.0 |  80.68% |     22589 | 106.23M |  9665 |       785 | 3.06M | 26884 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:17'41'' | 0:12'40'' |
| Q25L60X60P000  |   60.0 |  80.53% |     22770 | 106.16M |  9657 |       924 | 3.14M | 25945 |   41.0 | 3.0 |  10.7 |  75.0 | "31,41,51,61,71,81" | 0:20'15'' | 0:12'37'' |
| Q25L60XallP000 |   73.8 |  80.36% |     22083 | 106.02M |  9851 |      1004 | 3.32M | 25611 |   51.0 | 3.0 |  14.0 |  90.0 | "31,41,51,61,71,81" | 0:22'11'' | 0:12'19'' |
| Q30L60X40P000  |   40.0 |  84.70% |     21504 | 105.99M | 10241 |       796 | 3.59M | 31121 |   29.0 | 2.0 |   7.7 |  52.5 | "31,41,51,61,71,81" | 0:16'12'' | 0:13'36'' |
| Q30L60X50P000  |   50.0 |  84.65% |     22837 | 105.99M |  9960 |       920 | 3.55M | 29212 |   36.0 | 2.0 |  10.0 |  63.0 | "31,41,51,61,71,81" | 0:17'04'' | 0:13'36'' |
| Q30L60X60P000  |   60.0 |  84.57% |     23574 | 106.46M |  9457 |       844 | 2.92M | 27461 |   44.0 | 3.0 |  11.7 |  79.5 | "31,41,51,61,71,81" | 0:19'37'' | 0:13'44'' |
| Q30L60XallP000 |   73.9 |  84.49% |     24117 | 106.48M |  9369 |      1011 | 3.19M | 26424 |   54.0 | 3.0 |  15.0 |  94.5 | "31,41,51,61,71,81" | 0:20'44'' | 0:13'35'' |

| Name                |      N50 |       Sum |      # |
|:--------------------|---------:|----------:|-------:|
| Genome              | 23459830 | 119667750 |      7 |
| Paralogs            |     2007 |  16447809 |   8055 |
| Xall.trim.corrected |     7477 |     4.46G | 661124 |
| Xall.trim.contig    |  5997654 | 121555181 |    265 |

| Name                           |      N50 |       Sum |      # |
|:-------------------------------|---------:|----------:|-------:|
| Genome                         | 23459830 | 119667750 |      7 |
| Paralogs                       |     2007 |  16447809 |   8055 |
| 7_mergeKunitigsAnchors.anchors |    28512 | 107742213 |   8449 |
| 7_mergeKunitigsAnchors.others  |     1182 |   5434964 |   4319 |
| 7_mergeTadpoleAnchors.anchors  |    26909 | 107388764 |   8737 |
| 7_mergeTadpoleAnchors.others   |     1196 |   3848342 |   3001 |
| 7_mergeAnchors.anchors         |    28512 | 107726209 |   8449 |
| 7_mergeAnchors.others          |     1182 |   5442970 |   4326 |
| anchorLong                     |    29561 | 107449744 |   8164 |
| anchorFill                     |  1160299 | 109462778 |    555 |
| canu_Xall-trim                 |  5997654 | 121555181 |    265 |
| tadpole.Q25L60                 |     4513 | 109057953 |  95442 |
| tadpole.Q30L60                 |     5164 | 107886497 |  87705 |
| spades.contig                  |    58236 | 156805082 | 160567 |
| spades.scaffold                |    62989 | 156808267 | 160410 |
| spades.non-contained           |   108359 | 115385167 |   4477 |
| spades.anchor                  |   112039 | 111264044 |   3334 |
| megahit.contig                 |    29553 | 120480399 |  36050 |
| megahit.non-contained          |    33556 | 109603529 |   8598 |
| megahit.anchor                 |    34828 | 105485207 |   7931 |
| platanus.contig                |    15243 | 139505037 | 105243 |
| platanus.scaffold              |   187447 | 128262857 |  66059 |
| platanus.non-contained         |   217833 | 116408310 |   2039 |
| platanus.anchor                |   210246 | 115342282 |   1921 |

# col_0H

## col_0H: download

* Reference genome

```bash
mkdir -p ${HOME}/data/anchr/col_0H
cd ${HOME}/data/anchr/col_0H

mkdir -p 1_genome
cd 1_genome

cp ~/data/anchr/col_0/1_genome/genome.fa .
cp ~/data/anchr/col_0/1_genome/paralogs.fas .

```

* Illumina HiSeq (pe100)

    [SRX202246](https://www.ncbi.nlm.nih.gov/sra/SRX202246)

```bash
cd ${HOME}/data/anchr/col_0H

mkdir -p 2_illumina
cd 2_illumina

# Downloading from ena with aria2
cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR611/SRR611086
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR616/SRR616966
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
b884e83b47c485c9a07f732b3805e7cf    SRR611086
102db119d1040c3bf85af5e4da6e456d    SRR616966
EOF

md5sum --check sra_md5.txt

for sra in SRR61{1086,6966}; do
    echo ${sra}
    fastq-dump --split-files ./${sra}
done

cat SRR61{1086,6966}_1.fastq > R1.fq
cat SRR61{1086,6966}_2.fastq > R2.fq

find . -name "*.fq" | parallel -j 2 pigz -p 8
rm *.fastq

```

## col_0H: template

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/anchr/col_0H/ \
    wangq@202.119.37.251:data/anchr/col_0H

#rsync -avP wangq@202.119.37.251:data/anchr/col_0H/ ~/data/anchr/col_0H

```

* template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=col_0H
QUEUE_NAME=largemem

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 119667750 \
    --is_euk \
    --trim2 "--uniq --bbduk" \
    --cov2 "40 50 60 all" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,3" \
    --insertsize \
    --parallel 24

```

## col_0H: run

Same as [s288c: run](#s288c-run)

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 643.4 |    472 | 2200.4 |                         38.56% |
| tadpole.bbtools | 451.6 |    470 |   89.3 |                         26.89% |
| genome.picard   | 467.2 |    472 |   37.0 |                             FR |
| tadpole.picard  | 452.2 |    470 |   78.7 |                             FR |

| Name     |      N50 |       Sum |         # |
|:---------|---------:|----------:|----------:|
| Genome   | 23459830 | 119667750 |         7 |
| Paralogs |     2007 |  16447809 |      8055 |
| Illumina |      100 |    14.95G | 149486290 |
| uniq     |      100 |    14.46G | 144631354 |
| bbduk    |      100 |    14.46G | 144631276 |
| Q25L60   |      100 |    12.74G | 130797998 |
| Q30L60   |      100 |    11.24G | 117453711 |

```text
#trimmedReads
#Matched	71844	0.04967%
#Name	Reads	ReadsPct
PhiX_read2_adapter	23641	0.01635%
Reverse_adapter	9496	0.00657%
I5_Nextera_Transposase_1	5833	0.00403%
PhiX_read1_adapter	5136	0.00355%
RNA_Adapter_(RA5)_part_#_15013205	3565	0.00246%
Nextera_LMP_Read2_External_Adapter	3439	0.00238%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	2725	0.00188%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	1855	0.00128%
Nextera_LMP_Read1_External_Adapter	1649	0.00114%
I7_Nextera_Transposase_2	1645	0.00114%
TruSeq_Universal_Adapter	1414	0.00098%
TruSeq_Adapter_Index_1_6	1383	0.00096%
I7_Adapter_Nextera_No_Barcode	1305	0.00090%
I5_Adapter_Nextera	1273	0.00088%
I5_Nextera_Transposase_2	1244	0.00086%
Bisulfite_R2	1127	0.00078%
Bisulfite_R1	1098	0.00076%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N701	1034	0.00071%
```

| Name         | N50 |     Sum |         # |
|:-------------|----:|--------:|----------:|
| clumped      | 100 |  11.52G | 115177851 |
| trimmed      | 100 |  10.92G | 111626078 |
| filtered     | 100 |  10.92G | 111625985 |
| ecco         | 100 |   10.9G | 111625984 |
| ecct         | 100 |   8.74G |  89358903 |
| extended     | 140 |  12.05G |  89358903 |
| merged       | 140 | 287.32M |   2115294 |
| unmerged.raw | 140 |   11.5G |  85128314 |
| unmerged     | 140 |  10.87G |  82281182 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt |  99.8 |    100 |  17.9 |          4.23% |
| ihist.merge.txt  | 135.8 |    139 |  25.7 |          4.73% |

```text
#trimmedReads
#Matched	58413	0.05072%
#Name	Reads	ReadsPct
PhiX_read2_adapter	17628	0.01531%
Reverse_adapter	7738	0.00672%
I5_Nextera_Transposase_1	5069	0.00440%
PhiX_read1_adapter	4659	0.00405%
RNA_Adapter_(RA5)_part_#_15013205	3136	0.00272%
Nextera_LMP_Read2_External_Adapter	2884	0.00250%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	2030	0.00176%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	1662	0.00144%
I7_Nextera_Transposase_2	1493	0.00130%
Nextera_LMP_Read1_External_Adapter	1318	0.00114%
TruSeq_Universal_Adapter	1204	0.00105%
I5_Nextera_Transposase_2	1153	0.00100%
I5_Adapter_Nextera	1144	0.00099%
```

```text
#filteredReads
#Matched	93	0.00008%
#Name	Reads	ReadsPct
```

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|--------:|--------:|---------:|----------:|
| Q25L60 | 106.6 |   88.6 |   16.82% |      98 | "71" | 119.67M | 279.86M |     2.34 | 0:35'04'' |
| Q30L60 |  94.0 |   79.4 |   15.54% |      96 | "71" | 119.67M | 246.46M |     2.06 | 0:30'57'' |

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |     # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|-------:|------:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  69.73% |     11975 | 104.27M | 15824 |      1067 |  7.12M | 60491 |   25.0 |  1.0 |   7.3 |  42.0 | "31,41,51,61,71,81" | 0:30'08'' | 0:15'33'' |
| Q25L60X40P001  |   40.0 |  69.79% |     12051 | 104.27M | 15778 |      1065 |  7.01M | 60634 |   25.0 |  1.0 |   7.3 |  42.0 | "31,41,51,61,71,81" | 0:30'23'' | 0:16'02'' |
| Q25L60X50P000  |   50.0 |  70.35% |     12318 | 106.17M | 15513 |      1220 |  8.63M | 61396 |   30.0 |  2.0 |   8.0 |  54.0 | "31,41,51,61,71,81" | 0:35'44'' | 0:16'37'' |
| Q25L60X60P000  |   60.0 |  70.89% |     12639 | 106.87M | 15129 |      1335 | 13.21M | 62928 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:40'59'' | 0:17'38'' |
| Q25L60XallP000 |   88.6 |  71.63% |      9931 | 135.11M | 30245 |      1021 |  4.32M | 78017 |   46.0 | 13.0 |   3.0 |  92.0 | "31,41,51,61,71,81" | 0:54'55'' | 0:19'18'' |
| Q30L60X40P000  |   40.0 |  70.65% |     10899 |  104.2M | 16850 |      1035 |  4.72M | 61436 |   25.0 |  2.0 |   6.3 |  46.5 | "31,41,51,61,71,81" | 0:28'59'' | 0:15'21'' |
| Q30L60X50P000  |   50.0 |  71.35% |     11581 | 105.15M | 16150 |      1123 |  7.13M | 61598 |   31.0 |  2.0 |   8.3 |  55.5 | "31,41,51,61,71,81" | 0:35'04'' | 0:16'18'' |
| Q30L60X60P000  |   60.0 |  71.84% |     12010 | 105.95M | 15682 |      1255 | 10.29M | 62458 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:39'07'' | 0:17'05'' |
| Q30L60XallP000 |   79.4 |  72.66% |     12480 | 107.18M | 15338 |      1419 | 19.05M | 64684 |   48.0 |  6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:48'29'' | 0:17'29'' |

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  78.20% |     10475 | 101.99M | 17071 |      1012 |  5.19M | 65176 |   25.0 | 1.0 |   7.3 |  42.0 | "31,41,51,61,71,81" | 0:13'45'' | 0:15'41'' |
| Q25L60X40P001  |   40.0 |  78.24% |     10595 | 102.01M | 16952 |      1011 |  5.17M | 64941 |   25.0 | 1.0 |   7.3 |  42.0 | "31,41,51,61,71,81" | 0:13'41'' | 0:15'38'' |
| Q25L60X50P000  |   50.0 |  78.68% |     11677 | 103.72M | 15871 |      1033 |  4.82M | 60221 |   31.0 | 2.0 |   8.3 |  55.5 | "31,41,51,61,71,81" | 0:15'58'' | 0:16'23'' |
| Q25L60X60P000  |   60.0 |  79.20% |     12284 | 104.75M | 15494 |      1092 |  6.32M | 58947 |   37.0 | 2.0 |  10.3 |  64.5 | "31,41,51,61,71,81" | 0:18'06'' | 0:16'41'' |
| Q25L60XallP000 |   88.6 |  80.49% |     13439 | 107.07M | 14708 |      1375 | 13.32M | 62095 |   53.0 | 5.0 |  12.7 | 102.0 | "31,41,51,61,71,81" | 0:23'32'' | 0:18'47'' |
| Q30L60X40P000  |   40.0 |  79.41% |      8981 | 101.82M | 18849 |      1006 |  3.86M | 68415 |   25.0 | 2.0 |   6.3 |  46.5 | "31,41,51,61,71,81" | 0:12'55'' | 0:15'35'' |
| Q30L60X50P000  |   50.0 |  79.93% |     10105 | 103.05M | 17419 |      1015 |  4.21M | 64010 |   32.0 | 2.0 |   8.7 |  57.0 | "31,41,51,61,71,81" | 0:15'12'' | 0:15'51'' |
| Q30L60X60P000  |   60.0 |  80.39% |     10818 | 104.06M | 16820 |      1035 |  5.14M | 62150 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:17'32'' | 0:16'31'' |
| Q30L60XallP000 |   79.4 |  81.13% |     11721 | 105.42M | 15946 |      1179 |  8.14M | 62665 |   50.0 | 3.0 |  13.7 |  88.5 | "31,41,51,61,71,81" | 0:21'23'' | 0:16'57'' |

| Name                           |      N50 |       Sum |      # |
|:-------------------------------|---------:|----------:|-------:|
| Genome                         | 23459830 | 119667750 |      7 |
| Paralogs                       |     2007 |  16447809 |   8055 |
| 7_mergeKunitigsAnchors.anchors |    12016 | 135707549 |  28582 |
| 7_mergeKunitigsAnchors.others  |     1345 |  39389985 |  27651 |
| 7_mergeTadpoleAnchors.anchors  |    14370 | 107496214 |  14253 |
| 7_mergeTadpoleAnchors.others   |     1312 |  19106502 |  13671 |
| 7_mergeAnchors.anchors         |    12016 | 135716086 |  28590 |
| 7_mergeAnchors.others          |     1345 |  39391084 |  27652 |
| tadpole.Q25L60                 |      494 | 229351949 | 620298 |
| tadpole.Q30L60                 |      621 | 197869414 | 519364 |
| spades.contig                  |     3091 | 373674609 | 472715 |
| spades.scaffold                |     5723 | 378661350 | 399868 |
| spades.non-contained           |    10809 | 245723776 |  50159 |
| spades.anchor                  |     1070 |      1070 |      1 |
| megahit.contig                 |     3555 | 255595895 | 197372 |
| megahit.non-contained          |     8497 | 194304706 |  48694 |
| megahit.anchor                 |     1070 |      1070 |      1 |
| platanus.contig                |     7434 | 133533781 | 262736 |
| platanus.scaffold              |    70787 | 118894657 |  11124 |
| platanus.non-contained         |    72444 | 116299742 |   4486 |
| platanus.anchor                |    71109 | 111877064 |   5138 |


# *Oryza sativa* Japonica Group Nipponbare

* Genome: [Ensembl Genomes](http://plants.ensembl.org/Oryza_sativa/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.16

## nip: download

* Reference genome

```bash
mkdir -p ~/data/anchr/nip/1_genome
cd ~/data/anchr/nip/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ensemblgenomes.org/pub/release-29/plants/fasta/oryza_sativa/dna/Oryza_sativa.IRGSP-1.0.29.dna_sm.toplevel.fa.gz
faops order Oryza_sativa.IRGSP-1.0.29.dna_sm.toplevel.fa.gz \
    <(for chr in $(seq 1 1 12); do echo $chr; done) \
    genome.fa

cp ~/data/anchr/paralogs/model/Results/nip/nip.multi.fas paralogs.fas

```

* Illumina HiSeq 180 bp

    [SRX734432](https://www.ncbi.nlm.nih.gov/sra/SRX2527206[accn]) SRR1614244

```bash
cd ${HOME}/data/anchr/nip

mkdir -p 2_illumina
cd 2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR161/004/SRR1614244/SRR1614244_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR161/004/SRR1614244/SRR1614244_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
8ca85062cf7ef7fb21af1c22d16a5309 SRR1614244_1.fastq.gz
931f7c2d1e4d6518a19a9da71c57d966 SRR1614244_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s SRR1614244_1.fastq.gz R1.fq.gz
ln -s SRR1614244_2.fastq.gz R2.fq.gz

```

* PacBio

    [SRX1897300](https://www.ncbi.nlm.nih.gov/sra/SRX1897300) SRR3743363

```bash
mkdir -p ~/data/anchr/nip/3_pacbio
cd ~/data/anchr/nip/3_pacbio

cat <<EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR374/003/SRR3743363/SRR3743363_subreads.fastq.gz
EOF

aria2c -x 6 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
a77a415cc45f4077d88f81976a59e078 SRR3743363_subreads.fastq.gz
EOF

md5sum --check sra_md5.txt

faops filter -l 0 SRR3743363_subreads.fastq.gz pacbio.fasta

```
