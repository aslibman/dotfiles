# Enable vi mode
fish_vi_key_bindings

# Load atuin -- must run after fzf to override its CTRL-R binding
# See https://github.com/junegunn/fzf/issues/4417
__atuin_setup

# Load SSH keys into a shared agent; only pass keys that exist so shells stay quiet
set -l ssh_keys (path filter ~/.ssh/id_ed25519 ~/.ssh/id_rsa | path basename)
if set -q ssh_keys[1]
    SHELL=fish keychain --eval --quiet $ssh_keys | source
end

# Key bindings
bind / self-insert
bind \cf ff-widget
bind -M insert \cf ff-widget
