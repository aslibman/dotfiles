# Shared helpers, loaded with `load helpers`.

bats_require_minimum_version 1.5.0

# Where the home profile and generated dotfiles live. The Nix check sets both;
# after a real switch they come from the active home-manager generation.
if [[ -z ${HM_PROFILE:-} ]]; then
    if [[ -e $HOME/.nix-profile ]]; then
        HM_PROFILE=$HOME/.nix-profile
    else
        HM_PROFILE=/etc/profiles/per-user/$USER # NixOS with useUserPackages
    fi
fi
: "${HM_HOME_FILES:=$(readlink -f "$HOME/.local/state/home-manager/gcroots/current-home")/home-files}"

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

# Family, full and PostScript names of every font in the directories home-manager's
# fontconfig file exposes (what apps actually search).
installed_font_names() {
    local dirs
    mapfile -t dirs < <(sed -n 's:.*<dir>\(.*\)</dir>.*:\1:p' "$HOME/.config/fontconfig/conf.d/10-hm-fonts.conf" |
        while read -r d; do [[ -d $d ]] && echo "$d"; done)
    find -L "${dirs[@]}" -type f \( -name '*.ttf' -o -name '*.otf' \) \
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
