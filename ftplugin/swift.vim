" File: swift.vim
" Author: Kevin Ballard
" Description: Filetype plugin for Swift
" Last Modified: June 06, 2014

if exists("b:did_ftplugin")
    finish
endif
let b:did_ftplugin = 1

let s:save_cpo = &cpo
set cpo&vim

" Define a trivial :SwiftRun command
" This may want to be expanded later
command! -nargs=* -buffer SwiftRun w !xcrun swift -sdk $(xcrun -show-sdk-path -sdk macosx) -i - -- <args>

" Map ⌘R to :SwiftRun
nnoremap <buffer> <silent> <D-r> :SwiftRun<CR>

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sw=4 ts=4:
