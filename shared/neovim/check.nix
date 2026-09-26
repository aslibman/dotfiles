# Starts the generated Neovim config headlessly and fails on any startup error.
{ pkgs, homeConfig }:

pkgs.runCommand "neovim-config-check"
  {
    nativeBuildInputs = [ homeConfig.programs.neovim.finalPackage ];
  }
  ''
    export HOME=$TMPDIR
    export XDG_CONFIG_HOME=${homeConfig.home-files}/.config
    export XDG_DATA_HOME=${homeConfig.home-files}/.local/share
    export XDG_STATE_HOME=$TMPDIR/state XDG_CACHE_HOME=$TMPDIR/cache

    output=$(nvim --headless +'colorscheme dracula' +qa 2>&1)
    if [ -n "$output" ]; then
      echo "$output"
      exit 1
    fi
    touch $out
  ''
