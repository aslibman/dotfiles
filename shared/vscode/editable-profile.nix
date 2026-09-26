# Makes the Nix-generated VSCode settings, keybindings and extensions editable
# during a session, then resets them to the Nix-defined state on each switch.
# Also applies to vscode-server (Remote SSH).

{ config, pkgs, ... }:

let
  vscodeUserPath =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "Library/Application Support/Code/User"
    else
      ".config/Code/User";
  vscodeUserDir = "${config.home.homeDirectory}/${vscodeUserPath}";
in
{
  home.activation.vscodePreSetup = config.lib.dag.entryBefore [ "linkGeneration" ] ''
    run ${pkgs.writeShellScript "vscode-pre-setup" ''
      rm -f "${vscodeUserDir}/settings.json" "${vscodeUserDir}/keybindings.json"
      rm -rf "$HOME/.vscode/extensions"
    ''}
  '';

  home.activation.vscodePostSetup = config.lib.dag.entryAfter [ "linkGeneration" ] ''
    run ${pkgs.writeShellScript "vscode-post-setup" ''
      set -euo pipefail

      for f in "${vscodeUserDir}/settings.json" "${vscodeUserDir}/keybindings.json"; do
        [ -L "$f" ] || continue
        cp "$(readlink "$f")" "$f.tmp" && rm "$f" && mv "$f.tmp" "$f" && chmod 644 "$f"
      done

      vss="${config.home.homeDirectory}/.vscode-server/data/User/settings.json"
      if [ -d "$(dirname "$vss")" ]; then
        cp "${vscodeUserDir}/settings.json" "$vss"
      fi
    ''}
  '';
}
