" File: autoload/w3m/search_engines/yahoodict.vim
" Last Modified: 2012.03.25
" Version: 1.0.0
" Author: yuratomo (twitter @yusetomo)

let s:engine = w3m#search_engine#Init('yahoodict', 'http://dic.search.yahoo.com/search?ei=' . &encoding . '&p=%s&fr=dic&stype=prefix')

function! s:engine.filter(outputs)
  let start = -1
  let end = -1
  let idx = 0
  for output in a:outputs
    if match(output, '‚±‚±‚©‚ç–{•¶') != -1
      let start = idx + 1
    elseif match(output, '–{•¶‚Í‚±‚±‚Ü‚Å') != -1
      let end = idx - 1
      break
    endif
    let idx = idx + 1
  endfor
  if start != -1 && end != -1
    return a:outputs[ start : end ]
  else
    return a:outputs
  endif
endfunction

call w3m#search_engine#Add(s:engine)
