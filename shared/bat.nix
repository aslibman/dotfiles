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

  # Page man through bat (equivalent to `batman --export-env`)
  home.sessionVariables = {
    MANPAGER = "env BATMAN_IS_BEING_MANPAGER=yes bash ${pkgs.bat-extras.batman}/bin/batman";
    MANROFFOPT = "-c";
  };
}
