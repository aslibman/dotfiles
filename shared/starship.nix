{ ... }:

{
  programs.starship = {
    enable = true;
    settings = {
      format = "[╭](bold comment) $python$direnv$username$directory$line_break$character";
      add_newline = false;
      palette = "dracula";

      palettes.dracula = {
        background = "#282a36";
        current_line = "#44475a";
        foreground = "#f8f8f2";
        comment = "#6272a4";
        cyan = "#8be9fd";
        green = "#50fa7b";
        orange = "#ffb86c";
        pink = "#ff79c6";
        purple = "#bd93f9";
        red = "#ff5555";
        yellow = "#f1fa8c";
      };

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
