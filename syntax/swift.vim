" Vim syntax file
" Language:    Swift
" Maintainer:  Kevin Ballard
" Last Change: Jul 25, 2014

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

let s:fold = has("folding") ? get(b:, 'swift_no_fold', get(g:, 'swift_no_fold')) : 0
if s:fold == 2
    setlocal foldmethod<
    setlocal foldlevel<
elseif s:fold == 1
    setlocal foldmethod=syntax
    setlocal foldlevel<
else
    setlocal foldmethod=syntax
    setlocal foldlevel=999
endif

" Syntax definitions {{{1

" @swiftDefs are definitions that cannot occur inside closures/functions
syn cluster swiftDefs contains=NONE
" @swiftItems are things that cannot be found in an expression
syn cluster swiftItems contains=@swiftDefs

" Define a few lists that we're going to need later
" These are all regex snippets, with implied word boundaries
let s:declarations = ['class', 'struct', 'enum', 'protocol', 'extension',
            \'var', 'func', 'subscript', 'init', 'deinit', 'operator']
let s:modifiers = ['final', 'lazy', 'optional', 'required', 'override',
            \'dynamic', 'prefix', 'infix', 'postfix', 'convenience', 'weak',
            \'unowned', 'mutating', 'nonmutating']
let s:modifiers_suffixed = ['unowned\_s*(safe)', 'unowned\_s*(unsafe)']
let s:accessControl = ['public', 'private', 'internal']

let s:declarations_re = '\<\%('.join(s:declarations, '\|').'\)\>'
let s:modifiers_re = '\<\%('.join(map(s:modifiers, 'v:val."\\>"'), '\|')
            \.'\|'.join(s:modifiers_suffixed, '\|').'\)'
let s:accessControl_re = '\<\%('.join(s:accessControl, '\|').'\)\>'
" inclues an optional parenthesized suffix
let s:accessControl2_re = s:accessControl_re.'\%(\_s*(\_[^)]*)\)\='
" includes (optionally-suffixed) access conrol
let s:modifiers2_re = '\%('.s:modifiers_re.'\|'.s:accessControl2_re.'\)'

" Identifiers {{{2

syn match swiftIdentifier /\<\i\+\>/ display transparent contains=NONE

" Keywords {{{2

" Declarations {{{3

" Keywords have priority over other matches, so use syn-match for the few
" keywords that we want to reuse in other matches.
exe 'syn match swiftKeyword /'.s:declarations_re.'/'

" Access control {{{3

" Define the keywords once because they're keywords, and again for @swiftItems
" to support the (set) modifier.

exe 'syn keyword swiftKeyword' join(s:accessControl)

exe 'syn keyword swiftAccessControl' join(s:accessControl) 'nextgroup=swiftAccessControlScope skipwhite skipempty'
exe 'syn match swiftAccessControlScope /(\_s*set\_s*)\ze\%(\_s*'.s:modifiers2_re.'\)*\_s*\<\%(var\|subscript\)\>/ contained skipwhite skipempty'
syn cluster swiftItems add=swiftAccessControl

" Other keywords {{{3

syn keyword swiftKeyword import let
syn keyword swiftKeyword static typealias
syn keyword swiftKeyword break case continue default do else fallthrough if in
syn keyword swiftKeyword for return switch where while
syn keyword swiftKeyword as dynamicType is super self Self
syn keyword swiftKeyword __COLUMN__ __FILE__ __FUNCTION__ __LINE__

" Undocumented keywords {{{3

syn keyword swiftKeyword new

" Special types {{{3

syn match swiftKeyword /\.\@1<=\%(Type\|Protocol\)\>/ display

" Built-in types {{{2
" This is just the types that represent primitives or other commonly-used
" types, not everything that exists in Swift.

" Primitive types
syn keyword swiftType Int Int8 Int16 Int32 Int64 Word IntMax
syn keyword swiftType UInt UInt8 UInt16 UInt32 UInt64 UWord UIntMax
syn keyword swiftType Double Float Float80
syn keyword swiftType Bool Bit

" Containers
syn keyword swiftType Array Dictionary
syn keyword swiftType Optional ImplicitlyUnwrappedOptional
syn keyword swiftType ContiguousArray HeapBuffer

" String-related types
syn keyword swiftType String UTF8 UTF16 UTF32 UnicodeScalar Character

" Ranges/intervals
syn keyword swiftType Range ClosedInterval HalfOpenInterval
syn keyword swiftType SrideTo StrideThrough

