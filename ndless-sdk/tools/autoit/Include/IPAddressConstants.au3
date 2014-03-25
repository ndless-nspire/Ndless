#include-once

; #INDEX# =======================================================================================================================
; Title .........: IPAddress_Constants
; AutoIt Version : 3.2
; Language ......: English
; Description ...: Constants for IPAddress functions.
; Author(s) .....: Valik, Gary Frost, ...
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__IPADDRESSCONSTANT_WM_USER = 0X400
Global Const $IPM_CLEARADDRESS = ($__IPADDRESSCONSTANT_WM_USER + 100)
Global Const $IPM_SETADDRESS = ($__IPADDRESSCONSTANT_WM_USER + 101)
Global Const $IPM_GETADDRESS = ($__IPADDRESSCONSTANT_WM_USER + 102)
Global Const $IPM_SETRANGE = ($__IPADDRESSCONSTANT_WM_USER + 103)
Global Const $IPM_SETFOCUS = ($__IPADDRESSCONSTANT_WM_USER + 104)
Global Const $IPM_ISBLANK = ($__IPADDRESSCONSTANT_WM_USER + 105)
; ===============================================================================================================================

; #NOTIFICATIONS# ===============================================================================================================
Global Const $IPN_FIRST = (-860)
Global Const $IPN_FIELDCHANGED = ($IPN_FIRST - 0) ; Sent when the user changes a field or moves from one field to another
; ===============================================================================================================================
