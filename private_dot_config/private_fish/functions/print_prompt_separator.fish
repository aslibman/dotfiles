function print_prompt_separator
    set -l last_status $argv[1]  # receive status from fish_postexec

    set dot "·"
    set color (set_color -o brblack)     # Light gray dots
    set timecolor (set_color brcyan)     # Datetime color
    set rtcolor (set_color bryellow)     # Runtime color
    set errcolor (set_color red)         # Error code color
    set reset (set_color normal)

    # Terminal width
    set cols (tput cols)

    # Current date and time
    set datetime (date "+%Y-%m-%d %H:%M:%S")

    # Command duration formatting (only if >= 2s)
    set runtime ""
    if test $CMD_DURATION -ge 2000
        set total_secs (math --scale=0 "$CMD_DURATION / 1000")

        set hours (math --scale=0 "$total_secs / 3600")
        set mins (math --scale=0 "($total_secs % 3600) / 60")
        set secs (math --scale=0 "$total_secs % 60")

        set formatted_runtime ""
        if test $hours -gt 0
            set formatted_runtime $hours"h "$mins"m "$secs"s"
        else if test $mins -gt 0
            set formatted_runtime $mins"m "$secs"s"
        else
            set formatted_runtime $secs"s"
        end

        set runtime " | $rtcolor$formatted_runtime$reset"
    end

    # Status code (only show if non-zero)
    set status_text ""
    if test $last_status -ne 0
        set status_text " | $errcolor✖ Exit $last_status$reset"
    end

    # Center text: datetime + runtime (if any)
    set center_text "$timecolor$datetime$reset$runtime$status_text"

    # Compute left/right padding
    set text_len (string length --visible $center_text)
    set left_len (math --scale=0 "($cols - $text_len) / 2")
    set right_len (math --scale=0 "$cols - $left_len - $text_len")

    set left (string repeat -n $left_len $dot)
    set right (string repeat -n $right_len $dot)

    # Print full-width dotted line with centered info
    printf "\n$color$left$reset$center_text$color$right$reset\n"
end