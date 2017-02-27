#!/usr/bin/env perl
use strict;
use warnings;
use autodie;

use Getopt::Long::Descriptive;
use FindBin;
use YAML::Syck qw();

use AlignDB::IntSpan;
use Graph;
use GraphViz;
use Path::Tiny qw();

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
    next if lc $_ eq "stdin";
    if ( !Path::Tiny::path($_)->is_file ) {
        $usage->die( { pre_text => "The input file [$_] doesn't exist.\n" } );
    }
}

#----------------------------------------------------------#
# start
#----------------------------------------------------------#
my %is_anchor;

#----------------------------#
# load overlaps and build graph
#----------------------------#
my $graph = Graph->new( directed => 1 );

{
    my $in_fh;
    if ( lc $ARGV[0] eq 'stdin' ) {
        $in_fh = *STDIN{IO};
    }
    else {
        open $in_fh, "<", $ARGV[0];
    }

    my %seen_pair;

    while ( my $line = <$in_fh> ) {
        chomp $line;
        my @fields = split "\t", $line;
        my ( $f_id,     $g_id, $ovlp_len, $ovlp_idt ) = @fields[ 0 .. 3 ];
        my ( $f_strand, $f_B,  $f_E,      $f_len )    = @fields[ 4 .. 7 ];
        my ( $g_strand, $g_B,  $g_E,      $g_len )    = @fields[ 8 .. 11 ];
        my $contained = $fields[12];

        # ignore self overlapping
        next if $f_id eq $g_id;

        # we've orient all sequences to the same strand
        next if $g_strand == 1;

        # skip duplicated overlaps
        my $pair = join( "-", sort ( $f_id, $g_id ) );
        next if $seen_pair{$pair};
        $seen_pair{$pair}++;

        $is_anchor{$f_id}++ if ( index( $f_id, $opt->{prefix} . "/" ) == 0 );
        $is_anchor{$g_id}++ if ( index( $g_id, $opt->{prefix} . "/" ) == 0 );

        if ( $f_B > 0 ) {

            if ( $f_E == $f_len ) {

                #          f.B        f.E
                # f ========+---------->
                # g         -----------+=======>
                #          g.B        g.E
                $graph->add_weighted_edge( $f_id, $g_id, $g_len - $g_E );
            }
            else {
                #          f.B        f.E
                # f ========+----------+=======>
                # g         ----------->
                #          g.B        g.E
                $graph->add_weighted_edge( $g_id, $f_id, $f_len - $f_E );
            }
        }
        else {
            if ( $g_E == $g_len ) {

                #          f.B        f.E
                # f         -----------+=======>
                # g ========+---------->
                #          g.B        g.E
                $graph->add_weighted_edge( $g_id, $f_id, $f_len - $f_E );
            }
            else {
                #          f.B        f.E
                # f         ----------->
                # g ========+----------+=======>
                #          g.B        g.E
                $graph->add_weighted_edge( $f_id, $g_id, $g_len - $g_E );
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
    g2gv( $anchor_graph, $ARGV[0] . ".png" );
    transitive_reduction($anchor_graph);
    g2gv( $anchor_graph, $ARGV[0] . ".reduced.png" );
}

if ( $anchor_graph->is_dag ) {
    if ( scalar $anchor_graph->exterior_vertices() == 2 ) {
        my @ts = $anchor_graph->topological_sort;

        print "    @ts\n";
    }
    else {
        print "    Branched\n";
    }
}
else {
    print "    Cyclic\n";
}

sub transitive_reduction {

    #@type Graph
    my $g = shift;

    my $count = 0;
    my $prev_count;
    while (1) {
        last if defined $prev_count and $prev_count == $count;
        $prev_count = $count;

        for my $v ( $g->vertices ) {
            next if $g->out_degree($v) < 2;

            my @s = sort { $a cmp $b } $g->successors($v);
            for my $i ( 0 .. $#s ) {
                for my $j ( 0 .. $#s ) {
                    next if $i == $j;
                    if ( $g->is_reachable( $s[$i], $s[$j] ) ) {
                        $g->delete_edge( $v, $s[$j] );

                        $count++;
                    }
                }
            }
        }
    }

    return $count;
}

sub g2gv {

    #@type Graph
    my $g  = shift;
    my $fn = shift;

    my $gv = GraphViz->new( directed => 1 );

    for my $v ( $g->vertices ) {
        $gv->add_node($v);
    }

    for my $e ( $g->edges ) {
        $gv->add_edge( @{$e} );
    }

    Path::Tiny::path($fn)->spew_raw( $gv->as_png );
}
