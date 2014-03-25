#include-once

#include "MenuConstants.au3"
#include "WinAPI.au3"
#include "StructureConstants.au3"

; #INDEX# =======================================================================================================================
; Title .........: Menu
; AutoIt Version : 3.3.7.20++
; Language ......: English
; Description ...: Functions that assist with Menu control management.
;                  A menu is a list of items that specify options or groups of options (a submenu) for an application. Clicking a
;                  menu item opens a submenu or causes the application to carry out a command.
; Author(s) .....: Paul Campbell (PaulIA)
; Dll(s) ........: user32.dll
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__MENUCONSTANT_OBJID_CLIENT = 0xFFFFFFFC
; ===============================================================================================================================

; #NO_DOC_FUNCTION# =============================================================================================================
; Not working/documented/implemented at this time
;
;_GUICtrlMenu_EndMenu
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_GUICtrlMenu_AddMenuItem
;_GUICtrlMenu_AppendMenu
;_GUICtrlMenu_CheckMenuItem
;_GUICtrlMenu_CheckRadioItem
;_GUICtrlMenu_CreateMenu
;_GUICtrlMenu_CreatePopup
;_GUICtrlMenu_DeleteMenu
;_GUICtrlMenu_DestroyMenu
;_GUICtrlMenu_DrawMenuBar
;_GUICtrlMenu_EnableMenuItem
;_GUICtrlMenu_FindItem
;_GUICtrlMenu_FindParent
;_GUICtrlMenu_GetItemBmp
;_GUICtrlMenu_GetItemBmpChecked
;_GUICtrlMenu_GetItemBmpUnchecked
;_GUICtrlMenu_GetItemChecked
;_GUICtrlMenu_GetItemCount
;_GUICtrlMenu_GetItemData
;_GUICtrlMenu_GetItemDefault
;_GUICtrlMenu_GetItemDisabled
;_GUICtrlMenu_GetItemEnabled
;_GUICtrlMenu_GetItemGrayed
;_GUICtrlMenu_GetItemHighlighted
;_GUICtrlMenu_GetItemID
;_GUICtrlMenu_GetItemInfo
;_GUICtrlMenu_GetItemRect
;_GUICtrlMenu_GetItemRectEx
;_GUICtrlMenu_GetItemState
;_GUICtrlMenu_GetItemStateEx
;_GUICtrlMenu_GetItemSubMenu
;_GUICtrlMenu_GetItemText
;_GUICtrlMenu_GetItemType
;_GUICtrlMenu_GetMenu
;_GUICtrlMenu_GetMenuBackground
;_GUICtrlMenu_GetMenuBarInfo
;_GUICtrlMenu_GetMenuContextHelpID
;_GUICtrlMenu_GetMenuData
;_GUICtrlMenu_GetMenuDefaultItem
;_GUICtrlMenu_GetMenuHeight
;_GUICtrlMenu_GetMenuInfo
;_GUICtrlMenu_GetMenuStyle
;_GUICtrlMenu_GetSystemMenu
;_GUICtrlMenu_InsertMenuItem
;_GUICtrlMenu_InsertMenuItemEx
;_GUICtrlMenu_IsMenu
;_GUICtrlMenu_LoadMenu
;_GUICtrlMenu_MapAccelerator
;_GUICtrlMenu_MenuItemFromPoint
;_GUICtrlMenu_RemoveMenu
;_GUICtrlMenu_SetItemBitmaps
;_GUICtrlMenu_SetItemBmp
;_GUICtrlMenu_SetItemBmpChecked
;_GUICtrlMenu_SetItemBmpUnchecked
;_GUICtrlMenu_SetItemChecked
;_GUICtrlMenu_SetItemData
;_GUICtrlMenu_SetItemDefault
;_GUICtrlMenu_SetItemDisabled
;_GUICtrlMenu_SetItemEnabled
;_GUICtrlMenu_SetItemGrayed
;_GUICtrlMenu_SetItemHighlighted
;_GUICtrlMenu_SetItemID
;_GUICtrlMenu_SetItemInfo
;_GUICtrlMenu_SetItemState
;_GUICtrlMenu_SetItemSubMenu
;_GUICtrlMenu_SetItemText
;_GUICtrlMenu_SetItemType
;_GUICtrlMenu_SetMenu
;_GUICtrlMenu_SetMenuBackground
;_GUICtrlMenu_SetMenuContextHelpID
;_GUICtrlMenu_SetMenuData
;_GUICtrlMenu_SetMenuDefaultItem
;_GUICtrlMenu_SetMenuHeight
;_GUICtrlMenu_SetMenuInfo
;_GUICtrlMenu_SetMenuStyle
;_GUICtrlMenu_TrackPopupMenu
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;$tagMENUBARINFO
;$tagMDINEXTMENU
;$tagMENUGETOBJECTINFO
;$tagTPMPARAMS
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagMENUBARINFO
; Description ...: tagMENUBARINFO structure
; Fields ........: Size     - Specifies the size, in bytes, of the structure
;                  Left     - Specifies the x coordinate of the upper left corner of the rectangle
;                  Top      - Specifies the y coordinate of the upper left corner of the rectangle
;                  Right    - Specifies the x coordinate of the lower right corner of the rectangle
;                  Bottom   - Specifies the y coordinate of the lower right corner of the rectangle
;                  hMenu    - Handle to the menu bar or popup menu
;                  hWndMenu - Handle to the menu bar or popup menu
;                  Focused  - True if the item has focus
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagMENUBARINFO = "dword Size;" & $tagRECT & ";handle hMenu;handle hWndMenu;bool Focused"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagMDINEXTMENU
; Description ...: tagMDINEXTMENU structure
; Fields ........: hMenuIn   - Receives a handle to the current menu
;                  hMenuNext - Specifies a handle to the menu to be activated
;                  hWndNext  - Specifies a handle to the window to receive the menu notification messages
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagMDINEXTMENU = "handle hMenuIn;handle hMenuNext;hwnd hWndNext"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagMENUGETOBJECTINFO
; Description ...: tagMENUGETOBJECTINFO structure
; Fields ........: Flags - Position of the mouse cursor with respect to the item indicated by Pos. It can be one of the following
;                  +values.:
;                  |$MNGOF_BOTTOMGAP - Mouse is on the bottom of the item indicated by Pos
;                  |$MNGOF_TOPGAP    - Mouse is on the top of the item indicated by Pos
;                  Pos   - Position of the item the mouse cursor is on
;                  hMenu - Handle to the menu the mouse cursor is on
;                  RIID  - Identifier of the requested interface. Currently it can only be IDropTarget.
;                  Obj   - Pointer to the interface corresponding to the RIID member.  This pointer is  to  be  returned  by  the
;                  +application when processing the message.
; Author ........: Paul Campbell (PaulIA)
; Remarks .......: The tagMENUGETOBJECTINFO structure is used only in drag and drop menus.  When the $WM_MENUGETOBJECT message is
;                  sent, lParam is a pointer to  this  structure.  To  create  a  drag  and  drop  menu,  call  SetMenuInfo  with
;                  $MNS_DRAGDROP set
; ===============================================================================================================================
Global Const $tagMENUGETOBJECTINFO = "dword Flags;uint Pos;handle hMenu;ptr RIID;ptr Obj"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagTPMPARAMS
; Description ...: tagTPMPARAMS structure
; Fields ........: Size   - Size of structure, in bytes
;                  Left   - X position of upper left corner to exclude when positioing the window
;                  Top    - Y position of upper left corner to exclude when positioing the window
;                  Right  - X position of lower right corner to exclude when positioing the window
;                  Bottom - Y position of lower right corner to exclude when positioing the window
; Author ........: Paul Campbell (PaulIA)
; Remarks .......: All coordinates are in screen coordinates
; ===============================================================================================================================
Global Const $tagTPMPARAMS = "uint Size;" & $tagRECT

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_AddMenuItem
; Description ...: Adds a new menu item to the end of the menu
; Syntax.........: _GUICtrlMenu_AddMenuItem($hMenu, $sText[, $iCmdID = 0[, $hSubMenu = 0]])
; Parameters ....: $hMenu       - Handle of the menu
;                  $sText       - Menu item text. If blank, a separator will be added.
;                  $iCmdID      - Command ID to assign to the item
;                  $hSubMenu    - Handle to the submenu associated with the menu item
; Return values .: Success      - Zero based menu item index
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_InsertMenuItem
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_AddMenuItem($hMenu, $sText, $iCmdID = 0, $hSubMenu = 0)
	Local $iIndex = _GUICtrlMenu_GetItemCount($hMenu)
	Local $tMenu = DllStructCreate($tagMENUITEMINFO)
	DllStructSetData($tMenu, "Size", DllStructGetSize($tMenu))
	DllStructSetData($tMenu, "Mask", BitOR($MIIM_ID, $MIIM_STRING, $MIIM_SUBMENU))
	DllStructSetData($tMenu, "ID", $iCmdID)
	DllStructSetData($tMenu, "SubMenu", $hSubMenu)
	If $sText = "" Then
		DllStructSetData($tMenu, "Mask", $MIIM_FTYPE)
		DllStructSetData($tMenu, "Type", $MFT_SEPARATOR)
	Else
		DllStructSetData($tMenu, "Mask", BitOR($MIIM_ID, $MIIM_STRING, $MIIM_SUBMENU))
		Local $tText = DllStructCreate("wchar Text[" & StringLen($sText) + 1 & "]")
		DllStructSetData($tText, "Text", $sText)
		DllStructSetData($tMenu, "TypeData", DllStructGetPtr($tText))
	EndIf
	Local $aResult = DllCall("User32.dll", "bool", "InsertMenuItemW", "handle", $hMenu, "uint", $iIndex, "bool", True, "struct*", $tMenu)
	If @error Then Return SetError(@error, @extended, -1)
	Return SetExtended($aResult[0], $iIndex)
