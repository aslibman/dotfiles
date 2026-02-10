#!/usr/bin/env bash
# Test Neovim configuration for errors after home-manager build

set -e

echo "Testing Neovim configuration..."

# Test 1: Check for startup errors
echo "→ Checking for startup errors..."
if ! nvim --headless +qa 2>&1 | grep -q "Error"; then
    echo "  ✓ No startup errors"
else
    echo "  ✗ Startup errors detected:"
    nvim --headless +qa 2>&1
    exit 1
fi

# Test 2: Verify plugins are loaded
echo "→ Verifying plugins are loaded..."
nvim --headless +'lua print(vim.inspect(vim.api.nvim_list_runtime_paths()))' +qa 2>&1 | grep -q "nvim-treesitter" || {
    echo "  ✗ nvim-treesitter not found"
    exit 1
}
echo "  ✓ Plugins loaded"

# Test 3: Check if required Lua modules can be loaded
echo "→ Testing Lua modules..."
MODULES=("notify" "hardtime")
for module in "${MODULES[@]}"; do
    if nvim --headless +"lua require('$module')" +qa 2>&1 | grep -q "Error"; then
        echo "  ✗ Failed to load module: $module"
        nvim --headless +"lua require('$module')" +qa 2>&1
        exit 1
    fi
    echo "  ✓ Module '$module' loaded successfully"
done

# Test 4: Verify colorscheme is available
echo "→ Testing colorscheme..."
if nvim --headless +"colorscheme dracula" +qa 2>&1 | grep -q "Error"; then
    echo "  ✗ Dracula colorscheme failed to load"
    exit 1
fi
echo "  ✓ Dracula colorscheme available"

# Test 5: Run Neovim health checks
echo "→ Running health checks..."
nvim --headless +"checkhealth" +"write! /tmp/nvim-health.log" +qa 2>/dev/null

# Filter out expected warnings in Nix environments:
# - tree-sitter-cli, curl, tar: only needed for :TSInstall (we use Nix)
# - provider errors: we disabled providers
UNEXPECTED_ERRORS=$(grep "ERROR\|WARNING" /tmp/nvim-health.log | \
    grep -v "tree-sitter-cli not found" | \
    grep -v "tar not found" | \
    grep -v "curl not found" | \
    grep -v "vim.provider" || true)

if [ -n "$UNEXPECTED_ERRORS" ]; then
    echo "  ⚠ Unexpected health check errors found:"
    echo "$UNEXPECTED_ERRORS" | head -10
    echo "  (See /tmp/nvim-health.log for details)"
else
    echo "  ✓ Health checks passed"
fi

echo ""
echo "✅ All Neovim tests passed!"
exit 0
