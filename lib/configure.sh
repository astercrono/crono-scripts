#!/usr/bin/env bash

CSCRIPT_LIB_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CSCRIPT_DIR="$( cd $CSCRIPT_LIB_DIR/.. && pwd )"

source "${CSCRIPT_LIB_DIR}/fancy.sh"