EndFunc   ;==>_GUICtrlMenu_AddMenuItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_AppendMenu
; Description ...: Appends a new item to the end of the specified menu bar, drop-down menu, submenu, or shortcut menu
; Syntax.........: _GUICtrlMenu_AppendMenu($hMenu, $iFlags, $iNewItem, $pNewItem)
; Parameters ....: $hMenu       - Handle of the menu
;                  $iFlags      - Specifies flags to control the appearance and behavior of the new menu item:
;                  |$MF_BITMAP       - Uses a bitmap as the menu item
;                  |$MF_CHECKED      - Places a check mark next to the menu item. If the application provides check-mark bitmaps,
;                  +this flag displays the check-mark bitmap next to the menu item.
;                  |$MF_DISABLED     - Disables the menu item so that it cannot be selected, but the flag does not gray it.
;                  |$MF_ENABLED      - Enables the menu item so that it can be selected, and restores it from its grayed state.
;                  |$MF_GRAYED       - Disables the menu item and grays it so that it cannot be selected.
;                  |$MF_MENUBARBREAK - Functions the same as $MF_MENUBREAK for a menu bar.  For a drop  down  menu,  submenu,  or
;                  +shortcut menu, the new column is separated from the old column by a vertical line.
;                  |$MF_MENUBREAK    - Places the item on a new line (for a menu bar) or in a new column (for a drop  down  menu,
;                  +submenu, or shortcut menu) without separating columns.
;                  |$MF_OWNERDRAW    - Specifies that the item is an owner drawn item. Before the menu is displayed for the first
;                  +time, the window that owns the menu receives a $WM_MEASUREITEM message to retrieve the width  and  height  of
;                  +the menu item. The $WM_DRAWITEM message is then sent to the window procedure of the owner window whenever the
;                  +appearance of the menu item must be updated.
;                  |$MF_POPUP        - Specifies that the menu item opens a drop down menu or  submenu.  The  iNewItem  parameter
;                  +specifies a handle to the drop down menu or submenu. This flag is used to add a menu name to a menu bar, or a
;                  +menu item that opens a submenu to a drop down menu, submenu, or shortcut menu.
;                  |$MF_SEPARATOR    - Draws a horizontal dividing line.  This flag is used only in a drop down menu, submenu, or
;                  +shortcut menu. The line cannot be grayed, disabled, or highlighted.  The pNewItem and iNewItem parameters are
;                  +ignored.
;                  |$MF_STRING       - Specifies that the menu item is a text string.  The pNewItem parameter is a string.
;                  |$MF_UNCHECKED    - Does not place a check mark next to the item.  If  the  application  supplies  check  mark
;                  +bitmaps, this flag displays the clear bitmap next to the menu item.
;                  $iNewItem    - Specifies either the identifier of the new menu item or, if the $iFlags parameter is set  to  a
;                  +popup, a handle to the drop down menu or submenu.
;                  $pNewItem    - Specifies the content of the new menu item.  The interpretation of pNewItem depends on  whether
;                  +the iFlags parameter includes the $MF_BITMAP, $MF_OWNERDRAW, or $MF_STRING flag:
;                  |$MF_BITMAP    - Contains a bitmap handle
;                  |$MF_OWNERDRAW - Contains an application supplied value that can be used to maintain additional  data  related
;                  +to the menu item. The value is in the ItemData member of the structure pointed to by the lParam parameter  of
;                  +the $WM_MEASUREITEM or $WM_DRAWITEM message sent when the menu is created or its appearance is updated.
;                  |$MF_STRING    - Contains a string
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_InsertMenuItem
; Link ..........: @@MsdnLink@@ AppendMenu
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_AppendMenu($hMenu, $iFlags, $iNewItem, $pNewItem)
	Local $sType = "wstr"
	If BitAND($iFlags, $MF_BITMAP) Then $sType = "handle"
	If BitAND($iFlags, $MF_OWNERDRAW) Then $sType = "ulong_ptr"
	Local $aResult = DllCall("User32.dll", "bool", "AppendMenuW", "handle", $hMenu, "uint", $iFlags, "uint_ptr", $iNewItem, $sType, $pNewItem)
	If @error Then Return SetError(@error, @extended, False)
	If $aResult[0] = 0 Then Return SetError(10, 0, False)

	_GUICtrlMenu_DrawMenuBar(_GUICtrlMenu_FindParent($hMenu))
	Return True
EndFunc   ;==>_GUICtrlMenu_AppendMenu

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_CheckMenuItem
; Description ...: Sets the state of the specified menu item's check mark attribute to either selected or clear
; Syntax.........: _GUICtrlMenu_CheckMenuItem($hMenu, $iItem[, $fCheck = True[, $fByPos = True]])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iItem       - Identifier or position of the menu item to check
;                  $fCheck      - True to set the check mark, False to remove it
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - The previous state of the menu item (either $MF_CHECKED or $MF_UNCHECKED)
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: An item in a menu bar cannot have a check mark. The $iItem parameter identifies a item that opens a submenu or
;                  a command item.  For an item that opens a submenu, the $Item parameter must specify the position of the  item.
;                  For a command item, the $Item parameter can specify either the item's position or its identifier.
; Related .......: _GUICtrlMenu_CheckRadioItem
; Link ..........: @@MsdnLink@@ CheckMenuItem
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_CheckMenuItem($hMenu, $iItem, $fCheck = True, $fByPos = True)
	Local $iByPos = 0

	If $fCheck Then $iByPos = BitOR($iByPos, $MF_CHECKED)
	If $fByPos Then $iByPos = BitOR($iByPos, $MF_BYPOSITION)
	Local $aResult = DllCall("User32.dll", "dword", "CheckMenuItem", "handle", $hMenu, "uint", $iItem, "uint", $iByPos)
	If @error Then Return SetError(@error, @extended, -1)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_CheckMenuItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_CheckRadioItem
; Description ...: Checks a specified menu item and makes it a radio item
; Syntax.........: _GUICtrlMenu_CheckRadioItem($hMenu, $iFirst, $iLast, $iCheck[, $fByPos = True])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iFirst      - Identifier or position of the first menu item in the group
;                  $iLast       - Identifier or position of the last menu item in the group
;                  $iCheck      - Identifier or position of the menu item to check
;                  $fByPos      - Menu identifier flag:
;                  | True - $iFirst, $iLast and $iCheck are a zero based item position
;                  |False - $iFirst, $iLast and $iCheck are a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function sets the $MFT_RADIOCHECK type flag and the $MFS_CHECKED state for the item specified by  $iCheck
;                  and, at the same time, clears both flags for all other items in the group. The checked item is displayed using
;                  a bullet bitmap instead of a check-mark bitmap.
; Related .......: _GUICtrlMenu_CheckMenuItem
; Link ..........: @@MsdnLink@@ CheckMenuRadioItem
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_CheckRadioItem($hMenu, $iFirst, $iLast, $iCheck, $fByPos = True)
	Local $iByPos = 0

	If $fByPos Then $iByPos = $MF_BYPOSITION
	Local $aResult = DllCall("User32.dll", "bool", "CheckMenuRadioItem", "handle", $hMenu, "uint", $iFirst, "uint", $iLast, "uint", $iCheck, "uint", $iByPos)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_CheckRadioItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_CreateMenu
; Description ...: Creates a menu
; Syntax.........: _GUICtrlMenu_CreateMenu([$iStyle = 8])
; Parameters ....: $iStyle      - Style of the menu. It can be one or more of the following values:
;                  | 1 - Menu automatically ends when mouse is outside the menu for 10 seconds
;                  | 2 - The same space is reserved for the check mark and the bitmap
;                  | 4 - Menu items are OLE drop targets or drag sources
;                  | 8 - Menu is modeless
;                  |16 - No space is reserved to the left of an item for a check mark
;                  |32 - Menu owner receives a WM_MENUCOMMAND message instead of a WM_COMMAND message for selections
; Return values .: Success      - Handle to the newly created menu
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Menu resources that are assigned to a window are freed automatically. If the menu is not assigned to a window,
;                  an application must free system resources associated with the menu before closing.  An application frees  menu
;                  resources by calling the _GUICtrlMenu_DestroyMenu function.
; Related .......: _GUICtrlMenu_CreatePopup, _GUICtrlMenu_DestroyMenu
; Link ..........: @@MsdnLink@@ CreateMenu
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_CreateMenu($iStyle = 8)
	Local $aResult = DllCall("User32.dll", "handle", "CreateMenu")
	If @error Then Return SetError(@error, @extended, 0)
	If $aResult[0] = 0 Then Return SetError(10, 0, 0)

	_GUICtrlMenu_SetMenuStyle($aResult[0], $iStyle)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_CreateMenu

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_CreatePopup
; Description ...: Creates a drop down menu, submenu, or shortcut menu
; Syntax.........: _GUICtrlMenu_CreatePopup([$iStyle = 8])
; Parameters ....: $iStyle      - Style of the menu. It can be one or more of the following values:
;                  | 1 - Menu automatically ends when mouse is outside the menu for 10 seconds
;                  | 2 - The same space is reserved for the check mark and the bitmap
;                  | 4 - Menu items are OLE drop targets or drag sources
;                  | 8 - Menu is modeless
;                  |16 - No space is reserved to the left of an item for a check mark
;                  |32 - Menu owner receives a WM_MENUCOMMAND message instead of a WM_COMMAND message for selections
; Return values .: Success      - Handle to the newly created  menu
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Menu resources that are assigned to a window are freed automatically. If the menu is not assigned to a window,
;                  an application must free system resources associated with the menu before closing.  An application frees  menu
;                  resources by calling the _GUICtrlMenu_DestroyMenu function.
; Related .......: _GUICtrlMenu_CreateMenu, _GUICtrlMenu_DestroyMenu
; Link ..........: @@MsdnLink@@ CreatePopupMenu
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_CreatePopup($iStyle = 8)
	Local $aResult = DllCall("User32.dll", "handle", "CreatePopupMenu")
	If @error Then Return SetError(@error, @extended, 0)
	If $aResult[0] = 0 Then Return SetError(10, 0, 0)

	_GUICtrlMenu_SetMenuStyle($aResult[0], $iStyle)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_CreatePopup

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_DeleteMenu
; Description ...: Deletes an item from the specified menu
; Syntax.........: _GUICtrlMenu_DeleteMenu($hMenu, $iItem[, $fByPos = True])
; Parameters ....: $hMenu       - Menu handle
;                  $iItem       - Identifier or position of the menu item
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_DestroyMenu
; Link ..........: @@MsdnLink@@ DeleteMenu
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_DeleteMenu($hMenu, $iItem, $fByPos = True)
	Local $iByPos = 0

	If $fByPos Then $iByPos = $MF_BYPOSITION
	Local $aResult = DllCall("User32.dll", "bool", "DeleteMenu", "handle", $hMenu, "uint", $iItem, "uint", $iByPos)
	If @error Then Return SetError(@error, @extended, False)
	If $aResult[0] = 0 Then Return SetError(10, 0, False)

	_GUICtrlMenu_DrawMenuBar(_GUICtrlMenu_FindParent($hMenu))
	Return True
EndFunc   ;==>_GUICtrlMenu_DeleteMenu

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_DestroyMenu
; Description ...: Destroys the specified menu and frees any memory that the menu occupies
; Syntax.........: _GUICtrlMenu_DestroyMenu($hMenu)
; Parameters ....: $hMenu       - Menu handle
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_DeleteMenu, _GUICtrlMenu_CreateMenu, _GUICtrlMenu_CreatePopup
; Link ..........: @@MsdnLink@@ DestroyMenu
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_DestroyMenu($hMenu)
	Local $aResult = DllCall("User32.dll", "bool", "DestroyMenu", "handle", $hMenu)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_DestroyMenu

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_DrawMenuBar
; Description ...: Redraws the menu bar of the specified window
; Syntax.........: _GUICtrlMenu_DrawMenuBar($hWnd)
; Parameters ....: $hWnd        - Handle to the window whose menu bar needs redrawing
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: If the menu bar changes after Windows has created the window, this function must be called to draw the menu bar.
; Related .......:
; Link ..........: @@MsdnLink@@ DrawMenuBar
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_DrawMenuBar($hWnd)
	Local $aResult = DllCall("User32.dll", "bool", "DrawMenuBar", "hwnd", $hWnd)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_DrawMenuBar

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_EnableMenuItem
; Description ...: Enables, disables, or grays the specified menu item
; Syntax.........: _GUICtrlMenu_EnableMenuItem($hMenu, $iItem[, $iState = 0[, $fByPos = True]])
; Parameters ....: $hMenu       - Menu handle
;                  $iItem       - Identifier or position of the menu item
;                  $iState      - Indicates whether the menu item is enabled, disabled, or grayed:
;                  |0 - Enabled
;                  |1 - Grayed
;                  |2 - Disabled
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ EnableMenuItem
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_EnableMenuItem($hMenu, $iItem, $iState = 0, $fByPos = True)
	Local $iByPos = $iState
	If $fByPos Then $iByPos = BitOR($iByPos, $MF_BYPOSITION)
	Local $aResult = DllCall("User32.dll", "bool", "EnableMenuItem", "handle", $hMenu, "uint", $iItem, "uint", $iByPos)
	If @error Then Return SetError(@error, @extended, False)
	If $aResult[0] = 0 Then Return SetError(10, 0, False)

	_GUICtrlMenu_DrawMenuBar(_GUICtrlMenu_FindParent($hMenu))
	Return True
EndFunc   ;==>_GUICtrlMenu_EnableMenuItem

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlMenu_EndMenu
; Description ...: Ends the calling thread's active menu
; Syntax.........: _GUICtrlMenu_EndMenu()
; Parameters ....:
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Does not work on menus in external programs
; Related .......:
; Link ..........: @@MsdnLink@@ EndMenu
; Example .......:
; ===============================================================================================================================
Func _GUICtrlMenu_EndMenu()
	Local $aResult = DllCall("User32.dll", "bool", "EndMenu")
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_EndMenu

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_FindItem
; Description ...: Retrieves a menu item based on it's text
; Syntax.........: _GUICtrlMenu_FindItem($hMenu, $sText[, $fInStr = False[, $iStart = 0]])
; Parameters ....: $hMenu       - Menu handle
;                  $sText       - Text to search for
;                  $fInStr      - If True, the text can be anywhere in the item's text.
;                  $iStart      - Item to start searching from
; Return values .: Success      - The zero based index of the first item that contains the text
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The search is case insensitive
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_FindItem($hMenu, $sText, $fInStr = False, $iStart = 0)
	Local $sMenu

	For $iI = $iStart To _GUICtrlMenu_GetItemCount($hMenu)
		$sMenu = StringReplace(_GUICtrlMenu_GetItemText($hMenu, $iI), "&", "")
		Switch $fInStr
			Case False
				If $sMenu = $sText Then Return $iI
			Case True
				If StringInStr($sMenu, $sText) Then Return $iI
		EndSwitch
	Next
	Return -1
EndFunc   ;==>_GUICtrlMenu_FindItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_FindParent
; Description ...: Retrieves the window to which a menu belongs
; Syntax.........: _GUICtrlMenu_FindParent($hMenu)
; Parameters ....: $hMenu       - Menu handle
; Return values .: Success      - Window handle
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetMenu
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_FindParent($hMenu)
	Local $hList = _WinAPI_EnumWindowsTop()
	For $iI = 1 To $hList[0][0]
		If _GUICtrlMenu_GetMenu($hList[$iI][0]) = $hMenu Then Return $hList[$iI][0]
	Next
EndFunc   ;==>_GUICtrlMenu_FindParent

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetItemBmp
; Description ...: Retrieves the bitmap displayed for the item
; Syntax.........: _GUICtrlMenu_GetItemBmp($hMenu, $iItem[, $fByPos = True])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iItem       - Identifier or position of the menu item
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - Handle to the bitmap to be displayed
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_SetItemBmp
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetItemBmp($hMenu, $iItem, $fByPos = True)
	Local $tInfo = _GUICtrlMenu_GetItemInfo($hMenu, $iItem, $fByPos)
	Return DllStructGetData($tInfo, "BmpItem")
EndFunc   ;==>_GUICtrlMenu_GetItemBmp

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetItemBmpChecked
; Description ...: Retrieves the bitmap displayed if the item is selected
; Syntax.........: _GUICtrlMenu_GetItemBmpChecked($hMenu, $iItem[, $fByPos = True])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iItem       - Identifier or position of the menu item
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - Handle to the bitmap to display next to the item if it is selected
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_SetItemBmpChecked
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetItemBmpChecked($hMenu, $iItem, $fByPos = True)
	Local $tInfo = _GUICtrlMenu_GetItemInfo($hMenu, $iItem, $fByPos)
	Return DllStructGetData($tInfo, "BmpChecked")
EndFunc   ;==>_GUICtrlMenu_GetItemBmpChecked

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetItemBmpUnchecked
; Description ...: Retrieves the bitmap displayed if the item is not selected
; Syntax.........: _GUICtrlMenu_GetItemBmpUnchecked($hMenu, $iItem[, $fByPos = True])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iItem       - Identifier or position of the menu item
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - Handle to the bitmap to display next to the item if it is not selected
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_SetItemBmpUnchecked
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetItemBmpUnchecked($hMenu, $iItem, $fByPos = True)
	Local $tInfo = _GUICtrlMenu_GetItemInfo($hMenu, $iItem, $fByPos)
	Return DllStructGetData($tInfo, "BmpUnchecked")
EndFunc   ;==>_GUICtrlMenu_GetItemBmpUnchecked

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetItemChecked
; Description ...: Retrieves the status of the menu item checked state
; Syntax.........: _GUICtrlMenu_GetItemChecked($hMenu, $iItem[, $fByPos = True])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iItem       - Identifier or position of the menu item
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: True         - Item is checked
;                  False        - Item is not checked
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_SetItemChecked
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetItemChecked($hMenu, $iItem, $fByPos = True)
	Return BitAND(_GUICtrlMenu_GetItemStateEx($hMenu, $iItem, $fByPos), $MF_CHECKED) <> 0
EndFunc   ;==>_GUICtrlMenu_GetItemChecked

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetItemCount
; Description ...: Retrieves the number of items in the specified menu
; Syntax.........: _GUICtrlMenu_GetItemCount($hMenu)
; Parameters ....: $hMenu       - Handle of the menu
; Return values .: Success      - The number of items in the menu
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GetMenuItemCount
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetItemCount($hMenu)
	Local $aResult = DllCall("User32.dll", "int", "GetMenuItemCount", "handle", $hMenu)
	If @error Then Return SetError(@error, @extended, -1)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_GetItemCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetItemData
; Description ...: Retrieves the application defined value associated with the menu item
; Syntax.........: _GUICtrlMenu_GetItemData($hMenu, $iItem[, $fByPos = True])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iItem       - Identifier or position of the menu item
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - Application defined value associated with the menu item
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_SetItemData
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetItemData($hMenu, $iItem, $fByPos = True)
	Local $tInfo = _GUICtrlMenu_GetItemInfo($hMenu, $iItem, $fByPos)
	Return DllStructGetData($tInfo, "ItemData")
EndFunc   ;==>_GUICtrlMenu_GetItemData

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetItemDefault
; Description ...: Retrieves the status of the menu item default state
; Syntax.........: _GUICtrlMenu_GetItemDefault($hMenu, $iItem[, $fByPos = True])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iItem       - Identifier or position of the menu item
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: True         - Item is the default item
;                  False        - Item is not the default item
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_SetItemDefault
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetItemDefault($hMenu, $iItem, $fByPos = True)
	Return BitAND(_GUICtrlMenu_GetItemStateEx($hMenu, $iItem, $fByPos), $MF_DEFAULT) <> 0
EndFunc   ;==>_GUICtrlMenu_GetItemDefault

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetItemDisabled
; Description ...: Retrieves the status of the menu item disabled state
; Syntax.........: _GUICtrlMenu_GetItemDisabled($hMenu, $iItem[, $fByPos = True])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iItem       - Identifier or position of the menu item
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: True         - Item is disabled
;                  False        - Item is not disabled
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_SetItemDisabled
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetItemDisabled($hMenu, $iItem, $fByPos = True)
	Return BitAND(_GUICtrlMenu_GetItemStateEx($hMenu, $iItem, $fByPos), $MF_DISABLED) <> 0
EndFunc   ;==>_GUICtrlMenu_GetItemDisabled

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetItemEnabled
; Description ...: Retrieves the status of the menu item enabled state
; Syntax.........: _GUICtrlMenu_GetItemEnabled($hMenu, $iItem[, $fByPos = True])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iItem       - Identifier or position of the menu item
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: True         - Item is enabled
;                  False        - Item is not enabled
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_SetItemEnabled
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetItemEnabled($hMenu, $iItem, $fByPos = True)
	Return BitAND(_GUICtrlMenu_GetItemStateEx($hMenu, $iItem, $fByPos), $MF_DISABLED) = 0
EndFunc   ;==>_GUICtrlMenu_GetItemEnabled

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetItemGrayed
; Description ...: Retrieves the status of the menu item grayed state
; Syntax.........: _GUICtrlMenu_GetItemGrayed($hMenu, $iItem[, $fByPos = True])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iItem       - Identifier or position of the menu item
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: True         - Item is grayed
;                  False        - Item is not grayed
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_SetItemGrayed
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetItemGrayed($hMenu, $iItem, $fByPos = True)
	Return BitAND(_GUICtrlMenu_GetItemStateEx($hMenu, $iItem, $fByPos), $MF_GRAYED) <> 0
EndFunc   ;==>_GUICtrlMenu_GetItemGrayed

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetItemHighlighted
; Description ...: Retrieves the status of the menu item highlighted state
; Syntax.........: _GUICtrlMenu_GetItemHighlighted($hMenu, $iItem[, $fByPos = True])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iItem       - Identifier or position of the menu item
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: True         - Item is highlighted
;                  False        - Item is not highlighted
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_SetItemHighlighted
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetItemHighlighted($hMenu, $iItem, $fByPos = True)
	Return BitAND(_GUICtrlMenu_GetItemStateEx($hMenu, $iItem, $fByPos), $MF_HILITE) <> 0
