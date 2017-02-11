#!/usr/bin/env bash

check_install () {
    if brew list --versions $1 > /dev/null; then
        echo "$1 already installed"
    else
        brew install $1;
    fi
}

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    check_install jdk
    check_install wang-q/tap/superreads
fi

for package in parallel pigz;
do
    check_install ${package}
done

for package in bbtools bedtools fastqc picard-tools samtools sickle;
do
    check_install homebrew/science/${package};
done

for package in faops jrunlist scythe sparsemem dazz_db@20161112 daligner@20170203;
do
    check_install wang-q/tap/${package};
done

exit 0
