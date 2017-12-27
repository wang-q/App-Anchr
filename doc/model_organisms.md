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

* Settings

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=e_coli

```

* Reference genome

```bash
mkdir -p ${WORKING_DIR}/${BASE_NAME}/1_genome
cd ${WORKING_DIR}/${BASE_NAME}/1_genome

curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=U00096.3&rettype=fasta&retmode=txt" \
    > U00096.fa
# simplify header, remove .3
cat U00096.fa \
    | perl -nl -e '
        /^>(\w+)/ and print qq{>$1} and next;
        print;
    ' \
    > genome.fa

cp ${WORKING_DIR}/paralogs/model/Results/e_coli/e_coli.multi.fas paralogs.fas
```

* Illumina

```bash
mkdir -p ${WORKING_DIR}/${BASE_NAME}/2_illumina
cd ${WORKING_DIR}/${BASE_NAME}/2_illumina

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
mkdir -p ${WORKING_DIR}/${BASE_NAME}/3_pacbio
cd ${WORKING_DIR}/${BASE_NAME}/3_pacbio

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
    --trim2 "--uniq --shuffle --scythe " \
    --sample2 300 \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix" \
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
| scythe    |     151 |   1.39G |  9221824 |
| Q25L60    |     151 |   1.06G |  8057720 |
| Q30L60    |     127 | 926.35M |  7887100 |
| PacBio    |   13982 | 748.51M |    87225 |
| X40.raw   |   14030 | 185.68M |    22336 |
| X40.trim  |   13702 | 169.38M |    19468 |
| X80.raw   |   13990 | 371.34M |    44005 |
| X80.trim  |   13632 | 339.51M |    38725 |
| Xall.raw  |   13982 | 748.51M |    87225 |
| Xall.trim |   13646 | 689.43M |    77693 |

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q25L60 | 297.6 |    298 |  20.5 |         42.38% |
| Q30L60 | 297.6 |    298 |  20.2 |         45.33% |

* mergereads

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bash 2_mergereads.sh

```

| Name           | N50 |    Sum |        # |
|:---------------|----:|-------:|---------:|
| clumped        | 151 |  1.72G | 11411654 |
| filteredbytile | 151 |  1.67G | 11046432 |
| trimmed        | 147 |  1.42G | 10363642 |
| filtered       | 147 |  1.42G | 10363140 |
| ecco           | 147 |  1.42G | 10363140 |
| eccc           | 147 |  1.42G | 10363140 |
| ecct           | 147 |  1.41G | 10308638 |
| extended       | 186 |  1.82G | 10308638 |
| merged         | 339 |  1.72G |  5084831 |
| unmerged.raw   | 174 | 20.16M |   138976 |
| unmerged       | 165 |  14.5M |   102452 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 270.8 |    277 |  25.0 |          9.79% |
| ihist.merge.txt  | 337.7 |    338 |  19.3 |         98.65% |

```text
#mergeReads
#Matched	502	0.00484%
#Name	Reads	ReadsPct
gi|9626372|ref|NC_001422.1| Coliphage phiX174, complete genome	502	0.00484%
```

* quorum

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bash 2_quorum.sh
bash 9_statQuorum.sh

```

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 228.8 |  215.5 |   5.815% |     133 | "83" | 4.64M | 4.57M |     0.99 | 0:02'27'' |
| Q30L60 | 199.7 |  194.8 |   2.483% |     120 | "71" | 4.64M | 4.56M |     0.98 | 0:02'10'' |

* down sampling, k-unitigs and anchors

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bash 4_downSampling.sh

bash 4_kunitigs.sh
bash 4_anchors.sh
bash 9_statAnchors.sh
mv statAnchors.md statSuperReadsAnchors.md

bash 4_tadpole.sh
bash 4_tadpoleAnchors.sh
bash 9_statAnchors.sh 4_tadpole
mv statAnchors.md statTadpoleAnchors.md

