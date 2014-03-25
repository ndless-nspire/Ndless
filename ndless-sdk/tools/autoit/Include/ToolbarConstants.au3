#include-once

; #INDEX# =======================================================================================================================
; Title .........: Toolbar_Constants
; AutoIt Version : 3.2
; Language ......: English
; Description ...: Constants for Toolbar functions.
; Author(s) .....: Valik, Gary Frost, ...
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $TBIF_IMAGE = 0x00000001
Global Const $TBIF_TEXT = 0x00000002
Global Const $TBIF_STATE = 0x00000004
Global Const $TBIF_STYLE = 0x00000008
Global Const $TBIF_LPARAM = 0x00000010
Global Const $TBIF_COMMAND = 0x00000020
Global Const $TBIF_SIZE = 0x00000040
Global Const $TBIF_BYINDEX = 0x80000000

Global Const $TBMF_PAD = 0x00000001
Global Const $TBMF_BARPAD = 0x00000002
Global Const $TBMF_BUTTONSPACING = 0x00000004

Global Const $TBSTATE_CHECKED = 0x00000001 ; The button has the $TBSTYLE_CHECK style and is being clicked
Global Const $TBSTATE_PRESSED = 0x00000002 ; The button is being clicked
Global Const $TBSTATE_ENABLED = 0x00000004 ; The button accepts user input
Global Const $TBSTATE_HIDDEN = 0x00000008 ; The button is not visible and cannot receive user input
Global Const $TBSTATE_INDETERMINATE = 0x00000010 ; The button is grayed
Global Const $TBSTATE_WRAP = 0x00000020 ; The button is followed by a line break
Global Const $TBSTATE_ELLIPSES = 0x00000040 ; The button's text is cut off and an ellipsis is displayed
Global Const $TBSTATE_MARKED = 0x00000080 ; The button is marked
; ===============================================================================================================================

