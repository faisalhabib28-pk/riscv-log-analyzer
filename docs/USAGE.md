# Detailed Usage Guide

## analyze.sh

### Arguments
- $1: Log file path (required)
- --format [text|csv]: Output format
- --output <path>: Output file
- --verbose: Verbose mode
- --help: Help

### Examples
```bash
bash scripts/analyze.sh test_data/sample_sim.log
bash scripts/analyze.sh test_data/sample_pass.log --format csv
bash scripts/analyze.sh test_data/sample_fail.log --output output/report.txt
```

## Log File Format

