#include-once

; #INDEX# =======================================================================================================================
; Title .........: Rebar_Constants
; AutoIt Version : 3.2
; Language ......: English
; Description ...: Constants for Rebar functions.
; Author(s) .....: Valik, Gary Frost, ...
; ===============================================================================================================================

; #MESSAGES# ====================================================================================================================
Global Const $__REBARCONSTANT_WM_USER = 0X400
Global Const $RB_BEGINDRAG = ($__REBARCONSTANT_WM_USER + 24)
Global Const $RB_DELETEBAND = ($__REBARCONSTANT_WM_USER + 2)
Global Const $RB_DRAGMOVE = ($__REBARCONSTANT_WM_USER + 26)
Global Const $RB_ENDDRAG = ($__REBARCONSTANT_WM_USER + 25)
Global Const $RB_GETBANDBORDERS = ($__REBARCONSTANT_WM_USER + 34)
Global Const $RB_GETBANDCOUNT = ($__REBARCONSTANT_WM_USER + 12)
Global Const $RB_GETBANDINFO = ($__REBARCONSTANT_WM_USER + 5)
Global Const $RB_GETBANDINFOA = ($__REBARCONSTANT_WM_USER + 29)
Global Const $RB_GETBANDINFOW = ($__REBARCONSTANT_WM_USER + 28)
Global Const $RB_GETBANDMARGINS = ($__REBARCONSTANT_WM_USER + 40)
Global Const $RB_GETBARHEIGHT = ($__REBARCONSTANT_WM_USER + 27)
Global Const $RB_GETBARINFO = ($__REBARCONSTANT_WM_USER + 3)
Global Const $RB_GETBKCOLOR = ($__REBARCONSTANT_WM_USER + 20)
Global Const $RB_GETCOLORSCHEME = 0x2000 + 3
Global Const $RB_GETDROPTARGET = (0x2000 + 4)
Global Const $RB_GETPALETTE = ($__REBARCONSTANT_WM_USER + 38)
Global Const $RB_GETRECT = ($__REBARCONSTANT_WM_USER + 9)
Global Const $RB_GETROWCOUNT = ($__REBARCONSTANT_WM_USER + 13)
Global Const $RB_GETROWHEIGHT = ($__REBARCONSTANT_WM_USER + 14)
Global Const $RB_GETTEXTCOLOR = ($__REBARCONSTANT_WM_USER + 22)
Global Const $RB_GETTOOLTIPS = ($__REBARCONSTANT_WM_USER + 17)
Global Const $RB_GETUNICODEFORMAT = 0x2000 + 6
Global Const $RB_HITTEST = ($__REBARCONSTANT_WM_USER + 8)
Global Const $RB_IDTOINDEX = ($__REBARCONSTANT_WM_USER + 16)
Global Const $RB_INSERTBANDA = ($__REBARCONSTANT_WM_USER + 1)
Global Const $RB_INSERTBANDW = ($__REBARCONSTANT_WM_USER + 10)
Global Const $RB_MAXIMIZEBAND = ($__REBARCONSTANT_WM_USER + 31)
Global Const $RB_MINIMIZEBAND = ($__REBARCONSTANT_WM_USER + 30)
Global Const $RB_MOVEBAND = ($__REBARCONSTANT_WM_USER + 39)
Global Const $RB_PUSHCHEVRON = ($__REBARCONSTANT_WM_USER + 43)
Global Const $RB_SETBANDINFOA = ($__REBARCONSTANT_WM_USER + 6)
Global Const $RB_SETBANDINFOW = ($__REBARCONSTANT_WM_USER + 11)
Global Const $RB_SETBARINFO = ($__REBARCONSTANT_WM_USER + 4)
Global Const $RB_SETBKCOLOR = ($__REBARCONSTANT_WM_USER + 19)
Global Const $RB_SETCOLORSCHEME = 0x2000 + 2
Global Const $RB_SETPALETTE = ($__REBARCONSTANT_WM_USER + 37)
Global Const $RB_SETPARENT = ($__REBARCONSTANT_WM_USER + 7)
Global Const $RB_SETTEXTCOLOR = ($__REBARCONSTANT_WM_USER + 21)
Global Const $RB_SETTOOLTIPS = ($__REBARCONSTANT_WM_USER + 18)
Global Const $RB_SETUNICODEFORMAT = 0x2000 + 5
Global Const $RB_SETWINDOWTHEME = 0x2000 + 11
Global Const $RB_SHOWBAND = ($__REBARCONSTANT_WM_USER + 35)
Global Const $RB_SIZETORECT = ($__REBARCONSTANT_WM_USER + 23)
; ===============================================================================================================================

