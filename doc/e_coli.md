# Tuning parameters for the dataset of *E. coli*

[TOC level=1-3]: # " "
- [Tuning parameters for the dataset of *E. coli*](#tuning-parameters-for-the-dataset-of-e-coli)
- [More tools on downloading and preprocessing data](#more-tools-on-downloading-and-preprocessing-data)
    - [Extra external executables](#extra-external-executables)
    - [PacBio specific tools](#pacbio-specific-tools)
- [*Escherichia coli* str. K-12 substr. MG1655](#escherichia-coli-str-k-12-substr-mg1655)
    - [Download](#download)
    - [Combinations of different quality values and read lengths](#combinations-of-different-quality-values-and-read-lengths)
    - [Quorum](#quorum)
    - [Down sampling](#down-sampling)
    - [Generate k-unitigs (sampled)](#generate-k-unitigs-sampled)
    - [Create anchors (sampled)](#create-anchors-sampled)
    - [Merge anchors with Qxx, Lxx and QxxLxx](#merge-anchors-with-qxx-lxx-and-qxxlxx)
    - [Merge anchors](#merge-anchors)
    - [With PE info](#with-pe-info)
    - [Different K values](#different-k-values)
    - [3GS](#3gs)
    - [Expand anchors](#expand-anchors)


# More tools on downloading and preprocessing data

## Extra external executables

```bash
brew install aria2 curl                     # downloading tools

brew install homebrew/science/sratoolkit    # NCBI SRAToolkit

brew reinstall --build-from-source --without-webp gd # broken, can't find libwebp.so.6
brew reinstall --build-from-source gnuplot@4
brew install homebrew/science/mummer        # mummer need gnuplot4

brew install python
pip install matplotlib
brew install homebrew/science/quast         # assembly quality assessment
quast --test                                # may recompile the bundled nucmer

# canu requires gnuplot 5 while mummer requires gnuplot 4
brew install canu

brew unlink gnuplot@4
brew install gnuplot
brew unlink gnuplot

brew link gnuplot@4 --force

brew install r --without-tcltk --without-x11
brew install kmergenie --with-maxkmer=200
```

## PacBio specific tools

PacBio is switching its data format from `hdf5` to `bam`, but at now
(early 2017) the majority of public available PacBio data are still in
formats of `.bax.h5` or `hdf5.tgz`. For dealing with these files, PacBio
releases some tools which can be installed by another specific tool,
named `pitchfork`.

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

* Compiled binary files are in `~/share/pitchfork/deployment`. Run
  `source ~/share/pitchfork/deployment/setup-env.sh` will bring this
  path to your `$PATH`. This action would also pollute your bash
  environment, if anything went wrong, restart your terminal.

```bash
source ~/share/pitchfork/deployment/setup-env.sh

bax2bam --help
```

* Data of P4C2 and older are not supported in the current version of
  PacBio softwares (SMRTAnalysis). So install SMRTAnalysis_2.3.0.

```bash
mkdir -p ~/share/SMRTAnalysis_2.3.0
cd ~/share/SMRTAnalysis_2.3.0

aria2c -x 9 -s 3 -c http://files.pacb.com/software/smrtanalysis/2.3.0/smrtanalysis_2.3.0.140936.run
aria2c -x 9 -s 3 -c http://files.pacb.com/software/smrtanalysis/2.3.0/smrtanalysis-patch_2.3.0.140936.p5.run

aria2c -x 9 -s 3 -c https://atlas.hashicorp.com/ubuntu/boxes/trusty64/versions/20170313.0.7/providers/virtualbox.box
vagrant box add ubuntu/trusty64 trusty-server-cloudimg-amd64-vagrant-disk1.box --force

curl -O https://raw.githubusercontent.com/mhsieh/SMRTAnalysis_2.3.0_install/master/vagrant-u1404/Vagrantfile

vagrant destroy -f
rm -fr .vagrant/
vagrant up --provider virtualbox

```

# *Escherichia coli* str. K-12 substr. MG1655

* Genome: INSDC
  [U00096.3](https://www.ncbi.nlm.nih.gov/nuccore/U00096.3)
* Taxonomy ID:
  [511145](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=511145)
* Proportion of paralogs (> 1000 bp): 0.0323

## Download

* Reference genome

```bash
mkdir -p ~/data/anchr/e_coli/1_genome
cd ~/data/anchr/e_coli/1_genome

curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=U00096.3&rettype=fasta&retmode=txt" \
    > U00096.fa
# simplify header, remove .3
cat U00096.fa \
    | perl -nl -e '
        /^>(\w+)/ and print qq{>$1} and next;
        print;
    ' \
    > genome.fa

cp ~/data/anchr/paralogs/model/Results/e_coli/e_coli.multi.fas paralogs.fas
```

* Illumina

```bash
mkdir -p ~/data/anchr/e_coli/2_illumina
cd ~/data/anchr/e_coli/2_illumina
aria2c -x 9 -s 3 -c ftp://webdata:webdata@ussd-ftp.illumina.com/Data/SequencingRuns/MG1655/MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz
aria2c -x 9 -s 3 -c ftp://webdata:webdata@ussd-ftp.illumina.com/Data/SequencingRuns/MG1655/MiSeq_Ecoli_MG1655_110721_PF_R2.fastq.gz

ln -s MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz R1.fq.gz
ln -s MiSeq_Ecoli_MG1655_110721_PF_R2.fastq.gz R2.fq.gz
```

* PacBio

    [Here](https://github.com/PacificBiosciences/DevNet/wiki/E.-coli-Bacterial-Assembly)
    PacBio provides a 7 GB file for *E. coli* (20 kb library), which is
    gathered with RS II and the P6C4 reagent.

```bash
mkdir -p ~/data/anchr/e_coli/3_pacbio
cd ~/data/anchr/e_coli/3_pacbio
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
ln -s fasta/m141013.fasta pacbio.fasta

head -n 46000 pacbio.fasta > pacbio.40x.fasta
faops n50 -S -C pacbio.40x.fasta

head -n 92000 pacbio.fasta > pacbio.80x.fasta
faops n50 -S -C pacbio.80x.fasta

```

* FastQC

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

## Combinations of different quality values and read lengths

* qual: 1, 20, 25, 30, and 35
* len: 1, 60, 90, and 120

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

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

# get the default adapter file
# anchr trim --help
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

if [ ! -e 2_illumina/R1.shuffle.fq.gz ]; then
    shuffle.sh \
        in=2_illumina/R1.scythe.fq.gz \
        in2=2_illumina/R2.scythe.fq.gz \
        out=2_illumina/R1.shuffle.fq \
        out2=2_illumina/R2.shuffle.fq
    
    parallel --no-run-if-empty -j 2 "
            pigz -p 8 2_illumina/{}.shuffle.fq
        " ::: R1 R2
fi

parallel --no-run-if-empty -j 3 "
    mkdir -p 2_illumina/Q{1}L{2}
    cd 2_illumina/Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        --noscythe \
        -q {1} -l {2} \
        ../R1.shuffle.fq.gz ../R2.shuffle.fq.gz \
        -o stdout \
        | bash
    " ::: 1 20 25 30 35 ::: 1 60 90 120

```

* Stats

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Paralogs"; faops n50 -H -S -C 1_genome/paralogs.fas;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "PacBio";   faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "shuffle";  faops n50 -H -S -C 2_illumina/R1.shuffle.fq.gz 2_illumina/R2.shuffle.fq.gz;) >> stat.md

parallel -k --no-run-if-empty -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo Q{1}L{2};
            if [[ {1} -ge '30' ]]; then
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz \
                    2_illumina/Q{1}L{2}/Rs.fq.gz;
            else
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz;
            fi
        )
    " ::: 1 20 25 30 35 ::: 1 60 90 120 \
    >> stat.md

cat stat.md
```

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 4641652 |    4641652 |        1 |
| Paralogs |    1934 |     195673 |      106 |
| PacBio   |   13982 |  748508361 |    87225 |
| Illumina |     151 | 1730299940 | 11458940 |
| uniq     |     151 | 1727289000 | 11439000 |
| scythe   |     151 | 1722450607 | 11439000 |
| shuffle  |     151 | 1722450607 | 11439000 |
| Q1L1     |     151 | 1722395665 | 11438116 |
| Q1L60    |     151 | 1722133185 | 11434888 |
| Q1L90    |     151 | 1721242394 | 11425956 |
| Q1L120   |     151 | 1718953984 | 11407264 |
| Q20L1    |     151 | 1532644712 | 11409534 |
| Q20L60   |     151 | 1468709458 | 10572422 |
| Q20L90   |     151 | 1370119196 |  9617554 |
| Q20L120  |     151 | 1135307713 |  7723784 |
| Q25L1    |     151 | 1410647449 | 11371376 |
| Q25L60   |     151 | 1317617346 |  9994728 |
| Q25L90   |     151 | 1177142378 |  8586574 |
| Q25L120  |     151 |  837111446 |  5805874 |
| Q30L1    |     125 | 1202244744 | 11323819 |
| Q30L60   |     127 | 1149107745 |  9783292 |
| Q30L90   |     130 | 1021609911 |  8105773 |
| Q30L120  |     139 |  693661043 |  5002158 |
| Q35L1    |      63 |  607071735 | 10829952 |
| Q35L60   |      72 |  366922898 |  5062192 |
| Q35L90   |      95 |   35259773 |   364046 |
| Q35L120  |     124 |     647353 |     5169 |

## Quorum

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 1 "
    cd 2_illumina/Q{1}L{2}
    echo >&2 '==> Group Q{1}L{2} <=='

    if [ ! -e R1.fq.gz ]; then
        echo >&2 '    R1.fq.gz not exists'
        exit;
    fi

    if [ -e pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa exists'
        exit;
    fi

    if [[ {1} -ge '30' ]]; then
        anchr quorum \
            R1.fq.gz R2.fq.gz Rs.fq.gz \
            -p 16 \
            -o quorum.sh
    else
        anchr quorum \
            R1.fq.gz R2.fq.gz \
            -p 16 \
            -o quorum.sh
    fi

    bash quorum.sh
    
    echo >&2
    " ::: 1 20 25 30 35 ::: 1 60 90 120

```

Clear intermediate files.

```bash
BASE_NAME=e_coli
cd $HOME/data/anchr/${BASE_NAME}

find 2_illumina -type f -name "quorum_mer_db.jf" | xargs rm
find 2_illumina -type f -name "k_u_hash_0"       | xargs rm
find 2_illumina -type f -name "*.tmp"            | xargs rm
find 2_illumina -type f -name "pe.renamed.fastq" | xargs rm
find 2_illumina -type f -name "se.renamed.fastq" | xargs rm
find 2_illumina -type f -name "pe.cor.sub.fa"    | xargs rm
```

* Stats of processed reads

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=4641652

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > stat1.md

parallel -k --no-run-if-empty -j 3 "
    if [ ! -d 2_illumina/Q{1}L{2} ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 2_illumina/Q{1}L{2} ${REAL_G}
    " ::: 1 20 25 30 35 ::: 1 60 90 120 \
     >> stat1.md

cat stat1.md
```

| Name    |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG |   EstG | Est/Real |   RunTime |
|:--------|--------:|------:|--------:|-------:|---------:|--------:|------:|------:|-------:|---------:|----------:|
| Q1L1    |   1.72G | 371.1 |   1.16G |  249.0 |  32.894% |     150 |  "75" | 4.64M |  6.65M |     1.43 | 0:05'22'' |
| Q1L60   |   1.72G | 371.0 |   1.16G |  249.0 |  32.891% |     150 |  "75" | 4.64M |  6.65M |     1.43 | 0:05'42'' |
| Q1L90   |   1.72G | 370.8 |   1.16G |  248.9 |  32.886% |     150 |  "75" | 4.64M |  6.64M |     1.43 | 0:05'48'' |
| Q1L120  |   1.72G | 370.3 |   1.15G |  248.6 |  32.873% |     150 |  "75" | 4.64M |  6.64M |     1.43 | 0:05'22'' |
| Q20L1   |   1.53G | 330.2 |   1.33G |  286.9 |  13.102% |     136 |  "63" | 4.64M |  4.85M |     1.05 | 0:04'15'' |
| Q20L60  |   1.47G | 316.4 |   1.28G |  275.6 |  12.888% |     139 |  "67" | 4.64M |  4.82M |     1.04 | 0:04'11'' |
| Q20L90  |   1.37G | 295.2 |   1.19G |  256.8 |  13.001% |     143 |  "95" | 4.64M |  4.69M |     1.01 | 0:03'47'' |
| Q20L120 |   1.14G | 244.6 | 988.43M |  212.9 |  12.937% |     147 | "105" | 4.64M |  4.63M |     1.00 | 0:03'12'' |
| Q25L1   |   1.41G | 303.9 |   1.32G |  285.3 |   6.119% |     128 |  "77" | 4.64M |  4.59M |     0.99 | 0:03'58'' |
| Q25L60  |   1.32G | 283.9 |   1.24G |  267.4 |   5.801% |     133 |  "83" | 4.64M |  4.58M |     0.99 | 0:03'46'' |
| Q25L90  |   1.18G | 253.6 |   1.11G |  238.8 |   5.832% |     138 |  "87" | 4.64M |  4.57M |     0.99 | 0:03'18'' |
| Q25L120 | 837.11M | 180.3 | 786.11M |  169.4 |   6.093% |     144 |  "95" | 4.64M |  4.56M |     0.98 | 0:02'24'' |
| Q30L1   |    1.2G | 259.0 |   1.17G |  251.0 |   3.091% |     114 |  "59" | 4.64M |  4.56M |     0.98 | 0:03'29'' |
| Q30L60  |   1.15G | 247.7 |   1.12G |  241.6 |   2.484% |     120 |  "71" | 4.64M |  4.56M |     0.98 | 0:03'17'' |
| Q30L90  |   1.02G | 220.4 | 996.45M |  214.7 |   2.605% |     128 |  "79" | 4.64M |  4.56M |     0.98 | 0:02'55'' |
| Q30L120 | 695.91M | 149.9 | 674.79M |  145.4 |   3.035% |     139 |  "91" | 4.64M |  4.56M |     0.98 | 0:02'15'' |
| Q35L1   | 607.39M | 130.9 | 584.79M |  126.0 |   3.721% |      61 |  "33" | 4.64M |  4.56M |     0.98 | 0:01'56'' |
| Q35L60  | 369.07M |  79.5 | 362.78M |   78.2 |   1.705% |      73 |  "45" | 4.64M |  4.51M |     0.97 | 0:01'15'' |
| Q35L90  |  35.58M |   7.7 |  32.82M |    7.1 |   7.770% |      98 |  "65" | 4.64M |  2.03M |     0.44 | 0:00'23'' |
| Q35L120 | 652.49K |   0.1 | 293.98K |    0.1 |  54.945% |     126 |  "85" | 4.64M | 47.62K |     0.01 | 0:00'15'' |

* kmergenie

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

kmergenie -l 21 -k 151 -s 10 -t 8 ../R1.fq.gz -o oriR1
kmergenie -l 21 -k 151 -s 10 -t 8 ../R2.fq.gz -o oriR2
kmergenie -l 21 -k 151 -s 10 -t 8 ../Q30L60/pe.cor.fa -o Q30L60

```

## Down sampling

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=4641652

for QxxLxx in $( parallel "echo 'Q{1}L{2}'" ::: 1 20 25 30 35 ::: 1 60 90 120 ); do
    echo "==> ${QxxLxx}"

    if [ ! -e 2_illumina/${QxxLxx}/pe.cor.fa ]; then
        echo "2_illumina/${QxxLxx}/pe.cor.fa not exists"
        continue;
    fi

    for X in 40 80 120 160 200; do
        printf "==> Coverage: %s\n" ${X}
        
        rm -fr 2_illumina/${QxxLxx}X${X}*
    
        faops split-about -l 0 \
            2_illumina/${QxxLxx}/pe.cor.fa \
            $(( ${REAL_G} * ${X} )) \
            "2_illumina/${QxxLxx}X${X}"
        
        MAX_SERIAL=$(
            cat 2_illumina/${QxxLxx}/environment.json \
                | jq ".SUM_OUT | tonumber | . / ${REAL_G} / ${X} | floor | . - 1"
        )
        
        for i in $( seq 0 1 ${MAX_SERIAL} ); do
            P=$( printf "%03d" ${i})
            printf "  * Part: %s\n" ${P}
            
            mkdir -p "2_illumina/${QxxLxx}X${X}P${P}"
            
            mv  "2_illumina/${QxxLxx}X${X}/${P}.fa" \
                "2_illumina/${QxxLxx}X${X}P${P}/pe.cor.fa"
            cp 2_illumina/${QxxLxx}/environment.json "2_illumina/${QxxLxx}X${X}P${P}"
    
        done
    done
done

```

## Generate k-unitigs (sampled)

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 3 "
    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'

    if [ ! -e 2_illumina/Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        echo >&2 '    2_illumina/Q{1}L{2}X{3}P{4}/pe.cor.fa not exists'
        exit;
    fi

    if [ -e Q{1}L{2}X{3}P{4}/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi

    mkdir -p Q{1}L{2}X{3}P{4}
    cd Q{1}L{2}X{3}P{4}

    anchr kunitigs \
        ../2_illumina/Q{1}L{2}X{3}P{4}/pe.cor.fa \
        ../2_illumina/Q{1}L{2}X{3}P{4}/environment.json \
        -p 8 \
        --kmer 31,41,51,61,71,81 \
        -o kunitigs.sh
    bash kunitigs.sh

    echo >&2
    " ::: 1 20 25 30 35 ::: 1 60 90 120 ::: 40 80 120 160 200 ::: 000 001 002 003 004 005

```

## Create anchors (sampled)

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 3 "
    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'

    if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    rm -fr Q{1}L{2}X{3}P{4}/anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh Q{1}L{2}X{3}P{4} 8 false
    
    echo >&2
    " ::: 1 20 25 30 35 ::: 1 60 90 120 ::: 40 80 120 160 200 ::: 000 001 002 003 004 005

```

* Stats of anchors

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=4641652

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > stat2.md

parallel -k --no-run-if-empty -j 6 "
    if [ ! -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 Q{1}L{2}X{3}P{4} ${REAL_G}
    " ::: 1 20 25 30 35 ::: 1 60 90 120 ::: 40 80 120 160 200 ::: 000 001 002 003 004 005 \
     >> stat2.md

cat stat2.md
```

| Name            |  SumCor | CovCor | N50SR |     Sum |    # | N50Anchor |     Sum |    # | N50Others |     Sum |    # |                Kmer | RunTimeKU | RunTimeAN |
|:----------------|--------:|-------:|------:|--------:|-----:|----------:|--------:|-----:|----------:|--------:|-----:|--------------------:|----------:|:----------|
| Q1L1X40P000     | 185.67M |   40.0 |  1061 |    3.7M | 3715 |      1547 |   1.95M | 1241 |       725 |   1.75M | 2474 | "31,41,51,61,71,81" | 0:03'28'' | 0:01'11'' |
| Q1L1X40P001     | 185.67M |   40.0 |  1072 |   3.69M | 3685 |      1533 |   1.97M | 1255 |       728 |   1.72M | 2430 | "31,41,51,61,71,81" | 0:03'28'' | 0:01'14'' |
| Q1L1X40P002     | 185.67M |   40.0 |  1024 |   3.67M | 3751 |      1529 |   1.84M | 1188 |       731 |   1.83M | 2563 | "31,41,51,61,71,81" | 0:03'29'' | 0:01'15'' |
| Q1L1X40P003     | 185.67M |   40.0 |  1054 |   3.69M | 3727 |      1559 |   1.92M | 1221 |       730 |   1.77M | 2506 | "31,41,51,61,71,81" | 0:03'25'' | 0:01'05'' |
| Q1L1X40P004     | 185.67M |   40.0 |  1044 |   3.66M | 3704 |      1542 |   1.89M | 1204 |       725 |   1.77M | 2500 | "31,41,51,61,71,81" | 0:03'34'' | 0:01'14'' |
| Q1L1X40P005     | 185.67M |   40.0 |  1052 |   3.73M | 3749 |      1566 |   1.94M | 1226 |       729 |   1.79M | 2523 | "31,41,51,61,71,81" | 0:03'36'' | 0:01'12'' |
| Q1L1X80P000     | 371.33M |   80.0 |   759 |   2.12M | 2722 |      1335 | 605.08K |  437 |       658 |   1.51M | 2285 | "31,41,51,61,71,81" | 0:05'17'' | 0:01'23'' |
| Q1L1X80P001     | 371.33M |   80.0 |   755 |    2.1M | 2704 |      1378 | 560.66K |  398 |       672 |   1.54M | 2306 | "31,41,51,61,71,81" | 0:05'15'' | 0:01'24'' |
| Q1L1X80P002     | 371.33M |   80.0 |   755 |   2.12M | 2763 |      1294 |  554.3K |  406 |       668 |   1.57M | 2357 | "31,41,51,61,71,81" | 0:05'18'' | 0:01'23'' |
| Q1L1X120P000    |    557M |  120.0 |   701 |   1.35M | 1851 |      1331 | 285.94K |  203 |       638 |   1.06M | 1648 | "31,41,51,61,71,81" | 0:07'14'' | 0:01'19'' |
| Q1L1X120P001    |    557M |  120.0 |   710 |   1.36M | 1874 |      1276 | 274.08K |  205 |       647 |   1.09M | 1669 | "31,41,51,61,71,81" | 0:07'18'' | 0:01'50'' |
| Q1L1X160P000    | 742.66M |  160.0 |   689 | 983.98K | 1372 |      1333 | 184.09K |  129 |       631 | 799.89K | 1243 | "31,41,51,61,71,81" | 0:09'15'' | 0:01'34'' |
| Q1L1X200P000    | 928.33M |  200.0 |   668 | 796.31K | 1138 |      1317 | 129.31K |   96 |       624 |    667K | 1042 | "31,41,51,61,71,81" | 0:11'19'' | 0:01'08'' |
| Q1L60X40P000    | 185.67M |   40.0 |  1061 |    3.7M | 3715 |      1547 |   1.95M | 1241 |       724 |   1.74M | 2474 | "31,41,51,61,71,81" | 0:03'22'' | 0:01'16'' |
| Q1L60X40P001    | 185.67M |   40.0 |  1071 |   3.69M | 3686 |      1533 |   1.97M | 1257 |       727 |   1.72M | 2429 | "31,41,51,61,71,81" | 0:03'21'' | 0:01'00'' |
| Q1L60X40P002    | 185.67M |   40.0 |  1024 |   3.67M | 3749 |      1529 |   1.84M | 1189 |       731 |   1.82M | 2560 | "31,41,51,61,71,81" | 0:03'20'' | 0:01'11'' |
| Q1L60X40P003    | 185.67M |   40.0 |  1055 |   3.69M | 3724 |      1559 |   1.92M | 1221 |       730 |   1.77M | 2503 | "31,41,51,61,71,81" | 0:03'25'' | 0:01'07'' |
| Q1L60X40P004    | 185.67M |   40.0 |  1045 |   3.66M | 3702 |      1542 |    1.9M | 1205 |       725 |   1.76M | 2497 | "31,41,51,61,71,81" | 0:03'22'' | 0:01'11'' |
| Q1L60X40P005    | 185.67M |   40.0 |  1052 |   3.73M | 3749 |      1567 |   1.94M | 1225 |       729 |   1.79M | 2524 | "31,41,51,61,71,81" | 0:03'23'' | 0:01'05'' |
| Q1L60X80P000    | 371.33M |   80.0 |   759 |   2.12M | 2721 |      1335 | 605.07K |  437 |       658 |   1.51M | 2284 | "31,41,51,61,71,81" | 0:05'22'' | 0:01'15'' |
| Q1L60X80P001    | 371.33M |   80.0 |   755 |    2.1M | 2704 |      1378 | 560.66K |  398 |       672 |   1.54M | 2306 | "31,41,51,61,71,81" | 0:05'23'' | 0:01'13'' |
| Q1L60X80P002    | 371.33M |   80.0 |   755 |   2.12M | 2763 |      1294 |  553.4K |  406 |       669 |   1.57M | 2357 | "31,41,51,61,71,81" | 0:05'21'' | 0:01'15'' |
| Q1L60X120P000   |    557M |  120.0 |   701 |   1.35M | 1850 |      1331 | 285.94K |  203 |       638 |   1.06M | 1647 | "31,41,51,61,71,81" | 0:07'25'' | 0:01'07'' |
| Q1L60X120P001   |    557M |  120.0 |   709 |   1.36M | 1872 |      1276 | 274.86K |  205 |       646 |   1.09M | 1667 | "31,41,51,61,71,81" | 0:07'29'' | 0:01'10'' |
| Q1L60X160P000   | 742.66M |  160.0 |   690 | 983.87K | 1372 |      1333 | 182.97K |  128 |       631 | 800.89K | 1244 | "31,41,51,61,71,81" | 0:09'36'' | 0:01'11'' |
| Q1L60X200P000   | 928.33M |  200.0 |   668 | 795.58K | 1135 |      1285 | 132.61K |   98 |       622 | 662.97K | 1037 | "31,41,51,61,71,81" | 0:11'51'' | 0:01'32'' |
| Q1L90X40P000    | 185.67M |   40.0 |  1061 |    3.7M | 3718 |      1547 |   1.95M | 1241 |       724 |   1.75M | 2477 | "31,41,51,61,71,81" | 0:03'23'' | 0:01'14'' |
| Q1L90X40P001    | 185.67M |   40.0 |  1074 |   3.69M | 3685 |      1533 |   1.97M | 1258 |       727 |   1.72M | 2427 | "31,41,51,61,71,81" | 0:03'22'' | 0:01'10'' |
| Q1L90X40P002    | 185.67M |   40.0 |  1025 |   3.66M | 3743 |      1532 |   1.84M | 1190 |       731 |   1.82M | 2553 | "31,41,51,61,71,81" | 0:03'27'' | 0:01'10'' |
| Q1L90X40P003    | 185.67M |   40.0 |  1057 |   3.69M | 3724 |      1560 |   1.92M | 1223 |       728 |   1.77M | 2501 | "31,41,51,61,71,81" | 0:03'24'' | 0:01'12'' |
| Q1L90X40P004    | 185.67M |   40.0 |  1045 |   3.66M | 3700 |      1542 |    1.9M | 1205 |       726 |   1.76M | 2495 | "31,41,51,61,71,81" | 0:03'24'' | 0:01'06'' |
| Q1L90X40P005    | 185.67M |   40.0 |  1051 |   3.73M | 3758 |      1566 |   1.94M | 1225 |       728 |   1.79M | 2533 | "31,41,51,61,71,81" | 0:03'23'' | 0:01'12'' |
| Q1L90X80P000    | 371.33M |   80.0 |   759 |   2.12M | 2722 |      1335 | 605.07K |  437 |       657 |   1.51M | 2285 | "31,41,51,61,71,81" | 0:05'27'' | 0:01'08'' |
| Q1L90X80P001    | 371.33M |   80.0 |   754 |    2.1M | 2704 |      1375 | 560.16K |  398 |       672 |   1.54M | 2306 | "31,41,51,61,71,81" | 0:05'28'' | 0:01'16'' |
| Q1L90X80P002    | 371.33M |   80.0 |   755 |   2.12M | 2764 |      1295 | 553.09K |  405 |       669 |   1.57M | 2359 | "31,41,51,61,71,81" | 0:05'25'' | 0:01'11'' |
| Q1L90X120P000   |    557M |  120.0 |   701 |   1.35M | 1848 |      1332 | 286.06K |  203 |       638 |   1.06M | 1645 | "31,41,51,61,71,81" | 0:07'30'' | 0:01'03'' |
| Q1L90X120P001   |    557M |  120.0 |   709 |   1.36M | 1874 |      1276 | 273.96K |  205 |       647 |   1.09M | 1669 | "31,41,51,61,71,81" | 0:07'34'' | 0:01'18'' |
| Q1L90X160P000   | 742.66M |  160.0 |   688 | 983.83K | 1372 |      1331 | 182.87K |  128 |       631 | 800.96K | 1244 | "31,41,51,61,71,81" | 0:09'40'' | 0:01'14'' |
| Q1L90X200P000   | 928.33M |  200.0 |   667 | 797.21K | 1140 |      1317 | 130.54K |   97 |       624 | 666.67K | 1043 | "31,41,51,61,71,81" | 0:11'51'' | 0:01'16'' |
| Q1L120X40P000   | 185.67M |   40.0 |  1061 |    3.7M | 3718 |      1547 |   1.95M | 1241 |       724 |   1.75M | 2477 | "31,41,51,61,71,81" | 0:03'24'' | 0:01'12'' |
| Q1L120X40P001   | 185.67M |   40.0 |  1075 |   3.69M | 3682 |      1533 |   1.97M | 1260 |       728 |   1.71M | 2422 | "31,41,51,61,71,81" | 0:03'20'' | 0:01'05'' |
| Q1L120X40P002   | 185.67M |   40.0 |  1026 |   3.66M | 3746 |      1527 |   1.85M | 1194 |       733 |   1.82M | 2552 | "31,41,51,61,71,81" | 0:03'24'' | 0:01'05'' |
| Q1L120X40P003   | 185.67M |   40.0 |  1054 |   3.69M | 3720 |      1561 |   1.92M | 1217 |       729 |   1.77M | 2503 | "31,41,51,61,71,81" | 0:03'22'' | 0:01'09'' |
| Q1L120X40P004   | 185.67M |   40.0 |  1043 |   3.66M | 3697 |      1549 |   1.89M | 1197 |       726 |   1.77M | 2500 | "31,41,51,61,71,81" | 0:03'21'' | 0:01'13'' |
| Q1L120X40P005   | 185.67M |   40.0 |  1053 |   3.74M | 3766 |      1556 |   1.95M | 1230 |       726 |   1.79M | 2536 | "31,41,51,61,71,81" | 0:03'24'' | 0:01'10'' |
| Q1L120X80P000   | 371.33M |   80.0 |   760 |   2.12M | 2722 |      1332 | 606.87K |  439 |       657 |   1.51M | 2283 | "31,41,51,61,71,81" | 0:05'23'' | 0:01'16'' |
| Q1L120X80P001   | 371.33M |   80.0 |   754 |    2.1M | 2705 |      1375 | 560.09K |  398 |       672 |   1.54M | 2307 | "31,41,51,61,71,81" | 0:05'26'' | 0:01'11'' |
| Q1L120X80P002   | 371.33M |   80.0 |   755 |   2.12M | 2762 |      1302 | 552.27K |  403 |       669 |   1.57M | 2359 | "31,41,51,61,71,81" | 0:05'22'' | 0:01'13'' |
| Q1L120X120P000  |    557M |  120.0 |   701 |   1.35M | 1853 |      1332 | 288.23K |  205 |       638 |   1.06M | 1648 | "31,41,51,61,71,81" | 0:07'34'' | 0:01'01'' |
| Q1L120X120P001  |    557M |  120.0 |   710 |   1.36M | 1877 |      1274 |  274.2K |  205 |       647 |   1.09M | 1672 | "31,41,51,61,71,81" | 0:07'30'' | 0:01'20'' |
| Q1L120X160P000  | 742.66M |  160.0 |   689 | 983.36K | 1370 |      1332 | 186.45K |  131 |       631 | 796.92K | 1239 | "31,41,51,61,71,81" | 0:09'39'' | 0:01'29'' |
| Q1L120X200P000  | 928.33M |  200.0 |   667 | 798.44K | 1140 |      1285 | 132.46K |   98 |       622 | 665.98K | 1042 | "31,41,51,61,71,81" | 0:11'54'' | 0:01'16'' |
| Q20L1X40P000    | 185.67M |   40.0 |  5183 |   4.62M | 1286 |      5332 |   4.43M | 1082 |       861 | 186.37K |  204 | "31,41,51,61,71,81" | 0:03'17'' | 0:01'19'' |
| Q20L1X40P001    | 185.67M |   40.0 |  5278 |    4.6M | 1293 |      5494 |   4.44M | 1089 |       788 | 153.38K |  204 | "31,41,51,61,71,81" | 0:03'16'' | 0:01'13'' |
| Q20L1X40P002    | 185.67M |   40.0 |  5421 |   4.59M | 1272 |      5626 |   4.44M | 1072 |       778 | 148.49K |  200 | "31,41,51,61,71,81" | 0:03'18'' | 0:01'25'' |
| Q20L1X40P003    | 185.67M |   40.0 |  5206 |    4.6M | 1293 |      5448 |   4.43M | 1075 |       776 | 162.93K |  218 | "31,41,51,61,71,81" | 0:03'18'' | 0:01'12'' |
| Q20L1X40P004    | 185.67M |   40.0 |  5391 |    4.6M | 1279 |      5586 |   4.45M | 1083 |       805 |    150K |  196 | "31,41,51,61,71,81" | 0:03'16'' | 0:01'20'' |
| Q20L1X40P005    | 185.67M |   40.0 |  5242 |   4.59M | 1281 |      5471 |   4.42M | 1041 |       795 | 178.46K |  240 | "31,41,51,61,71,81" | 0:03'20'' | 0:01'26'' |
| Q20L1X80P000    | 371.33M |   80.0 |  2134 |   4.51M | 2687 |      2419 |   3.81M | 1738 |       775 | 699.21K |  949 | "31,41,51,61,71,81" | 0:05'16'' | 0:02'28'' |
| Q20L1X80P001    | 371.33M |   80.0 |  2122 |   4.51M | 2645 |      2468 |   3.83M | 1725 |       780 | 681.18K |  920 | "31,41,51,61,71,81" | 0:05'15'' | 0:02'10'' |
| Q20L1X80P002    | 371.33M |   80.0 |  2155 |    4.5M | 2660 |      2497 |   3.81M | 1724 |       777 | 689.31K |  936 | "31,41,51,61,71,81" | 0:05'16'' | 0:02'07'' |
| Q20L1X120P000   |    557M |  120.0 |  1444 |   4.26M | 3402 |      1809 |   3.03M | 1702 |       761 |   1.23M | 1700 | "31,41,51,61,71,81" | 0:07'17'' | 0:03'01'' |
| Q20L1X120P001   |    557M |  120.0 |  1446 |   4.26M | 3386 |      1857 |   3.04M | 1704 |       752 |   1.21M | 1682 | "31,41,51,61,71,81" | 0:07'13'' | 0:02'55'' |
| Q20L1X160P000   | 742.66M |  160.0 |  1193 |   3.99M | 3682 |      1607 |   2.42M | 1497 |       750 |   1.57M | 2185 | "31,41,51,61,71,81" | 0:09'10'' | 0:03'30'' |
| Q20L1X200P000   | 928.33M |  200.0 |  1055 |   3.78M | 3784 |      1522 |   2.04M | 1322 |       732 |   1.75M | 2462 | "31,41,51,61,71,81" | 0:11'07'' | 0:03'13'' |
| Q20L60X40P000   | 185.67M |   40.0 |  5098 |   4.62M | 1304 |      5210 |   4.43M | 1097 |       844 | 186.79K |  207 | "31,41,51,61,71,81" | 0:03'13'' | 0:01'18'' |
| Q20L60X40P001   | 185.67M |   40.0 |  5119 |    4.6M | 1307 |      5407 |   4.43M | 1094 |       790 | 160.35K |  213 | "31,41,51,61,71,81" | 0:03'14'' | 0:01'22'' |
| Q20L60X40P002   | 185.67M |   40.0 |  5249 |   4.59M | 1293 |      5377 |   4.45M | 1097 |       778 | 144.28K |  196 | "31,41,51,61,71,81" | 0:03'14'' | 0:01'20'' |
| Q20L60X40P003   | 185.67M |   40.0 |  5133 |    4.6M | 1302 |      5464 |   4.43M | 1084 |       790 | 166.66K |  218 | "31,41,51,61,71,81" | 0:03'14'' | 0:01'25'' |
| Q20L60X40P004   | 185.67M |   40.0 |  5130 |    4.6M | 1313 |      5292 |   4.44M | 1106 |       793 | 155.28K |  207 | "31,41,51,61,71,81" | 0:03'14'' | 0:01'21'' |
| Q20L60X40P005   | 185.67M |   40.0 |  5322 |   4.59M | 1293 |      5531 |   4.41M | 1051 |       805 | 183.23K |  242 | "31,41,51,61,71,81" | 0:03'16'' | 0:01'22'' |
| Q20L60X80P000   | 371.33M |   80.0 |  2129 |   4.51M | 2684 |      2448 |    3.8M | 1738 |       783 | 701.56K |  946 | "31,41,51,61,71,81" | 0:05'08'' | 0:02'06'' |
| Q20L60X80P001   | 371.33M |   80.0 |  2153 |   4.51M | 2634 |      2476 |   3.84M | 1721 |       780 | 676.29K |  913 | "31,41,51,61,71,81" | 0:05'10'' | 0:02'16'' |
| Q20L60X80P002   | 371.33M |   80.0 |  2186 |    4.5M | 2654 |      2525 |    3.8M | 1702 |       773 | 698.94K |  952 | "31,41,51,61,71,81" | 0:05'11'' | 0:02'14'' |
| Q20L60X120P000  |    557M |  120.0 |  1468 |   4.28M | 3375 |      1822 |   3.05M | 1701 |       770 |   1.22M | 1674 | "31,41,51,61,71,81" | 0:07'03'' | 0:02'52'' |
| Q20L60X120P001  |    557M |  120.0 |  1461 |   4.28M | 3374 |      1845 |   3.09M | 1729 |       750 |   1.19M | 1645 | "31,41,51,61,71,81" | 0:06'57'' | 0:02'53'' |
| Q20L60X160P000  | 742.66M |  160.0 |  1207 |   4.05M | 3683 |      1646 |    2.5M | 1529 |       754 |   1.55M | 2154 | "31,41,51,61,71,81" | 0:08'57'' | 0:03'23'' |
| Q20L60X200P000  | 928.33M |  200.0 |  1089 |   3.87M | 3791 |      1561 |   2.13M | 1363 |       740 |   1.73M | 2428 | "31,41,51,61,71,81" | 0:10'51'' | 0:03'06'' |
| Q20L90X40P000   | 185.67M |   40.0 |  6570 |   4.61M | 1008 |      6725 |   4.49M |  879 |       856 | 117.92K |  129 | "31,41,51,61,71,81" | 0:03'28'' | 0:01'50'' |
| Q20L90X40P001   | 185.67M |   40.0 |  7208 |   4.59M | 1010 |      7356 |    4.5M |  890 |       790 |  90.64K |  120 | "31,41,51,61,71,81" | 0:03'27'' | 0:01'28'' |
| Q20L90X40P002   | 185.67M |   40.0 |  6970 |   4.59M | 1005 |      7253 |    4.5M |  890 |       769 |  84.54K |  115 | "31,41,51,61,71,81" | 0:03'30'' | 0:01'20'' |
| Q20L90X40P003   | 185.67M |   40.0 |  7017 |   4.59M | 1014 |      7125 |   4.49M |  886 |       832 |  97.74K |  128 | "31,41,51,61,71,81" | 0:03'26'' | 0:01'18'' |
| Q20L90X40P004   | 185.67M |   40.0 |  6995 |   4.59M | 1005 |      7184 |    4.5M |  889 |       800 |  91.38K |  116 | "31,41,51,61,71,81" | 0:03'28'' | 0:01'14'' |
| Q20L90X40P005   | 185.67M |   40.0 |  6768 |   4.59M | 1009 |      6980 |   4.49M |  876 |       811 |  99.81K |  133 | "31,41,51,61,71,81" | 0:03'27'' | 0:01'23'' |
| Q20L90X80P000   | 371.33M |   80.0 |  3098 |   4.59M | 2005 |      3287 |   4.24M | 1527 |       776 | 355.93K |  478 | "31,41,51,61,71,81" | 0:05'30'' | 0:02'26'' |
| Q20L90X80P001   | 371.33M |   80.0 |  3045 |   4.59M | 2019 |      3280 |   4.24M | 1540 |       783 | 355.31K |  479 | "31,41,51,61,71,81" | 0:05'27'' | 0:02'16'' |
| Q20L90X80P002   | 371.33M |   80.0 |  3172 |   4.58M | 1968 |      3342 |   4.23M | 1492 |       767 |  349.2K |  476 | "31,41,51,61,71,81" | 0:05'24'' | 0:02'00'' |
| Q20L90X120P000  |    557M |  120.0 |  2165 |   4.55M | 2630 |      2469 |   3.91M | 1771 |       769 | 634.41K |  859 | "31,41,51,61,71,81" | 0:07'32'' | 0:03'28'' |
| Q20L90X120P001  |    557M |  120.0 |  2232 |   4.53M | 2567 |      2518 |    3.9M | 1718 |       774 | 626.43K |  849 | "31,41,51,61,71,81" | 0:07'29'' | 0:03'25'' |
| Q20L90X160P000  | 742.66M |  160.0 |  1852 |   4.48M | 2899 |      2189 |   3.68M | 1813 |       770 | 798.81K | 1086 | "31,41,51,61,71,81" | 0:09'23'' | 0:03'40'' |
| Q20L90X200P000  | 928.33M |  200.0 |  1732 |   4.45M | 3034 |      2074 |   3.57M | 1828 |       761 | 880.06K | 1206 | "31,41,51,61,71,81" | 0:11'34'' | 0:03'48'' |
| Q20L120X40P000  | 185.67M |   40.0 |  8832 |    4.6M |  838 |      8954 |   4.49M |  740 |       891 | 101.73K |   98 | "31,41,51,61,71,81" | 0:03'32'' | 0:01'43'' |
| Q20L120X40P001  | 185.67M |   40.0 |  8577 |   4.58M |  836 |      8892 |   4.51M |  742 |       788 |  69.07K |   94 | "31,41,51,61,71,81" | 0:03'33'' | 0:01'28'' |
| Q20L120X40P002  | 185.67M |   40.0 |  8147 |   4.58M |  859 |      8263 |    4.5M |  756 |       795 |  75.92K |  103 | "31,41,51,61,71,81" | 0:03'33'' | 0:01'23'' |
| Q20L120X40P003  | 185.67M |   40.0 |  8864 |   4.57M |  819 |      8970 |    4.5M |  727 |       860 |  75.55K |   92 | "31,41,51,61,71,81" | 0:03'32'' | 0:01'17'' |
| Q20L120X40P004  | 185.67M |   40.0 |  8495 |   4.57M |  855 |      8659 |    4.5M |  755 |       796 |  74.63K |  100 | "31,41,51,61,71,81" | 0:03'33'' | 0:01'27'' |
| Q20L120X80P000  | 371.33M |   80.0 |  4501 |   4.59M | 1519 |      4648 |   4.38M | 1234 |       795 | 213.29K |  285 | "31,41,51,61,71,81" | 0:05'35'' | 0:02'12'' |
| Q20L120X80P001  | 371.33M |   80.0 |  4373 |    4.6M | 1530 |      4668 |   4.38M | 1241 |       800 | 217.37K |  289 | "31,41,51,61,71,81" | 0:05'35'' | 0:02'17'' |
| Q20L120X120P000 |    557M |  120.0 |  3256 |   4.58M | 1931 |      3496 |   4.24M | 1476 |       793 | 339.34K |  455 | "31,41,51,61,71,81" | 0:07'33'' | 0:03'01'' |
| Q20L120X160P000 | 742.66M |  160.0 |  2868 |   4.57M | 2130 |      3135 |   4.16M | 1578 |       793 | 411.32K |  552 | "31,41,51,61,71,81" | 0:09'41'' | 0:03'34'' |
| Q20L120X200P000 | 928.33M |  200.0 |  2727 |   4.57M | 2204 |      2999 |   4.13M | 1605 |       798 | 447.03K |  599 | "31,41,51,61,71,81" | 0:11'50'' | 0:03'31'' |
| Q25L1X40P000    | 185.67M |   40.0 | 50567 |   4.55M |  193 |     50567 |   4.54M |  178 |       728 |  10.68K |   15 | "31,41,51,61,71,81" | 0:03'31'' | 0:01'37'' |
| Q25L1X40P001    | 185.67M |   40.0 | 38549 |   4.55M |  218 |     38549 |   4.54M |  200 |       728 |  12.78K |   18 | "31,41,51,61,71,81" | 0:03'29'' | 0:01'30'' |
| Q25L1X40P002    | 185.67M |   40.0 | 41181 |   4.55M |  202 |     41181 |   4.54M |  186 |       706 |  10.99K |   16 | "31,41,51,61,71,81" | 0:03'28'' | 0:01'41'' |
| Q25L1X40P003    | 185.67M |   40.0 | 39149 |   4.55M |  215 |     39149 |   4.53M |  197 |       812 |  13.66K |   18 | "31,41,51,61,71,81" | 0:03'29'' | 0:01'20'' |
| Q25L1X40P004    | 185.67M |   40.0 | 43332 |   4.55M |  197 |     43332 |   4.54M |  184 |       637 |    8.7K |   13 | "31,41,51,61,71,81" | 0:03'33'' | 0:01'28'' |
| Q25L1X40P005    | 185.67M |   40.0 | 42904 |   4.55M |  197 |     42904 |   4.53M |  179 |       754 |  12.94K |   18 | "31,41,51,61,71,81" | 0:03'32'' | 0:01'28'' |
| Q25L1X80P000    | 371.33M |   80.0 | 26345 |   4.56M |  304 |     26345 |   4.54M |  284 |       767 |  14.26K |   20 | "31,41,51,61,71,81" | 0:05'22'' | 0:02'38'' |
| Q25L1X80P001    | 371.33M |   80.0 | 26134 |   4.56M |  304 |     26255 |   4.54M |  276 |       812 |  20.63K |   28 | "31,41,51,61,71,81" | 0:05'17'' | 0:02'17'' |
| Q25L1X80P002    | 371.33M |   80.0 | 27724 |   4.55M |  284 |     27724 |   4.54M |  263 |       647 |  14.17K |   21 | "31,41,51,61,71,81" | 0:05'14'' | 0:02'37'' |
| Q25L1X120P000   |    557M |  120.0 | 18832 |   4.57M |  413 |     18917 |   4.55M |  383 |       681 |  20.33K |   30 | "31,41,51,61,71,81" | 0:07'11'' | 0:03'21'' |
| Q25L1X120P001   |    557M |  120.0 | 20913 |   4.56M |  393 |     20913 |   4.54M |  364 |       808 |     21K |   29 | "31,41,51,61,71,81" | 0:07'10'' | 0:03'19'' |
| Q25L1X160P000   | 742.66M |  160.0 | 14976 |   4.57M |  495 |     15057 |   4.54M |  452 |       836 |  31.71K |   43 | "31,41,51,61,71,81" | 0:09'07'' | 0:03'51'' |
| Q25L1X200P000   | 928.33M |  200.0 | 13666 |   4.57M |  548 |     13796 |   4.54M |  500 |       812 |  34.74K |   48 | "31,41,51,61,71,81" | 0:10'54'' | 0:04'26'' |
| Q25L60X40P000   | 185.67M |   40.0 | 46002 |   4.55M |  202 |     46002 |   4.54M |  186 |       706 |     11K |   16 | "31,41,51,61,71,81" | 0:03'21'' | 0:01'48'' |
| Q25L60X40P001   | 185.67M |   40.0 | 35665 |   4.55M |  224 |     35665 |   4.54M |  205 |       705 |  13.21K |   19 | "31,41,51,61,71,81" | 0:03'22'' | 0:01'38'' |
| Q25L60X40P002   | 185.67M |   40.0 | 39149 |   4.55M |  207 |     40910 |   4.53M |  189 |       754 |  12.77K |   18 | "31,41,51,61,71,81" | 0:03'24'' | 0:01'14'' |
| Q25L60X40P003   | 185.67M |   40.0 | 39218 |   4.55M |  217 |     39218 |   4.53M |  198 |       812 |     14K |   19 | "31,41,51,61,71,81" | 0:03'25'' | 0:01'31'' |
| Q25L60X40P004   | 185.67M |   40.0 | 41181 |   4.55M |  200 |     41181 |   4.54M |  186 |       672 |   9.74K |   14 | "31,41,51,61,71,81" | 0:03'20'' | 0:01'29'' |
| Q25L60X40P005   | 185.67M |   40.0 | 37874 |   4.55M |  221 |     37874 |   4.53M |  201 |       754 |  15.98K |   20 | "31,41,51,61,71,81" | 0:03'15'' | 0:01'33'' |
| Q25L60X80P000   | 371.33M |   80.0 | 27749 |   4.56M |  296 |     27749 |   4.54M |  273 |       767 |  16.37K |   23 | "31,41,51,61,71,81" | 0:05'12'' | 0:02'21'' |
| Q25L60X80P001   | 371.33M |   80.0 | 28431 |   4.55M |  297 |     28831 |   4.54M |  272 |       812 |  18.57K |   25 | "31,41,51,61,71,81" | 0:05'09'' | 0:02'36'' |
| Q25L60X80P002   | 371.33M |   80.0 | 26221 |   4.55M |  296 |     26255 |   4.54M |  270 |       718 |  18.46K |   26 | "31,41,51,61,71,81" | 0:05'10'' | 0:02'15'' |
| Q25L60X120P000  |    557M |  120.0 | 19611 |   4.56M |  391 |     19828 |   4.55M |  364 |       812 |  19.05K |   27 | "31,41,51,61,71,81" | 0:07'02'' | 0:03'14'' |
| Q25L60X120P001  |    557M |  120.0 | 21668 |   4.56M |  377 |     21668 |   4.54M |  346 |       799 |  22.56K |   31 | "31,41,51,61,71,81" | 0:07'02'' | 0:03'04'' |
| Q25L60X160P000  | 742.66M |  160.0 | 16181 |   4.57M |  453 |     16181 |   4.54M |  420 |       830 |   24.2K |   33 | "31,41,51,61,71,81" | 0:08'51'' | 0:03'44'' |
| Q25L60X200P000  | 928.33M |  200.0 | 14758 |   4.57M |  491 |     14815 |   4.54M |  452 |       812 |  28.22K |   39 | "31,41,51,61,71,81" | 0:10'39'' | 0:04'17'' |
| Q25L90X40P000   | 185.67M |   40.0 | 38635 |   4.55M |  231 |     38635 |   4.53M |  209 |       637 |  14.66K |   22 | "31,41,51,61,71,81" | 0:03'34'' | 0:01'42'' |
| Q25L90X40P001   | 185.67M |   40.0 | 31837 |   4.56M |  251 |     31837 |   4.54M |  231 |       863 |  20.49K |   20 | "31,41,51,61,71,81" | 0:03'37'' | 0:01'32'' |
| Q25L90X40P002   | 185.67M |   40.0 | 36675 |   4.55M |  232 |     36675 |   4.53M |  211 |       705 |  13.94K |   21 | "31,41,51,61,71,81" | 0:03'37'' | 0:01'30'' |
| Q25L90X40P003   | 185.67M |   40.0 | 33644 |   4.55M |  255 |     33644 |   4.53M |  238 |       812 |  11.85K |   17 | "31,41,51,61,71,81" | 0:03'27'' | 0:01'20'' |
| Q25L90X40P004   | 185.67M |   40.0 | 35814 |   4.55M |  231 |     35879 |   4.54M |  212 |       718 |  13.34K |   19 | "31,41,51,61,71,81" | 0:03'26'' | 0:01'23'' |
| Q25L90X80P000   | 371.33M |   80.0 | 27311 |   4.55M |  291 |     27550 |   4.54M |  268 |       640 |  15.66K |   23 | "31,41,51,61,71,81" | 0:05'15'' | 0:02'35'' |
| Q25L90X80P001   | 371.33M |   80.0 | 26937 |   4.55M |  304 |     26937 |   4.53M |  277 |       812 |  19.36K |   27 | "31,41,51,61,71,81" | 0:05'16'' | 0:02'30'' |
| Q25L90X120P000  |    557M |  120.0 | 23577 |   4.56M |  345 |     23577 |   4.54M |  324 |       640 |  13.96K |   21 | "31,41,51,61,71,81" | 0:07'18'' | 0:03'09'' |
| Q25L90X160P000  | 742.66M |  160.0 | 18805 |   4.56M |  390 |     18838 |   4.55M |  366 |       682 |  16.09K |   24 | "31,41,51,61,71,81" | 0:09'17'' | 0:03'41'' |
| Q25L90X200P000  | 928.33M |  200.0 | 18443 |   4.56M |  405 |     18443 |   4.54M |  377 |       682 |  18.76K |   28 | "31,41,51,61,71,81" | 0:11'16'' | 0:04'16'' |
| Q25L120X40P000  | 185.67M |   40.0 | 26255 |   4.54M |  350 |     26479 |   4.52M |  319 |       636 |  21.08K |   31 | "31,41,51,61,71,81" | 0:03'38'' | 0:01'36'' |
| Q25L120X40P001  | 185.67M |   40.0 | 23275 |   4.54M |  361 |     24178 |   4.52M |  326 |       812 |  25.28K |   35 | "31,41,51,61,71,81" | 0:03'35'' | 0:01'21'' |
| Q25L120X40P002  | 185.67M |   40.0 | 23960 |   4.54M |  350 |     24496 |   4.52M |  319 |       812 |  22.76K |   31 | "31,41,51,61,71,81" | 0:03'35'' | 0:01'34'' |
| Q25L120X40P003  | 185.67M |   40.0 | 23425 |   4.54M |  354 |     23605 |   4.51M |  324 |       740 |  21.41K |   30 | "31,41,51,61,71,81" | 0:03'37'' | 0:01'24'' |
| Q25L120X80P000  | 371.33M |   80.0 | 33725 |   4.55M |  280 |     33756 |   4.53M |  256 |       812 |  16.92K |   24 | "31,41,51,61,71,81" | 0:05'40'' | 0:02'12'' |
| Q25L120X80P001  | 371.33M |   80.0 | 30995 |   4.55M |  287 |     30995 |   4.54M |  265 |       673 |  15.12K |   22 | "31,41,51,61,71,81" | 0:05'41'' | 0:02'15'' |
| Q25L120X120P000 |    557M |  120.0 | 31632 |   4.56M |  275 |     31632 |   4.54M |  255 |       812 |  13.89K |   20 | "31,41,51,61,71,81" | 0:07'34'' | 0:03'07'' |
| Q25L120X160P000 | 742.66M |  160.0 | 32084 |   4.56M |  265 |     32084 |   4.54M |  245 |       831 |  14.21K |   20 | "31,41,51,61,71,81" | 0:09'43'' | 0:03'20'' |
| Q30L1X40P000    | 185.67M |   40.0 | 47271 |   4.55M |  193 |     47271 |   4.54M |  176 |       754 |  12.24K |   17 | "31,41,51,61,71,81" | 0:03'25'' | 0:01'44'' |
| Q30L1X40P001    | 185.67M |   40.0 | 44647 |   4.55M |  188 |     44647 |   4.53M |  171 |       728 |  12.17K |   17 | "31,41,51,61,71,81" | 0:03'23'' | 0:01'44'' |
| Q30L1X40P002    | 185.67M |   40.0 | 49170 |   4.54M |  187 |     49170 |   4.53M |  171 |       728 |   11.4K |   16 | "31,41,51,61,71,81" | 0:03'24'' | 0:01'44'' |
| Q30L1X40P003    | 185.67M |   40.0 | 44479 |   4.55M |  196 |     44479 |   4.54M |  179 |       706 |  11.62K |   17 | "31,41,51,61,71,81" | 0:03'22'' | 0:01'47'' |
| Q30L1X40P004    | 185.67M |   40.0 | 43294 |   4.55M |  194 |     43294 |   4.53M |  177 |       754 |  12.49K |   17 | "31,41,51,61,71,81" | 0:03'24'' | 0:01'43'' |
| Q30L1X40P005    | 185.67M |   40.0 | 43854 |   4.54M |  187 |     43854 |   4.53M |  173 |       754 |  10.21K |   14 | "31,41,51,61,71,81" | 0:03'25'' | 0:01'49'' |
| Q30L1X80P000    | 371.33M |   80.0 | 57888 |   4.55M |  170 |     57888 |   4.54M |  153 |       728 |  12.39K |   17 | "31,41,51,61,71,81" | 0:05'06'' | 0:02'34'' |
| Q30L1X80P001    | 371.33M |   80.0 | 57848 |   4.55M |  171 |     57848 |   4.53M |  155 |       728 |  11.62K |   16 | "31,41,51,61,71,81" | 0:05'09'' | 0:02'27'' |
| Q30L1X80P002    | 371.33M |   80.0 | 53723 |   4.55M |  170 |     53723 |   4.53M |  154 |       754 |   11.6K |   16 | "31,41,51,61,71,81" | 0:05'06'' | 0:02'37'' |
| Q30L1X120P000   |    557M |  120.0 | 57888 |   4.55M |  168 |     59716 |   4.54M |  153 |       728 |  10.75K |   15 | "31,41,51,61,71,81" | 0:06'54'' | 0:03'42'' |
| Q30L1X120P001   |    557M |  120.0 | 54868 |   4.55M |  166 |     54868 |   4.54M |  150 |       728 |  11.31K |   16 | "31,41,51,61,71,81" | 0:06'52'' | 0:03'16'' |
| Q30L1X160P000   | 742.66M |  160.0 | 57888 |   4.55M |  165 |     57888 |   4.54M |  151 |       728 |   9.91K |   14 | "31,41,51,61,71,81" | 0:08'29'' | 0:03'54'' |
| Q30L1X200P000   | 928.33M |  200.0 | 57888 |   4.55M |  161 |     57888 |   4.54M |  147 |       728 |   9.91K |   14 | "31,41,51,61,71,81" | 0:10'19'' | 0:04'52'' |
| Q30L60X40P000   | 185.67M |   40.0 | 41916 |   4.55M |  208 |     41916 |   4.54M |  189 |       754 |  15.03K |   19 | "31,41,51,61,71,81" | 0:03'26'' | 0:01'40'' |
| Q30L60X40P001   | 185.67M |   40.0 | 40063 |   4.55M |  215 |     40063 |   4.53M |  197 |       728 |  12.88K |   18 | "31,41,51,61,71,81" | 0:03'24'' | 0:01'51'' |
| Q30L60X40P002   | 185.67M |   40.0 | 44646 |   4.54M |  208 |     44646 |   4.53M |  189 |       728 |  13.39K |   19 | "31,41,51,61,71,81" | 0:03'27'' | 0:01'46'' |
| Q30L60X40P003   | 185.67M |   40.0 | 41181 |   4.54M |  211 |     41181 |   4.53M |  193 |       728 |  12.92K |   18 | "31,41,51,61,71,81" | 0:03'27'' | 0:01'27'' |
| Q30L60X40P004   | 185.67M |   40.0 | 40123 |   4.54M |  203 |     40123 |   4.53M |  187 |       728 |  11.35K |   16 | "31,41,51,61,71,81" | 0:03'27'' | 0:01'26'' |
| Q30L60X40P005   | 185.67M |   40.0 | 36221 |   4.55M |  241 |     36221 |   4.53M |  215 |       706 |  17.85K |   26 | "31,41,51,61,71,81" | 0:03'19'' | 0:01'42'' |
| Q30L60X80P000   | 371.33M |   80.0 | 53721 |   4.55M |  182 |     53721 |   4.53M |  165 |       728 |  12.34K |   17 | "31,41,51,61,71,81" | 0:05'12'' | 0:02'32'' |
| Q30L60X80P001   | 371.33M |   80.0 | 48437 |   4.55M |  183 |     48437 |   4.53M |  164 |       754 |  13.78K |   19 | "31,41,51,61,71,81" | 0:05'11'' | 0:02'32'' |
| Q30L60X80P002   | 371.33M |   80.0 | 49167 |   4.55M |  187 |     49167 |   4.53M |  166 |       706 |  14.59K |   21 | "31,41,51,61,71,81" | 0:05'06'' | 0:02'48'' |
| Q30L60X120P000  |    557M |  120.0 | 53723 |   4.55M |  174 |     53723 |   4.54M |  157 |       754 |  12.25K |   17 | "31,41,51,61,71,81" | 0:07'01'' | 0:03'39'' |
| Q30L60X120P001  |    557M |  120.0 | 50795 |   4.55M |  185 |     50795 |   4.54M |  166 |       728 |  13.38K |   19 | "31,41,51,61,71,81" | 0:06'51'' | 0:03'43'' |
| Q30L60X160P000  | 742.66M |  160.0 | 53735 |   4.55M |  170 |     53735 |   4.54M |  155 |       728 |  10.75K |   15 | "31,41,51,61,71,81" | 0:08'44'' | 0:03'41'' |
| Q30L60X200P000  | 928.33M |  200.0 | 54908 |   4.55M |  167 |     54908 |   4.54M |  152 |       728 |  10.75K |   15 | "31,41,51,61,71,81" | 0:10'31'' | 0:04'42'' |
| Q30L90X40P000   | 185.67M |   40.0 | 26791 |   4.54M |  293 |     26791 |   4.53M |  269 |       706 |  16.62K |   24 | "31,41,51,61,71,81" | 0:03'31'' | 0:01'40'' |
| Q30L90X40P001   | 185.67M |   40.0 | 27265 |   4.55M |  312 |     27265 |   4.53M |  287 |       754 |  18.34K |   25 | "31,41,51,61,71,81" | 0:03'31'' | 0:01'39'' |
| Q30L90X40P002   | 185.67M |   40.0 | 25788 |   4.54M |  303 |     25788 |   4.52M |  279 |       754 |  18.13K |   24 | "31,41,51,61,71,81" | 0:03'33'' | 0:01'39'' |
| Q30L90X40P003   | 185.67M |   40.0 | 26255 |   4.54M |  322 |     26530 |   4.52M |  294 |       728 |  19.54K |   28 | "31,41,51,61,71,81" | 0:03'32'' | 0:01'27'' |
| Q30L90X40P004   | 185.67M |   40.0 | 34061 |   4.56M |  260 |     34194 |   4.54M |  239 |       754 |  15.28K |   21 | "31,41,51,61,71,81" | 0:03'29'' | 0:01'25'' |
| Q30L90X80P000   | 371.33M |   80.0 | 37367 |   4.55M |  224 |     37367 |   4.53M |  203 |       754 |  15.34K |   21 | "31,41,51,61,71,81" | 0:05'24'' | 0:02'40'' |
| Q30L90X80P001   | 371.33M |   80.0 | 37357 |   4.54M |  231 |     38964 |   4.53M |  212 |       734 |  13.54K |   19 | "31,41,51,61,71,81" | 0:05'25'' | 0:02'26'' |
| Q30L90X120P000  |    557M |  120.0 | 42691 |   4.55M |  203 |     42691 |   4.53M |  185 |       728 |  12.96K |   18 | "31,41,51,61,71,81" | 0:07'12'' | 0:03'15'' |
| Q30L90X160P000  | 742.66M |  160.0 | 44646 |   4.55M |  198 |     44646 |   4.54M |  181 |       754 |   12.4K |   17 | "31,41,51,61,71,81" | 0:09'10'' | 0:03'37'' |
| Q30L90X200P000  | 928.33M |  200.0 | 46294 |   4.55M |  190 |     46294 |   4.54M |  172 |       754 |  13.28K |   18 | "31,41,51,61,71,81" | 0:10'56'' | 0:04'27'' |
| Q30L120X40P000  | 185.67M |   40.0 | 10194 |   4.48M |  771 |     10456 |   4.39M |  656 |       796 |  93.36K |  115 | "31,41,51,61,71,81" | 0:03'35'' | 0:01'37'' |
| Q30L120X40P001  | 185.67M |   40.0 |  9937 |   4.48M |  764 |     10058 |    4.4M |  655 |       768 |  80.23K |  109 | "31,41,51,61,71,81" | 0:03'33'' | 0:01'24'' |
| Q30L120X40P002  | 185.67M |   40.0 | 21129 |   4.54M |  390 |     21129 |   4.52M |  359 |       799 |  23.03K |   31 | "31,41,51,61,71,81" | 0:03'38'' | 0:01'32'' |
| Q30L120X80P000  | 371.33M |   80.0 | 16302 |   4.53M |  498 |     16519 |   4.48M |  439 |       797 |  46.37K |   59 | "31,41,51,61,71,81" | 0:05'38'' | 0:02'26'' |
| Q30L120X120P000 |    557M |  120.0 | 35814 |   4.55M |  240 |     35814 |   4.53M |  222 |       728 |  12.78K |   18 | "31,41,51,61,71,81" | 0:07'33'' | 0:03'10'' |
| Q35L1X40P000    | 185.67M |   40.0 |  6672 |   4.52M | 1082 |      6810 |   4.37M |  877 |       773 | 151.92K |  205 | "31,41,51,61,71,81" | 0:01'57'' | 0:02'31'' |
| Q35L1X40P001    | 185.67M |   40.0 |  6567 |   4.52M | 1114 |      6757 |   4.36M |  901 |       778 | 162.97K |  213 | "31,41,51,61,71,81" | 0:01'55'' | 0:01'51'' |
| Q35L1X40P002    | 185.67M |   40.0 |  6351 |   4.52M | 1111 |      6616 |   4.34M |  879 |       784 | 184.81K |  232 | "31,41,51,61,71,81" | 0:01'56'' | 0:02'23'' |
| Q35L1X80P000    | 371.33M |   80.0 | 11654 |   4.56M |  657 |     11921 |   4.47M |  558 |       781 |  83.27K |   99 | "31,41,51,61,71,81" | 0:02'55'' | 0:03'29'' |
| Q35L1X120P000   |    557M |  120.0 | 14842 |   4.57M |  540 |     14990 |   4.49M |  459 |       841 |  73.64K |   81 | "31,41,51,61,71,81" | 0:03'47'' | 0:04'41'' |
| Q35L60X40P000   | 185.67M |   40.0 |  2130 |   3.76M | 2304 |      2669 |   3.03M | 1278 |       738 | 732.54K | 1026 | "31,41,51,61,71,81" | 0:02'10'' | 0:01'53'' |

## Merge anchors with Qxx, Lxx and QxxLxx

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

# merge anchors with Qxx
for Q in 1 20 25 30 35; do
    mkdir -p mergeQ${Q}
    anchr contained \
        $(
            parallel -k --no-run-if-empty -j 6 '
                if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                    echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
                fi
                ' ::: ${Q} ::: 1 60 90 120 ::: 40 80 120 160 200 ::: 000 001 002 003 004 005
        ) \
        --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
        -o stdout \
        | faops filter -a 1000 -l 0 stdin mergeQ${Q}/anchor.contained.fasta
    anchr orient mergeQ${Q}/anchor.contained.fasta --len 1000 --idt 0.98 -o mergeQ${Q}/anchor.orient.fasta
    anchr merge mergeQ${Q}/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
        | faops filter -a 1000 -l 0 stdin mergeQ${Q}/anchor.merge.fasta
done

# merge anchors with Lxx
for L in 1 60 90 120; do
    mkdir -p mergeL${L}
    anchr contained \
        $(
            parallel -k --no-run-if-empty -j 6 '
                if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                    echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
                fi
                ' ::: 1 20 25 30 35 ::: ${L} ::: 40 80 120 160 200 ::: 000 001 002 003 004 005
        ) \
        --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
        -o stdout \
        | faops filter -a 1000 -l 0 stdin mergeL${L}/anchor.contained.fasta
    anchr orient mergeL${L}/anchor.contained.fasta --len 1000 --idt 0.98 -o mergeL${L}/anchor.orient.fasta
    anchr merge mergeL${L}/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
        | faops filter -a 1000 -l 0 stdin mergeL${L}/anchor.merge.fasta
done

# quast
rm -fr 9_qa_mergeQL
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    mergeQ1/anchor.merge.fasta \
    mergeQ20/anchor.merge.fasta \
    mergeQ25/anchor.merge.fasta \
    mergeQ30/anchor.merge.fasta \
    mergeQ35/anchor.merge.fasta \
    mergeL1/anchor.merge.fasta \
    mergeL60/anchor.merge.fasta \
    mergeL90/anchor.merge.fasta \
    mergeL120/anchor.merge.fasta \
    1_genome/paralogs.fas \
    --label "mergeQ1,mergeQ20,mergeQ25,mergeQ30,mergeQ35,mergeL1,mergeL60,mergeL90,mergeL120,paralogs" \
    -o 9_qa_mergeQL

# merge anchors with QxxLxx
for Q in 20 25 30; do
    for L in 1 60 90; do
        mkdir -p mergeQ${Q}L${L}
        anchr contained \
            $(
                parallel -k --no-run-if-empty -j 6 '
                    if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                        echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
                    fi
                    ' ::: ${Q} ::: ${L} ::: 40 80 120 160 200 ::: 000 001 002 003 004 005
            ) \
            --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
            -o stdout \
            | faops filter -a 1000 -l 0 stdin mergeQ${Q}L${L}/anchor.contained.fasta
        anchr orient mergeQ${Q}L${L}/anchor.contained.fasta --len 1000 --idt 0.98 -o mergeQ${Q}L${L}/anchor.orient.fasta
        anchr merge mergeQ${Q}L${L}/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
            | faops filter -a 1000 -l 0 stdin mergeQ${Q}L${L}/anchor.merge.fasta
    done
done

# quast
rm -fr 9_qa_mergeQxxLxx
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    mergeQ20L1/anchor.merge.fasta \
    mergeQ20L60/anchor.merge.fasta \
    mergeQ20L90/anchor.merge.fasta \
    mergeQ25L1/anchor.merge.fasta \
    mergeQ25L60/anchor.merge.fasta \
    mergeQ25L90/anchor.merge.fasta \
    mergeQ30L1/anchor.merge.fasta \
    mergeQ30L60/anchor.merge.fasta \
    mergeQ30L90/anchor.merge.fasta \
    1_genome/paralogs.fas \
    --label "mergeQ20L1,mergeQ20L60,mergeQ20L90,mergeQ25L1,mergeQ25L60,mergeQ25L90,mergeQ30L1,mergeQ30L60,mergeQ30L90,paralogs" \
    -o 9_qa_mergeQxxLxx

```

## Merge anchors

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

# merge anchors
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
            fi
            " ::: 25 30 ::: 60 ::: 40 80 120 160 200 ::: 000 001 002 003 004 005
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.others.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.others.fa
            fi
            " ::: 25 30 ::: 60 ::: 40 80 120 160 200 ::: 000 001 002 003 004 005
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.merge.fasta

# anchor sort on ref
bash ~/Scripts/cpan/App-Anchr/share/sort_on_ref.sh merge/anchor.merge.fasta 1_genome/genome.fa merge/anchor.sort
nucmer -l 200 1_genome/genome.fa merge/anchor.sort.fa
mummerplot -png out.delta -p anchor.sort --large

# mummerplot files
rm *.[fr]plot
rm out.delta
rm *.gp
mv anchor.sort.png merge/

# quast
rm -fr 9_qa_merge
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "merge,others,paralogs" \
    -o 9_qa_merge

```

## With PE info

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

mkdir -p Q25L100_2500000_SR
cd ${BASE_DIR}/Q25L100_2500000_SR
ln -s ../Q25L100_2500000/R1.fq.gz R1.fq.gz
ln -s ../Q25L100_2500000/R2.fq.gz R2.fq.gz

anchr superreads \
    R1.fq.gz R2.fq.gz \
    -s 300 -d 30 -p 8 \
    -o superreads.sh
bash superreads.sh

rm -fr anchor
bash ~/Scripts/cpan/App-Anchr/share/anchor.sh . 8 true

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 .

```

## Different K values

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

# oriR1: 67; oriR2: 43; Q30L60: 71

parallel -j 3 "
    mkdir -p Q20L60K{}
    cd Q20L60K{}

    anchr kunitigs \
        ../2_illumina/Q20L60X40P000/pe.cor.fa \
        ../2_illumina/Q20L60X40P000/environment.json \
        -p 8 \
        --kmer {} \
        -o kunitigs.sh
    bash kunitigs.sh

    rm -fr anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh . 8 false
    " ::: 21 31 41 51 61 71 81 91 101 111 121 67 43 

mkdir -p Q20L60Kmerge
anchr contained \
    Q20L60K21/anchor/pe.anchor.fa \
    Q20L60K31/anchor/pe.anchor.fa \
    Q20L60K41/anchor/pe.anchor.fa \
    Q20L60K51/anchor/pe.anchor.fa \
    Q20L60K61/anchor/pe.anchor.fa \
    Q20L60K71/anchor/pe.anchor.fa \
    Q20L60K81/anchor/pe.anchor.fa \
    Q20L60K91/anchor/pe.anchor.fa \
    Q20L60K101/anchor/pe.anchor.fa \
    Q20L60K111/anchor/pe.anchor.fa \
    Q20L60K121/anchor/pe.anchor.fa \
    Q20L60K67/anchor/pe.anchor.fa \
    Q20L60K43/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin Q20L60Kmerge/anchor.contained.fasta
anchr orient Q20L60Kmerge/anchor.contained.fasta --len 1000 --idt 0.98 -o Q20L60Kmerge/anchor.orient.fasta
anchr merge Q20L60Kmerge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin Q20L60Kmerge/anchor.merge.fasta

rm -fr 9_qa_kmer_Q20
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    Q20L60K21/anchor/pe.anchor.fa \
    Q20L60K31/anchor/pe.anchor.fa \
    Q20L60K41/anchor/pe.anchor.fa \
    Q20L60K51/anchor/pe.anchor.fa \
    Q20L60K61/anchor/pe.anchor.fa \
    Q20L60K71/anchor/pe.anchor.fa \
    Q20L60K81/anchor/pe.anchor.fa \
    Q20L60K91/anchor/pe.anchor.fa \
    Q20L60K101/anchor/pe.anchor.fa \
    Q20L60K111/anchor/pe.anchor.fa \
    Q20L60K121/anchor/pe.anchor.fa \
    Q20L60K67/anchor/pe.anchor.fa \
    Q20L60K43/anchor/pe.anchor.fa \
    Q20L60X40P000/anchor/pe.anchor.fa \
    Q20L60Kmerge/anchor.merge.fasta \
    1_genome/paralogs.fas \
    --label "Q20L60K21,Q20L60K31,Q20L60K41,Q20L60K51,Q20L60K61,Q20L60K71,Q20L60K81,Q20L60K91,Q20L60K101,Q20L60K111,Q20L60K121,Q20L60K67,Q20L60K43,Q20L60X40P000,Q20L60Kmerge,paralogs" \
    -o 9_qa_kmer_Q20

parallel -j 3 "
    mkdir -p Q25L60K{}
    cd Q25L60K{}

    anchr kunitigs \
        ../2_illumina/Q25L60X40P000/pe.cor.fa \
        ../2_illumina/Q25L60X40P000/environment.json \
        -p 8 \
        --kmer {} \
        -o kunitigs.sh
    bash kunitigs.sh

    rm -fr anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh . 8 false
    " ::: 21 31 41 51 61 71 81 91 101 111 121 67 43 

mkdir -p Q25L60Kmerge
anchr contained \
    Q25L60K21/anchor/pe.anchor.fa \
    Q25L60K31/anchor/pe.anchor.fa \
    Q25L60K41/anchor/pe.anchor.fa \
    Q25L60K51/anchor/pe.anchor.fa \
    Q25L60K61/anchor/pe.anchor.fa \
    Q25L60K71/anchor/pe.anchor.fa \
    Q25L60K81/anchor/pe.anchor.fa \
    Q25L60K91/anchor/pe.anchor.fa \
    Q25L60K101/anchor/pe.anchor.fa \
    Q25L60K111/anchor/pe.anchor.fa \
    Q25L60K121/anchor/pe.anchor.fa \
    Q25L60K67/anchor/pe.anchor.fa \
    Q25L60K43/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin Q25L60Kmerge/anchor.contained.fasta
anchr orient Q25L60Kmerge/anchor.contained.fasta --len 1000 --idt 0.98 -o Q25L60Kmerge/anchor.orient.fasta
anchr merge Q25L60Kmerge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin Q25L60Kmerge/anchor.merge.fasta

rm -fr 9_qa_kmer_Q25
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    Q25L60K21/anchor/pe.anchor.fa \
    Q25L60K31/anchor/pe.anchor.fa \
    Q25L60K41/anchor/pe.anchor.fa \
    Q25L60K51/anchor/pe.anchor.fa \
    Q25L60K61/anchor/pe.anchor.fa \
    Q25L60K71/anchor/pe.anchor.fa \
    Q25L60K81/anchor/pe.anchor.fa \
    Q25L60K91/anchor/pe.anchor.fa \
    Q25L60K101/anchor/pe.anchor.fa \
    Q25L60K111/anchor/pe.anchor.fa \
    Q25L60K121/anchor/pe.anchor.fa \
    Q25L60K67/anchor/pe.anchor.fa \
    Q25L60K43/anchor/pe.anchor.fa \
    Q25L60X40P000/anchor/pe.anchor.fa \
    Q25L60Kmerge/anchor.merge.fasta \
    1_genome/paralogs.fas \
    --label "Q25L60K21,Q25L60K31,Q25L60K41,Q25L60K51,Q25L60K61,Q25L60K71,Q25L60K81,Q25L60K91,Q25L60K101,Q25L60K111,Q25L60K121,Q25L60K67,Q25L60K43,Q25L60X40P000,Q25L60Kmerge,paralogs" \
    -o 9_qa_kmer_Q25

parallel -j 3 "
    mkdir -p Q30L60K{}
    cd Q30L60K{}

    anchr kunitigs \
        ../2_illumina/Q30L60X40P000/pe.cor.fa \
        ../2_illumina/Q30L60X40P000/environment.json \
        -p 8 \
        --kmer {} \
        -o kunitigs.sh
    bash kunitigs.sh

    rm -fr anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh . 8 false
    " ::: 21 31 41 51 61 71 81 91 101 111 121 67 43 

mkdir -p Q30L60Kmerge
anchr contained \
    Q30L60K21/anchor/pe.anchor.fa \
    Q30L60K31/anchor/pe.anchor.fa \
    Q30L60K41/anchor/pe.anchor.fa \
    Q30L60K51/anchor/pe.anchor.fa \
    Q30L60K61/anchor/pe.anchor.fa \
    Q30L60K71/anchor/pe.anchor.fa \
    Q30L60K81/anchor/pe.anchor.fa \
    Q30L60K91/anchor/pe.anchor.fa \
    Q30L60K101/anchor/pe.anchor.fa \
    Q30L60K111/anchor/pe.anchor.fa \
    Q30L60K121/anchor/pe.anchor.fa \
    Q30L60K67/anchor/pe.anchor.fa \
    Q30L60K43/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin Q30L60Kmerge/anchor.contained.fasta
anchr orient Q30L60Kmerge/anchor.contained.fasta --len 1000 --idt 0.98 -o Q30L60Kmerge/anchor.orient.fasta
anchr merge Q30L60Kmerge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin Q30L60Kmerge/anchor.merge.fasta

rm -fr 9_qa_kmer_Q30
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    Q30L60K21/anchor/pe.anchor.fa \
    Q30L60K31/anchor/pe.anchor.fa \
    Q30L60K41/anchor/pe.anchor.fa \
    Q30L60K51/anchor/pe.anchor.fa \
    Q30L60K61/anchor/pe.anchor.fa \
    Q30L60K71/anchor/pe.anchor.fa \
    Q30L60K81/anchor/pe.anchor.fa \
    Q30L60K91/anchor/pe.anchor.fa \
    Q30L60K101/anchor/pe.anchor.fa \
    Q30L60K111/anchor/pe.anchor.fa \
    Q30L60K121/anchor/pe.anchor.fa \
    Q30L60K67/anchor/pe.anchor.fa \
    Q30L60K43/anchor/pe.anchor.fa \
    Q30L60X40P000/anchor/pe.anchor.fa \
    Q30L60Kmerge/anchor.merge.fasta \
    1_genome/paralogs.fas \
    --label "Q30L60K21,Q30L60K31,Q30L60K41,Q30L60K51,Q30L60K61,Q30L60K71,Q30L60K81,Q30L60K91,Q30L60K101,Q30L60K111,Q30L60K121,Q30L60K67,Q30L60K43,Q30L60X40P000,Q30L60Kmerge,paralogs" \
    -o 9_qa_kmer_Q30

# stat2
REAL_G=4641652

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > statK2.md

parallel -k --no-run-if-empty -j 6 "
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 {1}K{2} ${REAL_G}
    " ::: Q20L60 Q25L60 Q30L60 ::: 21 31 41 51 61 71 81 91 101 111 121 67 43 \
    >> statK2.md

```

| Name       |  SumCor | CovCor | N50SR |   Sum |    # | N50Anchor |     Sum |    # | N50Others |     Sum |    # |  Kmer | RunTimeKU | RunTimeAN |
|:-----------|--------:|-------:|------:|------:|-----:|----------:|--------:|-----:|----------:|--------:|-----:|------:|----------:|:----------|
| Q20L60K21  | 185.67M |   40.0 |  2693 | 4.28M | 2103 |      2973 |   3.83M | 1494 |       779 | 453.06K |  609 |  "21" | 0:01'01'' | 0:01'51'' |
| Q20L60K31  | 185.67M |   40.0 |  3406 | 4.42M | 1788 |      3628 |   4.11M | 1379 |       786 | 305.16K |  409 |  "31" | 0:00'59'' | 0:01'40'' |
| Q20L60K41  | 185.67M |   40.0 |  3630 | 4.48M | 1730 |      3869 |   4.19M | 1343 |       792 | 289.16K |  387 |  "41" | 0:01'00'' | 0:01'53'' |
| Q20L60K51  | 185.67M |   40.0 |  3933 | 4.52M | 1644 |      4111 |   4.26M | 1305 |       791 | 252.67K |  339 |  "51" | 0:00'53'' | 0:01'41'' |
| Q20L60K61  | 185.67M |   40.0 |  4159 | 4.55M | 1569 |      4322 |   4.32M | 1262 |       794 | 228.25K |  307 |  "61" | 0:00'52'' | 0:01'47'' |
| Q20L60K71  | 185.67M |   40.0 |  4413 | 4.57M | 1486 |      4559 |   4.36M | 1212 |       800 | 205.59K |  274 |  "71" | 0:00'52'' | 0:01'53'' |
| Q20L60K81  | 185.67M |   40.0 |  4606 | 4.59M | 1410 |      4791 |    4.4M | 1169 |       807 | 181.87K |  241 |  "81" | 0:00'47'' | 0:01'55'' |
| Q20L60K91  | 185.67M |   40.0 |  4836 |  4.6M | 1375 |      4934 |   4.42M | 1132 |       795 | 181.56K |  243 |  "91" | 0:00'44'' | 0:01'44'' |
| Q20L60K101 | 185.67M |   40.0 |  4593 |  4.6M | 1494 |      4800 |   4.37M | 1181 |       775 | 231.66K |  313 | "101" | 0:00'44'' | 0:01'43'' |
| Q20L60K111 | 185.67M |   40.0 |  3262 | 4.56M | 1987 |      3612 |   4.15M | 1419 |       764 | 415.19K |  568 | "111" | 0:00'44'' | 0:01'55'' |
| Q20L60K121 | 185.67M |   40.0 |  1632 | 4.28M | 3110 |      2117 |   3.22M | 1626 |       747 |   1.07M | 1484 | "121" | 0:00'41'' | 0:01'47'' |
| Q20L60K67  | 185.67M |   40.0 |  4328 | 4.56M | 1516 |      4541 |   4.34M | 1224 |       803 | 218.74K |  292 |  "67" | 0:00'50'' | 0:01'54'' |
| Q20L60K43  | 185.67M |   40.0 |  3714 | 4.49M | 1697 |      4006 |   4.21M | 1324 |       791 | 278.13K |  373 |  "43" | 0:00'50'' | 0:01'39'' |
| Q25L60K21  | 185.67M |   40.0 |  7089 | 4.44M |  999 |      7305 |   4.31M |  828 |       759 | 125.91K |  171 |  "21" | 0:00'52'' | 0:01'06'' |
| Q25L60K31  | 185.67M |   40.0 | 14206 |  4.5M |  500 |     14262 |   4.48M |  464 |       784 |  26.86K |   36 |  "31" | 0:00'52'' | 0:01'13'' |
| Q25L60K41  | 185.67M |   40.0 | 18971 | 4.52M |  387 |     19351 |   4.51M |  364 |       759 |  16.37K |   23 |  "41" | 0:00'54'' | 0:01'20'' |
| Q25L60K51  | 185.67M |   40.0 | 26192 | 4.53M |  335 |     26192 |   4.52M |  312 |       685 |  15.33K |   23 |  "51" | 0:00'49'' | 0:01'12'' |
| Q25L60K61  | 185.67M |   40.0 | 23820 | 4.54M |  344 |     24492 |   4.52M |  321 |       628 |  15.07K |   23 |  "61" | 0:00'48'' | 0:01'14'' |
| Q25L60K71  | 185.67M |   40.0 | 20891 | 4.55M |  403 |     20891 |   4.52M |  372 |       740 |  21.82K |   31 |  "71" | 0:00'46'' | 0:01'16'' |
| Q25L60K81  | 185.67M |   40.0 | 15295 | 4.55M |  529 |     15393 |   4.52M |  478 |       754 |  36.95K |   51 |  "81" | 0:00'40'' | 0:00'58'' |
| Q25L60K91  | 185.67M |   40.0 |  9179 | 4.56M |  818 |      9314 |   4.48M |  705 |       764 |  82.59K |  113 |  "91" | 0:00'38'' | 0:00'57'' |
| Q25L60K101 | 185.67M |   40.0 |  5239 | 4.54M | 1393 |      5447 |   4.32M | 1083 |       763 | 225.22K |  310 | "101" | 0:00'37'' | 0:00'59'' |
| Q25L60K111 | 185.67M |   40.0 |  2453 | 4.39M | 2417 |      2852 |   3.72M | 1496 |       754 |  665.2K |  921 | "111" | 0:00'34'' | 0:01'07'' |
| Q25L60K121 | 185.67M |   40.0 |  1147 | 3.59M | 3366 |      1734 |   2.08M | 1218 |       724 |   1.51M | 2148 | "121" | 0:00'31'' | 0:01'08'' |
| Q25L60K67  | 185.67M |   40.0 | 21564 | 4.54M |  387 |     21613 |   4.52M |  361 |       726 |  18.07K |   26 |  "67" | 0:00'44'' | 0:01'15'' |
| Q25L60K43  | 185.67M |   40.0 | 21290 | 4.53M |  366 |     21290 |   4.51M |  345 |       712 |   14.7K |   21 |  "43" | 0:00'53'' | 0:00'54'' |
| Q30L60K21  | 185.67M |   40.0 |  7464 | 4.44M |  948 |      7708 |   4.32M |  789 |       759 | 118.21K |  159 |  "21" | 0:01'11'' | 0:01'52'' |
| Q30L60K31  | 185.67M |   40.0 | 15791 |  4.5M |  447 |     15800 |   4.48M |  414 |       784 |  24.93K |   33 |  "31" | 0:01'13'' | 0:01'57'' |
| Q30L60K41  | 185.67M |   40.0 | 21978 | 4.52M |  378 |     22693 |    4.5M |  349 |       754 |  21.15K |   29 |  "41" | 0:01'13'' | 0:01'59'' |
| Q30L60K51  | 185.67M |   40.0 | 21553 | 4.53M |  380 |     21581 |   4.51M |  348 |       740 |   23.4K |   32 |  "51" | 0:01'00'' | 0:01'41'' |
| Q30L60K61  | 185.67M |   40.0 | 17816 | 4.54M |  477 |     17876 |    4.5M |  429 |       765 |  35.78K |   48 |  "61" | 0:00'57'' | 0:01'55'' |
| Q30L60K71  | 185.67M |   40.0 | 10956 | 4.54M |  725 |     11268 |   4.48M |  641 |       747 |  60.67K |   84 |  "71" | 0:00'56'' | 0:01'55'' |
| Q30L60K81  | 185.67M |   40.0 |  6773 | 4.53M | 1094 |      6982 |   4.39M |  908 |       755 | 135.84K |  186 |  "81" | 0:00'47'' | 0:01'44'' |
| Q30L60K91  | 185.67M |   40.0 |  3702 | 4.45M | 1787 |      4018 |   4.09M | 1294 |       759 |  358.8K |  493 |  "91" | 0:00'43'' | 0:01'55'' |
| Q30L60K101 | 185.67M |   40.0 |  1829 | 4.13M | 2788 |      2227 |   3.23M | 1529 |       744 | 904.82K | 1259 | "101" | 0:00'41'' | 0:01'52'' |
| Q30L60K111 | 185.67M |   40.0 |  1027 | 3.11M | 3145 |      1636 |    1.6M |  966 |       710 |   1.51M | 2179 | "111" | 0:00'42'' | 0:01'26'' |
| Q30L60K121 | 185.67M |   40.0 |   769 | 1.45M | 1820 |      1484 | 449.81K |  295 |       642 | 998.46K | 1525 | "121" | 0:00'34'' | 0:01'07'' |
| Q30L60K67  | 185.67M |   40.0 | 13527 | 4.54M |  592 |     13936 |    4.5M |  532 |       757 |     44K |   60 |  "67" | 0:00'58'' | 0:01'36'' |
| Q30L60K43  | 185.67M |   40.0 | 23150 | 4.53M |  371 |     23535 |    4.5M |  340 |       808 |  23.18K |   31 |  "43" | 0:00'53'' | 0:01'24'' |

## 3GS

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

canu \
    -p ecoli -d canu-raw-40x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=4.8m \
    -pacbio-raw 3_pacbio/pacbio.40x.fasta

canu \
    -p ecoli -d canu-raw-80x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=4.8m \
    -pacbio-raw 3_pacbio/pacbio.80x.fasta

faops n50 -S -C canu-raw-40x/ecoli.trimmedReads.fasta.gz
faops n50 -S -C canu-raw-80x/ecoli.trimmedReads.fasta.gz

```

## Expand anchors

三代 reads 里有一个常见的错误, 即单一 ZMW 里的测序结果中,
接头序列部分的测序结果出现了较多的错误, 因此并没有将接头序列去除干净, 形成的
subreads 里含有多份基因组上同一片段, 它们之间以接头序列为间隔. 二代 contigs
有可能会与一条三代 reads 匹配多次, 对组装造成影响. `anchr group`
命令里提供了选项, 将这种三代的 reads 去除. 此判断没有放到 `anchr cover` 里,
因为拆分出的的 anchors 里也可能会有匹配多次的情况.

```text
      ===
------------>
             )
  <----------
      ===
```

* anchorLong

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

anchr cover \
    --parallel 16 \
    -c 2 -m 40 \
    -b 10 --len 1000 --idt 0.9 \
    merge/anchor.merge.fasta \
    canu-raw-40x/ecoli.trimmedReads.fasta.gz \
    -o merge/anchor.cover.fasta

rm -fr anchorLong
anchr overlap2 \
    --parallel 16 \
    merge/anchor.cover.fasta \
    canu-raw-40x/ecoli.trimmedReads.fasta.gz \
    -d anchorLong \
    -b 10 --len 1000 --idt 0.98

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
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

rm -fr contigTrim
anchr overlap2 \
    --parallel 16 \
    anchorLong/contig.fasta \
    canu-raw-40x/ecoli.contigs.fasta \
    -d contigTrim \
    -b 10 --len 1000 --idt 0.98 --all

CONTIG_COUNT=$(faops n50 -H -N 0 -C contigTrim/anchor.fasta)
echo ${CONTIG_COUNT}

rm -fr contigTrim/group
anchr group \
    --parallel 16 \
    --keep \
    contigTrim/anchorLong.db \
    contigTrim/anchorLong.ovlp.tsv \
    --range "1-${CONTIG_COUNT}" --len 1000 --idt 0.98 --max 20000 -c 1 --png

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

        anchr overlap --len 1000 --idt 0.98 --all \
            group/{}.strand.fasta \
            -o stdout \
            | anchr restrict \
                stdin group/{}.restrict.tsv \
                -o group/{}.ovlp.tsv;

        anchr layout \
            group/{}.ovlp.tsv \
            group/{}.relation.tsv \
            group/{}.strand.fasta \
            --png \
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
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

rm -fr 9_qa_contig
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/anchor.cover.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-raw-40x/ecoli.contigs.fasta \
    canu-raw-80x/ecoli.contigs.fasta \
    1_genome/paralogs.fas \
    --label "merge,cover,contig,contigTrim,canu-40x,canu-80x,paralogs" \
    -o 9_qa_contig

```

* Stats

```bash
BASE_DIR=$HOME/data/anchr/e_coli
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
| Genome       | 4641652 | 4641652 |   1 |
| Paralogs     |    1934 |  195673 | 106 |
| anchor.merge |   95579 | 4564714 | 103 |
| others.merge |    1225 |    2242 |   2 |
| anchor.cover |   94389 | 4552209 | 100 |
| anchorLong   |  132686 | 4540198 |  62 |
| contigTrim   | 4594649 | 4636507 |   2 |

| Name         |     N50 |     Sum |   # |
|:-------------|--------:|--------:|----:|
| Genome       | 4641652 | 4641652 |   1 |
| Paralogs     |    1934 |  195673 | 106 |
| anchor.merge |   73736 | 4541010 | 120 |
| others.merge |    2571 |    7797 |   4 |
| anchor.cover |   73736 | 4531274 | 116 |
| anchorLong   |   97556 | 4530064 |  92 |
| contigTrim   | 3692388 | 4432486 |   3 |

* Clear QxxLxxx.

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr 2_illumina/Q{1,20,25,30,35}L*
rm -fr Q{20,25,30,35}L*
```
