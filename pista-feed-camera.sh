#! /bin/bash

# XXX pipefail breaks our exit-code-based test.
# set -o pipefail
set -e

camera_in_use() {
    sudo lsof /dev/video* \
    2> /dev/null \
    | awk 'BEGIN {code = 1} NR == 2 {code = 0} END {exit code}'
}


main() {
    local -r interval="$1"

    printf '[debug] interval: \"%d\"\n' "$interval" 1>&2

    trap '' PIPE

    while :
    do
        if camera_in_use
        then
            printf '!\n'
        else
            printf '\n'
        fi
        sleep "$interval"
    done
}

main "$@"
