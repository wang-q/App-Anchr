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
        [ "trim2=s",      "steps for trimming Illumina reads",         { default => "--uniq" }, ],
        [ "sample2=i",    "total sampling coverage of Illumina reads", ],
        [ "coverage2=s",  "down sampling coverage of Illumina reads",  { default => "40 80" }, ],
        [ "qual2=s",      "quality threshold",                         { default => "25 30" }, ],
        [ "len2=s",       "filter reads less or equal to this length", { default => "60" }, ],
        [ "coverage3=s",  "down sampling coverage of PacBio reads", ],
        [ "parallel|p=i", "number of threads",                         { default => 16 }, ],
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

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $template;
    my $sh_name;

    # fastqc
    $sh_name = "2_fastqc.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
cd [% args.0 %]

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

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

    # kmergenie
    $sh_name = "2_kmergenie.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
cd [% args.0 %]

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

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

    # trim2
    $sh_name = "2_trim.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
cd [% args.0 %]

cd 2_illumina

anchr trim \
    [% opt.trim2 %] \
[% IF opt.sample2 -%]
[% IF opt.genome -%]
    --sample $(( [% opt.genome %] * [% opt.sample2 %] )) \
[% END -%]
[% END -%]
    $(
        if [ -e illumina_adapters.fa ]; then
            echo "-a illumina_adapters.fa";
        fi
    ) \
    --nosickle \
    --parallel [% opt.parallel %] \
    R1.fq.gz [% IF not opt.se %]R2.fq.gz[% END %] \
    -o trim.sh
bash trim.sh

