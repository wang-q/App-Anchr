#!/usr/bin/env bash

USAGE="Usage: $0 RESULT_DIR N_THREADS USE_SR"

if [ "$#" -lt 1 ]; then
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
    echo >&2 -e "  * $@"
}

#----------------------------#
# Parameters
#----------------------------#
RESULT_DIR=$1
N_THREADS=${2:-8}
USE_SR=${3:-true}

log_info "Parameters"
log_debug "    RESULT_DIR=${RESULT_DIR}"
log_debug "    N_THREADS=${N_THREADS}"
log_debug "    USE_SR=${USE_SR}"

[ -e ${RESULT_DIR}/pe.cor.fa ] || {
    log_warn "Can't find pe.cor.fa in [${RESULT_DIR}].";
    exit 1;
}

#----------------------------#
# Prepare SR
#----------------------------#
log_info "Prepare SR"
mkdir -p ${RESULT_DIR}/anchor
cd ${RESULT_DIR}/anchor

ln -s ../pe.cor.fa .

if [ "${USE_SR}" = true ] ; then
    ln -s ../work1/superReadSequences.fasta SR.fasta
else
    ln -s ../k_unitigs.fasta SR.fasta
fi

faops size SR.fasta > sr.chr.sizes

#----------------------------#
# unambiguous
#----------------------------#
log_info "unambiguous regions"

# index
log_debug "bbmap index"
bbmap.sh ref=SR.fasta \
    1>bbmap.err 2>&1

log_debug "bbmap"
bbmap.sh \
    maxindel=0 strictmaxindel perfectmode \
    threads=${N_THREADS} \
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
        $F[2] < 1000 and next;
        $F[3] < 0.95 and next;
        print $F[0];
    ' \
    | sort -n \
    > anchor.txt

rm unambiguous.cover.*

#----------------------------#
# anchor2
#----------------------------#
log_info "anchor2 - unambiguous2"

# contiguous unique region longer than 1000
jrunlist span unambiguous.cover.yml --op excise -n 1000 -o unambiguous2.cover.yml
jrunlist stat sr.chr.sizes unambiguous2.cover.yml -o unambiguous2.cover.csv

cat unambiguous2.cover.csv \
    | perl -nla -F"," -e '
        $F[0] eq q{chr} and next;
        $F[0] eq q{all} and next;
        $F[2] < 1000 and next;
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
# anchor2
#----------------------------#
log_info "pe.anchor.fa & pe.others.fa"
faops some -l 0 SR.fasta anchor.txt pe.anchor.fa

faops some -l 0 SR.fasta anchor2.txt stdout >> pe.anchor.fa

faops some -l 0 -i SR.fasta anchor.txt stdout \
    | faops some -l 0 -i stdin anchor2.txt pe.others.fa

#----------------------------#
# Done
#----------------------------#
touch anchor.success
log_info "Done."
