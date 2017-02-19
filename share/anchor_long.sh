#!/usr/bin/env bash

USAGE="Usage: $0 ANCHOR_FILE LONG_FILE WORKING_DIR BLOCK_SIZE N_THREADS"

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
    echo >&2 -e "==> $@"
}

#----------------------------#
# Parameters
#----------------------------#
ANCHOR_FILE=$1
LONG_FILE=$2
WORKING_DIR=${3:-.}
BLOCK_SIZE=${4:-50}
N_THREADS=${5:-8}

log_info "Parameters"
log_debug "    ANCHOR_FILE=${ANCHOR_FILE}"
log_debug "    LONG_FILE=${LONG_FILE}"
log_debug "    WORKING_DIR=${WORKING_DIR}"
log_debug "    BLOCK_SIZE=${BLOCK_SIZE}"
log_debug "    N_THREADS=${N_THREADS}"

[ -e ${ANCHOR_FILE} ] || {
    log_warn "Can't find anchor file [${ANCHOR_FILE}].";
    exit 1;
}

[ -e ${LONG_FILE} ] || {
    log_warn "Can't find long-reads file [${LONG_FILE}].";
    exit 1;
}

[ -d ${WORKING_DIR} ] || {
    log_warn "Can't find working directory [${WORKING_DIR}].";
    exit 1;
}

#----------------------------#
# Prepare sequences
#----------------------------#
log_info "Prepare sequences"
mkdir -p ${WORKING_DIR}/anchorLong
cat ${ANCHOR_FILE} \
    | anchr dazzname --prefix anchor stdin -o stdout \
    | faops filter -l 0 stdin ${WORKING_DIR}/anchorLong/anchor.fasta
mv stdout.replace.tsv ${WORKING_DIR}/anchorLong/anchor.replace.tsv

ANCHOR_SUM=$(  faops n50 -H -N 0 -S ${WORKING_DIR}/anchorLong/anchor.fasta)
ANCHOR_COUNT=$(faops n50 -H -N 0 -C ${WORKING_DIR}/anchorLong/anchor.fasta)
log_debug "ANCHOR_SUM ${ANCHOR_SUM}"
log_debug "ANCHOR_COUNT ${ANCHOR_COUNT}"

cat ${LONG_FILE} \
    | anchr dazzname --prefix long --start $((${ANCHOR_COUNT} + 1)) stdin -o stdout \
    | faops filter -l 0 -a 2000 stdin ${WORKING_DIR}/anchorLong/long.fasta
mv stdout.replace.tsv ${WORKING_DIR}/anchorLong/long.replace.tsv

pushd ${WORKING_DIR}/anchorLong

#----------------------------#
# Make the dazzler DB
#----------------------------#
log_info "Make the dazzler DB"
if [[ -e anchorLongDB.db || -e .anchorLongDB.bps ]]; then
    DBrm anchorLongDB
fi
fasta2DB anchorLongDB anchor.fasta
fasta2DB anchorLongDB long.fasta
DBdust anchorLongDB
DBsplit -s${BLOCK_SIZE} anchorLongDB

BLOCK_NUMBER=$(cat anchorLongDB.db | perl -nl -e '/^blocks\s+=\s+(\d+)/ and print $1')
log_debug "BLOCK_NUMBER ${BLOCK_NUMBER}"

ANCHOR_IDX=$(( ${ANCHOR_SUM} / 1000000 / ${BLOCK_SIZE} + 1 ))
log_debug "ANCHOR_IDX ${ANCHOR_IDX}"

#----------------------------#
# daligner
#----------------------------#
log_info "daligner"
if [[ -e anchorLongDB.las || -e anchorLongDB.1.las ]]; then
    rm anchorLongDB*.las
fi

for i in $(seq 1 1 ${ANCHOR_IDX}); do
    seq 1 1 ${BLOCK_NUMBER} \
        | parallel --no-run-if-empty --keep-order -j 4 "
            daligner -e0.8 -l1000 -s1000 -M16 -mdust anchorLongDB.${i} anchorLongDB.{};
            LAcheck -vS anchorLongDB anchorLongDB.1.anchorLongDB.{};
            LAcheck -vS anchorLongDB anchorLongDB.{}.anchorLongDB.1;
        "
done

for i in $(seq 1 1 ${ANCHOR_IDX}); do
    LAmerge -v anchorLongDB.${i} \
        $(for j in $(seq 1 1 ${BLOCK_NUMBER}); do printf "anchorLongDB.${i}.anchorLongDB.${j} "; done)
    LAcheck -vS anchorLongDB anchorLongDB.${i}
done

rm anchorLongDB.*.anchorLongDB.*.las

LAcat -v anchorLongDB.#.las > anchorLongDB.las
LAcheck -vS anchorLongDB anchorLongDB
rm anchorLongDB.*.las

#----------------------------#
# show2ovlp
#----------------------------#
log_info "show2ovlp"
LAshow -o anchorLongDB.db anchorLongDB.las > anchorLong.show.txt
cat anchor.fasta long.fasta \
    | anchr show2ovlp stdin anchorLong.show.txt -o anchorLong.ovlp.tsv

#----------------------------#
# Done
#----------------------------#
touch long.success
popd
log_info "Done."
