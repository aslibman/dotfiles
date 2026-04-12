#!/bin/bash
# Bootstrap script to set up dotfiles on a new machine
# Usage:
#   sh -c "$(curl -fsLS https://raw.githubusercontent.com/aslibman/dotfiles/master/install.sh)"
#
# Requires Nix to be installed first: https://nixos.org/download/

set -euo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-aslibman/dotfiles}"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-master}"

echo "========================================="
echo "  Dotfiles Bootstrap Script"
echo "========================================="
echo ""
echo "This script will:"
echo "  1. Verify Nix is installed"
echo "  2. Run home-manager to install packages and apply configuration"
echo ""

if ! command -v nix &> /dev/null; then
    echo "ERROR: Nix is not installed or not in PATH"
    echo "Please install Nix first: https://nixos.org/download/"
    exit 1
fi

echo "Running dotfiles setup..."
echo ""

nix run "github:$DOTFILES_REPO/$DOTFILES_BRANCH" --impure

echo ""
echo "========================================="
echo "  Setup Complete!"
echo "========================================="
echo ""
echo "To update in the future, run: nix run github:$DOTFILES_REPO --impure"
echo ""