```

| Name          | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|----:|----------:|-------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |  98.42% |     43332 |  4.5M | 184 |      1517 | 12.54K |  9 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'59'' |
| Q25L60X40P001 |   40.0 |  98.51% |     43332 |  4.5M | 177 |      1454 |  9.85K |  7 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'40'' | 0:01'00'' |
| Q25L60X40P002 |   40.0 |  98.43% |     48038 | 4.51M | 173 |      1497 | 14.18K | 10 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:02'02'' | 0:00'59'' |
| Q25L60X40P003 |   40.0 |  98.44% |     39149 |  4.5M | 185 |      1255 | 13.31K | 10 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:02'00'' | 0:00'58'' |
| Q25L60X40P004 |   40.0 |  98.49% |     40210 |  4.5M | 177 |      1363 | 14.09K | 10 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'53'' | 0:01'01'' |
| Q25L60X80P000 |   80.0 |  98.27% |     33192 | 4.52M | 223 |      1538 |  9.12K |  7 |   78.0 | 4.0 |  22.0 | 135.0 | "31,41,51,61,71,81" | 0:03'04'' | 0:00'58'' |
| Q25L60X80P001 |   80.0 |  98.26% |     31642 | 4.51M | 228 |      1497 | 12.03K |  9 |   78.0 | 3.0 |  23.0 | 130.5 | "31,41,51,61,71,81" | 0:03'05'' | 0:00'57'' |
| Q30L60X40P000 |   40.0 |  98.52% |     41181 | 4.41M | 203 |      1607 | 33.48K | 18 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'47'' | 0:01'01'' |
| Q30L60X40P001 |   40.0 |  98.62% |     40910 |  4.5M | 193 |      1444 |  16.2K | 12 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:01'57'' | 0:00'59'' |
| Q30L60X40P002 |   40.0 |  98.57% |     40190 | 4.51M | 201 |      1497 | 19.63K | 14 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:01'39'' | 0:00'59'' |
| Q30L60X40P003 |   40.0 |  98.58% |     35664 | 4.37M | 208 |      1537 | 27.92K | 18 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'58'' |
| Q30L60X80P000 |   80.0 |  98.63% |     47239 | 4.47M | 160 |      1507 | 14.54K | 10 |   78.0 | 4.5 |  21.5 | 137.2 | "31,41,51,61,71,81" | 0:02'20'' | 0:01'05'' |
| Q30L60X80P001 |   80.0 |  98.64% |     46295 | 4.47M | 169 |      1517 | 15.33K | 10 |   78.0 | 4.0 |  22.0 | 135.0 | "31,41,51,61,71,81" | 0:02'19'' | 0:01'02'' |

| Name          | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|----:|----------:|-------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |  98.51% |     47339 | 4.47M | 174 |      1446 | 19.78K | 14 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'09'' | 0:01'30'' |
| Q25L60X40P001 |   40.0 |  98.59% |     46294 | 4.53M | 176 |      1343 | 15.23K | 12 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'06'' | 0:01'32'' |
| Q25L60X40P002 |   40.0 |  98.51% |     48131 | 4.52M | 176 |      1800 | 25.29K | 12 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'14'' | 0:01'23'' |
| Q25L60X40P003 |   40.0 |  98.52% |     44647 |  4.5M | 174 |      1517 | 16.06K | 12 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'19'' | 0:01'24'' |
| Q25L60X40P004 |   40.0 |  98.54% |     46298 |  4.5M | 174 |      1492 | 22.07K | 14 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'20'' | 0:01'27'' |
| Q25L60X80P000 |   80.0 |  98.54% |     59716 | 4.53M | 146 |      1282 |  9.12K |  7 |   79.0 | 4.0 |  22.3 | 136.5 | "31,41,51,61,71,81" | 0:01'45'' | 0:01'33'' |
| Q25L60X80P001 |   80.0 |  98.52% |     57888 | 4.52M | 147 |      1343 | 10.81K |  8 |   78.5 | 3.5 |  22.7 | 133.5 | "31,41,51,61,71,81" | 0:01'51'' | 0:01'14'' |
| Q30L60X40P000 |   40.0 |  98.48% |     30971 | 4.47M | 253 |      1607 | 40.58K | 23 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:01'04'' |
| Q30L60X40P001 |   40.0 |  98.52% |     30880 | 4.49M | 250 |      1450 | 20.73K | 15 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:01'25'' | 0:01'03'' |
| Q30L60X40P002 |   40.0 |  98.50% |     30816 | 4.52M | 254 |      1343 |  26.3K | 20 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:01'21'' | 0:01'04'' |
| Q30L60X40P003 |   40.0 |  98.55% |     31013 | 4.49M | 255 |      1563 | 34.04K | 21 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'59'' |
| Q30L60X80P000 |   80.0 |  98.58% |     46294 | 4.48M | 173 |      1370 | 18.74K | 14 |   78.0 | 5.0 |  21.0 | 139.5 | "31,41,51,61,71,81" | 0:01'45'' | 0:01'05'' |
| Q30L60X80P001 |   80.0 |  98.59% |     42691 |  4.5M | 188 |      1497 | 11.19K |  8 |   78.0 | 5.0 |  21.0 | 139.5 | "31,41,51,61,71,81" | 0:01'45'' | 0:01'00'' |

* merge anchors

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bash 6_mergeAnchors.sh 4_kunitigs
mv 6_mergeAnchors 6_mergeSuperReadsAnchors

bash 6_mergeAnchors.sh 4_tadpole
mv 6_mergeAnchors 6_mergeTadpoleAnchors

cp 6_mergeSuperReadsAnchors/anchor.merge.fasta 6_mergeSuperReadsAnchors/anchor.fasta
cp 6_mergeTadpoleAnchors/anchor.merge.fasta 6_mergeTadpoleAnchors/anchor.fasta

cp 6_mergeSuperReadsAnchors/others.non-contained.fasta 6_mergeSuperReadsAnchors/pe.others.fa
cp 6_mergeTadpoleAnchors/others.non-contained.fasta 6_mergeTadpoleAnchors/pe.others.fa

bash 6_mergeAnchors.sh 6_merge

# anchor sort on ref
for D in 6_mergeAnchors 6_mergeSuperReadsAnchors 6_mergeTadpoleAnchors; do
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
bash 8_platanus.sh

```

