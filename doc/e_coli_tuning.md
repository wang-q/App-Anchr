# Tuning parameters for the dataset of *E. coli*

[TOC level=1-3]: # " "
- [Tuning parameters for the dataset of *E. coli*](#tuning-parameters-for-the-dataset-of-e-coli)
- [*Escherichia coli* str. K-12 substr. MG1655](#escherichia-coli-str-k-12-substr-mg1655)
    - [Symlinks](#symlinks)
    - [Combinations of different quality values and read lengths](#combinations-of-different-quality-values-and-read-lengths)
    - [Down sampling](#down-sampling)
    - [Generate super-reads](#generate-super-reads)
    - [Create anchors](#create-anchors)
    - [Results](#results)


# *Escherichia coli* str. K-12 substr. MG1655

* Genome: INSDC [U00096.3](https://www.ncbi.nlm.nih.gov/nuccore/U00096.3)
* Proportion of paralogs: 0.0323
* Real
    * N50: 4,641,652
    * S: 4,641,652
    * C: 1

## Symlinks

* Reference genome

```bash
mkdir -p ~/data/anchr/e_coli_tuning/1_genome
cd ~/data/anchr/e_coli_tuning/1_genome

ln -s ~/data/anchr/e_coli/1_genome/genome.fa genome.fa

mkdir -p ~/data/anchr/e_coli_tuning/2_illumina
cd ~/data/anchr/e_coli_tuning/2_illumina

ln -s ~/data/anchr/e_coli/2_illumina/R1.fq.gz R1.fq.gz
ln -s ~/data/anchr/e_coli/2_illumina/R2.fq.gz R2.fq.gz
```

## Combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 120, 130, 140 and 151

```bash
BASE_DIR=$HOME/data/anchr/e_coli_tuning
cd ${BASE_DIR}

# get the default adapter file
# anchr trim --help

scythe \
    2_illumina/R1.fq.gz \
    -q sanger \
    -M 100 \
    -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
    --quiet \
    | pigz -p 4 -c \
    > 2_illumina/R1.scythe.fq.gz

scythe \
    2_illumina/R2.fq.gz \
    -q sanger \
    -M 100 \
    -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
    --quiet \
    | pigz -p 4 -c \
    > 2_illumina/R2.scythe.fq.gz

cd ${BASE_DIR}
for qual in 20 25 30; do
    for len in 120 130 140 151; do
        DIR_COUNT="${BASE_DIR}/2_illumina/Q${qual}L${len}"
        
        mkdir -p ${DIR_COUNT}
        pushd ${DIR_COUNT}
        
        anchr trim \
            --noscythe \
            -q ${qual} -l ${len} \
            ../R1.scythe.fq.gz ../R2.scythe.fq.gz \
            -o stdout \
            | bash

        popd
    done
done

# clear dirs stack
dirs -c
```

* Stats

```bash
cd ~/data/anchr/e_coli_tuning

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "original"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md

for qual in 20 25 30; do
    for len in 120 130 140 151; do
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
| genome   | 4641652 |    4641652 |        1 |
| original |     151 | 1730299940 | 11458940 |
| scythe   |     151 | 1724565376 | 11458940 |
| Q20L120  |     151 | 1138097252 |  7742646 |
| Q20L130  |     151 |  977384738 |  6561892 |
| Q20L140  |     151 |  786030615 |  5213876 |
| Q20L151  |     151 |  742079836 |  4914436 |
| Q25L120  |     151 |  839150352 |  5820278 |
| Q25L130  |     151 |  634128805 |  4303670 |
| Q25L140  |     151 |  421124326 |  2798656 |
| Q25L151  |     151 |  373099860 |  2470860 |
| Q30L120  |     140 |  383365150 |  2755884 |
| Q30L130  |     151 |  211952097 |  1468318 |
| Q30L140  |     151 |   92578231 |   617860 |
| Q30L151  |     151 |   69647542 |   461242 |

## Down sampling

过高的 coverage 会造成不好的影响. SGA 的文档里也说了类似的事情.

> Very highly-represented sequences (>1000X) can cause problems for SGA... In these cases, it is
> worth considering pre-filtering the data...

```bash
BASE_DIR=$HOME/data/anchr/e_coli_tuning
cd ${BASE_DIR}

# works on bash 3
ARRAY=( "2_illumina:original:5000000"
        "2_illumina/Q20L120:Q20L120:3800000"
        "2_illumina/Q20L130:Q20L130:3200000"
        "2_illumina/Q20L140:Q20L140:2600000"
        "2_illumina/Q20L151:Q20L151:2400000"
        "2_illumina/Q25L120:Q25L120:2800000"
        "2_illumina/Q25L130:Q25L130:2000000"
        "2_illumina/Q25L140:Q25L140:1200000"
        "2_illumina/Q25L151:Q25L151:1200000"
        "2_illumina/Q30L120:Q30L120:1200000"
        "2_illumina/Q30L130:Q30L130:400000"
        "2_illumina/Q30L140:Q30L140:400000"
        "2_illumina/Q30L151:Q30L151:200000")

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
        
        echo "==> Group ${GROUP_ID}_${count}"
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

## Generate super-reads

```bash
BASE_DIR=$HOME/data/anchr/e_coli_tuning
cd ${BASE_DIR}

for d in $(perl -e 'for $n (qw{original Q20L120 Q20L130 Q20L140 Q20L151 Q25L120 Q25L130 Q25L140 Q25L151 Q30L120 Q30L130 Q30L140 Q30L151}) { for $i (1 .. 25) { printf qq{%s_%d }, $n, (200000 * $i); } }');
do
    echo
    DIR_COUNT="${BASE_DIR}/${d}/"

    if [ ! -d ${DIR_COUNT} ]; then
        continue
    fi
    
    echo "==> Group ${DIR_COUNT}"

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
cd $HOME/data/anchr/e_coli_tuning

find . -type f -name "quorum_mer_db.jf" | xargs rm
find . -type f -name "k_u_hash_0" | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp" | xargs rm
#find . -type f -name "pe.renamed.fastq" | xargs rm
```

## Create anchors

```bash
BASE_DIR=$HOME/data/anchr/e_coli_tuning
cd ${BASE_DIR}

for d in $(perl -e 'for $n (qw{original Q20L120 Q20L130 Q20L140 Q20L151 Q25L120 Q25L130 Q25L140 Q25L151 Q30L120 Q30L130 Q30L140 Q30L151}) { for $i (1 .. 25) { printf qq{%s_%d }, $n, (200000 * $i); } }');
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -e ${DIR_COUNT}/work1/superReadSequences.fasta ]; then
        continue
    fi
        
    if [ -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue
    fi
    
    rm -fr ${DIR_COUNT}/sr
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh ${DIR_COUNT} 16 false 120
done
```

## Results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/e_coli_tuning
cd ${BASE_DIR}

REAL_G=4641652

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

for d in $(perl -e 'for $n (qw{original Q20L120 Q20L130 Q20L140 Q20L151 Q25L120 Q25L130 Q25L140 Q25L151 Q30L120 Q30L130 Q30L140 Q30L151}) { for $i (1 .. 25) { printf qq{%s_%d }, $n, (200000 * $i); } }');
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
BASE_DIR=$HOME/data/anchr/e_coli_tuning
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

for d in $(perl -e 'for $n (qw{original Q20L120 Q20L130 Q20L140 Q20L151 Q25L120 Q25L130 Q25L140 Q25L151 Q30L120 Q30L130 Q30L140 Q30L151}) { for $i (1 .. 25) { printf qq{%s_%d }, $n, (200000 * $i); } }');
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

* Illumina reads 的分布是有偏性的. 极端 GC 区域, 结构复杂区域都会得到较低的 fq 分值, 本应被 trim 掉.
  但覆盖度过高时, 这些区域之间的 reads 相互支持, 被保留下来的概率大大增加.
    * Discard% 在 CovFq 大于 100 倍时, 快速下降.
* Illumina reads 错误率约为 1% 不到一点. 当覆盖度过高时, 错误的点重复出现的概率要比完全无偏性的情况大一些.
    * 理论上 Subs% 应该是恒定值, 但当 CovFq 大于 100 倍时, 这个值在下降, 也就是这些错误的点相互支持, 躲过了 Kmer
      纠错.
* 直接的反映就是 EstG 过大, SumSR 过大.
* 留下的错误片段, 会形成 **伪独立** 片段, 降低 N50 SR
* 留下的错误位点, 会形成 **伪杂合** 位点, 降低 N50 SR
* trimmed 的 N50 比 filter 要大一些, 可能是留下了更多二代测序效果较差的位置. 同样 2400000 对 reads, trim 的 EstG
  更接近真实值
    * Real - 4.64M
    * Trimmed - 4.61M (EstG)
    * Filter - 4.59M (EstG)
* 但是 trimmed 里出 misassemblies 的概率要比 filter 大.