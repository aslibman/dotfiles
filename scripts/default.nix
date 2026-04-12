{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "ff" (builtins.readFile ./ff.sh))
    (pkgs.writeShellScriptBin "fkill" (builtins.readFile ./fkill.sh))
  ];
}
