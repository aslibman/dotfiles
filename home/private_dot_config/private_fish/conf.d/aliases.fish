# Always output colors for shellcheck
abbr shellcheck "shellcheck --color"

# Create help prettyprinter abbreviation
# https://github.com/sharkdp/bat#highlighting---help-messages
abbr -a --position anywhere -- --help '--help | bat -plhelp'
abbr -a --position anywhere -- -h '-h | bat -plhelp'

# Use nvim instead of vim
alias vim="nvim"

# Use eza instead of ls
alias ls="eza"

# Alias git amend
alias gamend="git commit --amend --no-edit"