{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      # UI and Appearance
      vim-airline
      vim-devicons
      dracula-vim

      # Utilities
      vim-commentary

      # Treesitter
      (nvim-treesitter.withPlugins (p: [
        p.bash
        p.c
        p.cpp
        p.css
        p.dockerfile
        p.fish
        p.go
        p.html
        p.java
        p.javascript
        p.json
        p.lua
        p.make
        p.markdown
        p.nix
        p.python
        p.regex
        p.rust
        p.sql
        p.terraform
        p.toml
        p.tsx
        p.typescript
        p.vim
        p.xml
        p.yaml
      ]))

      # Hardtime and dependencies
      nui-nvim
      hardtime-nvim
      nvim-notify
    ];

    extraConfig = ''
      " File format settings
      set ff=unix
      set number
      set relativenumber

      " Indentation settings
      set autoindent
      set tabstop=4
      set shiftwidth=4
      set smarttab
      set expandtab
      set softtabstop=4
      filetype indent on

      " Miscellaneous settings
      set mouse=a
      set showmatch
      set incsearch
      set hlsearch
      set scrolloff=6

      " Enable Dracula theme
      set termguicolors
      let g:dracula_italic = 0
      colorscheme dracula
    '';

    initLua = ''
      -- Disable unused providers (removes healthcheck warnings)
      vim.g.loaded_python3_provider = 0
      vim.g.loaded_ruby_provider = 0
      vim.g.loaded_node_provider = 0
      vim.g.loaded_perl_provider = 0

      vim.notify = require("notify")
      require("hardtime").setup({})
    '';
  };

  # Post-activation validation - runs after new generation is linked
  # This ensures we're testing the newly built Neovim
  home.activation.validateNeovim = config.lib.dag.entryAfter [ "linkGeneration" ] ''
    run echo "🔍 Validating Neovim configuration..."

    # Use the newly installed nvim from the new generation
    if ! run ${pkgs.writeShellScript "test-neovim-wrapper" ''
      export PATH="${config.home.profileDirectory}/bin:$PATH"
      ${./test-neovim.sh}
    ''}; then
      echo "❌ Neovim validation failed!"
      echo "Fix the errors above before the configuration can be activated."
      exit 1
    fi
  '';
}
