# Detect paralogs in model organisms

End users of [ANCHR](https://github.com/wang-q/App-Anchr) don't need to run the following codes. We
use paralogs just for quality assessments.

These steps require an unpublished project: [withncbi](https://github.com/wang-q/withncbi).

Paralogs detected here **may** overlap with transposons/retrotransposons.

## Prepare genomes

```bash
mkdir -p ~/data/anchr/paralogs/genomes
cd ~/data/anchr/paralogs/genomes

for strain in e_coli Bcer Mabs Rsph Vcho; do
    if [ -d ${strain} ]; then
        echo >&2 Skip ${strain};
        continue;
    fi

    if [ ! -e ~/data/anchr/${strain}/1_genome/genome.fa ]; then
        echo >&2 Skip ${strain};
        continue;
    fi

    egaz prepseq \
        ~/data/anchr/${strain}/1_genome/genome.fa -o ${strain} \
        --repeatmasker '--parallel 16' -v
done

for strain in Bper Cdif Cdip Cjej Ftul Hinf Lmon Lpne Ngon Nmen Sfle Vpar; do
    if [ -d ${strain} ]; then
        echo >&2 Skip ${strain};
        continue;
    fi

    egaz prepseq \
        ~/data/anchr/${strain}/1_genome/genome.fa -o ${strain} \
        --repeatmasker '--parallel 16' -v
done

# soft-masked by ensembl 
for strain in s288c iso_1 n2 col_0 nip; do
    if [ -d ${strain} ]; then
        echo >&2 Skip ${strain};
        continue;
    fi

    egaz prepseq \
        ~/data/anchr/${strain}/1_genome/genome.fa -o ${strain} \
        -v
done

```

## Self-alignments

```bash
cd ~/data/anchr/paralogs

egaz template \
    genomes/Bcer genomes/Mabs genomes/Rsph genomes/Vcho \
    --self -o gage/ \
    --circos \
    --length 1000 --parallel 16 -v

bash gage/1_self.sh
bash gage/3_proc.sh
bash gage/4_circos.sh

```

```bash
cd ~/data/anchr/paralogs

egaz template \
    genomes/Bper genomes/Cdif genomes/Cdip genomes/Cjej \
    genomes/Ftul genomes/Hinf genomes/Lmon genomes/Lpne \
    genomes/Ngon genomes/Nmen genomes/Sfle genomes/Vpar \
    --self -o otherbac/ \
    --circos \
    --length 1000 --parallel 16 -v

bash otherbac/1_self.sh
bash otherbac/3_proc.sh
bash otherbac/4_circos.sh

```

```bash
cd ~/data/anchr/paralogs

egaz template \
    genomes/e_coli genomes/s288c genomes/iso_1 genomes/n2 genomes/col_0 genomes/nip \
    --self -o model/ \
    --circos \
    --length 1000 --parallel 16 -v

bash model/1_self.sh
bash model/3_proc.sh
bash model/4_circos.sh

```
