" File: autoload/w3m.vim
" Last Modified: 2012.04.04
" Author: yuratomo (twitter @yusetomo)

let s:save_cpo = &cpo
set cpo&vim

let s:w3m_title = 'w3m'
let s:tmp_option = ''
let s:message_adjust = 20
let [s:TAG_START,s:TAG_END,s:TAG_BOTH,s:TAG_UNKNOWN] = range(4)

if has('win32')
  let s:abandon_error = ' 2> NUL'
else
  let s:abandon_error = ' 2> /dev/null'
endif

call w3m#history#Load()

function! w3m#BufWinEnter()
  call s:applySyntax()
endfunction

function! w3m#BufWinLeave()
  call clearmatches()
endfunction

function! w3m#CheckUnderCursor()
  let [cl,cc] = [ line('.'), col('.') ]
  let tstart = -1
  let tidx = 0
  for tag in b:tag_list
    if tag.line == cl && tag.col > cc
      let tstart = tidx - 1
      break
    endif
    let tidx = tidx + 1
  endfor
  if tstart == -1
    return
  endif

  let tidx = tstart
  while tidx >= 0
    if b:tag_list[tidx].line != cl
      if tidx > 0
        echo b:tag_list[tidx-1].attr
      endif
      break
    endif
    if b:tag_list[tidx].type != s:TAG_START
      let tidx -= 1
      continue
    endif
    if has_key(b:tag_list[tidx].attr, 'href')
      echo b:tag_list[tidx].attr.href
      break
    endif
    let tidx -= 1
  endwhile
endfunction

function! w3m#ShowUsage()
  echo "[Usage] :W3m url"
  echo "example :W3m http://www.yahoo.co.jp"
endfunction

function! w3m#ShowTitle()
  let cols = winwidth(0) - &numberwidth

  " resolve title from cache
  if has_key(b:history[b:history_index], 'title') 
    call s:message( strpart(b:history[b:history_index].title, 0, cols - s:message_adjust) )
    return
  endif

  if exists('b:last_url')
    let title = "no title"
    for tag in b:tag_list
      if tag.type == s:TAG_START && tag.tagname ==? 'title_alt' && has_key(tag.attr, 'title')
        let title = tag.attr.title
        break
      endif
    endfor
    call s:message( strpart(title, 0, cols - s:message_adjust) )
  endif

  " cache title
  let b:history[b:history_index].title = title
endfunction

