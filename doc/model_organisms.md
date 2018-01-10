# Assemble genomes of model organisms by ANCHR

[TOC levels=1-3]: # " "
- [Assemble genomes of model organisms by ANCHR](#assemble-genomes-of-model-organisms-by-anchr)
- [More tools on downloading and preprocessing data](#more-tools-on-downloading-and-preprocessing-data)
    - [Extra external executables](#extra-external-executables)
    - [Two of the leading assemblers](#two-of-the-leading-assemblers)
    - [PacBio specific tools](#pacbio-specific-tools)
- [*Escherichia coli* str. K-12 substr. MG1655](#escherichia-coli-str-k-12-substr-mg1655)
    - [e_coli: download](#e-coli-download)
    - [e_coli: template](#e-coli-template)
    - [e_coli: run](#e-coli-run)
- [*Saccharomyces cerevisiae* S288c](#saccharomyces-cerevisiae-s288c)
    - [s288c: download](#s288c-download)
    - [s288c: template](#s288c-template)
    - [s288c: run](#s288c-run)
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


# More tools on downloading and preprocessing data

## Extra external executables

```bash
brew install aria2 curl                     # downloading tools

brew install homebrew/science/sratoolkit    # NCBI SRAToolkit

brew reinstall --build-from-source --without-webp gd # broken, can't find libwebp.so.6
brew reinstall --build-from-source lua@5.1
brew reinstall --build-from-source gnuplot@4
brew install homebrew/science/mummer        # mummer need gnuplot4

brew install openblas                       # numpy

brew install python
brew install homebrew/science/quast         # assembly quality assessment
quast --test                                # may recompile the bundled nucmer

# canu requires gnuplot 5 while mummer requires gnuplot 4
brew install --build-from-source canu

brew unlink gnuplot@4
brew install gnuplot
brew unlink gnuplot

brew link gnuplot@4 --force

brew install r
brew install kmergenie --with-maxkmer=200

brew install homebrew/science/kmc --HEAD
```

## Two of the leading assemblers

```bash
brew install homebrew/science/spades
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
    --trim2 "--uniq --shuffle --bbduk" \
    --sample2 300 \
    --cov2 "40 80" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --cov3 "40 80 all" \
    --qual3 "raw trim" \
    --mergereads \
    --tile \
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

# preprocess Illumina reads
bash 2_trim.sh

# preprocess PacBio reads
bash 3_trimlong.sh

# reads stats
bash 9_statReads.sh

# insertSize
bash 2_insertSize.sh

```

| Name      |     N50 |     Sum |        # |
|:----------|--------:|--------:|---------:|
| Genome    | 4641652 | 4641652 |        1 |
| Paralogs  |    1934 |  195673 |      106 |
| Illumina  |     151 |   1.73G | 11458940 |
| uniq      |     151 |   1.73G | 11439000 |
| shuffle   |     151 |   1.73G | 11439000 |
| sample    |     151 |   1.39G |  9221824 |
| bbduk     |     150 |   1.38G |  9221642 |
| Q20L60    |     150 |   1.22G |  8835415 |
| Q25L60    |     150 |   1.11G |  8522766 |
| Q30L60    |     127 | 926.56M |  7887527 |
| PacBio    |   13982 | 748.51M |    87225 |
| X40.raw   |   14030 | 185.68M |    22336 |
| X40.trim  |   13702 | 169.38M |    19468 |
| X80.raw   |   13990 | 371.34M |    44005 |
| X80.trim  |   13632 | 339.51M |    38725 |
| Xall.raw  |   13982 | 748.51M |    87225 |
| Xall.trim |   13646 | 689.43M |    77693 |

```text
#trimmedReads
#Matched        15594   0.16910%
#Name   Reads   ReadsPct
pcr_dimer       6920    0.07504%
PCR_Primers     1266    0.01373%
```

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q20L60 | 297.6 |    298 |  19.7 |         35.07% |
| Q25L60 | 297.7 |    298 |  19.4 |         43.03% |
| Q30L60 | 297.8 |    298 |  45.2 |         45.61% |

* mergereads

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bash 2_mergereads.sh

```

| Name           | N50 |    Sum |        # |
|:---------------|----:|-------:|---------:|
| clumped        | 151 |  1.72G | 11411654 |
| filteredbytile | 151 |  1.66G | 11024018 |
| trimmed        | 149 |  1.42G | 10344602 |
| filtered       | 149 |  1.42G | 10344094 |
| ecco           | 149 |  1.42G | 10344094 |
| eccc           | 149 |  1.42G | 10344094 |
| ecct           | 149 |  1.42G | 10289556 |
| extended       | 189 |  1.82G | 10289556 |
| merged         | 339 |  1.71G |  5075796 |
| unmerged.raw   | 174 | 20.08M |   137964 |
| unmerged       | 164 | 14.44M |   101870 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 271.6 |    277 |  23.8 |         10.87% |
| ihist.merge.txt  | 337.7 |    338 |  19.3 |         98.66% |

```text
#trimmedReads
#Matched	18712	0.16974%
#Name	Reads	ReadsPct
pcr_dimer	8380	0.07602%
PCR_Primers	1504	0.01364%
```

```text
#filteredReads
#Matched	508	0.00491%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	506	0.00489%
```

* quorum

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bash 2_quorum.sh
bash 9_statQuorum.sh

```

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q20L60 | 262.6 |  232.0 |   11.63% |     139 | "93" | 4.64M | 4.67M |     1.01 | 0:03'02'' |
| Q25L60 | 239.9 |  228.2 |    4.88% |     133 | "83" | 4.64M | 4.57M |     0.99 | 0:02'46'' |
| Q30L60 | 199.8 |  195.4 |    2.16% |     120 | "71" | 4.64M | 4.56M |     0.98 | 0:02'25'' |

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

| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000 |   40.0 |  96.32% |      8937 | 4.43M |  734 |        65 | 100.31K | 1763 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'45'' |
| Q20L60X40P001 |   40.0 |  96.34% |      9212 | 4.42M |  711 |        77 | 113.24K | 1779 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'47'' |
| Q20L60X40P002 |   40.0 |  96.58% |      9445 | 4.45M |  693 |        63 |  95.59K | 1689 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'44'' |
| Q20L60X40P003 |   40.0 |  96.45% |      8961 | 4.44M |  732 |        65 |  99.77K | 1747 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'05'' | 0:00'44'' |
| Q20L60X40P004 |   40.0 |  96.50% |      8653 | 4.44M |  731 |        67 |  99.33K | 1734 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'44'' |
| Q20L60X80P000 |   80.0 |  92.32% |      4424 | 4.23M | 1226 |        50 | 124.32K | 2579 |   75.0 | 5.0 |  20.0 | 135.0 | "31,41,51,61,71,81" | 0:01'47'' | 0:00'42'' |
| Q20L60X80P001 |   80.0 |  92.60% |      4377 | 4.24M | 1233 |        51 | 129.33K | 2606 |   75.0 | 5.0 |  20.0 | 135.0 | "31,41,51,61,71,81" | 0:01'47'' | 0:00'44'' |
| Q25L60X40P000 |   40.0 |  98.38% |     41712 | 4.49M |  201 |       872 |  87.76K |  923 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'05'' | 0:00'53'' |
| Q25L60X40P001 |   40.0 |  98.41% |     44606 | 4.52M |  185 |        53 |  46.11K |  937 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'05'' | 0:00'58'' |
| Q25L60X40P002 |   40.0 |  98.40% |     38797 | 4.51M |  185 |        54 |  48.46K |  978 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'05'' | 0:00'57'' |
| Q25L60X40P003 |   40.0 |  98.42% |     41387 | 4.52M |  195 |        51 |  45.57K |  945 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'53'' |
| Q25L60X40P004 |   40.0 |  98.43% |     44628 | 4.51M |  172 |        61 |  54.26K |  953 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'58'' |
| Q25L60X80P000 |   80.0 |  98.15% |     34719 | 4.51M |  226 |        47 |  36.06K |  834 |   78.0 | 3.0 |  20.0 | 130.5 | "31,41,51,61,71,81" | 0:01'45'' | 0:00'56'' |
| Q25L60X80P001 |   80.0 |  98.14% |     30655 | 4.52M |  242 |        46 |  37.48K |  886 |   78.0 | 3.0 |  20.0 | 130.5 | "31,41,51,61,71,81" | 0:01'45'' | 0:00'53'' |
| Q30L60X40P000 |   40.0 |  98.55% |     41008 |  4.5M |  208 |       889 | 114.97K | 1177 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'56'' |
| Q30L60X40P001 |   40.0 |  98.57% |     35610 |  4.5M |  228 |       868 | 123.16K | 1298 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'55'' |
| Q30L60X40P002 |   40.0 |  98.61% |     40030 | 4.51M |  203 |       586 |  89.29K | 1247 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'03'' | 0:01'01'' |
| Q30L60X40P003 |   40.0 |  98.60% |     41440 |  4.5M |  203 |       720 | 101.52K | 1230 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'57'' |
| Q30L60X80P000 |   80.0 |  98.59% |     48403 | 4.51M |  167 |        90 |  53.15K |  956 |   79.0 | 4.0 |  20.0 | 136.5 | "31,41,51,61,71,81" | 0:01'41'' | 0:01'05'' |
| Q30L60X80P001 |   80.0 |  98.62% |     48080 | 4.51M |  166 |        58 |   48.7K |  954 |   78.0 | 4.0 |  20.0 | 135.0 | "31,41,51,61,71,81" | 0:01'41'' | 0:01'01'' |

| Name          | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q20L60X40P000 |   40.0 |  98.21% |     38595 | 4.52M | 212 |        51 |  51.93K | 1106 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'55'' |
| Q20L60X40P001 |   40.0 |  98.12% |     41727 | 4.52M | 192 |        61 |  61.59K | 1048 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'57'' |
| Q20L60X40P002 |   40.0 |  98.19% |     45022 | 4.52M | 189 |        54 |  47.49K |  963 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'56'' |
| Q20L60X40P003 |   40.0 |  98.17% |     35056 | 4.51M | 210 |        62 |  57.93K | 1034 |   38.0 | 2.0 |  10.7 |  66.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'56'' |
| Q20L60X40P004 |   40.0 |  98.19% |     35146 | 4.52M | 207 |        59 |  57.12K | 1072 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'55'' |
| Q20L60X80P000 |   80.0 |  97.48% |     17232 |  4.5M | 403 |        49 |  54.61K | 1143 |   77.0 | 3.0 |  20.0 | 129.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'49'' |
| Q20L60X80P001 |   80.0 |  97.64% |     19202 | 4.51M | 380 |        51 |  52.46K | 1055 |   77.0 | 3.0 |  20.0 | 129.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'46'' |
| Q25L60X40P000 |   40.0 |  98.53% |     43823 | 4.51M | 171 |        52 |   54.3K | 1084 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'58'' |
| Q25L60X40P001 |   40.0 |  98.56% |     47179 | 4.52M | 174 |        52 |   51.3K | 1085 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'38'' | 0:01'00'' |
| Q25L60X40P002 |   40.0 |  98.54% |     51150 | 4.52M | 171 |        53 |  56.55K | 1112 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'59'' |
| Q25L60X40P003 |   40.0 |  98.51% |     48069 | 4.52M | 175 |        50 |  50.99K | 1075 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'56'' |
| Q25L60X40P004 |   40.0 |  98.56% |     47204 | 4.51M | 164 |        61 |  63.65K | 1099 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'59'' |
| Q25L60X80P000 |   80.0 |  98.52% |     54807 | 4.52M | 159 |        48 |  37.16K |  819 |   78.0 | 3.0 |  20.0 | 130.5 | "31,41,51,61,71,81" | 0:00'47'' | 0:01'02'' |
| Q25L60X80P001 |   80.0 |  98.50% |     55804 | 4.52M | 148 |        46 |  35.29K |  811 |   78.0 | 3.0 |  20.0 | 130.5 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'58'' |
| Q30L60X40P000 |   40.0 |  98.54% |     31579 | 4.52M | 239 |        60 |  73.69K | 1419 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'56'' |
| Q30L60X40P001 |   40.0 |  98.52% |     30813 | 4.49M | 284 |       778 | 153.72K | 1589 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'57'' |
| Q30L60X40P002 |   40.0 |  98.55% |     34010 |  4.5M | 248 |       729 | 117.71K | 1509 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'40'' | 0:01'00'' |
| Q30L60X40P003 |   40.0 |  98.57% |     30990 | 4.52M | 233 |        50 |  70.36K | 1481 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'39'' | 0:00'57'' |
| Q30L60X80P000 |   80.0 |  98.60% |     41887 | 4.51M | 193 |       292 |  67.04K | 1111 |   78.0 | 4.0 |  20.0 | 135.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:01'07'' |
| Q30L60X80P001 |   80.0 |  98.60% |     42232 | 4.51M | 185 |       506 |  68.32K | 1134 |   78.0 | 4.0 |  20.0 | 135.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:01'02'' |

* merge anchors

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bash 6_mergeAnchors.sh 4_kunitigs 6_mergeKunitigsAnchors

bash 6_mergeAnchors.sh 4_tadpole 6_mergeTadpoleAnchors

bash 6_mergeAnchors.sh 6_merge 6_mergeAnchors

# anchor sort on ref
for D in 6_mergeAnchors 6_mergeKunitigsAnchors 6_mergeTadpoleAnchors; do
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

bash 6_anchorLong.sh 6_mergeAnchors/anchor.merge.fasta 5_canu_Xall-trim/${BASE_NAME}.correctedReads.fasta.gz

# false strand
cat 6_anchorLong/group/*.ovlp.tsv \
    | perl -nla -e '/anchor.+long/ or next; print $F[0] if $F[8] == 1;' \
    | sort | uniq -c

bash 6_anchorFill.sh 6_anchorLong/contig.fasta 5_canu_Xall-trim/${BASE_NAME}.contigs.fasta

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

| Name                           |     N50 |     Sum |    # |
|:-------------------------------|--------:|--------:|-----:|
| Genome                         | 4641652 | 4641652 |    1 |
| Paralogs                       |    1934 |  195673 |  106 |
| 6_mergeKunitigsAnchors.anchors |   63594 | 4530920 |  122 |
| 6_mergeKunitigsAnchors.others  |    1061 |  322687 |  282 |
| 6_mergeTadpoleAnchors.anchors  |   67348 | 4531664 |  119 |
| 6_mergeTadpoleAnchors.others   |    1086 |  389480 |  320 |
| 6_mergeAnchors.anchors         |   67348 | 4531664 |  119 |
| 6_mergeAnchors.others          |    1086 |  389480 |  320 |
| anchorLong                     |   80372 | 4324205 |  107 |
| anchorFill                     |  691935 | 4397879 |    9 |
| canu_X40-raw                   | 4674150 | 4674150 |    1 |
| canu_X40-trim                  | 4674046 | 4674046 |    1 |
| canu_X80-raw                   | 4658166 | 4658166 |    1 |
| canu_X80-trim                  | 4657933 | 4657933 |    1 |
| canu_Xall-raw                  | 4670118 | 4670118 |    1 |
| canu_Xall-trim                 | 4670240 | 4670240 |    1 |
| tadpole.Q20L60                 |    5305 | 4566636 | 1548 |
| tadpole.Q25L60                 |   15712 | 4543727 |  626 |
| tadpole.Q30L60                 |   18487 | 4539551 |  546 |
| spades.contig                  |  117644 | 4665739 |  311 |
| spades.scaffold                |  132608 | 4665779 |  307 |
| spades.non-contained           |  125617 | 4585700 |   91 |
| spades.anchor                  |  125552 | 4539555 |   69 |
| megahit.contig                 |   67382 | 4579520 |  205 |
| megahit.non-contained          |   67382 | 4553887 |  124 |
| megahit.anchor                 |   67325 | 4525248 |  114 |
| platanus.contig                |   16464 | 4674383 | 1017 |
| platanus.scaffold              |  133012 | 4574920 |  142 |
| platanus.non-contained         |  133012 | 4556916 |   63 |
| platanus.anchor                |  132960 | 4542760 |   67 |


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

cp ~/data/anchr/paralogs/model/Results/${BASE_NAME}/${BASE_NAME}.multi.fas 1_genome/paralogs.fas
```

* Illumina

    PRJNA340312, SRX2058864

```bash
cd ${HOME}/data/anchr/s288c

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
    --trim2 "--uniq --bbduk" \
    --cov2 "40 80 120 all" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --cov3 "all" \
    --qual3 "trim" \
    --mergereads \
    --ecphase "1,2,3" \
    --parallel 24

```

## s288c: run

```bash
# Illumina QC
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_fastqc" "bash 2_fastqc.sh"
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_kmergenie" "bash 2_kmergenie.sh"

# preprocess Illumina reads
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_trim" "bash 2_trim.sh"

# preprocess PacBio reads
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-3_trimlong" "bash 3_trimlong.sh"

# reads stats
bsub -w "ended(${BASE_NAME}-2_trim) && ended(${BASE_NAME}-3_trimlong)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_statReads" "bash 9_statReads.sh"

# merge reads
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_mergereads" "bash 2_mergereads.sh"

# insert size
bsub -w "done(${BASE_NAME}-2_trim)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_insertSize" "bash 2_insertSize.sh"

# spades and platanus
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

# merge anchors
bsub -w "done(${BASE_NAME}-4_anchors)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-6_mergeAnchors_4_kunitigs" "bash 6_mergeAnchors.sh 4_kunitigs 6_mergeKunitigsAnchors"

bsub -w "done(${BASE_NAME}-4_tadpoleAnchors)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-6_mergeAnchors_4_tadpole" "bash 6_mergeAnchors.sh 4_tadpole 6_mergeTadpoleAnchors"

bsub -w "done(${BASE_NAME}-6_mergeAnchors_4_kunitigs) && done(${BASE_NAME}-6_mergeAnchors_4_tadpole)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-6_mergeAnchors" "bash 6_mergeAnchors.sh 6_mergeAnchors"

# canu
bsub -w "done(${BASE_NAME}-3_trimlong)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-5_canu" "bash 5_canu.sh"
bsub -w "done(${BASE_NAME}-5_canu)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_statCanu" "bash 9_statCanu.sh"

# expand anchors
bsub -w "done(${BASE_NAME}-6_mergeAnchors) && done(${BASE_NAME}-5_canu)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-6_anchorLong" \
    "bash 6_anchorLong.sh 6_mergeAnchors/anchor.merge.fasta 5_canu_Xall-trim/${BASE_NAME}.correctedReads.fasta.gz"

bsub -w "done(${BASE_NAME}-6_anchorLong)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-6_anchorFill" \
    "bash 6_anchorFill.sh 6_anchorLong/contig.fasta 5_canu_Xall-trim/${BASE_NAME}.contigs.fasta"

```

```bash
# stats
bash 9_statFinal.sh

bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_quast" "bash 9_quast.sh"

# false strands of anchorLong
cat 6_anchorLong/group/*.ovlp.tsv \
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

megahit \
    -r merged.fq.gz --12 unmerged.fq.gz \
    --k-min 45 --k-max 225 \
    --k-step 26 --min-count 2 \
    -o megahit_out

anchr contained \
    megahit_out/final.contigs.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin megahit_out/megahit.non-contained.fasta

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
    tadpole_out/tadpole.non-contained.fasta \
    tadpole_out/anchor.merge.fasta \
    ../../1_genome/paralogs.fas \
    --label "spades,megahit,tadpole,tadpoleMerge,paralogs" \
    -o 9_quast_merge

```

| Name      |    N50 |      Sum |        # |
|:----------|-------:|---------:|---------:|
| Genome    | 924431 | 12157105 |       17 |
| Paralogs  |   3851 |  1059148 |      366 |
| Illumina  |    151 |    2.94G | 19464114 |
| uniq      |    151 |    2.78G | 18402464 |
| bbduk     |    150 |    2.71G | 18400866 |
| Q25L60    |    150 |    2.53G | 17386774 |
| Q30L60    |    150 |    2.39G | 16520390 |
| PacBio    |   8412 |  820.96M |   177100 |
| Xall.raw  |   8412 |  820.96M |   177100 |
| Xall.trim |   7829 |  626.41M |   106381 |

```text
#trimmedReads
#Matched	976837	5.30819%
#Name	Reads	ReadsPct
I5_Nextera_Transposase_1	572028	3.10843%
I7_Nextera_Transposase_1	393889	2.14041%
PhiX_read2_adapter	2061	0.01120%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N712	1470	0.00799%
Reverse_adapter	1096	0.00596%
```

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q25L60 | 312.6 |    292 | 146.1 |         42.06% |
| Q30L60 | 311.9 |    292 | 144.8 |         42.97% |

| Name         | N50 |     Sum |        # |
|:-------------|----:|--------:|---------:|
| clumped      | 151 |   2.74G | 18146514 |
| trimmed      | 150 |   2.64G | 17918200 |
| filtered     | 150 |   2.64G | 17916946 |
| ecco         | 150 |   2.64G | 17916946 |
| eccc         | 150 |   2.64G | 17916946 |
| ecct         | 150 |   2.54G | 17197106 |
| extended     | 190 |   3.21G | 17197106 |
| merged       | 356 |   2.36G |  7196431 |
| unmerged.raw | 190 | 521.67M |  2804244 |
| unmerged     | 190 | 454.92M |  2517480 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 211.0 |    221 |  53.2 |         39.66% |
| ihist.merge.txt  | 328.6 |    325 |  95.3 |         83.69% |

```text
#trimmedReads
#Matched	967050	5.32912%
#Name	Reads	ReadsPct
I5_Nextera_Transposase_1	566558	3.12213%
I7_Nextera_Transposase_1	389682	2.14742%
PhiX_read2_adapter	2038	0.01123%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N712	1458	0.00803%
Reverse_adapter	1089	0.00600%
```

```text
#filteredReads
#Matched	698	0.00390%
#Name	Reads	ReadsPct
contam_135	523	0.00292%
contam_159	156	0.00087%
```

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |  RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|-------:|-------:|---------:|----------:|
| Q25L60 | 208.4 |  195.9 |    6.00% |     146 | "105" | 12.16M | 11.85M |     0.97 | 0:05'16'' |
| Q30L60 | 196.3 |  186.9 |    4.82% |     145 | "105" | 12.16M | 11.72M |     0.96 | 0:04'57'' |

| Name           | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  89.25% |     11739 | 10.38M | 1759 |      1040 |    1.3M | 5042 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'22'' | 0:01'39'' |
| Q25L60X40P001  |   40.0 |  89.16% |     10337 | 10.33M | 1907 |      1027 |   1.39M | 5211 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'22'' | 0:01'41'' |
| Q25L60X40P002  |   40.0 |  89.19% |     11205 | 10.41M | 1819 |      1003 |   1.22M | 5121 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'22'' | 0:01'37'' |
| Q25L60X40P003  |   40.0 |  89.14% |     10123 | 10.36M | 1952 |      1004 |    1.3M | 5255 |   35.0 |  3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:02'22'' | 0:01'35'' |
| Q25L60X80P000  |   80.0 |  88.53% |     11401 | 10.49M | 1791 |      1018 |      1M | 4311 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:03'51'' | 0:01'34'' |
| Q25L60X80P001  |   80.0 |  88.41% |     10882 | 10.48M | 1829 |       988 | 993.29K | 4375 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:03'53'' | 0:01'36'' |
| Q25L60X120P000 |  120.0 |  87.79% |     11390 | 10.81M | 1621 |       868 | 510.38K | 3839 |  107.0 | 10.0 |  20.0 | 205.5 | "31,41,51,61,71,81" | 0:05'23'' | 0:01'35'' |
| Q25L60XallP000 |  195.9 |  86.97% |     10360 | 10.91M | 1693 |      1004 | 312.66K | 3766 |  175.0 | 16.0 |  20.0 | 334.5 | "31,41,51,61,71,81" | 0:08'18'' | 0:01'37'' |
| Q30L60X40P000  |   40.0 |  89.52% |     11691 | 10.45M | 1739 |      1013 |   1.17M | 5004 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'24'' | 0:01'41'' |
| Q30L60X40P001  |   40.0 |  89.70% |     11423 | 10.41M | 1806 |      1039 |   1.25M | 4966 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'21'' | 0:01'35'' |
| Q30L60X40P002  |   40.0 |  89.60% |     11422 | 10.43M | 1790 |      1002 |   1.18M | 4996 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'22'' | 0:01'34'' |
| Q30L60X40P003  |   40.0 |  89.31% |     12075 | 10.44M | 1763 |      1011 |   1.21M | 4995 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'21'' | 0:01'38'' |
| Q30L60X80P000  |   80.0 |  88.73% |     12823 | 10.58M | 1620 |      1009 |  918.3K | 4117 |   72.0 |  6.0 |  18.0 | 135.0 | "31,41,51,61,71,81" | 0:03'51'' | 0:01'33'' |
| Q30L60X80P001  |   80.0 |  88.75% |     12399 | 10.57M | 1685 |       978 | 905.09K | 4199 |   72.0 |  6.0 |  18.0 | 135.0 | "31,41,51,61,71,81" | 0:03'52'' | 0:01'37'' |
| Q30L60X120P000 |  120.0 |  88.17% |     12536 | 10.84M | 1557 |       988 | 545.12K | 3757 |  107.0 |  9.0 |  20.0 | 201.0 | "31,41,51,61,71,81" | 0:05'19'' | 0:01'37'' |
| Q30L60XallP000 |  186.9 |  87.58% |     11735 | 10.99M | 1556 |       994 | 305.68K | 3576 |  167.0 | 15.0 |  20.0 | 318.0 | "31,41,51,61,71,81" | 0:07'55'' | 0:01'36'' |

| Name           | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  92.53% |     10942 | 10.43M | 1767 |      1009 |   1.27M | 5465 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'40'' |
| Q25L60X40P001  |   40.0 |  92.45% |     11348 | 10.44M | 1772 |      1016 |   1.23M | 5397 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'16'' | 0:01'40'' |
| Q25L60X40P002  |   40.0 |  92.51% |     10677 | 10.46M | 1772 |      1019 |   1.19M | 5324 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'13'' | 0:01'44'' |
| Q25L60X40P003  |   40.0 |  92.44% |     10521 | 10.49M | 1821 |      1003 |   1.14M | 5452 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'45'' |
| Q25L60X80P000  |   80.0 |  92.91% |     16774 | 10.71M | 1339 |       958 | 948.98K | 4431 |   72.0 |  6.0 |  18.0 | 135.0 | "31,41,51,61,71,81" | 0:01'36'' | 0:01'58'' |
| Q25L60X80P001  |   80.0 |  92.87% |     16621 | 10.74M | 1379 |       832 | 893.26K | 4353 |   72.0 |  6.0 |  18.0 | 135.0 | "31,41,51,61,71,81" | 0:01'36'' | 0:01'52'' |
| Q25L60X120P000 |  120.0 |  92.62% |     16877 | 10.93M | 1202 |       781 | 536.28K | 3696 |  107.0 |  9.0 |  20.0 | 201.0 | "31,41,51,61,71,81" | 0:02'00'' | 0:01'52'' |
| Q25L60XallP000 |  195.9 |  92.10% |     14635 | 11.07M | 1258 |       881 | 308.22K | 3333 |  176.0 | 15.0 |  20.0 | 331.5 | "31,41,51,61,71,81" | 0:02'51'' | 0:01'56'' |
| Q30L60X40P000  |   40.0 |  92.66% |     10609 | 10.48M | 1760 |      1006 |   1.18M | 5376 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'41'' |
| Q30L60X40P001  |   40.0 |  92.64% |     10728 | 10.46M | 1818 |      1031 |    1.2M | 5369 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'14'' | 0:01'45'' |
| Q30L60X40P002  |   40.0 |  92.57% |     10320 | 10.45M | 1833 |       999 |   1.18M | 5452 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'38'' |
| Q30L60X40P003  |   40.0 |  92.56% |     10741 | 10.46M | 1829 |       984 |   1.16M | 5355 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'18'' | 0:01'39'' |
| Q30L60X80P000  |   80.0 |  93.13% |     17680 | 10.75M | 1299 |       933 | 928.12K | 4346 |   72.0 |  6.0 |  18.0 | 135.0 | "31,41,51,61,71,81" | 0:01'36'' | 0:01'51'' |
| Q30L60X80P001  |   80.0 |  93.14% |     17184 | 10.74M | 1339 |       882 | 902.45K | 4469 |   72.0 |  6.0 |  18.0 | 135.0 | "31,41,51,61,71,81" | 0:01'36'' | 0:01'54'' |
| Q30L60X120P000 |  120.0 |  92.93% |     17376 | 10.94M | 1220 |       846 | 593.68K | 3821 |  108.0 |  8.0 |  20.0 | 198.0 | "31,41,51,61,71,81" | 0:02'01'' | 0:01'53'' |
| Q30L60XallP000 |  186.9 |  92.53% |     15955 | 11.07M | 1203 |       947 | 343.29K | 3411 |  168.0 | 13.0 |  20.0 | 310.5 | "31,41,51,61,71,81" | 0:02'49'' | 0:01'55'' |

| Name                |    N50 |      Sum |     # |
|:--------------------|-------:|---------:|------:|
| Genome              | 924431 | 12157105 |    17 |
| Paralogs            |   3851 |  1059148 |   366 |
| Xall.trim.corrected |   7965 |   450.5M | 66099 |
| Xall.trim.contig    | 813374 | 12360766 |    26 |

| Name                           |    N50 |      Sum |    # |
|:-------------------------------|-------:|---------:|-----:|
| Genome                         | 924431 | 12157105 |   17 |
| Paralogs                       |   3851 |  1059148 |  366 |
| 6_mergeKunitigsAnchors.anchors |  34530 | 11448482 |  638 |
| 6_mergeKunitigsAnchors.others  |   1365 |  3884048 | 3081 |
| 6_mergeTadpoleAnchors.anchors  |  30553 | 11326666 |  689 |
| 6_mergeTadpoleAnchors.others   |   1341 |  3206898 | 2581 |
| 6_mergeAnchors.anchors         |  34364 | 11409655 |  637 |
| 6_mergeAnchors.others          |   1365 |  3884048 | 3081 |
| anchorLong                     |  38064 | 11357909 |  544 |
| anchorFill                     | 260276 | 11474414 |   77 |
| canu_Xall-trim                 | 813374 | 12360766 |   26 |
| tadpole.Q25L60                 |   9870 | 11411593 | 3071 |
| tadpole.Q30L60                 |  10639 | 11409404 | 2966 |
| spades.contig                  |  93363 | 11747736 | 1444 |
| spades.scaffold                | 106111 | 11748416 | 1421 |
| spades.non-contained           |  97714 | 11513927 |  261 |
| spades.anchor                  |   8667 | 10755810 | 1788 |
| megahit.contig                 |  43186 | 11625049 | 1020 |
| megahit.non-contained          |  44023 | 11433079 |  521 |
| megahit.anchor                 |   8209 | 10657328 | 1865 |
| platanus.contig                |   7427 | 12170383 | 5342 |
| platanus.scaffold              |  67382 | 11891523 | 3166 |
| platanus.non-contained         |  71428 | 11408032 |  322 |
| platanus.anchor                |   8215 | 10688304 | 1892 |

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
    --trim2 "--uniq " \
    --cov2 "40 50 60 70 80 all" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix" \
    --tadpole \
    --cov3 "all" \
    --qual3 "trim" \
    --mergereads \
    --ecphase "1,3" \
    --parallel 24

```

## iso_1: run

Same as [s288c: run](#s288c-run)

The `meryl` step of `canu` failed in hpcc, run it locally.

| Name      |      N50 |       Sum |         # |
|:----------|---------:|----------:|----------:|
| Genome    | 25286936 | 137567477 |         8 |
| Paralogs  |     4031 |  13665900 |      4492 |
| Illumina  |      101 |    18.12G | 179363706 |
| uniq      |      101 |     17.6G | 174216504 |
| Q25L60    |      101 |    14.66G | 147178220 |
| Q30L60    |      101 |    13.98G | 143634907 |
| PacBio    |    13704 |     5.62G |    630193 |
| Xall.raw  |    13704 |     5.62G |    630193 |
| Xall.trim |    13572 |     5.22G |    541317 |

| Name         | N50 |     Sum |         # |
|:-------------|----:|--------:|----------:|
| clumped      | 101 |  14.38G | 142384532 |
| trimmed      | 100 |  12.85G | 131018227 |
| filtered     | 100 |  12.85G | 130960798 |
| ecco         | 100 |  12.81G | 130960798 |
| ecct         | 100 |  12.47G | 127435144 |
| extended     | 140 |  17.38G | 127435144 |
| merged       | 141 | 484.77M |   3485038 |
| unmerged.raw | 140 |  16.44G | 120465068 |
| unmerged     | 140 |  15.76G | 117634441 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt |  99.9 |    101 |  17.7 |          5.25% |
| ihist.merge.txt  | 139.1 |    141 |  24.7 |          5.47% |

```text
#mergeReads
#Matched	57429	0.04383%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	57383	0.04380%
```

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q25L60 | 250.6 |    230 | 100.2 |         31.50% |
| Q30L60 | 249.4 |    229 |  99.0 |         32.53% |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|--------:|--------:|---------:|----------:|
| Q25L60 | 106.5 |   96.3 |    9.59% |      99 | "71" | 137.57M | 127.12M |     0.92 | 0:26'10'' |
| Q30L60 | 101.7 |   94.2 |    7.45% |      99 | "71" | 137.57M | 126.42M |     0.92 | 0:25'02'' |

```text
#Q25L60
#Matched	140814	0.10575%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	125980	0.09461%
Reverse_adapter	6535	0.00491%
pcr_dimer	5607	0.00421%
PCR_Primers	2430	0.00182%

#Q30L60
#Matched	730797	0.54710%
#Name	Reads	ReadsPct
Reverse_adapter	595234	0.44561%
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	119889	0.08975%
TruSeq_Adapter_Index_5	8089	0.00606%
pcr_dimer	4216	0.00316%
PCR_Primers	1865	0.00140%
RNA_PCR_Primer_Index_5_(RPI5)	792	0.00059%

```

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  82.90% |     14957 | 114.35M | 14224 |      1040 | 4.61M | 51326 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:31'28'' | 0:17'27'' |
| Q25L60X40P001  |   40.0 |  82.84% |     14941 | 114.25M | 14374 |      1051 | 4.67M | 51807 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:31'21'' | 0:17'09'' |
| Q25L60X50P000  |   50.0 |  82.77% |     14261 | 114.59M | 14509 |      1046 | 4.29M | 49100 |   44.0 | 4.0 |  10.7 |  84.0 | "31,41,51,61,71,81" | 0:36'09'' | 0:17'03'' |
| Q25L60X60P000  |   60.0 |  82.43% |     13275 | 114.22M | 15127 |      1050 | 4.62M | 47671 |   53.0 | 4.0 |  13.7 |  97.5 | "31,41,51,61,71,81" | 0:40'40'' | 0:16'24'' |
| Q25L60X70P000  |   70.0 |  82.02% |     12507 | 114.24M | 15736 |      1050 | 4.36M | 47230 |   62.0 | 5.0 |  15.7 | 115.5 | "31,41,51,61,71,81" | 0:44'59'' | 0:16'10'' |
| Q25L60X80P000  |   80.0 |  81.69% |     11745 |  114.2M | 16411 |      1045 | 4.17M | 47043 |   70.0 | 6.0 |  17.3 | 132.0 | "31,41,51,61,71,81" | 0:49'24'' | 0:15'50'' |
| Q25L60XallP000 |   96.3 |  81.18% |     10771 | 113.83M | 17396 |      1041 | 4.27M | 47457 |   85.0 | 7.0 |  21.3 | 159.0 | "31,41,51,61,71,81" | 0:56'34'' | 0:15'26'' |
| Q30L60X40P000  |   40.0 |  82.47% |     14757 | 113.27M | 14905 |      1063 | 5.29M | 51400 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:31'01'' | 0:16'59'' |
| Q30L60X40P001  |   40.0 |  82.47% |     14241 | 113.01M | 15254 |      1074 | 5.49M | 51878 |   35.0 | 3.0 |   8.7 |  66.0 | "31,41,51,61,71,81" | 0:31'37'' | 0:16'30'' |
| Q30L60X50P000  |   50.0 |  82.62% |     14539 | 113.79M | 14750 |      1056 | 4.81M | 50428 |   44.0 | 4.0 |  10.7 |  84.0 | "31,41,51,61,71,81" | 0:36'01'' | 0:17'03'' |
| Q30L60X60P000  |   60.0 |  82.60% |     13966 | 114.02M | 14941 |      1066 | 4.59M | 49558 |   53.0 | 5.0 |  12.7 | 102.0 | "31,41,51,61,71,81" | 0:40'33'' | 0:17'12'' |
| Q30L60X70P000  |   70.0 |  82.45% |     13396 | 114.11M | 15298 |      1062 | 4.41M | 49018 |   61.0 | 6.0 |  14.3 | 118.5 | "31,41,51,61,71,81" | 0:44'42'' | 0:16'59'' |
| Q30L60X80P000  |   80.0 |  82.29% |     12845 | 114.13M | 15660 |      1068 | 4.31M | 48673 |   70.0 | 7.0 |  16.3 | 136.5 | "31,41,51,61,71,81" | 0:49'14'' | 0:17'06'' |
| Q30L60XallP000 |   94.2 |  82.06% |     12191 | 114.05M | 16108 |      1069 | 4.22M | 48331 |   83.0 | 7.0 |  20.7 | 156.0 | "31,41,51,61,71,81" | 0:55'06'' | 0:16'57'' |

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  84.02% |     18977 | 114.11M | 12414 |      1059 | 3.44M | 42351 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:15'10'' | 0:16'18'' |
| Q25L60X40P001  |   40.0 |  83.93% |     18922 | 113.99M | 12679 |      1072 | 3.47M | 42822 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:15'09'' | 0:16'27'' |
| Q25L60X50P000  |   50.0 |  84.28% |     19910 | 114.45M | 11826 |      1059 | 3.74M | 41585 |   44.0 | 4.0 |  10.7 |  84.0 | "31,41,51,61,71,81" | 0:16'34'' | 0:16'59'' |
| Q25L60X60P000  |   60.0 |  84.46% |     20136 | 114.84M | 11632 |      1065 | 3.61M | 40938 |   53.0 | 5.0 |  12.7 | 102.0 | "31,41,51,61,71,81" | 0:18'28'' | 0:17'29'' |
| Q25L60X70P000  |   70.0 |  84.58% |     19963 | 114.81M | 11679 |      1072 | 3.86M | 40495 |   62.0 | 5.0 |  15.7 | 115.5 | "31,41,51,61,71,81" | 0:19'36'' | 0:17'52'' |
| Q25L60X80P000  |   80.0 |  84.55% |     19525 | 114.97M | 11765 |      1073 |  3.7M | 39849 |   71.0 | 6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:20'37'' | 0:17'38'' |
| Q25L60XallP000 |   96.3 |  84.33% |     18616 | 114.99M | 12102 |      1070 | 3.74M | 39701 |   85.0 | 7.0 |  21.3 | 159.0 | "31,41,51,61,71,81" | 0:22'12'' | 0:17'54'' |
| Q30L60X40P000  |   40.0 |  83.42% |     15631 | 112.98M | 14485 |      1055 | 3.78M | 46161 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:14'25'' | 0:15'30'' |
| Q30L60X40P001  |   40.0 |  83.29% |     15127 | 112.65M | 14862 |      1060 | 3.89M | 46742 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:14'33'' | 0:15'00'' |
| Q30L60X50P000  |   50.0 |  83.80% |     16701 | 113.43M | 13695 |      1059 | 4.32M | 45095 |   44.0 | 4.0 |  10.7 |  84.0 | "31,41,51,61,71,81" | 0:16'33'' | 0:16'16'' |
| Q30L60X60P000  |   60.0 |  84.03% |     16965 | 114.19M | 13301 |      1071 | 3.62M | 44595 |   52.0 | 6.0 |  11.3 | 104.0 | "31,41,51,61,71,81" | 0:17'51'' | 0:17'05'' |
| Q30L60X70P000  |   70.0 |  84.13% |     17082 | 114.15M | 13151 |      1065 | 3.99M | 44057 |   61.0 | 6.0 |  14.3 | 118.5 | "31,41,51,61,71,81" | 0:19'10'' | 0:16'59'' |
| Q30L60X80P000  |   80.0 |  84.23% |     17045 | 114.38M | 13163 |      1071 | 3.92M | 43911 |   70.0 | 7.0 |  16.3 | 136.5 | "31,41,51,61,71,81" | 0:20'29'' | 0:17'54'' |
| Q30L60XallP000 |   94.2 |  84.23% |     16934 | 114.53M | 13141 |      1088 |  3.9M | 43698 |   83.0 | 7.0 |  20.7 | 156.0 | "31,41,51,61,71,81" | 0:21'33'' | 0:18'08'' |

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
| 6_mergeKunitigsAnchors.anchors |    30390 | 116413426 |   9012 |
| 6_mergeKunitigsAnchors.others  |     1127 |   9854818 |   7645 |
| 6_mergeTadpoleAnchors.anchors  |    27465 | 116048350 |   9646 |
| 6_mergeTadpoleAnchors.others   |     1132 |   6422796 |   4742 |
| 6_mergeAnchors.anchors         |    30394 | 116384236 |   9010 |
| 6_mergeAnchors.others          |     1127 |   9857282 |   7647 |
| anchorLong                     |    33534 | 113084526 |   7880 |
| anchorFill                     |   259717 | 114600236 |   1848 |
| canu_Xall-trim                 | 18542648 | 151436172 |    598 |
| tadpole.Q25L60                 |     5293 | 117636764 |  56413 |
| tadpole.Q30L60                 |     6462 | 117560164 |  51234 |
| spades.contig                  |   121722 | 135713005 | 120270 |
| spades.scaffold                |   134650 | 135719566 | 119991 |
| spades.non-contained           |   134650 | 121328458 |   3726 |
| platanus.contig                |    11503 | 156820565 | 359399 |
| platanus.scaffold              |   146404 | 129134232 |  71416 |
| platanus.non-contained         |   161200 | 119999445 |   3216 |

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
    --trim2 "--uniq " \
    --cov2 "40 50 60 all" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix" \
    --tadpole \
    --cov3 "all" \
    --qual3 "trim" \
    --mergereads \
    --ecphase "1,3" \
    --parallel 24

```

## n2: run

Same as [s288c: run](#s288c-run)

| Name      |      N50 |       Sum |         # |
|:----------|---------:|----------:|----------:|
| Genome    | 17493829 | 100286401 |         7 |
| Paralogs  |     2013 |   5313653 |      2637 |
| Illumina  |      100 |    11.56G | 115608926 |
| uniq      |      100 |    11.39G | 113889072 |
| Q25L60    |      100 |     9.88G | 101608118 |
| Q30L60    |      100 |     8.87G |  99371914 |
| PacBio    |    16572 |     8.12G |    740776 |
| Xall.raw  |    16572 |     8.12G |    740776 |
| Xall.trim |    16237 |     7.68G |    674732 |

| Name         | N50 |     Sum |        # |
|:-------------|----:|--------:|---------:|
| clumped      | 100 |    9.5G | 94973958 |
| trimmed      | 100 |   5.88G | 61682321 |
| filtered     | 100 |   5.88G | 61682318 |
| ecco         | 100 |   5.86G | 61682318 |
| ecct         | 100 |   5.77G | 60691211 |
| extended     | 140 |   7.94G | 60691211 |
| merged       | 140 | 213.51M |  1583461 |
| unmerged.raw | 140 |   7.53G | 57524288 |
| unmerged     | 140 |   7.33G | 56260270 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt |  97.4 |    100 |  15.0 |          5.03% |
| ihist.merge.txt  | 134.8 |    139 |  27.2 |          5.22% |

```text
#mergeReads
#Matched	3	0.00000%
#Name	Reads	ReadsPct
```

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q25L60 | 212.0 |    204 |  67.6 |         20.04% |
| Q30L60 | 211.3 |    203 |  67.1 |         30.69% |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer |   RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|--------:|-------:|---------:|----------:|
| Q25L60 |  98.5 |   63.6 |   35.44% |      97 | "71" | 100.29M | 98.89M |     0.99 | 0:16'07'' |
| Q30L60 |  88.5 |   73.9 |   16.46% |      91 | "69" | 100.29M | 98.82M |     0.99 | 0:15'07'' |

```text
#Q25L60
#Matched	5070	0.00764%
#Name	Reads	ReadsPct
Reverse_adapter	2814	0.00424%
TruSeq_Universal_Adapter	1637	0.00247%
pcr_dimer	287	0.00043%
PCR_Primers	170	0.00026%

#Q30L60
#Matched	36641	0.04333%
#Name	Reads	ReadsPct
Reverse_adapter	34937	0.04132%
TruSeq_Universal_Adapter	781	0.00092%
TruSeq_Adapter_Index_13	362	0.00043%
pcr_dimer	185	0.00022%
PCR_Primers	111	0.00013%
contam_43	101	0.00012%

```

| Name           | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  91.34% |     11958 | 86.23M | 14044 |      2267 | 9.91M | 58305 |   31.0 | 3.0 |   7.3 |  60.0 | "31,41,51,61,71,81" | 0:26'14'' | 0:19'50'' |
| Q25L60X50P000  |   50.0 |  91.54% |     12181 | 86.98M | 13637 |      2893 | 9.63M | 55769 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:30'43'' | 0:20'21'' |
| Q25L60X60P000  |   60.0 |  91.65% |     12322 | 87.28M | 13353 |      2847 | 9.27M | 52058 |   44.0 | 5.0 |   9.7 |  88.0 | "31,41,51,61,71,81" | 0:34'08'' | 0:20'19'' |
| Q25L60XallP000 |   63.6 |  91.65% |     12247 | 87.55M | 13348 |      3198 | 8.97M | 50737 |   46.0 | 6.0 |   9.3 |  92.0 | "31,41,51,61,71,81" | 0:35'25'' | 0:20'13'' |
| Q30L60X40P000  |   40.0 |  91.68% |     11897 |  86.2M | 14361 |      3714 | 9.86M | 60337 |   31.0 | 3.0 |   7.3 |  60.0 | "31,41,51,61,71,81" | 0:24'34'' | 0:20'11'' |
| Q30L60X50P000  |   50.0 |  91.98% |     12379 | 87.13M | 13800 |      4564 | 9.36M | 58518 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:28'37'' | 0:20'45'' |
| Q30L60X60P000  |   60.0 |  92.20% |     12705 | 87.57M | 13388 |      4678 | 9.06M | 56084 |   45.0 | 5.0 |  10.0 |  90.0 | "31,41,51,61,71,81" | 0:31'59'' | 0:21'20'' |
| Q30L60XallP000 |   73.9 |  92.28% |     12886 | 87.74M | 13054 |      3907 | 9.03M | 52387 |   54.0 | 6.0 |  12.0 | 108.0 | "31,41,51,61,71,81" | 0:36'17'' | 0:21'37'' |

| Name           | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  91.78% |     12045 | 84.87M | 14284 |      5330 | 8.95M | 58906 |   31.0 | 3.0 |   7.3 |  60.0 | "31,41,51,61,71,81" | 0:13'58'' | 0:19'52'' |
| Q25L60X50P000  |   50.0 |  92.22% |     12861 | 86.29M | 13818 |      5715 | 8.68M | 56427 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:16'50'' | 0:20'29'' |
| Q25L60X60P000  |   60.0 |  92.49% |     13451 | 86.96M | 13268 |      6113 | 8.68M | 55519 |   44.0 | 5.0 |   9.7 |  88.0 | "31,41,51,61,71,81" | 0:18'52'' | 0:21'01'' |
| Q25L60XallP000 |   63.6 |  92.58% |     13615 | 86.93M | 13120 |      4621 |  9.1M | 55146 |   47.0 | 5.0 |  10.7 |  93.0 | "31,41,51,61,71,81" | 0:19'41'' | 0:21'01'' |
| Q30L60X40P000  |   40.0 |  91.85% |     11046 | 84.53M | 15108 |      9687 | 9.04M | 63150 |   31.0 | 3.0 |   7.3 |  60.0 | "31,41,51,61,71,81" | 0:12'59'' | 0:19'20'' |
| Q30L60X50P000  |   50.0 |  92.40% |     12068 | 85.93M | 14366 |      8660 | 8.42M | 59593 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:15'25'' | 0:20'52'' |
| Q30L60X60P000  |   60.0 |  92.72% |     12807 |  86.8M | 13886 |      8717 | 8.21M | 57737 |   45.0 | 5.0 |  10.0 |  90.0 | "31,41,51,61,71,81" | 0:17'04'' | 0:21'10'' |
| Q30L60XallP000 |   73.9 |  92.94% |     13282 | 87.33M | 13405 |      6777 |  8.5M | 56581 |   54.0 | 6.0 |  12.0 | 108.0 | "31,41,51,61,71,81" | 0:19'14'' | 0:21'21'' |

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
| 6_mergeKunitigsAnchors.anchors |    15811 |  89139396 |  11853 |
| 6_mergeKunitigsAnchors.others  |     1787 |  15007816 |   7856 |
| 6_mergeTadpoleAnchors.anchors  |    14363 |  88269361 |  12921 |
| 6_mergeTadpoleAnchors.others   |     1900 |  11067762 |   5541 |
| 6_mergeAnchors.anchors         |    15811 |  89154553 |  11852 |
| 6_mergeAnchors.others          |     1785 |  15017242 |   7867 |
| anchorLong                     |    18950 |  88201923 |   9790 |
| anchorFill                     |   294121 |  94583312 |    705 |
| canu_Xall-trim                 |  2859614 | 107313895 |    109 |
| tadpole.Q25L60                 |     3829 |  94574682 |  69660 |
| tadpole.Q30L60                 |     4262 |  94454906 |  67082 |
| spades.contig                  |    29569 | 105888001 |  61628 |
| spades.scaffold                |    30934 | 105896000 |  61340 |
| spades.non-contained           |    33028 |  97916802 |   7046 |
| platanus.contig                |     9540 | 108908253 | 143264 |
| platanus.scaffold              |    28158 |  99589056 |  35182 |
| platanus.non-contained         |    30510 |  94099392 |   7644 |

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
    --trim2 "--uniq " \
    --cov2 "40 50 60 all" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix" \
    --tadpole \
    --cov3 "all" \
    --qual3 "trim" \
    --mergereads \
    --ecphase "1,3" \
    --parallel 24

```

## col_0: run

Same as [s288c: run](#s288c-run)

| Name      |      N50 |       Sum |        # |
|:----------|---------:|----------:|---------:|
| Genome    | 23459830 | 119667750 |        7 |
| Paralogs  |     2007 |  16447809 |     8055 |
| Illumina  |      301 |    15.53G | 53786130 |
| uniq      |      301 |    15.53G | 53779068 |
| Q25L60    |      259 |    11.82G | 49650904 |
| Q30L60    |      239 |    10.37G | 48122656 |
| PacBio    |     6754 |    18.77G |  5721958 |
| Xall.raw  |     6754 |    18.77G |  5721958 |
| Xall.trim |     7329 |     7.72G |  1353993 |

| Name         | N50 |     Sum |        # |
|:-------------|----:|--------:|---------:|
| clumped      | 301 |  15.52G | 53765032 |
| trimmed      | 275 |  13.39G | 52866400 |
| filtered     | 275 |  13.39G | 52866138 |
| ecco         | 275 |  13.39G | 52866138 |
| ecct         | 280 |  10.93G | 42173004 |
| extended     | 318 |  12.57G | 42173004 |
| merged       | 412 |   8.02G | 20179591 |
| unmerged.raw | 288 | 441.09M |  1813822 |
| unmerged     | 242 | 280.69M |  1399470 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 335.8 |    334 |  86.2 |         64.84% |
| ihist.merge.txt  | 397.7 |    387 | 104.6 |         95.70% |

```text
#mergeReads
#Matched	131	0.00025%
#Name	Reads	ReadsPct
```

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q25L60 | 316.8 |    297 | 103.9 |         20.08% |
| Q30L60 | 331.0 |    313 | 106.6 |         29.29% |

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|--------:|--------:|---------:|----------:|
| Q25L60 |  98.8 |   70.4 |   28.72% |     236 | "127" | 119.67M | 125.48M |     1.05 | 0:20'20'' |
| Q30L60 |  86.7 |   73.0 |   15.82% |     218 | "127" | 119.67M | 119.23M |     1.00 | 0:17'47'' |

```text
#Q25L60
#Matched	73079	0.20887%
#Name	Reads	ReadsPct
Reverse_adapter	38707	0.11063%
TruSeq_Universal_Adapter	31754	0.09076%
pcr_dimer	1152	0.00329%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	646	0.00185%
PCR_Primers	655	0.00187%

#Q30L60
#Matched	61247	0.15138%
#Name	Reads	ReadsPct
Reverse_adapter	43719	0.10806%
TruSeq_Universal_Adapter	15943	0.03940%
pcr_dimer	628	0.00155%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	463	0.00114%
PCR_Primers	371	0.00092%

```

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  68.87% |     17775 |  105.1M | 11718 |       656 | 3.76M | 30549 |   27.0 | 2.0 |   7.0 |  49.5 | "31,41,51,61,71,81" | 0:36'05'' | 0:12'08'' |
| Q25L60X50P000  |   50.0 |  68.74% |     16539 | 104.67M | 12178 |       593 | 4.29M | 32124 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:42'02'' | 0:12'13'' |
| Q25L60X60P000  |   60.0 |  68.69% |     15619 | 105.25M | 12358 |       126 | 3.51M | 33567 |   41.0 | 3.0 |  10.7 |  75.0 | "31,41,51,61,71,81" | 0:47'43'' | 0:12'49'' |
| Q25L60XallP000 |   70.4 |  68.70% |     14607 | 104.93M | 12998 |       178 | 3.99M | 35925 |   48.0 | 3.0 |  13.0 |  85.5 | "31,41,51,61,71,81" | 0:53'59'' | 0:13'20'' |
| Q30L60X40P000  |   40.0 |  73.87% |     21826 | 105.59M | 10313 |       778 | 3.63M | 28898 |   29.0 | 2.0 |   7.7 |  52.5 | "31,41,51,61,71,81" | 0:34'52'' | 0:12'53'' |
| Q30L60X50P000  |   50.0 |  73.72% |     22015 | 106.24M |  9970 |       436 | 2.76M | 28142 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:40'35'' | 0:13'05'' |
| Q30L60X60P000  |   60.0 |  73.58% |     21622 |    106M | 10014 |       436 | 3.07M | 28169 |   44.0 | 3.0 |  11.7 |  79.5 | "31,41,51,61,71,81" | 0:46'27'' | 0:13'20'' |
| Q30L60XallP000 |   73.0 |  73.32% |     21082 | 106.02M | 10122 |       611 | 3.15M | 28371 |   53.0 | 3.0 |  14.7 |  93.0 | "31,41,51,61,71,81" | 0:53'49'' | 0:13'38'' |

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  80.58% |     21614 | 105.67M | 10375 |       913 | 3.87M | 28981 |   27.0 | 2.0 |   7.0 |  49.5 | "31,41,51,61,71,81" | 0:16'09'' | 0:12'46'' |
| Q25L60X50P000  |   50.0 |  80.48% |     22787 | 106.26M |  9668 |       711 | 3.06M | 26943 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:18'01'' | 0:12'43'' |
| Q25L60X60P000  |   60.0 |  80.35% |     22608 | 106.15M |  9689 |       894 | 3.18M | 26146 |   41.0 | 3.0 |  10.7 |  75.0 | "31,41,51,61,71,81" | 0:19'12'' | 0:12'38'' |
| Q25L60XallP000 |   70.4 |  80.21% |     22287 | 106.39M |  9736 |      1004 | 2.84M | 25468 |   48.0 | 4.0 |  12.0 |  90.0 | "31,41,51,61,71,81" | 0:21'14'' | 0:12'22'' |
| Q30L60X40P000  |   40.0 |  84.72% |     21186 | 105.74M | 10440 |       866 | 3.92M | 31291 |   29.0 | 2.0 |   7.7 |  52.5 | "31,41,51,61,71,81" | 0:15'40'' | 0:13'33'' |
| Q30L60X50P000  |   50.0 |  84.61% |     22644 | 106.48M |  9767 |       747 | 2.87M | 28827 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:17'19'' | 0:13'29'' |
| Q30L60X60P000  |   60.0 |  84.55% |     23437 | 106.31M |  9539 |       803 | 3.08M | 27626 |   44.0 | 3.0 |  11.7 |  79.5 | "31,41,51,61,71,81" | 0:18'59'' | 0:13'31'' |
| Q30L60XallP000 |   73.0 |  84.34% |     24196 | 106.52M |  9347 |      1010 | 3.14M | 26374 |   53.0 | 3.0 |  14.7 |  93.0 | "31,41,51,61,71,81" | 0:20'07'' | 0:13'35'' |

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
| 6_mergeKunitigsAnchors.anchors |    28409 | 107331614 |   8446 |
| 6_mergeKunitigsAnchors.others  |     1164 |   4955968 |   3946 |
| 6_mergeTadpoleAnchors.anchors  |    26654 | 107219476 |   8761 |
| 6_mergeTadpoleAnchors.others   |     1176 |   3428208 |   2662 |
| 6_mergeAnchors.anchors         |    28424 | 107388211 |   8446 |
| 6_mergeAnchors.others          |     1165 |   4962513 |   3951 |
| anchorLong                     |    29412 | 107225252 |   8195 |
| anchorFill                     |  1133885 | 109053104 |    542 |
| canu_Xall-trim                 |  5997654 | 121555181 |    265 |
| tadpole.Q25L60                 |     4504 | 109047255 |  95504 |
| tadpole.Q30L60                 |     5155 | 107884344 |  87761 |
| spades.contig                  |    57805 | 156418066 | 160037 |
| spades.scaffold                |    63103 | 156421332 | 159868 |
| spades.non-contained           |   105827 | 115376936 |   4482 |
| platanus.contig                |    15019 | 139807772 | 106870 |
| platanus.scaffold              |   192019 | 128497152 |  67429 |
| platanus.non-contained         |   217851 | 116431399 |   2050 |

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

* Illumina HiSeq (100 bp)

    [SRX202246](https://www.ncbi.nlm.nih.gov/sra/SRX202246[accn])

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
QUEUE_NAME=mpi

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 119667750 \
    --is_euk \
    --trim2 "--uniq " \
    --cov2 "40 50 60 all" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix" \
    --tadpole \
    --mergereads \
    --ecphase "1,3" \
    --parallel 24

```

## col_0H: run

Same as [s288c: run](#s288c-run)

| Name     |      N50 |       Sum |         # |
|:---------|---------:|----------:|----------:|
| Genome   | 23459830 | 119667750 |         7 |
| Paralogs |     2007 |  16447809 |      8055 |
| Illumina |      100 |    14.95G | 149486290 |
| uniq     |      100 |    14.46G | 144631354 |
| Q25L60   |      100 |    12.01G | 122626250 |
| Q30L60   |      100 |    11.24G | 117469136 |

| Name         | N50 |    Sum |         # |
|:-------------|----:|-------:|----------:|
| clumped      | 100 | 11.52G | 115177851 |
| trimmed      | 100 | 10.87G | 111620596 |
| filtered     | 100 | 10.87G | 111620593 |
| ecco         | 100 | 10.84G | 111620592 |
| ecct         | 100 |   8.7G |  89335918 |
| extended     | 140 |    12G |  89335918 |
| merged       | 140 | 286.7M |   2112068 |
| unmerged.raw | 140 | 11.45G |  85111782 |
| unmerged     | 140 | 10.83G |  82264046 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt |  99.9 |    100 |  17.9 |          4.23% |
| ihist.merge.txt  | 135.7 |    139 |  25.5 |          4.73% |

```text
#mergeReads
#Matched	3	0.00000%
#Name	Reads	ReadsPct
```

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q25L60 | 461.9 |    463 |  25.7 |         22.08% |
| Q30L60 | 461.9 |    463 |  38.9 |         23.16% |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|--------:|--------:|---------:|----------:|
| Q25L60 | 100.3 |   83.4 |   16.84% |      98 | "71" | 119.67M | 265.15M |     2.22 | 0:23'16'' |
| Q30L60 |  94.1 |   79.3 |   15.68% |      96 | "71" | 119.67M | 246.49M |     2.06 | 0:23'20'' |

```text
#Q25L60
#Matched	76	0.00007%
#Name	Reads	ReadsPct

#Q30L60
#Matched	77	0.00008%
#Name	Reads	ReadsPct

```

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |     # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|-------:|------:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  70.18% |     11850 | 104.74M | 15887 |      1070 |  6.01M | 60680 |   25.0 |  2.0 |   6.3 |  46.5 | "31,41,51,61,71,81" | 0:30'18'' | 0:15'41'' |
| Q25L60X40P001  |   40.0 |  70.27% |     12069 | 104.99M | 15706 |      1052 |   5.3M | 59987 |   25.0 |  2.0 |   6.3 |  46.5 | "31,41,51,61,71,81" | 0:30'17'' | 0:16'14'' |
| Q25L60X50P000  |   50.0 |  70.80% |     12319 |  105.6M | 15351 |      1209 |  9.39M | 61357 |   31.0 |  2.0 |   8.3 |  55.5 | "31,41,51,61,71,81" | 0:35'54'' | 0:16'53'' |
| Q25L60X60P000  |   60.0 |  71.33% |     12634 | 106.72M | 15084 |      1322 | 13.13M | 62537 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:40'58'' | 0:17'22'' |
| Q25L60XallP000 |   83.4 |  71.87% |     12411 | 113.03M | 17457 |      1336 | 21.32M | 66822 |   46.0 | 10.0 |   5.3 |  92.0 | "31,41,51,61,71,81" | 0:52'22'' | 0:18'43'' |
| Q30L60X40P000  |   40.0 |  70.89% |     10844 | 104.09M | 16877 |      1034 |     5M | 61719 |   25.0 |  2.0 |   6.3 |  46.5 | "31,41,51,61,71,81" | 0:29'03'' | 0:15'17'' |
| Q30L60X50P000  |   50.0 |  71.56% |     11591 | 105.05M | 16051 |      1114 |  7.07M | 61433 |   32.0 |  2.0 |   8.7 |  57.0 | "31,41,51,61,71,81" | 0:34'39'' | 0:16'25'' |
| Q30L60X60P000  |   60.0 |  72.15% |     12051 | 105.85M | 15542 |      1241 | 10.09M | 61945 |   38.0 |  3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:39'19'' | 0:16'39'' |
| Q30L60XallP000 |   79.3 |  72.63% |     12485 | 107.17M | 15324 |      1420 | 19.07M | 64671 |   48.0 |  6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 0:48'29'' | 0:17'03'' |

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  78.68% |     10482 | 102.43M | 17080 |      1009 |  4.09M | 65532 |   25.0 | 2.0 |   6.3 |  46.5 | "31,41,51,61,71,81" | 0:13'30'' | 0:16'17'' |
| Q25L60X40P001  |   40.0 |  78.65% |     10843 | 102.04M | 16725 |      1013 |  5.26M | 64596 |   25.0 | 1.0 |   7.3 |  42.0 | "31,41,51,61,71,81" | 0:13'40'' | 0:15'31'' |
| Q25L60X50P000  |   50.0 |  79.32% |     11703 | 103.56M | 15900 |      1033 |  5.02M | 60948 |   31.0 | 2.0 |   8.3 |  55.5 | "31,41,51,61,71,81" | 0:15'54'' | 0:16'29'' |
| Q25L60X60P000  |   60.0 |  79.73% |     12414 | 105.04M | 15539 |      1081 |  5.82M | 59687 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:18'05'' | 0:16'28'' |
| Q25L60XallP000 |   83.4 |  80.54% |     13391 | 106.62M | 14647 |      1322 | 11.27M | 60970 |   51.0 | 4.0 |  13.0 |  94.5 | "31,41,51,61,71,81" | 0:21'47'' | 0:18'22'' |
| Q30L60X40P000  |   40.0 |  79.60% |      9038 | 101.67M | 18698 |      1004 |  3.83M | 68325 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:12'42'' | 0:15'40'' |
| Q30L60X50P000  |   50.0 |  80.43% |     10106 | 102.89M | 17281 |      1014 |  4.23M | 63710 |   32.0 | 2.0 |   8.7 |  57.0 | "31,41,51,61,71,81" | 0:15'31'' | 0:15'47'' |
| Q30L60X60P000  |   60.0 |  80.68% |     10868 | 104.32M | 16767 |      1031 |  4.54M | 62190 |   38.0 | 3.0 |   9.7 |  70.5 | "31,41,51,61,71,81" | 0:17'34'' | 0:16'51'' |
| Q30L60XallP000 |   79.3 |  81.12% |     11721 | 105.45M | 15952 |      1178 |  8.15M | 62672 |   50.0 | 3.0 |  13.7 |  88.5 | "31,41,51,61,71,81" | 0:21'01'' | 0:16'44'' |

| Name                           |      N50 |       Sum |      # |
|:-------------------------------|---------:|----------:|-------:|
| Genome                         | 23459830 | 119667750 |      7 |
| Paralogs                       |     2007 |  16447809 |   8055 |
| 6_mergeKunitigsAnchors.anchors |    15195 | 113687485 |  15834 |
| 6_mergeKunitigsAnchors.others  |     1429 |  41928088 |  28521 |
| 6_mergeTadpoleAnchors.anchors  |    14344 | 107225816 |  14215 |
| 6_mergeTadpoleAnchors.others   |     1274 |  16486285 |  12024 |
| 6_mergeAnchors.anchors         |    15194 | 113662041 |  15836 |
| 6_mergeAnchors.others          |     1429 |  41928781 |  28522 |
| tadpole.Q25L60                 |      494 | 229360793 | 620292 |
| tadpole.Q30L60                 |      621 | 197877120 | 519373 |
| spades.contig                  |     3091 | 373749865 | 472923 |
| spades.scaffold                |     5722 | 378736969 | 400070 |
| spades.non-contained           |    10816 | 245747265 |  50159 |
| platanus.contig                |     7440 | 133566256 | 263122 |
| platanus.scaffold              |    70787 | 118884363 |  11095 |
| platanus.non-contained         |    73333 | 116313252 |   4485 |
