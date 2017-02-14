package App::Anchr::Command::superreads;
use strict;
use warnings;
use autodie;

use App::Anchr -command;
use App::Anchr::Common;

use constant abstract => "Run MaSuRCA to create super-reads";

sub opt_spec {
    return (
        [ "outfile|o=s", "output filename, [stdout] for screen", { default => "superreads.sh" }, ],
        [ 'size|s=i',    'fragment size',                        { default => 300, }, ],
        [ 'std|d=i',     'fragment size standard deviation',     { default => 30, }, ],
        [ 'jf=i',        'jellyfish hash size',                  { default => 500_000_000, }, ],
        [ 'kmer=s',      'kmer size to be used for super reads', { default => 'auto', }, ],
        [ 'prefix|r=s',  'prefix for paired-reads',              { default => 'pe', }, ],
        [ 'strict', 'discard any reads altered by error correction', ],
        [   "adapter|a=s", "adapter file",
            { default => File::ShareDir::dist_file( 'App-Anchr', 'adapter.jf' ) },
        ],
        [ 'parallel|p=i', 'number of threads', { default => 8, }, ],
        { show_defaults => 1, }
    );
}

sub usage_desc {
    return "anchr superreads [options] <PE file1> <PE file2>";
}

sub description {
    my $desc;
    $desc .= ucfirst(abstract) . ".\n";
    $desc .= "\tFastq files can be gzipped\n";
    $desc
        .= "\tSource code download from ftp://ftp.genome.umd.edu/pub/MaSuRCA/beta/SuperReads_RNA-1.0.1.tar.gz\n";
    return $desc;
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;

    if ( @{$args} != 2 ) {
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
# masurca
#----------------------------#
set +e
# Set some paths and prime system to save environment variables
save () {
    (echo -n "$1=\""; eval "echo -n \"\$$1\""; echo '"') >> environment.sh
}

signaled () {
    log_warn Interrupted
    exit 1
}
trap signaled TERM QUIT INT

rm -f environment.sh; touch environment.sh
NUM_THREADS=[% opt.parallel %]
save NUM_THREADS

#----------------------------#
# Renaming reads
#----------------------------#
log_info 'Processing pe library reads'
rm -rf meanAndStdevByPrefix.pe.txt
echo '[% opt.prefix %] [% opt.size %] [% opt.std %]' >> meanAndStdevByPrefix.pe.txt

rename_filter_fastq \
    '[% opt.prefix %]' \
    <(exec expand_fastq '[% args.0 %]' | awk '{if(length($0>200)) print substr($0,1,200); else print $0;}') \
    <(exec expand_fastq '[% args.1 %]' | awk '{if(length($0>200)) print substr($0,1,200); else print $0;}') \
    > '[% opt.prefix %].renamed.fastq'

#----------------------------#
# Stats of PE and counting kmer
#----------------------------#
head -q -n 40000 [% opt.prefix %].renamed.fastq | grep --text -v '^+' | grep --text -v '^@' > pe_data.tmp
export PE_AVG_READ_LENGTH=`awk '{if(length($1)>31){n+=length($1);m++;}}END{print int(n/m)}' pe_data.tmp`
save PE_AVG_READ_LENGTH
echo "Average PE read length $PE_AVG_READ_LENGTH"

[% IF opt.kmer == 'auto' -%]
KMER=$( head -n 80000 [% opt.prefix %].renamed.fastq \
    | tail -n 40000 \
    | perl -e '
        my @lines;
        while ( my $line = <STDIN> ) {
            $line = <STDIN>;
            chomp($line);
            push( @lines, $line );
            $line = <STDIN>;
            $line = <STDIN>;
        }
        my @legnths;
        my $min_len    = 100000;
        my $base_count = 0;
        for my $l (@lines) {
            $base_count += length($l);
            push( @lengths, length($l) );
            for $base ( split( "", $l ) ) {
                if ( uc($base) eq "G" or uc($base) eq "C" ) { $gc_count++; }
            }
        }
        @lengths  = sort { $b <=> $a } @lengths;
        $min_len  = $lengths[ int( $#lengths * .75 ) ];
        $gc_ratio = $gc_count / $base_count;
        $kmer     = 0;
        if ( $gc_ratio < 0.5 ) {
            $kmer = int( $min_len * .7 );
        }
        elsif ( $gc_ratio >= 0.5 && $gc_ratio < 0.6 ) {
            $kmer = int( $min_len * .5 );
        }
        else {
            $kmer = int( $min_len * .33 );
        }
        $kmer++ if ( $kmer % 2 == 0 );
        $kmer = 31  if ( $kmer < 31 );
        $kmer = 127 if ( $kmer > 127 );
        print $kmer;
    ' )
save KMER
echo "Choosing kmer size of $KMER for the graph"
[% ELSE -%]
KMER=[% opt.kmer %]
save KMER
echo "You set kmer size of $KMER for the graph"
[% END -%]

#----------------------------#
# Jellyfish
#----------------------------#
MIN_Q_CHAR=$( cat [% opt.prefix %].renamed.fastq \
    | head -n 40000 \
    | awk 'BEGIN{flag=0}{if($0 ~ /^\+/){flag=1}else if(flag==1){print $0;flag=0}}' \
    | perl -ne '
        BEGIN { $q0_char = "@"; }

        chomp;
        for $v ( split "" ) {
            if ( ord($v) < ord($q0_char) ) { $q0_char = $v; }
        }

        END {
            $ans = ord($q0_char);
            if   ( $ans < 64 ) { print "33\n" }
            else               { print "64\n" }
        }
    ')
save MIN_Q_CHAR
echo MIN_Q_CHAR: $MIN_Q_CHAR

JF_SIZE=$( ls -l *.fastq \
    | awk '{n+=$5} END{s=int(n/50); if(s>[% opt.jf %])print s;else print "[% opt.jf %]";}' )
save JF_SIZE
perl -e '
    if(int('$JF_SIZE') > [% opt.jf %]) {
        print "WARNING: JF_SIZE set too low, increasing JF_SIZE to at least '$JF_SIZE', this automatic increase may be not enough!\n";
    }
    '

if [ ! -e quorum_mer_db.jf ]; then
    log_info Creating mer database for Quorum.

    quorum_create_database \
        -t [% opt.parallel %] \
        -s $JF_SIZE -b 7 -m 24 -q $((MIN_Q_CHAR + 5)) \
        -o quorum_mer_db.jf.tmp \
        [% opt.prefix %].renamed.fastq \
        && mv quorum_mer_db.jf.tmp quorum_mer_db.jf
    if [ $? -ne 0 ]; then
        log_warn Increase JF_SIZE by --jf, the recommendation value is genome_size*coverage/2
        exit 1
    fi
fi

#----------------------------#
# Error correct PE
#----------------------------#
# -m Minimum count for a k-mer to be considered "good" (1)
# -g Number of good k-mer in a row for anchor (2)
# -w Size of window (10)
# -e Maximum number of error in a window (3)
# As we have trimmed reads with sickle, we lower `-e` to 1 from original value of 3,
# remove `--no-discard`.
# And we only want most reliable parts of the genome other than the whole genome, so dropping rare
# k-mers is totally OK for us. Raise `-m` from 1 to 2, `-g` from 1 to 2, and `-a` from 1 to 3.
if [ ! -e pe.cor.fa ]; then
    log_info Error correct PE.
    quorum_error_correct_reads \
        -q $((MIN_Q_CHAR + 40)) \
        --contaminant=[% opt.adapter %] \
        -m 2 -s 1 -g 2 -a 3 -t [% opt.parallel %] -w 10 -e 1 \
        quorum_mer_db.jf \
        [% opt.prefix %].renamed.fastq \
        -o pe.cor --verbose 1>quorum.err 2>&1 \
    || {
        mv pe.cor.fa pe.cor.fa.failed;
        log_warn Error correction of PE reads failed. Check pe.cor.log.;
        exit 1;
    }
fi

#----------------------------#
# Estimating genome size.
#----------------------------#
log_info Estimating genome size.

if [ ! -e k_u_hash_0 ]; then
    jellyfish count -m 31 -t [% opt.parallel %] -C -s $JF_SIZE -o k_u_hash_0 pe.cor.fa
fi
export ESTIMATED_GENOME_SIZE=$(jellyfish histo -t [% opt.parallel %] -h 1 k_u_hash_0 | tail -n 1 |awk '{print $2}')
save ESTIMATED_GENOME_SIZE
echo "Estimated genome size: $ESTIMATED_GENOME_SIZE"

#----------------------------#
# Build k-unitigs
#----------------------------#
if [ ! -e guillaumeKUnitigsAtLeast32bases_all.fasta ]; then
    log_info Creating k-unitigs with k=$KMER
    create_k_unitigs_large_k -c $(($KMER-1)) -t [% opt.parallel %] \
        -m $KMER -n $ESTIMATED_GENOME_SIZE -l $KMER -f 0.000001 pe.cor.fa \
        | grep --text -v '^>' \
        | perl -an -e '
            $seq = $F[0];
            $F[0] =~ tr/ACTGactg/TGACtgac/;
            $revseq = reverse( $F[0] );
            $h{ ( $seq ge $revseq ) ? $seq : $revseq } = 1;

            END {
                $n = 0;
                foreach $k ( keys %h ) { print ">", $n++, " length:", length($k), "\n$k\n" }
            }
        ' \
        > guillaumeKUnitigsAtLeast32bases_all.fasta
fi

#----------------------------#
# super-reads
#----------------------------#
log_info Creating super-reads
createSuperReadsForDirectory.perl \
    -l $KMER \
    -mean-and-stdev-by-prefix-file meanAndStdevByPrefix.pe.txt \
    -kunitigsfile guillaumeKUnitigsAtLeast32bases_all.fasta \
    -t [% opt.parallel %] -mikedebug work1 pe.cor.fa 1> super1.err 2>&1
if [[ ! -e work1/superReads.success ]]; then
    log_warn Super reads failed, check super1.err and files in ./work1/
    exit 1
fi

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
