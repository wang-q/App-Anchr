package App::Anchr::Command::anchors;
use strict;
use warnings;
use autodie;

use App::Anchr -command;
use App::Anchr::Common;

use constant abstract => "selete anchors from k-unitigs or superreads";

sub opt_spec {
    return (
        [ "outfile|o=s",  "output filename, [stdout] for screen", { default => "anchors.sh" }, ],
        [ 'min=i',        'minimal length of anchors',            { default => 1000, }, ],
        [ 'parallel|p=i', 'number of threads',                    { default => 8, }, ],
        { show_defaults => 1, }
    );
}

sub usage_desc {
    return "anchr anchors [options] <pe.cor.fa> <k_unitigs.fasta>";
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
    echo >&2 -e "  * $@"
}

#----------------------------#
# helper functions
#----------------------------#
set +e

signaled () {
    log_warn Interrupted
    exit 1
}
trap signaled TERM QUIT INT

#----------------------------#
# Prepare SR
#----------------------------#
log_info Symlink/copy input files
if [ ! -e pe.cor.fa ]; then
    ln -s [% args.0 %] pe.cor.fa
fi

if [ ! -e SR.fasta ]; then
    ln -s [% args.1 %] SR.fasta
fi

log_debug "SR sizes"
faops size SR.fasta > sr.chr.sizes

#----------------------------#
# unambiguous
#----------------------------#
log_info "Unambiguous regions"

# index
log_debug "bbmap index"
bbmap.sh ref=SR.fasta \
    1>bbmap.err 2>&1

log_debug "bbmap"
bbmap.sh \
    maxindel=0 strictmaxindel perfectmode \
    threads=[% opt.parallel %] \
    ambiguous=toss \
    ref=SR.fasta in=pe.cor.fa \
    outm=unambiguous.sam outu=unmapped.sam \
    1>>bbmap.err 2>&1

log_debug "sort bam"
picard SortSam \
    INPUT=unambiguous.sam \
    OUTPUT=unambiguous.sort.bam \
    SORT_ORDER=coordinate \
    VALIDATION_STRINGENCY=LENIENT \
    1>>picard.err 2>&1

log_debug "genomeCoverageBed"
# at least two unambiguous reads covered
genomeCoverageBed -bga -split -g sr.chr.sizes -ibam unambiguous.sort.bam \
    | perl -nlae '
        $F[3] == 0 and next;
        $F[3] == 1 and next;
        printf qq{%s:%s-%s\n}, $F[0], $F[1] + 1, $F[2];
    ' \
    > unambiguous.cover.txt

find . -type f -name "*.sam"   | parallel --no-run-if-empty -j 1 rm

#----------------------------#
# anchor
#----------------------------#
log_info "anchor - unambiguous"
jrunlist cover unambiguous.cover.txt -o unambiguous.cover.yml
jrunlist stat sr.chr.sizes unambiguous.cover.yml -o unambiguous.cover.csv

cat unambiguous.cover.csv \
    | perl -nla -F"," -e '
        $F[0] eq q{chr} and next;
        $F[0] eq q{all} and next;
        $F[2] < [% opt.min %] and next;
        $F[3] < 0.95 and next;
        print $F[0];
    ' \
    | sort -n \
    > anchor.txt

rm unambiguous.cover.txt

#----------------------------#
# anchor2
#----------------------------#
log_info "anchor2 - unambiguous2"

# contiguous unique region longer than [% opt.min %]
jrunlist span unambiguous.cover.yml --op excise -n [% opt.min %] -o unambiguous2.cover.yml
jrunlist stat sr.chr.sizes unambiguous2.cover.yml -o unambiguous2.cover.csv

cat unambiguous2.cover.csv \
    | perl -nla -F"," -e '
        $F[0] eq q{chr} and next;
        $F[0] eq q{all} and next;
        $F[2] < [% opt.min %] and next;
        print $F[0];
    ' \
    | sort -n \
    > unambiguous2.txt

cat unambiguous2.txt \
    | perl -nl -MPath::Tiny -e '
        BEGIN {
            %seen = ();
            @ls = grep {/\S/}
                  path(q{anchor.txt})->lines({ chomp => 1});
            $seen{$_}++ for @ls;
        }

        $seen{$_} and next;
        print;
    ' \
    > anchor2.txt

rm unambiguous2.*

#----------------------------#
# Split SR.fasta to anchor and others
#----------------------------#
log_info "pe.anchor.fa & pe.others.fa"
faops some -l 0 SR.fasta anchor.txt pe.anchor.fa

faops some -l 0 SR.fasta anchor2.txt stdout >> pe.anchor.fa

faops some -l 0 -i SR.fasta anchor.txt stdout \
    | faops some -l 0 -i stdin anchor2.txt pe.others.fa

#----------------------------#
# Done.
#----------------------------#
touch anchor.success
log_info "Done."

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
