" File: ftplugin/swift.vim
" Author: Kevin Ballard
" Description: Filetype plugin for Swift
" Last Change: Jul 25, 2014

if exists("b:did_ftplugin")
    finish
endif
let b:did_ftplugin = 1

let s:save_cpo = &cpo
set cpo&vim

" Variables {{{1

" Match Xcode default indentation settings
setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4

" Use 80 as the text width but only format comments
setlocal textwidth=80
setlocal formatoptions-=t formatoptions+=croqnl
silent! setlocal formatoptions+=j

" cc=+1 is common, but showing it for the comment width kind of sucks.
" Let's pick 120 characters instead, that's a good length.
setlocal colorcolumn=121

setlocal suffixesadd=.swift

setlocal comments=s1:/**,mb:*,ex:*/,s1:/*,mb:*,ex:*/,:///,://
setlocal commentstring=//%s

" Commands {{{1

" See |:SwiftRun| for docs
command! -nargs=* -complete=file -buffer -bang SwiftRun call swift#Run(<bang>0, <q-args>)

" Mappings {{{1

" Map ⌘R in MacVim to :SwiftRun
nnoremap <buffer> <silent> <D-r> :SwiftRun<CR>

" Map ⌘⇧R in MacVim to :SwiftRun! pre-filled with the last args
nnoremap <buffer> <D-R> :SwiftRun! <C-r>=join(b:swift_last_swift_args)<CR><C-\>eswift#AppendCmdLine(' -- ' . join(b:swift_last_args))<CR>

if !exists("b:swift_last_swift_args") || !exists("b:swift_last_args")
    let b:swift_last_swift_args = []
    let b:swift_last_args = []
endif

" Miscellaneous {{{1

" Add support to NERDCommenter
if !exists('g:swift_setup_NERDCommenter')
    let g:swift_setup_NERDCommenter = 1

    let s:delimiter_map = { 'swift': { 'left': '//', 'leftAlt': '/*', 'rightAlt': '*/' } }

    if exists('g:NERDDelimiterMap')
        call extend(g:NERDDelimiterMap, s:delimiter_map)
    elseif exists('g:NERDCustomDelimiters')
        call extend(g:NERDCustomDelimiters, s:delimiter_map)
    else
        let g:NERDCustomDelimiters = s:delimiter_map
    endif
    unlet s:delimiter_map
endif

" Check for 'showmatch' because it doesn't work right with \()
if &showmatch
    echohl WarningMsg
    echomsg "Swift string interpolations do not work well with 'showmatch'"
    echohl None
    echomsg "It is recommended that you turn it off and use matchparen instead"
endif

" Cleanup {{{1

let b:undo_ftplugin = "
            \ setlocal expandtab< shiftwidth< tabstop< softtabstop< textwidth<
            \|setlocal colorcolumn<
            \|setlocal formatoptions< suffixesadd< comments< commentstring<
            \|setlocal showmatch<
            \|delcommand SwiftRun
            \|unlet! b:swift_last_swift_args b:swift_last_args
            \|nunmap <buffer> <D-r>
            \|nunmap <buffer> <D-R>
            \|unlet! b:swift_last_args b:swift_last_swift_args
            \"

" }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sw=4 ts=4:
