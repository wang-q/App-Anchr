# Assemble three genomes from GAGE-B data sets by ANCHR

[TOC levels=1-3]: # " "
- [Assemble three genomes from GAGE-B data sets by ANCHR](#assemble-three-genomes-from-gage-b-data-sets-by-anchr)
- [*Rhodobacter sphaeroides* 2.4.1](#rhodobacter-sphaeroides-241)
    - [Rsph: download](#rsph-download)
    - [Rsph: combinations of different quality values and read lengths](#rsph-combinations-of-different-quality-values-and-read-lengths)
    - [Rsph: down sampling](#rsph-down-sampling)
    - [Rsph: generate super-reads](#rsph-generate-super-reads)
    - [Rsph: create anchors](#rsph-create-anchors)
    - [Rsph: results](#rsph-results)
    - [Rsph: merge anchors](#rsph-merge-anchors)
- [*Mycobacterium abscessus* 6G-0125-R](#mycobacterium-abscessus-6g-0125-r)
    - [Mabs: download](#mabs-download)
    - [Mabs: combinations of different quality values and read lengths](#mabs-combinations-of-different-quality-values-and-read-lengths)
    - [Mabs: down sampling](#mabs-down-sampling)
    - [Mabs: generate super-reads](#mabs-generate-super-reads)
    - [Mabs: create anchors](#mabs-create-anchors)
    - [Mabs: results](#mabs-results)
    - [Mabs: merge anchors](#mabs-merge-anchors)
- [*Vibrio cholerae* CP1032(5)](#vibrio-cholerae-cp10325)
    - [Vcho: download](#vcho-download)
    - [Vcho: combinations of different quality values and read lengths](#vcho-combinations-of-different-quality-values-and-read-lengths)
    - [Vcho: down sampling](#vcho-down-sampling)
    - [Vcho: generate super-reads](#vcho-generate-super-reads)
    - [Vcho: create anchors](#vcho-create-anchors)
    - [Vcho: results](#vcho-results)
    - [Vcho: merge anchors](#vcho-merge-anchors)

# *Bacillus cereus* ATCC 10987

## Bcer: download

* Reference genome

    * Taxid: [222523](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=222523)
    * RefSeq assembly accession: [GCF_000008005.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/005/GCF_000008005.1_ASM800v1/GCF_000008005.1_ASM800v1_assembly_report.txt)

```bash
mkdir -p ~/data/anchr/Bcer/1_genome
cd ~/data/anchr/Bcer/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/005/GCF_000008005.1_ASM800v1/GCF_000008005.1_ASM800v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_003909.8${TAB}1
NC_005707.1${TAB}pBc10987
EOF

faops replace GCF_000008005.1_ASM800v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/gage/Results/Bcer/Bcer.multi.fas paralogs.fas

```

* Illumina

    Download from GAGE-B site.

```bash
mkdir -p ~/data/anchr/Bcer/2_illumina
cd ~/data/anchr/Bcer/2_illumina

aria2c -x 9 -s 3 -c http://ccb.jhu.edu/gage_b/datasets/B_cereus_MiSeq.tar.gz

# NOT gzipped tar
tar xvf B_cereus_MiSeq.tar.gz raw/frag_1__cov100x.fastq
tar xvf B_cereus_MiSeq.tar.gz raw/frag_2__cov100x.fastq

cat raw/frag_1__cov100x.fastq \
    | pigz -p 8 -c \
    > R1.fq.gz
cat raw/frag_2__cov100x.fastq \
    | pigz -p 8 -c \
    > R2.fq.gz

rm -fr raw
```

* GAGE-B assemblies

```bash
mkdir -p ~/data/anchr/Bcer/8_competitor
cd ~/data/anchr/Bcer/8_competitor

aria2c -x 9 -s 3 -c http://ccb.jhu.edu/gage_b/genomeAssemblies/B_cereus_MiSeq.tar.gz

tar xvfz B_cereus_MiSeq.tar.gz abyss_ctg.fasta
tar xvfz B_cereus_MiSeq.tar.gz soap_ctg.fasta
tar xvfz B_cereus_MiSeq.tar.gz spades_ctg.fasta
tar xvfz B_cereus_MiSeq.tar.gz velvet_ctg.fasta

```

## Bcer: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 100, 120, and 140

```bash
BASE_DIR=$HOME/data/anchr/Bcer

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
BASE_DIR=$HOME/data/anchr/Bcer
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
| Genome   | 5224283 |   5432652 |       2 |
| Paralogs |    2295 |    223889 |     103 |
| Illumina |     251 | 481020311 | 2080000 |
| PacBio   |         |           |         |
| uniq     |     251 | 480993557 | 2079856 |
| scythe   |     251 | 479499589 | 2079856 |
| Q20L100  |     250 | 393336810 | 1687342 |
| Q20L120  |     250 | 379811124 | 1606842 |
| Q20L140  |     250 | 363979707 | 1518592 |
| Q25L100  |     250 | 360854174 | 1573602 |
| Q25L120  |     250 | 346615375 | 1487780 |
| Q25L140  |     250 | 329430795 | 1391388 |
| Q30L100  |     250 | 310660617 | 1398540 |
| Q30L120  |     250 | 295474164 | 1305320 |
| Q30L140  |     250 | 275600434 | 1192484 |

## Bcer: down sampling

```bash
BASE_DIR=$HOME/data/anchr/Bcer
cd ${BASE_DIR}

# works on bash 3
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

## Bcer: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/Bcer
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
BASE_DIR=$HOME/data/anchr/Bcer

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## Bcer: create anchors

```bash
BASE_DIR=$HOME/data/anchr/Bcer
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

## Bcer: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/Bcer
cd ${BASE_DIR}

REAL_G=5432652

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
BASE_DIR=$HOME/data/anchr/Bcer
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
| Q20L100 | 393.34M |  72.4 |     191 |  127 | 290.45M |  26.158% | 5.43M | 5.35M |     0.98 | 5.48M |     0 | 0:04'00'' |
| Q20L120 | 379.81M |  69.9 |     193 |  127 | 280.58M |  26.127% | 5.43M | 5.34M |     0.98 | 5.47M |     0 | 0:04'04'' |
| Q20L140 | 363.98M |  67.0 |     196 |  127 | 269.09M |  26.070% | 5.43M | 5.34M |     0.98 | 5.46M |     0 | 0:03'43'' |
| Q25L100 | 360.85M |  66.4 |     190 |  127 | 278.57M |  22.802% | 5.43M | 5.34M |     0.98 | 5.43M |     0 | 0:03'59'' |
| Q25L120 | 346.62M |  63.8 |     192 |  127 | 267.17M |  22.921% | 5.43M | 5.34M |     0.98 | 5.43M |     0 | 0:03'33'' |
| Q25L140 | 329.43M |  60.6 |     195 |  127 | 253.34M |  23.097% | 5.43M | 5.34M |     0.98 | 5.43M |     0 | 0:03'25'' |
| Q30L100 | 310.66M |  57.2 |     187 |  127 | 250.44M |  19.386% | 5.43M | 5.34M |     0.98 | 5.42M |     0 | 0:03'26'' |
| Q30L120 | 295.47M |  54.4 |     190 |  127 | 237.38M |  19.660% | 5.43M | 5.33M |     0.98 | 5.43M |     0 | 0:03'06'' |
| Q30L140 |  275.6M |  50.7 |     193 |  127 | 220.27M |  20.077% | 5.43M | 5.33M |     0.98 | 5.43M |     0 | 0:03'11'' |

| Name    | N50SRclean |   Sum |    # | N50Anchor |   Sum |   # | N50Anchor2 | Sum | # | N50Others |     Sum |   # |   RunTime |
|:--------|-----------:|------:|-----:|----------:|------:|----:|-----------:|----:|--:|----------:|--------:|----:|----------:|
| Q20L100 |      16434 | 5.48M | 1099 |     16595 | 5.35M | 509 |          0 |   0 | 0 |       216 | 130.69K | 590 | 0:01'19'' |
| Q20L120 |      15776 | 5.47M | 1058 |     16365 | 5.35M | 518 |          0 |   0 | 0 |       231 | 122.41K | 540 | 0:01'16'' |
| Q20L140 |      14977 | 5.46M |  999 |     15479 | 5.34M | 525 |          0 |   0 | 0 |       253 | 117.38K | 474 | 0:01'12'' |
| Q25L100 |      16668 | 5.43M |  811 |     17410 | 5.34M | 482 |          0 |   0 | 0 |       286 |  88.94K | 329 | 0:01'04'' |
| Q25L120 |      16307 | 5.43M |  816 |     16369 | 5.34M | 496 |          0 |   0 | 0 |       329 |  90.28K | 320 | 0:01'03'' |
| Q25L140 |      15084 | 5.43M |  831 |     15247 | 5.34M | 524 |          0 |   0 | 0 |       383 |  92.35K | 307 | 0:01'04'' |
| Q30L100 |      14933 | 5.42M |  819 |     15028 | 5.34M | 540 |          0 |   0 | 0 |       399 |  85.41K | 279 | 0:01'06'' |
| Q30L120 |      13870 | 5.43M |  866 |     13955 | 5.33M | 576 |          0 |   0 | 0 |       426 |  94.42K | 290 | 0:01'05'' |
| Q30L140 |      12756 | 5.43M |  922 |     12915 | 5.33M | 628 |          0 |   0 | 0 |       446 | 100.55K | 294 | 0:01'02'' |

## Bcer: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/Bcer
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
    8_competitor/abyss_ctg.fasta \
    8_competitor/soap_ctg.fasta \
    8_competitor/spades_ctg.fasta \
    8_competitor/velvet_ctg.fasta \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "abyss,soap,spades,velvet,merge,others,paralogs" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/Bcer
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

* Stats

```bash
BASE_DIR=$HOME/data/anchr/Bcer
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
| Genome       | 5224283 | 5432652 |   2 |
| Paralogs     |    2295 |  223889 | 103 |
| anchor.merge |   19530 | 5360781 | 423 |
| others.merge |    1013 |    4049 |   4 |

# *Rhodobacter sphaeroides* 2.4.1

## Rsph: download

* Reference genome

    * Taxid: [272943](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=272943)
    * RefSeq assembly accession: [GCF_000012905.2](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/745/GCF_000006745.1_ASM674v1/GCF_000006745.1_ASM674v1_assembly_report.txt)

```bash
mkdir -p ~/data/anchr/Rsph/1_genome
cd ~/data/anchr/Rsph/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/012/905/GCF_000012905.2_ASM1290v2/GCF_000012905.2_ASM1290v2_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_007493.2${TAB}1
NC_007494.2${TAB}2
NC_009007.1${TAB}A
NC_007488.2${TAB}B
NC_007489.1${TAB}C
NC_007490.2${TAB}D
NC_009008.1${TAB}E
EOF

faops replace GCF_000012905.2_ASM1290v2_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/gage/Results/Rsph/Rsph.multi.fas paralogs.fas

```

* Illumina

    SRX160386, SRR522246

```bash
mkdir -p ~/data/anchr/Rsph/2_illumina
cd ~/data/anchr/Rsph/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR522/SRR522246
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
d3fb8d78abada2e481dd30f3b5f7293d        SRR522246
EOF

md5sum --check sra_md5.txt

fastq-dump --split-files ./SRR522246  
find . -name "*.fastq" | parallel -j 2 pigz -p 8

ln -s SRR522246_1.fastq.gz R1.fq.gz
ln -s SRR522246_2.fastq.gz R2.fq.gz
```

* GAGE-B assemblies

```bash
mkdir -p ~/data/anchr/Rsph/8_competitor
cd ~/data/anchr/Rsph/8_competitor

aria2c -x 9 -s 3 -c http://ccb.jhu.edu/gage_b/genomeAssemblies/R_sphaeroides_MiSeq.tar.gz

tar xvfz R_sphaeroides_MiSeq.tar.gz abyss_ctg.fasta
tar xvfz R_sphaeroides_MiSeq.tar.gz soap_ctg.fasta
tar xvfz R_sphaeroides_MiSeq.tar.gz spades_ctg.fasta
tar xvfz R_sphaeroides_MiSeq.tar.gz velvet_ctg.fasta

```

## Rsph: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 100, 120, and 140

```bash
BASE_DIR=$HOME/data/anchr/Rsph

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
BASE_DIR=$HOME/data/anchr/Rsph
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

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 3188524 |    4602977 |        7 |
| Paralogs |    2337 |     147155 |       66 |
| Illumina |     251 | 4237215336 | 16881336 |
| PacBio   |         |            |          |
| uniq     |     251 | 4199507606 | 16731106 |
| scythe   |     251 | 3261298332 | 16731106 |
| Q20L100  |     149 | 1287602433 |  8847984 |
| Q20L120  |     154 |  909473257 |  5940550 |
| Q20L140  |     162 |  426006455 |  2603868 |
| Q25L100  |     139 |  952173268 |  6942908 |
| Q25L120  |     146 |  544771400 |  3729154 |
| Q25L140  |     156 |  165137858 |  1042218 |
| Q30L100  |     126 |  458552566 |  3649914 |
| Q30L120  |     135 |  140859954 |  1027960 |
| Q30L140  |     149 |   15145623 |    99638 |

## Rsph: down sampling

```bash
BASE_DIR=$HOME/data/anchr/Rsph
cd ${BASE_DIR}

# works on bash 3
ARRAY=(
    "2_illumina/Q20L100:Q20L100:2500000"
    "2_illumina/Q20L120:Q20L120:2500000"
    "2_illumina/Q20L140:Q20L140:1000000"
    "2_illumina/Q25L100:Q25L100:2500000"
    "2_illumina/Q25L120:Q25L120:1500000"
    "2_illumina/Q25L140:Q25L140:500000"
    "2_illumina/Q30L100:Q30L100:1500000"
    "2_illumina/Q30L120:Q30L120:500000"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    GROUP_MAX=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[2];')
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    for count in $(perl -e 'print 500000 * $_, q{ } for 1 .. 5');
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

## Rsph: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/Rsph
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
        for my $i ( 1 .. 5 ) {
            printf qq{%s_%d\n}, $n, ( 500000 * $i );
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
BASE_DIR=$HOME/data/anchr/Rsph
cd ${BASE_DIR}

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## Rsph: create anchors

```bash
BASE_DIR=$HOME/data/anchr/Rsph
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
        for my $i ( 1 .. 5 ) {
            printf qq{%s_%d\n}, $n, ( 500000 * $i );
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

## Rsph: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/Rsph
cd ${BASE_DIR}

REAL_G=4602977

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
        for my $i ( 1 .. 5 ) {
            printf qq{%s_%d\n}, $n, ( 500000 * $i );
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
BASE_DIR=$HOME/data/anchr/Rsph
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
        for my $i ( 1 .. 5 ) {
            printf qq{%s_%d\n}, $n, ( 500000 * $i );
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
| Q20L100_500000  | 145.54M |  31.6 |     146 |   41 | 129.22M |  11.215% |  4.6M | 4.52M |     0.98 | 4.62M |     0 | 0:01'55'' |
| Q20L100_1000000 | 291.07M |  63.2 |     146 |   41 | 258.39M |  11.226% |  4.6M | 4.54M |     0.99 | 4.64M |     0 | 0:03'03'' |
| Q20L100_1500000 | 436.59M |  94.9 |     146 |   41 | 387.75M |  11.188% |  4.6M | 4.56M |     0.99 | 4.69M |     0 | 0:04'16'' |
| Q20L100_2000000 |  582.1M | 126.5 |     146 |   41 | 517.21M |  11.147% |  4.6M | 4.58M |     0.99 | 4.77M |     0 | 0:05'38'' |
| Q20L100_2500000 | 727.64M | 158.1 |     146 |   41 | 647.04M |  11.076% |  4.6M |  4.6M |     1.00 | 4.88M |     0 | 0:06'34'' |
| Q20L120_500000  |  153.1M |  33.3 |     154 |   45 | 135.26M |  11.656% |  4.6M | 4.45M |     0.97 | 4.57M |     0 | 0:02'00'' |
| Q20L120_1000000 | 306.18M |  66.5 |     153 |   45 | 270.75M |  11.572% |  4.6M | 4.52M |     0.98 | 4.63M |     0 | 0:03'15'' |
| Q20L120_1500000 | 459.26M |  99.8 |     153 |   45 | 406.32M |  11.527% |  4.6M | 4.54M |     0.99 | 4.69M |     0 | 0:04'20'' |
| Q20L120_2000000 |  612.4M | 133.0 |     153 |   45 | 542.05M |  11.488% |  4.6M | 4.57M |     0.99 | 4.78M |     0 | 0:05'45'' |
| Q20L120_2500000 | 765.48M | 166.3 |     153 |   45 | 678.05M |  11.422% |  4.6M | 4.59M |     1.00 | 4.88M |     0 | 0:06'56'' |
| Q20L140_500000  | 163.62M |  35.5 |     163 |   49 | 142.82M |  12.711% |  4.6M | 4.24M |     0.92 | 4.39M |     0 | 0:01'52'' |
| Q20L140_1000000 | 327.23M |  71.1 |     163 |   49 |  285.8M |  12.660% |  4.6M |  4.4M |     0.96 | 4.55M |     0 | 0:03'27'' |
| Q25L100_500000  | 137.18M |  29.8 |     138 |   39 | 130.78M |   4.666% |  4.6M | 4.47M |     0.97 | 4.58M |     0 | 0:01'52'' |
| Q25L100_1000000 | 274.28M |  59.6 |     138 |   39 | 261.49M |   4.663% |  4.6M | 4.52M |     0.98 | 4.62M |     0 | 0:03'01'' |
| Q25L100_1500000 | 411.47M |  89.4 |     138 |   39 | 392.37M |   4.641% |  4.6M | 4.54M |     0.99 | 4.63M |     0 | 0:04'07'' |
| Q25L100_2000000 | 548.54M | 119.2 |     138 |   39 | 523.03M |   4.651% |  4.6M | 4.54M |     0.99 | 4.64M |     0 | 0:05'14'' |
| Q25L100_2500000 | 685.71M | 149.0 |     138 |   39 |  653.9M |   4.639% |  4.6M | 4.55M |     0.99 | 4.65M |     0 | 0:06'22'' |
| Q25L120_500000  | 146.07M |  31.7 |     146 |   43 | 138.87M |   4.933% |  4.6M | 4.35M |     0.95 | 4.48M |     0 | 0:01'53'' |
| Q25L120_1000000 | 292.17M |  63.5 |     146 |   43 | 277.77M |   4.932% |  4.6M | 4.46M |     0.97 | 4.56M |     0 | 0:03'08'' |
| Q25L120_1500000 | 438.29M |  95.2 |     146 |   43 | 416.77M |   4.908% |  4.6M | 4.49M |     0.98 | 4.59M |     0 | 0:04'12'' |
| Q25L140_500000  | 158.45M |  34.4 |     158 |   49 | 149.45M |   5.676% |  4.6M | 3.93M |     0.85 | 4.09M |     0 | 0:01'58'' |
| Q30L100_500000  | 125.62M |  27.3 |     126 |   37 | 122.48M |   2.496% |  4.6M | 4.35M |     0.95 |  4.5M |     0 | 0:01'48'' |
| Q30L100_1000000 | 251.27M |  54.6 |     126 |   37 | 245.15M |   2.439% |  4.6M | 4.47M |     0.97 | 4.58M |     0 | 0:02'41'' |
| Q30L100_1500000 |  376.9M |  81.9 |     126 |   37 | 367.79M |   2.419% |  4.6M |  4.5M |     0.98 |  4.6M |     0 | 0:03'38'' |
| Q30L120_500000  | 137.03M |  29.8 |     137 |   41 | 133.16M |   2.824% |  4.6M | 4.04M |     0.88 | 4.22M |     0 | 0:01'44'' |

| Name            | N50SRclean |   Sum |    # | N50Anchor |   Sum |    # | N50Anchor2 |    Sum |  # | N50Others |     Sum |    # |   RunTime |
|:----------------|-----------:|------:|-----:|----------:|------:|-----:|-----------:|-------:|---:|----------:|--------:|-----:|----------:|
| Q20L100_500000  |       7803 | 4.62M | 2488 |      8185 | 4.34M |  754 |          0 |      0 |  0 |       260 | 272.44K | 1734 | 0:01'37'' |
| Q20L100_1000000 |      11622 | 4.64M | 2394 |     12370 | 4.41M |  570 |          0 |      0 |  0 |       179 | 237.32K | 1824 | 0:02'14'' |
| Q20L100_1500000 |       9906 | 4.69M | 3116 |     10458 | 4.36M |  637 |          0 |      0 |  0 |       185 | 327.72K | 2479 | 0:02'40'' |
| Q20L100_2000000 |       7407 | 4.77M | 4464 |      8226 | 4.29M |  802 |          0 |      0 |  0 |       178 | 475.55K | 3662 | 0:03'02'' |
| Q20L100_2500000 |       4731 | 4.88M | 6442 |      5526 | 4.15M | 1042 |          0 |      0 |  0 |       198 |  723.6K | 5400 | 0:03'26'' |
| Q20L120_500000  |       5245 | 4.57M | 2835 |      5702 | 4.13M |  978 |       1406 |  9.51K |  7 |       403 |  431.7K | 1850 | 0:01'28'' |
| Q20L120_1000000 |       7195 | 4.63M | 2479 |      7561 | 4.33M |  786 |       1138 |  3.41K |  3 |       272 | 291.54K | 1690 | 0:02'05'' |
| Q20L120_1500000 |       7659 | 4.69M | 3172 |      8390 | 4.31M |  781 |       1248 |  2.46K |  2 |       245 | 370.83K | 2389 | 0:02'40'' |
| Q20L120_2000000 |       5757 | 4.78M | 4558 |      6532 | 4.23M |  908 |       1061 |  1.06K |  1 |       247 | 551.29K | 3649 | 0:02'56'' |
| Q20L120_2500000 |       4244 | 4.88M | 6233 |      5130 | 4.12M | 1081 |          0 |      0 |  0 |       238 |  765.8K | 5152 | 0:03'41'' |
| Q20L140_500000  |       2743 | 4.39M | 3888 |      3454 | 3.55M | 1250 |       1307 | 37.17K | 28 |       525 | 800.09K | 2610 | 0:01'20'' |
| Q20L140_1000000 |       3938 | 4.55M | 3425 |      4741 | 3.95M | 1122 |       1286 | 16.01K | 12 |       461 | 578.48K | 2291 | 0:02'03'' |
| Q25L100_500000  |       5903 | 4.58M | 2848 |      6405 | 4.22M |  927 |       1461 |  4.53K |  3 |       324 | 358.25K | 1918 | 0:01'34'' |
| Q25L100_1000000 |       8843 | 4.62M | 2394 |      9238 | 4.37M |  691 |       1383 |  2.59K |  2 |       224 | 239.55K | 1701 | 0:01'57'' |
| Q25L100_1500000 |      10355 | 4.63M | 2317 |     10828 | 4.41M |  609 |          0 |      0 |  0 |       184 | 221.66K | 1708 | 0:02'38'' |
| Q25L100_2000000 |      10964 | 4.64M | 2372 |     11465 | 4.42M |  582 |          0 |      0 |  0 |       158 | 218.42K | 1790 | 0:03'18'' |
| Q25L100_2500000 |      10374 | 4.65M | 2587 |     11127 |  4.4M |  598 |          0 |      0 |  0 |       169 | 250.16K | 1989 | 0:03'33'' |
| Q25L120_500000  |       3620 | 4.48M | 3413 |      4227 | 3.85M | 1141 |       1272 | 21.51K | 17 |       493 | 611.84K | 2255 | 0:01'36'' |
| Q25L120_1000000 |       5561 | 4.56M | 2685 |      5968 | 4.18M |  937 |       2010 |  3.29K |  2 |       392 | 384.41K | 1746 | 0:02'02'' |
| Q25L120_1500000 |       6767 | 4.59M | 2468 |      7214 | 4.29M |  845 |       1578 |  2.91K |  2 |       318 | 303.19K | 1621 | 0:02'35'' |
| Q25L140_500000  |       1793 | 4.09M | 4560 |      2663 | 2.84M | 1191 |       1416 | 65.37K | 48 |       561 |   1.18M | 3321 | 0:01'31'' |
| Q30L100_500000  |       3202 |  4.5M | 4081 |      3819 | 3.79M | 1232 |       1180 |  8.43K |  7 |       473 | 700.86K | 2842 | 0:01'30'' |
| Q30L100_1000000 |       5248 | 4.58M | 3196 |      5756 | 4.16M |  993 |       1099 |  3.72K |  3 |       359 | 415.98K | 2200 | 0:02'03'' |
| Q30L100_1500000 |       6617 |  4.6M | 2862 |      7037 | 4.29M |  881 |       1261 |  1.26K |  1 |       297 | 318.45K | 1980 | 0:02'28'' |
| Q30L120_500000  |       1923 | 4.22M | 4999 |      2644 | 3.05M | 1276 |       1292 | 27.63K | 21 |       527 |   1.14M | 3702 | 0:01'29'' |

## Rsph: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/Rsph
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L100_1000000/anchor/pe.anchor.fa \
    Q20L100_1500000/anchor/pe.anchor.fa \
    Q20L120_1000000/anchor/pe.anchor.fa \
    Q20L120_1500000/anchor/pe.anchor.fa \
    Q20L140_1000000/anchor/pe.anchor.fa \
    Q25L100_1000000/anchor/pe.anchor.fa \
    Q25L100_1500000/anchor/pe.anchor.fa \
    Q25L100_2000000/anchor/pe.anchor.fa \
    Q25L120_1000000/anchor/pe.anchor.fa \
    Q25L120_1500000/anchor/pe.anchor.fa \
    Q30L100_1000000/anchor/pe.anchor.fa \
    Q30L100_1500000/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge anchor2 and others
anchr contained \
    Q20L100_1000000/anchor/pe.anchor2.fa \
    Q20L120_1000000/anchor/pe.anchor2.fa \
    Q20L140_1000000/anchor/pe.anchor2.fa \
    Q25L100_1000000/anchor/pe.anchor2.fa \
    Q25L120_1000000/anchor/pe.anchor2.fa \
    Q30L100_1000000/anchor/pe.anchor2.fa \
    Q20L100_1000000/anchor/pe.others.fa \
    Q20L120_1000000/anchor/pe.others.fa \
    Q20L140_1000000/anchor/pe.others.fa \
    Q25L100_1000000/anchor/pe.others.fa \
    Q25L120_1000000/anchor/pe.others.fa \
    Q30L100_1000000/anchor/pe.others.fa \
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
    8_competitor/abyss_ctg.fasta \
    8_competitor/soap_ctg.fasta \
    8_competitor/spades_ctg.fasta \
    8_competitor/velvet_ctg.fasta \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "abyss,soap,spades,velvet,merge,others,paralogs" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/Rsph
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

* Stats

```bash
BASE_DIR=$HOME/data/anchr/Rsph
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
| Genome       | 3188524 | 4602977 |   7 |
| Paralogs     |    2337 |  147155 |  66 |
| anchor.merge |   24773 | 4488524 | 317 |
| others.merge |    1065 |   58564 |  51 |

# *Mycobacterium abscessus* 6G-0125-R

## Mabs: download

* Reference genome

    * *Mycobacterium abscessus* ATCC 19977
        * Taxid: [561007](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=243277)
        * RefSeq assembly accession: [GCF_000069185.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/745/GCF_000006745.1_ASM674v1/GCF_000006745.1_ASM674v1_assembly_report.txt)
    * *Mycobacterium abscessus* 6G-0125-R
        * RefSeq assembly accession: GCF_000270985.1

```bash
mkdir -p ~/data/anchr/Mabs/1_genome
cd ~/data/anchr/Mabs/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/069/185/GCF_000069185.1_ASM6918v1/GCF_000069185.1_ASM6918v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_010397.1${TAB}1
NC_010394.1${TAB}unnamed
EOF

faops replace GCF_000069185.1_ASM6918v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/gage/Results/Mabs/Mabs.multi.fas paralogs.fas

```

* Illumina

    SRX246890, SRR768269

```bash
mkdir -p ~/data/anchr/Mabs/2_illumina
cd ~/data/anchr/Mabs/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR768/SRR768269
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
afcf09a85f0797ab893b05200b575b9d        SRR768269
EOF

md5sum --check sra_md5.txt

fastq-dump --split-files ./SRR768269  
find . -name "*.fastq" | parallel -j 2 pigz -p 8

ln -s SRR768269_1.fastq.gz R1.fq.gz
ln -s SRR768269_2.fastq.gz R2.fq.gz
```

* GAGE-B assemblies

```bash
mkdir -p ~/data/anchr/Mabs/8_competitor
cd ~/data/anchr/Mabs/8_competitor

aria2c -x 9 -s 3 -c http://ccb.jhu.edu/gage_b/genomeAssemblies/M_abscessus_MiSeq.tar.gz

tar xvfz M_abscessus_MiSeq.tar.gz abyss_ctg.fasta
tar xvfz M_abscessus_MiSeq.tar.gz soap_ctg.fasta
tar xvfz M_abscessus_MiSeq.tar.gz spades_ctg.fasta
tar xvfz M_abscessus_MiSeq.tar.gz velvet_ctg.fasta

```

## Mabs: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 100, 120, and 140

```bash
BASE_DIR=$HOME/data/anchr/Mabs

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
BASE_DIR=$HOME/data/anchr/Mabs
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

| Name     |     N50 |        Sum |       # |
|:---------|--------:|-----------:|--------:|
| Genome   | 5067172 |    5090491 |       2 |
| Paralogs |    1580 |      83364 |      53 |
| Illumina |     251 | 2194026140 | 8741140 |
| PacBio   |         |            |         |
| uniq     |     251 | 2191831898 | 8732398 |
| scythe   |     194 | 1580945973 | 8732398 |
| Q20L100  |     182 | 1116526651 | 6381972 |
| Q20L120  |     184 | 1022588693 | 5688032 |
| Q20L140  |     188 |  880254750 | 4716680 |
| Q25L100  |     177 |  926043102 | 5426906 |
| Q25L120  |     180 |  824293152 | 4678024 |
| Q25L140  |     184 |  680187695 | 3704988 |
| Q30L100  |     170 |  663451172 | 4046430 |
| Q30L120  |     174 |  556341951 | 3257720 |
| Q30L140  |     179 |  421267610 | 2353262 |

## Mabs: down sampling

```bash
BASE_DIR=$HOME/data/anchr/Mabs
cd ${BASE_DIR}

# works on bash 3
ARRAY=(
    "2_illumina/Q20L100:Q20L100:2500000"
    "2_illumina/Q20L120:Q20L120:2500000"
    "2_illumina/Q20L140:Q20L140:2000000"
    "2_illumina/Q25L100:Q25L100:2500000"
    "2_illumina/Q25L120:Q25L120:2000000"
    "2_illumina/Q25L140:Q25L140:1500000"
    "2_illumina/Q30L100:Q30L100:2000000"
    "2_illumina/Q30L120:Q30L120:1500000"
    "2_illumina/Q30L140:Q30L140:1000000"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    GROUP_MAX=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[2];')
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    for count in $(perl -e 'print 500000 * $_, q{ } for 1 .. 5');
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

## Mabs: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/Mabs
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
        for my $i ( 1 .. 5 ) {
            printf qq{%s_%d\n}, $n, ( 500000 * $i );
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
BASE_DIR=$HOME/data/anchr/Mabs

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## Mabs: create anchors

```bash
BASE_DIR=$HOME/data/anchr/Mabs
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
        for my $i ( 1 .. 5 ) {
            printf qq{%s_%d\n}, $n, ( 500000 * $i );
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

## Mabs: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/Mabs
cd ${BASE_DIR}

REAL_G=5090491

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
        for my $i ( 1 .. 5 ) {
            printf qq{%s_%d\n}, $n, ( 500000 * $i );
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
BASE_DIR=$HOME/data/anchr/Mabs
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
        for my $i ( 1 .. 5 ) {
            printf qq{%s_%d\n}, $n, ( 500000 * $i );
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
| Q20L100_500000  |    175M |  34.4 |     171 |   49 | 137.79M |  21.263% | 5.09M | 5.16M |     1.01 | 5.27M |     0 | 0:01'37'' |
| Q20L100_1000000 | 349.93M |  68.7 |     173 |   49 | 276.11M |  21.095% | 5.09M | 5.26M |     1.03 | 5.53M |     0 | 0:02'36'' |
| Q20L100_1500000 |  524.9M | 103.1 |     176 |   49 | 413.39M |  21.245% | 5.09M | 5.29M |     1.04 | 5.49M |     0 | 0:03'47'' |
| Q20L100_2000000 | 699.76M | 137.5 |     178 |   49 | 551.69M |  21.161% | 5.09M | 5.36M |     1.05 | 5.71M |     0 | 0:04'41'' |
| Q20L100_2500000 | 874.69M | 171.8 |     181 |   49 | 690.36M |  21.074% | 5.09M | 5.42M |     1.06 | 5.96M |     0 | 0:05'34'' |
| Q20L120_500000  | 179.72M |  35.3 |     175 |   51 | 142.08M |  20.944% | 5.09M | 5.15M |     1.01 | 5.28M |     0 | 0:01'43'' |
| Q20L120_1000000 | 359.53M |  70.6 |     178 |   51 | 284.56M |  20.853% | 5.09M | 5.26M |     1.03 | 5.57M |     0 | 0:02'43'' |
| Q20L120_1500000 | 539.33M | 105.9 |     180 |   51 | 426.26M |  20.964% | 5.09M |  5.3M |     1.04 | 5.53M |     0 | 0:03'43'' |
| Q20L120_2000000 | 719.07M | 141.3 |     183 |   51 |  568.6M |  20.925% | 5.09M | 5.36M |     1.05 | 5.76M |     0 | 0:04'44'' |
| Q20L120_2500000 |  898.9M | 176.6 |     185 |   51 | 711.77M |  20.818% | 5.09M | 5.43M |     1.07 | 6.03M |     0 | 0:05'49'' |
| Q20L140_500000  | 186.61M |  36.7 |     181 |   53 | 147.45M |  20.984% | 5.09M | 5.14M |     1.01 | 5.29M |     0 | 0:01'46'' |
| Q20L140_1000000 | 373.27M |  73.3 |     183 |   53 | 295.46M |  20.845% | 5.09M | 5.27M |     1.04 | 5.64M |     0 | 0:02'45'' |
| Q20L140_1500000 | 559.86M | 110.0 |     185 |   53 |  442.3M |  20.999% | 5.09M |  5.3M |     1.04 | 5.56M |     0 | 0:03'47'' |
| Q20L140_2000000 | 746.47M | 146.6 |     187 |   53 | 590.26M |  20.926% | 5.09M | 5.37M |     1.06 | 5.82M |     0 | 0:04'44'' |
| Q25L100_500000  | 170.63M |  33.5 |     168 |   47 | 142.11M |  16.716% | 5.09M | 5.16M |     1.01 | 5.26M |     0 | 0:01'35'' |
| Q25L100_1000000 | 341.27M |  67.0 |     172 |   47 | 284.06M |  16.763% | 5.09M | 5.23M |     1.03 | 5.33M |     0 | 0:02'40'' |
| Q25L100_1500000 | 511.95M | 100.6 |     175 |   47 | 426.45M |  16.701% | 5.09M | 5.29M |     1.04 | 5.46M |     0 | 0:03'46'' |
| Q25L100_2000000 | 682.51M | 134.1 |     179 |   47 | 569.07M |  16.620% | 5.09M | 5.35M |     1.05 | 5.62M |     0 | 0:04'35'' |
| Q25L100_2500000 | 853.23M | 167.6 |     181 |   47 | 711.89M |  16.566% | 5.09M |  5.4M |     1.06 | 5.81M |     0 | 0:05'40'' |
| Q25L120_500000  | 176.23M |  34.6 |     173 |   49 | 146.84M |  16.673% | 5.09M | 5.14M |     1.01 | 5.27M |     0 | 0:01'27'' |
| Q25L120_1000000 | 352.37M |  69.2 |     176 |   51 | 293.42M |  16.728% | 5.09M | 5.23M |     1.03 | 5.35M |     0 | 0:02'30'' |
| Q25L120_1500000 | 528.59M | 103.8 |     180 |   49 | 440.46M |  16.673% | 5.09M | 5.29M |     1.04 | 5.48M |     0 | 0:03'39'' |
| Q25L120_2000000 | 704.78M | 138.5 |     183 |   49 | 587.96M |  16.576% | 5.09M | 5.36M |     1.05 | 5.67M |     0 | 0:04'50'' |
| Q25L140_500000  | 183.58M |  36.1 |     180 |   53 | 152.62M |  16.868% | 5.09M | 5.11M |     1.00 | 5.28M |     0 | 0:01'38'' |
| Q25L140_1000000 | 367.16M |  72.1 |     183 |   53 |    305M |  16.928% | 5.09M | 5.23M |     1.03 | 5.37M |     0 | 0:02'47'' |
| Q25L140_1500000 | 550.76M | 108.2 |     186 |   53 | 458.08M |  16.829% | 5.09M |  5.3M |     1.04 | 5.54M |     0 | 0:04'02'' |
| Q30L100_500000  | 163.96M |  32.2 |     165 |   45 |  141.7M |  13.575% | 5.09M | 5.15M |     1.01 | 5.26M |     0 | 0:01'33'' |
| Q30L100_1000000 | 327.86M |  64.4 |     169 |   45 | 283.35M |  13.577% | 5.09M | 5.24M |     1.03 | 5.34M |     0 | 0:02'33'' |
| Q30L100_1500000 | 491.88M |  96.6 |     174 |   45 |  425.3M |  13.536% | 5.09M | 5.29M |     1.04 | 5.45M |     0 | 0:03'29'' |
| Q30L100_2000000 | 655.84M | 128.8 |     179 |   45 | 567.56M |  13.461% | 5.09M | 5.34M |     1.05 |  5.6M |     0 | 0:04'30'' |
| Q30L120_500000  | 170.78M |  33.5 |     171 |   49 | 147.39M |  13.693% | 5.09M | 5.12M |     1.01 | 5.26M |     0 | 0:01'44'' |
| Q30L120_1000000 | 341.56M |  67.1 |     176 |   49 |  294.6M |  13.748% | 5.09M | 5.23M |     1.03 | 5.36M |     0 | 0:02'42'' |
| Q30L120_1500000 | 512.33M | 100.6 |     181 |   49 | 442.45M |  13.640% | 5.09M |  5.3M |     1.04 |  5.5M |     0 | 0:03'32'' |
| Q30L140_500000  | 178.99M |  35.2 |     179 |   51 | 153.95M |  13.989% | 5.09M | 5.06M |     0.99 | 5.25M |     0 | 0:01'34'' |
| Q30L140_1000000 | 358.04M |  70.3 |     184 |   53 | 307.56M |  14.099% | 5.09M | 5.21M |     1.02 | 5.39M |     0 | 0:02'34'' |

| Name            | N50SRclean |   Sum |     # | N50Anchor |   Sum |    # | N50Anchor2 |    Sum |  # | N50Others |     Sum |    # |   RunTime |
|:----------------|-----------:|------:|------:|----------:|------:|-----:|-----------:|-------:|---:|----------:|--------:|-----:|----------:|
| Q20L100_500000  |       7108 | 5.27M |  2316 |      7427 | 4.99M |  929 |       1558 | 18.81K | 12 |       277 | 260.87K | 1375 | 0:01'41'' |
| Q20L100_1000000 |       3432 | 5.53M |  5512 |      3971 | 4.74M | 1480 |       1262 | 13.06K | 10 |       375 | 784.17K | 4022 | 0:02'03'' |
| Q20L100_1500000 |       4974 | 5.49M |  4342 |      5405 | 4.96M | 1187 |       1527 |  5.57K |  4 |       201 | 522.85K | 3151 | 0:02'37'' |
| Q20L100_2000000 |       2723 | 5.71M |  7432 |      3308 | 4.63M | 1661 |       1690 |  2.84K |  2 |       294 |   1.07M | 5769 | 0:02'52'' |
| Q20L100_2500000 |       1690 | 5.96M | 11171 |      2397 |  4.1M | 1887 |       1690 |  4.59K |  3 |       390 |   1.86M | 9281 | 0:03'39'' |
| Q20L120_500000  |       5429 | 5.28M |  2781 |      5870 |  4.9M | 1121 |       1598 | 21.18K | 14 |       400 | 363.14K | 1646 | 0:01'37'' |
| Q20L120_1000000 |       2952 | 5.57M |  6084 |      3577 | 4.64M | 1583 |       1487 | 23.45K | 16 |       397 | 915.56K | 4485 | 0:02'01'' |
| Q20L120_1500000 |       4389 | 5.53M |  4824 |      4800 |  4.9M | 1305 |       1409 |   5.6K |  4 |       216 | 620.93K | 3515 | 0:02'20'' |
| Q20L120_2000000 |       2534 | 5.76M |  7864 |      3108 | 4.56M | 1721 |       1739 |  13.9K |  8 |       317 |   1.18M | 6135 | 0:02'58'' |
| Q20L120_2500000 |       1550 | 6.03M | 11825 |      2265 | 3.99M | 1933 |       1240 |  3.54K |  3 |       399 |   2.04M | 9889 | 0:03'27'' |
| Q20L140_500000  |       3844 | 5.29M |  3400 |      4298 | 4.72M | 1385 |       1555 | 36.63K | 24 |       527 | 528.05K | 1991 | 0:01'36'' |
| Q20L140_1000000 |       2349 | 5.64M |  7028 |      2923 | 4.43M | 1738 |       1448 | 50.62K | 34 |       427 |   1.16M | 5256 | 0:01'57'' |
| Q20L140_1500000 |       3896 | 5.56M |  5162 |      4489 | 4.81M | 1380 |       1495 | 17.02K | 10 |       251 | 732.39K | 3772 | 0:02'20'' |
| Q20L140_2000000 |       2139 | 5.82M |  8642 |      2745 |  4.4M | 1820 |       1263 |  19.2K | 15 |       359 |    1.4M | 6807 | 0:02'57'' |
| Q25L100_500000  |       6745 | 5.26M |  2334 |      7175 | 4.97M |  945 |       1415 | 11.39K |  8 |       339 | 279.02K | 1381 | 0:01'26'' |
| Q25L100_1000000 |      10084 | 5.33M |  2381 |     10556 | 5.05M |  698 |       1852 |  2.99K |  2 |       194 | 276.31K | 1681 | 0:01'55'' |
| Q25L100_1500000 |       5769 | 5.46M |  3917 |      6353 | 4.99M | 1101 |          0 |      0 |  0 |       203 | 471.55K | 2816 | 0:02'44'' |
| Q25L100_2000000 |       3315 | 5.62M |  6107 |      3958 | 4.77M | 1511 |          0 |      0 |  0 |       260 |  847.1K | 4596 | 0:03'02'' |
| Q25L100_2500000 |       2078 | 5.81M |  8993 |      2777 | 4.35M | 1804 |          0 |      0 |  0 |       402 |   1.45M | 7189 | 0:03'23'' |
| Q25L120_500000  |       4859 | 5.27M |  2885 |      5187 | 4.84M | 1208 |       1622 | 15.85K | 10 |       483 | 409.91K | 1667 | 0:01'35'' |
| Q25L120_1000000 |       7794 | 5.35M |  2623 |      8189 | 5.04M |  869 |       1258 |  1.26K |  1 |       200 | 303.04K | 1753 | 0:02'02'' |
| Q25L120_1500000 |       4933 | 5.48M |  4212 |      5438 | 4.93M | 1186 |       1336 |     4K |  3 |       220 | 545.49K | 3023 | 0:02'31'' |
| Q25L120_2000000 |       2947 | 5.67M |  6675 |      3529 | 4.67M | 1601 |       1399 |  12.1K |  9 |       302 | 985.69K | 5065 | 0:03'09'' |
| Q25L140_500000  |       3244 | 5.28M |  3794 |      3694 | 4.58M | 1489 |       1474 | 51.93K | 36 |       544 | 643.84K | 2269 | 0:01'34'' |
| Q25L140_1000000 |       5322 | 5.37M |  3263 |      5779 | 4.92M | 1124 |       1201 | 11.53K |  9 |       257 | 440.82K | 2130 | 0:01'57'' |
| Q25L140_1500000 |       3646 | 5.54M |  5056 |      4126 | 4.81M | 1438 |       1375 | 15.22K | 11 |       254 | 717.35K | 3607 | 0:02'28'' |
| Q30L100_500000  |       5713 | 5.26M |  2687 |      6084 | 4.91M | 1105 |       1590 | 18.79K | 12 |       410 | 332.85K | 1570 | 0:01'31'' |
| Q30L100_1000000 |       8331 | 5.34M |  2588 |      8779 | 5.03M |  792 |       1246 |  5.18K |  4 |       198 | 302.95K | 1792 | 0:02'02'' |
| Q30L100_1500000 |       5748 | 5.45M |  3884 |      6482 | 4.96M | 1058 |       1221 |  3.75K |  3 |       211 | 492.09K | 2823 | 0:02'31'' |
| Q30L100_2000000 |       3298 |  5.6M |  6016 |      3851 | 4.76M | 1511 |       1186 |  3.47K |  3 |       265 | 838.73K | 4502 | 0:03'04'' |
| Q30L120_500000  |       3797 | 5.26M |  3391 |      4248 | 4.69M | 1380 |       1318 | 30.06K | 21 |       522 | 534.78K | 1990 | 0:01'31'' |
| Q30L120_1000000 |       5778 | 5.36M |  3075 |      6194 | 4.97M | 1059 |       1625 | 12.89K |  8 |       216 | 380.77K | 2008 | 0:02'09'' |
| Q30L120_1500000 |       4236 |  5.5M |  4632 |      4678 | 4.88M | 1309 |       1225 | 12.03K |  9 |       229 | 616.76K | 3314 | 0:02'28'' |
| Q30L140_500000  |       2534 | 5.25M |  4555 |      3025 | 4.28M | 1659 |       1435 |    76K | 51 |       573 | 896.56K | 2845 | 0:01'34'' |
| Q30L140_1000000 |       3884 | 5.39M |  4033 |      4344 | 4.73M | 1367 |       1587 | 43.42K | 27 |       374 |  620.2K | 2639 | 0:02'05'' |

## Mabs: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/Mabs
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L100_1000000/anchor/pe.anchor.fa \
    Q20L100_1500000/anchor/pe.anchor.fa \
    Q20L120_1000000/anchor/pe.anchor.fa \
    Q20L120_1500000/anchor/pe.anchor.fa \
    Q20L140_1000000/anchor/pe.anchor.fa \
    Q20L140_1500000/anchor/pe.anchor.fa \
    Q25L100_1000000/anchor/pe.anchor.fa \
    Q25L100_1500000/anchor/pe.anchor.fa \
    Q25L120_1000000/anchor/pe.anchor.fa \
    Q25L120_1500000/anchor/pe.anchor.fa \
    Q25L140_1000000/anchor/pe.anchor.fa \
    Q25L140_1500000/anchor/pe.anchor.fa \
    Q30L100_1000000/anchor/pe.anchor.fa \
    Q30L100_1500000/anchor/pe.anchor.fa \
    Q30L120_1000000/anchor/pe.anchor.fa \
    Q30L120_1500000/anchor/pe.anchor.fa \
    Q30L140_1000000/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge anchor2 and others
anchr contained \
    Q20L100_1000000/anchor/pe.anchor2.fa \
    Q20L120_1000000/anchor/pe.anchor2.fa \
    Q20L140_1000000/anchor/pe.anchor2.fa \
    Q25L100_1000000/anchor/pe.anchor2.fa \
    Q25L120_1000000/anchor/pe.anchor2.fa \
    Q25L140_1000000/anchor/pe.anchor2.fa \
    Q30L100_1000000/anchor/pe.anchor2.fa \
    Q30L120_1000000/anchor/pe.anchor2.fa \
    Q30L140_1000000/anchor/pe.anchor2.fa \
    Q20L100_1000000/anchor/pe.others.fa \
    Q20L120_1000000/anchor/pe.others.fa \
    Q20L140_1000000/anchor/pe.others.fa \
    Q25L100_1000000/anchor/pe.others.fa \
    Q25L120_1000000/anchor/pe.others.fa \
    Q25L140_1000000/anchor/pe.others.fa \
    Q30L100_1000000/anchor/pe.others.fa \
    Q30L120_1000000/anchor/pe.others.fa \
    Q30L140_1000000/anchor/pe.others.fa \
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
    8_competitor/abyss_ctg.fasta \
    8_competitor/soap_ctg.fasta \
    8_competitor/spades_ctg.fasta \
    8_competitor/velvet_ctg.fasta \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "abyss,soap,spades,velvet,merge,others,paralogs" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/Mabs
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

* Stats

```bash
BASE_DIR=$HOME/data/anchr/Mabs
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
| Genome       | 5067172 | 5090491 |   2 |
| Paralogs     |    1580 |   83364 |  53 |
| anchor.merge |   62704 | 5156175 | 146 |
| others.merge |    1225 |  238771 | 185 |

# *Vibrio cholerae* CP1032(5)

## Vcho: download

* Reference genome

    * *Vibrio cholerae* O1 biovar El Tor str. N16961
        * Taxid: [243277](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=243277)
        * RefSeq assembly accession: [GCF_000006745.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/745/GCF_000006745.1_ASM674v1/GCF_000006745.1_ASM674v1_assembly_report.txt)
    * *Vibrio cholerae* CP1032(5)
        * RefSeq assembly accession: GCF_000279305.1

```bash
mkdir -p ~/data/anchr/Vcho/1_genome
cd ~/data/anchr/Vcho/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/745/GCF_000006745.1_ASM674v1/GCF_000006745.1_ASM674v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_002505.1${TAB}I
NC_002506.1${TAB}II
EOF

faops replace GCF_000006745.1_ASM674v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/gage/Results/Vcho/Vcho.multi.fas paralogs.fas

```

* Illumina

    SRX247310, SRR769320

```bash
mkdir -p ~/data/anchr/Vcho/2_illumina
cd ~/data/anchr/Vcho/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/srr/SRR769/SRR769320
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
28f49ca6ae9a00c3a7937e00e04e8512        SRR769320
EOF

md5sum --check sra_md5.txt

fastq-dump --split-files ./SRR769320  
find . -name "*.fastq" | parallel -j 2 pigz -p 8

ln -s SRR769320_1.fastq.gz R1.fq.gz
ln -s SRR769320_2.fastq.gz R2.fq.gz
```

* GAGE-B assemblies

```bash
mkdir -p ~/data/anchr/Vcho/8_competitor
cd ~/data/anchr/Vcho/8_competitor

aria2c -x 9 -s 3 -c http://ccb.jhu.edu/gage_b/genomeAssemblies/V_cholerae_MiSeq.tar.gz

tar xvfz V_cholerae_MiSeq.tar.gz abyss_ctg.fasta
tar xvfz V_cholerae_MiSeq.tar.gz soap_ctg.fasta
tar xvfz V_cholerae_MiSeq.tar.gz spades_ctg.fasta
tar xvfz V_cholerae_MiSeq.tar.gz velvet_ctg.fasta

```

## Vcho: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 100, 120, and 140

```bash
BASE_DIR=$HOME/data/anchr/Vcho

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
BASE_DIR=$HOME/data/anchr/Vcho
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

| Name     |     N50 |        Sum |       # |
|:---------|--------:|-----------:|--------:|
| Genome   | 2961149 |    4033464 |       2 |
| Paralogs |    3483 |     114707 |      48 |
| Illumina |     251 | 1762158050 | 7020550 |
| PacBio   |         |            |         |
| uniq     |     251 | 1727781592 | 6883592 |
| scythe   |     198 | 1314316931 | 6883592 |
| Q20L100  |     192 | 1161679827 | 6241070 |
| Q20L120  |     193 | 1122792745 | 5957734 |
| Q20L140  |     195 | 1044398184 | 5417172 |
| Q25L100  |     189 | 1056640471 | 5774338 |
| Q25L120  |     190 | 1010327668 | 5437194 |
| Q25L140  |     193 |  922963312 | 4842010 |
| Q30L100  |     184 |  889848287 | 5009608 |
| Q30L120  |     185 |  832476939 | 4590842 |
| Q30L140  |     188 |  732712135 | 3919768 |

## Vcho: down sampling

```bash
BASE_DIR=$HOME/data/anchr/Vcho
cd ${BASE_DIR}

# works on bash 3
ARRAY=(
    "2_illumina/Q20L100:Q20L100:2500000"
    "2_illumina/Q20L120:Q20L120:2500000"
    "2_illumina/Q20L140:Q20L140:2500000"
    "2_illumina/Q25L100:Q25L100:2500000"
    "2_illumina/Q25L120:Q25L120:2500000"
    "2_illumina/Q25L140:Q25L140:2000000"
    "2_illumina/Q30L100:Q30L100:2500000"
    "2_illumina/Q30L120:Q30L120:2000000"
    "2_illumina/Q30L140:Q30L140:2000000"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    GROUP_MAX=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[2];')
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    for count in $(perl -e 'print 500000 * $_, q{ } for 1 .. 5');
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

## Vcho: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/Vcho
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
        for my $i ( 1 .. 5 ) {
            printf qq{%s_%d\n}, $n, ( 500000 * $i );
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
BASE_DIR=$HOME/data/anchr/Vcho
cd ${BASE_DIR}

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## Vcho: create anchors

```bash
BASE_DIR=$HOME/data/anchr/Vcho
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
        for my $i ( 1 .. 5 ) {
            printf qq{%s_%d\n}, $n, ( 500000 * $i );
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

## Vcho: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/Vcho
cd ${BASE_DIR}

REAL_G=4033464

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
        for my $i ( 1 .. 5 ) {
            printf qq{%s_%d\n}, $n, ( 500000 * $i );
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
BASE_DIR=$HOME/data/anchr/Vcho
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
        for my $i ( 1 .. 5 ) {
            printf qq{%s_%d\n}, $n, ( 500000 * $i );
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
| Q20L100_500000  | 186.17M |  46.2 |     180 |  115 | 150.15M |  19.350% | 4.03M | 3.94M |     0.98 | 4.19M |     0 | 0:01'35'' |
| Q20L100_1000000 | 372.26M |  92.3 |     184 |  121 | 300.12M |  19.379% | 4.03M | 3.96M |     0.98 | 4.25M |     0 | 0:02'35'' |
| Q20L100_1500000 | 558.48M | 138.5 |     187 |  127 |    451M |  19.245% | 4.03M |    4M |     0.99 |  4.5M |     0 | 0:03'48'' |
| Q20L100_2000000 | 744.61M | 184.6 |     191 |  127 | 601.74M |  19.186% | 4.03M | 4.06M |     1.01 | 4.83M |     0 | 0:06'06'' |
| Q20L100_2500000 |  930.6M | 230.7 |     194 |  127 | 755.51M |  18.815% | 4.03M | 4.22M |     1.05 | 6.07M |     0 | 0:08'11'' |
| Q20L120_500000  | 188.42M |  46.7 |     182 |  117 | 152.72M |  18.949% | 4.03M | 3.94M |     0.98 | 4.21M |     0 | 0:02'19'' |
| Q20L120_1000000 | 376.91M |  93.4 |     186 |  121 | 305.19M |  19.028% | 4.03M | 3.96M |     0.98 | 4.27M |     0 | 0:04'04'' |
| Q20L120_1500000 | 565.39M | 140.2 |     189 |  127 |  458.5M |  18.906% | 4.03M |    4M |     0.99 | 4.51M |     0 | 0:06'05'' |
| Q20L120_2000000 | 753.91M | 186.9 |     192 |  127 | 611.92M |  18.834% | 4.03M | 4.06M |     1.01 | 4.85M |     0 | 0:06'15'' |
| Q20L120_2500000 | 942.29M | 233.6 |     195 |  127 | 768.49M |  18.444% | 4.03M | 4.23M |     1.05 | 6.15M |     0 | 0:07'11'' |
| Q20L140_500000  |  192.8M |  47.8 |     186 |  121 | 156.73M |  18.707% | 4.03M | 3.94M |     0.98 | 4.22M |     0 | 0:01'39'' |
| Q20L140_1000000 | 385.57M |  95.6 |     189 |  127 | 313.42M |  18.712% | 4.03M | 3.96M |     0.98 | 4.31M |     0 | 0:02'52'' |
| Q20L140_1500000 | 578.39M | 143.4 |     192 |  127 | 470.65M |  18.628% | 4.03M | 4.01M |     0.99 | 4.55M |     0 | 0:04'18'' |
| Q20L140_2000000 | 771.22M | 191.2 |     195 |  127 |  628.2M |  18.546% | 4.03M | 4.07M |     1.01 | 4.91M |     0 | 0:05'33'' |
| Q20L140_2500000 | 963.99M | 239.0 |     197 |  127 | 786.08M |  18.456% | 4.03M | 4.16M |     1.03 | 5.35M |     0 | 0:06'35'' |
| Q25L100_500000  | 183.03M |  45.4 |     179 |  115 | 154.17M |  15.765% | 4.03M | 3.93M |     0.98 | 4.18M |     0 | 0:01'30'' |
| Q25L100_1000000 | 365.97M |  90.7 |     183 |  119 | 308.21M |  15.784% | 4.03M | 3.96M |     0.98 | 4.22M |     0 | 0:02'27'' |
| Q25L100_1500000 | 548.96M | 136.1 |     187 |  127 | 462.86M |  15.685% | 4.03M | 3.99M |     0.99 | 4.43M |     0 | 0:03'37'' |
| Q25L100_2000000 | 731.93M | 181.5 |     191 |  127 | 617.34M |  15.655% | 4.03M | 4.04M |     1.00 | 4.67M |     0 | 0:05'27'' |
| Q25L100_2500000 | 914.95M | 226.8 |     195 |  127 | 772.42M |  15.577% | 4.03M |  4.1M |     1.02 | 5.02M |     0 | 0:06'19'' |
| Q25L120_500000  | 185.83M |  46.1 |     181 |  117 | 156.99M |  15.517% | 4.03M | 3.94M |     0.98 |  4.2M |     0 | 0:01'47'' |
| Q25L120_1000000 | 371.71M |  92.2 |     186 |  121 | 313.66M |  15.619% | 4.03M | 3.95M |     0.98 | 4.25M |     0 | 0:02'22'' |
| Q25L120_1500000 | 557.49M | 138.2 |     189 |  127 | 470.87M |  15.538% | 4.03M |    4M |     0.99 | 4.46M |     0 | 0:03'31'' |
| Q25L120_2000000 |  743.2M | 184.3 |     193 |  127 | 628.16M |  15.478% | 4.03M | 4.05M |     1.00 | 4.76M |     0 | 0:05'14'' |
| Q25L120_2500000 | 929.13M | 230.4 |     197 |  127 | 785.97M |  15.408% | 4.03M | 4.11M |     1.02 | 5.11M |     0 | 0:06'30'' |
| Q25L140_500000  | 190.62M |  47.3 |     185 |  121 | 160.89M |  15.594% | 4.03M | 3.93M |     0.97 | 4.23M |     0 | 0:01'28'' |
| Q25L140_1000000 | 381.24M |  94.5 |     188 |  127 | 321.81M |  15.589% | 4.03M | 3.96M |     0.98 | 4.31M |     0 | 0:02'44'' |
| Q25L140_1500000 | 571.84M | 141.8 |     192 |  127 | 483.15M |  15.510% | 4.03M |    4M |     0.99 | 4.54M |     0 | 0:03'52'' |
| Q25L140_2000000 | 762.51M | 189.0 |     196 |  127 |  644.8M |  15.437% | 4.03M | 4.06M |     1.01 | 4.83M |     0 | 0:05'11'' |
| Q30L100_500000  | 177.61M |  44.0 |     176 |  111 | 155.06M |  12.697% | 4.03M | 3.93M |     0.98 | 4.17M |     0 | 0:01'48'' |
| Q30L100_1000000 | 355.22M |  88.1 |     182 |  119 | 310.03M |  12.723% | 4.03M | 3.95M |     0.98 | 4.22M |     0 | 0:02'36'' |
| Q30L100_1500000 | 532.82M | 132.1 |     188 |  127 | 465.39M |  12.656% | 4.03M | 3.98M |     0.99 |  4.4M |     0 | 0:03'20'' |
| Q30L100_2000000 | 710.44M | 176.1 |     193 |  127 | 620.95M |  12.597% | 4.03M | 4.01M |     1.00 | 4.62M |     0 | 0:04'05'' |
| Q30L100_2500000 | 888.14M | 220.2 |     198 |  127 | 776.85M |  12.530% | 4.03M | 4.07M |     1.01 | 4.91M |     0 | 0:06'02'' |
| Q30L120_500000  | 181.36M |  45.0 |     180 |  115 | 158.22M |  12.756% | 4.03M | 3.94M |     0.98 |  4.2M |     0 | 0:01'42'' |
| Q30L120_1000000 | 362.64M |  89.9 |     185 |  121 | 316.36M |  12.763% | 4.03M | 3.95M |     0.98 | 4.27M |     0 | 0:02'25'' |
| Q30L120_1500000 | 544.08M | 134.9 |     190 |  127 | 474.96M |  12.704% | 4.03M | 3.98M |     0.99 | 4.46M |     0 | 0:03'38'' |
| Q30L120_2000000 | 725.33M | 179.8 |     195 |  127 | 633.67M |  12.638% | 4.03M | 4.02M |     1.00 | 4.71M |     0 | 0:05'08'' |
| Q30L140_500000  | 186.92M |  46.3 |     184 |  119 |  162.6M |  13.016% | 4.03M | 3.93M |     0.97 | 4.17M |     0 | 0:01'29'' |
| Q30L140_1000000 | 373.84M |  92.7 |     189 |  127 | 325.38M |  12.964% | 4.03M | 3.95M |     0.98 | 4.32M |     0 | 0:03'14'' |
| Q30L140_1500000 | 560.78M | 139.0 |     194 |  127 | 488.39M |  12.908% | 4.03M | 3.99M |     0.99 | 4.55M |     0 | 0:03'46'' |
| Q30L140_2000000 | 732.71M | 181.7 |     198 |  127 |  638.6M |  12.844% | 4.03M | 4.03M |     1.00 |  4.8M |     0 | 0:04'15'' |

| Name            | N50SRclean |   Sum |     # | N50Anchor |   Sum |    # | N50Anchor2 |    Sum |  # | N50Others |     Sum |     # |   RunTime |
|:----------------|-----------:|------:|------:|----------:|------:|-----:|-----------:|-------:|---:|----------:|--------:|------:|----------:|
| Q20L100_500000  |       5129 | 4.19M |  2363 |      5777 | 3.74M |  876 |       1510 |  2.57K |  2 |       476 | 449.41K |  1485 | 0:01'27'' |
| Q20L100_1000000 |       7296 | 4.25M |  2377 |      8208 | 3.87M |  708 |          0 |      0 |  0 |       220 |  381.4K |  1669 | 0:01'49'' |
| Q20L100_1500000 |       4781 |  4.5M |  3919 |      5588 | 3.83M |  927 |          0 |      0 |  0 |       200 | 670.38K |  2992 | 0:02'19'' |
| Q20L100_2000000 |       2915 | 4.83M |  6202 |      3704 | 3.72M | 1203 |          0 |      0 |  0 |       200 |   1.12M |  4999 | 0:02'11'' |
| Q20L100_2500000 |        971 | 6.07M | 14572 |      2000 | 2.96M | 1558 |          0 |      0 |  0 |       220 |   3.11M | 13014 | 0:02'40'' |
| Q20L120_500000  |       4263 | 4.21M |  2629 |      4849 | 3.69M | 1004 |       1554 | 10.22K |  7 |       480 | 510.94K |  1618 | 0:01'12'' |
| Q20L120_1000000 |       6126 | 4.27M |  2554 |      6814 | 3.85M |  801 |       1135 |  1.14K |  1 |       241 | 415.15K |  1752 | 0:01'08'' |
| Q20L120_1500000 |       4068 | 4.51M |  4037 |      4759 | 3.83M | 1024 |          0 |      0 |  0 |       200 | 673.44K |  3013 | 0:01'39'' |
| Q20L120_2000000 |       2772 | 4.85M |  6343 |      3618 | 3.68M | 1243 |          0 |      0 |  0 |       200 |   1.17M |  5100 | 0:02'17'' |
| Q20L120_2500000 |        902 | 6.15M | 15174 |      1956 | 2.88M | 1568 |          0 |      0 |  0 |       227 |   3.28M | 13606 | 0:03'28'' |
| Q20L140_500000  |       3699 | 4.22M |  2833 |      4281 | 3.63M | 1057 |       1213 |   4.7K |  4 |       499 | 590.76K |  1772 | 0:01'16'' |
| Q20L140_1000000 |       4882 | 4.31M |  2873 |      5623 | 3.79M |  949 |       1150 |  4.57K |  4 |       302 | 508.72K |  1920 | 0:01'32'' |
| Q20L140_1500000 |       3595 | 4.55M |  4409 |      4273 | 3.76M | 1114 |       1207 |  1.21K |  1 |       228 | 789.48K |  3294 | 0:01'31'' |
| Q20L140_2000000 |       2319 | 4.91M |  6791 |      3224 | 3.61M | 1349 |          0 |      0 |  0 |       218 |    1.3M |  5442 | 0:02'36'' |
| Q20L140_2500000 |       1563 | 5.35M |  9752 |      2568 | 3.37M | 1479 |          0 |      0 |  0 |       221 |   1.98M |  8273 | 0:03'00'' |
| Q25L100_500000  |       4631 | 4.18M |  2408 |      5143 | 3.73M |  957 |       1071 |  1.07K |  1 |       438 | 448.51K |  1450 | 0:01'48'' |
| Q25L100_1000000 |       7626 | 4.22M |  2146 |      8269 | 3.88M |  681 |       1287 |  2.51K |  2 |       237 | 336.44K |  1463 | 0:01'51'' |
| Q25L100_1500000 |       5062 | 4.43M |  3478 |      5960 | 3.84M |  898 |          0 |      0 |  0 |       201 | 586.72K |  2580 | 0:02'17'' |
| Q25L100_2000000 |       3580 | 4.67M |  5052 |      4497 | 3.78M | 1094 |          0 |      0 |  0 |       197 | 883.68K |  3958 | 0:03'04'' |
| Q25L100_2500000 |       2346 | 5.02M |  7442 |      3294 | 3.65M | 1344 |          0 |      0 |  0 |       198 |   1.37M |  6098 | 0:03'27'' |
| Q25L120_500000  |       3889 |  4.2M |  2710 |      4507 | 3.67M | 1067 |       1185 |  4.76K |  4 |       508 | 535.18K |  1639 | 0:01'19'' |
| Q25L120_1000000 |       5373 | 4.25M |  2528 |      5949 | 3.85M |  878 |          0 |      0 |  0 |       261 | 407.95K |  1650 | 0:01'42'' |
| Q25L120_1500000 |       4062 | 4.46M |  3780 |      4663 | 3.82M | 1040 |       1275 |  1.28K |  1 |       217 | 643.25K |  2739 | 0:02'30'' |
| Q25L120_2000000 |       2810 | 4.76M |  5777 |      3694 |  3.7M | 1236 |          0 |      0 |  0 |       206 |   1.06M |  4541 | 0:02'54'' |
| Q25L120_2500000 |       1990 | 5.11M |  8132 |      2965 | 3.54M | 1412 |          0 |      0 |  0 |       207 |   1.57M |  6720 | 0:03'27'' |
| Q25L140_500000  |       3134 | 4.23M |  3041 |      3723 | 3.58M | 1172 |       1222 | 11.11K |  9 |       532 | 636.36K |  1860 | 0:01'29'' |
| Q25L140_1000000 |       3984 | 4.31M |  2967 |      4570 | 3.77M | 1059 |       1130 |  3.51K |  3 |       395 | 533.49K |  1905 | 0:01'59'' |
| Q25L140_1500000 |       3230 | 4.54M |  4408 |      4080 | 3.73M | 1189 |          0 |      0 |  0 |       254 | 811.78K |  3219 | 0:02'33'' |
| Q25L140_2000000 |       2326 | 4.83M |  6348 |      3190 | 3.62M | 1356 |          0 |      0 |  0 |       231 |   1.21M |  4992 | 0:03'14'' |
| Q30L100_500000  |       4308 | 4.17M |  2418 |      4929 | 3.72M |  979 |       1098 |  3.38K |  3 |       479 | 448.43K |  1436 | 0:01'25'' |
| Q30L100_1000000 |       6451 | 4.22M |  2279 |      7039 | 3.85M |  784 |       1157 |  1.16K |  1 |       272 | 368.64K |  1494 | 0:01'58'' |
| Q30L100_1500000 |       4991 |  4.4M |  3306 |      5678 | 3.86M |  947 |          0 |      0 |  0 |       211 | 541.67K |  2359 | 0:02'40'' |
| Q30L100_2000000 |       3378 | 4.62M |  4811 |      4217 | 3.78M | 1127 |          0 |      0 |  0 |       202 | 844.61K |  3684 | 0:03'08'' |
| Q30L100_2500000 |       2475 | 4.91M |  6782 |      3269 | 3.67M | 1336 |          0 |      0 |  0 |       200 |   1.24M |  5446 | 0:03'30'' |
| Q30L120_500000  |       3387 |  4.2M |  2820 |      3933 |  3.6M | 1134 |       1206 |  3.58K |  3 |       567 | 596.58K |  1683 | 0:01'25'' |
| Q30L120_1000000 |       4569 | 4.27M |  2711 |      5067 | 3.81M |  983 |          0 |      0 |  0 |       345 | 457.06K |  1728 | 0:02'00'' |
| Q30L120_1500000 |       3633 | 4.46M |  3850 |      4163 | 3.79M | 1133 |          0 |      0 |  0 |       253 | 671.86K |  2717 | 0:02'24'' |
| Q30L120_2000000 |       2735 | 4.71M |  5527 |      3430 | 3.72M | 1306 |          0 |      0 |  0 |       217 | 990.37K |  4221 | 0:03'08'' |
| Q30L140_500000  |       3013 | 4.17M |  2832 |      3543 | 3.54M | 1213 |       1275 | 12.46K | 10 |       594 | 619.71K |  1609 | 0:01'27'' |
| Q30L140_1000000 |       3285 | 4.32M |  3271 |      3859 |  3.7M | 1200 |          0 |      0 |  0 |       441 |  617.8K |  2071 | 0:01'47'' |
| Q30L140_1500000 |       2767 | 4.55M |  4606 |      3390 | 3.69M | 1308 |       1089 |  1.09K |  1 |       299 | 854.12K |  3297 | 0:02'20'' |
| Q30L140_2000000 |       2216 |  4.8M |  6273 |      2929 | 3.58M | 1412 |       1089 |  1.09K |  1 |       262 |   1.22M |  4860 | 0:03'04'' |

## Vcho: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/Vcho
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L100_1000000/anchor/pe.anchor.fa \
    Q20L100_1500000/anchor/pe.anchor.fa \
    Q20L120_1000000/anchor/pe.anchor.fa \
    Q20L120_1500000/anchor/pe.anchor.fa \
    Q20L140_1000000/anchor/pe.anchor.fa \
    Q20L140_1500000/anchor/pe.anchor.fa \
    Q25L100_1000000/anchor/pe.anchor.fa \
    Q25L100_1500000/anchor/pe.anchor.fa \
    Q25L120_1000000/anchor/pe.anchor.fa \
    Q25L120_1500000/anchor/pe.anchor.fa \
    Q25L140_1000000/anchor/pe.anchor.fa \
    Q25L140_1500000/anchor/pe.anchor.fa \
    Q30L100_1000000/anchor/pe.anchor.fa \
    Q30L100_1500000/anchor/pe.anchor.fa \
    Q30L120_1000000/anchor/pe.anchor.fa \
    Q30L120_1500000/anchor/pe.anchor.fa \
    Q30L140_1000000/anchor/pe.anchor.fa \
    Q30L140_1500000/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge anchor2 and others
anchr contained \
    Q20L100_1000000/anchor/pe.anchor2.fa \
    Q20L120_1000000/anchor/pe.anchor2.fa \
    Q20L140_1000000/anchor/pe.anchor2.fa \
    Q25L100_1000000/anchor/pe.anchor2.fa \
    Q25L120_1000000/anchor/pe.anchor2.fa \
    Q25L140_1000000/anchor/pe.anchor2.fa \
    Q30L100_1000000/anchor/pe.anchor2.fa \
    Q30L120_1000000/anchor/pe.anchor2.fa \
    Q30L140_1000000/anchor/pe.anchor2.fa \
    Q20L100_1000000/anchor/pe.others.fa \
    Q20L120_1000000/anchor/pe.others.fa \
    Q20L140_1000000/anchor/pe.others.fa \
    Q25L100_1000000/anchor/pe.others.fa \
    Q25L120_1000000/anchor/pe.others.fa \
    Q25L140_1000000/anchor/pe.others.fa \
    Q30L100_1000000/anchor/pe.others.fa \
    Q30L120_1000000/anchor/pe.others.fa \
    Q30L140_1000000/anchor/pe.others.fa \
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
    8_competitor/abyss_ctg.fasta \
    8_competitor/soap_ctg.fasta \
    8_competitor/spades_ctg.fasta \
    8_competitor/velvet_ctg.fasta \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "abyss,soap,spades,velvet,merge,others,paralogs" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/Vcho
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

* Stats

```bash
BASE_DIR=$HOME/data/anchr/Vcho
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
| Genome       | 2961149 | 4033464 |   2 |
| Paralogs     |    3483 |  114707 |  48 |
| anchor.merge |   75961 | 3943387 | 135 |
| others.merge |    1021 |   43353 |  41 |
