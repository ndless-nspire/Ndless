#include-once

; #INDEX# =======================================================================================================================
; Title .........: Tab_Constants
; AutoIt Version : 3.2
; Language ......: English
; Description ...: <a href="../appendix/GUIStyles.htm#Tab">GUI control Tab styles</a> and much more constants.
; Author(s) .....: Valik, Gary Frost, ...
; ===============================================================================================================================

; #STYLES# ======================================================================================================================
Global Const $TCS_BOTTOM = 0x00000002 ; Tabs appear at the bottom of the control
Global Const $TCS_BUTTONS = 0x00000100 ; Tabs appear as buttons, and no border is drawn around the display area
Global Const $TCS_FIXEDWIDTH = 0x00000400 ; All tabs are the same width
Global Const $TCS_FLATBUTTONS = 0x00000008 ; Selected tabs appear as being indented into the background
Global Const $TCS_FOCUSNEVER = 0x00008000 ; The tab control does not receive the input focus when clicked
Global Const $TCS_FOCUSONBUTTONDOWN = 0x00001000 ; The tab control receives the input focus when clicked
Global Const $TCS_FORCEICONLEFT = 0x00000010 ; Icons are aligned with the left edge of each fixed-width tab
Global Const $TCS_FORCELABELLEFT = 0x00000020 ; Labels are aligned with the left edge of each fixed-width tab
Global Const $TCS_HOTTRACK = 0x00000040 ; Items under the pointer are automatically highlighted
Global Const $TCS_MULTILINE = 0x00000200 ; Multiple rows of tabs are displayed if necessary
Global Const $TCS_MULTISELECT = 0x00000004 ; Multiple tabs can be selected with the CTRL key when clicking
Global Const $TCS_OWNERDRAWFIXED = 0x00002000 ; The parent window is responsible for drawing tabs
Global Const $TCS_RAGGEDRIGHT = 0x00000800 ; Rows of tabs will not be stretched to fill the control width
Global Const $TCS_RIGHT = 0x00000002 ; Tabs appear vertically on the right side of controls
Global Const $TCS_RIGHTJUSTIFY = 0x00000000 ; The width of each tab is increased to fill the control width
Global Const $TCS_SCROLLOPPOSITE = 0x00000001 ; Unneeded tabs scroll to the opposite side of the control
Global Const $TCS_SINGLELINE = 0x00000000 ; Only one row of tabs is displayed
Global Const $TCS_TABS = 0x00000000 ; Tabs appear as tabs, and a border is drawn around the display area
Global Const $TCS_TOOLTIPS = 0x00004000 ; The tab control has a ToolTip control associated with
Global Const $TCS_VERTICAL = 0x00000080 ; Tabs appear at the left side of the control
; ===============================================================================================================================

; #EXTSTYLES# ===================================================================================================================
Global Const $TCS_EX_FLATSEPARATORS = 0x00000001 ; The tab control will draw separators between the tab items
Global Const $TCS_EX_REGISTERDROP = 0x00000002 ; The tab control generates TCN_GETOBJECT notification messages
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $TCHT_NOWHERE = 0x00000001
Global Const $TCHT_ONITEMICON = 0x00000002
Global Const $TCHT_ONITEMLABEL = 0x00000004
Global Const $TCHT_ONITEM = 0x00000006

Global Const $TCIF_TEXT = 0x00000001
Global Const $TCIF_IMAGE = 0x00000002
Global Const $TCIF_RTLREADING = 0x00000004
Global Const $TCIF_PARAM = 0x00000008
Global Const $TCIF_STATE = 0x00000010
Global Const $TCIF_ALLDATA = 0x0000001B

; item states
Global Const $TCIS_BUTTONPRESSED = 0x00000001
Global Const $TCIS_HIGHLIGHTED = 0x00000002

; Error checking
Global Const $TC_ERR = -1

; Control default styles
Global Const $GUI_SS_DEFAULT_TAB = 0
; ===============================================================================================================================

; #MESSAGES# ====================================================================================================================
; Messages to send to Tab control
Global Const $TCM_FIRST = 0x1300
Global Const $TCCM_FIRST = 0X2000
Global Const $TCM_ADJUSTRECT = ($TCM_FIRST + 40)
Global Const $TCM_DELETEALLITEMS = ($TCM_FIRST + 9)
Global Const $TCM_DELETEITEM = ($TCM_FIRST + 8)
Global Const $TCM_DESELECTALL = ($TCM_FIRST + 50)
Global Const $TCM_GETCURFOCUS = ($TCM_FIRST + 47)
Global Const $TCM_GETCURSEL = ($TCM_FIRST + 11)
Global Const $TCM_GETEXTENDEDSTYLE = ($TCM_FIRST + 53)
Global Const $TCM_GETIMAGELIST = ($TCM_FIRST + 2)
Global Const $TCM_GETITEMA = ($TCM_FIRST + 5)
Global Const $TCM_GETITEMW = ($TCM_FIRST + 60)
Global Const $TCM_GETITEMCOUNT = ($TCM_FIRST + 4)
Global Const $TCM_GETITEMRECT = ($TCM_FIRST + 10)
Global Const $TCM_GETROWCOUNT = ($TCM_FIRST + 44)
Global Const $TCM_GETTOOLTIPS = ($TCM_FIRST + 45)
Global Const $TCCM_GETUNICODEFORMAT = ($TCCM_FIRST + 6)
Global Const $TCM_GETUNICODEFORMAT = $TCCM_GETUNICODEFORMAT
Global Const $TCM_HIGHLIGHTITEM = ($TCM_FIRST + 51)
Global Const $TCM_HITTEST = ($TCM_FIRST + 13)
Global Const $TCM_INSERTITEMA = ($TCM_FIRST + 7)
Global Const $TCM_INSERTITEMW = ($TCM_FIRST + 62)
Global Const $TCM_REMOVEIMAGE = ($TCM_FIRST + 42)
Global Const $TCM_SETITEMA = ($TCM_FIRST + 6)
Global Const $TCM_SETITEMW = ($TCM_FIRST + 61)
Global Const $TCM_SETITEMEXTRA = ($TCM_FIRST + 14)
Global Const $TCM_SETITEMSIZE = $TCM_FIRST + 41
Global Const $TCM_SETCURFOCUS = ($TCM_FIRST + 48)
Global Const $TCM_SETCURSEL = ($TCM_FIRST + 12)
Global Const $TCM_SETEXTENDEDSTYLE = ($TCM_FIRST + 52)
Global Const $TCM_SETIMAGELIST = $TCM_FIRST + 3
Global Const $TCM_SETMINTABWIDTH = ($TCM_FIRST + 49)
Global Const $TCM_SETPADDING = ($TCM_FIRST + 43)
Global Const $TCM_SETTOOLTIPS = ($TCM_FIRST + 46)
Global Const $TCCM_SETUNICODEFORMAT = ($TCCM_FIRST + 5)
Global Const $TCM_SETUNICODEFORMAT = $TCCM_SETUNICODEFORMAT
; ===============================================================================================================================

; #NOTIFICATIONS# ===============================================================================================================
Global Const $TCN_FIRST = -550
Global Const $TCN_FOCUSCHANGE = ($TCN_FIRST - 4)
Global Const $TCN_GETOBJECT = ($TCN_FIRST - 3)
Global Const $TCN_KEYDOWN = ($TCN_FIRST - 0)
Global Const $TCN_SELCHANGE = ($TCN_FIRST - 1)
Global Const $TCN_SELCHANGING = ($TCN_FIRST - 2)
; ===============================================================================================================================

