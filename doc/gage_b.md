# Assemble four genomes from GAGE-B data sets by ANCHR

[TOC levels=1-3]: # " "
- [Assemble four genomes from GAGE-B data sets by ANCHR](#assemble-four-genomes-from-gage-b-data-sets-by-anchr)
- [*Bacillus cereus* ATCC 10987](#bacillus-cereus-atcc-10987)
    - [Bcer: download](#bcer-download)
    - [Bcer: combinations of different quality values and read lengths](#bcer-combinations-of-different-quality-values-and-read-lengths)
    - [Bcer: quorum](#bcer-quorum)
    - [Bcer: generate k-unitigs](#bcer-generate-k-unitigs)
    - [Bcer: create anchors](#bcer-create-anchors)
    - [Bcer: merge anchors](#bcer-merge-anchors)
- [*Rhodobacter sphaeroides* 2.4.1](#rhodobacter-sphaeroides-241)
    - [Rsph: download](#rsph-download)
    - [Rsph: combinations of different quality values and read lengths](#rsph-combinations-of-different-quality-values-and-read-lengths)
    - [Rsph: quorum](#rsph-quorum)
    - [Rsph: generate k-unitigs](#rsph-generate-k-unitigs)
    - [Rsph: create anchors](#rsph-create-anchors)
    - [Rsph: merge anchors](#rsph-merge-anchors)
- [*Mycobacterium abscessus* 6G-0125-R](#mycobacterium-abscessus-6g-0125-r)
    - [Mabs: download](#mabs-download)
    - [Mabs: combinations of different quality values and read lengths](#mabs-combinations-of-different-quality-values-and-read-lengths)
    - [Mabs: quorum](#mabs-quorum)
    - [Mabs: generate k-unitigs](#mabs-generate-k-unitigs)
    - [Mabs: create anchors](#mabs-create-anchors)
    - [Mabs: merge anchors](#mabs-merge-anchors)
- [*Vibrio cholerae* CP1032(5)](#vibrio-cholerae-cp10325)
    - [Vcho: download](#vcho-download)
    - [Vcho: combinations of different quality values and read lengths](#vcho-combinations-of-different-quality-values-and-read-lengths)
    - [Vcho: quorum](#vcho-quorum)
    - [Vcho: generate k-unitigs](#vcho-generate-k-unitigs)
    - [Vcho: create anchors](#vcho-create-anchors)
    - [Vcho: results](#vcho-results)
    - [Vcho: merge anchors](#vcho-merge-anchors)
- [*Mycobacterium abscessus* 6G-0125-R Full](#mycobacterium-abscessus-6g-0125-r-full)
    - [MabsF: download](#mabsf-download)
    - [MabsF: combinations of different quality values and read lengths](#mabsf-combinations-of-different-quality-values-and-read-lengths)
    - [MabsF: quorum](#mabsf-quorum)
    - [MabsF: down sampling](#mabsf-down-sampling)
    - [MabsF: generate k-unitigs (sampled)](#mabsf-generate-k-unitigs-sampled)
    - [MabsF: create anchors (sampled)](#mabsf-create-anchors-sampled)
    - [MabsF: merge anchors](#mabsf-merge-anchors)
- [*Rhodobacter sphaeroides* 2.4.1 Full](#rhodobacter-sphaeroides-241-full)
    - [RsphF: download](#rsphf-download)
    - [RsphF: combinations of different quality values and read lengths](#rsphf-combinations-of-different-quality-values-and-read-lengths)
    - [RsphF: quorum](#rsphf-quorum)
    - [RsphF: down sampling](#rsphf-down-sampling)
    - [RsphF: generate k-unitigs (sampled)](#rsphf-generate-k-unitigs-sampled)
    - [RsphF: create anchors (sampled)](#rsphf-create-anchors-sampled)
    - [RsphF: merge anchors](#rsphf-merge-anchors)
- [*Vibrio cholerae* CP1032(5) Full](#vibrio-cholerae-cp10325-full)
    - [VchoF: download](#vchof-download)
    - [VchoF: combinations of different quality values and read lengths](#vchof-combinations-of-different-quality-values-and-read-lengths)
    - [VchoF: quorum](#vchof-quorum)
    - [VchoF: down sampling](#vchof-down-sampling)
    - [VchoF: generate k-unitigs (sampled)](#vchof-generate-k-unitigs-sampled)
    - [VchoF: create anchors (sampled)](#vchof-create-anchors-sampled)
    - [VchoF: merge anchors](#vchof-merge-anchors)


# *Bacillus cereus* ATCC 10987

## Bcer: download

* Reference genome

    * Strain: Bacillus cereus ATCC 10987
    * Taxid: [222523](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=222523)
    * RefSeq assembly accession:
      [GCF_000008005.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/005/GCF_000008005.1_ASM800v1/GCF_000008005.1_ASM800v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0797

```bash
BASE_NAME=Bcer
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 1_genome
cd 1_genome

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
BASE_NAME=Bcer
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina
cd 2_illumina

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
BASE_NAME=Bcer
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 8_competitor
cd 8_competitor

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

* FastQC

```bash
BASE_NAME=Bcer
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

## Bcer: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60 and 90

```bash
BASE_NAME=Bcer
cd ${HOME}/data/anchr/${BASE_NAME}

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
        ../R1.uniq.fq.gz ../R2.uniq.fq.gz \
        -o stdout \
        | bash
    " ::: 20 25 30 ::: 50 60 90 120 150

```

* Stats

```bash
BASE_NAME=Bcer
cd ${HOME}/data/anchr/${BASE_NAME}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Paralogs"; faops n50 -H -S -C 1_genome/paralogs.fas;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md

parallel -k --no-run-if-empty -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo Q{1}L{2};
            if [[ {1} == '30' ]]; then
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz \
                    2_illumina/Q{1}L{2}/Rs.fq.gz;
            else
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz;
            fi
        )
    " ::: 20 25 30 ::: 50 60 90 120 150 \
    >> stat.md

cat stat.md
```

| Name     |     N50 |       Sum |       # |
|:---------|--------:|----------:|--------:|
| Genome   | 5224283 |   5432652 |       2 |
| Paralogs |    2295 |    223889 |     103 |
| Illumina |     251 | 481020311 | 2080000 |
| uniq     |     251 | 480993557 | 2079856 |
| Q20L50   |     250 | 418201416 | 1853818 |
| Q20L60   |     250 | 413565637 | 1820298 |
| Q20L90   |     250 | 399014064 | 1722610 |
| Q20L120  |     250 | 379863230 | 1606970 |
| Q20L150  |     250 | 355741434 | 1474732 |
| Q25L50   |     250 | 386828032 | 1751668 |
| Q25L60   |     250 | 381755768 | 1713804 |
| Q25L90   |     250 | 366630183 | 1610142 |
| Q25L120  |     250 | 346644557 | 1487854 |
| Q25L150  |     250 | 320301035 | 1342642 |
| Q30L50   |     250 | 373400998 | 1780992 |
| Q30L60   |     250 | 371873795 | 1752907 |
| Q30L90   |     250 | 366362011 | 1678716 |
| Q30L120  |     250 | 356595645 | 1586227 |
| Q30L150  |     250 | 339876003 | 1462107 |

## Bcer: quorum

```bash
BASE_NAME=Bcer
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 1 "
    cd 2_illumina/Q{1}L{2}
    echo >&2 '==> Group Q{1}L{2} <=='

    if [ ! -e R1.fq.gz ]; then
        echo >&2 '    R1.fq.gz not exists'
        exit;
    fi

    if [ -e pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa exists'
        exit;
    fi

    if [[ {1} == '30' ]]; then
        anchr quorum \
            R1.fq.gz R2.fq.gz Rs.fq.gz \
            -p 16 \
            -o quorum.sh
    else
        anchr quorum \
            R1.fq.gz R2.fq.gz \
            -p 16 \
            -o quorum.sh
    fi

    bash quorum.sh
    
    echo >&2
    " ::: 20 25 30 ::: 50 60 90 120 150

```

Clear intermediate files.

```bash
BASE_NAME=Bcer
cd $HOME/data/anchr/${BASE_NAME}

find 2_illumina -type f -name "quorum_mer_db.jf" | xargs rm
find 2_illumina -type f -name "k_u_hash_0"       | xargs rm
find 2_illumina -type f -name "*.tmp"            | xargs rm
find 2_illumina -type f -name "pe.renamed.fastq" | xargs rm
find 2_illumina -type f -name "se.renamed.fastq" | xargs rm
find 2_illumina -type f -name "pe.cor.sub.fa"    | xargs rm
```

* Stats of processed reads

```bash
BASE_NAME=Bcer
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=5432652

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > stat1.md

parallel -k --no-run-if-empty -j 3 "
    if [ ! -d 2_illumina/Q{1}L{2} ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 2_illumina/Q{1}L{2} ${REAL_G}
    " ::: 20 25 30 ::: 50 60 90 120 150 \
     >> stat1.md

cat stat1.md
```

| Name    |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:--------|--------:|------:|--------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q20L50  |  418.2M |  77.0 | 355.25M |   65.4 |  15.053% |     222 | "127" | 5.43M | 5.36M |     0.99 | 0:01'32'' |
| Q20L60  | 413.57M |  76.1 | 351.41M |   64.7 |  15.029% |     224 | "127" | 5.43M | 5.36M |     0.99 | 0:01'30'' |
| Q20L90  | 399.01M |  73.4 | 339.36M |   62.5 |  14.950% |     228 | "127" | 5.43M | 5.35M |     0.99 | 0:01'21'' |
| Q20L120 | 379.86M |  69.9 | 323.97M |   59.6 |  14.715% |     233 | "127" | 5.43M | 5.35M |     0.98 | 0:01'29'' |
| Q20L150 | 355.74M |  65.5 | 304.85M |   56.1 |  14.307% |     239 | "127" | 5.43M | 5.34M |     0.98 | 0:01'25'' |
| Q25L50  | 386.83M |  71.2 | 348.03M |   64.1 |  10.030% |     216 | "127" | 5.43M | 5.34M |     0.98 | 0:01'29'' |
| Q25L60  | 381.76M |  70.3 | 343.49M |   63.2 |  10.023% |     218 | "127" | 5.43M | 5.34M |     0.98 | 0:01'18'' |
| Q25L90  | 366.63M |  67.5 | 329.99M |   60.7 |   9.994% |     224 | "127" | 5.43M | 5.34M |     0.98 | 0:01'15'' |
| Q25L120 | 346.64M |  63.8 | 312.33M |   57.5 |   9.900% |     229 | "127" | 5.43M | 5.34M |     0.98 | 0:01'23'' |
| Q25L150 |  320.3M |  59.0 | 289.05M |   53.2 |   9.757% |     236 | "127" | 5.43M | 5.34M |     0.98 | 0:01'21'' |
| Q30L50  | 373.59M |  68.8 | 349.89M |   64.4 |   6.345% |     208 | "119" | 5.43M | 5.34M |     0.98 | 0:01'33'' |
| Q30L60  | 372.08M |  68.5 | 348.42M |   64.1 |   6.360% |     210 | "121" | 5.43M | 5.34M |     0.98 | 0:01'16'' |
| Q30L90  |  366.6M |  67.5 |  343.3M |   63.2 |   6.356% |     216 | "127" | 5.43M | 5.34M |     0.98 | 0:01'13'' |
| Q30L120 | 356.88M |  65.7 | 334.06M |   61.5 |   6.394% |     222 | "127" | 5.43M | 5.34M |     0.98 | 0:01'26'' |
| Q30L150 |  340.2M |  62.6 | 318.28M |   58.6 |   6.445% |     230 | "127" | 5.43M | 5.34M |     0.98 | 0:01'28'' |

* kmergenie

```bash
BASE_NAME=Bcer
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

kmergenie -l 21 -k 151 -s 10 -t 8 ../R1.fq.gz -o oriR1
kmergenie -l 21 -k 151 -s 10 -t 8 ../R2.fq.gz -o oriR2
kmergenie -l 21 -k 151 -s 10 -t 8 ../Q20L60/pe.cor.fa -o Q20L60

```

## Bcer: generate k-unitigs

```bash
BASE_NAME=Bcer
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 1 "
    echo >&2 '==> Group Q{1}L{2} '

    if [ -e Q{1}L{2}/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi
    
    mkdir -p Q{1}L{2}
    cd Q{1}L{2}

    anchr kunitigs \
        ../2_illumina/Q{1}L{2}/pe.cor.fa \
        ../2_illumina/Q{1}L{2}/environment.json \
        -p 16 \
        --kmer 31,41,51,61,71,81,101,121,59,91 \
        -o kunitigs.sh
    bash kunitigs.sh
    
    echo >&2
    " ::: 20 25 30 ::: 50 60 90 120 150

```

## Bcer: create anchors

```bash
BASE_NAME=Bcer
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 3 "
    echo >&2 '==> Group Q{1}L{2}'

    if [ -e Q{1}L{2}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    rm -fr Q{1}L{2}/anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh Q{1}L{2} 8 false
    
    echo >&2
    " ::: 20 25 30 ::: 50 60 90 120 150

```

* Stats of anchors

```bash
BASE_NAME=Bcer
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=5432652

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > stat2.md

parallel -k --no-run-if-empty -j 6 "
    if [ ! -e Q{1}L{2}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 Q{1}L{2} ${REAL_G}
    " ::: 20 25 30 ::: 50 60 90 120 150 \
     >> stat2.md

cat stat2.md
```

| Name    |  SumCor | CovCor | N50SR |   Sum |   # | N50Anchor |   Sum |   # | N50Others |    Sum |  # |                              Kmer | RunTimeKU | RunTimeAN |
|:--------|--------:|-------:|------:|------:|----:|----------:|------:|----:|----------:|-------:|---:|----------------------------------:|----------:|:----------|
| Q20L50  | 355.25M |   65.4 | 22987 | 5.37M | 392 |     22987 | 5.35M | 362 |       773 | 21.99K | 30 | "31,41,51,59,61,71,81,91,101,121" | 0:05'33'' | 0:02'00'' |
| Q20L60  | 351.41M |   64.7 | 23260 | 5.37M | 386 |     23260 | 5.35M | 356 |       773 | 21.91K | 30 | "31,41,51,59,61,71,81,91,101,121" | 0:05'25'' | 0:02'09'' |
| Q20L90  | 339.36M |   62.5 | 23977 | 5.37M | 373 |     24091 | 5.35M | 342 |       770 | 22.21K | 31 | "31,41,51,59,61,71,81,91,101,121" | 0:05'47'' | 0:01'59'' |
| Q20L120 | 323.97M |   59.6 | 25917 | 5.36M | 346 |     25917 | 5.35M | 319 |       756 | 19.02K | 27 | "31,41,51,59,61,71,81,91,101,121" | 0:05'30'' | 0:02'01'' |
| Q20L150 | 304.85M |   56.1 | 28540 | 5.36M | 316 |     28540 | 5.35M | 295 |       773 |  15.4K | 21 | "31,41,51,59,61,71,81,91,101,121" | 0:05'23'' | 0:01'53'' |
| Q25L50  | 348.03M |   64.1 | 42085 | 5.37M | 237 |     42180 | 5.33M | 214 |     27296 | 42.35K | 23 | "31,41,51,59,61,71,81,91,101,121" | 0:05'41'' | 0:02'08'' |
| Q25L60  | 343.49M |   63.2 | 42812 | 5.36M | 237 |     42812 | 5.34M | 214 |       866 | 21.89K | 23 | "31,41,51,59,61,71,81,91,101,121" | 0:06'33'' | 0:02'05'' |
| Q25L90  | 329.99M |   60.7 | 41799 | 5.39M | 233 |     42085 | 5.33M | 212 |     37349 |    58K | 21 | "31,41,51,59,61,71,81,91,101,121" | 0:06'19'' | 0:01'55'' |
| Q25L120 | 312.33M |   57.5 | 42804 | 5.38M | 230 |     43054 | 5.33M | 208 |     16148 | 50.91K | 22 | "31,41,51,59,61,71,81,91,101,121" | 0:05'24'' | 0:02'04'' |
| Q25L150 | 289.05M |   53.2 | 43054 | 5.36M | 229 |     43111 | 5.34M | 208 |       866 | 18.59K | 21 | "31,41,51,59,61,71,81,91,101,121" | 0:05'11'' | 0:01'57'' |
| Q30L50  | 349.89M |   64.4 | 47451 | 5.38M | 217 |     47578 | 5.33M | 188 |     16158 | 51.28K | 29 | "31,41,51,59,61,71,81,91,101,121" | 0:05'40'' | 0:02'20'' |
| Q30L60  | 348.42M |   64.1 | 47486 | 5.41M | 218 |     47578 | 5.33M | 188 |     16154 | 83.02K | 30 | "31,41,51,59,61,71,81,91,101,121" | 0:06'34'' | 0:02'11'' |
| Q30L90  |  343.3M |   63.2 | 45136 | 5.39M | 218 |     45136 | 5.33M | 191 |     16144 | 65.81K | 27 | "31,41,51,59,61,71,81,91,101,121" | 0:06'19'' | 0:02'11'' |
| Q30L120 | 334.06M |   61.5 | 45008 | 5.36M | 218 |     45008 | 5.34M | 196 |       735 | 15.17K | 22 | "31,41,51,59,61,71,81,91,101,121" | 0:05'36'' | 0:02'09'' |
| Q30L150 | 318.28M |   58.6 | 44549 | 5.35M | 220 |     44549 | 5.34M | 199 |       748 | 14.72K | 21 | "31,41,51,59,61,71,81,91,101,121" | 0:05'30'' | 0:02'03'' |

## Bcer: merge anchors

```bash
BASE_NAME=Bcer
cd ${HOME}/data/anchr/${BASE_NAME}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L60/anchor/pe.anchor.fa \
    Q25L60/anchor/pe.anchor.fa \
    Q30L60/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
anchr contained \
    Q20L60/anchor/pe.others.fa \
    Q25L60/anchor/pe.others.fa \
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
| anchor.merge |   52711 | 5345966 | 173 |
| others.merge |   16154 |   73545 |   7 |

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
BASE_NAME=Rsph
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 1_genome
cd 1_genome

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

    Download from GAGE-B site.

```bash
BASE_NAME=Rsph
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina
cd 2_illumina

aria2c -x 9 -s 3 -c http://ccb.jhu.edu/gage_b/datasets/R_sphaeroides_MiSeq.tar.gz

# NOT gzipped tar
tar xvf R_sphaeroides_MiSeq.tar.gz raw/insert_540_1__cov100x.fastq
tar xvf R_sphaeroides_MiSeq.tar.gz raw/insert_540_2__cov100x.fastq

cat raw/insert_540_1__cov100x.fastq \
    | pigz -p 8 -c \
    > R1.fq.gz
cat raw/insert_540_2__cov100x.fastq \
    | pigz -p 8 -c \
    > R2.fq.gz

rm -fr raw
```

* GAGE-B assemblies

```bash
BASE_NAME=Rsph
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 8_competitor
cd 8_competitor

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

* FastQC

```bash
BASE_NAME=Rsph
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

## Rsph: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60 and 90

```bash
BASE_NAME=Rsph
cd ${HOME}/data/anchr/${BASE_NAME}

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

* Stats

```bash
BASE_NAME=Rsph
cd ${HOME}/data/anchr/${BASE_NAME}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Paralogs"; faops n50 -H -S -C 1_genome/paralogs.fas;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md

parallel -k --no-run-if-empty -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo Q{1}L{2};
            if [[ {1} == '30' ]]; then
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz \
                    2_illumina/Q{1}L{2}/Rs.fq.gz;
            else
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz;
            fi
        )
    " ::: 20 25 30 ::: 60 90 \
    >> stat.md

cat stat.md
```

| Name     |     N50 |       Sum |       # |
|:---------|--------:|----------:|--------:|
| Genome   | 3188524 |   4602977 |       7 |
| Paralogs |    2337 |    147155 |      66 |
| Illumina |     251 | 451800000 | 1800000 |
| uniq     |     251 | 447895946 | 1784446 |
| scythe   |     251 | 347832128 | 1784446 |
| Q20L60   |     145 | 174293113 | 1281168 |
| Q20L90   |     148 | 150636485 | 1056140 |
| Q25L60   |     134 | 144881787 | 1149800 |
| Q25L90   |     137 | 117120340 |  876000 |
| Q30L60   |     117 | 126094347 | 1149478 |
| Q30L90   |     123 | 104485730 |  864312 |

## Rsph: quorum

```bash
BASE_NAME=Rsph
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 1 "
    cd 2_illumina/Q{1}L{2}
    echo >&2 '==> Group Q{1}L{2} <=='

    if [ ! -e R1.fq.gz ]; then
        echo >&2 '    R1.fq.gz not exists'
        exit;
    fi

    if [ -e pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa exists'
        exit;
    fi

    if [[ {1} == '30' ]]; then
        anchr quorum \
            R1.fq.gz R2.fq.gz Rs.fq.gz \
            -p 16 \
            -o quorum.sh
    else
        anchr quorum \
            R1.fq.gz R2.fq.gz \
            -p 16 \
            -o quorum.sh
    fi

    bash quorum.sh
    
    echo >&2
    " ::: 20 25 30 ::: 60 90

```

Clear intermediate files.

```bash
BASE_NAME=Rsph
cd $HOME/data/anchr/${BASE_NAME}

find 2_illumina -type f -name "quorum_mer_db.jf" | xargs rm
find 2_illumina -type f -name "k_u_hash_0"       | xargs rm
find 2_illumina -type f -name "*.tmp"            | xargs rm
find 2_illumina -type f -name "pe.renamed.fastq" | xargs rm
find 2_illumina -type f -name "se.renamed.fastq" | xargs rm
find 2_illumina -type f -name "pe.cor.sub.fa"    | xargs rm
```

* Stats of processed reads

```bash
BASE_NAME=Rsph
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=4602977

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > stat1.md

parallel -k --no-run-if-empty -j 3 "
    if [ ! -d 2_illumina/Q{1}L{2} ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 2_illumina/Q{1}L{2} ${REAL_G}
    " ::: 20 25 30 ::: 60 90 \
     >> stat1.md

cat stat1.md
```

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q20L60 | 174.29M |  37.9 | 154.91M |   33.7 |  11.122% |     136 | "37" |  4.6M | 4.55M |     0.99 | 0:00'54'' |
| Q20L90 | 150.64M |  32.7 | 133.74M |   29.1 |  11.220% |     143 | "39" |  4.6M | 4.53M |     0.98 | 0:00'56'' |
| Q25L60 | 144.88M |  31.5 | 138.36M |   30.1 |   4.502% |     126 | "35" |  4.6M | 4.53M |     0.99 | 0:00'55'' |
| Q25L90 | 117.12M |  25.4 | 111.77M |   24.3 |   4.572% |     134 | "37" |  4.6M | 4.49M |     0.98 | 0:00'49'' |
| Q30L60 | 126.32M |  27.4 | 123.22M |   26.8 |   2.454% |     111 | "31" |  4.6M | 4.52M |     0.98 | 0:00'50'' |
| Q30L90 |  104.8M |  22.8 | 102.03M |   22.2 |   2.643% |     121 | "35" |  4.6M | 4.48M |     0.97 | 0:00'46'' |

* kmergenie

```bash
BASE_NAME=Rsph
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

kmergenie -l 21 -k 151 -s 10 -t 8 ../R1.fq.gz -o oriR1
kmergenie -l 21 -k 151 -s 10 -t 8 ../R2.fq.gz -o oriR2
kmergenie -l 21 -k 151 -s 10 -t 8 ../Q20L60/pe.cor.fa -o Q20L60

```

## Rsph: generate k-unitigs

```bash
BASE_NAME=Rsph
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 1 "
    echo >&2 '==> Group Q{1}L{2} '

    if [ -e Q{1}L{2}/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi
    
    mkdir -p Q{1}L{2}
    cd Q{1}L{2}

    anchr kunitigs \
        ../2_illumina/Q{1}L{2}/pe.cor.fa \
        ../2_illumina/Q{1}L{2}/environment.json \
        -p 16 \
        --kmer 31,41,51,61,71,81 \
        -o kunitigs.sh
    bash kunitigs.sh
    
    echo >&2
    " ::: 20 25 30 ::: 60 90

```

## Rsph: create anchors

```bash
BASE_NAME=Rsph
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 3 "
    echo >&2 '==> Group Q{1}L{2}'

    if [ -e Q{1}L{2}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    rm -fr Q{1}L{2}/anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh Q{1}L{2} 8 false
    
    echo >&2
    " ::: 20 25 30 ::: 60 90

```

* Stats of anchors

```bash
BASE_NAME=Rsph
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=4602977

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > stat2.md

parallel -k --no-run-if-empty -j 6 "
    if [ ! -e Q{1}L{2}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 Q{1}L{2} ${REAL_G}
    " ::: 20 25 30 ::: 60 90 \
     >> stat2.md

cat stat2.md
```

| Name   |  SumCor | CovCor | N50SR |   Sum |    # | N50Anchor |   Sum |   # | N50Others |     Sum |   # |                Kmer | RunTimeKU | RunTimeAN |
|:-------|--------:|-------:|------:|------:|-----:|----------:|------:|----:|----------:|--------:|----:|--------------------:|----------:|:----------|
| Q20L60 | 154.91M |   33.7 | 21566 | 4.55M |  432 |     21854 | 4.51M | 376 |       796 |  42.42K |  56 | "31,41,51,61,71,81" | 0:02'04'' | 0:01'42'' |
| Q20L90 | 133.74M |   29.1 | 15128 | 4.53M |  569 |     15277 | 4.47M | 495 |       785 |  55.46K |  74 | "31,41,51,61,71,81" | 0:01'56'' | 0:01'37'' |
| Q25L60 | 138.36M |   30.1 | 17440 | 4.53M |  498 |     17460 | 4.48M | 429 |       755 |  51.28K |  69 | "31,41,51,61,71,81" | 0:01'56'' | 0:01'36'' |
| Q25L90 | 111.77M |   24.3 |  9053 | 4.46M |  833 |      9267 | 4.36M | 702 |       793 |  99.01K | 131 | "31,41,51,61,71,81" | 0:01'44'' | 0:01'25'' |
| Q30L60 | 123.22M |   26.8 | 10535 | 4.52M |  725 |     10753 | 4.44M | 624 |       758 |  74.44K | 101 | "31,41,51,61,71,81" | 0:01'45'' | 0:01'31'' |
| Q30L90 | 102.03M |   22.2 |  6921 | 4.47M | 1064 |      7136 | 4.33M | 884 |       782 | 133.93K | 180 | "31,41,51,61,71,81" | 0:01'40'' | 0:01'22'' |

## Rsph: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/Rsph
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L60/anchor/pe.anchor.fa \
    Q25L60/anchor/pe.anchor.fa \
    Q30L60/anchor/pe.anchor.fa \
    Q20L90/anchor/pe.anchor.fa \
    Q25L90/anchor/pe.anchor.fa \
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
    Q25L60/anchor/pe.others.fa \
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
| anchor.merge |   27741 | 4517524 | 289 |
| others.merge |    1077 |   12396 |  11 |

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
        * Taxid: [561007](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=561007)
        * RefSeq assembly accession:
          [GCF_000069185.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/069/185/GCF_000069185.1_ASM6918v1/GCF_000069185.1_ASM6918v1_assembly_report.txt)
        * Proportion of paralogs (> 1000 bp): 0.0168
    * *Mycobacterium abscessus* 6G-0125-R
        * RefSeq assembly accession: GCF_000270985.1

```bash
BASE_NAME=Mabs
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 1_genome
cd 1_genome

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

    Download from GAGE-B site.

```bash
BASE_NAME=Mabs
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina
cd 2_illumina

aria2c -x 9 -s 3 -c http://ccb.jhu.edu/gage_b/datasets/M_abscessus_MiSeq.tar.gz

# NOT gzipped tar
tar xvf M_abscessus_MiSeq.tar.gz raw/reads_1.fastq
tar xvf M_abscessus_MiSeq.tar.gz raw/reads_2.fastq

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
BASE_NAME=Mabs
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 8_competitor
cd 8_competitor

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

* FastQC

```bash
BASE_NAME=Mabs
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

## Mabs: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60 and 90

```bash
BASE_NAME=Mabs
cd ${HOME}/data/anchr/${BASE_NAME}

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

* Stats

```bash
BASE_NAME=Mabs
cd ${HOME}/data/anchr/${BASE_NAME}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Paralogs"; faops n50 -H -S -C 1_genome/paralogs.fas;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md

parallel -k --no-run-if-empty -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo Q{1}L{2};
            if [[ {1} == '30' ]]; then
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz \
                    2_illumina/Q{1}L{2}/Rs.fq.gz;
            else
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz;
            fi
        )
    " ::: 20 25 30 ::: 60 90 \
    >> stat.md

cat stat.md
```

| Name     |     N50 |       Sum |       # |
|:---------|--------:|----------:|--------:|
| Genome   | 5067172 |   5090491 |       2 |
| Paralogs |    1580 |     83364 |      53 |
| Illumina |     251 | 511999840 | 2039840 |
| uniq     |     251 | 511871830 | 2039330 |
| scythe   |     194 | 369175995 | 2039330 |
| Q20L60   |     180 | 291683466 | 1747016 |
| Q20L90   |     181 | 270086392 | 1560994 |
| Q25L60   |     175 | 251424558 | 1563932 |
| Q25L90   |     177 | 226928403 | 1348272 |
| Q30L60   |     164 | 222027704 | 1502478 |
| Q30L90   |     168 | 207048566 | 1303643 |

## Mabs: quorum

```bash
BASE_NAME=Mabs
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 1 "
    cd 2_illumina/Q{1}L{2}
    echo >&2 '==> Group Q{1}L{2} <=='

    if [ ! -e R1.fq.gz ]; then
        echo >&2 '    R1.fq.gz not exists'
        exit;
    fi

    if [ -e pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa exists'
        exit;
    fi

    if [[ {1} == '30' ]]; then
        anchr quorum \
            R1.fq.gz R2.fq.gz Rs.fq.gz \
            -p 16 \
            -o quorum.sh
    else
        anchr quorum \
            R1.fq.gz R2.fq.gz \
            -p 16 \
            -o quorum.sh
    fi

    bash quorum.sh
    
    echo >&2
    " ::: 20 25 30 ::: 60 90

```

Clear intermediate files.

```bash
BASE_NAME=Mabs
cd $HOME/data/anchr/${BASE_NAME}

find 2_illumina -type f -name "quorum_mer_db.jf" | xargs rm
find 2_illumina -type f -name "k_u_hash_0"       | xargs rm
find 2_illumina -type f -name "*.tmp"            | xargs rm
find 2_illumina -type f -name "pe.renamed.fastq" | xargs rm
find 2_illumina -type f -name "se.renamed.fastq" | xargs rm
find 2_illumina -type f -name "pe.cor.sub.fa"    | xargs rm
```

* Stats of processed reads

```bash
BASE_NAME=Mabs
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=5090491

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > stat1.md

parallel -k --no-run-if-empty -j 3 "
    if [ ! -d 2_illumina/Q{1}L{2} ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 2_illumina/Q{1}L{2} ${REAL_G}
    " ::: 20 25 30 ::: 60 90 \
     >> stat1.md

cat stat1.md
```

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q20L60 | 291.68M |  57.3 | 228.29M |   44.8 |  21.734% |     167 | "47" | 5.09M | 5.23M |     1.03 | 0:01'09'' |
| Q20L90 | 270.09M |  53.1 | 212.75M |   41.8 |  21.228% |     173 | "49" | 5.09M | 5.22M |     1.03 | 0:01'03'' |
| Q25L60 | 251.42M |  49.4 | 210.79M |   41.4 |  16.164% |     162 | "43" | 5.09M | 5.21M |     1.02 | 0:01'02'' |
| Q25L90 | 226.93M |  44.6 | 190.67M |   37.5 |  15.979% |     168 | "47" | 5.09M |  5.2M |     1.02 | 0:01'00'' |
| Q30L60 | 222.24M |  43.7 | 194.38M |   38.2 |  12.534% |     152 | "39" | 5.09M | 5.19M |     1.02 | 0:01'05'' |
| Q30L90 | 207.32M |  40.7 | 180.55M |   35.5 |  12.911% |     161 | "45" | 5.09M | 5.19M |     1.02 | 0:00'58'' |

* kmergenie

```bash
BASE_NAME=Mabs
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

kmergenie -l 21 -k 151 -s 10 -t 8 ../R1.fq.gz -o oriR1
kmergenie -l 21 -k 151 -s 10 -t 8 ../R2.fq.gz -o oriR2
kmergenie -l 21 -k 151 -s 10 -t 8 ../Q20L60/pe.cor.fa -o Q20L60

```

## Mabs: generate k-unitigs

```bash
BASE_NAME=Mabs
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 1 "
    echo >&2 '==> Group Q{1}L{2} '

    if [ -e Q{1}L{2}/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi
    
    mkdir -p Q{1}L{2}
    cd Q{1}L{2}

    anchr kunitigs \
        ../2_illumina/Q{1}L{2}/pe.cor.fa \
        ../2_illumina/Q{1}L{2}/environment.json \
        -p 16 \
        --kmer 31,41,51,61,71,81,45 \
        -o kunitigs.sh
    bash kunitigs.sh
    
    echo >&2
    " ::: 20 25 30 ::: 60 90

```

## Mabs: create anchors

```bash
BASE_NAME=Mabs
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 3 "
    echo >&2 '==> Group Q{1}L{2}'

    if [ -e Q{1}L{2}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    rm -fr Q{1}L{2}/anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh Q{1}L{2} 8 false
    
    echo >&2
    " ::: 20 25 30 ::: 60 90

```

* Stats of anchors

```bash
BASE_NAME=Mabs
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=5090491

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > stat2.md

parallel -k --no-run-if-empty -j 6 "
    if [ ! -e Q{1}L{2}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 Q{1}L{2} ${REAL_G}
    " ::: 20 25 30 ::: 60 90 \
     >> stat2.md

cat stat2.md
```

| Name   |  SumCor | CovCor | N50SR |   Sum |    # | N50Anchor |   Sum |    # | N50Others |     Sum |   # |                   Kmer | RunTimeKU | RunTimeAN |
|:-------|--------:|-------:|------:|------:|-----:|----------:|------:|-----:|----------:|--------:|----:|-----------------------:|----------:|:----------|
| Q20L60 | 228.29M |   44.8 |  6493 | 5.21M | 1213 |      6642 | 5.07M | 1046 |       815 | 141.92K | 167 | "31,41,45,51,61,71,81" | 0:02'44'' | 0:01'44'' |
| Q20L90 | 212.75M |   41.8 |  6583 | 5.25M | 1208 |      6652 | 5.04M | 1039 |       957 | 210.94K | 169 | "31,41,45,51,61,71,81" | 0:02'34'' | 0:01'39'' |
| Q25L60 | 210.79M |   41.4 |  8980 | 5.17M |  885 |      9075 |  5.1M |  796 |       764 |  64.25K |  89 | "31,41,45,51,61,71,81" | 0:02'36'' | 0:01'38'' |
| Q25L90 | 190.67M |   37.5 |  8282 | 5.17M |  945 |      8358 |  5.1M |  845 |       773 |   72.9K | 100 | "31,41,45,51,61,71,81" | 0:02'27'' | 0:01'35'' |
| Q30L60 | 194.38M |   38.2 | 14939 |  5.2M |  616 |     15113 | 5.11M |  561 |      9075 |   93.7K |  55 | "31,41,45,51,61,71,81" | 0:02'30'' | 0:01'40'' |
| Q30L90 | 180.55M |   35.5 | 14939 | 5.15M |  609 |     15316 | 5.12M |  560 |       726 |  34.09K |  49 | "31,41,45,51,61,71,81" | 0:02'27'' | 0:01'35'' |

## Mabs: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/Mabs
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L60/anchor/pe.anchor.fa \
    Q25L60/anchor/pe.anchor.fa \
    Q30L60/anchor/pe.anchor.fa \
    Q20L90/anchor/pe.anchor.fa \
    Q25L90/anchor/pe.anchor.fa \
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
    Q25L60/anchor/pe.others.fa \
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

| Name         |     N50 |     Sum |   # |
|:-------------|--------:|--------:|----:|
| Genome       | 5067172 | 5090491 |   2 |
| Paralogs     |    1580 |   83364 |  53 |
| anchor.merge |   16956 | 5151885 | 491 |
| others.merge |   40761 |   72491 |   7 |

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
BASE_NAME=Vcho
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 1_genome
cd 1_genome

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

    Download from GAGE-B site.

```bash
BASE_NAME=Vcho
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina
cd 2_illumina

aria2c -x 9 -s 3 -c http://ccb.jhu.edu/gage_b/datasets/V_cholerae_MiSeq.tar.gz

# NOT gzipped tar
tar xvf V_cholerae_MiSeq.tar.gz raw/reads_1.fastq
tar xvf V_cholerae_MiSeq.tar.gz raw/reads_2.fastq

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
BASE_NAME=Vcho
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 8_competitor
cd 8_competitor

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

* FastQC

```bash
BASE_NAME=Vcho
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

## Vcho: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60 and 90

```bash
BASE_NAME=Vcho
cd ${HOME}/data/anchr/${BASE_NAME}

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

* Stats

```bash
BASE_NAME=Vcho
cd ${HOME}/data/anchr/${BASE_NAME}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Paralogs"; faops n50 -H -S -C 1_genome/paralogs.fas;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md

parallel -k --no-run-if-empty -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo Q{1}L{2};
            if [[ {1} == '30' ]]; then
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz \
                    2_illumina/Q{1}L{2}/Rs.fq.gz;
            else
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz;
            fi
        )
    " ::: 20 25 30 ::: 60 90 \
    >> stat.md

cat stat.md
```

| Name     |     N50 |       Sum |       # |
|:---------|--------:|----------:|--------:|
| Genome   | 2961149 |   4033464 |       2 |
| Paralogs |    3483 |    114707 |      48 |
| Illumina |     251 | 399999624 | 1593624 |
| uniq     |     251 | 397989616 | 1585616 |
| scythe   |     198 | 303351043 | 1585616 |
| Q20L60   |     192 | 276676322 | 1504034 |
| Q20L90   |     192 | 271399426 | 1460080 |
| Q25L60   |     189 | 254738206 | 1415632 |
| Q25L90   |     189 | 248113857 | 1359224 |
| Q30L60   |     182 | 231416118 | 1354988 |
| Q30L90   |     183 | 227344381 | 1300876 |

## Vcho: quorum

```bash
BASE_NAME=Vcho
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 1 "
    cd 2_illumina/Q{1}L{2}
    echo >&2 '==> Group Q{1}L{2} <=='

    if [ ! -e R1.fq.gz ]; then
        echo >&2 '    R1.fq.gz not exists'
        exit;
    fi

    if [ -e pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa exists'
        exit;
    fi

    if [[ {1} == '30' ]]; then
        anchr quorum \
            R1.fq.gz R2.fq.gz Rs.fq.gz \
            -p 16 \
            -o quorum.sh
    else
        anchr quorum \
            R1.fq.gz R2.fq.gz \
            -p 16 \
            -o quorum.sh
    fi

    bash quorum.sh
    
    echo >&2
    " ::: 20 25 30 ::: 60 90

```

Clear intermediate files.

```bash
BASE_NAME=Vcho
cd $HOME/data/anchr/${BASE_NAME}

find 2_illumina -type f -name "quorum_mer_db.jf" | xargs rm
find 2_illumina -type f -name "k_u_hash_0"       | xargs rm
find 2_illumina -type f -name "*.tmp"            | xargs rm
find 2_illumina -type f -name "pe.renamed.fastq" | xargs rm
find 2_illumina -type f -name "se.renamed.fastq" | xargs rm
find 2_illumina -type f -name "pe.cor.sub.fa"    | xargs rm
```

* Stats of processed reads

```bash
BASE_NAME=Vcho
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=4033464

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > stat1.md

parallel -k --no-run-if-empty -j 3 "
    if [ ! -d 2_illumina/Q{1}L{2} ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 2_illumina/Q{1}L{2} ${REAL_G}
    " ::: 20 25 30 ::: 60 90 \
     >> stat1.md

cat stat1.md
```

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q20L60 | 276.68M |  68.6 | 224.36M |   55.6 |  18.911% |     183 | "113" | 4.03M | 3.96M |     0.98 | 0:01'05'' |
| Q20L90 |  271.4M |  67.3 | 220.69M |   54.7 |  18.684% |     184 | "113" | 4.03M | 3.96M |     0.98 | 0:01'04'' |
| Q25L60 | 254.74M |  63.2 | 217.57M |   53.9 |  14.590% |     179 | "109" | 4.03M | 3.95M |     0.98 | 0:01'04'' |
| Q25L90 | 248.11M |  61.5 | 212.22M |   52.6 |  14.465% |     182 | "111" | 4.03M | 3.95M |     0.98 | 0:01'02'' |
| Q30L60 | 231.51M |  57.4 | 205.43M |   50.9 |  11.266% |     174 | "105" | 4.03M | 3.94M |     0.98 | 0:01'02'' |
| Q30L90 | 227.45M |  56.4 |  201.7M |   50.0 |  11.322% |     177 | "107" | 4.03M | 3.94M |     0.98 | 0:00'58'' |

* kmergenie

```bash
BASE_NAME=Vcho
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

kmergenie -l 21 -k 151 -s 10 -t 8 ../R1.fq.gz -o oriR1
kmergenie -l 21 -k 151 -s 10 -t 8 ../R2.fq.gz -o oriR2
kmergenie -l 21 -k 151 -s 10 -t 8 ../Q20L60/pe.cor.fa -o Q20L60

```

## Vcho: generate k-unitigs

```bash
BASE_NAME=Vcho
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 1 "
    echo >&2 '==> Group Q{1}L{2} '

    if [ -e Q{1}L{2}/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi
    
    mkdir -p Q{1}L{2}
    cd Q{1}L{2}

    anchr kunitigs \
        ../2_illumina/Q{1}L{2}/pe.cor.fa \
        ../2_illumina/Q{1}L{2}/environment.json \
        -p 16 \
        --kmer 31,41,51,61,71,81,101,121,57,63 \
        -o kunitigs.sh
    bash kunitigs.sh
    
    echo >&2
    " ::: 20 25 30 ::: 60 90

```

## Vcho: create anchors

```bash
BASE_NAME=Vcho
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 3 "
    echo >&2 '==> Group Q{1}L{2}'

    if [ -e Q{1}L{2}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    rm -fr Q{1}L{2}/anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh Q{1}L{2} 8 false
    
    echo >&2
    " ::: 20 25 30 ::: 60 90

```

* Stats of anchors

```bash
BASE_NAME=Vcho
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=4033464

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > stat2.md

parallel -k --no-run-if-empty -j 6 "
    if [ ! -e Q{1}L{2}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 Q{1}L{2} ${REAL_G}
    " ::: 20 25 30 ::: 60 90 \
     >> stat2.md

cat stat2.md
```

## Vcho: results

| Name   |  SumCor | CovCor | N50SR |   Sum |   # | N50Anchor |   Sum |   # | N50Others |    Sum |   # |                              Kmer | RunTimeKU | RunTimeAN |
|:-------|--------:|-------:|------:|------:|----:|----------:|------:|----:|----------:|-------:|----:|----------------------------------:|----------:|:----------|
| Q20L60 | 224.36M |   55.6 |  9312 | 3.99M | 737 |      9549 | 3.89M | 608 |       771 | 96.04K | 129 | "31,41,51,57,61,63,71,81,101,121" | 0:03'18'' | 0:01'37'' |
| Q20L90 | 220.69M |   54.7 |  9312 | 3.99M | 730 |      9549 | 3.89M | 598 |       765 | 97.45K | 132 | "31,41,51,57,61,63,71,81,101,121" | 0:03'24'' | 0:01'25'' |
| Q25L60 | 217.57M |   53.9 | 24544 | 3.96M | 355 |     24583 | 3.91M | 289 |       789 | 49.08K |  66 | "31,41,51,57,61,63,71,81,101,121" | 0:03'22'' | 0:01'39'' |
| Q25L90 | 212.22M |   52.6 | 23725 | 3.96M | 362 |     24544 | 3.91M | 294 |       772 | 49.93K |  68 | "31,41,51,57,61,63,71,81,101,121" | 0:03'22'' | 0:01'29'' |
| Q30L60 | 205.43M |   50.9 | 29588 | 3.96M | 329 |     29684 | 3.91M | 266 |       765 | 45.76K |  63 | "31,41,51,57,61,63,71,81,101,121" | 0:03'14'' | 0:01'36'' |
| Q30L90 |  201.7M |   50.0 | 29588 | 3.96M | 329 |     29684 | 3.91M | 266 |       765 | 45.76K |  63 | "31,41,51,57,61,63,71,81,101,121" | 0:03'15'' | 0:01'36'' |

## Vcho: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/Vcho
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L60/anchor/pe.anchor.fa \
    Q25L60/anchor/pe.anchor.fa \
    Q30L60/anchor/pe.anchor.fa \
    Q20L90/anchor/pe.anchor.fa \
    Q25L90/anchor/pe.anchor.fa \
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
    Q25L60/anchor/pe.others.fa \
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

| Name         |     N50 |     Sum |   # |
|:-------------|--------:|--------:|----:|
| Genome       | 2961149 | 4033464 |   2 |
| Paralogs     |    3483 |  114707 |  48 |
| anchor.merge |   32909 | 3910957 | 235 |
| others.merge |    1068 |    5516 |   5 |

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/Vcho
cd ${BASE_DIR}

#rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

# *Mycobacterium abscessus* 6G-0125-R Full

## MabsF: download

* Reference genome

```bash
BASE_NAME=MabsF
mkdir -p ${HOME}/data/anchr/${BASE_NAME}
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 1_genome
cd 1_genome

cp ~/data/anchr/Mabs/1_genome/genome.fa .
cp ~/data/anchr/Mabs/1_genome/paralogs.fas .

```

* Illumina

    SRX246890, SRR768269

```bash
BASE_NAME=MabsF
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina
cd 2_illumina

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
BASE_NAME=MabsF
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 8_competitor
cd 8_competitor

cp ~/data/anchr/Mabs/8_competitor/* .

```

* FastQC

```bash
BASE_NAME=MabsF
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

## MabsF: combinations of different quality values and read lengths

* qual: 20, 25, 30, and 35
* len: 60

```bash
BASE_NAME=MabsF
cd ${HOME}/data/anchr/${BASE_NAME}

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

if [ ! -e 2_illumina/R1.shuffle.fq.gz ]; then
    shuffle.sh \
        in=2_illumina/R1.scythe.fq.gz \
        in2=2_illumina/R2.scythe.fq.gz \
        out=2_illumina/R1.shuffle.fq \
        out2=2_illumina/R2.shuffle.fq
    
    parallel --no-run-if-empty -j 2 "
            pigz -p 8 2_illumina/{}.shuffle.fq
        " ::: R1 R2
fi

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
        ../R1.shuffle.fq.gz ../R2.shuffle.fq.gz \
        -o stdout \
        | bash
    " ::: 20 25 30 35 ::: 60

```

* Stats

```bash
BASE_NAME=MabsF
cd ${HOME}/data/anchr/${BASE_NAME}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Paralogs"; faops n50 -H -S -C 1_genome/paralogs.fas;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "shuffle";  faops n50 -H -S -C 2_illumina/R1.shuffle.fq.gz 2_illumina/R2.shuffle.fq.gz;) >> stat.md

parallel -k --no-run-if-empty -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo Q{1}L{2};
            if [[ {1} -ge '30' ]]; then
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz \
                    2_illumina/Q{1}L{2}/Rs.fq.gz;
            else
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz;
            fi
        )
    " ::: 20 25 30 35 ::: 60 \
    >> stat.md

cat stat.md
```

| Name     |     N50 |        Sum |       # |
|:---------|--------:|-----------:|--------:|
| Genome   | 5067172 |    5090491 |       2 |
| Paralogs |    1580 |      83364 |      53 |
| Illumina |     251 | 2194026140 | 8741140 |
| uniq     |     251 | 2191831898 | 8732398 |
| scythe   |     194 | 1580945973 | 8732398 |
| shuffle  |     194 | 1580945973 | 8732398 |
| Q20L60   |     180 | 1245966051 | 7468270 |
| Q25L60   |     174 | 1072555697 | 6677782 |
| Q30L60   |     164 |  945361833 | 6407581 |
| Q35L60   |     135 |  510070253 | 4212149 |

## MabsF: quorum

```bash
BASE_NAME=MabsF
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 1 "
    cd 2_illumina/Q{1}L{2}
    echo >&2 '==> Group Q{1}L{2} <=='

    if [ ! -e R1.fq.gz ]; then
        echo >&2 '    R1.fq.gz not exists'
        exit;
    fi

    if [ -e pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa exists'
        exit;
    fi

    if [[ {1} -ge '30' ]]; then
        anchr quorum \
            R1.fq.gz R2.fq.gz Rs.fq.gz \
            -p 16 \
            -o quorum.sh
    else
        anchr quorum \
            R1.fq.gz R2.fq.gz \
            -p 16 \
            -o quorum.sh
    fi

    bash quorum.sh
    
    echo >&2
    " ::: 20 25 30 35 ::: 60

```

Clear intermediate files.

```bash
BASE_NAME=MabsF
cd $HOME/data/anchr/${BASE_NAME}

find 2_illumina -type f -name "quorum_mer_db.jf" | xargs rm
find 2_illumina -type f -name "k_u_hash_0"       | xargs rm
find 2_illumina -type f -name "*.tmp"            | xargs rm
find 2_illumina -type f -name "pe.renamed.fastq" | xargs rm
find 2_illumina -type f -name "se.renamed.fastq" | xargs rm
find 2_illumina -type f -name "pe.cor.sub.fa"    | xargs rm
```

* Stats of processed reads

```bash
BASE_NAME=MabsF
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=5090491

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > stat1.md

parallel -k --no-run-if-empty -j 3 "
    if [ ! -d 2_illumina/Q{1}L{2} ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 2_illumina/Q{1}L{2} ${REAL_G}
    " ::: 20 25 30 35 ::: 60 \
     >> stat1.md

cat stat1.md
```

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q20L60 |   1.25G | 244.8 | 979.96M |  192.5 |  21.349% |     167 | "47" | 5.09M |  5.9M |     1.16 | 0:06'46'' |
| Q25L60 |   1.07G | 210.7 | 895.74M |  176.0 |  16.485% |     160 | "43" | 5.09M | 5.49M |     1.08 | 0:03'39'' |
| Q30L60 | 946.28M | 185.9 | 824.29M |  161.9 |  12.891% |     151 | "39" | 5.09M | 5.41M |     1.06 | 0:05'52'' |
| Q35L60 | 511.26M | 100.4 | 475.89M |   93.5 |   6.919% |     125 | "31" | 5.09M | 5.28M |     1.04 | 0:03'18'' |

* kmergenie

```bash
BASE_NAME=MabsF
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

kmergenie -l 21 -k 151 -s 10 -t 8 ../R1.fq.gz -o oriR1
kmergenie -l 21 -k 151 -s 10 -t 8 ../R2.fq.gz -o oriR2
kmergenie -l 21 -k 151 -s 10 -t 8 ../Q20L60/pe.cor.fa -o Q20L60

```

## MabsF: down sampling

```bash
BASE_NAME=MabsF
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=5090491

for QxxLxx in $( parallel "echo 'Q{1}L{2}'" ::: 20 25 30 35 ::: 60 ); do
    echo "==> ${QxxLxx}"

    if [ ! -e 2_illumina/${QxxLxx}/pe.cor.fa ]; then
        echo "2_illumina/${QxxLxx}/pe.cor.fa not exists"
        continue;
    fi

    for X in 40 80 120 160; do
        printf "==> Coverage: %s\n" ${X}
        
        rm -fr 2_illumina/${QxxLxx}X${X}*
    
        faops split-about -l 0 \
            2_illumina/${QxxLxx}/pe.cor.fa \
            $(( ${REAL_G} * ${X} )) \
            "2_illumina/${QxxLxx}X${X}"
        
        MAX_SERIAL=$(
            cat 2_illumina/${QxxLxx}/environment.json \
                | jq ".SUM_OUT | tonumber | . / ${REAL_G} / ${X} | floor | . - 1"
        )
        
        for i in $( seq 0 1 ${MAX_SERIAL} ); do
            P=$( printf "%03d" ${i})
            printf "  * Part: %s\n" ${P}
            
            mkdir -p "2_illumina/${QxxLxx}X${X}P${P}"
            
            mv  "2_illumina/${QxxLxx}X${X}/${P}.fa" \
                "2_illumina/${QxxLxx}X${X}P${P}/pe.cor.fa"
            cp 2_illumina/${QxxLxx}/environment.json "2_illumina/${QxxLxx}X${X}P${P}"
    
        done
    done
done

```

## MabsF: generate k-unitigs (sampled)

```bash
BASE_NAME=MabsF
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 3 "
    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'

    if [ ! -e 2_illumina/Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        echo >&2 '    2_illumina/Q{1}L{2}X{3}P{4}/pe.cor.fa not exists'
        exit;
    fi

    if [ -e Q{1}L{2}X{3}P{4}/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi

    mkdir -p Q{1}L{2}X{3}P{4}
    cd Q{1}L{2}X{3}P{4}

    anchr kunitigs \
        ../2_illumina/Q{1}L{2}X{3}P{4}/pe.cor.fa \
        ../2_illumina/Q{1}L{2}X{3}P{4}/environment.json \
        -p 8 \
        --kmer 31,41,51,61,71,81 \
        -o kunitigs.sh
    bash kunitigs.sh

    echo >&2
    " ::: 20 25 30 35 ::: 60 ::: 40 80 120 160 ::: 000 001 002 003 004 005

```

## MabsF: create anchors (sampled)

```bash
BASE_NAME=MabsF
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 3 "
    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'

    if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    rm -fr Q{1}L{2}X{3}P{4}/anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh Q{1}L{2}X{3}P{4} 8 false
    
    echo >&2
    " ::: 20 25 30 35 ::: 60 ::: 40 80 120 160 ::: 000 001 002 003 004 005

```

* Stats of anchors

```bash
BASE_NAME=MabsF
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=5090491

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > stat2.md

parallel -k --no-run-if-empty -j 6 "
    if [ ! -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 Q{1}L{2}X{3}P{4} ${REAL_G}
    " ::: 20 25 30 35 ::: 60 ::: 40 80 120 160 ::: 000 001 002 003 004 005 \
     >> stat2.md

cat stat2.md
```

| Name           |  SumCor | CovCor | N50SR |   Sum |    # | N50Anchor |     Sum |    # | N50Others |     Sum |    # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|--------:|-------:|------:|------:|-----:|----------:|--------:|-----:|----------:|--------:|-----:|--------------------:|----------:|:----------|
| Q20L60X40P000  | 203.62M |   40.0 |  1893 | 5.06M | 3298 |      2210 |   4.07M | 1962 |       768 | 985.71K | 1336 | "31,41,51,61,71,81" | 0:07'56'' | 0:00'49'' |
| Q20L60X40P001  | 203.62M |   40.0 |  1907 | 5.05M | 3258 |      2303 |   4.09M | 1962 |       766 | 959.49K | 1296 | "31,41,51,61,71,81" | 0:08'01'' | 0:00'48'' |
| Q20L60X40P002  | 203.62M |   40.0 |  1869 | 5.05M | 3314 |      2231 |   4.05M | 1965 |       775 |      1M | 1349 | "31,41,51,61,71,81" | 0:07'56'' | 0:00'47'' |
| Q20L60X40P003  | 203.62M |   40.0 |  1837 | 5.08M | 3347 |      2195 |   4.05M | 1962 |       773 |   1.02M | 1385 | "31,41,51,61,71,81" | 0:07'27'' | 0:00'48'' |
| Q20L60X80P000  | 407.24M |   80.0 |  1119 | 4.43M | 4302 |      1562 |    2.5M | 1606 |       740 |   1.92M | 2696 | "31,41,51,61,71,81" | 0:12'25'' | 0:01'10'' |
| Q20L60X80P001  | 407.24M |   80.0 |  1095 | 4.46M | 4370 |      1547 |   2.48M | 1600 |       737 |   1.98M | 2770 | "31,41,51,61,71,81" | 0:12'33'' | 0:01'06'' |
| Q20L60X120P000 | 610.86M |  120.0 |   895 | 3.75M | 4320 |      1367 |    1.5M | 1074 |       709 |   2.25M | 3246 | "31,41,51,61,71,81" | 0:17'05'' | 0:01'11'' |
| Q20L60X160P000 | 814.48M |  160.0 |   801 | 3.18M | 3999 |      1267 | 958.67K |  734 |       687 |   2.22M | 3265 | "31,41,51,61,71,81" | 0:21'53'' | 0:01'20'' |
| Q25L60X40P000  | 203.62M |   40.0 |  6180 | 5.19M | 1273 |      6389 |   5.05M | 1086 |       782 | 140.79K |  187 | "31,41,51,61,71,81" | 0:07'47'' | 0:00'51'' |
| Q25L60X40P001  | 203.62M |   40.0 |  6535 | 5.19M | 1231 |      6628 |   5.04M | 1045 |       790 | 141.15K |  186 | "31,41,51,61,71,81" | 0:07'09'' | 0:00'49'' |
| Q25L60X40P002  | 203.62M |   40.0 |  6023 | 5.19M | 1262 |      6142 |   5.06M | 1091 |       766 |  126.8K |  171 | "31,41,51,61,71,81" | 0:07'33'' | 0:00'48'' |
| Q25L60X40P003  | 203.62M |   40.0 |  6161 | 5.19M | 1250 |      6255 |   5.06M | 1072 |       772 | 133.35K |  178 | "31,41,51,61,71,81" | 0:07'27'' | 0:00'48'' |
| Q25L60X80P000  | 407.24M |   80.0 |  3355 | 5.18M | 2136 |      3556 |    4.8M | 1630 |       775 | 381.53K |  506 | "31,41,51,61,71,81" | 0:12'19'' | 0:01'19'' |
| Q25L60X80P001  | 407.24M |   80.0 |  3507 | 5.18M | 2085 |      3725 |    4.8M | 1573 |       775 | 382.36K |  512 | "31,41,51,61,71,81" | 0:12'20'' | 0:01'17'' |
| Q25L60X120P000 | 610.86M |  120.0 |  2412 | 5.14M | 2776 |      2656 |   4.49M | 1901 |       766 | 646.72K |  875 | "31,41,51,61,71,81" | 0:17'01'' | 0:01'37'' |
| Q25L60X160P000 | 814.48M |  160.0 |  1954 | 5.06M | 3209 |      2322 |   4.16M | 1995 |       769 | 893.15K | 1214 | "31,41,51,61,71,81" | 0:21'26'' | 0:01'42'' |
| Q30L60X40P000  | 203.62M |   40.0 |  8273 | 5.18M |  991 |      8370 |   5.09M |  867 |       779 |  92.35K |  124 | "31,41,51,61,71,81" | 0:07'09'' | 0:00'45'' |
| Q30L60X40P001  | 203.62M |   40.0 |  9110 | 5.18M |  935 |      9185 |   5.09M |  833 |       830 |  83.09K |  102 | "31,41,51,61,71,81" | 0:06'40'' | 0:00'43'' |
| Q30L60X40P002  | 203.62M |   40.0 |  8894 |  5.2M |  936 |      8955 |   5.09M |  832 |       905 |  112.7K |  104 | "31,41,51,61,71,81" | 0:06'31'' | 0:00'41'' |
| Q30L60X40P003  | 203.62M |   40.0 | 12662 |  5.2M |  644 |     12662 |   5.12M |  588 |      1100 |  82.57K |   56 | "31,41,51,61,71,81" | 0:06'59'' | 0:00'47'' |
| Q30L60X80P000  | 407.24M |   80.0 |  4796 |  5.2M | 1614 |      4979 |   4.97M | 1313 |       789 | 229.01K |  301 | "31,41,51,61,71,81" | 0:11'40'' | 0:01'09'' |
| Q30L60X80P001  | 407.24M |   80.0 |  5788 | 5.19M | 1327 |      5928 |   5.04M | 1126 |       782 | 149.89K |  201 | "31,41,51,61,71,81" | 0:11'30'' | 0:01'14'' |
| Q30L60X120P000 | 610.86M |  120.0 |  3418 | 5.18M | 2115 |      3603 |   4.82M | 1622 |       769 | 367.68K |  493 | "31,41,51,61,71,81" | 0:16'13'' | 0:01'33'' |
| Q30L60X160P000 | 814.48M |  160.0 |  2971 | 5.16M | 2347 |      3286 |   4.71M | 1728 |       766 |    454K |  619 | "31,41,51,61,71,81" | 0:19'18'' | 0:01'55'' |
| Q35L60X40P000  | 203.62M |   40.0 | 11114 | 5.14M |  698 |     11151 |   5.09M |  634 |       743 |  45.28K |   64 | "31,41,51,61,71,81" | 0:06'59'' | 0:00'48'' |
| Q35L60X40P001  | 203.62M |   40.0 | 15527 | 5.15M |  537 |     15539 |   5.11M |  495 |       945 |  46.37K |   42 | "31,41,51,61,71,81" | 0:07'01'' | 0:00'50'' |
| Q35L60X80P000  | 407.24M |   80.0 | 11320 | 5.16M |  699 |     11440 |   5.11M |  635 |       758 |  48.12K |   64 | "31,41,51,61,71,81" | 0:08'30'' | 0:01'20'' |

## MabsF: merge anchors

```bash
BASE_NAME=MabsF
cd ${HOME}/data/anchr/${BASE_NAME}

# merge anchors
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
            fi
            " ::: 20 25 30 35 ::: 60 ::: 40 80 120 160 ::: 000 001 002 003 004 005 006
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.others.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.others.fa
            fi
            " ::: 20 25 30 35 ::: 60 ::: 40 80 120 160 ::: 000 001 002 003 004 005 006
    ) \
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
BASE_NAME=MabsF
cd ${HOME}/data/anchr/${BASE_NAME}

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
| anchor.merge |  116660 | 5174578 |  91 |
| others.merge |    1021 |  406393 | 309 |

* Clear QxxLxxx.

```bash
BASE_NAME=MabsF
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr 2_illumina/Q{20,25,30,35}L*
rm -fr Q{20,25,30,35}L*
```

# *Rhodobacter sphaeroides* 2.4.1 Full

## RsphF: download

* Reference genome

```bash
BASE_NAME=RsphF
mkdir -p ${HOME}/data/anchr/${BASE_NAME}
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 1_genome
cd 1_genome

cp ~/data/anchr/Rsph/1_genome/genome.fa .
cp ~/data/anchr/Rsph/1_genome/paralogs.fas .

```

* Illumina

    SRX160386, SRR522246

```bash
BASE_NAME=RsphF
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina
cd 2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR522/SRR522246/SRR522246_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR522/SRR522246/SRR522246_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
a29e463504252388f9f381bd8659b084 SRR522246_1.fastq.gz
0e44d585f34c41681a7dcb25960ee273 SRR522246_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s SRR522246_1.fastq.gz R1.fq.gz
ln -s SRR522246_2.fastq.gz R2.fq.gz
```

* GAGE-B assemblies

```bash
BASE_NAME=RsphF
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 8_competitor
cd 8_competitor

cp ~/data/anchr/Rsph/8_competitor/* .

```

* FastQC

```bash
BASE_NAME=MabsF
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

## RsphF: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60

```bash
BASE_NAME=RsphF
cd ${HOME}/data/anchr/${BASE_NAME}

if [ ! -e 2_illumina/R1.uniq.fq.gz ]; then
    tally \
        --pair-by-offset --with-quality --nozip --unsorted \
        -i 2_illumina/R1.fq.gz \
        -j 2_illumina/R2.fq.gz \
        -o 2_illumina/R1.uniq.fq \
        -p 2_illumina/R2.uniq.fq
    
    parallel --no-run-if-empty -j 2 "
            pigz -p 8 2_illumina/{}.uniq.fq
        " ::: R1 R2
fi

if [ ! -e 2_illumina/R1.scythe.fq.gz ]; then
    parallel --no-run-if-empty -j 2 "
        scythe \
            2_illumina/{}.uniq.fq.gz \
            -q sanger \
            -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
            --quiet \
            | pigz -p 8 -c \
            > 2_illumina/{}.scythe.fq.gz
        " ::: R1 R2
fi

if [ ! -e 2_illumina/R1.shuffle.fq.gz ]; then
    shuffle.sh \
        in=2_illumina/R1.scythe.fq.gz \
        in2=2_illumina/R2.scythe.fq.gz \
        out=2_illumina/R1.shuffle.fq \
        out2=2_illumina/R2.shuffle.fq
    
    parallel --no-run-if-empty -j 2 "
            pigz -p 8 2_illumina/{}.shuffle.fq
        " ::: R1 R2
fi

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
        ../R1.shuffle.fq.gz ../R2.shuffle.fq.gz \
        -o stdout \
        | bash
    " ::: 20 25 30 ::: 60

```

* Stats

```bash
BASE_NAME=RsphF
cd ${HOME}/data/anchr/${BASE_NAME}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Paralogs"; faops n50 -H -S -C 1_genome/paralogs.fas;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "shuffle";  faops n50 -H -S -C 2_illumina/R1.shuffle.fq.gz 2_illumina/R2.shuffle.fq.gz;) >> stat.md

parallel -k --no-run-if-empty -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo Q{1}L{2};
            if [[ {1} -ge '30' ]]; then
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz \
                    2_illumina/Q{1}L{2}/Rs.fq.gz;
            else
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz;
            fi
        )
    " ::: 20 25 30 ::: 60 \
    >> stat.md

cat stat.md
```

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 3188524 |    4602977 |        7 |
| Paralogs |    2337 |     147155 |       66 |
| Illumina |     251 | 4237215336 | 16881336 |
| uniq     |     251 | 4199507606 | 16731106 |
| scythe   |     251 | 3261298332 | 16731106 |
| shuffle  |     251 | 3261298332 | 16731106 |
| Q20L60   |     145 | 1633008251 | 12002480 |
| Q25L60   |     134 | 1357459456 | 10772226 |
| Q30L60   |     117 | 1181885100 | 10776009 |

## RsphF: quorum

```bash
BASE_NAME=RsphF
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 1 "
    cd 2_illumina/Q{1}L{2}
    echo >&2 '==> Group Q{1}L{2} <=='

    if [ ! -e R1.fq.gz ]; then
        echo >&2 '    R1.fq.gz not exists'
        exit;
    fi

    if [ -e pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa exists'
        exit;
    fi

    if [[ {1} -ge '30' ]]; then
        anchr quorum \
            R1.fq.gz R2.fq.gz Rs.fq.gz \
            -p 16 \
            -o quorum.sh
    else
        anchr quorum \
            R1.fq.gz R2.fq.gz \
            -p 16 \
            -o quorum.sh
    fi

    bash quorum.sh
    
    echo >&2
    " ::: 20 25 30 ::: 60

```

Clear intermediate files.

```bash
BASE_NAME=RsphF
cd $HOME/data/anchr/${BASE_NAME}

find 2_illumina -type f -name "quorum_mer_db.jf" | xargs rm
find 2_illumina -type f -name "k_u_hash_0"       | xargs rm
find 2_illumina -type f -name "*.tmp"            | xargs rm
find 2_illumina -type f -name "pe.renamed.fastq" | xargs rm
find 2_illumina -type f -name "se.renamed.fastq" | xargs rm
find 2_illumina -type f -name "pe.cor.sub.fa"    | xargs rm
```

* Stats of processed reads

```bash
BASE_NAME=RsphF
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=4602977

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > stat1.md

parallel -k --no-run-if-empty -j 3 "
    if [ ! -d 2_illumina/Q{1}L{2} ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 2_illumina/Q{1}L{2} ${REAL_G}
    " ::: 20 25 30 ::: 60 \
     >> stat1.md

cat stat1.md
```

| Name   | SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|------:|-------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q20L60 | 1.63G | 354.8 |  1.47G |  318.3 |  10.280% |     136 | "37" |  4.6M | 5.07M |     1.10 | 0:05'01'' |
| Q25L60 | 1.36G | 294.9 |   1.3G |  281.8 |   4.449% |     127 | "35" |  4.6M | 4.59M |     1.00 | 0:03'55'' |
| Q30L60 | 1.18G | 257.2 |  1.15G |  250.9 |   2.467% |     112 | "31" |  4.6M | 4.55M |     0.99 | 0:03'32'' |

* kmergenie

```bash
BASE_NAME=RsphF
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

kmergenie -l 21 -k 151 -s 10 -t 8 ../R1.fq.gz -o oriR1
kmergenie -l 21 -k 151 -s 10 -t 8 ../R2.fq.gz -o oriR2
kmergenie -l 21 -k 151 -s 10 -t 8 ../Q20L60/pe.cor.fa -o Q20L60

```

## RsphF: down sampling

```bash
BASE_NAME=RsphF
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=4602977

for QxxLxx in $( parallel "echo 'Q{1}L{2}'" ::: 20 25 30 ::: 60 ); do
    echo "==> ${QxxLxx}"

    if [ ! -e 2_illumina/${QxxLxx}/pe.cor.fa ]; then
        echo "2_illumina/${QxxLxx}/pe.cor.fa not exists"
        continue;
    fi

    for X in 40 80 120 160 200 240; do
        printf "==> Coverage: %s\n" ${X}
        
        rm -fr 2_illumina/${QxxLxx}X${X}*
    
        faops split-about -l 0 \
            2_illumina/${QxxLxx}/pe.cor.fa \
            $(( ${REAL_G} * ${X} )) \
            "2_illumina/${QxxLxx}X${X}"
        
        MAX_SERIAL=$(
            cat 2_illumina/${QxxLxx}/environment.json \
                | jq ".SUM_OUT | tonumber | . / ${REAL_G} / ${X} | floor | . - 1"
        )
        
        for i in $( seq 0 1 ${MAX_SERIAL} ); do
            P=$( printf "%03d" ${i})
            printf "  * Part: %s\n" ${P}
            
            mkdir -p "2_illumina/${QxxLxx}X${X}P${P}"
            
            mv  "2_illumina/${QxxLxx}X${X}/${P}.fa" \
                "2_illumina/${QxxLxx}X${X}P${P}/pe.cor.fa"
            cp 2_illumina/${QxxLxx}/environment.json "2_illumina/${QxxLxx}X${X}P${P}"
    
        done
    done
done

```

## RsphF: generate k-unitigs (sampled)

```bash
BASE_NAME=RsphF
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 3 "
    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'

    if [ ! -e 2_illumina/Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        echo >&2 '    2_illumina/Q{1}L{2}X{3}P{4}/pe.cor.fa not exists'
        exit;
    fi

    if [ -e Q{1}L{2}X{3}P{4}/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi

    mkdir -p Q{1}L{2}X{3}P{4}
    cd Q{1}L{2}X{3}P{4}

    anchr kunitigs \
        ../2_illumina/Q{1}L{2}X{3}P{4}/pe.cor.fa \
        ../2_illumina/Q{1}L{2}X{3}P{4}/environment.json \
        -p 8 \
        --kmer 31,41,51,61,71,81 \
        -o kunitigs.sh
    bash kunitigs.sh

    echo >&2
    " ::: 20 25 30 ::: 60 ::: 40 80 120 160 200 240 ::: 000 001 002 003 004 005 006

```

## RsphF: create anchors (sampled)

```bash
BASE_NAME=RsphF
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 3 "
    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'

    if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    rm -fr Q{1}L{2}X{3}P{4}/anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh Q{1}L{2}X{3}P{4} 8 false
    
    echo >&2
    " ::: 20 25 30 ::: 60 ::: 40 80 120 160 200 240 ::: 000 001 002 003 004 005 006

```

* Stats of anchors

```bash
BASE_NAME=RsphF
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=4602977

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > stat2.md

parallel -k --no-run-if-empty -j 6 "
    if [ ! -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 Q{1}L{2}X{3}P{4} ${REAL_G}
    " ::: 20 25 30 ::: 60 ::: 40 80 120 160 200 240 ::: 000 001 002 003 004 005 006 \
     >> stat2.md

cat stat2.md
```

| Name           |  SumCor | CovCor | N50SR |   Sum |    # | N50Anchor |   Sum |    # | N50Others |     Sum |    # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|--------:|-------:|------:|------:|-----:|----------:|------:|-----:|----------:|--------:|-----:|--------------------:|----------:|:----------|
| Q20L60X40P000  | 184.12M |   40.0 |  5523 | 4.55M | 1367 |      5805 |  4.3M | 1025 |       719 | 240.91K |  342 | "31,41,51,61,71,81" | 0:03'51'' | 0:01'58'' |
| Q20L60X40P001  | 184.12M |   40.0 |  5274 | 4.55M | 1405 |      5614 | 4.32M | 1086 |       748 | 231.27K |  319 | "31,41,51,61,71,81" | 0:03'52'' | 0:01'47'' |
| Q20L60X40P002  | 184.12M |   40.0 |  5228 | 4.55M | 1404 |      5478 |  4.3M | 1054 |       755 | 252.48K |  350 | "31,41,51,61,71,81" | 0:03'49'' | 0:01'59'' |
| Q20L60X40P003  | 184.12M |   40.0 |  5242 | 4.55M | 1386 |      5579 |  4.3M | 1056 |       780 | 245.53K |  330 | "31,41,51,61,71,81" | 0:04'12'' | 0:02'11'' |
| Q20L60X40P004  | 184.12M |   40.0 |  5333 | 4.54M | 1400 |      5651 | 4.27M | 1031 |       753 | 269.24K |  369 | "31,41,51,61,71,81" | 0:04'12'' | 0:02'10'' |
| Q20L60X40P005  | 184.12M |   40.0 |  4866 | 4.57M | 1474 |      5252 | 4.29M | 1097 |       751 | 271.41K |  377 | "31,41,51,61,71,81" | 0:04'12'' | 0:02'12'' |
| Q20L60X40P006  | 184.12M |   40.0 |  5102 | 4.55M | 1466 |      5428 | 4.28M | 1089 |       738 | 272.99K |  377 | "31,41,51,61,71,81" | 0:04'13'' | 0:02'08'' |
| Q20L60X80P000  | 368.24M |   80.0 |  2354 | 4.39M | 2476 |      2675 | 3.74M | 1569 |       745 |  650.7K |  907 | "31,41,51,61,71,81" | 0:06'09'' | 0:03'24'' |
| Q20L60X80P001  | 368.24M |   80.0 |  2248 | 4.39M | 2551 |      2600 | 3.69M | 1579 |       766 | 705.52K |  972 | "31,41,51,61,71,81" | 0:06'00'' | 0:03'22'' |
| Q20L60X80P002  | 368.24M |   80.0 |  2305 | 4.38M | 2532 |      2653 |  3.7M | 1580 |       746 | 685.93K |  952 | "31,41,51,61,71,81" | 0:05'15'' | 0:03'14'' |
| Q20L60X120P000 | 552.36M |  120.0 |  1530 | 4.11M | 3193 |      1907 | 3.01M | 1654 |       745 |    1.1M | 1539 | "31,41,51,61,71,81" | 0:07'05'' | 0:03'03'' |
| Q20L60X120P001 | 552.36M |  120.0 |  1508 | 4.11M | 3212 |      1903 | 2.99M | 1631 |       734 |   1.12M | 1581 | "31,41,51,61,71,81" | 0:07'09'' | 0:03'00'' |
| Q20L60X160P000 | 736.48M |  160.0 |  1201 | 3.82M | 3527 |      1621 | 2.35M | 1458 |       736 |   1.47M | 2069 | "31,41,51,61,71,81" | 0:08'59'' | 0:03'28'' |
| Q20L60X200P000 |  920.6M |  200.0 |  1048 | 3.54M | 3637 |      1475 | 1.87M | 1259 |       724 |   1.67M | 2378 | "31,41,51,61,71,81" | 0:10'53'' | 0:03'30'' |
| Q20L60X240P000 |    1.1G |  240.0 |   976 | 3.32M | 3587 |      1413 |  1.6M | 1108 |       715 |   1.73M | 2479 | "31,41,51,61,71,81" | 0:12'46'' | 0:04'00'' |
| Q25L60X40P000  | 184.12M |   40.0 | 18603 | 4.55M |  512 |     18719 | 4.49M |  438 |       745 |  54.33K |   74 | "31,41,51,61,71,81" | 0:03'25'' | 0:01'50'' |
| Q25L60X40P001  | 184.12M |   40.0 | 16650 | 4.55M |  517 |     16854 |  4.5M |  450 |       731 |   47.8K |   67 | "31,41,51,61,71,81" | 0:03'28'' | 0:01'47'' |
| Q25L60X40P002  | 184.12M |   40.0 | 17665 | 4.55M |  512 |     17820 |  4.5M |  442 |       759 |  50.93K |   70 | "31,41,51,61,71,81" | 0:03'27'' | 0:01'46'' |
| Q25L60X40P003  | 184.12M |   40.0 | 16571 | 4.55M |  524 |     16602 |  4.5M |  462 |       755 |  45.53K |   62 | "31,41,51,61,71,81" | 0:03'28'' | 0:01'46'' |
| Q25L60X40P004  | 184.12M |   40.0 | 18453 | 4.55M |  502 |     18796 |  4.5M |  435 |       757 |  49.47K |   67 | "31,41,51,61,71,81" | 0:03'32'' | 0:01'52'' |
| Q25L60X40P005  | 184.12M |   40.0 | 15921 | 4.55M |  518 |     15979 |  4.5M |  455 |       752 |  45.82K |   63 | "31,41,51,61,71,81" | 0:04'17'' | 0:01'55'' |
| Q25L60X40P006  | 184.12M |   40.0 | 17984 | 4.55M |  482 |     17985 |  4.5M |  421 |       746 |  44.73K |   61 | "31,41,51,61,71,81" | 0:05'06'' | 0:01'49'' |
| Q25L60X80P000  | 368.24M |   80.0 | 18917 | 4.56M |  536 |     19988 | 4.49M |  434 |       755 |  74.43K |  102 | "31,41,51,61,71,81" | 0:08'46'' | 0:03'00'' |
| Q25L60X80P001  | 368.24M |   80.0 | 17945 | 4.56M |  528 |     18008 |  4.5M |  444 |       764 |  62.47K |   84 | "31,41,51,61,71,81" | 0:08'41'' | 0:02'57'' |
| Q25L60X80P002  | 368.24M |   80.0 | 17478 | 4.56M |  535 |     17665 |  4.5M |  448 |       755 |  62.46K |   87 | "31,41,51,61,71,81" | 0:08'43'' | 0:03'04'' |
| Q25L60X120P000 | 552.36M |  120.0 | 15909 | 4.57M |  621 |     16106 | 4.47M |  489 |       746 |  94.97K |  132 | "31,41,51,61,71,81" | 0:12'00'' | 0:03'42'' |
| Q25L60X120P001 | 552.36M |  120.0 | 15043 | 4.57M |  609 |     15679 | 4.48M |  490 |       751 |  85.39K |  119 | "31,41,51,61,71,81" | 0:12'04'' | 0:03'42'' |
| Q25L60X160P000 | 736.48M |  160.0 | 14258 | 4.56M |  682 |     14484 | 4.45M |  533 |       755 | 108.77K |  149 | "31,41,51,61,71,81" | 0:15'20'' | 0:04'13'' |
| Q25L60X200P000 |  920.6M |  200.0 | 12275 | 4.56M |  736 |     12571 | 4.44M |  576 |       761 | 116.55K |  160 | "31,41,51,61,71,81" | 0:18'19'' | 0:04'54'' |
| Q25L60X240P000 |    1.1G |  240.0 | 11064 | 4.56M |  799 |     11474 | 4.43M |  620 |       755 | 129.71K |  179 | "31,41,51,61,71,81" | 0:21'28'' | 0:05'57'' |
| Q30L60X40P000  | 184.12M |   40.0 | 12205 | 4.52M |  668 |     12367 | 4.46M |  582 |       786 |  66.66K |   86 | "31,41,51,61,71,81" | 0:05'31'' | 0:02'00'' |
| Q30L60X40P001  | 184.12M |   40.0 | 12508 | 4.52M |  648 |     12569 | 4.46M |  562 |       758 |  61.88K |   86 | "31,41,51,61,71,81" | 0:05'19'' | 0:01'51'' |
| Q30L60X40P002  | 184.12M |   40.0 | 12230 | 4.53M |  661 |     12285 | 4.47M |  582 |       776 |  59.69K |   79 | "31,41,51,61,71,81" | 0:05'13'' | 0:01'58'' |
| Q30L60X40P003  | 184.12M |   40.0 | 12131 | 4.52M |  664 |     12347 | 4.46M |  579 |       797 |  64.78K |   85 | "31,41,51,61,71,81" | 0:05'14'' | 0:02'03'' |
| Q30L60X40P004  | 184.12M |   40.0 | 12525 | 4.52M |  644 |     12545 | 4.47M |  571 |       798 |  55.73K |   73 | "31,41,51,61,71,81" | 0:05'19'' | 0:01'56'' |
| Q30L60X40P005  | 184.12M |   40.0 | 10733 | 4.54M |  707 |     10836 | 4.47M |  620 |       840 |   73.7K |   87 | "31,41,51,61,71,81" | 0:05'12'' | 0:02'08'' |
| Q30L60X80P000  | 368.24M |   80.0 | 18784 | 4.54M |  467 |     18887 |  4.5M |  403 |       746 |  46.76K |   64 | "31,41,51,61,71,81" | 0:08'14'' | 0:02'55'' |
| Q30L60X80P001  | 368.24M |   80.0 | 18575 | 4.54M |  475 |     18713 |  4.5M |  419 |       788 |  41.52K |   56 | "31,41,51,61,71,81" | 0:08'13'' | 0:03'08'' |
| Q30L60X80P002  | 368.24M |   80.0 | 20104 | 4.55M |  434 |     20151 | 4.52M |  392 |       755 |  30.87K |   42 | "31,41,51,61,71,81" | 0:08'17'' | 0:03'10'' |
| Q30L60X120P000 | 552.36M |  120.0 | 20259 | 4.55M |  413 |     20583 | 4.51M |  358 |       755 |     41K |   55 | "31,41,51,61,71,81" | 0:11'25'' | 0:03'46'' |
| Q30L60X120P001 | 552.36M |  120.0 | 23142 | 4.55M |  392 |     23142 | 4.52M |  350 |       753 |  30.68K |   42 | "31,41,51,61,71,81" | 0:11'25'' | 0:03'53'' |
| Q30L60X160P000 | 736.48M |  160.0 | 22582 | 4.55M |  384 |     22952 | 4.52M |  338 |       755 |   34.1K |   46 | "31,41,51,61,71,81" | 0:14'28'' | 0:04'22'' |
| Q30L60X200P000 |  920.6M |  200.0 | 23857 | 4.55M |  362 |     24234 | 4.52M |  319 |       755 |  31.94K |   43 | "31,41,51,61,71,81" | 0:14'39'' | 0:05'12'' |
| Q30L60X240P000 |    1.1G |  240.0 | 27029 | 4.55M |  341 |     27041 | 4.53M |  303 |       753 |  27.78K |   38 | "31,41,51,61,71,81" | 0:14'20'' | 0:05'41'' |

## RsphF: merge anchors

```bash
BASE_NAME=RsphF
cd ${HOME}/data/anchr/${BASE_NAME}

# merge anchors
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
            fi
            " ::: 20 25 30 ::: 60 ::: 40 80 120 160 200 240 ::: 000 001 002 003 004 005 006
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.others.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.others.fa
            fi
            " ::: 20 25 30 ::: 60 ::: 40 80 120 160 200 240 ::: 000 001 002 003 004 005 006
    ) \
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
BASE_NAME=RsphF
cd ${HOME}/data/anchr/${BASE_NAME}

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
| anchor.merge |   71151 | 4545906 | 172 |
| others.merge |    1077 |  203096 | 178 |

# *Vibrio cholerae* CP1032(5) Full

## VchoF: download

* Reference genome

```bash
BASE_NAME=VchoF
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 1_genome
cd 1_genome

cp ~/data/anchr/Vcho/1_genome/genome.fa .
cp ~/data/anchr/Vcho/1_genome/paralogs.fas .

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
BASE_NAME=VchoF
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 8_competitor
cd 8_competitor

cp ~/data/anchr/Vcho/8_competitor/* .

```

* FastQC

```bash
BASE_NAME=VchoF
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

## VchoF: combinations of different quality values and read lengths

* qual: 20, 25, 30, and 35
* len: 60

```bash
BASE_NAME=VchoF
cd ${HOME}/data/anchr/${BASE_NAME}

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


if [ ! -e 2_illumina/R1.shuffle.fq.gz ]; then
    shuffle.sh \
        in=2_illumina/R1.scythe.fq.gz \
        in2=2_illumina/R2.scythe.fq.gz \
        out=2_illumina/R1.shuffle.fq \
        out2=2_illumina/R2.shuffle.fq
    
    parallel --no-run-if-empty -j 2 "
            pigz -p 8 2_illumina/{}.shuffle.fq
        " ::: R1 R2
fi

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
        ../R1.shuffle.fq.gz ../R2.shuffle.fq.gz \
        -o stdout \
        | bash
    " ::: 20 25 30 35 ::: 60

```

* Stats

```bash
BASE_NAME=VchoF
cd ${HOME}/data/anchr/${BASE_NAME}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Paralogs"; faops n50 -H -S -C 1_genome/paralogs.fas;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "shuffle";  faops n50 -H -S -C 2_illumina/R1.shuffle.fq.gz 2_illumina/R2.shuffle.fq.gz;) >> stat.md

parallel -k --no-run-if-empty -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo Q{1}L{2};
            if [[ {1} -ge '30' ]]; then
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz \
                    2_illumina/Q{1}L{2}/Rs.fq.gz;
            else
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz;
            fi
        )
    " ::: 20 25 30 35 ::: 60 \
    >> stat.md

cat stat.md
```

| Name     |     N50 |        Sum |       # |
|:---------|--------:|-----------:|--------:|
| Genome   | 2961149 |    4033464 |       2 |
| Paralogs |    3483 |     114707 |      48 |
| Illumina |     251 | 1762158050 | 7020550 |
| uniq     |     251 | 1727781592 | 6883592 |
| scythe   |     198 | 1314316931 | 6883592 |
| shuffle  |     198 | 1314316931 | 6883592 |
| Q20L60   |     191 | 1196764734 | 6525578 |
| Q25L60   |     188 | 1099934249 | 6132504 |
| Q30L60   |     181 |  997874106 | 5859471 |
| Q35L60   |     156 |  664302023 | 4632696 |

## VchoF: quorum

```bash
BASE_NAME=VchoF
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 1 "
    cd 2_illumina/Q{1}L{2}
    echo >&2 '==> Group Q{1}L{2} <=='

    if [ ! -e R1.fq.gz ]; then
        echo >&2 '    R1.fq.gz not exists'
        exit;
    fi

    if [ -e pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa exists'
        exit;
    fi

    if [[ {1} -ge '30' ]]; then
        anchr quorum \
            R1.fq.gz R2.fq.gz Rs.fq.gz \
            -p 16 \
            -o quorum.sh
    else
        anchr quorum \
            R1.fq.gz R2.fq.gz \
            -p 16 \
            -o quorum.sh
    fi

    bash quorum.sh
    
    echo >&2
    " ::: 20 25 30 35 ::: 60

```

Clear intermediate files.

```bash
BASE_NAME=VchoF
cd $HOME/data/anchr/${BASE_NAME}

find 2_illumina -type f -name "quorum_mer_db.jf" | xargs rm
find 2_illumina -type f -name "k_u_hash_0"       | xargs rm
find 2_illumina -type f -name "*.tmp"            | xargs rm
find 2_illumina -type f -name "pe.renamed.fastq" | xargs rm
find 2_illumina -type f -name "se.renamed.fastq" | xargs rm
find 2_illumina -type f -name "pe.cor.sub.fa"    | xargs rm
```

* Stats of processed reads

```bash
BASE_NAME=VchoF
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=4033464

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > stat1.md

parallel -k --no-run-if-empty -j 3 "
    if [ ! -d 2_illumina/Q{1}L{2} ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 2_illumina/Q{1}L{2} ${REAL_G}
    " ::: 20 25 30 35 ::: 60 \
     >> stat1.md

cat stat1.md
```

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q20L60 |    1.2G | 296.7 | 970.76M |  240.7 |  18.885% |     182 | "111" | 4.03M | 4.55M |     1.13 | 0:06'26'' |
| Q25L60 |    1.1G | 272.7 | 939.68M |  233.0 |  14.569% |     178 | "109" | 4.03M | 4.37M |     1.08 | 0:04'50'' |
| Q30L60 | 998.27M | 247.5 |  882.7M |  218.8 |  11.578% |     172 | "103" | 4.03M | 4.16M |     1.03 | 0:03'27'' |
| Q35L60 | 664.93M | 164.9 | 625.69M |  155.1 |   5.901% |     146 |  "83" | 4.03M | 3.99M |     0.99 | 0:07'37'' |

* kmergenie

```bash
BASE_NAME=VchoF
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

kmergenie -l 21 -k 151 -s 10 -t 8 ../R1.fq.gz -o oriR1
kmergenie -l 21 -k 151 -s 10 -t 8 ../R2.fq.gz -o oriR2
kmergenie -l 21 -k 151 -s 10 -t 8 ../Q20L60/pe.cor.fa -o Q20L60

```

## VchoF: down sampling

```bash
BASE_NAME=VchoF
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=4033464

for QxxLxx in $( parallel "echo 'Q{1}L{2}'" ::: 20 25 30 35 ::: 60 ); do
    echo "==> ${QxxLxx}"

    if [ ! -e 2_illumina/${QxxLxx}/pe.cor.fa ]; then
        echo "2_illumina/${QxxLxx}/pe.cor.fa not exists"
        continue;
    fi

    for X in 40 80 120 160; do
        printf "==> Coverage: %s\n" ${X}
        
        rm -fr 2_illumina/${QxxLxx}X${X}*
    
        faops split-about -l 0 \
            2_illumina/${QxxLxx}/pe.cor.fa \
            $(( ${REAL_G} * ${X} )) \
            "2_illumina/${QxxLxx}X${X}"
        
        MAX_SERIAL=$(
            cat 2_illumina/${QxxLxx}/environment.json \
                | jq ".SUM_OUT | tonumber | . / ${REAL_G} / ${X} | floor | . - 1"
        )
        
        for i in $( seq 0 1 ${MAX_SERIAL} ); do
            P=$( printf "%03d" ${i})
            printf "  * Part: %s\n" ${P}
            
            mkdir -p "2_illumina/${QxxLxx}X${X}P${P}"
            
            mv  "2_illumina/${QxxLxx}X${X}/${P}.fa" \
                "2_illumina/${QxxLxx}X${X}P${P}/pe.cor.fa"
            cp 2_illumina/${QxxLxx}/environment.json "2_illumina/${QxxLxx}X${X}P${P}"
    
        done
    done
done

```

## VchoF: generate k-unitigs (sampled)

```bash
BASE_NAME=VchoF
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 3 "
    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'

    if [ ! -e 2_illumina/Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        echo >&2 '    2_illumina/Q{1}L{2}X{3}P{4}/pe.cor.fa not exists'
        exit;
    fi

    if [ -e Q{1}L{2}X{3}P{4}/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi

    mkdir -p Q{1}L{2}X{3}P{4}
    cd Q{1}L{2}X{3}P{4}

    anchr kunitigs \
        ../2_illumina/Q{1}L{2}X{3}P{4}/pe.cor.fa \
        ../2_illumina/Q{1}L{2}X{3}P{4}/environment.json \
        -p 8 \
        --kmer 31,41,51,61,71,81 \
        -o kunitigs.sh
    bash kunitigs.sh

    echo >&2
    " ::: 20 25 30 35 ::: 60 ::: 40 80 120 160 ::: 000 001 002 003 004 005

```

## VchoF: create anchors (sampled)

```bash
BASE_NAME=VchoF
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty -j 3 "
    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'

    if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    rm -fr Q{1}L{2}X{3}P{4}/anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh Q{1}L{2}X{3}P{4} 8 false
    
    echo >&2
    " ::: 20 25 30 35 ::: 60 ::: 40 80 120 160 ::: 000 001 002 003 004 005

```

* Stats of anchors

```bash
BASE_NAME=VchoF
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=4033464

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > stat2.md

parallel -k --no-run-if-empty -j 6 "
    if [ ! -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 Q{1}L{2}X{3}P{4} ${REAL_G}
    " ::: 20 25 30 35 ::: 60 ::: 40 80 120 160 ::: 000 001 002 003 004 005 \
     >> stat2.md

cat stat2.md
```

| Name           |  SumCor | CovCor | N50SR |   Sum |    # | N50Anchor |   Sum |    # | N50Others |     Sum |    # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|--------:|-------:|------:|------:|-----:|----------:|------:|-----:|----------:|--------:|-----:|--------------------:|----------:|:----------|
| Q20L60X40P000  | 161.34M |   40.0 |  2462 | 3.89M | 2106 |      2823 | 3.35M | 1374 |       772 | 538.04K |  732 | "31,41,51,61,71,81" | 0:04'48'' | 0:01'11'' |
| Q20L60X40P001  | 161.34M |   40.0 |  2429 | 3.87M | 2114 |      2724 | 3.32M | 1372 |       783 | 550.92K |  742 | "31,41,51,61,71,81" | 0:04'45'' | 0:01'05'' |
| Q20L60X40P002  | 161.34M |   40.0 |  2454 | 3.88M | 2063 |      2739 | 3.38M | 1384 |       775 | 501.94K |  679 | "31,41,51,61,71,81" | 0:04'43'' | 0:01'14'' |
| Q20L60X40P003  | 161.34M |   40.0 |  2492 | 3.88M | 2036 |      2785 |  3.4M | 1383 |       774 | 480.72K |  653 | "31,41,51,61,71,81" | 0:02'50'' | 0:01'07'' |
| Q20L60X40P004  | 161.34M |   40.0 |  2388 | 3.89M | 2126 |      2678 | 3.36M | 1406 |       781 | 534.58K |  720 | "31,41,51,61,71,81" | 0:02'51'' | 0:01'13'' |
| Q20L60X40P005  | 161.34M |   40.0 |  2403 | 3.88M | 2102 |      2700 | 3.36M | 1399 |       776 | 517.99K |  703 | "31,41,51,61,71,81" | 0:02'51'' | 0:01'06'' |
| Q20L60X80P000  | 322.68M |   80.0 |  1437 | 3.62M | 2898 |      1841 | 2.57M | 1433 |       739 |   1.05M | 1465 | "31,41,51,61,71,81" | 0:04'45'' | 0:01'39'' |
| Q20L60X80P001  | 322.68M |   80.0 |  1466 | 3.64M | 2873 |      1878 | 2.61M | 1443 |       754 |   1.04M | 1430 | "31,41,51,61,71,81" | 0:04'43'' | 0:01'36'' |
| Q20L60X80P002  | 322.68M |   80.0 |  1440 | 3.66M | 2954 |      1817 | 2.57M | 1440 |       747 |   1.09M | 1514 | "31,41,51,61,71,81" | 0:04'43'' | 0:01'34'' |
| Q20L60X120P000 | 484.02M |  120.0 |  1149 | 3.31M | 3146 |      1585 | 1.94M | 1222 |       726 |   1.36M | 1924 | "31,41,51,61,71,81" | 0:06'51'' | 0:01'35'' |
| Q20L60X120P001 | 484.02M |  120.0 |  1150 | 3.36M | 3216 |      1572 | 1.97M | 1248 |       725 |   1.39M | 1968 | "31,41,51,61,71,81" | 0:06'53'' | 0:01'41'' |
| Q20L60X160P000 | 645.35M |  160.0 |  1007 | 3.07M | 3221 |      1448 | 1.54M | 1030 |       714 |   1.53M | 2191 | "31,41,51,61,71,81" | 0:08'51'' | 0:01'57'' |
| Q25L60X40P000  | 161.34M |   40.0 |  2817 | 3.92M | 1890 |      3166 | 3.48M | 1304 |       794 | 435.83K |  586 | "31,41,51,61,71,81" | 0:02'56'' | 0:01'03'' |
| Q25L60X40P001  | 161.34M |   40.0 |  2792 | 3.91M | 1921 |      3115 | 3.47M | 1318 |       793 | 448.33K |  603 | "31,41,51,61,71,81" | 0:02'55'' | 0:00'59'' |
| Q25L60X40P002  | 161.34M |   40.0 |  2863 |  3.9M | 1837 |      3120 | 3.51M | 1303 |       774 | 393.18K |  534 | "31,41,51,61,71,81" | 0:02'49'' | 0:00'57'' |
| Q25L60X40P003  | 161.34M |   40.0 |  2900 | 3.91M | 1846 |      3179 | 3.51M | 1306 |       796 | 401.91K |  540 | "31,41,51,61,71,81" | 0:02'49'' | 0:00'52'' |
| Q25L60X40P004  | 161.34M |   40.0 |  2628 | 3.93M | 1966 |      2913 | 3.47M | 1342 |       786 | 462.73K |  624 | "31,41,51,61,71,81" | 0:02'49'' | 0:01'01'' |
| Q25L60X80P000  | 322.68M |   80.0 |  1707 | 3.76M | 2661 |      2109 | 2.89M | 1465 |       758 | 870.59K | 1196 | "31,41,51,61,71,81" | 0:05'07'' | 0:01'29'' |
| Q25L60X80P001  | 322.68M |   80.0 |  1732 | 3.75M | 2616 |      2140 | 2.92M | 1470 |       754 | 831.13K | 1146 | "31,41,51,61,71,81" | 0:05'21'' | 0:01'27'' |
| Q25L60X120P000 | 484.02M |  120.0 |  1340 | 3.55M | 2995 |      1739 | 2.41M | 1402 |       746 |   1.14M | 1593 | "31,41,51,61,71,81" | 0:08'13'' | 0:01'54'' |
| Q25L60X160P000 | 645.35M |  160.0 |  1177 | 3.39M | 3170 |      1586 | 2.05M | 1283 |       730 |   1.34M | 1887 | "31,41,51,61,71,81" | 0:12'02'' | 0:01'45'' |
| Q30L60X40P000  | 161.34M |   40.0 |  6751 | 3.95M |  953 |      7050 | 3.81M |  768 |       793 | 136.58K |  185 | "31,41,51,61,71,81" | 0:04'06'' | 0:01'13'' |
| Q30L60X40P001  | 161.34M |   40.0 |  6742 | 3.95M |  944 |      6961 | 3.81M |  759 |       796 | 138.05K |  185 | "31,41,51,61,71,81" | 0:04'05'' | 0:00'55'' |
| Q30L60X40P002  | 161.34M |   40.0 |  6773 | 3.95M |  927 |      7062 | 3.82M |  755 |       767 | 125.77K |  172 | "31,41,51,61,71,81" | 0:04'26'' | 0:00'55'' |
| Q30L60X40P003  | 161.34M |   40.0 |  7020 | 3.94M |  918 |      7323 | 3.82M |  748 |       785 | 125.69K |  170 | "31,41,51,61,71,81" | 0:04'15'' | 0:00'58'' |
| Q30L60X40P004  | 161.34M |   40.0 |  6893 | 3.94M |  942 |      6958 | 3.81M |  757 |       801 | 137.56K |  185 | "31,41,51,61,71,81" | 0:03'57'' | 0:01'06'' |
| Q30L60X80P000  | 322.68M |   80.0 |  3971 | 3.94M | 1452 |      4234 | 3.67M | 1090 |       789 | 267.63K |  362 | "31,41,51,61,71,81" | 0:06'21'' | 0:01'35'' |
| Q30L60X80P001  | 322.68M |   80.0 |  4067 | 3.95M | 1449 |      4401 | 3.68M | 1084 |       787 |  271.5K |  365 | "31,41,51,61,71,81" | 0:06'15'' | 0:01'35'' |
| Q30L60X120P000 | 484.02M |  120.0 |  2923 | 3.92M | 1846 |      3161 | 3.52M | 1295 |       775 | 404.11K |  551 | "31,41,51,61,71,81" | 0:07'48'' | 0:02'18'' |
| Q30L60X160P000 | 645.35M |  160.0 |  2423 | 3.88M | 2145 |      2768 | 3.34M | 1401 |       760 | 542.85K |  744 | "31,41,51,61,71,81" | 0:08'26'' | 0:02'37'' |
| Q35L60X40P000  | 161.34M |   40.0 | 14108 | 3.94M |  532 |     14266 | 3.87M |  437 |       755 |   67.3K |   95 | "31,41,51,61,71,81" | 0:02'50'' | 0:01'29'' |
| Q35L60X40P001  | 161.34M |   40.0 | 15083 | 3.94M |  496 |     15588 | 3.87M |  406 |       744 |  64.11K |   90 | "31,41,51,61,71,81" | 0:02'57'' | 0:01'14'' |
| Q35L60X40P002  | 161.34M |   40.0 | 14338 | 3.93M |  515 |     14732 | 3.87M |  432 |       794 |  61.68K |   83 | "31,41,51,61,71,81" | 0:02'58'' | 0:01'01'' |
| Q35L60X80P000  | 322.68M |   80.0 |  8341 | 3.95M |  769 |      8549 | 3.85M |  633 |       733 |  97.41K |  136 | "31,41,51,61,71,81" | 0:04'43'' | 0:01'56'' |
| Q35L60X120P000 | 484.02M |  120.0 |  6066 | 3.95M | 1009 |      6362 |  3.8M |  815 |       754 | 141.19K |  194 | "31,41,51,61,71,81" | 0:06'15'' | 0:02'26'' |

## VchoF: merge anchors

```bash
BASE_NAME=VchoF
cd ${HOME}/data/anchr/${BASE_NAME}

# merge anchors
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
            fi
            " ::: 20 25 30 ::: 60 ::: 40 80 120 160 ::: 000 001 002 003 004 005 006
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.others.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.others.fa
            fi
            " ::: 20 25 30 ::: 60 ::: 40 80 120 160 ::: 000 001 002 003 004 005 006
    ) \
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
BASE_NAME=VchoF
cd ${HOME}/data/anchr/${BASE_NAME}

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
| anchor.merge |   76329 | 3919163 | 126 |
| others.merge |    1010 |  201938 | 197 |
