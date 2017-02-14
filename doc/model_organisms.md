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
* Real
    * N50: 4,641,652
    * S: 4,641,652
    * C: 1
* Original
    * N50: 151
    * S: 1,730,299,940
    * C: 11,458,940
* Trimmed, 120-151 bp
    * N50: 151
    * S: 1,138,073,985
    * C: 7,742,458
* Filter, 151 bp
    * N50: 151
    * S: 742,079,836
    * C: 4,914,436
* PacBio
    * N50: 13,982
    * S: 748,508,361
    * C: 87,225

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

## *E. coli*: trim/filter

* Trimmed: minimal length 120 bp.

```bash
mkdir -p ~/data/anchr/e_coli/2_illumina/trimmed
cd ~/data/anchr/e_coli/2_illumina/trimmed

anchr trim \
    -l 120 -q 20 \
    ../R1.fq.gz ../R2.fq.gz \
    -o stdout \
    | bash
```

* Filter: discard any reads with trimmed parts.

```bash
mkdir -p ~/data/anchr/e_coli/2_illumina/filter
cd ~/data/anchr/e_coli/2_illumina/filter

anchr trim \
    -l 151 -q 20 \
    ../R1.fq.gz ../R2.fq.gz \
    -o stdout \
    | bash
```

* Stats

```bash
cd ~/data/anchr/e_coli

faops n50 -S -C 1_genome/genome.fa
faops n50 -S -C 2_illumina/R1.fq.gz         2_illumina/R2.fq.gz
faops n50 -S -C 2_illumina/trimmed/R1.fq.gz 2_illumina/trimmed/R2.fq.gz
faops n50 -S -C 2_illumina/filter/R1.fq.gz  2_illumina/filter/R1.fq.gz
faops n50 -S -C 3_pacbio/pacbio.fasta
```

## *E. coli*: down sampling

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

# works on bash 3
ARRAY=( "2_illumina/trimmed:trimmed:3800000"
        "2_illumina/filter:filter:2400000")

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

for d in $(perl -e 'for $n (qw{trimmed filter}) { for $i (1 .. 25) { printf qq{%s_%d }, $n, (200000 * $i); } }');
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

for d in $(perl -e 'for $n (qw{trimmed filter}) { for $i (1 .. 25) { printf qq{%s_%d }, $n, (200000 * $i); } }');
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

## *E. coli*: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

REAL_G=4641652

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

for d in $(perl -e 'for $n (qw{trimmed filter}) { for $i (1 .. 25) { printf qq{%s_%d }, $n, (200000 * $i); } }');
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

for d in $(perl -e 'for $n (qw{trimmed filter}) { for $i (1 .. 25) { printf qq{%s_%d }, $n, (200000 * $i); } }');
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

