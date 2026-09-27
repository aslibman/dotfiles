load helpers

@test "generated JSON files parse" {
    files=("$(vscode_user_dir)/settings.json" "$(vscode_user_dir)/keybindings.json")
    if is_darwin; then
        files+=(
            "$HOME/.config/karabiner/karabiner.json"
            "$HOME/.config/karabiner/assets/complex_modifications/windows_shortcuts.json"
            "$HOME/Library/Application Support/iTerm2/DynamicProfiles/profiles.json"
        )
    fi
    for f in "${files[@]}"; do
        jq empty "$f" || { echo "invalid JSON: $f"; return 1; }
    done
}

@test "generated TOML and YAML files parse" {
    for f in "$HOME/.config/starship.toml" "$HOME/.config/atuin/config.toml"; do
        yq -p toml '.' "$f" >/dev/null || { echo "invalid TOML: $f"; return 1; }
    done
    yq '.' "$HOME/.config/eza/theme.yml" >/dev/null
}

@test "no generated dotfile is a broken symlink" {
    broken=$(find "$HOME" -path "$HOME/.nix-profile" -prune -o -xtype l -print)
    [ -z "$broken" ] || { echo "broken symlinks:"; echo "$broken"; return 1; }
}

@test "every installed CLI tool runs" {
    for cmd in \
        "atuin --version" "bat --version" "batgrep --version" "claude --version" \
        "delta --version" "direnv version" "dot -V" "dust --version" "eza --version" \
        "fd --version" "fish --version" "fzf --version" "gh --version" "git --version" \
        "git lfs version" "keychain --version" "nvim --version" "podman --version" \
        "procs --version" "rg --version" "rustup --version" \
        "shellcheck --version" "starship --version" "tldr --version" "tmux -V" \
        "unzip -v" "uv --version"; do
        $cmd >/dev/null 2>&1 || { echo "failed: $cmd"; $cmd; return 1; }
    done
    reef 2>&1 | grep -q '^usage: reef' # reef has no --version
}

@test "every font the config names is installed" {
    assert_font_installed "$(jq -r '."editor.fontFamily"' "$(vscode_user_dir)/settings.json" | cut -d, -f1 | tr -d "'")"
    if is_darwin; then
        # iTerm stores "<PostScript name> <size>"
        for font in $(jq -r '.Profiles[] | ."Normal Font" // empty' \
            "$HOME/Library/Application Support/iTerm2/DynamicProfiles/profiles.json" | awk '{print $1}'); do
            assert_font_installed "$font"
        done
    else
        assert_font_installed "$(sed -n 's/^font-family = //p' "$HOME/.config/ghostty/config")"
    fi
}

@test "the fontconfig module exposes profile fonts" {
    grep -Rq "nix-profile/share/fonts\|home-manager-path/share/fonts" "$HOME/.config/fontconfig/conf.d/"
}
