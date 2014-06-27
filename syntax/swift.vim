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

set foldmethod=syntax
set foldlevel=999

" Syntax definitions {{{1

" Identifiers {{{2

syn match swiftIdentifier /\<\i\+\>/ display transparent contains=NONE

" Keywords {{{2

" Keywords have priority over other matches, so use syn-match for the few
" keywords that we want to reuse in other matches.
syn match swiftKeyword /\<\%(class\|struct\|enum\|protocol\|var\)\>/
syn keyword swiftKeyword deinit extension func import init let
syn keyword swiftKeyword static subscript typealias
syn keyword swiftKeyword break case continue default do else fallthrough if in
syn keyword swiftKeyword for return switch where while
syn keyword swiftKeyword as dynamicType is new super self Self Type
syn keyword swiftKeyword __COLUMN__ __FILE__ __FUNCTION__ __LINE__

" context-sensitive keywords:
" inout, mutating, nonmutating, override

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
syn cluster swiftLiteral add=swiftInteger

" Float and hex float literals {{{3
" NB: Swift's documentation allows a decimal integer literal to also match a
" float literal. We don't want that here.
syn match swiftFloat display /\<\d[0-9_]*\.\d[0-9_]*\%([eE][-+]\?\d[0-9_]*\)\?\>/
syn match swiftFloat display /\<\d[0-9_]*\%(\.\d[0-9_]*\)\?[eE][-+]\?\d[0-9_]*\>/
syn match swiftFloat display /\<0x\x[0-9a-fA-F_]*\%(\.\x[0-9a-fA-F_]*\)\?[pP][-+]\?\d[0-9_]*\>/
syn cluster swiftLiteral add=swiftFloat

" String literals {{{3

