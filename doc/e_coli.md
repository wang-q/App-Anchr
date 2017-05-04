# Tuning parameters for the dataset of *E. coli*

[TOC level=1-3]: # " "
- [Tuning parameters for the dataset of *E. coli*](#tuning-parameters-for-the-dataset-of-e-coli)
- [More tools on downloading and preprocessing data](#more-tools-on-downloading-and-preprocessing-data)
    - [Extra external executables](#extra-external-executables)
    - [PacBio specific tools](#pacbio-specific-tools)
- [*Escherichia coli* str. K-12 substr. MG1655](#escherichia-coli-str-k-12-substr-mg1655)
    - [Download](#download)
    - [Combinations of different quality values and read lengths](#combinations-of-different-quality-values-and-read-lengths)
    - [Down sampling](#down-sampling)
    - [Generate k-unitigs/super-reads](#generate-k-unitigssuper-reads)
    - [Create anchors](#create-anchors)
    - [Results](#results)
    - [With PE info and substitutions](#with-pe-info-and-substitutions)
    - [Different K values](#different-k-values)
    - [Merge anchors from different groups of reads](#merge-anchors-from-different-groups-of-reads)
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

## Combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 100, 110, 120, 130, 140, and 150

```bash
BASE_DIR=$HOME/data/anchr/e_coli

cd ${BASE_DIR}
tally \
    --pair-by-offset --with-quality --nozip --unsorted \
    -i 2_illumina/R1.fq.gz \
    -j 2_illumina/R2.fq.gz \
    -o 2_illumina/R1.uniq.fq \
    -p 2_illumina/R2.uniq.fq

parallel --no-run-if-empty -j 2 "
        pigz -p 4 2_illumina/{}.uniq.fq
    " ::: R1 R2

# get the default adapter file
# anchr trim --help
cd ${BASE_DIR}
parallel --no-run-if-empty -j 2 "
    scythe \
        2_illumina/{}.uniq.fq.gz \
        -q sanger \
        -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
        --quiet \
        | pigz -p 4 -c \
        > 2_illumina/{}.scythe.fq.gz
    " ::: R1 R2

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
    " ::: 20 25 30 ::: 100 110 120 130 140 150

```

* Stats

```bash
BASE_DIR=$HOME/data/anchr/e_coli
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
    for len in 100 110 120 130 140 150; do
        DIR_COUNT="${BASE_DIR}/2_illumina/Q${qual}L${len}"

        printf "| %s | %s | %s | %s |\n" \
            $(echo "Q${qual}L${len}"; faops n50 -H -S -C ${DIR_COUNT}/R1.fq.gz  ${DIR_COUNT}/R2.fq.gz;) \
            >> stat.md
    done
done

cat stat.md
```

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 4641652 |    4641652 |        1 |
| Paralogs |    1934 |     195673 |      106 |
| Illumina |     151 | 1730299940 | 11458940 |
| PacBio   |   13982 |  748508361 |    87225 |
| uniq     |     151 | 1727289000 | 11439000 |
| scythe   |     151 | 1722450607 | 11439000 |
| Q20L100  |     151 | 1313693158 |  9131290 |
| Q20L110  |     151 | 1239533914 |  8527884 |
| Q20L120  |     151 | 1135307713 |  7723784 |
| Q20L130  |     151 |  974861513 |  6544970 |
| Q20L140  |     151 |  783982447 |  5200288 |
| Q20L150  |     151 |  740819508 |  4906104 |
| Q25L100  |     151 | 1094886162 |  7863866 |
| Q25L110  |     151 |  985156722 |  6959022 |
| Q25L120  |     151 |  837111446 |  5805874 |
| Q25L130  |     151 |  632754699 |  4294152 |
| Q25L140  |     151 |  420621485 |  2795284 |
| Q25L150  |     151 |  373058240 |  2470590 |
| Q30L100  |     134 |  711896900 |  5443968 |
| Q30L110  |     136 |  554338151 |  4113824 |
| Q30L120  |     141 |  383179242 |  2753854 |
| Q30L130  |     151 |  212446523 |  1471424 |
| Q30L140  |     151 |   93333137 |   622856 |
| Q30L150  |     151 |   70528417 |   467078 |

## Down sampling

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

ARRAY=( 
    "2_illumina:original:4000000"
    "2_illumina/Q20L100:Q20L100:4000000"
    "2_illumina/Q20L110:Q20L110:4000000"
    "2_illumina/Q20L120:Q20L120:3500000"
    "2_illumina/Q20L130:Q20L130:3000000"
    "2_illumina/Q20L140:Q20L140:2500000"
    "2_illumina/Q20L150:Q20L150:2500000"
    "2_illumina/Q25L100:Q25L100:3500000"
    "2_illumina/Q25L110:Q25L110:3500000"
    "2_illumina/Q25L120:Q25L120:2500000"
    "2_illumina/Q25L130:Q25L130:2000000"
    "2_illumina/Q25L140:Q25L140:1000000"
    "2_illumina/Q25L150:Q25L150:1000000"
    "2_illumina/Q30L100:Q30L100:2500000"
    "2_illumina/Q30L110:Q30L110:2000000"
    "2_illumina/Q30L120:Q30L120:1000000"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    GROUP_MAX=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[2];')
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    perl -e 'print 500000 * $_, qq{\n} for 1 .. 8' \
    | parallel --no-run-if-empty -j 4 "
        if [[ {} -gt '$GROUP_MAX' ]]; then
            exit;
        fi

        echo '    ${GROUP_ID}_{}'
        mkdir -p ${BASE_DIR}/${GROUP_ID}_{}
        
        if [ -e ${BASE_DIR}/${GROUP_ID}_{}/R1.fq.gz ]; then
            exit;
        fi

        seqtk sample -s{} \
            ${BASE_DIR}/${GROUP_DIR}/R1.fq.gz {} \
            | pigz -p 4 -c > ${BASE_DIR}/${GROUP_ID}_{}/R1.fq.gz
        seqtk sample -s{} \
            ${BASE_DIR}/${GROUP_DIR}/R2.fq.gz {} \
            | pigz -p 4 -c > ${BASE_DIR}/${GROUP_ID}_{}/R2.fq.gz
    "

done
```

## Generate k-unitigs/super-reads

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        original
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        for my $i ( 1 .. 8 ) {
            printf qq{%s_%d\n}, $n, ( 500000 * $i );
        }
    }
    ' \
    | parallel --no-run-if-empty -j 3 "
        echo '==> Group {}'
        
        if [ ! -d ${BASE_DIR}/{} ]; then
            echo '    directory not exists'
            exit;
        fi        

        if [ -e ${BASE_DIR}/{}/pe.cor.fa ]; then
            echo '    pe.cor.fa already presents'
            exit;
        fi

        cd ${BASE_DIR}/{}
        anchr superreads \
            R1.fq.gz R2.fq.gz \
            --nosr -p 8 \
            --kmer 39,49,59,69,79,89 \
            -o superreads.sh
        bash superreads.sh
    "

```

Clear intermediate files.

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## Create anchors

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        original
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        for my $i ( 1 .. 8 ) {
            printf qq{%s_%d\n}, $n, ( 500000 * $i );
        }
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

## Results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

REAL_G=4641652

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

perl -e '
    for my $n (
        qw{
        original
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        for my $i ( 1 .. 8 ) {
            printf qq{%s_%d\n}, $n, ( 500000 * $i );
        }
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
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

perl -e '
    for my $n (
        qw{
        original
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        for my $i ( 1 .. 8 ) {
            printf qq{%s_%d\n}, $n, ( 500000 * $i );
        }
    }
    ' \
    | parallel -k --no-run-if-empty -j 9 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

| Name             |   SumFq | CovFq | AvgRead |                Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:-----------------|--------:|------:|--------:|--------------------:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| original_500000  |    151M |  32.5 |     151 | "39,49,59,69,79,89" |  95.16M |  36.979% | 4.64M | 4.58M |     0.99 |  4.6M |     0 | 0:06'12'' |
| original_1000000 |    302M |  65.1 |     151 | "39,49,59,69,79,89" | 192.04M |  36.411% | 4.64M | 4.68M |     1.01 | 4.43M |     0 | 0:09'54'' |
| original_1500000 |    453M |  97.6 |     151 | "39,49,59,69,79,89" | 290.09M |  35.962% | 4.64M | 4.79M |     1.03 | 4.03M |     0 | 0:13'27'' |
| original_2000000 |    604M | 130.1 |     151 | "39,49,59,69,79,89" | 389.03M |  35.591% | 4.64M | 4.94M |     1.06 | 3.54M |     0 | 0:17'58'' |
| original_2500000 |    755M | 162.7 |     151 | "39,49,59,69,79,89" | 489.12M |  35.215% | 4.64M | 5.11M |     1.10 | 2.98M |     0 | 0:21'22'' |
| original_3000000 |    906M | 195.2 |     151 | "39,49,59,69,79,89" | 589.74M |  34.907% | 4.64M |  5.3M |     1.14 | 2.45M |     0 | 0:26'18'' |
| original_3500000 |   1.06G | 227.7 |     151 | "39,49,59,69,79,89" | 691.24M |  34.604% | 4.64M | 5.51M |     1.19 | 2.05M |     0 | 0:30'39'' |
| original_4000000 |   1.21G | 260.3 |     151 | "39,49,59,69,79,89" | 793.52M |  34.311% | 4.64M | 5.74M |     1.24 | 1.65M |     0 | 0:35'06'' |
| Q20L100_500000   | 143.87M |  31.0 |     144 | "39,49,59,69,79,89" | 124.61M |  13.385% | 4.64M | 4.55M |     0.98 | 4.55M |     0 | 0:07'32'' |
| Q20L100_1000000  | 287.72M |  62.0 |     144 | "39,49,59,69,79,89" | 249.55M |  13.264% | 4.64M | 4.56M |     0.98 | 4.55M |     0 | 0:12'04'' |
| Q20L100_1500000  | 431.61M |  93.0 |     144 | "39,49,59,69,79,89" | 374.63M |  13.202% | 4.64M | 4.57M |     0.98 | 4.57M |     0 | 0:15'47'' |
| Q20L100_2000000  | 575.48M | 124.0 |     144 | "39,49,59,69,79,89" | 499.78M |  13.154% | 4.64M | 4.58M |     0.99 | 4.59M |     0 | 0:19'51'' |
| Q20L100_2500000  | 719.31M | 155.0 |     144 | "39,49,59,69,79,89" | 624.83M |  13.135% | 4.64M | 4.59M |     0.99 |  4.6M |     0 | 0:23'25'' |
| Q20L100_3000000  |  863.2M | 186.0 |     144 | "39,49,59,69,79,89" |  750.2M |  13.091% | 4.64M | 4.61M |     0.99 | 4.62M |     0 | 0:27'12'' |
| Q20L100_3500000  |   1.01G | 217.0 |     144 | "39,49,59,69,79,89" | 875.49M |  13.064% | 4.64M | 4.62M |     1.00 |  4.6M |     0 | 0:32'52'' |
| Q20L100_4000000  |   1.15G | 248.0 |     144 | "39,49,59,69,79,89" |      1G |  13.015% | 4.64M | 4.64M |     1.00 | 4.59M |     0 | 0:35'12'' |
| Q20L110_500000   | 145.36M |  31.3 |     145 | "39,49,59,69,79,89" | 126.11M |  13.244% | 4.64M | 4.55M |     0.98 | 4.55M |     0 | 0:06'57'' |
| Q20L110_1000000  | 290.68M |  62.6 |     145 | "39,49,59,69,79,89" | 252.36M |  13.183% | 4.64M | 4.56M |     0.98 | 4.55M |     0 | 0:11'27'' |
| Q20L110_1500000  | 436.05M |  93.9 |     145 | "39,49,59,69,79,89" | 378.54M |  13.190% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:14'48'' |
| Q20L110_2000000  | 581.39M | 125.3 |     145 | "39,49,59,69,79,89" | 505.05M |  13.130% | 4.64M | 4.58M |     0.99 | 4.58M |     0 | 0:18'40'' |
| Q20L110_2500000  | 726.79M | 156.6 |     145 | "39,49,59,69,79,89" | 631.62M |  13.094% | 4.64M | 4.59M |     0.99 |  4.6M |     0 | 0:22'01'' |
| Q20L110_3000000  | 872.11M | 187.9 |     145 | "39,49,59,69,79,89" |  758.2M |  13.061% | 4.64M |  4.6M |     0.99 | 4.61M |     0 | 0:26'31'' |
| Q20L110_3500000  |   1.02G | 219.2 |     145 | "39,49,59,69,79,89" | 885.09M |  13.010% | 4.64M | 4.62M |     1.00 | 4.61M |     0 | 0:31'22'' |
| Q20L110_4000000  |   1.16G | 250.5 |     145 | "39,49,59,69,79,89" |   1.01G |  12.961% | 4.64M | 4.64M |     1.00 | 4.59M |     0 | 0:34'04'' |
| Q20L120_500000   |    147M |  31.7 |     147 | "39,49,59,69,79,89" | 127.72M |  13.114% | 4.64M | 4.55M |     0.98 | 4.55M |     0 | 0:06'54'' |
| Q20L120_1000000  | 293.95M |  63.3 |     147 | "39,49,59,69,79,89" | 255.24M |  13.169% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:11'13'' |
| Q20L120_1500000  | 440.97M |  95.0 |     147 | "39,49,59,69,79,89" | 383.13M |  13.118% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:14'59'' |
| Q20L120_2000000  | 587.93M | 126.7 |     147 | "39,49,59,69,79,89" | 510.95M |  13.093% | 4.64M | 4.57M |     0.99 | 4.58M |     0 | 0:17'59'' |
| Q20L120_2500000  | 734.94M | 158.3 |     147 | "39,49,59,69,79,89" | 639.02M |  13.051% | 4.64M | 4.58M |     0.99 |  4.6M |     0 | 0:21'05'' |
| Q20L120_3000000  | 881.95M | 190.0 |     147 | "39,49,59,69,79,89" |  767.2M |  13.011% | 4.64M |  4.6M |     0.99 | 4.61M |     0 | 0:23'59'' |
| Q20L120_3500000  |   1.03G | 221.7 |     147 | "39,49,59,69,79,89" | 895.51M |  12.967% | 4.64M | 4.61M |     0.99 | 4.61M |     0 | 0:27'23'' |
| Q20L130_500000   | 148.95M |  32.1 |     149 | "39,49,59,69,79,89" | 129.32M |  13.176% | 4.64M | 4.53M |     0.98 | 4.53M |     0 | 0:05'47'' |
| Q20L130_1000000  |  297.9M |  64.2 |     149 | "39,49,59,69,79,89" | 258.61M |  13.188% | 4.64M | 4.55M |     0.98 | 4.55M |     0 | 0:09'46'' |
| Q20L130_1500000  | 446.85M |  96.3 |     149 | "39,49,59,69,79,89" | 388.08M |  13.152% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:12'00'' |
| Q20L130_2000000  |  595.8M | 128.4 |     149 | "39,49,59,69,79,89" | 517.69M |  13.111% | 4.64M | 4.57M |     0.98 | 4.58M |     0 | 0:15'02'' |
| Q20L130_2500000  | 744.74M | 160.4 |     149 | "39,49,59,69,79,89" | 647.22M |  13.094% | 4.64M | 4.58M |     0.99 | 4.59M |     0 | 0:18'54'' |
| Q20L130_3000000  | 893.69M | 192.5 |     149 | "39,49,59,69,79,89" | 777.03M |  13.054% | 4.64M | 4.59M |     0.99 | 4.61M |     0 | 0:22'40'' |
| Q20L140_500000   | 150.76M |  32.5 |     150 | "39,49,59,69,79,89" | 130.61M |  13.364% | 4.64M | 4.51M |     0.97 |  4.5M |     0 | 0:06'05'' |
| Q20L140_1000000  | 301.51M |  65.0 |     150 | "39,49,59,69,79,89" | 261.25M |  13.355% | 4.64M | 4.54M |     0.98 | 4.54M |     0 | 0:09'04'' |
| Q20L140_1500000  | 452.27M |  97.4 |     150 | "39,49,59,69,79,89" | 391.94M |  13.340% | 4.64M | 4.55M |     0.98 | 4.55M |     0 | 0:11'48'' |
| Q20L140_2000000  | 603.03M | 129.9 |     150 | "39,49,59,69,79,89" |  522.8M |  13.305% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:14'47'' |
| Q20L140_2500000  | 753.79M | 162.4 |     150 | "39,49,59,69,79,89" | 653.87M |  13.256% | 4.64M | 4.57M |     0.98 | 4.59M |     0 | 0:18'16'' |
| Q20L150_500000   |    151M |  32.5 |     150 | "39,49,59,69,79,89" | 130.92M |  13.297% | 4.64M |  4.5M |     0.97 | 4.49M |     0 | 0:05'50'' |
| Q20L150_1000000  |    302M |  65.1 |     150 | "39,49,59,69,79,89" | 261.88M |  13.285% | 4.64M | 4.54M |     0.98 | 4.53M |     0 | 0:08'28'' |
| Q20L150_1500000  |    453M |  97.6 |     150 | "39,49,59,69,79,89" | 392.83M |  13.283% | 4.64M | 4.55M |     0.98 | 4.55M |     0 | 0:11'29'' |
| Q20L150_2000000  |    604M | 130.1 |     150 | "39,49,59,69,79,89" | 523.92M |  13.259% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:14'24'' |
| Q20L150_2500000  | 740.82M | 159.6 |     150 | "39,49,59,69,79,89" | 642.87M |  13.222% | 4.64M | 4.57M |     0.98 | 4.58M |     0 | 0:17'19'' |
| Q25L100_500000   | 139.22M |  30.0 |     139 | "39,49,59,69,79,89" | 131.02M |   5.891% | 4.64M | 4.55M |     0.98 | 4.54M |     0 | 0:05'41'' |
| Q25L100_1000000  | 278.46M |  60.0 |     140 | "39,49,59,69,79,89" | 262.04M |   5.894% | 4.64M | 4.55M |     0.98 | 4.55M |     0 | 0:08'13'' |
| Q25L100_1500000  | 417.71M |  90.0 |     139 | "39,49,59,69,79,89" | 393.08M |   5.895% | 4.64M | 4.56M |     0.98 | 4.55M |     0 | 0:10'50'' |
| Q25L100_2000000  | 556.94M | 120.0 |     140 | "39,49,59,69,79,89" | 524.04M |   5.907% | 4.64M | 4.56M |     0.98 | 4.55M |     0 | 0:13'56'' |
| Q25L100_2500000  | 696.15M | 150.0 |     140 | "39,49,59,69,79,89" |  655.2M |   5.882% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:17'10'' |
| Q25L100_3000000  | 835.35M | 180.0 |     140 | "39,49,59,69,79,89" | 786.18M |   5.885% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:19'15'' |
| Q25L100_3500000  |  974.6M | 210.0 |     139 | "39,49,59,69,79,89" |  917.3M |   5.879% | 4.64M | 4.57M |     0.98 | 4.56M |     0 | 0:22'00'' |
| Q25L110_500000   | 141.56M |  30.5 |     142 | "39,49,59,69,79,89" | 133.09M |   5.986% | 4.64M | 4.54M |     0.98 | 4.54M |     0 | 0:05'33'' |
| Q25L110_1000000  | 283.13M |  61.0 |     141 | "39,49,59,69,79,89" | 266.18M |   5.989% | 4.64M | 4.55M |     0.98 | 4.55M |     0 | 0:08'39'' |
| Q25L110_1500000  | 424.69M |  91.5 |     142 | "39,49,59,69,79,89" | 399.32M |   5.974% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:11'19'' |
| Q25L110_2000000  | 566.27M | 122.0 |     142 | "39,49,59,69,79,89" | 532.46M |   5.972% | 4.64M | 4.56M |     0.98 | 4.55M |     0 | 0:13'20'' |
| Q25L110_2500000  | 707.82M | 152.5 |     142 | "39,49,59,69,79,89" | 665.57M |   5.969% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:16'36'' |
| Q25L110_3000000  |  849.4M | 183.0 |     141 | "39,49,59,69,79,89" | 798.81M |   5.956% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:19'33'' |
| Q25L110_3500000  | 985.16M | 212.2 |     141 | "39,49,59,69,79,89" | 926.49M |   5.955% | 4.64M | 4.57M |     0.98 | 4.56M |     0 | 0:21'50'' |
| Q25L120_500000   | 144.17M |  31.1 |     144 | "39,49,59,69,79,89" | 135.37M |   6.100% | 4.64M | 4.53M |     0.98 | 4.53M |     0 | 0:05'12'' |
| Q25L120_1000000  | 288.38M |  62.1 |     144 | "39,49,59,69,79,89" | 270.86M |   6.076% | 4.64M | 4.55M |     0.98 | 4.54M |     0 | 0:08'25'' |
| Q25L120_1500000  | 432.57M |  93.2 |     144 | "39,49,59,69,79,89" | 406.21M |   6.093% | 4.64M | 4.56M |     0.98 | 4.55M |     0 | 0:11'40'' |
| Q25L120_2000000  | 576.74M | 124.3 |     144 | "39,49,59,69,79,89" | 541.54M |   6.104% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:13'35'' |
| Q25L120_2500000  | 720.92M | 155.3 |     144 | "39,49,59,69,79,89" | 676.98M |   6.096% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:16'39'' |
| Q25L130_500000   | 147.35M |  31.7 |     147 | "39,49,59,69,79,89" | 137.95M |   6.384% | 4.64M |  4.5M |     0.97 | 4.49M |     0 | 0:05'48'' |
| Q25L130_1000000  | 294.71M |  63.5 |     147 | "39,49,59,69,79,89" | 275.86M |   6.393% | 4.64M | 4.54M |     0.98 | 4.53M |     0 | 0:09'12'' |
| Q25L130_1500000  | 442.04M |  95.2 |     147 | "39,49,59,69,79,89" | 413.83M |   6.382% | 4.64M | 4.55M |     0.98 | 4.55M |     0 | 0:11'13'' |
| Q25L130_2000000  | 589.41M | 127.0 |     147 | "39,49,59,69,79,89" | 551.77M |   6.387% | 4.64M | 4.55M |     0.98 | 4.55M |     0 | 0:14'13'' |
| Q25L140_500000   | 150.48M |  32.4 |     150 | "39,49,59,69,79,89" | 140.08M |   6.907% | 4.64M | 4.42M |     0.95 | 4.39M |     0 | 0:05'35'' |
| Q25L140_1000000  | 300.95M |  64.8 |     150 | "39,49,59,69,79,89" | 280.19M |   6.899% | 4.64M |  4.5M |     0.97 | 4.49M |     0 | 0:08'02'' |
| Q25L150_500000   |    151M |  32.5 |     150 | "39,49,59,69,79,89" | 140.28M |   7.097% | 4.64M | 4.38M |     0.94 | 4.35M |     0 | 0:06'31'' |
| Q25L150_1000000  |    302M |  65.1 |     150 | "39,49,59,69,79,89" |  280.8M |   7.020% | 4.64M | 4.48M |     0.97 | 4.47M |     0 | 0:07'59'' |
| Q30L100_500000   | 130.79M |  28.2 |     131 | "39,49,59,69,79,89" |  127.5M |   2.514% | 4.64M | 4.53M |     0.97 | 4.52M |     0 | 0:05'08'' |
| Q30L100_1000000  | 261.57M |  56.4 |     131 | "39,49,59,69,79,89" | 255.01M |   2.508% | 4.64M | 4.55M |     0.98 | 4.54M |     0 | 0:07'26'' |
| Q30L100_1500000  | 392.31M |  84.5 |     131 | "39,49,59,69,79,89" | 382.49M |   2.504% | 4.64M | 4.55M |     0.98 | 4.55M |     0 | 0:09'33'' |
| Q30L100_2000000  | 523.09M | 112.7 |     131 | "39,49,59,69,79,89" | 510.05M |   2.492% | 4.64M | 4.56M |     0.98 | 4.55M |     0 | 0:12'05'' |
| Q30L100_2500000  | 653.84M | 140.9 |     131 | "39,49,59,69,79,89" | 637.52M |   2.495% | 4.64M | 4.56M |     0.98 | 4.55M |     0 | 0:15'17'' |
| Q30L110_500000   | 134.74M |  29.0 |     135 | "39,49,59,69,79,89" | 131.29M |   2.561% | 4.64M |  4.5M |     0.97 | 4.49M |     0 | 0:04'45'' |
| Q30L110_1000000  |  269.5M |  58.1 |     135 | "39,49,59,69,79,89" | 262.57M |   2.571% | 4.64M | 4.54M |     0.98 | 4.54M |     0 | 0:07'21'' |
| Q30L110_1500000  | 404.26M |  87.1 |     135 | "39,49,59,69,79,89" | 393.83M |   2.581% | 4.64M | 4.55M |     0.98 | 4.55M |     0 | 0:09'14'' |
| Q30L110_2000000  |    539M | 116.1 |     134 | "39,49,59,69,79,89" | 525.11M |   2.576% | 4.64M | 4.55M |     0.98 | 4.55M |     0 | 0:11'20'' |
| Q30L120_500000   | 139.15M |  30.0 |     139 | "39,49,59,69,79,89" | 135.34M |   2.739% | 4.64M | 4.44M |     0.96 | 4.41M |     0 | 0:04'45'' |
| Q30L120_1000000  | 278.29M |  60.0 |     139 | "39,49,59,69,79,89" | 270.83M |   2.680% | 4.64M | 4.51M |     0.97 | 4.51M |     0 | 0:06'32'' |

| Name             | N50SR |   Sum |    # | N50Anchor |     Sum |    # | N50Anchor2 |     Sum |  # | N50Others |     Sum |    # |   RunTime |
|:-----------------|------:|------:|-----:|----------:|--------:|-----:|-----------:|--------:|---:|----------:|--------:|-----:|----------:|
| original_500000  |  3846 |  4.6M | 1751 |      4157 |   4.06M | 1228 |       2147 | 213.32K | 99 |       789 | 318.34K |  424 | 0:00'45'' |
| original_1000000 |  1771 | 4.43M | 3062 |      2123 |   3.45M | 1719 |       1177 |  15.37K | 12 |       769 | 973.77K | 1331 | 0:00'54'' |
| original_1500000 |  1224 | 4.03M | 3629 |      1672 |   2.52M | 1517 |       1698 |    1.7K |  1 |       738 |   1.51M | 2111 | 0:01'05'' |
| original_2000000 |   990 | 3.54M | 3718 |      1490 |   1.71M | 1121 |          0 |       0 |  0 |       725 |   1.83M | 2597 | 0:00'51'' |
| original_2500000 |   874 | 2.98M | 3455 |      1396 |   1.16M |  799 |          0 |       0 |  0 |       695 |   1.82M | 2656 | 0:00'53'' |
| original_3000000 |   817 | 2.45M | 2982 |      1349 | 825.06K |  583 |       1613 |   1.61K |  1 |       683 |   1.62M | 2398 | 0:00'56'' |
| original_3500000 |   761 | 2.05M | 2631 |      1341 | 560.77K |  404 |       1964 |   1.96K |  1 |       668 |   1.49M | 2226 | 0:00'58'' |
| original_4000000 |   724 | 1.65M | 2191 |      1327 | 417.33K |  304 |       2210 |   2.21K |  1 |       642 |   1.23M | 1886 | 0:00'53'' |
| Q20L100_500000   | 31648 | 4.55M |  260 |     33580 |   4.53M |  235 |       1866 |   9.11K |  5 |       713 |  13.95K |   20 | 0:00'36'' |
| Q20L100_1000000  | 30722 | 4.55M |  263 |     30722 |   4.54M |  243 |          0 |       0 |  0 |       706 |  13.61K |   20 | 0:00'58'' |
| Q20L100_1500000  | 16010 | 4.57M |  458 |     16299 |   4.54M |  422 |       1280 |   1.28K |  1 |       788 |  25.05K |   35 | 0:01'21'' |
| Q20L100_2000000  |  9260 | 4.59M |  744 |      9427 |   4.53M |  661 |       2148 |   2.15K |  1 |       797 |  61.62K |   82 | 0:01'37'' |
| Q20L100_2500000  |  6319 |  4.6M | 1085 |      6478 |   4.48M |  947 |       4833 |  17.62K |  4 |       785 | 100.93K |  134 | 0:01'45'' |
| Q20L100_3000000  |  4272 | 4.62M | 1549 |      4372 |   4.39M | 1263 |       4733 |  15.32K |  4 |       787 | 210.63K |  282 | 0:02'00'' |
| Q20L100_3500000  |  3106 |  4.6M | 1980 |      3303 |   4.25M | 1516 |       2773 |  11.08K |  4 |       792 | 343.69K |  460 | 0:02'01'' |
| Q20L100_4000000  |  2419 | 4.59M | 2459 |      2689 |   4.02M | 1686 |       2773 |   2.77K |  1 |       774 | 568.22K |  772 | 0:02'09'' |
| Q20L110_500000   | 26454 | 4.55M |  306 |     26703 |    4.5M |  271 |      19729 |   22.1K |  3 |       754 |  27.46K |   32 | 0:00'37'' |
| Q20L110_1000000  | 32391 | 4.55M |  257 |     32391 |   4.54M |  239 |          0 |       0 |  0 |       669 |  12.14K |   18 | 0:00'57'' |
| Q20L110_1500000  | 18847 | 4.56M |  404 |     19029 |   4.54M |  375 |          0 |       0 |  0 |       702 |  19.83K |   29 | 0:01'12'' |
| Q20L110_2000000  | 10772 | 4.58M |  680 |     10920 |   4.54M |  618 |          0 |       0 |  0 |       702 |  43.19K |   62 | 0:01'25'' |
| Q20L110_2500000  |  6904 |  4.6M | 1041 |      7040 |   4.49M |  898 |          0 |       0 |  0 |       825 | 115.65K |  143 | 0:01'39'' |
| Q20L110_3000000  |  4431 | 4.61M | 1488 |      4595 |   4.39M | 1208 |       4629 |   8.49K |  2 |       788 | 208.13K |  278 | 0:01'52'' |
| Q20L110_3500000  |  3296 | 4.61M | 1921 |      3554 |   4.27M | 1468 |       3617 |  11.73K |  4 |       773 | 330.46K |  449 | 0:02'06'' |
| Q20L110_4000000  |  2497 | 4.59M | 2389 |      2734 |   4.05M | 1675 |       2491 |   7.93K |  3 |       781 | 525.37K |  711 | 0:02'33'' |
| Q20L120_500000   | 24425 | 4.55M |  356 |     24537 |   4.49M |  319 |      19605 |  27.39K |  4 |       912 |  31.38K |   33 | 0:00'34'' |
| Q20L120_1000000  | 31095 | 4.56M |  278 |     31095 |   4.49M |  252 |      33493 |   53.1K |  2 |       656 |  15.85K |   24 | 0:00'57'' |
| Q20L120_1500000  | 18621 | 4.56M |  405 |     18621 |   4.54M |  371 |       1095 |    1.1K |  1 |       656 |  22.13K |   33 | 0:03'31'' |
| Q20L120_2000000  | 12305 | 4.58M |  636 |     12348 |   4.54M |  579 |          0 |       0 |  0 |       822 |  41.18K |   57 | 0:04'17'' |
| Q20L120_2500000  |  7248 |  4.6M |  974 |      7391 |    4.5M |  845 |       3838 |   3.84K |  1 |       801 |  96.22K |  128 | 0:05'40'' |
| Q20L120_3000000  |  4610 | 4.61M | 1425 |      4787 |   4.42M | 1170 |          0 |       0 |  0 |       809 |  191.7K |  255 | 0:04'59'' |
| Q20L120_3500000  |  3407 | 4.61M | 1863 |      3710 |   4.28M | 1425 |       3816 |   5.17K |  2 |       795 |  326.9K |  436 | 0:04'48'' |
| Q20L130_500000   | 16764 | 4.53M |  469 |     17016 |   4.47M |  413 |       4300 |  18.94K |  6 |       763 |  36.35K |   50 | 0:00'51'' |
| Q20L130_1000000  | 25380 | 4.55M |  332 |     25590 |    4.5M |  303 |       6625 |  32.63K |  4 |       608 |  15.69K |   25 | 0:01'08'' |
| Q20L130_1500000  | 19022 | 4.56M |  420 |     19022 |   4.53M |  384 |          0 |       0 |  0 |       765 |  25.42K |   36 | 0:01'11'' |
| Q20L130_2000000  | 12256 | 4.58M |  625 |     12309 |   4.52M |  567 |       3838 |   3.84K |  1 |       879 |  59.66K |   57 | 0:02'07'' |
| Q20L130_2500000  |  7490 | 4.59M |  952 |      7610 |    4.5M |  826 |          0 |       0 |  0 |       778 |  91.34K |  126 | 0:02'24'' |
| Q20L130_3000000  |  5051 | 4.61M | 1369 |      5177 |    4.4M | 1112 |       5376 |  16.44K |  4 |       795 | 189.96K |  253 | 0:02'57'' |
| Q20L140_500000   | 11454 |  4.5M |  668 |     11869 |    4.4M |  568 |       3752 |  41.79K | 14 |       754 |  63.83K |   86 | 0:00'35'' |
| Q20L140_1000000  | 18478 | 4.54M |  443 |     18819 |   4.49M |  384 |       4547 |   8.46K |  4 |       754 |  39.22K |   55 | 0:01'03'' |
| Q20L140_1500000  | 16968 | 4.55M |  486 |     17031 |    4.5M |  433 |       3771 |   9.69K |  3 |       775 |  35.78K |   50 | 0:01'26'' |
| Q20L140_2000000  | 11340 | 4.57M |  654 |     11555 |   4.52M |  593 |       1167 |   1.17K |  1 |       805 |  43.75K |   60 | 0:01'38'' |
| Q20L140_2500000  |  7606 | 4.59M |  969 |      7728 |   4.49M |  840 |       6887 |  10.47K |  2 |       765 |  91.28K |  127 | 0:01'56'' |
| Q20L150_500000   | 10349 | 4.49M |  736 |     10602 |   4.37M |  615 |       2465 |   41.3K | 19 |       792 |  75.49K |  102 | 0:00'31'' |
| Q20L150_1000000  | 18310 | 4.53M |  460 |     18339 |   4.49M |  412 |       1267 |   3.92K |  3 |       695 |  31.37K |   45 | 0:00'54'' |
| Q20L150_1500000  | 15329 | 4.55M |  503 |     15394 |   4.51M |  457 |       1443 |   2.56K |  2 |       743 |  31.63K |   44 | 0:01'21'' |
| Q20L150_2000000  | 11463 | 4.56M |  653 |     11512 |    4.5M |  587 |      12899 |   12.9K |  1 |       742 |  46.07K |   65 | 0:01'38'' |
| Q20L150_2500000  |  8045 | 4.58M |  897 |      8116 |   4.48M |  781 |       6887 |  10.48K |  2 |       762 |  82.55K |  114 | 0:01'50'' |
| Q25L100_500000   | 27865 | 4.54M |  312 |     27865 |   4.52M |  287 |       2423 |   2.42K |  1 |       817 |  18.49K |   24 | 0:00'44'' |
| Q25L100_1000000  | 43870 | 4.55M |  219 |     43870 |   4.53M |  195 |          0 |       0 |  0 |       645 |  15.48K |   24 | 0:01'01'' |
| Q25L100_1500000  | 52776 | 4.55M |  199 |     52776 |   4.53M |  177 |       3592 |   3.59K |  1 |       680 |  13.97K |   21 | 0:01'31'' |
| Q25L100_2000000  | 49180 | 4.55M |  197 |     49180 |   4.54M |  174 |       1695 |    1.7K |  1 |       642 |  14.36K |   22 | 0:01'52'' |
| Q25L100_2500000  | 43870 | 4.56M |  227 |     43870 |   4.54M |  205 |       1084 |   1.08K |  1 |       610 |  13.43K |   21 | 0:02'12'' |
| Q25L100_3000000  | 33508 | 4.56M |  247 |     33508 |   4.54M |  225 |          0 |       0 |  0 |       688 |  14.46K |   22 | 0:02'32'' |
| Q25L100_3500000  | 26271 | 4.56M |  297 |     26271 |   4.55M |  276 |          0 |       0 |  0 |       625 |  13.41K |   21 | 0:02'44'' |
| Q25L110_500000   | 21657 | 4.54M |  373 |     21657 |   4.51M |  341 |       2645 |   3.93K |  2 |       713 |  20.55K |   30 | 0:00'40'' |
| Q25L110_1000000  | 35683 | 4.55M |  253 |     35835 |   4.53M |  229 |          0 |       0 |  0 |       677 |  15.96K |   24 | 0:01'08'' |
| Q25L110_1500000  | 41371 | 4.56M |  216 |     41371 |   4.48M |  192 |      44949 |  65.83K |  3 |       634 |  13.78K |   21 | 0:01'24'' |
| Q25L110_2000000  | 37626 | 4.55M |  234 |     37626 |   4.54M |  211 |       1122 |   1.12K |  1 |       656 |  14.32K |   22 | 0:02'13'' |
| Q25L110_2500000  | 35689 | 4.56M |  249 |     35689 |   4.54M |  222 |          0 |       0 |  0 |       705 |  18.31K |   27 | 0:02'13'' |
| Q25L110_3000000  | 30643 | 4.56M |  268 |     31000 |   4.55M |  247 |          0 |       0 |  0 |       656 |   13.7K |   21 | 0:03'02'' |
| Q25L110_3500000  | 27093 | 4.56M |  317 |     27285 |   4.54M |  290 |          0 |       0 |  0 |       656 |  17.34K |   27 | 0:02'34'' |
| Q25L120_500000   | 15848 | 4.53M |  493 |     15988 |   4.47M |  442 |       7951 |  24.77K |  5 |       855 |   38.7K |   46 | 0:01'04'' |
| Q25L120_1000000  | 29122 | 4.54M |  308 |     30175 |   4.52M |  279 |       3439 |   3.44K |  1 |       728 |  19.72K |   28 | 0:01'05'' |
| Q25L120_1500000  | 35830 | 4.55M |  260 |     35830 |   4.53M |  237 |       6125 |   6.13K |  1 |       714 |  14.92K |   22 | 0:01'20'' |
| Q25L120_2000000  | 35093 | 4.56M |  255 |     35093 |   4.48M |  228 |      44348 |  64.09K |  2 |       632 |  16.54K |   25 | 0:01'53'' |
| Q25L120_2500000  | 34790 | 4.56M |  248 |     32921 |   4.48M |  225 |      44351 |   64.1K |  2 |       631 |  13.34K |   21 | 0:02'22'' |
| Q25L130_500000   | 10823 | 4.49M |  719 |     11108 |    4.4M |  614 |       1544 |  17.21K | 12 |       780 |  68.74K |   93 | 0:00'52'' |
| Q25L130_1000000  | 18911 | 4.53M |  432 |     19388 |   4.47M |  377 |       6123 |  21.24K |  5 |       772 |  36.25K |   50 | 0:01'07'' |
| Q25L130_1500000  | 26301 | 4.55M |  353 |     26427 |   4.49M |  312 |      12180 |  31.15K |  4 |       746 |  26.03K |   37 | 0:01'39'' |
| Q25L130_2000000  | 26271 | 4.55M |  336 |     26307 |    4.5M |  301 |      18278 |  30.74K |  4 |       703 |  21.23K |   31 | 0:01'42'' |
| Q25L140_500000   |  6856 | 4.39M | 1128 |      7240 |   4.15M |  851 |       1896 |  50.39K | 26 |       765 | 187.74K |  251 | 0:00'43'' |
| Q25L140_1000000  | 11683 | 4.49M |  707 |     12121 |   4.37M |  579 |       2377 |  29.19K | 12 |       785 |  87.72K |  116 | 0:00'56'' |
| Q25L150_500000   |  5786 | 4.35M | 1201 |      6178 |    4.1M |  919 |       1589 |  52.79K | 29 |       776 | 190.19K |  253 | 0:00'33'' |
| Q25L150_1000000  |  9960 | 4.47M |  783 |     10120 |   4.36M |  645 |       1856 |  24.09K | 12 |       732 |  89.04K |  126 | 0:00'55'' |
| Q30L100_500000   | 12611 | 4.52M |  625 |     12809 |   4.45M |  543 |       2728 |  10.05K |  5 |       738 |  54.92K |   77 | 0:00'36'' |
| Q30L100_1000000  | 21563 | 4.54M |  404 |     21657 |    4.5M |  365 |       4422 |  16.67K |  4 |       728 |  24.97K |   35 | 0:01'15'' |
| Q30L100_1500000  | 25590 | 4.55M |  322 |     25788 |   4.52M |  290 |       4007 |  10.34K |  3 |       680 |  19.93K |   29 | 0:01'43'' |
| Q30L100_2000000  | 33868 | 4.55M |  274 |     34056 |   4.53M |  247 |       5635 |      7K |  2 |       656 |  17.06K |   25 | 0:02'11'' |
| Q30L100_2500000  | 35093 | 4.55M |  250 |     35093 |   4.54M |  227 |          0 |       0 |  0 |       659 |  15.41K |   23 | 0:02'28'' |
| Q30L110_500000   |  9662 | 4.49M |  816 |      9908 |   4.37M |  681 |       1900 |  24.67K | 11 |       784 |   92.9K |  124 | 0:00'39'' |
| Q30L110_1000000  | 16102 | 4.54M |  504 |     16492 |   4.46M |  441 |      12243 |  33.66K |  6 |       803 |  42.59K |   57 | 0:00'58'' |
| Q30L110_1500000  | 22667 | 4.55M |  391 |     22968 |   4.48M |  348 |      18258 |  34.29K |  5 |       754 |  31.33K |   38 | 0:01'35'' |
| Q30L110_2000000  | 26271 | 4.55M |  341 |     26271 |   4.51M |  307 |       4384 |  14.74K |  3 |       709 |  21.39K |   31 | 0:01'51'' |
| Q30L120_500000   |  6437 | 4.41M | 1122 |      6658 |   4.19M |  881 |       4197 |  53.85K | 18 |       783 | 167.76K |  223 | 0:00'46'' |
| Q30L120_1000000  | 10935 | 4.51M |  701 |     11312 |   4.41M |  604 |       4955 |  39.44K | 11 |       754 |  61.31K |   86 | 0:01'05'' |

| Name               | N50SRclean |   Sum |   # | N50Anchor |   Sum |   # | N50Anchor2 |   Sum |  # | N50Others |   Sum |   # |   RunTime |
|:-------------------|-----------:|------:|----:|----------:|------:|----:|-----------:|------:|---:|----------:|------:|----:|----------:|
| Q25L100_3000000_SR |      22529 | 5.46M | 694 |     21172 | 3.14M | 244 |      31882 | 1.23M | 68 |     24143 | 1.09M | 382 | 0:02'30'' |

| Name           |   SumFq | CovFq | AvgRead |                Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:---------------|--------:|------:|--------:|--------------------:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| Q25L100K39     | 696.15M | 150.0 |     140 |                "39" |  655.2M |   5.882% | 4.64M | 4.56M |     0.98 | 4.52M |     0 | 0:06'03'' |
| Q25L100K49     | 696.15M | 150.0 |     140 |                "49" |  655.2M |   5.882% | 4.64M | 4.56M |     0.98 | 4.53M |     0 | 0:06'08'' |
| Q25L100K59     | 696.15M | 150.0 |     140 |                "59" |  655.2M |   5.882% | 4.64M | 4.56M |     0.98 | 4.54M |     0 | 0:06'17'' |
| Q25L100K69     | 696.15M | 150.0 |     140 |                "69" |  655.2M |   5.882% | 4.64M | 4.56M |     0.98 | 4.55M |     0 | 0:06'04'' |
| Q25L100K79     | 696.15M | 150.0 |     140 |                "79" |  655.2M |   5.882% | 4.64M | 4.56M |     0.98 | 4.55M |     0 | 0:06'03'' |
| Q25L100K89     | 696.15M | 150.0 |     140 |                "89" |  655.2M |   5.882% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:06'06'' |
| Q25L100Kauto   | 696.15M | 150.0 |     140 |                "91" |  655.2M |   5.882% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:04'53'' |
| Q25L120K39     | 720.92M | 155.3 |     144 |                "39" | 676.98M |   6.096% | 4.64M | 4.56M |     0.98 | 4.52M |     0 | 0:06'58'' |
| Q25L120K49     | 720.92M | 155.3 |     144 |                "49" | 676.98M |   6.096% | 4.64M | 4.56M |     0.98 | 4.53M |     0 | 0:06'53'' |
| Q25L120K59     | 720.92M | 155.3 |     144 |                "59" | 676.98M |   6.096% | 4.64M | 4.56M |     0.98 | 4.54M |     0 | 0:07'05'' |
| Q25L120K69     | 720.92M | 155.3 |     144 |                "69" | 676.98M |   6.096% | 4.64M | 4.56M |     0.98 | 4.54M |     0 | 0:05'56'' |
| Q25L120K79     | 720.92M | 155.3 |     144 |                "79" | 676.98M |   6.096% | 4.64M | 4.56M |     0.98 | 4.55M |     0 | 0:05'46'' |
| Q25L120K89     | 720.92M | 155.3 |     144 |                "89" | 676.98M |   6.096% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:06'15'' |
| Q25L120Kauto   | 720.92M | 155.3 |     144 |                "95" | 676.98M |   6.096% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:04'44'' |
| Q25L100Kseries | 696.15M | 150.0 |     140 | "39,49,59,69,79,89" |  655.2M |   5.882% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:11'40'' |
| Q25L120Kseries | 720.92M | 155.3 |     144 | "39,49,59,69,79,89" | 676.98M |   6.096% | 4.64M | 4.56M |     0.98 | 4.55M |     0 | 0:11'48'' |

| Name           | N50SR |   Sum |   # | N50Anchor |   Sum |   # | N50Anchor2 |   Sum | # | N50Others |    Sum |  # |   RunTime |
|:---------------|------:|------:|----:|----------:|------:|----:|-----------:|------:|--:|----------:|-------:|---:|----------:|
| Q25L100K39     | 19333 | 4.52M | 399 |     19333 |  4.5M | 370 |          0 |     0 | 0 |       770 |  20.5K | 29 | 0:04'06'' |
| Q25L100K49     | 27205 | 4.53M | 308 |     27205 | 4.52M | 286 |       2108 | 2.11K | 1 |       668 | 14.07K | 21 | 0:04'14'' |
| Q25L100K59     | 27225 | 4.54M | 312 |     27225 | 4.52M | 287 |       2108 | 2.11K | 1 |       683 | 16.48K | 24 | 0:04'07'' |
| Q25L100K69     | 23932 | 4.55M | 339 |     23932 | 4.53M | 313 |       2108 | 2.11K | 1 |       828 | 17.89K | 25 | 0:04'04'' |
| Q25L100K79     | 22619 | 4.55M | 379 |     22619 | 4.53M | 347 |          0 |     0 | 0 |       809 | 22.62K | 32 | 0:04'13'' |
| Q25L100K89     | 16344 | 4.56M | 479 |     16411 | 4.53M | 434 |          0 |     0 | 0 |       714 | 31.68K | 45 | 0:04'13'' |
| Q25L120K39     | 18947 | 4.52M | 415 |     18947 |  4.5M | 386 |          0 |     0 | 0 |       754 | 20.41K | 29 | 0:03'30'' |
| Q25L120K49     | 25205 | 4.53M | 348 |     26029 | 4.51M | 320 |       2030 | 2.03K | 1 |       673 | 18.33K | 27 | 0:03'31'' |
| Q25L120K59     | 23053 | 4.54M | 365 |     23053 | 4.51M | 332 |       2030 | 2.03K | 1 |       616 | 21.33K | 32 | 0:03'28'' |
| Q25L120K69     | 18587 | 4.54M | 441 |     18875 | 4.51M | 400 |       2030 | 2.03K | 1 |       744 | 28.56K | 40 | 0:03'16'' |
| Q25L120K79     | 15747 | 4.55M | 507 |     15829 | 4.51M | 461 |          0 |     0 | 0 |       785 | 33.81K | 46 | 0:03'00'' |
| Q25L120K89     | 12495 | 4.56M | 629 |     12697 |  4.5M | 552 |          0 |     0 | 0 |       753 | 55.26K | 77 | 0:03'10'' |
| Q25L120Kauto   | 11811 | 4.56M | 706 |     11898 |  4.5M | 622 |          0 |     0 | 0 |       736 | 59.61K | 84 | 0:02'34'' |
| Q25L100Kseries | 43870 | 4.56M | 227 |     43870 | 4.54M | 205 |       1084 | 1.08K | 1 |       610 | 13.43K | 21 | 0:03'35'' |
| Q25L120Kseries | 34790 | 4.55M | 247 |     34790 | 4.54M | 226 |          0 |     0 | 0 |       631 | 13.34K | 21 | 0:03'47'' |

## With PE info and substitutions

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
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

parallel -j 3 "
    mkdir -p ${BASE_DIR}/Q25L100K{}
    cd ${BASE_DIR}/Q25L100K{}
    ln -s ../Q25L100_2500000/R1.fq.gz R1.fq.gz
    ln -s ../Q25L100_2500000/R2.fq.gz R2.fq.gz

    anchr superreads \
        R1.fq.gz R2.fq.gz \
        --nosr -p 8 \
        --kmer {} \
        -o superreads.sh
    bash superreads.sh

    rm -fr anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh . 8 false
    " ::: 39 49 59 69 79 89 auto

parallel -j 3 "
    mkdir -p ${BASE_DIR}/Q25L120K{}
    cd ${BASE_DIR}/Q25L120K{}
    ln -s ../Q25L120_2500000/R1.fq.gz R1.fq.gz
    ln -s ../Q25L120_2500000/R2.fq.gz R2.fq.gz

    anchr superreads \
        R1.fq.gz R2.fq.gz \
        --nosr -p 8 \
        --kmer {} \
        -o superreads.sh
    bash superreads.sh

    rm -fr anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh . 8 false
    " ::: 39 49 59 69 79 89 auto

parallel -j 2 "
    mkdir -p ${BASE_DIR}/{}Kseries
    cd ${BASE_DIR}/{}Kseries
    ln -s ../{}_2500000/R1.fq.gz R1.fq.gz
    ln -s ../{}_2500000/R2.fq.gz R2.fq.gz

    anchr superreads \
        R1.fq.gz R2.fq.gz \
        --nosr -p 8 \
        --kmer 39,49,59,69,79,89 \
        -o superreads.sh
    bash superreads.sh

    rm -fr anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh . 8 false
    " ::: Q25L100 Q25L120

REAL_G=4641652

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/statK1.md

parallel -k --no-run-if-empty -j 4 "
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${BASE_DIR}/Q25L100K{} ${REAL_G}
    " ::: 39 49 59 69 79 89 auto \
    >> ${BASE_DIR}/statK1.md

parallel -k --no-run-if-empty -j 4 "
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${BASE_DIR}/Q25L120K{} ${REAL_G}
    " ::: 39 49 59 69 79 89 auto \
    >> ${BASE_DIR}/statK1.md
    
parallel -k --no-run-if-empty -j 4 "
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${BASE_DIR}/{}Kseries ${REAL_G}
    " ::: Q25L100 Q25L120 \
    >> ${BASE_DIR}/statK1.md

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/statK2.md

parallel -k --no-run-if-empty -j 4 "
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/Q25L100K{}
    " ::: 39 49 59 69 79 89 \
    >> ${BASE_DIR}/statK2.md

parallel -k --no-run-if-empty -j 4 "
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/Q25L120K{}
    " ::: 39 49 59 69 79 89 auto \
    >> ${BASE_DIR}/statK2.md

parallel -k --no-run-if-empty -j 4 "
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}Kseries
    " ::: Q25L100 Q25L120 \
    >> ${BASE_DIR}/statK2.md

# merge anchors
cd ${BASE_DIR}
mkdir -p Q25L100merge
anchr contained \
    Q25L100K39/anchor/pe.anchor.fa \
    Q25L100K49/anchor/pe.anchor.fa \
    Q25L100K59/anchor/pe.anchor.fa \
    Q25L100K69/anchor/pe.anchor.fa \
    Q25L100K79/anchor/pe.anchor.fa \
    Q25L100K89/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin Q25L100merge/anchor.contained.fasta
anchr orient Q25L100merge/anchor.contained.fasta --len 1000 --idt 0.98 -o Q25L100merge/anchor.orient.fasta
anchr merge Q25L100merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin Q25L100merge/anchor.merge.fasta

cd ${BASE_DIR}
mkdir -p Q25L120merge
anchr contained \
    Q25L120K39/anchor/pe.anchor.fa \
    Q25L120K49/anchor/pe.anchor.fa \
    Q25L120K59/anchor/pe.anchor.fa \
    Q25L120K69/anchor/pe.anchor.fa \
    Q25L120K79/anchor/pe.anchor.fa \
    Q25L120K89/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin Q25L120merge/anchor.contained.fasta
anchr orient Q25L120merge/anchor.contained.fasta --len 1000 --idt 0.98 -o Q25L120merge/anchor.orient.fasta
anchr merge Q25L120merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin Q25L120merge/anchor.merge.fasta

rm -fr 9_qa_kmer
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    Q25L100K39/anchor/pe.anchor.fa \
    Q25L100K49/anchor/pe.anchor.fa \
    Q25L100K59/anchor/pe.anchor.fa \
    Q25L100K69/anchor/pe.anchor.fa \
    Q25L100K79/anchor/pe.anchor.fa \
    Q25L100K89/anchor/pe.anchor.fa \
    Q25L120K39/anchor/pe.anchor.fa \
    Q25L120K49/anchor/pe.anchor.fa \
    Q25L120K59/anchor/pe.anchor.fa \
    Q25L120K69/anchor/pe.anchor.fa \
    Q25L120K79/anchor/pe.anchor.fa \
    Q25L120K89/anchor/pe.anchor.fa \
    Q25L100Kseries/anchor/pe.anchor.fa \
    Q25L120Kseries/anchor/pe.anchor.fa \
    Q25L100merge/anchor.merge.fasta \
    Q25L120merge/anchor.merge.fasta \
    1_genome/paralogs.fas \
    --label "Q25L100K39,Q25L100K49,Q25L100K59,Q25L100K69,Q25L100K79,Q25L100K89,Q25L120K39,Q25L120K49,Q25L120K59,Q25L120K69,Q25L120K79,Q25L120K89,Q25L100Kseries,Q25L120Kseries,Q25L100merge,Q25L120merge,paralogs" \
    -o 9_qa_kmer

```

## Merge anchors from different groups of reads

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L100_1000000/anchor/pe.anchor.fa \
    Q20L100_1500000/anchor/pe.anchor.fa \
    Q20L100_2000000/anchor/pe.anchor.fa \
    Q20L110_1000000/anchor/pe.anchor.fa \
    Q20L110_1500000/anchor/pe.anchor.fa \
    Q20L110_2000000/anchor/pe.anchor.fa \
    Q20L120_1000000/anchor/pe.anchor.fa \
    Q20L120_1500000/anchor/pe.anchor.fa \
    Q20L120_2000000/anchor/pe.anchor.fa \
    Q20L130_1000000/anchor/pe.anchor.fa \
    Q20L130_1500000/anchor/pe.anchor.fa \
    Q20L130_2000000/anchor/pe.anchor.fa \
    Q20L140_1000000/anchor/pe.anchor.fa \
    Q20L140_1500000/anchor/pe.anchor.fa \
    Q20L140_2000000/anchor/pe.anchor.fa \
    Q20L150_1000000/anchor/pe.anchor.fa \
    Q20L150_1500000/anchor/pe.anchor.fa \
    Q20L150_2000000/anchor/pe.anchor.fa \
    Q25L100_1000000/anchor/pe.anchor.fa \
    Q25L100_1500000/anchor/pe.anchor.fa \
    Q25L100_2000000/anchor/pe.anchor.fa \
    Q25L100_2500000/anchor/pe.anchor.fa \
    Q25L100_3000000/anchor/pe.anchor.fa \
    Q25L100_3500000/anchor/pe.anchor.fa \
    Q25L110_1000000/anchor/pe.anchor.fa \
    Q25L110_1500000/anchor/pe.anchor.fa \
    Q25L110_2000000/anchor/pe.anchor.fa \
    Q25L110_2500000/anchor/pe.anchor.fa \
    Q25L110_3000000/anchor/pe.anchor.fa \
    Q25L110_3500000/anchor/pe.anchor.fa \
    Q25L120_1000000/anchor/pe.anchor.fa \
    Q25L120_1500000/anchor/pe.anchor.fa \
    Q25L120_2000000/anchor/pe.anchor.fa \
    Q25L120_2500000/anchor/pe.anchor.fa \
    Q25L130_1000000/anchor/pe.anchor.fa \
    Q25L130_1500000/anchor/pe.anchor.fa \
    Q25L130_2000000/anchor/pe.anchor.fa \
    Q25L140_1000000/anchor/pe.anchor.fa \
    Q25L150_1000000/anchor/pe.anchor.fa \
    Q30L100_1000000/anchor/pe.anchor.fa \
    Q30L100_1500000/anchor/pe.anchor.fa \
    Q30L100_2000000/anchor/pe.anchor.fa \
    Q30L100_2500000/anchor/pe.anchor.fa \
    Q30L110_1000000/anchor/pe.anchor.fa \
    Q30L110_1500000/anchor/pe.anchor.fa \
    Q30L110_2000000/anchor/pe.anchor.fa \
    Q30L120_1000000/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge anchor2 and others
anchr contained \
    Q20L100_1000000/anchor/pe.anchor2.fa \
    Q20L110_1000000/anchor/pe.anchor2.fa \
    Q20L120_1000000/anchor/pe.anchor2.fa \
    Q20L130_1000000/anchor/pe.anchor2.fa \
    Q20L140_1000000/anchor/pe.anchor2.fa \
    Q20L150_1000000/anchor/pe.anchor2.fa \
    Q25L100_1000000/anchor/pe.anchor2.fa \
    Q25L110_1000000/anchor/pe.anchor2.fa \
    Q25L120_1000000/anchor/pe.anchor2.fa \
    Q25L130_1000000/anchor/pe.anchor2.fa \
    Q25L140_1000000/anchor/pe.anchor2.fa \
    Q25L150_1000000/anchor/pe.anchor2.fa \
    Q30L100_1000000/anchor/pe.anchor2.fa \
    Q30L110_1000000/anchor/pe.anchor2.fa \
    Q30L120_1000000/anchor/pe.anchor2.fa \
    Q20L100_1000000/anchor/pe.others.fa \
    Q20L110_1000000/anchor/pe.others.fa \
    Q20L120_1000000/anchor/pe.others.fa \
    Q20L130_1000000/anchor/pe.others.fa \
    Q20L140_1000000/anchor/pe.others.fa \
    Q20L150_1000000/anchor/pe.others.fa \
    Q25L100_1000000/anchor/pe.others.fa \
    Q25L110_1000000/anchor/pe.others.fa \
    Q25L120_1000000/anchor/pe.others.fa \
    Q25L130_1000000/anchor/pe.others.fa \
    Q25L140_1000000/anchor/pe.others.fa \
    Q25L150_1000000/anchor/pe.others.fa \
    Q30L100_1000000/anchor/pe.others.fa \
    Q30L110_1000000/anchor/pe.others.fa \
    Q30L120_1000000/anchor/pe.others.fa \
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
    Q20L100_1000000/anchor/pe.anchor.fa \
    Q20L120_1000000/anchor/pe.anchor.fa \
    Q20L140_1000000/anchor/pe.anchor.fa \
    Q25L100_1500000/anchor/pe.anchor.fa \
    Q25L120_1500000/anchor/pe.anchor.fa \
    Q25L140_1000000/anchor/pe.anchor.fa \
    Q30L100_2500000/anchor/pe.anchor.fa \
    Q30L120_1000000/anchor/pe.anchor.fa \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "Q20L100,Q20L120,Q20L140,Q25L100,Q25L120,Q25L140,Q30L100,Q30L120,merge,others,paralogs" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
rm -fr original_*
```

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
   | faops filter -l 0 -a 2000 stdin anchorLong/contig.fasta

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
    -b 10 --len 2000 --idt 0.98 --all

CONTIG_COUNT=$(faops n50 -H -N 0 -C contigTrim/anchor.fasta)
echo ${CONTIG_COUNT}

rm -fr contigTrim/group
anchr group \
    --parallel 16 \
    --keep \
    contigTrim/anchorLong.db \
    contigTrim/anchorLong.ovlp.tsv \
    --range "1-${CONTIG_COUNT}" --len 2000 --idt 0.98 --max 20000 -c 1 --png

pushd ${BASE_DIR}/contigTrim
cat group/groups.txt \
    | parallel --no-run-if-empty -j 8 '
        echo {};
        anchr orient \
            --len 2000 --idt 0.98 \
            group/{}.anchor.fasta \
            group/{}.long.fasta \
            -r group/{}.restrict.tsv \
            -o group/{}.strand.fasta;

        anchr overlap --len 2000 --idt 0.98 --all \
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
| anchor.merge |   67396 | 4562512 | 122 |
| others.merge |    5833 |  184278 |  57 |
| anchor.cover |   63608 | 4542998 | 121 |
| anchorLong   |  112475 | 4531882 |  83 |
| contigTrim   | 4594658 | 4636003 |   2 |
