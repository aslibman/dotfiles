{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    prefix = "C-Space";
    baseIndex = 1;
    escapeTime = 1;
    mouse = true;
    terminal = "tmux-256color";
    keyMode = "vi";

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = dracula;
        extraConfig = ''
          set -g @dracula-plugins "git time"
          set -g @dracula-show-powerline true
          set -g @dracula-show-left-icon session
          set -g @dracula-border-contrast true
          set -g @dracula-show-empty-plugins false
          set -g @dracula-show-flags true
        '';
      }
    ];

    extraConfig = ''
      # Use fish shell
      set -g default-command "bash -l -c 'exec fish'"

      # Pane settings
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      # Use Alt-arrow keys without prefix key to switch panes
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D
      unbind Left
      unbind Right
      unbind Up
      unbind Down

      # Split panes with \ and -; open new split panes in same directory
      bind \\ split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # Enable colors
      set-option -sa terminal-overrides ",xterm*:Tc"

      # Aggressive resizing for clients
      setw -g aggressive-resize on

      # Disable right-click menu
      unbind -n MouseDown3Pane

      # Copy mode prompt navigation
      bind -T copy-mode n send-keys -X next-prompt
      bind -T copy-mode p send-keys -X previous-prompt

      # Disable visual activity for speed
      set -g visual-activity off
      set -g visual-bell off
      set -g visual-silence on

      # Powerline font
      tmux_conf_theme_left_separator_main='\uE0B0'
      tmux_conf_theme_left_separator_sub='\uE0B1'
      tmux_conf_theme_right_separator_main='\uE0B2'
      tmux_conf_theme_right_separator_sub='\uE0B3'
    '';
  };
}
