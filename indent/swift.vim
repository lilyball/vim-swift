" File: swift.vim
" Author: Kevin Ballard
" Description: Indentation file for Swift
" Last Modified: June 05, 2014

if exists("b:did_indent")
    finish
endif
let b:did_indent = 1

setl cindent " use cindent for the time being, it should work reasonably

let b:undo_indent = "setl cin<"

" vim: set et sw=4 ts=4:
