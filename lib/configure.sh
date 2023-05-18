#!/usr/bin/env bash

CSCRIPT_LIB="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CSCRIPT_DIR="$( cd $CSCRIPT_LIB/.. && pwd )"
CSCRIPT_TEST="$( cd $CSCRIPT_DIR/test && pwd )"
CSCRIPT_SPACE_ENCODE="@%@%"
CSCRIPT_VAR_ENCODE_START="@@{"
CSCRIPT_VAR_ENCODE_END="}@@"

source "${CSCRIPT_LIB}/fancy.sh"

CS_VAR() {
    var_name="$1"
    echo "$CSCRIPT_VAR_ENCODE_START$var_name$CSCRIPT_VAR_ENCODE_END"
}

CS_VAR_SET() {
    var_name="$1"
    var_val="$2"
    target="$3"

    var_name_encoded=$(CS_VAR "$var_name")

    echo "${target//$var_name_encoded/$var_val}"
}