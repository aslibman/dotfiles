# Disable greeting message
set -g fish_greeting

# Enable starship prompt
set --export STARSHIP_CONFIG ~/.config/starship/starship.toml
starship init fish | source

function fish_postexec --on-event fish_postexec
    set -l last_status $status
    print_prompt_separator $last_status
end