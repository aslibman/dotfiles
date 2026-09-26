# Runs tests/*.bats against a home configuration built for a scratch home
# directory, without activating it: $HOME holds the generated dotfiles and
# PATH is the home profile.
{ pkgs, mkHomeConfiguration }:

let
  homeDirectory = "/tmp/dotfiles-home-tests";
  homeConfig =
    (mkHomeConfiguration {
      username = "tester";
      inherit homeDirectory;
      gitEmail = "tester@example.com";
    }).config;
in
pkgs.runCommand "home-tests"
  {
    nativeBuildInputs = [
      pkgs.bats
      pkgs.procps
    ];
  }
  ''
    export HOME=${homeDirectory}
    export USER=$(id -un)
    rm -rf $HOME && mkdir -p $HOME
    cp -rs --no-preserve=mode ${homeConfig.home-files}/. $HOME/
    export PATH=${homeConfig.home.path}/bin:$PATH

    bats --print-output-on-failure ${./.}
    touch $out
  ''
