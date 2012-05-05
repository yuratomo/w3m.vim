" File: autoload/w3m/search_engines/local.vim
" Last Modified: 2012.05.05
" Version: 1.0.0
" Author: yuratomo (twitter @yusetomo)

let s:engine = w3m#search_engine#Init('local', '%s')

call w3m#search_engine#Add(s:engine)
