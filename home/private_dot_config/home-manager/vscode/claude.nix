{ config, pkgs, ... }:

let
  sandboxedClaude = pkgs.writeShellScriptBin "sandboxed-claude" ''
    workspace="''${workspaceFolder:-$PWD}"

    # Hack: Load direnv environment so devshell tools are on PATH inside claude's bash
    # See https://github.com/anthropics/claude-code/issues/2110 for maybe eventual support
    if command -v direnv >/dev/null 2>&1 && [ -f "$workspace/.envrc" ]; then
      eval "$(cd "$workspace" && DIRENV_LOG_FORMAT= direnv export bash 2>/dev/null)"
    fi

    exec nono run -p claude-code \
      --silent \
      --network-profile claude-code \
      --allow ${config.home.profileDirectory} \
      --allow "$workspace" \
      -- claude "$@"
  '';
in
{
  home.packages = [ sandboxedClaude ];

  programs.vscode.profiles.default.extensions = pkgs.nix4vscode.forVscode [
    "anthropic.claude-code"
  ];

  programs.vscode.profiles.default.userSettings = {
    "claudeCode.preferredLocation" = "panel";
    "claudeCode.claudeProcessWrapper" = "${sandboxedClaude}/bin/sandboxed-claude";
    "claudeCode.initialPermissionMode" = "acceptEdits";
  };
}
