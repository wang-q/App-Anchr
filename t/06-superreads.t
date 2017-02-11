#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use App::Cmd::Tester;

use App::Anchr;

my $result = test_app( 'App::Anchr' => [qw(help superreads)] );
like( $result->stdout, qr{superreads}, 'descriptions' );

$result = test_app( 'App::Anchr' => [qw(superreads)] );
like( $result->error, qr{need .+input file}, 'need infile' );

$result = test_app( 'App::Anchr' => [qw(superreads t/not_exists t/not_exists)] );
like( $result->error, qr{doesn't exist}, 'infile not exists' );

$result = test_app( 'App::Anchr' => [qw(superreads t/R1.fq.gz t/R2.fq.gz -a t/not_exists)] );
like( $result->error, qr{doesn't exist}, 'adapter file not exists' );

$result = test_app( 'App::Anchr' => [qw(superreads t/R1.fq.gz t/R2.fq.gz -o stdout)] );
is( ( scalar grep {/\S/} split( /\n/, $result->stdout ) ), 70, 'line count' );
like( $result->stdout, qr{scythe.+sickle.+outputs}s, 'bash contents' );

#{    # real run
#    my $tempdir = Path::Tiny->tempdir;
#    $result = test_app(
#        'App::Anchr' => [
#            qw(superreads t/R1.fq.gz t/R2.fq.gz), "-b",
#            $tempdir->stringify . "/R",     "-o",
#            $tempdir->child("superreads.sh")->stringify,
#        ]
#    );
#
#    ok( $tempdir->child("superreads.sh")->is_file, 'bash file exists' );
#    system( sprintf "bash %s", $tempdir->child("superreads.sh")->stringify );
#    ok( $tempdir->child("R1.fq.gz")->is_file, 'output files exist' );
#    ok( $tempdir->child("Rs.fq.gz")->is_file, 'output files exist' );
#
#    #    chdir $tempdir;    # keep tempdir
#}

done_testing();
