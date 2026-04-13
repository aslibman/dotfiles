{ ... }:

{
  programs.atuin = {
    enable = true;
    flags = [
      "--disable-up-arrow"
      "--disable-ctrl-r"
    ];
    settings = {
      auto_sync = false;
      keys.scroll_exits = false;
    };
  };
}
