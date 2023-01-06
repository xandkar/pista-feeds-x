#! /bin/bash

DEFAULT_INTERVAL_SECONDS=$((60 * 60))

total_cargo_build_space() {
    local -r dir="$1"

    find "$dir" -type f -name Cargo.toml \
    | while read -r cargo_toml_path
    do
        target_path=$(dirname "$cargo_toml_path")/target;
        if test -d "$target_path"
        then
            du -s "$target_path"; fi
        done \
    | awk '{tot += $1} END {print tot * 1024}' \
    | numfmt --to=iec
}

assert_unsigned_int() {
    local arg="$1"

    if ! [[ "$arg" =~ ^[0-9]+$ && "$arg" -gt 0 ]]; then
        printf 'Error: expected a single positive integer argument, but received "%s"\n' "$arg" >&2
        exit 1
    fi
}

main() {
    local -r interval="${1-$DEFAULT_INTERVAL_SECONDS}"
    local -r dir="${2-$HOME}"

    assert_unsigned_int "$interval"

    while :
    do
        total_cargo_build_space "$dir"
        sleep "$interval"
    done
}

main "$@"
