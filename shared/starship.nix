{ ... }:

{
  programs.starship = {
    enable = true;
    settings = {
      format = "[╭](bold comment) $python$direnv$username$directory$line_break$character";
      add_newline = false;
      palette = "dracula";

      palettes.dracula = import ./dracula.nix;

      character = {
        format = "[╰─$symbol](bold comment) ";
        success_symbol = "❯";
        error_symbol = "❯";
        vimcmd_symbol = "[❮](green)";
        vimcmd_replace_symbol = "[❮](purple)";
        vimcmd_visual_symbol = "[❮](yellow)";
      };

      cmd_duration = {
        style = "bold yellow";
      };

      directory = {
        style = "bold green";
        truncate_to_repo = false;
      };

      direnv = {
        disabled = false;
        format = ''[(\($symbol\) )]($style)'';
        symbol = "direnv";
        style = "bold orange";
      };

      python = {
        format = ''[(\($symbol$virtualenv\) )]($style)'';
        generic_venv_names = [ ".venv" ];
      };
    };
  };
}
