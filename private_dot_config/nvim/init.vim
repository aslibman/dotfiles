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

" Auto install vim-plug
" https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugins
call plug#begin()

Plug 'vim-airline/vim-airline' " Status bar
Plug 'ryanoasis/vim-devicons' " Developer Icons
Plug 'dracula/vim', {'as': 'dracula'} " Dracula theme
Plug 'tpope/vim-commentary' " Easy commenting
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} " Treesitter

call plug#end()

" Enable Dracula theme
set termguicolors
let g:dracula_italic = 0
colorscheme dracula

" Treesitter config - important to have GCC installed via Nix too
" https://old.reddit.com/r/Nix/comments/rgcynr/nonnixos_homemanager_treesitternvim_and_tsinstall/hqni4pv/
lua << EOF
require'nvim-treesitter.configs'.setup {
    ensure_installed = "all",
    highlight = { enable = true },
}
EOF
