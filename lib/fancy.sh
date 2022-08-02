#!/bin/bash
#
# Notes: 
#     - Bash 4 is required for associative arrays.
# 
FANCY_TEMPLATE="\e[STYLECOLORmVALUE\e[0m"

declare -A FANCY_COLORS=( 
    ["red"]=";31" 
    ["green"]=";32"
    ["yellow"]=";33"
    ["blue"]=";34"
    ["magenta"]=";35"
    ["cyan"]=";36"
    ["gray"]=";37"
    ["none"]=""
)

declare -A FANCY_STYLES=(
    ["normal"]="0"
    ["bold"]="1"
    ["underline"]="4"
    ["reverse"]="7"
)

fancy_print() {
    if [ "$#" -eq 3 ]; then
        style="${FANCY_STYLES[$1]}"
        color="${FANCY_COLORS[$2]}"
        value=$3
    elif [ "$#" -eq 2 ]; then
        style="${FANCY_STYLES[$1]}"
        color="${FANCY_COLORS[none]}"

        if [ -z "$style" ]; then
            style="${FANCY_STYLES[normal]}"
            color="${FANCY_COLORS[$1]}"
        fi

        value=$2
    elif [ "$#" -eq 1 ]; then
        style="${FANCY_STYLES[normal]}"
        color="${FANCY_COLORS[none]}"
        value=$1
    fi

    fancy="${FANCY_TEMPLATE//STYLE/$style}"
    fancy="${fancy//COLOR/$color}"
    fancy="${fancy//VALUE/$value}"

    echo -en "$fancy"
}

fancy_println() {
    fancy=$(fancy_print $@)
    echo -e "$fancy"
}
