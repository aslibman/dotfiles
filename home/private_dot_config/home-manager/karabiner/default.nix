{ pkgs, ... }:

let
  windowsShortcuts = builtins.fromJSON (builtins.readFile ./windows_shortcuts.json);

  karabinerConfig = {
    global = {
      check_for_updates_on_startup = false;
      show_in_menu_bar = true;
    };
    profiles = [
      {
        name = "Default";
        selected = true;
        virtual_hid_keyboard.keyboard_type_v2 = "ansi";
        simple_modifications = [
          {
            from = { key_code = "caps_lock"; };
            to = [{ key_code = "left_control"; }];
          }
        ];
        complex_modifications = {
          # Downloaded from 
          # https://raw.githubusercontent.com/rux616/karabiner-windows-mode/main/json/windows_shortcuts.json
          rules = windowsShortcuts.rules;
        };
      }
    ];
  };
in
{
  home.packages = with pkgs; [
    karabiner-elements
  ];

  home.file.".config/karabiner/karabiner.json" = {
    text = builtins.toJSON karabinerConfig;
    force = true;
  };

  home.file.".config/karabiner/assets/complex_modifications/windows_shortcuts.json".source =
    ./windows_shortcuts.json;
}
