load helpers

setup() {
    tmux -L bats -f "$HOME/.config/tmux/tmux.conf" new-session -d -x 120 -y 40
}

teardown() {
    tmux -L bats kill-server 2>/dev/null || true
}

t() { tmux -L bats "$@"; }

@test "core options" {
    [ "$(t show -gv prefix)" = "C-Space" ]
    [ "$(t show -gv base-index)" = "1" ]
    [ "$(t show -gwv pane-base-index)" = "1" ]
    [ "$(t show -gwv mode-keys)" = "vi" ]
    [ "$(t show -gv mouse)" = "on" ]
    [ "$(t show -gv renumber-windows)" = "on" ]
    [ "$(t show -sv escape-time)" = "1" ]
}

@test "split and pane navigation bindings" {
    keys=$(t list-keys)
    grep -qE 'prefix +\\\\ +split-window -h -c "#\{pane_current_path\}"' <<<"$keys"
    grep -qE 'prefix +- +split-window -v -c "#\{pane_current_path\}"' <<<"$keys"
    for dir in Left:L Right:R Up:U Down:D; do
        grep -qE "root +M-${dir%%:*} +select-pane -${dir#*:}" <<<"$keys" || { echo "M-${dir%%:*}"; return 1; }
    done
}

@test "dracula theme is configured" {
    [ "$(t show -gv @dracula-plugins)" = "git time" ]
    [ "$(t show -gv @dracula-show-powerline)" = "true" ]
}

@test "new panes run fish" {
    for _ in $(seq 50); do
        [ "$(t display -p '#{pane_current_command}')" = "fish" ] && return 0
        sleep 0.1
    done
    t display -p '#{pane_current_command}'
    return 1
}