* final stats

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bash 9_statFinal.sh
bash 9_quast.sh

#bash 0_cleanup.sh

```

| Name                   |     N50 |     Sum |    # |
|:-----------------------|--------:|--------:|-----:|
| Genome                 | 4641652 | 4641652 |    1 |
| Paralogs               |    1934 |  195673 |  106 |
| anchors                |   63638 | 4531348 |  124 |
| others                 |    1262 |  181438 |  148 |
| anchorLong             |   82617 | 4529844 |  109 |
| anchorFill             |  865377 | 4600704 |   10 |
| canu_X40-raw           | 4674150 | 4674150 |    1 |
| canu_X40-trim          | 4674046 | 4674046 |    1 |
| canu_X80-raw           | 4658166 | 4658166 |    1 |
| canu_X80-trim          | 4657933 | 4657933 |    1 |
| canu_Xall-raw          | 4670118 | 4670118 |    1 |
| canu_Xall-trim         | 4670240 | 4670240 |    1 |
| tadpole.Q25L60         |   15203 | 4543408 |  634 |
| tadpole.Q30L60         |   17904 | 4539904 |  553 |
| spades.contig          |  117644 | 4665624 |  332 |
| spades.scaffold        |  132608 | 4665674 |  327 |
| spades.non-contained   |  125811 | 4582613 |   93 |
| platanus.contig        |   16442 | 4673967 | 1016 |
| platanus.scaffold      |  133012 | 4576193 |  141 |
| platanus.non-contained |  133012 | 4559199 |   63 |

# *Saccharomyces cerevisiae* S288c

* Genome: [Ensembl 82](http://sep2015.archive.ensembl.org/Saccharomyces_cerevisiae/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.058

## s288c: download

* Settings

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=s288c

```

* Reference genome

```bash
mkdir -p ${WORKING_DIR}/${BASE_NAME}
cd ${WORKING_DIR}/${BASE_NAME}

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
cd ${WORKING_DIR}/${BASE_NAME}

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
mkdir -p ${WORKING_DIR}/${BASE_NAME}/3_pacbio
cd ${WORKING_DIR}/${BASE_NAME}/3_pacbio

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

* 对真核生物尽量不要使用 `scythe`

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
    --trim2 "--uniq " \
    --cov2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --cov3 "all" \
    --qual3 "trim" \
    --mergereads \
    --parallel 24

```

## s288c: run

```bash
# Illumina QC
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_fastqc" "bash 2_fastqc.sh"
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_kmergenie" "bash 2_kmergenie.sh"

# preprocess Illumina reads
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_trim" "bash 2_trim.sh"

# merge reads
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_mergereads" "bash 2_mergereads.sh"

# insert size
bsub -w "done(${BASE_NAME}-2_trim)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_insertSize" "bash 2_insertSize.sh"

# preprocess PacBio reads
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-3_trimlong" "bash 3_trimlong.sh"

# reads stats
bsub -w "done(${BASE_NAME}-2_trim) && done(${BASE_NAME}-3_trimlong)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_statReads" "bash 9_statReads.sh"

# spades and platanus
bsub -w "done(${BASE_NAME}-2_trim)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-8_spades" "bash 8_spades.sh"

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
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_statAnchors" "bash 9_statAnchors.sh"

# merge anchors
bsub -w "done(${BASE_NAME}-4_anchors)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-6_mergeAnchors" "bash 6_mergeAnchors.sh 4_kunitigs"

# canu
bsub -w "done(${BASE_NAME}-3_trimlong)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-5_canu" "bash 5_canu.sh"
bsub -w "done(${BASE_NAME}-5_canu)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_statCanu" "bash 9_statCanu.sh"

# expand anchors
bsub -w "done(${BASE_NAME}-4_anchors) && done(${BASE_NAME}-5_canu)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-6_anchorLong" \
    "bash 6_anchorLong.sh 6_mergeAnchors/anchor.merge.fasta 5_canu_Xall-trim/${BASE_NAME}.correctedReads.fasta.gz"

bsub -w "done(${BASE_NAME}-6_anchorLong)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-6_anchorFill" \
    "bash 6_anchorFill.sh 6_anchorLong/contig.fasta 5_canu_Xall-trim/${BASE_NAME}.contigs.fasta"

```

