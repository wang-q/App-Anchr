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
Grouping anthors by long reads

Usage: perl %c [options] <ovlp file> <dazz DB>
EOF

my @opt_spec = (
    [ 'help|h', 'display this message' ],
    [],
    [ 'range|r=s',    'ranges of reads',              { required => 1 }, ],
    [ 'coverage|c=i', 'minimal coverage',             { default  => 2 }, ],
    [ "len|l=i",      "minimal length of overlaps",   { default  => 500 }, ],
    [ "idt|i=f",      "minimal identity of overlaps", { default  => 0.7 }, ],
    [ "png",          "write a png file via graphviz", ],
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

if ( $opt->{range} ) {
    eval { AlignDB::IntSpan->new( $opt->{range} ); };
    if ($@) {
        $usage->die( { pre_text => "Invalid --range [$opt->{range}]\n" } );
    }
}

#----------------------------------------------------------#
# start
#----------------------------------------------------------#
my $anchor_range = AlignDB::IntSpan->new->add_runlist( $opt->{range} );
my $covered = {};    # Coverages of long reads in anchors

# long_id => { anchor_id => overlap_on_long }
my $links_of = {};

#----------------------------#
# load overlaps and build coverages
#----------------------------#
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
        next unless @fields == 13;

        my ( $f_id,     $g_id, $ovlp_len, $identity ) = @fields[ 0 .. 3 ];
        my ( $f_strand, $f_B,  $f_E,      $f_len )    = @fields[ 4 .. 7 ];
        my ( $g_strand, $g_B,  $g_E,      $g_len )    = @fields[ 8 .. 11 ];
        my $contained = $fields[12];

        # ignore self overlapping
        next if $f_id eq $g_id;

        # ignore poor overlaps
        next if $identity < $opt->{idt};

        # only want anchor-long overlaps
        if ( $anchor_range->contains($f_id) and $anchor_range->contains($g_id) ) {
            next;
        }
        if ( !$anchor_range->contains($f_id) and !$anchor_range->contains($g_id) ) {
            next;
        }

        # skip duplicated overlaps
        my $pair = join( "-", sort ( $f_id, $g_id ) );
        next if $seen_pair{$pair};
        $seen_pair{$pair}++;

        if ( $anchor_range->contains($f_id) and !$anchor_range->contains($g_id) ) {
            if ( !exists $covered->{$f_id} ) {
                $covered->{$f_id} = { all => AlignDB::IntSpan->new->add_pair( 1, $f_len ), };
                for my $i ( 1 .. $opt->{coverage} ) {
                    $covered->{$f_id}{$i} = AlignDB::IntSpan->new;
                }
            }
            bump_coverage( $covered->{$f_id}, $f_B, $f_E, );

            my ( $beg, $end ) = beg_end( $g_B, $g_E, );
            $links_of->{$g_id}{$f_id} = AlignDB::IntSpan->new->add_pair( $beg, $end );
        }
        elsif ( $anchor_range->contains($g_id) and !$anchor_range->contains($f_id) ) {
            if ( !exists $covered->{$g_id} ) {
                $covered->{$g_id} = { all => AlignDB::IntSpan->new->add_pair( 1, $g_len ), };
                for my $i ( 1 .. $opt->{coverage} ) {
                    $covered->{$g_id}{$i} = AlignDB::IntSpan->new;
                }
            }
            bump_coverage( $covered->{$g_id}, $g_B, $g_E, );

            my ( $beg, $end ) = beg_end( $f_B, $f_E, );
            $links_of->{$f_id}{$g_id} = AlignDB::IntSpan->new->add_pair( $beg, $end );
        }
    }
    close $in_fh;
}

my $trusted        = AlignDB::IntSpan->new;
my $non_overlapped = $anchor_range->copy;
for my $anchor_id ( sort { $a <=> $b } keys %{$covered} ) {
    $non_overlapped->remove($anchor_id);
    if ( $covered->{$anchor_id}{ $opt->{coverage} }->equals( $covered->{$anchor_id}{all} ) ) {
        $trusted->add($anchor_id);
    }
}

for my $anchor_id ( $anchor_range->diff($trusted)->diff($non_overlapped)->elements ) {
    printf "%s\t%s\t%s\n", $anchor_id, $covered->{$anchor_id}{all}->runlist,
        $covered->{$anchor_id}{ $opt->{coverage} }->runlist;
}

print $trusted, "\n";
print $trusted->size, "\n";
print $non_overlapped, "\n";

#----------------------------#
# grouping
#----------------------------#
my $graph = Graph->new( directed => 0 );

for my $long_id ( sort { $a <=> $b } keys %{$links_of} ) {
    my @anchors = sort { $a <=> $b }
        grep { $trusted->contains($_) }
        keys %{ $links_of->{$long_id} };

    my $count = scalar @anchors;
    next unless $count >= 2;

    for my $i ( 0 .. $count - 1 ) {
        for my $j ( $i + 1 .. $count - 1 ) {

            #@type AlignDB::IntSpan
            my $set_i    = $links_of->{$long_id}{ $anchors[$i] };
            my $set_j    = $links_of->{$long_id}{ $anchors[$j] };
            my $distance = $set_i->distance($set_j);

            next unless defined $distance;

            $graph->add_edge( $anchors[$i], $anchors[$j] );

            if ( $graph->has_edge_attribute( $anchors[$i], $anchors[$j], "long_ids" ) ) {
                my $long_ids_ref
                    = $graph->get_edge_attribute( $anchors[$i], $anchors[$j], "long_ids" );
                push @{$long_ids_ref}, $long_id;

            }
            else {
                $graph->set_edge_attribute( $anchors[$i], $anchors[$j], "long_ids", [$long_id], );
            }

            if ( $graph->has_edge_attribute( $anchors[$i], $anchors[$j], "distances" ) ) {
                my $distances_ref
                    = $graph->get_edge_attribute( $anchors[$i], $anchors[$j], "distances" );
                push @{$distances_ref}, $distance;
            }
            else {
                $graph->set_edge_attribute( $anchors[$i], $anchors[$j], "distances", [$distance], );
            }
        }
    }
}

