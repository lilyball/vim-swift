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

" Returns:
"   List of dictionaries with the following keys:
"     name: The device name
"     uuid: The device UUID
"     type: Device identifier, e.g. "com.apple.CoreSimulator.SimDeviceType.iPhone-6"
"     state: Device state, e.g. "Shutdown"
"     runtime: {
"       name: Runtime name, e.g. "iOS 8.2"
"       version: Runtime version, e.g. "8.2"
"       build: Runtime build, e.g. "12D5452a"
"       identifier: Runtime identifier, e.g. "com.apple.CoreSimulator.SimRuntime.iOS-8-2"
"     }
"
" If an error occurs with simctl, a message is echoed and {} is returned.
" Unavailable devices are not returned.
function! swift#platform#simDeviceInfo(...)
    let output = s:system('xcrun simctl list')
    if output.status
        redraw
        echohl ErrorMsg
        echom "Error: Shell command `xcrun simctl list` failed with error:"
        echohl None
        if has_key(output, 'stderr')
            for line in output.stderr
                echom line
            endfor
        else
            for line in output.stdout
                echom line
            endfor
        endif
        return {}
    endif

    let deviceTypes = {}
    let runtimes = {}
    let devices = []
    let state = 0
    let deviceRuntime = ''
    for line in output.stdout
        if line == ''
            continue
        endif
        if line == '== Device Types =='
            let state = 1
        elseif line == '== Runtimes =='
            let state = 2
        elseif line == '== Devices =='
            let state = 3
        elseif state == 1 " Device Types
            let matches = matchlist(line, '^\s*\(\w\&[^(]*\w\)\s\+(\([^)]*\))\s*$')
            if empty(matches)
                let state = -1
            else
                let deviceTypes[matches[1]] = matches[2]
            endif
        elseif state == 2 " Runtimes
            let matches = matchlist(line, '^\s*\(\w\&[^(]*\w\)\s\+(\([0-9.]\+\)\s*-\s*\([^)]\+\))\s\+(\([^)]*\))\s*$')
            if empty(matches)
                let state = -1
            else
                let runtimes[matches[1]] = {
                            \ 'name': matches[1],
                            \ 'version': matches[2],
                            \ 'build': matches[3],
                            \ 'identifier': matches[4]
                            \}
            endif
        elseif state == 3 " Devices
            if line =~ '^-- .* --$'
                let deviceRuntime = matchstr(line, '^-- \zs.*\ze --$')
            elseif empty(deviceRuntime)
                let state = -1
            elseif deviceRuntime =~? '^Unavailable:'
                " the runtime is unavailable, all devices in here will be
                " expected to similarly be unavailable.
            else
                let matches = matchlist(line, '^\s*\(\w\&[^(]*\w\)\s\+(\([^)]*\))\s\+(\([^)]*\))\%(\s\+(\([^)]*\))\)\?\s*$')
                if empty(matches)
                    let state = -1
                elseif matches[4] =~? '^unavailable\>'
                    " the device is unavailable
                else
                    call add(devices, {
                                \ 'name': matches[1],
                                \ 'uuid': matches[2],
                                \ 'state': matches[3],
                                \ 'runtime': deviceRuntime
                                \})
                endif
            endif
        else
            let state = -1
        endif
        if state == -1
            redraw
            echohl ErrorMsg
            echom "Error: Unexpected output from shell command `xcrun simctl list`"
            echohl None
            echom line
            return {}
        endif
    endfor
    for device in devices
        let device.type = get(deviceTypes, device.name, '')
        let device.runtime = get(runtimes, device.runtime, {})
    endfor
    return devices
endfunction

