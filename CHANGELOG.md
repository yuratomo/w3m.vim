HISTORY
-------

### v1.3.1 by yuratomo
* #21 fix local href

### v1.3.0 by yuratomo
* Support select element.

### v1.2.0 by yuratomo
* Add search-engine for local html file.

### v1.1.1 by yuratomo
* Fix errors that occur during hover hilighting.

### v1.1.0 by yuratomo
* Hover links highlighting. (__thanks dat5h__)
* Fixed default history file (__thanks nise-nabe__)
* Fixed search_engine/rfc.vim

### v1.0.0 by yuratomo
* Add :W3mHistory
* Add :W3mHistoryClear
* Add syntax/w3m.vim
* Add w3m#api#getHistoryList() function
* Add w3m#api#openHistory() function

### v0.8.3 by yuratomo
* Fixed bug when w3m#EditAddress()
* Add search-engine of vims (www.vim.org/scripts)
* Modify post logic

### v0.8.2 by yuratomo
* Add :W3mSplit
* Add search-engine of 2ch
* Should be buffer local commands.
* Fixed bug when check box is pressed.
* Debug and tool function move to another source.

### v0.8.1 by yuratomo
* modify search engine name. (java -> jdk)
* modify msdn's page-filter logic.

### v0.8.0 by yuratomo
* Anchor Correspondence
* add Anchor-Highlight (w3mAnchor)

### v0.7.0 by yuratomo
* Search by specifying search engine (#4)
* Add page-filter function

### v0.6.0 by yuratomo
* add W3mSetUserAgent
* add cookie settings.
*     w3m#option_use_cookie
*     w3m#option_accept_cookie
*     w3m#option_accept_bad_cookie
* add w3m#ToggleSyntaxOnOff() (default key is 's')
* add w3m#ToggleUseCookie() (default key is 'c')
* add default keymap : nmap <m-d> <Plug>(w3m-address-bar)

### v0.5.2 by yuratomo
* bug fix 1 (nmap without <buffer>)
* bug fix 2 (can not execute hit-a-hint)

### v0.5.1 by yuratomo
* corresonds to vimproc
* divided int plugin/w3m.vim and autoload/w3m.vim
* Change the way the map.

### v0.5.0 by yuratomo
* neglect needless tag. (speed up analysis time)

### v0.4.5 by yuratomo
* add :W3mClose
* add :W3mSyntaxOn / :W3mSyntaxOff
* add g:w3m#hit_a_hint_key
* Solution of the character code by &encoding

