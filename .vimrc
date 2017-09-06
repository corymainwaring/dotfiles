set nocompatible

" Line Numbering-----
set rnu
set nu

" Folding------------
set foldmethod=syntax
set foldlevelstart=1
set foldnestmax=1
let c_fold=1
let cpp_fold=1

" Coloring and Fonts-----
colorscheme solarized
set guifont=Input:h12
set guifontwide=SimHei
syn on
filetype on

" Status Line------------
set laststatus=2

" Indentation------------
set tabstop=4
set shiftwidth=4
set expandtab
set nowrap
set autoindent
set colorcolumn=100
inoremap <S-tab> <C-d>

" Searching--------------
set hlsearch
set incsearch
set ignorecase
set smartcase

" Misc-------------------
set sessionoptions+=resize,winpos
set backspace=indent,eol,start
set autochdir
set vb t_vb=

" Work in Unicode--------
if has("multi_byte")
  if &termencoding == ""
    let &termencoding = &encoding
  endif
  set encoding=utf-8
  setglobal fileencoding=utf-8
  "setglobal bomb
  set fileencodings=ucs-bom,utf-8,latin1
endif

" Undo-------------------
if !isdirectory($HOME."/.vim")
    call mkdir($HOME."/.vim", "", 0770)
endif
if !isdirectory($HOME."/.vim/undo")
    call mkdir($HOME."/.vim/undo", "", 0700)
endif
set undodir=~/.vim/undo
set undofile

" Swap Files-------------
set directory=~/.vim/swap//
set directory+=~/tmp//
set directory+=.

" Allow Folding----------
let javaScript_fold=1


" Custom mappings--------
let mapleader=" "
nnoremap <leader>n O// NOTE(cory): 
nnoremap <leader>t O// TODO(cory): 
nnoremap <leader>q :bw<cr>
nnoremap <leader>h <c-w>h
nnoremap <leader>j <c-w>j
nnoremap <leader>k <c-w>k
nnoremap <leader>l <c-w>l
nnoremap <leader>H <c-w>H
nnoremap <leader>J <c-w>J
nnoremap <leader>K <c-w>K
nnoremap <leader>L <c-w>L
nnoremap <silent> <Space><Space> :nohlsearch<Bar>:echo<CR>
nnoremap <leader>y "*y
nnoremap <leader>p "*p
nnoremap <leader>Y "*Y
nnoremap <leader>P "*P
vnoremap <leader>y "*y
vnoremap <leader>p "*p
vnoremap <leader>Y "*Y
vnoremap <leader>P "*P

" Plugins-------------------
call plug#begin()
Plug 'tpope/vim-fugitive'
Plug 'altercation/vim-colors-solarized'
call plug#end()

augroup myvimrc
    au!
    au BufWritePost .vimrc,_vimrc,vimrc so $MYVIMRC
augroup END

