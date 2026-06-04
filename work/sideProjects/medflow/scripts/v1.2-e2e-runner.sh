#!/bin/bash
# v1.2 Phase 4: E2E Test Runner for Critical Use Cases
set -euo pipefail
SUITE="${1:-all}"
echo "MedNext v1.2 E2E Test Suite: $SUITE"
cd "$(dirname "$0")/../frontend"
case "$SUITE" in
  surgery) npx playwright test --grep "CU-1" --reporter=list ;;
  laser)   npx playwright test --grep "CU-2" --reporter=list ;;
  xray)    npx playwright test --grep "CU-3" --reporter=list ;;
  all)     npx playwright test --grep "CU-" --reporter=list ;;
esac
echo "E2E suite complete"
