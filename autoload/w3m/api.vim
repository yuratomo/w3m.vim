" File: autoload/w3m/api.vim
" Last Modified: 2012.04.04
" Author: yuratomo (twitter @yusetomo)

function! w3m#api#getFormList()
  if exists('b:form_list')
    return b:form_list
  endif
  return []
endfunction

function! w3m#api#getTagList()
  if exists('b:tag_list')
    return b:tag_list
  endif
  return []
endfunction

function! w3m#api#getHistoryList()
  call w3m#history#Load()
  if exists('g:w3m#history#list')
    return g:w3m#history#list
  endif
  return []
endfunction

function! w3m#api#openHistory(item)
  if len(a:item.params) > 1
    call w3m#Open(0, a:item.params[0], join(a:item.params[1:], ' '))
  else
    call w3m#Open(0, a:item.params[0])
  endif
endfunction