function! s:ExecuteInShell(command)
  call s:SetupScratch(command)
  " system to get a string back
  " getbufline
  silent! execute 'silent %!'. command
  silent! execute 'resize ' . line('$')
  silent! redraw
  silent! execute 'au BufUnload <buffer> execute bufwinnr(' . bufnr('#') . ') . ''wincmd w'''
  silent! execute 'nnoremap <silent> <buffer> <LocalLeader>r :call <SID>ExecuteInShell(''' . command . ''')<CR>'
endfunction

function! s:SetupScratch(name)
    let winnr = bufwinnr('^'.a:name.'$')
    silent! execute winnr < 0 ? 'botright new '.a:name : winnr.'wincmd w'
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap number
    return bufnr("%")
endfunction
command! -complete=shellcmd -nargs=+ Shell call s:ExecuteInShell(<q-args>)
let g:curLine=2
let s:buildBuffer=-1
let g:buildErrors = []
let s:curError = 0
function! GotoNextBuildError()
    let l:error = g:buildErrors[s:curError]
    if l:error.buffer < 0
        silent! exe "e ".l:error.file
        s:HighlightErrors()
    else
        let tmp = l:error.buffer
        echo tmp
        silent! exe tmp . "wincmd w"
    endif
    silent! exe "normal ".l:error.line."G"
    let s:curError += 1
endfunction

function! s:FindBuffer(file)
    let l:buffer = bufnr(fnameescape(a:file))
    return l:buffer
endfunction



sign define buildErr text=>> texthl=Error linehl=Error
function! s:HighlightErrors()
    sign unplace *
    let l:i = 1
    for l:err in g:buildErrors
        exec 'sign place '.l:i.' line='.l:err.line.' name=buildErr buffer='.l:err.buffer
        let l:i = l:i + 1 
    endfor
endfunction
" Must be called from Error Buffer
function! s:GetErrors()
    let g:buildErrors = []
    let l:curErr = 1
    let l:lines = getbufline(bufnr(s:buildBuffer), 1, "$")
    for l:line in l:lines
        let l:error = matchlist(l:line, '\v^(\w\:\\[^(]+)\((\d+)\)\ :\ error\ \w+\:\ (.*)')
        if len(l:error) > 0
           call add(g:buildErrors, {
                       \ "buffer":s:FindBuffer(l:error[1]),
                       \ "line":l:error[2],
                       \ "error":l:error[3],
                       \ "file":l:error[1]}) 
        endif
    endfor
endfunction

function! s:Build()
    silent! execute 'w'
    let curWin = bufwinnr("%")
    let g:curLine=2
    let s:buildBuffer = s:SetupScratch('buildOutput')
    silent! execute 'set filetype=handmade_build'
    silent! execute 'nnoremap <silent> <buffer> <Esc> :bw'.s:buildBuffer.'<CR>'
    silent! execute 'silent %!W:\code\build.bat'
    let height = line("$")
    if height > 15
        let height = 15
    endif
    call s:GetErrors()
    call s:HighlightErrors()
    silent! execute 'resize '.height
    silent! execute 'setlocal wrap'
    silent! execute curWin.'wincmd w'
endfunction

command! Build call s:Build()
"nnoremap <leader>b :Build<cr>
"nnoremap <leader>e :call GotoNextBuildError()<cr>

" Restore cursor position, window position, and last search after running a
" command.
function! Preserve(command)
  " Save the last search.
  let search = @/

  " Save the current cursor position.
  let cursor_position = getpos('.')

  " Save the current window position.
  normal! H
  let window_position = getpos('.')
  call setpos('.', cursor_position)

  " Execute the command.
  execute a:command

  " Restore the last search.
  let @/ = search

  " Restore the previous window position.
  call setpos('.', window_position)
  normal! zt

  " Restore the previous cursor position.
  call setpos('.', cursor_position)
endfunction

if has("gui_running")
  function! ScreenFilename()
    if has('amiga')
      return "s:.vimsize"
    elseif has('win32')
      return $HOME.'\_vimsize'
    else
      return $HOME.'/.vimsize'
    endif
  endfunction

  function! ScreenRestore()
    " Restore window size (columns and lines) and position
    " from values stored in vimsize file.
    " Must set font first so columns and lines are based on font size.
    let f = ScreenFilename()
    if has("gui_running") && g:screen_size_restore_pos && filereadable(f)
      let vim_instance = (g:screen_size_by_vim_instance==1?(v:servername):'GVIM')
      for line in readfile(f)
        let sizepos = split(line)
        if len(sizepos) == 5 && sizepos[0] == vim_instance
          silent! execute "set columns=".sizepos[1]." lines=".sizepos[2]
          silent! execute "winpos ".sizepos[3]." ".sizepos[4]
          return
        endif
      endfor
    endif
  endfunction

  function! ScreenSave()
    " Save window size and position.
    if has("gui_running") && g:screen_size_restore_pos
      let vim_instance = (g:screen_size_by_vim_instance==1?(v:servername):'GVIM')
      let data = vim_instance . ' ' . &columns . ' ' . &lines . ' ' .
            \ (getwinposx()<0?0:getwinposx()) . ' ' .
            \ (getwinposy()<0?0:getwinposy())
      let f = ScreenFilename()
      if filereadable(f)
        let lines = readfile(f)
        call filter(lines, "v:val !~ '^" . vim_instance . "\\>'")
        call add(lines, data)
      else
        let lines = [data]
      endif
      call writefile(lines, f)
    endif
  endfunction

  if !exists('g:screen_size_restore_pos')
    let g:screen_size_restore_pos = 1
  endif
  if !exists('g:screen_size_by_vim_instance')
    let g:screen_size_by_vim_instance = 1
  endif
  autocmd VimEnter * if g:screen_size_restore_pos == 1 | call ScreenRestore() | endif
  autocmd VimLeavePre * if g:screen_size_restore_pos == 1 | call ScreenSave() | endif
endif
