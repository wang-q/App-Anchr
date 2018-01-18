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
    --ecphase "1,2,3" \
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

* mergereads

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bash 2_mergereads.sh

```

Table: statMergeReads

| Name           | N50 |    Sum |        # |
|:---------------|----:|-------:|---------:|
| clumped        | 151 |  1.73G | 11439000 |
| filteredbytile | 151 |  1.67G | 11072140 |
| trimmed        | 149 |  1.43G | 10389462 |
| filtered       | 149 |  1.43G | 10388954 |
| ecco           | 149 |  1.43G | 10388954 |
| eccc           | 149 |  1.43G | 10388954 |
| ecct           | 149 |  1.42G | 10334246 |
| extended       | 189 |  1.83G | 10334246 |
| merged         | 339 |  1.72G |  5098024 |
| unmerged.raw   | 174 | 20.11M |   138198 |
| unmerged       | 164 | 14.45M |   101916 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 271.6 |    277 |  23.9 |         10.84% |
| ihist.merge.txt  | 337.7 |    338 |  19.3 |         98.66% |

```text
#trimmedReads
#Matched        18810   0.16989%
#Name   Reads   ReadsPct
pcr_dimer       8414    0.07599%
PCR_Primers     1501    0.01356%
```

```text
#filteredReads
#Matched        508     0.00489%
#Name   Reads   ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome  506     0.00487%
```

* quorum

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bash 2_quorum.sh
bash 9_statQuorum.sh

```

Table: statQuorum

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

Table: statKunitigsAnchors.md

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

Table: statTadpoleAnchors.md

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
| MRX40P000 |   40.0 |  97.54% |     57732 |  4.5M | 134 |       137 |  46.1K | 341 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'23'' | 0:00'48'' |
| MRX40P001 |   40.0 |  97.44% |     57663 |  4.5M | 141 |       126 | 45.04K | 358 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'46'' |
| MRX40P002 |   40.0 |  97.48% |     56056 |  4.5M | 138 |       137 | 47.15K | 351 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'50'' |
| MRX40P003 |   40.0 |  97.39% |     51128 | 4.49M | 151 |       138 | 48.73K | 364 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'48'' |
| MRX40P004 |   40.0 |  97.45% |     58599 |  4.5M | 139 |       121 | 43.32K | 353 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'23'' | 0:00'48'' |
| MRX40P005 |   40.0 |  97.40% |     53564 |  4.5M | 145 |       129 | 43.79K | 351 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'23'' | 0:00'48'' |
| MRX40P006 |   40.0 |  97.41% |     54664 | 4.49M | 153 |       135 | 49.66K | 371 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'23'' | 0:00'49'' |
| MRX40P007 |   40.0 |  97.44% |     58561 |  4.5M | 141 |       132 |  46.2K | 350 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'23'' | 0:00'49'' |
| MRX40P008 |   40.0 |  97.51% |     57622 |  4.5M | 135 |       123 | 40.97K | 341 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'49'' |
| MRX80P000 |   80.0 |  97.25% |     43690 |  4.5M | 175 |       103 |  42.2K | 414 |   78.0 | 2.0 |  20.0 | 126.0 | "31,41,51,61,71,81" | 0:02'20'' | 0:00'45'' |
| MRX80P001 |   80.0 |  97.20% |     38945 |  4.5M | 178 |       106 | 42.28K | 416 |   78.0 | 2.0 |  20.0 | 126.0 | "31,41,51,61,71,81" | 0:02'21'' | 0:00'51'' |
| MRX80P002 |   80.0 |  97.21% |     43096 |  4.5M | 170 |        96 | 38.82K | 398 |   78.0 | 3.0 |  20.0 | 130.5 | "31,41,51,61,71,81" | 0:02'21'' | 0:00'48'' |
| MRX80P003 |   80.0 |  97.22% |     43684 |  4.5M | 176 |       102 | 41.17K | 415 |   78.0 | 3.0 |  20.0 | 130.5 | "31,41,51,61,71,81" | 0:02'21'' | 0:00'49'' |