| Name            |   SumFq | CovFq | AvgRead | Kmer |   SumFa | Discard% |   #Subs |  Subs% | RealG |  EstG | Est/Real | SumSR | SR/Real | SR/Est |   RunTime |
|:----------------|--------:|------:|--------:|-----:|--------:|---------:|--------:|-------:|------:|------:|---------:|------:|--------:|-------:|----------:|
| trimmed_200000  |   58.8M |  12.7 |     147 |  105 |  58.75M |   0.086% |  56.34K | 0.096% | 4.64M | 4.49M |     0.97 | 5.12M |    1.10 |   1.14 | 0:00'33'' |
| trimmed_400000  |  117.6M |  25.3 |     147 |  105 | 117.51M |   0.071% | 111.83K | 0.095% | 4.64M | 4.54M |     0.98 | 4.93M |    1.06 |   1.08 | 0:00'45'' |
| trimmed_600000  | 176.41M |  38.0 |     146 |  105 | 176.28M |   0.072% | 168.16K | 0.095% | 4.64M | 4.56M |     0.98 | 4.88M |    1.05 |   1.07 | 0:00'59'' |
| trimmed_800000  | 235.18M |  50.7 |     146 |  105 | 235.01M |   0.072% | 223.33K | 0.095% | 4.64M | 4.56M |     0.98 | 4.97M |    1.07 |   1.09 | 0:01'14'' |
| trimmed_1000000 |    294M |  63.3 |     146 |  105 | 293.79M |   0.070% | 279.12K | 0.095% | 4.64M | 4.56M |     0.98 | 5.16M |    1.11 |   1.13 | 0:01'24'' |
| trimmed_1200000 | 352.78M |  76.0 |     146 |  105 | 352.53M |   0.071% | 335.28K | 0.095% | 4.64M | 4.57M |     0.98 | 5.26M |    1.13 |   1.15 | 0:01'29'' |
| trimmed_1400000 | 411.56M |  88.7 |     146 |  105 | 411.26M |   0.072% | 391.04K | 0.095% | 4.64M | 4.57M |     0.99 | 5.63M |    1.21 |   1.23 | 0:01'45'' |
| trimmed_1600000 | 470.38M | 101.3 |     146 |  105 | 470.05M |   0.070% | 445.56K | 0.095% | 4.64M | 4.58M |     0.99 |  5.9M |    1.27 |   1.29 | 0:02'02'' |
| trimmed_1800000 | 529.16M | 114.0 |     146 |  105 | 528.78M |   0.071% | 499.33K | 0.094% | 4.64M | 4.59M |     0.99 | 6.34M |    1.37 |   1.38 | 0:02'07'' |
| trimmed_2000000 | 587.96M | 126.7 |     146 |  105 | 587.54M |   0.071% | 555.07K | 0.094% | 4.64M | 4.59M |     0.99 |  6.8M |    1.47 |   1.48 | 0:02'21'' |
| trimmed_2200000 | 646.77M | 139.3 |     146 |  105 |  646.3M |   0.072% | 611.18K | 0.095% | 4.64M |  4.6M |     0.99 |  7.1M |    1.53 |   1.54 | 0:02'28'' |
| trimmed_2400000 | 705.55M | 152.0 |     146 |  105 | 705.03M |   0.074% | 665.83K | 0.094% | 4.64M | 4.61M |     0.99 | 7.38M |    1.59 |   1.60 | 0:02'56'' |
| trimmed_2600000 | 764.34M | 164.7 |     146 |  105 | 763.78M |   0.074% | 720.05K | 0.094% | 4.64M | 4.61M |     0.99 | 7.79M |    1.68 |   1.69 | 0:02'52'' |
| trimmed_2800000 | 823.16M | 177.3 |     145 |  101 | 822.55M |   0.075% | 773.45K | 0.094% | 4.64M | 4.62M |     1.00 |  8.4M |    1.81 |   1.82 | 0:03'04'' |
| trimmed_3000000 | 881.92M | 190.0 |     145 |  101 | 881.26M |   0.075% | 827.23K | 0.094% | 4.64M | 4.63M |     1.00 | 8.49M |    1.83 |   1.83 | 0:03'16'' |
| trimmed_3200000 | 940.74M | 202.7 |     145 |  101 | 940.02M |   0.077% | 881.84K | 0.094% | 4.64M | 4.64M |     1.00 |  8.7M |    1.87 |   1.87 | 0:03'32'' |
| trimmed_3400000 | 999.54M | 215.3 |     145 |   99 | 998.77M |   0.077% | 934.24K | 0.094% | 4.64M | 4.65M |     1.00 | 8.98M |    1.93 |   1.93 | 0:03'54'' |
| trimmed_3600000 |   1.06G | 228.0 |     145 |   99 |   1.06G |   0.078% |  988.7K | 0.093% | 4.64M | 4.67M |     1.01 | 9.11M |    1.96 |   1.95 | 0:03'54'' |
| trimmed_3800000 |   1.12G | 240.7 |     145 |   97 |   1.12G |   0.079% |   1.04M | 0.093% | 4.64M | 4.68M |     1.01 | 9.29M |    2.00 |   1.99 | 0:04'13'' |
| filter_200000   |   60.4M |  13.0 |     151 |  105 |  60.34M |   0.093% |  56.92K | 0.094% | 4.64M | 4.38M |     0.94 | 4.73M |    1.02 |   1.08 | 0:00'36'' |
| filter_400000   |  120.8M |  26.0 |     151 |  105 | 120.71M |   0.075% | 113.84K | 0.094% | 4.64M |  4.5M |     0.97 | 4.81M |    1.04 |   1.07 | 0:00'46'' |
| filter_600000   |  181.2M |  39.0 |     151 |  105 | 181.06M |   0.076% | 172.33K | 0.095% | 4.64M | 4.53M |     0.98 | 4.82M |    1.04 |   1.07 | 0:01'20'' |
| filter_800000   |  241.6M |  52.1 |     151 |  105 | 241.43M |   0.072% | 229.13K | 0.095% | 4.64M | 4.54M |     0.98 | 4.87M |    1.05 |   1.07 | 0:01'16'' |
| filter_1000000  |    302M |  65.1 |     151 |  105 | 301.79M |   0.070% | 285.75K | 0.095% | 4.64M | 4.55M |     0.98 | 4.94M |    1.07 |   1.09 | 0:01'16'' |
| filter_1200000  |  362.4M |  78.1 |     151 |  105 | 362.15M |   0.070% | 343.66K | 0.095% | 4.64M | 4.55M |     0.98 | 5.03M |    1.08 |   1.11 | 0:01'38'' |
| filter_1400000  |  422.8M |  91.1 |     151 |  105 |  422.5M |   0.072% |  399.5K | 0.095% | 4.64M | 4.56M |     0.98 | 5.13M |    1.11 |   1.13 | 0:01'49'' |
| filter_1600000  |  483.2M | 104.1 |     151 |  105 | 482.85M |   0.072% |  456.8K | 0.095% | 4.64M | 4.57M |     0.98 |  5.3M |    1.14 |   1.16 | 0:02'03'' |
| filter_1800000  |  543.6M | 117.1 |     151 |  105 | 543.22M |   0.071% | 513.77K | 0.095% | 4.64M | 4.57M |     0.98 | 5.55M |    1.19 |   1.21 | 0:02'19'' |
| filter_2000000  |    604M | 130.1 |     151 |  105 | 603.57M |   0.071% | 569.58K | 0.094% | 4.64M | 4.57M |     0.99 | 5.73M |    1.23 |   1.25 | 0:02'35'' |
| filter_2200000  |  664.4M | 143.1 |     151 |  105 | 663.93M |   0.071% |    626K | 0.094% | 4.64M | 4.58M |     0.99 |  6.1M |    1.31 |   1.33 | 0:02'27'' |
| filter_2400000  |  724.8M | 156.2 |     151 |  105 | 724.28M |   0.071% |  681.8K | 0.094% | 4.64M | 4.59M |     0.99 | 6.46M |    1.39 |   1.41 | 0:02'39'' |

