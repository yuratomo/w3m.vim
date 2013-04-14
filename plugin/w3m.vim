" File: plugin/w3m.vim
" Last Modified: 2012.05.05
" Version: 1.2.0
" Author: yuratomo (twitter @yusetomo)

if exists('g:loaded_w3m') && g:loaded_w3m == 1
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

let [g:w3m#OPEN_NORMAL,g:w3m#OPEN_SPLIT,g:w3m#OPEN_TAB] = range(3)

if !exists('g:w3m#command')
  let g:w3m#command = 'w3m'
endif
if !exists('g:w3m#option')
  let g:w3m#option = '-o display_charset=' . &encoding . ' -halfdump -o frame=true -o ext_halfdump=1 -o strict_iso2022=0 -o ucs_conv=1'
endif
if !exists('g:w3m#wget_command')
  let g:w3m#wget_command = 'wget'
endif
if !exists('g:w3m#download_ext')
  let g:w3m#download_ext = [ 'zip', 'lzh', 'cab', 'tar', 'gz', 'z', 'exe' ]
endif
if !exists('g:w3m#search_engine')
  let g:w3m#search_engine = 'http://www.google.com/search?ie=' . &encoding . '&q=%s'
endif
if !exists('g:w3m#max_history_num')
  let g:w3m#max_history_num = 30
endif
if !exists('g:w3m#max_cache_page_num')
  let g:w3m#max_cache_page_num = 10
endif
if !exists('g:w3m#external_browser')
  let g:w3m#external_browser = 'chrome'
endif
if !exists('g:w3m#disable_vimproc')
  let g:w3m#disable_vimproc = 0
endif
if !exists('g:w3m#debug')
  let g:w3m#debug = 0
endif
if !exists('g:w3m#hit_a_hint_key')
  let g:w3m#hit_a_hint_key = 'f'
endif
if !exists('g:w3m#option_use_cookie')
  let g:w3m#option_use_cookie = -1
endif
if !exists('g:w3m#option_accept_cookie')
  let g:w3m#option_accept_cookie = -1
endif
if !exists('g:w3m#option_accept_bad_cookie')
  let g:w3m#option_accept_bad_cookie = -1
endif
if !exists('g:w3m#user_agent')
  let g:user_agent = ''
endif
if !exists('g:w3m#search_engine_list')
  let g:w3m#search_engine_list = []
endif
if !exists('g:w3m#page_filter_list')
  let g:w3m#page_filter_list = []
endif
if !exists('g:w3m#user_agent_list')
  let g:w3m#user_agent_list = []
endif
if !exists('g:w3m#set_hover_on')
  let g:w3m#set_hover_on = 1
endif
if !exists('g:w3m#hover_delay_time')
  let g:w3m#hover_delay_time = 100
endif
if !exists('g:w3m#lang')
  let g:w3m#lang = v:lang
endif

call add(g:w3m#user_agent_list, {'name':'w3m',     'agent':''})
call add(g:w3m#user_agent_list, {'name':'Chrome',  'agent':'Mozilla/5.0 (Windows NT 5.1) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/14.0.835.187 Safari/535.1'})
call add(g:w3m#user_agent_list, {'name':'Firefox', 'agent':'Mozilla/5.0 (Windows NT 5.1; rv:7.0.1) Gecko/20100101 Firefox/7.0.1'})
call add(g:w3m#user_agent_list, {'name':'IE6',     'agent':'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; GTB6.6; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)'})
call add(g:w3m#user_agent_list, {'name':'IE7',     'agent':'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; GTB6.6; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)'})
call add(g:w3m#user_agent_list, {'name':'IE8',     'agent':'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; GTB6.6; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)'})
call add(g:w3m#user_agent_list, {'name':'IE9',     'agent':'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C)'})
call add(g:w3m#user_agent_list, {'name':'Opera',   'agent':'Opera 11 Opera/9.80 (Windows NT 5.1; U; ja) Presto/2.7.62 Version/11.00'})
call add(g:w3m#user_agent_list, {'name':'Android', 'agent':'Mozilla/5.0 (Linux; U; Android 2.3.5; ja-jp; T-01D Build/F0001) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1'})
call add(g:w3m#user_agent_list, {'name':'iOS',     'agent':'Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3'})
call add(g:w3m#user_agent_list, {'name':'KDDI',    'agent':'KDDI-HI31 UP.Browser/6.2.0.5 (GUI) MMP/2.0'})
call add(g:w3m#user_agent_list, {'name':'DoCoMo',  'agent':'D502i	DoCoMo/1.0/D502i	DoCoMo/1.0/D502i/c10'})
call add(g:w3m#user_agent_list, {'name':'SoftBank','agent':'SoftBank/1.0/911SH/SHJ001/XXXXXXXXXXXXXXXX Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1'})

if !executable(g:w3m#command)
  echoerr "w3m is not exist!!"
  finish
endif

command! -nargs=* -complete=customlist,w3m#search_engine#List W3m :call w3m#Open(g:w3m#OPEN_NORMAL, <f-args>)
command! -nargs=* -complete=customlist,w3m#search_engine#List W3mTab :call w3m#Open(g:w3m#OPEN_TAB, <f-args>)
command! -nargs=* -complete=customlist,w3m#search_engine#List W3mSplit :call w3m#Open(g:w3m#OPEN_SPLIT, <f-args>)
command! -nargs=* -complete=file W3mLocal :call w3m#Open(g:w3m#OPEN_NORMAL, 'local', <f-args>)
command! -nargs=0 W3mHistory :call w3m#history#Show()
command! -nargs=0 W3mHistoryClear :call w3m#history#Clear()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_w3m = 1
