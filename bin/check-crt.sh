#!/bin/bash

set -e

if [[ $1 =~ .*:.* ]] ; then
    host=$1
else
    host=$1:443
fi
SHOW_ALL="NO"
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -a|--all)
        SHOW_ALL="YES"
        ;;
    esac

    shift # past argument or value
done

CLIENT_OPTS="s_client -showcerts -connect $host"
X509_OPTS="x509 -inform pem -noout -text"

if [ "$SHOW_ALL" = "YES" ] ; then
    echo | openssl $CLIENT_OPTS 2>/dev/null | openssl $X509_OPTS 2>/dev/null
else
    echo | openssl $CLIENT_OPTS 2>/dev/null | openssl $X509_OPTS 2>/dev/null | grep Validity -A 2
fi

