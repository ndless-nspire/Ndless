#include-once

; #INDEX# =======================================================================================================================
; Title .........: Border_Constants
; AutoIt Version : 3.2
; Language ......: English
; Description ...: Constants for _WinAPI_DrawEdge().
; Author(s) .....: Gary Frost
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $BDR_RAISEDINNER = 0x4
Global Const $BDR_RAISEDOUTER = 0x1
Global Const $BDR_SUNKENINNER = 0x8
Global Const $BDR_SUNKENOUTER = 0x2
Global Const $EDGE_BUMP = BitOR($BDR_RAISEDOUTER, $BDR_SUNKENINNER)
Global Const $EDGE_ETCHED = BitOR($BDR_SUNKENOUTER, $BDR_RAISEDINNER)
Global Const $EDGE_RAISED = BitOR($BDR_RAISEDOUTER, $BDR_RAISEDINNER)
Global Const $EDGE_SUNKEN = BitOR($BDR_SUNKENOUTER, $BDR_SUNKENINNER)

; Type of Border
Global Const $BF_ADJUST = 0x2000
Global Const $BF_BOTTOM = 0x8
Global Const $BF_DIAGONAL = 0x10
Global Const $BF_FLAT = 0x4000
Global Const $BF_LEFT = 0x1
Global Const $BF_MIDDLE = 0x800
Global Const $BF_MONO = 0x8000
Global Const $BF_RIGHT = 0x4
Global Const $BF_SOFT = 0x1000
Global Const $BF_TOP = 0x2
Global Const $BF_BOTTOMLEFT = BitOR($BF_BOTTOM, $BF_LEFT)
Global Const $BF_BOTTOMRIGHT = BitOR($BF_BOTTOM, $BF_RIGHT)
Global Const $BF_TOPLEFT = BitOR($BF_TOP, $BF_LEFT)
Global Const $BF_TOPRIGHT = BitOR($BF_TOP, $BF_RIGHT)
Global Const $BF_RECT = BitOR($BF_LEFT, $BF_TOP, $BF_RIGHT, $BF_BOTTOM)
Global Const $BF_DIAGONAL_ENDBOTTOMLEFT = BitOR($BF_DIAGONAL, $BF_BOTTOM, $BF_LEFT)
Global Const $BF_DIAGONAL_ENDBOTTOMRIGHT = BitOR($BF_DIAGONAL, $BF_BOTTOM, $BF_RIGHT)
Global Const $BF_DIAGONAL_ENDTOPLEFT = BitOR($BF_DIAGONAL, $BF_TOP, $BF_LEFT)
Global Const $BF_DIAGONAL_ENDTOPRIGHT = BitOR($BF_DIAGONAL, $BF_TOP, $BF_RIGHT)

; ===============================================================================================================================
