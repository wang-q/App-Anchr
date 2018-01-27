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
fi

for package in graphviz jq parallel pigz;
do
    check_install ${package}
done

for package in bbtools fastqc minimap miniasm poa samtools seqtk sickle;
do
    check_install brewsci/science/${package};
done

for package in faops jrange jrunlist sparsemem dazz_db@20161112 daligner@20170203;
do
    check_install wang-q/tap/${package};
done

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    if brew list --versions jellyfish > /dev/null; then
        brew unlink jellyfish
    fi
    check_install wang-q/tap/jellyfish@2.2.4
    brew unlink jellyfish@2.2.4 && brew link jellyfish@2.2.4
    check_install wang-q/tap/quorum@1.1.1
    check_install wang-q/tap/superreads
fi

exit 0
