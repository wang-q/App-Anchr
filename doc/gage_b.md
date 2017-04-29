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
| Q20L100 | 393.34M |  72.4 |     230 |  127 | 334.79M |  14.884% | 5.43M | 5.35M |     0.98 | 5.55M |     0 | 0:05'07'' |
| Q20L120 | 379.81M |  69.9 |     233 |  127 | 323.97M |  14.702% | 5.43M | 5.35M |     0.98 | 5.54M |     0 | 0:05'08'' |
| Q20L140 | 363.98M |  67.0 |     237 |  127 | 311.42M |  14.441% | 5.43M | 5.34M |     0.98 | 5.52M |     0 | 0:04'34'' |
| Q25L100 | 360.85M |  66.4 |     225 |  127 | 324.86M |   9.974% | 5.43M | 5.34M |     0.98 | 5.45M |     0 | 0:04'35'' |
| Q25L120 | 346.62M |  63.8 |     229 |  127 | 312.31M |   9.897% | 5.43M | 5.34M |     0.98 | 5.44M |     0 | 0:04'43'' |
| Q25L140 | 329.43M |  60.6 |     234 |  127 | 297.14M |   9.803% | 5.43M | 5.34M |     0.98 | 5.43M |     0 | 0:04'36'' |
| Q30L100 | 310.66M |  57.2 |     218 |  127 | 291.08M |   6.302% | 5.43M | 5.34M |     0.98 | 5.42M |     0 | 0:04'12'' |
| Q30L120 | 295.47M |  54.4 |     222 |  127 | 276.77M |   6.329% | 5.43M | 5.33M |     0.98 | 5.41M |     0 | 0:04'04'' |
| Q30L140 |  275.6M |  50.7 |     227 |  127 | 258.02M |   6.377% | 5.43M | 5.33M |     0.98 | 5.41M |     0 | 0:03'49'' |

