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
    keychain
    gh
    graphviz
    nerd-fonts.inconsolata
    procs
    reef
    ripgrep
    rustup
    shellcheck
    tldr
    unzip
    uv
  ];

  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    COLORTERM = "truecolor";
    # Use bat for syntax highlighting in less
    LESSOPEN = "| bat --color=always --paging=never --style=plain -- %s 2>/dev/null";
    LESS = "-R";
    # Silence VSCode's "install in WSL" prompt
    DONT_PROMPT_WSL_INSTALL = "No_Prompt_please";
  };

  programs.bash.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global.hide_env_diff = true;
  };
}
