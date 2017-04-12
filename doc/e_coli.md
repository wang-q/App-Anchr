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
brew reinstall --build-from-source homebrew/versions/gnuplot4 
brew install homebrew/science/mummer        # mummer need gnuplot4

brew install homebrew/science/quast         # assembly quality assessment
quast --test                                # may recompile the bundled nucmer

brew install wang-q/tap/reaper              # tally for deduplication

# canu requires gnuplot 5 while mummer requires gnuplot 4
brew install canu

brew unlink gnuplot4
brew install gnuplot
brew unlink gnuplot

brew link gnuplot4
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
  [511145](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=511145&lvl=3&lin=f&keep=1&srchmode=1&unlock)
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
    --pair-by-offset --with-quality --nozip \
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
parallel --no-run-if-empty -j 6 "
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

ARRAY=( "2_illumina:original:4000000"
        "2_illumina/Q20L100:Q20L100:4000000"
        "2_illumina/Q20L110:Q20L110:4000000"
        "2_illumina/Q20L120:Q20L120:4000000"
        "2_illumina/Q20L130:Q20L130:3200000"
        "2_illumina/Q20L140:Q20L140:2400000"
        "2_illumina/Q20L150:Q20L150:2400000"
        "2_illumina/Q25L100:Q25L100:4000000"
        "2_illumina/Q25L110:Q25L110:3200000"
        "2_illumina/Q25L120:Q25L120:2800000"
        "2_illumina/Q25L130:Q25L130:2000000"
        "2_illumina/Q25L140:Q25L140:1200000"
        "2_illumina/Q25L150:Q25L150:1200000"
        "2_illumina/Q30L100:Q30L100:2400000"
        "2_illumina/Q30L110:Q30L110:2000000"
        "2_illumina/Q30L120:Q30L120:1200000"
        "2_illumina/Q30L130:Q30L130:400000")

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    GROUP_MAX=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[2];')
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    for count in $(perl -e 'print 400000 * $_, q{ } for 1 .. 10');
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
        for my $i ( 1 .. 10 ) {
            printf qq{%s_%d\n}, $n, ( 400000 * $i );
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
cd $HOME/data/anchr/e_coli

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
        for my $i ( 1 .. 10 ) {
            printf qq{%s_%d\n}, $n, ( 400000 * $i );
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
        for my $i ( 1 .. 10 ) {
            printf qq{%s_%d\n}, $n, ( 400000 * $i );
        }
    }
    ' \
    | parallel -k --no-run-if-empty -j 8 "
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
        for my $i ( 1 .. 10 ) {
            printf qq{%s_%d\n}, $n, ( 400000 * $i );
        }
    }
    ' \
    | parallel -k --no-run-if-empty -j 16 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

