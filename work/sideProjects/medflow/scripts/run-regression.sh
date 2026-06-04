#!/bin/bash
#
# MedNext Automated Regression Testing Script
#
# This script ensures a clean testing environment and runs a full suite 
# of E2E tests for regression analysis, then automatically opens the visual report.
#
# Usage:
#   ./scripts/run-regression.sh           # Run tests in headless mode and show report
#   ./scripts/run-regression.sh --ui      # Run tests in interactive UI mode
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
E2E_SCRIPT="$PROJECT_ROOT/scripts/e2e-test.sh"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Ensure the e2e-test script is executable
chmod +x "$E2E_SCRIPT"

log_info "Step 1: Preparing a clean E2E environment..."
"$E2E_SCRIPT" reset

log_info "Step 2: Waiting for environment to be fully ready..."
sleep 5 # Additional buffer time
"$E2E_SCRIPT" verify

cd "$FRONTEND_DIR"

if [ "$1" == "--ui" ]; then
    log_info "Step 3: Running Playwright in Interactive UI Mode..."
    log_success "========================================================"
    log_success "🖥️  PLAYWRIGHT UI SERVER STARTED ON WSL"
    log_success "👉 OPEN YOUR WINDOWS CHROME AND GO TO: http://localhost:33333"
    log_success "========================================================"
    
    # Free the port just in case it's still running from a previous background process
    fuser -k 33333/tcp 2>/dev/null || true
    
    BROWSER=none PLAYWRIGHT_BASE_URL=http://localhost:25200 API_URL=http://localhost:25080 npx playwright test -c playwright.config.e2e.ts --ui-host=0.0.0.0 --ui-port=33333 --ui
else
    log_info "Step 3: Running full regression test suite (headless)..."
    # Set +e so the script doesn't exit immediately if tests fail, 
    # allowing us to still open the report.
    set +e 
    PLAYWRIGHT_BASE_URL=http://localhost:25200 API_URL=http://localhost:25080 npx playwright test -c playwright.config.e2e.ts
    TEST_RESULT=$?
    set -e

    if [ $TEST_RESULT -eq 0 ]; then
        log_success "All regression tests passed successfully!"
    else
        log_error "Some regression tests failed. Check the report for details."
    fi

    if [ "$1" != "--no-report" ] && [ "$2" != "--no-report" ]; then
        log_info "Step 4: Opening Playwright HTML Report..."
        npx playwright show-report playwright-report-e2e
    else
        log_info "Step 4: Skipping Playwright HTML Report (--no-report flag provided)."
    fi
fi
