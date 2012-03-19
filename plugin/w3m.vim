" File: plugin/w3m.vim
" Last Modified: 2012.03.19
" Version: 0.5.2
" Author: yuratomo (twitter @yusetomo)

if exists('g:loaded_w3m') && g:loaded_w3m == 1
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:w3m#command')
  let g:w3m#command = 'w3m'
endif
if !exists('g:w3m#option')
  let g:w3m#option = '-o display_charset=' . &encoding . ' -halfdump -o frame=true -o ext_halfdump=1 -o strict_iso2022=0 -o ucs_conv=1'
endif
if !exists('g:w3m#wget_command')
  let g:w3m#wget_command = 'wget'
endif
if !exists('g:w3m#download_ext')
  let g:w3m#download_ext = [ 'zip', 'lzh', 'cab', 'tar', 'gz', 'z', 'exe' ]
endif
if !exists('g:w3m#search_engine')
  let g:w3m#search_engine = 
    \ 'http://search.yahoo.co.jp/search?search.x=1&fr=top_ga1_sa_124&tid=top_ga1_sa_124&ei=' . &encoding . '&aq=&oq=&p='
endif
if !exists('g:w3m#max_history_num')
  let g:w3m#max_history_num = 10
endif
if !exists('g:w3m#external_browser')
  let g:w3m#external_browser = 'chrome'
endif
if !exists('g:w3m#disable_vimproc')
  let g:w3m#disable_vimproc = 0
endif
if !exists('g:w3m#debug')
  let g:w3m#debug = 0
endif
if !exists('g:w3m#hit_a_hint_key')
  let g:w3m#hit_a_hint_key = 'f'
endif
if !executable(g:w3m#command)
  echoerr "w3m is not exist!!"
  finish
endif

command! -nargs=* W3m :call w3m#Open(<f-args>)
command! -nargs=* W3mTab :call w3m#OpenAtNewTab(<f-args>)
command! -nargs=* W3mCopyUrl :call w3m#CopyUrl('*')
command! -nargs=* W3mReload :call w3m#Reload()
command! -nargs=* W3mAddressBar :call w3m#EditAddress()
command! -nargs=* W3mShowTitle :call w3m#ShowTitle()
command! -nargs=* W3mShowExtenalBrowser :call w3m#ShowExternalBrowser()
command! -nargs=* W3mShowSource :call w3m#ShowSourceAndHeader()
command! -nargs=* W3mClose :bd
command! -nargs=* W3mSyntaxOff :call w3m#ChangeSyntaxOnOff(0)
command! -nargs=* W3mSyntaxOn :call w3m#ChangeSyntaxOnOff(1)

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_w3m = 1
