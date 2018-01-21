package App::Anchr::Command::template;
use strict;
use warnings;
use autodie;

use App::Anchr -command;
use App::Anchr::Common;

use constant abstract => "create executing bash files";

sub opt_spec {
    return (
        [ "basename=s", "the basename of this genome, default is the working directory", ],
        [ "genome=i",   "your best guess of the haploid genome size", ],
        [ "is_euk",     "eukaryotes or not", ],
        [ "tmp=s",      "user defined tempdir", ],
        [ "parallel|p=i", "number of threads", { default => 16 }, ],
        [ "se",           "single end mode for Illumina", ],
        [ "separate",     "separate each Qual-Len/Cov-Qual groups", ],
        [],
        [ "trim2=s", "steps for trimming Illumina reads", { default => "--uniq --bbduk" }, ],
        [ "sample2=i", "total sampling coverage of Illumina reads", ],
        [ "cov2=s",   "down sampling coverage of Illumina reads",  { default => "40 80" }, ],
        [ "qual2=s",  "quality threshold",                         { default => "25 30" }, ],
        [ "len2=s",   "filter reads less or equal to this length", { default => "60" }, ],
        [ "filter=s", "adapter, phix, artifact",                   { default => "adapter" }, ],
        [ 'tadpole',  'use tadpole to create k-unitigs', ],
        [ 'megahit',  'feed megahit with sampled mergereads', ],
        [ 'spades',   'feed spades with sampled mergereads', ],
        [],
        [ "cov3=s", "down sampling coverage of PacBio reads", ],
        [ "qual3=s", "raw and/or trim", { default => "trim" } ],
        [],
        [ 'mergereads',  'also run the mergereads approach', ],
        [ "tile",        "with normal Illumina names, do tile based filtering", ],
        [ "prefilter=i", "prefilter=N (1 or 2) for tadpole and bbmerge", ],
        [ 'ecphase=s', 'Error-correct phases', { default => "1,2,3", }, ],
        [],
        [ 'insertsize', 'calc the insert sizes', ],
        [ "reads=i", "how many reads to estimate insert size", { default => 1000000 }, ],
        { show_defaults => 1, }
    );
}

sub usage_desc {
    return "anchr template [options] <working directory>";
}

sub description {
    my $desc;
    $desc .= ucfirst(abstract) . ".\n";
    $desc .= "\tFastq files can be gzipped\n";
    return $desc;
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;

    if ( @{$args} != 1 ) {
        my $message = "This command need one directory.\n\tIt found";
        $message .= sprintf " [%s]", $_ for @{$args};
        $message .= ".\n";
        $self->usage_error($message);
    }
    for ( @{$args} ) {
        if ( !Path::Tiny::path($_)->is_dir ) {
            $self->usage_error("The input directory [$_] doesn't exist.");
        }
    }

    $args->[0] = Path::Tiny::path( $args->[0] )->absolute;

    if ( !$opt->{basename} ) {
        $opt->{basename} = Path::Tiny::path( $args->[0] )->basename();
    }

    $opt->{parallel2} = int( $opt->{parallel} / 2 );
    $opt->{parallel2} = 2 if $opt->{parallel2} < 2;

}

sub execute {
    my ( $self, $opt, $args ) = @_;

    # fastqc
    $self->gen_fastqc( $opt, $args );

    # kmergenie
    $self->gen_kmergenie( $opt, $args );

    # insertSize
    $self->gen_insertSize( $opt, $args );

    # mergereads
    $self->gen_mergereads( $opt, $args );

    # trim2
    $self->gen_trim( $opt, $args );

    # trimlong
    $self->gen_trimlong( $opt, $args );

    # statReads
    $self->gen_statReads( $opt, $args );

    # quorum
    $self->gen_quorum( $opt, $args );

    # statQuorum
    $self->gen_statQuorum( $opt, $args );

    # downSampling
    $self->gen_downSampling( $opt, $args );

    # kunitigs
    $self->gen_kunitigs( $opt, $args );

    # anchors
    $self->gen_anchors( $opt, $args );

    # statAnchors
    $self->gen_statAnchors( $opt, $args );

    # 6_downSampling
    $self->gen_6_downSampling( $opt, $args );

    # 6_kunitigs
    $self->gen_6_kunitigs( $opt, $args );

    # 6_anchors
    $self->gen_6_anchors( $opt, $args );

    # 6_statAnchors
    $self->gen_statMRAnchors( $opt, $args );

    # mergeAnchors
    $self->gen_mergeAnchors( $opt, $args );

    # canu
    $self->gen_canu( $opt, $args );

    # statCanu
    $self->gen_statCanu( $opt, $args );

    # anchorLong
    $self->gen_anchorLong( $opt, $args );

    # anchorFill
    $self->gen_anchorFill( $opt, $args );

    # spades
    $self->gen_spades( $opt, $args );

    # megahit
    $self->gen_megahit( $opt, $args );

    # platanus
    $self->gen_platanus( $opt, $args );

    # quast
    $self->gen_quast( $opt, $args );

    # statFinal
    $self->gen_statFinal( $opt, $args );

    # cleanup
    $self->gen_cleanup( $opt, $args );

    # realClean
    $self->gen_realClean( $opt, $args );

    # master
    $self->gen_master( $opt, $args );

}

