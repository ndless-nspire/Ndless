#include-once

#include "ListBoxConstants.au3"
#include "DirConstants.au3"
#include "GuiConstantsEx.au3"
#include "Memory.au3"
#include "WinAPI.au3"
#include "SendMessage.au3"
#include "UDFGlobalID.au3"

; #INDEX# =======================================================================================================================
; Title .........: ListBox
; AutoIt Version : 3.3.7.20++
; Language ......: English
; Description ...: Functions that assist with ListBox control management.
; Author(s) .....: Paul Campbell (PaulIA)
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $_lb_ghLastWnd
Global $Debug_LB = False
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__LISTBOXCONSTANT_ClassName = "ListBox"
Global Const $__LISTBOXCONSTANT_ClassNames = $__LISTBOXCONSTANT_ClassName & "|TListbox"
Global Const $__LISTBOXCONSTANT_WS_TABSTOP = 0x00010000
Global Const $__LISTBOXCONSTANT_DEFAULT_GUI_FONT = 17
Global Const $__LISTBOXCONSTANT_WM_SETREDRAW = 0x000B
Global Const $__LISTBOXCONSTANT_WM_GETFONT = 0x0031
; ===============================================================================================================================

; #OLD_FUNCTIONS#================================================================================================================
; Old Function/Name                      ; --> New Function/Name/Replacement(s)
;
; deprecated functions will no longer work
;_GUICtrlListAddDir                       ; --> _GUICtrlListBox_Dir
;_GUICtrlListAddItem                      ; --> _GUICtrlListBox_AddString
;_GUICtrlListClear                        ; --> _GUICtrlListBox_ResetContent
;_GUICtrlListCount                        ; --> _GUICtrlListBox_GetCount
;_GUICtrlListDeleteItem                   ; --> _GUICtrlListBox_DeleteString
;_GUICtrlListFindString                   ; --> _GUICtrlListBox_FindString
;_GUICtrlListGetAnchorIndex               ; --> _GUICtrlListBox_GetAnchorIndex
;_GUICtrlListGetCaretIndex                ; --> _GUICtrlListBox_GetCaretIndex
;_GUICtrlListGetHorizontalExtent          ; --> _GUICtrlListBox_GetHorizontalExtent
;_GUICtrlListGetInfo                      ; --> _GUICtrlListBox_GetListBoxInfo
;_GUICtrlListBoxGetItemRect               ; --> _GUICtrlListBox_GetItemRect
;_GUICtrlListGetLocale                    ; --> _GUICtrlListBox_GetLocale
;_GUICtrlListGetSelCount                  ; --> _GUICtrlListBox_GetSelCount
;_GUICtrlListGetSelItems                  ; --> _GUICtrlListBox_GetSelItems
;_GUICtrlListGetSelItemsText              ; --> _GUICtrlListBox_GetSelItemsText
;_GUICtrlListGetSelState                  ; --> _GUICtrlListBox_GetSel
;_GUICtrlListGetText                      ; --> _GUICtrlListBox_GetText
;_GUICtrlListGetTextLen                   ; --> _GUICtrlListBox_GetTextLen
;_GUICtrlListGetTopIndex                  ; --> _GUICtrlListBox_GetTopIndex
;_GUICtrlListInsertItem                   ; --> _GUICtrlListBox_InsertString
;_GUICtrlListReplaceString                ; --> _GUICtrlListBox_ReplaceString
;_GUICtrlListSelectedIndex                ; --> _GUICtrlListBox_GetCurSel
;_GUICtrlListSelectIndex                  ; --> _GUICtrlListBox_SetCurSel
;_GUICtrlListSelectString                 ; --> _GUICtrlListBox_SelectString
;_GUICtrlListSelItemRange                 ; --> _GUICtrlListBox_SelItemRange
;_GUICtrlListSelItemRangeEx               ; --> _GUICtrlListBox_SelItemRangeEx
;_GUICtrlListSetAnchorIndex               ; --> _GUICtrlListBox_SetAnchorIndex
;_GUICtrlListSetCaretIndex                ; --> _GUICtrlListBox_SetCaretIndex
;_GUICtrlListSetHorizontalExtent          ; --> _GUICtrlListBox_SetHorizontalExtent
;_GUICtrlListSetLocale                    ; --> _GUICtrlListBox_SetLocale
;_GUICtrlListSetSel                       ; --> _GUICtrlListBox_SetSel
;_GUICtrlListSetTopIndex                  ; --> _GUICtrlListBox_SetTopIndex
;_GUICtrlListSort                         ; --> _GUICtrlListBox_Sort
;_GUICtrlListSwapString                   ; --> _GUICtrlListBox_SwapString
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_GUICtrlListBox_AddFile
;_GUICtrlListBox_AddString
;_GUICtrlListBox_BeginUpdate
;_GUICtrlListBox_ClickItem
;_GUICtrlListBox_Create
;_GUICtrlListBox_DeleteString
;_GUICtrlListBox_Destroy
;_GUICtrlListBox_Dir
;_GUICtrlListBox_EndUpdate
;_GUICtrlListBox_FindString
;_GUICtrlListBox_FindInText
;_GUICtrlListBox_GetAnchorIndex
;_GUICtrlListBox_GetCaretIndex
;_GUICtrlListBox_GetCount
;_GUICtrlListBox_GetCurSel
;_GUICtrlListBox_GetHorizontalExtent
;_GUICtrlListBox_GetItemData
;_GUICtrlListBox_GetItemHeight
;_GUICtrlListBox_GetItemRect
;_GUICtrlListBox_GetItemRectEx
;_GUICtrlListBox_GetListBoxInfo
;_GUICtrlListBox_GetLocale
;_GUICtrlListBox_GetLocaleCountry
;_GUICtrlListBox_GetLocaleLang
;_GUICtrlListBox_GetLocalePrimLang
;_GUICtrlListBox_GetLocaleSubLang
;_GUICtrlListBox_GetSel
;_GUICtrlListBox_GetSelCount
;_GUICtrlListBox_GetSelItems
;_GUICtrlListBox_GetSelItemsText
;_GUICtrlListBox_GetText
;_GUICtrlListBox_GetTextLen
;_GUICtrlListBox_GetTopIndex
;_GUICtrlListBox_InitStorage
;_GUICtrlListBox_InsertString
;_GUICtrlListBox_ItemFromPoint
;_GUICtrlListBox_ReplaceString
;_GUICtrlListBox_ResetContent
;_GUICtrlListBox_SelectString
;_GUICtrlListBox_SelItemRange
;_GUICtrlListBox_SelItemRangeEx
;_GUICtrlListBox_SetAnchorIndex
;_GUICtrlListBox_SetCaretIndex
;_GUICtrlListBox_SetColumnWidth
;_GUICtrlListBox_SetCurSel
;_GUICtrlListBox_SetHorizontalExtent
;_GUICtrlListBox_SetItemData
;_GUICtrlListBox_SetItemHeight
;_GUICtrlListBox_SetLocale
;_GUICtrlListBox_SetSel
;_GUICtrlListBox_SetTabStops
;_GUICtrlListBox_SetTopIndex
;_GUICtrlListBox_Sort
;_GUICtrlListBox_SwapString
;_GUICtrlListBox_UpdateHScroll
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_AddFile
; Description ...: Adds the specified filename that contains a directory listing
; Syntax.........: _GUICtrlListBox_AddFile($hWnd, $sFile)
; Parameters ....: $hWnd        - Handle to control
;                  $sFile       - Name of the file to add
; Return values .: Success      - Zero based index of the file that was added
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListBox_AddString, _GUICtrlListBox_DeleteString, _GUICtrlListBox_InitStorage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_AddFile($hWnd, $sFile)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_ADDFILE, 0, $sFile, 0, "wparam", "wstr")
	Else
		Return GUICtrlSendMsg($hWnd, $LB_ADDFILE, 0, $sFile)
	EndIf