Table: statMRTadpoleAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  97.48% |     78423 |  4.5M | 112 |       147 | 32.96K | 234 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'47'' |
| MRX40P001 |   40.0 |  97.41% |     73491 |  4.5M | 118 |       129 | 33.73K | 252 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'47'' |
| MRX40P002 |   40.0 |  97.42% |     63527 |  4.5M | 118 |       145 | 34.34K | 247 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'43'' |
| MRX40P003 |   40.0 |  97.40% |     67237 |  4.5M | 121 |       165 |  38.6K | 260 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'44'' |
| MRX40P004 |   40.0 |  97.41% |     67132 | 4.51M | 118 |       126 | 32.02K | 254 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'43'' |
| MRX40P005 |   40.0 |  97.43% |     63047 |  4.5M | 120 |       136 |  34.8K | 255 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'47'' |
| MRX40P006 |   40.0 |  97.42% |     63047 |  4.5M | 118 |       136 | 35.96K | 260 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'47'' | 0:00'45'' |
| MRX40P007 |   40.0 |  97.44% |     67169 |  4.5M | 114 |       140 | 37.29K | 268 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'47'' |
| MRX40P008 |   40.0 |  97.45% |     65270 |  4.5M | 116 |       138 | 32.39K | 244 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'44'' |
| MRX80P000 |   80.0 |  97.41% |     61017 | 4.51M | 119 |       104 | 27.56K | 254 |   78.0 | 2.0 |  20.0 | 126.0 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'47'' |
| MRX80P001 |   80.0 |  97.33% |     60737 | 4.51M | 126 |       110 | 29.68K | 266 |   78.0 | 2.0 |  20.0 | 126.0 | "31,41,51,61,71,81" | 0:00'59'' | 0:00'44'' |
| MRX80P002 |   80.0 |  97.34% |     59557 | 4.51M | 124 |       103 | 27.73K | 256 |   78.0 | 2.5 |  20.0 | 128.2 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'47'' |
| MRX80P003 |   80.0 |  97.33% |     60755 | 4.51M | 126 |       102 | 28.54K | 267 |   78.0 | 3.0 |  20.0 | 130.5 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'46'' |

* merge anchors

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bash 7_mergeAnchors.sh 4_kunitigs 7_mergeKunitigsAnchors

bash 7_mergeAnchors.sh 4_tadpole 7_mergeTadpoleAnchors

bash 7_mergeAnchors.sh 6_kunitigs 7_mergeMRKunitigsAnchors

bash 7_mergeAnchors.sh 6_tadpole 7_mergeMRTadpoleAnchors

bash 7_mergeAnchors.sh 7_merge 7_mergeAnchors

# anchor sort on ref
for D in 7_mergeAnchors 7_mergeKunitigsAnchors 7_mergeTadpoleAnchors 7_mergeMRKunitigsAnchors 7_mergeMRTadpoleAnchors; do
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
| 7_mergeKunitigsAnchors.anchors   |   63594 | 4530920 |  122 |
| 7_mergeKunitigsAnchors.others    |    1061 |  322687 |  282 |
| 7_mergeTadpoleAnchors.anchors    |   65398 | 4531452 |  124 |
| 7_mergeTadpoleAnchors.others     |    1236 |  173271 |  138 |
| 7_mergeMRKunitigsAnchors.anchors |   78535 | 4518654 |  107 |
| 7_mergeMRKunitigsAnchors.others  |    1096 |   36919 |   35 |
| 7_mergeMRTadpoleAnchors.anchors  |   82718 | 4519277 |  105 |
| 7_mergeMRTadpoleAnchors.others   |    1188 |   29721 |   27 |
| 7_mergeAnchors.anchors           |   82795 | 4531183 |  108 |
| 7_mergeAnchors.others            |    1084 |  396788 |  328 |
| anchorLong                       |   95462 | 4529892 |  100 |
| anchorFill                       |  868043 | 4602824 |    9 |
| canu_X40-raw                     | 4674150 | 4674150 |    1 |
| canu_X40-trim                    | 4674046 | 4674046 |    1 |
| canu_X80-raw                     | 4658166 | 4658166 |    1 |
| canu_X80-trim                    | 4657933 | 4657933 |    1 |
| canu_Xall-raw                    | 4670118 | 4670118 |    1 |
| canu_Xall-trim                   | 4670240 | 4670240 |    1 |
| tadpole.Q20L60                   |    5305 | 4566636 | 1548 |
| tadpole.Q25L60                   |   15712 | 4543727 |  626 |
| tadpole.Q30L60                   |   18487 | 4539551 |  546 |
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
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_mergereads" "bash 2_mergereads.sh"

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
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_statAnchors_6_kunitigs" "bash 9_statAnchors.sh 6_kunitigs statMRKunitigsAnchors.md"

