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
* len: 60 and 100

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
    " ::: 20 25 30 ::: 60 90

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
    for len in 60 90; do
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
| Q20L60   |     250 | 413488810 | 1820024 |
| Q20L90   |     250 | 398946475 | 1722398 |
| Q25L60   |     250 | 381704669 | 1713606 |
| Q25L90   |     250 | 366583021 | 1609962 |
| Q30L60   |     250 | 331980264 | 1545604 |
| Q30L90   |     250 | 316467938 | 1436324 |

## Bcer: down sampling

```bash
BASE_DIR=$HOME/data/anchr/Bcer
cd ${BASE_DIR}

ARRAY=(
    "2_illumina/Q20L60:Q20L60"
    "2_illumina/Q20L90:Q20L90"
    "2_illumina/Q25L60:Q25L60"
    "2_illumina/Q25L90:Q25L90"
    "2_illumina/Q30L60:Q30L60"
    "2_illumina/Q30L90:Q30L90"
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
        Q20L60 Q20L90
        Q25L60 Q25L90
        Q30L60 Q30L90
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
            --kmer 41,61,81,101,121 \
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
        Q20L60 Q20L90
        Q25L60 Q25L90
        Q30L60 Q30L90
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
        Q20L60 Q20L90
        Q25L60 Q25L90
        Q30L60 Q30L90
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
        Q20L60 Q20L90
        Q25L60 Q25L90
        Q30L60 Q30L90
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

| Name   |   SumFq | CovFq | AvgRead |               Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:-------|--------:|------:|--------:|-------------------:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| Q20L60 | 413.49M |  76.1 |     224 | "41,61,81,101,121" |  351.4M |  15.015% | 5.43M | 5.36M |     0.99 | 5.37M |     0 | 0:07'15'' |
| Q20L90 | 398.95M |  73.4 |     228 | "41,61,81,101,121" | 339.36M |  14.937% | 5.43M | 5.35M |     0.99 | 5.37M |     0 | 0:07'09'' |
| Q25L60 |  381.7M |  70.3 |     218 | "41,61,81,101,121" | 343.46M |  10.018% | 5.43M | 5.34M |     0.98 | 5.36M |     0 | 0:06'54'' |
| Q25L90 | 366.58M |  67.5 |     224 | "41,61,81,101,121" | 329.96M |   9.990% | 5.43M | 5.34M |     0.98 | 5.37M |     0 | 0:06'41'' |
| Q30L60 | 331.98M |  61.1 |     210 | "41,61,81,101,121" | 311.18M |   6.264% | 5.43M | 5.34M |     0.98 | 5.37M |     0 | 0:06'24'' |
| Q30L90 | 316.47M |  58.3 |     216 | "41,61,81,101,121" | 296.55M |   6.293% | 5.43M | 5.34M |     0.98 | 5.37M |     0 | 0:06'12'' |

| Name   | N50SR |   Sum |   # | N50Anchor |   Sum |   # | N50Others |    Sum |  # |   RunTime |
|:-------|------:|------:|----:|----------:|------:|----:|----------:|-------:|---:|----------:|
| Q20L60 | 22373 | 5.37M | 423 |     22373 | 5.35M | 389 |       791 | 25.36K | 34 | 0:01'29'' |
| Q20L90 | 22940 | 5.37M | 405 |     22940 | 5.34M | 372 |       783 | 24.42K | 33 | 0:01'35'' |
| Q25L60 | 40740 | 5.36M | 264 |     40740 | 5.34M | 243 |       713 |  14.2K | 21 | 0:01'40'' |
| Q25L90 | 37659 | 5.37M | 263 |     37680 | 5.35M | 243 |       866 | 20.13K | 20 | 0:01'35'' |
| Q30L60 | 43309 | 5.37M | 249 |     43309 | 5.32M | 222 |     16148 | 49.45K | 27 | 0:01'38'' |
| Q30L90 | 41518 | 5.37M | 252 |     41518 | 5.32M | 228 |     16148 | 47.32K | 24 | 0:01'34'' |

## Bcer: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/Bcer
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L60/anchor/pe.anchor.fa \
    Q20L90/anchor/pe.anchor.fa \
    Q25L60/anchor/pe.anchor.fa \
    Q25L90/anchor/pe.anchor.fa \
    Q30L60/anchor/pe.anchor.fa \
    Q30L90/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
anchr contained \
    Q20L60/anchor/pe.others.fa \
    Q20L90/anchor/pe.others.fa \
    Q25L60/anchor/pe.others.fa \
    Q25L90/anchor/pe.others.fa \
    Q30L60/anchor/pe.others.fa \
    Q30L90/anchor/pe.others.fa \
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
    1_genome/paralogs.fas \
    --label "abyss,soap,spades,velvet,merge,paralogs" \
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
| anchor.merge |   46191 | 5346983 | 206 |
| others.merge |   16206 |   25554 |   4 |

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
* len: 60 and 100

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
    " ::: 20 25 30 ::: 60 90

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
    for len in 60 90; do
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
| Q20L60   |     145 | 1633021051 | 12002574 |
| Q20L90   |     148 | 1411368270 |  9895408 |
| Q25L60   |     134 | 1357466274 | 10772280 |
| Q25L90   |     137 | 1097218003 |  8205020 |
| Q30L60   |     118 |  956403913 |  8625458 |
| Q30L90   |     123 |  622670075 |  5139530 |

## Rsph: down sampling

```bash
BASE_DIR=$HOME/data/anchr/Rsph
cd ${BASE_DIR}