EndFunc   ;==>_GUICtrlMenu_GetItemHighlighted

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetItemID
; Description ...: Retrieves the menu item ID
; Syntax.........: _GUICtrlMenu_GetItemID($hMenu, $iItem[, $fByPos = True])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iItem       - Identifier or position of the menu item
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - Application defined value associated with the menu item
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_SetItemID
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetItemID($hMenu, $iItem, $fByPos = True)
	Local $tInfo = _GUICtrlMenu_GetItemInfo($hMenu, $iItem, $fByPos)
	Return DllStructGetData($tInfo, "ID")
EndFunc   ;==>_GUICtrlMenu_GetItemID

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetItemInfo
; Description ...: Retrieves information about a menu item
; Syntax.........: _GUICtrlMenu_GetItemInfo($hMenu, $iItem[, $fByPos = True])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iItem       - Identifier or position of the menu item
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - $tagMENUITEMINFO structure
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_SetItemInfo, $tagMENUITEMINFO
; Link ..........: @@MsdnLink@@ GetMenuItemInfo
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetItemInfo($hMenu, $iItem, $fByPos = True)
	Local $tInfo = DllStructCreate($tagMENUITEMINFO)
	DllStructSetData($tInfo, "Size", DllStructGetSize($tInfo))
	DllStructSetData($tInfo, "Mask", $MIIM_DATAMASK)
	Local $aResult = DllCall("User32.dll", "bool", "GetMenuItemInfo", "handle", $hMenu, "uint", $iItem, "bool", $fByPos, "struct*", $tInfo)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($aResult[0], $tInfo)
EndFunc   ;==>_GUICtrlMenu_GetItemInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetItemRect
; Description ...: Retrieves the bounding rectangle for the specified menu item
; Syntax.........: _GUICtrlMenu_GetItemRect($hWnd, $hMenu, $iItem)
; Parameters ....: $hWnd        - Handle to the window containing the menu
;                  $hMenu       - Handle of the menu
;                  $iItem       - Zero based position of the menu item
; Return values .: Success      - Array with the following format:
;                  |[0] = X coordinate of the upper left corner of the rectangle
;                  |[1] = Y coordinate of the upper left corner of the rectangle
;                  |[2] = X coordinate of the lower right corner of the rectangle
;                  |[3] = Y coordinate of the lower right corner of the rectangle
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetItemRectEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetItemRect($hWnd, $hMenu, $iItem)
	Local $tRect = _GUICtrlMenu_GetItemRectEx($hWnd, $hMenu, $iItem)
	Local $aRect[4]
	$aRect[0] = DllStructGetData($tRect, "Left")
	$aRect[1] = DllStructGetData($tRect, "Top")
	$aRect[2] = DllStructGetData($tRect, "Right")
	$aRect[3] = DllStructGetData($tRect, "Bottom")
	Return $aRect
EndFunc   ;==>_GUICtrlMenu_GetItemRect

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetItemRectEx
; Description ...: Retrieves the bounding rectangle for the specified menu item
; Syntax.........: _GUICtrlMenu_GetItemRectEx($hWnd, $hMenu, $iItem)
; Parameters ....: $hWnd        - Handle to the window containing the menu
;                  $hMenu       - Handle of the menu
;                  $iItem       - Zero based position of the menu item
; Return values .: Success      - tagRECT structure
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetItemRect
; Link ..........: @@MsdnLink@@ GetMenuItemRect
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetItemRectEx($hWnd, $hMenu, $iItem)
	Local $tRect = DllStructCreate($tagRECT)
	Local $aResult = DllCall("User32.dll", "bool", "GetMenuItemRect", "hwnd", $hWnd, "handle", $hMenu, "uint", $iItem, "struct*", $tRect)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($aResult[0], $tRect)
EndFunc   ;==>_GUICtrlMenu_GetItemRectEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetItemState
; Description ...: Retrieves the menu item state
; Syntax.........: _GUICtrlMenu_GetItemState($hMenu, $iItem[, $fByPos = True])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iItem       - Identifier or position of the menu item
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - Menu item type.  Can be one or more of the following:
;                  | 1 - Item is checked
;                  | 2 - Item is the default item
;                  | 4 - Item is disabled
;                  | 8 - Item is disabled
;                  |16 - Item is highlighted
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetItemStateEx, _GUICtrlMenu_SetItemState
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetItemState($hMenu, $iItem, $fByPos = True)
	Local $iRet = 0

	Local $iState = _GUICtrlMenu_GetItemStateEx($hMenu, $iItem, $fByPos)
	If BitAND($iState, $MFS_CHECKED) <> 0 Then $iRet = BitOR($iRet, 1)
	If BitAND($iState, $MFS_DEFAULT) <> 0 Then $iRet = BitOR($iRet, 2)
	If BitAND($iState, $MFS_DISABLED) <> 0 Then $iRet = BitOR($iRet, 4)
	If BitAND($iState, $MFS_GRAYED) <> 0 Then $iRet = BitOR($iRet, 8)
	If BitAND($iState, $MFS_HILITE) <> 0 Then $iRet = BitOR($iRet, 16)
	Return $iRet
EndFunc   ;==>_GUICtrlMenu_GetItemState

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetItemStateEx
; Description ...: Retrieves the menu flags associated with the specified menu item
; Syntax.........: _GUICtrlMenu_GetItemStateEx($hMenu, $iItem[, $fByPos = True])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iItem       - Identifier or position of the menu item
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - If the menu item opens a submenu the low-order byte of the return value contains the menu flags
;                  +associated with the item, and the high-order byte contains the number of items in the submenu opened  by  the
;                  +item. Otherwise, the return value is a mask of the menu flags.
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_SetItemState, _GUICtrlMenu_GetItemState
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetItemStateEx($hMenu, $iItem, $fByPos = True)
	Local $tInfo = _GUICtrlMenu_GetItemInfo($hMenu, $iItem, $fByPos)
	Return DllStructGetData($tInfo, "State")
EndFunc   ;==>_GUICtrlMenu_GetItemStateEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetItemSubMenu
; Description ...: Retrieves a the submenu activated by a specified item
; Syntax.........: _GUICtrlMenu_GetItemSubMenu($hMenu, $iItem)
; Parameters ....: $hMenu       - Handle of the menu
;                  $iItem       - Zero based position of the menu item
; Return values .: Success      - A handle to the drop down menu or submenu activated by the menu item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_SetItemSubMenu, _GUICtrlMenu_RemoveMenu
; Link ..........: @@MsdnLink@@ GetSubMenu
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetItemSubMenu($hMenu, $iItem)
	Local $aResult = DllCall("User32.dll", "handle", "GetSubMenu", "handle", $hMenu, "int", $iItem)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_GetItemSubMenu

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetItemText
; Description ...: Retrieves the text of the specified menu item
; Syntax.........: _GUICtrlMenu_GetItemText($hMenu, $iItem[, $fByPos = True])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iItem       - Identifier or position of the menu item
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - Menu item text
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_SetItemText
; Link ..........: @@MsdnLink@@ GetMenuString
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetItemText($hMenu, $iItem, $fByPos = True)
	Local $iByPos = 0

	If $fByPos Then $iByPos = $MF_BYPOSITION
	Local $aResult = DllCall("User32.dll", "int", "GetMenuStringW", "handle", $hMenu, "uint", $iItem, "wstr", 0, "int", 4096, "uint", $iByPos)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($aResult[0], $aResult[3])
EndFunc   ;==>_GUICtrlMenu_GetItemText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetItemType
; Description ...: Retrieves the menu item type
; Syntax.........: _GUICtrlMenu_GetItemType($hMenu, $iItem[, $fByPos = True])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iItem       - Identifier or position of the menu item
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - Menu item type.  Can be one or more of the following:
;                  |$MFT_BITMAP       - Item is displayed using a bitmap
;                  |$MFT_MENUBARBREAK - Item is placed on a new line. A vertical line separates the new column from the old.
;                  |$MFT_MENUBREAK    - Item is placed on a new line. The columns are not separated by a vertical line.
;                  |$MFT_OWNERDRAW    - Item is owner drawn
;                  |$MFT_RADIOCHECK   - Item is displayed using a radio button mark
;                  |$MFT_RIGHTJUSTIFY - Item is right justified
;                  |$MFT_RIGHTORDER   - Item cascades from right to left
;                  |$MFT_SEPARATOR    - Item is a separator
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_SetItemType
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetItemType($hMenu, $iItem, $fByPos = True)
	Local $tInfo = _GUICtrlMenu_GetItemInfo($hMenu, $iItem, $fByPos)
	Return DllStructGetData($tInfo, "Type")
EndFunc   ;==>_GUICtrlMenu_GetItemType

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetMenu
; Description ...: Retrieves the handle of the menu assigned to the given window
; Syntax.........: _GUICtrlMenu_GetMenu($hWnd)
; Parameters ....: $hWnd        - Identifies the window whose menu handle is retrieved
; Return values .: Success      - The handle of the menu
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: _GUICtrlMenu_GetMenu does not work on floating menu bars.  Floating menu bars are custom controls that mimic standard
;                  menus, but are not menus.
; Related .......: _GUICtrlMenu_SetMenu, _GUICtrlMenu_FindParent
; Link ..........: @@MsdnLink@@ GetMenu
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetMenu($hWnd)
	Local $aResult = DllCall("User32.dll", "handle", "GetMenu", "hwnd", $hWnd)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_GetMenu

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetMenuBackground
; Description ...: Retrieves the brush to use for the menu's background
; Syntax.........: _GUICtrlMenu_GetMenuBackground($hMenu)
; Parameters ....: $hMenu       - Handle of the menu
; Return values .: Success      - Brush used for the menu's background
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_SetMenuBackground
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetMenuBackground($hMenu)
	Local $tInfo = _GUICtrlMenu_GetMenuInfo($hMenu)
	Return DllStructGetData($tInfo, "hBack")
