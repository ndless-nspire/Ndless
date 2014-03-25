#include-once

; #INDEX# =======================================================================================================================
; Title .........: Header_Constants
; AutoIt Version : 3.2
; Language ......: English
; Description ...: Constants for Header functions.
; Author(s) .....: Valik, Gary Frost
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $HDF_LEFT = 0x00000000
Global Const $HDF_RIGHT = 0x00000001
Global Const $HDF_CENTER = 0x00000002
Global Const $HDF_JUSTIFYMASK = 0x00000003

Global Const $HDF_BITMAP_ON_RIGHT = 0x00001000
Global Const $HDF_BITMAP = 0x00002000
Global Const $HDF_STRING = 0x00004000
Global Const $HDF_OWNERDRAW = 0x00008000
Global Const $HDF_DISPLAYMASK = 0x0000F000

Global Const $HDF_RTLREADING = 0x00000004
Global Const $HDF_SORTDOWN = 0x00000200
Global Const $HDF_IMAGE = 0x00000800
Global Const $HDF_SORTUP = 0x00000400
Global Const $HDF_FLAGMASK = 0x00000E04

Global Const $HDI_WIDTH = 0x00000001
Global Const $HDI_TEXT = 0x00000002
Global Const $HDI_FORMAT = 0x00000004
Global Const $HDI_PARAM = 0x00000008
Global Const $HDI_BITMAP = 0x00000010
Global Const $HDI_IMAGE = 0x00000020
Global Const $HDI_DI_SETITEM = 0x00000040
Global Const $HDI_ORDER = 0x00000080
Global Const $HDI_FILTER = 0x00000100

Global Const $HHT_NOWHERE = 0x00000001
Global Const $HHT_ONHEADER = 0x00000002
Global Const $HHT_ONDIVIDER = 0x00000004
Global Const $HHT_ONDIVOPEN = 0x00000008
Global Const $HHT_ONFILTER = 0x00000010
Global Const $HHT_ONFILTERBUTTON = 0x00000020
Global Const $HHT_ABOVE = 0x00000100
Global Const $HHT_BELOW = 0x00000200
Global Const $HHT_TORIGHT = 0x00000400
Global Const $HHT_TOLEFT = 0x00000800
; ===============================================================================================================================

; #MESSAGES# ====================================================================================================================
Global Const $HDM_FIRST = 0x1200
Global Const $HDM_CLEARFILTER = $HDM_FIRST + 24
Global Const $HDM_CREATEDRAGIMAGE = $HDM_FIRST + 16
Global Const $HDM_DELETEITEM = $HDM_FIRST + 2
Global Const $HDM_EDITFILTER = $HDM_FIRST + 23
Global Const $HDM_GETBITMAPMARGIN = $HDM_FIRST + 21
Global Const $HDM_GETFOCUSEDITEM = $HDM_FIRST + 27
Global Const $HDM_GETIMAGELIST = $HDM_FIRST + 9
Global Const $HDM_GETITEMA = $HDM_FIRST + 3
Global Const $HDM_GETITEMW = $HDM_FIRST + 11
Global Const $HDM_GETITEMCOUNT = $HDM_FIRST + 0
Global Const $HDM_GETITEMDROPDOWNRECT = $HDM_FIRST + 25
Global Const $HDM_GETITEMRECT = $HDM_FIRST + 7
Global Const $HDM_GETORDERARRAY = $HDM_FIRST + 17
Global Const $HDM_GETOVERFLOWRECT = $HDM_FIRST + 26
Global Const $HDM_GETUNICODEFORMAT = 0x2000 + 6
Global Const $HDM_HITTEST = $HDM_FIRST + 6
Global Const $HDM_INSERTITEMA = $HDM_FIRST + 1
Global Const $HDM_INSERTITEMW = $HDM_FIRST + 10
Global Const $HDM_LAYOUT = $HDM_FIRST + 5
Global Const $HDM_ORDERTOINDEX = $HDM_FIRST + 15
Global Const $HDM_SETBITMAPMARGIN = $HDM_FIRST + 20
Global Const $HDM_SETFILTERCHANGETIMEOUT = $HDM_FIRST + 22
Global Const $HDM_SETFOCUSEDITEM = $HDM_FIRST + 28
Global Const $HDM_SETHOTDIVIDER = $HDM_FIRST + 19
Global Const $HDM_SETIMAGELIST = $HDM_FIRST + 8
Global Const $HDM_SETITEMA = $HDM_FIRST + 4
Global Const $HDM_SETITEMW = $HDM_FIRST + 12
Global Const $HDM_SETORDERARRAY = $HDM_FIRST + 18
Global Const $HDM_SETUNICODEFORMAT = 0x2000 + 5
; ===============================================================================================================================