for my $edge ( $graph->edges ) {
    my $long_ids_ref = $graph->get_edge_attribute( @{$edge}, "long_ids" );

    if ( scalar @{$long_ids_ref} < $opt->{coverage} ) {
        $graph->delete_edge( @{$edge} );
    }

    my $distances_ref = $graph->get_edge_attribute( @{$edge}, "distances" );

    if ( !judge_distance($distances_ref) ) {
        $graph->delete_edge( @{$edge} );
    }
}

#----------------------------#
# Outputs
#----------------------------#
my $non_grouped = $trusted->copy;

#@type Path::Tiny
my $output_path = Path::Tiny::path( $ARGV[0] )->parent->child('group');
$output_path->mkpath;

my @ccs = map { $_->[0] }
    sort { $b->[1] <=> $a->[1] }
    map { [ $_, scalar( @{$_} ) ] }
    grep { scalar @{$_} > 1 } $graph->connected_components();
my $cc_serial = 1;
for my $cc (@ccs) {
    my @members   = sort { $a <=> $b } @{$cc};
    my $count     = scalar @members;
    my $base_name = sprintf "%s_%s", $cc_serial, $count;

    my $tempdir = Path::Tiny->tempdir("group.XXXXXXXX");

    {    # anchors
        my $cmd;
        $cmd .= "DBshow -U $ARGV[1] ";
        $cmd .= join " ", @members;
        $cmd .= " > " . $output_path->child("$base_name.anchor.fasta")->stringify;

        system $cmd;
    }

    {    # long reads
        my $long_id_set = AlignDB::IntSpan->new;

        for my $i ( 0 .. $count - 1 ) {
            $non_grouped->remove( $members[$i] );
            for my $j ( $i + 1 .. $count - 1 ) {
                if ( $graph->has_edge( $members[$i], $members[$j], ) ) {
                    my $long_ids_ref
                        = $graph->get_edge_attribute( $members[$i], $members[$j], "long_ids" );
                    $long_id_set->add( @{$long_ids_ref} );
                }

            }
        }

        my $cmd;
        $cmd .= "DBshow -U $ARGV[1] ";
        $cmd .= join " ", $long_id_set->as_array;
        $cmd .= " > " . $output_path->child("$base_name.long.fasta")->stringify;

        system $cmd;
    }

    $cc_serial++;
}
printf "CC count %d\n",    scalar(@ccs);
printf "Non-grouped %s\n", $non_grouped;

if ( $opt->{png} ) {
    g2gv0( $graph, $ARGV[0] . ".png" );
}

#----------------------------------------------------------#
# Subroutines
#----------------------------------------------------------#
sub beg_end {
    my $beg = shift;
    my $end = shift;

    if ( $beg > $end ) {
        ( $beg, $end ) = ( $end, $beg );
    }

    if ( $beg == 0 ) {
        $beg = 1;
    }

    return ( $beg, $end );
}

sub bump_coverage {
    my $tier_of = shift;
    my $beg     = shift;
    my $end     = shift;

    return if $tier_of->{ $opt->{coverage} }->equals( $tier_of->{all} );

    ( $beg, $end ) = beg_end( $beg, $end );

    my $new_set = AlignDB::IntSpan->new->add_pair( $beg, $end );
    for my $i ( 1 .. $opt->{coverage} ) {
        my $i_set = $tier_of->{$i}->intersect($new_set);
        $tier_of->{$i}->add($new_set);

        my $j = $i + 1;
        last if $j > $opt->{coverage};
        $new_set = $i_set->copy;

       #        printf "%s\t%s\t%s\n", $tier_of->{all}->runlist, $i_set->runlist, $new_set->runlist;
    }
}

sub judge_distance {
    my $d_ref = shift;

    return 0 unless defined $d_ref;
    return 0 if ( scalar @{$d_ref} < $opt->{coverage} );

    my $sum = 0;
    my $min = $d_ref->[0];
    my $max = $min;
    for my $d ( @{$d_ref} ) {
        $sum += $d;
        if ( $d < $min ) { $min = $d; }
        if ( $d > $max ) { $max = $d; }
    }
    my $avg = $sum / scalar( @{$d_ref} );
    my $v   = $max - $min;
    if ( $v < 200 or abs( $v / $avg ) < 0.2 ) {
        return 1;
    }
    else {
        return 0;
    }
}

sub g2gv0 {

    #@type Graph
    my $g  = shift;
    my $fn = shift;

    my $gv = GraphViz->new( directed => 0 );

    for my $v ( $g->vertices ) {
        $gv->add_node($v);
    }

    for my $e ( $g->edges ) {
        $gv->add_edge( @{$e} );
    }

    Path::Tiny::path($fn)->spew_raw( $gv->as_png );
}
