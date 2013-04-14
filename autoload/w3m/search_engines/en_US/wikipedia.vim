" File: autoload/w3m/search_engines/wikipedia.vim
" Last Modified: 2012.03.25
" Version: 1.0.0
" Author: yuratomo (twitter @yusetomo)

let s:engine = w3m#search_engine#Init('wikipedia', 'http://en.wikipedia.org/wiki/%s')

call w3m#search_engine#Add(s:engine)
