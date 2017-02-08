#!/usr/bin/env bash

for package in jdk parallel pigz;
do
    brew install ${package};
    [ $? -ne 0 ] && exit 1;
done

for package in bbtools bedtools picard-tools samtools sickle;
do
    brew install homebrew/science/${package};
    [ $? -ne 0 ] && exit 1;
done

for package in faops jrunlist sparsemem dazz_db@20161112 daligner@20170203 scythe;
do
    brew install wang-q/tap/${package};
    [ $? -ne 0 ] && exit 1;
done
