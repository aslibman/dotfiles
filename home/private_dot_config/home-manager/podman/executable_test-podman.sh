#!/usr/bin/env bash
# Test that podman is available and configured correctly

set -e

echo "Testing Podman..."

echo "→ Checking for podman binary..."
if ! command -v podman &>/dev/null; then
    echo "  ✗ podman not found in PATH"
    exit 1
fi
echo "  ✓ podman found at $(command -v podman)"

if [[ "$(uname)" == "Darwin" ]]; then
    echo "→ Checking for at least one podman machine..."
    if podman machine list --noheading 2>/dev/null | grep -q .; then
        echo "  ✓ at least one machine defined"
    else
        echo "  ✗ no podman machines defined"
        exit 1
    fi
fi

echo ""
echo "All Podman tests passed!"
exit 0
