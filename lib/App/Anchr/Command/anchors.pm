package App::Anchr::Command::anchors;
use strict;
use warnings;
use autodie;

use App::Anchr -command;
use App::Anchr::Common;

use constant abstract => "select anchors (proper covered regions) from contigs";

sub opt_spec {
    return (
        [ "outfile|o=s",  "output filename, [stdout] for screen",   { default => "anchors.sh" }, ],
        [ 'min=i',        'minimal length of anchors',              { default => 1000, }, ],
        [ 'reads=i',      'minimal coverage of reads',              { default => 2, }, ],
        [ 'scale=i',      'the scale factor k for MAD',             { default => 3, }, ],
        [ 'ratio=f',      'consider as anchor',                     { default => 0.95, }, ],
        [ 'fill=i',       'fill holes short than or equal to this', { default => 30, }, ],
        [ 'longest',      'only keep the longest proper region', ],
        [ 'parallel|p=i', 'number of threads',                      { default => 8, }, ],
        { show_defaults => 1, }
    );
}

sub usage_desc {
    return "anchr anchors [options] <contig.fasta> <pe.cor.fa> [more reads]";
}

sub description {
    my $desc;
    $desc .= ucfirst(abstract) . ".\n";
    $desc .= "\tFasta files can be gzipped\n";
    return $desc;
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;

    if ( @{$args} < 2 ) {
        my $message = "This command need two or more input files.\n\tIt found";
        $message .= sprintf " [%s]", $_ for @{$args};
        $message .= ".\n";
        $self->usage_error($message);
    }
    for ( @{$args} ) {
        if ( !Path::Tiny::path($_)->is_file ) {
            $self->usage_error("The input file [$_] doesn't exist.");
        }
    }

    for my $infile ( @{$args} ) {
        $infile = Path::Tiny::path($infile)->absolute->stringify;
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
        'anchors.tt2',
        {   args => $args,
            opt  => $opt,
        },
        \$output
    ) or die Template->error;

    print {$out_fh} $output;
    close $out_fh;
}

1;
