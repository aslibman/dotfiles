{ config, pkgs, ... }:

let
  sandboxedClaude = pkgs.writeShellScriptBin "sandboxed-claude" ''
    exec nono run -p claude-code \
      --silent \
      --network-profile claude-code \
      --allow ${config.home.profileDirectory} \
      --allow "''${workspaceFolder:-$PWD}" \
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
