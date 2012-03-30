" File: autoload/w3m/tools.vim
" Last Modified: 2012.03.30
" Author: yuratomo (twitter @yusetomo)

function! w3m#tools#getFormList()
  if exists('b:form_list')
    return b:form_list
  endif
  return []
endfunction

function! w3m#tools#getTagList()
  if exists('b:tag_list')
    return b:tag_list
  endif
  return []
endfunction

