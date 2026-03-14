{ pkgs, ... }:

{
  programs.bat = {
    enable = true;
    config.theme = "Dracula";
    extraPackages = with pkgs.bat-extras; [
      batgrep
      batman
    ];
  };
}
