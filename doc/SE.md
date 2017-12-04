# Single End

[TOC levels=1-3]: # " "
- [Single End](#single-end)
- [*Escherichia coli* str. K-12 substr. MG1655](#escherichia-coli-str-k-12-substr-mg1655)
    - [Download](#download)
    - [Preprocess Illumina reads](#preprocess-illumina-reads)
    - [Reads stats](#reads-stats)
    - [Quorum](#quorum)
    - [Down sampling](#down-sampling)
    - [K-unitigs and anchors (sampled)](#k-unitigs-and-anchors-sampled)
    - [Merge anchors](#merge-anchors)
    - [Clear intermediate files](#clear-intermediate-files)


# *Escherichia coli* str. K-12 substr. MG1655

* Genome: INSDC [U00096.3](https://www.ncbi.nlm.nih.gov/nuccore/U00096.3)
* Taxonomy ID: [511145](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=511145)
* Proportion of paralogs (> 1000 bp): 0.0323

## Download

* Settings

```bash
BASE_NAME=SE
REAL_G=4641652
COVERAGE2="40 80"
READ_QUAL="25 30"
READ_LEN="60"

```

* Reference genome

```bash
mkdir -p ${HOME}/data/anchr/${BASE_NAME}/1_genome
cd ${HOME}/data/anchr/${BASE_NAME}/1_genome

cp ~/data/anchr/e_coli/1_genome/genome.fa .
cp ~/data/anchr/e_coli/1_genome/paralogs.fas .

```

* Illumina

```bash
mkdir -p ${HOME}/data/anchr/${BASE_NAME}/2_illumina
cd ${HOME}/data/anchr/${BASE_NAME}/2_illumina

ln -sf ${HOME}/data/anchr/e_coli/2_illumina/MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz R1.fq.gz

```

## Preprocess Illumina reads

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

cd 2_illumina

anchr trim \
    --uniq \
    --shuffle \
    --scythe \
    --nosickle \
    R1.fq.gz \
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
                echo '../R1.scythe.fq.gz'
            elif [ -e ../R1.sample.fq.gz ]; then
                echo '../R1.sample.fq.gz'
            elif [ -e ../R1.shuffle.fq.gz ]; then
                echo '../R1.shuffle.fq.gz'
            elif [ -e ../R1.uniq.fq.gz ]; then
                echo '../R1.uniq.fq.gz'
            else
                echo '../R1.fq.gz'
            fi
        ) \
         \
        -o stdout \
        | bash
    " ::: ${READ_QUAL} ::: ${READ_LEN}

```

## Reads stats

```bash
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
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz;) >> stat.md
if [ -e 2_illumina/R1.uniq.fq.gz ]; then
    printf "| %s | %s | %s | %s |\n" \
        $(echo "uniq";    faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz;) >> stat.md
fi
if [ -e 2_illumina/R1.shuffle.fq.gz ]; then
    printf "| %s | %s | %s | %s |\n" \
        $(echo "shuffle"; faops n50 -H -S -C 2_illumina/R1.shuffle.fq.gz;) >> stat.md
fi
if [ -e 2_illumina/R1.sample.fq.gz ]; then
    printf "| %s | %s | %s | %s |\n" \
        $(echo "sample";   faops n50 -H -S -C 2_illumina/R1.sample.fq.gz;) >> stat.md
fi
if [ -e 2_illumina/R1.scythe.fq.gz ]; then
    printf "| %s | %s | %s | %s |\n" \
        $(echo "scythe";  faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz;) >> stat.md
fi

parallel --no-run-if-empty -k -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo Q{1}L{2};
            faops n50 -H -S -C \
                2_illumina/Q{1}L{2}/R1.sickle.fq.gz;
        )
    " ::: ${READ_QUAL} ::: ${READ_LEN} \
    >> stat.md

cat stat.md

```

| Name     |     N50 |       Sum |       # |
|:---------|--------:|----------:|--------:|
| Genome   | 4641652 |   4641652 |       1 |
| Paralogs |    1934 |    195673 |     106 |
| Illumina |     151 | 865149970 | 5729470 |
| uniq     |     151 | 717622215 | 4752465 |
| shuffle  |     151 | 717622215 | 4752465 |
| scythe   |     151 | 715942404 | 4752465 |
| Q25L60   |     151 | 603356181 | 4434322 |
| Q30L60   |     138 | 520273582 | 4122960 |

## Quorum

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

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

    anchr quorum \
        R1.sickle.fq.gz \
        -p 16 \
        -o quorum.sh

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

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 607.79M | 130.9 | 560.27M |  120.7 |   7.818% |     137 | "31" | 4.64M | 4.57M |     0.98 | 0:02'02'' |
| Q30L60 |  524.4M | 113.0 |  503.4M |  108.5 |   4.003% |     129 | "31" | 4.64M | 4.56M |     0.98 | 0:01'58'' |

## Down sampling

## K-unitigs and anchors (sampled)

| Name          |  SumCor | CovCor | N50Anchor |   Sum |   # | N50Others |    Sum |  # |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|--------:|-------:|----------:|------:|----:|----------:|-------:|---:|--------------------:|----------:|:----------|
| Q25L60X40P000 | 185.67M |   40.0 |     40210 | 4.54M | 185 |       797 | 19.21K | 25 | "31,41,51,61,71,81" | 0:02'58'' | 0:01'08'' |
| Q25L60X40P001 | 185.67M |   40.0 |     41491 | 4.54M | 184 |       797 | 15.23K | 21 | "31,41,51,61,71,81" | 0:02'50'' | 0:01'08'' |
| Q25L60X40P002 | 185.67M |   40.0 |     40099 | 4.54M | 201 |       754 |  19.7K | 27 | "31,41,51,61,71,81" | 0:03'05'' | 0:01'06'' |
| Q25L60X80P000 | 371.33M |   80.0 |     32375 | 4.54M | 245 |       706 | 19.59K | 27 | "31,41,51,61,71,81" | 0:04'26'' | 0:01'16'' |
| Q30L60X40P000 | 185.67M |   40.0 |     41181 | 4.53M | 181 |       812 | 23.32K | 30 | "31,41,51,61,71,81" | 0:02'38'' | 0:01'22'' |
| Q30L60X40P001 | 185.67M |   40.0 |     43292 | 4.53M | 177 |       754 | 21.05K | 29 | "31,41,51,61,71,81" | 0:02'53'' | 0:01'22'' |
| Q30L60X80P000 | 371.33M |   80.0 |     49172 | 4.53M | 166 |       754 | 20.76K | 27 | "31,41,51,61,71,81" | 0:03'03'' | 0:01'01'' |

## Merge anchors

## Clear intermediate files

