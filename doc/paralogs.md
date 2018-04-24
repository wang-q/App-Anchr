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
    --id    559292 --name 559292=s288c  \
    --id    7227   --name 7227=iso_1    \
    --id    6239   --name 6239=n2       \
    --id    3702   --name 3702=col_0    \
    --id    39947  --name 39947=nip     \
    --id    3880   --name 3880=a17      \
    \
    --id    222523 --name 222523=Bcer   \
    --id    272943 --name 272943=Rsph   \
    --id    561007 --name 561007=Mabs   \
    --id    243277 --name 243277=Vcho   \
    \
    --id    198214 --name 198214=Sfle   \
    --id    223926 --name 223926=Vpar   \
    --id    169963 --name 169963=Lmon   \
    --id    272624 --name 272624=Lpne   \
    --id    272563 --name 272563=Cdif   \
    --id    192222 --name 192222=Cjej   \
    --id    242231 --name 242231=Ngon   \
    --id    122586 --name 122586=Nmen   \
    --id    257313 --name 257313=Bper   \
    --id    257309 --name 257309=Cdip   \
    --id    177416 --name 177416=Ftul   \
    --id    71421  --name 71421=Hinf    \
    --file  taxon.csv                   \
    --entrez

```

## Prepare genomes

```bash
mkdir -p ~/data/anchr/paralogs/genomes
cd ~/data/anchr/paralogs/genomes

for strain in e_coli Bcer Rsph Mabs Vcho; do
    if [ -d ${strain} ]; then
        echo >&2 Skip ${strain};
        continue;
    fi

    egaz prepseq \
        ~/data/anchr/${strain}/1_genome/genome.fa -o ${strain} \
        --repeatmasker '--parallel 16' -v
done

for strain in s288c iso_1 n2 col_0 nip a17; do
    if [ -d ${strain} ]; then
        echo >&2 Skip ${strain};
        continue;
    fi

    egaz prepseq \
        ~/data/anchr/${strain}/1_genome/genome.fa -o ${strain} \
        -v
done

for strain in Sfle Vpar Lmon Lpne Cdif Cjej Ngon Nmen Bper Cdip Ftul Hinf; do
    mkdir -p ~/data/anchr/paralogs/genomes/${strain}
    faops split-name ~/data/anchr/${strain}/1_genome/genome.fa ~/data/anchr/paralogs/genomes/${strain}
done

```

## Self-alignments

```bash
cd ~/data/anchr/paralogs

egaz template \
    genomes/Bcer genomes/Rsph genomes/Mabs genomes/Vcho \
    -o gage/ \
    --self \
    --taxon taxon.csv \
    --length 1000 --parallel 16 -v

bash gage/1_self_cmd.sh
bash gage/3_proc_cmd.sh

```

```bash
cd ~/data/anchr/paralogs

egaz template \
    genomes/e_coli genomes/s288c genomes/iso_1 genomes/n2 \
    genomes/col_0 genomes/nip \
    -o model/ \
    --self \
    --taxon taxon.csv \
    --length 1000 --parallel 16 -v

bash model/1_self_cmd.sh
bash model/3_proc_cmd.sh

```

```bash
cd ~/data/anchr/paralogs

perl ~/Scripts/egaz/self_batch.pl \
    --working_dir ~/data/anchr/paralogs \
    --seq_dir ~/data/anchr/paralogs/genomes \
    -c ~/data/anchr/paralogs/taxon.csv \
    --length 1000 \
    --name otherbac \
    -t Sfle \
    -q Vpar \
    -q Lmon \
    -q Lpne \
    -q Cdif \
    -q Cjej \
    -q Ngon \
    -q Nmen \
    -q Bper \
    -q Cdip \
    -q Ftul \
    -q Hinf \
    --parallel 16

bash otherbac/1_real_chr.sh
bash otherbac/2_file_rm.sh
bash otherbac/3_self_cmd.sh
bash otherbac/4_proc_cmd.sh
bash otherbac/5_circos_cmd.sh
```

All done.
