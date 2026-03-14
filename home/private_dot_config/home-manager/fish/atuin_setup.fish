# Widget: fzf over atuin history with two columns:
#   {relativetime}<TAB>{command}
function fzf_atuin_history_widget
    set -l selected
    set -l ret 0

    # Initial query
    set -l buf (commandline -b)

    # --- atuin format strings ---
    set -l ATUIN_FMT "{relativetime}	{command}"

    # --- fzf options ---
    # - --tac
    # - -n2..,..  (search on the 2nd column only)
    # - --tiebreak=index
    # - --query=<current buffer>
    # - +m  (disable multi select)
    # - bind:
    #     ctrl-d: reload with directory filter (-c $PWD)
    #     ctrl-r: reload global
    #
    # Note: we escape \"$PWD\" so it expands when fzf executes the reload command.
    set -l bind_reload "--bind=ctrl-d:reload(atuin search --format '{$ATUIN_FMT}' -c \"$PWD\"),ctrl-r:reload(atuin search --format '{$ATUIN_FMT}')"

    set -l fzf_opts \
        --tac \
        -n2..,.. \
        --tiebreak=index \
        --query "$buf" \
        +m \
        $bind_reload

    set selected (atuin search --format "$ATUIN_FMT" | fzf $fzf_opts)
    set ret $status

    if test -n "$selected"
        # Strip the first column (relativetime + TAB)
        set -l cmd_only (string replace -r '^[^\t]*\t' '' -- "$selected")

        # Append to existing buffer
        set -l newbuf "$buf$cmd_only"
        commandline -r -- $newbuf
        commandline -f end-of-line repaint
    end

    return $ret
end

# Ctrl-R => fzf atuin search
# Ctrl-E => stock atuin search
bind \cr fzf_atuin_history_widget
bind \ce _atuin_search
bind -M insert \cr fzf_atuin_history_widget
bind -M insert \ce _atuin_search
