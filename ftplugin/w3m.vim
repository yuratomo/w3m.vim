if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

command! -buffer -nargs=* W3mCopyUrl :call w3m#CopyUrl('*')
command! -buffer -nargs=* W3mReload :call w3m#Reload()
command! -buffer -nargs=* W3mAddressBar :call w3m#EditAddress()
command! -buffer -nargs=* W3mShowTitle :call w3m#ShowTitle()
command! -buffer -nargs=* W3mShowExtenalBrowser :call w3m#ShowExternalBrowser()
command! -buffer -nargs=* W3mShowSource :call w3m#ShowSourceAndHeader()
command! -buffer -nargs=* W3mClose :bd
command! -buffer -nargs=* W3mSyntaxOff :call w3m#ChangeSyntaxOnOff(0)
command! -buffer -nargs=* W3mSyntaxOn :call w3m#ChangeSyntaxOnOff(1)
command! -buffer -nargs=1 -complete=customlist,w3m#ListUserAgent W3mSetUserAgent :call w3m#SetUserAgent('<args>', 1)
