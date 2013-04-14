" File: autoload/w3m/search_engines/yahoo.vim
" Last Modified: 2012.03.25
" Version: 1.0.0
" Author: yuratomo (twitter @yusetomo)

let s:engine = w3m#search_engine#Init('yahoo', 'http://search.yahoo.com/search?search.x=1&fr=top_ga1_sa_124&tid=top_ga1_sa_124&ei=' . &encoding . '&aq=&oq=&p=%s')

call w3m#search_engine#Add(s:engine)
