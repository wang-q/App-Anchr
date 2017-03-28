# Assemble genomes of model organisms by ANCHR

[TOC levels=1-3]: # " "
- [Assemble genomes of model organisms by ANCHR](#assemble-genomes-of-model-organisms-by-anchr)
- [*Saccharomyces cerevisiae* S288c](#saccharomyces-cerevisiae-s288c)
    - [Scer: download](#scer-download)
    - [Scer: combinations of different quality values and read lengths](#scer-combinations-of-different-quality-values-and-read-lengths)
    - [Scer: down sampling](#scer-down-sampling)
    - [Scer: generate super-reads](#scer-generate-super-reads)
    - [Scer: create anchors](#scer-create-anchors)
    - [Scer: results](#scer-results)
    - [Scer: merge anchors](#scer-merge-anchors)
    - [Scer: 3GS](#scer-3gs)
    - [Scer: expand anchors](#scer-expand-anchors)
- [*Drosophila melanogaster* iso-1](#drosophila-melanogaster-iso-1)
    - [Dmel: download](#dmel-download)
    - [Dmel: combinations of different quality values and read lengths](#dmel-combinations-of-different-quality-values-and-read-lengths)
    - [Dmel: down sampling](#dmel-down-sampling)
    - [Dmel: generate k-unitigs/super-reads](#dmel-generate-k-unitigssuper-reads)
    - [Dmel: create anchors](#dmel-create-anchors)
    - [Dmel: results](#dmel-results)
    - [Dmel: merge anchors from different groups of reads](#dmel-merge-anchors-from-different-groups-of-reads)
    - [Dmel: 3GS](#dmel-3gs)
    - [Dmel: expand anchors](#dmel-expand-anchors)
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
    - [Atha: quality assessment](#atha-quality-assessment)


# *Saccharomyces cerevisiae* S288c

* Genome: [Ensembl 82](http://sep2015.archive.ensembl.org/Saccharomyces_cerevisiae/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.058

## Scer: download

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

## Scer: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 100, 110, 120, 130, 140, and 150

```bash
BASE_DIR=$HOME/data/anchr/s288c

# get the default adapter file
# anchr trim --help
cd ${BASE_DIR}
parallel --no-run-if-empty -j 2 "
    scythe \
        2_illumina/{}.fq.gz \
        -q sanger \
        -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
        --quiet \
        | pigz -p 4 -c \
        > 2_illumina/{}.scythe.fq.gz
    " ::: R1 R2

cd ${BASE_DIR}
parallel --no-run-if-empty -j 6 "
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
    " ::: 20 25 30 ::: 100 110 120 130 140 150

```

* Stats

```bash
BASE_DIR=$HOME/data/anchr/s288c
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
    for len in 100 110 120 130 140 150; do
        DIR_COUNT="${BASE_DIR}/2_illumina/Q${qual}L${len}"

        printf "| %s | %s | %s | %s |\n" \
            $(echo "Q${qual}L${len}"; faops n50 -H -S -C ${DIR_COUNT}/R1.fq.gz  ${DIR_COUNT}/R2.fq.gz;) \
            >> stat.md
    done
done

cat stat.md
```

| Name     |    N50 |        Sum |        # |
|:---------|-------:|-----------:|---------:|
| Genome   | 924431 |   12157105 |       17 |
| Paralogs |   3851 |    1059148 |      366 |
| Illumina |    151 | 2939081214 | 19464114 |
| PacBio   |   8169 | 3529504618 |   846948 |
| scythe   |    151 | 2856064236 | 19464114 |
| Q20L100  |    151 | 2715518542 | 18143428 |
| Q20L110  |    151 | 2696726129 | 17978274 |
| Q20L120  |    151 | 2671314209 | 17768540 |
| Q20L130  |    151 | 2637766736 | 17510028 |
| Q20L140  |    151 | 2589334780 | 17160084 |
| Q20L150  |    151 | 2540801666 | 16827778 |
| Q25L100  |    151 | 2520194401 | 16855962 |
| Q25L110  |    151 | 2497487825 | 16660496 |
| Q25L120  |    151 | 2468125943 | 16421630 |
| Q25L130  |    151 | 2431389599 | 16140530 |
| Q25L140  |    151 | 2383125715 | 15792300 |
| Q25L150  |    151 | 2348269619 | 15552026 |
| Q30L100  |    151 | 2303935909 | 15434468 |
| Q30L110  |    151 | 2277953248 | 15213546 |
| Q30L120  |    151 | 2244788901 | 14947056 |
| Q30L130  |    151 | 2203023127 | 14630350 |
| Q30L140  |    151 | 2147806869 | 14234194 |
| Q30L150  |    151 | 2104817905 | 13939512 |

## Scer: down sampling

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

ARRAY=( "2_illumina:original:8000000"
        "2_illumina/Q20L100:Q20L100:8000000"
        "2_illumina/Q20L110:Q20L110:8000000"
        "2_illumina/Q20L120:Q20L120:8000000"
        "2_illumina/Q20L130:Q20L130:8000000"
        "2_illumina/Q20L140:Q20L140:8000000"
        "2_illumina/Q20L150:Q20L150:8000000"
        "2_illumina/Q25L100:Q25L100:8000000"
        "2_illumina/Q25L110:Q25L110:8000000"
        "2_illumina/Q25L120:Q25L120:8000000"
        "2_illumina/Q25L130:Q25L130:8000000"
        "2_illumina/Q25L140:Q25L140:7000000"
        "2_illumina/Q25L150:Q25L150:7000000"
        "2_illumina/Q30L100:Q30L100:7000000"
        "2_illumina/Q30L110:Q30L110:7000000"
        "2_illumina/Q30L120:Q30L120:7000000"
        "2_illumina/Q30L130:Q30L130:7000000"
        "2_illumina/Q30L140:Q30L140:7000000"
        "2_illumina/Q30L150:Q30L150:7000000")

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    GROUP_MAX=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[2];')
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    for count in $(perl -e 'print 1000000 * $_, q{ } for 1 .. 8');
    do
        if [[ "$count" -gt "$GROUP_MAX" ]]; then
            continue;
        fi
        
        echo "==> Group ${GROUP_ID}_${count}"
        DIR_COUNT="${BASE_DIR}/${GROUP_ID}_${count}"
        mkdir -p ${DIR_COUNT}
        
        if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
            continue;
        fi
        
        seqtk sample -s${count} \
            ${BASE_DIR}/${GROUP_DIR}/R1.fq.gz ${count} \
            | pigz > ${DIR_COUNT}/R1.fq.gz
        seqtk sample -s${count} \
            ${BASE_DIR}/${GROUP_DIR}/R2.fq.gz ${count} \
            | pigz > ${DIR_COUNT}/R2.fq.gz
    done
done
```

## Scer: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        original
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        for my $i ( 1 .. 8 ) {
            printf qq{%s_%d\n}, $n, ( 1000000 * $i );
        }
    }
    ' \
    | parallel --no-run-if-empty -j 4 "
        echo '==> Group {}'
        
        if [ ! -d ${BASE_DIR}/{} ]; then
            echo '    directory not exists'
            exit;
        fi        

        if [ -e ${BASE_DIR}/{}/pe.cor.fa ]; then
            echo '    pe.cor.fa already presents'
            exit;
        fi

        cd ${BASE_DIR}/{}
        anchr superreads \
            R1.fq.gz R2.fq.gz \
            --nosr -p 8 \
            -o superreads.sh
        bash superreads.sh
    "

```

Clear intermediate files.

```bash
cd $HOME/data/anchr/s288c

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## Scer: create anchors

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        original
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        for my $i ( 1 .. 8 ) {
            printf qq{%s_%d\n}, $n, ( 1000000 * $i );
        }
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

## Scer: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

REAL_G=12157105

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

perl -e '
    for my $n (
        qw{
        original
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        for my $i ( 1 .. 8 ) {
            printf qq{%s_%d\n}, $n, ( 1000000 * $i );
        }
    }
    ' \
    | parallel -k --no-run-if-empty -j 8 "
        if [ ! -d ${BASE_DIR}/{} ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${BASE_DIR}/{} ${REAL_G}
    " >> ${BASE_DIR}/stat1.md

cat stat1.md
```

* Stats of anchors

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

perl -e '
    for my $n (
        qw{
        original
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        for my $i ( 1 .. 8 ) {
            printf qq{%s_%d\n}, $n, ( 1000000 * $i );
        }
    }
    ' \
    | parallel -k --no-run-if-empty -j 16 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

| Name             |   SumFq | CovFq | AvgRead | Kmer |   SumFa | Discard% |  RealG |   EstG | Est/Real |  SumKU | SumSR |   RunTime |
|:-----------------|--------:|------:|--------:|-----:|--------:|---------:|-------:|-------:|---------:|-------:|------:|----------:|
| original_1000000 |    302M |  24.8 |     151 |  105 | 249.57M |  17.360% | 12.16M | 11.38M |     0.94 | 13.13M |     0 | 0:05'57'' |
| original_2000000 |    604M |  49.7 |     151 |  105 |  500.7M |  17.103% | 12.16M | 11.62M |     0.96 | 13.59M |     0 | 0:08'55'' |
| original_3000000 |    906M |  74.5 |     151 |  105 | 752.87M |  16.901% | 12.16M | 11.79M |     0.97 | 14.59M |     0 | 0:12'31'' |
| original_4000000 |   1.21G |  99.4 |     151 |  105 |   1.01G |  16.755% | 12.16M | 11.94M |     0.98 | 15.81M |     0 | 0:16'11'' |
| original_5000000 |   1.51G | 124.2 |     151 |  105 |   1.26G |  16.600% | 12.16M | 12.11M |     1.00 | 17.18M |     0 | 0:20'19'' |
| original_6000000 |   1.81G | 149.0 |     151 |  105 |   1.51G |  16.510% | 12.16M | 12.26M |     1.01 | 18.56M |     0 | 0:25'14'' |
| original_7000000 |   2.11G | 173.9 |     151 |  105 |   1.77G |  16.431% | 12.16M | 12.42M |     1.02 | 20.07M |     0 | 0:29'32'' |
| original_8000000 |   2.42G | 198.7 |     151 |  105 |   2.02G |  16.352% | 12.16M | 12.57M |     1.03 | 21.52M |     0 | 0:33'25'' |
| Q20L100_1000000  | 299.33M |  24.6 |     149 |  105 | 271.59M |   9.266% | 12.16M | 11.37M |     0.93 | 12.83M |     0 | 0:05'15'' |
| Q20L100_2000000  | 598.67M |  49.2 |     149 |  105 | 543.73M |   9.177% | 12.16M | 11.54M |     0.95 |  12.8M |     0 | 0:09'26'' |
| Q20L100_3000000  |    898M |  73.9 |     149 |  105 | 815.74M |   9.160% | 12.16M | 11.59M |     0.95 | 12.95M |     0 | 0:13'35'' |
| Q20L100_4000000  |    1.2G |  98.5 |     149 |  105 |   1.09G |   9.069% | 12.16M | 11.66M |     0.96 | 13.48M |     0 | 0:16'57'' |
| Q20L100_5000000  |    1.5G | 123.1 |     149 |  105 |   1.36G |   8.991% | 12.16M | 11.74M |     0.97 | 14.06M |     0 | 0:21'41'' |
| Q20L100_6000000  |    1.8G | 147.7 |     149 |  105 |   1.64G |   8.922% | 12.16M | 11.82M |     0.97 | 14.76M |     0 | 0:26'06'' |
| Q20L100_7000000  |    2.1G | 172.4 |     149 |  105 |   1.91G |   8.841% | 12.16M |  11.9M |     0.98 | 15.47M |     0 | 0:30'13'' |
| Q20L100_8000000  |   2.39G | 197.0 |     149 |  105 |   2.18G |   8.798% | 12.16M | 11.98M |     0.99 | 16.23M |     0 | 0:34'20'' |
| Q20L110_1000000  | 300.01M |  24.7 |     149 |  105 | 272.32M |   9.227% | 12.16M | 11.36M |     0.93 | 12.81M |     0 | 0:05'18'' |
| Q20L110_2000000  | 599.97M |  49.4 |     150 |  105 | 545.29M |   9.114% | 12.16M | 11.53M |     0.95 | 12.76M |     0 | 0:09'41'' |
| Q20L110_3000000  | 899.97M |  74.0 |     150 |  105 | 818.21M |   9.085% | 12.16M | 11.58M |     0.95 | 12.91M |     0 | 0:13'47'' |
| Q20L110_4000000  |    1.2G |  98.7 |     150 |  105 |   1.09G |   8.990% | 12.16M | 11.66M |     0.96 | 13.43M |     0 | 0:16'49'' |
| Q20L110_5000000  |    1.5G | 123.4 |     150 |  105 |   1.37G |   8.918% | 12.16M | 11.73M |     0.97 | 14.05M |     0 | 0:21'33'' |
| Q20L110_6000000  |    1.8G | 148.1 |     150 |  105 |   1.64G |   8.854% | 12.16M | 11.81M |     0.97 | 14.71M |     0 | 0:26'38'' |
| Q20L110_7000000  |    2.1G | 172.7 |     150 |  105 |   1.92G |   8.784% | 12.16M | 11.89M |     0.98 | 15.42M |     0 | 0:31'24'' |
| Q20L110_8000000  |    2.4G | 197.4 |     150 |  105 |   2.19G |   8.725% | 12.16M | 11.97M |     0.98 | 16.15M |     0 | 0:32'37'' |
| Q20L120_1000000  | 300.68M |  24.7 |     150 |  105 | 273.06M |   9.183% | 12.16M | 11.35M |     0.93 | 12.78M |     0 | 0:05'11'' |
| Q20L120_2000000  | 601.35M |  49.5 |     150 |  105 | 547.02M |   9.035% | 12.16M | 11.52M |     0.95 | 12.73M |     0 | 0:09'43'' |
| Q20L120_3000000  | 902.03M |  74.2 |     150 |  105 | 820.63M |   9.024% | 12.16M | 11.58M |     0.95 |  12.9M |     0 | 0:12'00'' |
| Q20L120_4000000  |    1.2G |  98.9 |     150 |  105 |    1.1G |   8.937% | 12.16M | 11.65M |     0.96 | 13.38M |     0 | 0:15'14'' |
| Q20L120_5000000  |    1.5G | 123.7 |     150 |  105 |   1.37G |   8.848% | 12.16M | 11.72M |     0.96 | 13.99M |     0 | 0:23'20'' |
| Q20L120_6000000  |    1.8G | 148.4 |     150 |  105 |   1.65G |   8.778% | 12.16M |  11.8M |     0.97 | 14.63M |     0 | 0:27'45'' |
| Q20L120_7000000  |    2.1G | 173.1 |     150 |  105 |   1.92G |   8.706% | 12.16M | 11.88M |     0.98 | 15.34M |     0 | 0:31'35'' |
| Q20L120_8000000  |   2.41G | 197.9 |     150 |  105 |    2.2G |   8.654% | 12.16M | 11.96M |     0.98 | 16.06M |     0 | 0:37'23'' |
| Q20L130_1000000  | 301.28M |  24.8 |     150 |  105 | 273.98M |   9.064% | 12.16M | 11.35M |     0.93 | 12.74M |     0 | 0:05'28'' |
| Q20L130_2000000  | 602.58M |  49.6 |     150 |  105 | 548.86M |   8.915% | 12.16M | 11.52M |     0.95 | 12.71M |     0 | 0:09'21'' |
| Q20L130_3000000  | 903.86M |  74.3 |     150 |  105 | 823.65M |   8.874% | 12.16M | 11.57M |     0.95 | 12.85M |     0 | 0:13'33'' |
| Q20L130_4000000  |   1.21G |  99.1 |     150 |  105 |    1.1G |   8.804% | 12.16M | 11.64M |     0.96 | 13.29M |     0 | 0:17'06'' |
| Q20L130_5000000  |   1.51G | 123.9 |     150 |  105 |   1.37G |   8.730% | 12.16M | 11.71M |     0.96 | 13.88M |     0 | 0:21'48'' |
| Q20L130_6000000  |   1.81G | 148.7 |     150 |  105 |   1.65G |   8.658% | 12.16M | 11.78M |     0.97 |  14.5M |     0 | 0:26'47'' |
| Q20L130_7000000  |   2.11G | 173.5 |     150 |  105 |   1.93G |   8.593% | 12.16M | 11.86M |     0.98 | 15.19M |     0 | 0:29'22'' |
| Q20L130_8000000  |   2.41G | 198.3 |     150 |  105 |    2.2G |   8.540% | 12.16M | 11.94M |     0.98 | 15.88M |     0 | 0:36'17'' |
| Q20L140_1000000  | 301.78M |  24.8 |     150 |  105 | 275.22M |   8.803% | 12.16M | 11.34M |     0.93 | 12.69M |     0 | 0:06'13'' |
| Q20L140_2000000  | 603.57M |  49.6 |     150 |  105 | 551.02M |   8.707% | 12.16M | 11.51M |     0.95 | 12.65M |     0 | 0:09'13'' |
| Q20L140_3000000  | 905.36M |  74.5 |     150 |  105 | 826.62M |   8.697% | 12.16M | 11.56M |     0.95 | 12.77M |     0 | 0:13'27'' |
| Q20L140_4000000  |   1.21G |  99.3 |     150 |  105 |    1.1G |   8.627% | 12.16M | 11.62M |     0.96 | 13.19M |     0 | 0:17'07'' |
| Q20L140_5000000  |   1.51G | 124.1 |     150 |  105 |   1.38G |   8.558% | 12.16M | 11.68M |     0.96 |  13.7M |     0 | 0:20'43'' |
| Q20L140_6000000  |   1.81G | 148.9 |     150 |  105 |   1.66G |   8.478% | 12.16M | 11.75M |     0.97 | 14.29M |     0 | 0:26'09'' |
| Q20L140_7000000  |   2.11G | 173.8 |     150 |  105 |   1.93G |   8.427% | 12.16M | 11.83M |     0.97 | 14.95M |     0 | 0:32'31'' |
| Q20L140_8000000  |   2.41G | 198.6 |     150 |  105 |   2.21G |   8.378% | 12.16M |  11.9M |     0.98 |  15.6M |     0 | 0:38'59'' |
| Q20L150_1000000  | 301.98M |  24.8 |     150 |  105 |  275.9M |   8.634% | 12.16M | 11.34M |     0.93 | 12.68M |     0 | 0:06'20'' |
| Q20L150_2000000  | 603.95M |  49.7 |     150 |  105 | 552.38M |   8.539% | 12.16M |  11.5M |     0.95 | 12.62M |     0 | 0:10'09'' |
| Q20L150_3000000  | 905.93M |  74.5 |     150 |  105 | 828.85M |   8.508% | 12.16M | 11.55M |     0.95 | 12.74M |     0 | 0:14'03'' |
| Q20L150_4000000  |   1.21G |  99.4 |     150 |  105 |   1.11G |   8.443% | 12.16M | 11.61M |     0.96 | 13.12M |     0 | 0:17'57'' |
| Q20L150_5000000  |   1.51G | 124.2 |     150 |  105 |   1.38G |   8.358% | 12.16M | 11.67M |     0.96 | 13.59M |     0 | 0:22'00'' |
| Q20L150_6000000  |   1.81G | 149.0 |     150 |  105 |   1.66G |   8.299% | 12.16M | 11.74M |     0.97 | 14.19M |     0 | 0:26'15'' |
| Q20L150_7000000  |   2.11G | 173.9 |     150 |  105 |   1.94G |   8.241% | 12.16M | 11.81M |     0.97 |  14.8M |     0 | 0:30'43'' |
| Q20L150_8000000  |   2.42G | 198.7 |     150 |  105 |   2.22G |   8.190% | 12.16M | 11.88M |     0.98 | 15.45M |     0 | 0:36'19'' |
| Q25L100_1000000  | 299.03M |  24.6 |     149 |  105 |    279M |   6.698% | 12.16M | 11.36M |     0.93 | 12.76M |     0 | 0:05'43'' |
| Q25L100_2000000  | 598.07M |  49.2 |     149 |  105 | 558.17M |   6.672% | 12.16M |  11.5M |     0.95 | 12.48M |     0 | 0:09'25'' |
| Q25L100_3000000  | 897.06M |  73.8 |     149 |  105 |  837.7M |   6.617% | 12.16M | 11.55M |     0.95 | 12.64M |     0 | 0:13'43'' |
| Q25L100_4000000  |    1.2G |  98.4 |     149 |  105 |   1.12G |   6.578% | 12.16M | 11.59M |     0.95 | 12.89M |     0 | 0:17'04'' |
| Q25L100_5000000  |    1.5G | 123.0 |     149 |  105 |    1.4G |   6.532% | 12.16M | 11.62M |     0.96 | 13.22M |     0 | 0:21'36'' |
| Q25L100_6000000  |   1.79G | 147.6 |     149 |  105 |   1.68G |   6.485% | 12.16M | 11.67M |     0.96 | 13.64M |     0 | 0:26'05'' |
| Q25L100_7000000  |   2.09G | 172.2 |     149 |  105 |   1.96G |   6.442% | 12.16M | 11.71M |     0.96 | 14.11M |     0 | 0:30'52'' |
| Q25L100_8000000  |   2.39G | 196.8 |     149 |  105 |   2.24G |   6.401% | 12.16M | 11.76M |     0.97 | 14.57M |     0 | 0:34'27'' |
| Q25L110_1000000  | 299.81M |  24.7 |     149 |  105 | 279.76M |   6.689% | 12.16M | 11.35M |     0.93 | 12.73M |     0 | 0:05'37'' |
| Q25L110_2000000  | 599.61M |  49.3 |     149 |  105 | 559.66M |   6.662% | 12.16M | 11.49M |     0.95 | 12.48M |     0 | 0:09'40'' |
| Q25L110_3000000  | 899.42M |  74.0 |     149 |  105 | 840.11M |   6.594% | 12.16M | 11.54M |     0.95 | 12.62M |     0 | 0:13'51'' |
| Q25L110_4000000  |    1.2G |  98.6 |     150 |  105 |   1.12G |   6.558% | 12.16M | 11.58M |     0.95 | 12.87M |     0 | 0:17'29'' |
| Q25L110_5000000  |    1.5G | 123.3 |     150 |  105 |    1.4G |   6.498% | 12.16M | 11.62M |     0.96 |  13.2M |     0 | 0:22'33'' |
| Q25L110_6000000  |    1.8G | 148.0 |     150 |  105 |   1.68G |   6.458% | 12.16M | 11.66M |     0.96 | 13.59M |     0 | 0:26'44'' |
| Q25L110_7000000  |    2.1G | 172.6 |     150 |  105 |   1.96G |   6.420% | 12.16M | 11.71M |     0.96 | 14.06M |     0 | 0:30'45'' |
| Q25L110_8000000  |    2.4G | 197.3 |     150 |  105 |   2.25G |   6.373% | 12.16M | 11.76M |     0.97 | 14.54M |     0 | 0:35'22'' |
| Q25L120_1000000  | 300.59M |  24.7 |     150 |  105 | 280.59M |   6.651% | 12.16M | 11.34M |     0.93 |  12.7M |     0 | 0:05'25'' |
| Q25L120_2000000  | 601.18M |  49.5 |     150 |  105 | 561.44M |   6.610% | 12.16M | 11.49M |     0.95 | 12.44M |     0 | 0:09'22'' |
| Q25L120_3000000  | 901.77M |  74.2 |     150 |  105 | 842.61M |   6.560% | 12.16M | 11.54M |     0.95 | 12.58M |     0 | 0:13'51'' |
| Q25L120_4000000  |    1.2G |  98.9 |     150 |  105 |   1.12G |   6.526% | 12.16M | 11.58M |     0.95 | 12.83M |     0 | 0:18'00'' |
| Q25L120_5000000  |    1.5G | 123.6 |     150 |  105 |   1.41G |   6.466% | 12.16M | 11.61M |     0.96 | 13.15M |     0 | 0:21'17'' |
| Q25L120_6000000  |    1.8G | 148.4 |     150 |  105 |   1.69G |   6.423% | 12.16M | 11.66M |     0.96 | 13.56M |     0 | 0:24'48'' |
| Q25L120_7000000  |    2.1G | 173.1 |     150 |  105 |   1.97G |   6.382% | 12.16M |  11.7M |     0.96 | 13.98M |     0 | 0:28'09'' |
| Q25L120_8000000  |    2.4G | 197.8 |     150 |  105 |   2.25G |   6.348% | 12.16M | 11.75M |     0.97 | 14.47M |     0 | 0:32'45'' |
| Q25L130_1000000  | 301.28M |  24.8 |     150 |  105 | 281.33M |   6.623% | 12.16M | 11.34M |     0.93 | 12.66M |     0 | 0:05'15'' |
| Q25L130_2000000  | 602.55M |  49.6 |     150 |  105 | 562.97M |   6.569% | 12.16M | 11.48M |     0.94 | 12.43M |     0 | 0:08'07'' |
| Q25L130_3000000  | 903.82M |  74.3 |     150 |  105 |  844.7M |   6.541% | 12.16M | 11.53M |     0.95 | 12.54M |     0 | 0:11'22'' |
| Q25L130_4000000  |   1.21G |  99.1 |     150 |  105 |   1.13G |   6.493% | 12.16M | 11.57M |     0.95 | 12.78M |     0 | 0:15'02'' |
| Q25L130_5000000  |   1.51G | 123.9 |     150 |  105 |   1.41G |   6.441% | 12.16M | 11.61M |     0.95 | 13.09M |     0 | 0:22'19'' |
| Q25L130_6000000  |   1.81G | 148.7 |     150 |  105 |   1.69G |   6.386% | 12.16M | 11.65M |     0.96 | 13.45M |     0 | 0:27'44'' |
| Q25L130_7000000  |   2.11G | 173.5 |     150 |  105 |   1.97G |   6.356% | 12.16M | 11.69M |     0.96 |  13.9M |     0 | 0:34'47'' |
| Q25L130_8000000  |   2.41G | 198.3 |     150 |  105 |   2.26G |   6.313% | 12.16M | 11.74M |     0.97 | 14.38M |     0 | 0:40'39'' |
| Q25L140_1000000  | 301.81M |  24.8 |     150 |  105 | 282.02M |   6.559% | 12.16M | 11.33M |     0.93 | 12.61M |     0 | 0:06'19'' |
| Q25L140_2000000  | 603.62M |  49.7 |     150 |  105 | 564.34M |   6.507% | 12.16M | 11.48M |     0.94 | 12.39M |     0 | 0:11'40'' |
| Q25L140_3000000  | 905.42M |  74.5 |     150 |  105 | 846.76M |   6.479% | 12.16M | 11.53M |     0.95 | 12.51M |     0 | 0:15'32'' |
| Q25L140_4000000  |   1.21G |  99.3 |     150 |  105 |   1.13G |   6.429% | 12.16M | 11.56M |     0.95 | 12.73M |     0 | 0:19'41'' |
| Q25L140_5000000  |   1.51G | 124.1 |     150 |  105 |   1.41G |   6.374% | 12.16M |  11.6M |     0.95 | 13.02M |     0 | 0:24'19'' |
| Q25L140_6000000  |   1.81G | 149.0 |     150 |  105 |    1.7G |   6.332% | 12.16M | 11.64M |     0.96 | 13.38M |     0 | 0:29'25'' |
| Q25L140_7000000  |   2.11G | 173.8 |     150 |  105 |   1.98G |   6.298% | 12.16M | 11.68M |     0.96 | 13.82M |     0 | 0:34'45'' |
| Q25L150_1000000  | 301.99M |  24.8 |     150 |  105 | 282.36M |   6.499% | 12.16M | 11.32M |     0.93 |  12.6M |     0 | 0:05'58'' |
| Q25L150_2000000  | 603.98M |  49.7 |     150 |  105 | 564.85M |   6.479% | 12.16M | 11.48M |     0.94 | 12.39M |     0 | 0:10'21'' |
| Q25L150_3000000  | 905.97M |  74.5 |     150 |  105 | 847.77M |   6.423% | 12.16M | 11.52M |     0.95 |  12.5M |     0 | 0:14'55'' |
| Q25L150_4000000  |   1.21G |  99.4 |     150 |  105 |   1.13G |   6.412% | 12.16M | 11.56M |     0.95 |  12.7M |     0 | 0:19'46'' |
| Q25L150_5000000  |   1.51G | 124.2 |     150 |  105 |   1.41G |   6.347% | 12.16M | 11.59M |     0.95 | 12.99M |     0 | 0:24'09'' |
| Q25L150_6000000  |   1.81G | 149.0 |     150 |  105 |    1.7G |   6.305% | 12.16M | 11.63M |     0.96 | 13.37M |     0 | 0:28'50'' |
| Q25L150_7000000  |   2.11G | 173.9 |     150 |  105 |   1.98G |   6.275% | 12.16M | 11.68M |     0.96 | 13.77M |     0 | 0:36'40'' |
| Q30L100_1000000  | 298.56M |  24.6 |     149 |  105 | 281.76M |   5.625% | 12.16M | 11.34M |     0.93 |  12.7M |     0 | 0:05'58'' |
| Q30L100_2000000  | 597.08M |  49.1 |     149 |  105 | 563.58M |   5.611% | 12.16M | 11.48M |     0.94 | 12.42M |     0 | 0:09'51'' |
| Q30L100_3000000  | 895.62M |  73.7 |     149 |  105 | 845.69M |   5.575% | 12.16M | 11.53M |     0.95 |  12.5M |     0 | 0:14'10'' |
| Q30L100_4000000  |   1.19G |  98.2 |     149 |  105 |   1.13G |   5.548% | 12.16M | 11.56M |     0.95 | 12.66M |     0 | 0:19'19'' |
| Q30L100_5000000  |   1.49G | 122.8 |     149 |  105 |   1.41G |   5.512% | 12.16M | 11.59M |     0.95 |  12.9M |     0 | 0:22'26'' |
| Q30L100_6000000  |   1.79G | 147.3 |     149 |  105 |   1.69G |   5.482% | 12.16M | 11.62M |     0.96 |  13.2M |     0 | 0:27'19'' |
| Q30L100_7000000  |   2.09G | 171.9 |     149 |  105 |   1.98G |   5.447% | 12.16M | 11.65M |     0.96 | 13.52M |     0 | 0:31'47'' |
| Q30L110_1000000  | 299.47M |  24.6 |     149 |  105 | 282.58M |   5.640% | 12.16M | 11.33M |     0.93 | 12.68M |     0 | 0:04'55'' |
| Q30L110_2000000  | 598.92M |  49.3 |     149 |  105 | 565.37M |   5.602% | 12.16M | 11.48M |     0.94 | 12.39M |     0 | 0:10'10'' |
| Q30L110_3000000  | 898.41M |  73.9 |     149 |  105 | 848.06M |   5.603% | 12.16M | 11.52M |     0.95 | 12.47M |     0 | 0:14'25'' |
| Q30L110_4000000  |    1.2G |  98.5 |     149 |  105 |   1.13G |   5.540% | 12.16M | 11.56M |     0.95 | 12.65M |     0 | 0:19'31'' |
| Q30L110_5000000  |    1.5G | 123.2 |     149 |  105 |   1.41G |   5.516% | 12.16M | 11.59M |     0.95 | 12.88M |     0 | 0:23'56'' |
| Q30L110_6000000  |    1.8G | 147.8 |     149 |  105 |    1.7G |   5.483% | 12.16M | 11.62M |     0.96 | 13.17M |     0 | 0:28'45'' |
| Q30L110_7000000  |    2.1G | 172.4 |     149 |  105 |   1.98G |   5.445% | 12.16M | 11.65M |     0.96 | 13.51M |     0 | 0:32'15'' |
| Q30L120_1000000  | 300.37M |  24.7 |     150 |  105 | 283.43M |   5.640% | 12.16M | 11.33M |     0.93 | 12.63M |     0 | 0:05'45'' |
| Q30L120_2000000  | 600.73M |  49.4 |     150 |  105 |  567.1M |   5.598% | 12.16M | 11.47M |     0.94 | 12.37M |     0 | 0:10'14'' |
| Q30L120_3000000  | 901.09M |  74.1 |     150 |  105 | 850.76M |   5.586% | 12.16M | 11.52M |     0.95 | 12.45M |     0 | 0:14'30'' |
| Q30L120_4000000  |    1.2G |  98.8 |     150 |  105 |   1.13G |   5.546% | 12.16M | 11.55M |     0.95 | 12.63M |     0 | 0:20'40'' |
| Q30L120_5000000  |    1.5G | 123.5 |     150 |  105 |   1.42G |   5.516% | 12.16M | 11.58M |     0.95 | 12.87M |     0 | 0:23'14'' |
| Q30L120_6000000  |    1.8G | 148.2 |     150 |  105 |    1.7G |   5.475% | 12.16M | 11.61M |     0.96 | 13.15M |     0 | 0:28'37'' |
| Q30L120_7000000  |    2.1G | 172.9 |     150 |  105 |   1.99G |   5.446% | 12.16M | 11.65M |     0.96 | 13.47M |     0 | 0:31'43'' |
| Q30L130_1000000  | 301.16M |  24.8 |     150 |  105 | 284.13M |   5.655% | 12.16M | 11.33M |     0.93 |  12.6M |     0 | 0:05'18'' |
| Q30L130_2000000  | 602.31M |  49.5 |     150 |  105 | 568.56M |   5.603% | 12.16M | 11.47M |     0.94 | 12.36M |     0 | 0:10'22'' |
| Q30L130_3000000  | 903.47M |  74.3 |     150 |  105 | 853.15M |   5.570% | 12.16M | 11.51M |     0.95 | 12.44M |     0 | 0:14'27'' |
| Q30L130_4000000  |    1.2G |  99.1 |     150 |  105 |   1.14G |   5.542% | 12.16M | 11.54M |     0.95 |  12.6M |     0 | 0:19'27'' |
| Q30L130_5000000  |   1.51G | 123.9 |     150 |  105 |   1.42G |   5.504% | 12.16M | 11.58M |     0.95 | 12.81M |     0 | 0:22'54'' |
| Q30L130_6000000  |   1.81G | 148.6 |     150 |  105 |   1.71G |   5.466% | 12.16M | 11.61M |     0.95 | 13.11M |     0 | 0:28'17'' |
| Q30L130_7000000  |   2.11G | 173.4 |     150 |  105 |   1.99G |   5.444% | 12.16M | 11.64M |     0.96 | 13.43M |     0 | 0:31'12'' |
| Q30L140_1000000  | 301.78M |  24.8 |     150 |  105 | 284.85M |   5.611% | 12.16M | 11.31M |     0.93 | 12.56M |     0 | 0:05'30'' |
| Q30L140_2000000  | 603.56M |  49.6 |     150 |  105 | 569.81M |   5.592% | 12.16M | 11.46M |     0.94 | 12.33M |     0 | 0:10'09'' |
| Q30L140_3000000  | 905.35M |  74.5 |     150 |  105 | 855.07M |   5.554% | 12.16M |  11.5M |     0.95 | 12.39M |     0 | 0:14'08'' |
| Q30L140_4000000  |   1.21G |  99.3 |     150 |  105 |   1.14G |   5.531% | 12.16M | 11.54M |     0.95 | 12.56M |     0 | 0:18'39'' |
| Q30L140_5000000  |   1.51G | 124.1 |     150 |  105 |   1.43G |   5.492% | 12.16M | 11.57M |     0.95 | 12.78M |     0 | 0:12'52'' |
| Q30L140_6000000  |   1.81G | 148.9 |     150 |  105 |   1.71G |   5.469% | 12.16M |  11.6M |     0.95 | 13.03M |     0 | 0:15'27'' |
| Q30L140_7000000  |   2.11G | 173.8 |     150 |  105 |      2G |   5.436% | 12.16M | 11.63M |     0.96 | 13.37M |     0 | 0:18'00'' |
| Q30L150_1000000  | 301.99M |  24.8 |     150 |  105 | 285.18M |   5.566% | 12.16M | 11.31M |     0.93 | 12.55M |     0 | 0:02'48'' |
| Q30L150_2000000  | 603.99M |  49.7 |     150 |  105 | 570.39M |   5.563% | 12.16M | 11.46M |     0.94 | 12.32M |     0 | 0:05'12'' |
| Q30L150_3000000  | 905.98M |  74.5 |     150 |  105 | 855.95M |   5.522% | 12.16M |  11.5M |     0.95 | 12.39M |     0 | 0:07'05'' |
| Q30L150_4000000  |   1.21G |  99.4 |     150 |  105 |   1.14G |   5.493% | 12.16M | 11.53M |     0.95 | 12.54M |     0 | 0:09'21'' |
| Q30L150_5000000  |   1.51G | 124.2 |     150 |  105 |   1.43G |   5.458% | 12.16M | 11.56M |     0.95 | 12.75M |     0 | 0:13'33'' |
| Q30L150_6000000  |   1.81G | 149.0 |     150 |  105 |   1.71G |   5.426% | 12.16M |  11.6M |     0.95 | 13.02M |     0 | 0:16'31'' |
| Q30L150_7000000  |    2.1G | 173.1 |     150 |  105 |   1.99G |   5.398% | 12.16M | 11.63M |     0.96 | 13.32M |     0 | 0:17'38'' |


| Name             | N50SRclean |    Sum |     # | N50Anchor |    Sum |    # | N50Anchor2 |    Sum |  # | N50Others |   Sum |     # |   RunTime |
|:-----------------|-----------:|-------:|------:|----------:|-------:|-----:|-----------:|-------:|---:|----------:|------:|------:|----------:|
| original_1000000 |       1206 | 13.13M | 23247 |      1898 |  7.42M | 4038 |       1135 | 12.89K | 11 |       427 | 5.69M | 19198 | 0:02'16'' |
| original_2000000 |       3008 | 13.59M | 20452 |      3841 | 10.55M | 3336 |       1214 | 17.91K | 15 |       153 | 3.02M | 17101 | 0:03'22'' |
| original_3000000 |       3961 | 14.59M | 27171 |      5506 | 11.03M | 2646 |       1529 |  3.02K |  2 |       128 | 3.56M | 24523 | 0:04'39'' |
| original_4000000 |       4279 | 15.81M | 36461 |      6747 |  11.1M | 2310 |       1511 |  2.73K |  2 |       124 |  4.7M | 34149 | 0:05'36'' |
| original_5000000 |       3545 | 17.18M | 47415 |      6596 | 11.13M | 2363 |       1237 |  1.24K |  1 |       123 | 6.05M | 45051 | 0:06'56'' |
| original_6000000 |       2658 | 18.56M | 58381 |      6240 | 11.05M | 2491 |          0 |      0 |  0 |       123 | 7.51M | 55890 | 0:07'48'' |
| original_7000000 |       1761 | 20.07M | 70521 |      5294 | 10.96M | 2776 |          0 |      0 |  0 |       123 | 9.11M | 67745 | 0:08'14'' |
| original_8000000 |       1052 | 21.52M | 82117 |      4401 | 10.81M | 3159 |       1531 |   2.7K |  2 |       123 | 10.7M | 78956 | 0:09'20'' |
| Q20L100_1000000  |       1383 | 12.83M | 19554 |      2016 |  7.96M | 4137 |       1259 | 12.59K | 10 |       445 | 4.86M | 15407 | 0:01'52'' |
| Q20L100_2000000  |       3520 |  12.8M | 13277 |      4223 | 10.68M | 3190 |       1195 |  7.33K |  6 |       209 | 2.11M | 10081 | 0:03'11'' |
| Q20L100_3000000  |       5304 | 12.95M | 12965 |      6297 | 11.13M | 2428 |       1159 |  1.16K |  1 |       161 | 1.82M | 10536 | 0:04'17'' |
| Q20L100_4000000  |       6294 | 13.48M | 16688 |      7899 | 11.23M | 2094 |       1509 |  2.94K |  2 |       141 | 2.24M | 14592 | 0:05'33'' |
| Q20L100_5000000  |       6658 | 14.06M | 21076 |      8927 | 11.26M | 1903 |          0 |      0 |  0 |       134 |  2.8M | 19173 | 0:06'40'' |
| Q20L100_6000000  |       6423 | 14.76M | 26440 |      9199 | 11.27M | 1868 |          0 |      0 |  0 |       131 | 3.48M | 24572 | 0:07'48'' |
| Q20L100_7000000  |       5903 | 15.47M | 31927 |      9068 | 11.28M | 1898 |          0 |      0 |  0 |       130 | 4.19M | 30029 | 0:08'38'' |
| Q20L100_8000000  |       5162 | 16.23M | 37731 |      8967 | 11.26M | 1952 |          0 |      0 |  0 |       130 | 4.96M | 35779 | 0:09'41'' |
| Q20L110_1000000  |       1371 | 12.81M | 19384 |      2002 |  7.99M | 4177 |       1152 | 23.61K | 20 |       450 |  4.8M | 15187 | 0:02'53'' |
| Q20L110_2000000  |       3468 | 12.76M | 12964 |      4088 | 10.69M | 3215 |       1103 |   1.1K |  1 |       217 | 2.07M |  9748 | 0:03'17'' |
| Q20L110_3000000  |       5433 | 12.91M | 12667 |      6244 | 11.11M | 2437 |       1231 |   4.8K |  4 |       165 | 1.79M | 10226 | 0:04'21'' |
| Q20L110_4000000  |       6373 | 13.43M | 16267 |      7863 | 11.22M | 2074 |       1216 |  1.22K |  1 |       143 | 2.21M | 14192 | 0:05'53'' |
| Q20L110_5000000  |       6865 | 14.05M | 20888 |      8800 | 11.27M | 1917 |       1105 |  1.11K |  1 |       135 | 2.78M | 18970 | 0:07'10'' |
| Q20L110_6000000  |       6498 | 14.71M | 25958 |      9464 | 11.28M | 1836 |          0 |      0 |  0 |       132 | 3.43M | 24122 | 0:08'22'' |
| Q20L110_7000000  |       5900 | 15.42M | 31493 |      9073 | 11.28M | 1902 |          0 |      0 |  0 |       130 | 4.15M | 29591 | 0:08'30'' |
| Q20L110_8000000  |       5275 | 16.15M | 37102 |      9037 | 11.27M | 1931 |          0 |      0 |  0 |       130 | 4.88M | 35171 | 0:08'48'' |
| Q20L120_1000000  |       1417 | 12.78M | 19079 |      2061 |  8.05M | 4126 |       1206 | 18.79K | 15 |       443 | 4.72M | 14938 | 0:02'43'' |
| Q20L120_2000000  |       3560 | 12.73M | 12669 |      4138 |  10.7M | 3173 |       1195 | 13.32K | 11 |       215 | 2.02M |  9485 | 0:03'17'' |
| Q20L120_3000000  |       5504 |  12.9M | 12527 |      6428 | 11.12M | 2365 |       1088 |  1.09K |  1 |       165 | 1.78M | 10161 | 0:04'59'' |
| Q20L120_4000000  |       6479 | 13.38M | 15887 |      7987 | 11.21M | 2035 |          0 |      0 |  0 |       144 | 2.17M | 13852 | 0:05'26'' |
| Q20L120_5000000  |       6744 | 13.99M | 20428 |      9107 | 11.26M | 1875 |          0 |      0 |  0 |       135 | 2.73M | 18553 | 0:06'41'' |
| Q20L120_6000000  |       6820 | 14.63M | 25305 |      9567 | 11.26M | 1832 |       1194 |  1.19K |  1 |       133 | 3.36M | 23472 | 0:08'04'' |
| Q20L120_7000000  |       6011 | 15.34M | 30821 |      9039 | 11.28M | 1882 |          0 |      0 |  0 |       131 | 4.06M | 28939 | 0:08'35'' |
| Q20L120_8000000  |       5475 | 16.06M | 36310 |      9158 | 11.26M | 1906 |          0 |      0 |  0 |       131 |  4.8M | 34404 | 0:09'23'' |
| Q20L130_1000000  |       1450 | 12.74M | 18623 |      2060 |  8.11M | 4144 |       1137 | 32.23K | 27 |       449 |  4.6M | 14452 | 0:02'46'' |
| Q20L130_2000000  |       3633 | 12.71M | 12408 |      4312 | 10.75M | 3175 |       1190 |  4.18K |  3 |       212 | 1.95M |  9230 | 0:03'33'' |
| Q20L130_3000000  |       5517 | 12.85M | 12117 |      6381 |  11.1M | 2386 |       1488 |  2.58K |  2 |       171 | 1.74M |  9729 | 0:04'36'' |
| Q20L130_4000000  |       6764 | 13.29M | 15082 |      8183 | 11.22M | 2000 |       1180 |  2.26K |  2 |       147 | 2.07M | 13080 | 0:05'42'' |
| Q20L130_5000000  |       6908 | 13.88M | 19474 |      9233 | 11.26M | 1860 |       1391 |  2.67K |  2 |       137 | 2.62M | 17612 | 0:06'22'' |
| Q20L130_6000000  |       6903 |  14.5M | 24202 |      9515 | 11.28M | 1822 |          0 |      0 |  0 |       134 | 3.22M | 22380 | 0:07'20'' |
| Q20L130_7000000  |       6335 | 15.19M | 29498 |      9314 | 11.28M | 1859 |          0 |      0 |  0 |       132 | 3.91M | 27639 | 0:08'24'' |
| Q20L130_8000000  |       5653 | 15.88M | 34859 |      9304 | 11.27M | 1892 |          0 |      0 |  0 |       132 | 4.62M | 32967 | 0:09'08'' |
| Q20L140_1000000  |       1482 | 12.69M | 18054 |      2128 |   8.2M | 4125 |       1237 | 23.36K | 19 |       454 | 4.47M | 13910 | 0:02'41'' |
| Q20L140_2000000  |       3700 | 12.65M | 11881 |      4261 | 10.78M | 3179 |       1236 |  2.41K |  2 |       217 | 1.87M |  8700 | 0:03'53'' |
| Q20L140_3000000  |       5680 | 12.77M | 11465 |      6593 | 11.13M | 2354 |          0 |      0 |  0 |       175 | 1.63M |  9111 | 0:04'51'' |
| Q20L140_4000000  |       6794 | 13.19M | 14264 |      8250 | 11.22M | 1990 |       1105 |  1.11K |  1 |       149 | 1.96M | 12273 | 0:05'36'' |
| Q20L140_5000000  |       7659 |  13.7M | 18073 |      9483 | 11.26M | 1805 |       1268 |  2.37K |  2 |       139 | 2.44M | 16266 | 0:06'31'' |
| Q20L140_6000000  |       7267 | 14.29M | 22574 |      9489 | 11.28M | 1794 |          0 |      0 |  0 |       135 | 3.01M | 20780 | 0:07'29'' |
| Q20L140_7000000  |       6928 | 14.95M | 27644 |      9622 | 11.28M | 1785 |          0 |      0 |  0 |       133 | 3.67M | 25859 | 0:08'02'' |
| Q20L140_8000000  |       5965 |  15.6M | 32559 |      9336 | 11.28M | 1846 |          0 |      0 |  0 |       132 | 4.32M | 30713 | 0:09'11'' |
| Q20L150_1000000  |       1493 | 12.68M | 17930 |      2118 |  8.28M | 4129 |       1153 | 15.17K | 13 |       441 | 4.38M | 13788 | 0:02'34'' |
| Q20L150_2000000  |       3726 | 12.62M | 11756 |      4312 | 10.75M | 3143 |       1140 |  3.46K |  3 |       224 | 1.87M |  8610 | 0:03'13'' |
| Q20L150_3000000  |       5583 | 12.74M | 11247 |      6422 | 11.12M | 2366 |       1308 |  3.76K |  3 |       180 | 1.62M |  8878 | 0:04'23'' |
| Q20L150_4000000  |       6814 | 13.12M | 13724 |      8190 | 11.23M | 1997 |       1692 |  2.92K |  2 |       151 | 1.89M | 11725 | 0:05'32'' |
| Q20L150_5000000  |       7655 | 13.59M | 17190 |      9446 | 11.26M | 1788 |       1105 |  1.11K |  1 |       141 | 2.33M | 15401 | 0:06'43'' |
| Q20L150_6000000  |       7344 | 14.19M | 21781 |      9905 | 11.27M | 1752 |       1553 |  1.55K |  1 |       136 | 2.92M | 20028 | 0:07'01'' |
| Q20L150_7000000  |       6848 |  14.8M | 26428 |      9691 | 11.29M | 1775 |          0 |      0 |  0 |       133 | 3.51M | 24653 | 0:08'09'' |
| Q20L150_8000000  |       6143 | 15.45M | 31390 |      9427 | 11.28M | 1833 |          0 |      0 |  0 |       133 | 4.16M | 29557 | 0:09'37'' |
| Q25L100_1000000  |       1426 | 12.76M | 18742 |      2010 |  8.11M | 4185 |       1107 | 12.49K | 11 |       453 | 4.64M | 14546 | 0:02'36'' |
| Q25L100_2000000  |       3747 | 12.48M | 10555 |      4336 | 10.76M | 3149 |       1301 |   5.1K |  4 |       249 | 1.71M |  7402 | 0:03'37'' |
| Q25L100_3000000  |       5579 | 12.64M | 10435 |      6369 | 11.11M | 2354 |       1345 |  1.35K |  1 |       195 | 1.53M |  8080 | 0:04'17'' |
| Q25L100_4000000  |       7021 | 12.89M | 11871 |      8260 | 11.22M | 2014 |       1105 |  1.11K |  1 |       158 | 1.67M |  9856 | 0:05'23'' |
| Q25L100_5000000  |       7688 | 13.22M | 14254 |      9226 | 11.27M | 1849 |          0 |      0 |  0 |       146 | 1.95M | 12405 | 0:06'46'' |
| Q25L100_6000000  |       7424 | 13.64M | 17464 |      9467 | 11.28M | 1814 |          0 |      0 |  0 |       140 | 2.36M | 15650 | 0:07'07'' |
| Q25L100_7000000  |       7090 | 14.11M | 21132 |      9445 | 11.27M | 1802 |          0 |      0 |  0 |       135 | 2.84M | 19330 | 0:08'03'' |
| Q25L100_8000000  |       6720 | 14.57M | 24699 |      9439 | 11.27M | 1844 |          0 |      0 |  0 |       134 |  3.3M | 22855 | 0:09'25'' |
| Q25L110_1000000  |       1446 | 12.73M | 18438 |      2081 |  8.16M | 4131 |       1192 |  16.7K | 14 |       451 | 4.56M | 14293 | 0:02'48'' |
| Q25L110_2000000  |       3803 | 12.48M | 10419 |      4367 | 10.77M | 3117 |       1277 |  2.34K |  2 |       253 |  1.7M |  7300 | 0:03'26'' |
| Q25L110_3000000  |       5672 | 12.62M | 10204 |      6394 |  11.1M | 2370 |       1180 |  4.78K |  4 |       200 | 1.51M |  7830 | 0:04'24'' |
| Q25L110_4000000  |       7347 | 12.87M | 11641 |      8584 | 11.22M | 1956 |       1105 |  1.11K |  1 |       160 | 1.65M |  9684 | 0:05'39'' |
| Q25L110_5000000  |       7889 |  13.2M | 14114 |      9501 | 11.27M | 1811 |          0 |      0 |  0 |       145 | 1.93M | 12303 | 0:06'34'' |
| Q25L110_6000000  |       7885 | 13.59M | 16994 |      9793 | 11.28M | 1774 |          0 |      0 |  0 |       140 | 2.31M | 15220 | 0:07'12'' |
| Q25L110_7000000  |       7360 | 14.06M | 20706 |      9793 | 11.28M | 1789 |          0 |      0 |  0 |       136 | 2.79M | 18917 | 0:08'04'' |
| Q25L110_8000000  |       6792 | 14.54M | 24373 |      9536 | 11.27M | 1843 |          0 |      0 |  0 |       135 | 3.27M | 22530 | 0:09'27'' |
| Q25L120_1000000  |       1463 |  12.7M | 18045 |      2079 |  8.21M | 4187 |       1213 | 14.28K | 12 |       457 | 4.47M | 13846 | 0:02'49'' |
| Q25L120_2000000  |       3852 | 12.44M | 10095 |      4379 |  10.8M | 3093 |       1194 |   6.7K |  5 |       248 | 1.63M |  6997 | 0:03'04'' |
| Q25L120_3000000  |       5753 | 12.58M |  9933 |      6481 | 11.12M | 2332 |       1228 |  4.66K |  4 |       198 | 1.46M |  7597 | 0:04'34'' |
| Q25L120_4000000  |       7161 | 12.83M | 11349 |      8447 | 11.22M | 1959 |       1274 |  1.27K |  1 |       162 | 1.61M |  9389 | 0:05'35'' |
| Q25L120_5000000  |       7920 | 13.15M | 13650 |      9444 | 11.25M | 1812 |          0 |      0 |  0 |       150 |  1.9M | 11838 | 0:06'23'' |
| Q25L120_6000000  |       8128 | 13.56M | 16734 |      9660 | 11.27M | 1741 |       1720 |  1.72K |  1 |       141 | 2.28M | 14992 | 0:07'14'' |
| Q25L120_7000000  |       7578 | 13.98M | 20022 |      9898 | 11.28M | 1768 |          0 |      0 |  0 |       138 |  2.7M | 18254 | 0:07'31'' |
| Q25L120_8000000  |       6899 | 14.47M | 23769 |      9600 | 11.28M | 1812 |       1720 |  1.72K |  1 |       136 | 3.19M | 21956 | 0:08'53'' |
| Q25L130_1000000  |       1514 | 12.66M | 17650 |      2095 |  8.32M | 4200 |       1165 | 29.29K | 24 |       450 | 4.31M | 13426 | 0:02'37'' |
| Q25L130_2000000  |       3858 | 12.43M | 10069 |      4408 | 10.76M | 3092 |       1185 |  3.68K |  3 |       264 | 1.67M |  6974 | 0:03'12'' |
| Q25L130_3000000  |       5716 | 12.54M |  9629 |      6453 | 11.14M | 2372 |       1132 |  2.22K |  2 |       203 | 1.41M |  7255 | 0:04'32'' |
| Q25L130_4000000  |       7347 | 12.78M | 10933 |      8292 | 11.24M | 1949 |       1236 |  1.24K |  1 |       164 | 1.54M |  8983 | 0:05'55'' |
| Q25L130_5000000  |       8240 | 13.09M | 13181 |      9685 | 11.27M | 1774 |       1109 |  1.11K |  1 |       149 | 1.82M | 11406 | 0:06'38'' |
| Q25L130_6000000  |       8263 | 13.45M | 15811 |     10281 | 11.29M | 1717 |          0 |      0 |  0 |       143 | 2.15M | 14094 | 0:07'59'' |
| Q25L130_7000000  |       7654 |  13.9M | 19329 |     10075 | 11.29M | 1753 |          0 |      0 |  0 |       139 | 2.61M | 17576 | 0:08'44'' |
| Q25L130_8000000  |       6923 | 14.38M | 23051 |      9622 | 11.29M | 1808 |          0 |      0 |  0 |       136 | 3.09M | 21243 | 0:09'12'' |
| Q25L140_1000000  |       1564 | 12.61M | 17108 |      2185 |  8.45M | 4156 |       1164 | 21.65K | 18 |       451 | 4.14M | 12934 | 0:02'35'' |
| Q25L140_2000000  |       3876 | 12.39M |  9760 |      4437 | 10.79M | 3045 |       1185 |   7.3K |  6 |       258 |  1.6M |  6709 | 0:03'41'' |
| Q25L140_3000000  |       5736 | 12.51M |  9360 |      6447 | 11.12M | 2326 |       1098 |  3.39K |  3 |       208 | 1.39M |  7031 | 0:04'57'' |
| Q25L140_4000000  |       7574 | 12.73M | 10596 |      8713 | 11.23M | 1910 |       1708 |  1.71K |  1 |       168 | 1.51M |  8685 | 0:05'47'' |
| Q25L140_5000000  |       8012 | 13.02M | 12598 |      9793 | 11.28M | 1805 |          0 |      0 |  0 |       151 | 1.74M | 10793 | 0:07'20'' |
| Q25L140_6000000  |       8502 | 13.38M | 15325 |     10179 | 11.29M | 1697 |          0 |      0 |  0 |       143 | 2.09M | 13628 | 0:08'24'' |
| Q25L140_7000000  |       7816 | 13.82M | 18711 |      9815 | 11.29M | 1742 |          0 |      0 |  0 |       139 | 2.53M | 16969 | 0:09'09'' |
| Q25L150_1000000  |       1571 |  12.6M | 17086 |      2141 |  8.42M | 4164 |       1148 | 21.71K | 18 |       455 | 4.16M | 12904 | 0:02'51'' |
| Q25L150_2000000  |       3956 | 12.39M |  9730 |      4536 | 10.81M | 3058 |       1123 |  5.71K |  5 |       257 | 1.58M |  6667 | 0:03'28'' |
| Q25L150_3000000  |       5919 |  12.5M |  9324 |      6807 | 11.15M | 2326 |       1199 |   1.2K |  1 |       200 | 1.35M |  6997 | 0:04'06'' |
| Q25L150_4000000  |       7447 |  12.7M | 10317 |      8631 | 11.24M | 1925 |          0 |      0 |  0 |       170 | 1.47M |  8392 | 0:12'07'' |
| Q25L150_5000000  |       8307 | 12.99M | 12375 |      9808 | 11.27M | 1782 |          0 |      0 |  0 |       151 | 1.71M | 10593 | 0:16'58'' |
| Q25L150_6000000  |       8595 | 13.37M | 15295 |     10291 | 11.29M | 1708 |       1109 |  1.11K |  1 |       143 | 2.08M | 13586 | 0:21'51'' |
| Q25L150_7000000  |       8024 | 13.77M | 18344 |     10134 | 11.29M | 1732 |          0 |      0 |  0 |       140 | 2.48M | 16612 | 0:16'35'' |
| Q30L100_1000000  |       1456 |  12.7M | 18224 |      2052 |  8.21M | 4215 |       1196 |  14.4K | 12 |       450 | 4.48M | 13997 | 0:05'27'' |
| Q30L100_2000000  |       3738 | 12.42M | 10096 |      4257 | 10.72M | 3154 |       1124 |  4.66K |  4 |       278 | 1.69M |  6938 | 0:04'48'' |
| Q30L100_3000000  |       5470 |  12.5M |  9434 |      6187 |  11.1M | 2400 |          0 |      0 |  0 |       209 |  1.4M |  7034 | 0:05'26'' |
| Q30L100_4000000  |       7246 | 12.66M | 10065 |      8337 | 11.22M | 1995 |       1105 |  1.11K |  1 |       177 | 1.44M |  8069 | 0:05'15'' |
| Q30L100_5000000  |       7889 |  12.9M | 11755 |      9394 | 11.25M | 1840 |          0 |      0 |  0 |       156 | 1.66M |  9915 | 0:06'20'' |
| Q30L100_6000000  |       8237 |  13.2M | 13977 |      9849 | 11.27M | 1783 |       1105 |  1.11K |  1 |       148 | 1.92M | 12193 | 0:06'55'' |
| Q30L100_7000000  |       8232 | 13.52M | 16400 |      9847 | 11.27M | 1754 |          0 |      0 |  0 |       143 | 2.25M | 14646 | 0:11'10'' |
| Q30L110_1000000  |       1480 | 12.68M | 17972 |      2080 |   8.2M | 4150 |       1241 | 18.57K | 15 |       459 | 4.46M | 13807 | 0:02'38'' |
| Q30L110_2000000  |       3788 | 12.39M |  9870 |      4366 | 10.76M | 3122 |       1092 |  5.85K |  5 |       269 | 1.63M |  6743 | 0:03'11'' |
| Q30L110_3000000  |       5651 | 12.47M |  9172 |      6420 | 11.08M | 2364 |       1181 |  4.69K |  4 |       209 | 1.38M |  6804 | 0:04'31'' |
| Q30L110_4000000  |       7390 | 12.65M |  9973 |      8444 | 11.22M | 1968 |       1271 |  1.27K |  1 |       178 | 1.43M |  8004 | 0:05'58'' |
| Q30L110_5000000  |       8113 | 12.88M | 11521 |      9386 | 11.27M | 1823 |       1415 |  1.42K |  1 |       154 | 1.61M |  9697 | 0:08'47'' |
| Q30L110_6000000  |       8261 | 13.17M | 13714 |      9898 | 11.25M | 1741 |          0 |      0 |  0 |       150 | 1.92M | 11973 | 0:12'24'' |
| Q30L110_7000000  |       7892 | 13.51M | 16341 |      9641 | 11.28M | 1788 |          0 |      0 |  0 |       142 | 2.23M | 14553 | 0:09'46'' |
| Q30L120_1000000  |       1538 | 12.63M | 17375 |      2134 |  8.38M | 4183 |       1249 | 18.16K | 14 |       451 | 4.23M | 13178 | 0:02'00'' |
| Q30L120_2000000  |       3786 | 12.37M |  9721 |      4316 | 10.77M | 3120 |       1277 |  3.88K |  3 |       268 |  1.6M |  6598 | 0:03'10'' |
| Q30L120_3000000  |       5773 | 12.45M |  9005 |      6436 | 11.11M | 2325 |       1328 |  3.91K |  3 |       209 | 1.34M |  6677 | 0:04'18'' |
| Q30L120_4000000  |       7173 | 12.63M |  9828 |      7983 | 11.22M | 1991 |       1105 |  3.29K |  3 |       178 |  1.4M |  7834 | 0:05'24'' |
| Q30L120_5000000  |       7939 | 12.87M | 11477 |      9325 | 11.25M | 1832 |       1700 |  2.95K |  2 |       157 | 1.62M |  9643 | 0:05'48'' |
| Q30L120_6000000  |       8368 | 13.15M | 13545 |      9976 | 11.27M | 1744 |       1069 |  1.07K |  1 |       150 | 1.88M | 11800 | 0:07'09'' |
| Q30L120_7000000  |       8237 | 13.47M | 16017 |     10160 | 11.27M | 1742 |          0 |      0 |  0 |       144 |  2.2M | 14275 | 0:07'15'' |
| Q30L130_1000000  |       1550 |  12.6M | 17053 |      2140 |  8.36M | 4134 |       1170 | 14.64K | 12 |       472 | 4.23M | 12907 | 0:02'29'' |
| Q30L130_2000000  |       3879 | 12.36M |  9631 |      4394 | 10.76M | 3102 |       1132 |  1.13K |  1 |       278 |  1.6M |  6528 | 0:03'40'' |
| Q30L130_3000000  |       5658 | 12.44M |  8853 |      6421 |  11.1M | 2354 |          0 |      0 |  0 |       209 | 1.33M |  6499 | 0:04'48'' |
| Q30L130_4000000  |       7352 |  12.6M |  9652 |      8413 |  11.2M | 1979 |       1140 |  1.14K |  1 |       185 |  1.4M |  7672 | 0:05'21'' |
| Q30L130_5000000  |       8193 | 12.81M | 11009 |      9866 | 11.25M | 1790 |       1069 |  1.07K |  1 |       160 | 1.56M |  9218 | 0:06'08'' |
| Q30L130_6000000  |       8439 | 13.11M | 13288 |     10247 | 11.27M | 1730 |       1103 |   1.1K |  1 |       150 | 1.84M | 11557 | 0:06'34'' |
| Q30L130_7000000  |       8195 | 13.43M | 15669 |     10001 | 11.29M | 1747 |          0 |      0 |  0 |       144 | 2.14M | 13922 | 0:07'06'' |
| Q30L140_1000000  |       1581 | 12.56M | 16716 |      2185 |  8.46M | 4163 |       1167 | 11.92K | 10 |       458 | 4.09M | 12543 | 0:02'19'' |
| Q30L140_2000000  |       3889 | 12.33M |  9348 |      4420 | 10.79M | 3109 |       1336 |  7.59K |  6 |       278 | 1.53M |  6233 | 0:03'20'' |
| Q30L140_3000000  |       5864 | 12.39M |  8561 |      6515 |  11.1M | 2331 |       1103 |   1.1K |  1 |       209 | 1.29M |  6229 | 0:03'51'' |
| Q30L140_4000000  |       7366 | 12.56M |  9333 |      8473 | 11.21M | 1971 |          0 |      0 |  0 |       187 | 1.35M |  7362 | 0:04'58'' |
| Q30L140_5000000  |       8574 | 12.78M | 10807 |     10063 | 11.25M | 1786 |          0 |      0 |  0 |       161 | 1.53M |  9021 | 0:06'08'' |
| Q30L140_6000000  |       8504 | 13.03M | 12679 |      9890 | 11.28M | 1737 |          0 |      0 |  0 |       151 | 1.75M | 10942 | 0:06'10'' |
| Q30L140_7000000  |       8256 | 13.37M | 15229 |     10109 | 11.28M | 1731 |          0 |      0 |  0 |       145 | 2.08M | 13498 | 0:07'13'' |
| Q30L150_1000000  |       1591 | 12.55M | 16687 |      2182 |   8.5M | 4146 |       1359 | 17.19K | 13 |       455 | 4.03M | 12528 | 0:02'37'' |
| Q30L150_2000000  |       3913 | 12.32M |  9331 |      4389 | 10.78M | 3082 |       1308 |  7.63K |  6 |       276 | 1.53M |  6243 | 0:03'18'' |
| Q30L150_3000000  |       5837 | 12.39M |  8569 |      6468 | 11.12M | 2338 |       1110 |  1.11K |  1 |       209 | 1.27M |  6230 | 0:04'12'' |
| Q30L150_4000000  |       7367 | 12.54M |  9234 |      8458 | 11.22M | 1967 |       1089 |  1.09K |  1 |       188 | 1.33M |  7266 | 0:05'13'' |
| Q30L150_5000000  |       8404 | 12.75M | 10594 |      9685 | 11.26M | 1782 |          0 |      0 |  0 |       160 | 1.49M |  8812 | 0:05'42'' |
| Q30L150_6000000  |       8793 | 13.02M | 12626 |     10361 | 11.26M | 1695 |          0 |      0 |  0 |       151 | 1.76M | 10931 | 0:06'23'' |
| Q30L150_7000000  |       8261 | 13.32M | 14913 |     10109 | 11.28M | 1730 |          0 |      0 |  0 |       146 | 2.04M | 13183 | 0:06'45'' |

| Name             | N50SRclean |    Sum |     # | N50Anchor |    Sum |    # | N50Anchor2 |   Sum | # | N50Others |   Sum |     # |   RunTime |
|:-----------------|-----------:|-------:|------:|----------:|-------:|-----:|-----------:|------:|--:|----------:|------:|------:|----------:|
| original_4000000 |       4279 | 15.81M | 36461 |      6747 |  11.1M | 2310 |       1511 | 2.73K | 2 |       124 |  4.7M | 34149 | 0:04'24'' |
| Q20L100_6000000  |       6423 | 14.76M | 26440 |      9199 | 11.27M | 1868 |          0 |     0 | 0 |       131 | 3.48M | 24572 | 0:07'48'' |
| Q20L110_6000000  |       6498 | 14.71M | 25958 |      9464 | 11.28M | 1836 |          0 |     0 | 0 |       132 | 3.43M | 24122 | 0:08'22'' |
| Q20L120_6000000  |       6820 | 14.63M | 25305 |      9567 | 11.26M | 1832 |       1194 | 1.19K | 1 |       133 | 3.36M | 23472 | 0:05'02'' |
| Q20L130_6000000  |       6903 |  14.5M | 24202 |      9515 | 11.28M | 1822 |          0 |     0 | 0 |       134 | 3.22M | 22380 | 0:04'29'' |
| Q20L140_7000000  |       6928 | 14.95M | 27644 |      9622 | 11.28M | 1785 |          0 |     0 | 0 |       133 | 3.67M | 25859 | 0:05'41'' |
| Q20L150_6000000  |       7344 | 14.19M | 21781 |      9905 | 11.27M | 1752 |       1553 | 1.55K | 1 |       136 | 2.92M | 20028 | 0:06'14'' |
| Q25L100_7000000  |       7090 | 14.11M | 21132 |      9445 | 11.27M | 1802 |          0 |     0 | 0 |       135 | 2.84M | 19330 | 0:08'03'' |
| Q25L110_7000000  |       7360 | 14.06M | 20706 |      9793 | 11.28M | 1789 |          0 |     0 | 0 |       136 | 2.79M | 18917 | 0:08'04'' |
| Q25L120_7000000  |       7578 | 13.98M | 20022 |      9898 | 11.28M | 1768 |          0 |     0 | 0 |       138 |  2.7M | 18254 | 0:05'56'' |
| Q25L130_6000000  |       8263 | 13.45M | 15811 |     10281 | 11.29M | 1717 |          0 |     0 | 0 |       143 | 2.15M | 14094 | 0:05'27'' |
| Q25L140_6000000  |       8502 | 13.38M | 15325 |     10179 | 11.29M | 1697 |          0 |     0 | 0 |       143 | 2.09M | 13628 | 0:04'41'' |
| Q25L150_6000000  |       8595 | 13.37M | 15295 |     10291 | 11.29M | 1708 |       1109 | 1.11K | 1 |       143 | 2.08M | 13586 | 0:04'51'' |
| Q30L100_7000000  |       8232 | 13.52M | 16400 |      9847 | 11.27M | 1754 |          0 |     0 | 0 |       143 | 2.25M | 14646 | 0:11'10'' |
| Q30L110_7000000  |       7892 | 13.51M | 16341 |      9641 | 11.28M | 1788 |          0 |     0 | 0 |       142 | 2.23M | 14553 | 0:09'46'' |
| Q30L120_7000000  |       8237 | 13.47M | 16017 |     10160 | 11.27M | 1742 |          0 |     0 | 0 |       144 |  2.2M | 14275 | 0:05'12'' |
| Q30L130_7000000  |       8195 | 13.43M | 15669 |     10001 | 11.29M | 1747 |          0 |     0 | 0 |       144 | 2.14M | 13922 | 0:05'35'' |
| Q30L140_7000000  |       8256 | 13.37M | 15229 |     10109 | 11.28M | 1731 |          0 |     0 | 0 |       145 | 2.08M | 13498 | 0:05'12'' |
| Q30L150_7000000  |       8261 | 13.32M | 14913 |     10109 | 11.28M | 1730 |          0 |     0 | 0 |       146 | 2.04M | 13183 | 0:05'12'' |

## Scer: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L100_6000000/anchor/pe.anchor.fa \
    Q20L110_6000000/anchor/pe.anchor.fa \
    Q20L120_6000000/anchor/pe.anchor.fa \
    Q20L130_6000000/anchor/pe.anchor.fa \
    Q20L140_7000000/anchor/pe.anchor.fa \
    Q20L150_6000000/anchor/pe.anchor.fa \
    Q25L100_7000000/anchor/pe.anchor.fa \
    Q25L110_7000000/anchor/pe.anchor.fa \
    Q25L120_7000000/anchor/pe.anchor.fa \
    Q25L130_6000000/anchor/pe.anchor.fa \
    Q25L140_6000000/anchor/pe.anchor.fa \
    Q25L150_6000000/anchor/pe.anchor.fa \
    Q30L100_7000000/anchor/pe.anchor.fa \
    Q30L110_7000000/anchor/pe.anchor.fa \
    Q30L120_7000000/anchor/pe.anchor.fa \
    Q30L130_7000000/anchor/pe.anchor.fa \
    Q30L140_7000000/anchor/pe.anchor.fa \
    Q30L150_7000000/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

faops n50 -S -C merge/anchor.merge.fasta

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
quast --no-check --threads 24 \
    -R 1_genome/genome.fa \
    Q20L100_6000000/anchor/pe.anchor.fa \
    Q20L110_6000000/anchor/pe.anchor.fa \
    Q20L120_6000000/anchor/pe.anchor.fa \
    Q20L130_6000000/anchor/pe.anchor.fa \
    Q20L140_7000000/anchor/pe.anchor.fa \
    Q20L150_6000000/anchor/pe.anchor.fa \
    Q25L100_7000000/anchor/pe.anchor.fa \
    Q25L110_7000000/anchor/pe.anchor.fa \
    Q25L120_7000000/anchor/pe.anchor.fa \
    Q25L130_6000000/anchor/pe.anchor.fa \
    Q25L140_6000000/anchor/pe.anchor.fa \
    Q25L150_6000000/anchor/pe.anchor.fa \
    Q30L100_7000000/anchor/pe.anchor.fa \
    Q30L110_7000000/anchor/pe.anchor.fa \
    Q30L120_7000000/anchor/pe.anchor.fa \
    Q30L130_7000000/anchor/pe.anchor.fa \
    Q30L140_7000000/anchor/pe.anchor.fa \
    Q30L150_7000000/anchor/pe.anchor.fa \
    merge/anchor.merge.fasta \
    1_genome/paralogs.fas \
    --label "Q20L100,Q20L110,Q20L120,Q20L130,Q20L140,Q20L150,Q25L100,Q25L110,Q25L120,Q25L130,Q25L140,Q25L150,Q30L100,Q30L110,Q30L120,Q30L130,Q30L140,Q30L150,merge,paralogs" \
    -o 9_qa
```

## Scer: 3GS

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

canu \
    -p s288c -d canu-raw-40x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=12.2m \
    -pacbio-raw 3_pacbio/pacbio.40x.fasta

canu \
    -p s288c -d canu-raw-80x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=12.2m \
    -pacbio-raw 3_pacbio/pacbio.80x.fasta

faops n50 -S -C canu-raw-40x/s288c.correctedReads.fasta.gz
faops n50 -S -C canu-raw-40x/s288c.trimmedReads.fasta.gz

faops n50 -S -C canu-raw-80x/s288c.trimmedReads.fasta.gz
```

## Scer: expand anchors

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
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

anchr cover \
    --parallel 16 \
    -c 2 -m 40 \
    -b 20 --len 1000 --idt 0.9 \
    merge/anchor.merge.fasta \
    canu-raw-40x/s288c.trimmedReads.fasta.gz \
    -o merge/anchor.cover.fasta
faops n50 -S -C merge/anchor.cover.fasta

rm -fr anchorLong
anchr overlap2 \
    --parallel 16 \
    merge/anchor.cover.fasta \
    canu-raw-40x/s288c.trimmedReads.fasta.gz \
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
            --png \
            -o group/{}.contig.fasta
    '
popd

# false strand
cat anchorLong/group/*.ovlp.tsv \
    | perl -nla -e '/anchor.+long/ or next; print $F[0] if $F[8] == 1;' \
    | sort | uniq -c

faops n50 -S -C anchorLong/group/*.contig.fasta

cat \
   anchorLong/group/non_grouped.fasta\
   anchorLong/group/*.contig.fasta \
   | faops filter -l 0 -a 2000 stdin anchorLong/contig.fasta

faops n50 -S -C anchorLong/contig.fasta

```

* contigTrim

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

rm -fr contigTrim
anchr overlap2 \
    --parallel 16 \
    anchorLong/contig.fasta \
    canu-raw-40x/s288c.contigs.fasta \
    -d contigTrim \
    -b 20 --len 2000 --idt 0.96 --all

CONTIG_COUNT=$(faops n50 -H -N 0 -C contigTrim/anchor.fasta)
echo ${CONTIG_COUNT}

rm -fr contigTrim/group
anchr group \
    --parallel 16 \
    --keep \
    contigTrim/anchorLong.db \
    contigTrim/anchorLong.ovlp.tsv \
    --range "1-${CONTIG_COUNT}" --len 2000 --idt 0.96 --max 100000 -c 1

pushd ${BASE_DIR}/contigTrim
cat group/groups.txt \
    | parallel --no-run-if-empty -j 8 '
        echo {};
        anchr orient \
            --len 2000 --idt 0.96 \
            group/{}.anchor.fasta \
            group/{}.long.fasta \
            -r group/{}.restrict.tsv \
            -o group/{}.strand.fasta;

        anchr overlap --len 2000 --idt 0.96 \
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

faops n50 -S -C contigTrim/group/*.contig.fasta

cat \
    contigTrim/group/non_grouped.fasta \
    contigTrim/group/*.contig.fasta \
    >  contigTrim/contig.fasta
faops n50 -S -C contigTrim/contig.fasta

```

* quast

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

rm -fr 9_qa_contig
quast --no-check --threads 24 \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/anchor.cover.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-raw-40x/s288c.contigs.fasta \
    canu-raw-all/s288c.contigs.fasta \
    1_genome/paralogs.fas \
    --label "merge,cover,contig,contigTrim,canu-40x,canu-all,paralogs" \
    -o 9_qa_contig

```

# *Drosophila melanogaster* iso-1

* Genome: [Ensembl 82](http://sep2015.archive.ensembl.org/Drosophila_melanogaster/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.0661

## Dmel: download

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
```

## Dmel: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 80, 90, and 100

```bash
BASE_DIR=$HOME/data/anchr/iso_1

# get the default adapter file
# anchr trim --help
cd ${BASE_DIR}
parallel --no-run-if-empty -j 2 "
    scythe \
        2_illumina/{}.fq.gz \
        -q sanger \
        -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
        --quiet \
        | pigz -p 4 -c \
        > 2_illumina/{}.scythe.fq.gz
    " ::: R1 R2

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
    " ::: 20 25 30 ::: 80 90 100

#rsync -avP -e "ssh -T -c arcfour -o Compression=no -x" ~/data/anchr/iso_1/2_illumina/ wangq@wq.nju.edu.cn:data/anchr/iso_1/2_illumina

```

* Stats

```bash
BASE_DIR=$HOME/data/anchr/iso_1
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
    for len in 80 90 100; do
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
| Genome   | 25286936 |   137567477 |         8 |
| Paralogs |     4031 |    13665900 |      4492 |
| Illumina |      101 | 18115734306 | 179363706 |
| PacBio   |    41580 |  5620710497 |    630193 |
| scythe   |      101 | 17655354009 | 179363706 |
| Q20L80   |      101 | 15632724201 | 155343162 |
| Q20L90   |      101 | 15298786230 | 151707356 |
| Q20L100  |      101 | 14684322086 | 145392184 |
| Q25L80   |      101 | 14399986653 | 143205838 |
| Q25L90   |      101 | 14001700581 | 138873692 |
| Q25L100  |      101 | 13236083908 | 131053048 |
| Q30L80   |      101 | 11913411932 | 118801086 |
| Q30L90   |      101 | 11336899313 | 112535528 |
| Q30L100  |      101 | 10451578620 | 103487252 |

## Dmel: down sampling

```bash
BASE_DIR=$HOME/data/anchr/iso_1
cd ${BASE_DIR}

# works on bash 3
ARRAY=( "2_illumina/Q20L80:Q20L80"
        "2_illumina/Q20L90:Q20L90"
        "2_illumina/Q20L100:Q20L100"
        "2_illumina/Q25L80:Q25L80"
        "2_illumina/Q25L90:Q25L90"
        "2_illumina/Q25L100:Q25L100"
        "2_illumina/Q30L80:Q30L80"
        "2_illumina/Q30L90:Q30L90"
        "2_illumina/Q30L100:Q30L100"
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

## Dmel: generate k-unitigs/super-reads

```bash
BASE_DIR=$HOME/data/anchr/iso_1
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L80 Q20L90 Q20L100
        Q25L80 Q25L90 Q25L100
        Q30L80 Q30L90 Q30L100
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

        if [ -e ${BASE_DIR}/{}/pe.cor.fa ]; then
            echo '    pe.cor.fa already presents'
            exit;
        fi

        cd ${BASE_DIR}/{}
        anchr superreads \
            R1.fq.gz R2.fq.gz \
            --nosr -p 8 \
            -o superreads.sh
        bash superreads.sh
    "

```

Clear intermediate files.

```bash
cd $HOME/data/anchr/iso_1/

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## Dmel: create anchors

```bash
BASE_DIR=$HOME/data/anchr/iso_1
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L80 Q20L90 Q20L100
        Q25L80 Q25L90 Q25L100
        Q30L80 Q30L90 Q30L100
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

## Dmel: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/iso_1
cd ${BASE_DIR}

REAL_G=137567477

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

perl -e '
    for my $n (
        qw{
        Q20L80 Q20L90 Q20L100
        Q25L80 Q25L90 Q25L100
        Q30L80 Q30L90 Q30L100
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 8 "
        if [ ! -d ${BASE_DIR}/{} ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${BASE_DIR}/{} ${REAL_G}
    " >> ${BASE_DIR}/stat1.md

cat stat1.md
```

* Stats of anchors

```bash
BASE_DIR=$HOME/data/anchr/iso_1
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

perl -e '
    for my $n (
        qw{
        Q20L80 Q20L90 Q20L100
        Q25L80 Q25L90 Q25L100
        Q30L80 Q30L90 Q30L100
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 16 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

| Name    |  SumFq | CovFq | AvgRead | Kmer |  SumFa | Discard% |   RealG |    EstG | Est/Real |   SumKU | SumSR |   RunTime |
|:--------|-------:|------:|--------:|-----:|-------:|---------:|--------:|--------:|---------:|--------:|------:|----------:|
| Q20L80  | 15.63G | 113.6 |     100 |   71 | 13.98G |  10.595% | 137.57M | 127.58M |     0.93 | 185.32M |     0 | 3:05'14'' |
| Q20L90  |  15.3G | 111.2 |     100 |   71 |  13.7G |  10.465% | 137.57M | 127.36M |     0.93 | 183.28M |     0 | 3:03'23'' |
| Q20L100 | 14.68G | 106.7 |     100 |   71 | 13.17G |  10.314% | 137.57M | 127.06M |     0.92 | 180.77M |     0 | 2:32'58'' |
| Q25L80  |  14.4G | 104.7 |     100 |   71 | 13.14G |   8.722% | 137.57M | 126.69M |     0.92 | 178.21M |     0 | 2:35'39'' |
| Q25L90  |    14G | 101.8 |     100 |   71 | 12.79G |   8.674% | 137.57M | 126.54M |     0.92 | 176.79M |     0 | 2:00'59'' |
| Q25L100 | 13.24G |  96.2 |     100 |   71 | 12.09G |   8.685% | 137.57M | 126.32M |     0.92 |    175M |     0 | 2:33'22'' |
| Q30L80  | 11.91G |  86.6 |     100 |   71 | 11.18G |   6.173% | 137.57M | 125.73M |     0.91 | 170.87M |     0 | 1:35'19'' |
| Q30L90  | 11.34G |  82.4 |     100 |   71 | 10.64G |   6.138% | 137.57M | 125.57M |     0.91 | 169.59M |     0 | 1:12'59'' |
| Q30L100 | 10.45G |  76.0 |     100 |   71 |  9.81G |   6.170% | 137.57M | 125.34M |     0.91 |  168.2M |     0 | 1:06'58'' |

| Name    | N50SRclean |     Sum |      # | N50Anchor |     Sum |     # | N50Anchor2 | Sum | # | N50Others |    Sum |      # |   RunTime |
|:--------|-----------:|--------:|-------:|----------:|--------:|------:|-----------:|----:|--:|----------:|-------:|-------:|----------:|
| Q20L80  |       3177 | 185.32M | 712171 |      7112 | 114.48M | 23516 |          0 |   0 | 0 |        94 | 70.84M | 688655 | 1:45'22'' |
| Q20L90  |       3491 | 183.28M | 687679 |      7675 | 114.77M | 22370 |          0 |   0 | 0 |        95 | 68.51M | 665309 | 1:42'18'' |
| Q20L100 |       3842 | 180.77M | 658356 |      8309 | 115.03M | 21227 |          0 |   0 | 0 |        95 | 65.74M | 637129 | 1:51'59'' |
| Q25L80  |       4148 | 178.21M | 629524 |      8669 | 115.07M | 20601 |          0 |   0 | 0 |        95 | 63.14M | 608923 | 1:33'21'' |
| Q25L90  |       4419 | 176.79M | 612729 |      9129 | 115.19M | 19905 |          0 |   0 | 0 |        96 |  61.6M | 592824 | 1:35'56'' |
| Q25L100 |       4708 |    175M | 592448 |      9512 | 115.23M | 19317 |          0 |   0 | 0 |        96 | 59.76M | 573131 | 1:20'47'' |
| Q30L80  |       4633 | 170.87M | 547668 |      9078 | 114.49M | 20185 |          0 |   0 | 0 |        99 | 56.38M | 527483 | 1:16'46'' |
| Q30L90  |       4653 | 169.59M | 533903 |      9104 | 114.19M | 20266 |          0 |   0 | 0 |       101 |  55.4M | 513637 | 1:14'08'' |
| Q30L100 |       4503 |  168.2M | 520452 |      8889 | 113.54M | 20734 |          0 |   0 | 0 |       102 | 54.66M | 499718 | 1:06'14'' |

## Dmel: merge anchors from different groups of reads

```bash
BASE_DIR=$HOME/data/anchr/iso_1
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L80/anchor/pe.anchor.fa \
    Q20L90/anchor/pe.anchor.fa \
    Q20L100/anchor/pe.anchor.fa \
    Q25L80/anchor/pe.anchor.fa \
    Q25L90/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    Q30L80/anchor/pe.anchor.fa \
    Q30L90/anchor/pe.anchor.fa \
    Q30L100/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

faops n50 -S -C merge/anchor.merge.fasta

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
quast --no-check --threads 24 \
    -R 1_genome/genome.fa \
    Q20L80/anchor/pe.anchor.fa \
    Q20L90/anchor/pe.anchor.fa \
    Q20L100/anchor/pe.anchor.fa \
    Q25L80/anchor/pe.anchor.fa \
    Q25L90/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    Q30L80/anchor/pe.anchor.fa \
    Q30L90/anchor/pe.anchor.fa \
    Q30L100/anchor/pe.anchor.fa \
    merge/anchor.merge.fasta \
    1_genome/paralogs.fas \
    --label "Q20L80,Q20L90,Q20L100,Q25L80,Q25L90,Q25L100,Q30L80,Q30L90,Q30L100,merge,paralogs" \
    -o 9_qa

```

## Dmel: 3GS

```bash
BASE_DIR=$HOME/data/anchr/iso_1
cd ${BASE_DIR}

cd 3_pacbio/
ln -s pacbio.fasta pacbio.40x.fasta

cd ${BASE_DIR}
canu \
    -p iso_1 -d canu-raw-40x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=137.6m \
    -pacbio-raw 3_pacbio/pacbio.40x.fasta

faops n50 -S -C 3_pacbio/pacbio.40x.fasta

faops n50 -S -C canu-raw-40x/iso_1.correctedReads.fasta.gz
faops n50 -S -C canu-raw-40x/iso_1.trimmedReads.fasta.gz

```

## Dmel: expand anchors

* anchorLong

```bash
BASE_DIR=$HOME/data/anchr/iso_1
cd ${BASE_DIR}

anchr cover \
    --parallel 16 \
    -c 2 -m 40 \
    -b 50 --len 1000 --idt 0.9 \
    merge/anchor.merge.fasta \
    canu-raw-40x/iso_1.trimmedReads.fasta.gz \
    -o merge/anchor.cover.fasta
faops n50 -S -C merge/anchor.cover.fasta

rm -fr anchorLong
anchr overlap2 \
    --parallel 16 \
    merge/anchor.cover.fasta \
    canu-raw-40x/iso_1.trimmedReads.fasta.gz \
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
            --png \
            -o group/{}.contig.fasta
    '
popd

# false strand
cat anchorLong/group/*.ovlp.tsv \
    | perl -nla -e '/anchor.+long/ or next; print $F[0] if $F[8] == 1;' \
    | sort | uniq -c

faops n50 -S -C anchorLong/group/*.contig.fasta

cat \
   anchorLong/group/non_grouped.fasta\
   anchorLong/group/*.contig.fasta \
   | faops filter -l 0 -a 2000 stdin anchorLong/contig.fasta

faops n50 -S -C anchorLong/contig.fasta

```

* contigTrim

```bash
BASE_DIR=$HOME/data/anchr/iso_1
cd ${BASE_DIR}

rm -fr contigTrim
anchr overlap2 \
    --parallel 16 \
    anchorLong/contig.fasta \
    canu-raw-40x/iso_1.contigs.fasta \
    -d contigTrim \
    -b 50 --len 2000 --idt 0.96 --all

CONTIG_COUNT=$(faops n50 -H -N 0 -C contigTrim/anchor.fasta)
echo ${CONTIG_COUNT}

rm -fr contigTrim/group
anchr group \
    --parallel 16 \
    --keep \
    contigTrim/anchorLong.db \
    contigTrim/anchorLong.ovlp.tsv \
    --range "1-${CONTIG_COUNT}" --len 2000 --idt 0.96 --max 20000 -c 1 --png

pushd ${BASE_DIR}/contigTrim
cat group/groups.txt \
    | parallel --no-run-if-empty -j 8 '
        echo {};
        anchr orient \
            --len 2000 --idt 0.96 \
            group/{}.anchor.fasta \
            group/{}.long.fasta \
            -r group/{}.restrict.tsv \
            -o group/{}.strand.fasta;

        anchr overlap --len 2000 --idt 0.96 --all \
            group/{}.strand.fasta \
            -o stdout \
            | anchr restrict \
                stdin group/{}.restrict.tsv \
                -o group/{}.ovlp.tsv;

        anchr layout \
            group/{}.ovlp.tsv \
            group/{}.relation.tsv \
            group/{}.strand.fasta \
            --png \
            -o group/{}.contig.fasta
    '
popd

faops n50 -S -C contigTrim/group/*.contig.fasta

cat \
    contigTrim/group/non_grouped.fasta \
    contigTrim/group/*.contig.fasta \
    >  contigTrim/contig.fasta
faops n50 -S -C contigTrim/contig.fasta

```

* quast

```bash
BASE_DIR=$HOME/data/anchr/iso_1
cd ${BASE_DIR}

rm -fr 9_qa_contig
quast --no-check --threads 24 \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/anchor.cover.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-raw-40x/iso_1.contigs.fasta \
    1_genome/paralogs.fas \
    --label "merge,cover,contig,contigTrim,canu-40x,paralogs" \
    -o 9_qa_contig

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
    | xargs zcat \
    | faops filter -l 0 stdin pacbio.fasta
```

## Cele: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 70, 80, 90, and 100

```bash
BASE_DIR=$HOME/data/anchr/n2

# get the default adapter file
# anchr trim --help
cd ${BASE_DIR}
parallel --no-run-if-empty -j 2 "
    scythe \
        2_illumina/{}.fq.gz \
        -q sanger \
        -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
        --quiet \
        | pigz -p 4 -c \
        > 2_illumina/{}.scythe.fq.gz
    " ::: R1 R2

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
    " ::: 20 25 30 ::: 70 80 90 100

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
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md

for qual in 20 25 30; do
    for len in 70 80 90 100; do
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
| scythe   |      100 | 11402318206 | 115608926 |
| Q20L70   |      100 | 10472350403 | 105202422 |
| Q20L80   |      100 | 10377586183 | 104082400 |
| Q20L90   |      100 | 10200869231 | 102123772 |
| Q20L100  |      100 |  9927543600 |  99275436 |
| Q25L70   |      100 |  9056627679 |  91005544 |
| Q25L80   |      100 |  8954210300 |  89801900 |
| Q25L90   |      100 |  8789905902 |  87985860 |
| Q25L100  |      100 |  8582060000 |  85820600 |
| Q30L70   |      100 |  4641960030 |  46793938 |
| Q30L80   |      100 |  4532887386 |  45511838 |
| Q30L90   |      100 |  4397405332 |  44026358 |
| Q30L100  |      100 |  4258404000 |  42584040 |

## Cele: down sampling

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

# works on bash 3
ARRAY=( "2_illumina/Q20L70:Q20L70"
        "2_illumina/Q20L80:Q20L80"
        "2_illumina/Q20L90:Q20L90"
        "2_illumina/Q20L100:Q20L100"
        "2_illumina/Q25L70:Q25L70"
        "2_illumina/Q25L80:Q25L80"
        "2_illumina/Q25L90:Q25L90"
        "2_illumina/Q25L100:Q25L100"
        "2_illumina/Q30L70:Q30L70"
        "2_illumina/Q30L80:Q30L80"
        "2_illumina/Q30L90:Q30L90"
        "2_illumina/Q30L100:Q30L100"
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

## Cele: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L70 Q20L80 Q20L90 Q20L100
        Q25L70 Q25L80 Q25L90 Q25L100
        Q30L70 Q30L80 Q30L90 Q30L100
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

        if [ -e ${BASE_DIR}/{}/pe.cor.fa ]; then
            echo '    pe.cor.fa already presents'
            exit;
        fi

        cd ${BASE_DIR}/{}
        anchr superreads \
            R1.fq.gz R2.fq.gz \
            --nosr -p 8 \
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
        Q20L70 Q20L80 Q20L90 Q20L100
        Q25L70 Q25L80 Q25L90 Q25L100
        Q30L70 Q30L80 Q30L90 Q30L100
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
        Q20L70 Q20L80 Q20L90 Q20L100
        Q25L70 Q25L80 Q25L90 Q25L100
        Q30L70 Q30L80 Q30L90 Q30L100
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 8 "
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
        Q20L70 Q20L80 Q20L90 Q20L100
        Q25L70 Q25L80 Q25L90 Q25L100
        Q30L70 Q30L80 Q30L90 Q30L100
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 16 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

| Name    |  SumFq | CovFq | AvgRead | Kmer | SumFa | Discard% |   RealG |   EstG | Est/Real |   SumKU | SumSR |   RunTime |
|:--------|-------:|------:|--------:|-----:|------:|---------:|--------:|-------:|---------:|--------:|------:|----------:|
| Q20L70  | 10.47G | 104.4 |      99 |   71 | 6.34G |  39.471% | 100.29M | 98.96M |     0.99 |  115.2M |     0 | 4:55'55'' |
| Q20L80  | 10.38G | 103.5 |      99 |   71 | 6.28G |  39.478% | 100.29M | 98.92M |     0.99 | 115.01M |     0 | 4:54'43'' |
| Q20L90  |  10.2G | 101.7 |      99 |   71 | 6.17G |  39.478% | 100.29M | 98.85M |     0.99 | 114.67M |     0 | 4:55'12'' |
| Q20L100 |  9.93G |  99.0 |     100 |   71 | 6.01G |  39.466% | 100.29M | 98.77M |     0.98 | 114.31M |     0 | 4:54'11'' |
| Q25L70  |  9.06G |  90.3 |      99 |   71 | 5.63G |  37.829% | 100.29M | 98.66M |     0.98 | 113.88M |     0 | 3:07'03'' |
| Q25L80  |  8.95G |  89.3 |      99 |   71 | 5.56G |  37.921% | 100.29M | 98.62M |     0.98 | 113.74M |     0 | 3:05'23'' |
| Q25L90  |  8.79G |  87.6 |      99 |   71 | 5.45G |  38.021% | 100.29M | 98.56M |     0.98 | 113.55M |     0 | 2:29'06'' |
| Q25L100 |  8.58G |  85.6 |     100 |   71 | 5.31G |  38.091% | 100.29M |  98.5M |     0.98 | 113.36M |     0 | 2:31'54'' |
| Q30L70  |  4.64G |  46.3 |      98 |   71 | 3.39G |  26.998% | 100.29M | 97.53M |     0.97 | 113.18M |     0 | 0:37'22'' |
| Q30L80  |  4.53G |  45.2 |      99 |   71 | 3.29G |  27.383% | 100.29M | 97.42M |     0.97 | 113.02M |     0 | 0:36'46'' |
| Q30L90  |   4.4G |  43.8 |      99 |   71 | 3.17G |  27.820% | 100.29M | 97.28M |     0.97 | 112.84M |     0 | 0:28'19'' |
| Q30L100 |  4.26G |  42.5 |     100 |   71 | 3.06G |  28.115% | 100.29M | 97.14M |     0.97 | 112.75M |     0 | 0:27'34'' |

| Name    | N50SRclean |     Sum |      # | N50Anchor |    Sum |     # | N50Anchor2 |   Sum | # | N50Others |    Sum |      # |   RunTime |
|:--------|-----------:|--------:|-------:|----------:|-------:|------:|-----------:|------:|--:|----------:|-------:|-------:|----------:|
| Q20L70  |       6074 |  115.2M | 200029 |      8770 | 90.57M | 17100 |          0 |     0 | 0 |       141 | 24.63M | 182929 | 0:53'53'' |
| Q20L80  |       6111 | 115.01M | 197836 |      8863 | 90.58M | 17020 |          0 |     0 | 0 |       141 | 24.43M | 180816 | 0:50'56'' |
| Q20L90  |       6301 | 114.67M | 194172 |      9087 | 90.57M | 16791 |          0 |     0 | 0 |       141 |  24.1M | 177381 | 0:53'49'' |
| Q20L100 |       6450 | 114.31M | 190397 |      9349 |  90.5M | 16537 |          0 |     0 | 0 |       141 | 23.81M | 173860 | 0:52'13'' |
| Q25L70  |       6717 | 113.88M | 187061 |      9745 | 90.11M | 16129 |          0 |     0 | 0 |       141 | 23.77M | 170932 | 0:33'22'' |
| Q25L80  |       6766 | 113.74M | 185763 |      9869 | 90.08M | 16071 |          0 |     0 | 0 |       141 | 23.66M | 169692 | 0:24'46'' |
| Q25L90  |       6874 | 113.55M | 184068 |     10058 | 89.96M | 15960 |       1073 | 1.07K | 1 |       141 | 23.59M | 168107 | 0:33'04'' |
| Q25L100 |       6874 | 113.36M | 182581 |     10064 | 89.82M | 15932 |       1073 | 1.07K | 1 |       141 | 23.54M | 166648 | 0:30'58'' |
| Q30L70  |       3444 | 113.18M | 209911 |      5777 | 82.12M | 20914 |          0 |     0 | 0 |       199 | 31.05M | 188997 | 0:17'12'' |
| Q30L80  |       3337 | 113.02M | 210193 |      5616 | 81.62M | 21134 |          0 |     0 | 0 |       203 |  31.4M | 189059 | 0:49'49'' |
| Q30L90  |       3148 | 112.84M | 211688 |      5349 | 80.79M | 21580 |          0 |     0 | 0 |       210 | 32.06M | 190108 | 0:33'40'' |
| Q30L100 |       2916 | 112.75M | 214570 |      5040 | 79.72M | 22141 |          0 |     0 | 0 |       218 | 33.03M | 192429 | 0:27'31'' |

## Cele: merge anchors from different groups of reads

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L70/anchor/pe.anchor.fa \
    Q20L80/anchor/pe.anchor.fa \
    Q20L90/anchor/pe.anchor.fa \
    Q20L100/anchor/pe.anchor.fa \
    Q25L70/anchor/pe.anchor.fa \
    Q25L80/anchor/pe.anchor.fa \
    Q25L90/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    Q30L70/anchor/pe.anchor.fa \
    Q30L80/anchor/pe.anchor.fa \
    Q30L90/anchor/pe.anchor.fa \
    Q30L100/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

faops n50 -S -C merge/anchor.merge.fasta

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
quast --no-check --threads 24 \
    -R 1_genome/genome.fa \
    Q20L70/anchor/pe.anchor.fa \
    Q20L80/anchor/pe.anchor.fa \
    Q20L90/anchor/pe.anchor.fa \
    Q20L100/anchor/pe.anchor.fa \
    Q25L70/anchor/pe.anchor.fa \
    Q25L80/anchor/pe.anchor.fa \
    Q25L90/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    Q30L70/anchor/pe.anchor.fa \
    Q30L80/anchor/pe.anchor.fa \
    Q30L90/anchor/pe.anchor.fa \
    Q30L100/anchor/pe.anchor.fa \
    merge/anchor.merge.fasta \
    1_genome/paralogs.fas \
    --label "Q20L70,Q20L80,Q20L90,Q20L100,Q25L70,Q25L80,Q25L90,Q25L100,Q30L70,Q30L80,Q30L90,Q30L100,merge,paralogs" \
    -o 9_qa

```

## Cele: 3GS

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

head -n 740000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.40x.fasta
faops n50 -S -C 3_pacbio/pacbio.40x.fasta

cd ${BASE_DIR}
canu \
    -p n2 -d canu-raw-40x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=100.3m \
    -pacbio-raw 3_pacbio/pacbio.40x.fasta

faops n50 -S -C 3_pacbio/pacbio.40x.fasta

faops n50 -S -C canu-raw-40x/n2.correctedReads.fasta.gz
faops n50 -S -C canu-raw-40x/n2.trimmedReads.fasta.gz

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
faops n50 -S -C merge/anchor.cover.fasta

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
            --png \
            -o group/{}.contig.fasta
    '
popd

# false strand
cat anchorLong/group/*.ovlp.tsv \
    | perl -nla -e '/anchor.+long/ or next; print $F[0] if $F[8] == 1;' \
    | sort | uniq -c

faops n50 -S -C anchorLong/group/*.contig.fasta

cat \
   anchorLong/group/non_grouped.fasta\
   anchorLong/group/*.contig.fasta \
   | faops filter -l 0 -a 2000 stdin anchorLong/contig.fasta

faops n50 -S -C anchorLong/contig.fasta

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
    -b 50 --len 2000 --idt 0.96 --all

CONTIG_COUNT=$(faops n50 -H -N 0 -C contigTrim/anchor.fasta)
echo ${CONTIG_COUNT}

rm -fr contigTrim/group
anchr group \
    --parallel 16 \
    --keep \
    contigTrim/anchorLong.db \
    contigTrim/anchorLong.ovlp.tsv \
    --range "1-${CONTIG_COUNT}" --len 2000 --idt 0.96 --max 20000 -c 1 --png

pushd ${BASE_DIR}/contigTrim
cat group/groups.txt \
    | parallel --no-run-if-empty -j 8 '
        echo {};
        anchr orient \
            --len 2000 --idt 0.96 \
            group/{}.anchor.fasta \
            group/{}.long.fasta \
            -r group/{}.restrict.tsv \
            -o group/{}.strand.fasta;

        anchr overlap --len 2000 --idt 0.96 --all \
            group/{}.strand.fasta \
            -o stdout \
            | anchr restrict \
                stdin group/{}.restrict.tsv \
                -o group/{}.ovlp.tsv;

        anchr layout \
            group/{}.ovlp.tsv \
            group/{}.relation.tsv \
            group/{}.strand.fasta \
            --png \
            -o group/{}.contig.fasta
    '
popd

faops n50 -S -C contigTrim/group/*.contig.fasta

cat \
    contigTrim/group/non_grouped.fasta \
    contigTrim/group/*.contig.fasta \
    >  contigTrim/contig.fasta
faops n50 -S -C contigTrim/contig.fasta

```

* quast

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

rm -fr 9_qa_contig
quast --no-check --threads 24 \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/anchor.cover.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-raw-40x/n2.contigs.fasta \
    1_genome/paralogs.fas \
    --label "merge,cover,contig,contigTrim,canu-40x,paralogs" \
    -o 9_qa_contig

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

https://www.ncbi.nlm.nih.gov/biosample/4539665

```bash
mkdir -p ~/data/anchr/col_0/3_pacbio
cd ~/data/anchr/col_0/3_pacbio

# download from sra
cat <<EOF > hdf5.txt
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405242_SRR3405242_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405243_SRR3405243_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405244_SRR3405244_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405245_SRR3405245_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405246_SRR3405246_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405247_SRR3405247_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405248_SRR3405248_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405249_SRR3405249_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405250_SRR3405250_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405251_SRR3405251_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405252_SRR3405252_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405253_SRR3405253_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405254_SRR3405254_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405255_SRR3405255_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405256_SRR3405256_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405257_SRR3405257_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405258_SRR3405258_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405259_SRR3405259_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405260_SRR3405260_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405261_SRR3405261_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405262_SRR3405262_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405263_SRR3405263_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405264_SRR3405264_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405265_SRR3405265_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405266_SRR3405266_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405267_SRR3405267_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405268_SRR3405268_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405269_SRR3405269_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405270_SRR3405270_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405271_SRR3405271_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405272_SRR3405272_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405273_SRR3405273_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405274_SRR3405274_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405275_SRR3405275_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405276_SRR3405276_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405277_SRR3405277_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405278_SRR3405278_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405279_SRR3405279_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405280_SRR3405280_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405281_SRR3405281_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405282_SRR3405282_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405283_SRR3405283_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405284_SRR3405284_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405285_SRR3405285_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405286_SRR3405286_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405287_SRR3405287_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405288_SRR3405288_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405289_SRR3405289_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR3405290_SRR3405290_hdf5.tgz
EOF

aria2c -x 9 -s 3 -c -i hdf5.txt

```


## Atha: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 70, 80, 90, and 100

```bash
BASE_DIR=$HOME/data/anchr/col_0

# get the default adapter file
# anchr trim --help
cd ${BASE_DIR}
parallel --no-run-if-empty -j 2 "
    scythe \
        2_illumina/{}.fq.gz \
        -q sanger \
        -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
        --quiet \
        | pigz -p 4 -c \
        > 2_illumina/{}.scythe.fq.gz
    " ::: R1 R2

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
    " ::: 20 25 30 ::: 70 80 90 100

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
    for len in 70 80 90 100; do
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
| PacBio   |          |             |           |
| scythe   |      100 | 14859828281 | 149486290 |
| Q20L70   |      100 | 13225437735 | 133614584 |
| Q20L80   |      100 | 12829458794 | 129008212 |
| Q20L90   |      100 | 12277500278 | 122999098 |
| Q20L100  |      100 | 11657500600 | 116575006 |
| Q25L70   |      100 | 12010989921 | 121705042 |
| Q25L80   |      100 | 11511159939 | 115877888 |
| Q25L90   |      100 | 10876573032 | 108964030 |
| Q25L100  |      100 | 10306275200 | 103062752 |
| Q30L70   |      100 |  9997814782 | 102202028 |
| Q30L80   |      100 |  9282649748 |  93816534 |
| Q30L90   |      100 |  8452773268 |  84758028 |
| Q30L100  |      100 |  7776826400 |  77768264 |

## Atha: down sampling

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

# works on bash 3
ARRAY=( "2_illumina/Q20L70:Q20L70"
        "2_illumina/Q20L80:Q20L80"
        "2_illumina/Q20L90:Q20L90"
        "2_illumina/Q20L100:Q20L100"
        "2_illumina/Q25L70:Q25L70"
        "2_illumina/Q25L80:Q25L80"
        "2_illumina/Q25L90:Q25L90"
        "2_illumina/Q25L100:Q25L100"
        "2_illumina/Q30L70:Q30L70"
        "2_illumina/Q30L80:Q30L80"
        "2_illumina/Q30L90:Q30L90"
        "2_illumina/Q30L100:Q30L100"
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
        Q20L70 Q20L80 Q20L90 Q20L100
        Q25L70 Q25L80 Q25L90 Q25L100
        Q30L70 Q30L80 Q30L90 Q30L100
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

        if [ -e ${BASE_DIR}/{}/pe.cor.fa ]; then
            echo '    pe.cor.fa already presents'
            exit;
        fi

        cd ${BASE_DIR}/{}
        anchr superreads \
            R1.fq.gz R2.fq.gz \
            --nosr -p 8 \
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
        Q20L70 Q20L80 Q20L90 Q20L100
        Q25L70 Q25L80 Q25L90 Q25L100
        Q30L70 Q30L80 Q30L90 Q30L100
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
        Q20L70 Q20L80 Q20L90 Q20L100
        Q25L70 Q25L80 Q25L90 Q25L100
        Q30L70 Q30L80 Q30L90 Q30L100
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 8 "
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
        Q20L70 Q20L80 Q20L90 Q20L100
        Q25L70 Q25L80 Q25L90 Q25L100
        Q30L70 Q30L80 Q30L90 Q30L100
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 16 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

| Name    |  SumFq | CovFq | AvgRead | Kmer |  SumFa | Discard% |   RealG |    EstG | Est/Real |   SumKU | SumSR |   RunTime |
|:--------|-------:|------:|--------:|-----:|-------:|---------:|--------:|--------:|---------:|--------:|------:|----------:|
| Q20L70  | 13.23G | 110.5 |      98 |   71 | 10.94G |  17.284% | 119.67M | 282.25M |     2.36 | 401.66M |     0 | 2:41'44'' |
| Q20L80  | 12.83G | 107.2 |      99 |   71 | 10.63G |  17.140% | 119.67M | 273.46M |     2.29 | 387.84M |     0 | 2:26'10'' |
| Q20L90  | 12.28G | 102.6 |      99 |   71 |  10.2G |  16.936% | 119.67M | 261.13M |     2.18 | 367.93M |     0 | 2:17'59'' |
| Q20L100 | 11.66G |  97.4 |     100 |   71 |   9.7G |  16.772% | 119.67M | 248.69M |     2.08 | 347.83M |     0 | 1:26'39'' |
| Q25L70  | 12.01G | 100.4 |      98 |   71 | 10.06G |  16.220% | 119.67M | 257.59M |     2.15 | 358.32M |     0 | 1:34'55'' |
| Q25L80  | 11.51G |  96.2 |      99 |   71 |  9.65G |  16.148% | 119.67M | 246.75M |     2.06 | 341.91M |     0 | 1:36'48'' |
| Q25L90  | 10.88G |  90.9 |      99 |   71 |  9.13G |  16.032% | 119.67M |  232.8M |     1.95 | 320.24M |     0 | 1:30'00'' |
| Q25L100 | 10.31G |  86.1 |     100 |   71 |  8.66G |  15.965% | 119.67M | 221.73M |     1.85 | 302.79M |     0 | 1:23'25'' |
| Q30L70  |    10G |  83.5 |      97 |   71 |   8.5G |  15.023% | 119.67M | 215.18M |     1.80 | 288.37M |     0 | 1:45'38'' |
| Q30L80  |  9.28G |  77.6 |      98 |   71 |  7.89G |  14.958% | 119.67M | 201.06M |     1.68 | 267.67M |     0 | 1:56'52'' |
| Q30L90  |  8.45G |  70.6 |      99 |   71 |   7.2G |  14.862% | 119.67M |  185.4M |     1.55 | 244.24M |     0 | 1:24'40'' |
| Q30L100 |  7.78G |  65.0 |     100 |   71 |  6.63G |  14.729% | 119.67M | 174.61M |     1.46 | 227.55M |     0 | 1:14'12'' |

| Name    | N50SRclean |     Sum |       # | N50Anchor |     Sum |     # | N50Anchor2 | Sum | # | N50Others |     Sum |       # |   RunTime |
|:--------|-----------:|--------:|--------:|----------:|--------:|------:|-----------:|----:|--:|----------:|--------:|--------:|----------:|
| Q20L70  |        135 | 401.66M | 2627085 |      9219 | 105.53M | 18397 |          0 |   0 | 0 |       107 | 296.13M | 2608688 | 1:29'05'' |
| Q20L80  |        137 | 387.84M | 2498917 |      9643 | 105.43M | 17798 |          0 |   0 | 0 |       107 | 282.42M | 2481119 | 1:25'29'' |
| Q20L90  |        140 | 367.93M | 2322890 |     10087 | 105.24M | 17085 |          0 |   0 | 0 |       108 | 262.69M | 2305805 | 1:22'07'' |
| Q20L100 |        141 | 347.83M | 2153029 |     10355 | 104.98M | 16747 |          0 |   0 | 0 |       108 | 242.85M | 2136282 | 1:15'54'' |
| Q25L70  |        139 | 358.32M | 2260702 |     10167 | 105.08M | 17010 |          0 |   0 | 0 |       106 | 253.24M | 2243692 | 1:00'14'' |
| Q25L80  |        141 | 341.91M | 2108999 |     10329 | 104.95M | 16814 |          0 |   0 | 0 |       107 | 236.95M | 2092185 | 1:07'04'' |
| Q25L90  |        144 | 320.24M | 1918340 |     10130 |  104.7M | 16918 |          0 |   0 | 0 |       107 | 215.55M | 1901422 | 1:00'35'' |
| Q25L100 |        149 | 302.79M | 1769463 |      9817 | 104.41M | 17286 |          0 |   0 | 0 |       107 | 198.37M | 1752177 | 0:55'34'' |
| Q30L70  |        149 | 288.37M | 1679588 |      8068 | 103.51M | 19669 |          0 |   0 | 0 |       104 | 184.86M | 1659919 | 0:44'25'' |
| Q30L80  |        163 | 267.67M | 1482050 |      7745 |  103.1M | 20165 |          0 |   0 | 0 |       105 | 164.57M | 1461885 | 0:55'56'' |
| Q30L90  |        193 | 244.24M | 1269314 |      7056 | 102.22M | 21349 |          0 |   0 | 0 |       106 | 142.02M | 1247965 | 0:53'02'' |
| Q30L100 |        262 | 227.55M | 1121332 |      6335 | 101.11M | 22760 |          0 |   0 | 0 |       107 | 126.44M | 1098572 | 0:43'15'' |

## Atha: merge anchors from different groups of reads

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L70/anchor/pe.anchor.fa \
    Q20L80/anchor/pe.anchor.fa \
    Q20L90/anchor/pe.anchor.fa \
    Q20L100/anchor/pe.anchor.fa \
    Q25L70/anchor/pe.anchor.fa \
    Q25L80/anchor/pe.anchor.fa \
    Q25L90/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    Q30L70/anchor/pe.anchor.fa \
    Q30L80/anchor/pe.anchor.fa \
    Q30L90/anchor/pe.anchor.fa \
    Q30L100/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

faops n50 -S -C merge/anchor.merge.fasta

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
quast --no-check --threads 24 \
    -R 1_genome/genome.fa \
    Q20L70/anchor/pe.anchor.fa \
    Q20L80/anchor/pe.anchor.fa \
    Q20L90/anchor/pe.anchor.fa \
    Q20L100/anchor/pe.anchor.fa \
    Q25L70/anchor/pe.anchor.fa \
    Q25L80/anchor/pe.anchor.fa \
    Q25L90/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    Q30L70/anchor/pe.anchor.fa \
    Q30L80/anchor/pe.anchor.fa \
    Q30L90/anchor/pe.anchor.fa \
    Q30L100/anchor/pe.anchor.fa \
    merge/anchor.merge.fasta \
    1_genome/paralogs.fas \
    --label "Q20L70,Q20L80,Q20L90,Q20L100,Q25L70,Q25L80,Q25L90,Q25L100,Q30L70,Q30L80,Q30L90,Q30L100,merge,paralogs" \
    -o 9_qa

```
