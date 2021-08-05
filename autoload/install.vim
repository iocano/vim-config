if exists("g:loaded_install")
    finish
endif

let g:loaded_install = 1

" {{{
function install#PluginManager()

    let s:plug_destination = printf('%s/autoload/plug.vim', expand('~/.vim'))

    let s:plug_source = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

    let s:curl_command = printf('curl -fLo %s --create-dirs %s', s:plug_destination, s:plug_source)

    call system(s:curl_command)
endfunction
" }}}

" {{{
function install#Plugins()

    " clean terminal
    execute "!clear"

    "install plugins
    PlugInstall --sync

    " close installation buffer
    bd
endfunction
" }}}

" {{{
function! install#CocExtensions(extension_list)
    for extension in a:extension_list
        execute printf('CocInstall %s', extension)
    endfor
endfunction
" }}}

" {{{ Grab a font by url using curl and install
function! install#LinuxFonts(fonts_url, font_path_list)

    let font_destination = expand('~/.local/share/fonts')

    " create dir if no exists
    call system(printf('mkdir -p %s', font_destination))

    " to save font names installed
    let font_name_list = []

    for font_path in a:font_path_list
        let font_url = printf("%s/%s", url, font_path_list)
        let font_name = s:InstallFont(font_url, font_destination)
        call add(font_name_list, font_name)
    endfor

    return font_name_list
endfunction
" }}}

" ------------------------------------ Script scope functions --------------------------------------

" {{{
function! s:InstallFontLinux(font_url, font_destination)

    " get font name from url
    let url_font_name = split(a:font_url, '/')[-1]

    " 'decode' url font name
    let font_name = substitute(url_font_name, '%20', ' ', 'g')

    " get font from url
    call system(printf("curl -fLo '%s/%s' %s", a:font_destination, font_name, fnameescape(a:font_url)))

    return font_name

endfunction
" }}}

" {{{
function! s:UpdateFontCacheLinux()

    " {{{ command description
    " sudo: ....
    "   -k: remove timestamp (always request password)
    " fc-cache: update font cache
    "   -f: force
    "   -v: verbose
    " }}}
    let update_font_cache_cmd = 'sudo -k fc-cache -fv'

    echo "Input password to update font cache"
    echo printf("Or updte later with: %s\n", substitute(update_font_cache_cmd, " -k", '', ''))
    call feedkeys("\<CR>")

    call system(update_font_cache_cmd)

endfunction
" }}}