EndFunc   ;==>_GUICtrlMenu_GetMenuBackground

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetMenuBarInfo
; Description ...: Retrieves information about the specified menu bar
; Syntax.........: _GUICtrlMenu_GetMenuBarInfo($hWnd[, $iItem = 0[, $iObject = 1]])
; Parameters ....: $hWnd        - Handle to the window  whose information is to be retrieved
;                  $iItem       - Specifies the item for which to retrieve information.  If 0, the function retrieves information
;                  +about the menu itself. If 1, the function retrieves information about the first item on the menu, and so on.
;                  $iObject     - Specifies the menu object:
;                  |0 - The popup menu associated with the window
;                  |1 - The menu bar associated with the window
;                  |2 - The system menu associated with the window
; Return values .: Success      - Array with the following format:
;                  |[0] - X coordinate of the upper left corner of the rectangle
;                  |[1] - Y coordinate of the upper left corner of the rectangle
;                  |[2] - X coordinate of the lower right corner of the rectangle
;                  |[3] - Y coordinate of the lower right corner of the rectangle
;                  |[4] - Handle to the menu bar or popup menu
;                  |[5] - Handle to the submenu
;                  |[6] - True if the menu bar has focus, otherwise False
;                  |[7] - True if the menu item has focus, otherwise False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GetMenuBarInfo
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetMenuBarInfo($hWnd, $iItem = 0, $iObject = 1)
	Local $aObject[3] = [$__MENUCONSTANT_OBJID_CLIENT, $OBJID_MENU, $OBJID_SYSMENU]

	Local $tInfo = DllStructCreate($tagMENUBARINFO)
	DllStructSetData($tInfo, "Size", DllStructGetSize($tInfo))
	Local $aResult = DllCall("User32.dll", "bool", "GetMenuBarInfo", "hwnd", $hWnd, "long", $aObject[$iObject], "long", $iItem, "struct*", $tInfo)
	If @error Then Return SetError(@error, @extended, 0)
	Local $aInfo[8]
	$aInfo[0] = DllStructGetData($tInfo, "Left")
	$aInfo[1] = DllStructGetData($tInfo, "Top")
	$aInfo[2] = DllStructGetData($tInfo, "Right")
	$aInfo[3] = DllStructGetData($tInfo, "Bottom")
	$aInfo[4] = DllStructGetData($tInfo, "hMenu")
	$aInfo[5] = DllStructGetData($tInfo, "hWndMenu")
	$aInfo[6] = BitAND(DllStructGetData($tInfo, "Focused"), 1) <> 0
	$aInfo[7] = BitAND(DllStructGetData($tInfo, "Focused"), 2) <> 0
	Return SetExtended($aResult[0], $aInfo)
EndFunc   ;==>_GUICtrlMenu_GetMenuBarInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetMenuContextHelpID
; Description ...: Retrieves the context help identifier
; Syntax.........: _GUICtrlMenu_GetMenuContextHelpID($hMenu)
; Parameters ....: $hMenu       - Handle of the menu
; Return values .: Success      - Context help identifier
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_SetMenuContextHelpID
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetMenuContextHelpID($hMenu)
	Local $tInfo = _GUICtrlMenu_GetMenuInfo($hMenu)
	Return DllStructGetData($tInfo, "ContextHelpID")
EndFunc   ;==>_GUICtrlMenu_GetMenuContextHelpID

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetMenuData
; Description ...: Retrieves the application defined value
; Syntax.........: _GUICtrlMenu_GetMenuData($hMenu)
; Parameters ....: $hMenu       - Handle of the menu
; Return values .: Success      - Application defined value
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_SetMenuData
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetMenuData($hMenu)
	Local $tInfo = _GUICtrlMenu_GetMenuInfo($hMenu)
	Return DllStructGetData($tInfo, "MenuData")
EndFunc   ;==>_GUICtrlMenu_GetMenuData

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetMenuDefaultItem
; Description ...: Retrieves the default menu item on the specified menu
; Syntax.........: _GUICtrlMenu_GetMenuDefaultItem($hMenu[, $fByPos = True[, $iFlags = 0]])
; Parameters ....: $hMenu       - Handle of the menu
;                  $fByPos      - Determines whether to retrive the menu items's identifer of it's position:
;                  | True - Return menu item position
;                  |False - Return menu item identifier
;                  $iFlags   - Specifies how the function searches for menu items:
;                  |0 - No special search parameters
;                  |1 - Specifies that the function will return a default item even if it is disabled
;                  |2 - Specifies that if the default item is one that opens a submenu the function is to search  recursively  in
;                  +the corresponding submenu.
; Return values .: Success      - The identifier or position of the menu item
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_SetMenuDefaultItem
; Link ..........: @@MsdnLink@@ GetMenuDefaultItem
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetMenuDefaultItem($hMenu, $fByPos = True, $iFlags = 0)
	Local $aResult = DllCall("User32.dll", "INT", "GetMenuDefaultItem", "handle", $hMenu, "uint", $fByPos, "uint", $iFlags)
	If @error Then Return SetError(@error, @extended, -1)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_GetMenuDefaultItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetMenuHeight
; Description ...: Retrieves the maximum height of a menu
; Syntax.........: _GUICtrlMenu_GetMenuHeight($hMenu)
; Parameters ....: $hMenu       - Handle of the menu
; Return values .: Success      - Maximum height of the menu in pixels
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: When the menu items exceed the space available, scroll bars are automatically used.  The default (0) is the screen height.
; Related .......: _GUICtrlMenu_SetMenuHeight
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetMenuHeight($hMenu)
	Local $tInfo = _GUICtrlMenu_GetMenuInfo($hMenu)
	Return DllStructGetData($tInfo, "YMax")
EndFunc   ;==>_GUICtrlMenu_GetMenuHeight

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetMenuInfo
; Description ...: Retrieves information about a specified menu
; Syntax.........: _GUICtrlMenu_GetMenuInfo($hMenu)
; Parameters ....: $hMenu       - Handle of the menu
; Return values .: Success      - $tagMENUINFO structure
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_SetMenuInfo, $tagMENUINFO
; Link ..........: @@MsdnLink@@ GetMenuInfo
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetMenuInfo($hMenu)
	Local $tInfo = DllStructCreate($tagMENUINFO)
	DllStructSetData($tInfo, "Size", DllStructGetSize($tInfo))
	DllStructSetData($tInfo, "Mask", BitOR($MIM_BACKGROUND, $MIM_HELPID, $MIM_MAXHEIGHT, $MIM_MENUDATA, $MIM_STYLE))
	Local $aResult = DllCall("User32.dll", "bool", "GetMenuInfo", "handle", $hMenu, "struct*", $tInfo)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($aResult[0], $tInfo)
EndFunc   ;==>_GUICtrlMenu_GetMenuInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetMenuStyle
; Description ...: Retrieves the style information for a menu
; Syntax.........: _GUICtrlMenu_GetMenuStyle($hMenu)
; Parameters ....: $hMenu       - Handle of the menu
; Return values .: Success      - Style of the menu. It can be one or more of the following values:
;                  |$MNS_AUTODISMISS - Menu automatically ends when mouse is outside the menu for 10 seconds
;                  |$MNS_CHECKORBMP  - The same space is reserved for the check mark and the bitmap
;                  |$MNS_DRAGDROP    - Menu items are OLE drop targets or drag sources
;                  |$MNS_MODELESS    - Menu is modeless
;                  |$MNS_NOCHECK     - No space is reserved to the left of an item for a check mark
;                  |$MNS_NOTIFYBYPOS - Menu owner receives a $WM_MENUCOMMAND message instead of  a  $WM_COMMAND  message  when  a
;                  +selection is made.
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_SetMenuStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetMenuStyle($hMenu)
	Local $tInfo = _GUICtrlMenu_GetMenuInfo($hMenu)
	Return DllStructGetData($tInfo, "Style")
EndFunc   ;==>_GUICtrlMenu_GetMenuStyle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_GetSystemMenu
; Description ...: Allows the application to access the window menu for copying and modifying
; Syntax.........: _GUICtrlMenu_GetSystemMenu($hWnd[, $fRevert = False])
; Parameters ....: $hWnd        - Handle to the window that will own a copy of the window menu
;                  $fRevert     - Specifies the action to be taken. If this parameter is False, the function returns a handle  to
;                  +the copy of the window menu currently in use.  The copy is initially identical to the window menu, but it can
;                  +be modified. If this parameter is True, the function resets the window menu back to the  default  state.  The
;                  +previous window menu, if any, is destroyed.
; Return values .: Success      - If the $fRevert parameter is False, the return value is a handle to a copy of the window  menu.
;                  +If the $fRevert parameter is True, the return value is 0.
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Any window that does not use the GetSystemMenu function to make its own copy of the window menu  receives  the
;                  standard window menu.  The window menu initially contains  items  with  various  identifier  values,  such  as
;                  $SC_CLOSE, $SC_MOVE, and $SC_SIZE. Menu items on the window menu send $WM_SYSCOMMAND messages.  All predefined
;                  window menu items have identifier numbers greater than 0xF000.  If an application adds commands to the  window
;                  menu, it should use identifier numbers less than 0xF000.  The system automatically grays items on the standard
;                  window menu, depending on the situation. The application can perform its own checking or graying by responding
;                  to the $WM_INITMENU message that is sent before any menu is displayed.
; Related .......:
; Link ..........: @@MsdnLink@@ GetSystemMenu
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_GetSystemMenu($hWnd, $fRevert = False)
	Local $aResult = DllCall("User32.dll", "hwnd", "GetSystemMenu", "hwnd", $hWnd, "int", $fRevert)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_GetSystemMenu

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_InsertMenuItem
; Description ...: Inserts a new menu item at the specified position
; Syntax.........: _GUICtrlMenu_InsertMenuItem($hMenu, $iIndex, $sText[, $iCmdID = 0[, $hSubMenu = 0]])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iIndex      - Zero based position of the menu item before which to insert the new item
;                  $sText       - Menu item text. If blank, a separator will be inserted.
;                  $iCmdID      - Command ID to assign to the item
;                  $hSubMenu    - Handle to the submenu associated with the menu item
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_InsertMenuItemEx, _GUICtrlMenu_AddMenuItem, _GUICtrlMenu_AppendMenu
; Link ..........: @@MsdnLink@@ InsertMenuItem
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_InsertMenuItem($hMenu, $iIndex, $sText, $iCmdID = 0, $hSubMenu = 0)
	Local $tMenu = DllStructCreate($tagMENUITEMINFO)
	DllStructSetData($tMenu, "Size", DllStructGetSize($tMenu))
	DllStructSetData($tMenu, "Mask", BitOR($MIIM_ID, $MIIM_STRING, $MIIM_SUBMENU))
	DllStructSetData($tMenu, "ID", $iCmdID)
	DllStructSetData($tMenu, "SubMenu", $hSubMenu)
	If $sText = "" Then
		DllStructSetData($tMenu, "Mask", $MIIM_FTYPE)
		DllStructSetData($tMenu, "Type", $MFT_SEPARATOR)
	Else
		DllStructSetData($tMenu, "Mask", BitOR($MIIM_ID, $MIIM_STRING, $MIIM_SUBMENU))
		Local $tText = DllStructCreate("wchar Text[" & StringLen($sText) + 1 & "]")
		DllStructSetData($tText, "Text", $sText)
		DllStructSetData($tMenu, "TypeData", DllStructGetPtr($tText))
	EndIf
	Local $aResult = DllCall("User32.dll", "bool", "InsertMenuItemW", "handle", $hMenu, "uint", $iIndex, "bool", True, "struct*", $tMenu)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_InsertMenuItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_InsertMenuItemEx
