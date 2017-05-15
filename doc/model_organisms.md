# Assemble genomes of model organisms by ANCHR

[TOC levels=1-3]: # " "
- [Assemble genomes of model organisms by ANCHR](#assemble-genomes-of-model-organisms-by-anchr)
- [*Saccharomyces cerevisiae* S288c](#saccharomyces-cerevisiae-s288c)
    - [s288c: download](#s288c-download)
    - [s288c: combinations of different quality values and read lengths](#s288c-combinations-of-different-quality-values-and-read-lengths)
    - [s288c: quorum](#s288c-quorum)
    - [s288c: down sampling](#s288c-down-sampling)
    - [s288c: k-unitigs and anchors (sampled)](#s288c-k-unitigs-and-anchors-sampled)
    - [s288c: merge anchors with Qxx, Lxx and QxxLxx](#s288c-merge-anchors-with-qxx-lxx-and-qxxlxx)
    - [s288c: merge anchors](#s288c-merge-anchors)
    - [s288c: 3GS](#s288c-3gs)
    - [s288c: expand anchors](#s288c-expand-anchors)
- [*Drosophila melanogaster* iso-1](#drosophila-melanogaster-iso-1)
    - [iso_1: download](#iso-1-download)
    - [iso_1: combinations of different quality values and read lengths](#iso-1-combinations-of-different-quality-values-and-read-lengths)
    - [iso_1: quorum](#iso-1-quorum)
    - [iso_1: down sampling](#iso-1-down-sampling)
    - [iso_1: k-unitigs and anchors (sampled)](#iso-1-k-unitigs-and-anchors-sampled)
    - [iso_1: merge anchors](#iso-1-merge-anchors)
    - [iso_1: 3GS](#iso-1-3gs)
    - [iso_1: expand anchors](#iso-1-expand-anchors)
- [*Caenorhabditis elegans* N2](#caenorhabditis-elegans-n2)
    - [Cele: download](#cele-download)
    - [Cele: combinations of different quality values and read lengths](#cele-combinations-of-different-quality-values-and-read-lengths)
    - [Cele: down sampling](#cele-down-sampling)
    - [Cele: generate super-reads](#cele-generate-super-reads)
    - [Cele: create anchors](#cele-create-anchors)
    - [Cele: results](#cele-results)
    - [Cele: merge anchors from different groups of reads](#cele-merge-anchors-from-different-groups-of-reads)
    - [Cele: 3GS](#cele-3gs)
    - [Cele: expand anchors](#cele-expand-anchors)
- [*Arabidopsis thaliana* Col-0](#arabidopsis-thaliana-col-0)
    - [Atha: download](#atha-download)
    - [Atha: combinations of different quality values and read lengths](#atha-combinations-of-different-quality-values-and-read-lengths)
    - [Atha: down sampling](#atha-down-sampling)
    - [Atha: generate super-reads](#atha-generate-super-reads)
    - [Atha: create anchors](#atha-create-anchors)
    - [Atha: results](#atha-results)
    - [Atha: merge anchors from different groups of reads](#atha-merge-anchors-from-different-groups-of-reads)
    - [Atha: 3GS](#atha-3gs)
    - [Atha: expand anchors](#atha-expand-anchors)


# *Saccharomyces cerevisiae* S288c

* Genome: [Ensembl 82](http://sep2015.archive.ensembl.org/Saccharomyces_cerevisiae/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.058

## s288c: download

* Reference genome

```bash
mkdir -p ~/data/anchr/s288c/1_genome
cd ~/data/anchr/s288c/1_genome

wget -N ftp://ftp.ensembl.org/pub/release-82/fasta/saccharomyces_cerevisiae/dna/Saccharomyces_cerevisiae.R64-1-1.dna_sm.toplevel.fa.gz
faops order Saccharomyces_cerevisiae.R64-1-1.dna_sm.toplevel.fa.gz \
    <(for chr in {I,II,III,IV,V,VI,VII,VIII,IX,X,XI,XII,XIII,XIV,XV,XVI,Mito}; do echo $chr; done) \
    genome.fa

cp ~/data/anchr/paralogs/model/Results/s288c/s288c.multi.fas 1_genome/paralogs.fas
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
tar xvfz ERR1655120_ERR1655120_hdf5.tgz --directory untar
tar xvfz ERR1655122_ERR1655122_hdf5.tgz --directory untar
tar xvfz ERR1655124_ERR1655124_hdf5.tgz --directory untar

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

cd ~/data/anchr/s288c
cat 3_pacbio/fasta/*.fasta > 3_pacbio/pacbio.fasta

head -n 230000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.40x.fasta
faops n50 -S -C 3_pacbio/pacbio.40x.fasta

head -n 460000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.80x.fasta
faops n50 -S -C 3_pacbio/pacbio.80x.fasta

```

* FastQC

```bash
BASE_NAME=s288c
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

## s288c: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60 and 90

```bash
BASE_NAME=s288c
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
        ../R1.uniq.fq.gz ../R2.uniq.fq.gz \
        -o stdout \
        | bash
    " ::: 20 25 30 ::: 60 90

```

* Stats

```bash
BASE_NAME=s288c
cd ${HOME}/data/anchr/${BASE_NAME}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Paralogs"; faops n50 -H -S -C 1_genome/paralogs.fas;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "PacBio";   faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md

parallel -k --no-run-if-empty -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo Q{1}L{2};
            if [[ {1} -ge '30' ]]; then
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz \
                    2_illumina/Q{1}L{2}/Rs.fq.gz;
            else
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz;
            fi
        )
    " ::: 20 25 30 ::: 60 90 \
    >> stat.md

cat stat.md
```

| Name     |    N50 |        Sum |        # |
|:---------|-------:|-----------:|---------:|
| Genome   | 924431 |   12157105 |       17 |
| Paralogs |   3851 |    1059148 |      366 |
| PacBio   |   8169 | 3529504618 |   846948 |
| Illumina |    151 | 2939081214 | 19464114 |
| uniq     |    151 | 2778772064 | 18402464 |
| Q20L60   |    151 | 2666527231 | 17811724 |
| Q20L90   |    151 | 2639214106 | 17564788 |
| Q25L60   |    151 | 2502621682 | 16817924 |
| Q25L90   |    151 | 2452148068 | 16354088 |
| Q30L60   |    151 | 2442383221 | 16630313 |
| Q30L90   |    151 | 2405561651 | 16139590 |

## s288c: quorum

```bash
BASE_NAME=s288c
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 1 "
    cd 2_illumina/Q{1}L{2}
    echo >&2 '==> Group Q{1}L{2} <=='

    if [ ! -e R1.fq.gz ]; then
        echo >&2 '    R1.fq.gz not exists'
        exit;
    fi

    if [ -e pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa exists'
        exit;
    fi

    if [[ {1} -ge '30' ]]; then
        anchr quorum \
            R1.fq.gz R2.fq.gz Rs.fq.gz \
            -p 16 \
            -o quorum.sh
    else
        anchr quorum \
            R1.fq.gz R2.fq.gz \
            -p 16 \
            -o quorum.sh
    fi

    bash quorum.sh
    
    echo >&2
    " ::: 20 25 30 ::: 60 90

```

Clear intermediate files.

```bash
BASE_NAME=s288c
cd $HOME/data/anchr/${BASE_NAME}

find 2_illumina -type f -name "quorum_mer_db.jf" | xargs rm
find 2_illumina -type f -name "k_u_hash_0"       | xargs rm
find 2_illumina -type f -name "*.tmp"            | xargs rm
find 2_illumina -type f -name "pe.renamed.fastq" | xargs rm
find 2_illumina -type f -name "se.renamed.fastq" | xargs rm
find 2_illumina -type f -name "pe.cor.sub.fa"    | xargs rm
```

* Stats of processed reads

```bash
BASE_NAME=s288c
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=12157105

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > stat1.md

parallel -k --no-run-if-empty -j 3 "
    if [ ! -d 2_illumina/Q{1}L{2} ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 2_illumina/Q{1}L{2} ${REAL_G}
    " ::: 20 25 30 ::: 60 90 \
     >> stat1.md

cat stat1.md
```

| Name   | SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead |  Kmer |  RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|------:|-------:|-------:|---------:|--------:|------:|-------:|-------:|---------:|----------:|
| Q20L60 | 2.67G | 219.3 |  2.28G |  187.9 |  14.327% |     149 | "105" | 12.16M | 12.66M |     1.04 | 0:07'19'' |
| Q20L90 | 2.64G | 217.1 |  2.27G |  186.4 |  14.156% |     150 | "105" | 12.16M | 12.61M |     1.04 | 0:07'02'' |
| Q25L60 |  2.5G | 205.9 |   2.2G |  181.2 |  11.967% |     149 | "105" | 12.16M | 12.16M |     1.00 | 0:06'55'' |
| Q25L90 | 2.45G | 201.7 |  2.16G |  177.7 |  11.915% |     150 | "105" | 12.16M | 12.12M |     1.00 | 0:06'25'' |
| Q30L60 | 2.44G | 201.0 |  2.18G |  179.5 |  10.664% |     148 | "105" | 12.16M | 12.06M |     0.99 | 0:06'49'' |
| Q30L90 | 2.41G | 198.0 |  2.15G |  176.7 |  10.721% |     149 | "105" | 12.16M | 12.04M |     0.99 | 0:06'37'' |

* kmergenie

```bash
BASE_NAME=s288c
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

kmergenie -l 21 -k 121 -s 10 -t 8 ../R1.fq.gz -o oriR1
kmergenie -l 21 -k 121 -s 10 -t 8 ../R2.fq.gz -o oriR2
kmergenie -l 21 -k 121 -s 10 -t 8 ../Q30L60/pe.cor.fa -o Q30L60

```

## s288c: down sampling

```bash
BASE_NAME=s288c
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=12157105

for QxxLxx in $( parallel "echo 'Q{1}L{2}'" ::: 20 25 30 ::: 60 90 ); do
    echo "==> ${QxxLxx}"

    if [ ! -e 2_illumina/${QxxLxx}/pe.cor.fa ]; then
        echo "2_illumina/${QxxLxx}/pe.cor.fa not exists"
        continue;
    fi

    for X in 40 80 120 160; do
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

## s288c: k-unitigs and anchors (sampled)

```bash
BASE_NAME=s288c
cd ${HOME}/data/anchr/${BASE_NAME}

# k-unitigs (sampled)
parallel --no-run-if-empty -j 1 "
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
    " ::: 20 25 30 ::: 60 90 ::: 40 80 120 160 ::: 000 001 002 003 004 005 006

# anchors (sampled)
parallel --no-run-if-empty -j 3 "
    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'

    if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    rm -fr Q{1}L{2}X{3}P{4}/anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh Q{1}L{2}X{3}P{4} 8 false
    
    echo >&2
    " ::: 20 25 30 ::: 60 90 ::: 40 80 120 160 ::: 000 001 002 003 004 005 006

# Stats of anchors
REAL_G=12157105

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > stat2.md

parallel -k --no-run-if-empty -j 6 "
    if [ ! -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 Q{1}L{2}X{3}P{4} ${REAL_G}
    " ::: 20 25 30 ::: 60 90 ::: 40 80 120 160 ::: 000 001 002 003 004 005 006 \
    >> stat2.md

cat stat2.md
```

| Name           | SumCor  | CovCor | N50SR |    Sum |    # | N50Anchor |    Sum |    # | N50Others |     Sum |    # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|:--------|-------:|------:|-------:|-----:|----------:|-------:|-----:|----------:|--------:|-----:|--------------------:|----------:|----------:|
| Q20L60X40P000  | 486.28M |   40.0 |  9231 | 11.38M | 2127 |      9339 | 11.12M | 1786 |       787 |  261.7K |  341 | "31,41,51,61,71,81" | 0:04'22'' | 0:02'59'' |
| Q20L60X40P001  | 486.28M |   40.0 |  9111 | 11.41M | 2168 |      9280 | 11.07M | 1787 |       835 | 342.87K |  381 | "31,41,51,61,71,81" | 0:04'21'' | 0:02'59'' |
| Q20L60X40P002  | 486.28M |   40.0 |  9243 | 11.38M | 2108 |      9464 |  11.1M | 1768 |       784 | 284.01K |  340 | "31,41,51,61,71,81" | 0:04'22'' | 0:02'10'' |
| Q20L60X40P003  | 486.28M |   40.0 |  8719 | 11.39M | 2187 |      8886 | 11.08M | 1843 |       833 | 305.36K |  344 | "31,41,51,61,71,81" | 0:04'22'' | 0:02'00'' |
| Q20L60X80P000  | 972.57M |   80.0 |  5997 | 11.41M | 3036 |      6225 | 10.95M | 2438 |       790 | 462.08K |  598 | "31,41,51,61,71,81" | 0:06'56'' | 0:03'55'' |
| Q20L60X80P001  | 972.57M |   80.0 |  5719 |  11.4M | 3122 |      6078 | 10.91M | 2494 |       780 | 489.79K |  628 | "31,41,51,61,71,81" | 0:07'05'' | 0:04'01'' |
| Q20L60X120P000 | 1.46G   |  120.0 |  4415 | 11.35M | 3869 |      4654 |  10.7M | 2971 |       763 | 657.87K |  898 | "31,41,51,61,71,81" | 0:09'30'' | 0:06'28'' |
| Q20L60X160P000 | 1.95G   |  160.0 |  3720 |  11.3M | 4429 |      4000 | 10.43M | 3234 |       765 | 876.93K | 1195 | "31,41,51,61,71,81" | 0:12'16'' | 0:07'54'' |
| Q20L90X40P000  | 486.28M |   40.0 |  9294 | 11.38M | 2100 |      9503 | 11.12M | 1766 |       786 |    256K |  334 | "31,41,51,61,71,81" | 0:04'47'' | 0:02'43'' |
| Q20L90X40P001  | 486.28M |   40.0 |  9183 | 11.42M | 2163 |      9355 | 11.06M | 1780 |       858 |  363.4K |  383 | "31,41,51,61,71,81" | 0:04'47'' | 0:02'19'' |
| Q20L90X40P002  | 486.28M |   40.0 |  9506 | 11.39M | 2083 |      9620 |  11.1M | 1745 |       820 | 296.78K |  338 | "31,41,51,61,71,81" | 0:04'35'' | 0:02'26'' |
| Q20L90X40P003  | 486.28M |   40.0 |  8825 | 11.36M | 2175 |      8903 |  11.1M | 1835 |       776 | 267.47K |  340 | "31,41,51,61,71,81" | 0:04'40'' | 0:02'57'' |
| Q20L90X80P000  | 972.57M |   80.0 |  6044 |  11.4M | 3006 |      6258 | 10.95M | 2416 |       788 |  448.2K |  590 | "31,41,51,61,71,81" | 0:07'14'' | 0:04'46'' |
| Q20L90X80P001  | 972.57M |   80.0 |  5734 |  11.4M | 3090 |      6078 | 10.93M | 2479 |       780 | 476.35K |  611 | "31,41,51,61,71,81" | 0:07'10'' | 0:03'31'' |
| Q20L90X120P000 | 1.46G   |  120.0 |  4452 | 11.35M | 3818 |      4699 |  10.7M | 2925 |       767 | 655.02K |  893 | "31,41,51,61,71,81" | 0:09'51'' | 0:05'10'' |
| Q20L90X160P000 | 1.95G   |  160.0 |  3768 |  11.3M | 4376 |      4053 | 10.45M | 3206 |       767 | 857.87K | 1170 | "31,41,51,61,71,81" | 0:12'30'' | 0:06'23'' |
| Q25L60X40P000  | 486.28M |   40.0 | 10985 | 11.37M | 1842 |     11177 | 11.15M | 1546 |       761 | 217.37K |  296 | "31,41,51,61,71,81" | 0:04'39'' | 0:02'38'' |
| Q25L60X40P001  | 486.28M |   40.0 | 10671 |  11.4M | 1869 |     10934 |  11.1M | 1551 |       856 |  301.2K |  318 | "31,41,51,61,71,81" | 0:04'37'' | 0:02'40'' |
| Q25L60X40P002  | 486.28M |   40.0 | 11317 | 11.39M | 1765 |     11471 | 11.15M | 1498 |       831 |  245.1K |  267 | "31,41,51,61,71,81" | 0:04'39'' | 0:02'43'' |
| Q25L60X40P003  | 486.28M |   40.0 | 11115 | 11.41M | 1843 |     11325 | 11.16M | 1553 |       824 | 252.23K |  290 | "31,41,51,61,71,81" | 0:04'38'' | 0:02'36'' |
| Q25L60X80P000  | 972.57M |   80.0 |  8264 | 11.44M | 2326 |      8381 | 11.08M | 1919 |       825 | 360.45K |  407 | "31,41,51,61,71,81" | 0:07'14'' | 0:04'42'' |
| Q25L60X80P001  | 972.57M |   80.0 |  8207 | 11.44M | 2350 |      8448 | 11.08M | 1930 |       802 | 358.02K |  420 | "31,41,51,61,71,81" | 0:07'12'' | 0:04'46'' |
| Q25L60X120P000 | 1.46G   |  120.0 |  6332 | 11.43M | 2924 |      6508 | 10.97M | 2350 |       787 | 460.58K |  574 | "31,41,51,61,71,81" | 0:09'51'' | 0:05'51'' |
| Q25L60X160P000 | 1.95G   |  160.0 |  5328 | 11.39M | 3366 |      5608 | 10.84M | 2627 |       776 | 549.59K |  739 | "31,41,51,61,71,81" | 0:12'46'' | 0:06'56'' |
| Q25L90X40P000  | 486.28M |   40.0 | 11287 | 11.37M | 1828 |     11438 | 11.15M | 1536 |       785 | 224.53K |  292 | "31,41,51,61,71,81" | 0:04'39'' | 0:02'22'' |
| Q25L90X40P001  | 486.28M |   40.0 | 11063 | 11.38M | 1821 |     11327 | 11.11M | 1520 |       826 | 269.52K |  301 | "31,41,51,61,71,81" | 0:04'50'' | 0:02'14'' |
| Q25L90X40P002  | 486.28M |   40.0 | 11430 | 11.38M | 1760 |     11500 | 11.14M | 1501 |       833 | 239.34K |  259 | "31,41,51,61,71,81" | 0:04'39'' | 0:02'24'' |
| Q25L90X40P003  | 486.28M |   40.0 | 11330 | 11.36M | 1814 |     11459 | 11.15M | 1527 |       769 | 218.47K |  287 | "31,41,51,61,71,81" | 0:05'00'' | 0:02'29'' |
| Q25L90X80P000  | 972.57M |   80.0 |  8629 | 11.42M | 2271 |      8946 | 11.08M | 1865 |       809 | 343.76K |  406 | "31,41,51,61,71,81" | 0:07'47'' | 0:04'28'' |
| Q25L90X80P001  | 972.57M |   80.0 |  8301 | 11.43M | 2303 |      8501 | 11.09M | 1903 |       802 | 342.89K |  400 | "31,41,51,61,71,81" | 0:09'52'' | 0:03'44'' |
| Q25L90X120P000 | 1.46G   |  120.0 |  6545 | 11.43M | 2862 |      6764 | 10.96M | 2289 |       790 | 465.62K |  573 | "31,41,51,61,71,81" | 0:11'56'' | 0:06'20'' |
| Q25L90X160P000 | 1.95G   |  160.0 |  5541 | 11.38M | 3275 |      5864 | 10.85M | 2553 |       776 | 534.12K |  722 | "31,41,51,61,71,81" | 0:17'41'' | 0:06'31'' |
| Q30L60X40P000  | 486.28M |   40.0 | 11148 | 11.36M | 1814 |     11307 | 11.15M | 1528 |       778 | 212.36K |  286 | "31,41,51,61,71,81" | 0:04'21'' | 0:02'47'' |
| Q30L60X40P001  | 486.28M |   40.0 | 11437 | 11.35M | 1768 |     11594 | 11.14M | 1478 |       748 | 208.35K |  290 | "31,41,51,61,71,81" | 0:04'24'' | 0:02'50'' |
| Q30L60X40P002  | 486.28M |   40.0 | 11705 | 11.37M | 1704 |     11868 | 11.17M | 1456 |       769 | 200.92K |  248 | "31,41,51,61,71,81" | 0:04'24'' | 0:02'41'' |
| Q30L60X40P003  | 486.28M |   40.0 | 11941 | 11.35M | 1761 |     12110 | 11.14M | 1476 |       761 | 206.14K |  285 | "31,41,51,61,71,81" | 0:04'26'' | 0:02'22'' |
| Q30L60X80P000  | 972.57M |   80.0 |  9106 | 11.43M | 2187 |      9385 | 11.11M | 1807 |       801 | 321.24K |  380 | "31,41,51,61,71,81" | 0:07'35'' | 0:05'24'' |
| Q30L60X80P001  | 972.57M |   80.0 |  8759 | 11.42M | 2214 |      8946 | 11.11M | 1824 |       800 | 315.32K |  390 | "31,41,51,61,71,81" | 0:09'02'' | 0:05'37'' |
| Q30L60X120P000 | 1.46G   |  120.0 |  6733 | 11.44M | 2754 |      6971 | 10.99M | 2220 |       801 |  443.2K |  534 | "31,41,51,61,71,81" | 0:12'46'' | 0:06'01'' |
| Q30L60X160P000 | 1.95G   |  160.0 |  5899 | 11.39M | 3142 |      6129 |  10.9M | 2481 |       771 | 492.28K |  661 | "31,41,51,61,71,81" | 0:16'15'' | 0:07'43'' |
| Q30L90X40P000  | 486.28M |   40.0 | 11097 | 11.36M | 1821 |     11288 | 11.14M | 1539 |       784 | 216.48K |  282 | "31,41,51,61,71,81" | 0:05'54'' | 0:02'45'' |
| Q30L90X40P001  | 486.28M |   40.0 | 11229 | 11.34M | 1789 |     11458 | 11.13M | 1499 |       748 | 207.17K |  290 | "31,41,51,61,71,81" | 0:05'00'' | 0:02'14'' |
| Q30L90X40P002  | 486.28M |   40.0 | 11538 | 11.43M | 1745 |     11611 | 11.15M | 1483 |       895 | 278.21K |  262 | "31,41,51,61,71,81" | 0:05'16'' | 0:02'29'' |
| Q30L90X40P003  | 486.28M |   40.0 | 11940 | 11.35M | 1762 |     12129 | 11.13M | 1462 |       772 | 221.02K |  300 | "31,41,51,61,71,81" | 0:04'52'' | 0:02'35'' |
| Q30L90X80P000  | 972.57M |   80.0 |  9387 | 11.42M | 2168 |      9493 | 11.11M | 1796 |       803 |  312.8K |  372 | "31,41,51,61,71,81" | 0:07'56'' | 0:04'21'' |
| Q30L90X80P001  | 972.57M |   80.0 |  8868 | 11.45M | 2205 |      8972 | 11.07M | 1814 |       861 | 380.25K |  391 | "31,41,51,61,71,81" | 0:09'25'' | 0:03'59'' |
| Q30L90X120P000 | 1.46G   |  120.0 |  6913 | 11.43M | 2720 |      7175 |    11M | 2195 |       801 | 436.79K |  525 | "31,41,51,61,71,81" | 0:12'38'' | 0:05'54'' |
| Q30L90X160P000 | 1.95G   |  160.0 |  6055 | 11.39M | 3084 |      6288 |  10.9M | 2434 |       777 | 487.33K |  650 | "31,41,51,61,71,81" | 0:16'15'' | 0:05'49'' |

## s288c: merge anchors with Qxx, Lxx and QxxLxx

```bash
BASE_NAME=s288c
cd ${HOME}/data/anchr/${BASE_NAME}

# merge anchors with Qxx
for Q in 20 25 30; do
    mkdir -p mergeQ${Q}
    anchr contained \
        $(
            parallel -k --no-run-if-empty -j 6 '
                if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                    echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
                fi
                ' ::: ${Q} ::: 60 90 ::: 40 80 120 160 ::: 000 001 002 003 004 005
        ) \
        --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
        -o stdout \
        | faops filter -a 1000 -l 0 stdin mergeQ${Q}/anchor.contained.fasta
    anchr orient mergeQ${Q}/anchor.contained.fasta --len 1000 --idt 0.98 -o mergeQ${Q}/anchor.orient.fasta
    anchr merge mergeQ${Q}/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
        | faops filter -a 1000 -l 0 stdin mergeQ${Q}/anchor.merge.fasta
done

# merge anchors with Lxx
for L in 60 90; do
    mkdir -p mergeL${L}
    anchr contained \
        $(
            parallel -k --no-run-if-empty -j 6 '
                if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                    echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
                fi
                ' ::: 20 25 30 ::: ${L} ::: 40 80 120 160 ::: 000 001 002 003 004 005
        ) \
        --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
        -o stdout \
        | faops filter -a 1000 -l 0 stdin mergeL${L}/anchor.contained.fasta
    anchr orient mergeL${L}/anchor.contained.fasta --len 1000 --idt 0.98 -o mergeL${L}/anchor.orient.fasta
    anchr merge mergeL${L}/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
        | faops filter -a 1000 -l 0 stdin mergeL${L}/anchor.merge.fasta
done

# merge anchors with QxxLxx
for Q in 20 25 30; do
    for L in 60 90; do
        mkdir -p mergeQ${Q}L${L}
        anchr contained \
            $(
                parallel -k --no-run-if-empty -j 6 '
                    if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                        echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
                    fi
                    ' ::: ${Q} ::: ${L} ::: 40 80 120 160 ::: 000 001 002 003 004 005
            ) \
            --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
            -o stdout \
            | faops filter -a 1000 -l 0 stdin mergeQ${Q}L${L}/anchor.contained.fasta
        anchr orient mergeQ${Q}L${L}/anchor.contained.fasta --len 1000 --idt 0.98 -o mergeQ${Q}L${L}/anchor.orient.fasta
        anchr merge mergeQ${Q}L${L}/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
            | faops filter -a 1000 -l 0 stdin mergeQ${Q}L${L}/anchor.merge.fasta
    done
done

# quast
rm -fr 9_qa_mergeQL
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    mergeQ20/anchor.merge.fasta \
    mergeQ25/anchor.merge.fasta \
    mergeQ30/anchor.merge.fasta \
    mergeL60/anchor.merge.fasta \
    mergeL90/anchor.merge.fasta \
    mergeQ20L60/anchor.merge.fasta \
    mergeQ20L90/anchor.merge.fasta \
    mergeQ25L60/anchor.merge.fasta \
    mergeQ25L90/anchor.merge.fasta \
    mergeQ30L60/anchor.merge.fasta \
    mergeQ30L90/anchor.merge.fasta \
    1_genome/paralogs.fas \
    --label "mergeQ20,mergeQ25,mergeQ30,mergeL60,mergeL90,mergeQ20L60,mergeQ20L90,mergeQ25L60,mergeQ25L90,mergeQ30L60,mergeQ30L90,paralogs" \
    -o 9_qa_mergeQL

```

## s288c: merge anchors

```bash
BASE_NAME=s288c
cd ${HOME}/data/anchr/${BASE_NAME}

# merge anchors
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
            fi
            " ::: 25 30 ::: 60 ::: 40 80 120 160 200 ::: 000 001 002 003 004 005
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.others.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.others.fa
            fi
            " ::: 25 30 ::: 60 ::: 40 80 120 160 200 ::: 000 001 002 003 004 005
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.merge.fasta

# anchor sort on ref
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
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "merge,others,paralogs" \
    -o 9_qa

```

## s288c: 3GS

```bash
BASE_NAME=s288c
cd ${HOME}/data/anchr/${BASE_NAME}

canu \
    -p ${BASE_NAME} -d canu-raw-40x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=12.2m \
    -pacbio-raw 3_pacbio/pacbio.40x.fasta

canu \
    -p ${BASE_NAME} -d canu-raw-80x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=12.2m \
    -pacbio-raw 3_pacbio/pacbio.80x.fasta

faops n50 -S -C canu-raw-40x/${BASE_NAME}.trimmedReads.fasta.gz
faops n50 -S -C canu-raw-80x/${BASE_NAME}.trimmedReads.fasta.gz

```

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

```bash
BASE_NAME=s288c
cd ${HOME}/data/anchr/${BASE_NAME}

anchr cover \
    --parallel 16 \
    -c 2 -m 40 \
    -b 20 --len 1000 --idt 0.9 \
    merge/anchor.merge.fasta \
    canu-raw-40x/${BASE_NAME}.trimmedReads.fasta.gz \
    -o merge/anchor.cover.fasta

rm -fr anchorLong
anchr overlap2 \
    --parallel 16 \
    merge/anchor.cover.fasta \
    canu-raw-40x/${BASE_NAME}.trimmedReads.fasta.gz \
    -d anchorLong \
    -b 20 --len 1000 --idt 0.98

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

pushd anchorLong
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
   | faops filter -l 0 -a 1000 stdin anchorLong/contig.fasta

```

* contigTrim

```bash
BASE_NAME=s288c
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr contigTrim
anchr overlap2 \
    --parallel 16 \
    anchorLong/contig.fasta \
    canu-raw-40x/${BASE_NAME}.contigs.fasta \
    -d contigTrim \
    -b 20 --len 1000 --idt 0.98 --all

CONTIG_COUNT=$(faops n50 -H -N 0 -C contigTrim/anchor.fasta)
echo ${CONTIG_COUNT}

rm -fr contigTrim/group
anchr group \
    --parallel 16 \
    --keep \
    contigTrim/anchorLong.db \
    contigTrim/anchorLong.ovlp.tsv \
    --range "1-${CONTIG_COUNT}" --len 1000 --idt 0.98 --max 20000 -c 1

pushd contigTrim
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

* quast

```bash
BASE_NAME=s288c
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr 9_qa_contig
quast --no-check --threads 16 \
    --eukaryote \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/anchor.cover.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-raw-40x/${BASE_NAME}.contigs.fasta \
    canu-raw-80x/${BASE_NAME}.contigs.fasta \
    1_genome/paralogs.fas \
    --label "merge,cover,contig,contigTrim,canu-40x,canu-80x,paralogs" \
    -o 9_qa_contig

```

* Stats

```bash
BASE_NAME=s288c
cd ${HOME}/data/anchr/${BASE_NAME}

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

| Name         |    N50 |      Sum |   # |
|:-------------|-------:|---------:|----:|
| Genome       | 924431 | 12157105 |  17 |
| Paralogs     |   3851 |  1059148 | 366 |
| anchor.merge |  29107 | 11462728 | 697 |
| others.merge |   6008 |   222772 |  94 |
| anchor.cover |  29017 | 11403066 | 669 |
| anchorLong   |  66330 | 11362195 | 324 |
| contigTrim   | 533508 | 11420219 |  43 |

* Clear QxxLxxXxx.

```bash
BASE_NAME=s288c
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr 2_illumina/Q{20,25,30}L{1,60,90,120}X*
rm -fr Q{20,25,30}L{1,60,90,120}X*
```

# *Drosophila melanogaster* iso-1

* Genome: [Ensembl 82](http://sep2015.archive.ensembl.org/Drosophila_melanogaster/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.0661

## iso_1: download

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
    same stock used in the official BDGP reference assemblies. This is gathered with RS II and
    P5C3.

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

cd 3_pacbio/
ln -s pacbio.fasta pacbio.40x.fasta

```

* FastQC

```bash
BASE_NAME=iso_1
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

## iso_1: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60

```bash
BASE_NAME=iso_1
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
        ../R1.uniq.fq.gz ../R2.uniq.fq.gz \
        -o stdout \
        | bash
    " ::: 20 25 30 ::: 60

```

* Stats

```bash
BASE_NAME=iso_1
cd ${HOME}/data/anchr/${BASE_NAME}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Paralogs"; faops n50 -H -S -C 1_genome/paralogs.fas;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "PacBio";   faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md

parallel -k --no-run-if-empty -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo Q{1}L{2};
            if [[ {1} -ge '30' ]]; then
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz \
                    2_illumina/Q{1}L{2}/Rs.fq.gz;
            else
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz;
            fi
        )
    " ::: 20 25 30 ::: 60 \
    >> stat.md

cat stat.md
```

| Name     |      N50 |         Sum |         # |
|:---------|---------:|------------:|----------:|
| Genome   | 25286936 |   137567477 |         8 |
| Paralogs |     4031 |    13665900 |      4492 |
| PacBio   |    41580 |  5620710497 |    630193 |
| Illumina |      101 | 18115734306 | 179363706 |
| uniq     |      101 | 17595866904 | 174216504 |
| Q20L60   |      101 | 15645516794 | 156403806 |
| Q25L60   |      101 | 14657099109 | 147178220 |
| Q30L60   |      101 | 13983733793 | 143634907 |

## iso_1: quorum

```bash
BASE_NAME=iso_1
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 1 "
    cd 2_illumina/Q{1}L{2}
    echo >&2 '==> Group Q{1}L{2} <=='

    if [ ! -e R1.fq.gz ]; then
        echo >&2 '    R1.fq.gz not exists'
        exit;
    fi

    if [ -e pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa exists'
        exit;
    fi

    if [[ {1} -ge '30' ]]; then
        anchr quorum \
            R1.fq.gz R2.fq.gz Rs.fq.gz \
            -p 16 \
            -o quorum.sh
    else
        anchr quorum \
            R1.fq.gz R2.fq.gz \
            -p 16 \
            -o quorum.sh
    fi

    bash quorum.sh
    
    echo >&2
    " ::: 20 25 30 ::: 60

```

Clear intermediate files.

```bash
BASE_NAME=iso_1
cd $HOME/data/anchr/${BASE_NAME}

find 2_illumina -type f -name "quorum_mer_db.jf" | xargs rm
find 2_illumina -type f -name "k_u_hash_0"       | xargs rm
find 2_illumina -type f -name "*.tmp"            | xargs rm
find 2_illumina -type f -name "pe.renamed.fastq" | xargs rm
find 2_illumina -type f -name "se.renamed.fastq" | xargs rm
find 2_illumina -type f -name "pe.cor.sub.fa"    | xargs rm
```

* Stats of processed reads

```bash
BASE_NAME=iso_1
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=137567477

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > stat1.md

parallel -k --no-run-if-empty -j 3 "
    if [ ! -d 2_illumina/Q{1}L{2} ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 2_illumina/Q{1}L{2} ${REAL_G}
    " ::: 20 25 30 ::: 60 \
     >> stat1.md

cat stat1.md
```

| Name   |  SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead | Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|-------:|------:|-------:|-------:|---------:|--------:|-----:|--------:|--------:|---------:|----------:|
| Q20L60 | 15.65G | 113.7 | 13.86G |  100.8 |  11.383% |     100 | "71" | 137.57M |    129M |     0.94 | 1:02'31'' |
| Q25L60 | 14.66G | 106.5 | 13.26G |   96.4 |   9.506% |      99 | "71" | 137.57M | 127.11M |     0.92 | 0:58'16'' |
| Q30L60 |    14G | 101.7 | 12.97G |   94.3 |   7.364% |      99 | "71" | 137.57M |  126.4M |     0.92 | 0:56'23'' |

* kmergenie

```bash
BASE_NAME=iso_1
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

kmergenie -l 21 -k 121 -s 10 -t 8 ../R1.fq.gz -o oriR1
kmergenie -l 21 -k 121 -s 10 -t 8 ../R2.fq.gz -o oriR2
kmergenie -l 21 -k 121 -s 10 -t 8 ../Q30L60/pe.cor.fa -o Q30L60

```

## iso_1: down sampling

```bash
BASE_NAME=iso_1
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=137567477

for QxxLxx in $( parallel "echo 'Q{1}L{2}'" ::: 25 30 ::: 60 ); do
    echo "==> ${QxxLxx}"

    if [ ! -e 2_illumina/${QxxLxx}/pe.cor.fa ]; then
        echo "2_illumina/${QxxLxx}/pe.cor.fa not exists"
        continue;
    fi

    for X in 40 80; do
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

## iso_1: k-unitigs and anchors (sampled)

```bash
BASE_NAME=iso_1
cd ${HOME}/data/anchr/${BASE_NAME}

# k-unitigs (sampled)
parallel --no-run-if-empty -j 1 "
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
    " ::: 25 30 ::: 60 ::: 40 80 ::: 000 001 002 003 004 005 006

# anchors (sampled)
parallel --no-run-if-empty -j 3 "
    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'

    if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    rm -fr Q{1}L{2}X{3}P{4}/anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh Q{1}L{2}X{3}P{4} 8 false
    
    echo >&2
    " ::: 25 30 ::: 60 ::: 40 80 ::: 000 001 002 003 004 005 006

# Stats of anchors
REAL_G=137567477

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > stat2.md

parallel -k --no-run-if-empty -j 6 "
    if [ ! -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 Q{1}L{2}X{3}P{4} ${REAL_G}
    " ::: 25 30 ::: 60 ::: 40 80 ::: 000 001 002 003 004 005 006 \
    >> stat2.md

cat stat2.md
```

| Name          | SumCor | CovCor | N50SR |     Sum |     # | N50Anchor |     Sum |     # | N50Others |   Sum |    # |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|-------:|------:|--------:|------:|----------:|--------:|------:|----------:|------:|-----:|--------------------:|----------:|:----------|
| Q25L60X40P000 |   5.5G |   40.0 | 15061 | 120.29M | 17983 |     15493 | 116.89M | 13581 |       755 | 3.39M | 4402 | "31,41,51,61,71,81" | 1:31'40'' | 0:26'06'' |
| Q25L60X40P001 |   5.5G |   40.0 | 15027 | 120.19M | 18215 |     15523 | 116.85M | 13757 |       747 | 3.34M | 4458 | "31,41,51,61,71,81" | 1:29'48'' | 0:26'10'' |
| Q25L60X80P000 | 11.01G |   80.0 | 11463 |  120.5M | 21148 |     11832 | 117.12M | 16510 |       742 | 3.38M | 4638 | "31,41,51,61,71,81" | 2:05'13'' | 0:39'48'' |
| Q30L60X40P000 |   5.5G |   40.0 | 14700 | 120.08M | 18880 |     15207 | 116.44M | 14088 |       751 | 3.64M | 4792 | "31,41,51,61,71,81" | 1:25'39'' | 0:27'28'' |
| Q30L60X40P001 |   5.5G |   40.0 | 14159 | 120.01M | 19498 |     14679 | 116.27M | 14523 |       745 | 3.74M | 4975 | "31,41,51,61,71,81" | 1:18'23'' | 0:27'31'' |
| Q30L60X80P000 | 11.01G |   80.0 | 12528 | 120.34M | 20211 |     13027 | 116.93M | 15584 |       742 |  3.4M | 4627 | "31,41,51,61,71,81" | 1:51'18'' | 0:31'53'' |

## iso_1: merge anchors

```bash
BASE_NAME=iso_1
cd ${HOME}/data/anchr/${BASE_NAME}

# merge anchors
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
            fi
            " ::: 25 30 ::: 60 ::: 40 80 ::: 000 001 002 003 004 005
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.others.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.others.fa
            fi
            " ::: 25 30 ::: 60 ::: 40 80 ::: 000 001 002 003 004 005
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.merge.fasta

# anchor sort on ref
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
    --eukaryote \
    --no-icarus \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "merge,others,paralogs" \
    -o 9_qa

```

## iso_1: 3GS

```bash
BASE_NAME=iso_1
cd ${HOME}/data/anchr/${BASE_NAME}

canu \
    -p ${BASE_NAME} -d canu-raw-40x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=137.6m \
    -pacbio-raw 3_pacbio/pacbio.40x.fasta

faops n50 -S -C canu-raw-40x/iso_1.correctedReads.fasta.gz
faops n50 -S -C canu-raw-40x/iso_1.trimmedReads.fasta.gz

```

## iso_1: expand anchors

* anchorLong

```bash
BASE_NAME=iso_1
cd ${HOME}/data/anchr/${BASE_NAME}

anchr cover \
    --parallel 16 \
    -c 2 -m 40 \
    -b 50 --len 1000 --idt 0.9 \
    merge/anchor.merge.fasta \
    canu-raw-40x/${BASE_NAME}.trimmedReads.fasta.gz \
    -o merge/anchor.cover.fasta

rm -fr anchorLong
anchr overlap2 \
    --parallel 16 \
    merge/anchor.cover.fasta \
    canu-raw-40x/${BASE_NAME}.trimmedReads.fasta.gz \
    -d anchorLong \
    -b 50 --len 1000 --idt 0.98

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
    --range "1-${ANCHOR_COUNT}" --len 1000 --idt 0.98 --max "-14" -c 4

pushd anchorLong
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
   | faops filter -l 0 -a 1000 stdin anchorLong/contig.fasta

```

* contigTrim

```bash
BASE_NAME=iso_1
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr contigTrim
anchr overlap2 \
    --parallel 16 \
    anchorLong/contig.fasta \
    canu-raw-40x/${BASE_NAME}.contigs.fasta \
    -d contigTrim \
    -b 50 --len 1000 --idt 0.98 --all

CONTIG_COUNT=$(faops n50 -H -N 0 -C contigTrim/anchor.fasta)
echo ${CONTIG_COUNT}

rm -fr contigTrim/group
anchr group \
    --parallel 16 \
    --keep \
    contigTrim/anchorLong.db \
    contigTrim/anchorLong.ovlp.tsv \
    --range "1-${CONTIG_COUNT}" --len 1000 --idt 0.98 --max 20000 -c 1

pushd ${BASE_DIR}/contigTrim
cat group/groups.txt \
    | parallel --no-run-if-empty -j 8 '
        echo {};
        anchr orient \
            --len 1000 --idt 0.98 \
            group/{}.anchor.fasta \
            group/{}.long.fasta \
            -r group/{}.restrict.tsv \
            -o group/{}.strand.fasta;

        anchr overlap --len 1000 --idt 0.98 --all \
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

* quast

```bash
BASE_NAME=iso_1
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr 9_qa_contig
quast --no-check --threads 16 \
    --eukaryote \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/anchor.cover.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-raw-40x/${BASE_NAME}.contigs.fasta \
    1_genome/paralogs.fas \
    --label "merge,cover,contig,contigTrim,canu-40x,paralogs" \
    -o 9_qa_contig

```

* Stats

```bash
BASE_NAME=iso_1
cd ${HOME}/data/anchr/${BASE_NAME}

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

| Name         |      N50 |       Sum |     # |
|:-------------|---------:|----------:|------:|
| Genome       | 25286936 | 137567477 |     8 |
| Paralogs     |     4031 |  13665900 |  4492 |
| anchor.merge |    14126 | 117782908 | 14540 |
| others.merge |     1133 |    383574 |   275 |
| anchor.cover |    13951 | 115773049 | 14325 |
| anchorLong   |    52346 | 113638401 |  4683 |
| contigTrim   |  1852169 | 121664817 |   479 |

* Clear QxxLxxXxx.

```bash
BASE_NAME=iso_1
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr 2_illumina/Q{20,25,30}L{1,60,90,120}X*
rm -fr Q{20,25,30}L{1,60,90,120}X*
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

cp ~/data/anchr/paralogs/model/Results/n2/n2.multi.fas 1_genome/paralogs.fas
```

* Illumina

    * Other SRA
        * SRX770040 - [insert size](https://www.ncbi.nlm.nih.gov/sra/SRX770040[accn]) is 500-600 bp
        * ERR1039478 - adaptor contamination "ACTTCCAGGGATTTATAAGCCGATGACGTCATAACATCCCTGACCCTTTA"
        * DRR008443
        * SRR065390

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

cd ~/data/anchr/n2
head -n 740000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.40x.fasta
faops n50 -S -C 3_pacbio/pacbio.40x.fasta

head -n 1480000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.80x.fasta
faops n50 -S -C 3_pacbio/pacbio.80x.fasta

```

## Cele: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60

```bash
BASE_DIR=$HOME/data/anchr/n2

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
    " ::: 20 25 30 ::: 60

```

* Stats

```bash
BASE_DIR=$HOME/data/anchr/n2
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
    for len in 60; do
        DIR_COUNT="${BASE_DIR}/2_illumina/Q${qual}L${len}"

        printf "| %s | %s | %s | %s |\n" \
            $(echo "Q${qual}L${len}"; faops n50 -H -S -C ${DIR_COUNT}/R1.fq.gz  ${DIR_COUNT}/R2.fq.gz;) \
            >> stat.md
    done
done

cat stat.md
```

| Name     |      N50 |         Sum |         # |
|:---------|---------:|------------:|----------:|
| Genome   | 17493829 |   100286401 |         7 |
| Paralogs |     2013 |     5313653 |      2637 |
| Illumina |      100 | 11560892600 | 115608926 |
| PacBio   |    55460 |  8117663505 |    740776 |
| uniq     |      100 | 11388907200 | 113889072 |
| scythe   |      100 | 11230770194 | 113889072 |
| Q20L60   |      100 | 10527401946 | 106345252 |
| Q25L60   |      100 |  9860227096 | 101566534 |
| Q30L60   |      100 |  8177579465 |  91705860 |

## Cele: down sampling

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

ARRAY=( 
    "2_illumina/Q20L60:Q20L60"
    "2_illumina/Q25L60:Q25L60"
    "2_illumina/Q30L60:Q30L60"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    printf "==> %s \t %s\n" "$GROUP_DIR" "$GROUP_ID"

    echo "==> Group ${GROUP_ID}"
    mkdir -p ${BASE_DIR}/${GROUP_ID}
    
    if [ -e ${BASE_DIR}/${GROUP_ID}/R1.fq.gz ]; then
        continue     
    fi
    
    ln -s ${BASE_DIR}/${GROUP_DIR}/R1.fq.gz ${BASE_DIR}/${GROUP_ID}/R1.fq.gz
    ln -s ${BASE_DIR}/${GROUP_DIR}/R2.fq.gz ${BASE_DIR}/${GROUP_ID}/R2.fq.gz

done

```

## Cele: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/n2

cd ${BASE_DIR}
perl -e '
    for my $n (
        qw{
        Q20L60
        Q25L60
        Q30L60
        }
        )
    {
        printf qq{%s\n}, $n;
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
            --kmer 41,61,81 \
            -o superreads.sh
        bash superreads.sh
    "

```

Clear intermediate files.

```bash
cd $HOME/data/anchr/n2/

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## Cele: create anchors

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L60
        Q25L60
        Q30L60
        }
        )
    {
        printf qq{%s\n}, $n;
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

## Cele: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

REAL_G=100286401

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

perl -e '
    for my $n (
        qw{
        Q20L60
        Q25L60
        Q30L60
        }
        )
    {
        printf qq{%s\n}, $n;
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
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

perl -e '
    for my $n (
        qw{
        Q20L60
        Q25L60
        Q30L60
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 8 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

| Name   |  SumFq | CovFq | AvgRead |       Kmer | SumFa | Discard% |   RealG |   EstG | Est/Real |  SumKU | SumSR |   RunTime |
|:-------|-------:|------:|--------:|-----------:|------:|---------:|--------:|-------:|---------:|-------:|------:|----------:|
| Q20L60 | 10.53G | 105.0 |      99 | "41,61,81" | 6.43G |  38.922% | 100.29M |    99M |     0.99 | 98.42M |     0 | 2:16'29'' |
| Q25L60 |  9.86G |  98.3 |      97 | "41,61,81" | 6.44G |  34.655% | 100.29M | 98.85M |     0.99 | 98.46M |     0 | 2:13'52'' |
| Q30L60 |  8.18G |  81.5 |      91 | "41,61,81" | 6.83G |  16.420% | 100.29M | 98.67M |     0.98 | 98.36M |     0 | 2:00'15'' |

| Name   | N50SR |    Sum |     # | N50Anchor |    Sum |     # | N50Others |   Sum |    # |   RunTime |
|:-------|------:|-------:|------:|----------:|-------:|------:|----------:|------:|-----:|----------:|
| Q20L60 | 10265 | 98.42M | 20978 |     10947 | 93.43M | 14932 |       807 | 4.99M | 6046 | 0:31'53'' |
| Q25L60 | 11172 | 98.46M | 20121 |     12037 | 93.39M | 14132 |       817 | 5.08M | 5989 | 0:32'50'' |
| Q30L60 | 12010 | 98.36M | 19875 |     12876 |    93M | 13650 |       822 | 5.36M | 6225 | 0:34'43'' |

## Cele: merge anchors from different groups of reads

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L60/anchor/pe.anchor.fa \
    Q25L60/anchor/pe.anchor.fa \
    Q30L60/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
anchr contained \
    Q20L60/anchor/pe.others.fa \
    Q25L60/anchor/pe.others.fa \
    Q30L60/anchor/pe.others.fa \
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
    --eukaryote \
    --no-icarus \
    -R 1_genome/genome.fa \
    Q20L60/anchor/pe.anchor.fa \
    Q25L60/anchor/pe.anchor.fa \
    Q30L60/anchor/pe.anchor.fa \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "Q20L60,Q25L60,Q30L60,merge,others,paralogs" \
    -o 9_qa

```

## Cele: 3GS

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

canu \
    -p n2 -d canu-raw-40x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=100.3m \
    -pacbio-raw 3_pacbio/pacbio.40x.fasta
    
canu \
    -p n2 -d canu-raw-80x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=100.3m \
    -pacbio-raw 3_pacbio/pacbio.80x.fasta

faops n50 -S -C canu-raw-40x/n2.trimmedReads.fasta.gz
faops n50 -S -C canu-raw-80x/n2.trimmedReads.fasta.gz

```

## Cele: expand anchors

* anchorLong

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

anchr cover \
    --parallel 16 \
    -c 2 -m 40 \
    -b 50 --len 1000 --idt 0.9 \
    merge/anchor.merge.fasta \
    canu-raw-40x/n2.trimmedReads.fasta.gz \
    -o merge/anchor.cover.fasta

rm -fr anchorLong
anchr overlap2 \
    --parallel 16 \
    merge/anchor.cover.fasta \
    canu-raw-40x/n2.trimmedReads.fasta.gz \
    -d anchorLong \
    -b 50 --len 1000 --idt 0.98

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
    --range "1-${ANCHOR_COUNT}" --len 1000 --idt 0.98 --max "-14" -c 4

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
   | faops filter -l 0 -a 1000 stdin anchorLong/contig.fasta

```

* contigTrim

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

rm -fr contigTrim
anchr overlap2 \
    --parallel 16 \
    anchorLong/contig.fasta \
    canu-raw-40x/n2.contigs.fasta \
    -d contigTrim \
    -b 50 --len 1000 --idt 0.98 --all

CONTIG_COUNT=$(faops n50 -H -N 0 -C contigTrim/anchor.fasta)
echo ${CONTIG_COUNT}

rm -fr contigTrim/group
anchr group \
    --parallel 16 \
    --keep \
    contigTrim/anchorLong.db \
    contigTrim/anchorLong.ovlp.tsv \
    --range "1-${CONTIG_COUNT}" --len 1000 --idt 0.98 --max 20000 -c 1

pushd ${BASE_DIR}/contigTrim
cat group/groups.txt \
    | parallel --no-run-if-empty -j 8 '
        echo {};
        anchr orient \
            --len 1000 --idt 0.98 \
            group/{}.anchor.fasta \
            group/{}.long.fasta \
            -r group/{}.restrict.tsv \
            -o group/{}.strand.fasta;

        anchr overlap --len 1000 --idt 0.98 --all \
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

* quast

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

rm -fr 9_qa_contig
quast --no-check --threads 16 \
    --eukaryote \
    --no-icarus \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/anchor.cover.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-raw-40x/n2.contigs.fasta \
    canu-raw-80x/n2.contigs.fasta \
    1_genome/paralogs.fas \
    --label "merge,cover,contig,contigTrim,canu-40x,canu-80x,paralogs" \
    -o 9_qa_contig

```

* Stats

```bash
BASE_DIR=$HOME/data/anchr/n2
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

| Name         |      N50 |       Sum |     # |
|:-------------|---------:|----------:|------:|
| Genome       | 17493829 | 100286401 |     7 |
| Paralogs     |     2013 |   5313653 |  2637 |
| anchor.merge |    13799 |  94200061 | 13071 |
| others.merge |     2402 |   1785990 |   851 |
| anchor.cover |    13401 |  92637789 | 12998 |
| anchorLong   |    22482 |  92245773 |  8868 |
| contigTrim   |  1269169 | 100974497 |   430 |

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
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

* PacBio

Chin, C.-S. *et al.* Phased diploid genome assembly with single-molecule real-time sequencing. *Nature Methods* (2016). doi:10.1038/nmeth.4035

P4C2 is not supported in newer version of SMRTAnalysis.

https://www.ncbi.nlm.nih.gov/biosample/4539665

[SRX1715692](https://www.ncbi.nlm.nih.gov/sra/SRX1715692[accn])

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

cd ~/data/anchr/col_0
head -n 2600000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.40x.fasta
faops n50 -S -C 3_pacbio/pacbio.40x.fasta

head -n 5200000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.80x.fasta
faops n50 -S -C 3_pacbio/pacbio.80x.fasta

```

## Atha: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60

```bash
BASE_DIR=$HOME/data/anchr/col_0

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
    " ::: 20 25 30 ::: 60

```

* Stats

```bash
BASE_DIR=$HOME/data/anchr/col_0
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
    for len in 60; do
        DIR_COUNT="${BASE_DIR}/2_illumina/Q${qual}L${len}"

        printf "| %s | %s | %s | %s |\n" \
            $(echo "Q${qual}L${len}"; faops n50 -H -S -C ${DIR_COUNT}/R1.fq.gz  ${DIR_COUNT}/R2.fq.gz;) \
            >> stat.md
    done
done

cat stat.md
```

| Name     |      N50 |         Sum |         # |
|:---------|---------:|------------:|----------:|
| Genome   | 23459830 |   119667750 |         7 |
| Paralogs |     2007 |    16447809 |      8055 |
| Illumina |      100 | 14948629000 | 149486290 |
| PacBio   |    44636 | 18768526777 |   5721958 |
| uniq     |      100 | 14463135400 | 144631354 |
| scythe   |      100 | 14375529511 | 144631354 |
| Q20L80   |      100 | 12382752775 | 124513758 |
| Q20L90   |      100 | 11851396527 | 118728378 |
| Q20L100  |      100 | 11258729200 | 112587292 |
| Q25L80   |      100 | 11126467271 | 111994486 |
| Q25L90   |      100 | 10522888606 | 105418214 |
| Q25L100  |      100 |  9978506000 |  99785060 |
| Q30L80   |      100 |  9022070877 |  91162128 |
| Q30L90   |      100 |  8234307462 |  82563768 |
| Q30L100  |      100 |  7586600800 |  75866008 |

## Atha: down sampling

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

ARRAY=( 
    "2_illumina/Q20L60:Q20L60"
    "2_illumina/Q25L60:Q25L60"
    "2_illumina/Q30L60:Q30L60"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    printf "==> %s \t %s\n" "$GROUP_DIR" "$GROUP_ID"

    echo "==> Group ${GROUP_ID}"
    DIR_COUNT="${BASE_DIR}/${GROUP_ID}"
    mkdir -p ${DIR_COUNT}
    
    if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
        continue     
    fi
    
    ln -s ${BASE_DIR}/${GROUP_DIR}/R1.fq.gz ${DIR_COUNT}/R1.fq.gz
    ln -s ${BASE_DIR}/${GROUP_DIR}/R2.fq.gz ${DIR_COUNT}/R2.fq.gz

done

```

## Atha: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/col_0

cd ${BASE_DIR}
perl -e '
    for my $n (
        qw{
        Q20L60
        Q25L60
        Q30L60
        }
        )
    {
        printf qq{%s\n}, $n;
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
            --kmer 41,61,81 \
            -o superreads.sh
        bash superreads.sh
    "

```

Clear intermediate files.

```bash
cd $HOME/data/anchr/col_0/

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## Atha: create anchors

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L60
        Q25L60
        Q30L60
        }
        )
    {
        printf qq{%s\n}, $n;
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

## Atha: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

REAL_G=119667750

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

perl -e '
    for my $n (
        qw{
        Q20L60
        Q25L60
        Q30L60
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 1 "
        if [ ! -d ${BASE_DIR}/{} ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${BASE_DIR}/{} ${REAL_G}
    " >> ${BASE_DIR}/stat1.md

cat stat1.md
```

* Stats of anchors

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

perl -e '
    for my $n (
        qw{
        Q20L60
        Q25L60
        Q30L60
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 8 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

| Name   |  SumFq | CovFq | AvgRead |       Kmer |  SumFa | Discard% |   RealG |    EstG | Est/Real |   SumKU | SumSR |   RunTime |
|:-------|-------:|------:|--------:|-----------:|-------:|---------:|--------:|--------:|---------:|--------:|------:|----------:|
| Q20L60 | 13.08G | 109.3 |      98 | "41,61,81" | 10.72G |  18.005% | 119.67M |  287.5M |     2.40 | 160.94M |     0 | 6:26'58'' |
| Q25L60 | 11.99G | 100.2 |      98 | "41,61,81" |  9.97G |  16.836% | 119.67M | 264.82M |     2.21 | 149.92M |     0 | 6:40'06'' |
| Q30L60 | 10.25G |  85.6 |      96 | "41,61,81" |  8.65G |  15.572% | 119.67M |  226.1M |     1.89 | 131.26M |     0 | 5:48'23'' |

| Name   | N50SR |     Sum |     # | N50Anchor |     Sum |     # | N50Others |    Sum |     # |   RunTime |
|:-------|------:|--------:|------:|----------:|--------:|------:|----------:|-------:|------:|----------:|
| Q20L60 |  6006 | 160.94M | 74206 |      8853 | 129.12M | 28687 |       709 | 31.82M | 45519 | 0:52'07'' |
| Q25L60 |  7827 | 149.92M | 62611 |     10965 |    123M | 23944 |       706 | 26.92M | 38667 | 0:51'54'' |
| Q30L60 |  9263 | 131.26M | 45874 |     11481 | 112.84M | 19274 |       697 | 18.42M | 26600 | 0:49'47'' |

## Atha: merge anchors from different groups of reads

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L60/anchor/pe.anchor.fa \
    Q25L60/anchor/pe.anchor.fa \
    Q30L60/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
anchr contained \
    Q20L60/anchor/pe.others.fa \
    Q25L60/anchor/pe.others.fa \
    Q30L60/anchor/pe.others.fa \
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
    --eukaryote \
    --no-icarus \
    -R 1_genome/genome.fa \
    Q20L60/anchor/pe.anchor.fa \
    Q25L60/anchor/pe.anchor.fa \
    Q30L60/anchor/pe.anchor.fa \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "Q20L60,Q25L60,Q30L60,merge,others,paralogs" \
    -o 9_qa

```

## Atha: 3GS

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

canu \
    -p col_0 -d canu-raw-40x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=119.7m \
    -pacbio-raw 3_pacbio/pacbio.40x.fasta
    
canu \
    -p col_0 -d canu-raw-80x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=119.7m \
    -pacbio-raw 3_pacbio/pacbio.80x.fasta

faops n50 -S -C canu-raw-40x/col_0.trimmedReads.fasta.gz
faops n50 -S -C canu-raw-80x/col_0.trimmedReads.fasta.gz

rm -fr canu-raw-40x/correction
rm -fr canu-raw-80x/correction

```

## Atha: expand anchors

* anchorLong

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

anchr cover \
    --parallel 16 \
    -c 2 -m 40 \
    -b 50 --len 1000 --idt 0.9 \
    merge/anchor.merge.fasta \
    canu-raw-40x/col_0.trimmedReads.fasta.gz \
    -o merge/anchor.cover.fasta

rm -fr anchorLong
anchr overlap2 \
    --parallel 16 \
    merge/anchor.cover.fasta \
    canu-raw-40x/col_0.trimmedReads.fasta.gz \
    -d anchorLong \
    -b 50 --len 1000 --idt 0.98

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
    --range "1-${ANCHOR_COUNT}" --len 1000 --idt 0.98 --max "-14" -c 4

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
   | faops filter -l 0 -a 1000 stdin anchorLong/contig.fasta

```

* contigTrim

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

rm -fr contigTrim
anchr overlap2 \
    --parallel 16 \
    anchorLong/contig.fasta \
    canu-raw-40x/col_0.contigs.fasta \
    -d contigTrim \
    -b 50 --len 1000 --idt 0.98 --all

CONTIG_COUNT=$(faops n50 -H -N 0 -C contigTrim/anchor.fasta)
echo ${CONTIG_COUNT}

rm -fr contigTrim/group
anchr group \
    --parallel 16 \
    --keep \
    contigTrim/anchorLong.db \
    contigTrim/anchorLong.ovlp.tsv \
    --range "1-${CONTIG_COUNT}" --len 1000 --idt 0.98 --max 20000 -c 1

pushd ${BASE_DIR}/contigTrim
cat group/groups.txt \
    | parallel --no-run-if-empty -j 8 '
        echo {};
        anchr orient \
            --len 1000 --idt 0.98 \
            group/{}.anchor.fasta \
            group/{}.long.fasta \
            -r group/{}.restrict.tsv \
            -o group/{}.strand.fasta;

        anchr overlap --len 1000 --idt 0.98 --all \
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

* quast

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

rm -fr 9_qa_contig
quast --no-check --threads 16 \
    --eukaryote \
    --no-icarus \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/anchor.cover.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-raw-40x/col_0.contigs.fasta \
    canu-raw-80x/col_0.contigs.fasta \
    1_genome/paralogs.fas \
    --label "merge,cover,contig,contigTrim,canu-40x,canu-80x,paralogs" \
    -o 9_qa_contig

```

* Stats

```bash
BASE_DIR=$HOME/data/anchr/col_0
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

| Name         |      N50 |       Sum |     # |
|:-------------|---------:|----------:|------:|
| Genome       | 23459830 | 119667750 |     7 |
| Paralogs     |     2007 |  16447809 |  8055 |
| anchor.merge |    11645 | 130998211 | 26612 |
| others.merge |     1029 |   2667364 |  2317 |
| anchor.cover |    11236 |  99297473 | 14876 |
| anchorLong   |    16909 |  99006352 | 11058 |
| contigTrim   |    48059 | 103917843 |  4907 |

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```