| Name            | strict% | N50SRclean |   Sum |    # | N50Anchor |     Sum |    # | N50Anchor2 |     Sum |   # | N50Others |     Sum |    # |   RunTime |
|:----------------|--------:|-----------:|------:|-----:|----------:|--------:|-----:|-----------:|--------:|----:|----------:|--------:|-----:|----------:|
| trimmed_200000  |  87.41% |       1012 |  3.2M | 3310 |      1538 |   1.44M |  921 |       1471 |  82.34K |  53 |       745 |   1.68M | 2336 | 0:01'08'' |
| trimmed_400000  |  87.51% |       3189 | 4.49M | 2003 |      3494 |   3.74M | 1295 |       4693 |  240.7K |  68 |       804 | 509.74K |  640 | 0:01'32'' |
| trimmed_600000  |  87.51% |       6287 | 4.62M | 1181 |      6606 |   4.06M |  859 |       6108 | 306.18K |  64 |       883 | 252.55K |  258 | 0:01'50'' |
| trimmed_800000  |  87.54% |       8696 | 4.66M |  910 |      9113 |   4.06M |  667 |       7575 | 417.14K |  69 |       951 |  181.6K |  174 | 0:02'01'' |
| trimmed_1000000 |  87.54% |      10475 |  4.7M |  746 |     10498 |      4M |  562 |      10568 | 545.87K |  76 |      2086 |  152.2K |  108 | 0:02'21'' |
| trimmed_1200000 |  87.53% |      11605 | 4.75M |  692 |     11978 |   3.93M |  501 |      11085 | 649.04K |  79 |      3355 | 179.28K |  112 | 0:02'46'' |
| trimmed_1400000 |  87.53% |      12763 | 4.85M |  627 |     12294 |   3.61M |  422 |      17578 | 984.97K |  98 |     11574 | 263.69K |  107 | 0:03'02'' |
| trimmed_1600000 |  87.56% |      12918 | 4.98M |  623 |     12480 |   3.41M |  391 |      14272 |   1.23M | 114 |     10685 | 349.46K |  118 | 0:03'15'' |
| trimmed_1800000 |  87.61% |      12332 | 5.19M |  673 |     12059 |   3.08M |  378 |      12824 |    1.5M | 150 |     11676 | 612.78K |  145 | 0:03'25'' |
| trimmed_2000000 |  87.61% |      11370 | 5.48M |  714 |     11388 |    2.6M |  328 |      11923 |   1.95M | 193 |      9638 | 928.27K |  193 | 0:03'50'' |
| trimmed_2200000 |  87.59% |      10636 | 5.51M |  771 |     11212 |    2.4M |  306 |      11051 |   2.06M | 226 |      8343 |   1.05M |  239 | 0:04'03'' |
| trimmed_2400000 |  87.60% |       9124 | 5.73M |  865 |     10202 |   2.22M |  298 |       9969 |   2.13M | 261 |      7458 |   1.38M |  306 | 0:04'08'' |
| trimmed_2600000 |  87.62% |       8455 | 6.02M |  989 |      9312 |   1.79M |  261 |       8779 |   2.43M | 329 |      6943 |   1.79M |  399 | 0:04'24'' |
| trimmed_2800000 |  87.64% |       7816 | 6.37M | 1095 |      9077 |   1.39M |  210 |       8270 |   2.77M | 386 |      6618 |   2.22M |  499 | 0:04'30'' |
| trimmed_3000000 |  87.66% |       6557 | 6.46M | 1264 |      8264 |   1.26M |  203 |       7701 |   2.65M | 406 |      5147 |   2.55M |  655 | 0:04'43'' |
| trimmed_3200000 |  87.67% |       6150 | 6.71M | 1459 |      7627 |   1.04M |  182 |       6940 |   2.61M | 430 |      4875 |   3.07M |  847 | 0:04'54'' |
| trimmed_3400000 |  87.70% |       5364 | 7.05M | 1656 |      7002 | 857.15K |  173 |       6554 |   2.41M | 424 |      4448 |   3.79M | 1059 | 0:05'22'' |
| trimmed_3600000 |  87.70% |       4707 | 7.11M | 1876 |      5785 | 706.19K |  159 |       6048 |   2.36M | 449 |      3924 |   4.04M | 1268 | 0:05'37'' |
| trimmed_3800000 |  87.71% |       4289 | 7.25M | 2078 |      5518 |  723.8K |  167 |       5856 |   2.15M | 428 |      3514 |   4.37M | 1483 | 0:05'46'' |
| filter_200000   |  87.34% |       1168 | 3.26M | 3037 |      1731 |   1.64M |  942 |       1749 | 178.01K |  98 |       737 |   1.44M | 1997 | 0:01'07'' |
| filter_400000   |  87.32% |       2711 | 4.32M | 2179 |      3221 |   3.42M | 1271 |       4025 | 282.73K |  91 |       781 | 623.37K |  817 | 0:01'36'' |
| filter_600000   |  87.21% |       4358 | 4.51M | 1591 |      4839 |   3.87M | 1078 |       4276 | 287.44K |  81 |       800 | 344.21K |  432 | 0:01'49'' |
| filter_800000   |  87.24% |       5948 | 4.58M | 1285 |      6337 |   4.03M |  912 |       4588 | 267.68K |  66 |       855 |  281.5K |  307 | 0:02'03'' |
| filter_1000000  |  87.27% |       6778 | 4.61M | 1120 |      7186 |    4.1M |  818 |       5465 | 259.71K |  60 |       897 | 247.67K |  242 | 0:02'22'' |
| filter_1200000  |  87.24% |       7672 | 4.64M | 1006 |      8044 |   4.06M |  745 |       6252 | 369.37K |  64 |       954 | 216.36K |  197 | 0:02'40'' |
| filter_1400000  |  87.27% |       7950 | 4.68M |  961 |      8396 |   4.01M |  703 |       7121 |  434.1K |  77 |      1416 | 233.34K |  181 | 0:02'58'' |
| filter_1600000  |  87.28% |       8522 | 4.79M |  928 |      8532 |   3.75M |  642 |       8439 | 720.05K | 109 |      4726 | 322.59K |  177 | 0:03'13'' |
| filter_1800000  |  87.28% |       8903 | 4.91M |  904 |      8730 |   3.46M |  580 |      10655 |   1.13M | 139 |      3987 | 318.23K |  185 | 0:03'25'' |
| filter_2000000  |  87.30% |       8473 | 4.96M |  927 |      8462 |    3.4M |  566 |       9368 |   1.14M | 149 |      4394 | 427.02K |  212 | 0:03'41'' |
| filter_2200000  |  87.32% |       8666 | 5.14M |  945 |      8666 |   3.02M |  511 |       9207 |   1.45M | 192 |      7343 | 677.79K |  242 | 0:04'05'' |
| filter_2400000  |  87.33% |       7851 | 5.26M | 1001 |      7964 |   2.73M |  481 |       9277 |   1.77M | 246 |      5905 |  757.9K |  274 | 0:04'14'' |

