" File: syntax_checkers/swift/swift.vim
" Author: Kevin Ballard
" Description: Syntastic checker for Swift
" Last Change: June 23, 2014

if exists("g:loaded_syntastic_swift_swift_checker")
    finish
endif
let g:loaded_syntastic_swift_swift_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_swift_swift_IsAvailable() dict
    let exec = self.getExec()
    if exec =~ '^xcrun '
        call system('xcrun -find ' . exec[6:])
        return v:shell_error == 0
    endif
    return executable(exec)
endfunction

function! SyntaxCheckers_swift_swift_GetLocList() dict
    let sdk = syntastic#util#shescape(system('xcrun -show-sdk-path -sdk macosx')[:-2])
    " disable escaping on the exe
    let makeprg = self.makeprgBuild({
                \ 'exe': self.getExec(),
                \ 'args_before': '-sdk ' . sdk,
                \ 'args': '-parse'})

    let errorformat =
                \ '%E%f:%l:%c: error: %m,' .
                \ '%W%f:%l:%c: warning: %m,' .
                \ '%Z%\s%#^~%#,' .
                \ '%-G%.%#'

    return SyntasticMake({
                \ 'makeprg': makeprg,
                \ 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
            \ 'filetype': 'swift',
            \ 'name': 'swift',
            \ 'exec': 'xcrun swiftc'})

let &cpo = s:save_cpo
unlet s:save_cpo
