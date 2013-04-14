" File: autoload/w3m/search_engines/alc.vim
" Last Modified: 2012.03.25
" Version: 1.0.0
" Author: yuratomo (twitter @yusetomo)

let s:engine = w3m#search_engine#Init('alc', 'http://eow.alc.co.jp/search?q=%s&ref=sa')

function! s:engine.filter(outputs)
  return a:outputs[40:-13]
endfunction

call w3m#search_engine#Add(s:engine)
