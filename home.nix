{
  username,
  homeDirectory,
  ...
}:

{
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
