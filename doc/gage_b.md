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
- [*Vibrio cholerae* CP1032(5) HiSeq](#vibrio-cholerae-cp10325-hiseq)
    - [VchoH: download](#vchoh-download)
    - [VchoH: combinations of different quality values and read lengths](#vchoh-combinations-of-different-quality-values-and-read-lengths)
    - [VchoH: down sampling](#vchoh-down-sampling)
    - [VchoH: generate super-reads](#vchoh-generate-super-reads)
    - [VchoH: create anchors](#vchoh-create-anchors)
    - [VchoH: results](#vchoh-results)
    - [VchoH: merge anchors](#vchoh-merge-anchors)


# *Bacillus cereus* ATCC 10987

## Bcer: download

* Reference genome

    * Strain: Bacillus cereus ATCC 10987
    * Taxid: [222523](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=222523)
    * RefSeq assembly accession:
      [GCF_000008005.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/005/GCF_000008005.1_ASM800v1/GCF_000008005.1_ASM800v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0797

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
tar xvfz B_cereus_MiSeq.tar.gz cabog_ctg.fasta
tar xvfz B_cereus_MiSeq.tar.gz mira_ctg.fasta
tar xvfz B_cereus_MiSeq.tar.gz msrca_ctg.fasta
tar xvfz B_cereus_MiSeq.tar.gz sga_ctg.fasta
tar xvfz B_cereus_MiSeq.tar.gz soap_ctg.fasta
tar xvfz B_cereus_MiSeq.tar.gz spades_ctg.fasta
tar xvfz B_cereus_MiSeq.tar.gz velvet_ctg.fasta

```

## Bcer: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60 and 90

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
    " ::: 20 25 30 ::: 60 90

```

* kmergenie

```bash
mkdir -p ~/data/anchr/Bcer/2_illumina/kmergenie
cd ~/data/anchr/Bcer/2_illumina/kmergenie

kmergenie -l 21 -k 151 -s 10 -t 10 ../R1.fq.gz -o oriR1
kmergenie -l 21 -k 151 -s 10 -t 10 ../R2.fq.gz -o oriR2
kmergenie -l 21 -k 151 -s 10 -t 10 ../Q20L60/R1.fq.gz -o Q20L60R1
kmergenie -l 21 -k 151 -s 10 -t 10 ../Q20L60/R2.fq.gz -o Q20L60R2

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
    $(echo "Paralogs"; faops n50 -H -S -C 1_genome/paralogs.fas;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "PacBio";   faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md

parallel -k --no-run-if-empty -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( echo Q{1}L{2}; \
            faops n50 -H -S -C \
                ${BASE_DIR}/2_illumina/Q{1}L{2}/R1.fq.gz \
                ${BASE_DIR}/2_illumina/Q{1}L{2}/R2.fq.gz;
        )
    " ::: 20 25 30 ::: 60 90 \
    >> ${BASE_DIR}/stat.md

cat stat.md
```

| Name     |     N50 |       Sum |       # |
|:---------|--------:|----------:|--------:|
| Genome   | 5224283 |   5432652 |       2 |
| Paralogs |    2295 |    223889 |     103 |
| PacBio   |         |           |         |
| Illumina |     251 | 481020311 | 2080000 |
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
        echo '    R1.fq.gz exists'        
        continue;
    fi
    
    ln -s ${BASE_DIR}/${GROUP_DIR}/R1.fq.gz ${DIR_COUNT}/R1.fq.gz
    ln -s ${BASE_DIR}/${GROUP_DIR}/R2.fq.gz ${DIR_COUNT}/R2.fq.gz
    ln -s ${BASE_DIR}/${GROUP_DIR}/Rs.fq.gz ${DIR_COUNT}/Rs.fq.gz

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

        if [ -e ${BASE_DIR}/{}/k_unitigs.fasta ]; then
            echo '    k_unitigs.fasta already presents'
            exit;
        fi

        cd ${BASE_DIR}/{}
        string='My long string'
        if [[ {} == *'Q30'* ]]; then
            anchr superreads \
                R1.fq.gz R2.fq.gz Rs.fq.gz \
                --nosr -p 8 \
                --kmer 41,61,81,101,121,71,91 \
                -o superreads.sh
        else
            anchr superreads \
                R1.fq.gz R2.fq.gz \
                --nosr -p 8 \
                --kmer 41,61,81,101,121,71,91 \
                -o superreads.sh
        fi
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
    | parallel -k --no-run-if-empty -j 3 "
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
    | parallel -k --no-run-if-empty -j 6 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

| Name   |   SumFq | CovFq | AvgRead |                     Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:-------|--------:|------:|--------:|-------------------------:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| Q20L60 | 413.49M |  76.1 |     224 | "41,61,81,101,121,71,91" |  351.4M |  15.015% | 5.43M | 5.36M |     0.99 | 5.37M |     0 | 0:10'19'' |
| Q20L90 | 398.95M |  73.4 |     228 | "41,61,81,101,121,71,91" | 339.36M |  14.937% | 5.43M | 5.35M |     0.99 | 5.37M |     0 | 0:10'14'' |
| Q25L60 |  381.7M |  70.3 |     218 | "41,61,81,101,121,71,91" | 343.46M |  10.018% | 5.43M | 5.34M |     0.98 | 5.36M |     0 | 0:10'23'' |
| Q25L90 | 366.58M |  67.5 |     224 | "41,61,81,101,121,71,91" | 329.96M |   9.990% | 5.43M | 5.34M |     0.98 | 5.37M |     0 | 0:09'13'' |
| Q30L60 | 331.98M |  61.1 |     210 | "41,61,81,101,121,71,91" |  348.4M |  -4.947% | 5.43M | 5.34M |     0.98 | 5.38M |     0 | 0:09'23'' |
| Q30L90 | 316.47M |  58.3 |     216 | "41,61,81,101,121,71,91" | 343.29M |  -8.477% | 5.43M | 5.34M |     0.98 | 5.38M |     0 | 0:09'25'' |

| Name   | N50SR |   Sum |   # | N50Anchor |   Sum |   # | N50Others |    Sum |  # |   RunTime |
|:-------|------:|------:|----:|----------:|------:|----:|----------:|-------:|---:|----------:|
| Q20L60 | 22636 | 5.37M | 420 |     22686 | 5.35M | 388 |       783 | 23.33K | 32 | 0:01'30'' |
| Q20L90 | 23117 | 5.37M | 405 |     23117 | 5.34M | 370 |       783 | 25.49K | 35 | 0:01'31'' |
| Q25L60 | 40740 | 5.36M | 265 |     40740 | 5.34M | 241 |       752 | 16.84K | 24 | 0:01'41'' |
| Q25L90 | 37659 | 5.37M | 263 |     37680 | 5.35M | 241 |       935 | 22.26K | 22 | 0:01'34'' |
| Q30L60 | 42824 | 5.38M | 247 |     42824 | 5.32M | 217 |     16158 | 52.03K | 30 | 0:01'50'' |
| Q30L90 | 42241 | 5.38M | 246 |     42241 | 5.32M | 218 |     16144 | 50.97K | 28 | 0:01'50'' |

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
    8_competitor/cabog_ctg.fasta \
    8_competitor/mira_ctg.fasta \
    8_competitor/msrca_ctg.fasta \
    8_competitor/sga_ctg.fasta \
    8_competitor/soap_ctg.fasta \
    8_competitor/spades_ctg.fasta \
    8_competitor/velvet_ctg.fasta \
    merge/anchor.merge.fasta \
    1_genome/paralogs.fas \
    --label "abyss,cabog,mira,msrca,sga,soap,spades,velvet,merge,paralogs" \
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
| anchor.merge |   46184 | 5353003 | 204 |
| others.merge |   16206 |   25564 |   4 |

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/Bcer
cd ${BASE_DIR}

#rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

# *Rhodobacter sphaeroides* 2.4.1

## Rsph: download

* Reference genome

    * Strain: Rhodobacter sphaeroides 2.4.1
    * Taxid: [272943](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=272943)
    * RefSeq assembly accession:
      [GCF_000012905.2](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/745/GCF_000006745.1_ASM674v1/GCF_000006745.1_ASM674v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0286

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
tar xvfz R_sphaeroides_MiSeq.tar.gz cabog_ctg.fasta
tar xvfz R_sphaeroides_MiSeq.tar.gz mira_ctg.fasta
tar xvfz R_sphaeroides_MiSeq.tar.gz msrca_ctg.fasta
tar xvfz R_sphaeroides_MiSeq.tar.gz sga_ctg.fasta
tar xvfz R_sphaeroides_MiSeq.tar.gz soap_ctg.fasta
tar xvfz R_sphaeroides_MiSeq.tar.gz spades_ctg.fasta
tar xvfz R_sphaeroides_MiSeq.tar.gz velvet_ctg.fasta

```

## Rsph: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60 and 90

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
    " ::: 20 25 30 ::: 60 90

```

* kmergenie

```bash
BASE_NAME=Rsph

mkdir -p $HOME/data/anchr/${BASE_NAME}/2_illumina/kmergenie
cd $HOME/data/anchr/${BASE_NAME}/2_illumina/kmergenie

kmergenie -l 21 -k 151 -s 10 -t 8 ../R1.fq.gz -o oriR1
kmergenie -l 21 -k 151 -s 10 -t 8 ../R2.fq.gz -o oriR2
kmergenie -l 21 -k 151 -s 10 -t 8 ../Q20L60/R1.fq.gz -o Q20L60R1
kmergenie -l 21 -k 151 -s 10 -t 8 ../Q20L60/R2.fq.gz -o Q20L60R2

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
    $(echo "PacBio";   faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
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
| PacBio   |         |            |          |
| Illumina |     251 | 4237215336 | 16881336 |
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
    "2_illumina/Q20L90:Q20L90:5000000"
    "2_illumina/Q25L60:Q25L60:5000000"
    "2_illumina/Q25L90:Q25L90:4000000"
    "2_illumina/Q30L60:Q30L60:4000000"
    "2_illumina/Q30L90:Q30L90:3000000"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    GROUP_MAX=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[2];')
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    perl -e 'print 1000000 * $_, qq{\n} for 1 .. 5' \
    | parallel --no-run-if-empty -j 3 "
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
        if [[ ${GROUP_ID} == *'Q30'* ]]; then
            seqtk sample -s{} \
                ${BASE_DIR}/${GROUP_DIR}/Rs.fq.gz {} \
                | pigz -p 4 -c > ${BASE_DIR}/${GROUP_ID}_{}/Rs.fq.gz
        fi
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

        if [ -e ${BASE_DIR}/{}/k_unitigs.fasta ]; then
            echo '    k_unitigs.fasta already presents'
            exit;
        fi

        cd ${BASE_DIR}/{}
        string='My long string'
        if [[ {} == *'Q30'* ]]; then
            anchr superreads \
                R1.fq.gz R2.fq.gz Rs.fq.gz \
                --nosr -p 8 \
                --kmer 41,61,81,101,121,31,51 \
                -o superreads.sh
        else
            anchr superreads \
                R1.fq.gz R2.fq.gz \
                --nosr -p 8 \
                --kmer 41,61,81,101,121,31,51 \
                -o superreads.sh
        fi
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

| Name           |   SumFq | CovFq | AvgRead |                     Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:---------------|--------:|------:|--------:|-------------------------:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| Q20L60_1000000 | 272.07M |  59.1 |     137 | "41,61,81,101,121,31,51" | 241.69M |  11.164% |  4.6M | 4.56M |     0.99 | 4.58M |     0 | 0:09'21'' |
| Q20L60_2000000 | 544.25M | 118.2 |     137 | "41,61,81,101,121,31,51" | 484.24M |  11.026% |  4.6M | 4.58M |     1.00 | 4.62M |     0 | 0:15'11'' |
| Q20L60_3000000 | 816.38M | 177.4 |     137 | "41,61,81,101,121,31,51" | 727.37M |  10.903% |  4.6M | 4.63M |     1.01 | 4.65M |     0 | 0:20'43'' |
| Q20L60_4000000 |   1.09G | 236.5 |     137 | "41,61,81,101,121,31,51" | 971.18M |  10.775% |  4.6M |  4.7M |     1.02 | 4.64M |     0 | 0:23'35'' |
| Q20L60_5000000 |   1.36G | 295.6 |     137 | "41,61,81,101,121,31,51" |   1.22G |  10.673% |  4.6M | 4.78M |     1.04 | 4.61M |     0 | 0:28'05'' |
| Q20L90_1000000 | 285.26M |  62.0 |     143 | "41,61,81,101,121,31,51" | 253.32M |  11.197% |  4.6M | 4.55M |     0.99 | 4.58M |     0 | 0:06'56'' |
| Q20L90_2000000 | 570.42M | 123.9 |     144 | "41,61,81,101,121,31,51" | 507.15M |  11.093% |  4.6M | 4.58M |     1.00 | 4.61M |     0 | 0:14'02'' |
| Q20L90_3000000 | 855.74M | 185.9 |     143 | "41,61,81,101,121,31,51" | 761.71M |  10.988% |  4.6M | 4.63M |     1.01 | 4.64M |     0 | 0:20'56'' |
| Q20L90_4000000 |   1.14G | 247.9 |     143 | "41,61,81,101,121,31,51" |   1.02G |  10.861% |  4.6M |  4.7M |     1.02 | 4.63M |     0 | 0:29'58'' |
| Q20L90_5000000 |   1.41G | 306.6 |     143 | "41,61,81,101,121,31,51" |   1.26G |  10.744% |  4.6M | 4.78M |     1.04 | 4.55M |     0 | 0:36'49'' |
| Q25L60_1000000 | 252.05M |  54.8 |     127 | "41,61,81,101,121,31,51" | 240.65M |   4.523% |  4.6M | 4.55M |     0.99 | 4.57M |     0 | 0:09'13'' |
| Q25L60_2000000 | 504.03M | 109.5 |     127 | "41,61,81,101,121,31,51" | 481.31M |   4.507% |  4.6M | 4.56M |     0.99 | 4.58M |     0 | 0:14'46'' |
| Q25L60_3000000 | 756.14M | 164.3 |     127 | "41,61,81,101,121,31,51" | 722.22M |   4.486% |  4.6M | 4.56M |     0.99 | 4.58M |     0 | 0:19'51'' |
| Q25L60_4000000 |   1.01G | 219.0 |     128 | "41,61,81,101,121,31,51" | 963.07M |   4.469% |  4.6M | 4.57M |     0.99 |  4.6M |     0 | 0:25'29'' |
| Q25L60_5000000 |   1.26G | 273.8 |     127 | "41,61,81,101,121,31,51" |    1.2G |   4.453% |  4.6M | 4.58M |     1.00 | 4.61M |     0 | 0:31'32'' |
| Q25L90_1000000 | 267.45M |  58.1 |     135 | "41,61,81,101,121,31,51" | 255.12M |   4.610% |  4.6M | 4.53M |     0.99 | 4.55M |     0 | 0:09'31'' |
| Q25L90_2000000 |  534.9M | 116.2 |     134 | "41,61,81,101,121,31,51" | 510.39M |   4.581% |  4.6M | 4.55M |     0.99 | 4.57M |     0 | 0:14'47'' |
| Q25L90_3000000 | 802.36M | 174.3 |     135 | "41,61,81,101,121,31,51" | 765.77M |   4.560% |  4.6M | 4.56M |     0.99 | 4.59M |     0 | 0:20'13'' |
| Q25L90_4000000 |   1.07G | 232.4 |     134 | "41,61,81,101,121,31,51" |   1.02G |   4.542% |  4.6M | 4.57M |     0.99 |  4.6M |     0 | 0:21'19'' |
| Q30L60_1000000 | 221.77M |  48.2 |     112 | "41,61,81,101,121,31,51" | 319.11M | -43.894% |  4.6M | 4.55M |     0.99 | 4.56M |     0 | 0:06'47'' |
| Q30L60_2000000 | 443.56M |  96.4 |     112 | "41,61,81,101,121,31,51" | 638.16M | -43.873% |  4.6M | 4.55M |     0.99 | 4.58M |     0 | 0:11'18'' |
| Q30L60_3000000 | 665.33M | 144.5 |     112 | "41,61,81,101,121,31,51" |  870.3M | -30.806% |  4.6M | 4.55M |     0.99 | 4.58M |     0 | 0:15'04'' |
| Q30L60_4000000 | 887.07M | 192.7 |     112 | "41,61,81,101,121,31,51" |   1.09G | -22.542% |  4.6M | 4.55M |     0.99 | 4.58M |     0 | 0:16'58'' |
| Q30L90_1000000 | 242.34M |  52.6 |     122 | "41,61,81,101,121,31,51" | 354.16M | -46.144% |  4.6M | 4.54M |     0.99 | 4.56M |     0 | 0:06'59'' |
| Q30L90_2000000 | 484.58M | 105.3 |     121 | "41,61,81,101,121,31,51" | 708.39M | -46.185% |  4.6M | 4.55M |     0.99 | 4.57M |     0 | 0:12'05'' |
| Q30L90_3000000 | 622.67M | 135.3 |     121 | "41,61,81,101,121,31,51" |  955.9M | -53.516% |  4.6M | 4.55M |     0.99 | 4.57M |     0 | 0:15'46'' |

| Name           | N50SR |   Sum |    # | N50Anchor |   Sum |    # | N50Others |     Sum |    # |   RunTime |
|:---------------|------:|------:|-----:|----------:|------:|-----:|----------:|--------:|-----:|----------:|
| Q20L60_1000000 | 26225 | 4.58M |  339 |     26328 | 4.55M |  300 |       739 |  27.22K |   39 | 0:02'05'' |
| Q20L60_2000000 | 17208 | 4.62M |  575 |     17475 | 4.53M |  451 |       761 |  89.05K |  124 | 0:03'12'' |
| Q20L60_3000000 |  7947 | 4.65M | 1134 |      8358 | 4.43M |  834 |       755 | 218.01K |  300 | 0:04'04'' |
| Q20L60_4000000 |  4069 | 4.64M | 1792 |      4418 | 4.25M | 1254 |       761 | 390.94K |  538 | 0:04'15'' |
| Q20L60_5000000 |  2466 | 4.61M | 2513 |      2864 | 3.92M | 1577 |       764 |  685.2K |  936 | 0:05'58'' |
| Q20L90_1000000 | 22522 | 4.58M |  411 |     22543 | 4.53M |  345 |       786 |  48.68K |   66 | 0:02'19'' |
| Q20L90_2000000 | 13360 | 4.61M |  697 |     13805 |  4.5M |  546 |       739 | 109.84K |  151 | 0:03'22'' |
| Q20L90_3000000 |  6389 | 4.64M | 1306 |      6662 |  4.4M |  971 |       742 | 239.87K |  335 | 0:04'22'' |
| Q20L90_4000000 |  3357 | 4.63M | 2055 |      3727 | 4.15M | 1397 |       745 | 475.98K |  658 | 0:04'47'' |
| Q20L90_5000000 |  2190 | 4.55M | 2705 |      2598 |  3.8M | 1658 |       745 | 753.74K | 1047 | 0:06'03'' |
| Q25L60_1000000 | 24394 | 4.57M |  381 |     24438 | 4.53M |  331 |       740 |  35.74K |   50 | 0:02'32'' |
| Q25L60_2000000 | 31007 | 4.58M |  300 |     31269 | 4.55M |  259 |       765 |  30.84K |   41 | 0:03'37'' |
| Q25L60_3000000 | 32862 | 4.58M |  307 |     32862 | 4.56M |  270 |       725 |  25.82K |   37 | 0:04'16'' |
| Q25L60_4000000 | 27823 |  4.6M |  389 |     27838 | 4.55M |  328 |       898 |  48.52K |   61 | 0:05'20'' |
| Q25L60_5000000 | 20420 | 4.61M |  498 |     21497 | 4.54M |  398 |       804 |  74.97K |  100 | 0:05'59'' |
| Q25L90_1000000 | 18034 | 4.55M |  502 |     18358 |  4.5M |  433 |       787 |  51.99K |   69 | 0:02'52'' |
| Q25L90_2000000 | 22104 | 4.57M |  387 |     22185 | 4.54M |  340 |       740 |  33.67K |   47 | 0:05'19'' |
| Q25L90_3000000 | 21864 | 4.59M |  420 |     22186 | 4.54M |  361 |       796 |  43.73K |   59 | 0:06'16'' |
| Q25L90_4000000 | 19564 |  4.6M |  483 |     20207 | 4.53M |  398 |       799 |  64.49K |   85 | 0:05'43'' |
| Q30L60_1000000 | 19170 | 4.56M |  468 |     19596 | 4.52M |  402 |       747 |  46.66K |   66 | 0:03'01'' |
| Q30L60_2000000 | 22885 | 4.58M |  390 |     23141 | 4.53M |  333 |       820 |  43.45K |   57 | 0:04'03'' |
| Q30L60_3000000 | 24770 | 4.58M |  360 |     24770 | 4.54M |  312 |       790 |  36.93K |   48 | 0:05'21'' |
| Q30L60_4000000 | 26031 | 4.58M |  336 |     26225 | 4.55M |  296 |       835 |  31.45K |   40 | 0:05'57'' |
| Q30L90_1000000 | 15433 | 4.56M |  566 |     15573 |  4.5M |  490 |       763 |  55.07K |   76 | 0:02'37'' |
| Q30L90_2000000 | 20258 | 4.57M |  460 |     20493 | 4.53M |  402 |       810 |  44.19K |   58 | 0:04'17'' |
| Q30L90_3000000 | 21686 | 4.57M |  415 |     21836 | 4.53M |  365 |       810 |  38.33K |   50 | 0:05'06'' |

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
    Q25L60_5000000/anchor/pe.anchor.fa \
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
    Q30L90_3000000/anchor/pe.anchor.fa \
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
    8_competitor/cabog_ctg.fasta \
    8_competitor/mira_ctg.fasta \
    8_competitor/msrca_ctg.fasta \
    8_competitor/sga_ctg.fasta \
    8_competitor/soap_ctg.fasta \
    8_competitor/spades_ctg.fasta \
    8_competitor/velvet_ctg.fasta \
    merge/anchor.merge.fasta \
    1_genome/paralogs.fas \
    --label "abyss,cabog,mira,msrca,sga,soap,spades,velvet,merge,paralogs" \
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
| anchor.merge |   71813 | 4563188 | 140 |
| others.merge |    1155 |   19103 |  17 |

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/Rsph
cd ${BASE_DIR}

#rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

# *Mycobacterium abscessus* 6G-0125-R

## Mabs: download

* Reference genome

    * *Mycobacterium abscessus* ATCC 19977
        * Taxid: [561007](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=243277)
        * RefSeq assembly accession:
          [GCF_000069185.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/745/GCF_000006745.1_ASM674v1/GCF_000006745.1_ASM674v1_assembly_report.txt)
        * Proportion of paralogs (> 1000 bp): 0.0168
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
tar xvfz M_abscessus_MiSeq.tar.gz cabog_ctg.fasta
tar xvfz M_abscessus_MiSeq.tar.gz mira_ctg.fasta
tar xvfz M_abscessus_MiSeq.tar.gz msrca_ctg.fasta
tar xvfz M_abscessus_MiSeq.tar.gz sga_ctg.fasta
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
    " ::: 20 25 30 ::: 60 90

```

* kmergenie

```bash
BASE_NAME=Mabs

mkdir -p $HOME/data/anchr/${BASE_NAME}/2_illumina/kmergenie
cd $HOME/data/anchr/${BASE_NAME}/2_illumina/kmergenie

kmergenie -l 21 -k 151 -s 10 -t 8 ../R1.fq.gz -o oriR1
kmergenie -l 21 -k 151 -s 10 -t 8 ../R2.fq.gz -o oriR2
kmergenie -l 21 -k 151 -s 10 -t 8 ../Q20L60/R1.fq.gz -o Q20L60R1
kmergenie -l 21 -k 151 -s 10 -t 8 ../Q20L60/R2.fq.gz -o Q20L60R2

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
    $(echo "PacBio";   faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
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
| PacBio   |         |            |         |
| Illumina |     251 | 2194026140 | 8741140 |
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
    "2_illumina/Q25L90:Q25L90:3000000"
    "2_illumina/Q30L60:Q30L60:3000000"
    "2_illumina/Q30L90:Q30L90:2000000"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    GROUP_MAX=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[2];')
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    perl -e 'print 1000000 * $_, qq{\n} for 1 .. 5' \
    | parallel --no-run-if-empty -j 3 "
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
        if [[ ${GROUP_ID} == *'Q30'* ]]; then
            seqtk sample -s{} \
                ${BASE_DIR}/${GROUP_DIR}/Rs.fq.gz {} \
                | pigz -p 4 -c > ${BASE_DIR}/${GROUP_ID}_{}/Rs.fq.gz
        fi
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

        if [ -e ${BASE_DIR}/{}/k_unitigs.fasta ]; then
            echo '    k_unitigs.fasta already presents'
            exit;
        fi

        cd ${BASE_DIR}/{}
        string='My long string'
        if [[ {} == *'Q30'* ]]; then
            anchr superreads \
                R1.fq.gz R2.fq.gz Rs.fq.gz \
                --nosr -p 8 \
                --kmer 41,61,81,101,121,47,65 \
                -o superreads.sh
        else
            anchr superreads \
                R1.fq.gz R2.fq.gz \
                --nosr -p 8 \
                --kmer 41,61,81,101,121,47,65 \
                -o superreads.sh
        fi
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
    | parallel -k --no-run-if-empty -j 3 "
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
    | parallel -k --no-run-if-empty -j 6 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

| Name           |   SumFq | CovFq | AvgRead |                     Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:---------------|--------:|------:|--------:|-------------------------:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| Q20L60_1000000 | 333.64M |  65.5 |     167 | "41,61,81,101,121,47,65" | 259.27M |  22.290% | 5.09M | 5.25M |     1.03 | 5.25M |     0 | 0:06'47'' |
| Q20L60_2000000 | 667.24M | 131.1 |     167 | "41,61,81,101,121,47,65" | 521.25M |  21.879% | 5.09M | 5.46M |     1.07 |  5.3M |     0 | 0:12'04'' |
| Q20L60_3000000 |      1G | 196.7 |     168 | "41,61,81,101,121,47,65" | 785.09M |  21.573% | 5.09M |  5.7M |     1.12 | 4.97M |     0 | 0:17'17'' |
| Q20L90_1000000 | 345.79M |  67.9 |     173 | "41,61,81,101,121,47,65" | 270.89M |  21.662% | 5.09M | 5.27M |     1.03 | 5.28M |     0 | 0:07'28'' |
| Q20L90_2000000 | 691.77M | 135.9 |     173 | "41,61,81,101,121,47,65" | 541.59M |  21.710% | 5.09M | 5.38M |     1.06 | 5.29M |     0 | 0:11'21'' |
| Q20L90_3000000 |   1.04G | 203.8 |     174 | "41,61,81,101,121,47,65" | 819.91M |  20.984% | 5.09M | 5.74M |     1.13 | 4.85M |     0 | 0:17'43'' |
| Q25L60_1000000 | 321.21M |  63.1 |     160 | "41,61,81,101,121,47,65" | 267.81M |  16.625% | 5.09M | 5.24M |     1.03 | 5.23M |     0 | 0:06'27'' |
| Q25L60_2000000 | 642.47M | 126.2 |     161 | "41,61,81,101,121,47,65" | 535.64M |  16.627% | 5.09M | 5.34M |     1.05 | 5.25M |     0 | 0:12'21'' |
| Q25L60_3000000 | 963.68M | 189.3 |     162 | "41,61,81,101,121,47,65" | 804.37M |  16.532% | 5.09M | 5.45M |     1.07 | 5.32M |     0 | 0:16'45'' |
| Q25L90_1000000 | 336.46M |  66.1 |     168 | "41,61,81,101,121,47,65" | 280.77M |  16.551% | 5.09M | 5.24M |     1.03 | 5.19M |     0 | 0:07'12'' |
| Q25L90_2000000 |  672.8M | 132.2 |     169 | "41,61,81,101,121,47,65" | 562.23M |  16.435% | 5.09M | 5.36M |     1.05 | 5.27M |     0 | 0:11'16'' |
| Q25L90_3000000 | 967.24M | 190.0 |     169 | "41,61,81,101,121,47,65" | 809.48M |  16.310% | 5.09M | 5.47M |     1.07 | 5.33M |     0 | 0:15'14'' |
| Q30L60_1000000 | 301.83M |  59.3 |     151 | "41,61,81,101,121,47,65" | 363.71M | -20.499% | 5.09M | 5.25M |     1.03 | 5.17M |     0 | 0:07'19'' |
| Q30L60_2000000 | 603.55M | 118.6 |     153 | "41,61,81,101,121,47,65" |  627.4M |  -3.950% | 5.09M | 5.34M |     1.05 | 5.24M |     0 | 0:11'27'' |
| Q30L60_3000000 | 828.46M | 162.7 |     153 | "41,61,81,101,121,47,65" | 824.29M |   0.503% | 5.09M | 5.41M |     1.06 | 5.29M |     0 | 0:14'02'' |
| Q30L90_1000000 | 321.78M |  63.2 |     161 | "41,61,81,101,121,47,65" | 408.01M | -26.799% | 5.09M | 5.26M |     1.03 | 5.18M |     0 | 0:08'13'' |
| Q30L90_2000000 | 643.47M | 126.4 |     162 | "41,61,81,101,121,47,65" | 707.96M | -10.021% | 5.09M | 5.38M |     1.06 | 5.27M |     0 | 0:12'38'' |

| Name           | N50SR |   Sum |    # | N50Anchor |   Sum |    # | N50Others |     Sum |    # |   RunTime |
|:---------------|------:|------:|-----:|----------:|------:|-----:|----------:|--------:|-----:|----------:|
| Q20L60_1000000 |  7785 | 5.25M | 1096 |      7881 | 5.15M |  963 |       805 | 102.48K |  133 | 0:00'53'' |
| Q20L60_2000000 |  2182 |  5.3M | 3097 |      2492 | 4.48M | 1992 |       774 | 819.05K | 1105 | 0:01'14'' |
| Q20L60_3000000 |  1178 | 4.97M | 4635 |      1613 |    3M | 1883 |       740 |   1.97M | 2752 | 0:01'51'' |
| Q20L90_1000000 |  5825 | 5.28M | 1353 |      5980 | 5.11M | 1119 |       756 | 170.15K |  234 | 0:00'56'' |
| Q20L90_2000000 |  4278 | 5.29M | 1777 |      4436 | 5.03M | 1417 |       778 | 264.04K |  360 | 0:01'38'' |
| Q20L90_3000000 |  1087 | 4.85M | 4836 |      1478 | 2.68M | 1776 |       733 |   2.17M | 3060 | 0:01'49'' |
| Q25L60_1000000 |  8569 | 5.23M |  947 |      8643 | 5.15M |  831 |       793 |  85.87K |  116 | 0:01'01'' |
| Q25L60_2000000 |  7354 | 5.25M | 1105 |      7544 | 5.14M |  953 |       742 | 110.46K |  152 | 0:01'39'' |
| Q25L60_3000000 |  3375 | 5.32M | 2208 |      3523 | 4.94M | 1699 |       764 | 377.31K |  509 | 0:02'08'' |
| Q25L90_1000000 | 16852 | 5.19M |  527 |     16874 | 5.17M |  492 |       739 |  24.79K |   35 | 0:01'01'' |
| Q25L90_2000000 |  5947 | 5.27M | 1314 |      6085 | 5.12M | 1119 |       802 | 147.73K |  195 | 0:01'50'' |
| Q25L90_3000000 |  3000 | 5.33M | 2454 |      3216 | 4.85M | 1803 |       780 | 483.27K |  651 | 0:02'25'' |
| Q30L60_1000000 | 21830 | 5.17M |  371 |     21830 | 5.15M |  343 |       756 |   19.6K |   28 | 0:01'43'' |
| Q30L60_2000000 |  8821 | 5.24M |  940 |      8929 | 5.16M |  836 |       774 |  77.14K |  104 | 0:02'00'' |
| Q30L60_3000000 |  4581 | 5.29M | 1659 |      4763 | 5.06M | 1347 |       774 | 228.91K |  312 | 0:02'44'' |
| Q30L90_1000000 | 18548 | 5.18M |  473 |     18548 | 5.15M |  440 |       894 |  34.12K |   33 | 0:01'26'' |
| Q30L90_2000000 |  5922 | 5.27M | 1350 |      6053 | 5.11M | 1141 |       790 | 156.01K |  209 | 0:01'49'' |

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
    Q25L60_3000000/anchor/pe.anchor.fa \
    Q25L90_1000000/anchor/pe.anchor.fa \
    Q25L90_2000000/anchor/pe.anchor.fa \
    Q25L90_3000000/anchor/pe.anchor.fa \
    Q30L60_1000000/anchor/pe.anchor.fa \
    Q30L60_2000000/anchor/pe.anchor.fa \
    Q30L60_3000000/anchor/pe.anchor.fa \
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
    8_competitor/cabog_ctg.fasta \
    8_competitor/mira_ctg.fasta \
    8_competitor/msrca_ctg.fasta \
    8_competitor/sga_ctg.fasta \
    8_competitor/soap_ctg.fasta \
    8_competitor/spades_ctg.fasta \
    8_competitor/velvet_ctg.fasta \
    merge/anchor.merge.fasta \
    1_genome/paralogs.fas \
    --label "abyss,cabog,mira,msrca,sga,soap,spades,velvet,merge,paralogs" \
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

| Name         |     N50 |     Sum |  # |
|:-------------|--------:|--------:|---:|
| Genome       | 5067172 | 5090491 |  2 |
| Paralogs     |    1580 |   83364 | 53 |
| anchor.merge |  125354 | 5191435 | 73 |
| others.merge |    1091 |   43179 | 34 |

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/Mabs
cd ${BASE_DIR}

#rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

# *Vibrio cholerae* CP1032(5)

## Vcho: download

* Reference genome

    * *Vibrio cholerae* O1 biovar El Tor str. N16961
        * Taxid: [243277](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=243277)
        * RefSeq assembly accession:
          [GCF_000006745.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/006/745/GCF_000006745.1_ASM674v1/GCF_000006745.1_ASM674v1_assembly_report.txt)
        * Proportion of paralogs (> 1000 bp): 0.0210
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
tar xvfz V_cholerae_MiSeq.tar.gz cabog_ctg.fasta
tar xvfz V_cholerae_MiSeq.tar.gz mira_ctg.fasta
tar xvfz V_cholerae_MiSeq.tar.gz msrca_ctg.fasta
tar xvfz V_cholerae_MiSeq.tar.gz sga_ctg.fasta
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
    " ::: 20 25 30 ::: 60 90

```

* kmergenie

```bash
BASE_NAME=Vcho

mkdir -p $HOME/data/anchr/${BASE_NAME}/2_illumina/kmergenie
cd $HOME/data/anchr/${BASE_NAME}/2_illumina/kmergenie

kmergenie -l 21 -k 151 -s 10 -t 8 ../R1.fq.gz -o oriR1
kmergenie -l 21 -k 151 -s 10 -t 8 ../R2.fq.gz -o oriR2
kmergenie -l 21 -k 151 -s 10 -t 8 ../Q20L60/R1.fq.gz -o Q20L60R1
kmergenie -l 21 -k 151 -s 10 -t 8 ../Q20L60/R2.fq.gz -o Q20L60R2

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
    $(echo "Paralogs"; faops n50 -H -S -C 1_genome/paralogs.fas;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "PacBio";   faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
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
| PacBio   |         |            |         |
| Illumina |     251 | 1762158050 | 7020550 |
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
    "2_illumina/Q25L90:Q25L90:3000000"
    "2_illumina/Q30L60:Q30L60:3000000"
    "2_illumina/Q30L90:Q30L90:3000000"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(perl -e "@p = split q{:}, q{${group}}; print \$p[0];")
    GROUP_ID=$( perl -e "@p = split q{:}, q{${group}}; print \$p[1];")
    GROUP_MAX=$(perl -e "@p = split q{:}, q{${group}}; print \$p[2];")
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    perl -e 'print 1000000 * $_, qq{\n} for 1 .. 5' \
    | parallel --no-run-if-empty -j 3 "
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
        if [[ ${GROUP_ID} == *'Q30'* ]]; then
            seqtk sample -s{} \
                ${BASE_DIR}/${GROUP_DIR}/Rs.fq.gz {} \
                | pigz -p 4 -c > ${BASE_DIR}/${GROUP_ID}_{}/Rs.fq.gz
        fi
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
        string='My long string'
        if [[ {} == *'Q30'* ]]; then
            anchr superreads \
                R1.fq.gz R2.fq.gz Rs.fq.gz \
                --nosr -p 8 \
                --kmer 41,61,81,101,121,49,57 \
                -o superreads.sh
        else
            anchr superreads \
                R1.fq.gz R2.fq.gz \
                --nosr -p 8 \
                --kmer 41,61,81,101,121,49,57 \
                -o superreads.sh
        fi
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
    | parallel -k --no-run-if-empty -j 3 "
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
    | parallel -k --no-run-if-empty -j 6 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

| Name           |   SumFq | CovFq | AvgRead |                     Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:---------------|--------:|------:|--------:|-------------------------:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| Q20L60_1000000 | 366.77M |  90.9 |     183 | "41,61,81,101,121,49,57" | 294.99M |  19.571% | 4.03M |    4M |     0.99 | 4.01M |     0 | 0:06'31'' |
| Q20L60_2000000 | 733.48M | 181.8 |     184 | "41,61,81,101,121,49,57" | 592.22M |  19.259% | 4.03M | 4.18M |     1.04 | 3.96M |     0 | 0:11'49'' |
| Q20L60_3000000 |    1.1G | 272.8 |     184 | "41,61,81,101,121,49,57" | 891.78M |  18.957% | 4.03M | 4.46M |     1.11 | 3.58M |     0 | 0:16'58'' |
| Q20L90_1000000 | 370.69M |  91.9 |     185 | "41,61,81,101,121,49,57" | 298.24M |  19.544% | 4.03M | 3.98M |     0.99 | 3.98M |     0 | 0:06'40'' |
| Q20L90_2000000 | 741.44M | 183.8 |     186 | "41,61,81,101,121,49,57" | 600.65M |  18.989% | 4.03M |  4.2M |     1.04 | 3.96M |     0 | 0:12'09'' |
| Q20L90_3000000 |   1.11G | 275.7 |     186 | "41,61,81,101,121,49,57" | 903.94M |  18.717% | 4.03M | 4.48M |     1.11 | 3.56M |     0 | 0:19'14'' |
| Q25L60_1000000 | 358.69M |  88.9 |     179 | "41,61,81,101,121,49,57" | 304.06M |  15.232% | 4.03M | 3.97M |     0.98 | 3.98M |     0 | 0:07'35'' |
| Q25L60_2000000 | 717.57M | 177.9 |     180 | "41,61,81,101,121,49,57" | 609.57M |  15.050% | 4.03M | 4.08M |     1.01 | 4.03M |     0 | 0:16'21'' |
| Q25L60_3000000 |   1.08G | 266.8 |     181 | "41,61,81,101,121,49,57" | 919.18M |  14.586% | 4.03M | 4.35M |     1.08 | 3.77M |     0 | 0:22'39'' |
| Q25L90_1000000 | 363.97M |  90.2 |     182 | "41,61,81,101,121,49,57" | 309.19M |  15.050% | 4.03M | 3.97M |     0.99 | 3.98M |     0 | 0:08'55'' |
| Q25L90_2000000 | 727.95M | 180.5 |     183 | "41,61,81,101,121,49,57" | 619.35M |  14.919% | 4.03M |  4.1M |     1.02 | 4.03M |     0 | 0:15'38'' |
| Q25L90_3000000 |   1.07G | 265.4 |     183 | "41,61,81,101,121,49,57" | 915.94M |  14.451% | 4.03M | 4.36M |     1.08 | 3.76M |     0 | 0:25'02'' |
| Q30L60_1000000 | 345.57M |  85.7 |     172 | "41,61,81,101,121,49,57" | 352.48M |  -1.998% | 4.03M | 3.97M |     0.98 | 3.98M |     0 | 0:10'49'' |
| Q30L60_2000000 | 690.97M | 171.3 |     174 | "41,61,81,101,121,49,57" | 658.73M |   4.666% | 4.03M | 4.06M |     1.01 | 4.04M |     0 | 0:14'27'' |
| Q30L60_3000000 | 943.13M | 233.8 |     174 | "41,61,81,101,121,49,57" | 882.69M |   6.408% | 4.03M | 4.16M |     1.03 | 4.02M |     0 | 0:20'14'' |
| Q30L90_1000000 | 352.52M |  87.4 |     176 | "41,61,81,101,121,49,57" | 373.98M |  -6.085% | 4.03M | 3.97M |     0.98 | 3.99M |     0 | 0:09'31'' |
| Q30L90_2000000 | 705.18M | 174.8 |     178 | "41,61,81,101,121,49,57" |  686.6M |   2.634% | 4.03M | 4.07M |     1.01 | 4.04M |     0 | 0:15'30'' |
| Q30L90_3000000 | 907.44M | 225.0 |     178 | "41,61,81,101,121,49,57" | 866.31M |   4.532% | 4.03M | 4.15M |     1.03 | 4.02M |     0 | 0:17'08'' |

| Name           | N50SR |   Sum |    # | N50Anchor |   Sum |    # | N50Others |     Sum |    # |   RunTime |
|:---------------|------:|------:|-----:|----------:|------:|-----:|----------:|--------:|-----:|----------:|
| Q20L60_1000000 |  5694 | 4.01M | 1117 |      6035 | 3.86M |  917 |       790 | 148.34K |  200 | 0:02'20'' |
| Q20L60_2000000 |  1810 | 3.96M | 2660 |      2215 | 3.14M | 1548 |       771 | 818.02K | 1112 | 0:03'18'' |
| Q20L60_3000000 |  1077 | 3.58M | 3540 |      1519 | 1.97M | 1272 |       731 |   1.61M | 2268 | 0:04'07'' |
| Q20L90_1000000 | 10590 | 3.98M |  653 |     10834 | 3.91M |  554 |       792 |  73.78K |   99 | 0:01'40'' |
| Q20L90_2000000 |  1766 | 3.96M | 2713 |      2172 | 3.08M | 1521 |       762 | 872.89K | 1192 | 0:02'07'' |
| Q20L90_3000000 |  1065 | 3.56M | 3559 |      1530 | 1.91M | 1227 |       726 |   1.65M | 2332 | 0:02'30'' |
| Q25L60_1000000 | 12448 | 3.98M |  572 |     12613 | 3.91M |  474 |       777 |  72.01K |   98 | 0:01'40'' |
| Q25L60_2000000 |  3817 | 4.03M | 1508 |      4187 | 3.76M | 1144 |       797 | 270.47K |  364 | 0:02'32'' |
| Q25L60_3000000 |  1222 | 3.77M | 3407 |      1648 | 2.35M | 1425 |       741 |   1.42M | 1982 | 0:03'01'' |
| Q25L90_1000000 | 11817 | 3.98M |  611 |     11827 | 3.91M |  512 |       717 |  71.01K |   99 | 0:01'38'' |
| Q25L90_2000000 |  3547 | 4.03M | 1597 |      3729 | 3.73M | 1188 |       767 | 300.18K |  409 | 0:02'42'' |
| Q25L90_3000000 |  1199 | 3.76M | 3442 |      1636 | 2.32M | 1425 |       740 |   1.44M | 2017 | 0:02'57'' |
| Q30L60_1000000 | 11297 | 3.98M |  591 |     11438 | 3.92M |  504 |       781 |   65.4K |   87 | 0:02'03'' |
| Q30L60_2000000 |  3915 | 4.04M | 1507 |      4290 | 3.75M | 1118 |       791 | 288.42K |  389 | 0:03'05'' |
| Q30L60_3000000 |  2446 | 4.02M | 2193 |      2773 | 3.47M | 1441 |       777 | 554.69K |  752 | 0:03'21'' |
| Q30L90_1000000 | 11309 | 3.99M |  639 |     11539 | 3.92M |  550 |       742 |  65.05K |   89 | 0:01'56'' |
| Q30L90_2000000 |  3586 | 4.04M | 1586 |      3820 | 3.74M | 1189 |       801 | 297.39K |  397 | 0:02'55'' |
| Q30L90_3000000 |  2472 | 4.02M | 2161 |      2805 | 3.49M | 1437 |       778 | 534.17K |  724 | 0:03'14'' |

## Vcho: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/Vcho
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L60_1000000/anchor/pe.anchor.fa \
    Q20L60_2000000/anchor/pe.anchor.fa \
    Q20L60_3000000/anchor/pe.anchor.fa \
    Q20L90_1000000/anchor/pe.anchor.fa \
    Q20L90_2000000/anchor/pe.anchor.fa \
    Q20L90_3000000/anchor/pe.anchor.fa \
    Q25L60_1000000/anchor/pe.anchor.fa \
    Q25L60_2000000/anchor/pe.anchor.fa \
    Q25L60_3000000/anchor/pe.anchor.fa \
    Q25L90_1000000/anchor/pe.anchor.fa \
    Q25L90_2000000/anchor/pe.anchor.fa \
    Q25L90_3000000/anchor/pe.anchor.fa \
    Q30L60_1000000/anchor/pe.anchor.fa \
    Q30L60_2000000/anchor/pe.anchor.fa \
    Q30L60_3000000/anchor/pe.anchor.fa \
    Q30L90_1000000/anchor/pe.anchor.fa \
    Q30L90_2000000/anchor/pe.anchor.fa \
    Q30L90_3000000/anchor/pe.anchor.fa \
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
    8_competitor/cabog_ctg.fasta \
    8_competitor/mira_ctg.fasta \
    8_competitor/msrca_ctg.fasta \
    8_competitor/sga_ctg.fasta \
    8_competitor/soap_ctg.fasta \
    8_competitor/spades_ctg.fasta \
    8_competitor/velvet_ctg.fasta \
    merge/anchor.merge.fasta \
    1_genome/paralogs.fas \
    --label "abyss,cabog,mira,msrca,sga,soap,spades,velvet,merge,paralogs" \
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
| anchor.merge |  129906 | 3919984 | 95 |
| others.merge |    1018 |   12684 | 12 |

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/Vcho
cd ${BASE_DIR}

#rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

# *Vibrio cholerae* CP1032(5) HiSeq

## VchoH: download

* Reference genome

```bash
mkdir -p ~/data/anchr/VchoH/1_genome
cd ~/data/anchr/VchoH/1_genome

cp ~/data/anchr/Vcho/1_genome/genome.fa .
cp ~/data/anchr/Vcho/1_genome/paralogs.fas .

```

* Illumina

    Download from GAGE-B site.

```bash
mkdir -p ~/data/anchr/VchoH/2_illumina
cd ~/data/anchr/VchoH/2_illumina

aria2c -x 9 -s 3 -c http://ccb.jhu.edu/gage_b/datasets/V_cholerae_HiSeq.tar.gz

# NOT gzipped tar
tar xvf V_cholerae_HiSeq.tar.gz raw/reads_1.fastq
tar xvf V_cholerae_HiSeq.tar.gz raw/reads_2.fastq

cat raw/reads_1.fastq \
    | pigz -p 8 -c \
    > R1.fq.gz
cat raw/reads_2.fastq \
    | pigz -p 8 -c \
    > R2.fq.gz

rm -fr raw
```

* GAGE-B assemblies

```bash
mkdir -p ~/data/anchr/VchoH/8_competitor
cd ~/data/anchr/VchoH/8_competitor

aria2c -x 9 -s 3 -c http://ccb.jhu.edu/gage_b/genomeAssemblies/V_cholerae_HiSeq.tar.gz

tar xvfz V_cholerae_HiSeq.tar.gz abyss_ctg.fasta
tar xvfz V_cholerae_HiSeq.tar.gz sga_ctg.fasta
tar xvfz V_cholerae_HiSeq.tar.gz soap_ctg.fasta
tar xvfz V_cholerae_HiSeq.tar.gz spades_ctg.fasta
tar xvfz V_cholerae_HiSeq.tar.gz velvet_ctg.fasta

```

## VchoH: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60

```bash
BASE_DIR=$HOME/data/anchr/VchoH

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
    " ::: 20 25 30 ::: 60

```

* Stats

```bash
BASE_DIR=$HOME/data/anchr/VchoH
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
    for len in 60; do
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
| Genome   | 2961149 |   4033464 |       2 |
| Paralogs |    3483 |    114707 |      48 |
| Illumina |     100 | 392009000 | 3920090 |
| PacBio   |         |           |         |
| uniq     |     100 | 362904400 | 3629044 |
| scythe   |     100 | 362679873 | 3629044 |
| Q20L60   |     100 | 362528513 | 3626022 |
| Q25L60   |     100 | 362528513 | 3626022 |
| Q30L60   |     100 | 362528513 | 3626022 |

## VchoH: down sampling

```bash
BASE_DIR=$HOME/data/anchr/VchoH

cd ${BASE_DIR}
ARRAY=(
    "2_illumina/Q30L60:Q30L60"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(perl -e "@p = split q{:}, q{${group}}; print \$p[0];")
    GROUP_ID=$( perl -e "@p = split q{:}, q{${group}}; print \$p[1];")
    GROUP_MAX=$(perl -e "@p = split q{:}, q{${group}}; print \$p[2];")
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

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

## VchoH: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/VchoH
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q30L60
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
            --kmer 41,51,61,71,81 \
            -o superreads.sh
        bash superreads.sh
    "

```

Clear intermediate files.

```bash
BASE_DIR=$HOME/data/anchr/VchoH
cd ${BASE_DIR}

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## VchoH: create anchors

```bash
BASE_DIR=$HOME/data/anchr/VchoH
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q30L60
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

## VchoH: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/VchoH
cd ${BASE_DIR}

REAL_G=4033464

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

perl -e '
    for my $n (
        qw{
        Q30L60
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
BASE_DIR=$HOME/data/anchr/VchoH
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

perl -e '
    for my $n (
        qw{
        Q30L60
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

| Name   |   SumFq | CovFq | AvgRead |             Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:-------|--------:|------:|--------:|-----------------:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| Q30L60 | 362.53M |  89.9 |      99 | "41,51,61,71,81" | 228.59M |  36.946% | 4.03M | 4.05M |     1.00 | 3.87M |     0 | 0:04'09'' |

| Name   | N50SR |   Sum |    # | N50Anchor |   Sum |    # | N50Others |     Sum |    # |   RunTime |
|:-------|------:|------:|-----:|----------:|------:|-----:|----------:|--------:|-----:|----------:|
| Q30L60 |  1869 | 3.87M | 2582 |      2273 | 3.04M | 1450 |       761 | 827.95K | 1132 | 0:01'21'' |

## VchoH: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/VchoH
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q30L60/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
anchr contained \
    Q30L60/anchor/pe.others.fa \
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
    8_competitor/sga_ctg.fasta \
    8_competitor/soap_ctg.fasta \
    8_competitor/spades_ctg.fasta \
    8_competitor/velvet_ctg.fasta \
    merge/anchor.merge.fasta \
    1_genome/paralogs.fas \
    --label "abyss,sga,soap,spades,velvet,merge,paralogs" \
    -o 9_qa

```

* Stats

```bash
BASE_DIR=$HOME/data/anchr/VchoH
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

| Name         |     N50 |     Sum |    # |
|:-------------|--------:|--------:|-----:|
| Genome       | 2961149 | 4033464 |    2 |
| Paralogs     |    3483 |  114707 |   48 |
| anchor.merge |    2273 | 3042187 | 1450 |
| others.merge |    1067 |   39645 |   35 |
