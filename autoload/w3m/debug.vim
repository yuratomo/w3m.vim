" File: autoload/w3m/debug.vim
" Last Modified: 2012.03.30
" Author: yuratomo (twitter @yusetomo)

function! w3m#debug#Dump()
  if !exists('b:last_url')
    return
  endif
  setlocal modifiable

  let didx = len(b:display_lines)
  call setline(didx, '--------- tags --------')
  let didx += 1
  for dline in b:tag_list
    call setline(didx, 
      \ dline.line.",".
      \ dline.col.",".
      \ dline.type.",".
      \ dline.tagname.":".
      \ string(dline.attr))
    let didx += 1
  endfor
  call setline(didx, '--------- forms --------')
  let didx += 1
  for dline in b:form_list
    call setline(didx, 
      \ dline.line.",".
      \ dline.col.",".
      \ dline.type.",".
      \ dline.tagname.":".
      \ string(dline.attr))
    let didx += 1
  endfor
  call setline(didx, '--------- dbgmsg --------')
  let didx += 1

  setlocal nomodifiable
endfunction

function! w3m#debug#ShowQuery()
  let fid = input('input fid:', 0)
  echo s:buildQueryString(fid, 0)
endfunction