| Name             |   SumFq | CovFq | AvgRead | Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real |  SumKU | SumSR |   RunTime |
|:-----------------|--------:|------:|--------:|-----:|--------:|---------:|------:|------:|---------:|-------:|------:|----------:|
| original_400000  |  120.8M |  26.0 |     151 |   75 |  76.08M |  37.018% | 4.64M | 4.57M |     0.98 |  4.94M |     0 | 0:01'27'' |
| original_800000  |  241.6M |  52.1 |     151 |   75 | 153.19M |  36.593% | 4.64M | 4.64M |     1.00 |  5.58M |     0 | 0:02'08'' |
| original_1200000 |  362.4M |  78.1 |     151 |   75 | 231.29M |  36.177% | 4.64M | 4.72M |     1.02 |  6.49M |     0 | 0:03'04'' |
| original_1600000 |  483.2M | 104.1 |     151 |   75 | 309.73M |  35.900% | 4.64M | 4.83M |     1.04 |  7.61M |     0 | 0:03'44'' |
| original_2000000 |    604M | 130.1 |     151 |   75 | 389.03M |  35.591% | 4.64M | 4.94M |     1.06 |  8.95M |     0 | 0:04'20'' |
| original_2400000 |  724.8M | 156.2 |     151 |   75 | 469.08M |  35.282% | 4.64M | 5.08M |     1.09 | 10.67M |     0 | 0:05'35'' |
| original_2800000 |  845.6M | 182.2 |     151 |   75 |  549.2M |  35.052% | 4.64M | 5.22M |     1.12 | 12.87M |     0 | 0:07'13'' |
| original_3200000 |  966.4M | 208.2 |     151 |   75 |  630.1M |  34.799% | 4.64M | 5.38M |     1.16 |  15.8M |     0 | 0:07'59'' |
| original_3600000 |   1.09G | 234.2 |     151 |   75 | 711.81M |  34.528% | 4.64M | 5.56M |     1.20 | 19.81M |     0 | 0:08'25'' |
| original_4000000 |   1.21G | 260.3 |     151 |   75 | 793.52M |  34.311% | 4.64M | 5.74M |     1.24 | 24.98M |     0 | 0:09'27'' |
| Q20L100_400000   |  115.1M |  24.8 |     144 |  101 |  99.85M |  13.251% | 4.64M | 4.55M |     0.98 |  4.86M |     0 | 0:01'30'' |
| Q20L100_800000   |  230.2M |  49.6 |     145 |  101 | 199.82M |  13.199% | 4.64M | 4.56M |     0.98 |  4.73M |     0 | 0:02'12'' |
| Q20L100_1200000  | 345.29M |  74.4 |     146 |  105 | 299.55M |  13.247% | 4.64M | 4.56M |     0.98 |  4.73M |     0 | 0:03'02'' |
| Q20L100_1600000  | 460.37M |  99.2 |     146 |  105 | 399.61M |  13.197% | 4.64M | 4.57M |     0.98 |  4.76M |     0 | 0:03'35'' |
| Q20L100_2000000  | 575.43M | 124.0 |     147 |  105 | 499.47M |  13.201% | 4.64M | 4.58M |     0.99 |  4.85M |     0 | 0:04'18'' |
| Q20L100_2400000  | 690.54M | 148.8 |     148 |  105 | 599.83M |  13.137% | 4.64M | 4.59M |     0.99 |  4.95M |     0 | 0:06'06'' |
| Q20L100_2800000  | 805.61M | 173.6 |     148 |  105 | 699.86M |  13.127% | 4.64M |  4.6M |     0.99 |  5.06M |     0 | 0:06'04'' |
| Q20L100_3200000  | 920.77M | 198.4 |     149 |  105 | 800.48M |  13.063% | 4.64M | 4.61M |     0.99 |  5.21M |     0 | 0:07'37'' |
| Q20L100_3600000  |   1.04G | 223.2 |     149 |  105 | 900.68M |  13.049% | 4.64M | 4.63M |     1.00 |  5.37M |     0 | 0:07'49'' |
| Q20L100_4000000  |   1.15G | 248.0 |     150 |  105 |      1G |  13.020% | 4.64M | 4.64M |     1.00 |  5.54M |     0 | 0:08'34'' |
| Q20L110_400000   | 116.29M |  25.1 |     146 |  105 | 100.98M |  13.168% | 4.64M | 4.55M |     0.98 |  4.94M |     0 | 0:01'21'' |
| Q20L110_800000   | 232.56M |  50.1 |     147 |  105 | 201.86M |  13.199% | 4.64M | 4.56M |     0.98 |  4.74M |     0 | 0:01'59'' |
| Q20L110_1200000  | 348.84M |  75.2 |     147 |  105 | 302.86M |  13.180% | 4.64M | 4.56M |     0.98 |  4.72M |     0 | 0:03'22'' |
| Q20L110_1600000  | 465.11M | 100.2 |     147 |  105 | 403.85M |  13.169% | 4.64M | 4.57M |     0.98 |  4.77M |     0 | 0:03'57'' |
| Q20L110_2000000  | 581.41M | 125.3 |     148 |  105 | 504.96M |  13.148% | 4.64M | 4.58M |     0.99 |  4.84M |     0 | 0:04'37'' |
| Q20L110_2400000  | 697.67M | 150.3 |     148 |  105 | 606.34M |  13.090% | 4.64M | 4.58M |     0.99 |  4.94M |     0 | 0:05'25'' |
| Q20L110_2800000  | 813.98M | 175.4 |     149 |  105 |  707.6M |  13.068% | 4.64M |  4.6M |     0.99 |  5.06M |     0 | 0:05'52'' |
| Q20L110_3200000  | 930.24M | 200.4 |     149 |  105 |  809.1M |  13.023% | 4.64M | 4.61M |     0.99 |  5.19M |     0 | 0:07'40'' |
| Q20L110_3600000  |   1.05G | 225.5 |     150 |  105 | 910.62M |  12.988% | 4.64M | 4.62M |     1.00 |  5.36M |     0 | 0:08'21'' |
| Q20L110_4000000  |   1.16G | 250.5 |     150 |  105 |   1.01G |  12.956% | 4.64M | 4.64M |     1.00 |  5.54M |     0 | 0:08'51'' |
| Q20L120_400000   | 117.59M |  25.3 |     147 |  105 |  102.2M |  13.088% | 4.64M | 4.54M |     0.98 |   4.9M |     0 | 0:01'19'' |
| Q20L120_800000   | 235.18M |  50.7 |     148 |  105 | 204.21M |  13.168% | 4.64M | 4.55M |     0.98 |  4.72M |     0 | 0:02'32'' |
| Q20L120_1200000  | 352.79M |  76.0 |     148 |  105 | 306.39M |  13.152% | 4.64M | 4.56M |     0.98 |  4.72M |     0 | 0:02'56'' |
| Q20L120_1600000  | 470.39M | 101.3 |     148 |  105 |  408.6M |  13.136% | 4.64M | 4.57M |     0.98 |  4.76M |     0 | 0:04'10'' |
| Q20L120_2000000  | 587.95M | 126.7 |     149 |  105 | 511.09M |  13.073% | 4.64M | 4.57M |     0.99 |  4.82M |     0 | 0:04'42'' |
| Q20L120_2400000  | 705.53M | 152.0 |     149 |  105 | 613.43M |  13.054% | 4.64M | 4.58M |     0.99 |  4.92M |     0 | 0:05'57'' |
| Q20L120_2800000  | 823.15M | 177.3 |     149 |  105 | 715.88M |  13.032% | 4.64M | 4.59M |     0.99 |  5.03M |     0 | 0:06'20'' |
| Q20L120_3200000  | 940.72M | 202.7 |     150 |  105 | 818.45M |  12.997% | 4.64M |  4.6M |     0.99 |  5.18M |     0 | 0:08'20'' |
| Q20L120_3600000  |   1.06G | 228.0 |     150 |  105 | 921.12M |  12.964% | 4.64M | 4.62M |     0.99 |  5.33M |     0 | 0:08'49'' |
| Q20L120_4000000  |   1.14G | 244.6 |     150 |  105 | 988.43M |  12.937% | 4.64M | 4.63M |     1.00 |  5.44M |     0 | 0:08'29'' |
| Q20L130_400000   | 119.16M |  25.7 |     149 |  105 | 103.46M |  13.174% | 4.64M | 4.52M |     0.97 |  4.86M |     0 | 0:01'24'' |
| Q20L130_800000   | 238.31M |  51.3 |     149 |  105 | 206.89M |  13.187% | 4.64M | 4.55M |     0.98 |  4.71M |     0 | 0:02'17'' |
| Q20L130_1200000  | 357.47M |  77.0 |     149 |  105 | 310.43M |  13.161% | 4.64M | 4.56M |     0.98 |  4.72M |     0 | 0:03'11'' |
| Q20L130_1600000  | 476.64M | 102.7 |     150 |  105 | 413.96M |  13.149% | 4.64M | 4.56M |     0.98 |  4.76M |     0 | 0:04'08'' |
| Q20L130_2000000  |  595.8M | 128.4 |     150 |  105 | 517.49M |  13.144% | 4.64M | 4.57M |     0.98 |  4.81M |     0 | 0:05'00'' |
| Q20L130_2400000  | 714.96M | 154.0 |     150 |  105 | 621.14M |  13.123% | 4.64M | 4.58M |     0.99 |   4.9M |     0 | 0:05'43'' |
| Q20L130_2800000  | 834.11M | 179.7 |     150 |  105 | 725.03M |  13.078% | 4.64M | 4.59M |     0.99 |  5.01M |     0 | 0:07'13'' |
| Q20L130_3200000  | 953.27M | 205.4 |     150 |  105 | 828.96M |  13.040% | 4.64M |  4.6M |     0.99 |  5.13M |     0 | 0:07'13'' |
| Q20L140_400000   | 120.61M |  26.0 |     150 |  105 | 104.44M |  13.404% | 4.64M | 4.48M |     0.97 |  4.82M |     0 | 0:01'34'' |
| Q20L140_800000   | 241.21M |  52.0 |     150 |  105 |    209M |  13.355% | 4.64M | 4.53M |     0.98 |  4.71M |     0 | 0:02'20'' |
| Q20L140_1200000  | 361.82M |  78.0 |     150 |  105 | 313.43M |  13.375% | 4.64M | 4.55M |     0.98 |  4.71M |     0 | 0:03'08'' |
| Q20L140_1600000  | 482.42M | 103.9 |     150 |  105 | 418.14M |  13.325% | 4.64M | 4.55M |     0.98 |  4.75M |     0 | 0:04'08'' |
| Q20L140_2000000  | 603.03M | 129.9 |     150 |  105 | 522.93M |  13.283% | 4.64M | 4.56M |     0.98 |  4.81M |     0 | 0:04'42'' |
| Q20L140_2400000  | 723.64M | 155.9 |     150 |  105 | 627.59M |  13.272% | 4.64M | 4.57M |     0.98 |  4.88M |     0 | 0:06'09'' |
| Q20L150_400000   |  120.8M |  26.0 |     150 |  105 | 104.73M |  13.299% | 4.64M | 4.47M |     0.96 |  4.81M |     0 | 0:01'29'' |
| Q20L150_800000   |  241.6M |  52.1 |     150 |  105 | 209.46M |  13.304% | 4.64M | 4.53M |     0.98 |  4.71M |     0 | 0:02'12'' |
| Q20L150_1200000  |  362.4M |  78.1 |     151 |  105 | 314.26M |  13.283% | 4.64M | 4.54M |     0.98 |  4.72M |     0 | 0:03'10'' |
| Q20L150_1600000  |  483.2M | 104.1 |     150 |  105 | 419.06M |  13.274% | 4.64M | 4.55M |     0.98 |  4.75M |     0 | 0:04'07'' |
| Q20L150_2000000  |    604M | 130.1 |     150 |  105 | 523.84M |  13.271% | 4.64M | 4.56M |     0.98 |  4.79M |     0 | 0:04'44'' |
| Q20L150_2400000  |  724.8M | 156.2 |     150 |  105 | 628.95M |  13.224% | 4.64M | 4.57M |     0.98 |  4.88M |     0 | 0:05'56'' |
| Q25L100_400000   | 111.37M |  24.0 |     141 |   91 | 104.81M |   5.892% | 4.64M | 4.54M |     0.98 |  4.75M |     0 | 0:01'19'' |
| Q25L100_800000   | 222.78M |  48.0 |     142 |   91 | 209.64M |   5.897% | 4.64M | 4.55M |     0.98 |  4.67M |     0 | 0:02'29'' |
| Q25L100_1200000  | 334.14M |  72.0 |     143 |   91 | 314.44M |   5.896% | 4.64M | 4.56M |     0.98 |  4.67M |     0 | 0:03'05'' |
| Q25L100_1600000  | 445.53M |  96.0 |     144 |   93 | 419.28M |   5.891% | 4.64M | 4.56M |     0.98 |  4.67M |     0 | 0:03'51'' |
| Q25L100_2000000  | 556.97M | 120.0 |     145 |   93 | 524.22M |   5.880% | 4.64M | 4.56M |     0.98 |  4.67M |     0 | 0:04'56'' |
| Q25L100_2400000  | 668.29M | 144.0 |     146 |   93 | 628.94M |   5.888% | 4.64M | 4.56M |     0.98 |  4.68M |     0 | 0:05'06'' |
| Q25L100_2800000  | 779.67M | 168.0 |     147 |   95 | 733.87M |   5.874% | 4.64M | 4.56M |     0.98 |  4.68M |     0 | 0:07'33'' |
| Q25L100_3200000  | 891.04M | 192.0 |     148 |   95 | 838.62M |   5.883% | 4.64M | 4.57M |     0.98 |   4.7M |     0 | 0:07'28'' |
| Q25L100_3600000  |      1G | 216.0 |     149 |   95 | 943.49M |   5.880% | 4.64M | 4.57M |     0.98 |  4.71M |     0 | 0:08'31'' |
| Q25L100_4000000  |   1.09G | 235.9 |     150 |   95 |   1.03G |   5.877% | 4.64M | 4.57M |     0.98 |  4.72M |     0 | 0:09'07'' |
| Q25L110_400000   | 113.26M |  24.4 |     143 |   93 | 106.46M |   5.997% | 4.64M | 4.53M |     0.98 |  4.76M |     0 | 0:01'28'' |
| Q25L110_800000   | 226.49M |  48.8 |     144 |   93 | 212.93M |   5.987% | 4.64M | 4.55M |     0.98 |  4.68M |     0 | 0:02'21'' |
| Q25L110_1200000  | 339.76M |  73.2 |     145 |   93 | 319.54M |   5.951% | 4.64M | 4.56M |     0.98 |  4.67M |     0 | 0:03'03'' |
| Q25L110_1600000  | 453.02M |  97.6 |     146 |   93 | 425.93M |   5.980% | 4.64M | 4.56M |     0.98 |  4.67M |     0 | 0:03'34'' |
| Q25L110_2000000  | 566.27M | 122.0 |     147 |   95 | 532.38M |   5.985% | 4.64M | 4.56M |     0.98 |  4.68M |     0 | 0:04'23'' |
| Q25L110_2400000  | 679.51M | 146.4 |     147 |   95 | 639.03M |   5.957% | 4.64M | 4.56M |     0.98 |  4.68M |     0 | 0:05'10'' |
| Q25L110_2800000  | 792.76M | 170.8 |     148 |   97 | 745.57M |   5.954% | 4.64M | 4.56M |     0.98 |  4.69M |     0 | 0:07'19'' |
| Q25L110_3200000  | 906.03M | 195.2 |     149 |   97 | 852.07M |   5.955% | 4.64M | 4.56M |     0.98 |   4.7M |     0 | 0:07'31'' |
| Q25L120_400000   | 115.35M |  24.9 |     145 |   95 | 108.32M |   6.093% | 4.64M | 4.51M |     0.97 |  4.75M |     0 | 0:01'59'' |
| Q25L120_800000   |  230.7M |  49.7 |     146 |   95 | 216.67M |   6.082% | 4.64M | 4.54M |     0.98 |  4.68M |     0 | 0:02'05'' |
| Q25L120_1200000  | 346.06M |  74.6 |     147 |   97 |  324.9M |   6.114% | 4.64M | 4.55M |     0.98 |  4.68M |     0 | 0:03'44'' |
| Q25L120_1600000  | 461.39M |  99.4 |     147 |   99 |  433.3M |   6.088% | 4.64M | 4.56M |     0.98 |  4.69M |     0 | 0:03'48'' |
| Q25L120_2000000  | 576.73M | 124.3 |     148 |   99 | 541.55M |   6.099% | 4.64M | 4.56M |     0.98 |  4.69M |     0 | 0:04'43'' |
| Q25L120_2400000  | 692.07M | 149.1 |     149 |  101 | 649.92M |   6.092% | 4.64M | 4.56M |     0.98 |   4.7M |     0 | 0:04'54'' |
| Q25L120_2800000  | 807.43M | 174.0 |     150 |  105 | 758.23M |   6.093% | 4.64M | 4.56M |     0.98 |  4.72M |     0 | 0:08'50'' |
| Q25L130_400000   | 117.89M |  25.4 |     148 |  105 | 110.33M |   6.407% | 4.64M | 4.47M |     0.96 |  4.88M |     0 | 0:01'21'' |
| Q25L130_800000   | 235.77M |  50.8 |     148 |  105 | 220.68M |   6.400% | 4.64M | 4.53M |     0.98 |  4.75M |     0 | 0:03'00'' |
| Q25L130_1200000  | 353.65M |  76.2 |     149 |  105 | 330.94M |   6.420% | 4.64M | 4.54M |     0.98 |  4.72M |     0 | 0:03'18'' |
| Q25L130_1600000  | 471.52M | 101.6 |     149 |  105 | 441.38M |   6.393% | 4.64M | 4.55M |     0.98 |  4.71M |     0 | 0:03'55'' |
| Q25L130_2000000  | 589.42M | 127.0 |     150 |  105 | 551.77M |   6.387% | 4.64M | 4.55M |     0.98 |  4.71M |     0 | 0:04'44'' |
| Q25L140_400000   | 120.38M |  25.9 |     150 |  105 | 111.97M |   6.984% | 4.64M | 4.36M |     0.94 |  4.74M |     0 | 0:01'15'' |
| Q25L140_800000   | 240.76M |  51.9 |     150 |  105 | 224.12M |   6.911% | 4.64M | 4.48M |     0.96 |  4.72M |     0 | 0:02'08'' |
| Q25L140_1200000  | 361.14M |  77.8 |     150 |  105 | 336.23M |   6.898% | 4.64M | 4.51M |     0.97 |  4.71M |     0 | 0:03'03'' |
| Q25L150_400000   |  120.8M |  26.0 |     150 |  105 | 112.24M |   7.083% | 4.64M | 4.32M |     0.93 |   4.7M |     0 | 0:01'21'' |
| Q25L150_800000   |  241.6M |  52.1 |     151 |  105 | 224.64M |   7.021% | 4.64M | 4.46M |     0.96 |  4.71M |     0 | 0:02'11'' |
| Q25L150_1200000  |  362.4M |  78.1 |     151 |  105 | 336.95M |   7.022% | 4.64M |  4.5M |     0.97 |  4.71M |     0 | 0:03'08'' |
| Q30L100_400000   | 104.59M |  22.5 |     133 |   83 | 101.98M |   2.504% | 4.64M | 4.51M |     0.97 |  4.76M |     0 | 0:01'18'' |
| Q30L100_800000   | 209.24M |  45.1 |     135 |   83 | 204.02M |   2.492% | 4.64M | 4.54M |     0.98 |  4.69M |     0 | 0:02'02'' |
| Q30L100_1200000  | 313.86M |  67.6 |     137 |   85 |    306M |   2.504% | 4.64M | 4.55M |     0.98 |  4.69M |     0 | 0:02'48'' |
| Q30L100_1600000  | 418.46M |  90.2 |     139 |   85 | 407.96M |   2.508% | 4.64M | 4.55M |     0.98 |  4.68M |     0 | 0:03'26'' |
| Q30L100_2000000  | 523.07M | 112.7 |     141 |   85 | 510.01M |   2.497% | 4.64M | 4.56M |     0.98 |  4.67M |     0 | 0:04'19'' |
| Q30L100_2400000  | 627.69M | 135.2 |     143 |   85 | 611.99M |   2.501% | 4.64M | 4.56M |     0.98 |  4.67M |     0 | 0:05'02'' |
| Q30L110_400000   | 107.83M |  23.2 |     137 |   87 | 105.05M |   2.576% | 4.64M | 4.47M |     0.96 |  4.75M |     0 | 0:01'24'' |
| Q30L110_800000   | 215.61M |  46.5 |     139 |   87 | 210.05M |   2.578% | 4.64M | 4.53M |     0.98 |   4.7M |     0 | 0:02'14'' |
| Q30L110_1200000  | 323.41M |  69.7 |     141 |   87 |  315.1M |   2.569% | 4.64M | 4.54M |     0.98 |  4.69M |     0 | 0:02'54'' |
| Q30L110_1600000  | 431.21M |  92.9 |     143 |   89 | 420.08M |   2.581% | 4.64M | 4.55M |     0.98 |  4.69M |     0 | 0:04'35'' |
| Q30L110_2000000  |    539M | 116.1 |     145 |   89 | 525.12M |   2.576% | 4.64M | 4.55M |     0.98 |  4.69M |     0 | 0:05'24'' |
| Q30L120_400000   | 111.31M |  24.0 |     141 |   91 | 108.23M |   2.768% | 4.64M |  4.4M |     0.95 |  4.73M |     0 | 0:01'48'' |
| Q30L120_800000   | 222.62M |  48.0 |     143 |   91 | 216.62M |   2.694% | 4.64M |  4.5M |     0.97 |  4.71M |     0 | 0:02'50'' |
| Q30L120_1200000  | 333.93M |  71.9 |     145 |   91 | 324.94M |   2.694% | 4.64M | 4.52M |     0.97 |   4.7M |     0 | 0:03'32'' |
| Q30L130_400000   |  115.5M |  24.9 |     146 |   95 | 111.95M |   3.078% | 4.64M |  4.2M |     0.91 |  4.57M |     0 | 0:01'37'' |

