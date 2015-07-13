" File: swift/cache.vim
" Author: Kevin Ballard
" Description: In-memory cache for plist lookups.
" Last Change: Jul 12, 2015

if !exists('s:files')
    let s:files = {}
endif

" Usage:
"   swift#cache#read_plist_key({filename}, {key})
" Arguments:
"   {filename} - Path to the plist file to read.
"   {key} - A key, in the syntax accepted by PlistBuddy, to read.
" Returns:
"   A string with the results. If no such plist/key combo exists, the empty
"   string will be returned.
function! swift#cache#read_plist_key(filename, key)
    let l:file = get(s:files, a:filename, {})
    if empty(l:file)
        let s:files[a:filename] = l:file
    endif
    if has_key(l:file, a:key)
        return l:file[a:key]
    endif
    let l:result = swift#util#system(['/usr/libexec/PlistBuddy', '-c', 'Print '.a:key, a:filename])
    if l:result.status == 0 && !empty(l:result.output)
        let l:file[a:key] = l:result.output[0]
    else
        let l:file[a:key] = ''
    endif
    return l:file[a:key]
endfunction

" Usage:
"   swift#cache#clear_cache({filename}[, {key}])
" Arguments:
"   {filename} - Path to the plist file.
"   {key} - A key, in the syntax accepted by PlistBuddy.
" Description:
"   If just {filename} is given, clears the cache for the entire file. If both
"   {filename} and {key} are given, clears the cache for just that pair.
function! swift#cache#clear_cache(filename, ...)
    if has_key(s:files, a:filename)
        if a:0 > 1
            let l:file = s:files[a:filename]
            if has_key(l:file, a:1)
                unlet l:file[a:1]
            endif
        else
            unlet s:files[a:filename]
        endif
    endif
endfunction
