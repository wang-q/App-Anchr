package App::Anchr::Command::anchors;
use strict;
use warnings;
use autodie;

use App::Anchr -command;
use App::Anchr::Common;

use constant abstract => "selete anchors from k-unitigs or superreads";

sub opt_spec {
    return (
        [ "outfile|o=s",  "output filename, [stdout] for screen", { default => "anchors.sh" }, ],
        [ 'min=i',        'minimal length of anchors',            { default => 1000, }, ],
        [ 'reads=i',      'minimal coverage of reads',            { default => 2, }, ],
        [ 'scale=i',      'the scale factor',                     { default => 3, }, ],
        [ 'parallel|p=i', 'number of threads',                    { default => 8, }, ],
        { show_defaults => 1, }
    );
}

sub usage_desc {
    return "anchr anchors [options] <k_unitigs.fasta> <pe.cor.fa>";
}

sub description {
    my $desc;
    $desc .= ucfirst(abstract) . ".\n";
    $desc .= "\tFasta files can be gzipped\n";
    return $desc;
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;

    if ( !( @{$args} == 2 ) ) {
        my $message = "This command need two input files.\n\tIt found";
        $message .= sprintf " [%s]", $_ for @{$args};
        $message .= ".\n";
        $self->usage_error($message);
    }
    for ( @{$args} ) {
        if ( !Path::Tiny::path($_)->is_file ) {
            $self->usage_error("The input file [$_] doesn't exist.");
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
