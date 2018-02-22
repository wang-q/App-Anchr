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
    --queue mpi \
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
    --sgapreqc \
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

bash 2_insertSize.sh
bash 2_sgaPreQC.sh

# preprocess Illumina reads
bash 2_trim.sh

# preprocess PacBio reads
bash 3_trimlong.sh

# reads stats
bash 9_statReads.sh

# mergereads
bash 2_mergereads.sh

# quorum
bash 2_quorum.sh
bash 9_statQuorum.sh

```

Table: statInsertSize

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| genome.bbtools  | 321.9 |    298 | 968.5 |                         47.99% |
| tadpole.bbtools | 295.6 |    296 |  21.1 |                         40.57% |
| genome.picard   | 298.2 |    298 |  18.0 |                             FR |
| tadpole.picard  | 294.9 |    296 |  21.7 |                             FR |


Table: statSgaPreQC

| Item           |  Value |
|:---------------|-------:|
| incorrectBases |  0.26% |
| perfectReads   | 79.72% |
| overlapDepth   | 356.41 |


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
| merged        | 339 |  1.43G | 4246260 |
| unmerged.raw  | 174 | 16.73M |  114986 |
| unmerged.trim | 174 | 16.72M |  114920 |
| U1            | 181 |   8.8M |   57460 |
| U2            | 167 |  7.92M |   57460 |
| Us            |   0 |      0 |       0 |
| pe.cor        | 338 |  1.45G | 8607440 |

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
| Q0L0X40P000   |   40.0 |  97.02% |     10065 | 4.46M |  645 |        79 |  99.87K | 1610 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:01'10'' |
| Q0L0X40P001   |   40.0 |  96.69% |     10741 | 4.44M |  654 |        79 |  97.74K | 1581 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'16'' | 0:01'09'' |
| Q0L0X40P002   |   40.0 |  96.75% |     10185 | 4.44M |  669 |        91 | 105.67K | 1647 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:01'06'' |
| Q0L0X40P003   |   40.0 |  96.90% |      9538 | 4.46M |  689 |        70 |  98.32K | 1715 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:01'07'' |
| Q0L0X40P004   |   40.0 |  96.89% |     10670 | 4.45M |  622 |        85 | 101.73K | 1592 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:01'06'' |
| Q0L0X80P000   |   80.0 |  94.29% |      5487 | 4.33M | 1079 |        54 | 104.45K | 2237 |   75.0 | 5.0 |  20.0 | 135.0 | "31,41,51,61,71,81" | 0:01'57'' | 0:01'09'' |
| Q0L0X80P001   |   80.0 |  94.19% |      5240 | 4.32M | 1088 |        69 | 123.34K | 2287 |   75.0 | 5.0 |  20.0 | 135.0 | "31,41,51,61,71,81" | 0:01'57'' | 0:01'07'' |
| Q20L60X40P000 |   40.0 |  97.16% |     11416 | 4.46M |  624 |        73 |  94.35K | 1592 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'10'' |
| Q20L60X40P001 |   40.0 |  97.03% |     11373 | 4.44M |  598 |       259 | 116.67K | 1553 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'10'' |
| Q20L60X40P002 |   40.0 |  97.13% |     10863 | 4.47M |  605 |        69 |  86.75K | 1534 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:01'08'' |
| Q20L60X40P003 |   40.0 |  97.04% |     11717 | 4.47M |  610 |        64 |   77.4K | 1528 |   38.0 | 3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'08'' |
| Q20L60X40P004 |   40.0 |  96.98% |     11386 | 4.45M |  602 |        95 | 101.26K | 1530 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'07'' |
| Q20L60X80P000 |   80.0 |  95.03% |      5890 | 4.36M |  980 |        61 | 104.26K | 2110 |   76.0 | 5.0 |  20.0 | 136.5 | "31,41,51,61,71,81" | 0:01'58'' | 0:01'11'' |
| Q20L60X80P001 |   80.0 |  94.95% |      6106 | 4.37M | 1015 |        56 |  99.67K | 2145 |   75.0 | 5.0 |  20.0 | 135.0 | "31,41,51,61,71,81" | 0:01'58'' | 0:01'08'' |
| Q25L60X40P000 |   40.0 |  97.92% |     18760 | 4.49M |  383 |        85 |  81.36K | 1273 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'20'' |
| Q25L60X40P001 |   40.0 |  97.91% |     18580 | 4.49M |  400 |       220 |  96.61K | 1366 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'17'' |
| Q25L60X40P002 |   40.0 |  97.93% |     19052 | 4.49M |  398 |        78 |  87.84K | 1395 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'22'' |
| Q25L60X40P003 |   40.0 |  98.05% |     18303 | 4.49M |  399 |        86 |  85.19K | 1326 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'16'' | 0:01'16'' |
| Q25L60X40P004 |   40.0 |  97.95% |     18296 | 4.48M |  397 |       183 |  93.48K | 1328 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'17'' |
| Q25L60X80P000 |   80.0 |  97.18% |     11693 | 4.47M |  575 |        58 |  63.31K | 1435 |   77.0 | 5.0 |  20.0 | 138.0 | "31,41,51,61,71,81" | 0:01'57'' | 0:01'17'' |
| Q25L60X80P001 |   80.0 |  97.18% |     11073 | 4.48M |  603 |        56 |  63.91K | 1497 |   77.0 | 5.0 |  20.0 | 138.0 | "31,41,51,61,71,81" | 0:01'56'' | 0:01'15'' |
| Q30L60X40P000 |   40.0 |  98.55% |     34313 | 4.52M |  220 |        64 |  66.71K | 1324 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:01'13'' | 0:01'24'' |
| Q30L60X40P001 |   40.0 |  98.54% |     31808 | 4.48M |  251 |       970 | 147.76K | 1351 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'14'' | 0:01'27'' |
| Q30L60X40P002 |   40.0 |  98.54% |     33957 | 4.51M |  219 |       309 |  75.66K | 1331 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:01'25'' |
| Q30L60X40P003 |   40.0 |  98.51% |     33137 | 4.51M |  226 |        69 |   66.9K | 1256 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:01'13'' | 0:01'27'' |
| Q30L60X80P000 |   80.0 |  98.53% |     33119 | 4.51M |  222 |       204 |  66.31K | 1127 |   78.0 | 4.0 |  20.0 | 135.0 | "31,41,51,61,71,81" | 0:01'51'' | 0:01'35'' |
| Q30L60X80P001 |   80.0 |  98.51% |     34022 | 4.51M |  217 |        61 |  53.01K | 1067 |   78.0 | 5.0 |  20.0 | 139.5 | "31,41,51,61,71,81" | 0:01'51'' | 0:01'35'' |

Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  98.26% |     31200 | 4.51M | 241 |        60 |   64.5K | 1174 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'52'' | 0:01'30'' |
| Q0L0X40P001   |   40.0 |  98.05% |     30519 | 4.51M | 264 |        58 |  62.73K | 1201 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'53'' | 0:01'23'' |
| Q0L0X40P002   |   40.0 |  98.12% |     31570 | 4.51M | 243 |       642 | 103.38K | 1184 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'50'' | 0:01'22'' |
| Q0L0X40P003   |   40.0 |  98.24% |     33083 | 4.51M | 233 |        62 |  68.22K | 1155 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'51'' | 0:01'25'' |
| Q0L0X40P004   |   40.0 |  98.17% |     35510 | 4.51M | 240 |        65 |  74.51K | 1212 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'48'' | 0:01'24'' |
| Q0L0X80P000   |   80.0 |  97.46% |     16177 |  4.5M | 433 |        52 |  54.06K | 1158 |   77.0 | 4.0 |  20.0 | 133.5 | "31,41,51,61,71,81" | 0:02'25'' | 0:01'15'' |
| Q0L0X80P001   |   80.0 |  97.46% |     17157 |  4.5M | 416 |        52 |  56.48K | 1166 |   77.0 | 4.0 |  20.0 | 133.5 | "31,41,51,61,71,81" | 0:02'23'' | 0:01'15'' |
| Q20L60X40P000 |   40.0 |  98.23% |     31683 | 4.52M | 245 |        58 |  63.67K | 1210 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'51'' | 0:01'26'' |
| Q20L60X40P001 |   40.0 |  98.18% |     31782 | 4.51M | 250 |        70 |  76.54K | 1212 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'50'' | 0:01'26'' |
| Q20L60X40P002 |   40.0 |  98.23% |     31765 | 4.52M | 246 |        57 |   61.1K | 1183 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'51'' | 0:01'23'' |
| Q20L60X40P003 |   40.0 |  98.24% |     32160 | 4.51M | 241 |        82 |  80.95K | 1148 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'50'' | 0:01'23'' |
| Q20L60X40P004 |   40.0 |  98.27% |     34274 | 4.51M | 231 |        66 |  72.69K | 1177 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'52'' | 0:01'27'' |
| Q20L60X80P000 |   80.0 |  97.57% |     19865 | 4.49M | 402 |        60 |  63.15K | 1150 |   77.0 | 4.0 |  20.0 | 133.5 | "31,41,51,61,71,81" | 0:02'26'' | 0:01'16'' |
| Q20L60X80P001 |   80.0 |  97.70% |     17764 |  4.5M | 400 |        57 |  58.99K | 1132 |   77.0 | 4.0 |  20.0 | 133.5 | "31,41,51,61,71,81" | 0:02'24'' | 0:01'14'' |
| Q25L60X40P000 |   40.0 |  98.42% |     33985 | 4.51M | 228 |        66 |  73.87K | 1266 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'52'' | 0:01'28'' |
| Q25L60X40P001 |   40.0 |  98.42% |     34341 | 4.51M | 228 |        88 |  86.46K | 1301 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'51'' | 0:01'24'' |
| Q25L60X40P002 |   40.0 |  98.45% |     36257 | 4.51M | 212 |        60 |  69.25K | 1265 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'51'' | 0:01'32'' |
| Q25L60X40P003 |   40.0 |  98.47% |     35557 | 4.52M | 227 |        60 |  70.46K | 1287 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'54'' | 0:01'29'' |
| Q25L60X40P004 |   40.0 |  98.39% |     32178 | 4.51M | 238 |        63 |  73.12K | 1273 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'51'' | 0:01'27'' |
| Q25L60X80P000 |   80.0 |  98.17% |     23505 | 4.51M | 300 |        56 |  58.45K | 1136 |   78.0 | 4.0 |  20.0 | 135.0 | "31,41,51,61,71,81" | 0:02'28'' | 0:01'25'' |
| Q25L60X80P001 |   80.0 |  98.19% |     26560 | 4.52M | 298 |        51 |  51.09K | 1136 |   77.0 | 4.0 |  20.0 | 133.5 | "31,41,51,61,71,81" | 0:02'26'' | 0:01'28'' |
| Q30L60X40P000 |   40.0 |  98.54% |     29366 | 4.52M | 256 |        71 |  86.02K | 1584 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:02'07'' | 0:01'25'' |
| Q30L60X40P001 |   40.0 |  98.47% |     31230 | 4.51M | 251 |       283 |  84.82K | 1469 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:02'10'' | 0:01'24'' |
| Q30L60X40P002 |   40.0 |  98.54% |     31194 | 4.52M | 253 |       522 |  99.63K | 1552 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:02'05'' | 0:01'27'' |
| Q30L60X40P003 |   40.0 |  98.51% |     28507 | 4.51M | 264 |       413 |  91.21K | 1501 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:02'07'' | 0:01'28'' |
| Q30L60X80P000 |   80.0 |  98.59% |     40017 | 4.51M | 212 |        85 |  71.59K | 1252 |   78.0 | 4.0 |  20.0 | 135.0 | "31,41,51,61,71,81" | 0:03'00'' | 0:01'38'' |
| Q30L60X80P001 |   80.0 |  98.55% |     37666 | 4.51M | 206 |        54 |  57.73K | 1191 |   78.0 | 5.0 |  20.0 | 139.5 | "31,41,51,61,71,81" | 0:02'57'' | 0:01'36'' |


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

Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |  92.81% |    136677 | 5.58M |  90 |      7394 |    1.2M | 520 |  123.0 | 3.0 |  20.0 | 198.0 | 0:02'13'' |
| 7_mergeKunitigsAnchors   |  93.67% |     63381 | 4.52M | 125 |      2164 | 656.49K | 332 |  123.0 | 5.0 |  20.0 | 207.0 | 0:02'34'' |
| 7_mergeMRKunitigsAnchors |  93.54% |     67213 | 4.51M | 117 |      1617 |  90.64K |  51 |  123.0 | 4.0 |  20.0 | 202.5 | 0:02'32'' |
| 7_mergeMRMegahitAnchors  |  93.47% |     78466 | 4.51M | 111 |      1066 | 162.79K | 154 |  123.0 | 4.0 |  20.0 | 202.5 | 0:02'31'' |
| 7_mergeMRSpadesAnchors   |  93.63% |    122451 | 5.23M |  91 |      1104 | 152.67K | 143 |  123.0 | 4.0 |  20.0 | 202.5 | 0:02'27'' |
| 7_mergeMRTadpoleAnchors  |  93.42% |     82672 | 4.51M | 107 |      1213 |  31.04K |  27 |  123.0 | 4.0 |  20.0 | 202.5 | 0:02'28'' |
| 7_mergeTadpoleAnchors    |  94.22% |     65356 | 4.52M | 119 |     17339 | 602.98K | 189 |  123.0 | 5.0 |  20.0 | 207.0 | 0:02'41'' |

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
| 7_mergeAnchors.anchors   |  136677 | 5582950 |   90 |
| 7_mergeAnchors.others    |    7394 | 1203173 |  520 |
| anchorLong               |  148364 | 5581111 |   87 |
| anchorFill               |  340359 | 5316563 |   28 |
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

# rsync -avP wangq@202.119.37.251:data/anchr/s288c/ ~/data/anchr/s288c

```

