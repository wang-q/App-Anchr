package App::Anchr::Command::quorum;
use strict;
use warnings;
use autodie;

use App::Anchr -command;
use App::Anchr::Common;

use constant abstract => "Run quorum to discard bad reads";

sub opt_spec {
    return (
        [ "outfile|o=s",  "output filename, [stdout] for screen", { default => "quorum.sh" }, ],
        [ 'jf=i',         'jellyfish hash size',                  { default => 500_000_000, }, ],
        [ 'estsize=s',    'estimated genome size',                { default => "auto", }, ],
        [ "filter=s",     "adapter, phix, artifact",              { default => "adapter" }, ],
        [ 'parallel|p=i', 'number of threads',                    { default => 8, }, ],
        { show_defaults => 1, }
    );
}

sub usage_desc {
    return "anchr quorum [options] <PE file1> <PE file2> [SE file]";
}

sub description {
    my $desc;
    $desc .= ucfirst(abstract) . ".\n";
    $desc .= "\tFastq files can be gzipped\n";
    return $desc;
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;

    if ( !( @{$args} == 1 or @{$args} == 2 or @{$args} == 3 ) ) {
        my $message = "This command need one, two or three input files.\n\tIt found";
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
        'quorum.tt2',
        {   args => $args,
            opt  => $opt,
        },
        \$output
    ) or die Template->error;

    print {$out_fh} $output;
    close $out_fh;
}

1;
