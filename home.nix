{ pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./atuin.nix
    ./bat.nix
    ./eza
    ./fish
    ./fzf.nix
    ./git.nix
    ./neovim
    ./podman
    ./scripts
    ./starship.nix
    ./tmux.nix
    ./vscode
  ];

  home.username = "alex";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/alex" else "/home/alex";

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
