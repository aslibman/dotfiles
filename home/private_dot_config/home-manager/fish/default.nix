{ ... }:

{
  programs.fish = {
    enable = true;

    shellInit = ''
      # Disable greeting message
      set -g fish_greeting

      # Set WSL-specific envvar to silence VSCode install
      set -gx DONT_PROMPT_WSL_INSTALL No_Prompt_please

      # Ensure ~/.nix-profile/bin takes priority over system paths.
      # fish_user_paths is always prepended to $PATH by fish.
      fish_add_path --move --prepend "$HOME/.nix-profile/bin"

      # Dracula theme for eza: https://draculatheme.com/eza
      set -gx EZA_COLORS "uu=36:uR=31:un=35:gu=37:da=2;34:ur=34:uw=95:ux=36:ue=36:gr=34:gw=35:gx=36:tr=34:tw=35:tx=36:xx=95:"

      # Use bat for syntax highlighting in less
      set -gx LESSOPEN "| bat --color=always --paging=never --style=plain -- %s 2>/dev/null"
      set -gx LESS -R
    '';

    interactiveShellInit = builtins.readFile ./interactive.fish;

    shellAbbrs = {
      shellcheck = "shellcheck --color";
      "--help" = {
        expansion = "--help | bat -plhelp";
        position = "anywhere";
      };
      "-h" = {
        expansion = "-h | bat -plhelp";
        position = "anywhere";
      };
    };

    shellAliases = {
      vim = "nvim";
      ls = "eza";
      find = "fd";
      ps = "procs";
      gamend = "git commit --amend --no-edit";
      docker = "podman";
    };

    functions = {
      fish_postexec = {
        onEvent = "fish_postexec";
        body = ''
          set -l last_status $status
          print_prompt_separator $last_status
        '';
      };

      print_prompt_separator.body = builtins.readFile ./print_prompt_separator.fish;

      __atuin_setup = {
        description = "Initialize atuin + fzf history widget for fish";
        body = builtins.readFile ./atuin_setup.fish;
      };

      ff-widget.body = ''
        set -l selected (ff)
        if test -n "$selected"
            commandline -i -- $selected
        end
        commandline -f repaint
      '';
    };
  };
}
