" File: syntax_checkers/swift/swiftc.vim
" Author: Kevin Ballard
" Description: Syntastic checker for Swift
" Last Change: Feb 16, 2015

if exists("g:loaded_syntastic_swift_swiftc_checker")
    finish
endif
let g:loaded_syntastic_swift_swiftc_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! s:getExec(dict, fallback, ...)
    let exec = a:dict.getExec()
    if exec =~? '^\%(xcrun\s\+\)\?swiftc\s*$'
        return call(function('swift#swiftc'), a:000)
    endif
    return a:fallback ? a:dict.getExec() : ''
endfunction

function! SyntaxCheckers_swift_swiftc_IsAvailable() dict
    let exec = s:getExec(self, 0, '-find')
    if !empty(exec)
        call system(exec)
        return v:shell_error == 0
    endif
    let exec = self.getExec()
    return executable(exec)
endfunction

function! SyntaxCheckers_swift_swiftc_GetLocList() dict
    let platformInfo = swift#platform#getPlatformInfo(swift#platform#detect())
    if empty(platformInfo)
        return []
    endif
    let args = swift#platform#argsForPlatformInfo(platformInfo)

    " disable escaping on the exe
    let makeprg = self.makeprgBuild({
                \ 'exe': s:getExec(self, 1),
                \ 'args_before': args,
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
            \ 'name': 'swiftc',
            \ 'exec': 'xcrun swiftc'})

let &cpo = s:save_cpo
unlet s:save_cpo
