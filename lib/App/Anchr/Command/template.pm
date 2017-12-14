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
        [ "trim2=s",      "steps for trimming illumina reads",         { default => "--uniq" }, ],
        [ "sample2=i",    "total sampling coverage of illumina reads", ],
        [ "coverage2=s",  "down sampling coverage of illumina reads",  { default => "40 80" }, ],
        [ "qual2=s",      "quality threshold",                         { default => "25 30" }, ],
        [ "len2=s",       "filter reads less or equal to this length", { default => "60" }, ],
        [ "coverage3=s",  "down sampling coverage of pacbio reads",    { default => "40 80" }, ],
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
    ../R1.fq.gz ../R2.fq.gz \
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
    " ::: R1 R2

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
[% END-%]
[% END-%]
    $(
        if [ -e illumina_adapters.fa ]; then
            echo "-a illumina_adapters.fa";
        fi
    ) \
    --nosickle \
    --parallel [% opt.parallel %] \
    R1.fq.gz R2.fq.gz \
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
                echo '../R1.scythe.fq.gz ../R2.scythe.fq.gz'
            elif [ -e ../R1.sample.fq.gz ]; then
                echo '../R1.sample.fq.gz ../R2.sample.fq.gz'
            elif [ -e ../R1.shuffle.fq.gz ]; then
                echo '../R1.shuffle.fq.gz ../R2.shuffle.fq.gz'
            elif [ -e ../R1.uniq.fq.gz ]; then
                echo '../R1.uniq.fq.gz ../R2.uniq.fq.gz'
            else
                echo '../R1.fq.gz ../R2.fq.gz'
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

}

1;
