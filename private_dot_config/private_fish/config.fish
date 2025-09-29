# Disable greeting message
set -g fish_greeting

function fish_postexec --on-event fish_postexec
    set -l last_status $status
    print_prompt_separator $last_status
end

if status is-interactive
    # Enable starship prompt
    set --export STARSHIP_CONFIG ~/.config/starship/starship.toml
    starship init fish | source

    # Enable atuin
    atuin init fish | source
end