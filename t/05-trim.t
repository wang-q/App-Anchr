#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use App::Cmd::Tester;

use App::Anchr;

# 1000 pair of reads
# seqtk sample -s1000 $HOME/data/anchr/e_coli/2_illumina/R1.fq.gz 1000 | pigz > t/R1.fq.gz
# seqtk sample -s1000 $HOME/data/anchr/e_coli/2_illumina/R2.fq.gz 1000 | pigz > t/R2.fq.gz

my $result = test_app( 'App::Anchr' => [qw(help trim)] );
like( $result->stdout, qr{trim}, 'descriptions' );

$result = test_app( 'App::Anchr' => [qw(trim)] );
like( $result->error, qr{need .+input file}, 'need infile' );

$result = test_app( 'App::Anchr' => [qw(trim t/not_exists t/not_exists)] );
like( $result->error, qr{doesn't exist}, 'infile not exists' );

$result = test_app( 'App::Anchr' => [qw(trim t/1_4.anchor.fasta --prefix B-A:D -o stdout)] );
like( $result->error, qr{Can't accept}, 'bad names' );

$result = test_app( 'App::Anchr' => [qw(trim t/1_4.anchor.fasta -o B-A:D)] );
like( $result->error, qr{Can't accept}, 'bad names' );

$result = test_app( 'App::Anchr' => [qw(trim t/1_4.anchor.fasta -o stdout)] );
is( ( scalar grep {/\S/} split( /\n/, $result->stdout ) ), 8, 'line count' );
like( $result->stdout, qr{anchr_read\/1}s, 'default prefix' );

done_testing();
