#!/usr/bin/env bash

# Events that occur within this time from an initial one are ignored
ignore_secs=0.25
clear='false'
verbose='false'

function usage {
    echo "Rerun a given command every time filesystem changes are detected."
    echo ""
    echo "Usage: $(basename $0) [OPTIONS] COMMAND"
    echo ""
    echo "  -c, --clear     Clear the screen before each execution of COMMAND."
    echo "  -v, --verbose   Print the name of the files that changed to cause"
    echo "                  each execution of COMMAND."
    echo "  -h, --help      Display this help and exit."
    echo ""
    echo "Run the given COMMAND, and then every time filesystem changes are"
    echo "detected in or below the current directory, run COMMAND again."
    echo "Changes within $ignore_secs seconds are grouped into one."
    echo ""
    echo "This is useful for running commands to regenerate visual output every"
    echo "time you hit [save] in your editor. For example, re-run tests, or"
    echo "refresh markdown or graphviz rendering."
    echo ""
    echo "COMMAND can only be a simple command, ie. \"executable arg arg...\"."
    echo "For compound commands, use:"
    echo ""
    echo "    rerun bash -c \"ls -l | grep ^d\""
    echo ""
    echo "Using this it's pretty easy to rig up ad-hoc GUI apps on the fly."
    echo "For example, every time you save a .dot file from the comfort of"
    echo "your favourite editor, rerun can execute GraphViz to render it to"
    echo "SVG, and refresh whatever GUI program you use to view that SVG."
    echo ""
    echo "COMMAND can't be a shell alias, and I don't understand why not."
}

while [ $# -gt 0 ]; do
    case "$1" in
      -c|--clear) clear='true';;
      -v|--verbose) verbose='true' ;;
      -h|--help) usage; exit;;
      *) break;;
    esac
    shift
done

function execute() {
    if [ $clear = "true" ]; then
        clear
    fi
    if [ $verbose = "true" ]; then
        if [ -n "$changes" ]; then
            echo -e "Changed: $(echo -e $changes | cut -d' ' -f2 | sort -u | tr '\n' ' ')"
            changes=""
        fi
        echo "$@"
    fi
    "$@"
}

execute "$@"
ignore_until=$(date +%s.%N)

inotifywait --quiet --recursive --monitor --format "%e %w%f" \
    --event modify --event move --event create --event delete \
    . | while read changed
do

    changes="$changes\n$changed"

    if [ $(echo "$(date +%s.%N) > $ignore_until" | bc) -eq 1 ] ; then
        ignore_until=$(echo "$(date +%s.%N) + $ignore_secs" | bc)
        ( sleep $ignore_secs ; execute "$@" ) &
    fi

done

