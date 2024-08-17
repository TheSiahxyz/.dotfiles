
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
autocmd BufRead,BufNewFile /tmp/neomutt* :Goyo 80 | call feedkeys("jk")
autocmd BufRead,BufNewFile /tmp/neomutt* map ZZ :Goyo!\|x!<CR>
autocmd BufRead,BufNewFile /tmp/neomutt* map ZQ :Goyo!\|q!<CR>

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

" Which key description
autocmd! User vim-which-key call which_key#register('<Space>', 'g:which_key_map')
let g:which_key_map = {}

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


" PLUGIN MAPPINGS & SETTINGS -------------------------------------------------------- {{{

" Open quickfix/location list
let g:which_key_map.o       = {
            \ 'name' : '+Open'        ,
            \ 'q' : 'Quickfix-list'   ,
            \ 'l' : 'Location-list'   ,
            \ }

" Check health
nnoremap <leader>ch :CheckHealth<CR>
let g:which_key_map.c       = { 'name' : 'Check' }
let g:which_key_map.c.h     = 'Check-health'

" Fugitive
nnoremap <leader>gs :Git<CR>
let g:which_key_map.g       = { 'name' : 'Git/Goyo' }
let g:which_key_map.g.s     = 'Git'

" Goyo plugin makes text more readable when writing prose:
nnoremap <leader>gy :call ToggleGoyo()<CR>
let g:which_key_map.g.y     = 'Toggle-goyo'

" Nerd tree
map <leader>n :NERDTreeToggle<CR>
let g:which_key_map.n       = 'Toggle-nerd-tree'

" Undotree
nnoremap <leader>u :UndotreeToggle<CR>
let g:which_key_map.u       = 'Toggle-undo-tree'

" vimwiki
map <leader>vw :VimwikiIndex<CR>
let g:which_key_map.v       = { 'name' : '+Vim-wiki' }
let g:which_key_map.v.w     = 'Vim-wiki-index'

" vim-plug
nnoremap <leader>pc :PlugClean<CR>
nnoremap <leader>pi :PlugInstall<CR>
nnoremap <leader>pu :PlugUpdate<CR>
let g:which_key_map.p       =   { 'name' : '+Plug' }
let g:which_key_map.p.c     =   'Plug-clean'
let g:which_key_map.p.i     =   'Plug-install'
let g:which_key_map.p.u     =   'Plug-update'

" whichkey
nnoremap <silent> <leader>      :<c-u>WhichKey '<Space>'<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey '\'<CR>

" lsp
if executable('pylsp')
    " pip install python-lsp-server
    au User lsp_setup call lsp#register_server({
                \ 'name': 'pylsp',
                \ 'cmd': {server_info->['pylsp']},
                \ 'allowlist': ['python'],
                \ })
endif

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gs <plug>(lsp-document-symbol-search)
    nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> <leader>lr <plug>(lsp-rename)
    nmap <buffer> [t <plug>(lsp-previous-diagnostic)
    nmap <buffer> ]t <plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)
    nnoremap <buffer> <expr><c-d> lsp#scroll(+4)
    nnoremap <buffer> <expr><c-u> lsp#scroll(-4)

    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre *.rs,*.go,*.py call execute('LspDocumentFormatSync')

    " refer to doc to add more commands
endfunction

let g:which_key_map.g = {
            \ 'name' : '+Goto'          ,
            \ 'd' : 'Definition'        ,
            \ 's' : 'Symbol'            ,
            \ 'S' : 'Workspace-symbol'  ,
            \ 'r' : 'References'        ,
            \ 'i' : 'Implementation'    ,
            \ 't' : 'Type-definition'   ,
            \ }

let g:which_key_map['['] = { 'name' : '+Previous' }
let g:which_key_map[']'] = { 'name' : '+Next' }
let g:which_key_map['[t'] = 'Diagnostic'
let g:which_key_map[']t'] = 'Diagnostic'
let g:which_key_map.K = 'Keyword'

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

let g:lsp_fold_enabled = 0
let g:lsp_log_verbose = 1
let g:lsp_log_file = expand('~/.cache/vim/log/vim-lsp.log')
let g:asyncomplete_log_file = expand('~/.cache/vim/log/asyncomplete.log')
let g:lsp_settings_filetype_python = ['pyright-langserver', 'ruff', 'ruff-lsp']