| Name             | N50SRclean |    Sum |      # | N50Anchor |     Sum |    # | N50Anchor2 |    Sum |  # | N50Others |     Sum |      # |   RunTime |
|:-----------------|-----------:|-------:|-------:|----------:|--------:|-----:|-----------:|-------:|---:|----------:|--------:|-------:|----------:|
| original_400000  |       2975 |  4.94M |   5517 |      3732 |   4.01M | 1322 |       1371 | 77.99K | 57 |       466 | 853.04K |   4138 | 0:01'32'' |
| original_800000  |       1578 |  5.58M |  12914 |      2352 |   3.63M | 1653 |       1275 |  26.5K | 21 |       358 |   1.92M |  11240 | 0:02'06'' |
| original_1200000 |        855 |  6.49M |  24289 |      1832 |   2.85M | 1591 |       1280 |  8.68K |  7 |       285 |   3.63M |  22691 | 0:02'22'' |
| original_1600000 |        490 |  7.61M |  38222 |      1590 |   2.18M | 1335 |       1447 |  2.79K |  2 |       183 |   5.43M |  36885 | 0:02'57'' |
| original_2000000 |        269 |  8.95M |  54953 |      1490 |   1.58M | 1042 |          0 |      0 |  0 |       125 |   7.36M |  53911 | 0:02'53'' |
| original_2400000 |        127 | 10.67M |  76590 |      1449 |   1.15M |  772 |          0 |      0 |  0 |       100 |   9.52M |  75818 | 0:03'12'' |
| original_2800000 |         97 | 12.87M | 104203 |      1341 | 849.67K |  605 |          0 |      0 |  0 |        92 |  12.02M | 103598 | 0:03'16'' |
| original_3200000 |         90 |  15.8M | 141238 |      1342 | 614.89K |  441 |          0 |      0 |  0 |        88 |  15.18M | 140797 | 0:03'41'' |
| original_3600000 |         85 | 19.81M | 192540 |      1314 | 416.39K |  310 |          0 |      0 |  0 |        85 |   19.4M | 192230 | 0:03'39'' |
| original_4000000 |         82 | 24.98M | 259046 |      1264 | 293.79K |  223 |          0 |      0 |  0 |        82 |  24.69M | 258823 | 0:04'01'' |
| Q20L100_400000   |       2452 |  4.86M |   4271 |      3217 |   3.84M | 1455 |       1255 |  7.29K |  6 |       553 |   1.01M |   2810 | 0:01'25'' |
| Q20L100_800000   |       7642 |  4.73M |   1848 |      8047 |   4.47M |  794 |          0 |      0 |  0 |       283 | 258.33K |   1054 | 0:01'48'' |
| Q20L100_1200000  |       9020 |  4.73M |   1643 |      9323 |    4.5M |  689 |          0 |      0 |  0 |       262 |  221.6K |    954 | 0:02'18'' |
| Q20L100_1600000  |       9476 |  4.76M |   1878 |      9830 |   4.51M |  675 |          0 |      0 |  0 |       209 | 248.23K |   1203 | 0:02'59'' |
| Q20L100_2000000  |       7119 |  4.85M |   2621 |      7737 |   4.51M |  833 |          0 |      0 |  0 |       195 | 340.97K |   1788 | 0:03'17'' |
| Q20L100_2400000  |       5491 |  4.95M |   3442 |      6137 |   4.48M | 1003 |          0 |      0 |  0 |       180 | 468.99K |   2439 | 0:03'43'' |
| Q20L100_2800000  |       4341 |  5.06M |   4362 |      4855 |   4.44M | 1176 |          0 |      0 |  0 |       181 | 622.11K |   3186 | 0:03'43'' |
| Q20L100_3200000  |       3212 |  5.21M |   5662 |      3952 |   4.37M | 1396 |          0 |      0 |  0 |       181 | 834.96K |   4266 | 0:03'54'' |
| Q20L100_3600000  |       2550 |  5.37M |   7050 |      3264 |   4.23M | 1563 |          0 |      0 |  0 |       218 |   1.14M |   5487 | 0:04'14'' |
| Q20L100_4000000  |       2034 |  5.54M |   8568 |      2695 |   4.08M | 1704 |          0 |      0 |  0 |       265 |   1.46M |   6864 | 0:04'40'' |
| Q20L110_400000   |       1921 |  4.94M |   5287 |      2595 |   3.59M | 1553 |       1372 |   2.5K |  2 |       532 |   1.34M |   3732 | 0:01'35'' |
| Q20L110_800000   |       6550 |  4.74M |   2038 |      7136 |   4.44M |  898 |          0 |      0 |  0 |       323 | 303.94K |   1140 | 0:01'50'' |
| Q20L110_1200000  |       9414 |  4.72M |   1643 |      9777 |   4.49M |  685 |          0 |      0 |  0 |       271 | 230.13K |    958 | 0:02'22'' |
| Q20L110_1600000  |       8500 |  4.77M |   1961 |      9065 |   4.52M |  732 |          0 |      0 |  0 |       209 | 252.04K |   1229 | 0:02'53'' |
| Q20L110_2000000  |       7369 |  4.84M |   2497 |      7759 |   4.51M |  827 |          0 |      0 |  0 |       197 | 325.39K |   1670 | 0:03'10'' |
| Q20L110_2400000  |       5621 |  4.94M |   3342 |      6163 |   4.48M |  995 |          0 |      0 |  0 |       191 | 455.63K |   2347 | 0:03'51'' |
| Q20L110_2800000  |       4043 |  5.06M |   4378 |      4698 |   4.45M | 1229 |          0 |      0 |  0 |       178 |  607.7K |   3149 | 0:03'38'' |
| Q20L110_3200000  |       3304 |  5.19M |   5549 |      3897 |   4.36M | 1384 |          0 |      0 |  0 |       207 | 837.01K |   4165 | 0:04'07'' |
| Q20L110_3600000  |       2532 |  5.36M |   6987 |      3211 |   4.22M | 1575 |          0 |      0 |  0 |       242 |   1.14M |   5412 | 0:04'06'' |
| Q20L110_4000000  |       1989 |  5.54M |   8534 |      2661 |   4.08M | 1720 |          0 |      0 |  0 |       270 |   1.46M |   6814 | 0:04'39'' |
| Q20L120_400000   |       2028 |   4.9M |   5056 |      2745 |   3.59M | 1491 |       1261 |  2.49K |  2 |       549 |    1.3M |   3563 | 0:01'29'' |
| Q20L120_800000   |       6563 |  4.72M |   1935 |      7147 |    4.4M |  900 |          0 |      0 |  0 |       470 | 316.89K |   1035 | 0:01'52'' |
| Q20L120_1200000  |       8212 |  4.72M |   1701 |      8632 |   4.48M |  763 |          0 |      0 |  0 |       286 | 236.04K |    938 | 0:02'22'' |
| Q20L120_1600000  |       7996 |  4.76M |   1912 |      8419 |   4.49M |  744 |          0 |      0 |  0 |       242 | 262.68K |   1168 | 0:02'40'' |
| Q20L120_2000000  |       6809 |  4.82M |   2460 |      7163 |    4.5M |  860 |          0 |      0 |  0 |       209 | 329.67K |   1600 | 0:03'12'' |
| Q20L120_2400000  |       5492 |  4.92M |   3230 |      5963 |   4.47M | 1015 |          0 |      0 |  0 |       209 | 447.09K |   2215 | 0:03'36'' |
| Q20L120_2800000  |       4216 |  5.03M |   4213 |      4819 |   4.43M | 1200 |          0 |      0 |  0 |       208 | 605.74K |   3013 | 0:03'39'' |
| Q20L120_3200000  |       3303 |  5.18M |   5437 |      3953 |   4.33M | 1378 |          0 |      0 |  0 |       221 | 845.67K |   4059 | 0:04'01'' |
| Q20L120_3600000  |       2544 |  5.33M |   6792 |      3217 |   4.23M | 1572 |          0 |      0 |  0 |       245 |   1.11M |   5220 | 0:04'14'' |
| Q20L120_4000000  |       2160 |  5.44M |   7745 |      2861 |   4.14M | 1666 |          0 |      0 |  0 |       271 |   1.31M |   6079 | 0:04'30'' |
| Q20L130_400000   |       1977 |  4.86M |   5090 |      2752 |   3.53M | 1445 |       1108 |  1.11K |  1 |       547 |   1.33M |   3644 | 0:01'34'' |
| Q20L130_800000   |       5728 |  4.71M |   2148 |      6149 |   4.34M |  988 |          0 |      0 |  0 |       491 | 369.06K |   1160 | 0:01'46'' |
| Q20L130_1200000  |       7490 |  4.72M |   1831 |      7998 |   4.44M |  806 |          0 |      0 |  0 |       330 | 273.57K |   1025 | 0:02'26'' |
| Q20L130_1600000  |       7038 |  4.76M |   2092 |      7487 |   4.47M |  846 |       1288 |  1.29K |  1 |       276 | 293.45K |   1245 | 0:02'44'' |
| Q20L130_2000000  |       6615 |  4.81M |   2431 |      6924 |   4.48M |  880 |          0 |      0 |  0 |       227 | 334.46K |   1551 | 0:03'06'' |
| Q20L130_2400000  |       5221 |   4.9M |   3198 |      5646 |   4.44M | 1022 |          0 |      0 |  0 |       219 | 456.79K |   2176 | 0:03'39'' |
| Q20L130_2800000  |       4126 |  5.01M |   4119 |      4745 |    4.4M | 1207 |          0 |      0 |  0 |       225 | 609.63K |   2912 | 0:03'51'' |
| Q20L130_3200000  |       3402 |  5.13M |   5175 |      3966 |   4.33M | 1370 |          0 |      0 |  0 |       244 | 799.79K |   3805 | 0:03'53'' |
| Q20L140_400000   |       1803 |  4.82M |   5512 |      2645 |   3.34M | 1421 |       1225 |  9.75K |  8 |       540 |   1.47M |   4083 | 0:01'30'' |
| Q20L140_800000   |       4490 |  4.71M |   2559 |      5091 |   4.22M | 1115 |          0 |      0 |  0 |       531 | 490.84K |   1444 | 0:01'50'' |
| Q20L140_1200000  |       5975 |  4.71M |   2132 |      6599 |   4.35M |  923 |          0 |      0 |  0 |       469 | 364.89K |   1209 | 0:02'25'' |
| Q20L140_1600000  |       6209 |  4.75M |   2229 |      6689 |   4.39M |  911 |       1084 |  1.08K |  1 |       410 | 353.95K |   1317 | 0:02'38'' |
| Q20L140_2000000  |       5768 |  4.81M |   2639 |      6255 |   4.42M |  980 |       1061 |  1.06K |  1 |       281 | 386.26K |   1658 | 0:03'01'' |
| Q20L140_2400000  |       4787 |  4.88M |   3236 |      5208 |   4.41M | 1103 |          0 |      0 |  0 |       266 | 473.38K |   2133 | 0:10'35'' |
| Q20L150_400000   |       1817 |  4.81M |   5671 |      2628 |    3.3M | 1392 |       1174 |  6.04K |  5 |       528 |    1.5M |   4274 | 0:02'19'' |
| Q20L150_800000   |       4366 |  4.71M |   2679 |      5070 |   4.17M | 1119 |       1251 |  2.36K |  2 |       546 | 539.69K |   1558 | 0:03'25'' |
| Q20L150_1200000  |       5624 |  4.72M |   2237 |      6191 |   4.33M |  973 |          0 |      0 |  0 |       485 | 389.39K |   1264 | 0:04'33'' |
| Q20L150_1600000  |       5862 |  4.75M |   2286 |      6345 |   4.39M |  958 |       1112 |  1.11K |  1 |       406 | 357.13K |   1327 | 0:06'00'' |
| Q20L150_2000000  |       5842 |  4.79M |   2582 |      6381 |   4.39M |  964 |          0 |      0 |  0 |       348 | 399.13K |   1618 | 0:05'04'' |
| Q20L150_2400000  |       4758 |  4.88M |   3257 |      5353 |   4.37M | 1086 |          0 |      0 |  0 |       305 | 504.68K |   2171 | 0:03'29'' |
| Q25L100_400000   |       3257 |  4.75M |   3365 |      3881 |   4.03M | 1290 |       1139 |  1.14K |  1 |       560 | 723.53K |   2074 | 0:01'20'' |
| Q25L100_800000   |       8587 |  4.67M |   1543 |      8837 |   4.45M |  739 |          0 |      0 |  0 |       425 | 222.89K |    804 | 0:01'51'' |
| Q25L100_1200000  |      10659 |  4.67M |   1275 |     10925 |   4.51M |  611 |          0 |      0 |  0 |       272 | 160.57K |    664 | 0:02'24'' |
| Q25L100_1600000  |      12503 |  4.67M |   1206 |     13089 |   4.51M |  545 |          0 |      0 |  0 |       248 | 154.46K |    661 | 0:02'43'' |
| Q25L100_2000000  |      14881 |  4.67M |   1175 |     15451 |   4.51M |  487 |          0 |      0 |  0 |       254 | 159.11K |    688 | 0:03'06'' |
| Q25L100_2400000  |      15451 |  4.68M |   1180 |     15952 |   4.52M |  466 |          0 |      0 |  0 |       234 | 154.07K |    714 | 0:03'40'' |
| Q25L100_2800000  |      16043 |  4.68M |   1216 |     16318 |   4.53M |  483 |          0 |      0 |  0 |       224 | 154.02K |    733 | 0:04'08'' |
| Q25L100_3200000  |      13359 |   4.7M |   1340 |     13938 |   4.53M |  512 |          0 |      0 |  0 |       197 | 164.12K |    828 | 0:04'06'' |
| Q25L100_3600000  |      12429 |  4.71M |   1436 |     13580 |   4.53M |  525 |          0 |      0 |  0 |       189 | 176.94K |    911 | 0:04'48'' |
| Q25L100_4000000  |      11825 |  4.72M |   1531 |     12354 |   4.53M |  542 |          0 |      0 |  0 |       189 |  189.7K |    989 | 0:04'48'' |
| Q25L110_400000   |       2922 |  4.76M |   3711 |      3580 |   3.93M | 1352 |       1114 |  2.17K |  2 |       549 |  821.8K |   2357 | 0:01'19'' |
| Q25L110_800000   |       7200 |  4.68M |   1733 |      7605 |   4.42M |  832 |          0 |      0 |  0 |       447 |  260.7K |    901 | 0:01'56'' |
| Q25L110_1200000  |       9375 |  4.67M |   1429 |     10000 |   4.48M |  691 |          0 |      0 |  0 |       289 | 190.35K |    738 | 0:02'30'' |
| Q25L110_1600000  |      11384 |  4.67M |   1294 |     11884 |   4.49M |  596 |       1305 |  1.31K |  1 |       276 | 174.05K |    697 | 0:02'46'' |
| Q25L110_2000000  |      11980 |  4.68M |   1309 |     12164 |   4.51M |  587 |          0 |      0 |  0 |       257 | 169.83K |    722 | 0:03'33'' |
| Q25L110_2400000  |      12827 |  4.68M |   1293 |     13429 |   4.51M |  553 |          0 |      0 |  0 |       256 | 169.49K |    740 | 0:03'42'' |
| Q25L110_2800000  |      12280 |  4.69M |   1351 |     12667 |   4.51M |  552 |          0 |      0 |  0 |       243 |  178.4K |    799 | 0:04'00'' |
| Q25L110_3200000  |      11410 |   4.7M |   1446 |     12060 |   4.52M |  581 |          0 |      0 |  0 |       230 | 185.77K |    865 | 0:04'13'' |
| Q25L120_400000   |       2567 |  4.75M |   4048 |      3258 |   3.81M | 1383 |       1143 |   2.2K |  2 |       528 |  943.2K |   2663 | 0:01'36'' |
| Q25L120_800000   |       5803 |  4.68M |   2020 |      6204 |   4.35M |  978 |          0 |      0 |  0 |       493 | 333.54K |   1042 | 0:01'46'' |
| Q25L120_1200000  |       7750 |  4.68M |   1655 |      8237 |   4.42M |  814 |          0 |      0 |  0 |       469 | 253.41K |    841 | 0:02'37'' |
| Q25L120_1600000  |       8264 |  4.69M |   1610 |      8720 |   4.45M |  777 |          0 |      0 |  0 |       417 | 236.43K |    833 | 0:02'42'' |
| Q25L120_2000000  |       9022 |  4.69M |   1513 |      9588 |   4.47M |  712 |          0 |      0 |  0 |       322 | 218.19K |    801 | 0:03'13'' |
| Q25L120_2400000  |       9044 |   4.7M |   1565 |      9464 |   4.48M |  715 |          0 |      0 |  0 |       292 | 220.31K |    850 | 0:04'01'' |
| Q25L120_2800000  |       8654 |  4.72M |   1674 |      8932 |   4.47M |  748 |          0 |      0 |  0 |       297 | 243.49K |    926 | 0:04'03'' |
| Q25L130_400000   |       1472 |  4.88M |   6770 |      2375 |   3.02M | 1370 |       1118 |  3.57K |  3 |       511 |   1.86M |   5397 | 0:01'40'' |
| Q25L130_800000   |       3547 |  4.75M |   3308 |      4193 |   4.05M | 1262 |          0 |      0 |  0 |       527 | 700.12K |   2046 | 0:01'53'' |
| Q25L130_1200000  |       4791 |  4.72M |   2448 |      5299 |   4.27M | 1104 |          0 |      0 |  0 |       525 | 447.94K |   1344 | 0:02'27'' |
| Q25L130_1600000  |       5957 |  4.71M |   2116 |      6357 |   4.35M |  962 |          0 |      0 |  0 |       476 | 364.67K |   1154 | 0:02'42'' |
| Q25L130_2000000  |       6406 |  4.71M |   2000 |      7046 |   4.37M |  909 |          0 |      0 |  0 |       491 | 338.81K |   1091 | 0:03'19'' |
| Q25L140_400000   |       1303 |  4.74M |   7132 |      2208 |   2.77M | 1314 |       1173 | 10.69K |  9 |       492 |   1.96M |   5809 | 0:01'33'' |
| Q25L140_800000   |       2546 |  4.72M |   4042 |      3287 |   3.73M | 1337 |       1239 |  2.39K |  2 |       558 | 987.19K |   2703 | 0:01'52'' |
| Q25L140_1200000  |       3499 |  4.71M |   3147 |      4140 |   4.04M | 1238 |       1256 |  1.26K |  1 |       547 | 672.44K |   1908 | 0:02'22'' |
| Q25L150_400000   |       1238 |   4.7M |   7384 |      2282 |   2.66M | 1253 |       1241 | 14.78K | 12 |       481 |   2.03M |   6119 | 0:01'32'' |
| Q25L150_800000   |       2436 |  4.71M |   4322 |      3140 |   3.65M | 1352 |       1315 |  6.48K |  5 |       541 |   1.05M |   2965 | 0:01'49'' |
| Q25L150_1200000  |       3097 |  4.71M |   3382 |      3887 |   3.96M | 1274 |          0 |      0 |  0 |       557 | 745.81K |   2108 | 0:02'19'' |
| Q30L100_400000   |       2092 |  4.76M |   4997 |      2838 |   3.57M | 1451 |       1233 |  2.31K |  2 |       524 |   1.19M |   3544 | 0:01'29'' |
| Q30L100_800000   |       4989 |  4.69M |   2443 |      5505 |   4.26M | 1060 |          0 |      0 |  0 |       508 | 431.06K |   1383 | 0:02'00'' |
| Q30L100_1200000  |       5992 |  4.69M |   2071 |      6487 |   4.35M |  946 |          0 |      0 |  0 |       496 | 338.74K |   1125 | 0:02'32'' |
| Q30L100_1600000  |       7132 |  4.68M |   1741 |      7598 |   4.42M |  836 |          0 |      0 |  0 |       463 | 253.85K |    905 | 0:03'00'' |
| Q30L100_2000000  |       8216 |  4.67M |   1618 |      8669 |   4.44M |  756 |          0 |      0 |  0 |       431 | 236.72K |    862 | 0:03'30'' |
| Q30L100_2400000  |       8863 |  4.67M |   1535 |      9125 |   4.46M |  723 |          0 |      0 |  0 |       332 | 210.15K |    812 | 0:03'44'' |
| Q30L110_400000   |       1812 |  4.75M |   5760 |      2615 |   3.28M | 1395 |       1279 |  1.28K |  1 |       518 |   1.47M |   4364 | 0:01'23'' |
| Q30L110_800000   |       3814 |   4.7M |   2985 |      4269 |   4.12M | 1224 |          0 |      0 |  0 |       515 | 579.51K |   1761 | 0:01'56'' |
| Q30L110_1200000  |       4966 |  4.69M |   2390 |      5460 |   4.28M | 1065 |          0 |      0 |  0 |       497 | 412.59K |   1325 | 0:02'30'' |
| Q30L110_1600000  |       5467 |  4.69M |   2160 |      5977 |   4.32M | 1001 |          0 |      0 |  0 |       505 | 367.06K |   1159 | 0:03'04'' |
| Q30L110_2000000  |       6386 |  4.69M |   1951 |      6855 |   4.37M |  898 |          0 |      0 |  0 |       476 | 317.98K |   1053 | 0:03'40'' |
| Q30L120_400000   |       1374 |  4.73M |   6998 |      2268 |   2.88M | 1339 |       1171 |  2.27K |  2 |       485 |   1.85M |   5657 | 0:01'37'' |
| Q30L120_800000   |       2724 |  4.71M |   3931 |      3513 |   3.82M | 1350 |       1359 |  1.36K |  1 |       522 | 884.07K |   2580 | 0:01'51'' |
| Q30L120_1200000  |       3774 |   4.7M |   3014 |      4405 |   4.07M | 1207 |       1467 |  2.55K |  2 |       546 | 619.58K |   1805 | 0:02'22'' |
| Q30L130_400000   |       1063 |  4.57M |   8225 |      2009 |   2.34M | 1187 |       1125 |  6.96K |  6 |       466 |   2.23M |   7032 | 0:01'27'' |

