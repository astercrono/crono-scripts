#!/usr/bin/env bash
source "$CSCRIPT_TEST/cpak/cpak_single.sh"
source "$CSCRIPT_TEST/cpak/cpak_batch_pack.sh"
source "$CSCRIPT_TEST/cpak/cpak_batch_unpack.sh"

TEST_DIR="/tmp"

run_test "cpak_single_test" "Pack and unpack a file (Single)"
run_test "cpak_batch_pack_test" "Pack many files into one archive (Batch)"
run_test "cpak_batch_unpack_test" "Unpack many files (Batch)"