#!/usr/bin/env bash

check_install () {
    if brew list --versions $1 > /dev/null; then
        echo "$1 already installed"
    else
        brew install $1;
    fi
}

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    check_install openjdk@9
fi

for package in graphviz jq parallel pigz; do
    check_install ${package}
done

for package in fastqc samtools sickle; do
    check_install ${package}
done

for package in bbtools minimap miniasm sga; do
    check_install brewsci/bio/${package};
done

for package in poa; do
    check_install brewsci/science/${package};
done

for package in faops sparsemem dazz_db@20161112 daligner@20170203; do
    check_install wang-q/tap/${package};
done

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    check_install brewsci/bio/masurca
fi

exit 0
