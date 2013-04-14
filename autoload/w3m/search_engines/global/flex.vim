" File: autoload/w3m/search_engines/flex.vim
" Last Modified: 2012.03.25
" Version: 1.0.0
" Author: yuratomo (twitter @yusetomo)

let s:engine = w3m#search_engine#Init('flex', 'http://www.google.com/search?sitesearch=help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/&q=%s')

function! s:engine.preproc()
  let s:user_agent_backup = g:user_agent
  call w3m#SetUserAgent('KDDI', 0)
endfunction

function! s:engine.postproc()
  let g:user_agent = s:user_agent_backup
  unlet s:user_agent_backup
endfunction

function! s:engine.filter(outputs)
  return a:outputs[12:-20]
endfunction

call w3m#search_engine#Add(s:engine)
