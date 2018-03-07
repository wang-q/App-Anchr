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
        - [s288c-Miseq](#s288c-miseq)
        - [s288c-Hiseq](#s288c-hiseq)
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

rm *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 4641652 \
    --insertsize \
    --sgapreqc \
    --sgastats \
    --trim2 "--dedupe --tile" \
    --sample2 300 \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,2,3" \
    --cov2 "40 60 80" \
    --tadpole \
    --statp 5 \
    --redoanchors \
    --cov3 "40 80 all" \
    --qual3 "raw trim" \
    --parallel 24

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

bash 2_insertSize.sh
bash 2_sgaPreQC.sh

# trim Illumina reads
bash 2_trim.sh

# trim PacBio reads
bash 3_trimlong.sh

# reads stats
bash 9_statReads.sh

# mergereads
bash 2_mergereads.sh

# quorum
bash 2_quorum.sh

```

Table: statInsertSize

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| genome.bbtools  | 321.9 |    298 | 968.5 |                         47.99% |
| tadpole.bbtools | 295.6 |    296 |  21.1 |                         40.57% |
| genome.picard   | 298.2 |    298 |  18.0 |                             FR |
| tadpole.picard  | 294.9 |    296 |  21.7 |                             FR |


Table: statSgaStats

| Item           |  Value |
|:---------------|-------:|
| incorrectBases |  0.26% |
| perfectReads   | 79.72% |
| overlapDepth   | 356.41 |


Table: statReads

| Name      |     N50 |     Sum |        # |
|:----------|--------:|--------:|---------:|
| Genome    | 4641652 | 4641652 |        1 |
| Paralogs  |    1934 |  195673 |      106 |
| Illumina  |     151 |   1.73G | 11458940 |
| trim      |     149 |   1.19G |  8653996 |
| Q20L60    |     149 |   1.17G |  8534257 |
| Q25L60    |     148 |    1.1G |  8293641 |
| Q30L60    |     128 | 922.22M |  7768040 |
| PacBio    |   13982 | 748.51M |    87225 |
| X40.raw   |   14030 | 185.68M |    22336 |
| X40.trim  |   13702 | 169.38M |    19468 |
| X80.raw   |   13990 | 371.34M |    44005 |
| X80.trim  |   13632 | 339.51M |    38725 |
| Xall.raw  |   13982 | 748.51M |    87225 |
| Xall.trim |   13646 | 689.43M |    77693 |


Table: statTrimReads

| Name           | N50 |     Sum |        # |
|:---------------|----:|--------:|---------:|
| clumpify       | 151 |   1.73G | 11439000 |
| filteredbytile | 151 |   1.67G | 11062784 |
| sample         | 151 |   1.39G |  9221824 |
| trim           | 149 |   1.19G |  8654404 |
| filter         | 149 |   1.19G |  8653996 |
| R1             | 150 | 614.35M |  4326998 |
| R2             | 144 | 576.27M |  4326998 |
| Rs             |   0 |       0 |        0 |


```text
#trim
#Matched        15655   0.16976%
#Name   Reads   ReadsPct
pcr_dimer       7016    0.07608%
PCR_Primers     1227    0.01331%
```

```text
#filter
#Matched        408     0.00471%
#Name   Reads   ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome  406     0.00469%
```


Table: statMergeReads

| Name          | N50 |    Sum |       # |
|:--------------|----:|-------:|--------:|
| clumped       | 149 |  1.19G | 8653168 |
| ecco          | 149 |  1.19G | 8653168 |
| eccc          | 149 |  1.19G | 8653168 |
| ecct          | 149 |  1.18G | 8607506 |
| extended      | 189 |  1.53G | 8607506 |
| merged        | 339 |  1.43G | 4246258 |
| unmerged.raw  | 174 | 16.73M |  114990 |
| unmerged.trim | 174 | 16.72M |  114926 |
| U1            | 181 |   8.8M |   57463 |
| U2            | 167 |  7.92M |   57463 |
| Us            |   0 |      0 |       0 |
| pe.cor        | 338 |  1.45G | 8607442 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 271.6 |    277 |  23.9 |         10.85% |
| ihist.merge.txt  | 337.7 |    338 |  19.3 |         98.66% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q0L0   | 256.5 |  238.1 |    7.17% |     138 | "93" | 4.64M | 4.63M |     1.00 | 0:03'03'' |
| Q20L60 | 252.8 |  236.5 |    6.44% |     138 | "67" | 4.64M | 4.61M |     0.99 | 0:02'59'' |
| Q25L60 | 237.0 |  227.7 |    3.91% |     135 | "87" | 4.64M | 4.57M |     0.98 | 0:02'49'' |
| Q30L60 | 198.8 |  194.7 |    2.07% |     123 | "73" | 4.64M | 4.56M |     0.98 | 0:02'31'' |


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
| Q0L0X40P000   |   40.0 |  96.51% |     10065 | 4.47M |  646 |        76 |  97.12K | 1611 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'49'' |
| Q0L0X40P001   |   40.0 |  96.13% |     10812 | 4.46M |  652 |        61 |  76.27K | 1562 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'49'' |
| Q0L0X40P002   |   40.0 |  96.18% |     10235 | 4.44M |  665 |        84 | 101.63K | 1640 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'48'' |
| Q0L0X40P003   |   40.0 |  96.38% |      9620 | 4.48M |  679 |        52 |   71.2K | 1685 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'48'' |
| Q0L0X40P004   |   40.0 |  96.40% |     10670 | 4.46M |  622 |        71 |  92.25K | 1591 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'48'' |
| Q0L0X60P000   |   60.0 |  94.49% |      6865 |  4.4M |  895 |        59 |   94.2K | 1920 |   59.0 | 4.0 |  15.7 | 106.5 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'46'' |
| Q0L0X60P001   |   60.0 |  94.52% |      6880 |  4.4M |  895 |        57 |  93.77K | 1956 |   59.0 | 4.0 |  15.7 | 106.5 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'50'' |
| Q0L0X60P002   |   60.0 |  94.70% |      6717 | 4.41M |  898 |        57 |  95.42K | 1992 |   59.0 | 4.0 |  15.7 | 106.5 | "31,41,51,61,71,81" | 0:01'02'' | 0:00'50'' |
| Q0L0X80P000   |   80.0 |  92.90% |      5466 | 4.34M | 1079 |        52 | 100.02K | 2236 |   79.0 | 6.0 |  20.0 | 145.5 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'52'' |
| Q0L0X80P001   |   80.0 |  92.80% |      5244 | 4.32M | 1086 |        63 | 117.94K | 2284 |   79.0 | 6.0 |  20.0 | 145.5 | "31,41,51,61,71,81" | 0:01'47'' | 0:00'52'' |
| Q20L60X40P000 |   40.0 |  96.77% |     11416 | 4.47M |  619 |        66 |  87.79K | 1587 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'09'' | 0:00'50'' |
| Q20L60X40P001 |   40.0 |  96.66% |     11671 | 4.45M |  588 |        99 | 102.74K | 1545 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'51'' |
| Q20L60X40P002 |   40.0 |  96.69% |     11017 | 4.48M |  599 |        65 |   81.2K | 1528 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'09'' | 0:00'49'' |
| Q20L60X40P003 |   40.0 |  96.60% |     11711 | 4.46M |  613 |        76 |  94.41K | 1544 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'11'' | 0:00'51'' |
| Q20L60X40P004 |   40.0 |  96.52% |     11386 | 4.46M |  601 |        74 |  90.46K | 1522 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'11'' | 0:00'48'' |
| Q20L60X60P000 |   60.0 |  95.32% |      7594 | 4.42M |  837 |        58 |   91.1K | 1883 |   59.0 | 4.0 |  15.7 | 106.5 | "31,41,51,61,71,81" | 0:01'29'' | 0:00'47'' |
| Q20L60X60P001 |   60.0 |  95.42% |      7829 | 4.44M |  808 |        58 |  83.85K | 1817 |   59.0 | 4.0 |  15.7 | 106.5 | "31,41,51,61,71,81" | 0:01'25'' | 0:00'49'' |
| Q20L60X60P002 |   60.0 |  95.31% |      7460 | 4.44M |  852 |        55 |  85.89K | 1895 |   59.0 | 4.0 |  15.7 | 106.5 | "31,41,51,61,71,81" | 0:01'27'' | 0:00'50'' |
| Q20L60X80P000 |   80.0 |  93.90% |      5880 | 4.37M |  981 |        54 |  95.77K | 2110 |   79.0 | 6.0 |  20.0 | 145.5 | "31,41,51,61,71,81" | 0:01'45'' | 0:00'54'' |
| Q20L60X80P001 |   80.0 |  93.77% |      6106 | 4.37M | 1016 |        53 |  93.72K | 2146 |   79.0 | 6.0 |  20.0 | 145.5 | "31,41,51,61,71,81" | 0:01'41'' | 0:00'56'' |
| Q25L60X40P000 |   40.0 |  97.84% |     18760 |  4.5M |  377 |        66 |  67.23K | 1262 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'56'' |
| Q25L60X40P001 |   40.0 |  97.81% |     18753 |  4.5M |  391 |        81 |   83.9K | 1358 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'15'' | 0:00'57'' |
| Q25L60X40P002 |   40.0 |  97.86% |     19052 |  4.5M |  392 |        70 |  78.86K | 1381 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'56'' |
| Q25L60X40P003 |   40.0 |  97.95% |     18303 |  4.5M |  394 |        73 |  76.87K | 1321 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'53'' |
| Q25L60X40P004 |   40.0 |  97.86% |     18296 | 4.49M |  393 |        77 |  80.32K | 1319 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'09'' | 0:00'55'' |
| Q25L60X60P000 |   60.0 |  97.36% |     14321 | 4.49M |  491 |        61 |  65.95K | 1354 |   59.0 | 4.0 |  15.7 | 106.5 | "31,41,51,61,71,81" | 0:01'27'' | 0:00'53'' |
| Q25L60X60P001 |   60.0 |  97.20% |     13945 | 4.49M |  500 |        60 |  63.56K | 1376 |   59.0 | 4.0 |  15.7 | 106.5 | "31,41,51,61,71,81" | 0:01'28'' | 0:00'52'' |
| Q25L60X60P002 |   60.0 |  97.36% |     13830 | 4.49M |  491 |        58 |  61.72K | 1347 |   59.0 | 4.0 |  15.7 | 106.5 | "31,41,51,61,71,81" | 0:01'31'' | 0:00'51'' |
| Q25L60X80P000 |   80.0 |  96.78% |     11874 | 4.48M |  574 |        55 |  60.05K | 1434 |   79.0 | 5.0 |  20.0 | 141.0 | "31,41,51,61,71,81" | 0:01'45'' | 0:00'54'' |
| Q25L60X80P001 |   80.0 |  96.76% |     11073 | 4.48M |  602 |        55 |  63.42K | 1496 |   79.0 | 5.0 |  20.0 | 141.0 | "31,41,51,61,71,81" | 0:01'53'' | 0:00'53'' |
| Q30L60X40P000 |   40.0 |  98.59% |     34311 | 4.53M |  217 |        54 |  62.67K | 1320 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'05'' |
| Q30L60X40P001 |   40.0 |  98.55% |     32722 | 4.51M |  225 |        64 |  70.16K | 1300 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:01'11'' | 0:01'03'' |
| Q30L60X40P002 |   40.0 |  98.56% |     33955 | 4.51M |  218 |        64 |  72.16K | 1333 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:01'13'' | 0:01'05'' |
| Q30L60X40P003 |   40.0 |  98.51% |     33141 | 4.51M |  226 |        56 |  64.59K | 1267 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:01'07'' | 0:01'04'' |
| Q30L60X60P000 |   60.0 |  98.56% |     34029 | 4.52M |  209 |        54 |   56.2K | 1173 |   60.0 | 4.0 |  16.0 | 108.0 | "31,41,51,61,71,81" | 0:01'34'' | 0:01'07'' |
| Q30L60X60P001 |   60.0 |  98.59% |     34372 | 4.51M |  215 |       504 |  92.91K | 1191 |   59.0 | 3.0 |  16.7 | 102.0 | "31,41,51,61,71,81" | 0:01'26'' | 0:01'08'' |
| Q30L60X60P002 |   60.0 |  98.53% |     33124 | 4.51M |  227 |        57 |  58.76K | 1157 |   60.0 | 4.0 |  16.0 | 108.0 | "31,41,51,61,71,81" | 0:01'31'' | 0:01'05'' |
| Q30L60X80P000 |   80.0 |  98.55% |     33119 | 4.51M |  218 |        89 |  62.72K | 1120 |   79.0 | 4.0 |  20.0 | 136.5 | "31,41,51,61,71,81" | 0:01'29'' | 0:01'11'' |
| Q30L60X80P001 |   80.0 |  98.49% |     34022 | 4.51M |  216 |        65 |  55.73K | 1066 |   79.0 | 4.5 |  20.0 | 138.8 | "31,41,51,61,71,81" | 0:01'12'' | 0:01'06'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|----:|----------:|-------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  98.33% |     31200 | 4.51M | 241 |        60 |  64.5K | 1174 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'56'' | 0:01'03'' |
| Q0L0X40P001   |   40.0 |  98.09% |     30502 | 4.51M | 264 |        59 | 64.65K | 1205 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'59'' |
| Q0L0X40P002   |   40.0 |  98.17% |     31565 | 4.51M | 243 |       105 | 99.04K | 1180 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'57'' |
| Q0L0X40P003   |   40.0 |  98.31% |     33064 | 4.51M | 234 |        62 | 66.96K | 1153 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'58'' |
| Q0L0X40P004   |   40.0 |  98.26% |     35510 | 4.52M | 242 |        61 | 69.43K | 1213 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'55'' | 0:01'03'' |
| Q0L0X60P000   |   60.0 |  97.80% |     23231 | 4.51M | 302 |        60 | 59.54K | 1064 |   59.0 | 3.0 |  16.7 | 102.0 | "31,41,51,61,71,81" | 0:01'05'' | 0:00'59'' |
| Q0L0X60P001   |   60.0 |  97.55% |     25470 |  4.5M | 304 |        58 | 57.92K | 1072 |   59.0 | 3.0 |  16.7 | 102.0 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'59'' |
| Q0L0X60P002   |   60.0 |  97.81% |     24116 | 4.51M | 297 |        58 |  58.4K | 1079 |   59.0 | 3.0 |  16.7 | 102.0 | "31,41,51,61,71,81" | 0:01'05'' | 0:01'00'' |
| Q0L0X80P000   |   80.0 |  97.03% |     16177 | 4.51M | 433 |        50 | 51.89K | 1158 |   79.0 | 4.0 |  20.0 | 136.5 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'53'' |
| Q0L0X80P001   |   80.0 |  97.11% |     17157 |  4.5M | 417 |        49 | 53.88K | 1167 |   79.0 | 4.0 |  20.0 | 136.5 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'58'' |
| Q20L60X40P000 |   40.0 |  98.31% |     31675 | 4.52M | 243 |        59 | 63.09K | 1207 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:01'06'' |
| Q20L60X40P001 |   40.0 |  98.25% |     31781 | 4.51M | 249 |        62 | 68.41K | 1208 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:01'09'' |
| Q20L60X40P002 |   40.0 |  98.27% |     31765 | 4.52M | 246 |        57 |  61.1K | 1183 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'59'' |
| Q20L60X40P003 |   40.0 |  98.31% |     32837 | 4.51M | 238 |        68 | 72.26K | 1143 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'58'' | 0:01'01'' |
| Q20L60X40P004 |   40.0 |  98.34% |     34237 | 4.51M | 232 |        60 | 65.97K | 1179 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:01'02'' | 0:01'03'' |
| Q20L60X60P000 |   60.0 |  97.77% |     25666 | 4.51M | 303 |        57 | 55.96K | 1090 |   59.0 | 3.0 |  16.7 | 102.0 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'57'' |
| Q20L60X60P001 |   60.0 |  97.89% |     26534 | 4.51M | 306 |        60 | 57.42K | 1068 |   59.0 | 3.0 |  16.7 | 102.0 | "31,41,51,61,71,81" | 0:01'03'' | 0:01'03'' |
| Q20L60X60P002 |   60.0 |  97.84% |     27235 | 4.51M | 291 |        68 | 65.04K | 1009 |   59.0 | 3.0 |  16.7 | 102.0 | "31,41,51,61,71,81" | 0:00'59'' | 0:01'01'' |
| Q20L60X80P000 |   80.0 |  97.25% |     19865 | 4.49M | 400 |        57 | 59.93K | 1147 |   79.0 | 4.0 |  20.0 | 136.5 | "31,41,51,61,71,81" | 0:01'12'' | 0:01'04'' |
| Q20L60X80P001 |   80.0 |  97.40% |     17764 | 4.51M | 401 |        52 | 55.04K | 1133 |   79.0 | 5.0 |  20.0 | 141.0 | "31,41,51,61,71,81" | 0:01'12'' | 0:01'05'' |
| Q25L60X40P000 |   40.0 |  98.51% |     33983 | 4.51M | 224 |        65 | 74.05K | 1257 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:01'04'' |
| Q25L60X40P001 |   40.0 |  98.51% |     34328 | 4.51M | 225 |        65 |  77.1K | 1293 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'59'' | 0:01'04'' |
| Q25L60X40P002 |   40.0 |  98.57% |     36257 | 4.51M | 214 |        56 | 64.39K | 1269 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:01'04'' |
| Q25L60X40P003 |   40.0 |  98.57% |     35554 | 4.52M | 225 |        57 | 67.92K | 1279 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:01'04'' |
| Q25L60X40P004 |   40.0 |  98.45% |     32176 | 4.51M | 238 |        60 | 70.64K | 1267 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'57'' | 0:01'05'' |
| Q25L60X60P000 |   60.0 |  98.34% |     31032 | 4.51M | 249 |        60 | 62.27K | 1124 |   60.0 | 3.0 |  17.0 | 103.5 | "31,41,51,61,71,81" | 0:01'04'' | 0:01'02'' |
| Q25L60X60P001 |   60.0 |  98.32% |     29651 | 4.51M | 247 |        60 | 60.32K | 1110 |   59.0 | 3.0 |  16.7 | 102.0 | "31,41,51,61,71,81" | 0:01'07'' | 0:01'02'' |
| Q25L60X60P002 |   60.0 |  98.33% |     31582 | 4.51M | 253 |        60 |    62K | 1148 |   59.0 | 3.0 |  16.7 | 102.0 | "31,41,51,61,71,81" | 0:01'07'' | 0:01'03'' |
| Q25L60X80P000 |   80.0 |  98.11% |     23505 | 4.51M | 301 |        55 | 56.67K | 1137 |   79.0 | 4.0 |  20.0 | 136.5 | "31,41,51,61,71,81" | 0:01'12'' | 0:01'03'' |
| Q25L60X80P001 |   80.0 |  98.15% |     26560 | 4.52M | 297 |        50 | 49.78K | 1136 |   79.0 | 4.0 |  20.0 | 136.5 | "31,41,51,61,71,81" | 0:01'06'' | 0:01'03'' |
| Q30L60X40P000 |   40.0 |  98.60% |     29365 | 4.53M | 252 |        56 | 80.47K | 1578 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'51'' | 0:01'07'' |
| Q30L60X40P001 |   40.0 |  98.48% |     31216 | 4.51M | 251 |        75 | 83.36K | 1466 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'48'' | 0:01'04'' |
| Q30L60X40P002 |   40.0 |  98.57% |     31204 | 4.52M | 253 |        89 | 93.93K | 1546 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:01'03'' |
| Q30L60X40P003 |   40.0 |  98.54% |     28499 | 4.51M | 262 |        66 | 85.65K | 1503 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'53'' | 0:01'05'' |
| Q30L60X60P000 |   60.0 |  98.65% |     35614 | 4.52M | 217 |        51 | 65.67K | 1355 |   60.0 | 4.0 |  16.0 | 108.0 | "31,41,51,61,71,81" | 0:01'00'' | 0:01'15'' |
| Q30L60X60P001 |   60.0 |  98.59% |     35054 | 4.52M | 210 |        52 | 64.24K | 1317 |   60.0 | 4.0 |  16.0 | 108.0 | "31,41,51,61,71,81" | 0:00'59'' | 0:01'12'' |
| Q30L60X60P002 |   60.0 |  98.58% |     34311 | 4.51M | 215 |        54 | 64.79K | 1261 |   60.0 | 4.0 |  16.0 | 108.0 | "31,41,51,61,71,81" | 0:01'01'' | 0:01'05'' |
| Q30L60X80P000 |   80.0 |  98.64% |     40017 | 4.52M | 199 |        53 | 59.89K | 1226 |   80.0 | 5.0 |  20.0 | 142.5 | "31,41,51,61,71,81" | 0:01'11'' | 0:01'11'' |
| Q30L60X80P001 |   80.0 |  98.57% |     39113 | 4.51M | 204 |        50 | 54.27K | 1187 |   80.0 | 5.0 |  20.0 | 142.5 | "31,41,51,61,71,81" | 0:01'09'' | 0:01'04'' |


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

```

Table: statMRKunitigsAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  96.78% |     38028 | 4.49M | 195 |       132 | 55.05K | 447 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'37'' | 0:00'45'' |
| MRX40P001 |   40.0 |  96.90% |     43690 | 4.49M | 180 |       137 | 56.74K | 420 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'42'' | 0:00'45'' |
| MRX40P002 |   40.0 |  97.00% |     41099 | 4.49M | 186 |       129 | 53.28K | 447 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'44'' | 0:00'48'' |
| MRX40P003 |   40.0 |  96.94% |     40969 | 4.49M | 184 |       134 | 55.62K | 441 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'48'' | 0:00'47'' |
| MRX40P004 |   40.0 |  96.79% |     43229 | 4.49M | 195 |       135 | 58.34K | 446 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'40'' | 0:00'47'' |
| MRX40P005 |   40.0 |  96.93% |     38959 | 4.49M | 194 |       137 | 56.92K | 454 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'52'' | 0:00'47'' |
| MRX60P000 |   60.0 |  96.48% |     31704 | 4.49M | 235 |       126 | 62.17K | 528 |   59.0 | 2.0 |  17.7 |  97.5 | "31,41,51,61,71,81" | 0:02'07'' | 0:00'47'' |
| MRX60P001 |   60.0 |  96.62% |     33841 | 4.49M | 221 |       126 | 58.91K | 505 |   59.0 | 2.0 |  17.7 |  97.5 | "31,41,51,61,71,81" | 0:02'18'' | 0:00'47'' |
| MRX60P002 |   60.0 |  96.48% |     32180 | 4.49M | 233 |       126 | 59.97K | 528 |   59.0 | 2.5 |  17.2 |  99.8 | "31,41,51,61,71,81" | 0:01'35'' | 0:00'45'' |
| MRX60P003 |   60.0 |  96.68% |     33759 | 4.49M | 219 |       125 | 60.84K | 511 |   59.0 | 2.0 |  17.7 |  97.5 | "31,41,51,61,71,81" | 0:01'34'' | 0:00'48'' |
| MRX60P004 |   60.0 |  96.51% |     33921 | 4.48M | 207 |       131 | 59.91K | 466 |   59.0 | 2.0 |  17.7 |  97.5 | "31,41,51,61,71,81" | 0:01'36'' | 0:00'46'' |
| MRX80P000 |   80.0 |  96.24% |     28774 | 4.49M | 269 |       109 |  57.3K | 593 |   79.0 | 3.0 |  20.0 | 132.0 | "31,41,51,61,71,81" | 0:01'57'' | 0:00'46'' |
| MRX80P001 |   80.0 |  96.36% |     28958 | 4.49M | 252 |       113 | 58.17K | 572 |   79.0 | 3.0 |  20.0 | 132.0 | "31,41,51,61,71,81" | 0:01'47'' | 0:00'49'' |
| MRX80P002 |   80.0 |  96.23% |     28689 | 4.49M | 268 |       106 | 56.14K | 589 |   79.0 | 3.0 |  20.0 | 132.0 | "31,41,51,61,71,81" | 0:01'39'' | 0:00'47'' |


Table: statMRTadpoleAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  96.73% |     65270 |  4.5M | 124 |       124 | 32.28K | 263 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'56'' |
| MRX40P001 |   40.0 |  96.77% |     64172 |  4.5M | 117 |       146 | 37.87K | 259 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'56'' |
| MRX40P002 |   40.0 |  96.67% |     60641 |  4.5M | 131 |       128 |  33.9K | 278 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'52'' |
| MRX40P003 |   40.0 |  96.77% |     65208 |  4.5M | 123 |       127 | 33.22K | 268 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'53'' |
| MRX40P004 |   40.0 |  96.72% |     63033 |  4.5M | 127 |       134 | 36.22K | 262 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'59'' | 0:00'56'' |
| MRX40P005 |   40.0 |  96.71% |     59466 |  4.5M | 131 |       131 | 34.46K | 273 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'55'' |
| MRX60P000 |   60.0 |  96.58% |     57647 |  4.5M | 137 |       122 | 35.56K | 287 |   59.0 | 2.0 |  17.7 |  97.5 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'58'' |
| MRX60P001 |   60.0 |  96.59% |     57634 |  4.5M | 144 |       121 | 35.31K | 301 |   59.0 | 2.0 |  17.7 |  97.5 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'53'' |
| MRX60P002 |   60.0 |  96.68% |     60738 |  4.5M | 138 |       117 | 33.58K | 293 |   59.0 | 2.0 |  17.7 |  97.5 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'52'' |
| MRX60P003 |   60.0 |  96.69% |     62991 |  4.5M | 132 |       122 | 35.12K | 284 |   59.0 | 2.0 |  17.7 |  97.5 | "31,41,51,61,71,81" | 0:01'11'' | 0:01'02'' |
| MRX60P004 |   60.0 |  96.58% |     59454 |  4.5M | 136 |       130 | 39.04K | 287 |   59.0 | 2.0 |  17.7 |  97.5 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'59'' |
| MRX80P000 |   80.0 |  96.50% |     51256 |  4.5M | 156 |       106 | 34.77K | 324 |   79.0 | 2.0 |  20.0 | 127.5 | "31,41,51,61,71,81" | 0:01'23'' | 0:01'01'' |
| MRX80P001 |   80.0 |  96.50% |     52774 |  4.5M | 162 |       107 | 34.66K | 338 |   79.0 | 2.0 |  20.0 | 127.5 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'59'' |
| MRX80P002 |   80.0 |  96.57% |     55607 | 4.51M | 151 |        96 | 29.07K | 311 |   79.0 | 3.0 |  20.0 | 132.0 | "31,41,51,61,71,81" | 0:01'21'' | 0:00'57'' |


* merge anchors

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bash 7_mergeAnchors.sh 4_kunitigs 7_mergeKunitigsAnchors
bash 7_mergeAnchors.sh 4_tadpole 7_mergeTadpoleAnchors

bash 7_mergeAnchors.sh 6_kunitigs 7_mergeMRKunitigsAnchors
bash 7_mergeAnchors.sh 6_tadpole 7_mergeMRTadpoleAnchors

#bash 7_mergeAnchors.sh 6_megahit 7_mergeMRMegahitAnchors
#bash 7_mergeAnchors.sh 6_spades 7_mergeMRSpadesAnchors

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

Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |  91.86% |     78538 | 4.52M | 107 |      3938 |  277.2K | 110 |  124.0 | 4.0 |  20.0 | 204.0 | 0:01'15'' |
| 7_mergeKunitigsAnchors   |  96.01% |     63178 | 4.52M | 127 |      2525 | 162.16K |  80 |  123.0 | 6.0 |  20.0 | 211.5 | 0:02'12'' |
| 7_mergeMRKunitigsAnchors |  96.01% |     67174 | 4.51M | 114 |      1345 |  30.08K |  23 |  124.0 | 4.0 |  20.0 | 204.0 | 0:02'09'' |
| 7_mergeMRTadpoleAnchors  |  96.11% |     78501 | 4.51M | 108 |     41100 |  70.14K |  23 |  124.0 | 3.5 |  20.0 | 201.8 | 0:02'13'' |
| 7_mergeTadpoleAnchors    |  96.41% |     65356 | 4.52M | 118 |      3938 | 195.76K |  85 |  123.0 | 5.0 |  20.0 | 207.0 | 0:02'07'' |


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

bash 7_anchorLong.sh \
    7_mergeAnchors/anchor.merge.fasta \
    5_canu_Xall-trim/${BASE_NAME}.correctedReads.fasta.gz \
    2

# false strand
cat 7_anchorLong/group/*.ovlp.tsv \
    | perl -nla -e '/anchor.+long/ or next; print $F[0] if $F[8] == 1;' \
    | sort | uniq -c

bash 7_anchorFill.sh \
    7_anchorLong/contig.fasta \
    5_canu_Xall-trim/${BASE_NAME}.contigs.fasta \
    1

```

* spades and platanus

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bash 8_spades.sh
bash 8_spades_MR.sh
bash 8_megahit.sh
bash 8_megahit_MR.sh
bash 8_platanus.sh

```

Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|----------:|
| 8_spades     |  92.52% |    117596 | 4.54M |  72 |      1275 | 40.68K | 164 |  124.5 | 4.5 |  20.0 | 207.0 | 0:01'49'' |
| 8_spades_MR  |  92.71% |    175990 | 4.55M |  63 |      1283 | 17.33K | 132 |  125.0 | 5.0 |  20.0 | 210.0 | 0:01'39'' |
| 8_megahit    |  92.17% |     67334 | 4.52M | 110 |      1141 |  25.4K | 231 |  124.0 | 4.0 |  20.0 | 204.0 | 0:01'37'' |
| 8_megahit_MR |  92.62% |    110523 | 4.56M |  83 |      1198 | 21.67K | 167 |  126.0 | 4.0 |  20.0 | 207.0 | 0:01'21'' |
| 8_platanus   |  94.23% |    132960 | 4.54M |  67 |      1145 | 14.16K | 130 |  114.0 | 3.0 |  20.0 | 184.5 | 0:02'26'' |

* final stats

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bash 9_statFinal.sh
bash 9_quast.sh

# bash 0_cleanup.sh

```

Table: statFinal

| Name                     |     N50 |     Sum |    # |
|:-------------------------|--------:|--------:|-----:|
| Genome                   | 4641652 | 4641652 |    1 |
| Paralogs                 |    1934 |  195673 |  106 |
| 7_mergeAnchors.anchors   |   78538 | 4515962 |  107 |
| 7_mergeAnchors.others    |    3938 |  277196 |  110 |
| anchorLong               |   78538 | 4515962 |  107 |
| anchorFill               |  651877 | 4575011 |   16 |
| canu_X40-raw             | 4674150 | 4674150 |    1 |
| canu_X40-trim            | 4674046 | 4674046 |    1 |
| canu_X80-raw             | 4658166 | 4658166 |    1 |
| canu_X80-trim            | 4657933 | 4657933 |    1 |
| canu_Xall-raw            | 4670118 | 4670118 |    1 |
| canu_Xall-trim           | 4670240 | 4670240 |    1 |
| spades.contig            |  117644 | 4648957 |  290 |
| spades.scaffold          |  125619 | 4649007 |  285 |
| spades.non-contained     |  117644 | 4578356 |   93 |
| spades_MR.contig         |  148609 | 4581434 |   97 |
| spades_MR.scaffold       |  148609 | 4581534 |   96 |
| spades_MR.non-contained  |  176015 | 4570016 |   69 |
| megahit.contig           |   67382 | 4572920 |  199 |
| megahit.non-contained    |   67382 | 4548380 |  121 |
| megahit_MR.contig        |  110552 | 4628012 |  219 |
| megahit_MR.non-contained |  110552 | 4577308 |   85 |
| platanus.contig          |   16464 | 4674383 | 1017 |
| platanus.scaffold        |  133012 | 4574920 |  142 |
| platanus.non-contained   |  133012 | 4556916 |   63 |


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

* Illumina

    * MiSeq (PE150) [ERX1999216](https://www.ncbi.nlm.nih.gov/sra/ERX1999216) ERR1938683 PRJEB19900
    * HiSeq 2500 (PE150, nextera) [SRX2058864](https://www.ncbi.nlm.nih.gov/sra/SRX2058864)
      SRR4074255 PRJNA340312

```bash
cd ${HOME}/data/anchr/s288c

mkdir -p 2_illumina
cd 2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR193/003/ERR1938683/ERR1938683_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR193/003/ERR1938683/ERR1938683_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR407/005/SRR4074255/SRR4074255_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR407/005/SRR4074255/SRR4074255_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
9a635e035371a81c8538698a54a24bfc ERR1938683_1.fastq.gz
48f362c1d7a95b996bc7931669b1d74b ERR1938683_2.fastq.gz
7ba93499d73cdaeaf50dd506e2c8572d SRR4074255_1.fastq.gz
aee9ec3f855796b6d30a3d191fc22345 SRR4074255_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -fs ERR1938683_1.fastq.gz R1.fq.gz
ln -fs ERR1938683_2.fastq.gz R2.fq.gz

#ln -fs SRR4074255_1.fastq.gz S1.fq.gz
#ln -fs SRR4074255_2.fastq.gz S2.fq.gz

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

# rsync -avP wangq@202.119.37.251:data/anchr/s288c/ ~/data/anchr/s288c

```

* template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=s288c

cd ${WORKING_DIR}/${BASE_NAME}

rm *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 12157105 \
    --is_euk \
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
    --ecphase "1,2,3" \
    --cov2 "40 60 80 all" \
    --tadpole \
    --statp 5 \
    --redoanchors \
    --cov3 "all" \
    --qual3 "trim" \
    --parallel 24 \
    --xmx 110g

```

## s288c: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=s288c

cd ${WORKING_DIR}/${BASE_NAME}
#rm -fr 4_*/ 6_*/ 7_*/ 8_*/ 2_illumina/trim 2_illumina/mergereads statReads.md 

bash 0_bsub.sh
#bkill -J "${BASE_NAME}-*"

#bash 0_master.sh
#bash 0_cleanup.sh

```

### s288c-Miseq

| Group             |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:------------------|------:|-------:|------:|-------------------------------:|
| R.genome.bbtools  | 407.5 |    367 | 464.6 |                         48.81% |
| R.tadpole.bbtools | 394.9 |    361 | 139.3 |                         42.86% |
| R.genome.picard   | 402.1 |    367 | 142.1 |                             FR |
| R.tadpole.picard  | 394.4 |    360 | 139.4 |                             FR |


Table: statSgaStats

| Library | incorrectBases | perfectReads | overlapDepth |
|:--------|---------------:|-------------:|-------------:|
| R       |          0.14% |       89.85% |       111.58 |
| S       |          0.23% |       88.56% |      2188.74 |


Table: statReads

| Name       |    N50 |      Sum |       # |
|:-----------|-------:|---------:|--------:|
| Genome     | 924431 | 12157105 |      17 |
| Paralogs   |   3851 |  1059148 |     366 |
| Illumina.R |    150 |  995.54M | 6636934 |
| trim.R     |    150 |   990.9M | 6615308 |
| Q20L60     |    150 |  979.32M | 6566749 |
| Q25L60     |    150 |  947.87M | 6402446 |
| Q30L60     |    150 |  892.85M | 6090219 |
| PacBio     |   8412 |  820.96M |  177100 |
| Xall.raw   |   8412 |  820.96M |  177100 |
| Xall.trim  |   7829 |  626.41M |  106381 |


Table: statTrimReads

| Name     | N50 |     Sum |       # |
|:---------|----:|--------:|--------:|
| clumpify | 150 | 992.93M | 6619558 |
| trim     | 150 |  990.9M | 6615308 |
| filter   | 150 |  990.9M | 6615308 |
| R1       | 150 | 495.67M | 3307654 |
| R2       | 150 | 495.23M | 3307654 |
| Rs       |   0 |       0 |       0 |


```text
#R.trim
#Matched	6050	0.09140%
#Name	Reads	ReadsPct
```

```text
#R.filter
#Matched	0	0.00000%
#Name	Reads	ReadsPct
```

```text
#R.peaks
#k	31
#unique_kmers	38213108
#main_peak	53
#genome_size	14057090
#haploid_genome_size	14057090
#fold_coverage	53
#haploid_fold_coverage	53
#ploidy	1
#percent_repeat	19.456
#start	center	stop	max	volume
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 150 | 990.89M | 6615240 |
| ecco          | 150 | 990.89M | 6615240 |
| eccc          | 150 | 990.89M | 6615240 |
| ecct          | 150 | 947.56M | 6322176 |
| extended      | 190 |    1.2G | 6322176 |
| merged.raw    | 387 | 902.23M | 2398194 |
| unmerged.raw  | 190 | 287.36M | 1525788 |
| unmerged.trim | 190 | 287.36M | 1525784 |
| M1            | 387 | 900.06M | 2392185 |
| U1            | 190 |  144.1M |  762892 |
| U2            | 190 | 143.26M |  762892 |
| Us            |   0 |       0 |       0 |
| M.cor         | 354 |   1.19G | 6310154 |

| Group              |  Mean | Median | STDev | PercentOfPairs |
|:-------------------|------:|-------:|------:|---------------:|
| M.ihist.merge1.txt | 249.2 |    255 |  27.7 |         19.23% |
| M.ihist.merge.txt  | 376.2 |    371 |  72.7 |         75.87% |


Table: statQuorum

| Name     | CovIn | CovOut | Discard% |  Kmer |  RealG |   EstG | Est/Real |   RunTime |
|:---------|------:|-------:|---------:|------:|-------:|-------:|---------:|----------:|
| Q0L0.R   |  81.5 |   73.5 |    9.82% | "105" | 12.16M | 11.92M |     0.98 | 0:01'39'' |
| Q20L60.R |  80.6 |   73.6 |    8.64% | "105" | 12.16M | 11.86M |     0.98 | 0:01'38'' |
| Q25L60.R |  78.0 |   73.2 |    6.10% | "105" | 12.16M | 11.66M |     0.96 | 0:01'37'' |
| Q30L60.R |  73.5 |   70.7 |    3.76% | "105" | 12.16M |  11.6M |     0.95 | 0:01'34'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  79.73% |     10739 | 11.09M | 1547 |      1076 | 221.09K | 2919 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:02'12'' | 0:01'23'' |
| Q0L0X60P000    |   60.0 |  78.65% |      8530 | 11.01M | 1876 |      1057 | 240.21K | 3558 |   50.0 | 2.0 |  14.7 |  84.0 | "31,41,51,61,71,81" | 0:02'57'' | 0:01'23'' |
| Q0L0XallP000   |   73.5 |  78.27% |      7714 | 10.96M | 2002 |      1059 | 246.71K | 3791 |   62.0 | 3.0 |  17.7 | 106.5 | "31,41,51,61,71,81" | 0:03'26'' | 0:01'28'' |
| Q20L60X40P000  |   40.0 |  80.23% |     11825 | 11.13M | 1454 |      1116 | 209.21K | 2597 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:02'12'' | 0:01'23'' |
| Q20L60X60P000  |   60.0 |  79.01% |      8934 | 11.05M | 1791 |      1072 | 215.85K | 3250 |   50.0 | 2.0 |  14.7 |  84.0 | "31,41,51,61,71,81" | 0:02'55'' | 0:01'26'' |
| Q20L60XallP000 |   73.6 |  78.50% |      8370 | 11.02M | 1926 |      1072 |  223.5K | 3453 |   62.0 | 3.0 |  17.7 | 106.5 | "31,41,51,61,71,81" | 0:03'25'' | 0:01'28'' |
| Q25L60X40P000  |   40.0 |  82.08% |     18351 |  11.2M | 1030 |      2346 |    170K | 1800 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'26'' |
| Q25L60X60P000  |   60.0 |  80.96% |     15230 | 11.17M | 1174 |      1547 |  166.3K | 2049 |   51.0 | 2.0 |  15.0 |  85.5 | "31,41,51,61,71,81" | 0:02'56'' | 0:01'25'' |
| Q25L60XallP000 |   73.2 |  80.76% |     14570 | 11.17M | 1236 |      1446 | 163.86K | 2092 |   62.0 | 3.0 |  17.7 | 106.5 | "31,41,51,61,71,81" | 0:03'23'' | 0:01'26'' |
| Q30L60X40P000  |   40.0 |  84.23% |     21519 | 11.22M |  855 |      1767 | 179.37K | 1716 |   34.0 | 1.0 |  10.3 |  55.5 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'31'' |
| Q30L60X60P000  |   60.0 |  83.24% |     18973 |  11.2M |  986 |      1859 | 162.99K | 1696 |   51.0 | 2.0 |  15.0 |  85.5 | "31,41,51,61,71,81" | 0:02'54'' | 0:01'30'' |
| Q30L60XallP000 |   70.7 |  82.93% |     18144 |  11.2M | 1025 |      1859 | 163.05K | 1810 |   60.0 | 2.0 |  18.0 |  99.0 | "31,41,51,61,71,81" | 0:03'19'' | 0:01'27'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  91.27% |     25042 | 11.22M |  736 |      2471 | 201.01K | 1944 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'11'' | 0:01'38'' |
| Q0L0X60P000    |   60.0 |  89.61% |     19525 |  11.2M |  913 |      2215 | 208.77K | 2025 |   50.0 | 2.0 |  14.7 |  84.0 | "31,41,51,61,71,81" | 0:01'21'' | 0:01'29'' |
| Q0L0XallP000   |   73.5 |  88.93% |     15431 | 11.18M | 1140 |      2215 | 221.53K | 2307 |   62.0 | 3.0 |  17.7 | 106.5 | "31,41,51,61,71,81" | 0:01'28'' | 0:01'30'' |
| Q20L60X40P000  |   40.0 |  91.26% |     25341 | 11.22M |  716 |      2521 | 208.86K | 1800 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'08'' | 0:01'36'' |
| Q20L60X60P000  |   60.0 |  89.71% |     20215 | 11.21M |  900 |      2318 | 192.08K | 1906 |   51.0 | 2.0 |  15.0 |  85.5 | "31,41,51,61,71,81" | 0:01'21'' | 0:01'30'' |
| Q20L60XallP000 |   73.6 |  88.99% |     15694 | 11.18M | 1113 |      2318 | 215.79K | 2271 |   62.0 | 2.0 |  18.7 | 102.0 | "31,41,51,61,71,81" | 0:01'28'' | 0:01'27'' |
| Q25L60X40P000  |   40.0 |  92.19% |     30172 | 11.22M |  631 |      2448 | 205.65K | 1714 |   34.0 | 1.0 |  10.3 |  55.5 | "31,41,51,61,71,81" | 0:01'09'' | 0:01'45'' |
| Q25L60X60P000  |   60.0 |  90.60% |     25402 | 11.22M |  727 |      3364 | 181.56K | 1508 |   51.0 | 2.0 |  15.0 |  85.5 | "31,41,51,61,71,81" | 0:01'22'' | 0:01'31'' |
| Q25L60XallP000 |   73.2 |  89.99% |     22525 | 11.21M |  825 |      3364 | 191.24K | 1681 |   62.0 | 2.0 |  18.7 | 102.0 | "31,41,51,61,71,81" | 0:01'28'' | 0:01'33'' |
| Q30L60X40P000  |   40.0 |  92.90% |     30622 | 11.23M |  616 |      2652 | 216.71K | 1721 |   34.0 | 1.0 |  10.3 |  55.5 | "31,41,51,61,71,81" | 0:01'08'' | 0:01'48'' |
| Q30L60X60P000  |   60.0 |  91.60% |     27883 | 11.24M |  671 |      3220 | 192.74K | 1462 |   51.0 | 2.0 |  15.0 |  85.5 | "31,41,51,61,71,81" | 0:01'21'' | 0:01'40'' |
| Q30L60XallP000 |   70.7 |  91.14% |     25710 | 11.22M |  707 |      3220 | 178.16K | 1531 |   60.0 | 2.0 |  18.0 |  99.0 | "31,41,51,61,71,81" | 0:01'26'' | 0:01'35'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  83.96% |     16632 | 11.11M | 1062 |      1090 | 238.63K | 2036 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:02'37'' | 0:01'21'' |
| MRX40P001  |   40.0 |  84.12% |     16433 | 11.11M | 1077 |      1052 | 238.15K | 2105 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:02'37'' | 0:01'21'' |
| MRX60P000  |   60.0 |  82.13% |     13472 | 11.06M | 1300 |      1057 | 251.69K | 2464 |   51.0 | 3.0 |  14.0 |  90.0 | "31,41,51,61,71,81" | 0:03'34'' | 0:01'23'' |
| MRX80P000  |   80.0 |  81.08% |     12178 | 11.01M | 1453 |      1021 | 274.05K | 2844 |   68.0 | 4.0 |  18.7 | 120.0 | "31,41,51,61,71,81" | 0:04'30'' | 0:01'24'' |
| MRXallP000 |   97.9 |  80.42% |     11088 | 11.02M | 1545 |      1039 | 246.03K | 2825 |   83.0 | 5.0 |  20.0 | 147.0 | "31,41,51,61,71,81" | 0:05'22'' | 0:01'24'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  89.30% |     34069 | 11.17M |  561 |      1621 | 212.62K | 1185 |   34.0 | 1.0 |  10.3 |  55.5 | "31,41,51,61,71,81" | 0:01'18'' | 0:01'24'' |
| MRX40P001  |   40.0 |  89.46% |     35368 |  11.2M |  547 |      1612 | 185.32K | 1122 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'16'' | 0:01'23'' |
| MRX60P000  |   60.0 |  88.76% |     26158 | 11.17M |  712 |      1784 |  215.9K | 1401 |   51.0 | 2.0 |  15.0 |  85.5 | "31,41,51,61,71,81" | 0:01'29'' | 0:01'23'' |
| MRX80P000  |   80.0 |  88.43% |     20238 | 11.16M |  885 |      1234 |  211.2K | 1746 |   68.0 | 3.0 |  19.7 | 115.5 | "31,41,51,61,71,81" | 0:01'41'' | 0:01'25'' |
| MRXallP000 |   97.9 |  88.14% |     18088 | 11.19M | 1024 |      1612 | 190.38K | 1785 |   83.0 | 4.0 |  20.0 | 142.5 | "31,41,51,61,71,81" | 0:01'51'' | 0:01'24'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |    Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|-------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |  73.86% |     47371 | 11.25M | 435 |      6786 | 318.52K | 118 |   32.0 | 1.0 |   9.7 |  52.5 | 0:01'38'' |
| 7_mergeKunitigsAnchors   |  82.12% |     26267 | 11.22M | 711 |      4408 | 287.82K | 110 |   32.0 | 1.0 |   9.7 |  52.5 | 0:02'16'' |
| 7_mergeMRKunitigsAnchors |  80.13% |     21966 | 11.18M | 820 |      1986 | 214.77K | 121 |   32.0 | 1.0 |   9.7 |  52.5 | 0:02'07'' |
| 7_mergeMRTadpoleAnchors  |  80.86% |     45154 | 11.23M | 465 |      3723 | 189.65K |  82 |   32.0 | 1.0 |   9.7 |  52.5 | 0:02'05'' |
| 7_mergeTadpoleAnchors    |  82.82% |     37883 | 11.25M | 495 |      4084 | 206.78K |  87 |   32.0 | 1.0 |   9.7 |  52.5 | 0:02'19'' |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |    Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|-------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|----------:|
| 8_spades     |  92.23% |    122839 | 11.32M | 166 |      8659 | 209.55K | 348 |   62.0 | 2.0 |  18.7 | 102.0 | 0:01'22'' |
| 8_spades_MR  |  94.36% |    122896 | 11.42M | 182 |      6870 | 186.45K | 351 |   84.0 | 3.0 |  20.0 | 139.5 | 0:01'26'' |
| 8_megahit    |  92.59% |     49527 | 11.24M | 410 |      3653 | 222.88K | 821 |   62.0 | 2.0 |  18.7 | 102.0 | 0:01'24'' |
| 8_megahit_MR |  93.48% |     87262 | 11.46M | 280 |      5440 |    182K | 437 |   84.0 | 3.0 |  20.0 | 139.5 | 0:01'23'' |
| 8_platanus   |  83.47% |    149271 | 11.37M | 153 |      4396 | 149.64K | 300 |   62.0 | 2.0 |  18.7 | 102.0 | 0:01'23'' |


Table: statCanu

| Name                |    N50 |      Sum |     # |
|:--------------------|-------:|---------:|------:|
| Genome              | 924431 | 12157105 |    17 |
| Paralogs            |   3851 |  1059148 |   366 |
| Xall.trim.corrected |   7965 |   450.5M | 66099 |
| Xall.trim.contig    | 813374 | 12360766 |    26 |


Table: statFinal

| Name                     |    N50 |      Sum |    # |
|:-------------------------|-------:|---------:|-----:|
| Genome                   | 924431 | 12157105 |   17 |
| Paralogs                 |   3851 |  1059148 |  366 |
| 7_mergeAnchors.anchors   |  47371 | 11251628 |  435 |
| 7_mergeAnchors.others    |   6786 |   318522 |  118 |
| anchorLong               |  49133 | 11199032 |  407 |
| anchorFill               | 244682 | 11280438 |   93 |
| canu_Xall-trim           | 813374 | 12360766 |   26 |
| spades.contig            | 120316 | 11706235 | 1101 |
| spades.scaffold          | 132560 | 11706875 | 1082 |
| spades.non-contained     | 122873 | 11528443 |  204 |
| spades_MR.contig         | 125460 | 11732592 |  670 |
| spades_MR.scaffold       | 132728 | 11733297 |  660 |
| spades_MR.non-contained  | 126581 | 11604188 |  196 |
| megahit.contig           |  49142 | 11641172 |  950 |
| megahit.non-contained    |  49287 | 11463998 |  473 |
| megahit_MR.contig        |  84456 | 12002172 | 1257 |
| megahit_MR.non-contained |  86307 | 11642588 |  309 |
| platanus.contig          |  39177 | 12113080 | 4268 |
| platanus.scaffold        | 153178 | 11959734 | 3270 |
| platanus.non-contained   | 155016 | 11514764 |  172 |


### s288c-Hiseq

Table: statInsertSize

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| genome.bbtools  | 356.5 |    320 | 484.3 |                         45.78% |
| tadpole.bbtools | 339.2 |    309 | 144.5 |                         43.33% |
| genome.picard   | 352.1 |    322 | 142.5 |                             FR |
| tadpole.picard  | 342.9 |    313 | 141.4 |                             FR |


Table: statSgaStats

| Item           |   Value |
|:---------------|--------:|
| incorrectBases |   0.16% |
| perfectReads   |  91.55% |
| overlapDepth   | 2263.01 |


Table: statReads

| Name     |    N50 |      Sum |        # |
|:---------|-------:|---------:|---------:|
| Genome   | 924431 | 12157105 |       17 |
| Paralogs |   3851 |  1059148 |      366 |
| Illumina |    151 |    2.94G | 19464114 |
| trim     |    150 |    2.68G | 18162546 |
| Q20L60   |    150 |    2.63G | 17868322 |
| Q25L60   |    150 |    2.52G | 17274131 |
| Q30L60   |    150 |    2.37G | 16419895 |


Table: statTrimReads

| Name     | N50 |   Sum |        # |
|:---------|----:|------:|---------:|
| clumpify | 151 | 2.78G | 18397208 |
| trim     | 150 | 2.68G | 18163836 |
| filter   | 150 | 2.68G | 18162546 |
| R1       | 150 | 1.34G |  9081273 |
| R2       | 150 | 1.34G |  9081273 |
| Rs       |   0 |     0 |        0 |


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
| merged        | 356 |    2.4G |  7288892 |
| unmerged.raw  | 190 | 527.63M |  2835946 |
| unmerged.trim | 190 | 527.63M |  2835938 |
| U1            | 190 | 267.14M |  1417969 |
| U2            | 190 |  260.5M |  1417969 |
| Us            |   0 |       0 |        0 |
| pe.cor        | 327 |   2.93G | 17413722 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 211.2 |    221 |  53.0 |         39.55% |
| ihist.merge.txt  | 328.9 |    326 |  95.0 |         83.71% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |  RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|-------:|-------:|---------:|----------:|
| Q0L0   | 220.4 |  197.9 |   10.20% |     141 | "105" | 12.16M | 12.44M |     1.02 | 0:04'12'' |
| Q20L60 | 216.0 |  197.7 |    8.46% |     141 | "105" | 12.16M | 12.14M |     1.00 | 0:04'04'' |
| Q25L60 | 207.2 |  195.1 |    5.84% |     140 | "105" | 12.16M | 11.84M |     0.97 | 0:04'06'' |
| Q30L60 | 195.2 |  186.0 |    4.71% |     142 | "105" | 12.16M | 11.72M |     0.96 | 0:03'50'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  88.08% |      9786 | 10.35M | 1989 |       971 |   1.24M | 5228 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'14'' | 0:01'41'' |
| Q0L0X40P001    |   40.0 |  87.70% |      9274 | 10.26M | 2020 |      1003 |   1.32M | 5219 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'13'' | 0:01'37'' |
| Q0L0X40P002    |   40.0 |  87.79% |      9180 | 10.27M | 1997 |       968 |   1.32M | 5298 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'14'' | 0:01'39'' |
| Q0L0X40P003    |   40.0 |  87.76% |      9924 | 10.32M | 1959 |       929 |   1.26M | 5221 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'13'' | 0:01'34'' |
| Q0L0X80P000    |   80.0 |  85.88% |     10250 | 10.55M | 1851 |       797 | 818.38K | 4345 |   73.0 |  7.0 |  17.3 | 141.0 | "31,41,51,61,71,81" | 0:03'39'' | 0:01'37'' |
| Q0L0X80P001    |   80.0 |  85.99% |      9714 | 10.56M | 1883 |       796 | 804.75K | 4438 |   74.0 |  7.0 |  17.7 | 142.5 | "31,41,51,61,71,81" | 0:03'39'' | 0:01'34'' |
| Q0L0X120P000   |  120.0 |  84.05% |      9164 | 10.73M | 1878 |       592 | 493.95K | 4165 |  111.0 | 11.0 |  20.0 | 216.0 | "31,41,51,61,71,81" | 0:05'06'' | 0:01'39'' |
| Q0L0XallP000   |  197.9 |  82.78% |      7713 | 10.81M | 2065 |       510 | 317.78K | 4538 |  183.0 | 18.0 |  20.0 | 355.5 | "31,41,51,61,71,81" | 0:07'54'' | 0:01'47'' |
| Q20L60X40P000  |   40.0 |  87.99% |      9968 | 10.32M | 1968 |       963 |   1.25M | 5133 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'36'' |
| Q20L60X40P001  |   40.0 |  88.38% |     10729 | 10.35M | 1872 |       974 |   1.28M | 5149 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'40'' |
| Q20L60X40P002  |   40.0 |  88.34% |     10421 | 10.36M | 1915 |       949 |   1.26M | 5165 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'12'' | 0:01'37'' |
| Q20L60X40P003  |   40.0 |  88.37% |     10475 | 10.32M | 1948 |       974 |    1.3M | 5266 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'12'' | 0:01'40'' |
| Q20L60X80P000  |   80.0 |  86.71% |     11374 | 10.63M | 1727 |       828 | 788.36K | 4212 |   74.0 |  7.0 |  17.7 | 142.5 | "31,41,51,61,71,81" | 0:03'35'' | 0:01'40'' |
| Q20L60X80P001  |   80.0 |  86.28% |     11334 | 10.63M | 1738 |       805 | 753.77K | 4104 |   74.0 |  7.0 |  17.7 | 142.5 | "31,41,51,61,71,81" | 0:03'37'' | 0:01'34'' |
| Q20L60X120P000 |  120.0 |  85.15% |     10565 | 10.79M | 1689 |       814 |  499.4K | 3887 |  111.0 | 10.0 |  20.0 | 211.5 | "31,41,51,61,71,81" | 0:05'01'' | 0:01'42'' |
| Q20L60XallP000 |  197.7 |  84.13% |      9469 |  10.9M | 1800 |       707 | 299.44K | 3998 |  183.0 | 17.0 |  20.0 | 351.0 | "31,41,51,61,71,81" | 0:07'49'' | 0:01'47'' |
| Q25L60X40P000  |   40.0 |  88.43% |     11649 | 10.39M | 1819 |       998 |   1.25M | 4987 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'36'' |
| Q25L60X40P001  |   40.0 |  88.84% |     10799 |  10.4M | 1872 |       944 |    1.2M | 5057 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'10'' | 0:01'39'' |
| Q25L60X40P002  |   40.0 |  88.74% |     10883 | 10.37M | 1895 |       918 |   1.27M | 5229 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'10'' | 0:01'42'' |
| Q25L60X40P003  |   40.0 |  88.76% |     10535 | 10.37M | 1894 |       982 |   1.26M | 5093 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'38'' |
| Q25L60X80P000  |   80.0 |  87.21% |     11349 | 10.56M | 1748 |       903 | 918.67K | 4241 |   74.0 |  6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:03'33'' | 0:01'40'' |
| Q25L60X80P001  |   80.0 |  87.23% |     12051 | 10.65M | 1645 |       872 | 788.81K | 4073 |   74.0 |  7.0 |  17.7 | 142.5 | "31,41,51,61,71,81" | 0:03'34'' | 0:01'39'' |
| Q25L60X120P000 |  120.0 |  86.15% |     11221 | 10.89M | 1615 |       708 | 484.03K | 3860 |  111.0 | 10.0 |  20.0 | 211.5 | "31,41,51,61,71,81" | 0:05'00'' | 0:01'45'' |
| Q25L60XallP000 |  195.1 |  84.79% |     10357 | 10.95M | 1684 |       793 | 276.27K | 3807 |  182.0 | 17.0 |  20.0 | 349.5 | "31,41,51,61,71,81" | 0:07'39'' | 0:01'48'' |
| Q30L60X40P000  |   40.0 |  89.35% |     11428 | 10.41M | 1836 |       973 |   1.23M | 5167 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'12'' | 0:01'41'' |
| Q30L60X40P001  |   40.0 |  89.22% |     11444 | 10.41M | 1800 |      1001 |   1.24M | 5095 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'12'' | 0:01'37'' |
| Q30L60X40P002  |   40.0 |  89.00% |     10888 | 10.38M | 1862 |       968 |   1.25M | 5055 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'12'' | 0:01'41'' |
| Q30L60X40P003  |   40.0 |  89.61% |     11884 | 10.44M | 1732 |       970 |   1.23M | 5020 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'12'' | 0:01'43'' |
| Q30L60X80P000  |   80.0 |  87.92% |     12356 | 10.62M | 1690 |       923 | 921.79K | 4281 |   74.0 |  6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:03'35'' | 0:01'45'' |
| Q30L60X80P001  |   80.0 |  88.03% |     12485 | 10.59M | 1651 |       931 | 903.96K | 4141 |   74.0 |  6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:03'36'' | 0:01'41'' |
| Q30L60X120P000 |  120.0 |  86.56% |     12369 | 10.92M | 1494 |       728 | 436.98K | 3675 |  112.0 | 10.0 |  20.0 | 213.0 | "31,41,51,61,71,81" | 0:04'59'' | 0:01'45'' |
| Q30L60XallP000 |  186.0 |  85.49% |     11611 | 11.02M | 1559 |       798 | 265.38K | 3598 |  174.0 | 16.0 |  20.0 | 333.0 | "31,41,51,61,71,81" | 0:07'20'' | 0:01'48'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  92.01% |     11667 | 10.73M | 1587 |       639 | 762.42K | 5113 |   37.0 |  4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:01'12'' | 0:01'44'' |
| Q0L0X40P001    |   40.0 |  91.64% |      9745 |  10.4M | 1889 |       939 |   1.24M | 5462 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:01'38'' |
| Q0L0X40P002    |   40.0 |  91.63% |     11373 | 10.67M | 1617 |       738 | 814.33K | 5060 |   37.0 |  4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:01'09'' | 0:01'38'' |
| Q0L0X40P003    |   40.0 |  91.94% |     12481 | 10.75M | 1546 |       776 | 773.77K | 4998 |   37.0 |  4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:01'11'' | 0:01'44'' |
| Q0L0X80P000    |   80.0 |  92.32% |     16443 |  10.7M | 1410 |       773 | 912.78K | 4369 |   74.0 |  6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:01'31'' | 0:01'52'' |
| Q0L0X80P001    |   80.0 |  92.15% |     15433 | 10.67M | 1434 |       827 | 947.27K | 4403 |   74.0 |  6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:01'31'' | 0:01'52'' |
| Q0L0X120P000   |  120.0 |  91.54% |     15464 | 10.94M | 1283 |       612 | 497.51K | 3608 |  111.0 |  9.0 |  20.0 | 207.0 | "31,41,51,61,71,81" | 0:01'53'' | 0:01'53'' |
| Q0L0XallP000   |  197.9 |  90.70% |     13795 | 11.06M | 1323 |       743 | 303.42K | 3462 |  184.0 | 15.0 |  20.0 | 343.5 | "31,41,51,61,71,81" | 0:02'44'' | 0:02'03'' |
| Q20L60X40P000  |   40.0 |  91.89% |     11863 | 10.68M | 1594 |       720 | 792.66K | 5039 |   37.0 |  4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:01'10'' | 0:01'43'' |
| Q20L60X40P001  |   40.0 |  91.89% |     10426 | 10.45M | 1814 |       925 |   1.17M | 5394 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'08'' | 0:01'39'' |
| Q20L60X40P002  |   40.0 |  91.90% |     10318 | 10.42M | 1837 |       928 |   1.17M | 5391 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'09'' | 0:01'39'' |
| Q20L60X40P003  |   40.0 |  92.04% |     10539 | 10.42M | 1856 |       945 |   1.21M | 5512 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'11'' | 0:01'39'' |
| Q20L60X80P000  |   80.0 |  92.58% |     16120 | 10.69M | 1397 |       867 | 989.15K | 4471 |   74.0 |  6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:01'35'' | 0:01'53'' |
| Q20L60X80P001  |   80.0 |  92.47% |     15072 | 10.67M | 1467 |       863 | 981.38K | 4419 |   74.0 |  6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:01'32'' | 0:01'55'' |
| Q20L60X120P000 |  120.0 |  91.84% |     16503 | 10.96M | 1229 |       652 | 489.02K | 3633 |  111.0 |  9.0 |  20.0 | 207.0 | "31,41,51,61,71,81" | 0:01'54'' | 0:01'57'' |
| Q20L60XallP000 |  197.7 |  90.85% |     14170 | 11.08M | 1288 |       772 | 287.89K | 3351 |  184.0 | 15.0 |  20.0 | 343.5 | "31,41,51,61,71,81" | 0:02'47'' | 0:01'59'' |
| Q25L60X40P000  |   40.0 |  92.27% |     11767 | 10.71M | 1562 |       783 | 773.39K | 5099 |   37.0 |  4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:01'10'' | 0:01'41'' |
| Q25L60X40P001  |   40.0 |  92.30% |     10742 | 10.49M | 1797 |       921 |   1.12M | 5387 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:01'42'' |
| Q25L60X40P002  |   40.0 |  92.27% |     10569 | 10.47M | 1854 |       924 |    1.2M | 5460 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'08'' | 0:01'41'' |
| Q25L60X40P003  |   40.0 |  92.22% |     10557 | 10.44M | 1809 |       915 |   1.15M | 5326 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'11'' | 0:01'42'' |
| Q25L60X80P000  |   80.0 |  92.71% |     16359 | 10.72M | 1372 |       911 | 960.39K | 4395 |   74.0 |  6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:01'32'' | 0:01'52'' |
| Q25L60X80P001  |   80.0 |  92.95% |     16325 | 10.74M | 1385 |       824 | 956.55K | 4383 |   74.0 |  6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:01'30'' | 0:01'59'' |
| Q25L60X120P000 |  120.0 |  92.26% |     16615 |    11M | 1167 |       566 | 459.83K | 3661 |  112.0 | 10.0 |  20.0 | 213.0 | "31,41,51,61,71,81" | 0:01'51'' | 0:01'59'' |
| Q25L60XallP000 |  195.1 |  91.32% |     14768 |  11.1M | 1234 |       794 | 272.55K | 3338 |  183.0 | 16.0 |  20.0 | 346.5 | "31,41,51,61,71,81" | 0:02'44'' | 0:02'01'' |
| Q30L60X40P000  |   40.0 |  92.24% |     10572 | 10.47M | 1828 |       953 |   1.14M | 5383 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'09'' | 0:01'40'' |
| Q30L60X40P001  |   40.0 |  92.38% |     10305 | 10.44M | 1866 |       968 |   1.19M | 5494 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'09'' | 0:01'41'' |
| Q30L60X40P002  |   40.0 |  92.30% |     10465 | 10.43M | 1833 |       930 |   1.22M | 5425 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'09'' | 0:01'39'' |
| Q30L60X40P003  |   40.0 |  92.41% |     10883 | 10.48M | 1763 |       880 |   1.15M | 5348 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'09'' | 0:01'42'' |
| Q30L60X80P000  |   80.0 |  93.16% |     17244 | 10.77M | 1325 |       809 | 865.25K | 4430 |   75.0 |  6.0 |  19.0 | 139.5 | "31,41,51,61,71,81" | 0:01'31'' | 0:01'58'' |
| Q30L60X80P001  |   80.0 |  93.30% |     17252 | 10.77M | 1294 |       817 | 896.19K | 4384 |   75.0 |  6.0 |  19.0 | 139.5 | "31,41,51,61,71,81" | 0:01'32'' | 0:02'02'' |
| Q30L60X120P000 |  120.0 |  92.80% |     17184 | 11.02M | 1141 |       673 | 481.24K | 3700 |  112.0 |  9.0 |  20.0 | 208.5 | "31,41,51,61,71,81" | 0:01'54'' | 0:02'02'' |
| Q30L60XallP000 |  186.0 |  91.92% |     16135 | 11.16M | 1168 |       771 | 271.38K | 3367 |  175.0 | 15.0 |  20.0 | 330.0 | "31,41,51,61,71,81" | 0:02'39'' | 0:02'06'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  84.63% |     13522 | 10.45M | 1621 |       994 | 925.66K | 3191 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'39'' | 0:01'25'' |
| MRX40P001  |   40.0 |  85.07% |     14647 | 10.52M | 1541 |       984 | 879.95K | 3118 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'38'' | 0:01'25'' |
| MRX40P002  |   40.0 |  85.49% |     13115 | 10.45M | 1636 |       910 | 934.91K | 3187 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'37'' | 0:01'24'' |
| MRX40P003  |   40.0 |  84.97% |     13489 | 10.45M | 1639 |       993 | 913.82K | 3133 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'38'' | 0:01'25'' |
| MRX40P004  |   40.0 |  85.11% |     13523 | 10.48M | 1618 |       909 | 908.73K | 3198 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'38'' | 0:01'24'' |
| MRX40P005  |   40.0 |  85.24% |     12938 | 10.42M | 1640 |       994 | 946.04K | 3237 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'38'' | 0:01'25'' |
| MRX80P000  |   80.0 |  82.95% |     12268 |  10.6M | 1588 |       748 | 691.58K | 3067 |   73.0 |  7.0 |  17.3 | 141.0 | "31,41,51,61,71,81" | 0:04'30'' | 0:01'26'' |
| MRX80P001  |   80.0 |  83.23% |     12475 | 10.62M | 1527 |       784 | 680.89K | 3012 |   73.0 |  7.0 |  17.3 | 141.0 | "31,41,51,61,71,81" | 0:04'30'' | 0:01'24'' |
| MRX80P002  |   80.0 |  83.34% |     12766 | 10.61M | 1559 |       739 | 689.84K | 3066 |   73.0 |  7.0 |  17.3 | 141.0 | "31,41,51,61,71,81" | 0:04'31'' | 0:01'28'' |
| MRX120P000 |  120.0 |  82.19% |     11488 | 10.78M | 1566 |       546 | 477.87K | 3205 |  110.0 | 11.0 |  20.0 | 214.5 | "31,41,51,61,71,81" | 0:06'23'' | 0:01'29'' |
| MRX120P001 |  120.0 |  82.08% |     11635 | 10.77M | 1535 |       607 | 472.82K | 3170 |  110.0 | 11.0 |  20.0 | 214.5 | "31,41,51,61,71,81" | 0:06'23'' | 0:01'31'' |
| MRXallP000 |  241.2 |  80.75% |      9096 | 10.88M | 1836 |       243 | 271.14K | 3830 |  220.0 | 24.0 |  20.0 | 438.0 | "31,41,51,61,71,81" | 0:12'08'' | 0:01'40'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  90.49% |     16590 | 10.58M | 1431 |       893 | 989.87K | 3419 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'19'' | 0:01'35'' |
| MRX40P001  |   40.0 |  90.54% |     16874 | 10.58M | 1442 |       821 | 948.16K | 3422 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'18'' | 0:01'35'' |
| MRX40P002  |   40.0 |  90.32% |     17036 |  10.6M | 1390 |       825 | 910.01K | 3257 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'17'' | 0:01'32'' |
| MRX40P003  |   40.0 |  90.21% |     17159 | 10.57M | 1421 |       854 | 956.63K | 3367 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'18'' | 0:01'35'' |
| MRX40P004  |   40.0 |  90.40% |     16457 | 10.59M | 1411 |       858 | 938.23K | 3317 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'18'' | 0:01'33'' |
| MRX40P005  |   40.0 |  90.52% |     16635 | 10.55M | 1421 |       894 |      1M | 3412 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'17'' | 0:01'36'' |
| MRX80P000  |   80.0 |  88.92% |     18465 | 10.73M | 1222 |       786 | 653.17K | 2456 |   74.0 |  6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:01'43'' | 0:01'32'' |
| MRX80P001  |   80.0 |  88.99% |     19113 | 10.73M | 1214 |       811 | 667.43K | 2500 |   74.0 |  6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:01'44'' | 0:01'29'' |
| MRX80P002  |   80.0 |  89.19% |     18988 | 10.72M | 1242 |       790 | 695.25K | 2606 |   74.0 |  6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:01'44'' | 0:01'33'' |
| MRX120P000 |  120.0 |  87.90% |     18238 | 10.95M | 1043 |       774 | 397.77K | 2203 |  111.0 |  9.0 |  20.0 | 207.0 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'31'' |
| MRX120P001 |  120.0 |  88.26% |     18240 | 10.94M | 1063 |       697 | 412.86K | 2323 |  111.0 |  9.0 |  20.0 | 207.0 | "31,41,51,61,71,81" | 0:02'10'' | 0:01'36'' |
| MRXallP000 |  241.2 |  87.58% |     15419 | 11.09M | 1171 |       954 | 229.16K | 2513 |  224.0 | 19.5 |  20.0 | 423.8 | "31,41,51,61,71,81" | 0:03'47'' | 0:01'45'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |    Sum |    # | N50Others |   Sum |    # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|-------:|-----:|----------:|------:|-----:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |  77.79% |     21294 | 10.85M | 1175 |      1879 |  4.2M | 2493 |   96.0 | 7.0 |  20.0 | 175.5 | 0:02'06'' |
| 7_mergeKunitigsAnchors   |  90.12% |     17986 | 10.85M | 1332 |      1662 | 3.41M | 2257 |   95.0 | 7.0 |  20.0 | 174.0 | 0:03'52'' |
| 7_mergeMRKunitigsAnchors |  88.28% |     16762 | 10.84M | 1371 |      1433 | 1.69M | 1306 |   96.0 | 7.0 |  20.0 | 175.5 | 0:03'18'' |
| 7_mergeMRTadpoleAnchors  |  87.72% |     13154 | 10.69M | 1530 |      1400 | 1.85M | 1423 |   95.0 | 6.0 |  20.0 | 169.5 | 0:03'08'' |
| 7_mergeTadpoleAnchors    |  89.00% |     16345 | 10.87M | 1370 |      1559 | 3.23M | 2227 |   95.0 | 7.0 |  20.0 | 174.0 | 0:03'31'' |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|----------:|
| 8_spades     |  82.61% |     10759 | 10.87M | 1501 |      1105 | 641.76K | 1766 |   96.0 | 7.0 |  20.0 | 175.5 | 0:01'53'' |
| 8_spades_MR  |  84.81% |      9257 | 10.85M | 1752 |      1089 | 725.31K | 1985 |   96.0 | 6.0 |  20.0 | 171.0 | 0:01'55'' |
| 8_megahit    |  78.08% |     10613 |  10.8M | 1555 |      1014 | 631.03K | 2063 |   96.0 | 7.0 |  20.0 | 175.5 | 0:01'56'' |
| 8_megahit_MR |  84.00% |     11498 | 10.96M | 1471 |      1052 | 649.87K | 1916 |   96.0 | 7.0 |  20.0 | 175.5 | 0:01'54'' |
| 8_platanus   |  84.94% |      8564 | 10.73M | 1823 |       953 | 684.68K | 2147 |   90.0 | 5.0 |  20.0 | 157.5 | 0:01'51'' |


Table: statFinal

| Name                     |    N50 |      Sum |    # |
|:-------------------------|-------:|---------:|-----:|
| Genome                   | 924431 | 12157105 |   17 |
| Paralogs                 |   3851 |  1059148 |  366 |
| 7_mergeAnchors.anchors   |  21294 | 10854835 | 1175 |
| 7_mergeAnchors.others    |   1879 |  4196704 | 2493 |
| anchorLong               |  21516 | 10849949 | 1167 |
| anchorFill               |  78578 | 11269791 |  243 |
| spades.contig            |  98194 | 11748052 | 1418 |
| spades.scaffold          | 107724 | 11748872 | 1390 |
| spades.non-contained     | 102190 | 11515252 |  265 |
| spades_MR.contig         | 108226 | 11736917 |  848 |
| spades_MR.scaffold       | 142479 | 11740952 |  812 |
| spades_MR.non-contained  | 109177 | 11572239 |  233 |
| megahit.contig           |  43020 | 11646704 | 1103 |
| megahit.non-contained    |  44023 | 11429429 |  509 |
| megahit_MR.contig        |  48765 | 12085200 | 1756 |
| megahit_MR.non-contained |  50037 | 11607566 |  445 |
| platanus.contig          |   7451 | 12205621 | 5475 |
| platanus.scaffold        |  67382 | 11916760 | 3298 |
| platanus.non-contained   |  70075 | 11412361 |  324 |


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

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue largemem \
    --genome 137567477 \
    --is_euk \
    --trim2 "--dedupe" \
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
    --sgapreqc \
    --parallel 24

```

## iso_1: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=iso_1

cd ${WORKING_DIR}/${BASE_NAME}

bash 0_bsub.sh
#bash 0_master.sh

#bash 0_cleanup.sh

```

The `meryl` step of `canu` failed in hpcc, run it locally.

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 587.2 |    244 | 3424.7 |                         43.08% |
| tadpole.bbtools | 257.0 |    234 |  108.0 |                         34.81% |
| genome.picard   | 265.6 |    244 |  109.9 |                             FR |
| tadpole.picard  | 257.1 |    235 |  107.5 |                             FR |


Table: statReads

| Name      |      N50 |       Sum |         # |
|:----------|---------:|----------:|----------:|
| Genome    | 25286936 | 137567477 |         8 |
| Paralogs  |     4031 |  13665900 |      4492 |
| Illumina  |      101 |    18.12G | 179363706 |
| trim      |      100 |    13.47G | 136635059 |
| Q25L60    |      100 |    12.61G | 128296090 |
| Q30L60    |      100 |    11.42G | 117749564 |
| PacBio    |    13704 |     5.62G |    630193 |
| Xall.raw  |    13704 |     5.62G |    630193 |
| Xall.trim |    13572 |     5.22G |    541317 |


Table: statTrimReads

| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| clumpify | 101 | 15.01G | 148592499 |
| trim     | 100 | 13.47G | 136711090 |
| filter   | 100 | 13.47G | 136635059 |
| R1       | 100 |  5.66G |  57300915 |
| R2       | 100 |  5.66G |  57300915 |
| Rs       | 100 |  2.15G |  22033229 |


```text
#trim
#Matched	1578903	1.06257%
#Name	Reads	ReadsPct
Reverse_adapter	1136448	0.76481%
TruSeq_Adapter_Index_1_6	175155	0.11788%
Nextera_LMP_Read2_External_Adapter	64132	0.04316%
pcr_dimer	54794	0.03688%
TruSeq_Universal_Adapter	38238	0.02573%
PCR_Primers	26578	0.01789%
PhiX_read2_adapter	22623	0.01522%
TruSeq_Adapter_Index_5	11993	0.00807%
I5_Nextera_Transposase_1	6016	0.00405%
PhiX_read1_adapter	5605	0.00377%
RNA_Adapter_(RA5)_part_#_15013205	3911	0.00263%
I7_Nextera_Transposase_2	3327	0.00224%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	2650	0.00178%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	2509	0.00169%
Nextera_LMP_Read1_External_Adapter	2189	0.00147%
I5_Nextera_Transposase_2	1834	0.00123%
I7_Adapter_Nextera_No_Barcode	1583	0.00107%
Bisulfite_R1	1496	0.00101%
I5_Adapter_Nextera	1394	0.00094%
RNA_PCR_Primer_(RP1)_part_#_15013198	1328	0.00089%
I7_Nextera_Transposase_1	1310	0.00088%
Bisulfite_R2	1289	0.00087%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N701	1273	0.00086%
```

```text
#filter
#Matched	76031	0.05561%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	75790	0.05544%
```


Table: statMergeReads

| Name          | N50 |     Sum |         # |
|:--------------|----:|--------:|----------:|
| clumped       | 100 |  11.56G | 117445953 |
| ecco          | 100 |  11.55G | 117445952 |
| ecct          | 100 |  11.18G | 113691481 |
| extended      | 140 |  15.55G | 113691481 |
| merged        | 140 | 245.39M |   1762269 |
| unmerged.raw  | 140 |  15.08G | 110166942 |
| unmerged.trim | 140 |  15.08G | 110149741 |
| U1            | 140 |   5.44G |  39529575 |
| U2            | 140 |   5.44G |  39529575 |
| Us            | 140 |    4.2G |  31090591 |
| pe.cor        | 140 |  15.35G | 144764870 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt |  98.0 |    100 |  10.6 |          2.91% |
| ihist.merge.txt  | 139.2 |    140 |  28.8 |          3.10% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|--------:|--------:|---------:|----------:|
| Q0L0   |  98.0 |   88.1 |   10.13% |      99 | "71" | 137.57M | 129.44M |     0.94 | 0:25'37'' |
| Q25L60 |  91.8 |   84.4 |    8.07% |      98 | "71" | 137.57M | 127.79M |     0.93 | 0:24'02'' |
| Q30L60 |  83.2 |   77.7 |    6.55% |      98 | "71" | 137.57M | 126.19M |     0.92 | 0:22'28'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  87.68% |     11625 | 114.72M | 16634 |      1024 | 4.33M | 58446 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:27'31'' | 0:16'41'' |
| Q0L0X40P001    |   40.0 |  87.64% |     11610 | 114.68M | 16555 |      1025 | 4.31M | 57820 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:27'30'' | 0:16'43'' |
| Q0L0X80P000    |   80.0 |  85.73% |      8304 | 113.28M | 20910 |      1025 | 4.09M | 53826 |   78.0 | 5.0 |  20.0 | 139.5 | "31,41,51,61,71,81" | 0:43'20'' | 0:14'12'' |
| Q0L0XallP000   |   88.1 |  85.46% |      7886 | 113.22M | 21729 |      1028 | 3.73M | 54450 |   86.0 | 6.0 |  20.0 | 156.0 | "31,41,51,61,71,81" | 0:46'22'' | 0:13'53'' |
| Q25L60X40P000  |   40.0 |  88.05% |     12861 |  114.7M | 15794 |      1036 |  4.3M | 55986 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:27'24'' | 0:16'52'' |
| Q25L60X40P001  |   40.0 |  88.03% |     12720 | 114.69M | 15774 |      1035 | 4.29M | 56125 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:27'29'' | 0:17'00'' |
| Q25L60X80P000  |   80.0 |  86.55% |      9501 | 113.75M | 19061 |      1037 | 4.09M | 51907 |   78.0 | 6.0 |  20.0 | 144.0 | "31,41,51,61,71,81" | 0:43'07'' | 0:14'45'' |
| Q25L60XallP000 |   84.4 |  86.42% |      9210 |  113.8M | 19487 |      1037 | 3.85M | 52149 |   82.0 | 6.0 |  20.0 | 150.0 | "31,41,51,61,71,81" | 0:44'53'' | 0:14'36'' |
| Q30L60X40P000  |   40.0 |  88.02% |     14062 | 114.03M | 14919 |      1061 | 4.48M | 51456 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:27'09'' | 0:16'36'' |
| Q30L60XallP000 |   77.7 |  87.73% |     12228 | 114.08M | 16030 |      1059 | 4.25M | 48637 |   76.0 | 6.0 |  19.3 | 141.0 | "31,41,51,61,71,81" | 0:41'53'' | 0:16'34'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  87.99% |     19345 | 114.59M | 12055 |      1041 | 3.62M | 43400 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:14'18'' | 0:16'14'' |
| Q0L0X40P001    |   40.0 |  87.94% |     19263 | 114.54M | 12036 |      1043 | 3.63M | 43060 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:14'24'' | 0:16'03'' |
| Q0L0X80P000    |   80.0 |  87.90% |     17523 | 115.34M | 12386 |      1065 | 3.47M | 40513 |   78.0 | 6.0 |  20.0 | 144.0 | "31,41,51,61,71,81" | 0:18'52'' | 0:16'48'' |
| Q0L0XallP000   |   88.1 |  87.70% |     16886 | 115.49M | 12672 |      1085 | 3.21M | 40157 |   85.0 | 7.0 |  20.0 | 159.0 | "31,41,51,61,71,81" | 0:19'36'' | 0:16'32'' |
| Q25L60X40P000  |   40.0 |  87.97% |     18963 | 114.19M | 12426 |      1055 | 3.63M | 42904 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:14'15'' | 0:15'54'' |
| Q25L60X40P001  |   40.0 |  88.02% |     18679 |  114.3M | 12475 |      1051 | 3.65M | 42983 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:14'22'' | 0:16'11'' |
| Q25L60X80P000  |   80.0 |  88.29% |     17921 | 115.25M | 12435 |      1063 | 3.45M | 41466 |   78.0 | 6.0 |  20.0 | 144.0 | "31,41,51,61,71,81" | 0:18'59'' | 0:17'16'' |
| Q25L60XallP000 |   84.4 |  88.25% |     17558 | 115.38M | 12555 |      1073 | 3.29M | 41554 |   82.0 | 6.0 |  20.0 | 150.0 | "31,41,51,61,71,81" | 0:19'30'' | 0:17'11'' |
| Q30L60X40P000  |   40.0 |  87.62% |     16030 | 113.17M | 14031 |      1054 | 3.97M | 45152 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:13'37'' | 0:15'33'' |
| Q30L60XallP000 |   77.7 |  88.33% |     16803 | 114.51M | 13214 |      1068 | 3.82M | 44248 |   76.0 | 6.0 |  19.3 | 141.0 | "31,41,51,61,71,81" | 0:18'35'' | 0:17'13'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|--------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  88.08% |      9137 |  113.1M | 19114 |      1036 | 3.52M | 41983 |   41.0 | 3.0 |  10.7 |  75.0 | "31,41,51,61,71,81" | 0:31'53'' | 0:11'02'' |
| MRX40P001  |   40.0 |  88.11% |      9114 | 113.13M | 19029 |      1040 | 3.52M | 41763 |   41.0 | 3.0 |  10.7 |  75.0 | "31,41,51,61,71,81" | 0:31'57'' | 0:10'56'' |
| MRX80P000  |   80.0 |  85.99% |      5922 | 110.56M | 25895 |      1016 | 3.71M | 54484 |   83.0 | 5.0 |  20.0 | 147.0 | "31,41,51,61,71,81" | 0:51'51'' | 0:11'30'' |
| MRXallP000 |  111.6 |  84.75% |      5055 | 109.55M | 29025 |      1023 | 3.18M | 60311 |  115.0 | 6.0 |  20.0 | 199.5 | "31,41,51,61,71,81" | 1:08'18'' | 0:11'50'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|--------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  90.02% |     24938 | 115.04M |  9870 |      1592 | 2.59M | 26469 |   41.0 | 4.0 |   9.7 |  79.5 | "31,41,51,61,71,81" | 0:16'39'' | 0:12'53'' |
| MRX40P001  |   40.0 |  90.08% |     24628 | 115.09M |  9877 |      1831 | 2.56M | 26654 |   41.0 | 4.0 |   9.7 |  79.5 | "31,41,51,61,71,81" | 0:16'12'' | 0:12'59'' |
| MRX80P000  |   80.0 |  89.21% |     15139 | 114.71M | 13355 |      2198 | 2.78M | 31098 |   83.0 | 6.0 |  20.0 | 151.5 | "31,41,51,61,71,81" | 0:21'06'' | 0:12'31'' |
| MRXallP000 |  111.6 |  88.69% |     11006 | 114.51M | 16909 |      3477 | 2.43M | 38402 |  116.0 | 7.0 |  20.0 | 205.5 | "31,41,51,61,71,81" | 0:24'01'' | 0:13'03'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|--------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |  75.70% |     26970 | 112.06M | 13600 |      1105 | 19.75M | 15973 |   33.0 | 8.0 |   3.0 |  66.0 | 0:13'55'' |
| 7_mergeKunitigsAnchors   |  81.75% |     24160 | 112.82M | 13116 |      1144 | 10.41M |  7989 |   37.0 | 3.0 |   9.3 |  69.0 | 0:25'26'' |
| 7_mergeMRKunitigsAnchors |  78.52% |      6586 |  107.7M | 24235 |      1198 | 11.85M |  9508 |   38.0 | 2.0 |  10.7 |  66.0 | 0:18'13'' |
| 7_mergeMRTadpoleAnchors  |  78.68% |     30590 | 112.17M | 11736 |      1380 |  5.25M |  3666 |   37.0 | 3.0 |   9.3 |  69.0 | 0:17'43'' |
| 7_mergeTadpoleAnchors    |  81.55% |     29060 | 112.71M | 11979 |      1165 |  9.08M |  6726 |   37.0 | 3.0 |   9.3 |  69.0 | 0:23'42'' |


Table: statCanu

| Name                |      N50 |       Sum |      # |
|:--------------------|---------:|----------:|-------:|
| Genome              | 25286936 | 137567477 |      8 |
| Paralogs            |     4031 |  13665900 |   4492 |
| Xall.trim.corrected |    13405 |     4.25G | 433377 |
| Xall.trim.contig    | 18542648 | 151436172 |    598 |


Table: statFinal

| Name                   |      N50 |       Sum |      # |
|:-----------------------|---------:|----------:|-------:|
| Genome                 | 25286936 | 137567477 |      8 |
| Paralogs               |     4031 |  13665900 |   4492 |
| 7_mergeAnchors.anchors |    26970 | 112063356 |  13600 |
| 7_mergeAnchors.others  |     1105 |  19747792 |  15973 |
| anchorLong             |    29039 | 110377691 |  13084 |
| anchorFill             |   163580 | 113860175 |   3032 |
| canu_Xall-trim         | 18542648 | 151436172 |    598 |
| spades.contig          |   124735 | 134478911 | 108828 |
| spades.scaffold        |   136881 | 134485053 | 108584 |
| spades.non-contained   |   140666 | 121329779 |   3686 |
| spades.anchor          |   146369 | 118487157 |   3336 |
| megahit.contig         |    63413 | 124673460 |  21050 |
| megahit.non-contained  |    68226 | 119001971 |   5731 |
| megahit.anchor         |    70266 | 115768290 |   6367 |
| platanus.contig        |    14007 | 153949534 | 383933 |
| platanus.scaffold      |   146421 | 127520755 |  67301 |
| platanus.non-contained |   161171 | 118868321 |   3126 |
| platanus.anchor        |   138366 | 115019300 |   6917 |


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

# rsync -avP wangq@202.119.37.251:data/anchr/n2/ ~/data/anchr/n2

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
    --trim2 "--dedupe" \
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

Table: statInsertSize

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 253.8 |    206 | 1044.6 |                         41.49% |
| tadpole.bbtools | 209.7 |    202 |   71.1 |                         41.58% |
| genome.picard   | 214.1 |    207 |   68.3 |                             FR |
| tadpole.picard  | 210.8 |    203 |   68.7 |                             FR |


Table: statReads

| Name      |      N50 |       Sum |         # |
|:----------|---------:|----------:|----------:|
| Genome    | 17493829 | 100286401 |         7 |
| Paralogs  |     2013 |   5313653 |      2637 |
| Illumina  |      100 |    11.56G | 115608926 |
| trim      |      100 |     6.04G |  63084445 |
| Q25L60    |      100 |     5.82G |  60775343 |
| Q30L60    |      100 |      5.5G |  57815410 |
| PacBio    |    16572 |     8.12G |    740776 |
| Xall.raw  |    16572 |     8.12G |    740776 |
| Xall.trim |    16237 |     7.68G |    674732 |


Table: statTrimReads

| Name     | N50 |   Sum |        # |
|:---------|----:|------:|---------:|
| clumpify | 100 | 9.71G | 97093177 |
| trim     | 100 | 6.04G | 63084574 |
| filter   | 100 | 6.04G | 63084445 |
| R1       | 100 | 1.38G | 14763307 |
| R2       | 100 | 1.38G | 14763307 |
| Rs       | 100 | 3.28G | 33557831 |


```text
#trim
#Matched	942414	0.97063%
#Name	Reads	ReadsPct
TruSeq_Adapter_Index_1_6	390233	0.40192%
Reverse_adapter	222243	0.22890%
Nextera_LMP_Read2_External_Adapter	140466	0.14467%
pcr_dimer	81351	0.08379%
PCR_Primers	37626	0.03875%
PhiX_read2_adapter	23532	0.02424%
TruSeq_Universal_Adapter	19639	0.02023%
PhiX_read1_adapter	5106	0.00526%
I5_Nextera_Transposase_1	3359	0.00346%
RNA_Adapter_(RA5)_part_#_15013205	3151	0.00325%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	2718	0.00280%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	1529	0.00157%
Nextera_LMP_Read1_External_Adapter	1408	0.00145%
I5_Adapter_Nextera	1381	0.00142%
I7_Nextera_Transposase_2	1102	0.00113%
Bisulfite_R1	1089	0.00112%
```

```text
#filter
#Matched	129	0.00020%
#Name	Reads	ReadsPct
contam_43	104	0.00016%
```


Table: statMergeReads

| Name          | N50 |     Sum |        # |
|:--------------|----:|--------:|---------:|
| clumped       | 100 |    5.7G | 59572056 |
| ecco          | 100 |   5.69G | 59572056 |
| ecct          | 100 |   5.57G | 58292962 |
| extended      | 140 |   7.64G | 58292962 |
| merged        | 139 | 173.52M |  1375744 |
| unmerged.raw  | 140 |    7.3G | 55541474 |
| unmerged.trim | 140 |    7.3G | 55473277 |
| U1            | 140 |   1.42G | 11228662 |
| U2            | 140 |   1.42G | 11228662 |
| Us            | 140 |   4.46G | 33015953 |
| pe.cor        | 140 |   7.51G | 91240718 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt |  92.4 |     98 |  15.7 |          4.54% |
| ihist.merge.txt  | 126.1 |    137 |  34.2 |          4.72% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer |   RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|--------:|-------:|---------:|----------:|
| Q0L0   |  60.6 |   57.0 |    5.92% |      94 | "71" | 100.29M |  98.8M |     0.99 | 0:12'19'' |
| Q25L60 |  58.4 |   55.6 |    4.88% |      94 | "71" | 100.29M | 98.62M |     0.98 | 0:11'58'' |
| Q30L60 |  55.1 |   52.8 |    4.22% |      94 | "71" | 100.29M | 98.47M |     0.98 | 0:11'08'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  93.55% |     11820 | 87.07M | 13976 |      2539 | 9.24M | 57722 |   32.0 | 3.0 |   7.7 |  61.5 | "31,41,51,61,71,81" | 0:27'02'' | 0:20'00'' |
| Q0L0X50P000    |   50.0 |  93.70% |     12157 | 87.26M | 13468 |      2484 | 9.36M | 52385 |   40.0 | 4.0 |   9.3 |  78.0 | "31,41,51,61,71,81" | 0:31'00'' | 0:19'50'' |
| Q0L0XallP000   |   57.0 |  93.64% |     12086 | 87.82M | 13443 |      3301 | 8.59M | 48662 |   45.0 | 5.0 |  10.0 |  90.0 | "31,41,51,61,71,81" | 0:33'37'' | 0:19'26'' |
| Q25L60X40P000  |   40.0 |  93.75% |     12370 | 87.18M | 13642 |      2900 | 9.14M | 56869 |   32.0 | 3.0 |   7.7 |  61.5 | "31,41,51,61,71,81" | 0:26'55'' | 0:20'09'' |
| Q25L60X50P000  |   50.0 |  93.90% |     12758 |  87.3M | 13155 |      2900 |  9.3M | 51712 |   40.0 | 4.0 |   9.3 |  78.0 | "31,41,51,61,71,81" | 0:30'55'' | 0:20'10'' |
| Q25L60XallP000 |   55.6 |  93.87% |     12758 | 87.78M | 13103 |      3953 | 8.63M | 48818 |   44.0 | 5.0 |   9.7 |  88.0 | "31,41,51,61,71,81" | 0:32'50'' | 0:19'54'' |
| Q30L60X40P000  |   40.0 |  93.92% |     12677 | 87.49M | 13647 |      7002 | 8.49M | 57007 |   32.0 | 4.0 |   6.7 |  64.0 | "31,41,51,61,71,81" | 0:26'47'' | 0:20'27'' |
| Q30L60X50P000  |   50.0 |  94.10% |     13093 | 87.69M | 13086 |      5206 | 8.66M | 52602 |   40.0 | 5.0 |   8.3 |  80.0 | "31,41,51,61,71,81" | 0:30'47'' | 0:20'41'' |
| Q30L60XallP000 |   52.8 |  94.12% |     13154 | 87.89M | 12978 |      6596 | 8.39M | 51157 |   42.0 | 5.0 |   9.0 |  84.0 | "31,41,51,61,71,81" | 0:31'57'' | 0:19'56'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  93.26% |     12495 | 86.02M | 14016 |      6985 | 8.35M | 57074 |   32.0 | 3.0 |   7.7 |  61.5 | "31,41,51,61,71,81" | 0:15'29'' | 0:20'06'' |
| Q0L0X50P000    |   50.0 |  93.60% |     13358 | 86.93M | 13419 |      4418 | 8.72M | 55368 |   40.0 | 4.0 |   9.3 |  78.0 | "31,41,51,61,71,81" | 0:17'54'' | 0:20'17'' |
| Q0L0XallP000   |   57.0 |  93.80% |     13711 | 87.79M | 13082 |      6483 | 8.25M | 54418 |   45.0 | 5.0 |  10.0 |  90.0 | "31,41,51,61,71,81" | 0:20'05'' | 0:21'02'' |
| Q25L60X40P000  |   40.0 |  93.28% |     12469 | 85.94M | 13994 |      7309 | 8.33M | 56771 |   32.0 | 3.0 |   7.7 |  61.5 | "31,41,51,61,71,81" | 0:15'30'' | 0:20'06'' |
| Q25L60X50P000  |   50.0 |  93.65% |     13241 | 86.87M | 13388 |      4320 | 8.73M | 55224 |   40.0 | 4.0 |   9.3 |  78.0 | "31,41,51,61,71,81" | 0:17'34'' | 0:20'21'' |
| Q25L60XallP000 |   55.6 |  93.83% |     13676 | 87.58M | 13151 |      6777 | 8.28M | 54566 |   44.0 | 5.0 |   9.7 |  88.0 | "31,41,51,61,71,81" | 0:19'24'' | 0:21'10'' |
| Q30L60X40P000  |   40.0 |  93.31% |     12123 | 86.22M | 14368 |     10996 | 7.66M | 57968 |   32.0 | 4.0 |   6.7 |  64.0 | "31,41,51,61,71,81" | 0:15'08'' | 0:20'13'' |
| Q30L60X50P000  |   50.0 |  93.72% |     12853 | 87.01M | 13655 |      8360 | 8.08M | 56141 |   40.0 | 5.0 |   8.3 |  80.0 | "31,41,51,61,71,81" | 0:17'22'' | 0:20'35'' |
| Q30L60XallP000 |   52.8 |  93.81% |     13152 |    87M | 13421 |      6643 | 8.49M | 55695 |   43.0 | 5.0 |   9.3 |  86.0 | "31,41,51,61,71,81" | 0:17'18'' | 0:19'50'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  91.85% |      9439 | 85.94M | 15529 |      3906 | 6.91M | 38767 |   33.0 | 4.0 |   7.0 |  66.0 | "31,41,51,61,71,81" | 0:31'38'' | 0:12'10'' |
| MRX50P000  |   50.0 |  91.55% |      8710 | 85.72M | 16177 |      3345 | 6.99M | 39633 |   41.0 | 5.0 |   8.7 |  82.0 | "31,41,51,61,71,81" | 0:35'49'' | 0:12'19'' |
| MRX60P000  |   60.0 |  91.29% |      8129 | 85.47M | 16772 |      3067 | 7.11M | 40745 |   49.0 | 6.0 |  10.3 |  98.0 | "31,41,51,61,71,81" | 0:39'46'' | 0:12'26'' |
| MRXallP000 |   74.8 |  90.96% |      7570 | 85.14M | 17486 |      2753 | 7.18M | 41983 |   62.0 | 7.0 |  13.7 | 124.0 | "31,41,51,61,71,81" | 0:45'50'' | 0:12'28'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  92.86% |     12988 | 86.29M | 13172 |     10280 | 6.99M | 36789 |   32.0 | 4.0 |   6.7 |  64.0 | "31,41,51,61,71,81" | 0:19'11'' | 0:15'05'' |
| MRX50P000  |   50.0 |  92.79% |     12861 | 86.43M | 13148 |      8911 | 7.15M | 35302 |   40.0 | 5.0 |   8.3 |  80.0 | "31,41,51,61,71,81" | 0:20'02'' | 0:14'23'' |
| MRX60P000  |   60.0 |  92.76% |     12623 | 86.74M | 13348 |      8791 | 7.06M | 35243 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:21'13'' | 0:13'51'' |
| MRXallP000 |   74.8 |  92.70% |     12142 | 86.81M | 13603 |      8643 | 6.88M | 35790 |   60.0 | 8.0 |  12.0 | 120.0 | "31,41,51,61,71,81" | 0:23'00'' | 0:14'07'' |


Table: statCanu

| Name                |      N50 |       Sum |      # |
|:--------------------|---------:|----------:|-------:|
| Genome              | 17493829 | 100286401 |      7 |
| Paralogs            |     2013 |   5313653 |   2637 |
| Xall.trim.corrected |    18340 |     3.86G | 207189 |
| Xall.trim.contig    |  2859614 | 107313895 |    109 |


Table: statFinal

| Name                             |      N50 |       Sum |      # |
|:---------------------------------|---------:|----------:|-------:|
| Genome                           | 17493829 | 100286401 |      7 |
| Paralogs                         |     2013 |   5313653 |   2637 |
| 7_mergeKunitigsAnchors.anchors   |    15155 |  89095788 |  12035 |
| 7_mergeKunitigsAnchors.others    |     2217 |  11016950 |   5286 |
| 7_mergeTadpoleAnchors.anchors    |    14751 |  88701412 |  12731 |
| 7_mergeTadpoleAnchors.others     |     2092 |  10319785 |   5023 |
| 7_mergeMRKunitigsAnchors.anchors |     9553 |  86601432 |  15504 |
| 7_mergeMRKunitigsAnchors.others  |     4091 |   6762941 |   2776 |
| 7_mergeMRTadpoleAnchors.anchors  |    13286 |  87290762 |  13044 |
| 7_mergeMRTadpoleAnchors.others   |    11456 |   6797806 |   2043 |
| 7_mergeAnchors.anchors           |    16442 |  90535601 |  11517 |
| 7_mergeAnchors.others            |     1801 |  15084788 |   7863 |
| anchorLong                       |    19820 |  89650829 |   9613 |
| anchorFill                       |   300454 |  95061676 |    683 |
| canu_Xall-trim                   |  2859614 | 107313895 |    109 |
| spades.contig                    |    29419 | 105692915 |  61550 |
| spades.scaffold                  |    30462 | 105699937 |  61290 |
| spades.non-contained             |    32671 |  97789620 |   7110 |
| spades.anchor                    |     2913 |  73716159 |  29415 |
| megahit.contig                   |    17377 | 100094511 |  21375 |
| megahit.non-contained            |    18653 |  95498095 |  10974 |
| megahit.anchor                   |     2286 |  64192331 |  30618 |
| platanus.contig                  |     6431 | 107526295 | 219426 |
| platanus.scaffold                |    17311 |  97679256 |  44346 |
| platanus.non-contained           |    19513 |  90328733 |  10413 |
| platanus.anchor                  |     2589 |  66294387 |  28802 |


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

# rsync -avP wangq@202.119.37.251:data/anchr/col_0/ ~/data/anchr/col_0

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
    --trim2 "--dedupe" \
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

Table: statInsertSize

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 419.7 |    340 | 1245.4 |                         48.78% |
| tadpole.bbtools | 340.6 |    324 |  115.1 |                         39.56% |
| genome.picard   | 396.4 |    377 |  110.0 |                             FR |
| genome.picard   | 255.3 |    268 |   52.6 |                             RF |
| tadpole.picard  | 378.7 |    363 |  109.1 |                             FR |
| tadpole.picard  | 245.0 |    255 |   51.5 |                             RF |


Table: statReads

| Name      |      N50 |       Sum |        # |
|:----------|---------:|----------:|---------:|
| Genome    | 23459830 | 119667750 |        7 |
| Paralogs  |     2007 |  16447809 |     8055 |
| Illumina  |      301 |    15.53G | 53786130 |
| trim      |      276 |    13.42G | 52880584 |
| Q25L60    |      265 |    12.14G | 50605347 |
| Q30L60    |      241 |    10.28G | 47349573 |
| PacBio    |     6754 |    18.77G |  5721958 |
| Xall.raw  |     6754 |    18.77G |  5721958 |
| Xall.trim |     7329 |     7.72G |  1353993 |


Table: statTrimReads

| Name     | N50 |    Sum |        # |
|:---------|----:|-------:|---------:|
| clumpify | 301 | 15.53G | 53779068 |
| trim     | 276 | 13.42G | 52881050 |
| filter   | 276 | 13.42G | 52880584 |
| R1       | 292 |  7.17G | 26440292 |
| R2       | 254 |  6.24G | 26440292 |
| Rs       |   0 |      0 |        0 |


```text
#trim
#Matched	1037665	1.92950%
#Name	Reads	ReadsPct
Reverse_adapter	430782	0.80102%
TruSeq_Universal_Adapter	286644	0.53300%
pcr_dimer	92485	0.17197%
Nextera_LMP_Read2_External_Adapter	60004	0.11158%
PCR_Primers	53353	0.09921%
TruSeq_Adapter_Index_1_6	44956	0.08359%
PhiX_read2_adapter	14144	0.02630%
Bisulfite_R2	6805	0.01265%
Bisulfite_R1	5581	0.01038%
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

```text
#filter
#Matched	260	0.00049%
#Name	Reads	ReadsPct
```


Table: statMergeReads

| Name          | N50 |     Sum |        # |
|:--------------|----:|--------:|---------:|
| clumped       | 276 |  13.42G | 52878950 |
| ecco          | 276 |  13.42G | 52878950 |
| ecct          | 280 |  10.96G | 42180046 |
| extended      | 319 |   12.6G | 42180046 |
| merged        | 412 |   8.03G | 20185361 |
| unmerged.raw  | 289 | 440.26M |  1809324 |
| unmerged.trim | 289 | 440.25M |  1809196 |
| U1            | 312 | 261.38M |   904598 |
| U2            | 235 | 178.87M |   904598 |
| Us            |   0 |       0 |        0 |
| pe.cor        | 405 |   8.49G | 42179918 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 336.0 |    334 |  86.3 |         64.84% |
| ihist.merge.txt  | 397.7 |    387 | 104.7 |         95.71% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|--------:|--------:|---------:|----------:|
| Q0L0   | 112.1 |   68.8 |   38.63% |     255 | "127" | 119.67M | 131.66M |     1.10 | 0:20'18'' |
| Q25L60 | 101.5 |   73.6 |   27.48% |     244 | "127" | 119.67M | 126.05M |     1.05 | 0:18'22'' |
| Q30L60 |  85.9 |   73.6 |   14.39% |     225 | "127" | 119.67M |  118.9M |     0.99 | 0:16'54'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  65.76% |     11095 | 102.08M | 16378 |       842 | 6.61M | 38916 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:36'23'' | 0:11'11'' |
| Q0L0X50P000    |   50.0 |  65.58% |     10137 | 103.38M | 16781 |       316 | 4.86M | 42299 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:42'34'' | 0:11'29'' |
| Q0L0X60P000    |   60.0 |  65.48% |      8869 | 102.12M | 18449 |       607 | 6.44M | 48599 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:48'36'' | 0:12'19'' |
| Q0L0XallP000   |   68.8 |  65.43% |      8298 | 102.44M | 19146 |       178 | 5.98M | 53630 |   45.0 | 4.0 |  11.0 |  85.5 | "31,41,51,61,71,81" | 0:53'57'' | 0:13'11'' |
| Q25L60X40P000  |   40.0 |  68.70% |     15320 | 104.44M | 13014 |       747 | 4.26M | 32302 |   27.0 | 2.0 |   7.0 |  49.5 | "31,41,51,61,71,81" | 0:35'24'' | 0:11'47'' |
| Q25L60X50P000  |   50.0 |  68.47% |     14174 | 105.02M | 13231 |       135 | 3.48M | 33306 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:41'19'' | 0:11'46'' |
| Q25L60X60P000  |   60.0 |  68.34% |     13145 | 104.69M | 13964 |       139 | 3.83M | 35549 |   41.0 | 3.0 |  10.7 |  75.0 | "31,41,51,61,71,81" | 0:47'23'' | 0:12'04'' |
| Q25L60XallP000 |   73.6 |  68.26% |     11994 | 104.65M | 14838 |       111 | 3.92M | 38838 |   50.0 | 4.0 |  12.7 |  93.0 | "31,41,51,61,71,81" | 0:55'12'' | 0:12'47'' |
| Q30L60X40P000  |   40.0 |  73.78% |     20511 | 105.57M | 10623 |       740 | 3.61M | 29448 |   29.0 | 2.0 |   7.7 |  52.5 | "31,41,51,61,71,81" | 0:34'43'' | 0:12'43'' |
| Q30L60X50P000  |   50.0 |  73.56% |     19777 | 106.18M | 10601 |       410 | 2.81M | 28985 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:40'28'' | 0:12'53'' |
| Q30L60X60P000  |   60.0 |  73.44% |     19225 | 105.89M | 10768 |       474 | 3.17M | 29215 |   44.0 | 3.0 |  11.7 |  79.5 | "31,41,51,61,71,81" | 0:46'13'' | 0:13'05'' |
| Q30L60XallP000 |   73.6 |  73.24% |     18410 | 105.68M | 11097 |       690 | 3.42M | 29662 |   54.0 | 3.0 |  15.0 |  94.5 | "31,41,51,61,71,81" | 0:53'56'' | 0:12'57'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  77.52% |     16578 | 103.88M | 12660 |       960 | 5.84M | 32387 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:17'41'' | 0:11'59'' |
| Q0L0X50P000    |   50.0 |  77.38% |     17371 | 105.45M | 11470 |       692 | 3.79M | 29770 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:18'42'' | 0:11'41'' |
| Q0L0X60P000    |   60.0 |  77.24% |     16903 | 104.82M | 11806 |       804 | 4.48M | 29303 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:20'23'' | 0:11'45'' |
| Q0L0XallP000   |   68.8 |  77.06% |     16444 | 105.37M | 11768 |       608 |  3.8M | 28817 |   46.0 | 4.0 |  11.3 |  87.0 | "31,41,51,61,71,81" | 0:21'52'' | 0:11'36'' |
| Q25L60X40P000  |   40.0 |  80.49% |     20478 | 105.32M | 10792 |       909 | 4.25M | 30016 |   27.0 | 2.0 |   7.0 |  49.5 | "31,41,51,61,71,81" | 0:16'09'' | 0:12'40'' |
| Q25L60X50P000  |   50.0 |  80.31% |     20942 | 106.02M | 10175 |       547 | 3.22M | 27725 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:18'11'' | 0:12'23'' |
| Q25L60X60P000  |   60.0 |  80.16% |     20331 | 105.89M | 10361 |       769 | 3.34M | 26966 |   41.0 | 3.0 |  10.7 |  75.0 | "31,41,51,61,71,81" | 0:19'48'' | 0:12'16'' |
| Q25L60XallP000 |   73.6 |  79.93% |     18877 | 106.04M | 10786 |       674 |  3.1M | 26714 |   51.0 | 4.0 |  13.0 |  94.5 | "31,41,51,61,71,81" | 0:21'48'' | 0:12'01'' |
| Q30L60X40P000  |   40.0 |  84.71% |     21140 | 105.81M | 10412 |       853 | 3.88M | 31251 |   29.0 | 2.0 |   7.7 |  52.5 | "31,41,51,61,71,81" | 0:16'04'' | 0:13'19'' |
| Q30L60X50P000  |   50.0 |  84.59% |     22115 | 106.52M |  9877 |       695 | 2.87M | 28896 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:17'28'' | 0:13'20'' |
| Q30L60X60P000  |   60.0 |  84.53% |     22220 |  106.3M |  9780 |       787 | 3.14M | 27814 |   44.0 | 3.0 |  11.7 |  79.5 | "31,41,51,61,71,81" | 0:19'01'' | 0:13'09'' |
| Q30L60XallP000 |   73.6 |  84.42% |     22536 |  106.5M |  9692 |       869 | 2.83M | 26617 |   54.0 | 4.0 |  14.0 |  99.0 | "31,41,51,61,71,81" | 0:20'36'' | 0:13'15'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|--------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  76.78% |     23758 |  105.1M |  9037 |       169 | 2.89M | 20361 |   31.0 | 3.0 |   7.3 |  60.0 | "31,41,51,61,71,81" | 0:40'30'' | 0:10'21'' |
| MRX50P000  |   50.0 |  76.62% |     22312 | 105.24M |  9460 |       154 | 2.73M | 21181 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:47'57'' | 0:10'24'' |
| MRX60P000  |   60.0 |  76.47% |     20853 | 104.86M |  9787 |       154 | 3.11M | 21894 |   46.0 | 4.0 |  11.3 |  87.0 | "31,41,51,61,71,81" | 0:54'56'' | 0:10'33'' |
| MRXallP000 |   70.9 |  76.33% |     19615 | 104.77M | 10162 |       144 | 3.15M | 22687 |   55.0 | 5.0 |  13.3 | 105.0 | "31,41,51,61,71,81" | 1:02'55'' | 0:10'53'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |     Sum |    # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|--------:|-----:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  89.55% |     28122 | 105.63M | 8226 |      1007 | 2.51M | 17811 |   30.0 | 3.0 |   7.0 |  58.5 | "31,41,51,61,71,81" | 0:17'10'' | 0:09'56'' |
| MRX50P000  |   50.0 |  89.53% |     27831 | 105.72M | 8243 |      1018 | 2.69M | 17901 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:18'56'' | 0:10'07'' |
| MRX60P000  |   60.0 |  89.51% |     27499 | 105.59M | 8279 |      1010 | 2.97M | 17999 |   46.0 | 4.0 |  11.3 |  87.0 | "31,41,51,61,71,81" | 0:20'28'' | 0:10'25'' |
| MRXallP000 |   70.9 |  89.50% |     26610 | 105.52M | 8399 |      1019 | 2.81M | 18199 |   54.0 | 5.0 |  13.0 | 103.5 | "31,41,51,61,71,81" | 0:21'58'' | 0:10'31'' |


Table: statCanu

| Name                |      N50 |       Sum |      # |
|:--------------------|---------:|----------:|-------:|
| Genome              | 23459830 | 119667750 |      7 |
| Paralogs            |     2007 |  16447809 |   8055 |
| Xall.trim.corrected |     7477 |     4.46G | 661124 |
| Xall.trim.contig    |  5997654 | 121555181 |    265 |


Table: statFinal

| Name                             |      N50 |       Sum |      # |
|:---------------------------------|---------:|----------:|-------:|
| Genome                           | 23459830 | 119667750 |      7 |
| Paralogs                         |     2007 |  16447809 |   8055 |
| 7_mergeKunitigsAnchors.anchors   |    24442 | 107065766 |   9451 |
| 7_mergeKunitigsAnchors.others    |     1141 |   7961334 |   6906 |
| 7_mergeTadpoleAnchors.anchors    |    25855 | 107169163 |   8975 |
| 7_mergeTadpoleAnchors.others     |     1176 |   5756546 |   4775 |
| 7_mergeMRKunitigsAnchors.anchors |    23775 | 105491537 |   9094 |
| 7_mergeMRKunitigsAnchors.others  |     1166 |   1590483 |   1173 |
| 7_mergeMRTadpoleAnchors.anchors  |    28419 | 106281767 |   8212 |
| 7_mergeMRTadpoleAnchors.others   |     1421 |   1846548 |   1032 |
| 7_mergeAnchors.anchors           |    30553 | 107766589 |   8104 |
| 7_mergeAnchors.others            |     1164 |   9763937 |   8002 |
| anchorLong                       |    31555 | 107593278 |   7797 |
| anchorFill                       |  1267395 | 112831349 |    561 |
| canu_Xall-trim                   |  5997654 | 121555181 |    265 |
| spades.contig                    |    47488 | 169892038 | 188953 |
| spades.scaffold                  |    50461 | 169895661 | 188792 |
| spades.non-contained             |   102585 | 116321413 |   5221 |
| spades.anchor                    |     4903 |  96643876 |  26175 |
| megahit.contig                   |    26812 | 128040922 |  61899 |
| megahit.non-contained            |    33554 | 109496333 |   8663 |
| megahit.anchor                   |    34966 | 105744230 |   7715 |
| platanus.contig                  |    15712 | 140734581 | 109263 |
| platanus.scaffold                |   196232 | 128644699 |  67966 |
| platanus.non-contained           |   229600 | 116482994 |   2007 |
| platanus.anchor                  |   209087 | 115390866 |   1967 |


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

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue largemem \
    --genome 119667750 \
    --is_euk \
    --trim2 "--dedupe" \
    --cov2 "40 50 60 all" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,3" \
    --insertsize \
    --sgapreqc \
    --parallel 24

```

## col_0H: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=col_0H

cd ${WORKING_DIR}/${BASE_NAME}

bash 0_bsub.sh
#bash 0_master.sh

#bash 0_cleanup.sh

```

Table: statInsertSize

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 643.4 |    472 | 2200.4 |                         38.56% |
| tadpole.bbtools | 451.6 |    470 |   89.3 |                         26.89% |
| genome.picard   | 467.2 |    472 |   37.0 |                             FR |
| tadpole.picard  | 452.2 |    470 |   78.7 |                             FR |


Table: statReads

| Name     |      N50 |       Sum |         # |
|:---------|---------:|----------:|----------:|
| Genome   | 23459830 | 119667750 |         7 |
| Paralogs |     2007 |  16447809 |      8055 |
| Illumina |      100 |    14.95G | 149486290 |
| trim     |      100 |    11.36G | 116251576 |
| Q25L60   |      100 |     10.4G | 106681266 |
| Q30L60   |      100 |     9.19G |  95859613 |


Table: statTrimReads

| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| clumpify | 100 |    12G | 120007867 |
| trim     | 100 | 11.36G | 116251669 |
| filter   | 100 | 11.36G | 116251576 |
| R1       | 100 |  5.06G |  51652565 |
| R2       | 100 |  5.06G |  51652565 |
| Rs       | 100 |  1.24G |  12946446 |


```text
#trim
#Matched	60136	0.05011%
#Name	Reads	ReadsPct
PhiX_read2_adapter	18176	0.01515%
Reverse_adapter	8071	0.00673%
I5_Nextera_Transposase_1	5182	0.00432%
PhiX_read1_adapter	4727	0.00394%
RNA_Adapter_(RA5)_part_#_15013205	3215	0.00268%
Nextera_LMP_Read2_External_Adapter	2930	0.00244%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	2121	0.00177%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	1698	0.00141%
I7_Nextera_Transposase_2	1521	0.00127%
Nextera_LMP_Read1_External_Adapter	1369	0.00114%
TruSeq_Universal_Adapter	1256	0.00105%
I5_Nextera_Transposase_2	1189	0.00099%
I5_Adapter_Nextera	1160	0.00097%
TruSeq_Adapter_Index_1_6	1033	0.00086%
```

```text
#filter
#Matched	93	0.00008%
#Name	Reads	ReadsPct
```


Table: statMergeReads

| Name          | N50 |     Sum |         # |
|:--------------|----:|--------:|----------:|
| clumped       | 100 |   10.5G | 107553677 |
| ecco          | 100 |  10.47G | 107553676 |
| ecct          | 100 |   8.32G |  85214703 |
| extended      | 140 |  11.45G |  85214703 |
| merged        | 139 | 284.19M |   2160313 |
| unmerged.raw  | 140 |   10.9G |  80894076 |
| unmerged.trim | 140 |   10.9G |  80838354 |
| U1            | 140 |   4.15G |  30437422 |
| U2            | 140 |   4.15G |  30437422 |
| Us            | 140 |    2.6G |  19963510 |
| pe.cor        | 140 |   11.2G | 105122490 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt |  97.8 |     99 |  17.4 |          5.19% |
| ihist.merge.txt  | 131.6 |    138 |  27.3 |          5.07% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|--------:|--------:|---------:|----------:|
| Q0L0   |  95.1 |   74.4 |   21.77% |      97 | "71" | 119.67M |  300.4M |     2.51 | 0:22'23'' |
| Q25L60 |  87.0 |   69.5 |   20.11% |      98 | "71" | 119.67M | 278.09M |     2.32 | 0:21'03'' |
| Q30L60 |  76.9 |   62.4 |   18.91% |      97 | "71" | 119.67M | 245.26M |     2.05 | 0:18'39'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |     # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|-------:|------:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  75.68% |     11612 | 106.31M | 16143 |      1245 | 10.19M | 64782 |   30.0 |  2.0 |   8.0 |  54.0 | "31,41,51,61,71,81" | 0:32'25'' | 0:17'22'' |
| Q0L0X50P000    |   50.0 |  76.41% |     11918 |  106.7M | 15601 |      1394 |  17.5M | 67132 |   37.0 |  3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:38'03'' | 0:18'43'' |
| Q0L0X60P000    |   60.0 |  76.88% |     11991 | 107.77M | 15749 |      1467 | 26.57M | 69440 |   44.0 |  5.0 |   9.7 |  88.0 | "31,41,51,61,71,81" | 0:43'19'' | 0:19'10'' |
| Q0L0XallP000   |   74.4 |  76.85% |      8310 | 143.14M | 35090 |      1021 |  5.31M | 88261 |   53.0 | 36.0 |   3.0 | 106.0 | "31,41,51,61,71,81" | 0:50'52'' | 0:20'22'' |
| Q25L60X40P000  |   40.0 |  76.89% |     12138 | 106.14M | 15762 |      1216 |     9M | 62018 |   30.0 |  2.0 |   8.0 |  54.0 | "31,41,51,61,71,81" | 0:31'58'' | 0:17'08'' |
| Q25L60X50P000  |   50.0 |  77.84% |     12496 | 106.64M | 15131 |      1358 | 15.89M | 64121 |   38.0 |  3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:37'22'' | 0:18'25'' |
| Q25L60X60P000  |   60.0 |  78.42% |     12828 | 107.04M | 14870 |      1464 | 24.66M | 65858 |   45.0 |  4.0 |  11.0 |  85.5 | "31,41,51,61,71,81" | 0:42'36'' | 0:18'55'' |
| Q25L60XallP000 |   69.5 |  78.61% |     12587 | 109.32M | 15749 |      1500 | 31.54M | 68775 |   51.0 |  8.0 |   9.0 | 102.0 | "31,41,51,61,71,81" | 0:47'28'' | 0:19'09'' |
| Q30L60X40P000  |   40.0 |  77.81% |     11379 | 105.17M | 16238 |      1127 |  7.35M | 62099 |   31.0 |  2.0 |   8.3 |  55.5 | "31,41,51,61,71,81" | 0:30'40'' | 0:16'54'' |
| Q30L60X50P000  |   50.0 |  78.65% |     11959 | 106.09M | 15657 |      1293 | 11.83M | 63454 |   39.0 |  3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:36'08'' | 0:17'53'' |
| Q30L60X60P000  |   60.0 |  79.27% |     12300 | 106.34M | 15228 |      1395 | 18.34M | 64634 |   46.0 |  4.0 |  11.3 |  87.0 | "31,41,51,61,71,81" | 0:40'43'' | 0:18'40'' |
| Q30L60XallP000 |   62.4 |  79.39% |     12377 | 106.46M | 15153 |      1423 |  19.8M | 64965 |   48.0 |  4.0 |  12.0 |  90.0 | "31,41,51,61,71,81" | 0:41'57'' | 0:18'18'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  76.01% |     12045 | 104.15M | 15618 |      1033 |  4.74M | 60951 |   30.0 | 2.0 |   8.0 |  54.0 | "31,41,51,61,71,81" | 0:14'53'' | 0:17'08'' |
| Q0L0X50P000    |   50.0 |  76.54% |     12705 | 105.22M | 15210 |      1140 |  7.51M | 59408 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:17'47'' | 0:17'33'' |
| Q0L0X60P000    |   60.0 |  77.17% |     13156 | 106.42M | 14907 |      1288 | 10.48M | 61386 |   45.0 | 3.0 |  12.0 |  81.0 | "31,41,51,61,71,81" | 0:19'54'' | 0:18'49'' |
| Q0L0XallP000   |   74.4 |  78.06% |     13647 | 106.85M | 14319 |      1435 | 18.19M | 63290 |   55.0 | 4.0 |  14.3 | 100.5 | "31,41,51,61,71,81" | 0:22'42'' | 0:19'47'' |
| Q25L60X40P000  |   40.0 |  77.00% |     11503 | 103.68M | 16044 |      1031 |  4.89M | 60631 |   31.0 | 2.0 |   8.3 |  55.5 | "31,41,51,61,71,81" | 0:14'46'' | 0:16'35'' |
| Q25L60X50P000  |   50.0 |  77.64% |     12313 | 105.06M | 15517 |      1114 |  6.77M | 59220 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:17'38'' | 0:17'01'' |
| Q25L60X60P000  |   60.0 |  78.52% |     12819 | 105.96M | 15044 |      1257 |   9.8M | 61095 |   46.0 | 3.0 |  12.3 |  82.5 | "31,41,51,61,71,81" | 0:19'29'' | 0:18'23'' |
| Q25L60XallP000 |   69.5 |  79.15% |     13208 | 106.35M | 14600 |      1368 | 14.12M | 62175 |   53.0 | 3.0 |  14.7 |  93.0 | "31,41,51,61,71,81" | 0:20'35'' | 0:19'03'' |
| Q30L60X40P000  |   40.0 |  77.97% |     10085 | 103.09M | 17525 |      1011 |  4.19M | 64326 |   32.0 | 2.0 |   8.7 |  57.0 | "31,41,51,61,71,81" | 0:14'17'' | 0:16'20'' |
| Q30L60X50P000  |   50.0 |  78.72% |     10957 | 104.19M | 16735 |      1041 |  5.76M | 62371 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:16'41'' | 0:17'06'' |
| Q30L60X60P000  |   60.0 |  79.34% |     11476 | 105.28M | 16227 |      1137 |  7.41M | 62864 |   48.0 | 3.0 |  13.0 |  85.5 | "31,41,51,61,71,81" | 0:18'50'' | 0:18'06'' |
| Q30L60XallP000 |   62.4 |  79.54% |     11627 | 105.38M | 16080 |      1162 |  8.18M | 63108 |   49.0 | 3.0 |  13.3 |  87.0 | "31,41,51,61,71,81" | 0:19'25'' | 0:18'22'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|--------:|------:|----------:|-------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  82.72% |     10870 | 105.83M | 16371 |      1137 |  9.12M |  71274 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:32'40'' | 0:17'36'' |
| MRX40P001  |   40.0 |  82.72% |     10855 | 105.79M | 16318 |      1135 |  9.13M |  71525 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:32'36'' | 0:17'28'' |
| MRX50P000  |   50.0 |  82.98% |      8921 | 107.13M | 19277 |      1083 | 10.41M |  93165 |   43.0 | 3.0 |  11.3 |  78.0 | "31,41,51,61,71,81" | 0:37'08'' | 0:20'50'' |
| MRX60P000  |   60.0 |  82.74% |      6849 | 109.53M | 24095 |      1051 | 11.22M | 112088 |   51.0 | 3.0 |  14.0 |  90.0 | "31,41,51,61,71,81" | 0:41'38'' | 0:24'09'' |
| MRXallP000 |   93.6 |  80.52% |      3486 | 116.08M | 42414 |      1024 | 12.64M | 143676 |   80.0 | 5.0 |  20.0 | 142.5 | "31,41,51,61,71,81" | 0:57'37'' | 0:23'42'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|--------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  81.43% |     15464 | 105.74M | 12625 |      1213 | 5.57M | 36353 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:17'14'' | 0:12'45'' |
| MRX40P001  |   40.0 |  81.52% |     15599 | 105.82M | 12666 |      1218 | 5.61M | 36364 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:17'12'' | 0:12'40'' |
| MRX50P000  |   50.0 |  80.93% |     15518 | 106.07M | 12649 |      1304 | 6.47M | 35289 |   43.0 | 3.0 |  11.3 |  78.0 | "31,41,51,61,71,81" | 0:18'22'' | 0:12'38'' |
| MRX60P000  |   60.0 |  80.81% |     15394 | 106.27M | 12788 |      1347 | 7.17M | 35335 |   52.0 | 4.0 |  13.3 |  96.0 | "31,41,51,61,71,81" | 0:19'55'' | 0:12'48'' |
| MRXallP000 |   93.6 |  80.54% |     14309 | 106.64M | 13571 |      1336 | 7.77M | 36822 |   81.0 | 6.0 |  20.0 | 148.5 | "31,41,51,61,71,81" | 0:24'15'' | 0:13'15'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |    Sum |     # | N50Others |     Sum |     # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|-------:|------:|----------:|--------:|------:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |  40.82% |      1634 | 49.28M | 30420 |      1688 | 151.06M | 95246 |   23.0 | 1.0 |   6.7 |  39.0 | 0:09'31'' |
| 7_mergeKunitigsAnchors   |  65.96% |      2660 |  88.3M | 37760 |      1594 |  82.52M | 53029 |   22.0 | 4.0 |   3.3 |  44.0 | 0:18'07'' |
| 7_mergeMRKunitigsAnchors |  65.68% |      1941 | 65.19M | 35277 |      1744 |  59.47M | 37720 |   25.0 | 1.0 |   7.3 |  42.0 | 0:21'07'' |
| 7_mergeMRTadpoleAnchors  |  65.52% |      1955 |  65.5M | 35236 |      1897 |  50.29M | 30612 |   25.0 | 1.0 |   7.3 |  42.0 | 0:16'37'' |
| 7_mergeTadpoleAnchors    |  69.02% |      1941 |  65.5M | 35439 |      1779 |  65.95M | 40745 |   25.0 | 1.0 |   7.3 |  42.0 | 0:23'54'' |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |     Sum |     # | N50Others |     Sum |     # | median |  MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|--------:|------:|----------:|--------:|------:|-------:|-----:|------:|------:|----------:|
| 8_spades     |  64.57% |      1205 |    1.6M |  1290 |     10344 | 261.06M | 52687 |    5.0 |  2.0 |   3.0 |  10.0 | 0:17'57'' |
| 8_spades_MR  |  60.21% |      3934 | 105.51M | 33782 |      1405 |   25.9M | 45618 |   23.0 | 18.0 |   3.0 |  46.0 | 0:12'55'' |
| 8_megahit    |  60.46% |      1371 |   3.71M |  2590 |      7102 | 211.16M | 55116 |    8.0 |  5.0 |   3.0 |  16.0 | 0:15'39'' |
| 8_megahit_MR |  59.32% |      3755 | 103.66M | 34438 |      1298 |  25.17M | 49698 |   23.0 | 15.0 |   3.0 |  46.0 | 0:12'51'' |
| 8_platanus   |  59.42% |      2006 |  70.66M | 37278 |      2213 |  45.73M | 41235 |   23.0 |  1.0 |   6.7 |  39.0 | 0:11'18'' |


Table: statFinal

| Name                     |      N50 |       Sum |      # |
|:-------------------------|---------:|----------:|-------:|
| Genome                   | 23459830 | 119667750 |      7 |
| Paralogs                 |     2007 |  16447809 |   8055 |
| 7_mergeAnchors.anchors   |     1634 |  49279888 |  30420 |
| 7_mergeAnchors.others    |     1688 | 151061891 |  95246 |
| spades.contig            |     3330 | 402702980 | 506987 |
| spades.scaffold          |     5965 | 408269297 | 427104 |
| spades.non-contained     |    11171 | 262656436 |  51397 |
| spades_MR.contig         |    44171 | 139987988 |  24801 |
| spades_MR.scaffold       |    50590 | 140093038 |  23164 |
| spades_MR.non-contained  |    49203 | 131422545 |  11884 |
| megahit.contig           |     3923 | 273605329 | 196667 |
| megahit.non-contained    |     7914 | 214869043 |  52527 |
| megahit_MR.contig        |    18323 | 154731460 |  72982 |
| megahit_MR.non-contained |    25196 | 128864233 |  15789 |
| platanus.contig          |     5507 | 148383014 | 526830 |
| platanus.scaffold        |    76395 | 118655589 |  10051 |
| platanus.non-contained   |    79069 | 116392861 |   3956 |


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

## nip: template

* Rsync to hpcc

```bash
rsync -avP \
    --exclude="*_subreads.fastq.gz" \
    ~/data/anchr/nip/ \
    wangq@202.119.37.251:data/anchr/nip

# rsync -avP wangq@202.119.37.251:data/anchr/nip/ ~/data/anchr/nip

```

* template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=nip
QUEUE_NAME=largemem

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 373245519 \
    --is_euk \
    --trim2 "--dedupe" \
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

## nip: run

Same as [s288c: run](#s288c-run)

Table: statInsertSize

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 213.3 |    175 | 1209.1 |                         43.41% |
| tadpole.bbtools | 161.6 |    162 |   44.7 |                         32.19% |
| genome.picard   | 173.0 |    177 |   36.6 |                             FR |
| tadpole.picard  | 164.1 |    165 |   41.6 |                             FR |
| tadpole.picard  | 113.4 |    110 |   17.1 |                             RF |


Table: statReads

| Name      |      N50 |       Sum |         # |
|:----------|---------:|----------:|----------:|
| Genome    | 29958434 | 373245519 |        12 |
| Paralogs  |     2842 |  88451827 |     36289 |
| Illumina  |      101 |     49.5G | 490080436 |
| trim      |      100 |    42.18G | 436041412 |
| Q25L60    |      100 |    39.23G | 407293560 |
| Q30L60    |      100 |    34.71G | 365583577 |
| PacBio    |     3843 |    12.75G |   4569941 |
| Xall.raw  |     3843 |    12.75G |   4569941 |
| Xall.trim |     3731 |     9.13G |   2880183 |


Table: statTrimReads

| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| clumpify | 101 |  48.7G | 482148792 |
| trim     | 100 | 42.31G | 437362526 |
| filter   | 100 | 42.18G | 436041412 |
| R1       | 100 | 21.11G | 218020706 |
| R2       | 100 | 21.08G | 218020706 |
| Rs       |   0 |      0 |         0 |


```text
#trim
#Matched	49418746	10.24969%
#Name	Reads	ReadsPct
pcr_dimer	28297190	5.86897%
PCR_Primers	5344003	1.10837%
Nextera_LMP_Read2_External_Adapter	5003882	1.03783%
TruSeq_Adapter_Index_1_6	4635975	0.96152%
PhiX_read1_adapter	3831069	0.79458%
Reverse_adapter	1625329	0.33710%
TruSeq_Universal_Adapter	479753	0.09950%
PhiX_read2_adapter	52478	0.01088%
I5_Nextera_Transposase_1	22467	0.00466%
I5_Nextera_Transposase_2	19363	0.00402%
RNA_Adapter_(RA5)_part_#_15013205	13570	0.00281%
Bisulfite_R2	12962	0.00269%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	10072	0.00209%
I7_Nextera_Transposase_2	7825	0.00162%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	7132	0.00148%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N701	7046	0.00146%
I7_Nextera_Transposase_1	6647	0.00138%
Nextera_LMP_Read1_External_Adapter	5313	0.00110%
I5_Adapter_Nextera	4801	0.00100%
Bisulfite_R1	3632	0.00075%
I7_Adapter_Nextera_No_Barcode	3071	0.00064%
RNA_PCR_Primer_(RP1)_part_#_15013198	2784	0.00058%
```

```text
#filter
#Matched	1320251	0.30187%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	1319530	0.30170%
contam_129	152	0.00003%
contam_32	136	0.00003%
```


Table: statMergeReads

| Name          | N50 |     Sum |         # |
|:--------------|----:|--------:|----------:|
| clumped       | 100 |  42.17G | 435882618 |
| ecco          | 100 |  42.17G | 435882618 |
| ecct          | 100 |  38.88G | 402035290 |
| extended      | 140 |  53.91G | 402035290 |
| merged        | 217 |  39.13G | 195895582 |
| unmerged.raw  | 129 |   1.27G |  10244126 |
| unmerged.trim | 129 |   1.27G |  10240950 |
| U1            | 129 | 636.35M |   5120475 |
| U2            | 129 | 630.75M |   5120475 |
| Us            |   0 |       0 |         0 |
| pe.cor        | 215 |   40.6G | 402032114 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 136.5 |    142 |  34.3 |         60.38% |
| ihist.merge.txt  | 199.8 |    207 |  45.7 |         97.45% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|--------:|--------:|---------:|----------:|
| Q0L0   | 352.5 |  324.4 |    7.97% |      97 | "71" | 119.67M | 304.93M |     2.55 | 1:14'37'' |
| Q25L60 | 328.0 |  307.7 |    6.18% |      97 | "71" | 119.67M | 300.76M |     2.51 | 1:09'08'' |
| Q30L60 | 290.3 |  275.2 |    5.18% |      96 | "71" | 119.67M | 298.28M |     2.49 | 1:03'45'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |      # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|-------:|-------:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  79.10% |      3703 | 204.02M | 71500 |      2741 | 79.63M | 241259 |   33.0 | 10.0 |   3.0 |  66.0 | "31,41,51,61,71,81" | 1:42'35'' | 1:15'51'' |
| Q0L0X40P001    |   40.0 |  79.12% |      3692 | 204.01M | 71443 |      2767 | 79.57M | 241312 |   33.0 | 10.0 |   3.0 |  66.0 | "31,41,51,61,71,81" | 1:42'42'' | 1:16'11'' |
| Q0L0X80P000    |   80.0 |  77.38% |      4170 | 211.09M | 67550 |      2552 | 62.12M | 200386 |   64.0 | 22.0 |   3.0 | 128.0 | "31,41,51,61,71,81" | 2:37'23'' | 1:17'36'' |
| Q0L0XallP000   |  104.0 |  75.93% |      4133 | 214.82M | 68783 |      2315 | 52.06M | 185684 |   85.0 | 30.0 |   3.0 | 170.0 | "31,41,51,61,71,81" | 3:04'23'' | 1:14'53'' |
| Q25L60X40P000  |   40.0 |  79.83% |      3675 | 205.89M | 72306 |      2811 | 80.64M | 248142 |   34.0 | 11.0 |   3.0 |  68.0 | "31,41,51,61,71,81" | 1:43'07'' | 1:20'53'' |
| Q25L60X40P001  |   40.0 |  79.80% |      3674 |  205.9M | 72439 |      2809 | 80.73M | 247963 |   34.0 | 11.0 |   3.0 |  68.0 | "31,41,51,61,71,81" | 1:43'10'' | 1:19'44'' |
| Q25L60X80P000  |   80.0 |  78.83% |      4184 | 209.19M | 67114 |      2745 | 70.76M | 209876 |   64.0 | 22.0 |   3.0 | 128.0 | "31,41,51,61,71,81" | 2:39'06'' | 1:23'04'' |
| Q25L60XallP000 |   98.7 |  78.00% |      4212 | 212.66M | 67383 |      2607 | 62.55M | 196872 |   80.0 | 28.0 |   3.0 | 160.0 | "31,41,51,61,71,81" | 3:01'07'' | 1:21'31'' |
| Q30L60X40P000  |   40.0 |  80.00% |      3347 | 200.13M | 75053 |      2750 | 87.57M | 260831 |   35.0 | 11.0 |   3.0 |  70.0 | "31,41,51,61,71,81" | 1:39'18'' | 1:20'11'' |
| Q30L60X40P001  |   40.0 |  80.05% |      3336 | 200.34M | 75178 |      2727 | 87.96M | 260846 |   35.0 | 11.0 |   3.0 |  70.0 | "31,41,51,61,71,81" | 1:39'28'' | 1:20'17'' |
| Q30L60X80P000  |   80.0 |  80.05% |      3860 | 207.19M | 70147 |      2801 | 79.77M | 232998 |   66.0 | 22.0 |   3.0 | 132.0 | "31,41,51,61,71,81" | 2:36'18'' | 1:32'56'' |
| Q30L60XallP000 |   88.2 |  79.83% |      3889 | 206.37M | 69533 |      2797 | 79.73M | 226673 |   72.0 | 24.0 |   3.0 | 144.0 | "31,41,51,61,71,81" | 2:46'15'' | 1:30'44'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |      # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|-------:|-------:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  80.59% |      3532 | 199.29M | 72054 |      3099 | 87.21M | 247928 |   34.0 | 11.0 |   3.0 |  68.0 | "31,41,51,61,71,81" | 0:53'48'' | 1:11'46'' |
| Q0L0X40P001    |   40.0 |  80.58% |      3534 | 198.96M | 71857 |      3129 | 87.42M | 247922 |   34.0 | 11.0 |   3.0 |  68.0 | "31,41,51,61,71,81" | 0:53'43'' | 1:11'54'' |
| Q0L0X80P000    |   80.0 |  82.09% |      4548 | 213.61M | 65097 |      3533 | 77.94M | 215458 |   64.0 | 21.0 |   3.0 | 128.0 | "31,41,51,61,71,81" | 1:25'16'' | 1:32'42'' |
| Q0L0XallP000   |  104.0 |  81.92% |      4787 | 215.11M | 63041 |      3517 | 75.11M | 196172 |   82.0 | 27.0 |   3.0 | 164.0 | "31,41,51,61,71,81" | 1:34'33'' | 1:32'11'' |
| Q25L60X40P000  |   40.0 |  80.77% |      3414 |  199.1M | 73476 |      3024 | 85.92M | 254282 |   35.0 | 11.0 |   3.0 |  70.0 | "31,41,51,61,71,81" | 0:52'44'' | 1:13'14'' |
| Q25L60X40P001  |   40.0 |  80.74% |      3424 | 199.16M | 73498 |      3057 | 85.99M | 254224 |   35.0 | 11.0 |   3.0 |  70.0 | "31,41,51,61,71,81" | 0:53'01'' | 1:13'04'' |
| Q25L60X80P000  |   80.0 |  82.62% |      4354 |  212.6M | 66810 |      3560 | 83.22M | 226608 |   65.0 | 21.0 |   3.0 | 130.0 | "31,41,51,61,71,81" | 1:24'30'' | 1:36'09'' |
| Q25L60XallP000 |   98.7 |  82.58% |      4566 | 213.65M | 64824 |      3569 |  81.3M | 211451 |   79.0 | 26.0 |   3.0 | 158.0 | "31,41,51,61,71,81" | 1:32'21'' | 1:37'37'' |
| Q30L60X40P000  |   40.0 |  80.25% |      3067 | 190.64M | 75626 |      2798 | 88.72M | 263413 |   36.0 | 11.0 |   3.0 |  72.0 | "31,41,51,61,71,81" | 0:49'29'' | 1:11'24'' |
| Q30L60X40P001  |   40.0 |  80.33% |      3071 | 190.63M | 75687 |      2753 | 89.32M | 263245 |   36.0 | 11.0 |   3.0 |  72.0 | "31,41,51,61,71,81" | 0:49'15'' | 1:10'58'' |
| Q30L60X80P000  |   80.0 |  82.91% |      3809 | 207.75M | 71298 |      3298 | 92.54M | 252017 |   67.0 | 21.0 |   3.0 | 134.0 | "31,41,51,61,71,81" | 1:19'28'' | 1:42'27'' |
| Q30L60XallP000 |   88.2 |  83.04% |      3938 | 210.37M | 70585 |      3345 | 89.48M | 246662 |   74.0 | 24.0 |   3.0 | 148.0 | "31,41,51,61,71,81" | 1:23'40'' | 1:46'02'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |      # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|--------:|------:|----------:|-------:|-------:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  75.44% |      4491 | 206.43M | 62218 |      3144 | 54.38M | 127639 |   34.0 | 12.0 |   3.0 |  68.0 | "31,41,51,61,71,81" | 2:32'09'' | 0:40'25'' |
| MRX40P001  |   40.0 |  75.46% |      4499 | 206.41M | 62203 |      3125 | 54.47M | 127560 |   34.0 | 12.0 |   3.0 |  68.0 | "31,41,51,61,71,81" | 2:31'58'' | 0:40'30'' |
| MRX80P000  |   80.0 |  74.00% |      4266 | 211.48M | 65589 |      2893 | 45.93M | 122213 |   69.0 | 24.0 |   3.0 | 138.0 | "31,41,51,61,71,81" | 3:50'22'' | 0:44'43'' |
| MRXallP000 |  108.8 |  73.14% |      4118 |  212.9M | 67420 |      2744 |  42.3M | 119965 |   95.0 | 32.0 |   3.0 | 190.0 | "31,41,51,61,71,81" | 4:46'01'' | 0:46'53'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |      # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|--------:|------:|----------:|-------:|-------:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  77.96% |      4505 | 197.43M | 59851 |      3747 |    67M | 127069 |   32.0 | 11.0 |   3.0 |  64.0 | "31,41,51,61,71,81" | 1:22'12'' | 0:40'39'' |
| MRX40P001  |   40.0 |  77.94% |      4517 | 197.31M | 59662 |      3759 | 67.29M | 126649 |   32.0 | 11.0 |   3.0 |  64.0 | "31,41,51,61,71,81" | 1:21'49'' | 0:40'47'' |
| MRX80P000  |   80.0 |  77.44% |      4787 | 213.44M | 61445 |      3510 | 50.07M | 110922 |   68.0 | 24.0 |   3.0 | 136.0 | "31,41,51,61,71,81" | 1:41'43'' | 0:46'55'' |
| MRXallP000 |  108.8 |  77.27% |      4727 | 215.22M | 62351 |      3478 |  48.5M | 105636 |   93.0 | 32.0 |   3.0 | 186.0 | "31,41,51,61,71,81" | 1:55'47'' | 0:49'51'' |


Table: statFinal

| Name                             |      N50 |       Sum |       # |
|:---------------------------------|---------:|----------:|--------:|
| Genome                           | 29958434 | 373245519 |      12 |
| Paralogs                         |     2842 |  88451827 |   36289 |
| 7_mergeKunitigsAnchors.anchors   |     5363 | 240787806 |   66809 |
| 7_mergeKunitigsAnchors.others    |     3427 | 152146559 |   62088 |
| 7_mergeTadpoleAnchors.anchors    |     5174 | 242678225 |   68994 |
| 7_mergeTadpoleAnchors.others     |     3620 | 146909552 |   58710 |
| 7_mergeMRKunitigsAnchors.anchors |     4993 | 223941334 |   62953 |
| 7_mergeMRKunitigsAnchors.others  |     3462 |  69282117 |   27735 |
| 7_mergeMRTadpoleAnchors.anchors  |     5141 | 221096838 |   60828 |
| 7_mergeMRTadpoleAnchors.others   |     4042 |  82103467 |   29718 |
| 7_mergeAnchors.anchors           |     6003 | 248451868 |   63541 |
| 7_mergeAnchors.others            |     3506 | 180159633 |   75109 |
| spades.contig                    |    12514 | 351318316 |  381553 |
| spades.scaffold                  |    12831 | 351338323 |  380642 |
| spades.non-contained             |    15457 | 299243861 |   35762 |
| spades.anchor                    |     9660 | 240430520 |   43321 |
| megahit.contig                   |     6632 | 307254168 |  135080 |
| megahit.non-contained            |     7787 | 272070666 |   54912 |
| megahit.anchor                   |     5780 | 217367537 |   55256 |
| platanus.contig                  |     2364 | 410328234 | 1140381 |
| platanus.scaffold                |     9646 | 311671367 |  150025 |
| platanus.non-contained           |    10787 | 284255639 |   43921 |
| platanus.anchor                  |     6662 | 217741681 |   50714 |
