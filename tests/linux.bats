load helpers

setup() {
    skip_unless_linux
}

@test "ghostty config is valid" {
    run ghostty +validate-config --config-file="$HOME/.config/ghostty/config"
    [ "$status" -eq 0 ] || { echo "$output"; return 1; }
}

@test "ghostty has the Dracula theme" {
    ghostty +list-themes --plain | grep -q '^Dracula'
}

@test "Nix apps are visible to the desktop" {
    grep -q "$HOME/.nix-profile/share" "$HOME/.config/environment.d/10-home-manager.conf"
    [ -f "$HOME/.nix-profile/share/applications/com.mitchellh.ghostty.desktop" ]
    [ -f "$HOME/.nix-profile/share/applications/code.desktop" ]
}

@test "ghostty is the default terminal" {
    grep -q '^x-scheme-handler/terminal=com.mitchellh.ghostty.desktop' "$HOME/.config/mimeapps.list"
}
