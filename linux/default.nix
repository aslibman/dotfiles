{
  imports = [
    ./ghostty
  ];

  targets.genericLinux.enable = true;
  # Also exposes ~/.nix-profile/share (and its .desktop files) to GNOME via
  # XDG_DATA_DIRS in ~/.config/environment.d.
  xdg.enable = true;
}
