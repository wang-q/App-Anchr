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
| original_500000  |    151M |  32.5 |     151 | "39,49,59,69,79,89" |  95.16M |  36.979% | 4.64M | 4.58M |     0.99 | 5.87M |     0 | 0:05'09'' |
| original_1000000 |    302M |  65.1 |     151 | "39,49,59,69,79,89" | 192.04M |  36.411% | 4.64M | 4.68M |     1.01 | 4.52M |     0 | 0:10'08'' |
| original_1500000 |    453M |  97.6 |     151 | "39,49,59,69,79,89" | 290.09M |  35.962% | 4.64M | 4.79M |     1.03 | 4.05M |     0 | 0:13'12'' |
| original_2000000 |    604M | 130.1 |     151 | "39,49,59,69,79,89" | 389.03M |  35.591% | 4.64M | 4.94M |     1.06 | 3.58M |     0 | 0:16'51'' |
| original_2500000 |    755M | 162.7 |     151 | "39,49,59,69,79,89" | 489.12M |  35.215% | 4.64M | 5.11M |     1.10 | 3.02M |     0 | 0:21'17'' |
| original_3000000 |    906M | 195.2 |     151 | "39,49,59,69,79,89" | 589.74M |  34.907% | 4.64M |  5.3M |     1.14 | 2.51M |     0 | 0:25'13'' |
| original_3500000 |   1.06G | 227.7 |     151 | "39,49,59,69,79,89" | 691.24M |  34.604% | 4.64M | 5.51M |     1.19 | 2.14M |     0 | 0:29'14'' |
| original_4000000 |   1.21G | 260.3 |     151 | "39,49,59,69,79,89" | 793.52M |  34.311% | 4.64M | 5.74M |     1.24 | 1.78M |     0 | 0:34'09'' |
| Q20L100_500000   | 143.87M |  31.0 |     144 | "39,49,59,69,79,89" | 124.61M |  13.385% | 4.64M | 4.55M |     0.98 | 7.25M |     0 | 0:06'52'' |
| Q20L100_1000000  | 287.72M |  62.0 |     144 | "39,49,59,69,79,89" | 249.55M |  13.264% | 4.64M | 4.56M |     0.98 | 6.79M |     0 | 0:11'16'' |
| Q20L100_1500000  | 431.61M |  93.0 |     144 | "39,49,59,69,79,89" | 374.63M |  13.202% | 4.64M | 4.57M |     0.98 | 6.12M |     0 | 0:15'35'' |
| Q20L100_2000000  | 575.48M | 124.0 |     144 | "39,49,59,69,79,89" | 499.78M |  13.154% | 4.64M | 4.58M |     0.99 | 5.34M |     0 | 0:19'04'' |
| Q20L100_2500000  | 719.31M | 155.0 |     144 | "39,49,59,69,79,89" | 624.83M |  13.135% | 4.64M | 4.59M |     0.99 | 5.02M |     0 | 0:23'06'' |
| Q20L100_3000000  |  863.2M | 186.0 |     144 | "39,49,59,69,79,89" |  750.2M |  13.091% | 4.64M | 4.61M |     0.99 | 4.98M |     0 | 0:27'48'' |
| Q20L100_3500000  |   1.01G | 217.0 |     144 | "39,49,59,69,79,89" | 875.49M |  13.064% | 4.64M | 4.62M |     1.00 | 4.84M |     0 | 0:32'54'' |
| Q20L100_4000000  |   1.15G | 248.0 |     144 | "39,49,59,69,79,89" |      1G |  13.015% | 4.64M | 4.64M |     1.00 | 4.76M |     0 | 0:36'51'' |
| Q20L110_500000   | 145.36M |  31.3 |     145 | "39,49,59,69,79,89" | 126.11M |  13.244% | 4.64M | 4.55M |     0.98 | 7.19M |     0 | 0:07'17'' |
| Q20L110_1000000  | 290.68M |  62.6 |     145 | "39,49,59,69,79,89" | 252.36M |  13.183% | 4.64M | 4.56M |     0.98 | 7.28M |     0 | 0:11'24'' |
| Q20L110_1500000  | 436.05M |  93.9 |     145 | "39,49,59,69,79,89" | 378.54M |  13.190% | 4.64M | 4.56M |     0.98 | 6.42M |     0 | 0:15'57'' |
| Q20L110_2000000  | 581.39M | 125.3 |     145 | "39,49,59,69,79,89" | 505.05M |  13.130% | 4.64M | 4.58M |     0.99 | 5.59M |     0 | 0:19'09'' |
| Q20L110_2500000  | 726.79M | 156.6 |     145 | "39,49,59,69,79,89" | 631.62M |  13.094% | 4.64M | 4.59M |     0.99 | 5.27M |     0 | 0:22'29'' |
| Q20L110_3000000  | 872.11M | 187.9 |     145 | "39,49,59,69,79,89" |  758.2M |  13.061% | 4.64M |  4.6M |     0.99 | 5.04M |     0 | 0:26'35'' |
| Q20L110_3500000  |   1.02G | 219.2 |     145 | "39,49,59,69,79,89" | 885.09M |  13.010% | 4.64M | 4.62M |     1.00 | 4.88M |     0 | 0:31'14'' |
| Q20L110_4000000  |   1.16G | 250.5 |     145 | "39,49,59,69,79,89" |   1.01G |  12.961% | 4.64M | 4.64M |     1.00 | 4.77M |     0 | 0:34'01'' |
| Q20L120_500000   |    147M |  31.7 |     147 | "39,49,59,69,79,89" | 127.72M |  13.114% | 4.64M | 4.55M |     0.98 | 6.65M |     0 | 0:07'04'' |
| Q20L120_1000000  | 293.95M |  63.3 |     147 | "39,49,59,69,79,89" | 255.24M |  13.169% | 4.64M | 4.56M |     0.98 | 7.02M |     0 | 0:10'46'' |
| Q20L120_1500000  | 440.97M |  95.0 |     147 | "39,49,59,69,79,89" | 383.13M |  13.118% | 4.64M | 4.56M |     0.98 | 6.45M |     0 | 0:15'04'' |
| Q20L120_2000000  | 587.93M | 126.7 |     147 | "39,49,59,69,79,89" | 510.95M |  13.093% | 4.64M | 4.57M |     0.99 | 5.65M |     0 | 0:18'32'' |
| Q20L120_2500000  | 734.94M | 158.3 |     147 | "39,49,59,69,79,89" | 639.02M |  13.051% | 4.64M | 4.58M |     0.99 | 5.38M |     0 | 0:21'39'' |
| Q20L120_3000000  | 881.95M | 190.0 |     147 | "39,49,59,69,79,89" |  767.2M |  13.011% | 4.64M |  4.6M |     0.99 | 5.05M |     0 | 0:26'24'' |
| Q20L120_3500000  |   1.03G | 221.7 |     147 | "39,49,59,69,79,89" | 895.51M |  12.967% | 4.64M | 4.61M |     0.99 | 4.97M |     0 | 0:31'31'' |
| Q20L130_500000   | 148.95M |  32.1 |     149 | "39,49,59,69,79,89" | 129.32M |  13.176% | 4.64M | 4.53M |     0.98 | 6.16M |     0 | 0:06'56'' |
| Q20L130_1000000  |  297.9M |  64.2 |     149 | "39,49,59,69,79,89" | 258.61M |  13.188% | 4.64M | 4.55M |     0.98 | 6.48M |     0 | 0:11'34'' |
| Q20L130_1500000  | 446.85M |  96.3 |     149 | "39,49,59,69,79,89" | 388.08M |  13.152% | 4.64M | 4.56M |     0.98 | 6.32M |     0 | 0:14'30'' |
| Q20L130_2000000  |  595.8M | 128.4 |     149 | "39,49,59,69,79,89" | 517.69M |  13.111% | 4.64M | 4.57M |     0.98 | 5.95M |     0 | 0:17'55'' |
| Q20L130_2500000  | 744.74M | 160.4 |     149 | "39,49,59,69,79,89" | 647.22M |  13.094% | 4.64M | 4.58M |     0.99 | 5.46M |     0 | 0:21'59'' |
| Q20L130_3000000  | 893.69M | 192.5 |     149 | "39,49,59,69,79,89" | 777.03M |  13.054% | 4.64M | 4.59M |     0.99 | 5.28M |     0 | 0:25'42'' |
| Q20L140_500000   | 150.76M |  32.5 |     150 | "39,49,59,69,79,89" | 130.61M |  13.364% | 4.64M | 4.51M |     0.97 | 5.67M |     0 | 0:06'49'' |
| Q20L140_1000000  | 301.51M |  65.0 |     150 | "39,49,59,69,79,89" | 261.25M |  13.355% | 4.64M | 4.54M |     0.98 | 6.36M |     0 | 0:10'30'' |
| Q20L140_1500000  | 452.27M |  97.4 |     150 | "39,49,59,69,79,89" | 391.94M |  13.340% | 4.64M | 4.55M |     0.98 | 6.48M |     0 | 0:13'35'' |
| Q20L140_2000000  | 603.03M | 129.9 |     150 | "39,49,59,69,79,89" |  522.8M |  13.305% | 4.64M | 4.56M |     0.98 | 6.03M |     0 | 0:17'01'' |
| Q20L140_2500000  | 753.79M | 162.4 |     150 | "39,49,59,69,79,89" | 653.87M |  13.256% | 4.64M | 4.57M |     0.98 | 5.61M |     0 | 0:21'03'' |
| Q20L150_500000   |    151M |  32.5 |     150 | "39,49,59,69,79,89" | 130.92M |  13.297% | 4.64M |  4.5M |     0.97 | 5.65M |     0 | 0:05'58'' |
| Q20L150_1000000  |    302M |  65.1 |     150 | "39,49,59,69,79,89" | 261.88M |  13.285% | 4.64M | 4.54M |     0.98 | 6.04M |     0 | 0:09'39'' |
| Q20L150_1500000  |    453M |  97.6 |     150 | "39,49,59,69,79,89" | 392.83M |  13.283% | 4.64M | 4.55M |     0.98 | 6.15M |     0 | 0:13'30'' |
| Q20L150_2000000  |    604M | 130.1 |     150 | "39,49,59,69,79,89" | 523.92M |  13.259% | 4.64M | 4.56M |     0.98 | 5.93M |     0 | 0:17'07'' |
| Q20L150_2500000  | 740.82M | 159.6 |     150 | "39,49,59,69,79,89" | 642.87M |  13.222% | 4.64M | 4.57M |     0.98 | 5.64M |     0 | 0:19'36'' |
| Q25L100_500000   | 139.22M |  30.0 |     139 | "39,49,59,69,79,89" | 131.02M |   5.891% | 4.64M | 4.55M |     0.98 | 6.81M |     0 | 0:06'01'' |
| Q25L100_1000000  | 278.46M |  60.0 |     140 | "39,49,59,69,79,89" | 262.04M |   5.894% | 4.64M | 4.55M |     0.98 | 7.43M |     0 | 0:09'19'' |
| Q25L100_1500000  | 417.71M |  90.0 |     139 | "39,49,59,69,79,89" | 393.08M |   5.895% | 4.64M | 4.56M |     0.98 | 7.63M |     0 | 0:11'18'' |
| Q25L100_2000000  | 556.94M | 120.0 |     140 | "39,49,59,69,79,89" | 524.04M |   5.907% | 4.64M | 4.56M |     0.98 | 7.57M |     0 | 0:15'24'' |
| Q25L100_2500000  | 696.15M | 150.0 |     140 | "39,49,59,69,79,89" |  655.2M |   5.882% | 4.64M | 4.56M |     0.98 | 7.08M |     0 | 0:18'07'' |
| Q25L100_3000000  | 835.35M | 180.0 |     140 | "39,49,59,69,79,89" | 786.18M |   5.885% | 4.64M | 4.56M |     0.98 | 7.13M |     0 | 0:20'54'' |
| Q25L100_3500000  |  974.6M | 210.0 |     139 | "39,49,59,69,79,89" |  917.3M |   5.879% | 4.64M | 4.57M |     0.98 | 6.61M |     0 | 0:23'56'' |
| Q25L110_500000   | 141.56M |  30.5 |     142 | "39,49,59,69,79,89" | 133.09M |   5.986% | 4.64M | 4.54M |     0.98 | 6.52M |     0 | 0:05'19'' |
| Q25L110_1000000  | 283.13M |  61.0 |     141 | "39,49,59,69,79,89" | 266.18M |   5.989% | 4.64M | 4.55M |     0.98 | 7.31M |     0 | 0:08'53'' |
| Q25L110_1500000  | 424.69M |  91.5 |     142 | "39,49,59,69,79,89" | 399.32M |   5.974% | 4.64M | 4.56M |     0.98 | 7.84M |     0 | 0:12'10'' |
| Q25L110_2000000  | 566.27M | 122.0 |     142 | "39,49,59,69,79,89" | 532.46M |   5.972% | 4.64M | 4.56M |     0.98 | 7.27M |     0 | 0:14'40'' |
| Q25L110_2500000  | 707.82M | 152.5 |     142 | "39,49,59,69,79,89" | 665.57M |   5.969% | 4.64M | 4.56M |     0.98 | 7.28M |     0 | 0:17'29'' |
| Q25L110_3000000  |  849.4M | 183.0 |     141 | "39,49,59,69,79,89" | 798.81M |   5.956% | 4.64M | 4.56M |     0.98 | 6.94M |     0 | 0:21'00'' |
| Q25L110_3500000  | 985.16M | 212.2 |     141 | "39,49,59,69,79,89" | 926.49M |   5.955% | 4.64M | 4.57M |     0.98 | 6.69M |     0 | 0:23'42'' |
| Q25L120_500000   | 144.17M |  31.1 |     144 | "39,49,59,69,79,89" | 135.37M |   6.100% | 4.64M | 4.53M |     0.98 |  6.1M |     0 | 0:05'32'' |
| Q25L120_1000000  | 288.38M |  62.1 |     144 | "39,49,59,69,79,89" | 270.86M |   6.076% | 4.64M | 4.55M |     0.98 | 6.74M |     0 | 0:08'48'' |
| Q25L120_1500000  | 432.57M |  93.2 |     144 | "39,49,59,69,79,89" | 406.21M |   6.093% | 4.64M | 4.56M |     0.98 | 6.88M |     0 | 0:11'18'' |
| Q25L120_2000000  | 576.74M | 124.3 |     144 | "39,49,59,69,79,89" | 541.54M |   6.104% | 4.64M | 4.56M |     0.98 | 7.42M |     0 | 0:11'54'' |
| Q25L120_2500000  | 720.92M | 155.3 |     144 | "39,49,59,69,79,89" | 676.98M |   6.096% | 4.64M | 4.56M |     0.98 | 7.26M |     0 | 0:13'54'' |
| Q25L130_500000   | 147.35M |  31.7 |     147 | "39,49,59,69,79,89" | 137.95M |   6.384% | 4.64M |  4.5M |     0.97 | 5.78M |     0 | 0:04'34'' |
| Q25L130_1000000  | 294.71M |  63.5 |     147 | "39,49,59,69,79,89" | 275.86M |   6.393% | 4.64M | 4.54M |     0.98 | 6.24M |     0 | 0:06'10'' |
| Q25L130_1500000  | 442.04M |  95.2 |     147 | "39,49,59,69,79,89" | 413.83M |   6.382% | 4.64M | 4.55M |     0.98 | 6.65M |     0 | 0:08'15'' |
| Q25L130_2000000  | 589.41M | 127.0 |     147 | "39,49,59,69,79,89" | 551.77M |   6.387% | 4.64M | 4.55M |     0.98 |  6.9M |     0 | 0:10'03'' |
| Q25L140_500000   | 150.48M |  32.4 |     150 | "39,49,59,69,79,89" | 140.08M |   6.907% | 4.64M | 4.42M |     0.95 |    5M |     0 | 0:04'00'' |
| Q25L140_1000000  | 300.95M |  64.8 |     150 | "39,49,59,69,79,89" | 280.19M |   6.899% | 4.64M |  4.5M |     0.97 | 5.67M |     0 | 0:06'16'' |
| Q25L150_500000   |    151M |  32.5 |     150 | "39,49,59,69,79,89" | 140.28M |   7.097% | 4.64M | 4.38M |     0.94 | 5.01M |     0 | 0:03'51'' |
| Q25L150_1000000  |    302M |  65.1 |     150 | "39,49,59,69,79,89" |  280.8M |   7.020% | 4.64M | 4.48M |     0.97 | 5.53M |     0 | 0:06'05'' |
| Q30L100_500000   | 130.79M |  28.2 |     131 | "39,49,59,69,79,89" |  127.5M |   2.514% | 4.64M | 4.53M |     0.97 | 6.17M |     0 | 0:03'11'' |
| Q30L100_1000000  | 261.57M |  56.4 |     131 | "39,49,59,69,79,89" | 255.01M |   2.508% | 4.64M | 4.55M |     0.98 | 6.51M |     0 | 0:05'14'' |
| Q30L100_1500000  | 392.31M |  84.5 |     131 | "39,49,59,69,79,89" | 382.49M |   2.504% | 4.64M | 4.55M |     0.98 | 7.36M |     0 | 0:07'16'' |
| Q30L100_2000000  | 523.09M | 112.7 |     131 | "39,49,59,69,79,89" | 510.05M |   2.492% | 4.64M | 4.56M |     0.98 | 6.91M |     0 | 0:09'16'' |
| Q30L100_2500000  | 653.84M | 140.9 |     131 | "39,49,59,69,79,89" | 637.52M |   2.495% | 4.64M | 4.56M |     0.98 |  7.3M |     0 | 0:11'14'' |
| Q30L110_500000   | 134.74M |  29.0 |     135 | "39,49,59,69,79,89" | 131.29M |   2.561% | 4.64M |  4.5M |     0.97 | 5.61M |     0 | 0:03'43'' |
| Q30L110_1000000  |  269.5M |  58.1 |     135 | "39,49,59,69,79,89" | 262.57M |   2.571% | 4.64M | 4.54M |     0.98 | 6.36M |     0 | 0:05'37'' |
| Q30L110_1500000  | 404.26M |  87.1 |     135 | "39,49,59,69,79,89" | 393.83M |   2.581% | 4.64M | 4.55M |     0.98 | 6.74M |     0 | 0:07'38'' |
| Q30L110_2000000  |    539M | 116.1 |     134 | "39,49,59,69,79,89" | 525.11M |   2.576% | 4.64M | 4.55M |     0.98 | 6.94M |     0 | 0:09'28'' |
| Q30L120_500000   | 139.15M |  30.0 |     139 | "39,49,59,69,79,89" | 135.34M |   2.739% | 4.64M | 4.44M |     0.96 | 5.16M |     0 | 0:03'46'' |
| Q30L120_1000000  | 278.29M |  60.0 |     139 | "39,49,59,69,79,89" | 270.83M |   2.680% | 4.64M | 4.51M |     0.97 | 5.62M |     0 | 0:05'59'' |