; #MESSAGES# ====================================================================================================================
Global Const $__TOOLBARCONSTANTS_WM_USER = 0X400
Global Const $TB_ENABLEBUTTON = $__TOOLBARCONSTANTS_WM_USER + 1
Global Const $TB_CHECKBUTTON = $__TOOLBARCONSTANTS_WM_USER + 2
Global Const $TB_PRESSBUTTON = $__TOOLBARCONSTANTS_WM_USER + 3
Global Const $TB_HIDEBUTTON = $__TOOLBARCONSTANTS_WM_USER + 4
Global Const $TB_INDETERMINATE = $__TOOLBARCONSTANTS_WM_USER + 5
Global Const $TB_MARKBUTTON = $__TOOLBARCONSTANTS_WM_USER + 6
Global Const $TB_ISBUTTONENABLED = $__TOOLBARCONSTANTS_WM_USER + 9
Global Const $TB_ISBUTTONCHECKED = $__TOOLBARCONSTANTS_WM_USER + 10
Global Const $TB_ISBUTTONPRESSED = $__TOOLBARCONSTANTS_WM_USER + 11
Global Const $TB_ISBUTTONHIDDEN = $__TOOLBARCONSTANTS_WM_USER + 12
Global Const $TB_ISBUTTONINDETERMINATE = $__TOOLBARCONSTANTS_WM_USER + 13
Global Const $TB_ISBUTTONHIGHLIGHTED = $__TOOLBARCONSTANTS_WM_USER + 14
Global Const $TB_SETSTATE = $__TOOLBARCONSTANTS_WM_USER + 17
Global Const $TB_GETSTATE = $__TOOLBARCONSTANTS_WM_USER + 18
Global Const $TB_ADDBITMAP = $__TOOLBARCONSTANTS_WM_USER + 19
Global Const $TB_ADDBUTTONSA = $__TOOLBARCONSTANTS_WM_USER + 20
Global Const $TB_INSERTBUTTONA = $__TOOLBARCONSTANTS_WM_USER + 21
Global Const $TB_DELETEBUTTON = $__TOOLBARCONSTANTS_WM_USER + 22
Global Const $TB_GETBUTTON = $__TOOLBARCONSTANTS_WM_USER + 23
Global Const $TB_BUTTONCOUNT = $__TOOLBARCONSTANTS_WM_USER + 24
Global Const $TB_COMMANDTOINDEX = $__TOOLBARCONSTANTS_WM_USER + 25
Global Const $TB_SAVERESTOREA = $__TOOLBARCONSTANTS_WM_USER + 26
Global Const $TB_SAVERESTOREW = $__TOOLBARCONSTANTS_WM_USER + 76
Global Const $TB_CUSTOMIZE = $__TOOLBARCONSTANTS_WM_USER + 27
Global Const $TB_ADDSTRINGA = $__TOOLBARCONSTANTS_WM_USER + 28
Global Const $TB_ADDSTRINGW = $__TOOLBARCONSTANTS_WM_USER + 77
Global Const $TB_GETITEMRECT = $__TOOLBARCONSTANTS_WM_USER + 29
Global Const $TB_BUTTONSTRUCTSIZE = $__TOOLBARCONSTANTS_WM_USER + 30
Global Const $TB_SETBUTTONSIZE = $__TOOLBARCONSTANTS_WM_USER + 31
Global Const $TB_SETBITMAPSIZE = $__TOOLBARCONSTANTS_WM_USER + 32
Global Const $TB_AUTOSIZE = $__TOOLBARCONSTANTS_WM_USER + 33
Global Const $TB_GETTOOLTIPS = $__TOOLBARCONSTANTS_WM_USER + 35
Global Const $TB_SETTOOLTIPS = $__TOOLBARCONSTANTS_WM_USER + 36
Global Const $TB_SETPARENT = $__TOOLBARCONSTANTS_WM_USER + 37
Global Const $TB_SETROWS = $__TOOLBARCONSTANTS_WM_USER + 39
Global Const $TB_GETROWS = $__TOOLBARCONSTANTS_WM_USER + 40
Global Const $TB_GETBITMAPFLAGS = $__TOOLBARCONSTANTS_WM_USER + 41
Global Const $TB_SETCMDID = $__TOOLBARCONSTANTS_WM_USER + 42
Global Const $TB_CHANGEBITMAP = $__TOOLBARCONSTANTS_WM_USER + 43
Global Const $TB_GETBITMAP = $__TOOLBARCONSTANTS_WM_USER + 44
Global Const $TB_GETBUTTONTEXTA = $__TOOLBARCONSTANTS_WM_USER + 45
Global Const $TB_GETBUTTONTEXTW = $__TOOLBARCONSTANTS_WM_USER + 75
Global Const $TB_REPLACEBITMAP = $__TOOLBARCONSTANTS_WM_USER + 46
Global Const $TB_SETINDENT = $__TOOLBARCONSTANTS_WM_USER + 47
Global Const $TB_SETIMAGELIST = $__TOOLBARCONSTANTS_WM_USER + 48
Global Const $TB_GETIMAGELIST = $__TOOLBARCONSTANTS_WM_USER + 49
Global Const $TB_LOADIMAGES = $__TOOLBARCONSTANTS_WM_USER + 50
Global Const $TB_GETRECT = $__TOOLBARCONSTANTS_WM_USER + 51
Global Const $TB_SETHOTIMAGELIST = $__TOOLBARCONSTANTS_WM_USER + 52
Global Const $TB_GETHOTIMAGELIST = $__TOOLBARCONSTANTS_WM_USER + 53
Global Const $TB_SETDISABLEDIMAGELIST = $__TOOLBARCONSTANTS_WM_USER + 54
Global Const $TB_GETDISABLEDIMAGELIST = $__TOOLBARCONSTANTS_WM_USER + 55
Global Const $TB_SETSTYLE = $__TOOLBARCONSTANTS_WM_USER + 56
Global Const $TB_GETSTYLE = $__TOOLBARCONSTANTS_WM_USER + 57
Global Const $TB_GETBUTTONSIZE = $__TOOLBARCONSTANTS_WM_USER + 58
Global Const $TB_SETBUTTONWIDTH = $__TOOLBARCONSTANTS_WM_USER + 59
Global Const $TB_SETMAXTEXTROWS = $__TOOLBARCONSTANTS_WM_USER + 60
Global Const $TB_GETTEXTROWS = $__TOOLBARCONSTANTS_WM_USER + 61
Global Const $TB_GETOBJECT = $__TOOLBARCONSTANTS_WM_USER + 62
Global Const $TB_GETBUTTONINFOW = $__TOOLBARCONSTANTS_WM_USER + 63
Global Const $TB_SETBUTTONINFOW = $__TOOLBARCONSTANTS_WM_USER + 64
Global Const $TB_GETBUTTONINFOA = $__TOOLBARCONSTANTS_WM_USER + 65
Global Const $TB_SETBUTTONINFOA = $__TOOLBARCONSTANTS_WM_USER + 66
Global Const $TB_INSERTBUTTONW = $__TOOLBARCONSTANTS_WM_USER + 67
Global Const $TB_ADDBUTTONSW = $__TOOLBARCONSTANTS_WM_USER + 68
Global Const $TB_HITTEST = $__TOOLBARCONSTANTS_WM_USER + 69
Global Const $TB_SETDRAWTEXTFLAGS = $__TOOLBARCONSTANTS_WM_USER + 70
Global Const $TB_GETHOTITEM = $__TOOLBARCONSTANTS_WM_USER + 71
Global Const $TB_SETHOTITEM = $__TOOLBARCONSTANTS_WM_USER + 72
Global Const $TB_SETANCHORHIGHLIGHT = $__TOOLBARCONSTANTS_WM_USER + 73
Global Const $TB_GETANCHORHIGHLIGHT = $__TOOLBARCONSTANTS_WM_USER + 74
Global Const $TB_MAPACCELERATOR = $__TOOLBARCONSTANTS_WM_USER + 78
Global Const $TB_GETINSERTMARK = $__TOOLBARCONSTANTS_WM_USER + 79
Global Const $TB_SETINSERTMARK = $__TOOLBARCONSTANTS_WM_USER + 80
Global Const $TB_INSERTMARKHITTEST = $__TOOLBARCONSTANTS_WM_USER + 81
Global Const $TB_MOVEBUTTON = $__TOOLBARCONSTANTS_WM_USER + 82
Global Const $TB_GETMAXSIZE = $__TOOLBARCONSTANTS_WM_USER + 83
Global Const $TB_SETEXTENDEDSTYLE = $__TOOLBARCONSTANTS_WM_USER + 84
Global Const $TB_GETEXTENDEDSTYLE = $__TOOLBARCONSTANTS_WM_USER + 85
Global Const $TB_GETPADDING = $__TOOLBARCONSTANTS_WM_USER + 86
Global Const $TB_SETPADDING = $__TOOLBARCONSTANTS_WM_USER + 87
Global Const $TB_SETINSERTMARKCOLOR = $__TOOLBARCONSTANTS_WM_USER + 88
Global Const $TB_GETINSERTMARKCOLOR = $__TOOLBARCONSTANTS_WM_USER + 89
Global Const $TB_MAPACCELERATORW = $__TOOLBARCONSTANTS_WM_USER + 90
Global Const $TB_GETSTRINGW = $__TOOLBARCONSTANTS_WM_USER + 91
Global Const $TB_GETSTRINGA = $__TOOLBARCONSTANTS_WM_USER + 92
Global Const $TB_GETMETRICS = $__TOOLBARCONSTANTS_WM_USER + 101
Global Const $TB_SETMETRICS = $__TOOLBARCONSTANTS_WM_USER + 102
Global Const $TB_GETCOLORSCHEME = 0x2000 + 3
Global Const $TB_SETCOLORSCHEME = 0x2000 + 2
Global Const $TB_SETUNICODEFORMAT = 0x2000 + 5
Global Const $TB_GETUNICODEFORMAT = 0x2000 + 6
Global Const $TB_SETWINDOWTHEME = 0x2000 + 11
; ===============================================================================================================================