nnoremap <leader>li :LspInstallServer<CR>

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

" fzf
let g:fzf_vim = {}
let $FZF_DEFAULT_OPTS = "--layout=default --preview-window 'right:60%' --preview 'bat --style=numbers --line-range :300 {}'
            \ --bind ctrl-y:preview-up,ctrl-e:preview-down,
            \ctrl-b:preview-page-up,ctrl-f:preview-page-down,
            \ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down,
            \shift-up:preview-top,shift-down:preview-bottom,
            \alt-up:half-page-up,alt-down:half-page-down"

if exists('$TMUX')
    let g:fzf_layout = { 'tmux': '90%,70%' }
else
    let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6, 'relative': v:true } }
endif
let g:fzf_vim.preview_window = ['right,50%,<70(up,40%)', 'ctrl-/']
let g:fzf_vim.commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'
let g:fzf_vim.tags_command = 'ctags -R'

function! s:build_quickfix_list(lines)
    call setqflist(map(copy(a:lines), '{ "filename": v:val, "lnum": 1 }'))
    copen
    cc
endfunction

let g:fzf_action = {
            \ 'ctrl-q' : function('s:build_quickfix_list'),
            \ 'ctrl-t' : 'tab split' ,
            \ 'ctrl-x' : 'split'     ,
            \ 'ctrl-v' : 'vsplit'    ,
            \ }

nnoremap <leader>cl :Colors<CR>
nnoremap <leader>fb :Files ~/.local/bin<CR>
nnoremap <leader>fc :Files ~/.config<CR>
nnoremap <leader>fd :Files ~/.dotfiles<CR>
nnoremap <leader>ff :Files .<CR>
nnoremap <leader>fF :Files ~<CR>
nnoremap <leader>fg :GFiles<CR>
nnoremap <leader>fG :GFiles?<CR>
nnoremap <leader>fs :Files ~/.local/src/suckless<CR>
nnoremap <leader>sb :Buffers<CR>
nnoremap <leader>sc :Changes<CR>
nnoremap <leader>sC :Commands<CR>
nnoremap <leader>sg :Rg<CR>
nnoremap <leader>sG :RG<CR>
nnoremap <leader>shc :History:<CR>
nnoremap <leader>shh :History<CR>
nnoremap <leader>shp :Helptags<CR>
nnoremap <leader>shs :History/<CR>
nnoremap <leader>sj :Jumps<CR>
nnoremap <leader>sk :Maps<CR>
nnoremap <leader>sl :Locate<CR>
nnoremap <leader>sm :Marks<CR>
nnoremap <leader>sn :Snippets<CR>
nnoremap <leader>st :Filetypes<CR>
nnoremap <leader>gc :Commits<CR>
nnoremap <leader>gC :BCommits<CR>

let g:which_key_map.c = 'Color-schemes'
let g:which_key_map.f = {
            \ 'name' : '+Find'          ,
            \ 'b' : 'Scripts'           ,
            \ 'c' : 'Config'            ,
            \ 'd' : 'Dotfiles'          ,
            \ 'f' : 'Files'             ,
            \ 'F' : 'Root-files'        ,
            \ 'g' : 'Git-files'         ,
            \ 'G' : 'Git-status'        ,
            \ 's' : 'Suckless'          ,
            \ }

let g:which_key_map.g = {
            \ 'name' : '+Git'           ,
            \ 'c' : 'Commits'           ,
            \ 'C' : 'Buffer-commits'    ,
            \ }

let g:which_key_map.s = {
            \ 'name' : '+Search'        ,
            \ 'b' : 'Buffers'           ,
            \ 'c' : 'Changes'           ,
            \ 'C' : 'Commands'          ,
            \ 'g' : 'Rip-grep'          ,
            \ 'G' : 'Rip-Grep'          ,
            \ 'h' : {
                \  'name' : '+History'      ,
                \ 'c' : 'Command-history'   ,
                \ 'h' : 'History'           ,
                \ 'p' : 'Help-tags'         ,
                \ 's' : 'Search-history'    ,
                \ },
            \ 'j' : 'Jumps'             ,
            \ 'k' : 'Key-maps'          ,
            \ 'l' : 'Locate'            ,
            \ 'm' : 'Marks'             ,
            \ 'n' : 'Snippets'          ,
            \ 't' : 'File-types'        ,
            \ }


