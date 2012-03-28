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
  let new_outputs = []
  let s = 8
  let e = len(a:outputs)
  let idx = 0
  for output in a:outputs
    let msdn_url = match(output, 'http:\/\/msdn\.microsoft\.com\/')
    if msdn_url != -1
      if match(output, ')\.aspx') != -1
        call add(new_outputs, substitute(output, ")\.aspx", ',d=printer)\.aspx', 'g'))
      else
        call add(new_outputs, substitute(output, "\.aspx", '(d=printer)\.aspx', 'g'))
      endif
    else
      call add(new_outputs, output)
    endif
    let link_table = match(output, 'リンクテーブル')
    if link_table != -1
      let e = idx - 1
      break
    endif
    let idx = idx + 1
  endfor
  return new_outputs[ s : e ]
endfunction

call w3m#page_filter#Add(s:filter)
