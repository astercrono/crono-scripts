#!/usr/bin/env bash

sample_foo_test() {
    local testdata=(1 2)
    for n in "${testdata[@]}"; do
        case_set "Check $n"
        case_pass
    done
}

run_test "sample_foo_test" "The Foo Test"