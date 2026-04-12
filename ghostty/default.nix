{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nerd-fonts.inconsolata
  ];

  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "InconsolataNFM";
      font-size = 16;
      theme = "Dracula";
      scrollback-limit = 1000000;
      command = "tmux new-session -A -s main";
      shell-integration = "fish";
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/terminal" = "com.mitchellh.ghostty.desktop";
      "application/x-terminal-emulator" = "com.mitchellh.ghostty.desktop";
    };
  };

  dconf.settings = {
    "org/gnome/desktop/default-applications/terminal" = {
      exec = "ghostty";
      exec-arg = "";
    };
  };

  home.sessionVariables = {
    TERMINAL = "ghostty";
  };
}
