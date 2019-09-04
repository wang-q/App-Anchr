package App::Anchr::Command::trim;
use strict;
use warnings;
use autodie;

use App::Anchr -command;
use App::Anchr::Common;

use constant abstract => "trim PE/SE Illumina fastq files";

sub opt_spec {
    return (
        [ "outfile|o=s", "output filename, [stdout] for screen",      { default => "trim.sh" }, ],
        [ "len|l=s",     "filter reads less or equal to this length", { default => "60" }, ],
        [ "qual|q=s",    "quality threshold",                         { default => "25" }, ],
        [ "filter=s",    "adapter, phix, artifact",                   { default => "adapter" }, ],
        [ "trimq=i",     "quality score for 3' end",                  { default => 15 }, ],
        [ "trimk=i",     "kmer for 5' adapter trimming",              { default => 23 }, ],
        [ "matchk=i",    "kmer for decontamination",                  { default => 27 }, ],
        [ "cutk=i",      "kmer for cutoff",                           { default => 31 }, ],
        [   "adapter=s", "adapter file",
            { default => File::ShareDir::dist_file( 'App-Anchr', 'illumina_adapters.fa' ) },
        ],
        [   "phix=s", "phix file",
            { default => File::ShareDir::dist_file( 'App-Anchr', 'phix174_ill.ref.fa' ) },
        ],
        [   "artifact=s",
            "artifact file",
            { default => File::ShareDir::dist_file( 'App-Anchr', 'sequencing_artifacts.fa' ) },
        ],
        [ "prefix=s", "prefix of trimmed reads", { default => "R" }, ],
        [ "dedupe",   "the uniq step", ],
        [ "tile",     "with normal Illumina names, do tile based filtering", ],
        [ "cutoff=i", "min kmer depth cutoff", ],
        [ "sample=i", "the sample step", ],
        [ "parallel|p=i", "number of threads", { default => 16 }, ],
        [ "xmx=s",        "set Java memory usage", ],
        { show_defaults => 1, }
    );
}

sub usage_desc {
    return "anchr trim [options] <file1> [file2]";
}

sub description {
    my $desc;
    $desc .= ucfirst(abstract) . ".\n";
    $desc .= "\tFastq files can be gzipped\n";
    return $desc;
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;

    if ( !( @{$args} == 1 or @{$args} == 2 ) ) {
        my $message = "This command need one or two input files.\n\tIt found";
        $message .= sprintf " [%s]", $_ for @{$args};
        $message .= ".\n";
        $self->usage_error($message);
    }
    for ( @{$args} ) {
        if ( !Path::Tiny::path($_)->is_file ) {
            $self->usage_error("The input file [$_] doesn't exist.");
        }
    }

    if ( $opt->{filter} ) {
        $opt->{filter} = [ grep {defined} split ",", $opt->{filter} ];
    }

    if ( $opt->{adapter} ) {
        if ( !Path::Tiny::path( $opt->{adapter} )->is_file ) {
            $self->usage_error("The adapter file [$opt->{adapter}] doesn't exist.");
        }
    }
}

sub execute {
    my ( $self, $opt, $args ) = @_;

    # A stream to 'stdout' or a standard file.
    my $out_fh;
    if ( lc $opt->{outfile} eq "stdout" ) {
        $out_fh = *STDOUT{IO};
    }
    else {
        open $out_fh, ">", $opt->{outfile};
    }

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $output;
    $tt->process(
        'trim.tt2',
        {   args => $args,
            opt  => $opt,
        },
        \$output
    ) or die Template->error;

    print {$out_fh} $output;
    close $out_fh;
}

1;
