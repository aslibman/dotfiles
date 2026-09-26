let
  c = import ./dracula.nix;
in
{
  programs.fzf = {
    enable = true;

    # Dracula FZF theme: https://draculatheme.com/fzf
    defaultOptions = [
      "--color=fg:${c.foreground},bg:${c.background},hl:${c.purple}"
      "--color=fg+:${c.foreground},bg+:${c.current_line},hl+:${c.purple}"
      "--color=info:${c.orange},prompt:${c.green},pointer:${c.pink}"
      "--color=marker:${c.pink},spinner:${c.orange},header:${c.comment}"
    ];

    # Preview file content using bat (https://github.com/sharkdp/bat)
    fileWidget.options = [
      "--preview 'bat -n --color=always {}'"
      "--bind 'ctrl-/:change-preview-window(down|hidden|)'"
    ];
  };
}
