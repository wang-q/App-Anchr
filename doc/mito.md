# Yeast mitochondria


# *Saccharomyces cerevisiae* S288c

* Genome: [Ensembl 82](http://sep2015.archive.ensembl.org/Saccharomyces_cerevisiae/Info/Index)
* Proportion of paralogs (> 1000 bp): 0.058

## s288cMito: download

* Reference genome

```bash
mkdir -p ${HOME}/data/anchr/s288cMito
cd ${HOME}/data/anchr/s288cMito

mkdir -p 1_genome
cd 1_genome

faops order ~/data/anchr/s288c/1_genome/genome.fa \
    <(for chr in {I,II,III,IV,V,VI,VII,VIII,IX,X,XI,XII,XIII,XIV,XV,XVI}; do echo $chr; done) \
    ref.fa

faops order ~/data/anchr/s288c/1_genome/genome.fa \
    <(echo Mito) \
    genome.fa

```

* Illumina

```bash
mkdir -p ${HOME}/data/anchr/s288cMito/2_illumina
cd ${HOME}/data/anchr/s288cMito/2_illumina

ln -sf ${HOME}/data/anchr/s288c/2_illumina/R1.fq.gz R1.fq.gz
ln -sf ${HOME}/data/anchr/s288c/2_illumina/R2.fq.gz R2.fq.gz

mkdir -p ${HOME}/data/anchr/s288cMito/2_illumina/trim
cd ${HOME}/data/anchr/s288cMito/2_illumina/trim

ln -sf ${HOME}/data/anchr/s288c/2_illumina/trim/R1.fq.gz R1.fq.gz
ln -sf ${HOME}/data/anchr/s288c/2_illumina/trim/R2.fq.gz R2.fq.gz

```

## s288cMito: ref

```bash
mkdir -p ${HOME}/data/anchr/s288cMito/2_illumina/ref
cd ${HOME}/data/anchr/s288cMito/2_illumina/ref

anchr trim \
    --dedupe \
    --qual 20 --len 60 \
    --filter "adapter,artifact" \
    --artifact ../../1_genome/ref.fa \
    --matchk 31 \
    --parallel 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o trim.sh
bash trim.sh

tadwrapper.sh \
    in=filter.fq.gz \
    out=contigs_%.fa \
    k=31,41,51,61,71,81 bisect \
    outfinal=contigs.fa

# Alignment; only use merged reads
bbmap.sh \
    in=filter.fq.gz \
    outm=mapped.sam.gz outu=unmapped.sam.gz \
    ref=../../1_genome/genome.fa \
    nodisk slow bs=bs.sh overwrite

callvariants.sh \
    in=mapped.sam.gz out=vars.txt \
    vcf=vars.vcf.gz ref=../../1_genome/genome.fa \
    ploidy=1 overwrite

# Generate a bam file, if viewing in IGV is desired.
bash bs.sh

mkdir -p ${HOME}/data/anchr/s288cMito/2_illumina/mergereads
cd ${HOME}/data/anchr/s288cMito/2_illumina/mergereads

anchr mergereads \
    --ecphase "1,3" \
    --parallel 16 \
    ../trim/filter.fq.gz \
    -o mergereads.sh
bash mergereads.sh

tadwrapper.sh \
    in=pe.cor.fa.gz \
    out=contigs_%.fa \
    k=25,55,95,125 bisect \
    outfinal=contigs.fa

```

## s288cMito: filter

```bash
mkdir -p ${HOME}/data/anchr/s288cMito/2_illumina/filter
cd ${HOME}/data/anchr/s288cMito/2_illumina/filter

clumpify.sh \
    in=../trim/R1.fq.gz \
    in2=../trim/R2.fq.gz \
    out=reads.fq.gz \
    dedupe dupesubs=0

kmercountexact.sh \
    in=reads.fq.gz \
    khist=khist_raw.txt peaks=peaks_raw.txt

primary=`grep "haploid_fold_coverage" peaks_raw.txt | sed "s/^.*\t//g"`
cutoff=$(( $primary * 3 ))

bbnorm.sh in=reads.fq.gz out=highpass.fq.gz pigz passes=1 bits=16 min=$cutoff target=9999999
#reformat.sh in=highpass.fq.gz out=highpass_gc.fq.gz maxgc=0.45

#fastqc highpass.fq.gz highpass_gc.fq.gz

kmercountexact.sh \
    in=highpass.fq.gz \
    khist=khist_100.txt k=100 \
    peaks=peaks_100.txt \
    smooth ow smoothradius=1 maxradius=1000 progressivemult=1.06 maxpeaks=16 prefilter=2

mitopeak=`grep "main_peak" peaks_100.txt | sed "s/^.*\t//g"`

upper=$((mitopeak * 6 / 3))
lower=$((mitopeak * 3 / 7))
mcs=$((mitopeak * 3 / 4))
mincov=$((mitopeak * 2 / 3))

tadwrapper.sh \
    in=highpass_gc.fq.gz \
    out=contigs_intermediate_%.fa \
    k=78,100,120 \
    outfinal=contigs_intermediate.fa prefilter=2 mincr=$lower maxcr=$upper mcs=$mcs mincov=$mincov

bbduk.sh \
    in=highpass.fq.gz \
    ref=contigs_intermediate.fa \
    outm=bbd005.fq.gz k=31 mm=f mkf=0.05

tadpole.sh \
    in=bbd005.fq.gz \
    out=contigs_bbd.fa \
    prefilter=2 mincr=$((mitopeak * 3 / 8)) maxcr=$((upper * 2)) mcs=$mcs mincov=$mincov k=100 bm1=6

```

```bash
cd ${HOME}/data/anchr/s288cMito

rm -fr 9_quast_mito
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    ${HOME}/data/anchr/s288cMito/2_illumina/trim/contigs.fa \
    ${HOME}/data/anchr/s288cMito/2_illumina/mergereads/contigs.fa \
    ${HOME}/data/anchr/s288cMito/2_illumina/filter/contigs_bbd.fa \
    --label "trim,mergereads,filter" \
    -o 9_quast_mito



```

