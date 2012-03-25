" File: autoload/w3m/search_engines/as3.vim
" Last Modified: 2012.03.25
" Version: 1.0.0
" Author: yuratomo (twitter @yusetomo)

let s:engine = w3m#search_engine#Init('as3', 'http://www.google.com/search?ie=EUC-JP&oe=UTF-8&sitesearch=livedocs.adobe.com/flash/9.0_jp/&q=%s')

function! s:engine.preproc()
  let s:user_agent_backup = g:user_agent
  call w3m#SetUserAgent('KDDI', 0)
endfunction

function! s:engine.postproc()
  let g:user_agent = s:user_agent_backup
  unlet s:user_agent_backup
endfunction

function! s:engine.filter(outputs)
  return w3m#search_engine#GoogleSiteFilter(a:outputs)
endfunction

call w3m#search_engine#Add(s:engine)