## *E. coli*: quality assessment

http://www.opiniomics.org/generate-a-single-contig-hybrid-assembly-of-e-coli-using-miseq-and-minion-data/

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

# sort on ref
for part in anchor anchor2 others;
do 
    bash ~/Scripts/cpan/App-Anchr/share/sort_on_ref.sh trimmed_800000/sr/pe.${part}.fa 1_genome/genome.fa pe.${part}
    nucmer -l 200 1_genome/genome.fa pe.${part}.fa
    mummerplot -png out.delta -p pe.${part} --medium
done

cp ~/data/alignment/self/ecoli/Results/MG1655/MG1655.multi.fas paralog.fas

cp ~/data/pacbio/ecoli_p6c4/2-asm-falcon/p_ctg.fa falcon.fa

nucmer -l 200 NC_000913.fa falcon.fa
mummerplot -png out.delta -p falcon --medium

# mummerplot files
rm *.[fr]plot
rm out.delta
rm *.gp

# quast
quast --no-check \
    -R 1_genome/genome.fa \
    trimmed_800000/sr/pe.anchor.fa \
    filter_1400000/sr/pe.anchor.fa \
    paralog.fas \
    --label "trimmed,filter,paralog" \
    -o qa
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
cd ~/data/anchr/s288c/3_pacbio/untar
tar xvfz ERR1655118_ERR1655118_hdf5.tgz --directory untar
tar xvfz ERR1655120_ERR1655120_hdf5.tgz --directory untar
tar xvfz ERR1655122_ERR1655122_hdf5.tgz --directory untar
tar xvfz ERR1655124_ERR1655124_hdf5.tgz --directory untar

