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

###Copy URL To Clipboard:###
    input :W3mCopyUrl

###Reload Current Page:###
    input :W3mReload

###Change Url:###
    input :W3mAddressBar

###Show External Browser:###
    input :W3mShowExtenalBrowser

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

ScreenShots
-----------

###Sample Image1###
![sample1](http://yuratomo.up.seesaa.net/image/w3mvim_v0.4.0.001.png "sample1")

###Hit-A-Hint###
![sample1](http://yuratomo.up.seesaa.net/image/w3mvim_v0.4.0.002.png "sample1")

