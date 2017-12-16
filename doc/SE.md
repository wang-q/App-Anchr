# Single End

[TOC levels=1-3]: # " "
- [Single End](#single-end)
- [*Escherichia coli* str. K-12 substr. MG1655](#escherichia-coli-str-k-12-substr-mg1655)
    - [SE: download](#se-download)
    - [SE: template](#se-template)
    - [SE: preprocessing](#se-preprocessing)
    - [SE: spades](#se-spades)
    - [SE: quorum](#se-quorum)
    - [SE: down sampling, k-unitigs and anchors](#se-down-sampling-k-unitigs-and-anchors)
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

```

* Reference genome

```bash
mkdir -p ${WORKING_DIR}/${BASE_NAME}/1_genome
cd ${WORKING_DIR}/${BASE_NAME}/1_genome

cp ../../e_coli/1_genome/genome.fa .
cp ../../e_coli/1_genome/paralogs.fas .

```

* Illumina

```bash
mkdir -p ${WORKING_DIR}/${BASE_NAME}/2_illumina
cd ${WORKING_DIR}/${BASE_NAME}/2_illumina

cp ../../e_coli/2_illumina/MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz R1.fq.gz

```

* PacBio

```bash
mkdir -p ${WORKING_DIR}/${BASE_NAME}/3_pacbio
cd ${WORKING_DIR}/${BASE_NAME}/3_pacbio

cp ../../e_coli/3_pacbio/pacbio.fasta .

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
    --coverage2 "40 80 all" \
    --qual2 "25 30" \
    --len2 "60" \
    --coverage3 "40 80" \
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

# preprocess PacBio reads
bsub -q largemem -n 24 -J "${BASE_NAME}-3_trimlong" "bash 3_trimlong.sh"

# reads stats
bsub -w "done(${BASE_NAME}-2_trim) && done(${BASE_NAME}-3_trimlong)" \
    -q largemem -n 24 -J "${BASE_NAME}-9_statReads" "bash 9_statReads.sh"

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
| PacBio   |   13982 | 748.51M |   87225 |
| X40.raw  |   14030 | 185.68M |   22336 |
| X40.trim |   13702 | 169.38M |   19468 |
| X80.raw  |   13990 | 371.34M |   44005 |
| X80.trim |   13632 | 339.51M |   38725 |

## SE: quorum

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bsub -q largemem -n 24 -J "${BASE_NAME}-2_quorum" "bash 2_quorum.sh"

bsub -w "done(${BASE_NAME}-2_quorum)" \
    -q largemem -n 24 -J "${BASE_NAME}-9_statQuorum" "bash 9_statQuorum.sh"

```

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 130.9 |  120.7 |   7.819% |     138 | "31" | 4.64M | 4.57M |     0.98 | 0:00'49'' |
| Q30L60 | 113.0 |  108.5 |   4.003% |     128 | "31" | 4.64M | 4.56M |     0.98 | 0:01'04'' |

* adapter filtering

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

## SE: down sampling, k-unitigs and anchors

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bsub -q largemem -n 24 -J "${BASE_NAME}-4_downSampling" "bash 4_downSampling.sh"

bsub -w "done(${BASE_NAME}-4_downSampling)" \
    -q largemem -n 24 -J "${BASE_NAME}-4_kunitigs" "bash 4_kunitigs.sh"

bsub -w "done(${BASE_NAME}-4_kunitigs)" \
    -q largemem -n 24 -J "${BASE_NAME}-4_anchors" "bash 4_anchors.sh"

bsub -w "done(${BASE_NAME}-4_anchors)" \
    -q largemem -n 24 -J "${BASE_NAME}-9_statAnchors" "bash 9_statAnchors.sh"

```

| Name           | CovCor | N50Anchor |   Sum |   # | N50Others |    Sum |  # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|----------:|------:|----:|----------:|-------:|---:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |     38676 | 4.52M | 199 |       847 | 25.98K | 31 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'00'' | 0:00'57'' |
| Q25L60X40P001  |   40.0 |     41560 | 4.53M | 180 |       861 |  21.7K | 25 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'01'' | 0:00'58'' |
| Q25L60X40P002  |   40.0 |     40210 | 4.53M | 186 |       787 | 19.86K | 26 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'00'' | 0:00'57'' |
| Q25L60X80P000  |   80.0 |     33340 | 4.53M | 235 |       869 | 23.38K | 27 |   79.0 | 2.0 |  24.3 | 127.5 | "31,41,51,61,71,81" | 0:00'01'' | 0:00'55'' |
| Q25L60XallP000 |  120.7 |     30704 | 4.53M | 259 |       848 | 24.05K | 29 |  119.0 | 4.0 |  35.7 | 196.5 | "31,41,51,61,71,81" | 0:01'57'' | 0:00'57'' |
| Q30L60X40P000  |   40.0 |     44646 | 4.52M | 177 |       963 | 34.91K | 36 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'00'' | 0:01'00'' |
| Q30L60X40P001  |   40.0 |     48417 | 4.53M | 169 |       844 | 31.33K | 38 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'01'' | 0:01'01'' |
| Q30L60X80P000  |   80.0 |     50795 | 4.52M | 157 |      1138 | 34.48K | 32 |   79.0 | 3.0 |  23.3 | 132.0 | "31,41,51,61,71,81" | 0:00'01'' | 0:01'03'' |
| Q30L60XallP000 |  108.5 |     49198 | 4.53M | 158 |      1054 | 31.67K | 27 |  107.0 | 3.0 |  32.7 | 174.0 | "31,41,51,61,71,81" | 0:01'43'' | 0:01'06'' |

## SE: merge anchors

```bash
cd ${WORKING_DIR}/${BASE_NAME}

bsub -q largemem -n 24 -J "${BASE_NAME}-6_mergeAnchors" "bash 6_mergeAnchors.sh 4_kunitigs"

# In a local machine
# anchor sort on ref
bash ~/Scripts/cpan/App-Anchr/share/sort_on_ref.sh \
    6_mergeAnchors/anchor.merge.fasta 1_genome/genome.fa 6_mergeAnchors/anchor.sort
nucmer -l 200 1_genome/genome.fa 6_mergeAnchors/anchor.sort.fa
mummerplot --postscript out.delta -p anchor.sort --small

# mummerplot files
rm *.[fr]plot
rm out.delta
rm *.gp
mv anchor.sort.ps 6_mergeAnchors/

```

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
    | faops filter -a 1000 -l 0 stdin 8_spades/spades.non-contained.fasta

```

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

