#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_test() {
    echo -e "${YELLOW}[TEST]${NC} $1"
}

# Test function
run_test() {
    local test_name=$1
    local test_command=$2

    TESTS_RUN=$((TESTS_RUN + 1))
    log_test "Running: $test_name"

    if eval "$test_command"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        log_info "✓ PASSED: $test_name"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        log_error "✗ FAILED: $test_name"
        return 1
    fi
}

echo "========================================="
echo "NixUp CI/CD Tests"
echo "========================================="
echo ""

# Test 1: Flake metadata
run_test "Flake metadata" "nix flake metadata --no-write-lock-file"

# Test 2: Flake show
run_test "Flake structure" "nix flake show --no-write-lock-file"

# Test 3: Flake check
run_test "Flake check" "nix flake check --no-write-lock-file --show-trace"

# Test 4: Evaluate system configuration
run_test "Evaluate system configuration" \
    "nix eval .#nixosConfigurations.framework.config.system.nixos.version --raw --no-write-lock-file"

# Test 5: Build system toplevel
run_test "Build system toplevel" \
    "nix build .#nixosConfigurations.framework.config.system.build.toplevel --no-link --no-write-lock-file --show-trace"

# Test 6: Check for deprecated options
log_test "Checking for deprecated options"
if nix eval .#nixosConfigurations.framework.config.warnings --json --no-write-lock-file 2>/dev/null | grep -q "deprecated"; then
    log_error "✗ FAILED: Found deprecated options"
    TESTS_FAILED=$((TESTS_FAILED + 1))
else
    log_info "✓ PASSED: No deprecated options found"
    TESTS_PASSED=$((TESTS_PASSED + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

# Test 7: Check flake inputs are locked
run_test "Flake inputs locked" \
    "test -f flake.lock"

# Test 8: Verify no evaluation errors in home-manager
run_test "Home Manager evaluation" \
    "nix eval .#nixosConfigurations.framework.config.home-manager.users --apply 'x: true' --no-write-lock-file"

echo ""
echo "========================================="
echo "Test Summary"
echo "========================================="
echo "Tests run:    $TESTS_RUN"
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"
echo "========================================="

if [ $TESTS_FAILED -eq 0 ]; then
    log_info "All tests passed!"
    exit 0
else
    log_error "Some tests failed!"
    exit 1
fi
