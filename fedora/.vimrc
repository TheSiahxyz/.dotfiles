" ============================================================
" Basic vimrc for Fedora
" ============================================================

set nocompatible
filetype plugin indent on
syntax on

" --- Line numbers
set number
set relativenumber

" --- Encoding
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,cp949,euc-kr,latin1

" --- Indentation
set autoindent
set smartindent
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set smarttab

" --- Search
set hlsearch
set incsearch
set ignorecase
set smartcase

" --- Display
set cursorline
set showmatch
set showcmd
set ruler
set laststatus=2
set wildmenu
set wildmode=longest:full,full
set scrolloff=5
set sidescrolloff=8
set signcolumn=yes
set display=lastline
set lazyredraw
set ttyfast

" --- Editing
set backspace=indent,eol,start
set hidden
set clipboard=unnamedplus
set mouse=a
set splitright
set splitbelow

" --- Files / history
set history=1000
set undolevels=1000
set undofile
set undodir=~/.vim/undo//
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set viminfo='100,<50,s10,h

" Auto-create undo/backup/swap directories
silent! call mkdir(expand('~/.vim/undo'), 'p')
silent! call mkdir(expand('~/.vim/backup'), 'p')
silent! call mkdir(expand('~/.vim/swap'), 'p')

" --- Misc
set timeoutlen=500
set updatetime=300
set noerrorbells
set novisualbell
set nowrap
set list
set listchars=tab:▸\ ,trail:·,nbsp:␣

" --- Colors
set background=dark
silent! colorscheme desert

" --- Leader key
let mapleader = " "

" --- Keymaps
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>h :nohlsearch<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" --- Restore last cursor position
augroup remember_last_pos
  autocmd!
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
augroup END
