" File: autoload/w3m/search_engines/msdn.vim
" Last Modified: 2012.03.25
" Version: 1.0.0
" Author: yuratomo (twitter @yusetomo)

let s:engine = w3m#search_engine#Init('msdn', 'http://www.google.com/search?ie=EUC-JP&oe=UTF-8&sitesearch=msdn.microsoft.com/ja-jp/library/&q=%s')

function! s:engine.preproc()
  let s:user_agent_backup = g:user_agent
  call w3m#SetUserAgent('KDDI', 0)
endfunction

function! s:engine.postproc()
  let g:user_agent = s:user_agent_backup
  unlet s:user_agent_backup
endfunction

function! s:engine.filter(outputs)
  let new_outputs = []
  for output in a:outputs[11:-18]
    let msdn_url = match(output, '\/url?q=http:\/\/msdn\.microsoft\.com\/')
    if msdn_url != -1
      let output = substitute(output, '\/url?q=', '', 'g')
      if match(output, ')\.aspx') != -1
        call add(new_outputs, substitute(output, ")\.aspx&[^\"' ]*", ',d=printer)\.aspx', 'g'))
      else
        call add(new_outputs, substitute(output, "\.aspx&[^\"' ]*", '(d=printer)\.aspx', 'g'))
      endif
    else
      call add(new_outputs, output)
    endif
  endfor
  return new_outputs
endfunction

call w3m#search_engine#Add(s:engine)
