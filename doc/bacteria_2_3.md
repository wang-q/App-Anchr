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
- [Vibrio parahaemolyticus ATCC BAA-239](#vibrio-parahaemolyticus-atcc-baa-239)
    - [Vpar: download](#vpar-download)
    - [Vpar: combinations of different quality values and read lengths](#vpar-combinations-of-different-quality-values-and-read-lengths)
    - [Vpar: down sampling](#vpar-down-sampling)
    - [Vpar: generate super-reads](#vpar-generate-super-reads)
    - [Vpar: create anchors](#vpar-create-anchors)
    - [Vpar: results](#vpar-results)
    - [Vpar: merge anchors](#vpar-merge-anchors)
- [Legionella pneumophila subsp. pneumophila ATCC 33152D-5; Philadelphia-1](#legionella-pneumophila-subsp-pneumophila-atcc-33152d-5-philadelphia-1)
    - [Lpne: download](#lpne-download)
    - [Lpne: combinations of different quality values and read lengths](#lpne-combinations-of-different-quality-values-and-read-lengths)
    - [Lpne: down sampling](#lpne-down-sampling)
    - [Lpne: generate super-reads](#lpne-generate-super-reads)
    - [Lpne: create anchors](#lpne-create-anchors)
    - [Lpne: results](#lpne-results)
    - [Lpne: merge anchors](#lpne-merge-anchors)
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
for movie in m150412 m150415 m150417 m150421;
do 
    bax2bam ~/data/anchr/Sfle/3_pacbio/untar/${movie}*.bax.h5
done

# convert .subreads.bam to fasta
mkdir -p ~/data/anchr/Sfle/3_pacbio/fasta

for movie in m150412 m150415 m150417 m150421;
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

head -n 230000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.40x.fasta
faops n50 -S -C 3_pacbio/pacbio.40x.fasta

head -n 460000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.80x.fasta
faops n50 -S -C 3_pacbio/pacbio.80x.fasta

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
#printf "| %s | %s | %s | %s |\n" \
#    $(echo "PacBio";   faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md
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

cat stat3.md
```

| Name         |     N50 |     Sum |   # |
|:-------------|--------:|--------:|----:|
| Genome       | 4607202 | 4828820 |   2 |
| Paralogs     |    1377 |  543111 | 334 |
| anchor.merge |   28583 | 4133481 | 280 |
| others.merge |    1005 |    1005 |   1 |

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
for movie in m150412 m150415 m150417 m150421;
do 
    bax2bam ~/data/anchr/Vpar/3_pacbio/untar/${movie}*.bax.h5
done

# convert .subreads.bam to fasta
mkdir -p ~/data/anchr/Vpar/3_pacbio/fasta

for movie in m150412 m150415 m150417 m150421;
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

head -n 230000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.40x.fasta
faops n50 -S -C 3_pacbio/pacbio.40x.fasta

head -n 460000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.80x.fasta
faops n50 -S -C 3_pacbio/pacbio.80x.fasta

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
| PacBio   |         |            |          |
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

cat stat3.md
```

| Name         |     N50 |     Sum |  # |
|:-------------|--------:|--------:|---:|
| Genome       | 3288558 | 5165770 |  2 |
| Paralogs     |    3333 |  155714 | 62 |
| anchor.merge |  174988 | 5035552 | 73 |
| others.merge |       0 |       0 |  0 |

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
tar xvfz SRR4244666_SRR4244666_hdf5.tgz --directory untar

# convert .bax.h5 to .subreads.bam
mkdir -p ~/data/anchr/Lpne/3_pacbio/bam
cd ~/data/anchr/Lpne/3_pacbio/bam

source ~/share/pitchfork/deployment/setup-env.sh
for movie in m150412 m150415 m150417 m150421;
do 
    bax2bam ~/data/anchr/Lpne/3_pacbio/untar/${movie}*.bax.h5
done

# convert .subreads.bam to fasta
mkdir -p ~/data/anchr/Lpne/3_pacbio/fasta

for movie in m150412 m150415 m150417 m150421;
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

head -n 230000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.40x.fasta
faops n50 -S -C 3_pacbio/pacbio.40x.fasta

head -n 460000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.80x.fasta
faops n50 -S -C 3_pacbio/pacbio.80x.fasta

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
| PacBio   |         |            |          |
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

cat stat3.md
```

| Name         |     N50 |     Sum |  # |
|:-------------|--------:|--------:|---:|
| Genome       | 3397754 | 3397754 |  1 |
| Paralogs     |    2793 |  100722 | 43 |
| anchor.merge |  197241 | 3389376 | 70 |
| others.merge |    1006 |    3017 |  3 |

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

SRX2179304 SRX2179305