; #NOTIFICATIONS# ===============================================================================================================
Global Const $RBN_FIRST = (-831)
Global Const $RBN_AUTOBREAK = ($RBN_FIRST - 22)
Global Const $RBN_AUTOSIZE = ($RBN_FIRST - 3)
Global Const $RBN_BEGINDRAG = ($RBN_FIRST - 4)
Global Const $RBN_CHEVRONPUSHED = ($RBN_FIRST - 10)
Global Const $RBN_CHILDSIZE = ($RBN_FIRST - 8)
Global Const $RBN_DELETEDBAND = ($RBN_FIRST - 7)
Global Const $RBN_DELETINGBAND = ($RBN_FIRST - 6)
Global Const $RBN_ENDDRAG = ($RBN_FIRST - 5)
Global Const $RBN_GETOBJECT = ($RBN_FIRST - 1)
Global Const $RBN_HEIGHTCHANGE = ($RBN_FIRST - 0)
Global Const $RBN_LAYOUTCHANGED = ($RBN_FIRST - 2)
Global Const $RBN_MINMAX = ($RBN_FIRST - 21)
; ===============================================================================================================================

; #STYLES# ======================================================================================================================
Global Const $RBS_AUTOSIZE = 0x2000
Global Const $RBS_BANDBORDERS = 0X400
Global Const $RBS_DBLCLKTOGGLE = 0x8000
Global Const $RBS_FIXEDORDER = 0x800
Global Const $RBS_REGISTERDROP = 0x1000
Global Const $RBS_TOOLTIPS = 0x100
Global Const $RBS_VARHEIGHT = 0X200
Global Const $RBS_VERTICALGRIPPER = 0x4000

; $tagREBARBANDINFO constants for fmask
Global Const $RBBIM_STYLE = 0x1
Global Const $RBBIM_COLORS = 0x2
Global Const $RBBIM_TEXT = 0x4
Global Const $RBBIM_IMAGE = 0x8
Global Const $RBBIM_CHILD = 0x10
Global Const $RBBIM_CHILDSIZE = 0x20
Global Const $RBBIM_SIZE = 0x40
Global Const $RBBIM_BACKGROUND = 0x80
Global Const $RBBIM_ID = 0x100
Global Const $RBBIM_IDEALSIZE = 0x200
Global Const $RBBIM_LPARAM = 0x400
Global Const $RBBIM_HEADERSIZE = 0x800

; $tagREBARINFO constants for fmask
Global Const $RBIM_IMAGELIST = 0x1

; $tagREBARBANDINFO constants for fstyle
Global Const $RBBS_BREAK = 0x1 ; The band is on a new line
Global Const $RBBS_CHILDEDGE = 0x4 ; The band has an edge at the top and bottom of the child window
Global Const $RBBS_FIXEDBMP = 0x20 ; The background bitmap does not move when the band is resized
Global Const $RBBS_FIXEDSIZE = 0x2 ; The band can't be sized. With this style, the sizing grip is not displayed on the band
Global Const $RBBS_GRIPPERALWAYS = 0x80 ; The band will always have a sizing grip, even if it is the only band in the rebar
Global Const $RBBS_HIDDEN = 0x8 ; The band will not be visible
Global Const $RBBS_HIDETITLE = 0x400 ; Keep band title hidden
Global Const $RBBS_NOGRIPPER = 0x100 ; The band will never have a sizing grip, even if there is more than one band in the rebar
Global Const $RBBS_NOVERT = 0x10 ; Don't show when vertical
Global Const $RBBS_TOPALIGN = 0x800 ; Keep band in top row
Global Const $RBBS_USECHEVRON = 0x200 ; Display drop-down button
Global Const $RBBS_VARIABLEHEIGHT = 0x40 ; The band can be resized by the rebar control; cyIntegral and cyMaxChild affect how the rebar will resize the band

; $tagRBHITTESTINFO constants for flags
Global Const $RBHT_CAPTION = 0x2
Global Const $RBHT_CHEVRON = 0x8
Global Const $RBHT_CLIENT = 0x3
Global Const $RBHT_GRABBER = 0x4
Global Const $RBHT_NOWHERE = 0x1

; $tagNMREBAR constants for dwMask
Global Const $RBNM_ID = 0x1
Global Const $RBNM_LPARAM = 0x4
Global Const $RBNM_STYLE = 0x2
; ===============================================================================================================================
