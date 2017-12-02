# Tuning parameters for the dataset of *E. coli*

[TOC level=1-3]: # " "
- [Tuning parameters for the dataset of *E. coli*](#tuning-parameters-for-the-dataset-of-e-coli)
    - [Local corrections](#local-corrections)


* miniasm

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