```bash
# stats
bash 9_statFinal.sh

bash -q mpi -n 24 -J "${BASE_NAME}-6_anchorFill" "bash 9_quast.sh"

# false strands of anchorLong
cat 6_anchorLong/group/*.ovlp.tsv \
    | perl -nla -e '/anchor.+long/ or next; print $F[0] if $F[8] == 1;' \
    | sort | uniq -c
    
#bash 0_cleanup.sh

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
| Q25L60    |    151 |     2.5G | 16817924 |
| Q30L60    |    151 |    2.44G | 16630313 |
| PacBio    |   8412 |  820.96M |   177100 |
| Xall.raw  |   8412 |  820.96M |   177100 |
| Xall.trim |   7829 |  626.41M |   106381 |

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q25L60 | 339.9 |    312 | 134.7 |         36.25% |
| Q30L60 | 338.4 |    311 | 133.6 |         37.26% |

| Name         | N50 |     Sum |        # |
|:-------------|----:|--------:|---------:|
| clumped      | 151 |   2.74G | 18146514 |
| trimmed      | 150 |   2.63G | 17918200 |
| filtered     | 150 |   2.63G | 17916952 |
| ecco         | 150 |   2.63G | 17916952 |
| eccc         | 150 |   2.63G | 17916952 |
| ecct         | 150 |   2.52G | 17195798 |
| extended     | 190 |    3.2G | 17195798 |
| merged       | 356 |   2.36G |  7176703 |
| unmerged.raw | 190 | 525.96M |  2842392 |
| unmerged     | 190 | 458.96M |  2551918 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 209.9 |    220 |  52.9 |         39.07% |
| ihist.merge.txt  | 328.1 |    325 |  94.9 |         83.47% |

```text
#mergeReads
#Matched	695	0.00388%
#Name	Reads	ReadsPct
contam_135	521	0.00291%
contam_159	156	0.00087%
```

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |  RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|-------:|-------:|---------:|----------:|
| Q25L60 | 205.9 |  180.6 |  12.291% |     149 | "105" | 12.16M | 12.16M |     1.00 | 0:04'27'' |
| Q30L60 | 201.0 |  178.9 |  10.986% |     148 | "105" | 12.16M | 12.06M |     0.99 | 0:04'20'' |

```text
#Q25L60
#Matched        56909   0.38546%
#Name   Reads   ReadsPct
I5_Nextera_Transposase_1        31974   0.21657%
I7_Nextera_Transposase_1        24866   0.16843%

#Q30L60
#Matched        56695   0.38200%
#Name   Reads   ReadsPct
I5_Nextera_Transposase_1        33136   0.22327%
I7_Nextera_Transposase_1        23482   0.15822%

