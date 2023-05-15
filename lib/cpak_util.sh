#!/usr/bin/env bash

function match_file_ext() {
    local filename="$1"
    local matches=""
    local final_match=""

    for key in "${!__CPAK_CMD_MAP[@]}"; do
        if [[ "$filename" == *"$key" ]]; then
            matches+=("$key")
        fi
    done

    largest=-1
    for m in ${matches[@]}; do
        m_len=${#m}
        if [ ${m_len} -gt $largest ]; then
            largest=$m_len
            final_match="$m"
        fi
    done

    echo "$final_match"
}

function strip_file_ext() {
    local filename="$1"
    local extension=$(match_file_ext "$file")
    echo "${file//.$extension/}"
}