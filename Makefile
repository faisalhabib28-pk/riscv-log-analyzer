.PHONY: all test report clean setup help

# Script paths
ANALYZER = scripts/analyze.sh
SETUP    = scripts/setup_env.sh
REPORT   = scripts/generate_report.sh

# Run everything
all: setup test report

# Check required tools
setup:
	@bash $(SETUP)

# Run analyzer on all log files
test: setup
	@echo ""
	@echo "=== Running Tests ==="
	@for log in test_data/*.log; do \
		echo ""; \
		echo "Testing: $$log"; \
		bash $(ANALYZER) "$$log" || true; \
	done

# Generate summary report
report: setup
	@bash $(REPORT)

# Remove generated output files
clean:
	@rm -rf output/
	@echo "Clean complete!"

# Show available targets
help:
	@echo ""
	@echo "MEDS RISC-V Log Analyzer"
	@echo "========================"
	@echo "  make all     - Run setup, test, and report"
	@echo "  make setup   - Check required tools"
	@echo "  make test    - Analyze all log files"
	@echo "  make report  - Generate summary report"
	@echo "  make clean   - Remove output files"
	@echo "  make help    - Show this help message"
	@echo ""
