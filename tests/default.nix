# Runs tests/*.bats against a home configuration built for a scratch home
# directory, without activating it: $HOME holds the generated dotfiles and
# ~/.nix-profile is the home profile. Tests tagged `activated` need a real
# switch and only run in CI after `nix run .` (see .github/workflows/test.yml).
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
    nativeBuildInputs = import ./tools.nix pkgs;
    passthru = { inherit homeConfig; };
  }
  ''
    export HOME=${homeDirectory}
    export USER=$(id -un)
    ${pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isLinux "export LANG=C.UTF-8 # the Linux sandbox has no locale"}
    rm -rf $HOME && mkdir -p $HOME
    trap 'rm -rf "$HOME"' EXIT
    cp -rs --no-preserve=mode ${homeConfig.home-files}/. $HOME/
    ln -s ${homeConfig.home.path} $HOME/.nix-profile
    export PATH=$HOME/.nix-profile/bin:$PATH
    export HM_HOME_FILES=${homeConfig.home-files}

    # Nix only shows the last lines of a failed build, so repeat the failures at the end
    bats --print-output-on-failure --filter-tags '!activated' ${./.} | tee $TMPDIR/bats.log || {
      echo "=== failed tests ==="
      awk '/^not ok/ { p = 1 } /^ok / { p = 0 } p' $TMPDIR/bats.log
      exit 1
    }
    touch $out
  ''
