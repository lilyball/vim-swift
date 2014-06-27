" Vim syntax file
" Language:    Swift
" Maintainer:  Kevin Ballard
" Last Change: June 05, 2014

if exists("b:current_syntax")
    finish
endif

" Settings {{{1

" iskeyword defines word characters, which affects \< and \>
" The default seems to be @,48-57,_,192-255
" We want it to match anything from identifier-character
" Unfortunately we can only match unicode values up to 0xFF, anything higher
" is assumed to be contained. But it's better than nothing
let &l:iskeyword = '@,' " isalpha(), should cover [a-zA-Z]
            \ . '48-57,' " 0-9
            \ . '_,'
            \ . '168,170,173,175,178-181,183-186,'
            \ . '188-190,192-214,216-246,248-255'
let &l:isident = &l:iskeyword

" Syntax definitions {{{1

" Keywords {{{2

syn keyword swiftKeyword class deinit enum extension func import init let
syn keyword swiftKeyword protocol static struct subscript typealias var
syn keyword swiftKeyword break case continue default do else fallthrough if in
syn keyword swiftKeyword for return switch where while
syn keyword swiftKeyword as dynamicType is new super self Self Type
syn keyword swiftKeyword __COLUMN__ __FILE__ __FUNCTION__ __LINE__

" context-sensitive keywords:
" associativity, didSet, get, infix, inout, left, mutating, none,
" nonmutating, operator, override, postfix, precedence, prefix, right, set,
" unowned, unowned(safe), unowned(unsafe), weak, willSet

" Built-in types {{{2
" This is just the types that represent primitives or other commonly-used
" types, not everything that exists in Swift.

syn keyword swiftType Int Int8 Int16 Int32 Int64
syn keyword swiftType UInt UInt8 UInt16 UInt32 UInt64
syn keyword swiftType Double Float Float80
syn keyword swiftType Bool
syn keyword swiftType String Array Dictionary
syn keyword swiftType Optional ImplicitlyUnwrappedOptional
syn keyword swiftType Range
syn keyword swiftType UTF8 UTF16 UTF32 UnicodeScalar Character

syn keyword swiftType Any AnyObject AnyClass

" Literals {{{2

" Dec, Bin, Oct, Hex integer literals {{{3
syn match swiftInteger display /\<\d[0-9_]*/
syn match swiftInteger display /\<0b[01][01_]*/
syn match swiftInteger display /\<0o\o[0-7_]*/
syn match swiftInteger display /\<0x\x[0-9a-fA-F_]*/

" Float and hex float literals {{{3
" NB: Swift's documentation allows a decimal integer literal to also match a
" float literal. We don't want that here.
syn match swiftFloat display /\<\d[0-9_]*\.\d[0-9_]*\%([eE][-+]\?\d[0-9_]*\)\?\>/
syn match swiftFloat display /\<\d[0-9_]*\%(\.\d[0-9_]*\)\?[eE][-+]\?\d[0-9_]*\>/
syn match swiftFloat display /\<0x\x[0-9a-fA-F_]*\%(\.\x[0-9a-fA-F_]*\)\?[pP][-+]\?\d[0-9_]*\>/

" String literals {{{3

syn region swiftString start=/"/ end=/"/ keepend oneline contains=swiftStringEscape,swiftStringEscapeError,swiftInterpolation,@Spell
syn match swiftStringEscapeError display contained /\\./
syn match swiftStringEscape display contained /\\\%([0\\tnr"']\|x\x\{2}\|u\x\{4}\|U\x\{8}\)/ extend

syn region swiftInterpolation matchgroup=swiftInterpolationDelim start=/\\(/ end=/)/ contained oneline contains=TOP

" Operators {{{2

syn match swiftOperator display ,\%(//\|/\*\)\@![-/=+!*%<>&|^~.]\+,

" Comments {{{2

syn region swiftCommentLine excludenl start="//" end="$" contains=@Spell oneline
syn region swiftCommentBlock matchgroup=swiftCommentBlock start="/\*" end="\*/" contains=swiftCommentBlockNest,@Spell
syn region swiftCommentBlockNest matchgroup=swiftCommentBlock start="/\*" end="\*/" contained contains=swiftCommentBlockNest,@Spell
" FIXME: Note, nested block comments don't work right with /* */*
" This is because vim will prioritize the comment start even though the
" comment end occurs first. I am unaware of any way to fix this.
" NB: don't try and use \*\@<! at the start of the block comment, that causes
" even more troubles, e.g. with /*/**/*/

" Default highlighting {{{1

hi def link swiftKeyword Keyword
hi def link swiftType    Type

hi def link swiftInteger  Number
hi def link swiftFloat    Number

hi def link swiftString String
hi def link swiftStringEscapeError Error
hi def link swiftStringEscape Special
hi def link swiftInterpolationDelim Delimiter

hi def link swiftCommentLine  Comment
hi def link swiftCommentBlock swiftCommentLine

" }}}1

syn sync minlines=200
syn sync maxlines=500

let b:current_syntax = "swift"

" vim: set et sw=4 ts=4:
