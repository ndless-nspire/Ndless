#include-once

; #INDEX# =======================================================================================================================
; Title .........: ComboBox_Constants
; AutoIt Version : 3.2
; Language ......: English
; Description ...: Constants for <a href="../appendix/GUIStyles.htm#Combo">GUI control Combo styles</a> and more.
; Author(s) .....: Valik, Gary Frost
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; Error checking
Global Const $CB_ERR = -1
Global Const $CB_ERRATTRIBUTE = -3
Global Const $CB_ERRREQUIRED = -4
Global Const $CB_ERRSPACE = -2
Global Const $CB_OKAY = 0

; States
Global Const $STATE_SYSTEM_INVISIBLE = 0x8000
Global Const $STATE_SYSTEM_PRESSED = 0x8

; ===============================================================================================================================

; ComboBox
; #STYLES# ======================================================================================================================
Global Const $CBS_AUTOHSCROLL = 0x40 ; Automatically scrolls the text in an edit control to the right when the user types a character at the end of the line.
Global Const $CBS_DISABLENOSCROLL = 0x800 ; Shows a disabled vertical scroll bar
Global Const $CBS_DROPDOWN = 0x2 ; Similar to $CBS_SIMPLE, except that the list box is not displayed unless the user selects an icon next to the edit control
Global Const $CBS_DROPDOWNLIST = 0x3 ; Similar to $CBS_DROPDOWN, except that the edit control is replaced by a static text item that displays the current selection in the list box
Global Const $CBS_HASSTRINGS = 0x200 ; Specifies that an owner-drawn combo box contains items consisting of strings
Global Const $CBS_LOWERCASE = 0x4000 ; Converts to lowercase all text in both the selection field and the list
Global Const $CBS_NOINTEGRALHEIGHT = 0x400 ; Specifies that the size of the combo box is exactly the size specified by the application when it created the combo box
Global Const $CBS_OEMCONVERT = 0x80 ; Converts text entered in the combo box edit control from the Windows character set to the OEM character set and then back to the Windows character set
Global Const $CBS_OWNERDRAWFIXED = 0x10 ; Specifies that the owner of the list box is responsible for drawing its contents and that the items in the list box are all the same height
Global Const $CBS_OWNERDRAWVARIABLE = 0x20 ; Specifies that the owner of the list box is responsible for drawing its contents and that the items in the list box are variable in height
Global Const $CBS_SIMPLE = 0x1 ; Displays the list box at all times
Global Const $CBS_SORT = 0x100 ; Automatically sorts strings added to the list box
Global Const $CBS_UPPERCASE = 0x2000 ; Converts to uppercase all text in both the selection field and the list
; ===============================================================================================================================

; #MESSAGES# ====================================================================================================================
Global Const $CBM_FIRST = 0x1700
Global Const $CB_ADDSTRING = 0x143
Global Const $CB_DELETESTRING = 0x144
Global Const $CB_DIR = 0x145
Global Const $CB_FINDSTRING = 0x14C
Global Const $CB_FINDSTRINGEXACT = 0x158
Global Const $CB_GETCOMBOBOXINFO = 0x164
Global Const $CB_GETCOUNT = 0x146
Global Const $CB_GETCUEBANNER = ($CBM_FIRST + 4)
Global Const $CB_GETCURSEL = 0x147
Global Const $CB_GETDROPPEDCONTROLRECT = 0x152
Global Const $CB_GETDROPPEDSTATE = 0x157
Global Const $CB_GETDROPPEDWIDTH = 0X15f
Global Const $CB_GETEDITSEL = 0x140
Global Const $CB_GETEXTENDEDUI = 0x156
Global Const $CB_GETHORIZONTALEXTENT = 0x15d
Global Const $CB_GETITEMDATA = 0x150
Global Const $CB_GETITEMHEIGHT = 0x154
Global Const $CB_GETLBTEXT = 0x148
Global Const $CB_GETLBTEXTLEN = 0x149
Global Const $CB_GETLOCALE = 0x15A
Global Const $CB_GETMINVISIBLE = 0x1702
Global Const $CB_GETTOPINDEX = 0x15b
Global Const $CB_INITSTORAGE = 0x161
Global Const $CB_LIMITTEXT = 0x141
Global Const $CB_RESETCONTENT = 0x14B
Global Const $CB_INSERTSTRING = 0x14A
Global Const $CB_SELECTSTRING = 0x14D
Global Const $CB_SETCUEBANNER = ($CBM_FIRST + 3)
Global Const $CB_SETCURSEL = 0x14E
Global Const $CB_SETDROPPEDWIDTH = 0x160
Global Const $CB_SETEDITSEL = 0x142
Global Const $CB_SETEXTENDEDUI = 0x155
Global Const $CB_SETHORIZONTALEXTENT = 0x15e
Global Const $CB_SETITEMDATA = 0x151
Global Const $CB_SETITEMHEIGHT = 0x153
Global Const $CB_SETLOCALE = 0x159
Global Const $CB_SETMINVISIBLE = 0x1701
Global Const $CB_SETTOPINDEX = 0x15c
Global Const $CB_SHOWDROPDOWN = 0x14F
; ===============================================================================================================================

