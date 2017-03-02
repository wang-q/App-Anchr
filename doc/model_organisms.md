# Assemble genomes of model organisms by ANCHR

[TOC levels=1-3]: # " "
- [Assemble genomes of model organisms by ANCHR](#assemble-genomes-of-model-organisms-by-anchr)
- [More tools on downloading and preprocessing data](#more-tools-on-downloading-and-preprocessing-data)
    - [Extra external executables](#extra-external-executables)
    - [PacBio specific tools](#pacbio-specific-tools)
- [*Escherichia coli* str. K-12 substr. MG1655](#escherichia-coli-str-k-12-substr-mg1655)
    - [*E. coli*: download](#e-coli-download)
    - [*E. coli*: trim](#e-coli-trim)
    - [*E. coli*: down sampling](#e-coli-down-sampling)
    - [*E. coli*: generate super-reads](#e-coli-generate-super-reads)
    - [*E. coli*: create anchors](#e-coli-create-anchors)
    - [*E. coli*: results](#e-coli-results)
    - [*E. coli*: quality assessment](#e-coli-quality-assessment)
    - [*E. coli*: anchor-long](#e-coli-anchor-long)
- [*Saccharomyces cerevisiae* S288c](#saccharomyces-cerevisiae-s288c)
    - [Scer: download](#scer-download)
    - [Scer: trim](#scer-trim)
    - [Scer: down sampling](#scer-down-sampling)
    - [Scer: generate super-reads](#scer-generate-super-reads)
    - [Scer: create anchors](#scer-create-anchors)
    - [Scer: results](#scer-results)
    - [Scer: quality assessment](#scer-quality-assessment)
- [*Drosophila melanogaster* iso-1](#drosophila-melanogaster-iso-1)
    - [Dmel: download](#dmel-download)
    - [Dmel: trim](#dmel-trim)
    - [Dmel: down sampling](#dmel-down-sampling)
    - [Dmel: generate super-reads](#dmel-generate-super-reads)
    - [Dmel: create anchors](#dmel-create-anchors)
    - [Dmel: results](#dmel-results)
    - [Dmel: quality assessment](#dmel-quality-assessment)
- [*Caenorhabditis elegans* N2](#caenorhabditis-elegans-n2)
    - [Cele: download](#cele-download)
    - [Cele: trim](#cele-trim)
    - [Cele: down sampling](#cele-down-sampling)
    - [Cele: generate super-reads](#cele-generate-super-reads)
    - [Cele: create anchors](#cele-create-anchors)
    - [Cele: results](#cele-results)
    - [Cele: quality assessment](#cele-quality-assessment)
- [*Arabidopsis thaliana* Col-0](#arabidopsis-thaliana-col-0)
    - [Atha: download](#atha-download)
    - [Atha: trim](#atha-trim)
    - [Atha: down sampling](#atha-down-sampling)
    - [Atha: generate super-reads](#atha-generate-super-reads)
    - [Atha: create anchors](#atha-create-anchors)
    - [Atha: results](#atha-results)
    - [Atha: quality assessment](#atha-quality-assessment)


# More tools on downloading and preprocessing data

## Extra external executables

```bash
brew install aria2 curl wget                # downloading tools

brew install homebrew/science/sratoolkit    # NCBI SRAToolkit

brew reinstall --build-from-source --without-webp gd # broken, can't find libwebp.so.6
brew reinstall --build-from-source homebrew/versions/gnuplot4 
brew install homebrew/science/mummer        # mummer need gnuplot4

brew install homebrew/science/quast         # assembly quality assessment
quast --test                                # may recompile the bundled nucmer
```

## PacBio specific tools

PacBio is switching its data format from `hdf5` to `bam`, but at now (early 2017) the majority of
public available PacBio data are still in formats of `.bax.h5` or `hdf5.tgz`. For dealing with
these files, PacBio releases some tools which can be installed by another specific tool, named
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
* Proportion of paralogs (> 1000 bp): 0.0323

## *E. coli*: download

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
```

* Illumina

```bash
mkdir -p ~/data/anchr/e_coli/2_illumina
cd ~/data/anchr/e_coli/2_illumina
wget -N ftp://webdata:webdata@ussd-ftp.illumina.com/Data/SequencingRuns/MG1655/MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz
wget -N ftp://webdata:webdata@ussd-ftp.illumina.com/Data/SequencingRuns/MG1655/MiSeq_Ecoli_MG1655_110721_PF_R2.fastq.gz

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
wget -N https://s3.amazonaws.com/files.pacb.com/datasets/secondary-analysis/e-coli-k12-P6C4/p6c4_ecoli_RSII_DDR2_with_15kb_cut_E01_1.tar.gz

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
```

## *E. coli*: trim

* Q20L150
* Q25L130

```bash
cd ~/data/anchr/e_coli

# get the default adapter file
# anchr trim --help

scythe \
    2_illumina/R1.fq.gz \
    -q sanger \
    -M 100 \
    -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
    --quiet \
    | pigz -p 4 -c \
    > 2_illumina/R1.scythe.fq.gz

scythe \
    2_illumina/R2.fq.gz \
    -q sanger \
    -M 100 \
    -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
    --quiet \
    | pigz -p 4 -c \
    > 2_illumina/R2.scythe.fq.gz

# Q20L150
mkdir -p ~/data/anchr/e_coli/2_illumina/Q20L150
cd ~/data/anchr/e_coli/2_illumina/Q20L150

anchr trim \
    --noscythe \
    -q 20 -l 150 \
    ../R1.scythe.fq.gz ../R2.scythe.fq.gz \
    -o stdout \
    | bash

# Q25L130
mkdir -p ~/data/anchr/e_coli/2_illumina/Q25L130
cd ~/data/anchr/e_coli/2_illumina/Q25L130

anchr trim \
    --noscythe \
    -q 25 -l 130 \
    ../R1.scythe.fq.gz ../R2.scythe.fq.gz \
    -o stdout \
    | bash
```

* Stats

```bash
cd ~/data/anchr/e_coli

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "PacBio";   faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz  2_illumina/R2.scythe.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Q20L150";  faops n50 -H -S -C 2_illumina/Q20L150/R1.fq.gz 2_illumina/Q20L150/R1.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Q25L130";  faops n50 -H -S -C 2_illumina/Q25L130/R1.fq.gz 2_illumina/Q25L130/R1.fq.gz;) >> stat.md

cat stat.md
```

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 4641652 |    4641652 |        1 |
| Illumina |     151 | 1730299940 | 11458940 |
| PacBio   |   13982 |  748508361 |    87225 |
| scythe   |     151 | 1724565376 | 11458940 |
| Q20L150  |     151 |  742743756 |  4918836 |
| Q25L130  |     151 |  642015132 |  4303670 |

## *E. coli*: down sampling

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

# works on bash 3
ARRAY=( "2_illumina/Q20L150:Q20L150:2400000"
        "2_illumina/Q25L130:Q25L130:2000000")

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    GROUP_MAX=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[2];')
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    for count in $(perl -e 'print 200000 * $_, q{ } for 1 .. 25');
    do
        if [[ "$count" -gt "$GROUP_MAX" ]]; then
            continue     
        fi
        
        echo "==> Reads ${GROUP_ID}_${count}"
        DIR_COUNT="${BASE_DIR}/${GROUP_ID}_${count}"
        mkdir -p ${DIR_COUNT}
        
        if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
            continue     
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

## *E. coli*: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

for d in $(perl -e 'for $n (qw{Q20L150 Q25L130}) { for $i (1 .. 25) { printf qq{%s_%d }, $n, (200000 * $i); } }');
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"

    if [ ! -d ${DIR_COUNT} ]; then
        continue
    fi
    
    if [ -e ${DIR_COUNT}/pe.cor.fa ]; then
        echo "    pe.cor.fa already presents"
        continue
    fi
    
    pushd ${DIR_COUNT} > /dev/null
    anchr superreads \
        R1.fq.gz \
        R2.fq.gz \
        -s 300 -d 30 -p 16
    bash superreads.sh
    popd > /dev/null
done
```

Clear intermediate files.

```bash
cd $HOME/data/anchr/e_coli

find . -type f -name "quorum_mer_db.jf" | xargs rm
find . -type f -name "k_u_hash_0" | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp" | xargs rm
#find . -type f -name "pe.renamed.fastq" | xargs rm
```

## *E. coli*: create anchors

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

for d in $(perl -e 'for $n (qw{Q20L150 Q25L130}) { for $i (1 .. 25) { printf qq{%s_%d }, $n, (200000 * $i); } }');
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ -e ${DIR_COUNT}/anchor/pe.anchor.fa ]; then
        continue
    fi
    
    rm -fr ${DIR_COUNT}/anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh ${DIR_COUNT} 16 120 false
done
```

## *E. coli*: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

REAL_G=4641652

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

for d in $(perl -e 'for $n (qw{Q20L150 Q25L130}) { for $i (1 .. 25) { printf qq{%s_%d }, $n, (200000 * $i); } }');
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -d ${DIR_COUNT} ]; then
        continue     
    fi
    
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${DIR_COUNT} ${REAL_G} \
        >> ${BASE_DIR}/stat1.md
done

cat stat1.md
```

* Stats of anchors

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

for d in $(perl -e 'for $n (qw{Q20L150 Q25L130}) { for $i (1 .. 25) { printf qq{%s_%d }, $n, (200000 * $i); } }');
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -e ${DIR_COUNT}/anchor/pe.anchor.fa ]; then
        continue     
    fi
    
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${DIR_COUNT} \
        >> ${BASE_DIR}/stat2.md

done

cat stat2.md
```

| Name            |   SumFq | CovFq | AvgRead | Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:----------------|--------:|------:|--------:|-----:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| Q20L150_200000  |   60.4M |  13.0 |     150 |  105 |  52.47M |  13.133% | 4.64M | 4.28M |     0.92 | 4.94M | 4.65M | 0:00'25'' |
| Q20L150_400000  |  120.8M |  26.0 |     150 |  105 | 104.77M |  13.271% | 4.64M | 4.47M |     0.96 | 4.81M | 4.83M | 0:00'44'' |
| Q20L150_600000  |  181.2M |  39.0 |     150 |  105 | 157.13M |  13.283% | 4.64M | 4.51M |     0.97 | 4.74M | 4.85M | 0:00'52'' |
| Q20L150_800000  |  241.6M |  52.1 |     150 |  105 | 209.46M |  13.301% | 4.64M | 4.53M |     0.98 | 4.72M | 4.85M | 0:00'59'' |
| Q20L150_1000000 |    302M |  65.1 |     150 |  105 | 261.92M |  13.272% | 4.64M | 4.54M |     0.98 | 4.71M | 4.86M | 0:01'11'' |
| Q20L150_1200000 |  362.4M |  78.1 |     150 |  105 | 314.43M |  13.237% | 4.64M | 4.54M |     0.98 | 4.71M | 4.91M | 0:01'22'' |
| Q20L150_1400000 |  422.8M |  91.1 |     150 |  105 | 366.73M |  13.262% | 4.64M | 4.55M |     0.98 | 4.73M | 5.04M | 0:01'33'' |
| Q20L150_1600000 |  483.2M | 104.1 |     150 |  105 |  419.2M |  13.245% | 4.64M | 4.55M |     0.98 | 4.75M | 5.12M | 0:01'49'' |
| Q20L150_1800000 |  543.6M | 117.1 |     150 |  105 | 471.78M |  13.212% | 4.64M | 4.55M |     0.98 | 4.77M | 5.37M | 0:01'58'' |
| Q20L150_2000000 |    604M | 130.1 |     150 |  105 | 524.15M |  13.219% | 4.64M | 4.56M |     0.98 |  4.8M | 5.72M | 0:02'09'' |
| Q20L150_2200000 |  664.4M | 143.1 |     150 |  105 | 576.74M |  13.194% | 4.64M | 4.56M |     0.98 | 4.83M | 5.85M | 0:02'22'' |
| Q20L150_2400000 |  724.8M | 156.2 |     150 |  105 |  629.2M |  13.190% | 4.64M | 4.57M |     0.98 | 4.88M | 6.27M | 0:02'34'' |
| Q25L130_200000  |  58.94M |  12.7 |     147 |  105 |  55.06M |   6.572% | 4.64M | 4.27M |     0.92 | 5.02M | 4.72M | 0:00'22'' |
| Q25L130_400000  | 117.87M |  25.4 |     147 |  101 | 110.35M |   6.384% | 4.64M | 4.47M |     0.96 | 4.79M | 4.82M | 0:00'35'' |
| Q25L130_600000  |  176.8M |  38.1 |     147 |  101 | 165.52M |   6.379% | 4.64M | 4.51M |     0.97 | 4.74M | 4.82M | 0:00'47'' |
| Q25L130_800000  | 235.75M |  50.8 |     146 |  101 | 220.72M |   6.374% | 4.64M | 4.53M |     0.98 | 4.71M | 4.81M | 0:00'57'' |
| Q25L130_1000000 | 294.68M |  63.5 |     146 |  101 | 275.93M |   6.365% | 4.64M | 4.54M |     0.98 |  4.7M | 4.86M | 0:01'10'' |
| Q25L130_1200000 | 353.62M |  76.2 |     146 |  101 | 331.08M |   6.374% | 4.64M | 4.54M |     0.98 |  4.7M | 4.85M | 0:01'20'' |
| Q25L130_1400000 | 412.57M |  88.9 |     146 |  101 | 386.28M |   6.374% | 4.64M | 4.55M |     0.98 |  4.7M | 4.87M | 0:01'34'' |
| Q25L130_1600000 | 471.51M | 101.6 |     146 |   99 | 441.41M |   6.384% | 4.64M | 4.55M |     0.98 | 4.69M |  4.9M | 0:01'46'' |
| Q25L130_1800000 | 530.45M | 114.3 |     146 |   99 | 496.67M |   6.368% | 4.64M | 4.55M |     0.98 | 4.69M |  4.9M | 0:01'57'' |
| Q25L130_2000000 | 589.39M | 127.0 |     146 |   99 | 551.82M |   6.374% | 4.64M | 4.55M |     0.98 | 4.69M | 4.94M | 0:02'10'' |

| Name            | N50SRclean |   Sum |    # | N50Anchor |   Sum |    # | N50Anchor2 |    Sum |  # | N50Others |     Sum |    # |   RunTime |
|:----------------|-----------:|------:|-----:|----------:|------:|-----:|-----------:|-------:|---:|----------:|--------:|-----:|----------:|
| Q20L150_200000  |       1022 | 2.73M | 2811 |      1600 | 1.33M |  815 |       1143 | 19.96K | 17 |       714 |   1.39M | 1979 | 0:00'28'' |
| Q20L150_400000  |       2160 | 4.11M | 2476 |      2603 | 3.33M | 1414 |       1259 | 14.04K | 11 |       761 | 763.72K | 1051 | 0:00'38'' |
| Q20L150_600000  |       3342 | 4.37M | 1887 |      3892 | 3.92M | 1288 |       1988 |  5.17K |  3 |       775 | 440.69K |  596 | 0:00'46'' |
| Q20L150_800000  |       4400 | 4.46M | 1562 |      4618 | 4.17M | 1177 |       1212 |  4.79K |  4 |       786 | 283.17K |  381 | 0:00'53'' |
| Q20L150_1000000 |       5385 | 4.49M | 1342 |      5719 | 4.26M | 1024 |       2093 |  2.09K |  1 |       793 | 236.46K |  317 | 0:01'01'' |
| Q20L150_1200000 |       5966 | 4.51M | 1197 |      6214 | 4.34M |  969 |       3104 |   3.1K |  1 |       783 | 168.99K |  227 | 0:01'10'' |
| Q20L150_1400000 |       6109 | 4.52M | 1175 |      6352 | 4.35M |  941 |       1601 |   1.6K |  1 |       773 | 171.14K |  233 | 0:01'17'' |
| Q20L150_1600000 |       6285 | 4.54M | 1156 |      6606 | 4.37M |  929 |       2206 |  2.21K |  1 |       771 | 165.93K |  226 | 0:01'22'' |
| Q20L150_1800000 |       6241 | 4.55M | 1164 |      6428 | 4.39M |  949 |       1957 |  1.96K |  1 |       787 | 158.72K |  214 | 0:01'28'' |
| Q20L150_2000000 |       5885 | 4.56M | 1210 |      6134 | 4.39M |  988 |          0 |      0 |  0 |       783 |  165.2K |  222 | 0:01'36'' |
| Q20L150_2200000 |       5503 | 4.57M | 1274 |      5761 | 4.39M | 1029 |       3349 |  3.35K |  1 |       767 | 178.53K |  244 | 0:01'44'' |
| Q20L150_2400000 |       5025 | 4.58M | 1369 |      5249 | 4.38M | 1095 |          0 |      0 |  0 |       777 | 202.76K |  274 | 0:01'42'' |
| Q25L130_200000  |        967 | 2.58M | 2751 |      1563 | 1.19M |  749 |       1234 |  11.6K |  9 |       700 |   1.38M | 1993 | 0:00'29'' |
| Q25L130_400000  |       2096 |  4.1M | 2503 |      2604 | 3.29M | 1406 |       1339 |  8.87K |  6 |       768 | 799.88K | 1091 | 0:00'39'' |
| Q25L130_600000  |       3250 | 4.35M | 1915 |      3759 | 3.87M | 1283 |       2113 | 17.24K |  8 |       781 | 462.43K |  624 | 0:00'49'' |
| Q25L130_800000  |       4249 | 4.45M | 1604 |      4658 | 4.14M | 1182 |          0 |      0 |  0 |       767 | 309.01K |  422 | 0:00'57'' |
| Q25L130_1000000 |       4883 | 4.48M | 1415 |      5288 | 4.24M | 1092 |       1142 |  1.14K |  1 |       796 | 240.76K |  322 | 0:01'04'' |
| Q25L130_1200000 |       5494 |  4.5M | 1282 |      5869 |  4.3M | 1005 |       1086 |  1.09K |  1 |       769 | 201.98K |  276 | 0:01'12'' |
| Q25L130_1400000 |       6223 | 4.52M | 1192 |      6453 | 4.35M |  954 |          0 |      0 |  0 |       782 | 175.72K |  238 | 0:01'20'' |
| Q25L130_1600000 |       7075 | 4.53M | 1095 |      7301 | 4.39M |  897 |          0 |      0 |  0 |       760 | 143.67K |  198 | 0:01'29'' |
| Q25L130_1800000 |       7228 | 4.54M | 1058 |      7438 |  4.4M |  868 |       2234 |  5.75K |  3 |       746 | 135.29K |  187 | 0:01'37'' |
| Q25L130_2000000 |       7690 | 4.54M | 1021 |      7988 |  4.4M |  829 |       2327 |  2.33K |  1 |       754 | 136.91K |  191 | 0:01'43'' |

## *E. coli*: quality assessment

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

# sort on ref
for part in anchor anchor2 others;
do 
    bash ~/Scripts/cpan/App-Anchr/share/sort_on_ref.sh Q20L150_1600000/anchor/pe.${part}.fa 1_genome/genome.fa pe.${part}
    nucmer -l 200 1_genome/genome.fa pe.${part}.fa
    mummerplot out.delta --png --prefix pe.${part} --size large
done

cp ~/data/anchr/paralogs/model/Results/e_coli/e_coli.multi.fas 1_genome/paralogs.fas

cp ~/data/pacbio/ecoli_p6c4/2-asm-falcon/p_ctg.fa falcon.fa

nucmer -l 200 NC_000913.fa falcon.fa
mummerplot -png out.delta -p falcon --medium

# mummerplot files
rm *.[fr]plot
rm out.delta
rm *.gp

# quast
rm -fr 9_qa
quast --no-check \
    -R 1_genome/genome.fa \
    Q20L150_1600000/anchor/pe.anchor.fa \
    Q25L130_1400000/anchor/pe.anchor.fa \
    Q25L130_2000000/anchor/pe.anchor.fa \
    Q20L150_1600000/anchorLong/contig.fasta \
    1_genome/paralogs.fas \
    --label "Q20L150_1600000,Q25L130_1400000,Q25L130_2000000,contig,paralogs" \
    -o 9_qa
```

## *E. coli*: anchor-long

* 只有基于 distances 的判断的话, `anchr group` 无法消除 false strands.
* multi-matched 判断不能放到 `anchr cover` 里, 拆分的 anchors 里也有 multi-matched 的部分.

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

#head -n 23000 ${BASE_DIR}/3_pacbio/pacbio.fasta > ${BASE_DIR}/3_pacbio/pacbio.20x.fasta
head -n 46000 ${BASE_DIR}/3_pacbio/pacbio.fasta > ${BASE_DIR}/3_pacbio/pacbio.40x.fasta

mkdir -p ${BASE_DIR}/Q20L150_1600000/covered
anchr cover \
    -b 20 -c 2 --len 1000 --idt 0.85 \
    ${BASE_DIR}/Q20L150_1600000/anchor/pe.anchor.fa \
    ${BASE_DIR}/3_pacbio/pacbio.40x.fasta \
    -o ${BASE_DIR}/Q20L150_1600000/covered/covered.fasta
faops n50 -S -C ${BASE_DIR}/Q20L150_1600000/covered/covered.fasta

anchr overlap2 \
    ${BASE_DIR}/Q20L150_1600000/covered/covered.fasta \
    ${BASE_DIR}/3_pacbio/pacbio.40x.fasta \
    -d ${BASE_DIR}/Q20L150_1600000/anchorLong \
    -b 20 --len 1000 --idt 0.85

ANCHOR_COUNT=$(faops n50 -H -N 0 -C ${BASE_DIR}/Q20L150_1600000/anchorLong/anchor.fasta)
echo ${ANCHOR_COUNT}
anchr group \
    ${BASE_DIR}/Q20L150_1600000/anchorLong/anchorLong.db \
    ${BASE_DIR}/Q20L150_1600000/anchorLong/anchorLong.ovlp.tsv \
    --range "1-${ANCHOR_COUNT}" --len 1000 --idt 0.85 --max 2000 -c 5 --png

pushd ${BASE_DIR}/Q20L150_1600000/anchorLong
cat group/groups.txt \
    | parallel --no-run-if-empty -j 4 '
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

        anchr overlap --len 10 --idt 0.98 \
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
    '
popd

# false strand
cat ${BASE_DIR}/Q20L150_1600000/anchorLong/group/*.ovlp.tsv \
    | perl -nla -e '/anchor.+long/ or next; print $F[0] if $F[8] == 1;' \
    | sort | uniq -c

for id in $(cat ${BASE_DIR}/Q20L150_1600000/anchorLong/group/groups.txt);
do
    echo ${id};
    perl ~/Scripts/cpan/App-Anchr/share/layout.pl \
        ${BASE_DIR}/Q20L150_1600000/anchorLong/group/${id}.ovlp.tsv \
        ${BASE_DIR}/Q20L150_1600000/anchorLong/group/${id}.relation.tsv \
        ${BASE_DIR}/Q20L150_1600000/anchorLong/group/${id}.strand.fasta \
        --oa ${BASE_DIR}/Q20L150_1600000/anchorLong/group/${id}.anchor.ovlp.tsv \
        --png \
        -o ${BASE_DIR}/Q20L150_1600000/anchorLong/group/${id}.contig.fasta
done

faops n50 -S -C ${BASE_DIR}/Q20L150_1600000/anchorLong/group/*.contig.fasta
cat ${BASE_DIR}/Q20L150_1600000/anchorLong/group/*.contig.fasta \
    >  ${BASE_DIR}/Q20L150_1600000/anchorLong/contig.fasta

rm -fr 9_qa
quast --no-check \
    -R 1_genome/genome.fa \
    Q20L150_1600000/anchor/pe.anchor.fa \
    Q20L150_1600000/anchorLong/contig.fasta \
    contig_2_14.fasta \
    1_genome/paralogs.fas \
    --label "Q20L150_1600000,contig,contig_2_14,paralogs" \
    -o 9_qa

```

| Long | cover | #Anchor |  max | linker | Multi-matched | Non-grouped |  CC | false strand |
|-----:|------:|:-------:|-----:|-------:|--------------:|------------:|----:|-------------:|
|  20x |     2 |   950   | 5000 |      2 |            19 |          16 |  59 |            2 |
|      |       |         |      |      3 |            19 |          45 |  89 |            2 |
|      |       |         |      |      5 |            19 |         194 | 154 |            0 |
|      |       |         | 2000 |      2 |            19 |          18 |  84 |            2 |
|      |       |         |      |      3 |            19 |          50 | 110 |            2 |
|      |       |         |      |      5 |            19 |         204 | 163 |            0 |
|  40x |     2 |   930   | 5000 |      2 |            38 |           3 |  27 |            1 |
|      |       |         |      |      3 |            38 |           3 |  28 |            1 |
|      |       |         |      |      5 |            38 |          10 |  60 |            1 |
|      |       |         | 2000 |      5 |            38 |          14 |  87 |            0 |
|      |       |         |      |     10 |            38 |         192 | 169 |            0 |

# *Saccharomyces cerevisiae* S288c

* Genome: [Ensembl 82](http://sep2015.archive.ensembl.org/Saccharomyces_cerevisiae/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.058

## Scer: download

* Reference genome

```bash
mkdir -p ~/data/anchr/s288c/1_genome
cd ~/data/anchr/s288c/1_genome
wget -N ftp://ftp.ensembl.org/pub/release-82/fasta/saccharomyces_cerevisiae/dna/Saccharomyces_cerevisiae.R64-1-1.dna_sm.toplevel.fa.gz
faops order Saccharomyces_cerevisiae.R64-1-1.dna_sm.toplevel.fa.gz \
    <(for chr in {I,II,III,IV,V,VI,VII,VIII,IX,X,XI,XII,XIII,XIV,XV,XVI,Mito}; do echo $chr; done) \
    genome.fa
```

* Illumina

    ENA hasn't synced with SRA for PRJNA340312, download with prefetch from sratoolkit.

```bash
mkdir -p ~/data/anchr/s288c/2_illumina
cd ~/data/anchr/s288c/2_illumina
prefetch --progress 0.5 SRR4074255
fastq-dump --split-files SRR4074255  
find . -name "*.fastq" | parallel -j 2 pigz -p 8

ln -s SRR4074255_1.fastq.gz R1.fq.gz
ln -s SRR4074255_2.fastq.gz R2.fq.gz
```

* PacBio

    PacBio provides a dataset of *S. cerevisiae* strain
    [W303](https://github.com/PacificBiosciences/DevNet/wiki/Saccharomyces-cerevisiae-W303-Assembly-Contigs),
    while the reference strain S288c is not provided. So we use the dataset from
    [project PRJEB7245](https://www.ncbi.nlm.nih.gov/bioproject/PRJEB7245),
    [study ERP006949](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=ERP006949), and
    [sample SAMEA4461733](https://www.ncbi.nlm.nih.gov/biosample/5850878). This is gathered with RS
    II and P6C4.

```bash
mkdir -p ~/data/anchr/s288c/3_pacbio
cd ~/data/anchr/s288c/3_pacbio

# download from sra
cat <<EOF > hdf5.txt
http://sra-download.ncbi.nlm.nih.gov/srapub_files/ERR1655118_ERR1655118_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/ERR1655120_ERR1655120_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/ERR1655122_ERR1655122_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/ERR1655124_ERR1655124_hdf5.tgz

EOF
aria2c -x 9 -s 3 -c -i hdf5.txt

# untar
mkdir -p ~/data/anchr/s288c/3_pacbio/untar
cd ~/data/anchr/s288c/3_pacbio
tar xvfz ERR1655118_ERR1655118_hdf5.tgz --directory untar
#tar xvfz ERR1655120_ERR1655120_hdf5.tgz --directory untar
#tar xvfz ERR1655122_ERR1655122_hdf5.tgz --directory untar
#tar xvfz ERR1655124_ERR1655124_hdf5.tgz --directory untar

# convert .bax.h5 to .subreads.bam
mkdir -p ~/data/anchr/s288c/3_pacbio/bam
cd ~/data/anchr/s288c/3_pacbio/bam

source ~/share/pitchfork/deployment/setup-env.sh
for movie in m150412 m150415 m150417 m150421;
do 
    bax2bam ~/data/anchr/s288c/3_pacbio/untar/${movie}*.bax.h5
done

# convert .subreads.bam to fasta
mkdir -p ~/data/anchr/s288c/3_pacbio/fasta

for movie in m150412 m150415 m150417 m150421;
do
    if [ ! -e ~/data/anchr/s288c/3_pacbio/bam/${movie}*.subreads.bam ]; then
        continue
    fi

    samtools fasta \
        ~/data/anchr/s288c/3_pacbio/bam/${movie}*.subreads.bam \
        > ~/data/anchr/s288c/3_pacbio/fasta/${movie}.fasta
done

cd ~/data/anchr/s288c/3_pacbio
ln -s fasta/m150412.fasta pacbio.fasta
```

## Scer: trim

* Q20L150

```bash
mkdir -p ~/data/anchr/s288c/2_illumina/Q20L150
pushd ~/data/anchr/s288c/2_illumina/Q20L150

anchr trim \
    -q 20 -l 150 \
    ../R1.fq.gz ../R2.fq.gz \
    -o stdout \
    | bash
    
popd
```

* Stats

```bash
cd ~/data/anchr/s288c

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "PacBio";   faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Q20L150";  faops n50 -H -S -C 2_illumina/Q20L150/R1.fq.gz 2_illumina/Q20L150/R1.fq.gz;) >> stat.md

cat stat.md
```

| Name     |    N50 |        Sum |        # |
|:---------|-------:|-----------:|---------:|
| Genome   | 924431 |   12157105 |       17 |
| Illumina |    151 | 2939081214 | 19464114 |
| PacBio   |   8412 |  820962526 |   177100 |
| Q20L150  |    151 | 2540868460 | 16827778 |

## Scer: down sampling

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

# works on bash 3
ARRAY=( "2_illumina/Q20L150:Q20L150:8000000")

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    GROUP_MAX=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[2];')
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    for count in $(perl -e 'print 1000000 * $_, q{ } for 1 .. 8');
    do
        if [[ "$count" -gt "$GROUP_MAX" ]]; then
            continue     
        fi
        
        echo "==> Reads ${GROUP_ID}_${count}"
        DIR_COUNT="${BASE_DIR}/${GROUP_ID}_${count}"
        mkdir -p ${DIR_COUNT}
        
        if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
            continue     
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

## Scer: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

for d in $(perl -e 'for $n (qw{Q20L150}) { for $i (1 .. 8) { printf qq{%s_%d }, $n, (1000000 * $i); } }');
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"

    if [ ! -d ${DIR_COUNT} ]; then
        continue
    fi
    
    if [ -e ${DIR_COUNT}/pe.cor.fa ]; then
        echo "    pe.cor.fa already presents"
        continue
    fi
    
    pushd ${DIR_COUNT} > /dev/null
    anchr superreads \
        R1.fq.gz \
        R2.fq.gz \
        --nosr \
        -s 300 -d 30 -p 16
    bash superreads.sh
    popd > /dev/null
done
```

Clear intermediate files.

```bash
cd $HOME/data/anchr/s288c/

find . -type f -name "quorum_mer_db.jf" | xargs rm
find . -type f -name "k_u_hash_0" | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp" | xargs rm
#find . -type f -name "pe.renamed.fastq" | xargs rm
```

## Scer: create anchors

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

for d in $(perl -e 'for $n (qw{Q20L150}) { for $i (1 .. 8) { printf qq{%s_%d }, $n, (1000000 * $i); } }');
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ -e ${DIR_COUNT}/anchor/pe.anchor.fa ]; then
        continue
    fi
    
    rm -fr ${DIR_COUNT}/anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh ${DIR_COUNT} 16 120 false
done
```

## Scer: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

REAL_G=12157105

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

for d in $(perl -e 'for $n (qw{Q20L150}) { for $i (1 .. 8) { printf qq{%s_%d }, $n, (1000000 * $i); } }');
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -d ${DIR_COUNT} ]; then
        continue     
    fi
    
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${DIR_COUNT} ${REAL_G} \
        >> ${BASE_DIR}/stat1.md
done

cat stat1.md
```

* Stats of anchors

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

for d in $(perl -e 'for $n (qw{Q20L150}) { for $i (1 .. 8) { printf qq{%s_%d }, $n, (1000000 * $i); } }');
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -e ${DIR_COUNT}/anchor/pe.anchor.fa ]; then
        continue     
    fi
    
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${DIR_COUNT} \
        >> ${BASE_DIR}/stat2.md

done

cat stat2.md
```

| Name            |   SumFq | CovFq | AvgRead | Kmer |   SumFa | Discard% |  RealG |   EstG | Est/Real |  SumKU | SumSR |   RunTime |
|:----------------|--------:|------:|--------:|-----:|--------:|---------:|-------:|-------:|---------:|-------:|------:|----------:|
| Q20L150_1000000 | 301.98M |  24.8 |     150 |  105 |  275.9M |   8.634% | 12.16M | 11.34M |     0.93 | 12.68M |     0 | 0:01'28'' |
| Q20L150_2000000 | 603.95M |  49.7 |     150 |  105 | 552.38M |   8.539% | 12.16M |  11.5M |     0.95 | 12.62M |     0 | 0:02'33'' |
| Q20L150_3000000 | 905.93M |  74.5 |     150 |  105 | 828.85M |   8.508% | 12.16M | 11.55M |     0.95 | 12.74M |     0 | 0:03'20'' |
| Q20L150_4000000 |   1.21G |  99.4 |     150 |  105 |   1.11G |   8.443% | 12.16M | 11.61M |     0.96 | 13.12M |     0 | 0:03'49'' |
| Q20L150_5000000 |   1.51G | 124.2 |     150 |  105 |   1.38G |   8.358% | 12.16M | 11.67M |     0.96 | 13.59M |     0 | 0:04'43'' |
| Q20L150_6000000 |   1.81G | 149.0 |     150 |  105 |   1.66G |   8.299% | 12.16M | 11.74M |     0.97 | 14.19M |     0 | 0:05'37'' |
| Q20L150_7000000 |   2.11G | 173.9 |     150 |  105 |   1.94G |   8.241% | 12.16M | 11.81M |     0.97 |  14.8M |     0 | 0:06'41'' |
| Q20L150_8000000 |   2.42G | 198.7 |     150 |  105 |   2.22G |   8.190% | 12.16M | 11.88M |     0.98 | 15.45M |     0 | 0:07'56'' |

| Name            | N50SRclean |    Sum |    # | N50Anchor |    Sum |    # | N50Anchor2 |    Sum |  # | N50Others |     Sum |    # |   RunTime |
|:----------------|-----------:|-------:|-----:|----------:|-------:|-----:|-----------:|-------:|---:|----------:|--------:|-----:|----------:|
| Q20L150_1000000 |       1821 | 10.24M | 6795 |      2119 |  8.27M | 4121 |       1177 | 17.25K | 14 |       769 |   1.95M | 2660 | 0:02'19'' |
| Q20L150_2000000 |       4157 | 11.24M | 3820 |      4312 | 10.74M | 3136 |       1140 |  3.46K |  3 |       779 | 501.81K |  681 | 0:03'18'' |
| Q20L150_3000000 |       6312 | 11.37M | 2721 |      6426 | 11.11M | 2357 |       1308 |  3.76K |  3 |       752 | 262.23K |  361 | 0:04'26'' |
| Q20L150_4000000 |       8000 | 11.41M | 2257 |      8215 | 11.21M | 1988 |       1692 |  2.92K |  2 |       761 | 193.84K |  267 | 0:05'24'' |
| Q20L150_5000000 |       9316 | 11.44M | 2036 |      9446 | 11.25M | 1780 |       2625 |  3.73K |  2 |       747 | 181.86K |  254 | 0:06'26'' |
| Q20L150_6000000 |       9759 | 11.44M | 1985 |      9941 | 11.26M | 1745 |       1553 |  1.55K |  1 |       757 | 174.18K |  239 | 0:07'06'' |
| Q20L150_7000000 |       9558 | 11.45M | 2004 |      9695 | 11.28M | 1768 |          0 |      0 |  0 |       744 | 168.96K |  236 | 0:07'44'' |
| Q20L150_8000000 |       9327 | 11.46M | 2082 |      9435 | 11.27M | 1826 |       2942 |  2.94K |  1 |       741 | 181.72K |  255 | 0:08'14'' |

## Scer: quality assessment

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

for part in anchor anchor2 others;
do 
    bash ~/Scripts/cpan/App-Anchr/share/sort_on_ref.sh Q20L150_2000000/anchor/pe.${part}.fa 1_genome/genome.fa pe.${part}
    nucmer -l 200 1_genome/genome.fa pe.${part}.fa
    mummerplot -png out.delta -p pe.${part} --medium
done

cp ~/data/anchr/paralogs/model/Results/s288c/s288c.multi.fas 1_genome/paralogs.fas

# mummerplot files
rm *.[fr]plot
rm out.delta
rm *.gp

# quast
rm -fr 9_qa
quast --no-check \
    -R 1_genome/genome.fa \
    Q20L150_2000000/anchor/pe.anchor.fa \
    Q20L150_4000000/anchor/pe.anchor.fa \
    Q20L150_6000000/anchor/pe.anchor.fa \
    1_genome/paralogs.fas \
    --label "2000000,4000000,6000000,paralogs" \
    -o 9_qa
```

## Scer: anchor-long

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

head -n 230000 ${BASE_DIR}/3_pacbio/pacbio.fasta > ${BASE_DIR}/3_pacbio/pacbio.40x.fasta
faops n50 -S -C ${BASE_DIR}/3_pacbio/pacbio.40x.fasta

mkdir -p ${BASE_DIR}/Q20L150_6000000/covered
anchr cover \
    -b 20 -c 2 --len 1000 --idt 0.85 \
    ${BASE_DIR}/Q20L150_6000000/anchor/pe.anchor.fa \
    ${BASE_DIR}/3_pacbio/pacbio.40x.fasta \
    -o ${BASE_DIR}/Q20L150_6000000/covered/covered.fasta
faops n50 -S -C ${BASE_DIR}/Q20L150_6000000/covered/covered.fasta

anchr overlap2 \
    ${BASE_DIR}/Q20L150_6000000/covered/covered.fasta \
    ${BASE_DIR}/3_pacbio/pacbio.40x.fasta \
    -d ${BASE_DIR}/Q20L150_6000000/anchorLong \
    -b 20 --len 1000 --idt 0.85

ANCHOR_COUNT=$(faops n50 -H -N 0 -C ${BASE_DIR}/Q20L150_6000000/anchorLong/anchor.fasta)
echo ${ANCHOR_COUNT}
anchr group \
    ${BASE_DIR}/Q20L150_6000000/anchorLong/anchorLong.db \
    ${BASE_DIR}/Q20L150_6000000/anchorLong/anchorLong.ovlp.tsv \
    --range "1-${ANCHOR_COUNT}" --len 1000 --idt 0.85 --max 5000 -c 3 --png

cat ${BASE_DIR}/Q20L150_6000000/anchorLong/group/groups.txt \
    | parallel --no-run-if-empty -j 4 '
        echo {};
        anchr orient \
            --len 1000 --idt 0.85 \
            ~/data/anchr/s288c/Q20L150_6000000/anchorLong/group/{}.anchor.fasta \
            ~/data/anchr/s288c/Q20L150_6000000/anchorLong/group/{}.long.fasta \
            -r ~/data/anchr/s288c/Q20L150_6000000/anchorLong/group/{}.restrict.tsv \
            -o ~/data/anchr/s288c/Q20L150_6000000/anchorLong/group/{}.strand.fasta;
        
        anchr overlap --len 1000 --idt 0.85 \
            ~/data/anchr/s288c/Q20L150_6000000/anchorLong/group/{}.strand.fasta \
            -o stdout \
            | anchr restrict \
                stdin ~/data/anchr/s288c/Q20L150_6000000/anchorLong/group/{}.restrict.tsv \
                -o ~/data/anchr/s288c/Q20L150_6000000/anchorLong/group/{}.ovlp.tsv;
    '

# false strand
cat ${BASE_DIR}/Q20L150_6000000/anchorLong/group/*.ovlp.tsv \
    | perl -nla -e '/anchor.+long/ or next; print $F[0] if $F[8] == 1;' \
    | sort | uniq -c

for id in $(cat ${BASE_DIR}/Q20L150_6000000/anchorLong/group/groups.txt);
do
    echo ${id};
    perl ~/Scripts/cpan/App-Anchr/share/layout.pl \
        ${BASE_DIR}/Q20L150_6000000/anchorLong/group/${id}.ovlp.tsv \
        ${BASE_DIR}/Q20L150_6000000/anchorLong/group/${id}.relation.tsv
done

```

# *Drosophila melanogaster* iso-1

* Genome: [Ensembl 82](http://sep2015.archive.ensembl.org/Drosophila_melanogaster/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.0661

## Dmel: download

* Reference genome

```bash
mkdir -p ~/data/anchr/iso_1/1_genome
cd ~/data/anchr/iso_1/1_genome

wget -N ftp://ftp.ensembl.org/pub/release-82/fasta/drosophila_melanogaster/dna/Drosophila_melanogaster.BDGP6.dna_sm.toplevel.fa.gz
faops order Drosophila_melanogaster.BDGP6.dna_sm.toplevel.fa.gz \
    <(for chr in {2L,2R,3L,3R,4,X,Y,dmel_mitochondrion_genome}; do echo $chr; done) \
    genome.fa
```

* Illumina

    SRR306628 labels ycnbwsp instead of iso-1.

```bash
# Downloading from ena with aria2
mkdir -p ~/data/anchr/iso_1/2_illumina
cd ~/data/anchr/iso_1/2_illumina
aria2c -x 9 -s 3 -c ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR306/SRR306628
fastq-dump --split-files ./SRR306628  
find . -name "*.fastq" | parallel -j 2 pigz -p 8

ln -s SRR306628_1.fastq.gz R1.fq.gz
ln -s SRR306628_2.fastq.gz R2.fq.gz
```

* PacBio

```bash
mkdir -p ~/data/anchr/iso_1/3_pacbio

```

## Dmel: trim

* Q20L120

```bash
mkdir -p ~/data/anchr/iso_1/2_illumina/Q20L120
pushd ~/data/anchr/iso_1/2_illumina/Q20L120

anchr trim \
    -q 20 -l 120 \
    ../R1.fq.gz ../R2.fq.gz \
    -o stdout \
    | bash
    
popd
```

* Stats

```bash
cd ~/data/anchr/iso_1

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "PacBio";   faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Q20L120";  faops n50 -H -S -C 2_illumina/Q20L120/R1.fq.gz 2_illumina/Q20L120/R1.fq.gz;) >> stat.md

cat stat.md
```

| Name     |      N50 |         Sum |        # |
|:---------|---------:|------------:|---------:|
| Genome   | 25286936 |   137567477 |        8 |
| Illumina |      146 | 12852672000 | 88032000 |
| PacBio   |          |             |          |
| Q20L120  |      146 |  7346135978 | 51441736 |

## Dmel: down sampling

```bash
BASE_DIR=$HOME/data/anchr/iso_1
cd ${BASE_DIR}

# works on bash 3
ARRAY=( "2_illumina/Q20L120:Q20L120:25000000")

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    GROUP_MAX=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[2];')
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    for count in $(perl -e 'print 5000000 * $_, q{ } for 1 .. 5');
    do
        if [[ "$count" -gt "$GROUP_MAX" ]]; then
            continue     
        fi
        
        echo "==> Reads ${GROUP_ID}_${count}"
        DIR_COUNT="${BASE_DIR}/${GROUP_ID}_${count}"
        mkdir -p ${DIR_COUNT}
        
        if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
            continue     
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

## Dmel: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/iso_1
cd ${BASE_DIR}

for d in $(perl -e 'for $n (qw{Q20L120}) { for $i (1 .. 5) { printf qq{%s_%d }, $n, (5000000 * $i); } }');
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"

    if [ ! -d ${DIR_COUNT} ]; then
        continue
    fi
    
    if [ -e ${DIR_COUNT}/pe.cor.fa ]; then
        echo "    pe.cor.fa already presents"
        continue
    fi
    
    pushd ${DIR_COUNT} > /dev/null
    anchr superreads \
        R1.fq.gz \
        R2.fq.gz \
        --nosr \
        -s 335 -d 33 -p 16
    bash superreads.sh
    popd > /dev/null
done
```

Clear intermediate files.

```bash
cd $HOME/data/anchr/iso_1/

find . -type f -name "quorum_mer_db.jf" | xargs rm
find . -type f -name "k_u_hash_0" | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp" | xargs rm
#find . -type f -name "pe.renamed.fastq" | xargs rm
```

## Dmel: create anchors

```bash
BASE_DIR=$HOME/data/anchr/iso_1
cd ${BASE_DIR}

for d in $(perl -e 'for $n (qw{Q20L120}) { for $i (1 .. 5) { printf qq{%s_%d }, $n, (5000000 * $i); } }');
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ -e ${DIR_COUNT}/anchor/pe.anchor.fa ]; then
        continue
    fi
    
    rm -fr ${DIR_COUNT}/anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh ${DIR_COUNT} 16 120 false
done
```

## Dmel: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/iso_1
cd ${BASE_DIR}

REAL_G=137567477

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

for d in $(perl -e 'for $n (qw{Q20L120}) { for $i (1 .. 5) { printf qq{%s_%d }, $n, (5000000 * $i); } }');
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -d ${DIR_COUNT} ]; then
        continue     
    fi
    
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${DIR_COUNT} ${REAL_G} \
        >> ${BASE_DIR}/stat1.md
done

cat stat1.md
```

* Stats of anchors

```bash
BASE_DIR=$HOME/data/anchr/iso_1
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

for d in $(perl -e 'for $n (qw{Q20L120}) { for $i (1 .. 5) { printf qq{%s_%d }, $n, (5000000 * $i); } }');
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -e ${DIR_COUNT}/anchor/pe.anchor.fa ]; then
        continue     
    fi
    
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${DIR_COUNT} \
        >> ${BASE_DIR}/stat2.md

done

cat stat2.md
```

| Name             | SumFq | CovFq | AvgRead | Kmer | SumFa | Discard% |   RealG |    EstG | Est/Real |   SumKU | SumSR |   RunTime |
|:-----------------|------:|------:|--------:|-----:|------:|---------:|--------:|--------:|---------:|--------:|------:|----------:|
| Q20L120_5000000  | 1.42G |  10.3 |     141 |   95 | 1.14G |  19.452% | 137.57M |  94.68M |     0.69 | 119.61M |     0 | 0:08'22'' |
| Q20L120_10000000 | 2.83G |  20.6 |     140 |   93 | 2.31G |  18.478% | 137.57M | 111.82M |     0.81 | 137.92M |     0 | 0:15'14'' |
| Q20L120_15000000 | 4.25G |  30.9 |     139 |   93 | 3.48G |  18.123% | 137.57M | 119.21M |     0.87 | 148.11M |     0 | 0:21'59'' |
| Q20L120_20000000 | 5.67G |  41.2 |     138 |   91 | 4.66G |  17.892% | 137.57M | 123.85M |     0.90 | 155.73M |     0 | 0:29'07'' |
| Q20L120_25000000 | 7.09G |  51.5 |     137 |   91 | 5.83G |  17.713% | 137.57M | 127.21M |     0.92 | 163.69M |     0 | 0:46'16'' |

| Name             | N50SRclean |     Sum |     # | N50Anchor |    Sum |     # | N50Anchor2 |     Sum |   # | N50Others |    Sum |     # |   RunTime |
|:-----------------|-----------:|--------:|------:|----------:|-------:|------:|-----------:|--------:|----:|----------:|-------:|------:|----------:|
| Q20L120_5000000  |        903 |  41.22M | 45797 |      1577 |  16.8M | 10364 |       1161 | 230.93K | 195 |       693 | 24.19M | 35238 | 0:06'18'' |
| Q20L120_10000000 |       1386 |  78.06M | 64045 |      2025 | 50.71M | 25913 |       1178 | 360.82K | 298 |       734 | 26.99M | 37834 | 0:10'51'' |
| Q20L120_15000000 |       1783 |  92.63M | 63874 |      2375 | 69.11M | 31492 |       1172 | 302.73K | 247 |       749 | 23.21M | 32135 | 0:14'08'' |
| Q20L120_20000000 |       2185 | 101.08M | 60715 |      2710 | 81.37M | 33713 |       1186 | 240.58K | 196 |       755 | 19.46M | 26806 | 0:18'30'' |
| Q20L120_25000000 |       2379 | 105.54M | 59727 |      2887 |  87.2M | 34576 |       1198 | 178.44K | 145 |       754 | 18.16M | 25006 | 0:26'37'' |

## Dmel: quality assessment

```bash
BASE_DIR=$HOME/data/anchr/iso_1
cd ${BASE_DIR}

for part in anchor anchor2 others;
do 
    bash ~/Scripts/cpan/App-Anchr/share/sort_on_ref.sh Q20L120_25000000/anchor/pe.${part}.fa 1_genome/genome.fa pe.${part}
    nucmer -l 200 1_genome/genome.fa pe.${part}.fa
    mummerplot -png out.delta -p pe.${part} --medium
done

# mummerplot files
rm *.[fr]plot
rm out.delta
rm *.gp

cp ~/data/anchr/paralogs/model/Results/iso_1/iso_1.multi.fas 1_genome/paralogs.fas

# quast
rm -fr 9_qa
quast --no-check \
    -R 1_genome/genome.fa \
    Q20L120_25000000/anchor/pe.anchor.fa \
    1_genome/paralogs.fas \
    --label "25000000,paralogs" \
    -o 9_qa
```

# *Caenorhabditis elegans* N2

* Genome: [Ensembl 82](http://sep2015.archive.ensembl.org/Caenorhabditis_elegans/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.0472

## Cele: download

* Reference genome

```bash
mkdir -p ~/data/anchr/n2/1_genome
cd ~/data/anchr/n2/1_genome

wget -N ftp://ftp.ensembl.org/pub/release-82/fasta/caenorhabditis_elegans/dna/Caenorhabditis_elegans.WBcel235.dna_sm.toplevel.fa.gz
faops order Caenorhabditis_elegans.WBcel235.dna_sm.toplevel.fa.gz \
    <(for chr in {I,II,III,IV,V,X,MtDNA}; do echo $chr; done) \
    genome.fa
```

* Illumina

    * Other SRA
        * SRX770040 - [insert size](https://www.ncbi.nlm.nih.gov/sra/SRX770040[accn]) is 500-600 bp
        * ERR1039478 - adaptor contamination "ACTTCCAGGGATTTATAAGCCGATGACGTCATAACATCCCTGACCCTTTA"
        * DRR008443

```bash
# Downloading from ena with aria2
mkdir -p ~/data/anchr/n2/2_illumina
cd ~/data/anchr/n2/2_illumina
aria2c -x 9 -s 3 -c ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR065/SRR065390
fastq-dump --split-files ./SRR065390  
find . -name "*.fastq" | parallel -j 2 pigz -p 8

ln -s SRR065390_1.fastq.gz R1.fq.gz
ln -s SRR065390_2.fastq.gz R2.fq.gz
```

* PacBio

```bash
mkdir -p ~/data/anchr/n2/3_pacbio

```

## Cele: trim

* Q20L80

```bash
mkdir -p ~/data/anchr/n2/2_illumina/Q20L80
pushd ~/data/anchr/n2/2_illumina/Q20L80

anchr trim \
    -q 20 -l 80 \
    ../R1.fq.gz ../R2.fq.gz \
    -o stdout \
    | bash

popd
```

* Stats

```bash
cd ~/data/anchr/n2

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "PacBio";   faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Q20L80";  faops n50 -H -S -C 2_illumina/Q20L80/R1.fq.gz 2_illumina/Q20L80/R1.fq.gz;) >> stat.md

cat stat.md
```

| Name     |      N50 |        Sum |        # |
|:---------|---------:|-----------:|---------:|
| Genome   | 17493829 |  100286401 |        7 |
| Illumina |      100 | 6761709200 | 67617092 |
| PacBio   |          |            |          |
| Q20L80   |      100 | 4771828790 | 48565296 |

## Cele: down sampling

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

# works on bash 3
ARRAY=( "2_illumina/Q20L80:Q20L80:25000000")

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    GROUP_MAX=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[2];')
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    for count in $(perl -e 'print 5000000 * $_, q{ } for 1 .. 5');
    do
        if [[ "$count" -gt "$GROUP_MAX" ]]; then
            continue     
        fi
        
        echo "==> Reads ${GROUP_ID}_${count}"
        DIR_COUNT="${BASE_DIR}/${GROUP_ID}_${count}"
        mkdir -p ${DIR_COUNT}
        
        if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
            continue     
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

## Cele: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

for d in $(perl -e 'for $n (qw{Q20L80}) { for $i (1 .. 5) { printf qq{%s_%d }, $n, (5000000 * $i); } }');
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"

    if [ ! -d ${DIR_COUNT} ]; then
        continue
    fi
    
    if [ -e ${DIR_COUNT}/pe.cor.fa ]; then
        echo "    pe.cor.fa already presents"
        continue
    fi
    
    pushd ${DIR_COUNT} > /dev/null
    anchr superreads \
        R1.fq.gz \
        R2.fq.gz \
        --nosr \
        -s 200 -d 20 -p 16
    bash superreads.sh
    popd > /dev/null
done
```

Clear intermediate files.

```bash
cd $HOME/data/anchr/n2/

find . -type f -name "quorum_mer_db.jf" | xargs rm
find . -type f -name "k_u_hash_0" | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp" | xargs rm
#find . -type f -name "pe.renamed.fastq" | xargs rm
```

## Cele: create anchors

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

for d in $(perl -e 'for $n (qw{Q20L80}) { for $i (1 .. 5) { printf qq{%s_%d }, $n, (5000000 * $i); } }');
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ -e ${DIR_COUNT}/anchor/pe.anchor.fa ]; then
        continue
    fi
    
    rm -fr ${DIR_COUNT}/anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh ${DIR_COUNT} 16 80 false
done
```

## Cele: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

REAL_G=100286401

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

for d in $(perl -e 'for $n (qw{Q20L80}) { for $i (1 .. 5) { printf qq{%s_%d }, $n, (5000000 * $i); } }');
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -d ${DIR_COUNT} ]; then
        continue     
    fi
    
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${DIR_COUNT} ${REAL_G} \
        >> ${BASE_DIR}/stat1.md
done

cat stat1.md
```

* Stats of anchors

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

for d in $(perl -e 'for $n (qw{Q20L80}) { for $i (1 .. 5) { printf qq{%s_%d }, $n, (5000000 * $i); } }');
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -e ${DIR_COUNT}/anchor/pe.anchor.fa ]; then
        continue     
    fi
    
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${DIR_COUNT} \
        >> ${BASE_DIR}/stat2.md

done

cat stat2.md
```

| Name            |   SumFq | CovFq | AvgRead | Kmer |   SumFa | Discard% |   RealG |   EstG | Est/Real |   SumKU | SumSR |   RunTime |
|:----------------|--------:|------:|--------:|-----:|--------:|---------:|--------:|-------:|---------:|--------:|------:|----------:|
| Q20L80_5000000  | 980.18M |   9.8 |      97 |   71 | 897.53M |   8.432% | 100.29M | 87.08M |     0.87 | 117.08M |     0 | 0:05'56'' |
| Q20L80_10000000 |   1.96G |  19.5 |      97 |   71 |   1.82G |   7.346% | 100.29M | 95.68M |     0.95 | 118.27M |     0 | 0:11'08'' |
| Q20L80_15000000 |   2.94G |  29.3 |      97 |   71 |   2.73G |   7.223% | 100.29M | 97.32M |     0.97 | 115.98M |     0 | 0:16'45'' |
| Q20L80_20000000 |   3.92G |  39.1 |      97 |   71 |   3.64G |   7.175% | 100.29M | 97.93M |     0.98 | 115.25M |     0 | 0:19'59'' |
| Q20L80_25000000 |   4.76G |  47.5 |      97 |   71 |   4.42G |   7.153% | 100.29M | 98.21M |     0.98 |  115.3M |     0 | 0:26'45'' |

| Name            | N50SRclean |    Sum |     # | N50Anchor |    Sum |     # | N50Anchor2 |   Sum | # | N50Others |    Sum |     # |   RunTime |
|:----------------|-----------:|-------:|------:|----------:|-------:|------:|-----------:|------:|--:|----------:|-------:|------:|----------:|
| Q20L80_5000000  |        637 | 12.58M | 19037 |      1190 |  1.05M |   845 |          0 |     0 | 0 |       621 | 11.52M | 18192 | 0:04'29'' |
| Q20L80_10000000 |       1105 | 64.74M | 62975 |      1604 | 36.11M | 22378 |       1096 | 2.16K | 2 |       725 | 28.63M | 40595 | 0:09'23'' |
| Q20L80_15000000 |       1994 | 83.29M | 53022 |      2499 | 66.13M | 29259 |       2455 | 7.13K | 4 |       749 | 17.15M | 23759 | 0:13'53'' |
| Q20L80_20000000 |       3050 | 89.24M | 42590 |      3564 | 77.94M | 26959 |       1750 | 3.25K | 2 |       752 |  11.3M | 15629 | 0:17'21'' |
| Q20L80_25000000 |       3831 | 91.59M | 37420 |      4373 | 82.57M | 24972 |       1890 | 1.89K | 1 |       754 |  9.02M | 12447 | 0:20'04'' |

## Cele: quality assessment

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

for part in anchor anchor2 others;
do 
    bash ~/Scripts/cpan/App-Anchr/share/sort_on_ref.sh Q20L80_25000000/anchor/pe.${part}.fa 1_genome/genome.fa pe.${part}
    nucmer -l 200 1_genome/genome.fa pe.${part}.fa
    mummerplot -png out.delta -p pe.${part} --medium
done

# mummerplot files
rm *.[fr]plot
rm out.delta
rm *.gp

cp ~/data/anchr/paralogs/model/Results/n2/n2.multi.fas 1_genome/paralogs.fas

# quast
rm -fr 9_qa
quast --no-check \
    -R 1_genome/genome.fa \
    Q20L80_25000000/anchor/pe.anchor.fa \
    1_genome/paralogs.fas \
    --label "25000000,paralogs" \
    -o 9_qa
```

# *Arabidopsis thaliana* Col-0

* Genome: [Ensembl Genomes](http://plants.ensembl.org/Arabidopsis_thaliana/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.1158

## Atha: download

* Reference genome

```bash
mkdir -p ~/data/anchr/col_0/1_genome
cd ~/data/anchr/col_0/1_genome
wget -N ftp://ftp.ensemblgenomes.org/pub/release-29/plants/fasta/arabidopsis_thaliana/dna/Arabidopsis_thaliana.TAIR10.29.dna_sm.toplevel.fa.gz
faops order Arabidopsis_thaliana.TAIR10.29.dna_sm.toplevel.fa.gz \
    <(for chr in {1,2,3,4,5,Mt,Pt}; do echo $chr; done) \
    genome.fa
```

* Illumina

```bash
# Downloading from ena with aria2
mkdir -p ~/data/anchr/col_0/2_illumina
cd ~/data/anchr/col_0/2_illumina
aria2c -x 9 -s 3 -c ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR611/SRR611086
fastq-dump --split-files ./SRR611086
find . -name "*.fastq" | parallel -j 2 pigz -p 8

ln -s SRR611086_1.fastq.gz R1.fq.gz
ln -s SRR611086_2.fastq.gz R2.fq.gz
```

* PacBio

```bash
mkdir -p ~/data/anchr/col_0/3_pacbio

```

## Atha: trim

* Q20L80

```bash
mkdir -p ~/data/anchr/col_0/2_illumina/Q20L80
pushd ~/data/anchr/col_0/2_illumina/Q20L80

anchr trim \
    -q 20 -l 80 \
    ../R1.fq.gz ../R2.fq.gz \
    -o stdout \
    | bash

popd
```

* Stats

```bash
cd ~/data/anchr/col_0

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "PacBio";   faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Q20L80";  faops n50 -H -S -C 2_illumina/Q20L80/R1.fq.gz 2_illumina/Q20L80/R1.fq.gz;) >> stat.md

cat stat.md
```

| Name     |      N50 |        Sum |        # |
|:---------|---------:|-----------:|---------:|
| Genome   | 23459830 |  119667750 |        7 |
| Illumina |      100 | 9978269800 | 99782698 |
| PacBio   |          |            |          |
| Q20L80   |      100 | 8618615500 | 86472520 |

## Atha: down sampling

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

# works on bash 3
ARRAY=( "2_illumina/Q20L80:Q20L80:40000000")

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    GROUP_MAX=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[2];')
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    for count in $(perl -e 'print 5000000 * $_, q{ } for 1 .. 8');
    do
        if [[ "$count" -gt "$GROUP_MAX" ]]; then
            continue     
        fi
        
        echo "==> Reads ${GROUP_ID}_${count}"
        DIR_COUNT="${BASE_DIR}/${GROUP_ID}_${count}"
        mkdir -p ${DIR_COUNT}
        
        if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
            continue     
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

## Atha: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

for d in $(perl -e 'for $n (qw{Q20L80}) { for $i (1 .. 8) { printf qq{%s_%d }, $n, (5000000 * $i); } }');
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"

    if [ ! -d ${DIR_COUNT} ]; then
        continue
    fi
    
    if [ -e ${DIR_COUNT}/pe.cor.fa ]; then
        echo "    pe.cor.fa already presents"
        continue
    fi
    
    pushd ${DIR_COUNT} > /dev/null
    anchr superreads \
        R1.fq.gz \
        R2.fq.gz \
        --nosr \
        -s 200 -d 20 -p 16
    bash superreads.sh
    popd > /dev/null
done
```

Clear intermediate files.

```bash
cd $HOME/data/anchr/col_0/

find . -type f -name "quorum_mer_db.jf" | xargs rm
find . -type f -name "k_u_hash_0" | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp" | xargs rm
#find . -type f -name "pe.renamed.fastq" | xargs rm
```

## Atha: create anchors

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

for d in $(perl -e 'for $n (qw{Q20L80}) { for $i (1 .. 8) { printf qq{%s_%d }, $n, (5000000 * $i); } }');
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ -e ${DIR_COUNT}/anchor/pe.anchor.fa ]; then
        continue
    fi
    
    rm -fr ${DIR_COUNT}/anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh ${DIR_COUNT} 16 80 false
done
```

## Atha: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

REAL_G=119667750

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

for d in $(perl -e 'for $n (qw{Q20L80}) { for $i (1 .. 8) { printf qq{%s_%d }, $n, (5000000 * $i); } }');
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -d ${DIR_COUNT} ]; then
        continue     
    fi
    
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${DIR_COUNT} ${REAL_G} \
        >> ${BASE_DIR}/stat1.md
done

cat stat1.md
```

* Stats of anchors

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

for d in $(perl -e 'for $n (qw{Q20L80}) { for $i (1 .. 8) { printf qq{%s_%d }, $n, (5000000 * $i); } }');
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -e ${DIR_COUNT}/anchor/pe.anchor.fa ]; then
        continue     
    fi
    
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${DIR_COUNT} \
        >> ${BASE_DIR}/stat2.md

done

cat stat2.md
```

| Name            |   SumFq | CovFq | AvgRead | Kmer |   SumFa | Discard% |   RealG |    EstG | Est/Real |   SumKU | SumSR |   RunTime |
|:----------------|--------:|------:|--------:|-----:|--------:|---------:|--------:|--------:|---------:|--------:|------:|----------:|
| Q20L80_5000000  | 994.55M |   8.3 |      99 |   71 | 707.85M |  28.828% | 119.67M |  80.47M |     0.67 | 115.95M |     0 | 0:05'57'' |
| Q20L80_10000000 |   1.99G |  16.6 |      99 |   71 |   1.51G |  24.124% | 119.67M | 114.21M |     0.95 | 160.41M |     0 | 0:13'30'' |
| Q20L80_15000000 |   2.98G |  24.9 |      99 |   71 |    2.3G |  22.808% | 119.67M |  126.9M |     1.06 | 169.83M |     0 | 0:17'29'' |
| Q20L80_20000000 |   3.98G |  33.2 |      99 |   71 |   3.11G |  21.758% | 119.67M | 139.64M |     1.17 | 182.61M |     0 | 0:21'04'' |
| Q20L80_25000000 |   4.97G |  41.6 |      99 |   71 |   3.94G |  20.820% | 119.67M | 154.03M |     1.29 | 201.12M |     0 | 0:33'45'' |
| Q20L80_30000000 |   5.97G |  49.9 |      99 |   71 |   4.77G |  20.007% | 119.67M | 169.58M |     1.42 |  223.3M |     0 | 0:25'15'' |
| Q20L80_35000000 |   6.96G |  58.2 |      99 |   71 |   5.62G |  19.289% | 119.67M | 185.76M |     1.55 | 247.36M |     0 | 0:30'35'' |
| Q20L80_40000000 |   7.96G |  66.5 |      99 |   71 |   6.47G |  18.671% | 119.67M | 202.11M |     1.69 | 272.18M |     0 | 0:37'11'' |

| Name            | N50SRclean |     Sum |     # | N50Anchor |     Sum |     # | N50Anchor2 |   Sum | # | N50Others |     Sum |     # |   RunTime |
|:----------------|-----------:|--------:|------:|----------:|--------:|------:|-----------:|------:|--:|----------:|--------:|------:|----------:|
| Q20L80_5000000  |       1500 | 532.36K |   448 |         0 |       0 |     0 |          0 |     0 | 0 |      1500 | 532.36K |   448 | 0:02'45'' |
| Q20L80_10000000 |        656 |   14.5M | 21372 |         0 |       0 |     0 |          0 |     0 | 0 |       656 |   14.5M | 21372 | 0:04'53'' |
| Q20L80_15000000 |        941 |  62.58M | 69252 |      1387 |  27.67M | 19474 |          0 |     0 | 0 |       717 |   34.9M | 49778 | 0:09'27'' |
| Q20L80_20000000 |       1639 |  92.22M | 67020 |      2023 |  70.15M | 36628 |       1086 | 3.41K | 3 |       756 |  22.07M | 30389 | 0:15'54'' |
| Q20L80_25000000 |       3005 | 102.07M | 47207 |      3327 |  91.66M | 33019 |          0 |     0 | 0 |       771 |  10.41M | 14188 | 0:15'54'' |
| Q20L80_30000000 |       4902 | 105.17M | 33963 |      5217 |  99.16M | 25721 |       1776 | 3.23K | 2 |       766 |   6.01M |  8240 | 0:18'46'' |
| Q20L80_35000000 |       6833 | 106.59M | 27391 |      7164 | 101.99M | 21035 |       1089 | 1.09K | 1 |       756 |    4.6M |  6355 | 0:20'51'' |
| Q20L80_40000000 |       8220 |  107.4M | 24504 |      8611 | 103.23M | 18700 |          0 |     0 | 0 |       748 |   4.17M |  5804 | 0:24'19'' |

## Atha: quality assessment

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

for part in anchor anchor2 others;
do 
    bash ~/Scripts/cpan/App-Anchr/share/sort_on_ref.sh Q20L80_40000000/anchor/pe.${part}.fa 1_genome/genome.fa pe.${part}
    nucmer -l 200 1_genome/genome.fa pe.${part}.fa
    mummerplot -png out.delta -p pe.${part} --medium
done

# mummerplot files
rm *.[fr]plot
rm out.delta
rm *.gp

cp ~/data/anchr/paralogs/model/Results/col_0/col_0.multi.fas 1_genome/paralogs.fas

# quast
rm -fr 9_qa
quast --no-check \
    -R 1_genome/genome.fa \
    Q20L80_30000000/anchor/pe.anchor.fa \
    Q20L80_40000000/anchor/pe.anchor.fa \
    1_genome/paralogs.fas \
    --label "30000000,40000000,paralogs" \
    -o 9_qa
```