EndFunc   ;==>_GUICtrlListBox_AddFile

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_AddString
; Description ...: Add a string
; Syntax.........: _GUICtrlListBox_AddString($hWnd, $sText)
; Parameters ....: $hWnd        - Handle to control
;                  $sText       - String that is to be added
; Return values .: Success      - Zero based index of string
;                  Failure      - -1
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: If there is insufficient space to store the new string, the return value is $LB_ERRSPACE.
;+
;                  If the list box does not have the $LBS_SORT style, the string is added to the end of the list.
;                  Otherwise, the string is inserted into the list and the list is sorted.
; Related .......: _GUICtrlListBox_InsertString, _GUICtrlListBox_DeleteString, _GUICtrlListBox_AddFile, _GUICtrlListBox_InitStorage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_AddString($hWnd, $sText)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_ADDSTRING, 0, $sText, 0, "wparam", "wstr")
	Else
		Return GUICtrlSendMsg($hWnd, $LB_ADDSTRING, 0, $sText)
	EndIf
EndFunc   ;==>_GUICtrlListBox_AddString

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_BeginUpdate
; Description ...: Prevents updating of the control until the EndUpdate function is called
; Syntax.........: _GUICtrlListBox_BeginUpdate($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListBox_EndUpdate
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_BeginUpdate($hWnd)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $__LISTBOXCONSTANT_WM_SETREDRAW) = 0
EndFunc   ;==>_GUICtrlListBox_BeginUpdate

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_ClickItem
; Description ...: Clicks an item
; Syntax.........: _GUICtrlListBox_ClickItem($hWnd, $iIndex[, $sButton = "left"[, $fMove = False[, $iClicks = 1[, $iSpeed = 0]]]])
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Specifies the zero based index of the item
;                  $sButton     - Button to click with
;                  $fMove       - If True, the mouse will be moved. If False, the mouse does not move.
;                  $iClicks     - Number of clicks
;                  $iSpeed      - Mouse movement speed
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_ClickItem($hWnd, $iIndex, $sButton = "left", $fMove = False, $iClicks = 1, $iSpeed = 0)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tRect = _GUICtrlListBox_GetItemRectEx($hWnd, $iIndex)
	Local $tPoint = _WinAPI_PointFromRect($tRect)
	$tPoint = _WinAPI_ClientToScreen($hWnd, $tPoint)
	Local $iX, $iY
	_WinAPI_GetXYFromPoint($tPoint, $iX, $iY)
	Local $iMode = Opt("MouseCoordMode", 1)
	If Not $fMove Then
		Local $aPos = MouseGetPos()
		_WinAPI_ShowCursor(False)
		MouseClick($sButton, $iX, $iY, $iClicks, $iSpeed)
		MouseMove($aPos[0], $aPos[1], 0)
		_WinAPI_ShowCursor(True)
	Else
		MouseClick($sButton, $iX, $iY, $iClicks, $iSpeed)
	EndIf
	Opt("MouseCoordMode", $iMode)
EndFunc   ;==>_GUICtrlListBox_ClickItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_Create
; Description ...: Create a Listbox control
; Syntax.........: _GUICtrlListBox_Create($hWnd, $sText, $iX, $iY[, $iWidth = 100[, $iHeight = 200[, $iStyle = 0x00B00002[, $iExStyle = 0x00000200]]]])
; Parameters ....: $hWnd        - Handle to parent or owner window
;                  $sText       - String to add to the combobox
;                  $iX          - Horizontal position of the control
;                  $iY          - Vertical position of the control
;                  $iWidth      - Control width
;                  $iHeight     - Control height
;                  $iStyle      - Control style:
;                  |$LBS_COMBOBOX          - Notifies a list box that it is part of a combo box
;                  |$LBS_DISABLENOSCROLL   - Shows a disabled vertical scroll bar
;                  |$LBS_EXTENDEDSEL       - Allows multiple items to be selected
;                  |$LBS_HASSTRINGS        - Specifies that a list box contains items consisting of strings
;                  |$LBS_MULTICOLUMN       - Specifies a multi columnn list box that will be scrolled horizontally
;                  |$LBS_MULTIPLESEL       - Turns string selection on or off each time the user clicks a string
;                  |$LBS_NODATA            - Specifies a no-data list box
;                  |$LBS_NOINTEGRALHEIGHT  - Specifies that the size is exactly the size set by the application
;                  |$LBS_NOREDRAW          - Specifies that the list box's appearance is not updated when changes are made
;                  |$LBS_NOSEL             - Specifies that the list box contains items that can be viewed but not selected
;                  |$LBS_NOTIFY            - Notifies whenever the user clicks or double clicks a string
;                  |$LBS_OWNERDRAWFIXED    - Specifies that the list box is owner drawn
;                  |$LBS_OWNERDRAWVARIABLE - Specifies that the list box is owner drawn with variable height
;                  |$LBS_SORT              - Sorts strings in the list box alphabetically
;                  |$LBS_STANDARD          - Standard list box style
;                  |$LBS_USETABSTOPS       - Enables a list box to recognize and expand tab characters
;                  |$LBS_WANTKEYBOARDINPUT - Specifies that the owner receives WM_VKEYTOITEM messages
;                  -
;                  |Default: $LBS_SORT, $WS_HSCROLL, $WS_VSCROLL, $WS_BORDER
;                  |Forced : $WS_CHILD, $WS_TABSTOP, $WS_VISIBLE, $LBS_NOTIFY
;                  -
;                  $iExStyle    - Control extended style. These correspond to the standard $WS_EX_ constants.
;                  -
;                  |Default: $WS_EX_CLIENTEDGE
; Return values .: Success      - Handle to the Listbox control
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......: This function is for Advanced users and for learning how the control works.
; Related .......: _GUICtrlListBox_Destroy
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_Create($hWnd, $sText, $iX, $iY, $iWidth = 100, $iHeight = 200, $iStyle = 0x00B00002, $iExStyle = 0x00000200)
	If Not IsHWnd($hWnd) Then
		; Invalid Window handle for _GUICtrlListBox_Create 1st parameter
		Return SetError(1, 0, 0)
	EndIf
	If Not IsString($sText) Then
		; 2nd parameter not a string for _GUICtrlListBox_Create
		Return SetError(2, 0, 0)
	EndIf

	If $iWidth = -1 Then $iWidth = 100
	If $iHeight = -1 Then $iHeight = 200
	Local Const $WS_VSCROLL = 0x00200000, $WS_HSCROLL = 0x00100000, $WS_BORDER = 0x00800000
	If $iStyle = -1 Then $iStyle = BitOR($WS_BORDER, $WS_VSCROLL, $WS_HSCROLL, $LBS_SORT)
	If $iExStyle = -1 Then $iExStyle = 0x00000200

	$iStyle = BitOR($iStyle, $__UDFGUICONSTANT_WS_VISIBLE, $__LISTBOXCONSTANT_WS_TABSTOP, $__UDFGUICONSTANT_WS_CHILD, $LBS_NOTIFY)

	Local $nCtrlID = __UDF_GetNextGlobalID($hWnd)
	If @error Then Return SetError(@error, @extended, 0)

	Local $hList = _WinAPI_CreateWindowEx($iExStyle, $__LISTBOXCONSTANT_ClassName, "", $iStyle, $iX, $iY, $iWidth, $iHeight, $hWnd, $nCtrlID)
	_WinAPI_SetFont($hList, _WinAPI_GetStockObject($__LISTBOXCONSTANT_DEFAULT_GUI_FONT))
	If StringLen($sText) Then _GUICtrlListBox_AddString($hList, $sText)
	Return $hList
