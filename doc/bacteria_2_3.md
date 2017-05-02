# Bacteria 2+3

[TOC levels=1-3]: # " "
- [Bacteria 2+3](#bacteria-23)
- [Shigella flexneri NCTC0001](#shigella-flexneri-nctc0001)
    - [Sfle: download](#sfle-download)
    - [Sfle: combinations of different quality values and read lengths](#sfle-combinations-of-different-quality-values-and-read-lengths)
    - [Sfle: down sampling](#sfle-down-sampling)
    - [Sfle: generate super-reads](#sfle-generate-super-reads)
    - [Sfle: create anchors](#sfle-create-anchors)
    - [Sfle: results](#sfle-results)
    - [Sfle: merge anchors](#sfle-merge-anchors)
    - [Sfle: 3GS](#sfle-3gs)
    - [Sfle: expand anchors](#sfle-expand-anchors)
- [Vibrio parahaemolyticus ATCC BAA-239](#vibrio-parahaemolyticus-atcc-baa-239)
    - [Vpar: download](#vpar-download)
    - [Vpar: combinations of different quality values and read lengths](#vpar-combinations-of-different-quality-values-and-read-lengths)
    - [Vpar: down sampling](#vpar-down-sampling)
    - [Vpar: generate super-reads](#vpar-generate-super-reads)
    - [Vpar: create anchors](#vpar-create-anchors)
    - [Vpar: results](#vpar-results)
    - [Vpar: merge anchors](#vpar-merge-anchors)
    - [Vpar: 3GS](#vpar-3gs)
    - [Vpar: expand anchors](#vpar-expand-anchors)
- [Legionella pneumophila subsp. pneumophila ATCC 33152D-5; Philadelphia-1](#legionella-pneumophila-subsp-pneumophila-atcc-33152d-5-philadelphia-1)
    - [Lpne: download](#lpne-download)
    - [Lpne: combinations of different quality values and read lengths](#lpne-combinations-of-different-quality-values-and-read-lengths)
    - [Lpne: down sampling](#lpne-down-sampling)
    - [Lpne: generate super-reads](#lpne-generate-super-reads)
    - [Lpne: create anchors](#lpne-create-anchors)
    - [Lpne: results](#lpne-results)
    - [Lpne: merge anchors](#lpne-merge-anchors)
    - [Lpne: 3GS](#lpne-3gs)
    - [Lpne: expand anchors](#lpne-expand-anchors)
- [Neisseria gonorrhoeae FDAARGOS_207](#neisseria-gonorrhoeae-fdaargos-207)
    - [Ngon: download](#ngon-download)
    - [Ngon: combinations of different quality values and read lengths](#ngon-combinations-of-different-quality-values-and-read-lengths)
    - [Ngon: down sampling](#ngon-down-sampling)
    - [Ngon: generate super-reads](#ngon-generate-super-reads)
    - [Ngon: create anchors](#ngon-create-anchors)
    - [Ngon: results](#ngon-results)
    - [Ngon: merge anchors](#ngon-merge-anchors)
    - [Ngon: 3GS](#ngon-3gs)
    - [Ngon: expand anchors](#ngon-expand-anchors)
- [Neisseria meningitidis FDAARGOS_209](#neisseria-meningitidis-fdaargos-209)
    - [Nmen: download](#nmen-download)
    - [Nmen: combinations of different quality values and read lengths](#nmen-combinations-of-different-quality-values-and-read-lengths)
    - [Nmen: down sampling](#nmen-down-sampling)
    - [Nmen: generate super-reads](#nmen-generate-super-reads)
    - [Nmen: create anchors](#nmen-create-anchors)
    - [Nmen: results](#nmen-results)
    - [Nmen: merge anchors](#nmen-merge-anchors)
    - [Nmen: 3GS](#nmen-3gs)
    - [Nmen: expand anchors](#nmen-expand-anchors)
- [Listeria monocytogenes FDAARGOS_351](#listeria-monocytogenes-fdaargos-351)
    - [Lmon: download](#lmon-download)
- [Clostridioides difficile 630](#clostridioides-difficile-630)
    - [Cdif: download](#cdif-download)
- [Campylobacter jejuni subsp. jejuni ATCC 700819](#campylobacter-jejuni-subsp-jejuni-atcc-700819)
    - [Cjej: download](#cjej-download)


# Shigella flexneri NCTC0001

Project
[ERP005470](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=ERP005470)

## Sfle: download

* Reference genome

    * Strain: Shigella flexneri 2a str. 301
    * Taxid: [198214](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=198214)
    * RefSeq assembly accession:
      [GCF_000006925.2](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/925/GCF_000006925.2_ASM692v2/GCF_000006925.2_ASM692v2_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0870

```bash
mkdir -p ~/data/anchr/Sfle/1_genome
cd ~/data/anchr/Sfle/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/925/GCF_000006925.2_ASM692v2/GCF_000006925.2_ASM692v2_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_004337.2${TAB}1
NC_004851.1${TAB}pCP301
EOF

faops replace GCF_000006925.2_ASM692v2_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Sfle/Sfle.multi.fas paralogs.fas

```

* Illumina

    * [ERX518562](https://www.ncbi.nlm.nih.gov/sra/ERX518562)

```bash
mkdir -p ~/data/anchr/Sfle/2_illumina
cd ~/data/anchr/Sfle/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR559/ERR559526/ERR559526_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR559/ERR559526/ERR559526_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
b79fa3fd3b2fb0370e12b8eb910c0268    ERR559526_1.fastq.gz
30c98d66d10d194c62ace652e757c0f3    ERR559526_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s ERR559526_1.fastq.gz R1.fq.gz
ln -s ERR559526_2.fastq.gz R2.fq.gz

```

* PacBio

```bash
mkdir -p ~/data/anchr/Sfle/3_pacbio
cd ~/data/anchr/Sfle/3_pacbio

# download from sra
cat <<EOF > hdf5.txt
http://sra-download.ncbi.nlm.nih.gov/srapub_files/ERR569654_ERR569654_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/ERR569655_ERR569655_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/ERR569656_ERR569656_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/ERR569657_ERR569657_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/ERR569658_ERR569658_hdf5.tgz
EOF
aria2c -x 9 -s 3 -c -i hdf5.txt

# untar
mkdir -p ~/data/anchr/Sfle/3_pacbio/untar
cd ~/data/anchr/Sfle/3_pacbio
tar xvfz ERR569654_ERR569654_hdf5.tgz --directory untar

# convert .bax.h5 to .subreads.bam
mkdir -p ~/data/anchr/Sfle/3_pacbio/bam
cd ~/data/anchr/Sfle/3_pacbio/bam

source ~/share/pitchfork/deployment/setup-env.sh
for movie in m140529;
do 
    bax2bam ~/data/anchr/Sfle/3_pacbio/untar/${movie}*.bax.h5
done

# convert .subreads.bam to fasta
mkdir -p ~/data/anchr/Sfle/3_pacbio/fasta

for movie in m140529;
do
    if [ ! -e ~/data/anchr/Sfle/3_pacbio/bam/${movie}*.subreads.bam ]; then
        continue
    fi

    samtools fasta \
        ~/data/anchr/Sfle/3_pacbio/bam/${movie}*.subreads.bam \
        > ~/data/anchr/Sfle/3_pacbio/fasta/${movie}.fasta
done

cd ~/data/anchr/Sfle
cat 3_pacbio/fasta/*.fasta > 3_pacbio/pacbio.fasta

rm -fr ~/data/anchr/Sfle/3_pacbio/untar
```

## Sfle: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 100, 120, and 140

```bash
BASE_DIR=$HOME/data/anchr/Sfle

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
BASE_DIR=$HOME/data/anchr/Sfle
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

| Name     |     N50 |       Sum |       # |
|:---------|--------:|----------:|--------:|
| Genome   | 4607202 |   4828820 |       2 |
| Paralogs |    1377 |    543111 |     334 |
| Illumina |     150 | 346446900 | 2309646 |
| PacBio   |    3333 | 432566566 |  170957 |
| uniq     |     150 | 346176600 | 2307844 |
| scythe   |     150 | 346111063 | 2307844 |
| Q20L100  |     150 | 328666531 | 2197926 |
| Q20L120  |     150 | 324837524 | 2168358 |
| Q20L140  |     150 | 320968042 | 2140506 |
| Q25L100  |     150 | 311022174 | 2081936 |
| Q25L120  |     150 | 306051953 | 2043536 |
| Q25L140  |     150 | 300829251 | 2006054 |
| Q30L100  |     150 | 289788577 | 1942538 |
| Q30L120  |     150 | 283729287 | 1895670 |
| Q30L140  |     150 | 277115524 | 1848284 |

## Sfle: down sampling

```bash
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

ARRAY=(
    "2_illumina/Q20L100:Q20L100"
    "2_illumina/Q20L120:Q20L120"
    "2_illumina/Q20L140:Q20L140"
    "2_illumina/Q25L100:Q25L100"
    "2_illumina/Q25L120:Q25L120"
    "2_illumina/Q25L140:Q25L140"
    "2_illumina/Q30L100:Q30L100"
    "2_illumina/Q30L120:Q30L120"
    "2_illumina/Q30L140:Q30L140"
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

```bash
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

head -n 160000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.40x.fasta
faops n50 -S -C 3_pacbio/pacbio.40x.fasta

head -n 320000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.80x.fasta
faops n50 -S -C 3_pacbio/pacbio.80x.fasta

```

## Sfle: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/Sfle
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
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## Sfle: create anchors

```bash
BASE_DIR=$HOME/data/anchr/Sfle
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

## Sfle: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

REAL_G=4607202

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
BASE_DIR=$HOME/data/anchr/Sfle
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

| Name    |   SumFq | CovFq | AvgRead | Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:--------|--------:|------:|--------:|-----:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| Q20L100 | 328.67M |  82.2 |     149 |   75 | 304.35M |   7.398% |    4M | 4.21M |     1.05 | 4.55M |     0 | 0:02'16'' |
| Q20L120 | 324.84M |  81.2 |     149 |   75 |  301.6M |   7.154% |    4M |  4.2M |     1.05 |  4.5M |     0 | 0:02'13'' |
| Q20L140 | 320.97M |  80.2 |     149 |   75 | 298.81M |   6.903% |    4M |  4.2M |     1.05 | 4.47M |     0 | 0:02'13'' |
| Q25L100 | 311.02M |  77.8 |     149 |   75 |  294.9M |   5.183% |    4M | 4.19M |     1.05 | 4.39M |     0 | 0:02'08'' |
| Q25L120 | 306.05M |  76.5 |     149 |   75 | 290.56M |   5.063% |    4M | 4.19M |     1.05 | 4.38M |     0 | 0:02'12'' |
| Q25L140 | 300.83M |  75.2 |     149 |   75 | 285.99M |   4.934% |    4M | 4.19M |     1.05 | 4.37M |     0 | 0:02'01'' |
| Q30L100 | 289.79M |  72.4 |     149 |   75 | 278.21M |   3.997% |    4M | 4.18M |     1.05 | 4.36M |     0 | 0:02'01'' |
| Q30L120 | 283.73M |  70.9 |     149 |   75 | 272.49M |   3.961% |    4M | 4.18M |     1.05 | 4.36M |     0 | 0:02'03'' |
| Q30L140 | 277.12M |  69.3 |     149 |   75 | 266.25M |   3.920% |    4M | 4.18M |     1.05 | 4.36M |     0 | 0:01'57'' |

| Name    | N50SRclean |   Sum |    # | N50Anchor |   Sum |   # | N50Anchor2 | Sum | # | N50Others |     Sum |    # |   RunTime |
|:--------|-----------:|------:|-----:|----------:|------:|----:|-----------:|----:|--:|----------:|--------:|-----:|----------:|
| Q20L100 |       6851 | 4.55M | 4101 |      7831 | 4.08M | 746 |          0 |   0 | 0 |       146 | 470.55K | 3355 | 0:00'58'' |
| Q20L120 |       8590 |  4.5M | 3536 |      9233 |  4.1M | 654 |          0 |   0 | 0 |       146 | 399.42K | 2882 | 0:00'59'' |
| Q20L140 |      10476 | 4.47M | 3096 |     11088 | 4.11M | 567 |          0 |   0 | 0 |       148 | 352.51K | 2529 | 0:01'01'' |
| Q25L100 |      18669 | 4.39M | 2216 |     19997 | 4.13M | 368 |          0 |   0 | 0 |       149 | 257.93K | 1848 | 0:01'03'' |
| Q25L120 |      20866 | 4.38M | 2108 |     21543 | 4.13M | 332 |          0 |   0 | 0 |       149 | 248.94K | 1776 | 0:01'00'' |
| Q25L140 |      21543 | 4.37M | 2040 |     22428 | 4.13M | 317 |          0 |   0 | 0 |       149 | 239.15K | 1723 | 0:00'59'' |
| Q30L100 |      23341 | 4.36M | 1950 |     24803 | 4.13M | 314 |          0 |   0 | 0 |       149 | 229.47K | 1636 | 0:00'59'' |
| Q30L120 |      21662 | 4.36M | 1944 |     24239 | 4.13M | 316 |          0 |   0 | 0 |       149 | 228.24K | 1628 | 0:01'00'' |
| Q30L140 |      21779 | 4.36M | 1936 |     23086 | 4.13M | 317 |          0 |   0 | 0 |       149 | 230.97K | 1619 | 0:00'57'' |

## Sfle: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L100/anchor/pe.anchor.fa \
    Q20L120/anchor/pe.anchor.fa \
    Q20L140/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    Q25L120/anchor/pe.anchor.fa \
    Q25L140/anchor/pe.anchor.fa \
    Q30L100/anchor/pe.anchor.fa \
    Q30L120/anchor/pe.anchor.fa \
    Q30L140/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge anchor2 and others
anchr contained \
    Q20L100/anchor/pe.anchor2.fa \
    Q20L120/anchor/pe.anchor2.fa \
    Q20L140/anchor/pe.anchor2.fa \
    Q25L100/anchor/pe.anchor2.fa \
    Q25L120/anchor/pe.anchor2.fa \
    Q25L140/anchor/pe.anchor2.fa \
    Q30L100/anchor/pe.anchor2.fa \
    Q30L120/anchor/pe.anchor2.fa \
    Q30L140/anchor/pe.anchor2.fa \
    Q20L100/anchor/pe.others.fa \
    Q20L120/anchor/pe.others.fa \
    Q20L140/anchor/pe.others.fa \
    Q25L100/anchor/pe.others.fa \
    Q25L120/anchor/pe.others.fa \
    Q25L140/anchor/pe.others.fa \
    Q30L100/anchor/pe.others.fa \
    Q30L120/anchor/pe.others.fa \
    Q30L140/anchor/pe.others.fa \
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
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "merge,others,paralogs" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

## Sfle: 3GS

```bash
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

canu \
    -p Sfle -d canu-raw-40x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=4.8m \
    -pacbio-raw 3_pacbio/pacbio.40x.fasta

canu \
    -p Sfle -d canu-raw-80x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=4.8m \
    -pacbio-raw 3_pacbio/pacbio.80x.fasta

faops n50 -S -C canu-raw-40x/Sfle.trimmedReads.fasta.gz
faops n50 -S -C canu-raw-80x/Sfle.trimmedReads.fasta.gz

```

## Sfle: expand anchors

* anchorLong

```bash
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

anchr cover \
    --parallel 16 \
    -c 2 -m 40 \
    -b 20 --len 1000 --idt 0.9 \
    merge/anchor.merge.fasta \
    canu-raw-40x/Sfle.trimmedReads.fasta.gz \
    -o merge/anchor.cover.fasta

rm -fr anchorLong
anchr overlap2 \
    --parallel 16 \
    merge/anchor.cover.fasta \
    canu-raw-40x/Sfle.trimmedReads.fasta.gz \
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
   | faops filter -l 0 -a 1000 stdin anchorLong/contig.fasta

```

* contigTrim

```bash
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

rm -fr contigTrim
anchr overlap2 \
    --parallel 16 \
    anchorLong/contig.fasta \
    canu-raw-40x/Sfle.contigs.fasta \
    -d contigTrim \
    -b 20 --len 1000 --idt 0.98 --all

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

        anchr overlap --len 1000 --idt 0.98 \
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
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

rm -fr 9_qa_contig
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/anchor.cover.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-raw-40x/Sfle.contigs.fasta \
    canu-raw-80x/Sfle.contigs.fasta \
    1_genome/paralogs.fas \
    --label "merge,cover,contig,contigTrim,canu-40x,canu-80x,paralogs" \
    -o 9_qa_contig

```

* Stats

```bash
BASE_DIR=$HOME/data/anchr/Sfle
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

| Name         |     N50 |     Sum |   # |
|:-------------|--------:|--------:|----:|
| Genome       | 4607202 | 4828820 |   2 |
| Paralogs     |    1377 |  543111 | 334 |
| anchor.merge |   28583 | 4133481 | 280 |
| others.merge |    1005 |    1005 |   1 |
| anchor.cover |   20551 | 4023001 | 356 |
| anchorLong   |   20671 | 4022270 | 344 |
| contigTrim   |   56443 | 4263132 | 140 |

# Vibrio parahaemolyticus ATCC BAA-239

Project
[SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Vpar: download

* Reference genome

    * Strain: Vibrio parahaemolyticus RIMD 2210633
    * Taxid: [223926](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=223926)
    * RefSeq assembly accession:
      [GCF_000196095.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/196/095/GCF_000196095.1_ASM19609v1/GCF_000196095.1_ASM19609v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0225

```bash
mkdir -p ~/data/anchr/Vpar/1_genome
cd ~/data/anchr/Vpar/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/196/095/GCF_000196095.1_ASM19609v1/GCF_000196095.1_ASM19609v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_004603.1${TAB}1
NC_004605.1${TAB}2
EOF

faops replace GCF_000196095.1_ASM19609v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Vpar/Vpar.multi.fas paralogs.fas

```

* Illumina

    * [SRX2165170](https://www.ncbi.nlm.nih.gov/sra/SRX2165170)

```bash
mkdir -p ~/data/anchr/Vpar/2_illumina
cd ~/data/anchr/Vpar/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR424/005/SRR4244665/SRR4244665_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR424/005/SRR4244665/SRR4244665_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
e18d81e9d1e6776e3af8a7c077ca68c8 SRR4244665_1.fastq.gz
d1c22a57ff241fef3c8e98a2b1f51441 SRR4244665_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s SRR4244665_1.fastq.gz R1.fq.gz
ln -s SRR4244665_2.fastq.gz R2.fq.gz

```

* PacBio

```bash
mkdir -p ~/data/anchr/Vpar/3_pacbio
cd ~/data/anchr/Vpar/3_pacbio

# download from sra
cat <<EOF > hdf5.txt
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR4244666_SRR4244666_hdf5.tgz
EOF
aria2c -x 9 -s 3 -c -i hdf5.txt

# untar
mkdir -p ~/data/anchr/Vpar/3_pacbio/untar
cd ~/data/anchr/Vpar/3_pacbio
tar xvfz SRR4244666_SRR4244666_hdf5.tgz --directory untar

# convert .bax.h5 to .subreads.bam
mkdir -p ~/data/anchr/Vpar/3_pacbio/bam
cd ~/data/anchr/Vpar/3_pacbio/bam

source ~/share/pitchfork/deployment/setup-env.sh
for movie in m150515;
do 
    bax2bam ~/data/anchr/Vpar/3_pacbio/untar/${movie}*.bax.h5
done

# convert .subreads.bam to fasta
mkdir -p ~/data/anchr/Vpar/3_pacbio/fasta

for movie in m150515;
do
    if [ ! -e ~/data/anchr/Vpar/3_pacbio/bam/${movie}*.subreads.bam ]; then
        continue
    fi

    samtools fasta \
        ~/data/anchr/Vpar/3_pacbio/bam/${movie}*.subreads.bam \
        > ~/data/anchr/Vpar/3_pacbio/fasta/${movie}.fasta
done

cd ~/data/anchr/Vpar
cat 3_pacbio/fasta/*.fasta > 3_pacbio/pacbio.fasta

faops n50 3_pacbio/pacbio.fasta

rm -fr ~/data/anchr/Vpar/3_pacbio/untar
```

## Vpar: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 80, 90, and 100

```bash
BASE_DIR=$HOME/data/anchr/Vpar

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
BASE_DIR=$HOME/data/anchr/Vpar
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

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 3288558 |    5165770 |        2 |
| Paralogs |    3333 |     155714 |       62 |
| Illumina |     101 | 1368727962 | 13551762 |
| PacBio   |   11771 | 1228497092 |   143537 |
| uniq     |     101 | 1361783404 | 13483004 |
| scythe   |     101 | 1346787728 | 13483004 |
| Q20L80   |     101 | 1235056033 | 12260434 |
| Q20L90   |     101 | 1214510165 | 12038126 |
| Q20L100  |     101 | 1180316267 | 11686470 |
| Q25L80   |     101 | 1156319125 | 11484046 |
| Q25L90   |     101 | 1130877812 | 11208590 |
| Q25L100  |     101 | 1099548984 | 10886782 |
| Q30L80   |     101 | 1002432558 |  9976778 |
| Q30L90   |     101 |  963917300 |  9559260 |
| Q30L100  |     101 |  924641823 |  9155276 |

## Vpar: down sampling

```bash
BASE_DIR=$HOME/data/anchr/Vpar
cd ${BASE_DIR}

ARRAY=(
    "2_illumina/Q20L80:Q20L80:5000000"
    "2_illumina/Q20L90:Q20L90:5000000"
    "2_illumina/Q20L100:Q20L100:5000000"
    "2_illumina/Q25L80:Q25L80:5000000"
    "2_illumina/Q25L90:Q25L90:5000000"
    "2_illumina/Q25L100:Q25L100:5000000"
    "2_illumina/Q30L80:Q30L80:4000000"
    "2_illumina/Q30L90:Q30L90:4000000"
    "2_illumina/Q30L100:Q30L100:4000000"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    GROUP_MAX=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[2];')
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    perl -e 'print 1000000 * $_, qq{\n} for 1 .. 5' \
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

```bash
BASE_DIR=$HOME/data/anchr/Vpar
cd ${BASE_DIR}

head -n 50000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.40x.fasta
faops n50 -S -C 3_pacbio/pacbio.40x.fasta

head -n 100000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.80x.fasta
faops n50 -S -C 3_pacbio/pacbio.80x.fasta

```

## Vpar: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/Vpar
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
        for my $i ( 1 .. 5 ) {
            printf qq{%s_%d\n}, $n, ( 1000000 * $i );
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
BASE_DIR=$HOME/data/anchr/Vpar
cd ${BASE_DIR}

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## Vpar: create anchors

```bash
BASE_DIR=$HOME/data/anchr/Vpar
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
        for my $i ( 1 .. 5 ) {
            printf qq{%s_%d\n}, $n, ( 1000000 * $i );
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

## Vpar: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/Vpar
cd ${BASE_DIR}

REAL_G=5165770

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
        for my $i ( 1 .. 5 ) {
            printf qq{%s_%d\n}, $n, ( 1000000 * $i );
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
BASE_DIR=$HOME/data/anchr/Vpar
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
        for my $i ( 1 .. 5 ) {
            printf qq{%s_%d\n}, $n, ( 1000000 * $i );
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

| Name            |   SumFq | CovFq | AvgRead | Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:----------------|--------:|------:|--------:|-----:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| Q20L80_1000000  | 201.47M |  39.0 |     100 |   71 | 185.77M |   7.793% | 5.17M | 5.09M |     0.99 | 5.17M |     0 | 0:02'13'' |
| Q20L80_2000000  | 402.94M |  78.0 |     100 |   71 | 371.39M |   7.830% | 5.17M | 5.11M |     0.99 |  5.2M |     0 | 0:03'41'' |
| Q20L80_3000000  | 604.41M | 117.0 |     100 |   71 | 557.32M |   7.791% | 5.17M | 5.14M |     1.00 | 5.27M |     0 | 0:05'06'' |
| Q20L80_4000000  | 805.88M | 156.0 |     100 |   71 | 743.41M |   7.752% | 5.17M | 5.22M |     1.01 |  5.4M |     0 | 0:05'30'' |
| Q20L80_5000000  |   1.01G | 195.0 |     100 |   71 | 929.83M |   7.696% | 5.17M | 5.33M |     1.03 | 5.58M |     0 | 0:06'16'' |
| Q20L90_1000000  | 201.78M |  39.1 |     100 |   71 | 186.31M |   7.666% | 5.17M | 5.09M |     0.99 | 5.18M |     0 | 0:01'31'' |
| Q20L90_2000000  | 403.56M |  78.1 |     100 |   71 | 372.65M |   7.659% | 5.17M |  5.1M |     0.99 | 5.19M |     0 | 0:02'24'' |
| Q20L90_3000000  | 605.33M | 117.2 |     100 |   71 |  559.1M |   7.637% | 5.17M | 5.14M |     1.00 | 5.26M |     0 | 0:03'27'' |
| Q20L90_4000000  | 807.11M | 156.2 |     100 |   71 | 745.81M |   7.595% | 5.17M | 5.22M |     1.01 | 5.39M |     0 | 0:04'36'' |
| Q20L90_5000000  |   1.01G | 195.3 |     100 |   71 | 932.89M |   7.532% | 5.17M | 5.34M |     1.03 | 5.58M |     0 | 0:05'46'' |
| Q20L100_1000000 |    202M |  39.1 |     100 |   71 | 186.87M |   7.489% | 5.17M | 5.09M |     0.99 | 5.18M |     0 | 0:01'22'' |
| Q20L100_2000000 | 403.99M |  78.2 |     100 |   71 | 373.65M |   7.511% | 5.17M |  5.1M |     0.99 | 5.19M |     0 | 0:02'27'' |
| Q20L100_3000000 | 605.99M | 117.3 |     100 |   71 | 560.78M |   7.461% | 5.17M | 5.14M |     1.00 | 5.26M |     0 | 0:03'29'' |
| Q20L100_4000000 | 807.99M | 156.4 |     100 |   71 | 748.06M |   7.418% | 5.17M | 5.22M |     1.01 | 5.39M |     0 | 0:04'36'' |
| Q20L100_5000000 |   1.01G | 195.5 |     100 |   71 | 935.57M |   7.368% | 5.17M | 5.33M |     1.03 | 5.56M |     0 | 0:05'44'' |
| Q25L80_1000000  | 201.37M |  39.0 |     100 |   71 | 187.35M |   6.965% | 5.17M | 5.09M |     0.98 | 5.17M |     0 | 0:01'23'' |
| Q25L80_2000000  | 402.76M |  78.0 |     100 |   71 | 374.69M |   6.968% | 5.17M |  5.1M |     0.99 | 5.19M |     0 | 0:02'29'' |
| Q25L80_3000000  | 604.13M | 116.9 |     100 |   71 |  562.3M |   6.924% | 5.17M | 5.14M |     1.00 | 5.25M |     0 | 0:03'36'' |
| Q25L80_4000000  | 805.51M | 155.9 |     100 |   71 | 750.02M |   6.890% | 5.17M | 5.21M |     1.01 | 5.35M |     0 | 0:04'49'' |
| Q25L80_5000000  |   1.01G | 194.9 |     100 |   71 | 937.99M |   6.842% | 5.17M | 5.32M |     1.03 | 5.53M |     0 | 0:06'02'' |
| Q25L90_1000000  | 201.79M |  39.1 |     100 |   71 | 187.87M |   6.895% | 5.17M | 5.09M |     0.98 | 5.17M |     0 | 0:01'35'' |
| Q25L90_2000000  | 403.58M |  78.1 |     100 |   71 | 375.82M |   6.878% | 5.17M |  5.1M |     0.99 | 5.19M |     0 | 0:02'51'' |
| Q25L90_3000000  | 605.36M | 117.2 |     100 |   71 |  563.8M |   6.866% | 5.17M | 5.14M |     0.99 | 5.25M |     0 | 0:04'22'' |
| Q25L90_4000000  | 807.15M | 156.2 |     100 |   71 | 752.05M |   6.826% | 5.17M | 5.21M |     1.01 | 5.35M |     0 | 0:05'38'' |
| Q25L90_5000000  |   1.01G | 195.3 |     100 |   71 | 940.48M |   6.785% | 5.17M | 5.32M |     1.03 | 5.52M |     0 | 0:06'54'' |
| Q25L100_1000000 |    202M |  39.1 |     100 |   71 | 188.15M |   6.856% | 5.17M | 5.09M |     0.98 | 5.17M |     0 | 0:01'31'' |
| Q25L100_2000000 | 403.99M |  78.2 |     100 |   71 | 376.41M |   6.827% | 5.17M |  5.1M |     0.99 | 5.19M |     0 | 0:02'52'' |
| Q25L100_3000000 | 605.99M | 117.3 |     100 |   71 |  564.6M |   6.831% | 5.17M | 5.14M |     0.99 | 5.25M |     0 | 0:04'27'' |
| Q25L100_4000000 | 807.99M | 156.4 |     100 |   71 | 753.21M |   6.780% | 5.17M | 5.21M |     1.01 | 5.35M |     0 | 0:06'04'' |
| Q25L100_5000000 |   1.01G | 195.5 |     100 |   71 |    942M |   6.731% | 5.17M | 5.32M |     1.03 | 5.52M |     0 | 0:07'28'' |
| Q30L80_1000000  | 200.96M |  38.9 |     100 |   71 | 188.17M |   6.362% | 5.17M | 5.09M |     0.98 | 5.17M |     0 | 0:01'57'' |
| Q30L80_2000000  | 401.91M |  77.8 |     100 |   71 | 376.39M |   6.349% | 5.17M |  5.1M |     0.99 | 5.18M |     0 | 0:02'40'' |
| Q30L80_3000000  | 602.86M | 116.7 |     100 |   71 | 564.72M |   6.326% | 5.17M | 5.14M |     0.99 | 5.23M |     0 | 0:03'47'' |
| Q30L80_4000000  | 803.81M | 155.6 |     100 |   71 | 753.25M |   6.290% | 5.17M | 5.21M |     1.01 | 5.35M |     0 | 0:05'00'' |
| Q30L90_1000000  | 201.67M |  39.0 |     100 |   71 | 188.89M |   6.340% | 5.17M | 5.09M |     0.98 | 5.17M |     0 | 0:01'39'' |
| Q30L90_2000000  | 403.35M |  78.1 |     100 |   71 | 377.82M |   6.329% | 5.17M |  5.1M |     0.99 | 5.18M |     0 | 0:02'41'' |
| Q30L90_3000000  | 605.02M | 117.1 |     100 |   71 | 566.83M |   6.312% | 5.17M | 5.14M |     0.99 | 5.24M |     0 | 0:03'52'' |
| Q30L90_4000000  | 806.69M | 156.2 |     100 |   71 | 756.09M |   6.272% | 5.17M | 5.21M |     1.01 | 5.35M |     0 | 0:04'49'' |
| Q30L100_1000000 | 201.99M |  39.1 |     100 |   71 | 189.21M |   6.326% | 5.17M | 5.09M |     0.98 | 5.17M |     0 | 0:01'31'' |
| Q30L100_2000000 | 403.98M |  78.2 |     100 |   71 | 378.43M |   6.325% | 5.17M |  5.1M |     0.99 | 5.18M |     0 | 0:02'41'' |
| Q30L100_3000000 | 605.97M | 117.3 |     100 |   71 | 567.82M |   6.296% | 5.17M | 5.14M |     1.00 | 5.24M |     0 | 0:03'47'' |
| Q30L100_4000000 | 807.96M | 156.4 |     100 |   71 | 757.42M |   6.255% | 5.17M | 5.21M |     1.01 | 5.35M |     0 | 0:04'36'' |

| Name            | N50SRclean |   Sum |    # | N50Anchor |   Sum |   # | N50Anchor2 | Sum | # | N50Others |     Sum |    # |   RunTime |
|:----------------|-----------:|------:|-----:|----------:|------:|----:|-----------:|----:|--:|----------:|--------:|-----:|----------:|
| Q20L80_1000000  |      49313 | 5.17M | 1041 |     50728 | 5.04M | 188 |          0 |   0 | 0 |       166 | 134.47K |  853 | 0:01'49'' |
| Q20L80_2000000  |      53816 |  5.2M | 1325 |     56789 | 5.03M | 148 |          0 |   0 | 0 |       141 | 164.54K | 1177 | 0:03'01'' |
| Q20L80_3000000  |      39632 | 5.27M | 2064 |     40205 | 5.03M | 213 |          0 |   0 | 0 |       123 | 234.87K | 1851 | 0:04'16'' |
| Q20L80_4000000  |      26430 |  5.4M | 3383 |     27497 | 5.04M | 305 |          0 |   0 | 0 |       107 | 360.45K | 3078 | 0:04'10'' |
| Q20L80_5000000  |      19696 | 5.58M | 5232 |     21235 | 5.04M | 380 |          0 |   0 | 0 |       102 | 545.43K | 4852 | 0:04'53'' |
| Q20L90_1000000  |      42295 | 5.18M | 1075 |     43006 | 5.04M | 187 |          0 |   0 | 0 |       165 | 138.68K |  888 | 0:02'09'' |
| Q20L90_2000000  |      66400 | 5.19M | 1261 |     67757 | 5.03M | 142 |          0 |   0 | 0 |       141 | 160.87K | 1119 | 0:02'30'' |
| Q20L90_3000000  |      42398 | 5.26M | 2000 |     44715 | 5.04M | 202 |          0 |   0 | 0 |       123 |  227.4K | 1798 | 0:03'20'' |
| Q20L90_4000000  |      31090 | 5.39M | 3289 |     33322 | 5.04M | 267 |          0 |   0 | 0 |       107 | 354.27K | 3022 | 0:04'06'' |
| Q20L90_5000000  |      21235 | 5.58M | 5180 |     24575 | 5.03M | 346 |          0 |   0 | 0 |       101 | 543.45K | 4834 | 0:04'55'' |
| Q20L100_1000000 |      45875 | 5.18M | 1052 |     48054 | 5.04M | 206 |          0 |   0 | 0 |       167 | 133.57K |  846 | 0:02'02'' |
| Q20L100_2000000 |      81553 | 5.19M | 1221 |     82389 | 5.03M | 125 |          0 |   0 | 0 |       143 | 157.71K | 1096 | 0:02'28'' |
| Q20L100_3000000 |      46144 | 5.26M | 1924 |     48098 | 5.03M | 167 |          0 |   0 | 0 |       123 | 222.85K | 1757 | 0:03'29'' |
| Q20L100_4000000 |      32264 | 5.39M | 3231 |     34348 | 5.03M | 251 |          0 |   0 | 0 |       109 |  352.1K | 2980 | 0:04'17'' |
| Q20L100_5000000 |      26906 | 5.56M | 4951 |     28907 | 5.03M | 298 |          0 |   0 | 0 |       102 |    525K | 4653 | 0:05'11'' |
| Q25L80_1000000  |      45411 | 5.17M | 1030 |     47977 | 5.03M | 196 |          0 |   0 | 0 |       173 | 137.73K |  834 | 0:02'11'' |
| Q25L80_2000000  |      93129 | 5.19M | 1173 |     95228 | 5.03M | 115 |          0 |   0 | 0 |       146 |  152.4K | 1058 | 0:02'28'' |
| Q25L80_3000000  |      66872 | 5.25M | 1848 |     70313 | 5.03M | 124 |          0 |   0 | 0 |       125 | 221.42K | 1724 | 0:03'27'' |
| Q25L80_4000000  |      49451 | 5.35M | 2882 |     51612 | 5.03M | 163 |          0 |   0 | 0 |       109 |  319.8K | 2719 | 0:03'59'' |
| Q25L80_5000000  |      39890 | 5.53M | 4601 |     45875 | 5.03M | 194 |          0 |   0 | 0 |       101 | 490.99K | 4407 | 0:05'19'' |
| Q25L90_1000000  |      43839 | 5.17M | 1048 |     44511 | 5.04M | 199 |          0 |   0 | 0 |       168 | 134.42K |  849 | 0:02'04'' |
| Q25L90_2000000  |      93129 | 5.19M | 1177 |     93466 | 5.03M | 107 |          0 |   0 | 0 |       144 | 154.38K | 1070 | 0:02'33'' |
| Q25L90_3000000  |      66035 | 5.25M | 1802 |     67762 | 5.03M | 134 |          0 |   0 | 0 |       125 | 212.55K | 1668 | 0:03'43'' |
| Q25L90_4000000  |      73085 | 5.35M | 2843 |     75819 | 5.03M | 142 |          0 |   0 | 0 |       108 | 316.61K | 2701 | 0:03'57'' |
| Q25L90_5000000  |      45932 | 5.52M | 4567 |     51969 | 5.03M | 170 |          0 |   0 | 0 |       101 | 490.61K | 4397 | 0:04'50'' |
| Q25L100_1000000 |      45743 | 5.17M | 1022 |     47076 | 5.04M | 194 |          0 |   0 | 0 |       171 | 132.75K |  828 | 0:02'09'' |
| Q25L100_2000000 |      73085 | 5.19M | 1179 |     78106 | 5.03M | 116 |          0 |   0 | 0 |       146 | 153.69K | 1063 | 0:02'27'' |
| Q25L100_3000000 |      68721 | 5.25M | 1736 |     73085 | 5.04M | 126 |          0 |   0 | 0 |       127 | 207.65K | 1610 | 0:03'34'' |
| Q25L100_4000000 |      69502 | 5.35M | 2814 |     71704 | 5.03M | 128 |          0 |   0 | 0 |       108 | 316.83K | 2686 | 0:04'03'' |
| Q25L100_5000000 |      51969 | 5.52M | 4505 |     57494 | 5.03M | 164 |          0 |   0 | 0 |       101 | 487.21K | 4341 | 0:05'04'' |
| Q30L80_1000000  |      40853 | 5.17M | 1056 |     42639 | 5.04M | 223 |          0 |   0 | 0 |       171 | 135.19K |  833 | 0:02'05'' |
| Q30L80_2000000  |      76677 | 5.18M | 1126 |     78261 | 5.03M | 115 |          0 |   0 | 0 |       151 | 148.06K | 1011 | 0:02'37'' |
| Q30L80_3000000  |      86645 | 5.23M | 1664 |     90039 | 5.03M | 112 |          0 |   0 | 0 |       131 | 201.63K | 1552 | 0:03'36'' |
| Q30L80_4000000  |      68721 | 5.35M | 2797 |     72211 | 5.03M | 123 |          0 |   0 | 0 |       108 | 315.38K | 2674 | 0:04'10'' |
| Q30L90_1000000  |      33614 | 5.17M | 1072 |     34734 | 5.04M | 251 |          0 |   0 | 0 |       172 | 135.78K |  821 | 0:02'04'' |
| Q30L90_2000000  |      82389 | 5.18M | 1143 |     88165 | 5.03M | 114 |          0 |   0 | 0 |       148 | 150.46K | 1029 | 0:02'43'' |
| Q30L90_3000000  |      94549 | 5.24M | 1676 |     95740 | 5.03M |  98 |          0 |   0 | 0 |       128 | 205.17K | 1578 | 0:03'27'' |
| Q30L90_4000000  |      79278 | 5.35M | 2775 |     80687 | 5.03M | 120 |          0 |   0 | 0 |       110 | 315.15K | 2655 | 0:04'00'' |
| Q30L100_1000000 |      33920 | 5.17M | 1080 |     35223 | 5.04M | 252 |          0 |   0 | 0 |       172 | 136.06K |  828 | 0:01'55'' |
| Q30L100_2000000 |      88165 | 5.18M | 1123 |     88165 | 5.03M | 115 |          0 |   0 | 0 |       152 | 149.09K | 1008 | 0:02'38'' |
| Q30L100_3000000 |      82740 | 5.24M | 1718 |     83419 | 5.03M | 105 |          0 |   0 | 0 |       127 | 208.49K | 1613 | 0:03'33'' |
| Q30L100_4000000 |      81753 | 5.35M | 2762 |     95228 | 5.03M | 111 |          0 |   0 | 0 |       110 | 313.49K | 2651 | 0:03'44'' |

## Vpar: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/Vpar
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L80_2000000/anchor/pe.anchor.fa \
    Q20L80_3000000/anchor/pe.anchor.fa \
    Q20L90_2000000/anchor/pe.anchor.fa \
    Q20L90_3000000/anchor/pe.anchor.fa \
    Q20L100_2000000/anchor/pe.anchor.fa \
    Q20L100_3000000/anchor/pe.anchor.fa \
    Q25L80_2000000/anchor/pe.anchor.fa \
    Q25L80_3000000/anchor/pe.anchor.fa \
    Q25L90_2000000/anchor/pe.anchor.fa \
    Q25L90_3000000/anchor/pe.anchor.fa \
    Q25L100_2000000/anchor/pe.anchor.fa \
    Q25L100_3000000/anchor/pe.anchor.fa \
    Q30L80_2000000/anchor/pe.anchor.fa \
    Q30L80_3000000/anchor/pe.anchor.fa \
    Q30L90_2000000/anchor/pe.anchor.fa \
    Q30L90_3000000/anchor/pe.anchor.fa \
    Q30L100_2000000/anchor/pe.anchor.fa \
    Q30L100_3000000/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge anchor2 and others
anchr contained \
    Q20L80_2000000/anchor/pe.anchor2.fa \
    Q20L90_2000000/anchor/pe.anchor2.fa \
    Q20L100_2000000/anchor/pe.anchor2.fa \
    Q25L80_2000000/anchor/pe.anchor2.fa \
    Q25L90_2000000/anchor/pe.anchor2.fa \
    Q25L100_2000000/anchor/pe.anchor2.fa \
    Q30L80_2000000/anchor/pe.anchor2.fa \
    Q30L90_2000000/anchor/pe.anchor2.fa \
    Q30L100_2000000/anchor/pe.anchor2.fa \
    Q20L80_2000000/anchor/pe.others.fa \
    Q20L90_2000000/anchor/pe.others.fa \
    Q20L100_2000000/anchor/pe.others.fa \
    Q25L80_2000000/anchor/pe.others.fa \
    Q25L90_2000000/anchor/pe.others.fa \
    Q25L100_2000000/anchor/pe.others.fa \
    Q30L80_2000000/anchor/pe.others.fa \
    Q30L90_2000000/anchor/pe.others.fa \
    Q30L100_2000000/anchor/pe.others.fa \
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
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "merge,others,paralogs" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/Vpar
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

## Vpar: 3GS

```bash
BASE_DIR=$HOME/data/anchr/Vpar
cd ${BASE_DIR}

canu \
    -p Vpar -d canu-raw-40x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=5.2m \
    -pacbio-raw 3_pacbio/pacbio.40x.fasta

canu \
    -p Vpar -d canu-raw-80x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=5.2m \
    -pacbio-raw 3_pacbio/pacbio.80x.fasta

faops n50 -S -C canu-raw-40x/Vpar.trimmedReads.fasta.gz
faops n50 -S -C canu-raw-80x/Vpar.trimmedReads.fasta.gz

```

## Vpar: expand anchors

* anchorLong

```bash
BASE_DIR=$HOME/data/anchr/Vpar
cd ${BASE_DIR}

anchr cover \
    --parallel 16 \
    -c 2 -m 40 \
    -b 20 --len 1000 --idt 0.9 \
    merge/anchor.merge.fasta \
    canu-raw-40x/Vpar.trimmedReads.fasta.gz \
    -o merge/anchor.cover.fasta

rm -fr anchorLong
anchr overlap2 \
    --parallel 16 \
    merge/anchor.cover.fasta \
    canu-raw-40x/Vpar.trimmedReads.fasta.gz \
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
   | faops filter -l 0 -a 1000 stdin anchorLong/contig.fasta

```

* contigTrim

```bash
BASE_DIR=$HOME/data/anchr/Vpar
cd ${BASE_DIR}

rm -fr contigTrim
anchr overlap2 \
    --parallel 16 \
    anchorLong/contig.fasta \
    canu-raw-40x/Vpar.contigs.fasta \
    -d contigTrim \
    -b 20 --len 1000 --idt 0.98 --all

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

        anchr overlap --len 1000 --idt 0.98 \
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
BASE_DIR=$HOME/data/anchr/Vpar
cd ${BASE_DIR}

rm -fr 9_qa_contig
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/anchor.cover.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-raw-40x/Vpar.contigs.fasta \
    canu-raw-80x/Vpar.contigs.fasta \
    1_genome/paralogs.fas \
    --label "merge,cover,contig,contigTrim,canu-40x,canu-80x,paralogs" \
    -o 9_qa_contig

```

* Stats

```bash
BASE_DIR=$HOME/data/anchr/Vpar
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

| Name         |     N50 |     Sum |  # |
|:-------------|--------:|--------:|---:|
| Genome       | 3288558 | 5165770 |  2 |
| Paralogs     |    3333 |  155714 | 62 |
| anchor.merge |  174988 | 5035552 | 73 |
| others.merge |       0 |       0 |  0 |
| anchor.cover |  174988 | 5019928 | 78 |
| anchorLong   |  188292 | 5019374 | 65 |
| contigTrim   | 1488728 | 5148234 | 11 |

# Legionella pneumophila subsp. pneumophila ATCC 33152D-5; Philadelphia-1

Project
[SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Lpne: download

* Reference genome

    * Strain: Legionella pneumophila subsp. pneumophila str. Philadelphia 1
    * Taxid: [272624](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=272624&lvl=3&lin=f&keep=1&srchmode=1&unlock)
    * RefSeq assembly accession:
      [GCF_000008485.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/485/GCF_000008485.1_ASM848v1/GCF_000008485.1_ASM848v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0264

```bash
mkdir -p ~/data/anchr/Lpne/1_genome
cd ~/data/anchr/Lpne/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/485/GCF_000008485.1_ASM848v1/GCF_000008485.1_ASM848v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_002942.5${TAB}1
EOF

faops replace GCF_000008485.1_ASM848v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Lpne/Lpne.multi.fas paralogs.fas

```

* Illumina

    * [SRX2179279](https://www.ncbi.nlm.nih.gov/sra/SRX2179279) SRR4272054

```bash
mkdir -p ~/data/anchr/Lpne/2_illumina
cd ~/data/anchr/Lpne/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR427/004/SRR4272054/SRR4272054_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR427/004/SRR4272054/SRR4272054_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
6391a189c30acde364eb553e1f592a81 SRR4272054_1.fastq.gz
67ec48fd2c37e09b35f232f262c46d15 SRR4272054_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s SRR4272054_1.fastq.gz R1.fq.gz
ln -s SRR4272054_2.fastq.gz R2.fq.gz

```

* PacBio

```bash
mkdir -p ~/data/anchr/Lpne/3_pacbio
cd ~/data/anchr/Lpne/3_pacbio

# download from sra
cat <<EOF > hdf5.txt
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR4272055_SRR4272055_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR4272056_SRR4272056_hdf5.tgz
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR4272057_SRR4272057_hdf5.tgz
EOF
aria2c -x 9 -s 3 -c -i hdf5.txt

# untar
mkdir -p ~/data/anchr/Lpne/3_pacbio/untar
cd ~/data/anchr/Lpne/3_pacbio
tar xvfz SRR4272055_SRR4272055_hdf5.tgz --directory untar
tar xvfz SRR4272056_SRR4272056_hdf5.tgz --directory untar
tar xvfz SRR4272057_SRR4272057_hdf5.tgz --directory untar

# convert .bax.h5 to .subreads.bam
mkdir -p ~/data/anchr/Lpne/3_pacbio/bam
cd ~/data/anchr/Lpne/3_pacbio/bam

source ~/share/pitchfork/deployment/setup-env.sh
for movie in m141027 m141028 m150113;
do 
    bax2bam ~/data/anchr/Lpne/3_pacbio/untar/${movie}*.bax.h5
done

# convert .subreads.bam to fasta
mkdir -p ~/data/anchr/Lpne/3_pacbio/fasta

for movie in m141027 m141028 m150113;
do
    if [ ! -e ~/data/anchr/Lpne/3_pacbio/bam/${movie}*.subreads.bam ]; then
        continue
    fi

    samtools fasta \
        ~/data/anchr/Lpne/3_pacbio/bam/${movie}*.subreads.bam \
        > ~/data/anchr/Lpne/3_pacbio/fasta/${movie}.fasta
done

cd ~/data/anchr/Lpne
cat 3_pacbio/fasta/*.fasta > 3_pacbio/pacbio.fasta

rm -fr ~/data/anchr/Lpne/3_pacbio/untar
```

## Lpne: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 80, 90, and 100

```bash
BASE_DIR=$HOME/data/anchr/Lpne

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
BASE_DIR=$HOME/data/anchr/Lpne
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

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 3397754 |    3397754 |        1 |
| Paralogs |    2793 |     100722 |       43 |
| Illumina |     101 | 1060346682 | 10498482 |
| PacBio   |    8538 |  287320468 |    56763 |
| uniq     |     101 | 1056283452 | 10458252 |
| scythe   |     101 | 1048724230 | 10458252 |
| Q20L80   |     101 |  952000078 |  9457058 |
| Q20L90   |     101 |  932812628 |  9249290 |
| Q20L100  |     101 |  897545859 |  8886796 |
| Q25L80   |     101 |  865945353 |  8608796 |
| Q25L90   |     101 |  841017269 |  8338754 |
| Q25L100  |     101 |  808725449 |  8007368 |
| Q30L80   |     101 |  689401710 |  6883378 |
| Q30L90   |     101 |  645698519 |  6408976 |
| Q30L100  |     101 |  606506359 |  6005422 |

## Lpne: down sampling

```bash
BASE_DIR=$HOME/data/anchr/Lpne
cd ${BASE_DIR}

ARRAY=(
    "2_illumina/Q20L80:Q20L80:4000000"
    "2_illumina/Q20L90:Q20L90:4000000"
    "2_illumina/Q20L100:Q20L100:4000000"
    "2_illumina/Q25L80:Q25L80:4000000"
    "2_illumina/Q25L90:Q25L90:4000000"
    "2_illumina/Q25L100:Q25L100:4000000"
    "2_illumina/Q30L80:Q30L80:3000000"
    "2_illumina/Q30L90:Q30L90:3000000"
    "2_illumina/Q30L100:Q30L100:3000000"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    GROUP_MAX=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[2];')
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    perl -e 'print 1000000 * $_, qq{\n} for 1 .. 4' \
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

```bash
BASE_DIR=$HOME/data/anchr/Lpne
cd ${BASE_DIR}

head -n 50000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.40x.fasta
faops n50 -S -C 3_pacbio/pacbio.40x.fasta

head -n 100000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.80x.fasta
faops n50 -S -C 3_pacbio/pacbio.80x.fasta

```

## Lpne: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/Lpne
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
        for my $i ( 1 .. 4 ) {
            printf qq{%s_%d\n}, $n, ( 1000000 * $i );
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
BASE_DIR=$HOME/data/anchr/Lpne
cd ${BASE_DIR}

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## Lpne: create anchors

```bash
BASE_DIR=$HOME/data/anchr/Lpne
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
        for my $i ( 1 .. 4 ) {
            printf qq{%s_%d\n}, $n, ( 1000000 * $i );
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

## Lpne: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/Lpne
cd ${BASE_DIR}

REAL_G=3397754

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
        for my $i ( 1 .. 4 ) {
            printf qq{%s_%d\n}, $n, ( 1000000 * $i );
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
BASE_DIR=$HOME/data/anchr/Lpne
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
        for my $i ( 1 .. 4 ) {
            printf qq{%s_%d\n}, $n, ( 1000000 * $i );
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

| Name            |   SumFq | CovFq | AvgRead | Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:----------------|--------:|------:|--------:|-----:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| Q20L80_1000000  | 201.33M |  59.3 |     100 |   71 | 182.86M |   9.174% |  3.4M |  3.4M |     1.00 | 3.45M |     0 | 0:01'18'' |
| Q20L80_2000000  | 402.66M | 118.5 |     100 |   71 | 365.79M |   9.155% |  3.4M | 3.41M |     1.00 | 3.49M |     0 | 0:02'23'' |
| Q20L80_3000000  | 603.99M | 177.8 |     100 |   71 | 548.96M |   9.111% |  3.4M | 3.42M |     1.01 | 3.56M |     0 | 0:03'30'' |
| Q20L80_4000000  | 805.32M | 237.0 |     100 |   71 |  732.4M |   9.055% |  3.4M | 3.46M |     1.02 | 3.77M |     0 | 0:04'28'' |
| Q20L90_1000000  | 201.71M |  59.4 |     100 |   71 | 183.68M |   8.936% |  3.4M |  3.4M |     1.00 | 3.45M |     0 | 0:01'17'' |
| Q20L90_2000000  | 403.41M | 118.7 |     100 |   71 | 367.53M |   8.893% |  3.4M | 3.41M |     1.00 | 3.48M |     0 | 0:02'24'' |
| Q20L90_3000000  | 605.11M | 178.1 |     100 |   71 | 551.46M |   8.866% |  3.4M | 3.42M |     1.01 | 3.55M |     0 | 0:03'27'' |
| Q20L90_4000000  | 806.82M | 237.5 |     100 |   71 | 735.57M |   8.830% |  3.4M | 3.44M |     1.01 | 3.65M |     0 | 0:04'32'' |
| Q20L100_1000000 |    202M |  59.4 |     100 |   71 | 184.64M |   8.593% |  3.4M |  3.4M |     1.00 | 3.45M |     0 | 0:01'17'' |
| Q20L100_2000000 | 403.99M | 118.9 |     100 |   71 | 369.32M |   8.582% |  3.4M | 3.41M |     1.00 | 3.48M |     0 | 0:02'25'' |
| Q20L100_3000000 | 605.99M | 178.3 |     100 |   71 |  554.2M |   8.545% |  3.4M | 3.42M |     1.01 | 3.54M |     0 | 0:03'20'' |
| Q20L100_4000000 | 807.98M | 237.8 |     100 |   71 | 739.07M |   8.529% |  3.4M | 3.43M |     1.01 | 3.62M |     0 | 0:04'34'' |
| Q25L80_1000000  | 201.18M |  59.2 |     100 |   71 | 185.79M |   7.646% |  3.4M |  3.4M |     1.00 | 3.44M |     0 | 0:01'14'' |
| Q25L80_2000000  | 402.36M | 118.4 |     100 |   71 |  371.8M |   7.595% |  3.4M | 3.41M |     1.00 | 3.46M |     0 | 0:02'23'' |
| Q25L80_3000000  | 603.53M | 177.6 |     100 |   71 | 557.81M |   7.575% |  3.4M | 3.41M |     1.00 | 3.48M |     0 | 0:03'26'' |
| Q25L80_4000000  | 804.71M | 236.8 |     100 |   71 | 743.81M |   7.568% |  3.4M | 3.42M |     1.01 | 3.53M |     0 | 0:04'36'' |
| Q25L90_1000000  | 201.71M |  59.4 |     100 |   71 | 186.63M |   7.479% |  3.4M |  3.4M |     1.00 | 3.44M |     0 | 0:01'18'' |
| Q25L90_2000000  | 403.43M | 118.7 |     100 |   71 | 373.23M |   7.485% |  3.4M |  3.4M |     1.00 | 3.45M |     0 | 0:02'23'' |
| Q25L90_3000000  | 605.14M | 178.1 |     100 |   71 | 560.06M |   7.450% |  3.4M | 3.41M |     1.00 | 3.48M |     0 | 0:03'29'' |
| Q25L90_4000000  | 806.85M | 237.5 |     100 |   71 | 746.79M |   7.444% |  3.4M | 3.42M |     1.01 | 3.52M |     0 | 0:04'40'' |
| Q25L100_1000000 |    202M |  59.4 |     100 |   71 | 187.12M |   7.363% |  3.4M |  3.4M |     1.00 | 3.44M |     0 | 0:01'19'' |
| Q25L100_2000000 | 403.99M | 118.9 |     100 |   71 | 374.26M |   7.358% |  3.4M |  3.4M |     1.00 | 3.45M |     0 | 0:02'40'' |
| Q25L100_3000000 | 605.99M | 178.3 |     100 |   71 | 561.58M |   7.328% |  3.4M | 3.41M |     1.00 | 3.48M |     0 | 0:03'39'' |
| Q25L100_4000000 | 807.98M | 237.8 |     100 |   71 | 748.72M |   7.334% |  3.4M | 3.42M |     1.01 | 3.51M |     0 | 0:04'47'' |
| Q30L80_1000000  |  200.3M |  59.0 |     100 |   71 |  187.9M |   6.194% |  3.4M |  3.4M |     1.00 | 3.43M |     0 | 0:01'39'' |
| Q30L80_2000000  | 400.61M | 117.9 |     100 |   71 | 375.81M |   6.190% |  3.4M |  3.4M |     1.00 | 3.44M |     0 | 0:02'40'' |
| Q30L80_3000000  | 600.93M | 176.9 |     100 |   71 | 563.76M |   6.185% |  3.4M | 3.41M |     1.00 | 3.45M |     0 | 0:03'48'' |
| Q30L90_1000000  |  201.5M |  59.3 |     100 |   71 | 189.16M |   6.121% |  3.4M |  3.4M |     1.00 | 3.43M |     0 | 0:01'39'' |
| Q30L90_2000000  | 402.99M | 118.6 |     100 |   71 | 378.24M |   6.143% |  3.4M |  3.4M |     1.00 | 3.44M |     0 | 0:02'38'' |
| Q30L90_3000000  | 604.49M | 177.9 |     100 |   71 | 567.43M |   6.131% |  3.4M | 3.41M |     1.00 | 3.45M |     0 | 0:03'55'' |
| Q30L100_1000000 | 201.99M |  59.4 |     100 |   71 | 189.73M |   6.067% |  3.4M |  3.4M |     1.00 | 3.43M |     0 | 0:01'45'' |
| Q30L100_2000000 | 403.97M | 118.9 |     100 |   71 | 379.37M |   6.089% |  3.4M |  3.4M |     1.00 | 3.44M |     0 | 0:02'39'' |
| Q30L100_3000000 | 605.96M | 178.3 |     100 |   71 |  569.1M |   6.082% |  3.4M | 3.41M |     1.00 | 3.45M |     0 | 0:03'44'' |

| Name            | N50SRclean |   Sum |    # | N50Anchor |   Sum |   # | N50Anchor2 | Sum | # | N50Others |     Sum |    # |   RunTime |
|:----------------|-----------:|------:|-----:|----------:|------:|----:|-----------:|----:|--:|----------:|--------:|-----:|----------:|
| Q20L80_1000000  |      38234 | 3.45M |  801 |     40736 | 3.36M | 145 |          0 |   0 | 0 |       141 |  93.53K |  656 | 0:01'21'' |
| Q20L80_2000000  |      21126 | 3.49M | 1056 |     21170 | 3.36M | 255 |          0 |   0 | 0 |       165 | 131.92K |  801 | 0:02'50'' |
| Q20L80_3000000  |      10313 | 3.56M | 1826 |     10747 | 3.36M | 460 |          0 |   0 | 0 |       141 | 207.23K | 1366 | 0:03'26'' |
| Q20L80_4000000  |       4137 | 3.77M | 4196 |      4914 | 3.27M | 863 |          0 |   0 | 0 |       138 | 506.11K | 3333 | 0:02'33'' |
| Q20L90_1000000  |      48622 | 3.45M |  757 |     49132 | 3.36M | 126 |          0 |   0 | 0 |       141 |  91.54K |  631 | 0:00'53'' |
| Q20L90_2000000  |      22369 | 3.48M |  971 |     22641 | 3.36M | 230 |          0 |   0 | 0 |       172 | 124.65K |  741 | 0:01'51'' |
| Q20L90_3000000  |      10405 | 3.55M | 1685 |     11231 | 3.37M | 448 |          0 |   0 | 0 |       141 | 185.49K | 1237 | 0:02'12'' |
| Q20L90_4000000  |       6501 | 3.65M | 2735 |      7108 | 3.33M | 657 |          0 |   0 | 0 |       141 | 318.06K | 2078 | 0:02'47'' |
| Q20L100_1000000 |      52405 | 3.45M |  724 |     52678 | 3.36M | 117 |          0 |   0 | 0 |       153 |  92.63K |  607 | 0:00'53'' |
| Q20L100_2000000 |      23655 | 3.48M |  918 |     24079 | 3.36M | 206 |          0 |   0 | 0 |       173 |  120.8K |  712 | 0:01'45'' |
| Q20L100_3000000 |      11731 | 3.54M | 1547 |     12628 | 3.36M | 399 |          0 |   0 | 0 |       141 | 177.19K | 1148 | 0:02'26'' |
| Q20L100_4000000 |       6966 | 3.62M | 2454 |      7479 | 3.34M | 600 |          0 |   0 | 0 |       141 | 283.02K | 1854 | 0:03'00'' |
| Q25L80_1000000  |      62404 | 3.44M |  632 |     64522 | 3.36M | 100 |          0 |   0 | 0 |       161 |  83.78K |  532 | 0:01'01'' |
| Q25L80_2000000  |      46094 | 3.46M |  653 |     47607 | 3.37M | 142 |          0 |   0 | 0 |       201 |   88.5K |  511 | 0:01'39'' |
| Q25L80_3000000  |      24781 | 3.48M |  927 |     25363 | 3.38M | 239 |          0 |   0 | 0 |       141 | 106.16K |  688 | 0:02'43'' |
| Q25L80_4000000  |      13000 | 3.53M | 1469 |     13439 | 3.38M | 384 |          0 |   0 | 0 |       134 | 154.53K | 1085 | 0:03'02'' |
| Q25L90_1000000  |      50161 | 3.44M |  654 |     52335 | 3.36M | 102 |          0 |   0 | 0 |       153 |  83.75K |  552 | 0:01'15'' |
| Q25L90_2000000  |      40326 | 3.45M |  644 |     41446 | 3.36M | 146 |          0 |   0 | 0 |       214 |  90.13K |  498 | 0:01'32'' |
| Q25L90_3000000  |      22325 | 3.48M |  934 |     22653 | 3.38M | 239 |          0 |   0 | 0 |       141 | 105.82K |  695 | 0:02'27'' |
| Q25L90_4000000  |      14641 | 3.52M | 1351 |     15060 | 3.38M | 365 |          0 |   0 | 0 |       133 |  138.6K |  986 | 0:02'44'' |
| Q25L100_1000000 |      64522 | 3.44M |  611 |     64936 | 3.36M |  97 |          0 |   0 | 0 |       150 |  79.95K |  514 | 0:01'06'' |
| Q25L100_2000000 |      43540 | 3.45M |  582 |     44594 | 3.37M | 124 |          0 |   0 | 0 |       198 |  79.91K |  458 | 0:01'43'' |
| Q25L100_3000000 |      26186 | 3.48M |  825 |     27229 | 3.38M | 214 |          0 |   0 | 0 |       141 |  96.19K |  611 | 0:02'25'' |
| Q25L100_4000000 |      15040 | 3.51M | 1261 |     15825 | 3.38M | 344 |          0 |   0 | 0 |       136 | 131.59K |  917 | 0:02'47'' |
| Q30L80_1000000  |      55619 | 3.43M |  579 |     56390 | 3.36M | 106 |          0 |   0 | 0 |       151 |  72.43K |  473 | 0:01'15'' |
| Q30L80_2000000  |      57309 | 3.44M |  512 |     57309 | 3.37M | 109 |          0 |   0 | 0 |       216 |  74.67K |  403 | 0:01'49'' |
| Q30L80_3000000  |      45755 | 3.45M |  573 |     46311 | 3.38M | 151 |          0 |   0 | 0 |       165 |  68.76K |  422 | 0:02'06'' |
| Q30L90_1000000  |      65754 | 3.43M |  571 |     70664 | 3.36M |  92 |          0 |   0 | 0 |       156 |  74.32K |  479 | 0:00'58'' |
| Q30L90_2000000  |      64522 | 3.44M |  511 |     66366 | 3.36M | 101 |          0 |   0 | 0 |       229 |  77.01K |  410 | 0:01'51'' |
| Q30L90_3000000  |      51935 | 3.45M |  540 |     52414 | 3.38M | 134 |          0 |   0 | 0 |       190 |  69.42K |  406 | 0:02'21'' |
| Q30L100_1000000 |      57424 | 3.43M |  587 |     59077 | 3.36M | 106 |          0 |   0 | 0 |       155 |  74.88K |  481 | 0:01'04'' |
| Q30L100_2000000 |      65219 | 3.44M |  516 |     65219 | 3.36M | 102 |          0 |   0 | 0 |       253 |  80.02K |  414 | 0:01'42'' |
| Q30L100_3000000 |      49783 | 3.45M |  547 |     52768 | 3.38M | 135 |          0 |   0 | 0 |       190 |  69.95K |  412 | 0:02'04'' |

## Lpne: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/Lpne
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L80_1000000/anchor/pe.anchor.fa \
    Q20L80_2000000/anchor/pe.anchor.fa \
    Q20L90_1000000/anchor/pe.anchor.fa \
    Q20L90_2000000/anchor/pe.anchor.fa \
    Q20L100_1000000/anchor/pe.anchor.fa \
    Q20L100_2000000/anchor/pe.anchor.fa \
    Q25L80_1000000/anchor/pe.anchor.fa \
    Q25L80_2000000/anchor/pe.anchor.fa \
    Q25L90_1000000/anchor/pe.anchor.fa \
    Q25L90_2000000/anchor/pe.anchor.fa \
    Q25L100_1000000/anchor/pe.anchor.fa \
    Q25L100_2000000/anchor/pe.anchor.fa \
    Q30L80_1000000/anchor/pe.anchor.fa \
    Q30L80_2000000/anchor/pe.anchor.fa \
    Q30L90_1000000/anchor/pe.anchor.fa \
    Q30L90_2000000/anchor/pe.anchor.fa \
    Q30L100_1000000/anchor/pe.anchor.fa \
    Q30L100_2000000/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge anchor2 and others
anchr contained \
    Q20L80_2000000/anchor/pe.anchor2.fa \
    Q20L90_2000000/anchor/pe.anchor2.fa \
    Q20L100_2000000/anchor/pe.anchor2.fa \
    Q25L80_2000000/anchor/pe.anchor2.fa \
    Q25L90_2000000/anchor/pe.anchor2.fa \
    Q25L100_2000000/anchor/pe.anchor2.fa \
    Q30L80_2000000/anchor/pe.anchor2.fa \
    Q30L90_2000000/anchor/pe.anchor2.fa \
    Q30L100_2000000/anchor/pe.anchor2.fa \
    Q20L80_2000000/anchor/pe.others.fa \
    Q20L90_2000000/anchor/pe.others.fa \
    Q20L100_2000000/anchor/pe.others.fa \
    Q25L80_2000000/anchor/pe.others.fa \
    Q25L90_2000000/anchor/pe.others.fa \
    Q25L100_2000000/anchor/pe.others.fa \
    Q30L80_2000000/anchor/pe.others.fa \
    Q30L90_2000000/anchor/pe.others.fa \
    Q30L100_2000000/anchor/pe.others.fa \
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
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "merge,others,paralogs" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/Lpne
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

## Lpne: 3GS

```bash
BASE_DIR=$HOME/data/anchr/Lpne
cd ${BASE_DIR}

canu \
    -p Lpne -d canu-raw-40x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=3.4m \
    -pacbio-raw 3_pacbio/pacbio.40x.fasta

canu \
    -p Lpne -d canu-raw-80x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=3.4m \
    -pacbio-raw 3_pacbio/pacbio.80x.fasta

faops n50 -S -C canu-raw-40x/Lpne.trimmedReads.fasta.gz
faops n50 -S -C canu-raw-80x/Lpne.trimmedReads.fasta.gz

```

## Lpne: expand anchors

* anchorLong

```bash
BASE_DIR=$HOME/data/anchr/Lpne
cd ${BASE_DIR}

anchr cover \
    --parallel 16 \
    -c 2 -m 40 \
    -b 20 --len 1000 --idt 0.9 \
    merge/anchor.merge.fasta \
    canu-raw-40x/Lpne.trimmedReads.fasta.gz \
    -o merge/anchor.cover.fasta

rm -fr anchorLong
anchr overlap2 \
    --parallel 16 \
    merge/anchor.cover.fasta \
    canu-raw-40x/Lpne.trimmedReads.fasta.gz \
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
   | faops filter -l 0 -a 1000 stdin anchorLong/contig.fasta

```

* contigTrim

```bash
BASE_DIR=$HOME/data/anchr/Lpne
cd ${BASE_DIR}

rm -fr contigTrim
anchr overlap2 \
    --parallel 16 \
    anchorLong/contig.fasta \
    canu-raw-40x/Lpne.contigs.fasta \
    -d contigTrim \
    -b 20 --len 1000 --idt 0.98 --all

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

        anchr overlap --len 1000 --idt 0.98 \
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
BASE_DIR=$HOME/data/anchr/Lpne
cd ${BASE_DIR}

rm -fr 9_qa_contig
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/anchor.cover.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-raw-40x/Lpne.contigs.fasta \
    canu-raw-80x/Lpne.contigs.fasta \
    1_genome/paralogs.fas \
    --label "merge,cover,contig,contigTrim,canu-40x,canu-80x,paralogs" \
    -o 9_qa_contig

```

* Stats

```bash
BASE_DIR=$HOME/data/anchr/Lpne
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

| Name         |     N50 |     Sum |  # |
|:-------------|--------:|--------:|---:|
| Genome       | 3397754 | 3397754 |  1 |
| Paralogs     |    2793 |  100722 | 43 |
| anchor.merge |  197241 | 3389376 | 70 |
| others.merge |    1006 |    3017 |  3 |
| anchor.cover |  197241 | 3353796 | 47 |
| anchorLong   |  219462 | 3351696 | 34 |
| contigTrim   | 2957768 | 3410381 |  4 |

# Neisseria gonorrhoeae FDAARGOS_207

Project
[SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Ngon: download

* Reference genome

    * Strain: Neisseria gonorrhoeae FA 1090
    * Taxid: [242231](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=242231)
    * RefSeq assembly accession:
      [GCF_000006845.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/845/GCF_000006845.1_ASM684v1/GCF_000006845.1_ASM684v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0546

```bash
mkdir -p ~/data/anchr/Ngon/1_genome
cd ~/data/anchr/Ngon/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/845/GCF_000006845.1_ASM684v1/GCF_000006845.1_ASM684v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_002946.2${TAB}1
EOF

faops replace GCF_000006845.1_ASM684v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Ngon/Ngon.multi.fas paralogs.fas

```

SRX2179294 SRX2179295

* Illumina

    * [SRX2179294](https://www.ncbi.nlm.nih.gov/sra/SRX2179294) SRR4272072

```bash
mkdir -p ~/data/anchr/Ngon/2_illumina
cd ~/data/anchr/Ngon/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR427/002/SRR4272072/SRR4272072_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR427/002/SRR4272072/SRR4272072_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
0e6b38963276a1fdc256eb1f843025bc SRR4272072_1.fastq.gz
532bbf1672dec3316a868774f411d50e SRR4272072_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s SRR4272072_1.fastq.gz R1.fq.gz
ln -s SRR4272072_2.fastq.gz R2.fq.gz

```

* PacBio

```bash
mkdir -p ~/data/anchr/Ngon/3_pacbio
cd ~/data/anchr/Ngon/3_pacbio

# download from sra
cat <<EOF > hdf5.txt
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR4272071_SRR4272071_hdf5.tgz
EOF
aria2c -x 9 -s 3 -c -i hdf5.txt

# untar
mkdir -p ~/data/anchr/Ngon/3_pacbio/untar
cd ~/data/anchr/Ngon/3_pacbio
tar xvfz SRR4272071_SRR4272071_hdf5.tgz --directory untar

# convert .bax.h5 to .subreads.bam
mkdir -p ~/data/anchr/Ngon/3_pacbio/bam
cd ~/data/anchr/Ngon/3_pacbio/bam

source ~/share/pitchfork/deployment/setup-env.sh
for movie in m150115;
do 
    bax2bam ~/data/anchr/Ngon/3_pacbio/untar/${movie}*.bax.h5
done

# convert .subreads.bam to fasta
mkdir -p ~/data/anchr/Ngon/3_pacbio/fasta

for movie in m150115;
do
    if [ ! -e ~/data/anchr/Ngon/3_pacbio/bam/${movie}*.subreads.bam ]; then
        continue
    fi

    samtools fasta \
        ~/data/anchr/Ngon/3_pacbio/bam/${movie}*.subreads.bam \
        > ~/data/anchr/Ngon/3_pacbio/fasta/${movie}.fasta
done

cd ~/data/anchr/Ngon
cat 3_pacbio/fasta/*.fasta > 3_pacbio/pacbio.fasta

faops n50 3_pacbio/pacbio.fasta

rm -fr ~/data/anchr/Ngon/3_pacbio/untar
```

## Ngon: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 80, 90, and 100

```bash
BASE_DIR=$HOME/data/anchr/Ngon

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
BASE_DIR=$HOME/data/anchr/Ngon
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

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 2153922 |    2153922 |        1 |
| Paralogs |    4318 |     142093 |       53 |
| Illumina |     101 | 1491583958 | 14768158 |
| PacBio   |   11808 | 1187845820 |   137516 |
| uniq     |     101 | 1485449016 | 14707416 |
| scythe   |     101 | 1460356291 | 14707416 |
| Q20L80   |     101 | 1156993843 | 11540782 |
| Q20L90   |     101 | 1099857225 | 10921560 |
| Q20L100  |     101 | 1018663400 | 10085908 |
| Q25L80   |     101 |  944529104 |  9436736 |
| Q25L90   |     101 |  880635570 |  8744142 |
| Q25L100  |     101 |  815899053 |  8078308 |
| Q30L80   |     101 |  566164368 |  5695484 |
| Q30L90   |     101 |  496616122 |  4939738 |
| Q30L100  |     101 |  441995355 |  4376350 |

## Ngon: down sampling

```bash
BASE_DIR=$HOME/data/anchr/Ngon
cd ${BASE_DIR}

ARRAY=(
    "2_illumina/Q20L80:Q20L80:4000000"
    "2_illumina/Q20L90:Q20L90:4000000"
    "2_illumina/Q20L100:Q20L100:4000000"
    "2_illumina/Q25L80:Q25L80:4000000"
    "2_illumina/Q25L90:Q25L90:4000000"
    "2_illumina/Q25L100:Q25L100:4000000"
    "2_illumina/Q30L80:Q30L80:2000000"
    "2_illumina/Q30L90:Q30L90:2000000"
    "2_illumina/Q30L100:Q30L100:2000000"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    GROUP_MAX=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[2];')
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    perl -e 'print 1000000 * $_, qq{\n} for 1 .. 4' \
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

```bash
BASE_DIR=$HOME/data/anchr/Ngon
cd ${BASE_DIR}

head -n 25000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.40x.fasta
faops n50 -S -C 3_pacbio/pacbio.40x.fasta

head -n 50000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.80x.fasta
faops n50 -S -C 3_pacbio/pacbio.80x.fasta

```

## Ngon: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/Ngon
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
        for my $i ( 1 .. 4 ) {
            printf qq{%s_%d\n}, $n, ( 1000000 * $i );
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
BASE_DIR=$HOME/data/anchr/Ngon
cd ${BASE_DIR}

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## Ngon: create anchors

```bash
BASE_DIR=$HOME/data/anchr/Ngon
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
        for my $i ( 1 .. 4 ) {
            printf qq{%s_%d\n}, $n, ( 1000000 * $i );
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

## Ngon: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/Ngon
cd ${BASE_DIR}

REAL_G=2153922

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
        for my $i ( 1 .. 4 ) {
            printf qq{%s_%d\n}, $n, ( 1000000 * $i );
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
BASE_DIR=$HOME/data/anchr/Ngon
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
        for my $i ( 1 .. 4 ) {
            printf qq{%s_%d\n}, $n, ( 1000000 * $i );
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

| Name            |   SumFq | CovFq | AvgRead | Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:----------------|--------:|------:|--------:|-----:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| Q20L80_1000000  | 200.52M |  93.1 |     100 |   51 | 179.86M |  10.300% | 2.15M | 2.07M |     0.96 | 2.28M |     0 | 0:01'24'' |
| Q20L80_2000000  |    401M | 186.2 |     100 |   51 | 360.04M |  10.216% | 2.15M |  2.1M |     0.97 | 2.49M |     0 | 0:02'50'' |
| Q20L80_3000000  | 601.52M | 279.3 |     100 |   51 | 542.02M |   9.891% | 2.15M | 2.23M |     1.04 | 3.22M |     0 | 0:03'58'' |
| Q20L80_4000000  | 802.03M | 372.4 |     100 |   51 | 723.99M |   9.730% | 2.15M | 2.35M |     1.09 | 3.86M |     0 | 0:05'05'' |
| Q20L90_1000000  | 201.41M |  93.5 |     100 |   51 | 181.14M |  10.062% | 2.15M | 2.06M |     0.96 | 2.27M |     0 | 0:01'36'' |
| Q20L90_2000000  | 402.82M | 187.0 |     100 |   51 | 362.71M |   9.958% | 2.15M | 2.09M |     0.97 | 2.45M |     0 | 0:02'39'' |
| Q20L90_3000000  | 604.23M | 280.5 |     100 |   51 | 545.95M |   9.646% | 2.15M | 2.22M |     1.03 | 3.14M |     0 | 0:04'08'' |
| Q20L90_4000000  | 805.64M | 374.0 |     100 |   51 | 729.16M |   9.493% | 2.15M | 2.33M |     1.08 | 3.73M |     0 | 0:05'11'' |
| Q20L100_1000000 |    202M |  93.8 |     100 |   51 | 182.13M |   9.835% | 2.15M | 2.05M |     0.95 | 2.21M |     0 | 0:01'40'' |
| Q20L100_2000000 | 403.99M | 187.6 |     100 |   51 |    365M |   9.652% | 2.15M | 2.09M |     0.97 | 2.42M |     0 | 0:02'49'' |
| Q20L100_3000000 | 605.99M | 281.3 |     100 |   51 | 549.15M |   9.381% | 2.15M | 2.19M |     1.02 | 3.01M |     0 | 0:04'05'' |
| Q20L100_4000000 | 807.99M | 375.1 |     100 |   51 | 733.35M |   9.237% | 2.15M |  2.3M |     1.07 | 3.57M |     0 | 0:05'14'' |
| Q25L80_1000000  | 200.19M |  92.9 |     100 |   51 | 183.81M |   8.182% | 2.15M | 2.05M |     0.95 | 2.17M |     0 | 0:01'43'' |
| Q25L80_2000000  | 400.36M | 185.9 |     100 |   51 | 367.89M |   8.112% | 2.15M | 2.06M |     0.96 | 2.24M |     0 | 0:03'01'' |
| Q25L80_3000000  | 600.54M | 278.8 |     100 |   51 | 552.55M |   7.992% | 2.15M | 2.11M |     0.98 |  2.5M |     0 | 0:04'07'' |
| Q25L80_4000000  | 800.72M | 371.8 |      99 |   51 | 737.27M |   7.924% | 2.15M | 2.16M |     1.00 | 2.76M |     0 | 0:05'20'' |
| Q25L90_1000000  | 201.42M |  93.5 |     100 |   51 |  185.1M |   8.105% | 2.15M | 2.04M |     0.95 | 2.17M |     0 | 0:01'35'' |
| Q25L90_2000000  | 402.85M | 187.0 |     100 |   51 | 370.44M |   8.045% | 2.15M | 2.06M |     0.96 | 2.23M |     0 | 0:02'56'' |
| Q25L90_3000000  | 604.27M | 280.5 |     100 |   51 | 556.47M |   7.910% | 2.15M | 2.11M |     0.98 | 2.48M |     0 | 0:04'12'' |
| Q25L90_4000000  | 805.69M | 374.1 |     100 |   51 |  742.5M |   7.843% | 2.15M | 2.16M |     1.00 | 2.73M |     0 | 0:05'06'' |
| Q25L100_1000000 |    202M |  93.8 |     100 |   51 | 185.78M |   8.030% | 2.15M | 2.04M |     0.95 | 2.16M |     0 | 0:01'44'' |
| Q25L100_2000000 |    404M | 187.6 |     100 |   51 | 371.83M |   7.961% | 2.15M | 2.06M |     0.95 | 2.23M |     0 | 0:02'48'' |
| Q25L100_3000000 | 605.99M | 281.3 |     100 |   51 | 558.31M |   7.868% | 2.15M |  2.1M |     0.98 | 2.45M |     0 | 0:04'08'' |
| Q25L100_4000000 | 807.99M | 375.1 |     100 |   51 |    745M |   7.796% | 2.15M | 2.15M |     1.00 | 2.69M |     0 | 0:05'27'' |
| Q30L80_1000000  | 198.81M |  92.3 |      99 |   71 | 186.18M |   6.353% | 2.15M | 2.04M |     0.95 | 2.15M |     0 | 0:01'33'' |
| Q30L80_2000000  | 397.63M | 184.6 |      99 |   71 | 372.43M |   6.337% | 2.15M | 2.05M |     0.95 | 2.17M |     0 | 0:02'40'' |
| Q30L90_1000000  | 201.07M |  93.3 |     100 |   71 | 188.31M |   6.347% | 2.15M | 2.04M |     0.95 | 2.15M |     0 | 0:01'33'' |
| Q30L90_2000000  | 402.14M | 186.7 |     100 |   71 |  376.7M |   6.325% | 2.15M | 2.05M |     0.95 | 2.17M |     0 | 0:02'38'' |
| Q30L100_1000000 | 201.99M |  93.8 |     100 |   71 |  189.1M |   6.380% | 2.15M | 2.04M |     0.95 | 2.15M |     0 | 0:01'29'' |
| Q30L100_2000000 | 403.99M | 187.6 |     100 |   71 | 378.43M |   6.326% | 2.15M | 2.05M |     0.95 | 2.17M |     0 | 0:02'39'' |

| Name            | N50SRclean |   Sum |     # | N50Anchor |     Sum |   # | N50Anchor2 | Sum | # | N50Others |     Sum |     # |   RunTime |
|:----------------|-----------:|------:|------:|----------:|--------:|----:|-----------:|----:|--:|----------:|--------:|------:|----------:|
| Q20L80_1000000  |       3659 | 2.28M |  3936 |      4540 |   1.85M | 530 |          0 |   0 | 0 |       127 |  436.1K |  3406 | 0:04'41'' |
| Q20L80_2000000  |       1545 | 2.49M |  7061 |      2627 |   1.59M | 701 |          0 |   0 | 0 |       189 | 902.08K |  6360 | 0:04'55'' |
| Q20L80_3000000  |        369 | 3.22M | 18252 |      1344 | 577.16K | 412 |          0 |   0 | 0 |       229 |   2.64M | 17840 | 0:05'31'' |
| Q20L80_4000000  |        159 | 3.86M | 27983 |      1295 | 222.01K | 168 |          0 |   0 | 0 |       131 |   3.64M | 27815 | 0:03'08'' |
| Q20L90_1000000  |       3690 | 2.27M |  3750 |      4497 |   1.88M | 530 |          0 |   0 | 0 |       105 | 392.51K |  3220 | 0:01'44'' |
| Q20L90_2000000  |       1799 | 2.45M |  6438 |      2603 |   1.66M | 708 |          0 |   0 | 0 |       150 | 788.91K |  5730 | 0:02'18'' |
| Q20L90_3000000  |        407 | 3.14M | 16936 |      1423 | 670.06K | 457 |          0 |   0 | 0 |       234 |   2.47M | 16479 | 0:02'56'' |
| Q20L90_4000000  |        188 | 3.73M | 25881 |      1254 | 282.56K | 219 |          0 |   0 | 0 |       143 |   3.44M | 25662 | 0:03'24'' |
| Q20L100_1000000 |       6620 | 2.21M |  2765 |      7899 |   1.94M | 369 |          0 |   0 | 0 |       101 | 265.43K |  2396 | 0:01'51'' |
| Q20L100_2000000 |       2143 | 2.42M |  5931 |      3122 |    1.7M | 643 |          0 |   0 | 0 |       140 | 716.06K |  5288 | 0:02'21'' |
| Q20L100_3000000 |        500 | 3.01M | 15014 |      1478 | 791.85K | 531 |          0 |   0 | 0 |       259 |   2.22M | 14483 | 0:02'58'' |
| Q20L100_4000000 |        229 | 3.57M | 23445 |      1248 |  350.5K | 269 |          0 |   0 | 0 |       167 |   3.22M | 23176 | 0:03'18'' |
| Q25L80_1000000  |      10766 | 2.17M |  2126 |     12192 |   1.98M | 269 |          0 |   0 | 0 |       101 | 191.33K |  1857 | 0:01'55'' |
| Q25L80_2000000  |       5477 | 2.24M |  3240 |      6325 |   1.93M | 425 |          0 |   0 | 0 |       101 | 313.37K |  2815 | 0:02'33'' |
| Q25L80_3000000  |       1546 |  2.5M |  7272 |      2488 |   1.61M | 725 |          0 |   0 | 0 |       163 | 898.57K |  6547 | 0:03'14'' |
| Q25L80_4000000  |        852 | 2.76M | 11054 |      1745 |   1.24M | 731 |          0 |   0 | 0 |       232 |   1.52M | 10323 | 0:03'22'' |
| Q25L90_1000000  |      10376 | 2.17M |  2102 |     10956 |   1.98M | 260 |          0 |   0 | 0 |       101 | 189.84K |  1842 | 0:01'55'' |
| Q25L90_2000000  |       5681 | 2.23M |  3117 |      7025 |   1.94M | 396 |          0 |   0 | 0 |       101 | 296.33K |  2721 | 0:02'22'' |
| Q25L90_3000000  |       1646 | 2.48M |  6820 |      2635 |   1.64M | 719 |          0 |   0 | 0 |       154 | 840.02K |  6101 | 0:03'08'' |
| Q25L90_4000000  |        909 | 2.73M | 10632 |      1823 |   1.27M | 718 |          0 |   0 | 0 |       231 |   1.46M |  9914 | 0:03'40'' |
| Q25L100_1000000 |      10578 | 2.16M |  2053 |     11529 |   1.98M | 265 |          0 |   0 | 0 |       101 | 181.76K |  1788 | 0:02'03'' |
| Q25L100_2000000 |       6989 | 2.23M |  3006 |      7844 |   1.94M | 367 |          0 |   0 | 0 |       101 | 287.29K |  2639 | 0:02'31'' |
| Q25L100_3000000 |       1863 | 2.45M |  6428 |      2718 |    1.7M | 716 |          0 |   0 | 0 |       134 | 754.07K |  5712 | 0:02'59'' |
| Q25L100_4000000 |       1023 | 2.69M |  9961 |      1903 |   1.37M | 745 |          0 |   0 | 0 |       198 |   1.32M |  9216 | 0:03'23'' |
| Q30L80_1000000  |      11924 | 2.15M |  1290 |     13459 |   1.99M | 242 |          0 |   0 | 0 |       164 | 162.92K |  1048 | 0:01'57'' |
| Q30L80_2000000  |      13036 | 2.17M |  1454 |     14151 |      2M | 240 |          0 |   0 | 0 |       141 | 170.68K |  1214 | 0:02'33'' |
| Q30L90_1000000  |      11160 | 2.15M |  1289 |     13020 |   1.99M | 260 |          0 |   0 | 0 |       171 | 164.07K |  1029 | 0:02'00'' |
| Q30L90_2000000  |      12381 | 2.17M |  1465 |     13417 |      2M | 246 |          0 |   0 | 0 |       141 |  172.4K |  1219 | 0:02'43'' |
| Q30L100_1000000 |       9818 | 2.15M |  1316 |     10973 |   1.99M | 271 |          0 |   0 | 0 |       164 |  162.3K |  1045 | 0:01'49'' |
| Q30L100_2000000 |      12276 | 2.17M |  1467 |     13938 |      2M | 247 |          0 |   0 | 0 |       141 | 173.47K |  1220 | 0:02'36'' |

## Ngon: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/Ngon
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L80_1000000/anchor/pe.anchor.fa \
    Q20L80_2000000/anchor/pe.anchor.fa \
    Q20L90_1000000/anchor/pe.anchor.fa \
    Q20L90_2000000/anchor/pe.anchor.fa \
    Q20L100_1000000/anchor/pe.anchor.fa \
    Q20L100_2000000/anchor/pe.anchor.fa \
    Q25L80_1000000/anchor/pe.anchor.fa \
    Q25L80_2000000/anchor/pe.anchor.fa \
    Q25L90_1000000/anchor/pe.anchor.fa \
    Q25L90_2000000/anchor/pe.anchor.fa \
    Q25L100_1000000/anchor/pe.anchor.fa \
    Q25L100_2000000/anchor/pe.anchor.fa \
    Q30L80_1000000/anchor/pe.anchor.fa \
    Q30L80_2000000/anchor/pe.anchor.fa \
    Q30L90_1000000/anchor/pe.anchor.fa \
    Q30L90_2000000/anchor/pe.anchor.fa \
    Q30L100_1000000/anchor/pe.anchor.fa \
    Q30L100_2000000/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge anchor2 and others
anchr contained \
    Q20L80_2000000/anchor/pe.anchor2.fa \
    Q20L90_2000000/anchor/pe.anchor2.fa \
    Q20L100_2000000/anchor/pe.anchor2.fa \
    Q25L80_2000000/anchor/pe.anchor2.fa \
    Q25L90_2000000/anchor/pe.anchor2.fa \
    Q25L100_2000000/anchor/pe.anchor2.fa \
    Q30L80_2000000/anchor/pe.anchor2.fa \
    Q30L90_2000000/anchor/pe.anchor2.fa \
    Q30L100_2000000/anchor/pe.anchor2.fa \
    Q20L80_2000000/anchor/pe.others.fa \
    Q20L90_2000000/anchor/pe.others.fa \
    Q20L100_2000000/anchor/pe.others.fa \
    Q25L80_2000000/anchor/pe.others.fa \
    Q25L90_2000000/anchor/pe.others.fa \
    Q25L100_2000000/anchor/pe.others.fa \
    Q30L80_2000000/anchor/pe.others.fa \
    Q30L90_2000000/anchor/pe.others.fa \
    Q30L100_2000000/anchor/pe.others.fa \
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
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "merge,others,paralogs" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/Ngon
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

## Ngon: 3GS

```bash
BASE_DIR=$HOME/data/anchr/Ngon
cd ${BASE_DIR}

canu \
    -p Ngon -d canu-raw-40x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=2.3m \
    -pacbio-raw 3_pacbio/pacbio.40x.fasta

canu \
    -p Ngon -d canu-raw-80x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=2.3m \
    -pacbio-raw 3_pacbio/pacbio.80x.fasta

faops n50 -S -C canu-raw-40x/Ngon.trimmedReads.fasta.gz
faops n50 -S -C canu-raw-80x/Ngon.trimmedReads.fasta.gz

```

## Ngon: expand anchors

* anchorLong

```bash
BASE_DIR=$HOME/data/anchr/Ngon
cd ${BASE_DIR}

anchr cover \
    --parallel 16 \
    -c 2 -m 40 \
    -b 20 --len 1000 --idt 0.9 \
    merge/anchor.merge.fasta \
    canu-raw-40x/Ngon.trimmedReads.fasta.gz \
    -o merge/anchor.cover.fasta

rm -fr anchorLong
anchr overlap2 \
    --parallel 16 \
    merge/anchor.cover.fasta \
    canu-raw-40x/Ngon.trimmedReads.fasta.gz \
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
   | faops filter -l 0 -a 1000 stdin anchorLong/contig.fasta

```

* contigTrim

```bash
BASE_DIR=$HOME/data/anchr/Ngon
cd ${BASE_DIR}

rm -fr contigTrim
anchr overlap2 \
    --parallel 16 \
    anchorLong/contig.fasta \
    canu-raw-40x/Ngon.contigs.fasta \
    -d contigTrim \
    -b 20 --len 1000 --idt 0.98 --all

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

        anchr overlap --len 1000 --idt 0.98 \
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
BASE_DIR=$HOME/data/anchr/Ngon
cd ${BASE_DIR}

rm -fr 9_qa_contig
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/anchor.cover.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-raw-40x/Ngon.contigs.fasta \
    canu-raw-80x/Ngon.contigs.fasta \
    1_genome/paralogs.fas \
    --label "merge,cover,contig,contigTrim,canu-40x,canu-80x,paralogs" \
    -o 9_qa_contig

```

* Stats

```bash
BASE_DIR=$HOME/data/anchr/Ngon
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

| Name         |     N50 |     Sum |   # |
|:-------------|--------:|--------:|----:|
| Genome       | 2153922 | 2153922 |   1 |
| Paralogs     |    4318 |  142093 |  53 |
| anchor.merge |   19941 | 2005051 | 172 |
| others.merge |    1000 |    6004 |   6 |
| anchor.cover |   17994 | 1874483 | 181 |
| anchorLong   |   23846 | 1872090 | 137 |
| contigTrim   |  497733 | 1942945 |  17 |

# Neisseria meningitidis FDAARGOS_209

Project
[SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Nmen: download

* Reference genome

    * Strain: Neisseria meningitidis MC58
    * Taxid: [122586](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=122586)
    * RefSeq assembly accession:
      [GCF_000008805.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/805/GCF_000008805.1_ASM880v1/GCF_000008805.1_ASM880v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0

```bash
mkdir -p ~/data/anchr/Nmen/1_genome
cd ~/data/anchr/Nmen/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/805/GCF_000008805.1_ASM880v1/GCF_000008805.1_ASM880v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_003112.2{TAB}1
EOF

faops replace GCF_000008805.1_ASM880v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Nmen/Nmen.multi.fas paralogs.fas

```

* Illumina

    * [SRX2179304](https://www.ncbi.nlm.nih.gov/sra/SRX2179304) SRR4272082

```bash
mkdir -p ~/data/anchr/Nmen/2_illumina
cd ~/data/anchr/Nmen/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR427/002/SRR4272082/SRR4272082_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR427/002/SRR4272082/SRR4272082_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
72eda37b3158f5668d6fe8ce62c6db7a SRR4272082_1.fastq.gz
4db52e50a273945315af9aa4582c6dc2 SRR4272082_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s SRR4272082_1.fastq.gz R1.fq.gz
ln -s SRR4272082_2.fastq.gz R2.fq.gz

```

* PacBio

```bash
mkdir -p ~/data/anchr/Nmen/3_pacbio
cd ~/data/anchr/Nmen/3_pacbio

# download from sra
cat <<EOF > hdf5.txt
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR4272081_SRR4272081_hdf5.tgz
EOF
aria2c -x 9 -s 3 -c -i hdf5.txt

# untar
mkdir -p ~/data/anchr/Nmen/3_pacbio/untar
cd ~/data/anchr/Nmen/3_pacbio
tar xvfz SRR4272081_SRR4272081_hdf5.tgz --directory untar

# convert .bax.h5 to .subreads.bam
mkdir -p ~/data/anchr/Nmen/3_pacbio/bam
cd ~/data/anchr/Nmen/3_pacbio/bam

source ~/share/pitchfork/deployment/setup-env.sh
for movie in m150116;
do 
    bax2bam ~/data/anchr/Nmen/3_pacbio/untar/${movie}*.bax.h5
done

# convert .subreads.bam to fasta
mkdir -p ~/data/anchr/Nmen/3_pacbio/fasta

for movie in m150116;
do
    if [ ! -e ~/data/anchr/Nmen/3_pacbio/bam/${movie}*.subreads.bam ]; then
        continue
    fi

    samtools fasta \
        ~/data/anchr/Nmen/3_pacbio/bam/${movie}*.subreads.bam \
        > ~/data/anchr/Nmen/3_pacbio/fasta/${movie}.fasta
done

cd ~/data/anchr/Nmen
cat 3_pacbio/fasta/*.fasta > 3_pacbio/pacbio.fasta

faops n50 3_pacbio/pacbio.fasta

rm -fr ~/data/anchr/Nmen/3_pacbio/untar
```

## Nmen: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 80, 90, and 100

```bash
BASE_DIR=$HOME/data/anchr/Nmen

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
BASE_DIR=$HOME/data/anchr/Nmen
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

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 2272360 |    2272360 |        1 |
| Paralogs |       0 |          0 |        0 |
| Illumina |     101 | 1395253390 | 13814390 |
| PacBio   |    9603 |  402166610 |    58711 |
| uniq     |     101 | 1389594158 | 13758358 |
| scythe   |     101 | 1367023234 | 13758358 |
| Q20L80   |     101 | 1095084793 | 10919678 |
| Q20L90   |     101 | 1043700895 | 10362764 |
| Q20L100  |     101 |  969715031 |  9601274 |
| Q25L80   |     101 |  901889081 |  9007120 |
| Q25L90   |     101 |  843855772 |  8377980 |
| Q25L100  |     101 |  784195025 |  7764412 |
| Q30L80   |     101 |  555276055 |  5581780 |
| Q30L90   |     101 |  490420370 |  4876952 |
| Q30L100  |     101 |  439138961 |  4348086 |

## Nmen: down sampling

```bash
BASE_DIR=$HOME/data/anchr/Nmen
cd ${BASE_DIR}

ARRAY=(
    "2_illumina/Q20L80:Q20L80:4000000"
    "2_illumina/Q20L90:Q20L90:4000000"
    "2_illumina/Q20L100:Q20L100:4000000"
    "2_illumina/Q25L80:Q25L80:4000000"
    "2_illumina/Q25L90:Q25L90:4000000"
    "2_illumina/Q25L100:Q25L100:4000000"
    "2_illumina/Q30L80:Q30L80:2000000"
    "2_illumina/Q30L90:Q30L90:2000000"
    "2_illumina/Q30L100:Q30L100:2000000"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    GROUP_MAX=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[2];')
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    perl -e 'print 1000000 * $_, qq{\n} for 1 .. 4' \
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

```bash
BASE_DIR=$HOME/data/anchr/Nmen
cd ${BASE_DIR}

head -n 25000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.40x.fasta
faops n50 -S -C 3_pacbio/pacbio.40x.fasta

head -n 50000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.80x.fasta
faops n50 -S -C 3_pacbio/pacbio.80x.fasta

```

## Nmen: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/Nmen
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
        for my $i ( 1 .. 4 ) {
            printf qq{%s_%d\n}, $n, ( 1000000 * $i );
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
BASE_DIR=$HOME/data/anchr/Nmen
cd ${BASE_DIR}

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## Nmen: create anchors

```bash
BASE_DIR=$HOME/data/anchr/Nmen
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
        for my $i ( 1 .. 4 ) {
            printf qq{%s_%d\n}, $n, ( 1000000 * $i );
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

## Nmen: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/Nmen
cd ${BASE_DIR}

REAL_G=2272360

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
        for my $i ( 1 .. 4 ) {
            printf qq{%s_%d\n}, $n, ( 1000000 * $i );
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
BASE_DIR=$HOME/data/anchr/Nmen
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
        for my $i ( 1 .. 4 ) {
            printf qq{%s_%d\n}, $n, ( 1000000 * $i );
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

| Name            |   SumFq | CovFq | AvgRead | Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:----------------|--------:|------:|--------:|-----:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| Q20L80_1000000  | 200.57M |  88.3 |     100 |   71 | 178.52M |  10.996% | 2.27M | 2.32M |     1.02 | 2.72M |     0 | 0:01'40'' |
| Q20L80_2000000  | 401.13M | 176.5 |     100 |   71 | 360.65M |  10.091% | 2.27M | 3.09M |     1.36 | 4.06M |     0 | 0:02'55'' |
| Q20L80_3000000  | 601.71M | 264.8 |     100 |   71 | 543.99M |   9.593% | 2.27M | 3.84M |     1.69 | 5.48M |     0 | 0:03'52'' |
| Q20L80_4000000  | 802.28M | 353.1 |     100 |   71 | 727.37M |   9.338% | 2.27M | 4.33M |     1.91 | 6.65M |     0 | 0:04'52'' |
| Q20L90_1000000  | 201.43M |  88.6 |     100 |   71 | 179.83M |  10.725% | 2.27M | 2.33M |     1.02 | 2.72M |     0 | 0:01'43'' |
| Q20L90_2000000  | 402.86M | 177.3 |     100 |   71 | 363.29M |   9.822% | 2.27M | 3.12M |     1.37 | 4.05M |     0 | 0:02'40'' |
| Q20L90_3000000  |  604.3M | 265.9 |     100 |   71 |    548M |   9.317% | 2.27M | 3.87M |     1.70 | 5.46M |     0 | 0:03'53'' |
| Q20L90_4000000  | 805.73M | 354.6 |     100 |   71 | 732.53M |   9.085% | 2.27M | 4.34M |     1.91 | 6.56M |     0 | 0:05'08'' |
| Q20L100_1000000 |    202M |  88.9 |     100 |   71 | 180.97M |  10.409% | 2.27M | 2.35M |     1.03 | 2.73M |     0 | 0:01'33'' |
| Q20L100_2000000 | 403.99M | 177.8 |     100 |   71 | 365.68M |   9.484% | 2.27M | 3.18M |     1.40 | 4.09M |     0 | 0:02'49'' |
| Q20L100_3000000 | 605.99M | 266.7 |     100 |   71 | 551.25M |   9.034% | 2.27M | 3.92M |     1.72 | 5.42M |     0 | 0:04'02'' |
| Q20L100_4000000 | 807.99M | 355.6 |     100 |   71 | 736.73M |   8.819% | 2.27M | 4.34M |     1.91 | 6.42M |     0 | 0:05'17'' |
| Q25L80_1000000  | 200.26M |  88.1 |     100 |   71 | 182.48M |   8.880% | 2.27M | 2.34M |     1.03 | 2.67M |     0 | 0:01'38'' |
| Q25L80_2000000  | 400.52M | 176.3 |     100 |   71 | 368.26M |   8.053% | 2.27M | 3.16M |     1.39 | 3.81M |     0 | 0:02'49'' |
| Q25L80_3000000  | 600.78M | 264.4 |     100 |   71 | 554.85M |   7.645% | 2.27M | 3.87M |     1.70 | 4.92M |     0 | 0:03'42'' |
| Q25L80_4000000  | 801.05M | 352.5 |     100 |   71 | 740.88M |   7.512% | 2.27M | 4.23M |     1.86 | 5.57M |     0 | 0:05'00'' |
| Q25L90_1000000  | 201.45M |  88.7 |     100 |   71 | 183.79M |   8.762% | 2.27M | 2.37M |     1.04 | 2.71M |     0 | 0:01'33'' |
| Q25L90_2000000  | 402.89M | 177.3 |     100 |   71 | 370.95M |   7.928% | 2.27M | 3.23M |     1.42 | 3.89M |     0 | 0:02'39'' |
| Q25L90_3000000  | 604.34M | 266.0 |     100 |   71 | 558.82M |   7.531% | 2.27M | 3.91M |     1.72 | 4.95M |     0 | 0:03'42'' |
| Q25L90_4000000  | 805.78M | 354.6 |     100 |   71 | 746.01M |   7.418% | 2.27M | 4.25M |     1.87 | 5.56M |     0 | 0:05'05'' |
| Q25L100_1000000 |    202M |  88.9 |     100 |   71 | 184.46M |   8.681% | 2.27M | 2.39M |     1.05 | 2.73M |     0 | 0:01'26'' |
| Q25L100_2000000 | 403.99M | 177.8 |     100 |   71 | 372.41M |   7.818% | 2.27M | 3.28M |     1.44 | 3.94M |     0 | 0:02'32'' |
| Q25L100_3000000 | 605.99M | 266.7 |     100 |   71 | 560.78M |   7.460% | 2.27M | 3.96M |     1.74 | 4.99M |     0 | 0:03'52'' |
| Q25L100_4000000 |  784.2M | 345.1 |     100 |   71 | 726.49M |   7.359% | 2.27M | 4.25M |     1.87 | 5.49M |     0 | 0:04'39'' |
| Q30L80_1000000  | 198.96M |  87.6 |      99 |   71 | 184.92M |   7.059% | 2.27M | 2.52M |     1.11 |  2.9M |     0 | 0:01'32'' |
| Q30L80_2000000  | 397.92M | 175.1 |      99 |   71 | 373.47M |   6.144% | 2.27M |  3.5M |     1.54 | 4.19M |     0 | 0:02'41'' |
| Q30L90_1000000  | 201.12M |  88.5 |     100 |   71 | 186.96M |   7.041% | 2.27M | 2.58M |     1.14 | 2.98M |     0 | 0:01'31'' |
| Q30L90_2000000  | 402.24M | 177.0 |     100 |   71 |  377.8M |   6.075% | 2.27M | 3.61M |     1.59 | 4.32M |     0 | 0:02'41'' |
| Q30L100_1000000 | 201.99M |  88.9 |     100 |   71 | 187.89M |   6.982% | 2.27M | 2.64M |     1.16 | 3.05M |     0 | 0:01'31'' |
| Q30L100_2000000 | 403.98M | 177.8 |     100 |   71 | 379.59M |   6.038% | 2.27M | 3.68M |     1.62 | 4.41M |     0 | 0:02'33'' |

| Name            | N50SRclean |   Sum |     # | N50Anchor |     Sum |   # | N50Anchor2 | Sum | # | N50Others |     Sum |     # |   RunTime |
|:----------------|-----------:|------:|------:|----------:|--------:|----:|-----------:|----:|--:|----------:|--------:|------:|----------:|
| Q20L80_1000000  |       3067 | 2.72M |  6623 |      4502 |   1.97M | 558 |          0 |   0 | 0 |       110 | 751.52K |  6065 | 0:02'11'' |
| Q20L80_2000000  |        417 | 4.06M | 19476 |      2128 |   1.58M | 777 |          0 |   0 | 0 |       120 |   2.47M | 18699 | 0:02'30'' |
| Q20L80_3000000  |        163 | 5.48M | 32037 |      1608 |   1.01M | 631 |          0 |   0 | 0 |       133 |   4.48M | 31406 | 0:03'20'' |
| Q20L80_4000000  |        160 | 6.65M | 41390 |      1343 | 520.48K | 381 |          0 |   0 | 0 |       145 |   6.13M | 41009 | 0:03'52'' |
| Q20L90_1000000  |       3333 | 2.72M |  6511 |      4983 |   1.98M | 527 |          0 |   0 | 0 |       111 | 735.96K |  5984 | 0:01'40'' |
| Q20L90_2000000  |        450 | 4.05M | 19124 |      2279 |   1.64M | 791 |          0 |   0 | 0 |       120 |   2.41M | 18333 | 0:02'34'' |
| Q20L90_3000000  |        169 | 5.46M | 31253 |      1557 |   1.04M | 664 |          0 |   0 | 0 |       137 |   4.42M | 30589 | 0:03'25'' |
| Q20L90_4000000  |        169 | 6.56M | 39670 |      1354 | 580.91K | 420 |          0 |   0 | 0 |       150 |   5.98M | 39250 | 0:03'59'' |
| Q20L100_1000000 |       3891 | 2.73M |  6556 |      6121 |   1.99M | 464 |          0 |   0 | 0 |       110 | 741.69K |  6092 | 0:01'49'' |
| Q20L100_2000000 |        450 | 4.09M | 19217 |      2513 |   1.71M | 766 |          0 |   0 | 0 |       119 |   2.38M | 18451 | 0:02'36'' |
| Q20L100_3000000 |        177 | 5.42M | 30090 |      1711 |   1.17M | 702 |          0 |   0 | 0 |       138 |   4.24M | 29388 | 0:03'25'' |
| Q20L100_4000000 |        180 | 6.42M | 37272 |      1388 | 694.59K | 488 |          0 |   0 | 0 |       157 |   5.72M | 36784 | 0:03'58'' |
| Q25L80_1000000  |       5557 | 2.67M |  5876 |      7895 |   2.01M | 370 |          0 |   0 | 0 |       108 | 654.31K |  5506 | 0:01'50'' |
| Q25L80_2000000  |       1584 | 3.81M | 15828 |      6034 |      2M | 457 |          0 |   0 | 0 |       113 |   1.81M | 15371 | 0:02'47'' |
| Q25L80_3000000  |        208 | 4.92M | 24132 |      3129 |   1.81M | 690 |          0 |   0 | 0 |       130 |    3.1M | 23442 | 0:03'24'' |
| Q25L80_4000000  |        226 | 5.57M | 27332 |      2105 |   1.56M | 785 |          0 |   0 | 0 |       154 |      4M | 26547 | 0:04'01'' |
| Q25L90_1000000  |       5568 | 2.71M |  6246 |      7444 |   2.02M | 373 |          0 |   0 | 0 |       108 | 687.74K |  5873 | 0:01'58'' |
| Q25L90_2000000  |       1368 | 3.89M | 16227 |      6402 |      2M | 444 |          0 |   0 | 0 |       115 |   1.88M | 15783 | 0:02'43'' |
| Q25L90_3000000  |        218 | 4.95M | 23789 |      3079 |   1.82M | 681 |          0 |   0 | 0 |       134 |   3.13M | 23108 | 0:03'21'' |
| Q25L90_4000000  |        242 | 5.56M | 26444 |      2176 |   1.58M | 784 |          0 |   0 | 0 |       161 |   3.98M | 25660 | 0:03'45'' |
| Q25L100_1000000 |       5540 | 2.73M |  6452 |      7669 |   2.03M | 380 |          0 |   0 | 0 |       107 | 707.24K |  6072 | 0:01'50'' |
| Q25L100_2000000 |       1226 | 3.94M | 16537 |      6458 |      2M | 427 |          0 |   0 | 0 |       117 |   1.94M | 16110 | 0:02'44'' |
| Q25L100_3000000 |        222 | 4.99M | 23637 |      3346 |   1.85M | 664 |          0 |   0 | 0 |       136 |   3.14M | 22973 | 0:03'25'' |
| Q25L100_4000000 |        253 | 5.49M | 25349 |      2446 |   1.66M | 757 |          0 |   0 | 0 |       163 |   3.83M | 24592 | 0:03'42'' |
| Q30L80_1000000  |       5028 |  2.9M |  7921 |      7790 |   2.01M | 380 |          0 |   0 | 0 |       108 | 881.01K |  7541 | 0:02'00'' |
| Q30L80_2000000  |        410 | 4.19M | 17948 |      8006 |   2.03M | 359 |          0 |   0 | 0 |       120 |   2.16M | 17589 | 0:02'41'' |
| Q30L90_1000000  |       4385 | 2.98M |  8567 |      7084 |   2.02M | 390 |          0 |   0 | 0 |       109 | 956.82K |  8177 | 0:01'58'' |
| Q30L90_2000000  |        293 | 4.32M | 18562 |      8048 |   2.03M | 352 |          0 |   0 | 0 |       125 |   2.29M | 18210 | 0:02'39'' |
| Q30L100_1000000 |       3879 | 3.05M |  9187 |      6983 |   2.01M | 410 |          0 |   0 | 0 |       111 |   1.03M |  8777 | 0:01'58'' |
| Q30L100_2000000 |        278 | 4.41M | 18812 |      7802 |   2.02M | 361 |          0 |   0 | 0 |       128 |   2.38M | 18451 | 0:02'42'' |

## Nmen: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/Nmen
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L80_1000000/anchor/pe.anchor.fa \
    Q20L80_2000000/anchor/pe.anchor.fa \
    Q20L90_1000000/anchor/pe.anchor.fa \
    Q20L90_2000000/anchor/pe.anchor.fa \
    Q20L100_1000000/anchor/pe.anchor.fa \
    Q20L100_2000000/anchor/pe.anchor.fa \
    Q25L80_1000000/anchor/pe.anchor.fa \
    Q25L80_2000000/anchor/pe.anchor.fa \
    Q25L90_1000000/anchor/pe.anchor.fa \
    Q25L90_2000000/anchor/pe.anchor.fa \
    Q25L100_1000000/anchor/pe.anchor.fa \
    Q25L100_2000000/anchor/pe.anchor.fa \
    Q30L80_1000000/anchor/pe.anchor.fa \
    Q30L80_2000000/anchor/pe.anchor.fa \
    Q30L90_1000000/anchor/pe.anchor.fa \
    Q30L90_2000000/anchor/pe.anchor.fa \
    Q30L100_1000000/anchor/pe.anchor.fa \
    Q30L100_2000000/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge anchor2 and others
anchr contained \
    Q20L80_2000000/anchor/pe.anchor2.fa \
    Q20L90_2000000/anchor/pe.anchor2.fa \
    Q20L100_2000000/anchor/pe.anchor2.fa \
    Q25L80_2000000/anchor/pe.anchor2.fa \
    Q25L90_2000000/anchor/pe.anchor2.fa \
    Q25L100_2000000/anchor/pe.anchor2.fa \
    Q30L80_2000000/anchor/pe.anchor2.fa \
    Q30L90_2000000/anchor/pe.anchor2.fa \
    Q30L100_2000000/anchor/pe.anchor2.fa \
    Q20L80_2000000/anchor/pe.others.fa \
    Q20L90_2000000/anchor/pe.others.fa \
    Q20L100_2000000/anchor/pe.others.fa \
    Q25L80_2000000/anchor/pe.others.fa \
    Q25L90_2000000/anchor/pe.others.fa \
    Q25L100_2000000/anchor/pe.others.fa \
    Q30L80_2000000/anchor/pe.others.fa \
    Q30L90_2000000/anchor/pe.others.fa \
    Q30L100_2000000/anchor/pe.others.fa \
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
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "merge,others,paralogs" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/Nmen
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

## Nmen: 3GS

```bash
BASE_DIR=$HOME/data/anchr/Nmen
cd ${BASE_DIR}

canu \
    -p Nmen -d canu-raw-40x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=2.3m \
    -pacbio-raw 3_pacbio/pacbio.40x.fasta

canu \
    -p Nmen -d canu-raw-80x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=2.3m \
    -pacbio-raw 3_pacbio/pacbio.80x.fasta

faops n50 -S -C canu-raw-40x/Nmen.trimmedReads.fasta.gz
faops n50 -S -C canu-raw-80x/Nmen.trimmedReads.fasta.gz

```

## Nmen: expand anchors

* anchorLong

```bash
BASE_DIR=$HOME/data/anchr/Nmen
cd ${BASE_DIR}

anchr cover \
    --parallel 16 \
    -c 2 -m 40 \
    -b 20 --len 1000 --idt 0.9 \
    merge/anchor.merge.fasta \
    canu-raw-40x/Nmen.trimmedReads.fasta.gz \
    -o merge/anchor.cover.fasta

rm -fr anchorLong
anchr overlap2 \
    --parallel 16 \
    merge/anchor.cover.fasta \
    canu-raw-40x/Nmen.trimmedReads.fasta.gz \
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
   | faops filter -l 0 -a 1000 stdin anchorLong/contig.fasta

```

* contigTrim

```bash
BASE_DIR=$HOME/data/anchr/Nmen
cd ${BASE_DIR}

rm -fr contigTrim
anchr overlap2 \
    --parallel 16 \
    anchorLong/contig.fasta \
    canu-raw-40x/Nmen.contigs.fasta \
    -d contigTrim \
    -b 20 --len 1000 --idt 0.98 --all

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

        anchr overlap --len 1000 --idt 0.98 \
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
BASE_DIR=$HOME/data/anchr/Nmen
cd ${BASE_DIR}

rm -fr 9_qa_contig
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/anchor.cover.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-raw-40x/Nmen.contigs.fasta \
    canu-raw-80x/Nmen.contigs.fasta \
    1_genome/paralogs.fas \
    --label "merge,cover,contig,contigTrim,canu-40x,canu-80x,paralogs" \
    -o 9_qa_contig

```

* Stats

```bash
BASE_DIR=$HOME/data/anchr/Nmen
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

| Name         |     N50 |     Sum |   # |
|:-------------|--------:|--------:|----:|
| Genome       | 2272360 | 2272360 |   1 |
| Paralogs     |       0 |       0 |   0 |
| anchor.merge |    8861 | 2054770 | 316 |
| others.merge |    1001 |    8007 |   8 |
| anchor.cover |    6446 | 1594011 | 333 |
| anchorLong   |    6549 | 1592821 | 324 |
| contigTrim   |   12169 | 1655270 | 231 |

# Listeria monocytogenes FDAARGOS_351

Project
[SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Lmon: download

* Reference genome

    * Strain: Listeria monocytogenes EGD-e
    * Taxid: [169963](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=169963)
    * RefSeq assembly accession:
      [GCF_000196035.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/196/035/GCF_000196035.1_ASM19603v1/GCF_000196035.1_ASM19603v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0133

```bash
mkdir -p ~/data/anchr/Lmon/1_genome
cd ~/data/anchr/Lmon/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/196/035/GCF_000196035.1_ASM19603v1/GCF_000196035.1_ASM19603v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_003210.1${TAB}1
EOF

faops replace GCF_000196035.1_ASM19603v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Lmon/Lmon.multi.fas paralogs.fas

```

* Illumina

    * [SRX2717967](https://www.ncbi.nlm.nih.gov/sra/SRX2717967)

```bash
mkdir -p ~/data/anchr/Vpar/2_illumina
cd ~/data/anchr/Vpar/2_illumina

cat << EOF > sra_ftp.txt
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
EOF

md5sum --check sra_md5.txt

ln -s SRR4244665_1.fastq.gz R1.fq.gz
ln -s SRR4244665_2.fastq.gz R2.fq.gz

```

# Clostridioides difficile 630

Project
[SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Cdif: download

* Reference genome

    * Strain: Clostridioides difficile 630
    * Taxid: [272563](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=272563)
    * RefSeq assembly accession:
      [GCF_000009205.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/009/205/GCF_000009205.1_ASM920v1/GCF_000009205.1_ASM920v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0661

```bash
mkdir -p ~/data/anchr/Cdif/1_genome
cd ~/data/anchr/Cdif/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/009/205/GCF_000009205.1_ASM920v1/GCF_000009205.1_ASM920v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_009089.1${TAB}1
NC_008226.1${TAB}pCD630
EOF

faops replace GCF_000009205.1_ASM920v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Cdif/Cdif.multi.fas paralogs.fas

```

SRX2107163

# Campylobacter jejuni subsp. jejuni ATCC 700819

Project
[SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Cjej: download

* Reference genome

    * Strain: Campylobacter jejuni subsp. jejuni NCTC 11168 = ATCC 700819
    * Taxid: [192222](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=192222&lvl=3&lin=f&keep=1&srchmode=1&unlock)
    * RefSeq assembly accession:
      [GCF_000009085.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/009/085/GCF_000009085.1_ASM908v1/GCF_000009085.1_ASM908v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0196

```bash
mkdir -p ~/data/anchr/Cjej/1_genome
cd ~/data/anchr/Cjej/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/009/085/GCF_000009085.1_ASM908v1/GCF_000009085.1_ASM908v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_002163.1${TAB}1
EOF

faops replace GCF_000009085.1_ASM908v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Cjej/Cjej.multi.fas paralogs.fas

```

SRX2107012
