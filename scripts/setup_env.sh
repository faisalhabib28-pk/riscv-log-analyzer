#!/bin/bash
set -euo pipefail

# Environment setup script
# Checks all required tools are installed

echo "=== MEDS Environment Setup ==="

# List of required tools
TOOLS="bash grep awk sed sort uniq bc"
ALL_OK=1

# Check each tool
for tool in $TOOLS; do
    if command -v "$tool" &>/dev/null; then
        echo "OK: $tool is installed"
    else
        echo "MISSING: $tool not found"
        ALL_OK=0
    fi
done

# Create output directory if not exists
mkdir -p output
echo "OK: output/ directory is ready"

# Final status
if [ $ALL_OK -eq 1 ]; then
    echo ""
    echo "Setup complete! All tools are ready."
else
    echo ""
    echo "Some tools are missing!"
    echo "Run: sudo apt install bc -y"
    exit 1
fi
