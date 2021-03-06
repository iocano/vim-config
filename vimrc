" vim: set nospell:

let g:vim_dir = expand('~/.vim')

source ~/.vim/vimrc.config
source ~/.vim/vimrc.maps

let s:plug_file = printf("%s/autoload/plug.vim", g:vim_dir)
if !filereadable(s:plug_file) | silent call install#PluginManager() | endif

source ~/.vim/vimrc.plugins

let s:plugged_dir = printf("%s/plugged", g:vim_dir)
if !isdirectory(s:plugged_dir) | silent call install#Plugins() | endif

if utils#PlugLoaded('coc.nvim')
    " vim coc grab this variable and install the extensions
    let g:coc_global_extensions = ['coc-phpls', 'coc-json']
endif

source ~/.vim/vimrc.plugins.functions
source ~/.vim/vimrc.plugins.config
source ~/.vim/vimrc.plugins.maps

if utils#IsLinux()

    let font_list = [
                \ 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraMono/Regular/complete/Fura%20Mono%20Regular%20Nerd%20Font%20Complete%20Mono.otf',
                \ 'https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf'
                \ ]
    call install#LinuxFonts(font_list)
endif