bsub -w "done(${BASE_NAME}-6_downSampling)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-6_tadpole" "bash 6_tadpole.sh"
bsub -w "done(${BASE_NAME}-6_kunitigs)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-6_tadpoleAnchors" "bash 6_tadpoleAnchors.sh"
bsub -w "done(${BASE_NAME}-6_tadpoleAnchors)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_statAnchors_6_tadpole" "bash 9_statAnchors.sh 6_tadpole statMRTadpoleAnchors.md"

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
| genome.bbtools  | 356.5 |    320 | 484.3 |                         45.78% |
| tadpole.bbtools | 339.2 |    309 | 144.5 |                         43.32% |
| genome.picard   | 352.1 |    322 | 142.5 |                             FR |
| tadpole.picard  | 342.9 |    313 | 141.3 |                             FR |


Table: statReads

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


Table: statMergeReads

| Name         | N50 |     Sum |        # |
|:-------------|----:|--------:|---------:|
| clumped      | 151 |   2.78G | 18397208 |
| trimmed      | 150 |   2.68G | 18163836 |
| filtered     | 150 |   2.68G | 18162546 |
| ecco         | 150 |   2.68G | 18162546 |
| eccc         | 150 |   2.68G | 18162546 |
| ecct         | 150 |   2.57G | 17440794 |
| extended     | 190 |   3.26G | 17440794 |
| merged       | 356 |    2.4G |  7300718 |
| unmerged.raw | 190 | 528.22M |  2839358 |
| unmerged     | 190 | 460.13M |  2547790 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 211.1 |    221 |  53.2 |         39.59% |
| ihist.merge.txt  | 328.8 |    326 |  95.2 |         83.72% |

```text
#trimmedReads
#Matched	976734	5.30914%
#Name	Reads	ReadsPct
I5_Nextera_Transposase_1	571978	3.10905%
I7_Nextera_Transposase_1	393836	2.14074%
PhiX_read2_adapter	2061	0.01120%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N712	1470	0.00799%
Reverse_adapter	1096	0.00596%
```

