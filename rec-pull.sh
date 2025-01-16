#!/bin/bash
set -e

echo "Updating GIT repos"
ODIR=`pwd`
for i in `find $ODIR -name '.git' -type d | sed s@/.git@@g`
do
    cd $i
    echo "Updating $i"
    git pull
done
cd $ODIR
