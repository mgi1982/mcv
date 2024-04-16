#!/bin/bash

set -e 

LEN=32

while [ -n "$1" ]; 
do
    case "$1" in
        -l)
            shift
            LEN=$1
            ;;
    esac
    shift
done

LC_CTYPE=C < /dev/urandom tr -dc '[:print:]' | head -c${1:-$LEN} | sed 's/\s/*/g'
