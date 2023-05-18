cpak_batch_unpack_case() {
    local pack_type="$1"
    local output_dir="$TEST_DIR/working"
    local file_base="$2"
    local pack_output="test_package"
    local expected_file_count=5

    cd "$TEST_DIR"

    local i=0
    while [ "$i" -lt "$expected_file_count" ]; do
        echo "hello" > "${file}${i}.test"
        i=$((i + 1))
    done

    # Pack
    for f in "$output_dir"/*.test; do
        if $VERBOSE; then
            bash $CSCRIPT_DIR/bin/cpak p -v -t $pack_type -o $pack_output "$f"
            local status_code="$?"
        else
            bash $CSCRIPT_DIR/bin/cpak p -t $pack_type -o $pack_output "$f" &>/dev/null
            local status_code="$?"
        fi
    done

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
    else
        local checked_file_count=0
        for f in "$output_dir"/*.test; do
            file_content=$(cat "$f")

            if [[ "$file_content" != "hello" ]]; then
                case_fail "Unexpected unpacked file contents. Expected=hello, Actual=$file_content"
                return 1
            fi

            checked_file_count=$((checked_file_count + 1))
        done

        if [[ "$checked_file_count" != "$expected_file_count" ]]; then
            case_fail "Incorrect number of unpacked files. Expected=$expected_file_count, Actual=$checked_file_count"
            return 1
        fi
    fi

    case_pass

    [ -f "$file" ] && rm "$file"
    [ -d "$output_dir" ] && rm -r "$output_dir"

    return 0
}

cpak_batch_unpack_test() {
    local test_cases=(
        "7z;testfile;true" 
        "rar;testfile;true"
        "tar;testfile;true"
        "tar.bz2;testfile;true"
        "tar.gz;testfile;true"
        "tar.xz;testfile;true"
        "zip;testfile;true"
    )

    for tc_def in "${test_cases[@]}"; do
        tc=(${tc_def//;/ })
        cmd="${tc[0]}"
        file="${tc[1]}"
        match_og="${tc[2]}"

        case_set "$cmd"
        cpak_batch_pack_case "$cmd" "$file" "$match_og"

        [ -d "$output" ] && rm -r "$output"
    done
}
