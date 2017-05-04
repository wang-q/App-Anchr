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
    --pair-by-offset --with-quality --nozip --unsorted \
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
    " ::: 20 25 30 ::: 100 120 140

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
    for len in 100 120 140; do
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
| Q20L120  |    151 | 2513082020 | 16717910 |
| Q20L140  |    151 | 2433715729 | 16128924 |
| Q25L100  |    151 | 2368715914 | 15849876 |
| Q25L120  |    151 | 2317508101 | 15420770 |
| Q25L140  |    151 | 2236545076 | 14821044 |
| Q30L100  |    151 | 2168729854 | 14533358 |
| Q30L120  |    151 | 2111855985 | 14062284 |
| Q30L140  |    151 | 2021095099 | 13394478 |

## Scer: down sampling

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

ARRAY=( 
    "2_illumina/Q20L100:Q20L100:8000000"
    "2_illumina/Q20L120:Q20L120:8000000"
    "2_illumina/Q20L140:Q20L140:8000000"
    "2_illumina/Q25L100:Q25L100:6000000"
    "2_illumina/Q25L120:Q25L120:6000000"
    "2_illumina/Q25L140:Q25L140:6000000"
    "2_illumina/Q30L100:Q30L100:6000000"
    "2_illumina/Q30L120:Q30L120:6000000"
    "2_illumina/Q30L140:Q30L140:6000000"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(perl -e "@p = split q{:}, q{${group}}; print \$p[0];")
    GROUP_ID=$( perl -e "@p = split q{:}, q{${group}}; print \$p[1];")
    GROUP_MAX=$(perl -e "@p = split q{:}, q{${group}}; print \$p[2];")
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    perl -e 'print 2000000 * $_, qq{\n} for 1 .. 4' \
    | parallel --no-run-if-empty -j 4 "
        if [[ {} -gt '$GROUP_MAX' ]]; then
            exit;
        fi

        echo '    ${GROUP_ID}_{}'
        mkdir -p ${BASE_DIR}/${GROUP_ID}_{}
        
        if [ -e ${BASE_DIR}/${GROUP_ID}_{}/R1.fq.gz ]; then
            exit;
        fi

        seqtk sample -s{} \
            ${BASE_DIR}/${GROUP_DIR}/R1.fq.gz {} \
            | pigz -p 4 -c > ${BASE_DIR}/${GROUP_ID}_{}/R1.fq.gz
        seqtk sample -s{} \
            ${BASE_DIR}/${GROUP_DIR}/R2.fq.gz {} \
            | pigz -p 4 -c > ${BASE_DIR}/${GROUP_ID}_{}/R2.fq.gz
    "

done

```

## Scer: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L120 Q20L140
        Q25L100 Q25L120 Q25L140
        Q30L100 Q30L120 Q30L140
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

        if [ -e ${BASE_DIR}/{}/k_unitigs.fasta ]; then
            echo '    k_unitigs.fasta already presents'
            exit;
        fi

        cd ${BASE_DIR}/{}
        anchr superreads \
            R1.fq.gz R2.fq.gz \
            --nosr -p 8 \
            --kmer 49,69,89 \
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
        Q20L100 Q20L120 Q20L140
        Q25L100 Q25L120 Q25L140
        Q30L100 Q30L120 Q30L140
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
        Q20L100 Q20L120 Q20L140
        Q25L100 Q25L120 Q25L140
        Q30L100 Q30L120 Q30L140
        }
        )
    {
        for my $i ( 1 .. 4 ) {
            printf qq{%s_%d\n}, $n, ( 2000000 * $i );
        }
    }
    ' \
    | parallel -k --no-run-if-empty -j 4 "
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
        Q20L100 Q20L120 Q20L140
        Q25L100 Q25L120 Q25L140
        Q30L100 Q30L120 Q30L140
        }
        )
    {
        for my $i ( 1 .. 4 ) {
            printf qq{%s_%d\n}, $n, ( 2000000 * $i );
        }
    }
    ' \
    | parallel -k --no-run-if-empty -j 8 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

| Name            |   SumFq | CovFq | AvgRead |       Kmer |   SumFa | Discard% |  RealG |   EstG | Est/Real |  SumKU | SumSR |   RunTime |
|:----------------|--------:|------:|--------:|-----------:|--------:|---------:|-------:|-------:|---------:|-------:|------:|----------:|
| Q20L100_2000000 | 598.39M |  49.2 |     149 | "49,69,89" | 540.14M |   9.734% | 12.16M | 11.55M |     0.95 | 11.93M |     0 | 0:04'31'' |
| Q20L100_4000000 |    1.2G |  98.4 |     149 | "49,69,89" |   1.08G |   9.574% | 12.16M | 11.68M |     0.96 | 11.74M |     0 | 0:07'03'' |
| Q20L100_6000000 |    1.8G | 147.7 |     149 | "49,69,89" |   1.63G |   9.401% | 12.16M | 11.85M |     0.97 | 11.62M |     0 | 0:09'37'' |
| Q20L100_8000000 |   2.39G | 196.9 |     149 | "49,69,89" |   2.17G |   9.289% | 12.16M | 12.02M |     0.99 | 11.59M |     0 | 0:11'56'' |
| Q20L120_2000000 | 601.29M |  49.5 |     150 | "49,69,89" | 543.76M |   9.567% | 12.16M | 11.54M |     0.95 | 11.88M |     0 | 0:04'15'' |
| Q20L120_4000000 |    1.2G |  98.9 |     150 | "49,69,89" |   1.09G |   9.432% | 12.16M | 11.66M |     0.96 | 11.73M |     0 | 0:06'47'' |
| Q20L120_6000000 |    1.8G | 148.4 |     150 | "49,69,89" |   1.64G |   9.270% | 12.16M | 11.83M |     0.97 | 11.57M |     0 | 0:09'28'' |
| Q20L120_8000000 |   2.41G | 197.8 |     150 | "49,69,89" |   2.19G |   9.151% | 12.16M | 11.99M |     0.99 | 11.52M |     0 | 0:12'13'' |
| Q20L140_2000000 | 603.57M |  49.6 |     150 | "49,69,89" | 547.72M |   9.253% | 12.16M | 11.52M |     0.95 | 11.89M |     0 | 0:04'30'' |
| Q20L140_4000000 |   1.21G |  99.3 |     150 | "49,69,89" |    1.1G |   9.126% | 12.16M | 11.63M |     0.96 | 11.65M |     0 | 0:06'40'' |
| Q20L140_6000000 |   1.81G | 148.9 |     150 | "49,69,89" |   1.65G |   8.978% | 12.16M | 11.78M |     0.97 | 11.59M |     0 | 0:09'37'' |
| Q20L140_8000000 |   2.41G | 198.6 |     150 | "49,69,89" |    2.2G |   8.865% | 12.16M | 11.93M |     0.98 | 11.53M |     0 | 0:12'18'' |
| Q25L100_2000000 | 597.77M |  49.2 |     149 | "49,69,89" | 555.67M |   7.042% | 12.16M | 11.51M |     0.95 | 11.91M |     0 | 0:04'19'' |
| Q25L100_4000000 |    1.2G |  98.3 |     149 | "49,69,89" |   1.11G |   6.972% | 12.16M | 11.59M |     0.95 | 11.77M |     0 | 0:06'42'' |
| Q25L100_6000000 |   1.79G | 147.5 |     149 | "49,69,89" |   1.67G |   6.858% | 12.16M | 11.68M |     0.96 | 11.62M |     0 | 0:09'18'' |
| Q25L120_2000000 | 601.14M |  49.4 |     150 | "49,69,89" | 558.97M |   7.016% | 12.16M |  11.5M |     0.95 | 11.75M |     0 | 0:04'22'' |
| Q25L120_4000000 |    1.2G |  98.9 |     150 | "49,69,89" |   1.12G |   6.904% | 12.16M | 11.58M |     0.95 | 11.77M |     0 | 0:06'57'' |
| Q25L120_6000000 |    1.8G | 148.3 |     150 | "49,69,89" |   1.68G |   6.807% | 12.16M | 11.67M |     0.96 | 11.68M |     0 | 0:09'43'' |
| Q25L140_2000000 | 603.61M |  49.7 |     150 | "49,69,89" | 562.01M |   6.893% | 12.16M | 11.48M |     0.94 | 11.96M |     0 | 0:04'33'' |
| Q25L140_4000000 |   1.21G |  99.3 |     150 | "49,69,89" |   1.13G |   6.804% | 12.16M | 11.57M |     0.95 | 11.84M |     0 | 0:07'06'' |
| Q25L140_6000000 |   1.81G | 149.0 |     150 | "49,69,89" |   1.69G |   6.711% | 12.16M | 11.65M |     0.96 | 11.51M |     0 | 0:09'55'' |
| Q30L100_2000000 | 596.92M |  49.1 |     149 | "49,69,89" | 561.52M |   5.931% | 12.16M | 11.49M |     0.95 | 11.87M |     0 | 0:04'21'' |
| Q30L100_4000000 |   1.19G |  98.2 |     149 | "49,69,89" |   1.12G |   5.865% | 12.16M | 11.56M |     0.95 | 11.81M |     0 | 0:07'02'' |
| Q30L100_6000000 |   1.79G | 147.3 |     149 | "49,69,89" |   1.69G |   5.793% | 12.16M | 11.63M |     0.96 | 11.55M |     0 | 0:09'18'' |
| Q30L120_2000000 | 600.71M |  49.4 |     150 | "49,69,89" | 565.08M |   5.931% | 12.16M | 11.48M |     0.94 | 11.82M |     0 | 0:04'23'' |
| Q30L120_4000000 |    1.2G |  98.8 |     150 | "49,69,89" |   1.13G |   5.864% | 12.16M | 11.55M |     0.95 | 11.64M |     0 | 0:06'59'' |
| Q30L120_6000000 |    1.8G | 148.2 |     150 | "49,69,89" |    1.7G |   5.790% | 12.16M | 11.62M |     0.96 | 11.48M |     0 | 0:09'44'' |
| Q30L140_2000000 | 603.57M |  49.6 |     150 | "49,69,89" | 567.88M |   5.913% | 12.16M | 11.47M |     0.94 | 11.97M |     0 | 0:04'25'' |
| Q30L140_4000000 |   1.21G |  99.3 |     150 | "49,69,89" |   1.14G |   5.850% | 12.16M | 11.54M |     0.95 | 11.88M |     0 | 0:07'02'' |
| Q30L140_6000000 |   1.81G | 148.9 |     150 | "49,69,89" |   1.71G |   5.778% | 12.16M | 11.61M |     0.95 | 11.65M |     0 | 0:09'44'' |

| Name            | N50SR |    Sum |    # | N50Anchor |    Sum |    # | N50Anchor2 |     Sum |   # | N50Others |     Sum |   # |   RunTime |
|:----------------|------:|-------:|-----:|----------:|-------:|-----:|-----------:|--------:|----:|----------:|--------:|----:|----------:|
| Q20L100_2000000 | 13279 | 11.93M | 1605 |     13156 |  9.89M | 1187 |      18089 |   1.29M | 118 |      8945 | 749.22K | 300 | 0:02'41'' |
| Q20L100_4000000 | 14527 | 11.74M | 1486 |     14475 | 10.65M | 1185 |      19011 | 526.08K |  47 |     12106 | 559.73K | 254 | 0:04'07'' |
| Q20L100_6000000 | 11960 | 11.62M | 1767 |     11780 | 10.91M | 1456 |      22576 | 334.18K |  30 |      1003 | 368.74K | 281 | 0:05'42'' |
| Q20L100_8000000 |  9911 | 11.59M | 2066 |      9856 | 10.91M | 1708 |      22765 | 329.86K |  29 |       900 | 348.16K | 329 | 0:06'49'' |
| Q20L120_2000000 | 13728 | 11.88M | 1534 |     13288 |  9.89M | 1152 |      20838 |   1.25M |  97 |     11293 | 734.37K | 285 | 0:02'22'' |
| Q20L120_4000000 | 15761 | 11.73M | 1438 |     15364 |  10.5M | 1149 |      28617 | 764.11K |  46 |     10908 | 467.28K | 243 | 0:03'50'' |
| Q20L120_6000000 | 12532 | 11.57M | 1695 |     12514 |    11M | 1416 |      18668 | 207.72K |  20 |      3434 |  362.4K | 259 | 0:05'48'' |
| Q20L120_8000000 | 10225 | 11.52M | 2004 |     10318 | 11.07M | 1672 |      15135 | 118.59K |  17 |       910 | 335.23K | 315 | 0:06'50'' |
| Q20L140_2000000 | 14063 | 11.89M | 1520 |     13706 |  9.81M | 1123 |      21834 |   1.44M | 110 |      7479 | 639.48K | 287 | 0:02'37'' |
| Q20L140_4000000 | 16428 | 11.65M | 1346 |     16237 | 10.64M | 1086 |      31013 | 649.96K |  47 |      8704 | 364.37K | 213 | 0:04'12'' |
| Q20L140_6000000 | 13236 | 11.59M | 1614 |     13252 |    11M | 1348 |      25175 | 216.47K |  16 |      7963 | 376.94K | 250 | 0:05'29'' |
| Q20L140_8000000 | 11056 | 11.53M | 1912 |     11204 | 11.03M | 1592 |      18668 | 228.75K |  26 |       846 | 278.67K | 294 | 0:06'23'' |
| Q25L100_2000000 | 14758 | 11.91M | 1491 |     14674 |  9.93M | 1098 |      18318 |   1.27M | 113 |     10548 | 704.47K | 280 | 0:02'27'' |
| Q25L100_4000000 | 16518 | 11.77M | 1398 |     16449 | 10.56M | 1102 |      24334 | 661.51K |  44 |     11546 | 549.66K | 252 | 0:04'25'' |
| Q25L100_6000000 | 13003 | 11.62M | 1613 |     13019 | 10.95M | 1336 |      20728 | 290.18K |  26 |      5573 | 383.48K | 251 | 0:05'46'' |
| Q25L120_2000000 | 14923 | 11.75M | 1437 |     14943 | 10.15M | 1103 |      19216 |   1.05M |  88 |      9442 | 545.09K | 246 | 0:02'30'' |
| Q25L120_4000000 | 16864 | 11.77M | 1343 |     16590 | 10.51M | 1066 |      27945 | 803.84K |  48 |     10677 |  451.3K | 229 | 0:04'26'' |
| Q25L120_6000000 | 13734 | 11.68M | 1599 |     13336 | 10.89M | 1318 |      28845 | 330.46K |  22 |     15875 |  458.8K | 259 | 0:05'43'' |
| Q25L140_2000000 | 15237 | 11.96M | 1476 |     14351 |  9.77M | 1104 |      23629 |    1.4M |  93 |     12073 | 789.14K | 279 | 0:02'33'' |
| Q25L140_4000000 | 16824 | 11.84M | 1359 |     16554 | 10.48M | 1059 |      23178 | 773.17K |  43 |     11263 |  591.3K | 257 | 0:03'41'' |
| Q25L140_6000000 | 14280 | 11.51M | 1516 |     14353 | 11.04M | 1248 |      20845 | 247.12K |  26 |       851 | 230.75K | 242 | 0:05'22'' |
| Q30L100_2000000 | 14572 | 11.87M | 1499 |     14595 | 10.11M | 1143 |      20879 |   1.05M |  86 |      9977 | 715.92K | 270 | 0:02'27'' |
| Q30L100_4000000 | 16824 | 11.81M | 1359 |     16847 | 10.49M | 1044 |      18733 | 630.81K |  45 |     11775 | 693.57K | 270 | 0:04'24'' |
| Q30L100_6000000 | 13883 | 11.55M | 1552 |     13999 | 11.04M | 1279 |      16874 | 194.63K |  22 |       986 | 310.77K | 251 | 0:06'00'' |
| Q30L120_2000000 | 14787 | 11.82M | 1480 |     14148 | 10.01M | 1122 |      20007 |   1.16M |  87 |      9657 | 659.59K | 271 | 0:02'36'' |
| Q30L120_4000000 | 17967 | 11.64M | 1291 |     17821 | 10.75M | 1050 |      32018 | 470.63K |  28 |      8884 | 417.78K | 213 | 0:03'56'' |
| Q30L120_6000000 | 14018 | 11.48M | 1523 |     14407 | 11.14M | 1259 |      13883 |  120.1K |  16 |       805 | 220.07K | 248 | 0:05'28'' |
| Q30L140_2000000 | 13946 | 11.97M | 1551 |     13214 |  9.81M | 1169 |      22856 |   1.41M |  97 |     11505 | 753.32K | 285 | 0:02'25'' |
| Q30L140_4000000 | 17300 | 11.88M | 1355 |     16706 | 10.36M | 1058 |      33881 | 858.76K |  44 |     16974 | 661.69K | 253 | 0:04'25'' |
| Q30L140_6000000 | 15574 | 11.65M | 1481 |     15432 | 10.76M | 1205 |      20316 | 452.81K |  28 |     11548 | 441.67K | 248 | 0:04'54'' |

| Name             | N50SRclean |    Sum |     # | N50Anchor |    Sum |    # | N50Anchor2 |    Sum |  # | N50Others |   Sum |     # |   RunTime |
|:-----------------|-----------:|-------:|------:|----------:|-------:|-----:|-----------:|-------:|---:|----------:|------:|------:|----------:|
| original_2000000 |       3008 | 13.59M | 20452 |      3841 | 10.55M | 3336 |       1214 | 17.91K | 15 |       153 | 3.02M | 17101 | 0:03'37'' |
| original_4000000 |       4279 | 15.81M | 36461 |      6747 |  11.1M | 2310 |       1511 |  2.73K |  2 |       124 |  4.7M | 34149 | 0:06'03'' |
| original_6000000 |       2658 | 18.56M | 58381 |      6240 | 11.05M | 2491 |          0 |      0 |  0 |       123 | 7.51M | 55890 | 0:08'20'' |
| original_8000000 |       1052 | 21.52M | 82117 |      4401 | 10.81M | 3159 |       1531 |   2.7K |  2 |       123 | 10.7M | 78956 | 0:10'26'' |
| Q20L100_2000000  |       3689 |  12.8M | 13003 |      4387 | 10.77M | 3115 |       1370 |  4.09K |  3 |       209 | 2.02M |  9885 | 0:03'52'' |
| Q20L100_4000000  |       6474 | 13.56M | 17214 |      8148 | 11.23M | 2021 |       1260 |  1.26K |  1 |       140 | 2.33M | 15192 | 0:06'20'' |
| Q20L100_6000000  |       6576 | 14.99M | 28131 |      9368 | 11.28M | 1852 |          0 |      0 |  0 |       131 | 3.71M | 26279 | 0:08'06'' |
| Q20L100_8000000  |       5174 | 16.51M | 39843 |      9007 | 11.27M | 1915 |       1076 |  1.08K |  1 |       130 | 5.25M | 37927 | 0:09'46'' |
| Q20L110_2000000  |       3770 | 12.78M | 12913 |      4393 | 10.77M | 3116 |       1189 |  4.87K |  4 |       209 |    2M |  9793 | 0:03'55'' |
| Q20L110_4000000  |       6546 | 13.54M | 17057 |      8308 | 11.23M | 1990 |       1302 |   1.3K |  1 |       140 | 2.31M | 15066 | 0:06'03'' |
| Q20L110_6000000  |       6490 | 14.94M | 27753 |      9425 | 11.27M | 1830 |          0 |      0 |  0 |       131 | 3.68M | 25923 | 0:08'05'' |
| Q20L110_8000000  |       5270 | 16.45M | 39238 |      9260 | 11.27M | 1894 |          0 |      0 |  0 |       130 | 5.17M | 37344 | 0:10'01'' |
| Q20L120_2000000  |       3710 | 12.76M | 12707 |      4357 | 10.77M | 3080 |       1234 |  4.82K |  4 |       209 | 1.99M |  9623 | 0:03'53'' |
| Q20L120_4000000  |       6707 | 13.48M | 16558 |      8340 | 11.23M | 1995 |          0 |      0 |  0 |       143 | 2.25M | 14563 | 0:06'12'' |
| Q20L120_6000000  |       6622 | 14.82M | 26703 |      9385 | 11.29M | 1825 |          0 |      0 |  0 |       132 | 3.53M | 24878 | 0:07'51'' |
| Q20L120_8000000  |       5380 | 16.32M | 38196 |      9313 | 11.27M | 1880 |          0 |      0 |  0 |       131 | 5.06M | 36316 | 0:09'55'' |
| Q20L130_2000000  |       3757 | 12.71M | 12288 |      4424 | 10.82M | 3100 |       1144 |   5.8K |  5 |       209 | 1.89M |  9183 | 0:03'54'' |
| Q20L130_4000000  |       6874 | 13.38M | 15719 |      8554 | 11.25M | 2001 |       1102 |   1.1K |  1 |       144 | 2.13M | 13717 | 0:05'55'' |
| Q20L130_6000000  |       6880 | 14.66M | 25370 |      9741 | 11.29M | 1802 |          0 |      0 |  0 |       133 | 3.36M | 23568 | 0:08'14'' |
| Q20L130_8000000  |       5611 | 16.15M | 36777 |      9397 | 11.28M | 1871 |          0 |      0 |  0 |       132 | 4.87M | 34906 | 0:09'59'' |
| Q20L140_2000000  |       3943 | 12.66M | 11782 |      4620 | 10.81M | 3000 |       1081 |  1.08K |  1 |       209 | 1.85M |  8781 | 0:03'43'' |
| Q20L140_4000000  |       7139 | 13.25M | 14627 |      8577 | 11.24M | 1932 |          0 |      0 |  0 |       149 | 2.01M | 12695 | 0:05'58'' |
| Q20L140_6000000  |       7424 | 14.46M | 23748 |     10089 | 11.29M | 1734 |          0 |      0 |  0 |       134 | 3.17M | 22014 | 0:07'31'' |
| Q20L140_8000000  |       5919 | 15.84M | 34313 |      9487 | 11.29M | 1839 |          0 |      0 |  0 |       133 | 4.56M | 32474 | 0:09'45'' |
| Q20L150_2000000  |       3978 | 12.61M | 11440 |      4614 | 10.82M | 2972 |       1237 |  8.57K |  7 |       209 | 1.79M |  8461 | 0:03'36'' |
| Q20L150_4000000  |       7307 |  13.2M | 14256 |      9027 | 11.24M | 1896 |       1266 |  1.27K |  1 |       149 | 1.96M | 12359 | 0:06'02'' |
| Q20L150_6000000  |       7540 | 14.34M | 22779 |      9915 | 11.29M | 1721 |       1105 |  1.11K |  1 |       135 | 3.04M | 21057 | 0:07'57'' |
| Q25L100_2000000  |       3976 | 12.51M | 10493 |      4567 | 10.81M | 3011 |       1169 |  6.34K |  5 |       239 | 1.69M |  7477 | 0:03'40'' |
| Q25L100_4000000  |       7254 | 12.92M | 11976 |      8524 | 11.24M | 1945 |       1489 |   2.6K |  2 |       155 | 1.67M | 10029 | 0:06'08'' |
| Q25L100_6000000  |       7822 | 13.73M | 18075 |      9901 |  11.3M | 1759 |          0 |      0 |  0 |       138 | 2.43M | 16316 | 0:08'05'' |
| Q25L110_2000000  |       3957 | 12.48M | 10262 |      4518 | 10.84M | 3029 |       1238 |  3.66K |  3 |       236 | 1.64M |  7230 | 0:04'01'' |
| Q25L110_4000000  |       7343 |  12.9M | 11798 |      8526 | 11.24M | 1943 |          0 |      0 |  0 |       157 | 1.66M |  9855 | 0:06'14'' |
| Q25L110_6000000  |       8019 | 13.71M | 17841 |     10221 | 11.28M | 1738 |       1105 |  1.11K |  1 |       139 | 2.42M | 16102 | 0:08'02'' |
| Q25L120_2000000  |       4076 | 12.45M |  9935 |      4682 | 10.85M | 2989 |       1428 |   2.8K |  2 |       241 |  1.6M |  6944 | 0:03'43'' |
| Q25L120_4000000  |       7539 | 12.86M | 11505 |      8720 | 11.25M | 1882 |          0 |      0 |  0 |       156 | 1.62M |  9623 | 0:05'50'' |
| Q25L120_6000000  |       7973 | 13.66M | 17435 |      9980 | 11.27M | 1721 |          0 |      0 |  0 |       141 | 2.39M | 15714 | 0:08'26'' |
| Q25L130_2000000  |       3993 | 12.43M |  9829 |      4563 | 10.84M | 3006 |       1189 |  3.91K |  3 |       246 | 1.59M |  6820 | 0:04'06'' |
| Q25L130_4000000  |       7776 | 12.81M | 11035 |      9002 | 11.25M | 1878 |       1118 |  1.12K |  1 |       161 | 1.56M |  9156 | 0:06'25'' |
| Q25L130_6000000  |       8396 | 13.57M | 16705 |     10349 | 11.29M | 1693 |          0 |      0 |  0 |       142 | 2.28M | 15012 | 0:07'50'' |
| Q25L140_2000000  |       4064 |  12.4M |  9618 |      4617 | 10.85M | 3004 |       1101 |   1.1K |  1 |       249 | 1.55M |  6613 | 0:03'35'' |
| Q25L140_4000000  |       7686 | 12.75M | 10616 |      8755 | 11.24M | 1864 |          0 |      0 |  0 |       166 | 1.51M |  8752 | 0:05'22'' |
| Q25L140_6000000  |       8595 | 13.47M | 15905 |     10430 |  11.3M | 1676 |          0 |      0 |  0 |       144 | 2.17M | 14229 | 0:07'26'' |
| Q25L150_2000000  |       4125 | 12.38M |  9424 |      4623 | 10.86M | 2998 |       1222 |  3.62K |  3 |       250 | 1.52M |  6423 | 0:03'49'' |
| Q25L150_4000000  |       7854 | 12.72M | 10377 |      8973 | 11.25M | 1864 |          0 |      0 |  0 |       167 | 1.47M |  8513 | 0:05'04'' |
| Q25L150_6000000  |       8696 | 13.44M | 15721 |     10566 | 11.29M | 1673 |       1232 |  1.23K |  1 |       143 | 2.15M | 14047 | 0:06'10'' |
| Q30L100_2000000  |       3916 | 12.41M |  9771 |      4467 |  10.8M | 3048 |       1199 |  4.73K |  4 |       260 |  1.6M |  6719 | 0:03'03'' |
| Q30L100_4000000  |       7564 | 12.66M | 10006 |      8784 | 11.22M | 1919 |          0 |      0 |  0 |       177 | 1.44M |  8087 | 0:05'07'' |
| Q30L100_6000000  |       8314 | 13.23M | 14132 |     10023 | 11.27M | 1723 |          0 |      0 |  0 |       149 | 1.97M | 12409 | 0:06'34'' |
| Q30L110_2000000  |       4023 |  12.4M |  9731 |      4577 | 10.82M | 3049 |       1132 |  1.13K |  1 |       254 | 1.57M |  6681 | 0:03'27'' |
| Q30L110_4000000  |       7461 | 12.65M |  9829 |      8612 | 11.24M | 1917 |          0 |      0 |  0 |       175 |  1.4M |  7912 | 0:04'47'' |
| Q30L110_6000000  |       8588 | 13.24M | 14181 |     10326 | 11.27M | 1693 |          0 |      0 |  0 |       148 | 1.97M | 12488 | 0:06'09'' |
| Q30L120_2000000  |       4021 | 12.37M |  9478 |      4609 | 10.82M | 2990 |       1156 |  8.44K |  7 |       259 | 1.55M |  6481 | 0:02'58'' |
| Q30L120_4000000  |       7730 | 12.61M |  9589 |      8713 | 11.23M | 1911 |       1579 |  1.58K |  1 |       180 | 1.38M |  7677 | 0:04'39'' |
| Q30L120_6000000  |       8646 | 13.19M | 13722 |     10511 | 11.29M | 1699 |       1069 |  1.07K |  1 |       149 | 1.89M | 12022 | 0:06'24'' |
| Q30L130_2000000  |       4066 | 12.36M |  9383 |      4583 | 10.81M | 3001 |       1206 |  4.78K |  4 |       273 | 1.54M |  6378 | 0:02'58'' |
| Q30L130_4000000  |       7894 |  12.6M |  9523 |      8994 | 11.24M | 1907 |          0 |      0 |  0 |       179 | 1.36M |  7616 | 0:04'31'' |
| Q30L130_6000000  |       8862 | 13.15M | 13440 |     10628 | 11.28M | 1690 |       1408 |  1.41K |  1 |       150 | 1.87M | 11749 | 0:06'08'' |
| Q30L140_2000000  |       4107 | 12.32M |  9117 |      4617 | 10.82M | 2980 |       1185 |  5.95K |  5 |       270 |  1.5M |  6132 | 0:02'33'' |
| Q30L140_4000000  |       7717 | 12.55M |  9164 |      8859 | 11.23M | 1897 |       1197 |  3.63K |  3 |       186 | 1.32M |  7264 | 0:04'42'' |
| Q30L140_6000000  |       8879 | 13.09M | 13014 |     10559 | 11.29M | 1672 |          0 |      0 |  0 |       151 |  1.8M | 11342 | 0:06'34'' |
| Q30L150_2000000  |       4063 | 12.31M |  9064 |      4589 | 10.83M | 2995 |       1367 |  2.72K |  2 |       270 | 1.48M |  6067 | 0:03'00'' |
| Q30L150_4000000  |       7868 | 12.53M |  8975 |      9003 | 11.24M | 1878 |          0 |      0 |  0 |       186 | 1.28M |  7097 | 0:04'04'' |
| Q30L150_6000000  |       8795 | 13.06M | 12820 |     10334 | 11.29M | 1685 |          0 |      0 |  0 |       151 | 1.77M | 11135 | 0:05'19'' |

## Scer: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L100_4000000/anchor/pe.anchor.fa \
    Q20L100_6000000/anchor/pe.anchor.fa \
    Q20L100_8000000/anchor/pe.anchor.fa \
    Q20L120_4000000/anchor/pe.anchor.fa \
    Q20L120_6000000/anchor/pe.anchor.fa \
    Q20L120_8000000/anchor/pe.anchor.fa \
    Q20L130_4000000/anchor/pe.anchor.fa \
    Q20L140_4000000/anchor/pe.anchor.fa \
    Q20L140_6000000/anchor/pe.anchor.fa \
    Q20L140_8000000/anchor/pe.anchor.fa \
    Q25L100_4000000/anchor/pe.anchor.fa \
    Q25L100_6000000/anchor/pe.anchor.fa \
    Q25L120_4000000/anchor/pe.anchor.fa \
    Q25L120_6000000/anchor/pe.anchor.fa \
    Q25L140_4000000/anchor/pe.anchor.fa \
    Q25L140_6000000/anchor/pe.anchor.fa \
    Q30L100_4000000/anchor/pe.anchor.fa \
    Q30L100_6000000/anchor/pe.anchor.fa \
    Q30L120_4000000/anchor/pe.anchor.fa \
    Q30L120_6000000/anchor/pe.anchor.fa \
    Q30L140_4000000/anchor/pe.anchor.fa \
    Q30L140_6000000/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge anchor2 and others
anchr contained \
    Q20L100_6000000/anchor/pe.anchor2.fa \
    Q20L120_6000000/anchor/pe.anchor2.fa \
    Q20L140_6000000/anchor/pe.anchor2.fa \
    Q25L100_6000000/anchor/pe.anchor2.fa \
    Q25L120_6000000/anchor/pe.anchor2.fa \
    Q25L140_6000000/anchor/pe.anchor2.fa \
    Q30L100_6000000/anchor/pe.anchor2.fa \
    Q30L120_6000000/anchor/pe.anchor2.fa \
    Q30L140_6000000/anchor/pe.anchor2.fa \
    Q20L100_6000000/anchor/pe.others.fa \
    Q20L120_6000000/anchor/pe.others.fa \
    Q20L140_6000000/anchor/pe.others.fa \
    Q25L100_6000000/anchor/pe.others.fa \
    Q25L120_6000000/anchor/pe.others.fa \
    Q25L140_6000000/anchor/pe.others.fa \
    Q30L100_6000000/anchor/pe.others.fa \
    Q30L120_6000000/anchor/pe.others.fa \
    Q30L140_6000000/anchor/pe.others.fa \
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
    Q20L120_6000000/anchor/pe.anchor.fa \
    Q20L140_6000000/anchor/pe.anchor.fa \
    Q25L100_6000000/anchor/pe.anchor.fa \
    Q25L120_6000000/anchor/pe.anchor.fa \
    Q25L140_6000000/anchor/pe.anchor.fa \
    Q30L100_6000000/anchor/pe.anchor.fa \
    Q30L120_6000000/anchor/pe.anchor.fa \
    Q30L140_6000000/anchor/pe.anchor.fa \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "Q20L100,Q20L120,Q20L140,Q25L100,Q25L120,Q25L140,Q30L100,Q30L120,Q30L140,merge,others,paralogs" \
    -o 9_qa

```


* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
rm -fr original_*
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

| Name         |    N50 |      Sum |   # |
|:-------------|-------:|---------:|----:|
| Genome       | 924431 | 12157105 |  17 |
| Paralogs     |   3851 |  1059148 | 366 |
| anchor.merge |  21107 | 11400212 | 930 |
| others.merge |   1011 |    33130 |  32 |
| anchor.cover |  21100 | 11344619 | 907 |
| anchorLong   |  50212 | 11242490 | 345 |
| contigTrim   | 539702 | 11682157 |  37 |

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
    --pair-by-offset --with-quality --nozip --unsorted \
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

ARRAY=( 
    "2_illumina/Q20L80:Q20L80"
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
    | parallel --no-run-if-empty -j 3 "
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
    | parallel -k --no-run-if-empty -j 4 "
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
    | parallel -k --no-run-if-empty -j 8 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

| Name     |  SumFq | CovFq | AvgRead | Kmer |  SumFa | Discard% |   RealG |    EstG | Est/Real |   SumKU | SumSR |   RunTime |
|:---------|-------:|------:|--------:|-----:|-------:|---------:|--------:|--------:|---------:|--------:|------:|----------:|
| Q20L80   | 15.13G | 110.0 |     100 |   71 | 13.48G |  10.904% | 137.57M | 127.56M |     0.93 | 185.13M |     0 | 3:07'24'' |
| Q20L90   |  14.8G | 107.6 |     100 |   71 | 13.21G |  10.773% | 137.57M | 127.34M |     0.93 |  183.1M |     0 | 3:40'54'' |
| Q20L100  |  14.2G | 103.2 |     101 |   71 | 12.69G |  10.621% | 137.57M | 127.04M |     0.92 | 180.58M |     0 | 3:38'02'' |
| Q25L80   | 13.92G | 101.2 |     100 |   71 | 12.67G |   8.979% | 137.57M | 126.67M |     0.92 | 178.04M |     0 | 2:36'18'' |
| Q25L90   | 13.53G |  98.4 |     100 |   71 | 12.32G |   8.932% | 137.57M | 126.52M |     0.92 | 176.62M |     0 | 2:52'23'' |
| Q25L100  | 12.78G |  92.9 |     101 |   71 | 11.64G |   8.949% | 137.57M |  126.3M |     0.92 | 174.84M |     0 | 2:50'54'' |
| Q30L80   | 11.49G |  83.5 |     100 |   71 | 10.76G |   6.359% | 137.57M | 125.71M |     0.91 | 170.75M |     0 | 1:55'41'' |
| Q30L90   | 10.93G |  79.4 |     100 |   71 | 10.23G |   6.327% | 137.57M | 125.55M |     0.91 | 169.47M |     0 | 1:28'48'' |
| Q30L100  | 10.06G |  73.1 |     100 |   71 |  9.42G |   6.364% | 137.57M | 125.33M |     0.91 | 168.09M |     0 | 1:22'44'' |

| Name     | N50SRclean |     Sum |      # | N50Anchor |     Sum |     # | N50Anchor2 | Sum | # | N50Others |    Sum |      # |   RunTime |
|:---------|-----------:|--------:|-------:|----------:|--------:|------:|-----------:|----:|--:|----------:|-------:|-------:|----------:|
| Q20L80   |       3204 | 185.13M | 709830 |      7166 | 114.49M | 23383 |          0 |   0 | 0 |        94 | 70.64M | 686447 | 1:47'40'' |
| Q20L90   |       3513 |  183.1M | 685466 |      7715 | 114.82M | 22280 |          0 |   0 | 0 |        95 | 68.28M | 663186 | 1:35'17'' |
| Q20L100  |       3899 | 180.58M | 656076 |      8424 | 115.07M | 21032 |          0 |   0 | 0 |        95 | 65.52M | 635044 | 1:28'29'' |
| Q25L80   |       4205 | 178.04M | 627317 |      8794 | 115.09M | 20437 |          0 |   0 | 0 |        95 | 62.95M | 606880 | 1:22'49'' |
| Q25L90   |       4472 | 176.62M | 610668 |      9178 | 115.22M | 19802 |          0 |   0 | 0 |        96 |  61.4M | 590866 | 1:09'57'' |
| Q25L100  |       4778 | 174.84M | 590560 |      9630 | 115.24M | 19193 |          0 |   0 | 0 |        96 |  59.6M | 571367 | 1:02'49'' |
| Q30L80   |       4666 | 170.75M | 546160 |      9117 | 114.51M | 20104 |          0 |   0 | 0 |        99 | 56.24M | 526056 | 1:00'06'' |
| Q30L90   |       4669 | 169.47M | 532443 |      9103 | 114.22M | 20205 |          0 |   0 | 0 |       101 | 55.25M | 512238 | 0:47'37'' |
| Q30L100  |       4510 | 168.09M | 519160 |      8880 | 113.57M | 20711 |          0 |   0 | 0 |       102 | 54.53M | 498449 | 0:36'44'' |

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
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    Q20L100O/anchor/pe.anchor.fa \
    Q25L100O/anchor/pe.anchor.fa \
    Q30L100O/anchor/pe.anchor.fa \
    Q20L100/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    Q30L100/anchor/pe.anchor.fa \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "Q20L100O,Q25L100O,Q30L100O,Q20L100,Q25L100,Q30L100,merge,others,paralogs" \
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
| anchor.merge |    15168 | 116902455 | 14046 |
| others.merge |     1005 |    227615 |   226 |
| anchor.cover |    15081 | 114949677 | 13842 |
| anchorLong   |    46865 | 112622237 |  5128 |
| contigTrim   |  2105281 | 121308821 |   468 |

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
    | xargs gzip -d -c \
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
    --pair-by-offset --with-quality --nozip --unsorted \
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
| uniq     |      100 | 11388907200 | 113889072 |
| scythe   |      100 | 11230770194 | 113889072 |
| Q20L80   |      100 | 10216337313 | 102465390 |
| Q20L90   |      100 | 10042338861 | 100536508 |
| Q20L100  |      100 |  9774369800 |  97743698 |
| Q25L80   |      100 |  8820614896 |  88461728 |
| Q25L90   |      100 |  8659318139 |  86678538 |
| Q25L100  |      100 |  8455551400 |  84555514 |
| Q30L80   |      100 |  4486390345 |  45044044 |
| Q30L90   |      100 |  4353221921 |  43583806 |
| Q30L100  |      100 |  4216434600 |  42164346 |

## Cele: down sampling

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

ARRAY=( 
    "2_illumina/Q20L80:Q20L80"
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
    mkdir -p ${BASE_DIR}/${GROUP_ID}
    
    if [ -e ${BASE_DIR}/${GROUP_ID}/R1.fq.gz ]; then
        continue     
    fi
    
    ln -s ${BASE_DIR}/${GROUP_DIR}/R1.fq.gz ${BASE_DIR}/${GROUP_ID}/R1.fq.gz
    ln -s ${BASE_DIR}/${GROUP_DIR}/R2.fq.gz ${BASE_DIR}/${GROUP_ID}/R2.fq.gz

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
    | parallel -k --no-run-if-empty -j 4 "
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
    | parallel -k --no-run-if-empty -j 8 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

| Name    |  SumFq | CovFq | AvgRead | Kmer | SumFa | Discard% |   RealG |   EstG | Est/Real |   SumKU | SumSR |   RunTime |
|:--------|-------:|------:|--------:|-----:|------:|---------:|--------:|-------:|---------:|--------:|------:|----------:|
| Q20L80  | 10.22G | 101.9 |      99 |   71 | 6.19G |  39.415% | 100.29M | 98.88M |     0.99 | 114.91M |     0 | 2:18'41'' |
| Q20L90  | 10.04G | 100.1 |      99 |   71 | 6.08G |  39.414% | 100.29M | 98.82M |     0.99 | 114.58M |     0 | 2:11'08'' |
| Q20L100 |  9.77G |  97.5 |     100 |   71 | 5.92G |  39.402% | 100.29M | 98.74M |     0.98 | 114.23M |     0 | 2:13'05'' |
| Q25L80  |  8.82G |  88.0 |      99 |   71 | 5.48G |  37.849% | 100.29M | 98.59M |     0.98 | 113.66M |     0 | 1:47'15'' |
| Q25L90  |  8.66G |  86.3 |      99 |   71 | 5.37G |  37.949% | 100.29M | 98.53M |     0.98 | 113.47M |     0 | 1:45'27'' |
| Q25L100 |  8.46G |  84.3 |     100 |   71 | 5.24G |  38.019% | 100.29M | 98.47M |     0.98 | 113.28M |     0 | 1:35'10'' |
| Q30L80  |  4.49G |  44.7 |      99 |   71 | 3.26G |  27.327% | 100.29M |  97.4M |     0.97 | 112.96M |     0 | 0:47'31'' |
| Q30L90  |  4.35G |  43.4 |      99 |   71 | 3.14G |  27.762% | 100.29M | 97.26M |     0.97 | 112.77M |     0 | 0:47'24'' |
| Q30L100 |  4.22G |  42.0 |     100 |   71 | 3.03G |  28.057% | 100.29M | 97.12M |     0.97 | 112.68M |     0 | 0:46'02'' |

| Name    | N50SRclean |     Sum |      # | N50Anchor |    Sum |     # | N50Anchor2 |   Sum | # | N50Others |    Sum |      # |   RunTime |
|:--------|-----------:|--------:|-------:|----------:|-------:|------:|-----------:|------:|--:|----------:|-------:|-------:|----------:|
| Q20L80  |       6147 | 114.91M | 196835 |      8890 | 90.58M | 16942 |          0 |     0 | 0 |       141 | 24.34M | 179893 | 0:44'25'' |
| Q20L90  |       6328 | 114.58M | 193181 |      9194 | 90.58M | 16739 |          0 |     0 | 0 |       141 |    24M | 176442 | 0:42'08'' |
| Q20L100 |       6443 | 114.23M | 189520 |      9352 | 90.51M | 16555 |          0 |     0 | 0 |       141 | 23.71M | 172965 | 0:42'17'' |
| Q25L80  |       6823 | 113.66M | 184909 |      9891 | 90.09M | 16035 |          0 |     0 | 0 |       141 | 23.57M | 168874 | 0:33'16'' |
| Q25L90  |       6847 | 113.47M | 183244 |      9987 | 89.97M | 15946 |       1073 | 1.07K | 1 |       141 | 23.49M | 167297 | 0:24'48'' |
| Q25L100 |       6922 | 113.28M | 181797 |     10086 | 89.83M | 15898 |       1073 | 1.07K | 1 |       141 | 23.45M | 165898 | 0:25'49'' |
| Q30L80  |       3350 | 112.96M | 209556 |      5643 | 81.64M | 21085 |          0 |     0 | 0 |       204 | 31.32M | 188471 | 0:17'53'' |
| Q30L90  |       3159 | 112.77M | 210993 |      5359 | 80.82M | 21536 |          0 |     0 | 0 |       210 | 31.95M | 189457 | 0:17'47'' |
| Q30L100 |       2941 | 112.68M | 213884 |      5081 | 79.76M | 22085 |          0 |     0 | 0 |       218 | 32.92M | 191799 | 0:12'20'' |

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
    Q20L100/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    Q30L100/anchor/pe.anchor.fa \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "Q20L100,Q25L100,Q30L100,merge,others,paralogs" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/n2
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
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
   | faops filter -l 0 -a 1000 stdin anchorLong/contig.fasta

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
    --range "1-${CONTIG_COUNT}" --len 1000 --idt 0.98 --max 20000 -c 1

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
| anchor.merge |    12300 |  91350822 | 14317 |
| others.merge |     1008 |    435339 |   431 |
| anchor.cover |    11869 |  89803083 | 14271 |
| anchorLong   |    19110 |  89418669 | 10012 |
| contigTrim   |  1185533 |  99164706 |   454 |

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

cd ${BASE_DIR}
tally \
    --pair-by-offset --with-quality --nozip --unsorted \
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
| uniq     |      100 | 14463135400 | 144631354 |
| scythe   |      100 | 14375529511 | 144631354 |
| Q20L80   |      100 | 12382752775 | 124513758 |
| Q20L90   |      100 | 11851396527 | 118728378 |
| Q20L100  |      100 | 11258729200 | 112587292 |
| Q25L80   |      100 | 11126467271 | 111994486 |
| Q25L90   |      100 | 10522888606 | 105418214 |
| Q25L100  |      100 |  9978506000 |  99785060 |
| Q30L80   |      100 |  9022070877 |  91162128 |
| Q30L90   |      100 |  8234307462 |  82563768 |
| Q30L100  |      100 |  7586600800 |  75866008 |

## Atha: down sampling

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

ARRAY=( 
    "2_illumina/Q20L80:Q20L80"
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
    | parallel -k --no-run-if-empty -j 4 "
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
    | parallel -k --no-run-if-empty -j 8 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

| Name    |  SumFq | CovFq | AvgRead | Kmer |  SumFa | Discard% |   RealG |    EstG | Est/Real |   SumKU | SumSR |   RunTime |
|:--------|-------:|------:|--------:|-----:|-------:|---------:|--------:|--------:|---------:|--------:|------:|----------:|
| Q20L80  | 12.38G | 103.5 |      99 |   71 | 10.19G |  17.748% | 119.67M | 272.09M |     2.27 | 385.56M |     0 | 2:58'03'' |
| Q20L90  | 11.85G |  99.0 |      99 |   71 |  9.77G |  17.534% | 119.67M | 259.83M |     2.17 | 365.78M |     0 | 2:51'44'' |
| Q20L100 | 11.26G |  94.1 |     100 |   71 |   9.3G |  17.355% | 119.67M | 247.49M |     2.07 | 345.83M |     0 | 2:32'42'' |
| Q25L80  | 11.13G |  93.0 |      99 |   71 |  9.27G |  16.696% | 119.67M |  245.6M |     2.05 | 339.99M |     0 | 2:15'45'' |
| Q25L90  | 10.52G |  87.9 |      99 |   71 |  8.78G |  16.561% | 119.67M | 231.75M |     1.94 | 318.51M |     0 | 2:24'10'' |
| Q25L100 |  9.98G |  83.4 |     100 |   71 |  8.33G |  16.480% | 119.67M | 220.77M |     1.84 | 301.19M |     0 | 2:15'26'' |
| Q30L80  |  9.02G |  75.4 |      99 |   71 |  7.63G |  15.383% | 119.67M |  200.3M |     1.67 | 266.41M |     0 | 1:58'09'' |
| Q30L90  |  8.23G |  68.8 |      99 |   71 |  6.98G |  15.252% | 119.67M | 184.79M |     1.54 | 243.22M |     0 | 1:50'21'' |
| Q30L100 |  7.59G |  63.4 |     100 |   71 |  6.44G |  15.095% | 119.67M | 174.07M |     1.45 | 226.66M |     0 | 1:42'40'' |

| Name    | N50SRclean |     Sum |       # | N50Anchor |     Sum |     # | N50Anchor2 | Sum | # | N50Others |     Sum |       # |   RunTime |
|:--------|-----------:|--------:|--------:|----------:|--------:|------:|-----------:|----:|--:|----------:|--------:|--------:|----------:|
| Q20L80  |        138 | 385.56M | 2477990 |      9656 | 105.43M | 17786 |          0 |   0 | 0 |       108 | 280.13M | 2460204 | 1:36'22'' |
| Q20L90  |        141 | 365.78M | 2303276 |     10104 | 105.23M | 17068 |          0 |   0 | 0 |       108 | 260.55M | 2286208 | 1:29'20'' |
| Q20L100 |        141 | 345.83M | 2134704 |     10364 | 104.98M | 16739 |          0 |   0 | 0 |       108 | 240.85M | 2117965 | 1:17'40'' |
| Q25L80  |        141 | 339.99M | 2091315 |     10337 | 104.95M | 16800 |          0 |   0 | 0 |       107 | 235.04M | 2074515 | 1:35'50'' |
| Q25L90  |        145 | 318.51M | 1902343 |     10148 |  104.7M | 16898 |          0 |   0 | 0 |       107 | 213.81M | 1885445 | 0:55'06'' |
| Q25L100 |        150 | 301.19M | 1754751 |      9825 | 104.41M | 17270 |          0 |   0 | 0 |       107 | 196.78M | 1737481 | 0:50'24'' |
| Q30L80  |        164 | 266.41M | 1470044 |      7762 | 103.11M | 20155 |          0 |   0 | 0 |       105 |  163.3M | 1449889 | 0:46'33'' |
| Q30L90  |        196 | 243.22M | 1259700 |      7060 | 102.23M | 21338 |          0 |   0 | 0 |       106 | 140.99M | 1238362 | 0:42'19'' |
| Q30L100 |        270 | 226.66M | 1112840 |      6352 | 101.13M | 22746 |          0 |   0 | 0 |       108 | 125.53M | 1090094 | 0:23'13'' |

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
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    Q20L100/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    Q30L100/anchor/pe.anchor.fa \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "Q20L100,Q25L100,Q30L100,merge,others,paralogs" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/col_0
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
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
   | faops filter -l 0 -a 1000 stdin anchorLong/contig.fasta

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

* Stats

```bash
BASE_DIR=$HOME/data/anchr/col_0
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
| Genome       | 23459830 | 119667750 |     7 |
| Paralogs     |     2007 |  16447809 |  8055 |
| anchor.merge |    12451 | 106231584 | 15229 |
| others.merge |     1006 |    257069 |   255 |
| anchor.cover |     9844 |  97268758 | 16161 |
| anchorLong   |    14946 |  97015830 | 11902 |
| contigTrim   |    48518 | 103408026 |  4884 |