; #NOTIFICATIONS# ===============================================================================================================
Global Const $TBN_FIRST = -700
Global Const $TBN_GETBUTTONINFOA = $TBN_FIRST - 0 ; Retrieves toolbar customization information
Global Const $TBN_BEGINDRAG = $TBN_FIRST - 1 ; The user has begun dragging a button in a toolbar
Global Const $TBN_ENDDRAG = $TBN_FIRST - 2 ; The user has stopped dragging a button in a toolbar
Global Const $TBN_BEGINADJUST = $TBN_FIRST - 3 ; The user has begun customizing a toolbar
Global Const $TBN_ENDADJUST = $TBN_FIRST - 4 ; The user has stopped customizing a toolbar
Global Const $TBN_RESET = $TBN_FIRST - 5 ; The user has reset the content of the Customize Toolbar dialog box
Global Const $TBN_QUERYINSERT = $TBN_FIRST - 6 ; Determines whether a button may be inserted during customization
Global Const $TBN_QUERYDELETE = $TBN_FIRST - 7 ; Determines whether a button may be deleted during customization
Global Const $TBN_TOOLBARCHANGE = $TBN_FIRST - 8 ; The user has customized a toolbar
Global Const $TBN_CUSTHELP = $TBN_FIRST - 9 ; The user has chosen the Help button in the Customize Toolbar dialog box
Global Const $TBN_DROPDOWN = $TBN_FIRST - 10 ; The user clicked a dropdown button
Global Const $TBN_GETOBJECT = $TBN_FIRST - 12 ; Sent to request a drop target object
Global Const $TBN_HOTITEMCHANGE = $TBN_FIRST - 13 ; The hot (highlighted) item has changed
Global Const $TBN_DRAGOUT = $TBN_FIRST - 14 ; The user clicked a button and then moveed the cursor off the button
Global Const $TBN_DELETINGBUTTON = $TBN_FIRST - 15 ; A button is about to be deleted
Global Const $TBN_GETDISPINFOA = $TBN_FIRST - 16 ; Retrieves display information for a toolbar item
Global Const $TBN_GETDISPINFOW = $TBN_FIRST - 17 ; [Unicode] Retrieves display information for a toolbar item
Global Const $TBN_GETINFOTIPA = $TBN_FIRST - 18 ; Retrieves infotip information for a toolbar item
Global Const $TBN_GETINFOTIPW = $TBN_FIRST - 19 ; [Unicode] Retrieves infotip information for a toolbar item
Global Const $TBN_GETBUTTONINFOW = $TBN_FIRST - 20 ; [Unicode] Retrieves toolbar customization information
Global Const $TBN_RESTORE = $TBN_FIRST - 21 ; A toolbar is in the process of being restored
Global Const $TBN_SAVE = $TBN_FIRST - 22 ; A toolbar is in the process of being saved
Global Const $TBN_INITCUSTOMIZE = $TBN_FIRST - 23 ; Customizing has started

