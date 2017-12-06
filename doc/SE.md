# Single End

[TOC levels=1-3]: # " "
- [Single End](#single-end)
- [*Escherichia coli* str. K-12 substr. MG1655](#escherichia-coli-str-k-12-substr-mg1655)
    - [SE: download](#se-download)
    - [SE: preprocess Illumina reads](#se-preprocess-illumina-reads)
    - [SE: reads stats](#se-reads-stats)
    - [SE: quorum](#se-quorum)
    - [SE: adapter filtering](#se-adapter-filtering)
    - [SE: down sampling](#se-down-sampling)
    - [SE: k-unitigs and anchors (sampled)](#se-k-unitigs-and-anchors-sampled)
    - [SE: merge anchors](#se-merge-anchors)
    - [SE: final stats](#se-final-stats)
    - [SE: clear intermediate files](#se-clear-intermediate-files)


# *Escherichia coli* str. K-12 substr. MG1655

* Genome: INSDC [U00096.3](https://www.ncbi.nlm.nih.gov/nuccore/U00096.3)
* Taxonomy ID: [511145](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=511145)
* Proportion of paralogs (> 1000 bp): 0.0323

## SE: download

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

## SE: preprocess Illumina reads

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

## SE: reads stats

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

## SE: quorum

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
| Q25L60 | 607.79M | 130.9 | 560.27M |  120.7 |   7.818% |     138 | "31" | 4.64M | 4.57M |     0.98 | 0:01'36'' |
| Q30L60 |  524.4M | 113.0 |  503.4M |  108.5 |   4.003% |     128 | "31" | 4.64M | 4.56M |     0.98 | 0:01'25'' |

## SE: adapter filtering

```text
#File	2_illumina/Q25L60/pe.cor.raw
#Total	4126622
#Matched	8	0.00019%
#Name	Reads	ReadsPct
RNA_PCR_Primer_Index_48_(RPI48)	2	0.00005%
TruSeq_Adapter_Index_13	2	0.00005%
TruSeq_Adapter_Index_3	1	0.00002%
TruSeq_Adapter_Index_14	1	0.00002%
I7_Primer_Nextera_XT_Index_Kit_v2_N721	1	0.00002%
TruSeq_Adapter_Index_22	1	0.00002%

```

## SE: down sampling

## SE: k-unitigs and anchors (sampled)

| Name          |  SumCor | CovCor | N50Anchor |   Sum |   # | N50Others |    Sum |  # |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|--------:|-------:|----------:|------:|----:|----------:|-------:|---:|--------------------:|----------:|:----------|
| Q25L60X40P000 | 185.67M |   40.0 |     40210 | 4.53M | 190 |       754 | 17.52K | 24 | "31,41,51,61,71,81" | 0:02'19'' | 0:01'10'' |
| Q25L60X40P001 | 185.67M |   40.0 |     41181 | 4.53M | 197 |       812 | 19.55K | 25 | "31,41,51,61,71,81" | 0:02'16'' | 0:01'11'' |
| Q25L60X40P002 | 185.67M |   40.0 |     39149 | 4.53M | 185 |       754 |  16.1K | 22 | "31,41,51,61,71,81" | 0:02'16'' | 0:01'11'' |
| Q25L60X80P000 | 371.33M |   80.0 |     32791 | 4.53M | 233 |       812 | 19.38K | 25 | "31,41,51,61,71,81" | 0:03'26'' | 0:01'15'' |
| Q30L60X40P000 | 185.67M |   40.0 |     44636 | 4.53M | 179 |       765 | 23.17K | 31 | "31,41,51,61,71,81" | 0:02'07'' | 0:01'12'' |
| Q30L60X40P001 | 185.67M |   40.0 |     40910 | 4.53M | 186 |       797 | 24.96K | 32 | "31,41,51,61,71,81" | 0:02'09'' | 0:01'13'' |
| Q30L60X80P000 | 371.33M |   80.0 |     49172 | 4.53M | 164 |       976 | 30.79K | 28 | "31,41,51,61,71,81" | 0:02'33'' | 0:01'20'' |

## SE: merge anchors

## SE: final stats

| Name     |     N50 |     Sum |   # |
|:---------|--------:|--------:|----:|
| Genome   | 4641652 | 4641652 |   1 |
| Paralogs |    1934 |  195673 | 106 |
| anchor   |   63476 | 4531207 | 122 |
| others   |     947 |   46487 |  46 |

## SE: clear intermediate files