| Name             | N50SRclean |   Sum |    # | N50Anchor |     Sum |    # | N50Anchor2 |     Sum |   # | N50Others |     Sum |    # |   RunTime |
|:-----------------|-----------:|------:|-----:|----------:|--------:|-----:|-----------:|--------:|----:|----------:|--------:|-----:|----------:|
| original_500000  |       3656 | 5.23M | 2065 |      3781 |   3.03M | 1000 |       4852 | 837.16K | 217 |      2294 |   1.36M |  848 | 0:00'43'' |
| original_1000000 |       1771 | 4.47M | 3087 |      2112 |    3.4M | 1703 |       2743 |     34K |  17 |       778 |   1.04M | 1367 | 0:00'54'' |
| original_1500000 |       1224 | 4.04M | 3637 |      1664 |    2.5M | 1510 |       4088 |  12.34K |   4 |       742 |   1.53M | 2123 | 0:01'09'' |
| original_2000000 |        991 | 3.56M | 3737 |      1488 |   1.69M | 1110 |          0 |       0 |   0 |       729 |   1.87M | 2627 | 0:01'17'' |
| original_2500000 |        875 |    3M | 3474 |      1387 |   1.14M |  787 |       2589 |   4.21K |   2 |       698 |   1.86M | 2685 | 0:01'19'' |
| original_3000000 |        816 | 2.47M | 3009 |      1349 | 805.71K |  572 |       2337 |   3.95K |   2 |       686 |   1.66M | 2435 | 0:01'30'' |
| original_3500000 |        762 | 2.09M | 2676 |      1322 | 527.42K |  385 |       2088 |  12.16K |   6 |       676 |   1.55M | 2285 | 0:01'19'' |
| original_4000000 |        732 | 1.72M | 2271 |      1289 | 360.27K |  270 |       2414 |  18.36K |   7 |       658 |   1.34M | 1994 | 0:01'20'' |
| Q20L100_500000   |      26192 | 5.76M |  379 |     26271 |   2.05M |  144 |      32362 |   2.27M |  86 |     18948 |   1.45M |  149 | 0:00'47'' |
| Q20L100_1000000  |      26951 | 5.57M |  370 |     24618 |   2.42M |  163 |      37336 |      2M |  81 |     17063 |   1.15M |  126 | 0:01'04'' |
| Q20L100_1500000  |      15271 | 5.29M |  542 |     13951 |   3.31M |  350 |      23863 |   1.21M |  64 |     12014 | 768.38K |  128 | 0:01'44'' |
| Q20L100_2000000  |       9103 | 4.94M |  815 |      8917 |   3.97M |  602 |      13044 | 443.29K |  44 |      8027 | 524.85K |  169 | 0:02'32'' |
| Q20L100_2500000  |       6251 | 4.81M | 1148 |      6307 |   4.09M |  888 |       8198 | 327.71K |  45 |      3649 | 391.95K |  215 | 0:02'57'' |
| Q20L100_3000000  |       4267 |  4.8M | 1611 |      4286 |   4.08M | 1206 |       6260 | 249.13K |  41 |      1240 | 466.02K |  364 | 0:03'18'' |
| Q20L100_3500000  |       3098 | 4.69M | 2021 |      3275 |   4.11M | 1482 |       4964 |  99.67K |  23 |       877 |  480.7K |  516 | 0:03'56'' |
| Q20L100_4000000  |       2413 | 4.66M | 2499 |      2664 |   3.91M | 1651 |       3179 |  65.12K |  18 |       822 | 692.08K |  830 | 0:03'53'' |
| Q20L110_500000   |      21571 | 5.75M |  445 |     19208 |   1.87M |  162 |      26803 |   2.54M | 119 |     16287 |   1.34M |  164 | 0:01'21'' |
| Q20L110_1000000  |      28453 | 5.57M |  344 |     26271 |   2.53M |  168 |      35249 |   1.82M |  65 |     23580 |   1.23M |  111 | 0:01'07'' |
| Q20L110_1500000  |      18084 |  5.4M |  496 |     15882 |   2.98M |  294 |      24447 |   1.43M |  78 |     16590 |  991.1K |  124 | 0:01'32'' |
| Q20L110_2000000  |      10510 | 5.08M |  770 |     10207 |   3.68M |  543 |      17477 | 752.08K |  57 |      8560 | 643.78K |  170 | 0:02'45'' |
| Q20L110_2500000  |       6876 | 4.92M | 1116 |      6576 |   3.95M |  831 |      11168 | 440.38K |  49 |      5443 | 526.64K |  236 | 0:03'12'' |
| Q20L110_3000000  |       4363 |  4.8M | 1556 |      4498 |   4.08M | 1147 |       7109 | 235.72K |  38 |      1952 |  488.7K |  371 | 0:03'40'' |
| Q20L110_3500000  |       3289 | 4.74M | 1985 |      3469 |   4.02M | 1414 |       5695 | 206.91K |  42 |       900 | 513.07K |  529 | 0:03'39'' |
| Q20L110_4000000  |       2493 | 4.67M | 2436 |      2712 |   3.93M | 1635 |       4871 |  83.15K |  21 |       832 | 656.89K |  780 | 0:04'08'' |
| Q20L120_500000   |      20220 | 5.36M |  465 |     21435 |    2.7M |  228 |      24943 |   1.68M |  94 |     12622 | 977.86K |  143 | 0:01'20'' |
| Q20L120_1000000  |      26339 | 5.56M |  388 |     22707 |    2.3M |  172 |      32266 |   2.08M |  87 |     17783 |   1.18M |  129 | 0:01'27'' |
| Q20L120_1500000  |      17849 | 5.27M |  487 |     16342 |   3.12M |  303 |      29583 |    1.4M |  68 |     13714 |  742.4K |  116 | 0:01'39'' |
| Q20L120_2000000  |      11772 | 5.13M |  727 |     11611 |   3.58M |  503 |      18228 | 855.19K |  65 |      9705 | 693.37K |  159 | 0:02'36'' |
| Q20L120_2500000  |       7235 | 4.99M | 1060 |      6737 |   3.81M |  772 |      12263 | 534.86K |  53 |      6696 | 641.72K |  235 | 0:03'11'' |
| Q20L120_3000000  |       4577 | 4.83M | 1496 |      4610 |   4.06M | 1111 |       7886 | 235.39K |  35 |      2985 | 532.47K |  350 | 0:03'27'' |
| Q20L120_3500000  |       3467 |  4.8M | 1932 |      3537 |      4M | 1367 |       6636 |  177.4K |  35 |       986 | 623.53K |  530 | 0:03'33'' |
| Q20L130_500000   |      15685 | 5.19M |  568 |     15410 |   3.13M |  326 |      18833 |   1.28M |  92 |     13125 | 777.58K |  150 | 0:01'11'' |
| Q20L130_1000000  |      22438 | 5.66M |  445 |     17657 |   2.37M |  211 |      27544 |   2.05M |  94 |     15421 |   1.25M |  140 | 0:01'03'' |
| Q20L130_1500000  |      17445 | 5.38M |  526 |     15859 |   2.95M |  291 |      21410 |   1.38M |  85 |     13303 |   1.05M |  150 | 0:01'29'' |
| Q20L130_2000000  |      11756 | 5.28M |  740 |     10451 |   3.21M |  472 |      25225 |    1.1M |  74 |     11174 | 962.44K |  194 | 0:02'25'' |
| Q20L130_2500000  |       7486 | 5.02M | 1048 |      7144 |    3.8M |  745 |      11982 | 551.74K |  59 |      5485 | 672.14K |  244 | 0:02'43'' |
| Q20L130_3000000  |       4995 | 4.92M | 1465 |      4933 |   3.91M | 1032 |       7823 | 357.29K |  51 |      3165 | 661.02K |  382 | 0:03'16'' |
| Q20L140_500000   |      10544 | 4.89M |  755 |     10544 |   3.52M |  494 |      12953 | 891.71K |  88 |      5468 | 473.64K |  173 | 0:01'01'' |
| Q20L140_1000000  |      16779 | 5.44M |  554 |     15315 |   2.69M |  289 |      23350 |   1.75M | 103 |     13052 |      1M |  162 | 0:01'15'' |
| Q20L140_1500000  |      14949 | 5.41M |  600 |     12938 |   2.69M |  331 |      22339 |   1.75M | 104 |     11286 | 969.65K |  165 | 0:01'52'' |
| Q20L140_2000000  |      11142 | 5.08M |  752 |      9678 |   3.38M |  505 |      15659 | 986.46K |  71 |      8625 | 721.86K |  176 | 0:02'07'' |
| Q20L140_2500000  |       7248 | 5.02M | 1083 |      6833 |   3.62M |  738 |      10171 | 718.14K |  84 |      4878 | 676.02K |  261 | 0:02'42'' |
| Q20L150_500000   |      10036 | 5.01M |  836 |      9527 |   3.39M |  529 |      14979 | 902.03K |  97 |      8420 | 713.21K |  210 | 0:01'05'' |
| Q20L150_1000000  |      16278 | 5.15M |  552 |     15111 |   2.99M |  331 |      22657 |    1.5M |  86 |      9792 | 662.08K |  135 | 0:01'07'' |
| Q20L150_1500000  |      14374 | 5.27M |  609 |     12612 |   3.12M |  370 |      21245 |   1.25M |  84 |     12424 | 903.56K |  155 | 0:01'40'' |
| Q20L150_2000000  |      10842 | 5.16M |  767 |      9949 |   3.32M |  483 |      13950 |   1.12M |  96 |      7735 | 722.83K |  188 | 0:01'58'' |
| Q20L150_2500000  |       7846 | 5.12M | 1016 |      7409 |   3.44M |  671 |      11088 |    922K |  98 |      6079 | 754.09K |  247 | 0:02'37'' |
| Q25L100_500000   |      22520 |  5.5M |  430 |     23062 |   2.49M |  191 |      29847 |   1.97M |  99 |     11946 |   1.04M |  140 | 0:01'04'' |
| Q25L100_1000000  |      35199 | 5.85M |  325 |     30286 |   1.81M |  115 |      44753 |   2.73M |  85 |     21520 |   1.31M |  125 | 0:01'17'' |
| Q25L100_1500000  |      39008 | 5.76M |  290 |     44655 |   2.16M |  115 |      53980 |   2.27M |  61 |     22563 |   1.34M |  114 | 0:01'52'' |
| Q25L100_2000000  |      39165 | 5.84M |  288 |     32391 |   1.99M |  109 |      56678 |   2.62M |  67 |     20546 |   1.23M |  112 | 0:02'05'' |
| Q25L100_2500000  |      33150 | 5.62M |  305 |     28410 |   2.39M |  144 |      52756 |   2.13M |  65 |     22365 |    1.1M |   96 | 0:02'45'' |
| Q25L100_3000000  |      30642 | 5.75M |  331 |     25590 |   2.55M |  163 |      36358 |   1.83M |  60 |     24990 |   1.36M |  108 | 0:03'07'' |
| Q25L100_3500000  |      24216 | 5.41M |  373 |     18978 |   2.63M |  211 |      36922 |   1.88M |  65 |     18490 | 911.54K |   97 | 0:03'27'' |
| Q25L110_500000   |      18613 | 5.37M |  496 |     16848 |   2.66M |  244 |      23801 |   1.71M |  94 |     11718 | 997.09K |  158 | 0:01'05'' |
| Q25L110_1000000  |      28730 | 5.75M |  374 |     24551 |   1.93M |  138 |      37122 |   2.43M |  90 |     17204 |   1.39M |  146 | 0:01'19'' |
| Q25L110_1500000  |      31628 |  5.9M |  340 |     34319 |   1.85M |  112 |      36183 |   2.71M | 100 |     23848 |   1.34M |  128 | 0:01'23'' |
| Q25L110_2000000  |      30823 | 5.73M |  343 |     30643 |   2.13M |  128 |      40427 |    2.4M |  84 |     17205 |    1.2M |  131 | 0:02'11'' |
| Q25L110_2500000  |      30037 | 5.54M |  338 |     28179 |   2.27M |  151 |      44763 |   2.17M |  71 |     17205 |    1.1M |  116 | 0:02'36'' |
| Q25L110_3000000  |      27265 | 5.59M |  365 |     24858 |   2.44M |  177 |      32613 |   1.93M |  68 |     19658 |   1.22M |  120 | 0:03'18'' |
| Q25L110_3500000  |      23697 | 5.38M |  406 |     19745 |   2.66M |  219 |      35205 |   1.82M |  71 |     14958 | 899.24K |  116 | 0:03'20'' |
| Q25L120_500000   |      14455 | 5.29M |  606 |     13281 |   2.97M |  355 |      21483 |   1.42M |  94 |     11402 | 900.92K |  157 | 0:01'28'' |
| Q25L120_1000000  |      22638 | 5.46M |  416 |     24606 |   2.64M |  199 |      28032 |   1.78M |  87 |     15977 |   1.04M |  130 | 0:01'37'' |
| Q25L120_1500000  |      28147 | 5.47M |  356 |     24615 |   2.22M |  164 |      36177 |   2.39M |  87 |     15770 | 859.18K |  105 | 0:01'41'' |
| Q25L120_2000000  |      28722 | 5.86M |  373 |     21729 |   1.81M |  143 |      38439 |    2.6M |  89 |     21896 |   1.45M |  141 | 0:02'11'' |
| Q25L120_2500000  |      28829 | 5.86M |  356 |     24624 |   1.92M |  140 |      36358 |   2.55M |  91 |     20769 |   1.39M |  125 | 0:02'37'' |
| Q25L130_500000   |      10262 | 5.08M |  827 |      9345 |   3.23M |  514 |      14270 |   1.11M | 103 |      7781 | 741.34K |  210 | 0:01'18'' |
| Q25L130_1000000  |      17182 | 5.21M |  531 |     16703 |   3.01M |  293 |      22636 |    1.5M |  96 |     10063 | 695.72K |  142 | 0:01'13'' |
| Q25L130_1500000  |      22552 | 5.48M |  451 |     17789 |   2.44M |  237 |      32503 |   2.08M |  93 |     20334 | 958.32K |  121 | 0:01'48'' |
| Q25L130_2000000  |      24244 | 5.63M |  435 |     18247 |   2.39M |  224 |      33644 |   2.02M |  89 |     21617 |   1.22M |  122 | 0:01'54'' |
| Q25L140_500000   |       6729 | 4.67M | 1199 |      6825 |   3.62M |  782 |       9528 | 485.33K |  82 |      3505 | 560.33K |  335 | 0:01'01'' |
| Q25L140_1000000  |      10925 | 5.04M |  802 |     10095 |   3.34M |  504 |      15670 | 955.72K |  87 |      9731 | 744.15K |  211 | 0:01'14'' |
| Q25L150_500000   |       5859 | 4.66M | 1273 |      5578 |   3.56M |  855 |       9614 | 491.91K |  80 |      4252 |  607.1K |  338 | 0:00'54'' |
| Q25L150_1000000  |       9888 |  4.9M |  855 |      9445 |   3.56M |  580 |      15381 | 805.75K |  75 |      7936 | 538.55K |  200 | 0:01'18'' |
| Q30L100_500000   |      11798 | 5.24M |  752 |     10838 |   3.02M |  434 |      17780 |   1.42M | 112 |      8734 | 798.04K |  206 | 0:01'05'' |
| Q30L100_1000000  |      17749 | 5.38M |  537 |     15739 |   2.38M |  255 |      22846 |    2.1M | 125 |      9898 | 900.62K |  157 | 0:01'10'' |
| Q30L100_1500000  |      23060 | 5.74M |  446 |     21392 |   2.24M |  189 |      31052 |   2.21M | 102 |     16468 |   1.28M |  155 | 0:01'40'' |
| Q30L100_2000000  |      25461 |  5.6M |  398 |     27865 |   2.14M |  155 |      27624 |   2.27M | 108 |     16111 |   1.19M |  135 | 0:02'14'' |
| Q30L100_2500000  |      27956 | 5.79M |  376 |     25792 |   1.78M |  135 |      36017 |   2.68M | 107 |     16983 |   1.33M |  134 | 0:02'45'' |
| Q30L110_500000   |       8936 | 4.93M |  933 |      8756 |   3.41M |  580 |      11815 | 904.87K | 100 |      5055 | 610.65K |  253 | 0:01'13'' |
| Q30L110_1000000  |      14401 | 5.39M |  640 |     13378 |   2.58M |  322 |      17123 |   1.89M | 135 |     11103 | 919.17K |  183 | 0:01'44'' |
| Q30L110_1500000  |      18245 | 5.54M |  514 |     18245 |   2.54M |  250 |      22971 |      2M | 112 |     12977 |      1M |  152 | 0:01'43'' |
| Q30L110_2000000  |      21696 | 5.54M |  465 |     24591 |    2.4M |  211 |      23900 |   2.18M | 115 |     13208 |    953K |  139 | 0:02'19'' |
| Q30L120_500000   |       6268 | 4.73M | 1222 |      6320 |   3.61M |  800 |       8668 | 516.16K |  78 |      3211 | 606.83K |  344 | 0:01'00'' |
| Q30L120_1000000  |      10333 | 4.95M |  803 |     10147 |   3.37M |  511 |      14477 |   1.03M |  99 |      5513 |  553.3K |  193 | 0:01'15'' |