| Name    | N50SRclean |   Sum |    # | N50Anchor |   Sum |   # | N50Anchor2 |   Sum | # | N50Others |     Sum |    # |   RunTime |
|:--------|-----------:|------:|-----:|----------:|------:|----:|-----------:|------:|--:|----------:|--------:|-----:|----------:|
| Q20L100 |      14148 | 5.55M | 1576 |     15077 | 5.35M | 555 |          0 |     0 | 0 |       186 | 205.35K | 1021 | 0:01'26'' |
| Q20L120 |      14479 | 5.54M | 1476 |     15077 | 5.35M | 549 |          0 |     0 | 0 |       188 | 188.13K |  927 | 0:01'23'' |
| Q20L140 |      15074 | 5.52M | 1339 |     15661 | 5.35M | 539 |          0 |     0 | 0 |       202 | 167.32K |  800 | 0:01'17'' |
| Q25L100 |      17999 | 5.45M |  871 |     18301 | 5.35M | 459 |          0 |     0 | 0 |       253 |  98.16K |  412 | 0:01'10'' |
| Q25L120 |      17950 | 5.44M |  858 |     18144 | 5.34M | 464 |          0 |     0 | 0 |       253 |  97.31K |  394 | 0:01'16'' |
| Q25L140 |      18177 | 5.43M |  817 |     18428 | 5.34M | 462 |          0 |     0 | 0 |       253 |   91.1K |  355 | 0:01'16'' |
| Q30L100 |      17503 | 5.42M |  728 |     17743 | 5.34M | 469 |          0 |     0 | 0 |       359 |  74.11K |  259 | 0:01'15'' |
| Q30L120 |      17079 | 5.41M |  730 |     17467 | 5.34M | 482 |          0 |     0 | 0 |       398 |  74.82K |  248 | 0:01'09'' |
| Q30L140 |      15768 | 5.41M |  732 |     16128 | 5.34M | 499 |       1145 | 1.15K | 1 |       403 |  72.58K |  232 | 0:01'09'' |

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
| anchor.merge |   20352 | 5353315 | 402 |
| others.merge |    1145 |    1145 |   1 |

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
| Q20L100_500000  | 145.51M |  31.6 |     146 |   41 |  129.1M |  11.277% |  4.6M | 4.51M |     0.98 | 4.61M |     0 | 0:01'57'' |
| Q20L100_1000000 | 291.01M |  63.2 |     146 |   41 | 258.19M |  11.279% |  4.6M | 4.54M |     0.99 | 4.64M |     0 | 0:03'50'' |
| Q20L100_1500000 | 436.56M |  94.8 |     147 |   41 | 387.48M |  11.243% |  4.6M | 4.56M |     0.99 | 4.69M |     0 | 0:05'13'' |
| Q20L100_2000000 | 582.13M | 126.5 |     146 |   41 | 517.09M |  11.172% |  4.6M | 4.58M |     0.99 | 4.77M |     0 | 0:06'51'' |
| Q20L100_2500000 | 727.61M | 158.1 |     146 |   41 |  646.7M |  11.120% |  4.6M |  4.6M |     1.00 | 4.88M |     0 | 0:08'42'' |
| Q20L120_500000  | 153.11M |  33.3 |     153 |   45 | 135.13M |  11.742% |  4.6M | 4.45M |     0.97 | 4.57M |     0 | 0:02'16'' |
| Q20L120_1000000 | 306.23M |  66.5 |     153 |   45 | 270.57M |  11.644% |  4.6M | 4.52M |     0.98 | 4.63M |     0 | 0:04'14'' |
| Q20L120_1500000 |  459.3M |  99.8 |     154 |   45 | 405.98M |  11.608% |  4.6M | 4.54M |     0.99 | 4.69M |     0 | 0:05'38'' |
| Q20L120_2000000 | 612.37M | 133.0 |     154 |   45 | 541.67M |  11.544% |  4.6M | 4.57M |     0.99 | 4.78M |     0 | 0:07'31'' |
| Q20L120_2500000 | 765.52M | 166.3 |     153 |   45 | 677.68M |  11.474% |  4.6M | 4.59M |     1.00 |  4.9M |     0 | 0:09'38'' |
| Q20L140_500000  | 163.62M |  35.5 |     164 |   49 | 142.72M |  12.774% |  4.6M | 4.25M |     0.92 | 4.39M |     0 | 0:02'39'' |
| Q20L140_1000000 | 327.19M |  71.1 |     164 |   49 | 285.55M |  12.727% |  4.6M |  4.4M |     0.96 | 4.56M |     0 | 0:04'48'' |
| Q25L100_500000  | 137.14M |  29.8 |     138 |   39 | 130.77M |   4.644% |  4.6M | 4.48M |     0.97 | 4.59M |     0 | 0:02'33'' |
| Q25L100_1000000 | 274.33M |  59.6 |     138 |   39 | 261.64M |   4.628% |  4.6M | 4.53M |     0.98 | 4.62M |     0 | 0:03'47'' |
| Q25L100_1500000 | 411.44M |  89.4 |     138 |   39 | 392.39M |   4.628% |  4.6M | 4.54M |     0.99 | 4.63M |     0 | 0:05'17'' |
| Q25L100_2000000 | 548.54M | 119.2 |     138 |   39 | 523.13M |   4.632% |  4.6M | 4.54M |     0.99 | 4.64M |     0 | 0:06'47'' |
| Q25L100_2500000 | 685.76M | 149.0 |     138 |   39 | 654.08M |   4.621% |  4.6M | 4.55M |     0.99 | 4.65M |     0 | 0:08'41'' |
| Q25L120_500000  |  146.1M |  31.7 |     146 |   43 |  138.9M |   4.930% |  4.6M | 4.35M |     0.94 | 4.48M |     0 | 0:02'21'' |
| Q25L120_1000000 | 292.17M |  63.5 |     146 |   43 | 277.83M |   4.906% |  4.6M | 4.46M |     0.97 | 4.56M |     0 | 0:04'03'' |
| Q25L120_1500000 | 438.27M |  95.2 |     146 |   43 | 416.81M |   4.896% |  4.6M | 4.49M |     0.98 | 4.59M |     0 | 0:05'46'' |
| Q30L100_500000  | 125.63M |  27.3 |     126 |   37 | 122.51M |   2.485% |  4.6M | 4.35M |     0.95 |  4.5M |     0 | 0:02'12'' |
| Q30L100_1000000 | 251.29M |  54.6 |     126 |   37 | 245.17M |   2.433% |  4.6M | 4.47M |     0.97 | 4.58M |     0 | 0:02'47'' |
| Q30L100_1500000 | 376.89M |  81.9 |     126 |   37 | 367.77M |   2.419% |  4.6M |  4.5M |     0.98 | 4.61M |     0 | 0:03'35'' |

