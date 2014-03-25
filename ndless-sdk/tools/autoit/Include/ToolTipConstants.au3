#include-once

; #INDEX# =======================================================================================================================
; Title .........: ToolTip_Constants
; AutoIt Version : 3.2
; Language ......: English
; Description ...: Constants for ToolTip functions.
; Author(s) .....: Valik, Gary Frost, ...
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $TTF_IDISHWND = 0x00000001
Global Const $TTF_CENTERTIP = 0x00000002
Global Const $TTF_RTLREADING = 0x00000004
Global Const $TTF_SUBCLASS = 0x00000010
Global Const $TTF_TRACK = 0x00000020
Global Const $TTF_ABSOLUTE = 0x00000080
Global Const $TTF_TRANSPARENT = 0x00000100
Global Const $TTF_PARSELINKS = 0x00001000
Global Const $TTF_DI_SETITEM = 0x00008000
; ===============================================================================================================================

; #MESSAGES# ====================================================================================================================
Global Const $__TOOLTIPCONSTANTS_WM_USER = 0X400
Global Const $TTM_ACTIVATE = $__TOOLTIPCONSTANTS_WM_USER + 1
Global Const $TTM_SETDELAYTIME = $__TOOLTIPCONSTANTS_WM_USER + 3
Global Const $TTM_ADDTOOL = $__TOOLTIPCONSTANTS_WM_USER + 4
Global Const $TTM_DELTOOL = $__TOOLTIPCONSTANTS_WM_USER + 5
Global Const $TTM_NEWTOOLRECT = $__TOOLTIPCONSTANTS_WM_USER + 6
Global Const $TTM_GETTOOLINFO = $__TOOLTIPCONSTANTS_WM_USER + 8
Global Const $TTM_SETTOOLINFO = $__TOOLTIPCONSTANTS_WM_USER + 9
Global Const $TTM_HITTEST = $__TOOLTIPCONSTANTS_WM_USER + 10
Global Const $TTM_GETTEXT = $__TOOLTIPCONSTANTS_WM_USER + 11
Global Const $TTM_UPDATETIPTEXT = $__TOOLTIPCONSTANTS_WM_USER + 12
Global Const $TTM_GETTOOLCOUNT = $__TOOLTIPCONSTANTS_WM_USER + 13
Global Const $TTM_ENUMTOOLS = $__TOOLTIPCONSTANTS_WM_USER + 14
Global Const $TTM_GETCURRENTTOOL = $__TOOLTIPCONSTANTS_WM_USER + 15
Global Const $TTM_WINDOWFROMPOINT = $__TOOLTIPCONSTANTS_WM_USER + 16
Global Const $TTM_TRACKACTIVATE = $__TOOLTIPCONSTANTS_WM_USER + 17
Global Const $TTM_TRACKPOSITION = $__TOOLTIPCONSTANTS_WM_USER + 18
Global Const $TTM_SETTIPBKCOLOR = $__TOOLTIPCONSTANTS_WM_USER + 19
Global Const $TTM_SETTIPTEXTCOLOR = $__TOOLTIPCONSTANTS_WM_USER + 20
Global Const $TTM_GETDELAYTIME = $__TOOLTIPCONSTANTS_WM_USER + 21
Global Const $TTM_GETTIPBKCOLOR = $__TOOLTIPCONSTANTS_WM_USER + 22
Global Const $TTM_GETTIPTEXTCOLOR = $__TOOLTIPCONSTANTS_WM_USER + 23
Global Const $TTM_SETMAXTIPWIDTH = $__TOOLTIPCONSTANTS_WM_USER + 24
Global Const $TTM_GETMAXTIPWIDTH = $__TOOLTIPCONSTANTS_WM_USER + 25
Global Const $TTM_SETMARGIN = $__TOOLTIPCONSTANTS_WM_USER + 26
Global Const $TTM_GETMARGIN = $__TOOLTIPCONSTANTS_WM_USER + 27
Global Const $TTM_POP = $__TOOLTIPCONSTANTS_WM_USER + 28
Global Const $TTM_UPDATE = $__TOOLTIPCONSTANTS_WM_USER + 29
Global Const $TTM_GETBUBBLESIZE = $__TOOLTIPCONSTANTS_WM_USER + 30
Global Const $TTM_ADJUSTRECT = $__TOOLTIPCONSTANTS_WM_USER + 31
Global Const $TTM_SETTITLE = $__TOOLTIPCONSTANTS_WM_USER + 32
Global Const $TTM_SETTITLEW = $__TOOLTIPCONSTANTS_WM_USER + 33
Global Const $TTM_POPUP = $__TOOLTIPCONSTANTS_WM_USER + 34
Global Const $TTM_GETTITLE = $__TOOLTIPCONSTANTS_WM_USER + 35
Global Const $TTM_ADDTOOLW = $__TOOLTIPCONSTANTS_WM_USER + 50
Global Const $TTM_DELTOOLW = $__TOOLTIPCONSTANTS_WM_USER + 51
Global Const $TTM_NEWTOOLRECTW = $__TOOLTIPCONSTANTS_WM_USER + 52
Global Const $TTM_GETTOOLINFOW = $__TOOLTIPCONSTANTS_WM_USER + 53
Global Const $TTM_SETTOOLINFOW = $__TOOLTIPCONSTANTS_WM_USER + 54
Global Const $TTM_HITTESTW = $__TOOLTIPCONSTANTS_WM_USER + 55
Global Const $TTM_GETTEXTW = $__TOOLTIPCONSTANTS_WM_USER + 56
Global Const $TTM_UPDATETIPTEXTW = $__TOOLTIPCONSTANTS_WM_USER + 57
Global Const $TTM_ENUMTOOLSW = $__TOOLTIPCONSTANTS_WM_USER + 58
Global Const $TTM_GETCURRENTTOOLW = $__TOOLTIPCONSTANTS_WM_USER + 59
Global Const $TTM_SETWINDOWTHEME = 0x2000 + 11
; ===============================================================================================================================

; #NOTIFICATIONS# ===============================================================================================================
Global Const $TTN_FIRST = -520
Global Const $TTN_GETDISPINFO = $TTN_FIRST - 0 ; Sent to retrieve information needed to display a ToolTip
Global Const $TTN_SHOW = $TTN_FIRST - 1 ; Notifies the owner window that a ToolTip control is about to be displayed
Global Const $TTN_POP = $TTN_FIRST - 2 ; Notifies the owner window that a ToolTip is about to be hidden
Global Const $TTN_LINKCLICK = $TTN_FIRST - 3 ; Sent when a text link inside a balloon ToolTip is clicked
Global Const $TTN_GETDISPINFOW = $TTN_FIRST - 10 ; [Unicode] Sent to retrieve information needed to display a ToolTip
; ===============================================================================================================================

; #STYLES# ======================================================================================================================
Global Const $TTS_ALWAYSTIP = 0x00000001 ; The control appears when the cursor is on a tool
Global Const $TTS_NOPREFIX = 0x00000002 ; Prevents the stripping of the ampersand character from a string
Global Const $TTS_NOANIMATE = 0x00000010 ; Disables sliding ToolTip animation
Global Const $TTS_NOFADE = 0x00000020 ; Disables fading ToolTip animation
Global Const $TTS_BALLOON = 0x00000040 ; The control has the appearance of a cartoon balloon
Global Const $TTS_CLOSE = 0x00000080 ; Displays a close box in the ToolTip corner
; ===============================================================================================================================
