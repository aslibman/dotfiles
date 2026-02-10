#!/usr/bin/env bash
# Post-build validation script for home-manager
# Usage: home-manager switch && ./post-build-test.sh

set -euo pipefail

EXIT_CODE=0

echo "🔍 Running post-build validation..."
echo ""

# Test Neovim
if ~/.config/home-manager/test-neovim.sh; then
    echo ""
else
    echo "❌ Neovim tests failed"
    EXIT_CODE=1
fi

# Add more tests here for other programs
# Example:
# echo "Testing other programs..."
# if ! command -v fzf &> /dev/null; then
#     echo "❌ fzf not found"
#     EXIT_CODE=1
# fi

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ All post-build tests passed!"
    exit 0
else
    echo "❌ Some tests failed"
    exit 1
fi
