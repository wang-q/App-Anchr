# Assemble genomes of model organisms by ANCHR

[TOC levels=1-3]: # ""
- [Assemble genomes of model organisms by ANCHR](#assemble-genomes-of-model-organisms-by-anchr)
- [More tools on downloading and preprocessing data](#more-tools-on-downloading-and-preprocessing-data)
    - [Extra external executables](#extra-external-executables)
    - [Other leading assemblers](#other-leading-assemblers)
    - [PacBio specific tools](#pacbio-specific-tools)
- [*Escherichia coli* str. K-12 substr. MG1655](#escherichia-coli-str-k-12-substr-mg1655)
    - [mg1655: download](#mg1655-download)
    - [mg1655: template](#mg1655-template)
    - [mg1655: run](#mg1655-run)


# More tools on downloading and preprocessing data

## Extra external executables

```shell script
brew install aria2 curl                     # downloading tools

brew tap brewsci/bio
brew tap brewsci/science

brew install sratoolkit    # NCBI SRAToolkit

brew reinstall --build-from-source --without-webp gd # broken, can't find libwebp.so.6
brew reinstall --build-from-source lua@5.1
brew reinstall --build-from-source gnuplot@4
brew install mummer        # mummer need gnuplot4

brew install openblas                       # numpy
brew install python
brew install --HEAD quast         # assembly quality assessment. https://github.com/ablab/quast/issues/140
quast --test                                # may recompile the bundled nucmer

# canu requires gnuplot 5 while mummer requires gnuplot 4
brew install --build-from-source canu

brew unlink gnuplot@4
brew install gnuplot
brew unlink gnuplot

brew link gnuplot@4 --force

#brew install r
brew install ntcard
brew install wang-q/tap/kmergenie@1.7051

brew install kmc --HEAD

brew install --ignore-dependencies picard-tools

```

## Other leading assemblers

```shell script
brew install spades
brew install megahit
brew install wang-q/tap/platanus

```

## PacBio specific tools

PacBio is switching its data format from `hdf5` to `bam`, but many public available PacBio data are
still in formats of `.bax.h5` or `hdf5.tgz`. To deal with these files, PacBio releases some tools
which can be installed by `bioconda`.

```shell script
# https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

conda install bax2bam

bax2bam --help
```

# *Escherichia coli* str. K-12 substr. MG1655

* Taxonomy ID: [511145](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=511145)
* Genome: INSDC [U00096.3](https://www.ncbi.nlm.nih.gov/nuccore/U00096.3)
* Assembly: [GCF_000005845.2](https://www.ncbi.nlm.nih.gov/assembly/GCF_000005845.2)
* Proportion of paralogs (> 1000 bp): 0.0323

## mg1655: download

* Reference genome

```shell script
mkdir -p ~/data/anchr/ref
cd ~/data/anchr/ref

rsync -avP \
    ftp.ncbi.nlm.nih.gov::genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/ \
    mg1655/

```

```shell script
mkdir -p ${HOME}/data/anchr/mg1655/1_genome
cd ${HOME}/data/anchr/mg1655/1_genome

find ~/data/anchr/ref/mg1655/ -name "*_genomic.fna.gz" |
    grep -v "_from_" |
    xargs gzip -dcf |
    faops filter -N -s stdin genome.fa

cat ${HOME}/data/anchr/paralogs/model/Results/mg1655/mg1655.multi.fas |
    faops filter -N -d stdin stdout \
    > paralogs.fa

```

* Illumina

```shell script
cd ${HOME}/data/anchr/mg1655

mkdir -p 2_illumina
cd 2_illumina

aria2c -x 9 -s 3 -c ftp://webdata:webdata@ussd-ftp.illumina.com/Data/SequencingRuns/MG1655/MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz
aria2c -x 9 -s 3 -c ftp://webdata:webdata@ussd-ftp.illumina.com/Data/SequencingRuns/MG1655/MiSeq_Ecoli_MG1655_110721_PF_R2.fastq.gz

ln -s MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz R1.fq.gz
ln -s MiSeq_Ecoli_MG1655_110721_PF_R2.fastq.gz R2.fq.gz

```

* PacBio

    [Here](https://github.com/PacificBiosciences/DevNet/wiki/E.-coli-Bacterial-Assembly) PacBio
    provides a 7 GB file for *E. coli* (20 kb library), which is gathered with RS II and the P6C4
    reagent.

```shell script
cd ${HOME}/data/anchr/mg1655

mkdir -p 3_pacbio
cd 3_pacbio

aria2c -x 9 -s 3 -c https://s3.amazonaws.com/files.pacb.com/datasets/secondary-analysis/e-coli-k12-P6C4/p6c4_ecoli_RSII_DDR2_with_15kb_cut_E01_1.tar.gz

tar xvfz p6c4_ecoli_RSII_DDR2_with_15kb_cut_E01_1.tar.gz

# Optional, a human readable .metadata.xml file
#xmllint --format E01_1/m141013_011508_sherri_c100709962550000001823135904221533_s1_p0.metadata.xml \
#    > m141013.metadata.xml

# convert .bax.h5 to .subreads.bam
mkdir -p ~/data/anchr/mg1655/3_pacbio/bam
cd ~/data/anchr/mg1655/3_pacbio/bam

bax2bam ../E01_1/Analysis_Results/*.bax.h5

# convert .subreads.bam to fasta
mkdir -p ~/data/anchr/mg1655/3_pacbio/fasta

samtools fasta \
    ~/data/anchr/mg1655/3_pacbio/bam/m141013*.subreads.bam \
    > ~/data/anchr/mg1655/3_pacbio/fasta/m141013.fasta

cd ~/data/anchr/mg1655/3_pacbio
cat fasta/m141013.fasta |
    faops dazz -l 0 -p long stdin stdout |
    pigz > pacbio.fasta.gz

```

## mg1655: template

* Rsync to hpcc

```shell script
rsync -avP \
    --exclude="p6c4_ecoli_RSII_DDR2_with_15kb_cut_E01_1.tar.gz" \
    ~/data/anchr/mg1655/ \
    wangq@202.119.37.251:data/anchr/mg1655

# rsync -avP wangq@202.119.37.251:data/anchr/mg1655/ ~/data/anchr/mg1655

```

* template

`--cov2 "40 60 80 100"` introduced ~10 SNPs and 1 misassembly.

```shell script
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=mg1655

cd ${WORKING_DIR}/${BASE_NAME}

rm *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 4641652 \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --sgastats \
    --trim2 "--dedupe --tile --cutoff 5 --cutk 31" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,artifact" \
    --mergereads \
    --ecphase "1,2,3" \
    --cov2 "40 80" \
    --statp 5 \
    --redoanchors \
    --cov3 "80 all" \
    --qual3 "trim" \
    --parallel 24 \
    --xmx 110g

```

## mg1655: run

```shell script
WORKING_DIR=${HOME}/data/anchr
BASE_NAME=mg1655

cd ${WORKING_DIR}/${BASE_NAME}
# rm -fr 4_*/ 6_*/ 7_*/ 8_*/
# rm -fr 2_illumina/trim 2_illumina/mergereads statReads.md 

bash 0_bsub.sh
#bsub -q mpi -n 24 -J "${BASE_NAME}-0_master" "bash 0_master.sh"
#bkill -J "${BASE_NAME}-*"

#bash 0_master.sh
#bash 0_cleanup.sh

```

三代 reads 里有一个常见的错误, 即单一 ZMW 里的测序结果中, 接头序列部分的测序结果出现了较多的错误,
因此并没有将接头序列去除干净, 形成的 subreads 里含有多份基因组上同一片段, 它们之间以接头序列为间隔.

`anchr group` 命令默认会将这种三代的 reads 去除. `--keep` 选项会留下这种 reads, 这适用于组装好的三代序列.

```text
      ===
------------>
             )
  <----------
      ===
```


Table: statInsertSize

| Group             |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:------------------|------:|-------:|------:|-------------------------------:|
| R.genome.bbtools  | 321.9 |    298 | 968.5 |                         47.99% |
| R.tadpole.bbtools | 295.6 |    296 |  21.1 |                         40.60% |
| R.genome.picard   | 298.2 |    298 |  18.0 |                             FR |
| R.tadpole.picard  | 294.9 |    296 |  21.7 |                             FR |


Table: statSgaStats

| Library | incorrectBases | perfectReads | overlapDepth |
|:--------|---------------:|-------------:|-------------:|
| R       |          0.26% |       79.72% |       356.41 |


Table: statReads

| Name       |     N50 |     Sum |        # |
|:-----------|--------:|--------:|---------:|
| Genome     | 4641652 | 4641652 |        1 |
| Paralogs   |    1937 |  187300 |      106 |
| Illumina.R |     151 |   1.73G | 11458940 |
| trim.R     |     149 |   1.43G | 10359348 |
| Q20L60     |     149 |   1.41G | 10220578 |
| Q25L60     |     148 |   1.32G |  9935345 |
| Q30L60     |     128 |   1.11G |  9307976 |
| PacBio     |   13982 | 748.51M |    87225 |
| X80.raw    |   13990 | 371.34M |    44005 |
| X80.trim   |   13632 | 339.51M |    38725 |
| Xall.raw   |   13982 | 748.51M |    87225 |
| Xall.trim  |   13646 | 689.43M |    77693 |


Table: statTrimReads

| Name           | N50 |     Sum |        # |
|:---------------|----:|--------:|---------:|
| clumpify       | 151 |   1.73G | 11439000 |
| filteredbytile | 151 |   1.67G | 11054998 |
| highpass       | 151 |   1.66G | 10984458 |
| trim           | 149 |   1.43G | 10359854 |
| filter         | 149 |   1.43G | 10359348 |
| R1             | 150 | 735.71M |  5179674 |
| R2             | 144 | 690.13M |  5179674 |
| Rs             |   0 |       0 |        0 |


```text
#R.trim
#Matched	17789	0.16195%
#Name	Reads	ReadsPct
```

```text
#R.filter
#Matched	505	0.00487%
#Name	Reads	ReadsPct
```

```text
#R.peaks
#k	31
#unique_kmers	20702335
#error_kmers	16177612
#genomic_kmers	4524723
#main_peak	246
#genome_size_in_peaks	4596128
#genome_size	4626174
#haploid_genome_size	4626174
#fold_coverage	246
#haploid_fold_coverage	246
#ploidy	1
#percent_repeat_in_peaks	1.554
#percent_repeat	1.748
#start	center	stop	max	volume
```


Table: statMergeReads

| Name          | N50 |    Sum |        # |
|:--------------|----:|-------:|---------:|
| clumped       | 149 |  1.43G | 10358168 |
| ecco          | 149 |  1.43G | 10358168 |
| eccc          | 149 |  1.43G | 10358168 |
| ecct          | 149 |  1.42G | 10309684 |
| extended      | 189 |  1.83G | 10309684 |
| merged.raw    | 339 |  1.72G |  5083086 |
| unmerged.raw  | 175 | 21.12M |   143512 |
| unmerged.trim | 175 | 21.12M |   143454 |
| M1            | 339 |  1.71G |  5055621 |
| U1            | 181 | 11.08M |    71727 |
| U2            | 168 | 10.04M |    71727 |
| Us            |   0 |      0 |        0 |
| M.cor         | 338 |  1.73G | 10254696 |

| Group              |  Mean | Median | STDev | PercentOfPairs |
|:-------------------|------:|-------:|------:|---------------:|
| M.ihist.merge1.txt | 271.7 |    277 |  23.4 |         10.84% |
| M.ihist.merge.txt  | 337.7 |    338 |  19.3 |         98.61% |


Table: statQuorum

| Name     | CovIn | CovOut | Discard% | Kmer | RealG |  EstG | Est/Real |   RunTime |
|:---------|------:|-------:|---------:|-----:|------:|------:|---------:|----------:|
| Q0L0.R   | 307.2 |  285.5 |    7.05% | "97" | 4.64M | 4.66M |     1.00 | 0:04'07'' |
| Q20L60.R | 302.8 |  283.6 |    6.35% | "97" | 4.64M | 4.63M |     1.00 | 0:04'04'' |
| Q25L60.R | 283.9 |  273.0 |    3.84% | "89" | 4.64M | 4.57M |     0.98 | 0:03'51'' |
| Q30L60.R | 238.3 |  233.4 |    2.03% | "73" | 4.64M | 4.56M |     0.98 | 0:03'19'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|------:|-----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  96.16% |      7584 | 4.35M |  855 |       780 | 204.67K | 1844 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'38'' |
| Q0L0X40P001   |   40.0 |  96.09% |      7325 | 4.33M |  826 |       644 | 191.71K | 1759 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'39'' |
| Q0L0X40P002   |   40.0 |  96.23% |      7216 |  4.3M |  866 |       723 | 218.22K | 1866 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'35'' |
| Q0L0X40P003   |   40.0 |  96.18% |      7635 | 4.32M |  811 |       578 | 180.56K | 1782 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'37'' |
| Q0L0X40P004   |   40.0 |  96.26% |      7622 |  4.3M |  838 |       545 | 187.02K | 1865 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'37'' |
| Q0L0X40P005   |   40.0 |  96.03% |      9138 | 4.41M |  730 |        99 | 104.32K | 1679 |   39.0 | 3.0 |  10.0 |  72.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'36'' |
| Q0L0X80P000   |   80.0 |  92.17% |      4823 | 4.27M | 1156 |        87 | 145.79K | 2398 |   79.0 | 6.0 |  20.3 | 145.5 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'37'' |
| Q0L0X80P001   |   80.0 |  92.28% |      4602 | 4.27M | 1169 |        85 | 148.31K | 2446 |   79.0 | 6.0 |  20.3 | 145.5 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'38'' |
| Q0L0X80P002   |   80.0 |  92.07% |      4652 | 4.26M | 1186 |        82 | 147.43K | 2474 |   79.0 | 6.0 |  20.3 | 145.5 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'38'' |
| Q20L60X40P000 |   40.0 |  96.53% |      8098 |  4.3M |  771 |       776 | 207.71K | 1688 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'37'' |
| Q20L60X40P001 |   40.0 |  96.44% |      7314 | 4.29M |  827 |       566 | 184.02K | 1826 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'36'' |
| Q20L60X40P002 |   40.0 |  96.64% |      7766 | 4.32M |  803 |       688 | 200.51K | 1805 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'37'' |
| Q20L60X40P003 |   40.0 |  96.49% |      7559 | 4.33M |  814 |       568 | 169.32K | 1723 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'37'' |
| Q20L60X40P004 |   40.0 |  96.44% |      8005 | 4.28M |  779 |       721 | 189.45K | 1737 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'36'' |
| Q20L60X40P005 |   40.0 |  96.59% |      8045 | 4.35M |  796 |       604 | 182.62K | 1800 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'37'' |
| Q20L60X80P000 |   80.0 |  93.13% |      5256 |  4.3M | 1093 |        93 | 142.74K | 2288 |   79.0 | 6.0 |  20.3 | 145.5 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'38'' |
| Q20L60X80P001 |   80.0 |  93.55% |      5231 | 4.33M | 1084 |        70 | 124.29K | 2275 |   79.0 | 6.0 |  20.3 | 145.5 | "31,41,51,61,71,81" | 0:01'11'' | 0:00'39'' |
| Q20L60X80P002 |   80.0 |  93.27% |      5402 | 4.31M | 1084 |        90 | 139.28K | 2296 |   79.0 | 6.0 |  20.3 | 145.5 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'37'' |
| Q25L60X40P000 |   40.0 |  97.74% |      9800 | 4.15M |  665 |       818 | 202.14K | 1617 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'41'' |
| Q25L60X40P001 |   40.0 |  97.91% |     10194 |  4.2M |  643 |       742 | 187.47K | 1540 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'41'' |
| Q25L60X40P002 |   40.0 |  97.86% |     10248 | 4.24M |  621 |       799 | 212.82K | 1588 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'40'' |
| Q25L60X40P003 |   40.0 |  97.89% |     12841 | 4.45M |  525 |       407 |  121.7K | 1510 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'41'' |
| Q25L60X40P004 |   40.0 |  97.79% |      9688 | 4.21M |  646 |       822 | 201.55K | 1518 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'40'' |
| Q25L60X40P005 |   40.0 |  97.72% |      9946 | 4.15M |  639 |       687 | 198.84K | 1584 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'41'' |
| Q25L60X80P000 |   80.0 |  96.77% |      9552 | 4.45M |  702 |        99 | 104.06K | 1631 |   79.0 | 5.0 |  21.3 | 141.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'42'' |
| Q25L60X80P001 |   80.0 |  96.81% |      9618 | 4.43M |  688 |       274 | 116.98K | 1585 |   79.0 | 5.0 |  21.3 | 141.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'41'' |
| Q25L60X80P002 |   80.0 |  96.55% |      9213 | 4.42M |  716 |       252 | 115.19K | 1609 |   79.0 | 5.0 |  21.3 | 141.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'41'' |
| Q30L60X40P000 |   40.0 |  98.53% |      9831 |  3.3M |  515 |      1002 | 283.91K | 1448 |   40.0 | 2.0 |  11.3 |  69.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'45'' |
| Q30L60X40P001 |   40.0 |  98.55% |     13235 | 4.03M |  495 |       956 | 201.65K | 1509 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'45'' |
| Q30L60X40P002 |   40.0 |  98.57% |     14090 | 4.28M |  478 |       833 | 189.72K | 1575 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'46'' |
| Q30L60X40P003 |   40.0 |  98.52% |     13513 | 4.06M |  473 |       830 | 179.29K | 1470 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'45'' |
| Q30L60X40P004 |   40.0 |  98.55% |     14049 |  3.9M |  448 |       889 | 179.53K | 1485 |   40.0 | 3.0 |  10.3 |  73.5 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'46'' |
| Q30L60X80P000 |   80.0 |  98.48% |     14830 | 3.92M |  460 |       817 | 168.43K | 1239 |   79.0 | 4.0 |  22.3 | 136.5 | "31,41,51,61,71,81" | 0:01'08'' | 0:00'50'' |
| Q30L60X80P001 |   80.0 |  98.52% |     13322 | 4.11M |  492 |       842 | 184.69K | 1349 |   79.0 | 4.0 |  22.3 | 136.5 | "31,41,51,61,71,81" | 0:01'08'' | 0:00'49'' |


Table: statMRKunitigsAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  96.07% |     19924 | 4.45M | 354 |       145 |  93.32K | 696 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'35'' |
| MRX40P001 |   40.0 |  96.13% |     20940 |  4.4M | 351 |       133 |  80.99K | 688 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'35'' |
| MRX40P002 |   40.0 |  96.27% |     23117 | 4.47M | 346 |       131 |  80.33K | 677 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'36'' |
| MRX40P003 |   40.0 |  96.14% |     19357 |  4.4M | 364 |       136 |  87.02K | 696 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'36'' |
| MRX40P004 |   40.0 |  96.26% |     21643 | 4.41M | 330 |       131 |  78.15K | 651 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'35'' |
| MRX40P005 |   40.0 |  96.12% |     22763 |  4.4M | 349 |       134 |  85.66K | 679 |   39.0 | 2.0 |  11.0 |  67.5 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'35'' |
| MRX80P000 |   80.0 |  94.88% |     14912 | 4.43M | 453 |       131 | 111.11K | 937 |   79.0 | 4.0 |  22.3 | 136.5 | "31,41,51,61,71,81" | 0:01'32'' | 0:00'39'' |
| MRX80P001 |   80.0 |  94.97% |     15084 | 4.43M | 442 |       132 | 112.55K | 925 |   79.0 | 4.0 |  22.3 | 136.5 | "31,41,51,61,71,81" | 0:01'32'' | 0:00'38'' |
| MRX80P002 |   80.0 |  94.95% |     16945 | 4.44M | 424 |       126 |  104.4K | 890 |   79.0 | 5.0 |  21.3 | 141.0 | "31,41,51,61,71,81" | 0:01'32'' | 0:00'37'' |
| MRX80P003 |   80.0 |  94.83% |     15194 | 4.43M | 448 |       127 | 107.49K | 926 |   79.0 | 4.0 |  22.3 | 136.5 | "31,41,51,61,71,81" | 0:01'33'' | 0:00'37'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |   Sum |   # | N50Others |     Sum |   # | median |  MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|------:|----:|----------:|--------:|----:|-------:|-----:|------:|------:|----------:|
| 7_mergeAnchors           |  96.96% |     40963 |  4.5M | 199 |      2093 | 465.08K | 255 |  285.0 | 11.0 |  84.0 | 477.0 | 0:00'59'' |
| 7_mergeKunitigsAnchors   |  99.00% |     48897 | 4.51M | 178 |      1800 | 390.17K | 240 |  284.0 | 15.0 |  79.7 | 493.5 | 0:02'03'' |
| 7_mergeMRKunitigsAnchors |  98.75% |     35640 |  4.5M | 211 |      2458 | 130.34K |  71 |  285.0 | 11.0 |  84.0 | 477.0 | 0:01'46'' |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |   Sum |   # | N50Others |    Sum |   # | median |  MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|------:|----:|----------:|-------:|----:|-------:|-----:|------:|------:|----------:|
| 8_spades     |  98.54% |     54833 | 2.48M |  98 |      1117 | 26.68K | 131 |  285.0 | 10.0 |  85.0 | 472.5 | 0:00'53'' |
| 8_spades_MR  |  98.39% |    125798 | 4.31M |  77 |      1002 | 34.17K | 152 |  371.0 |  9.5 | 114.2 | 599.2 | 0:00'56'' |
| 8_megahit    |  98.16% |     40324 | 3.47M | 159 |      1133 | 33.15K | 218 |  285.0 | 10.0 |  85.0 | 472.5 | 0:00'53'' |
| 8_megahit_MR |  98.78% |    112650 | 4.33M |  79 |      1065 | 32.25K | 146 |  371.0 |  8.0 | 115.7 | 592.5 | 0:00'55'' |
| 8_platanus   |  97.86% |     41234 | 1.97M |  94 |      1053 | 20.82K | 116 |  285.0 |  8.5 |  86.5 | 465.8 | 0:00'53'' |


Table: statCanu

| Name                |     N50 |     Sum |     # |
|:--------------------|--------:|--------:|------:|
| Genome              | 4641652 | 4641652 |     1 |
| X80.trim.corrected  |   16820 | 175.59M | 10873 |
| Xall.trim.corrected |   20143 | 173.96M |  8468 |
| X80.trim.contig     | 4657933 | 4657933 |     1 |
| Xall.trim.contig    | 4670240 | 4670240 |     1 |


Table: statFinal

| Name                     |     N50 |     Sum |    # |
|:-------------------------|--------:|--------:|-----:|
| Genome                   | 4641652 | 4641652 |    1 |
| 7_mergeAnchors.anchors   |   40963 | 4497177 |  199 |
| 7_mergeAnchors.others    |    2093 |  465083 |  255 |
| anchorLong               |   40963 | 4496671 |  198 |
| anchorFill               |  651795 | 4572588 |   19 |
| canu_X80-trim            | 4657933 | 4657933 |    1 |
| canu_Xall-trim           | 4670240 | 4670240 |    1 |
| spades.contig            |  132608 | 4574598 |  140 |
| spades.scaffold          |  133063 | 4574782 |  136 |
| spades.non-contained     |  132608 | 4555564 |   75 |
| spades_MR.contig         |  148607 | 4587655 |  148 |
| spades_MR.scaffold       |  148607 | 4587855 |  146 |
| spades_MR.non-contained  |  148607 | 4570765 |   76 |
| megahit.contig           |   82825 | 4569602 |  154 |
| megahit.non-contained    |   82825 | 4550829 |  106 |
| megahit_MR.contig        |  132896 | 4608829 |  126 |
| megahit_MR.non-contained |  132896 | 4585602 |   68 |
| platanus.contig          |   14750 | 4713278 | 1179 |
| platanus.scaffold        |  148483 | 4577580 |  142 |
| platanus.non-contained   |  176491 | 4559796 |   64 |

