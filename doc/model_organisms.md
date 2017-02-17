# Assemble genomes of model organisms by ANCHR

[TOC levels=1-3]: # " "
- [Assemble genomes of model organisms by ANCHR](#assemble-genomes-of-model-organisms-by-anchr)
- [More tools on downloading and preprocessing data](#more-tools-on-downloading-and-preprocessing-data)
    - [Extra external executables](#extra-external-executables)
    - [PacBio specific tools](#pacbio-specific-tools)
- [*Escherichia coli* str. K-12 substr. MG1655](#escherichia-coli-str-k-12-substr-mg1655)
    - [*E. coli*: download](#e-coli-download)
    - [*E. coli*: trim/filter](#e-coli-trimfilter)
    - [*E. coli*: down sampling](#e-coli-down-sampling)
    - [*E. coli*: generate super-reads](#e-coli-generate-super-reads)
    - [*E. coli*: create anchors](#e-coli-create-anchors)
    - [*E. coli*: results](#e-coli-results)
    - [*E. coli*: quality assessment](#e-coli-quality-assessment)
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
- [*Caenorhabditis elegans* N2](#caenorhabditis-elegans-n2)
    - [Cele: download](#cele-download)
    - [Cele: trim](#cele-trim)
    - [Cele: down sampling](#cele-down-sampling)
    - [Cele: generate super-reads](#cele-generate-super-reads)
    - [Cele: create anchors](#cele-create-anchors)
    - [Cele: results](#cele-results)
- [*Arabidopsis thaliana* Col-0](#arabidopsis-thaliana-col-0)
    - [Atha: download](#atha-download)
    - [Atha: trim](#atha-trim)
    - [Atha: down sampling](#atha-down-sampling)
    - [Atha: generate super-reads](#atha-generate-super-reads)
    - [Atha: create anchors](#atha-create-anchors)


# More tools on downloading and preprocessing data

## Extra external executables

```bash
brew install aria2 curl wget                # downloading tools

brew install homebrew/science/sratoolkit    # NCBI SRAToolkit

brew install gd --without-webp              # broken, can't find libwebp.so.6
brew install homebrew/versions/gnuplot4
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
* Proportion of paralogs: 0.0323

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
    
    if [ -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue
    fi
    
    rm -fr ${DIR_COUNT}/sr
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh ${DIR_COUNT} 16 120
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
    
    if [ ! -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue     
    fi
    
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${DIR_COUNT} \
        >> ${BASE_DIR}/stat2.md

done

cat stat2.md
```

| Name            |   SumFq | CovFq | AvgRead | Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumSR | SR/Real | SR/Est |   RunTime |
|:----------------|--------:|------:|--------:|-----:|--------:|---------:|------:|------:|---------:|------:|--------:|-------:|----------:|
| Q20L150_200000  |   60.4M |  13.0 |     150 |  105 |  52.47M |  13.133% | 4.64M | 4.28M |     0.92 | 4.65M |    1.00 |   1.09 | 0:00'22'' |
| Q20L150_400000  |  120.8M |  26.0 |     150 |  105 | 104.77M |  13.271% | 4.64M | 4.47M |     0.96 | 4.83M |    1.04 |   1.08 | 0:00'35'' |
| Q20L150_600000  |  181.2M |  39.0 |     150 |  105 | 157.13M |  13.283% | 4.64M | 4.51M |     0.97 | 4.85M |    1.04 |   1.07 | 0:00'48'' |
| Q20L150_800000  |  241.6M |  52.1 |     150 |  105 | 209.46M |  13.301% | 4.64M | 4.53M |     0.98 | 4.85M |    1.05 |   1.07 | 0:00'59'' |
| Q20L150_1000000 |    302M |  65.1 |     150 |  105 | 261.92M |  13.272% | 4.64M | 4.54M |     0.98 | 4.86M |    1.05 |   1.07 | 0:01'09'' |
| Q20L150_1200000 |  362.4M |  78.1 |     150 |  105 | 314.43M |  13.237% | 4.64M | 4.54M |     0.98 |  4.9M |    1.06 |   1.08 | 0:01'23'' |
| Q20L150_1400000 |  422.8M |  91.1 |     150 |  105 | 366.73M |  13.262% | 4.64M | 4.55M |     0.98 | 5.04M |    1.09 |   1.11 | 0:01'34'' |
| Q20L150_1600000 |  483.2M | 104.1 |     150 |  105 |  419.2M |  13.245% | 4.64M | 4.55M |     0.98 | 5.12M |    1.10 |   1.12 | 0:01'46'' |
| Q20L150_1800000 |  543.6M | 117.1 |     150 |  105 | 471.78M |  13.212% | 4.64M | 4.55M |     0.98 | 5.36M |    1.16 |   1.18 | 0:02'00'' |
| Q20L150_2000000 |    604M | 130.1 |     150 |  105 | 524.15M |  13.219% | 4.64M | 4.56M |     0.98 | 5.71M |    1.23 |   1.25 | 0:02'12'' |
| Q20L150_2200000 |  664.4M | 143.1 |     150 |  105 | 576.74M |  13.194% | 4.64M | 4.56M |     0.98 | 5.87M |    1.26 |   1.29 | 0:02'30'' |
| Q20L150_2400000 |  724.8M | 156.2 |     150 |  105 |  629.2M |  13.190% | 4.64M | 4.57M |     0.98 | 6.27M |    1.35 |   1.37 | 0:02'38'' |
| Q25L130_200000  |  58.94M |  12.7 |     147 |  105 |  55.06M |   6.572% | 4.64M | 4.27M |     0.92 | 4.72M |    1.02 |   1.11 | 0:00'22'' |
| Q25L130_400000  | 117.87M |  25.4 |     147 |  101 | 110.35M |   6.384% | 4.64M | 4.47M |     0.96 | 4.82M |    1.04 |   1.08 | 0:00'35'' |
| Q25L130_600000  |  176.8M |  38.1 |     147 |  101 | 165.52M |   6.379% | 4.64M | 4.51M |     0.97 | 4.82M |    1.04 |   1.07 | 0:00'48'' |
| Q25L130_800000  | 235.75M |  50.8 |     146 |  101 | 220.72M |   6.374% | 4.64M | 4.53M |     0.98 | 4.81M |    1.04 |   1.06 | 0:01'01'' |
| Q25L130_1000000 | 294.68M |  63.5 |     146 |  101 | 275.93M |   6.365% | 4.64M | 4.54M |     0.98 | 4.86M |    1.05 |   1.07 | 0:01'10'' |
| Q25L130_1200000 | 353.62M |  76.2 |     146 |  101 | 331.08M |   6.374% | 4.64M | 4.54M |     0.98 | 4.85M |    1.05 |   1.07 | 0:01'24'' |
| Q25L130_1400000 | 412.57M |  88.9 |     146 |  101 | 386.28M |   6.374% | 4.64M | 4.55M |     0.98 | 4.87M |    1.05 |   1.07 | 0:01'41'' |
| Q25L130_1600000 | 471.51M | 101.6 |     146 |   99 | 441.41M |   6.384% | 4.64M | 4.55M |     0.98 |  4.9M |    1.06 |   1.08 | 0:01'54'' |
| Q25L130_1800000 | 530.45M | 114.3 |     146 |   99 | 496.67M |   6.368% | 4.64M | 4.55M |     0.98 |  4.9M |    1.06 |   1.08 | 0:02'05'' |
| Q25L130_2000000 | 589.39M | 127.0 |     146 |   99 | 551.82M |   6.374% | 4.64M | 4.55M |     0.98 | 4.94M |    1.06 |   1.09 | 0:02'22'' |

| Name            | N50SRclean |   Sum |    # | N50Anchor |   Sum |    # | N50Anchor2 |     Sum |   # | N50Others |     Sum |    # |   RunTime |
|:----------------|-----------:|------:|-----:|----------:|------:|-----:|-----------:|--------:|----:|----------:|--------:|-----:|----------:|
| Q20L150_200000  |       1037 | 2.78M | 2833 |      1579 | 1.27M |  791 |       2380 |  93.97K |  43 |       718 |   1.41M | 1999 | 0:00'30'' |
| Q20L150_400000  |       2218 | 4.18M | 2480 |      2573 | 3.12M | 1341 |       3945 | 248.89K |  73 |       776 | 810.66K | 1066 | 0:00'52'' |
| Q20L150_600000  |       3578 | 4.43M | 1858 |      4035 | 3.73M | 1200 |       4384 | 231.35K |  62 |       805 | 472.87K |  596 | 0:00'51'' |
| Q20L150_800000  |       4588 | 4.55M | 1545 |      4778 | 3.87M | 1073 |       5225 |  301.7K |  70 |       849 | 374.39K |  402 | 0:00'59'' |
| Q20L150_1000000 |       5686 | 4.57M | 1322 |      6017 |    4M |  928 |       5601 | 276.99K |  60 |       839 | 298.38K |  334 | 0:01'02'' |
| Q20L150_1200000 |       6375 | 4.59M | 1155 |      6777 | 4.03M |  853 |       5818 | 327.86K |  66 |       874 | 228.99K |  236 | 0:01'13'' |
| Q20L150_1400000 |       6939 | 4.62M | 1096 |      7254 | 4.04M |  792 |       6102 | 326.17K |  65 |       913 | 258.37K |  239 | 0:01'20'' |
| Q20L150_1600000 |       7199 | 4.72M | 1043 |      7620 | 3.93M |  732 |       6432 | 483.65K |  89 |      2117 |  304.8K |  222 | 0:01'35'' |
| Q20L150_1800000 |       7573 | 4.79M | 1019 |      7942 | 3.67M |  669 |       8529 | 821.29K | 122 |      2080 | 299.21K |  228 | 0:01'33'' |
| Q20L150_2000000 |       7574 | 4.87M | 1006 |      8110 | 3.62M |  643 |       7027 | 847.16K | 137 |      3983 | 408.71K |  226 | 0:01'44'' |
| Q20L150_2200000 |       7806 | 5.02M | 1034 |      7640 | 3.23M |  604 |       9585 |   1.28M | 178 |      4259 | 512.45K |  252 | 0:01'52'' |
| Q20L150_2400000 |       7345 | 5.17M | 1081 |      7491 | 2.97M |  564 |       8213 |   1.48M | 221 |      4740 | 729.88K |  296 | 0:02'01'' |
| Q25L130_200000  |        989 | 2.63M | 2769 |      1531 | 1.12M |  713 |       2261 |  87.05K |  40 |       707 |   1.42M | 2016 | 0:00'31'' |
| Q25L130_400000  |       2157 | 4.16M | 2506 |      2566 | 3.09M | 1338 |       3713 | 224.06K |  65 |       783 | 845.34K | 1103 | 0:00'42'' |
| Q25L130_600000  |       3333 | 4.42M | 1911 |      3754 | 3.67M | 1216 |       4526 |  244.1K |  65 |       811 | 505.28K |  630 | 0:00'54'' |
| Q25L130_800000  |       4431 | 4.52M | 1597 |      4753 |  3.9M | 1098 |       5338 | 280.58K |  67 |       801 | 345.65K |  432 | 0:01'01'' |
| Q25L130_1000000 |       5027 | 4.58M | 1412 |      5305 | 3.92M | 1001 |       6820 | 338.77K |  70 |       878 | 313.23K |  341 | 0:01'15'' |
| Q25L130_1200000 |       5766 | 4.58M | 1269 |      6180 | 4.01M |  910 |       5706 | 307.63K |  63 |       852 | 264.55K |  296 | 0:01'29'' |
| Q25L130_1400000 |       6553 |  4.6M | 1176 |      6946 | 4.07M |  863 |       5708 | 279.05K |  57 |       900 | 253.67K |  256 | 0:01'41'' |
| Q25L130_1600000 |       7496 | 4.64M | 1075 |      7862 | 4.08M |  793 |       6814 |  296.3K |  57 |       967 | 256.57K |  225 | 0:01'39'' |
| Q25L130_1800000 |       7883 | 4.64M | 1035 |      8440 | 4.09M |  763 |       6855 | 309.07K |  60 |       971 | 245.13K |  212 | 0:02'00'' |
| Q25L130_2000000 |       8460 | 4.64M |  994 |      8838 | 4.09M |  720 |       6520 | 308.55K |  59 |       971 | 250.14K |  215 | 0:02'18'' |

## *E. coli*: quality assessment

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

# sort on ref
for part in anchor anchor2 others;
do 
    bash ~/Scripts/cpan/App-Anchr/share/sort_on_ref.sh Q20L150_1000000/sr/pe.${part}.fa 1_genome/genome.fa pe.${part}
    nucmer -l 200 1_genome/genome.fa pe.${part}.fa
    mummerplot -png out.delta -p pe.${part} --medium
done

cp ~/data/alignment/self/ecoli/Results/MG1655/MG1655.multi.fas 1_genome/paralogs.fas

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
    Q20L150_1000000/sr/pe.anchor.fa \
    Q20L150_1000000/guillaumeKUnitigsAtLeast32bases_all.fasta \
    Q25L130_2000000/sr/pe.anchor.fa \
    Q25L130_2000000/guillaumeKUnitigsAtLeast32bases_all.fasta \
    1_genome/paralogs.fas \
    --label "Q20L150_1000000,Q20L150_1000000K,Q25L130_2000000,Q25L130_2000000K,paralogs" \
    -o 9_qa
```

# *Saccharomyces cerevisiae* S288c

* Genome: [Ensembl 82](http://sep2015.archive.ensembl.org/Saccharomyces_cerevisiae/Info/Index)
* Proportion of paralogs: 0.058
* Real
    * N50: 924431
    * S: 12,157,105
    * C: 17
* Original
    * N50: 151
    * S: 2,939,081,214
    * C: 19,464,114
* Trimmed, 120-151 bp
    * N50: 151
    * S: 2,669,549,333
    * C: 17,753,870
* PacBio
    * N50: 8,412
    * S: 820,962,526
    * C: 177,100

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

* Trimmed: minimal length 120 bp.

```bash
mkdir -p ~/data/anchr/s288c/2_illumina/trimmed
cd ~/data/anchr/s288c/2_illumina/trimmed

anchr trim \
    -l 120 -q 20 \
    ../R1.fq.gz ../R2.fq.gz \
    -o stdout \
    | bash
```

* Stats

```bash
cd ~/data/anchr/s288c

faops n50 -S -C 1_genome/genome.fa
faops n50 -S -C 2_illumina/R1.fq.gz         2_illumina/R2.fq.gz
faops n50 -S -C 2_illumina/trimmed/R1.fq.gz 2_illumina/trimmed/R2.fq.gz
faops n50 -S -C 3_pacbio/pacbio.fasta
```

## Scer: down sampling

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

# works on bash 3
ARRAY=( "2_illumina/trimmed:trimmed:8000000")

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

for d in $(perl -e 'for $n (qw{trimmed}) { for $i (1 .. 8) { printf qq{%s_%d }, $n, (1000000 * $i); } }');
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
# masurca
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

for d in $(perl -e 'for $n (qw{trimmed}) { for $i (1 .. 8) { printf qq{%s_%d }, $n, (1000000 * $i); } }');
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue
    fi
    
    rm -fr ${DIR_COUNT}/sr
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh ${DIR_COUNT} 16 false 120
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

for d in $(perl -e 'for $n (qw{trimmed}) { for $i (1 .. 8) { printf qq{%s_%d }, $n, (1000000 * $i); } }');
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

for d in $(perl -e 'for $n (qw{trimmed}) { for $i (1 .. 8) { printf qq{%s_%d }, $n, (1000000 * $i); } }');
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue     
    fi
    
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${DIR_COUNT} \
        >> ${BASE_DIR}/stat2.md

done

cat stat2.md
```

| Name            |   SumFq | CovFq | AvgRead | Kmer |   SumFa | Discard% |   #Subs |  Subs% |  RealG |   EstG | Est/Real |  SumSR | SR/Real | SR/Est |   RunTime |
|:----------------|--------:|------:|--------:|-----:|--------:|---------:|--------:|-------:|-------:|-------:|---------:|-------:|--------:|-------:|----------:|
| trimmed_1000000 | 300.72M |  24.7 |     150 |  105 | 300.16M |   0.187% | 242.27K | 0.081% | 12.16M | 11.43M |     0.94 | 13.17M |    1.08 |   1.15 | 0:01'29'' |
| trimmed_2000000 | 601.46M |  49.5 |     150 |  105 | 600.41M |   0.174% | 480.27K | 0.080% | 12.16M | 11.63M |     0.96 | 14.19M |    1.17 |   1.22 | 0:02'32'' |
| trimmed_3000000 |  902.2M |  74.2 |     150 |  105 | 900.69M |   0.167% | 716.27K | 0.080% | 12.16M | 11.71M |     0.96 | 16.81M |    1.38 |   1.44 | 0:03'32'' |
| trimmed_4000000 |    1.2G |  98.9 |     150 |  105 |    1.2G |   0.161% | 945.81K | 0.079% | 12.16M | 11.83M |     0.97 | 19.97M |    1.64 |   1.69 | 0:04'36'' |
| trimmed_5000000 |    1.5G | 123.7 |     150 |  105 |    1.5G |   0.156% |   1.17M | 0.078% | 12.16M | 11.94M |     0.98 | 24.19M |    1.99 |   2.03 | 0:05'46'' |
| trimmed_6000000 |    1.8G | 148.4 |     150 |  105 |    1.8G |   0.153% |    1.4M | 0.077% | 12.16M | 12.06M |     0.99 | 27.08M |    2.23 |   2.25 | 0:06'49'' |
| trimmed_7000000 |   2.11G | 173.2 |     150 |  105 |    2.1G |   0.149% |   1.62M | 0.077% | 12.16M | 12.18M |     1.00 |  29.4M |    2.42 |   2.41 | 0:08'03'' |
| trimmed_8000000 |   2.41G | 197.9 |     150 |  105 |    2.4G |   0.146% |   1.84M | 0.077% | 12.16M |  12.3M |     1.01 | 31.11M |    2.56 |   2.53 | 0:09'22'' |

| Name            | strict% | N50SRclean |    Sum |    # | N50Anchor |    Sum |    # | N50Anchor2 |     Sum |    # | N50Others |     Sum |    # |   RunTime |
|:----------------|--------:|-----------:|-------:|-----:|----------:|-------:|-----:|-----------:|--------:|-----:|----------:|--------:|-----:|----------:|
| trimmed_1000000 |  91.83% |       1914 | 10.72M | 6932 |      2230 |  8.43M | 4053 |       2402 | 184.12K |   90 |       783 |   2.11M | 2789 | 0:02'45'' |
| trimmed_2000000 |  91.93% |       4630 |  11.8M | 3809 |      4922 | 10.09M | 2643 |       4786 | 808.15K |  205 |       901 | 899.18K |  961 | 0:03'45'' |
| trimmed_3000000 |  91.97% |       7155 | 12.52M | 2790 |      7210 |  8.81M | 1657 |       8725 |   2.64M |  402 |      2252 |   1.07M |  731 | 0:05'05'' |
| trimmed_4000000 |  92.04% |       8299 | 13.56M | 2622 |      8730 |  6.98M | 1122 |       9116 |   4.52M |  643 |      5226 |   2.06M |  857 | 0:06'37'' |
| trimmed_5000000 |  92.11% |       8567 | 14.88M | 2711 |      9411 |  4.88M |  751 |       9220 |   6.13M |  802 |      6227 |   3.87M | 1158 | 0:07'24'' |
| trimmed_6000000 |  92.17% |       7493 | 15.86M | 3102 |      9075 |  3.84M |  594 |       8783 |   6.62M |  909 |      5342 |   5.39M | 1599 | 0:09'00'' |
| trimmed_7000000 |  92.23% |       6752 | 16.62M | 3511 |      8909 |  3.04M |  476 |       7526 |   6.35M |  980 |      5262 |   7.23M | 2055 | 0:10'02'' |
| trimmed_8000000 |  92.28% |       6032 | 17.61M | 4041 |      8184 |  2.21M |  382 |       7149 |   6.32M | 1013 |      4864 |   9.08M | 2646 | 0:11'35'' |

## Scer: quality assessment

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

for part in anchor anchor2 others;
do 
    bash ~/Scripts/cpan/App-Anchr/share/sort_on_ref.sh trimmed_2000000/sr/pe.${part}.fa 1_genome/genome.fa pe.${part}
    nucmer -l 200 1_genome/genome.fa pe.${part}.fa
    mummerplot -png out.delta -p pe.${part} --medium
done

cp ~/data/alignment/self/yeast/Results/S288c/S288c.multi.fas $HOME/data/anchr/s288c/1_genome/paralogs.fas

# mummerplot files
rm *.[fr]plot
rm out.delta
rm *.gp

# quast
quast --no-check \
    -R 1_genome/genome.fa \
    trimmed_2000000/sr/pe.anchor.fa \
    trimmed_3000000/sr/pe.anchor.fa \
    paralogs.fas \
    --label "2000000,3000000,paralogs" \
    -o qa
```

# *Drosophila melanogaster* iso-1

* Genome: [Ensembl 82](http://sep2015.archive.ensembl.org/Drosophila_melanogaster/Info/Index)
* Proportion of paralogs: 0.0531
* Real
    * N50: 25,286,936
    * S: 137,567,477
    * C: 8
* Original
    * N50: 146
    * S: 12,852,672,000
    * C: 88,032,000
* Trimmed, 120-146 bp
    * N50: 146
    * S: 7,291,209,256
    * C: 51,441,736

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

* Trimmed: minimal length 120 bp.

```bash
mkdir -p ~/data/anchr/iso_1/2_illumina/trimmed
cd ~/data/anchr/iso_1/2_illumina/trimmed

anchr trim \
    -l 120 -q 20 \
    ../R1.fq.gz ../R2.fq.gz \
    -o stdout \
    | bash
```

* Stats

```bash
cd ~/data/anchr/iso_1

faops n50 -S -C 1_genome/genome.fa
faops n50 -S -C 2_illumina/R1.fq.gz         2_illumina/R2.fq.gz
faops n50 -S -C 2_illumina/trimmed/R1.fq.gz 2_illumina/trimmed/R2.fq.gz
```

## Dmel: down sampling

```bash
BASE_DIR=$HOME/data/anchr/iso_1
cd ${BASE_DIR}

# works on bash 3
ARRAY=( "2_illumina/trimmed:trimmed:25000000")

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

for d in $(perl -e 'for $n (qw{trimmed}) { for $i (1 .. 5) { printf qq{%s_%d }, $n, (5000000 * $i); } }');
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
        -s 335 -d 33 -p 16
    bash superreads.sh
    popd > /dev/null
done
```

Clear intermediate files.

```bash
# masurca
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

for d in $(perl -e 'for $n (qw{trimmed}) { for $i (1 .. 5) { printf qq{%s_%d }, $n, (5000000 * $i); } }');
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue
    fi
    
    rm -fr ${DIR_COUNT}/sr
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh ${DIR_COUNT} 16 false 120
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

for d in $(perl -e 'for $n (qw{trimmed}) { for $i (1 .. 5) { printf qq{%s_%d }, $n, (5000000 * $i); } }');
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

for d in $(perl -e 'for $n (qw{trimmed}) { for $i (1 .. 5) { printf qq{%s_%d }, $n, (5000000 * $i); } }');
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue     
    fi
    
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${DIR_COUNT} \
        >> ${BASE_DIR}/stat2.md

done

cat stat2.md
```

| Name             | SumFq | CovFq | AvgRead | Kmer | SumFa | Discard% | #Subs |  Subs% |   RealG |    EstG | Est/Real |   SumSR | SR/Real | SR/Est |   RunTime |
|:-----------------|------:|------:|--------:|-----:|------:|---------:|------:|-------:|--------:|--------:|---------:|--------:|--------:|-------:|----------:|
| trimmed_5000000  | 1.42G |  10.3 |     141 |   95 | 1.41G |   0.664% | 1.89M | 0.134% | 137.57M | 104.08M |     0.76 | 118.61M |    0.86 |   1.14 | 0:09'15'' |
| trimmed_10000000 | 2.83G |  20.6 |     140 |   93 | 2.82G |   0.588% | 3.76M | 0.134% | 137.57M | 118.24M |     0.86 | 150.75M |    1.10 |   1.27 | 0:14'12'' |
| trimmed_15000000 | 4.25G |  30.9 |     139 |   93 | 4.23G |   0.564% |  5.6M | 0.133% | 137.57M |  124.5M |     0.91 | 173.24M |    1.26 |   1.39 | 0:20'46'' |
| trimmed_20000000 | 5.67G |  41.2 |     138 |   91 | 5.64G |   0.547% | 7.42M | 0.132% | 137.57M | 128.49M |     0.93 | 196.61M |    1.43 |   1.53 | 0:28'10'' |
| trimmed_25000000 | 7.09G |  51.5 |     137 |   91 | 7.05G |   0.536% |  9.2M | 0.131% | 137.57M | 131.37M |     0.95 | 218.75M |    1.59 |   1.67 | 0:36'08'' |

| Name             | strict% | N50SRclean |     Sum |     # | N50Anchor |    Sum |     # | N50Anchor2 |    Sum |    # | N50Others |    Sum |     # |   RunTime |
|:-----------------|--------:|-----------:|--------:|------:|----------:|-------:|------:|-----------:|-------:|-----:|----------:|-------:|------:|----------:|
| trimmed_5000000  |  83.39% |       1008 |  54.97M | 56301 |      1725 | 22.49M | 12883 |       1552 |  2.55M | 1510 |       718 | 29.93M | 41908 | 0:04'54'' |
| trimmed_10000000 |  83.42% |       1662 |  92.86M | 67622 |      2352 | 56.11M | 25589 |       2577 |  6.36M | 2849 |       776 | 30.39M | 39184 | 0:09'41'' |
| trimmed_15000000 |  83.55% |       2227 | 108.27M | 65205 |      2818 | 68.62M | 27591 |       3762 | 10.24M | 3520 |       840 | 29.42M | 34094 | 0:14'17'' |
| trimmed_20000000 |  83.68% |       2731 | 119.48M | 62645 |      3270 | 72.09M | 26071 |       4367 | 16.15M | 4686 |       933 | 31.25M | 31888 | 0:18'08'' |
| trimmed_25000000 |  83.80% |       2932 | 128.57M | 63780 |      3411 | 69.59M | 24491 |       4829 | 21.49M | 5640 |      1118 | 37.49M | 33649 | 0:21'42'' |

# *Caenorhabditis elegans* N2

* Genome: [Ensembl 82](http://sep2015.archive.ensembl.org/Caenorhabditis_elegans/Info/Index)
* Proportion of paralogs: 0.0472
* Real
    * N50: 17,493,829
    * S: 100,286,401
    * C: 7
* Original
    * N50: 100
    * S: 6,761,709,200
    * C: 67,617,092
* Trimmed, 80-100 bp
    * N50: 100
    * S: 4,760,227,361
    * C: 48,565,296

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

* Trimmed: minimal length 80 bp.

```bash
mkdir -p ~/data/anchr/n2/2_illumina/trimmed
cd ~/data/anchr/n2/2_illumina/trimmed

anchr trim \
    -l 80 -q 20 \
    ../R1.fq.gz ../R2.fq.gz \
    -o stdout \
    | bash
```

* Stats

```bash
cd ~/data/anchr/n2

faops n50 -S -C 1_genome/genome.fa
faops n50 -S -C 2_illumina/R1.fq.gz         2_illumina/R2.fq.gz
faops n50 -S -C 2_illumina/trimmed/R1.fq.gz 2_illumina/trimmed/R2.fq.gz
```

## Cele: down sampling

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

# works on bash 3
ARRAY=( "2_illumina/trimmed:trimmed:25000000")

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

for d in $(perl -e 'for $n (qw{trimmed}) { for $i (1 .. 5) { printf qq{%s_%d }, $n, (5000000 * $i); } }');
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
        -s 200 -d 20 -p 16
    bash superreads.sh
    popd > /dev/null
done
```

Clear intermediate files.

```bash
# masurca
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

for d in $(perl -e 'for $n (qw{trimmed}) { for $i (1 .. 5) { printf qq{%s_%d }, $n, (5000000 * $i); } }');
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue
    fi
    
    rm -fr ${DIR_COUNT}/sr
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh ${DIR_COUNT} 16 false 80
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

for d in $(perl -e 'for $n (qw{trimmed}) { for $i (1 .. 5) { printf qq{%s_%d }, $n, (5000000 * $i); } }');
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

for d in $(perl -e 'for $n (qw{trimmed}) { for $i (1 .. 5) { printf qq{%s_%d }, $n, (5000000 * $i); } }');
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue     
    fi
    
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${DIR_COUNT} \
        >> ${BASE_DIR}/stat2.md

done

cat stat2.md
```

| Name             |   SumFq | CovFq | AvgRead | Kmer |   SumFa | Discard% |   #Subs |  Subs% |   RealG |   EstG | Est/Real |   SumSR | SR/Real | SR/Est |   RunTime |
|:-----------------|--------:|------:|--------:|-----:|--------:|---------:|--------:|-------:|--------:|-------:|---------:|--------:|--------:|-------:|----------:|
| trimmed_5000000  | 980.18M |   9.8 |      97 |   71 | 973.45M |   0.686% | 601.64K | 0.062% | 100.29M | 90.12M |     0.90 |  108.1M |    1.08 |   1.20 | 0:05'14'' |
| trimmed_10000000 |   1.96G |  19.5 |      97 |   71 |   1.95G |   0.481% |   1.03M | 0.053% | 100.29M | 96.45M |     0.96 |  120.9M |    1.21 |   1.25 | 0:09'08'' |
| trimmed_15000000 |   2.94G |  29.3 |      97 |   71 |   2.93G |   0.455% |    1.5M | 0.051% | 100.29M | 97.72M |     0.97 | 133.09M |    1.33 |   1.36 | 0:13'02'' |
| trimmed_20000000 |   3.92G |  39.1 |      97 |   71 |    3.9G |   0.446% |   1.99M | 0.051% | 100.29M | 98.24M |     0.98 |  154.7M |    1.54 |   1.57 | 0:17'11'' |
| trimmed_25000000 |   4.76G |  47.5 |      97 |   71 |   4.74G |   0.444% |   2.41M | 0.051% | 100.29M | 98.52M |     0.98 | 174.67M |    1.74 |   1.77 | 0:20'18'' |

| Name             | strict% | N50SRclean |     Sum |     # | N50Anchor |    Sum |     # | N50Anchor2 |    Sum |    # | N50Others |    Sum |     # |   RunTime |
|:-----------------|--------:|-----------:|--------:|------:|----------:|-------:|------:|-----------:|-------:|-----:|----------:|-------:|------:|----------:|
| trimmed_5000000  |  93.93% |        648 |  15.62M | 23227 |      1195 |   1.4M |  1114 |       1635 | 29.94K |   19 |       630 | 14.19M | 22094 | 0:03'20'' |
| trimmed_10000000 |  94.58% |       1172 |  71.52M | 66496 |      1668 | 38.69M | 23204 |       2023 |  1.93M |  957 |       745 |  30.9M | 42335 | 0:09'38'' |
| trimmed_15000000 |  94.68% |       2197 |  91.87M | 54955 |      2681 | 60.71M | 25750 |       3488 |  8.87M | 2907 |       834 | 22.29M | 26298 | 0:16'19'' |
| trimmed_20000000 |  94.71% |       3297 | 103.02M | 46613 |      3574 | 58.78M | 20284 |       5020 |  20.5M | 5102 |      1066 | 23.74M | 21227 | 0:20'47'' |
| trimmed_25000000 |  94.73% |       3846 | 111.38M | 44620 |      4011 | 51.96M | 16590 |       5379 | 28.72M | 6570 |      1974 |  30.7M | 21460 | 0:26'21'' |

# *Arabidopsis thaliana* Col-0

* Genome: [Ensembl Genomes](http://plants.ensembl.org/Arabidopsis_thaliana/Info/Index)
* Proportion of paralogs: 0.1115
* Real
    * N50: 23,459,830
    * S: 119,667,750
    * C: 7
* Original
    * N50: 100
    * S: 9,978,269,800
    * C: 99,782,698
* Trimmed
    * N50: 100
    * S: 8,600,245,685
    * C: 86,472,520

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

    450

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

* Trimmed: minimal length 80 bp.

```bash
mkdir -p ~/data/anchr/col_0/2_illumina/trimmed
cd ~/data/anchr/col_0/2_illumina/trimmed

anchr trim \
    -l 80 -q 20 \
    ../R1.fq.gz ../R2.fq.gz \
    -o stdout \
    | bash
```

* Stats

```bash
cd ~/data/anchr/col_0

faops n50 -S -C 1_genome/genome.fa
faops n50 -S -C 2_illumina/R1.fq.gz         2_illumina/R2.fq.gz
faops n50 -S -C 2_illumina/trimmed/R1.fq.gz 2_illumina/trimmed/R2.fq.gz
```

## Atha: down sampling

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

# works on bash 3
ARRAY=( "2_illumina/trimmed:trimmed:40000000")

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

for d in $(perl -e 'for $n (qw{trimmed}) { for $i (1 .. 8) { printf qq{%s_%d }, $n, (5000000 * $i); } }');
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

for d in $(perl -e 'for $n (qw{trimmed}) { for $i (1 .. 8) { printf qq{%s_%d }, $n, (5000000 * $i); } }');
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue
    fi
    
    rm -fr ${DIR_COUNT}/sr
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh ${DIR_COUNT} 16 false 80
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

for d in $(perl -e 'for $n (qw{trimmed}) { for $i (1 .. 8) { printf qq{%s_%d }, $n, (5000000 * $i); } }');
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

for d in $(perl -e 'for $n (qw{trimmed}) { for $i (1 .. 8) { printf qq{%s_%d }, $n, (5000000 * $i); } }');
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue     
    fi
    
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${DIR_COUNT} \
        >> ${BASE_DIR}/stat2.md

done

cat stat2.md
```

| Name             |   SumFq | CovFq | AvgRead | Kmer |   SumFa | Discard% |   #Subs |  Subs% |   RealG |    EstG | Est/Real |   SumSR | SR/Real | SR/Est |   RunTime |
|:-----------------|--------:|------:|--------:|-----:|--------:|---------:|--------:|-------:|--------:|--------:|---------:|--------:|--------:|-------:|----------:|
| trimmed_5000000  | 994.55M |   8.3 |      99 |   71 | 991.27M |   0.331% | 931.93K | 0.094% | 119.67M | 101.22M |     0.85 |  95.61M |    0.80 |   0.94 | 0:08'15'' |
| trimmed_10000000 |   1.99G |  16.6 |      99 |   71 |   1.98G |   0.230% |    1.7M | 0.086% | 119.67M | 138.53M |     1.16 |  157.1M |    1.31 |   1.13 | 0:16'17'' |
| trimmed_15000000 |   2.98G |  24.9 |      99 |   71 |   2.98G |   0.228% |   2.55M | 0.086% | 119.67M | 164.08M |     1.37 | 170.97M |    1.43 |   1.04 | 0:23'41'' |
| trimmed_20000000 |   3.98G |  33.2 |      99 |   71 |   3.97G |   0.232% |   3.42M | 0.086% | 119.67M | 189.74M |     1.59 | 185.52M |    1.55 |   0.98 | 0:32'17'' |
| trimmed_25000000 |   4.97G |  41.6 |      99 |   71 |   4.96G |   0.252% |   4.52M | 0.091% | 119.67M | 214.13M |     1.79 | 204.19M |    1.71 |   0.95 | 0:40'54'' |
| trimmed_30000000 |   5.97G |  49.9 |      99 |   71 |   5.95G |   0.255% |   5.43M | 0.091% | 119.67M | 239.49M |     2.00 | 229.96M |    1.92 |   0.96 | 0:49'53'' |
| trimmed_35000000 |   6.96G |  58.2 |      99 |   71 |   6.94G |   0.257% |   6.33M | 0.091% | 119.67M | 264.54M |     2.21 | 262.23M |    2.19 |   0.99 | 0:49'02'' |
| trimmed_40000000 |   7.96G |  66.5 |      99 |   71 |   7.94G |   0.258% |   7.21M | 0.091% | 119.67M | 288.97M |     2.41 | 295.78M |    2.47 |   1.02 | 0:55'58'' |

| Name             | strict% | N50SRclean |     Sum |     # | N50Anchor |     Sum |     # | N50Anchor2 |     Sum |    # | N50Others |     Sum |     # |   RunTime |
|:-----------------|--------:|-----------:|--------:|------:|----------:|--------:|------:|-----------:|--------:|-----:|----------:|--------:|------:|----------:|
| trimmed_5000000  |  92.99% |       1453 | 714.99K |   638 |      3282 | 178.45K |    71 |       3314 |     94K |   32 |       756 | 442.54K |   535 | 0:02'37'' |
| trimmed_10000000 |  93.30% |        677 |  19.89M | 28528 |      1175 |   2.35M |  1893 |       2266 |  87.37K |   43 |       648 |  17.46M | 26592 | 0:07'06'' |
| trimmed_15000000 |  93.31% |       1025 |  71.15M | 73698 |      1461 |  35.41M | 23839 |       1728 | 298.42K |  173 |       733 |  35.44M | 49686 | 0:12'08'' |
| trimmed_20000000 |  93.29% |       1904 |  98.19M | 64053 |      2295 |  76.69M | 36534 |       2129 |   1.45M |  681 |       775 |  20.06M | 26838 | 0:18'54'' |
| trimmed_25000000 |  92.98% |       3625 | 106.58M | 42994 |      4003 |  92.91M | 29147 |       3462 |   3.35M | 1110 |       822 |  10.32M | 12737 | 0:25'30'' |
| trimmed_30000000 |  92.98% |       5965 | 109.59M | 30994 |      6454 |  96.35M | 21184 |       5499 |   5.82M | 1401 |       874 |   7.42M |  8409 | 0:34'15'' |
| trimmed_35000000 |  92.99% |       8308 | 112.12M | 25573 |      8886 |  94.37M | 16363 |       9098 |  10.09M | 1727 |       950 |   7.66M |  7483 | 0:33'18'' |
| trimmed_40000000 |  93.00% |       9802 | 114.38M | 23474 |     10394 |  91.42M | 14061 |      11333 |  14.96M | 2076 |       998 |      8M |  7337 | 0:30'34'' |
