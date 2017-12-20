package App::Anchr::Command::kunitigs;
use strict;
use warnings;
use autodie;

use App::Anchr -command;
use App::Anchr::Common;

use constant abstract => "create k-unitigs from corrected reads";

sub opt_spec {
    return (
        [ "outfile|o=s",  "output filename, [stdout] for screen", { default => "kunitigs.sh" }, ],
        [ 'jf=s',         'jellyfish hash size',                  { default => "auto", }, ],
        [ 'estsize=s',    'estimated genome size',                { default => "auto", }, ],
        [ 'kmer=s',       'kmer size to be used',                 { default => "31", }, ],
        [ 'min=i',        'minimal length of k-unitigs',          { default => 1000, }, ],
        [ 'merge',        'merge k-unitigs from all kmers', ],
        [ 'parallel|p=i', 'number of threads',                    { default => 8, }, ],
        { show_defaults => 1, }
    );
}

sub usage_desc {
    return "anchr kunitigs [options] <pe.cor.fa> <environment.json>";
}

sub description {
    my $desc;
    $desc .= ucfirst(abstract) . ".\n";
    $desc .= "\tFasta files can be gzipped\n";
    return $desc;
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;

    if ( !( @{$args} == 2 ) ) {
        my $message = "This command need two input files.\n\tIt found";
        $message .= sprintf " [%s]", $_ for @{$args};
        $message .= ".\n";
        $self->usage_error($message);
    }
    for ( @{$args} ) {
        if ( !Path::Tiny::path($_)->is_file ) {
            $self->usage_error("The input file [$_] doesn't exist.");
        }
    }

    unless ( $opt->{kmer} =~ /^[\d,]+$/ ) {
        $self->usage_error("Invalid k-mer [$opt->{kmer}].");
    }
    $opt->{kmer} = [ sort { $a <=> $b } grep {defined} split ",", $opt->{kmer} ];
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
        'kunitigs.tt2',
        {   args => $args,
            opt  => $opt,
        },
        \$output
    ) or die Template->error;

    print {$out_fh} $output;
    close $out_fh;
}

1;
