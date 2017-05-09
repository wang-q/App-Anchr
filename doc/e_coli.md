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

## Combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60, 90, and 120

```bash
BASE_DIR=$HOME/data/anchr/e_coli

cd ${BASE_DIR}
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
cd ${BASE_DIR}
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
    " ::: 20 25 30 ::: 60 90 120

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
    for len in 60 90 120; do
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
| Q20L60   |     151 | 1468709458 | 10572422 |
| Q20L90   |     151 | 1370119196 |  9617554 |
| Q20L120  |     151 | 1135307713 |  7723784 |
| Q25L60   |     151 | 1317617346 |  9994728 |
| Q25L90   |     151 | 1177142378 |  8586574 |
| Q25L120  |     151 |  837111446 |  5805874 |
| Q30L60   |     128 | 1062490984 |  8936174 |
| Q30L90   |     131 |  841751070 |  6618100 |
| Q30L120  |     141 |  383179242 |  2753854 |

## Down sampling

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

ARRAY=( 
    "2_illumina:original:4000000"
    "2_illumina/Q20L60:Q20L60:4000000"
    "2_illumina/Q20L90:Q20L90:4000000"
    "2_illumina/Q20L120:Q20L120:4000000"
    "2_illumina/Q25L60:Q25L60:4000000"
    "2_illumina/Q25L90:Q25L90:4000000"
    "2_illumina/Q25L120:Q25L120:3000000"
    "2_illumina/Q30L60:Q30L60:4000000"
    "2_illumina/Q30L90:Q30L90:3000000"
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
        Q20L60 Q20L90 Q20L120
        Q25L60 Q25L90 Q25L120
        Q30L60 Q30L90 Q30L120
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

        if [ -e ${BASE_DIR}/{}/k_unitigs.fasta ]; then
            echo '    k_unitigs.fasta already presents'
            exit;
        fi

        cd ${BASE_DIR}/{}
        anchr superreads \
            R1.fq.gz R2.fq.gz \
            --nosr -p 8 \
            --kmer 41,61,81,101,121 \
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
        Q20L60 Q20L90 Q20L120
        Q25L60 Q25L90 Q25L120
        Q30L60 Q30L90 Q30L120
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
        Q20L60 Q20L90 Q20L120
        Q25L60 Q25L90 Q25L120
        Q30L60 Q30L90 Q30L120
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
        Q20L60 Q20L90 Q20L120
        Q25L60 Q25L90 Q25L120
        Q30L60 Q30L90 Q30L120
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

| Name             |   SumFq | CovFq | AvgRead |               Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:-----------------|--------:|------:|--------:|-------------------:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| original_500000  |    151M |  32.5 |     151 | "41,61,81,101,121" |  95.16M |  36.979% | 4.64M | 4.58M |     0.99 | 4.68M |     0 | 0:02'10'' |
| original_1000000 |    302M |  65.1 |     151 | "41,61,81,101,121" | 192.04M |  36.411% | 4.64M | 4.68M |     1.01 |  4.7M |     0 | 0:03'06'' |
| original_1500000 |    453M |  97.6 |     151 | "41,61,81,101,121" | 290.09M |  35.962% | 4.64M | 4.79M |     1.03 | 4.49M |     0 | 0:04'07'' |
| original_2000000 |    604M | 130.1 |     151 | "41,61,81,101,121" | 389.03M |  35.591% | 4.64M | 4.94M |     1.06 | 4.13M |     0 | 0:05'42'' |
| original_2500000 |    755M | 162.7 |     151 | "41,61,81,101,121" | 489.12M |  35.215% | 4.64M | 5.11M |     1.10 | 3.62M |     0 | 0:06'32'' |
| original_3000000 |    906M | 195.2 |     151 | "41,61,81,101,121" | 589.74M |  34.907% | 4.64M |  5.3M |     1.14 | 3.05M |     0 | 0:06'57'' |
| original_3500000 |   1.06G | 227.7 |     151 | "41,61,81,101,121" | 691.24M |  34.604% | 4.64M | 5.51M |     1.19 | 2.57M |     0 | 0:08'08'' |
| original_4000000 |   1.21G | 260.3 |     151 | "41,61,81,101,121" | 793.52M |  34.311% | 4.64M | 5.74M |     1.24 | 2.13M |     0 | 0:08'31'' |
| Q20L60_500000    | 138.95M |  29.9 |     139 | "41,61,81,101,121" | 120.17M |  13.511% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:04'26'' |
| Q20L60_1000000   | 277.84M |  59.9 |     139 | "41,61,81,101,121" | 240.48M |  13.444% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:04'59'' |
| Q20L60_1500000   | 416.77M |  89.8 |     139 | "41,61,81,101,121" | 360.91M |  13.402% | 4.64M | 4.57M |     0.98 | 4.59M |     0 | 0:06'11'' |
| Q20L60_2000000   | 555.69M | 119.7 |     139 | "41,61,81,101,121" | 481.24M |  13.397% | 4.64M | 4.58M |     0.99 | 4.61M |     0 | 0:07'49'' |
| Q20L60_2500000   |  694.6M | 149.6 |     139 | "41,61,81,101,121" | 602.09M |  13.319% | 4.64M |  4.6M |     0.99 | 4.64M |     0 | 0:09'02'' |
| Q20L60_3000000   | 833.51M | 179.6 |     139 | "41,61,81,101,121" | 722.61M |  13.305% | 4.64M | 4.62M |     0.99 | 4.68M |     0 | 0:11'02'' |
| Q20L60_3500000   | 972.46M | 209.5 |     139 | "41,61,81,101,121" | 843.49M |  13.262% | 4.64M | 4.64M |     1.00 |  4.7M |     0 | 0:13'35'' |
| Q20L60_4000000   |   1.11G | 239.4 |     139 | "41,61,81,101,121" | 964.55M |  13.205% | 4.64M | 4.66M |     1.00 | 4.72M |     0 | 0:22'19'' |
| Q20L90_500000    | 142.46M |  30.7 |     142 | "41,61,81,101,121" | 123.42M |  13.367% | 4.64M | 4.55M |     0.98 | 4.57M |     0 | 0:05'39'' |
| Q20L90_1000000   | 284.91M |  61.4 |     143 | "41,61,81,101,121" | 246.93M |  13.328% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:05'50'' |
| Q20L90_1500000   | 427.36M |  92.1 |     143 | "41,61,81,101,121" | 370.55M |  13.295% | 4.64M | 4.57M |     0.98 | 4.59M |     0 | 0:08'08'' |
| Q20L90_2000000   | 569.85M | 122.8 |     143 | "41,61,81,101,121" |  494.4M |  13.241% | 4.64M | 4.58M |     0.99 | 4.62M |     0 | 0:11'21'' |
| Q20L90_2500000   | 712.33M | 153.5 |     143 | "41,61,81,101,121" |  618.2M |  13.215% | 4.64M | 4.59M |     0.99 | 4.65M |     0 | 0:15'40'' |
| Q20L90_3000000   | 854.77M | 184.2 |     143 | "41,61,81,101,121" | 742.32M |  13.155% | 4.64M | 4.61M |     0.99 | 4.68M |     0 | 0:17'56'' |
| Q20L90_3500000   | 997.27M | 214.9 |     142 | "41,61,81,101,121" | 866.42M |  13.120% | 4.64M | 4.63M |     1.00 | 4.71M |     0 | 0:16'22'' |
| Q20L90_4000000   |   1.14G | 245.5 |     142 | "41,61,81,101,121" | 990.71M |  13.069% | 4.64M | 4.65M |     1.00 | 4.72M |     0 | 0:22'30'' |
| Q20L120_500000   |    147M |  31.7 |     147 | "41,61,81,101,121" | 127.72M |  13.114% | 4.64M | 4.55M |     0.98 | 4.56M |     0 | 0:02'29'' |
| Q20L120_1000000  | 293.95M |  63.3 |     147 | "41,61,81,101,121" | 255.24M |  13.169% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:03'32'' |
| Q20L120_1500000  | 440.97M |  95.0 |     147 | "41,61,81,101,121" | 383.13M |  13.118% | 4.64M | 4.56M |     0.98 | 4.59M |     0 | 0:04'38'' |
| Q20L120_2000000  | 587.93M | 126.7 |     147 | "41,61,81,101,121" | 510.95M |  13.093% | 4.64M | 4.57M |     0.99 | 4.61M |     0 | 0:06'08'' |
| Q20L120_2500000  | 734.94M | 158.3 |     147 | "41,61,81,101,121" | 639.02M |  13.051% | 4.64M | 4.58M |     0.99 | 4.64M |     0 | 0:07'00'' |
| Q20L120_3000000  | 881.95M | 190.0 |     147 | "41,61,81,101,121" |  767.2M |  13.011% | 4.64M |  4.6M |     0.99 | 4.68M |     0 | 0:07'07'' |
| Q20L120_3500000  |   1.03G | 221.7 |     147 | "41,61,81,101,121" | 895.51M |  12.967% | 4.64M | 4.61M |     0.99 |  4.7M |     0 | 0:08'01'' |
| Q20L120_4000000  |   1.14G | 244.6 |     147 | "41,61,81,101,121" | 988.43M |  12.937% | 4.64M | 4.63M |     1.00 | 4.72M |     0 | 0:14'47'' |
| Q25L60_500000    | 131.83M |  28.4 |     133 | "41,61,81,101,121" | 124.15M |   5.829% | 4.64M | 4.55M |     0.98 | 4.57M |     0 | 0:03'18'' |
| Q25L60_1000000   |  263.6M |  56.8 |     133 | "41,61,81,101,121" | 248.24M |   5.826% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:04'34'' |
| Q25L60_1500000   |  395.5M |  85.2 |     133 | "41,61,81,101,121" | 372.49M |   5.817% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:06'24'' |
| Q25L60_2000000   | 527.37M | 113.6 |     133 | "41,61,81,101,121" | 496.59M |   5.837% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:07'46'' |
| Q25L60_2500000   | 659.18M | 142.0 |     133 | "41,61,81,101,121" | 620.88M |   5.811% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:08'45'' |
| Q25L60_3000000   | 790.95M | 170.4 |     133 | "41,61,81,101,121" | 744.93M |   5.818% | 4.64M | 4.57M |     0.98 | 4.57M |     0 | 0:10'14'' |
| Q25L60_3500000   | 922.81M | 198.8 |     133 | "41,61,81,101,121" | 869.14M |   5.816% | 4.64M | 4.57M |     0.98 | 4.58M |     0 | 0:11'46'' |
| Q25L60_4000000   |   1.05G | 227.2 |     133 | "41,61,81,101,121" | 993.37M |   5.814% | 4.64M | 4.57M |     0.99 | 4.58M |     0 | 0:13'11'' |
| Q25L90_500000    |  137.1M |  29.5 |     137 | "41,61,81,101,121" | 129.07M |   5.852% | 4.64M | 4.55M |     0.98 | 4.55M |     0 | 0:03'06'' |
| Q25L90_1000000   | 274.18M |  59.1 |     138 | "41,61,81,101,121" | 258.04M |   5.886% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:04'57'' |
| Q25L90_1500000   | 411.28M |  88.6 |     137 | "41,61,81,101,121" | 387.21M |   5.852% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:06'15'' |
| Q25L90_2000000   | 548.37M | 118.1 |     137 | "41,61,81,101,121" | 516.26M |   5.856% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:08'11'' |
| Q25L90_2500000   | 685.46M | 147.7 |     137 | "41,61,81,101,121" | 645.35M |   5.851% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:09'13'' |
| Q25L90_3000000   | 822.53M | 177.2 |     137 | "41,61,81,101,121" | 774.48M |   5.842% | 4.64M | 4.57M |     0.98 | 4.58M |     0 | 0:11'03'' |
| Q25L90_3500000   | 959.65M | 206.7 |     137 | "41,61,81,101,121" | 903.63M |   5.838% | 4.64M | 4.57M |     0.98 | 4.58M |     0 | 0:12'44'' |
| Q25L90_4000000   |    1.1G | 236.3 |     137 | "41,61,81,101,121" |   1.03G |   5.842% | 4.64M | 4.57M |     0.98 | 4.59M |     0 | 0:14'06'' |
| Q25L120_500000   | 144.17M |  31.1 |     144 | "41,61,81,101,121" | 135.37M |   6.100% | 4.64M | 4.53M |     0.98 | 4.54M |     0 | 0:02'12'' |
| Q25L120_1000000  | 288.38M |  62.1 |     144 | "41,61,81,101,121" | 270.86M |   6.076% | 4.64M | 4.55M |     0.98 | 4.55M |     0 | 0:03'26'' |
| Q25L120_1500000  | 432.57M |  93.2 |     144 | "41,61,81,101,121" | 406.21M |   6.093% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:04'24'' |
| Q25L120_2000000  | 576.74M | 124.3 |     144 | "41,61,81,101,121" | 541.54M |   6.104% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:05'12'' |
| Q25L120_2500000  | 720.92M | 155.3 |     144 | "41,61,81,101,121" | 676.98M |   6.096% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:06'12'' |
| Q25L120_3000000  | 837.11M | 180.3 |     144 | "41,61,81,101,121" | 786.11M |   6.093% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:11'29'' |
| Q30L60_500000    | 118.87M |  25.6 |     121 | "41,61,81,101,121" | 115.99M |   2.420% | 4.64M | 4.55M |     0.98 | 4.57M |     0 | 0:02'54'' |
| Q30L60_1000000   | 237.81M |  51.2 |     120 | "41,61,81,101,121" | 232.15M |   2.380% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:04'15'' |
| Q30L60_1500000   | 356.65M |  76.8 |     120 | "41,61,81,101,121" | 348.11M |   2.393% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:05'23'' |
| Q30L60_2000000   | 475.58M | 102.5 |     120 | "41,61,81,101,121" | 464.19M |   2.395% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:06'41'' |
| Q30L60_2500000   | 594.46M | 128.1 |     120 | "41,61,81,101,121" |  580.2M |   2.399% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:07'47'' |
| Q30L60_3000000   | 713.36M | 153.7 |     121 | "41,61,81,101,121" | 696.21M |   2.404% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:08'50'' |
| Q30L60_3500000   | 832.27M | 179.3 |     120 | "41,61,81,101,121" | 812.33M |   2.396% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:10'28'' |
| Q30L60_4000000   |  951.2M | 204.9 |     120 | "41,61,81,101,121" | 928.39M |   2.397% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:11'27'' |
| Q30L90_500000    | 127.19M |  27.4 |     127 | "41,61,81,101,121" | 124.05M |   2.470% | 4.64M | 4.54M |     0.98 | 4.55M |     0 | 0:02'54'' |
| Q30L90_1000000   | 254.34M |  54.8 |     128 | "41,61,81,101,121" | 248.09M |   2.457% | 4.64M | 4.55M |     0.98 | 4.56M |     0 | 0:04'29'' |
| Q30L90_1500000   | 381.56M |  82.2 |     128 | "41,61,81,101,121" | 372.17M |   2.460% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:05'50'' |
| Q30L90_2000000   | 508.74M | 109.6 |     128 | "41,61,81,101,121" | 496.26M |   2.454% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:07'12'' |
| Q30L90_2500000   | 635.99M | 137.0 |     127 | "41,61,81,101,121" | 620.38M |   2.455% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:08'57'' |
| Q30L90_3000000   | 763.13M | 164.4 |     128 | "41,61,81,101,121" | 744.45M |   2.448% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:09'57'' |
| Q30L120_500000   | 139.15M |  30.0 |     139 | "41,61,81,101,121" | 135.34M |   2.739% | 4.64M | 4.44M |     0.96 | 4.42M |     0 | 0:02'19'' |
| Q30L120_1000000  | 278.29M |  60.0 |     139 | "41,61,81,101,121" | 270.83M |   2.680% | 4.64M | 4.51M |     0.97 | 4.51M |     0 | 0:03'08'' |

| Name             | N50SR |   Sum |    # | N50Anchor |     Sum |    # | N50Others |     Sum |    # |   RunTime |
|:-----------------|------:|------:|-----:|----------:|--------:|-----:|----------:|--------:|-----:|----------:|
| original_500000  |  4074 | 4.68M | 1737 |      4354 |   4.33M | 1262 |       789 | 357.43K |  475 | 0:01'26'' |
| original_1000000 |  2251 |  4.7M | 2706 |      2599 |   3.95M | 1697 |       785 | 748.62K | 1009 | 0:01'47'' |
| original_1500000 |  1489 | 4.49M | 3524 |      1859 |   3.24M | 1787 |       746 |   1.25M | 1737 | 0:02'00'' |
| original_2000000 |  1099 | 4.13M | 4034 |      1563 |   2.28M | 1427 |       732 |   1.85M | 2607 | 0:02'18'' |
| original_2500000 |   918 | 3.62M | 4054 |      1408 |   1.55M | 1066 |       706 |   2.07M | 2988 | 0:02'25'' |
| original_3000000 |   832 | 3.05M | 3682 |      1357 |   1.07M |  755 |       679 |   1.98M | 2927 | 0:02'35'' |
| original_3500000 |   771 | 2.57M | 3278 |      1332 | 723.12K |  519 |       674 |   1.85M | 2759 | 0:02'12'' |
| original_4000000 |   722 | 2.13M | 2842 |      1311 | 524.16K |  379 |       645 |    1.6M | 2463 | 0:02'35'' |
| Q20L60_500000    | 42980 | 4.57M |  233 |     42980 |   4.55M |  205 |       590 |  17.83K |   28 | 0:01'34'' |
| Q20L60_1000000   | 34721 | 4.57M |  234 |     34721 |   4.56M |  207 |       706 |  18.53K |   27 | 0:02'11'' |
| Q20L60_1500000   | 21202 | 4.59M |  370 |     21264 |   4.57M |  340 |       807 |   22.4K |   30 | 0:02'47'' |
| Q20L60_2000000   | 13363 | 4.61M |  592 |     13441 |   4.57M |  532 |       778 |  44.01K |   60 | 0:03'20'' |
| Q20L60_2500000   |  8129 | 4.64M |  873 |      8281 |   4.58M |  786 |       796 |  64.42K |   87 | 0:03'35'' |
| Q20L60_3000000   |  5663 | 4.68M | 1265 |      5820 |   4.54M | 1066 |       769 | 145.93K |  199 | 0:03'39'' |
| Q20L60_3500000   |  4107 |  4.7M | 1615 |      4288 |   4.46M | 1299 |       819 | 241.32K |  316 | 0:06'31'' |
| Q20L60_4000000   |  3075 | 4.72M | 2057 |      3327 |   4.35M | 1561 |       796 | 371.54K |  496 | 0:04'22'' |
| Q20L90_500000    | 40230 | 4.57M |  247 |     40230 |   4.55M |  217 |       706 |  20.38K |   30 | 0:01'24'' |
| Q20L90_1000000   | 41230 | 4.57M |  233 |     41230 |   4.55M |  206 |       706 |  18.22K |   27 | 0:02'15'' |
| Q20L90_1500000   | 22491 | 4.59M |  346 |     22491 |   4.57M |  317 |       807 |  21.96K |   29 | 0:02'39'' |
| Q20L90_2000000   | 12612 | 4.62M |  591 |     12709 |   4.58M |  539 |       828 |  38.76K |   52 | 0:02'51'' |
| Q20L90_2500000   |  8237 | 4.65M |  878 |      8352 |   4.58M |  788 |       788 |  67.11K |   90 | 0:03'25'' |
| Q20L90_3000000   |  5602 | 4.68M | 1287 |      5820 |   4.52M | 1080 |       796 | 159.04K |  207 | 0:03'25'' |
| Q20L90_3500000   |  3969 | 4.71M | 1691 |      4135 |   4.45M | 1348 |       811 | 258.48K |  343 | 0:03'47'' |
| Q20L90_4000000   |  2869 | 4.72M | 2179 |      3105 |    4.3M | 1621 |       789 | 417.79K |  558 | 0:04'35'' |
| Q20L120_500000   | 23354 | 4.56M |  375 |     23585 |   4.52M |  330 |       749 |  32.23K |   45 | 0:01'33'' |
| Q20L120_1000000  | 31712 | 4.57M |  266 |     31712 |   4.55M |  244 |       701 |  14.74K |   22 | 0:02'00'' |
| Q20L120_1500000  | 21072 | 4.59M |  371 |     21072 |   4.56M |  337 |       697 |  23.74K |   34 | 0:02'50'' |
| Q20L120_2000000  | 13630 | 4.61M |  573 |     13888 |   4.57M |  525 |       677 |  32.87K |   48 | 0:03'10'' |
| Q20L120_2500000  |  8348 | 4.64M |  880 |      8550 |   4.56M |  771 |       761 |  80.79K |  109 | 0:03'36'' |
| Q20L120_3000000  |  5219 | 4.68M | 1298 |      5386 |   4.52M | 1087 |       819 | 165.19K |  211 | 0:03'55'' |
| Q20L120_3500000  |  3848 |  4.7M | 1734 |      4111 |   4.42M | 1348 |       796 | 288.59K |  386 | 0:04'07'' |
| Q20L120_4000000  |  3086 | 4.72M | 2082 |      3378 |   4.31M | 1545 |       796 | 402.46K |  537 | 0:04'10'' |
| Q25L60_500000    | 40828 | 4.57M |  224 |     40828 |   4.54M |  190 |       745 |  27.83K |   34 | 0:01'35'' |
| Q25L60_1000000   | 59901 | 4.56M |  167 |     59901 |   4.55M |  143 |       702 |  15.72K |   24 | 0:02'21'' |
| Q25L60_1500000   | 61243 | 4.57M |  166 |     61243 |   4.55M |  146 |       706 |  13.43K |   20 | 0:02'58'' |
| Q25L60_2000000   | 55334 | 4.57M |  166 |     55334 |   4.56M |  147 |       677 |  12.19K |   19 | 0:03'53'' |
| Q25L60_2500000   | 55845 | 4.57M |  188 |     55845 |   4.56M |  168 |       720 |   13.8K |   20 | 0:03'57'' |
| Q25L60_3000000   | 47433 | 4.57M |  197 |     47433 |   4.56M |  178 |       722 |  13.27K |   19 | 0:04'13'' |
| Q25L60_3500000   | 38336 | 4.58M |  242 |     38336 |   4.57M |  221 |       669 |  13.69K |   21 | 0:04'33'' |
| Q25L60_4000000   | 31712 | 4.58M |  285 |     31712 |   4.56M |  257 |       754 |   20.1K |   28 | 0:05'24'' |
| Q25L90_500000    | 29154 | 4.55M |  293 |     29154 |   4.53M |  264 |       750 |  20.41K |   29 | 0:01'36'' |
| Q25L90_1000000   | 55845 | 4.56M |  188 |     55845 |   4.55M |  164 |       614 |  15.02K |   24 | 0:02'06'' |
| Q25L90_1500000   | 59776 | 4.56M |  169 |     59776 |   4.55M |  150 |       745 |  13.79K |   19 | 0:03'05'' |
| Q25L90_2000000   | 55845 | 4.57M |  177 |     55845 |   4.55M |  158 |       722 |  13.33K |   19 | 0:03'56'' |
| Q25L90_2500000   | 52785 | 4.57M |  197 |     52785 |   4.56M |  176 |       706 |  15.14K |   21 | 0:04'08'' |
| Q25L90_3000000   | 41994 | 4.58M |  217 |     41994 |   4.56M |  197 |       754 |  16.85K |   20 | 0:04'24'' |
| Q25L90_3500000   | 31457 | 4.58M |  249 |     31712 |   4.57M |  229 |       722 |  15.37K |   20 | 0:04'31'' |
| Q25L90_4000000   | 26830 | 4.59M |  295 |     27017 |   4.57M |  270 |       722 |  18.37K |   25 | 0:05'31'' |
| Q25L120_500000   | 15690 | 4.54M |  514 |     15707 |    4.5M |  457 |       833 |  45.76K |   57 | 0:01'38'' |
| Q25L120_1000000  | 30721 | 4.55M |  315 |     30721 |   4.53M |  280 |       745 |  25.11K |   35 | 0:02'06'' |
| Q25L120_1500000  | 36914 | 4.57M |  258 |     36914 |   4.55M |  238 |       706 |  13.65K |   20 | 0:02'47'' |
| Q25L120_2000000  | 37756 | 4.57M |  253 |     37756 |   4.56M |  226 |       737 |  18.85K |   27 | 0:03'39'' |
| Q25L120_2500000  | 36715 | 4.57M |  245 |     36715 |   4.56M |  227 |       614 |  11.77K |   18 | 0:04'02'' |
| Q25L120_3000000  | 35067 | 4.57M |  271 |     35067 |   4.55M |  244 |       754 |  19.16K |   27 | 0:04'19'' |
| Q30L60_500000    | 22151 | 4.57M |  388 |     22251 |   4.53M |  342 |       752 |  33.57K |   46 | 0:01'50'' |
| Q30L60_1000000   | 36227 | 4.56M |  238 |     36227 |   4.54M |  209 |       694 |  19.36K |   29 | 0:02'28'' |
| Q30L60_1500000   | 47234 | 4.56M |  213 |     47234 |   4.54M |  184 |       702 |  20.38K |   29 | 0:02'55'' |
| Q30L60_2000000   | 48172 | 4.57M |  214 |     48172 |   4.55M |  183 |       700 |  20.85K |   31 | 0:03'47'' |
| Q30L60_2500000   | 50875 | 4.57M |  196 |     50875 |   4.55M |  177 |       657 |  12.39K |   19 | 0:03'46'' |
| Q30L60_3000000   | 52180 | 4.57M |  194 |     52180 |   4.55M |  172 |       657 |  14.74K |   22 | 0:04'39'' |
| Q30L60_3500000   | 52184 | 4.57M |  194 |     52184 |   4.55M |  171 |       706 |  15.98K |   23 | 0:05'11'' |
| Q30L60_4000000   | 52184 | 4.57M |  187 |     52184 |   4.55M |  168 |       706 |  13.16K |   19 | 0:05'53'' |
| Q30L90_500000    | 14773 | 4.55M |  554 |     14801 |    4.5M |  493 |       706 |  42.95K |   61 | 0:01'46'' |
| Q30L90_1000000   | 25899 | 4.56M |  323 |     25899 |   4.54M |  294 |       728 |  20.25K |   29 | 0:02'31'' |
| Q30L90_1500000   | 35268 | 4.57M |  268 |     35268 |   4.55M |  238 |       745 |  21.42K |   30 | 0:02'54'' |
| Q30L90_2000000   | 38671 | 4.56M |  239 |     38671 |   4.54M |  211 |       728 |  19.24K |   28 | 0:03'39'' |
| Q30L90_2500000   | 40270 | 4.57M |  229 |     40970 |   4.55M |  206 |       706 |  15.89K |   23 | 0:03'58'' |
| Q30L90_3000000   | 43300 | 4.57M |  219 |     43300 |   4.55M |  197 |       706 |  15.05K |   22 | 0:04'25'' |
| Q30L120_500000   |  6122 | 4.42M | 1164 |      6397 |   4.24M |  926 |       771 | 176.73K |  238 | 0:01'34'' |
| Q30L120_1000000  | 10785 | 4.51M |  733 |     10986 |   4.44M |  636 |       744 |  68.77K |   97 | 0:02'18'' |

| Name               | N50SRclean |   Sum |   # | N50Anchor |   Sum |   # | N50Anchor2 |   Sum |  # | N50Others |   Sum |   # |   RunTime |
|:-------------------|-----------:|------:|----:|----------:|------:|----:|-----------:|------:|---:|----------:|------:|----:|----------:|
| Q25L100_3000000_SR |      22529 | 5.46M | 694 |     21172 | 3.14M | 244 |      31882 | 1.23M | 68 |     24143 | 1.09M | 382 | 0:02'30'' |

| Name           |   SumFq | CovFq | AvgRead |               Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:---------------|--------:|------:|--------:|-------------------:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| Q25L60K41      | 527.37M | 113.6 |     133 |               "41" | 496.59M |   5.837% | 4.64M | 4.56M |     0.98 | 4.53M |     0 | 0:05'32'' |
| Q25L60K61      | 527.37M | 113.6 |     133 |               "61" | 496.59M |   5.837% | 4.64M | 4.56M |     0.98 | 4.54M |     0 | 0:05'21'' |
| Q25L60K81      | 527.37M | 113.6 |     133 |               "81" | 496.59M |   5.837% | 4.64M | 4.56M |     0.98 | 4.55M |     0 | 0:05'20'' |
| Q25L60K101     | 527.37M | 113.6 |     133 |              "101" | 496.59M |   5.837% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:04'49'' |
| Q25L60K121     | 527.37M | 113.6 |     133 |              "121" | 496.59M |   5.837% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:04'40'' |
| Q25L60Kauto    | 527.37M | 113.6 |     133 |               "83" | 496.59M |   5.837% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:05'01'' |
| Q25L120K41     | 576.74M | 124.3 |     144 |               "41" | 541.54M |   6.104% | 4.64M | 4.56M |     0.98 | 4.52M |     0 | 0:06'02'' |
| Q25L120K61     | 576.74M | 124.3 |     144 |               "61" | 541.54M |   6.104% | 4.64M | 4.56M |     0.98 | 4.54M |     0 | 0:05'50'' |
| Q25L120K81     | 576.74M | 124.3 |     144 |               "81" | 541.54M |   6.104% | 4.64M | 4.56M |     0.98 | 4.55M |     0 | 0:05'48'' |
| Q25L120K101    | 576.74M | 124.3 |     144 |              "101" | 541.54M |   6.104% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:05'12'' |
| Q25L120K121    | 576.74M | 124.3 |     144 |              "121" | 541.54M |   6.104% | 4.64M | 4.56M |     0.98 | 4.53M |     0 | 0:05'01'' |
| Q25L120Kauto   | 576.74M | 124.3 |     144 |               "95" | 541.54M |   6.104% | 4.64M | 4.56M |     0.98 | 4.56M |     0 | 0:05'16'' |
| Q25L60Kseries  | 527.37M | 113.6 |     133 | "41,61,81,101,121" | 496.59M |   5.837% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:07'45'' |
| Q25L120Kseries | 576.74M | 124.3 |     144 | "41,61,81,101,121" | 541.54M |   6.104% | 4.64M | 4.56M |     0.98 | 4.57M |     0 | 0:08'40'' |

| Name           | N50SR |   Sum |    # | N50Anchor |   Sum |    # | N50Others |     Sum |   # |   RunTime |
|:---------------|------:|------:|-----:|----------:|------:|-----:|----------:|--------:|----:|----------:|
| Q25L60K41      | 23468 | 4.53M |  335 |     23912 | 4.51M |  314 |       714 |   14.6K |  21 | 0:03'35'' |
| Q25L60K61      | 33600 | 4.54M |  274 |     33600 | 4.52M |  249 |       613 |  16.29K |  25 | 0:03'34'' |
| Q25L60K81      | 23844 | 4.55M |  339 |     23848 | 4.53M |  312 |       769 |  19.34K |  27 | 0:03'40'' |
| Q25L60K101     | 14967 | 4.57M |  530 |     14990 | 4.54M |  480 |       754 |  35.01K |  50 | 0:03'22'' |
| Q25L60K121     |  4864 | 4.57M | 1481 |      5198 | 4.32M | 1139 |       784 | 253.53K | 342 | 0:03'19'' |
| Q25L60Kauto    | 23005 | 4.56M |  353 |     23446 | 4.54M |  325 |       706 |  19.21K |  28 | 0:03'31'' |
| Q25L120K41     | 21326 | 4.52M |  386 |     21326 |  4.5M |  357 |       706 |  20.38K |  29 | 0:03'35'' |
| Q25L120K61     | 21501 | 4.54M |  394 |     21501 | 4.51M |  355 |       685 |  26.49K |  39 | 0:03'37'' |
| Q25L120K81     | 14254 | 4.55M |  566 |     14269 |  4.5M |  497 |       779 |  50.13K |  69 | 0:03'19'' |
| Q25L120K101    |  9143 | 4.56M |  861 |      9315 | 4.47M |  740 |       764 |  88.26K | 121 | 0:03'22'' |
| Q25L120K121    |  4383 | 4.53M | 1607 |      4782 | 4.22M | 1194 |       787 | 304.83K | 413 | 0:03'30'' |
| Q25L120Kauto   | 10504 | 4.56M |  748 |     10695 | 4.49M |  648 |       737 |  71.39K | 100 | 0:03'24'' |
| Q25L60Kseries  | 55334 | 4.57M |  166 |     55334 | 4.56M |  147 |       677 |  12.19K |  19 | 0:02'55'' |
| Q25L120Kseries | 37756 | 4.57M |  252 |     37756 | 4.55M |  225 |       737 |  18.85K |  27 | 0:03'13'' |

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
    mkdir -p ${BASE_DIR}/Q25L60K{}
    cd ${BASE_DIR}/Q25L60K{}
    ln -s ../Q25L60_2000000/R1.fq.gz R1.fq.gz
    ln -s ../Q25L60_2000000/R2.fq.gz R2.fq.gz

    anchr superreads \
        R1.fq.gz R2.fq.gz \
        --nosr -p 8 \
        --kmer {} \
        -o superreads.sh
    bash superreads.sh

    rm -fr anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh . 8 false
    " ::: 41 61 81 101 121 auto

parallel -j 3 "
    mkdir -p ${BASE_DIR}/Q25L120K{}
    cd ${BASE_DIR}/Q25L120K{}
    ln -s ../Q25L120_2000000/R1.fq.gz R1.fq.gz
    ln -s ../Q25L120_2000000/R2.fq.gz R2.fq.gz

    anchr superreads \
        R1.fq.gz R2.fq.gz \
        --nosr -p 8 \
        --kmer {} \
        -o superreads.sh
    bash superreads.sh

    rm -fr anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh . 8 false
    " ::: 41 61 81 101 121 auto

parallel -j 2 "
    mkdir -p ${BASE_DIR}/{}Kseries
    cd ${BASE_DIR}/{}Kseries
    ln -s ../{}_2000000/R1.fq.gz R1.fq.gz
    ln -s ../{}_2000000/R2.fq.gz R2.fq.gz

    anchr superreads \
        R1.fq.gz R2.fq.gz \
        --nosr -p 8 \
        --kmer 41,61,81,101,121 \
        -o superreads.sh
    bash superreads.sh

    rm -fr anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh . 8 false
    " ::: Q25L60 Q25L120

REAL_G=4641652

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/statK1.md

parallel -k --no-run-if-empty -j 4 "
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${BASE_DIR}/Q25L60K{} ${REAL_G}
    " ::: 41 61 81 101 121 auto \
    >> ${BASE_DIR}/statK1.md

parallel -k --no-run-if-empty -j 4 "
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${BASE_DIR}/Q25L120K{} ${REAL_G}
    " ::: 41 61 81 101 121 auto \
    >> ${BASE_DIR}/statK1.md
    
parallel -k --no-run-if-empty -j 4 "
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${BASE_DIR}/{}Kseries ${REAL_G}
    " ::: Q25L60 Q25L120 \
    >> ${BASE_DIR}/statK1.md

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/statK2.md

parallel -k --no-run-if-empty -j 4 "
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/Q25L60K{}
    " ::: 41 61 81 101 121 auto \
    >> ${BASE_DIR}/statK2.md

parallel -k --no-run-if-empty -j 4 "
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/Q25L120K{}
    " ::: 41 61 81 101 121 auto \
    >> ${BASE_DIR}/statK2.md

parallel -k --no-run-if-empty -j 4 "
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}Kseries
    " ::: Q25L60 Q25L120 \
    >> ${BASE_DIR}/statK2.md

# merge anchors
cd ${BASE_DIR}
mkdir -p Q25L60merge
anchr contained \
    Q25L60K41/anchor/pe.anchor.fa \
    Q25L60K61/anchor/pe.anchor.fa \
    Q25L60K81/anchor/pe.anchor.fa \
    Q25L60K101/anchor/pe.anchor.fa \
    Q25L60K121/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin Q25L60merge/anchor.contained.fasta
anchr orient Q25L60merge/anchor.contained.fasta --len 1000 --idt 0.98 -o Q25L60merge/anchor.orient.fasta
anchr merge Q25L60merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin Q25L60merge/anchor.merge.fasta

cd ${BASE_DIR}
mkdir -p Q25L120merge
anchr contained \
    Q25L120K41/anchor/pe.anchor.fa \
    Q25L120K61/anchor/pe.anchor.fa \
    Q25L120K81/anchor/pe.anchor.fa \
    Q25L120K101/anchor/pe.anchor.fa \
    Q25L120K121/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin Q25L120merge/anchor.contained.fasta
anchr orient Q25L120merge/anchor.contained.fasta --len 1000 --idt 0.98 -o Q25L120merge/anchor.orient.fasta
anchr merge Q25L120merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin Q25L120merge/anchor.merge.fasta

rm -fr 9_qa_kmer
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    Q25L60K41/anchor/pe.anchor.fa \
    Q25L60K61/anchor/pe.anchor.fa \
    Q25L60K81/anchor/pe.anchor.fa \
    Q25L60K101/anchor/pe.anchor.fa \
    Q25L60K121/anchor/pe.anchor.fa \
    Q25L120K41/anchor/pe.anchor.fa \
    Q25L120K61/anchor/pe.anchor.fa \
    Q25L120K81/anchor/pe.anchor.fa \
    Q25L120K101/anchor/pe.anchor.fa \
    Q25L120K121/anchor/pe.anchor.fa \
    Q25L60Kseries/anchor/pe.anchor.fa \
    Q25L120Kseries/anchor/pe.anchor.fa \
    Q25L60merge/anchor.merge.fasta \
    Q25L120merge/anchor.merge.fasta \
    1_genome/paralogs.fas \
    --label "Q25L60K41,Q25L60K61,Q25L60K81,Q25L60K101,Q25L60K121,Q25L120K41,Q25L120K61,Q25L120K81,Q25L120K101,Q25L120K121,Q25L60Kseries,Q25L120Kseries,Q25L60merge,Q25L120merge,paralogs" \
    -o 9_qa_kmer

```

