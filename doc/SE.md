# Single End

[TOC levels=1-3]: # " "
- [Single End](#single-end)
- [*Escherichia coli* str. K-12 substr. MG1655](#escherichia-coli-str-k-12-substr-mg1655)
    - [SE: download](#se-download)
    - [SE: run](#se-run)


# *Escherichia coli* str. K-12 substr. MG1655

* Genome: INSDC [U00096.3](https://www.ncbi.nlm.nih.gov/nuccore/U00096.3)
* Taxonomy ID: [511145](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=511145)
* Proportion of paralogs (> 1000 bp): 0.0323

## SE: download

* Settings

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=SE

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

## SE: run

```bash
rsync -avP ~/data/anchr/SE/ wangq@202.119.37.251:data/anchr/SE

# rsync -avP wangq@202.119.37.251:data/anchr/SE/ ~/data/anchr/SE

```

```bash
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=SE

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --se \
    --basename ${BASE_NAME} \
    --genome 4641652 \
    --trim2 "--uniq --shuffle " \
    --cov2 "40 80 all" \
    --qual2 "25 30" \
    --len2 "60" \
    --parallel 24

# run
bsub -q largemem -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"

bsub -w "done(${BASE_NAME}-0_master)" \
    -q largemem -n 24 -J "${BASE_NAME}-0_cleanup" "bash 0_cleanup.sh"

```

| Name     |     N50 |     Sum |       # |
|:---------|--------:|--------:|--------:|
| Genome   | 4641652 | 4641652 |       1 |
| Paralogs |    1934 |  195673 |     106 |
| Illumina |     151 | 865.15M | 5729470 |
| uniq     |     151 | 717.62M | 4752465 |
| shuffle  |     151 | 717.62M | 4752465 |
| Q25L60   |     151 | 603.67M | 4435307 |
| Q30L60   |     138 | 520.44M | 4123618 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 131.0 |  120.6 |    7.94% |     138 | "31" | 4.64M | 4.57M |     0.98 | 0:01'17'' |
| Q30L60 | 113.0 |  108.4 |    4.10% |     129 | "31" | 4.64M | 4.56M |     0.98 | 0:01'04'' |

| Name           | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |   Sum | # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|----:|----------:|------:|--:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  98.67% |     41912 | 4.53M | 183 |      1054 | 1.05K | 1 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'59'' |
| Q25L60X40P001  |   40.0 |  98.73% |     40910 | 4.53M | 183 |      1054 | 5.93K | 5 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'59'' |
| Q25L60X40P002  |   40.0 |  98.66% |     41329 | 4.52M | 189 |      1130 | 6.25K | 5 |   39.0 | 1.0 |  12.0 |  63.0 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'57'' |
| Q25L60X80P000  |   80.0 |  98.52% |     31293 | 4.53M | 237 |      1480 | 5.11K | 4 |   79.0 | 2.0 |  24.3 | 127.5 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'56'' |
| Q25L60XallP000 |  120.6 |  98.41% |     30633 | 4.53M | 257 |      1703 | 6.88K | 5 |  119.0 | 3.0 |  36.7 | 192.0 | "31,41,51,61,71,81" | 0:01'57'' | 0:00'58'' |
| Q30L60X40P000  |   40.0 |  98.86% |     44646 | 4.53M | 176 |      1079 | 6.03K | 5 |   39.0 | 1.5 |  11.5 |  65.2 | "31,41,51,61,71,81" | 0:00'51'' | 0:01'03'' |
| Q30L60X40P001  |   40.0 |  98.86% |     41329 | 4.53M | 181 |      1563 | 6.66K | 5 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'52'' | 0:01'02'' |
| Q30L60X80P000  |   80.0 |  98.88% |     48132 | 4.53M | 165 |      1501 | 5.37K | 4 |   79.0 | 3.0 |  23.3 | 132.0 | "31,41,51,61,71,81" | 0:01'21'' | 0:01'06'' |
| Q30L60XallP000 |  108.4 |  98.87% |     49198 | 4.53M | 158 |      1700 | 8.63K | 5 |  107.0 | 3.0 |  32.7 | 174.0 | "31,41,51,61,71,81" | 0:01'44'' | 0:01'07'' |

| Name                   |     N50 |     Sum |   # |
|:-----------------------|--------:|--------:|----:|
| Genome                 | 4641652 | 4641652 |   1 |
| Paralogs               |    1934 |  195673 | 106 |
| anchors                |   63440 | 4532169 | 123 |
| others                 |    1096 |   68234 |  61 |
| anchorLong             |       0 |       0 |   0 |
| anchorFill             |       0 |       0 |   0 |
| spades.contig          |   97656 | 4646773 | 272 |
| spades.scaffold        |  112078 | 4647273 | 267 |
| spades.non-contained   |  106190 | 4575960 | 104 |
| platanus.contig        |   43810 | 4612793 | 837 |
| platanus.non-contained |   44625 | 4523974 | 188 |
