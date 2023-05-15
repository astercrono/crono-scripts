#!/usr/bin/env bash

source "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/configure.sh"

BAT_STATUS=0

SUITE_STATUS=0
SUITE_PASS_COUNT=0
SUITE_FAIL_COUNT=0
SUITE_TEST_COUNT=0
SUITE_CASE_PASS_COUNT=0
SUITE_CASE_FAIL_COUNT=0

FAILED_TESTS=()

TEST_STATUS=0
CASE_PASS_COUNT=0
CASE_FAIL_COUNT=0

CASE_WIDTH=30

start_suite() {
    suite_name="$1"
    echo ""
    fancy_print -n -s bold -c yellow "Testing:"
    fancy_print -s bold " $suite_name"
    echo "__________________________________________________"
    echo ""
}

run_test() {
    SUITE_TEST_COUNT=$((SUITE_TEST_COUNT + 1))

    local test_func="$1"
    local name="$2"

    fancy_print -n -s bold -c cyan "Running: "
    fancy_print -s bold "$name"

    "$test_func"

    if [ "$TEST_STATUS" -gt 0 ]; then
        SUITE_FAIL_COUNT=$((TEST_FAIL_COUNT + 1))
        FAILED_TESTS+=("${name// /_}")
    else
        SUITE_PASS_COUNT=$((TEST_PASS_COUNT + 1))
    fi

    echo ""
}

case_pass() {
    local desc="$1"

    fancy_print -n -s bold -c green "    [PASS] "
    fancy_print -s bold "$desc"

    CASE_PASS_COUNT=$((CASE_PASS_COUNT + 1))
    SUITE_CASE_PASS_COUNT=$((SUITE_CASE_PASS_COUNT + 1))
    return 0
}

case_fail() {
    local pack_type="$1"
    local extra_notes="$2"

    fancy_print -n -s bold -c red "    [FAIL] "
    fancy_print -n -s bold "$1"

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
    CASE_PASS_COUNT=$((CASE_FAIL_COUNT + 1))
    SUITE_CASE_FAIL_COUNT=$((SUITE_CASE_FAIL_COUNT + 1))

    return 1
}

end_suite() {
    fancy_print -s bold -c magenta "Summary"

    # fancy_print -s bold "    Tests:       $SUITE_TEST_COUNT"

    local pass_color=""
    local fail_color=""

    if [ "$SUITE_FAIL_COUNT" -gt 0 ]; then
        fail_color="-c red"
    else
        pass_color="-c green"
    fi

    fancy_print -n -s bold $pass_color "    Total Tests: "
    echo " $SUITE_TEST_COUNT"

    fancy_print -n -s bold $pass_color "    Passed: "
    echo " $SUITE_PASS_COUNT"

    fancy_print -n -s bold $fail_color "    Failed: "
    echo " $SUITE_FAIL_COUNT"


    local total_cases=$((SUITE_CASE_PASS_COUNT + SUITE_CASE_FAIL_COUNT))
    # fancy_print -s bold "    Cases:       $total_cases"

    echo ""

    fancy_print -n -s bold $pass_color "    Total Cases: "
    echo " $total_cases"

    fancy_print -n -s bold $pass_color "    Passed: "
    echo " $SUITE_CASE_PASS_COUNT"

    fancy_print -n -s bold $fail_color "    Failed: "
    echo " $SUITE_CASE_FAIL_COUNT"

    if [[ "${SUITE_CASE_FAIL_COUNT}" -gt 0 ]]; then
        echo "" 
        fancy_print -s bold -s red "    Failed Tests:"
        for t in "${FAILED_TESTS[@]}"; do
            echo "        ${t//_/ }"
        done | sort
    fi

    echo ""
    fancy_print -n -s bold -c blue "Status:"
    if [ "$SUITE_STATUS" -gt 0 ]; then
        fancy_print -s bold -c red " Failed"
    else
        fancy_print -s bold -c green " Passed"
    fi

    echo ""

    return $SUITE_STATUS
}