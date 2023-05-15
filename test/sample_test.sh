#!/usr/bin/env bash

run_good_test() {
    case_pass
}

run_bad_test() {
    case_pass
    case_pass
    case_fail
    case_pass
}

sample_foo_test() {
    local testdata=(1 2 3)
    for n in "${testdata[@]}"; do
        case_set "Check $n"

        if [ "$n" -eq "2" ]; then
            case_fail "Failed because BAD. Very bad!"
        else
            case_pass
        fi
    done
}

sample_bar_test() {
    local testdata=(1 2)
    for n in "${testdata[@]}"; do
        case_set "Check $n"
        case_pass
    done
}

run_test "sample_foo_test" "The Foo Test"
run_test "sample_bar_test" "The Bar Test"