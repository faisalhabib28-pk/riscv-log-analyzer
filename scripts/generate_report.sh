#!/bin/bash
set -euo pipefail

# Report generator script
# Runs analyzer on all log files and saves summary

echo "=== Generating Summary Report ==="

# Create output directory
mkdir -p output
REPORT="output/summary_report.txt"

# Write report header
{
echo "MEDS RISC-V Log Analyzer - Summary Report"
echo "Generated: $(date)"
echo "==========================================="
echo ""

# Analyze each log file
for log in test_data/*.log; do
    echo "--- $log ---"
    bash scripts/analyze.sh "$log" || true
    echo ""
done
} > "$REPORT"

echo "Report saved: $REPORT"
cat "$REPORT"
