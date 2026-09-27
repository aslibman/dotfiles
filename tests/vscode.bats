load helpers

settings() { jq -r "$1" "$(vscode_user_dir)/settings.json"; }

@test "every configured extension is installed" {
    for ext in anthropic.claude-code astral-sh.ty asvetliakov.vscode-neovim charliermarsh.ruff \
        dracula-theme.theme-dracula jnoortheen.nix-ide ms-python.debugpy ms-python.python \
        ms-python.vscode-python-envs ms-toolsai.jupyter ms-toolsai.jupyter-keymap \
        ms-toolsai.jupyter-renderers ms-toolsai.vscode-jupyter-cell-tags \
        ms-vscode-remote.remote-containers rust-lang.rust-analyzer tamasfe.even-better-toml; do
        [ -f "$HOME/.vscode/extensions/$ext/package.json" ] || { echo "missing $ext"; return 1; }
    done
}

@test "tool paths in settings exist" {
    [ -x "$(settings '."nix.serverPath"')" ]
    [ -x "$(settings '."claudeCode.claudeProcessWrapper"')" ]
}

@test "key settings" {
    [ "$(settings '."workbench.colorTheme"')" = "Dracula Theme" ]
    [ "$(settings '."dev.containers.dockerPath"')" = "podman" ]
    [ "$(settings '."update.mode"')" = "none" ]
    [ "$(settings '."github.copilot.chat.enabled"')" = "false" ]
}

@test "no duplicate keybindings" {
    dupes=$(jq -r '.[] | [.key, .command, (.when // "")] | @tsv' "$(vscode_user_dir)/keybindings.json" | sort | uniq -d)
    [ -z "$dupes" ] || { echo "$dupes"; return 1; }
}

@test "vscode-server shares the extensions directory" {
    [ "$(cd "$HOME/.vscode-server/extensions" && pwd -P)" = "$(cd "$HOME/.vscode/extensions" && pwd -P)" ]
}