" Pointers
syn keyword swiftType UnsafePointer UnsafeMutablePointer
syn keyword swiftType AutoreleasingUnsafeMutablePointer
syn keyword swiftType COpaquePointer CFunctionPointer
syn keyword swiftType UnsafeBufferPointer UnsafeMutableBufferPointer

" Sequences/Collections/Generators
syn keyword swiftType IndexingGenerator LazySequence LazyBidirectionalCollection LazyRandomAccessCollection
syn keyword swiftType FilterCollectionView
syn keyword swiftType BidirectionalReverseView RandomAccessReverseView
syn keyword swifTType UnsafeBufferPointerGenerator

" Miscellaneous
syn keyword swiftType ObjectIdentifier CVarArgType

" Protocols
syn keyword swiftProtocol Any AnyObject AnyClass
syn keyword swiftProtocol ForwardIndexType BidirectionalIndexType RandomAccessIndexType
syn keyword swiftProtocol Comparable Hashable Equatable Strideable Reflectable
syn keyword swiftProtocol NilLiteralConvertible DictionaryLiteralConvertible ArrayLiteralConvertible IntegerLiteralConvertible
syn keyword swiftProtocol Streamable Printable DebugPrintable
syn keyword swiftProtocol UnicodeCodecType
syn keyword swiftProtocol IntegerType UnsignedIntegerType BooleanType
syn keyword swiftProtocol SignedNumberType AbsoluteValuable IntervalType
syn keyword swiftProtocol CollectionType SequenceType GeneratorType
syn keyword swiftProtocol RawOptionSetType BitwiseOperationsType
syn keyword swiftProtocol OutputStreamType
syn keyword swiftProtocol ExtensibleCollectionType

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

syn region swiftString start=/"/ end=/"/ end=/$/ keepend oneline contains=swiftStringEscape,swiftStringEscapeError,swiftInterpolation,@Spell
syn match swiftStringEscapeError display contained /\\./
syn match swiftStringEscape contained /\\[0\\tnr"']/ extend
syn match swiftStringEscapeError display contained /\\\%(x\x\{,2}\|u\x\{,4}\|U\x\{,8}\)/
syn region swiftStringEscape matchgroup=swiftStringEscapeUnicode start="\\u{" end=/}\|\ze"/ display contained contains=swiftStringEscapeUnicodeError keepend
syn region swiftStringEscapeUnicodeError start=/\_X\|{\@1<=\x\{8}\zs\_[^}]/ end=/}/ display contained

syn region swiftInterpolation matchgroup=swiftInterpolationDelim start=/\\(/ end=/)/ contained oneline contains=TOP

" Boolean literals {{{3

syn keyword swiftBoolean true false

" Nil literal {{{3

syn keyword swiftNil nil

" Built-in enum variants {{{3

syn match swiftEnumLiteral /\.\@1<=\%(Some\|None\)/

" Miscellaneous {{{2