; #NOTIFICATIONS# ===============================================================================================================
Global Const $HDN_FIRST = -300
Global Const $HDN_BEGINDRAG = $HDN_FIRST - 10 ; Sent when a drag operation has begun
Global Const $HDN_BEGINTRACK = $HDN_FIRST - 6 ; Sent when the user has begun dragging a divider
Global Const $HDN_DIVIDERDBLCLICK = $HDN_FIRST - 5 ; Sent when the user double clicks the divider
Global Const $HDN_ENDDRAG = $HDN_FIRST - 11 ; Sent when a drag operation has ended
Global Const $HDN_ENDTRACK = $HDN_FIRST - 7 ; Sent when the user has finished dragging a divider
Global Const $HDN_FILTERBTNCLICK = $HDN_FIRST - 13 ; Sent when filter button is clicked
Global Const $HDN_FILTERCHANGE = $HDN_FIRST - 12 ; Sent when the attributes of a header control filter are being changed
Global Const $HDN_GETDISPINFO = $HDN_FIRST - 9 ; Sent when the control needs information about a callback
Global Const $HDN_ITEMCHANGED = $HDN_FIRST - 1 ; Sent when a header item has changed
Global Const $HDN_ITEMCHANGING = $HDN_FIRST - 0 ; Sent when a header item is about to change
Global Const $HDN_ITEMCLICK = $HDN_FIRST - 2 ; Sent when the user clicks the control
Global Const $HDN_ITEMDBLCLICK = $HDN_FIRST - 3 ; Sent when the user double clicks the control
Global Const $HDN_TRACK = $HDN_FIRST - 8 ; Sent when the user is dragging a divider
Global Const $HDN_BEGINTRACKW = $HDN_FIRST - 26 ; [Unicode] Sent when the user has begun dragging a divider
Global Const $HDN_DIVIDERDBLCLICKW = $HDN_FIRST - 25 ; [Unicode] Sent when the user double clicks the divider
Global Const $HDN_ENDTRACKW = $HDN_FIRST - 27 ; [Unicode] Sent when the user has finished dragging a divider
Global Const $HDN_GETDISPINFOW = $HDN_FIRST - 29 ; [Unicode] Sent when the control needs information about a callback
Global Const $HDN_ITEMCHANGEDW = $HDN_FIRST - 21 ; [Unicode] Sent when a header item has changed
Global Const $HDN_ITEMCHANGINGW = $HDN_FIRST - 20 ; [Unicode] Sent when a header item is about to change
Global Const $HDN_ITEMCLICKW = $HDN_FIRST - 22 ; [Unicode] Sent when the user clicks the control
Global Const $HDN_ITEMDBLCLICKW = $HDN_FIRST - 23 ; [Unicode] Sent when the user double clicks the control
Global Const $HDN_TRACKW = $HDN_FIRST - 28 ; [Unicode] Sent when the user is dragging a divider
; ===============================================================================================================================

; #STYLES# ======================================================================================================================
Global Const $HDS_BUTTONS = 0x00000002 ; Each item in the control looks and behaves like a push button
Global Const $HDS_CHECKBOXES = 0x00000400 ; Allows the placing of checkboxes on header items on Vista
Global Const $HDS_DRAGDROP = 0x00000040 ; Allows drag-and-drop reordering of header items
Global Const $HDS_FILTERBAR = 0x00000100 ; Include a filter bar as part of the standard header control
Global Const $HDS_FLAT = 0x00000200 ; Control is drawn flat when XP is running in classic mode
Global Const $HDS_FULLDRAG = 0x00000080 ; Column contents are displayed while the user resizes a column
Global Const $HDS_HIDDEN = 0x00000008 ; Indicates a header control that is intended to be hidden
Global Const $HDS_HORZ = 0x00000000 ; Creates a header control with a horizontal orientation
Global Const $HDS_HOTTRACK = 0x00000004 ; Enables hot tracking
Global Const $HDS_NOSIZING = 0x0800 ; The user cannot drag the divider on the header control on Vista
Global Const $HDS_OVERFLOW = 0x1000 ; A button is displayed when not all items can be displayed within the header control's rectangle on Vista
Global Const $HDS_DEFAULT = 0x00000046 ; Default header style $HDS_DRAGDROP + $HDS_HOTTRACK + $HDS_BUTTONS
; ===============================================================================================================================