; Description ...: Inserts a new menu item at the specified position in a menu
; Syntax.........: _GUICtrlMenu_InsertMenuItemEx($hMenu, $iIndex, ByRef $tMenu[, $fByPos = True])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iIndex      - Position of the menu item before which to insert the new item
;                  $tMenu       - $tagMENUITEMINFO structure
;                  $fByPos      - Menu identifier flag:
;                  | True - $iIndex is a zero based item position
;                  |False - $iIndex is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_InsertMenuItem, $tagMENUITEMINFO
; Link ..........: @@MsdnLink@@ InsertMenuItem
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_InsertMenuItemEx($hMenu, $iIndex, ByRef $tMenu, $fByPos = True)
	Local $aResult = DllCall("User32.dll", "bool", "InsertMenuItemW", "handle", $hMenu, "uint", $iIndex, "bool", $fByPos, "struct*", $tMenu)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_InsertMenuItemEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_IsMenu
; Description ...: Determines whether a handle is a menu handle
; Syntax.........: _GUICtrlMenu_IsMenu($hMenu)
; Parameters ....: $hMenu       - Handle to be tested
; Return values .: True         - Handle is a menu handle
;                  False        - Handle is not a menu handle
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ IsMenu
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_IsMenu($hMenu)
	Local $aResult = DllCall("User32.dll", "bool", "IsMenu", "handle", $hMenu)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_IsMenu

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_LoadMenu
; Description ...: Loads the specified menu resource from the executable file associated with an application instance
; Syntax.........: _GUICtrlMenu_LoadMenu($hInst, $sMenuName)
; Parameters ....: $hInst       - Handle to the module containing the menu resource to be loaded
;                  $sMenuName   - String that contains the name of the menu resource.  Alternatively, this parameter can  consist
;                  +of the resource identifier in the low order word and 0 in the high order word.
; Return values .: Success      - Handle to the menu resource
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ LoadMenu
; Example .......:
; ===============================================================================================================================
Func _GUICtrlMenu_LoadMenu($hInst, $sMenuName)
	Local $aResult = DllCall("User32.dll", "handle", "LoadMenuW", "handle", $hInst, "wstr", $sMenuName)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_LoadMenu

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_MapAccelerator
; Description ...: Maps a menu accelerator key to it's position in the menu
; Syntax.........: _GUICtrlMenu_MapAccelerator($hMenu, $cAccel)
; Parameters ....: $hMenu       - Handle to menu
;                  $cAccel      - Accelerator key
; Return values .: Success      - The zero based position of the item in the menu
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_MapAccelerator($hMenu, $cAccel)
	Local $sText

	Local $iCount = _GUICtrlMenu_GetItemCount($hMenu)
	For $iI = 0 To $iCount - 1
		$sText = _GUICtrlMenu_GetItemText($hMenu, $iI)
		If StringInStr($sText, "&" & $cAccel) > 0 Then Return $iI
	Next
	Return -1
EndFunc   ;==>_GUICtrlMenu_MapAccelerator

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_MenuItemFromPoint
; Description ...: Determines which menu item is at the specified location.
; Syntax.........: _GUICtrlMenu_MenuItemFromPoint($hWnd, $hMenu[, $iX = -1[, $iY = -1]])
; Parameters ....: $hWnd  - Handle to the window containing the menu. If this value is 0 and $hMenu represents a popup menu,  the
;                  +function will find the menu window.
;                  $hMenu - Handle to the menu containing the menu items to hit test
;                  $iX    - X position to test. If -1, the current mouse X position will be used.
;                  $iY    - Y position to test. If -1, the current mouse Y position will be used.
; Return values .: Success      - The zero based position of the menu item at the specified location
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: If $hMenu specifies a menu bar the coordinates are window coordinates. Otherwise, they are client coordinates.
; Related .......:
; Link ..........: @@MsdnLink@@ MenuItemFromPoint
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_MenuItemFromPoint($hWnd, $hMenu, $iX = -1, $iY = -1)
	If $iX = -1 Then $iX = _WinAPI_GetMousePosX()
	If $iY = -1 Then $iY = _WinAPI_GetMousePosY()
	Local $aResult = DllCall("User32.dll", "int", "MenuItemFromPoint", "hwnd", $hWnd, "handle", $hMenu, "int", $iX, "int", $iY)
	If @error Then Return SetError(@error, @extended, -1)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_MenuItemFromPoint

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_RemoveMenu
; Description ...: Deletes a menu item or detaches a submenu from the specified menu
; Syntax.........: _GUICtrlMenu_RemoveMenu($hMenu, $iItem[, $fByPos = True])
; Parameters ....: $hMenu       - Handle to the menu to be changed
;                  $iItem       - Identifier or position of the menu item
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: If the menu item opens a drop down menu or submenu, _GUICtrlMenu_RemoveMenu does not destroy the menu or its  handle,
;                  allowing the menu to be reused.  Before this function is called, the _GUICtrlMenu_GetItemSubMenu function  should  be
;                  used retrieve a handle to the drop-down menu or submenu.
; Related .......: _GUICtrlMenu_GetItemSubMenu
; Link ..........: @@MsdnLink@@ RemoveMenu
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_RemoveMenu($hMenu, $iItem, $fByPos = True)
	Local $iByPos = 0

	If $fByPos Then $iByPos = $MF_BYPOSITION
	Local $aResult = DllCall("User32.dll", "bool", "RemoveMenu", "handle", $hMenu, "uint", $iItem, "uint", $iByPos)
	If @error Then Return SetError(@error, @extended, False)
	If $aResult[0] = 0 Then Return SetError(10, 0, False)

	_GUICtrlMenu_DrawMenuBar(_GUICtrlMenu_FindParent($hMenu))
	Return True
EndFunc   ;==>_GUICtrlMenu_RemoveMenu

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetItemBitmaps
; Description ...: Associates the specified bitmap with a menu item
; Syntax.........: _GUICtrlMenu_SetItemBitmaps($hMenu, $iItem, $hChecked, $hUnChecked[, $fByPos = True])
; Parameters ....: $hMenu       - Menu handle
;                  $iItem       - Identifier or position of the menu item
;                  $hChecked    - Handle to the bitmap displayed when the menu item is selected
;                  $hUnChecked  - Handle to the bitmap displayed when the menu item is not selected
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: If either the hBitmapUnchecked or hBitmapChecked parameter is 0, the system displays nothing next to the  menu
;                  item for the corresponding check state.  If both parameters are 0, the system displays the default check  mark
;                  bitmap when the item is selected, and removes the bitmap when the item is not selected.
; Related .......: _GUICtrlMenu_SetItemBmpChecked, _GUICtrlMenu_SetItemBmpUnchecked
; Link ..........: @@MsdnLink@@ SetMenuItemBitmaps
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetItemBitmaps($hMenu, $iItem, $hChecked, $hUnChecked, $fByPos = True)
	Local $iByPos = 0

	If $fByPos Then $iByPos = $MF_BYPOSITION
	Local $aResult = DllCall("User32.dll", "bool", "SetMenuItemBitmaps", "handle", $hMenu, "uint", $iItem, "uint", $iByPos, "handle", $hUnChecked, "handle", $hChecked)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_SetItemBitmaps

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetItemBmp
; Description ...: Sets the bitmap displayed for the item
; Syntax.........: _GUICtrlMenu_SetItemBmp($hMenu, $iItem, $hBmp[, $fByPos = True])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iItem       - Identifier or position of the menu item
;                  $hBmp        - Handle to the item bitmap
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetItemBmp
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetItemBmp($hMenu, $iItem, $hBmp, $fByPos = True)
	Local $tInfo = DllStructCreate($tagMENUITEMINFO)
	DllStructSetData($tInfo, "Size", DllStructGetSize($tInfo))
	DllStructSetData($tInfo, "Mask", $MIIM_BITMAP)
	DllStructSetData($tInfo, "BmpItem", $hBmp)
	Return _GUICtrlMenu_SetItemInfo($hMenu, $iItem, $tInfo, $fByPos)
EndFunc   ;==>_GUICtrlMenu_SetItemBmp

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetItemBmpChecked
; Description ...: Sets the bitmap displayed if the item is selected
; Syntax.........: _GUICtrlMenu_SetItemBmpChecked($hMenu, $iItem, $hBmp[, $fByPos = True])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iItem       - Identifier or position of the menu item
;                  $hBmp        - Handle to the bitmap to display next to the item if it is selected
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetItemBmpChecked, _GUICtrlMenu_SetItemBitmaps
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetItemBmpChecked($hMenu, $iItem, $hBmp, $fByPos = True)
	Local $tInfo = _GUICtrlMenu_GetItemInfo($hMenu, $iItem, $fByPos)
	DllStructSetData($tInfo, "Mask", $MIIM_CHECKMARKS)
	DllStructSetData($tInfo, "BmpChecked", $hBmp)
	Return _GUICtrlMenu_SetItemInfo($hMenu, $iItem, $tInfo, $fByPos)
EndFunc   ;==>_GUICtrlMenu_SetItemBmpChecked

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetItemBmpUnchecked
; Description ...: Sets the bitmap displayed if the item is not selected
; Syntax.........: _GUICtrlMenu_SetItemBmpUnchecked($hMenu, $iItem, $hBmp[, $fByPos = True])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iItem       - Identifier or position of the menu item
;                  $hBmp        - Handle to the bitmap to display next to the item if it is not selected
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetItemBmpUnchecked, _GUICtrlMenu_SetItemBitmaps
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetItemBmpUnchecked($hMenu, $iItem, $hBmp, $fByPos = True)
	Local $tInfo = _GUICtrlMenu_GetItemInfo($hMenu, $iItem, $fByPos)
	DllStructSetData($tInfo, "Mask", $MIIM_CHECKMARKS)
	DllStructSetData($tInfo, "BmpUnchecked", $hBmp)
	Return _GUICtrlMenu_SetItemInfo($hMenu, $iItem, $tInfo, $fByPos)
EndFunc   ;==>_GUICtrlMenu_SetItemBmpUnchecked

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetItemChecked
; Description ...: Sets the checked state of a menu item
; Syntax.........: _GUICtrlMenu_SetItemChecked($hMenu, $iItem[, $fState = True[, $fByPos = True]])
; Parameters ....: $hMenu       - Menu handle
;                  $iItem       - Identifier or position of the menu item
;                  $fState      - True to set state, otherwise False
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetItemChecked
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetItemChecked($hMenu, $iItem, $fState = True, $fByPos = True)
	Return _GUICtrlMenu_SetItemState($hMenu, $iItem, $MFS_CHECKED, $fState, $fByPos)
