#!/bin/bash
set -euo pipefail

# MEDS RISC-V Log Analyzer
# Author: Faisal Habib
# Date: 2026

# Default values
FORMAT="text"
OUTPUT=""
VERBOSE=0
LOG_FILE=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Print usage information
show_help() {
    echo "Usage: $0 <log_file> [options]"
    echo ""
    echo "Options:"
    echo "  --format [text|csv]  Output format (default: text)"
    echo "  --output <path>      Output file path"
    echo "  --verbose            Enable verbose mode"
    echo "  --help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 test_data/sample_sim.log"
    echo "  $0 test_data/sample_sim.log --format csv"
    exit 0
}

# Print log message if verbose mode is enabled
log_msg() {
    if [ $VERBOSE -eq 1 ]; then
        echo "[$(date +%H:%M:%S)] $*"
    fi
}

# Analyze the log file and extract test results
analyze_log() {
    local file="$1"

    log_msg "Analyzing: $file"

    # Count test results
    local total_pass total_fail total_skip total_tests
    total_pass=$(grep -c "TEST PASS:" "$file" || true)
    total_fail=$(grep -c "TEST FAIL:" "$file" || true)
    total_skip=$(grep -c "TEST SKIP:" "$file" || true)
    total_tests=$((total_pass + total_fail + total_skip))

    # Calculate pass rate percentage
    local pass_rate=0
    if [ $total_tests -gt 0 ]; then
        pass_rate=$(echo "scale=1; $total_pass * 100 / $total_tests" | bc)
    fi

    # Extract names of failed tests
    local failed_tests
    failed_tests=$(grep "TEST FAIL:" "$file" | \
        sed 's/.*TEST FAIL: \([^ ]*\).*/\1/' || true)

    # Print output in selected format
    if [ "$FORMAT" = "csv" ]; then
        echo "file,total,passed,failed,skipped,pass_rate"
        echo "$file,$total_tests,$total_pass,$total_fail,$total_skip,${pass_rate}%"
    else
        print_report "$file" "$total_tests" "$total_pass" \
                     "$total_fail" "$total_skip" "$pass_rate" "$failed_tests"
    fi

    # Return exit code based on failures
    [ $total_fail -eq 0 ] && return 0 || return 1
}

# Print formatted text report
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

    # List failed tests or show success message
    if [ -z "$failed_list" ]; then
        report="$report
  No failures found!"
    else
        local i=1
        while IFS= read -r test; do
            report="$report
  $i. $test"
            i=$((i+1))
        done <<< "$failed_list"
    fi

    # Set verdict based on failure count
    if [ "$fail" -eq 0 ]; then
        report="$report

--- Verdict: PASS ---"
    else
        report="$report

--- Verdict: FAIL ---"
    fi

    # Write to file or print to stdout
    if [ -n "$OUTPUT" ]; then
        mkdir -p "$(dirname "$OUTPUT")"
        echo "$report" > "$OUTPUT"
        echo "Report saved: $OUTPUT"
    else
        echo "$report"
    fi
}

# Check if arguments are provided
if [ $# -eq 0 ]; then
    show_help
fi

# First argument is the log file
LOG_FILE="$1"
shift

# Parse remaining options
while [ $# -gt 0 ]; do
    case "$1" in
        --help)    show_help ;;
        --verbose) VERBOSE=1; shift ;;
        --format)  FORMAT="$2"; shift 2 ;;
        --output)  OUTPUT="$2"; shift 2 ;;
        *)         echo "Error: Unknown option: $1"; exit 1 ;;
    esac
done

# Verify log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: File not found: $LOG_FILE"
    exit 1
fi

# Install bc if not available
command -v bc &>/dev/null || sudo apt install bc -y

# Run the analyzer
if analyze_log "$LOG_FILE"; then
    echo "Exit code: 0"
    exit 0
else
    echo "Exit code: 1"
    exit 1
fi