function! w3m#ShowSourceAndHeader()
  if exists('b:last_url')
    let cmdline = join( [ g:w3m#command, s:tmp_option, g:w3m#option, '"' . b:last_url . '"' ], ' ')
    new
    execute '%!'.substitute(cmdline, "-halfdump", "-dump_both", "")
  endif
endfunction

function! w3m#ShowExternalBrowser()
  if exists('g:w3m#external_browser') && exists('b:last_url')
    call s:system(g:w3m#external_browser . ' "' . b:last_url . '"')
  endif
endfunction

function! w3m#ShowURL()
  if exists('b:last_url')
    call s:message(b:last_url)
  endif
endfunction

function! w3m#CopyUrl(to)
  if exists('b:last_url')
    call setreg(a:to, b:last_url)
  endif
endfunction

function! w3m#Reload()
  if exists('b:last_url')
    call w3m#Open(g:w3m#OPEN_NORMAL, b:last_url)
  endif
endfunction

function! w3m#EditAddress()
  if exists('b:last_url')
    let url = input('url:', b:last_url)
    if url != ""
      call w3m#Open(g:w3m#OPEN_NORMAL, url)
      echo url
    endif
  endif
endfunction

function! w3m#SetUserAgent(name, reload)
  let change = 0
  for item in g:w3m#user_agent_list
    if item.name == a:name
      let g:user_agent = item.agent
      let change = 1
      break
    endif
  endfor
  if change == 1 && a:reload == 1
    call w3m#Reload()
  endif
endfunction

function! w3m#ListUserAgent(A, L, P)
  let items = []
  for item in g:w3m#user_agent_list
    if item.name =~ '^'.a:A
      call add(items, item.name)
    endif
  endfor
  return items
endfunction

function! w3m#MatchSearchStart(key)
  cnoremap <buffer> <CR> <CR>:call w3m#MatchSearchEnd()<CR>
  cnoremap <buffer> <ESC> <ESC>:call w3m#MatchSearchEnd()<CR>
  nnoremap <buffer> <ESC> <ESC>:call w3m#MatchSearchEnd()<CR>
  call feedkeys(a:key, 'n')
endfunction

function! w3m#MatchSearchEnd()
  cnoremap <buffer> <CR> <CR>
  cnoremap <buffer> <ESC> <ESC>
  nnoremap <buffer> <ESC> <ESC>
  if exists('b:last_match_id') && b:last_match_id != -1
    try 
      call matchdelete(b:last_match_id)
    catch
    endtry
  endif
  let keyword = histget("search", -1)
  if keyword == '^.*$\n'
    return
  endif
  let b:last_match_id = matchadd("Search", keyword)
endfunction

function! w3m#ToggleSyntax()
  if b:enable_syntax == 0
    cal w3m#ChangeSyntaxOnOff(1)
  else
    cal w3m#ChangeSyntaxOnOff(0)
  endif
endfunction

function! w3m#ChangeSyntaxOnOff(mode)
  let b:enable_syntax = a:mode
  if a:mode == 0
    call clearmatches()
    call s:message("syntax off")
  else
    call s:applySyntax()
    call s:message("syntax on")
  endif
endfunction

function! w3m#ToggleUseCookie()
  if g:w3m#option_use_cookie == 0
    let g:w3m#option_use_cookie = 1
    call s:message("use_cookie on")
  else
    let g:w3m#option_use_cookie = 0
    call s:message("use_cookie off")
  endif
endfunction

function! w3m#Open(mode, ...)
  if len(a:000) == 0
    if exists('g:w3m#homepage')
      call w3m#Open(a:mode, g:w3m#homepage)
    else
      call w3m#ShowUsage()
    endif
    return
  endif
  if a:mode == g:w3m#OPEN_TAB
    tabe
  elseif a:mode == g:w3m#OPEN_SPLIT
    new
  endif

  call s:prepare_buffer()
  if b:history_index >= 0 && b:history_index < len(b:history)
    let b:history[b:history_index].curpos = [ line('.'), col('.') ]
  endif

  "Load search engines and page filters
  call w3m#search_engine#Load()
  call w3m#page_filter#Load()

  "Is the search-engine specified?
  let use_filter = 0
  for se in g:w3m#search_engine_list
    if has_key(se, 'name') && has_key(se, 'url')
      if se.name == a:000[0]
        "preproc for search-engine
        if has_key(se, 'preproc')
          call se.preproc()
        endif
        let url = printf(se.url, join(a:000[1:], ' '))
        let use_filter = 1
        break
      endif
    endif
  endfor

  if use_filter == 0
    if s:isHttpURL(a:000[0])
      let url = s:normalizeUrl(a:000[0])
    else
      let url = g:w3m#search_engine . join(a:000, ' ')
    endif

    "Is the url match page-filter pattern?
    for se in g:w3m#page_filter_list
      if has_key(se, 'pattern')
        if match(url, se.pattern) != -1
          "preproc for page-filter
          if has_key(se, 'preproc')
            call se.preproc()
          endif
          let use_filter = 1
          break
        endif
      endif
    endfor
  endif

  "Is url include anchor?
  let anchor = ''
  let aidx = stridx(url, '#')
  if aidx >= 0
    let anchor = url[ aidx : ]
    let url = url[0 : aidx - 1 ]
  endif

  "create command
  let cols = winwidth(0) - &numberwidth
  let cmdline = s:create_command(url, cols)
  call s:message( strpart('open ' . url, 0, cols - s:message_adjust) )

  "postproc for filter
  if use_filter == 1
    if has_key(se, 'postproc')
      call se.postproc()
    endif
  endif

  "execute halfdump
  let outputs = split(s:neglectNeedlessTags(s:system(cmdline)), '\n')

  "do filter
  if use_filter == 1
    if has_key(se, 'filter')
      let outputs = se.filter(outputs)
    endif
  endif

  "add outputs to url-history
  if len(b:history) - 1 > b:history_index
    call remove(b:history, b:history_index+1, -1)
  endif
  call add(b:history, {'url':url, 'outputs':outputs} )
  let b:history_index = len(b:history) - 1
  if b:history_index >= g:w3m#max_cache_page_num
    call remove(b:history, 0, 0)
    let b:history_index = len(b:history) - 1
  endif

  call s:openCurrentHistory()

  "add global history
  let title = b:history[b:history_index].title
  call w3m#history#Regist(title, a:000)

  "move to anchor
  if anchor != ''
    call s:moveToAnchor(anchor)
  endif
endfunction

function! w3m#Back()
  if b:history_index <= 0
    return
  endif
  let b:history[b:history_index].curpos = [ line('.'), col('.') ]
  let b:history_index -= 1
  call s:openCurrentHistory()
endfunction

function! w3m#Forward()
  if b:history_index >= len(b:history) - 1
    return
  endif
  let b:history[b:history_index].curpos = [ line('.'), col('.') ]
  let b:history_index += 1
  call s:openCurrentHistory()
endfunction

function! w3m#PrevLink()
  let [cl,cc] = [ line('.'), col('.') ]
  let tstart = -1
  let tidx = 0
  for tag in b:tag_list
    if tag.type == s:TAG_START && s:is_tag_tabstop(tag)
      if tag.line == cl && tag.col >= cc -1
        break
      elseif tag.line > cl
        break
      else
        let tstart = tidx
      endif
    endif
    let tidx = tidx + 1
  endfor
  if tstart != -1
    call cursor(b:tag_list[tstart].line, b:tag_list[tstart].col)
  endif
endfunction

function! w3m#NextLink()
  let [cl,cc] = [ line('.'), col('.') ]
  let tstart = -1
  let tidx = 0
  for tag in b:tag_list
    if tag.type == s:TAG_START && s:is_tag_tabstop(tag)
      if tag.line == cl && tag.col > cc
        let tstart = tidx
        break
      elseif tag.line > cl
        let tstart = tidx
        break
      endif
    endif
    let tidx = tidx + 1
  endfor
  if tstart != -1
    call cursor(b:tag_list[tstart].line, b:tag_list[tstart].col)
  endif
endfunction

function! w3m#Click(shift)
  let [cl,cc] = [ line('.'), col('.') ]
  let tstart = -1
  let tidx = 0
  for tag in b:tag_list
    if tag.line == cl && tag.col > cc
      let tstart = tidx - 1
      break
    endif
    let tidx = tidx + 1
  endfor
  if tstart == -1
    call s:message('not process')
    return
  endif
  call s:message('processing')

  let tidx = tstart
  while tidx >= 0
    if b:tag_list[tidx].line != cl
      break
    endif
    if b:tag_list[tidx].type != s:TAG_START
      let tidx -= 1
      continue
    endif
    let b:click_with_shift = a:shift
    let ret = s:dispatchTagProc(b:tag_list[tidx].tagname, tidx)
    if ret == 1
      break
    endif
    let tidx -= 1
  endwhile

  call w3m#ShowTitle()
endfunction

function! s:post(url, file)
  let s:tmp_option = '-post ' . a:file
  call w3m#Open(g:w3m#OPEN_NORMAL, a:url)
  let s:tmp_option = ''
  call s:message('post ok')
endfunction

function! s:openCurrentHistory()
  setlocal modifiable
  call s:message('analize output')
  let b:display_lines = s:analizeOutputs(b:history[b:history_index].outputs)
  let b:last_url = b:history[b:history_index].url
  call clearmatches()
  % delete _
  call setline(1, b:display_lines)
  call w3m#ShowTitle()
  call s:applySyntax()
  if has_key(b:history[b:history_index], 'curpos') 
    let [cl,cc] = b:history[b:history_index].curpos
    call cursor(cl, cc)
  endif
  setlocal ft=w3m bt=nofile noswf nomodifiable nowrap hidden nolist
endfunction

function! s:analizeOutputs(output_lines)
  let display_lines = []
  let b:tag_list = []
  let b:anchor_list = []
  let b:form_list = []

  let cline = 1
  let tnum  = 0
  for line in a:output_lines
    let analaized_line = ''
    let [lidx, ltidx, gtidx] = [ 0, -1, -1 ]
    let line_anchor_list = []
    while 1
      let ltidx = stridx(line, '<', lidx)
      if ltidx >= 0
        let analaized_line .= s:decordeEntRef(strpart(line, lidx, ltidx-lidx))
        let ccol = strlen(analaized_line) + 1
        let lidx = ltidx + 1
        let gtidx = stridx(line, '>', lidx)
        if gtidx >= 0
          let ctag = strpart(line, ltidx, gtidx-ltidx+1)
          let type = s:resolvTagType(ctag)
          let attr = {}
          let tname = s:analizeTag(ctag, attr)
          let item = {
              \ 'line':cline,
              \ 'col':ccol,
              \ 'type':type,
              \ 'tagname':tname,
              \ 'attr':attr,
              \ 'evalue':'',
              \ 'edited':0,
              \ 'echecked':0
              \ }
          call add(b:tag_list, item)
          if tname == 'a'
            " Assume: All anchors start and stop on the same line
            if type == s:TAG_START
              " A link/anchor has been found
              call add( line_anchor_list, {"startCol":ccol,"endCol":ccol,"line":cline,"attr":attr})
            else
              let n = len(line_anchor_list) - 1
              let line_anchor_list[n]["endCol"] = ccol
              " echo "attr: ".attr
              " sleep
            end
          endif
          let tnum += 1
          if stridx(tname,'input') == 0
            call add(b:form_list, item)
          endif
          let lidx = gtidx + 1
        else
          let analaized_line .= s:decordeEntRef(strpart(line, lidx))
          break
        endif
      else
        let analaized_line .= s:decordeEntRef(strpart(line, lidx))
        break
      endif
    endwhile
    call add(display_lines, analaized_line)
    call add(b:anchor_list, line_anchor_list)
    let cline += 1
  endfor
  return display_lines
endfunction

function! s:resolvTagType(tag)
  if stridx(a:tag, '<') == 0
    if stridx(a:tag, '/>') >= 0 && match(a:tag, '=\a') == -1
      return s:TAG_BOTH
    elseif stridx(a:tag, '</') == 0
      return s:TAG_END
    else
      return s:TAG_START
    endif
  endif
  return s:TAG_UNKNOWN
endfunction

function! s:analizeTag(tag, attr)
  let tagname_e = stridx(a:tag, ' ') - 1
  let taglen = strlen(a:tag)
  if tagname_e < 0
    if a:tag[1:1] == '/'
      return tolower(strpart(a:tag, 2, taglen-3))
    else
      return tolower(strpart(a:tag, 1, taglen-2))
    endif
  endif

  let tagname = tolower(strpart(a:tag, 1, tagname_e))
  let idx = tagname_e + 2
  while 1
    if idx >= taglen
      break
    endif

    let na = stridx(a:tag, ' ', idx)
    let eq = stridx(a:tag, '=', idx)
    if eq == -1 || eq > na
      if na == -1
        if eq == -1
          let key = strpart(a:tag, idx, taglen-idx-1)
          if key != ""
            let a:attr[tolower(key)] = ''
          endif
          break
        endif
        let na = taglen - 1
      else " no value key
        let key = strpart(a:tag, idx, na-idx)
        if key != ""
          let a:attr[tolower(key)] = ''
        endif
        let idx = na + 1
        continue
      endif
    endif

    let vs = eq+1
    if a:tag[vs] == '"' || a:tag[vs] == "'"
      let ee = stridx(a:tag, a:tag[vs], vs+1) " end quate
      let vs += 1
      let ve = ee - 1
      let na = ee + 1
    else
      let ve = na - 1
    endif
    let ks = idx
    let ke = eq - 1

    let keyname = strpart(a:tag, ks, ke-ks+1)
    if strlen(keyname) > 0
      let a:attr[tolower(keyname)] = s:decordeEntRef(strpart(a:tag, vs, ve-vs+1))
    endif
    let idx = na + 1
  endwhile

  return tagname
endfunction

function! s:prepare_buffer()
  if !exists('b:w3m_bufname')
    let id = 1
    while buflisted(s:w3m_title.'-'.id)
      let id += 1
    endwhile
    let bufname = s:w3m_title.'-'.id
    silent edit `=bufname`

    let b:w3m_bufname = s:w3m_title.'-'.id
    let b:last_url = ''
    let b:history_index = 0
    let b:history = []
    let b:display_lines = []
    let b:tag_list = []
    let b:anchor_list = []
    let b:form_list = []
    let b:click_with_shift = 0
    let b:last_match_id = -1
    let b:enable_syntax = 1

    call s:keymap()
    call s:default_highligh()

    augroup w3m
      au BufWinEnter <buffer> silent! call w3m#BufWinEnter()
      au BufWinLeave <buffer> silent! call w3m#BufWinLeave()
    augroup END
  endif
endfunction

function! s:keymap()
  nnoremap <buffer><Plug>(w3m-click)         :<C-u>call w3m#Click(0)<CR>
  nnoremap <buffer><Plug>(w3m-shift-click)   :<C-u>call w3m#Click(1)<CR>
  nnoremap <buffer><Plug>(w3m-address-bar)   :<C-u>call w3m#EditAddress()<CR>
  nnoremap <buffer><Plug>(w3m-next-link)     :<C-u>call w3m#NextLink()<CR>
  nnoremap <buffer><Plug>(w3m-prev-link)     :<C-u>call w3m#PrevLink()<CR>
  nnoremap <buffer><Plug>(w3m-back)          :<C-u>call w3m#Back()<CR>
  nnoremap <buffer><Plug>(w3m-forward)       :<C-u>call w3m#Forward()<CR>
  nnoremap <buffer><Plug>(w3m-show-link)     :<C-u>call w3m#CheckUnderCursor()<CR>
  nnoremap <buffer><Plug>(w3m-show-title)    :<C-u>call w3m#ShowTitle()<CR>
  nnoremap <buffer><Plug>(w3m-search-start)  :<C-u>call w3m#MatchSearchStart('/')<CR>
  nnoremap <buffer><Plug>(w3m-search-end)    :<C-u>call w3m#MatchSearchEnd()<CR>
  nnoremap <buffer><Plug>(w3m-hit-a-hint)    :<C-u>call w3m#HitAHintStart()<CR>
  nnoremap <buffer><Plug>(w3m-syntax-on)     :<C-u>call w3m#ChangeSyntaxOnOff(1)<CR>
  nnoremap <buffer><Plug>(w3m-syntax-off)    :<C-u>call w3m#ChangeSyntaxOnOff(0)<CR>
  nnoremap <buffer><Plug>(w3m-toggle-syntax) :<C-u>call w3m#ToggleSyntax()<CR>
  nnoremap <buffer><Plug>(w3m-toggle-use-cookie) :<C-u>call w3m#ToggleUseCookie()<CR>

  if !exists('g:w3m#disable_default_keymap') || g:w3m#disable_default_keymap == 0
    nmap <buffer><LeftMouse> <LeftMouse><Plug>(w3m-click)
    nmap <buffer><CR>        <Plug>(w3m-click)
    nmap <buffer><S-CR>      <Plug>(w3m-shift-click)
    nmap <buffer><TAB>       <Plug>(w3m-next-link)
    nmap <buffer><S-TAB>     <Plug>(w3m-prev-link)
    nmap <buffer><BS>        <Plug>(w3m-back)
    nmap <buffer><A-LEFT>    <Plug>(w3m-back)
    nmap <buffer><A-RIGHT>   <Plug>(w3m-forward)
    nmap <buffer>s           <Plug>(w3m-toggle-syntax)
    nmap <buffer>c           <Plug>(w3m-toggle-use-cookie)
    nmap <buffer>=           <Plug>(w3m-show-link)
    nmap <buffer>/           <Plug>(w3m-search-start)
    nmap <buffer>*           *<Plug>(w3m-search-end)
    nmap <buffer>#           #<Plug>(w3m-search-end)
    nmap <buffer><m-d>       <Plug>(w3m-address-bar)
    exe 'nmap <buffer>' . g:w3m#hit_a_hint_key . ' <Plug>(w3m-hit-a-hint)'
  endif
endfunction

function! s:default_highligh()
  if !hlexists('w3mBold')
    hi w3mBold gui=bold
  endif
  if !hlexists('w3mUnderline')
    hi w3mUnderline gui=underline
  endif
  if !hlexists('w3mInput')
    highlight! link w3mInput String
  endif
  if !hlexists('w3mSubmit')
    highlight! link w3mSubmit Special
  endif
  if !hlexists('w3mLink')
    highlight! link w3mLink Function
  endif
  if !hlexists('w3mAnchor')
    highlight! link w3mAnchor Label
  endif
  if !hlexists('w3mLinkHover')
    highlight! link w3mLinkHover SpecialKey
  endif
  if !hlexists('w3mHitAHint')
    highlight! link w3mHitAHint Question
  endif
endfunction

function! s:applySyntax()
  if b:enable_syntax == 0
    return
  endif
  let link_s = -1
  let bold_s = -1
  let underline_s = -1
  let input_s = -1
  let input_highlight = ""
  let link_anchor = 0
  for tag in b:tag_list
    if link_s == -1 && tag.tagname ==? 'a' && tag.type == s:TAG_START
      if tag.col > 0
        let link_s = tag.col -1
      else
        let link_s = 0
      endif
      if has_key(tag.attr, 'href') && tag.attr.href[0] == '#'
        let link_anchor = 1
      endif
    elseif link_s != -1 && tag.tagname ==? 'a' && tag.type == s:TAG_END
      let link_e = tag.col
      if link_anchor == 1
        call matchadd('w3mAnchor', '\%>'.link_s.'c\%<'.link_e.'c\%'.tag.line.'l')
      else
        call matchadd('w3mLink', '\%>'.link_s.'c\%<'.link_e.'c\%'.tag.line.'l')
      endif
      let link_anchor = 0
      let link_s = -1

    elseif bold_s == -1 && tag.tagname ==? 'b' && tag.type == s:TAG_START
      if tag.col > 0
        let bold_s = tag.col -1
      else
        let bold_s = 0
      endif
    elseif bold_s != -1 && tag.tagname ==? 'b' && tag.type == s:TAG_END
      let bold_e = tag.col
      call matchadd('w3mBold', '\%>'.bold_s.'c\%<'.bold_e.'c\%'.tag.line.'l')
      let bold_s = -1

    elseif underline_s == -1 && tag.tagname ==? 'u' && tag.type == s:TAG_START
      if tag.col > 0
        let underline_s = tag.col -1
      else
        let underline_s = 0
      endif
    elseif underline_s != -1 && tag.tagname ==? 'u' && tag.type == s:TAG_END
      let underline_e = tag.col
      call matchadd('w3mUnderline', '\%>'.underline_s.'c\%<'.underline_e.'c\%'.tag.line.'l')
      let underline_s = -1

    elseif input_s == -1 && tag.tagname ==? 'input_alt' && tag.type == s:TAG_START
      if s:is_tag_input_image_submit(tag)
        let input_highlight = 'w3mSubmit'
      else
        let input_highlight = 'w3mInput'
      endif
      if tag.col > 0
        let input_s = tag.col -1
      else
        let input_s = 0
      endif
    elseif input_s != -1 && stridx(tag.tagname, 'input') == 0 && tag.type == s:TAG_END
      let input_e = tag.col
      call matchadd(input_highlight, '\%>'.input_s.'c\%<'.input_e.'c\%'.tag.line.'l')
      let input_s = -1
    endif
  endfor

endfunction

" apply hover-links function
if exists('g:w3m#set_hover_on') && g:w3m#set_hover_on > 0
  let g:w3m#set_hover_on = 1
  if has("autocmd")
    if g:w3m#hover_delay_time == 0
      " everytime the cursor moves in the buffer 
      " normal mode is forcesd by default, so only check normal mode
      au! CursorMoved w3m-*  call s:applyHoverHighlight()
    else
      au! CursorMoved w3m-*  call s:delayHoverHighlight()
    endif
  else
    unlet g:w3m#set_hover_on
  endif
  function! s:delayHoverHighlight()
    if !exists('g:w3m#updatetime_backup')
      let g:w3m#updatetime_backup = &updatetime
      let &updatetime = g:w3m#hover_delay_time
      au! CursorHold w3m-*  call s:applyHoverHighlight()
    endif
  endfunction
  function! s:applyHoverHighlight()
    if !exists('g:w3m#set_hover_on') || g:w3m#set_hover_on < 1 
      " hover-links is turned OFF
      return
    endif
    let [cline,ccol] = [ line('.'), col('.') ]
    if exists("b:match_hover_anchor") && b:match_hover_anchor.line == cline && b:match_hover_anchor.startCol <=  ccol && b:match_hover_anchor.endCol > ccol
      " the link under the cursor has not changed
      return
    endif
    if cline >= len(b:anchor_list)
      return
    endif
    " loop through all anchors on this line
    for anchor in b:anchor_list[cline - 1]
      if anchor.startCol <= ccol && anchor.endCol > ccol
        " a match is found
        let a_found = anchor
        break
      endif
      if anchor.startCol > ccol
        " we've gone to far
        break
      endif
    endfor
    if exists('b:match_hover_id') 
      " restore color
      silent! call matchdelete(b:match_hover_id)
      unlet b:match_hover_id
      unlet b:match_hover_anchor
    endif
    if exists('a_found')
      let b:match_hover_anchor = a_found
      let tstart = b:match_hover_anchor.startCol - 1
      let tend   = b:match_hover_anchor.endCol
      let b:match_hover_id = matchadd('w3mLinkHover', '\%>'.tstart.'c\%<'.tend.'c\%'.cline.'l')
    endif
    if exists('g:w3m#updatetime_backup')
      let &updatetime = g:w3m#updatetime_backup
      au! CursorHold w3m-*
      unlet g:w3m#updatetime_backup
    endif
  endfunction
endif

function! s:escapeSyntax(str)
  return escape(a:str, '~"\|*-[]')
endfunction

function! s:dispatchTagProc(tagname, tidx)
  let ret = 0
  if a:tagname ==? 'a'
    let ret = s:tag_a(a:tidx)
  elseif stridx(a:tagname, 'input') == 0
    let ret = s:tag_input(a:tidx)
  endif
  return ret
endfunction

function! s:tag_a(tidx)
  if has_key(b:tag_list[a:tidx].attr,'href')
    let url = s:resolveUrl(b:tag_list[a:tidx].attr.href)
    if s:is_download_target(url)
      call s:downloadFile(url)
    elseif s:is_anchor(url)
      call s:moveToAnchor(url)
    else
      let open_mode = g:w3m#OPEN_NORMAL
      if b:click_with_shift == 1
        let open_mode = g:w3m#OPEN_SPLIT
      endif
      call w3m#Open(open_mode, url)
    endif
    return 1
  endif
  return 0
endfunction

function! s:tag_input(tidx)
  let url = ''
  " find form
  if !has_key(b:tag_list[a:tidx].attr,'type')
    return
  endif
  let type = b:tag_list[a:tidx].attr.type

  try 
    call s:tag_input_{tolower(type)}(a:tidx)
  catch /^Vim\%((\a\+)\)\=:E117/
  endtry

  return 1
endfunction

function! s:tag_input_image(tidx)
  if has_key(b:tag_list[a:tidx].attr,'value') && b:tag_list[a:tidx].attr.value ==? 'submit'
    call s:tag_input_submit(a:tidx)
  endif
endfunction

function! s:tag_input_submit(tidx)
  let idx = a:tidx - 1
  let action = 'GET'
  let fid = 0
  while idx >= 0
    if b:tag_list[idx].type == s:TAG_START && stridx(b:tag_list[idx].tagname, 'form') == 0
     if has_key(b:tag_list[idx].attr,'action') 
       let url = s:resolveUrl(b:tag_list[idx].attr.action)
       if has_key(b:tag_list[idx].attr,'method') 
         let action = b:tag_list[idx].attr.method
       endif
       if has_key(b:tag_list[idx].attr,'fid') 
         let fid = b:tag_list[idx].attr.fid
       endif
       break
     endif
   endif
   let idx -= 1
  endwhile

  if url != ''
    if action ==? 'GET'
      let query = w3m#buildQueryString(fid, a:tidx, 1)
      call w3m#Open(g:w3m#OPEN_NORMAL, url . query)
    elseif action ==? 'POST'
      let file = w3m#generatePostFile(fid, a:tidx)
      call s:post(url, file)
      call delete(file)
    else
      call s:message(toupper(action) . ' is not support')
    endif
  endif
endfunction

function! s:tag_input_text(tidx)
  redraw
  if b:tag_list[a:tidx].edited == 0
    if has_key(b:tag_list[a:tidx].attr, 'value')
      let value = b:tag_list[a:tidx].attr.value
    else
      let value = ''
    endif
  else
    let value = b:tag_list[a:tidx].evalue
  endif
  let b:tag_list[a:tidx].evalue = input('input:', value)
  let b:tag_list[a:tidx].edited = 1
  call s:applyEditedInputValues()
endfunction

function! s:tag_input_textarea(tidx)
  call s:tag_input_text(a:tidx)
endfunction

function! s:tag_input_password(tidx)
  redraw
  if b:tag_list[a:tidx].edited == 0
    let value = b:tag_list[a:tidx].attr.value
  else
    let value = b:tag_list[a:tidx].evalue
  endif
  let b:tag_list[a:tidx].evalue = input('input password:', value)
  let b:tag_list[a:tidx].edited = 1
  call s:applyEditedInputValues()
endfunction

function! s:tag_input_radio(tidx)
  redraw
  " 他の同じnameのecheckedをリセット
  for item in b:form_list
    if has_key(item.attr, 'type') && item.attr.type ==? 'radio'
      let item.edited = 1
      let item.echecked = 0
    endif
  endfor

  let b:tag_list[a:tidx].echecked = 1
  if has_key(b:tag_list[a:tidx].attr, 'value')
    let value = b:tag_list[a:tidx].attr.value
  else
    let value = ''
  endif
  let b:tag_list[a:tidx].evalue = value
  call s:applyEditedInputValues()
endfunction

function! s:tag_input_checkbox(tidx)
  redraw
  if b:tag_list[a:tidx].edited == 1
    if b:tag_list[a:tidx].echecked == 1
      let b:tag_list[a:tidx].echecked = 0
    else
      let b:tag_list[a:tidx].echecked = 1
    endif
  else
    let b:tag_list[a:tidx].edited = 1
    if has_key(b:tag_list[a:tidx], 'checked')
      let b:tag_list[a:tidx].echecked = 0
    else
      let b:tag_list[a:tidx].echecked = 1
    endif
  endif
  let b:tag_list[a:tidx].echecked = 1
  if has_key(b:tag_list[a:tidx].attr, 'value')
    let value = b:tag_list[a:tidx].attr.value
  else
    let value = ''
  endif
  let b:tag_list[a:tidx].evalue = value
  call s:applyEditedInputValues()
endfunction

function! s:tag_input_reset(tidx)
  for item in b:form_list
    if s:is_editable_tag(item)
      let item.evalue = ''
      let item.edited = 0
    endif
  endfor
  call s:applyEditedInputValues()
  call s:message('reset form data')
endfunction

"function! s:tag_input_xxx(tidx)
"endfunction

function! s:create_command(url, cols)
  let command_list = [ g:w3m#command, s:tmp_option, g:w3m#option, '-cols', a:cols]

  if g:w3m#option_use_cookie != -1
    call add(command_list, '-o use_cookie=' . g:w3m#option_use_cookie)
  endif
  if g:w3m#option_accept_cookie != -1
    call add(command_list, '-o accept_cookie=' . g:w3m#option_accept_cookie)
  endif
  if g:w3m#option_accept_bad_cookie != -1
    call add(command_list, '-o accept_bad_cookie=' . g:w3m#option_accept_bad_cookie)
  endif
  if g:user_agent != ''
    call add(command_list, '-o user_agent="' . g:user_agent . '"')
  endif

  call add(command_list, '"' . a:url . '"')
  let cmdline = join(command_list, ' ') . s:abandon_error
  return cmdline
endfunction

function! s:resolveUrl(url)
  if s:isHttpURL(a:url)
    return s:decordeEntRef(a:url)
  elseif s:is_anchor(a:url)
    return a:url
  else
    if a:url[0] == '/'
      let base = strlen(b:last_url) - 1
      let tmp = stridx(b:last_url, '/')
      if tmp != -1
        let tmp = stridx(b:last_url, '/', tmp+1)
        if tmp != -1
          let tmp = stridx(b:last_url, '/', tmp+1)
          if tmp != -1
            let base = tmp - 1
          endif
        endif
      endif
    else
      let base = strridx(b:last_url, '/')
    endif
    let url = strpart(b:last_url, 0, base+1)
    return url . s:decordeEntRef(a:url)
  endif
endfunction

function! w3m#buildQueryString(fid, tidx, is_encode)
  let query = ''
  let first = 1
  for item in b:form_list
    if has_key(item.attr,'name') && item.attr.name != ''
      if !has_key(item.attr,'fid') || item.attr.fid != a:fid
        continue
      endif
      if has_key(item.attr,'type')
        "if item.attr.type == 'submit' && has_key(item.attr, 'name') && item.attr.name != b:tag_list[a:tidx].attr.name
        if item.attr.type == 'submit'
          continue
        elseif item.attr.type == 'radio' || item.attr.type == 'checkbox'
          if item.edited == 1
            if item.echecked == 0
              continue
            endif
          else
            if !has_key(item.attr, 'checked')
              continue
            endif
          endif
        endif
      endif

      if first == 1
        let query .= '?'
        let first = 0
      else
        let query .= '&'
      endif
      if item.edited == 0
        if has_key(item.attr,'value')
          let value = item.attr.value
        else
          let value = ''
        endif
      else
        let value = item.evalue
      endif
      if a:is_encode == 1
        let query .= item.attr.name . '=' . s:encodeUrl(value)
      else
        let query .= item.attr.name . '=' . value
      endif
    endif
  endfor
  return query
endfunction

function! w3m#generatePostFile(fid, tidx)
  let tmp_file = tempname()
  let items = w3m#buildQueryString(a:fid, a:tidx, 0)[1:] . '&'
  call writefile([ items ], tmp_file)
  return tmp_file
endfunction

function! s:applyEditedInputValues()
  for item in b:form_list
    if s:is_editable_tag(item)
      if item.edited == 0
        if has_key(item.attr,'value')
          let value = item.attr.value
        else
          let value = ''
        endif
      else
        let value = item.evalue
      endif
      let line = getline(item.line)
      let s = stridx(line, '[')
      if s >= 0
        let e = stridx(line, ']')
        if e >= 0
          let i = s+strlen(value) + 1
          while i < e
            let value .= ' '
            let i += 1
          endwhile
        endif
      endif
      let value = strpart(value, 0, e - s -1)
      let line = strpart(line, 0, item.col-1) . value . strpart(line, item.col+strlen(value)-1)
      setlocal modifiable
      call setline(item.line, line)
      setlocal nomodifiable

    elseif s:is_radio_or_checkbox(item)
      if item.edited == 1
        if item.echecked == 1
          let value = '*'
        else
          let value = ' '
        endif
      else 
        if has_key(item.attr, 'checked')
          let value = '*'
        else
          let value = ' '
        endif
      endif
      let line = getline(item.line)
      let line = strpart(line, 0, item.col-1) . value . strpart(line, item.col)
      setlocal modifiable
      call setline(item.line, line)
      setlocal nomodifiable

    endif
  endfor
endfunction

function! w3m#HitAHintStart()
  if !exists('b:tag_list')
    return
  endif
  let index = 0
  for item in b:tag_list
    if item.tagname ==? 'a' && item.type == s:TAG_START && item.line >= line('w0')
      let link_s = item.col-1
      let link_e = item.col+strlen(index)
      let line = getline(item.line)
      let line = strpart(line, 0, link_s) . '@' . index . strpart(line, link_e)
      setlocal modifiable
      call setline(item.line, line)
      setlocal nomodifiable
      let link_e = link_e + 1
      call matchadd('w3mHitAHint', '\%>'.link_s.'c\%<'.link_e.'c\%'.item.line.'l')
      let index = index + 1
    endif
    if item.line >= line('w$')
      break
    endif
  endfor
  cnoremap <buffer> <CR> <CR>:call w3m#Click(0)<CR>:call w3m#HitAHintEnd()<CR>
  cnoremap <buffer> <ESC> <ESC>:call w3m#HitAHintEnd()<CR>
  nnoremap <buffer> <ESC> <ESC>:call w3m#HitAHintEnd()<CR>
  call feedkeys('/@', 'n')
endfunction

function! w3m#HitAHintEnd()
  cnoremap <buffer> <CR> <CR>
  cnoremap <buffer> <ESC> <ESC>
  nnoremap <buffer> <ESC> <ESC>
  call s:applySyntax()
  for item in b:tag_list
    if item.tagname ==? 'a' && item.type == s:TAG_START && item.line >= line('w0')
      let line = b:display_lines[item.line-1]
      setlocal modifiable
      call setline(item.line, line)
      setlocal nomodifiable
    endif
    if item.line >= line('w$')
      break
    endif
  endfor
endfunction

function! s:encodeUrl(str)
  if &encoding == 'utf-8'
    let utf8str = a:str
  else
    let utf8str = iconv(a:str, &encoding, 'utf-8')
  endif
  let retval = substitute(utf8str,  '[^- *.0-9A-Za-z]', '\=s:ch2hex(submatch(0))', 'g')
  let retval = substitute(retval, ' ', '%20', 'g')
  return retval
endfunction

function! s:ch2hex(ch)
  let result = ''
  let i = 0
  while i < strlen(a:ch)
    let hex = s:nr2hex(char2nr(a:ch[i]))
    let result = result . '%' . (strlen(hex) < 2 ? '0' : '') . hex
    let i = i + 1
  endwhile
  return result
endfunction

function! s:nr2hex(nr)
  let n = a:nr
  let r = ""
  while 1
    let r = '0123456789ABCDEF'[n % 16] . r
    let n = n / 16
    if n == 0
      break
    endif
  endwhile
  return r
endfunction

function! s:isHttpURL(str)
  if stridx(a:str, 'http://') == 0 || stridx(a:str, 'https://') == 0
    return 1
  endif
  return 0
endfunction

function! s:normalizeUrl(url)
  let url = a:url
  let s1 = stridx(a:url, '/')
  let s2 = stridx(a:url, '/', s1+1)
  let s3 = stridx(a:url, '/', s2+1)
  if s3 == -1
    let url .= '/'
  endif
  return url
endfunction

function! s:neglectNeedlessTags(output)
  return substitute(a:output,'<[/]\{0,1\}\(_symbol\|_id\|intenal\|pre_int\|img_alt\|nobr\).\{-\}>','','g')
endfunction

function! s:decordeEntRef(str)
  let str = a:str
  let str = substitute(str, '&quot;',   '"', 'g')
  let str = substitute(str, '&#40;',    '(', 'g')
  let str = substitute(str, '&#41;',    ')', 'g')
  let str = substitute(str, '&laquo;',  '≪', 'g')
  let str = substitute(str, '&raquo;',  '≫', 'g')
  let str = substitute(str, '&lt;',     '<', 'g')
  let str = substitute(str, '&gt;',     '>', 'g')
  let str = substitute(str, '&amp;',    '\&','g')
  let str = substitute(str, '&yen;',    '\\','g')
  let str = substitute(str, '&cent;',   '￠','g')
  let str = substitute(str, '&copy;',   'c', 'g')
  let str = substitute(str, '&middot;', '・','g')
  let str = substitute(str, '&apos;',   "'", 'g')
  return    substitute(str, '&nbsp;',   ' ', 'g')
endfunction

function! s:message(msg)
  redraw
  if a:msg != ''
    echom 'w3m: ' . a:msg
  endif
endfunction

function! s:system(string)
  if exists('*vimproc#system()') && g:w3m#disable_vimproc == 0
    return vimproc#system(a:string)
  else
    return system(a:string)
  endif
endfunction

function! s:downloadFile(url)
  if executable(g:w3m#wget_command)
    let output_dir = input("save dir: ", expand("$HOME"), "dir")
    call s:message('download ' . a:url)
    echo s:system(g:w3m#wget_command . ' -P "' . output_dir . '" ' . a:url)
  endif
endfunction

function! s:is_download_target(href)
  let dot = strridx(a:href, '.')
  if dot == -1
    return 0
  endif
  let ext = strpart(a:href, dot+1)
  if index(g:w3m#download_ext, tolower(ext)) >= 0
    return 1
  endif
  return 0
endfunction

function! s:moveToAnchor(href)
  let aname = a:href[1:]
  for tag in b:tag_list
    if has_key(tag.attr, 'name') && tag.attr.name ==? aname
      call cursor(tag.line, tag.col) 
      break
    endif
  endfor
endfunction

function! s:is_anchor(href)
  if a:href[0] ==? '#'
    return 1
  endif
  return 0
endfunction

function! s:is_tag_input_image_submit(tag)
  if a:tag.tagname ==? 'input_alt'
    if has_key(a:tag.attr,'type') && a:tag.attr.type ==? 'image'
      if has_key(a:tag.attr,'value') && a:tag.attr.value ==? 'submit'
        return 1
      endif
    endif
  endif
  return 0
endfunction

function! s:is_editable_tag(tag)
  if has_key(a:tag.attr,'name') && has_key(a:tag.attr,'type') && a:tag.tagname ==? 'input_alt'
    if a:tag.attr.type ==? 'text' || a:tag.attr.type ==? 'textarea'
      return 1
    endif
  endif
  return 0
endfunction

function! s:is_radio_or_checkbox(tag)
  if has_key(a:tag.attr,'name') && has_key(a:tag.attr,'type') && a:tag.tagname ==? 'input_alt'
    if a:tag.attr.type ==? 'radio' || a:tag.attr.type ==? 'checkbox'
      return 1
    endif
  endif
  return 0
endfunction

function! s:is_tag_tabstop(tag)
  if a:tag.tagname ==? 'a' || a:tag.tagname ==? 'input_alt'
    return 1
  endif
  return 0
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
