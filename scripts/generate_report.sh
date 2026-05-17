#!/bin/bash
set -euo pipefail

echo "=== Generating Summary Report ==="

mkdir -p output
REPORT="output/summary_report.txt"

{
echo "MEDS RISC-V Log Analyzer - Summary Report"
echo "Generated: $(date)"
echo "==========================================="
echo ""

for log in test_data/*.log; do
    echo "--- $log ---"
    bash scripts/analyze.sh "$log" || true
    echo ""
done
} > "$REPORT"

echo "Report saved: $REPORT"
cat "$REPORT"