; #NOTIFICATIONS# ===============================================================================================================
Global Const $CBN_CLOSEUP = 8
Global Const $CBN_DBLCLK = 2
Global Const $CBN_DROPDOWN = 7
Global Const $CBN_EDITCHANGE = 5
Global Const $CBN_EDITUPDATE = 6
Global Const $CBN_ERRSPACE = (-1)
Global Const $CBN_KILLFOCUS = 4
Global Const $CBN_SELCHANGE = 1
Global Const $CBN_SELENDCANCEL = 10
Global Const $CBN_SELENDOK = 9
Global Const $CBN_SETFOCUS = 3
; ===============================================================================================================================

; ComboBoxEx
; #STYLES# ======================================================================================================================
; ComboBox styles supported: $CBS_DROPDOWN, $CBS_DROPDOWNLIST, $CBS_SIMPLE
Global Const $CBES_EX_CASESENSITIVE = 0x10 ; Searches in the list will be case sensitive
Global Const $CBES_EX_NOEDITIMAGE = 0x1 ; The edit box and the dropdown list will not display item images
Global Const $CBES_EX_NOEDITIMAGEINDENT = 0x2 ; The edit box and the dropdown list will not display item images
Global Const $CBES_EX_NOSIZELIMIT = 0x8 ; Allows the ComboBoxEx control to be vertically sized smaller than its contained combo box control
; ===============================================================================================================================

; #MESSAGES#=====================================================================================================================
Global Const $__COMBOBOXCONSTANT_WM_USER = 0X400
Global Const $CBEM_DELETEITEM = $CB_DELETESTRING
Global Const $CBEM_GETCOMBOCONTROL = ($__COMBOBOXCONSTANT_WM_USER + 6)
Global Const $CBEM_GETEDITCONTROL = ($__COMBOBOXCONSTANT_WM_USER + 7)
Global Const $CBEM_GETEXSTYLE = ($__COMBOBOXCONSTANT_WM_USER + 9)
Global Const $CBEM_GETEXTENDEDSTYLE = ($__COMBOBOXCONSTANT_WM_USER + 9)
Global Const $CBEM_GETIMAGELIST = ($__COMBOBOXCONSTANT_WM_USER + 3)
Global Const $CBEM_GETITEMA = ($__COMBOBOXCONSTANT_WM_USER + 4)
Global Const $CBEM_GETITEMW = ($__COMBOBOXCONSTANT_WM_USER + 13)
Global Const $CBEM_GETUNICODEFORMAT = 0x2000 + 6
Global Const $CBEM_HASEDITCHANGED = ($__COMBOBOXCONSTANT_WM_USER + 10)
Global Const $CBEM_INSERTITEMA = ($__COMBOBOXCONSTANT_WM_USER + 1)
Global Const $CBEM_INSERTITEMW = ($__COMBOBOXCONSTANT_WM_USER + 11)
Global Const $CBEM_SETEXSTYLE = ($__COMBOBOXCONSTANT_WM_USER + 8)
Global Const $CBEM_SETEXTENDEDSTYLE = ($__COMBOBOXCONSTANT_WM_USER + 14)
Global Const $CBEM_SETIMAGELIST = ($__COMBOBOXCONSTANT_WM_USER + 2)
Global Const $CBEM_SETITEMA = ($__COMBOBOXCONSTANT_WM_USER + 5)
Global Const $CBEM_SETITEMW = ($__COMBOBOXCONSTANT_WM_USER + 12)
Global Const $CBEM_SETUNICODEFORMAT = 0x2000 + 5
Global Const $CBEM_SETWINDOWTHEME = 0x2000 + 11
; ===============================================================================================================================

; #NOTIFICATIONS# ===============================================================================================================
Global Const $CBEN_FIRST = (-800)
Global Const $CBEN_LAST = (-830)
Global Const $CBEN_BEGINEDIT = ($CBEN_FIRST - 4)
Global Const $CBEN_DELETEITEM = ($CBEN_FIRST - 2)
Global Const $CBEN_DRAGBEGINA = ($CBEN_FIRST - 8)
Global Const $CBEN_DRAGBEGINW = ($CBEN_FIRST - 9)
Global Const $CBEN_ENDEDITA = ($CBEN_FIRST - 5)
Global Const $CBEN_ENDEDITW = ($CBEN_FIRST - 6)
Global Const $CBEN_GETDISPINFO = ($CBEN_FIRST - 0)
Global Const $CBEN_GETDISPINFOA = ($CBEN_FIRST - 0)
Global Const $CBEN_GETDISPINFOW = ($CBEN_FIRST - 7)
Global Const $CBEN_INSERTITEM = ($CBEN_FIRST - 1)

; attributes for Extended ComboBox
Global Const $CBEIF_DI_SETITEM = 0x10000000
Global Const $CBEIF_IMAGE = 0x2
Global Const $CBEIF_INDENT = 0x10
Global Const $CBEIF_LPARAM = 0x20
Global Const $CBEIF_OVERLAY = 0x8
Global Const $CBEIF_SELECTEDIMAGE = 0x4
Global Const $CBEIF_TEXT = 0x1

; Control default styles
Global Const $__COMBOBOXCONSTANT_WS_VSCROLL = 0x00200000
Global Const $GUI_SS_DEFAULT_COMBO = BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $__COMBOBOXCONSTANT_WS_VSCROLL)
; ===============================================================================================================================
