" vim: set nospell:

" user vim directory
let g:vim_dir = has('unix') ? expand("~/.vim") : substitute(expand("~/vimfiles"), "\\", "/", "g")

" load functions file
execute printf('source %s/vimrc.functions', vim_dir)

" config files in needed order
let config_files = [ 'vimrc.config', 'vimrc.maps', 'vimrc.plugs', 'vimrc.plugs.functions', 'vimrc.plugs.config', 'vimrc.plugs.maps']

" plugin directory
let g:plugged_dir = printf('%s/plugged', vim_dir)

" on first run plugged dir doesn't exist
if !isdirectory(g:plugged_dir)

    silent call InstallPluginManager()
    " load file with plugin list

    execute printf('source %s/vimrc.plugs', vim_dir)

    " remove vimrc.plugs from list (don't load again) only on first run
    call filter(config_files, 'v:val !~# "^vimrc\.plugs$"')

    silent call InstallPlugins()

    if has('unix') && !has('win32unix')
        let fonts_url = 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts'
        let font_path[0] = 'DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf'
        let font_path[1] = 'FiraMono/Regular/complete/Fura%20Mono%20Regular%20Nerd%20Font%20Complete%20Mono.otf'

        silent call InstallFontList(patched_fonts_url, font_path)

        call UpdateFontCache()

    endif

    if PlugLoaded('coc.nvim')

        let coc_extension_list = [ 'coc-phpls' ]

        " VimEnter is triggered after source config
        autocmd VimEnter * call InstallCocExtensionList(coc_extension_list)

    endif
endif

call SourceFileList(config_files)
