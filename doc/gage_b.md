# Assemble three genomes from GAGE-B data sets by ANCHR

[TOC levels=1-3]: # " "
- [Assemble three genomes from GAGE-B data sets by ANCHR](#assemble-three-genomes-from-gage-b-data-sets-by-anchr)
- [*Bacillus cereus* ATCC 10987](#bacillus-cereus-atcc-10987)
    - [Bcer: download](#bcer-download)
    - [Bcer: combinations of different quality values and read lengths](#bcer-combinations-of-different-quality-values-and-read-lengths)
    - [Bcer: down sampling](#bcer-down-sampling)
    - [Bcer: generate super-reads](#bcer-generate-super-reads)
    - [Bcer: create anchors](#bcer-create-anchors)
    - [Bcer: results](#bcer-results)
    - [Bcer: merge anchors](#bcer-merge-anchors)
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
    * RefSeq assembly accession:
      [GCF_000008005.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/005/GCF_000008005.1_ASM800v1/GCF_000008005.1_ASM800v1_assembly_report.txt)

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

cd ${BASE_DIR}
if [ ! -e 2_illumina/R1.scythe.fq.gz ]; then
    parallel --no-run-if-empty -j 2 "
        scythe \
            2_illumina/{}.uniq.fq.gz \
            -q sanger \
            -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
            --quiet \
            | pigz -p 4 -c \
            > 2_illumina/{}.scythe.fq.gz
        " ::: R1 R2
fi

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
            --kmer 49,69,89 \
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

| Name    |   SumFq | CovFq | AvgRead |       Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:--------|--------:|------:|--------:|-----------:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| Q20L100 | 393.34M |  72.4 |     230 | "49,69,89" | 334.79M |  14.884% | 5.43M | 5.35M |     0.98 | 5.37M |     0 | 0:05'59'' |
| Q20L120 | 379.81M |  69.9 |     233 | "49,69,89" | 323.97M |  14.702% | 5.43M | 5.35M |     0.98 | 5.36M |     0 | 0:05'36'' |
| Q20L140 | 363.98M |  67.0 |     237 | "49,69,89" | 311.42M |  14.441% | 5.43M | 5.34M |     0.98 | 5.36M |     0 | 0:05'33'' |
| Q25L100 | 360.85M |  66.4 |     225 | "49,69,89" | 324.86M |   9.974% | 5.43M | 5.34M |     0.98 | 5.37M |     0 | 0:05'24'' |
| Q25L120 | 346.62M |  63.8 |     229 | "49,69,89" | 312.31M |   9.897% | 5.43M | 5.34M |     0.98 | 5.38M |     0 | 0:05'23'' |
| Q25L140 | 329.43M |  60.6 |     234 | "49,69,89" | 297.14M |   9.803% | 5.43M | 5.34M |     0.98 | 5.36M |     0 | 0:05'03'' |
| Q30L100 | 310.66M |  57.2 |     218 | "49,69,89" | 291.08M |   6.302% | 5.43M | 5.34M |     0.98 | 5.37M |     0 | 0:04'58'' |
| Q30L120 | 295.47M |  54.4 |     222 | "49,69,89" | 276.77M |   6.329% | 5.43M | 5.33M |     0.98 | 5.37M |     0 | 0:04'59'' |
| Q30L140 |  275.6M |  50.7 |     227 | "49,69,89" | 258.02M |   6.377% | 5.43M | 5.33M |     0.98 | 5.36M |     0 | 0:04'49'' |

| Name    | N50SR |   Sum |   # | N50Anchor |   Sum |   # | N50Others |    Sum |  # |   RunTime |
|:--------|------:|------:|----:|----------:|------:|----:|----------:|-------:|---:|----------:|
| Q20L100 | 20316 | 5.37M | 474 |     20408 | 5.31M | 423 |       879 | 57.51K | 51 | 0:02'04'' |
| Q20L120 | 20817 | 5.36M | 449 |     20873 | 5.32M | 406 |       802 | 40.26K | 43 | 0:02'04'' |
| Q20L140 | 22399 | 5.36M | 419 |     22515 | 5.32M | 377 |       784 | 39.73K | 42 | 0:01'57'' |
| Q25L100 | 27988 | 5.37M | 328 |     28651 | 5.32M | 295 |      6580 | 49.73K | 33 | 0:01'59'' |
| Q25L120 | 29369 | 5.38M | 325 |     31498 |  5.3M | 291 |     12380 | 76.24K | 34 | 0:01'58'' |
| Q25L140 | 29369 | 5.36M | 323 |     30414 | 5.32M | 288 |     12340 | 47.51K | 35 | 0:01'55'' |
| Q30L100 | 32401 | 5.37M | 316 |     32533 | 5.35M | 283 |       650 | 21.54K | 33 | 0:02'03'' |
| Q30L120 | 31859 | 5.37M | 319 |     32401 | 5.34M | 284 |       779 | 30.85K | 35 | 0:01'57'' |
| Q30L140 | 32401 | 5.36M | 322 |     32533 | 5.33M | 287 |       779 | 30.97K | 35 | 0:01'56'' |

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

# merge others
anchr contained \
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
| anchor.merge |   35423 | 5344852 | 263 |
| others.merge |   12400 |   38257 |   5 |

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/Bcer
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

# *Rhodobacter sphaeroides* 2.4.1

## Rsph: download

* Reference genome

    * Taxid: [272943](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=272943)
    * RefSeq assembly accession:
      [GCF_000012905.2](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/745/GCF_000006745.1_ASM674v1/GCF_000006745.1_ASM674v1_assembly_report.txt)

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

cd ${BASE_DIR}
if [ ! -e 2_illumina/R1.scythe.fq.gz ]; then
    parallel --no-run-if-empty -j 2 "
        scythe \
            2_illumina/{}.uniq.fq.gz \
            -q sanger \
            -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
            --quiet \
            | pigz -p 4 -c \
            > 2_illumina/{}.scythe.fq.gz
        " ::: R1 R2
fi

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

ARRAY=(
    "2_illumina/Q20L100:Q20L100:2500000"
    "2_illumina/Q20L120:Q20L120:2500000"
    "2_illumina/Q20L140:Q20L140:1000000"
    "2_illumina/Q25L100:Q25L100:2500000"
    "2_illumina/Q25L120:Q25L120:1500000"
    "2_illumina/Q30L100:Q30L100:1500000"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    GROUP_MAX=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[2];')
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    perl -e 'print 500000 * $_, qq{\n} for 1 .. 5' \
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
            --kmer 49,69,89 \
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

| Name            |   SumFq | CovFq | AvgRead |       Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:----------------|--------:|------:|--------:|-----------:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| Q20L100_500000  | 145.51M |  31.6 |     146 | "49,69,89" |  129.1M |  11.277% |  4.6M | 4.51M |     0.98 | 4.48M |     0 | 0:02'47'' |
| Q20L100_1000000 | 291.01M |  63.2 |     146 | "49,69,89" | 258.19M |  11.279% |  4.6M | 4.54M |     0.99 | 4.54M |     0 | 0:04'13'' |
| Q20L100_1500000 | 436.56M |  94.8 |     147 | "49,69,89" | 387.48M |  11.243% |  4.6M | 4.56M |     0.99 | 4.55M |     0 | 0:05'36'' |
| Q20L100_2000000 | 582.13M | 126.5 |     146 | "49,69,89" | 517.09M |  11.172% |  4.6M | 4.58M |     0.99 | 4.55M |     0 | 0:06'56'' |
| Q20L100_2500000 | 727.61M | 158.1 |     146 | "49,69,89" |  646.7M |  11.120% |  4.6M |  4.6M |     1.00 | 4.53M |     0 | 0:08'14'' |
| Q20L120_500000  | 153.11M |  33.3 |     153 | "49,69,89" | 135.13M |  11.742% |  4.6M | 4.45M |     0.97 | 4.38M |     0 | 0:02'44'' |
| Q20L120_1000000 | 306.23M |  66.5 |     153 | "49,69,89" | 270.57M |  11.644% |  4.6M | 4.52M |     0.98 |  4.5M |     0 | 0:04'32'' |
| Q20L120_1500000 |  459.3M |  99.8 |     154 | "49,69,89" | 405.98M |  11.608% |  4.6M | 4.54M |     0.99 | 4.51M |     0 | 0:05'43'' |
| Q20L120_2000000 | 612.37M | 133.0 |     154 | "49,69,89" | 541.67M |  11.544% |  4.6M | 4.57M |     0.99 | 4.51M |     0 | 0:07'18'' |
| Q20L120_2500000 | 765.52M | 166.3 |     153 | "49,69,89" | 677.68M |  11.474% |  4.6M | 4.59M |     1.00 | 4.48M |     0 | 0:08'49'' |
| Q20L140_500000  | 163.62M |  35.5 |     164 | "49,69,89" | 142.72M |  12.774% |  4.6M | 4.25M |     0.92 | 4.07M |     0 | 0:02'51'' |
| Q20L140_1000000 | 327.19M |  71.1 |     164 | "49,69,89" | 285.55M |  12.727% |  4.6M |  4.4M |     0.96 |  4.3M |     0 | 0:04'37'' |
| Q25L100_500000  | 137.14M |  29.8 |     138 | "49,69,89" | 130.77M |   4.644% |  4.6M | 4.48M |     0.97 | 4.41M |     0 | 0:02'46'' |
| Q25L100_1000000 | 274.33M |  59.6 |     138 | "49,69,89" | 261.64M |   4.628% |  4.6M | 4.53M |     0.98 | 4.51M |     0 | 0:04'01'' |
| Q25L100_1500000 | 411.44M |  89.4 |     138 | "49,69,89" | 392.39M |   4.628% |  4.6M | 4.54M |     0.99 | 4.53M |     0 | 0:05'56'' |
| Q25L100_2000000 | 548.54M | 119.2 |     138 | "49,69,89" | 523.13M |   4.632% |  4.6M | 4.54M |     0.99 | 4.54M |     0 | 0:06'46'' |
| Q25L100_2500000 | 685.76M | 149.0 |     138 | "49,69,89" | 654.08M |   4.621% |  4.6M | 4.55M |     0.99 | 4.55M |     0 | 0:08'09'' |
| Q25L120_500000  |  146.1M |  31.7 |     146 | "49,69,89" |  138.9M |   4.930% |  4.6M | 4.35M |     0.94 |  4.2M |     0 | 0:02'41'' |
| Q25L120_1000000 | 292.17M |  63.5 |     146 | "49,69,89" | 277.83M |   4.906% |  4.6M | 4.46M |     0.97 | 4.39M |     0 | 0:04'25'' |
| Q25L120_1500000 | 438.27M |  95.2 |     146 | "49,69,89" | 416.81M |   4.896% |  4.6M | 4.49M |     0.98 | 4.45M |     0 | 0:05'39'' |
| Q30L100_500000  | 125.63M |  27.3 |     126 | "49,69,89" | 122.51M |   2.485% |  4.6M | 4.35M |     0.95 | 4.12M |     0 | 0:02'16'' |
| Q30L100_1000000 | 251.29M |  54.6 |     126 | "49,69,89" | 245.17M |   2.433% |  4.6M | 4.47M |     0.97 | 4.38M |     0 | 0:03'33'' |
| Q30L100_1500000 | 376.89M |  81.9 |     126 | "49,69,89" | 367.77M |   2.419% |  4.6M |  4.5M |     0.98 | 4.45M |     0 | 0:04'49'' |

| Name            | N50SR |   Sum |    # | N50Anchor |   Sum |    # | N50Others |     Sum |   # |   RunTime |
|:----------------|------:|------:|-----:|----------:|------:|-----:|----------:|--------:|----:|----------:|
| Q20L100_500000  |  8340 | 4.48M |  913 |      8607 | 4.38M |  779 |       784 | 100.27K | 134 | 0:01'30'' |
| Q20L100_1000000 | 13510 | 4.54M |  625 |     13807 | 4.47M |  537 |       809 |  65.97K |  88 | 0:02'16'' |
| Q20L100_1500000 | 12626 | 4.55M |  727 |     12854 | 4.45M |  594 |       761 |   96.4K | 133 | 0:02'52'' |
| Q20L100_2000000 |  8339 | 4.55M |  991 |      8669 |  4.4M |  784 |       733 | 146.75K | 207 | 0:03'22'' |
| Q20L100_2500000 |  5639 | 4.53M | 1307 |      5891 | 4.31M | 1007 |       764 |  216.8K | 300 | 0:03'50'' |
| Q20L120_500000  |  5589 | 4.38M | 1235 |      5814 | 4.21M | 1012 |       790 | 169.01K | 223 | 0:01'33'' |
| Q20L120_1000000 |  7864 |  4.5M |  923 |      8160 | 4.39M |  777 |       791 | 109.73K | 146 | 0:02'11'' |
| Q20L120_1500000 |  8497 | 4.51M |  942 |      8779 | 4.39M |  780 |       760 |  118.4K | 162 | 0:02'57'' |
| Q20L120_2000000 |  6251 | 4.51M | 1177 |      6533 | 4.32M |  920 |       768 | 186.85K | 257 | 0:03'30'' |
| Q20L120_2500000 |  4999 | 4.48M | 1429 |      5315 | 4.23M | 1075 |       748 |  252.3K | 354 | 0:03'45'' |
| Q20L140_500000  |  3108 | 4.07M | 1848 |      3457 | 3.62M | 1246 |       790 | 451.08K | 602 | 0:01'33'' |
| Q20L140_1000000 |  4429 |  4.3M | 1500 |      4826 | 4.02M | 1125 |       791 | 280.21K | 375 | 0:02'12'' |
| Q25L100_500000  |  5890 | 4.41M | 1213 |      6030 | 4.23M |  966 |       771 | 183.83K | 247 | 0:01'37'' |
| Q25L100_1000000 |  9304 | 4.51M |  818 |      9568 | 4.43M |  707 |       774 |  81.91K | 111 | 0:02'24'' |
| Q25L100_1500000 | 11745 | 4.53M |  682 |     11902 | 4.47M |  599 |       785 |  61.63K |  83 | 0:02'56'' |
| Q25L100_2000000 | 12531 | 4.54M |  648 |     12564 | 4.49M |  571 |       808 |  58.13K |  77 | 0:03'38'' |
| Q25L100_2500000 | 12551 | 4.55M |  671 |     12801 | 4.48M |  573 |       804 |  72.66K |  98 | 0:04'05'' |
| Q25L120_500000  |  3832 |  4.2M | 1603 |      4191 | 3.87M | 1167 |       786 | 327.28K | 436 | 0:01'39'' |
| Q25L120_1000000 |  5785 | 4.39M | 1200 |      5977 | 4.21M |  955 |       785 | 183.73K | 245 | 0:02'19'' |
| Q25L120_1500000 |  7215 | 4.45M | 1022 |      7427 | 4.32M |  845 |       766 | 131.32K | 177 | 0:02'52'' |
| Q30L100_500000  |  3137 | 4.12M | 1824 |      3537 | 3.72M | 1282 |       787 | 405.72K | 542 | 0:01'39'' |
| Q30L100_1000000 |  5087 | 4.38M | 1354 |      5412 | 4.15M | 1043 |       766 | 228.09K | 311 | 0:02'18'' |
| Q30L100_1500000 |  6483 | 4.45M | 1135 |      6756 | 4.29M |  919 |       783 | 158.92K | 216 | 0:02'51'' |

## Rsph: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/Rsph
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L100_1000000/anchor/pe.anchor.fa \
    Q20L100_1500000/anchor/pe.anchor.fa \
    Q20L100_2000000/anchor/pe.anchor.fa \
    Q20L120_1000000/anchor/pe.anchor.fa \
    Q20L120_1500000/anchor/pe.anchor.fa \
    Q20L120_2000000/anchor/pe.anchor.fa \
    Q20L140_1000000/anchor/pe.anchor.fa \
    Q25L100_1500000/anchor/pe.anchor.fa \
    Q25L100_2000000/anchor/pe.anchor.fa \
    Q25L100_2500000/anchor/pe.anchor.fa \
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

# merge others
anchr contained \
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
| anchor.merge |   26847 | 4533535 | 301 |
| others.merge |    1020 |   32216 |  31 |

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/Rsph
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

# *Mycobacterium abscessus* 6G-0125-R

## Mabs: download

* Reference genome

    * *Mycobacterium abscessus* ATCC 19977
        * Taxid: [561007](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=243277)
        * RefSeq assembly accession:
          [GCF_000069185.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/745/GCF_000006745.1_ASM674v1/GCF_000006745.1_ASM674v1_assembly_report.txt)
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

cd ${BASE_DIR}
if [ ! -e 2_illumina/R1.scythe.fq.gz ]; then
    parallel --no-run-if-empty -j 2 "
        scythe \
            2_illumina/{}.uniq.fq.gz \
            -q sanger \
            -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
            --quiet \
            | pigz -p 4 -c \
            > 2_illumina/{}.scythe.fq.gz
        " ::: R1 R2
fi

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

ARRAY=(
    "2_illumina/Q20L100:Q20L100:2500000"
    "2_illumina/Q20L120:Q20L120:2500000"
    "2_illumina/Q20L140:Q20L140:2000000"
    "2_illumina/Q25L100:Q25L100:2500000"
    "2_illumina/Q25L120:Q25L120:2000000"
    "2_illumina/Q25L140:Q25L140:2000000"
    "2_illumina/Q30L100:Q30L100:2000000"
    "2_illumina/Q30L120:Q30L120:1500000"
    "2_illumina/Q30L140:Q30L140:1000000"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    GROUP_MAX=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[2];')
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    perl -e 'print 500000 * $_, qq{\n} for 1 .. 5' \
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
            --kmer 49,69,89 \
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

| Name            |   SumFq | CovFq | AvgRead |       Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:----------------|--------:|------:|--------:|-----------:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| Q20L100_500000  | 174.96M |  34.4 |     174 | "49,69,89" | 137.05M |  21.667% | 5.09M | 5.16M |     1.01 | 5.15M |     0 | 0:02'52'' |
| Q20L100_1000000 | 349.97M |  68.7 |     175 | "49,69,89" | 274.77M |  21.486% | 5.09M | 5.27M |     1.04 |  5.2M |     0 | 0:04'30'' |
| Q20L100_1500000 | 524.92M | 103.1 |     174 | "49,69,89" | 411.63M |  21.582% | 5.09M | 5.31M |     1.04 | 5.21M |     0 | 0:06'01'' |
| Q20L100_2000000 | 699.77M | 137.5 |     175 | "49,69,89" | 549.28M |  21.506% | 5.09M | 5.38M |     1.06 | 5.19M |     0 | 0:07'37'' |
| Q20L100_2500000 | 874.71M | 171.8 |     175 | "49,69,89" | 691.83M |  20.908% | 5.09M | 5.62M |     1.10 | 4.33M |     0 | 0:09'12'' |
| Q20L120_500000  | 179.78M |  35.3 |     179 | "49,69,89" | 141.29M |  21.414% | 5.09M | 5.16M |     1.01 | 5.13M |     0 | 0:02'54'' |
| Q20L120_1000000 | 359.59M |  70.6 |     179 | "49,69,89" | 283.43M |  21.179% | 5.09M | 5.28M |     1.04 | 5.18M |     0 | 0:04'31'' |
| Q20L120_1500000 | 539.45M | 106.0 |     179 | "49,69,89" | 424.19M |  21.365% | 5.09M | 5.32M |     1.04 |  5.2M |     0 | 0:06'14'' |
| Q20L120_2000000 | 719.16M | 141.3 |     179 | "49,69,89" | 566.29M |  21.257% | 5.09M |  5.4M |     1.06 | 5.18M |     0 | 0:07'46'' |
| Q20L120_2500000 | 898.84M | 176.6 |     179 | "49,69,89" | 713.58M |  20.611% | 5.09M | 5.65M |     1.11 |  4.1M |     0 | 0:09'34'' |
| Q20L140_500000  | 186.63M |  36.7 |     186 | "49,69,89" | 146.54M |  21.481% | 5.09M | 5.13M |     1.01 |  5.1M |     0 | 0:03'00'' |
| Q20L140_1000000 | 373.19M |  73.3 |     186 | "49,69,89" | 293.99M |  21.222% | 5.09M | 5.28M |     1.04 | 5.15M |     0 | 0:04'41'' |
| Q20L140_1500000 | 559.88M | 110.0 |     186 | "49,69,89" | 439.96M |  21.419% | 5.09M | 5.33M |     1.05 | 5.19M |     0 | 0:06'14'' |
| Q20L140_2000000 | 746.49M | 146.6 |     186 | "49,69,89" | 587.46M |  21.303% | 5.09M | 5.42M |     1.06 | 5.16M |     0 | 0:10'00'' |
| Q25L100_500000  | 170.61M |  33.5 |     170 | "49,69,89" |  142.6M |  16.422% | 5.09M | 5.16M |     1.01 | 5.14M |     0 | 0:02'55'' |
| Q25L100_1000000 | 341.34M |  67.1 |     170 | "49,69,89" |    285M |  16.506% | 5.09M | 5.24M |     1.03 | 5.17M |     0 | 0:06'51'' |
| Q25L100_1500000 | 511.87M | 100.6 |     171 | "49,69,89" | 427.93M |  16.399% | 5.09M |  5.3M |     1.04 | 5.21M |     0 | 0:08'57'' |
| Q25L100_2000000 | 682.54M | 134.1 |     171 | "49,69,89" | 571.06M |  16.333% | 5.09M | 5.37M |     1.06 |  5.2M |     0 | 0:09'36'' |
| Q25L100_2500000 |  853.2M | 167.6 |     171 | "49,69,89" | 714.47M |  16.260% | 5.09M | 5.43M |     1.07 | 5.17M |     0 | 0:11'54'' |
| Q25L120_500000  | 176.23M |  34.6 |     176 | "49,69,89" | 147.42M |  16.351% | 5.09M | 5.14M |     1.01 | 5.11M |     0 | 0:03'37'' |
| Q25L120_1000000 | 352.34M |  69.2 |     176 | "49,69,89" | 294.31M |  16.472% | 5.09M | 5.24M |     1.03 | 5.16M |     0 | 0:06'13'' |
| Q25L120_1500000 | 528.65M | 103.8 |     177 | "49,69,89" | 442.19M |  16.355% | 5.09M | 5.31M |     1.04 | 5.19M |     0 | 0:08'03'' |
| Q25L120_2000000 | 704.84M | 138.5 |     176 | "49,69,89" |  590.2M |  16.265% | 5.09M | 5.38M |     1.06 | 5.19M |     0 | 0:10'04'' |
| Q25L140_500000  | 183.57M |  36.1 |     183 | "49,69,89" | 153.27M |  16.504% | 5.09M | 5.11M |     1.00 | 5.03M |     0 | 0:04'15'' |
| Q25L140_1000000 | 367.17M |  72.1 |     184 | "49,69,89" | 306.09M |  16.634% | 5.09M | 5.24M |     1.03 | 5.14M |     0 | 0:06'05'' |
| Q25L140_1500000 | 550.77M | 108.2 |     184 | "49,69,89" | 459.72M |  16.532% | 5.09M | 5.32M |     1.05 | 5.18M |     0 | 0:08'14'' |
| Q25L140_2000000 | 680.19M | 133.6 |     183 | "49,69,89" | 568.25M |  16.458% | 5.09M | 5.38M |     1.06 | 5.17M |     0 | 0:08'23'' |
| Q30L100_500000  | 163.94M |  32.2 |     163 | "49,69,89" | 142.61M |  13.014% | 5.09M | 5.14M |     1.01 | 5.11M |     0 | 0:03'25'' |
| Q30L100_1000000 | 327.94M |  64.4 |     164 | "49,69,89" | 285.22M |  13.026% | 5.09M | 5.23M |     1.03 | 5.16M |     0 | 0:04'40'' |
| Q30L100_1500000 | 491.89M |  96.6 |     164 | "49,69,89" | 428.12M |  12.964% | 5.09M |  5.3M |     1.04 | 5.19M |     0 | 0:06'20'' |
| Q30L100_2000000 | 655.83M | 128.8 |     164 | "49,69,89" | 571.23M |  12.899% | 5.09M | 5.36M |     1.05 |  5.2M |     0 | 0:07'17'' |
| Q30L120_500000  | 170.77M |  33.5 |     170 | "49,69,89" | 148.46M |  13.067% | 5.09M | 5.12M |     1.01 | 5.05M |     0 | 0:02'56'' |
| Q30L120_1000000 | 341.56M |  67.1 |     171 | "49,69,89" | 296.71M |  13.131% | 5.09M | 5.24M |     1.03 | 5.16M |     0 | 0:04'39'' |
| Q30L120_1500000 |  512.3M | 100.6 |     170 | "49,69,89" | 445.37M |  13.065% | 5.09M | 5.31M |     1.04 | 5.18M |     0 | 0:06'42'' |
| Q30L140_500000  | 179.02M |  35.2 |     179 | "49,69,89" | 155.08M |  13.376% | 5.09M | 5.07M |     1.00 | 4.93M |     0 | 0:03'13'' |
| Q30L140_1000000 | 358.03M |  70.3 |     179 | "49,69,89" | 309.81M |  13.468% | 5.09M | 5.22M |     1.03 | 5.08M |     0 | 0:05'01'' |

| Name            | N50SR |   Sum |    # | N50Anchor |   Sum |    # | N50Others |     Sum |    # |   RunTime |
|:----------------|------:|------:|-----:|----------:|------:|-----:|----------:|--------:|-----:|----------:|
| Q20L100_500000  |  8705 | 5.15M |  953 |      8893 | 5.07M |  841 |       745 |  80.88K |  112 | 0:01'57'' |
| Q20L100_1000000 |  4061 |  5.2M | 1798 |      4283 | 4.93M | 1441 |       790 | 269.14K |  357 | 0:02'22'' |
| Q20L100_1500000 |  5363 | 5.21M | 1445 |      5519 | 5.03M | 1217 |       795 | 177.79K |  228 | 0:03'03'' |
| Q20L100_2000000 |  3157 | 5.19M | 2272 |      3365 | 4.76M | 1688 |       766 | 426.53K |  584 | 0:02'44'' |
| Q20L100_2500000 |  1016 | 4.33M | 4521 |      1476 |  2.2M | 1483 |       721 |   2.14M | 3038 | 0:03'01'' |
| Q20L120_500000  |  5857 | 5.13M | 1319 |      5973 | 4.99M | 1129 |       788 | 142.49K |  190 | 0:01'04'' |
| Q20L120_1000000 |  3342 | 5.18M | 2111 |      3584 |  4.8M | 1599 |       790 | 382.46K |  512 | 0:01'42'' |
| Q20L120_1500000 |  4955 |  5.2M | 1527 |      5200 | 5.01M | 1279 |       778 | 187.54K |  248 | 0:02'23'' |
| Q20L120_2000000 |  2826 | 5.18M | 2479 |      3137 | 4.65M | 1767 |       770 | 523.92K |  712 | 0:02'55'' |
| Q20L120_2500000 |   960 |  4.1M | 4474 |      1394 |  1.9M | 1323 |       718 |   2.21M | 3151 | 0:02'36'' |
| Q20L140_500000  |  4377 |  5.1M | 1668 |      4543 | 4.84M | 1342 |       784 | 252.54K |  326 | 0:01'19'' |
| Q20L140_1000000 |  2743 | 5.15M | 2487 |      2984 | 4.61M | 1770 |       778 | 533.38K |  717 | 0:02'03'' |
| Q20L140_1500000 |  4187 | 5.19M | 1837 |      4378 |  4.9M | 1448 |       786 | 293.62K |  389 | 0:02'23'' |
| Q20L140_2000000 |  2469 | 5.16M | 2729 |      2754 | 4.51M | 1869 |       778 | 645.47K |  860 | 0:02'57'' |
| Q25L100_500000  |  7856 | 5.14M | 1040 |      8006 | 5.03M |  902 |       758 | 100.88K |  138 | 0:01'33'' |
| Q25L100_1000000 | 11560 | 5.17M |  691 |     11574 | 5.13M |  635 |       823 |   41.5K |   56 | 0:02'14'' |
| Q25L100_1500000 |  6066 | 5.21M | 1251 |      6203 | 5.07M | 1095 |       834 |  134.7K |  156 | 0:02'39'' |
| Q25L100_2000000 |  3829 |  5.2M | 1915 |      4024 |  4.9M | 1519 |       771 | 292.02K |  396 | 0:03'28'' |
| Q25L100_2500000 |  2595 | 5.17M | 2647 |      2896 |  4.6M | 1863 |       766 | 571.02K |  784 | 0:03'52'' |
| Q25L120_500000  |  5322 | 5.11M | 1397 |      5457 | 4.93M | 1160 |       807 |  184.2K |  237 | 0:01'31'' |
| Q25L120_1000000 |  9131 | 5.16M |  909 |      9263 | 5.07M |  797 |       787 |  88.44K |  112 | 0:02'10'' |
| Q25L120_1500000 |  5248 | 5.19M | 1435 |      5365 | 5.02M | 1211 |       783 | 167.54K |  224 | 0:02'35'' |
| Q25L120_2000000 |  3323 | 5.19M | 2162 |      3482 | 4.81M | 1652 |       773 | 373.21K |  510 | 0:03'34'' |
| Q25L140_500000  |  3687 | 5.03M | 1928 |      4020 |  4.7M | 1484 |       777 | 332.01K |  444 | 0:01'29'' |
| Q25L140_1000000 |  5731 | 5.14M | 1312 |      5975 | 4.99M | 1101 |       771 | 158.85K |  211 | 0:02'17'' |
| Q25L140_1500000 |  3892 | 5.18M | 1826 |      4123 | 4.91M | 1470 |       770 | 263.77K |  356 | 0:02'31'' |
| Q25L140_2000000 |  3064 | 5.17M | 2328 |      3288 | 4.73M | 1729 |       768 | 439.07K |  599 | 0:03'29'' |
| Q30L100_500000  |  6217 | 5.11M | 1254 |      6372 | 4.96M | 1049 |       774 | 150.82K |  205 | 0:01'40'' |
| Q30L100_1000000 |  9140 | 5.16M |  875 |      9148 | 5.09M |  781 |       760 |  67.68K |   94 | 0:02'23'' |
| Q30L100_1500000 |  5960 | 5.19M | 1239 |      6131 | 5.07M | 1073 |       774 | 121.39K |  166 | 0:03'06'' |
| Q30L100_2000000 |  3927 |  5.2M | 1863 |      4111 | 4.91M | 1474 |       772 |  285.8K |  389 | 0:03'49'' |
| Q30L120_500000  |  4123 | 5.05M | 1724 |      4377 | 4.81M | 1386 |       773 | 248.37K |  338 | 0:01'43'' |
| Q30L120_1000000 |  6322 | 5.16M | 1197 |      6452 | 5.02M | 1033 |       804 | 137.38K |  164 | 0:02'17'' |
| Q30L120_1500000 |  4676 | 5.18M | 1586 |      4896 | 4.97M | 1294 |       790 | 214.98K |  292 | 0:03'01'' |
| Q30L140_500000  |  2889 | 4.93M | 2350 |      3191 | 4.41M | 1646 |       771 | 519.25K |  704 | 0:01'22'' |
| Q30L140_1000000 |  4377 | 5.08M | 1653 |      4584 | 4.85M | 1333 |       753 | 233.08K |  320 | 0:02'02'' |

## Mabs: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/Mabs
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L100_1000000/anchor/pe.anchor.fa \
    Q20L100_1500000/anchor/pe.anchor.fa \
    Q20L100_2000000/anchor/pe.anchor.fa \
    Q20L120_1000000/anchor/pe.anchor.fa \
    Q20L120_1500000/anchor/pe.anchor.fa \
    Q20L120_2000000/anchor/pe.anchor.fa \
    Q20L140_1000000/anchor/pe.anchor.fa \
    Q20L140_1500000/anchor/pe.anchor.fa \
    Q20L140_2000000/anchor/pe.anchor.fa \
    Q25L100_1000000/anchor/pe.anchor.fa \
    Q25L100_1500000/anchor/pe.anchor.fa \
    Q25L100_2000000/anchor/pe.anchor.fa \
    Q25L120_1000000/anchor/pe.anchor.fa \
    Q25L120_1500000/anchor/pe.anchor.fa \
    Q25L120_2000000/anchor/pe.anchor.fa \
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

# merge others
anchr contained \
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
| anchor.merge |   67242 | 5220973 | 132 |
| others.merge |    1055 |  125266 |  93 |

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/Mabs
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

# *Vibrio cholerae* CP1032(5)

## Vcho: download

* Reference genome

    * *Vibrio cholerae* O1 biovar El Tor str. N16961
        * Taxid: [243277](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=243277)
        * RefSeq assembly accession:
          [GCF_000006745.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/745/GCF_000006745.1_ASM674v1/GCF_000006745.1_ASM674v1_assembly_report.txt)
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

cd ${BASE_DIR}
if [ ! -e 2_illumina/R1.scythe.fq.gz ]; then
    parallel --no-run-if-empty -j 2 "
        scythe \
            2_illumina/{}.uniq.fq.gz \
            -q sanger \
            -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
            --quiet \
            | pigz -p 4 -c \
            > 2_illumina/{}.scythe.fq.gz
        " ::: R1 R2
fi

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

ARRAY=(
    "2_illumina/Q20L100:Q20L100:2500000"
    "2_illumina/Q20L120:Q20L120:2500000"
    "2_illumina/Q20L140:Q20L140:2500000"
    "2_illumina/Q25L100:Q25L100:2500000"
    "2_illumina/Q25L120:Q25L120:2500000"
    "2_illumina/Q25L140:Q25L140:2500000"
    "2_illumina/Q30L100:Q30L100:2500000"
    "2_illumina/Q30L120:Q30L120:2000000"
    "2_illumina/Q30L140:Q30L140:2000000"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(perl -e "@p = split q{:}, q{${group}}; print \$p[0];")
    GROUP_ID=$( perl -e "@p = split q{:}, q{${group}}; print \$p[1];")
    GROUP_MAX=$(perl -e "@p = split q{:}, q{${group}}; print \$p[2];")
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    perl -e 'print 500000 * $_, qq{\n} for 1 .. 5' \
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
            --kmer 49,69,89 \
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

| Name            |   SumFq | CovFq | AvgRead |       Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:----------------|--------:|------:|--------:|-----------:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| Q20L100_500000  |  186.1M |  46.1 |     186 | "49,69,89" |    150M |  19.400% | 4.03M | 3.94M |     0.98 | 3.94M |     0 | 0:03'54'' |
| Q20L100_1000000 |  372.2M |  92.3 |     186 | "49,69,89" | 300.13M |  19.364% | 4.03M | 3.98M |     0.99 | 3.95M |     0 | 0:05'58'' |
| Q20L100_1500000 | 558.38M | 138.4 |     186 | "49,69,89" | 450.91M |  19.248% | 4.03M | 4.04M |     1.00 | 3.94M |     0 | 0:07'52'' |
| Q20L100_2000000 | 744.46M | 184.6 |     186 | "49,69,89" | 604.15M |  18.846% | 4.03M | 4.19M |     1.04 |  3.7M |     0 | 0:10'01'' |
| Q20L100_2500000 | 930.67M | 230.7 |     187 | "49,69,89" | 756.52M |  18.713% | 4.03M | 4.33M |     1.07 | 3.38M |     0 | 0:11'25'' |
| Q20L120_500000  | 188.54M |  46.7 |     188 | "49,69,89" | 152.72M |  18.998% | 4.03M | 3.94M |     0.98 | 3.94M |     0 | 0:03'24'' |
| Q20L120_1000000 | 376.99M |  93.5 |     188 | "49,69,89" | 305.12M |  19.065% | 4.03M | 3.99M |     0.99 | 3.95M |     0 | 0:05'38'' |
| Q20L120_1500000 | 565.29M | 140.1 |     189 | "49,69,89" | 458.71M |  18.853% | 4.03M | 4.05M |     1.00 | 3.95M |     0 | 0:06'48'' |
| Q20L120_2000000 |  753.8M | 186.9 |     189 | "49,69,89" | 612.09M |  18.799% | 4.03M | 4.13M |     1.02 | 3.91M |     0 | 0:08'08'' |
| Q20L120_2500000 | 942.27M | 233.6 |     188 | "49,69,89" | 769.39M |  18.347% | 4.03M | 4.35M |     1.08 | 3.37M |     0 | 0:11'23'' |
| Q20L140_500000  | 192.86M |  47.8 |     193 | "49,69,89" | 156.81M |  18.693% | 4.03M | 3.94M |     0.98 | 3.94M |     0 | 0:03'14'' |
| Q20L140_1000000 | 385.48M |  95.6 |     193 | "49,69,89" | 313.22M |  18.745% | 4.03M | 3.99M |     0.99 | 3.95M |     0 | 0:05'08'' |
| Q20L140_1500000 | 578.33M | 143.4 |     193 | "49,69,89" | 470.53M |  18.640% | 4.03M | 4.06M |     1.01 | 3.95M |     0 | 0:06'56'' |
| Q20L140_2000000 | 771.16M | 191.2 |     193 | "49,69,89" |  628.3M |  18.525% | 4.03M | 4.16M |     1.03 | 3.92M |     0 | 0:08'27'' |
| Q20L140_2500000 | 963.94M | 239.0 |     193 | "49,69,89" | 789.86M |  18.059% | 4.03M | 4.36M |     1.08 | 3.33M |     0 | 0:10'46'' |
| Q25L100_500000  | 182.93M |  45.4 |     183 | "49,69,89" | 155.44M |  15.025% | 4.03M | 3.94M |     0.98 | 3.94M |     0 | 0:03'02'' |
| Q25L100_1000000 | 365.95M |  90.7 |     183 | "49,69,89" |    311M |  15.017% | 4.03M | 3.98M |     0.99 | 3.95M |     0 | 0:04'44'' |
| Q25L100_1500000 | 548.86M | 136.1 |     183 | "49,69,89" | 467.06M |  14.903% | 4.03M | 4.02M |     1.00 | 3.96M |     0 | 0:06'35'' |
| Q25L100_2000000 | 731.98M | 181.5 |     184 | "49,69,89" | 623.43M |  14.829% | 4.03M | 4.08M |     1.01 | 3.95M |     0 | 0:08'22'' |
| Q25L100_2500000 | 914.97M | 226.8 |     184 | "49,69,89" | 780.09M |  14.742% | 4.03M | 4.19M |     1.04 |  3.9M |     0 | 0:10'08'' |
| Q25L120_500000  | 185.77M |  46.1 |     185 | "49,69,89" | 158.38M |  14.747% | 4.03M | 3.94M |     0.98 | 3.94M |     0 | 0:03'03'' |
| Q25L120_1000000 | 371.73M |  92.2 |     186 | "49,69,89" | 316.57M |  14.837% | 4.03M | 3.97M |     0.99 | 3.96M |     0 | 0:04'46'' |
| Q25L120_1500000 | 557.44M | 138.2 |     186 | "49,69,89" | 475.27M |  14.740% | 4.03M | 4.03M |     1.00 | 3.97M |     0 | 0:06'31'' |
| Q25L120_2000000 |  743.3M | 184.3 |     186 | "49,69,89" | 634.49M |  14.639% | 4.03M |  4.1M |     1.02 | 3.94M |     0 | 0:08'17'' |
| Q25L120_2500000 | 929.12M | 230.4 |     186 | "49,69,89" | 793.87M |  14.556% | 4.03M |  4.2M |     1.04 | 3.88M |     0 | 0:10'10'' |
| Q25L140_500000  | 190.69M |  47.3 |     190 | "49,69,89" | 162.61M |  14.724% | 4.03M | 3.94M |     0.98 | 3.93M |     0 | 0:03'10'' |
| Q25L140_1000000 | 381.26M |  94.5 |     190 | "49,69,89" | 325.13M |  14.722% | 4.03M | 3.98M |     0.99 | 3.95M |     0 | 0:04'51'' |
| Q25L140_1500000 | 571.92M | 141.8 |     190 | "49,69,89" | 487.99M |  14.676% | 4.03M | 4.05M |     1.00 | 3.96M |     0 | 0:06'47'' |
| Q25L140_2000000 | 762.41M | 189.0 |     190 | "49,69,89" | 651.52M |  14.545% | 4.03M | 4.13M |     1.02 | 3.93M |     0 | 0:08'13'' |
| Q25L140_2500000 | 922.96M | 228.8 |     191 | "49,69,89" | 789.42M |  14.469% | 4.03M | 4.21M |     1.04 | 3.87M |     0 | 0:09'49'' |
| Q30L100_500000  | 177.61M |  44.0 |     178 | "49,69,89" | 156.93M |  11.645% | 4.03M | 3.94M |     0.98 | 3.94M |     0 | 0:02'49'' |
| Q30L100_1000000 | 355.17M |  88.1 |     177 | "49,69,89" | 313.66M |  11.687% | 4.03M | 3.96M |     0.98 | 3.95M |     0 | 0:04'29'' |
| Q30L100_1500000 | 532.91M | 132.1 |     178 | "49,69,89" | 471.02M |  11.613% | 4.03M |    4M |     0.99 | 3.97M |     0 | 0:06'03'' |
| Q30L100_2000000 | 710.47M | 176.1 |     178 | "49,69,89" | 628.46M |  11.544% | 4.03M | 4.04M |     1.00 | 3.95M |     0 | 0:07'53'' |
| Q30L100_2500000 | 888.14M | 220.2 |     179 | "49,69,89" | 786.35M |  11.462% | 4.03M | 4.11M |     1.02 | 3.91M |     0 | 0:09'21'' |
| Q30L120_500000  | 181.34M |  45.0 |     181 | "49,69,89" |  160.2M |  11.658% | 4.03M | 3.94M |     0.98 | 3.94M |     0 | 0:02'48'' |
| Q30L120_1000000 |  362.7M |  89.9 |     182 | "49,69,89" | 320.39M |  11.665% | 4.03M | 3.96M |     0.98 | 3.95M |     0 | 0:04'26'' |
| Q30L120_1500000 |    544M | 134.9 |     181 | "49,69,89" | 480.83M |  11.612% | 4.03M |    4M |     0.99 | 3.96M |     0 | 0:06'07'' |
| Q30L120_2000000 | 725.38M | 179.8 |     182 | "49,69,89" | 641.52M |  11.560% | 4.03M | 4.06M |     1.01 | 3.95M |     0 | 0:07'49'' |
| Q30L140_500000  | 186.98M |  46.4 |     186 | "49,69,89" | 164.71M |  11.906% | 4.03M | 3.93M |     0.97 | 3.93M |     0 | 0:03'04'' |
| Q30L140_1000000 | 373.87M |  92.7 |     187 | "49,69,89" | 329.73M |  11.807% | 4.03M | 3.97M |     0.98 | 3.95M |     0 | 0:04'53'' |
| Q30L140_1500000 | 560.86M | 139.1 |     187 | "49,69,89" | 494.78M |  11.782% | 4.03M | 4.01M |     1.00 | 3.95M |     0 | 0:06'38'' |
| Q30L140_2000000 | 732.71M | 181.7 |     187 | "49,69,89" |  647.1M |  11.684% | 4.03M | 4.07M |     1.01 | 3.93M |     0 | 0:08'02'' |

| Name            | N50SR |   Sum |    # | N50Anchor |   Sum |    # | N50Others |     Sum |    # |   RunTime |
|:----------------|------:|------:|-----:|----------:|------:|-----:|----------:|--------:|-----:|----------:|
| Q20L100_500000  | 12264 | 3.94M |  603 |     12510 | 3.86M |  499 |       795 |  76.69K |  104 | 0:01'37'' |
| Q20L100_1000000 |  9183 | 3.95M |  769 |      9332 | 3.86M |  642 |       787 |  92.65K |  127 | 0:02'16'' |
| Q20L100_1500000 |  4299 | 3.94M | 1344 |      4537 | 3.73M | 1056 |       793 | 215.97K |  288 | 0:03'06'' |
| Q20L100_2000000 |  1429 |  3.7M | 2943 |      1875 | 2.62M | 1455 |       756 |   1.08M | 1488 | 0:02'21'' |
| Q20L100_2500000 |  1125 | 3.38M | 3272 |      1567 | 1.93M | 1220 |       726 |   1.45M | 2052 | 0:02'56'' |
| Q20L120_500000  | 10274 | 3.94M |  650 |     10509 | 3.86M |  538 |       739 |  80.33K |  112 | 0:01'18'' |
| Q20L120_1000000 |  8479 | 3.95M |  768 |      8681 | 3.86M |  646 |       801 |  91.58K |  122 | 0:01'51'' |
| Q20L120_1500000 |  4374 | 3.95M | 1378 |      4670 | 3.72M | 1059 |       768 | 234.44K |  319 | 0:02'16'' |
| Q20L120_2000000 |  2567 | 3.91M | 2044 |      2858 | 3.42M | 1383 |       778 | 487.41K |  661 | 0:02'34'' |
| Q20L120_2500000 |  1106 | 3.37M | 3290 |      1548 |  1.9M | 1218 |       728 |   1.46M | 2072 | 0:02'25'' |
| Q20L140_500000  |  9259 | 3.94M |  770 |      9375 | 3.83M |  620 |       767 | 110.51K |  150 | 0:01'18'' |
| Q20L140_1000000 |  8673 | 3.95M |  791 |      8963 | 3.84M |  650 |       788 |  104.6K |  141 | 0:01'46'' |
| Q20L140_1500000 |  3857 | 3.95M | 1465 |      4137 | 3.71M | 1135 |       775 | 243.74K |  330 | 0:02'08'' |
| Q20L140_2000000 |  2567 | 3.92M | 2051 |      2923 | 3.41M | 1360 |       773 | 507.15K |  691 | 0:02'27'' |
| Q20L140_2500000 |  1069 | 3.33M | 3333 |      1519 | 1.81M | 1190 |       728 |   1.52M | 2143 | 0:02'36'' |
| Q25L100_500000  | 12594 | 3.94M |  607 |     12968 | 3.85M |  490 |       803 |  87.46K |  117 | 0:01'19'' |
| Q25L100_1000000 |  9375 | 3.95M |  711 |      9546 | 3.87M |  595 |       784 |  84.76K |  116 | 0:02'00'' |
| Q25L100_1500000 |  4550 | 3.96M | 1279 |      4815 | 3.77M | 1016 |       790 | 196.69K |  263 | 0:02'11'' |
| Q25L100_2000000 |  2933 | 3.95M | 1846 |      3290 | 3.54M | 1290 |       776 | 408.72K |  556 | 0:02'55'' |
| Q25L100_2500000 |  2066 |  3.9M | 2429 |      2395 | 3.22M | 1496 |       771 | 683.07K |  933 | 0:03'12'' |
| Q25L120_500000  | 11133 | 3.94M |  637 |     11211 | 3.86M |  534 |       766 |  76.42K |  103 | 0:01'25'' |
| Q25L120_1000000 |  9015 | 3.96M |  744 |      9256 | 3.86M |  606 |       764 |  99.32K |  138 | 0:01'54'' |
| Q25L120_1500000 |  4419 | 3.97M | 1296 |      4671 | 3.77M | 1027 |       790 | 198.56K |  269 | 0:02'19'' |
| Q25L120_2000000 |  2932 | 3.94M | 1868 |      3236 | 3.53M | 1309 |       785 | 415.91K |  559 | 0:03'04'' |
| Q25L120_2500000 |  1922 | 3.88M | 2480 |      2285 | 3.15M | 1491 |       771 | 726.91K |  989 | 0:03'24'' |
| Q25L140_500000  |  8596 | 3.93M |  758 |      8847 | 3.83M |  619 |       754 | 100.75K |  139 | 0:01'23'' |
| Q25L140_1000000 |  8798 | 3.95M |  767 |      8990 | 3.85M |  633 |       820 | 100.77K |  134 | 0:01'53'' |
| Q25L140_1500000 |  4423 | 3.96M | 1341 |      4636 | 3.72M | 1021 |       783 | 238.82K |  320 | 0:02'13'' |
| Q25L140_2000000 |  2755 | 3.93M | 1936 |      3019 |  3.5M | 1364 |       771 | 422.68K |  572 | 0:02'46'' |
| Q25L140_2500000 |  1969 | 3.87M | 2471 |      2316 | 3.15M | 1485 |       771 | 725.67K |  986 | 0:02'59'' |
| Q30L100_500000  | 13117 | 3.94M |  558 |     13295 | 3.87M |  455 |       740 |  73.83K |  103 | 0:01'30'' |
| Q30L100_1000000 | 10170 | 3.95M |  670 |     10239 | 3.87M |  563 |       795 |  78.81K |  107 | 0:02'00'' |
| Q30L100_1500000 |  5066 | 3.97M | 1169 |      5263 | 3.79M |  922 |       760 | 179.94K |  247 | 0:02'26'' |
| Q30L100_2000000 |  3195 | 3.95M | 1728 |      3511 |  3.6M | 1249 |       764 | 350.25K |  479 | 0:03'14'' |
| Q30L100_2500000 |  2191 | 3.91M | 2303 |      2543 | 3.29M | 1454 |       769 | 622.71K |  849 | 0:03'12'' |
| Q30L120_500000  | 10289 | 3.94M |  676 |     10626 | 3.85M |  553 |       723 |  88.41K |  123 | 0:01'26'' |
| Q30L120_1000000 |  8965 | 3.95M |  754 |      9184 | 3.84M |  608 |       747 | 105.97K |  146 | 0:01'56'' |
| Q30L120_1500000 |  5165 | 3.96M | 1205 |      5514 | 3.77M |  943 |       783 | 194.08K |  262 | 0:02'32'' |
| Q30L120_2000000 |  2977 | 3.95M | 1839 |      3237 | 3.56M | 1305 |       770 | 390.48K |  534 | 0:03'04'' |
| Q30L140_500000  | 10502 | 3.93M |  659 |     10531 | 3.84M |  540 |       748 |  87.75K |  119 | 0:01'24'' |
| Q30L140_1000000 |  7287 | 3.95M |  900 |      7467 | 3.82M |  726 |       808 | 130.58K |  174 | 0:01'55'' |
| Q30L140_1500000 |  4320 | 3.95M | 1352 |      4586 | 3.71M | 1029 |       801 |    242K |  323 | 0:02'20'' |
| Q30L140_2000000 |  2795 | 3.93M | 1933 |      3133 | 3.49M | 1333 |       783 | 446.42K |  600 | 0:02'50'' |

## Vcho: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/Vcho
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L100_1000000/anchor/pe.anchor.fa \
    Q20L100_1500000/anchor/pe.anchor.fa \
    Q20L100_2000000/anchor/pe.anchor.fa \
    Q20L120_1000000/anchor/pe.anchor.fa \
    Q20L120_1500000/anchor/pe.anchor.fa \
    Q20L120_2000000/anchor/pe.anchor.fa \
    Q20L140_1000000/anchor/pe.anchor.fa \
    Q20L140_1500000/anchor/pe.anchor.fa \
    Q20L140_2000000/anchor/pe.anchor.fa \
    Q25L100_1000000/anchor/pe.anchor.fa \
    Q25L100_1500000/anchor/pe.anchor.fa \
    Q25L100_2000000/anchor/pe.anchor.fa \
    Q25L120_1000000/anchor/pe.anchor.fa \
    Q25L120_1500000/anchor/pe.anchor.fa \
    Q25L120_2000000/anchor/pe.anchor.fa \
    Q25L140_1000000/anchor/pe.anchor.fa \
    Q25L140_1500000/anchor/pe.anchor.fa \
    Q25L140_2000000/anchor/pe.anchor.fa \
    Q30L100_1000000/anchor/pe.anchor.fa \
    Q30L100_1500000/anchor/pe.anchor.fa \
    Q30L100_2000000/anchor/pe.anchor.fa \
    Q30L120_1000000/anchor/pe.anchor.fa \
    Q30L120_1500000/anchor/pe.anchor.fa \
    Q30L120_2000000/anchor/pe.anchor.fa \
    Q30L140_1000000/anchor/pe.anchor.fa \
    Q30L140_1500000/anchor/pe.anchor.fa \
    Q30L140_2000000/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
anchr contained \
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

| Name         |     N50 |     Sum |  # |
|:-------------|--------:|--------:|---:|
| Genome       | 2961149 | 4033464 |  2 |
| Paralogs     |    3483 |  114707 | 48 |
| anchor.merge |  121235 | 3898870 | 95 |
| others.merge |    1007 |   28703 | 28 |

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/Vcho
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```