syn match swiftOperator display ,\%(//\|/\*\)\@![-/=+!*%<>&|^~.]\+, transparent contains=NONE

syn region swiftBalancedParens matchgroup=swiftBalancedParens start="(" end=")" transparent contains=TOP,@swiftItems

syn region swiftClosure matchgroup=swiftClosure start="{" end="}" contains=swiftClosureCaptureList,swiftClosureSimple fold
syn region swiftClosureSimple start='[^}[:space:]]' end='\ze}' transparent contained contains=TOP,@swiftDefs
syn region swiftClosureCaptureList start="\[" end="\]" contained contains=TOP,@swiftDefs nextgroup=swiftClosureSimple skipwhite skipempty
syn match swiftClosureCaptureListOwnership /\<\%(strong\>\|weak\>\|unowned\%((safe)\|(unsafe)\|\>\)\)/ contained containedin=swiftClosureCaptureList
syn match swiftPlaceholder /\$\d\+/ contained containedin=swiftClosureSimple

syn match swiftAttribute /@\i\+/ nextgroup=swiftAttributeArguments skipwhite skipempty
syn region swiftAttributeArguments matchgroup=swiftAttributeArguments start="(" end=")" contains=TOP,@swiftItems contained
syn region swiftAttributeArgumentsNest matchgroup=swiftAttributeArguments start="(" end=")" transparent contained containedin=swiftAttributeArguments
syn region swiftAttributeArgumentsNest matchgroup=swiftAttributeArguments start="\[" end="\]" transparent contained containedin=swiftAttributeArguments

syn region swiftAttributeArgumentsNest matchgroup=swiftAttributeArguments start="{" end="}" transparent contained containedin=swiftAttributeArguments

" Declarations {{{2

" Types (struct/class/etc) {{{3
syn match swiftTypeDef /\<\%(class\|struct\|enum\|protocol\|extension\)\>\_[^{]*\ze{/ contains=TOP,@swiftItems nextgroup=swiftTypeBody
syn region swiftTypeBody matchgroup=swiftTypeBody start="{" end="}" contained contains=TOP fold
syn cluster swiftDefs add=swiftTypeDef

" Operators {{{3
syn match swiftOperatorDef /\<operator\_s*[^[:space:]]\+\_s*\ze{/ contains=swiftKeyword,swiftOperator nextgroup=swiftOperatorBody
syn region swiftOperatorBody start="{" end="}" contained contains=swiftOperatorPrecedence,swiftOperatorAssociativity,swiftOperatorAssignment fold
syn keyword swiftOperatorPrecedence contained nextgroup=swiftOperatorPrecedenceLevel skipwhite skipempty precedence
syn match swiftOperatorPrecedenceLevel contained /\d\+/
syn keyword swiftOperatorAssociativity contained nextgroup=swiftOperatorAssociativityValue skipwhite skipempty associativity
syn keyword swiftOperatorAssociativityValue contained left right none
syn keyword swiftOperatorAssignment contained assignment
syn cluster swiftDefs add=swiftOperatorDef

" Functions {{{3

syn match swiftFuncDef /\<func\>\_s*[^[:space:]();]\+\_s*\ze(/ contains=TOP,@swiftItems nextgroup=swiftFuncArgs
syn match swiftSpecialFuncDef /\<\%(init\|deinit\)\>\_s*\ze(/ contains=swiftKeyword nextgroup=swiftFuncArgs
syn region swiftFuncArgs matchgroup=swiftFuncArgs start="(" end=")" contained contains=TOP,@swiftItems transparent nextgroup=swiftFuncBody skipwhite skipempty
syn region swiftFuncBody matchgroup=swiftFuncBody start="{" end="}" contained contains=TOP,@swiftDefs fold
syn keyword swiftFuncArgInout contained containedin=swiftFuncArgs inout
syn cluster swiftItems add=swiftFuncDef
syn cluster swiftDefs add=swiftSpecialFuncDef

" Subscripts {{{3

syn match swiftSubscriptDef /\<subscript\>\_[^{]*\ze{/ contains=TOP,@swiftItems nextgroup=swiftSubscriptBody
syn region swiftSubscriptBody matchgroup=swiftSubscriptBody start="{" end="}" fold contained contains=TOP,@swiftDefs
syn keyword swiftSubscriptAttribute contained containedin=swiftSubscriptBody nextgroup=swiftSubscriptAttriuteBlock skipwhite skipempty get
syn match swiftSubscriptAttribute /\<set\>/ contained containedin=swiftSubscriptBody nextgroup=swiftSubscriptAttributeArg,swiftSubscriptAttriuteBlock skipwhite skipempty
syn match swiftSubscriptAttribute /\<\%(mutating\|nonmutating\)\>\ze\_s*\<\%(get\|set\)\>/ contained containedin=swiftSubscriptBody nextgroup=swiftSubscriptAttribute skipwhite skipempty
syn region swiftSubscriptAttributeArg matchgroup=swiftSubscriptAttributeArg start="(" end=")" contained contains=TOP,@swiftItems nextgroup=swiftSubscriptAttributeBlock skipwhite skipempty
syn region swiftSubscriptAttributeBlock matchgroup=swiftSubscriptAttributeBlock start="{" end="}" contained contains=TOP,@swiftDefs fold
syn cluster swiftDefs add=swiftSubscriptDef

" Variables {{{3

syn match swiftVarDef /\<var\>\_[^{=]*\ze{/ contains=TOP,swiftVarDef,@swiftDefs nextgroup=swiftVarBody
syn region swiftVarBody matchgroup=swiftVarBody start="{" end="}" fold contained contains=TOP,@swiftDefs
syn keyword swiftVarAttribute contained containedin=swiftVarBody nextgroup=swiftVarAttributeBlock skipwhite skipempty get
syn match swiftVarAttribute /\<\%(set\|willSet\|didSet\)\>/ contained containedin=swiftVarBody nextgroup=swiftVarAttributeArg,swiftVarAttributeBlock skipwhite skipempty
syn match swiftVarAttribute /\<\%(mutating\|nonmutating\)\>\ze\_s*\<\%(get\|set\|willSet\|didSet\)\>/ contained containedin=swiftVarBody nextgroup=swiftVarAttribute skipwhite skipempty
syn region swiftVarAttributeArg matchgroup=swiftVarAttributeArg start="(" end=")" contained contains=TOP,@swiftItems nextgroup=swiftVarAttributeBlock skipwhite skipempty
syn region swiftVarAttributeBlock matchgroup=swiftVarAttributeBlock start="{" end="}" contained contains=TOP,@swiftDefs fold
syn cluster swiftItems add=swiftVarDef

" Modifiers {{{3

exe 'syn match swiftDeclarationModifier /'.s:modifiers_re.'\ze\%(\_s*'.s:modifiers2_re.'\)*\_s*'.s:declarations_re.'/'
syn cluster swiftItems add=swiftDeclarationModifier

" Comments {{{2

syn region swiftCommentLine excludenl start="//" end="$" contains=@swiftCommentLineMarker,@Spell oneline
syn region swiftCommentBlock matchgroup=swiftCommentBlockDelim start="/\*" end="\*/" contains=swiftCommentBlockNest,@swiftCommentBlockMarker,@Spell keepend
syn region swiftCommentBlockNest matchgroup=swiftCommentBlockDelim start="/\*" end="\*/" contains=swiftCommentBlockNest,@swiftCommentBlockMarker,@Spell contained keepend extend

syn region swiftDocCommentLine excludenl start="///" end="$" contains=@swiftCommentLineMarker,@Spell oneline
syn region swiftDocCommentBlock matchgroup=swiftDocCommentBlockDelim start="/\*\*" end="\*/" contains=swiftCommentBlockNest,@swiftCommentBlockMarker,@Spell keepend

" it seems the markers don't care about word boundaries, only that the literal
" substring matches
syn match swiftCommentTodo /TODO:\|FIXME:/ contained
" for MARK: we want to highlight the rest of the line as well. TODO: and
" FIXME: actually use the rest of the line too, but marks are used for
" separation and should be more distinct
syn region swiftCommentLineMark excludenl start=/MARK:/ end=/$/ contained contains=@Spell oneline
syn cluster swiftCommentLineMarker contains=swiftCommentTodo,swiftCommentLineMark
syn region swiftCommentBlockMark excludenl start=/MARK:/ end=/$/ end=,\ze/\*, contained contains=@Spell oneline
syn cluster swiftCommentBlockMarker contains=swiftCommentTodo,swiftCommentBlockMark

" Default highlighting {{{1

hi def link swiftKeyword Keyword
hi def link swiftType    Type
hi def link swiftProtocol swiftType

hi def link swiftAccessControl      Keyword
hi def link swiftAccessControlScope swiftAccessControl

hi def link swiftLiteral  Number
hi def link swiftInteger  swiftLiteral
hi def link swiftFloat    swiftLiteral
hi def link swiftBoolean  swiftLiteral
hi def link swiftNil      swiftKeyword
hi def link swiftEnumLiteral swiftLiteral

hi def link swiftString String
hi def link swiftStringEscapeError Error
hi def link swiftStringEscape Special
hi def link swiftStringEscapeUnicode swiftStringEscape
hi def link swiftStringEscapeUnicodeError swiftStringEscapeError
hi def link swiftInterpolationDelim Delimiter

hi def link swiftClosureCaptureListOwnership swiftKeyword
hi def link swiftPlaceholder Identifier

hi def link swiftAttribute          Macro
hi def link swiftAttributeArguments Macro

hi def link swiftOperatorDefKeywords swiftKeyword
hi def link swiftOperatorPrecedence swiftKeyword
hi def link swiftOperatorPrecedenceLevel swiftInteger
hi def link swiftOperatorAssociativity swiftKeyword
hi def link swiftOperatorAssociativityValue swiftKeyword
hi def link swiftOperatorAssignment swiftKeyword

hi def link swiftFuncArgInout swiftKeyword

hi def link swiftSubscriptAttribute swiftKeyword
hi def link swiftVarAttribute swiftKeyword

hi def link swiftDeclarationModifier swiftKeyword

hi def link swiftCommentLine  Comment
hi def link swiftCommentBlock swiftCommentLine
hi def link swiftCommentBlockDelim swiftCommentBlock
hi def link swiftCommentBlockNest swiftCommentBlock

hi def link swiftDocCommentLine SpecialComment
hi def link swiftDocCommentBlock swiftDocCommentLine
hi def link swiftDocCommentBlockDelim swiftDocCommentBlock

hi def link swiftCommentTodo Todo
hi def link swiftCommentLineMark PreProc
hi def link swiftCommentBlockMark PreProc

" }}}1

syn sync minlines=200
syn sync maxlines=500

let b:current_syntax = "swift"

" vim: set et sw=4 ts=4:
