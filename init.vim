if has("unix")
  let s:uname = system("uname")
  let g:python_host_prog = '/usr/bin/python3'
  let g:python3_host_prog = '/usr/bin/python3'
endif

call plug#begin("~/.vim/plugged")
Plug 'romainl/flattened'
Plug 'nsf/gocode'
Plug 'rust-lang/rust.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive'
Plug 'toyamarinyon/vim-swift'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'w0rp/ale'
Plug 'bluz71/vim-moonfly-colors'
Plug 'yorokobi/vim-splunk'
Plug 'hashivim/vim-terraform'
Plug 'zchee/nvim-go', { 'do': 'make'}
call plug#end()

"JSX
let g:jsx_ext_required = 0

"Vim-Go
" let g:go_fmt_autosave = 0

" Airline
let g:airline_left_sep = '▶'
let g:airline_right_sep = '◀'
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.space = ' '
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.spell = 'Ꞩ'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.notexists = '∄'
let g:airline_symbols.whitespace = 'Ξ'
let g:airline_symbols.maxlinenr = '☰'
let g:airline_symbols.crypt = '🔒'
let g:airline_symbols.readonly = '🔏'
let g:airline#extensions#wordcount#enabled = 0
imap <S-Tab> <C-d>

" ALE
let g:ale_sign_error = '>'
let g:ale_sign_warning = '-'
let g:ale_java_javac_classpath = '.'
let g:ale_python_pylint_options = '-rcfile ~/dotfiles/pylint.rc'

let g:ale_fixers = {
  \   'python': [
  \       'black',
  \   ],
  \}

let mapleader = " "
set nu
set rnu
set tabstop=2
set expandtab
set shiftwidth=2
set textwidth=100
set colorcolumn=100
set background=dark
set laststatus=2
set autochdir
set autoread
set incsearch
set hlsearch
set ignorecase
set smartcase
set termguicolors
set scrolloff=8
colorscheme flattened_dark
syntax enable

"NeoVim can't handle <ESC>
set ttimeout
set ttimeoutlen=0
set matchtime=0

" Undo, Backup, and Swap file locations
set undofile

let s:vimfiles = $HOME."/.vim"
function! EnsureDirectory(directory)
    if !isdirectory(a:directory)
        call mkdir(a:directory, "p")
    endif
    return a:directory
endfunction

let &undodir=EnsureDirectory(s:vimfiles."/undo")."//"
let &backupdir=EnsureDirectory(s:vimfiles."/backup")."//"
let &directory=EnsureDirectory(s:vimfiles."/swap")."//"

nnoremap <Leader><Leader> :nohl<Cr>
nnoremap <Leader>H <C-w>H
nnoremap <Leader>J <C-w>J
nnoremap <Leader>K <C-w>K
nnoremap <Leader>L <C-w>L
nnoremap <Leader>h <C-w>h
nnoremap <Leader>j <C-w>j
nnoremap <Leader>k <C-w>k
nnoremap <Leader>l <C-w>l
nnoremap <Leader>] <C-]>
nnoremap <Leader>p "*p
vnoremap <Leader>p "*p
vnoremap <Leader>y "*y
nnoremap <Leader>y "*y
nnoremap <Leader>P "*P
vnoremap <Leader>P "*P
vnoremap <Leader>Y "*Y
nnoremap <Leader>Y "*Y

function! _render_markdown()
    if expand("%:e") == "md"
        w
        silent !markdown-it % > %:r.html
        silent !open -a Safari %:r.html
    endif
endfunction

function! _write_markdown()
    if expand("%:e") == "md"
        w
        silent !markdown-it % > %:r.html
    endif
endfunction


com! ClearTrailingWhiteSpace %s/\s\+$//
com! RenderMarkdown call _render_markdown()
com! WriteMarkdown call _write_markdown()

augroup CustomFileTypeDetect
  au! BufRead,BufNewFile *.md setlocal spell
augroup END
