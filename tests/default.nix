# Runs tests/*.bats against a home configuration built for a scratch home
# directory, without activating it: $HOME holds the generated dotfiles and
# PATH is the home profile.
{ pkgs, mkHomeConfiguration }:

let
  # The path is baked into the generated config, so it can't be picked at
  # runtime. Keying it on the source means different versions never share a
  # directory; Nix won't run two builds of the same version concurrently.
  # (On Linux the sandbox gives each build a private /tmp anyway.)
  sourceHash = builtins.substring 0 12 (
    builtins.unsafeDiscardStringContext (
      baseNameOf (
        builtins.path {
          path = ../.;
          name = "source";
        }
      )
    )
  );
  homeDirectory = "/tmp/dotfiles-home-tests-${sourceHash}";
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
    trap 'rm -rf "$HOME"' EXIT
    cp -rs --no-preserve=mode ${homeConfig.home-files}/. $HOME/
    export PATH=${homeConfig.home.path}/bin:$PATH

    bats --print-output-on-failure ${./.}
    touch $out
  ''
