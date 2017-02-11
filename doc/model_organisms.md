# Assemble genomes of model organisms by ANCHR

[TOC]: # " "
- [*E. coli*](#e-coli)
    - [*E. coli*: download](#e-coli-download)
    - [*E. coli*: trim/filter](#e-coli-trimfilter)
    - [*E. coli*: down sampling](#e-coli-down-sampling)
    - [*E. coli*: generate super-reads](#e-coli-generate-super-reads)

## *E. coli*

*Escherichia coli* str. K-12 substr. MG1655

* INSDC: [U00096.3](https://www.ncbi.nlm.nih.gov/nuccore/U00096.3)
* paralogs: 0.0323

* Real:

    * S: 4,641,652

* Original:

    * N50: 151
    * S: 865,149,970
    * C: 5,729,470

* Trimmed, 120-151 bp

    * N50: 151
    * S: 577,015,664
    * C: 3,871,229

* Filter, 151 bp

    * N50: 151
    * S: 371,039,918
    * C: 2,457,218

### *E. coli*: download

```bash
# genome
mkdir -p ~/data/anchr/e_coli/1_genome
cd ~/data/anchr/e_coli/1_genome
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=U00096.3&rettype=fasta&retmode=txt" \
    > U00096.fa
ln -s U00096.fa genome.fa

# illumina
mkdir -p ~/data/anchr/e_coli/2_illumina
cd ~/data/anchr/e_coli/2_illumina
wget -N ftp://webdata:webdata@ussd-ftp.illumina.com/Data/SequencingRuns/MG1655/MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz
wget -N ftp://webdata:webdata@ussd-ftp.illumina.com/Data/SequencingRuns/MG1655/MiSeq_Ecoli_MG1655_110721_PF_R2.fastq.gz

ln -s MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz R1.fq.gz
ln -s MiSeq_Ecoli_MG1655_110721_PF_R2.fastq.gz R2.fq.gz

# pacbio
mkdir -p ~/data/anchr/e_coli/3_pacbio
```

### *E. coli*: trim/filter

* Trimmed: minimal length 120 bp.

```bash
mkdir -p ~/data/anchr/e_coli/2_illumina/trimmed
cd ~/data/anchr/e_coli/2_illumina/trimmed

anchr trim \
    -l 120 -q 20 \
    ../R1.fq.gz ../R2.fq.gz \
    -o stdout \
    | bash
```

* Filter: discard any reads with trimmed parts.

```bash
mkdir -p ~/data/anchr/e_coli/2_illumina/filter
cd ~/data/anchr/e_coli/2_illumina/filter

anchr trim \
    -l 151 -q 20 \
    ../R1.fq.gz ../R2.fq.gz \
    -o stdout \
    | bash
```

* Stats

```bash
cd ~/data/anchr/e_coli

faops n50 -S -C 1_genome/genome.fa
faops n50 -S -C 2_illumina/R1.fq.gz
faops n50 -S -C 2_illumina/trimmed/R1.fq.gz
faops n50 -S -C 2_illumina/filter/R1.fq.gz
```

### *E. coli*: down sampling

过高的 coverage 会造成不好的影响. SGA 的文档里也说了类似的事情.

> Very highly-represented sequences (>1000X) can cause problems for SGA... In these cases, it is
> worth considering pre-filtering the data...

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

# works on bash 3
# http://stackoverflow.com/a/4444841
ARRAY=( "2_illumina:original"
        "2_illumina/trimmed:trimmed"
        "2_illumina/filter:filter")

for pos in "${ARRAY[@]}" ; do
    KEY=${pos%%:*}
    VALUE=${pos#*:}
    printf "==> %s => %s\n" "$KEY" "$VALUE"
    
    for count in 200000 400000 600000 800000 1000000 1200000 1400000 1600000 1800000 2000000 2200000 2400000;
    do
        echo "==> Reads ${count}"
        DIR_COUNT="${BASE_DIR}/${VALUE}_${count}"
        mkdir -p ${DIR_COUNT}
        
        if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
            continue     
        fi
        
        seqtk sample -s${count} \
            ${BASE_DIR}/${KEY}/R1.fq.gz ${count} \
            | pigz > ${DIR_COUNT}/R1.fq.gz
        seqtk sample -s${count} \
            ${BASE_DIR}/${KEY}/R2.fq.gz ${count} \
            | pigz > ${DIR_COUNT}/R2.fq.gz
    done
done
```

### *E. coli*: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

for d in {original,trimmed,filter}_{200000,400000,600000,800000,1000000,1200000,1400000,1600000,1800000,2000000,2200000,2400000};
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"

    if [ ! -d ${DIR_COUNT} ]; then
        echo "${DIR_COUNT} doesn't exist"
        continue
    fi
    
    if [ -e ${DIR_COUNT}/pe.cor.fa ]; then
        echo "pe.cor.fa already presents"
        continue
    fi
    
    pushd ${DIR_COUNT} > /dev/null
    anchr superreads \
        R1.fq.gz \
        R2.fq.gz \
        -s 300 -d 30 -p 8
    bash superreads.sh
    popd > /dev/null
done
```

Stats of super-reads

```bash
BASE_DIR=$HOME/data/data/anchr/e_coli
cd ${BASE_DIR}

REAL_G=4641652

bash ~/Scripts/sra/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

bash ~/Scripts/sra/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

for d in {original,trimmed,filter}_{200000,400000,600000,800000,1000000,1200000,1400000,1600000,1800000,2000000,2200000,2400000};
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -d ${DIR_COUNT} ]; then
        continue     
    fi
    
    bash ~/Scripts/sra/sr_stat.sh 1 ${DIR_COUNT} \
        >> ${BASE_DIR}/stat1.md
    
    bash ~/Scripts/sra/sr_stat.sh 2 ${DIR_COUNT} ${REAL_G} \
        >> ${BASE_DIR}/stat2.md
done

cat stat1.md
cat stat2.md
```

