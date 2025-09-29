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

    # Set up fzf key bindings
    fzf --fish | source

    # Preview file content using bat (https://github.com/sharkdp/bat)
    set --export FZF_CTRL_T_OPTS "
      --preview 'bat -n --color=always {}'
      --bind 'ctrl-/:change-preview-window(down|hidden|)'"

    # Dracula FZF theme: https://draculatheme.com/fzf
    set --export FZF_DEFAULT_OPTS '--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'

    # Load atuin from atuin_setup.fish
    # We must ensure this is run after fzf setup to override fzf's default CTRL-R search with atuin
    # See https://github.com/junegunn/fzf/issues/4417
    __atuin_setup

    # Use bat for man pages - https://github.com/sharkdp/bat#man
    batman --export-env | source

    # Setup source-highlight for less pager
    set --export LESSOPEN "| $HOME/.nix-profile/bin/src-hilite-lesspipe.sh %s"
    set --export LESS -R
end