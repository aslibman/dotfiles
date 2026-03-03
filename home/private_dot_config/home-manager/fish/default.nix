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
