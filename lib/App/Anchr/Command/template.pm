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
        [ "se",         "single end mode for Illumina", ],
        [ "separate",   "separate each Qual-Len/Cov-Qual groups", ],
        [ "trim2=s",    "steps for trimming Illumina reads",         { default => "--uniq" }, ],
        [ "sample2=i",  "total sampling coverage of Illumina reads", ],
        [ "cov2=s",     "down sampling coverage of Illumina reads",  { default => "40 80" }, ],
        [ "qual2=s",    "quality threshold",                         { default => "25 30" }, ],
        [ "len2=s",     "filter reads less or equal to this length", { default => "60" }, ],
        [ "reads=i",    "how many reads to estimate insert size",    { default => 2000000 }, ],
        [ "filter=s",   "adapter, phix, artifact",                   { default => "adapter" }, ],
        [ 'tadpole',    'also use tadpole to create k-unitigs', ],
        [ "cov3=s",     "down sampling coverage of PacBio reads", ],
        [ "qual3=s",    "raw and/or trim",                           { default => "trim" } ],
        [ 'mergereads', 'also run the mergereads approach', ],
        [ "tile",        "with normal Illumina names, do tile based filtering", ],
        [ "prefilter=i", "prefilter=N (1 or 2) for tadpole and bbmerge", ],
        [ 'ecphase=s',    'Error-correct phases', { default => "1,2,3", }, ],
        [ "parallel|p=i", "number of threads",    { default => 16 }, ],
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

    # kmergenie
    $self->gen_mergereads( $opt, $args );

    # trim2
    $self->gen_trim( $opt, $args );

    # trimlong
    $self->gen_trimlong( $opt, $args );

    # statReads
    $self->gen_statReads( $opt, $args );

    # insertSize
    $self->gen_insertSize( $opt, $args );

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

    $sh_name = "2_insertSize.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn 2_insertSize.sh

cd [% args.0 %]

parallel --no-run-if-empty --linebuffer -k -j 1 "
    cd 2_illumina/Q{1}L{2}
    echo >&2 '==> Qual-Len: Q{1}L{2} <=='

    if [ ! -e R1.sickle.fq.gz ]; then
        echo >&2 '    R1.sickle.fq.gz not exists'
        exit;
    fi

    if [ -e ihist.txt ]; then
        echo >&2 '    ihist.txt presents'
        exit;
    fi

    tadpole.sh \
        in=R1.sickle.fq.gz \
        in2=R2.sickle.fq.gz \
        out=tadpole.contig.fasta \
        threads=[% opt.parallel %] \
        overwrite

    bbmap.sh \
        in=R1.sickle.fq.gz \
        in2=R2.sickle.fq.gz \
        out=pe.sam.gz \
        ref=tadpole.contig.fasta \
        threads=[% opt.parallel %] \
        maxindel=0 strictmaxindel perfectmode \
        reads=[% opt.reads %] \
        nodisk overwrite

    reformat.sh \
        in=pe.sam.gz \
        ihist=ihist.txt \
        overwrite

    find . -type f -name "pe.sam.gz" | parallel --no-run-if-empty -j 1 rm

    echo >&2
    " ::: [% opt.qual2 %] ::: [% opt.len2 %]

    printf "| %s | %s | %s | %s | %s |\n" \
        "Group" "Mean" "Median" "STDev" "PercentOfPairs" \
        > statInsertSize.md
    printf "|:--|--:|--:|--:|--:|\n" >> statInsertSize.md

#Mean	339.868
#Median	312
#Mode	251
#STDev	134.676
#PercentOfPairs	36.247

for Q in [% opt.qual2 %]; do
    for L in [% opt.len2 %]; do
        printf "| %s " "Q${Q}L${L}" >> statInsertSize.md
        cat 2_illumina/Q${Q}L${L}/ihist.txt \
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
done

