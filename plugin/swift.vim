" File: plugin/swift.vim
" Author: Kevin Ballard
" Description: Plugin for Swift
" Last Change: June 23, 2014

if exists("g:loaded_syntastic_swift_filetype")
    finish
endif
let g:loaded_syntastic_swift_filetype = 1

let s:save_cpo = &cpo
set cpo&vim

if exists("g:syntastic_extra_filetypes")
    let g:syntastic_extra_filetypes += ['rust']
else
    let g:syntastic_extra_filetypes = ['rust']
endif

let &cpo = s:save_cpo
unlet s:save_cpo