* template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=s288c

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
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
    --sgapreqc \
    --parallel 24

```

## s288c: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=s288c

cd ${WORKING_DIR}/${BASE_NAME}

bash 0_bsub.sh
#bash 0_master.sh

#bash 0_cleanup.sh

```

Table: statInsertSize

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| genome.bbtools  | 407.5 |    367 | 464.6 |                         48.81% |
| tadpole.bbtools | 394.9 |    360 | 139.2 |                         42.87% |
| genome.picard   | 402.1 |    367 | 142.1 |                             FR |
| tadpole.picard  | 394.4 |    360 | 139.4 |                             FR |


Table: statSgaPreQC

| Item           |  Value |
|:---------------|-------:|
| incorrectBases |  0.08% |
| perfectReads   | 93.09% |
| overlapDepth   | 113.65 |


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
| merged        | 387 | 902.19M | 2398077 |
| unmerged.raw  | 190 | 287.33M | 1525616 |
| unmerged.trim | 190 | 287.33M | 1525612 |
| U1            | 190 | 144.08M |  762806 |
| U2            | 190 | 143.24M |  762806 |
| Us            |   0 |       0 |       0 |
| pe.cor        | 354 |   1.19G | 6321766 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 249.2 |    255 |  27.7 |         19.23% |
| ihist.merge.txt  | 376.2 |    371 |  72.7 |         75.87% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |  RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|-------:|-------:|---------:|----------:|
| Q0L0   |  81.5 |   73.5 |    9.82% |     149 | "105" | 12.16M | 11.92M |     0.98 | 0:01'58'' |
| Q20L60 |  80.6 |   73.6 |    8.64% |     148 | "105" | 12.16M | 11.86M |     0.98 | 0:01'57'' |
| Q25L60 |  78.0 |   73.2 |    6.10% |     147 | "105" | 12.16M | 11.66M |     0.96 | 0:01'57'' |
| Q30L60 |  73.5 |   70.7 |    3.76% |     146 | "105" | 12.16M |  11.6M |     0.95 | 0:01'50'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  83.00% |     10666 | 10.97M | 1555 |       899 | 362.27K | 3449 |   32.0 | 1.0 |   9.7 |  52.5 | "31,41,51,61,71,81" | 0:02'13'' | 0:01'16'' |
| Q0L0X60P000    |   60.0 |  82.10% |      8477 | 10.91M | 1892 |        84 |  341.5K | 4077 |   48.0 | 2.0 |  14.0 |  81.0 | "31,41,51,61,71,81" | 0:02'58'' | 0:01'19'' |
| Q0L0XallP000   |   73.5 |  81.74% |      7664 | 10.85M | 2009 |        82 | 356.94K | 4298 |   59.0 | 3.0 |  16.7 | 102.0 | "31,41,51,61,71,81" | 0:03'28'' | 0:01'18'' |
| Q20L60X40P000  |   40.0 |  83.15% |     11323 | 11.01M | 1492 |       115 | 312.27K | 3334 |   32.0 | 1.0 |   9.7 |  52.5 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'18'' |
| Q20L60X60P000  |   60.0 |  82.39% |      8934 | 10.93M | 1804 |        86 | 337.15K | 3891 |   49.0 | 2.0 |  14.3 |  82.5 | "31,41,51,61,71,81" | 0:02'55'' | 0:01'19'' |
| Q20L60XallP000 |   73.6 |  82.05% |      8386 |  10.9M | 1929 |        79 | 326.45K | 4122 |   60.0 | 3.0 |  17.0 | 103.5 | "31,41,51,61,71,81" | 0:03'25'' | 0:01'19'' |
| Q25L60X40P000  |   40.0 |  84.67% |     19024 | 11.14M |  991 |      1039 | 239.15K | 2462 |   33.0 | 1.0 |  10.0 |  54.0 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'24'' |
| Q25L60X60P000  |   60.0 |  84.01% |     15848 | 11.11M | 1165 |      1018 | 239.68K | 2635 |   49.0 | 2.0 |  14.3 |  82.5 | "31,41,51,61,71,81" | 0:02'54'' | 0:01'18'' |
| Q25L60XallP000 |   73.2 |  83.84% |     14510 |  11.1M | 1237 |      1014 | 243.88K | 2746 |   60.0 | 2.0 |  18.0 |  99.0 | "31,41,51,61,71,81" | 0:03'23'' | 0:01'21'' |
| Q30L60X40P000  |   40.0 |  86.45% |     21400 | 11.16M |  842 |      1235 | 236.65K | 2223 |   33.0 | 1.0 |  10.0 |  54.0 | "31,41,51,61,71,81" | 0:02'12'' | 0:01'24'' |
| Q30L60X60P000  |   60.0 |  85.65% |     18793 | 11.15M |  984 |      1079 |  230.7K | 2349 |   50.0 | 2.0 |  14.7 |  84.0 | "31,41,51,61,71,81" | 0:02'55'' | 0:01'25'' |
| Q30L60XallP000 |   70.7 |  85.55% |     18122 | 11.14M | 1025 |      1054 | 229.91K | 2394 |   59.0 | 2.0 |  17.7 |  97.5 | "31,41,51,61,71,81" | 0:03'18'' | 0:01'25'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  91.80% |     23728 | 11.17M |  756 |      1366 | 292.31K | 2266 |   33.0 | 1.0 |  10.0 |  54.0 | "31,41,51,61,71,81" | 0:01'09'' | 0:01'32'' |
| Q0L0X60P000    |   60.0 |  91.16% |     19207 | 11.16M |  938 |      1148 |  274.4K | 2272 |   49.0 | 2.0 |  14.3 |  82.5 | "31,41,51,61,71,81" | 0:01'21'' | 0:01'22'' |
| Q0L0XallP000   |   73.5 |  90.75% |     15371 | 11.11M | 1143 |      1069 | 295.24K | 2549 |   60.0 | 2.0 |  18.0 |  99.0 | "31,41,51,61,71,81" | 0:01'27'' | 0:01'21'' |
| Q20L60X40P000  |   40.0 |  91.86% |     25237 | 11.17M |  722 |      1125 | 260.66K | 2261 |   33.0 | 1.0 |  10.0 |  54.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:01'32'' |
| Q20L60X60P000  |   60.0 |  91.22% |     19662 | 11.15M |  900 |      1151 | 260.83K | 2196 |   49.0 | 2.0 |  14.3 |  82.5 | "31,41,51,61,71,81" | 0:01'20'' | 0:01'24'' |
| Q20L60XallP000 |   73.6 |  90.85% |     15636 | 11.12M | 1114 |      1110 | 281.64K | 2497 |   60.0 | 2.0 |  18.0 |  99.0 | "31,41,51,61,71,81" | 0:01'28'' | 0:01'19'' |
| Q25L60X40P000  |   40.0 |  92.43% |     30246 | 11.19M |  629 |      1582 | 247.33K | 2007 |   33.0 | 1.0 |  10.0 |  54.0 | "31,41,51,61,71,81" | 0:01'08'' | 0:01'32'' |
| Q25L60X60P000  |   60.0 |  91.93% |     25139 | 11.18M |  736 |      1621 | 231.75K | 1898 |   50.0 | 2.0 |  14.7 |  84.0 | "31,41,51,61,71,81" | 0:01'20'' | 0:01'24'' |
| Q25L60XallP000 |   73.2 |  91.61% |     22471 | 11.17M |  828 |      1710 | 246.42K | 1940 |   61.0 | 2.0 |  18.3 | 100.5 | "31,41,51,61,71,81" | 0:01'27'' | 0:01'23'' |
| Q30L60X40P000  |   40.0 |  92.86% |     31150 |  11.2M |  597 |      1726 | 250.96K | 2079 |   33.0 | 1.0 |  10.0 |  54.0 | "31,41,51,61,71,81" | 0:01'11'' | 0:01'36'' |
| Q30L60X60P000  |   60.0 |  92.41% |     27834 | 11.18M |  656 |      1717 | 243.58K | 1889 |   50.0 | 1.0 |  15.7 |  79.5 | "31,41,51,61,71,81" | 0:01'18'' | 0:01'30'' |
| Q30L60XallP000 |   70.7 |  92.22% |     25565 | 11.18M |  709 |      1683 | 231.56K | 1922 |   59.0 | 2.0 |  17.7 |  97.5 | "31,41,51,61,71,81" | 0:01'26'' | 0:01'26'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  86.78% |     16606 | 11.07M | 1075 |       152 | 280.98K | 2304 |   32.0 | 2.0 |   8.7 |  57.0 | "31,41,51,61,71,81" | 0:02'36'' | 0:01'16'' |
| MRX40P001  |   40.0 |  87.26% |     17494 | 11.08M | 1061 |       154 | 282.63K | 2274 |   32.0 | 2.0 |   8.7 |  57.0 | "31,41,51,61,71,81" | 0:02'37'' | 0:01'16'' |
| MRX60P000  |   60.0 |  85.88% |     13524 | 11.01M | 1317 |       121 | 314.39K | 2784 |   48.0 | 3.0 |  13.0 |  85.5 | "31,41,51,61,71,81" | 0:03'34'' | 0:01'19'' |
| MRX80P000  |   80.0 |  84.58% |     12354 | 10.95M | 1453 |       108 | 342.54K | 3042 |   64.0 | 4.0 |  17.3 | 114.0 | "31,41,51,61,71,81" | 0:04'30'' | 0:01'17'' |
| MRXallP000 |   98.0 |  83.05% |     11042 | 10.94M | 1546 |       101 | 336.01K | 3232 |   78.0 | 5.0 |  20.0 | 139.5 | "31,41,51,61,71,81" | 0:05'23'' | 0:01'22'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  91.30% |     34085 | 11.15M |  552 |      1275 | 236.12K | 1233 |   33.0 | 1.0 |  10.0 |  54.0 | "31,41,51,61,71,81" | 0:01'17'' | 0:01'17'' |
| MRX40P001  |   40.0 |  91.34% |     34160 | 11.15M |  548 |      1172 | 233.38K | 1241 |   33.0 | 1.0 |  10.0 |  54.0 | "31,41,51,61,71,81" | 0:01'17'' | 0:01'19'' |
| MRX60P000  |   60.0 |  90.98% |     26452 | 11.14M |  707 |      1130 | 250.23K | 1498 |   49.0 | 2.0 |  14.3 |  82.5 | "31,41,51,61,71,81" | 0:01'30'' | 0:01'15'' |
| MRX80P000  |   80.0 |  90.69% |     20395 |  11.1M |  886 |      1049 | 277.19K | 1860 |   66.0 | 2.0 |  20.0 | 108.0 | "31,41,51,61,71,81" | 0:01'39'' | 0:01'18'' |
| MRXallP000 |   98.0 |  90.44% |     17986 | 11.11M | 1023 |      1039 |  251.4K | 2136 |   80.0 | 3.0 |  20.0 | 133.5 | "31,41,51,61,71,81" | 0:01'51'' | 0:01'17'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |    Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|-------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |  74.17% |     47132 | 11.13M | 428 |      1570 |  482.2K | 285 |   31.0 | 1.0 |   9.3 |  51.0 | 0:01'35'' |
| 7_mergeKunitigsAnchors   |  77.50% |     26751 | 11.13M | 701 |      1272 | 353.15K | 228 |   31.0 | 1.0 |   9.3 |  51.0 | 0:02'11'' |
| 7_mergeMRKunitigsAnchors |  75.86% |     22722 | 11.08M | 813 |      1612 | 260.11K | 162 |   31.0 | 1.0 |   9.3 |  51.0 | 0:01'54'' |
| 7_mergeMRTadpoleAnchors  |  76.55% |     45940 | 11.14M | 454 |      4341 | 211.71K |  86 |   31.0 | 1.0 |   9.3 |  51.0 | 0:01'59'' |
| 7_mergeTadpoleAnchors    |  77.83% |     39651 | 11.16M | 497 |      3690 | 277.28K | 123 |   31.0 | 1.0 |   9.3 |  51.0 | 0:02'09'' |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |    Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|-------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|----------:|
| 8_spades     |  85.15% |    122800 | 11.31M | 168 |      5538 | 226.17K | 372 |   32.0 | 1.0 |   9.7 |  52.5 | 0:01'20'' |
| 8_spades_MR  |  87.12% |    146529 | 11.38M | 161 |      5585 | 227.75K | 341 |   32.0 | 1.0 |   9.7 |  52.5 | 0:01'23'' |
| 8_megahit    |  84.95% |     51979 | 11.22M | 404 |      3451 | 239.87K | 861 |   32.0 | 1.0 |   9.7 |  52.5 | 0:02'40'' |
| 8_megahit_MR |  86.41% |     87208 | 11.41M | 270 |      3465 | 230.46K | 577 |   32.0 | 1.0 |   9.7 |  52.5 | 0:01'21'' |
| 8_platanus   |  80.84% |    150088 | 11.35M | 152 |      3670 | 157.75K | 320 |   31.0 | 1.0 |   9.3 |  51.0 | 0:01'20'' |


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
| 7_mergeAnchors.anchors   |  47132 | 11133456 |  428 |
| 7_mergeAnchors.others    |   1570 |   482204 |  285 |
| anchorLong               |  47132 | 11127662 |  426 |
| anchorFill               | 230292 | 11261345 |   94 |
| canu_Xall-trim           | 813374 | 12360766 |   26 |
| spades.contig            | 122875 | 11742788 | 1257 |
| spades.scaffold          | 133886 | 11743508 | 1239 |
| spades.non-contained     | 125298 | 11531378 |  204 |
| spades_MR.contig         | 161566 | 11729267 |  627 |
| spades_MR.scaffold       | 176936 | 11729863 |  619 |
| spades_MR.non-contained  | 176847 | 11604378 |  180 |
| megahit.contig           |  49631 | 11651194 |  984 |
| megahit.non-contained    |  51277 | 11457600 |  457 |
| megahit_MR.contig        |  84456 | 12009082 | 1263 |
| megahit_MR.non-contained |  86307 | 11642769 |  311 |
| platanus.contig          |  37135 | 12071740 | 3954 |
| platanus.scaffold        | 160128 | 11921921 | 2948 |
| platanus.non-contained   | 176536 | 11510261 |  168 |


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

* Illumina HiSeq 2500 (PE150, nextera)

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

# rsync -avP wangq@202.119.37.251:data/anchr/s288cH/ ~/data/anchr/s288cH

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


Table: statInsertSize

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| genome.bbtools  | 356.5 |    320 | 484.3 |                         45.78% |
| tadpole.bbtools | 338.8 |    309 | 144.3 |                         43.31% |
| genome.picard   | 352.1 |    322 | 142.5 |                             FR |
| tadpole.picard  | 342.9 |    313 | 141.4 |                             FR |


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
| merged        | 356 |    2.4G |  7288850 |
| unmerged.raw  | 190 | 527.65M |  2836030 |
| unmerged.trim | 190 | 527.65M |  2836022 |
| U1            | 190 | 267.15M |  1418011 |
| U2            | 190 |  260.5M |  1418011 |
| Us            |   0 |       0 |        0 |
| pe.cor        | 327 |   2.93G | 17413722 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 211.2 |    221 |  53.0 |         39.55% |
| ihist.merge.txt  | 328.9 |    326 |  95.0 |         83.71% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |  RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|-------:|-------:|---------:|----------:|
| Q0L0   | 220.4 |  197.9 |   10.20% |     146 | "105" | 12.16M | 12.44M |     1.02 | 0:04'13'' |
| Q20L60 | 216.0 |  197.7 |    8.46% |     146 | "105" | 12.16M | 12.14M |     1.00 | 0:04'07'' |
| Q25L60 | 207.2 |  195.1 |    5.84% |     145 | "105" | 12.16M | 11.84M |     0.97 | 0:04'00'' |
| Q30L60 | 195.2 |  186.0 |    4.71% |     145 | "105" | 12.16M | 11.72M |     0.96 | 0:03'50'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  88.20% |      9221 | 10.24M | 2090 |      1013 |   1.34M | 5363 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'15'' | 0:01'34'' |
| Q0L0X40P001    |   40.0 |  88.26% |      9150 | 10.22M | 2055 |      1015 |   1.42M | 5266 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'14'' | 0:01'33'' |
| Q0L0X40P002    |   40.0 |  88.42% |     10110 | 10.37M | 1924 |       991 |   1.26M | 5246 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'14'' | 0:01'37'' |
| Q0L0X40P003    |   40.0 |  88.27% |      9315 | 10.28M | 1998 |      1014 |   1.32M | 5148 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'14'' | 0:01'32'' |
| Q0L0X80P000    |   80.0 |  87.23% |      9284 | 10.35M | 2031 |       891 |   1.03M | 4603 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:03'39'' | 0:01'30'' |
| Q0L0X80P001    |   80.0 |  87.31% |      9573 | 10.38M | 1962 |       991 |   1.04M | 4499 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:03'39'' | 0:01'30'' |
| Q0L0X120P000   |  120.0 |  86.40% |      8874 | 10.67M | 1937 |       786 | 583.18K | 4315 |  106.0 | 10.0 |  20.0 | 204.0 | "31,41,51,61,71,81" | 0:05'05'' | 0:01'30'' |
| Q0L0XallP000   |  197.9 |  85.37% |      7683 | 10.77M | 2083 |       760 | 358.73K | 4554 |  175.0 | 17.0 |  20.0 | 339.0 | "31,41,51,61,71,81" | 0:07'55'' | 0:01'35'' |
| Q20L60X40P000  |   40.0 |  88.76% |      9124 | 10.27M | 1996 |      1013 |   1.39M | 5275 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'12'' | 0:01'35'' |
| Q20L60X40P001  |   40.0 |  88.67% |      9948 | 10.27M | 1949 |      1036 |   1.39M | 5135 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'36'' |
| Q20L60X40P002  |   40.0 |  88.60% |     10370 | 10.28M | 1931 |      1005 |   1.31M | 5096 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'12'' | 0:01'35'' |
| Q20L60X40P003  |   40.0 |  88.56% |      9059 | 10.22M | 2009 |      1046 |    1.4M | 5272 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'32'' |
| Q20L60X80P000  |   80.0 |  87.86% |     10430 | 10.48M | 1886 |       963 | 964.35K | 4278 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:03'36'' | 0:01'32'' |
| Q20L60X80P001  |   80.0 |  87.75% |     10555 | 10.42M | 1842 |       980 |   1.01M | 4327 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:03'36'' | 0:01'30'' |
| Q20L60X120P000 |  120.0 |  87.18% |     10366 | 10.75M | 1737 |       855 | 549.51K | 3927 |  107.0 | 10.0 |  20.0 | 205.5 | "31,41,51,61,71,81" | 0:05'00'' | 0:01'33'' |
| Q20L60XallP000 |  197.7 |  86.48% |      9468 | 10.86M | 1813 |       900 | 339.12K | 4013 |  176.0 | 16.0 |  20.0 | 336.0 | "31,41,51,61,71,81" | 0:07'47'' | 0:01'35'' |
| Q25L60X40P000  |   40.0 |  89.21% |     10251 | 10.31M | 1963 |      1007 |   1.35M | 5214 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'36'' |
| Q25L60X40P001  |   40.0 |  89.00% |     11139 | 10.37M | 1821 |      1057 |   1.25M | 4966 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'10'' | 0:01'35'' |
| Q25L60X40P002  |   40.0 |  89.25% |     11281 |  10.4M | 1853 |      1007 |   1.24M | 5203 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'38'' |
| Q25L60X40P003  |   40.0 |  89.20% |     10802 |  10.4M | 1839 |      1034 |   1.24M | 5071 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'10'' | 0:01'33'' |
| Q25L60X80P000  |   80.0 |  88.32% |     11547 | 10.49M | 1774 |      1011 |      1M | 4235 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:03'34'' | 0:01'34'' |
| Q25L60X80P001  |   80.0 |  88.39% |     11359 | 10.49M | 1783 |       987 |  998.7K | 4250 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:03'33'' | 0:01'33'' |
| Q25L60X120P000 |  120.0 |  87.62% |     11240 | 10.79M | 1660 |       860 | 530.67K | 3829 |  107.0 | 10.0 |  20.0 | 205.5 | "31,41,51,61,71,81" | 0:04'58'' | 0:01'35'' |
| Q25L60XallP000 |  195.1 |  87.01% |     10318 | 10.91M | 1695 |       991 | 317.46K | 3817 |  174.0 | 16.0 |  20.0 | 333.0 | "31,41,51,61,71,81" | 0:07'39'' | 0:01'37'' |
| Q30L60X40P000  |   40.0 |  89.67% |     11377 | 10.41M | 1825 |       991 |   1.24M | 5141 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'13'' | 0:01'39'' |
| Q30L60X40P001  |   40.0 |  89.62% |     12048 | 10.44M | 1739 |      1023 |   1.16M | 4870 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'12'' | 0:01'36'' |
| Q30L60X40P002  |   40.0 |  89.71% |     11519 |  10.4M | 1762 |      1051 |   1.25M | 4996 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'12'' | 0:01'38'' |
| Q30L60X40P003  |   40.0 |  89.56% |     11403 | 10.46M | 1783 |       969 |   1.13M | 5023 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'12'' | 0:01'37'' |
| Q30L60X80P000  |   80.0 |  88.75% |     12549 | 10.53M | 1690 |       943 | 941.57K | 4233 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:03'36'' | 0:01'35'' |
| Q30L60X80P001  |   80.0 |  88.92% |     12531 | 10.57M | 1643 |      1008 | 921.92K | 4154 |   72.0 |  6.0 |  18.0 | 135.0 | "31,41,51,61,71,81" | 0:03'36'' | 0:01'37'' |
| Q30L60X120P000 |  120.0 |  88.15% |     12353 | 10.85M | 1583 |       799 | 522.69K | 3777 |  107.0 |  9.0 |  20.0 | 201.0 | "31,41,51,61,71,81" | 0:05'01'' | 0:01'37'' |
| Q30L60XallP000 |  186.0 |  87.55% |     11568 | 10.98M | 1578 |       963 | 307.81K | 3621 |  166.0 | 15.0 |  20.0 | 316.5 | "31,41,51,61,71,81" | 0:07'22'' | 0:01'38'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  91.90% |     10279 | 10.42M | 1889 |       986 |   1.18M | 5414 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'16'' | 0:01'34'' |
| Q0L0X40P001    |   40.0 |  92.03% |     10782 | 10.45M | 1820 |       944 |   1.23M | 5432 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'16'' | 0:01'38'' |
| Q0L0X40P002    |   40.0 |  92.09% |     10670 | 10.46M | 1806 |       940 |   1.17M | 5382 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'38'' |
| Q0L0X40P003    |   40.0 |  91.99% |     10102 | 10.43M | 1824 |       967 |   1.15M | 5370 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'14'' | 0:01'35'' |
| Q0L0X80P000    |   80.0 |  92.31% |     15564 | 10.62M | 1463 |       899 |   1.01M | 4470 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:01'38'' | 0:01'43'' |
| Q0L0X80P001    |   80.0 |  92.42% |     15190 | 10.65M | 1444 |       942 |   1.01M | 4383 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:01'39'' | 0:01'47'' |
| Q0L0X120P000   |  120.0 |  91.91% |     15594 |  10.9M | 1295 |       776 |  549.1K | 3667 |  107.0 |  9.0 |  20.0 | 201.0 | "31,41,51,61,71,81" | 0:02'03'' | 0:01'45'' |
| Q0L0XallP000   |  197.9 |  91.58% |     13795 | 11.03M | 1350 |       881 | 354.53K | 3497 |  176.0 | 15.0 |  20.0 | 331.5 | "31,41,51,61,71,81" | 0:02'52'' | 0:01'44'' |
| Q20L60X40P000  |   40.0 |  92.22% |     10384 | 10.46M | 1863 |       912 |   1.16M | 5466 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'16'' | 0:01'37'' |
| Q20L60X40P001  |   40.0 |  92.23% |     10513 | 10.44M | 1815 |       983 |   1.21M | 5431 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'18'' | 0:01'37'' |
| Q20L60X40P002  |   40.0 |  92.24% |     10812 | 10.48M | 1788 |       990 |   1.21M | 5339 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'16'' | 0:01'38'' |
| Q20L60X40P003  |   40.0 |  92.22% |     10152 | 10.44M | 1808 |       974 |   1.17M | 5410 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'14'' | 0:01'35'' |
| Q20L60X80P000  |   80.0 |  92.55% |     15358 | 10.67M | 1474 |       912 |      1M | 4487 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:01'38'' | 0:01'46'' |
| Q20L60X80P001  |   80.0 |  92.52% |     16023 | 10.68M | 1445 |       911 | 987.83K | 4397 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:01'38'' | 0:01'45'' |
| Q20L60X120P000 |  120.0 |  92.19% |     16156 |  10.9M | 1246 |       803 | 584.13K | 3694 |  107.0 |  9.0 |  20.0 | 201.0 | "31,41,51,61,71,81" | 0:02'02'' | 0:01'45'' |
| Q20L60XallP000 |  197.7 |  91.76% |     14170 | 11.05M | 1311 |       843 | 321.82K | 3378 |  177.0 | 15.0 |  20.0 | 333.0 | "31,41,51,61,71,81" | 0:02'54'' | 0:01'46'' |
| Q25L60X40P000  |   40.0 |  92.41% |     10439 | 10.46M | 1836 |       911 |   1.11M | 5370 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'16'' | 0:01'36'' |
| Q25L60X40P001  |   40.0 |  92.53% |     10721 | 10.44M | 1781 |      1032 |   1.22M | 5403 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'37'' |
| Q25L60X40P002  |   40.0 |  92.46% |     11839 |  10.8M | 1503 |       732 | 657.38K | 4985 |   36.0 |  4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'37'' |
| Q25L60X40P003  |   40.0 |  92.58% |     10642 | 10.45M | 1792 |      1007 |    1.2M | 5452 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'13'' | 0:01'39'' |
| Q25L60X80P000  |   80.0 |  92.87% |     15474 | 10.67M | 1441 |       923 | 984.11K | 4453 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:01'37'' | 0:01'46'' |
| Q25L60X80P001  |   80.0 |  92.89% |     16400 | 10.71M | 1387 |       876 |  923.1K | 4396 |   72.0 |  6.0 |  18.0 | 135.0 | "31,41,51,61,71,81" | 0:01'38'' | 0:01'47'' |
| Q25L60X120P000 |  120.0 |  92.52% |     16484 | 10.92M | 1238 |       831 | 554.72K | 3623 |  107.0 |  9.0 |  20.0 | 201.0 | "31,41,51,61,71,81" | 0:02'01'' | 0:01'48'' |
| Q25L60XallP000 |  195.1 |  92.13% |     14605 | 11.07M | 1258 |       873 | 311.31K | 3364 |  175.0 | 15.0 |  20.0 | 330.0 | "31,41,51,61,71,81" | 0:02'52'' | 0:01'46'' |
| Q30L60X40P000  |   40.0 |  92.65% |     10264 | 10.46M | 1833 |       987 |   1.21M | 5419 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'37'' |
| Q30L60X40P001  |   40.0 |  92.66% |     10872 | 10.47M | 1760 |      1005 |   1.16M | 5315 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'13'' | 0:01'34'' |
| Q30L60X40P002  |   40.0 |  92.61% |     10071 | 10.42M | 1800 |      1012 |   1.21M | 5391 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'13'' | 0:01'38'' |
| Q30L60X40P003  |   40.0 |  92.71% |     10810 | 10.47M | 1796 |       949 |   1.16M | 5477 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'14'' | 0:01'37'' |
| Q30L60X80P000  |   80.0 |  93.19% |     17619 | 10.75M | 1304 |       846 | 908.88K | 4446 |   72.0 |  6.0 |  18.0 | 135.0 | "31,41,51,61,71,81" | 0:01'38'' | 0:01'50'' |
| Q30L60X80P001  |   80.0 |  93.16% |     16874 | 10.74M | 1323 |       855 | 907.43K | 4469 |   72.0 |  6.0 |  18.0 | 135.0 | "31,41,51,61,71,81" | 0:01'37'' | 0:01'51'' |
| Q30L60X120P000 |  120.0 |  92.94% |     18342 | 10.95M | 1160 |       722 | 531.99K | 3724 |  108.0 |  9.0 |  20.0 | 202.5 | "31,41,51,61,71,81" | 0:02'00'' | 0:01'51'' |
| Q30L60XallP000 |  186.0 |  92.50% |     15974 | 11.07M | 1211 |       961 | 341.83K | 3419 |  168.0 | 13.0 |  20.0 | 310.5 | "31,41,51,61,71,81" | 0:02'43'' | 0:01'52'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  86.80% |     12864 | 10.38M | 1621 |      1043 |   1.03M | 3183 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'51'' | 0:01'24'' |
| MRX40P001  |   40.0 |  86.70% |     13386 |  10.4M | 1631 |      1028 | 994.14K | 3149 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'50'' | 0:01'22'' |
| MRX40P002  |   40.0 |  87.08% |     13438 | 10.44M | 1636 |      1014 | 990.32K | 3130 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'50'' | 0:01'23'' |
| MRX40P003  |   40.0 |  86.67% |     13284 | 10.41M | 1646 |      1020 | 955.75K | 3185 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'49'' | 0:01'21'' |
| MRX40P004  |   40.0 |  86.66% |     12893 | 10.38M | 1646 |      1040 |      1M | 3155 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'49'' | 0:01'20'' |
| MRX40P005  |   40.0 |  86.69% |     13340 | 10.39M | 1686 |      1019 | 993.06K | 3223 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'50'' | 0:01'25'' |
| MRX80P000  |   80.0 |  85.90% |     10869 |  10.4M | 1744 |       986 |  908.1K | 3291 |   70.0 |  6.0 |  17.3 | 132.0 | "31,41,51,61,71,81" | 0:04'50'' | 0:01'20'' |
| MRX80P001  |   80.0 |  85.88% |     12279 | 10.62M | 1570 |       935 | 722.46K | 3064 |   70.0 |  7.0 |  16.3 | 136.5 | "31,41,51,61,71,81" | 0:04'50'' | 0:01'23'' |
| MRX80P002  |   80.0 |  85.79% |     12501 | 10.58M | 1605 |       910 | 718.23K | 3101 |   70.0 |  7.0 |  16.3 | 136.5 | "31,41,51,61,71,81" | 0:04'48'' | 0:01'19'' |
| MRX120P000 |  120.0 |  85.18% |     11185 | 10.68M | 1620 |       862 | 567.69K | 3299 |  105.0 | 10.0 |  20.0 | 202.5 | "31,41,51,61,71,81" | 0:06'50'' | 0:01'25'' |
| MRX120P001 |  120.0 |  85.08% |     11081 | 10.68M | 1636 |       887 | 570.43K | 3286 |  105.0 | 10.0 |  20.0 | 202.5 | "31,41,51,61,71,81" | 0:06'48'' | 0:01'24'' |
| MRXallP000 |  241.2 |  83.88% |      9132 | 10.86M | 1853 |       834 | 325.79K | 3846 |  209.0 | 22.0 |  20.0 | 412.5 | "31,41,51,61,71,81" | 0:12'55'' | 0:01'30'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  91.16% |     15366 | 10.49M | 1449 |      1007 |   1.09M | 3439 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:01'21'' | 0:01'34'' |
| MRX40P001  |   40.0 |  91.08% |     17801 | 10.52M | 1394 |      1024 |   1.05M | 3286 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:01'22'' | 0:01'32'' |
| MRX40P002  |   40.0 |  91.03% |     16853 | 10.51M | 1458 |      1014 |   1.06M | 3359 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:01'24'' | 0:01'30'' |
| MRX40P003  |   40.0 |  91.08% |     16572 | 10.55M | 1457 |       938 |   1.01M | 3490 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:01'21'' | 0:01'31'' |
| MRX40P004  |   40.0 |  91.04% |     16642 | 10.51M | 1461 |      1017 |   1.08M | 3507 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:01'22'' | 0:01'33'' |
| MRX40P005  |   40.0 |  91.07% |     16384 | 10.51M | 1463 |       983 |   1.03M | 3375 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:01'22'' | 0:01'31'' |
| MRX80P000  |   80.0 |  90.61% |     19715 | 10.68M | 1208 |       973 | 725.24K | 2472 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:01'52'' | 0:01'27'' |
| MRX80P001  |   80.0 |  90.56% |     18050 | 10.68M | 1269 |       973 | 742.72K | 2563 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:01'50'' | 0:01'25'' |
| MRX80P002  |   80.0 |  90.48% |     18200 |  10.7M | 1259 |       985 |  727.9K | 2525 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:01'52'' | 0:01'25'' |
| MRX120P000 |  120.0 |  90.31% |     18765 | 10.88M | 1102 |       891 | 472.66K | 2345 |  107.0 |  9.0 |  20.0 | 201.0 | "31,41,51,61,71,81" | 0:02'20'' | 0:01'27'' |
| MRX120P001 |  120.0 |  90.27% |     18008 |  10.9M | 1115 |       808 | 442.66K | 2368 |  107.0 |  9.0 |  20.0 | 201.0 | "31,41,51,61,71,81" | 0:02'21'' | 0:01'28'' |
| MRXallP000 |  241.2 |  90.03% |     15237 | 11.06M | 1198 |       988 | 264.44K | 2540 |  214.0 | 19.0 |  20.0 | 406.5 | "31,41,51,61,71,81" | 0:04'06'' | 0:01'32'' |


Table: statFinal

| Name                             |    N50 |      Sum |    # |
|:---------------------------------|-------:|---------:|-----:|
| Genome                           | 924431 | 12157105 |   17 |
| Paralogs                         |   3851 |  1059148 |  366 |
| 7_mergeKunitigsAnchors.anchors   |  30238 | 11356870 |  695 |
| 7_mergeKunitigsAnchors.others    |   1431 |  5062509 | 3922 |
| 7_mergeTadpoleAnchors.anchors    |  30553 | 11331925 |  668 |
| 7_mergeTadpoleAnchors.others     |   1363 |  4426212 | 3546 |
| 7_mergeMRKunitigsAnchors.anchors |  29320 | 11319953 |  741 |
| 7_mergeMRKunitigsAnchors.others  |   1352 |  2364318 | 1877 |
| 7_mergeMRTadpoleAnchors.anchors  |  30911 | 11270957 |  653 |
| 7_mergeMRTadpoleAnchors.others   |   1348 |  2235818 | 1773 |
| 7_mergeAnchors.anchors           |  40012 | 11809868 |  565 |
| 7_mergeAnchors.others            |   1470 |  6255680 | 4737 |
| spades.contig                    |  98194 | 11748052 | 1418 |
| spades.scaffold                  | 107724 | 11748872 | 1390 |
| spades.non-contained             | 102190 | 11515252 |  265 |
| spades.anchor                    |  10759 | 10873494 | 1501 |
| megahit.contig                   |  43963 | 11645819 | 1102 |
| megahit.non-contained            |  44572 | 11428430 |  507 |
| megahit.anchor                   |   7954 | 10588820 | 1943 |
| platanus.contig                  |   7451 | 12205621 | 5475 |
| platanus.scaffold                |  67382 | 11916760 | 3298 |
| platanus.non-contained           |  70075 | 11412361 |  324 |
| platanus.anchor                  |   8317 | 10699538 | 1854 |


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