syn region swiftString start=/"/ end=/"/ keepend oneline contains=swiftStringEscape,swiftStringEscapeError,swiftInterpolation,@Spell
syn match swiftStringEscapeError display contained /\\./
syn match swiftStringEscape display contained /\\\%([0\\tnr"']\|x\x\{2}\|u\x\{4}\|U\x\{8}\)/ extend
syn cluster swiftLiteral add=swiftString

syn region swiftInterpolation matchgroup=swiftInterpolationDelim start=/\\(/ end=/)/ contained oneline contains=TOP

" Miscellaneous {{{2

syn match swiftOperator display ,\%(//\|/\*\)\@![-/=+!*%<>&|^~.]\+, transparent contains=NONE

syn region swiftClosure matchgroup=swiftClosure start="{" end="}" contains=swiftClosureCaptureList,swiftClosureSimple fold
syn region swiftClosureSimple start='[^}[:space:]]' end='\ze}' transparent contained contains=TOP,@swiftDefs
syn region swiftClosureCaptureList start="\[" end="\]" contained contains=TOP,@swiftDefs nextgroup=swiftClosureSimple skipwhite skipempty
syn match swiftClosureCaptureListOwnership /\<\%(strong\>\|weak\>\|unowned\%((safe)\|(unsafe)\|\>\)\)/ contained containedin=swiftClosureCaptureList

syn match swiftAttribute /@\i\+/ nextgroup=swiftAttributeArguments skipwhite skipempty
syn region swiftAttributeArguments matchgroup=swiftAttributeArguments start="(" end=")" contains=swiftAttributeArgumentsNest,swiftIdentifier,swiftKeyword,@swiftLiteral,swiftOperator contained
syn region swiftAttributeArgumentsNest matchgroup=swiftAttributeArguments start="(" end=")" transparent contained
syn region swiftAttributeArgumentsNest matchgroup=swiftAttributeArguments start="\[" end="\]" transparent contained
syn region swiftAttributeArgumentsNest matchgroup=swiftAttributeArguments start="{" end="}" transparent contained

" Definitions {{{2

syn match swiftTypeDef /\<\%(class\|struct\|enum\|protocol\)\>[^{]*\ze{/ contains=TOP,@swiftDefs nextgroup=swiftTypeBody
syn region swiftTypeBody matchgroup=swiftTypeBody start="{" end="}" contained contains=TOP fold
syn cluster swiftDefs add=swiftTypeDef

syn region swiftOperatorDef start=/\<operator\_s\+\%(prefix\|postfix\)\>/ end="\ze{" contains=swiftOperatorDefKeywords,swiftOperator nextgroup=swiftOperatorEmptyBody
syn region swiftOperatorDef start="\<operator\_s\+infix\>" end="\ze{"  contains=swiftOperatorDefKeywords,swiftOperator nextgroup=swiftOperatorInfixBody
syn region swiftOperatorEmptyBody start="{" end="}" contained
syn region swiftOperatorInfixBody start="{" end="}" contained contains=swiftOperatorPrecedence,swiftOperatorAssociativity fold
syn match swiftOperatorDefKeywords /\<\%(operator\|prefix\|postfix\|infix\)\>/ contained
syn keyword swiftOperatorPrecedence contained nextgroup=swiftOperatorPrecedenceLevel skipwhite skipempty precedence
syn match swiftOperatorPrecedenceLevel contained /\d\+/
syn keyword swiftOperatorAssociativity contained nextgroup=swiftOperatorAssociativityValue skipwhite skipempty associativity
syn keyword swiftOperatorAssociativityValue contained left right none
syn cluster swiftDefs add=swiftOperatorDef

" Variables {{{2

syn match swiftVarDef /\<var\>[^{]*\ze{/ contains=TOP,swiftVarDef,@swiftDefs nextgroup=swiftVarBody
syn region swiftVarBody matchgroup=swiftVarBody start="{" end="}" fold contained contains=TOP,@swiftDefs,swiftVarBody
syn keyword swiftVarAttribute contained containedin=swiftVarBody nextgroup=swiftVarAttributeBlock skipwhite skipempty get
syn match swiftVarAttribute /\<\%(set\|willSet\|didSet\)\>/ contained containedin=swiftVarBody nextgroup=swiftVarAttributeArg,swiftVarAttributeBlock skipwhite skipempty
syn region swiftVarAttributeArg start="(" end=")" contained contains=swiftKeyword,@swiftLiteral,swiftIdentifier nextgroup=swiftVarAttributeBlock skipwhite skipempty
syn region swiftVarAttributeBlock matchgroup=swiftVarAttributeBlock start="{" end="}" contained contains=TOP,@swiftDefs fold

" Comments {{{2

syn region swiftCommentLine excludenl start="//" end="$" contains=@Spell oneline
syn region swiftCommentBlock matchgroup=swiftCommentBlockDelim start="/\*" end="\*/" contains=swiftCommentBlockNest,@Spell
syn region swiftCommentBlockNest matchgroup=swiftCommentBlockDelim start="/\*" end="\*/" contains=swiftCommentBlockNest,@Spell contained transparent

" Default highlighting {{{1

hi def link swiftKeyword Keyword
hi def link swiftType    Type

hi def link swiftInteger  Number
hi def link swiftFloat    Number

hi def link swiftString String
hi def link swiftStringEscapeError Error
hi def link swiftStringEscape Special
hi def link swiftInterpolationDelim Delimiter

hi def link swiftClosureCaptureListOwnership swiftKeyword

hi def link swiftOperatorDefKeywords swiftKeyword
hi def link swiftOperatorPrecedence swiftKeyword
hi def link swiftOperatorPrecedenceLevel swiftInteger
hi def link swiftOperatorAssociativity swiftKeyword
hi def link swiftOperatorAssociativityValue swiftKeyword

hi def link swiftAttribute          Macro
hi def link swiftAttributeArguments Macro

hi def link swiftVarAttribute swiftKeyword

hi def link swiftCommentLine  Comment
hi def link swiftCommentBlock swiftCommentLine
hi def link swiftCommentBlockDelim swiftCommentBlock

" }}}1

syn sync minlines=200
syn sync maxlines=500

let b:current_syntax = "swift"

" vim: set et sw=4 ts=4:
