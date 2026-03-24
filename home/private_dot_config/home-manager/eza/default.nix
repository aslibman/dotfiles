{ ... }:

{
  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
  };

  xdg.configFile."eza/theme.yml".source = ./dracula.yml;
}
