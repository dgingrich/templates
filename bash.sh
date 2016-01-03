#!/bin/bash
set -o pipefail # Fail if any prat of a pipe fails
set -e  # Fail on failing commands
set -u  # Fail on unset variable

# Declare "globals", especially if they're used in the help
option="default";

# Helper to write to stderr
err() {
    echo >&2 "$@"
}

# Output usage
usage() {
    cat <<EOF
USAGE: $0 [-h | --help] [-v | --verbose] [--option] <otheropts>

    --help: Display this message

    -v, --verbose: Turn on verbosity, which sets +x, echoing all commands to
        stderr before executing.

    --option: Whatever, defaults to $options

    <otheropts>: These too

Describe what happens.

EOF
}

# Parse args and validate
opts=`getopts -o hv --long help,verbose,option -- "$@"` || { err "Failed parsing args: $@"; usage; exit; }
eval set -- "$opts"
while true; do
    case "$1" in
        -h | --help)    usage; exit 0 ;;
        -v | --verbose) set -x; shift ;;
        --option)       option="$1"; shift ;;
        --)             shift; break ;;
        *)              break ;;
    esac
done
if (( $# != 1 )); then
    err "Must specify exactly one other_opts"
    usage
    exit 1
fi

# Random logic

# Example of trapping
trap 'echo exiting' HUP INT QUIT TERM EXIT
