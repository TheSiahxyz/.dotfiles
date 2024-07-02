
" AUTOCMD ---------------------------------------------------------------- {{{

" Disables automatic commenting on newline:
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Nerd tree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Runs a script that cleans out tex build files whenever I close out of a .tex file.
autocmd VimLeave *.tex !texclear %

" Text files
let g:vimwiki_ext2syntax = {'.Rmd': 'markdown', '.rmd': 'markdown','.md': 'markdown', '.markdown': 'markdown', '.mdown': 'markdown'}
let g:vimwiki_list = [{'path': '~/.local/share/nvim/vimwiki', 'syntax': 'markdown', 'ext': '.md'}]
autocmd BufRead,BufNewFile /tmp/calcurse*,~/.calcurse/notes/* set filetype=markdown
autocmd BufRead,BufNewFile *.ms,*.me,*.mom,*.man set filetype=groff
autocmd BufRead,BufNewFile *.tex set filetype=tex

" Enable Goyo by default for mutt writing
autocmd BufRead,BufNewFile /tmp/neomutt* let g:goyo_width=80
autocmd BufRead,BufNewFile /tmp/neomutt* :Goyo | set bg=light
autocmd BufRead,BufNewFile /tmp/neomutt* map ZZ :Goyo\|x!<CR>
autocmd BufRead,BufNewFile /tmp/neomutt* map ZQ :Goyo\|q!<CR>

" Automatically deletes all trailing whitespace and newlines at end of file on save. & reset cursor position
autocmd BufWritePre * let currPos = getpos(".")
autocmd BufWritePre * %s/\s\+$//e
autocmd BufWritePre * %s/\n\+\%$//e
autocmd BufWritePre *.[ch] %s/\%$/\r/e " add trailing newline for ANSI C standard
autocmd BufWritePre *neomutt* %s/^--$/-- /e " dash-dash-space signature delimiter in emails
autocmd BufWritePre * cal cursor(currPos[1], currPos[2])

" When shortcut files are updated, renew bash and ranger configs with new material:
autocmd BufWritePost bm-files,bm-dirs !shortcuts

" Run xrdb whenever Xdefaults or Xresources are updated.
autocmd BufRead,BufNewFile Xresources,Xdefaults,xresources,xdefaults set filetype=xdefaults
autocmd BufWritePost Xresources,Xdefaults,xresources,xdefaults !xrdb %

" Recompile dwmblocks on config edit.
autocmd BufWritePost ~/.local/src/dwmblocks/config.h !cd ~/.local/src/dwmblocks/; sudo make install && { killall -q dwmblocks;setsid -f dwmblocks }

" }}}


" BACKUP ----------------------------------------------------------------- {{{

if version >= 703
    set undodir=~/.config/vim/undodir
    set undofile
    set undoreload=10000
endif

" }}}


" PLUGINS INIT ----------------------------------------------------------- {{{

if filereadable(expand("~/.config/vim/plugins.vim"))
    silent !mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}/vim/plugged/
    source ~/.config/vim/plugins.vim
endif

" goyo
let g:is_goyo_active = v:false
function! GoyoEnter()
  if executable('tmux') && strlen($TMUX)
    silent !tmux set status off
    silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
  endif

  let g:default_colorscheme = exists('g:colors_name') ? g:colors_name : 'default'
  set background=light
  set linebreak
  set wrap
  set textwidth=0
  set wrapmargin=0

  Goyo 80x85%
  colorscheme seoul256
  let g:is_goyo_active = v:true
endfunction

function! GoyoLeave()
  if executable('tmux') && strlen($TMUX)
    silent !tmux set status on
    silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
  endif

  Goyo!
  execute 'colorscheme ' . g:default_colorscheme
  let g:is_goyo_active = v:false
endfunction

function! ToggleGoyo()
  if g:is_goyo_active
    call GoyoLeave()
  else
    call GoyoEnter()
  endif
endfunction

" }}}


" PLUGIN MAPPINGS -------------------------------------------------------- {{{

" fugitive
nnoremap <leader>gs :Git<CR>

" Goyo plugin makes text more readable when writing prose:
nnoremap <leader>gy :call ToggleGoyo()<CR>

" Nerd tree
map <leader>n :NERDTreeToggle<CR>

" Undotree
nnoremap <leader>u :UndotreeToggle<CR>

" vimwiki
map <leader>vw :VimwikiIndex<CR>

" vim-plug
nnoremap <leader>pi :PlugInstall<CR>

" whichkey
nnoremap <silent> <leader> :WhichKey '<Space>'<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey  '\'<CR>

" }}}


" PLUGIN SETTINGS -------------------------------------------------------- {{{

" vim-airline
if !exists('g:airline_symbols')
        let g:airline_symbols = {}
endif
let g:airline_symbols.colnr = ' C:'
let g:airline_symbols.linenr = ' L:'
let g:airline_symbols.maxlinenr = '☰ '

" colorscheme
if isdirectory(expand("~/.config/vim/plugged/gruvbox"))
    let g:airline_theme = 'gruvbox'
    colorscheme gruvbox
endif

" whichkey
set timeoutlen=300

" }}}