| Name            | N50SRclean |   Sum |    # | N50Anchor |   Sum |    # | N50Anchor2 |     Sum |  # | N50Others |     Sum |    # |   RunTime |
|:----------------|-----------:|------:|-----:|----------:|------:|-----:|-----------:|--------:|---:|----------:|--------:|-----:|----------:|
| original_400000 |       2975 | 4.94M | 5517 |      3732 | 4.01M | 1322 |       1371 |  77.99K | 57 |       466 | 853.04K | 4138 | 0:01'32'' |
| Q20L100_1600000 |       9476 | 4.76M | 1878 |      9830 | 4.51M |  675 |          0 |       0 |  0 |       209 | 248.23K | 1203 | 0:02'59'' |
| Q20L110_1600000 |       8500 | 4.77M | 1961 |      9065 | 4.52M |  732 |          0 |       0 |  0 |       209 | 252.04K | 1229 | 0:02'53'' |
| Q20L120_1600000 |       7996 | 4.76M | 1912 |      8419 | 4.49M |  744 |          0 |       0 |  0 |       242 | 262.68K | 1168 | 0:02'40'' |
| Q20L130_1600000 |       7038 | 4.76M | 2092 |      7487 | 4.47M |  846 |       1288 |   1.29K |  1 |       276 | 293.45K | 1245 | 0:02'44'' |
| Q20L140_1600000 |       6209 | 4.75M | 2229 |      6689 | 4.39M |  911 |       1084 |   1.08K |  1 |       410 | 353.95K | 1317 | 0:02'38'' |
| Q20L150_1600000 |       5862 | 4.75M | 2286 |      6345 | 4.39M |  958 |       1112 |   1.11K |  1 |       406 | 357.13K | 1327 | 0:06'00'' |
| Q25L100_2800000 |      16043 | 4.68M | 1216 |     16318 | 4.53M |  483 |          0 |       0 |  0 |       224 | 154.02K |  733 | 0:04'08'' |
| Q25L110_2800000 |      12280 | 4.69M | 1351 |     12667 | 4.51M |  552 |          0 |       0 |  0 |       243 |  178.4K |  799 | 0:04'00'' |
| Q25L120_2400000 |       9044 |  4.7M | 1565 |      9464 | 4.48M |  715 |          0 |       0 |  0 |       292 | 220.31K |  850 | 0:04'01'' |
| Q25L130_2000000 |       6406 | 4.71M | 2000 |      7046 | 4.37M |  909 |          0 |       0 |  0 |       491 | 338.81K | 1091 | 0:03'19'' |
| Q25L140_1200000 |       3499 | 4.71M | 3147 |      4140 | 4.04M | 1238 |       1256 |   1.26K |  1 |       547 | 672.44K | 1908 | 0:02'22'' |
| Q25L150_1200000 |       3097 | 4.71M | 3382 |      3887 | 3.96M | 1274 |          0 |       0 |  0 |       557 | 745.81K | 2108 | 0:02'19'' |
| Q30L100_2400000 |       8863 | 4.67M | 1535 |      9125 | 4.46M |  723 |          0 |       0 |  0 |       332 | 210.15K |  812 | 0:03'44'' |
| Q30L110_2000000 |       6386 | 4.69M | 1951 |      6855 | 4.37M |  898 |          0 |       0 |  0 |       476 | 317.98K | 1053 | 0:03'40'' |
| Q30L120_1200000 |       3774 |  4.7M | 3014 |      4405 | 4.07M | 1207 |       1467 |   2.55K |  2 |       546 | 619.58K | 1805 | 0:02'22'' |
| Q25L150_SR      |       3340 | 4.83M | 2939 |      3906 | 3.67M | 1180 |       9114 | 321.73K | 56 |       654 |  834.9K | 1703 | 0:02'25'' |

