#!/usr/bin/env bash

USAGE="Usage: $0 STAT_TASK(1|2|3|4) RESULT_DIR(header) [GENOME_SIZE]"

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
STAT_TASK=$1
RESULT_DIR=$2
GENOME_SIZE=$3

#----------------------------#
# Run
#----------------------------#
if [ "${STAT_TASK}" = "1" ]; then
    if [ "${RESULT_DIR}" = "header" ]; then
        printf "| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | \n" \
            "Name" \
            "SumFq" "CovFq" "AvgRead" "Kmer" \
            "SumFa" "Discard%" "#Subs" "Subs%" \
            "RealG" "EstG" "Est/Real" \
            "SumSR" "SumSR/Real" "SR/EstG" \
            "RunTime"
        printf "|:--|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|\n"
    elif [ "${GENOME_SIZE}" -ne "${GENOME_SIZE}" ]; then
        log_warn "Need a integer for GENOME_SIZE"
        exit 1;
    elif [ -e "${RESULT_DIR}/environment.sh" ]; then
        log_debug "${RESULT_DIR}"
        cd "${RESULT_DIR}"

        SUM_FQ=$( if [ -e pe.renamed.fastq ]; then faops n50 -H -N 0 -S pe.renamed.fastq; else echo 0; fi )
        SUM_FA=$( faops n50 -H -N 0 -S pe.cor.fa )
        TOTAL_SUBS=$( cat pe.cor.fa | tr ' ' '\n' | grep ":sub:" | wc -l )
        EST_G=$( cat environment.sh | perl -n -e '/ESTIMATED_GENOME_SIZE=\"(\d+)\"/ and print $1' )
        SUM_SR=$( faops n50 -H -N 0 -S work1/superReadSequences.fasta)
        SECS=$(expr $(stat -c %Y super1.err) - $(stat -c %Y superreads.sh))

        printf "| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | \n" \
            $( basename $( pwd ) ) \
            $( perl -MNumber::Format -e "print Number::Format::format_bytes(${SUM_FQ}, base => 1000,);" ) \
            $( perl -e "printf qq{%.1f}, ${SUM_FQ} / ${GENOME_SIZE};" ) \
            $( cat environment.sh | perl -n -e '/PE_AVG_READ_LENGTH=\"(\d+)\"/ and print $1' ) \
            $( cat environment.sh | perl -n -e '/KMER=\"(\d+)\"/ and print $1' ) \
            $( perl -MNumber::Format -e "print Number::Format::format_bytes(${SUM_FA}, base => 1000,);" ) \
            $( perl -e "printf qq{%.3f%%}, (1 - ${SUM_FA} / ${SUM_FQ}) * 100;" ) \
            $( perl -MNumber::Format -e "print Number::Format::format_bytes(${TOTAL_SUBS}, base => 1000,);" ) \
            $( perl -e "printf qq{%.3f%%}, ${TOTAL_SUBS} / ${SUM_FA} * 100;" ) \
            $( perl -MNumber::Format -e "print Number::Format::format_bytes(${GENOME_SIZE}, base => 1000,);" ) \
            $( perl -MNumber::Format -e "print Number::Format::format_bytes(${EST_G}, base => 1000,);" ) \
            $( perl -e "printf qq{%.2f}, ${EST_G} / ${GENOME_SIZE}" ) \
            $( perl -MNumber::Format -e "print Number::Format::format_bytes(${SUM_SR}, base => 1000,);" ) \
            $( perl -e "printf qq{%.2f}, ${SUM_SR} / ${EST_G}" ) \
            $( perl -e "printf qq{%.2f}, ${SUM_SR} / ${GENOME_SIZE}" ) \
            $( printf "%d:%02d'%02d''\n" $((${SECS}/3600)) $((${SECS}%3600/60)) $((${SECS}%60)) )
    else
        log_warn "RESULT_DIR not exists"
    fi

elif [ "${STAT_TASK}" = "3" ]; then
    if [ "${RESULT_DIR}" = "header" ]; then
        printf "| %s | %s | %s | %s | %s | %s | %s | %s | \n" \
            "Name" "#cor.fa" "#strict.fa" "strict/cor" "N50SRclean" "SumSRclean" "#SRclean" "RunTime"
        printf "|:--|--:|--:|--:|--:|--:|--:|--:|\n"
    elif [ -d "${RESULT_DIR}/sr" ]; then
        log_debug "${RESULT_DIR}"
        cd "${RESULT_DIR}/sr"

        SECS=$(expr $(stat -c %Y anchor.success) - $(stat -c %Y pe.cor.fa))
        COUNT_COR=$( faops n50 -H -N 0 -C pe.cor.fa )
        COUNT_STRICT=$( faops n50 -H -N 0 -C pe.strict.fa )
        printf "| %s | %s | %s | %s | %s | %s | %s | %s | \n" \
            $( basename $( dirname $(pwd) ) ) \
            ${COUNT_COR} \
            ${COUNT_STRICT} \
            $( perl -e "printf qq{%.4f}, ${COUNT_STRICT} / ${COUNT_COR}" ) \
            $( faops n50 -H -N 50 -S -C SR.clean.fasta ) \
            $( printf "%d:%02d'%02d''\n" $((${SECS}/3600)) $((${SECS}%3600/60)) $((${SECS}%60)) )
    else
        log_warn "RESULT_DIR/sr not exists"
    fi

elif [ "${STAT_TASK}" = "4" ]; then
    if [ "${RESULT_DIR}" = "header" ]; then
        printf "| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | \n" \
            "Name" \
            "N50Anchor" "SumAnchor" "#anchor" \
            "N50Anchor2" "SumAnchor2" "#anchor2" \
            "N50Others" "SumOthers" "#others"
        printf "|:--|--:|--:|--:|--:|--:|--:|--:|--:|--:|\n"
    elif [ -d "${RESULT_DIR}/sr" ]; then
        log_debug "${RESULT_DIR}"
        cd "${RESULT_DIR}/sr"

        printf "| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | \n" \
            $( basename $( dirname $(pwd) ) ) \
            $( faops n50 -H -N 50 -S -C pe.anchor.fa ) \
            $( faops n50 -H -N 50 -S -C pe.anchor2.fa ) \
            $( faops n50 -H -N 50 -S -C pe.others.fa )
    else
        log_warn "RESULT_DIR/sr not exists"
    fi

else
    log_warn "Unsupported STAT_TASK"
fi