| Name             | N50SRclean |    Sum |      # | N50Anchor |     Sum |    # | N50Anchor2 |    Sum |  # | N50Others |     Sum |      # |   RunTime |
|:-----------------|-----------:|-------:|-------:|----------:|--------:|-----:|-----------:|-------:|---:|----------:|--------:|-------:|----------:|
| original_500000  |       2762 |  5.06M |   6690 |      3551 |      4M | 1371 |       1332 |  84.1K | 61 |       420 | 977.68K |   5258 | 0:01'29'' |
| original_1000000 |       1161 |  5.99M |  18009 |      2022 |   3.24M | 1677 |       1210 | 25.49K | 21 |       327 |   2.72M |  16311 | 0:01'52'' |
| original_1500000 |        565 |  7.27M |  34044 |      1663 |   2.36M | 1430 |          0 |      0 |  0 |       213 |   4.91M |  32614 | 0:02'29'' |
| original_2000000 |        269 |  8.95M |  54953 |      1490 |   1.58M | 1042 |          0 |      0 |  0 |       125 |   7.36M |  53911 | 0:03'02'' |
| original_2500000 |        115 | 11.18M |  82982 |      1387 |   1.06M |  732 |          0 |      0 |  0 |        98 |  10.13M |  82250 | 0:03'17'' |
| original_3000000 |         92 | 14.26M | 121747 |      1338 | 730.33K |  521 |          0 |      0 |  0 |        90 |  13.53M | 121226 | 0:03'33'' |
| original_3500000 |         86 | 18.69M | 178129 |      1338 | 438.69K |  323 |          0 |      0 |  0 |        85 |  18.25M | 177806 | 0:03'52'' |
| original_4000000 |         82 | 24.98M | 259047 |      1264 | 293.79K |  223 |          0 |      0 |  0 |        82 |  24.69M | 258824 | 0:04'34'' |
| Q20L100_500000   |      15187 |  4.64M |   1214 |     15904 |   4.51M |  449 |          0 |      0 |  0 |       181 | 131.82K |    765 | 0:05'45'' |
| Q20L100_1000000  |      11799 |  4.69M |   1351 |     12060 |   4.52M |  562 |          0 |      0 |  0 |       223 | 167.71K |    789 | 0:05'57'' |
| Q20L100_1500000  |      10673 |  4.75M |   1807 |     11023 |   4.52M |  627 |          0 |      0 |  0 |       193 | 225.65K |   1180 | 0:06'25'' |
| Q20L100_2000000  |       7986 |  4.78M |   2669 |      8402 |   4.49M |  739 |          0 |      0 |  0 |       137 | 291.26K |   1930 | 0:03'16'' |
| Q20L100_2500000  |       5168 |  4.96M |   3638 |      5793 |   4.48M | 1035 |          0 |      0 |  0 |       165 | 472.59K |   2603 | 0:03'41'' |
| Q20L100_3000000  |       3660 |     5M |   5403 |      4212 |   4.32M | 1302 |          0 |      0 |  0 |       179 | 679.84K |   4101 | 0:04'02'' |
| Q20L100_3500000  |       2620 |  5.14M |   7161 |      3186 |   4.16M | 1538 |          0 |      0 |  0 |       270 | 978.26K |   5623 | 0:04'04'' |
| Q20L100_4000000  |       1953 |   5.3M |   9165 |      2620 |    3.9M | 1675 |       1200 |  2.37K |  2 |       362 |    1.4M |   7488 | 0:04'43'' |
| Q20L110_500000   |       3090 |  4.84M |   3654 |      3762 |   4.04M | 1337 |          0 |      0 |  0 |       530 | 802.12K |   2317 | 0:01'34'' |
| Q20L110_1000000  |       9654 |   4.7M |   1481 |     10135 |   4.49M |  659 |          0 |      0 |  0 |       286 | 207.75K |    822 | 0:02'05'' |
| Q20L110_1500000  |       9004 |  4.75M |   1812 |      9663 |   4.51M |  699 |          0 |      0 |  0 |       225 | 237.65K |   1113 | 0:02'43'' |
| Q20L110_2000000  |       7044 |  4.84M |   2521 |      7549 |   4.51M |  836 |          0 |      0 |  0 |       203 | 332.54K |   1685 | 0:03'14'' |
| Q20L110_2500000  |       5102 |  4.95M |   3547 |      5674 |   4.47M | 1028 |          0 |      0 |  0 |       191 |  484.7K |   2519 | 0:03'45'' |
| Q20L110_3000000  |       3678 |  5.11M |   4948 |      4235 |   4.38M | 1285 |          0 |      0 |  0 |       201 |  731.5K |   3663 | 0:03'58'' |
| Q20L110_3500000  |       2709 |  5.29M |   6555 |      3384 |   4.25M | 1524 |          0 |      0 |  0 |       235 |   1.04M |   5031 | 0:04'02'' |
| Q20L110_4000000  |       1976 |  5.51M |   8538 |      2663 |   4.06M | 1719 |          0 |      0 |  0 |       287 |   1.45M |   6819 | 0:04'39'' |
| Q20L120_500000   |       3145 |  4.81M |   3542 |      3739 |   4.07M | 1369 |       1160 |  1.16K |  1 |       525 | 744.06K |   2172 | 0:01'27'' |
| Q20L120_1000000  |       8363 |  4.71M |   1712 |      8941 |   4.45M |  763 |          0 |      0 |  0 |       355 |  261.1K |    949 | 0:01'59'' |
| Q20L120_1500000  |       8499 |  4.74M |   1825 |      8955 |    4.5M |  729 |       1089 |  1.09K |  1 |       228 | 242.12K |   1095 | 0:02'49'' |
| Q20L120_2000000  |       7232 |  4.82M |   2451 |      7771 |    4.5M |  825 |          0 |      0 |  0 |       209 | 328.58K |   1626 | 0:03'21'' |
| Q20L120_2500000  |       5248 |  4.94M |   3431 |      5742 |   4.46M | 1032 |          0 |      0 |  0 |       204 | 478.28K |   2399 | 0:03'26'' |
| Q20L120_3000000  |       3782 |   5.1M |   4785 |      4325 |   4.38M | 1280 |          0 |      0 |  0 |       209 | 718.65K |   3505 | 0:03'50'' |
| Q20L120_3500000  |       2763 |  5.29M |   6419 |      3471 |   4.26M | 1500 |          0 |      0 |  0 |       230 |   1.03M |   4919 | 0:04'20'' |
| Q20L130_500000   |       2951 |  4.79M |   3733 |      3598 |   3.95M | 1357 |       1256 |  1.26K |  1 |       554 | 840.52K |   2375 | 0:01'33'' |
| Q20L130_1000000  |       6914 |  4.71M |   1874 |      7431 |   4.42M |  873 |          0 |      0 |  0 |       422 | 291.46K |   1001 | 0:02'12'' |
| Q20L130_1500000  |       7427 |  4.74M |   1954 |      7802 |   4.46M |  802 |          0 |      0 |  0 |       296 |  288.5K |   1152 | 0:02'44'' |
| Q20L130_2000000  |       6660 |  4.82M |   2485 |      7213 |   4.47M |  887 |          0 |      0 |  0 |       230 | 344.18K |   1598 | 0:03'27'' |
| Q20L130_2500000  |       4979 |  4.92M |   3391 |      5427 |   4.44M | 1070 |          0 |      0 |  0 |       217 |  481.3K |   2321 | 0:03'36'' |
| Q20L130_3000000  |       3832 |  5.07M |   4657 |      4443 |   4.36M | 1295 |          0 |      0 |  0 |       239 | 709.13K |   3362 | 0:04'00'' |
| Q20L140_500000   |       2524 |  4.77M |   4116 |      3237 |   3.79M | 1396 |       1230 |  4.76K |  4 |       553 | 976.94K |   2716 | 0:01'37'' |
| Q20L140_1000000  |       5480 |  4.71M |   2224 |      6024 |    4.3M |  981 |       1205 |  1.21K |  1 |       516 | 403.18K |   1242 | 0:02'23'' |
| Q20L140_1500000  |       6195 |  4.74M |   2201 |      6637 |    4.4M |  933 |       1068 |  1.07K |  1 |       383 | 338.97K |   1267 | 0:02'48'' |
| Q20L140_2000000  |       5794 |  4.81M |   2631 |      6247 |   4.41M |  989 |          0 |      0 |  0 |       298 | 392.04K |   1642 | 0:03'19'' |
| Q20L140_2500000  |       4554 |  4.92M |   3539 |      5025 |   4.39M | 1139 |          0 |      0 |  0 |       271 | 530.82K |   2400 | 0:03'34'' |
| Q20L150_500000   |       2348 |  4.76M |   4309 |      3119 |   3.71M | 1393 |       1170 |  6.31K |  5 |       553 |   1.05M |   2911 | 0:01'35'' |
| Q20L150_1000000  |       5217 |  4.71M |   2349 |      5842 |   4.27M | 1022 |          0 |      0 |  0 |       490 | 431.98K |   1327 | 0:02'12'' |
| Q20L150_1500000  |       5982 |  4.73M |   2196 |      6527 |   4.38M |  941 |          0 |      0 |  0 |       447 | 354.31K |   1255 | 0:02'51'' |
| Q20L150_2000000  |       5429 |   4.8M |   2682 |      5955 |    4.4M |  994 |       1196 |   1.2K |  1 |       307 | 404.88K |   1687 | 0:03'19'' |
| Q20L150_2500000  |       4698 |  4.89M |   3339 |      5248 |   4.37M | 1104 |          0 |      0 |  0 |       296 |  514.6K |   2235 | 0:03'37'' |
| Q25L100_500000   |       5392 |   4.7M |   2203 |      5915 |   4.32M | 1025 |       1193 |  2.36K |  2 |       482 | 372.31K |   1176 | 0:01'32'' |
| Q25L100_1000000  |      10184 |  4.66M |   1298 |     10555 |   4.49M |  624 |          0 |      0 |  0 |       298 | 169.77K |    674 | 0:02'23'' |
| Q25L100_1500000  |      12503 |  4.66M |   1158 |     13397 |   4.52M |  528 |          0 |      0 |  0 |       263 | 145.72K |    630 | 0:03'01'' |
| Q25L100_2000000  |      15570 |  4.66M |   1093 |     16045 |   4.52M |  443 |          0 |      0 |  0 |       231 | 139.59K |    650 | 0:03'45'' |
| Q25L100_2500000  |      15907 |  4.67M |   1156 |     16260 |   4.53M |  450 |          0 |      0 |  0 |       218 |    144K |    706 | 0:04'01'' |
| Q25L100_3000000  |      17660 |  4.68M |   1173 |     18372 |   4.53M |  420 |          0 |      0 |  0 |       193 |    145K |    753 | 0:04'23'' |
| Q25L100_3500000  |      14400 |  4.69M |   1321 |     15601 |   4.54M |  465 |          0 |      0 |  0 |       177 | 154.79K |    856 | 0:04'46'' |
| Q25L110_500000   |       4235 |  4.72M |   2713 |      5005 |   4.19M | 1128 |       1116 |  1.12K |  1 |       518 | 527.88K |   1584 | 0:01'32'' |
| Q25L110_1000000  |       8302 |  4.67M |   1512 |      8577 |   4.46M |  753 |          0 |      0 |  0 |       403 |    213K |    759 | 0:02'08'' |
| Q25L110_1500000  |      10853 |  4.67M |   1277 |     11669 |    4.5M |  614 |          0 |      0 |  0 |       283 | 164.83K |    663 | 0:03'04'' |
| Q25L110_2000000  |      11924 |  4.67M |   1246 |     12150 |   4.51M |  563 |          0 |      0 |  0 |       257 | 160.36K |    683 | 0:03'38'' |
| Q25L110_2500000  |      12510 |  4.68M |   1259 |     13314 |   4.52M |  513 |          0 |      0 |  0 |       238 | 161.99K |    746 | 0:03'58'' |
| Q25L110_3000000  |      13221 |  4.69M |   1326 |     13870 |   4.52M |  518 |          0 |      0 |  0 |       218 | 166.42K |    808 | 0:04'28'' |
| Q25L110_3500000  |      12429 |   4.7M |   1430 |     13176 |   4.53M |  528 |          0 |      0 |  0 |       195 | 175.35K |    902 | 0:04'38'' |
| Q25L120_500000   |       3703 |  4.72M |   3081 |      4357 |   4.07M | 1237 |       1176 |  4.64K |  4 |       541 | 650.67K |   1840 | 0:01'37'' |
| Q25L120_1000000  |       7072 |  4.67M |   1720 |      7582 |   4.41M |  860 |          0 |      0 |  0 |       480 |  262.3K |    860 | 0:02'18'' |
| Q25L120_1500000  |       8744 |  4.68M |   1527 |      9117 |   4.46M |  746 |          0 |      0 |  0 |       394 | 217.13K |    781 | 0:02'56'' |
| Q25L120_2000000  |      10137 |  4.68M |   1402 |     10695 |   4.49M |  648 |          0 |      0 |  0 |       296 | 191.72K |    754 | 0:03'30'' |
| Q25L120_2500000  |      11333 |  4.68M |   1368 |     11898 |    4.5M |  622 |          0 |      0 |  0 |       261 | 176.83K |    746 | 0:03'59'' |
| Q25L130_500000   |       2032 |  4.83M |   5260 |      2872 |   3.47M | 1386 |       1303 |  6.35K |  5 |       531 |   1.35M |   3869 | 0:01'43'' |
| Q25L130_1000000  |       4038 |  4.73M |   2771 |      4571 |   4.19M | 1191 |          0 |      0 |  0 |       534 | 536.58K |   1580 | 0:02'05'' |
| Q25L130_1500000  |       5706 |  4.71M |   2173 |      6187 |   4.34M |  997 |          0 |      0 |  0 |       487 | 374.38K |   1176 | 0:02'49'' |
| Q25L130_2000000  |       6852 |   4.7M |   1909 |      7267 |    4.4M |  884 |          0 |      0 |  0 |       467 | 306.31K |   1025 | 0:03'36'' |
| Q25L140_500000   |       1721 |  4.75M |   5928 |      2574 |    3.2M | 1371 |       1256 |  7.41K |  6 |       500 |   1.54M |   4551 | 0:01'45'' |
| Q25L140_1000000  |       3110 |  4.72M |   3509 |      3914 |   3.92M | 1265 |       1088 |  2.17K |  2 |       553 | 798.84K |   2242 | 0:01'51'' |
| Q25L150_500000   |       1561 |  4.71M |   6207 |      2489 |   3.04M | 1342 |       1157 | 13.11K | 11 |       504 |   1.66M |   4854 | 0:01'40'' |
| Q25L150_1000000  |       2743 |  4.71M |   3775 |      3542 |   3.85M | 1325 |       1449 |  1.45K |  1 |       546 | 863.91K |   2449 | 0:02'03'' |
| Q30L100_500000   |       3136 |  4.71M |   3495 |      3721 |   3.98M | 1320 |       1211 |  2.31K |  2 |       541 | 724.42K |   2173 | 0:01'45'' |
| Q30L100_1000000  |       5989 |  4.67M |   2022 |      6493 |   4.36M |  947 |          0 |      0 |  0 |       481 | 310.96K |   1075 | 0:02'11'' |
| Q30L100_1500000  |       7952 |  4.67M |   1657 |      8471 |   4.43M |  765 |          0 |      0 |  0 |       400 | 236.22K |    892 | 0:03'02'' |
| Q30L100_2000000  |       9584 |  4.66M |   1477 |     10161 |   4.46M |  674 |          0 |      0 |  0 |       338 | 202.45K |    803 | 0:03'33'' |
| Q30L100_2500000  |      10873 |  4.66M |   1389 |     11515 |   4.48M |  623 |          0 |      0 |  0 |       313 | 186.13K |    766 | 0:04'01'' |
| Q30L110_500000   |       2245 |  4.74M |   4611 |      3101 |   3.63M | 1378 |       1082 |  2.16K |  2 |       541 |   1.11M |   3231 | 0:01'44'' |
| Q30L110_1000000  |       4465 |  4.69M |   2652 |      5055 |   4.18M | 1112 |          0 |      0 |  0 |       537 | 510.59K |   1540 | 0:02'24'' |
| Q30L110_1500000  |       5541 |  4.69M |   2163 |      5979 |   4.33M |  982 |          0 |      0 |  0 |       494 |  361.7K |   1181 | 0:03'14'' |
| Q30L110_2000000  |       6661 |  4.68M |   1895 |      7239 |   4.38M |  876 |          0 |      0 |  0 |       437 | 297.22K |   1019 | 0:03'36'' |
| Q30L120_500000   |       1769 |  4.73M |   5780 |      2624 |   3.26M | 1385 |       1125 |  2.22K |  2 |       505 |   1.47M |   4393 | 0:01'45'' |
| Q30L120_1000000  |       3243 |   4.7M |   3381 |      3912 |   3.98M | 1283 |          0 |      0 |  0 |       541 | 724.08K |   2098 | 0:02'15'' |