ARRAY=(
    "2_illumina/Q20L60:Q20L60:5000000"
    "2_illumina/Q20L90:Q20L90:4000000"
    "2_illumina/Q25L60:Q25L60:5000000"
    "2_illumina/Q25L90:Q25L90:4000000"
    "2_illumina/Q30L60:Q30L60:4000000"
    "2_illumina/Q30L90:Q30L90:2000000"
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

## Rsph: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/Rsph
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L60 Q20L90
        Q25L60 Q25L90
        Q30L60 Q30L90
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
            --kmer 41,61,81,101,121 \
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
        Q20L60 Q20L90
        Q25L60 Q25L90
        Q30L60 Q30L90
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
        Q20L60 Q20L90
        Q25L60 Q25L90
        Q30L60 Q30L90
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
BASE_DIR=$HOME/data/anchr/Rsph
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

perl -e '
    for my $n (
        qw{
        Q20L60 Q20L90
        Q25L60 Q25L90
        Q30L60 Q30L90
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

| Name           |   SumFq | CovFq | AvgRead |               Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:---------------|--------:|------:|--------:|-------------------:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| Q20L60_1000000 | 272.07M |  59.1 |     137 | "41,61,81,101,121" | 241.69M |  11.164% |  4.6M | 4.56M |     0.99 | 4.58M |     0 | 0:04'43'' |
| Q20L60_2000000 | 544.25M | 118.2 |     137 | "41,61,81,101,121" | 484.24M |  11.026% |  4.6M | 4.58M |     1.00 | 4.61M |     0 | 0:07'39'' |
| Q20L60_3000000 | 816.38M | 177.4 |     137 | "41,61,81,101,121" | 727.37M |  10.903% |  4.6M | 4.63M |     1.01 | 4.65M |     0 | 0:10'30'' |
| Q20L60_4000000 |   1.09G | 236.5 |     137 | "41,61,81,101,121" | 971.18M |  10.775% |  4.6M |  4.7M |     1.02 | 4.64M |     0 | 0:13'22'' |
| Q20L60_5000000 |   1.36G | 295.6 |     137 | "41,61,81,101,121" |   1.22G |  10.673% |  4.6M | 4.78M |     1.04 |  4.6M |     0 | 0:16'27'' |
| Q20L90_1000000 | 285.26M |  62.0 |     143 | "41,61,81,101,121" | 253.32M |  11.197% |  4.6M | 4.55M |     0.99 | 4.58M |     0 | 0:05'13'' |
| Q20L90_2000000 | 570.42M | 123.9 |     144 | "41,61,81,101,121" | 507.15M |  11.093% |  4.6M | 4.58M |     1.00 | 4.61M |     0 | 0:08'10'' |
| Q20L90_3000000 | 855.74M | 185.9 |     143 | "41,61,81,101,121" | 761.71M |  10.988% |  4.6M | 4.63M |     1.01 | 4.64M |     0 | 0:10'55'' |
| Q20L90_4000000 |   1.14G | 247.9 |     143 | "41,61,81,101,121" |   1.02G |  10.861% |  4.6M |  4.7M |     1.02 | 4.62M |     0 | 0:14'03'' |
| Q25L60_1000000 | 252.05M |  54.8 |     127 | "41,61,81,101,121" | 240.65M |   4.523% |  4.6M | 4.55M |     0.99 | 4.57M |     0 | 0:04'31'' |
| Q25L60_2000000 | 504.03M | 109.5 |     127 | "41,61,81,101,121" | 481.31M |   4.507% |  4.6M | 4.56M |     0.99 | 4.58M |     0 | 0:07'16'' |
| Q25L60_3000000 | 756.14M | 164.3 |     127 | "41,61,81,101,121" | 722.22M |   4.486% |  4.6M | 4.56M |     0.99 | 4.58M |     0 | 0:10'29'' |
| Q25L60_4000000 |   1.01G | 219.0 |     128 | "41,61,81,101,121" | 963.07M |   4.469% |  4.6M | 4.57M |     0.99 |  4.6M |     0 | 0:12'52'' |
| Q25L60_5000000 |   1.26G | 273.8 |     127 | "41,61,81,101,121" |    1.2G |   4.453% |  4.6M | 4.58M |     1.00 | 4.61M |     0 | 0:15'07'' |
| Q25L90_1000000 | 267.45M |  58.1 |     135 | "41,61,81,101,121" | 255.12M |   4.610% |  4.6M | 4.53M |     0.99 | 4.55M |     0 | 0:04'59'' |
| Q25L90_2000000 |  534.9M | 116.2 |     134 | "41,61,81,101,121" | 510.39M |   4.581% |  4.6M | 4.55M |     0.99 | 4.57M |     0 | 0:08'02'' |
| Q25L90_3000000 | 802.36M | 174.3 |     135 | "41,61,81,101,121" | 765.77M |   4.560% |  4.6M | 4.56M |     0.99 | 4.59M |     0 | 0:10'41'' |
| Q25L90_4000000 |   1.07G | 232.4 |     134 | "41,61,81,101,121" |   1.02G |   4.542% |  4.6M | 4.57M |     0.99 |  4.6M |     0 | 0:13'05'' |
| Q30L60_1000000 | 221.77M |  48.2 |     112 | "41,61,81,101,121" | 216.82M |   2.231% |  4.6M | 4.53M |     0.99 | 4.53M |     0 | 0:04'08'' |
| Q30L60_2000000 | 443.56M |  96.4 |     112 | "41,61,81,101,121" | 433.61M |   2.243% |  4.6M | 4.55M |     0.99 | 4.56M |     0 | 0:06'02'' |
| Q30L60_3000000 | 665.33M | 144.5 |     112 | "41,61,81,101,121" | 650.33M |   2.254% |  4.6M | 4.55M |     0.99 | 4.57M |     0 | 0:08'21'' |
| Q30L60_4000000 | 887.07M | 192.7 |     112 | "41,61,81,101,121" | 867.07M |   2.255% |  4.6M | 4.55M |     0.99 | 4.58M |     0 | 0:10'33'' |
| Q30L90_1000000 | 242.34M |  52.6 |     122 | "41,61,81,101,121" |  236.6M |   2.369% |  4.6M |  4.5M |     0.98 | 4.48M |     0 | 0:04'15'' |
| Q30L90_2000000 | 484.58M | 105.3 |     121 | "41,61,81,101,121" | 473.16M |   2.358% |  4.6M | 4.53M |     0.98 | 4.54M |     0 | 0:06'48'' |

| Name           | N50SR |   Sum |    # | N50Anchor |   Sum |    # | N50Others |     Sum |   # |   RunTime |
|:---------------|------:|------:|-----:|----------:|------:|-----:|----------:|--------:|----:|----------:|
| Q20L60_1000000 | 21878 | 4.58M |  400 |     21878 | 4.55M |  357 |       710 |  30.18K |  43 | 0:02'31'' |
| Q20L60_2000000 | 15564 | 4.61M |  615 |     15968 | 4.53M |  491 |       761 |  89.21K | 124 | 0:03'33'' |
| Q20L60_3000000 |  7754 | 4.65M | 1160 |      8071 | 4.42M |  850 |       755 | 226.22K | 310 | 0:04'37'' |
| Q20L60_4000000 |  3995 | 4.64M | 1808 |      4306 | 4.24M | 1262 |       759 | 396.37K | 546 | 0:04'16'' |
| Q20L60_5000000 |  2434 |  4.6M | 2521 |      2854 | 3.92M | 1583 |       763 | 685.65K | 938 | 0:05'24'' |
| Q20L90_1000000 | 17854 | 4.58M |  478 |     19181 | 4.52M |  404 |       757 |  53.87K |  74 | 0:02'15'' |
| Q20L90_2000000 | 11865 | 4.61M |  745 |     12217 | 4.49M |  589 |       743 | 113.86K | 156 | 0:03'13'' |
| Q20L90_3000000 |  6200 | 4.64M | 1338 |      6468 | 4.39M |  990 |       743 | 248.84K | 348 | 0:04'00'' |
| Q20L90_4000000 |  3322 | 4.62M | 2080 |      3700 | 4.13M | 1408 |       745 | 485.76K | 672 | 0:04'19'' |
| Q25L60_1000000 | 19008 | 4.57M |  461 |     19233 | 4.52M |  403 |       753 |  41.75K |  58 | 0:02'26'' |
| Q25L60_2000000 | 22270 | 4.58M |  378 |     22481 | 4.54M |  331 |       794 |  35.69K |  47 | 0:03'37'' |
| Q25L60_3000000 | 25885 | 4.58M |  364 |     26030 | 4.55M |  322 |       740 |  29.85K |  42 | 0:04'15'' |
| Q25L60_4000000 | 22629 |  4.6M |  439 |     22658 | 4.54M |  372 |       899 |  53.76K |  67 | 0:05'29'' |
| Q25L60_5000000 | 18394 | 4.61M |  545 |     19614 | 4.53M |  440 |       811 |  79.39K | 105 | 0:06'01'' |
| Q25L90_1000000 | 14981 | 4.55M |  596 |     15128 | 4.49M |  515 |       783 |  60.06K |  81 | 0:02'19'' |
| Q25L90_2000000 | 17745 | 4.57M |  466 |     17885 | 4.53M |  414 |       740 |  37.35K |  52 | 0:03'25'' |
| Q25L90_3000000 | 18492 | 4.59M |  481 |     18508 | 4.54M |  417 |       765 |  47.41K |  64 | 0:04'10'' |
| Q25L90_4000000 | 16480 |  4.6M |  540 |     16530 | 4.53M |  450 |       778 |  67.97K |  90 | 0:05'19'' |
| Q30L60_1000000 |  9791 | 4.53M |  793 |      9876 | 4.45M |  682 |       758 |  80.29K | 111 | 0:02'20'' |
| Q30L60_2000000 | 14035 | 4.56M |  600 |     14140 | 4.51M |  519 |       755 |  58.83K |  81 | 0:03'23'' |
| Q30L60_3000000 | 15618 | 4.57M |  536 |     15983 | 4.52M |  466 |       794 |  53.09K |  70 | 0:04'14'' |
| Q30L60_4000000 | 17673 | 4.58M |  499 |     17702 | 4.53M |  430 |       787 |  50.99K |  69 | 0:05'12'' |
| Q30L90_1000000 |  6764 | 4.48M | 1060 |      6999 | 4.34M |  873 |       784 | 138.83K | 187 | 0:02'22'' |
| Q30L90_2000000 |  9732 | 4.54M |  795 |     10010 | 4.45M |  676 |       789 |  89.24K | 119 | 0:03'28'' |

## Rsph: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/Rsph
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L60_1000000/anchor/pe.anchor.fa \
    Q20L60_2000000/anchor/pe.anchor.fa \
    Q20L90_1000000/anchor/pe.anchor.fa \
    Q20L90_2000000/anchor/pe.anchor.fa \
    Q25L60_1000000/anchor/pe.anchor.fa \
    Q25L60_2000000/anchor/pe.anchor.fa \
    Q25L60_3000000/anchor/pe.anchor.fa \
    Q25L60_4000000/anchor/pe.anchor.fa \
    Q25L90_1000000/anchor/pe.anchor.fa \
    Q25L90_2000000/anchor/pe.anchor.fa \
    Q25L90_3000000/anchor/pe.anchor.fa \
    Q25L90_4000000/anchor/pe.anchor.fa \
    Q30L60_1000000/anchor/pe.anchor.fa \
    Q30L60_2000000/anchor/pe.anchor.fa \
    Q30L60_3000000/anchor/pe.anchor.fa \
    Q30L60_4000000/anchor/pe.anchor.fa \
    Q30L90_1000000/anchor/pe.anchor.fa \
    Q30L90_2000000/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
anchr contained \
    Q20L60_1000000/anchor/pe.others.fa \
    Q20L90_1000000/anchor/pe.others.fa \
    Q25L60_1000000/anchor/pe.others.fa \
    Q25L90_1000000/anchor/pe.others.fa \
    Q30L60_1000000/anchor/pe.others.fa \
    Q30L90_1000000/anchor/pe.others.fa \
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
    1_genome/paralogs.fas \
    --label "abyss,soap,spades,velvet,merge,paralogs" \
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
| anchor.merge |   45424 | 4561812 | 185 |
| others.merge |    1084 |   28433 |  26 |

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
* len: 60 and 90

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
    " ::: 20 25 30 ::: 60 90

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
    for len in 60 90; do
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
| Q20L60   |     180 | 1245989712 | 7468436 |
| Q20L90   |     181 | 1153104910 | 6667310 |
| Q25L60   |     174 | 1072566099 | 6677852 |
| Q25L90   |     177 |  967235873 | 5749906 |
| Q30L60   |     166 |  828460499 | 5489956 |
| Q30L90   |     169 |  708807896 | 4406252 |

## Mabs: down sampling

```bash
BASE_DIR=$HOME/data/anchr/Mabs
cd ${BASE_DIR}

ARRAY=(
    "2_illumina/Q20L60:Q20L60:3000000"
    "2_illumina/Q20L90:Q20L90:3000000"
    "2_illumina/Q25L60:Q25L60:3000000"
    "2_illumina/Q25L90:Q25L90:2000000"
    "2_illumina/Q30L60:Q30L60:2000000"
    "2_illumina/Q30L90:Q30L90:2000000"
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

## Mabs: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/Mabs
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L60 Q20L90
        Q25L60 Q25L90
        Q30L60 Q30L90
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
            --kmer 41,61,81,101,121 \
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
        Q20L60 Q20L90
        Q25L60 Q25L90
        Q30L60 Q30L90
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
        Q20L60 Q20L90
        Q25L60 Q25L90
        Q30L60 Q30L90
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
BASE_DIR=$HOME/data/anchr/Mabs
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

perl -e '
    for my $n (
        qw{
        Q20L60 Q20L90
        Q25L60 Q25L90
        Q30L60 Q30L90
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

| Name           |   SumFq | CovFq | AvgRead |               Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:---------------|--------:|------:|--------:|-------------------:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| Q20L60_1000000 | 333.64M |  65.5 |     167 | "41,61,81,101,121" | 259.27M |  22.290% | 5.09M | 5.25M |     1.03 | 5.25M |     0 | 0:05'19'' |
| Q20L60_2000000 | 667.24M | 131.1 |     167 | "41,61,81,101,121" | 521.25M |  21.879% | 5.09M | 5.46M |     1.07 |  5.3M |     0 | 0:08'37'' |
| Q20L60_3000000 |      1G | 196.7 |     168 | "41,61,81,101,121" | 785.09M |  21.573% | 5.09M |  5.7M |     1.12 | 4.97M |     0 | 0:12'15'' |
| Q20L90_1000000 | 345.79M |  67.9 |     173 | "41,61,81,101,121" | 270.89M |  21.662% | 5.09M | 5.27M |     1.03 | 5.27M |     0 | 0:05'08'' |
| Q20L90_2000000 | 691.77M | 135.9 |     173 | "41,61,81,101,121" | 541.59M |  21.710% | 5.09M | 5.38M |     1.06 | 5.29M |     0 | 0:08'32'' |
| Q20L90_3000000 |   1.04G | 203.8 |     174 | "41,61,81,101,121" | 819.91M |  20.984% | 5.09M | 5.74M |     1.13 | 4.85M |     0 | 0:12'32'' |
| Q25L60_1000000 | 321.21M |  63.1 |     160 | "41,61,81,101,121" | 267.81M |  16.625% | 5.09M | 5.24M |     1.03 | 5.23M |     0 | 0:04'49'' |
| Q25L60_2000000 | 642.47M | 126.2 |     161 | "41,61,81,101,121" | 535.64M |  16.627% | 5.09M | 5.34M |     1.05 | 5.25M |     0 | 0:08'13'' |
| Q25L60_3000000 | 963.68M | 189.3 |     162 | "41,61,81,101,121" | 804.37M |  16.532% | 5.09M | 5.45M |     1.07 | 5.31M |     0 | 0:11'53'' |
| Q25L90_1000000 | 336.46M |  66.1 |     168 | "41,61,81,101,121" | 280.77M |  16.551% | 5.09M | 5.24M |     1.03 | 5.18M |     0 | 0:05'13'' |
| Q25L90_2000000 |  672.8M | 132.2 |     169 | "41,61,81,101,121" | 562.23M |  16.435% | 5.09M | 5.36M |     1.05 | 5.27M |     0 | 0:08'44'' |
| Q30L60_1000000 | 301.83M |  59.3 |     151 | "41,61,81,101,121" |  262.8M |  12.932% | 5.09M | 5.22M |     1.03 | 5.17M |     0 | 0:04'54'' |
| Q30L60_2000000 | 603.55M | 118.6 |     153 | "41,61,81,101,121" | 526.37M |  12.789% | 5.09M | 5.32M |     1.05 | 5.25M |     0 | 0:08'00'' |
| Q30L90_1000000 | 321.78M |  63.2 |     161 | "41,61,81,101,121" | 279.79M |  13.049% | 5.09M | 5.24M |     1.03 | 5.18M |     0 | 0:04'59'' |
| Q30L90_2000000 | 643.47M | 126.4 |     162 | "41,61,81,101,121" | 560.37M |  12.914% | 5.09M | 5.35M |     1.05 | 5.27M |     0 | 0:08'22'' |

| Name           | N50SR |   Sum |    # | N50Anchor |   Sum |    # | N50Others |     Sum |    # |   RunTime |
|:---------------|------:|------:|-----:|----------:|------:|-----:|----------:|--------:|-----:|----------:|
| Q20L60_1000000 |  7785 | 5.25M | 1095 |      7881 | 5.15M |  963 |       798 | 100.19K |  132 | 0:01'41'' |
| Q20L60_2000000 |  2182 |  5.3M | 3099 |      2493 | 4.48M | 1992 |       774 | 821.96K | 1107 | 0:02'25'' |
| Q20L60_3000000 |  1178 | 4.97M | 4635 |      1613 |    3M | 1882 |       740 |   1.97M | 2753 | 0:02'50'' |
| Q20L90_1000000 |  5825 | 5.27M | 1353 |      5980 |  5.1M | 1119 |       758 | 170.31K |  234 | 0:01'38'' |
| Q20L90_2000000 |  4275 | 5.29M | 1780 |      4436 | 5.02M | 1416 |       782 | 270.55K |  364 | 0:02'31'' |
| Q20L90_3000000 |  1087 | 4.85M | 4834 |      1477 | 2.69M | 1777 |       732 |   2.16M | 3057 | 0:02'47'' |
| Q25L60_1000000 |  8569 | 5.23M |  949 |      8643 | 5.15M |  833 |       793 |  85.86K |  116 | 0:01'39'' |
| Q25L60_2000000 |  7354 | 5.25M | 1108 |      7537 | 5.14M |  954 |       748 | 112.46K |  154 | 0:02'41'' |
| Q25L60_3000000 |  3374 | 5.31M | 2209 |      3523 | 4.94M | 1698 |       761 | 373.61K |  511 | 0:03'18'' |
| Q25L90_1000000 | 16671 | 5.18M |  529 |     16753 | 5.16M |  494 |       739 |  24.79K |   35 | 0:01'58'' |
| Q25L90_2000000 |  5947 | 5.27M | 1317 |      6085 | 5.12M | 1120 |       807 | 151.16K |  197 | 0:02'46'' |
| Q30L60_1000000 | 21553 | 5.17M |  400 |     21571 | 5.14M |  366 |       743 |  23.93K |   34 | 0:01'55'' |
| Q30L60_2000000 |  9388 | 5.25M |  884 |      9483 | 5.15M |  785 |       888 |  99.73K |   99 | 0:02'44'' |
| Q30L90_1000000 | 13964 | 5.18M |  610 |     14046 | 5.15M |  564 |       789 |  34.28K |   46 | 0:01'37'' |
| Q30L90_2000000 |  6086 | 5.27M | 1284 |      6293 | 5.11M | 1076 |       803 |  158.9K |  208 | 0:02'32'' |

## Mabs: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/Mabs
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L60_1000000/anchor/pe.anchor.fa \
    Q20L60_2000000/anchor/pe.anchor.fa \
    Q20L90_1000000/anchor/pe.anchor.fa \
    Q20L90_2000000/anchor/pe.anchor.fa \
    Q25L60_1000000/anchor/pe.anchor.fa \
    Q25L60_2000000/anchor/pe.anchor.fa \
    Q25L90_1000000/anchor/pe.anchor.fa \
    Q25L90_2000000/anchor/pe.anchor.fa \
    Q30L60_1000000/anchor/pe.anchor.fa \
    Q30L60_2000000/anchor/pe.anchor.fa \
    Q30L90_1000000/anchor/pe.anchor.fa \
    Q30L90_2000000/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
anchr contained \
    Q20L60_1000000/anchor/pe.others.fa \
    Q20L90_1000000/anchor/pe.others.fa \
    Q25L60_1000000/anchor/pe.others.fa \
    Q25L90_1000000/anchor/pe.others.fa \
    Q30L60_1000000/anchor/pe.others.fa \
    Q30L90_1000000/anchor/pe.others.fa \
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
    1_genome/paralogs.fas \
    --label "abyss,soap,spades,velvet,merge,paralogs" \
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

| Name         |     N50 |     Sum |  # |
|:-------------|--------:|--------:|---:|
| Genome       | 5067172 | 5090491 |  2 |
| Paralogs     |    1580 |   83364 | 53 |
| anchor.merge |  117221 | 5151939 | 72 |
| others.merge |    1104 |   43911 | 38 |

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
* len: 60 and 90

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
    " ::: 20 25 30 ::: 60 90

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
    for len in 60 90; do
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
| Q20L60   |     191 | 1196793571 | 6525756 |
| Q20L90   |     192 | 1173364858 | 6330538 |
| Q25L60   |     188 | 1099946499 | 6132586 |
| Q25L90   |     189 | 1070665556 | 5882882 |
| Q30L60   |     182 |  943132742 | 5460004 |
| Q30L90   |     183 |  907435729 | 5147836 |

## Vcho: down sampling

```bash
BASE_DIR=$HOME/data/anchr/Vcho
cd ${BASE_DIR}

ARRAY=(
    "2_illumina/Q20L60:Q20L60:3000000"
    "2_illumina/Q20L90:Q20L90:3000000"
    "2_illumina/Q25L60:Q25L60:3000000"
    "2_illumina/Q25L90:Q25L90:2000000"
    "2_illumina/Q30L60:Q30L60:2000000"
    "2_illumina/Q30L90:Q30L90:2000000"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(perl -e "@p = split q{:}, q{${group}}; print \$p[0];")
    GROUP_ID=$( perl -e "@p = split q{:}, q{${group}}; print \$p[1];")
    GROUP_MAX=$(perl -e "@p = split q{:}, q{${group}}; print \$p[2];")
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

## Vcho: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/Vcho
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L60 Q20L90
        Q25L60 Q25L90
        Q30L60 Q30L90
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
            --kmer 41,61,81,101,121 \
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
        Q20L60 Q20L90
        Q25L60 Q25L90
        Q30L60 Q30L90
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
        Q20L60 Q20L90
        Q25L60 Q25L90
        Q30L60 Q30L90
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
BASE_DIR=$HOME/data/anchr/Vcho
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

perl -e '
    for my $n (
        qw{
        Q20L60 Q20L90
        Q25L60 Q25L90
        Q30L60 Q30L90
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

| Name           |   SumFq | CovFq | AvgRead |               Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:---------------|--------:|------:|--------:|-------------------:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| Q20L60_1000000 | 366.77M |  90.9 |     183 | "41,61,81,101,121" | 294.99M |  19.571% | 4.03M |    4M |     0.99 | 4.01M |     0 | 0:05'55'' |
| Q20L60_2000000 | 733.48M | 181.8 |     184 | "41,61,81,101,121" | 592.22M |  19.259% | 4.03M | 4.18M |     1.04 | 3.96M |     0 | 0:10'04'' |
| Q20L60_3000000 |    1.1G | 272.8 |     184 | "41,61,81,101,121" | 891.78M |  18.957% | 4.03M | 4.46M |     1.11 | 3.58M |     0 | 0:14'05'' |
| Q20L90_1000000 | 370.69M |  91.9 |     185 | "41,61,81,101,121" | 298.24M |  19.544% | 4.03M | 3.98M |     0.99 | 3.98M |     0 | 0:05'28'' |
| Q20L90_2000000 | 741.44M | 183.8 |     186 | "41,61,81,101,121" | 600.65M |  18.989% | 4.03M |  4.2M |     1.04 | 3.96M |     0 | 0:09'19'' |
| Q20L90_3000000 |   1.11G | 275.7 |     186 | "41,61,81,101,121" | 903.94M |  18.717% | 4.03M | 4.48M |     1.11 | 3.56M |     0 | 0:13'49'' |
| Q25L60_1000000 | 358.69M |  88.9 |     179 | "41,61,81,101,121" | 304.06M |  15.232% | 4.03M | 3.97M |     0.98 | 3.98M |     0 | 0:05'19'' |
| Q25L60_2000000 | 717.57M | 177.9 |     180 | "41,61,81,101,121" | 609.57M |  15.050% | 4.03M | 4.08M |     1.01 | 4.03M |     0 | 0:09'35'' |
| Q25L60_3000000 |   1.08G | 266.8 |     181 | "41,61,81,101,121" | 919.18M |  14.586% | 4.03M | 4.35M |     1.08 | 3.77M |     0 | 0:14'06'' |
| Q25L90_1000000 | 363.97M |  90.2 |     182 | "41,61,81,101,121" | 309.19M |  15.050% | 4.03M | 3.97M |     0.99 | 3.98M |     0 | 0:05'33'' |
| Q25L90_2000000 | 727.95M | 180.5 |     183 | "41,61,81,101,121" | 619.35M |  14.919% | 4.03M |  4.1M |     1.02 | 4.03M |     0 | 0:09'43'' |
| Q30L60_1000000 | 345.57M |  85.7 |     172 | "41,61,81,101,121" | 305.14M |  11.700% | 4.03M | 3.96M |     0.98 | 3.98M |     0 | 0:05'18'' |
| Q30L60_2000000 | 690.97M | 171.3 |     174 | "41,61,81,101,121" | 611.28M |  11.534% | 4.03M | 4.04M |     1.00 | 4.03M |     0 | 0:09'04'' |
| Q30L90_1000000 | 352.52M |  87.4 |     176 | "41,61,81,101,121" | 311.24M |  11.710% | 4.03M | 3.96M |     0.98 | 3.98M |     0 | 0:05'35'' |
| Q30L90_2000000 | 705.18M | 174.8 |     178 | "41,61,81,101,121" | 623.71M |  11.552% | 4.03M | 4.04M |     1.00 | 4.04M |     0 | 0:09'23'' |

| Name           | N50SR |   Sum |    # | N50Anchor |   Sum |    # | N50Others |     Sum |    # |   RunTime |
|:---------------|------:|------:|-----:|----------:|------:|-----:|----------:|--------:|-----:|----------:|
| Q20L60_1000000 |  5694 | 4.01M | 1118 |      6035 | 3.86M |  917 |       790 |    149K |  201 | 0:01'48'' |
| Q20L60_2000000 |  1810 | 3.96M | 2660 |      2215 | 3.14M | 1548 |       771 | 818.02K | 1112 | 0:02'29'' |
| Q20L60_3000000 |  1077 | 3.58M | 3540 |      1519 | 1.97M | 1272 |       731 |   1.61M | 2268 | 0:03'01'' |
| Q20L90_1000000 | 10590 | 3.98M |  653 |     10834 | 3.91M |  554 |       792 |  73.78K |   99 | 0:01'49'' |
| Q20L90_2000000 |  1766 | 3.96M | 2713 |      2172 | 3.08M | 1521 |       762 | 872.89K | 1192 | 0:02'39'' |
| Q20L90_3000000 |  1065 | 3.56M | 3559 |      1530 | 1.91M | 1227 |       726 |   1.65M | 2332 | 0:02'58'' |
| Q25L60_1000000 | 12448 | 3.98M |  572 |     12613 | 3.91M |  474 |       777 |  72.01K |   98 | 0:02'03'' |
| Q25L60_2000000 |  3817 | 4.03M | 1508 |      4187 | 3.76M | 1144 |       797 | 270.47K |  364 | 0:03'16'' |
| Q25L60_3000000 |  1222 | 3.77M | 3408 |      1648 | 2.35M | 1426 |       741 |   1.42M | 1982 | 0:03'19'' |
| Q25L90_1000000 | 11817 | 3.98M |  612 |     11827 | 3.91M |  512 |       722 |  71.83K |  100 | 0:02'00'' |
| Q25L90_2000000 |  3547 | 4.03M | 1597 |      3729 | 3.73M | 1188 |       767 | 300.18K |  409 | 0:03'02'' |
| Q30L60_1000000 | 13262 | 3.98M |  514 |     13596 | 3.91M |  433 |       784 |  60.73K |   81 | 0:02'10'' |
| Q30L60_2000000 |  4283 | 4.03M | 1408 |      4497 | 3.77M | 1063 |       786 | 254.53K |  345 | 0:03'15'' |
| Q30L90_1000000 | 12858 | 3.98M |  568 |     12906 | 3.92M |  480 |       791 |  64.11K |   88 | 0:02'01'' |
| Q30L90_2000000 |  3895 | 4.04M | 1471 |      4243 | 3.77M | 1114 |       805 | 268.19K |  357 | 0:03'08'' |

## Vcho: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/Vcho
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L60_1000000/anchor/pe.anchor.fa \
    Q20L60_2000000/anchor/pe.anchor.fa \
    Q20L90_1000000/anchor/pe.anchor.fa \
    Q20L90_2000000/anchor/pe.anchor.fa \
    Q25L60_1000000/anchor/pe.anchor.fa \
    Q25L60_2000000/anchor/pe.anchor.fa \
    Q25L90_1000000/anchor/pe.anchor.fa \
    Q25L90_2000000/anchor/pe.anchor.fa \
    Q30L60_1000000/anchor/pe.anchor.fa \
    Q30L60_2000000/anchor/pe.anchor.fa \
    Q30L90_1000000/anchor/pe.anchor.fa \
    Q30L90_2000000/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
anchr contained \
    Q20L60_1000000/anchor/pe.others.fa \
    Q20L90_1000000/anchor/pe.others.fa \
    Q25L60_1000000/anchor/pe.others.fa \
    Q25L90_1000000/anchor/pe.others.fa \
    Q30L60_1000000/anchor/pe.others.fa \
    Q30L90_1000000/anchor/pe.others.fa \
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
    1_genome/paralogs.fas \
    --label "abyss,soap,spades,velvet,merge,paralogs" \
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
| anchor.merge |  125605 | 3922361 | 98 |
| others.merge |    1014 |   13694 | 13 |

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/Vcho
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```