EndFunc   ;==>_GUICtrlListBox_Create

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_DeleteString
; Description ...: Delete a string
; Syntax.........: _GUICtrlListBox_DeleteString($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero-based index of the string to be deleted
; Return values .: Success      - Count of strings remaining
;                  Failure      - -1
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListBox_AddString, _GUICtrlListBox_InsertString, _GUICtrlListBox_AddFile, _GUICtrlListBox_ResetContent
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_DeleteString($hWnd, $iIndex)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_DELETESTRING, $iIndex)
	Else
		Return GUICtrlSendMsg($hWnd, $LB_DELETESTRING, $iIndex, 0)
	EndIf
EndFunc   ;==>_GUICtrlListBox_DeleteString

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_Destroy
; Description ...: Delete the control
; Syntax.........: _GUICtrlListBox_Destroy(ByRef $hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True, Handle is set to 0
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Restricted to only be used on Listbox created with _GUICtrlListBox_Create
; Related .......: _GUICtrlListBox_Create
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_Destroy(ByRef $hWnd)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
;~ 	If Not _WinAPI_IsClassName($hWnd, $__LISTBOXCONSTANT_ClassNames) Then Return SetError(2, 2, False)

	Local $Destroyed = 0
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lb_ghLastWnd) Then
			Local $nCtrlID = _WinAPI_GetDlgCtrlID($hWnd)
			Local $hParent = _WinAPI_GetParent($hWnd)
			$Destroyed = _WinAPI_DestroyWindow($hWnd)
			Local $iRet = __UDF_FreeGlobalID($hParent, $nCtrlID)
			If Not $iRet Then
				; can check for errors here if needed, for debug
			EndIf
		Else
			; Not Allowed to Destroy Other Applications Control(s)
			Return SetError(1, 1, False)
		EndIf
	Else
		$Destroyed = GUICtrlDelete($hWnd)
	EndIf
	If $Destroyed Then $hWnd = 0
	Return $Destroyed <> 0
EndFunc   ;==>_GUICtrlListBox_Destroy

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_Dir
; Description ...: Adds the names of directories and files
; Syntax.........: _GUICtrlListBox_Dir($hWnd, $sFile[, $iAttributes = 0[, $fBrackets = True]])
; Parameters ....: $hWnd        - Handle to control
;                  $sFile       - Specifies an absolute path, relative path, or filename
;                  $iAttributes - Specifies the attributes of the files or directories to be added:
;                  |$DDL_READWRITE - Includes read-write files with no additional attributes
;                  |$DDL_READONLY  - Includes read-only files
;                  |$DDL_HIDDEN    - Includes hidden files
;                  |$DDL_SYSTEM    - Includes system files
;                  |$DDL_DIRECTORY - Includes subdirectories
;                  |$DDL_ARCHIVE   - Includes archived files
;                  |$DDL_DRIVES    - All mapped drives are added to the list
;                  |$DDL_EXCLUSIVE - Includes only files with the specified attributes
;                  $fBrackets      - include/exclude brackets when $DDL_DRIVES is used
; Return values .: Success      - Zero based index of the last name added
;                  Failure      - -1
; Author ........: Gary Frost (gafrost), CyberSlug
; Modified.......:
; Remarks .......: If there is insufficient space to store the new strings, the return value is $LB_ERRSPACE
; Related .......: _GUICtrlListBox_InitStorage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_Dir($hWnd, $sFile, $iAttributes = 0, $fBrackets = True)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)

	If BitAND($iAttributes, $DDL_DRIVES) = $DDL_DRIVES And Not $fBrackets Then
		Local $sText
		Local $gui_no_brackets = GUICreate("no brackets")
		Local $list_no_brackets = GUICtrlCreateList("", 240, 40, 120, 120)
		Local $v_ret = GUICtrlSendMsg($list_no_brackets, $LB_DIR, $iAttributes, $sFile)
		For $i = 0 To _GUICtrlListBox_GetCount($list_no_brackets) - 1
			$sText = _GUICtrlListBox_GetText($list_no_brackets, $i)
			$sText = StringReplace(StringReplace(StringReplace($sText, "[", ""), "]", ":"), "-", "")
			_GUICtrlListBox_InsertString($hWnd, $sText)
		Next
		GUIDelete($gui_no_brackets)
		Return $v_ret
	Else
		If IsHWnd($hWnd) Then
			Return _SendMessage($hWnd, $LB_DIR, $iAttributes, $sFile, 0, "wparam", "wstr")
		Else
			Return GUICtrlSendMsg($hWnd, $LB_DIR, $iAttributes, $sFile)
		EndIf
	EndIf
EndFunc   ;==>_GUICtrlListBox_Dir

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_EndUpdate
; Description ...: Enables screen repainting that was turned off with the BeginUpdate function
; Syntax.........: _GUICtrlListBox_EndUpdate($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListBox_BeginUpdate
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_EndUpdate($hWnd)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $__LISTBOXCONSTANT_WM_SETREDRAW, 1, 0) = 0
EndFunc   ;==>_GUICtrlListBox_EndUpdate

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_FindString
; Description ...: Search for a string
; Syntax.........: _GUICtrlListBox_FindString($hWnd, $sText[, $fExact = False])
; Parameters ....: $hWnd        - Handle to control
;                  $sText       - String to search for
;                  $fExact      - Exact match or not
; Return values .: Success      - The zero based index of the item
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Find the first string in a list box that begins with the specified string.
;+
;                  If exact is specified find the first list box string that exactly matches the specified string,
;                  except that the search is not case sensitive
; Related .......: _GUICtrlListBox_FindInText, _GUICtrlListBox_SelectString
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_FindString($hWnd, $sText, $fExact = False)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)

	If IsHWnd($hWnd) Then
		If ($fExact) Then
			Return _SendMessage($hWnd, $LB_FINDSTRINGEXACT, -1, $sText, 0, "wparam", "wstr")
		Else
			Return _SendMessage($hWnd, $LB_FINDSTRING, -1, $sText, 0, "wparam", "wstr")
		EndIf
	Else
		If ($fExact) Then
			Return GUICtrlSendMsg($hWnd, $LB_FINDSTRINGEXACT, -1, $sText)
		Else
			Return GUICtrlSendMsg($hWnd, $LB_FINDSTRING, -1, $sText)
		EndIf
	EndIf
EndFunc   ;==>_GUICtrlListBox_FindString

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_FindInText
; Description ...: Searches for an item that contains the specified text anywhere in its text
; Syntax.........: _GUICtrlListBox_FindInText($hWnd, $sText[, $iStart = -1[, $fWrapOK = True]])
; Parameters ....: $hWnd        - Handle to the control
;                  $sText       - Text to match
;                  $iStart      - Zero based index of the item to begin the search with or -1 to start from  the  beginning.  The
;                  +specified item is itself excluded from the search.
;                  $fWrapOK     - If True, the search will continue with the first item if no match is found
; Return values .: Success      - The zero based index of the item
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The search is case insensitive
; Related .......: _GUICtrlListBox_FindString, _GUICtrlListBox_SelectString
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_FindInText($hWnd, $sText, $iStart = -1, $fWrapOK = True)
	Local $sList

	Local $iCount = _GUICtrlListBox_GetCount($hWnd)
	For $iI = $iStart + 1 To $iCount - 1
		$sList = _GUICtrlListBox_GetText($hWnd, $iI)
		If StringInStr($sList, $sText) Then Return $iI
	Next

	If ($iStart = -1) Or Not $fWrapOK Then Return -1
	For $iI = 0 To $iStart - 1
		$sList = _GUICtrlListBox_GetText($hWnd, $iI)
		If StringInStr($sList, $sText) Then Return $iI
	Next

	Return -1
