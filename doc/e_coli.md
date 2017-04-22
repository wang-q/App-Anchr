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

* Data of P4C2 and older are not supported in the current version of PacBio softwares
  (SMRTAnalysis). So install SMRTAnalysis_2.3.0.

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

* Genome: INSDC [U00096.3](https://www.ncbi.nlm.nih.gov/nuccore/U00096.3)
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

    [Here](https://github.com/PacificBiosciences/DevNet/wiki/E.-coli-Bacterial-Assembly) PacBio
    provides a 7 GB file for *E. coli* (20 kb library), which is gathered with RS II and the P6C4
    reagent.

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

    for count in $(perl -e 'print 500000 * $_, q{ } for 1 .. 8');
    do
        if [[ "$count" -gt "$GROUP_MAX" ]]; then
            continue;
        fi
        
        echo "==> Group ${GROUP_ID}_${count}"
        DIR_COUNT="${BASE_DIR}/${GROUP_ID}_${count}"
        mkdir -p ${DIR_COUNT}
        
        if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
            continue;
        fi
        
        seqtk sample -s${count} \
            ${BASE_DIR}/${GROUP_DIR}/R1.fq.gz ${count} \
            | pigz > ${DIR_COUNT}/R1.fq.gz
        seqtk sample -s${count} \
            ${BASE_DIR}/${GROUP_DIR}/R2.fq.gz ${count} \
            | pigz > ${DIR_COUNT}/R2.fq.gz
    done
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
            --nosr -s 300 -d 30 -p 8 \
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

| Name             |   SumFq | CovFq | AvgRead | Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real |  SumKU | SumSR |   RunTime |
|:-----------------|--------:|------:|--------:|-----:|--------:|---------:|------:|------:|---------:|-------:|------:|----------:|
| original_500000  |    151M |  32.5 |     151 |   75 |  95.16M |  36.979% | 4.64M | 4.58M |     0.99 |  5.06M |     0 | 0:01'56'' |
| original_1000000 |    302M |  65.1 |     151 |   75 | 192.04M |  36.411% | 4.64M | 4.68M |     1.01 |  5.99M |     0 | 0:03'25'' |
| original_1500000 |    453M |  97.6 |     151 |   75 | 290.09M |  35.962% | 4.64M | 4.79M |     1.03 |  7.27M |     0 | 0:04'48'' |
| original_2000000 |    604M | 130.1 |     151 |   75 | 389.03M |  35.591% | 4.64M | 4.94M |     1.06 |  8.95M |     0 | 0:06'44'' |
| original_2500000 |    755M | 162.7 |     151 |   75 | 489.12M |  35.215% | 4.64M | 5.11M |     1.10 | 11.18M |     0 | 0:08'17'' |
| original_3000000 |    906M | 195.2 |     151 |   75 | 589.74M |  34.907% | 4.64M |  5.3M |     1.14 | 14.26M |     0 | 0:10'03'' |
| original_3500000 |   1.06G | 227.7 |     151 |   75 | 691.24M |  34.604% | 4.64M | 5.51M |     1.19 | 18.69M |     0 | 0:11'32'' |
| original_4000000 |   1.21G | 260.3 |     151 |   75 | 793.52M |  34.311% | 4.64M | 5.74M |     1.24 | 24.98M |     0 | 0:13'06'' |
| Q20L100_500000   | 143.87M |  31.0 |     144 |   69 | 124.61M |  13.385% | 4.64M | 4.55M |     0.98 |  4.64M |     0 | 0:01'54'' |
| Q20L100_1000000  | 287.72M |  62.0 |     144 |   97 | 249.55M |  13.264% | 4.64M | 4.56M |     0.98 |  4.69M |     0 | 0:03'18'' |
| Q20L100_1500000  | 431.61M |  93.0 |     144 |   97 | 374.63M |  13.202% | 4.64M | 4.57M |     0.98 |  4.75M |     0 | 0:04'47'' |
| Q20L100_2000000  | 575.48M | 124.0 |     144 |   69 | 499.78M |  13.154% | 4.64M | 4.58M |     0.99 |  4.78M |     0 | 0:06'29'' |
| Q20L100_2500000  | 719.31M | 155.0 |     144 |   99 | 624.83M |  13.135% | 4.64M | 4.59M |     0.99 |  4.96M |     0 | 0:07'37'' |
| Q20L100_3000000  |  863.2M | 186.0 |     144 |   69 |  750.2M |  13.091% | 4.64M | 4.61M |     0.99 |     5M |     0 | 0:09'50'' |
| Q20L100_3500000  |   1.01G | 217.0 |     144 |   69 | 875.49M |  13.064% | 4.64M | 4.62M |     1.00 |  5.14M |     0 | 0:11'12'' |
| Q20L100_4000000  |   1.15G | 248.0 |     144 |   69 |      1G |  13.015% | 4.64M | 4.64M |     1.00 |   5.3M |     0 | 0:12'44'' |
| Q20L110_500000   | 145.36M |  31.3 |     145 |  105 | 126.11M |  13.244% | 4.64M | 4.55M |     0.98 |  4.84M |     0 | 0:01'54'' |
| Q20L110_1000000  | 290.68M |  62.6 |     145 |  101 | 252.36M |  13.183% | 4.64M | 4.56M |     0.98 |   4.7M |     0 | 0:03'31'' |
| Q20L110_1500000  | 436.05M |  93.9 |     145 |  105 | 378.54M |  13.190% | 4.64M | 4.56M |     0.98 |  4.75M |     0 | 0:04'56'' |
| Q20L110_2000000  | 581.39M | 125.3 |     145 |  105 | 505.05M |  13.130% | 4.64M | 4.58M |     0.99 |  4.84M |     0 | 0:06'10'' |
| Q20L110_2500000  | 726.79M | 156.6 |     145 |  101 | 631.62M |  13.094% | 4.64M | 4.59M |     0.99 |  4.95M |     0 | 0:07'53'' |
| Q20L110_3000000  | 872.11M | 187.9 |     145 |  101 |  758.2M |  13.061% | 4.64M |  4.6M |     0.99 |  5.11M |     0 | 0:09'32'' |
| Q20L110_3500000  |   1.02G | 219.2 |     145 |  101 | 885.09M |  13.010% | 4.64M | 4.62M |     1.00 |  5.29M |     0 | 0:10'46'' |
| Q20L110_4000000  |   1.16G | 250.5 |     145 |  101 |   1.01G |  12.961% | 4.64M | 4.64M |     1.00 |  5.51M |     0 | 0:12'29'' |
| Q20L120_500000   |    147M |  31.7 |     147 |  105 | 127.72M |  13.114% | 4.64M | 4.55M |     0.98 |  4.81M |     0 | 0:02'18'' |
| Q20L120_1000000  | 293.95M |  63.3 |     147 |  105 | 255.24M |  13.169% | 4.64M | 4.56M |     0.98 |  4.71M |     0 | 0:03'32'' |
| Q20L120_1500000  | 440.97M |  95.0 |     147 |  105 | 383.13M |  13.118% | 4.64M | 4.56M |     0.98 |  4.74M |     0 | 0:04'54'' |
| Q20L120_2000000  | 587.93M | 126.7 |     147 |  105 | 510.95M |  13.093% | 4.64M | 4.57M |     0.99 |  4.82M |     0 | 0:06'49'' |
| Q20L120_2500000  | 734.94M | 158.3 |     147 |  105 | 639.02M |  13.051% | 4.64M | 4.58M |     0.99 |  4.94M |     0 | 0:08'15'' |
| Q20L120_3000000  | 881.95M | 190.0 |     147 |  105 |  767.2M |  13.011% | 4.64M |  4.6M |     0.99 |   5.1M |     0 | 0:09'41'' |
| Q20L120_3500000  |   1.03G | 221.7 |     147 |  105 | 895.51M |  12.967% | 4.64M | 4.61M |     0.99 |  5.29M |     0 | 0:10'44'' |
| Q20L130_500000   | 148.95M |  32.1 |     149 |  105 | 129.32M |  13.176% | 4.64M | 4.53M |     0.98 |  4.79M |     0 | 0:02'10'' |
| Q20L130_1000000  |  297.9M |  64.2 |     149 |  105 | 258.61M |  13.188% | 4.64M | 4.55M |     0.98 |  4.71M |     0 | 0:03'39'' |
| Q20L130_1500000  | 446.85M |  96.3 |     149 |  105 | 388.08M |  13.152% | 4.64M | 4.56M |     0.98 |  4.74M |     0 | 0:04'50'' |
| Q20L130_2000000  |  595.8M | 128.4 |     149 |  105 | 517.69M |  13.111% | 4.64M | 4.57M |     0.98 |  4.82M |     0 | 0:06'20'' |
| Q20L130_2500000  | 744.74M | 160.4 |     149 |  105 | 647.22M |  13.094% | 4.64M | 4.58M |     0.99 |  4.92M |     0 | 0:08'44'' |
| Q20L130_3000000  | 893.69M | 192.5 |     149 |  105 | 777.03M |  13.054% | 4.64M | 4.59M |     0.99 |  5.07M |     0 | 0:10'25'' |
| Q20L140_500000   | 150.76M |  32.5 |     150 |  105 | 130.61M |  13.364% | 4.64M | 4.51M |     0.97 |  4.77M |     0 | 0:02'08'' |
| Q20L140_1000000  | 301.51M |  65.0 |     150 |  105 | 261.25M |  13.355% | 4.64M | 4.54M |     0.98 |  4.71M |     0 | 0:03'52'' |
| Q20L140_1500000  | 452.27M |  97.4 |     150 |  105 | 391.94M |  13.340% | 4.64M | 4.55M |     0.98 |  4.74M |     0 | 0:05'06'' |
| Q20L140_2000000  | 603.03M | 129.9 |     150 |  105 |  522.8M |  13.305% | 4.64M | 4.56M |     0.98 |  4.81M |     0 | 0:06'42'' |
| Q20L140_2500000  | 753.79M | 162.4 |     150 |  105 | 653.87M |  13.256% | 4.64M | 4.57M |     0.98 |  4.92M |     0 | 0:08'20'' |
| Q20L150_500000   |    151M |  32.5 |     150 |  105 | 130.92M |  13.297% | 4.64M |  4.5M |     0.97 |  4.76M |     0 | 0:02'04'' |
| Q20L150_1000000  |    302M |  65.1 |     150 |  105 | 261.88M |  13.285% | 4.64M | 4.54M |     0.98 |  4.71M |     0 | 0:03'46'' |
| Q20L150_1500000  |    453M |  97.6 |     150 |  105 | 392.83M |  13.283% | 4.64M | 4.55M |     0.98 |  4.73M |     0 | 0:05'26'' |
| Q20L150_2000000  |    604M | 130.1 |     150 |  105 | 523.92M |  13.259% | 4.64M | 4.56M |     0.98 |   4.8M |     0 | 0:06'58'' |
| Q20L150_2500000  | 740.82M | 159.6 |     150 |  105 | 642.87M |  13.222% | 4.64M | 4.57M |     0.98 |  4.89M |     0 | 0:07'50'' |
| Q25L100_500000   | 139.22M |  30.0 |     139 |   89 | 131.02M |   5.891% | 4.64M | 4.55M |     0.98 |   4.7M |     0 | 0:02'11'' |
| Q25L100_1000000  | 278.46M |  60.0 |     140 |   89 | 262.04M |   5.894% | 4.64M | 4.55M |     0.98 |  4.66M |     0 | 0:03'26'' |
| Q25L100_1500000  | 417.71M |  90.0 |     139 |   91 | 393.08M |   5.895% | 4.64M | 4.56M |     0.98 |  4.66M |     0 | 0:04'45'' |
| Q25L100_2000000  | 556.94M | 120.0 |     140 |   89 | 524.04M |   5.907% | 4.64M | 4.56M |     0.98 |  4.66M |     0 | 0:07'00'' |
| Q25L100_2500000  | 696.15M | 150.0 |     140 |   91 |  655.2M |   5.882% | 4.64M | 4.56M |     0.98 |  4.67M |     0 | 0:08'07'' |
| Q25L100_3000000  | 835.35M | 180.0 |     140 |   89 | 786.18M |   5.885% | 4.64M | 4.56M |     0.98 |  4.68M |     0 | 0:11'03'' |
| Q25L100_3500000  |  974.6M | 210.0 |     139 |   89 |  917.3M |   5.879% | 4.64M | 4.57M |     0.98 |  4.69M |     0 | 0:13'04'' |
| Q25L110_500000   | 141.56M |  30.5 |     142 |   93 | 133.09M |   5.986% | 4.64M | 4.54M |     0.98 |  4.72M |     0 | 0:02'41'' |
| Q25L110_1000000  | 283.13M |  61.0 |     141 |   93 | 266.18M |   5.989% | 4.64M | 4.55M |     0.98 |  4.67M |     0 | 0:04'28'' |
| Q25L110_1500000  | 424.69M |  91.5 |     142 |   93 | 399.32M |   5.974% | 4.64M | 4.56M |     0.98 |  4.67M |     0 | 0:05'10'' |
| Q25L110_2000000  | 566.27M | 122.0 |     142 |   93 | 532.46M |   5.972% | 4.64M | 4.56M |     0.98 |  4.67M |     0 | 0:06'27'' |
| Q25L110_2500000  | 707.82M | 152.5 |     142 |   91 | 665.57M |   5.969% | 4.64M | 4.56M |     0.98 |  4.68M |     0 | 0:08'27'' |
| Q25L110_3000000  |  849.4M | 183.0 |     141 |   91 | 798.81M |   5.956% | 4.64M | 4.56M |     0.98 |  4.69M |     0 | 0:10'06'' |
| Q25L110_3500000  | 985.16M | 212.2 |     141 |   91 | 926.49M |   5.955% | 4.64M | 4.57M |     0.98 |   4.7M |     0 | 0:11'13'' |
| Q25L120_500000   | 144.17M |  31.1 |     144 |   95 | 135.37M |   6.100% | 4.64M | 4.53M |     0.98 |  4.72M |     0 | 0:02'08'' |
| Q25L120_1000000  | 288.38M |  62.1 |     144 |   95 | 270.86M |   6.076% | 4.64M | 4.55M |     0.98 |  4.67M |     0 | 0:03'53'' |
| Q25L120_1500000  | 432.57M |  93.2 |     144 |   95 | 406.21M |   6.093% | 4.64M | 4.56M |     0.98 |  4.68M |     0 | 0:05'19'' |
| Q25L120_2000000  | 576.74M | 124.3 |     144 |   95 | 541.54M |   6.104% | 4.64M | 4.56M |     0.98 |  4.68M |     0 | 0:06'50'' |
| Q25L120_2500000  | 720.92M | 155.3 |     144 |   95 | 676.98M |   6.096% | 4.64M | 4.56M |     0.98 |  4.68M |     0 | 0:08'14'' |
| Q25L130_500000   | 147.35M |  31.7 |     147 |  105 | 137.95M |   6.384% | 4.64M |  4.5M |     0.97 |  4.83M |     0 | 0:02'11'' |
| Q25L130_1000000  | 294.71M |  63.5 |     147 |  105 | 275.86M |   6.393% | 4.64M | 4.54M |     0.98 |  4.73M |     0 | 0:03'44'' |
| Q25L130_1500000  | 442.04M |  95.2 |     147 |  105 | 413.83M |   6.382% | 4.64M | 4.55M |     0.98 |  4.71M |     0 | 0:05'08'' |
| Q25L130_2000000  | 589.41M | 127.0 |     147 |  103 | 551.77M |   6.387% | 4.64M | 4.55M |     0.98 |   4.7M |     0 | 0:06'57'' |
| Q25L140_500000   | 150.48M |  32.4 |     150 |  105 | 140.08M |   6.907% | 4.64M | 4.42M |     0.95 |  4.75M |     0 | 0:02'23'' |
| Q25L140_1000000  | 300.95M |  64.8 |     150 |  105 | 280.19M |   6.899% | 4.64M |  4.5M |     0.97 |  4.72M |     0 | 0:03'47'' |
| Q25L150_500000   |    151M |  32.5 |     150 |  105 | 140.28M |   7.097% | 4.64M | 4.38M |     0.94 |  4.71M |     0 | 0:02'08'' |
| Q25L150_1000000  |    302M |  65.1 |     150 |  105 |  280.8M |   7.020% | 4.64M | 4.48M |     0.97 |  4.71M |     0 | 0:03'42'' |
| Q30L100_500000   | 130.79M |  28.2 |     131 |   81 |  127.5M |   2.514% | 4.64M | 4.53M |     0.97 |  4.71M |     0 | 0:01'56'' |
| Q30L100_1000000  | 261.57M |  56.4 |     131 |   81 | 255.01M |   2.508% | 4.64M | 4.55M |     0.98 |  4.67M |     0 | 0:03'27'' |
| Q30L100_1500000  | 392.31M |  84.5 |     131 |   81 | 382.49M |   2.504% | 4.64M | 4.55M |     0.98 |  4.67M |     0 | 0:04'36'' |
| Q30L100_2000000  | 523.09M | 112.7 |     131 |   81 | 510.05M |   2.492% | 4.64M | 4.56M |     0.98 |  4.66M |     0 | 0:06'10'' |
| Q30L100_2500000  | 653.84M | 140.9 |     131 |   81 | 637.52M |   2.495% | 4.64M | 4.56M |     0.98 |  4.66M |     0 | 0:07'37'' |
| Q30L120_500000   | 134.74M |  29.0 |     135 |   87 | 131.29M |   2.561% | 4.64M |  4.5M |     0.97 |  4.74M |     0 | 0:02'08'' |
| Q30L120_1000000  |  269.5M |  58.1 |     135 |   87 | 262.57M |   2.571% | 4.64M | 4.54M |     0.98 |  4.69M |     0 | 0:03'28'' |
| Q30L120_1500000  | 404.26M |  87.1 |     135 |   87 | 393.83M |   2.581% | 4.64M | 4.55M |     0.98 |  4.69M |     0 | 0:04'37'' |
| Q30L120_2000000  |    539M | 116.1 |     134 |   87 | 525.11M |   2.576% | 4.64M | 4.55M |     0.98 |  4.68M |     0 | 0:04'26'' |

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

三代 reads 里有一个常见的错误, 即单一 ZMW 里的测序结果中, 接头序列部分的测序结果出现了较多的错误,
因此并没有将接头序列去除干净, 形成的 subreads 里含有多份基因组上同一片段, 它们之间以接头序列为间隔. 二代 contigs
有可能会与一条三代 reads 匹配多次, 对组装造成影响. `anchr group` 命令里提供了选项, 将这种三代的 reads 去除.
此判断没有放到 `anchr cover` 里, 因为拆分出的的 anchors 里也可能会有匹配多次的情况.

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