# bax2bam
source ~/share/pitchfork/deployment/setup-env.sh
mkdir -p ~/data/anchr/s288c/3_pacbio/bam
cd ~/data/anchr/s288c/3_pacbio/bam

for movie in m150412 m150415 m150417 m150421;
do 
    bax2bam ~/data/anchr/s288c/3_pacbio/untar/${movie}*.bax.h5
done

# bam to fasta
mkdir -p ~/data/anchr/s288c/3_pacbio/fasta

for movie in m150412 m150415 m150417 m150421;
do 
    samtools fasta \
        ~/data/anchr/s288c/3_pacbio/bam/${movie}*.subreads.bam \
        > ~/data/anchr/s288c/3_pacbio/fasta/${movie}.fasta
done

#N50     8248
#S       2585714835
#C       600574
faops n50 -S -C ~/data/pacbio/rawdata/S288c/fasta/*.fasta
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

cp ~/data/alignment/self/yeast/Results/S288c/S288c.multi.fas paralog.fas

# mummerplot files
rm *.[fr]plot
rm out.delta
rm *.gp

# quast
quast --no-check \
    -R 1_genome/genome.fa \
    trimmed_2000000/sr/pe.anchor.fa \
    trimmed_3000000/sr/pe.anchor.fa \
    paralog.fas \
    --label "2000000,3000000,paralog" \
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
# masurca
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
