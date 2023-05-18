#!/usr/bin/env bash

source "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/configure.sh"

TARGET_TEST=""
VERBOSE=false
BAT_STATUS=0

SUITE_NAME=""
SUITE_COUNT=0
SUITE_PASS_COUNT=0
SUITE_FAIL_COUNT=0
FAILED_SUITES=()

CASE_WIDTH=30
TEST_INDENT=""
CASE_INDENT="    "
SUMMARY_INDENT="    "

RUN_PATHS=()

bat_banner() {
    cat "$CSCRIPT_LIB/batman_banner.txt"
    echo ""
    echo ""
}

bat_usage() {
    fancy_print -n -s bold -c cyan "Usage: "
    fancy_print -n -s bold "batman "
    fancy_print -n -s underline "[options]" && echo -n " "
    fancy_print -s underline "TARGETS"

    echo ""

    fancy_print -s bold -c green "Options: "
    echo "    -p"
    echo "        Enable plaintext mode."
    echo "        Removes all styles and colors from output."
    echo "    -h"
    echo "        Print this help message"
    echo ""

    fancy_print -s underline "TARGETS"
    echo "May be a single file or GLOB pattern of test scripts."
    echo ""
    fancy_print -c magenta "Test scripts must: "
    echo "    - End with _test.sh"
    echo "    - Make at least 1 valid use of run_test() and case_pass()"
}

bat_valid_test() {
    local path="$@"
    local status=0
    grep -qE "run_test .* .*" "$path"; status=$((status + $?))
    return $status
}

bat_run_tests() {
    for encoded_path in "${RUN_PATHS[@]}"; do
        pushd . &>/dev/null
        [[ ! "$encoded_path" == *"_test.sh" ]] && continue

        local path="${encoded_path/$CSCRIPT_SPACE_ENCODE/\ }"

        if ! bat_valid_test "$path"; then continue; fi

        start_suite "$path"
        . "$path"
        end_suite
        popd &>/dev/null
    done
}

print_divider() {
    echo "__________________________________________________"
}

start_suite() {
    SUITE_NAME="$1"
    SUITE_STATUS=0
    SUITE_COUNT=$((SUITE_COUNT + 1))

    TEST_STATUS=0
    TEST_COUNT=0
    TEST_PASS_COUNT=0
    TEST_FAIL_COUNT=0
    FAILED_TESTS=()

    CASE_PASS_COUNT=0
    CASE_FAIL_COUNT=0

    CASE_DESC=""

    print_divider
    fancy_print -s bold -c yellow "> $SUITE_NAME"
    echo ""
}

run_test() {
    local test_func="$1"
    local name="$2"

    if [[ "$TARGET_TEST" != "" ]] && [[ "${test_func^^}" != *"${TARGET_TEST^^}"* ]]; then
        return 0
    fi

    TEST_COUNT=$((TEST_COUNT + 1))
    TEST_STATUS=0

    fancy_print -n -s bold -c cyan "Running[$test_func]: "
    fancy_print -s bold "$name"

    "$test_func"

    if [ "$TEST_STATUS" -gt 0 ]; then
        TEST_FAIL_COUNT=$((TEST_FAIL_COUNT + 1))
        FAILED_TESTS+=("${name// /_}")
    else
        TEST_PASS_COUNT=$((TEST_PASS_COUNT + 1))
    fi

    echo ""
    return "$TEST_STATUS"
}

case_set() {
    CASE_DESC="$@"
}

case_pass() {
    fancy_print -n -s bold -c green "$CASE_INDENT[PASS] "
    fancy_print -s bold "$CASE_DESC"

    CASE_PASS_COUNT=$((CASE_PASS_COUNT + 1))
    return 0
}

case_fail() {
    local extra_notes="$1"

    fancy_print -n -s bold -c red "$CASE_INDENT[FAIL] "
    fancy_print -n -s bold "$CASE_DESC"

    if [[ "$extra_notes" == "" ]]; then
        echo ""
    else
        pack_type_width=${#pack_type}
        name_width=$((6 + pack_type_width))
        notes_indent=$((CASE_WIDTH - name_width))
        spacing=$(printf "%${notes_indent}s")
        echo "$spacing -- $extra_notes"
    fi

    SUITE_STATUS=1
    TEST_STATUS=1
    BAT_STATUS=1

    CASE_FAIL_COUNT=$((CASE_FAIL_COUNT + 1))

    return 1
}

end_suite() {
    local pass_color="-c green"
    local fail_color=""

    if [ "$TEST_FAIL_COUNT" -gt 0 ]; then
        fail_color="-c red"
        pass_color=""
    fi

    fancy_print -n -s bold "Total Tests: "
    echo " $TEST_COUNT"

    fancy_print -n -s bold $pass_color "${SUMMARY_INDENT}Passed: "
    echo "  $TEST_PASS_COUNT"

    fancy_print -n -s bold $fail_color "${SUMMARY_INDENT}Failed: "
    echo "  $TEST_FAIL_COUNT"


    if [ "$TEST_FAIL_COUNT" -gt 0 ]; then
        echo "" 
        fancy_print -s bold -s red "Failed Tests:"
        for t in "${FAILED_TESTS[@]}"; do
            echo "${SUMMARY_INDENT}${t//_/ }"
        done | sort
    fi

    echo ""

    if [ "$SUITE_STATUS" -gt 0 ]; then
        BAT_STATUS=1
        SUITE_FAIL_COUNT=$((SUITE_FAIL_COUNT + 1))
        FAILED_SUITES+=("$SUITE_NAME")
    else
        SUITE_PASS_COUNT=$((SUITE_PASS_COUNT + 1))
    fi
    return $SUITE_STATUS
}

bat_summary() {
    local pass_color="-c green"
    local fail_color=""

    print_divider
    fancy_print -s bold -c magenta "> Grand Summary:"
    echo ""

    if [ "$SUITE_FAIL_COUNT" -gt 0 ]; then
        fail_color="-c red"
        pass_color=""
    fi

    fancy_print -n -s bold "Total Suites: "
    echo "$SUITE_COUNT"

    fancy_print -n -s bold $pass_color "${SUMMARY_INDENT}Passed: "
    echo "  $SUITE_PASS_COUNT"

    fancy_print -n -s bold $fail_color "${SUMMARY_INDENT}Failed: "
    echo "  $SUITE_FAIL_COUNT"

    if [ "$SUITE_FAIL_COUNT" -gt 0 ]; then
        echo "" 
        fancy_print -s bold -s red "Failed Suites:"
        for t in "${FAILED_SUITES[@]}"; do
            echo "${SUMMARY_INDENT}${SUMMARY_INDENT}${t//_/ }"
        done | sort
    fi

    echo ""
}