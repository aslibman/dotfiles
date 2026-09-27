# shellcheck disable=SC2016 # $VARS in single quotes are expanded by fish, not bash

@test "man pages are paged through bat" {
    run fish -c 'echo $MANPAGER'
    [[ "$output" == *bat* ]]
    # The pager command itself must work on man-formatted input
    printf 'NAME\n     ls - list directory contents\n' | sh -c "$(fish -c 'echo $MANPAGER')"
}

@test "less highlights files through bat" {
    run fish -c 'echo $LESSOPEN'
    [[ "$output" == "| bat "* ]]
}

@test "git pages diffs through delta and colors moved lines" {
    [ "$(git config core.pager)" = "delta" ]
    [ "$(git config diff.colorMoved)" = "default" ]
}

@test "neovim starts without errors" {
    run nvim --headless +'colorscheme dracula' +qa
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "tmux config loads" {
    run tmux -L bats -f "$HOME/.config/tmux/tmux.conf" start-server \; show -gw pane-base-index \; kill-server
    [ "$status" -eq 0 ]
    [ "$output" = "pane-base-index 1" ]
}

@test "bat has the Dracula theme and the help syntax" {
    bat --list-themes | grep -qx Dracula
    echo "Usage: foo [OPTIONS]" | bat -plhelp --color=never >/dev/null
}

@test "batgrep finds matches" {
    printf 'needle\n' > "$BATS_TEST_TMPDIR/haystack"
    run batgrep --no-color needle "$BATS_TEST_TMPDIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *needle* ]]
}

@test "eza theme colours are valid hex" {
    bad=$(yq '.. | select(has("foreground")) | .foreground' "$HOME/.config/eza/theme.yml" |
        grep -vE '^#[0-9A-Fa-f]{6}$' || true)
    [ -z "$bad" ] || { echo "invalid colours: $bad"; return 1; }
}

@test "eza shows git status" {
    git init -q "$BATS_TEST_TMPDIR/repo" && touch "$BATS_TEST_TMPDIR/repo/new"
    run eza -l --git --color=never "$BATS_TEST_TMPDIR/repo"
    [ "$status" -eq 0 ]
    [[ "$output" == *"-N"*" new"* ]] || { echo "$output"; return 1; }
}

@test "direnv loads .envrc and nix-direnv" {
    cd "$BATS_TEST_TMPDIR"
    echo 'export DIRENV_TEST=works' > .envrc
    direnv allow .
    [ "$(direnv exec . sh -c 'echo $DIRENV_TEST')" = "works" ]
    grep -Rq nix-direnv "$HOME/.config/direnv/"
    [ "$(yq -p toml '.global.hide_env_diff' "$HOME/.config/direnv/direnv.toml")" = "true" ]
}

@test "starship renders the prompt with venv and direnv modules" {
    cd "$BATS_TEST_TMPDIR"
    run starship prompt
    [ "$status" -eq 0 ]
    [[ "$output" == *"╭"* ]]
    # generic_venv_names: a venv called .venv shows the project directory's name
    mkdir -p .venv && VIRTUAL_ENV="$PWD/.venv" run starship prompt
    [[ "$output" == *"(🐍 $(basename "$PWD"))"* ]] || { echo "$output"; return 1; }
    touch .envrc && run starship module direnv
    [[ "$output" == *"(direnv)"* ]] || { echo "$output"; return 1; }
}

@test "starship prompt is fast" {
    cd "$BATS_TEST_TMPDIR"
    start=${EPOCHREALTIME/./}
    starship prompt >/dev/null
    elapsed_ms=$(((${EPOCHREALTIME/./} - start) / 1000))
    echo "prompt took ${elapsed_ms}ms"
    [ "$elapsed_ms" -lt 200 ]
}

@test "fzf uses the shared Dracula palette and bat previews" {
    run fish -c 'echo $FZF_DEFAULT_OPTS; echo $FZF_CTRL_T_OPTS'
    [[ "${lines[0]}" == *"bg:#282a36"* ]]
    [[ "${lines[1]}" == *"bat -n --color=always"* ]]
}

@test "atuin sync is off" {
    [ "$(yq -p toml '.auto_sync' "$HOME/.config/atuin/config.toml")" = "false" ]
}
