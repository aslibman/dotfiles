# shellcheck disable=SC2016 # $VARS in single quotes are expanded by fish, not bash
load helpers

@test "interactive startup prints nothing to stderr" {
    run --separate-stderr fish_i exit
    [ "$status" -eq 0 ]
    [ -z "$stderr" ] || { echo "$stderr"; return 1; }
}

@test "interactive startup is fast" {
    start=${EPOCHREALTIME/./}
    fish_i exit 2>/dev/null
    elapsed_ms=$(((${EPOCHREALTIME/./} - start) / 1000))
    echo "startup took ${elapsed_ms}ms"
    [ "$elapsed_ms" -lt 1500 ]
}

@test "vimdiff opens neovim in diff mode" {
    run fish_i 'functions vimdiff'
    [[ "$output" == *"nvim -d \$argv"* ]]
}

@test "vi key bindings are enabled" {
    run fish_i 'echo $fish_key_bindings'
    [[ "$output" == *fish_vi_key_bindings* ]] # vi mode emits cursor-shape escapes
}

@test "the Nix profile comes first in PATH" {
    run fish -c 'echo $PATH[1]'
    [ "$output" = "$HOME/.nix-profile/bin" ]
}

@test "session variables reach fish" {
    run fish -c 'echo $EDITOR; echo $COLORTERM; echo $LESS'
    [ "${lines[0]}" = "nvim" ]
    [ "${lines[1]}" = "truecolor" ]
    [ "${lines[2]}" = "-R" ]
}

@test "aliases resolve to the replacement tools" {
    for pair in find:fd ps:procs docker:podman "gamend:git commit --amend --no-edit"; do
        run fish_i "functions ${pair%%:*}"
        [[ "$output" == *"${pair#*:} \$argv"* ]] || { echo "${pair%%:*}: $output"; return 1; }
    done
}

@test "--help and -h abbreviations pipe through bat anywhere on the line" {
    run fish_i 'abbr --show'
    [[ "$output" == *"--position anywhere -- --help '--help | bat -plhelp'"* ]]
    [[ "$output" == *"--position anywhere -- -h '-h | bat -plhelp'"* ]]
}

@test "history and search widgets are bound in default and insert modes" {
    for mode in default insert; do
        run fish_i "bind -M $mode"
        [[ "$output" == *"ctrl-r fzf_atuin_history_widget"* ]] || { echo "$mode: ctrl-r"; return 1; }
        [[ "$output" == *"ctrl-e _atuin_search"* ]] || { echo "$mode: ctrl-e"; return 1; }
        [[ "$output" == *"ctrl-f ff-widget"* ]] || { echo "$mode: ctrl-f"; return 1; }
    done
}

@test "atuin does not take over the up arrow" {
    run fish_i 'bind -M insert up; bind up'
    [[ "$output" != *atuin* ]]
}

# print_prompt_separator <status> with CMD_DURATION and COLUMNS set
separator() {
    fish -c "set -g COLUMNS $1; set -g CMD_DURATION $2; print_prompt_separator $3" |
        sed 's/\x1b\[[0-9;]*m//g' | tr -d '\n'
}

@test "prompt separator spans the terminal width" {
    for cols in 40 41 80; do
        line=$(separator "$cols" 0 0)
        [ "$(fish -c "string length -- '$line'")" -eq "$cols" ] || { echo "cols=$cols: '$line'"; return 1; }
    done
}

@test "prompt separator shows runtimes of 2s or more" {
    [[ "$(separator 80 1999 0)" != *" | "* ]]
    [[ "$(separator 80 3500 0)" == *"| 3s"* ]]
    [[ "$(separator 80 65000 0)" == *"| 1m 5s"* ]]
    [[ "$(separator 80 3600000 0)" == *"| 1h 0m 0s"* ]]
}

@test "prompt separator shows non-zero exit codes only" {
    [[ "$(separator 80 0 0)" != *Exit* ]]
    [[ "$(separator 80 0 2)" == *"✖ Exit 2"* ]]
}

@test "atuin widget passes a valid format to fzf and atuin" {
    # Stub fzf to record its arguments instead of prompting
    run fish_i 'function fzf; string join \n -- $argv > '"$BATS_TEST_TMPDIR"'/fzf-args; end
                fzf_atuin_history_widget 2>/dev/null; true'
    args=$(cat "$BATS_TEST_TMPDIR/fzf-args")
    [[ "$args" == *"--format '{relativetime}	{command}'"* ]] || { echo "$args"; return 1; }
    [[ "$args" != *"{{"* ]]
}

@test "atuin search works on an empty history" {
    ATUIN_SESSION=bats run atuin search --format '{command}' anything
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ] # 1 = no matches
    [[ "$output" != *rror* ]]
}
