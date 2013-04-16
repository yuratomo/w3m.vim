let s:engine = w3m#search_engine#Init('duck', 'https://duckduckgo.com/?q=%s')

function! s:engine.preproc()
  let s:user_agent_backup = g:user_agent
  call w3m#SetUserAgent('w3m', 0)
endfunction

function! s:engine.postproc()
  let g:user_agent = s:user_agent_backup
  unlet s:user_agent_backup
endfunction

function! s:engine.filter(outputs)
  return a:outputs[1:-1]
endfunctio

call w3m#search_engine#Add(s:engine)
