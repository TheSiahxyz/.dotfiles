
" AUTOCMD ---------------------------------------------------------------- {{{

" Close with q
autocmd FileType checkhealth,help,lspinfo,neotest-output,neotest-output-panel,neotest-summary,netrw,notify,qf,query,spectre_panel,startuptime,terminal,tsplayground noremap <buffer> q :bd<CR>

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
    source ${XDG_CONFIG_HOME:-$HOME/.config}/vim/plugins.vim
endif

" goyo
let g:is_goyo_active = v:false
function! GoyoEnter()
    if executable('tmux') && strlen($TMUX)
        silent !tmux set status off
        silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
    endif

    let g:default_colorscheme = exists('g:colors_name') ? g:colors_name : 'desert'
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
nnoremap <Leader>ch :CheckHealth<CR>
let g:which_key_map.c       = { 'name' : 'Check' }
let g:which_key_map.c.h     = 'Check-health'

" Bookmarks
let g:bookmark_no_default_key_mappings = 1
let g:bookmark_save_per_working_dir = 1
let g:bookmark_auto_save = 1
nmap <Leader>mm <Plug>BookmarkToggle
nmap <Leader>mi <Plug>BookmarkAnnotate
nmap <Leader>ma <Plug>BookmarkShowAll
nmap <Leader>m] <Plug>BookmarkNext
nmap <Leader>m[ <Plug>BookmarkPrev
nmap <Leader>mc <Plug>BookmarkClear
nmap <Leader>mx <Plug>BookmarkClearAll
nmap <Leader>mk <Plug>BookmarkMoveUp
nmap <Leader>mj <Plug>BookmarkMoveDown
nmap <Leader>mg <Plug>BookmarkMoveToLine

" Fugitive
nnoremap <Leader>gs :Git<CR>
let g:which_key_map.g       = { 'name' : 'Git/Goyo' }
let g:which_key_map.g.s     = 'Git'

" Goyo plugin makes text more readable when writing prose:
nnoremap <Leader>gy :call ToggleGoyo()<CR>
let g:which_key_map.g.y     = 'Toggle-goyo'

" Nerd tree
map <Leader>n :NERDTreeToggle<CR>
let g:which_key_map.n       = 'Toggle-nerd-tree'

" Undotree
nnoremap <Leader>u :UndotreeToggle<CR>
let g:which_key_map.u       = 'Toggle-undo-tree'

" vimwiki
map <Leader>vw :VimwikiIndex<CR>
let g:which_key_map.v       = { 'name' : '+Vim-wiki' }
let g:which_key_map.v.w     = 'Vim-wiki-index'

" vim-plug
nnoremap <Leader>pc :PlugClean<CR>
nnoremap <Leader>pi :PlugInstall<CR>
nnoremap <Leader>pu :PlugUpdate<CR>
let g:which_key_map.p       =   { 'name' : '+Plug' }
let g:which_key_map.p.c     =   'Plug-clean'
let g:which_key_map.p.i     =   'Plug-install'
let g:which_key_map.p.u     =   'Plug-update'

" whichkey
nnoremap <silent> <Leader>      :<C-U>WhichKey '<Space>'<CR>
nnoremap <silent> <localleader> :<C-U>WhichKey '\'<CR>

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
    nmap <buffer> <Leader>lr <plug>(lsp-rename)
    nmap <buffer> [t <plug>(lsp-previous-diagnostic)
    nmap <buffer> ]t <plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)
    " nnoremap <buffer> <expr><C-D> lsp#scroll(+4)
    " nnoremap <buffer> <expr><C-U> lsp#scroll(-4)

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
let g:lsp_log_file = expand('~/.cache/vim/vim-lsp.log')
let g:asyncomplete_log_file = expand('~/.cache/vim/asyncomplete.log')
let g:lsp_settings_filetype_python = ['pyright-langserver', 'ruff', 'ruff-lsp']

nnoremap <Leader>li :LspInstallServer<CR>

