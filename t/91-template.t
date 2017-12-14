#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

#use App::Cmd::Tester;
use App::Cmd::Tester::CaptureExternal;

use App::Anchr;

my $result = test_app( 'App::Anchr' => [qw(help template)] );
like( $result->stdout, qr{template}, 'descriptions' );

$result = test_app( 'App::Anchr' => [qw(template)] );
like( $result->error, qr{need .+ directory}, 'need directory' );

$result = test_app( 'App::Anchr' => [qw(template t/not_exists)] );
like( $result->error, qr{doesn't exist}, 'not exists' );

{
    # real run
    my $tempdir = Path::Tiny->tempdir;
    test_app( 'App::Anchr' =>
            [ qw(template), $tempdir->stringify, ] );

    ok( $tempdir->child("2_fastqc.sh"), '2_fastqc.sh exists' );
}

done_testing();