```

| Name          | CovCor | N50Anchor |    Sum |    # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|-------:|-----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |   40.0 |     12071 |   9.8M | 1402 |      1013 | 502.43K | 513 |   34.0 | 4.0 |   7.3 |  68.0 | "31,41,51,61,71,81" | 0:02'25'' | 0:01'30'' |
| Q25L60X40P001 |   40.0 |     12556 | 10.07M | 1412 |       996 | 453.64K | 482 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:02'23'' | 0:01'30'' |
| Q25L60X40P002 |   40.0 |     13165 | 10.17M | 1356 |       993 |  437.3K | 453 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:02'24'' | 0:01'32'' |
| Q25L60X40P003 |   40.0 |     13142 | 10.15M | 1367 |      1023 | 481.82K | 498 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:02'25'' | 0:01'32'' |
| Q25L60X80P000 |   80.0 |     10813 |  9.79M | 1554 |       990 | 463.46K | 491 |   70.0 | 7.0 |  16.3 | 136.5 | "31,41,51,61,71,81" | 0:03'55'' | 0:01'28'' |
| Q25L60X80P001 |   80.0 |     11358 |  10.2M | 1544 |       973 | 464.78K | 502 |   70.0 | 8.0 |  15.3 | 140.0 | "31,41,51,61,71,81" | 0:03'56'' | 0:01'29'' |
| Q30L60X40P000 |   40.0 |     12586 |  10.2M | 1378 |       964 | 457.74K | 490 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:02'25'' | 0:01'30'' |
| Q30L60X40P001 |   40.0 |     13453 | 10.14M | 1351 |       990 | 459.04K | 485 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:02'23'' | 0:01'33'' |
| Q30L60X40P002 |   40.0 |     13164 | 10.11M | 1305 |       987 | 424.69K | 447 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:02'24'' | 0:01'33'' |
| Q30L60X40P003 |   40.0 |     13661 | 10.43M | 1319 |       975 | 410.42K | 450 |   36.0 | 4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:02'24'' | 0:01'29'' |
| Q30L60X80P000 |   80.0 |     12472 |  9.88M | 1454 |       992 | 451.54K | 478 |   70.0 | 7.0 |  16.3 | 136.5 | "31,41,51,61,71,81" | 0:03'55'' | 0:01'31'' |
| Q30L60X80P001 |   80.0 |     11951 | 10.34M | 1465 |       952 | 439.16K | 485 |   71.0 | 8.0 |  15.7 | 142.0 | "31,41,51,61,71,81" | 0:03'54'' | 0:01'32'' |

| Name                |    N50 |      Sum |     # |
|:--------------------|-------:|---------:|------:|
| Genome              | 924431 | 12157105 |    17 |
| Paralogs            |   3851 |  1059148 |   366 |
| Xall.trim.corrected |   7965 |   450.5M | 66099 |
| Xall.trim.contig    | 813374 | 12360766 |    26 |

| Name                   |    N50 |      Sum |    # |
|:-----------------------|-------:|---------:|-----:|
| Genome                 | 924431 | 12157105 |   17 |
| Paralogs               |   3851 |  1059148 |  366 |
| anchors                |  26702 | 11261198 |  784 |
| others                 |   1188 |  1524190 | 1365 |
| anchorLong             |  40449 | 11172421 |  545 |
| anchorFill             | 253179 | 11276561 |   74 |
| canu_Xall-trim         | 813374 | 12360766 |   26 |
| tadpole.Q25L60         |   7705 | 11413019 | 3654 |
| tadpole.Q30L60         |   8348 | 11410696 | 3501 |
| spades.contig          |  83977 | 11775064 | 1710 |
| spades.scaffold        |  93363 | 11775854 | 1676 |
| spades.non-contained   |  85760 | 11511681 |  296 |
| platanus.contig        |   5983 | 12437850 | 7727 |
| platanus.scaffold      |  55443 | 12073445 | 4735 |
| platanus.non-contained |  59263 | 11404921 |  360 |

# *Drosophila melanogaster* iso-1

* Genome: [Ensembl 82](http://sep2015.archive.ensembl.org/Drosophila_melanogaster/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.0661

## iso_1: download

* Settings

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=iso_1

```

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
    --genome 137567477 \
    --is_euk \
    --trim2 "--uniq " \
    --cov2 "40 50 60 70 80 all" \
    --qual2 "25 30" \
    --len2 "60" \
    --cov3 "all" \
    --qual3 "trim" \
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

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q25L60 | 250.5 |    230 | 100.0 |         31.48% |
| Q30L60 | 249.5 |    229 |  99.1 |         32.54% |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|--------:|--------:|---------:|----------:|
| Q25L60 | 106.5 |   96.4 |   9.510% |      99 | "71" | 137.57M | 127.11M |     0.92 | 0:27'57'' |
| Q30L60 | 101.7 |   94.2 |   7.375% |      99 | "71" | 137.57M |  126.4M |     0.92 | 0:27'02'' |