EndFunc   ;==>_GUICtrlMenu_SetItemChecked

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetItemData
; Description ...: Sets the application defined value for a menu item
; Syntax.........: _GUICtrlMenu_SetItemData($hMenu, $iItem, $iData[, $fByPos = True])
; Parameters ....: $hMenu       - Menu handle
;                  $iItem       - Identifier or position of the menu item
;                  $iData       - Application defined value
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetItemData
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetItemData($hMenu, $iItem, $iData, $fByPos = True)
	Local $tInfo = DllStructCreate($tagMENUITEMINFO)
	DllStructSetData($tInfo, "Size", DllStructGetSize($tInfo))
	DllStructSetData($tInfo, "Mask", $MIIM_DATA)
	DllStructSetData($tInfo, "ItemData", $iData)
	Return _GUICtrlMenu_SetItemInfo($hMenu, $iItem, $tInfo, $fByPos)
EndFunc   ;==>_GUICtrlMenu_SetItemData

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetItemDefault
; Description ...: Sets the status of the menu item default state
; Syntax.........: _GUICtrlMenu_SetItemDefault($hMenu, $iItem[, $fState = True[, $fByPos = True]])
; Parameters ....: $hMenu       - Handle of the menu
;                  $iItem       - Identifier or position of the menu item
;                  $fState      - Item state to set:
;                  | True - State is enabled
;                  |False - State is disabled
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetItemDefault
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetItemDefault($hMenu, $iItem, $fState = True, $fByPos = True)
	Return _GUICtrlMenu_SetItemState($hMenu, $iItem, $MFS_DEFAULT, $fState, $fByPos)
EndFunc   ;==>_GUICtrlMenu_SetItemDefault

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetItemDisabled
; Description ...: Sets the disabled state of a menu item
; Syntax.........: _GUICtrlMenu_SetItemDisabled($hMenu, $iItem[, $fState = True[, $fByPos = True]])
; Parameters ....: $hMenu       - Menu handle
;                  $iItem       - Identifier or position of the menu item
;                  $fState      - True to set state, otherwise False
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetItemDisabled
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetItemDisabled($hMenu, $iItem, $fState = True, $fByPos = True)
	Return _GUICtrlMenu_SetItemState($hMenu, $iItem, BitOR($MFS_DISABLED, $MFS_GRAYED), $fState, $fByPos)
EndFunc   ;==>_GUICtrlMenu_SetItemDisabled

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetItemEnabled
; Description ...: Sets the enabled state of a menu item
; Syntax.........: _GUICtrlMenu_SetItemEnabled($hMenu, $iItem[, $fState = True[, $fByPos = True]])
; Parameters ....: $hMenu       - Menu handle
;                  $iItem       - Identifier or position of the menu item
;                  $fState      - Item state to set:
;                  | True - State is enabled
;                  |False - State is disabled
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetItemEnabled
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetItemEnabled($hMenu, $iItem, $fState = True, $fByPos = True)
	Return _GUICtrlMenu_SetItemState($hMenu, $iItem, BitOR($MFS_DISABLED, $MFS_GRAYED), Not $fState, $fByPos)
EndFunc   ;==>_GUICtrlMenu_SetItemEnabled

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetItemGrayed
; Description ...: Sets the grayed state of a menu item
; Syntax.........: _GUICtrlMenu_SetItemGrayed($hMenu, $iItem[, $fState = True[, $fByPos = True]])
; Parameters ....: $hMenu       - Menu handle
;                  $iItem       - Identifier or position of the menu item
;                  $fState      - Item state to set:
;                  | True - State is enabled
;                  |False - State is disabled
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetItemGrayed
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetItemGrayed($hMenu, $iItem, $fState = True, $fByPos = True)
	Return _GUICtrlMenu_SetItemState($hMenu, $iItem, $MFS_GRAYED, $fState, $fByPos)
EndFunc   ;==>_GUICtrlMenu_SetItemGrayed

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetItemHighlighted
; Description ...: Sets the highlighted state of a menu item
; Syntax.........: _GUICtrlMenu_SetItemHighlighted($hMenu, $iItem[, $fState = True[, $fByPos = True]])
; Parameters ....: $hMenu       - Menu handle
;                  $iItem       - Identifier or position of the menu item
;                  $fState      - Item state to set:
;                  | True - State is enabled
;                  |False - State is disabled
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetItemHighlighted
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetItemHighlighted($hMenu, $iItem, $fState = True, $fByPos = True)
	Return _GUICtrlMenu_SetItemState($hMenu, $iItem, $MFS_HILITE, $fState, $fByPos)
EndFunc   ;==>_GUICtrlMenu_SetItemHighlighted

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetItemID
; Description ...: Sets the menu item ID
; Syntax.........: _GUICtrlMenu_SetItemID($hMenu, $iItem, $iID[, $fByPos = True])
; Parameters ....: $hMenu       - Menu handle
;                  $iItem       - Identifier or position of the menu item
;                  $iID         - Menu item ID
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetItemID
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetItemID($hMenu, $iItem, $iID, $fByPos = True)
	Local $tInfo = DllStructCreate($tagMENUITEMINFO)
	DllStructSetData($tInfo, "Size", DllStructGetSize($tInfo))
	DllStructSetData($tInfo, "Mask", $MIIM_ID)
	DllStructSetData($tInfo, "ID", $iID)
	Return _GUICtrlMenu_SetItemInfo($hMenu, $iItem, $tInfo, $fByPos)
EndFunc   ;==>_GUICtrlMenu_SetItemID

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetItemInfo
; Description ...: Changes information about a menu item
; Syntax.........: _GUICtrlMenu_SetItemInfo($hMenu, $iItem, ByRef $tInfo[, $fByPos = True])
; Parameters ....: $hMenu       - Menu handle
;                  $iItem       - Identifier or position of the menu item
;                  $tInfo       - $tagMENUITEMINFO structure
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetItemInfo, $tagMENUITEMINFO
; Link ..........: @@MsdnLink@@ SetMenuItemInfo
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetItemInfo($hMenu, $iItem, ByRef $tInfo, $fByPos = True)
	DllStructSetData($tInfo, "Size", DllStructGetSize($tInfo))
	Local $aResult = DllCall("User32.dll", "bool", "SetMenuItemInfoW", "handle", $hMenu, "uint", $iItem, "bool", $fByPos, "struct*", $tInfo)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_SetItemInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetItemState
; Description ...: Sets the state of a menu item
; Syntax.........: _GUICtrlMenu_SetItemState($hMenu, $iItem, $iState[, $fState = True[, $fByPos = True]])
; Parameters ....: $hMenu       - Menu handle
;                  $iItem       - Identifier or position of the menu item
;                  $iState      - Menu item state:
;                  |$MFS_CHECKED  - Item is checked
;                  |$MFS_DEFAULT  - Item is the default item
;                  |$MFS_DISABLED - Item is disabled
;                  |$MFS_GRAYED   - Item is disabled
;                  |$MFS_HILITE   - Item is highlighted
;                  $fState      - Item state to set:
;                  | True - State is enabled
;                  |False - State is disabled
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetItemState, _GUICtrlMenu_GetItemStateEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetItemState($hMenu, $iItem, $iState, $fState = True, $fByPos = True)
	Local $iFlag = _GUICtrlMenu_GetItemStateEx($hMenu, $iItem, $fByPos)
	If $fState Then
		$iState = BitOR($iFlag, $iState)
	Else
		$iState = BitAND($iFlag, BitNOT($iState))
	EndIf
	Local $tInfo = DllStructCreate($tagMENUITEMINFO)
	DllStructSetData($tInfo, "Size", DllStructGetSize($tInfo))
	DllStructSetData($tInfo, "Mask", $MIIM_STATE)
	DllStructSetData($tInfo, "State", $iState)
	Return _GUICtrlMenu_SetItemInfo($hMenu, $iItem, $tInfo, $fByPos)
EndFunc   ;==>_GUICtrlMenu_SetItemState

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetItemSubMenu
; Description ...: Sets the drop down menu or submenu associated with the menu item
; Syntax.........: _GUICtrlMenu_SetItemSubMenu($hMenu, $iItem, $hSubMenu[, $fByPos = True])
; Parameters ....: $hMenu       - Menu handle
;                  $iItem       - Identifier or position of the menu item
;                  $hSubMenu    - Handle to the drop down menu or submenu
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetItemSubMenu
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetItemSubMenu($hMenu, $iItem, $hSubMenu, $fByPos = True)
	Local $tInfo = DllStructCreate($tagMENUITEMINFO)
	DllStructSetData($tInfo, "Size", DllStructGetSize($tInfo))
	DllStructSetData($tInfo, "Mask", $MIIM_SUBMENU)
	DllStructSetData($tInfo, "SubMenu", $hSubMenu)
	Return _GUICtrlMenu_SetItemInfo($hMenu, $iItem, $tInfo, $fByPos)
EndFunc   ;==>_GUICtrlMenu_SetItemSubMenu

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetItemText
; Description ...: Sets the text for a menu item
; Syntax.........: _GUICtrlMenu_SetItemText($hMenu, $iItem, $sText[, $fByPos = True])
; Parameters ....: $hMenu       - Menu handle
;                  $iItem       - Identifier or position of the menu item
;                  $sText       - Menu item text
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetItemText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetItemText($hMenu, $iItem, $sText, $fByPos = True)
	Local $tBuffer = DllStructCreate("wchar Text[" & StringLen($sText) + 1 & "]")
	DllStructSetData($tBuffer, "Text", $sText)
	Local $tInfo = DllStructCreate($tagMENUITEMINFO)
	DllStructSetData($tInfo, "Size", DllStructGetSize($tInfo))
	DllStructSetData($tInfo, "Mask", $MIIM_STRING)
	DllStructSetData($tInfo, "TypeData", DllStructGetPtr($tBuffer))
	Return _GUICtrlMenu_SetItemInfo($hMenu, $iItem, $tInfo, $fByPos)
EndFunc   ;==>_GUICtrlMenu_SetItemText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetItemType
; Description ...: Sets the menu item type
; Syntax.........: _GUICtrlMenu_SetItemType($hMenu, $iItem, $iType[, $fByPos = True])
; Parameters ....: $hMenu       - Menu handle
;                  $iItem       - Identifier or position of the menu item
;                  $iType       - Menu item type. This can be one or more of the following values:
;                  |$MFT_BITMAP       - Item is displayed using a bitmap
;                  |$MFT_MENUBARBREAK - Item is placed on a new line. A vertical line separates the new column from the old.
;                  |$MFT_MENUBREAK    - Item is placed on a new line. The columns are not separated by a vertical line.
;                  |$MFT_OWNERDRAW    - Item is owner drawn
;                  |$MFT_RADIOCHECK   - Item is displayed using a radio button mark
;                  |$MFT_RIGHTJUSTIFY - Item is right justified
;                  |$MFT_RIGHTORDER   - Item cascades from right to left
;                  |$MFT_SEPARATOR    - Item is a separator
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetItemType
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetItemType($hMenu, $iItem, $iType, $fByPos = True)
	Local $tInfo = DllStructCreate($tagMENUITEMINFO)
	DllStructSetData($tInfo, "Size", DllStructGetSize($tInfo))
	DllStructSetData($tInfo, "Mask", $MIIM_FTYPE)
	DllStructSetData($tInfo, "Type", $iType)
	Return _GUICtrlMenu_SetItemInfo($hMenu, $iItem, $tInfo, $fByPos)
