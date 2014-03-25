#include-once

; #INDEX# =======================================================================================================================
; Title .........: Slider_Constants
; AutoIt Version : 3.2
; Language ......: English
; Description ...: <a href="../appendix/GUIStyles.htm#Slider">GUI control Slider styles</a> and much more constants.
; Author(s) .....: Valik, Gary Frost, ...
; ===============================================================================================================================

; #STYLES# ======================================================================================================================
Global Const $TBS_AUTOTICKS = 0x0001
Global Const $TBS_BOTH = 0x0008
Global Const $TBS_BOTTOM = 0x0000
Global Const $TBS_DOWNISLEFT = 0x0400
Global Const $TBS_ENABLESELRANGE = 0x20
Global Const $TBS_FIXEDLENGTH = 0x40
Global Const $TBS_HORZ = 0x0000
Global Const $TBS_LEFT = 0x0004
Global Const $TBS_NOTHUMB = 0x0080
Global Const $TBS_NOTICKS = 0x0010
Global Const $TBS_REVERSED = 0x200
Global Const $TBS_RIGHT = 0x0000
Global Const $TBS_TOP = 0x0004
Global Const $TBS_TOOLTIPS = 0x100
Global Const $TBS_VERT = 0x0002

; Control default styles
Global Const $GUI_SS_DEFAULT_SLIDER = $TBS_AUTOTICKS
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; Custom Draw Values (Custom Draw values, for example, are specified in the dwItemSpec member of the NMCUSTOMDRAW structure)
Global Const $TBCD_CHANNEL = 0x3 ;Identifies the channel that the trackbar control's thumb marker slides along.
Global Const $TBCD_THUMB = 0x2 ;Identifies the trackbar control's thumb marker. This is the part of the control that the user moves
Global Const $TBCD_TICS = 0x1 ;Identifies the tick marks that are displayed along the trackbar control's edge

; Messages
Global Const $__SLIDERCONSTANT_WM_USER = 0x400
Global Const $TBM_CLEARSEL = $__SLIDERCONSTANT_WM_USER + 19
Global Const $TBM_CLEARTICS = $__SLIDERCONSTANT_WM_USER + 9
Global Const $TBM_GETBUDDY = $__SLIDERCONSTANT_WM_USER + 33
Global Const $TBM_GETCHANNELRECT = $__SLIDERCONSTANT_WM_USER + 26
Global Const $TBM_GETLINESIZE = $__SLIDERCONSTANT_WM_USER + 24
Global Const $TBM_GETNUMTICS = $__SLIDERCONSTANT_WM_USER + 16
Global Const $TBM_GETPAGESIZE = $__SLIDERCONSTANT_WM_USER + 22
Global Const $TBM_GETPOS = $__SLIDERCONSTANT_WM_USER
Global Const $TBM_GETPTICS = $__SLIDERCONSTANT_WM_USER + 14
Global Const $TBM_GETSELEND = $__SLIDERCONSTANT_WM_USER + 18
Global Const $TBM_GETSELSTART = $__SLIDERCONSTANT_WM_USER + 17
Global Const $TBM_GETRANGEMAX = $__SLIDERCONSTANT_WM_USER + 2
Global Const $TBM_GETRANGEMIN = $__SLIDERCONSTANT_WM_USER + 1
Global Const $TBM_GETTHUMBLENGTH = $__SLIDERCONSTANT_WM_USER + 28
Global Const $TBM_GETTHUMBRECT = $__SLIDERCONSTANT_WM_USER + 25
Global Const $TBM_GETTIC = $__SLIDERCONSTANT_WM_USER + 3
Global Const $TBM_GETTICPOS = $__SLIDERCONSTANT_WM_USER + 15
Global Const $TBM_GETTOOLTIPS = $__SLIDERCONSTANT_WM_USER + 30
Global Const $TBM_GETUNICODEFORMAT = 0x2000 + 6
Global Const $TBM_SETBUDDY = $__SLIDERCONSTANT_WM_USER + 32
Global Const $TBM_SETLINESIZE = $__SLIDERCONSTANT_WM_USER + 23
Global Const $TBM_SETPAGESIZE = $__SLIDERCONSTANT_WM_USER + 21
Global Const $TBM_SETPOS = $__SLIDERCONSTANT_WM_USER + 5
Global Const $TBM_SETRANGE = $__SLIDERCONSTANT_WM_USER + 6
Global Const $TBM_SETRANGEMAX = $__SLIDERCONSTANT_WM_USER + 8
Global Const $TBM_SETRANGEMIN = $__SLIDERCONSTANT_WM_USER + 7
Global Const $TBM_SETSEL = $__SLIDERCONSTANT_WM_USER + 10
Global Const $TBM_SETSELEND = $__SLIDERCONSTANT_WM_USER + 12
Global Const $TBM_SETSELSTART = $__SLIDERCONSTANT_WM_USER + 11
Global Const $TBM_SETTHUMBLENGTH = $__SLIDERCONSTANT_WM_USER + 27
Global Const $TBM_SETTIC = $__SLIDERCONSTANT_WM_USER + 4
Global Const $TBM_SETTICFREQ = $__SLIDERCONSTANT_WM_USER + 20
Global Const $TBM_SETTIPSIDE = $__SLIDERCONSTANT_WM_USER + 31
Global Const $TBM_SETTOOLTIPS = $__SLIDERCONSTANT_WM_USER + 29
Global Const $TBM_SETUNICODEFORMAT = 0x2000 + 5

; Tip Side Params
Global Const $TBTS_BOTTOM = 2
Global Const $TBTS_LEFT = 1
Global Const $TBTS_RIGHT = 3
Global Const $TBTS_TOP = 0
; ===============================================================================================================================
