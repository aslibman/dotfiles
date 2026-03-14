#!/usr/bin/env bash
# Test VSCode configuration for errors after home-manager build

set -e

echo "Testing VSCode configuration..."

# Test 1: Check that the code binary is available
echo "→ Checking for code binary..."
if command -v code &>/dev/null; then
    echo "  ✓ code binary found"
else
    echo "  ✗ code binary not found in PATH"
    exit 1
fi

# Test 2: Verify vim keybindings extension is installed
echo "→ Checking for Neovim extension..."
if code --list-extensions | grep -qi "asvetliakov.vscode-neovim"; then
    echo "  ✓ vscode-neovim installed"
else
    echo "  ✗ vscode-neovim not found"
    exit 1
fi

# Test 3: Verify settings and keybindings files exist
echo "→ Checking config files..."
if [ "$(uname)" = "Darwin" ]; then
    CONFIG_DIR="$HOME/Library/Application Support/Code/User"
else
    CONFIG_DIR="$HOME/.config/Code/User"
fi

for file in settings.json keybindings.json; do
    if [ -f "$CONFIG_DIR/$file" ]; then
        echo "  ✓ $file present"
    else
        echo "  ✗ $file not found"
        exit 1
    fi
done

echo ""
echo "✅ All VSCode tests passed!"
exit 0
