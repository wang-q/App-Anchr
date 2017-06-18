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
    $desc .= "\tAll operations are running in a tempdir and no intermediate files are kept.\n";
    $desc
        .= "\tThe inaccuracy of overlap boundary identified by mininap may loose some parts of reads, ";
    $desc .= "\tbut also prevent adaptor or chimeric sequences joining with good parts of reads.\n";
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
    my $cwd     = Path::Tiny->cwd;
    my $tempdir = Path::Tiny->tempdir("anchr_trimlong_XXXXXXXX");
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

    {    # paf2ovlp
        my $cmd;
        $cmd .= "anchr paf2ovlp";
        $cmd .= " $basename.paf";
        $cmd .= " --parallel $opt->{parallel}";
        $cmd .= " -o $basename.ovlp.tsv";
        App::Anchr::Common::exec_cmd( $cmd, { verbose => $opt->{verbose}, } );

        if ( !$tempdir->child("$basename.ovlp.tsv")->is_file ) {
            Carp::croak "Failed: create $basename.ovlp.tsv\n";
        }
    }

    # seq_name => tier_of => { 1 => intspan, 2 => intspan}
    my $covered = {};

    {    # load overlaps and build coverages
        my %seen_pair;

        for my $line ( $tempdir->child("$basename.ovlp.tsv")->lines( { chomp => 1 } ) ) {
            my $info = App::Anchr::Common::parse_ovlp_line($line);

            # ignore self overlapping
            next if $info->{f_id} eq $info->{g_id};

            # ignore poor overlaps
            next if $info->{ovlp_len} < $opt->{len};

            # skip duplicated overlaps
            my $pair = join( "\t", sort ( $info->{f_id}, $info->{g_id} ) );
            next if $seen_pair{$pair};
            $seen_pair{$pair}++;

            {    # first seq
                if ( !exists $covered->{ $info->{f_id} } ) {
                    $covered->{ $info->{f_id} }
                        = { all => AlignDB::IntSpan->new->add_pair( 1, $info->{f_len} ), };
                    for my $i ( 1 .. $opt->{coverage} ) {
                        $covered->{ $info->{f_id} }{$i} = AlignDB::IntSpan->new;
                    }
                }

                my ( $beg, $end, ) = App::Anchr::Common::beg_end( $info->{f_B}, $info->{f_E}, );
                App::Anchr::Common::bump_coverage( $covered->{ $info->{f_id} },
                    $beg, $end, $opt->{coverage} );

            }

            {    # second seq
                if ( !exists $covered->{ $info->{g_id} } ) {
                    $covered->{ $info->{g_id} }
                        = { all => AlignDB::IntSpan->new->add_pair( 1, $info->{g_len} ), };
                    for my $i ( 1 .. $opt->{coverage} ) {
                        $covered->{ $info->{g_id} }{$i} = AlignDB::IntSpan->new;
                    }
                }

                my ( $beg, $end, ) = App::Anchr::Common::beg_end( $info->{g_B}, $info->{g_E}, );
                App::Anchr::Common::bump_coverage( $covered->{ $info->{g_id} },
                    $beg, $end, $opt->{coverage} );
            }
        }
    }

    {    # Create covered.fasta
        $tempdir->child("covered.txt")->remove;

        for my $key ( sort keys %{$covered} ) {
            my @subsets = $covered->{$key}{ $opt->{coverage} }->sets;
            my ($best_part) = map { $_->[0] }
                sort { $b->[1] <=> $a->[1] }
                map { [ $_, $_->count() ] } @subsets;

            $tempdir->child("covered.txt")
                ->append( sprintf( "%s:%s\n", $key, $best_part->runlist ) );
        }

        if ( !$tempdir->child("covered.txt")->is_file ) {
            Carp::croak "Failed: create covered.txt\n";
        }

    }

    {    # Outputs. stdout is handeld by faops
        my $cmd;
        $cmd .= "faops region -l 0 $infile covered.txt $opt->{outfile}";
        App::Anchr::Common::exec_cmd( $cmd, { verbose => $opt->{verbose}, } );
    }

    chdir $cwd;
}

1;
