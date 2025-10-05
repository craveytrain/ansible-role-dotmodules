" Vim configuration
" This file is deployed via GNU Stow

" Basic settings
set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set hlsearch
set incsearch
set ignorecase
set smartcase
set showmatch
set ruler
set laststatus=2
set backspace=indent,eol,start
set wildmenu
set wildmode=longest:full,full

" Enable syntax highlighting
syntax on

" Enable file type detection
filetype on
filetype plugin on
filetype indent on

" Color scheme
colorscheme desert

" Key mappings
let mapleader = " "
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>wq :wq<CR>
nnoremap <leader>h :nohlsearch<CR>

" Plugin management with vim-plug
call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
call plug#end()

" NERDTree settings
nnoremap <leader>n :NERDTreeToggle<CR>
let NERDTreeShowHidden=1

" Airline settings
let g:airline_theme='powerlineish'
let g:airline_powerline_fonts=1
