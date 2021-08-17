if exists("g:loaded_utils")
    finish
endif

let g:loaded_utils = 1

" Restart vim on linux
function utils#RestartVimLinux()
    " command to get vim plus arguments (e.g. vim -O file1 file2 ...)
    let get_vim_args_cmd = printf("ps -o command= -p %s", getpid())

    " get command output
    let start_vim_cmd = system(get_vim_args_cmd)

    " command to sleep 1 second, start vim with args and finally clear screen on exit
    let schedule_restart_cmd = printf('!sleep 1 && %s', start_vim_cmd)

    " execute command
    execute schedule_restart_cmd

    " clean terminal
    execute "!clear"

    " exit vim
    :qall!
endfunction

" Check if is linux OS
function utils#IsLinux()
    " cygwin and mac also return true to has('unix')
    return has('unix') && !has('win32unix') && !has('macunix')
endfunction

" Check if is Windows on 32 or 64 bits
function utils#IsWindows()
    return has('win32') || has('win64')
endfunction

" Return full path of viminfo file, create the file if not exists
function utils#GetVimInfoFile()
    " check if neovim or vim
    let file_name = has('nvim') ? 'nviminfo' : 'viminfo'

    " full file path
    let full_path = utils#PathPrintf("%s/%s", g:vim_dir, file_name)

    if !filereadable(full_path)
        " command to create the file, on linux: touch, on windows: echo
        let create_file_cmd = has('unix') ? "touch" : "echo '' >"

        silent execute printf("!%s %s", create_file_cmd, full_path)
    endif

    " Return escaped string to use with viminfo option
    return substitute(full_path, '\', '/', "g")
endfunction

" Get directory for backup, undodir,swap and view, create directory if not exists
function utils#GetDirectoryFor(option)

    let directories = {'backupdir' : 'backup', 'undodir' : 'undo', 'directory' : 'swap', 'viewdir' : 'view'}

    if !has_key(directories, a:option)
        return printf("%s_is_no_valid", a:option)
    endif

    " let directory_path = printf("%s/%s", g:vim_dir, directories[a:option])
    let directory_path = utils#PathPrintf("%s/%s", g:vim_dir, directories[a:option])

    " if directory doesn't exists create it
    if !isdirectory(directory_path)
        silent execute printf("!mkdir %s", directory_path)
    endif

    return directory_path
endfunction

" Load(source) list of files
function utils#SourceFileList(file_list)
    for file in a:file_list
        execute printf('source %s/%s', g:vim_dir, file)
    endfor
endfunction

" Return git tree root if exists, otherwise return empty string
function utils#GetGitRoot()
    " {{{ command description
    "   git :               Git command
    "   rev-parse :         Is an ancillary plumbing command primarily used for manipulation.
    "   --show-toplevel :   Show the path of the top-level directory of the working tree.
    "   2> /dev/null :      if not working tree git report and error, discard it
    " }}}
    let get_git_root_cmd = 'git rev-parse --show-toplevel 2> /dev/null'

    " execute command
    let cmd_output = system(get_git_root_cmd)

    " return command output
    return cmd_output[:-2] "[:-2] : Remove last byte from the string (^@)
endfunction

" Return custom fold text (set with 'foldtext' option)
function utils#MyFoldText()
    " number of lines of current fold
    let line_count = v:foldend - v:foldstart + 1

    " singular/plural
    let singular_plural = (line_count == 1) ? 'line' : 'lines'

    " line to show when is not a function fold
    let first_no_empty_line = ''

    " iterate over all fold lines
    for i in range(v:foldstart, v:foldend)
        let current_line = copy(getline(i))

        " is a function fold: return function signature
        if current_line =~  '^ *function.*\(.*\)'
            return printf('+ %s -> %s %s ', current_line, line_count, singular_plural)
        endif

        " if not a function fold: get text of first line with text
        if ((current_line =~ '.*[a-zA-Z0-9]\+.*') && (first_no_empty_line == ''))
            let first_no_empty_line = current_line
        endif
    endfor

    " remove fold marks '{', comment mark '"' and white spaces
    let clean_line = substitute(first_no_empty_line, '\v( *[\{]{3} *)| *" *', '', "g")

    " if not a function return first no empty line
    return printf('+ %s -> %s %s', clean_line, line_count, singular_plural)
endfunction

" Return 1 if plugin is loaded, otherwise return 0
function utils#PlugLoaded(name)

    " plugin manager default dir
    let plugged_dir = printf('%s/plugged/%s', expand('~/.vim'), a:name)

    " name is dir/plugin name and exists on runtimepath
    return isdirectory(plugged_dir) && match(&runtimepath, a:name) != -1
endfunction

" Return path with backslashes on windows and slashes with unix-like OS's
function! utils#PathPrintf(format, ...)
    let function_name = "utils#PrintPath()"
    let text = a:format
    let arguments = copy(a:000)

    for i in range(0, len(arguments) - 1)
        if match(text, '%s') > -1
            let text = substitute(text, '%s', escape(remove(arguments,0), '\') , "")
        endif
    endfor

    if match(text, '%s') > -1
        echoerr printf("Insufficient arguments for %s", function_name)
        return ""
    endif

    if len(arguments) > 0
        echoerr printf("Too many arguments to %s", function_name)
        return ""
    endif

    return utils#IsWindows() ? substitute(text, '/', '\', "g") : text
endfunction