; Toolbar Notifications
Global Const $HICF_ACCELERATOR = 0x4 ;The change in the hot item was caused by a shortcut key
Global Const $HICF_ARROWKEYS = 0x2 ;The change in the hot item was caused by an arrow key
Global Const $HICF_DUPACCEL = 0x8 ;Modifies HICF_ACCELERATOR. If this flag is set, more than one item has the same shortcut key character
Global Const $HICF_ENTERING = 0x10 ;Modifies the other reason flags. If this flag is set, there is no previous hot item and idOld does not contain valid information
Global Const $HICF_LEAVING = 0x20 ;Modifies the other reason flags. If this flag is set, there is no new hot item and idNew does not contain valid information
Global Const $HICF_LMOUSE = 0x80 ;The change in the hot item resulted from a left-click mouse event
Global Const $HICF_MOUSE = 0x1 ;The change in the hot item resulted from a mouse event
Global Const $HICF_OTHER = 0x0 ;The change in the hot item resulted from an event that could not be determined. This will most often be due to a change in focus or the TB_SETHOTITEM message
Global Const $HICF_RESELECT = 0x40 ;The change in the hot item resulted from the user entering the shortcut key for an item that was already hot
Global Const $HICF_TOGGLEDROPDOWN = 0x100 ;Version 5.80. Causes the button to switch states
; ===============================================================================================================================

; #STYLES# ======================================================================================================================
Global Const $BTNS_BUTTON = 0x00000000 ; Standard button
Global Const $BTNS_SEP = 0x00000001 ; Creates a separator
Global Const $BTNS_CHECK = 0x00000002 ; Toggles between the pressed and nonpressed
Global Const $BTNS_GROUP = 0x00000004 ; Button that stays pressed until another button in the group is pressed
Global Const $BTNS_CHECKGROUP = 0x00000006 ; Button that stays pressed until another button in the group is pressed
Global Const $BTNS_DROPDOWN = 0x00000008 ; Creates a drop-down style button that can display a list
Global Const $BTNS_AUTOSIZE = 0x00000010 ; The toolbar control should not assign the standard width to the button
Global Const $BTNS_NOPREFIX = 0x00000020 ; The button text will not have an accelerator prefix
Global Const $BTNS_SHOWTEXT = 0x00000040 ; Specifies that button text should be displayed
Global Const $BTNS_WHOLEDROPDOWN = 0x00000080 ; Specifies that the button will have a drop-down arrow
Global Const $TBSTYLE_TOOLTIPS = 0x00000100 ; Creates a ToolTip control
Global Const $TBSTYLE_WRAPABLE = 0x00000200 ; Creates a toolbar that can have multiple lines of buttons
Global Const $TBSTYLE_ALTDRAG = 0x00000400 ; Allows users to change a toolbar button's position by dragging it
Global Const $TBSTYLE_FLAT = 0x00000800 ; Creates a flat toolbar
Global Const $TBSTYLE_LIST = 0x00001000 ; Creates a flat toolbar with button text to the right of the bitmap
Global Const $TBSTYLE_CUSTOMERASE = 0x00002000 ; Sends $NM_CUSTOMDRAW messages when processing $WM_ERASEBKGND messages
Global Const $TBSTYLE_REGISTERDROP = 0x00004000 ; Sends $TBN_GETOBJECT messages to request drop target objects
Global Const $TBSTYLE_TRANSPARENT = 0x00008000 ; Creates a transparent toolbar
; ===============================================================================================================================

; #EXTSTYLES# ===================================================================================================================
Global Const $TBSTYLE_EX_DRAWDDARROWS = 0x00000001 ; Allows buttons to have a separate dropdown arrow
Global Const $TBSTYLE_EX_MIXEDBUTTONS = 0x00000008 ; Allows mixing buttons with text and images
Global Const $TBSTYLE_EX_HIDECLIPPEDBUTTONS = 0x00000010 ; Hides partially clipped buttons
Global Const $TBSTYLE_EX_DOUBLEBUFFER = 0x00000080 ; Requires the toolbar to be double buffered
; ===============================================================================================================================
