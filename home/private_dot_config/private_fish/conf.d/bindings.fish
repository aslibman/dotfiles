bind / self-insert
bind -M default / self-insert

# CTRL-F - Paste the selected file from ff (fuzzy find) into the command line
function ff-widget
    set -l selected (ff)
    if test -n "$selected"
        commandline -i -- $selected
    end
    commandline -f repaint
end
bind \cf ff-widget
bind -M default \cf ff-widget
bind -M insert \cf ff-widget