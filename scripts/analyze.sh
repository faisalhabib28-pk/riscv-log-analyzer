#!/bin/bash
set -euo pipefail

# MEDS RISC-V Log Analyzer
# Author: Faisal Habib

# Default values
FORMAT="text"
OUTPUT=""
VERBOSE=0
LOG_FILE=""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Help function
show_help() {
    echo "Usage: $0 <log_file> [options]"
    echo ""
    echo "Options:"
    echo "  --format [text|csv]  Output format (default: text)"
    echo "  --output <path>      Output file path"
    echo "  --verbose            Verbose mode"
    echo "  --help               Help dekho"
    echo ""
    echo "Examples:"
    echo "  $0 test_data/sample_sim.log"
    echo "  $0 test_data/sample_sim.log --format csv"
    exit 0
}

# Log function
log_msg() {
    if [ $VERBOSE -eq 1 ]; then
        echo "[$(date +%H:%M:%S)] $*"
    fi
}

# Analyze function
analyze_log() {
    local file="$1"

    log_msg "Analyzing: $file"

    # Counts nikalo
    local total_pass total_fail total_skip total_tests
    total_pass=$(grep -c "TEST PASS:" "$file" || true)
    total_fail=$(grep -c "TEST FAIL:" "$file" || true)
    total_skip=$(grep -c "TEST SKIP:" "$file" || true)
    total_tests=$((total_pass + total_fail + total_skip))

    # Pass rate
    local pass_rate=0
    if [ $total_tests -gt 0 ]; then
        pass_rate=$(echo "scale=1; $total_pass * 100 / $total_tests" | bc)
    fi

    # Failed tests
    local failed_tests
    failed_tests=$(grep "TEST FAIL:" "$file" | \
        sed 's/.*TEST FAIL: \([^ ]*\).*/\1/' || true)

    # Output
    if [ "$FORMAT" = "csv" ]; then
        echo "file,total,passed,failed,skipped,pass_rate"
        echo "$file,$total_tests,$total_pass,$total_fail,$total_skip,${pass_rate}%"
    else
        print_report "$file" "$total_tests" "$total_pass" \
                     "$total_fail" "$total_skip" "$pass_rate" "$failed_tests"
    fi

    [ $total_fail -eq 0 ] && return 0 || return 1
}

# Print report function
print_report() {
    local file="$1" total="$2" pass="$3"
    local fail="$4" skip="$5" rate="$6" failed_list="$7"

    local report
    report="
=== RISC-V Simulation Log Analysis ===
Log file:      $file
Date:          $(date '+%Y-%m-%d %H:%M:%S')

--- Results ---
Total tests:   $total
Passed:        $pass ($rate%)
Failed:        $fail
Skipped:       $skip

--- Failed Tests ---"

    if [ -z "$failed_list" ]; then
        report="$report
  Koi failure nahi!"
    else
        local i=1
        while IFS= read -r test; do
            report="$report
  $i. $test"
            i=$((i+1))
        done <<< "$failed_list"
    fi

    if [ "$fail" -eq 0 ]; then
        report="$report

--- Verdict: PASS ---"
    else
        report="$report

--- Verdict: FAIL ---"
    fi

    if [ -n "$OUTPUT" ]; then
        mkdir -p "$(dirname "$OUTPUT")"
        echo "$report" > "$OUTPUT"
        echo "Report saved: $OUTPUT"
    else
        echo "$report"
    fi
}

# Arguments check
if [ $# -eq 0 ]; then
    show_help
fi

LOG_FILE="$1"
shift

# Options parse karo
while [ $# -gt 0 ]; do
    case "$1" in
        --help)    show_help ;;
        --verbose) VERBOSE=1; shift ;;
        --format)  FORMAT="$2"; shift 2 ;;
        --output)  OUTPUT="$2"; shift 2 ;;
        *)         echo "Error: Unknown option: $1"; exit 1 ;;
    esac
done

# File check
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: File nahi mili: $LOG_FILE"
    exit 1
fi

# bc install check
command -v bc &>/dev/null || sudo apt install bc -y

# Run!
if analyze_log "$LOG_FILE"; then
    echo "Exit code: 0"
    exit 0
else
    echo "Exit code: 1"
    exit 1
fi
