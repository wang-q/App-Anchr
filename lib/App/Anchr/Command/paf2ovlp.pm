package App::Anchr::Command::paf2ovlp;
use strict;
use warnings;
use autodie;

use App::Anchr -command;
use App::Anchr::Common;

use constant abstract => 'minimap paf to ovelaps';

sub opt_spec {
    return ( [ "outfile|o=s", "output filename, [stdout] for screen" ], { show_defaults => 1, } );
}

sub usage_desc {
    return "anchr paf2ovlp [options] <minimap outputs>";
}

sub description {
    my $desc;
    $desc .= ucfirst(abstract) . ".\n";
    return $desc;
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;

    if ( @{$args} != 1 ) {
        my $message = "This command need one input file.\n\tIt found";
        $message .= sprintf " [%s]", $_ for @{$args};
        $message .= ".\n";
        $self->usage_error($message);
    }
    for ( @{$args} ) {
        next if lc $_ eq "stdin";
        if ( !Path::Tiny::path($_)->is_file ) {
            $self->usage_error("The input file [$_] doesn't exist.");
        }
    }

    if ( !exists $opt->{outfile} ) {
        $opt->{outfile} = Path::Tiny::path( $args->[0] )->absolute . ".ovlp.tsv";
    }
}

sub execute {
    my ( $self, $opt, $args ) = @_;

    # A stream from 'stdin' or a standard file.
    my $in_fh;
    if ( lc $args->[0] eq 'stdin' ) {
        $in_fh = *STDIN{IO};
    }
    else {
        open $in_fh, "<", $args->[0];
    }

    # A stream to 'stdout' or a standard file.
    my $out_fh;
    if ( lc $opt->{outfile} eq "stdout" ) {
        $out_fh = *STDOUT{IO};
    }
    else {
        open $out_fh, ">", $opt->{outfile};
    }

    while ( my $line = <$in_fh> ) {
        my $info = App::Anchr::Common::parse_paf_line($line);

        printf $out_fh "%s\n", App::Anchr::Common::create_ovlp_line($info);
    }

    close $in_fh;
    close $out_fh;
}

1;
