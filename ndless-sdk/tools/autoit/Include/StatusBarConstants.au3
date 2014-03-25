#include-once

; #INDEX# =======================================================================================================================
; Title .........: StatusBar_Constants
; AutoIt Version : 3.2
; Language ......: English
; Description ...: Constants for StatusBar functions.
; Author(s) .....: Valik, Gary Frost, ...
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
;=== Status Bar Styles
Global Const $SBARS_SIZEGRIP = 0x100
Global Const $SBT_TOOLTIPS = 0x800
Global Const $SBARS_TOOLTIPS = 0x800
;=== uFlags
Global Const $SBT_SUNKEN = 0x0 ;Default
Global Const $SBT_NOBORDERS = 0x100 ;The text is drawn without borders.
Global Const $SBT_POPOUT = 0x200 ; The text is drawn with a border to appear higher than the plane of the window.
Global Const $SBT_RTLREADING = 0x400 ;SB_SETTEXT, SB_SETTEXT, SB_GETTEXTLENGTH flags only: Displays text using right-to-left reading order on Hebrew or Arabic systems.
Global Const $SBT_NOTABPARSING = 0x800 ;Tab characters are ignored.
Global Const $SBT_OWNERDRAW = 0x1000 ;The text is drawn by the parent window.
;=== Messages to send to Statusbar
Global Const $__STATUSBARCONSTANT_WM_USER = 0X400
Global Const $SB_GETBORDERS = ($__STATUSBARCONSTANT_WM_USER + 7)
Global Const $SB_GETICON = ($__STATUSBARCONSTANT_WM_USER + 20)
Global Const $SB_GETPARTS = ($__STATUSBARCONSTANT_WM_USER + 6)
Global Const $SB_GETRECT = ($__STATUSBARCONSTANT_WM_USER + 10)
Global Const $SB_GETTEXTA = ($__STATUSBARCONSTANT_WM_USER + 2)
Global Const $SB_GETTEXTW = ($__STATUSBARCONSTANT_WM_USER + 13)
Global Const $SB_GETTEXT = $SB_GETTEXTA
Global Const $SB_GETTEXTLENGTHA = ($__STATUSBARCONSTANT_WM_USER + 3)
Global Const $SB_GETTEXTLENGTHW = ($__STATUSBARCONSTANT_WM_USER + 12)
Global Const $SB_GETTEXTLENGTH = $SB_GETTEXTLENGTHA
Global Const $SB_GETTIPTEXTA = ($__STATUSBARCONSTANT_WM_USER + 18)
Global Const $SB_GETTIPTEXTW = ($__STATUSBARCONSTANT_WM_USER + 19)
Global Const $SB_GETUNICODEFORMAT = 0x2000 + 6

Global Const $SB_ISSIMPLE = ($__STATUSBARCONSTANT_WM_USER + 14)

Global Const $SB_SETBKCOLOR = 0x2000 + 1
Global Const $SB_SETICON = ($__STATUSBARCONSTANT_WM_USER + 15)
Global Const $SB_SETMINHEIGHT = ($__STATUSBARCONSTANT_WM_USER + 8)
Global Const $SB_SETPARTS = ($__STATUSBARCONSTANT_WM_USER + 4)
Global Const $SB_SETTEXTA = ($__STATUSBARCONSTANT_WM_USER + 1)
Global Const $SB_SETTEXTW = ($__STATUSBARCONSTANT_WM_USER + 11)
Global Const $SB_SETTEXT = $SB_SETTEXTA
Global Const $SB_SETTIPTEXTA = ($__STATUSBARCONSTANT_WM_USER + 16)
Global Const $SB_SETTIPTEXTW = ($__STATUSBARCONSTANT_WM_USER + 17)
Global Const $SB_SETUNICODEFORMAT = 0x2000 + 5
Global Const $SB_SIMPLE = ($__STATUSBARCONSTANT_WM_USER + 9)

Global Const $SB_SIMPLEID = 0xff
; ===============================================================================================================================

; #NOTIFICATIONS# ===============================================================================================================
Global Const $SBN_FIRST = -880
Global Const $SBN_SIMPLEMODECHANGE = $SBN_FIRST - 0 ; Sent when the simple mode changes due to a $SB_SIMPLE message
; ===============================================================================================================================
