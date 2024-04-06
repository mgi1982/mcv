#!/usr/bin/env bash

PORTS="118 218 318"
HOST=$1

if [ -z "$1" ] ; then
	echo "Where do you want me to knock?"
    exit 1
fi

function knock() {
    CMD=$(which curl)
    if [ ! -z "$CMD" ] ; then
        CMD="$CMD -q --connect-timeout 0.1 $HOST:$PORT"
    else
        CMD=$(which nc)
        if [ ! -z "$CMD" ] ; then
            CMD="$CMD -G 1 $HOST $PORT"
        else
            CMD=$(which wget)
            if [ ! -z "$CMD" ] ; then
                CMD="$CMD -t 1 --timeout=0.1 $HOST:$PORT"
            fi
        fi
    fi

    if [ -z "$CMD" ] ; then
        echo "No command available to knock. Exiting"
        exit 1
    else
        $CMD
    fi
}

echo "Knock Knock $HOST"
for PORT in $PORTS
do
    knock 2> /dev/null
done
