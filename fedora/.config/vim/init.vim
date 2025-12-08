" AUTOCMD ---------------------------------------------------------------- {{{

" Close with q
autocmd FileType checkhealth,help,lspinfo,neotest-output,neotest-output-panel,neotest-summary,netrw,notify,qf,query,spectre_panel,startuptime,terminal,tsplayground noremap <buffer> q :bd<CR>

" Disables automatic commenting on newline:
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Nerd tree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Text files
autocmd BufRead,BufNewFile *.ms,*.me,*.mom,*.man set filetype=groff
autocmd BufRead,BufNewFile *.tex set filetype=tex

" Automatically deletes all trailing whitespace and newlines at end of file on save. & reset cursor position
autocmd BufWritePre * let currPos = getpos(".")
autocmd BufWritePre * %s/\s\+$//e
autocmd BufWritePre * %s/\n\+\%$//e
autocmd BufWritePre *.[ch] %s/\%$/\r/e " add trailing newline for ANSI C standard
autocmd BufWritePre *neomutt* %s/^--$/-- /e " dash-dash-space signature delimiter in emails
autocmd BufWritePre * cal cursor(currPos[1], currPos[2])

" When shortcut files are updated, renew bash and ranger configs with new material:
autocmd BufWritePost bm-files,bm-dirs !shortcuts

" }}}


" BACKUP ----------------------------------------------------------------- {{{

if version >= 703
    set undodir=${XDG_CONFIG_HOME:-$HOME/.config}/vim/undodir
    set undofile
    set undoreload=10000
endif

" }}}


" SHORTCUTS ---------------------------------------------------------------- {{{

if filereadable(expand("${XDG_CONFIG_HOME:-$HOME/.config}/vim/shortcuts.vim"))
    silent! source ${XDG_CONFIG_HOME:-$HOME/.config}/vim/shortcuts.vim
endif

" }}}
