# Tuning parameters for the dataset of *E. coli*

[TOC level=1-3]: # " "
- [Tuning parameters for the dataset of *E. coli*](#tuning-parameters-for-the-dataset-of-e-coli)
- [More tools on downloading and preprocessing data](#more-tools-on-downloading-and-preprocessing-data)
    - [Extra external executables](#extra-external-executables)
    - [Two of the leading assemblers](#two-of-the-leading-assemblers)
    - [PacBio specific tools](#pacbio-specific-tools)
- [*Escherichia coli* str. K-12 substr. MG1655](#escherichia-coli-str-k-12-substr-mg1655)
    - [Download](#download)
    - [Preprocess Illumina reads](#preprocess-illumina-reads)
    - [Preprocess Illumina single end reads](#preprocess-illumina-single-end-reads)
    - [Preprocess PacBio reads](#preprocess-pacbio-reads)
    - [Reads stats](#reads-stats)
    - [Spades](#spades)
    - [Platanus](#platanus)
    - [Quorum](#quorum)
    - [Down sampling](#down-sampling)
    - [K-unitigs and anchors (sampled)](#k-unitigs-and-anchors-sampled)
    - [Merge anchors with Qxx, Lxx and QxxLxx](#merge-anchors-with-qxx-lxx-and-qxxlxx)
    - [Merge anchors](#merge-anchors)
    - [Scaffolding with PE](#scaffolding-with-pe)
    - [Different K values](#different-k-values)
    - [3GS](#3gs)
    - [Local corrections](#local-corrections)
    - [Expand anchors](#expand-anchors)
    - [Final stats](#final-stats)


# More tools on downloading and preprocessing data

## Extra external executables

```bash
brew install aria2 curl                     # downloading tools

brew install homebrew/science/sratoolkit    # NCBI SRAToolkit

brew reinstall --build-from-source --without-webp gd # broken, can't find libwebp.so.6
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

* Settings

```bash
BASE_NAME=e_coli
REAL_G=4641652
COVERAGE2="30 40 50 60 80 120 160 200"
COVERAGE3="20 40 80"
READ_QUAL="25 30 35"
READ_LEN="30 60 90"

```

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
cat fasta/m141013.fasta \
    | faops dazz -l 0 -p long stdin pacbio.fasta

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

* kmergenie

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

parallel -j 2 "
    kmergenie -l 21 -k 121 -s 10 -t 8 ../{}.fq.gz -o {}
    " ::: R1 R2

```

## Preprocess Illumina reads

```bash
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

parallel --no-run-if-empty --linebuffer -k -j 3 "
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
    " ::: ${READ_QUAL} ::: ${READ_LEN}

```

* kmc

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/kmc
cd 2_illumina/kmc

# raw
cat <<EOF > list.tmp
../R1.fq.gz
../R2.fq.gz

EOF

kmc -k51 -n100 -ci3 @list.tmp raw . 
kmc_tools transform raw histogram hist.raw.txt

# uniq
cat <<EOF > list.tmp
../R1.uniq.fq.gz
../R2.uniq.fq.gz

EOF

kmc -k51 -n100 -ci3 @list.tmp uniq . 
kmc_tools transform uniq histogram hist.uniq.txt

# Q25L60
cat <<EOF > list.tmp
../Q25L60/R1.fq.gz
../Q25L60/R2.fq.gz

EOF

kmc -k51 -n100 -ci1 @list.tmp Q25L60 . 
kmc_tools transform Q25L60 histogram hist.Q25L60.txt

#kmc_tools transform Q25L60 dump dump.Q25L60.txt

kmc_tools filter Q25L60 @list.tmp -ci3 filtered.fa -fa

faops n50 -H -S -C \
    ../Q25L60/R1.fq.gz \
    ../Q25L60/R2.fq.gz;
    
faops n50 -H -S -C \
    ../Q25L60/pe.cor.fa;

faops n50 -H -S -C \
    filtered.fa;

```

## Preprocess Illumina single end reads

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

# symlink R1.fq.gz
mkdir -p 2_illumina_se
cd 2_illumina_se
ln -s ../2_illumina/MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz R1.fq.gz

cd ${HOME}/data/anchr/${BASE_NAME}

if [ ! -e 2_illumina_se/R1.uniq.fq.gz ]; then
    tally \
        --with-quality --nozip --unsorted \
        -i 2_illumina_se/R1.fq.gz \
        -o 2_illumina_se/R1.uniq.fq

    pigz -p 8 2_illumina_se/R1.uniq.fq
fi

# get the default adapter file
# anchr trim --help
if [ ! -e 2_illumina_se/R1.scythe.fq.gz ]; then
    scythe \
        2_illumina_se/R1.uniq.fq.gz \
        -q sanger \
        -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
        --quiet \
        | pigz -p 4 -c \
        > 2_illumina_se/R1.scythe.fq.gz
fi

if [ ! -e 2_illumina_se/R1.shuffle.fq.gz ]; then
    shuffle.sh \
        in=2_illumina_se/R1.scythe.fq.gz \
        out=2_illumina_se/R1.shuffle.fq

    pigz -p 8 2_illumina_se/R1.shuffle.fq
fi

parallel --no-run-if-empty --linebuffer -k -j 3 "
    mkdir -p 2_illumina_se/Q{1}L{2}
    cd 2_illumina_se/Q{1}L{2}

    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        --noscythe \
        -q {1} -l {2} \
        ../R1.shuffle.fq.gz \
        -o stdout \
        | bash
    " ::: ${READ_QUAL} ::: ${READ_LEN}

```

## Preprocess PacBio reads

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

for X in ${COVERAGE3}; do
    printf "==> Coverage: %s\n" ${X}
    
    faops split-about -m 1 -l 0 \
        3_pacbio/pacbio.fasta \
        $(( ${REAL_G} * ${X} )) \
        3_pacbio
        
    mv 3_pacbio/000.fa "3_pacbio/pacbio.X${X}.raw.fasta"

done

for X in ${COVERAGE3}; do
    printf "==> Coverage: %s\n" ${X}
    
    anchr trimlong --parallel 16 -v \
        "3_pacbio/pacbio.X${X}.raw.fasta" \
        -o "3_pacbio/pacbio.X${X}.trim.fasta"

done

```

## Reads stats

```bash
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
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "shuffle";  faops n50 -H -S -C 2_illumina/R1.shuffle.fq.gz 2_illumina/R2.shuffle.fq.gz;) >> stat.md

parallel --no-run-if-empty -k -j 3 "
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
    " ::: ${READ_QUAL} ::: ${READ_LEN} \
    >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina.se"; faops n50 -H -S -C 2_illumina/R1.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "shuffle";  faops n50 -H -S -C 2_illumina/R1.shuffle.fq.gz;) >> stat.md

parallel --no-run-if-empty -k -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo Q{1}L{2};
            faops n50 -H -S -C \
                2_illumina/Q{1}L{2}/R1.fq.gz;
        )
    " ::: ${READ_QUAL} ::: ${READ_LEN} \
    >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "PacBio";    faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md

parallel --no-run-if-empty -k -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo X{1}.{2};
            faops n50 -H -S -C \
                3_pacbio/pacbio.X{1}.{2}.fasta;
        )
    " ::: ${COVERAGE3} ::: raw trim \
    >> stat.md

cat stat.md

```

| Name        |     N50 |        Sum |        # |
|:------------|--------:|-----------:|---------:|
| Genome      | 4641652 |    4641652 |        1 |
| Paralogs    |    1934 |     195673 |      106 |
| Illumina    |     151 | 1730299940 | 11458940 |
| uniq        |     151 | 1727289000 | 11439000 |
| scythe      |     151 | 1722450607 | 11439000 |
| shuffle     |     151 | 1722450607 | 11439000 |
| Q20L30      |     151 | 1514584050 | 11126596 |
| Q20L60      |     151 | 1468709458 | 10572422 |
| Q20L90      |     151 | 1370119196 |  9617554 |
| Q25L30      |     151 | 1382782641 | 10841386 |
| Q25L60      |     151 | 1317617346 |  9994728 |
| Q25L90      |     151 | 1177142378 |  8586574 |
| Q30L30      |     125 | 1192536117 | 10716954 |
| Q30L60      |     127 | 1149107745 |  9783292 |
| Q30L90      |     130 | 1021609911 |  8105773 |
| Q35L30      |      64 |  588252718 |  9588363 |
| Q35L60      |      72 |  366922898 |  5062192 |
| Q35L90      |      95 |   35259773 |   364046 |
| Illumina.se |     151 |  865149970 |  5729470 |
| uniq        |     151 |  863644500 |  5719500 |
| scythe      |     151 |  861911638 |  5719500 |
| shuffle     |     151 |  861911638 |  5719500 |
| Q20L30      |     151 |  783882899 |  5563298 |
| Q20L60      |     151 |  757802465 |  5286211 |
| Q20L90      |     151 |  703050396 |  4808777 |
| Q25L30      |     151 |  728558482 |  5420693 |
| Q25L60      |     151 |  691634734 |  4997364 |
| Q25L90      |     151 |  613377171 |  4293287 |
| Q30L30      |     135 |  623827219 |  5146199 |
| Q30L60      |     137 |  569705732 |  4468087 |
| Q30L90      |     141 |  446561495 |  3309050 |
| Q35L30      |      67 |  282698520 |  4405787 |
| Q35L60      |      75 |  110177124 |  1458773 |
| Q35L90      |      98 |    2206782 |    22099 |
| PacBio      |   13982 |  748508361 |    87225 |
| X20.raw     |   14138 |   92847236 |    11329 |
| X20.trim    |   13873 |   83906110 |     9733 |
| X40.raw     |   14030 |  185678104 |    22336 |
| X40.trim    |   13702 |  169380879 |    19468 |
| X80.raw     |   13990 |  371337468 |    44005 |
| X80.trim    |   13632 |  339513065 |    38725 |

## Spades

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

spades.py \
    -t 16 \
    -k 21,33,55,77 --careful \
    -1 2_illumina/Q25L60/R1.fq.gz \
    -2 2_illumina/Q25L60/R2.fq.gz \
    -s 2_illumina/Q25L60/Rs.fq.gz \
    -o 8_spades

spades.py \
    -t 16 \
    -k 21,33,55,77 --careful \
    -1 2_illumina/Q30L60/R1.fq.gz \
    -2 2_illumina/Q30L60/R2.fq.gz \
    -s 2_illumina/Q30L60/Rs.fq.gz \
    -o 8_spades_Q30L60

anchr contained \
    8_spades/contigs.fasta \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin 8_spades/contigs.non-contained.fasta

```

## Platanus

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 8_platanus
cd 8_platanus

if [ ! -e pe.fa ]; then
    faops interleave \
        -p pe \
        ../2_illumina/Q25L60/R1.fq.gz \
        ../2_illumina/Q25L60/R2.fq.gz \
        > pe.fa
    
    faops interleave \
        -p se \
        ../2_illumina/Q25L60/Rs.fq.gz \
        > se.fa
fi

platanus assemble -t 16 -m 100 \
    -f pe.fa se.fa \
    2>&1 | tee ass_log.txt

platanus scaffold -t 16 \
    -c out_contig.fa -b out_contigBubble.fa \
    -ip1 pe.fa \
    2>&1 | tee sca_log.txt

platanus gap_close -t 16 \
    -c out_scaffold.fa \
    -ip1 pe.fa \
    2>&1 | tee gap_log.txt

anchr contained \
    out_gapClosed.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin gapClosed.non-contained.fasta

```

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 8_platanus_quorum
cd 8_platanus_quorum

if [ ! -e pe.fa ]; then
    faops interleave \
        -p pe \
        ../2_illumina/Q25L60/R1.fq.gz \
        ../2_illumina/Q25L60/R2.fq.gz \
        > pe.fa
fi

platanus assemble -t 16 -m 100 \
    -f ../2_illumina/Q25L60/pe.cor.fa \
    2>&1 | tee ass_log.txt

platanus scaffold -t 16 \
    -c out_contig.fa -b out_contigBubble.fa \
    -ip1 pe.fa \
    2>&1 | tee sca_log.txt

platanus gap_close -t 16 \
    -c out_scaffold.fa \
    -ip1 pe.fa \
    2>&1 | tee gap_log.txt

```

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 8_platanus_Q30L60
cd 8_platanus_Q30L60

if [ ! -e pe.fa ]; then
    faops interleave \
        -p pe \
        ../2_illumina/Q30L60/R1.fq.gz \
        ../2_illumina/Q30L60/R2.fq.gz \
        > pe.fa
    
    faops interleave \
        -p se \
        ../2_illumina/Q30L60/Rs.fq.gz \
        > se.fa
fi

platanus assemble -t 16 -m 100 \
    -f pe.fa se.fa \
    2>&1 | tee ass_log.txt

platanus scaffold -t 16 \
    -c out_contig.fa -b out_contigBubble.fa \
    -ip1 pe.fa \
    2>&1 | tee sca_log.txt

platanus gap_close -t 16 \
    -c out_scaffold.fa \
    -ip1 pe.fa \
    2>&1 | tee gap_log.txt

```

```text
#### PROCESS INFORMATION ####
VmPeak:          65.317 GByte
VmHWM:            7.030 GByte
```

## Quorum

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

# pe
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
    " ::: ${READ_QUAL} ::: ${READ_LEN}

# se
parallel --no-run-if-empty -j 1 "
    cd 2_illumina_se/Q{1}L{2}
    echo >&2 '==> Group Q{1}L{2} <=='

    if [ ! -e R1.fq.gz ]; then
        echo >&2 '    R1.fq.gz not exists'
        exit;
    fi

    if [ -e pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa exists'
        exit;
    fi

    anchr quorum \
        R1.fq.gz \
        -p 16 \
        -o quorum.sh

    bash quorum.sh
    
    echo >&2
    " ::: ${READ_QUAL} ::: ${READ_LEN}

```

Clear intermediate files.

```bash
cd $HOME/data/anchr/${BASE_NAME}

find 2_illumina* -type f -name "quorum_mer_db.jf" | xargs rm
find 2_illumina* -type f -name "k_u_hash_0"       | xargs rm
find 2_illumina* -type f -name "*.tmp"            | xargs rm
find 2_illumina* -type f -name "pe.renamed.fastq" | xargs rm
find 2_illumina* -type f -name "se.renamed.fastq" | xargs rm
find 2_illumina* -type f -name "pe.cor.sub.fa"    | xargs rm
```

* Stats of processed reads

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > stat1.md

parallel --no-run-if-empty -k -j 3 "
    if [ ! -d 2_illumina/Q{1}L{2} ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 2_illumina/Q{1}L{2} ${REAL_G}
    " ::: ${READ_QUAL} ::: ${READ_LEN} \
     >> stat1.md

parallel --no-run-if-empty -k -j 3 "
    if [ ! -d 2_illumina_se/Q{1}L{2} ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 2_illumina_se/Q{1}L{2} ${REAL_G}
    " ::: ${READ_QUAL} ::: ${READ_LEN} \
     >> stat1.md

cat stat1.md
```

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L30 |   1.38G | 297.9 |    1.3G |  280.6 |   5.808% |     128 | "79" | 4.64M | 4.59M |     0.99 | 0:03'33'' |
| Q25L60 |   1.32G | 283.9 |   1.24G |  267.4 |   5.801% |     133 | "83" | 4.64M | 4.58M |     0.99 | 0:03'22'' |
| Q25L90 |   1.18G | 253.6 |   1.11G |  238.8 |   5.832% |     138 | "87" | 4.64M | 4.57M |     0.99 | 0:03'04'' |
| Q30L30 |   1.19G | 257.0 |   1.16G |  250.7 |   2.437% |     115 | "65" | 4.64M | 4.56M |     0.98 | 0:03'06'' |
| Q30L60 |   1.15G | 247.7 |   1.12G |  241.6 |   2.484% |     120 | "71" | 4.64M | 4.56M |     0.98 | 0:02'58'' |
| Q30L90 |   1.02G | 220.4 | 996.45M |  214.7 |   2.605% |     128 | "79" | 4.64M | 4.56M |     0.98 | 0:02'44'' |
| Q35L30 | 589.03M | 126.9 | 582.15M |  125.4 |   1.169% |      62 | "35" | 4.64M | 4.56M |     0.98 | 0:01'37'' |
| Q35L60 | 369.07M |  79.5 | 362.78M |   78.2 |   1.705% |      73 | "45" | 4.64M | 4.51M |     0.97 | 0:01'03'' |
| Q35L90 |  35.58M |   7.7 |  32.82M |    7.1 |   7.770% |      98 | "65" | 4.64M | 2.03M |     0.44 | 0:00'17'' |
| Q25L30 | 618.38M | 133.2 | 570.17M |  122.8 |   7.796% |     133 | "31" | 4.64M | 4.57M |     0.98 | 0:01'48'' |
| Q25L60 | 607.79M | 130.9 | 560.27M |  120.7 |   7.818% |     137 | "31" | 4.64M | 4.57M |     0.98 | 0:01'45'' |
| Q25L90 | 581.79M | 125.3 | 535.83M |  115.4 |   7.899% |     142 | "31" | 4.64M | 4.56M |     0.98 | 0:01'42'' |
| Q30L30 | 542.41M | 116.9 | 520.61M |  112.2 |   4.020% |     123 | "31" | 4.64M | 4.56M |     0.98 | 0:01'41'' |
| Q30L60 |  524.4M | 113.0 | 503.41M |  108.5 |   4.003% |     128 | "31" | 4.64M | 4.56M |     0.98 | 0:01'36'' |
| Q30L90 | 483.18M | 104.1 | 463.81M |   99.9 |   4.009% |     135 | "31" | 4.64M | 4.56M |     0.98 | 0:01'30'' |
| Q35L30 | 267.51M |  57.6 | 260.03M |   56.0 |   2.798% |      65 | "31" | 4.64M | 4.55M |     0.98 | 0:00'50'' |
| Q35L60 | 184.75M |  39.8 | 179.91M |   38.8 |   2.623% |      76 | "31" | 4.64M | 4.49M |     0.97 | 0:01'02'' |
| Q35L90 |   37.1M |   8.0 |   34.9M |    7.5 |   5.920% |     100 | "31" | 4.64M | 2.89M |     0.62 | 0:00'16'' |

## Down sampling

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

for QxxLxx in $( parallel "echo 'Q{1}L{2}'" ::: ${READ_QUAL} ::: ${READ_LEN} ); do
    echo "==> ${QxxLxx}"

    if [ ! -e 2_illumina/${QxxLxx}/pe.cor.fa ]; then
        echo "2_illumina/${QxxLxx}/pe.cor.fa not exists"
        continue;
    fi

    for X in ${COVERAGE2}; do
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

## K-unitigs and anchors (sampled)

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

# k-unitigs (sampled)
parallel --no-run-if-empty --linebuffer -k -j 2 "
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
        -p 16 \
        --kmer 31,41,51,61,71,81 \
        -o kunitigs.sh
    bash kunitigs.sh

    echo >&2
    " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})

# anchors (sampled)
parallel --no-run-if-empty --linebuffer -k -j 3 "
    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'

    if [ ! -e Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa not exists'
        exit;
    fi

    if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi

    rm -fr Q{1}L{2}X{3}P{4}/anchor
    mkdir -p Q{1}L{2}X{3}P{4}/anchor
    cd Q{1}L{2}X{3}P{4}/anchor
    anchr anchors \
        ../k_unitigs.fasta \
        ../pe.cor.fa \
        -p 8 \
        -o anchors.sh
    bash anchors.sh
    
    echo >&2
    " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})

# Stats of anchors
bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > stat2.md

parallel --no-run-if-empty -k -j 6 "
    if [ ! -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 Q{1}L{2}X{3}P{4} ${REAL_G}
    " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100}) \
    >> stat2.md

cat stat2.md
```

| Name           | SumCor  | CovCor | N50SR |   Sum |    # | N50Anchor |   Sum |    # | N50Others |     Sum |    # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|:--------|-------:|------:|------:|-----:|----------:|------:|-----:|----------:|--------:|-----:|--------------------:|----------:|----------:|
| Q25L30X30P000  | 139.25M |   30.0 | 50795 | 4.55M |  195 |     50795 | 4.53M |  178 |       728 |  12.72K |   17 | "31,41,51,61,71,81" | 0:02'05'' | 0:00'26'' |
| Q25L30X30P001  | 139.25M |   30.0 | 44646 | 4.55M |  197 |     44646 | 4.53M |  175 |       754 |  16.31K |   22 | "31,41,51,61,71,81" | 0:02'15'' | 0:00'26'' |
| Q25L30X30P002  | 139.25M |   30.0 | 39149 | 4.55M |  210 |     39149 | 4.53M |  191 |       754 |  13.89K |   19 | "31,41,51,61,71,81" | 0:02'13'' | 0:00'26'' |
| Q25L30X30P003  | 139.25M |   30.0 | 42744 | 4.55M |  198 |     42744 | 4.53M |  178 |       812 |  14.81K |   20 | "31,41,51,61,71,81" | 0:02'04'' | 0:00'25'' |
| Q25L30X30P004  | 139.25M |   30.0 | 42897 | 4.55M |  207 |     43854 | 4.53M |  190 |       848 |  12.89K |   17 | "31,41,51,61,71,81" | 0:02'12'' | 0:00'25'' |
| Q25L30X30P005  | 139.25M |   30.0 | 43789 | 4.55M |  195 |     43789 | 4.53M |  177 |       812 |  14.12K |   18 | "31,41,51,61,71,81" | 0:02'10'' | 0:00'26'' |
| Q25L30X30P006  | 139.25M |   30.0 | 41329 | 4.55M |  190 |     41329 | 4.53M |  171 |       754 |  14.11K |   19 | "31,41,51,61,71,81" | 0:02'05'' | 0:00'25'' |
| Q25L30X30P007  | 139.25M |   30.0 | 41758 | 4.55M |  201 |     41758 | 4.53M |  182 |       841 |  15.09K |   19 | "31,41,51,61,71,81" | 0:02'12'' | 0:00'25'' |
| Q25L30X30P008  | 139.25M |   30.0 | 40732 | 4.55M |  196 |     40732 | 4.54M |  179 |       847 |  14.64K |   17 | "31,41,51,61,71,81" | 0:02'05'' | 0:00'25'' |
| Q25L30X40P000  | 185.67M |   40.0 | 50567 | 4.55M |  196 |     50567 | 4.53M |  179 |       754 |     13K |   17 | "31,41,51,61,71,81" | 0:02'16'' | 0:00'27'' |
| Q25L30X40P001  | 185.67M |   40.0 | 38554 | 4.55M |  215 |     40089 | 4.53M |  196 |       754 |  14.03K |   19 | "31,41,51,61,71,81" | 0:02'13'' | 0:00'26'' |
| Q25L30X40P002  | 185.67M |   40.0 | 41181 | 4.55M |  203 |     41181 | 4.53M |  184 |       812 |  14.21K |   19 | "31,41,51,61,71,81" | 0:02'18'' | 0:00'26'' |
| Q25L30X40P003  | 185.67M |   40.0 | 39149 | 4.55M |  211 |     39467 | 4.53M |  194 |       812 |  12.79K |   17 | "31,41,51,61,71,81" | 0:02'09'' | 0:00'27'' |
| Q25L30X40P004  | 185.67M |   40.0 | 37301 | 4.55M |  202 |     37301 | 4.53M |  186 |       848 |   12.3K |   16 | "31,41,51,61,71,81" | 0:02'17'' | 0:00'26'' |
| Q25L30X40P005  | 185.67M |   40.0 | 42904 | 4.55M |  198 |     42904 | 4.53M |  178 |       812 |  14.88K |   20 | "31,41,51,61,71,81" | 0:02'09'' | 0:00'26'' |
| Q25L30X40P006  | 185.67M |   40.0 | 40572 | 4.55M |  204 |     40572 | 4.53M |  187 |       812 |  12.81K |   17 | "31,41,51,61,71,81" | 0:02'20'' | 0:00'26'' |
| Q25L30X50P000  | 232.08M |   50.0 | 46295 | 4.55M |  208 |     46295 | 4.53M |  188 |       706 |   14.2K |   20 | "31,41,51,61,71,81" | 0:02'27'' | 0:00'27'' |
| Q25L30X50P001  | 232.08M |   50.0 | 35814 | 4.55M |  234 |     36372 | 4.54M |  213 |       754 |  15.12K |   21 | "31,41,51,61,71,81" | 0:02'38'' | 0:00'27'' |
| Q25L30X50P002  | 232.08M |   50.0 | 39149 | 4.55M |  232 |     39467 | 4.54M |  210 |       706 |  14.91K |   22 | "31,41,51,61,71,81" | 0:02'34'' | 0:00'28'' |
| Q25L30X50P003  | 232.08M |   50.0 | 37618 | 4.55M |  213 |     37618 | 4.53M |  196 |       847 |  13.01K |   17 | "31,41,51,61,71,81" | 0:02'32'' | 0:00'27'' |
| Q25L30X50P004  | 232.08M |   50.0 | 37646 | 4.55M |  224 |     37646 | 4.53M |  202 |       682 |  15.75K |   22 | "31,41,51,61,71,81" | 0:02'37'' | 0:00'27'' |
| Q25L30X60P000  | 278.5M  |   60.0 | 38484 | 4.55M |  234 |     38484 | 4.54M |  213 |       754 |  15.16K |   21 | "31,41,51,61,71,81" | 0:02'46'' | 0:00'28'' |
| Q25L30X60P001  | 278.5M  |   60.0 | 35284 | 4.55M |  244 |     35284 | 4.54M |  221 |       812 |  17.36K |   23 | "31,41,51,61,71,81" | 0:02'55'' | 0:00'27'' |
| Q25L30X60P002  | 278.5M  |   60.0 | 36796 | 4.55M |  250 |     36796 | 4.54M |  232 |       848 |  13.93K |   18 | "31,41,51,61,71,81" | 0:02'40'' | 0:00'28'' |
| Q25L30X60P003  | 278.5M  |   60.0 | 31417 | 4.55M |  241 |     31417 | 4.53M |  219 |       847 |  16.67K |   22 | "31,41,51,61,71,81" | 0:02'47'' | 0:00'28'' |
| Q25L30X80P000  | 371.33M |   80.0 | 27490 | 4.56M |  297 |     27490 | 4.54M |  275 |       812 |  16.04K |   22 | "31,41,51,61,71,81" | 0:03'27'' | 0:00'29'' |
| Q25L30X80P001  | 371.33M |   80.0 | 25813 | 4.56M |  302 |     25829 | 4.54M |  276 |       812 |  19.07K |   26 | "31,41,51,61,71,81" | 0:03'29'' | 0:00'29'' |
| Q25L30X80P002  | 371.33M |   80.0 | 28394 | 4.55M |  287 |     28394 | 4.54M |  261 |       812 |     19K |   26 | "31,41,51,61,71,81" | 0:03'24'' | 0:00'29'' |
| Q25L30X120P000 | 557M    |  120.0 | 19331 | 4.56M |  401 |     19331 | 4.54M |  369 |       831 |  24.91K |   32 | "31,41,51,61,71,81" | 0:04'52'' | 0:00'32'' |
| Q25L30X120P001 | 557M    |  120.0 | 21205 | 4.56M |  388 |     21205 | 4.54M |  358 |       847 |  23.92K |   30 | "31,41,51,61,71,81" | 0:04'44'' | 0:00'32'' |
| Q25L30X160P000 | 742.66M |  160.0 | 14976 | 4.57M |  486 |     15057 | 4.53M |  442 |       857 |  36.26K |   44 | "31,41,51,61,71,81" | 0:06'01'' | 0:00'33'' |
| Q25L30X200P000 | 928.33M |  200.0 | 14154 | 4.57M |  538 |     14184 | 4.53M |  490 |       847 |  39.31K |   48 | "31,41,51,61,71,81" | 0:07'01'' | 0:00'34'' |
| Q25L60X30P000  | 139.25M |   30.0 | 46295 | 4.55M |  205 |     46295 | 4.53M |  189 |       754 |  12.27K |   16 | "31,41,51,61,71,81" | 0:02'12'' | 0:00'26'' |
| Q25L60X30P001  | 139.25M |   30.0 | 40910 | 4.55M |  207 |     40910 | 4.53M |  182 |       754 |   18.2K |   25 | "31,41,51,61,71,81" | 0:02'05'' | 0:00'23'' |
| Q25L60X30P002  | 139.25M |   30.0 | 39125 | 4.54M |  203 |     41023 | 4.53M |  186 |       812 |  12.55K |   17 | "31,41,51,61,71,81" | 0:02'02'' | 0:00'23'' |
| Q25L60X30P003  | 139.25M |   30.0 | 41910 | 4.55M |  205 |     41910 | 4.53M |  184 |       812 |   15.6K |   21 | "31,41,51,61,71,81" | 0:01'59'' | 0:00'25'' |
| Q25L60X30P004  | 139.25M |   30.0 | 37180 | 4.55M |  222 |     37180 | 4.53M |  199 |       841 |  17.14K |   23 | "31,41,51,61,71,81" | 0:02'03'' | 0:00'26'' |
| Q25L60X30P005  | 139.25M |   30.0 | 42414 | 4.55M |  206 |     42414 | 4.53M |  189 |       976 |  15.09K |   17 | "31,41,51,61,71,81" | 0:01'59'' | 0:00'24'' |
| Q25L60X30P006  | 139.25M |   30.0 | 41352 | 4.56M |  198 |     41915 | 4.54M |  181 |      1345 |  23.78K |   17 | "31,41,51,61,71,81" | 0:01'57'' | 0:00'24'' |
| Q25L60X30P007  | 139.25M |   30.0 | 40098 | 4.55M |  214 |     40098 | 4.53M |  192 |       842 |  18.65K |   22 | "31,41,51,61,71,81" | 0:02'06'' | 0:00'24'' |
| Q25L60X40P000  | 185.67M |   40.0 | 46002 | 4.55M |  202 |     46002 | 4.53M |  184 |       754 |   13.6K |   18 | "31,41,51,61,71,81" | 0:02'17'' | 0:00'24'' |
| Q25L60X40P001  | 185.67M |   40.0 | 35665 | 4.55M |  224 |     35665 | 4.53M |  204 |       754 |  14.47K |   20 | "31,41,51,61,71,81" | 0:02'16'' | 0:00'23'' |
| Q25L60X40P002  | 185.67M |   40.0 | 39149 | 4.55M |  207 |     40910 | 4.53M |  187 |       830 |  15.15K |   20 | "31,41,51,61,71,81" | 0:02'16'' | 0:00'24'' |
| Q25L60X40P003  | 185.67M |   40.0 | 39218 | 4.55M |  217 |     39218 | 4.53M |  198 |       812 |     14K |   19 | "31,41,51,61,71,81" | 0:02'14'' | 0:00'25'' |
| Q25L60X40P004  | 185.67M |   40.0 | 41181 | 4.55M |  200 |     41181 | 4.53M |  184 |       857 |  12.34K |   16 | "31,41,51,61,71,81" | 0:02'14'' | 0:00'26'' |
| Q25L60X40P005  | 185.67M |   40.0 | 37874 | 4.55M |  221 |     38618 | 4.52M |  198 |      1255 |  26.26K |   23 | "31,41,51,61,71,81" | 0:02'14'' | 0:00'24'' |
| Q25L60X50P000  | 232.08M |   50.0 | 43332 | 4.55M |  218 |     43332 | 4.53M |  198 |       706 |  14.27K |   20 | "31,41,51,61,71,81" | 0:02'28'' | 0:00'23'' |
| Q25L60X50P001  | 232.08M |   50.0 | 35591 | 4.55M |  235 |     35591 | 4.54M |  216 |       754 |  13.72K |   19 | "31,41,51,61,71,81" | 0:02'31'' | 0:00'24'' |
| Q25L60X50P002  | 232.08M |   50.0 | 36874 | 4.55M |  234 |     37482 | 4.53M |  212 |       754 |  15.89K |   22 | "31,41,51,61,71,81" | 0:02'28'' | 0:00'24'' |
| Q25L60X50P003  | 232.08M |   50.0 | 38807 | 4.55M |  208 |     38807 | 4.53M |  190 |       812 |  13.33K |   18 | "31,41,51,61,71,81" | 0:02'30'' | 0:00'24'' |
| Q25L60X50P004  | 232.08M |   50.0 | 35678 | 4.55M |  234 |     35678 | 4.53M |  214 |       754 |  14.62K |   20 | "31,41,51,61,71,81" | 0:02'31'' | 0:00'25'' |
| Q25L60X60P000  | 278.5M  |   60.0 | 35674 | 4.55M |  244 |     35674 | 4.54M |  224 |       767 |  14.42K |   20 | "31,41,51,61,71,81" | 0:02'50'' | 0:00'25'' |
| Q25L60X60P001  | 278.5M  |   60.0 | 36372 | 4.55M |  247 |     36372 | 4.53M |  224 |       830 |   18.4K |   23 | "31,41,51,61,71,81" | 0:02'46'' | 0:00'25'' |
| Q25L60X60P002  | 278.5M  |   60.0 | 34138 | 4.55M |  256 |     34138 | 4.53M |  237 |       812 |  13.55K |   19 | "31,41,51,61,71,81" | 0:02'46'' | 0:00'24'' |
| Q25L60X60P003  | 278.5M  |   60.0 | 31952 | 4.55M |  245 |     32746 | 4.53M |  222 |       754 |  16.89K |   23 | "31,41,51,61,71,81" | 0:02'46'' | 0:00'27'' |
| Q25L60X80P000  | 371.33M |   80.0 | 27749 | 4.56M |  296 |     27749 | 4.54M |  272 |       812 |  17.62K |   24 | "31,41,51,61,71,81" | 0:03'27'' | 0:00'27'' |
| Q25L60X80P001  | 371.33M |   80.0 | 28431 | 4.55M |  297 |     28831 | 4.53M |  271 |       830 |  20.07K |   26 | "31,41,51,61,71,81" | 0:03'24'' | 0:00'26'' |
| Q25L60X80P002  | 371.33M |   80.0 | 26221 | 4.55M |  296 |     26255 | 4.53M |  269 |       747 |   19.8K |   27 | "31,41,51,61,71,81" | 0:03'31'' | 0:00'28'' |
| Q25L60X120P000 | 557M    |  120.0 | 19611 | 4.56M |  391 |     19828 | 4.54M |  361 |       847 |  24.45K |   30 | "31,41,51,61,71,81" | 0:04'33'' | 0:00'29'' |
| Q25L60X120P001 | 557M    |  120.0 | 21668 | 4.56M |  377 |     21668 | 4.54M |  344 |       847 |  25.77K |   33 | "31,41,51,61,71,81" | 0:04'46'' | 0:00'28'' |
| Q25L60X160P000 | 742.66M |  160.0 | 16181 | 4.57M |  453 |     16181 | 4.54M |  418 |       857 |  29.65K |   35 | "31,41,51,61,71,81" | 0:06'00'' | 0:00'32'' |
| Q25L60X200P000 | 928.33M |  200.0 | 14758 | 4.57M |  491 |     14815 | 4.54M |  451 |       848 |  33.68K |   40 | "31,41,51,61,71,81" | 0:06'35'' | 0:00'36'' |
| Q25L90X30P000  | 139.25M |   30.0 | 36389 | 4.54M |  237 |     36389 | 4.53M |  218 |       754 |  14.37K |   19 | "31,41,51,61,71,81" | 0:02'20'' | 0:00'25'' |
| Q25L90X30P001  | 139.25M |   30.0 | 31862 | 4.55M |  262 |     31862 | 4.53M |  240 |       754 |  15.81K |   22 | "31,41,51,61,71,81" | 0:01'59'' | 0:00'24'' |
| Q25L90X30P002  | 139.25M |   30.0 | 33865 | 4.55M |  247 |     33961 | 4.53M |  225 |       831 |  16.36K |   22 | "31,41,51,61,71,81" | 0:01'52'' | 0:00'23'' |
| Q25L90X30P003  | 139.25M |   30.0 | 36372 | 4.55M |  245 |     36372 | 4.53M |  222 |       706 |  15.73K |   23 | "31,41,51,61,71,81" | 0:01'55'' | 0:00'23'' |
| Q25L90X30P004  | 139.25M |   30.0 | 34042 | 4.54M |  258 |     34138 | 4.53M |  238 |       713 |  14.85K |   20 | "31,41,51,61,71,81" | 0:01'54'' | 0:00'24'' |
| Q25L90X30P005  | 139.25M |   30.0 | 31417 | 4.54M |  255 |     31417 | 4.53M |  235 |       827 |  15.83K |   20 | "31,41,51,61,71,81" | 0:01'52'' | 0:00'24'' |
| Q25L90X30P006  | 139.25M |   30.0 | 31632 | 4.54M |  253 |     31632 | 4.53M |  232 |       812 |   15.7K |   21 | "31,41,51,61,71,81" | 0:01'53'' | 0:00'23'' |
| Q25L90X40P000  | 185.67M |   40.0 | 38635 | 4.55M |  231 |     38635 | 4.53M |  208 |       706 |  15.91K |   23 | "31,41,51,61,71,81" | 0:02'13'' | 0:00'24'' |
| Q25L90X40P001  | 185.67M |   40.0 | 31837 | 4.55M |  250 |     31837 | 4.54M |  230 |       774 |  14.59K |   20 | "31,41,51,61,71,81" | 0:02'11'' | 0:00'24'' |
| Q25L90X40P002  | 185.67M |   40.0 | 36675 | 4.55M |  232 |     36675 | 4.53M |  211 |       705 |  13.94K |   21 | "31,41,51,61,71,81" | 0:02'12'' | 0:00'24'' |
| Q25L90X40P003  | 185.67M |   40.0 | 33644 | 4.55M |  255 |     33644 | 4.53M |  236 |       828 |  14.45K |   19 | "31,41,51,61,71,81" | 0:02'08'' | 0:00'26'' |
| Q25L90X40P004  | 185.67M |   40.0 | 35814 | 4.55M |  231 |     35879 | 4.54M |  211 |       754 |  14.68K |   20 | "31,41,51,61,71,81" | 0:02'11'' | 0:00'24'' |
| Q25L90X50P000  | 232.08M |   50.0 | 35674 | 4.55M |  245 |     35674 | 4.53M |  222 |       637 |  15.86K |   23 | "31,41,51,61,71,81" | 0:02'32'' | 0:00'25'' |
| Q25L90X50P001  | 232.08M |   50.0 | 35233 | 4.56M |  241 |     35814 | 4.54M |  220 |       812 |  15.59K |   21 | "31,41,51,61,71,81" | 0:02'36'' | 0:00'26'' |
| Q25L90X50P002  | 232.08M |   50.0 | 39149 | 4.55M |  248 |     40098 | 4.53M |  226 |       810 |   16.2K |   22 | "31,41,51,61,71,81" | 0:02'35'' | 0:00'26'' |
| Q25L90X50P003  | 232.08M |   50.0 | 30995 | 4.56M |  244 |     31013 | 4.53M |  222 |       937 |  22.55K |   22 | "31,41,51,61,71,81" | 0:02'34'' | 0:00'25'' |
| Q25L90X60P000  | 278.5M  |   60.0 | 29584 | 4.55M |  257 |     29584 | 4.54M |  236 |       636 |  14.36K |   21 | "31,41,51,61,71,81" | 0:02'48'' | 0:00'27'' |
| Q25L90X60P001  | 278.5M  |   60.0 | 36372 | 4.55M |  252 |     36372 | 4.53M |  229 |       767 |  17.04K |   23 | "31,41,51,61,71,81" | 0:02'57'' | 0:00'28'' |
| Q25L90X60P002  | 278.5M  |   60.0 | 31014 | 4.55M |  262 |     31014 | 4.53M |  241 |       847 |  15.79K |   21 | "31,41,51,61,71,81" | 0:02'48'' | 0:00'26'' |
| Q25L90X80P000  | 371.33M |   80.0 | 27311 | 4.55M |  291 |     27550 | 4.54M |  267 |       652 |  16.91K |   24 | "31,41,51,61,71,81" | 0:03'30'' | 0:00'29'' |
| Q25L90X80P001  | 371.33M |   80.0 | 26937 | 4.55M |  304 |     26937 | 4.53M |  277 |       812 |  19.36K |   27 | "31,41,51,61,71,81" | 0:03'40'' | 0:00'30'' |
| Q25L90X120P000 | 557M    |  120.0 | 23577 | 4.56M |  345 |     23577 | 4.54M |  322 |       831 |  19.34K |   23 | "31,41,51,61,71,81" | 0:05'00'' | 0:00'30'' |
| Q25L90X160P000 | 742.66M |  160.0 | 18805 | 4.56M |  390 |     18838 | 4.54M |  364 |       847 |  21.52K |   26 | "31,41,51,61,71,81" | 0:06'13'' | 0:00'34'' |
| Q25L90X200P000 | 928.33M |  200.0 | 18443 | 4.56M |  405 |     18671 | 4.54M |  375 |       811 |  24.11K |   30 | "31,41,51,61,71,81" | 0:06'54'' | 0:00'37'' |
| Q30L30X30P000  | 139.25M |   30.0 | 43854 | 4.55M |  203 |     43854 | 4.53M |  184 |       840 |  17.09K |   19 | "31,41,51,61,71,81" | 0:02'14'' | 0:00'26'' |
| Q30L30X30P001  | 139.25M |   30.0 | 34060 | 4.56M |  221 |     34060 | 4.51M |  197 |     11558 |  49.87K |   24 | "31,41,51,61,71,81" | 0:01'53'' | 0:00'24'' |
| Q30L30X30P002  | 139.25M |   30.0 | 38989 | 4.55M |  214 |     38989 | 4.53M |  195 |       953 |  19.22K |   19 | "31,41,51,61,71,81" | 0:01'49'' | 0:00'25'' |
| Q30L30X30P003  | 139.25M |   30.0 | 41462 | 4.55M |  207 |     41462 | 4.53M |  185 |       812 |  17.16K |   22 | "31,41,51,61,71,81" | 0:01'49'' | 0:00'23'' |
| Q30L30X30P004  | 139.25M |   30.0 | 40063 | 4.55M |  214 |     40063 | 4.53M |  196 |       754 |  13.72K |   18 | "31,41,51,61,71,81" | 0:01'44'' | 0:00'23'' |
| Q30L30X30P005  | 139.25M |   30.0 | 42691 | 4.55M |  213 |     42691 | 4.53M |  193 |       812 |  15.88K |   20 | "31,41,51,61,71,81" | 0:01'48'' | 0:00'24'' |
| Q30L30X30P006  | 139.25M |   30.0 | 34421 | 4.54M |  216 |     34421 | 4.53M |  196 |       839 |  15.64K |   20 | "31,41,51,61,71,81" | 0:01'47'' | 0:00'24'' |
| Q30L30X30P007  | 139.25M |   30.0 | 36362 | 4.57M |  219 |     40210 | 4.53M |  195 |     11558 |  42.75K |   24 | "31,41,51,61,71,81" | 0:01'49'' | 0:00'24'' |
| Q30L30X40P000  | 185.67M |   40.0 | 44646 | 4.55M |  194 |     46295 | 4.53M |  173 |      1000 |  22.81K |   21 | "31,41,51,61,71,81" | 0:02'04'' | 0:00'26'' |
| Q30L30X40P001  | 185.67M |   40.0 | 46294 | 4.54M |  187 |     46294 | 4.53M |  168 |       812 |  14.73K |   19 | "31,41,51,61,71,81" | 0:02'07'' | 0:00'25'' |
| Q30L30X40P002  | 185.67M |   40.0 | 48126 | 4.54M |  187 |     48126 | 4.53M |  168 |       754 |  14.63K |   19 | "31,41,51,61,71,81" | 0:01'59'' | 0:00'24'' |
| Q30L30X40P003  | 185.67M |   40.0 | 44647 | 4.55M |  193 |     44647 | 4.53M |  174 |       754 |  14.66K |   19 | "31,41,51,61,71,81" | 0:02'08'' | 0:00'25'' |
| Q30L30X40P004  | 185.67M |   40.0 | 43854 | 4.55M |  192 |     43854 | 4.53M |  174 |       812 |  14.23K |   18 | "31,41,51,61,71,81" | 0:01'54'' | 0:00'26'' |
| Q30L30X40P005  | 185.67M |   40.0 | 46294 | 4.55M |  189 |     46294 | 4.53M |  170 |       830 |  16.53K |   19 | "31,41,51,61,71,81" | 0:02'04'' | 0:00'25'' |
| Q30L30X50P000  | 232.08M |   50.0 | 49172 | 4.55M |  187 |     49172 | 4.53M |  168 |       754 |  14.49K |   19 | "31,41,51,61,71,81" | 0:02'26'' | 0:00'25'' |
| Q30L30X50P001  | 232.08M |   50.0 | 47078 | 4.54M |  180 |     47078 | 4.53M |  162 |       812 |  14.55K |   18 | "31,41,51,61,71,81" | 0:02'20'' | 0:00'26'' |
| Q30L30X50P002  | 232.08M |   50.0 | 50785 | 4.54M |  178 |     50785 | 4.53M |  161 |       754 |  13.17K |   17 | "31,41,51,61,71,81" | 0:02'22'' | 0:00'24'' |
| Q30L30X50P003  | 232.08M |   50.0 | 48154 | 4.55M |  185 |     48154 | 4.53M |  165 |       820 |  15.96K |   20 | "31,41,51,61,71,81" | 0:02'25'' | 0:00'25'' |
| Q30L30X50P004  | 232.08M |   50.0 | 44647 | 4.55M |  195 |     46294 | 4.53M |  174 |       812 |  19.16K |   21 | "31,41,51,61,71,81" | 0:02'12'' | 0:00'26'' |
| Q30L30X60P000  | 278.5M  |   60.0 | 52431 | 4.55M |  178 |     52431 | 4.53M |  159 |       754 |   14.5K |   19 | "31,41,51,61,71,81" | 0:02'43'' | 0:00'25'' |
| Q30L30X60P001  | 278.5M  |   60.0 | 53712 | 4.55M |  178 |     53712 | 4.53M |  157 |       754 |   16.1K |   21 | "31,41,51,61,71,81" | 0:02'42'' | 0:00'27'' |
| Q30L30X60P002  | 278.5M  |   60.0 | 49172 | 4.55M |  177 |     49172 | 4.53M |  159 |       796 |  13.85K |   18 | "31,41,51,61,71,81" | 0:02'39'' | 0:00'27'' |
| Q30L30X60P003  | 278.5M  |   60.0 | 52798 | 4.55M |  174 |     52798 | 4.53M |  154 |       728 |  14.82K |   20 | "31,41,51,61,71,81" | 0:02'41'' | 0:00'25'' |
| Q30L30X80P000  | 371.33M |   80.0 | 57888 | 4.55M |  167 |     59716 | 4.53M |  147 |       841 |  16.22K |   20 | "31,41,51,61,71,81" | 0:03'24'' | 0:00'30'' |
| Q30L30X80P001  | 371.33M |   80.0 | 54868 | 4.55M |  171 |     54868 | 4.53M |  153 |       754 |  14.03K |   18 | "31,41,51,61,71,81" | 0:03'15'' | 0:00'30'' |
| Q30L30X80P002  | 371.33M |   80.0 | 53723 | 4.55M |  171 |     53723 | 4.53M |  151 |       754 |  15.85K |   20 | "31,41,51,61,71,81" | 0:03'20'' | 0:00'27'' |
| Q30L30X120P000 | 557M    |  120.0 | 57888 | 4.55M |  167 |     57888 | 4.53M |  147 |       946 |  18.05K |   20 | "31,41,51,61,71,81" | 0:04'29'' | 0:00'33'' |
| Q30L30X120P001 | 557M    |  120.0 | 54898 | 4.55M |  166 |     54898 | 4.53M |  146 |       812 |  16.56K |   20 | "31,41,51,61,71,81" | 0:04'27'' | 0:00'33'' |
| Q30L30X160P000 | 742.66M |  160.0 | 57888 | 4.55M |  163 |     57888 | 4.53M |  145 |       946 |  17.68K |   18 | "31,41,51,61,71,81" | 0:05'43'' | 0:00'33'' |
| Q30L30X200P000 | 928.33M |  200.0 | 59716 | 4.55M |  159 |     60917 | 4.53M |  141 |       946 |  17.68K |   18 | "31,41,51,61,71,81" | 0:06'25'' | 0:00'38'' |
| Q30L60X30P000  | 139.25M |   30.0 | 40210 | 4.55M |  230 |     40210 | 4.53M |  209 |       812 |  18.07K |   21 | "31,41,51,61,71,81" | 0:02'11'' | 0:00'26'' |
| Q30L60X30P001  | 139.25M |   30.0 | 34143 | 4.55M |  242 |     34340 | 4.53M |  220 |       830 |  17.15K |   22 | "31,41,51,61,71,81" | 0:01'40'' | 0:00'25'' |
| Q30L60X30P002  | 139.25M |   30.0 | 33644 | 4.56M |  242 |     33644 | 4.53M |  223 |      1255 |   25.9K |   19 | "31,41,51,61,71,81" | 0:01'44'' | 0:00'25'' |
| Q30L60X30P003  | 139.25M |   30.0 | 34347 | 4.54M |  234 |     34347 | 4.53M |  214 |       754 |  15.39K |   20 | "31,41,51,61,71,81" | 0:01'47'' | 0:00'23'' |
| Q30L60X30P004  | 139.25M |   30.0 | 35079 | 4.54M |  245 |     35079 | 4.52M |  222 |       840 |  19.07K |   23 | "31,41,51,61,71,81" | 0:01'43'' | 0:00'23'' |
| Q30L60X30P005  | 139.25M |   30.0 | 33227 | 4.55M |  241 |     33227 | 4.53M |  220 |       933 |  17.79K |   21 | "31,41,51,61,71,81" | 0:01'38'' | 0:00'23'' |
| Q30L60X30P006  | 139.25M |   30.0 | 33961 | 4.56M |  252 |     33961 | 4.52M |  228 |     11472 |  40.39K |   24 | "31,41,51,61,71,81" | 0:01'46'' | 0:00'24'' |
| Q30L60X30P007  | 139.25M |   30.0 | 26225 | 4.56M |  322 |     26439 | 4.53M |  283 |       701 |  26.71K |   39 | "31,41,51,61,71,81" | 0:01'35'' | 0:00'23'' |
| Q30L60X40P000  | 185.67M |   40.0 | 41916 | 4.55M |  208 |     41916 | 4.53M |  186 |       976 |  23.31K |   22 | "31,41,51,61,71,81" | 0:02'03'' | 0:00'26'' |
| Q30L60X40P001  | 185.67M |   40.0 | 40063 | 4.55M |  215 |     40063 | 4.53M |  195 |       812 |  15.48K |   20 | "31,41,51,61,71,81" | 0:02'03'' | 0:00'24'' |
| Q30L60X40P002  | 185.67M |   40.0 | 44646 | 4.54M |  208 |     44646 | 4.53M |  187 |       812 |  15.99K |   21 | "31,41,51,61,71,81" | 0:02'05'' | 0:00'24'' |
| Q30L60X40P003  | 185.67M |   40.0 | 41181 | 4.54M |  211 |     41181 | 4.53M |  191 |       812 |  15.52K |   20 | "31,41,51,61,71,81" | 0:02'02'' | 0:00'25'' |
| Q30L60X40P004  | 185.67M |   40.0 | 40123 | 4.54M |  203 |     40123 | 4.53M |  185 |       812 |  13.95K |   18 | "31,41,51,61,71,81" | 0:02'00'' | 0:00'25'' |
| Q30L60X40P005  | 185.67M |   40.0 | 36221 | 4.55M |  241 |     36221 | 4.53M |  214 |       708 |  19.11K |   27 | "31,41,51,61,71,81" | 0:02'02'' | 0:00'25'' |
| Q30L60X50P000  | 232.08M |   50.0 | 43854 | 4.55M |  201 |     44525 | 4.53M |  180 |       840 |  17.71K |   21 | "31,41,51,61,71,81" | 0:02'24'' | 0:00'27'' |
| Q30L60X50P001  | 232.08M |   50.0 | 47794 | 4.54M |  194 |     47794 | 4.53M |  174 |       822 |  16.02K |   20 | "31,41,51,61,71,81" | 0:02'23'' | 0:00'26'' |
| Q30L60X50P002  | 232.08M |   50.0 | 41923 | 4.55M |  200 |     41923 | 4.53M |  179 |       840 |  16.74K |   21 | "31,41,51,61,71,81" | 0:02'24'' | 0:00'26'' |
| Q30L60X50P003  | 232.08M |   50.0 | 43292 | 4.54M |  194 |     43292 | 4.53M |  175 |       754 |  14.57K |   19 | "31,41,51,61,71,81" | 0:02'27'' | 0:00'26'' |
| Q30L60X60P000  | 278.5M  |   60.0 | 47281 | 4.55M |  186 |     47281 | 4.53M |  166 |       840 |  15.84K |   20 | "31,41,51,61,71,81" | 0:02'39'' | 0:00'28'' |
| Q30L60X60P001  | 278.5M  |   60.0 | 48459 | 4.55M |  190 |     48459 | 4.53M |  169 |       812 |  16.06K |   21 | "31,41,51,61,71,81" | 0:02'45'' | 0:00'26'' |
| Q30L60X60P002  | 278.5M  |   60.0 | 46294 | 4.55M |  191 |     46294 | 4.53M |  172 |       755 |  14.84K |   19 | "31,41,51,61,71,81" | 0:02'43'' | 0:00'28'' |
| Q30L60X60P003  | 278.5M  |   60.0 | 44647 | 4.55M |  202 |     44647 | 4.53M |  180 |       728 |  15.81K |   22 | "31,41,51,61,71,81" | 0:02'39'' | 0:00'28'' |
| Q30L60X80P000  | 371.33M |   80.0 | 53721 | 4.55M |  182 |     53721 | 4.53M |  161 |       848 |  17.27K |   21 | "31,41,51,61,71,81" | 0:03'29'' | 0:00'28'' |
| Q30L60X80P001  | 371.33M |   80.0 | 48437 | 4.55M |  183 |     48437 | 4.53M |  162 |       803 |  16.38K |   21 | "31,41,51,61,71,81" | 0:03'22'' | 0:00'30'' |
| Q30L60X80P002  | 371.33M |   80.0 | 49167 | 4.55M |  187 |     49167 | 4.53M |  164 |       754 |  17.35K |   23 | "31,41,51,61,71,81" | 0:03'17'' | 0:00'31'' |
| Q30L60X120P000 | 557M    |  120.0 | 53723 | 4.55M |  174 |     53723 | 4.53M |  153 |       946 |  19.57K |   21 | "31,41,51,61,71,81" | 0:04'35'' | 0:00'32'' |
| Q30L60X120P001 | 557M    |  120.0 | 50795 | 4.55M |  185 |     50795 | 4.53M |  163 |       764 |  17.56K |   22 | "31,41,51,61,71,81" | 0:04'41'' | 0:00'35'' |
| Q30L60X160P000 | 742.66M |  160.0 | 53735 | 4.55M |  170 |     53735 | 4.53M |  151 |       946 |  18.52K |   19 | "31,41,51,61,71,81" | 0:05'47'' | 0:00'37'' |
| Q30L60X200P000 | 928.33M |  200.0 | 54908 | 4.55M |  167 |     54908 | 4.53M |  149 |       946 |  18.81K |   18 | "31,41,51,61,71,81" | 0:06'37'' | 0:00'44'' |
| Q30L90X30P000  | 139.25M |   30.0 | 23704 | 4.54M |  369 |     23704 | 4.52M |  337 |       732 |  23.38K |   32 | "31,41,51,61,71,81" | 0:02'12'' | 0:00'25'' |
| Q30L90X30P001  | 139.25M |   30.0 | 20880 | 4.54M |  392 |     21288 | 4.52M |  356 |       754 |  26.67K |   36 | "31,41,51,61,71,81" | 0:01'47'' | 0:00'25'' |
| Q30L90X30P002  | 139.25M |   30.0 | 21097 | 4.55M |  383 |     21392 | 4.51M |  347 |       914 |  39.94K |   36 | "31,41,51,61,71,81" | 0:01'45'' | 0:00'24'' |
| Q30L90X30P003  | 139.25M |   30.0 | 19756 | 4.56M |  388 |     19768 |  4.5M |  352 |     10456 |  65.81K |   36 | "31,41,51,61,71,81" | 0:01'47'' | 0:00'24'' |
| Q30L90X30P004  | 139.25M |   30.0 | 23711 | 4.56M |  383 |     23809 |  4.5M |  344 |      1279 |  53.22K |   39 | "31,41,51,61,71,81" | 0:01'38'' | 0:00'23'' |
| Q30L90X30P005  | 139.25M |   30.0 | 30189 | 4.55M |  278 |     30189 | 4.52M |  252 |      1255 |  31.27K |   26 | "31,41,51,61,71,81" | 0:01'54'' | 0:00'23'' |
| Q30L90X30P006  | 139.25M |   30.0 |  8751 | 4.53M |  852 |      8785 | 4.45M |  745 |       751 |  81.67K |  107 | "31,41,51,61,71,81" | 0:01'37'' | 0:00'24'' |
| Q30L90X40P000  | 185.67M |   40.0 | 26791 | 4.55M |  294 |     26791 | 4.52M |  267 |       976 |  31.31K |   27 | "31,41,51,61,71,81" | 0:02'10'' | 0:00'25'' |
| Q30L90X40P001  | 185.67M |   40.0 | 27265 | 4.54M |  311 |     27265 | 4.52M |  284 |       822 |  20.94K |   27 | "31,41,51,61,71,81" | 0:02'09'' | 0:00'24'' |
| Q30L90X40P002  | 185.67M |   40.0 | 25788 | 4.55M |  304 |     25788 | 4.52M |  277 |       968 |  31.19K |   27 | "31,41,51,61,71,81" | 0:02'07'' | 0:00'25'' |
| Q30L90X40P003  | 185.67M |   40.0 | 26255 | 4.54M |  322 |     26530 | 4.52M |  291 |       808 |  23.38K |   31 | "31,41,51,61,71,81" | 0:02'06'' | 0:00'24'' |
| Q30L90X40P004  | 185.67M |   40.0 | 34061 | 4.56M |  260 |     34194 | 4.53M |  236 |      1255 |  30.76K |   24 | "31,41,51,61,71,81" | 0:02'04'' | 0:00'24'' |
| Q30L90X50P000  | 232.08M |   50.0 | 31632 | 4.55M |  259 |     32270 | 4.52M |  236 |      1212 |  29.56K |   23 | "31,41,51,61,71,81" | 0:02'30'' | 0:00'25'' |
| Q30L90X50P001  | 232.08M |   50.0 | 31201 | 4.55M |  268 |     31590 | 4.52M |  242 |       972 |  31.16K |   26 | "31,41,51,61,71,81" | 0:02'23'' | 0:00'25'' |
| Q30L90X50P002  | 232.08M |   50.0 | 31012 | 4.56M |  276 |     31012 | 4.52M |  248 |     11558 |  45.29K |   28 | "31,41,51,61,71,81" | 0:02'29'' | 0:00'24'' |
| Q30L90X50P003  | 232.08M |   50.0 | 36372 | 4.55M |  231 |     36372 | 4.53M |  210 |       848 |  19.79K |   21 | "31,41,51,61,71,81" | 0:02'32'' | 0:00'26'' |
| Q30L90X60P000  | 278.5M  |   60.0 | 34340 | 4.55M |  245 |     34340 | 4.53M |  221 |       854 |   19.6K |   24 | "31,41,51,61,71,81" | 0:02'45'' | 0:00'25'' |
| Q30L90X60P001  | 278.5M  |   60.0 | 35607 | 4.55M |  243 |     35607 | 4.52M |  221 |      1255 |  28.27K |   22 | "31,41,51,61,71,81" | 0:02'48'' | 0:00'25'' |
| Q30L90X60P002  | 278.5M  |   60.0 | 43790 | 4.55M |  213 |     43790 | 4.53M |  191 |       812 |  17.74K |   22 | "31,41,51,61,71,81" | 0:02'50'' | 0:00'27'' |
| Q30L90X80P000  | 371.33M |   80.0 | 37367 | 4.55M |  224 |     37367 | 4.53M |  199 |       854 |  20.94K |   25 | "31,41,51,61,71,81" | 0:03'31'' | 0:00'28'' |
| Q30L90X80P001  | 371.33M |   80.0 | 37357 | 4.54M |  231 |     38964 | 4.53M |  209 |       812 |  17.45K |   22 | "31,41,51,61,71,81" | 0:03'26'' | 0:00'26'' |
| Q30L90X120P000 | 557M    |  120.0 | 42691 | 4.55M |  203 |     42691 | 4.53M |  181 |       929 |  19.77K |   22 | "31,41,51,61,71,81" | 0:04'46'' | 0:00'35'' |
| Q30L90X160P000 | 742.66M |  160.0 | 44646 | 4.55M |  198 |     44646 | 4.53M |  177 |       975 |  20.46K |   21 | "31,41,51,61,71,81" | 0:06'09'' | 0:00'38'' |
| Q30L90X200P000 | 928.33M |  200.0 | 46294 | 4.55M |  190 |     48130 | 4.53M |  170 |       945 |     20K |   20 | "31,41,51,61,71,81" | 0:06'25'' | 0:00'39'' |
| Q35L30X30P000  | 139.25M |   30.0 |  4768 | 4.45M | 1473 |      5201 | 4.18M | 1115 |       770 | 264.86K |  358 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'25'' |
| Q35L30X30P001  | 139.25M |   30.0 |  4754 | 4.45M | 1484 |      5126 | 4.17M | 1119 |       782 | 276.02K |  365 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'25'' |
| Q35L30X30P002  | 139.25M |   30.0 |  4627 | 4.46M | 1507 |      4915 | 4.17M | 1119 |       753 | 293.46K |  388 | "31,41,51,61,71,81" | 0:01'05'' | 0:00'25'' |
| Q35L30X30P003  | 139.25M |   30.0 |  4410 | 4.47M | 1555 |      4788 | 4.17M | 1155 |       784 | 298.35K |  400 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'24'' |
| Q35L30X40P000  | 185.67M |   40.0 |  6751 | 4.51M | 1071 |      6955 | 4.36M |  865 |       762 | 152.52K |  206 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'28'' |
| Q35L30X40P001  | 185.67M |   40.0 |  6571 | 4.51M | 1112 |      6753 | 4.35M |  895 |       767 | 163.46K |  217 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'27'' |
| Q35L30X40P002  | 185.67M |   40.0 |  6716 | 4.53M | 1105 |      6929 | 4.34M |  867 |       783 | 189.23K |  238 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'26'' |
| Q35L30X50P000  | 232.08M |   50.0 |  8227 | 4.53M |  880 |      8309 | 4.42M |  736 |       790 | 118.58K |  144 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'26'' |
| Q35L30X50P001  | 232.08M |   50.0 |  8276 | 4.54M |  907 |      8517 | 4.41M |  742 |       774 | 134.61K |  165 | "31,41,51,61,71,81" | 0:01'23'' | 0:00'28'' |
| Q35L30X60P000  | 278.5M  |   60.0 |  9811 | 4.54M |  774 |      9956 | 4.44M |  645 |       782 | 107.26K |  129 | "31,41,51,61,71,81" | 0:01'36'' | 0:00'30'' |
| Q35L30X60P001  | 278.5M  |   60.0 |  9727 | 4.55M |  782 |      9838 | 4.45M |  660 |       813 | 104.65K |  122 | "31,41,51,61,71,81" | 0:01'33'' | 0:00'33'' |
| Q35L30X80P000  | 371.33M |   80.0 | 11480 | 4.55M |  665 |     11787 | 4.47M |  560 |       781 |  88.42K |  105 | "31,41,51,61,71,81" | 0:01'58'' | 0:00'35'' |
| Q35L30X120P000 | 557M    |  120.0 | 14990 | 4.56M |  530 |     15235 | 4.49M |  449 |       844 |  74.65K |   81 | "31,41,51,61,71,81" | 0:02'14'' | 0:00'37'' |
| Q35L60X30P000  | 139.25M |   30.0 |  1781 | 3.44M | 2422 |      2206 | 2.43M | 1176 |       766 |      1M | 1246 | "31,41,51,61,71,81" | 0:01'15'' | 0:00'25'' |
| Q35L60X30P001  | 139.25M |   30.0 |  1969 |    4M | 2560 |      2490 | 3.13M | 1393 |       753 | 864.07K | 1167 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'28'' |
| Q35L60X40P000  | 185.67M |   40.0 |  2130 | 3.76M | 2304 |      2583 | 2.84M | 1237 |       805 | 917.15K | 1067 | "31,41,51,61,71,81" | 0:01'27'' | 0:00'28'' |
| Q35L60X50P000  | 232.08M |   50.0 |  2907 | 4.13M | 2048 |      3341 | 3.39M | 1235 |       839 |    744K |  813 | "31,41,51,61,71,81" | 0:01'34'' | 0:00'26'' |
| Q35L60X60P000  | 278.5M  |   60.0 |  3810 | 4.35M | 1740 |      4087 | 3.85M | 1187 |       850 | 498.26K |  553 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'27'' |

## Merge anchors with Qxx, Lxx and QxxLxx

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

# merge anchors with Qxx
for Q in ${READ_QUAL}; do
    mkdir -p mergeQ${Q}
    anchr contained \
        $(
            parallel -k --no-run-if-empty -j 6 '
                if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                    echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
                fi
                ' ::: ${Q} :::  ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})
        ) \
        --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
        -o stdout \
        | faops filter -a 1000 -l 0 stdin mergeQ${Q}/anchor.contained.fasta
    anchr orient mergeQ${Q}/anchor.contained.fasta --len 1000 --idt 0.98 -o mergeQ${Q}/anchor.orient.fasta
    anchr merge mergeQ${Q}/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
        | faops filter -a 1000 -l 0 stdin mergeQ${Q}/anchor.merge.fasta
done

# merge anchors with Lxx
for L in ${READ_LEN}; do
    mkdir -p mergeL${L}
    anchr contained \
        $(
            parallel -k --no-run-if-empty -j 6 '
                if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                    echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
                fi
                ' ::: ${READ_QUAL} ::: ${L} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})
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
    mergeQ25/anchor.merge.fasta \
    mergeQ30/anchor.merge.fasta \
    mergeQ35/anchor.merge.fasta \
    mergeL30/anchor.merge.fasta \
    mergeL60/anchor.merge.fasta \
    mergeL90/anchor.merge.fasta \
    1_genome/paralogs.fas \
    --label "mergeQ25,mergeQ30,mergeQ35,mergeL30,mergeL60,mergeL90,paralogs" \
    -o 9_qa_mergeQL

# merge anchors with QxxLxx
for Q in ${READ_QUAL}; do
    for L in ${READ_LEN}; do
        mkdir -p mergeQ${Q}L${L}
        anchr contained \
            $(
                parallel -k --no-run-if-empty -j 6 '
                    if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                        echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
                    fi
                    ' ::: ${Q} ::: ${L} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})
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
    $( parallel -k 'printf "mergeQ{1}L{2}/anchor.merge.fasta "' ::: ${READ_QUAL} ::: ${READ_LEN} ) \
    1_genome/paralogs.fas \
    --label "$( parallel -k 'printf "mergeQ{1}L{2},"' ::: ${READ_QUAL} ::: ${READ_LEN} )paralogs" \
    -o 9_qa_mergeQxxLxx

# merge anchors with QxxXxx
for Q in ${READ_QUAL}; do
    for X in ${COVERAGE2}; do
        mkdir -p mergeQ${Q}X${X}
        anchr contained \
            $(
                parallel -k --no-run-if-empty -j 6 '
                    if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                        echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
                    fi
                    ' ::: ${Q} ::: 60 ::: ${X} ::: $(printf "%03d " {0..100})
            ) \
            --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
            -o stdout \
            | faops filter -a 1000 -l 0 stdin mergeQ${Q}X${X}/anchor.contained.fasta
        anchr orient mergeQ${Q}X${X}/anchor.contained.fasta --len 1000 --idt 0.98 -o mergeQ${Q}X${X}/anchor.orient.fasta
        anchr merge mergeQ${Q}X${X}/anchor.orient.fasta --len 1000 --idt 0.999 -o mergeQ${Q}X${X}/anchor.merge0.fasta
        anchr contained mergeQ${Q}X${X}/anchor.merge0.fasta --len 1000 --idt 0.98 \
            --proportion 0.99 --parallel 16 -o stdout \
            | faops filter -a 1000 -l 0 stdin mergeQ${Q}X${X}/anchor.merge.fasta
    done
done

# quast
rm -fr 9_qa_mergeQxxXxx
quast --no-check --threads 16 \
    --eukaryote \
    -R 1_genome/genome.fa \
    $( parallel -k 'printf "mergeQ{1}X{2}/anchor.merge.fasta "' ::: ${READ_QUAL} ::: ${COVERAGE2} ) \
    1_genome/paralogs.fas \
    --label "$( parallel -k 'printf "mergeQ{1}X{2},"' ::: ${READ_QUAL} ::: ${COVERAGE2} )paralogs" \
    -o 9_qa_mergeQxxXxx

```

## Merge anchors

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

# merge anchors
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
            fi
            " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o merge/anchor.merge0.fasta
anchr contained merge/anchor.merge0.fasta --len 1000 --idt 0.98 \
    --proportion 0.99 --parallel 16 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge1.fasta
faops order merge/anchor.merge1.fasta \
    <(faops size merge/anchor.merge1.fasta | sort -n -r -k2,2 | cut -f 1) \
    merge/anchor.merge.fasta

# merge others
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.others.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.others.fa
            fi
            " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o merge/others.merge0.fasta
anchr contained merge/others.merge0.fasta --len 1000 --idt 0.98 \
    --proportion 0.99 --parallel 16 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.merge.fasta

# anchor sort on ref
bash ~/Scripts/cpan/App-Anchr/share/sort_on_ref.sh merge/anchor.merge.fasta 1_genome/genome.fa merge/anchor.sort
nucmer -l 200 1_genome/genome.fa merge/anchor.sort.fa
mummerplot out.delta --png --large -p anchor.sort

# mummerplot files
rm *.[fr]plot
rm out.delta
rm *.gp
mv anchor.sort.png merge/

# minidot
minimap merge/anchor.sort.fa 1_genome/genome.fa \
    | minidot - > merge/anchor.minidot.eps

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

## Scaffolding with PE

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

# PE
mkdir -p merge/scaffold
cd merge/scaffold

if [ ! -e pe.fa ]; then
    faops interleave \
        -p pe \
        ../../2_illumina/Q25L60/R1.fq.gz \
        ../../2_illumina/Q25L60/R2.fq.gz \
        > pe.fa
fi

anchr scaffold \
    ../anchor.merge.fasta \
    pe.fa \
    -p 8 \
    -o scaffold.sh
bash scaffold.sh

```

## Different K values

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

# oriR1: 67; oriR2: 43; Q30L60: 71

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
    mkdir -p anchor
    cd anchor
    anchr anchors \
        ../k_unitigs.fasta \
        ../pe.cor.fa \
        -p 8 \
        -o anchors.sh
    bash anchors.sh
    " ::: 21 31 41 43 51 61 67 71 81 91 101 111 121

mkdir -p Q25L60Kmerge
anchr contained \
    Q25L60K21/anchor/pe.anchor.fa \
    Q25L60K31/anchor/pe.anchor.fa \
    Q25L60K41/anchor/pe.anchor.fa \
    Q25L60K43/anchor/pe.anchor.fa \
    Q25L60K51/anchor/pe.anchor.fa \
    Q25L60K61/anchor/pe.anchor.fa \
    Q25L60K67/anchor/pe.anchor.fa \
    Q25L60K71/anchor/pe.anchor.fa \
    Q25L60K81/anchor/pe.anchor.fa \
    Q25L60K91/anchor/pe.anchor.fa \
    Q25L60K101/anchor/pe.anchor.fa \
    Q25L60K111/anchor/pe.anchor.fa \
    Q25L60K121/anchor/pe.anchor.fa \
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
    Q25L60K43/anchor/pe.anchor.fa \
    Q25L60K51/anchor/pe.anchor.fa \
    Q25L60K61/anchor/pe.anchor.fa \
    Q25L60K67/anchor/pe.anchor.fa \
    Q25L60K71/anchor/pe.anchor.fa \
    Q25L60K81/anchor/pe.anchor.fa \
    Q25L60K91/anchor/pe.anchor.fa \
    Q25L60K101/anchor/pe.anchor.fa \
    Q25L60K111/anchor/pe.anchor.fa \
    Q25L60K121/anchor/pe.anchor.fa \
    Q25L60X40P000/anchor/pe.anchor.fa \
    Q25L60Kmerge/anchor.merge.fasta \
    1_genome/paralogs.fas \
    --label "Q25L60K21,Q25L60K31,Q25L60K41,Q25L60K43,Q25L60K51,Q25L60K61,Q25L60K67,Q25L60K71,Q25L60K81,Q25L60K91,Q25L60K101,Q25L60K111,Q25L60K121,Q25L60X40P000,Q25L60Kmerge,paralogs" \
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
    mkdir -p anchor
    cd anchor
    anchr anchors \
        ../k_unitigs.fasta \
        ../pe.cor.fa \
        -p 8 \
        -o anchors.sh
    bash anchors.sh
    " ::: 21 31 41 43 51 61 67 71 81 91 101 111 121

mkdir -p Q30L60Kmerge
anchr contained \
    Q30L60K21/anchor/pe.anchor.fa \
    Q30L60K31/anchor/pe.anchor.fa \
    Q30L60K41/anchor/pe.anchor.fa \
    Q30L60K43/anchor/pe.anchor.fa \
    Q30L60K51/anchor/pe.anchor.fa \
    Q30L60K61/anchor/pe.anchor.fa \
    Q30L60K67/anchor/pe.anchor.fa \
    Q30L60K71/anchor/pe.anchor.fa \
    Q30L60K81/anchor/pe.anchor.fa \
    Q30L60K91/anchor/pe.anchor.fa \
    Q30L60K101/anchor/pe.anchor.fa \
    Q30L60K111/anchor/pe.anchor.fa \
    Q30L60K121/anchor/pe.anchor.fa \
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
    Q30L60K43/anchor/pe.anchor.fa \
    Q30L60K51/anchor/pe.anchor.fa \
    Q30L60K61/anchor/pe.anchor.fa \
    Q30L60K67/anchor/pe.anchor.fa \
    Q30L60K71/anchor/pe.anchor.fa \
    Q30L60K81/anchor/pe.anchor.fa \
    Q30L60K91/anchor/pe.anchor.fa \
    Q30L60K101/anchor/pe.anchor.fa \
    Q30L60K111/anchor/pe.anchor.fa \
    Q30L60K121/anchor/pe.anchor.fa \
    Q30L60X40P000/anchor/pe.anchor.fa \
    Q30L60Kmerge/anchor.merge.fasta \
    1_genome/paralogs.fas \
    --label "Q30L60K21,Q30L60K31,Q30L60K41,Q30L60K43,Q30L60K51,Q30L60K61,Q30L60K67,Q30L60K71,Q30L60K81,Q30L60K91,Q30L60K101,Q30L60K111,Q30L60K121,Q30L60X40P000,Q30L60Kmerge,paralogs" \
    -o 9_qa_kmer_Q30

# stat2
REAL_G=4641652

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > statK2.md

parallel -k --no-run-if-empty -j 6 "
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 {1}K{2} ${REAL_G}
    " ::: Q25L60 Q30L60 ::: 21 31 41 43 51 61 67 71 81 91 101 111 121 \
    >> statK2.md

```

| Name       |  SumCor | CovCor | N50SR |   Sum |    # | N50Anchor |     Sum |    # | N50Others |     Sum |    # |  Kmer | RunTimeKU | RunTimeAN |
|:-----------|--------:|-------:|------:|------:|-----:|----------:|--------:|-----:|----------:|--------:|-----:|------:|----------:|:----------|
| Q25L60K21  | 185.67M |   40.0 |  7089 | 4.44M |  999 |      7305 |   4.31M |  827 |       759 | 127.25K |  172 |  "21" | 0:00'48'' | 0:00'33'' |
| Q25L60K31  | 185.67M |   40.0 | 14206 |  4.5M |  500 |     14262 |   4.47M |  462 |       801 |  29.46K |   38 |  "31" | 0:00'47'' | 0:00'33'' |
| Q25L60K41  | 185.67M |   40.0 | 18971 | 4.52M |  387 |     19351 |   4.51M |  362 |       804 |  18.97K |   25 |  "41" | 0:00'47'' | 0:00'33'' |
| Q25L60K43  | 185.67M |   40.0 | 21290 | 4.53M |  366 |     21290 |   4.51M |  343 |       808 |   17.3K |   23 |  "43" | 0:00'46'' | 0:00'35'' |
| Q25L60K51  | 185.67M |   40.0 | 26192 | 4.53M |  334 |     26195 |   4.51M |  309 |       720 |  17.93K |   25 |  "51" | 0:00'45'' | 0:00'34'' |
| Q25L60K61  | 185.67M |   40.0 | 23820 | 4.54M |  344 |     24492 |   4.52M |  319 |       706 |  17.67K |   25 |  "61" | 0:00'46'' | 0:00'33'' |
| Q25L60K67  | 185.67M |   40.0 | 21564 | 4.54M |  387 |     21613 |   4.52M |  359 |       754 |  20.67K |   28 |  "67" | 0:00'42'' | 0:00'35'' |
| Q25L60K71  | 185.67M |   40.0 | 20891 | 4.55M |  403 |     20891 |   4.52M |  370 |       754 |  24.42K |   33 |  "71" | 0:00'42'' | 0:00'35'' |
| Q25L60K81  | 185.67M |   40.0 | 15295 | 4.55M |  529 |     15393 |   4.51M |  476 |       757 |  39.55K |   53 |  "81" | 0:00'40'' | 0:00'35'' |
| Q25L60K91  | 185.67M |   40.0 |  9179 | 4.56M |  818 |      9314 |   4.48M |  703 |       789 |  85.19K |  115 |  "91" | 0:00'37'' | 0:00'36'' |
| Q25L60K101 | 185.67M |   40.0 |  5239 | 4.54M | 1393 |      5449 |   4.32M | 1081 |       764 | 227.82K |  312 | "101" | 0:00'36'' | 0:00'36'' |
| Q25L60K111 | 185.67M |   40.0 |  2453 | 4.39M | 2418 |      2852 |   3.72M | 1494 |       754 | 668.43K |  924 | "111" | 0:00'34'' | 0:00'35'' |
| Q25L60K121 | 185.67M |   40.0 |  1146 | 3.59M | 3369 |      1734 |   2.08M | 1217 |       724 |   1.51M | 2152 | "121" | 0:00'20'' | 0:00'21'' |
| Q30L60K21  | 185.67M |   40.0 |  7464 | 4.44M |  948 |      7708 |   4.32M |  788 |       760 | 119.55K |  160 |  "21" | 0:00'50'' | 0:00'36'' |
| Q30L60K31  | 185.67M |   40.0 | 15791 |  4.5M |  447 |     15800 |   4.48M |  412 |       801 |  27.53K |   35 |  "31" | 0:00'50'' | 0:00'36'' |
| Q30L60K41  | 185.67M |   40.0 | 21978 | 4.52M |  378 |     22693 |    4.5M |  348 |       754 |  22.49K |   30 |  "41" | 0:00'49'' | 0:00'35'' |
| Q30L60K43  | 185.67M |   40.0 | 23150 | 4.53M |  371 |     23535 |    4.5M |  338 |       813 |  25.78K |   33 |  "43" | 0:00'44'' | 0:00'34'' |
| Q30L60K51  | 185.67M |   40.0 | 21553 | 4.53M |  380 |     21581 |   4.51M |  346 |       782 |     26K |   34 |  "51" | 0:00'44'' | 0:00'35'' |
| Q30L60K61  | 185.67M |   40.0 | 17816 | 4.54M |  477 |     17876 |    4.5M |  428 |       792 |  37.13K |   49 |  "61" | 0:00'45'' | 0:00'35'' |
| Q30L60K67  | 185.67M |   40.0 | 13527 | 4.54M |  592 |     13936 |   4.49M |  530 |       785 |   46.6K |   62 |  "67" | 0:00'40'' | 0:00'36'' |
| Q30L60K71  | 185.67M |   40.0 | 10956 | 4.54M |  726 |     11268 |   4.48M |  640 |       757 |  63.27K |   86 |  "71" | 0:00'39'' | 0:00'36'' |
| Q30L60K81  | 185.67M |   40.0 |  6773 | 4.53M | 1094 |      6982 |   4.39M |  906 |       760 | 138.44K |  188 |  "81" | 0:00'39'' | 0:00'36'' |
| Q30L60K91  | 185.67M |   40.0 |  3702 | 4.45M | 1787 |      4021 |   4.08M | 1292 |       761 | 361.39K |  495 |  "91" | 0:00'35'' | 0:00'34'' |
| Q30L60K101 | 185.67M |   40.0 |  1829 | 4.13M | 2788 |      2227 |   3.23M | 1527 |       744 | 907.41K | 1261 | "101" | 0:00'33'' | 0:00'32'' |
| Q30L60K111 | 185.67M |   40.0 |  1027 | 3.11M | 3144 |      1636 |    1.6M |  965 |       710 |   1.51M | 2179 | "111" | 0:00'31'' | 0:00'29'' |
| Q30L60K121 | 185.67M |   40.0 |   769 | 1.45M | 1820 |      1484 | 449.81K |  295 |       643 | 998.63K | 1525 | "121" | 0:00'16'' | 0:00'13'' |

## 3GS

* Canu

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty --linebuffer -k -j 1 "
    echo >&2 '==> Group X{1}-{2}'

    if [ ! -e  3_pacbio/pacbio.X{1}.{2}.fasta ]; then
        echo >&2 '    3_pacbio/pacbio.X{1}.{2}.fasta not exists'
        exit;
    fi

    if [ -e canu-X{1}-{2}/*.contigs.fasta ]; then
        echo >&2 '    contigs.fasta already presents'
        exit;
    fi

    canu \
        -p ${BASE_NAME} -d canu-X{1}-{2} \
        gnuplot=\$(brew --prefix)/Cellar/\$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
        genomeSize=${REAL_G} \
        -pacbio-raw 3_pacbio/pacbio.X{1}.{2}.fasta
    " ::: ${COVERAGE3} ::: raw trim

# canu
printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat3GS.md
printf "|:--|--:|--:|--:|\n" >> stat3GS.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat3GS.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Paralogs"; faops n50 -H -S -C 1_genome/paralogs.fas;) >> stat3GS.md

parallel --no-run-if-empty -k -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo X{1}.{2}.trimmedReads;
            faops n50 -H -S -C \
                canu-X{1}-{2}/${BASE_NAME}.trimmedReads.fasta.gz;
        )

    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo X{1}.{2};
            faops n50 -H -S -C \
                canu-X{1}-{2}/${BASE_NAME}.contigs.fasta;
        )

    " ::: ${COVERAGE3} ::: raw trim \
    >> stat3GS.md

cat stat3GS.md

# minidot
minimap canu-X40-raw/${BASE_NAME}.contigs.fasta 1_genome/genome.fa \
    | minidot - > canu-X40-raw/minidot.eps

minimap canu-X40-trim/${BASE_NAME}.contigs.fasta 1_genome/genome.fa \
    | minidot - > canu-X40-trim/minidot.eps

```

| Name                  |     N50 |       Sum |     # |
|:----------------------|--------:|----------:|------:|
| Genome                | 4641652 |   4641652 |     1 |
| Paralogs              |    1934 |    195673 |   106 |
| X20.raw.trimmedReads  |   13371 |  77919428 |  9346 |
| X20.raw               | 4627684 |   4627684 |     1 |
| X20.trim.trimmedReads |   13315 |  76372731 |  9112 |
| X20.trim              | 3369728 |   4639399 |     4 |
| X40.raw.trimmedReads  |   13386 | 149491812 | 17019 |
| X40.raw               | 4674150 |   4674150 |     1 |
| X40.trim.trimmedReads |   13324 | 147656491 | 16861 |
| X40.trim              | 4674046 |   4674046 |     1 |
| X80.raw.trimmedReads  |   16891 | 173081880 | 10689 |
| X80.raw               | 4658166 |   4658166 |     1 |
| X80.trim.trimmedReads |   16753 | 174620642 | 10873 |
| X80.trim              | 4657933 |   4657933 |     1 |

* miniasm

    * `-S         skip self and dual mappings`
    * `-w INT     minizer window size [{-k}*2/3]`
    * `-L INT     min matching length [40]`
    * `-m FLOAT   merge two chains if FLOAT fraction of minimizers are shared [0.50]`
    * `-t INT     number of threads [3]`

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p miniasm

minimap -Sw5 -L100 -m0 -t16 \
    3_pacbio/pacbio.40x.fasta 3_pacbio/pacbio.40x.fasta \
    > miniasm/pacbio.40x.paf

miniasm miniasm/pacbio.40x.paf > miniasm/utg.noseq.gfa

miniasm -f 3_pacbio/pacbio.40x.fasta miniasm/pacbio.40x.paf \
    > miniasm/utg.gfa

awk '/^S/{print ">"$2"\n"$3}' miniasm/utg.gfa > miniasm/utg.fa

minimap 1_genome/genome.fa miniasm/utg.fa | minidot - > miniasm/utg.eps
```

```bash
#real    0m19.504s
#user    1m11.237s
#sys     0m18.500s
time anchr paf2ovlp --parallel 16 miniasm/pacbio.40x.paf -o miniasm/pacbio.40x.ovlp.tsv

#real    0m19.451s
#user    0m43.343s
#sys     0m9.734s
time anchr paf2ovlp --parallel 4 miniasm/pacbio.40x.paf -o miniasm/pacbio.40x.ovlp.tsv

#real    0m17.324s
#user    0m9.276s
#sys     1m23.833s
time jrange covered miniasm/pacbio.40x.paf --longest --paf -o miniasm/pacbio.40x.pos.txt
```

## Local corrections

```bash
BASE_NAME=e_coli
REAL_G=4641652
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr localCor
anchr overlap2 \
    --parallel 16 \
    merge/anchor.merge.fasta \
    3_pacbio/pacbio.40x.trim.fasta \
    -d localCor \
    -b 10 --len 1000 --idt 0.85 --all

pushd localCor

anchr cover \
    --range "1-$(faops n50 -H -N 0 -C anchor.fasta)" \
    --len 1000 --idt 0.85 -c 2 \
    anchorLong.ovlp.tsv \
    -o anchor.cover.json
cat anchor.cover.json | jq "." > environment.json

rm -fr group
anchr localcor \
    anchorLong.db \
    anchorLong.ovlp.tsv \
    --parallel 16 \
    --range $(cat environment.json | jq -r '.TRUSTED') \
    --len 1000 --idt 0.85 --trim -v

faops some -i -l 0 \
    long.fasta \
    group/overlapped.long.txt \
    independentLong.fasta

# localCor
gzip -d -c -f $(find group -type f -name "*.correctedReads.fasta.gz") \
    | faops filter -l 0 stdin stdout \
    | grep -E '^>long' -A 1 \
    | sed '/^--$/d' \
    | faops dazz -a -l 0 stdin stdout \
    | pigz -c > localCor.fasta.gz

canu \
    -p ${BASE_NAME} -d localCor \
    gnuplotTested=true \
    genomeSize=${REAL_G} \
    -pacbio-corrected localCor.fasta.gz \
    -pacbio-corrected anchor.fasta

canu \
    -p ${BASE_NAME} -d localCorIndep \
    gnuplotTested=true \
    genomeSize=${REAL_G} \
    -pacbio-raw localCor.fasta.gz \
    -pacbio-raw anchor.fasta \
    -pacbio-raw independentLong.fasta

# localTrim
gzip -d -c -f $(find group -type f -name "*.trimmedReads.fasta.gz") \
    | faops filter -l 0 stdin stdout \
    | grep -E '^>long' -A 1 \
    | sed '/^--$/d' \
    | faops dazz -a -l 0 stdin stdout \
    | pigz -c > localTrim.fasta.gz

canu \
    -p ${BASE_NAME} -d localTrim \
    gnuplotTested=true \
    genomeSize=${REAL_G} \
    -pacbio-corrected localCor.fasta.gz \
    -pacbio-corrected anchor.fasta

# globalTrim
canu -assemble \
    -p ${BASE_NAME} -d globalTrim \
    gnuplotTested=true \
    genomeSize=${REAL_G} \
    -pacbio-corrected ../canu-raw-40x/${BASE_NAME}.trimmedReads.fasta.gz \
    -pacbio-corrected anchor.fasta

popd

# quast
rm -fr 9_qa_localCor
quast --no-check --threads 16 \
    --eukaryote \
    -R 1_genome/genome.fa \
    localCor/anchor.fasta \
    localCor/localCor/${BASE_NAME}.contigs.fasta \
    localCor/localCorIndep/${BASE_NAME}.contigs.fasta \
    localCor/localTrim/${BASE_NAME}.contigs.fasta \
    localCor/globalTrim/${BASE_NAME}.contigs.fasta \
    canu-raw-40x/${BASE_NAME}.contigs.fasta \
    canu-trim-40x/${BASE_NAME}.contigs.fasta \
    1_genome/paralogs.fas \
    --label "anchor,localCor,localCorIndep,localTrim,globalTrim,40x,40x.trim,paralogs" \
    -o 9_qa_localCor

find . -type d -name "correction" | xargs rm -fr

```

## Expand anchors

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

* anchorLong

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr anchorLong
anchr overlap2 \
    --parallel 16 \
    merge/anchor.merge.fasta \
    3_pacbio/pacbio.X40.trim.fasta \
    -d anchorLong \
    -b 10 --len 1000 --idt 0.85 --all

pushd anchorLong

anchr cover \
    --range "1-$(faops n50 -H -N 0 -C anchor.fasta)" \
    --len 1000 --idt 0.85 -c 2 \
    anchorLong.ovlp.tsv \
    -o anchor.cover.json
cat anchor.cover.json | jq "." > environment.json

anchr overlap \
    anchor.fasta \
    --serial --len 30 --idt 0.9999 \
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
    > anchor.ovlp.tsv

rm -fr group
anchr group \
    anchorLong.db \
    anchorLong.ovlp.tsv \
    --oa anchor.ovlp.tsv \
    --parallel 16 \
    --range $(cat environment.json | jq -r '.TRUSTED') \
    --len 1000 --idt 0.85 --max "-30" -c 2 --png

cat group/groups.txt \
    | parallel --no-run-if-empty -j 8 '
        echo {};
        anchr orient \
            --len 1000 --idt 0.85 \
            group/{}.anchor.fasta \
            group/{}.long.fasta \
            -r group/{}.restrict.tsv \
            -o group/{}.strand.fasta;

        anchr overlap --len 1000 --idt 0.85 \
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
                $F[3] > 0.9999 or next;
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
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr contigTrim
anchr overlap2 \
    --parallel 16 \
    anchorLong/contig.fasta \
    canu-X40-trim/${BASE_NAME}.contigs.fasta \
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

pushd contigTrim
cat group/groups.txt \
    | parallel --no-run-if-empty --linebuffer -k -j 8 '
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

# minidot
minimap contigTrim/contig.fasta 1_genome/genome.fa \
    | minidot - > contigTrim/contig.minidot.eps

```

## Final stats

* Stats

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

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
    $(echo "anchorLong"; faops n50 -H -S -C anchorLong/contig.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "contigTrim"; faops n50 -H -S -C contigTrim/contig.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "spades.contig"; faops n50 -H -S -C 8_spades/contigs.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "spades.scaffold"; faops n50 -H -S -C 8_spades/scaffolds.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "platanus.contig"; faops n50 -H -S -C 8_platanus/out_contig.fa;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "platanus.scaffold"; faops n50 -H -S -C 8_platanus/out_gapClosed.fa;) >> stat3.md

cat stat3.md
```

| Name              |     N50 |     Sum |    # |
|:------------------|--------:|--------:|-----:|
| Genome            | 4641652 | 4641652 |    1 |
| Paralogs          |    1934 |  195673 |  106 |
| anchor.merge      |   73736 | 4532566 |  117 |
| others.merge      |    5923 |   21847 |    6 |
| anchorLong        |   80390 | 4531790 |  109 |
| contigTrim        | 3790335 | 4616261 |    4 |
| spades.contig     |  132662 | 4645193 |  311 |
| spades.scaffold   |  133063 | 4645555 |  306 |
| platanus.contig   |   15090 | 4683012 | 1069 |
| platanus.scaffold |  133014 | 4575941 |  137 |

* quast

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr 9_qa_contig
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-raw-40x/${BASE_NAME}.contigs.fasta \
    8_spades/scaffolds.fasta \
    8_platanus/out_gapClosed.fa \
    1_genome/paralogs.fas \
    --label "merge,contig,contigTrim,canu-40x,spades,platanus,paralogs" \
    -o 9_qa_contig

```

* Clear intermediate files.

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr 2_illumina/Q{20,25,30,35}L{30,60,90,120}X*
rm -fr Q{20,25,30,35}L{30,60,90,120}X*

rm -fr mergeL*
rm -fr mergeQ*

find . -type d -name "correction" -path "*canu-*" | xargs rm -fr
find . -type d -name "trimming"   -path "*canu-*" | xargs rm -fr
find . -type d -name "unitigging" -path "*canu-*" | xargs rm -fr

find . -type d -path "*8_spades/*" | xargs rm -fr

find . -type f -path "*8_platanus/*" -name "[ps]e.fa" | xargs rm

```
