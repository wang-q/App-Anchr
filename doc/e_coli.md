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
    - [With PE](#with-pe)
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
```

## Combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 100, 110, 120, 130, 140, and 150

```bash
BASE_DIR=$HOME/data/anchr/e_coli

# get the default adapter file
# anchr trim --help
cd ${BASE_DIR}
parallel --no-run-if-empty -j 2 "
    scythe \
        2_illumina/{}.fq.gz \
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
| scythe   |     151 | 1724565376 | 11458940 |
| Q20L100  |     151 | 1316581647 |  9150886 |
| Q20L110  |     151 | 1242406364 |  8547376 |
| Q20L120  |     151 | 1138097252 |  7742646 |
| Q20L130  |     151 |  977384738 |  6561892 |
| Q20L140  |     151 |  786030615 |  5213876 |
| Q20L150  |     151 |  742742028 |  4918836 |
| Q25L100  |     151 | 1097441477 |  7882294 |
| Q25L110  |     151 |  987545269 |  6976114 |
| Q25L120  |     151 |  839150352 |  5820278 |
| Q25L130  |     151 |  634128805 |  4303670 |
| Q25L140  |     151 |  421124326 |  2798656 |
| Q25L150  |     151 |  373356309 |  2472564 |
| Q30L100  |     133 |  713315968 |  5456016 |
| Q30L110  |     136 |  555209466 |  4121294 |
| Q30L120  |     140 |  383365150 |  2755884 |
| Q30L130  |     151 |  211952097 |  1468318 |
| Q30L140  |     151 |   92578231 |   617860 |
| Q30L150  |     151 |   69756203 |   461964 |

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
    | parallel --no-run-if-empty -j 4 "
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
| original_400000  |  120.8M |  26.0 |     151 |   75 |  76.08M |  37.018% | 4.64M | 4.57M |     0.98 |  4.94M |     0 | 0:01'51'' |
| original_800000  |  241.6M |  52.1 |     151 |   75 | 153.19M |  36.593% | 4.64M | 4.64M |     1.00 |  5.58M |     0 | 0:02'56'' |
| original_1200000 |  362.4M |  78.1 |     151 |   75 | 231.29M |  36.177% | 4.64M | 4.72M |     1.02 |  6.49M |     0 | 0:04'00'' |
| original_1600000 |  483.2M | 104.1 |     151 |   75 | 309.73M |  35.900% | 4.64M | 4.83M |     1.04 |  7.61M |     0 | 0:05'09'' |
| original_2000000 |    604M | 130.1 |     151 |   75 | 389.03M |  35.591% | 4.64M | 4.94M |     1.06 |  8.95M |     0 | 0:06'14'' |
| original_2400000 |  724.8M | 156.2 |     151 |   75 | 469.08M |  35.282% | 4.64M | 5.08M |     1.09 | 10.67M |     0 | 0:07'35'' |
| original_2800000 |  845.6M | 182.2 |     151 |   75 |  549.2M |  35.052% | 4.64M | 5.22M |     1.12 | 12.87M |     0 | 0:10'41'' |
| original_3200000 |  966.4M | 208.2 |     151 |   75 |  630.1M |  34.799% | 4.64M | 5.38M |     1.16 |  15.8M |     0 | 0:11'16'' |
| original_3600000 |   1.09G | 234.2 |     151 |   75 | 711.81M |  34.528% | 4.64M | 5.56M |     1.20 | 19.81M |     0 | 0:14'26'' |
| original_4000000 |   1.21G | 260.3 |     151 |   75 | 793.52M |  34.311% | 4.64M | 5.74M |     1.24 | 24.98M |     0 | 0:15'59'' |
| Q20L100_400000   | 115.12M |  24.8 |     143 |   69 |  99.86M |  13.254% | 4.64M | 4.55M |     0.98 |  4.64M |     0 | 0:02'23'' |
| Q20L100_800000   | 230.21M |  49.6 |     143 |   95 | 199.69M |  13.256% | 4.64M | 4.56M |     0.98 |   4.7M |     0 | 0:03'15'' |
| Q20L100_1200000  | 345.29M |  74.4 |     143 |   95 |  299.6M |  13.233% | 4.64M | 4.56M |     0.98 |   4.7M |     0 | 0:04'35'' |
| Q20L100_1600000  | 460.38M |  99.2 |     142 |   95 | 399.67M |  13.187% | 4.64M | 4.57M |     0.98 |  4.75M |     0 | 0:05'51'' |
| Q20L100_2000000  | 575.48M | 124.0 |     143 |   95 | 499.78M |  13.154% | 4.64M | 4.58M |     0.99 |  4.83M |     0 | 0:07'14'' |
| Q20L100_2400000  | 690.59M | 148.8 |     142 |   95 | 600.01M |  13.117% | 4.64M | 4.59M |     0.99 |  4.93M |     0 | 0:08'29'' |
| Q20L100_2800000  | 805.68M | 173.6 |     142 |   93 | 700.31M |  13.079% | 4.64M |  4.6M |     0.99 |  5.03M |     0 | 0:09'37'' |
| Q20L100_3200000  | 920.79M | 198.4 |     141 |   93 | 800.67M |  13.046% | 4.64M | 4.61M |     0.99 |  5.17M |     0 | 0:11'10'' |
| Q20L100_3600000  |   1.04G | 223.2 |     141 |   93 | 900.89M |  13.033% | 4.64M | 4.63M |     1.00 |  5.31M |     0 | 0:12'29'' |
| Q20L100_4000000  |   1.15G | 248.0 |     141 |   93 |      1G |  12.979% | 4.64M | 4.65M |     1.00 |  5.49M |     0 | 0:13'46'' |
| Q20L110_400000   | 116.27M |  25.1 |     145 |  101 | 100.96M |  13.170% | 4.64M | 4.54M |     0.98 |  4.84M |     0 | 0:02'00'' |
| Q20L110_800000   | 232.56M |  50.1 |     145 |  101 | 201.96M |  13.157% | 4.64M | 4.55M |     0.98 |   4.7M |     0 | 0:03'18'' |
| Q20L110_1200000  | 348.85M |  75.2 |     145 |   97 | 302.96M |  13.155% | 4.64M | 4.56M |     0.98 |   4.7M |     0 | 0:04'38'' |
| Q20L110_1600000  | 465.14M | 100.2 |     144 |   97 |    404M |  13.144% | 4.64M | 4.57M |     0.98 |  4.74M |     0 | 0:05'54'' |
| Q20L110_2000000  | 581.44M | 125.3 |     144 |   97 | 505.23M |  13.107% | 4.64M | 4.58M |     0.99 |  4.82M |     0 | 0:07'20'' |
| Q20L110_2400000  | 697.72M | 150.3 |     144 |   97 | 606.55M |  13.067% | 4.64M | 4.59M |     0.99 |  4.92M |     0 | 0:08'43'' |
| Q20L110_2800000  | 813.99M | 175.4 |     143 |   95 | 707.87M |  13.036% | 4.64M |  4.6M |     0.99 |  5.03M |     0 | 0:09'54'' |
| Q20L110_3200000  | 930.25M | 200.4 |     143 |   95 | 809.31M |  13.000% | 4.64M | 4.61M |     0.99 |  5.15M |     0 | 0:11'13'' |
| Q20L110_3600000  |   1.05G | 225.5 |     143 |   95 | 910.86M |  12.967% | 4.64M | 4.62M |     1.00 |   5.3M |     0 | 0:12'42'' |
| Q20L110_4000000  |   1.16G | 250.5 |     142 |   95 |   1.01G |  12.940% | 4.64M | 4.64M |     1.00 |  5.47M |     0 | 0:13'45'' |
| Q20L120_400000   |  117.6M |  25.3 |     147 |  105 | 102.19M |  13.104% | 4.64M | 4.54M |     0.98 |   4.9M |     0 | 0:02'03'' |
| Q20L120_800000   | 235.18M |  50.7 |     146 |  105 | 204.42M |  13.080% | 4.64M | 4.55M |     0.98 |  4.71M |     0 | 0:03'23'' |
| Q20L120_1200000  | 352.79M |  76.0 |     146 |  105 | 306.49M |  13.123% | 4.64M | 4.56M |     0.98 |  4.72M |     0 | 0:04'35'' |
| Q20L120_1600000  | 470.38M | 101.3 |     146 |  105 | 408.87M |  13.076% | 4.64M | 4.56M |     0.98 |  4.75M |     0 | 0:05'49'' |
| Q20L120_2000000  | 587.97M | 126.7 |     146 |  105 | 511.21M |  13.056% | 4.64M | 4.57M |     0.99 |  4.82M |     0 | 0:07'07'' |
| Q20L120_2400000  | 705.56M | 152.0 |     146 |  105 | 613.66M |  13.024% | 4.64M | 4.58M |     0.99 |  4.92M |     0 | 0:08'21'' |
| Q20L120_2800000  | 823.13M | 177.3 |     145 |  101 | 716.22M |  12.988% | 4.64M | 4.59M |     0.99 |  5.02M |     0 | 0:09'40'' |
| Q20L120_3200000  | 940.75M | 202.7 |     145 |  101 |  818.8M |  12.963% | 4.64M |  4.6M |     0.99 |  5.14M |     0 | 0:11'21'' |
| Q20L120_3600000  |   1.06G | 228.0 |     145 |   99 | 921.51M |  12.928% | 4.64M | 4.62M |     0.99 |  5.29M |     0 | 0:12'38'' |
| Q20L120_4000000  |   1.14G | 245.2 |     145 |   97 | 991.21M |  12.906% | 4.64M | 4.63M |     1.00 |  5.39M |     0 | 0:13'34'' |
| Q20L130_400000   | 119.17M |  25.7 |     148 |  105 | 103.52M |  13.125% | 4.64M | 4.52M |     0.97 |  4.85M |     0 | 0:01'56'' |
| Q20L130_800000   | 238.32M |  51.3 |     148 |  105 | 207.08M |  13.110% | 4.64M | 4.55M |     0.98 |  4.72M |     0 | 0:03'25'' |
| Q20L130_1200000  | 357.48M |  77.0 |     148 |  105 | 310.32M |  13.192% | 4.64M | 4.56M |     0.98 |  4.71M |     0 | 0:04'44'' |
| Q20L130_1600000  | 476.63M | 102.7 |     148 |  105 |    414M |  13.139% | 4.64M | 4.56M |     0.98 |  4.75M |     0 | 0:05'59'' |
| Q20L130_2000000  | 595.79M | 128.4 |     148 |  105 | 517.68M |  13.111% | 4.64M | 4.57M |     0.98 |  4.81M |     0 | 0:07'11'' |
| Q20L130_2400000  | 714.95M | 154.0 |     148 |  105 | 621.51M |  13.070% | 4.64M | 4.58M |     0.99 |  4.91M |     0 | 0:08'46'' |
| Q20L130_2800000  | 834.11M | 179.7 |     148 |  105 |  725.3M |  13.045% | 4.64M | 4.59M |     0.99 |  5.01M |     0 | 0:09'58'' |
| Q20L130_3200000  | 953.27M | 205.4 |     147 |  105 | 829.27M |  13.008% | 4.64M | 4.59M |     0.99 |  5.13M |     0 | 0:11'21'' |
| Q20L140_400000   | 120.61M |  26.0 |     150 |  105 |  104.6M |  13.269% | 4.64M | 4.49M |     0.97 |  4.82M |     0 | 0:02'10'' |
| Q20L140_800000   | 241.21M |  52.0 |     150 |  105 | 208.99M |  13.357% | 4.64M | 4.53M |     0.98 |  4.71M |     0 | 0:03'22'' |
| Q20L140_1200000  | 361.82M |  77.9 |     150 |  105 | 313.62M |  13.321% | 4.64M | 4.55M |     0.98 |  4.71M |     0 | 0:04'41'' |
| Q20L140_1600000  | 482.42M | 103.9 |     150 |  105 | 418.21M |  13.311% | 4.64M | 4.55M |     0.98 |  4.75M |     0 | 0:05'48'' |
| Q20L140_2000000  | 603.03M | 129.9 |     150 |  105 | 523.06M |  13.261% | 4.64M | 4.56M |     0.98 |  4.81M |     0 | 0:07'14'' |
| Q20L140_2400000  | 723.64M | 155.9 |     150 |  105 | 627.81M |  13.242% | 4.64M | 4.57M |     0.98 |  4.89M |     0 | 0:08'50'' |
| Q20L150_400000   |  120.8M |  26.0 |     150 |  105 | 104.77M |  13.271% | 4.64M | 4.47M |     0.96 |  4.81M |     0 | 0:02'00'' |
| Q20L150_800000   |  241.6M |  52.1 |     150 |  105 | 209.46M |  13.301% | 4.64M | 4.53M |     0.98 |  4.72M |     0 | 0:03'19'' |
| Q20L150_1200000  |  362.4M |  78.1 |     150 |  105 | 314.43M |  13.237% | 4.64M | 4.54M |     0.98 |  4.71M |     0 | 0:04'49'' |
| Q20L150_1600000  |  483.2M | 104.1 |     150 |  105 |  419.2M |  13.245% | 4.64M | 4.55M |     0.98 |  4.75M |     0 | 0:06'04'' |
| Q20L150_2000000  |    604M | 130.1 |     150 |  105 | 524.15M |  13.219% | 4.64M | 4.56M |     0.98 |   4.8M |     0 | 0:07'25'' |
| Q20L150_2400000  |  724.8M | 156.2 |     150 |  105 |  629.2M |  13.190% | 4.64M | 4.57M |     0.98 |  4.88M |     0 | 0:08'32'' |
| Q25L100_400000   | 111.39M |  24.0 |     139 |   89 | 104.84M |   5.875% | 4.64M | 4.54M |     0.98 |  4.73M |     0 | 0:02'02'' |
| Q25L100_800000   | 222.79M |  48.0 |     138 |   89 |  209.7M |   5.875% | 4.64M | 4.55M |     0.98 |  4.67M |     0 | 0:03'08'' |
| Q25L100_1200000  | 334.18M |  72.0 |     138 |   89 | 314.49M |   5.891% | 4.64M | 4.56M |     0.98 |  4.66M |     0 | 0:04'34'' |
| Q25L100_1600000  | 445.51M |  96.0 |     138 |   89 | 419.35M |   5.874% | 4.64M | 4.56M |     0.98 |  4.66M |     0 | 0:05'37'' |
| Q25L100_2000000  | 556.91M | 120.0 |     137 |   89 | 524.15M |   5.883% | 4.64M | 4.56M |     0.98 |  4.66M |     0 | 0:06'50'' |
| Q25L100_2400000  | 668.31M | 144.0 |     137 |   87 | 629.02M |   5.878% | 4.64M | 4.56M |     0.98 |  4.67M |     0 | 0:08'22'' |
| Q25L100_2800000  | 779.65M | 168.0 |     136 |   87 | 733.82M |   5.878% | 4.64M | 4.56M |     0.98 |  4.67M |     0 | 0:09'40'' |
| Q25L100_3200000  | 891.05M | 192.0 |     136 |   87 | 838.68M |   5.877% | 4.64M | 4.57M |     0.98 |  4.68M |     0 | 0:10'47'' |
| Q25L100_3600000  |      1G | 216.0 |     135 |   87 | 943.63M |   5.866% | 4.64M | 4.57M |     0.98 |   4.7M |     0 | 0:12'09'' |
| Q25L100_4000000  |    1.1G | 236.4 |     135 |   87 |   1.03G |   5.864% | 4.64M | 4.57M |     0.98 |  4.71M |     0 | 0:13'30'' |
| Q25L110_400000   | 113.26M |  24.4 |     141 |   91 | 106.46M |   6.001% | 4.64M | 4.53M |     0.98 |  4.73M |     0 | 0:01'49'' |
| Q25L110_800000   | 226.52M |  48.8 |     141 |   91 | 213.13M |   5.913% | 4.64M | 4.55M |     0.98 |  4.67M |     0 | 0:03'25'' |
| Q25L110_1200000  | 339.77M |  73.2 |     140 |   91 | 319.53M |   5.956% | 4.64M | 4.56M |     0.98 |  4.66M |     0 | 0:04'45'' |
| Q25L110_1600000  |    453M |  97.6 |     140 |   91 | 426.03M |   5.954% | 4.64M | 4.56M |     0.98 |  4.66M |     0 | 0:05'40'' |
| Q25L110_2000000  | 566.24M | 122.0 |     140 |   91 |  532.6M |   5.941% | 4.64M | 4.56M |     0.98 |  4.67M |     0 | 0:07'05'' |
| Q25L110_2400000  | 679.51M | 146.4 |     140 |   91 | 639.01M |   5.959% | 4.64M | 4.56M |     0.98 |  4.67M |     0 | 0:08'50'' |
| Q25L110_2800000  | 792.74M | 170.8 |     139 |   91 | 745.63M |   5.943% | 4.64M | 4.56M |     0.98 |  4.68M |     0 | 0:09'56'' |
| Q25L110_3200000  | 905.99M | 195.2 |     138 |   89 | 852.13M |   5.945% | 4.64M | 4.57M |     0.98 |  4.69M |     0 | 0:11'10'' |
| Q25L120_400000   | 115.35M |  24.9 |     144 |   95 |  108.3M |   6.114% | 4.64M | 4.51M |     0.97 |  4.75M |     0 | 0:02'11'' |
| Q25L120_800000   |  230.7M |  49.7 |     143 |   95 | 216.66M |   6.083% | 4.64M | 4.55M |     0.98 |  4.68M |     0 | 0:03'19'' |
| Q25L120_1200000  | 346.02M |  74.5 |     143 |   93 | 324.97M |   6.086% | 4.64M | 4.55M |     0.98 |  4.67M |     0 | 0:04'41'' |
| Q25L120_1600000  | 461.35M |  99.4 |     143 |   93 |  433.3M |   6.080% | 4.64M | 4.56M |     0.98 |  4.67M |     0 | 0:05'51'' |
| Q25L120_2000000  |  576.7M | 124.2 |     143 |   93 | 541.65M |   6.077% | 4.64M | 4.56M |     0.98 |  4.67M |     0 | 0:07'15'' |
| Q25L120_2400000  | 692.05M | 149.1 |     142 |   93 | 649.95M |   6.083% | 4.64M | 4.56M |     0.98 |  4.68M |     0 | 0:08'51'' |
| Q25L120_2800000  | 807.39M | 173.9 |     142 |   93 | 758.32M |   6.077% | 4.64M | 4.56M |     0.98 |  4.68M |     0 | 0:10'12'' |
| Q25L130_400000   | 117.87M |  25.4 |     147 |  101 | 110.35M |   6.384% | 4.64M | 4.47M |     0.96 |  4.79M |     0 | 0:02'04'' |
| Q25L130_800000   | 235.75M |  50.8 |     146 |  101 | 220.72M |   6.374% | 4.64M | 4.53M |     0.98 |  4.71M |     0 | 0:03'27'' |
| Q25L130_1200000  | 353.62M |  76.2 |     146 |  101 | 331.08M |   6.374% | 4.64M | 4.54M |     0.98 |   4.7M |     0 | 0:04'47'' |
| Q25L130_1600000  | 471.51M | 101.6 |     146 |   99 | 441.41M |   6.384% | 4.64M | 4.55M |     0.98 |  4.69M |     0 | 0:06'00'' |
| Q25L130_2000000  | 589.39M | 127.0 |     146 |   99 | 551.82M |   6.374% | 4.64M | 4.55M |     0.98 |  4.69M |     0 | 0:07'30'' |
| Q25L140_400000   | 120.38M |  25.9 |     150 |  105 | 112.03M |   6.940% | 4.64M | 4.37M |     0.94 |  4.76M |     0 | 0:02'03'' |
| Q25L140_800000   | 240.76M |  51.9 |     150 |  105 | 224.15M |   6.897% | 4.64M | 4.48M |     0.96 |  4.73M |     0 | 0:03'20'' |
| Q25L140_1200000  | 361.14M |  77.8 |     150 |  105 | 336.21M |   6.902% | 4.64M | 4.51M |     0.97 |  4.71M |     0 | 0:04'42'' |
| Q25L150_400000   |  120.8M |  26.0 |     150 |  105 | 112.21M |   7.113% | 4.64M | 4.32M |     0.93 |  4.71M |     0 | 0:01'57'' |
| Q25L150_800000   |  241.6M |  52.1 |     150 |  105 |  224.7M |   6.997% | 4.64M | 4.46M |     0.96 |  4.72M |     0 | 0:03'35'' |
| Q25L150_1200000  |  362.4M |  78.1 |     150 |  105 | 336.98M |   7.013% | 4.64M |  4.5M |     0.97 |  4.71M |     0 | 0:04'24'' |
| Q30L100_400000   |  104.6M |  22.5 |     130 |   81 | 101.94M |   2.545% | 4.64M | 4.51M |     0.97 |  4.73M |     0 | 0:01'55'' |
| Q30L100_800000   | 209.15M |  45.1 |     129 |   81 |  203.9M |   2.510% | 4.64M | 4.54M |     0.98 |  4.68M |     0 | 0:03'11'' |
| Q30L100_1200000  | 313.77M |  67.6 |     129 |   81 | 305.91M |   2.507% | 4.64M | 4.55M |     0.98 |  4.67M |     0 | 0:04'23'' |
| Q30L100_1600000  | 418.32M |  90.1 |     129 |   81 | 407.86M |   2.501% | 4.64M | 4.56M |     0.98 |  4.67M |     0 | 0:05'25'' |
| Q30L100_2000000  | 522.97M | 112.7 |     128 |   81 | 509.93M |   2.493% | 4.64M | 4.56M |     0.98 |  4.66M |     0 | 0:06'24'' |
| Q30L100_2400000  | 627.56M | 135.2 |     128 |   81 | 611.88M |   2.499% | 4.64M | 4.56M |     0.98 |  4.66M |     0 | 0:07'38'' |
| Q30L110_400000   | 107.76M |  23.2 |     134 |   87 | 104.95M |   2.609% | 4.64M | 4.47M |     0.96 |  4.76M |     0 | 0:01'49'' |
| Q30L110_800000   | 215.55M |  46.4 |     133 |   85 | 209.97M |   2.590% | 4.64M | 4.53M |     0.98 |  4.69M |     0 | 0:03'22'' |
| Q30L110_1200000  | 323.33M |  69.7 |     133 |   87 |    315M |   2.578% | 4.64M | 4.54M |     0.98 |  4.69M |     0 | 0:04'36'' |
| Q30L110_1600000  | 431.13M |  92.9 |     133 |   87 | 420.06M |   2.569% | 4.64M | 4.55M |     0.98 |  4.68M |     0 | 0:05'23'' |
| Q30L110_2000000  | 538.87M | 116.1 |     132 |   85 | 525.01M |   2.571% | 4.64M | 4.55M |     0.98 |  4.68M |     0 | 0:05'52'' |
| Q30L120_400000   | 111.29M |  24.0 |     138 |   91 | 108.18M |   2.795% | 4.64M |  4.4M |     0.95 |  4.74M |     0 | 0:01'52'' |
| Q30L120_800000   | 222.57M |  48.0 |     138 |   91 | 216.57M |   2.697% | 4.64M |  4.5M |     0.97 |  4.71M |     0 | 0:02'59'' |
| Q30L120_1200000  | 333.85M |  71.9 |     138 |   91 | 324.89M |   2.686% | 4.64M | 4.52M |     0.97 |   4.7M |     0 | 0:03'33'' |
| Q30L130_400000   | 115.47M |  24.9 |     144 |   95 | 111.91M |   3.087% | 4.64M |  4.2M |     0.90 |  4.57M |     0 | 0:01'55'' |

| Name             | N50SRclean |    Sum |      # | N50Anchor |     Sum |    # | N50Anchor2 |    Sum |  # | N50Others |     Sum |      # |   RunTime |
|:-----------------|-----------:|-------:|-------:|----------:|--------:|-----:|-----------:|-------:|---:|----------:|--------:|-------:|----------:|
| original_400000  |       2975 |  4.94M |   5517 |      3732 |   4.01M | 1322 |       1371 | 77.99K | 57 |       466 | 853.04K |   4138 | 0:01'06'' |
| original_800000  |       1578 |  5.58M |  12914 |      2352 |   3.63M | 1653 |       1275 |  26.5K | 21 |       358 |   1.92M |  11240 | 0:01'37'' |
| original_1200000 |        855 |  6.49M |  24289 |      1832 |   2.85M | 1591 |       1280 |  8.68K |  7 |       285 |   3.63M |  22691 | 0:01'50'' |
| original_1600000 |        490 |  7.61M |  38222 |      1590 |   2.18M | 1335 |       1447 |  2.79K |  2 |       183 |   5.43M |  36885 | 0:02'17'' |
| original_2000000 |        269 |  8.95M |  54953 |      1490 |   1.58M | 1042 |          0 |      0 |  0 |       125 |   7.36M |  53911 | 0:02'31'' |
| original_2400000 |        127 | 10.67M |  76590 |      1449 |   1.15M |  772 |          0 |      0 |  0 |       100 |   9.52M |  75818 | 0:02'36'' |
| original_2800000 |         97 | 12.87M | 104203 |      1341 | 849.67K |  605 |          0 |      0 |  0 |        92 |  12.02M | 103598 | 0:02'51'' |
| original_3200000 |         90 |  15.8M | 141238 |      1342 | 614.89K |  441 |          0 |      0 |  0 |        88 |  15.18M | 140797 | 0:03'23'' |
| original_3600000 |         85 | 19.81M | 192540 |      1314 | 416.39K |  310 |          0 |      0 |  0 |        85 |   19.4M | 192230 | 0:03'40'' |
| original_4000000 |         82 | 24.98M | 259047 |      1264 | 293.79K |  223 |          0 |      0 |  0 |        82 |  24.69M | 258824 | 0:03'59'' |
| Q20L100_400000   |      10917 |  4.64M |   1376 |     11286 |   4.47M |  597 |       1750 |  1.75K |  1 |       268 |  159.7K |    778 | 0:01'21'' |
| Q20L100_800000   |       9901 |   4.7M |   1567 |     10426 |   4.48M |  644 |       1427 |  1.43K |  1 |       283 | 217.84K |    922 | 0:01'47'' |
| Q20L100_1200000  |      12432 |   4.7M |   1412 |     12833 |   4.53M |  543 |          0 |      0 |  0 |       189 | 166.38K |    869 | 0:02'31'' |
| Q20L100_1600000  |      10587 |  4.75M |   1851 |     11021 |   4.52M |  643 |          0 |      0 |  0 |       189 | 229.76K |   1208 | 0:02'31'' |
| Q20L100_2000000  |       7811 |  4.83M |   2536 |      8352 |   4.51M |  783 |          0 |      0 |  0 |       185 | 313.94K |   1753 | 0:03'15'' |
| Q20L100_2400000  |       5572 |  4.93M |   3452 |      6094 |   4.48M |  991 |          0 |      0 |  0 |       172 | 446.39K |   2461 | 0:02'58'' |
| Q20L100_2800000  |       4096 |  5.03M |   4465 |      4738 |   4.43M | 1225 |          0 |      0 |  0 |       185 | 599.11K |   3240 | 0:03'33'' |
| Q20L100_3200000  |       3189 |  5.17M |   5766 |      3782 |   4.32M | 1412 |          0 |      0 |  0 |       195 | 848.07K |   4354 | 0:03'49'' |
| Q20L100_3600000  |       2503 |  5.31M |   7119 |      3142 |   4.21M | 1584 |          0 |      0 |  0 |       228 |   1.09M |   5535 | 0:03'51'' |
| Q20L100_4000000  |       1951 |  5.49M |   8924 |      2605 |   4.01M | 1729 |          0 |      0 |  0 |       295 |   1.48M |   7195 | 0:04'37'' |
| Q20L110_400000   |       2401 |  4.84M |   4172 |      3043 |   3.85M | 1470 |       1161 |  3.52K |  3 |       566 | 989.34K |   2699 | 0:01'24'' |
| Q20L110_800000   |       8353 |   4.7M |   1593 |      8728 |   4.46M |  738 |          0 |      0 |  0 |       348 | 235.08K |    855 | 0:01'35'' |
| Q20L110_1200000  |      11427 |   4.7M |   1446 |     12002 |   4.51M |  578 |          0 |      0 |  0 |       228 | 184.99K |    868 | 0:02'21'' |
| Q20L110_1600000  |       9772 |  4.74M |   1764 |     10289 |   4.52M |  647 |          0 |      0 |  0 |       193 |  218.2K |   1117 | 0:02'41'' |
| Q20L110_2000000  |       7937 |  4.82M |   2419 |      8424 |   4.51M |  779 |          0 |      0 |  0 |       190 | 305.12K |   1640 | 0:03'14'' |
| Q20L110_2400000  |       5689 |  4.92M |   3362 |      6160 |   4.49M |  994 |          0 |      0 |  0 |       171 | 425.82K |   2368 | 0:03'19'' |
| Q20L110_2800000  |       4141 |  5.03M |   4399 |      4743 |   4.42M | 1201 |          0 |      0 |  0 |       189 | 601.99K |   3198 | 0:03'59'' |
| Q20L110_3200000  |       3277 |  5.15M |   5521 |      3952 |   4.33M | 1386 |          0 |      0 |  0 |       207 | 818.27K |   4135 | 0:03'52'' |
| Q20L110_3600000  |       2529 |   5.3M |   6999 |      3177 |   4.19M | 1578 |          0 |      0 |  0 |       264 |   1.11M |   5421 | 0:04'01'' |
| Q20L110_4000000  |       1976 |  5.47M |   8578 |      2669 |   4.02M | 1708 |          0 |      0 |  0 |       310 |   1.45M |   6870 | 0:04'33'' |
| Q20L120_400000   |       1990 |   4.9M |   5131 |      2679 |    3.6M | 1506 |       1074 |  1.07K |  1 |       531 |    1.3M |   3624 | 0:01'23'' |
| Q20L120_800000   |       6536 |  4.71M |   1902 |      7021 |   4.41M |  877 |          0 |      0 |  0 |       436 | 303.99K |   1025 | 0:01'44'' |
| Q20L120_1200000  |       8732 |  4.72M |   1686 |      9323 |   4.48M |  727 |          0 |      0 |  0 |       278 | 238.54K |    959 | 0:02'19'' |
| Q20L120_1600000  |       8918 |  4.75M |   1843 |      9319 |    4.5M |  714 |          0 |      0 |  0 |       228 | 248.01K |   1129 | 0:02'43'' |
| Q20L120_2000000  |       6965 |  4.82M |   2432 |      7495 |   4.51M |  845 |          0 |      0 |  0 |       199 | 310.34K |   1587 | 0:03'16'' |
| Q20L120_2400000  |       5476 |  4.92M |   3231 |      5895 |   4.47M |  994 |          0 |      0 |  0 |       209 | 448.87K |   2237 | 0:03'42'' |
| Q20L120_2800000  |       4400 |  5.02M |   4182 |      5110 |    4.4M | 1155 |          0 |      0 |  0 |       203 | 613.16K |   3027 | 0:03'57'' |
| Q20L120_3200000  |       3445 |  5.14M |   5290 |      4116 |   4.33M | 1343 |          0 |      0 |  0 |       221 | 810.01K |   3947 | 0:03'59'' |
| Q20L120_3600000  |       2546 |  5.29M |   6729 |      3201 |   4.22M | 1568 |          0 |      0 |  0 |       255 |   1.07M |   5161 | 0:03'57'' |
| Q20L120_4000000  |       2164 |  5.39M |   7742 |      2825 |   4.12M | 1668 |          0 |      0 |  0 |       285 |   1.27M |   6074 | 0:04'14'' |
| Q20L130_400000   |       2090 |  4.85M |   4971 |      2813 |    3.6M | 1452 |       1251 |  7.82K |  6 |       524 |   1.24M |   3513 | 0:01'28'' |
| Q20L130_800000   |       5909 |  4.72M |   2177 |      6387 |   4.34M |  978 |       1129 |  1.13K |  1 |       485 | 375.03K |   1198 | 0:01'52'' |
| Q20L130_1200000  |       7468 |  4.71M |   1820 |      7818 |   4.45M |  810 |          0 |      0 |  0 |       317 | 266.27K |   1010 | 0:02'27'' |
| Q20L130_1600000  |       7656 |  4.75M |   1967 |      8107 |   4.48M |  802 |       1284 |  1.28K |  1 |       244 | 266.62K |   1164 | 0:02'38'' |
| Q20L130_2000000  |       6584 |  4.81M |   2472 |      7024 |   4.46M |  884 |          0 |      0 |  0 |       243 | 348.58K |   1588 | 0:02'52'' |
| Q20L130_2400000  |       5259 |  4.91M |   3249 |      5749 |   4.45M | 1028 |          0 |      0 |  0 |       209 | 457.11K |   2221 | 0:03'27'' |
| Q20L130_2800000  |       4176 |  5.01M |   4096 |      4740 |    4.4M | 1187 |          0 |      0 |  0 |       218 | 604.57K |   2909 | 0:03'46'' |
| Q20L130_3200000  |       3464 |  5.13M |   5136 |      3970 |   4.34M | 1358 |          0 |      0 |  0 |       240 | 792.31K |   3778 | 0:03'43'' |
| Q20L140_400000   |       1870 |  4.82M |   5490 |      2674 |   3.38M | 1433 |       1337 |  6.25K |  5 |       525 |   1.43M |   4052 | 0:01'20'' |
| Q20L140_800000   |       4580 |  4.71M |   2585 |      5200 |   4.21M | 1109 |          0 |      0 |  0 |       535 |  501.9K |   1476 | 0:01'40'' |
| Q20L140_1200000  |       6064 |  4.71M |   2143 |      6628 |   4.36M |  947 |          0 |      0 |  0 |       466 | 357.72K |   1196 | 0:02'17'' |
| Q20L140_1600000  |       5973 |  4.75M |   2271 |      6570 |    4.4M |  935 |          0 |      0 |  0 |       357 | 350.93K |   1336 | 0:02'50'' |
| Q20L140_2000000  |       5717 |  4.81M |   2639 |      6214 |   4.41M |  973 |          0 |      0 |  0 |       310 | 397.89K |   1666 | 0:02'41'' |
| Q20L140_2400000  |       4698 |  4.89M |   3309 |      5153 |    4.4M | 1114 |          0 |      0 |  0 |       270 |  486.7K |   2195 | 0:03'22'' |
| Q20L150_400000   |       1795 |  4.81M |   5574 |      2603 |   3.33M | 1414 |       1259 | 14.04K | 11 |       524 |   1.46M |   4149 | 0:01'28'' |
| Q20L150_800000   |       4130 |  4.72M |   2783 |      4618 |   4.17M | 1177 |       1212 |  4.79K |  4 |       529 | 544.13K |   1602 | 0:01'39'' |
| Q20L150_1200000  |       5747 |  4.71M |   2189 |      6214 |   4.34M |  970 |          0 |      0 |  0 |       466 | 368.33K |   1219 | 0:02'08'' |
| Q20L150_1600000  |       5984 |  4.75M |   2299 |      6574 |   4.37M |  930 |          0 |      0 |  0 |       433 | 373.96K |   1369 | 0:02'35'' |
| Q20L150_2000000  |       5499 |   4.8M |   2672 |      6134 |   4.39M |  988 |          0 |      0 |  0 |       326 | 411.15K |   1684 | 0:03'00'' |
| Q20L150_2400000  |       4716 |  4.88M |   3272 |      5249 |   4.38M | 1095 |          0 |      0 |  0 |       297 | 504.74K |   2177 | 0:03'09'' |
| Q25L100_400000   |       3644 |  4.73M |   2996 |      4292 |   4.13M | 1239 |       1088 |  1.09K |  1 |       547 | 602.64K |   1756 | 0:01'21'' |
| Q25L100_800000   |       8976 |  4.67M |   1474 |      9561 |   4.46M |  697 |          0 |      0 |  0 |       408 | 210.36K |    777 | 0:01'49'' |
| Q25L100_1200000  |      12061 |  4.66M |   1199 |     12463 |   4.51M |  565 |          0 |      0 |  0 |       259 | 147.42K |    634 | 0:02'32'' |
| Q25L100_1600000  |      14006 |  4.66M |   1122 |     14400 |   4.52M |  491 |          0 |      0 |  0 |       234 | 137.33K |    631 | 0:02'48'' |
| Q25L100_2000000  |      15795 |  4.66M |   1067 |     16152 |   4.53M |  441 |          0 |      0 |  0 |       222 | 130.39K |    626 | 0:03'07'' |
| Q25L100_2400000  |      16038 |  4.67M |   1155 |     16559 |   4.53M |  442 |          0 |      0 |  0 |       214 | 143.72K |    713 | 0:03'35'' |
| Q25L100_2800000  |      17658 |  4.67M |   1176 |     18269 |   4.53M |  414 |          0 |      0 |  0 |       187 | 142.57K |    762 | 0:03'55'' |
| Q25L100_3200000  |      15453 |  4.68M |   1274 |     15523 |   4.53M |  449 |          0 |      0 |  0 |       182 | 150.81K |    825 | 0:04'16'' |
| Q25L100_3600000  |      14878 |   4.7M |   1403 |     15497 |   4.53M |  471 |          0 |      0 |  0 |       173 | 163.85K |    932 | 0:04'23'' |
| Q25L100_4000000  |      13243 |  4.71M |   1498 |     13729 |   4.54M |  494 |          0 |      0 |  0 |       173 | 171.03K |   1004 | 0:04'56'' |
| Q25L110_400000   |       3253 |  4.73M |   3259 |      3938 |   4.06M | 1310 |       1222 |  1.22K |  1 |       545 | 670.15K |   1948 | 0:01'30'' |
| Q25L110_800000   |       7974 |  4.67M |   1641 |      8497 |   4.43M |  796 |          0 |      0 |  0 |       444 | 240.62K |    845 | 0:01'52'' |
| Q25L110_1200000  |      10237 |  4.66M |   1344 |     10688 |   4.49M |  641 |          0 |      0 |  0 |       294 | 178.33K |    703 | 0:02'22'' |
| Q25L110_1600000  |      12046 |  4.66M |   1248 |     12493 |    4.5M |  578 |          0 |      0 |  0 |       269 | 162.06K |    670 | 0:03'02'' |
| Q25L110_2000000  |      12480 |  4.67M |   1245 |     13165 |   4.51M |  550 |          0 |      0 |  0 |       263 | 162.72K |    695 | 0:03'12'' |
| Q25L110_2400000  |      13031 |  4.67M |   1229 |     13687 |   4.51M |  508 |          0 |      0 |  0 |       240 | 160.62K |    721 | 0:03'29'' |
| Q25L110_2800000  |      13140 |  4.68M |   1274 |     13938 |   4.52M |  506 |          0 |      0 |  0 |       220 | 158.84K |    768 | 0:03'45'' |
| Q25L110_3200000  |      13138 |  4.69M |   1378 |     13661 |   4.52M |  518 |          0 |      0 |  0 |       202 |  168.3K |    860 | 0:03'48'' |
| Q25L120_400000   |       2598 |  4.75M |   4109 |      3252 |    3.8M | 1392 |       1158 |  3.48K |  3 |       536 | 952.75K |   2714 | 0:01'27'' |
| Q25L120_800000   |       5973 |  4.68M |   1983 |      6596 |   4.35M |  934 |       1144 |  1.14K |  1 |       505 | 332.45K |   1048 | 0:01'47'' |
| Q25L120_1200000  |       8224 |  4.67M |   1571 |      8696 |   4.44M |  767 |          0 |      0 |  0 |       405 | 225.84K |    804 | 0:02'30'' |
| Q25L120_1600000  |       9530 |  4.67M |   1430 |      9997 |   4.47M |  686 |          0 |      0 |  0 |       364 | 199.84K |    744 | 0:02'53'' |
| Q25L120_2000000  |      10434 |  4.67M |   1382 |     10858 |   4.48M |  634 |          0 |      0 |  0 |       296 | 190.61K |    748 | 0:03'31'' |
| Q25L120_2400000  |      11128 |  4.68M |   1355 |     11817 |    4.5M |  604 |          0 |      0 |  0 |       268 | 177.99K |    751 | 0:03'48'' |
| Q25L120_2800000  |      10912 |  4.68M |   1393 |     11128 |   4.51M |  598 |          0 |      0 |  0 |       244 |  177.7K |    795 | 0:03'48'' |
| Q25L130_400000   |       1773 |  4.79M |   5638 |      2604 |   3.29M | 1408 |       1221 |   4.7K |  4 |       539 |   1.49M |   4226 | 0:01'35'' |
| Q25L130_800000   |       4050 |  4.71M |   2817 |      4658 |   4.14M | 1182 |          0 |      0 |  0 |       544 | 571.76K |   1635 | 0:01'52'' |
| Q25L130_1200000  |       5310 |   4.7M |   2197 |      5869 |    4.3M | 1005 |       1086 |  1.09K |  1 |       512 | 394.09K |   1191 | 0:02'11'' |
| Q25L130_1600000  |       6864 |  4.69M |   1865 |      7301 |   4.39M |  897 |          0 |      0 |  0 |       479 | 298.64K |    968 | 0:02'33'' |
| Q25L130_2000000  |       7488 |  4.69M |   1783 |      7988 |   4.41M |  830 |          0 |      0 |  0 |       478 | 284.45K |    953 | 0:03'14'' |
| Q25L140_400000   |       1261 |  4.76M |   7286 |      2224 |   2.73M | 1298 |       1098 |  8.22K |  7 |       488 |   2.02M |   5981 | 0:01'26'' |
| Q25L140_800000   |       2520 |  4.73M |   4152 |      3371 |   3.73M | 1342 |       1217 |  5.87K |  5 |       548 | 996.28K |   2805 | 0:01'48'' |
| Q25L140_1200000  |       3524 |  4.71M |   3163 |      4237 |   4.02M | 1227 |       1117 |  1.12K |  1 |       556 | 687.16K |   1935 | 0:02'15'' |
| Q25L150_400000   |       1211 |  4.71M |   7415 |      2220 |   2.61M | 1256 |       1234 | 16.69K | 13 |       494 |   2.07M |   6146 | 0:01'19'' |
| Q25L150_800000   |       2353 |  4.72M |   4396 |      3182 |   3.63M | 1348 |       1366 |  7.63K |  6 |       537 |   1.08M |   3042 | 0:01'39'' |
| Q25L150_1200000  |       3093 |  4.71M |   3401 |      3914 |   3.96M | 1270 |       1146 |  1.15K |  1 |       547 | 750.43K |   2130 | 0:02'08'' |
| Q30L100_400000   |       2274 |  4.73M |   4462 |      3094 |   3.68M | 1408 |       1199 |  3.51K |  3 |       539 |   1.05M |   3051 | 0:01'24'' |
| Q30L100_800000   |       5304 |  4.68M |   2291 |      5845 |    4.3M | 1028 |          0 |      0 |  0 |       489 | 379.58K |   1263 | 0:01'52'' |
| Q30L100_1200000  |       7107 |  4.67M |   1801 |      7667 |   4.39M |  831 |          0 |      0 |  0 |       457 | 276.13K |    970 | 0:02'22'' |
| Q30L100_1600000  |       8656 |  4.67M |   1607 |      8942 |   4.44M |  742 |          0 |      0 |  0 |       423 | 230.25K |    865 | 0:02'48'' |
| Q30L100_2000000  |       9969 |  4.66M |   1472 |     10368 |   4.45M |  667 |          0 |      0 |  0 |       420 | 210.45K |    805 | 0:03'16'' |
| Q30L100_2400000  |      10798 |  4.66M |   1399 |     11471 |   4.48M |  640 |          0 |      0 |  0 |       313 | 185.67K |    759 | 0:03'30'' |
| Q30L110_400000   |       1735 |  4.76M |   5863 |      2564 |   3.27M | 1420 |       1271 |  7.45K |  6 |       506 |   1.48M |   4437 | 0:01'28'' |
| Q30L110_800000   |       3875 |  4.69M |   2955 |      4371 |   4.12M | 1198 |          0 |      0 |  0 |       531 | 575.33K |   1757 | 0:01'53'' |
| Q30L110_1200000  |       5116 |  4.69M |   2375 |      5636 |   4.27M | 1053 |          0 |      0 |  0 |       517 | 420.31K |   1322 | 0:02'24'' |
| Q30L110_1600000  |       5959 |  4.68M |   2090 |      6458 |   4.34M |  958 |       1069 |  1.07K |  1 |       470 | 339.78K |   1131 | 0:02'47'' |
| Q30L110_2000000  |       6894 |  4.68M |   1837 |      7359 |   4.39M |  861 |          0 |      0 |  0 |       458 | 281.16K |    976 | 0:03'18'' |
| Q30L120_400000   |       1372 |  4.74M |   7028 |      2241 |   2.87M | 1356 |       1229 |  4.96K |  4 |       487 |   1.86M |   5668 | 0:01'33'' |
| Q30L120_800000   |       2689 |  4.71M |   3933 |      3383 |   3.83M | 1360 |       1356 |  2.59K |  2 |       527 | 879.01K |   2571 | 0:01'50'' |
| Q30L120_1200000  |       3776 |   4.7M |   3030 |      4350 |   4.09M | 1219 |          0 |      0 |  0 |       528 |  610.2K |   1811 | 0:02'23'' |
| Q30L130_400000   |       1055 |  4.57M |   8198 |      2034 |   2.34M | 1180 |       1157 |  8.67K |  7 |       467 |   2.22M |   7011 | 0:01'21'' |

| Name            | N50SRclean |   Sum |    # | N50Anchor |   Sum |    # | N50Anchor2 |     Sum |  # | N50Others |     Sum |    # |   RunTime |
|:----------------|-----------:|------:|-----:|----------:|------:|-----:|-----------:|--------:|---:|----------:|--------:|-----:|----------:|
| original_400000 |       2975 | 4.94M | 5517 |      3732 | 4.01M | 1322 |       1371 |  77.99K | 57 |       466 | 853.04K | 4138 | 0:00'48'' |
| Q20L100_1200000 |      12432 |  4.7M | 1412 |     12833 | 4.53M |  543 |          0 |       0 |  0 |       189 | 166.38K |  869 | 0:02'31'' |
| Q20L110_1200000 |      11427 |  4.7M | 1446 |     12002 | 4.51M |  578 |          0 |       0 |  0 |       228 | 184.99K |  868 | 0:02'21'' |
| Q20L120_1600000 |       8918 | 4.75M | 1843 |      9319 |  4.5M |  714 |          0 |       0 |  0 |       228 | 248.01K | 1129 | 0:02'28'' |
| Q20L130_1600000 |       7656 | 4.75M | 1967 |      8107 | 4.48M |  802 |       1284 |   1.28K |  1 |       244 | 266.62K | 1164 | 0:02'34'' |
| Q20L140_1600000 |       5973 | 4.75M | 2271 |      6570 |  4.4M |  935 |          0 |       0 |  0 |       357 | 350.93K | 1336 | 0:02'24'' |
| Q20L150_1600000 |       5984 | 4.75M | 2299 |      6574 | 4.37M |  930 |          0 |       0 |  0 |       433 | 373.96K | 1369 | 0:02'20'' |
| Q25L100_2800000 |      17658 | 4.67M | 1176 |     18269 | 4.53M |  414 |          0 |       0 |  0 |       187 | 142.57K |  762 | 0:03'55'' |
| Q25L110_2800000 |      13140 | 4.68M | 1274 |     13938 | 4.52M |  506 |          0 |       0 |  0 |       220 | 158.84K |  768 | 0:03'45'' |
| Q25L120_2400000 |      11128 | 4.68M | 1355 |     11817 |  4.5M |  604 |          0 |       0 |  0 |       268 | 177.99K |  751 | 0:03'36'' |
| Q25L130_2000000 |       7488 | 4.69M | 1783 |      7988 | 4.41M |  830 |          0 |       0 |  0 |       478 | 284.45K |  953 | 0:02'48'' |
| Q25L140_1200000 |       3524 | 4.71M | 3163 |      4237 | 4.02M | 1227 |       1117 |   1.12K |  1 |       556 | 687.16K | 1935 | 0:01'59'' |
| Q25L150_1200000 |       3093 | 4.71M | 3401 |      3914 | 3.96M | 1270 |       1146 |   1.15K |  1 |       547 | 750.43K | 2130 | 0:01'53'' |
| Q30L100_2400000 |      10798 | 4.66M | 1399 |     11471 | 4.48M |  640 |          0 |       0 |  0 |       313 | 185.67K |  759 | 0:03'30'' |
| Q30L110_2000000 |       6894 | 4.68M | 1837 |      7359 | 4.39M |  861 |          0 |       0 |  0 |       458 | 281.16K |  976 | 0:03'18'' |
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

## Merge anchors from different groups of reads

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L100_1200000/anchor/pe.anchor.fa \
    Q20L110_1200000/anchor/pe.anchor.fa \
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
    Q20L100_1200000/anchor/pe.anchor.fa \
    Q20L110_1200000/anchor/pe.anchor.fa \
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
    1_genome/paralogs.fas \
    --label "Q20L100,Q20L110,Q20L120,Q20L130,Q20L140,Q20L150,Q25L100,Q25L110,Q25L120,Q25L130,Q25L140,Q25L150,Q30L100,Q30L110,Q30L120,merge,paralogs" \
    -o 9_qa
```

## 3GS

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

head -n 46000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.40x.fasta
faops n50 -S -C 3_pacbio/pacbio.40x.fasta

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

faops n50 -S -C 3_pacbio/pacbio.40x.fasta

faops n50 -S -C canu-raw-40x/ecoli.correctedReads.fasta.gz
faops n50 -S -C canu-raw-40x/ecoli.trimmedReads.fasta.gz

faops n50 -S -C canu-raw-all/ecoli.trimmedReads.fasta.gz

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

faops n50 -S -C anchorLong/group/*.contig.fasta

cat \
   anchorLong/group/non_grouped.fasta\
   anchorLong/group/*.contig.fasta \
   | faops filter -l 0 -a 2000 stdin anchorLong/contig.fasta

faops n50 -S -C anchorLong/contig.fasta

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

faops n50 -S -C contigTrim/group/*.contig.fasta

cat \
    contigTrim/group/non_grouped.fasta \
    contigTrim/group/*.contig.fasta \
    >  contigTrim/contig.fasta
faops n50 -S -C contigTrim/contig.fasta

```

* quast

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

rm -fr 9_qa_contig
quast --no-check --threads 24 \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/anchor.cover.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-raw-40x/ecoli.contigs.fasta \
    canu-raw-all/ecoli.contigs.fasta \
    1_genome/paralogs.fas \
    --label "merge,cover,contig,contigTrim,canu-40x,canu-all,paralogs" \
    -o 9_qa_contig

```

