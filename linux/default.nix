{ lib, ... }:

{
  imports = [
    ./ghostty
  ];

  targets.genericLinux.enable = true;
  xdg.enable = true;

  # Symlink nix profile apps so GNOME's launcher can discover them
  # TODO: Figure out whether this is really necessary or if we can
  # fix apps on GNOME via just xdg settings.
  home.activation.linkNixApps = lib.hm.dag.entryAfter [ "writeBoundaries" ] ''
    mkdir -p ~/.local/share/applications
    rm -f ~/.local/share/applications/nix
    ln -s ~/.nix-profile/share/applications ~/.local/share/applications/nix
  '';
}
