w3m.vim
=======

Description
-----------
w3m.vim is a plugin on vim for w3m that is a console web browser.

Usage
-----

###Open URL:###
    input :W3m [url or keyword]

###Open URL At New Tab:###
    input :W3mTab [url or keyword]

###Close:###
    input :W3mClose
    or
    input :bd

###Copy URL To Clipboard:###
    input :W3mCopyUrl

###Reload Current Page:###
    input :W3mReload

###Change Url:###
    input :W3mAddressBar

###Show External Browser:###
    input :W3mShowExtenalBrowser

###Syntax Off:###
    input :W3mSyntaxOff

###Syntax On:###
    input :W3mSyntaxOn

Settings
--------

###Hilight:###
    highlight! link w3mLink      Function
    highlight! link w3mSubmit    Special
    highlight! link w3mInput     String
    highlight! link w3mBold      Comment
    highlight! link w3mUnderline Underlined
    highlight! link w3mHitAHint  Question

###Use Proxy:###
    let &HTTP_PROXY='http://xxx.xxx/:8080'

###Set External Browser:###
    let g:w3m#external_browser = 'chrome'

###Set Home Page:###
    let g:w3m#homepage = "http://www.google.co.jp/"

###Specify Key Of Hit-A-Hint:###
    let g:w3m#hit_a_hint_key = 'f'

###Specify Default Search Engine:###
    let g:w3m#search_engine = 
        \ 'http://search.yahoo.co.jp/search?search.x=1&fr=top_ga1_sa_124&tid=top_ga1_sa_124&ei=' . &encoding . '&aq=&oq=&p='

Default Keymaps
---------------
* &lt;CR&gt;      Open link under the cursor.
* &lt;S-CR&gt;    Open link under the cursor (with new tab).
* &lt;TAB&gt;     Move cursor next link.
* &lt;s-TAB&gt;   Move cursor previous link.
* &lt;Space&gt;   Scroll down.
* &lt;S-Space&gt; Scroll up.
* &lt;BS&gt;      Back page.
* &lt;A-LEFT&gt;  Back page.
* &lt;A-RIGHT&gt; Forward page.
* =         Show href under the cursor.
* f         Hit-A-Hint.

ScreenShots
-----------

###Sample Image1###
![sample1](http://yuratomo.up.seesaa.net/image/w3mvim_v0.4.0.001.png "sample1")

###Hit-A-Hint###
![sample1](http://yuratomo.up.seesaa.net/image/w3mvim_v0.4.0.002.png "sample1")


HISTORY
-------

### v0.5.0 by yuratomo ###
* neglect needless tag. (speed up analysis time)

### v0.4.5 by yuratomo ###
* add :W3mClose
* add :W3mSyntaxOn / :W3mSyntaxOff
* add g:w3m#hit_a_hint_key
* Solution of the character code by &encoding

