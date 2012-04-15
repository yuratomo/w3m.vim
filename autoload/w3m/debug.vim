" File: autoload/w3m/debug.vim
" Last Modified: 2012.03.30
" Author: yuratomo (twitter @yusetomo)

function! w3m#debug#dump()
  if !exists('b:last_url')
    return
  endif
  setlocal modifiable

  let didx = len(b:display_lines)
  call setline(didx, '--------- url --------')
  let didx += 1
  call setline(didx, 'url: ' .  b:last_url)
  let didx += 1
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
  call setline(didx, '--------- global history --------')
  let didx += 1
  for hist in b:history
    call setline(didx, string(hist))
    let didx += 1
  endfor

  setlocal nomodifiable
endfunction

function! w3m#debug#showQuery()
  let fid = input('input fid:', 0)
  echo w3m#buildQueryString(fid, 0, 0)
endfunction

function! w3m#debug#copyQuery()
  let fid = input('input fid:', 0)
  call setreg('*', w3m#buildQueryString(fid, 0, 0))
endfunction

function! w3m#debug#test()
endfunction

