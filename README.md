# RISC-V Log Analyzer

MEDS Module 1 Grand Assignment
Student: Faisal Habib
Summer Training 2026

## Description
A shell-based tool that analyzes RISC-V simulation log files
and generates summary reports.

## Installation
```bash
git clone git@github.com:faisalhabib28-pk/riscv-log-analyzer.git
cd riscv-log-analyzer
make setup
```

## Usage
```bash
# Basic usage
bash scripts/analyze.sh test_data/sample_sim.log

# CSV format output
bash scripts/analyze.sh test_data/sample_sim.log --format csv

# Enable verbose mode
bash scripts/analyze.sh test_data/sample_sim.log --verbose

# Save output to file
bash scripts/analyze.sh test_data/sample_sim.log --output output/report.txt
```

## Makefile Targets
```bash
make all     # Run setup, test, and report
make test    # Analyze all log files
make report  # Generate summary report
make clean   # Remove output files
make help    # Show help message
```

## Sample Output