## Merge anchors from different groups of reads

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

# merge anchors
mkdir -p mergeL60
anchr contained \
    Q20L60_1000000/anchor/pe.anchor.fa \
    Q20L60_1500000/anchor/pe.anchor.fa \
    Q20L60_2000000/anchor/pe.anchor.fa \
    Q25L60_1000000/anchor/pe.anchor.fa \
    Q25L60_1500000/anchor/pe.anchor.fa \
    Q25L60_2000000/anchor/pe.anchor.fa \
    Q25L60_2500000/anchor/pe.anchor.fa \
    Q25L60_3000000/anchor/pe.anchor.fa \
    Q30L60_1000000/anchor/pe.anchor.fa \
    Q30L60_1500000/anchor/pe.anchor.fa \
    Q30L60_2000000/anchor/pe.anchor.fa \
    Q30L60_2500000/anchor/pe.anchor.fa \
    Q30L60_3000000/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin mergeL60/anchor.contained.fasta
anchr orient mergeL60/anchor.contained.fasta --len 1000 --idt 0.98 -o mergeL60/anchor.orient.fasta
anchr merge mergeL60/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin mergeL60/anchor.merge.fasta

mkdir -p mergeL90
anchr contained \
    Q20L90_1000000/anchor/pe.anchor.fa \
    Q20L90_1500000/anchor/pe.anchor.fa \
    Q20L90_2000000/anchor/pe.anchor.fa \
    Q25L90_1000000/anchor/pe.anchor.fa \
    Q25L90_1500000/anchor/pe.anchor.fa \
    Q25L90_2000000/anchor/pe.anchor.fa \
    Q25L90_2500000/anchor/pe.anchor.fa \
    Q25L90_3000000/anchor/pe.anchor.fa \
    Q30L90_1000000/anchor/pe.anchor.fa \
    Q30L90_1500000/anchor/pe.anchor.fa \
    Q30L90_2000000/anchor/pe.anchor.fa \
    Q30L90_2500000/anchor/pe.anchor.fa \
    Q30L90_3000000/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin mergeL90/anchor.contained.fasta