| Name            | N50SRclean |   Sum |    # | N50Anchor |   Sum |    # | N50Anchor2 |    Sum |  # | N50Others |     Sum |    # |   RunTime |
|:----------------|-----------:|------:|-----:|----------:|------:|-----:|-----------:|-------:|---:|----------:|--------:|-----:|----------:|
| Q20L100_500000  |       7886 | 4.61M | 2532 |      8390 | 4.33M |  757 |       1230 |   2.3K |  2 |       258 | 279.48K | 1773 | 0:01'26'' |
| Q20L100_1000000 |      11623 | 4.64M | 2360 |     12138 |  4.4M |  553 |          0 |      0 |  0 |       189 | 242.87K | 1807 | 0:01'44'' |
| Q20L100_1500000 |      10173 | 4.69M | 3100 |     11236 | 4.36M |  638 |          0 |      0 |  0 |       183 | 325.81K | 2462 | 0:02'37'' |
| Q20L100_2000000 |       6767 | 4.77M | 4570 |      7467 | 4.28M |  833 |          0 |      0 |  0 |       194 | 497.46K | 3737 | 0:02'41'' |
| Q20L100_2500000 |       4699 | 4.88M | 6567 |      5483 | 4.15M | 1040 |          0 |      0 |  0 |       197 | 736.06K | 5527 | 0:03'11'' |
| Q20L120_500000  |       5064 | 4.57M | 2849 |      5577 | 4.15M | 1002 |       1387 |  14.9K | 10 |       356 | 408.89K | 1837 | 0:01'18'' |
| Q20L120_1000000 |       7150 | 4.63M | 2491 |      7620 | 4.32M |  794 |       1130 |  3.45K |  3 |       290 |  299.3K | 1694 | 0:01'39'' |
| Q20L120_1500000 |       7624 | 4.69M | 3127 |      8343 | 4.31M |  776 |          0 |      0 |  0 |       257 | 371.91K | 2351 | 0:02'19'' |
| Q20L120_2000000 |       5698 | 4.78M | 4537 |      6457 | 4.22M |  908 |          0 |      0 |  0 |       260 | 557.37K | 3629 | 0:02'49'' |
| Q20L120_2500000 |       4177 |  4.9M | 6489 |      5063 |  4.1M | 1073 |       1195 |   1.2K |  1 |       236 | 799.18K | 5415 | 0:03'13'' |
| Q20L140_500000  |       2806 | 4.39M | 3844 |      3456 | 3.54M | 1218 |       1347 | 47.31K | 34 |       542 | 811.82K | 2592 | 0:01'19'' |
| Q20L140_1000000 |       3931 | 4.56M | 3545 |      4657 | 3.95M | 1123 |       1277 | 15.63K | 12 |       443 | 593.72K | 2410 | 0:01'24'' |
| Q25L100_500000  |       5925 | 4.59M | 2858 |      6365 | 4.22M |  908 |       1843 |  2.96K |  2 |       322 | 365.71K | 1948 | 0:01'05'' |
| Q25L100_1000000 |       9181 | 4.62M | 2389 |      9539 | 4.38M |  693 |       1145 |  1.15K |  1 |       211 | 232.96K | 1695 | 0:01'50'' |
| Q25L100_1500000 |      10071 | 4.63M | 2323 |     10573 | 4.41M |  607 |          0 |      0 |  0 |       183 | 221.84K | 1716 | 0:02'22'' |
| Q25L100_2000000 |      10636 | 4.64M | 2410 |     11381 | 4.41M |  587 |          0 |      0 |  0 |       176 | 231.34K | 1823 | 0:03'26'' |
| Q25L100_2500000 |      10590 | 4.65M | 2618 |     11436 | 4.39M |  592 |       1138 |  1.14K |  1 |       176 | 258.31K | 2025 | 0:03'22'' |
| Q25L120_500000  |       3570 | 4.48M | 3421 |      4211 | 3.85M | 1147 |       1247 | 15.17K | 12 |       483 | 609.47K | 2262 | 0:01'31'' |
| Q25L120_1000000 |       5643 | 4.56M | 2687 |      6084 | 4.17M |  937 |       1609 |   4.9K |  3 |       395 | 385.44K | 1747 | 0:01'30'' |
| Q25L120_1500000 |       6767 | 4.59M | 2478 |      7215 | 4.28M |  845 |       1578 |  2.91K |  2 |       334 | 311.25K | 1631 | 0:02'12'' |
| Q30L100_500000  |       3216 |  4.5M | 4080 |      3871 | 3.78M | 1216 |       1183 |   9.9K |  8 |       485 | 706.91K | 2856 | 0:01'03'' |
| Q30L100_1000000 |       5168 | 4.58M | 3173 |      5809 | 4.16M |  990 |       1099 |  3.82K |  3 |       359 | 414.47K | 2180 | 0:01'52'' |
| Q30L100_1500000 |       6633 | 4.61M | 2878 |      7037 | 4.28M |  872 |       1261 |  1.26K |  1 |       297 |  322.8K | 2005 | 0:01'52'' |

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
| anchor.merge |   26022 | 4492774 | 302 |
| others.merge |    1106 |   52424 |  45 |

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
| Q20L100_500000  | 174.96M |  34.4 |     174 |   49 | 137.05M |  21.667% | 5.09M | 5.16M |     1.01 | 5.27M |     0 | 0:02'13'' |
| Q20L100_1000000 | 349.97M |  68.7 |     175 |   49 | 274.77M |  21.486% | 5.09M | 5.27M |     1.04 | 5.56M |     0 | 0:04'06'' |
| Q20L100_1500000 | 524.92M | 103.1 |     174 |   49 | 411.63M |  21.582% | 5.09M | 5.31M |     1.04 | 5.54M |     0 | 0:06'01'' |
| Q20L100_2000000 | 699.77M | 137.5 |     175 |   49 | 549.28M |  21.506% | 5.09M | 5.38M |     1.06 | 5.78M |     0 | 0:08'01'' |
| Q20L100_2500000 | 874.71M | 171.8 |     175 |   49 | 691.83M |  20.908% | 5.09M | 5.62M |     1.10 | 7.13M |     0 | 0:09'27'' |
| Q20L120_500000  | 179.78M |  35.3 |     179 |   51 | 141.29M |  21.414% | 5.09M | 5.16M |     1.01 | 5.29M |     0 | 0:02'32'' |
| Q20L120_1000000 | 359.59M |  70.6 |     179 |   51 | 283.43M |  21.179% | 5.09M | 5.28M |     1.04 | 5.63M |     0 | 0:04'26'' |
| Q20L120_1500000 | 539.45M | 106.0 |     179 |   51 | 424.19M |  21.365% | 5.09M | 5.32M |     1.04 | 5.57M |     0 | 0:06'11'' |
| Q20L120_2000000 | 719.16M | 141.3 |     179 |   51 | 566.29M |  21.257% | 5.09M |  5.4M |     1.06 | 5.84M |     0 | 0:08'01'' |
| Q20L120_2500000 | 898.84M | 176.6 |     179 |   51 | 713.58M |  20.611% | 5.09M | 5.65M |     1.11 | 7.35M |     0 | 0:10'07'' |
| Q20L140_500000  | 186.63M |  36.7 |     186 |   53 | 146.54M |  21.481% | 5.09M | 5.13M |     1.01 | 5.29M |     0 | 0:02'20'' |
| Q20L140_1000000 | 373.19M |  73.3 |     186 |   53 | 293.99M |  21.222% | 5.09M | 5.28M |     1.04 | 5.69M |     0 | 0:04'52'' |
| Q20L140_1500000 | 559.88M | 110.0 |     186 |   53 | 439.96M |  21.419% | 5.09M | 5.33M |     1.05 | 5.62M |     0 | 0:06'30'' |
| Q20L140_2000000 | 746.49M | 146.6 |     186 |   53 | 587.46M |  21.303% | 5.09M | 5.42M |     1.06 | 5.93M |     0 | 0:08'29'' |
| Q25L100_500000  | 170.61M |  33.5 |     170 |   47 |  142.6M |  16.422% | 5.09M | 5.16M |     1.01 | 5.25M |     0 | 0:02'20'' |
| Q25L100_1000000 | 341.34M |  67.1 |     170 |   47 |    285M |  16.506% | 5.09M | 5.24M |     1.03 | 5.34M |     0 | 0:04'18'' |
| Q25L100_1500000 | 511.87M | 100.6 |     171 |   47 | 427.93M |  16.399% | 5.09M |  5.3M |     1.04 | 5.49M |     0 | 0:06'01'' |
| Q25L100_2000000 | 682.54M | 134.1 |     171 |   47 | 571.06M |  16.333% | 5.09M | 5.37M |     1.06 | 5.68M |     0 | 0:07'56'' |
| Q25L100_2500000 |  853.2M | 167.6 |     171 |   47 | 714.47M |  16.260% | 5.09M | 5.43M |     1.07 | 5.88M |     0 | 0:09'57'' |
| Q25L120_500000  | 176.23M |  34.6 |     176 |   49 | 147.42M |  16.351% | 5.09M | 5.14M |     1.01 | 5.27M |     0 | 0:02'24'' |
| Q25L120_1000000 | 352.34M |  69.2 |     176 |   49 | 294.31M |  16.472% | 5.09M | 5.24M |     1.03 | 5.35M |     0 | 0:04'25'' |
| Q25L120_1500000 | 528.65M | 103.8 |     177 |   49 | 442.19M |  16.355% | 5.09M | 5.31M |     1.04 | 5.52M |     0 | 0:06'24'' |
| Q25L120_2000000 | 704.84M | 138.5 |     176 |   51 |  590.2M |  16.265% | 5.09M | 5.38M |     1.06 | 5.75M |     0 | 0:08'08'' |
| Q25L140_500000  | 183.57M |  36.1 |     183 |   53 | 153.27M |  16.504% | 5.09M | 5.11M |     1.00 | 5.28M |     0 | 0:02'39'' |
| Q25L140_1000000 | 367.17M |  72.1 |     184 |   53 | 306.09M |  16.634% | 5.09M | 5.24M |     1.03 |  5.4M |     0 | 0:04'26'' |
| Q25L140_1500000 | 550.77M | 108.2 |     184 |   53 | 459.72M |  16.532% | 5.09M | 5.32M |     1.05 |  5.6M |     0 | 0:06'16'' |
| Q25L140_2000000 | 680.19M | 133.6 |     183 |   53 | 568.25M |  16.458% | 5.09M | 5.38M |     1.06 | 5.77M |     0 | 0:07'58'' |
| Q30L100_500000  | 163.94M |  32.2 |     163 |   45 | 142.61M |  13.014% | 5.09M | 5.14M |     1.01 | 5.25M |     0 | 0:02'32'' |
| Q30L100_1000000 | 327.94M |  64.4 |     164 |   45 | 285.22M |  13.026% | 5.09M | 5.23M |     1.03 | 5.34M |     0 | 0:04'05'' |
| Q30L100_1500000 | 491.89M |  96.6 |     164 |   45 | 428.12M |  12.964% | 5.09M |  5.3M |     1.04 | 5.48M |     0 | 0:05'53'' |
| Q30L100_2000000 | 655.83M | 128.8 |     164 |   45 | 571.23M |  12.899% | 5.09M | 5.36M |     1.05 | 5.63M |     0 | 0:07'05'' |
| Q30L120_500000  | 170.77M |  33.5 |     170 |   49 | 148.46M |  13.067% | 5.09M | 5.12M |     1.01 | 5.26M |     0 | 0:02'31'' |
| Q30L120_1000000 | 341.56M |  67.1 |     171 |   49 | 296.71M |  13.131% | 5.09M | 5.24M |     1.03 | 5.38M |     0 | 0:04'24'' |
| Q30L120_1500000 |  512.3M | 100.6 |     170 |   49 | 445.37M |  13.065% | 5.09M | 5.31M |     1.04 | 5.53M |     0 | 0:06'05'' |
| Q30L140_500000  | 179.02M |  35.2 |     179 |   53 | 155.08M |  13.376% | 5.09M | 5.07M |     1.00 | 5.28M |     0 | 0:02'24'' |
| Q30L140_1000000 | 358.03M |  70.3 |     179 |   53 | 309.81M |  13.468% | 5.09M | 5.22M |     1.03 | 5.41M |     0 | 0:03'45'' |

