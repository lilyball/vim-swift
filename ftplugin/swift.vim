" File: ftplugin/swift.vim
" Author: Kevin Ballard
" Description: Filetype plugin for Swift
" Last Change: Jul 07, 2014

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

setlocal suffixesadd=.swift

setlocal comments=s1:/**,mb:*,ex:*/,s1:/*,mb:*,ex:*/,:///,://
setlocal commentstring=//%s

" Commands {{{1

" Define a trivial :SwiftRun command
" This may want to be expanded later
command! -nargs=* -buffer -bang -bar SwiftRun call swift#Run(<bang>0, [<f-args>])

" Mappings {{{1

" Map ⌘R to :SwiftRun in MacVim
nnoremap <buffer> <silent> <D-r> :SwiftRun<CR>

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
            \|setlocal formatoptions< suffixesadd< comments< commentstring<
            \|setlocal showmatch<
            \|delcommand SwiftRun
            \|nunmap <buffer> <D-r>
            \|unlet! b:swift_last_args b:swift_last_swift_args
            \"

" }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sw=4 ts=4:
