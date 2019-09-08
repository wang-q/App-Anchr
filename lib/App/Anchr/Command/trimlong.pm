package App::Anchr::Command::trimlong;
use strict;
use warnings;
use autodie;

use App::Anchr - command;
use App::Anchr::Common;

use constant abstract => "trim long reads with minimap";

sub opt_spec {
    return (
        [ "outfile|o=s", "output filename, [stdout] for screen", ],
        [ "coverage|c=i", "minimal coverage",           { default => 3 }, ],
        [ "len|l=i",      "minimal length of overlaps", { default => 1000 }, ],
        [ "tmp=s",        "user defined tempdir", ],
        [ "parallel|p=i", "number of threads",          { default => 8 }, ],
        [ "verbose|v",    "verbose mode", ],
        { show_defaults => 1, }
    );
}

sub usage_desc {
    return "anchr trimlong [options] <infile>";
}

sub description {
    my $desc;
    $desc .= ucfirst(abstract) . ".\n";
    $desc .= <<'MARKDOWN';

All operations are running in a tempdir and no intermediate files are kept.

The inaccuracy of overlap boundary identified by mininap may loose some parts of reads,
but also prevent adaptor or chimeric sequences joining with good parts of reads.

MARKDOWN
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
        if ( !Path::Tiny::path($_)->is_file ) {
            $self->usage_error("The input file [$_] doesn't exist.");
        }
    }

    if ( !exists $opt->{outfile} ) {
        $opt->{outfile} = Path::Tiny::path( $args->[0] )->absolute . ".cover.fasta";
    }
}

sub execute {
    my ( $self, $opt, $args ) = @_;

    # make paths absolute before we chdir
    my $infile = Path::Tiny::path( $args->[0] )->absolute->stringify;

    if ( lc $opt->{outfile} ne "stdout" ) {
        $opt->{outfile} = Path::Tiny::path( $opt->{outfile} )->absolute->stringify;
    }

    # record cwd, we'll return there
    my $cwd = Path::Tiny->cwd;
    my $tempdir;
    if ( $opt->{tmp} ) {
        $tempdir = Path::Tiny->tempdir(
            TEMPLATE => "anchr_trimlong_XXXXXXXX",
            DIR      => $opt->{tmp},
        );
    }
    else {
        $tempdir = Path::Tiny->tempdir("anchr_trimlong_XXXXXXXX");
    }
    chdir $tempdir;

    my $basename = $tempdir->basename();
    $basename =~ s/\W+/_/g;

    {    # Call minimap
        my $cmd;
        $cmd .= "minimap";
        $cmd .= " -Sw5 -L100 -m0 -t$opt->{parallel}";
        $cmd .= " $infile $infile";
        $cmd .= " > $basename.paf";
        App::Anchr::Common::exec_cmd( $cmd, { verbose => $opt->{verbose}, } );

        if ( !$tempdir->child("$basename.paf")->is_file ) {
            Carp::croak "Failed: create $basename.paf\n";
        }
    }

    {    # paf to covered
        my $cmd;
        $cmd .= "ovlpr covered $basename.paf";
        $cmd .= " --coverage $opt->{coverage} --len $opt->{len} --longest --paf";
        $cmd .= " -o $basename.covered.txt";
        App::Anchr::Common::exec_cmd( $cmd, { verbose => $opt->{verbose}, } );

        if ( !$tempdir->child("$basename.covered.txt")->is_file ) {
            Carp::croak "Failed: create $basename.covered.txt\n";
        }
    }

    {    # Outputs. stdout is handled by faops
        my $cmd;
        $cmd .= "faops region -l 0 $infile $basename.covered.txt $opt->{outfile}";
        App::Anchr::Common::exec_cmd( $cmd, { verbose => $opt->{verbose}, } );
    }

    chdir $cwd;
}

1;