parallel --no-run-if-empty --linebuffer -k -j 2 "
    mkdir -p Q{1}L{2}
    cd Q{1}L{2}

    printf '==> Qual-Len: %s\n'  Q{1}L{2}
    if [ -e R1.sickle.fq.gz ]; then
        echo '    R1.sickle.fq.gz already presents'
        exit;
    fi

    anchr trim \
        -q {1} -l {2} \
        \$(
            if [ -e ../R1.scythe.fq.gz ]; then
                echo '../R1.scythe.fq.gz [% IF not opt.se %]../R2.scythe.fq.gz[% END %]'
            elif [ -e ../R1.sample.fq.gz ]; then
                echo '../R1.sample.fq.gz [% IF not opt.se %]../R2.sample.fq.gz[% END %]'
            elif [ -e ../R1.shuffle.fq.gz ]; then
                echo '../R1.shuffle.fq.gz [% IF not opt.se %]../R2.shuffle.fq.gz[% END %]'
            elif [ -e ../R1.uniq.fq.gz ]; then
                echo '../R1.uniq.fq.gz [% IF not opt.se %]../R2.uniq.fq.gz[% END %]'
            else
                echo '../R1.fq.gz [% IF not opt.se %]../R2.fq.gz[% END %]'
            fi
        ) \
        --parallel [% opt.parallel %] \
        -o stdout \
        | bash
    " ::: [% opt.qual2 %] ::: [% opt.len2 %]

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

    # trimlong
    if ( $opt->{coverage3} ) {
        $sh_name = "3_trimlong.sh";
        print "Create $sh_name\n";
        $template = <<'EOF';
cd [% args.0 %]

for X in [% opt.coverage3 %]; do
    printf "==> Coverage: %s\n" ${X}

    faops split-about -m 1 -l 0 \
        3_pacbio/pacbio.fasta \
        $(( [% opt.genome %] * ${X} )) \
        3_pacbio

    mv 3_pacbio/000.fa "3_pacbio/pacbio.X${X}.raw.fasta"
done

for X in  [% opt.coverage3 %]; do
    printf "==> Coverage: %s\n" ${X}

    anchr trimlong --parallel 16 -v \
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

    # statReads
    $sh_name = "23_statReads.sh";
    print "Create $sh_name\n";
    $template = <<'EOF';
cd [% args.0 %]

stat_format () {
    echo $(faops n50 -H -N 50 -S -C $@) \
        | perl -nla -MNumber::Format -e '
            printf qq{%d\t%s\t%d\n}, $F[0], Number::Format::format_bytes($F[1], base => 1000,), $F[2];
        '
}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > statReads.md
printf "|:--|--:|--:|--:|\n" >> statReads.md

if [ -e 1_genome/genome.fa ]; then
    printf "| %s | %s | %s | %s |\n" \
        $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> statReads.md
fi
if [ -e 1_genome/paralogs.fas ]; then
    printf "| %s | %s | %s | %s |\n" \
        $(echo "Paralogs"; faops n50 -H -S -C 1_genome/paralogs.fas;) >> statReads.md
fi

if [ -e 2_illumina/R1.fq.gz ]; then
    printf "| %s | %s | %s | %s |\n" \
        $(echo "Illumina"; stat_format 2_illumina/R1.fq.gz [% IF not opt.se %]2_illumina/R2.fq.gz[% END %];) >> statReads.md
fi
if [ -e 2_illumina/R1.uniq.fq.gz ]; then
    printf "| %s | %s | %s | %s |\n" \
        $(echo "uniq";    stat_format 2_illumina/R1.uniq.fq.gz [% IF not opt.se %]2_illumina/R2.uniq.fq.gz[% END %];) >> statReads.md
fi
if [ -e 2_illumina/R1.shuffle.fq.gz ]; then
    printf "| %s | %s | %s | %s |\n" \
        $(echo "shuffle"; stat_format 2_illumina/R1.shuffle.fq.gz [% IF not opt.se %]2_illumina/R2.shuffle.fq.gz[% END %];) >> statReads.md
fi
if [ -e 2_illumina/R1.sample.fq.gz ]; then
    printf "| %s | %s | %s | %s |\n" \
        $(echo "sample";  stat_format 2_illumina/R1.sample.fq.gz [% IF not opt.se %]2_illumina/R2.sample.fq.gz[% END %];) >> statReads.md
fi
if [ -e 2_illumina/R1.scythe.fq.gz ]; then
    printf "| %s | %s | %s | %s |\n" \
        $(echo "scythe";  stat_format 2_illumina/R1.scythe.fq.gz [% IF not opt.se %]2_illumina/R2.scythe.fq.gz[% END %];) >> statReads.md
fi

parallel --no-run-if-empty -k -j 2 "
    stat_format () {
        echo \$(faops n50 -H -N 50 -S -C \$@) \
            | perl -nla -MNumber::Format -e '
                printf qq{%d\t%s\t%d\n}, \$F[0], Number::Format::format_bytes(\$F[1], base => 1000,), \$F[2];
            '
    }

    if [ ! -e 2_illumina/Q{1}L{2}/R1.sickle.fq.gz ]; then
        exit;
    fi

    printf \"| %s | %s | %s | %s |\n\" \
        \$(
            echo Q{1}L{2};
[% IF not opt.se %]
            if [[ {1} -ge '30' ]]; then
                stat_format \
                    2_illumina/Q{1}L{2}/R1.sickle.fq.gz \
                    2_illumina/Q{1}L{2}/R2.sickle.fq.gz \
                    2_illumina/Q{1}L{2}/Rs.sickle.fq.gz;
            else
                stat_format \
                    2_illumina/Q{1}L{2}/R1.sickle.fq.gz \
                    2_illumina/Q{1}L{2}/R2.sickle.fq.gz;
            fi
[% ELSE %]
            faops n50 -H -S -C \
                2_illumina/Q{1}L{2}/R1.sickle.fq.gz;
[% END %]
        )
    " ::: [% opt.qual2 %] ::: [% opt.len2 %] \
    >> statReads.md

if [ -e 3_pacbio/pacbio.fasta ]; then
    printf "| %s | %s | %s | %s |\n" \
        $(echo "PacBio"; stat_format 3_pacbio/pacbio.fasta;) >> statReads.md
fi

parallel --no-run-if-empty -k -j 2 "
    stat_format () {
        echo \$(faops n50 -H -N 50 -S -C \$@) \
            | perl -nla -MNumber::Format -e '
                printf qq{%d\t%s\t%d\n}, \$F[0], Number::Format::format_bytes(\$F[1], base => 1000,), \$F[2];
            '
    }

    if [ ! -e 3_pacbio/pacbio.X{1}.{2}.fasta ]; then
        exit;
    fi

    printf \"| %s | %s | %s | %s |\n\" \
        \$(
            echo X{1}.{2};
            stat_format \
                3_pacbio/pacbio.X{1}.{2}.fasta;
        )
    " ::: [% opt.coverage3 %] ::: raw trim \
    >> statReads.md

cat statReads.md

EOF
    $tt->process(
        \$template,
        {   args => $args,
            opt  => $opt,
        },
        Path::Tiny::path( $args->[0], $sh_name )->stringify
    ) or die Template->error;

}

1;
