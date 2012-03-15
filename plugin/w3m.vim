"
" File: w3m.vim
" Last Modified: 2012.03.13
" Version: 0.4.0
" Author: yuratomo
"
" Usage:
"
"   Open URL:
"     input :W3m [url or keyword]
"
"   Open URL At New Tab:
"     input :W3mTab [url or keyword]
"
"   Copy URL To Clipboar:
"     input :W3mCopyUrl
"
"   Reload Current Page:
"     input :W3mReload
"
"   Change Url:
"     input :W3mAddressBar
"
"   Show External Browser:
"     input :W3mShowExtenalBrowser
"
" Setting:
"
"   Hilight:
"     highlight! link w3mLink      Function
"     highlight! link w3mSubmit    Special
"     highlight! link w3mInput     String
"     highlight! link w3mBold      Comment
"     highlight! link w3mUnderline Underlined
"     highlight! link w3mHitAHint  Question
"
"   Use Proxy:
"     let &HTTP_PROXY='http://xxx.xxx/:8080'
"
"   Set External Browser:
"     let g:w3m#external_browser = 'chrome'
"
"   Set Home Page:
"     let g:w3m#homepage = "http://www.google.co.jp/"
"
" Default Keymap:
"   <CR>      Open link under the cursor.
"   <S-CR>    Open link under the cursor (with new tab).
"   <TAB>     Move cursor next link.
"   <s-TAB>   Move cursor previous link.
"   <Space>   Scroll down.
"   <S-Space> Scroll up.
"   <BS>      Back page.
"   <A-LEFT>  Back page.
"   <A-RIGHT> Forward page.
"   =         Show href under the cursor.
"   f         Hit-A-Hint.
"
" History:
"    v0.0.1 ・first version
"    v0.0.2 ・listchars=はグローバルなので設定しないように修正
"           ・URLオープン中にw3mのコマンドではなく、URLを表示するように修正。
"           ・以下のコマンドを追加
"             :W3mTab              を追加(新しいタブで開く)
"             :W3mCopyUrl          クリップボードにURLをコピー
"    v0.0.3 ・ハイライトを"syntax match"ではなく"call matchadd"に変更し、
"           ・範囲指定によりマッチさせるように変更
"           ・cursorlineはハイライト行で処理が遅くなるので削除
"           ・<b>と<u>の対応を入れた。
"    v0.0.4 ・<a HREF=...>のように属性名が大文字だとうまくジャンプできない
"             不具合修正
"           ・w3mInputを[]で見ないでinputタグで見るように修正
"           ・テキストエリアに入力時に[]からはみ出さないように修正。
"           ・リンクの上で<S-CR>を押すと新しいタブで開くようにした。
"    v0.0.5 ・googleのホームから検索できない件修正(input submitをくえりーからはずす)
"           ・テキストエリアのアンダーラインが変だったので修正
"           ・wgetによるzipファイルなどのダウンロード対応
"    v0.1.0 ・a href= にルートからの相対パスが指定されているとリンクがたどれない件修正
"           ・w3mLinkのハイライト定義がないとエラーになる件修正
"           ・w3mを開いたウィンドウにmatch指定が残る問題修正
"           　また、他のウィンドウでw3mのバッファを開くとmatchが消える問題修正
"    v0.2.0 ・input type=radio/checkbox 対応
"           ・2chみたいにa href=http://bar/見たいな属性がある場合に対応
"           ・リロード機能(:W3mReload)追加
"           ・属性の解析がおかしかったので修正
"    v0.2.1 ・属性解析ロジック不具合修正
"           ・<a href='xxx'みたいにシングルクォートが使われている場合に対応
"    v0.3.0 ・:W3mAddressBarを追加
"           ・:W3mShowTitle (タイトル表示)追加
"           ・:W3mShowExtenalBrowser (外部ブラウザ表示)追加
"           ・:W3mShowSource (ソースの表示)追加
"           ・ホームページ指定機能追加 (g:w3m#homepage = ...)
"           ・カーソル下のリンクのURLを表示する機能追加(=)
"    v0.4.0 ・HitAHint機能追加
"           ・ハイライトグループにw3mBoldとw3mUnderlineを追加
"           ・リンクをマウスでクリックできるようにした。
"           ・matchがhlsearchより優先されるのでその対策
"    v0.4.1 ・検索していない状態でinput text等をクリックするとハイライト
"             が誤動作するバグ修正
"    v0.4.2 ・戻る/進む/新しいURLを開く時に前のページのカーソル位置を覚えるように修正
"
"

