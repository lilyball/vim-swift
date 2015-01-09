" File: autoload/swift/platform.vim
" Author: Kevin Ballard
" Description: Platform support for Swift
" Last Change: Jan 08, 2015

" Returns a dict containing the following keys:
" - platform - required, value is "macosx" or "iphonesimulator"
" - device - optional, name of the device to use. Device may not be valid.
function! swift#platform#detect()
    let dict = {}
    let check_file=1
    let iphoneos_platform_pat = '^i\%(phone\%(os\|sim\%(ulator\)\?\)\?\|pad\|os\)$'
    let macosx_platform_pat = '^\%(mac\)\?osx'
    for scope in [b:, w:, g:]
        if !has_key(dict, 'platform')
            let platform = get(scope, "swift_platform", "")
            if type(platform) == type("")
                if platform =~? iphoneos_platform_pat
                    let dict.platform = 'iphonesimulator'
                elseif platform =~? macosx_platform_pat
                    let dict.platform = 'macosx'
                endif
            endif
        endif
        if !has_key(dict, 'device')
            let device = get(scope, "swift_device", "")
            if type(device) == type("") && !empty(device)
                let dict.device = device
            endif
        endif
        if has_key(dict, 'platform') && has_key(dict, 'device')
            break
        endif
        if check_file
            let check_file = 0
            let limit = 128
            for scope in [b:, w:, g:]
                let value = get(scope, "swift_platform_detect_limit", "")
                if type(value) == type(0)
                    let limit = value
                    break
                endif
            endfor
            " look for a special comment of the form
            " // swift: platform=iphoneos
            " // swift: device=iPhone 6
            " or for an import of UIKit, AppKit, or Cocoa
            let commentnest = 0
            let autoplatform = ''
            for line in getline(1,limit)
                if line =~ '^\s*//\s*swift:'
                    let start = matchend(line, '^\s*//\s*swift:\s*')
                    let pat = '\(\w\+\)=\(\w\+\>\%(\s\w\+\>=\@!\)*\)'
                    while 1
                        let match = matchlist(line, pat, start)
                        if empty(match)
                            break
                        endif
                        let start += len(match[0])
                        if match[1] == 'platform' && !has_key(dict, 'platform')
                            if match[2] =~? iphoneos_platform_pat
                                let dict.platform = 'iphonesimulator'
                            elseif match[2] =~? macosx_platform_pat
                                let dict.platform = 'macosx'
                            endif
                        elseif match[1] == 'device' && !has_key(dict, 'device')
                            let dict.device = match[2]
                        endif
                    endwhile
                endif
                if has_key(dict, 'platform') && has_key(dict, 'device')
                    break
                endif
                if !empty(autoplatform)
                    continue
                endif
                if commentnest == 0
                    if line =~ '^\s*import\s\+UIKit\>'
                        let autoplatform = 'iphonesimulator'
                    elseif line =~ '^\s*import\s\+\%(AppKit\|Cocoa\)\>'
                        let autoplatform = 'macosx'
                    endif
                endif
                let start = 0
                while 1
                    let start = match(line, '/\*\|\*/', start)
                    if start < 0 | break | endif
                    if line[start:start+1] == '/*'
                        let commentnest+=1
                    elseif commentnest > 0
                        let commentnest-=1
                    else
                        " invalid syntax, cancel the whole line
                        break
                    endif
                endwhile
            endfor
        endif
    endfor
    if !has_key(dict, 'platform')
        if empty(autoplatform)
            " autodetect failed, assume macosx
            let dict.platform = 'macosx'
        else
            let dict.platform = autoplatform
        endif
    endif
    return dict
endfunction
