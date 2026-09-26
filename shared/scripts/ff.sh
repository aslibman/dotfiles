#!/bin/bash
# Interactive content search: `ff [folder]`. Prints the selected file paths.
[[ -n $1 ]] && { cd "$1" || exit 1; }

RG_COMMAND="rg -i -l --hidden --no-ignore-vcs"

rg --files | fzf \
    -m \
    -e \
    --ansi \
    --disabled \
    --reverse \
    --bind "ctrl-a:select-all" \
    --bind "change:reload:$RG_COMMAND {q} || true" \
    --preview "rg -i --pretty --context 2 {q} {}" | cut -d":" -f1,2