if exists('g:loaded_w3m') && g:loaded_w3m == 1
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:w3m#command')
  let g:w3m#command = 'w3m'
endif
if !exists('g:w3m#option')
  let g:w3m#option = '-s -halfdump -o frame=true -o ext_halfdump=1 -o strict_iso2022=0 -o ucs_conv=1'
endif
if !exists('g:w3m#wget_command')
  let g:w3m#wget_command = 'wget'
endif
if !exists('g:w3m#download_ext')
  let g:w3m#download_ext = [ 'zip', 'lzh', 'cab', 'tar', 'gz', 'z', 'exe' ]
endif
if !exists('g:w3m#search_engine')
  let g:w3m#search_engine = 
    \ 'http://search.yahoo.co.jp/search?search.x=1&fr=top_ga1_sa_124&tid=top_ga1_sa_124&ei=SHIFT_JIS&aq=&oq=&p='
endif
if !exists('g:w3m#max_history_num')
  let g:w3m#max_history_num = 10
endif
if !exists('g:w3m#external_browser')
  let g:w3m#external_browser = 'chrome'
endif
if !exists('g:w3m#debug')
  let g:w3m#debug = 0
endif
if !executable(g:w3m#command)
  echoerr "w3m is not exist!!"
  finish
endif

let s:w3m_title = 'w3m'
let s:message_adjust = 20
let s:tmp_option = ''
let [s:TAG_START,s:TAG_END,s:TAG_BOTH,s:TAG_UNKNOWN] = range(4)

command! -nargs=* W3m :call w3m#Open(<f-args>)
command! -nargs=* W3mTab :call w3m#OpenAtNewTab(<f-args>)
command! -nargs=* W3mCopyUrl :call w3m#CopyUrl('*')
command! -nargs=* W3mReload :call w3m#Reload()
command! -nargs=* W3mAddressBar :call w3m#EditAddress()
command! -nargs=* W3mShowTitle :call w3m#ShowTitle()
command! -nargs=* W3mShowExtenalBrowser :call w3m#ShowExternalBrowser()
command! -nargs=* W3mShowSource :call w3m#ShowSourceAndHeader()

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
      let tidx = -1
      break
    endif
    if b:tag_list[tidx].type != s:TAG_START
      let tidx -= 1
      continue
    endif
    if has_key(b:tag_list[tidx].attr, 'href')
      break
    endif
    let tidx -= 1
  endwhile

  if tidx >= 0
    echo b:tag_list[tidx].attr.href
  endif
endfunction

function! w3m#Debug()
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
  call setline(didx, 'query=' . s:buildQueryString())
  let didx += 1
  call setline(didx, b:debug_msg)
  let didx += 1

  setlocal nomodifiable
endfunction
function! s:ddd(msg)
  if g:w3m#debug == 1 && exists('b:debug_msg')
    call add(b:debug_msg, a:msg)
  endif
endfunction

function! w3m#ShowUsage()
  echo "[Usage] :W3m url"
  echo "example :W3m http://www.yahoo.co.jp"
endfunction

function! w3m#ShowTitle()
  if exists('b:last_url')
    let title = "no title"
    for tag in b:tag_list
      if tag.type == s:TAG_START && tag.tagname ==? 'title_alt' && has_key(tag.attr, 'title')
        let title = tag.attr.title
        break
      endif
    endfor
    call s:message(title)
  endif
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
    call system(g:w3m#external_browser . ' "' . b:last_url . '"')
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
    call w3m#Open(b:last_url)
  endif
endfunction

function! w3m#EditAddress()
  if exists('b:last_url')
    let url = input('url:', b:last_url)
    call w3m#Open(url)
  endif
endfunction

function! w3m#MatchSearch()
  if exists('b:last_search_id') && b:last_search_id != -1
    try 
      call matchdelete(b:last_search_id)
    catch
    endtry
  endif
  let keyword = histget("search", -1)
  if keyword == '^.*$\n'
    return
  endif
  let b:last_search_id = matchadd("Search", keyword)
endfunction

function! w3m#OpenAtNewTab(...)
  tabe
  call w3m#Open(join(a:000, ' '))
endfunction

function! w3m#Open(...)
  if len(a:000) == 0
    if exists('g:w3m#homepage')
      call w3m#Open(g:w3m#homepage)
    else
      call w3m#ShowUsage()
    endif
    return
  endif

  call s:prepare_buffer()
  if b:history_index >= 0 && b:history_index < len(b:history)
    let b:history[b:history_index].curpos = [ line('.'), col('.') ]
  endif

  if s:isHttpURL(a:000[0])
    let url = s:normalizeUrl(a:000[0])
  else
    let url = g:w3m#search_engine . join(a:000, ' ')
  endif
  if len(b:history) - 1 > b:history_index
    call remove(b:history, b:history_index+1, -1)
  endif
  let cols = winwidth(0) - &numberwidth
  let cmdline = join( [ g:w3m#command, s:tmp_option, g:w3m#option, '-cols', cols, '"' . url . '"' ], ' ')
  call s:message( strpart('open ' . url, 0, cols - s:message_adjust) )
  call add(b:history, {'url':url, 'outputs':split(system(cmdline), '\n')} )
  let b:history_index = len(b:history) - 1
  if b:history_index >= g:w3m#max_history_num
    call remove(b:history, 0, 0)
    let b:history_index = len(b:history) - 1
  endif

  call s:openCurrentHistory()
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

  "call s:message('done')
  call w3m#ShowTitle()
endfunction

function! s:post(url, file)
  let s:tmp_option = '-post ' . a:file
  call w3m#Open(a:url)
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
  setlocal bt=nofile noswf nomodifiable nowrap hidden nolist
endfunction

function! s:analizeOutputs(output_lines)
  let display_lines = []
  let b:tag_list = []
  let b:form_list = []

  let cline = 1
  for line in a:output_lines
    let analaized_line = ''
    let [lidx, ltidx, gtidx] = [ 0, -1, -1 ]
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

    let a:attr[tolower(strpart(a:tag, ks, ke-ks+1))] = s:decordeEntRef(strpart(a:tag, vs, ve-vs+1))
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
    let b:form_list = []
    let b:debug_msg = []
    let b:click_with_shift = 0
    let b:last_search_id = -1

    call s:keymap()
    call s:default_highligh()

    augroup w3m
      au BufWinEnter <buffer> silent! call w3m#BufWinEnter()
      au BufWinLeave <buffer> silent! call w3m#BufWinLeave()
    augroup END
  endif
endfunction

function! s:keymap()
  if !exists('g:w3m#disable_default_keymap') || g:w3m#disable_default_keymap == 0
    nnoremap <buffer> <CR> :call w3m#Click(0)<CR>
    nnoremap <buffer> <S-CR> :call w3m#Click(1)<CR>
    nnoremap <buffer> <TAB> :call w3m#NextLink()<CR>
    nnoremap <buffer> <s-TAB> :call w3m#PrevLink()<CR>
    nnoremap <buffer> <Space>   10<C-E>
    nnoremap <buffer> <S-Space> 10<C-Y>
    nnoremap <buffer> <BS> :call w3m#Back()<CR>
    nnoremap <buffer> <A-LEFT> :call w3m#Back()<CR>
    nnoremap <buffer> <A-RIGHT> :call w3m#Forward()<CR>
    nnoremap <buffer> = :call w3m#CheckUnderCursor()<CR>
    cnoremap <buffer> <CR> <CR>:call w3m#MatchSearch()<CR>
    nnoremap <buffer> * *:call w3m#MatchSearch()<CR>
    nnoremap <buffer> # #:call w3m#MatchSearch()<CR>
    nnoremap <buffer> f :call w3m#HitAHint()<CR>
    nnoremap <buffer> <LeftMouse> <LeftMouse>:call w3m#Click(0)<CR>
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
  if !hlexists('w3mHitAHint')
    highlight! link w3mHitAHint Question
  endif
endfunction

function! s:applySyntax()
  let link_s = -1
  let bold_s = -1
  let underline_s = -1
  let input_s = -1
  let input_highlight = ""
  for tag in b:tag_list
    if link_s == -1 && tag.tagname ==? 'a' && tag.type == s:TAG_START
      if tag.col > 0
        let link_s = tag.col -1
      else
        let link_s = 0
      endif
    elseif link_s != -1 && tag.tagname ==? 'a' && tag.type == s:TAG_END
      let link_e = tag.col
      call matchadd('w3mLink', '\%>'.link_s.'c\%<'.link_e.'c\%'.tag.line.'l')
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
    else
      if b:click_with_shift == 1
        call w3m#OpenAtNewTab(url)
      else
        call w3m#Open(url)
      endif
    endif
  endif
  return 1
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
    while idx >= 0
      if b:tag_list[idx].type == s:TAG_START && stridx(b:tag_list[idx].tagname, 'form') == 0
       if has_key(b:tag_list[idx].attr,'action') 
         let url = s:resolveUrl(b:tag_list[idx].attr.action)
         if has_key(b:tag_list[idx].attr,'method') 
           let action = b:tag_list[idx].attr.method
         endif
         break
       endif
     endif
     let idx -= 1
    endwhile

    if url != ''
      if action ==? 'GET'
        let query = s:buildQueryString()
        call w3m#Open(url . query)
      elseif action ==? 'POST'
        let file = s:generatePostFile()
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
    if has_key(item, 'type') && item.type ==? 'radio'
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

function! s:resolveUrl(url)
  if s:isHttpURL(a:url)
    return s:decordeEntRef(a:url)
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

function! s:buildQueryString()
  let query = ''
  let first = 1
  for item in b:form_list
    if has_key(item.attr,'name') && has_key(item.attr,'value') && item.attr.name != ''
      if has_key(item.attr,'type')
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
        let value = item.attr.value
      else
        let value = item.evalue
      endif
      let query .= item.attr.name . '=' . s:encodeUrl(value)
    endif
  endfor
  return query
endfunction

function! s:generatePostFile()
  let tmp_file = tempname()
  let items = []

  for item in b:form_list
    if has_key(item.attr,'name') && has_key(item.attr,'value') && item.attr.name != ''
      if has_key(item.attr,'type')
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

      if item.edited == 0
        let value = item.attr.value
      else
        let value = item.evalue
      endif
      call add(items,  item.attr.name . '=' . s:encodeUrl(value))
    endif
  endfor

  call writefile(items, tmp_file)
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

function! w3m#HitAHint()
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
  call feedkeys('/@')
endfunction

function! w3m#HitAHintEnd()
  cnoremap <buffer> <CR> <CR>:call w3m#MatchSearch()<CR>
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

function! s:downloadFile(url)
  if executable(g:w3m#wget_command)
    let output_dir = input("save dir: ", expand("$HOME"), "dir")
    call s:message('download ' . a:url)
    echo system(g:w3m#wget_command . ' -P "' . output_dir . '" ' . a:url)
  endif
endfunction

function! s:is_download_target(url)
  let dot = strridx(a:url, '.')
  let ext = strpart(a:url, dot+1)
  if index(g:w3m#download_ext, tolower(ext)) >= 0
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

let g:loaded_w3m = 1
