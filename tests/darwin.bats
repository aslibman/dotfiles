load helpers

setup() {
    skip_unless_darwin
}

@test "karabiner maps caps lock to control and loads every windows rule" {
    config="$HOME/.config/karabiner/karabiner.json"
    rules="$HOME/.config/karabiner/assets/complex_modifications/windows_shortcuts.json"
    [ "$(jq -r '.profiles[0].simple_modifications[0].from.key_code' "$config")" = "caps_lock" ]
    [ "$(jq -r '.profiles[0].simple_modifications[0].to[0].key_code' "$config")" = "left_control" ]
    [ "$(jq '.profiles[0].complex_modifications.rules | length' "$config")" -eq "$(jq '.rules | length' "$rules")" ]
}

@test "iTerm2 has the Dracula colour preset" {
    grep -q "Ansi 0 Color" "$HOME/Library/Application Support/iTerm2/ColorPresets/Dracula.itermcolors"
}
