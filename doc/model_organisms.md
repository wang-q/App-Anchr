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
    - [s288c_MiSeq: symlink](#s288c-miseq-symlink)
    - [s288c_MiSeq: template](#s288c-miseq-template)
    - [s288c_MiSeq: run](#s288c-miseq-run)
    - [s288c_HiSeq: symlink](#s288c-hiseq-symlink)
    - [s288c_HiSeq: template](#s288c-hiseq-template)
    - [s288c_HiSeq: run](#s288c-hiseq-run)
- [*Drosophila melanogaster* iso-1](#drosophila-melanogaster-iso-1)
    - [iso_1: download](#iso-1-download)
    - [iso_1_HiSeq_2000: symlink](#iso-1-hiseq-2000-symlink)
    - [iso_1_HiSeq_2000: template](#iso-1-hiseq-2000-template)
    - [iso_1_HiSeq_2000: run](#iso-1-hiseq-2000-run)
    - [iso_1_HiSeq_2500: symlink](#iso-1-hiseq-2500-symlink)
    - [iso_1_HiSeq_2500: template](#iso-1-hiseq-2500-template)
    - [iso_1_HiSeq_2500: run](#iso-1-hiseq-2500-run)
- [*Caenorhabditis elegans* N2](#caenorhabditis-elegans-n2)
    - [n2: download](#n2-download)
    - [n2_pe120: symlink](#n2-pe120-symlink)
    - [n2_pe120: template](#n2-pe120-template)
    - [n2_pe120: run](#n2-pe120-run)
    - [n2_pe100: symlink](#n2-pe100-symlink)
    - [n2_pe100: template](#n2-pe100-template)
    - [n2_pe100: run](#n2-pe100-run)
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
cat U00096.fa |
    perl -nl -e '
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

* Rsync to hpcc

```bash
rsync -avP \
    --exclude="p6c4_ecoli_RSII_DDR2_with_15kb_cut_E01_1.tar.gz" \
    ~/data/anchr/e_coli/ \
    wangq@202.119.37.251:data/anchr/e_coli

# rsync -avP wangq@202.119.37.251:data/anchr/e_coli/ ~/data/anchr/e_coli

```

* template

`--cov2 "40 60 80 100"` introduced ~10 SNPs and 1 misassembly.

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
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --sgastats \
    --trim2 "--dedupe --tile --cutoff 5 --cutk 31" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,2,3" \
    --cov2 "40 80" \
    --tadpole \
    --statp 5 \
    --redoanchors \
    --cov3 "80 all" \
    --qual3 "trim" \
    --parallel 24 \
    --xmx 110g

```

## e_coli: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=e_coli

cd ${WORKING_DIR}/${BASE_NAME}
#rm -fr 4_*/ 6_*/ 7_*/ 8_*/ 2_illumina/trim 2_illumina/mergereads statReads.md 

bash 0_bsub.sh
#bkill -J "${BASE_NAME}-*"

#bash 0_master.sh
#bash 0_cleanup.sh

```

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


Table: statInsertSize

| Group             |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:------------------|------:|-------:|------:|-------------------------------:|
| R.genome.bbtools  | 321.9 |    298 | 968.5 |                         47.99% |
| R.tadpole.bbtools | 295.6 |    296 |  21.1 |                         40.60% |
| R.genome.picard   | 298.2 |    298 |  18.0 |                             FR |
| R.tadpole.picard  | 294.9 |    296 |  21.7 |                             FR |


Table: statSgaStats

| Library | incorrectBases | perfectReads | overlapDepth |
|:--------|---------------:|-------------:|-------------:|
| R       |          0.26% |       79.72% |       356.41 |


Table: statReads

| Name       |     N50 |     Sum |        # |
|:-----------|--------:|--------:|---------:|
| Genome     | 4641652 | 4641652 |        1 |
| Paralogs   |    1934 |  195673 |      106 |
| Illumina.R |     151 |   1.73G | 11458940 |
| trim.R     |     149 |   1.43G | 10363942 |
| Q20L60     |     149 |   1.41G | 10224942 |
| Q25L60     |     148 |   1.32G |  9939581 |
| Q30L60     |     128 |   1.11G |  9311358 |
| PacBio     |   13982 | 748.51M |    87225 |
| X80.raw    |   13990 | 371.34M |    44005 |
| X80.trim   |   13632 | 339.51M |    38725 |
| Xall.raw   |   13982 | 748.51M |    87225 |
| Xall.trim  |   13646 | 689.43M |    77693 |


Table: statTrimReads

| Name           | N50 |     Sum |        # |
|:---------------|----:|--------:|---------:|
| clumpify       | 151 |   1.73G | 11439000 |
| filteredbytile | 151 |   1.67G | 11060132 |
| highpass       | 151 |   1.66G | 10989512 |
| trim           | 149 |   1.43G | 10364442 |
| filter         | 149 |   1.43G | 10363942 |
| R1             | 150 |    736M |  5181971 |
| R2             | 144 | 690.42M |  5181971 |
| Rs             |   0 |       0 |        0 |


```text
#R.trim
#Matched	17666	0.16075%
#Name	Reads	ReadsPct
```

```text
#R.filter
#Matched	499	0.00481%
#Name	Reads	ReadsPct
```

```text
#R.peaks
#k	31
#unique_kmers	20719894
#main_peak	239
#genome_size	4602129
#haploid_genome_size	4602129
#fold_coverage	239
#haploid_fold_coverage	239
#ploidy	1
#percent_repeat	2.092
#start	center	stop	max	volume
```


Table: statMergeReads

| Name          | N50 |    Sum |        # |
|:--------------|----:|-------:|---------:|
| clumped       | 149 |  1.43G | 10362762 |
| ecco          | 149 |  1.43G | 10362762 |
| eccc          | 149 |  1.43G | 10362762 |
| ecct          | 149 |  1.42G | 10314376 |
| extended      | 189 |  1.83G | 10314376 |
| merged.raw    | 339 |  1.72G |  5089559 |
| unmerged.raw  | 175 | 19.82M |   135258 |
| unmerged.trim | 175 | 19.81M |   135198 |
| M1            | 339 |  1.71G |  5061974 |
| U1            | 181 | 10.42M |    67599 |
| U2            | 168 |  9.39M |    67599 |
| Us            |   0 |      0 |        0 |
| M.cor         | 338 |  1.73G | 10259146 |

| Group              |  Mean | Median | STDev | PercentOfPairs |
|:-------------------|------:|-------:|------:|---------------:|
| M.ihist.merge1.txt | 271.6 |    277 |  23.7 |         10.86% |
| M.ihist.merge.txt  | 337.7 |    338 |  19.3 |         98.69% |


Table: statQuorum

| Name     | CovIn | CovOut | Discard% | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:---------|------:|-------:|---------:|-----:|------:|------:|---------:|----------:|
| Q0L0.R   | 307.3 |  285.6 |    7.05% | "95" | 4.64M | 4.66M |     1.00 | 0:02'18'' |
| Q20L60.R | 302.9 |  283.7 |    6.35% | "95" | 4.64M | 4.63M |     1.00 | 0:02'16'' |
| Q25L60.R | 284.0 |  273.1 |    3.84% | "89" | 4.64M | 4.57M |     0.98 | 0:02'11'' |
| Q30L60.R | 238.3 |  233.5 |    2.03% | "75" | 4.64M | 4.56M |     0.98 | 0:01'53'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  95.96% |      9531 | 4.45M |  699 |        69 |  87.85K | 1652 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'53'' |
| Q0L0X40P001   |   40.0 |  96.19% |      9614 | 4.42M |  718 |       429 | 136.01K | 1669 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'54'' |
| Q0L0X40P002   |   40.0 |  96.02% |      9335 | 4.45M |  697 |        74 |  96.94K | 1711 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'51'' |
| Q0L0X40P003   |   40.0 |  96.03% |      9622 | 4.41M |  715 |       447 | 136.38K | 1708 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'52'' |
| Q0L0X40P004   |   40.0 |  96.20% |      9031 | 4.41M |  715 |       653 |  143.1K | 1653 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'52'' |
| Q0L0X40P005   |   40.0 |  96.20% |      8938 | 4.47M |  720 |        65 |  86.13K | 1719 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'53'' |
| Q0L0X80P000   |   80.0 |  92.26% |      4736 | 4.29M | 1185 |        63 | 129.49K | 2465 |   79.0 | 6.0 |  20.0 | 145.5 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'51'' |
| Q0L0X80P001   |   80.0 |  91.94% |      5060 | 4.28M | 1142 |        60 | 120.11K | 2399 |   79.0 | 6.0 |  20.0 | 145.5 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'52'' |
| Q0L0X80P002   |   80.0 |  92.17% |      4750 |  4.3M | 1166 |        56 | 116.96K | 2413 |   79.0 | 6.0 |  20.0 | 145.5 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'51'' |
| Q20L60X40P000 |   40.0 |  96.52% |     10283 | 4.41M |  667 |       487 | 146.04K | 1633 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'54'' |
| Q20L60X40P001 |   40.0 |  96.70% |     10018 | 4.43M |  682 |       319 | 129.98K | 1620 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'54'' |
| Q20L60X40P002 |   40.0 |  96.36% |      9855 | 4.41M |  703 |       645 | 153.21K | 1714 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'52'' |
| Q20L60X40P003 |   40.0 |  96.50% |     10276 | 4.47M |  645 |        62 |  79.92K | 1603 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'53'' |
| Q20L60X40P004 |   40.0 |  96.51% |      9928 | 4.44M |  687 |       391 | 132.87K | 1667 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'53'' |
| Q20L60X40P005 |   40.0 |  96.41% |      9864 |  4.4M |  702 |       664 | 160.15K | 1688 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'52'' |
| Q20L60X80P000 |   80.0 |  93.29% |      5477 | 4.34M | 1068 |        62 | 111.42K | 2214 |   79.0 | 6.0 |  20.0 | 145.5 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'53'' |
| Q20L60X80P001 |   80.0 |  93.23% |      5411 | 4.33M | 1084 |        67 |  121.9K | 2300 |   79.0 | 6.0 |  20.0 | 145.5 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'53'' |
| Q20L60X80P002 |   80.0 |  93.23% |      5484 | 4.34M | 1061 |        64 | 113.65K | 2218 |   79.0 | 6.0 |  20.0 | 145.5 | "31,41,51,61,71,81" | 0:01'20'' | 0:00'51'' |
| Q25L60X40P000 |   40.0 |  97.82% |     14981 | 4.45M |  501 |       638 | 162.89K | 1481 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'57'' |
| Q25L60X40P001 |   40.0 |  97.91% |     15337 | 4.46M |  481 |       614 | 145.85K | 1453 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'59'' |
| Q25L60X40P002 |   40.0 |  97.94% |     16645 | 4.45M |  474 |       698 | 158.93K | 1475 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'59'' |
| Q25L60X40P003 |   40.0 |  97.84% |     15126 | 4.46M |  511 |       527 | 147.07K | 1482 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'56'' |
| Q25L60X40P004 |   40.0 |  97.78% |     14442 | 4.44M |  516 |       678 | 163.63K | 1460 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'58'' |
| Q25L60X40P005 |   40.0 |  97.62% |     16136 | 4.44M |  489 |       652 |  145.8K | 1426 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'56'' |
| Q25L60X80P000 |   80.0 |  96.69% |     10118 | 4.47M |  647 |        76 |  82.48K | 1523 |   79.0 | 5.0 |  20.0 | 141.0 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'55'' |
| Q25L60X80P001 |   80.0 |  96.56% |     11160 | 4.47M |  635 |        66 |   75.8K | 1479 |   79.0 | 5.0 |  20.0 | 141.0 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'56'' |
| Q25L60X80P002 |   80.0 |  96.37% |      9860 | 4.46M |  656 |        58 |  67.29K | 1513 |   79.0 | 5.0 |  20.0 | 141.0 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'55'' |
| Q30L60X40P000 |   40.0 |  98.60% |     32897 |  4.5M |  257 |       569 | 114.71K | 1379 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'47'' | 0:01'07'' |
| Q30L60X40P001 |   40.0 |  98.54% |     30543 | 4.48M |  256 |       772 | 122.71K | 1374 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'47'' | 0:01'06'' |
| Q30L60X40P002 |   40.0 |  98.55% |     30821 | 4.49M |  277 |       746 | 136.68K | 1392 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'47'' | 0:01'04'' |
| Q30L60X40P003 |   40.0 |  98.56% |     30972 | 4.48M |  290 |      1007 | 136.84K | 1356 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'48'' | 0:01'04'' |
| Q30L60X40P004 |   40.0 |  98.57% |     29621 |  4.5M |  289 |       409 | 115.43K | 1447 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'48'' | 0:01'06'' |
| Q30L60X80P000 |   80.0 |  98.56% |     30012 | 4.48M |  287 |       686 | 118.98K | 1248 |   79.0 | 4.0 |  20.0 | 136.5 | "31,41,51,61,71,81" | 0:01'14'' | 0:01'10'' |
| Q30L60X80P001 |   80.0 |  98.47% |     30562 | 4.48M |  294 |      1038 | 144.48K | 1217 |   79.0 | 4.0 |  20.0 | 136.5 | "31,41,51,61,71,81" | 0:01'15'' | 0:01'07'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  98.28% |     30988 |  4.5M | 267 |       108 | 100.96K | 1254 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:01'04'' |
| Q0L0X40P001   |   40.0 |  98.20% |     28586 |  4.5M | 294 |       113 |  99.93K | 1256 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:01'04'' |
| Q0L0X40P002   |   40.0 |  98.27% |     27844 | 4.49M | 304 |       184 | 111.89K | 1356 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'38'' | 0:01'05'' |
| Q0L0X40P003   |   40.0 |  98.28% |     27213 |  4.5M | 301 |       198 | 106.25K | 1321 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'37'' | 0:01'03'' |
| Q0L0X40P004   |   40.0 |  98.18% |     30512 |  4.5M | 268 |       100 |   97.5K | 1226 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:01'02'' |
| Q0L0X40P005   |   40.0 |  98.28% |     29298 | 4.48M | 290 |       698 | 133.31K | 1287 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'37'' | 0:01'05'' |
| Q0L0X80P000   |   80.0 |  97.04% |     17314 | 4.49M | 422 |        61 |  64.52K | 1144 |   79.0 | 4.0 |  20.0 | 136.5 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'57'' |
| Q0L0X80P001   |   80.0 |  97.17% |     16043 | 4.49M | 443 |        55 |  62.99K | 1231 |   79.0 | 4.0 |  20.0 | 136.5 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'58'' |
| Q0L0X80P002   |   80.0 |  97.28% |     16254 | 4.49M | 442 |        65 |  72.19K | 1233 |   79.0 | 4.0 |  20.0 | 136.5 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'57'' |
| Q20L60X40P000 |   40.0 |  98.31% |     31084 | 4.49M | 278 |       192 | 110.12K | 1268 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:01'03'' |
| Q20L60X40P001 |   40.0 |  98.30% |     31997 | 4.49M | 279 |       411 | 113.83K | 1231 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'39'' | 0:01'04'' |
| Q20L60X40P002 |   40.0 |  98.09% |     29746 | 4.49M | 280 |       176 | 106.25K | 1224 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:01'01'' |
| Q20L60X40P003 |   40.0 |  98.32% |     29343 | 4.49M | 281 |       425 | 115.64K | 1291 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'38'' | 0:01'05'' |
| Q20L60X40P004 |   40.0 |  98.34% |     30923 |  4.5M | 274 |       117 | 103.22K | 1269 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:01'03'' |
| Q20L60X40P005 |   40.0 |  98.31% |     26892 | 4.49M | 286 |       172 | 113.41K | 1303 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:01'05'' |
| Q20L60X80P000 |   80.0 |  97.47% |     19540 | 4.49M | 378 |        73 |  70.37K | 1103 |   79.0 | 4.0 |  20.0 | 136.5 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'57'' |
| Q20L60X80P001 |   80.0 |  97.39% |     16521 | 4.49M | 426 |        85 |  81.81K | 1217 |   79.0 | 4.0 |  20.0 | 136.5 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'58'' |
| Q20L60X80P002 |   80.0 |  97.40% |     17315 | 4.49M | 423 |        60 |  65.84K | 1188 |   79.0 | 4.0 |  20.0 | 136.5 | "31,41,51,61,71,81" | 0:00'46'' | 0:00'58'' |
| Q25L60X40P000 |   40.0 |  98.47% |     28807 | 4.47M | 295 |       501 | 145.04K | 1370 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:01'05'' |
| Q25L60X40P001 |   40.0 |  98.52% |     30972 | 4.49M | 278 |       266 | 114.95K | 1339 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:01'06'' |
| Q25L60X40P002 |   40.0 |  98.51% |     31202 | 4.49M | 280 |       283 | 113.75K | 1330 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'38'' | 0:01'04'' |
| Q25L60X40P003 |   40.0 |  98.47% |     30895 | 4.49M | 280 |       466 | 130.03K | 1349 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:01'06'' |
| Q25L60X40P004 |   40.0 |  98.47% |     34253 | 4.49M | 253 |       428 | 120.26K | 1311 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:01'07'' |
| Q25L60X40P005 |   40.0 |  98.53% |     30923 | 4.48M | 284 |       539 | 142.25K | 1399 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'37'' | 0:01'05'' |
| Q25L60X80P000 |   80.0 |  98.13% |     22972 |  4.5M | 322 |       103 |  74.91K | 1132 |   79.0 | 4.0 |  20.0 | 136.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:01'03'' |
| Q25L60X80P001 |   80.0 |  98.11% |     22728 |  4.5M | 329 |        85 |  76.12K | 1168 |   79.0 | 4.0 |  20.0 | 136.5 | "31,41,51,61,71,81" | 0:00'46'' | 0:01'02'' |
| Q25L60X80P002 |   80.0 |  97.91% |     21452 | 4.49M | 344 |        92 |  78.81K | 1163 |   79.0 | 4.0 |  20.0 | 136.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:01'03'' |
| Q30L60X40P000 |   40.0 |  98.58% |     29351 |  4.5M | 288 |       569 |  133.1K | 1630 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'36'' | 0:01'06'' |
| Q30L60X40P001 |   40.0 |  98.53% |     29297 | 4.48M | 289 |       750 | 144.59K | 1615 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'37'' | 0:01'04'' |
| Q30L60X40P002 |   40.0 |  98.57% |     29319 | 4.49M | 299 |       858 | 146.47K | 1579 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'37'' | 0:01'05'' |
| Q30L60X40P003 |   40.0 |  98.51% |     25819 | 4.48M | 321 |       897 | 153.22K | 1615 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'37'' | 0:01'05'' |
| Q30L60X40P004 |   40.0 |  98.54% |     27568 |  4.5M | 309 |       605 | 150.82K | 1657 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'35'' | 0:01'04'' |
| Q30L60X80P000 |   80.0 |  98.62% |     33193 | 4.51M | 228 |       244 |  78.64K | 1222 |   80.0 | 5.0 |  20.0 | 142.5 | "31,41,51,61,71,81" | 0:00'44'' | 0:01'10'' |
| Q30L60X80P001 |   80.0 |  98.54% |     36290 |  4.5M | 241 |       584 |  84.22K | 1210 |   80.0 | 5.0 |  20.0 | 142.5 | "31,41,51,61,71,81" | 0:00'42'' | 0:01'10'' |


Table: statMRKunitigsAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  97.02% |     38032 | 4.49M | 204 |       131 | 56.71K | 469 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:01'02'' | 0:00'55'' |
| MRX40P001 |   40.0 |  96.99% |     33415 | 4.47M | 262 |       173 | 86.14K | 536 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'53'' |
| MRX40P002 |   40.0 |  96.97% |     32960 | 4.46M | 272 |       218 | 88.65K | 532 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'51'' |
| MRX40P003 |   40.0 |  97.03% |     32065 | 4.47M | 236 |       159 | 78.92K | 505 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'52'' |
| MRX40P004 |   40.0 |  96.95% |     32442 | 4.46M | 246 |       171 |  83.6K | 524 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'02'' | 0:00'53'' |
| MRX40P005 |   40.0 |  96.91% |     35088 | 4.47M | 249 |       157 | 75.16K | 510 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:01'02'' | 0:00'50'' |
| MRX80P000 |   80.0 |  96.11% |     26084 | 4.49M | 282 |       113 | 61.53K | 603 |   79.0 | 3.0 |  20.0 | 132.0 | "31,41,51,61,71,81" | 0:01'42'' | 0:00'50'' |
| MRX80P001 |   80.0 |  96.28% |     27466 | 4.48M | 277 |       120 | 65.81K | 609 |   79.0 | 3.0 |  20.0 | 132.0 | "31,41,51,61,71,81" | 0:01'43'' | 0:00'51'' |
| MRX80P002 |   80.0 |  96.21% |     27710 | 4.48M | 283 |       116 | 63.75K | 611 |   79.0 | 3.0 |  20.0 | 132.0 | "31,41,51,61,71,81" | 0:01'43'' | 0:00'51'' |
| MRX80P003 |   80.0 |  96.27% |     28782 | 4.48M | 266 |       114 | 61.59K | 588 |   79.0 | 4.0 |  20.0 | 136.5 | "31,41,51,61,71,81" | 0:01'42'' | 0:00'52'' |


Table: statMRTadpoleAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  96.76% |     49717 | 4.49M | 181 |       172 | 49.66K | 323 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'51'' |
| MRX40P001 |   40.0 |  96.79% |     45981 | 4.48M | 186 |       199 | 53.77K | 330 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'49'' |
| MRX40P002 |   40.0 |  96.81% |     46248 | 4.48M | 204 |       250 | 61.47K | 359 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'47'' |
| MRX40P003 |   40.0 |  96.78% |     49542 | 4.49M | 168 |       190 | 51.04K | 314 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'48'' |
| MRX40P004 |   40.0 |  96.76% |     47525 | 4.49M | 170 |       200 | 51.68K | 312 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'47'' |
| MRX40P005 |   40.0 |  96.78% |     49409 | 4.49M | 170 |       182 | 50.61K | 308 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'48'' |
| MRX80P000 |   80.0 |  96.54% |     42055 |  4.5M | 172 |       111 |  36.5K | 342 |   79.0 | 2.0 |  20.0 | 127.5 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'49'' |
| MRX80P001 |   80.0 |  96.59% |     47834 |  4.5M | 159 |       118 | 38.27K | 326 |   79.0 | 3.0 |  20.0 | 132.0 | "31,41,51,61,71,81" | 0:00'52'' | 0:00'52'' |
| MRX80P002 |   80.0 |  96.52% |     50580 |  4.5M | 170 |       111 | 38.46K | 345 |   79.0 | 3.0 |  20.0 | 132.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'49'' |
| MRX80P003 |   80.0 |  96.57% |     51829 |  4.5M | 159 |       112 | 36.84K | 321 |   79.0 | 3.0 |  20.0 | 132.0 | "31,41,51,61,71,81" | 0:00'51'' | 0:00'48'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median |  MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|-----:|------:|------:|----------:|
| 7_mergeAnchors           |  97.75% |     63631 | 4.53M | 120 |      1563 | 198.69K | 135 |  285.0 |  9.0 |  20.0 | 468.0 | 0:01'17'' |
| 7_mergeKunitigsAnchors   |  98.89% |     63411 | 4.53M | 125 |      1550 | 174.22K | 124 |  284.0 | 14.0 |  20.0 | 489.0 | 0:02'36'' |
| 7_mergeMRKunitigsAnchors |  98.87% |     63053 | 4.51M | 122 |      1197 |  64.92K |  57 |  285.0 | 11.0 |  20.0 | 477.0 | 0:02'07'' |
| 7_mergeMRTadpoleAnchors  |  98.75% |     63540 | 4.51M | 115 |      1197 |  60.35K |  54 |  285.0 | 10.0 |  20.0 | 472.5 | 0:01'54'' |
| 7_mergeTadpoleAnchors    |  99.05% |     63411 | 4.53M | 127 |      1514 | 168.84K | 118 |  285.0 | 11.0 |  20.0 | 477.0 | 0:02'15'' |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median |  MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|-----:|------:|------:|----------:|
| 8_spades     |  98.54% |    117621 | 4.53M |  76 |      1255 | 21.06K | 149 |  285.0 | 10.0 |  20.0 | 472.5 | 0:01'04'' |
| 8_spades_MR  |  98.40% |    132669 | 4.55M |  73 |      1246 | 15.89K | 145 |  371.0 |  9.5 |  20.0 | 599.2 | 0:01'02'' |
| 8_megahit    |  98.14% |     63050 | 4.52M | 119 |      1255 | 24.01K | 242 |  285.0 | 10.0 |  20.0 | 472.5 | 0:01'05'' |
| 8_megahit_MR |  98.37% |    102863 | 4.56M |  84 |      1218 | 15.85K | 169 |  371.0 |  8.5 |  20.0 | 594.8 | 0:01'01'' |
| 8_platanus   |  97.87% |    117593 | 4.54M |  79 |      1065 | 16.24K | 143 |  285.0 |  8.5 |  20.0 | 465.8 | 0:01'03'' |


Table: statCanu

| Name                |     N50 |     Sum |     # |
|:--------------------|--------:|--------:|------:|
| Genome              | 4641652 | 4641652 |     1 |
| Paralogs            |    1934 |  195673 |   106 |
| X80.trim.corrected  |   16820 | 175.59M | 10873 |
| Xall.trim.corrected |   20143 | 173.96M |  8468 |
| X80.trim.contig     | 4657933 | 4657933 |     1 |
| Xall.trim.contig    | 4670240 | 4670240 |     1 |


Table: statFinal

| Name                     |     N50 |     Sum |    # |
|:-------------------------|--------:|--------:|-----:|
| Genome                   | 4641652 | 4641652 |    1 |
| Paralogs                 |    1934 |  195673 |  106 |
| 7_mergeAnchors.anchors   |   63631 | 4525486 |  120 |
| 7_mergeAnchors.others    |    1563 |  198686 |  135 |
| anchorLong               |   63631 | 4525421 |  118 |
| anchorFill               |  651952 | 4577084 |   18 |
| canu_X80-trim            | 4657933 | 4657933 |    1 |
| canu_Xall-trim           | 4670240 | 4670240 |    1 |
| spades.contig            |  132608 | 4574638 |  138 |
| spades.scaffold          |  133063 | 4574668 |  135 |
| spades.non-contained     |  132608 | 4555782 |   74 |
| spades_MR.contig         |  148607 | 4587655 |  148 |
| spades_MR.scaffold       |  148607 | 4587755 |  147 |
| spades_MR.non-contained  |  148607 | 4569042 |   74 |
| megahit.contig           |   65422 | 4572359 |  200 |
| megahit.non-contained    |   65422 | 4548194 |  123 |
| megahit_MR.contig        |  110552 | 4630720 |  223 |
| megahit_MR.non-contained |  110552 | 4577919 |   86 |
| platanus.contig          |   14854 | 4712644 | 1174 |
| platanus.scaffold        |  148483 | 4577644 |  142 |
| platanus.non-contained   |  176491 | 4559860 |   64 |


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

    * [ERX1999216](https://www.ncbi.nlm.nih.gov/sra/ERX1999216)

        MiSeq (PE150) ERR1938683 PRJEB19900

    * [SRX2058864](https://www.ncbi.nlm.nih.gov/sra/SRX2058864)

        HiSeq 2500 (PE150, nextera) SRR4074255 PRJNA340312

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

* Rsync to hpcc

```bash
rsync -avP \
    --exclude="*_hdf5.tgz" \
    ~/data/anchr/s288c/ \
    wangq@202.119.37.251:data/anchr/s288c

# rsync -avP wangq@202.119.37.251:data/anchr/s288c/ ~/data/anchr/s288c

```

## s288c_MiSeq: symlink

```bash
mkdir -p ~/data/anchr/s288c_MiSeq/1_genome
cd ~/data/anchr/s288c_MiSeq/1_genome

ln -fs ../../s288c/1_genome/genome.fa genome.fa
ln -fs ../../s288c/1_genome/paralogs.fas paralogs.fas

mkdir -p ~/data/anchr/s288c_MiSeq/2_illumina
cd ~/data/anchr/s288c_MiSeq/2_illumina

ln -fs ../../s288c/2_illumina/ERR1938683_1.fastq.gz R1.fq.gz
ln -fs ../../s288c/2_illumina/ERR1938683_2.fastq.gz R2.fq.gz

```

## s288c_MiSeq: template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=s288c_MiSeq

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
    --parallel 24 \
    --xmx 110g

```

## s288c_MiSeq: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=s288c_MiSeq

cd ${WORKING_DIR}/${BASE_NAME}
#rm -fr 4_*/ 6_*/ 7_*/ 8_*/ && rm -fr 2_illumina/trim 2_illumina/mergereads statReads.md 

bash 0_bsub.sh
#bkill -J "${BASE_NAME}-*"

#bash 0_master.sh
#bash 0_cleanup.sh

```

Table: statInsertSize

| Group             |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:------------------|------:|-------:|------:|-------------------------------:|
| R.genome.bbtools  | 407.5 |    367 | 464.6 |                         48.81% |
| R.tadpole.bbtools | 394.8 |    360 | 139.2 |                         42.83% |
| R.genome.picard   | 402.1 |    367 | 142.1 |                             FR |
| R.tadpole.picard  | 394.4 |    360 | 139.4 |                             FR |


Table: statSgaStats

| Library | incorrectBases | perfectReads | overlapDepth |
|:--------|---------------:|-------------:|-------------:|
| R       |          0.14% |       89.85% |       111.58 |


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
| merged.raw    | 387 | 902.24M | 2398220 |
| unmerged.raw  | 190 | 287.35M | 1525736 |
| unmerged.trim | 190 | 287.35M | 1525732 |
| M1            | 387 | 900.07M | 2392217 |
| U1            | 190 | 144.09M |  762866 |
| U2            | 190 | 143.25M |  762866 |
| Us            |   0 |       0 |       0 |
| M.cor         | 354 |   1.19G | 6310166 |

| Group              |  Mean | Median | STDev | PercentOfPairs |
|:-------------------|------:|-------:|------:|---------------:|
| M.ihist.merge1.txt | 249.2 |    255 |  27.7 |         19.23% |
| M.ihist.merge.txt  | 376.2 |    371 |  72.7 |         75.87% |


Table: statQuorum

| Name     | CovIn | CovOut | Discard% |  Kmer |  RealG |   EstG | Est/Real |   RunTime |
|:---------|------:|-------:|---------:|------:|-------:|-------:|---------:|----------:|
| Q0L0.R   |  81.5 |   73.5 |    9.82% | "105" | 12.16M | 11.92M |     0.98 | 0:01'39'' |
| Q20L60.R |  80.6 |   73.6 |    8.64% | "105" | 12.16M | 11.86M |     0.98 | 0:01'38'' |
| Q25L60.R |  78.0 |   73.2 |    6.10% | "105" | 12.16M | 11.66M |     0.96 | 0:01'38'' |
| Q30L60.R |  73.5 |   70.7 |    3.76% | "105" | 12.16M |  11.6M |     0.95 | 0:01'34'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  79.60% |     11006 |    11M | 1566 |       107 | 326.14K | 3391 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:02'12'' | 0:01'21'' |
| Q0L0X60P000    |   60.0 |  78.61% |      8467 | 10.88M | 1887 |        89 | 361.06K | 4013 |   50.0 | 2.0 |  14.7 |  84.0 | "31,41,51,61,71,81" | 0:02'56'' | 0:01'25'' |
| Q0L0XallP000   |   73.5 |  78.27% |      7662 | 10.84M | 2007 |        84 |    371K | 4249 |   62.0 | 3.0 |  17.7 | 106.5 | "31,41,51,61,71,81" | 0:03'27'' | 0:01'26'' |
| Q20L60X40P000  |   40.0 |  80.06% |     11397 | 11.04M | 1487 |        99 | 295.25K | 3237 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:02'12'' | 0:01'21'' |
| Q20L60X60P000  |   60.0 |  78.91% |      8870 | 10.95M | 1814 |        85 | 314.12K | 3845 |   51.0 | 3.0 |  14.0 |  90.0 | "31,41,51,61,71,81" | 0:02'55'' | 0:01'25'' |
| Q20L60XallP000 |   73.6 |  78.50% |      8377 | 10.89M | 1932 |        82 | 340.25K | 4068 |   62.0 | 3.0 |  17.7 | 106.5 | "31,41,51,61,71,81" | 0:03'27'' | 0:01'27'' |
| Q25L60X40P000  |   40.0 |  82.20% |     18715 | 11.14M | 1019 |      1071 | 251.21K | 2359 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:02'12'' | 0:01'28'' |
| Q25L60X60P000  |   60.0 |  81.07% |     15722 | 11.11M | 1189 |      1039 | 246.91K | 2605 |   51.0 | 2.0 |  15.0 |  85.5 | "31,41,51,61,71,81" | 0:02'55'' | 0:01'25'' |
| Q25L60XallP000 |   73.2 |  80.76% |     14598 |  11.1M | 1242 |      1019 | 240.74K | 2689 |   62.0 | 3.0 |  17.7 | 106.5 | "31,41,51,61,71,81" | 0:03'24'' | 0:01'30'' |
| Q30L60X40P000  |   40.0 |  84.54% |     21333 | 11.15M |  891 |      1052 |  250.7K | 2237 |   34.0 | 1.0 |  10.3 |  55.5 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'28'' |
| Q30L60X60P000  |   60.0 |  83.22% |     18603 | 11.15M |  983 |      1056 | 226.81K | 2280 |   51.0 | 2.0 |  15.0 |  85.5 | "31,41,51,61,71,81" | 0:02'55'' | 0:01'31'' |
| Q30L60XallP000 |   70.7 |  82.93% |     18093 | 11.13M | 1030 |      1056 | 230.26K | 2347 |   60.0 | 2.0 |  18.0 |  99.0 | "31,41,51,61,71,81" | 0:03'18'' | 0:01'29'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  91.09% |     23999 | 11.17M |  760 |      1157 | 290.37K | 2270 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:01'36'' |
| Q0L0X60P000    |   60.0 |  89.56% |     19164 | 11.13M |  960 |      1077 | 283.96K | 2311 |   50.0 | 2.0 |  14.7 |  84.0 | "31,41,51,61,71,81" | 0:01'20'' | 0:01'31'' |
| Q0L0XallP000   |   73.5 |  88.93% |     15375 | 11.11M | 1148 |      1071 | 297.03K | 2552 |   62.0 | 3.0 |  17.7 | 106.5 | "31,41,51,61,71,81" | 0:01'32'' | 0:01'31'' |
| Q20L60X40P000  |   40.0 |  91.36% |     25531 | 11.18M |  723 |      1260 |  254.9K | 2178 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'08'' | 0:01'37'' |
| Q20L60X60P000  |   60.0 |  89.60% |     19765 | 11.16M |  917 |      1148 | 254.14K | 2194 |   51.0 | 2.0 |  15.0 |  85.5 | "31,41,51,61,71,81" | 0:01'21'' | 0:01'27'' |
| Q20L60XallP000 |   73.6 |  88.99% |     15699 | 11.11M | 1120 |      1081 | 289.21K | 2501 |   62.0 | 2.0 |  18.7 | 102.0 | "31,41,51,61,71,81" | 0:01'26'' | 0:01'29'' |
| Q25L60X40P000  |   40.0 |  92.11% |     28664 | 11.18M |  646 |      1260 | 280.38K | 2017 |   34.0 | 1.0 |  10.3 |  55.5 | "31,41,51,61,71,81" | 0:01'08'' | 0:01'43'' |
| Q25L60X60P000  |   60.0 |  90.73% |     26218 | 11.18M |  725 |      2215 |  260.6K | 1837 |   51.0 | 2.0 |  15.0 |  85.5 | "31,41,51,61,71,81" | 0:01'20'' | 0:01'29'' |
| Q25L60XallP000 |   73.2 |  89.99% |     22471 | 11.17M |  831 |      1683 | 249.06K | 1941 |   62.0 | 2.0 |  18.7 | 102.0 | "31,41,51,61,71,81" | 0:01'26'' | 0:01'29'' |
| Q30L60X40P000  |   40.0 |  92.68% |     29460 | 11.19M |  651 |      1273 | 269.58K | 2189 |   34.0 | 1.0 |  10.3 |  55.5 | "31,41,51,61,71,81" | 0:01'09'' | 0:01'49'' |
| Q30L60X60P000  |   60.0 |  91.58% |     27292 | 11.19M |  680 |      1976 |  237.3K | 1945 |   51.0 | 2.0 |  15.0 |  85.5 | "31,41,51,61,71,81" | 0:01'20'' | 0:01'40'' |
| Q30L60XallP000 |   70.7 |  91.14% |     25656 | 11.18M |  712 |      1671 | 234.19K | 1924 |   60.0 | 2.0 |  18.0 |  99.0 | "31,41,51,61,71,81" | 0:01'25'' | 0:01'34'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  86.21% |     16878 | 11.06M | 1088 |       152 | 306.97K | 2309 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:02'38'' | 0:01'21'' |
| MRX40P001  |   40.0 |  84.20% |     16857 | 11.03M | 1069 |       158 | 314.89K | 2281 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:02'36'' | 0:01'19'' |
| MRX60P000  |   60.0 |  82.82% |     13426 |    11M | 1312 |       116 |  318.7K | 2766 |   51.0 | 3.0 |  14.0 |  90.0 | "31,41,51,61,71,81" | 0:03'33'' | 0:01'21'' |
| MRX80P000  |   80.0 |  81.01% |     12126 | 10.93M | 1461 |       113 | 359.88K | 3062 |   68.0 | 4.0 |  18.7 | 120.0 | "31,41,51,61,71,81" | 0:04'30'' | 0:01'24'' |
| MRXallP000 |   97.9 |  80.42% |     11042 | 10.94M | 1548 |       102 | 336.96K | 3235 |   83.0 | 5.0 |  20.0 | 147.0 | "31,41,51,61,71,81" | 0:05'21'' | 0:01'27'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  89.38% |     35974 | 11.16M |  553 |      1152 | 227.33K | 1236 |   34.0 | 2.0 |   9.3 |  60.0 | "31,41,51,61,71,81" | 0:01'17'' | 0:01'21'' |
| MRX40P001  |   40.0 |  89.04% |     34185 | 11.13M |  581 |      1138 | 245.86K | 1240 |   34.0 | 1.0 |  10.3 |  55.5 | "31,41,51,61,71,81" | 0:01'17'' | 0:01'21'' |
| MRX60P000  |   60.0 |  88.89% |     26720 | 11.14M |  715 |      1122 | 253.28K | 1517 |   51.0 | 2.0 |  15.0 |  85.5 | "31,41,51,61,71,81" | 0:01'29'' | 0:01'24'' |
| MRX80P000  |   80.0 |  88.38% |     20744 |  11.1M |  884 |      1038 | 269.63K | 1851 |   68.0 | 3.0 |  19.7 | 115.5 | "31,41,51,61,71,81" | 0:01'40'' | 0:01'23'' |
| MRXallP000 |   97.9 |  88.15% |     18021 | 11.11M | 1025 |      1039 | 252.49K | 2139 |   83.0 | 4.0 |  20.0 | 142.5 | "31,41,51,61,71,81" | 0:01'55'' | 0:01'23'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |    Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|-------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |  83.04% |     45312 | 11.17M | 437 |      4408 |  357.7K | 148 |   62.0 | 2.0 |  18.7 | 102.0 | 0:01'45'' |
| 7_mergeKunitigsAnchors   |  87.99% |     25473 | 11.16M | 723 |      2249 | 269.67K | 149 |   62.0 | 2.0 |  18.7 | 102.0 | 0:02'24'' |
| 7_mergeMRKunitigsAnchors |  86.36% |     22825 | 11.08M | 804 |      1810 | 210.88K | 123 |   62.0 | 2.0 |  18.7 | 102.0 | 0:02'10'' |
| 7_mergeMRTadpoleAnchors  |  86.46% |     42887 | 11.14M | 465 |      3723 | 222.27K | 102 |   62.0 | 2.0 |  18.7 | 102.0 | 0:02'07'' |
| 7_mergeTadpoleAnchors    |  88.78% |     37694 | 11.19M | 499 |      6149 | 307.29K | 115 |   62.0 | 2.0 |  18.7 | 102.0 | 0:02'34'' |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |    Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|-------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|----------:|
| 8_spades     |  92.23% |     86250 | 11.29M | 234 |      5078 | 238.75K | 438 |   62.0 | 2.0 |  18.7 | 102.0 | 0:01'23'' |
| 8_spades_MR  |  94.36% |    117469 |  11.4M | 201 |      5239 |  201.4K | 397 |   84.0 | 3.0 |  20.0 | 139.5 | 0:01'24'' |
| 8_megahit    |  92.51% |     48143 | 11.21M | 423 |      2897 | 251.66K | 895 |   62.0 | 2.0 |  18.7 | 102.0 | 0:01'25'' |
| 8_megahit_MR |  93.52% |     86242 | 11.44M | 279 |      4348 | 203.63K | 584 |   84.0 | 3.0 |  20.0 | 139.5 | 0:01'22'' |
| 8_platanus   |  83.47% |     77257 | 11.33M | 256 |      2889 | 185.92K | 428 |   62.0 | 2.0 |  18.7 | 102.0 | 0:01'23'' |


Table: statFinal

| Name                     |    N50 |      Sum |    # |
|:-------------------------|-------:|---------:|-----:|
| Genome                   | 924431 | 12157105 |   17 |
| Paralogs                 |   3851 |  1059148 |  366 |
| 7_mergeAnchors.anchors   |  45312 | 11165036 |  437 |
| 7_mergeAnchors.others    |   4408 |   357697 |  148 |
| spades.contig            | 120316 | 11706235 | 1101 |
| spades.scaffold          | 132560 | 11706875 | 1082 |
| spades.non-contained     | 122873 | 11528443 |  204 |
| spades_MR.contig         | 125460 | 11732806 |  665 |
| spades_MR.scaffold       | 132728 | 11733422 |  655 |
| spades_MR.non-contained  | 126627 | 11605087 |  196 |
| megahit.contig           |  49142 | 11641716 |  955 |
| megahit.non-contained    |  49287 | 11462033 |  472 |
| megahit_MR.contig        |  84455 | 12007715 | 1274 |
| megahit_MR.non-contained |  86307 | 11640863 |  305 |
| platanus.contig          |  39177 | 12113080 | 4268 |
| platanus.scaffold        | 153178 | 11959734 | 3270 |
| platanus.non-contained   | 155016 | 11514764 |  172 |


## s288c_HiSeq: symlink

```bash
mkdir -p ~/data/anchr/s288c_HiSeq/1_genome
cd ~/data/anchr/s288c_HiSeq/1_genome

ln -fs ../../s288c/1_genome/genome.fa genome.fa
ln -fs ../../s288c/1_genome/paralogs.fas paralogs.fas

mkdir -p ~/data/anchr/s288c_HiSeq/2_illumina
cd ~/data/anchr/s288c_HiSeq/2_illumina

ln -fs ../../s288c/2_illumina/SRR4074255_1.fastq.gz R1.fq.gz
ln -fs ../../s288c/2_illumina/SRR4074255_2.fastq.gz R2.fq.gz

```

## s288c_HiSeq: template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=s288c_HiSeq

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
    --cov2 "40 80" \
    --tadpole \
    --statp 5 \
    --redoanchors \
    --parallel 24 \
    --xmx 110g

```

## s288c_HiSeq: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=s288c_HiSeq

cd ${WORKING_DIR}/${BASE_NAME}
#rm -fr 4_*/ 6_*/ 7_*/ 8_*/ && rm -fr 2_illumina/trim 2_illumina/mergereads statReads.md 

bash 0_bsub.sh
#bkill -J "${BASE_NAME}-*"

#bash 0_master.sh
#bash 0_cleanup.sh

```

Table: statInsertSize

| Group             |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:------------------|------:|-------:|------:|-------------------------------:|
| R.genome.bbtools  | 356.5 |    320 | 484.3 |                         45.78% |
| R.tadpole.bbtools | 339.2 |    309 | 144.5 |                         43.32% |
| R.genome.picard   | 352.1 |    322 | 142.5 |                             FR |
| R.tadpole.picard  | 342.8 |    313 | 141.4 |                             FR |


Table: statSgaStats

| Library | incorrectBases | perfectReads | overlapDepth |
|:--------|---------------:|-------------:|-------------:|
| R       |          0.23% |       88.56% |      2188.74 |


Table: statReads

| Name       |    N50 |      Sum |        # |
|:-----------|-------:|---------:|---------:|
| Genome     | 924431 | 12157105 |       17 |
| Paralogs   |   3851 |  1059148 |      366 |
| Illumina.R |    151 |    2.94G | 19464114 |
| trim.R     |    150 |    2.68G | 18163836 |
| Q20L60     |    150 |    2.63G | 17869582 |
| Q25L60     |    150 |    2.52G | 17275353 |
| Q30L60     |    150 |    2.37G | 16421056 |


Table: statTrimReads

| Name     | N50 |   Sum |        # |
|:---------|----:|------:|---------:|
| clumpify | 151 | 2.78G | 18397208 |
| trim     | 150 | 2.68G | 18163836 |
| filter   | 150 | 2.68G | 18163836 |
| R1       | 150 | 1.34G |  9081918 |
| R2       | 150 | 1.34G |  9081918 |
| Rs       |   0 |     0 |        0 |


```text
#R.trim
#Matched	976734	5.30914%
#Name	Reads	ReadsPct
I5_Nextera_Transposase_1	571978	3.10905%
I7_Nextera_Transposase_1	393836	2.14074%
```

```text
#R.filter
#Matched	0	0.00000%
#Name	Reads	ReadsPct
```

```text
#R.peaks
#k	31
#unique_kmers	89032436
#main_peak	165
#genome_size	11714528
#haploid_genome_size	11714528
#fold_coverage	165
#haploid_fold_coverage	165
#ploidy	1
#percent_repeat	10.541
#start	center	stop	max	volume
```


Table: statMergeReads

| Name          | N50 |     Sum |        # |
|:--------------|----:|--------:|---------:|
| clumped       | 150 |   2.68G | 18136794 |
| ecco          | 150 |   2.68G | 18136794 |
| eccc          | 150 |   2.68G | 18136794 |
| ecct          | 150 |   2.57G | 17415786 |
| extended      | 190 |   3.25G | 17415786 |
| merged.raw    | 356 |    2.4G |  7289590 |
| unmerged.raw  | 190 | 527.76M |  2836606 |
| unmerged.trim | 190 | 527.76M |  2836598 |
| M1            | 356 |   2.35G |  7138027 |
| U1            | 190 |  267.2M |  1418299 |
| U2            | 190 | 260.56M |  1418299 |
| Us            |   0 |       0 |        0 |
| M.cor         | 327 |   2.88G | 17112652 |

| Group              |  Mean | Median | STDev | PercentOfPairs |
|:-------------------|------:|-------:|------:|---------------:|
| M.ihist.merge1.txt | 211.2 |    221 |  53.0 |         39.55% |
| M.ihist.merge.txt  | 328.9 |    326 |  95.0 |         83.71% |


Table: statQuorum

| Name     | CovIn | CovOut | Discard% |  Kmer |  RealG |   EstG | Est/Real |   RunTime |
|:---------|------:|-------:|---------:|------:|-------:|-------:|---------:|----------:|
| Q0L0.R   | 220.4 |  197.9 |   10.20% | "105" | 12.16M | 12.44M |     1.02 | 0:04'16'' |
| Q20L60.R | 216.0 |  197.7 |    8.46% | "105" | 12.16M | 12.14M |     1.00 | 0:04'10'' |
| Q25L60.R | 207.2 |  195.1 |    5.84% | "105" | 12.16M | 11.84M |     0.97 | 0:04'00'' |
| Q30L60.R | 195.2 |  186.0 |    4.71% | "105" | 12.16M | 11.72M |     0.96 | 0:03'47'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |   Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|-------:|-----:|----------:|------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  87.86% |      4916 | 10.08M | 2700 |       912 | 1.56M | 6179 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:02'12'' | 0:01'38'' |
| Q0L0X40P001   |   40.0 |  87.94% |      3737 |  9.61M | 3145 |      1008 | 2.22M | 6855 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'12'' | 0:01'38'' |
| Q0L0X40P002   |   40.0 |  87.94% |      3685 |  9.58M | 3187 |      1014 | 2.25M | 6863 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'35'' |
| Q0L0X40P003   |   40.0 |  87.99% |      3785 |  9.63M | 3104 |      1022 |  2.2M | 6746 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'12'' | 0:01'38'' |
| Q0L0X80P000   |   80.0 |  86.02% |      4780 | 10.13M | 2757 |       902 | 1.36M | 5542 |   74.0 | 7.0 |  17.7 | 142.5 | "31,41,51,61,71,81" | 0:03'37'' | 0:01'36'' |
| Q0L0X80P001   |   80.0 |  85.89% |      4106 |  9.87M | 2993 |       979 | 1.64M | 5762 |   73.0 | 6.0 |  18.3 | 136.5 | "31,41,51,61,71,81" | 0:03'37'' | 0:01'36'' |
| Q20L60X40P000 |   40.0 |  88.36% |      3847 |  9.63M | 3110 |      1039 | 2.28M | 6668 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'37'' |
| Q20L60X40P001 |   40.0 |  88.03% |      3779 |  9.61M | 3094 |      1046 | 2.23M | 6549 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'12'' | 0:01'38'' |
| Q20L60X40P002 |   40.0 |  88.07% |      3754 |  9.64M | 3132 |      1002 | 2.21M | 6671 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'35'' |
| Q20L60X40P003 |   40.0 |  87.94% |      3894 |  9.68M | 3090 |      1024 | 2.17M | 6563 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'37'' |
| Q20L60X80P000 |   80.0 |  86.55% |      4937 | 10.19M | 2698 |       909 | 1.33M | 5308 |   74.0 | 7.0 |  17.7 | 142.5 | "31,41,51,61,71,81" | 0:03'36'' | 0:01'35'' |
| Q20L60X80P001 |   80.0 |  86.55% |      4961 | 10.19M | 2694 |       868 | 1.31M | 5345 |   74.0 | 7.0 |  17.7 | 142.5 | "31,41,51,61,71,81" | 0:03'36'' | 0:01'40'' |
| Q25L60X40P000 |   40.0 |  88.74% |      3769 |  9.69M | 3152 |      1028 | 2.24M | 6884 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'10'' | 0:01'40'' |
| Q25L60X40P001 |   40.0 |  88.74% |      3884 |  9.69M | 3066 |      1030 | 2.22M | 6723 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'37'' |
| Q25L60X40P002 |   40.0 |  88.70% |      3887 |  9.68M | 3086 |      1036 | 2.18M | 6644 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'10'' | 0:01'40'' |
| Q25L60X40P003 |   40.0 |  88.87% |      3915 |  9.67M | 3082 |      1037 | 2.21M | 6733 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'37'' |
| Q25L60X80P000 |   80.0 |  86.94% |      4525 | 10.05M | 2793 |       970 | 1.47M | 5390 |   74.0 | 6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:03'36'' | 0:01'39'' |
| Q25L60X80P001 |   80.0 |  87.48% |      5185 |  10.2M | 2603 |       924 | 1.35M | 5373 |   74.0 | 7.0 |  17.7 | 142.5 | "31,41,51,61,71,81" | 0:03'35'' | 0:01'41'' |
| Q30L60X40P000 |   40.0 |  89.37% |      3913 |   9.7M | 3086 |      1039 | 2.22M | 6707 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'40'' |
| Q30L60X40P001 |   40.0 |  89.25% |      3940 |  9.65M | 3040 |      1064 | 2.27M | 6739 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'10'' | 0:01'40'' |
| Q30L60X40P002 |   40.0 |  89.18% |      4069 |  9.76M | 2989 |      1042 | 2.13M | 6580 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'41'' |
| Q30L60X40P003 |   40.0 |  89.39% |      3979 |  9.72M | 3019 |      1021 | 2.19M | 6703 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'38'' |
| Q30L60X80P000 |   80.0 |  88.03% |      4692 | 10.06M | 2772 |       935 | 1.57M | 5655 |   74.0 | 6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:03'34'' | 0:01'42'' |
| Q30L60X80P001 |   80.0 |  88.01% |      4765 | 10.09M | 2762 |       962 | 1.54M | 5620 |   74.0 | 6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:03'34'' | 0:01'45'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |   Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|-------:|-----:|----------:|------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  91.70% |      4038 |  9.75M | 3024 |      1010 |  2.1M | 6881 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'09'' | 0:01'39'' |
| Q0L0X40P001   |   40.0 |  91.65% |      5564 | 10.23M | 2508 |       890 | 1.41M | 6238 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:01'09'' | 0:01'40'' |
| Q0L0X40P002   |   40.0 |  91.73% |      3961 |  9.74M | 3037 |      1016 | 2.13M | 6932 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'09'' | 0:01'40'' |
| Q0L0X40P003   |   40.0 |  91.88% |      4135 |  9.78M | 2945 |      1014 | 2.14M | 6839 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'09'' | 0:01'40'' |
| Q0L0X80P000   |   80.0 |  92.37% |      5222 | 10.18M | 2598 |       932 | 1.71M | 6094 |   74.0 | 6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:01'30'' | 0:01'55'' |
| Q0L0X80P001   |   80.0 |  92.23% |      5154 | 10.16M | 2585 |       911 | 1.65M | 6002 |   74.0 | 6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:01'33'' | 0:01'51'' |
| Q20L60X40P000 |   40.0 |  92.06% |      4105 |   9.8M | 2971 |      1021 | 2.17M | 6911 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'09'' | 0:01'42'' |
| Q20L60X40P001 |   40.0 |  91.87% |      4060 |  9.74M | 2957 |      1011 |  2.1M | 6731 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'07'' | 0:01'36'' |
| Q20L60X40P002 |   40.0 |  92.02% |      3999 |  9.78M | 3004 |       997 | 2.12M | 6949 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:01'39'' |
| Q20L60X40P003 |   40.0 |  91.74% |      5468 | 10.28M | 2482 |       873 | 1.38M | 6164 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:01'10'' | 0:01'41'' |
| Q20L60X80P000 |   80.0 |  92.58% |      5164 | 10.21M | 2615 |       892 | 1.69M | 6112 |   74.0 | 6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:01'32'' | 0:01'54'' |
| Q20L60X80P001 |   80.0 |  92.47% |      5194 |  10.2M | 2584 |       924 | 1.68M | 6063 |   74.0 | 6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:01'30'' | 0:01'49'' |
| Q25L60X40P000 |   40.0 |  92.19% |      4076 |   9.8M | 3010 |      1007 | 2.08M | 7006 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'09'' | 0:01'41'' |
| Q25L60X40P001 |   40.0 |  92.22% |      4085 |  9.81M | 2974 |      1004 | 2.09M | 7003 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'09'' | 0:01'39'' |
| Q25L60X40P002 |   40.0 |  92.20% |      4160 |  9.82M | 2968 |      1031 | 2.07M | 6797 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'13'' | 0:01'37'' |
| Q25L60X40P003 |   40.0 |  92.04% |      5686 | 10.28M | 2473 |       871 | 1.36M | 6129 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:01'08'' | 0:01'39'' |
| Q25L60X80P000 |   80.0 |  92.94% |      5213 | 10.25M | 2551 |       932 | 1.64M | 6127 |   74.0 | 6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:01'33'' | 0:01'53'' |
| Q25L60X80P001 |   80.0 |  92.97% |      5278 | 10.19M | 2552 |       982 | 1.72M | 6128 |   74.0 | 6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:01'32'' | 0:01'55'' |
| Q30L60X40P000 |   40.0 |  92.38% |      4131 |  9.77M | 2963 |      1035 | 2.14M | 6882 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'09'' | 0:01'41'' |
| Q30L60X40P001 |   40.0 |  92.35% |      4169 |  9.75M | 2968 |      1034 | 2.16M | 6954 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'08'' | 0:01'39'' |
| Q30L60X40P002 |   40.0 |  92.17% |      4245 |  9.85M | 2926 |      1018 | 1.98M | 6715 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:01'40'' |
| Q30L60X40P003 |   40.0 |  92.32% |      4245 |  9.82M | 2920 |       992 |    2M | 6779 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:01'38'' |
| Q30L60X80P000 |   80.0 |  93.24% |      5405 | 10.24M | 2546 |       890 | 1.68M | 6245 |   75.0 | 6.0 |  19.0 | 139.5 | "31,41,51,61,71,81" | 0:01'36'' | 0:01'58'' |
| Q30L60X80P001 |   80.0 |  93.15% |      5723 |  10.3M | 2454 |       883 | 1.56M | 6030 |   75.0 | 6.0 |  19.0 | 139.5 | "31,41,51,61,71,81" | 0:01'31'' | 0:01'56'' |


Table: statMRKunitigsAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|-------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  85.72% |      4749 |  9.98M | 2728 |       995 |   1.45M | 4420 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'37'' | 0:01'23'' |
| MRX40P001 |   40.0 |  85.51% |      4723 |  9.97M | 2758 |      1009 |   1.49M | 4483 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'38'' | 0:01'25'' |
| MRX40P002 |   40.0 |  85.41% |      4630 |  9.95M | 2743 |       988 |    1.5M | 4498 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'38'' | 0:01'24'' |
| MRX40P003 |   40.0 |  85.13% |      4698 |  9.95M | 2728 |       984 |   1.49M | 4365 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'37'' | 0:01'23'' |
| MRX40P004 |   40.0 |  85.39% |      4759 |  9.96M | 2719 |      1024 |   1.52M | 4411 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:02'38'' | 0:01'25'' |
| MRX80P000 |   80.0 |  83.77% |      6213 | 10.33M | 2299 |       842 | 975.19K | 3860 |   74.0 | 7.0 |  17.7 | 142.5 | "31,41,51,61,71,81" | 0:04'31'' | 0:01'24'' |
| MRX80P001 |   80.0 |  83.45% |      6162 | 10.31M | 2338 |       880 |  988.1K | 3887 |   74.0 | 7.0 |  17.7 | 142.5 | "31,41,51,61,71,81" | 0:04'30'' | 0:01'23'' |


Table: statMRTadpoleAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |   Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|-------:|-----:|----------:|------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  90.57% |      5153 | 10.12M | 2600 |       953 | 1.57M | 4922 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'16'' | 0:01'35'' |
| MRX40P001 |   40.0 |  90.79% |      4996 | 10.07M | 2649 |       986 | 1.68M | 5048 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'17'' | 0:01'34'' |
| MRX40P002 |   40.0 |  90.64% |      5108 | 10.08M | 2579 |       973 | 1.61M | 4918 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'17'' | 0:01'33'' |
| MRX40P003 |   40.0 |  90.84% |      5160 | 10.08M | 2592 |       923 | 1.63M | 5006 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'20'' | 0:01'37'' |
| MRX40P004 |   40.0 |  90.28% |      5113 | 10.07M | 2595 |       992 | 1.58M | 4773 |   37.0 | 3.0 |   9.3 |  69.0 | "31,41,51,61,71,81" | 0:01'25'' | 0:01'33'' |
| MRX80P000 |   80.0 |  89.25% |      6198 | 10.34M | 2285 |       878 | 1.11M | 3779 |   74.0 | 6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:01'44'' | 0:01'30'' |
| MRX80P001 |   80.0 |  89.16% |      6246 | 10.38M | 2271 |       890 | 1.11M | 3767 |   74.0 | 6.0 |  18.7 | 138.0 | "31,41,51,61,71,81" | 0:01'44'' | 0:01'30'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |    Sum |    # | N50Others |   Sum |    # | median |  MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|-------:|-----:|----------:|------:|-----:|-------:|-----:|------:|------:|----------:|
| 7_mergeAnchors           |  87.98% |     15838 | 11.04M | 1214 |      1865 | 4.58M | 2838 |  185.0 | 15.0 |  20.0 | 345.0 | 0:02'11'' |
| 7_mergeKunitigsAnchors   |  93.15% |     11881 | 10.99M | 1532 |      1732 | 4.64M | 3068 |  186.0 | 18.0 |  20.0 | 360.0 | 0:03'46'' |
| 7_mergeMRKunitigsAnchors |  90.74% |     11000 | 10.86M | 1551 |      1472 | 2.22M | 1666 |  185.0 | 16.0 |  20.0 | 349.5 | 0:02'58'' |
| 7_mergeMRTadpoleAnchors  |  90.92% |     11600 | 10.96M | 1508 |      1449 |  2.2M | 1672 |  185.0 | 16.0 |  20.0 | 349.5 | 0:02'55'' |
| 7_mergeTadpoleAnchors    |  93.06% |     13491 | 11.01M | 1411 |      1666 | 4.38M | 2984 |  185.0 | 17.0 |  20.0 | 354.0 | 0:03'41'' |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |    Sum |   # | N50Others |     Sum |    # | median |  MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|-------:|----:|----------:|--------:|-----:|-------:|-----:|------:|------:|----------:|
| 8_spades     |  92.44% |     38385 | 11.18M | 597 |      1374 | 321.66K |  874 |  185.0 | 13.0 |  20.0 | 336.0 | 0:01'42'' |
| 8_spades_MR  |  92.77% |     54113 | 11.28M | 504 |      1423 |  285.8K |  778 |  223.0 | 15.0 |  20.0 | 402.0 | 0:01'39'' |
| 8_megahit    |  90.24% |     27923 |  11.1M | 789 |      1247 | 326.17K | 1327 |  184.0 | 13.0 |  20.0 | 334.5 | 0:01'41'' |
| 8_megahit_MR |  92.42% |     41053 | 11.35M | 554 |      1356 | 259.74K |  998 |  223.0 | 17.0 |  20.0 | 411.0 | 0:01'39'' |
| 8_platanus   |  89.43% |     24429 | 11.06M | 895 |      1045 | 278.25K | 1420 |  186.0 | 12.0 |  20.0 | 333.0 | 0:01'40'' |


Table: statFinal

| Name                     |    N50 |      Sum |    # |
|:-------------------------|-------:|---------:|-----:|
| Genome                   | 924431 | 12157105 |   17 |
| Paralogs                 |   3851 |  1059148 |  366 |
| 7_mergeAnchors.anchors   |  15838 | 11040979 | 1214 |
| 7_mergeAnchors.others    |   1865 |  4578703 | 2838 |
| spades.contig            | 100082 | 11686050 | 1204 |
| spades.scaffold          | 107598 | 11686780 | 1176 |
| spades.non-contained     | 102809 | 11499948 |  278 |
| spades_MR.contig         |  98750 | 11754736 | 1017 |
| spades_MR.scaffold       | 117682 | 11758642 |  979 |
| spades_MR.non-contained  |  99683 | 11565634 |  275 |
| megahit.contig           |  37720 | 11623866 | 1050 |
| megahit.non-contained    |  39093 | 11421408 |  539 |
| megahit_MR.contig        |  48765 | 12102411 | 1816 |
| megahit_MR.non-contained |  50037 | 11606236 |  448 |
| platanus.contig          |   4797 | 12324154 | 6839 |
| platanus.scaffold        |  38569 | 11887603 | 3658 |
| platanus.non-contained   |  40566 | 11339030 |  527 |


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

    * [ERX645969](https://www.ncbi.nlm.nih.gov/sra/?term=ERX645969)

        ERR701706-ERR701711 HiSeq 2000

    * [ERX645975](https://www.ncbi.nlm.nih.gov/sra/?term=ERX645975)

        ERR701712 ERR701713 HiSeq 2500 laboratory strain nos-GAL4; UAS-DCR2

    * SRX081846 labels ycnbwsp instead of iso-1.

```bash
mkdir -p ~/data/anchr/iso_1/2_illumina
cd ~/data/anchr/iso_1/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR701/ERR701706/ERR701706_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR701/ERR701706/ERR701706_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR701/ERR701707/ERR701707_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR701/ERR701707/ERR701707_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR701/ERR701708/ERR701708_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR701/ERR701708/ERR701708_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR701/ERR701709/ERR701709_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR701/ERR701709/ERR701709_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR701/ERR701710/ERR701710_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR701/ERR701710/ERR701710_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR701/ERR701711/ERR701711_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR701/ERR701711/ERR701711_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR701/ERR701712/ERR701712_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR701/ERR701712/ERR701712_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR701/ERR701713/ERR701713_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR701/ERR701713/ERR701713_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
a8a6c25c6c5c0fd0614cf922c2d362ce ERR701706_1.fastq.gz
7505f2615e64b9a23aa7b94d3fa0424b ERR701706_2.fastq.gz
f936e6a30cadb5ce23ab6fd3c37bbaed ERR701707_1.fastq.gz
bfd0a93a6a8381502a538a8154ee3837 ERR701707_2.fastq.gz
d731ac125513744c6d3225e97c3d03f5 ERR701708_1.fastq.gz
880638916636194987184d46db86b88e ERR701708_2.fastq.gz
d92e991965b291d1f642a8cb021f816a ERR701709_1.fastq.gz
fbd57f2c1b06f4b8e2f06f8f9df51758 ERR701709_2.fastq.gz
62abb11673775412afdceabf49360abc ERR701710_1.fastq.gz
dc4022980881e459b565997574311299 ERR701710_2.fastq.gz
3fca504995f8fac6083a916a2af2d702 ERR701711_1.fastq.gz
30b14bd452a5386efa2da48c262815b9 ERR701711_2.fastq.gz
a6066532b411192be13e9ff5231092f8 ERR701712_1.fastq.gz
d6ca4111786d6d554a615ea3a9a76137 ERR701712_2.fastq.gz
df6285d1c8f8f1a62396064e68eaba65 ERR701713_1.fastq.gz
668c7a8e70b1186584367609112f7909 ERR701713_2.fastq.gz
EOF

md5sum --check sra_md5.txt

pigz -d -c ERR7017{06..11}_1.fastq.gz | pigz > HiSeq_2000_1.fq.gz
pigz -d -c ERR7017{06..11}_2.fastq.gz | pigz > HiSeq_2000_2.fq.gz

pigz -d -c ERR7017{12,13}_1.fastq.gz | pigz > HiSeq_2500_1.fq.gz
pigz -d -c ERR7017{12,13}_2.fastq.gz | pigz > HiSeq_2500_2.fq.gz

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

* Rsync to hpcc

```bash
rsync -avP \
    --exclude="ERR70*" \
    --exclude="*.tgz" \
    ~/data/anchr/iso_1/ \
    wangq@202.119.37.251:data/anchr/iso_1

#rsync -avP wangq@202.119.37.251:data/anchr/iso_1/ ~/data/anchr/iso_1

```

## iso_1_HiSeq_2000: symlink

```bash
mkdir -p ~/data/anchr/iso_1_HiSeq_2000/1_genome
cd ~/data/anchr/iso_1_HiSeq_2000/1_genome

ln -fs ../../iso_1/1_genome/genome.fa genome.fa
ln -fs ../../iso_1/1_genome/paralogs.fas paralogs.fas

mkdir -p ~/data/anchr/iso_1_HiSeq_2000/2_illumina
cd ~/data/anchr/iso_1_HiSeq_2000/2_illumina

ln -fs ../../iso_1/2_illumina/HiSeq_2000_1.fq.gz R1.fq.gz
ln -fs ../../iso_1/2_illumina/HiSeq_2000_2.fq.gz R2.fq.gz

```

## iso_1_HiSeq_2000: template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=iso_1_HiSeq_2000

cd ${WORKING_DIR}/${BASE_NAME}

rm *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 137567477 \
    --is_euk \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --trim2 "--dedupe" \
    --qual2 "25" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,2,3" \
    --cov2 "40 80 all" \
    --tadpole \
    --statp 5 \
    --redoanchors \
    --parallel 24 \
    --xmx 110g

```

## iso_1_HiSeq_2000: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=iso_1_HiSeq_2000

cd ${WORKING_DIR}/${BASE_NAME}
#rm -fr 4_*/ 6_*/ 7_*/ 8_*/ && rm -fr 2_illumina/trim 2_illumina/mergereads statReads.md 

bash 0_bsub.sh
#bkill -J "${BASE_NAME}-*"

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


## iso_1_HiSeq_2500: symlink

```bash
mkdir -p ~/data/anchr/iso_1_HiSeq_2500/1_genome
cd ~/data/anchr/iso_1_HiSeq_2500/1_genome

ln -fs ../../iso_1/1_genome/genome.fa genome.fa
ln -fs ../../iso_1/1_genome/paralogs.fas paralogs.fas

mkdir -p ~/data/anchr/iso_1_HiSeq_2500/2_illumina
cd ~/data/anchr/iso_1_HiSeq_2500/2_illumina

ln -fs ../../iso_1/2_illumina/HiSeq_2500_1.fq.gz R1.fq.gz
ln -fs ../../iso_1/2_illumina/HiSeq_2500_2.fq.gz R2.fq.gz

```

## iso_1_HiSeq_2500: template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=iso_1_HiSeq_2500

cd ${WORKING_DIR}/${BASE_NAME}

rm *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 137567477 \
    --is_euk \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --trim2 "--dedupe" \
    --qual2 "25" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,2,3" \
    --cov2 "40 80 all" \
    --tadpole \
    --statp 5 \
    --redoanchors \
    --parallel 24 \
    --xmx 110g

```

## iso_1_HiSeq_2500: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=iso_1_HiSeq_2500

cd ${WORKING_DIR}/${BASE_NAME}
#rm -fr 4_*/ 6_*/ 7_*/ 8_*/ && rm -fr 2_illumina/trim 2_illumina/mergereads statReads.md 

bash 0_bsub.sh
#bkill -J "${BASE_NAME}-*"

#bash 0_master.sh
#bash 0_cleanup.sh

```

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

    * [SRX1321528](https://www.ncbi.nlm.nih.gov/sra/SRX1321528) SRR2598966

        HiSeq 2500 pe120, insert size 200(138)

    * [SRX697546](https://www.ncbi.nlm.nih.gov/sra/SRX697546) SRR1571299 7.5G
    * [SRX697551](https://www.ncbi.nlm.nih.gov/sra/SRX697551) SRR1571322 4G

        HiSeq 2000 pe100, insert size 200(68)

    * Other SRA
        * [SRX770040](https://www.ncbi.nlm.nih.gov/sra/SRX770040) - GEO
        * ERX1118232 - ERR1039478, 9.8G
        * DRX007633 - DRR008443 - GA II
        * SRX026594 - SRR065390 - GA II

```bash
# Downloading from ena with aria2
mkdir -p ~/data/anchr/n2/2_illumina
cd ~/data/anchr/n2/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR259/006/SRR2598966/SRR2598966_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR259/006/SRR2598966/SRR2598966_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR157/009/SRR1571299/SRR1571299_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR157/009/SRR1571299/SRR1571299_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR157/002/SRR1571322/SRR1571322_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR157/002/SRR1571322/SRR1571322_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
1f3f5dba991ad565263281c0770a12fa SRR2598966_1.fastq.gz
7fb98259f2f3feb7b82ba862ae57996a SRR2598966_2.fastq.gz
60e8b2981855b0af44a2ade68c09915f SRR1571299_1.fastq.gz
3f0e9d29a27df4f424d59a9d38196a6f SRR1571299_2.fastq.gz
11778477088b22a520218e236cc34502 SRR1571322_1.fastq.gz
5ac12fa22126e4393fc18a33cc5e7233 SRR1571322_2.fastq.gz
EOF

md5sum --check sra_md5.txt

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

* Rsync to hpcc

```bash
rsync -avP \
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
## n2_pe100: symlink

```bash
mkdir -p ~/data/anchr/n2_pe100/1_genome
cd ~/data/anchr/n2_pe100/1_genome

ln -fs ../../n2/1_genome/genome.fa genome.fa
ln -fs ../../n2/1_genome/paralogs.fas paralogs.fas

mkdir -p ~/data/anchr/n2_pe100/2_illumina
cd ~/data/anchr/n2_pe100/2_illumina

ln -fs ../../n2/2_illumina/SRR1571299_1.fastq.gz R1.fq.gz
ln -fs ../../n2/2_illumina/SRR1571299_2.fastq.gz R2.fq.gz

ln -fs ../../n2/2_illumina/SRR1571322_1.fastq.gz S1.fq.gz
ln -fs ../../n2/2_illumina/SRR1571322_2.fastq.gz S2.fq.gz

```

## n2_pe100: template

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=n2_pe100

cd ${WORKING_DIR}/${BASE_NAME}

rm -f *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 100286401 \
    --is_euk \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --trim2 "--dedupe" \
    --qual2 "25" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,3" \
    --cov2 "40 60 all" \
    --tadpole \
    --statp 5 \
    --redoanchors \
    --parallel 24 \
    --xmx 110g

```

## n2_pe100: run

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=n2_pe100

cd ${WORKING_DIR}/${BASE_NAME}
#rm -fr 4_*/ 6_*/ 7_*/ 8_*/ 2_illumina/trim 2_illumina/mergereads statReads.md 

bash 0_bsub.sh
#bkill -J "${BASE_NAME}-*"

#bash 0_master.sh
#bash 0_cleanup.sh

```


Table: statInsertSize

| Group             |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:------------------|------:|-------:|-------:|-------------------------------:|
| R.genome.bbtools  | 253.7 |    207 | 1041.8 |                         41.49% |
| R.tadpole.bbtools | 209.9 |    202 |   69.6 |                         41.78% |
| S.genome.bbtools  | 265.0 |    210 | 1147.9 |                         34.15% |
| S.tadpole.bbtools | 218.4 |    210 |   68.2 |                         42.09% |
| R.genome.picard   | 214.1 |    207 |   68.3 |                             FR |
| R.tadpole.picard  | 211.1 |    203 |   68.7 |                             FR |
| S.genome.picard   | 217.9 |    210 |   65.5 |                             FR |
| S.tadpole.picard  | 219.0 |    211 |   67.8 |                             FR |


Table: statReads

| Name       |      N50 |       Sum |        # |
|:-----------|---------:|----------:|---------:|
| Genome     | 17493829 | 100286401 |        7 |
| Paralogs   |     2013 |   5313653 |     2637 |
| Illumina.R |      100 |     7.54G | 75384334 |
| trim.R     |      100 |     2.41G | 25843048 |
| Q25L60     |      100 |      2.3G | 24729544 |
| Illumina.S |      100 |     4.02G | 40224592 |
| trim.S     |      100 |     1.29G | 13865668 |
| Q25L60     |      100 |     1.23G | 13221034 |


Table: statTrimReads

| Name     | N50 |     Sum |        # |
|:---------|----:|--------:|---------:|
| clumpify | 100 |   7.28G | 72804426 |
| trim     | 100 |   2.41G | 25843048 |
| filter   | 100 |   2.41G | 25843048 |
| R1       | 100 |   1.28G | 12921524 |
| R2       | 100 |   1.13G | 12921524 |
| Rs       |   0 |       0 |        0 |
| clumpify | 100 |   3.96G | 39627568 |
| trim     | 100 |   1.29G | 13865668 |
| filter   | 100 |   1.29G | 13865668 |
| S1       | 100 | 686.22M |  6932834 |
| S2       | 100 | 605.43M |  6932834 |
| Ss       |   0 |       0 |        0 |


```text
#R.trim
#Matched	758194	1.04141%
#Name	Reads	ReadsPct
TruSeq_Adapter_Index_1_6	310535	0.42653%
Reverse_adapter	184463	0.25337%
Nextera_LMP_Read2_External_Adapter	111769	0.15352%
```

```text
#R.filter
#Matched	0	0.00000%
#Name	Reads	ReadsPct
```

```text
#R.peaks
#k	31
#unique_kmers	123434456
#main_peak	12
#genome_size	113154381
#haploid_genome_size	113154381
#fold_coverage	12
#haploid_fold_coverage	12
#ploidy	1
#percent_repeat	22.111
#start	center	stop	max	volume
```


```text
#S.trim
#Matched	193156	0.48743%
#Name	Reads	ReadsPct
TruSeq_Adapter_Index_1_6	80521	0.20319%
```

```text
#S.filter
#Matched	0	0.00000%
#Name	Reads	ReadsPct
```

```text
#S.peaks
#k	31
#unique_kmers	111430061
#main_peak	5
#genome_size	141057416
#haploid_genome_size	141057416
#fold_coverage	5
#haploid_fold_coverage	5
#ploidy	1
#percent_repeat	38.894
#start	center	stop	max	volume
```


Table: statMergeReads

| Name          | N50 |     Sum |        # |
|:--------------|----:|--------:|---------:|
| clumped       | 100 |   2.41G | 25833480 |
| ecco          | 100 |   2.41G | 25833480 |
| ecct          | 100 |   2.33G | 25001866 |
| extended      | 140 |   3.13G | 25001866 |
| merged.raw    | 246 |   2.42G | 10411398 |
| unmerged.raw  | 133 | 442.46M |  4179070 |
| unmerged.trim | 133 | 442.42M |  4178516 |
| M1            | 246 |   2.41G | 10390539 |
| U1            | 140 | 272.57M |  2089258 |
| U2            |  87 | 169.85M |  2089258 |
| Us            |   0 |       0 |        0 |
| M.cor         | 230 |   2.87G | 24959594 |

| Group              |  Mean | Median | STDev | PercentOfPairs |
|:-------------------|------:|-------:|------:|---------------:|
| M.ihist.merge1.txt | 139.4 |    141 |  28.7 |         31.66% |
| M.ihist.merge.txt  | 232.3 |    227 |  65.9 |         83.28% |

| Name          | N50 |     Sum |        # |
|:--------------|----:|--------:|---------:|
| clumped       | 100 |   1.29G | 13862970 |
| ecco          | 100 |   1.29G | 13862970 |
| ecct          | 100 |    1.1G | 11863536 |
| extended      | 140 |   1.42G | 11863536 |
| merged.raw    | 241 | 939.12M |  4101691 |
| unmerged.raw  | 120 | 387.44M |  3660154 |
| unmerged.trim | 120 | 387.41M |  3659816 |
| N1            | 241 |    938M |  4096621 |
| V1            | 127 | 227.05M |  1829908 |
| V2            | 110 | 160.35M |  1829908 |
| Vs            |   0 |       0 |        0 |
| N.cor         | 207 |   1.33G | 11853058 |

| Group              |  Mean | Median | STDev | PercentOfPairs |
|:-------------------|------:|-------:|------:|---------------:|
| N.ihist.merge1.txt | 145.9 |    149 |  27.0 |         26.19% |
| N.ihist.merge.txt  | 229.0 |    223 |  63.8 |         69.15% |


Table: statQuorum

| Name     | CovIn | CovOut | Discard% | Kmer |   RealG |   EstG | Est/Real |   RunTime |
|:---------|------:|-------:|---------:|-----:|--------:|-------:|---------:|----------:|
| Q0L0.R   |  24.0 |   22.9 |    4.60% | "71" | 100.29M | 96.97M |     0.97 | 0:04'38'' |
| Q25L60.R |  23.0 |   22.1 |    3.64% | "71" | 100.29M |  96.8M |     0.97 | 0:04'31'' |
| Q0L0.S   |  12.9 |   12.2 |    5.46% | "71" | 100.29M |  89.9M |     0.90 | 0:02'35'' |
| Q25L60.S |  12.3 |   11.7 |    4.66% | "71" | 100.29M | 89.09M |     0.89 | 0:02'29'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0XallP000   |   35.1 |  89.91% |     11188 | 83.55M | 14794 |      1907 | 10.15M | 59917 |   28.0 | 3.0 |   6.3 |  55.5 | "31,41,51,61,71,81" | 0:20'13'' | 0:19'25'' |
| Q25L60XallP000 |   33.9 |  89.88% |     11019 | 83.83M | 14878 |      3481 |  9.15M | 59772 |   27.0 | 3.0 |   6.0 |  54.0 | "31,41,51,61,71,81" | 0:19'33'' | 0:18'43'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0XallP000   |   35.1 |  89.82% |     10106 | 82.11M | 15645 |      2750 | 9.35M | 64296 |   28.0 | 3.0 |   6.3 |  55.5 | "31,41,51,61,71,81" | 0:10'50'' | 0:18'56'' |
| Q25L60XallP000 |   33.9 |  89.61% |      9691 | 81.29M | 16085 |      1773 | 10.2M | 64728 |   27.0 | 2.0 |   7.0 |  49.5 | "31,41,51,61,71,81" | 0:10'45'' | 0:17'49'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  85.47% |      9632 | 80.47M | 15117 |      6986 | 8.01M | 40901 |   32.0 | 5.0 |   5.7 |  64.0 | "31,41,51,61,71,81" | 0:30'10'' | 0:13'01'' |
| MRXallP000 |   41.8 |  85.45% |      9643 | 79.94M | 15024 |      4330 | 8.71M | 40696 |   33.0 | 4.0 |   7.0 |  66.0 | "31,41,51,61,71,81" | 0:31'02'' | 0:13'12'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  86.63% |      9156 | 79.59M | 15490 |      5715 | 8.88M | 46555 |   32.0 | 4.0 |   6.7 |  64.0 | "31,41,51,61,71,81" | 0:16'22'' | 0:14'43'' |
| MRXallP000 |   41.8 |  86.58% |      9186 | 79.86M | 15480 |      7485 | 8.57M | 46160 |   33.0 | 4.0 |   7.0 |  66.0 | "31,41,51,61,71,81" | 0:16'32'' | 0:14'59'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |    # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|-------:|------:|----------:|-------:|-----:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |  72.99% |     13677 | 81.97M | 12602 |      1555 | 14.59M | 8071 |   28.0 | 2.0 |   7.3 |  51.0 | 0:13'20'' |
| 7_mergeKunitigsAnchors   |  68.41% |     11811 |  82.7M | 13951 |      3433 |   9.1M | 4233 |   28.0 | 3.0 |   6.3 |  55.5 | 0:10'16'' |
| 7_mergeMRKunitigsAnchors |  64.46% |      9864 | 78.89M | 14514 |      7290 |  7.94M | 3369 |   28.0 | 2.0 |   7.3 |  51.0 | 0:08'40'' |
| 7_mergeMRTadpoleAnchors  |  62.89% |      9382 | 78.26M | 14860 |      9953 |  7.94M | 3229 |   28.0 | 2.0 |   7.3 |  51.0 | 0:08'11'' |
| 7_mergeTadpoleAnchors    |  64.40% |     10421 | 80.99M | 14888 |      4509 |   8.9M | 4063 |   28.0 | 3.0 |   6.3 |  55.5 | 0:08'37'' |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |    Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|-------:|------:|----------:|------:|------:|-------:|----:|------:|------:|----------:|
| 8_spades     |  90.82% |     23247 | 86.93M |  9057 |     29419 |  8.1M | 18216 |   28.0 | 4.0 |   5.3 |  56.0 | 0:10'21'' |
| 8_spades_MR  |  88.31% |     14148 | 84.47M | 12498 |     37925 |  7.8M | 25358 |   33.0 | 5.0 |   6.0 |  66.0 | 0:09'18'' |
| 8_megahit    |  89.02% |     15946 | 84.47M | 11570 |     17480 | 8.26M | 23746 |   28.0 | 3.0 |   6.3 |  55.5 | 0:09'30'' |
| 8_megahit_MR |  89.56% |     14361 | 85.15M | 12324 |     30458 | 8.07M | 25266 |   33.0 | 5.0 |   6.0 |  66.0 | 0:09'29'' |
| 8_platanus   |  79.70% |     11255 | 74.73M | 13115 |      7646 | 6.72M | 27153 |   28.0 | 3.0 |   6.3 |  55.5 | 0:07'25'' |


Table: statFinal

| Name                     |      N50 |       Sum |      # |
|:-------------------------|---------:|----------:|-------:|
| Genome                   | 17493829 | 100286401 |      7 |
| Paralogs                 |     2013 |   5313653 |   2637 |
| 7_mergeAnchors.anchors   |    13677 |  81965941 |  12602 |
| 7_mergeAnchors.others    |     1555 |  14590973 |   8071 |
| spades.contig            |    21708 | 104281921 |  69139 |
| spades.scaffold          |    22758 | 104289060 |  68811 |
| spades.non-contained     |    25124 |  95049532 |   9208 |
| spades_MR.contig         |    13329 |  99112753 |  35898 |
| spades_MR.scaffold       |    13628 |  99124516 |  35706 |
| spades_MR.non-contained  |    14790 |  92269166 |  13042 |
| megahit.contig           |    14867 |  98517269 |  24724 |
| megahit.non-contained    |    16370 |  92730446 |  12212 |
| megahit_MR.contig        |    13539 |  99670329 |  25181 |
| megahit_MR.non-contained |    14965 |  93211437 |  13099 |
| platanus.contig          |     2958 | 104308540 | 313135 |
| platanus.scaffold        |     9054 |  93429435 |  62957 |
| platanus.non-contained   |    11337 |  81447985 |  14042 |

| Name                     |      N50 |       Sum |      # |
|:-------------------------|---------:|----------:|-------:|
| Genome                   | 17493829 | 100286401 |      7 |
| Paralogs                 |     2013 |   5313653 |   2637 |
| 7_mergeAnchors.anchors   |    14641 |  84491923 |  11924 |
| 7_mergeAnchors.others    |     1935 |  13064305 |   6542 |
| spades.contig            |    24298 | 104650509 |  67784 |
| spades.scaffold          |    25436 | 104658106 |  67460 |
| spades.non-contained     |    28016 |  95907515 |   8536 |
| spades_MR.contig         |    17344 | 100438752 |  30512 |
| spades_MR.scaffold       |    18151 | 100462682 |  30201 |
| spades_MR.non-contained  |    19018 |  94662166 |  11130 |
| megahit.contig           |    15847 |  99027810 |  23779 |
| megahit.non-contained    |    17148 |  93570798 |  11832 |
| megahit_MR.contig        |    17641 | 100742198 |  21202 |
| megahit_MR.non-contained |    19147 |  95497506 |  11334 |
| platanus.contig          |     3360 | 106005153 | 321046 |
| platanus.scaffold        |    10148 |  94618611 |  60185 |
| platanus.non-contained   |    12549 |  83371534 |  13508 |


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