```text
#File	pe.cor.raw
#Total	133144953
#Matched	5597	0.00420%
#Name	Reads	ReadsPct
Reverse_adapter	5472	0.00411%

#File	pe.cor.raw
#Total	132986954
#Matched	21939	0.01650%
#Name	Reads	ReadsPct
Reverse_adapter	21644	0.01628%

```

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |   Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  84.03% |     15061 | 115.02M | 13812 |       870 | 7.31M | 7878 |   34.0 | 4.0 |   7.3 |  68.0 | "31,41,51,61,71,81" | 0:32'21'' | 0:28'17'' |
| Q25L60X40P001  |   40.0 |  84.00% |     15076 | 114.97M | 13958 |       867 | 7.37M | 7976 |   34.0 | 4.0 |   7.3 |  68.0 | "31,41,51,61,71,81" | 0:32'22'' | 0:28'00'' |
| Q25L60X50P000  |   50.0 |  83.93% |     14307 | 115.26M | 14251 |       875 |  6.7M | 7155 |   43.0 | 5.0 |   9.3 |  86.0 | "31,41,51,61,71,81" | 0:36'50'' | 0:23'52'' |
| Q25L60X60P000  |   60.0 |  83.62% |     13258 | 115.78M | 14996 |       855 | 6.23M | 6730 |   51.0 | 7.0 |  10.0 | 102.0 | "31,41,51,61,71,81" | 0:41'23'' | 0:23'56'' |
| Q25L60X70P000  |   70.0 |  83.27% |     12511 | 115.66M | 15656 |       858 | 6.16M | 6630 |   59.0 | 8.0 |  11.7 | 118.0 | "31,41,51,61,71,81" | 0:45'52'' | 0:36'31'' |
| Q25L60X80P000  |   80.0 |  82.98% |     11765 | 115.52M | 16342 |       865 | 6.18M | 6626 |   68.0 | 9.0 |  13.7 | 136.0 | "31,41,51,61,71,81" | 0:50'31'' | 0:36'05'' |
| Q25L60XallP000 |   96.4 |  81.10% |     10834 | 114.29M | 17164 |      3058 |  2.5M | 1138 |   85.0 | 7.0 |  21.3 | 159.0 | "31,41,51,61,71,81" | 1:43'46'' | 0:21'36'' |
| Q30L60X40P000  |   40.0 |  83.77% |     14740 | 114.84M | 14399 |       854 |  7.6M | 8369 |   34.0 | 5.0 |   6.3 |  68.0 | "31,41,51,61,71,81" | 0:32'21'' | 0:22'04'' |
| Q30L60X40P001  |   40.0 |  83.75% |     14255 | 114.57M | 14780 |       852 |  7.9M | 8710 |   34.0 | 5.0 |   6.3 |  68.0 | "31,41,51,61,71,81" | 0:32'17'' | 0:21'46'' |
| Q30L60X50P000  |   50.0 |  83.86% |     14458 | 115.44M | 14494 |       852 | 6.84M | 7432 |   42.0 | 6.0 |   8.0 |  84.0 | "31,41,51,61,71,81" | 0:36'48'' | 0:22'23'' |
| Q30L60X60P000  |   60.0 |  83.80% |     13899 | 115.33M | 14737 |       859 | 6.64M | 7161 |   51.0 | 7.0 |  10.0 | 102.0 | "31,41,51,61,71,81" | 0:41'14'' | 0:22'57'' |
| Q30L60X70P000  |   70.0 |  83.68% |     13333 | 115.35M | 15143 |       864 | 6.53M | 6995 |   59.0 | 8.0 |  11.7 | 118.0 | "31,41,51,61,71,81" | 0:45'50'' | 0:23'27'' |
| Q30L60X80P000  |   80.0 |  83.55% |     12784 | 115.23M | 15493 |       869 | 6.47M | 6901 |   68.0 | 9.0 |  13.7 | 136.0 | "31,41,51,61,71,81" | 0:49'39'' | 0:21'23'' |
| Q30L60XallP000 |   94.2 |  82.04% |     12263 | 114.24M | 15806 |      2888 | 2.67M | 1208 |   83.0 | 7.0 |  20.7 | 156.0 | "31,41,51,61,71,81" | 1:40'32'' | 0:24'01'' |

| Name                |      N50 |       Sum |      # |
|:--------------------|---------:|----------:|-------:|
| Genome              | 25286936 | 137567477 |      8 |
| Paralogs            |     4031 |  13665900 |   4492 |
| Xall.trim.corrected |    13405 |     4.25G | 433377 |
| Xall.trim.contig    | 18542648 | 151436172 |    598 |


| Name                   |      N50 |       Sum |      # |
|:-----------------------|---------:|----------:|-------:|
| Genome                 | 25286936 | 137567477 |      8 |
| Paralogs               |     4031 |  13665900 |   4492 |
| anchors                |    26562 | 117385710 |   9637 |
| others                 |      890 |  15559454 |  17450 |
| anchorLong             |    38892 | 113750098 |   7028 |
| anchorFill             |   257427 | 113856141 |   1785 |
| canu_Xall-trim         | 18542648 | 151436172 |    598 |
| tadpole.Q25L60         |     5293 | 117636764 |  56413 |
| tadpole.Q30L60         |     6462 | 117560164 |  51234 |
| spades.contig          |   121722 | 135713005 | 120270 |
| spades.scaffold        |   134650 | 135719566 | 119991 |
| spades.non-contained   |   134650 | 121328458 |   3726 |
| platanus.contig        |    11503 | 156820565 | 359399 |
| platanus.scaffold      |   146404 | 129134232 |  71416 |
| platanus.non-contained |   161200 | 119999445 |   3216 |

# *Caenorhabditis elegans* N2

