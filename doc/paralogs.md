# Detect paralogs in model organisms

End users of [ANCHR](https://github.com/wang-q/App-Anchr) don't need to run the following codes. We
use paralogs just for quality assessments.

These steps require two unpublished projects: [egaz](https://github.com/wang-q/egaz) and
[withncbi](https://github.com/wang-q/withncbi).

Paralogs detected here **may** overlap with transposons/retrotransposons.

## Taxonomy for each strains

```bash
mkdir -p ~/data/anchr/paralogs
cd ~/data/anchr/paralogs

perl        ~/Scripts/withncbi/taxon/strain_info.pl \
    --id    511145 --name 511145=e_coli \
    --id    272943 --name 272943=Rsph   \
    --id    561007 --name 1001740=Mabs  \
    --id    243277 --name 991923=Vcho   \
    --id    559292 --name 559292=s288c  \
    --id    7227   --name 7227=iso_1    \
    --id    6239   --name 6239=n2       \
    --id    3702   --name 3702=col_0    \
    --file  taxon.csv                   \
    --entrez
```

## Prepare genomes

```bash
mkdir -p ~/data/anchr/paralogs/genomes
cd ~/data/anchr/paralogs/genomes

for strain in e_coli Rsph Mabs Vcho s288c iso_1 n2 col_0; do
    mkdir -p ~/data/anchr/paralogs/genomes/${strain}
    faops split-name ~/data/anchr/${strain}/1_genome/genome.fa ~/data/anchr/paralogs/genomes/${strain}
done
```

## Self-alignments

```bash
cd ~/data/anchr/paralogs

perl ~/Scripts/egaz/self_batch.pl \
    --working_dir ~/data/anchr/paralogs \
    --seq_dir ~/data/anchr/paralogs/genomes \
    -c ~/data/anchr/paralogs/taxon.csv \
    --length 1000 \
    --norm \
    --name model \
    -t e_coli \
    -q Rsph \
    -q Mabs \
    -q Vcho \
    -q s288c \
    -q iso_1 \
    -q n2 \
    -q col_0 \
    --parallel 16

bash model/1_real_chr.sh
bash model/3_self_cmd.sh
bash model/4_proc_cmd.sh
bash model/5_circos_cmd.sh
```

All done.