| Name               | N50SRclean |   Sum |   # | N50Anchor |   Sum |   # | N50Anchor2 |   Sum |  # | N50Others |   Sum |   # |   RunTime |
|:-------------------|-----------:|------:|----:|----------:|------:|----:|-----------:|------:|---:|----------:|------:|----:|----------:|
| Q25L100_3000000_SR |      22529 | 5.46M | 694 |     21172 | 3.14M | 244 |      31882 | 1.23M | 68 |     24143 | 1.09M | 382 | 0:02'30'' |

| Name           |   SumFq | CovFq | AvgRead |                Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:---------------|--------:|------:|--------:|--------------------:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| Q25L100K39     | 835.35M | 180.0 |     140 |                "39" | 786.18M |   5.885% | 4.64M | 4.56M |     0.98 | 4.52M |     0 | 0:14'21'' |
| Q25L100K49     | 835.35M | 180.0 |     140 |                "49" | 786.18M |   5.885% | 4.64M | 4.56M |     0.98 | 4.53M |     0 | 0:14'10'' |
| Q25L100K59     | 835.35M | 180.0 |     140 |                "59" | 786.18M |   5.885% | 4.64M | 4.56M |     0.98 | 4.54M |     0 | 0:14'10'' |
| Q25L100K69     | 835.35M | 180.0 |     140 |                "69" | 786.18M |   5.885% | 4.64M | 4.56M |     0.98 | 4.55M |     0 | 0:13'16'' |
| Q25L100K79     | 835.35M | 180.0 |     140 |                "79" | 786.18M |   5.885% | 4.64M | 4.56M |     0.98 | 4.55M |     0 | 0:13'30'' |
| Q25L100K89     | 835.35M | 180.0 |     140 |                "89" | 786.18M |   5.885% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:13'33'' |
| Q25L100Kauto   | 835.35M | 180.0 |     140 |                "89" | 786.18M |   5.885% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:05'56'' |
| Q25L120K39     | 720.92M | 155.3 |     144 |                "39" | 676.98M |   6.096% | 4.64M | 4.56M |     0.98 | 4.52M |     0 | 0:12'34'' |
| Q25L120K49     | 720.92M | 155.3 |     144 |                "49" | 676.98M |   6.096% | 4.64M | 4.56M |     0.98 | 4.53M |     0 | 0:11'47'' |
| Q25L120K59     | 720.92M | 155.3 |     144 |                "59" | 676.98M |   6.096% | 4.64M | 4.56M |     0.98 | 4.54M |     0 | 0:12'12'' |
| Q25L120K69     | 720.92M | 155.3 |     144 |                "69" | 676.98M |   6.096% | 4.64M | 4.56M |     0.98 | 4.54M |     0 | 0:11'31'' |
| Q25L120K79     | 720.92M | 155.3 |     144 |                "79" | 676.98M |   6.096% | 4.64M | 4.56M |     0.98 | 4.55M |     0 | 0:11'36'' |
| Q25L120K89     | 720.92M | 155.3 |     144 |                "89" | 676.98M |   6.096% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:11'20'' |
| Q25L120Kauto   | 720.92M | 155.3 |     144 |                "95" | 676.98M |   6.096% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:07'26'' |
| Q25L100Kseries | 696.15M | 150.0 |     140 | "39,49,59,69,79,89" |  655.2M |   5.882% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:16'56'' |
| Q25L120Kseries | 720.92M | 155.3 |     144 | "39,49,59,69,79,89" | 676.98M |   6.096% | 4.64M | 4.56M |     0.98 | 4.55M |     0 | 0:17'16'' |

