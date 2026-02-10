#!/bin/bash
# This script installs Nix if it's not already installed
# Runs once before chezmoi applies dotfiles

set -euo pipefail

echo "Checking for Nix installation..."

# Check if Nix is already installed
if command -v nix &> /dev/null; then
    echo "✓ Nix is already installed ($(nix --version))"
    exit 0
fi

echo "Installing Nix..."

# Use Determinate Systems Nix installer
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm

# Source Nix for the current session
if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

echo "✓ Nix installed successfully!"