```text
#filteredReads
#Matched	716	0.00394%
#Name	Reads	ReadsPct
contam_135	539	0.00297%
contam_159	158	0.00087%
```


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |  RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|-------:|-------:|---------:|----------:|
| Q25L60 | 208.4 |  195.9 |    6.00% |     146 | "105" | 12.16M | 11.85M |     0.97 | 0:06'00'' |
| Q30L60 | 196.3 |  186.9 |    4.82% |     145 | "105" | 12.16M | 11.72M |     0.96 | 0:04'58'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  89.07% |     11369 | 10.38M | 1851 |      1016 |   1.25M | 5102 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'23'' | 0:01'38'' |
| Q25L60X40P001  |   40.0 |  88.97% |     11119 | 10.39M | 1837 |      1013 |   1.25M | 5022 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'22'' | 0:01'36'' |
| Q25L60X40P002  |   40.0 |  89.12% |     10768 | 10.41M | 1872 |      1011 |   1.24M | 5106 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'23'' | 0:01'38'' |
| Q25L60X40P003  |   40.0 |  89.27% |     10615 | 10.37M | 1862 |      1016 |   1.29M | 5108 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'22'' | 0:01'35'' |
| Q25L60X80P000  |   80.0 |  88.32% |     11235 | 10.45M | 1842 |      1016 |   1.05M | 4362 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:03'58'' | 0:01'35'' |
| Q25L60X80P001  |   80.0 |  88.33% |     10930 | 10.49M | 1833 |       966 | 990.75K | 4385 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:03'53'' | 0:01'32'' |
| Q25L60X120P000 |  120.0 |  87.70% |     11501 | 10.77M | 1675 |       896 | 561.47K | 3890 |  107.0 |  9.0 |  20.0 | 201.0 | "31,41,51,61,71,81" | 0:05'24'' | 0:01'36'' |
| Q25L60XallP000 |  195.9 |  86.98% |     10377 | 10.97M | 1693 |      1004 | 312.65K | 3768 |  175.0 | 16.0 |  20.0 | 334.5 | "31,41,51,61,71,81" | 0:08'18'' | 0:01'35'' |
| Q30L60X40P000  |   40.0 |  89.41% |     11752 | 10.42M | 1771 |      1008 |   1.19M | 4965 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'21'' | 0:01'37'' |
| Q30L60X40P001  |   40.0 |  89.58% |     11661 | 10.43M | 1748 |      1023 |   1.23M | 5013 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'22'' | 0:01'34'' |
| Q30L60X40P002  |   40.0 |  89.33% |     11479 | 10.45M | 1787 |      1015 |   1.22M | 5123 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'22'' | 0:01'37'' |
| Q30L60X40P003  |   40.0 |  89.59% |     11945 | 10.44M | 1757 |      1038 |   1.23M | 5042 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:02'22'' | 0:01'39'' |
| Q30L60X80P000  |   80.0 |  88.99% |     12579 | 10.55M | 1688 |      1007 | 971.65K | 4215 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:03'51'' | 0:01'38'' |
| Q30L60X80P001  |   80.0 |  88.76% |     11979 | 10.52M | 1711 |       982 | 987.94K | 4242 |   71.0 |  6.0 |  17.7 | 133.5 | "31,41,51,61,71,81" | 0:03'51'' | 0:01'37'' |
| Q30L60X120P000 |  120.0 |  88.22% |     12591 | 10.83M | 1536 |       930 | 530.02K | 3761 |  107.0 |  9.0 |  20.0 | 201.0 | "31,41,51,61,71,81" | 0:05'23'' | 0:01'35'' |
| Q30L60XallP000 |  186.9 |  87.58% |     11694 | 10.96M | 1555 |      1003 | 306.63K | 3575 |  167.0 | 15.0 |  20.0 | 318.0 | "31,41,51,61,71,81" | 0:07'54'' | 0:01'39'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  92.49% |     10712 | 10.46M | 1780 |      1008 |    1.2M | 5388 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'17'' | 0:01'41'' |
| Q25L60X40P001  |   40.0 |  92.42% |     10975 | 10.47M | 1796 |       953 |   1.17M | 5288 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'14'' | 0:01'38'' |
| Q25L60X40P002  |   40.0 |  92.45% |     10874 | 10.47M | 1798 |      1001 |   1.14M | 5276 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'14'' | 0:01'35'' |
| Q25L60X40P003  |   40.0 |  92.51% |     10674 | 10.43M | 1818 |       999 |   1.23M | 5455 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'13'' | 0:01'39'' |
| Q25L60X80P000  |   80.0 |  92.89% |     16387 | 10.68M | 1378 |       984 |   1.01M | 4366 |   72.0 |  6.0 |  18.0 | 135.0 | "31,41,51,61,71,81" | 0:01'38'' | 0:01'50'' |
| Q25L60X80P001  |   80.0 |  92.94% |     16426 | 10.73M | 1356 |       887 | 959.36K | 4436 |   72.0 |  6.0 |  18.0 | 135.0 | "31,41,51,61,71,81" | 0:01'39'' | 0:01'47'' |
| Q25L60X120P000 |  120.0 |  92.52% |     16405 | 10.92M | 1239 |       874 | 557.65K | 3675 |  107.0 |  9.0 |  20.0 | 201.0 | "31,41,51,61,71,81" | 0:02'01'' | 0:01'46'' |
| Q25L60XallP000 |  195.9 |  92.11% |     14635 | 11.07M | 1258 |       881 | 308.25K | 3335 |  176.0 | 15.0 |  20.0 | 331.5 | "31,41,51,61,71,81" | 0:02'54'' | 0:01'50'' |
| Q30L60X40P000  |   40.0 |  92.60% |     10565 | 10.47M | 1787 |       987 |   1.12M | 5324 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'12'' | 0:01'35'' |
| Q30L60X40P001  |   40.0 |  92.66% |     10534 | 10.46M | 1799 |      1007 |   1.18M | 5409 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'40'' |
| Q30L60X40P002  |   40.0 |  92.61% |     10792 | 10.48M | 1804 |       989 |   1.17M | 5406 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'39'' |
| Q30L60X40P003  |   40.0 |  92.54% |     10635 | 10.43M | 1801 |      1025 |    1.2M | 5363 |   36.0 |  3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:01'13'' | 0:01'36'' |
| Q30L60X80P000  |   80.0 |  93.13% |     17845 | 10.76M | 1303 |       868 | 875.33K | 4382 |   72.0 |  6.0 |  18.0 | 135.0 | "31,41,51,61,71,81" | 0:01'37'' | 0:01'50'' |
| Q30L60X80P001  |   80.0 |  93.06% |     16510 | 10.74M | 1326 |       914 | 957.84K | 4449 |   72.0 |  6.0 |  18.0 | 135.0 | "31,41,51,61,71,81" | 0:01'38'' | 0:01'49'' |
| Q30L60X120P000 |  120.0 |  92.89% |     17816 | 10.95M | 1201 |       863 | 565.07K | 3709 |  108.0 |  8.0 |  20.0 | 198.0 | "31,41,51,61,71,81" | 0:02'01'' | 0:01'55'' |
| Q30L60XallP000 |  186.9 |  92.53% |     15955 | 11.07M | 1203 |       947 | 343.29K | 3411 |  168.0 | 13.0 |  20.0 | 310.5 | "31,41,51,61,71,81" | 0:02'47'' | 0:01'52'' |