sub gen_fastqc {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "2_fastqc.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn 2_fastqc.sh

cd [% args.0 %]

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

if [ -e R1_fastqc.html ]; then
    exit;
fi

fastqc -t [% opt.parallel %] \
    ../R1.fq.gz [% IF not opt.se %]../R2.fq.gz[% END %] \
    -o .

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_kmergenie {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "2_kmergenie.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn 2_kmergenie.sh

cd [% args.0 %]

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

if [ -e R1.dat.pdf ]; then
    exit;
fi

parallel --no-run-if-empty --linebuffer -k -j 2 "
    kmergenie -l 21 -k 121 -s 10 -t [% opt.parallel2 %] --one-pass ../{}.fq.gz -o {}
    " ::: R1  [% IF not opt.se %]R2[% END %]

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_mergereads {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    return unless $opt->{mergereads};
    return if $opt->{se};

    $sh_name = "2_mergereads.sh";
    print "Create $sh_name\n";

    $tt->process(
        '2_mergereads.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_trim {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "2_trim.sh";
    print "Create $sh_name\n";

    $tt->process(
        '2_trim.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_trimlong {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    return unless $opt->{cov3};

    $sh_name = "3_trimlong.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn 3_trimlong.sh

cd [% args.0 %]

for X in [% opt.cov3 %]; do
    printf "==> Coverage: %s\n" ${X}

    if [ -e 3_pacbio/pacbio.X${X}.raw.fasta ]; then
        echo "  pacbio.X${X}.raw.fasta presents";
        continue;
    fi

    # shortcut if cov3 == all
    if [[ ${X} == "all" ]]; then
        pushd 3_pacbio > /dev/null

        ln -s pacbio.fasta pacbio.X${X}.raw.fasta

        popd > /dev/null
        continue;
    fi

    faops split-about -m 1 -l 0 \
        3_pacbio/pacbio.fasta \
        $(( [% opt.genome %] * ${X} )) \
        3_pacbio

    mv 3_pacbio/000.fa "3_pacbio/pacbio.X${X}.raw.fasta"
done

for X in  [% opt.cov3 %]; do
    printf "==> Coverage: %s\n" ${X}

    if [ -e 3_pacbio/pacbio.X${X}.trim.fasta ]; then
        echo "  pacbio.X${X}.trim.fasta presents";
        continue;
    fi

    anchr trimlong --parallel [% opt.parallel2 %] -v \
        "3_pacbio/pacbio.X${X}.raw.fasta" \
        -o "3_pacbio/pacbio.X${X}.trim.fasta"
done

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_statReads {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "9_statReads.sh";
    print "Create $sh_name\n";

    $tt->process(
        '9_statReads.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_insertSize {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    return if $opt->{se};
    return unless $opt->{insertsize};

    $sh_name = "2_insertSize.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn 2_insertSize.sh

cd [% args.0 %]

mkdir -p 2_illumina/insertSize
cd 2_illumina/insertSize

if [ -e ihist.tadpole.txt ]; then
    exit;
fi

if [ -e ihist.genome.txt ]; then
    exit;
fi

tadpole.sh \
    in=../R1.fq.gz \
    in2=../R2.fq.gz \
    out=tadpole.contig.fasta \
    threads=[% opt.parallel %] \
    overwrite

bbmap.sh \
    in=../R1.fq.gz \
    in2=../R2.fq.gz \
    out=tadpole.sam.gz \
    ref=tadpole.contig.fasta \
    threads=[% opt.parallel %] \
    pairedonly \
    reads=[% opt.reads %] \
    nodisk overwrite

reformat.sh \
    in=tadpole.sam.gz \
    ihist=ihist.tadpole.txt \
    overwrite

picard SortSam \
    I=tadpole.sam.gz \
    O=tadpole.sort.bam \
    SORT_ORDER=coordinate \
    VALIDATION_STRINGENCY=LENIENT

picard CollectInsertSizeMetrics \
    I=tadpole.sort.bam \
    O=insert_size.tadpole.txt \
    HISTOGRAM_FILE=insert_size.tadpole.pdf

if [ -e ../../1_genome/genome.fa ]; then
    bbmap.sh \
        in=../R1.fq.gz \
        in2=../R2.fq.gz \
        out=genome.sam.gz \
        ref=../../1_genome/genome.fa \
        threads=[% opt.parallel %] \
        maxindel=0 strictmaxindel \
        reads=[% opt.reads %] \
        nodisk overwrite

    reformat.sh \
        in=genome.sam.gz \
        ihist=ihist.genome.txt \
        overwrite

    picard SortSam \
        I=genome.sam.gz \
        O=genome.sort.bam \
        SORT_ORDER=coordinate \
        VALIDATION_STRINGENCY=LENIENT

    picard CollectInsertSizeMetrics \
        I=genome.sort.bam \
        O=insert_size.genome.txt \
        HISTOGRAM_FILE=insert_size.genome.pdf

fi

echo -e "Table: statInsertSize\n" > statInsertSize.md
printf "| %s | %s | %s | %s | %s |\n" \
    "Group" "Mean" "Median" "STDev" "PercentOfPairs/PairOrientation" \
    >> statInsertSize.md
printf "|:--|--:|--:|--:|--:|\n" >> statInsertSize.md

# bbtools reformat.sh
#Mean	339.868
#Median	312
#Mode	251
#STDev	134.676
#PercentOfPairs	36.247
for G in genome tadpole; do
    if [ ! -e ihist.${G}.txt ]; then
        continue;
    fi

    printf "| %s " "${G}.bbtools" >> statInsertSize.md
    cat ihist.${G}.txt \
        | perl -nla -e '
            BEGIN { our $stat = { }; };

            m{\#(Mean|Median|STDev|PercentOfPairs)} or next;
            $stat->{$1} = $F[1];

            END {
                printf qq{| %.1f | %s | %.1f | %.2f%% |\n},
                    $stat->{Mean},
                    $stat->{Median},
                    $stat->{STDev},
                    $stat->{PercentOfPairs};
            }
            ' \
        >> statInsertSize.md
done

# picard CollectInsertSizeMetrics
#MEDIAN_INSERT_SIZE	MODE_INSERT_SIZE	MEDIAN_ABSOLUTE_DEVIATION	MIN_INSERT_SIZE	MAX_INSERT_SIZE	MEAN_INSERT_SIZE	STANDARD_DEVIATION	READ_PAIRS	PAIR_ORIENTATION	WIDTH_OF_10_PERCENT	WIDTH_OF_20_PERCENT	WIDTH_OF_30_PERCENT	WIDTH_OF_40_PERCENT	WIDTH_OF_50_PERCENT	WIDTH_OF_60_PERCENT	WIDTH_OF_70_PERCENT	WIDTH_OF_80_PERCENT	WIDTH_OF_90_PERCENT	WIDTH_OF_95_PERCENT	WIDTH_OF_99_PERCENT	SAMPLE	LIBRARY	READ_GROUP
#296	287	14	92	501	294.892521	21.587526	1611331	FR	7	11	17	23	29	35	41	49	63	81	145
for G in genome tadpole; do
    if [ ! -e insert_size.${G}.txt ]; then
        continue;
    fi

    cat insert_size.${G}.txt \
        | G=${G} perl -nla -F"\t" -e '
            next if @F < 9;
            next unless /^\d/;
            printf qq{| %s | %.1f | %s | %.1f | %s |\n},
                qq{$ENV{G}.picard},
                $F[5],
                $F[0],
                $F[6],
                $F[8];
            ' \
        >> statInsertSize.md
done

find . -type f -name "*.sam.gz" -or -name "*.sort.bam" \
    | parallel --no-run-if-empty -j 1 rm

cat statInsertSize.md

mv statInsertSize.md ../../

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_quorum {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    if ( !$opt->{separate} ) {
        $sh_name = "2_quorum.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn 2_quorum.sh

cd [% args.0 %]

parallel --no-run-if-empty --linebuffer -k -j 1 "
    cd 2_illumina/Q{1}L{2}
    echo >&2 '==> Qual-Len: Q{1}L{2} <=='

    if [ ! -e R1.sickle.fq.gz ]; then
        echo >&2 '    R1.sickle.fq.gz not exists'
        exit;
    fi

    if [ -e pe.cor.fa.gz ]; then
        echo >&2 '    pe.cor.fa.gz exists'
        exit;
    fi

    anchr quorum \
        R1.sickle.fq.gz \
[% IF not opt.se -%]
        R2.sickle.fq.gz \
        \$(
            if [ -e Rs.sickle.fq.gz ]; then
                echo Rs.sickle.fq.gz;
            fi
        ) \
[% END -%]
        -p [% opt.parallel %] \
        -o quorum.sh
    bash quorum.sh

    find . -type f -name "quorum_mer_db.jf" | parallel --no-run-if-empty -j 1 rm
    find . -type f -name "k_u_hash_0"       | parallel --no-run-if-empty -j 1 rm
    find . -type f -name "*.tmp"            | parallel --no-run-if-empty -j 1 rm
    find . -type f -name "pe.renamed.fastq" | parallel --no-run-if-empty -j 1 rm
    find . -type f -name "se.renamed.fastq" | parallel --no-run-if-empty -j 1 rm
    find . -type f -name "pe.cor.sub.fa"    | parallel --no-run-if-empty -j 1 rm
    find . -type f -name "pe.cor.log"       | parallel --no-run-if-empty -j 1 rm

    echo >&2
    " ::: [% opt.qual2 %] ::: [% opt.len2 %]

EOF
        $tt->process(
            \$template,
            {   args => $args,
                opt  => $opt,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }
    else {
        for my $qual ( grep {defined} split /\s+/, $opt->{qual2} ) {
            for my $len ( grep {defined} split /\s+/, $opt->{len2} ) {
                $sh_name = "2_quorum_Q${qual}L${len}.sh";
                print "Create $sh_name\n";
                $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn 2_quorum.sh

cd [% args.0 %]

cd 2_illumina/Q[% qual %]L[% len %]
echo >&2 '==> Qual-Len: Q[% qual %]L[% len %] <=='

if [ ! -e R1.sickle.fq.gz ]; then
    echo >&2 '    R1.sickle.fq.gz not exists'
    exit;
fi

if [ -e pe.cor.fa.gz ]; then
    echo >&2 '    pe.cor.fa.gz exists'
    exit;
fi

anchr quorum \
    R1.sickle.fq.gz \
[% IF not opt.se -%]
    R2.sickle.fq.gz \
    \$(
        if [ -e Rs.sickle.fq.gz ]; then
            echo Rs.sickle.fq.gz;
        fi
    ) \
[% END -%]
    -p [% opt.parallel %] \
    -o quorum.sh
bash quorum.sh

EOF
                $tt->process(
                    \$template,
                    {   args => $args,
                        opt  => $opt,
                        qual => $qual,
                        len  => $len,
                    },
                    Path::Tiny::path( $args->[0], $sh_name )->stringify
                ) or die Template->error;
            }
        }
    }

}

sub gen_statQuorum {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "9_statQuorum.sh";
    print "Create $sh_name\n";

    $tt->process(
        '9_statQuorum.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_downSampling {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "4_downSampling.sh";
    print "Create $sh_name\n";

    $tt->process(
        '4_downSampling.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_6_downSampling {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    return unless $opt->{mergereads};
    return if $opt->{se};

    $sh_name = "6_downSampling.sh";
    print "Create $sh_name\n";

    $tt->process(
        '6_downSampling.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_kunitigs {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "4_kunitigs.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

cd [% args.0 %]

parallel --no-run-if-empty --linebuffer -k -j 1 "
    if [ ! -e 4_Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'
    if [ -e 4_kunitigs_Q{1}L{2}X{3}P{4}/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi

    mkdir -p 4_kunitigs_Q{1}L{2}X{3}P{4}
    cd 4_kunitigs_Q{1}L{2}X{3}P{4}

    anchr kunitigs \
        ../4_Q{1}L{2}X{3}P{4}/pe.cor.fa \
        ../4_Q{1}L{2}X{3}P{4}/environment.json \
        -p [% opt.parallel %] \
        --kmer 31,41,51,61,71,81 \
        -o kunitigs.sh
    bash kunitigs.sh

    echo >&2
    " ::: [% opt.qual2 %] ::: [% opt.len2 %] ::: [% opt.cov2 %] ::: $(printf "%03d " {0..50})

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

    if ( $opt->{tadpole} ) {
        $sh_name = "4_tadpole.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

cd [% args.0 %]

parallel --no-run-if-empty --linebuffer -k -j 1 "
    if [ ! -e 4_Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'
    if [ -e 4_tadpole_Q{1}L{2}X{3}P{4}/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi

    mkdir -p 4_tadpole_Q{1}L{2}X{3}P{4}
    cd 4_tadpole_Q{1}L{2}X{3}P{4}

    anchr kunitigs \
        ../4_Q{1}L{2}X{3}P{4}/pe.cor.fa \
        ../4_Q{1}L{2}X{3}P{4}/environment.json \
        -p [% opt.parallel %] \
        --kmer 31,41,51,61,71,81 \
        --tadpole \
        -o kunitigs.sh
    bash kunitigs.sh

    echo >&2
    " ::: [% opt.qual2 %] ::: [% opt.len2 %] ::: [% opt.cov2 %] ::: $(printf "%03d " {0..50})

EOF
        $tt->process(
            \$template,
            {   args => $args,
                opt  => $opt,
                sh   => $sh_name,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }

    if ( $opt->{megahit} ) {
        $sh_name = "4_megahit.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

cd [% args.0 %]

parallel --no-run-if-empty --linebuffer -k -j 1 "
    if [ ! -e 4_Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'
    if [ -e 4_megahit_Q{1}L{2}X{3}P{4}/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi

    mkdir -p 4_megahit_Q{1}L{2}X{3}P{4}
    cd 4_megahit_Q{1}L{2}X{3}P{4}

    ln -s ../4_Q{1}L{2}X{3}P{4}/pe.cor.fa pe.cor.fa
    cp ../4_Q{1}L{2}X{3}P{4}/environment.json environment.json

    START_TIME=\$(date +%s)

    megahit \
        -t [% opt.parallel %] \
        --k-list 31,41,51,61,71,81 \
        --12 pe.cor.fa \
        --min-count 3 \
        -o megahit_out

    anchr contained \
        megahit_out/final.contigs.fa \
        --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
        -o stdout \
        | faops filter -a 1000 -l 0 stdin k_unitigs.fasta

    END_TIME=\$(date +%s)
    RUNTIME=\$((END_TIME-START_TIME))

    TJQ=\$(jq \".RUNTIME = \"\${RUNTIME}\"\" < environment.json)
    [[ \$? == 0 ]] && echo \"\${TJQ}\" >| environment.json

    SUM_COR=\$( faops n50 -H -N 0 -S pe.cor.fa )

    TJQ=\$(jq \".SUM_COR = \"\${SUM_COR}\"\" < environment.json)
    [[ \$? == 0 ]] && echo \"\${TJQ}\" >| environment.json

    echo >&2
    " ::: [% opt.qual2 %] ::: [% opt.len2 %] ::: [% opt.cov2 %] ::: $(printf "%03d " {0..50})

EOF
        $tt->process(
            \$template,
            {   args => $args,
                opt  => $opt,
                sh   => $sh_name,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }

    if ( $opt->{spades} ) {
        $sh_name = "4_spades.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

cd [% args.0 %]

parallel --no-run-if-empty --linebuffer -k -j 1 "
    if [ ! -e 4_Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'
    if [ -e 4_spades_Q{1}L{2}X{3}P{4}/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi

    mkdir -p 4_spades_Q{1}L{2}X{3}P{4}
    cd 4_spades_Q{1}L{2}X{3}P{4}

    ln -s ../4_Q{1}L{2}X{3}P{4}/pe.cor.fa pe.cor.fa
    cp ../4_Q{1}L{2}X{3}P{4}/environment.json environment.json

    START_TIME=\$(date +%s)

    spades.py \
        -t [% opt.parallel %] \
        --only-assembler \
        -k 31,41,51,61,71,81 \
        --12 pe.cor.fa \
        -o .

    anchr contained \
        contigs.fasta \
        --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
        -o stdout \
        | faops filter -a 1000 -l 0 stdin k_unitigs.fasta

    find . -type d -not -name "anchor" | parallel --no-run-if-empty -j 1 rm -fr

    END_TIME=\$(date +%s)
    RUNTIME=\$((END_TIME-START_TIME))

    TJQ=\$(jq \".RUNTIME = \"\${RUNTIME}\"\" < environment.json)
    [[ \$? == 0 ]] && echo \"\${TJQ}\" >| environment.json

    SUM_COR=\$( faops n50 -H -N 0 -S pe.cor.fa )

    TJQ=\$(jq \".SUM_COR = \"\${SUM_COR}\"\" < environment.json)
    [[ \$? == 0 ]] && echo \"\${TJQ}\" >| environment.json

    echo >&2
    " ::: [% opt.qual2 %] ::: [% opt.len2 %] ::: [% opt.cov2 %] ::: $(printf "%03d " {0..50})

EOF
        $tt->process(
            \$template,
            {   args => $args,
                opt  => $opt,
                sh   => $sh_name,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }

}

sub gen_6_kunitigs {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    return unless $opt->{mergereads};
    return if $opt->{se};

    $sh_name = "6_kunitigs.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

cd [% args.0 %]

parallel --no-run-if-empty --linebuffer -k -j 1 "
    if [ ! -e 6_MRX{1}P{2}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> Group MRX{1}P{2}'
    if [ -e 6_kunitigs_MRX{1}P{2}/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi

    mkdir -p 6_kunitigs_MRX{1}P{2}
    cd 6_kunitigs_MRX{1}P{2}

    anchr kunitigs \
        ../6_MRX{1}P{2}/pe.cor.fa \
        ../6_MRX{1}P{2}/environment.json \
        -p [% opt.parallel %] \
        --kmer 31,41,51,61,71,81 \
        -o kunitigs.sh
    bash kunitigs.sh

    echo >&2
    " ::: [% opt.cov2 %] ::: $(printf "%03d " {0..50})

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

    if ( $opt->{tadpole} ) {
        $sh_name = "6_tadpole.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

cd [% args.0 %]

parallel --no-run-if-empty --linebuffer -k -j 1 "
    if [ ! -e 6_MRX{1}P{2}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> Group MRX{1}P{2}'
    if [ -e 6_tadpole_MRX{1}P{2}/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi

    mkdir -p 6_tadpole_MRX{1}P{2}
    cd 6_tadpole_MRX{1}P{2}

    anchr kunitigs \
        ../6_MRX{1}P{2}/pe.cor.fa \
        ../6_MRX{1}P{2}/environment.json \
        -p [% opt.parallel %] \
        --kmer 31,41,51,61,71,81 \
        --tadpole \
        -o kunitigs.sh
    bash kunitigs.sh

    echo >&2
    " ::: [% opt.cov2 %] ::: $(printf "%03d " {0..50})

EOF
        $tt->process(
            \$template,
            {   args => $args,
                opt  => $opt,
                sh   => $sh_name,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }

}

sub gen_anchors {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "4_anchors.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn 4_anchors.sh

cd [% args.0 %]

parallel --no-run-if-empty --linebuffer -k -j 2 "
    if [ ! -e 4_Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'
    if [ -e 4_kunitigs_Q{1}L{2}X{3}P{4}/anchor/anchor.fasta ]; then
        echo >&2 '    anchor.fasta already presents'
        exit;
    fi

    rm -fr 4_kunitigs_Q{1}L{2}X{3}P{4}/anchor
    mkdir -p 4_kunitigs_Q{1}L{2}X{3}P{4}/anchor
    cd 4_kunitigs_Q{1}L{2}X{3}P{4}/anchor

    anchr anchors \
        ../k_unitigs.fasta \
        ../pe.cor.fa \
        -p [% opt.parallel2 %] \
        -o anchors.sh
    bash anchors.sh

    echo >&2
    " ::: [% opt.qual2 %] ::: [% opt.len2 %] ::: [% opt.cov2 %] ::: $(printf "%03d " {0..50})

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

    if ( $opt->{tadpole} ) {
        $sh_name = "4_tadpoleAnchors.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn 4_tadpoleAnchors.sh

cd [% args.0 %]

parallel --no-run-if-empty --linebuffer -k -j 2 "
    if [ ! -e 4_Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'
    if [ -e 4_tadpole_Q{1}L{2}X{3}P{4}/anchor/anchor.fasta ]; then
        echo >&2 '    anchor.fasta already presents'
        exit;
    fi

    rm -fr 4_tadpole_Q{1}L{2}X{3}P{4}/anchor
    mkdir -p 4_tadpole_Q{1}L{2}X{3}P{4}/anchor
    cd 4_tadpole_Q{1}L{2}X{3}P{4}/anchor

    anchr anchors \
        ../k_unitigs.fasta \
        ../pe.cor.fa \
        -p [% opt.parallel2 %] \
        -o anchors.sh
    bash anchors.sh

    echo >&2
    " ::: [% opt.qual2 %] ::: [% opt.len2 %] ::: [% opt.cov2 %] ::: $(printf "%03d " {0..50})

EOF
        $tt->process(
            \$template,
            {   args => $args,
                opt  => $opt,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }

    if ( $opt->{megahit} ) {
        $sh_name = "4_megahitAnchors.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn 4_megahitAnchors.sh

cd [% args.0 %]

parallel --no-run-if-empty --linebuffer -k -j 2 "
    if [ ! -e 4_Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'
    if [ -e 4_megahit_Q{1}L{2}X{3}P{4}/anchor/anchor.fasta ]; then
        echo >&2 '    anchor.fasta already presents'
        exit;
    fi

    rm -fr 4_megahit_Q{1}L{2}X{3}P{4}/anchor
    mkdir -p 4_megahit_Q{1}L{2}X{3}P{4}/anchor
    cd 4_megahit_Q{1}L{2}X{3}P{4}/anchor

    anchr anchors \
        ../k_unitigs.fasta \
        ../pe.cor.fa \
        --ratio 0.99 \
        --fill 3 \
        -p [% opt.parallel2 %] \
        -o anchors.sh
    bash anchors.sh

    echo >&2
    " ::: [% opt.qual2 %] ::: [% opt.len2 %] ::: [% opt.cov2 %] ::: $(printf "%03d " {0..50})

EOF
        $tt->process(
            \$template,
            {   args => $args,
                opt  => $opt,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }

    if ( $opt->{spades} ) {
        $sh_name = "4_spadesAnchors.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn 4_spadesAnchors.sh

cd [% args.0 %]

parallel --no-run-if-empty --linebuffer -k -j 2 "
    if [ ! -e 4_Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'
    if [ -e 4_spades_Q{1}L{2}X{3}P{4}/anchor/anchor.fasta ]; then
        echo >&2 '    anchor.fasta already presents'
        exit;
    fi

    rm -fr 4_spades_Q{1}L{2}X{3}P{4}/anchor
    mkdir -p 4_spades_Q{1}L{2}X{3}P{4}/anchor
    cd 4_spades_Q{1}L{2}X{3}P{4}/anchor

    anchr anchors \
        ../k_unitigs.fasta \
        ../pe.cor.fa \
        --ratio 0.99 \
        --fill 3 \
        -p [% opt.parallel2 %] \
        -o anchors.sh
    bash anchors.sh

    echo >&2
    " ::: [% opt.qual2 %] ::: [% opt.len2 %] ::: [% opt.cov2 %] ::: $(printf "%03d " {0..50})

EOF
        $tt->process(
            \$template,
            {   args => $args,
                opt  => $opt,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }

}

sub gen_6_anchors {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    return unless $opt->{mergereads};
    return if $opt->{se};

    $sh_name = "6_anchors.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

cd [% args.0 %]

parallel --no-run-if-empty --linebuffer -k -j 2 "
    if [ ! -e 6_MRX{1}P{2}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> Group MRX{1}P{2}'
    if [ -e 6_kunitigs_MRX{1}P{2}/anchor/anchor.fasta ]; then
        echo >&2 '    anchor.fasta already presents'
        exit;
    fi

    rm -fr 6_kunitigs_MRX{1}P{2}/anchor
    mkdir -p 6_kunitigs_MRX{1}P{2}/anchor
    cd 6_kunitigs_MRX{1}P{2}/anchor

    anchr anchors \
        ../k_unitigs.fasta \
        ../pe.cor.fa \
        -p [% opt.parallel2 %] \
        -o anchors.sh
    bash anchors.sh

    echo >&2
    " ::: [% opt.cov2 %] ::: $(printf "%03d " {0..50})

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
            sh   => $sh_name,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

    if ( $opt->{tadpole} ) {
        $sh_name = "6_tadpoleAnchors.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn [% sh %]

cd [% args.0 %]

parallel --no-run-if-empty --linebuffer -k -j 2 "
    if [ ! -e 6_MRX{1}P{2}/pe.cor.fa ]; then
        exit;
    fi

    echo >&2 '==> Group MRX{1}P{2}'
    if [ -e 6_tadpole_MRX{1}P{2}/anchor/anchor.fasta ]; then
        echo >&2 '    anchor.fasta already presents'
        exit;
    fi

    rm -fr 6_tadpole_MRX{1}P{2}/anchor
    mkdir -p 6_tadpole_MRX{1}P{2}/anchor
    cd 6_tadpole_MRX{1}P{2}/anchor

    anchr anchors \
        ../k_unitigs.fasta \
        ../pe.cor.fa \
        -p [% opt.parallel2 %] \
        -o anchors.sh
    bash anchors.sh

    echo >&2
    " ::: [% opt.cov2 %] ::: $(printf "%03d " {0..50})

EOF
        $tt->process(
            \$template,
            {   args => $args,
                opt  => $opt,
                sh   => $sh_name,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }

}

sub gen_statAnchors {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "9_statAnchors.sh";
    print "Create $sh_name\n";

    $tt->process(
        '9_statAnchors.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_statMRAnchors {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "9_statMRAnchors.sh";
    print "Create $sh_name\n";

    $tt->process(
        '9_statMRAnchors.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_mergeAnchors {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "7_mergeAnchors.sh";
    print "Create $sh_name\n";

    $tt->process(
        '7_mergeAnchors.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

sub gen_canu {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    return unless $opt->{cov3};

    if ( !$opt->{separate} ) {
        $sh_name = "5_canu.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn 5_canu.sh

cd [% args.0 %]

parallel --no-run-if-empty --linebuffer -k -j 1 "
    echo >&2 '==> Group X{1}-{2}'

    if [ ! -e 3_pacbio/pacbio.X{1}.{2}.fasta ]; then
        echo >&2 '  3_pacbio/pacbio.X{1}.{2}.fasta not exists'
        exit;
    fi

    if [ -e 5_canu_X{1}-{2}/*.contigs.fasta ]; then
        echo >&2 '  5_canu_X{1}-{2}/contigs.fasta already presents'
        exit;
    fi

    canu \
        -p [% opt.basename %] \
        -d 5_canu_X{1}-{2} \
        gnuplot="/dev/null" gnuplotTested=true \
        useGrid=false \
        genomeSize=[% opt.genome %] \
        -pacbio-raw 3_pacbio/pacbio.X{1}.{2}.fasta
    " ::: [% opt.cov3 %] ::: [% opt.qual3 %]

# sometimes canu failed
exit;

EOF
        $tt->process(
            \$template,
            {   args => $args,
                opt  => $opt,
            },
            Path::Tiny::path( $args->[0], $sh_name )->stringify
        ) or die Template->error;
    }
    else {
        for my $cov ( grep {defined} split /\s+/, $opt->{cov3} ) {
            for my $qual ( grep {defined} split /\s+/, $opt->{qual3} ) {
                $sh_name = "5_canu_X${cov}-${qual}.sh";
                print "Create $sh_name\n";
                $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn 5_canu.sh

cd [% args.0 %]

echo >&2 '==> Group X[% cov %]-[% qual %]'

if [ ! -e 3_pacbio/pacbio.X[% cov %].[% qual %].fasta ]; then
    echo >&2 '  3_pacbio/pacbio.X{[% cov %].[% qual %].fasta not exists'
    exit;
fi

if [ -e 5_canu_X[% cov %]-[% qual %]/*.contigs.fasta ]; then
    echo >&2 '  5_canu_X[% cov %]-[% qual %]/contigs.fasta already presents'
    exit;
fi

canu \
    -p [% opt.basename %] \
    -d 5_canu_X[% cov %]-[% qual %] \
    gnuplotTested=true \
    useGrid=false \
    genomeSize=[% opt.genome %] \
    -pacbio-raw 3_pacbio/pacbio.X[% cov %].[% qual %].fasta

# sometimes canu failed
exit;

EOF
                $tt->process(
                    \$template,
                    {   args => $args,
                        opt  => $opt,
                        cov  => $cov,
                        qual => $qual,
                    },
                    Path::Tiny::path( $args->[0], $sh_name )->stringify
                ) or die Template->error;
            }

        }
    }

}

sub gen_statCanu {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    return unless $opt->{cov3};

    $sh_name = "9_statCanu.sh";
    print "Create $sh_name\n";

    $tt->process(
        '9_statCanu.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_anchorLong {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    return unless $opt->{cov3};

    $sh_name = "7_anchorLong.sh";
    print "Create $sh_name\n";

    $tt->process(
        '7_anchorLong.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_anchorFill {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    return unless $opt->{cov3};

    $sh_name = "7_anchorFill.sh";
    print "Create $sh_name\n";

    $tt->process(
        '7_anchorFill.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_spades {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "8_spades.sh";
    print "Create $sh_name\n";

    $tt->process(
        '8_spades.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_megahit {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "8_megahit.sh";
    print "Create $sh_name\n";

    $tt->process(
        '8_megahit.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_platanus {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "8_platanus.sh";
    print "Create $sh_name\n";

    $tt->process(
        '8_platanus.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_quast {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "9_quast.sh";
    print "Create $sh_name\n";

    $tt->process(
        '9_quast.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_statFinal {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "9_statFinal.sh";
    print "Create $sh_name\n";

    $tt->process(
        '9_statFinal.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_cleanup {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "0_cleanup.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn 0_cleanup.sh

cd [% args.0 %]

# bax2bam
rm -fr 3_pacbio/bam/*
rm -fr 3_pacbio/fasta/*
rm -fr 3_pacbio/untar/*

# illumina
parallel --no-run-if-empty --linebuffer -k -j 1 "
    if [ -e 2_illumina/{1}.{2}.fq.gz ]; then
        rm 2_illumina/{1}.{2}.fq.gz;
        touch 2_illumina/{1}.{2}.fq.gz;
    fi
    " ::: R1 R2  ::: uniq shuffle sample bbduk

# quorum
find 2_illumina -type f -name "quorum_mer_db.jf" | parallel --no-run-if-empty -j 1 rm
find 2_illumina -type f -name "k_u_hash_0"       | parallel --no-run-if-empty -j 1 rm
find 2_illumina -type f -name "*.tmp"            | parallel --no-run-if-empty -j 1 rm
find 2_illumina -type f -name "pe.renamed.fastq" | parallel --no-run-if-empty -j 1 rm
find 2_illumina -type f -name "se.renamed.fastq" | parallel --no-run-if-empty -j 1 rm
find 2_illumina -type f -name "pe.cor.sub.fa"    | parallel --no-run-if-empty -j 1 rm
find 2_illumina -type f -name "pe.cor.log"       | parallel --no-run-if-empty -j 1 rm

# down sampling
rm -fr 4_Q{15,20,25,30,35}*
find . -type f -path "*4_kunitigs_*" -name "k_unitigs_K*.fasta"  | parallel --no-run-if-empty -j 1 rm
find . -type f -path "*4_kunitigs_*/anchor*" -name "basecov.txt" | parallel --no-run-if-empty -j 1 rm
find . -type f -path "*4_kunitigs_*/anchor*" -name "*.sam"       | parallel --no-run-if-empty -j 1 rm
find . -type f -path "*4_tadpole_*" -name "k_unitigs_K*.fasta"   | parallel --no-run-if-empty -j 1 rm
find . -type f -path "*4_tadpole_*/anchor*" -name "basecov.txt"  | parallel --no-run-if-empty -j 1 rm
find . -type f -path "*4_tadpole_*/anchor*" -name "*.sam"        | parallel --no-run-if-empty -j 1 rm

rm -fr 6_MR*
find . -type f -path "*6_kunitigs_*" -name "k_unitigs_K*.fasta"  | parallel --no-run-if-empty -j 1 rm
find . -type f -path "*6_kunitigs_*/anchor*" -name "basecov.txt" | parallel --no-run-if-empty -j 1 rm
find . -type f -path "*6_kunitigs_*/anchor*" -name "*.sam"       | parallel --no-run-if-empty -j 1 rm
find . -type f -path "*6_tadpole_*" -name "k_unitigs_K*.fasta"   | parallel --no-run-if-empty -j 1 rm
find . -type f -path "*6_tadpole_*/anchor*" -name "basecov.txt"  | parallel --no-run-if-empty -j 1 rm
find . -type f -path "*6_tadpole_*/anchor*" -name "*.sam"        | parallel --no-run-if-empty -j 1 rm

# tempdir
find . -type d -name "\?" | xargs rm -fr

# canu
find . -type d -name "correction" -path "*5_canu_*" | parallel --no-run-if-empty -j 1 rm -fr
find . -type d -name "trimming"   -path "*5_canu_*" | parallel --no-run-if-empty -j 1 rm -fr
find . -type d -name "unitigging" -path "*5_canu_*" | parallel --no-run-if-empty -j 1 rm -fr

# anchorLong and anchorFill
find . -type d -name "group"         -path "*7_anchor*" | parallel --no-run-if-empty -j 1 rm -fr
find . -type f -name "long.fasta"    -path "*7_anchor*" | parallel --no-run-if-empty -j 1 rm
find . -type f -name ".anchorLong.*" -path "*7_anchor*" | parallel --no-run-if-empty -j 1 rm

# spades
find . -type d -path "*8_spades/*" -not -name "anchor" | parallel --no-run-if-empty -j 1 rm -fr

# platanus
find . -type f -path "*8_platanus/*" -name "[ps]e.fa" | parallel --no-run-if-empty -j 1 rm

# quast
find . -type d -name "nucmer_output" | parallel --no-run-if-empty -j 1 rm -fr
find . -type f -path "*contigs_reports/*" -name "*.stdout*" -or -name "*.stderr*" | parallel --no-run-if-empty -j 1 rm

# LSF outputs and dumps
find . -type f -name "output.*" | parallel --no-run-if-empty -j 1 rm
find . -type f -name "core.*"   | parallel --no-run-if-empty -j 1 rm

# cat all .md
if [ -e statInsertSize.md ]; then
    echo;
    cat statInsertSize.md;
    echo;
fi
if [ -e statReads.md ]; then
    echo;
    cat statReads.md;
    echo;
fi
if [ -e statMergeReads.md ]; then
    echo;
    cat statMergeReads.md;
    echo;
fi
if [ -e statQuorum.md ]; then
    echo;
    cat statQuorum.md;
    echo;
fi
if [ -e statAnchors.md ]; then
    echo;
    cat statAnchors.md;
    echo;
fi
if [ -e statKunitigsAnchors.md ]; then
    echo;
    cat statKunitigsAnchors.md;
    echo;
fi
if [ -e statTadpoleAnchors.md ]; then
    echo;
    cat statTadpoleAnchors.md;
    echo;
fi
if [ -e statMRKunitigsAnchors.md ]; then
    echo;
    cat statMRKunitigsAnchors.md;
    echo;
fi
if [ -e statMRTadpoleAnchors.md ]; then
    echo;
    cat statMRTadpoleAnchors.md;
    echo;
fi
if [ -e statCanu.md ]; then
    echo;
    cat statCanu.md;
    echo;
fi
if [ -e statFinal.md ]; then
    echo;
    cat statFinal.md;
    echo;
fi

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_realClean {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "0_realClean.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn 0_realClean.sh

cd [% args.0 %]

# illumina
rm -fr 2_illumina/Q*/

parallel --no-run-if-empty --linebuffer -k -j 1 "
    if [ -e 2_illumina/{1}.{2}.fq.gz ]; then
        rm 2_illumina/{1}.{2}.fq.gz;
    fi
    " ::: R1 R2  ::: uniq shuffle sample bbduk

rm -fr 2_illumina/mergereads/

# pacbio
rm -fr 3_pacbio/bam
rm -fr 3_pacbio/fasta
rm -fr 3_pacbio/untar

rm 3_pacbio/pacbio.X*.fasta

# down sampling
rm -fr 4_Q*
rm -fr 4_kunitigs*
rm -fr 4_tadpole*

# canu
rm -fr 5_canu*

# mergeAnchors, anchorLong and anchorFill
rm -fr 7_merge*
rm -fr 7_anchor*

# spades, platanus, and megahit
rm -fr 8_spades*
rm -fr 8_platanus*
rm -fr 8_megahit*

# quast
rm -fr 9_quast*

# tempdir
find . -type d -name "\?" | parallel --no-run-if-empty -j 1 rm -fr

# LSF outputs and dumps
find . -type f -name "output.*" | parallel --no-run-if-empty -j 1 rm
find . -type f -name "core.*"   | parallel --no-run-if-empty -j 1 rm

# .md
rm *.md

# bash
rm *.sh

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

sub gen_master {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "0_master.sh";
    print "Create $sh_name\n";

    $tt->process(
        '0_master.tt2',
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;
}

1;
