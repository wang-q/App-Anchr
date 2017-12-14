# Assemble genomes of model organisms by ANCHR

[TOC levels=1-3]: # " "
- [Assemble genomes of model organisms by ANCHR](#assemble-genomes-of-model-organisms-by-anchr)
- [More tools on downloading and preprocessing data](#more-tools-on-downloading-and-preprocessing-data)
    - [Extra external executables](#extra-external-executables)
    - [Two of the leading assemblers](#two-of-the-leading-assemblers)
    - [PacBio specific tools](#pacbio-specific-tools)
- [*Escherichia coli* str. K-12 substr. MG1655](#escherichia-coli-str-k-12-substr-mg1655)
    - [e_coli: download](#e-coli-download)
    - [e_coli: template](#e-coli-template)
    - [e_coli: preprocessing](#e-coli-preprocessing)
    - [e_coli: spades](#e-coli-spades)
    - [e_coli: platanus](#e-coli-platanus)
    - [e_coli: quorum](#e-coli-quorum)
    - [e_coli: adapter filtering](#e-coli-adapter-filtering)
    - [e_coli: down sampling](#e-coli-down-sampling)
    - [e_coli: k-unitigs and anchors (sampled)](#e-coli-k-unitigs-and-anchors-sampled)
    - [e_coli: merge anchors](#e-coli-merge-anchors)
    - [e_coli: 3GS](#e-coli-3gs)
    - [e_coli: expand anchors](#e-coli-expand-anchors)
    - [e_coli: final stats](#e-coli-final-stats)
    - [e_coli: clear intermediate files](#e-coli-clear-intermediate-files)
- [*Saccharomyces cerevisiae* S288c](#saccharomyces-cerevisiae-s288c)
    - [s288c: download](#s288c-download)
    - [s288c: preprocess Illumina reads](#s288c-preprocess-illumina-reads)
    - [s288c: preprocess PacBio reads](#s288c-preprocess-pacbio-reads)
    - [s288c: reads stats](#s288c-reads-stats)
    - [s288c: spades](#s288c-spades)
    - [s288c: platanus](#s288c-platanus)
    - [s288c: quorum](#s288c-quorum)
    - [s288c: adapter filtering](#s288c-adapter-filtering)
    - [s288c: down sampling](#s288c-down-sampling)
    - [s288c: k-unitigs and anchors (sampled)](#s288c-k-unitigs-and-anchors-sampled)
    - [s288c: merge anchors](#s288c-merge-anchors)
    - [s288c: 3GS](#s288c-3gs)
    - [s288c: expand anchors](#s288c-expand-anchors)
    - [s288c: final stats](#s288c-final-stats)
    - [s288c: clear intermediate files](#s288c-clear-intermediate-files)
- [*Drosophila melanogaster* iso-1](#drosophila-melanogaster-iso-1)
    - [iso_1: download](#iso-1-download)
    - [iso_1: preprocess Illumina reads](#iso-1-preprocess-illumina-reads)
    - [iso_1: preprocess PacBio reads](#iso-1-preprocess-pacbio-reads)
    - [iso_1: reads stats](#iso-1-reads-stats)
    - [iso_1: spades](#iso-1-spades)
    - [iso_1: platanus](#iso-1-platanus)
    - [iso_1: quorum](#iso-1-quorum)
    - [iso_1: down sampling](#iso-1-down-sampling)
    - [iso_1: k-unitigs and anchors (sampled)](#iso-1-k-unitigs-and-anchors-sampled)
    - [iso_1: merge anchors](#iso-1-merge-anchors)
    - [iso_1: 3GS](#iso-1-3gs)
    - [iso_1: expand anchors](#iso-1-expand-anchors)
    - [iso_1: final stats](#iso-1-final-stats)
    - [iso_1: clear intermediate files](#iso-1-clear-intermediate-files)
- [*Caenorhabditis elegans* N2](#caenorhabditis-elegans-n2)
    - [n2: download](#n2-download)
    - [n2: preprocess Illumina reads](#n2-preprocess-illumina-reads)
    - [n2: preprocess PacBio reads](#n2-preprocess-pacbio-reads)
    - [n2: reads stats](#n2-reads-stats)
    - [n2: spades](#n2-spades)
    - [n2: platanus](#n2-platanus)
    - [n2: quorum](#n2-quorum)
    - [n2: adapter filtering](#n2-adapter-filtering)
    - [n2: down sampling](#n2-down-sampling)
    - [n2: k-unitigs and anchors (sampled)](#n2-k-unitigs-and-anchors-sampled)
    - [n2: merge anchors](#n2-merge-anchors)
    - [n2: 3GS](#n2-3gs)
    - [n2: expand anchors](#n2-expand-anchors)
    - [n2: final stats](#n2-final-stats)
    - [n2: clear intermediate files](#n2-clear-intermediate-files)
- [*Arabidopsis thaliana* Col-0](#arabidopsis-thaliana-col-0)
    - [col_0: download](#col-0-download)
    - [col_0: preprocess Illumina reads](#col-0-preprocess-illumina-reads)
    - [col_0: preprocess PacBio reads](#col-0-preprocess-pacbio-reads)
    - [col_0: reads stats](#col-0-reads-stats)
    - [col_0: spades](#col-0-spades)
    - [col_0: platanus](#col-0-platanus)
    - [col_0: quorum](#col-0-quorum)
    - [col_0: down sampling](#col-0-down-sampling)
    - [col_0: k-unitigs and anchors (sampled)](#col-0-k-unitigs-and-anchors-sampled)
    - [col_0: merge anchors](#col-0-merge-anchors)
    - [col_0: 3GS](#col-0-3gs)
    - [col_0: expand anchors](#col-0-expand-anchors)
    - [col_0: final stats](#col-0-final-stats)
    - [col_0: clear intermediate files](#col-0-clear-intermediate-files)


# More tools on downloading and preprocessing data

## Extra external executables

```bash
brew install aria2 curl                     # downloading tools

brew install homebrew/science/sratoolkit    # NCBI SRAToolkit

brew reinstall --build-from-source --without-webp gd # broken, can't find libwebp.so.6
brew reinstall --build-from-source gnuplot@4
brew install homebrew/science/mummer        # mummer need gnuplot4

brew install openblas                       # numpy

brew install python
brew install homebrew/science/quast         # assembly quality assessment
quast --test                                # may recompile the bundled nucmer

# canu requires gnuplot 5 while mummer requires gnuplot 4
brew install --build-from-source canu

brew unlink gnuplot@4
brew install gnuplot
brew unlink gnuplot

brew link gnuplot@4 --force

brew install r
brew install kmergenie --with-maxkmer=200

brew install homebrew/science/kmc --HEAD
```

## Two of the leading assemblers

```bash
brew install homebrew/science/spades
brew install wang-q/tap/platanus

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
* Taxonomy ID: [511145](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=511145)
* Proportion of paralogs (> 1000 bp): 0.0323

## e_coli: download

* Settings

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=e_coli
REAL_G=4641652
IS_EUK="false"
TRIM2="--uniq --shuffle --scythe "
SAMPLE2=
COVERAGE2="40 80"
READ_QUAL="25 30"
READ_LEN="60"
COVERAGE3="40 80"
EXPAND_WITH="80"

```

* Reference genome

```bash
mkdir -p ${WORKING_DIR}/${BASE_NAME}/1_genome
cd ${WORKING_DIR}/${BASE_NAME}/1_genome

curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=U00096.3&rettype=fasta&retmode=txt" \
    > U00096.fa
# simplify header, remove .3
cat U00096.fa \
    | perl -nl -e '
        /^>(\w+)/ and print qq{>$1} and next;
        print;
    ' \
    > genome.fa

cp ${WORKING_DIR}/paralogs/model/Results/e_coli/e_coli.multi.fas paralogs.fas
```

* Illumina

```bash
mkdir -p ${WORKING_DIR}/${BASE_NAME}/2_illumina
cd ${WORKING_DIR}/${BASE_NAME}/2_illumina

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
mkdir -p ${WORKING_DIR}/${BASE_NAME}/3_pacbio
cd ${WORKING_DIR}/${BASE_NAME}/3_pacbio

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
cat fasta/m141013.fasta \
    | faops dazz -l 0 -p long stdin pacbio.fasta

```

## e_coli: template

```bash
cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename e_coli \
    --genome 4641652 \
    --trim2 "--uniq --shuffle --scythe " \
    --coverage2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --coverage3 "40 80" \
    --parallel 16

```

## e_coli: preprocessing

```bash
cd ${WORKING_DIR}/${BASE_NAME}

# Illumina QC
bash 2_fastqc.sh
bash 2_kmergenie.sh

# preprocess Illumina reads
bash 2_trim.sh

# preprocess PacBio reads
bash 3_trimlong.sh

# reads stats
bash 23_statReads.sh

```

| Name     |     N50 |     Sum |        # |
|:---------|--------:|--------:|---------:|
| Genome   | 4641652 | 4641652 |        1 |
| Paralogs |    1934 |  195673 |      106 |
| Illumina |     151 |   1.73G | 11458940 |
| uniq     |     151 |   1.73G | 11439000 |
| shuffle  |     151 |   1.73G | 11439000 |
| scythe   |     151 |   1.72G | 11439000 |
| Q25L60   |     151 |   1.32G |  9994656 |
| Q30L60   |     127 |   1.15G |  9783226 |
| PacBio   |   13982 | 748.51M |    87225 |
| X40.raw  |   14030 | 185.68M |    22336 |
| X40.trim |   13702 | 169.38M |    19468 |
| X80.raw  |   13990 | 371.34M |    44005 |
| X80.trim |   13632 | 339.51M |    38725 |

## e_coli: spades

```bash
cd ${WORKING_DIR}/${BASE_NAME}

spades.py \
    -t 16 \
    -k 21,33,55,77 \
    --only-assembler \
    -1 2_illumina/Q25L60/R1.sickle.fq.gz \
    -2 2_illumina/Q25L60/R2.sickle.fq.gz \
    -s 2_illumina/Q25L60/Rs.sickle.fq.gz \
    -o 8_spades

anchr contained \
    8_spades/contigs.fasta \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin 8_spades/contigs.non-contained.fasta

```

## e_coli: platanus

```bash
cd ${WORKING_DIR}/${BASE_NAME}

mkdir -p 8_platanus
cd 8_platanus

if [ ! -e pe.fa ]; then
    faops interleave \
        -p pe \
        ../2_illumina/Q25L60/R1.sickle.fq.gz \
        ../2_illumina/Q25L60/R2.sickle.fq.gz \
        > pe.fa
    
    faops interleave \
        -p se \
        ../2_illumina/Q25L60/Rs.sickle.fq.gz \
        > se.fa
fi

platanus assemble -t 16 -m 100 \
    -f pe.fa se.fa \
    2>&1 | tee ass_log.txt

platanus scaffold -t 16 \
    -c out_contig.fa -b out_contigBubble.fa \
    -ip1 pe.fa \
    2>&1 | tee sca_log.txt

platanus gap_close -t 16 \
    -c out_scaffold.fa \
    -ip1 pe.fa \
    2>&1 | tee gap_log.txt

anchr contained \
    out_gapClosed.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin gapClosed.non-contained.fasta

```

## e_coli: quorum

```bash
cd ${WORKING_DIR}/${BASE_NAME}

parallel --no-run-if-empty --linebuffer -k -j 1 "
    cd 2_illumina/Q{1}L{2}
    echo >&2 '==> Group Q{1}L{2} <=='

    if [ ! -e R1.sickle.fq.gz ]; then
        echo >&2 '    R1.sickle.fq.gz not exists'
        exit;
    fi

    if [ -e pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa exists'
        exit;
    fi

    if [[ {1} -ge '30' ]]; then
        anchr quorum \
            R1.sickle.fq.gz R2.sickle.fq.gz Rs.sickle.fq.gz \
            -p 16 \
            -o quorum.sh
    else
        anchr quorum \
            R1.sickle.fq.gz R2.sickle.fq.gz \
            -p 16 \
            -o quorum.sh
    fi

    bash quorum.sh
    
    echo >&2
    " ::: ${READ_QUAL} ::: ${READ_LEN}

# Stats of processed reads
bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > stat1.md

parallel --no-run-if-empty -k -j 3 "
    if [ ! -d 2_illumina/Q{1}L{2} ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 2_illumina/Q{1}L{2} ${REAL_G}
    " ::: ${READ_QUAL} ::: ${READ_LEN} \
     >> stat1.md

cat stat1.md

```

| Name   | SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|------:|-------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 1.32G | 283.9 |  1.24G |  267.4 |   5.801% |     133 | "83" | 4.64M | 4.58M |     0.99 | 0:03'47'' |
| Q30L60 | 1.15G | 247.7 |  1.12G |  241.6 |   2.484% |     120 | "71" | 4.64M | 4.56M |     0.98 | 0:03'12'' |

## e_coli: adapter filtering

```bash
cd ${WORKING_DIR}/${BASE_NAME}

for QxxLxx in $( parallel "echo 'Q{1}L{2}'" ::: ${READ_QUAL} ::: ${READ_LEN} ); do
    echo "==> ${QxxLxx}"

    if [ -e 2_illumina/${QxxLxx}/filtering.stats.txt ]; then
        echo "2_illumina/${QxxLxx}/filtering.stats.txt already exists"
        continue;
    fi

    if [ ! -e 2_illumina/${QxxLxx}/pe.cor.fa ]; then
        echo "2_illumina/${QxxLxx}/pe.cor.fa not exists"
        continue;
    fi
    
    mv 2_illumina/${QxxLxx}/pe.cor.fa 2_illumina/${QxxLxx}/pe.cor.raw

    bbduk.sh \
        in=2_illumina/${QxxLxx}/pe.cor.raw \
        out=2_illumina/${QxxLxx}/pe.cor.fa \
        outm=2_illumina/${QxxLxx}/matched.fa \
        ref=$(brew --prefix)/Cellar/$(brew list --versions bbtools | sed 's/ /\//')/resources/adapters.fa \
        k=27 hdist=1 stats=2_illumina/${QxxLxx}/filtering.stats.txt

    rm 2_illumina/${QxxLxx}/pe.cor.raw
done

```

## e_coli: down sampling

```bash
cd ${WORKING_DIR}/${BASE_NAME}

for QxxLxx in $( parallel "echo 'Q{1}L{2}'" ::: ${READ_QUAL} ::: ${READ_LEN} ); do
    echo "==> ${QxxLxx}"

    if [ ! -e 2_illumina/${QxxLxx}/pe.cor.fa ]; then
        echo "2_illumina/${QxxLxx}/pe.cor.fa not exists"
        continue;
    fi

    for X in ${COVERAGE2}; do
        printf "==> Coverage: %s\n" ${X}
        
        rm -fr 2_illumina/${QxxLxx}X${X}*
    
        faops split-about -l 0 \
            2_illumina/${QxxLxx}/pe.cor.fa \
            $(( ${REAL_G} * ${X} )) \
            "2_illumina/${QxxLxx}X${X}"
        
        MAX_SERIAL=$(
            cat 2_illumina/${QxxLxx}/environment.json \
                | jq ".SUM_OUT | tonumber | . / ${REAL_G} / ${X} | floor | . - 1"
        )
        
        for i in $( seq 0 1 ${MAX_SERIAL} ); do
            P=$( printf "%03d" ${i})
            printf "  * Part: %s\n" ${P}
            
            mkdir -p "2_illumina/${QxxLxx}X${X}P${P}"
            
            mv  "2_illumina/${QxxLxx}X${X}/${P}.fa" \
                "2_illumina/${QxxLxx}X${X}P${P}/pe.cor.fa"
            cp 2_illumina/${QxxLxx}/environment.json "2_illumina/${QxxLxx}X${X}P${P}"
    
        done
    done
done

```

## e_coli: k-unitigs and anchors (sampled)

```bash
cd ${WORKING_DIR}/${BASE_NAME}

# k-unitigs
parallel --no-run-if-empty --linebuffer -k -j 2 "
    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'

    if [ ! -e 2_illumina/Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        echo >&2 '    2_illumina/Q{1}L{2}X{3}P{4}/pe.cor.fa not exists'
        exit;
    fi

    if [ -e Q{1}L{2}X{3}P{4}/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi

    mkdir -p Q{1}L{2}X{3}P{4}
    cd Q{1}L{2}X{3}P{4}

    anchr kunitigs \
        ../2_illumina/Q{1}L{2}X{3}P{4}/pe.cor.fa \
        ../2_illumina/Q{1}L{2}X{3}P{4}/environment.json \
        -p 16 \
        --kmer 31,41,51,61,71,81 \
        -o kunitigs.sh
    bash kunitigs.sh

    echo >&2
    " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})

# anchors
parallel --no-run-if-empty --linebuffer -k -j 3 "
    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'

    if [ ! -e Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa not exists'
        exit;
    fi

    if [ -e Q{1}L{2}X{3}P{4}/anchor/anchor.fasta ]; then
        echo >&2 '    anchor.fasta already presents'
        exit;
    fi

    rm -fr Q{1}L{2}X{3}P{4}/anchor
    mkdir -p Q{1}L{2}X{3}P{4}/anchor
    cd Q{1}L{2}X{3}P{4}/anchor
    
    anchr anchors \
        ../k_unitigs.fasta \
        ../pe.cor.fa \
        -p 8 \
        -o anchors.sh
    bash anchors.sh

    echo >&2
    " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})

# Stats of anchors
bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > stat2.md

parallel --no-run-if-empty -k -j 6 "
    if [ ! -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 Q{1}L{2}X{3}P{4} ${REAL_G}
    " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100}) \
    >> stat2.md

cat stat2.md
```

| Name          | SumCor | CovCor | N50Anchor |    Sum | # | N50Others | Sum | # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|-------:|----------:|-------:|--:|----------:|----:|--:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 |  1.94M |   40.0 |     48509 | 48.51K | 1 |         0 |   0 | 0 |   40.5 | 1.5 |  12.0 |  67.5 | "31,41,51,61,71,81" | 0:00'11'' | 0:00'37'' |
| Q25L60X40P001 |  1.94M |   40.0 |     48294 | 48.29K | 1 |         0 |   0 | 0 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'12'' | 0:00'36'' |
| Q25L60X40P002 |  1.94M |   40.0 |     48460 | 48.46K | 1 |         0 |   0 | 0 |   40.0 | 0.0 |  13.3 |  60.0 | "31,41,51,61,71,81" | 0:00'11'' | 0:00'37'' |
| Q25L60X80P000 |  3.88M |   80.0 |     48512 | 48.51K | 1 |         0 |   0 | 0 |   81.0 | 0.0 |  27.0 | 121.5 | "31,41,51,61,71,81" | 0:00'12'' | 0:00'38'' |
| Q30L60X40P000 |  1.94M |   40.0 |     48509 | 48.51K | 1 |         0 |   0 | 0 |   40.5 | 2.5 |  11.0 |  72.0 | "31,41,51,61,71,81" | 0:00'12'' | 0:00'39'' |
| Q30L60X40P001 |  1.94M |   40.0 |     48396 |  48.4K | 1 |         0 |   0 | 0 |   40.5 | 2.0 |  11.5 |  69.8 | "31,41,51,61,71,81" | 0:00'11'' | 0:00'37'' |
| Q30L60X40P002 |  1.94M |   40.0 |     48491 | 48.49K | 1 |         0 |   0 | 0 |   38.5 | 2.5 |  10.3 |  69.0 | "31,41,51,61,71,81" | 0:00'10'' | 0:00'21'' |
| Q30L60X80P000 |  3.88M |   80.0 |     48512 | 48.51K | 1 |         0 |   0 | 0 |   80.0 | 2.0 |  24.7 | 129.0 | "31,41,51,61,71,81" | 0:00'11'' | 0:00'23'' |

## e_coli: merge anchors

```bash
cd ${WORKING_DIR}/${BASE_NAME}

# merge anchors
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/anchor.fasta ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/anchor.fasta
            fi
            " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.non-contained.fasta
anchr orient merge/anchor.non-contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o merge/anchor.merge0.fasta
anchr contained merge/anchor.merge0.fasta --len 1000 --idt 0.98 \
    --proportion 0.99 --parallel 16 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.others.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.others.fa
            fi
            " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})
    ) \
    --len 500 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 500 -l 0 stdin merge/others.non-contained.fasta

# anchor sort on ref
bash ~/Scripts/cpan/App-Anchr/share/sort_on_ref.sh merge/anchor.merge.fasta 1_genome/genome.fa merge/anchor.sort
nucmer -l 200 1_genome/genome.fa merge/anchor.sort.fa
mummerplot out.delta --png --large -p anchor.sort

# mummerplot files
rm *.[fr]plot
rm out.delta
rm *.gp
mv anchor.sort.png merge/

# minidot
minimap merge/anchor.sort.fa 1_genome/genome.fa \
    | minidot - > merge/anchor.minidot.eps

# quast
rm -fr 9_qa
quast --no-check --threads 16 \
    $(
        if [ "${IS_EUK}" = "true" ]; then
            echo "--eukaryote --no-icarus"
        fi
    ) \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/others.non-contained.fasta \
    1_genome/paralogs.fas \
    --label "merge,others,paralogs" \
    -o 9_qa

```

## e_coli: 3GS

```bash
cd ${WORKING_DIR}/${BASE_NAME}

parallel --no-run-if-empty --linebuffer -k -j 1 "
    echo >&2 '==> Group X{1}-{2}'

    if [ ! -e  3_pacbio/pacbio.X{1}.{2}.fasta ]; then
        echo >&2 '    3_pacbio/pacbio.X{1}.{2}.fasta not exists'
        exit;
    fi

    if [ -e canu-X{1}-{2}/*.contigs.fasta ]; then
        echo >&2 '    contigs.fasta already presents'
        exit;
    fi

    canu \
        -p ${BASE_NAME} -d canu-X{1}-{2} \
        gnuplot=\$(brew --prefix)/Cellar/\$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
        genomeSize=${REAL_G} \
        -pacbio-raw 3_pacbio/pacbio.X{1}.{2}.fasta
    " ::: ${COVERAGE3} ::: raw trim

# canu
printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat3GS.md
printf "|:--|--:|--:|--:|\n" >> stat3GS.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat3GS.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Paralogs"; faops n50 -H -S -C 1_genome/paralogs.fas;) >> stat3GS.md

parallel --no-run-if-empty -k -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo X{1}.{2}.corrected;
            faops n50 -H -S -C \
                canu-X{1}-{2}/${BASE_NAME}.correctedReads.fasta.gz;
        )
    " ::: ${COVERAGE3} ::: raw trim \
    >> stat3GS.md

parallel --no-run-if-empty -k -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo X{1}.{2};
            faops n50 -H -S -C \
                canu-X{1}-{2}/${BASE_NAME}.contigs.fasta;
        )
    " ::: ${COVERAGE3} ::: raw trim \
    >> stat3GS.md

cat stat3GS.md

# minidot
minimap canu-X40-raw/${BASE_NAME}.contigs.fasta 1_genome/genome.fa \
    | minidot - > canu-X40-raw/minidot.eps

minimap canu-X40-trim/${BASE_NAME}.contigs.fasta 1_genome/genome.fa \
    | minidot - > canu-X40-trim/minidot.eps

```

| Name               |     N50 |       Sum |     # |
|:-------------------|--------:|----------:|------:|
| Genome             | 4641652 |   4641652 |     1 |
| Paralogs           |    1934 |    195673 |   106 |
| X40.raw.corrected  |   13465 | 150999437 | 17096 |
| X40.trim.corrected |   13372 | 148630560 | 16928 |
| X80.raw.corrected  |   16977 | 174462103 | 10692 |
| X80.trim.corrected |   16820 | 175594582 | 10873 |
| X40.raw            | 4674150 |   4674150 |     1 |
| X40.trim           | 4674046 |   4674046 |     1 |
| X80.raw            | 4658166 |   4658166 |     1 |
| X80.trim           | 4657933 |   4657933 |     1 |

## e_coli: expand anchors

三代 reads 里有一个常见的错误, 即单一 ZMW 里的测序结果中, 接头序列部分的测序结果出现了较多的错误,
因此并没有将接头序列去除干净, 形成的 subreads 里含有多份基因组上同一片段, 它们之间以接头序列为间隔.

`anchr group` 命令默认会将这种三代的 reads 去除. `--keep` 选项会留下这种 reads, 这适用于组装好的三代序列.

```text
      ===
------------>
             )
  <----------
      ===
```

* anchorLong

```bash
cd ${WORKING_DIR}/${BASE_NAME}

rm -fr anchorLong
anchr overlap2 \
    --parallel 16 \
    merge/anchor.merge.fasta \
    canu-X${EXPAND_WITH}-trim/${BASE_NAME}.correctedReads.fasta.gz \
    -d anchorLong \
    -b 50 --len 1000 --idt 0.98 --all

pushd anchorLong

anchr cover \
    --range "1-$(faops n50 -H -N 0 -C anchor.fasta)" \
    --len 1000 --idt 0.98 -c 2 \
    anchorLong.ovlp.tsv \
    -o anchor.cover.json
cat anchor.cover.json | jq "." > environment.json

anchr overlap \
    anchor.fasta \
    --serial --len 30 --idt 0.9999 \
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
    > anchor.ovlp.tsv

rm -fr group
anchr group \
    anchorLong.db \
    anchorLong.ovlp.tsv \
    --oa anchor.ovlp.tsv \
    --parallel 16 \
    --range $(cat environment.json | jq -r '.TRUSTED') \
    --len 1000 --idt 0.98 --max "-30" -c 2

cat group/groups.txt \
    | parallel --no-run-if-empty --linebuffer -k -j 8 '
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

        anchr overlap --len 30 --idt 0.9999 \
            group/{}.strand.fasta \
            -o stdout \
            | perl -nla -e '\''
                @F == 13 or next;
                $F[3] > 0.9999 or next;
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
            -o group/{}.contig.fasta
    '
popd

# false strand
cat anchorLong/group/*.ovlp.tsv \
    | perl -nla -e '/anchor.+long/ or next; print $F[0] if $F[8] == 1;' \
    | sort | uniq -c

cat \
   anchorLong/group/non_grouped.fasta \
   anchorLong/group/*.contig.fasta \
   | faops filter -l 0 -a 1000 stdin anchorLong/contig.fasta

```

* contigTrim

```bash
cd ${WORKING_DIR}/${BASE_NAME}

rm -fr contigTrim
anchr overlap2 \
    --parallel 16 \
    anchorLong/contig.fasta \
    canu-X${EXPAND_WITH}-trim/${BASE_NAME}.contigs.fasta \
    -d contigTrim \
    -b 50 --len 1000 --idt 0.995 --all

CONTIG_COUNT=$(faops n50 -H -N 0 -C contigTrim/anchor.fasta)
echo ${CONTIG_COUNT}

rm -fr contigTrim/group
anchr group \
    --parallel 16 \
    --keep \
    contigTrim/anchorLong.db \
    contigTrim/anchorLong.ovlp.tsv \
    --range "1-${CONTIG_COUNT}" --len 1000 --idt 0.995 --max 5000 -c 1

pushd contigTrim
cat group/groups.txt \
    | parallel --no-run-if-empty --linebuffer -k -j 8 '
        echo {};
        anchr orient \
            --len 1000 --idt 0.995 \
            group/{}.anchor.fasta \
            group/{}.long.fasta \
            -r group/{}.restrict.tsv \
            -o group/{}.strand.fasta;

        anchr overlap --len 1000 --idt 0.995 --all \
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

cat \
    contigTrim/group/non_grouped.fasta \
    contigTrim/group/*.contig.fasta \
    >  contigTrim/contig.fasta

```

## e_coli: final stats

* Stats

```bash
cd ${WORKING_DIR}/${BASE_NAME}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat3.md
printf "|:--|--:|--:|--:|\n" >> stat3.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Paralogs"; faops n50 -H -S -C 1_genome/paralogs.fas;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "anchor";   faops n50 -H -S -C merge/anchor.merge.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "others";   faops n50 -H -S -C merge/others.non-contained.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "anchorLong"; faops n50 -H -S -C anchorLong/contig.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "contigTrim"; faops n50 -H -S -C contigTrim/contig.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "canu-X${EXPAND_WITH}-raw"; faops n50 -H -S -C canu-X${EXPAND_WITH}-raw/${BASE_NAME}.contigs.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "canu-X${EXPAND_WITH}-trim"; faops n50 -H -S -C canu-X${EXPAND_WITH}-trim/${BASE_NAME}.contigs.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "spades.contig"; faops n50 -H -S -C 8_spades/contigs.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "spades.scaffold"; faops n50 -H -S -C 8_spades/scaffolds.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "spades.non-contained"; faops n50 -H -S -C 8_spades/contigs.non-contained.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "platanus.contig"; faops n50 -H -S -C 8_platanus/out_contig.fa;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "platanus.scaffold"; faops n50 -H -S -C 8_platanus/out_gapClosed.fa;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "platanus.non-contained"; faops n50 -H -S -C 8_platanus/gapClosed.non-contained.fasta;) >> stat3.md

cat stat3.md

```

| Name                   |     N50 |     Sum |    # |
|:-----------------------|--------:|--------:|-----:|
| Genome                 | 4641652 | 4641652 |    1 |
| Paralogs               |    1934 |  195673 |  106 |
| anchor                 |   63501 | 4534356 |  120 |
| others                 |     941 |  122752 |  129 |
| anchorLong             |   82828 | 4532095 |  102 |
| contigTrim             | 1047591 | 4604252 |    9 |
| canu-X80-raw           | 4658166 | 4658166 |    1 |
| canu-X80-trim          | 4657933 | 4657933 |    1 |
| spades.contig          |  133059 | 4588342 |  169 |
| spades.scaffold        |  148513 | 4588382 |  165 |
| spades.non-contained   |  133059 | 4563262 |   74 |
| platanus.contig        |   15090 | 4683012 | 1069 |
| platanus.scaffold      |  133014 | 4575941 |  137 |
| platanus.non-contained |  133014 | 4559275 |   63 |

* quast

```bash
cd ${WORKING_DIR}/${BASE_NAME}

QUAST_TARGET=
QUAST_LABEL=

if [ -e 1_genome/genome.fa ]; then
    QUAST_TARGET+=" -R 1_genome/genome.fa "
fi
if [ -e merge/anchor.merge.fasta ]; then
    QUAST_TARGET+=" merge/anchor.merge.fasta "
    QUAST_LABEL+="merge,"
fi
if [ -e anchorLong/contig.fasta ]; then
    QUAST_TARGET+=" anchorLong/contig.fasta "
    QUAST_LABEL+="anchorLong,"
fi
if [ -e contigTrim/contig.fasta ]; then
    QUAST_TARGET+=" contigTrim/contig.fasta "
    QUAST_LABEL+="contigTrim,"
fi
if [ -e canu-X${EXPAND_WITH}-raw/${BASE_NAME}.contigs.fasta ]; then
    QUAST_TARGET+=" canu-X${EXPAND_WITH}-raw/${BASE_NAME}.contigs.fasta "
    QUAST_LABEL+="canu-X${EXPAND_WITH}-raw,"
fi
if [ -e canu-X${EXPAND_WITH}-trim/${BASE_NAME}.contigs.fasta ]; then
    QUAST_TARGET+=" canu-X${EXPAND_WITH}-trim/${BASE_NAME}.contigs.fasta "
    QUAST_LABEL+="canu-X${EXPAND_WITH}-trim,"
fi
if [ -e 8_spades/contigs.non-contained.fasta ]; then
    QUAST_TARGET+=" 8_spades/contigs.non-contained.fasta "
    QUAST_LABEL+="spades,"
fi
if [ -e 8_platanus/gapClosed.non-contained.fasta ]; then
    QUAST_TARGET+=" 8_platanus/gapClosed.non-contained.fasta "
    QUAST_LABEL+="platanus,"
fi
if [ -e 1_genome/paralogs.fas ]; then
    QUAST_TARGET+=" 1_genome/paralogs.fas "
    QUAST_LABEL+="paralogs,"
fi

QUAST_LABEL=$( echo "${QUAST_LABEL}" | sed 's/,$//' )

rm -fr 9_qa_contig
quast --no-check --threads 16 \
    $(
        if [ "${IS_EUK}" = "true" ]; then
            echo "--eukaryote --no-icarus"
        fi
    ) \
    ${QUAST_TARGET} \
    --label ${QUAST_LABEL} \
    -o 9_qa_contig

```

## e_coli: clear intermediate files

```bash
cd ${WORKING_DIR}/${BASE_NAME}

# bax2bam
rm -fr 3_pacbio/bam/*
rm -fr 3_pacbio/fasta/*
rm -fr 3_pacbio/untar/*

# quorum
find 2_illumina -type f -name "quorum_mer_db.jf" | xargs rm
find 2_illumina -type f -name "k_u_hash_0"       | xargs rm
find 2_illumina -type f -name "*.tmp"            | xargs rm
find 2_illumina -type f -name "pe.renamed.fastq" | xargs rm
find 2_illumina -type f -name "se.renamed.fastq" | xargs rm
find 2_illumina -type f -name "pe.cor.sub.fa"    | xargs rm

# down sampling
rm -fr 2_illumina/Q{15,20,25,30,35}L{30,60,90,120}X*
rm -fr Q{15,20,25,30,35}L{30,60,90,120}X*

rm -fr mergeQ*
rm -fr mergeL*

# canu
find . -type d -name "correction" -path "*canu-*" | xargs rm -fr
find . -type d -name "trimming"   -path "*canu-*" | xargs rm -fr
find . -type d -name "unitigging" -path "*canu-*" | xargs rm -fr

# spades
find . -type d -path "*8_spades/*" | xargs rm -fr

# platanus
find . -type f -path "*8_platanus/*" -name "[ps]e.fa" | xargs rm

```

# *Saccharomyces cerevisiae* S288c

* Genome: [Ensembl 82](http://sep2015.archive.ensembl.org/Saccharomyces_cerevisiae/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.058

## s288c: download

* Settings

```bash
BASE_NAME=s288c
REAL_G=12157105
IS_EUK="true"
COVERAGE2="40 80"
COVERAGE3="40 80"
READ_QUAL="25 30"
READ_LEN="60"
EXPAND_WITH="40"

```

* Reference genome

```bash
BASE_NAME=s288c
mkdir -p ${HOME}/data/anchr/${BASE_NAME}
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 1_genome
cd 1_genome

wget -N ftp://ftp.ensembl.org/pub/release-82/fasta/saccharomyces_cerevisiae/dna/Saccharomyces_cerevisiae.R64-1-1.dna_sm.toplevel.fa.gz
faops order Saccharomyces_cerevisiae.R64-1-1.dna_sm.toplevel.fa.gz \
    <(for chr in {I,II,III,IV,V,VI,VII,VIII,IX,X,XI,XII,XIII,XIV,XV,XVI,Mito}; do echo $chr; done) \
    genome.fa

cp ~/data/anchr/paralogs/model/Results/${BASE_NAME}/${BASE_NAME}.multi.fas 1_genome/paralogs.fas
```

* Illumina

    PRJNA340312, SRX2058864

```bash
BASE_NAME=s288c
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina
cd 2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR407/005/SRR4074255/SRR4074255_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR407/005/SRR4074255/SRR4074255_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
7ba93499d73cdaeaf50dd506e2c8572d SRR4074255_1.fastq.gz
aee9ec3f855796b6d30a3d191fc22345 SRR4074255_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s SRR522246_1.fastq.gz R1.fq.gz
ln -s SRR522246_2.fastq.gz R2.fq.gz
```

* PacBio

    PacBio provides a dataset of *S. cerevisiae* strain
    [W303](https://github.com/PacificBiosciences/DevNet/wiki/Saccharomyces-cerevisiae-W303-Assembly-Contigs),
    while the reference strain S288c is not provided. So we use the dataset from
    [project PRJEB7245](https://www.ncbi.nlm.nih.gov/bioproject/PRJEB7245),
    [study ERP006949](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=ERP006949), and
    [sample SAMEA4461732](https://www.ncbi.nlm.nih.gov/biosample/SAMEA4461732). They're gathered
    with RS II and P6C4.

```bash
mkdir -p ~/data/anchr/s288c/3_pacbio
cd ~/data/anchr/s288c/3_pacbio

# download from sra
cat <<EOF > hdf5.txt
http://sra-download.ncbi.nlm.nih.gov/srapub_files/ERR1655118_ERR1655118_hdf5.tgz
EOF

aria2c -x 9 -s 3 -c -i hdf5.txt

# untar
mkdir -p ~/data/anchr/s288c/3_pacbio/untar
cd ~/data/anchr/s288c/3_pacbio
tar xvfz ERR1655118_ERR1655118_hdf5.tgz --directory untar

# convert .bax.h5 to .subreads.bam
mkdir -p ~/data/anchr/s288c/3_pacbio/bam
cd ~/data/anchr/s288c/3_pacbio/bam

source ~/share/pitchfork/deployment/setup-env.sh
for movie in m150412;
do 
    bax2bam ~/data/anchr/s288c/3_pacbio/untar/${movie}*.bax.h5
done

# convert .subreads.bam to fasta
mkdir -p ~/data/anchr/s288c/3_pacbio/fasta

for movie in m150412;
do
    if [ ! -e ~/data/anchr/s288c/3_pacbio/bam/${movie}*.subreads.bam ]; then
        continue
    fi

    samtools fasta \
        ~/data/anchr/s288c/3_pacbio/bam/${movie}*.subreads.bam \
        > ~/data/anchr/s288c/3_pacbio/fasta/${movie}.fasta
done

cd ~/data/anchr/s288c
cat 3_pacbio/fasta/*.fasta \
    | faops dazz -l 0 -p long stdin 3_pacbio/pacbio.fasta

```

* FastQC

* kmergenie

## s288c: preprocess Illumina reads

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

cd 2_illumina

anchr trim \
    --uniq \
    --nosickle \
    R1.fq.gz R2.fq.gz \
    -o trim.sh
bash trim.sh

parallel --no-run-if-empty --linebuffer -k -j 3 "
    mkdir -p Q{1}L{2}
    cd Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        -q {1} -l {2} \
        \$(
            if [ -e ../R1.scythe.fq.gz ]; then
                echo '../R1.scythe.fq.gz ../R2.scythe.fq.gz'
            elif [ -e ../R1.sample.fq.gz ]; then
                echo '../R1.sample.fq.gz ../R2.sample.fq.gz'
            elif [ -e ../R1.shuffle.fq.gz ]; then
                echo '../R1.shuffle.fq.gz ../R2.shuffle.fq.gz'
            elif [ -e ../R1.uniq.fq.gz ]; then
                echo '../R1.uniq.fq.gz ../R2.uniq.fq.gz'
            else
                echo '../R1.fq.gz ../R2.fq.gz'
            fi
        ) \
         \
        -o stdout \
        | bash
    " ::: ${READ_QUAL} ::: ${READ_LEN}

```

## s288c: preprocess PacBio reads

## s288c: reads stats

| Name     |    N50 |        Sum |        # |
|:---------|-------:|-----------:|---------:|
| Genome   | 924431 |   12157105 |       17 |
| Paralogs |   3851 |    1059148 |      366 |
| Illumina |    151 | 2939081214 | 19464114 |
| uniq     |    151 | 2778772064 | 18402464 |
| Q25L60   |    151 | 2502621682 | 16817924 |
| Q30L60   |    151 | 2442383221 | 16630313 |
| PacBio   |   8412 |  820962526 |   177100 |
| X40.raw  |   8344 |  486285507 |   108074 |
| X40.trim |   7743 |  373850168 |    64169 |
| X80.raw  |   8412 |  820962526 |   177100 |
| X80.trim |   7829 |  626413879 |   106381 |

## s288c: spades

## s288c: platanus

## s288c: quorum

| Name   | SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead |  Kmer |  RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|------:|-------:|-------:|---------:|--------:|------:|-------:|-------:|---------:|----------:|
| Q25L60 |  2.5G | 205.9 |   2.2G |  181.2 |  11.967% |     149 | "105" | 12.16M | 12.16M |     1.00 | 0:07'55'' |
| Q30L60 | 2.44G | 201.0 |  2.18G |  179.5 |  10.664% |     148 | "105" | 12.16M | 12.06M |     0.99 | 0:07'41'' |

## s288c: adapter filtering

```text
#File	2_illumina/Q25L60/pe.cor.raw
#Total	14763763
#Matched	56909	0.38546%
#Name	Reads	ReadsPct
I5_Nextera_Transposase_1	31974	0.21657%
I7_Nextera_Transposase_1	24866	0.16843%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N712	49	0.00033%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]507	20	0.00014%
```

## s288c: down sampling

## s288c: k-unitigs and anchors (sampled)

| Name          |  SumCor | CovCor | N50Anchor |    Sum |    # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|--------:|-------:|----------:|-------:|-----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 | 486.28M |   40.0 |     12071 |   9.8M | 1403 |      1013 | 502.32K | 513 |   34.0 | 4.0 |   7.3 |  68.0 | "31,41,51,61,71,81" | 0:05'51'' | 0:01'44'' |
| Q25L60X40P001 | 486.28M |   40.0 |     12488 | 10.06M | 1415 |       995 |  452.8K | 483 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:05'52'' | 0:01'48'' |
| Q25L60X40P002 | 486.28M |   40.0 |     13165 | 10.17M | 1356 |       993 |  437.3K | 453 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:06'05'' | 0:01'47'' |
| Q25L60X40P003 | 486.28M |   40.0 |     13115 | 10.15M | 1369 |      1028 | 484.47K | 499 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:06'04'' | 0:01'46'' |
| Q25L60X80P000 | 972.57M |   80.0 |     10872 |  9.78M | 1554 |       990 | 463.46K | 491 |   70.0 | 7.0 |  16.3 | 136.5 | "31,41,51,61,71,81" | 0:09'49'' | 0:01'44'' |
| Q25L60X80P001 | 972.57M |   80.0 |     11356 |  10.2M | 1545 |       973 | 464.78K | 502 |   70.0 | 8.0 |  15.3 | 140.0 | "31,41,51,61,71,81" | 0:09'47'' | 0:01'46'' |
| Q30L60X40P000 | 486.28M |   40.0 |     12586 |  10.2M | 1378 |       964 | 457.74K | 490 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:05'49'' | 0:01'46'' |
| Q30L60X40P001 | 486.28M |   40.0 |     13250 | 10.13M | 1353 |       990 | 455.94K | 483 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:05'50'' | 0:01'47'' |
| Q30L60X40P002 | 486.28M |   40.0 |     13163 | 10.11M | 1303 |       986 | 425.13K | 448 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:05'44'' | 0:01'48'' |
| Q30L60X40P003 | 486.28M |   40.0 |     13645 | 10.43M | 1318 |       975 | 410.44K | 450 |   36.0 | 4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 0:05'47'' | 0:01'43'' |
| Q30L60X80P000 | 972.57M |   80.0 |     12351 |  9.83M | 1455 |       992 | 451.54K | 478 |   70.0 | 7.0 |  16.3 | 136.5 | "31,41,51,61,71,81" | 0:09'40'' | 0:01'49'' |
| Q30L60X80P001 | 972.57M |   80.0 |     11951 | 10.34M | 1467 |       947 | 434.72K | 483 |   71.0 | 8.0 |  15.7 | 142.0 | "31,41,51,61,71,81" | 0:09'43'' | 0:01'49'' |

## s288c: merge anchors

## s288c: 3GS

| Name               |    N50 |       Sum |     # |
|:-------------------|-------:|----------:|------:|
| Genome             | 924431 |  12157105 |    17 |
| Paralogs           |   3851 |   1059148 |   366 |
| X40.raw.corrected  |   7382 | 297595242 | 53773 |
| X40.trim.corrected |   7456 | 308765772 | 54958 |
| X80.raw.corrected  |   7385 | 440867536 | 79638 |
| X80.trim.corrected |   7965 | 450502473 | 66099 |
| X40.raw            | 498694 |  12267418 |    48 |
| X40.trim           | 551422 |  12193990 |    47 |
| X80.raw            | 604680 |  12351131 |    37 |
| X80.trim           | 813374 |  12360766 |    26 |

## s288c: expand anchors

在酿酒酵母中, 有下列几组完全相同的序列, 它们都是新近发生的片段重复:

* I:216563-218385, VIII:537165-538987
* I:223713-224783, VIII:550350-551420
* IV:528442-530427, IV:532327-534312, IV:536212-538197
* IV:530324-531519, IV:534209-535404
* IV:5645-7725, X:738076-740156
* IV:7810-9432, X:736368-737990
* IX:9683-11043, X:9666-11026
* IV:1244112-1245373, XV:575980-577241
* VIII:212266-214124, VIII:214264-216122
* IX:11366-14953, X:11349-14936
* XII:468935-470576, XII:472587-474228, XII:482167-483808, XII:485819-487460,
* XII:483798-485798, XII:487450-489450

* anchorLong

* contigTrim

## s288c: final stats

* Stats

| Name                   |    N50 |      Sum |    # |
|:-----------------------|-------:|---------:|-----:|
| Genome                 | 924431 | 12157105 |   17 |
| Paralogs               |   3851 |  1059148 |  366 |
| anchor                 |  26624 | 11199635 |  786 |
| others                 |   1188 |  1526877 | 1367 |
| anchorLong             |  40449 | 11027419 |  540 |
| contigTrim             | 253177 | 11213678 |   82 |
| canu-X40-raw           | 498694 | 12267418 |   48 |
| canu-X40-trim          | 551422 | 12193990 |   47 |
| spades.contig          |  89836 | 11731746 | 1189 |
| spades.scaffold        |  98572 | 11732702 | 1167 |
| spades.non-contained   |  91619 | 11544360 |  291 |
| platanus.contig        |   5983 | 12437850 | 7727 |
| platanus.scaffold      |  55443 | 12073445 | 4735 |
| platanus.non-contained |  59263 | 11404921 |  360 |

* quast

## s288c: clear intermediate files

# *Drosophila melanogaster* iso-1

* Genome: [Ensembl 82](http://sep2015.archive.ensembl.org/Drosophila_melanogaster/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.0661

## iso_1: download

* Settings

```bash
BASE_NAME=iso_1
REAL_G=137567477
COVERAGE2="30 40 50 60 80 90"
COVERAGE3="40"
READ_QUAL="25 30"
READ_LEN="60"
EXPAND_WITH="40"

```

* Reference genome

```bash
mkdir -p ~/data/anchr/iso_1/1_genome
cd ~/data/anchr/iso_1/1_genome

wget -N ftp://ftp.ensembl.org/pub/release-82/fasta/drosophila_melanogaster/dna/Drosophila_melanogaster.BDGP6.dna_sm.toplevel.fa.gz
faops order Drosophila_melanogaster.BDGP6.dna_sm.toplevel.fa.gz \
    <(for chr in {2L,2R,3L,3R,4,X,Y,dmel_mitochondrion_genome}; do echo $chr; done) \
    genome.fa

cp ~/data/anchr/paralogs/model/Results/iso_1/iso_1.multi.fas 1_genome/paralogs.fas
```

* Illumina

    * [ERX645969](http://www.ebi.ac.uk/ena/data/view/ERX645969): ERR701706-ERR701711
    * SRR306628 labels ycnbwsp instead of iso-1.

```bash
mkdir -p ~/data/anchr/iso_1/2_illumina
cd ~/data/anchr/iso_1/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/err/ERR701/ERR701706
ftp://ftp.sra.ebi.ac.uk/vol1/err/ERR701/ERR701707
ftp://ftp.sra.ebi.ac.uk/vol1/err/ERR701/ERR701708
ftp://ftp.sra.ebi.ac.uk/vol1/err/ERR701/ERR701709
ftp://ftp.sra.ebi.ac.uk/vol1/err/ERR701/ERR701710
ftp://ftp.sra.ebi.ac.uk/vol1/err/ERR701/ERR701711
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
c0c877f8ba0bba7e26597e415d7591e1        ERR701706
8737074782482ced94418a579bc0e8db        ERR701707
e638730be88ee74102511c5091850359        ERR701708
d2bf01cb606e5d2ccad76bd1380e17a3        ERR701709
a51e6c1c09f225f1b6628b614c046ed0        ERR701710
dab2d1f14eff875f456045941a955b51        ERR701711
EOF

md5sum --check sra_md5.txt

for sra in ERR7017{06,07,08,09,10,11}; do
    echo ${sra}
    fastq-dump --split-files ./${sra}
done

cat ERR7017{06,07,08,09,10,11}_1.fastq > R1.fq
cat ERR7017{06,07,08,09,10,11}_2.fastq > R2.fq

find . -name "*.fq" | parallel -j 2 pigz -p 8
rm *.fastq
```

* PacBio

    PacBio provides a dataset of *D. melanogaster* strain
    [ISO1](https://github.com/PacificBiosciences/DevNet/wiki/Drosophila-sequence-and-assembly), the
    same stock used in the official BDGP reference assemblies. This is gathered with RS II and P5C3.

```bash
mkdir -p ~/data/anchr/iso_1/3_pacbio
cd ~/data/anchr/iso_1/3_pacbio

cat <<EOF > tgz.txt
https://s3.amazonaws.com/datasets.pacb.com/2014/Drosophila/raw/Dro1_24NOV2013_398.tgz
https://s3.amazonaws.com/datasets.pacb.com/2014/Drosophila/raw/Dro2_25NOV2013_399.tgz
https://s3.amazonaws.com/datasets.pacb.com/2014/Drosophila/raw/Dro3_26NOV2013_400.tgz
https://s3.amazonaws.com/datasets.pacb.com/2014/Drosophila/raw/Dro4_28NOV2013_401.tgz
https://s3.amazonaws.com/datasets.pacb.com/2014/Drosophila/raw/Dro5_29NOV2013_402.tgz
https://s3.amazonaws.com/datasets.pacb.com/2014/Drosophila/raw/Dro6_1DEC2013_403.tgz
EOF
aria2c -x 9 -s 3 -c -i tgz.txt

# untar
mkdir -p ~/data/anchr/iso_1/3_pacbio/untar
cd ~/data/anchr/iso_1/3_pacbio
tar xvfz Dro1_24NOV2013_398.tgz --directory untar
#tar xvfz Dro2_25NOV2013_399.tgz --directory untar
#tar xvfz Dro3_26NOV2013_400.tgz --directory untar
#tar xvfz Dro4_28NOV2013_401.tgz --directory untar
tar xvfz Dro5_29NOV2013_402.tgz --directory untar
tar xvfz Dro6_1DEC2013_403.tgz --directory untar

find . -type f -name "*.ba?.h5" | parallel -j 1 "mv {} untar" 

# convert .bax.h5 to .subreads.bam
mkdir -p ~/data/anchr/iso_1/3_pacbio/bam
cd ~/data/anchr/iso_1/3_pacbio/bam

source ~/share/pitchfork/deployment/setup-env.sh
for movie in m131124_190051 m131124_221952 m131125_013854 m131125_045830 m131130_054035 m131130_091217 m131130_124231 m131130_161213 m131130_194336 m131130_231441 m131201_024805 m131201_061903 m131201_223357 m131202_020424 m131202_053545 m131202_090545 m131202_123546 m131202_160616 m131202_193958 m131202_231109;
do 
    if [ -e ~/data/anchr/iso_1/3_pacbio/bam/${movie}*.subreads.bam ]; then
        continue
    fi
    bax2bam ~/data/anchr/iso_1/3_pacbio/untar/${movie}*.bax.h5
done

# convert .subreads.bam to fasta
mkdir -p ~/data/anchr/iso_1/3_pacbio/fasta
for movie in m131124_190051 m131124_221952 m131125_013854 m131125_045830 m131130_054035 m131130_091217 m131130_124231 m131130_161213 m131130_194336 m131130_231441 m131201_024805 m131201_061903 m131201_223357 m131202_020424 m131202_053545 m131202_090545 m131202_123546 m131202_160616 m131202_193958 m131202_231109;
do
    if [ ! -e ~/data/anchr/iso_1/3_pacbio/bam/${movie}*.subreads.bam ]; then
        continue
    fi

    samtools fasta \
        ~/data/anchr/iso_1/3_pacbio/bam/${movie}*.subreads.bam \
        > ~/data/anchr/iso_1/3_pacbio/fasta/${movie}.fasta
done

cd ~/data/anchr/iso_1
cat 3_pacbio/fasta/*.fasta > 3_pacbio/pacbio.fasta

```

* FastQC

* kmergenie

## iso_1: preprocess Illumina reads

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

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

cat ${HOME}/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
    > 2_illumina/illumina_adapters.fa
echo ">TruSeq_Adapter_Index_5" >> 2_illumina/illumina_adapters.fa
echo "GATCGGAAGAGCACACGTCTGAACTCCAGTCACACAGTGATCTCGTATGC" >> 2_illumina/illumina_adapters.fa
echo ">Illumina_Single_End_PCR_Primer_1" >> 2_illumina/illumina_adapters.fa
echo "GATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCG" >> 2_illumina/illumina_adapters.fa

if [ ! -e 2_illumina/R1.scythe.fq.gz ]; then
    parallel --no-run-if-empty -j 2 "
        scythe \
            2_illumina/{}.uniq.fq.gz \
            -q sanger \
            -a 2_illumina/illumina_adapters.fa \
            --quiet \
            | pigz -p 4 -c \
            > 2_illumina/{}.scythe.fq.gz
        " ::: R1 R2
fi

parallel --no-run-if-empty -j 3 "
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
    " ::: ${READ_QUAL} ::: ${READ_LEN}

```

## iso_1: preprocess PacBio reads

## iso_1: reads stats

| Name     |      N50 |         Sum |         # |
|:---------|---------:|------------:|----------:|
| Genome   | 25286936 |   137567477 |         8 |
| Paralogs |     4031 |    13665900 |      4492 |
| Illumina |      101 | 18115734306 | 179363706 |
| uniq     |      101 | 17595866904 | 174216504 |
| Q25L60   |      101 | 14636451057 | 147068666 |
| Q30L60   |      101 | 13929885386 | 142979844 |
| PacBio   |    13704 |  5620710497 |    630193 |
| X40.raw  |    13724 |  5502707116 |    616212 |
| X40.trim |    13587 |  5110432584 |    529483 |

## iso_1: spades

## iso_1: platanus

## iso_1: quorum

| Name   |  SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead | Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|-------:|------:|-------:|-------:|---------:|--------:|-----:|--------:|--------:|---------:|----------:|
| Q25L60 | 14.64G | 106.4 |  13.3G |   96.7 |   9.144% |      99 | "71" | 137.57M | 126.99M |     0.92 | 1:08'40'' |
| Q30L60 | 13.94G | 101.4 |    13G |   94.5 |   6.768% |      99 | "71" | 137.57M |  126.3M |     0.92 | 0:01'43'' |

## iso_1: down sampling

## iso_1: k-unitigs and anchors (sampled)

| Name          | SumCor | CovCor | N50SR |     Sum |     # | N50Anchor |     Sum |     # | N50Others |   Sum |    # |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|-------:|------:|--------:|------:|----------:|--------:|------:|----------:|------:|-----:|--------------------:|----------:|:----------|
| Q25L60X30P000 |  4.13G |   30.0 | 15149 | 120.02M | 18508 |     15738 | 114.97M | 13414 |       876 | 5.05M | 5094 | "31,41,51,61,71,81" | 1:15'07'' | 0:12'40'' |
| Q25L60X30P001 |  4.13G |   30.0 | 15157 | 120.09M | 18592 |     15722 |  114.9M | 13382 |       871 | 5.19M | 5210 | "31,41,51,61,71,81" | 1:14'53'' | 0:13'00'' |
| Q25L60X30P002 |  4.13G |   30.0 | 14854 | 119.91M | 18819 |     15517 | 114.88M | 13665 |       861 | 5.03M | 5154 | "31,41,51,61,71,81" | 1:14'46'' | 0:12'21'' |
| Q25L60X40P000 |   5.5G |   40.0 | 15047 | 120.27M | 18032 |     15567 | 115.69M | 13420 |       873 | 4.58M | 4612 | "31,41,51,61,71,81" | 1:23'52'' | 0:13'09'' |
| Q25L60X40P001 |   5.5G |   40.0 | 14858 | 120.17M | 18267 |     15427 | 115.57M | 13647 |       867 |  4.6M | 4620 | "31,41,51,61,71,81" | 1:20'33'' | 0:13'15'' |
| Q25L60X50P000 |  6.88G |   50.0 | 14047 | 120.35M | 18601 |     14584 | 115.74M | 14053 |       879 | 4.61M | 4548 | "31,41,51,61,71,81" | 1:34'20'' | 0:14'00'' |
| Q25L60X60P000 |  8.25G |   60.0 | 12960 |  120.5M | 19492 |     13427 | 115.72M | 14813 |       883 | 4.78M | 4679 | "31,41,51,61,71,81" | 1:37'26'' | 0:14'56'' |
| Q25L60X80P000 | 11.01G |   80.0 | 11442 | 120.48M | 21207 |     11894 | 115.57M | 16209 |       872 | 4.91M | 4998 | "31,41,51,61,71,81" | 2:01'14'' | 0:17'03'' |
| Q25L60X90P000 | 12.38G |   90.0 | 10810 | 120.56M | 22072 |     11270 | 115.37M | 16890 |       883 | 5.19M | 5182 | "31,41,51,61,71,81" | 2:04'48'' | 0:17'22'' |
| Q30L60X30P000 |  4.13G |   30.0 | 14106 |  119.6M | 19949 |     14766 | 114.24M | 14409 |       852 | 5.36M | 5540 | "31,41,51,61,71,81" | 1:12'39'' | 0:10'06'' |
| Q30L60X30P001 |  4.13G |   30.0 | 13848 | 119.66M | 20344 |     14573 | 114.26M | 14640 |       848 |  5.4M | 5704 | "31,41,51,61,71,81" | 1:09'08'' | 0:10'45'' |
| Q30L60X30P002 |  4.13G |   30.0 | 13376 | 119.69M | 20872 |     14066 | 114.06M | 14945 |       848 | 5.63M | 5927 | "31,41,51,61,71,81" | 1:11'59'' | 0:10'51'' |
| Q30L60X40P000 |   5.5G |   40.0 | 14689 | 120.02M | 18895 |     15236 |  115.1M | 13927 |       863 | 4.92M | 4968 | "31,41,51,61,71,81" | 1:39'43'' | 0:11'19'' |
| Q30L60X40P001 |   5.5G |   40.0 | 14196 |    120M | 19501 |     14762 | 114.91M | 14344 |       862 | 5.09M | 5157 | "31,41,51,61,71,81" | 1:45'46'' | 0:12'30'' |
| Q30L60X50P000 |  6.88G |   50.0 | 14475 | 120.19M | 18857 |     15099 | 115.34M | 14055 |       876 | 4.86M | 4802 | "31,41,51,61,71,81" | 2:39'21'' | 0:13'12'' |
| Q30L60X60P000 |  8.25G |   60.0 | 13721 | 120.24M | 19222 |     14312 | 115.45M | 14428 |       870 | 4.79M | 4794 | "31,41,51,61,71,81" | 2:42'39'' | 0:12'42'' |
| Q30L60X80P000 | 11.01G |   80.0 | 12558 | 120.36M | 20179 |     13107 | 115.53M | 15329 |       870 | 4.83M | 4850 | "31,41,51,61,71,81" | 3:40'45'' | 0:15'59'' |
| Q30L60X90P000 | 12.38G |   90.0 | 12064 | 120.37M | 20697 |     12543 | 115.46M | 15729 |       866 | 4.91M | 4968 | "31,41,51,61,71,81" | 3:42'05'' | 0:19'02'' |

## iso_1: merge anchors

## iso_1: 3GS

| Name               |      N50 |        Sum |      # |
|:-------------------|---------:|-----------:|-------:|
| Genome             | 25286936 |  137567477 |      8 |
| Paralogs           |     4031 |   13665900 |   4492 |
| X40.raw.corrected  |    13477 | 4357395055 | 444661 |
| X40.trim.corrected |    13405 | 4247295356 | 432489 |
| X40.raw            | 13356203 |  149005475 |    425 |
| X40.trim           |  8097152 |  149602462 |    446 |

## iso_1: expand anchors

* anchorLong

* contigTrim

## iso_1: final stats

* Stats

| Name                   |      N50 |       Sum |      # |
|:-----------------------|---------:|----------:|-------:|
| Genome                 | 25286936 | 137567477 |      8 |
| Paralogs               |     4031 |  13665900 |   4492 |
| anchor.merge           |    31929 | 117520723 |   8728 |
| others.merge           |     4637 |   4905392 |   2074 |
| anchorLong             |    41276 | 113743746 |   6780 |
| contigTrim             |   216556 | 113102926 |   1899 |
| canu-X40-raw           | 13356203 | 149005475 |    425 |
| canu-X40-trim          |  8097152 | 149602462 |    446 |
| spades.scaffold        |   142273 | 132725706 |  61182 |
| spades.non-contained   |   121727 | 122464676 |   4383 |
| platanus.contig        |    11503 | 156820565 | 359399 |
| platanus.scaffold      |   146404 | 129134232 |  71416 |
| platanus.non-contained |   161200 | 119999445 |   3216 |

* quast

## iso_1: clear intermediate files

# *Caenorhabditis elegans* N2

* Genome: [Ensembl 82](http://sep2015.archive.ensembl.org/Caenorhabditis_elegans/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.0472

## n2: download

* Settings

```bash
BASE_NAME=n2
REAL_G=100286401
IS_EUK="true"
COVERAGE2="30 40 50 60 70"
COVERAGE3="40 80"
READ_QUAL="25 30"
READ_LEN="60"
EXPAND_WITH="40"

```

* Reference genome

```bash
mkdir -p ~/data/anchr/n2/1_genome
cd ~/data/anchr/n2/1_genome

wget -N ftp://ftp.ensembl.org/pub/release-82/fasta/caenorhabditis_elegans/dna/Caenorhabditis_elegans.WBcel235.dna_sm.toplevel.fa.gz
faops order Caenorhabditis_elegans.WBcel235.dna_sm.toplevel.fa.gz \
    <(for chr in {I,II,III,IV,V,X,MtDNA}; do echo $chr; done) \
    genome.fa

cp ~/data/anchr/paralogs/model/Results/n2/n2.multi.fas 1_genome/paralogs.fas
```

* Illumina

    * Other SRA
        * SRX770040 - [insert size](https://www.ncbi.nlm.nih.gov/sra/SRX770040[accn]) is 500-600 bp
        * ERR1039478 - adaptor contamination "ACTTCCAGGGATTTATAAGCCGATGACGTCATAACATCCCTGACCCTTTA"
        * DRR008443 - GA II
        * SRR065390 - GA II

```bash
# Downloading from ena with aria2
mkdir -p ~/data/anchr/n2/2_illumina
cd ~/data/anchr/n2/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR157/009/SRR1571299
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR157/002/SRR1571322
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
8b6c83b413af32eddb58c12044c5411b        SRR1571299
1951826a35d31272615afa19ea9a552c        SRR1571322
EOF

md5sum --check sra_md5.txt

for sra in SRR1571{299,322}; do
    echo ${sra}
    fastq-dump --split-files ./${sra}
done

cat SRR1571{299,322}_1.fastq > R1.fq
cat SRR1571{299,322}_2.fastq > R2.fq

find . -name "*.fq" | parallel -j 2 pigz -p 8
rm *.fastq

```

* PacBio

https://github.com/PacificBiosciences/DevNet/wiki/C.-elegans-data-set

```bash
mkdir -p ~/data/anchr/n2/3_pacbio/fasta
cd ~/data/anchr/n2/3_pacbio/fasta

perl -MMojo::UserAgent -e '
    my $url = q{http://datasets.pacb.com.s3.amazonaws.com/2014/c_elegans/wget.html};

    my $ua   = Mojo::UserAgent->new->max_redirects(10);
    my $tx   = $ua->get($url);
    my $base = $tx->req->url;

    $tx->res->dom->find(q{a})->map( sub { $base->new( $_->{href} )->to_abs($base) } )
        ->each( sub                     { print shift . "\n" } );
' \
    | grep subreads.fasta \
    > s3.url.txt

aria2c -x 9 -s 3 -c -i s3.url.txt
find . -type f -name "*.fasta" | parallel -j 2 pigz -p 8

cd ~/data/anchr/n2/3_pacbio
find fasta -type f -name "*.subreads.fasta.gz" \
    | sort \
    | xargs gzip -d -c \
    | faops filter -l 0 stdin pacbio.fasta

```

* FastQC

* kmergenie

## n2: preprocess Illumina reads

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

cd 2_illumina

anchr trim \
    --uniq \
    --nosickle \
    R1.fq.gz R2.fq.gz \
    -o trim.sh
bash trim.sh

parallel --no-run-if-empty --linebuffer -k -j 3 "
    mkdir -p Q{1}L{2}
    cd Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        -q {1} -l {2} \
        \$(
            if [ -e ../R1.scythe.fq.gz ]; then
                echo '../R1.scythe.fq.gz ../R2.scythe.fq.gz'
            elif [ -e ../R1.sample.fq.gz ]; then
                echo '../R1.sample.fq.gz ../R2.sample.fq.gz'
            elif [ -e ../R1.shuffle.fq.gz ]; then
                echo '../R1.shuffle.fq.gz ../R2.shuffle.fq.gz'
            elif [ -e ../R1.uniq.fq.gz ]; then
                echo '../R1.uniq.fq.gz ../R2.uniq.fq.gz'
            else
                echo '../R1.fq.gz ../R2.fq.gz'
            fi
        ) \
         \
        -o stdout \
        | bash
    " ::: ${READ_QUAL} ::: ${READ_LEN}

```

## n2: preprocess PacBio reads

## n2: reads stats

| Name     |      N50 |         Sum |         # |
|:---------|---------:|------------:|----------:|
| Genome   | 17493829 |   100286401 |         7 |
| Paralogs |     2013 |     5313653 |      2637 |
| Illumina |      100 | 11560892600 | 115608926 |
| uniq     |      100 | 11388907200 | 113889072 |
| Q25L60   |      100 |  9883174284 | 101608118 |
| Q30L60   |      100 |  8868221193 |  99371914 |
| PacBio   |    16572 |  8117663505 |    740776 |
| X40.raw  |    16733 |  4011470192 |    360659 |
| X40.trim |    16336 |  3764009640 |    325356 |
| X80.raw  |    16578 |  8022917144 |    731704 |
| X80.trim |    16240 |  7584684643 |    666119 |

## n2: spades

## n2: platanus

## n2: quorum

| Name   | SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead | Kmer |   RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|------:|-------:|-------:|---------:|--------:|-----:|--------:|-------:|---------:|----------:|
| Q25L60 | 9.88G |  98.5 |  6.38G |   63.6 |  35.443% |      97 | "71" | 100.29M | 98.89M |     0.99 | 0:53'22'' |
| Q30L60 | 8.88G |  88.5 |  7.42G |   73.9 |  16.455% |      91 | "69" | 100.29M | 98.82M |     0.99 | 0:51'43'' |

## n2: adapter filtering

```text
#File	2_illumina/Q30L60/pe.cor.raw
#Total	84522239
#Matched	2807	0.00332%
#Name	Reads	ReadsPct
Reverse_adapter	2745	0.00325%
I7_Nextera_Transposase_1	29	0.00003%
TruSeq_Adapter_Index_13	18	0.00002%
I5_Nextera_Transposase_1	5	0.00001%
pcr_dimer	4	0.00000%
PCR_Primers	2	0.00000%
TruSeq_Adapter_Index_14	2	0.00000%
TruSeq_Adapter_Index_3	1	0.00000%
RNA_PCR_Primer_Index_38_(RPI38)	1	0.00000%

```

## n2: down sampling

## n2: k-unitigs and anchors (sampled)

| Name          | SumCor | CovCor | N50Anchor |    Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|-------:|----------:|-------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X30P000 |  3.01G |   30.0 |     11568 | 84.12M | 14036 |       957 | 20.09M | 18862 |   22.0 | 3.0 |   6.5 |  44.0 | "31,41,51,61,71,81" | 1:24'17'' | 0:41'00'' |
| Q25L60X30P001 |  3.01G |   30.0 |     10995 | 84.34M | 14453 |       920 | 19.47M | 19030 |   20.0 | 3.0 |   5.5 |  40.0 | "31,41,51,61,71,81" | 1:22'25'' | 0:38'17'' |
| Q25L60X40P000 |  4.01G |   40.0 |     12285 |  85.3M | 13327 |       990 | 17.92M | 16069 |   29.0 | 4.0 |   8.5 |  58.0 | "31,41,51,61,71,81" | 1:43'47'' | 0:43'24'' |
| Q25L60X50P000 |  5.01G |   50.0 |     12317 | 86.91M | 13193 |      1006 | 15.43M | 13248 |   35.0 | 6.0 |   8.5 |  70.0 | "31,41,51,61,71,81" | 1:50'13'' | 0:53'28'' |
| Q25L60X60P000 |  6.02G |   60.0 |     12419 | 87.36M | 13022 |      1040 | 14.26M | 11796 |   41.0 | 7.0 |  10.0 |  82.0 | "31,41,51,61,71,81" | 2:05'06'' | 0:55'26'' |
| Q30L60X30P000 |  3.01G |   30.0 |     11356 | 83.96M | 14306 |       948 | 20.96M | 19593 |   23.0 | 3.0 |   7.0 |  46.0 | "31,41,51,61,71,81" | 1:28'25'' | 0:57'17'' |
| Q30L60X30P001 |  3.01G |   30.0 |     10507 | 83.89M | 15035 |       899 | 20.44M | 20463 |   21.0 | 3.0 |   6.0 |  42.0 | "31,41,51,61,71,81" | 1:13'11'' | 0:56'24'' |
| Q30L60X40P000 |  4.01G |   40.0 |     12005 | 86.68M | 14011 |       932 | 17.82M | 16720 |   29.0 | 5.0 |   7.0 |  58.0 | "31,41,51,61,71,81" | 1:17'57'' | 1:04'21'' |
| Q30L60X50P000 |  5.01G |   50.0 |     12534 | 87.07M | 13353 |       968 | 16.46M | 14721 |   36.0 | 6.0 |   9.0 |  72.0 | "31,41,51,61,71,81" | 1:32'36'' | 1:12'17'' |
| Q30L60X60P000 |  6.02G |   60.0 |     12866 | 87.15M | 12913 |      1004 | 15.55M | 13274 |   43.0 | 7.0 |  11.0 |  86.0 | "31,41,51,61,71,81" | 2:12'26'' | 1:11'02'' |
| Q30L60X70P000 |  7.02G |   70.0 |     13064 | 87.19M | 12674 |      1046 | 14.88M | 12249 |   49.0 | 8.0 |  12.5 |  98.0 | "31,41,51,61,71,81" | 2:14'34'' | 1:04'45'' |

## n2: merge anchors

## n2: 3GS

| Name               |      N50 |        Sum |      # |
|:-------------------|---------:|-----------:|-------:|
| Genome             | 17493829 |  100286401 |      7 |
| Paralogs           |     2013 |    5313653 |   2637 |
| X40.raw.corrected  |    16283 | 3322175158 | 272851 |
| X40.trim.corrected |    16122 | 3270117760 | 272680 |
| X80.raw.corrected  |    18543 | 3841910529 | 204406 |
| X80.trim.corrected |    18288 | 3856015518 | 208003 |
| X40.raw            |  3680860 |  106573851 |    153 |
| X40.trim           |  2965260 |  106522712 |    153 |
| X80.raw            |  2922642 |  107417644 |    114 |
| X80.trim           |  3084499 |  107369523 |    116 |

## n2: expand anchors

* anchorLong

* contigTrim

## n2: final stats

* Stats

| Name                   |      N50 |       Sum |      # |
|:-----------------------|---------:|----------:|-------:|
| Genome                 | 17493829 | 100286401 |      7 |
| Paralogs               |     2013 |   5313653 |   2637 |
| anchor.merge           |    15591 |  90656638 |  11754 |
| others.merge           |    11300 |  11524419 |   3507 |
| anchorLong             |    20518 |  89701523 |   9054 |
| contigTrim             |   308321 |  95466256 |    694 |
| canu-X40-raw           |  3680860 | 106573851 |    153 |
| canu-X40-trim          |  2965260 | 106522712 |    153 |
| spades.scaffold        |    39185 | 105667774 |  39154 |
| spades.non-contained   |    38451 |  99104997 |   6431 |
| platanus.contig        |     9540 | 108908253 | 143264 |
| platanus.scaffold      |    28158 |  99589056 |  35182 |
| platanus.non-contained |    30510 |  94099392 |   7644 |

* quast

## n2: clear intermediate files

# *Arabidopsis thaliana* Col-0

* Genome: [Ensembl Genomes](http://plants.ensembl.org/Arabidopsis_thaliana/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.1158

## col_0: download

* Settings

```bash
BASE_NAME=col_0
REAL_G=119667750
IS_EUK="true"
COVERAGE2="30 40 50 60 70"
COVERAGE3="40 80"
READ_QUAL="25 30"
READ_LEN="60"
EXPAND_WITH="80"

```

* Reference genome

```bash
mkdir -p ~/data/anchr/col_0/1_genome
cd ~/data/anchr/col_0/1_genome
wget -N ftp://ftp.ensemblgenomes.org/pub/release-29/plants/fasta/arabidopsis_thaliana/dna/Arabidopsis_thaliana.TAIR10.29.dna_sm.toplevel.fa.gz
faops order Arabidopsis_thaliana.TAIR10.29.dna_sm.toplevel.fa.gz \
    <(for chr in {1,2,3,4,5,Mt,Pt}; do echo $chr; done) \
    genome.fa
```

* Illumina HiSeq (100 bp)

    [SRX202246](https://www.ncbi.nlm.nih.gov/sra/SRX202246[accn])

```bash
# Downloading from ena with aria2
mkdir -p ~/data/anchr/col_0/2_illumina
cd ~/data/anchr/col_0/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR611/SRR611086
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR616/SRR616966
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
b884e83b47c485c9a07f732b3805e7cf    SRR611086
102db119d1040c3bf85af5e4da6e456d    SRR616966
EOF

md5sum --check sra_md5.txt

for sra in SRR61{1086,6966}; do
    echo ${sra}
    fastq-dump --split-files ./${sra}
done

cat SRR61{1086,6966}_1.fastq > R1.fq
cat SRR61{1086,6966}_2.fastq > R2.fq

find . -name "*.fq" | parallel -j 2 pigz -p 8
rm *.fastq

```

* Illumina MiSeq

    [SRX2527206](https://www.ncbi.nlm.nih.gov/sra/SRX2527206[accn]) SRR5216995

```bash
BASE_NAME=col_0
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina
cd 2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR521/005/SRR5216995/SRR5216995_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR521/005/SRR5216995/SRR5216995_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
ce4a92a9364a6773633223ff7a807810 SRR5216995_1.fastq.gz
5c6672124a628ea0020c88e74eff53a3 SRR5216995_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s SRR5216995_1.fastq.gz R1.fq.gz
ln -s SRR5216995_2.fastq.gz R2.fq.gz

```

* PacBio

Chin, C.-S. *et al.* Phased diploid genome assembly with single-molecule real-time sequencing.
*Nature Methods* (2016). doi:10.1038/nmeth.4035

P4C2 is not supported in newer version of SMRTAnalysis.

https://www.ncbi.nlm.nih.gov/biosample/4539665

[SRX1715692](https://www.ncbi.nlm.nih.gov/sra/SRX1715692)

```bash
mkdir -p ~/data/anchr/col_0/3_pacbio
cd ~/data/anchr/col_0/3_pacbio

cat <<EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/002/SRR3405242
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/003/SRR3405243
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/004/SRR3405244
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/006/SRR3405246
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/008/SRR3405248
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/000/SRR3405250
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/002/SRR3405252
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/003/SRR3405253
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/004/SRR3405254
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/005/SRR3405255
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/006/SRR3405256
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/007/SRR3405257
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/008/SRR3405258
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/009/SRR3405259
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/005/SRR3405245
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/007/SRR3405247
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/009/SRR3405249
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/001/SRR3405251
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/000/SRR3405260
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/003/SRR3405263
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/005/SRR3405265
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/007/SRR3405267
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/009/SRR3405269
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/001/SRR3405271
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/004/SRR3405274
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/005/SRR3405275
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/006/SRR3405276
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/007/SRR3405277
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/008/SRR3405278
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/009/SRR3405279
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/000/SRR3405280
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/001/SRR3405281
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/002/SRR3405282
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/003/SRR3405283
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/004/SRR3405284
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/005/SRR3405285
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/006/SRR3405286
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/007/SRR3405287
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/008/SRR3405288
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/009/SRR3405289
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/000/SRR3405290
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/001/SRR3405261
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/002/SRR3405262
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/004/SRR3405264
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/006/SRR3405266
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/008/SRR3405268
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/000/SRR3405270
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/002/SRR3405272
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR340/003/SRR3405273
EOF

aria2c -x 6 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
be9c803f847ff1c81d153110cc699390        SRR3405242
c68a2c3b62245a697722fd3f8fda7a2d        SRR3405243
7116e8a0de87b1acd016d9b284e4795c        SRR3405244
51f8e5ee4565aace4e5a5cba73e3e597        SRR3405246
f339f580e86aad3a5487b5cec8ae80d4        SRR3405248
1a8246ed1f7c38801cfc603e088abb70        SRR3405250
a0ce8435a7fa2e7ddbd6ac181902f751        SRR3405252
8754f69a1c8c1f00b58b48454c1c01ad        SRR3405253
367508500303325e855666133505a5af        SRR3405254
d250f69fcf2975c89ceab5a4f9425b36        SRR3405255
badd9b2d23f94d1c98263d2e786742ae        SRR3405256
6c5cbd3bce9459283a415d8a5c05c86e        SRR3405257
32da7a364c8cbda5cf76b87f7c51b475        SRR3405258
eb3819adf483451ac670f89d1ea6b76e        SRR3405259
5337862eeb0945f932de74e8f7b9ec4f        SRR3405245
4545ce4666878fcbcda1e7737be1896b        SRR3405247
71d61bc64e3ca9b91f08b1c6b1389f16        SRR3405249
b9a911b8eb4fbfe29dff8cf920429f18        SRR3405251
99bae070fa90d53c8f15b9cf42c634f6        SRR3405260
830e02f1f3cb66b9e085803a21ad8040        SRR3405263
86d28c63f00095ae0ff1151e7e0bf7b4        SRR3405265
3e048ad8dbb526d4a533ee1d5ec10a43        SRR3405267
1b73ed3a1124f5f025c511672c1e18d3        SRR3405269
fa07c85b9e6258abcef8bdb730ab812f        SRR3405271
aeb6ab7edfa42e5e27704b7625c659c1        SRR3405274
0eb24fcc9b40f6fe0f013fe79dd7edf7        SRR3405275
f051e0065602477e0a1d13a6d0a42d3d        SRR3405276
178540e33e9f4f76adc8509b147d7ff6        SRR3405277
6fdfa97e2eacf0ac186b5333e97c334b        SRR3405278
a6bb6b57db82eb6e4161847f9d35a608        SRR3405279
8399b8e8e4d48c7374a414a9585efa5b        SRR3405280
e725278a3837775e214b39093a900927        SRR3405281
fab9120bfa1130b300f7e82b74d23173        SRR3405282
33929263f09811d7f7360a9675e82cdd        SRR3405283
7f9e58c6fa43e8f2f3fa2496e149d2cb        SRR3405284
b9a469affbff1bdcb1b299c106c2c1b9        SRR3405285
688ab23dbfe7977f9de780486a8d5c6b        SRR3405286
fadc273d324413017e45570e3bf0ee6e        SRR3405287
6f4b0eb22cb523ddecb842042d500ceb        SRR3405288
03a4581c1b951dba3bb9e295e9113bf3        SRR3405289
51fa78f451a33bd44f985ac220e17efe        SRR3405290
fac8c4c2a862a4d572d77d0deb4b0abc        SRR3405261
3fd1a3d8140cfa96a0287e9e2b6055c4        SRR3405262
f908e6194fb3a0026b5263acadbd2600        SRR3405264
e04a7d96ba91ebb11772c019981ea9eb        SRR3405266
784e28febf413c6dfa842802aa106a55        SRR3405268
05b91a051fc52417858e93ce3b22fe2e        SRR3405270
07bca433005313a4a2c8050e32952f58        SRR3405272
a9bbee29c3d507760c4c33fbbe436fa6        SRR3405273
EOF

md5sum --check sra_md5.txt

for sra in SRR34052{42,43,44,46,48,50,52,53,54,55,56,57,58,59,45,47,49,51,60,63,65,67,69,71,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,61,62,64,66,68,70,72,73}; do
    echo ${sra}
    fastq-dump ./${sra}
done

cat SRR34052{42,43,44,46,48,50,52,53,54,55,56,57,58,59,45,47,49,51,60,63,65,67,69,71,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,61,62,64,66,68,70,72,73}.fastq \
    > pacbio.fq

find . -name "*.fq" | parallel -j 2 pigz -p 8
rm *.fastq

faops filter -l 0 pacbio.fq.gz pacbio.fasta

```

* FastQC

* kmergenie

## col_0: preprocess Illumina reads

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

cd 2_illumina

cat <<EOF > illumina_adapters.fa
>multiplexing-forward
GATCGGAAGAGCACACGTCT
>truseq-forward-contam
AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
>truseq-reverse-contam
AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTA

>TruSeq_Adapter_Index_7
GATCGGAAGAGCACACGTCTGAACTCCAGTCACCAGATCATCTCGTATGC
>Illumina_Single_End_PCR_Primer_1
GATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCG

EOF

anchr trim \
    --uniq \
    --scythe -a illumina_adapters.fa \
    --nosickle \
    R1.fq.gz R2.fq.gz \
    -o trim.sh
bash trim.sh

parallel --no-run-if-empty --linebuffer -k -j 3 "
    mkdir -p Q{1}L{2}
    cd Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        -q {1} -l {2} \
        \$(
            if [ -e ../R1.scythe.fq.gz ]; then
                echo '../R1.scythe.fq.gz ../R2.scythe.fq.gz'
            elif [ -e ../R1.sample.fq.gz ]; then
                echo '../R1.sample.fq.gz ../R2.sample.fq.gz'
            elif [ -e ../R1.shuffle.fq.gz ]; then
                echo '../R1.shuffle.fq.gz ../R2.shuffle.fq.gz'
            elif [ -e ../R1.uniq.fq.gz ]; then
                echo '../R1.uniq.fq.gz ../R2.uniq.fq.gz'
            else
                echo '../R1.fq.gz ../R2.fq.gz'
            fi
        ) \
         \
        -o stdout \
        | bash
    " ::: ${READ_QUAL} ::: ${READ_LEN}

```

## col_0: preprocess PacBio reads

## col_0: reads stats

| Name            |      N50 |         Sum |        # |
|:----------------|---------:|------------:|---------:|
| Genome          | 23459830 |   119667750 |        7 |
| Paralogs        |     2007 |    16447809 |     8055 |
| Illumina        |      301 | 15529845059 | 53786130 |
| uniq            |      301 | 15528150050 | 53779068 |
| scythe          |      301 | 15360514682 | 53779068 |
| Q25L60          |      259 | 11810487076 | 49563358 |
| Q30L60          |      239 | 10358345113 | 48050599 |
| PacBio          |     6754 | 18768526777 |  5721958 |
| PacBio.40x      |     7830 |  4906030224 |  1300000 |
| PacBio.40x.trim |     6904 |  2032710549 |   381134 |
| PacBio.80x      |     7448 |  9473394614 |  2600000 |
| PacBio.80x.trim |     6975 |  3942522483 |   729527 |

## col_0: spades

## col_0: platanus

## col_0: quorum

| Name   |  SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead |  Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|-------:|------:|-------:|-------:|---------:|--------:|------:|--------:|--------:|---------:|----------:|
| Q25L60 | 11.81G |  98.7 |  8.44G |   70.6 |  28.507% |     236 | "127" | 119.67M | 125.42M |     1.05 | 0:31'28'' |
| Q30L60 | 10.36G |  86.6 |  8.74G |   73.0 |  15.659% |     218 | "127" | 119.67M | 119.18M |     1.00 | 0:28'04'' |

* Clear intermediate files.

## col_0: down sampling

## col_0: k-unitigs and anchors (sampled)

| Name          | SumCor | CovCor | N50SR |     Sum |     # | N50Anchor |     Sum |     # | N50Others |   Sum |    # |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|-------:|------:|--------:|------:|----------:|--------:|------:|----------:|------:|-----:|--------------------:|----------:|:----------|
| Q25L60X30P000 |  3.59G |   30.0 | 18733 | 111.59M | 15856 |     19498 | 107.59M | 10747 |       764 |    4M | 5109 | "31,41,51,61,71,81" | 1:06'14'' | 0:15'59'' |
| Q25L60X30P001 |  3.59G |   30.0 | 18745 | 111.55M | 15798 |     19547 | 107.66M | 10721 |       756 | 3.89M | 5077 | "31,41,51,61,71,81" | 1:04'15'' | 0:15'52'' |
| Q25L60X40P000 |  4.79G |   40.0 | 17330 |  111.7M | 16608 |     18073 | 107.57M | 11337 |       762 | 4.13M | 5271 | "31,41,51,61,71,81" | 1:17'35'' | 0:17'47'' |
| Q25L60X50P000 |  5.98G |   50.0 | 15873 |  111.8M | 17490 |     16552 | 107.54M | 11978 |       759 | 4.27M | 5512 | "31,41,51,61,71,81" | 1:22'01'' | 0:16'01'' |
| Q25L60X60P000 |  7.18G |   60.0 | 14741 |  111.9M | 18377 |     15450 | 107.46M | 12592 |       759 | 4.43M | 5785 | "31,41,51,61,71,81" | 1:35'15'' | 0:17'51'' |
| Q25L60X70P000 |  8.38G |   70.0 | 13862 | 112.08M | 19240 |     14573 | 107.31M | 13169 |       767 | 4.77M | 6071 | "31,41,51,61,71,81" | 1:40'24'' | 0:18'44'' |
| Q30L60X30P000 |  3.59G |   30.0 | 21238 | 111.92M | 15035 |     21979 | 107.52M |  9977 |       809 |  4.4M | 5058 | "31,41,51,61,71,81" | 1:02'03'' | 0:15'03'' |
| Q30L60X30P001 |  3.59G |   30.0 | 21339 | 111.82M | 14934 |     22177 | 107.68M |  9907 |       790 | 4.14M | 5027 | "31,41,51,61,71,81" | 0:59'13'' | 0:14'11'' |
| Q30L60X40P000 |  4.79G |   40.0 | 21449 | 112.02M | 15080 |     22146 | 107.62M |  9939 |       799 |  4.4M | 5141 | "31,41,51,61,71,81" | 1:07'02'' | 0:14'49'' |
| Q30L60X50P000 |  5.98G |   50.0 | 21448 | 112.12M | 15271 |     22214 | 107.69M |  9990 |       792 | 4.43M | 5281 | "31,41,51,61,71,81" | 1:08'37'' | 0:12'22'' |
| Q30L60X60P000 |  7.18G |   60.0 | 20774 | 112.22M | 15522 |     21760 | 107.72M | 10130 |       790 | 4.49M | 5392 | "31,41,51,61,71,81" | 1:46'11'' | 0:17'48'' |
| Q30L60X70P000 |  8.38G |   70.0 | 20201 |  112.3M | 15810 |     21326 | 107.73M | 10254 |       786 | 4.57M | 5556 | "31,41,51,61,71,81" | 2:05'08'' | 0:18'35'' |

## col_0: merge anchors

## col_0: 3GS

| Name               |      N50 |        Sum |      # |
|:-------------------|---------:|-----------:|-------:|
| Genome             | 23459830 |  119667750 |      7 |
| Paralogs           |     2007 |   16447809 |   8055 |
| X40.raw.corrected  |     6409 | 1314347545 | 260841 |
| X40.trim.corrected |     6857 | 1851234466 | 344501 |
| X80.raw.corrected  |     6531 | 2429934540 | 467495 |
| X80.trim.corrected |     6748 | 2839501986 | 535499 |
| X40.raw            |    55098 |  101659090 |   2680 |
| X40.trim           |   160979 |  113324147 |   1251 |
| X80.raw            |   496472 |  119336133 |    699 |
| X80.trim           |  3410906 |  120074130 |    336 |

## col_0: expand anchors

* anchorLong

* contigTrim

## col_0: final stats

* Stats

| Name                   |      N50 |       Sum |      # |
|:-----------------------|---------:|----------:|-------:|
| Genome                 | 23459830 | 119667750 |      7 |
| Paralogs               |     2007 |  16447809 |   8055 |
| anchor.merge           |    28769 | 108464379 |   8561 |
| others.merge           |     2695 |   2223388 |    971 |
| anchorLong             |    45816 | 107155884 |   5581 |
| contigTrim             |   987958 | 111197558 |    630 |
| canu-X80-raw           |   496472 | 119336133 |    699 |
| canu-X80-trim          |  3410906 | 120074130 |    336 |
| spades.scaffold        |    67856 | 154750615 | 114703 |
| spades.non-contained   |    95036 | 116874530 |   5039 |
| platanus.contig        |    15019 | 139807772 | 106870 |
| platanus.scaffold      |   192019 | 128497152 |  67429 |
| platanus.non-contained |   217851 | 116431399 |   2050 |

* quast

## col_0: clear intermediate files

