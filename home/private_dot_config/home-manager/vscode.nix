{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;

    mutableExtensionsDir = true;

    profiles.default = {
      extensions = pkgs.nix4vscode.forVscode [
        "anthropic.claude-code"
        "asvetliakov.vscode-neovim"
        "astral-sh.ty"
        "github.vscode-github-actions"
        "jnoortheen.nix-ide"
        "ms-python.debugpy"
        "ms-python.python"
        "ms-python.vscode-python-envs"
        "ms-toolsai.jupyter"
        "ms-toolsai.jupyter-keymap"
        "ms-toolsai.jupyter-renderers"
        "ms-toolsai.vscode-jupyter-cell-tags"
      ];

      userSettings = {
        "claudeCode.preferredLocation" = "panel";
        "editor.minimap.enabled" = false;
        "editor.lineNumbers" = "relative";
        "explorer.confirmDelete" = false;
        "update.mode" = "none";
        "extensions.autoUpdate" = false;
        "extensions.autoCheckUpdates" = false;
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

  home.activation.validateVscode = config.lib.dag.entryAfter ["linkGeneration"] ''
    run echo "🔍 Validating VSCode configuration..."

    if ! run ${pkgs.writeShellScript "test-vscode-wrapper" ''
      export PATH="${config.home.profileDirectory}/bin:$PATH"
      ${./test-vscode.sh}
    ''}; then
      echo "❌ VSCode validation failed!"
      echo "Fix the errors above before the configuration can be activated."
      exit 1
    fi
  '';
}
