w3m.vim
=======

Description
-----------
w3m.vim is a plugin on vim for w3m that is a console web browser.

Requirements
------------
w3m.vim requires [w3m](http://w3m.sourceforge.net/) to be installed.

If w3m is not in your `PATH`, you can specify its location in
your vimrc file.

    let g:w3m#command = 'C:\w3m.exe'
    let g:w3m#command = '/path/to/w3m'

Usage
-----

- Open URL:

        :W3m [url or keyword]

- Search Mode:

        :W3m search-engine-name keyword
    
        [search-engine-name]
        alc              : space alc
        android          : Android SDK
        as3              : ActionScript 3.0
        go               : Go language
        google           : Google
        java             : JDK6
        man              : man
        msdn             : MSDN
        perl             : PERL
        php              : PHP
        python           : Python
        rfc              : RFC
        ruby             : Ruby
        wikipedia        : Wikipedia
        yahoo            : Yahoo
        yahoodict        : Yahoo dictionary
        local            : Local HTML file

- Open URL At New Tab:

        :W3mTab [url or keyword]

- Open URL At Split Window:

        :W3mSplit [url or keyword]

- Open URL At Vertical Split Window:

        :W3mVSplit [url or keyword]

- Open Local Html File

        :W3m local html-file-path

- Close:

        :W3mClose
        or
        :bd

- Copy URL To Clipboard:

        :W3mCopyUrl

- Reload Current Page:

        :W3mReload

- Change Url:

        :W3mAddressBar

- Show External Browser:

        :W3mShowExtenalBrowser

- Syntax Off:

        :W3mSyntaxOff

- Syntax On:

        :W3mSyntaxOn

- Change User-Agent

        :W3mSetUserAgent (w3m|Chrome|Firefox|IE6|IE7|IE8|IE9|Opera|Android|iOS|KDDI|DoCoMo|SoftBank)

- Open from history:

        :W3mHistory

- Clear history:

        input :W3mHistoryClear

Settings
--------

- Highlight:

        highlight! link w3mLink      Function
        highlight! link w3mLinkHover SpecialKey
        highlight! link w3mSubmit    Special
        highlight! link w3mInput     String
        highlight! link w3mBold      Comment
        highlight! link w3mUnderline Underlined
        highlight! link w3mHitAHint  Question
        highlight! link w3mAnchor    Label

- Use Proxy:

        let &HTTP_PROXY='http://xxx.xxx/:8080'

- Set External Browser:

    let g:w3m#external_browser = 'chrome'

- Set Home Page:

        let g:w3m#homepage = "http://www.google.co.jp/"

- Specify Key Of Hit-A-Hint:

        let g:w3m#hit_a_hint_key = 'f'

- Specify Default Search Engine:

        let g:w3m#search_engine = 
            \ 'http://search.yahoo.co.jp/search?search.x=1&fr=top_ga1_sa_124&tid=top_ga1_sa_124&ei=' . &encoding . '&aq=&oq=&p='

- Disable Default Keymap:

You set as follows if you do not want to use default keymap.

    let g:w3m#disable_default_keymap = 1

- Disable Vimproc:

You set as follows if you do not want to use vimproc.

    let g:w3m#disable_vimproc = 1

- Toggle Link Hovering

By default links under the curosr are highlighted. Turn off with one of the following

    unlet g:w3m#set_hover_on
    let g:w3m#hover_set_on = -1 
    " a value less than or equal to 0 will turn it off

    " set delay time until highlighting
    let g:w3m#hover_delay_time = 100

- Search Engine Localization:

Search engines are loaded from `autoload/w3m/search_engines/YOUR_LOCALE/`, and then from the "global" locale
unless a localized search engine of the same name exists. Your locale defaults to `v:lang`, which vim sets
based on your `$LANG` environment variable.

To specify a custom locale for loading search engines:

    let g:w3m#lang = 'en_US'

- Specify path to history file:

    let g:w3m#history#save_file = $HOME.'/.vim_w3m_hist'

Default Keymaps
---------------

* `<CR>`      Open link under the cursor.
* `<S-CR>`    Open link under the cursor (with new tab).
* `<TAB>`     Move cursor next link.
* `<s-TAB>`   Move cursor previous link.
* `<Space>`   Scroll down.
* `<S-Space>` Scroll up.
* `<BS>`      Back page.
* `<A-LEFT>`  Back page.
* `<A-RIGHT>` Forward page.
* `=`         Show href under the cursor.
* `f`         Hit-A-Hint.
* `s`         Toggle Syntax On/Off.
* `c`         Toggle Cookie On/Off.
* `<M-D>`     Edit current url.

ScreenShots
-----------

- Sample Image1

  ![sample1](http://yuratomo.up.seesaa.net/image/w3mvim_v0.4.0.001.png "sample1")

- Hit-A-Hint

  ![sample1](http://yuratomo.up.seesaa.net/image/w3mvim_v0.4.0.002.png "sample1")

