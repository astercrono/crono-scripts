#!/usr/bin/env bash
#
# Notes: 
#     - Bash 4+ is required for associative arrays.
# 
declare -A __FANCY_COLORS=( 
    ["red"]=";31" 
    ["green"]=";32"
    ["yellow"]=";33"
    ["blue"]=";34"
    ["magenta"]=";35"
    ["cyan"]=";36"
    ["gray"]=";37"
    ["none"]=""
)

declare -A __FANCY_STYLES=(
    ["normal"]="0"
    ["bold"]="1"
    ["underline"]="4"
    ["reverse"]="7"
)

function __validate_style {
    if [ "${__FANCY_STYLES[$1]}" ]; then
        return 0
    else
        fancy_print -s bold -c red "Invalid Style"
        return 1
    fi
}

function __validate_color {
    if [ "${__FANCY_COLORS[$1]}" ]; then
        return 0
    else
        fancy_print -s bold -c red "Invalid Color"
        return 1
    fi
}

__fancy_usage() {
    cmd_suffix="$1"
    fancy_print -s bold -c cyan -n "Usage: "
    echo "fancy_print [-s style] [-c color] [-n] [-h] value"
    echo ""
    fancy_print -s bold -c blue "Options: "
    echo "    -s) Select style"
    echo "    -c) Select color"
    echo "    -n) Do not add newline to output"
    echo "    -h) Print this help message"
    echo ""
    fancy_print -s bold -c green "Available Styles: "
    for key in "${!__FANCY_STYLES[@]}"; do
        echo "    $key"
    done
    echo ""
    fancy_print -s bold -c green "Available Colors: "
    for key in "${!__FANCY_COLORS[@]}"; do
        echo "    $key"
    done
    echo ""
}

fancy_print() {
    local style=""
    local color=""
    local value=""
    local newline="\n"

    local OPTIND s c n h
    while getopts "s:c:nh" opt; do
        case $opt in
            s)  
                style="$OPTARG"
                ;;
            c)  
                ! __validate_color "$OPTARG" && __fancy_usage && return 1
                color="$OPTARG"
                ;;
            n)
                newline=""
                ;;
            h)
                __fancy_usage && return 0
                ;;
            *)  ;;
        esac
    done

    shift $(($OPTIND - 1))

    local value="$1"

    if [[ "$value" == "" ]]; then
        fancy_print -s bold -c red "Missing Value"
        __fancy_usage
        return 1
    fi
    [[ "$style" == "" ]] && style="normal"
    [[ "$color" == "" ]] && color="none"

    local style_code="${__FANCY_STYLES[$style]}"
    local color_code="${__FANCY_COLORS[$color]}"

    printf "\e[${style_code}${color_code}m${value}\e[0m${newline}"
}