" vim-airline
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_symbols.colnr = ' C:'
let g:airline_symbols.linenr = ' L:'
let g:airline_symbols.maxlinenr = ' '
let g:airline#extensions#whitespace#symbol = '!'

" colorscheme
if isdirectory(expand("~/.config/vim/plugged/catppuccin"))
    let g:airline_theme = 'catppuccin_mocha'
    colorscheme catppuccin_mocha
endif

" fzf
let g:fzf_vim = {}
let $FZF_DEFAULT_OPTS = "--layout=default --preview-window 'right:60%' --preview 'bat --style=numbers --line-range :300 {}'
              \ --bind ctrl-y:preview-up,
              \        ctrl-e:preview-down,
              \        ctrl-b:preview-page-up,
              \        ctrl-f:preview-page-down,
              \        ctrl-u:preview-half-page-up,
              \        ctrl-d:preview-half-page-down,
              \        shift-up:preview-top,
              \        shift-down:preview-bottom,
              \        alt-up:half-page-up,
              \        alt-down:half-page-down
              \ "

" tmux
if exists('$TMUX')
    let g:fzf_layout = { 'tmux': '90%,70%' }
    let  g:tmux_navigator_no_wrap = 1
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

nnoremap <Leader>cl :Colors<CR>
nnoremap <Leader>fb :Files ~/.local/bin<CR>
nnoremap <Leader>fc :Files ~/.config<CR>
nnoremap <Leader>fd :Files ~/.dotfiles<CR>
nnoremap <Leader>ff :Files .<CR>
nnoremap <Leader>fF :Files ~<CR>
nnoremap <Leader>fg :GFiles<CR>
nnoremap <Leader>fG :GFiles?<CR>
nnoremap <Leader>fs :Files ~/.local/src/suckless<CR>
nnoremap <Leader>fv :Files ~/.config/vim<CR>
nnoremap <Leader>sb :Buffers<CR>
nnoremap <Leader>sc :Changes<CR>
nnoremap <Leader>sC :Commands<CR>
nnoremap <Leader>sg :Rg<CR>
nnoremap <Leader>sG :RG<CR>
nnoremap <Leader>shc :History:<CR>
nnoremap <Leader>shh :History<CR>
nnoremap <Leader>shp :Helptags<CR>
nnoremap <Leader>shs :History/<CR>
nnoremap <Leader>sj :Jumps<CR>
nnoremap <Leader>sk :Maps<CR>
nnoremap <Leader>sl :Locate<CR>
nnoremap <Leader>sm :Marks<CR>
nnoremap <Leader>sn :Snippets<CR>
nnoremap <Leader>st :Filetypes<CR>
nnoremap <Leader>gc :Commits<CR>
nnoremap <Leader>gC :BCommits<CR>

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
            \ 'v' : 'Vim-config'        ,
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
let g:SuperTabDefaultCompletionType    = '<C-N>'
let g:SuperTabCrMapping                = 0
let g:UltiSnipsExpandTrigger           = '<C-E>'
let g:UltiSnipsJumpForwardTrigger      = '<tab>'
let g:UltiSnipsJumpBackwardTrigger     = '<s-tab>'
let g:UltiSnipsEditSplit               = 'vertical'
let g:UltiSnipsAutoTrigger             = 1
let g:asyncomplete_auto_completeopt    = 0
let g:asyncomplete_auto_popup          = 1

set completeopt=menuone,noinsert,noselect,preview
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

if has('python3')
    call asyncomplete#register_source(asyncomplete#sources#ultisnips#get_source_options({
                \ 'name': 'ultisnips',
                \ 'allowlist': ['*'],
                \ 'completor': function('asyncomplete#sources#ultisnips#completor'),
                \ }))
endif

inoremap <expr> <Tab>   pumvisible() ? "\<C-N>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-P>" : "\<S-Tab>"
inoremap <expr> <CR>    pumvisible() ? asyncomplete#close_popup() : "\<CR>"

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