anchr orient mergeL90/anchor.contained.fasta --len 1000 --idt 0.98 -o mergeL90/anchor.orient.fasta
anchr merge mergeL90/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin mergeL90/anchor.merge.fasta

mkdir -p mergeL120
anchr contained \
    Q20L120_1000000/anchor/pe.anchor.fa \
    Q20L120_1500000/anchor/pe.anchor.fa \
    Q20L120_2000000/anchor/pe.anchor.fa \
    Q25L120_1000000/anchor/pe.anchor.fa \
    Q25L120_1500000/anchor/pe.anchor.fa \
    Q25L120_2000000/anchor/pe.anchor.fa \
    Q25L120_2500000/anchor/pe.anchor.fa \
    Q25L120_3000000/anchor/pe.anchor.fa \
    Q30L120_1000000/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin mergeL120/anchor.contained.fasta
anchr orient mergeL120/anchor.contained.fasta --len 1000 --idt 0.98 -o mergeL120/anchor.orient.fasta
anchr merge mergeL120/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin mergeL120/anchor.merge.fasta

mkdir -p merge
anchr contained \
    Q20L60_1000000/anchor/pe.anchor.fa \
    Q20L60_1500000/anchor/pe.anchor.fa \
    Q20L60_2000000/anchor/pe.anchor.fa \
    Q20L90_1000000/anchor/pe.anchor.fa \
    Q20L90_1500000/anchor/pe.anchor.fa \
    Q20L90_2000000/anchor/pe.anchor.fa \
    Q25L60_1000000/anchor/pe.anchor.fa \
    Q25L60_1500000/anchor/pe.anchor.fa \
    Q25L60_2000000/anchor/pe.anchor.fa \
    Q25L60_2500000/anchor/pe.anchor.fa \
    Q25L60_3000000/anchor/pe.anchor.fa \
    Q25L90_1000000/anchor/pe.anchor.fa \
    Q25L90_1500000/anchor/pe.anchor.fa \
    Q25L90_2000000/anchor/pe.anchor.fa \
    Q25L90_2500000/anchor/pe.anchor.fa \
    Q25L90_3000000/anchor/pe.anchor.fa \
    Q30L60_1000000/anchor/pe.anchor.fa \
    Q30L60_1500000/anchor/pe.anchor.fa \
    Q30L60_2000000/anchor/pe.anchor.fa \
    Q30L60_2500000/anchor/pe.anchor.fa \
    Q30L60_3000000/anchor/pe.anchor.fa \
    Q30L90_1000000/anchor/pe.anchor.fa \
    Q30L90_1500000/anchor/pe.anchor.fa \
    Q30L90_2000000/anchor/pe.anchor.fa \
    Q30L90_2500000/anchor/pe.anchor.fa \
    Q30L90_3000000/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
anchr contained \
    Q20L60_1000000/anchor/pe.others.fa \
    Q20L90_1000000/anchor/pe.others.fa \
    Q25L60_1000000/anchor/pe.others.fa \
    Q25L90_1000000/anchor/pe.others.fa \
    Q30L60_1000000/anchor/pe.others.fa \
    Q30L90_1000000/anchor/pe.others.fa \
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
    mergeL60/anchor.merge.fasta \
    mergeL90/anchor.merge.fasta \
    mergeL120/anchor.merge.fasta \
    merge/anchor.merge.fasta \
    1_genome/paralogs.fas \
    --label "mergeL60,mergeL90,mergeL120,merge,paralogs" \
    -o 9_qa

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
| anchor.merge |   95579 | 4564714 | 103 |
| others.merge |    1225 |    2242 |   2 |
| anchor.cover |   94389 | 4552209 | 100 |
| anchorLong   |  132686 | 4540198 |  62 |
| contigTrim   | 4594649 | 4636507 |   2 |

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
rm -fr original_*
```
