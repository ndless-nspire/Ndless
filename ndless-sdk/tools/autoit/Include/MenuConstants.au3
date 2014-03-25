#include-once

; #INDEX# =======================================================================================================================
; Title .........: Menu_Constants
; AutoIt Version : 3.2
; Language ......: English
; Description ...: Constants for Menu functions.
; Author(s) .....: Valik, Gary Frost, ...
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $MF_UNCHECKED = 0x0
Global Const $MF_STRING = 0x0
Global Const $MF_GRAYED = 0x00000001
Global Const $MF_DISABLED = 0x00000002
Global Const $MF_BITMAP = 0x00000004
Global Const $MF_CHECKED = 0x00000008
Global Const $MF_POPUP = 0x00000010
Global Const $MF_MENUBARBREAK = 0x00000020
Global Const $MF_MENUBREAK = 0x00000040
Global Const $MF_HILITE = 0x00000080
Global Const $MF_OWNERDRAW = 0x00000100
Global Const $MF_USECHECKBITMAPS = 0x00000200
Global Const $MF_BYPOSITION = 0x00000400
Global Const $MF_SEPARATOR = 0x00000800
Global Const $MF_DEFAULT = 0x00001000
Global Const $MF_SYSMENU = 0x00002000
Global Const $MF_HELP = 0x00004000
Global Const $MF_RIGHTJUSTIFY = 0x00004000
Global Const $MF_MOUSESELECT = 0x00008000

Global Const $MFS_GRAYED = 0x00000003
Global Const $MFS_DISABLED = $MFS_GRAYED
Global Const $MFS_CHECKED = $MF_CHECKED
Global Const $MFS_HILITE = $MF_HILITE
Global Const $MFS_DEFAULT = $MF_DEFAULT

Global Const $MFT_BITMAP = $MF_BITMAP
Global Const $MFT_MENUBARBREAK = $MF_MENUBARBREAK
Global Const $MFT_MENUBREAK = $MF_MENUBREAK
Global Const $MFT_OWNERDRAW = $MF_OWNERDRAW
Global Const $MFT_RADIOCHECK = 0x00000200
Global Const $MFT_SEPARATOR = $MF_SEPARATOR
Global Const $MFT_RIGHTORDER = 0x00002000
Global Const $MFT_RIGHTJUSTIFY = $MF_RIGHTJUSTIFY

Global Const $MIIM_STATE = 0x00000001
Global Const $MIIM_ID = 0x00000002
Global Const $MIIM_SUBMENU = 0x00000004
Global Const $MIIM_CHECKMARKS = 0x00000008
Global Const $MIIM_TYPE = 0x00000010
Global Const $MIIM_DATA = 0x00000020
Global Const $MIIM_DATAMASK = 0x0000003F
Global Const $MIIM_STRING = 0x00000040
Global Const $MIIM_BITMAP = 0x00000080
Global Const $MIIM_FTYPE = 0x00000100

Global Const $MIM_MAXHEIGHT = 0x00000001
Global Const $MIM_BACKGROUND = 0x00000002
Global Const $MIM_HELPID = 0x00000004
Global Const $MIM_MENUDATA = 0x00000008
Global Const $MIM_STYLE = 0x00000010
Global Const $MIM_APPLYTOSUBMENUS = 0x80000000

Global Const $MNS_CHECKORBMP = 0x04000000
Global Const $MNS_NOTIFYBYPOS = 0x08000000
Global Const $MNS_AUTODISMISS = 0x10000000
Global Const $MNS_DRAGDROP = 0x20000000
Global Const $MNS_MODELESS = 0x40000000
Global Const $MNS_NOCHECK = 0x80000000

Global Const $TPM_LEFTBUTTON = 0x0
Global Const $TPM_LEFTALIGN = 0x0
Global Const $TPM_TOPALIGN = 0x0
Global Const $TPM_HORIZONTAL = 0x0
Global Const $TPM_RECURSE = 0x00000001
Global Const $TPM_RIGHTBUTTON = 0x00000002
Global Const $TPM_CENTERALIGN = 0x00000004
Global Const $TPM_RIGHTALIGN = 0x00000008
Global Const $TPM_VCENTERALIGN = 0x00000010
Global Const $TPM_BOTTOMALIGN = 0x00000020
Global Const $TPM_VERTICAL = 0x00000040
Global Const $TPM_NONOTIFY = 0x00000080
Global Const $TPM_RETURNCMD = 0x00000100
Global Const $TPM_HORPOSANIMATION = 0x00000400
Global Const $TPM_HORNEGANIMATION = 0x00000800
Global Const $TPM_VERPOSANIMATION = 0x00001000
Global Const $TPM_VERNEGANIMATION = 0x00002000
Global Const $TPM_NOANIMATION = 0x00004000
Global Const $TPM_LAYOUTRTL = 0x00008000
; ===============================================================================================================================

; #System Menu Commands# ========================================================================================================
Global Const $SC_SIZE = 0xF000
Global Const $SC_MOVE = 0xF010
Global Const $SC_MINIMIZE = 0xF020
Global Const $SC_MAXIMIZE = 0xF030
Global Const $SC_NEXTWINDOW = 0xF040
Global Const $SC_PREVWINDOW = 0xF050
Global Const $SC_CLOSE = 0xF060
Global Const $SC_VSCROLL = 0xF070
Global Const $SC_HSCROLL = 0xF080
Global Const $SC_MOUSEMENU = 0xF090
Global Const $SC_KEYMENU = 0xF100
Global Const $SC_ARRANGE = 0xF110
Global Const $SC_RESTORE = 0xF120
Global Const $SC_TASKLIST = 0xF130
Global Const $SC_SCREENSAVE = 0xF140
Global Const $SC_HOTKEY = 0xF150
Global Const $SC_DEFAULT = 0xF160
Global Const $SC_MONITORPOWER = 0xF170
Global Const $SC_CONTEXTHELP = 0xF180
Global Const $SC_SEPARATOR = 0xF00F

; Reserved IDs for System Objects
Global Const $OBJID_SYSMENU = 0xFFFFFFFF
Global Const $OBJID_MENU = 0xFFFFFFFD
; ===============================================================================================================================
