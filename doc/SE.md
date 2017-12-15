# Single End

[TOC levels=1-3]: # " "
- [Single End](#single-end)
- [*Escherichia coli* str. K-12 substr. MG1655](#escherichia-coli-str-k-12-substr-mg1655)
    - [SE: download](#se-download)
    - [SE: template](#se-template)
    - [SE: preprocessing](#se-preprocessing)
    - [SE: spades](#se-spades)
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
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=SE
REAL_G=4641652
IS_EUK="false"
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

cp ../../e_coli/2_illumina/MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz R1.fq.gz

```

## SE: template

```bash
rsync -avP ~/data/anchr/SE/ wangq@202.119.37.251:data/anchr/SE

```

```bash
cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --se \
    --basename ${BASE_NAME} \
    --genome ${REAL_G} \
    --trim2 "--uniq --shuffle --scythe " \
    --coverage2 "40 80" \
    --qual2 "25 30" \
    --len2 "60" \
    --parallel 24

```

## SE: preprocessing

```bash
cd ${WORKING_DIR}/${BASE_NAME}

# Illumina QC
bsub -q largemem -n 24 -J "${BASE_NAME}-2_fastqc" "bash 2_fastqc.sh"
bsub -q largemem -n 24 -J "${BASE_NAME}-2_kmergenie" "bash 2_kmergenie.sh"

# preprocess Illumina reads
bsub -q largemem -n 24 -J "${BASE_NAME}-2_trim" "bash 2_trim.sh"

# reads stats
# execute after 2_trim finished
bsub -w "done(${BASE_NAME}-2_trim)" \
    -q largemem -n 24 -J "${BASE_NAME}-23_statReads" "bash 23_statReads.sh"

```

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 4641652 | 4641652 |       1 |
| Paralogs |    1934 |  195673 |     106 |
| Illumina |     151 | 865.15M | 5729470 |
| uniq     |     151 | 717.62M | 4752465 |
| shuffle  |     151 | 717.62M | 4752465 |
| scythe   |     151 | 715.94M | 4752465 |
| Q25L60   |     151 | 603.36M | 4434322 |
| Q30L60   |     138 | 520.27M | 4122960 |

## SE: spades

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

spades.py \
    -t 16 \
    -k 21,33,55,77 \
    -s 2_illumina/Q25L60/R1.sickle.fq.gz \
    -o 8_spades

anchr contained \
    8_spades/contigs.fasta \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin 8_spades/contigs.non-contained.fasta

```

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

| Name          |  SumCor | CovCor | N50Anchor |   Sum |   # | N50Others |    Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|--------:|-------:|----------:|------:|----:|----------:|-------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000 | 185.67M |   40.0 |     40210 | 4.53M | 189 |       812 | 19.08K | 25 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:02'19'' | 0:01'02'' |
| Q25L60X40P001 | 185.67M |   40.0 |     41181 | 4.53M | 195 |       848 | 23.93K | 28 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:02'16'' | 0:01'05'' |
| Q25L60X40P002 | 185.67M |   40.0 |     39149 | 4.53M | 185 |       797 | 17.34K | 23 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:02'16'' | 0:01'03'' |
| Q25L60X80P000 | 371.33M |   80.0 |     32791 | 4.53M | 233 |       812 | 19.38K | 25 |   79.0 | 3.0 |  23.3 | 132.0 | "31,41,51,61,71,81" | 0:03'26'' | 0:01'07'' |
| Q30L60X40P000 | 185.67M |   40.0 |     44636 | 4.53M | 178 |       797 | 24.74K | 32 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:02'07'' | 0:01'08'' |
| Q30L60X40P001 | 185.67M |   40.0 |     40910 | 4.53M | 185 |       812 | 26.58K | 33 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:02'09'' | 0:01'10'' |
| Q30L60X80P000 | 371.33M |   80.0 |     49172 | 4.53M | 163 |      1054 | 32.35K | 29 |   79.0 | 3.0 |  23.3 | 132.0 | "31,41,51,61,71,81" | 0:02'33'' | 0:01'13'' |

## SE: merge anchors

## SE: final stats

* Stats

| Name                 |     N50 |     Sum |   # |
|:---------------------|--------:|--------:|----:|
| Genome               | 4641652 | 4641652 |   1 |
| Paralogs             |    1934 |  195673 | 106 |
| anchor               |   63171 | 4532654 | 126 |
| others               |     847 |   39054 |  49 |
| spades.contig        |  106190 | 4646950 | 258 |
| spades.scaffold      |  112078 | 4647450 | 253 |
| spades.non-contained |  106190 | 4583351 | 108 |

* quast

## SE: clear intermediate files

