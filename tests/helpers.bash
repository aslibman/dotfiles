# Shared helpers, loaded with `load helpers`.

bats_require_minimum_version 1.5.0

is_darwin() { [[ $(uname) == Darwin ]]; }

skip_unless_darwin() { is_darwin || skip "macOS only"; }
skip_unless_linux() { is_darwin && skip "Linux only"; true; }

# Run fish interactively so interactiveShellInit (bindings, abbrs, ...) is loaded.
fish_i() { fish -i -c "$1"; }

vscode_user_dir() {
    if is_darwin; then
        echo "$HOME/Library/Application Support/Code/User"
    else
        echo "$HOME/.config/Code/User"
    fi
}

# Family, full and PostScript names of every font in the home profile.
installed_font_names() {
    find -L "$HOME/.nix-profile/share/fonts" -type f \( -name '*.ttf' -o -name '*.otf' \) \
        -exec fc-scan --format '%{family}\n%{fullname}\n%{postscriptname}\n' {} \; 2>/dev/null |
        tr ',' '\n' | sort -u
}

assert_font_installed() {
    if ! installed_font_names | grep -qxF "$1"; then
        echo "font '$1' is not installed; available families:"
        installed_font_names | grep -i nerd | head -20
        return 1
    fi
}
