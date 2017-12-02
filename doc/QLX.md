# Quality, length and Coverage

[TOC levels=1-3]: # " "
- [Quality, length and Coverage](#quality-length-and-coverage)
- [*Escherichia coli* str. K-12 substr. MG1655](#escherichia-coli-str-k-12-substr-mg1655)
    - [Download](#download)
    - [Preprocess Illumina reads](#preprocess-illumina-reads)
    - [Reads stats](#reads-stats)
    - [Quorum](#quorum)
    - [Down sampling](#down-sampling)
    - [K-unitigs and anchors (sampled)](#k-unitigs-and-anchors-sampled)
    - [Merge anchors with Qxx, Lxx and QxxLxx](#merge-anchors-with-qxx-lxx-and-qxxlxx)
    - [Clear intermediate files](#clear-intermediate-files)


# *Escherichia coli* str. K-12 substr. MG1655

* Genome: INSDC
  [U00096.3](https://www.ncbi.nlm.nih.gov/nuccore/U00096.3)
* Taxonomy ID:
  [511145](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=511145)
* Proportion of paralogs (> 1000 bp): 0.0323

## Download

* Settings

```bash
BASE_NAME=QLX
REAL_G=4641652
COVERAGE2="20 30 40 50 60 80 120 160 200"
READ_QUAL="15 20 25 30 35"
READ_LEN="30 60 90"

```

* Reference genome

    * Strain: Bacillus cereus ATCC 10987
    * Taxid: [222523](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=222523)
    * RefSeq assembly accession:
      [GCF_000008005.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/005/GCF_000008005.1_ASM800v1/GCF_000008005.1_ASM800v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0797

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
ln -sf ${HOME}/data/anchr/e_coli/2_illumina/MiSeq_Ecoli_MG1655_110721_PF_R2.fastq.gz R2.fq.gz

cat <<EOF > illumina_adapters.fa
>multiplexing-forward
GATCGGAAGAGCACACGTCT
>solexa-forward
AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
>truseq-forward-contam
AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
>truseq-reverse-contam
AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTA
>nextera-forward-read-contam
CTGTCTCTTATACACATCTCCGAGCCCACGAGAC
>nextera-reverse-read-contam
CTGTCTCTTATACACATCTGACGCTGCCGACGA
>solexa-reverse
AGATCGGAAGAGCGGTTCAGCAGGAATGCCGAG

EOF

```

## Preprocess Illumina reads

* kmc

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/kmc
cd 2_illumina/kmc

# raw
cat <<EOF > list.tmp
../R1.fq.gz
../R2.fq.gz

EOF

kmc -k51 -n100 -ci3 @list.tmp raw . 
kmc_tools transform raw histogram hist.raw.txt

# uniq
cat <<EOF > list.tmp
../R1.uniq.fq.gz
../R2.uniq.fq.gz

EOF

kmc -k51 -n100 -ci3 @list.tmp uniq . 
kmc_tools transform uniq histogram hist.uniq.txt

# Q25L60
cat <<EOF > list.tmp
../Q25L60/R1.fq.gz
../Q25L60/R2.fq.gz

EOF

kmc -k51 -n100 -ci1 @list.tmp Q25L60 . 
kmc_tools transform Q25L60 histogram hist.Q25L60.txt

#kmc_tools transform Q25L60 dump dump.Q25L60.txt

kmc_tools filter Q25L60 @list.tmp -ci3 filtered.fa -fa

faops n50 -H -S -C \
    ../Q25L60/R1.fq.gz \
    ../Q25L60/R2.fq.gz;
    
faops n50 -H -S -C \
    ../Q25L60/pe.cor.fa;

faops n50 -H -S -C \
    filtered.fa;

```

## Reads stats

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 4641652 |    4641652 |        1 |
| Paralogs |    1934 |     195673 |      106 |
| Illumina |     151 | 1730299940 | 11458940 |
| uniq     |     151 | 1727289000 | 11439000 |
| shuffle  |     151 | 1727289000 | 11439000 |
| scythe   |     151 | 1722450607 | 11439000 |
| Q15L30   |     151 | 1605703103 | 11288436 |
| Q15L60   |     151 | 1575519248 | 10949858 |
| Q15L90   |     151 | 1510984308 | 10345828 |
| Q20L30   |     151 | 1514584050 | 11126596 |
| Q20L60   |     151 | 1468709458 | 10572422 |
| Q20L90   |     151 | 1370119196 |  9617554 |
| Q25L30   |     151 | 1382782641 | 10841386 |
| Q25L60   |     151 | 1317617346 |  9994728 |
| Q25L90   |     151 | 1177142378 |  8586574 |
| Q30L30   |     125 | 1192536117 | 10716954 |
| Q30L60   |     127 | 1149107745 |  9783292 |
| Q30L90   |     130 | 1021609911 |  8105773 |
| Q35L30   |      64 |  588252718 |  9588363 |
| Q35L60   |      72 |  366922898 |  5062192 |
| Q35L90   |      95 |   35259773 |   364046 |

## Quorum

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q15L30 |   1.61G | 345.9 |   1.25G |  268.8 |  22.284% |     142 | "75" | 4.64M | 5.52M |     1.19 | 0:04'57'' |
| Q15L60 |   1.58G | 339.4 |   1.23G |  264.1 |  22.186% |     143 | "75" | 4.64M | 5.47M |     1.18 | 0:04'24'' |
| Q15L90 |   1.51G | 325.5 |   1.18G |  254.0 |  21.975% |     146 | "75" | 4.64M | 5.35M |     1.15 | 0:04'08'' |
| Q20L30 |   1.51G | 326.3 |   1.32G |  284.1 |  12.941% |     136 | "65" | 4.64M | 4.85M |     1.04 | 0:04'06'' |
| Q20L60 |   1.47G | 316.4 |   1.28G |  275.6 |  12.888% |     139 | "65" | 4.64M | 4.82M |     1.04 | 0:04'02'' |
| Q20L90 |   1.37G | 295.2 |   1.19G |  256.8 |  13.001% |     143 | "95" | 4.64M | 4.69M |     1.01 | 0:03'54'' |
| Q25L30 |   1.38G | 297.9 |    1.3G |  280.6 |   5.808% |     129 | "57" | 4.64M | 4.59M |     0.99 | 0:03'54'' |
| Q25L60 |   1.32G | 283.9 |   1.24G |  267.4 |   5.801% |     133 | "83" | 4.64M | 4.58M |     0.99 | 0:03'50'' |
| Q25L90 |   1.18G | 253.6 |   1.11G |  238.8 |   5.832% |     137 | "89" | 4.64M | 4.57M |     0.99 | 0:03'12'' |
| Q30L30 |   1.19G | 257.0 |   1.16G |  250.7 |   2.437% |     115 | "65" | 4.64M | 4.56M |     0.98 | 0:03'25'' |
| Q30L60 |   1.15G | 247.7 |   1.12G |  241.6 |   2.484% |     120 | "71" | 4.64M | 4.56M |     0.98 | 0:03'16'' |
| Q30L90 |   1.02G | 220.4 | 996.45M |  214.7 |   2.605% |     128 | "79" | 4.64M | 4.56M |     0.98 | 0:02'54'' |
| Q35L30 | 589.03M | 126.9 | 582.15M |  125.4 |   1.169% |      62 | "37" | 4.64M | 4.56M |     0.98 | 0:01'51'' |
| Q35L60 | 369.07M |  79.5 | 362.78M |   78.2 |   1.705% |      73 | "45" | 4.64M | 4.51M |     0.97 | 0:01'29'' |
| Q35L90 |  35.58M |   7.7 |  32.82M |    7.1 |   7.770% |      98 | "65" | 4.64M | 2.03M |     0.44 | 0:00'32'' |

## Down sampling

## K-unitigs and anchors (sampled)

## Merge anchors with Qxx, Lxx and QxxLxx

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

# merge anchors with Qxx
for Q in ${READ_QUAL}; do
    mkdir -p mergeQ${Q}
    anchr contained \
        $(
            parallel -k --no-run-if-empty -j 6 '
                if [ -e Q{1}L{2}X{3}P{4}/anchor/anchor.fasta ]; then
                    echo Q{1}L{2}X{3}P{4}/anchor/anchor.fasta
                fi
                ' ::: ${Q} :::  ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})
        ) \
        --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
        -o stdout \
        | faops filter -a 1000 -l 0 stdin mergeQ${Q}/anchor.contained.fasta
    anchr orient mergeQ${Q}/anchor.contained.fasta --len 1000 --idt 0.98 -o mergeQ${Q}/anchor.orient.fasta
    anchr merge mergeQ${Q}/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
        | faops filter -a 1000 -l 0 stdin mergeQ${Q}/anchor.merge.fasta
done

# merge anchors with Lxx
for L in ${READ_LEN}; do
    mkdir -p mergeL${L}
    anchr contained \
        $(
            parallel -k --no-run-if-empty -j 6 '
                if [ -e Q{1}L{2}X{3}P{4}/anchor/anchor.fasta ]; then
                    echo Q{1}L{2}X{3}P{4}/anchor/anchor.fasta
                fi
                ' ::: ${READ_QUAL} ::: ${L} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})
        ) \
        --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
        -o stdout \
        | faops filter -a 1000 -l 0 stdin mergeL${L}/anchor.contained.fasta
    anchr orient mergeL${L}/anchor.contained.fasta --len 1000 --idt 0.98 -o mergeL${L}/anchor.orient.fasta
    anchr merge mergeL${L}/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
        | faops filter -a 1000 -l 0 stdin mergeL${L}/anchor.merge.fasta
done

# quast
rm -fr 9_qa_mergeQL
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    mergeQ25/anchor.merge.fasta \
    mergeQ30/anchor.merge.fasta \
    mergeQ35/anchor.merge.fasta \
    mergeL30/anchor.merge.fasta \
    mergeL60/anchor.merge.fasta \
    mergeL90/anchor.merge.fasta \
    1_genome/paralogs.fas \
    --label "mergeQ25,mergeQ30,mergeQ35,mergeL30,mergeL60,mergeL90,paralogs" \
    -o 9_qa_mergeQL

# merge anchors with QxxLxx
for Q in ${READ_QUAL}; do
    for L in ${READ_LEN}; do
        mkdir -p mergeQ${Q}L${L}
        anchr contained \
            $(
                parallel -k --no-run-if-empty -j 6 '
                    if [ -e Q{1}L{2}X{3}P{4}/anchor/anchor.fasta ]; then
                        echo Q{1}L{2}X{3}P{4}/anchor/anchor.fasta
                    fi
                    ' ::: ${Q} ::: ${L} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})
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
rm -fr 9_qa_mergeQxxLxx
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    $( parallel -k 'printf "mergeQ{1}L{2}/anchor.merge.fasta "' ::: ${READ_QUAL} ::: ${READ_LEN} ) \
    1_genome/paralogs.fas \
    --label "$( parallel -k 'printf "mergeQ{1}L{2},"' ::: ${READ_QUAL} ::: ${READ_LEN} )paralogs" \
    -o 9_qa_mergeQxxLxx

# merge anchors with QxxXxx
for Q in ${READ_QUAL}; do
    for X in ${COVERAGE2}; do
        mkdir -p mergeQ${Q}X${X}
        anchr contained \
            $(
                parallel -k --no-run-if-empty -j 6 '
                    if [ -e Q{1}L{2}X{3}P{4}/anchor/anchor.fasta ]; then
                        echo Q{1}L{2}X{3}P{4}/anchor/anchor.fasta
                    fi
                    ' ::: ${Q} ::: 60 ::: ${X} ::: $(printf "%03d " {0..100})
            ) \
            --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
            -o stdout \
            | faops filter -a 1000 -l 0 stdin mergeQ${Q}X${X}/anchor.contained.fasta
        anchr orient mergeQ${Q}X${X}/anchor.contained.fasta --len 1000 --idt 0.98 -o mergeQ${Q}X${X}/anchor.orient.fasta
        anchr merge mergeQ${Q}X${X}/anchor.orient.fasta --len 1000 --idt 0.999 -o mergeQ${Q}X${X}/anchor.merge0.fasta
        anchr contained mergeQ${Q}X${X}/anchor.merge0.fasta --len 1000 --idt 0.98 \
            --proportion 0.99 --parallel 16 -o stdout \
            | faops filter -a 1000 -l 0 stdin mergeQ${Q}X${X}/anchor.merge.fasta
    done
done

# quast
rm -fr 9_qa_mergeQxxXxx
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    $( parallel -k 'printf "mergeQ{1}X{2}/anchor.merge.fasta "' ::: ${READ_QUAL} ::: ${COVERAGE2} ) \
    1_genome/paralogs.fas \
    --label "$( parallel -k 'printf "mergeQ{1}X{2},"' ::: ${READ_QUAL} ::: ${COVERAGE2} )paralogs" \
    -o 9_qa_mergeQxxXxx

```

## Clear intermediate files


## Preprocess Illumina single end reads

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

# symlink R1.fq.gz
mkdir -p 2_illumina_se
cd 2_illumina_se
ln -s ../2_illumina/MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz R1.fq.gz

cd ${HOME}/data/anchr/${BASE_NAME}

if [ ! -e 2_illumina_se/R1.uniq.fq.gz ]; then
    tally \
        --with-quality --nozip --unsorted \
        -i 2_illumina_se/R1.fq.gz \
        -o 2_illumina_se/R1.uniq.fq

    pigz -p 8 2_illumina_se/R1.uniq.fq
fi

# get the default adapter file
# anchr trim --help
if [ ! -e 2_illumina_se/R1.scythe.fq.gz ]; then
    scythe \
        2_illumina_se/R1.uniq.fq.gz \
        -q sanger \
        -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
        --quiet \
        | pigz -p 4 -c \
        > 2_illumina_se/R1.scythe.fq.gz
fi

if [ ! -e 2_illumina_se/R1.shuffle.fq.gz ]; then
    shuffle.sh \
        in=2_illumina_se/R1.scythe.fq.gz \
        out=2_illumina_se/R1.shuffle.fq

    pigz -p 8 2_illumina_se/R1.shuffle.fq
fi

parallel --no-run-if-empty --linebuffer -k -j 3 "
    mkdir -p 2_illumina_se/Q{1}L{2}
    cd 2_illumina_se/Q{1}L{2}

    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        --noscythe \
        -q {1} -l {2} \
        ../R1.shuffle.fq.gz \
        -o stdout \
        | bash
    " ::: ${READ_QUAL} ::: ${READ_LEN}

```

## miniasm

    * `-S         skip self and dual mappings`
    * `-w INT     minizer window size [{-k}*2/3]`
    * `-L INT     min matching length [40]`
    * `-m FLOAT   merge two chains if FLOAT fraction of minimizers are shared [0.50]`
    * `-t INT     number of threads [3]`

```bash
BASE_NAME=e_coli
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p miniasm

minimap -Sw5 -L100 -m0 -t16 \
    3_pacbio/pacbio.40x.fasta 3_pacbio/pacbio.40x.fasta \
    > miniasm/pacbio.40x.paf

miniasm miniasm/pacbio.40x.paf > miniasm/utg.noseq.gfa

miniasm -f 3_pacbio/pacbio.40x.fasta miniasm/pacbio.40x.paf \
    > miniasm/utg.gfa

awk '/^S/{print ">"$2"\n"$3}' miniasm/utg.gfa > miniasm/utg.fa

minimap 1_genome/genome.fa miniasm/utg.fa | minidot - > miniasm/utg.eps
```

```bash
#real    0m19.504s
#user    1m11.237s
#sys     0m18.500s
time anchr paf2ovlp --parallel 16 miniasm/pacbio.40x.paf -o miniasm/pacbio.40x.ovlp.tsv

#real    0m19.451s
#user    0m43.343s
#sys     0m9.734s
time anchr paf2ovlp --parallel 4 miniasm/pacbio.40x.paf -o miniasm/pacbio.40x.ovlp.tsv

#real    0m17.324s
#user    0m9.276s
#sys     1m23.833s
time jrange covered miniasm/pacbio.40x.paf --longest --paf -o miniasm/pacbio.40x.pos.txt
```

## Local corrections

```bash
BASE_NAME=e_coli
REAL_G=4641652
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr localCor
anchr overlap2 \
    --parallel 16 \
    merge/anchor.merge.fasta \
    3_pacbio/pacbio.40x.trim.fasta \
    -d localCor \
    -b 10 --len 1000 --idt 0.85 --all

pushd localCor

anchr cover \
    --range "1-$(faops n50 -H -N 0 -C anchor.fasta)" \
    --len 1000 --idt 0.85 -c 2 \
    anchorLong.ovlp.tsv \
    -o anchor.cover.json
cat anchor.cover.json | jq "." > environment.json

rm -fr group
anchr localcor \
    anchorLong.db \
    anchorLong.ovlp.tsv \
    --parallel 16 \
    --range $(cat environment.json | jq -r '.TRUSTED') \
    --len 1000 --idt 0.85 --trim -v

faops some -i -l 0 \
    long.fasta \
    group/overlapped.long.txt \
    independentLong.fasta

# localCor
gzip -d -c -f $(find group -type f -name "*.correctedReads.fasta.gz") \
    | faops filter -l 0 stdin stdout \
    | grep -E '^>long' -A 1 \
    | sed '/^--$/d' \
    | faops dazz -a -l 0 stdin stdout \
    | pigz -c > localCor.fasta.gz

canu \
    -p ${BASE_NAME} -d localCor \
    gnuplotTested=true \
    genomeSize=${REAL_G} \
    -pacbio-corrected localCor.fasta.gz \
    -pacbio-corrected anchor.fasta

canu \
    -p ${BASE_NAME} -d localCorIndep \
    gnuplotTested=true \
    genomeSize=${REAL_G} \
    -pacbio-raw localCor.fasta.gz \
    -pacbio-raw anchor.fasta \
    -pacbio-raw independentLong.fasta

# localTrim
gzip -d -c -f $(find group -type f -name "*.trimmedReads.fasta.gz") \
    | faops filter -l 0 stdin stdout \
    | grep -E '^>long' -A 1 \
    | sed '/^--$/d' \
    | faops dazz -a -l 0 stdin stdout \
    | pigz -c > localTrim.fasta.gz

canu \
    -p ${BASE_NAME} -d localTrim \
    gnuplotTested=true \
    genomeSize=${REAL_G} \
    -pacbio-corrected localCor.fasta.gz \
    -pacbio-corrected anchor.fasta

# globalTrim
canu -assemble \
    -p ${BASE_NAME} -d globalTrim \
    gnuplotTested=true \
    genomeSize=${REAL_G} \
    -pacbio-corrected ../canu-raw-40x/${BASE_NAME}.trimmedReads.fasta.gz \
    -pacbio-corrected anchor.fasta

popd

# quast
rm -fr 9_qa_localCor
quast --no-check --threads 16 \
    --eukaryote \
    -R 1_genome/genome.fa \
    localCor/anchor.fasta \
    localCor/localCor/${BASE_NAME}.contigs.fasta \
    localCor/localCorIndep/${BASE_NAME}.contigs.fasta \
    localCor/localTrim/${BASE_NAME}.contigs.fasta \
    localCor/globalTrim/${BASE_NAME}.contigs.fasta \
    canu-raw-40x/${BASE_NAME}.contigs.fasta \
    canu-trim-40x/${BASE_NAME}.contigs.fasta \
    1_genome/paralogs.fas \
    --label "anchor,localCor,localCorIndep,localTrim,globalTrim,40x,40x.trim,paralogs" \
    -o 9_qa_localCor

find . -type d -name "correction" | xargs rm -fr

```
