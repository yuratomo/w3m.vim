" File: autoload/w3m/search_engines/2ch.vim
" Last Modified: 2012.03.30
" Version: 1.0.0
" Author: yuratomo (twitter @yusetomo)

let s:engine = w3m#search_engine#Init('2ch', 'http://find.2ch.net/?STR=%s&COUNT=50&TYPE=TITLE&BBS=ALL')

function! s:engine.preproc()
endfunction

function! s:engine.postproc()
endfunction

function! s:engine.filter(outputs)
  return a:outputs
endfunction

call w3m#search_engine#Add(s:engine)
