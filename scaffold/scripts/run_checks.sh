#!/bin/bash

# Quality Checks Script
# Runs analysis, tests, and formatting checks
# Usage: ./run_checks.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

FAILED=0

# Check 1: Flutter Analyze
print_header "Step 1/4: Running Flutter Analyze"
if flutter analyze; then
    print_success "Analyze passed"
else
    print_error "Analyze failed"
    FAILED=1
fi

# Check 2: Flutter Test
print_header "Step 2/4: Running Flutter Tests"
if flutter test; then
    print_success "All tests passed"
else
    print_error "Tests failed"
    FAILED=1
fi

# Check 3: Dart Format Check
print_header "Step 3/4: Checking Code Formatting"
if dart format --output=none --set-exit-if-changed lib test; then
    print_success "Code is properly formatted"
else
    print_warning "Code needs formatting"
    print_info "Run 'dart format .' to format code"
    # Don't fail on formatting issues
fi

# Check 4: Riverpod Lint (if available)
print_header "Step 4/4: Running Riverpod Lint"
if command -v dart &> /dev/null; then
    if dart run custom_lint 2>/dev/null; then
        print_success "Riverpod lint passed"
    else
        print_info "Riverpod lint not available or has warnings"
    fi
else
    print_info "Dart command not found, skipping custom lint"
fi

# Final result
echo ""
if [ $FAILED -eq 0 ]; then
    print_header "ALL CHECKS PASSED ✅"
    exit 0
else
    print_header "SOME CHECKS FAILED ❌"
    exit 1
fi
