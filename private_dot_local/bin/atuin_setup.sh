#!/bin/bash

atuin_setup() {
    if ! command -v atuin &> /dev/null; then
        return 1
    fi

    export ATUIN_NOBIND="true"
    eval "$(atuin init bash --disable-up-arrow --disable-ctrl-r)"

    fzf_atuin_history_widget() {
        local selected
        
        # atuin options
        local atuin_opts_immediate="--format {relativetime}\t{command}"
        # For the reload binding: delay the ANSI‑C evaluation so that when fzf
        # spawns a new shell, the quoting is re‑interpreted.
        local atuin_opts_reload="--format \$'{relativetime}\t{command}'"
      
        # fzf options
        local fzf_opts=(
            --tac
            "-n2..,.."
            --tiebreak=index
            "--query=${READLINE_LINE}"
            "+m"
            "--bind=ctrl-d:reload(atuin search ${atuin_opts_reload} -c $PWD),ctrl-r:reload(atuin search ${atuin_opts_reload})"
        )

        selected=$(atuin search ${atuin_opts_immediate} | fzf "${fzf_opts[@]}")
        local ret=$?
        
        if [[ -n "$selected" ]]; then
            # Remove everything before and including the first tab
            selected="${selected#*$'\t'}"              
            READLINE_LINE+="$selected"
            READLINE_POINT=${#READLINE_LINE}
        fi
        
        return $ret
    }

    bind -x '"\C-r":fzf_atuin_history_widget'

    bind -x '"\C-e":__atuin_history'
}

atuin_setup
