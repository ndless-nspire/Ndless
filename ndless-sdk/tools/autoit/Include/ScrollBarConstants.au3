#include-once

; #INDEX# =======================================================================================================================
; Title .........: ScrollBar_Constants
; AutoIt Version : 3.2
; Language ......: English
; Description ...: Constants for ScrollBar functions.
; Author(s) .....: Valik, Gary Frost, ...
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $SIF_POS = 0x04
Global Const $SIF_PAGE = 0x02
Global Const $SIF_RANGE = 0x01
Global Const $SIF_TRACKPOS = 0x10
Global Const $SIF_ALL = BitOR($SIF_RANGE, $SIF_PAGE, $SIF_POS, $SIF_TRACKPOS)

Global Const $SB_HORZ = 0
Global Const $SB_VERT = 1
Global Const $SB_CTL = 2
Global Const $SB_BOTH = 3

Global Const $SB_LINELEFT = 0
Global Const $SB_LINERIGHT = 1
Global Const $SB_PAGELEFT = 2
Global Const $SB_PAGERIGHT = 3

Global Const $SB_THUMBPOSITION = 0x4
Global Const $SB_THUMBTRACK = 0x5
Global Const $SB_LINEDOWN = 1
Global Const $SB_LINEUP = 0
Global Const $SB_PAGEDOWN = 3
Global Const $SB_PAGEUP = 2
Global Const $SB_SCROLLCARET = 4
Global Const $SB_TOP = 6
Global Const $SB_BOTTOM = 7

Global Const $ESB_DISABLE_BOTH = 0x3
Global Const $ESB_DISABLE_DOWN = 0x2
Global Const $ESB_DISABLE_LEFT = 0x1
Global Const $ESB_DISABLE_LTUP = $ESB_DISABLE_LEFT
Global Const $ESB_DISABLE_RIGHT = 0x2
Global Const $ESB_DISABLE_RTDN = $ESB_DISABLE_RIGHT
Global Const $ESB_DISABLE_UP = 0x1
Global Const $ESB_ENABLE_BOTH = 0x0

; Reserved IDs for System Objects
Global Const $OBJID_HSCROLL = 0xFFFFFFFA
Global Const $OBJID_VSCROLL = 0xFFFFFFFB
Global Const $OBJID_CLIENT = 0xFFFFFFFC
; ===============================================================================================================================
