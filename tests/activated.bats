# Checks that only make sense after a real `home-manager switch`. Run in CI:
#   bats --filter-tags activated tests
load helpers

# bats file_tags=activated

@test "VS Code settings are editable copies, not store symlinks" {
    for f in settings.json keybindings.json; do
        path="$(vscode_user_dir)/$f"
        [ -f "$path" ] && [ ! -L "$path" ] && [ -w "$path" ] || { ls -l "$path"; return 1; }
    done
}

@test "GUI apps are installed into ~/Applications" {
    skip_unless_darwin
    for app in iTerm2 "Visual Studio Code" Karabiner-Elements; do
        [ -d "$HOME/Applications/Home Manager Apps/$app.app" ] || { echo "missing $app"; return 1; }
    done
}

@test "iTerm2 auto-update checks are disabled" {
    skip_unless_darwin
    [ "$(defaults read com.googlecode.iterm2 SUEnableAutomaticChecks)" = "0" ]
}

@test "podman machine shares /Users and /var/folders" {
    skip_unless_darwin
    mounts=$(podman machine inspect dev-machine | jq -r '.[0].Mounts[].Source')
    grep -qx /Users <<<"$mounts"
    grep -qx /var/folders <<<"$mounts"
}

@test "podman works" {
    skip_unless_linux
    podman info --format '{{.Host.Arch}}'
}
