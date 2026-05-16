.PHONY: all test report clean setup help

ANALYZER = scripts/analyze.sh
SETUP    = scripts/setup_env.sh
REPORT   = scripts/generate_report.sh

all: setup test report

setup:
	@bash $(SETUP)

test: setup
	@echo ""
	@echo "=== Running Tests ==="
	@for log in test_data/*.log; do \
		echo ""; \
		echo "Testing: $$log"; \
		bash $(ANALYZER) "$$log" || true; \
	done

report: setup
	@bash $(REPORT)

clean:
	@rm -rf output/
	@echo "Clean done!"

help:
	@echo ""
	@echo "MEDS RISC-V Log Analyzer"
	@echo "========================"
	@echo "  make all     - run all"
	@echo "  make setup   - check tools"
	@echo "  make test    - run tests"
	@echo "  make report  - make report"
	@echo "  make clean   -  delete output"
	@echo "  make help    - show help"
	@echo ""