## With PE info and substitutions

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

mkdir -p Q25L150_SR
cd ${BASE_DIR}/Q25L150_SR
ln -s ../Q25L150_1200000/R1.fq.gz R1.fq.gz
ln -s ../Q25L150_1200000/R2.fq.gz R2.fq.gz

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
    Q20L100_1600000/anchor/pe.anchor.fa \
    Q20L110_1600000/anchor/pe.anchor.fa \
    Q20L120_1600000/anchor/pe.anchor.fa \
    Q20L130_1600000/anchor/pe.anchor.fa \
    Q20L140_1600000/anchor/pe.anchor.fa \
    Q20L150_1600000/anchor/pe.anchor.fa \
    Q25L100_2800000/anchor/pe.anchor.fa \
    Q25L110_2800000/anchor/pe.anchor.fa \
    Q25L120_2400000/anchor/pe.anchor.fa \
    Q25L130_2000000/anchor/pe.anchor.fa \
    Q25L140_1200000/anchor/pe.anchor.fa \
    Q25L150_1200000/anchor/pe.anchor.fa \
    Q30L100_2400000/anchor/pe.anchor.fa \
    Q30L110_2000000/anchor/pe.anchor.fa \
    Q30L120_1200000/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

faops n50 -S -C merge/anchor.merge.fasta

