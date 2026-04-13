{ pkgs, ... }:

{
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
}
