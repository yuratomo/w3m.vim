" File: autoload/w3m/search_engine.vim
" Last Modified: 2012.03.25
" Author: yuratomo (twitter @yusetomo)

let s:loaded_search_engines = 0

function! w3m#search_engine#Load()
  if s:loaded_search_engines == 1
    return
  endif

  " Load search engines with active locale (set g:w3m#lang or $LANG)
  for file in split(globpath(&runtimepath, 'autoload/w3m/search_engines/' . split(g:w3m#lang, '\.')[0] . '/*.vim'), '\n')
    exe 'so ' . file
  endfor

  " Load search engines with 'global' locale
  for file in split(globpath(&runtimepath, 'autoload/w3m/search_engines/global/*.vim'), '\n')
    exe 'so ' . file
  endfor

  let s:loaded_search_engines = 1
endfunction

function! w3m#search_engine#List(A, L, P)
  if s:loaded_search_engines == 0
    call w3m#search_engine#Load()
  endif
  let items = []
  for item in g:w3m#search_engine_list
    if item.name =~ '^'.a:A
      call add(items, item.name)
    endif
  endfor
  return items
endfunction

" for search engine define

function! w3m#search_engine#Init(name, url)
  return {'name':a:name, 'url':a:url}
endfunction

function! w3m#search_engine#Add(engine)
  let skip = 0

  " skip if already loaded from another locale
  for item in g:w3m#search_engine_list
    if item.name == a:engine.name
      let skip = 1
    endif
  endfor

  if !skip
    call add(g:w3m#search_engine_list, a:engine)
  endif

endfunction

function! w3m#search_engine#GoogleSiteFilter(outputs)
  let new_outputs = []
  for output in a:outputs[11:-18]
    let msdn_url = match(output, '\/url?q=http:\/\/')
    if msdn_url != -1
      let output = substitute(output, '\/url?q=', '', 'g')
      call add(new_outputs, substitute(output, "&[^\"' ]*", '', 'g'))
    else
      call add(new_outputs, output)
    endif
  endfor
  return new_outputs
endfunction