" snippets
let g:SuperTabDefaultCompletionType    = '<c-n>'
let g:SuperTabCrMapping                = 0
let g:UltiSnipsExpandTrigger           = '<c-e>'
let g:UltiSnipsJumpForwardTrigger      = '<tab>'
let g:UltiSnipsJumpBackwardTrigger     = '<s-tab>'
let g:UltiSnipsEditSplit               = 'vertical'
let g:UltiSnipsAutoTrigger             = 1
let g:asyncomplete_auto_completeopt    = 0
let g:asyncomplete_auto_popup          = 1

set completeopt=menuone,noinsert,noselect,preview
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

if executable('pyls')
    " pip install python-language-server
    au User lsp_setup call lsp#register_server({
                \ 'name': 'pyls',
                \ 'cmd': {server_info->['pyls']},
                \ 'allowlist': ['python'],
                \ })
endif

if has('python3')
    call asyncomplete#register_source(asyncomplete#sources#ultisnips#get_source_options({
                \ 'name': 'ultisnips',
                \ 'allowlist': ['*'],
                \ 'completor': function('asyncomplete#sources#ultisnips#completor'),
                \ }))
endif

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"

" whichkey
set timeoutlen=500

let g:which_key_map.a       =   'Select-all-the-text'
let g:which_key_map.b       =   { 'name' : '+Buffer' }
let g:which_key_map.b.n     =   'New/open-buffer'
let g:which_key_map.c       =   { 'name' : '+Format' }
let g:which_key_map.c.f     =   'Format-buffer'
let g:which_key_map.e       =   'Explorer'
let g:which_key_map.h       =   { 'name' : '+Hex' }
let g:which_key_map.h.x     =   'Toggle-hex/reverse-conversion'
let g:which_key_map.l       =   { 'name' : '+Lex/Lsp' }
let g:which_key_map.l.e     =   'Open-lex'
let g:which_key_map.l.i     =   'Lsp-install-server'
let g:which_key_map.l.r     =   'Rename'
let g:which_key_map.o       =   { 'name' : '+Open' }
let g:which_key_map.o.g     =   'Orthography'
let g:which_key_map.Q       =   'Force-quit-all'
let g:which_key_map.r       =   { 'name' : '+Replace' }
let g:which_key_map.r.w     =   'Replace word'
let g:which_key_map.s       =   { 'name' : '+Surround' }
let g:which_key_map.s.o     =   'Source-file'
let g:which_key_map.s.w     =   'Surround-word'
let g:which_key_map.t       =   'Go-to-tab'
let g:which_key_map["'"]    =   'Register'
let g:which_key_map['w']    =   {
            \ 'name' : '+windows' ,
            \ 'd' : ['<C-W>c'     , 'Delete-window']         ,
            \ 'h' : ['<C-W>h'     , 'Window-left']           ,
            \ 'H' : ['<C-W>5<'    , 'Expand-window-left']    ,
            \ 'j' : ['<C-W>j'     , 'Window-below']          ,
            \ 'J' : [':resize +5' , 'Expand-window-below']   ,
            \ 'k' : ['<C-W>k'     , 'Window-up']             ,
            \ 'K' : [':resize -5' , 'Expand-window-up']      ,
            \ 'l' : ['<C-W>l'     , 'Window-right']          ,
            \ 'L' : ['<C-W>5>'    , 'Expand-window-right']   ,
            \ 's' : ['<C-W>s'     , 'Split-window-below']    ,
            \ 'v' : ['<C-W>v'     , 'Split-window-below']    ,
            \ 'w' : ['<C-W>w'     , 'Other-window']          ,
            \ '2' : ['<C-W>v'     , 'Layout-double-columns'] ,
            \ '-' : ['<C-W>s'     , 'Split-window-below']    ,
            \ '|' : ['<C-W>v'     , 'Split-window-right']    ,
            \ '=' : ['<C-W>='     , 'Balance-window']        ,
            \ '?' : ['Windows'    , 'Fzf-window']            ,
            \ }

" }}}
