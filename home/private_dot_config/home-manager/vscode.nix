{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;

    mutableExtensionsDir = true;

    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        asvetliakov.vscode-neovim
        jnoortheen.nix-ide
        ms-python.python
        ms-toolsai.jupyter
      ];

      userSettings = {
        "claudeCode.preferredLocation" = "panel";
        "editor.minimap.enabled" = false;
        "editor.lineNumbers" = "relative";
        "explorer.confirmDelete" = false;
        "extensions.experimental.affinity" = {
          "asvetliakov.vscode-neovim" = 1;
        };
      };

      keybindings = [
        {
          key = "up";
          command = "selectPrevCodeAction";
          when = "suggestWidgetVisible && textInputFocus && !editorReadonly && vim.mode == 'Insert'";
        }
        {
          key = "up";
          command = "-selectPrevCodeAction";
          when = "codeActionMenuVisible";
        }
        {
          key = "down";
          command = "selectNextSuggestion";
          when = "suggestWidgetVisible && textInputFocus && !editorReadonly && vim.mode == 'Insert'";
        }
        {
          key = "down";
          command = "-selectNextSuggestion";
          when = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus || suggestWidgetVisible && textInputFocus && !suggestWidgetHasFocusedSuggestion";
        }
      ];
    };
  };
}
