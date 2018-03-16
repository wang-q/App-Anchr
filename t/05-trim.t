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

$result = test_app( 'App::Anchr' => [qw(trim t/R1.fq.gz t/R2.fq.gz --adapter t/not_exists)] );
like( $result->error, qr{doesn't exist}, 'adapter file not exists' );

$result = test_app( 'App::Anchr' => [qw(trim t/R1.fq.gz t/R2.fq.gz -o stdout)] );
ok( scalar( grep {/\S/} split( /\n/, $result->stdout ) ) > 40, 'line count' );
like( $result->stdout, qr{Pipeline.+Sickle}s, 'bash contents' );

$result = test_app( 'App::Anchr' => [qw(trim t/R1.fq.gz -o stdout )] );
like( $result->stdout, qr{\sse\s}s, 'se mode' );
unlike( $result->stdout, qr{\spe\s}s, 'se mode without pe' );

{    # real run
    my $t_path = Path::Tiny::path("t/")->absolute->stringify;
    my $cwd    = Path::Tiny->cwd;

    my $tempdir = Path::Tiny->tempdir;
    chdir $tempdir;

    $result = test_app(
        'App::Anchr' => [
            "trim",             "$t_path/R1.fq.gz",
            "$t_path/R2.fq.gz", qw(-q 25 -l 60),
            "-o",               $tempdir->child("trim.sh")->stringify,
        ]
    );

    ok( $tempdir->child("trim.sh")->is_file, 'bash file exists' );
    system( sprintf "bash %s", $tempdir->child("trim.sh")->stringify );
    ok( $tempdir->child("Q25L60/R1.fq.gz")->is_file, 'R1 exist' );
    ok( $tempdir->child("Q25L60/Rs.fq.gz")->is_file, 'Rs exist' );

    chdir $cwd;    # Won't keep tempdir
}

done_testing();
