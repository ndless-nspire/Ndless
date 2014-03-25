#include-once

; #INDEX# =======================================================================================================================
; Title .........: Frame_Constants
; AutoIt Version : 3.2
; Language ......: English
; Description ...: Constants for _WinAPI_DrawFrameControl().
; Author(s) .....: Gary Frost
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; type of frame
Global Const $DFC_BUTTON = 4
Global Const $DFC_CAPTION = 1
Global Const $DFC_MENU = 2
Global Const $DFC_POPUPMENU = 5
Global Const $DFC_SCROLL = 3

; initial state of the frame
Global Const $DFCS_BUTTON3STATE = 0x8
Global Const $DFCS_BUTTONCHECK = 0x0
Global Const $DFCS_BUTTONPUSH = 0x10
Global Const $DFCS_BUTTONRADIO = 0x4
Global Const $DFCS_BUTTONRADIOIMAGE = 0x1
Global Const $DFCS_BUTTONRADIOMASK = 0x2
Global Const $DFCS_CAPTIONCLOSE = 0x0
Global Const $DFCS_CAPTIONHELP = 0x4
Global Const $DFCS_CAPTIONMAX = 0x2
Global Const $DFCS_CAPTIONMIN = 0x1
Global Const $DFCS_CAPTIONRESTORE = 0x3
Global Const $DFCS_MENUARROW = 0x0
Global Const $DFCS_MENUARROWRIGHT = 0x4
Global Const $DFCS_MENUBULLET = 0x2
Global Const $DFCS_MENUCHECK = 0x1
Global Const $DFCS_SCROLLCOMBOBOX = 0x5
Global Const $DFCS_SCROLLDOWN = 0x1
Global Const $DFCS_SCROLLLEFT = 0x2
Global Const $DFCS_SCROLLRIGHT = 0x3
Global Const $DFCS_SCROLLSIZEGRIP = 0x8
Global Const $DFCS_SCROLLSIZEGRIPRIGHT = 0x10
Global Const $DFCS_SCROLLUP = 0x0
Global Const $DFCS_ADJUSTRECT = 0x2000

; Set state constants
Global Const $DFCS_CHECKED = 0x400
Global Const $DFCS_FLAT = 0x4000
Global Const $DFCS_HOT = 0x1000
Global Const $DFCS_INACTIVE = 0x100
Global Const $DFCS_PUSHED = 0x200
Global Const $DFCS_TRANSPARENT = 0x800

; ===============================================================================================================================
