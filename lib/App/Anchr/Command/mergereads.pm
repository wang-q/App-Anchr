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
        [ "len|l=i",      "filter reads less or equal to this length", { default => 60 }, ],
        [ "tile",         "with normal Illumina names, do tile based filtering", ],
        [ "prefilter=i",  "prefilter=N (1 or 2) for tadpole and bbmerge", ],
        [ "filter=s",     "adapter, phix, artifact",                   { default => "adapter" }, ],
        [ "trimq=i",      "quality score for 3' end",                  { default => 15 }, ],
        [ "trimk=i",      "kmer for 5' adapter trimming",              { default => 23 }, ],
        [ "matchk=i",     "kmer for decontamination",                  { default => 27 }, ],
        [ 'ecphase=s',    'Error-correct phases',                      { default => "1,2,3", }, ],
        [ "parallel|p=i", "number of threads",                         { default => 8 }, ],
        { show_defaults => 1, }
    );
}

sub usage_desc {
    return "anchr mergereads [options] <file1> [file2]";
}

sub description {
    my $desc;
    $desc .= ucfirst(abstract) . ".\n";
    $desc .= "\tFastq files can be gzipped\n";
    return $desc;
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;

    if ( !( @{$args} == 1 or @{$args} == 2 ) ) {
        my $message = "This command need one or two input files.\n\tIt found";
        $message .= sprintf " [%s]", $_ for @{$args};
        $message .= ".\n";
        $self->usage_error($message);
    }
    for ( @{$args} ) {
        if ( !Path::Tiny::path($_)->is_file ) {
            $self->usage_error("The input file [$_] doesn't exist.");
        }
    }

    if ( $opt->{filter} ) {
        $opt->{filter} = [ grep {defined} split ",", $opt->{filter} ];
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