Table: statCanu

| Name                |    N50 |      Sum |     # |
|:--------------------|-------:|---------:|------:|
| Genome              | 924431 | 12157105 |    17 |
| Paralogs            |   3851 |  1059148 |   366 |
| Xall.trim.corrected |   7965 |   450.5M | 66099 |
| Xall.trim.contig    | 813374 | 12360766 |    26 |


Table: statFinal

| Name                           |    N50 |      Sum |    # |
|:-------------------------------|-------:|---------:|-----:|
| Genome                         | 924431 | 12157105 |   17 |
| Paralogs                       |   3851 |  1059148 |  366 |
| 7_mergeKunitigsAnchors.anchors |  32933 | 11356239 |  640 |
| 7_mergeKunitigsAnchors.others  |   1375 |  3787992 | 2993 |
| 7_mergeTadpoleAnchors.anchors  |  29743 | 11246792 |  691 |
| 7_mergeTadpoleAnchors.others   |   1310 |  3176593 | 2583 |
| 7_mergeAnchors.anchors         |  32933 | 11356239 |  640 |
| 7_mergeAnchors.others          |   1375 |  3787992 | 2993 |
| anchorLong                     |  37703 | 11286751 |  534 |
| anchorFill                     | 253144 | 11283555 |   77 |
| canu_Xall-trim                 | 813374 | 12360766 |   26 |
| spades.contig                  |  93363 | 11747736 | 1444 |
| spades.scaffold                | 106111 | 11748416 | 1421 |
| spades.non-contained           |  97714 | 11513927 |  261 |
| spades.anchor                  |   8667 | 10755810 | 1788 |
| megahit.contig                 |  43186 | 11624926 | 1019 |
| megahit.non-contained          |  44023 | 11432633 |  519 |
| megahit.anchor                 |   8209 | 10658000 | 1865 |
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

