{ pkgs, ... }:

{
  programs.vscode.profiles.default = {
    extensions = pkgs.nix4vscode.forVscode [ "anthropic.claude-code" ];

    userSettings = {
      "claudeCode.preferredLocation" = "panel";
      "claudeCode.claudeProcessWrapper" = "${pkgs.claude-code}/bin/claude";
      "claudeCode.initialPermissionMode" = "acceptEdits";
    };
  };
}