EndFunc   ;==>_GUICtrlMenu_SetItemType

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetMenu
; Description ...: Assigns a new menu to the specified window
; Syntax.........: _GUICtrlMenu_SetMenu($hWnd, $hMenu)
; Parameters ....: $hWnd        - Handle to the window to which the menu is to be assigned
;                  $hMenu       - Handle to the new menu. If 0, the window's current menu is removed.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetMenu
; Link ..........: @@MsdnLink@@ SetMenu
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetMenu($hWnd, $hMenu)
	Local $aResult = DllCall("User32.dll", "bool", "SetMenu", "hwnd", $hWnd, "handle", $hMenu)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_SetMenu

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetMenuBackground
; Description ...: Sets the background brush for the menu
; Syntax.........: _GUICtrlMenu_SetMenuBackground($hMenu, $hBrush)
; Parameters ....: $hMenu       - Handle of the menu
;                  $hBrush      - Brush to use for the background
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetMenuBackground
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetMenuBackground($hMenu, $hBrush)
	Local $tInfo = DllStructCreate($tagMENUINFO)
	DllStructSetData($tInfo, "Mask", $MIM_BACKGROUND)
	DllStructSetData($tInfo, "hBack", $hBrush)
	Return _GUICtrlMenu_SetMenuInfo($hMenu, $tInfo)
EndFunc   ;==>_GUICtrlMenu_SetMenuBackground

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetMenuContextHelpID
; Description ...: Sets the context help identifier for the menu
; Syntax.........: _GUICtrlMenu_SetMenuContextHelpID($hMenu, $iHelpID)
; Parameters ....: $hMenu       - Handle of the menu
;                  $iHelpID     - Context help ID
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetMenuContextHelpID
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetMenuContextHelpID($hMenu, $iHelpID)
	Local $tInfo = DllStructCreate($tagMENUINFO)
	DllStructSetData($tInfo, "Mask", $MIM_HELPID)
	DllStructSetData($tInfo, "ContextHelpID", $iHelpID)
	Return _GUICtrlMenu_SetMenuInfo($hMenu, $tInfo)
EndFunc   ;==>_GUICtrlMenu_SetMenuContextHelpID

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetMenuData
; Description ...: Sets the application defined for the menu
; Syntax.........: _GUICtrlMenu_SetMenuData($hMenu, $iData)
; Parameters ....: $hMenu       - Handle of the menu
;                  $iData       - Application defined data
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetMenuData
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetMenuData($hMenu, $iData)
	Local $tInfo = DllStructCreate($tagMENUINFO)
	DllStructSetData($tInfo, "Mask", $MIM_MENUDATA)
	DllStructSetData($tInfo, "MenuData", $iData)
	Return _GUICtrlMenu_SetMenuInfo($hMenu, $tInfo)
EndFunc   ;==>_GUICtrlMenu_SetMenuData

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetMenuDefaultItem
; Description ...: Sets the default menu item
; Syntax.........: _GUICtrlMenu_SetMenuDefaultItem($hMenu, $iItem[, $fByPos = True])
; Parameters ....: $hMenu       - Menu handle
;                  $iItem       - Identifier or position of the default menu item or -1 for no default item
;                  $fByPos      - Menu identifier flag:
;                  | True - $iItem is a zero based item position
;                  |False - $iItem is a menu item identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetMenuDefaultItem
; Link ..........: @@MsdnLink@@ SetMenuDefaultItem
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetMenuDefaultItem($hMenu, $iItem, $fByPos = True)
	Local $aResult = DllCall("User32.dll", "bool", "SetMenuDefaultItem", "handle", $hMenu, "uint", $iItem, "uint", $fByPos)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_SetMenuDefaultItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetMenuHeight
; Description ...: Sets the maximum height of the menu
; Syntax.........: _GUICtrlMenu_SetMenuHeight($hMenu, $iHeight)
; Parameters ....: $hMenu       - Handle of the menu
;                  $iHeight     - Maximum height of the menu
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetMenuHeight
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetMenuHeight($hMenu, $iHeight)
	Local $tInfo = DllStructCreate($tagMENUINFO)
	DllStructSetData($tInfo, "Mask", $MIM_MAXHEIGHT)
	DllStructSetData($tInfo, "YMax", $iHeight)
	Return _GUICtrlMenu_SetMenuInfo($hMenu, $tInfo)
EndFunc   ;==>_GUICtrlMenu_SetMenuHeight

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetMenuInfo
; Description ...: Sets information for a specified menu
; Syntax.........: _GUICtrlMenu_SetMenuInfo($hMenu, ByRef $tInfo)
; Parameters ....: $hMenu       - Menu handle
;                  $tInfo       - $tagMENUINFO structure
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetMenuInfo, $tagMENUINFO
; Link ..........: @@MsdnLink@@ SetMenuInfo
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetMenuInfo($hMenu, ByRef $tInfo)
	DllStructSetData($tInfo, "Size", DllStructGetSize($tInfo))
	Local $aResult = DllCall("User32.dll", "bool", "SetMenuInfo", "handle", $hMenu, "struct*", $tInfo)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_SetMenuInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_SetMenuStyle
; Description ...: Sets the menu style
; Syntax.........: _GUICtrlMenu_SetMenuStyle($hMenu, $iStyle)
; Parameters ....: $hMenu       - Handle of the menu
;                  $iStyle      - Style of the menu. It can be one or more of the following values:
;                  |$MNS_AUTODISMISS - Menu automatically ends when mouse is outside the menu for 10 seconds
;                  |$MNS_CHECKORBMP  - The same space is reserved for the check mark and the bitmap
;                  |$MNS_DRAGDROP    - Menu items are OLE drop targets or drag sources
;                  |$MNS_MODELESS    - Menu is modeless
;                  |$MNS_NOCHECK     - No space is reserved to the left of an item for a check mark
;                  |$MNS_NOTIFYBYPOS - Menu owner receives a $WM_MENUCOMMAND message instead of  a  $WM_COMMAND  message  when  a
;                  +selection is made
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMenu_GetMenuStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_SetMenuStyle($hMenu, $iStyle)
	Local $tInfo = DllStructCreate($tagMENUINFO)
	DllStructSetData($tInfo, "Mask", $MIM_STYLE)
	DllStructSetData($tInfo, "Style", $iStyle)
	Return _GUICtrlMenu_SetMenuInfo($hMenu, $tInfo)
EndFunc   ;==>_GUICtrlMenu_SetMenuStyle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMenu_TrackPopupMenu
; Description ...: Displays a shortcut menu at the specified location
; Syntax.........: _GUICtrlMenu_TrackPopupMenu($hMenu, $hWnd[, $iX = -1[, $iY = -1[, $iAlignX = 1[, $iAlignY = 1[, $iNotify = 0[, $iButtons = 0]]]]]])
; Parameters ....: $hMenu       - Handle to the shortcut menu to be displayed
;                  $hWnd        - Handle to the window that owns the shortcut menu
;                  $iX          - Specifies the horizontal location of the shortcut menu, in screen coordinates.  If this is  -1,
;                  +the current mouse position is used.
;                  $iY          - Specifies the vertical location of the shortcut menu, in screen coordinates. If this is -1, the
;                  +current mouse position is used.
;                  $iAlignX     - Specifies how to position the menu horizontally:
;                  |0 - Center the menu horizontally relative to $iX
;                  |1 - Position the menu so that its left side is aligned with $iX
;                  |2 - Position the menu so that its right side is aligned with $iX
;                  $iAlignY     - Specifies how to position the menu vertically:
;                  |0 - Position the menu so that its bottom side is aligned with $iY
;                  |1 - Position the menu so that its top side is aligned with $iY
;                  |2 - Center the menu vertically relative to $iY
;                  $iNotify     - Use to determine the selection withouta parent window:
;                  |1 - Do not send notification messages
;                  |2 - Return the menu item identifier of the user's selection
;                  $iButtons    - Mouse button the shortcut menu tracks:
;                  |0 - The user can select items with only the left mouse button
;                  |1 - The user can select items with both left and right buttons
; Return values .: Success      - If $iNotify is set to 2, the return value is the menu item identifier  of  the  item  that  the
;                  +user selected. If the user cancels the menu without making a selection or if an error occurs, then the return
;                  +value is zero. If $iNotify is not set to 2, the return value is 1.
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ TrackPopupMenu
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMenu_TrackPopupMenu($hMenu, $hWnd, $iX = -1, $iY = -1, $iAlignX = 1, $iAlignY = 1, $iNotify = 0, $iButtons = 0)
	If $iX = -1 Then $iX = _WinAPI_GetMousePosX()
	If $iY = -1 Then $iY = _WinAPI_GetMousePosY()

	Local $iFlags = 0
	Switch $iAlignX
		Case 1
			$iFlags = BitOR($iFlags, $TPM_LEFTALIGN)
		Case 2
			$iFlags = BitOR($iFlags, $TPM_RIGHTALIGN)
		Case Else
			$iFlags = BitOR($iFlags, $TPM_CENTERALIGN)
	EndSwitch
	Switch $iAlignY
		Case 1
			$iFlags = BitOR($iFlags, $TPM_TOPALIGN)
		Case 2
			$iFlags = BitOR($iFlags, $TPM_VCENTERALIGN)
		Case Else
			$iFlags = BitOR($iFlags, $TPM_BOTTOMALIGN)
	EndSwitch
	If BitAND($iNotify, 1) <> 0 Then $iFlags = BitOR($iFlags, $TPM_NONOTIFY)
	If BitAND($iNotify, 2) <> 0 Then $iFlags = BitOR($iFlags, $TPM_RETURNCMD)
	Switch $iButtons
		Case 1
			$iFlags = BitOR($iFlags, $TPM_RIGHTBUTTON)
		Case Else
			$iFlags = BitOR($iFlags, $TPM_LEFTBUTTON)
	EndSwitch
	Local $aResult = DllCall("User32.dll", "bool", "TrackPopupMenu", "handle", $hMenu, "uint", $iFlags, "int", $iX, "int", $iY, "int", 0, "hwnd", $hWnd, "ptr", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_GUICtrlMenu_TrackPopupMenu