# merge anchor2 and others
anchr contained \
    Q20L100_1600000/anchor/pe.anchor2.fa \
    Q20L110_1600000/anchor/pe.anchor2.fa \
    Q20L120_1600000/anchor/pe.anchor2.fa \
    Q20L130_1600000/anchor/pe.anchor2.fa \
    Q20L140_1600000/anchor/pe.anchor2.fa \
    Q20L150_1600000/anchor/pe.anchor2.fa \
    Q25L100_2800000/anchor/pe.anchor2.fa \
    Q25L110_2800000/anchor/pe.anchor2.fa \
    Q25L120_2400000/anchor/pe.anchor2.fa \
    Q25L130_2000000/anchor/pe.anchor2.fa \
    Q25L140_1200000/anchor/pe.anchor2.fa \
    Q25L150_1200000/anchor/pe.anchor2.fa \
    Q30L100_2400000/anchor/pe.anchor2.fa \
    Q30L110_2000000/anchor/pe.anchor2.fa \
    Q30L120_1200000/anchor/pe.anchor2.fa \
    Q20L100_1600000/anchor/pe.others.fa \
    Q20L110_1600000/anchor/pe.others.fa \
    Q20L120_1600000/anchor/pe.others.fa \
    Q20L130_1600000/anchor/pe.others.fa \
    Q20L140_1600000/anchor/pe.others.fa \
    Q20L150_1600000/anchor/pe.others.fa \
    Q25L100_2800000/anchor/pe.others.fa \
    Q25L110_2800000/anchor/pe.others.fa \
    Q25L120_2400000/anchor/pe.others.fa \
    Q25L130_2000000/anchor/pe.others.fa \
    Q25L140_1200000/anchor/pe.others.fa \
    Q25L150_1200000/anchor/pe.others.fa \
    Q30L100_2400000/anchor/pe.others.fa \
    Q30L110_2000000/anchor/pe.others.fa \
    Q30L120_1200000/anchor/pe.others.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.merge.fasta
    
