" File: autoload/w3m/page_filters/msdn.vim
" Last Modified: 2012.03.25
" Version: 1.0.0
" Author: yuratomo (twitter @yusetomo)

let s:filter = w3m#page_filter#Init('msdn', 'http:\/\/msdn\.microsoft\.com\/ja-jp\/library')

function! s:filter.preproc()
endfunction

function! s:filter.postproc()
endfunction

function! s:filter.filter(outputs)
  let s = 8
  let e = len(a:outputs)
  let idx = e - 1
  while idx >= 0
    let output = a:outputs[idx]
    let link_table = match(output, 'リンクテーブル')
    if link_table != -1
      let e = idx - 1
      break
    endif
    let idx = idx - 1
  endwhile
  return a:outputs[ s : e ]
endfunction

call w3m#page_filter#Add(s:filter)