* Genome: [Ensembl 82](http://sep2015.archive.ensembl.org/Caenorhabditis_elegans/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.0472

## n2: download

* Settings

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=n2

```

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
    --cov3 "all" \
    --qual3 "trim" \
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

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q25L60 | 212.0 |    204 |  67.6 |         20.04% |
| Q30L60 | 211.3 |    203 |  67.1 |         30.69% |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer |   RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|--------:|-------:|---------:|----------:|
| Q25L60 |  98.5 |   63.6 |   35.44% |      97 | "71" | 100.29M | 98.89M |     0.99 | 0:17'47'' |
| Q30L60 |  88.5 |   73.9 |   16.46% |      91 | "69" | 100.29M | 98.82M |     0.99 | 0:16'27'' |

```text
#File	pe.cor.raw
#Total	66376070
#Matched	1203	0.00181%
#Name	Reads	ReadsPct
Reverse_adapter	1151	0.00173%

#File	pe.cor.raw
#Total	84522239
#Matched	2807	0.00332%
#Name	Reads	ReadsPct

```

| Name           | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |   Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|------:|----------:|------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  91.35% |     12150 | 86.11M | 13537 |      6985 | 8.07M | 2911 |   31.0 | 3.0 |   7.3 |  60.0 | "31,41,51,61,71,81" | 0:25'03'' | 0:20'49'' |
| Q25L60X50P000  |   50.0 |  91.55% |     12307 | 86.91M | 13210 |      7042 | 7.74M | 2648 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:29'12'' | 0:21'56'' |
| Q25L60X60P000  |   60.0 |  91.67% |     12419 | 87.42M | 13038 |      6717 | 7.57M | 2559 |   44.0 | 5.0 |   9.7 |  88.0 | "31,41,51,61,71,81" | 0:33'07'' | 0:20'23'' |
| Q25L60XallP000 |   63.6 |  91.67% |     12321 | 87.69M | 13071 |      6819 | 7.37M | 2441 |   46.0 | 6.0 |   9.3 |  92.0 | "31,41,51,61,71,81" | 0:34'14'' | 0:22'32'' |
| Q30L60X40P000  |   40.0 |  91.67% |     12121 | 86.09M | 13807 |      9407 | 8.08M | 2769 |   31.0 | 3.0 |   7.3 |  60.0 | "31,41,51,61,71,81" | 0:23'52'' | 0:19'32'' |
| Q30L60X50P000  |   50.0 |  91.96% |     12550 | 87.14M | 13367 |      9561 | 7.63M | 2493 |   38.0 | 4.0 |   8.7 |  75.0 | "31,41,51,61,71,81" | 0:27'45'' | 0:20'46'' |
| Q30L60X60P000  |   60.0 |  92.19% |     12808 | 87.67M | 13025 |      9689 | 7.46M | 2355 |   45.0 | 5.0 |  10.0 |  90.0 | "31,41,51,61,71,81" | 0:31'11'' | 0:21'30'' |
| Q30L60XallP000 |   73.9 |  92.26% |     12976 | 87.83M | 12768 |      8920 | 7.39M | 2313 |   54.0 | 6.0 |  12.0 | 108.0 | "31,41,51,61,71,81" | 0:34'58'' | 0:21'49'' |

| Name                |      N50 |       Sum |      # |
|:--------------------|---------:|----------:|-------:|
| Genome              | 17493829 | 100286401 |      7 |
| Paralogs            |     2013 |   5313653 |   2637 |
| Xall.trim.corrected |    18340 |     3.86G | 207189 |
| Xall.trim.contig    |  2859614 | 107313895 |    109 |

| Name                   |      N50 |       Sum |      # |
|:-----------------------|---------:|----------:|-------:|
| Genome                 | 17493829 | 100286401 |      7 |
| Paralogs               |     2013 |   5313653 |   2637 |
| anchors                |    14820 |  89121759 |  11981 |
| others                 |     2167 |  11181041 |   5075 |
| anchorLong             |    20639 |  88197480 |   9059 |
| anchorFill             |   294156 |  94191922 |    744 |
| canu_Xall-trim         |  2859614 | 107313895 |    109 |
| tadpole.Q25L60         |     3829 |  94574682 |  69660 |
| tadpole.Q30L60         |     4262 |  94454906 |  67082 |
| spades.contig          |    29569 | 105888001 |  61628 |
| spades.scaffold        |    30934 | 105896000 |  61340 |
| spades.non-contained   |    33028 |  97916802 |   7046 |
| platanus.contig        |     9540 | 108908253 | 143264 |
| platanus.scaffold      |    28158 |  99589056 |  35182 |
| platanus.non-contained |    30510 |  94099392 |   7644 |

# *Arabidopsis thaliana* Col-0

* Genome: [Ensembl Genomes](http://plants.ensembl.org/Arabidopsis_thaliana/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.1158

## col_0: download

* Settings

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=col_0

```

* Reference genome

```bash
mkdir -p ~/data/anchr/col_0/1_genome
cd ~/data/anchr/col_0/1_genome
wget -N ftp://ftp.ensemblgenomes.org/pub/release-29/plants/fasta/arabidopsis_thaliana/dna/Arabidopsis_thaliana.TAIR10.29.dna_sm.toplevel.fa.gz
faops order Arabidopsis_thaliana.TAIR10.29.dna_sm.toplevel.fa.gz \
    <(for chr in {1,2,3,4,5,Mt,Pt}; do echo $chr; done) \
    genome.fa
```

* Illumina HiSeq (100 bp)

    [SRX202246](https://www.ncbi.nlm.nih.gov/sra/SRX202246[accn])

```bash
# Downloading from ena with aria2
mkdir -p ~/data/anchr/col_0/2_illumina
cd ~/data/anchr/col_0/2_illumina

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
    --cov3 "all" \
    --qual3 "trim" \
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

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q25L60 | 316.8 |    296 | 104.1 |         20.07% |
| Q30L60 | 330.9 |    313 | 106.6 |         29.31% |

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|--------:|--------:|---------:|----------:|
| Q25L60 |  98.8 |   70.4 |   28.72% |     236 | "127" | 119.67M | 125.44M |     1.05 | 0:21'44'' |
| Q30L60 |  86.7 |   73.0 |   15.82% |     218 | "127" | 119.67M | 119.21M |     1.00 | 0:19'41'' |

```text
#File	pe.cor.raw
#Total	34920794
#Matched	5824	0.01668%
#Name	Reads	ReadsPct
Reverse_adapter	5501	0.01575%

#File	pe.cor.raw
#Total	40402458
#Matched	4188	0.01037%
#Name	Reads	ReadsPct
Reverse_adapter	4012	0.00993%

```

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |   Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  68.88% |     18509 | 104.37M | 10889 |      1167 |  1.3M |  974 |   27.0 | 2.0 |   7.0 |  49.5 | "31,41,51,61,71,81" | 0:37'35'' | 0:15'00'' |
| Q25L60X50P000  |   50.0 |  68.78% |     17181 | 104.11M | 11405 |      1165 | 1.48M | 1117 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:43'34'' | 0:15'28'' |
| Q25L60X60P000  |   60.0 |  68.70% |     15758 | 105.74M | 12071 |      1128 | 1.33M | 1015 |   41.0 | 3.0 |  10.7 |  75.0 | "31,41,51,61,71,81" | 0:45'05'' | 0:15'44'' |
| Q25L60XallP000 |   70.4 |  68.71% |     14828 | 105.24M | 12599 |      1151 | 1.56M | 1155 |   48.0 | 3.0 |  13.0 |  85.5 | "31,41,51,61,71,81" | 0:48'48'' | 0:16'47'' |
| Q30L60X40P000  |   40.0 |  73.91% |     22426 | 105.09M |  9631 |      1220 | 1.38M | 1003 |   29.0 | 2.0 |   7.7 |  52.5 | "31,41,51,61,71,81" | 0:34'52'' | 0:14'23'' |
| Q30L60X50P000  |   50.0 |  73.75% |     22214 | 106.63M |  9727 |      1141 | 1.12M |  846 |   36.0 | 3.0 |   9.0 |  67.5 | "31,41,51,61,71,81" | 0:40'11'' | 0:15'16'' |
| Q30L60X60P000  |   60.0 |  73.60% |     21889 |  106.4M |  9756 |      1156 | 1.28M |  949 |   44.0 | 3.0 |  11.7 |  79.5 | "31,41,51,61,71,81" | 0:51'52'' | 0:15'27'' |
| Q30L60XallP000 |   73.0 |  73.37% |     21355 | 106.47M |  9900 |      1200 | 1.41M | 1006 |   53.0 | 3.0 |  14.7 |  93.0 | "31,41,51,61,71,81" | 1:37'10'' | 0:16'19'' |

| Name                |      N50 |       Sum |      # |
|:--------------------|---------:|----------:|-------:|
| Genome              | 23459830 | 119667750 |      7 |
| Paralogs            |     2007 |  16447809 |   8055 |
| Xall.trim.corrected |     7477 |     4.46G | 661124 |
| Xall.trim.contig    |  5997654 | 121555181 |    265 |

| Name                   |      N50 |       Sum |      # |
|:-----------------------|---------:|----------:|-------:|
| Genome                 | 23459830 | 119667750 |      7 |
| Paralogs               |     2007 |  16447809 |   8055 |
| anchors                |    25234 | 107890628 |   9113 |
| others                 |      848 |   7111802 |   8564 |
| anchorLong             |    41466 | 107541950 |   6236 |
| anchorFill             |  1088118 | 113534241 |    558 |
| canu_Xall-trim         |  5997654 | 121555181 |    265 |
| tadpole.Q25L60         |     4504 | 109047255 |  95504 |
| tadpole.Q30L60         |     5155 | 107884344 |  87761 |
| spades.contig          |    57805 | 156418066 | 160037 |
| spades.scaffold        |    63103 | 156421332 | 159868 |
| spades.non-contained   |   105827 | 115376936 |   4482 |
| platanus.contig        |    15019 | 139807772 | 106870 |
| platanus.scaffold      |   192019 | 128497152 |  67429 |
| platanus.non-contained |   217851 | 116431399 |   2050 |