faops n50 -S -C merge/others.merge.fasta

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
    Q20L100_1600000/anchor/pe.anchor.fa \
    Q20L110_1600000/anchor/pe.anchor.fa \
    Q20L120_1600000/anchor/pe.anchor.fa \
    Q20L130_1600000/anchor/pe.anchor.fa \
    Q20L140_1600000/anchor/pe.anchor.fa \
    Q20L150_1600000/anchor/pe.anchor.fa \
    Q25L100_2800000/anchor/pe.anchor.fa \
    Q25L110_2800000/anchor/pe.anchor.fa \
    Q25L120_2400000/anchor/pe.anchor.fa \
    Q25L130_2000000/anchor/pe.anchor.fa \
    Q25L140_1200000/anchor/pe.anchor.fa \
    Q25L150_1200000/anchor/pe.anchor.fa \
    Q30L100_2400000/anchor/pe.anchor.fa \
    Q30L110_2000000/anchor/pe.anchor.fa \
    Q30L120_1200000/anchor/pe.anchor.fa \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "Q20L100,Q20L110,Q20L120,Q20L130,Q20L140,Q20L150,Q25L100,Q25L110,Q25L120,Q25L130,Q25L140,Q25L150,Q30L100,Q30L110,Q30L120,merge,others,paralogs" \
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
faops n50 -S -C merge/anchor.cover.fasta

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
    -b 10 --len 2000 --idt 0.96 --all

CONTIG_COUNT=$(faops n50 -H -N 0 -C contigTrim/anchor.fasta)
echo ${CONTIG_COUNT}

rm -fr contigTrim/group
anchr group \
    --parallel 16 \
    --keep \
    contigTrim/anchorLong.db \
    contigTrim/anchorLong.ovlp.tsv \
    --range "1-${CONTIG_COUNT}" --len 2000 --idt 0.96 --max 20000 -c 1 --png

pushd ${BASE_DIR}/contigTrim
cat group/groups.txt \
    | parallel --no-run-if-empty -j 8 '
        echo {};
        anchr orient \
            --len 2000 --idt 0.96 \
            group/{}.anchor.fasta \
            group/{}.long.fasta \
            -r group/{}.restrict.tsv \
            -o group/{}.strand.fasta;

        anchr overlap --len 2000 --idt 0.96 --all \
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
| anchor.merge |   23668 | 4559138 | 328 |
| others.merge |    1008 |   57863 |  56 |
| anchor.cover |   23668 | 4555277 | 325 |
| anchorLong   |   95547 | 4519161 | 101 |
| contigTrim   | 4594609 | 4635986 |   2 |
