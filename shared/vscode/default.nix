{
  config,
  pkgs,
  ...
}:

let
  windowsKeybindings = import ./windows-keybindings.nix;

  extensions = pkgs.nix4vscode.forVscode [
    "astral-sh.ty"
    "charliermarsh.ruff"
    "jnoortheen.nix-ide"
    "ms-python.debugpy"
    "ms-python.python"
    "ms-python.vscode-python-envs"
    "ms-toolsai.jupyter"
    "ms-toolsai.jupyter-keymap"
    "ms-toolsai.jupyter-renderers"
    "ms-toolsai.vscode-jupyter-cell-tags"
    "rust-lang.rust-analyzer"
    "tamasfe.even-better-toml"
    "asvetliakov.vscode-neovim"
    "ms-vscode-remote.remote-containers"
    "dracula-theme.theme-dracula"
  ];
in
{
  imports = [
    ./claude.nix
    ./editable-profile.nix
  ];

  programs.vscode = {
    enable = true;

    mutableExtensionsDir = true;

    profiles.default = {
      inherit extensions;

      userSettings = {
        "workbench.colorTheme" = "Dracula Theme";
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
        "editor.minimap.enabled" = false;
        "editor.lineNumbers" = "relative";
        "editor.fontFamily" = "'Inconsolata Nerd Font', monospace";
        "editor.fontLigatures" = false;
        "editor.fontSize" = 14;
        "explorer.confirmDelete" = false;
        "update.mode" = "none";
        "extensions.autoUpdate" = false;
        "extensions.autoCheckUpdates" = false;
        "extensions.ignoreRecommendations" = true;
        "extensions.experimental.affinity" = {
          "asvetliakov.vscode-neovim" = 1;
        };
        "files.autoSave" = "afterDelay";
        "files.autoSaveDelay" = 1000;
        "github.copilot.enable" = {
          "*" = false;
        };
        "github.copilot.editor.enableAutoCompletions" = false;
        "github.copilot.chat.enabled" = false;
        "github.copilot.renameSuggestions.triggerAutomatically" = false;
        "github.copilot.nextEditSuggestions.enabled" = false;
        # Remove some of neovim's CTRL key captures
        "vscode-neovim.ctrlKeysForInsertMode" = [
          "d"
          "h"
          "j"
          "m"
          "o"
          "r"
          "t"
          "u"
          "w"
        ];
        "vscode-neovim.ctrlKeysForNormalMode" = [
          "b"
          "d"
          "e"
          "f"
          "h"
          "i"
          "j"
          "k"
          "l"
          "m"
          "o"
          "r"
          "t"
          "u"
          "w"
          "x"
          "y"
          "z"
          "/"
          "]"
          "right"
          "left"
          "up"
          "down"
          "backspace"
          "delete"
        ];
        "dev.containers.dockerPath" = "podman";
      };

      keybindings = windowsKeybindings ++ [
        {
          key = "up";
          command = "selectPrevSuggestion";
          when = "suggestWidgetVisible && textInputFocus && !editorReadonly";
        }
        {
          key = "up";
          command = "-selectPrevSuggestion";
          when = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus || suggestWidgetVisible && textInputFocus && !suggestWidgetHasFocusedSuggestion";
        }
        {
          key = "down";
          command = "selectNextSuggestion";
          when = "suggestWidgetVisible && textInputFocus && !editorReadonly";
        }
        {
          key = "down";
          command = "-selectNextSuggestion";
          when = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus || suggestWidgetVisible && textInputFocus && !suggestWidgetHasFocusedSuggestion";
        }
      ];
    };
  };

  home.file.".vscode-server/extensions".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.vscode/extensions";
}
