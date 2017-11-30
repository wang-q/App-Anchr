# Bacteria 2+3

[TOC levels=1-3]: # " "
- [Bacteria 2+3](#bacteria-23)
- [Vibrio parahaemolyticus ATCC BAA-239, 副溶血弧菌](#vibrio-parahaemolyticus-atcc-baa-239-副溶血弧菌)
    - [Vpar: download](#vpar-download)
    - [Vpar: preprocess Illumina reads](#vpar-preprocess-illumina-reads)
    - [Vpar: preprocess PacBio reads](#vpar-preprocess-pacbio-reads)
    - [Vpar: reads stats](#vpar-reads-stats)
    - [Vpar: spades](#vpar-spades)
    - [Vpar: platanus](#vpar-platanus)
    - [Vpar: quorum](#vpar-quorum)
    - [Vpar: down sampling](#vpar-down-sampling)
    - [Vpar: k-unitigs and anchors (sampled)](#vpar-k-unitigs-and-anchors-sampled)
    - [Vpar: merge anchors](#vpar-merge-anchors)
    - [Vpar: 3GS](#vpar-3gs)
    - [Vpar: expand anchors](#vpar-expand-anchors)
    - [Vpar: final stats](#vpar-final-stats)
    - [Vpar: clear intermediate files](#vpar-clear-intermediate-files)
- [Legionella pneumophila subsp. pneumophila ATCC 33152D-5; Philadelphia-1, 嗜肺军团菌](#legionella-pneumophila-subsp-pneumophila-atcc-33152d-5-philadelphia-1-嗜肺军团菌)
    - [Lpne: download](#lpne-download)
    - [Lpne: preprocess Illumina reads](#lpne-preprocess-illumina-reads)
    - [Lpne: preprocess PacBio reads](#lpne-preprocess-pacbio-reads)
    - [Lpne: reads stats](#lpne-reads-stats)
    - [Lpne: spades](#lpne-spades)
    - [Lpne: platanus](#lpne-platanus)
    - [Lpne: quorum](#lpne-quorum)
    - [Lpne: down sampling](#lpne-down-sampling)
    - [Lpne: k-unitigs and anchors (sampled)](#lpne-k-unitigs-and-anchors-sampled)
    - [Lpne: merge anchors](#lpne-merge-anchors)
    - [Lpne: 3GS](#lpne-3gs)
    - [Lpne: expand anchors](#lpne-expand-anchors)
    - [Lpne: final stats](#lpne-final-stats)
    - [Lpne: clear intermediate files](#lpne-clear-intermediate-files)
- [Neisseria gonorrhoeae FDAARGOS_207, 淋病奈瑟氏菌](#neisseria-gonorrhoeae-fdaargos-207-淋病奈瑟氏菌)
    - [Ngon: download](#ngon-download)
    - [Ngon: preprocess Illumina reads](#ngon-preprocess-illumina-reads)
    - [Ngon: preprocess PacBio reads](#ngon-preprocess-pacbio-reads)
    - [Ngon: reads stats](#ngon-reads-stats)
    - [Ngon: spades](#ngon-spades)
    - [Ngon: platanus](#ngon-platanus)
    - [Ngon: quorum](#ngon-quorum)
    - [Ngon: down sampling](#ngon-down-sampling)
    - [Ngon: k-unitigs and anchors (sampled)](#ngon-k-unitigs-and-anchors-sampled)
    - [Ngon: merge anchors](#ngon-merge-anchors)
    - [Ngon: 3GS](#ngon-3gs)
    - [Ngon: expand anchors](#ngon-expand-anchors)
    - [Ngon: final stats](#ngon-final-stats)
    - [Ngon: clear intermediate files](#ngon-clear-intermediate-files)
- [Neisseria meningitidis FDAARGOS_209, 脑膜炎奈瑟氏菌](#neisseria-meningitidis-fdaargos-209-脑膜炎奈瑟氏菌)
    - [Nmen: download](#nmen-download)
    - [Nmen: preprocess Illumina reads](#nmen-preprocess-illumina-reads)
    - [Nmen: preprocess PacBio reads](#nmen-preprocess-pacbio-reads)
    - [Nmen: reads stats](#nmen-reads-stats)
    - [Nmen: spades](#nmen-spades)
    - [Nmen: platanus](#nmen-platanus)
    - [Nmen: quorum](#nmen-quorum)
    - [Nmen: down sampling](#nmen-down-sampling)
    - [Nmen: k-unitigs and anchors (sampled)](#nmen-k-unitigs-and-anchors-sampled)
    - [Nmen: merge anchors](#nmen-merge-anchors)
    - [Nmen: 3GS](#nmen-3gs)
    - [Nmen: expand anchors](#nmen-expand-anchors)
    - [Nmen: final stats](#nmen-final-stats)
    - [Nmen: clear intermediate files](#nmen-clear-intermediate-files)
- [Bordetella pertussis FDAARGOS_195, 百日咳博德特氏杆菌](#bordetella-pertussis-fdaargos-195-百日咳博德特氏杆菌)
    - [Bper: download](#bper-download)
    - [Bper: combinations of different quality values and read lengths](#bper-combinations-of-different-quality-values-and-read-lengths)
    - [Bper: down sampling](#bper-down-sampling)
    - [Bper: generate super-reads](#bper-generate-super-reads)
    - [Bper: create anchors](#bper-create-anchors)
    - [Bper: results](#bper-results)
    - [Bper: merge anchors](#bper-merge-anchors)
- [Corynebacterium diphtheriae FDAARGOS_197, 白喉杆菌](#corynebacterium-diphtheriae-fdaargos-197-白喉杆菌)
    - [Cdip: download](#cdip-download)
    - [Cdip: combinations of different quality values and read lengths](#cdip-combinations-of-different-quality-values-and-read-lengths)
    - [Cdip: quorum](#cdip-quorum)
    - [Cdip: down sampling](#cdip-down-sampling)
    - [Cdip: k-unitigs and anchors (sampled)](#cdip-k-unitigs-and-anchors-sampled)
    - [Cdip: merge anchors](#cdip-merge-anchors)
    - [Cdip: 3GS](#cdip-3gs)
    - [Cdip: expand anchors](#cdip-expand-anchors)
- [Francisella tularensis FDAARGOS_247, 土拉热弗朗西斯氏菌](#francisella-tularensis-fdaargos-247-土拉热弗朗西斯氏菌)
    - [Ftul: download](#ftul-download)
    - [Ftul: combinations of different quality values and read lengths](#ftul-combinations-of-different-quality-values-and-read-lengths)
    - [Ftul: quorum](#ftul-quorum)
    - [Ftul: down sampling](#ftul-down-sampling)
    - [Ftul: k-unitigs and anchors (sampled)](#ftul-k-unitigs-and-anchors-sampled)
    - [Ftul: merge anchors](#ftul-merge-anchors)
    - [Ftul: 3GS](#ftul-3gs)
    - [Ftul: expand anchors](#ftul-expand-anchors)
- [Shigella flexneri NCTC0001, 福氏志贺氏菌](#shigella-flexneri-nctc0001-福氏志贺氏菌)
    - [Sfle: download](#sfle-download)
    - [Sfle: combinations of different quality values and read lengths](#sfle-combinations-of-different-quality-values-and-read-lengths)
    - [Sfle: down sampling](#sfle-down-sampling)
    - [Sfle: generate super-reads](#sfle-generate-super-reads)
    - [Sfle: create anchors](#sfle-create-anchors)
    - [Sfle: results](#sfle-results)
    - [Sfle: merge anchors](#sfle-merge-anchors)
    - [Sfle: 3GS](#sfle-3gs)
    - [Sfle: expand anchors](#sfle-expand-anchors)
- [Haemophilus influenzae FDAARGOS_199, 流感嗜血杆菌](#haemophilus-influenzae-fdaargos-199-流感嗜血杆菌)
    - [Hinf: download](#hinf-download)
- [Listeria monocytogenes FDAARGOS_351, 单核细胞增生李斯特氏菌](#listeria-monocytogenes-fdaargos-351-单核细胞增生李斯特氏菌)
    - [Lmon: download](#lmon-download)
- [Clostridioides difficile 630](#clostridioides-difficile-630)
    - [Cdif: download](#cdif-download)
- [Campylobacter jejuni subsp. jejuni ATCC 700819, 空肠弯曲杆菌](#campylobacter-jejuni-subsp-jejuni-atcc-700819-空肠弯曲杆菌)
    - [Cjej: download](#cjej-download)
- [Escherichia virus Lambda](#escherichia-virus-lambda)
    - [lambda: download](#lambda-download)
    - [lambda: preprocess PacBio reads](#lambda-preprocess-pacbio-reads)
    - [lambda: reads stats](#lambda-reads-stats)
    - [lambda: 3GS](#lambda-3gs)


# Vibrio parahaemolyticus ATCC BAA-239, 副溶血弧菌

Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Vpar: download

* Settings

```bash
BASE_NAME=Vpar
REAL_G=5165770
COVERAGE2="30 40 50 60 80 120 160"
COVERAGE3="40 80"
READ_QUAL="25 30"
READ_LEN="60"
EXPAND_WITH="40"

```

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

* FastQC

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

* kmergenie

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

parallel -j 2 "
    kmergenie -l 21 -k 121 -s 10 -t 8 ../{}.fq.gz -o {}
    " ::: R1 R2

```

## Vpar: preprocess Illumina reads

```bash
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

cat <<EOF > 2_illumina/illumina_adapters.fa
>multiplexing-forward
GATCGGAAGAGCACACGTCT
>solexa-forward
AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
>truseq-forward-contam
AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
>truseq-reverse-contam
AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTA
>nextera-forward-read-contam
CTGTCTCTTATACACATCTCCGAGCCCACGAGAC
>nextera-reverse-read-contam
CTGTCTCTTATACACATCTGACGCTGCCGACGA
>solexa-reverse
AGATCGGAAGAGCGGTTCAGCAGGAATGCCGAG

EOF

if [ ! -e 2_illumina/R1.scythe.fq.gz ]; then
    parallel --no-run-if-empty -j 2 "
        scythe \
            2_illumina/{}.uniq.fq.gz \
            -q sanger \
            -a 2_illumina/illumina_adapters.fa \
            --quiet \
            | pigz -p 4 -c \
            > 2_illumina/{}.scythe.fq.gz
        " ::: R1 R2
fi

parallel --no-run-if-empty --linebuffer -k -j 3 "
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
    " ::: ${READ_QUAL} ::: ${READ_LEN}

```

## Vpar: preprocess PacBio reads

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

for X in ${COVERAGE3}; do
    printf "==> Coverage: %s\n" ${X}
    
    faops split-about -m 1 -l 0 \
        3_pacbio/pacbio.fasta \
        $(( ${REAL_G} * ${X} )) \
        3_pacbio
        
    mv 3_pacbio/000.fa "3_pacbio/pacbio.X${X}.raw.fasta"

done

for X in ${COVERAGE3}; do
    printf "==> Coverage: %s\n" ${X}
    
    anchr trimlong --parallel 16 -v \
        "3_pacbio/pacbio.X${X}.raw.fasta" \
        -o "3_pacbio/pacbio.X${X}.trim.fasta"

done

```

## Vpar: reads stats

```bash
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

parallel --no-run-if-empty -k -j 3 "
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
    " ::: ${READ_QUAL} ::: ${READ_LEN} \
    >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "PacBio";    faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md

parallel --no-run-if-empty -k -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo X{1}.{2};
            faops n50 -H -S -C \
                3_pacbio/pacbio.X{1}.{2}.fasta;
        )
    " ::: ${COVERAGE3} ::: raw trim \
    >> stat.md

cat stat.md

```

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 3288558 |    5165770 |        2 |
| Paralogs |    3333 |     155714 |       62 |
| Illumina |     101 | 1368727962 | 13551762 |
| uniq     |     101 | 1361783404 | 13483004 |
| Q25L60   |     101 | 1200269501 | 12011552 |
| Q30L60   |     101 | 1141304237 | 11613075 |
| PacBio   |   11771 | 1228497092 |   143537 |
| X40.raw  |   11816 |  206635364 |    24145 |
| X40.trim |   10545 |  173840405 |    20555 |
| X80.raw  |   11822 |  413261717 |    48766 |
| X80.trim |   10678 |  355440531 |    41795 |

## Vpar: spades

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

spades.py \
    -t 16 \
    -k 21,33,55,77 \
    -1 2_illumina/Q25L60/R1.fq.gz \
    -2 2_illumina/Q25L60/R2.fq.gz \
    -s 2_illumina/Q25L60/Rs.fq.gz \
    -o 8_spades

anchr contained \
    8_spades/contigs.fasta \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin 8_spades/contigs.non-contained.fasta

```

## Vpar: platanus

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 8_platanus
cd 8_platanus

if [ ! -e pe.fa ]; then
    faops interleave \
        -p pe \
        ../2_illumina/Q25L60/R1.fq.gz \
        ../2_illumina/Q25L60/R2.fq.gz \
        > pe.fa
    
    faops interleave \
        -p se \
        ../2_illumina/Q25L60/Rs.fq.gz \
        > se.fa
fi

platanus assemble -t 16 -m 100 \
    -f pe.fa se.fa \
    2>&1 | tee ass_log.txt

platanus scaffold -t 16 \
    -c out_contig.fa -b out_contigBubble.fa \
    -ip1 pe.fa \
    2>&1 | tee sca_log.txt

platanus gap_close -t 16 \
    -c out_scaffold.fa \
    -ip1 pe.fa \
    2>&1 | tee gap_log.txt

anchr contained \
    out_gapClosed.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin gapClosed.non-contained.fasta

```

## Vpar: quorum

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty --linebuffer -k -j 1 "
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
    " ::: ${READ_QUAL} ::: ${READ_LEN}

# Stats of processed reads
bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > stat1.md

parallel --no-run-if-empty -k -j 3 "
    if [ ! -d 2_illumina/Q{1}L{2} ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 2_illumina/Q{1}L{2} ${REAL_G}
    " ::: ${READ_QUAL} ::: ${READ_LEN} \
     >> stat1.md

cat stat1.md

```

| Name   | SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|------:|-------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 |  1.2G | 232.4 |  1.12G |  216.3 |   6.910% |      99 | "71" | 5.17M | 5.48M |     1.06 | 0:04'00'' |
| Q30L60 | 1.14G | 221.1 |  1.07G |  207.1 |   6.300% |      99 | "71" | 5.17M | 5.42M |     1.05 | 0:04'08'' |

## Vpar: down sampling

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

for QxxLxx in $( parallel "echo 'Q{1}L{2}'" ::: ${READ_QUAL} ::: ${READ_LEN} ); do
    echo "==> ${QxxLxx}"

    if [ ! -e 2_illumina/${QxxLxx}/pe.cor.fa ]; then
        echo "2_illumina/${QxxLxx}/pe.cor.fa not exists"
        continue;
    fi

    for X in ${COVERAGE2}; do
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

## Vpar: k-unitigs and anchors (sampled)

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

# k-unitigs (sampled)
parallel --no-run-if-empty --linebuffer -k -j 2 "
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
        -p 16 \
        --kmer 31,41,51,61,71,81 \
        -o kunitigs.sh
    bash kunitigs.sh

    echo >&2
    " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})

# anchors (sampled)
parallel --no-run-if-empty --linebuffer -k -j 3 "
    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'

    if [ ! -e Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa not exists'
        exit;
    fi

    if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi

    rm -fr Q{1}L{2}X{3}P{4}/anchor
    mkdir -p Q{1}L{2}X{3}P{4}/anchor
    cd Q{1}L{2}X{3}P{4}/anchor
    anchr anchors \
        ../k_unitigs.fasta \
        ../pe.cor.fa \
        -p 8 \
        -o anchors.sh
    bash anchors.sh
    
    echo >&2
    " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})

# Stats of anchors
bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > stat2.md

parallel --no-run-if-empty -k -j 6 "
    if [ ! -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 Q{1}L{2}X{3}P{4} ${REAL_G}
    " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100}) \
    >> stat2.md

cat stat2.md

```

| Name           |  SumCor | CovCor |  N50SR |   Sum |   # | N50Anchor |   Sum |   # | N50Others |    Sum |  # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|--------:|-------:|-------:|------:|----:|----------:|------:|----:|----------:|-------:|---:|--------------------:|----------:|:----------|
| Q25L60X30P000  | 154.97M |   30.0 | 109589 | 5.06M | 125 |    109589 | 5.04M |  99 |       697 |  17.8K | 26 | "31,41,51,61,71,81" | 0:03'14'' | 0:00'35'' |
| Q25L60X30P001  | 154.97M |   30.0 | 100541 | 5.06M | 120 |    100541 | 5.04M |  93 |       610 | 17.01K | 27 | "31,41,51,61,71,81" | 0:03'12'' | 0:00'35'' |
| Q25L60X30P002  | 154.97M |   30.0 |  97266 | 5.06M | 129 |     97266 | 5.04M | 104 |       641 | 16.67K | 25 | "31,41,51,61,71,81" | 0:03'22'' | 0:00'34'' |
| Q25L60X30P003  | 154.97M |   30.0 |  95823 | 5.06M | 122 |     95823 | 5.04M |  97 |       693 | 17.41K | 25 | "31,41,51,61,71,81" | 0:03'20'' | 0:00'30'' |
| Q25L60X30P004  | 154.97M |   30.0 | 100499 | 5.06M | 129 |    100499 | 5.04M | 100 |       693 | 19.35K | 29 | "31,41,51,61,71,81" | 0:03'30'' | 0:00'30'' |
| Q25L60X30P005  | 154.97M |   30.0 |  92972 | 5.06M | 124 |     92972 | 5.04M |  98 |       671 | 17.09K | 26 | "31,41,51,61,71,81" | 0:03'13'' | 0:00'30'' |
| Q25L60X30P006  | 154.97M |   30.0 |  99695 | 5.06M | 120 |     99695 | 5.04M |  95 |       802 | 24.36K | 25 | "31,41,51,61,71,81" | 0:03'19'' | 0:00'28'' |
| Q25L60X40P000  | 206.63M |   40.0 |  99472 | 5.06M | 131 |     99472 | 5.04M | 106 |       697 | 17.28K | 25 | "31,41,51,61,71,81" | 0:03'34'' | 0:00'30'' |
| Q25L60X40P001  | 206.63M |   40.0 |  90461 | 5.06M | 130 |     93540 | 5.04M | 104 |       710 | 18.07K | 26 | "31,41,51,61,71,81" | 0:04'49'' | 0:00'29'' |
| Q25L60X40P002  | 206.63M |   40.0 |  95833 | 5.06M | 124 |     95833 | 5.04M | 100 |       710 | 16.99K | 24 | "31,41,51,61,71,81" | 0:04'55'' | 0:00'27'' |
| Q25L60X40P003  | 206.63M |   40.0 |  89804 | 5.06M | 137 |     89804 | 5.04M | 109 |       710 | 19.32K | 28 | "31,41,51,61,71,81" | 0:04'42'' | 0:00'28'' |
| Q25L60X40P004  | 206.63M |   40.0 |  99637 | 5.06M | 128 |     99637 | 5.04M | 100 |       697 | 19.43K | 28 | "31,41,51,61,71,81" | 0:04'43'' | 0:00'28'' |
| Q25L60X50P000  | 258.29M |   50.0 |  83870 | 5.06M | 138 |     83870 | 5.04M | 113 |       697 | 17.27K | 25 | "31,41,51,61,71,81" | 0:04'15'' | 0:00'27'' |
| Q25L60X50P001  | 258.29M |   50.0 |  86671 |  5.1M | 139 |     86671 | 5.04M | 113 |     38604 | 56.06K | 26 | "31,41,51,61,71,81" | 0:04'48'' | 0:00'29'' |
| Q25L60X50P002  | 258.29M |   50.0 |  88545 | 5.06M | 141 |     88545 | 5.04M | 113 |       656 | 19.13K | 28 | "31,41,51,61,71,81" | 0:05'11'' | 0:00'29'' |
| Q25L60X50P003  | 258.29M |   50.0 |  81937 | 5.06M | 138 |     81937 | 5.04M | 111 |       710 | 18.81K | 27 | "31,41,51,61,71,81" | 0:05'05'' | 0:00'28'' |
| Q25L60X60P000  | 309.95M |   60.0 |  81937 | 5.06M | 151 |     81937 | 5.04M | 124 |       710 | 18.82K | 27 | "31,41,51,61,71,81" | 0:04'53'' | 0:00'30'' |
| Q25L60X60P001  | 309.95M |   60.0 |  81569 |  5.1M | 153 |     81569 | 5.04M | 126 |     38604 | 57.25K | 27 | "31,41,51,61,71,81" | 0:05'17'' | 0:00'30'' |
| Q25L60X60P002  | 309.95M |   60.0 |  84496 | 5.06M | 147 |     84496 | 5.04M | 121 |       710 | 18.23K | 26 | "31,41,51,61,71,81" | 0:04'23'' | 0:00'27'' |
| Q25L60X80P000  | 413.26M |   80.0 |  69413 | 5.06M | 174 |     69621 | 5.04M | 145 |       697 | 19.97K | 29 | "31,41,51,61,71,81" | 0:06'15'' | 0:00'34'' |
| Q25L60X80P001  | 413.26M |   80.0 |  79824 | 5.06M | 162 |     81559 | 5.04M | 136 |       729 | 18.52K | 26 | "31,41,51,61,71,81" | 0:05'41'' | 0:00'33'' |
| Q25L60X120P000 | 619.89M |  120.0 |  52714 |  5.1M | 202 |     55788 | 5.04M | 171 |     38604 | 59.96K | 31 | "31,41,51,61,71,81" | 0:06'51'' | 0:00'33'' |
| Q25L60X160P000 | 826.52M |  160.0 |  41027 | 5.11M | 234 |     41027 | 5.05M | 203 |     38604 |  59.9K | 31 | "31,41,51,61,71,81" | 0:09'52'' | 0:00'35'' |
| Q30L60X30P000  | 154.97M |   30.0 | 134227 | 5.06M | 116 |    139680 | 5.04M |  88 |       641 | 18.63K | 28 | "31,41,51,61,71,81" | 0:03'36'' | 0:00'28'' |
| Q30L60X30P001  | 154.97M |   30.0 | 155741 | 5.06M | 112 |    155741 | 5.04M |  82 |       697 | 20.53K | 30 | "31,41,51,61,71,81" | 0:04'04'' | 0:00'26'' |
| Q30L60X30P002  | 154.97M |   30.0 | 139680 |  5.1M | 113 |    139680 | 5.04M |  83 |     38604 | 58.88K | 30 | "31,41,51,61,71,81" | 0:03'38'' | 0:00'27'' |
| Q30L60X30P003  | 154.97M |   30.0 | 105213 | 5.06M | 116 |    105213 | 5.04M |  88 |       641 | 18.77K | 28 | "31,41,51,61,71,81" | 0:03'57'' | 0:00'26'' |
| Q30L60X30P004  | 154.97M |   30.0 | 152507 | 5.06M | 110 |    152507 | 5.04M |  81 |       700 | 20.15K | 29 | "31,41,51,61,71,81" | 0:03'17'' | 0:00'25'' |
| Q30L60X30P005  | 154.97M |   30.0 | 139680 | 5.06M | 110 |    152507 | 5.03M |  79 |       775 | 29.78K | 31 | "31,41,51,61,71,81" | 0:02'52'' | 0:00'26'' |
| Q30L60X40P000  | 206.63M |   40.0 | 152640 | 5.06M | 106 |    152640 | 5.04M |  83 |       693 | 15.75K | 23 | "31,41,51,61,71,81" | 0:03'42'' | 0:00'26'' |
| Q30L60X40P001  | 206.63M |   40.0 | 105206 | 5.06M | 109 |    105206 | 5.04M |  85 |       710 | 16.72K | 24 | "31,41,51,61,71,81" | 0:03'24'' | 0:00'26'' |
| Q30L60X40P002  | 206.63M |   40.0 | 105213 | 5.06M | 113 |    105213 | 5.04M |  87 |       656 | 17.45K | 26 | "31,41,51,61,71,81" | 0:03'31'' | 0:00'26'' |
| Q30L60X40P003  | 206.63M |   40.0 | 152517 | 5.06M | 109 |    152517 | 5.04M |  84 |       846 | 24.98K | 25 | "31,41,51,61,71,81" | 0:03'36'' | 0:00'27'' |
| Q30L60X40P004  | 206.63M |   40.0 | 115357 | 5.06M | 109 |    115357 | 5.04M |  82 |       689 | 18.28K | 27 | "31,41,51,61,71,81" | 0:03'09'' | 0:00'27'' |
| Q30L60X50P000  | 258.29M |   50.0 | 134285 | 5.06M | 112 |    134285 | 5.04M |  89 |       697 | 16.04K | 23 | "31,41,51,61,71,81" | 0:03'41'' | 0:00'27'' |
| Q30L60X50P001  | 258.29M |   50.0 | 105213 |  5.1M | 107 |    139690 | 5.04M |  83 |     38604 | 54.59K | 24 | "31,41,51,61,71,81" | 0:04'06'' | 0:00'26'' |
| Q30L60X50P002  | 258.29M |   50.0 | 119300 | 5.06M | 114 |    119300 | 5.04M |  88 |       700 | 17.91K | 26 | "31,41,51,61,71,81" | 0:03'33'' | 0:00'26'' |
| Q30L60X50P003  | 258.29M |   50.0 | 105213 | 5.06M | 111 |    105213 | 5.04M |  85 |       693 | 18.01K | 26 | "31,41,51,61,71,81" | 0:03'10'' | 0:00'27'' |
| Q30L60X60P000  | 309.95M |   60.0 | 115507 | 5.06M | 118 |    115507 | 5.04M |  92 |       710 | 18.13K | 26 | "31,41,51,61,71,81" | 0:05'06'' | 0:00'28'' |
| Q30L60X60P001  | 309.95M |   60.0 | 104258 |  5.1M | 120 |    105213 | 5.04M |  93 |     38604 | 56.45K | 27 | "31,41,51,61,71,81" | 0:05'17'' | 0:00'28'' |
| Q30L60X60P002  | 309.95M |   60.0 | 139690 | 5.06M | 111 |    139690 | 5.04M |  87 |       697 | 16.43K | 24 | "31,41,51,61,71,81" | 0:05'21'' | 0:00'28'' |
| Q30L60X80P000  | 413.26M |   80.0 | 109589 | 5.06M | 118 |    109589 | 5.04M |  94 |       710 | 16.73K | 24 | "31,41,51,61,71,81" | 0:06'41'' | 0:00'30'' |
| Q30L60X80P001  | 413.26M |   80.0 | 105213 | 5.06M | 122 |    105213 | 5.04M |  97 |       697 | 17.37K | 25 | "31,41,51,61,71,81" | 0:07'39'' | 0:00'29'' |
| Q30L60X120P000 | 619.89M |  120.0 |  93851 |  5.1M | 136 |     93851 | 5.04M | 110 |     38604 | 56.18K | 26 | "31,41,51,61,71,81" | 0:08'49'' | 0:00'31'' |
| Q30L60X160P000 | 826.52M |  160.0 |  88545 |  5.1M | 141 |     88545 | 5.04M | 115 |     38604 | 55.93K | 26 | "31,41,51,61,71,81" | 0:08'33'' | 0:00'34'' |

## Vpar: merge anchors

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

# merge anchors
mkdir -p merge
anchr contained \
    $(
        parallel --no-run-if-empty -k -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
            fi
            " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o merge/anchor.merge0.fasta
anchr contained merge/anchor.merge0.fasta --len 1000 --idt 0.98 \
    --proportion 0.99 --parallel 16 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
mkdir -p merge
anchr contained \
    $(
        parallel --no-run-if-empty -k -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.others.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.others.fa
            fi
            " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o merge/others.merge0.fasta
anchr contained merge/others.merge0.fasta --len 1000 --idt 0.98 \
    --proportion 0.99 --parallel 16 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.merge.fasta

# anchor sort on ref
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

## Vpar: 3GS

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

parallel --no-run-if-empty --linebuffer -k -j 1 "
    echo >&2 '==> Group X{1}-{2}'

    if [ ! -e  3_pacbio/pacbio.X{1}.{2}.fasta ]; then
        echo >&2 '    3_pacbio/pacbio.X{1}.{2}.fasta not exists'
        exit;
    fi

    if [ -e canu-X{1}-{2}/*.contigs.fasta ]; then
        echo >&2 '    contigs.fasta already presents'
        exit;
    fi

    canu \
        -p ${BASE_NAME} -d canu-X{1}-{2} \
        gnuplot=\$(brew --prefix)/Cellar/\$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
        genomeSize=${REAL_G} \
        -pacbio-raw 3_pacbio/pacbio.X{1}.{2}.fasta
    " ::: ${COVERAGE3} ::: raw trim

# canu
printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat3GS.md
printf "|:--|--:|--:|--:|\n" >> stat3GS.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat3GS.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Paralogs"; faops n50 -H -S -C 1_genome/paralogs.fas;) >> stat3GS.md

parallel --no-run-if-empty -k -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo X{1}.{2}.corrected;
            faops n50 -H -S -C \
                canu-X{1}-{2}/${BASE_NAME}.correctedReads.fasta.gz;
        )
    " ::: ${COVERAGE3} ::: raw trim \
    >> stat3GS.md

parallel --no-run-if-empty -k -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo X{1}.{2};
            faops n50 -H -S -C \
                canu-X{1}-{2}/${BASE_NAME}.contigs.fasta;
        )
    " ::: ${COVERAGE3} ::: raw trim \
    >> stat3GS.md

cat stat3GS.md

# minidot
minimap canu-X40-raw/${BASE_NAME}.contigs.fasta 1_genome/genome.fa \
    | minidot - > canu-X40-raw/minidot.eps

minimap canu-X40-trim/${BASE_NAME}.contigs.fasta 1_genome/genome.fa \
    | minidot - > canu-X40-trim/minidot.eps

```

| Name               |     N50 |       Sum |     # |
|:-------------------|--------:|----------:|------:|
| Genome             | 3288558 |   5165770 |     2 |
| Paralogs           |    3333 |    155714 |    62 |
| X40.raw.corrected  |   10645 | 142920341 | 16613 |
| X40.trim.corrected |   10455 | 139373803 | 16359 |
| X80.raw.corrected  |   12302 | 202279213 | 17129 |
| X80.trim.corrected |   11981 | 201858628 | 17420 |
| X40.raw            | 1697538 |   5188544 |     7 |
| X40.trim           | 1697335 |   5182144 |     6 |
| X80.raw            | 3318284 |   5205189 |     2 |
| X80.trim           | 3316838 |   5204553 |     2 |

## Vpar: expand anchors

* anchorLong

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr anchorLong
anchr overlap2 \
    --parallel 16 \
    merge/anchor.merge.fasta \
    canu-X${EXPAND_WITH}-trim/${BASE_NAME}.correctedReads.fasta.gz \
    -d anchorLong \
    -b 50 --len 1000 --idt 0.98 --all

pushd anchorLong

anchr cover \
    --range "1-$(faops n50 -H -N 0 -C anchor.fasta)" \
    --len 1000 --idt 0.98 -c 2 \
    anchorLong.ovlp.tsv \
    -o anchor.cover.json
cat anchor.cover.json | jq "." > environment.json

anchr overlap \
    anchor.fasta \
    --serial --len 30 --idt 0.9999 \
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
    > anchor.ovlp.tsv

rm -fr group
anchr group \
    anchorLong.db \
    anchorLong.ovlp.tsv \
    --oa anchor.ovlp.tsv \
    --parallel 16 \
    --range $(cat environment.json | jq -r '.TRUSTED') \
    --len 1000 --idt 0.98 --max "-30" -c 2

cat group/groups.txt \
    | parallel --no-run-if-empty --linebuffer -k -j 8 '
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

        anchr overlap --len 30 --idt 0.9999 \
            group/{}.strand.fasta \
            -o stdout \
            | perl -nla -e '\''
                @F == 13 or next;
                $F[3] > 0.9999 or next;
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
            -o group/{}.contig.fasta
    '
popd

# false strand
cat anchorLong/group/*.ovlp.tsv \
    | perl -nla -e '/anchor.+long/ or next; print $F[0] if $F[8] == 1;' \
    | sort | uniq -c

cat \
   anchorLong/group/non_grouped.fasta \
   anchorLong/group/*.contig.fasta \
   | faops filter -l 0 -a 1000 stdin anchorLong/contig.fasta

```

* contigTrim

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr contigTrim
anchr overlap2 \
    --parallel 16 \
    anchorLong/contig.fasta \
    canu-X${EXPAND_WITH}-trim/${BASE_NAME}.contigs.fasta \
    -d contigTrim \
    -b 50 --len 1000 --idt 0.995 --all

CONTIG_COUNT=$(faops n50 -H -N 0 -C contigTrim/anchor.fasta)
echo ${CONTIG_COUNT}

rm -fr contigTrim/group
anchr group \
    --parallel 16 \
    --keep \
    contigTrim/anchorLong.db \
    contigTrim/anchorLong.ovlp.tsv \
    --range "1-${CONTIG_COUNT}" --len 1000 --idt 0.995 --max 5000 -c 1

pushd contigTrim
cat group/groups.txt \
    | parallel --no-run-if-empty --linebuffer -k -j 8 '
        echo {};
        anchr orient \
            --len 1000 --idt 0.995 \
            group/{}.anchor.fasta \
            group/{}.long.fasta \
            -r group/{}.restrict.tsv \
            -o group/{}.strand.fasta;

        anchr overlap --len 1000 --idt 0.995 --all \
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

## Vpar: final stats

* Stats

```bash
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
printf "| %s | %s | %s | %s |\n" \
    $(echo "anchorLong"; faops n50 -H -S -C anchorLong/contig.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "contigTrim"; faops n50 -H -S -C contigTrim/contig.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "canu-X${EXPAND_WITH}-raw"; faops n50 -H -S -C canu-X${EXPAND_WITH}-raw/${BASE_NAME}.contigs.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "canu-X${EXPAND_WITH}-trim"; faops n50 -H -S -C canu-X${EXPAND_WITH}-trim/${BASE_NAME}.contigs.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "spades.scaffold"; faops n50 -H -S -C 8_spades/scaffolds.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "spades.non-contained"; faops n50 -H -S -C 8_spades/contigs.non-contained.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "platanus.contig"; faops n50 -H -S -C 8_platanus/out_contig.fa;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "platanus.scaffold"; faops n50 -H -S -C 8_platanus/out_gapClosed.fa;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "platanus.non-contained"; faops n50 -H -S -C 8_platanus/gapClosed.non-contained.fasta;) >> stat3.md

cat stat3.md

```

| Name                   |     N50 |     Sum |    # |
|:-----------------------|--------:|--------:|-----:|
| Genome                 | 3288558 | 5165770 |    2 |
| Paralogs               |    3333 |  155714 |   62 |
| anchor.merge           |  179419 | 5060720 |   72 |
| others.merge           |   38604 |   57145 |    6 |
| anchorLong             |  208183 | 5049448 |   56 |
| contigTrim             | 1017789 | 5090429 |   15 |
| canu-X40-raw           | 1697538 | 5188544 |    7 |
| canu-X40-trim          | 1697335 | 5182144 |    6 |
| spades.scaffold        |  373514 | 6566166 | 3637 |
| spades.non-contained   |  288633 | 5164547 |  125 |
| platanus.contig        |  196706 | 5152580 |  619 |
| platanus.scaffold      |  339534 | 5134547 |  434 |
| platanus.non-contained |  426844 | 5061526 |   34 |

* quast

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr 9_qa_contig
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-X${EXPAND_WITH}-raw/${BASE_NAME}.contigs.fasta \
    canu-X${EXPAND_WITH}-trim/${BASE_NAME}.contigs.fasta \
    8_spades/contigs.non-contained.fasta \
    8_platanus/gapClosed.non-contained.fasta \
    1_genome/paralogs.fas \
    --label "merge,contig,contigTrim,canu-X${EXPAND_WITH}-raw,canu-X${EXPAND_WITH}-trim,spades,platanus,paralogs" \
    -o 9_qa_contig

```

## Vpar: clear intermediate files

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

# bax2bam
rm -fr 3_pacbio/bam/*
rm -fr 3_pacbio/fasta/*
rm -fr 3_pacbio/untar/*

# quorum
find 2_illumina -type f -name "quorum_mer_db.jf" | xargs rm
find 2_illumina -type f -name "k_u_hash_0"       | xargs rm
find 2_illumina -type f -name "*.tmp"            | xargs rm
find 2_illumina -type f -name "pe.renamed.fastq" | xargs rm
find 2_illumina -type f -name "se.renamed.fastq" | xargs rm
find 2_illumina -type f -name "pe.cor.sub.fa"    | xargs rm

# down sampling
rm -fr 2_illumina/Q{20,25,30,35}L{30,60,90,120}X*
rm -fr Q{20,25,30,35}L{30,60,90,120}X*

rm -fr mergeQ*
rm -fr mergeL*

# canu
find . -type d -name "correction" -path "*canu-*" | xargs rm -fr
find . -type d -name "trimming"   -path "*canu-*" | xargs rm -fr
find . -type d -name "unitigging" -path "*canu-*" | xargs rm -fr

# spades
find . -type d -path "*8_spades/*" | xargs rm -fr

# platanus
find . -type f -path "*8_platanus/*" -name "[ps]e.fa" | xargs rm

```

# Legionella pneumophila subsp. pneumophila ATCC 33152D-5; Philadelphia-1, 嗜肺军团菌

Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Lpne: download

* Settings

```bash
BASE_NAME=Lpne
REAL_G=3397754
COVERAGE2="30 40 50 60 80 120 160"
COVERAGE3="40 80"
READ_QUAL="25 30"
READ_LEN="60"
EXPAND_WITH="40"

```

* Reference genome

    * Strain: Legionella pneumophila subsp. pneumophila str. Philadelphia 1
    * Taxid:
      [272624](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=272624&lvl=3&lin=f&keep=1&srchmode=1&unlock)
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

* FastQC

* kmergenie

## Lpne: preprocess Illumina reads

## Lpne: preprocess PacBio reads

## Lpne: reads stats

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 3397754 |    3397754 |        1 |
| Paralogs |    2793 |     100722 |       43 |
| Illumina |     101 | 1060346682 | 10498482 |
| uniq     |     101 | 1056283452 | 10458252 |
| Q25L60   |     101 |  908681802 |  9124858 |
| Q30L60   |     101 |  833644744 |  8594286 |
| PacBio   |    8538 |  287320468 |    56763 |
| X40.raw  |    8671 |  135913310 |    26008 |
| X40.trim |    8378 |  114584028 |    18809 |
| X80.raw  |    8542 |  271822256 |    53600 |
| X80.trim |    8354 |  232880224 |    39020 |

## Lpne: spades

## Lpne: platanus

## Lpne: quorum

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 | 908.68M | 267.4 | 838.31M |  246.7 |   7.745% |      99 | "71" |  3.4M | 3.43M |     1.01 | 0:03'39'' |
| Q30L60 | 834.32M | 245.6 | 781.86M |  230.1 |   6.288% |      97 | "71" |  3.4M | 3.42M |     1.01 | 0:03'48'' |

## Lpne: down sampling

## Lpne: k-unitigs and anchors (sampled)

| Name           | SumCor  | CovCor |  N50SR |   Sum |   # | N50Anchor |   Sum |   # | N50Others |     Sum |  # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|:--------|-------:|-------:|------:|----:|----------:|------:|----:|----------:|--------:|---:|--------------------:|----------:|----------:|
| Q25L60X30P000  | 101.93M |   30.0 |  67703 | 3.41M | 124 |     69995 | 3.35M |  82 |      1857 |  58.47K | 42 | "31,41,51,61,71,81" | 0:02'50'' | 0:00'20'' |
| Q25L60X30P001  | 101.93M |   30.0 |  68106 |  3.4M | 113 |     68106 | 3.37M |  82 |       793 |  24.79K | 31 | "31,41,51,61,71,81" | 0:02'49'' | 0:00'21'' |
| Q25L60X30P002  | 101.93M |   30.0 |  88700 |  3.4M | 112 |     88700 | 3.36M |  82 |      1857 |  42.43K | 30 | "31,41,51,61,71,81" | 0:01'53'' | 0:00'21'' |
| Q25L60X30P003  | 101.93M |   30.0 |  78358 | 3.41M | 114 |     78358 | 3.35M |  74 |      3690 |  60.82K | 40 | "31,41,51,61,71,81" | 0:01'59'' | 0:00'21'' |
| Q25L60X30P004  | 101.93M |   30.0 |  88066 | 3.41M | 110 |     88066 | 3.35M |  72 |      3690 |  62.59K | 38 | "31,41,51,61,71,81" | 0:01'29'' | 0:00'20'' |
| Q25L60X30P005  | 101.93M |   30.0 |  96175 |  3.4M | 100 |     96175 | 3.36M |  69 |      1443 |  39.46K | 31 | "31,41,51,61,71,81" | 0:01'33'' | 0:00'20'' |
| Q25L60X30P006  | 101.93M |   30.0 |  90727 | 3.44M | 107 |     90727 | 3.34M |  72 |     18406 |  91.07K | 35 | "31,41,51,61,71,81" | 0:01'26'' | 0:00'19'' |
| Q25L60X30P007  | 101.93M |   30.0 |  80965 |  3.4M | 103 |     81351 | 3.33M |  69 |     20097 |   71.9K | 34 | "31,41,51,61,71,81" | 0:01'26'' | 0:00'20'' |
| Q25L60X40P000  | 135.91M |   40.0 |  74009 | 3.42M | 131 |     74009 | 3.35M |  82 |      1407 |   67.5K | 49 | "31,41,51,61,71,81" | 0:01'43'' | 0:00'20'' |
| Q25L60X40P001  | 135.91M |   40.0 |  77457 | 3.39M | 108 |     79418 | 3.36M |  75 |       853 |  29.06K | 33 | "31,41,51,61,71,81" | 0:01'42'' | 0:00'21'' |
| Q25L60X40P002  | 135.91M |   40.0 |  88927 | 3.41M | 110 |     88927 | 3.36M |  69 |      1151 |  50.56K | 41 | "31,41,51,61,71,81" | 0:01'42'' | 0:00'22'' |
| Q25L60X40P003  | 135.91M |   40.0 |  93788 | 3.42M | 113 |     96726 | 3.34M |  72 |     20097 |  79.36K | 41 | "31,41,51,61,71,81" | 0:01'41'' | 0:00'21'' |
| Q25L60X40P004  | 135.91M |   40.0 |  96181 | 3.51M | 106 |     93788 | 3.24M |  74 |    122878 | 274.18K | 32 | "31,41,51,61,71,81" | 0:01'53'' | 0:00'20'' |
| Q25L60X40P005  | 135.91M |   40.0 |  77117 | 3.41M | 104 |     77117 | 3.36M |  69 |      1776 |   53.4K | 35 | "31,41,51,61,71,81" | 0:01'51'' | 0:00'21'' |
| Q25L60X50P000  | 169.89M |   50.0 |  66794 | 3.46M | 137 |     67589 | 3.36M |  94 |     59532 | 101.83K | 43 | "31,41,51,61,71,81" | 0:01'53'' | 0:00'21'' |
| Q25L60X50P001  | 169.89M |   50.0 |  64882 | 3.41M | 131 |     64882 | 3.36M |  86 |      1179 |  53.93K | 45 | "31,41,51,61,71,81" | 0:01'53'' | 0:00'21'' |
| Q25L60X50P002  | 169.89M |   50.0 |  78869 | 3.42M | 132 |     78869 | 3.36M |  85 |      1707 |  68.17K | 47 | "31,41,51,61,71,81" | 0:01'51'' | 0:00'21'' |
| Q25L60X50P003  | 169.89M |   50.0 |  72719 | 3.41M | 117 |     72719 | 3.36M |  85 |      1776 |  48.89K | 32 | "31,41,51,61,71,81" | 0:01'56'' | 0:00'21'' |
| Q25L60X60P000  | 203.87M |   60.0 |  63364 |  3.4M | 143 |     63364 | 3.36M | 104 |      1543 |  44.92K | 39 | "31,41,51,61,71,81" | 0:02'13'' | 0:00'23'' |
| Q25L60X60P001  | 203.87M |   60.0 |  72930 | 3.42M | 137 |     88927 | 3.36M |  93 |      1490 |  58.23K | 44 | "31,41,51,61,71,81" | 0:02'01'' | 0:00'22'' |
| Q25L60X60P002  | 203.87M |   60.0 |  62921 | 3.43M | 134 |     72524 | 3.33M |  89 |      9602 |     91K | 45 | "31,41,51,61,71,81" | 0:02'09'' | 0:00'23'' |
| Q25L60X60P003  | 203.87M |   60.0 |  69423 | 3.43M | 119 |     69423 | 3.36M |  87 |      5545 |  70.74K | 32 | "31,41,51,61,71,81" | 0:02'11'' | 0:00'23'' |
| Q25L60X80P000  | 271.82M |   80.0 |  49306 | 3.41M | 168 |     49390 | 3.36M | 130 |      1647 |  49.38K | 38 | "31,41,51,61,71,81" | 0:02'35'' | 0:00'23'' |
| Q25L60X80P001  | 271.82M |   80.0 |  52778 | 3.43M | 159 |     54316 | 3.34M | 115 |      8132 |  95.51K | 44 | "31,41,51,61,71,81" | 0:02'39'' | 0:00'23'' |
| Q25L60X80P002  | 271.82M |   80.0 |  49142 | 3.42M | 149 |     49142 | 3.36M | 119 |      5944 |  63.19K | 30 | "31,41,51,61,71,81" | 0:02'46'' | 0:00'24'' |
| Q25L60X120P000 | 407.73M |  120.0 |  31476 | 3.41M | 226 |     31476 | 3.36M | 185 |      1270 |  55.82K | 41 | "31,41,51,61,71,81" | 0:02'58'' | 0:00'26'' |
| Q25L60X120P001 | 407.73M |  120.0 |  30286 | 3.42M | 202 |     30531 | 3.34M | 172 |     13202 |  85.29K | 30 | "31,41,51,61,71,81" | 0:03'30'' | 0:00'26'' |
| Q25L60X160P000 | 543.64M |  160.0 |  23309 | 3.42M | 281 |     24110 | 3.36M | 240 |      1548 |   58.6K | 41 | "31,41,51,61,71,81" | 0:03'49'' | 0:00'26'' |
| Q30L60X30P000  | 101.93M |   30.0 |  96018 | 3.39M |  99 |     96018 | 3.35M |  63 |       821 |  32.04K | 36 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'21'' |
| Q30L60X30P001  | 101.93M |   30.0 | 132422 | 3.46M |  93 |    132422 | 3.43M |  62 |       949 |  28.37K | 31 | "31,41,51,61,71,81" | 0:01'17'' | 0:00'21'' |
| Q30L60X30P002  | 101.93M |   30.0 |  96152 |  3.4M |  90 |     96152 | 3.35M |  60 |      3690 |   47.6K | 30 | "31,41,51,61,71,81" | 0:01'17'' | 0:00'21'' |
| Q30L60X30P003  | 101.93M |   30.0 | 145243 | 3.39M |  91 |    145243 | 3.36M |  60 |      1053 |  33.66K | 31 | "31,41,51,61,71,81" | 0:01'21'' | 0:00'21'' |
| Q30L60X30P004  | 101.93M |   30.0 | 119863 |  3.4M |  89 |    119863 | 3.35M |  54 |      1647 |  49.24K | 35 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'20'' |
| Q30L60X30P005  | 101.93M |   30.0 | 119853 |  3.4M |  95 |    122888 | 3.36M |  59 |      1067 |  40.84K | 36 | "31,41,51,61,71,81" | 0:01'34'' | 0:00'20'' |
| Q30L60X30P006  | 101.93M |   30.0 | 111170 |  3.4M |  91 |    116168 | 3.36M |  60 |      1647 |  44.47K | 31 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'20'' |
| Q30L60X40P000  | 135.91M |   40.0 | 132985 | 3.39M | 101 |    132985 | 3.36M |  62 |       809 |  32.35K | 39 | "31,41,51,61,71,81" | 0:01'33'' | 0:00'20'' |
| Q30L60X40P001  | 135.91M |   40.0 | 142168 | 3.39M |  96 |    142168 | 3.36M |  57 |       801 |  35.08K | 39 | "31,41,51,61,71,81" | 0:01'32'' | 0:00'21'' |
| Q30L60X40P002  | 135.91M |   40.0 | 100398 | 3.41M |  93 |    132382 | 3.36M |  58 |      1370 |  48.04K | 35 | "31,41,51,61,71,81" | 0:01'34'' | 0:00'21'' |
| Q30L60X40P003  | 135.91M |   40.0 | 111065 |  3.4M |  85 |    122908 | 3.36M |  56 |      1179 |  39.95K | 29 | "31,41,51,61,71,81" | 0:01'34'' | 0:00'21'' |
| Q30L60X40P004  | 135.91M |   40.0 | 119873 | 3.41M |  88 |    119873 | 3.36M |  55 |      1822 |  52.26K | 33 | "31,41,51,61,71,81" | 0:01'38'' | 0:00'22'' |
| Q30L60X50P000  | 169.89M |   50.0 | 132985 | 3.48M |  95 |    142178 | 3.23M |  59 |    126407 |  242.2K | 36 | "31,41,51,61,71,81" | 0:01'54'' | 0:00'22'' |
| Q30L60X50P001  | 169.89M |   50.0 | 120743 | 3.39M | 102 |    120743 | 3.36M |  60 |       791 |  33.01K | 42 | "31,41,51,61,71,81" | 0:01'43'' | 0:00'22'' |
| Q30L60X50P002  | 169.89M |   50.0 | 119863 | 3.39M |  92 |    119863 | 3.36M |  58 |      1075 |  33.55K | 34 | "31,41,51,61,71,81" | 0:01'52'' | 0:00'21'' |
| Q30L60X50P003  | 169.89M |   50.0 | 119873 | 3.42M |  94 |    119873 | 3.36M |  61 |      3478 |   58.4K | 33 | "31,41,51,61,71,81" | 0:01'44'' | 0:00'21'' |
| Q30L60X60P000  | 203.87M |   60.0 | 132985 | 3.48M |  94 |    142178 | 3.23M |  63 |    126417 |  244.1K | 31 | "31,41,51,61,71,81" | 0:01'56'' | 0:00'22'' |
| Q30L60X60P001  | 203.87M |   60.0 | 116204 | 3.44M |  96 |    120743 | 3.36M |  60 |     43044 |  79.42K | 36 | "31,41,51,61,71,81" | 0:01'58'' | 0:00'22'' |
| Q30L60X60P002  | 203.87M |   60.0 | 103673 | 3.41M |  95 |    103673 | 3.36M |  64 |      1776 |  52.28K | 31 | "31,41,51,61,71,81" | 0:02'14'' | 0:00'22'' |
| Q30L60X80P000  | 271.82M |   80.0 | 120743 |  3.4M | 100 |    120743 | 3.36M |  67 |      2403 |   43.3K | 33 | "31,41,51,61,71,81" | 0:02'25'' | 0:00'23'' |
| Q30L60X80P001  | 271.82M |   80.0 |  91387 |  3.4M | 102 |     91387 | 3.36M |  69 |      1693 |  45.04K | 33 | "31,41,51,61,71,81" | 0:02'13'' | 0:00'24'' |
| Q30L60X120P000 | 407.73M |  120.0 |  97997 |  3.4M | 106 |     97997 | 3.36M |  81 |      3127 |  44.37K | 25 | "31,41,51,61,71,81" | 0:02'52'' | 0:00'26'' |
| Q30L60X160P000 | 543.64M |  160.0 |  66338 | 3.42M | 124 |     68045 | 3.34M |  95 |     13202 |  78.43K | 29 | "31,41,51,61,71,81" | 0:02'45'' | 0:00'26'' |

## Lpne: merge anchors

## Lpne: 3GS

## Lpne: expand anchors

* anchorLong

* contigTrim

## Lpne: final stats

* Stats

| Name                   |     N50 |     Sum |   # |
|:-----------------------|--------:|--------:|----:|
| Genome                 | 3397754 | 3397754 |   1 |
| Paralogs               |    2793 |  100722 |  43 |
| anchor.merge           |  248594 | 3578721 |  40 |
| others.merge           |  252824 |  491718 |  27 |
| anchorLong             |  261851 | 3573909 |  34 |
| contigTrim             |  479159 | 1666557 |   5 |
| canu-X40-raw           | 3415718 | 3415718 |   1 |
| canu-X40-trim          | 3393633 | 3393633 |   1 |
| spades.scaffold        |  431777 | 3485527 | 292 |
| spades.non-contained   |  431777 | 3408065 |  28 |
| platanus.contig        |  198660 | 3392691 | 209 |
| platanus.scaffold      |  363087 | 3385711 | 144 |
| platanus.non-contained |  363087 | 3364434 |  22 |

* quast

## Lpne: clear intermediate files

# Neisseria gonorrhoeae FDAARGOS_207, 淋病奈瑟氏菌

Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Ngon: download

* Settings

```bash
BASE_NAME=Ngon
REAL_G=2153922
COVERAGE2="30 40 50 60 80 120 160"
COVERAGE3="40 80"
READ_QUAL="25 30"
READ_LEN="60"
EXPAND_WITH="40"

```

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

## Ngon: preprocess Illumina reads

## Ngon: preprocess PacBio reads

## Ngon: reads stats

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 2153922 |    2153922 |        1 |
| Paralogs |    4318 |     142093 |       53 |
| Illumina |     101 | 1491583958 | 14768158 |
| uniq     |     101 | 1485449016 | 14707416 |
| scythe   |     101 | 1460356291 | 14707416 |
| Q25L60   |     101 | 1062429395 | 10873960 |
| Q30L60   |     101 |  884852448 |  9519518 |
| PacBio   |   11808 | 1187845820 |   137516 |
| X40.raw  |   11588 |   86161380 |    10392 |
| X40.trim |   10011 |   68381718 |     8716 |
| X80.raw  |   11668 |  172317459 |    20331 |
| X80.trim |    9976 |  136791162 |    17440 |

## Ngon: spades

## Ngon: platanus

## Ngon: quorum

| Name   |  SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|-------:|------:|--------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 |  1.06G | 493.3 | 978.44M |  454.3 |   7.905% |      97 | "51" | 2.15M | 2.28M |     1.06 | 0:03'52'' |
| Q30L60 | 886.6M | 411.6 | 831.03M |  385.8 |   6.267% |      93 | "61" | 2.15M |  2.1M |     0.97 | 0:02'59'' |

## Ngon: down sampling

## Ngon: k-unitigs and anchors (sampled)

| Name           |  SumCor | CovCor | N50SR |   Sum |   # | N50Anchor |   Sum |   # | N50Others |     Sum |   # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|--------:|-------:|------:|------:|----:|----------:|------:|----:|----------:|--------:|----:|--------------------:|----------:|:----------|
| Q25L60X30P000  |  64.62M |   30.0 | 10938 | 2.06M | 354 |     11468 | 1.99M | 263 |       840 |     75K |  91 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'15'' |
| Q25L60X30P001  |  64.62M |   30.0 | 11719 | 2.06M | 340 |     12019 | 1.99M | 257 |       848 |  69.95K |  83 | "31,41,51,61,71,81" | 0:01'04'' | 0:00'16'' |
| Q25L60X30P002  |  64.62M |   30.0 | 10986 | 2.06M | 345 |     12249 | 1.99M | 268 |       858 |  66.57K |  77 | "31,41,51,61,71,81" | 0:01'04'' | 0:00'16'' |
| Q25L60X30P003  |  64.62M |   30.0 | 11641 | 2.06M | 355 |     12387 | 1.99M | 268 |       864 |   74.8K |  87 | "31,41,51,61,71,81" | 0:01'04'' | 0:00'16'' |
| Q25L60X30P004  |  64.62M |   30.0 | 10911 | 2.06M | 339 |     11152 | 1.99M | 260 |       849 |  70.49K |  79 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'16'' |
| Q25L60X30P005  |  64.62M |   30.0 | 11981 | 2.06M | 328 |     12140 | 1.99M | 251 |       862 |  67.84K |  77 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'15'' |
| Q25L60X30P006  |  64.62M |   30.0 | 14255 | 2.05M | 281 |     14396 | 1.99M | 218 |       858 |  57.54K |  63 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'15'' |
| Q25L60X30P007  |  64.62M |   30.0 | 14810 | 2.05M | 297 |     15152 | 1.99M | 222 |       869 |  67.28K |  75 | "31,41,51,61,71,81" | 0:00'59'' | 0:00'15'' |
| Q25L60X30P008  |  64.62M |   30.0 | 12381 | 2.06M | 309 |     12544 | 1.99M | 231 |       789 |  64.88K |  78 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'16'' |
| Q25L60X30P009  |  64.62M |   30.0 | 12979 | 2.06M | 300 |     13375 | 1.99M | 227 |       880 |  68.45K |  73 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'14'' |
| Q25L60X30P010  |  64.62M |   30.0 | 14533 | 2.05M | 281 |     14790 | 1.98M | 212 |       864 |  62.29K |  69 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'16'' |
| Q25L60X30P011  |  64.62M |   30.0 | 13980 | 2.05M | 276 |     14526 | 1.99M | 220 |       897 |  53.77K |  56 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'15'' |
| Q25L60X30P012  |  64.62M |   30.0 | 13710 | 2.05M | 274 |     13811 | 1.99M | 211 |       891 |  57.98K |  63 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'16'' |
| Q25L60X30P013  |  64.62M |   30.0 | 15339 | 2.05M | 274 |     15451 | 1.99M | 209 |       897 |  60.37K |  65 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'14'' |
| Q25L60X30P014  |  64.62M |   30.0 | 13982 | 2.05M | 269 |     14270 | 1.99M | 212 |       890 |  53.72K |  57 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'15'' |
| Q25L60X40P000  |  86.16M |   40.0 | 10390 | 2.06M | 365 |     10809 |    2M | 283 |       831 |  66.58K |  82 | "31,41,51,61,71,81" | 0:01'02'' | 0:00'16'' |
| Q25L60X40P001  |  86.16M |   40.0 | 11719 | 2.06M | 350 |     12394 | 1.98M | 261 |       841 |  72.26K |  89 | "31,41,51,61,71,81" | 0:01'04'' | 0:00'16'' |
| Q25L60X40P002  |  86.16M |   40.0 | 11736 | 2.06M | 352 |     12253 | 1.99M | 272 |       771 |  63.67K |  80 | "31,41,51,61,71,81" | 0:01'04'' | 0:00'16'' |
| Q25L60X40P003  |  86.16M |   40.0 | 10780 | 2.05M | 327 |     11531 | 1.99M | 261 |       852 |  59.24K |  66 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'16'' |
| Q25L60X40P004  |  86.16M |   40.0 | 12940 | 2.05M | 295 |     13106 | 1.98M | 229 |       880 |  61.75K |  66 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'16'' |
| Q25L60X40P005  |  86.16M |   40.0 | 14105 | 2.05M | 315 |     14250 | 1.99M | 235 |       856 |  69.32K |  80 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'16'' |
| Q25L60X40P006  |  86.16M |   40.0 | 12585 | 2.05M | 301 |     13012 | 1.99M | 233 |       849 |  56.88K |  68 | "31,41,51,61,71,81" | 0:00'59'' | 0:00'15'' |
| Q25L60X40P007  |  86.16M |   40.0 | 12630 | 2.05M | 308 |     13210 | 1.99M | 234 |       880 |  65.46K |  74 | "31,41,51,61,71,81" | 0:01'04'' | 0:00'16'' |
| Q25L60X40P008  |  86.16M |   40.0 | 13653 | 2.04M | 287 |     13821 | 1.99M | 231 |       932 |  52.64K |  56 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'16'' |
| Q25L60X40P009  |  86.16M |   40.0 | 14200 | 2.04M | 275 |     14226 | 1.99M | 213 |       897 |  55.53K |  62 | "31,41,51,61,71,81" | 0:01'05'' | 0:00'16'' |
| Q25L60X40P010  |  86.16M |   40.0 | 13710 | 2.05M | 279 |     13982 | 1.99M | 219 |      1194 |  63.94K |  60 | "31,41,51,61,71,81" | 0:01'04'' | 0:00'16'' |
| Q25L60X50P000  |  107.7M |   50.0 | 10225 | 2.06M | 364 |     10393 | 1.99M | 283 |       831 |  66.61K |  81 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'16'' |
| Q25L60X50P001  |  107.7M |   50.0 |  9987 | 2.06M | 368 |     10212 |    2M | 293 |       849 |  61.49K |  75 | "31,41,51,61,71,81" | 0:01'09'' | 0:00'17'' |
| Q25L60X50P002  |  107.7M |   50.0 | 10221 | 2.05M | 367 |     10463 | 1.99M | 289 |       792 |  63.44K |  78 | "31,41,51,61,71,81" | 0:01'21'' | 0:00'16'' |
| Q25L60X50P003  |  107.7M |   50.0 | 11981 | 2.04M | 328 |     12093 | 1.99M | 258 |       839 |  59.25K |  70 | "31,41,51,61,71,81" | 0:01'20'' | 0:00'16'' |
| Q25L60X50P004  |  107.7M |   50.0 | 13380 | 2.05M | 313 |     13664 | 1.98M | 236 |       858 |  66.56K |  77 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'15'' |
| Q25L60X50P005  |  107.7M |   50.0 | 12383 | 2.05M | 323 |     12534 | 1.99M | 245 |       854 |  61.99K |  78 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'17'' |
| Q25L60X50P006  |  107.7M |   50.0 | 12034 | 2.04M | 315 |     12398 | 1.98M | 249 |       909 |  60.84K |  66 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'15'' |
| Q25L60X50P007  |  107.7M |   50.0 | 13114 | 2.04M | 295 |     13651 | 1.99M | 235 |       864 |  51.37K |  60 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'15'' |
| Q25L60X50P008  |  107.7M |   50.0 | 12924 | 2.04M | 290 |     13071 |    2M | 239 |       897 |  46.75K |  51 | "31,41,51,61,71,81" | 0:01'16'' | 0:00'16'' |
| Q25L60X60P000  | 129.24M |   60.0 |  9391 | 2.05M | 396 |      9669 | 1.98M | 313 |       769 |  65.25K |  83 | "31,41,51,61,71,81" | 0:01'15'' | 0:00'17'' |
| Q25L60X60P001  | 129.24M |   60.0 |  8663 | 2.05M | 411 |      8788 | 1.99M | 332 |       799 |  62.57K |  79 | "31,41,51,61,71,81" | 0:01'21'' | 0:00'16'' |
| Q25L60X60P002  | 129.24M |   60.0 |  9312 | 2.05M | 376 |      9442 | 1.99M | 299 |       832 |  64.05K |  77 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'17'' |
| Q25L60X60P003  | 129.24M |   60.0 | 10809 | 2.05M | 355 |     11622 | 1.98M | 272 |       850 |  68.91K |  83 | "31,41,51,61,71,81" | 0:01'28'' | 0:00'16'' |
| Q25L60X60P004  | 129.24M |   60.0 | 10816 | 2.05M | 353 |     10953 | 1.98M | 269 |       799 |  64.45K |  84 | "31,41,51,61,71,81" | 0:01'26'' | 0:00'17'' |
| Q25L60X60P005  | 129.24M |   60.0 | 10662 | 2.04M | 340 |     11074 | 1.98M | 270 |       909 |  63.04K |  70 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'17'' |
| Q25L60X60P006  | 129.24M |   60.0 | 10996 | 2.05M | 343 |     11607 | 1.99M | 278 |       850 |   56.5K |  65 | "31,41,51,61,71,81" | 0:01'20'' | 0:00'17'' |
| Q25L60X80P000  | 172.31M |   80.0 |  6915 | 2.04M | 480 |      7242 | 1.97M | 387 |       752 |  69.46K |  93 | "31,41,51,61,71,81" | 0:01'36'' | 0:00'18'' |
| Q25L60X80P001  | 172.31M |   80.0 |  6855 | 2.05M | 491 |      7154 | 1.98M | 396 |       750 |  72.54K |  95 | "31,41,51,61,71,81" | 0:01'34'' | 0:00'17'' |
| Q25L60X80P002  | 172.31M |   80.0 |  8119 | 2.05M | 434 |      8349 | 1.97M | 337 |       832 |  75.54K |  97 | "31,41,51,61,71,81" | 0:01'40'' | 0:00'18'' |
| Q25L60X80P003  | 172.31M |   80.0 |  8816 | 2.05M | 411 |      9097 | 1.97M | 316 |       810 |  72.64K |  95 | "31,41,51,61,71,81" | 0:01'37'' | 0:00'18'' |
| Q25L60X80P004  | 172.31M |   80.0 |  8790 | 2.04M | 406 |      9279 | 1.98M | 328 |       850 |  64.48K |  78 | "31,41,51,61,71,81" | 0:01'49'' | 0:00'18'' |
| Q25L60X120P000 | 258.47M |  120.0 |  4368 | 2.04M | 691 |      4574 | 1.93M | 543 |       753 | 108.52K | 148 | "31,41,51,61,71,81" | 0:02'04'' | 0:00'19'' |
| Q25L60X120P001 | 258.47M |  120.0 |  4816 | 2.04M | 623 |      5078 | 1.94M | 478 |       803 | 109.01K | 145 | "31,41,51,61,71,81" | 0:02'06'' | 0:00'20'' |
| Q25L60X120P002 | 258.47M |  120.0 |  5575 | 2.04M | 570 |      5820 | 1.95M | 447 |       797 |  93.83K | 123 | "31,41,51,61,71,81" | 0:01'59'' | 0:00'21'' |
| Q25L60X160P000 | 344.63M |  160.0 |  3236 | 2.03M | 881 |      3440 | 1.86M | 651 |       759 | 166.94K | 230 | "31,41,51,61,71,81" | 0:02'35'' | 0:00'19'' |
| Q25L60X160P001 | 344.63M |  160.0 |  3771 | 2.04M | 751 |      4196 |  1.9M | 564 |       798 | 140.63K | 187 | "31,41,51,61,71,81" | 0:02'34'' | 0:00'21'' |
| Q30L60X30P000  |  64.62M |   30.0 | 13142 | 2.04M | 296 |     14001 | 1.97M | 221 |       853 |  69.89K |  75 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'15'' |
| Q30L60X30P001  |  64.62M |   30.0 | 13347 | 2.05M | 304 |     13570 | 1.98M | 234 |       947 |  70.99K |  70 | "31,41,51,61,71,81" | 0:01'02'' | 0:00'16'' |
| Q30L60X30P002  |  64.62M |   30.0 | 13821 | 2.05M | 304 |     14216 | 1.98M | 231 |       864 |  67.63K |  73 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'14'' |
| Q30L60X30P003  |  64.62M |   30.0 | 13509 | 2.04M | 278 |     13967 | 1.98M | 215 |       858 |  60.35K |  63 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'14'' |
| Q30L60X30P004  |  64.62M |   30.0 | 17673 | 2.05M | 266 |     18198 | 1.98M | 192 |       864 |  66.56K |  74 | "31,41,51,61,71,81" | 0:01'00'' | 0:00'14'' |
| Q30L60X30P005  |  64.62M |   30.0 | 14648 | 2.05M | 273 |     15920 | 1.98M | 200 |       861 |  65.93K |  73 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'16'' |
| Q30L60X30P006  |  64.62M |   30.0 | 14903 | 2.06M | 272 |     15406 | 1.99M | 201 |       850 |  68.86K |  71 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'17'' |
| Q30L60X30P007  |  64.62M |   30.0 | 16937 | 2.05M | 271 |     17397 | 1.98M | 197 |       889 |   68.6K |  74 | "31,41,51,61,71,81" | 0:00'56'' | 0:00'15'' |
| Q30L60X30P008  |  64.62M |   30.0 | 18463 | 2.04M | 247 |     18571 | 1.98M | 187 |       909 |  60.25K |  60 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'16'' |
| Q30L60X30P009  |  64.62M |   30.0 | 18493 | 2.05M | 250 |     18581 | 1.99M | 183 |       881 |  67.71K |  67 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'16'' |
| Q30L60X30P010  |  64.62M |   30.0 | 16203 | 2.05M | 269 |     16541 | 1.99M | 205 |       839 |  59.07K |  64 | "31,41,51,61,71,81" | 0:01'01'' | 0:00'15'' |
| Q30L60X30P011  |  64.62M |   30.0 |  7799 | 2.05M | 428 |      8033 | 1.96M | 321 |       768 |  87.64K | 107 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'14'' |
| Q30L60X40P000  |  86.16M |   40.0 | 14479 | 2.05M | 272 |     15210 | 1.98M | 202 |       868 |  66.51K |  70 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'15'' |
| Q30L60X40P001  |  86.16M |   40.0 | 15012 | 2.05M | 271 |     15963 | 1.99M | 207 |       864 |  59.23K |  64 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'15'' |
| Q30L60X40P002  |  86.16M |   40.0 | 15945 | 2.04M | 259 |     16260 | 1.99M | 199 |       864 |  57.34K |  60 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'14'' |
| Q30L60X40P003  |  86.16M |   40.0 | 18199 | 2.05M | 245 |     18538 | 1.98M | 174 |       897 |  65.17K |  71 | "31,41,51,61,71,81" | 0:01'08'' | 0:00'15'' |
| Q30L60X40P004  |  86.16M |   40.0 | 15406 | 2.05M | 262 |     15963 | 1.99M | 190 |       868 |  64.05K |  72 | "31,41,51,61,71,81" | 0:01'09'' | 0:00'15'' |
| Q30L60X40P005  |  86.16M |   40.0 | 16937 | 2.04M | 247 |     18313 | 1.99M | 184 |       852 |   58.4K |  63 | "31,41,51,61,71,81" | 0:01'09'' | 0:00'16'' |
| Q30L60X40P006  |  86.16M |   40.0 | 18014 | 2.04M | 235 |     18483 | 1.99M | 179 |       909 |  54.93K |  56 | "31,41,51,61,71,81" | 0:01'02'' | 0:00'15'' |
| Q30L60X40P007  |  86.16M |   40.0 | 17484 | 2.04M | 239 |     18004 | 1.99M | 181 |       895 |  54.42K |  58 | "31,41,51,61,71,81" | 0:01'04'' | 0:00'15'' |
| Q30L60X40P008  |  86.16M |   40.0 | 10521 | 2.05M | 368 |     10854 | 1.97M | 278 |       843 |   78.3K |  90 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'15'' |
| Q30L60X50P000  |  107.7M |   50.0 | 15969 | 2.05M | 259 |     16223 | 1.98M | 193 |      1000 |  68.47K |  66 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'16'' |
| Q30L60X50P001  |  107.7M |   50.0 | 17994 | 2.05M | 244 |     18518 | 1.99M | 187 |       901 |  57.01K |  57 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'16'' |
| Q30L60X50P002  |  107.7M |   50.0 | 18493 | 2.04M | 241 |     18528 | 1.99M | 174 |       844 |  59.12K |  67 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'15'' |
| Q30L60X50P003  |  107.7M |   50.0 | 15963 | 2.05M | 254 |     16260 |    2M | 187 |       849 |  57.73K |  67 | "31,41,51,61,71,81" | 0:01'04'' | 0:00'16'' |
| Q30L60X50P004  |  107.7M |   50.0 | 18493 | 2.04M | 233 |     18591 | 1.99M | 174 |       897 |  56.88K |  59 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'16'' |
| Q30L60X50P005  |  107.7M |   50.0 | 18528 | 2.05M | 228 |     18581 |    2M | 173 |       899 |  52.89K |  55 | "31,41,51,61,71,81" | 0:01'05'' | 0:00'15'' |
| Q30L60X50P006  |  107.7M |   50.0 | 16157 | 2.05M | 255 |     16223 | 1.99M | 197 |       856 |  54.43K |  58 | "31,41,51,61,71,81" | 0:01'02'' | 0:00'16'' |
| Q30L60X60P000  | 129.24M |   60.0 | 16260 | 2.05M | 246 |     16652 | 1.98M | 184 |       971 |  64.44K |  62 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'16'' |
| Q30L60X60P001  | 129.24M |   60.0 | 18014 | 2.04M | 243 |     18217 | 1.99M | 187 |       878 |  52.31K |  56 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'15'' |
| Q30L60X60P002  | 129.24M |   60.0 | 18014 | 2.04M | 234 |     18493 | 1.99M | 172 |       901 |  57.34K |  62 | "31,41,51,61,71,81" | 0:01'15'' | 0:00'16'' |
| Q30L60X60P003  | 129.24M |   60.0 | 18142 | 2.05M | 237 |     18313 | 1.99M | 176 |       892 |  60.41K |  61 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'16'' |
| Q30L60X60P004  | 129.24M |   60.0 | 19022 | 2.05M | 228 |     19519 |    2M | 171 |       901 |  54.18K |  57 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'16'' |
| Q30L60X60P005  | 129.24M |   60.0 | 16159 | 2.05M | 251 |     16260 | 1.99M | 191 |       849 |  55.57K |  60 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'17'' |
| Q30L60X80P000  | 172.31M |   80.0 | 16804 | 2.04M | 246 |     16937 | 1.99M | 185 |       872 |  55.13K |  61 | "31,41,51,61,71,81" | 0:01'28'' | 0:00'17'' |
| Q30L60X80P001  | 172.31M |   80.0 | 18014 | 2.04M | 244 |     18538 | 1.99M | 182 |       850 |  54.75K |  62 | "31,41,51,61,71,81" | 0:01'29'' | 0:00'17'' |
| Q30L60X80P002  | 172.31M |   80.0 | 16831 | 2.04M | 249 |     16896 | 1.99M | 187 |       849 |  53.11K |  62 | "31,41,51,61,71,81" | 0:01'29'' | 0:00'17'' |
| Q30L60X80P003  | 172.31M |   80.0 | 18538 | 2.04M | 233 |     18581 | 1.99M | 174 |       876 |  52.27K |  59 | "31,41,51,61,71,81" | 0:01'27'' | 0:00'17'' |
| Q30L60X120P000 | 258.47M |  120.0 | 16223 | 2.04M | 258 |     16513 | 1.99M | 197 |       832 |   53.4K |  61 | "31,41,51,61,71,81" | 0:01'54'' | 0:00'18'' |
| Q30L60X120P001 | 258.47M |  120.0 | 15018 | 2.04M | 261 |     15804 | 1.99M | 201 |       850 |  50.85K |  60 | "31,41,51,61,71,81" | 0:01'56'' | 0:00'19'' |
| Q30L60X120P002 | 258.47M |  120.0 | 16223 | 2.04M | 249 |     16684 | 1.99M | 190 |       850 |  49.89K |  59 | "31,41,51,61,71,81" | 0:01'55'' | 0:00'18'' |
| Q30L60X160P000 | 344.63M |  160.0 | 13972 | 2.04M | 284 |     15012 | 1.98M | 215 |       809 |  55.32K |  69 | "31,41,51,61,71,81" | 0:02'08'' | 0:00'18'' |
| Q30L60X160P001 | 344.63M |  160.0 | 13710 | 2.04M | 300 |     13913 | 1.99M | 230 |       769 |  54.07K |  70 | "31,41,51,61,71,81" | 0:01'31'' | 0:00'20'' |

## Ngon: merge anchors

## Ngon: 3GS

| Name               |     N50 |      Sum |    # |
|:-------------------|--------:|---------:|-----:|
| Genome             | 2153922 |  2153922 |    1 |
| Paralogs           |    4318 |   142093 |   53 |
| X40.raw.corrected  |    9847 | 55682989 | 7133 |
| X40.trim.corrected |    9713 | 54697518 | 7101 |
| X80.raw.corrected  |   10551 | 81435212 | 8177 |
| X80.trim.corrected |   10333 | 81378927 | 8342 |
| X40.raw            | 2199421 |  2199421 |    1 |
| X40.trim           | 2201340 |  2201340 |    1 |
| X80.raw            | 2201886 |  2201886 |    1 |
| X80.trim           | 2205541 |  2205541 |    1 |

## Ngon: expand anchors

* anchorLong

* contigTrim

## Ngon: final stats

* Stats

| Name                   |     N50 |     Sum |    # |
|:-----------------------|--------:|--------:|-----:|
| Genome                 | 2153922 | 2153922 |    1 |
| Paralogs               |    4318 |  142093 |   53 |
| anchor.merge           |   24324 | 2013846 |  142 |
| others.merge           |    1347 |  134531 |   88 |
| anchorLong             |   37026 | 1416019 |   76 |
| contigTrim             |   70807 | 1363652 |   59 |
| canu-X40-raw           | 2199421 | 2199421 |    1 |
| canu-X40-trim          | 2201340 | 2201340 |    1 |
| spades.scaffold        |   49686 | 2420777 | 1263 |
| spades.non-contained   |   57178 | 2062870 |   84 |
| platanus.contig        |   20636 | 2140482 |  845 |
| platanus.scaffold      |   46754 | 2104640 |  513 |
| platanus.non-contained |   46992 | 2038450 |   86 |

* quast

## Ngon: clear intermediate files

# Neisseria meningitidis FDAARGOS_209, 脑膜炎奈瑟氏菌

Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Nmen: download

* Settings

```bash
BASE_NAME=Nmen
REAL_G=2272360
COVERAGE2="40 80"
COVERAGE3="40 80"
READ_QUAL="25 30"
READ_LEN="60"
EXPAND_WITH="40"

```

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
NC_003112.2${TAB}1
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

* FastQC

* kmergenie

## Nmen: preprocess Illumina reads

## Nmen: preprocess PacBio reads

## Nmen: reads stats

* Stats

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 2272360 |    2272360 |        1 |
| Paralogs |       0 |          0 |        0 |
| Illumina |     101 | 1395253390 | 13814390 |
| uniq     |     101 | 1389594158 | 13758358 |
| scythe   |     101 | 1367023234 | 13758358 |
| Q25L60   |     101 | 1009951835 | 10324212 |
| Q30L60   |     101 |  849226072 |  9109365 |
| PacBio   |    9603 |  402166610 |    58711 |
| X40.raw  |    9572 |   90903934 |    12719 |
| X40.trim |    9017 |   80424232 |    10580 |
| X80.raw  |    9605 |  181790161 |    26345 |
| X80.trim |    9133 |  163286173 |    21467 |

## Nmen: spades

## Nmen: platanus

## Nmen: quorum

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q25L60 |   1.01G | 444.5 | 933.83M |  411.0 |   7.537% |      97 | "71" | 2.27M | 4.42M |     1.94 | 0:02'20'' |
| Q30L60 | 850.81M | 374.4 | 800.75M |  352.4 |   5.884% |      93 | "61" | 2.27M |  4.2M |     1.85 | 0:02'02'' |

## Nmen: down sampling

## Nmen: k-unitigs and anchors (sampled)

| Name          |  SumCor | CovCor | N50SR |   Sum |   # | N50Anchor |   Sum |   # | N50Others |     Sum |   # |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|--------:|-------:|------:|------:|----:|----------:|------:|----:|----------:|--------:|----:|--------------------:|----------:|:----------|
| Q25L60X40P000 |  90.89M |   40.0 |  7366 | 2.12M | 472 |      7574 | 2.02M | 374 |       956 |  97.26K |  98 | "31,41,51,61,71,81" | 0:01'08'' | 0:00'16'' |
| Q25L60X40P001 |  90.89M |   40.0 |  7203 | 2.12M | 493 |      7454 | 2.01M | 388 |       988 | 111.43K | 105 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'16'' |
| Q25L60X40P002 |  90.89M |   40.0 |  7061 | 2.13M | 487 |      7299 | 2.01M | 382 |      1003 |  118.1K | 105 | "31,41,51,61,71,81" | 0:01'08'' | 0:00'16'' |
| Q25L60X40P003 |  90.89M |   40.0 |  6602 | 2.14M | 512 |      6827 |    2M | 400 |      1052 |  134.5K | 112 | "31,41,51,61,71,81" | 0:01'09'' | 0:00'17'' |
| Q25L60X40P004 |  90.89M |   40.0 |  7452 | 2.11M | 450 |      7679 | 2.02M | 356 |       960 |  96.67K |  94 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'16'' |
| Q25L60X40P005 |  90.89M |   40.0 |  7470 | 2.13M | 455 |      7710 | 2.01M | 356 |      1193 | 115.74K |  99 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'17'' |
| Q25L60X40P006 |  90.89M |   40.0 |  7793 | 2.11M | 440 |      7961 | 2.01M | 358 |      1081 | 100.25K |  82 | "31,41,51,61,71,81" | 0:01'08'' | 0:00'15'' |
| Q25L60X40P007 |  90.89M |   40.0 |  8204 | 2.12M | 417 |      8258 | 2.02M | 339 |      1108 |  95.99K |  78 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'16'' |
| Q25L60X40P008 |  90.89M |   40.0 |  7810 | 2.12M | 448 |      8061 | 2.01M | 350 |      1021 | 114.69K |  98 | "31,41,51,61,71,81" | 0:01'09'' | 0:00'16'' |
| Q25L60X40P009 |  90.89M |   40.0 |  7812 | 2.13M | 426 |      8097 | 2.01M | 347 |      3091 |  117.5K |  79 | "31,41,51,61,71,81" | 0:01'09'' | 0:00'17'' |
| Q25L60X80P000 | 181.79M |   80.0 |  5397 | 2.13M | 616 |      5713 |    2M | 477 |       935 | 137.97K | 139 | "31,41,51,61,71,81" | 0:01'38'' | 0:00'19'' |
| Q25L60X80P001 | 181.79M |   80.0 |  5375 | 2.12M | 636 |      5645 |    2M | 484 |       759 |    119K | 152 | "31,41,51,61,71,81" | 0:01'39'' | 0:00'18'' |
| Q25L60X80P002 | 181.79M |   80.0 |  6197 | 2.11M | 549 |      6438 |    2M | 420 |       859 | 112.97K | 129 | "31,41,51,61,71,81" | 0:01'38'' | 0:00'17'' |
| Q25L60X80P003 | 181.79M |   80.0 |  6024 | 2.14M | 559 |      6212 |    2M | 439 |       992 |  138.9K | 120 | "31,41,51,61,71,81" | 0:01'39'' | 0:00'18'' |
| Q25L60X80P004 | 181.79M |   80.0 |  6259 | 2.12M | 540 |      6408 |    2M | 422 |       951 | 121.47K | 118 | "31,41,51,61,71,81" | 0:01'28'' | 0:00'18'' |
| Q30L60X40P000 |  90.89M |   40.0 |  8183 | 2.11M | 422 |      8415 | 2.01M | 332 |       988 |  99.16K |  90 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'15'' |
| Q30L60X40P001 |  90.89M |   40.0 |  8087 | 2.14M | 431 |      8226 | 1.99M | 330 |      4889 | 151.06K | 101 | "31,41,51,61,71,81" | 0:01'05'' | 0:00'17'' |
| Q30L60X40P002 |  90.89M |   40.0 |  8223 | 2.12M | 414 |      8516 | 2.01M | 318 |      1108 | 109.22K |  96 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'16'' |
| Q30L60X40P003 |  90.89M |   40.0 |  8379 | 2.11M | 397 |      8699 | 2.02M | 310 |       961 |  92.09K |  87 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'17'' |
| Q30L60X40P004 |  90.89M |   40.0 |  8526 | 2.11M | 399 |      8730 | 2.01M | 310 |       988 |  99.89K |  89 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'16'' |
| Q30L60X40P005 |  90.89M |   40.0 |  8581 |  2.1M | 396 |      8921 | 2.02M | 311 |       935 |  86.55K |  85 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'17'' |
| Q30L60X40P006 |  90.89M |   40.0 |  8575 | 2.13M | 388 |      8882 | 2.01M | 308 |      2923 | 119.92K |  80 | "31,41,51,61,71,81" | 0:01'05'' | 0:00'16'' |
| Q30L60X40P007 |  90.89M |   40.0 |  8228 | 2.13M | 418 |      8653 | 1.98M | 311 |      2166 | 142.95K | 107 | "31,41,51,61,71,81" | 0:01'08'' | 0:00'16'' |
| Q30L60X80P000 | 181.79M |   80.0 |  8160 | 2.17M | 467 |      8409 | 2.01M | 324 |       981 | 155.32K | 143 | "31,41,51,61,71,81" | 0:01'26'' | 0:00'17'' |
| Q30L60X80P001 | 181.79M |   80.0 |  8506 | 2.14M | 422 |      8882 | 2.02M | 308 |       981 | 120.62K | 114 | "31,41,51,61,71,81" | 0:01'28'' | 0:00'18'' |
| Q30L60X80P002 | 181.79M |   80.0 |  8967 | 2.16M | 402 |      9112 | 1.99M | 298 |      4889 | 164.31K | 104 | "31,41,51,61,71,81" | 0:01'28'' | 0:00'18'' |
| Q30L60X80P003 | 181.79M |   80.0 |  8966 | 2.12M | 387 |      9232 | 2.01M | 304 |      1787 |    107K |  83 | "31,41,51,61,71,81" | 0:01'04'' | 0:00'16'' |

## Nmen: merge anchors

## Nmen: 3GS

| Name               |     N50 |      Sum |    # |
|:-------------------|--------:|---------:|-----:|
| Genome             | 2272360 |  2272360 |    1 |
| Paralogs           |       0 |        0 |    0 |
| X40.raw.corrected  |    9195 | 70449230 | 8878 |
| X40.trim.corrected |    9030 | 68464011 | 8818 |
| X80.raw.corrected  |   10640 | 90338570 | 8406 |
| X80.trim.corrected |   10334 | 90084457 | 8603 |
| X40.raw            | 2187325 |  2187325 |    1 |
| X40.trim           | 2187256 |  2187256 |    1 |
| X80.raw            | 2196467 |  2196467 |    1 |
| X80.trim           | 2196486 |  2196486 |    1 |

## Nmen: expand anchors

* anchorLong

* contigTrim

## Nmen: final stats

* Stats

| Name                   |     N50 |     Sum |    # |
|:-----------------------|--------:|--------:|-----:|
| Genome                 | 2272360 | 2272360 |    1 |
| Paralogs               |       0 |       0 |    0 |
| anchor.merge           |   10021 | 2048057 |  281 |
| others.merge           |    4663 |  239139 |   82 |
| anchorLong             |    6361 |  618586 |  140 |
| contigTrim             |    6361 |  618586 |  140 |
| canu-X40-raw           | 2187325 | 2187325 |    1 |
| canu-X40-trim          | 2187256 | 2187256 |    1 |
| spades.scaffold        |   46528 | 4458223 |  626 |
| spades.non-contained   |   31959 | 4374230 |  227 |
| platanus.contig        |    8599 | 2277767 | 1568 |
| platanus.scaffold      |   42293 | 2207891 |  819 |
| platanus.non-contained |   42882 | 2094123 |   95 |

* quast

## Nmen: clear intermediate files

# Bordetella pertussis FDAARGOS_195, 百日咳博德特氏杆菌

* Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

* Other name: ATCC BAA-589D-5; Tohama 1;

* BioSample: [SAMN04875532](https://www.ncbi.nlm.nih.gov/biosample/SAMN04875532)

## Bper: download

* Reference genome

    * Strain: Bordetella pertussis Tohama I
    * Taxid: [257313](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=257313)
    * RefSeq assembly accession:
      [GCF_000195715.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/195/715/GCF_000195715.1_ASM19571v1/GCF_000195715.1_ASM19571v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0201

```bash
mkdir -p ~/data/anchr/Bper/1_genome
cd ~/data/anchr/Bper/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/195/715/GCF_000195715.1_ASM19571v1/GCF_000195715.1_ASM19571v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_002929.2${TAB}1
EOF

faops replace GCF_000195715.1_ASM19571v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Bper/Bper.multi.fas paralogs.fas

```

* Illumina

    * [SRX2179101](https://www.ncbi.nlm.nih.gov/sra/SRX2179101) SRR4271511
    * [SRX2179104](https://www.ncbi.nlm.nih.gov/sra/SRX2179104) SRR4271510

```bash
mkdir -p ~/data/anchr/Bper/2_illumina
cd ~/data/anchr/Bper/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR427/001/SRR4271511/SRR4271511_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR427/001/SRR4271511/SRR4271511_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR427/000/SRR4271510/SRR4271510_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR427/000/SRR4271510/SRR4271510_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
0177ba6d05bfbf8a77f47b56cceb7c2e SRR4271511_1.fastq.gz
bf80b95eef4b86ad09cddec0c323415a SRR4271511_2.fastq.gz
1e52042a69c78ad7e3cd4dde3cc36721 SRR4271510_1.fastq.gz
b4d60d4ec59cc7c6dcd12e235981dfda SRR4271510_2.fastq.gz
EOF

md5sum --check sra_md5.txt

gzip -d -c SRR427151{1,0}_1.fastq.gz | pigz -p 8 -c > R1.fq.gz
gzip -d -c SRR427151{1,0}_2.fastq.gz | pigz -p 8 -c > R2.fq.gz

```

## Bper: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60

```bash
BASE_DIR=$HOME/data/anchr/Bper

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
    " ::: 20 25 30 ::: 60

```

* Stats

```bash
BASE_DIR=$HOME/data/anchr/Bper
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

| Name     |     N50 |        Sum |        # |
|:---------|--------:|-----------:|---------:|
| Genome   | 4086189 |    4086189 |        1 |
| Paralogs |         |            |          |
| Illumina |     101 | 1673028438 | 16564638 |
| PacBio   |         |            |          |
| uniq     |     101 | 1655310614 | 16389214 |
| scythe   |     101 | 1610064719 | 16389214 |
| Q20L60   |     101 | 1293069038 | 13162032 |
| Q25L60   |     101 | 1054727096 | 10895386 |
| Q30L60   |     101 |  622654879 |  6731812 |

## Bper: down sampling

```bash
BASE_DIR=$HOME/data/anchr/Bper
cd ${BASE_DIR}

ARRAY=(
    "2_illumina/Q20L60:Q20L60:5000000"
    "2_illumina/Q25L60:Q25L60:5000000"
    "2_illumina/Q30L60:Q30L60:3000000"
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

## Bper: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/Bper
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L60
        Q25L60
        Q30L60
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
        anchr superreads \
            R1.fq.gz R2.fq.gz \
            --nosr -p 8 \
            --kmer 41,61,81 \
            -o superreads.sh
        bash superreads.sh
    "

```

Clear intermediate files.

```bash
BASE_DIR=$HOME/data/anchr/Bper
cd ${BASE_DIR}

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## Bper: create anchors

```bash
BASE_DIR=$HOME/data/anchr/Bper
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L60
        Q25L60
        Q30L60
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

## Bper: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/Bper
cd ${BASE_DIR}

REAL_G=4086189

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

perl -e '
    for my $n (
        qw{
        Q20L60
        Q25L60
        Q30L60
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
BASE_DIR=$HOME/data/anchr/Bper
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

perl -e '
    for my $n (
        qw{
        Q20L60
        Q25L60
        Q30L60
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

| Name           |   SumFq | CovFq | AvgRead |       Kmer |   SumFa | Discard% | RealG |  EstG | Est/Real | SumKU | SumSR |   RunTime |
|:---------------|--------:|------:|--------:|-----------:|--------:|---------:|------:|------:|---------:|------:|------:|----------:|
| Q20L60_1000000 |  196.5M |  48.1 |      98 | "41,61,81" | 174.49M |  11.200% | 4.09M | 3.53M |     0.86 | 3.35M |     0 | 0:02'28'' |
| Q20L60_2000000 | 392.97M |  96.2 |      98 | "41,61,81" | 350.42M |  10.828% | 4.09M | 3.76M |     0.92 | 3.49M |     0 | 0:04'13'' |
| Q20L60_3000000 | 589.47M | 144.3 |      98 | "41,61,81" | 527.09M |  10.583% | 4.09M |    4M |     0.98 | 3.49M |     0 | 0:05'46'' |
| Q20L60_4000000 | 785.92M | 192.3 |      98 | "41,61,81" | 704.37M |  10.377% | 4.09M | 4.32M |     1.06 | 3.42M |     0 | 0:07'29'' |
| Q20L60_5000000 | 982.43M | 240.4 |      98 | "41,61,81" | 882.57M |  10.165% | 4.09M | 4.68M |     1.15 | 3.26M |     0 | 0:09'27'' |
| Q25L60_1000000 | 193.62M |  47.4 |      97 | "41,61,81" |    176M |   9.104% | 4.09M | 3.49M |     0.85 | 3.31M |     0 | 0:02'24'' |
| Q25L60_2000000 | 387.23M |  94.8 |      97 | "41,61,81" |  353.2M |   8.788% | 4.09M | 3.72M |     0.91 | 3.46M |     0 | 0:04'20'' |
| Q25L60_3000000 | 580.86M | 142.2 |      97 | "41,61,81" | 530.94M |   8.594% | 4.09M | 3.99M |     0.98 | 3.53M |     0 | 0:06'14'' |
| Q25L60_4000000 | 774.45M | 189.5 |      97 | "41,61,81" | 709.38M |   8.401% | 4.09M | 4.35M |     1.06 | 3.58M |     0 | 0:07'41'' |
| Q25L60_5000000 | 968.06M | 236.9 |      97 | "41,61,81" | 888.28M |   8.242% | 4.09M | 4.75M |     1.16 | 3.61M |     0 | 0:09'43'' |
| Q30L60_1000000 | 184.98M |  45.3 |      93 | "41,61,81" | 170.81M |   7.662% | 4.09M | 3.44M |     0.84 | 3.16M |     0 | 0:02'29'' |
| Q30L60_2000000 |    370M |  90.6 |      92 | "41,61,81" | 343.25M |   7.231% | 4.09M | 3.84M |     0.94 | 3.36M |     0 | 0:04'09'' |
| Q30L60_3000000 | 554.99M | 135.8 |      92 | "41,61,81" | 516.82M |   6.878% | 4.09M | 4.35M |     1.07 | 3.46M |     0 | 0:05'33'' |

| Name           | N50SR |   Sum |    # | N50Anchor |   Sum |    # | N50Others |     Sum |    # |   RunTime |
|:---------------|------:|------:|-----:|----------:|------:|-----:|----------:|--------:|-----:|----------:|
| Q20L60_1000000 |  2742 | 3.35M | 1662 |      3114 | 2.96M | 1127 |       753 | 390.98K |  535 | 0:01'23'' |
| Q20L60_2000000 |  2254 | 3.49M | 2020 |      2579 | 2.94M | 1273 |       766 | 547.44K |  747 | 0:01'51'' |
| Q20L60_3000000 |  1735 | 3.49M | 2481 |      2108 | 2.64M | 1335 |       766 | 842.39K | 1146 | 0:02'32'' |
| Q20L60_4000000 |  1386 | 3.42M | 2875 |      1793 | 2.27M | 1291 |       748 |   1.15M | 1584 | 0:02'51'' |
| Q20L60_5000000 |  1130 | 3.26M | 3134 |      1572 | 1.85M | 1169 |       742 |   1.41M | 1965 | 0:03'05'' |
| Q25L60_1000000 |  2807 | 3.31M | 1588 |      3210 | 2.93M | 1072 |       744 | 374.64K |  516 | 0:01'22'' |
| Q25L60_2000000 |  3211 | 3.46M | 1544 |      3556 | 3.13M | 1091 |       728 | 328.02K |  453 | 0:02'10'' |
| Q25L60_3000000 |  2914 | 3.53M | 1679 |      3223 | 3.14M | 1148 |       766 | 391.06K |  531 | 0:02'53'' |
| Q25L60_4000000 |  2532 | 3.58M | 1905 |      2838 |  3.1M | 1247 |       767 | 482.46K |  658 | 0:03'36'' |
| Q25L60_5000000 |  2192 | 3.61M | 2149 |      2563 | 3.01M | 1333 |       759 |  592.4K |  816 | 0:04'09'' |
| Q30L60_1000000 |  2433 | 3.16M | 1703 |      2778 |  2.7M | 1076 |       758 | 459.36K |  627 | 0:01'29'' |
| Q30L60_2000000 |  2858 | 3.36M | 1610 |      3251 | 2.98M | 1087 |       731 | 372.53K |  523 | 0:01'44'' |
| Q30L60_3000000 |  3136 | 3.46M | 1580 |      3503 |  3.1M | 1088 |       742 | 353.88K |  492 | 0:02'18'' |

## Bper: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/Bper
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L60_1000000/anchor/pe.anchor.fa \
    Q20L60_2000000/anchor/pe.anchor.fa \
    Q20L60_3000000/anchor/pe.anchor.fa \
    Q20L60_4000000/anchor/pe.anchor.fa \
    Q25L60_1000000/anchor/pe.anchor.fa \
    Q25L60_2000000/anchor/pe.anchor.fa \
    Q25L60_3000000/anchor/pe.anchor.fa \
    Q25L60_4000000/anchor/pe.anchor.fa \
    Q30L60_1000000/anchor/pe.anchor.fa \
    Q30L60_2000000/anchor/pe.anchor.fa \
    Q30L60_3000000/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
anchr contained \
    Q20L60_2000000/anchor/pe.others.fa \
    Q25L60_2000000/anchor/pe.others.fa \
    Q30L60_2000000/anchor/pe.others.fa \
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

* Stats

```bash
BASE_DIR=$HOME/data/anchr/Bper
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
| Genome       | 4086189 | 4086189 |   1 |
| Paralogs     |         |         |     |
| anchor.merge |    4674 | 3478267 | 986 |
| others.merge |    1024 |   52609 |  49 |

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/Bper
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

# Corynebacterium diphtheriae FDAARGOS_197, 白喉杆菌

* Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

* Other name: ATCC 700971D-5; NCTC 13129;

* BioSample: [SAMN04875534](https://www.ncbi.nlm.nih.gov/biosample/SAMN04875534)

## Cdip: download

* Reference genome

    * Strain: Corynebacterium diphtheriae NCTC 13129 (high GC Gram+)
    * Taxid: [257309](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=257309)
    * RefSeq assembly accession:
      [GCF_000195815.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/195/815/GCF_000195815.1_ASM19581v1/GCF_000195815.1_ASM19581v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0180

```bash
mkdir -p ~/data/anchr/Cdip/1_genome
cd ~/data/anchr/Cdip/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/195/815/GCF_000195815.1_ASM19581v1/GCF_000195815.1_ASM19581v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_002935.2${TAB}1
EOF

faops replace GCF_000195815.1_ASM19581v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Cdip/Cdip.multi.fas paralogs.fas

```

* Illumina

    * [SRX2179108](https://www.ncbi.nlm.nih.gov/sra/SRX2179108) SRR4271515

```bash
mkdir -p ~/data/anchr/Cdip/2_illumina
cd ~/data/anchr/Cdip/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR427/005/SRR4271515/SRR4271515_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR427/005/SRR4271515/SRR4271515_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
abb1c4a0140d13fa9513e445ebcb97c6 SRR4271515_1.fastq.gz
0910e7ae9d75f37a08e3b24aa75326ed SRR4271515_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s SRR4271515_1.fastq.gz R1.fq.gz
ln -s SRR4271515_2.fastq.gz R2.fq.gz

```

* PacBio

```bash
mkdir -p ~/data/anchr/Cdip/3_pacbio
cd ~/data/anchr/Cdip/3_pacbio

# download from sra
cat <<EOF > hdf5.txt
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR4271514_SRR4271514_hdf5.tgz
EOF
aria2c -x 9 -s 3 -c -i hdf5.txt

# untar
mkdir -p ~/data/anchr/Cdip/3_pacbio/untar
cd ~/data/anchr/Cdip/3_pacbio
tar xvfz SRR4271514_SRR4271514_hdf5.tgz --directory untar

# convert .bax.h5 to .subreads.bam
mkdir -p ~/data/anchr/Cdip/3_pacbio/bam
cd ~/data/anchr/Cdip/3_pacbio/bam

source ~/share/pitchfork/deployment/setup-env.sh
for movie in m141028;
do 
    bax2bam ~/data/anchr/Cdip/3_pacbio/untar/${movie}*.bax.h5
done

# convert .subreads.bam to fasta
mkdir -p ~/data/anchr/Cdip/3_pacbio/fasta

for movie in m141028;
do
    if [ ! -e ~/data/anchr/Cdip/3_pacbio/bam/${movie}*.subreads.bam ]; then
        continue
    fi

    samtools fasta \
        ~/data/anchr/Cdip/3_pacbio/bam/${movie}*.subreads.bam \
        > ~/data/anchr/Cdip/3_pacbio/fasta/${movie}.fasta
done

cd ~/data/anchr/Cdip
cat 3_pacbio/fasta/*.fasta > 3_pacbio/pacbio.fasta

rm -fr ~/data/anchr/Cdip/3_pacbio/untar
```

* FastQC

```bash
BASE_NAME=Cdip
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

## Cdip: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60

```bash
BASE_NAME=Cdip
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
    " ::: 20 25 30 ::: 60

```

* Stats

```bash
BASE_NAME=Cdip
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
    $(echo "PacBio";   faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md

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
| Genome   | 2488635 |    2488635 |        1 |
| Paralogs |    5635 |      56210 |       18 |
| PacBio   |    8966 |  665803465 |   110317 |
| Illumina |     101 | 1124010012 | 11128812 |
| uniq     |     101 | 1120677416 | 11095816 |
| Q20L60   |     101 |  942374034 |  9521902 |
| Q25L60   |     101 |  811857109 |  8299530 |
| Q30L60   |     101 |  674398728 |  7270020 |

## Cdip: quorum

```bash
BASE_NAME=Cdip
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
BASE_NAME=Cdip
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
BASE_NAME=Cdip
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=2488635

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

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q20L60 | 942.37M | 378.7 | 839.01M |  337.1 |  10.969% |      98 | "51" | 2.49M | 2.92M |     1.17 | 0:03'14'' |
| Q25L60 | 811.86M | 326.2 | 742.27M |  298.3 |   8.571% |      97 | "51" | 2.49M | 2.58M |     1.04 | 0:02'48'' |
| Q30L60 | 675.61M | 271.5 | 631.39M |  253.7 |   6.545% |      93 | "43" | 2.49M | 2.48M |     0.99 | 0:02'21'' |

* kmergenie

```bash
BASE_NAME=Cdip
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

kmergenie -l 21 -k 91 -s 10 -t 8 ../R1.fq.gz -o oriR1
kmergenie -l 21 -k 91 -s 10 -t 8 ../R2.fq.gz -o oriR2
kmergenie -l 21 -k 91 -s 10 -t 8 ../Q30L60/pe.cor.fa -o Q30L60

```

## Cdip: down sampling

```bash
BASE_NAME=Cdip
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=2488635

for QxxLxx in $( parallel "echo 'Q{1}L{2}'" ::: 25 30 ::: 60 ); do
    echo "==> ${QxxLxx}"

    if [ ! -e 2_illumina/${QxxLxx}/pe.cor.fa ]; then
        echo "2_illumina/${QxxLxx}/pe.cor.fa not exists"
        continue;
    fi

    for X in 40 80 120 160 240; do
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

```bash
BASE_DIR=$HOME/data/anchr/Cdip
cd ${BASE_DIR}

head -n 35000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.40x.fasta
faops n50 -S -C 3_pacbio/pacbio.40x.fasta

head -n 70000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.80x.fasta
faops n50 -S -C 3_pacbio/pacbio.80x.fasta

```

## Cdip: k-unitigs and anchors (sampled)

```bash
BASE_NAME=Cdip
cd ${HOME}/data/anchr/${BASE_NAME}

# k-unitigs (sampled)
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
    " ::: 25 30 ::: 60 ::: 40 80 120 160 240 ::: 000 001 002 003 004 005 006

# anchors (sampled)
parallel --no-run-if-empty -j 3 "
    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'

    if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    rm -fr Q{1}L{2}X{3}P{4}/anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh Q{1}L{2}X{3}P{4} 8 false
    
    echo >&2
    " ::: 25 30 ::: 60 ::: 40 80 120 160 240 ::: 000 001 002 003 004 005 006

# Stats of anchors
REAL_G=2488635

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > stat2.md

parallel -k --no-run-if-empty -j 6 "
    if [ ! -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 Q{1}L{2}X{3}P{4} ${REAL_G}
    " ::: 25 30 ::: 60 ::: 40 80 120 160 240 ::: 000 001 002 003 004 005 006 \
    >> stat2.md

cat stat2.md
```

| Name           | SumCor  | CovCor | N50SR |   Sum |   # | N50Anchor |   Sum |   # | N50Others |    Sum |   # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|:--------|-------:|------:|------:|----:|----------:|------:|----:|----------:|-------:|----:|--------------------:|----------:|----------:|
| Q25L60X40P000  | 99.55M  |   40.0 | 34190 | 2.46M | 140 |     34190 | 2.45M | 131 |       844 |  7.28K |   9 | "31,41,51,61,71,81" | 0:02'48'' | 0:01'25'' |
| Q25L60X40P001  | 99.55M  |   40.0 | 30045 | 2.46M | 148 |     30045 | 2.45M | 132 |       844 | 13.48K |  16 | "31,41,51,61,71,81" | 0:02'49'' | 0:01'35'' |
| Q25L60X40P002  | 99.55M  |   40.0 | 27638 | 2.47M | 162 |     27680 | 2.45M | 145 |       742 | 13.08K |  17 | "31,41,51,61,71,81" | 0:02'46'' | 0:01'35'' |
| Q25L60X40P003  | 99.55M  |   40.0 | 33236 | 2.46M | 131 |     33236 | 2.45M | 117 |       684 |  9.59K |  14 | "31,41,51,61,71,81" | 0:02'53'' | 0:01'23'' |
| Q25L60X40P004  | 99.55M  |   40.0 | 49674 | 2.45M |  99 |     49674 | 2.45M |  91 |       748 |  6.37K |   8 | "31,41,51,61,71,81" | 0:02'58'' | 0:01'31'' |
| Q25L60X40P005  | 99.55M  |   40.0 | 46364 | 2.46M | 108 |     46364 | 2.45M |  97 |       727 |  7.86K |  11 | "31,41,51,61,71,81" | 0:02'55'' | 0:01'33'' |
| Q25L60X40P006  | 99.55M  |   40.0 | 47421 | 2.46M | 117 |     47421 | 2.45M | 105 |       783 |  9.12K |  12 | "31,41,51,61,71,81" | 0:02'45'' | 0:01'35'' |
| Q25L60X80P000  | 199.09M |   80.0 | 19434 | 2.46M | 238 |     19434 | 2.44M | 213 |       822 | 19.67K |  25 | "31,41,51,61,71,81" | 0:03'58'' | 0:02'06'' |
| Q25L60X80P001  | 199.09M |   80.0 | 15365 | 2.46M | 246 |     15447 | 2.45M | 227 |       727 | 13.98K |  19 | "31,41,51,61,71,81" | 0:03'53'' | 0:02'11'' |
| Q25L60X80P002  | 199.09M |   80.0 | 27534 | 2.46M | 163 |     27534 | 2.45M | 151 |       707 |  8.48K |  12 | "31,41,51,61,71,81" | 0:03'57'' | 0:01'56'' |
| Q25L60X120P000 | 298.64M |  120.0 |  9278 | 2.47M | 391 |      9498 | 2.44M | 351 |       770 | 29.14K |  40 | "31,41,51,61,71,81" | 0:05'22'' | 0:02'46'' |
| Q25L60X120P001 | 298.64M |  120.0 | 13839 | 2.46M | 290 |     13936 | 2.44M | 261 |       727 | 20.61K |  29 | "31,41,51,61,71,81" | 0:05'23'' | 0:02'34'' |
| Q25L60X160P000 | 398.18M |  160.0 |  6698 | 2.47M | 550 |      6848 | 2.42M | 479 |       727 | 50.73K |  71 | "31,41,51,61,71,81" | 0:07'01'' | 0:03'12'' |
| Q25L60X240P000 | 597.27M |  240.0 |  4746 | 2.47M | 759 |      4908 | 2.38M | 627 |       778 |  95.9K | 132 | "31,41,51,61,71,81" | 0:09'39'' | 0:03'43'' |
| Q30L60X40P000  | 99.55M  |   40.0 | 55218 | 2.46M |  91 |     55218 | 2.44M |  81 |     10398 | 17.13K |  10 | "31,41,51,61,71,81" | 0:03'05'' | 0:01'35'' |
| Q30L60X40P001  | 99.55M  |   40.0 | 55749 | 2.45M |  93 |     55749 | 2.45M |  85 |       844 |  6.42K |   8 | "31,41,51,61,71,81" | 0:02'52'' | 0:01'35'' |
| Q30L60X40P002  | 99.55M  |   40.0 | 65454 | 2.46M |  75 |     65454 | 2.44M |  62 |      1126 | 13.91K |  13 | "31,41,51,61,71,81" | 0:03'01'' | 0:01'37'' |
| Q30L60X40P003  | 99.55M  |   40.0 | 97954 | 2.45M |  68 |     97954 | 2.45M |  62 |       834 |  4.77K |   6 | "31,41,51,61,71,81" | 0:02'53'' | 0:01'25'' |
| Q30L60X40P004  | 99.55M  |   40.0 | 71924 | 2.45M |  76 |     71924 | 2.45M |  67 |       727 |  6.18K |   9 | "31,41,51,61,71,81" | 0:02'54'' | 0:01'26'' |
| Q30L60X40P005  | 99.55M  |   40.0 | 63766 | 2.45M |  88 |     63766 | 2.44M |  76 |       727 |  8.73K |  12 | "31,41,51,61,71,81" | 0:02'37'' | 0:01'26'' |
| Q30L60X80P000  | 199.09M |   80.0 | 60425 | 2.45M |  76 |     60425 | 2.45M |  70 |       753 |  4.59K |   6 | "31,41,51,61,71,81" | 0:04'00'' | 0:02'03'' |
| Q30L60X80P001  | 199.09M |   80.0 | 68973 | 2.45M |  64 |     68973 | 2.45M |  57 |       844 |  5.27K |   7 | "31,41,51,61,71,81" | 0:04'02'' | 0:02'00'' |
| Q30L60X80P002  | 199.09M |   80.0 | 89791 | 2.45M |  65 |     89791 | 2.45M |  58 |       809 |  5.53K |   7 | "31,41,51,61,71,81" | 0:04'01'' | 0:02'08'' |
| Q30L60X120P000 | 298.64M |  120.0 | 60425 | 2.45M |  74 |     60427 | 2.45M |  67 |       727 |  5.37K |   7 | "31,41,51,61,71,81" | 0:05'23'' | 0:02'27'' |
| Q30L60X120P001 | 298.64M |  120.0 | 71924 | 2.45M |  62 |     71924 | 2.44M |  56 |       844 |   4.9K |   6 | "31,41,51,61,71,81" | 0:05'18'' | 0:02'36'' |
| Q30L60X160P000 | 398.18M |  160.0 | 60427 | 2.45M |  75 |     60427 | 2.45M |  68 |       727 |  5.37K |   7 | "31,41,51,61,71,81" | 0:06'26'' | 0:03'04'' |
| Q30L60X240P000 | 597.27M |  240.0 | 57594 | 2.45M |  86 |     59198 | 2.44M |  74 |       844 |  9.05K |  12 | "31,41,51,61,71,81" | 0:06'47'' | 0:03'28'' |

## Cdip: merge anchors

```bash
BASE_NAME=Cdip
cd ${HOME}/data/anchr/${BASE_NAME}

# merge anchors
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
            fi
            " ::: 25 30 ::: 60 ::: 40 80 120 160 240 ::: 000 001 002 003 004 005 006
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
            " ::: 25 30 ::: 60 ::: 40 80 120 160 240 ::: 000 001 002 003 004 005 006
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.merge.fasta

# anchors sorted on ref
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

## Cdip: 3GS

```bash
BASE_NAME=Cdip
REAL_G=2488635
cd $HOME/data/anchr/${BASE_NAME}

canu \
    -p ${BASE_NAME} -d canu-raw-40x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=${REAL_G} \
    -pacbio-raw 3_pacbio/pacbio.40x.fasta

canu \
    -p ${BASE_NAME} -d canu-raw-80x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=${REAL_G} \
    -pacbio-raw 3_pacbio/pacbio.80x.fasta

faops n50 -S -C canu-raw-40x/${BASE_NAME}.trimmedReads.fasta.gz
faops n50 -S -C canu-raw-80x/${BASE_NAME}.trimmedReads.fasta.gz

```

## Cdip: expand anchors

* anchorLong

```bash
BASE_NAME=Cdip
cd ${HOME}/data/anchr/${BASE_NAME}

anchr cover \
    --parallel 16 \
    -c 2 -m 40 \
    -b 20 --len 1000 --idt 0.9 \
    merge/anchor.merge.fasta \
    canu-raw-40x/${BASE_NAME}.trimmedReads.fasta.gz \
    -o merge/anchor.cover.fasta

rm -fr anchorLong
anchr overlap2 \
    --parallel 16 \
    merge/anchor.cover.fasta \
    canu-raw-40x/${BASE_NAME}.trimmedReads.fasta.gz \
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
    --range "1-${ANCHOR_COUNT}" --len 1000 --idt 0.98 --max "-14" -c 4

pushd anchorLong
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
BASE_NAME=Cdip
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr contigTrim
anchr overlap2 \
    --parallel 16 \
    anchorLong/contig.fasta \
    canu-raw-40x/${BASE_NAME}.contigs.fasta \
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

pushd contigTrim
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
BASE_NAME=Cdip
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr 9_qa_contig
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/anchor.cover.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-raw-40x/${BASE_NAME}.contigs.fasta \
    canu-raw-80x/${BASE_NAME}.contigs.fasta \
    1_genome/paralogs.fas \
    --label "merge,cover,contig,contigTrim,canu-40x,canu-80x,paralogs" \
    -o 9_qa_contig

```

* Stats

```bash
BASE_NAME=Cdip
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
| Genome       | 2488635 | 2488635 |  1 |
| Paralogs     |    5635 |   56210 | 18 |
| anchor.merge |  115948 | 2447558 | 46 |
| others.merge |    2541 |   23728 | 10 |
| anchor.cover |  108033 | 2442070 | 45 |
| anchorLong   |  125030 | 2441001 | 30 |
| contigTrim   | 2488479 | 2488479 |  1 |

* Clear QxxLxxXxx.

```bash
BASE_NAME=Cdip
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr 2_illumina/Q{20,25,30}L{1,60,90,120}X*
rm -fr Q{20,25,30}L{1,60,90,120}X*
```

# Francisella tularensis FDAARGOS_247, 土拉热弗朗西斯氏菌

* Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

* Other name: SHU-S4

* BioSample: [SAMN04875573](https://www.ncbi.nlm.nih.gov/biosample/SAMN04875573)

## Ftul: download

* Reference genome

    * Strain: Francisella tularensis subsp. tularensis SCHU S4 (g-proteobacteria)
    * Taxid: [177416](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=177416)
    * RefSeq assembly accession:
      [GCF_000008985.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/985/GCF_000008985.1_ASM898v1/GCF_000008985.1_ASM898v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0438

```bash
mkdir -p ~/data/anchr/Ftul/1_genome
cd ~/data/anchr/Ftul/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/985/GCF_000008985.1_ASM898v1/GCF_000008985.1_ASM898v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_006570.2${TAB}1
EOF

faops replace GCF_000008985.1_ASM898v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Ftul/Ftul.multi.fas paralogs.fas

```

* Illumina

    * [SRX2105481](https://www.ncbi.nlm.nih.gov/sra/SRX2179108) SRR4124773

```bash
mkdir -p ~/data/anchr/Ftul/2_illumina
cd ~/data/anchr/Ftul/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR412/003/SRR4124773/SRR4124773_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR412/003/SRR4124773/SRR4124773_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
f24d93fab957c01c8501d7b60c1f0e99 SRR4124773_1.fastq.gz
6cdca7f1fb3bbbb811a3c8b9c63dcd3b SRR4124773_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s SRR4124773_1.fastq.gz R1.fq.gz
ln -s SRR4124773_2.fastq.gz R2.fq.gz

```

* PacBio

```bash
mkdir -p ~/data/anchr/Ftul/3_pacbio
cd ~/data/anchr/Ftul/3_pacbio

# download from sra
cat <<EOF > hdf5.txt
http://sra-download.ncbi.nlm.nih.gov/srapub_files/SRR4124774_SRR4124774_hdf5.tgz
EOF
aria2c -x 9 -s 3 -c -i hdf5.txt

# untar
mkdir -p ~/data/anchr/Ftul/3_pacbio/untar
cd ~/data/anchr/Ftul/3_pacbio
tar xvfz SRR4124774_SRR4124774_hdf5.tgz --directory untar

# convert .bax.h5 to .subreads.bam
mkdir -p ~/data/anchr/Ftul/3_pacbio/bam
cd ~/data/anchr/Ftul/3_pacbio/bam

source ~/share/pitchfork/deployment/setup-env.sh
for movie in m150419;
do 
    bax2bam ~/data/anchr/Ftul/3_pacbio/untar/${movie}*.bax.h5
done

# convert .subreads.bam to fasta
mkdir -p ~/data/anchr/Ftul/3_pacbio/fasta

for movie in m150419;
do
    if [ ! -e ~/data/anchr/Ftul/3_pacbio/bam/${movie}*.subreads.bam ]; then
        continue
    fi

    samtools fasta \
        ~/data/anchr/Ftul/3_pacbio/bam/${movie}*.subreads.bam \
        > ~/data/anchr/Ftul/3_pacbio/fasta/${movie}.fasta
done

cd ~/data/anchr/Ftul
cat 3_pacbio/fasta/*.fasta > 3_pacbio/pacbio.fasta

rm -fr ~/data/anchr/Ftul/3_pacbio/untar
```

* FastQC

```bash
BASE_NAME=Ftul
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

## Ftul: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60

```bash
BASE_NAME=Ftul
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

# Down sampling to 200x
REAL_G=1892775
READ_COUNT=$(( 200 / 2 * ${REAL_G} / 101 ))
parallel --no-run-if-empty -j 2 "
    seqtk sample \
        -s${READ_COUNT} \
        2_illumina/{}.uniq.fq.gz \
        ${READ_COUNT} \
        | pigz -p 4 -c \
        > 2_illumina/{}.200x.fq.gz
    " ::: R1 R2

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
        ../R1.200x.fq.gz ../R2.200x.fq.gz \
        -o stdout \
        | bash
    " ::: 20 25 30 ::: 60

```

* Stats

```bash
BASE_NAME=Ftul
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
    $(echo "PacBio";   faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "200x";     faops n50 -H -S -C 2_illumina/R1.200x.fq.gz 2_illumina/R2.200x.fq.gz;) >> stat.md

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
| Genome   | 1892775 |    1892775 |        1 |
| Paralogs |   33912 |      93531 |       10 |
| PacBio   |   10022 | 1161069478 |   151564 |
| Illumina |     101 | 2144257270 | 21230270 |
| uniq     |     101 | 2122919000 | 21019000 |
| 200x     |     101 |  378554868 |  3748068 |
| Q20L60   |     101 |  367096899 |  3645544 |
| Q25L60   |     101 |  358221620 |  3563774 |
| Q30L60   |     101 |  348913664 |  3507509 |

## Ftul: quorum

```bash
BASE_NAME=Ftul
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
BASE_NAME=Ftul
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
BASE_NAME=Ftul
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=1892775

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

| Name   | SumIn |  CovIn | SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|-------:|-------:|---------:|--------:|-----:|------:|------:|---------:|----------:|
| Q20L60 | 2.06G | 1087.9 |  1.96G | 1033.3 |   5.015% |     100 | "71" | 1.89M | 1.92M |     1.01 | 0:05'31'' |
| Q25L60 | 2.01G | 1061.5 |  1.92G | 1016.4 |   4.253% |     100 | "71" | 1.89M | 1.89M |     1.00 | 0:05'29'' |
| Q30L60 | 1.96G | 1034.1 |  1.89G |  998.3 |   3.465% |      99 | "71" | 1.89M | 1.86M |     0.98 | 0:05'29'' |

| Name   |   SumIn | CovIn |  SumOut | CovOut | Discard% | AvgRead | Kmer | RealG | EstG | Est/Real |   RunTime |
|:-------|--------:|------:|--------:|-------:|---------:|--------:|-----:|------:|-----:|---------:|----------:|
| Q20L60 |  367.1M | 193.9 | 348.22M |  184.0 |   5.143% |     100 | "71" | 1.89M | 1.8M |     0.95 | 0:01'15'' |
| Q25L60 | 358.22M | 189.3 | 342.63M |  181.0 |   4.353% |     100 | "71" | 1.89M | 1.8M |     0.95 | 0:01'10'' |
| Q30L60 | 349.03M | 184.4 | 336.65M |  177.9 |   3.546% |      99 | "71" | 1.89M | 1.8M |     0.95 | 0:01'10'' |

* kmergenie

```bash
BASE_NAME=Ftul
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

kmergenie -l 21 -k 91 -s 10 -t 8 ../R1.fq.gz -o oriR1
kmergenie -l 21 -k 91 -s 10 -t 8 ../R2.fq.gz -o oriR2
kmergenie -l 21 -k 91 -s 10 -t 8 ../Q30L60/pe.cor.fa -o Q30L60

```

## Ftul: down sampling

```bash
BASE_NAME=Ftul
cd ${HOME}/data/anchr/${BASE_NAME}

REAL_G=1892775

for QxxLxx in $( parallel "echo 'Q{1}L{2}'" ::: 25 30 ::: 60 ); do
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

```bash
BASE_DIR=$HOME/data/anchr/Ftul
cd ${BASE_DIR}

head -n 20000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.40x.fasta
faops n50 -S -C 3_pacbio/pacbio.40x.fasta

head -n 40000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.80x.fasta
faops n50 -S -C 3_pacbio/pacbio.80x.fasta

```

## Ftul: k-unitigs and anchors (sampled)

```bash
BASE_NAME=Ftul
cd ${HOME}/data/anchr/${BASE_NAME}

# k-unitigs (sampled)
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
    " ::: 25 30 ::: 60 ::: 40 80 120 160 ::: 000 001 002 003 004 005 006

# anchors (sampled)
parallel --no-run-if-empty -j 3 "
    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'

    if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    rm -fr Q{1}L{2}X{3}P{4}/anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh Q{1}L{2}X{3}P{4} 8 false
    
    echo >&2
    " ::: 25 30 ::: 60 ::: 40 80 120 160 ::: 000 001 002 003 004 005 006

# Stats of anchors
REAL_G=1892775

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > stat2.md

parallel -k --no-run-if-empty -j 6 "
    if [ ! -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 Q{1}L{2}X{3}P{4} ${REAL_G}
    " ::: 25 30 ::: 60 ::: 40 80 120 160 ::: 000 001 002 003 004 005 006 \
    >> stat2.md

cat stat2.md
```

| Name           |  SumCor | CovCor | N50SR |   Sum |  # | N50Anchor |   Sum |  # | N50Others |    Sum | # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|--------:|-------:|------:|------:|---:|----------:|------:|---:|----------:|-------:|--:|--------------------:|----------:|:----------|
| Q25L60X40P000  |  75.71M |   40.0 | 35248 |  1.8M | 72 |     35248 |  1.8M | 71 |       865 |    865 | 1 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'52'' |
| Q25L60X40P001  |  75.71M |   40.0 | 32751 |  1.8M | 75 |     32751 | 1.79M | 72 |      4293 |  9.43K | 3 | "31,41,51,61,71,81" | 0:01'15'' | 0:00'52'' |
| Q25L60X40P002  |  75.71M |   40.0 | 32751 |  1.8M | 76 |     32751 | 1.79M | 73 |      4293 |  9.45K | 3 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'54'' |
| Q25L60X40P003  |  75.71M |   40.0 | 32751 | 1.82M | 75 |     32803 | 1.77M | 72 |     23232 | 47.32K | 3 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'47'' |
| Q25L60X80P000  | 151.42M |   80.0 | 32751 |  1.8M | 78 |     32751 |  1.8M | 74 |       645 |  2.58K | 4 | "31,41,51,61,71,81" | 0:01'48'' | 0:01'09'' |
| Q25L60X80P001  | 151.42M |   80.0 | 31667 |  1.8M | 79 |     31667 |  1.8M | 77 |       865 |  1.44K | 2 | "31,41,51,61,71,81" | 0:01'49'' | 0:01'12'' |
| Q25L60X120P000 | 227.13M |  120.0 | 32404 |  1.8M | 83 |     32404 |  1.8M | 78 |       650 |  3.55K | 5 | "31,41,51,61,71,81" | 0:02'27'' | 0:01'21'' |
| Q25L60X160P000 | 302.84M |  160.0 | 31667 |  1.8M | 84 |     31667 |  1.8M | 83 |       865 |    865 | 1 | "31,41,51,61,71,81" | 0:03'05'' | 0:01'42'' |
| Q30L60X40P000  |  75.71M |   40.0 | 35248 |  1.8M | 72 |     35248 |  1.8M | 71 |       855 |    855 | 1 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'56'' |
| Q30L60X40P001  |  75.71M |   40.0 | 32751 | 1.84M | 76 |     32813 | 1.76M | 71 |     32374 | 74.19K | 5 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'45'' |
| Q30L60X40P002  |  75.71M |   40.0 | 32751 |  1.8M | 73 |     32751 |  1.8M | 72 |       855 |    855 | 1 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'44'' |
| Q30L60X40P003  |  75.71M |   40.0 | 32741 |  1.8M | 75 |     32741 |  1.8M | 74 |       865 |    865 | 1 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'45'' |
| Q30L60X80P000  | 151.42M |   80.0 | 32751 |  1.8M | 74 |     32751 |  1.8M | 73 |       865 |    865 | 1 | "31,41,51,61,71,81" | 0:01'49'' | 0:01'08'' |
| Q30L60X80P001  | 151.42M |   80.0 | 32751 |  1.8M | 74 |     32751 |  1.8M | 73 |       865 |    865 | 1 | "31,41,51,61,71,81" | 0:01'50'' | 0:01'12'' |
| Q30L60X120P000 | 227.13M |  120.0 | 32751 |  1.8M | 77 |     32751 |  1.8M | 75 |       865 |  1.49K | 2 | "31,41,51,61,71,81" | 0:02'26'' | 0:01'32'' |
| Q30L60X160P000 | 302.84M |  160.0 | 32404 |  1.8M | 79 |     32404 |  1.8M | 77 |       865 |  1.49K | 2 | "31,41,51,61,71,81" | 0:03'00'' | 0:01'37'' |

## Ftul: merge anchors

```bash
BASE_NAME=Ftul
cd ${HOME}/data/anchr/${BASE_NAME}

# merge anchors
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
            fi
            " ::: 25 30 ::: 60 ::: 40 80 120 160 ::: 000 001 002 003 004 005 006
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
            " ::: 25 30 ::: 60 ::: 40 80 120 160 ::: 000 001 002 003 004 005 006
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.merge.fasta

# anchors sorted on ref
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

## Ftul: 3GS

```bash
BASE_NAME=Ftul
GENOME_SIZE=1.9m
cd $HOME/data/anchr/${BASE_NAME}

canu \
    -p ${BASE_NAME} -d canu-raw-40x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=${GENOME_SIZE} \
    -pacbio-raw 3_pacbio/pacbio.40x.fasta

canu \
    -p ${BASE_NAME} -d canu-raw-80x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=${GENOME_SIZE} \
    -pacbio-raw 3_pacbio/pacbio.80x.fasta

faops n50 -S -C canu-raw-40x/${BASE_NAME}.trimmedReads.fasta.gz
faops n50 -S -C canu-raw-80x/${BASE_NAME}.trimmedReads.fasta.gz

```

## Ftul: expand anchors

* anchorLong

```bash
BASE_NAME=Ftul
cd ${HOME}/data/anchr/${BASE_NAME}

anchr cover \
    --parallel 16 \
    -c 2 -m 40 \
    -b 20 --len 1000 --idt 0.9 \
    merge/anchor.merge.fasta \
    canu-raw-40x/${BASE_NAME}.trimmedReads.fasta.gz \
    -o merge/anchor.cover.fasta

rm -fr anchorLong
anchr overlap2 \
    --parallel 16 \
    merge/anchor.cover.fasta \
    canu-raw-40x/${BASE_NAME}.trimmedReads.fasta.gz \
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
    --range "1-${ANCHOR_COUNT}" --len 1000 --idt 0.98 --max "-14" -c 4

pushd anchorLong
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
BASE_NAME=Ftul
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr contigTrim
anchr overlap2 \
    --parallel 16 \
    anchorLong/contig.fasta \
    canu-raw-40x/${BASE_NAME}.contigs.fasta \
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

pushd contigTrim
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
BASE_NAME=Ftul
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr 9_qa_contig
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/anchor.cover.fasta \
    anchorLong/contig.fasta \
    contigTrim/contig.fasta \
    canu-raw-40x/Ftul.contigs.fasta \
    canu-raw-80x/Ftul.contigs.fasta \
    1_genome/paralogs.fas \
    --label "merge,cover,contig,contigTrim,canu-40x,canu-80x,paralogs" \
    -o 9_qa_contig

```

* Stats

```bash
BASE_NAME=Ftul
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
| Genome       | 1892775 | 1892775 |  1 |
| Paralogs     |   33912 |   93531 | 10 |
| anchor.merge |   32813 | 1801122 | 73 |
| others.merge |   32404 |   64274 |  3 |
| anchor.cover |   32813 | 1796007 | 71 |
| anchorLong   |   35248 | 1795927 | 70 |
| contigTrim   | 1027458 | 1856949 |  4 |

* Clear QxxLxxXxx.

```bash
BASE_NAME=Ftul
cd ${HOME}/data/anchr/${BASE_NAME}

rm -fr 2_illumina/Q{20,25,30}L{1,60,90,120}X*
rm -fr Q{20,25,30}L{1,60,90,120}X*
```


# Shigella flexneri NCTC0001, 福氏志贺氏菌

Project [ERP005470](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=ERP005470)

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
* len: 60 and 90

```bash
BASE_DIR=$HOME/data/anchr/Sfle

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
| Genome   | 4607202 |   4828820 |       2 |
| Paralogs |    1377 |    543111 |     334 |
| Illumina |     150 | 346446900 | 2309646 |
| PacBio   |    3333 | 432566566 |  170957 |
| uniq     |     150 | 346176600 | 2307844 |
| scythe   |     150 | 346111063 | 2307844 |
| Q20L60   |     150 | 333654543 | 2241618 |
| Q20L90   |     150 | 330186360 | 2210410 |
| Q25L60   |     150 | 318498288 | 2147972 |
| Q25L90   |     150 | 313056345 | 2098682 |
| Q30L60   |     150 | 299305225 | 2026998 |
| Q30L90   |     150 | 292247140 | 1962820 |

## Sfle: down sampling

```bash
BASE_DIR=$HOME/data/anchr/Sfle
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
BASE_DIR=$HOME/data/anchr/Sfle
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
| Q20L60 | 333.65M |  72.4 |     148 | "41,61,81,101,121" | 307.96M |   7.702% | 4.61M | 4.22M |     0.92 | 4.26M |     0 | 0:04'30'' |
| Q20L90 | 330.19M |  71.7 |     149 | "41,61,81,101,121" | 305.44M |   7.493% | 4.61M | 4.21M |     0.91 | 4.26M |     0 | 0:04'36'' |
| Q25L60 |  318.5M |  69.1 |     148 | "41,61,81,101,121" | 301.45M |   5.353% | 4.61M | 4.19M |     0.91 | 4.22M |     0 | 0:04'29'' |
| Q25L90 | 313.06M |  67.9 |     149 | "41,61,81,101,121" | 296.68M |   5.230% | 4.61M | 4.19M |     0.91 | 4.22M |     0 | 0:05'02'' |
| Q30L60 | 299.31M |  65.0 |     147 | "41,61,81,101,121" | 287.19M |   4.047% | 4.61M | 4.18M |     0.91 | 4.22M |     0 | 0:04'58'' |
| Q30L90 | 292.25M |  63.4 |     148 | "41,61,81,101,121" | 280.53M |   4.009% | 4.61M | 4.18M |     0.91 | 4.22M |     0 | 0:04'49'' |

| Name   | N50SR |   Sum |   # | N50Anchor |   Sum |   # | N50Others |    Sum |   # |   RunTime |
|:-------|------:|------:|----:|----------:|------:|----:|----------:|-------:|----:|----------:|
| Q20L60 |  8637 | 4.26M | 778 |      8821 | 4.17M | 660 |       765 | 87.11K | 118 | 0:00'51'' |
| Q20L90 |  9406 | 4.26M | 725 |      9482 | 4.18M | 615 |       766 | 80.73K | 110 | 0:00'53'' |
| Q25L60 | 19847 | 4.22M | 398 |     20462 | 4.18M | 337 |       770 | 44.81K |  61 | 0:00'58'' |
| Q25L90 | 21495 | 4.22M | 378 |     21517 | 4.18M | 321 |       765 | 41.64K |  57 | 0:00'56'' |
| Q30L60 | 29285 | 4.22M | 316 |     29285 | 4.18M | 264 |       760 | 37.42K |  52 | 0:00'57'' |
| Q30L90 | 29285 | 4.22M | 314 |     29570 | 4.18M | 261 |       760 | 37.88K |  53 | 0:00'56'' |

## Sfle: merge anchors

```bash
BASE_DIR=$HOME/data/anchr/Sfle
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
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    1_genome/paralogs.fas \
    --label "merge,others,paralogs" \
    -o 9_qa

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
| anchor.merge |   29718 | 4177514 | 258 |
| others.merge |    1013 |    5268 |   5 |
| anchor.cover |   21445 | 4065033 | 337 |
| anchorLong   |   21727 | 4064559 | 333 |
| contigTrim   |   59768 | 4286051 | 140 |

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/anchr/Sfle
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

# Haemophilus influenzae FDAARGOS_199, 流感嗜血杆菌

* Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

* Other name: ATCC 51907D; Rd KW20

* BioSample: [SAMN04875536](https://www.ncbi.nlm.nih.gov/biosample/SAMN04875536)

## Hinf: download

* Reference genome

    * Strain: Haemophilus influenzae Rd KW20 (g-proteobacteria)
    * Taxid: [71421](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=71421)
    * RefSeq assembly accession:
      [GCF_000027305.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/027/305/GCF_000027305.1_ASM2730v1/GCF_000027305.1_ASM2730v1_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0324

```bash
mkdir -p ~/data/anchr/Hinf/1_genome
cd ~/data/anchr/Hinf/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/027/305/GCF_000027305.1_ASM2730v1/GCF_000027305.1_ASM2730v1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_000907.1${TAB}1
EOF

faops replace GCF_000027305.1_ASM2730v1_genomic.fna.gz replace.tsv genome.fa

cp ~/data/anchr/paralogs/otherbac/Results/Hinf/Hinf.multi.fas paralogs.fas

```

* Illumina

    * [SRX2104758](https://www.ncbi.nlm.nih.gov/sra/SRX2104758) SRR4123928

```bash
mkdir -p ~/data/anchr/Hinf/2_illumina
cd ~/data/anchr/Hinf/2_illumina

cat << EOF > sra_ftp.txt
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
EOF

md5sum --check sra_md5.txt

ln -s SRR4124773_1.fastq.gz R1.fq.gz
ln -s SRR4124773_2.fastq.gz R2.fq.gz

```

# Listeria monocytogenes FDAARGOS_351, 单核细胞增生李斯特氏菌

Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

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

Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

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

# Campylobacter jejuni subsp. jejuni ATCC 700819, 空肠弯曲杆菌

Project [SRP040661](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP040661)

## Cjej: download

* Reference genome

    * Strain: Campylobacter jejuni subsp. jejuni NCTC 11168 = ATCC 700819
    * Taxid:
      [192222](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=192222&lvl=3&lin=f&keep=1&srchmode=1&unlock)
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

# Escherichia virus Lambda

Project [SRP055199](https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP055199)

## lambda: download

* Reference genome

    * Strain: Escherichia virus Lambda (viruses)
    * Taxid:
      [10710](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=10710&lvl=3&lin=f&keep=1&srchmode=1&unlock)
    * RefSeq assembly accession:
      [GCF_000840245.1](ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/840/245/GCF_000840245.1_ViralProj14204/GCF_000840245.1_ViralProj14204_assembly_report.txt)
    * Proportion of paralogs (> 1000 bp): 0.0

```bash
mkdir -p ~/data/anchr/lambda/1_genome
cd ~/data/anchr/lambda/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/840/245/GCF_000840245.1_ViralProj14204/GCF_000840245.1_ViralProj14204_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_001416.1${TAB}1
EOF

faops replace GCF_000840245.1_ViralProj14204_genomic.fna.gz replace.tsv genome.fa

#cp ~/data/anchr/paralogs/otherbac/Results/lambda/lambda.multi.fas paralogs.fas

```

* PacBio

```bash
mkdir -p ~/data/anchr/lambda/3_pacbio
cd ~/data/anchr/lambda/3_pacbio

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR179/005/SRR1796325/SRR1796325.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
2c663d7ea426eea0aaba9017e1a9168c SRR1796325.fastq.gz
EOF

md5sum --check sra_md5.txt

cd ~/data/anchr/lambda
faops filter -l 0 3_pacbio/SRR1796325.fastq.gz 3_pacbio/pacbio.fasta

```

## lambda: preprocess PacBio reads

```bash
BASE_NAME=lambda
cd ${HOME}/data/anchr/${BASE_NAME}

head -n 3000 3_pacbio/pacbio.fasta > 3_pacbio/pacbio.40x.fasta

anchr trimlong --parallel 16 -v \
    3_pacbio/pacbio.40x.fasta \
    -o 3_pacbio/pacbio.40x.trim.fasta

```

## lambda: reads stats

```bash
BASE_NAME=lambda
cd ${HOME}/data/anchr/${BASE_NAME}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat.md
#printf "| %s | %s | %s | %s |\n" \
#    $(echo "Paralogs"; faops n50 -H -S -C 1_genome/paralogs.fas;) >> stat.md
#
#printf "| %s | %s | %s | %s |\n" \
#    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
#printf "| %s | %s | %s | %s |\n" \
#    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
#
#parallel -k --no-run-if-empty -j 3 "
#    printf \"| %s | %s | %s | %s |\n\" \
#        \$( 
#            echo Q{1}L{2};
#            if [[ {1} -ge '30' ]]; then
#                faops n50 -H -S -C \
#                    2_illumina/Q{1}L{2}/R1.fq.gz \
#                    2_illumina/Q{1}L{2}/R2.fq.gz \
#                    2_illumina/Q{1}L{2}/Rs.fq.gz;
#            else
#                faops n50 -H -S -C \
#                    2_illumina/Q{1}L{2}/R1.fq.gz \
#                    2_illumina/Q{1}L{2}/R2.fq.gz;
#            fi
#        )
#    " ::: 20 25 30 35 ::: 60 \
#    >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "PacBio";    faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md

parallel -k --no-run-if-empty -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo PacBio.{};
            faops n50 -H -S -C \
                3_pacbio/pacbio.{}.fasta;
        )
    " ::: 40x 40x.trim \
    >> stat.md

cat stat.md

```

| Name            |   N50 |      Sum |    # |
|:----------------|------:|---------:|-----:|
| Genome          | 48502 |    48502 |    1 |
| PacBio          |  1325 | 11945526 | 9796 |
| PacBio.40x      |  1365 |  1896887 | 1500 |
| PacBio.40x.trim |  1452 |  1509584 | 1054 |

## lambda: 3GS

* miniasm

```bash
BASE_NAME=lambda
cd ${HOME}/data/anchr/${BASE_NAME}

mkdir -p miniasm

minimap -Sw5 -L100 -m0 -t16 \
    ~/data/anchr/e_coli/anchorLong/group/11_2.long.fasta ~/data/anchr/e_coli/anchorLong/group/11_2.long.fasta \
    > miniasm/pacbio.40x.paf

sftp://wangq@wq.nju.edu.cn

miniasm miniasm/pacbio.40x.paf > miniasm/utg.noseq.gfa

miniasm -f 3_pacbio/pacbio.40x.fasta miniasm/pacbio.40x.paf \
    > miniasm/utg.gfa

awk '/^S/{print ">"$2"\n"$3}' miniasm/utg.gfa > miniasm/utg.fa

minimap 1_genome/genome.fa miniasm/utg.fa | minidot - > miniasm/utg.eps

```

