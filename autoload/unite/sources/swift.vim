" File: unite/sources/swift.vim
" Author: Kevin Ballard
" Description: Unite sources file for Swift
" Last Change: Jan 13, 2015

let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#swift#define() "{{{
    return s:source
endfunction "}}}

let s:source = {
            \ 'name': 'swift/device',
            \ 'hooks': {},
            \ 'action_table': {},
            \ 'default_action': 'set_global',
            \ 'is_grouped': 1,
            \ 'description': 'iOS Simulator devices for use with Swift'
            \}

function! s:source.gather_candidates(args, context) "{{{
    let devices = swift#platform#simDeviceInfo()
    return map(copy(devices), "{ 'word': v:val.name, 'group': v:val.runtime.name }")
endfunction "}}}

function! s:source.hooks.on_post_filter(args, context) "{{{
    let g:swift_unite_candidates = deepcopy(a:context.candidates)
    for candidate in a:context.candidates
        if get(candidate, 'is_dummy')
            " group name
            let candidate.abbr =
                        \ '-- ' . candidate.word . ' --'
        else
            let candidate.abbr =
                        \ '  ' . candidate.word
        endif
    endfor
endfunction "}}}

" Actions {{{

let s:source.action_table.set_buffer = {
            \ 'description': 'select the iOS Simulator device (buffer-local)',
            \ 'is_selectable': 0
            \}
function! s:source.action_table.set_buffer.func(candidate) "{{{
    let b:swift_device = a:candidate.word
endfunction "}}}

let s:source.action_table.set_global = {
            \ 'description': 'select the iOS Simulator device (global)',
            \ 'is_selectable': 0
            \}
function! s:source.action_table.set_global.func(candidate) "{{{
    let g:swift_device = a:candidate.word
endfunction "}}}

" }}}

let &cpo = s:save_cpo
unlet s:save_cpo
