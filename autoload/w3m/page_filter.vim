" File: autoload/w3m/page_filter.vim
" Last Modified: 2012.03.25
" Author: yuratomo (twitter @yusetomo)

let s:loaded_page_filters = 0

function! w3m#page_filter#Load()
  if s:loaded_page_filters == 1
    return
  endif
  for file in split(globpath(&runtimepath, 'autoload/w3m/page_filters/*.vim'), '\n')
    exe 'so ' . file
  endfor
  let s:loaded_page_filters = 1
endfunction

" for page filter define

function! w3m#page_filter#Init(name, pattern)
  return {'name':a:name, 'pattern':a:pattern}
endfunction

function! w3m#page_filter#Add(engine)
  call add(g:w3m#page_filter_list, a:engine)
endfunction