| Name           | N50SR |   Sum |   # | N50Anchor |   Sum |   # | N50Anchor2 |   Sum | # | N50Others |    Sum |  # |   RunTime |
|:---------------|------:|------:|----:|----------:|------:|----:|-----------:|------:|--:|----------:|-------:|---:|----------:|
| Q25L100K39     | 18102 | 4.52M | 415 |     18213 |  4.5M | 381 |          0 |     0 | 0 |       770 | 24.67K | 34 | 0:04'31'' |
| Q25L100K49     | 25621 | 4.53M | 316 |     25621 | 4.52M | 293 |          0 |     0 | 0 |       704 | 15.68K | 23 | 0:04'23'' |
| Q25L100K59     | 24826 | 4.54M | 335 |     24981 | 4.52M | 307 |          0 |     0 | 0 |       705 |  19.2K | 28 | 0:04'09'' |
| Q25L100K69     | 23662 | 4.55M | 349 |     23662 | 4.53M | 322 |          0 |     0 | 0 |       757 | 19.19K | 27 | 0:04'05'' |
| Q25L100K79     | 20478 | 4.55M | 403 |     20575 | 4.53M | 373 |       1210 | 1.21K | 1 |       757 | 20.51K | 29 | 0:04'16'' |
| Q25L100K89     | 18274 | 4.56M | 467 |     18372 | 4.53M | 420 |          0 |     0 | 0 |       706 | 32.68K | 47 | 0:04'17'' |
| Q25L120K39     | 18947 | 4.52M | 415 |     18947 |  4.5M | 386 |          0 |     0 | 0 |       754 | 20.41K | 29 | 0:03'26'' |
| Q25L120K49     | 25205 | 4.53M | 348 |     26029 | 4.51M | 320 |       2030 | 2.03K | 1 |       673 | 18.33K | 27 | 0:03'11'' |
| Q25L120K59     | 23053 | 4.54M | 365 |     23053 | 4.51M | 332 |       2030 | 2.03K | 1 |       616 | 21.33K | 32 | 0:03'32'' |
| Q25L120K69     | 18587 | 4.54M | 441 |     18875 | 4.51M | 400 |       2030 | 2.03K | 1 |       744 | 28.56K | 40 | 0:03'16'' |
| Q25L120K79     | 15747 | 4.55M | 507 |     15829 | 4.51M | 461 |          0 |     0 | 0 |       785 | 33.81K | 46 | 0:03'42'' |
| Q25L120K89     | 12495 | 4.56M | 629 |     12697 |  4.5M | 552 |          0 |     0 | 0 |       753 | 55.26K | 77 | 0:03'47'' |
| Q25L120Kauto   | 11811 | 4.56M | 706 |     11898 |  4.5M | 622 |          0 |     0 | 0 |       736 | 59.61K | 84 | 0:03'00'' |
| Q25L100Kseries | 43870 | 4.56M | 227 |     43870 | 4.54M | 205 |       1084 | 1.08K | 1 |       610 | 13.43K | 21 | 0:03'19'' |
| Q25L120Kseries | 34790 | 4.55M | 247 |     34790 | 4.54M | 226 |          0 |     0 | 0 |       631 | 13.34K | 21 | 0:03'22'' |

