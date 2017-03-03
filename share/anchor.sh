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
    echo >&2 -e "==> $@"
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
    anchr merge ../work1/superReadSequences.fasta --len 500 --idt 0.98 -o SR.clean.fasta
else
    anchr merge ../k_unitigs.fasta --len 500 --idt 0.98 -o SR.clean.fasta
fi

faops size SR.clean.fasta > sr.chr.sizes

#----------------------------#
# unambiguous
#----------------------------#
log_info "unambiguous regions"

# index
log_debug "bbmap index"
bbmap.sh ref=SR.clean.fasta \
    1>bbmap.err 2>&1

log_debug "bbmap"
bbmap.sh \
    maxindel=0 strictmaxindel perfectmode \
    threads=${N_THREADS} \
    ambiguous=toss \
    ref=SR.clean.fasta in=pe.cor.fa \
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

#----------------------------#
# ambiguous
#----------------------------#
log_info "ambiguous regions"

log_debug "pe.unmapped.txt"
cat unmapped.sam \
    | perl -nle '
        /^@/ and next;
        @fields = split "\t";
        print $fields[0];
    ' \
    > pe.unmapped.txt

log_debug "pe.unmapped.fa"

# Too large for `faops some`
split -n10 -d pe.unmapped.txt pe.part

if [ -e pe.unmapped.fa ];
then
    rm pe.unmapped.fa
fi

for part in $(printf "%.2d " {0..9})
do
    faops some -l 0 pe.cor.fa pe.part${part} stdout
    rm pe.part${part}
done >> pe.unmapped.fa

log_debug "bbmap"
bbmap.sh \
    maxindel=0 strictmaxindel perfectmode \
    threads=${N_THREADS} \
    ref=SR.clean.fasta in=pe.unmapped.fa \
    outm=ambiguous.sam outu=unmapped2.sam \
    1>>bbmap.err 2>&1

log_debug "sort bam"
picard SortSam \
    INPUT=ambiguous.sam \
    OUTPUT=ambiguous.sort.bam \
    SORT_ORDER=coordinate \
    VALIDATION_STRINGENCY=LENIENT \
    1>>picard.err 2>&1

log_debug "genomeCoverageBed"
genomeCoverageBed -bga -split -g sr.chr.sizes -ibam ambiguous.sort.bam \
    | perl -nlae '
        $F[3] == 0 and next;
        printf qq{%s:%s-%s\n}, $F[0], $F[1] + 1, $F[2];
    ' \
    > ambiguous.cover.txt

#----------------------------#
# anchor
#----------------------------#
log_info "pe.anchor.fa"

log_debug "unambiguous.cover"
jrunlist cover unambiguous.cover.txt

log_debug "ambiguous.cover"
jrunlist cover ambiguous.cover.txt

log_debug "unique.cover"
jrunlist compare --op diff unambiguous.cover.txt.yml ambiguous.cover.txt.yml -o unique.cover.yml
runlist stat unique.cover.yml -s sr.chr.sizes -o unique.cover.csv

cat unique.cover.csv \
    | perl -nla -F"," -e '
        $F[0] eq q{chr} and next;
        $F[0] eq q{all} and next;
        $F[2] < 1000 and next;
        $F[3] < 0.95 and next;
        print $F[0];
    ' \
    | sort -n \
    > anchor.txt

log_debug "pe.anchor.fa"
faops some -l 0 SR.clean.fasta anchor.txt pe.anchor.fa

#----------------------------#
# anchor2
#----------------------------#
log_info "pe.anchor2.fa & pe.others.fa"

# contiguous unique region longer than 1000
jrunlist span unique.cover.yml --op excise -n 1000 -o stdout \
    | runlist stat stdin -s sr.chr.sizes -o unique2.cover.csv

cat unique2.cover.csv \
    | perl -nla -F"," -e '
        $F[0] eq q{chr} and next;
        $F[0] eq q{all} and next;
        $F[2] < 1000 and next;
        print $F[0];
    ' \
    | sort -n \
    > unique2.txt

cat unique2.txt \
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

faops some -l 0 SR.clean.fasta anchor2.txt pe.anchor2.fa

faops some -l 0 -i SR.clean.fasta anchor.txt stdout \
    | faops some -l 0 -i stdin anchor2.txt pe.others.fa

rm unique2.cover.csv unique2.txt

#----------------------------#
# Record unique regions
#----------------------------#
log_info "Record unique regions"

cat pe.anchor2.fa \
    | perl -nl -MPath::Tiny -e '
        BEGIN {
            %seen = ();
            @ls = grep {/\S/}
                  path(q{unique.cover.yml})->lines({ chomp => 1});
            for (@ls) {
                /^(\d+):\s+([\d,-]+)/ or next;
                $seen{$1} = $2;
            }
            $flag = 0;
        }

        if (/^>(\d+)/) {
            if ($seen{$1}) {
                print qq{>$1|$seen{$1}};
                $flag = 1;
            }
        }
        elsif (/^\w+/) {
            if ($flag) {
                print;
                $flag = 0;
            }
        }
    ' \
    > pe.anchor2.record.fa

cat pe.others.fa \
    | perl -nl -MPath::Tiny -e '
        BEGIN {
            %seen = ();
            @ls = grep {/\S/}
                  path(q{unique.cover.yml})->lines({ chomp => 1});
            for (@ls) {
                /^(\d+):\s+([\d,-]+)/ or next;
                $seen{$1} = $2;
            }
            $flag = 0;
        }

        if (/^>(\d+)/) {
            if ($seen{$1}) {
                print qq{>$1|$seen{$1}};
            }
            else {
                print;
            }
            $flag = 1;
        }
        elsif (/^\w+/) {
            if ($flag) {
                print;
                $flag = 0;
            }
        }
    ' \
    > pe.others.record.fa

#----------------------------#
# Clear intermediate files
#----------------------------#
log_info "Clear intermediate files"

find . -type f -name "ambiguous.sam"   | parallel --no-run-if-empty -j 1 rm
find . -type f -name "unambiguous.sam" | parallel --no-run-if-empty -j 1 rm
find . -type f -name "unmapped.sam"    | parallel --no-run-if-empty -j 1 rm
find . -type f -name "pe.unmapped.fa"  | parallel --no-run-if-empty -j 1 rm

#----------------------------#
# Done
#----------------------------#
touch anchor.success
log_info "Done."