cat statInsertSize.md

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

    if [ -e pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa exists'
        exit;
    fi

    anchr quorum \
        R1.sickle.fq.gz [% IF not opt.se %]R2.sickle.fq.gz[% END %] \
        \$(
            if [[ {1} -ge '30' ]]; then
                if [ -e Rs.sickle.fq.gz ]; then
                    echo Rs.sickle.fq.gz;
                fi
            fi
        ) \
[% IF opt.filter -%]
        --filter [% opt.filter %] \
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

if [ -e pe.cor.fa ]; then
    echo >&2 '    pe.cor.fa exists'
    exit;
fi

anchr quorum \
    R1.sickle.fq.gz [% IF not opt.se %]R2.sickle.fq.gz[% END %] \
    \$(
        if [[ [% qual %] -ge '30' ]]; then
            if [ -e Rs.sickle.fq.gz ]; then
                echo Rs.sickle.fq.gz;
            fi
        fi
    ) \
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

sub gen_kunitigs {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "4_kunitigs.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn 4_kunitigs.sh

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
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

    if ( $opt->{tadpole} ) {
        $sh_name = "4_tadpole.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
[% INCLUDE header.tt2 %]
log_warn 4_tadpole.sh

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

sub gen_mergeAnchors {
    my ( $self, $opt, $args ) = @_;

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    $sh_name = "6_mergeAnchors.sh";
    print "Create $sh_name\n";

    $tt->process(
        '6_mergeAnchors.tt2',
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

    $sh_name = "6_anchorLong.sh";
    print "Create $sh_name\n";

    $tt->process(
        '6_anchorLong.tt2',
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

    $sh_name = "6_anchorFill.sh";
    print "Create $sh_name\n";

    $tt->process(
        '6_anchorFill.tt2',
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
    " ::: R1 R2  ::: uniq shuffle sample scythe

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

# tempdir
find . -type d -name "\?" | xargs rm -fr

# canu
find . -type d -name "correction" -path "*5_canu_*" | parallel --no-run-if-empty -j 1 rm -fr
find . -type d -name "trimming"   -path "*5_canu_*" | parallel --no-run-if-empty -j 1 rm -fr
find . -type d -name "unitigging" -path "*5_canu_*" | parallel --no-run-if-empty -j 1 rm -fr

# anchorLong and anchorFill
find . -type d -name "group"         -path "*6_anchor*" | parallel --no-run-if-empty -j 1 rm -fr
find . -type f -name "long.fasta"    -path "*6_anchor*" | parallel --no-run-if-empty -j 1 rm
find . -type f -name ".anchorLong.*" -path "*6_anchor*" | parallel --no-run-if-empty -j 1 rm

# spades
find . -type d -path "*8_spades/*" | parallel --no-run-if-empty -j 1 rm -fr

# platanus
find . -type f -path "*8_platanus/*" -name "[ps]e.fa" | parallel --no-run-if-empty -j 1 rm

# quast
find . -type d -name "nucmer_output" | parallel --no-run-if-empty -j 1 rm -fr
find . -type f -path "*contigs_reports/*" -name "*.stdout*" -or -name "*.stderr*" | parallel --no-run-if-empty -j 1 rm

# LSF outputs and dumps
find . -type f -name "output.*" | parallel --no-run-if-empty -j 1 rm
find . -type f -name "core.*"   | parallel --no-run-if-empty -j 1 rm

# cat all .md
if [ -e statReads.md ]; then
    cat statReads.md;
    echo;
fi
if [ -e 2_illumina/mergereads/statMergeReads.md ]; then
    cat 2_illumina/mergereads/statMergeReads.md;
    echo;
fi
if [ -e statInsertSize.md ]; then
    cat statInsertSize.md;
    echo;
fi
if [ -e statQuorum.md ]; then
    cat statQuorum.md;
    echo;
fi
if [ -e statAnchors.md ]; then
    cat statAnchors.md;
    echo;
fi
if [ -e statKunitigsAnchors.md ]; then
    cat statKunitigsAnchors.md;
    echo;
fi
if [ -e statTadpoleAnchors.md ]; then
    cat statTadpoleAnchors.md;
    echo;
fi
if [ -e statCanu.md ]; then
    cat statCanu.md;
    echo;
fi
if [ -e statFinal.md ]; then
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
    " ::: R1 R2  ::: uniq shuffle sample scythe

# pacbio
rm -fr 3_pacbio/bam
rm -fr 3_pacbio/fasta
rm -fr 3_pacbio/untar

rm 3_pacbio/pacbio.X*.fasta

# down sampling
rm -fr 4_Q*
rm -fr 4_kunitigs*

# canu
rm -fr 5_canu*

# mergeAnchors, anchorLong and anchorFill
rm -fr 6_merge*
rm -fr 6_anchor*

# spades
rm -fr 8_spades*

# platanus
rm -fr 8_platanus*

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
