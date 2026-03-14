#!/bin/bash

##
# Interactive search.
# Usage: `ff` or `ff <folder>`.
#
[[ -n $1 ]] && cd "$1" || exit 1 # go to provided folder or exit
RG_DEFAULT_COMMAND="rg -i -l --hidden --no-ignore-vcs"

__fzf_contentsearch__() {
    local output
    output=$(
        FZF_DEFAULT_COMMAND="rg --files" fzf \
            -m \
            -e \
            --ansi \
            --disabled \
            --reverse \
            --bind "ctrl-a:select-all" \
            --bind "f12:execute-silent:(subl -b {})" \
            --bind "change:reload:$RG_DEFAULT_COMMAND {q} || true" \
            --preview "rg -i --pretty --context 2 {q} {}" | cut -d":" -f1,2
    ) || return
    echo "$output"
}

__fzf_contentsearch__