| Name            | N50SRclean |   Sum |     # | N50Anchor |   Sum |    # | N50Anchor2 |    Sum |  # | N50Others |     Sum |     # |   RunTime |
|:----------------|-----------:|------:|------:|----------:|------:|-----:|-----------:|-------:|---:|----------:|--------:|------:|----------:|
| Q20L100_500000  |       7201 | 5.27M |  2320 |      7694 | 4.99M |  908 |       1330 | 21.71K | 15 |       282 | 264.25K |  1397 | 0:01'29'' |
| Q20L100_1000000 |       3094 | 5.56M |  5933 |      3672 | 4.71M | 1579 |       1516 |  9.15K |  6 |       353 | 842.93K |  4348 | 0:02'12'' |
| Q20L100_1500000 |       4254 | 5.54M |  4946 |      4852 | 4.89M | 1304 |       1262 |  2.43K |  2 |       227 | 640.93K |  3640 | 0:02'34'' |
| Q20L100_2000000 |       2423 | 5.78M |  8313 |      3052 | 4.51M | 1740 |       1470 |  7.34K |  5 |       338 |   1.26M |  6568 | 0:02'49'' |
| Q20L100_2500000 |        487 | 7.13M | 29768 |      1393 | 1.49M | 1047 |       1165 |  9.63K |  8 |       355 |   5.63M | 28713 | 0:03'01'' |
| Q20L120_500000  |       5068 | 5.29M |  2872 |      5481 |  4.9M | 1197 |       1348 | 22.77K | 16 |       386 | 364.35K |  1659 | 0:01'27'' |
| Q20L120_1000000 |       2638 | 5.63M |  6773 |      3161 | 4.52M | 1668 |       1576 | 28.97K | 19 |       414 |   1.07M |  5086 | 0:01'54'' |
| Q20L120_1500000 |       4140 | 5.57M |  5175 |      4656 | 4.87M | 1339 |       1644 |  7.94K |  5 |       225 | 683.58K |  3831 | 0:03'01'' |
| Q20L120_2000000 |       2209 | 5.84M |  8884 |      2894 |  4.4M | 1766 |       1342 | 16.94K | 13 |       353 |   1.42M |  7105 | 0:02'45'' |
| Q20L120_2500000 |        437 | 7.35M | 32057 |      1331 | 1.28M |  930 |       1148 | 13.41K | 11 |       334 |   6.06M | 31116 | 0:02'41'' |
| Q20L140_500000  |       3750 | 5.29M |  3489 |      4160 | 4.68M | 1384 |       1494 | 59.78K | 38 |       519 | 550.86K |  2067 | 0:01'17'' |
| Q20L140_1000000 |       2151 | 5.69M |  7752 |      2769 | 4.29M | 1756 |       1548 | 65.45K | 42 |       445 |   1.34M |  5954 | 0:02'09'' |
| Q20L140_1500000 |       3358 | 5.62M |  5891 |      3992 | 4.73M | 1487 |       1498 | 23.99K | 15 |       276 | 864.14K |  4389 | 0:02'29'' |
| Q20L140_2000000 |       1873 | 5.93M |  9848 |      2553 | 4.21M | 1848 |       1334 | 25.96K | 17 |       383 |   1.69M |  7983 | 0:02'56'' |
| Q25L100_500000  |       6925 | 5.25M |  2325 |      7350 | 4.97M |  971 |       1465 | 17.36K | 12 |       295 | 265.49K |  1342 | 0:01'23'' |
| Q25L100_1000000 |       9774 | 5.34M |  2411 |     10195 | 5.07M |  717 |          0 |      0 |  0 |       189 | 268.07K |  1694 | 0:02'04'' |
| Q25L100_1500000 |       4977 | 5.49M |  4259 |      5431 | 4.96M | 1193 |       1466 |  2.64K |  2 |       216 | 527.32K |  3064 | 0:02'28'' |
| Q25L100_2000000 |       2960 | 5.68M |  6893 |      3555 | 4.68M | 1601 |       1388 |  2.46K |  2 |       290 | 996.09K |  5290 | 0:03'21'' |
| Q25L100_2500000 |       1898 | 5.88M |  9859 |      2587 | 4.26M | 1860 |       1130 |  1.13K |  1 |       400 |   1.62M |  7998 | 0:03'32'' |
| Q25L120_500000  |       4775 | 5.27M |  2947 |      5068 | 4.85M | 1211 |       1324 | 21.97K | 16 |       453 | 399.03K |  1720 | 0:01'30'' |
| Q25L120_1000000 |       8009 | 5.35M |  2698 |      8391 | 5.02M |  855 |       1226 |  4.04K |  3 |       211 | 330.41K |  1840 | 0:01'58'' |
| Q25L120_1500000 |       4283 | 5.52M |  4671 |      4794 |  4.9M | 1290 |       1397 |  2.47K |  2 |       230 | 619.71K |  3379 | 0:02'34'' |
| Q25L120_2000000 |       2613 | 5.75M |  7494 |      3233 | 4.58M | 1691 |       1188 |  12.1K | 10 |       319 |   1.15M |  5793 | 0:03'05'' |
| Q25L140_500000  |       3061 | 5.28M |  3953 |      3593 | 4.52M | 1514 |       1436 | 64.67K | 44 |       550 | 695.08K |  2395 | 0:01'29'' |
| Q25L140_1000000 |       5013 |  5.4M |  3514 |      5486 |  4.9M | 1166 |       1450 | 13.11K |  9 |       263 | 487.98K |  2339 | 0:01'57'' |
| Q25L140_1500000 |       3219 |  5.6M |  5645 |      3760 | 4.73M | 1517 |       1574 | 24.94K | 17 |       297 | 837.93K |  4111 | 0:02'27'' |
| Q25L140_2000000 |       2365 | 5.77M |  7714 |      3024 | 4.48M | 1739 |       1331 | 30.97K | 23 |       355 |   1.25M |  5952 | 0:02'51'' |
| Q30L100_500000  |       5811 | 5.25M |  2626 |      6173 |  4.9M | 1070 |       1773 | 17.53K | 10 |       416 | 336.87K |  1546 | 0:01'33'' |
| Q30L100_1000000 |       7903 | 5.34M |  2674 |      8417 | 5.03M |  839 |       1453 |   4.6K |  3 |       199 | 304.78K |  1832 | 0:02'05'' |
| Q30L100_1500000 |       4900 | 5.48M |  4201 |      5329 | 4.96M | 1180 |       1391 |  1.39K |  1 |       211 | 515.89K |  3020 | 0:02'49'' |
| Q30L100_2000000 |       3111 | 5.63M |  6492 |      3628 | 4.71M | 1574 |       1221 |  4.48K |  3 |       280 |    916K |  4915 | 0:03'15'' |
| Q30L120_500000  |       3670 | 5.26M |  3419 |      4134 | 4.69M | 1393 |       1466 | 46.58K | 32 |       490 |  523.6K |  1994 | 0:01'34'' |
| Q30L120_1000000 |       5641 | 5.38M |  3268 |      6112 | 4.95M | 1087 |       1402 | 14.47K | 10 |       219 | 407.42K |  2171 | 0:02'09'' |
| Q30L120_1500000 |       3940 | 5.53M |  4958 |      4523 | 4.83M | 1353 |       1245 | 12.69K |  9 |       250 | 687.31K |  3596 | 0:02'37'' |
| Q30L140_500000  |       2377 | 5.28M |  4819 |      2973 | 4.19M | 1634 |       1437 |  75.9K | 53 |       578 |   1.01M |  3132 | 0:01'20'' |
| Q30L140_1000000 |       3757 | 5.41M |  4211 |      4205 | 4.72M | 1394 |       1459 |  30.7K | 21 |       379 | 658.61K |  2796 | 0:01'48'' |

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
| anchor.merge |   71152 | 5202771 | 140 |
| others.merge |    1226 |  248323 | 191 |

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
| Q20L100_500000  |  186.1M |  46.1 |     186 |  113 |    150M |  19.400% | 4.03M | 3.94M |     0.98 | 4.19M |     0 | 0:02'12'' |
| Q20L100_1000000 |  372.2M |  92.3 |     186 |  113 | 300.13M |  19.364% | 4.03M | 3.98M |     0.99 | 4.31M |     0 | 0:04'00'' |
| Q20L100_1500000 | 558.38M | 138.4 |     186 |  113 | 450.91M |  19.248% | 4.03M | 4.04M |     1.00 | 4.61M |     0 | 0:05'54'' |
| Q20L100_2000000 | 744.46M | 184.6 |     186 |  113 | 604.15M |  18.846% | 4.03M | 4.19M |     1.04 | 5.76M |     0 | 0:07'42'' |
| Q20L100_2500000 | 930.67M | 230.7 |     187 |  113 | 756.52M |  18.713% | 4.03M | 4.33M |     1.07 | 6.58M |     0 | 0:10'03'' |
| Q20L120_500000  | 188.54M |  46.7 |     188 |  115 | 152.72M |  18.998% | 4.03M | 3.94M |     0.98 | 4.21M |     0 | 0:02'17'' |
| Q20L120_1000000 | 376.99M |  93.5 |     188 |  115 | 305.12M |  19.065% | 4.03M | 3.99M |     0.99 | 4.32M |     0 | 0:04'13'' |
| Q20L120_1500000 | 565.29M | 140.1 |     189 |  115 | 458.71M |  18.853% | 4.03M | 4.05M |     1.00 | 4.64M |     0 | 0:05'45'' |
| Q20L120_2000000 |  753.8M | 186.9 |     189 |  115 | 612.09M |  18.799% | 4.03M | 4.13M |     1.02 | 5.08M |     0 | 0:07'57'' |
| Q20L120_2500000 | 942.27M | 233.6 |     188 |  115 | 769.39M |  18.347% | 4.03M | 4.35M |     1.08 | 6.67M |     0 | 0:09'49'' |
| Q20L140_500000  | 192.86M |  47.8 |     193 |  119 | 156.81M |  18.693% | 4.03M | 3.94M |     0.98 | 4.24M |     0 | 0:02'20'' |
| Q20L140_1000000 | 385.48M |  95.6 |     193 |  119 | 313.22M |  18.745% | 4.03M | 3.99M |     0.99 | 4.34M |     0 | 0:04'07'' |
| Q20L140_1500000 | 578.33M | 143.4 |     193 |  119 | 470.53M |  18.640% | 4.03M | 4.06M |     1.01 | 4.71M |     0 | 0:05'59'' |
| Q20L140_2000000 | 771.16M | 191.2 |     193 |  119 |  628.3M |  18.525% | 4.03M | 4.16M |     1.03 | 5.14M |     0 | 0:08'09'' |
| Q20L140_2500000 | 963.94M | 239.0 |     193 |  119 | 789.86M |  18.059% | 4.03M | 4.36M |     1.08 | 6.82M |     0 | 0:09'45'' |
| Q25L100_500000  | 182.93M |  45.4 |     183 |  111 | 155.44M |  15.025% | 4.03M | 3.94M |     0.98 |  4.2M |     0 | 0:02'26'' |
| Q25L100_1000000 | 365.95M |  90.7 |     183 |  111 |    311M |  15.017% | 4.03M | 3.98M |     0.99 | 4.28M |     0 | 0:04'20'' |
| Q25L100_1500000 | 548.86M | 136.1 |     183 |  111 | 467.06M |  14.903% | 4.03M | 4.02M |     1.00 | 4.52M |     0 | 0:05'53'' |
| Q25L100_2000000 | 731.98M | 181.5 |     184 |  111 | 623.43M |  14.829% | 4.03M | 4.08M |     1.01 | 4.84M |     0 | 0:07'49'' |
| Q25L100_2500000 | 914.97M | 226.8 |     184 |  111 | 780.09M |  14.742% | 4.03M | 4.19M |     1.04 | 5.27M |     0 | 0:09'53'' |
| Q25L120_500000  | 185.77M |  46.1 |     185 |  113 | 158.38M |  14.747% | 4.03M | 3.94M |     0.98 | 4.21M |     0 | 0:02'29'' |
| Q25L120_1000000 | 371.73M |  92.2 |     186 |  113 | 316.57M |  14.837% | 4.03M | 3.97M |     0.99 | 4.29M |     0 | 0:04'22'' |
| Q25L120_1500000 | 557.44M | 138.2 |     186 |  113 | 475.27M |  14.740% | 4.03M | 4.03M |     1.00 | 4.56M |     0 | 0:06'02'' |
| Q25L120_2000000 |  743.3M | 184.3 |     186 |  113 | 634.49M |  14.639% | 4.03M |  4.1M |     1.02 | 4.91M |     0 | 0:07'52'' |
| Q25L120_2500000 | 929.12M | 230.4 |     186 |  115 | 793.87M |  14.556% | 4.03M |  4.2M |     1.04 | 5.36M |     0 | 0:09'39'' |
| Q25L140_500000  | 190.69M |  47.3 |     190 |  117 | 162.61M |  14.724% | 4.03M | 3.94M |     0.98 | 4.22M |     0 | 0:02'28'' |
| Q25L140_1000000 | 381.26M |  94.5 |     190 |  117 | 325.13M |  14.722% | 4.03M | 3.98M |     0.99 | 4.32M |     0 | 0:04'23'' |
| Q25L140_1500000 | 571.92M | 141.8 |     190 |  117 | 487.99M |  14.676% | 4.03M | 4.05M |     1.00 | 4.63M |     0 | 0:06'14'' |
| Q25L140_2000000 | 762.41M | 189.0 |     190 |  117 | 651.52M |  14.545% | 4.03M | 4.13M |     1.02 | 5.02M |     0 | 0:08'00'' |
| Q25L140_2500000 | 922.96M | 228.8 |     191 |  117 | 789.42M |  14.469% | 4.03M | 4.21M |     1.04 | 5.41M |     0 | 0:09'49'' |
| Q30L100_500000  | 177.61M |  44.0 |     178 |  107 | 156.93M |  11.645% | 4.03M | 3.94M |     0.98 | 4.17M |     0 | 0:02'13'' |
| Q30L100_1000000 | 355.17M |  88.1 |     177 |  107 | 313.66M |  11.687% | 4.03M | 3.96M |     0.98 | 4.23M |     0 | 0:04'08'' |
| Q30L100_1500000 | 532.91M | 132.1 |     178 |  107 | 471.02M |  11.613% | 4.03M |    4M |     0.99 | 4.44M |     0 | 0:05'49'' |
| Q30L100_2000000 | 710.47M | 176.1 |     178 |  109 | 628.46M |  11.544% | 4.03M | 4.04M |     1.00 | 4.72M |     0 | 0:07'44'' |
| Q30L100_2500000 | 888.14M | 220.2 |     179 |  109 | 786.35M |  11.462% | 4.03M | 4.11M |     1.02 | 5.08M |     0 | 0:09'26'' |
| Q30L120_500000  | 181.34M |  45.0 |     181 |  111 |  160.2M |  11.658% | 4.03M | 3.94M |     0.98 |  4.2M |     0 | 0:02'22'' |
| Q30L120_1000000 |  362.7M |  89.9 |     182 |  111 | 320.39M |  11.665% | 4.03M | 3.96M |     0.98 | 4.28M |     0 | 0:04'11'' |
| Q30L120_1500000 |    544M | 134.9 |     181 |  111 | 480.83M |  11.612% | 4.03M |    4M |     0.99 | 4.49M |     0 | 0:06'04'' |
| Q30L120_2000000 | 725.38M | 179.8 |     182 |  111 | 641.52M |  11.560% | 4.03M | 4.06M |     1.01 | 4.82M |     0 | 0:07'47'' |
| Q30L140_500000  | 186.98M |  46.4 |     186 |  115 | 164.71M |  11.906% | 4.03M | 3.93M |     0.97 | 4.16M |     0 | 0:02'31'' |
| Q30L140_1000000 | 373.87M |  92.7 |     187 |  115 | 329.73M |  11.807% | 4.03M | 3.97M |     0.98 | 4.34M |     0 | 0:04'35'' |
| Q30L140_1500000 | 560.86M | 139.1 |     187 |  115 | 494.78M |  11.782% | 4.03M | 4.01M |     1.00 | 4.58M |     0 | 0:05'22'' |
| Q30L140_2000000 | 732.71M | 181.7 |     187 |  115 |  647.1M |  11.684% | 4.03M | 4.07M |     1.01 | 4.91M |     0 | 0:04'45'' |

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
| anchor.merge |  110342 | 3927263 | 113 |
| others.merge |    1030 |   48393 |  42 |
