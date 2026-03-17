{ pkgs, ... }:

{
  home.packages = with pkgs; [
    iterm2
    nerd-fonts.inconsolata
  ];

  targets.darwin.defaults."com.googlecode.iterm2" = {
    SUEnableAutomaticChecks = false;
  };

  home.file = {
    "Library/Application Support/iTerm2/DynamicProfiles/profiles.json".source = ./profiles.json;
    "Library/Application Support/iTerm2/ColorPresets/Dracula.itermcolors".source =
      ./Dracula.itermcolors;
  };
}
