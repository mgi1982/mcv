#!/bin/bash

set -e

ODIR="$PWD"
for repo in $(find . -maxdepth 2 -mindepth 2 -name '.git') ; do
    DIR=$ODIR/$(dirname $repo | sed 's/\.\///g')
    cd $DIR
    git status | grep "working tree clean" -q --color=always && echo $DIR is clean || (echo ; echo $DIR is ; git status)
done
cd $ODIR
