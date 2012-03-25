" File: autoload/w3m/page_filters/php.vim
" Last Modified: 2012.03.25
" Version: 1.0.0
" Author: yuratomo (twitter @yusetomo)

let s:filter = w3m#page_filter#Init('php', 'http:\/\/php\.net\/manual')

function! s:filter.preproc()
endfunction

function! s:filter.postproc()
endfunction

function! s:filter.filter(outputs)
  let s = 0
  let idx = 0
  for output in a:outputs
    let change_lanag = match(output, 'Change language')
    if change_lanag != -1
      let s = idx + 1
      break
    endif
    let idx = idx + 1
  endfor
  return a:outputs[ s : ]
endfunction

call w3m#page_filter#Add(s:filter)
