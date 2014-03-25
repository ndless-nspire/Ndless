#include-once

; #INDEX# =======================================================================================================================
; Title .........: ListBox_Constants
; AutoIt Version : 3.2
; Language ......: English
; Description ...: <a href="../appendix/GUIStyles.htm#List">GUI control ListBox styles</a> and much more constants.
; Author(s) .....: Valik, Gary Frost, ...
; ===============================================================================================================================

; #STYLES# ======================================================================================================================
Global Const $LBS_NOTIFY = 0x00000001 ; Notifies whenever the user clicks or double clicks a string
Global Const $LBS_SORT = 0x00000002 ; Sorts strings in the list box alphabetically
Global Const $LBS_NOREDRAW = 0x00000004 ; Specifies that the appearance is not updated when changes are made
Global Const $LBS_MULTIPLESEL = 0x00000008 ; Turns string selection on or off each time the user clicks a string
Global Const $LBS_OWNERDRAWFIXED = 0x00000010 ; Specifies that the list box is owner drawn
Global Const $LBS_OWNERDRAWVARIABLE = 0x00000020 ; Specifies that the list box is owner drawn with variable height
Global Const $LBS_HASSTRINGS = 0x00000040 ; Specifies that a list box contains items consisting of strings
Global Const $LBS_USETABSTOPS = 0x00000080 ; Enables a list box to recognize and expand tab characters
Global Const $LBS_NOINTEGRALHEIGHT = 0x00000100 ; Specifies that the size is exactly the size set by the application
Global Const $LBS_MULTICOLUMN = 0x00000200 ; Specifies a multi columnn list box that is scrolled horizontally
Global Const $LBS_WANTKEYBOARDINPUT = 0x00000400 ; Specifies that the owner window receives WM_VKEYTOITEM messages
Global Const $LBS_EXTENDEDSEL = 0x00000800 ; Allows multiple items to be selected
Global Const $LBS_DISABLENOSCROLL = 0x00001000 ; Shows a disabled vertical scroll bar
Global Const $LBS_NODATA = 0x00002000 ; Specifies a no-data list box
Global Const $LBS_NOSEL = 0x00004000 ; Specifies that items that can be viewed but not selected
Global Const $LBS_COMBOBOX = 0x00008000 ; Notifies a list box that it is part of a combo box
Global Const $LBS_STANDARD = 0x00000003 ; Standard list box style
; ===============================================================================================================================

; #ERRORS# ======================================================================================================================
Global Const $LB_ERR = -1
Global Const $LB_ERRATTRIBUTE = -3
Global Const $LB_ERRREQUIRED = -4
Global Const $LB_ERRSPACE = -2
; ===============================================================================================================================

; #MESSAGES# ====================================================================================================================
Global Const $LB_ADDSTRING = 0x0180
Global Const $LB_INSERTSTRING = 0x0181
Global Const $LB_DELETESTRING = 0x0182
Global Const $LB_SELITEMRANGEEX = 0x0183
Global Const $LB_RESETCONTENT = 0x0184
Global Const $LB_SETSEL = 0x0185
Global Const $LB_SETCURSEL = 0x0186
Global Const $LB_GETSEL = 0x0187
Global Const $LB_GETCURSEL = 0x0188
Global Const $LB_GETTEXT = 0x0189
Global Const $LB_GETTEXTLEN = 0x018A
Global Const $LB_GETCOUNT = 0x018B
Global Const $LB_SELECTSTRING = 0x018C
Global Const $LB_DIR = 0x018D
Global Const $LB_GETTOPINDEX = 0x018E
Global Const $LB_FINDSTRING = 0x018F
Global Const $LB_GETSELCOUNT = 0x0190
Global Const $LB_GETSELITEMS = 0x0191
Global Const $LB_SETTABSTOPS = 0x0192
Global Const $LB_GETHORIZONTALEXTENT = 0x0193
Global Const $LB_SETHORIZONTALEXTENT = 0x0194
Global Const $LB_SETCOLUMNWIDTH = 0x0195
Global Const $LB_ADDFILE = 0x0196
Global Const $LB_SETTOPINDEX = 0x0197
Global Const $LB_GETITEMRECT = 0x0198
Global Const $LB_GETITEMDATA = 0x0199
Global Const $LB_SETITEMDATA = 0x019A
Global Const $LB_SELITEMRANGE = 0x019B
Global Const $LB_SETANCHORINDEX = 0x019C
Global Const $LB_GETANCHORINDEX = 0x019D
Global Const $LB_SETCARETINDEX = 0x019E
Global Const $LB_GETCARETINDEX = 0x019F
Global Const $LB_SETITEMHEIGHT = 0x01A0
Global Const $LB_GETITEMHEIGHT = 0x01A1
Global Const $LB_FINDSTRINGEXACT = 0x01A2
Global Const $LB_SETLOCALE = 0x01A5
Global Const $LB_GETLOCALE = 0x01A6
Global Const $LB_SETCOUNT = 0x01A7
Global Const $LB_INITSTORAGE = 0x01A8
Global Const $LB_ITEMFROMPOINT = 0x01A9
Global Const $LB_MULTIPLEADDSTRING = 0x01B1
Global Const $LB_GETLISTBOXINFO = 0x01B2
; ================================================================================================================================

; #NOTIFICATIONS# ===============================================================================================================
Global Const $LBN_ERRSPACE = 0xFFFFFFFE ; Sent when a list box cannot allocate enough memory for a request
Global Const $LBN_SELCHANGE = 0x00000001 ; Sent when the selection in a list box is about to change
Global Const $LBN_DBLCLK = 0x00000002 ; Sent when the user double clicks a string in a list box
Global Const $LBN_SELCANCEL = 0x00000003 ; Sent when the user cancels the selection in a list box
Global Const $LBN_SETFOCUS = 0x00000004 ; Sent when a list box receives the keyboard focus
Global Const $LBN_KILLFOCUS = 0x00000005 ; Sent when a list box loses the keyboard focus
; ===============================================================================================================================

; Control default styles
Global Const $__LISTBOXCONSTANT_WS_BORDER = 0x00800000
Global Const $__LISTBOXCONSTANT_WS_VSCROLL = 0x00200000
Global Const $GUI_SS_DEFAULT_LIST = BitOR($LBS_SORT, $__LISTBOXCONSTANT_WS_BORDER, $__LISTBOXCONSTANT_WS_VSCROLL, $LBS_NOTIFY)
