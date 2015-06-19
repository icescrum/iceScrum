#!/usr/bin/env bash
PORT_NUMBER="$1"

function usage {
    echo "usage: ${0##*/} "
    echo "ex: ${0##*/} 5005"
}

if [ -z $PORT_NUMBER ]; then
    usage
    exit 1
fi

echo "waiting for port $PORT_NUMBER to open up"

while ! nc -z localhost $PORT_NUMBER; do sleep 0.1; done;