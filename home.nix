{
  pkgs,
  username,
  homeDirectory,
  ...
}:

{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./shared
  ];

  home.username = username;
  home.homeDirectory = homeDirectory;

  home.packages = with pkgs; [
    claude-code
    delta
    dust
    fd
    graphviz
    keychain
    procs
    reef
    ripgrep
    rustup
    shellcheck
    tldr
    unzip
    uv
  ];

  home.stateVersion = "25.11";

  home.sessionVariables = {
    EDITOR = "nvim";
    COLORTERM = "truecolor";
  };

  programs.bash.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global.hide_env_diff = true;
  };

  programs.home-manager.enable = true;
}
