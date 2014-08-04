" File: autoload/swift.vim
" Author: Kevin Ballard
" Description: Helper functions for Swift
" Last Change: Aug 04, 2014

" Run {{{1

function! swift#Run(bang, args)
	let args = s:ShellTokenize(a:args)
	if a:bang
		let idx = index(l:args, '--')
		if idx != -1
			let swift_args = idx == 0 ? [] : l:args[:idx-1]
			let args = l:args[idx+1:]
		else
			let swift_args = l:args
			let args = []
		endif
	else
		let swift_args = []
	endif

	let b:swift_last_swift_args = l:swift_args
	let b:swift_last_args = l:args

	call s:WithPath(function("s:Run"), swift_args, args)
endfunction

function! s:Run(path, swift_args, args)
	try
		let exepath = tempname()
		if has('win32')
			let exepath .= '.exe'
		endif

		let sdk = system('xcrun -show-sdk-path -sdk macosx')[:-2]
		let swift_args = ['-sdk', sdk, a:path, '-o', exepath] + a:swift_args

		let swift = 'xcrun swiftc'

		let output = system(swift . " " . join(swift_args))
		if output != ''
			echohl WarningMsg
			echo output
			echohl None
		endif
		if !v:shell_error
			exe '!' . shellescape(exepath) . " " . join(a:args)
		endif
	finally
		if exists("exepath")
			silent! call delete(exepath)
		endif
	endtry
endfunction

" Utility functions {{{1

function! s:WithPath(func, ...)
	try
		let save_write = &write
		set write
		let path = expand('%')
		let pathisempty = empty(path)
		if pathisempty || !save_write
			" use a temporary file named 'unnamed.swift' inside a temporary
			" directory. This produces better error messages
			let tmpdir = tempname()
			call mkdir(tmpdir)

			let save_cwd = getcwd()
			silent exe 'lcd' tmpdir

			let path = 'unnamed.swift'

			let save_mod = &mod
			set nomod

			silent exe 'keepalt write! ' . path
			if pathisempty
				silent keepalt 0file
			endif
		else
			update
		endif

		call call(a:func, [path] + a:000)
	finally
		if exists("save_mod")   | let &mod = save_mod          | endif
		if exists("save_write") | let &write = save_write      | endif
		if exists("save_cwd")   | silent exe 'lcd' save_cwd    | endif
		if exists("tmpdir")     | silent call s:RmDir(tmpdir)  | endif
	endtry
endfunction

function! swift#AppendCmdLine(text)
	call setcmdpos(getcmdpos())
	let cmd = getcmdline() . a:text
	return cmd
endfunction

" Tokenize the String according to shell parsing rules
function! s:ShellTokenize(text)
	let pat = '\%([^ \t\n''"]\+\|\\.\|''[^'']*\%(''\|$\)\|"\%(\\.\|[^"]\)*\%("\|$\)\)\+'
	let start = 0
	let tokens = []
	while 1
		let pos = match(a:text, pat, start)
		if l:pos == -1
			break
		endif
		let end = matchend(a:text, pat, start)
		call add(tokens, strpart(a:text, pos, end-pos))
		let start = l:end
	endwhile
	return l:tokens
endfunction

function! s:RmDir(path)
	" sanity check; make sure it's not empty, /, or $HOME
	if empty(a:path)
		echoerr 'Attempted to delete empty path'
		return 0
	elseif a:path == '/' || a:path == $HOME
		echoerr 'Attempted to delete protected path: ' . a:path
		return 0
	endif
	silent exe "!rm -rf " . shellescape(a:path)
endfunction

" }}}1

" vim: set noet sw=4 ts=4:
