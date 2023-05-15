#!/usr/bin/env bash

# source "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/../lib/configure.sh"
# source "$CSCRIPT_DIR/batman"

TEST_DIR="/tmp"

run_single_case() {
    local pack_type="$1"
    local output_dir="$TEST_DIR/working"
    local file="$2"
    local pack_output="test_package"
    local unpack_matches_original="$3"

    cd "$TEST_DIR"
    echo "test" > "$file"

    # Pack
    bash $CSCRIPT_DIR/cpak p -t $pack_type -o $pack_output "$TEST_DIR/$file" &>/dev/null
    # bash $CSCRIPT_DIR/cpak p -v -t $pack_type -o $pack_output "$TEST_DIR/$file" 
    local status_code="$?"

    if [ $status_code -eq 1 ]; then
        case_fail "$pack_type" "Unknown error during packing procedure"
        return 1
    fi
    
    if [ ! -f "$pack_output.$pack_type" ]; then
        case_fail "$pack_type" "Missing packed file"
        return 1
    fi

    # Unpack
    bash $CSCRIPT_DIR/cpak u -o "$output_dir" "$pack_output.$pack_type" &>/dev/null
    # bash $CSCRIPT_DIR/cpak u -v -o "$output_dir" "$pack_output.$pack_type"
    status_code="$?"

    if [ $status_code -eq 1 ]; then
        case_fail "$pack_type" "Unknown error during packing procedure"
        return 1
    elif [[ "$unpack_matches_original" == "false" ]]; then
        if [ ! -f "$output_dir/$pack_output" ]; then
            case_fail "$pack_type" "Missing unpacked file: Expected=$output_dir/$pack_output"
            return 1
        fi
    elif [ ! -f "$output_dir/$file" ]; then
        case_fail "$pack_type" "Missing unpacked file: Expected=$output_dir/$file"
        return 1
    fi

    # case_fail "$pack_type" "Missing packed file"
    case_pass "$pack_type"

    [ -f "$file" ] && rm "$file"
    [ -d "$output_dir" ] && rm -r "$output_dir"

    return 0
}

run_single() {
    local test_cases=(
        "7z;testfile;true" 
        "bz2;testfile;false"
        "gz;testfile;false"
        "rar;testfile;true"
        "tar;testfile;true"
        "tar.bz2;testfile;true"
        "tar.gz;testfile;true"
        "tar.xz;testfile;true"
        "xz;testfile;false"
        "zip;testfile;true"
    )

    for tc_def in "${test_cases[@]}"; do
        tc=(${tc_def//;/ })
        cmd="${tc[0]}"
        pack_type="${tc[1]}"
        output="${tc[2]}"
        file="${tc[3]}"

        run_single_case "$cmd" "$pack_type" "$output" "$file"

        [ -d "$output" ] && rm -r "$output"
    done
}

start_suite "cpak.sh"
run_test "run_single" "Pack and Unpack (Single File)"
end_suite