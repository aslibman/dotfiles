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
    # `podman machine inspect` doesn't report mounts; the machine config does
    mounts=$(jq -r '.Mounts[].Source' "$HOME"/.config/containers/podman/machine/*/dev-machine.json)
    grep -qx /Users <<<"$mounts"
    grep -qx /var/folders <<<"$mounts"
}

@test "dracula renders the tmux status bar" {
    # The plugin's scripts use #!/usr/bin/env, which the Linux build sandbox lacks
    tmux -L bats-activated -f "$HOME/.config/tmux/tmux.conf" new-session -d
    status=$(tmux -L bats-activated show -gv status-right)
    tmux -L bats-activated kill-server
    [[ "$status" == *dracula* ]] || { echo "$status"; return 1; }
}

@test "podman works" {
    skip_unless_linux
    # Ubuntu 24.04+ blocks unprivileged user namespaces for binaries without an
    # AppArmor profile, which includes Nix's podman (Ubuntu's own podman has one)
    if [[ $(cat /proc/sys/kernel/apparmor_restrict_unprivileged_userns 2>/dev/null) == 1 ]]; then
        skip "AppArmor restricts unprivileged user namespaces; rootless Nix podman needs a profile"
    fi
    podman info --format '{{.Host.Arch}}'
}
