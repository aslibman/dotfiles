#!/bin/bash
# Bootstrap script to set up dotfiles on a new machine
# Usage:
#   sh -c "$(curl -fsLS https://raw.githubusercontent.com/alibman/dotfiles/master/install.sh)"

set -euo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-aslibman/dotfiles}"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-master}"

echo "========================================="
echo "  Dotfiles Bootstrap Script"
echo "========================================="
echo ""
echo "This script will:"
echo "  1. Install chezmoi (if not installed)"
echo "  2. Clone your dotfiles repository"
echo "  3. Install Nix (via chezmoi script)"
echo "  4. Apply dotfiles"
echo "  5. Set up home-manager and install packages"
echo ""

if command -v chezmoi &> /dev/null; then
    echo "✓ chezmoi is already installed"
    CHEZMOI="chezmoi"
else
    echo "Installing chezmoi..."
    sh -c "$(curl -fsLS get.chezmoi.io)"
    echo "✓ chezmoi installed successfully"
fi

echo ""
echo "Initializing dotfiles from $DOTFILES_REPO..."
echo ""

$CHEZMOI init --apply "https://github.com/$DOTFILES_REPO.git"

echo ""
echo "========================================="
echo "  ✓ Setup Complete!"
echo "========================================="
echo ""
echo "To update in the future, run: chezmoi update"
echo ""
