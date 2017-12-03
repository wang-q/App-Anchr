package App::Anchr::Command::trim;
use strict;
use warnings;
use autodie;

use App::Anchr -command;
use App::Anchr::Common;

use constant abstract => "trim PE/SE Illumina fastq files";

sub opt_spec {
    return (
        [ "outfile|o=s",  "output filename, [stdout] for screen",      { default => "trim.sh" }, ],
        [ "basename|b=s", "prefix of fastq filenames",                 { default => "R" }, ],
        [ "len|l=i",      "filter reads less or equal to this length", { default => 60 }, ],
        [ "qual|q=i",     "quality threshold",                         { default => 25 }, ],
        [   "adapter|a=s", "adapter file",
            { default => File::ShareDir::dist_file( 'App-Anchr', 'illumina_adapters.fa' ) },
        ],
        [ "uniq",     "the uniq step", ],
        [ "shuffle",  "the shuffle step", ],
        [ "scythe",   "the scythe step", ],
        [ "nosickle", "skip the sickle step", ],
        [ "parallel|p=i", "number of threads", { default => 8 }, ],
        { show_defaults => 1, }
    );
}

sub usage_desc {
    return "anchr trim [options] <file1> [file2]";
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

    if ( $opt->{adapter} ) {
        if ( !Path::Tiny::path( $opt->{adapter} )->is_file ) {
            $self->usage_error("The adapter file [$opt->{adapter}] doesn't exist.");
        }
    }
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

    my $tt   = Template->new;
    my $text = <<'EOF';
#!/usr/bin/env bash

#----------------------------#
# Colors in term
#----------------------------#
# http://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
GREEN=
RED=
NC=
if tty -s < /dev/fd/1 2> /dev/null; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    NC='\033[0m' # No Color
fi

log_warn () {
    echo >&2 -e "${RED}==> $@ <==${NC}"
}

log_info () {
    echo >&2 -e "${GREEN}==> $@${NC}"
}

log_debug () {
    echo >&2 -e "==> $@"
}

#----------------------------#
# Run
#----------------------------#

[% IF opt.uniq -%]
[% current = 'uniq' -%]
#----------------------------#
# [% current %]
#----------------------------#
log_info "[% current %]"
if [ ! -e R1.[% current %].fq.gz ]; then
[% IF args.1 -%]
    tally \
        --pair-by-offset --with-quality --nozip --unsorted \
        -i [% args.0 %] \
        -j [% args.1 %] \
        -o R1.[% current %].fq \
        -p R2.[% current %].fq

    parallel --no-run-if-empty -j 1 "
        pigz -p [% opt.parallel %] {}.[% current %].fq
        " ::: R1 R2
[% ELSE -%]
    tally \
        --with-quality --nozip --unsorted \
        -i [% args.0 %] \
        -o R1.[% current %].fq

    pigz -p [% opt.parallel %] R1.[% current %].fq
[% END -%]
fi
[% prev = 'uniq' -%]
[% END -%]

[% IF opt.shuffle -%]
[% current = 'shuffle' -%]
#----------------------------#
# [% current %]
#----------------------------#
log_info "[% current %]"
if [ ! -e R1.[% current %].fq.gz ]; then
[% IF args.1 -%]
    shuffle.sh \
[% IF prev -%]
        in=R1.[% prev %].fq.gz \
        in2=R2.[% prev %].fq.gz \
[% ELSE -%]
        in=[% args.0 %] \
        in2=[% args.1 %] \
[% END -%]
        out=R1.[% current %].fq \
        out2=R2.[% current %].fq

    parallel --no-run-if-empty -j 1 "
        pigz -p [% opt.parallel %] {}.[% current %].fq
        " ::: R1 R2
[% ELSE -%]
    shuffle.sh \
[% IF prev -%]
        in=R1.[% prev %].fq.gz \
[% ELSE -%]
        in=[% args.0 %] \
[% END -%]
        out=R1.[% current %].fq

    pigz -p [% opt.parallel %] R1.[% current %].fq
[% END -%]
fi
[% prev = 'shuffle' -%]
[% END -%]

[% IF opt.scythe -%]
[% current = 'scythe' -%]
#----------------------------#
# [% current %]
#----------------------------#
log_info "[% current %]"
if [ ! -e R1.[% current %].fq.gz ]; then
    parallel --no-run-if-empty -j 2 "
        scythe \
[% IF prev -%]
            {}.[% prev %].fq.gz \
[% ELSE -%]
            [% args.0 %] \
[% END -%]
            -q sanger \
            -M [% opt.len %] \
            -a [% opt.adapter %] \
            --quiet \
            | pigz -p [% opt.parallel %] -c \
            > {}.[% current %].fq.gz
        " ::: R1 [% IF args.1 %]R2[% END %]
fi
[% prev = 'scythe' -%]
[% END -%]

[% IF not opt.nosickle -%]
[% current = 'sickle' -%]
#----------------------------#
# [% current %]
#----------------------------#
log_info "[% current %]"
if [ ! -e R1.[% current %].fq.gz ]; then
[% IF args.1 -%]
    sickle pe \
        -t sanger \
        -l [% opt.len %] \
        -q [% opt.qual %] \
[% IF prev -%]
        -f R1.[% prev %].fq.gz \
        -r R2.[% prev %].fq.gz \
[% ELSE -%]
        -f [% args.0 %] \
        -r [% args.1 %] \
[% END -%]
        -o R1.[% current %].fq \
        -p R2.[% current %].fq \
        -s Rs.[% current %].fq

    parallel --no-run-if-empty -j 1 "
        pigz -p [% opt.parallel %] {}.[% current %].fq
        " ::: R1 R2 Rs
[% ELSE -%]
    sickle se \
        -t sanger \
        -l [% opt.len %] \
        -q [% opt.qual %] \
[% IF prev -%]
        -f R1.[% prev %].fq.gz \
[% ELSE -%]
        -f [% args.0 %] \
[% END -%]
        -o R1.sickle.fq

    pigz -p [% opt.parallel %] R1.[% current %].fq
[% END -%]
fi
[% prev = 'sickle' -%]

#----------------------------#
# outputs
#----------------------------#
mv R1.sickle.fq.gz [% opt.basename %]1.sickle.fq.gz
[% IF args.1 -%]
mv R2.sickle.fq.gz [% opt.basename %]2.sickle.fq.gz
mv Rs.sickle.fq.gz [% opt.basename %]s.sickle.fq.gz
[% END -%]

[% END -%]

exit 0

EOF
    my $output;
    $tt->process(
        \$text,
        {   args => $args,
            opt  => $opt,
        },
        \$output
    );

    print {$out_fh} $output;
    close $out_fh;
}

1;
