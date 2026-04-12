{ lib, ... }:

{
  targets.genericLinux.enable = true;

  # Symlink nix profile apps so GNOME's launcher can discover them
  home.activation.linkNixApps = lib.hm.dag.entryAfter [ "writeBoundaries" ] ''
    mkdir -p ~/.local/share/applications
    rm -f ~/.local/share/applications/nix
    ln -s ~/.nix-profile/share/applications ~/.local/share/applications/nix
  '';
}
