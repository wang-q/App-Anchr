package App::Anchr::Command::template;
use strict;
use warnings;
use autodie;

use App::Anchr -command;
use App::Anchr::Common;

use constant abstract => "create executing bash files";

sub opt_spec {
    return (
        [ "basename=i", "the basename of this genome, default is the working directory", ],
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

fastqc -t 16 \
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

}

1;
