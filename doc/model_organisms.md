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
    - [Atha: merge anchors from different groups of reads](#atha-merge-anchors-from-different-groups-of-reads)
    - [Atha: 3GS](#atha-3gs)
    - [Atha: expand anchors](#atha-expand-anchors)


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

cd ${BASE_DIR}
tally \
    --pair-by-offset --with-quality --nozip \
    -i 2_illumina/R1.fq.gz \
    -j 2_illumina/R2.fq.gz \
    -o 2_illumina/R1.uniq.fq \
    -p 2_illumina/R2.uniq.fq

parallel --no-run-if-empty -j 2 "
        pigz -p 4 2_illumina/{}.uniq.fq
    " ::: R1 R2

# get the default adapter file
# anchr trim --help
cd ${BASE_DIR}
parallel --no-run-if-empty -j 2 "
    scythe \
        2_illumina/{}.uniq.fq.gz \
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
    $(echo "uniq";   faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
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
| uniq     |    151 | 2778772064 | 18402464 |
| scythe   |    151 | 2726611643 | 18402464 |
| Q20L100  |    151 | 2557546534 | 17096310 |
| Q20L110  |    151 | 2537979281 | 16923260 |
| Q20L120  |    151 | 2513082020 | 16717910 |
| Q20L130  |    151 | 2480422561 | 16466380 |
| Q20L140  |    151 | 2433715729 | 16128924 |
| Q20L150  |    151 | 2387474987 | 15812304 |
| Q25L100  |    151 | 2368715914 | 15849876 |
| Q25L110  |    151 | 2345799214 | 15651066 |
| Q25L120  |    151 | 2317508101 | 15420770 |
| Q25L130  |    151 | 2282355721 | 15151692 |
| Q25L140  |    151 | 2236545076 | 14821044 |
| Q25L150  |    151 | 2203715071 | 14594672 |
| Q30L100  |    151 | 2168729854 | 14533358 |
| Q30L110  |    151 | 2143269668 | 14315098 |
| Q30L120  |    151 | 2111855985 | 14062284 |
| Q30L130  |    151 | 2072607603 | 13764330 |
| Q30L140  |    151 | 2021095099 | 13394478 |
| Q30L150  |    151 | 1980685011 | 13117410 |

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
        "2_illumina/Q20L150:Q20L150:6000000"
        "2_illumina/Q25L100:Q25L100:6000000"
        "2_illumina/Q25L110:Q25L110:6000000"
        "2_illumina/Q25L120:Q25L120:6000000"
        "2_illumina/Q25L130:Q25L130:6000000"
        "2_illumina/Q25L140:Q25L140:6000000"
        "2_illumina/Q25L150:Q25L150:6000000"
        "2_illumina/Q30L100:Q30L100:6000000"
        "2_illumina/Q30L110:Q30L110:6000000"
        "2_illumina/Q30L120:Q30L120:6000000"
        "2_illumina/Q30L130:Q30L130:6000000"
        "2_illumina/Q30L140:Q30L140:6000000"
        "2_illumina/Q30L150:Q30L150:6000000")

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    GROUP_MAX=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[2];')
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    for count in $(perl -e 'print 2000000 * $_, q{ } for 1 .. 4');
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
        for my $i ( 1 .. 4 ) {
            printf qq{%s_%d\n}, $n, ( 2000000 * $i );
        }
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
        for my $i ( 1 .. 4 ) {
            printf qq{%s_%d\n}, $n, ( 2000000 * $i );
        }
    }
    ' \
    | parallel --no-run-if-empty -j 3 "
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
        for my $i ( 1 .. 4 ) {
            printf qq{%s_%d\n}, $n, ( 2000000 * $i );
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
        for my $i ( 1 .. 4 ) {
            printf qq{%s_%d\n}, $n, ( 2000000 * $i );
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
| original_2000000 |    604M |  49.7 |     151 |  105 |  500.7M |  17.103% | 12.16M | 11.62M |     0.96 | 13.59M |     0 | 0:03'50'' |
| original_4000000 |   1.21G |  99.4 |     151 |  105 |   1.01G |  16.755% | 12.16M | 11.94M |     0.98 | 15.81M |     0 | 0:06'58'' |
| original_6000000 |   1.81G | 149.0 |     151 |  105 |   1.51G |  16.510% | 12.16M | 12.26M |     1.01 | 18.56M |     0 | 0:10'26'' |
| original_8000000 |   2.42G | 198.7 |     151 |  105 |   2.02G |  16.352% | 12.16M | 12.57M |     1.03 | 21.52M |     0 | 0:14'16'' |
| Q20L100_2000000  | 598.39M |  49.2 |     149 |  105 | 540.26M |   9.714% | 12.16M | 11.55M |     0.95 | 12.82M |     0 | 0:03'51'' |
| Q20L100_4000000  |    1.2G |  98.4 |     150 |  105 |   1.08G |   9.567% | 12.16M | 11.68M |     0.96 | 13.56M |     0 | 0:07'37'' |
| Q20L100_6000000  |    1.8G | 147.7 |     150 |  105 |   1.63G |   9.417% | 12.16M | 11.85M |     0.97 | 14.96M |     0 | 0:11'13'' |
| Q20L100_8000000  |   2.39G | 196.9 |     150 |  105 |   2.17G |   9.288% | 12.16M | 12.02M |     0.99 | 16.49M |     0 | 0:14'43'' |
| Q20L110_2000000  | 599.88M |  49.3 |     150 |  105 | 541.97M |   9.654% | 12.16M | 11.54M |     0.95 | 12.79M |     0 | 0:04'24'' |
| Q20L110_4000000  |    1.2G |  98.7 |     150 |  105 |   1.09G |   9.506% | 12.16M | 11.67M |     0.96 | 13.53M |     0 | 0:07'46'' |
| Q20L110_6000000  |    1.8G | 148.0 |     150 |  105 |   1.63G |   9.355% | 12.16M | 11.84M |     0.97 | 14.91M |     0 | 0:10'58'' |
| Q20L110_8000000  |    2.4G | 197.4 |     150 |  105 |   2.18G |   9.232% | 12.16M | 12.01M |     0.99 | 16.43M |     0 | 0:14'47'' |
| Q20L120_2000000  | 601.29M |  49.5 |     150 |  105 | 543.78M |   9.564% | 12.16M | 11.54M |     0.95 | 12.77M |     0 | 0:04'21'' |
| Q20L120_4000000  |    1.2G |  98.9 |     150 |  105 |   1.09G |   9.440% | 12.16M | 11.66M |     0.96 | 13.46M |     0 | 0:07'59'' |
| Q20L120_6000000  |    1.8G | 148.4 |     150 |  105 |   1.64G |   9.274% | 12.16M | 11.83M |     0.97 | 14.82M |     0 | 0:11'11'' |
| Q20L120_8000000  |   2.41G | 197.8 |     150 |  105 |   2.19G |   9.150% | 12.16M | 11.99M |     0.99 | 16.34M |     0 | 0:15'10'' |
| Q20L130_2000000  | 602.54M |  49.6 |     150 |  105 | 545.82M |   9.413% | 12.16M | 11.53M |     0.95 | 12.71M |     0 | 0:04'07'' |
| Q20L130_4000000  |   1.21G |  99.1 |     150 |  105 |   1.09G |   9.309% | 12.16M | 11.65M |     0.96 | 13.41M |     0 | 0:07'46'' |
| Q20L130_6000000  |   1.81G | 148.7 |     150 |  105 |   1.64G |   9.160% | 12.16M |  11.8M |     0.97 | 14.67M |     0 | 0:11'06'' |
| Q20L130_8000000  |   2.41G | 198.3 |     150 |  105 |   2.19G |   9.034% | 12.16M | 11.97M |     0.98 | 16.15M |     0 | 0:14'40'' |
| Q20L140_2000000  | 603.56M |  49.6 |     150 |  105 | 547.89M |   9.224% | 12.16M | 11.52M |     0.95 | 12.64M |     0 | 0:05'06'' |
| Q20L140_4000000  |   1.21G |  99.3 |     150 |  105 |    1.1G |   9.128% | 12.16M | 11.63M |     0.96 | 13.25M |     0 | 0:07'53'' |
| Q20L140_6000000  |   1.81G | 148.9 |     150 |  105 |   1.65G |   8.986% | 12.16M | 11.78M |     0.97 | 14.45M |     0 | 0:11'14'' |
| Q20L140_8000000  |   2.41G | 198.6 |     150 |  105 |    2.2G |   8.864% | 12.16M | 11.93M |     0.98 | 15.85M |     0 | 0:14'54'' |
| Q20L150_2000000  | 603.95M |  49.7 |     150 |  105 | 549.48M |   9.020% | 12.16M | 11.51M |     0.95 | 12.61M |     0 | 0:04'26'' |
| Q20L150_4000000  |   1.21G |  99.4 |     150 |  105 |    1.1G |   8.927% | 12.16M | 11.62M |     0.96 | 13.17M |     0 | 0:07'57'' |
| Q20L150_6000000  |   1.81G | 149.0 |     150 |  105 |   1.65G |   8.790% | 12.16M | 11.76M |     0.97 | 14.34M |     0 | 0:11'30'' |
| Q25L100_2000000  | 597.75M |  49.2 |     149 |  105 | 555.38M |   7.089% | 12.16M |  11.5M |     0.95 | 12.48M |     0 | 0:04'08'' |
| Q25L100_4000000  |    1.2G |  98.3 |     150 |  105 |   1.11G |   6.962% | 12.16M | 11.59M |     0.95 | 12.91M |     0 | 0:08'00'' |
| Q25L100_6000000  |   1.79G | 147.5 |     150 |  105 |   1.67G |   6.862% | 12.16M | 11.68M |     0.96 | 13.73M |     0 | 0:11'22'' |
| Q25L110_2000000  | 599.54M |  49.3 |     150 |  105 |  557.4M |   7.029% | 12.16M |  11.5M |     0.95 | 12.49M |     0 | 0:04'03'' |
| Q25L110_4000000  |    1.2G |  98.6 |     150 |  105 |   1.12G |   6.931% | 12.16M | 11.59M |     0.95 |  12.9M |     0 | 0:07'40'' |
| Q25L110_6000000  |    1.8G | 147.9 |     150 |  105 |   1.68G |   6.835% | 12.16M | 11.68M |     0.96 | 13.71M |     0 | 0:11'54'' |
| Q25L120_2000000  | 601.14M |  49.4 |     150 |  105 |  558.9M |   7.026% | 12.16M |  11.5M |     0.95 | 12.47M |     0 | 0:04'16'' |
| Q25L120_4000000  |    1.2G |  98.9 |     150 |  105 |   1.12G |   6.914% | 12.16M | 11.58M |     0.95 | 12.85M |     0 | 0:07'48'' |
| Q25L120_6000000  |    1.8G | 148.3 |     150 |  105 |   1.68G |   6.803% | 12.16M | 11.67M |     0.96 | 13.63M |     0 | 0:11'29'' |
| Q25L130_2000000  | 602.54M |  49.6 |     150 |  105 | 560.67M |   6.949% | 12.16M | 11.49M |     0.94 | 12.42M |     0 | 0:04'39'' |
| Q25L130_4000000  |   1.21G |  99.1 |     150 |  105 |   1.12G |   6.862% | 12.16M | 11.58M |     0.95 | 12.81M |     0 | 0:08'02'' |
| Q25L130_6000000  |   1.81G | 148.7 |     150 |  105 |   1.69G |   6.767% | 12.16M | 11.66M |     0.96 | 13.57M |     0 | 0:11'33'' |
| Q25L140_2000000  | 603.61M |  49.7 |     150 |  105 | 561.92M |   6.907% | 12.16M | 11.48M |     0.94 | 12.39M |     0 | 0:04'23'' |
| Q25L140_4000000  |   1.21G |  99.3 |     150 |  105 |   1.13G |   6.807% | 12.16M | 11.57M |     0.95 | 12.75M |     0 | 0:07'56'' |
| Q25L140_6000000  |   1.81G | 149.0 |     150 |  105 |   1.69G |   6.713% | 12.16M | 11.65M |     0.96 | 13.48M |     0 | 0:12'28'' |
| Q25L150_2000000  | 603.98M |  49.7 |     150 |  105 | 562.44M |   6.878% | 12.16M | 11.48M |     0.94 | 12.36M |     0 | 0:04'19'' |
| Q25L150_4000000  |   1.21G |  99.4 |     150 |  105 |   1.13G |   6.777% | 12.16M | 11.57M |     0.95 | 12.73M |     0 | 0:07'36'' |
| Q25L150_6000000  |   1.81G | 149.0 |     150 |  105 |   1.69G |   6.686% | 12.16M | 11.65M |     0.96 | 13.42M |     0 | 0:11'31'' |
| Q30L100_2000000  | 596.88M |  49.1 |     149 |  105 | 561.47M |   5.932% | 12.16M | 11.49M |     0.95 | 12.42M |     0 | 0:04'16'' |
| Q30L100_4000000  |   1.19G |  98.2 |     150 |  105 |   1.12G |   5.859% | 12.16M | 11.56M |     0.95 | 12.66M |     0 | 0:07'49'' |
| Q30L100_6000000  |   1.79G | 147.3 |     150 |  105 |   1.69G |   5.788% | 12.16M | 11.63M |     0.96 | 13.24M |     0 | 0:11'14'' |
| Q30L110_2000000  | 598.87M |  49.3 |     149 |  105 | 563.44M |   5.917% | 12.16M | 11.49M |     0.94 |  12.4M |     0 | 0:04'19'' |
| Q30L110_4000000  |    1.2G |  98.5 |     150 |  105 |   1.13G |   5.869% | 12.16M | 11.56M |     0.95 | 12.66M |     0 | 0:07'45'' |
| Q30L110_6000000  |    1.8G | 147.8 |     150 |  105 |   1.69G |   5.790% | 12.16M | 11.63M |     0.96 | 13.22M |     0 | 0:11'12'' |
| Q30L120_2000000  | 600.71M |  49.4 |     150 |  105 |  565.1M |   5.929% | 12.16M | 11.48M |     0.94 | 12.36M |     0 | 0:04'26'' |
| Q30L120_4000000  |    1.2G |  98.8 |     150 |  105 |   1.13G |   5.863% | 12.16M | 11.55M |     0.95 | 12.62M |     0 | 0:07'51'' |
| Q30L120_6000000  |    1.8G | 148.2 |     150 |  105 |    1.7G |   5.784% | 12.16M | 11.62M |     0.96 | 13.19M |     0 | 0:11'10'' |
| Q30L130_2000000  | 602.31M |  49.5 |     150 |  105 |  566.6M |   5.929% | 12.16M | 11.47M |     0.94 | 12.35M |     0 | 0:04'18'' |
| Q30L130_4000000  |    1.2G |  99.1 |     150 |  105 |   1.13G |   5.861% | 12.16M | 11.55M |     0.95 |  12.6M |     0 | 0:07'48'' |
| Q30L130_6000000  |   1.81G | 148.6 |     150 |  105 |    1.7G |   5.784% | 12.16M | 11.62M |     0.96 | 13.14M |     0 | 0:11'29'' |
| Q30L140_2000000  | 603.56M |  49.6 |     150 |  105 | 567.92M |   5.906% | 12.16M | 11.47M |     0.94 | 12.33M |     0 | 0:04'15'' |
| Q30L140_4000000  |   1.21G |  99.3 |     150 |  105 |   1.14G |   5.848% | 12.16M | 11.54M |     0.95 | 12.56M |     0 | 0:07'54'' |
| Q30L140_6000000  |   1.81G | 148.9 |     150 |  105 |   1.71G |   5.775% | 12.16M | 11.61M |     0.95 | 13.08M |     0 | 0:12'09'' |
| Q30L150_2000000  | 603.99M |  49.7 |     150 |  105 | 568.66M |   5.849% | 12.16M | 11.46M |     0.94 | 12.31M |     0 | 0:04'16'' |
| Q30L150_4000000  |   1.21G |  99.4 |     150 |  105 |   1.14G |   5.797% | 12.16M | 11.54M |     0.95 | 12.54M |     0 | 0:07'40'' |
| Q30L150_6000000  |   1.81G | 149.0 |     150 |  105 |   1.71G |   5.738% | 12.16M |  11.6M |     0.95 | 13.06M |     0 | 0:11'22'' |

| Name             | N50SRclean |    Sum |     # | N50Anchor |    Sum |    # | N50Anchor2 |    Sum |  # | N50Others |   Sum |     # |   RunTime |
|:-----------------|-----------:|-------:|------:|----------:|-------:|-----:|-----------:|-------:|---:|----------:|------:|------:|----------:|
| original_2000000 |       3008 | 13.59M | 20452 |      3841 | 10.55M | 3336 |       1214 | 17.91K | 15 |       153 | 3.02M | 17101 | 0:03'31'' |
| original_4000000 |       4279 | 15.81M | 36461 |      6747 |  11.1M | 2310 |       1511 |  2.73K |  2 |       124 |  4.7M | 34149 | 0:05'45'' |
| original_6000000 |       2658 | 18.56M | 58381 |      6240 | 11.05M | 2491 |          0 |      0 |  0 |       123 | 7.51M | 55890 | 0:07'55'' |
| original_8000000 |       1052 | 21.52M | 82117 |      4401 | 10.81M | 3159 |       1531 |   2.7K |  2 |       123 | 10.7M | 78956 | 0:10'34'' |
| Q20L100_2000000  |       3613 | 12.82M | 13231 |      4264 | 10.76M | 3169 |       1286 |   6.3K |  5 |       209 | 2.05M | 10057 | 0:03'37'' |
| Q20L100_4000000  |       6509 | 13.56M | 17249 |      8164 | 11.23M | 2034 |       1661 |  3.16K |  2 |       141 | 2.33M | 15213 | 0:06'04'' |
| Q20L100_6000000  |       6443 | 14.96M | 27897 |      9235 | 11.27M | 1861 |          0 |      0 |  0 |       131 | 3.68M | 26036 | 0:08'15'' |
| Q20L100_8000000  |       5165 | 16.49M | 39678 |      8985 | 11.27M | 1900 |          0 |      0 |  0 |       130 | 5.22M | 37778 | 0:09'36'' |
| Q20L110_2000000  |       3649 | 12.79M | 12927 |      4285 | 10.77M | 3130 |       1157 |  5.97K |  5 |       209 | 2.01M |  9792 | 0:03'24'' |
| Q20L110_4000000  |       6846 | 13.53M | 16923 |      8484 | 11.24M | 1981 |       1142 |  1.14K |  1 |       140 | 2.28M | 14941 | 0:05'54'' |
| Q20L110_6000000  |       6597 | 14.91M | 27520 |      9319 | 11.27M | 1827 |          0 |      0 |  0 |       131 | 3.64M | 25693 | 0:08'08'' |
| Q20L110_8000000  |       5259 | 16.43M | 39136 |      9021 | 11.28M | 1909 |          0 |      0 |  0 |       130 | 5.15M | 37227 | 0:09'25'' |
| Q20L120_2000000  |       3742 | 12.77M | 12705 |      4424 | 10.78M | 3095 |       1176 | 11.94K | 10 |       209 | 1.97M |  9600 | 0:03'34'' |
| Q20L120_4000000  |       6696 | 13.46M | 16360 |      8500 | 11.24M | 1986 |       1159 |  1.16K |  1 |       142 | 2.22M | 14373 | 0:05'54'' |
| Q20L120_6000000  |       6506 | 14.82M | 26680 |      9319 | 11.28M | 1834 |          0 |      0 |  0 |       132 | 3.54M | 24846 | 0:08'04'' |
| Q20L120_8000000  |       5300 | 16.34M | 38340 |      9054 | 11.27M | 1898 |          0 |      0 |  0 |       131 | 5.07M | 36442 | 0:09'58'' |
| Q20L130_2000000  |       3799 | 12.71M | 12216 |      4414 | 10.81M | 3051 |       1236 |  6.17K |  5 |       209 |  1.9M |  9160 | 0:03'53'' |
| Q20L130_4000000  |       6885 | 13.41M | 15913 |      8755 | 11.22M | 1924 |          0 |      0 |  0 |       144 | 2.18M | 13989 | 0:05'52'' |
| Q20L130_6000000  |       6852 | 14.67M | 25473 |      9665 | 11.28M | 1796 |          0 |      0 |  0 |       134 | 3.39M | 23677 | 0:08'00'' |
| Q20L130_8000000  |       5627 | 16.15M | 36777 |      9397 | 11.28M | 1865 |          0 |      0 |  0 |       132 | 4.87M | 34912 | 0:09'27'' |
| Q20L140_2000000  |       3925 | 12.64M | 11634 |      4540 | 10.83M | 3024 |       1204 |  8.42K |  7 |       209 | 1.81M |  8603 | 0:03'26'' |
| Q20L140_4000000  |       7184 | 13.25M | 14700 |      8580 | 11.24M | 1955 |          0 |      0 |  0 |       148 | 2.02M | 12745 | 0:06'01'' |
| Q20L140_6000000  |       7452 | 14.45M | 23709 |     10145 | 11.28M | 1733 |       1068 |  1.07K |  1 |       134 | 3.17M | 21975 | 0:07'30'' |
| Q20L140_8000000  |       5968 | 15.85M | 34363 |      9512 | 11.29M | 1831 |          0 |      0 |  0 |       132 | 4.56M | 32532 | 0:09'18'' |
| Q20L150_2000000  |       3963 | 12.61M | 11430 |      4584 | 10.83M | 3011 |       1361 |  5.15K |  4 |       209 | 1.78M |  8415 | 0:03'41'' |
| Q20L150_4000000  |       7473 | 13.17M | 13974 |      9016 | 11.24M | 1899 |       1116 |  1.12K |  1 |       149 | 1.93M | 12074 | 0:06'00'' |
| Q20L150_6000000  |       7581 | 14.34M | 22832 |     10275 | 11.29M | 1739 |          0 |      0 |  0 |       135 | 3.06M | 21093 | 0:07'42'' |
| Q25L100_2000000  |       3909 | 12.48M | 10329 |      4519 | 10.81M | 3052 |       1137 |  4.54K |  4 |       243 | 1.67M |  7273 | 0:03'39'' |
| Q25L100_4000000  |       7220 | 12.91M | 11928 |      8501 | 11.23M | 1942 |       1105 |  1.11K |  1 |       158 | 1.68M |  9985 | 0:06'08'' |
| Q25L100_6000000  |       7902 | 13.73M | 18051 |     10049 | 11.28M | 1738 |          0 |      0 |  0 |       138 | 2.44M | 16313 | 0:08'01'' |
| Q25L110_2000000  |       3918 | 12.49M | 10340 |      4441 | 10.83M | 3071 |       1140 |  4.72K |  4 |       240 | 1.65M |  7265 | 0:04'02'' |
| Q25L110_4000000  |       7246 |  12.9M | 11809 |      8446 | 11.25M | 1934 |       1084 |  1.08K |  1 |       156 | 1.65M |  9874 | 0:05'54'' |
| Q25L110_6000000  |       7792 | 13.71M | 17896 |      9887 | 11.29M | 1761 |          0 |      0 |  0 |       140 | 2.42M | 16135 | 0:07'29'' |
| Q25L120_2000000  |       4011 | 12.47M | 10182 |      4521 | 10.84M | 3029 |       1366 |  1.37K |  1 |       236 | 1.63M |  7152 | 0:03'41'' |
| Q25L120_4000000  |       7447 | 12.85M | 11383 |      8736 | 11.24M | 1901 |       1072 |  1.07K |  1 |       160 | 1.61M |  9481 | 0:05'47'' |
| Q25L120_6000000  |       8379 | 13.63M | 17175 |     10291 | 11.29M | 1711 |          0 |      0 |  0 |       141 | 2.34M | 15464 | 0:07'59'' |
| Q25L130_2000000  |       4070 | 12.42M |  9770 |      4638 | 10.84M | 2975 |       1140 |  3.57K |  3 |       247 | 1.58M |  6792 | 0:04'02'' |
| Q25L130_4000000  |       7724 | 12.81M | 11062 |      8824 | 11.24M | 1888 |          0 |      0 |  0 |       162 | 1.57M |  9174 | 0:05'55'' |
| Q25L130_6000000  |       8337 | 13.57M | 16730 |     10253 | 11.29M | 1717 |       1708 |   2.9K |  2 |       142 | 2.28M | 15011 | 0:07'23'' |
| Q25L140_2000000  |       4136 | 12.39M |  9464 |      4757 | 10.86M | 2959 |       1278 |  2.37K |  2 |       248 | 1.52M |  6503 | 0:10'59'' |
| Q25L140_4000000  |       7815 | 12.75M | 10621 |      8781 | 11.24M | 1854 |       1837 |  1.84K |  1 |       166 | 1.51M |  8766 | 0:05'39'' |
| Q25L140_6000000  |       8591 | 13.48M | 15962 |     10605 |  11.3M | 1675 |          0 |      0 |  0 |       143 | 2.18M | 14287 | 0:08'42'' |
| Q25L150_2000000  |       4156 | 12.36M |  9274 |      4701 | 10.88M | 2963 |       1214 |  3.65K |  3 |       251 | 1.48M |  6308 | 0:03'10'' |
| Q25L150_4000000  |       7830 | 12.73M | 10470 |      8985 | 11.26M | 1844 |       1689 |  2.96K |  2 |       164 | 1.47M |  8624 | 0:05'16'' |
| Q25L150_6000000  |       8601 | 13.42M | 15570 |     10657 | 11.29M | 1667 |          0 |      0 |  0 |       144 | 2.13M | 13903 | 0:08'27'' |
| Q30L100_2000000  |       3807 | 12.42M |  9885 |      4327 | 10.81M | 3098 |       1165 |  7.38K |  6 |       254 |  1.6M |  6781 | 0:03'53'' |
| Q30L100_4000000  |       7443 | 12.66M |  9956 |      8495 | 11.24M | 1929 |       1100 |   1.1K |  1 |       174 | 1.42M |  8026 | 0:05'33'' |
| Q30L100_6000000  |       8265 | 13.24M | 14233 |     10147 | 11.28M | 1721 |       1105 |  1.11K |  1 |       148 | 1.97M | 12511 | 0:06'38'' |
| Q30L110_2000000  |       3959 |  12.4M |  9729 |      4519 | 10.81M | 3039 |       1394 |  6.75K |  5 |       257 | 1.58M |  6685 | 0:03'23'' |
| Q30L110_4000000  |       7360 | 12.66M |  9992 |      8639 | 11.22M | 1929 |          0 |      0 |  0 |       177 | 1.44M |  8063 | 0:05'34'' |
| Q30L110_6000000  |       8588 | 13.22M | 14042 |     10293 | 11.29M | 1704 |          0 |      0 |  0 |       146 | 1.93M | 12338 | 0:07'16'' |
| Q30L120_2000000  |       4067 | 12.36M |  9325 |      4565 | 10.84M | 2978 |       1397 |  6.79K |  5 |       256 | 1.51M |  6342 | 0:03'34'' |
| Q30L120_4000000  |       7763 | 12.62M |  9668 |      8684 | 11.23M | 1927 |          0 |      0 |  0 |       180 |  1.4M |  7741 | 0:05'43'' |
| Q30L120_6000000  |       8626 | 13.19M | 13792 |     10394 | 11.28M | 1701 |       1105 |  1.11K |  1 |       148 | 1.91M | 12090 | 0:06'37'' |
| Q30L130_2000000  |       3992 | 12.35M |  9366 |      4461 | 10.84M | 3045 |       1393 |  4.26K |  3 |       257 | 1.51M |  6318 | 0:03'19'' |
| Q30L130_4000000  |       7662 |  12.6M |  9494 |      8609 | 11.23M | 1911 |       1216 |   2.3K |  2 |       182 | 1.37M |  7581 | 0:05'18'' |
| Q30L130_6000000  |       8601 | 13.14M | 13424 |      9955 | 11.28M | 1706 |          0 |      0 |  0 |       150 | 1.86M | 11718 | 0:06'39'' |
| Q30L140_2000000  |       4052 | 12.33M |  9155 |      4569 | 10.84M | 3013 |       1315 |  7.84K |  6 |       262 | 1.48M |  6136 | 0:03'18'' |
| Q30L140_4000000  |       7672 | 12.56M |  9156 |      8851 | 11.23M | 1908 |       1221 |  1.22K |  1 |       187 | 1.33M |  7247 | 0:05'17'' |
| Q30L140_6000000  |       8703 | 13.08M | 12986 |     10329 | 11.27M | 1692 |          0 |      0 |  0 |       151 | 1.81M | 11294 | 0:06'59'' |
| Q30L150_2000000  |       4080 | 12.31M |  8995 |      4611 | 10.83M | 2952 |       1105 |   2.2K |  2 |       270 | 1.48M |  6041 | 0:03'16'' |
| Q30L150_4000000  |       7742 | 12.54M |  9027 |      8729 | 11.24M | 1884 |       1105 |  1.11K |  1 |       184 |  1.3M |  7142 | 0:05'13'' |
| Q30L150_6000000  |       8850 | 13.06M | 12799 |     10459 | 11.28M | 1665 |          0 |      0 |  0 |       151 | 1.78M | 11134 | 0:06'41'' |

| Name             | N50SRclean |    Sum |     # | N50Anchor |    Sum |    # | N50Anchor2 |   Sum | # | N50Others |   Sum |     # |   RunTime |
|:-----------------|-----------:|-------:|------:|----------:|-------:|-----:|-----------:|------:|--:|----------:|------:|------:|----------:|
| original_4000000 |       4279 | 15.81M | 36461 |      6747 |  11.1M | 2310 |       1511 | 2.73K | 2 |       124 |  4.7M | 34149 | 0:05'45'' |
| Q20L100_6000000  |       6443 | 14.96M | 27897 |      9235 | 11.27M | 1861 |          0 |     0 | 0 |       131 | 3.68M | 26036 | 0:08'15'' |
| Q20L110_6000000  |       6597 | 14.91M | 27520 |      9319 | 11.27M | 1827 |          0 |     0 | 0 |       131 | 3.64M | 25693 | 0:08'08'' |
| Q20L120_6000000  |       6506 | 14.82M | 26680 |      9319 | 11.28M | 1834 |          0 |     0 | 0 |       132 | 3.54M | 24846 | 0:08'04'' |
| Q20L130_6000000  |       6852 | 14.67M | 25473 |      9665 | 11.28M | 1796 |          0 |     0 | 0 |       134 | 3.39M | 23677 | 0:08'00'' |
| Q20L140_6000000  |       7452 | 14.45M | 23709 |     10145 | 11.28M | 1733 |       1068 | 1.07K | 1 |       134 | 3.17M | 21975 | 0:07'30'' |
| Q20L150_6000000  |       7581 | 14.34M | 22832 |     10275 | 11.29M | 1739 |          0 |     0 | 0 |       135 | 3.06M | 21093 | 0:07'42'' |
| Q25L100_6000000  |       7902 | 13.73M | 18051 |     10049 | 11.28M | 1738 |          0 |     0 | 0 |       138 | 2.44M | 16313 | 0:08'01'' |
| Q25L110_6000000  |       7792 | 13.71M | 17896 |      9887 | 11.29M | 1761 |          0 |     0 | 0 |       140 | 2.42M | 16135 | 0:07'29'' |
| Q25L120_6000000  |       8379 | 13.63M | 17175 |     10291 | 11.29M | 1711 |          0 |     0 | 0 |       141 | 2.34M | 15464 | 0:07'59'' |
| Q25L130_6000000  |       8337 | 13.57M | 16730 |     10253 | 11.29M | 1717 |       1708 |  2.9K | 2 |       142 | 2.28M | 15011 | 0:07'23'' |
| Q25L140_6000000  |       8591 | 13.48M | 15962 |     10605 |  11.3M | 1675 |          0 |     0 | 0 |       143 | 2.18M | 14287 | 0:08'42'' |
| Q25L150_6000000  |       8601 | 13.42M | 15570 |     10657 | 11.29M | 1667 |          0 |     0 | 0 |       144 | 2.13M | 13903 | 0:08'27'' |
| Q30L100_6000000  |       8265 | 13.24M | 14233 |     10147 | 11.28M | 1721 |       1105 | 1.11K | 1 |       148 | 1.97M | 12511 | 0:06'38'' |
| Q30L110_6000000  |       8588 | 13.22M | 14042 |     10293 | 11.29M | 1704 |          0 |     0 | 0 |       146 | 1.93M | 12338 | 0:07'16'' |
| Q30L120_6000000  |       8626 | 13.19M | 13792 |     10394 | 11.28M | 1701 |       1105 | 1.11K | 1 |       148 | 1.91M | 12090 | 0:06'37'' |
| Q30L130_6000000  |       8601 | 13.14M | 13424 |      9955 | 11.28M | 1706 |          0 |     0 | 0 |       150 | 1.86M | 11718 | 0:06'39'' |
| Q30L140_6000000  |       8703 | 13.08M | 12986 |     10329 | 11.27M | 1692 |          0 |     0 | 0 |       151 | 1.81M | 11294 | 0:06'59'' |
| Q30L150_6000000  |       8850 | 13.06M | 12799 |     10459 | 11.28M | 1665 |          0 |     0 | 0 |       151 | 1.78M | 11134 | 0:06'41'' |

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
    Q20L140_6000000/anchor/pe.anchor.fa \
    Q20L150_6000000/anchor/pe.anchor.fa \
    Q25L100_6000000/anchor/pe.anchor.fa \
    Q25L110_6000000/anchor/pe.anchor.fa \
    Q25L120_6000000/anchor/pe.anchor.fa \
    Q25L130_6000000/anchor/pe.anchor.fa \
    Q25L140_6000000/anchor/pe.anchor.fa \
    Q25L150_6000000/anchor/pe.anchor.fa \
    Q30L100_6000000/anchor/pe.anchor.fa \
    Q30L110_6000000/anchor/pe.anchor.fa \
    Q30L120_6000000/anchor/pe.anchor.fa \
    Q30L130_6000000/anchor/pe.anchor.fa \
    Q30L140_6000000/anchor/pe.anchor.fa \
    Q30L150_6000000/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge anchor2 and others
anchr contained \
    Q20L100_6000000/anchor/pe.anchor2.fa \
    Q20L110_6000000/anchor/pe.anchor2.fa \
    Q20L120_6000000/anchor/pe.anchor2.fa \
    Q20L130_6000000/anchor/pe.anchor2.fa \
    Q20L140_6000000/anchor/pe.anchor2.fa \
    Q20L150_6000000/anchor/pe.anchor2.fa \
    Q25L100_6000000/anchor/pe.anchor2.fa \
    Q25L110_6000000/anchor/pe.anchor2.fa \
    Q25L120_6000000/anchor/pe.anchor2.fa \
    Q25L130_6000000/anchor/pe.anchor2.fa \
    Q25L140_6000000/anchor/pe.anchor2.fa \
    Q25L150_6000000/anchor/pe.anchor2.fa \
    Q30L100_6000000/anchor/pe.anchor2.fa \
    Q30L110_6000000/anchor/pe.anchor2.fa \
    Q30L120_6000000/anchor/pe.anchor2.fa \
    Q30L130_6000000/anchor/pe.anchor2.fa \
    Q30L140_6000000/anchor/pe.anchor2.fa \
    Q30L150_6000000/anchor/pe.anchor2.fa \
    Q20L100_6000000/anchor/pe.others.fa \
    Q20L110_6000000/anchor/pe.others.fa \
    Q20L120_6000000/anchor/pe.others.fa \
    Q20L130_6000000/anchor/pe.others.fa \
    Q20L140_6000000/anchor/pe.others.fa \
    Q20L150_6000000/anchor/pe.others.fa \
    Q25L100_6000000/anchor/pe.others.fa \
    Q25L110_6000000/anchor/pe.others.fa \
    Q25L120_6000000/anchor/pe.others.fa \
    Q25L130_6000000/anchor/pe.others.fa \
    Q25L140_6000000/anchor/pe.others.fa \
    Q25L150_6000000/anchor/pe.others.fa \
    Q30L100_6000000/anchor/pe.others.fa \
    Q30L110_6000000/anchor/pe.others.fa \
    Q30L120_6000000/anchor/pe.others.fa \
    Q30L130_6000000/anchor/pe.others.fa \
    Q30L140_6000000/anchor/pe.others.fa \
    Q30L150_6000000/anchor/pe.others.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.merge.fasta

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
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    Q20L100_6000000/anchor/pe.anchor.fa \
    Q20L110_6000000/anchor/pe.anchor.fa \
    Q20L120_6000000/anchor/pe.anchor.fa \
    Q20L130_6000000/anchor/pe.anchor.fa \
    Q20L140_6000000/anchor/pe.anchor.fa \
    Q20L150_6000000/anchor/pe.anchor.fa \
    Q25L100_6000000/anchor/pe.anchor.fa \
    Q25L110_6000000/anchor/pe.anchor.fa \
    Q25L120_6000000/anchor/pe.anchor.fa \
    Q25L130_6000000/anchor/pe.anchor.fa \
    Q25L140_6000000/anchor/pe.anchor.fa \
    Q25L150_6000000/anchor/pe.anchor.fa \
    Q30L100_6000000/anchor/pe.anchor.fa \
    Q30L110_6000000/anchor/pe.anchor.fa \
    Q30L120_6000000/anchor/pe.anchor.fa \
    Q30L130_6000000/anchor/pe.anchor.fa \
    Q30L140_6000000/anchor/pe.anchor.fa \
    Q30L150_6000000/anchor/pe.anchor.fa \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "Q20L100,Q20L110,Q20L120,Q20L130,Q20L140,Q20L150,Q25L100,Q25L110,Q25L120,Q25L130,Q25L140,Q25L150,Q30L100,Q30L110,Q30L120,Q30L130,Q30L140,Q30L150,merge,others,paralogs" \
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

cat \
   anchorLong/group/non_grouped.fasta\
   anchorLong/group/*.contig.fasta \
   | faops filter -l 0 -a 2000 stdin anchorLong/contig.fasta

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

cat \
    contigTrim/group/non_grouped.fasta \
    contigTrim/group/*.contig.fasta \
    >  contigTrim/contig.fasta

```

* quast

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

rm -fr 9_qa_contig
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/anchor.cover.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-raw-40x/s288c.contigs.fasta \
    canu-raw-80x/s288c.contigs.fasta \
    1_genome/paralogs.fas \
    --label "merge,cover,contig,contigTrim,canu-40x,canu-80x,paralogs" \
    -o 9_qa_contig

```

* Stats

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

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
    $(echo "anchor.cover"; faops n50 -H -S -C merge/anchor.cover.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "anchorLong"; faops n50 -H -S -C anchorLong/contig.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "contigTrim"; faops n50 -H -S -C contigTrim/contig.fasta;) >> stat3.md

cat stat3.md
```

| Name         |    N50 |      Sum |    # |
|:-------------|-------:|---------:|-----:|
| Genome       | 924431 | 12157105 |   17 |
| Paralogs     |   3851 |  1059148 |  366 |
| anchor.merge |  18000 | 11400204 | 1088 |
| others.merge |   1016 |    27362 |   26 |
| anchor.cover |  18000 | 11343071 | 1061 |
| anchorLong   |  42533 | 11227195 |  391 |
| contigTrim   | 539698 | 11574003 |   37 |

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
```

## Dmel: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 80, 90, and 100

```bash
BASE_DIR=$HOME/data/anchr/iso_1

cd ${BASE_DIR}
tally \
    --pair-by-offset --with-quality --nozip \
    -i 2_illumina/R1.fq.gz \
    -j 2_illumina/R2.fq.gz \
    -o 2_illumina/R1.uniq.fq \
    -p 2_illumina/R2.uniq.fq

parallel --no-run-if-empty -j 2 "
        pigz -p 4 2_illumina/{}.uniq.fq
    " ::: R1 R2

cd ${BASE_DIR}
parallel --no-run-if-empty -j 2 "
    scythe \
        2_illumina/{}.uniq.fq.gz \
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
    $(echo "uniq";   faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
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
| uniq     |      101 | 17595866904 | 174216504 |
| scythe   |      101 | 17137458539 | 174216504 |
| Q20L80   |      101 | 15130877350 | 150361714 |
| Q20L90   |      101 | 14804113792 | 146804390 |
| Q20L100  |      101 | 14202454005 | 140621110 |
| Q25L80   |      101 | 13921072062 | 138449202 |
| Q25L90   |      101 | 13532232287 | 134220268 |
| Q25L100  |      101 | 12780659034 | 126543750 |
| Q30L80   |      101 | 11488498812 | 114573204 |
| Q30L90   |      101 | 10925470689 | 108454652 |
| Q30L100  |      101 | 10062188150 |  99631472 |

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
| Q20L80  | 15.13G | 110.0 |     100 |   71 | 13.48G |  10.904% | 137.57M | 127.56M |     0.93 | 185.13M |     0 | 3:17'41'' |
| Q20L90  |  14.8G | 107.6 |     100 |   71 | 13.21G |  10.773% | 137.57M | 127.34M |     0.93 |  183.1M |     0 | 3:23'17'' |
| Q20L100 |  14.2G | 103.2 |     101 |   71 | 12.69G |  10.621% | 137.57M | 127.04M |     0.92 | 180.58M |     0 | 3:13'49'' |
| Q25L80  | 13.92G | 101.2 |     100 |   71 | 12.67G |   8.979% | 137.57M | 126.67M |     0.92 | 178.04M |     0 | 2:48'19'' |
| Q25L90  | 13.53G |  98.4 |     100 |   71 | 12.32G |   8.932% | 137.57M | 126.52M |     0.92 | 176.62M |     0 | 2:41'11'' |
| Q25L100 | 12.78G |  92.9 |     101 |   71 | 11.64G |   8.949% | 137.57M |  126.3M |     0.92 | 174.84M |     0 | 2:39'59'' |
| Q30L80  | 11.49G |  83.5 |     100 |   71 | 10.76G |   6.359% | 137.57M | 125.71M |     0.91 | 170.75M |     0 | 2:11'28'' |
| Q30L90  | 10.93G |  79.4 |     100 |   71 | 10.23G |   6.327% | 137.57M | 125.55M |     0.91 | 169.47M |     0 | 1:58'11'' |
| Q30L100 | 10.06G |  73.1 |     100 |   71 |  9.42G |   6.364% | 137.57M | 125.33M |     0.91 | 168.09M |     0 | 1:46'57'' |

| Name    | N50SRclean |     Sum |      # | N50Anchor |     Sum |     # | N50Anchor2 | Sum | # | N50Others |    Sum |      # |   RunTime |
|:--------|-----------:|--------:|-------:|----------:|--------:|------:|-----------:|----:|--:|----------:|-------:|-------:|----------:|
| Q20L80  |       3204 | 185.13M | 709830 |      7166 | 114.49M | 23383 |          0 |   0 | 0 |        94 | 70.64M | 686447 | 2:45'04'' |
| Q20L90  |       3513 |  183.1M | 685466 |      7715 | 114.82M | 22280 |          0 |   0 | 0 |        95 | 68.28M | 663186 | 2:43'34'' |
| Q20L100 |       3899 | 180.58M | 656076 |      8424 | 115.07M | 21032 |          0 |   0 | 0 |        95 | 65.52M | 635044 | 2:39'54'' |
| Q25L80  |       4205 | 178.04M | 627317 |      8794 | 115.09M | 20437 |          0 |   0 | 0 |        95 | 62.95M | 606880 | 2:47'28'' |
| Q25L90  |       4472 | 176.62M | 610668 |      9178 | 115.22M | 19802 |          0 |   0 | 0 |        96 |  61.4M | 590866 | 1:34'06'' |
| Q25L100 |       4778 | 174.84M | 590560 |      9630 | 115.24M | 19193 |          0 |   0 | 0 |        96 |  59.6M | 571367 | 1:25'46'' |
| Q30L80  |       4666 | 170.75M | 546160 |      9117 | 114.51M | 20104 |          0 |   0 | 0 |        99 | 56.24M | 526056 | 1:19'26'' |
| Q30L90  |       4669 | 169.47M | 532443 |      9103 | 114.22M | 20205 |          0 |   0 | 0 |       101 | 55.25M | 512238 | 1:21'19'' |
| Q30L100 |       4510 | 168.09M | 519160 |      8880 | 113.57M | 20711 |          0 |   0 | 0 |       102 | 54.53M | 498449 | 0:39'23'' |

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

# merge anchor2 and others
anchr contained \
    Q20L80/anchor/pe.anchor2.fa \
    Q20L90/anchor/pe.anchor2.fa \
    Q20L100/anchor/pe.anchor2.fa \
    Q25L80/anchor/pe.anchor2.fa \
    Q25L90/anchor/pe.anchor2.fa \
    Q25L100/anchor/pe.anchor2.fa \
    Q30L80/anchor/pe.anchor2.fa \
    Q30L90/anchor/pe.anchor2.fa \
    Q30L100/anchor/pe.anchor2.fa \
    Q20L80/anchor/pe.others.fa \
    Q20L90/anchor/pe.others.fa \
    Q20L100/anchor/pe.others.fa \
    Q25L80/anchor/pe.others.fa \
    Q25L90/anchor/pe.others.fa \
    Q25L100/anchor/pe.others.fa \
    Q30L80/anchor/pe.others.fa \
    Q30L90/anchor/pe.others.fa \
    Q30L100/anchor/pe.others.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.merge.fasta

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
quast --no-check --threads 16 \
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
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "Q20L80,Q20L90,Q20L100,Q25L80,Q25L90,Q25L100,Q30L80,Q30L90,Q30L100,merge,others,paralogs" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/iso_1
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
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

cat \
   anchorLong/group/non_grouped.fasta\
   anchorLong/group/*.contig.fasta \
   | faops filter -l 0 -a 2000 stdin anchorLong/contig.fasta

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

cat \
    contigTrim/group/non_grouped.fasta \
    contigTrim/group/*.contig.fasta \
    >  contigTrim/contig.fasta

```

* quast

```bash
BASE_DIR=$HOME/data/anchr/iso_1
cd ${BASE_DIR}

rm -fr 9_qa_contig
quast --no-check --threads 16 \
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

* Stats

```bash
BASE_DIR=$HOME/data/anchr/iso_1
cd ${BASE_DIR}

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
    $(echo "anchor.cover"; faops n50 -H -S -C merge/anchor.cover.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "anchorLong"; faops n50 -H -S -C anchorLong/contig.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "contigTrim"; faops n50 -H -S -C contigTrim/contig.fasta;) >> stat3.md

cat stat3.md
```

| Name         |      N50 |       Sum |     # |
|:-------------|---------:|----------:|------:|
| Genome       | 25286936 | 137567477 |     8 |
| Paralogs     |     4031 |  13665900 |  4492 |
| anchor.merge |    15168 | 116892943 | 14045 |
| others.merge |     1005 |    227615 |   226 |
| anchor.cover |    15089 | 114942142 | 13840 |
| anchorLong   |    46963 | 112614778 |  5123 |
| contigTrim   |  1806806 | 121709471 |   465 |

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

cd ~/data/anchr/n2
head -n 740000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.40x.fasta
faops n50 -S -C 3_pacbio/pacbio.40x.fasta

head -n 1480000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.80x.fasta
faops n50 -S -C 3_pacbio/pacbio.80x.fasta

```

## Cele: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 80, 90, and 100

```bash
BASE_DIR=$HOME/data/anchr/n2

cd ${BASE_DIR}
tally \
    --pair-by-offset --with-quality --nozip \
    -i 2_illumina/R1.fq.gz \
    -j 2_illumina/R2.fq.gz \
    -o 2_illumina/R1.uniq.fq \
    -p 2_illumina/R2.uniq.fq

parallel --no-run-if-empty -j 2 "
        pigz -p 4 2_illumina/{}.uniq.fq
    " ::: R1 R2

cd ${BASE_DIR}
parallel --no-run-if-empty -j 2 "
    scythe \
        2_illumina/{}.uniq.fq.gz \
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
    $(echo "uniq";   faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
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
| Genome   | 17493829 |   100286401 |         7 |
| Paralogs |     2013 |     5313653 |      2637 |
| Illumina |      100 | 11560892600 | 115608926 |
| PacBio   |    55460 |  8117663505 |    740776 |
| scythe   |      100 | 11402318206 | 115608926 |
| Q20L80   |      100 | 10377586183 | 104082400 |
| Q20L90   |      100 | 10200869231 | 102123772 |
| Q20L100  |      100 |  9927543600 |  99275436 |
| Q25L80   |      100 |  8954210300 |  89801900 |
| Q25L90   |      100 |  8789905902 |  87985860 |
| Q25L100  |      100 |  8582060000 |  85820600 |
| Q30L80   |      100 |  4532887386 |  45511838 |
| Q30L90   |      100 |  4397405332 |  44026358 |
| Q30L100  |      100 |  4258404000 |  42584040 |

## Cele: down sampling

```bash
BASE_DIR=$HOME/data/anchr/n2
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

## Cele: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/n2
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
BASE_DIR=$HOME/data/anchr/n2
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

| Name    |  SumFq | CovFq | AvgRead | Kmer | SumFa | Discard% |   RealG |   EstG | Est/Real |   SumKU | SumSR |   RunTime |
|:--------|-------:|------:|--------:|-----:|------:|---------:|--------:|-------:|---------:|--------:|------:|----------:|
| Q20L80  | 10.22G | 101.9 |      99 |   71 | 6.19G |  39.415% | 100.29M | 98.88M |     0.99 | 114.91M |     0 | 1:28'36'' |
| Q20L90  | 10.04G | 100.1 |      99 |   71 | 6.08G |  39.414% | 100.29M | 98.82M |     0.99 | 114.58M |     0 | 1:22'42'' |
| Q20L100 |  9.77G |  97.5 |     100 |   71 | 5.92G |  39.402% | 100.29M | 98.74M |     0.98 | 114.23M |     0 | 1:27'15'' |
| Q25L80  |  8.82G |  88.0 |      99 |   71 | 5.48G |  37.849% | 100.29M | 98.59M |     0.98 | 113.66M |     0 | 1:10'40'' |
| Q25L90  |  8.66G |  86.3 |      99 |   71 | 5.37G |  37.949% | 100.29M | 98.53M |     0.98 | 113.47M |     0 | 1:05'15'' |
| Q25L100 |  8.46G |  84.3 |     100 |   71 | 5.24G |  38.019% | 100.29M | 98.47M |     0.98 | 113.28M |     0 | 1:03'37'' |
| Q30L80  |  4.49G |  44.7 |      99 |   71 | 3.26G |  27.327% | 100.29M |  97.4M |     0.97 | 112.96M |     0 | 0:30'56'' |
| Q30L90  |  4.35G |  43.4 |      99 |   71 | 3.14G |  27.762% | 100.29M | 97.26M |     0.97 | 112.77M |     0 | 0:31'50'' |
| Q30L100 |  4.22G |  42.0 |     100 |   71 | 3.03G |  28.057% | 100.29M | 97.12M |     0.97 | 112.68M |     0 | 0:30'08'' |

| Name    | N50SRclean |     Sum |      # | N50Anchor |    Sum |     # | N50Anchor2 |   Sum | # | N50Others |    Sum |      # |   RunTime |
|:--------|-----------:|--------:|-------:|----------:|-------:|------:|-----------:|------:|--:|----------:|-------:|-------:|----------:|
| Q20L80  |       6147 | 114.91M | 196835 |      8890 | 90.58M | 16942 |          0 |     0 | 0 |       141 | 24.34M | 179893 | 0:56'08'' |
| Q20L90  |       6328 | 114.58M | 193181 |      9194 | 90.58M | 16739 |          0 |     0 | 0 |       141 |    24M | 176442 | 0:55'05'' |
| Q20L100 |       6443 | 114.23M | 189520 |      9352 | 90.51M | 16555 |          0 |     0 | 0 |       141 | 23.71M | 172965 | 0:53'17'' |
| Q25L80  |       6823 | 113.66M | 184909 |      9891 | 90.09M | 16035 |          0 |     0 | 0 |       141 | 23.57M | 168874 | 0:30'55'' |
| Q25L90  |       6847 | 113.47M | 183244 |      9987 | 89.97M | 15946 |       1073 | 1.07K | 1 |       141 | 23.49M | 167297 | 0:25'00'' |
| Q25L100 |       6922 | 113.28M | 181797 |     10086 | 89.83M | 15898 |       1073 | 1.07K | 1 |       141 | 23.45M | 165898 | 0:20'50'' |
| Q30L80  |       3350 | 112.96M | 209556 |      5643 | 81.64M | 21085 |          0 |     0 | 0 |       204 | 31.32M | 188471 | 0:17'03'' |
| Q30L90  |       3159 | 112.77M | 210993 |      5359 | 80.82M | 21536 |          0 |     0 | 0 |       210 | 31.95M | 189457 | 0:17'24'' |
| Q30L100 |       2941 | 112.68M | 213884 |      5081 | 79.76M | 22085 |          0 |     0 | 0 |       218 | 32.92M | 191799 | 0:16'56'' |

## Cele: merge anchors from different groups of reads

```bash
BASE_DIR=$HOME/data/anchr/n2
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

# merge anchor2 and others
anchr contained \
    Q20L80/anchor/pe.anchor2.fa \
    Q20L90/anchor/pe.anchor2.fa \
    Q20L100/anchor/pe.anchor2.fa \
    Q25L80/anchor/pe.anchor2.fa \
    Q25L90/anchor/pe.anchor2.fa \
    Q25L100/anchor/pe.anchor2.fa \
    Q30L80/anchor/pe.anchor2.fa \
    Q30L90/anchor/pe.anchor2.fa \
    Q30L100/anchor/pe.anchor2.fa \
    Q20L80/anchor/pe.others.fa \
    Q20L90/anchor/pe.others.fa \
    Q20L100/anchor/pe.others.fa \
    Q25L80/anchor/pe.others.fa \
    Q25L90/anchor/pe.others.fa \
    Q25L100/anchor/pe.others.fa \
    Q30L80/anchor/pe.others.fa \
    Q30L90/anchor/pe.others.fa \
    Q30L100/anchor/pe.others.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.merge.fasta

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
quast --no-check --threads 16 \
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

## Cele: 3GS

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

canu \
    -p n2 -d canu-raw-40x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=100.3m \
    -pacbio-raw 3_pacbio/pacbio.40x.fasta
    
canu \
    -p n2 -d canu-raw-80x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=100.3m \
    -pacbio-raw 3_pacbio/pacbio.80x.fasta

faops n50 -S -C canu-raw-40x/n2.trimmedReads.fasta.gz
faops n50 -S -C canu-raw-80x/n2.trimmedReads.fasta.gz

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

cat \
   anchorLong/group/non_grouped.fasta\
   anchorLong/group/*.contig.fasta \
   | faops filter -l 0 -a 2000 stdin anchorLong/contig.fasta

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
    -b 50 --len 1000 --idt 0.98 --all

CONTIG_COUNT=$(faops n50 -H -N 0 -C contigTrim/anchor.fasta)
echo ${CONTIG_COUNT}

rm -fr contigTrim/group
anchr group \
    --parallel 16 \
    --keep \
    contigTrim/anchorLong.db \
    contigTrim/anchorLong.ovlp.tsv \
    --range "1-${CONTIG_COUNT}" --len 1000 --idt 0.98 --max 20000 -c 1 --png

pushd ${BASE_DIR}/contigTrim
cat group/groups.txt \
    | parallel --no-run-if-empty -j 8 '
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

* quast

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

rm -fr 9_qa_contig
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/anchor.cover.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-raw-40x/n2.contigs.fasta \
    canu-raw-80x/n2.contigs.fasta \
    1_genome/paralogs.fas \
    --label "merge,cover,contig,contigTrim,canu-40x,canu-80x,paralogs" \
    -o 9_qa_contig

```

* Stats

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

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
    $(echo "anchor.cover"; faops n50 -H -S -C merge/anchor.cover.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "anchorLong"; faops n50 -H -S -C anchorLong/contig.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "contigTrim"; faops n50 -H -S -C contigTrim/contig.fasta;) >> stat3.md

cat stat3.md
```

| Name         |      N50 |       Sum |     # |
|:-------------|---------:|----------:|------:|
| Genome       | 17493829 | 100286401 |     7 |
| Paralogs     |     2013 |   5313653 |  2637 |
| anchor.merge |    12279 |  91350626 | 14333 |
| others.merge |          |           |       |
| anchor.cover |    11899 |  89851676 | 14244 |
| anchorLong   |    20445 |  85720529 |  7279 |
| contigTrim   |   899344 |  98640587 |   431 |

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

P4C2 is not supported in newer version of SMRTAnalysis.

https://www.ncbi.nlm.nih.gov/biosample/4539665

[SRX1715692](https://www.ncbi.nlm.nih.gov/sra/SRX1715692[accn])


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

cd ~/data/anchr/col_0
head -n 2600000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.40x.fasta
faops n50 -S -C 3_pacbio/pacbio.40x.fasta

head -n 5200000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.80x.fasta
faops n50 -S -C 3_pacbio/pacbio.80x.fasta

```

## Atha: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 80, 90, and 100

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
    " ::: 20 25 30 ::: 80 90 100

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
| Genome   | 23459830 |   119667750 |         7 |
| Paralogs |     2007 |    16447809 |      8055 |
| Illumina |      100 | 14948629000 | 149486290 |
| PacBio   |    44636 | 18768526777 |   5721958 |
| scythe   |      100 | 14859828281 | 149486290 |
| Q20L80   |      100 | 12829458794 | 129008212 |
| Q20L90   |      100 | 12277500278 | 122999098 |
| Q20L100  |      100 | 11657500600 | 116575006 |
| Q25L80   |      100 | 11511159939 | 115877888 |
| Q25L90   |      100 | 10876573032 | 108964030 |
| Q25L100  |      100 | 10306275200 | 103062752 |
| Q30L80   |      100 |  9282649748 |  93816534 |
| Q30L90   |      100 |  8452773268 |  84758028 |
| Q30L100  |      100 |  7776826400 |  77768264 |

## Atha: down sampling

```bash
BASE_DIR=$HOME/data/anchr/col_0
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

## Atha: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/col_0
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
BASE_DIR=$HOME/data/anchr/col_0
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
| Q20L80  | 12.83G | 107.2 |      99 |   71 | 10.63G |  17.140% | 119.67M | 273.46M |     2.29 | 387.84M |     0 | 2:26'10'' |
| Q20L90  | 12.28G | 102.6 |      99 |   71 |  10.2G |  16.936% | 119.67M | 261.13M |     2.18 | 367.93M |     0 | 2:17'59'' |
| Q20L100 | 11.66G |  97.4 |     100 |   71 |   9.7G |  16.772% | 119.67M | 248.69M |     2.08 | 347.83M |     0 | 1:26'39'' |
| Q25L80  | 11.51G |  96.2 |      99 |   71 |  9.65G |  16.148% | 119.67M | 246.75M |     2.06 | 341.91M |     0 | 1:36'48'' |
| Q25L90  | 10.88G |  90.9 |      99 |   71 |  9.13G |  16.032% | 119.67M |  232.8M |     1.95 | 320.24M |     0 | 1:30'00'' |
| Q25L100 | 10.31G |  86.1 |     100 |   71 |  8.66G |  15.965% | 119.67M | 221.73M |     1.85 | 302.79M |     0 | 1:23'25'' |
| Q30L80  |  9.28G |  77.6 |      98 |   71 |  7.89G |  14.958% | 119.67M | 201.06M |     1.68 | 267.67M |     0 | 1:56'52'' |
| Q30L90  |  8.45G |  70.6 |      99 |   71 |   7.2G |  14.862% | 119.67M |  185.4M |     1.55 | 244.24M |     0 | 1:24'40'' |
| Q30L100 |  7.78G |  65.0 |     100 |   71 |  6.63G |  14.729% | 119.67M | 174.61M |     1.46 | 227.55M |     0 | 1:14'12'' |

| Name    | N50SRclean |     Sum |       # | N50Anchor |     Sum |     # | N50Anchor2 | Sum | # | N50Others |     Sum |       # |   RunTime |
|:--------|-----------:|--------:|--------:|----------:|--------:|------:|-----------:|----:|--:|----------:|--------:|--------:|----------:|
| Q20L80  |        137 | 387.84M | 2498917 |      9643 | 105.43M | 17798 |          0 |   0 | 0 |       107 | 282.42M | 2481119 | 1:25'29'' |
| Q20L90  |        140 | 367.93M | 2322890 |     10087 | 105.24M | 17085 |          0 |   0 | 0 |       108 | 262.69M | 2305805 | 1:22'07'' |
| Q20L100 |        141 | 347.83M | 2153029 |     10355 | 104.98M | 16747 |          0 |   0 | 0 |       108 | 242.85M | 2136282 | 1:15'54'' |
| Q25L80  |        141 | 341.91M | 2108999 |     10329 | 104.95M | 16814 |          0 |   0 | 0 |       107 | 236.95M | 2092185 | 1:07'04'' |
| Q25L90  |        144 | 320.24M | 1918340 |     10130 |  104.7M | 16918 |          0 |   0 | 0 |       107 | 215.55M | 1901422 | 1:00'35'' |
| Q25L100 |        149 | 302.79M | 1769463 |      9817 | 104.41M | 17286 |          0 |   0 | 0 |       107 | 198.37M | 1752177 | 0:55'34'' |
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
quast --no-check --threads 16 \
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

## Atha: 3GS

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

canu \
    -p col_0 -d canu-raw-40x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=119.7m \
    -pacbio-raw 3_pacbio/pacbio.40x.fasta
    
canu \
    -p col_0 -d canu-raw-80x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=119.7m \
    -pacbio-raw 3_pacbio/pacbio.80x.fasta

faops n50 -S -C canu-raw-40x/col_0.trimmedReads.fasta.gz
faops n50 -S -C canu-raw-80x/col_0.trimmedReads.fasta.gz

```

## Atha: expand anchors

* anchorLong

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

anchr cover \
    --parallel 16 \
    -c 2 -m 40 \
    -b 50 --len 1000 --idt 0.9 \
    merge/anchor.merge.fasta \
    canu-raw-40x/col_0.trimmedReads.fasta.gz \
    -o merge/anchor.cover.fasta

rm -fr anchorLong
anchr overlap2 \
    --parallel 16 \
    merge/anchor.cover.fasta \
    canu-raw-40x/col_0.trimmedReads.fasta.gz \
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

cat \
   anchorLong/group/non_grouped.fasta\
   anchorLong/group/*.contig.fasta \
   | faops filter -l 0 -a 2000 stdin anchorLong/contig.fasta

```

* contigTrim

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

rm -fr contigTrim
anchr overlap2 \
    --parallel 16 \
    anchorLong/contig.fasta \
    canu-raw-40x/col_0.contigs.fasta \
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
    --range "1-${CONTIG_COUNT}" --len 1000 --idt 0.98 --max 20000 -c 1 --png

pushd ${BASE_DIR}/contigTrim
cat group/groups.txt \
    | parallel --no-run-if-empty -j 8 '
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

* quast

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

rm -fr 9_qa_contig
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/anchor.cover.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-raw-40x/col_0.contigs.fasta \
    canu-raw-80x/col_0.contigs.fasta \
    1_genome/paralogs.fas \
    --label "merge,cover,contig,contigTrim,canu-40x,canu-80x,paralogs" \
    -o 9_qa_contig

```