" Arguments:
"   {platform} - A platform dictionary as returned by swift#platform#detect()
" Returns:
"   A copy of {platform} augmented with a 'deviceInfo' key if relevant,
"   or {} if an error occurred (the error will be echoed).
function! swift#platform#getPlatformInfo(platform)
    if a:platform.platform == 'macosx'
        return copy(a:platform)
    elseif a:platform.platform == 'iphonesimulator'
        if empty(get(a:platform, 'device', {}))
            redraw
            echohl ErrorMsg
            echom "Error: No device specified for platform iphonesimulator"
            echohl None
            echo "Please set b:swift_device or g:swift_device and try again."
            if s:hasUnite()
                echo "Type `"
                echohl PreProc
                echon ":Unite swift/device"
                echohl None
                echon "` to select a device."
            endif
            return []
        endif
        let allDeviceInfo = swift#platform#simDeviceInfo()
        if empty(allDeviceInfo)
            return []
        endif
        let deviceInfo={}
        let found=0
        for deviceInfo in allDeviceInfo
            if deviceInfo.name ==? a:platform.device
                let found=1
                break
            endif
        endfor
        if !found
            redraw
            echohl ErrorMsg
            echom "Error: Device '".a:platform.device."' does not exist."
            echohl None
            return []
        endif
        return extend(copy(a:platform), {'deviceInfo': deviceInfo})
    else
        throw "swift: unexpected platform ".a:platform.platform
    endif
endfunction

" Arguments:
"   {platform} - A platform info dictionary as returned by
"                swift#platform#getPlatformInfo()
" Returns:
"   A List of arguments to be passed to swiftc. If the device is invalid
"   or another error occurred, an error is echoed and [] is returned.
function! swift#platform#argsForPlatformInfo(platformInfo)
    if a:platformInfo.platform == 'macosx'
        return ['-sdk', swift#platform#sdkPath(a:platformInfo.platform)]
    elseif a:platformInfo.platform == 'iphonesimulator'
        let deviceInfo = a:platformInfo.deviceInfo
        if index(g:swift#platform#32bitDevices, deviceInfo.type) >= 0
            let arch = 'i386'
        else
            let arch = 'x86_64'
        endif
        let target = arch.'-apple-ios'.deviceInfo.runtime.version
        return ['-sdk', swift#platform#sdkPath(a:platformInfo.platform), '-target', target]
    else
        throw "swift: unexpected platform ".a:platformInfo.platform
    endif
endfunction

function! swift#platform#sdkPath(sdkname)
    let sdk = system('xcrun -show-sdk-path -sdk ' . a:sdkname)
    if sdk =~ '\n'
        let sdk = sdk[:-2]
    endif
    return sdk
endfunction

" Arguments:
"   {exepath} - Path to an executable
"   {platformInfo} - Platform info
" Returns:
"   A string that can be passed to ! to execute the binary.
function! swift#platform#commandStringForExecutable(exepath, platformInfo)
    if a:platformInfo.platform ==# 'iphonesimulator'
        let path = 'xcrun simctl spawn '
        let path .= shellescape(a:platformInfo.deviceInfo.uuid)
        return path.' '.shellescape(a:exepath)
    else
        return shellescape(a:exepath)
    endif
endfunction

" We can't easily test what architectures a device supports
" so we're just blacklisting the known 32-bit devices.
let swift#platform#32bitDevices = [
            \ 'com.apple.CoreSimulator.SimDeviceType.iPhone-4s',
            \ 'com.apple.CoreSimulator.SimDeviceType.iPhone-5',
            \ 'com.apple.CoreSimulator.SimDeviceType.iPad-2',
            \ 'com.apple.CoreSimulator.SimDeviceType.iPad-Retina'
            \]

function! s:hasUnite()
    if !exists('*unite#version')
        try
            call unite#version()
        catch
        endtry
    endif
    return exists('*unite#version')
endfunction

if !exists('*vimproc#version')
    try
        call vimproc#version()
    catch
    endtry
endif
if exists('*vimproc#version')
    function! s:system(cmd)
        let file = vimproc#popen3(a:cmd)
        let stdout = file.stdout.read_lines()
        let stderr = file.stderr.read_lines()
        let status = file.waitpid()
        if status[0] == 'exit'
            let code = status[1]
        else
            " presumably a signal
            let code = 128 + status[1]
        endif
        return { 'stdout': stdout, 'stderr': stderr, 'status': code }
    endfunction
else
    function! s:system(cmd)
        " we can't split output and error without vimproc
        let output = system(a:cmd)
        let status = v:shell_error
        let lines = split(output, '\n')
        return { 'stdout': lines, 'status': status }
    endfunction
endif
