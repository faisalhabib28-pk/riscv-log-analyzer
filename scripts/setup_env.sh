#!/bin/bash
set -euo pipefail

echo "=== MEDS Environment Setup ==="

TOOLS="bash grep awk sed sort uniq bc"
ALL_OK=1

for tool in $TOOLS; do
    if command -v "$tool" &>/dev/null; then
        echo "OK: $tool installed"
    else
        echo "MISSING: $tool"
        ALL_OK=0
    fi
done

mkdir -p output
echo "OK: output/ directory ready"

if [ $ALL_OK -eq 1 ]; then
    echo ""
    echo "Setup complete!"
else
    echo "Kuch tools missing hain!"
    echo "Run: sudo apt install bc -y"
    exit 1
fi
