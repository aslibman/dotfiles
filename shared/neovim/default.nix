{ pkgs, ... }:

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
      is-vim

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

    initLua = ''
      vim.opt.number = true
      vim.opt.relativenumber = true

      vim.opt.tabstop = 4
      vim.opt.shiftwidth = 4
      vim.opt.softtabstop = 4
      vim.opt.expandtab = true

      vim.opt.mouse = "a"
      vim.opt.showmatch = true
      vim.opt.scrolloff = 6

      vim.opt.termguicolors = true
      vim.g.dracula_italic = 0
      vim.cmd.colorscheme("dracula")

      vim.notify = require("notify")
      require("hardtime").setup({})
    '';
  };
}
