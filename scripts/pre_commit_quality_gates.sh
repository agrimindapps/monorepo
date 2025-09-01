#!/bin/bash
# Pre-commit Quality Gates Hook
# Prevents commits that violate quality standards

set -e

echo "🚦 Running Quality Gates Pre-commit Hook..."

# Check if Dart is available
if ! command -v dart &> /dev/null; then
    echo "❌ Dart not found. Please install Flutter/Dart SDK."
    exit 1
fi

# Get staged files
staged_files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.dart$' || true)

if [ -z "$staged_files" ]; then
    echo "✅ No Dart files staged for commit."
    exit 0
fi

# Run quality gates on staged files
echo "📁 Analyzing staged Dart files..."

# Change to monorepo root
cd "$(git rev-parse --show-toplevel)"

# Run quality gates
dart scripts/quality_gates.dart --ci --check=all --report=console

exit_code=$?

if [ $exit_code -eq 0 ]; then
    echo "✅ All quality gates passed!"
    exit 0
elif [ $exit_code -eq 1 ]; then
    echo ""
    echo "❌ Quality gates failed with critical issues!"
    echo ""
    echo "Critical issues must be fixed before committing:"
    echo "• Files exceeding 500 lines"
    echo "• Architecture violations"
    echo "• Critical security issues"
    echo "• Memory leaks"
    echo ""
    echo "To bypass (NOT RECOMMENDED): git commit --no-verify"
    echo "To fix: Review the issues above and refactor your code"
    echo ""
    exit 1
else
    echo "❌ Quality gates script failed to run properly."
    exit 2
fi