EndFunc   ;==>_GUICtrlListBox_FindInText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_GetAnchorIndex
; Description ...: Retrieves the index of the anchor item
; Syntax.........: _GUICtrlListBox_GetAnchorIndex($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - The zero based index of the item
; Author ........: CyberSlug
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListBox_SetAnchorIndex
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_GetAnchorIndex($hWnd)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_GETANCHORINDEX)
	Else
		Return GUICtrlSendMsg($hWnd, $LB_GETANCHORINDEX, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListBox_GetAnchorIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_GetCaretIndex
; Description ...: Return index of item that has the focus rectangle
; Syntax.........: _GUICtrlListBox_GetCaretIndex($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - Zero based index of the selected item
;                  Failure      - -1 if nothing is selected
; Author ........: CyberSlug
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListBox_SetCaretIndex
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_GetCaretIndex($hWnd)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_GETCARETINDEX)
	Else
		Return GUICtrlSendMsg($hWnd, $LB_GETCARETINDEX, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListBox_GetCaretIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_GetCount
; Description ...: Retrieves the number of items
; Syntax.........: _GUICtrlListBox_GetCount($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - The number of items in the list box
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_GetCount($hWnd)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_GETCOUNT)
	Else
		Return GUICtrlSendMsg($hWnd, $LB_GETCOUNT, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListBox_GetCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_GetCurSel
; Description ...: Retrieve the index of the currently selected item
; Syntax.........: _GUICtrlListBox_GetCurSel($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - Zero based index of the currently selected item
;                  Failure      - -1 if there is no selection
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Do not use this with a multiple-selection list box.
; Related .......: _GUICtrlListBox_SetCurSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_GetCurSel($hWnd)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_GETCURSEL)
	Else
		Return GUICtrlSendMsg($hWnd, $LB_GETCURSEL, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListBox_GetCurSel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_GetHorizontalExtent
; Description ...: Retrieve from a list box the the scrollable width
; Syntax.........: _GUICtrlListBox_GetHorizontalExtent($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - Scrollable width, in pixels, of the list box
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The list box must have been defined with the $WS_HSCROLL style.
; Related .......: _GUICtrlListBox_SetHorizontalExtent
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_GetHorizontalExtent($hWnd)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_GETHORIZONTALEXTENT)
	Else
		Return GUICtrlSendMsg($hWnd, $LB_GETHORIZONTALEXTENT, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListBox_GetHorizontalExtent

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_GetItemData
; Description ...: Retrieves the application defined value associated with an item
; Syntax.........: _GUICtrlListBox_GetItemData($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Specifies the zero based index of the item
; Return values .: Success      - Application defined value
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListBox_SetItemData
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_GetItemData($hWnd, $iIndex)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_GETITEMDATA, $iIndex)
	Else
		Return GUICtrlSendMsg($hWnd, $LB_GETITEMDATA, $iIndex, 0)
	EndIf
EndFunc   ;==>_GUICtrlListBox_GetItemData

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_GetItemHeight
; Description ...: Retrieves the height of items
; Syntax.........: _GUICtrlListBox_GetItemHeight($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - The height, in pixels, of each item in the list box
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListBox_SetItemHeight
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_GetItemHeight($hWnd)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_GETITEMHEIGHT)
	Else
		Return GUICtrlSendMsg($hWnd, $LB_GETITEMHEIGHT, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListBox_GetItemHeight

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_GetItemRect
; Description ...: Retrieves the rectangle that bounds an item
; Syntax.........: _GUICtrlListBox_GetItemRect($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Specifies the zero based index of the item
; Return values .: Success      - Array with the following format:
;                  |[0] - X coordinate of the upper left corner of the rectangle
;                  |[1] - Y coordinate of the upper left corner of the rectangle
;                  |[2] - X coordinate of the lower right corner of the rectangle
;                  |[3] - Y coordinate of the lower right corner of the rectangle
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListBox_GetItemRectEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_GetItemRect($hWnd, $iIndex)
	Local $aRect[4]

	Local $tRect = _GUICtrlListBox_GetItemRectEx($hWnd, $iIndex)
	$aRect[0] = DllStructGetData($tRect, "Left")
	$aRect[1] = DllStructGetData($tRect, "Top")
	$aRect[2] = DllStructGetData($tRect, "Right")
	$aRect[3] = DllStructGetData($tRect, "Bottom")
	Return $aRect
EndFunc   ;==>_GUICtrlListBox_GetItemRect

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_GetItemRectEx
; Description ...: Retrieves the rectangle that bounds an item
; Syntax.........: _GUICtrlListBox_GetItemRectEx($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Specifies the zero based index of the item
; Return values .: Success      - $tagRECT structure that receives the client coordinates for the item
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListBox_GetItemRect, $tagRECT
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_GetItemRectEx($hWnd, $iIndex)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	Local $tRect = DllStructCreate($tagRECT)
	If IsHWnd($hWnd) Then
		_SendMessage($hWnd, $LB_GETITEMRECT, $iIndex, $tRect, 0, "wparam", "struct*")
	Else
		GUICtrlSendMsg($hWnd, $LB_GETITEMRECT, $iIndex, DllStructGetPtr($tRect))
	EndIf
	Return $tRect
EndFunc   ;==>_GUICtrlListBox_GetItemRectEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_GetListBoxInfo
; Description ...: Retrieve the number of items per column in a specified list box
; Syntax.........: _GUICtrlListBox_GetListBoxInfo($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - The number of items per column
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Minimum operating systems Windows XP.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_GetListBoxInfo($hWnd)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_GETLISTBOXINFO)
	Else
		Return GUICtrlSendMsg($hWnd, $LB_GETLISTBOXINFO, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListBox_GetListBoxInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_GetLocale
; Description ...: Retrieves the current locale
; Syntax.........: _GUICtrlListBox_GetLocale($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - The high order word contains the country code and the low order word contains the language identifier.
; Author ........: CyberSlug
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListBox_GetLocaleCountry, _GUICtrlListBox_GetLocaleLang, _GUICtrlListBox_GetLocalePrimLang, _GUICtrlListBox_GetLocaleSubLang, _GUICtrlListBox_SetLocale
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_GetLocale($hWnd)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_GETLOCALE)
	Else
		Return GUICtrlSendMsg($hWnd, $LB_GETLOCALE, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListBox_GetLocale

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_GetLocaleCountry
; Description ...: Retrieves the current country code
; Syntax.........: _GUICtrlListBox_GetLocaleCountry($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - The country code of the list box
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListBox_GetLocale
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_GetLocaleCountry($hWnd)
	Return _WinAPI_HiWord(_GUICtrlListBox_GetLocale($hWnd))
EndFunc   ;==>_GUICtrlListBox_GetLocaleCountry

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_GetLocaleLang
; Description ...: Retrieves the current language identifier
; Syntax.........: _GUICtrlListBox_GetLocaleLang($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - The language identifier of the list box
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListBox_GetLocale
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_GetLocaleLang($hWnd)
	Return _WinAPI_LoWord(_GUICtrlListBox_GetLocale($hWnd))
EndFunc   ;==>_GUICtrlListBox_GetLocaleLang

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_GetLocalePrimLang
; Description ...: Extract primary language id from a language id
; Syntax.........: _GUICtrlListBox_GetLocalePrimLang($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - Primary language id
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListBox_GetLocale
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_GetLocalePrimLang($hWnd)
	Return _WinAPI_PrimaryLangId(_GUICtrlListBox_GetLocaleLang($hWnd))
EndFunc   ;==>_GUICtrlListBox_GetLocalePrimLang

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_GetLocaleSubLang
; Description ...: Extract sublanguage id from a language id
; Syntax.........: _GUICtrlListBox_GetLocaleSubLang($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - Sub-Language id
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListBox_GetLocale
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_GetLocaleSubLang($hWnd)
	Return _WinAPI_SubLangId(_GUICtrlListBox_GetLocaleLang($hWnd))
EndFunc   ;==>_GUICtrlListBox_GetLocaleSubLang

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_GetSel
; Description ...: Retrieves the selection state of an item
; Syntax.........: _GUICtrlListBox_GetSel($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Specifies the zero-based index of the item
; Return values .: True         - Item is selected
;                  False        - Item is not selected
; Author ........: CyberSlug
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListBox_SetSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_GetSel($hWnd, $iIndex)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_GETSEL, $iIndex) <> 0
	Else
		Return GUICtrlSendMsg($hWnd, $LB_GETSEL, $iIndex, 0) <> 0
	EndIf
EndFunc   ;==>_GUICtrlListBox_GetSel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_GetSelCount
; Description ...: Retrieves the total number of selected items
; Syntax.........: _GUICtrlListBox_GetSelCount($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - Count of selected items
;                  Failure      - -1 if no items are selected
; Author ........: CyberSlug
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_GetSelCount($hWnd)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_GETSELCOUNT)
	Else
		Return GUICtrlSendMsg($hWnd, $LB_GETSELCOUNT, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListBox_GetSelCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_GetSelItems
; Description ...: Fills a buffer with an array of selected items
; Syntax.........: _GUICtrlListBox_GetSelItems($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - Array with the following format:
;                  |[0] - Total items in array
;                  |[1] - Index of the selected item
;                  |[2] - Index of the selected item
;                  |[n] - Index of the selected item
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListBox_GetSelItemsText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_GetSelItems($hWnd)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	Local $aArray[1] = [0]

	Local $iCount = _GUICtrlListBox_GetSelCount($hWnd)
	If $iCount > 0 Then
		ReDim $aArray[$iCount + 1]
		Local $tArray = DllStructCreate("int[" & $iCount & "]")
		If IsHWnd($hWnd) Then
			_SendMessage($hWnd, $LB_GETSELITEMS, $iCount, $tArray, 0, "wparam", "struct*")
		Else
			GUICtrlSendMsg($hWnd, $LB_GETSELITEMS, $iCount, DllStructGetPtr($tArray))
		EndIf
		$aArray[0] = $iCount
		For $iI = 1 To $iCount
			$aArray[$iI] = DllStructGetData($tArray, 1, $iI)
		Next
	EndIf
	Return $aArray
EndFunc   ;==>_GUICtrlListBox_GetSelItems

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_GetSelItemsText
; Description ...: Retrieves the text of selected items
; Syntax.........: _GUICtrlListBox_GetSelItemsText($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - Array with the following format:
;                  |[0] - Total items in array
;                  |[1] - Text of the selected item
;                  |[2] - Text of the selected item
;                  |[n] - Text of the selected item
; Author ........: Gary Frost (gafrost), CyberSlug
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListBox_GetSelItems
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_GetSelItemsText($hWnd)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	Local $aText[1] = [0], $iCount = _GUICtrlListBox_GetSelCount($hWnd)
	If $iCount > 0 Then
		Local $aIndices = _GUICtrlListBox_GetSelItems($hWnd)
		ReDim $aText[UBound($aIndices)]
		$aText[0] = $aIndices[0]
		For $i = 1 To $aIndices[0]
			$aText[$i] = _GUICtrlListBox_GetText($hWnd, $aIndices[$i])
		Next
	EndIf
	Return $aText
EndFunc   ;==>_GUICtrlListBox_GetSelItemsText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_GetText
; Description ...: Returns the item (string) at the specified index
; Syntax.........: _GUICtrlListBox_GetText($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Specifies the zero-based index of the string to retrieve
; Return values .: Success      - item (string)
; Author ........: CyberSlug
; Modified.......: Gary Frost (gafrost
; Remarks .......:
; Related .......: _GUICtrlListBox_GetTextLen
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_GetText($hWnd, $iIndex)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)

	Local $tText = DllStructCreate("wchar Text[" & _GUICtrlListBox_GetTextLen($hWnd, $iIndex) + 1 & "]")
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	_SendMessage($hWnd, $LB_GETTEXT, $iIndex, $tText, 0, "wparam", "struct*")
	Return DllStructGetData($tText, "Text")
EndFunc   ;==>_GUICtrlListBox_GetText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_GetTextLen
; Description ...: Gets the length of a string in a list box
; Syntax.........: _GUICtrlListBox_GetTextLen($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Specifies the zero based index of the item
; Return values .: Success      - The length of the string
; Author ........: CyberSlug
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListBox_GetText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_GetTextLen($hWnd, $iIndex)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_GETTEXTLEN, $iIndex)
	Else
		Return GUICtrlSendMsg($hWnd, $LB_GETTEXTLEN, $iIndex, 0)
	EndIf
EndFunc   ;==>_GUICtrlListBox_GetTextLen

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_GetTopIndex
; Description ...: Retrieve the index of the first visible item in a list
; Syntax.........: _GUICtrlListBox_GetTopIndex($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - The index of the first visible item
; Author ........: Gary Frost (gafrost), CyberSlug
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListBox_SetTopIndex
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_GetTopIndex($hWnd)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_GETTOPINDEX)
	Else
		Return GUICtrlSendMsg($hWnd, $LB_GETTOPINDEX, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListBox_GetTopIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_InitStorage
; Description ...: This message allocates memory for storing items
; Syntax.........: _GUICtrlListBox_InitStorage($hWnd, $iItems, $iBytes)
; Parameters ....: $hWnd        - Handle to control
;                  $iItems      - The total amount of items that you intend to add
;                  $iBytes      - The total amount of memory your strings will consume
; Return values .: Success      - The total number of items for which memory has been pre-allocated
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListBox_AddFile, _GUICtrlListBox_AddString, _GUICtrlListBox_Dir, _GUICtrlListBox_InsertString
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_InitStorage($hWnd, $iItems, $iBytes)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_INITSTORAGE, $iItems, $iBytes)
	Else
		Return GUICtrlSendMsg($hWnd, $LB_INITSTORAGE, $iItems, $iBytes)
	EndIf
EndFunc   ;==>_GUICtrlListBox_InitStorage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_InsertString
; Description ...: Insert a string into the list
; Syntax.........: _GUICtrlListBox_InsertString($hWnd, $sText[, $iIndex = -1])
; Parameters ....: $hWnd        - Handle to control
;                  $sText       - Text string to be inserted
;                  $iIndex      - Specifies the zero based index of the position at which to insert the string. If this parameter
;                  +is -1 the string is added to the end of the list.
; Return values .: Success      - Zero based index of the item position
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If $iIndex is -1 then string is added to end of list.  Unlike the _GUICtrlListBox_AddString,
;                  this function does not cause a list with the $LBS_SORT style to be sorted.
; Related .......: _GUICtrlListBox_AddString, _GUICtrlListBox_DeleteString, _GUICtrlListBox_InitStorage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_InsertString($hWnd, $sText, $iIndex = -1)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_INSERTSTRING, $iIndex, $sText, 0, "wparam", "wstr")
	Else
		Return GUICtrlSendMsg($hWnd, $LB_INSERTSTRING, $iIndex, $sText)
	EndIf
EndFunc   ;==>_GUICtrlListBox_InsertString

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_ItemFromPoint
; Description ...: Retrieves the zero based index of the item nearest the specified point
; Syntax.........: _GUICtrlListBox_ItemFromPoint($hWnd, $iX, $iY)
; Parameters ....: $hWnd        - Handle to control
;                  $iX          - X coordinate, relative to the upper-left corner of the client area
;                  $iY          - Y coordinate, relative to the upper-left corner of the client area
; Return values .: Success      - The index of the nearest item
;                  Failure      - -1 if the point is outside of the client area
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_ItemFromPoint($hWnd, $iX, $iY)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	Local $iRet

	If IsHWnd($hWnd) Then
		$iRet = _SendMessage($hWnd, $LB_ITEMFROMPOINT, 0, _WinAPI_MakeLong($iX, $iY))
	Else
		$iRet = GUICtrlSendMsg($hWnd, $LB_ITEMFROMPOINT, 0, _WinAPI_MakeLong($iX, $iY))
	EndIf

	If _WinAPI_HiWord($iRet) <> 0 Then $iRet = -1
	Return $iRet
EndFunc   ;==>_GUICtrlListBox_ItemFromPoint

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_ReplaceString
; Description ...: Replaces the text of an item
; Syntax.........: _GUICtrlListBox_ReplaceString($hWnd, $iIndex, $sText)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Specifies the zero based index of the item
;                  $sText       - String to replace old string
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost), CyberSlug
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_ReplaceString($hWnd, $iIndex, $sText)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If (_GUICtrlListBox_DeleteString($hWnd, $iIndex) == $LB_ERR) Then Return SetError($LB_ERR, $LB_ERR, False)
	If (_GUICtrlListBox_InsertString($hWnd, $sText, $iIndex) == $LB_ERR) Then Return SetError($LB_ERR, $LB_ERR, False)
	Return True
EndFunc   ;==>_GUICtrlListBox_ReplaceString

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_ResetContent
; Description ...: Remove all items from the list box
; Syntax.........: _GUICtrlListBox_ResetContent($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListBox_DeleteString
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_ResetContent($hWnd)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		_SendMessage($hWnd, $LB_RESETCONTENT)
	Else
		GUICtrlSendMsg($hWnd, $LB_RESETCONTENT, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListBox_ResetContent

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_SelectString
; Description ...: Searchs for an item that begins with the specified string
; Syntax.........: _GUICtrlListBox_SelectString($hWnd, $sText[, $iIndex = -1])
; Parameters ....: $hWnd        - Handle to control
;                  $sText       - String that contains the string for which to search.
;                  $iIndex      - Specifies the zero based index of the item before the first item to be searched.  When the
;                  +search reaches the bottom of the list box, it continues searching from the top of the list box back to the
;                  +item specified by $iIndex.  If $iIndex is –1, the entire list box is searched from the beginning.
; Return values .: Success      - The zero based index of the selected item
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The list box is scrolled, if necessary, to bring the selected item into view.
;                  Do not use this message with a list box that has the $LBS_MULTIPLESEL or the $LBS_EXTENDEDSEL styles.
; Related .......: _GUICtrlListBox_FindString, _GUICtrlListBox_FindInText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_SelectString($hWnd, $sText, $iIndex = -1)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_SELECTSTRING, $iIndex, $sText, 0, "wparam", "wstr")
	Else
		Return GUICtrlSendMsg($hWnd, $LB_SELECTSTRING, $iIndex, $sText)
	EndIf
EndFunc   ;==>_GUICtrlListBox_SelectString

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_SelItemRange
; Description ...: Select one or more consecutive items in a multiple-selection list box
; Syntax.........: _GUICtrlListBox_SelItemRange($hWnd, $iFirst, $iLast[, $fSelect = True])
; Parameters ....: $hWnd        - Handle to control
;                  $iFirst      - Zero based index of the first item to select
;                  $iLast       - Zero based index of the last item to select
;                  $fSelect     - Specifies how to set the selection.  If this parameter is True,  the  string  is  selected  and
;                  +highlighted; if it is False, the highlight is removed and the string is no longer selected.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost), CyberSlug
; Modified.......: Gary Frost (gafrost, re-written
; Remarks .......: Use this message only with multiple-selection list boxes.
;                  This message can select a range only within the first 65,536 items.
; Related .......: _GUICtrlListBox_SelItemRangeEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_SelItemRange($hWnd, $iFirst, $iLast, $fSelect = True)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_SELITEMRANGE, $fSelect, _WinAPI_MakeLong($iFirst, $iLast)) = 0
	Else
		Return GUICtrlSendMsg($hWnd, $LB_SELITEMRANGE, $fSelect, _WinAPI_MakeLong($iFirst, $iLast)) = 0
	EndIf
EndFunc   ;==>_GUICtrlListBox_SelItemRange

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_SelItemRangeEx
; Description ...: Select one or more consecutive items in a multiple-selection list box
; Syntax.........: _GUICtrlListBox_SelItemRangeEx($hWnd, $iFirst, $iLast)
; Parameters ....: $hWnd        - Handle to control
;                  $iFirst      - Zero based index of the first item to select
;                  $iLast       - Zero based index of the last item to select
; Return values .: Success      - True
;                  Failure      - False
; Author ........: CyberSlug
; Modified.......: Gary Frost (gafrost)
; Remarks .......: If the $iFirst is less than the $iLast, the specified range of items is selected. If
;                  $iFirst is greater than or equal to $iLast, the range is removed from the specified
;                  range of items.  To select only one item, select two items and then deselect the
;                  unwanted item.
;+
;                  Use this message only with multiple-selection list boxes.
;                  This message can select a range only within the first 65,536 items.
; Related .......: _GUICtrlListBox_SelItemRange
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_SelItemRangeEx($hWnd, $iFirst, $iLast)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_SELITEMRANGEEX, $iFirst, $iLast) = 0
	Else
		Return GUICtrlSendMsg($hWnd, $LB_SELITEMRANGEEX, $iFirst, $iLast) = 0
	EndIf
EndFunc   ;==>_GUICtrlListBox_SelItemRangeEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_SetAnchorIndex
; Description ...: Set the anchor item—that is, the item from which a multiple selection starts
; Syntax.........: _GUICtrlListBox_SetAnchorIndex($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Specifies the zero based index of the item
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListBox_GetAnchorIndex
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_SetAnchorIndex($hWnd, $iIndex)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_SETANCHORINDEX, $iIndex) = 0
	Else
		Return GUICtrlSendMsg($hWnd, $LB_SETANCHORINDEX, $iIndex, 0) = 0
	EndIf
EndFunc   ;==>_GUICtrlListBox_SetAnchorIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_SetCaretIndex
; Description ...: Set the focus rectangle to the item at the specified index in a multiple-selection list box
; Syntax.........: _GUICtrlListBox_SetCaretIndex($hWnd, $iIndex[, $fPartial = False])
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Specifies the zero based index of the item
;                  $fPartial    - If False, the item is scrolled until it is fully visible; if it is True, the item  is  scrolled
;                  +until it is at least partially visible.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListBox_GetCaretIndex
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_SetCaretIndex($hWnd, $iIndex, $fPartial = False)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_SETCARETINDEX, $iIndex, $fPartial) = 0
	Else
		Return GUICtrlSendMsg($hWnd, $LB_SETCARETINDEX, $iIndex, $fPartial) = 0
	EndIf
EndFunc   ;==>_GUICtrlListBox_SetCaretIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_SetColumnWidth
; Description ...: Set the width, in pixels, of all columns
; Syntax.........: _GUICtrlListBox_SetColumnWidth($hWnd, $iWidth)
; Parameters ....: $hWnd        - Handle to control
;                  $iWidth      - Specifies the width, in pixels, of all columns
; Return values .: None
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: For use on controls created with the $LBS_MULTICOLUMN style
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_SetColumnWidth($hWnd, $iWidth)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		_SendMessage($hWnd, $LB_SETCOLUMNWIDTH, $iWidth)
	Else
		GUICtrlSendMsg($hWnd, $LB_SETCOLUMNWIDTH, $iWidth, 0)
	EndIf
EndFunc   ;==>_GUICtrlListBox_SetColumnWidth

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_SetCurSel
; Description ...: Select a string and scroll it into view, if necessary
; Syntax.........: _GUICtrlListBox_SetCurSel($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Specifies the zero based index of the string that is selected. If this parameter is -1 the list
;                  +box is set to have no selection.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Sokko
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Use this message only with single-selection list boxes.
;                  You cannot use it to set or remove a selection in a multiple-selection list box
; Related .......: _GUICtrlListBox_GetCurSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_SetCurSel($hWnd, $iIndex)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_SETCURSEL, $iIndex)
	Else
		Return GUICtrlSendMsg($hWnd, $LB_SETCURSEL, $iIndex, 0)
	EndIf
EndFunc   ;==>_GUICtrlListBox_SetCurSel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_SetHorizontalExtent
; Description ...: Set the width, in pixels, by which a list box can be scrolled horizontally
; Syntax.........: _GUICtrlListBox_SetHorizontalExtent($hWnd, $iWidth)
; Parameters ....: $hWnd        - Handle to control
;                  $iWidth      - Specifies the number of pixels the list box can be scrolled
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Microsoft Windows 95/Windows 98/Windows Millennium Edition (Windows Me) : The $iWidth parameter
;                  is limited to 16-bit values.
;+
;                  To respond to the _GUICtrlListBox_SetHorizontalExtent, the list box must have been defined with
;                  the $WS_HSCROLL style.
; Related .......: _GUICtrlListBox_GetHorizontalExtent
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_SetHorizontalExtent($hWnd, $iWidth)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		_SendMessage($hWnd, $LB_SETHORIZONTALEXTENT, $iWidth)
	Else
		GUICtrlSendMsg($hWnd, $LB_SETHORIZONTALEXTENT, $iWidth, 0)
	EndIf
EndFunc   ;==>_GUICtrlListBox_SetHorizontalExtent

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_SetItemData
; Description ...: Sets the value associated with the specified item
; Syntax.........:  _GUICtrlListBox_SetItemData($hWnd, $iIndex, $iValue)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Specifies the zero based index of the item
;                  $iValue      - Specifies the value to be associated with the item
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListBox_GetItemData
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_SetItemData($hWnd, $iIndex, $iValue)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_SETITEMDATA, $iIndex, $iValue) <> -1
	Else
		Return GUICtrlSendMsg($hWnd, $LB_SETITEMDATA, $iIndex, $iValue) <> -1
	EndIf
EndFunc   ;==>_GUICtrlListBox_SetItemData

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_SetItemHeight
; Description ...: Sets the height, in pixels, of items
; Syntax.........: _GUICtrlListBox_SetItemHeight($hWnd, $iHeight[, $iIndex = 0])
; Parameters ....: $hWnd        - Handle to control
;                  $iHeight     - Specifies the height, in pixels, of the item
;                  $iIndex      - Specifies the zero based index of the item in the list box.  Use this only if the  control  has
;                  +the LBS_OWNERDRAWVARIABLE style otherwise, set it to zero.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListBox_GetItemHeight
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_SetItemHeight($hWnd, $iHeight, $iIndex = 0)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	Local $iRet

	If IsHWnd($hWnd) Then
		$iRet = _SendMessage($hWnd, $LB_SETITEMHEIGHT, $iIndex, $iHeight)
		_WinAPI_InvalidateRect($hWnd)
	Else
		$iRet = GUICtrlSendMsg($hWnd, $LB_SETITEMHEIGHT, $iIndex, $iHeight)
		_WinAPI_InvalidateRect(GUICtrlGetHandle($hWnd))
	EndIf
	Return $iRet <> -1
EndFunc   ;==>_GUICtrlListBox_SetItemHeight

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_SetLocale
; Description ...: Set the current locale
; Syntax.........: _GUICtrlListBox_SetLocale($hWnd, $iLocal)
; Parameters ....: $hWnd        - Handle to control
;                  $iLocal      - Specifies the locale identifier that the list box will use for sorting when adding text
; Return values .: Success      - The previous locale identifier
;                  Failure      - -1
; Author ........: CyberSlug
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListBox_GetLocale
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_SetLocale($hWnd, $iLocal)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_SETLOCALE, $iLocal)
	Else
		Return GUICtrlSendMsg($hWnd, $LB_SETLOCALE, $iLocal, 0)
	EndIf
EndFunc   ;==>_GUICtrlListBox_SetLocale

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_SetSel
; Description ...: Select a string(s) in a multiple-selection list box
; Syntax.........: _GUICtrlListBox_SetSel($hWnd[, $iIndex = -1[, $fSelect = -1]])
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Specifies the zero based index of the item
;                  $fSelect     - Specifies how to set the selection.
;                 |   -1        - Toggle select/unselect of a string
;                 | True        - The string is selected
;                 |False        - The highlight is removed and the string is no longer selected
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost), CyberSlug
; Modified.......:
; Remarks .......: An $iIndex of -1 means to toggle select/unselect of all items (ignores the $fSelect)
; Related .......: _GUICtrlListBox_GetSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_SetSel($hWnd, $iIndex = -1, $fSelect = -1)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	Local $i_ret = True
	If IsHWnd($hWnd) Then
		If $iIndex == -1 Then ; toggle all
			For $iIndex = 0 To _GUICtrlListBox_GetCount($hWnd) - 1
				$i_ret = _GUICtrlListBox_GetSel($hWnd, $iIndex)
				If ($i_ret == $LB_ERR) Then Return SetError($LB_ERR, $LB_ERR, False)
				If ($i_ret > 0) Then ;If Selected Then
					$i_ret = _SendMessage($hWnd, $LB_SETSEL, False, $iIndex) <> -1
				Else
					$i_ret = _SendMessage($hWnd, $LB_SETSEL, True, $iIndex) <> -1
				EndIf
				If ($i_ret == False) Then Return SetError($LB_ERR, $LB_ERR, False)
			Next
		ElseIf $fSelect == -1 Then ; toggle state of index
			If _GUICtrlListBox_GetSel($hWnd, $iIndex) Then ;If Selected Then
				Return _SendMessage($hWnd, $LB_SETSEL, False, $iIndex) <> -1
			Else
				Return _SendMessage($hWnd, $LB_SETSEL, True, $iIndex) <> -1
			EndIf
		Else ; set state according to flag
			Return _SendMessage($hWnd, $LB_SETSEL, $fSelect, $iIndex) <> -1
		EndIf
	Else
		If $iIndex == -1 Then ; toggle all
			For $iIndex = 0 To _GUICtrlListBox_GetCount($hWnd) - 1
				$i_ret = _GUICtrlListBox_GetSel($hWnd, $iIndex)
				If ($i_ret == $LB_ERR) Then Return SetError($LB_ERR, $LB_ERR, False)
				If ($i_ret > 0) Then ;If Selected Then
					$i_ret = GUICtrlSendMsg($hWnd, $LB_SETSEL, False, $iIndex) <> -1
				Else
					$i_ret = GUICtrlSendMsg($hWnd, $LB_SETSEL, True, $iIndex) <> -1
				EndIf
				If ($i_ret == False) Then Return SetError($LB_ERR, $LB_ERR, False)
			Next
		ElseIf $fSelect == -1 Then ; toggle state of index
			If _GUICtrlListBox_GetSel($hWnd, $iIndex) Then ;If Selected Then
				Return GUICtrlSendMsg($hWnd, $LB_SETSEL, False, $iIndex) <> -1
			Else
				Return GUICtrlSendMsg($hWnd, $LB_SETSEL, True, $iIndex) <> -1
			EndIf
		Else ; set state according to flag
			Return GUICtrlSendMsg($hWnd, $LB_SETSEL, $fSelect, $iIndex) <> -1
		EndIf
	EndIf
	Return $i_ret
EndFunc   ;==>_GUICtrlListBox_SetSel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_SetTabStops
; Description ...: Sets the tab-stop positions
; Syntax.........: _GUICtrlListBox_SetTabStops($hWnd, $aTabStops)
; Parameters ....: $hWnd        - Handle to control
;                  $aTabStops   - Array with the following format:
;                  |[0] - Number of tab stops in the array (n)
;                  |[1] - First tab stop
;                  |[2] - Second tab stop
;                  |[n] - Nth tab stop
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: The integers in $aTabStops represent the number of quarters of the average character width for the font that
;                  is selected into the list box.  For example, a tab stop of 4 is placed at 1.0 character units, and a tab stop
;                  of 6 is placed at 1.5 average character units.  However, if the list box is part of a dialog box, the integers
;                  are in dialog template units.  The tab stops must be sorted in ascending order; backward tabs are not allowed.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_SetTabStops($hWnd, $aTabStops)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)

	Local $iCount = $aTabStops[0]
	Local $tTabStops = DllStructCreate("int[" & $iCount & "]")
	For $iI = 1 To $iCount
		DllStructSetData($tTabStops, 1, $aTabStops[$iI], $iI)
	Next
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_SETTABSTOPS, $iCount, $tTabStops, 0, "wparam", "struct*") = 0
	Else
		Return GUICtrlSendMsg($hWnd, $LB_SETTABSTOPS, $iCount, DllStructGetPtr($tTabStops)) = 0
	EndIf
EndFunc   ;==>_GUICtrlListBox_SetTabStops

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_SetTopIndex
; Description ...: Ensure that a particular item in a list box is visible
; Syntax.........: _GUICtrlListBox_SetTopIndex($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Specifies the zero-based index of the item
; Return values .: Success      - True
;                  Failure      - False
; Author ........: CyberSlug
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListBox_GetTopIndex
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_SetTopIndex($hWnd, $iIndex)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LB_SETTOPINDEX, $iIndex) <> -1
	Else
		Return GUICtrlSendMsg($hWnd, $LB_SETTOPINDEX, $iIndex, 0) <> -1
	EndIf
EndFunc   ;==>_GUICtrlListBox_SetTopIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_Sort
; Description ...: Re-sorts list box if it has the $LBS_SORT style
; Syntax.........: _GUICtrlListBox_Sort($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost), CyberSlug
; Modified.......:
; Remarks .......: Re-sorts list box if it has the LBS_SORT style
;                  Might be useful if you use InsertString
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_Sort($hWnd)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	Local $bak = _GUICtrlListBox_GetText($hWnd, 0)
	If ($bak == -1) Then Return SetError($LB_ERR, $LB_ERR, False)
	If (_GUICtrlListBox_DeleteString($hWnd, 0) == -1) Then Return SetError($LB_ERR, $LB_ERR, False)
	Return _GUICtrlListBox_AddString($hWnd, $bak) <> -1
EndFunc   ;==>_GUICtrlListBox_Sort

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_SwapString
; Description ...: Swaps the text of two items at the specified indices
; Syntax.........: _GUICtrlListBox_SwapString($hWnd, $iIndexA, $iIndexB)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndexA     - Zero-based index item to swap
;                  $iIndexB     - Zero-based index item to swap
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost), Cyberslug
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_SwapString($hWnd, $iIndexA, $iIndexB)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	Local $itemA = _GUICtrlListBox_GetText($hWnd, $iIndexA)
	Local $itemB = _GUICtrlListBox_GetText($hWnd, $iIndexB)
	If (_GUICtrlListBox_DeleteString($hWnd, $iIndexA) == -1) Then Return SetError($LB_ERR, $LB_ERR, False)
	If (_GUICtrlListBox_InsertString($hWnd, $itemB, $iIndexA) == -1) Then Return SetError($LB_ERR, $LB_ERR, False)

	If (_GUICtrlListBox_DeleteString($hWnd, $iIndexB) == -1) Then Return SetError($LB_ERR, $LB_ERR, False)
	If (_GUICtrlListBox_InsertString($hWnd, $itemA, $iIndexB) == -1) Then Return SetError($LB_ERR, $LB_ERR, False)
	Return True
EndFunc   ;==>_GUICtrlListBox_SwapString

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListBox_UpdateHScroll
; Description ...: Update the horizontal scroll bar based on the longest string
; Syntax.........: _GUICtrlListBox_UpdateHScroll($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: None
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListBox_UpdateHScroll($hWnd)
	If $Debug_LB Then __UDF_ValidateClassName($hWnd, $__LISTBOXCONSTANT_ClassNames)
	Local $hDC, $hFont, $tSize, $sText
	Local $iMax = 0
	If IsHWnd($hWnd) Then
		$hFont = _SendMessage($hWnd, $__LISTBOXCONSTANT_WM_GETFONT)
		$hDC = _WinAPI_GetDC($hWnd)
		_WinAPI_SelectObject($hDC, $hFont)
		For $iI = 0 To _GUICtrlListBox_GetCount($hWnd) - 1
			$sText = _GUICtrlListBox_GetText($hWnd, $iI)
			$tSize = _WinAPI_GetTextExtentPoint32($hDC, $sText & "W")
			If DllStructGetData($tSize, "X") > $iMax Then
				$iMax = DllStructGetData($tSize, "X")
			EndIf
		Next
		_GUICtrlListBox_SetHorizontalExtent($hWnd, $iMax)
		_WinAPI_SelectObject($hDC, $hFont)
		_WinAPI_ReleaseDC($hWnd, $hDC)
	Else
		$hFont = GUICtrlSendMsg($hWnd, $__LISTBOXCONSTANT_WM_GETFONT, 0, 0)
		Local $t_hwnd = GUICtrlGetHandle($hWnd)
		$hDC = _WinAPI_GetDC($t_hwnd)
		_WinAPI_SelectObject($hDC, $hFont)
		For $iI = 0 To _GUICtrlListBox_GetCount($hWnd) - 1
			$sText = _GUICtrlListBox_GetText($hWnd, $iI)
			$tSize = _WinAPI_GetTextExtentPoint32($hDC, $sText & "W")
			If DllStructGetData($tSize, "X") > $iMax Then
				$iMax = DllStructGetData($tSize, "X")
			EndIf
		Next
		_GUICtrlListBox_SetHorizontalExtent($hWnd, $iMax)
		_WinAPI_SelectObject($hDC, $hFont)
		_WinAPI_ReleaseDC($t_hwnd, $hDC)
	EndIf
EndFunc   ;==>_GUICtrlListBox_UpdateHScroll