## With PE info and substitutions

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

mkdir -p Q25L100_3000000_SR
cd ${BASE_DIR}/Q25L100_3000000_SR
ln -s ../Q25L100_3000000/R1.fq.gz R1.fq.gz
ln -s ../Q25L100_3000000/R2.fq.gz R2.fq.gz

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
    Q25L100_2500000/anchor/pe.anchor.fa \
    Q25L100_3000000/anchor/pe.anchor.fa \
    Q25L100_3500000/anchor/pe.anchor.fa \
    Q25L110_2500000/anchor/pe.anchor.fa \
    Q25L110_3000000/anchor/pe.anchor.fa \
    Q25L110_3500000/anchor/pe.anchor.fa \
    Q25L120_1500000/anchor/pe.anchor.fa \
    Q25L120_2000000/anchor/pe.anchor.fa \
    Q25L120_2500000/anchor/pe.anchor.fa \
    Q25L130_1500000/anchor/pe.anchor.fa \
    Q25L130_2000000/anchor/pe.anchor.fa \
    Q25L140_1000000/anchor/pe.anchor.fa \
    Q25L150_1000000/anchor/pe.anchor.fa \
    Q30L100_1500000/anchor/pe.anchor.fa \
    Q30L100_2000000/anchor/pe.anchor.fa \
    Q30L100_2500000/anchor/pe.anchor.fa \
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
    Q20L120_1500000/anchor/pe.anchor2.fa \
    Q20L130_1500000/anchor/pe.anchor2.fa \
    Q20L140_1500000/anchor/pe.anchor2.fa \
    Q20L150_1500000/anchor/pe.anchor2.fa \
    Q25L100_2500000/anchor/pe.anchor2.fa \
    Q25L110_2500000/anchor/pe.anchor2.fa \
    Q25L120_2500000/anchor/pe.anchor2.fa \
    Q25L130_2000000/anchor/pe.anchor2.fa \
    Q25L140_1000000/anchor/pe.anchor2.fa \
    Q25L150_1000000/anchor/pe.anchor2.fa \
    Q30L100_2500000/anchor/pe.anchor2.fa \
    Q30L110_2000000/anchor/pe.anchor2.fa \
    Q30L120_1000000/anchor/pe.anchor2.fa \
    Q20L100_1000000/anchor/pe.others.fa \
    Q20L110_1000000/anchor/pe.others.fa \
    Q20L120_1500000/anchor/pe.others.fa \
    Q20L130_1500000/anchor/pe.others.fa \
    Q20L140_1500000/anchor/pe.others.fa \
    Q20L150_1500000/anchor/pe.others.fa \
    Q25L100_2500000/anchor/pe.others.fa \
    Q25L110_2500000/anchor/pe.others.fa \
    Q25L120_2500000/anchor/pe.others.fa \
    Q25L130_2000000/anchor/pe.others.fa \
    Q25L140_1000000/anchor/pe.others.fa \
    Q25L150_1000000/anchor/pe.others.fa \
    Q30L100_2500000/anchor/pe.others.fa \
    Q30L110_2000000/anchor/pe.others.fa \
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
quast --no-check --threads 24 \
    -R 1_genome/genome.fa \
    Q20L100_1000000/anchor/pe.anchor.fa \
    Q20L120_1500000/anchor/pe.anchor.fa \
    Q20L140_1500000/anchor/pe.anchor.fa \
    Q25L100_2500000/anchor/pe.anchor.fa \
    Q25L120_2500000/anchor/pe.anchor.fa \
    Q25L140_1000000/anchor/pe.anchor.fa \
    Q30L100_2500000/anchor/pe.anchor.fa \
    Q30L120_1000000/anchor/pe.anchor.fa \
    Q25L100_3000000_SR/anchor/pe.anchor.fa \
    Q25L100_3000000_SR/anchor/pe.anchor2.fa \
    Q25L100_3000000_SR/anchor/pe.others.fa \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "Q20L100,Q20L120,Q20L140,Q25L100,Q25L120,Q25L140,Q30L100,Q30L120,SRAnchor,SRAnchor2,SROthers,merge,others,paralogs" \
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
| anchor.merge |   37408 | 4566302 | 202 |
| others.merge |    1007 |   69487 |  68 |
| anchor.cover |   37408 | 4558888 | 197 |
| anchorLong   |  105757 | 4533625 |  83 |
| contigTrim   | 4654077 | 4654077 |   1 |
