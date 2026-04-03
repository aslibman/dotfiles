{ config, pkgs, ... }:

{
  # Populate mutable settings copies from the Nix-managed source on each rebuild.
  # This applies to both the local VSCode profile and the vscode-server (Remote SSH).
  # Edits are allowed during a session but wiped to a clean slate on the next rebuild.
  # Extensions remain mutable via the shared ~/.vscode/extensions directory.
  home.activation.vscodeEditableProfile = config.lib.dag.entryAfter [ "linkGeneration" ] ''
    run ${pkgs.writeShellScript "vscode-editable-profile-setup" ''
      VSCODE_USER_DIR="${config.xdg.configHome}/Code/User"
      PROFILE_DIR="$VSCODE_USER_DIR/profiles/editable"
      VSCODE_SERVER_USER_DIR="${config.home.homeDirectory}/.vscode-server/data/User"

      # Local VSCode: editable named profile
      mkdir -p "$PROFILE_DIR"
      install -m 644 "$VSCODE_USER_DIR/settings.json" "$PROFILE_DIR/settings.json"
      install -m 644 "$VSCODE_USER_DIR/keybindings.json" "$PROFILE_DIR/keybindings.json"

      # Register the local profile in VSCode's storage.json if not already present
      STORAGE_FILE="$VSCODE_USER_DIR/globalStorage/storage.json"
      if [ -f "$STORAGE_FILE" ]; then
        ${pkgs.jq}/bin/jq '
          if (.userDataProfiles // [] | map(.name) | contains(["editable"]))
          then .
          else .userDataProfiles += [{"name": "editable", "location": "editable"}]
          end
        ' "$STORAGE_FILE" > "$STORAGE_FILE.tmp" && mv "$STORAGE_FILE.tmp" "$STORAGE_FILE"
      fi

      # vscode-server (Remote SSH): copy into User scope so settings are editable
      # in the Settings UI, unlike Machine scope which VSCode treats as read-only.
      if [ -d "$VSCODE_SERVER_USER_DIR" ]; then
        install -m 644 "$VSCODE_USER_DIR/settings.json" "$VSCODE_SERVER_USER_DIR/settings.json"
      fi
    ''}
  '';
}
