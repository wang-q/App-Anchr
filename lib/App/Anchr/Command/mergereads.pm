package App::Anchr::Command::mergereads;
use strict;
use warnings;
use autodie;

use App::Anchr -command;
use App::Anchr::Common;

use constant abstract => "merge reads with bbtools";

sub opt_spec {
    return (
        [ "outfile|o=s", "output filename, [stdout] for screen", { default => "mergereads.sh" }, ],
        [ "prefilter=i", "prefilter=N (1 or 2) for tadpole and bbmerge", ],
        [ "qual|q=i",     "quality score for 3' end",                  { default => 15 }, ],
        [ "len|l=i",      "filter reads less or equal to this length", { default => 60 }, ],
        [ 'ecphase=s',    'Error-correct phases',                      { default => "1,2,3", }, ],
        [ "prefixm=s",    "prefix of merged reads",                    { default => "M" }, ],
        [ "prefixu=s",    "prefix of unmerged reads",                  { default => "U" }, ],
        [ "parallel|p=i", "number of threads",                         { default => 16 }, ],
        [ "xmx=s",        "set Java memory usage", ],
        { show_defaults => 1, }
    );
}

sub usage_desc {
    return "anchr mergereads [options] <R1> [R2] [Rs]";
}

sub description {
    my $desc;
    $desc .= ucfirst(abstract) . ".\n";
    $desc .= "\tFastq files can be gzipped\n";
    $desc .= "\tFile1 and file2 are paired; or file1 is interleaved\n";
    $desc .= "\tFile3 is single\n";
    return $desc;
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;

    if ( !( @{$args} == 1 or @{$args} == 2 or @{$args} == 3 ) ) {
        my $message = "This command need one, two or three input files.\n\tIt found";
        $message .= sprintf " [%s]", $_ for @{$args};
        $message .= ".\n";
        $self->usage_error($message);
    }
    for ( @{$args} ) {
        if ( !Path::Tiny::path($_)->is_file ) {
            $self->usage_error("The input file [$_] doesn't exist.");
        }
    }

    unless ( $opt->{ecphase} =~ /^[\d,]+$/ ) {
        $self->usage_error("Invalid ecphase [$opt->{ecphase}].");
    }
    $opt->{ecphase} = [ sort { $a <=> $b } grep {defined} split ",", $opt->{ecphase} ];

}

sub execute {
    my ( $self, $opt, $args ) = @_;

    # A stream to 'stdout' or a standard file.
    my $out_fh;
    if ( lc $opt->{outfile} eq "stdout" ) {
        $out_fh = *STDOUT{IO};
    }
    else {
        open $out_fh, ">", $opt->{outfile};
    }

    my $tt = Template->new( INCLUDE_PATH => [ File::ShareDir::dist_dir('App-Anchr') ], );
    my $output;
    $tt->process(
        'mergereads.tt2',
        {   args => $args,
            opt  => $opt,
        },
        \$output
    ) or die Template->error;

    print {$out_fh} $output;
    close $out_fh;
}

1;
