# Tuning parameters for the dataset of *E. coli*


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
