#!/usr/bin/env perl
use strict;
use warnings;
use autodie;

use Getopt::Long::Descriptive;

use App::Anchr::Common;

#----------------------------------------------------------#
# GetOpt section
#----------------------------------------------------------#
my $usage_desc = <<EOF;
Layout anchors

Usage: perl %c [options] <.ovlp.tsv> <.relation.tsv>
EOF

my @opt_spec = (
    [ 'help|h', 'display this message' ],
    [],
    [ 'prefix|p=s', 'prefix of anchors', { default => "anchor" }, ],
    [ 'ao=s',       'overlaps between anchors', ],
    [ "png",        "write a png file via graphviz", ],
    { show_defaults => 1, },
);

( my Getopt::Long::Descriptive::Opts $opt, my Getopt::Long::Descriptive::Usage $usage, )
    = Getopt::Long::Descriptive::describe_options( $usage_desc, @opt_spec, );

$usage->die if $opt->{help};

if ( @ARGV != 2 ) {
    my $message = "This script need two input files.\n\tIt found";
    $message .= sprintf " [%s]", $_ for @ARGV;
    $message .= ".\n";
    $usage->die( { pre_text => $message } );
}
for (@ARGV) {
    if ( !Path::Tiny::path($_)->is_file ) {
        $usage->die( { pre_text => "The input file [$_] doesn't exist.\n" } );
    }
}
if ( $opt->{ao} ) {
    if ( !Path::Tiny::path( $opt->{ao} )->is_file ) {
        $usage->die( { pre_text => "The overlap file [$opt->{ao}] doesn't exist.\n" } );
    }
}

#----------------------------------------------------------#
# start
#----------------------------------------------------------#

#----------------------------#
# load overlaps and build graph
#----------------------------#
my $graph = Graph->new( directed => 1 );
my %is_anchor;
{
    open my $in_fh, "<", $ARGV[0];

    my %seen_pair;
    while ( my $line = <$in_fh> ) {
        my $info = App::Anchr::Common::parse_ovlp_line($line);

        # ignore self overlapping
        next if $info->{f_id} eq $info->{g_id};

        # we've orient all sequences to the same strand
        next if $info->{g_strand} == 1;

        # skip duplicated overlaps
        my $pair = join( "-", sort ( $info->{f_id}, $info->{g_id} ) );
        next if $seen_pair{$pair};
        $seen_pair{$pair}++;

        $is_anchor{ $info->{f_id} }++ if ( index( $info->{f_id}, $opt->{prefix} . "/" ) == 0 );
        $is_anchor{ $info->{g_id} }++ if ( index( $info->{g_id}, $opt->{prefix} . "/" ) == 0 );

        if ( $info->{f_B} > 0 ) {

            if ( $info->{f_E} == $info->{f_len} ) {

                #          f.B        f.E
                # f ========+---------->
                # g         -----------+=======>
                #          g.B        g.E
                $graph->add_weighted_edge( $info->{f_id}, $info->{g_id},
                    $info->{g_len} - $info->{g_E} );
            }
            else {
                #          f.B        f.E
                # f ========+----------+=======>
                # g         ----------->
                #          g.B        g.E
                $graph->add_weighted_edge( $info->{g_id}, $info->{f_id},
                    $info->{f_len} - $info->{f_E} );
            }
        }
        else {
            if ( $info->{g_E} == $info->{g_len} ) {

                #          f.B        f.E
                # f         -----------+=======>
                # g ========+---------->
                #          g.B        g.E
                $graph->add_weighted_edge( $info->{g_id}, $info->{f_id},
                    $info->{f_len} - $info->{f_E} );
            }
            else {
                #          f.B        f.E
                # f         ----------->
                # g ========+----------+=======>
                #          g.B        g.E
                $graph->add_weighted_edge( $info->{f_id}, $info->{g_id},
                    $info->{g_len} - $info->{g_E} );
            }
        }
    }
    close $in_fh;
}

#----------------------------#
# Graph of anchors
#----------------------------#
my $anchor_graph = Graph->new( directed => 1 );
{

    my @nodes = $graph->vertices;

    my @linkers = grep { !$is_anchor{$_} } @nodes;

    for my $l (@linkers) {
        my @p = grep { $is_anchor{$_} } $graph->predecessors($l);
        my @s = grep { $is_anchor{$_} } $graph->successors($l);

        for my $p (@p) {
            for my $s (@s) {
                $anchor_graph->add_edge( $p, $s );
            }
        }

        if ( @p > 1 ) {
            @p = map { $_->[0] }
                sort { $b->[1] <=> $a->[1] }
                map { [ $_, $graph->get_edge_weight( $_, $l ) ] } @p;
            for my $i ( 0 .. $#p - 1 ) {
                $anchor_graph->add_edge( $p[$i], $p[ $i + 1 ] );
            }
        }

        if ( @s > 1 ) {
            printf STDERR "* There should be only one successor, as anchors arn't overlapped\n";
            @s = map { $_->[0] }
                sort { $a->[1] <=> $b->[1] }
                map { [ $_, $graph->get_edge_weight( $l, $_, ) ] } @s;
            for my $i ( 0 .. $#s - 1 ) {
                $anchor_graph->add_edge( $s[$i], $s[ $i + 1 ] );
            }
        }

    }
    if ( $opt->{png} ) {
        App::Anchr::Common::g2gv( $anchor_graph, $ARGV[0] . ".png" );
    }
    App::Anchr::Common::transitive_reduction($anchor_graph);
    if ( $opt->{png} ) {
        App::Anchr::Common::g2gv( $anchor_graph, $ARGV[0] . ".reduced.png" );
    }
}

#----------------------------#
# existing overlaps
#----------------------------#
my $existing_ovlp_of = {};
if ( $opt->{ao} ) {
    open my $in_fh, "<", $opt->{ao};

    while ( my $line = <$in_fh> ) {
        my $info = App::Anchr::Common::parse_ovlp_line($line);

        # ignore self overlapping
        next if $info->{f_id} eq $info->{g_id};

        # we've orient all sequences to the same strand
        next if $info->{g_strand} == 1;

        my $pair = join( "-", sort ( $info->{f_id}, $info->{g_id} ) );

        $existing_ovlp_of->{$pair} = $info;
    }
    close $in_fh;
}

my @paths;
if ( $anchor_graph->is_dag ) {
    if ( scalar $anchor_graph->exterior_vertices == 2 ) {
        print "    Linear\n";

        my @ts = $anchor_graph->topological_sort;
        push @paths, \@ts;
    }
    else {
        print "    Branched\n";
    }
}
else {
    print "    Cyclic\n";
}

for my $path (@paths) {
    my @nodes = @{$path};

    for my $i ( 0 .. $#nodes ) {

    }
}
