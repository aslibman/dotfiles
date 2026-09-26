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
