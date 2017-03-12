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
    - [Generate super-reads](#generate-super-reads)
    - [Create anchors](#create-anchors)
    - [Results](#results)
    - [Quality assessment](#quality-assessment)
    - [anchor-long](#anchor-long)


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

# canu requires gnuplot 5 while mummer requires gnuplot 4
brew install canu

brew unlink gnuplot4
brew install gnuplot
brew unlink gnuplot

brew link gnuplot4
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

## Combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 120, 130, 140 and 150

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

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

cd ${BASE_DIR}
parallel --no-run-if-empty -j 6 "
        mkdir -p 2_illumina/Q{1}L{2}
        cd 2_illumina/Q{1}L{2}
        
        anchr trim \
            --noscythe \
            -q {1} -l {2} \
            ../R1.scythe.fq.gz ../R2.scythe.fq.gz \
            -o stdout \
            | bash
    " ::: 20 25 30 ::: 120 130 140 150

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
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "PacBio";   faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md

for qual in 20 25 30; do
    for len in 120 130 140 150; do
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
| Illumina |     151 | 1730299940 | 11458940 |
| PacBio   |   13982 |  748508361 |    87225 |
| scythe   |     151 | 1724565376 | 11458940 |
| Q20L120  |     151 | 1138097252 |  7742646 |
| Q20L130  |     151 |  977384738 |  6561892 |
| Q20L140  |     151 |  786030615 |  5213876 |
| Q20L150  |     151 |  742742028 |  4918836 |
| Q25L120  |     151 |  839150352 |  5820278 |
| Q25L130  |     151 |  634128805 |  4303670 |
| Q25L140  |     151 |  421124326 |  2798656 |
| Q25L150  |     151 |  373356309 |  2472564 |
| Q30L120  |     140 |  383365150 |  2755884 |
| Q30L130  |     151 |  211952097 |  1468318 |
| Q30L140  |     151 |   92578231 |   617860 |
| Q30L150  |     151 |   69756203 |   461964 |

## Down sampling

过高的 coverage 会造成不好的影响. SGA 的文档里也说了类似的事情.

> Very highly-represented sequences (>1000X) can cause problems for SGA... In these cases, it is
> worth considering pre-filtering the data...

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

ARRAY=( "2_illumina:original:4000000"
        "2_illumina/Q20L120:Q20L120:3800000"
        "2_illumina/Q20L130:Q20L130:3200000"
        "2_illumina/Q20L140:Q20L140:2600000"
        "2_illumina/Q20L150:Q20L150:2400000"
        "2_illumina/Q25L120:Q25L120:2800000"
        "2_illumina/Q25L130:Q25L130:2000000"
        "2_illumina/Q25L140:Q25L140:1200000"
        "2_illumina/Q25L150:Q25L150:1200000"
        "2_illumina/Q30L120:Q30L120:1200000"
        "2_illumina/Q30L130:Q30L130:600000"
        "2_illumina/Q30L140:Q30L140:200000"
        "2_illumina/Q30L150:Q30L150:200000")

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    GROUP_MAX=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[2];')
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    for count in $(perl -e 'print 200000 * $_, q{ } for 1 .. 20');
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

## Generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}


perl -e '
    for my $n (
        qw{
        original
        Q20L120 Q20L130 Q20L140 Q20L150
        Q25L120 Q25L130 Q25L140 Q25L150
        Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        for my $i ( 1 .. 25 ) {
            printf qq{%s_%d\n}, $n, ( 200000 * $i );
        }
    }
    ' \
    | parallel --no-run-if-empty -j 6 "
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
        Q20L120 Q20L130 Q20L140 Q20L150
        Q25L120 Q25L130 Q25L140 Q25L150
        Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        for my $i ( 1 .. 25 ) {
            printf qq{%s_%d\n}, $n, ( 200000 * $i );
        }
    }
    ' \
    | parallel --no-run-if-empty -j 4 "
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
        Q20L120 Q20L130 Q20L140 Q20L150
        Q25L120 Q25L130 Q25L140 Q25L150
        Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        for my $i ( 1 .. 25 ) {
            printf qq{%s_%d\n}, $n, ( 200000 * $i );
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
        Q20L120 Q20L130 Q20L140 Q20L150
        Q25L120 Q25L130 Q25L140 Q25L150
        Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        for my $i ( 1 .. 25 ) {
            printf qq{%s_%d\n}, $n, ( 200000 * $i );
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
| original_200000  |   60.4M |  13.0 |     151 |   75 |  38.25M |  36.669% | 4.64M | 4.45M |     0.96 |  4.74M |     0 | 0:00'35'' |
| original_400000  |  120.8M |  26.0 |     151 |   75 |  76.08M |  37.018% | 4.64M | 4.57M |     0.98 |  4.94M |     0 | 0:00'51'' |
| original_600000  |  181.2M |  39.0 |     151 |   75 | 114.43M |  36.851% | 4.64M |  4.6M |     0.99 |  5.23M |     0 | 0:01'07'' |
| original_800000  |  241.6M |  52.1 |     151 |   75 | 153.19M |  36.593% | 4.64M | 4.64M |     1.00 |  5.58M |     0 | 0:01'28'' |
| original_1000000 |    302M |  65.1 |     151 |   75 | 192.04M |  36.411% | 4.64M | 4.68M |     1.01 |  5.99M |     0 | 0:01'30'' |
| original_1200000 |  362.4M |  78.1 |     151 |   75 | 231.29M |  36.177% | 4.64M | 4.72M |     1.02 |  6.49M |     0 | 0:01'33'' |
| original_1400000 |  422.8M |  91.1 |     151 |   75 | 270.56M |  36.008% | 4.64M | 4.77M |     1.03 |  7.03M |     0 | 0:01'43'' |
| original_1600000 |  483.2M | 104.1 |     151 |   75 | 309.73M |  35.900% | 4.64M | 4.83M |     1.04 |  7.61M |     0 | 0:02'00'' |
| original_1800000 |  543.6M | 117.1 |     151 |   75 | 349.44M |  35.717% | 4.64M | 4.88M |     1.05 |   8.2M |     0 | 0:02'20'' |
| original_2000000 |    604M | 130.1 |     151 |   75 | 389.03M |  35.591% | 4.64M | 4.94M |     1.06 |  8.95M |     0 | 0:02'30'' |
| original_2200000 |  664.4M | 143.1 |     151 |   75 | 428.95M |  35.438% | 4.64M | 5.01M |     1.08 |  9.75M |     0 | 0:02'44'' |
| original_2400000 |  724.8M | 156.2 |     151 |   75 | 469.08M |  35.282% | 4.64M | 5.08M |     1.09 | 10.67M |     0 | 0:03'04'' |
| original_2600000 |  785.2M | 169.2 |     151 |   75 | 508.97M |  35.180% | 4.64M | 5.15M |     1.11 | 11.65M |     0 | 0:03'31'' |
| original_2800000 |  845.6M | 182.2 |     151 |   75 |  549.2M |  35.052% | 4.64M | 5.22M |     1.12 | 12.87M |     0 | 0:03'25'' |
| original_3000000 |    906M | 195.2 |     151 |   75 | 589.74M |  34.907% | 4.64M |  5.3M |     1.14 | 14.26M |     0 | 0:03'44'' |
| original_3200000 |  966.4M | 208.2 |     151 |   75 |  630.1M |  34.799% | 4.64M | 5.38M |     1.16 |  15.8M |     0 | 0:04'04'' |
| original_3400000 |   1.03G | 221.2 |     151 |   75 | 671.04M |  34.648% | 4.64M | 5.47M |     1.18 |  17.6M |     0 | 0:04'23'' |
| original_3600000 |   1.09G | 234.2 |     151 |   75 | 711.81M |  34.528% | 4.64M | 5.56M |     1.20 | 19.81M |     0 | 0:04'30'' |
| original_3800000 |   1.15G | 247.2 |     151 |   75 | 752.53M |  34.426% | 4.64M | 5.65M |     1.22 | 22.19M |     0 | 0:04'37'' |
| original_4000000 |   1.21G | 260.3 |     151 |   75 | 793.52M |  34.311% | 4.64M | 5.74M |     1.24 | 24.98M |     0 | 0:04'53'' |
| Q20L120_200000   |  58.79M |  12.7 |     147 |  105 |  51.18M |  12.949% | 4.64M | 4.46M |     0.96 |  5.33M |     0 | 0:00'37'' |
| Q20L120_400000   |  117.6M |  25.3 |     147 |  105 | 102.19M |  13.104% | 4.64M | 4.54M |     0.98 |   4.9M |     0 | 0:00'46'' |
| Q20L120_600000   | 176.38M |  38.0 |     146 |  105 | 153.28M |  13.097% | 4.64M | 4.55M |     0.98 |  4.78M |     0 | 0:01'13'' |
| Q20L120_800000   | 235.18M |  50.7 |     146 |  105 | 204.42M |  13.080% | 4.64M | 4.55M |     0.98 |  4.71M |     0 | 0:01'14'' |
| Q20L120_1000000  | 293.99M |  63.3 |     146 |  105 | 255.42M |  13.119% | 4.64M | 4.56M |     0.98 |  4.71M |     0 | 0:01'34'' |
| Q20L120_1200000  | 352.79M |  76.0 |     146 |  105 | 306.49M |  13.123% | 4.64M | 4.56M |     0.98 |  4.72M |     0 | 0:01'28'' |
| Q20L120_1400000  | 411.57M |  88.7 |     146 |  105 | 357.63M |  13.107% | 4.64M | 4.56M |     0.98 |  4.74M |     0 | 0:01'40'' |
| Q20L120_1600000  | 470.38M | 101.3 |     146 |  105 | 408.87M |  13.076% | 4.64M | 4.56M |     0.98 |  4.75M |     0 | 0:01'51'' |
| Q20L120_1800000  | 529.16M | 114.0 |     146 |  105 | 459.95M |  13.079% | 4.64M | 4.57M |     0.98 |  4.79M |     0 | 0:01'58'' |
| Q20L120_2000000  | 587.97M | 126.7 |     146 |  105 | 511.21M |  13.056% | 4.64M | 4.57M |     0.99 |  4.82M |     0 | 0:02'13'' |
| Q20L120_2200000  | 646.76M | 139.3 |     146 |  105 | 562.37M |  13.048% | 4.64M | 4.58M |     0.99 |  4.86M |     0 | 0:02'26'' |
| Q20L120_2400000  | 705.56M | 152.0 |     146 |  105 | 613.66M |  13.024% | 4.64M | 4.58M |     0.99 |  4.92M |     0 | 0:02'27'' |
| Q20L120_2600000  | 764.34M | 164.7 |     146 |  105 | 664.85M |  13.017% | 4.64M | 4.59M |     0.99 |  4.98M |     0 | 0:02'39'' |
| Q20L120_2800000  | 823.13M | 177.3 |     145 |  101 | 716.22M |  12.988% | 4.64M | 4.59M |     0.99 |  5.02M |     0 | 0:02'50'' |
| Q20L120_3000000  | 881.96M | 190.0 |     145 |  101 | 767.44M |  12.985% | 4.64M |  4.6M |     0.99 |  5.08M |     0 | 0:03'01'' |
| Q20L120_3200000  | 940.75M | 202.7 |     145 |  101 |  818.8M |  12.963% | 4.64M |  4.6M |     0.99 |  5.14M |     0 | 0:03'20'' |
| Q20L120_3400000  | 999.54M | 215.3 |     145 |   99 | 870.05M |  12.955% | 4.64M | 4.61M |     0.99 |  5.21M |     0 | 0:03'30'' |
| Q20L120_3600000  |   1.06G | 228.0 |     145 |   99 | 921.51M |  12.928% | 4.64M | 4.62M |     0.99 |  5.29M |     0 | 0:03'46'' |
| Q20L120_3800000  |   1.12G | 240.7 |     145 |   99 | 972.93M |  12.908% | 4.64M | 4.62M |     1.00 |  5.38M |     0 | 0:04'42'' |
| Q20L130_200000   |  59.58M |  12.8 |     149 |  105 |  51.88M |  12.920% | 4.64M |  4.4M |     0.95 |  5.17M |     0 | 0:00'32'' |
| Q20L130_400000   | 119.17M |  25.7 |     148 |  105 | 103.52M |  13.125% | 4.64M | 4.52M |     0.97 |  4.85M |     0 | 0:00'49'' |
| Q20L130_600000   | 178.73M |  38.5 |     148 |  105 | 155.23M |  13.150% | 4.64M | 4.54M |     0.98 |  4.76M |     0 | 0:01'06'' |
| Q20L130_800000   | 238.32M |  51.3 |     148 |  105 | 207.08M |  13.110% | 4.64M | 4.55M |     0.98 |  4.72M |     0 | 0:01'07'' |
| Q20L130_1000000  | 297.89M |  64.2 |     148 |  105 | 258.74M |  13.143% | 4.64M | 4.55M |     0.98 |  4.71M |     0 | 0:01'35'' |
| Q20L130_1200000  | 357.48M |  77.0 |     148 |  105 | 310.32M |  13.192% | 4.64M | 4.56M |     0.98 |  4.71M |     0 | 0:01'40'' |
| Q20L130_1400000  | 417.05M |  89.8 |     148 |  105 | 362.23M |  13.144% | 4.64M | 4.56M |     0.98 |  4.73M |     0 | 0:01'54'' |
| Q20L130_1600000  | 476.63M | 102.7 |     148 |  105 |    414M |  13.139% | 4.64M | 4.56M |     0.98 |  4.75M |     0 | 0:02'03'' |
| Q20L130_1800000  |  536.2M | 115.5 |     148 |  105 | 465.84M |  13.123% | 4.64M | 4.57M |     0.98 |  4.78M |     0 | 0:02'35'' |
| Q20L130_2000000  | 595.79M | 128.4 |     148 |  105 | 517.68M |  13.111% | 4.64M | 4.57M |     0.98 |  4.81M |     0 | 0:02'44'' |
| Q20L130_2200000  | 655.38M | 141.2 |     148 |  105 | 569.69M |  13.074% | 4.64M | 4.57M |     0.99 |  4.86M |     0 | 0:02'16'' |
| Q20L130_2400000  | 714.95M | 154.0 |     148 |  105 | 621.51M |  13.070% | 4.64M | 4.58M |     0.99 |  4.91M |     0 | 0:02'27'' |
| Q20L130_2600000  | 774.53M | 166.9 |     148 |  105 | 673.44M |  13.052% | 4.64M | 4.58M |     0.99 |  4.95M |     0 | 0:02'38'' |
| Q20L130_2800000  | 834.11M | 179.7 |     148 |  105 |  725.3M |  13.045% | 4.64M | 4.59M |     0.99 |  5.01M |     0 | 0:02'48'' |
| Q20L130_3000000  | 893.69M | 192.5 |     148 |  105 | 777.33M |  13.021% | 4.64M | 4.59M |     0.99 |  5.07M |     0 | 0:03'01'' |
| Q20L130_3200000  | 953.27M | 205.4 |     147 |  105 | 829.27M |  13.008% | 4.64M | 4.59M |     0.99 |  5.13M |     0 | 0:03'14'' |
| Q20L140_200000   |   60.3M |  13.0 |     150 |  105 |  52.32M |  13.236% | 4.64M | 4.31M |     0.93 |  4.98M |     0 | 0:00'31'' |
| Q20L140_400000   | 120.61M |  26.0 |     150 |  105 |  104.6M |  13.269% | 4.64M | 4.49M |     0.97 |  4.82M |     0 | 0:01'14'' |
| Q20L140_600000   | 180.91M |  39.0 |     150 |  105 | 156.81M |  13.323% | 4.64M | 4.52M |     0.97 |  4.75M |     0 | 0:01'20'' |
| Q20L140_800000   | 241.21M |  52.0 |     150 |  105 | 208.99M |  13.357% | 4.64M | 4.53M |     0.98 |  4.71M |     0 | 0:01'29'' |
| Q20L140_1000000  | 301.52M |  65.0 |     150 |  105 | 261.39M |  13.307% | 4.64M | 4.54M |     0.98 |  4.71M |     0 | 0:01'27'' |
| Q20L140_1200000  | 361.82M |  77.9 |     150 |  105 | 313.62M |  13.321% | 4.64M | 4.55M |     0.98 |  4.71M |     0 | 0:02'13'' |
| Q20L140_1400000  | 422.12M |  90.9 |     150 |  105 | 365.95M |  13.307% | 4.64M | 4.55M |     0.98 |  4.73M |     0 | 0:01'49'' |
| Q20L140_1600000  | 482.42M | 103.9 |     150 |  105 | 418.21M |  13.311% | 4.64M | 4.55M |     0.98 |  4.75M |     0 | 0:02'59'' |
| Q20L140_1800000  | 542.73M | 116.9 |     150 |  105 |  470.7M |  13.271% | 4.64M | 4.56M |     0.98 |  4.78M |     0 | 0:02'45'' |
| Q20L140_2000000  | 603.03M | 129.9 |     150 |  105 | 523.06M |  13.261% | 4.64M | 4.56M |     0.98 |  4.81M |     0 | 0:02'53'' |
| Q20L140_2200000  | 663.33M | 142.9 |     150 |  105 | 575.41M |  13.254% | 4.64M | 4.57M |     0.98 |  4.85M |     0 | 0:02'50'' |
| Q20L140_2400000  | 723.64M | 155.9 |     150 |  105 | 627.81M |  13.242% | 4.64M | 4.57M |     0.98 |  4.89M |     0 | 0:03'02'' |
| Q20L140_2600000  | 783.94M | 168.9 |     150 |  105 | 680.26M |  13.225% | 4.64M | 4.57M |     0.99 |  4.94M |     0 | 0:03'51'' |
| Q20L150_200000   |   60.4M |  13.0 |     150 |  105 |  52.47M |  13.133% | 4.64M | 4.28M |     0.92 |  4.94M |     0 | 0:00'41'' |
| Q20L150_400000   |  120.8M |  26.0 |     150 |  105 | 104.77M |  13.271% | 4.64M | 4.47M |     0.96 |  4.81M |     0 | 0:01'18'' |
| Q20L150_600000   |  181.2M |  39.0 |     150 |  105 | 157.13M |  13.283% | 4.64M | 4.51M |     0.97 |  4.74M |     0 | 0:00'55'' |
| Q20L150_800000   |  241.6M |  52.1 |     150 |  105 | 209.46M |  13.301% | 4.64M | 4.53M |     0.98 |  4.72M |     0 | 0:02'05'' |
| Q20L150_1000000  |    302M |  65.1 |     150 |  105 | 261.92M |  13.272% | 4.64M | 4.54M |     0.98 |  4.71M |     0 | 0:01'39'' |
| Q20L150_1200000  |  362.4M |  78.1 |     150 |  105 | 314.43M |  13.237% | 4.64M | 4.54M |     0.98 |  4.71M |     0 | 0:01'47'' |
| Q20L150_1400000  |  422.8M |  91.1 |     150 |  105 | 366.73M |  13.262% | 4.64M | 4.55M |     0.98 |  4.73M |     0 | 0:02'07'' |
| Q20L150_1600000  |  483.2M | 104.1 |     150 |  105 |  419.2M |  13.245% | 4.64M | 4.55M |     0.98 |  4.75M |     0 | 0:02'07'' |
| Q20L150_1800000  |  543.6M | 117.1 |     150 |  105 | 471.78M |  13.212% | 4.64M | 4.55M |     0.98 |  4.77M |     0 | 0:02'27'' |
| Q20L150_2000000  |    604M | 130.1 |     150 |  105 | 524.15M |  13.219% | 4.64M | 4.56M |     0.98 |   4.8M |     0 | 0:02'49'' |
| Q20L150_2200000  |  664.4M | 143.1 |     150 |  105 | 576.74M |  13.194% | 4.64M | 4.56M |     0.98 |  4.83M |     0 | 0:03'37'' |
| Q20L150_2400000  |  724.8M | 156.2 |     150 |  105 |  629.2M |  13.190% | 4.64M | 4.57M |     0.98 |  4.88M |     0 | 0:03'14'' |
| Q25L120_200000   |  57.66M |  12.4 |     144 |   95 |   54.1M |   6.179% | 4.64M | 4.38M |     0.94 |  4.88M |     0 | 0:00'37'' |
| Q25L120_400000   | 115.35M |  24.9 |     144 |   95 |  108.3M |   6.114% | 4.64M | 4.51M |     0.97 |  4.75M |     0 | 0:00'53'' |
| Q25L120_600000   | 173.01M |  37.3 |     144 |   95 | 162.51M |   6.069% | 4.64M | 4.54M |     0.98 |   4.7M |     0 | 0:01'19'' |
| Q25L120_800000   |  230.7M |  49.7 |     143 |   95 | 216.66M |   6.083% | 4.64M | 4.55M |     0.98 |  4.68M |     0 | 0:01'18'' |
| Q25L120_1000000  | 288.36M |  62.1 |     143 |   93 | 270.81M |   6.088% | 4.64M | 4.55M |     0.98 |  4.67M |     0 | 0:01'38'' |
| Q25L120_1200000  | 346.02M |  74.5 |     143 |   93 | 324.97M |   6.086% | 4.64M | 4.55M |     0.98 |  4.67M |     0 | 0:01'46'' |
| Q25L120_1400000  | 403.68M |  87.0 |     143 |   93 | 379.07M |   6.096% | 4.64M | 4.55M |     0.98 |  4.67M |     0 | 0:02'17'' |
| Q25L120_1600000  | 461.35M |  99.4 |     143 |   93 |  433.3M |   6.080% | 4.64M | 4.56M |     0.98 |  4.67M |     0 | 0:02'24'' |
| Q25L120_1800000  | 519.04M | 111.8 |     143 |   93 | 487.46M |   6.085% | 4.64M | 4.56M |     0.98 |  4.67M |     0 | 0:02'33'' |
| Q25L120_2000000  |  576.7M | 124.2 |     143 |   93 | 541.65M |   6.077% | 4.64M | 4.56M |     0.98 |  4.67M |     0 | 0:02'54'' |
| Q25L120_2200000  | 634.37M | 136.7 |     142 |   93 | 595.83M |   6.076% | 4.64M | 4.56M |     0.98 |  4.68M |     0 | 0:03'48'' |
| Q25L120_2400000  | 692.05M | 149.1 |     142 |   93 | 649.95M |   6.083% | 4.64M | 4.56M |     0.98 |  4.68M |     0 | 0:03'22'' |
| Q25L120_2600000  | 749.72M | 161.5 |     142 |   93 |  704.1M |   6.085% | 4.64M | 4.56M |     0.98 |  4.68M |     0 | 0:03'34'' |
| Q25L120_2800000  | 807.39M | 173.9 |     142 |   93 | 758.32M |   6.077% | 4.64M | 4.56M |     0.98 |  4.68M |     0 | 0:03'59'' |
| Q25L130_200000   |  58.94M |  12.7 |     147 |  105 |  55.06M |   6.572% | 4.64M | 4.27M |     0.92 |  5.02M |     0 | 0:00'32'' |
| Q25L130_400000   | 117.87M |  25.4 |     147 |  101 | 110.35M |   6.384% | 4.64M | 4.47M |     0.96 |  4.79M |     0 | 0:01'00'' |
| Q25L130_600000   |  176.8M |  38.1 |     147 |  101 | 165.52M |   6.379% | 4.64M | 4.51M |     0.97 |  4.74M |     0 | 0:01'02'' |
| Q25L130_800000   | 235.75M |  50.8 |     146 |  101 | 220.72M |   6.374% | 4.64M | 4.53M |     0.98 |  4.71M |     0 | 0:01'31'' |
| Q25L130_1000000  | 294.68M |  63.5 |     146 |  101 | 275.93M |   6.365% | 4.64M | 4.54M |     0.98 |   4.7M |     0 | 0:01'58'' |
| Q25L130_1200000  | 353.62M |  76.2 |     146 |  101 | 331.08M |   6.374% | 4.64M | 4.54M |     0.98 |   4.7M |     0 | 0:02'04'' |
| Q25L130_1400000  | 412.57M |  88.9 |     146 |  101 | 386.28M |   6.374% | 4.64M | 4.55M |     0.98 |   4.7M |     0 | 0:02'28'' |
| Q25L130_1600000  | 471.51M | 101.6 |     146 |   99 | 441.41M |   6.384% | 4.64M | 4.55M |     0.98 |  4.69M |     0 | 0:01'58'' |
| Q25L130_1800000  | 530.45M | 114.3 |     146 |   99 | 496.67M |   6.368% | 4.64M | 4.55M |     0.98 |  4.69M |     0 | 0:02'45'' |
| Q25L130_2000000  | 589.39M | 127.0 |     146 |   99 | 551.82M |   6.374% | 4.64M | 4.55M |     0.98 |  4.69M |     0 | 0:02'59'' |
| Q25L140_200000   |  60.19M |  13.0 |     150 |  105 |  55.71M |   7.451% | 4.64M | 4.03M |     0.87 |  4.63M |     0 | 0:00'32'' |
| Q25L140_400000   | 120.38M |  25.9 |     150 |  105 | 112.03M |   6.940% | 4.64M | 4.37M |     0.94 |  4.76M |     0 | 0:01'35'' |
| Q25L140_600000   | 180.57M |  38.9 |     150 |  105 |    168M |   6.960% | 4.64M | 4.45M |     0.96 |  4.74M |     0 | 0:01'38'' |
| Q25L140_800000   | 240.76M |  51.9 |     150 |  105 | 224.15M |   6.897% | 4.64M | 4.48M |     0.96 |  4.73M |     0 | 0:01'17'' |
| Q25L140_1000000  | 300.95M |  64.8 |     150 |  105 | 280.21M |   6.890% | 4.64M |  4.5M |     0.97 |  4.72M |     0 | 0:01'47'' |
| Q25L140_1200000  | 361.14M |  77.8 |     150 |  105 | 336.21M |   6.902% | 4.64M | 4.51M |     0.97 |  4.71M |     0 | 0:01'50'' |
| Q25L150_200000   |   60.4M |  13.0 |     150 |  105 |  55.83M |   7.560% | 4.64M | 3.95M |     0.85 |  4.54M |     0 | 0:00'35'' |
| Q25L150_400000   |  120.8M |  26.0 |     150 |  105 | 112.21M |   7.113% | 4.64M | 4.32M |     0.93 |  4.71M |     0 | 0:01'02'' |
| Q25L150_600000   |  181.2M |  39.0 |     150 |  105 | 168.43M |   7.050% | 4.64M | 4.42M |     0.95 |  4.72M |     0 | 0:01'10'' |
| Q25L150_800000   |  241.6M |  52.1 |     150 |  105 |  224.7M |   6.997% | 4.64M | 4.46M |     0.96 |  4.72M |     0 | 0:01'34'' |
| Q25L150_1000000  |    302M |  65.1 |     150 |  105 | 280.84M |   7.006% | 4.64M | 4.48M |     0.97 |  4.71M |     0 | 0:01'49'' |
| Q25L150_1200000  |  362.4M |  78.1 |     150 |  105 | 336.98M |   7.013% | 4.64M |  4.5M |     0.97 |  4.71M |     0 | 0:02'03'' |
| Q30L120_200000   |  55.65M |  12.0 |     139 |   91 |  53.79M |   3.341% | 4.64M | 4.09M |     0.88 |  4.59M |     0 | 0:00'31'' |
| Q30L120_400000   | 111.29M |  24.0 |     138 |   91 | 108.18M |   2.795% | 4.64M |  4.4M |     0.95 |  4.74M |     0 | 0:00'48'' |
| Q30L120_600000   | 166.95M |  36.0 |     138 |   91 | 162.43M |   2.706% | 4.64M | 4.47M |     0.96 |  4.72M |     0 | 0:01'22'' |
| Q30L120_800000   | 222.57M |  48.0 |     138 |   91 | 216.57M |   2.697% | 4.64M |  4.5M |     0.97 |  4.71M |     0 | 0:01'22'' |
| Q30L120_1000000  | 278.21M |  59.9 |     138 |   91 | 270.73M |   2.686% | 4.64M | 4.51M |     0.97 |  4.71M |     0 | 0:01'52'' |
| Q30L120_1200000  | 333.85M |  71.9 |     138 |   91 | 324.89M |   2.686% | 4.64M | 4.52M |     0.97 |   4.7M |     0 | 0:02'11'' |
| Q30L130_200000   |  57.74M |  12.4 |     144 |   95 |  55.39M |   4.061% | 4.64M | 3.75M |     0.81 |  4.22M |     0 | 0:00'34'' |
| Q30L130_400000   | 115.47M |  24.9 |     144 |   95 | 111.91M |   3.087% | 4.64M |  4.2M |     0.90 |  4.57M |     0 | 0:00'48'' |
| Q30L130_600000   | 173.22M |  37.3 |     144 |   95 | 168.07M |   2.970% | 4.64M | 4.34M |     0.93 |  4.65M |     0 | 0:00'58'' |
| Q30L140_200000   |  59.93M |  12.9 |     149 |  105 |  56.92M |   5.034% | 4.64M | 3.11M |     0.67 |   3.6M |     0 | 0:00'34'' |
| Q30L150_200000   |   60.4M |  13.0 |     150 |  105 |  57.15M |   5.387% | 4.64M | 2.87M |     0.62 |  3.29M |     0 | 0:00'26'' |

* Illumina reads 的分布是有偏性的. 极端 GC 区域, 结构复杂区域都会得到较低的 fq 分值, 本应被 trim 掉.
  但覆盖度过高时, 这些区域之间的 reads 相互支持, 被保留下来的概率大大增加.
    * Discard% 在 CovFq 大于 100 倍时, 快速下降.
* Illumina reads 错误率约为 1% 不到一点. 当覆盖度过高时, 错误的点重复出现的概率要比完全无偏性的情况大一些.
    * 理论上 Subs% 应该是恒定值, 但当 CovFq 大于 100 倍时, 这个值在下降, 也就是这些错误的点相互支持, 躲过了 Kmer
      纠错.
* 直接的反映就是 EstG 过大, SumSR 过大.
* 留下的错误片段, 会形成 **伪独立** 片段, 降低 N50 SR
* 留下的错误位点, 会形成 **伪杂合** 位点, 降低 N50 SR
* trimmed 的 N50 比 filter 要大一些, 可能是留下了更多二代测序效果较差的位置. 同样 2400000 对 reads, trim 的 EstG
  更接近真实值
    * Real - 4.64M
    * Trimmed - 4.61M (EstG)
    * Filter - 4.59M (EstG)
* 但是 trimmed 里出 misassemblies 的概率要比 filter 大.

| Name             | N50SRclean |    Sum |      # | N50Anchor |     Sum |    # | N50Anchor2 |     Sum |   # | N50Others |     Sum |      # |   RunTime |
|:-----------------|-----------:|-------:|-------:|----------:|--------:|-----:|-----------:|--------:|----:|----------:|--------:|-------:|----------:|
| original_200000  |       1210 |  4.74M |   7196 |      2010 |   2.44M | 1272 |       1336 | 244.66K | 181 |       566 |   2.05M |   5743 | 0:00'44'' |
| original_400000  |       2975 |  4.94M |   5517 |      3732 |   4.01M | 1322 |       1371 |  77.99K |  57 |       466 | 853.04K |   4138 | 0:00'48'' |
| original_600000  |       2264 |  5.23M |   8692 |      3023 |   3.91M | 1479 |       1305 |   68.9K |  52 |       365 |   1.25M |   7161 | 0:01'02'' |
| original_800000  |       1578 |  5.58M |  12914 |      2352 |   3.63M | 1653 |       1275 |   26.5K |  21 |       358 |   1.92M |  11240 | 0:01'16'' |
| original_1000000 |       1161 |  5.99M |  18009 |      2022 |   3.24M | 1677 |       1210 |  25.49K |  21 |       327 |   2.72M |  16311 | 0:01'28'' |
| original_1200000 |        855 |  6.49M |  24289 |      1832 |   2.85M | 1591 |       1280 |   8.68K |   7 |       285 |   3.63M |  22691 | 0:01'33'' |
| original_1400000 |        647 |  7.03M |  30969 |      1713 |   2.49M | 1471 |       1144 |   3.63K |   3 |       236 |   4.53M |  29495 | 0:01'55'' |
| original_1600000 |        490 |  7.61M |  38222 |      1590 |   2.18M | 1335 |       1447 |   2.79K |   2 |       183 |   5.43M |  36885 | 0:01'59'' |
| original_1800000 |        373 |   8.2M |  45621 |      1506 |   1.87M | 1208 |          0 |       0 |   0 |       149 |   6.33M |  44413 | 0:02'14'' |
| original_2000000 |        269 |  8.95M |  54953 |      1490 |   1.58M | 1042 |          0 |       0 |   0 |       125 |   7.36M |  53911 | 0:02'19'' |
| original_2200000 |        179 |  9.75M |  64976 |      1423 |   1.38M |  936 |          0 |       0 |   0 |       109 |   8.37M |  64040 | 0:02'28'' |
| original_2400000 |        127 | 10.67M |  76590 |      1449 |   1.15M |  772 |          0 |       0 |   0 |       100 |   9.52M |  75818 | 0:02'38'' |
| original_2600000 |        107 | 11.65M |  88845 |      1416 | 983.45K |  683 |          0 |       0 |   0 |        96 |  10.67M |  88162 | 0:02'48'' |
| original_2800000 |         97 | 12.87M | 104203 |      1341 | 849.67K |  605 |          0 |       0 |   0 |        92 |  12.02M | 103598 | 0:02'50'' |
| original_3000000 |         92 | 14.26M | 121747 |      1338 | 730.33K |  521 |          0 |       0 |   0 |        90 |  13.53M | 121226 | 0:03'02'' |
| original_3200000 |         90 |  15.8M | 141238 |      1342 | 614.89K |  441 |          0 |       0 |   0 |        88 |  15.18M | 140797 | 0:03'06'' |
| original_3400000 |         87 |  17.6M | 164242 |      1366 | 490.16K |  347 |          0 |       0 |   0 |        86 |  17.11M | 163895 | 0:03'29'' |
| original_3600000 |         85 | 19.81M | 192540 |      1314 | 416.39K |  310 |          0 |       0 |   0 |        85 |   19.4M | 192230 | 0:03'41'' |
| original_3800000 |         84 | 22.19M | 223073 |      1237 | 340.74K |  260 |          0 |       0 |   0 |        83 |  21.85M | 222813 | 0:03'23'' |
| original_4000000 |         82 | 24.98M | 259047 |      1264 | 293.79K |  223 |          0 |       0 |   0 |        82 |  24.69M | 258824 | 0:03'36'' |
| Q20L120_200000   |        484 |  5.33M |  15109 |      1407 | 941.06K |  646 |       1134 |  10.53K |   9 |       387 |   4.38M |  14454 | 0:00'58'' |
| Q20L120_400000   |       1990 |   4.9M |   5131 |      2679 |    3.6M | 1506 |       1074 |   1.07K |   1 |       531 |    1.3M |   3624 | 0:01'15'' |
| Q20L120_600000   |       4058 |  4.78M |   2856 |      4570 |   4.23M | 1180 |          0 |       0 |   0 |       506 | 550.21K |   1676 | 0:01'15'' |
| Q20L120_800000   |       6536 |  4.71M |   1902 |      7021 |   4.41M |  877 |          0 |       0 |   0 |       436 | 303.99K |   1025 | 0:01'37'' |
| Q20L120_1000000  |       7583 |  4.71M |   1700 |      8247 |   4.46M |  787 |          0 |       0 |   0 |       339 | 250.45K |    913 | 0:01'53'' |
| Q20L120_1200000  |       8732 |  4.72M |   1686 |      9323 |   4.48M |  727 |          0 |       0 |   0 |       278 | 238.54K |    959 | 0:02'02'' |
| Q20L120_1400000  |       8059 |  4.74M |   1812 |      8555 |    4.5M |  742 |          0 |       0 |   0 |       248 | 241.97K |   1070 | 0:02'17'' |
| Q20L120_1600000  |       8918 |  4.75M |   1843 |      9319 |    4.5M |  714 |          0 |       0 |   0 |       228 | 248.01K |   1129 | 0:02'28'' |
| Q20L120_1800000  |       7971 |  4.79M |   2152 |      8383 |    4.5M |  763 |          0 |       0 |   0 |       209 | 289.78K |   1389 | 0:02'49'' |
| Q20L120_2000000  |       6965 |  4.82M |   2432 |      7495 |   4.51M |  845 |          0 |       0 |   0 |       199 | 310.34K |   1587 | 0:03'01'' |
| Q20L120_2200000  |       6249 |  4.86M |   2746 |      6728 |   4.49M |  922 |          0 |       0 |   0 |       209 |  369.3K |   1824 | 0:02'54'' |
| Q20L120_2400000  |       5476 |  4.92M |   3231 |      5895 |   4.47M |  994 |          0 |       0 |   0 |       209 | 448.87K |   2237 | 0:03'19'' |
| Q20L120_2600000  |       4740 |  4.98M |   3735 |      5319 |   4.44M | 1098 |          0 |       0 |   0 |       209 |  534.6K |   2637 | 0:03'28'' |
| Q20L120_2800000  |       4400 |  5.02M |   4182 |      5110 |    4.4M | 1155 |          0 |       0 |   0 |       203 | 613.16K |   3027 | 0:03'32'' |
| Q20L120_3000000  |       3907 |  5.08M |   4751 |      4589 |   4.38M | 1267 |          0 |       0 |   0 |       201 | 702.88K |   3484 | 0:03'36'' |
| Q20L120_3200000  |       3445 |  5.14M |   5290 |      4116 |   4.33M | 1343 |          0 |       0 |   0 |       221 | 810.01K |   3947 | 0:03'50'' |
| Q20L120_3400000  |       2934 |  5.21M |   5980 |      3605 |   4.29M | 1451 |          0 |       0 |   0 |       223 | 920.51K |   4529 | 0:03'42'' |
| Q20L120_3600000  |       2546 |  5.29M |   6729 |      3201 |   4.22M | 1568 |          0 |       0 |   0 |       255 |   1.07M |   5161 | 0:04'15'' |
| Q20L120_3800000  |       2262 |  5.38M |   7497 |      2948 |   4.15M | 1643 |          0 |       0 |   0 |       276 |   1.23M |   5854 | 0:04'06'' |
| Q20L130_200000   |        535 |  5.17M |  13799 |      1461 |   1.18M |  780 |       1129 |  17.17K |  15 |       400 |   3.97M |  13004 | 0:01'11'' |
| Q20L130_400000   |       2090 |  4.85M |   4971 |      2813 |    3.6M | 1452 |       1251 |   7.82K |   6 |       524 |   1.24M |   3513 | 0:01'11'' |
| Q20L130_600000   |       3959 |  4.76M |   2970 |      4497 |   4.16M | 1196 |          0 |       0 |   0 |       510 | 595.71K |   1774 | 0:01'19'' |
| Q20L130_800000   |       5909 |  4.72M |   2177 |      6387 |   4.34M |  978 |       1129 |   1.13K |   1 |       485 | 375.03K |   1198 | 0:01'28'' |
| Q20L130_1000000  |       6715 |  4.71M |   1889 |      7183 |   4.41M |  859 |          0 |       0 |   0 |       431 | 303.22K |   1030 | 0:01'47'' |
| Q20L130_1200000  |       7468 |  4.71M |   1820 |      7818 |   4.45M |  810 |          0 |       0 |   0 |       317 | 266.27K |   1010 | 0:01'57'' |
| Q20L130_1400000  |       7873 |  4.73M |   1882 |      8286 |   4.47M |  801 |          0 |       0 |   0 |       270 | 260.42K |   1081 | 0:02'21'' |
| Q20L130_1600000  |       7656 |  4.75M |   1967 |      8107 |   4.48M |  802 |       1284 |   1.28K |   1 |       244 | 266.62K |   1164 | 0:02'34'' |
| Q20L130_1800000  |       6940 |  4.78M |   2217 |      7419 |   4.47M |  834 |          0 |       0 |   0 |       256 | 312.33K |   1383 | 0:02'48'' |
| Q20L130_2000000  |       6584 |  4.81M |   2472 |      7024 |   4.46M |  884 |          0 |       0 |   0 |       243 | 348.58K |   1588 | 0:03'01'' |
| Q20L130_2200000  |       5984 |  4.86M |   2822 |      6493 |   4.45M |  947 |          0 |       0 |   0 |       238 | 403.83K |   1875 | 0:03'21'' |
| Q20L130_2400000  |       5259 |  4.91M |   3249 |      5749 |   4.45M | 1028 |          0 |       0 |   0 |       209 | 457.11K |   2221 | 0:03'15'' |
| Q20L130_2600000  |       4677 |  4.95M |   3603 |      5208 |   4.44M | 1108 |          0 |       0 |   0 |       209 | 512.56K |   2495 | 0:03'19'' |
| Q20L130_2800000  |       4176 |  5.01M |   4096 |      4740 |    4.4M | 1187 |          0 |       0 |   0 |       218 | 604.57K |   2909 | 0:03'10'' |
| Q20L130_3000000  |       3861 |  5.07M |   4628 |      4423 |   4.37M | 1279 |          0 |       0 |   0 |       225 | 697.58K |   3349 | 0:03'50'' |
| Q20L130_3200000  |       3464 |  5.13M |   5136 |      3970 |   4.34M | 1358 |          0 |       0 |   0 |       240 | 792.31K |   3778 | 0:03'25'' |
| Q20L140_200000   |        575 |  4.98M |  12773 |      1580 |    1.3M |  804 |       1164 |  22.59K |  19 |       408 |   3.66M |  11950 | 0:00'59'' |
| Q20L140_400000   |       1870 |  4.82M |   5490 |      2674 |   3.38M | 1433 |       1337 |   6.25K |   5 |       525 |   1.43M |   4052 | 0:01'19'' |
| Q20L140_600000   |       3260 |  4.75M |   3461 |      3973 |   4.01M | 1290 |       1127 |   1.13K |   1 |       528 |  735.1K |   2170 | 0:01'29'' |
| Q20L140_800000   |       4580 |  4.71M |   2585 |      5200 |   4.21M | 1109 |          0 |       0 |   0 |       535 |  501.9K |   1476 | 0:01'36'' |
| Q20L140_1000000  |       5259 |  4.71M |   2297 |      5815 |   4.31M | 1005 |          0 |       0 |   0 |       487 | 404.64K |   1292 | 0:01'57'' |
| Q20L140_1200000  |       6064 |  4.71M |   2143 |      6628 |   4.36M |  947 |          0 |       0 |   0 |       466 | 357.72K |   1196 | 0:01'57'' |
| Q20L140_1400000  |       6258 |  4.73M |   2181 |      6782 |   4.39M |  924 |          0 |       0 |   0 |       386 | 343.19K |   1257 | 0:02'25'' |
| Q20L140_1600000  |       5973 |  4.75M |   2271 |      6570 |    4.4M |  935 |          0 |       0 |   0 |       357 | 350.93K |   1336 | 0:02'24'' |
| Q20L140_1800000  |       5945 |  4.78M |   2425 |      6456 |   4.42M |  953 |          0 |       0 |   0 |       296 | 358.81K |   1472 | 0:02'54'' |
| Q20L140_2000000  |       5717 |  4.81M |   2639 |      6214 |   4.41M |  973 |          0 |       0 |   0 |       310 | 397.89K |   1666 | 0:03'19'' |
| Q20L140_2200000  |       5144 |  4.85M |   2968 |      5577 |   4.42M | 1053 |          0 |       0 |   0 |       269 | 431.48K |   1915 | 0:03'02'' |
| Q20L140_2400000  |       4698 |  4.89M |   3309 |      5153 |    4.4M | 1114 |          0 |       0 |   0 |       270 |  486.7K |   2195 | 0:03'22'' |
| Q20L140_2600000  |       4403 |  4.94M |   3696 |      4840 |   4.38M | 1172 |          0 |       0 |   0 |       272 | 555.36K |   2524 | 0:03'09'' |
| Q20L150_200000   |        575 |  4.94M |  12711 |      1592 |   1.33M |  816 |       1143 |  19.96K |  17 |       400 |   3.59M |  11878 | 0:01'05'' |
| Q20L150_400000   |       1795 |  4.81M |   5574 |      2603 |   3.33M | 1414 |       1259 |  14.04K |  11 |       524 |   1.46M |   4149 | 0:01'19'' |
| Q20L150_600000   |       3059 |  4.74M |   3578 |      3892 |   3.93M | 1290 |       1178 |   1.18K |   1 |       551 | 815.44K |   2287 | 0:01'17'' |
| Q20L150_800000   |       4130 |  4.72M |   2783 |      4618 |   4.17M | 1177 |       1212 |   4.79K |   4 |       529 | 544.13K |   1602 | 0:01'37'' |
| Q20L150_1000000  |       5185 |  4.71M |   2398 |      5709 |   4.26M | 1025 |          0 |       0 |   0 |       534 | 455.08K |   1373 | 0:01'50'' |
| Q20L150_1200000  |       5747 |  4.71M |   2189 |      6214 |   4.34M |  970 |          0 |       0 |   0 |       466 | 368.33K |   1219 | 0:02'05'' |
| Q20L150_1400000  |       5848 |  4.73M |   2269 |      6352 |   4.35M |  941 |       1601 |    1.6K |   1 |       459 | 380.96K |   1327 | 0:02'18'' |
| Q20L150_1600000  |       5984 |  4.75M |   2299 |      6574 |   4.37M |  930 |          0 |       0 |   0 |       433 | 373.96K |   1369 | 0:02'20'' |
| Q20L150_1800000  |       5952 |  4.77M |   2417 |      6428 |   4.39M |  950 |          0 |       0 |   0 |       366 | 378.97K |   1467 | 0:02'52'' |
| Q20L150_2000000  |       5499 |   4.8M |   2672 |      6134 |   4.39M |  988 |          0 |       0 |   0 |       326 | 411.15K |   1684 | 0:02'57'' |
| Q20L150_2200000  |       5248 |  4.83M |   2900 |      5761 |   4.39M | 1030 |          0 |       0 |   0 |       305 | 444.86K |   1870 | 0:02'57'' |
| Q20L150_2400000  |       4716 |  4.88M |   3272 |      5249 |   4.38M | 1095 |          0 |       0 |   0 |       297 | 504.74K |   2177 | 0:03'17'' |
| Q25L120_200000   |        770 |  4.88M |  10261 |      1707 |   1.83M | 1071 |       1142 |  16.56K |  14 |       466 |   3.03M |   9176 | 0:01'03'' |
| Q25L120_400000   |       2598 |  4.75M |   4109 |      3252 |    3.8M | 1392 |       1158 |   3.48K |   3 |       536 | 952.75K |   2714 | 0:01'09'' |
| Q25L120_600000   |       4371 |   4.7M |   2603 |      5122 |   4.21M | 1129 |          0 |       0 |   0 |       518 | 492.56K |   1474 | 0:01'17'' |
| Q25L120_800000   |       5973 |  4.68M |   1983 |      6596 |   4.35M |  934 |       1144 |   1.14K |   1 |       505 | 332.45K |   1048 | 0:01'43'' |
| Q25L120_1000000  |       7597 |  4.67M |   1679 |      8233 |   4.42M |  818 |          0 |       0 |   0 |       459 | 252.84K |    861 | 0:01'57'' |
| Q25L120_1200000  |       8224 |  4.67M |   1571 |      8696 |   4.44M |  767 |          0 |       0 |   0 |       405 | 225.84K |    804 | 0:02'11'' |
| Q25L120_1400000  |       9299 |  4.67M |   1470 |      9851 |   4.46M |  699 |          0 |       0 |   0 |       391 | 209.67K |    771 | 0:02'17'' |
| Q25L120_1600000  |       9530 |  4.67M |   1430 |      9997 |   4.47M |  686 |          0 |       0 |   0 |       364 | 199.84K |    744 | 0:02'42'' |
| Q25L120_1800000  |      10142 |  4.67M |   1381 |     10352 |   4.48M |  651 |          0 |       0 |   0 |       331 | 191.95K |    730 | 0:02'50'' |
| Q25L120_2000000  |      10434 |  4.67M |   1382 |     10858 |   4.48M |  634 |          0 |       0 |   0 |       296 | 190.61K |    748 | 0:03'02'' |
| Q25L120_2200000  |      10554 |  4.68M |   1380 |     11198 |   4.49M |  624 |          0 |       0 |   0 |       291 | 188.72K |    756 | 0:03'16'' |
| Q25L120_2400000  |      11128 |  4.68M |   1355 |     11817 |    4.5M |  604 |          0 |       0 |   0 |       268 | 177.99K |    751 | 0:03'36'' |
| Q25L120_2600000  |      10742 |  4.68M |   1392 |     11164 |    4.5M |  610 |          0 |       0 |   0 |       268 | 184.33K |    782 | 0:03'16'' |
| Q25L120_2800000  |      10912 |  4.68M |   1393 |     11128 |   4.51M |  598 |          0 |       0 |   0 |       244 |  177.7K |    795 | 0:03'23'' |
| Q25L130_200000   |        517 |  5.02M |  14099 |      1563 |   1.19M |  752 |       1232 |   9.63K |   8 |       362 |   3.82M |  13339 | 0:01'07'' |
| Q25L130_400000   |       1773 |  4.79M |   5638 |      2604 |   3.29M | 1408 |       1221 |    4.7K |   4 |       539 |   1.49M |   4226 | 0:01'15'' |
| Q25L130_600000   |       2932 |  4.74M |   3653 |      3759 |   3.89M | 1287 |       1200 |   4.62K |   4 |       551 | 846.11K |   2362 | 0:01'29'' |
| Q25L130_800000   |       4050 |  4.71M |   2817 |      4658 |   4.14M | 1182 |          0 |       0 |   0 |       544 | 571.76K |   1635 | 0:01'44'' |
| Q25L130_1000000  |       4603 |   4.7M |   2460 |      5271 |   4.24M | 1093 |       1142 |   1.14K |   1 |       527 |    463K |   1366 | 0:01'50'' |
| Q25L130_1200000  |       5310 |   4.7M |   2197 |      5869 |    4.3M | 1005 |       1086 |   1.09K |   1 |       512 | 394.09K |   1191 | 0:02'07'' |
| Q25L130_1400000  |       6035 |   4.7M |   2049 |      6453 |   4.35M |  954 |          0 |       0 |   0 |       505 |  348.5K |   1095 | 0:02'27'' |
| Q25L130_1600000  |       6864 |  4.69M |   1865 |      7301 |   4.39M |  897 |          0 |       0 |   0 |       479 | 298.64K |    968 | 0:02'30'' |
| Q25L130_1800000  |       6958 |  4.69M |   1840 |      7438 |    4.4M |  870 |       1189 |   1.19K |   1 |       460 | 289.34K |    969 | 0:02'51'' |
| Q25L130_2000000  |       7488 |  4.69M |   1783 |      7988 |   4.41M |  830 |          0 |       0 |   0 |       478 | 284.45K |    953 | 0:02'48'' |
| Q25L140_200000   |        552 |  4.63M |  12401 |      1672 |   1.25M |  740 |       1219 |  11.71K |  10 |       367 |   3.36M |  11651 | 0:01'03'' |
| Q25L140_400000   |       1261 |  4.76M |   7286 |      2224 |   2.73M | 1298 |       1098 |   8.22K |   7 |       488 |   2.02M |   5981 | 0:01'20'' |
| Q25L140_600000   |       2010 |  4.74M |   5169 |      2759 |   3.44M | 1393 |       1148 |   3.51K |   3 |       511 |    1.3M |   3773 | 0:01'25'' |
| Q25L140_800000   |       2520 |  4.73M |   4152 |      3371 |   3.73M | 1342 |       1217 |   5.87K |   5 |       548 | 996.28K |   2805 | 0:01'42'' |
| Q25L140_1000000  |       3069 |  4.72M |   3515 |      3967 |   3.91M | 1274 |       1238 |   1.24K |   1 |       563 | 805.33K |   2240 | 0:01'41'' |
| Q25L140_1200000  |       3524 |  4.71M |   3163 |      4237 |   4.02M | 1227 |       1117 |   1.12K |   1 |       556 | 687.16K |   1935 | 0:01'59'' |
| Q25L150_200000   |        545 |  4.54M |  12133 |      1680 |    1.2M |  708 |       1176 |   14.2K |  12 |       381 |   3.32M |  11413 | 0:01'00'' |
| Q25L150_400000   |       1211 |  4.71M |   7415 |      2220 |   2.61M | 1256 |       1234 |  16.69K |  13 |       494 |   2.07M |   6146 | 0:01'05'' |
| Q25L150_600000   |       1851 |  4.72M |   5436 |      2633 |    3.3M | 1375 |       1122 |   8.29K |   7 |       523 |   1.41M |   4054 | 0:01'17'' |
| Q25L150_800000   |       2353 |  4.72M |   4396 |      3182 |   3.63M | 1348 |       1366 |   7.63K |   6 |       537 |   1.08M |   3042 | 0:01'35'' |
| Q25L150_1000000  |       2708 |  4.71M |   3787 |      3539 |   3.83M | 1318 |          0 |       0 |   0 |       553 | 882.98K |   2469 | 0:01'37'' |
| Q25L150_1200000  |       3093 |  4.71M |   3401 |      3914 |   3.96M | 1270 |       1146 |   1.15K |   1 |       547 | 750.43K |   2130 | 0:01'53'' |
| Q30L120_200000   |        606 |  4.59M |  11957 |      1690 |   1.37M |  801 |       1185 |  11.72K |  10 |       393 |   3.21M |  11146 | 0:00'58'' |
| Q30L120_400000   |       1372 |  4.74M |   7028 |      2241 |   2.87M | 1356 |       1229 |   4.96K |   4 |       487 |   1.86M |   5668 | 0:01'12'' |
| Q30L120_600000   |       2118 |  4.72M |   4934 |      2936 |   3.51M | 1388 |       1275 |   2.36K |   2 |       525 |    1.2M |   3544 | 0:01'22'' |
| Q30L120_800000   |       2689 |  4.71M |   3933 |      3383 |   3.83M | 1360 |       1356 |   2.59K |   2 |       527 | 879.01K |   2571 | 0:01'48'' |
| Q30L120_1000000  |       3240 |  4.71M |   3429 |      3840 |   3.97M | 1292 |          0 |       0 |   0 |       532 |  732.5K |   2137 | 0:01'57'' |
| Q30L120_1200000  |       3776 |   4.7M |   3030 |      4350 |   4.09M | 1219 |          0 |       0 |   0 |       528 |  610.2K |   1811 | 0:02'10'' |
| Q30L130_200000   |        553 |  4.22M |  11500 |      1760 |   1.14M |  648 |       1132 |  11.12K |   9 |       381 |   3.07M |  10843 | 0:01'06'' |
| Q30L130_400000   |       1055 |  4.57M |   8198 |      2034 |   2.34M | 1180 |       1157 |   8.67K |   7 |       467 |   2.22M |   7011 | 0:01'12'' |
| Q30L130_600000   |       1497 |  4.65M |   6452 |      2421 |   2.94M | 1324 |       1147 |   9.34K |   8 |       499 |    1.7M |   5120 | 0:01'19'' |
| Q30L140_200000   |        439 |   3.6M |  11302 |      1735 | 751.26K |  432 |       1217 |   4.66K |   4 |       294 |   2.85M |  10866 | 0:00'46'' |
| Q30L150_200000   |        454 |  3.29M |  10037 |      1776 | 670.38K |  380 |       1211 |   2.36K |   2 |       336 |   2.62M |   9655 | 0:00'33'' |

| Name            | N50SRclean |   Sum |    # | N50Anchor |   Sum |    # | N50Anchor2 |     Sum |  # | N50Others |     Sum |    # |   RunTime |
|:----------------|-----------:|------:|-----:|----------:|------:|-----:|-----------:|--------:|---:|----------:|--------:|-----:|----------:|
| original_400000 |       2975 | 4.94M | 5517 |      3732 | 4.01M | 1322 |       1371 |  77.99K | 57 |       466 | 853.04K | 4138 | 0:00'48'' |
| Q20L120_1600000 |       8918 | 4.75M | 1843 |      9319 |  4.5M |  714 |          0 |       0 |  0 |       228 | 248.01K | 1129 | 0:02'28'' |
| Q20L130_1600000 |       7656 | 4.75M | 1967 |      8107 | 4.48M |  802 |       1284 |   1.28K |  1 |       244 | 266.62K | 1164 | 0:02'34'' |
| Q20L140_1600000 |       5973 | 4.75M | 2271 |      6570 |  4.4M |  935 |          0 |       0 |  0 |       357 | 350.93K | 1336 | 0:02'24'' |
| Q20L150_1600000 |       5984 | 4.75M | 2299 |      6574 | 4.37M |  930 |          0 |       0 |  0 |       433 | 373.96K | 1369 | 0:02'20'' |
| Q25L120_2400000 |      11128 | 4.68M | 1355 |     11817 |  4.5M |  604 |          0 |       0 |  0 |       268 | 177.99K |  751 | 0:03'36'' |
| Q25L130_2000000 |       7488 | 4.69M | 1783 |      7988 | 4.41M |  830 |          0 |       0 |  0 |       478 | 284.45K |  953 | 0:02'48'' |
| Q25L140_1200000 |       3524 | 4.71M | 3163 |      4237 | 4.02M | 1227 |       1117 |   1.12K |  1 |       556 | 687.16K | 1935 | 0:01'59'' |
| Q25L150_1200000 |       3093 | 4.71M | 3401 |      3914 | 3.96M | 1270 |       1146 |   1.15K |  1 |       547 | 750.43K | 2130 | 0:01'53'' |
| Q30L120_1200000 |       3776 |  4.7M | 3030 |      4350 | 4.09M | 1219 |          0 |       0 |  0 |       528 |  610.2K | 1811 | 0:02'10'' |
| Q25L150_SR      |       3287 |  4.8M | 2948 |      4031 | 3.69M | 1173 |       9118 | 305.53K | 56 |       635 | 811.23K | 1719 | 0:02'15'' |

## With PE

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

mkdir -p Q25L150_SR
cd ${BASE_DIR}/Q25L150_SR
ln -s ../Q25L150_1200000/R1.fq.gz R1.fq.gz
ln -s ../Q25L150_1200000/R2.fq.gz R2.fq.gz

anchr superreads \
    R1.fq.gz R2.fq.gz \
    -s 300 -d 30 -p 16 \
    -o superreads.sh
bash superreads.sh

rm -fr anchor
bash ~/Scripts/cpan/App-Anchr/share/anchor.sh . 16 true

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 .

```

## Quality assessment

http://www.opiniomics.org/generate-a-single-contig-hybrid-assembly-of-e-coli-using-miseq-and-minion-data/

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

# sort on ref
for part in anchor others;
do 
    bash ~/Scripts/cpan/App-Anchr/share/sort_on_ref.sh Q25L120_2400000/anchor/pe.${part}.fa 1_genome/genome.fa pe.${part}
    nucmer -l 200 1_genome/genome.fa pe.${part}.fa
    mummerplot -png out.delta -p pe.${part} --medium
done

cp ~/data/anchr/paralogs/model/Results/e_coli/e_coli.multi.fas 1_genome/paralogs.fas

# mummerplot files
rm *.[fr]plot
rm out.delta
rm *.gp

# merge anchors
mkdir -p merge
anchr contained \
    Q20L120_1600000/anchor/pe.anchor.fa \
    Q20L130_1600000/anchor/pe.anchor.fa \
    Q20L140_1600000/anchor/pe.anchor.fa \
    Q20L150_1600000/anchor/pe.anchor.fa \
    Q25L120_2400000/anchor/pe.anchor.fa \
    Q25L130_2000000/anchor/pe.anchor.fa \
    Q25L140_1200000/anchor/pe.anchor.fa \
    Q25L150_1200000/anchor/pe.anchor.fa \
    Q30L120_1200000/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

faops n50 -S -C merge/anchor.merge.fasta

# quast
rm -fr 9_qa
quast --no-check \
    -R 1_genome/genome.fa \
    Q20L120_1600000/anchor/pe.anchor.fa \
    Q20L130_1600000/anchor/pe.anchor.fa \
    Q20L140_1600000/anchor/pe.anchor.fa \
    Q20L150_1600000/anchor/pe.anchor.fa \
    Q25L120_2400000/anchor/pe.anchor.fa \
    Q25L130_2000000/anchor/pe.anchor.fa \
    Q25L140_1200000/anchor/pe.anchor.fa \
    Q25L150_1200000/anchor/pe.anchor.fa \
    Q30L120_1200000/anchor/pe.anchor.fa \
    merge/anchor.merge.fasta \
    1_genome/paralogs.fas \
    --label "Q20L120,Q20L130,Q20L140,Q20L150,Q25L120,Q25L130,Q25L140,Q25L150,Q30L120,merge,paralogs" \
    -o 9_qa
```

## Expand anchors

### anchorLong

* 只有基于 distances 的判断的话, `anchr group` 无法消除 false strands.
* multi-matched 判断不能放到 `anchr cover` 里, 拆分的 anchors 里也有 multi-matched 的部分.

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

#head -n 23000 ${BASE_DIR}/3_pacbio/pacbio.fasta > ${BASE_DIR}/3_pacbio/pacbio.20x.fasta
head -n 46000 ${BASE_DIR}/3_pacbio/pacbio.fasta > ${BASE_DIR}/3_pacbio/pacbio.40x.fasta

rm -fr covered
mkdir -p covered
anchr cover \
    -c 2 -m 60 \
    -b 20 --len 1000 --idt 0.8 \
    merge/anchor.merge.fasta \
    3_pacbio/pacbio.40x.fasta \
    -o covered/covered.fasta
faops n50 -S -C covered/covered.fasta

rm -fr anchorLong
anchr overlap2 \
    covered/covered.fasta \
    3_pacbio/pacbio.40x.fasta \
    -d anchorLong \
    -b 20 --len 1000 --idt 0.85

anchr overlap \
    ${BASE_DIR}/covered/covered.fasta \
    --serial --len 10 --idt 0.98 \
    -o stdout \
    | perl -nla -e '
        BEGIN {
            our %seen;
            our %count_of;
        }

        @F == 13 or next;
        $F[3] > 0.98 or next;

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
    > ${BASE_DIR}/anchorLong/anchor.ovlp.tsv

ANCHOR_COUNT=$(faops n50 -H -N 0 -C ${BASE_DIR}/anchorLong/anchor.fasta)
echo ${ANCHOR_COUNT}

rm -fr ${BASE_DIR}/anchorLong/group
anchr group \
    ${BASE_DIR}/anchorLong/anchorLong.db \
    ${BASE_DIR}/anchorLong/anchorLong.ovlp.tsv \
    --oa ${BASE_DIR}/anchorLong/anchor.ovlp.tsv \
    --range "1-${ANCHOR_COUNT}" --len 1000 --idt 0.85 --max 1 -c 4 --png

pushd ${BASE_DIR}/anchorLong
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
cat ${BASE_DIR}/anchorLong/group/*.ovlp.tsv \
    | perl -nla -e '/anchor.+long/ or next; print $F[0] if $F[8] == 1;' \
    | sort | uniq -c

faops n50 -S -C ${BASE_DIR}/anchorLong/group/*.contig.fasta

cat \
    ${BASE_DIR}/anchorLong/group/non_grouped.fasta\
    ${BASE_DIR}/anchorLong/group/*.contig.fasta \
    >  ${BASE_DIR}/anchorLong/contig.fasta
faops n50 -S -C ${BASE_DIR}/anchorLong/contig.fasta

```

### contigLong

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

rm -fr contigLong
anchr overlap2 \
    ${BASE_DIR}/anchorLong/contig.fasta \
    ${BASE_DIR}/3_pacbio/pacbio.40x.fasta \
    -d ${BASE_DIR}/contigLong \
    -b 20 --len 2000 --idt 0.85 --all

CONTIG_COUNT=$(faops n50 -H -N 0 -C ${BASE_DIR}/contigLong/anchor.fasta)
echo ${CONTIG_COUNT}
LONG_COUNT=$(faops n50 -H -N 0 -C ${BASE_DIR}/contigLong/long.fasta)
echo ${LONG_COUNT}

# breaksLong
anchr break \
    ${BASE_DIR}/contigLong/anchorLong.db \
    ${BASE_DIR}/contigLong/anchorLong.ovlp.tsv \
    --range "1-${CONTIG_COUNT}" --len 2000 --idt 0.85 --power 1.1 \
    -o contigLong/breaksLong.fasta

# canu
rm -fr canu-breaks
canu \
    -correct \
    -p ecoli -d canu-breaks \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=4.8m \
    -pacbio-raw contigLong/breaksLong.fasta

canu \
    -trim \
    -p ecoli -d canu-breaks \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=4.8m \
    -pacbio-corrected canu-breaks/ecoli.correctedReads.fasta.gz

faops n50 -S -C contigLong/breaksLong.fasta
faops n50 -S -C canu-breaks/ecoli.trimmedReads.fasta.gz

```

* nonOverlappedLong

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

CONTIG_COUNT=$(faops n50 -H -N 0 -C ${BASE_DIR}/contigLong/anchor.fasta)
echo ${CONTIG_COUNT}
LONG_COUNT=$(faops n50 -H -N 0 -C ${BASE_DIR}/contigLong/long.fasta)
echo ${LONG_COUNT}

# nonOverlappedLong
cat contigLong/anchorLong.ovlp.tsv \
    | CONTIG_COUNT=${CONTIG_COUNT} perl -nla -e '
        BEGIN {
            our %seen;
        }

        @F == 13 or next;

        my $pair = join( "-", sort { $a <=> $b } ( $F[0], $F[1], ) );
        next if $seen{$pair};
        $seen{$pair} = $_;

        if ( $F[0] <= $ENV{CONTIG_COUNT} and $F[1] > $ENV{CONTIG_COUNT} ) {
            print $F[1];
        }
    ' \
    | sort -n | uniq \
    > contigLong/overlappedLong.serial.txt

grep -Fx -v \
    -f contigLong/overlappedLong.serial.txt \
    <(seq $((${CONTIG_COUNT} + 1)) 1 ${LONG_COUNT}) \
    > contigLong/nonOverlappedLong.serial.txt

DBshow -n contigLong/anchorLong.db \
    contigLong/nonOverlappedLong.serial.txt \
    | sed 's/^>//' \
    > contigLong/nonOverlappedLong.header.txt

faops some -l 0 \
    contigLong/long.fasta \
    contigLong/nonOverlappedLong.header.txt \
    contigLong/nonOverlappedLong.fasta

faops n50 -S -C contigLong/nonOverlappedLong.fasta

```

### contigTrim

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

rm -fr contigTrim
anchr overlap2 \
    anchorLong/contig.fasta \
    canu-breaks/ecoli.trimmedReads.fasta.gz \
    -d contigTrim \
    -b 10 --len 1000 --idt 0.96

CONTIG_COUNT=$(faops n50 -H -N 0 -C ${BASE_DIR}/contigTrim/anchor.fasta)
echo ${CONTIG_COUNT}

rm -fr ${BASE_DIR}/contigTrim/group
anchr group \
    contigTrim/anchorLong.db \
    contigTrim/anchorLong.ovlp.tsv \
    --range "1-${CONTIG_COUNT}" --len 1000 --idt 0.96 --max 5000 -c 8

pushd ${BASE_DIR}/contigTrim
cat group/groups.txt \
    | parallel --no-run-if-empty -j 8 '
        echo {};
        anchr orient \
            --len 1000 --idt 0.96 \
            group/{}.anchor.fasta \
            group/{}.long.fasta \
            -r group/{}.restrict.tsv \
            -o group/{}.strand.fasta;

        anchr overlap --len 1000 --idt 0.96 \
            group/{}.strand.fasta \
            -o stdout \
            | anchr restrict \
                stdin group/{}.restrict.tsv \
                -o group/{}.ovlp.tsv;

        anchr layout \
            group/{}.ovlp.tsv \
            group/{}.relation.tsv \
            group/{}.strand.fasta \
            -o group/{}.contig.fasta
    '
popd

faops n50 -S -C contigTrim/group/*.contig.fasta

cat \
    contigTrim/group/non_grouped.fasta \
    contigTrim/group/*.contig.fasta \
    >  contigTrim/contig.fasta
faops n50 -S -C contigTrim/contig.fasta

```

### contigFinal

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

rm -fr contigFinal
anchr overlap2 \
    contigTrim/contig.fasta \
    canu-breaks/ecoli.trimmedReads.fasta.gz \
    -d contigFinal \
    -b 10 --len 1000 --idt 0.96

CONTIG_COUNT=$(faops n50 -H -N 0 -C ${BASE_DIR}/contigFinal/anchor.fasta)
echo ${CONTIG_COUNT}
LONG_COUNT=$(faops n50 -H -N 0 -C ${BASE_DIR}/contigFinal/long.fasta)
echo ${LONG_COUNT}

# nonContainedLong
cat ${BASE_DIR}/contigFinal/anchorLong.ovlp.tsv \
    | CONTIG_COUNT=${CONTIG_COUNT} perl -nla -e '
        BEGIN {
            our %seen;
        }

        @F == 13 or next;

        my $pair = join( "-", sort { $a <=> $b } ( $F[0], $F[1], ) );
        next if $seen{$pair};
        $seen{$pair} = $_;

        if ( $F[0] <= $ENV{CONTIG_COUNT} and $F[1] > $ENV{CONTIG_COUNT} ) {
            if ( $F[12] eq "overlap" ) {
                print $F[1];
            }
        }
    ' \
    | sort -n | uniq \
    > contigFinal/nonContainedLong.serial.txt

DBshow -n contigFinal/anchorLong.db \
    contigFinal/nonContainedLong.serial.txt \
    | sed 's/^>//' \
    > contigFinal/nonContainedLong.header.txt

faops some -l 0 \
    contigFinal/long.fasta \
    contigFinal/nonContainedLong.header.txt \
    contigFinal/nonContainedLong.fasta

faops n50 -S -C contigFinal/nonContainedLong.fasta

# canu
rm -fr canu-non-contained
canu \
    -correct \
    -p ecoli -d canu-non-contained \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=4.8m \
    -pacbio-raw \
    contigFinal/nonContainedLong.fasta \
    contigLong/nonOverlappedLong.fasta

canu \
    -trim \
    -p ecoli -d canu-non-contained \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=4.8m \
    -pacbio-corrected canu-non-contained/ecoli.correctedReads.fasta.gz

faops n50 -S -C canu-non-contained/ecoli.trimmedReads.fasta.gz

rm -fr canu-anchor
canu \
    -assemble \
    -p ecoli -d canu-anchor \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=4.8m \
    -pacbio-corrected \
    contigFinal/anchor.fasta \
    contigFinal/anchor.fasta \
    canu-non-contained/ecoli.trimmedReads.fasta.gz

rm -fr canu-anchor2
canu \
    -assemble \
    -p ecoli -d canu-anchor2 \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=4.8m \
    -pacbio-corrected \
    contigFinal/anchor.fasta \
    contigFinal/anchor.fasta \
    contigFinal/nonContainedLong.fasta
```

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

canu \
    -p ecoli -d canu-raw-40x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=4.8m \
    -pacbio-raw 3_pacbio/pacbio.40x.fasta

canu \
    -p ecoli -d canu-raw-all \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=4.8m \
    -pacbio-raw 3_pacbio/pacbio.fasta

rm -fr 9_qa_contig
quast --no-check \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-anchor/ecoli.contigs.fasta \
    canu-anchor2/ecoli.contigs.fasta \
    canu-raw-40x/ecoli.unitigs.fasta \
    canu-raw-all/ecoli.unitigs.fasta \
    1_genome/paralogs.fas \
    --label "merge,contig,contigTrim,canu-anchor,canu-anchor2,canu-40x,canu-all,paralogs" \
    -o 9_qa_contig
```
