#!/bin/bash
# Pick processes with fzf and kill them: `fkill [-SIGNAL]` (default -9).
pids=$(ps -o pid=,command= -u "$USER" | fzf --multi | awk '{print $1}')
[[ -n $pids ]] && echo "$pids" | xargs kill "${1:--9}"
