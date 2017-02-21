#!/usr/bin/env bash

USAGE="Usage: $0 ANCHOR_FILE LONG_FILE OUT_BASE"

if [ "$#" -lt 3 ]; then
    echo >&2 "$USAGE"
    exit 1
fi

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
# Parameters
#----------------------------#
ANCHOR_FILE=$1
LONG_FILE=$2
OUT_BASE=${3:-rename}

[ -e ${ANCHOR_FILE} ] || {
    log_warn "Can't find [${ANCHOR_FILE}].";
    exit 1;
}

[ -e ${LONG_FILE} ] || {
    log_warn "Can't find [${LONG_FILE}].";
    exit 1;
}

#----------------------------#
# Run
#----------------------------#
# create tmp dir
MY_TMP_DIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`

log_info "Temp dir: ${MY_TMP_DIR}"

log_info "Sort by lengths"
faops order ${ANCHOR_FILE} \
    <(faops size ${ANCHOR_FILE} | sort -n -r -k2,2 | cut -f 1) \
    ${MY_TMP_DIR}/anchor.fasta

faops order ${LONG_FILE} \
    <(faops size ${LONG_FILE} | sort -n -r -k2,2 | cut -f 1) \
    ${MY_TMP_DIR}/long.fasta

log_info "Preprocess reads to format them for dazzler"
pushd ${MY_TMP_DIR}

if [ -e stdout.* ]; then
    rm stdout.*
fi
cat anchor.fasta long.fasta \
    | anchr dazzname stdin -o stdout \
    | faops filter -l 0 stdin renamed.fasta

log_info "Make the dazzler DB"
DBrm myDB
fasta2DB myDB renamed.fasta
DBdust myDB

log_info "Run daligner for the first time"
if [ -e myDB.las ]; then
    rm myDB.las
fi
HPC.daligner myDB -v -M4 -e.80 -l1000 -s1000 -mdust > job.sh
bash job.sh

log_info "To positive strands"
COUNT_ANCHOR=$(faops n50 -N 0 -H -C anchor.fasta | xargs echo)
COUNT_ALL=$(faops n50 -N 0 -H -C renamed.fasta | xargs echo)

LAdump -o myDB.db myDB.las "1-${COUNT_ANCHOR}" \
    | grep "^P" \
    | COUNT_ALL=${COUNT_ALL} perl -nla -F"\s+" -MAlignDB::IntSpan -MGraph -e '
        BEGIN {
            our $copy = $ENV{COUNT_ALL};
            our $graph = Graph->new( directed => 0 );
        }

        $graph->set_edge_attribute( $F[1], $F[2], q{strand}, $F[3] );

        END {
            my $assigned = AlignDB::IntSpan->new(1);
            my $unhandled = AlignDB::IntSpan->new->add_pair( 2, $copy );

            $graph->set_vertex_attribute( 1, q{strand}, q{n} );

            my $prev_size = $assigned->size;
            my $cur_loop  = 0;                 # existing point
            while ( $assigned->size < $copy ) {
                if ( $prev_size == $assigned->size ) {
                    $cur_loop++;
                    last if $cur_loop > 10;
                }
                else {
                    $cur_loop = 0;
                }
                $prev_size = $assigned->size;

                for my $i ( $assigned->elements ) {
                    for my $j ( $unhandled->elements ) {
                        next if !$graph->has_edge( $i, $j );

                        # assign strands
                        my $i_strand = $graph->get_vertex_attribute( $i, q{strand} );
                        my $edge_strand = $graph->get_edge_attribute( $i, $j, q{strand} );
                        if ( $edge_strand eq q{n} ) {
                            $graph->set_vertex_attribute( $j, q{strand}, $i_strand );
                        }
                        else {
                            if ( $i_strand eq q{n} ) {
                                $graph->set_vertex_attribute( $j, q{strand}, q{c} );
                            }
                            else {
                                $graph->set_vertex_attribute( $j, q{strand}, q{n} );
                            }
                        }
                        $unhandled->remove($j);
                        $assigned->add($j);
                    }
                }
            }

            my @negs;
            for my $i ( sort { $a <=> $b } $graph->vertices ) {
                my $i_strand = $graph->get_vertex_attribute( $i, q{strand} );
                push @negs, $i if ( $i_strand eq q{c} );
            }

            system(qq{DBshow -n myDB @negs});
        }
    ' \
    | sed 's/^>//' \
    > rc.list

faops some -l 0 -i renamed.fasta rc.list stdout \
    > strand.fa
faops some renamed.fasta rc.list stdout \
    | faops rc -l 0 -n stdin stdout \
    >> strand.fa

faops order -l 0 strand.fa <(faops size renamed.fasta | cut -f 1) renamed.rc.fasta

log_info "Run daligner for the second/third time"
anchr overlap renamed.rc.fasta --len 1000 --idt .80 --serial -o renamed.rc.ovlp.tsv
anchr overlap renamed.rc.fasta --len 10   --idt .98 --serial -o 10.98.ovlp.tsv

log_info "Create outputs"
popd
mv ${MY_TMP_DIR}/renamed.rc.fasta    ${OUT_BASE}.renamed.fasta
mv ${MY_TMP_DIR}/renamed.rc.ovlp.tsv ${OUT_BASE}.ovlp.tsv
mv ${MY_TMP_DIR}/10.98.ovlp.tsv      ${OUT_BASE}.10.98.ovlp.tsv
mv ${MY_TMP_DIR}/stdout.replace.tsv  ${OUT_BASE}.replace.tsv

# clean tmp dir
rm -fr ${MY_TMP_DIR}
