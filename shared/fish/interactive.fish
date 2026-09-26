# Enable vi mode
fish_vi_key_bindings

# Load atuin -- must run after fzf to override its CTRL-R binding
# See https://github.com/junegunn/fzf/issues/4417
__atuin_setup

# Key bindings
bind / self-insert
bind \cf ff-widget
bind -M insert \cf ff-widget
