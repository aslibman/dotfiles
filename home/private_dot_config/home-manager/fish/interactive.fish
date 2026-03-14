# Enable vi mode
fish_vi_key_bindings

# Add custom bin scripts to PATH
fish_add_path "$HOME/.local/bin"

# Load atuin -- must run after fzf to override its CTRL-R binding
# See https://github.com/junegunn/fzf/issues/4417
__atuin_setup

# Setup keychain for SSH key management
if type -q keychain
    keychain --eval --quiet --agents ssh id_rsa id_ed25519 2>/dev/null
    if test -f ~/.keychain/(hostname)-fish
        source ~/.keychain/(hostname)-fish
    end
end

# Key bindings
bind / self-insert
bind -M default / self-insert
bind \cf ff-widget
bind -M default \cf ff-widget
bind -M insert \cf ff-widget
