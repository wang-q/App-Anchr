# Assemble genomes of model organisms by ANCHR

[TOC]: # " "
- [*E. coli*](#e-coli)
    - [*E. coli*: download](#e-coli-download)
    - [*E. coli*: trim/filter](#e-coli-trimfilter)
    - [*E. coli*: down sampling](#e-coli-down-sampling)
    - [*E. coli*: generate super-reads](#e-coli-generate-super-reads)

## *E. coli*

*Escherichia coli* str. K-12 substr. MG1655

* INSDC: [U00096.3](https://www.ncbi.nlm.nih.gov/nuccore/U00096.3)
* paralogs: 0.0323

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

### *E. coli*: download

```bash
# genome
mkdir -p ~/data/anchr/e_coli/1_genome
cd ~/data/anchr/e_coli/1_genome
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=U00096.3&rettype=fasta&retmode=txt" \
    > U00096.fa
ln -s U00096.fa genome.fa

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

### *E. coli*: trim/filter

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

### *E. coli*: down sampling

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

### *E. coli*: generate super-reads

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
        -s 300 -d 30 -p 8
    bash superreads.sh
    popd > /dev/null
done
```

Stats of super-reads

```bash
BASE_DIR=$HOME/data/anchr/e_coli
cd ${BASE_DIR}

REAL_G=4641652

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

for d in {original,trimmed,filter}_{200000,400000,600000,800000,1000000,1200000,1400000,1600000,1800000,2000000,2200000,2400000};
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

| Name             |   SumFq | CovFq | AvgRead | Kmer |   SumFa | Discard% |   #Subs | Subs% | RealG |  EstG | Est/Real |  SumSR | SumSR/Real | SR/EstG |   RunTime |
|:-----------------|--------:|------:|--------:|-----:|--------:|---------:|--------:|------:|------:|------:|---------:|-------:|-----------:|--------:|----------:|
| original_200000  |   60.4M |  13.0 |     151 |   75 |  59.51M |    1.47% | 330.39K | 0.56% | 4.64M | 4.57M |     0.98 |  5.71M |       1.25 |    1.23 | 0:01'15'' |
| original_400000  |  120.8M |  26.0 |     151 |   75 | 119.07M |    1.43% | 659.18K | 0.55% | 4.64M | 4.64M |     1.00 | 10.24M |       2.21 |    2.21 | 0:01'30'' |
| original_600000  |  181.2M |  39.0 |     151 |   75 | 178.64M |    1.41% | 984.55K | 0.55% | 4.64M | 4.72M |     1.02 | 10.98M |       2.33 |    2.37 | 0:01'49'' |
| original_800000  |  241.6M |  52.1 |     151 |   75 | 238.23M |    1.40% |    1.3M | 0.55% | 4.64M | 4.82M |     1.04 | 11.65M |       2.42 |    2.51 | 0:02'15'' |
| original_1000000 |    302M |  65.1 |     151 |   75 | 297.81M |    1.39% |   1.62M | 0.54% | 4.64M | 4.94M |     1.06 | 12.25M |       2.48 |    2.64 | 0:02'35'' |
| original_1200000 |  362.4M |  78.1 |     151 |   75 | 357.42M |    1.37% |   1.93M | 0.54% | 4.64M | 5.06M |     1.09 | 12.86M |       2.54 |    2.77 | 0:02'58'' |
| original_1400000 |  422.8M |  91.1 |     151 |   75 | 417.02M |    1.37% |   2.24M | 0.54% | 4.64M | 5.19M |     1.12 | 13.35M |       2.57 |    2.88 | 0:03'21'' |
| original_1600000 |  483.2M | 104.1 |     151 |   75 | 476.61M |    1.36% |   2.55M | 0.53% | 4.64M | 5.33M |     1.15 | 14.03M |       2.63 |    3.02 | 0:03'52'' |
| original_1800000 |  543.6M | 117.1 |     151 |   75 | 536.19M |    1.36% |   2.85M | 0.53% | 4.64M | 5.47M |     1.18 |  14.6M |       2.67 |    3.15 | 0:04'20'' |
| original_2000000 |    604M | 130.1 |     151 |   75 | 595.79M |    1.36% |   3.15M | 0.53% | 4.64M | 5.63M |     1.21 | 15.31M |       2.72 |    3.30 | 0:04'44'' |
| original_2200000 |  664.4M | 143.1 |     151 |   75 | 655.37M |    1.36% |   3.45M | 0.53% | 4.64M | 5.79M |     1.25 | 15.77M |       2.72 |    3.40 | 0:05'09'' |
| original_2400000 |  724.8M | 156.2 |     151 |   75 | 715.01M |    1.35% |   3.74M | 0.52% | 4.64M | 5.96M |     1.28 | 16.45M |       2.76 |    3.54 | 0:05'33'' |
| trimmed_200000   |   58.8M |  12.7 |     147 |  105 |  58.75M |    0.09% |  56.34K | 0.10% | 4.64M | 4.49M |     0.97 |  5.12M |       1.14 |    1.10 | 0:01'05'' |
| trimmed_400000   |  117.6M |  25.3 |     147 |  105 | 117.51M |    0.07% | 111.83K | 0.10% | 4.64M | 4.54M |     0.98 |  4.93M |       1.08 |    1.06 | 0:01'26'' |
| trimmed_600000   | 176.41M |  38.0 |     146 |  105 | 176.28M |    0.07% | 168.16K | 0.10% | 4.64M | 4.56M |     0.98 |  4.88M |       1.07 |    1.05 | 0:01'47'' |
| trimmed_800000   | 235.18M |  50.7 |     146 |  105 | 235.01M |    0.07% | 223.33K | 0.10% | 4.64M | 4.56M |     0.98 |  4.97M |       1.09 |    1.07 | 0:02'12'' |
| trimmed_1000000  |    294M |  63.3 |     146 |  105 | 293.79M |    0.07% | 279.12K | 0.10% | 4.64M | 4.56M |     0.98 |  5.16M |       1.13 |    1.11 | 0:02'33'' |
| trimmed_1200000  | 352.78M |  76.0 |     146 |  105 | 352.53M |    0.07% | 335.28K | 0.10% | 4.64M | 4.57M |     0.98 |  5.26M |       1.15 |    1.13 | 0:02'55'' |
| trimmed_1400000  | 411.56M |  88.7 |     146 |  105 | 411.26M |    0.07% | 391.04K | 0.10% | 4.64M | 4.57M |     0.99 |  5.63M |       1.23 |    1.21 | 0:03'13'' |
| trimmed_1600000  | 470.38M | 101.3 |     146 |  105 | 470.05M |    0.07% | 445.56K | 0.09% | 4.64M | 4.58M |     0.99 |   5.9M |       1.29 |    1.27 | 0:03'27'' |
| trimmed_1800000  | 529.16M | 114.0 |     146 |  105 | 528.78M |    0.07% | 499.33K | 0.09% | 4.64M | 4.59M |     0.99 |  6.34M |       1.38 |    1.37 | 0:03'48'' |
| trimmed_2000000  | 587.96M | 126.7 |     146 |  105 | 587.54M |    0.07% | 555.07K | 0.09% | 4.64M | 4.59M |     0.99 |   6.8M |       1.48 |    1.47 | 0:04'06'' |
| trimmed_2200000  | 646.77M | 139.3 |     146 |  105 |  646.3M |    0.07% | 611.18K | 0.09% | 4.64M |  4.6M |     0.99 |   7.1M |       1.54 |    1.53 | 0:04'38'' |
| trimmed_2400000  | 705.55M | 152.0 |     146 |  105 | 705.03M |    0.07% | 665.83K | 0.09% | 4.64M | 4.61M |     0.99 |  7.38M |       1.60 |    1.59 | 0:04'42'' |
| filter_200000    |   60.4M |  13.0 |     151 |  105 |  60.34M |    0.09% |  56.92K | 0.09% | 4.64M | 4.38M |     0.94 |  4.73M |       1.08 |    1.02 | 0:01'06'' |
| filter_400000    |  120.8M |  26.0 |     151 |  105 | 120.71M |    0.07% | 113.84K | 0.09% | 4.64M |  4.5M |     0.97 |  4.81M |       1.07 |    1.04 | 0:01'29'' |
| filter_600000    |  181.2M |  39.0 |     151 |  105 | 181.06M |    0.08% | 172.33K | 0.10% | 4.64M | 4.53M |     0.98 |  4.82M |       1.07 |    1.04 | 0:01'50'' |
| filter_800000    |  241.6M |  52.1 |     151 |  105 | 241.43M |    0.07% | 229.13K | 0.09% | 4.64M | 4.54M |     0.98 |  4.87M |       1.07 |    1.05 | 0:02'16'' |
| filter_1000000   |    302M |  65.1 |     151 |  105 | 301.79M |    0.07% | 285.75K | 0.09% | 4.64M | 4.55M |     0.98 |  4.94M |       1.09 |    1.07 | 0:02'32'' |
| filter_1200000   |  362.4M |  78.1 |     151 |  105 | 362.15M |    0.07% | 343.66K | 0.09% | 4.64M | 4.55M |     0.98 |  5.03M |       1.11 |    1.08 | 0:02'52'' |
| filter_1400000   |  422.8M |  91.1 |     151 |  105 |  422.5M |    0.07% |  399.5K | 0.09% | 4.64M | 4.56M |     0.98 |  5.13M |       1.13 |    1.11 | 0:03'26'' |
| filter_1600000   |  483.2M | 104.1 |     151 |  105 | 482.85M |    0.07% |  456.8K | 0.09% | 4.64M | 4.57M |     0.98 |   5.3M |       1.16 |    1.14 | 0:03'42'' |
| filter_1800000   |  543.6M | 117.1 |     151 |  105 | 543.22M |    0.07% | 513.77K | 0.09% | 4.64M | 4.57M |     0.98 |  5.55M |       1.21 |    1.19 | 0:03'54'' |
| filter_2000000   |    604M | 130.1 |     151 |  105 | 603.57M |    0.07% | 569.58K | 0.09% | 4.64M | 4.57M |     0.99 |  5.73M |       1.25 |    1.23 | 0:04'20'' |
| filter_2200000   |  664.4M | 143.1 |     151 |  105 | 663.93M |    0.07% |    626K | 0.09% | 4.64M | 4.58M |     0.99 |   6.1M |       1.33 |    1.31 | 0:04'49'' |
| filter_2400000   |  724.8M | 156.2 |     151 |  105 | 724.28M |    0.07% |  681.8K | 0.09% | 4.64M | 4.59M |     0.99 |  6.46M |       1.41 |    1.39 | 0:05'10'' |

* Illumina reads 的分布是有偏性的. 极端 GC 区域, 结构复杂区域都会得到较低的 fq 分值, 本应被 trim 掉.
  但覆盖度过高时, 这些区域之间的 reads 相互支持, 被保留下来的概率大大增加.
    * Discard% 在 CovFq 大于 100 倍时, 快速下降.
* Illumina reads 错误率约为 1% 不到一点. 当覆盖度过高时, 错误的点重复出现的概率要比完全无偏性的情况大一些.
    * 理论上 Subs% 应该是恒定值, 但当 CovFq 大于 100 倍时, 这个值在下降, 也就是这些错误的点相互支持, 躲过了
      Kmer 纠错.
* 直接的反映就是 EstG 过大, SumSR 过大.
* 留下的错误片段, 会形成 **伪独立** 片段, 降低 N50 SR
* 留下的错误位点, 会形成 **伪杂合** 位点, 降低 N50 SR
* trim 的效果比 filter 好. 可能是留下了更多二代测序效果较差的位置. 最大的 EstG, trim 的更接近真实值
    * Real - 4.64M
    * Trimmed - 4.61M (EstG)
    * Filter - 4.59M (EstG)

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
