#!/usr/bin/env bash

cpak_single_case() {
    local pack_type="$1"
    local output_dir="$TEST_DIR/working"
    local file="$2"
    local pack_output="test_package"
    local unpack_matches_original="$3"

    cd "$TEST_DIR"
    echo "test" > "$file"

    # Pack
    if $VERBOSE; then
        bash $CSCRIPT_DIR/bin/cpak p -v -t $pack_type -o $pack_output "$TEST_DIR/$file"
        local status_code="$?"
    else
        bash $CSCRIPT_DIR/bin/cpak p -t $pack_type -o $pack_output "$TEST_DIR/$file" &>/dev/null
        local status_code="$?"
    fi

    if [ $status_code -eq 1 ]; then
        case_fail "Unknown error during packing procedure"
        return 1
    fi
    
    if [ ! -f "$pack_output.$pack_type" ]; then
        case_fail "Missing packed file"
        return 1
    fi

    # Unpack
    if $VERBOSE; then
        bash $CSCRIPT_DIR/bin/cpak u -v -o "$output_dir" "$pack_output.$pack_type"
        status_code="$?"
    else
        bash $CSCRIPT_DIR/bin/cpak u -o "$output_dir" "$pack_output.$pack_type" &>/dev/null
        status_code="$?"
    fi

    if [ $status_code -eq 1 ]; then
        case_fail "Unknown error during packing procedure"
        return 1
    elif [[ "$unpack_matches_original" == "false" ]]; then
        if [ ! -f "$output_dir/$pack_output" ]; then
            case_fail "Missing unpacked file: Expected=$output_dir/$pack_output"
            return 1
        fi
    elif [ ! -f "$output_dir/$file" ]; then
        case_fail "Missing unpacked file: Expected=$output_dir/$file"
        return 1
    fi

    case_pass

    [ -f "$file" ] && rm "$file"
    [ -d "$output_dir" ] && rm -r "$output_dir"

    return 0
}

cpak_single_test() {
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
        file="${tc[1]}"
        match_og="${tc[2]}"

        case_set "$cmd"
        cpak_single_case "$cmd" "$file" "$match_og"

        [ -d "$output" ] && rm -r "$output"
    done
}