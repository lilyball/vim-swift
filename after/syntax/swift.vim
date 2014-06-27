" File: after/syntax/swift.vim
" Author: Kevin Ballard
" Description: Conceal support for Swift
" Last Change: June 26, 2014

if exists('g:swift_no_conceal') || !has('conceal') || &enc != 'utf-8'
    finish
endif

syn match swiftOperatorArrowHead contained '>' transparent contains=NONE conceal cchar= 
syn match swiftOperatorArrowTail contained '-' transparent contains=NONE conceal cchar=⟶
syn match swiftOperatorArrow '->\%([-/=+!*%<>&|^~.]\)\@!' contains=swiftOperatorArrowHead,swiftOperatorArrowTail transparent

syn match swiftIdentPrime /\i\@<=__*\>/me=s+1 conceal cchar=′ containedin=swiftIdentifier transparent contains=NONE

setl conceallevel=2

" vim: set et sw=4 ts=4:
