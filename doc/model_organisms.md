# Assemble genomes of model organisms by ANCHR

[TOC levels=1-3]: # " "
- [Assemble genomes of model organisms by ANCHR](#assemble-genomes-of-model-organisms-by-anchr)
- [*Saccharomyces cerevisiae* S288c](#saccharomyces-cerevisiae-s288c)
    - [s288c: download](#s288c-download)
    - [s288c: preprocess Illumina reads](#s288c-preprocess-illumina-reads)
    - [s288c: preprocess PacBio reads](#s288c-preprocess-pacbio-reads)
    - [s288c: reads stats](#s288c-reads-stats)
    - [s288c: spades](#s288c-spades)
    - [s288c: platanus](#s288c-platanus)
    - [s288c: quorum](#s288c-quorum)
    - [s288c: down sampling](#s288c-down-sampling)
    - [s288c: k-unitigs and anchors (sampled)](#s288c-k-unitigs-and-anchors-sampled)
    - [s288c: merge anchors with Qxx and QxxL60Xxx](#s288c-merge-anchors-with-qxx-and-qxxl60xxx)
    - [s288c: merge anchors](#s288c-merge-anchors)
    - [s288c: 3GS](#s288c-3gs)
    - [s288c: local corrections](#s288c-local-corrections)
    - [s288c: expand anchors](#s288c-expand-anchors)
    - [s288c: final stats](#s288c-final-stats)
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
- [*Caenorhabditis elegans* N2](#caenorhabditis-elegans-n2)
    - [n2: download](#n2-download)
    - [n2: preprocess Illumina reads](#n2-preprocess-illumina-reads)
    - [n2: preprocess PacBio reads](#n2-preprocess-pacbio-reads)
    - [n2: reads stats](#n2-reads-stats)
    - [n2: spades](#n2-spades)
    - [n2: platanus](#n2-platanus)
    - [n2: quorum](#n2-quorum)
    - [n2: down sampling](#n2-down-sampling)
    - [n2: k-unitigs and anchors (sampled)](#n2-k-unitigs-and-anchors-sampled)
    - [n2: merge anchors](#n2-merge-anchors)
    - [n2: 3GS](#n2-3gs)
    - [n2: expand anchors](#n2-expand-anchors)
    - [n2: final stats](#n2-final-stats)
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


# *Saccharomyces cerevisiae* S288c

* Genome: [Ensembl 82](http://sep2015.archive.ensembl.org/Saccharomyces_cerevisiae/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.058

## s288c: download

* Settings

```bash
BASE_NAME=s288c
REAL_G=12157105
COVERAGE2="30 40 50 60 80 120 160"
COVERAGE3="40 80"
READ_QUAL="25 30"
READ_LEN="60"

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

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

* kmergenie

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

parallel -j 2 "
    kmergenie -l 21 -k 121 -s 10 -t 8 ../{}.fq.gz -o {}
    " ::: R1 R2

```

## s288c: preprocess Illumina reads

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

parallel --no-run-if-empty --linebuffer -k -j 3 "
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
    " ::: ${READ_QUAL} ::: ${READ_LEN}

```

## s288c: preprocess PacBio reads

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

for X in ${COVERAGE3}; do
    printf "==> Coverage: %s\n" ${X}
    
    faops split-about -m 1 -l 0 \
        3_pacbio/pacbio.fasta \
        $(( ${REAL_G} * ${X} )) \
        3_pacbio
        
    mv 3_pacbio/000.fa "3_pacbio/pacbio.X${X}.raw.fasta"

done

for X in ${COVERAGE3}; do
    printf "==> Coverage: %s\n" ${X}
    
    anchr trimlong --parallel 16 -v \
        "3_pacbio/pacbio.X${X}.raw.fasta" \
        -o "3_pacbio/pacbio.X${X}.trim.fasta"

done

```

## s288c: reads stats

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
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md

parallel --no-run-if-empty -k -j 3 "
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
    " ::: ${READ_QUAL} ::: ${READ_LEN} \
    >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "PacBio";    faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md

parallel --no-run-if-empty -k -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo X{1}.{2};
            faops n50 -H -S -C \
                3_pacbio/pacbio.X{1}.{2}.fasta;
        )
    " ::: ${COVERAGE3} ::: raw trim \
    >> stat.md

cat stat.md

```

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

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

spades.py \
    -t 16 \
    -k 21,33,55,77 \
    -1 2_illumina/Q25L60/R1.fq.gz \
    -2 2_illumina/Q25L60/R2.fq.gz \
    -s 2_illumina/Q25L60/Rs.fq.gz \
    -o 8_spades

anchr contained \
    8_spades/contigs.fasta \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin 8_spades/contigs.non-contained.fasta

```

## s288c: platanus

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 8_platanus
cd 8_platanus

if [ ! -e pe.fa ]; then
    faops interleave \
        -p pe \
        ../2_illumina/Q25L60/R1.fq.gz \
        ../2_illumina/Q25L60/R2.fq.gz \
        > pe.fa
    
    faops interleave \
        -p se \
        ../2_illumina/Q25L60/Rs.fq.gz \
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

```text
#### PROCESS INFORMATION ####
VmPeak:          65.688 GByte
VmHWM:            7.394 GByte
```

## s288c: quorum

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty --linebuffer -k -j 1 "
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

| Name   | SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead |  Kmer |  RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|------:|-------:|-------:|---------:|--------:|------:|-------:|-------:|---------:|----------:|
| Q25L60 |  2.5G | 205.9 |   2.2G |  181.2 |  11.967% |     149 | "105" | 12.16M | 12.16M |     1.00 | 0:06'55'' |
| Q30L60 | 2.44G | 201.0 |  2.18G |  179.5 |  10.664% |     148 | "105" | 12.16M | 12.06M |     0.99 | 0:06'49'' |

* Clear intermediate files.

```bash
cd $HOME/data/anchr/${BASE_NAME}

find 2_illumina -type f -name "quorum_mer_db.jf" | xargs rm
find 2_illumina -type f -name "k_u_hash_0"       | xargs rm
find 2_illumina -type f -name "*.tmp"            | xargs rm
find 2_illumina -type f -name "pe.renamed.fastq" | xargs rm
find 2_illumina -type f -name "se.renamed.fastq" | xargs rm
find 2_illumina -type f -name "pe.cor.sub.fa"    | xargs rm
```

## s288c: down sampling

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

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

## s288c: k-unitigs and anchors (sampled)

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

# k-unitigs (sampled)
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

# anchors (sampled)
parallel --no-run-if-empty --linebuffer -k -j 3 "
    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'

    if [ ! -e Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa not exists'
        exit;
    fi

    if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        echo >&2 '    k_unitigs.fasta already presents'
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

| Name           |  SumCor | CovCor | N50SR |    Sum |    # | N50Anchor |    Sum |    # | N50Others |     Sum |   # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|--------:|-------:|------:|-------:|-----:|----------:|-------:|-----:|----------:|--------:|----:|--------------------:|----------:|:----------|
| Q25L60X30P000  | 364.71M |   30.0 | 10058 | 11.32M | 1910 |     10348 | 11.09M | 1613 |       809 | 230.88K | 297 | "31,41,51,61,71,81" | 0:10'03'' | 0:01'22'' |
| Q25L60X30P001  | 364.71M |   30.0 | 10449 | 11.32M | 1901 |     10591 | 11.09M | 1592 |       766 | 230.71K | 309 | "31,41,51,61,71,81" | 0:10'13'' | 0:01'21'' |
| Q25L60X30P002  | 364.71M |   30.0 |  9850 | 11.34M | 1902 |     10106 | 11.08M | 1604 |       822 | 262.06K | 298 | "31,41,51,61,71,81" | 0:09'35'' | 0:01'21'' |
| Q25L60X30P003  | 364.71M |   30.0 | 10787 | 11.38M | 1814 |     10843 | 11.07M | 1539 |       965 | 309.26K | 275 | "31,41,51,61,71,81" | 0:09'37'' | 0:01'24'' |
| Q25L60X30P004  | 364.71M |   30.0 | 10708 | 11.37M | 1854 |     10798 |  11.1M | 1573 |       890 | 270.34K | 281 | "31,41,51,61,71,81" | 0:08'25'' | 0:01'26'' |
| Q25L60X30P005  | 364.71M |   30.0 | 10975 | 11.33M | 1844 |     11298 | 11.09M | 1539 |       791 | 234.89K | 305 | "31,41,51,61,71,81" | 0:08'49'' | 0:01'26'' |
| Q25L60X40P000  | 486.28M |   40.0 | 10985 | 11.37M | 1842 |     11177 | 11.14M | 1536 |       784 |  230.4K | 306 | "31,41,51,61,71,81" | 0:09'52'' | 0:01'42'' |
| Q25L60X40P001  | 486.28M |   40.0 | 10671 |  11.4M | 1869 |     10957 | 11.08M | 1538 |       883 | 320.23K | 331 | "31,41,51,61,71,81" | 0:10'56'' | 0:01'42'' |
| Q25L60X40P002  | 486.28M |   40.0 | 11317 | 11.39M | 1765 |     11489 | 11.13M | 1485 |       872 |  263.1K | 280 | "31,41,51,61,71,81" | 0:10'41'' | 0:01'43'' |
| Q25L60X40P003  | 486.28M |   40.0 | 11061 | 11.38M | 1844 |     11329 | 11.13M | 1536 |       813 | 249.05K | 308 | "31,41,51,61,71,81" | 0:10'52'' | 0:01'42'' |
| Q25L60X50P000  | 607.86M |   50.0 | 10316 | 11.38M | 1932 |     10671 | 11.12M | 1591 |       787 | 258.16K | 341 | "31,41,51,61,71,81" | 0:11'27'' | 0:01'43'' |
| Q25L60X50P001  | 607.86M |   50.0 | 10086 | 11.41M | 1902 |     10191 | 11.12M | 1608 |       880 | 292.52K | 294 | "31,41,51,61,71,81" | 0:10'54'' | 0:01'50'' |
| Q25L60X50P002  | 607.86M |   50.0 | 10621 | 11.39M | 1875 |     10952 | 11.14M | 1561 |       789 | 248.52K | 314 | "31,41,51,61,71,81" | 0:12'54'' | 0:01'05'' |
| Q25L60X60P000  | 729.43M |   60.0 |  9557 |  11.4M | 2053 |      9874 | 11.12M | 1691 |       784 | 273.62K | 362 | "31,41,51,61,71,81" | 0:13'23'' | 0:01'09'' |
| Q25L60X60P001  | 729.43M |   60.0 |  9584 | 11.41M | 2022 |      9822 | 11.12M | 1689 |       813 | 290.68K | 333 | "31,41,51,61,71,81" | 0:12'20'' | 0:01'02'' |
| Q25L60X60P002  | 729.43M |   60.0 |  9659 | 11.48M | 2067 |      9825 | 11.07M | 1713 |       942 | 405.06K | 354 | "31,41,51,61,71,81" | 0:12'31'' | 0:00'59'' |
| Q25L60X80P000  | 972.57M |   80.0 |  8264 | 11.44M | 2326 |      8392 | 11.07M | 1912 |       830 | 370.19K | 414 | "31,41,51,61,71,81" | 0:19'02'' | 0:01'12'' |
| Q25L60X80P001  | 972.57M |   80.0 |  8207 | 11.44M | 2350 |      8450 | 11.06M | 1916 |       822 |  376.3K | 434 | "31,41,51,61,71,81" | 0:18'53'' | 0:01'12'' |
| Q25L60X120P000 |   1.46G |  120.0 |  6336 | 11.43M | 2924 |      6523 | 10.95M | 2339 |       798 | 481.11K | 585 | "31,41,51,61,71,81" | 0:22'50'' | 0:01'23'' |
| Q25L60X160P000 |   1.95G |  160.0 |  5329 | 11.38M | 3365 |      5608 | 10.83M | 2619 |       776 | 550.46K | 746 | "31,41,51,61,71,81" | 0:29'58'' | 0:01'59'' |
| Q30L60X30P000  | 364.71M |   30.0 | 10316 | 11.33M | 1903 |     10489 |  11.1M | 1617 |       793 |  226.9K | 286 | "31,41,51,61,71,81" | 0:09'27'' | 0:01'15'' |
| Q30L60X30P001  | 364.71M |   30.0 | 10302 | 11.32M | 1910 |     10504 | 11.09M | 1608 |       761 | 227.88K | 302 | "31,41,51,61,71,81" | 0:08'15'' | 0:01'06'' |
| Q30L60X30P002  | 364.71M |   30.0 | 10281 | 11.31M | 1891 |     10507 | 11.09M | 1592 |       759 | 225.73K | 299 | "31,41,51,61,71,81" | 0:08'40'' | 0:01'03'' |
| Q30L60X30P003  | 364.71M |   30.0 | 11247 | 11.32M | 1743 |     11426 | 11.08M | 1485 |       832 | 236.32K | 258 | "31,41,51,61,71,81" | 0:07'47'' | 0:01'07'' |
| Q30L60X30P004  | 364.71M |   30.0 | 10856 | 11.31M | 1837 |     11126 | 11.09M | 1543 |       789 |  224.7K | 294 | "31,41,51,61,71,81" | 0:07'57'' | 0:01'07'' |
| Q30L60X40P000  | 486.28M |   40.0 | 11148 | 11.36M | 1814 |     11317 | 11.14M | 1517 |       789 |  226.9K | 297 | "31,41,51,61,71,81" | 0:10'01'' | 0:01'12'' |
| Q30L60X40P001  | 486.28M |   40.0 | 11437 | 11.35M | 1769 |     11594 | 11.12M | 1466 |       771 | 228.01K | 303 | "31,41,51,61,71,81" | 0:09'49'' | 0:01'25'' |
| Q30L60X40P002  | 486.28M |   40.0 | 11734 | 11.38M | 1704 |     11819 | 11.11M | 1444 |       904 | 264.88K | 260 | "31,41,51,61,71,81" | 0:07'55'' | 0:01'32'' |
| Q30L60X40P003  | 486.28M |   40.0 | 11941 | 11.35M | 1761 |     12110 | 11.13M | 1465 |       785 | 221.56K | 296 | "31,41,51,61,71,81" | 0:08'01'' | 0:01'47'' |
| Q30L60X50P000  | 607.86M |   50.0 | 10982 | 11.38M | 1853 |     11259 | 11.14M | 1537 |       785 |  239.2K | 316 | "31,41,51,61,71,81" | 0:11'32'' | 0:01'50'' |
| Q30L60X50P001  | 607.86M |   50.0 | 10822 | 11.37M | 1834 |     11165 | 11.14M | 1535 |       769 | 223.95K | 299 | "31,41,51,61,71,81" | 0:11'55'' | 0:01'44'' |
| Q30L60X50P002  | 607.86M |   50.0 | 11181 | 11.38M | 1813 |     11347 | 11.15M | 1515 |       789 |  234.4K | 298 | "31,41,51,61,71,81" | 0:12'56'' | 0:01'48'' |
| Q30L60X60P000  | 729.43M |   60.0 | 10356 | 11.39M | 1961 |     10657 | 11.14M | 1616 |       780 | 255.15K | 345 | "31,41,51,61,71,81" | 0:14'23'' | 0:01'40'' |
| Q30L60X60P001  | 729.43M |   60.0 | 10332 |  11.4M | 1927 |     10613 | 11.11M | 1607 |       808 | 288.85K | 320 | "31,41,51,61,71,81" | 0:12'55'' | 0:01'39'' |
| Q30L60X80P000  | 972.57M |   80.0 |  9106 | 11.42M | 2186 |      9387 |  11.1M | 1799 |       805 | 326.52K | 387 | "31,41,51,61,71,81" | 0:15'13'' | 0:02'01'' |
| Q30L60X80P001  | 972.57M |   80.0 |  8759 | 11.42M | 2214 |      8905 | 11.05M | 1812 |       849 | 368.46K | 402 | "31,41,51,61,71,81" | 0:17'06'' | 0:02'09'' |
| Q30L60X120P000 |   1.46G |  120.0 |  6733 | 11.44M | 2754 |      6973 | 10.98M | 2210 |       808 | 455.74K | 544 | "31,41,51,61,71,81" | 0:24'24'' | 0:02'22'' |
| Q30L60X160P000 |   1.95G |  160.0 |  5899 | 11.39M | 3142 |      6134 | 10.89M | 2471 |       777 | 504.21K | 671 | "31,41,51,61,71,81" | 0:20'56'' | 0:01'59'' |

## s288c: merge anchors with Qxx and QxxL60Xxx

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

# merge anchors with Qxx
for Q in ${READ_QUAL}; do
    mkdir -p mergeQ${Q}
    anchr contained \
        $(
            parallel -k --no-run-if-empty -j 6 '
                if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                    echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
                fi
                ' ::: ${Q} ::: ${READ_LEN} :::  ${COVERAGE2} ::: $(printf "%03d " {0..100})
        ) \
        --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
        -o stdout \
        | faops filter -a 1000 -l 0 stdin mergeQ${Q}/anchor.contained.fasta
    anchr orient mergeQ${Q}/anchor.contained.fasta --len 1000 --idt 0.98 -o mergeQ${Q}/anchor.orient.fasta
    anchr merge mergeQ${Q}/anchor.orient.fasta --len 1000 --idt 0.999 -o mergeQ${Q}/anchor.merge0.fasta
    anchr contained mergeQ${Q}/anchor.merge0.fasta --len 1000 --idt 0.98 \
        --proportion 0.99 --parallel 16 -o stdout \
        | faops filter -a 1000 -l 0 stdin mergeQ${Q}/anchor.merge.fasta
done

# merge anchors with QxxL60Xxx
for Q in ${READ_QUAL}; do
    for X in ${COVERAGE2}; do
        mkdir -p mergeQ${Q}X${X}
        anchr contained \
            $(
                parallel -k --no-run-if-empty -j 6 '
                    if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                        echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
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
rm -fr 9_qa_mergeQxx
quast --no-check --threads 16 \
    --eukaryote \
    -R 1_genome/genome.fa \
    mergeQ25/anchor.merge.fasta \
    mergeQ30/anchor.merge.fasta \
    1_genome/paralogs.fas \
    --label "mergeQ25,mergeQ30,paralogs" \
    -o 9_qa_mergeQxx

rm -fr 9_qa_mergeQxxXxx
quast --no-check --threads 16 \
    --eukaryote \
    -R 1_genome/genome.fa \
    $( parallel -k 'printf "mergeQ{1}X{2}/anchor.merge.fasta "' ::: ${READ_QUAL} ::: ${COVERAGE2} ) \
    1_genome/paralogs.fas \
    --label "$( parallel -k 'printf "mergeQ{1}X{2},"' ::: ${READ_QUAL} ::: ${COVERAGE2} )paralogs" \
    -o 9_qa_mergeQxxXxx

```

## s288c: merge anchors

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

# merge anchors
mkdir -p merge
anchr contained \
    $(
        parallel --no-run-if-empty -k -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
            fi
            " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o merge/anchor.merge0.fasta
anchr contained merge/anchor.merge0.fasta --len 1000 --idt 0.98 \
    --proportion 0.99 --parallel 16 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
mkdir -p merge
anchr contained \
    $(
        parallel --no-run-if-empty -k -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.others.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.others.fa
            fi
            " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o merge/others.merge0.fasta
anchr contained merge/others.merge0.fasta --len 1000 --idt 0.98 \
    --proportion 0.99 --parallel 16 -o stdout \
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

## s288c: 3GS

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

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
            echo X{1}.{2}.trimmedReads;
            faops n50 -H -S -C \
                canu-X{1}-{2}/${BASE_NAME}.trimmedReads.fasta.gz;
        )

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

| Name                  |    N50 |       Sum |     # |
|:----------------------|-------:|----------:|------:|
| Genome                | 924431 |  12157105 |    17 |
| Paralogs              |   3851 |   1059148 |   366 |
| X40.raw.trimmedReads  |   7314 | 292715743 | 53395 |
| X40.raw               | 498694 |  12267418 |    48 |
| X40.trim.trimmedReads |   7405 | 304308381 | 54642 |
| X40.trim              | 551422 |  12193990 |    47 |
| X80.raw.trimmedReads  |   7327 | 435001864 | 79206 |
| X80.raw               | 604680 |  12351131 |    37 |
| X80.trim.trimmedReads |   7913 | 446060990 | 66050 |
| X80.trim              | 813374 |  12360766 |    26 |

## s288c: local corrections

```bash
BASE_NAME=s288c
REAL_G=12157105
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr localCor
anchr overlap2 \
    --parallel 16 \
    merge/anchor.merge.fasta \
    3_pacbio/pacbio.40x.trim.fasta \
    -d localCor \
    -b 20 --len 1000 --idt 0.85 --all

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
    --len 1000 --idt 0.85 -v

faops some -i -l 0 \
    long.fasta \
    group/overlapped.long.txt \
    independentLong.fasta

find . -type d -name "correction" | xargs rm -fr

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
    -p ${BASE_NAME} -d localCorRaw \
    gnuplotTested=true \
    genomeSize=${REAL_G} \
    -pacbio-raw localCor.fasta.gz \
    -pacbio-raw anchor.fasta

canu \
    -p ${BASE_NAME} -d localCorIndep \
    gnuplotTested=true \
    genomeSize=${REAL_G} \
    -pacbio-raw localCor.fasta.gz \
    -pacbio-raw anchor.fasta \
    -pacbio-raw independentLong.fasta

popd

# quast
rm -fr 9_qa_localCor
quast --no-check --threads 16 \
    --eukaryote \
    -R 1_genome/genome.fa \
    localCor/anchor.fasta \
    localCor/localCor/${BASE_NAME}.contigs.fasta \
    localCor/localCorRaw/${BASE_NAME}.contigs.fasta \
    localCor/localCorIndep/${BASE_NAME}.contigs.fasta \
    1_genome/paralogs.fas \
    --label "anchor,localCor,localCorRaw,localCorIndep,paralogs" \
    -o 9_qa_localCor

find . -type d -name "correction" | xargs rm -fr

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
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr anchorLong
anchr overlap2 \
    --parallel 16 \
    merge/anchor.merge.fasta \
    3_pacbio/pacbio.X40.trim.fasta \
    -d anchorLong \
    -b 50 --len 1000 --idt 0.85 --all

pushd anchorLong

anchr cover \
    --range "1-$(faops n50 -H -N 0 -C anchor.fasta)" \
    --len 1000 --idt 0.85 -c 2 \
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
    --len 1000 --idt 0.85 --max "-30" -c 2

cat group/groups.txt \
    | parallel --no-run-if-empty --linebuffer -k -j 8 '
        echo {};
        anchr orient \
            --len 1000 --idt 0.85 \
            group/{}.anchor.fasta \
            group/{}.long.fasta \
            -r group/{}.restrict.tsv \
            -o group/{}.strand.fasta;

        anchr overlap --len 1000 --idt 0.85 \
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
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr contigTrim
anchr overlap2 \
    --parallel 16 \
    anchorLong/contig.fasta \
    canu-X40-trim/${BASE_NAME}.contigs.fasta \
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
    --range "1-${CONTIG_COUNT}" --len 1000 --idt 0.98 --max 5000 -c 1

pushd contigTrim
cat group/groups.txt \
    | parallel --no-run-if-empty --linebuffer -k -j 8 '
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

## s288c: final stats

* Stats

```bash
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
    $(echo "anchorLong"; faops n50 -H -S -C anchorLong/contig.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "contigTrim"; faops n50 -H -S -C contigTrim/contig.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "canu-X40-raw"; faops n50 -H -S -C canu-X40-raw/${BASE_NAME}.contigs.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "canu-X40-trim"; faops n50 -H -S -C canu-X40-trim/${BASE_NAME}.contigs.fasta;) >> stat3.md
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

| Name                   |    N50 |      Sum |    # |
|:-----------------------|-------:|---------:|-----:|
| Genome                 | 924431 | 12157105 |   17 |
| Paralogs               |   3851 |  1059148 |  366 |
| anchor.merge           |  32537 | 11325611 |  595 |
| others.merge           |   6008 |   424881 |  184 |
| anchorLong             |  41366 | 11219030 |  462 |
| contigTrim             | 260345 | 11316985 |   84 |
| canu-X40-raw           | 498694 | 12267418 |   48 |
| canu-X40-trim          | 551422 | 12193990 |   47 |
| spades.scaffold        |  98572 | 11732702 | 1167 |
| spades.non-contained   |  91619 | 11544360 |  291 |
| platanus.contig        |   5983 | 12437850 | 7727 |
| platanus.scaffold      |  55443 | 12073445 | 4735 |
| platanus.non-contained |  59263 | 11404921 |  360 |

* quast

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr 9_qa_contig
quast --no-check --threads 16 \
    --eukaryote \
    --no-icarus \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-X40-raw/${BASE_NAME}.contigs.fasta \
    canu-X40-trim/${BASE_NAME}.contigs.fasta \
    8_spades/contigs.non-contained.fasta \
    8_platanus/gapClosed.non-contained.fasta \
    1_genome/paralogs.fas \
    --label "merge,contig,contigTrim,canu-X40-raw,canu-X40-trim,spades,platanus,paralogs" \
    -o 9_qa_contig

```

* Clear QxxLxxXxx.

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr 2_illumina/Q{20,25,30,35}L{30,60,90,120}X*
rm -fr Q{20,25,30,35}L{30,60,90,120}X*

rm -fr mergeQ*
rm -fr mergeL*

find . -type d -name "correction" -path "*canu-*" | xargs rm -fr
find . -type d -name "trimming"   -path "*canu-*" | xargs rm -fr
find . -type d -name "unitigging" -path "*canu-*" | xargs rm -fr

find . -type d -path "*8_spades/*" | xargs rm -fr

find . -type f -path "*8_platanus/*" -name "[ps]e.fa" | xargs rm

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

## iso_1: preprocess Illumina reads

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

## iso_1: preprocess PacBio reads

```bash
BASE_NAME=iso_1
cd ${HOME}/data/anchr/${BASE_NAME}

anchr trimlong --parallel 16 -v \
    3_pacbio/pacbio.40x.fasta \
    -o 3_pacbio/pacbio.40x.trim.fasta

```

## iso_1: reads stats

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

printf "| %s | %s | %s | %s |\n" \
    $(echo "PacBio";    faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md

parallel -k --no-run-if-empty -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo PacBio.{};
            faops n50 -H -S -C \
                3_pacbio/pacbio.{}.fasta;
        )
    " ::: 40x 40x.trim \
    >> stat.md

cat stat.md

```

| Name            |      N50 |         Sum |         # |
|:----------------|---------:|------------:|----------:|
| Genome          | 25286936 |   137567477 |         8 |
| Paralogs        |     4031 |    13665900 |      4492 |
| Illumina        |      101 | 18115734306 | 179363706 |
| uniq            |      101 | 17595866904 | 174216504 |
| Q20L60          |      101 | 15645516794 | 156403806 |
| Q25L60          |      101 | 14657099109 | 147178220 |
| Q30L60          |      101 | 13983733793 | 143634907 |
| PacBio          |    13704 |  5620710497 |    630193 |
| PacBio.40x      |    13704 |  5620710497 |    630193 |
| PacBio.40x.trim |    13554 |  5213016859 |    541236 |

## iso_1: spades

```bash
BASE_NAME=iso_1
cd ${HOME}/data/anchr/${BASE_NAME}

spades.py \
    -t 16 \
    -k 21,33,55,77 \
    -1 2_illumina/Q25L60/R1.fq.gz \
    -2 2_illumina/Q25L60/R2.fq.gz \
    -s 2_illumina/Q25L60/Rs.fq.gz \
    -o 8_spades

```

## iso_1: platanus

```bash
BASE_NAME=iso_1
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 8_platanus
cd 8_platanus

if [ ! -e pe.fa ]; then
    faops interleave \
        -p pe \
        ../2_illumina/Q25L60/R1.fq.gz \
        ../2_illumina/Q25L60/R2.fq.gz \
        > pe.fa
    
    faops interleave \
        -p se \
        ../2_illumina/Q25L60/Rs.fq.gz \
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

```

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
REAL_G=137567477
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
        --kmer 31,41,51,61,71,81,43,45 \
        -o kunitigs.sh
    bash kunitigs.sh

    echo >&2
    " ::: 25 30 ::: 60 ::: 40 80 ::: 000 001 002 003 004 005 006

# anchors (sampled)
parallel --no-run-if-empty -j 3 "
    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'

    if [ ! -e Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa not exists'
        exit;
    fi

    if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        echo >&2 '    k_unitigs.fasta already presents'
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
    " ::: 25 30 ::: 60 ::: 40 80 ::: 000 001 002 003 004 005 006

# Stats of anchors
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

| Name          | SumCor | CovCor | N50SR |     Sum |     # | N50Anchor |     Sum |     # | N50Others |   Sum |    # |                      Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|-------:|------:|--------:|------:|----------:|--------:|------:|----------:|------:|-----:|--------------------------:|----------:|:----------|
| Q25L60X40P000 |   5.5G |   40.0 | 15071 |  120.4M | 17971 |     15570 | 115.59M | 13374 |       895 | 4.81M | 4597 | "31,41,43,45,51,61,71,81" | 1:49'30'' | 0:15'43'' |
| Q25L60X40P001 |   5.5G |   40.0 | 15022 | 120.25M | 18206 |     15611 | 115.64M | 13570 |       867 | 4.61M | 4636 | "31,41,43,45,51,61,71,81" | 1:51'20'' | 0:13'54'' |
| Q25L60X80P000 | 11.01G |   80.0 | 11442 | 120.49M | 21157 |     11891 | 115.59M | 16183 |       872 |  4.9M | 4974 | "31,41,43,45,51,61,71,81" | 2:29'52'' | 0:18'07'' |
| Q30L60X40P000 |   5.5G |   40.0 | 14735 | 120.17M | 18849 |     15237 | 115.12M | 13892 |       878 | 5.05M | 4957 | "31,41,43,45,51,61,71,81" | 1:50'40'' | 0:10'07'' |
| Q30L60X40P001 |   5.5G |   40.0 | 14182 |  120.1M | 19483 |     14723 | 114.97M | 14333 |       865 | 5.14M | 5150 | "31,41,43,45,51,61,71,81" | 1:50'22'' | 0:11'26'' |
| Q30L60X80P000 | 11.01G |   80.0 | 12544 | 120.37M | 20203 |     13096 | 115.53M | 15333 |       867 | 4.84M | 4870 | "31,41,43,45,51,61,71,81" | 2:35'52'' | 0:13'13'' |

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
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o merge/anchor.merge0.fasta
anchr contained merge/anchor.merge0.fasta --len 1000 --idt 0.98 \
    --proportion 0.99 --parallel 16 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge1.fasta
faops order merge/anchor.merge1.fasta \
    <(faops size merge/anchor.merge1.fasta | sort -n -r -k2,2 | cut -f 1) \
    merge/anchor.merge.fasta

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
REAL_G=137567477
cd ${HOME}/data/anchr/${BASE_NAME}

canu \
    -p ${BASE_NAME} -d canu-raw-40x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=${REAL_G} \
    -pacbio-raw 3_pacbio/pacbio.40x.fasta

canu \
    -p ${BASE_NAME} -d canu-trim-40x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=${REAL_G} \
    -pacbio-raw 3_pacbio/pacbio.40x.trim.fasta

find . -type d -name "correction" -path "*canu-*" | xargs rm -fr

minimap canu-raw-40x/${BASE_NAME}.contigs.fasta 1_genome/genome.fa \
    | minidot - > canu-raw-40x/minidot.eps

minimap canu-trim-40x/${BASE_NAME}.contigs.fasta 1_genome/genome.fa \
    | minidot - > canu-trim-40x/minidot.eps

faops n50 -S -C canu-raw-40x/${BASE_NAME}.trimmedReads.fasta.gz
faops n50 -S -C canu-trim-40x/${BASE_NAME}.trimmedReads.fasta.gz

```

## iso_1: expand anchors

* anchorLong

```bash
BASE_NAME=iso_1
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr anchorLong
anchr overlap2 \
    --parallel 16 \
    merge/anchor.merge.fasta \
    3_pacbio/pacbio.40x.trim.fasta \
    -d anchorLong \
    -b 50 --len 1000 --idt 0.85 --all

pushd anchorLong

anchr cover \
    --range "1-$(faops n50 -H -N 0 -C anchor.fasta)" \
    --len 1000 --idt 0.85 -c 2 \
    anchorLong.ovlp.tsv \
    -o anchor.cover.json
cat anchor.cover.json | jq "." > environment.json

anchr overlap \
    anchor.fasta \
    --serial --len 20 --idt 0.9999 \
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
    --len 1000 --idt 0.85 --max "-20" -c 2

cat group/groups.txt \
    | parallel --no-run-if-empty -j 8 '
        echo {};
        anchr orient \
            --len 1000 --idt 0.85 \
            group/{}.anchor.fasta \
            group/{}.long.fasta \
            -r group/{}.restrict.tsv \
            -o group/{}.strand.fasta;

        anchr overlap --len 1000 --idt 0.85 \
            group/{}.strand.fasta \
            -o stdout \
            | anchr restrict \
                stdin group/{}.restrict.tsv \
                -o group/{}.ovlp.tsv;

        anchr overlap --len 20 --idt 0.9999 \
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
    -b 50 --len 1000 --idt 0.99 --all

CONTIG_COUNT=$(faops n50 -H -N 0 -C contigTrim/anchor.fasta)
echo ${CONTIG_COUNT}

rm -fr contigTrim/group
anchr group \
    --parallel 16 \
    --keep \
    contigTrim/anchorLong.db \
    contigTrim/anchorLong.ovlp.tsv \
    --range "1-${CONTIG_COUNT}" --len 1000 --idt 0.99 --max 20000 -c 1

pushd contigTrim
cat group/groups.txt \
    | parallel --no-run-if-empty -j 8 '
        echo {};
        anchr orient \
            --len 1000 --idt 0.99 \
            group/{}.anchor.fasta \
            group/{}.long.fasta \
            -r group/{}.restrict.tsv \
            -o group/{}.strand.fasta;

        anchr overlap --len 1000 --idt 0.99 --all \
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

## iso_1: final stats

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
    $(echo "anchorLong"; faops n50 -H -S -C anchorLong/contig.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "contigTrim"; faops n50 -H -S -C contigTrim/contig.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "spades.contig"; faops n50 -H -S -C 8_spades/contigs.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "spades.scaffold"; faops n50 -H -S -C 8_spades/scaffolds.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "platanus.contig"; faops n50 -H -S -C 8_platanus/out_contig.fa;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "platanus.scaffold"; faops n50 -H -S -C 8_platanus/out_gapClosed.fa;) >> stat3.md

cat stat3.md
```

| Name              |      N50 |       Sum |      # |
|:------------------|---------:|----------:|-------:|
| Genome            | 25286936 | 137567477 |      8 |
| Paralogs          |     4031 |  13665900 |   4492 |
| anchor.merge      |    26860 | 117041459 |   9566 |
| others.merge      |     8732 |   3092289 |   1004 |
| anchor.cover      |    26199 | 116199529 |   9576 |
| anchorLong        |    69814 | 115806088 |   4924 |
| contigTrim        |  1238480 | 123572499 |    603 |
| spades.contig     |   108756 | 132705321 |  61620 |
| spades.scaffold   |   142273 | 132725706 |  61182 |
| platanus.contig   |    11503 | 156820565 | 359399 |
| platanus.scaffold |   146404 | 129134232 |  71416 |

* quast

```bash
BASE_NAME=iso_1
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr 9_qa_contig
quast --no-check --threads 16 \
    --eukaryote \
    --no-icarus \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-raw-40x/${BASE_NAME}.contigs.fasta \
    canu-trim-40x/${BASE_NAME}.contigs.fasta \
    8_spades/scaffolds.fasta \
    8_platanus/out_gapClosed.fa \
    1_genome/paralogs.fas \
    --label "merge,contig,contigTrim,canu-40x,canu-40x.trim,spades,platanus,paralogs" \
    -o 9_qa_contig

```

* Clear QxxLxxXxx.

```bash
BASE_NAME=iso_1
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr 2_illumina/Q{20,25,30,35}L{30,60,90,120}X*
rm -fr Q{20,25,30,35}L{30,60,90,120}X*
```

# *Caenorhabditis elegans* N2

* Genome: [Ensembl 82](http://sep2015.archive.ensembl.org/Caenorhabditis_elegans/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.0472

## n2: download

* Settings

```bash
BASE_NAME=n2
REAL_G=100286401
COVERAGE2="30 40 50 60"
COVERAGE3="40 80"
READ_QUAL="25 30"
READ_LEN="60"

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

```

* FastQC

* kmergenie

## n2: preprocess Illumina reads

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

* Clear intermediate files.

## n2: down sampling

## n2: k-unitigs and anchors (sampled)

| Name          | SumCor | CovCor | N50SR |    Sum |     # | N50Anchor |    Sum |     # | N50Others |    Sum |    # |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|-------:|------:|-------:|------:|----------:|-------:|------:|----------:|-------:|-----:|--------------------:|----------:|:----------|
| Q25L60X30P000 |  3.01G |   30.0 | 11004 | 98.24M | 22246 |     11789 |  85.9M | 13653 |      2402 | 12.34M | 8593 | "31,41,51,61,71,81" | 1:07'18'' | 0:15'28'' |
| Q25L60X30P001 |  3.01G |   30.0 | 10433 | 97.91M | 23025 |     11345 | 85.41M | 13877 |      1607 |  12.5M | 9148 | "31,41,51,61,71,81" | 1:01'28'' | 0:15'26'' |
| Q25L60X40P000 |  4.01G |   40.0 | 11692 | 98.77M | 20684 |     12466 | 87.36M | 13151 |      3423 | 11.41M | 7533 | "31,41,51,61,71,81" | 1:07'11'' | 0:17'46'' |
| Q25L60X50P000 |  5.01G |   50.0 | 11870 | 99.08M | 19874 |     12539 | 88.24M | 13041 |      4403 | 10.84M | 6833 | "31,41,51,61,71,81" | 1:12'12'' | 0:17'15'' |
| Q25L60X60P000 |  6.02G |   60.0 | 11787 | 99.28M | 19541 |     12470 | 88.54M | 12969 |      4657 | 10.74M | 6572 | "31,41,51,61,71,81" | 1:19'02'' | 0:19'23'' |
| Q30L60X30P000 |  3.01G |   30.0 | 10924 |  97.8M | 22846 |     11762 | 85.39M | 13766 |      1466 | 12.41M | 9080 | "31,41,51,61,71,81" | 0:58'19'' | 0:15'39'' |
| Q30L60X30P001 |  3.01G |   30.0 | 10165 | 97.41M | 24053 |     10923 | 84.52M | 14218 |      1259 |  12.9M | 9835 | "31,41,51,61,71,81" | 1:01'01'' | 0:15'02'' |
| Q30L60X40P000 |  4.01G |   40.0 | 11882 | 98.71M | 21159 |     12576 |  86.9M | 13233 |      3231 | 11.81M | 7926 | "31,41,51,61,71,81" | 1:48'03'' | 0:18'25'' |
| Q30L60X50P000 |  5.01G |   50.0 | 12310 | 99.09M | 20025 |     12849 | 87.73M | 12946 |      4775 | 11.36M | 7079 | "31,41,51,61,71,81" | 2:15'59'' | 0:18'17'' |
| Q30L60X60P000 |  6.02G |   60.0 | 12468 | 99.26M | 19356 |     12947 | 88.31M | 12776 |      5901 | 10.95M | 6580 | "31,41,51,61,71,81" | 1:32'14'' | 0:16'16'' |

## n2: merge anchors

## n2: 3GS

| Name                  |      N50 |        Sum |      # |
|:----------------------|---------:|-----------:|-------:|
| Genome                | 17493829 |  100286401 |      7 |
| Paralogs              |     2013 |    5313653 |   2637 |
| X40.raw.trimmedReads  |    16026 | 3225979202 | 271542 |
| X40.raw               |  3680860 |  106573851 |    153 |
| X40.trim.trimmedReads |    15968 | 3210251549 | 271514 |
| X40.trim              |  2965260 |  106522712 |    153 |
| X80.raw.trimmedReads  |    18183 | 3719126370 | 204086 |
| X80.raw               |  2922642 |  107417644 |    114 |
| X80.trim.trimmedReads |    18055 | 3771313179 | 207744 |
| X80.trim              |  3084499 |  107369523 |    116 |

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
| anchorLong             |    17387 |  89485645 |  10168 |
| contigTrim             |   322297 |  95048266 |    645 |
| canu-X40-raw           |  3680860 | 106573851 |    153 |
| canu-X40-trim          |  2965260 | 106522712 |    153 |
| spades.scaffold        |    39185 | 105667774 |  39154 |
| spades.non-contained   |    38451 |  99104997 |   6431 |
| platanus.contig        |     9540 | 108908253 | 143264 |
| platanus.scaffold      |    28158 |  99589056 |  35182 |
| platanus.non-contained |    30510 |  94099392 |   7644 |

* quast

* Clear QxxLxxx.

# *Arabidopsis thaliana* Col-0

* Genome: [Ensembl Genomes](http://plants.ensembl.org/Arabidopsis_thaliana/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.1158

## col_0: download

* Settings

```bash
BASE_NAME=col_0
REAL_G=119667750
COVERAGE2="30 40 50 60 70"
COVERAGE3="40 80"
READ_QUAL="25 30"
READ_LEN="60"

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
BASE_NAME=col_0
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
echo ">TruSeq_Adapter_Index_7" >> 2_illumina/illumina_adapters.fa
echo "GATCGGAAGAGCACACGTCTGAACTCCAGTCACCAGATCATCTCGTATGC" >> 2_illumina/illumina_adapters.fa
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
    " ::: 25 30 ::: 60

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

| Name | N50 | Sum | # |
|:-----|----:|----:|--:|

## col_0: expand anchors

* anchorLong

* contigTrim

## col_0: final stats

* Stats

| Name              |      N50 |       Sum |      # |
|:------------------|---------:|----------:|-------:|
| Genome            | 23459830 | 119667750 |      7 |
| Paralogs          |     2007 |  16447809 |   8055 |
| anchor.merge      |    28391 | 108282399 |   8601 |
| others.merge      |     2939 |   2073808 |    882 |
| anchor.cover      |    28398 | 107735288 |   8339 |
| anchorLong        |    45080 | 107528125 |   5622 |
| contigTrim        |   694603 | 108985292 |    666 |
| canu-trim         |  2880862 | 119217587 |    244 |
| spades.contig     |    55516 | 154715185 | 115087 |
| spades.scaffold   |    67856 | 154750615 | 114703 |
| platanus.contig   |    15019 | 139807772 | 106870 |
| platanus.scaffold |   192019 | 128497152 |  67429 |

* quast

* Clear QxxLxxx.
