#!/bin/bash

# Script documentation

# Options, see http://www.tldp.org/LDP/abs/html/options.html for list.  Some ones you almost always want
set -e  # Fail on failing commands
set -o pipefail # Fail if any part of a pipe fails
set -u  # Fail on unset variable, prevents 'rm -Rf $missing/*' errors

# Declare "globals", especially if theyr'e used in the usage or cmdline parsing.  See below for
# alternate cli parsing/defaults for small scripts.
options="default"

# Helper to log to stderr
err() {
    echo >&2 "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $@"
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

# For small scripts, it is easier to explicitly read out positional args w/ defaults:
option=${1:-default}

# An alternate notation updates a variable in place if it's not set, though generally the above is
# easier.
$options=$1
: ${options:=default}   # Leading ':' prevents bash from evaluating the line

# If you require root, make the caller run with sudo, don't use SUID or SGID
if [[ $EUID -ne 0 ]]; then
   echo >&2 "This script must be run as root, use sudo"
   exit 1
fi

# The rest of your script

## Some random tips

# Use -- before user provided positional args so they're not intepreted as command flags
cat -- "$1"

# Use umask to avoid race conditions on secret files, though this is also hackable, see
# https://developer.apple.com/library/mac/documentation/OpenSource/Conceptual/ShellScripting/ShellScriptSecurity/ShellScriptSecurity.html
(umask 0177 && echo secret > secret.txt)

# Use '[[ ... ]]' for conditionals (instead of '[ ... ]' or 'test'), the former don't expand
# pathnames and allow regexs.

# Use mktemp for temporary files, use trap to cleanup
filename=$(mktemp)

# Trap to perform cleanup on signals
cleanup() {
    echo 'cleaning up!'
    rm -f $filename
}
trap cleanup HUP INT QUIT TERM EXIT

echo >$filename 'Whatever'
