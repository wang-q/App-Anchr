# Assemble genomes of model organisms by ANCHR

[TOC levels=1-3]: # " "
- [Assemble genomes of model organisms by ANCHR](#assemble-genomes-of-model-organisms-by-anchr)
- [Extra external dependencies](#extra-external-dependencies)
- [*Escherichia coli* str. K-12 substr. MG1655](#escherichia-coli-str-k-12-substr-mg1655)
    - [*E. coli*: download](#e-coli-download)
    - [*E. coli*: trim/filter](#e-coli-trimfilter)
    - [*E. coli*: down sampling](#e-coli-down-sampling)
    - [*E. coli*: generate super-reads](#e-coli-generate-super-reads)
    - [*E. coli*: create anchors](#e-coli-create-anchors)
    - [*E. coli*: results](#e-coli-results)
    - [*E. coli*: quality assessment](#e-coli-quality-assessment)
- [*Saccharomyces cerevisiae* S288c](#saccharomyces-cerevisiae-s288c)
    - [Scer: download](#scer-download)
    - [Scer: trim](#scer-trim)
    - [Scer: down sampling](#scer-down-sampling)
    - [Scer: generate super-reads](#scer-generate-super-reads)
    - [Scer: create anchors](#scer-create-anchors)
    - [Scer: results](#scer-results)
    - [Scer: quality assessment](#scer-quality-assessment)

# Extra external dependencies

```bash
brew tap homebrew/science

brew install sratoolkit

brew install gd --without-webp # broken, can't find libwebp.so.6
brew install homebrew/versions/gnuplot4
brew install mummer # mummer need gnuplot4

brew install quast
```

# *Escherichia coli* str. K-12 substr. MG1655

* Genome: INSDC [U00096.3](https://www.ncbi.nlm.nih.gov/nuccore/U00096.3)
* Proportion of paralogs: 0.0323

* Real:

    * S: 4,641,652

* Original:

    * N50: 151
    * S: 865,149,970
    * C: 5,729,470

* Trimmed, 120-151 bp

    * N50: 151
    * S: 577,015,664
    * C: 3,871,229

* Filter, 151 bp

    * N50: 151
    * S: 371,039,918
    * C: 2,457,218

## *E. coli*: download

```bash
# genome
mkdir -p ~/data/anchr/e_coli/1_genome
cd ~/data/anchr/e_coli/1_genome
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=U00096.3&rettype=fasta&retmode=txt" \
    > U00096.fa
# simplify header, remove .3
cat U00096.fa \
    | perl -nl -e '
        /^>(\w+)/ and print qq{>$1} and next;
        print;
    ' \
    > genome.fa

# illumina
mkdir -p ~/data/anchr/e_coli/2_illumina
cd ~/data/anchr/e_coli/2_illumina
wget -N ftp://webdata:webdata@ussd-ftp.illumina.com/Data/SequencingRuns/MG1655/MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz
wget -N ftp://webdata:webdata@ussd-ftp.illumina.com/Data/SequencingRuns/MG1655/MiSeq_Ecoli_MG1655_110721_PF_R2.fastq.gz

ln -s MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz R1.fq.gz
ln -s MiSeq_Ecoli_MG1655_110721_PF_R2.fastq.gz R2.fq.gz

# pacbio
mkdir -p ~/data/anchr/e_coli/3_pacbio
```

## *E. coli*: trim/filter

* Trimmed: minimal length 120 bp.

```bash
mkdir -p ~/data/anchr/e_coli/2_illumina/trimmed
cd ~/data/anchr/e_coli/2_illumina/trimmed

anchr trim \
    -l 120 -q 20 \
    ../R1.fq.gz ../R2.fq.gz \
    -o stdout \
    | bash
```

* Filter: discard any reads with trimmed parts.

```bash
mkdir -p ~/data/anchr/e_coli/2_illumina/filter
cd ~/data/anchr/e_coli/2_illumina/filter

anchr trim \
    -l 151 -q 20 \
    ../R1.fq.gz ../R2.fq.gz \
    -o stdout \
    | bash
```

* Stats

```bash
cd ~/data/anchr/e_coli

faops n50 -S -C 1_genome/genome.fa
faops n50 -S -C 2_illumina/R1.fq.gz
faops n50 -S -C 2_illumina/trimmed/R1.fq.gz
faops n50 -S -C 2_illumina/filter/R1.fq.gz
```

## *E. coli*: down sampling

过高的 coverage 会造成不好的影响. SGA 的文档里也说了类似的事情.

> Very highly-represented sequences (>1000X) can cause problems for SGA... In these cases, it is
> worth considering pre-filtering the data...

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

# works on bash 3
ARRAY=( "2_illumina:original:5000000"
        "2_illumina/trimmed:trimmed:3800000"
        "2_illumina/filter:filter:2400000")

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    GROUP_MAX=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[2];')
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    for count in $(perl -e 'print 200000 * $_, q{ } for 1 .. 25');
    do
        if [[ "$count" -gt "$GROUP_MAX" ]]; then
            continue     
        fi
        
        echo "==> Reads ${GROUP_ID}_${count}"
        DIR_COUNT="${BASE_DIR}/${GROUP_ID}_${count}"
        mkdir -p ${DIR_COUNT}
        
        if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
            continue     
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

## *E. coli*: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

for d in $(perl -e 'for $n (qw{original trimmed filter}) { for $i (1 .. 25) { printf qq{%s_%d }, $n, (200000 * $i); } }');
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"

    if [ ! -d ${DIR_COUNT} ]; then
        continue
    fi
    
    if [ -e ${DIR_COUNT}/pe.cor.fa ]; then
        echo "    pe.cor.fa already presents"
        continue
    fi
    
    pushd ${DIR_COUNT} > /dev/null
    anchr superreads \
        R1.fq.gz \
        R2.fq.gz \
        -s 300 -d 30 -p 16
    bash superreads.sh
    popd > /dev/null
done
```

Clear intermediate files.

```bash
# masurca
cd $HOME/data/anchr/e_coli

find . -type f -name "quorum_mer_db.jf" | xargs rm
find . -type f -name "k_u_hash_0" | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp" | xargs rm
#find . -type f -name "pe.renamed.fastq" | xargs rm
```

## *E. coli*: create anchors

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

for d in $(perl -e 'for $n (qw{original trimmed filter}) { for $i (1 .. 25) { printf qq{%s_%d }, $n, (200000 * $i); } }');
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue
    fi
    
    rm -fr ${DIR_COUNT}/sr
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh ${DIR_COUNT} 16 false 120
done
```

## *E. coli*: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

REAL_G=4641652

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

for d in $(perl -e 'for $n (qw{original trimmed filter}) { for $i (1 .. 25) { printf qq{%s_%d }, $n, (200000 * $i); } }');
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -d ${DIR_COUNT} ]; then
        continue     
    fi
    
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${DIR_COUNT} ${REAL_G} \
        >> ${BASE_DIR}/stat1.md
done

cat stat1.md
```

* Stats of anchors

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

for d in $(perl -e 'for $n (qw{original trimmed filter}) { for $i (1 .. 25) { printf qq{%s_%d }, $n, (200000 * $i); } }');
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue     
    fi
    
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${DIR_COUNT} \
        >> ${BASE_DIR}/stat2.md

done

cat stat2.md
```

| Name             |   SumFq | CovFq | AvgRead | Kmer |   SumFa | Discard% |   #Subs |  Subs% | RealG |  EstG | Est/Real |  SumSR | SR/Real | SR/Est |   RunTime |
|:-----------------|--------:|------:|--------:|-----:|--------:|---------:|--------:|-------:|------:|------:|---------:|-------:|--------:|-------:|----------:|
| original_200000  |   60.4M |  13.0 |     151 |   75 |  59.51M |   1.471% | 330.39K | 0.555% | 4.64M | 4.57M |     0.98 |  5.71M |    1.23 |   1.25 | 0:00'27'' |
| original_400000  |  120.8M |  26.0 |     151 |   75 | 119.07M |   1.435% | 659.18K | 0.554% | 4.64M | 4.64M |     1.00 | 10.24M |    2.21 |   2.21 | 0:00'38'' |
| original_600000  |  181.2M |  39.0 |     151 |   75 | 178.64M |   1.414% | 984.55K | 0.551% | 4.64M | 4.72M |     1.02 | 10.98M |    2.37 |   2.33 | 0:00'50'' |
| original_800000  |  241.6M |  52.1 |     151 |   75 | 238.23M |   1.396% |    1.3M | 0.546% | 4.64M | 4.82M |     1.04 | 11.65M |    2.51 |   2.42 | 0:01'02'' |
| original_1000000 |    302M |  65.1 |     151 |   75 | 297.81M |   1.387% |   1.62M | 0.544% | 4.64M | 4.94M |     1.06 | 12.25M |    2.64 |   2.48 | 0:01'15'' |
| original_1200000 |  362.4M |  78.1 |     151 |   75 | 357.42M |   1.374% |   1.93M | 0.540% | 4.64M | 5.06M |     1.09 | 12.86M |    2.77 |   2.54 | 0:01'30'' |
| original_1400000 |  422.8M |  91.1 |     151 |   75 | 417.02M |   1.366% |   2.24M | 0.536% | 4.64M | 5.19M |     1.12 | 13.35M |    2.88 |   2.57 | 0:01'45'' |
| original_1600000 |  483.2M | 104.1 |     151 |   75 | 476.61M |   1.364% |   2.55M | 0.534% | 4.64M | 5.33M |     1.15 | 14.03M |    3.02 |   2.63 | 0:01'54'' |
| original_1800000 |  543.6M | 117.1 |     151 |   75 | 536.19M |   1.363% |   2.85M | 0.531% | 4.64M | 5.47M |     1.18 |  14.6M |    3.15 |   2.67 | 0:02'09'' |
| original_2000000 |    604M | 130.1 |     151 |   75 | 595.79M |   1.360% |   3.15M | 0.529% | 4.64M | 5.63M |     1.21 | 15.31M |    3.30 |   2.72 | 0:02'23'' |
| original_2200000 |  664.4M | 143.1 |     151 |   75 | 655.37M |   1.359% |   3.45M | 0.526% | 4.64M | 5.79M |     1.25 | 15.77M |    3.40 |   2.72 | 0:02'41'' |
| original_2400000 |  724.8M | 156.2 |     151 |   75 | 715.01M |   1.350% |   3.74M | 0.524% | 4.64M | 5.96M |     1.28 | 16.45M |    3.54 |   2.76 | 0:02'58'' |
| original_2600000 |  785.2M | 169.2 |     151 |   75 | 774.58M |   1.352% |   4.04M | 0.522% | 4.64M | 6.13M |     1.32 | 16.91M |    3.64 |   2.76 | 0:03'13'' |
| original_2800000 |  845.6M | 182.2 |     151 |   75 | 834.15M |   1.354% |   4.34M | 0.521% | 4.64M | 6.32M |     1.36 | 17.58M |    3.79 |   2.78 | 0:03'29'' |
| original_3000000 |    906M | 195.2 |     151 |   75 | 893.76M |   1.351% |   4.62M | 0.517% | 4.64M |  6.5M |     1.40 | 18.24M |    3.93 |   2.81 | 0:03'43'' |
| original_3200000 |  966.4M | 208.2 |     151 |   75 | 953.35M |   1.350% |   4.92M | 0.516% | 4.64M | 6.69M |     1.44 | 18.94M |    4.08 |   2.83 | 0:03'55'' |
| original_3400000 |   1.03G | 221.2 |     151 |   75 |   1.01G |   1.347% |    5.2M | 0.513% | 4.64M | 6.89M |     1.48 | 19.47M |    4.20 |   2.83 | 0:04'14'' |
| original_3600000 |   1.09G | 234.2 |     151 |   75 |   1.07G |   1.347% |   5.49M | 0.512% | 4.64M |  7.1M |     1.53 | 20.25M |    4.36 |   2.85 | 0:04'27'' |
| original_3800000 |   1.15G | 247.2 |     151 |   75 |   1.13G |   1.348% |   5.77M | 0.510% | 4.64M |  7.3M |     1.57 | 21.01M |    4.53 |   2.88 | 0:04'51'' |
| original_4000000 |   1.21G | 260.3 |     151 |   75 |   1.19G |   1.344% |   6.05M | 0.508% | 4.64M |  7.5M |     1.62 | 21.81M |    4.70 |   2.91 | 0:05'02'' |
| original_4200000 |   1.27G | 273.3 |     151 |   75 |   1.25G |   1.346% |   6.33M | 0.506% | 4.64M | 7.72M |     1.66 |  22.7M |    4.89 |   2.94 | 0:05'23'' |
| original_4400000 |   1.33G | 286.3 |     151 |   75 |   1.31G |   1.346% |   6.62M | 0.505% | 4.64M | 7.94M |     1.71 | 23.58M |    5.08 |   2.97 | 0:05'37'' |
| original_4600000 |   1.39G | 299.3 |     151 |   75 |   1.37G |   1.346% |   6.89M | 0.503% | 4.64M | 8.17M |     1.76 | 24.55M |    5.29 |   3.00 | 0:05'54'' |
| original_4800000 |   1.45G | 312.3 |     151 |   75 |   1.43G |   1.347% |   7.16M | 0.501% | 4.64M |  8.4M |     1.81 | 25.53M |    5.50 |   3.04 | 0:06'17'' |
| original_5000000 |   1.51G | 325.3 |     151 |   75 |   1.49G |   1.347% |   7.44M | 0.499% | 4.64M | 8.64M |     1.86 | 26.67M |    5.75 |   3.09 | 0:06'26'' |
| trimmed_200000   |   58.8M |  12.7 |     147 |  105 |  58.75M |   0.086% |  56.34K | 0.096% | 4.64M | 4.49M |     0.97 |  5.12M |    1.10 |   1.14 | 0:00'33'' |
| trimmed_400000   |  117.6M |  25.3 |     147 |  105 | 117.51M |   0.071% | 111.83K | 0.095% | 4.64M | 4.54M |     0.98 |  4.93M |    1.06 |   1.08 | 0:00'45'' |
| trimmed_600000   | 176.41M |  38.0 |     146 |  105 | 176.28M |   0.072% | 168.16K | 0.095% | 4.64M | 4.56M |     0.98 |  4.88M |    1.05 |   1.07 | 0:00'59'' |
| trimmed_800000   | 235.18M |  50.7 |     146 |  105 | 235.01M |   0.072% | 223.33K | 0.095% | 4.64M | 4.56M |     0.98 |  4.97M |    1.07 |   1.09 | 0:01'14'' |
| trimmed_1000000  |    294M |  63.3 |     146 |  105 | 293.79M |   0.070% | 279.12K | 0.095% | 4.64M | 4.56M |     0.98 |  5.16M |    1.11 |   1.13 | 0:01'24'' |
| trimmed_1200000  | 352.78M |  76.0 |     146 |  105 | 352.53M |   0.071% | 335.28K | 0.095% | 4.64M | 4.57M |     0.98 |  5.26M |    1.13 |   1.15 | 0:01'29'' |
| trimmed_1400000  | 411.56M |  88.7 |     146 |  105 | 411.26M |   0.072% | 391.04K | 0.095% | 4.64M | 4.57M |     0.99 |  5.63M |    1.21 |   1.23 | 0:01'45'' |
| trimmed_1600000  | 470.38M | 101.3 |     146 |  105 | 470.05M |   0.070% | 445.56K | 0.095% | 4.64M | 4.58M |     0.99 |   5.9M |    1.27 |   1.29 | 0:02'02'' |
| trimmed_1800000  | 529.16M | 114.0 |     146 |  105 | 528.78M |   0.071% | 499.33K | 0.094% | 4.64M | 4.59M |     0.99 |  6.34M |    1.37 |   1.38 | 0:02'07'' |
| trimmed_2000000  | 587.96M | 126.7 |     146 |  105 | 587.54M |   0.071% | 555.07K | 0.094% | 4.64M | 4.59M |     0.99 |   6.8M |    1.47 |   1.48 | 0:02'21'' |
| trimmed_2200000  | 646.77M | 139.3 |     146 |  105 |  646.3M |   0.072% | 611.18K | 0.095% | 4.64M |  4.6M |     0.99 |   7.1M |    1.53 |   1.54 | 0:02'28'' |
| trimmed_2400000  | 705.55M | 152.0 |     146 |  105 | 705.03M |   0.074% | 665.83K | 0.094% | 4.64M | 4.61M |     0.99 |  7.38M |    1.59 |   1.60 | 0:02'56'' |
| trimmed_2600000  | 764.34M | 164.7 |     146 |  105 | 763.78M |   0.074% | 720.05K | 0.094% | 4.64M | 4.61M |     0.99 |  7.79M |    1.68 |   1.69 | 0:02'52'' |
| trimmed_2800000  | 823.16M | 177.3 |     145 |  101 | 822.55M |   0.075% | 773.45K | 0.094% | 4.64M | 4.62M |     1.00 |   8.4M |    1.81 |   1.82 | 0:03'04'' |
| trimmed_3000000  | 881.92M | 190.0 |     145 |  101 | 881.26M |   0.075% | 827.23K | 0.094% | 4.64M | 4.63M |     1.00 |  8.49M |    1.83 |   1.83 | 0:03'16'' |
| trimmed_3200000  | 940.74M | 202.7 |     145 |  101 | 940.02M |   0.077% | 881.84K | 0.094% | 4.64M | 4.64M |     1.00 |   8.7M |    1.87 |   1.87 | 0:03'32'' |
| trimmed_3400000  | 999.54M | 215.3 |     145 |   99 | 998.77M |   0.077% | 934.24K | 0.094% | 4.64M | 4.65M |     1.00 |  8.98M |    1.93 |   1.93 | 0:03'54'' |
| trimmed_3600000  |   1.06G | 228.0 |     145 |   99 |   1.06G |   0.078% |  988.7K | 0.093% | 4.64M | 4.67M |     1.01 |  9.11M |    1.96 |   1.95 | 0:03'54'' |
| trimmed_3800000  |   1.12G | 240.7 |     145 |   97 |   1.12G |   0.079% |   1.04M | 0.093% | 4.64M | 4.68M |     1.01 |  9.29M |    2.00 |   1.99 | 0:04'13'' |
| filter_200000    |   60.4M |  13.0 |     151 |  105 |  60.34M |   0.093% |  56.92K | 0.094% | 4.64M | 4.38M |     0.94 |  4.73M |    1.02 |   1.08 | 0:00'36'' |
| filter_400000    |  120.8M |  26.0 |     151 |  105 | 120.71M |   0.075% | 113.84K | 0.094% | 4.64M |  4.5M |     0.97 |  4.81M |    1.04 |   1.07 | 0:00'46'' |
| filter_600000    |  181.2M |  39.0 |     151 |  105 | 181.06M |   0.076% | 172.33K | 0.095% | 4.64M | 4.53M |     0.98 |  4.82M |    1.04 |   1.07 | 0:01'20'' |
| filter_800000    |  241.6M |  52.1 |     151 |  105 | 241.43M |   0.072% | 229.13K | 0.095% | 4.64M | 4.54M |     0.98 |  4.87M |    1.05 |   1.07 | 0:01'16'' |
| filter_1000000   |    302M |  65.1 |     151 |  105 | 301.79M |   0.070% | 285.75K | 0.095% | 4.64M | 4.55M |     0.98 |  4.94M |    1.07 |   1.09 | 0:01'16'' |
| filter_1200000   |  362.4M |  78.1 |     151 |  105 | 362.15M |   0.070% | 343.66K | 0.095% | 4.64M | 4.55M |     0.98 |  5.03M |    1.08 |   1.11 | 0:01'38'' |
| filter_1400000   |  422.8M |  91.1 |     151 |  105 |  422.5M |   0.072% |  399.5K | 0.095% | 4.64M | 4.56M |     0.98 |  5.13M |    1.11 |   1.13 | 0:01'49'' |
| filter_1600000   |  483.2M | 104.1 |     151 |  105 | 482.85M |   0.072% |  456.8K | 0.095% | 4.64M | 4.57M |     0.98 |   5.3M |    1.14 |   1.16 | 0:02'03'' |
| filter_1800000   |  543.6M | 117.1 |     151 |  105 | 543.22M |   0.071% | 513.77K | 0.095% | 4.64M | 4.57M |     0.98 |  5.55M |    1.19 |   1.21 | 0:02'19'' |
| filter_2000000   |    604M | 130.1 |     151 |  105 | 603.57M |   0.071% | 569.58K | 0.094% | 4.64M | 4.57M |     0.99 |  5.73M |    1.23 |   1.25 | 0:02'35'' |
| filter_2200000   |  664.4M | 143.1 |     151 |  105 | 663.93M |   0.071% |    626K | 0.094% | 4.64M | 4.58M |     0.99 |   6.1M |    1.31 |   1.33 | 0:02'27'' |
| filter_2400000   |  724.8M | 156.2 |     151 |  105 | 724.28M |   0.071% |  681.8K | 0.094% | 4.64M | 4.59M |     0.99 |  6.46M |    1.39 |   1.41 | 0:02'39'' |


* Illumina reads 的分布是有偏性的. 极端 GC 区域, 结构复杂区域都会得到较低的 fq 分值, 本应被 trim 掉.
  但覆盖度过高时, 这些区域之间的 reads 相互支持, 被保留下来的概率大大增加.
    * Discard% 在 CovFq 大于 100 倍时, 快速下降.
* Illumina reads 错误率约为 1% 不到一点. 当覆盖度过高时, 错误的点重复出现的概率要比完全无偏性的情况大一些.
    * 理论上 Subs% 应该是恒定值, 但当 CovFq 大于 100 倍时, 这个值在下降, 也就是这些错误的点相互支持, 躲过了
      Kmer 纠错.
* 直接的反映就是 EstG 过大, SumSR 过大.
* 留下的错误片段, 会形成 **伪独立** 片段, 降低 N50 SR
* 留下的错误位点, 会形成 **伪杂合** 位点, 降低 N50 SR
* trim 的效果比 filter 好. 可能是留下了更多二代测序效果较差的位置. 同样 2400000 对 reads, trim 的 EstG
  更接近真实值
    * Real - 4.64M
    * Trimmed - 4.61M (EstG)
    * Filter - 4.59M (EstG)

| Name             | strict% | N50SRclean |   Sum |    # | N50Anchor |     Sum |    # | N50Anchor2 |     Sum |   # | N50Others |     Sum |    # |   RunTime |
|:-----------------|--------:|-----------:|------:|-----:|----------:|--------:|-----:|-----------:|--------:|----:|----------:|--------:|-----:|----------:|
| original_200000  |  64.08% |       6053 | 4.82M | 1204 |      6640 |   3.08M |  605 |       5697 |   1.25M | 296 |      2387 | 482.85K |  303 | 0:01'13'' |
| original_400000  |  64.14% |       5870 | 6.55M | 1474 |      7325 | 944.29K |  152 |       6892 |   2.37M | 393 |      4640 |   3.24M |  929 | 0:01'34'' |
| original_600000  |  64.16% |       3573 | 6.68M | 2332 |      6155 | 894.13K |  187 |       4739 |   1.73M | 407 |      2873 |   4.06M | 1738 | 0:01'47'' |
| original_800000  |  64.33% |       2619 | 6.85M | 3131 |      4089 |  604.9K |  179 |       3761 |   1.51M | 446 |      2217 |   4.73M | 2506 | 0:01'59'' |
| original_1000000 |  64.42% |       2160 | 6.92M | 3773 |      4038 | 520.03K |  165 |       3257 |    1.2M | 403 |      1915 |    5.2M | 3205 | 0:02'14'' |
| original_1200000 |  64.58% |       1870 | 6.88M | 4298 |      3253 | 578.58K |  221 |       2838 | 952.28K | 356 |      1650 |   5.35M | 3721 | 0:02'29'' |
| original_1400000 |  64.69% |       1657 | 7.03M | 4886 |      2718 | 457.77K |  193 |       2688 | 825.45K | 337 |      1492 |   5.75M | 4356 | 0:02'44'' |
| original_1600000 |  64.74% |       1493 | 6.93M | 5259 |      2429 | 480.63K |  224 |       2552 | 739.22K | 306 |      1338 |   5.71M | 4729 | 0:02'56'' |
| original_1800000 |  64.87% |       1359 | 7.01M | 5759 |      1973 | 409.17K |  211 |       2347 | 639.23K | 276 |      1244 |   5.96M | 5272 | 0:03'09'' |
| original_2000000 |  64.93% |       1239 | 6.98M | 6152 |      1784 | 305.93K |  175 |       2290 | 479.01K | 211 |      1167 |    6.2M | 5766 | 0:03'16'' |
| original_2200000 |  65.04% |       1151 | 7.03M | 6568 |      1702 |  278.6K |  166 |       2226 | 388.67K | 180 |      1092 |   6.37M | 6222 | 0:03'25'' |
| original_2400000 |  65.15% |       1048 | 7.01M | 7019 |      1655 | 244.96K |  147 |       2098 | 333.09K | 161 |       996 |   6.43M | 6711 | 0:03'37'' |
| original_2600000 |  65.22% |       1003 | 7.07M | 7369 |      1501 | 187.96K |  121 |       1939 | 247.48K | 130 |       969 |   6.63M | 7118 | 0:03'50'' |
| original_2800000 |  65.29% |        934 | 7.08M | 7781 |      1417 | 164.01K |  112 |       1858 | 223.63K | 112 |       906 |   6.69M | 7557 | 0:04'02'' |
| original_3000000 |  65.41% |        872 | 7.13M | 8210 |      1405 | 134.38K |   94 |       1874 | 166.53K |  88 |       856 |   6.83M | 8028 | 0:04'12'' |
| original_3200000 |  65.47% |        842 | 6.99M | 8376 |      1239 | 120.99K |   91 |       1675 | 131.55K |  73 |       825 |   6.74M | 8212 | 0:04'13'' |
| original_3400000 |  65.59% |        807 | 7.05M | 8792 |      1443 |  84.89K |   58 |       1811 |  98.36K |  52 |       795 |   6.87M | 8682 | 0:04'29'' |
| original_3600000 |  65.67% |        776 | 6.96M | 8957 |      1306 |  76.54K |   58 |       1741 |  66.46K |  38 |       768 |   6.82M | 8861 | 0:04'35'' |
| original_3800000 |  65.74% |        743 | 6.91M | 9165 |      1193 |  55.05K |   43 |       1681 |  49.01K |  29 |       737 |    6.8M | 9093 | 0:04'40'' |
| original_4000000 |  65.83% |        717 | 6.75M | 9229 |      1137 |  41.05K |   33 |       1671 |  34.54K |  21 |       714 |   6.67M | 9175 | 0:04'50'' |
| original_4200000 |  65.91% |        696 | 6.58M | 9231 |      1297 |  33.27K |   26 |       1654 |     27K |  15 |       694 |   6.52M | 9190 | 0:04'59'' |
| original_4400000 |  65.99% |        675 | 6.47M | 9351 |      1373 |  27.72K |   20 |       1725 |  11.71K |   7 |       673 |   6.43M | 9324 | 0:05'10'' |
| original_4600000 |  66.09% |        661 | 6.23M | 9183 |      1194 |  18.57K |   15 |       1549 |   4.39K |   3 |       660 |   6.21M | 9165 | 0:05'14'' |
| original_4800000 |  66.17% |        640 | 6.01M | 9088 |      1126 |  16.63K |   13 |       1871 |   9.99K |   6 |       639 |   5.99M | 9069 | 0:05'22'' |
| original_5000000 |  66.25% |        629 | 5.78M | 8876 |      1088 |  12.43K |   11 |       1945 |   1.95K |   1 |       629 |   5.77M | 8864 | 0:05'30'' |
| trimmed_200000   |  87.41% |       1012 |  3.2M | 3310 |      1538 |   1.44M |  921 |       1471 |  82.34K |  53 |       745 |   1.68M | 2336 | 0:01'08'' |
| trimmed_400000   |  87.51% |       3189 | 4.49M | 2003 |      3494 |   3.74M | 1295 |       4693 |  240.7K |  68 |       804 | 509.74K |  640 | 0:01'32'' |
| trimmed_600000   |  87.51% |       6287 | 4.62M | 1181 |      6606 |   4.06M |  859 |       6108 | 306.18K |  64 |       883 | 252.55K |  258 | 0:01'50'' |
| trimmed_800000   |  87.54% |       8696 | 4.66M |  910 |      9113 |   4.06M |  667 |       7575 | 417.14K |  69 |       951 |  181.6K |  174 | 0:02'01'' |
| trimmed_1000000  |  87.54% |      10475 |  4.7M |  746 |     10498 |      4M |  562 |      10568 | 545.87K |  76 |      2086 |  152.2K |  108 | 0:02'21'' |
| trimmed_1200000  |  87.53% |      11605 | 4.75M |  692 |     11978 |   3.93M |  501 |      11085 | 649.04K |  79 |      3355 | 179.28K |  112 | 0:02'46'' |
| trimmed_1400000  |  87.53% |      12763 | 4.85M |  627 |     12294 |   3.61M |  422 |      17578 | 984.97K |  98 |     11574 | 263.69K |  107 | 0:03'02'' |
| trimmed_1600000  |  87.56% |      12918 | 4.98M |  623 |     12480 |   3.41M |  391 |      14272 |   1.23M | 114 |     10685 | 349.46K |  118 | 0:03'15'' |
| trimmed_1800000  |  87.61% |      12332 | 5.19M |  673 |     12059 |   3.08M |  378 |      12824 |    1.5M | 150 |     11676 | 612.78K |  145 | 0:03'25'' |
| trimmed_2000000  |  87.61% |      11370 | 5.48M |  714 |     11388 |    2.6M |  328 |      11923 |   1.95M | 193 |      9638 | 928.27K |  193 | 0:03'50'' |
| trimmed_2200000  |  87.59% |      10636 | 5.51M |  771 |     11212 |    2.4M |  306 |      11051 |   2.06M | 226 |      8343 |   1.05M |  239 | 0:04'03'' |
| trimmed_2400000  |  87.60% |       9124 | 5.73M |  865 |     10202 |   2.22M |  298 |       9969 |   2.13M | 261 |      7458 |   1.38M |  306 | 0:04'08'' |
| trimmed_2600000  |  87.62% |       8455 | 6.02M |  989 |      9312 |   1.79M |  261 |       8779 |   2.43M | 329 |      6943 |   1.79M |  399 | 0:04'24'' |
| trimmed_2800000  |  87.64% |       7816 | 6.37M | 1095 |      9077 |   1.39M |  210 |       8270 |   2.77M | 386 |      6618 |   2.22M |  499 | 0:04'30'' |
| trimmed_3000000  |  87.66% |       6557 | 6.46M | 1264 |      8264 |   1.26M |  203 |       7701 |   2.65M | 406 |      5147 |   2.55M |  655 | 0:04'43'' |
| trimmed_3200000  |  87.67% |       6150 | 6.71M | 1459 |      7627 |   1.04M |  182 |       6940 |   2.61M | 430 |      4875 |   3.07M |  847 | 0:04'54'' |
| trimmed_3400000  |  87.70% |       5364 | 7.05M | 1656 |      7002 | 857.15K |  173 |       6554 |   2.41M | 424 |      4448 |   3.79M | 1059 | 0:05'22'' |
| trimmed_3600000  |  87.70% |       4707 | 7.11M | 1876 |      5785 | 706.19K |  159 |       6048 |   2.36M | 449 |      3924 |   4.04M | 1268 | 0:05'37'' |
| trimmed_3800000  |  87.71% |       4289 | 7.25M | 2078 |      5518 |  723.8K |  167 |       5856 |   2.15M | 428 |      3514 |   4.37M | 1483 | 0:05'46'' |
| filter_200000    |  87.34% |       1168 | 3.26M | 3037 |      1731 |   1.64M |  942 |       1749 | 178.01K |  98 |       737 |   1.44M | 1997 | 0:01'07'' |
| filter_400000    |  87.32% |       2711 | 4.32M | 2179 |      3221 |   3.42M | 1271 |       4025 | 282.73K |  91 |       781 | 623.37K |  817 | 0:01'36'' |
| filter_600000    |  87.21% |       4358 | 4.51M | 1591 |      4839 |   3.87M | 1078 |       4276 | 287.44K |  81 |       800 | 344.21K |  432 | 0:01'49'' |
| filter_800000    |  87.24% |       5948 | 4.58M | 1285 |      6337 |   4.03M |  912 |       4588 | 267.68K |  66 |       855 |  281.5K |  307 | 0:02'03'' |
| filter_1000000   |  87.27% |       6778 | 4.61M | 1120 |      7186 |    4.1M |  818 |       5465 | 259.71K |  60 |       897 | 247.67K |  242 | 0:02'22'' |
| filter_1200000   |  87.24% |       7672 | 4.64M | 1006 |      8044 |   4.06M |  745 |       6252 | 369.37K |  64 |       954 | 216.36K |  197 | 0:02'40'' |
| filter_1400000   |  87.27% |       7950 | 4.68M |  961 |      8396 |   4.01M |  703 |       7121 |  434.1K |  77 |      1416 | 233.34K |  181 | 0:02'58'' |
| filter_1600000   |  87.28% |       8522 | 4.79M |  928 |      8532 |   3.75M |  642 |       8439 | 720.05K | 109 |      4726 | 322.59K |  177 | 0:03'13'' |
| filter_1800000   |  87.28% |       8903 | 4.91M |  904 |      8730 |   3.46M |  580 |      10655 |   1.13M | 139 |      3987 | 318.23K |  185 | 0:03'25'' |
| filter_2000000   |  87.30% |       8473 | 4.96M |  927 |      8462 |    3.4M |  566 |       9368 |   1.14M | 149 |      4394 | 427.02K |  212 | 0:03'41'' |
| filter_2200000   |  87.32% |       8666 | 5.14M |  945 |      8666 |   3.02M |  511 |       9207 |   1.45M | 192 |      7343 | 677.79K |  242 | 0:04'05'' |
| filter_2400000   |  87.33% |       7851 | 5.26M | 1001 |      7964 |   2.73M |  481 |       9277 |   1.77M | 246 |      5905 |  757.9K |  274 | 0:04'14'' |

## *E. coli*: quality assessment

http://www.opiniomics.org/generate-a-single-contig-hybrid-assembly-of-e-coli-using-miseq-and-minion-data/

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

for part in anchor anchor2 others;
do 
    bash ~/Scripts/cpan/App-Anchr/share/sort_on_ref.sh trimmed_800000/sr/pe.${part}.fa 1_genome/genome.fa pe.${part}
    nucmer -l 200 1_genome/genome.fa pe.${part}.fa
    mummerplot -png out.delta -p pe.${part} --medium
done

cp ~/data/alignment/self/ecoli/Results/MG1655/MG1655.multi.fas paralog.fasta

cp ~/data/pacbio/ecoli_p6c4/2-asm-falcon/p_ctg.fa falcon.fa

nucmer -l 200 NC_000913.fa falcon.fa
mummerplot -png out.delta -p falcon --medium

# mummerplot files
rm *.[fr]plot
rm out.delta
rm *.gp
```

# *Saccharomyces cerevisiae* S288c

* Genome: [Ensembl 82](http://sep2015.archive.ensembl.org/Saccharomyces_cerevisiae/Info/Index)
* Proportion of paralogs: 0.058

* Real:

    * N50: 924431
    * S: 12,157,105
    * C: 17

* Original:

    * N50: 151
    * S: 1,469,540,607
    * C: 9,732,057

* Trimmed:

    * N50: 151
    * S: 1,335,844,095
    * C: 8,876,935

## Scer: download

```bash
# genome
mkdir -p ~/data/anchr/s288c/1_genome
cd ~/data/anchr/s288c/1_genome
wget -N ftp://ftp.ensembl.org/pub/release-82/fasta/saccharomyces_cerevisiae/dna/Saccharomyces_cerevisiae.R64-1-1.dna_sm.toplevel.fa.gz
faops order Saccharomyces_cerevisiae.R64-1-1.dna_sm.toplevel.fa.gz \
    <(for chr in {I,II,III,IV,V,VI,VII,VIII,IX,X,XI,XII,XIII,XIV,XV,XVI,Mito}; do echo $chr; done) \
    genome.fa

# illumina
# ENA hasn't synced with SRA for PRJNA340312
# Downloading with prefetch from sratoolkit
mkdir -p ~/data/anchr/s288c/2_illumina
cd ~/data/anchr/s288c/2_illumina
prefetch --progress 0.5 SRR4074255
fastq-dump --split-files SRR4074255  
find . -name "*.fastq" | parallel -j 2 pigz -p 8

ln -s SRR4074255_1.fastq.gz R1.fq.gz
ln -s SRR4074255_2.fastq.gz R2.fq.gz

# pacbio
mkdir -p ~/data/anchr/s288c/3_pacbio
```

## Scer: trim

* Trimmed: minimal length 120 bp.

```bash
mkdir -p ~/data/anchr/s288c/2_illumina/trimmed
cd ~/data/anchr/s288c/2_illumina/trimmed

anchr trim \
    -l 120 -q 20 \
    ../R1.fq.gz ../R2.fq.gz \
    -o stdout \
    | bash
```

* Stats

```bash
cd ~/data/anchr/s288c

faops n50 -S -C 1_genome/genome.fa
faops n50 -S -C 2_illumina/R1.fq.gz
faops n50 -S -C 2_illumina/trimmed/R1.fq.gz
```

## Scer: down sampling

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

# works on bash 3
ARRAY=( "2_illumina/trimmed:trimmed:8000000")

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    GROUP_MAX=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[2];')
    printf "==> %s \t %s \t %s\n" "$GROUP_DIR" "$GROUP_ID" "$GROUP_MAX"

    for count in $(perl -e 'print 1000000 * $_, q{ } for 1 .. 8');
    do
        if [[ "$count" -gt "$GROUP_MAX" ]]; then
            continue     
        fi
        
        echo "==> Reads ${GROUP_ID}_${count}"
        DIR_COUNT="${BASE_DIR}/${GROUP_ID}_${count}"
        mkdir -p ${DIR_COUNT}
        
        if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
            continue     
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

## Scer: generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

for d in $(perl -e 'for $n (qw{trimmed}) { for $i (1 .. 8) { printf qq{%s_%d }, $n, (1000000 * $i); } }');
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"

    if [ ! -d ${DIR_COUNT} ]; then
        continue
    fi
    
    if [ -e ${DIR_COUNT}/pe.cor.fa ]; then
        echo "    pe.cor.fa already presents"
        continue
    fi
    
    pushd ${DIR_COUNT} > /dev/null
    anchr superreads \
        R1.fq.gz \
        R2.fq.gz \
        -s 300 -d 30 -p 16
    bash superreads.sh
    popd > /dev/null
done
```

Clear intermediate files.

```bash
# masurca
cd $HOME/data/anchr/s288c/

find . -type f -name "quorum_mer_db.jf" | xargs rm
find . -type f -name "k_u_hash_0" | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp" | xargs rm
#find . -type f -name "pe.renamed.fastq" | xargs rm
```

## Scer: create anchors

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

for d in $(perl -e 'for $n (qw{trimmed}) { for $i (1 .. 8) { printf qq{%s_%d }, $n, (1000000 * $i); } }');
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue
    fi
    
    rm -fr ${DIR_COUNT}/sr
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh ${DIR_COUNT} 16 false 120
done
```

## Scer: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

REAL_G=12157105

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

for d in $(perl -e 'for $n (qw{trimmed}) { for $i (1 .. 8) { printf qq{%s_%d }, $n, (1000000 * $i); } }');
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -d ${DIR_COUNT} ]; then
        continue     
    fi
    
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${DIR_COUNT} ${REAL_G} \
        >> ${BASE_DIR}/stat1.md
done

cat stat1.md
```

* Stats of anchors

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

for d in $(perl -e 'for $n (qw{trimmed}) { for $i (1 .. 8) { printf qq{%s_%d }, $n, (1000000 * $i); } }');
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue     
    fi
    
    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${DIR_COUNT} \
        >> ${BASE_DIR}/stat2.md

done

cat stat2.md
```

| Name            |   SumFq | CovFq | AvgRead | Kmer |   SumFa | Discard% |   #Subs |  Subs% |  RealG |   EstG | Est/Real |  SumSR | SR/Real | SR/Est |   RunTime |
|:----------------|--------:|------:|--------:|-----:|--------:|---------:|--------:|-------:|-------:|-------:|---------:|-------:|--------:|-------:|----------:|
| trimmed_1000000 | 300.72M |  24.7 |     150 |  105 | 300.16M |   0.187% | 242.27K | 0.081% | 12.16M | 11.43M |     0.94 | 13.17M |    1.08 |   1.15 | 0:01'15'' |
| trimmed_2000000 | 601.46M |  49.5 |     150 |  105 | 600.41M |   0.174% | 480.27K | 0.080% | 12.16M | 11.63M |     0.96 | 14.19M |    1.17 |   1.22 | 0:02'13'' |
| trimmed_3000000 |  902.2M |  74.2 |     150 |  105 | 900.69M |   0.167% | 716.27K | 0.080% | 12.16M | 11.71M |     0.96 | 16.81M |    1.38 |   1.44 | 0:03'11'' |
| trimmed_4000000 |    1.2G |  98.9 |     150 |  105 |    1.2G |   0.161% | 945.81K | 0.079% | 12.16M | 11.83M |     0.97 | 19.97M |    1.64 |   1.69 | 0:04'15'' |
| trimmed_5000000 |    1.5G | 123.7 |     150 |  105 |    1.5G |   0.156% |   1.17M | 0.078% | 12.16M | 11.94M |     0.98 | 24.19M |    1.99 |   2.03 | 0:05'16'' |
| trimmed_6000000 |    1.8G | 148.4 |     150 |  105 |    1.8G |   0.153% |    1.4M | 0.077% | 12.16M | 12.06M |     0.99 | 27.08M |    2.23 |   2.25 | 0:06'22'' |
| trimmed_7000000 |   2.11G | 173.2 |     150 |  105 |    2.1G |   0.149% |   1.62M | 0.077% | 12.16M | 12.18M |     1.00 |  29.4M |    2.42 |   2.41 | 0:07'23'' |
| trimmed_8000000 |   2.41G | 197.9 |     150 |  105 |    2.4G |   0.146% |   1.84M | 0.077% | 12.16M |  12.3M |     1.01 | 31.11M |    2.56 |   2.53 | 0:08'36'' |

## Scer: quality assessment

```bash
BASE_DIR=$HOME/data/anchr/s288c
cd ${BASE_DIR}

for part in anchor anchor2 others;
do 
    bash ~/Scripts/cpan/App-Anchr/share/sort_on_ref.sh trimmed_800000/sr/pe.${part}.fa 1_genome/genome.fa pe.${part}
    nucmer -l 200 1_genome/genome.fa pe.${part}.fa
    mummerplot -png out.delta -p pe.${part} --medium
done

# mummerplot files
rm *.[fr]plot
rm out.delta
rm *.gp
```
