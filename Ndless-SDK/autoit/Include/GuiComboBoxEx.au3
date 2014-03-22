#include-once

#include "GuiComboBox.au3"
#include "DirConstants.au3"
#include "Memory.au3"
#include "UDFGlobalID.au3"

; #INDEX# =======================================================================================================================
; Title .........: ComboBoxEx
; AutoIt Version : 3.3.7.20++
; Language ......: English
; Description ...: Functions that assist with ComboBoxEx control management.
;                  ComboBoxEx Controls are an extension of the combo box control that provides native support for item images.
;                  To make item images easily accessible, the control provides image list support. By using this control, you
;                  can provide the functionality of a combo box without having to manually draw item graphics.
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $_ghCBExLastWnd
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__COMBOBOXEXCONSTANT_ClassName = "ComboBoxEx32"
Global Const $__COMBOBOXEXCONSTANT_WM_SIZE = 0x05
; ===============================================================================================================================

; #NO_DOC_FUNCTION# =============================================================================================================
; Not working/documented/implemented at this time
;
;_GUICtrlComboBoxEx_HasEditChanged
;
; Things to figure out for ComboBoxEx
;FindString
;AutoComplete
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_GUICtrlComboBoxEx_AddDir
;_GUICtrlComboBoxEx_AddString
;_GUICtrlComboBoxEx_BeginUpdate
;_GUICtrlComboBoxEx_Create
;_GUICtrlComboBoxEx_CreateSolidBitMap
;_GUICtrlComboBoxEx_DeleteString
;_GUICtrlComboBoxEx_Destroy
;_GUICtrlComboBoxEx_EndUpdate
;_GUICtrlComboBoxEx_FindStringExact
;_GUICtrlComboBoxEx_GetComboBoxInfo
;_GUICtrlComboBoxEx_GetComboControl
;_GUICtrlComboBoxEx_GetCount
;_GUICtrlComboBoxEx_GetCurSel
;_GUICtrlComboBoxEx_GetDroppedControlRect
;_GUICtrlComboBoxEx_GetDroppedControlRectEx
;_GUICtrlComboBoxEx_GetDroppedState
;_GUICtrlComboBoxEx_GetDroppedWidth
;_GUICtrlComboBoxEx_GetEditControl
;_GUICtrlComboBoxEx_GetEditSel
;_GUICtrlComboBoxEx_GetEditText
;_GUICtrlComboBoxEx_GetExtendedStyle
;_GUICtrlComboBoxEx_GetExtendedUI
;_GUICtrlComboBoxEx_GetImageList
;_GUICtrlComboBoxEx_GetItem
;_GUICtrlComboBoxEx_GetItemEx
;_GUICtrlComboBoxEx_GetItemHeight
;_GUICtrlComboBoxEx_GetItemImage
;_GUICtrlComboBoxEx_GetItemIndent
;_GUICtrlComboBoxEx_GetItemOverlayImage
;_GUICtrlComboBoxEx_GetItemParam
;_GUICtrlComboBoxEx_GetItemSelectedImage
;_GUICtrlComboBoxEx_GetItemText
;_GUICtrlComboBoxEx_GetItemTextLen
;_GUICtrlComboBoxEx_GetList
;_GUICtrlComboBoxEx_GetListArray
;_GUICtrlComboBoxEx_GetLocale
;_GUICtrlComboBoxEx_GetLocaleCountry
;_GUICtrlComboBoxEx_GetLocaleLang
;_GUICtrlComboBoxEx_GetLocalePrimLang
;_GUICtrlComboBoxEx_GetLocaleSubLang
;_GUICtrlComboBoxEx_GetMinVisible
;_GUICtrlComboBoxEx_GetTopIndex
;_GUICtrlComboBoxEx_GetUnicode
;_GUICtrlComboBoxEx_InitStorage
;_GUICtrlComboBoxEx_InsertString
;_GUICtrlComboBoxEx_LimitText
;_GUICtrlComboBoxEx_ReplaceEditSel
;_GUICtrlComboBoxEx_ResetContent
;_GUICtrlComboBoxEx_SetCurSel
;_GUICtrlComboBoxEx_SetDroppedWidth
;_GUICtrlComboBoxEx_SetEditSel
;_GUICtrlComboBoxEx_SetEditText
;_GUICtrlComboBoxEx_SetExtendedStyle
;_GUICtrlComboBoxEx_SetExtendedUI
;_GUICtrlComboBoxEx_SetImageList
;_GUICtrlComboBoxEx_SetItem
;_GUICtrlComboBoxEx_SetItemEx
;_GUICtrlComboBoxEx_SetItemHeight
;_GUICtrlComboBoxEx_SetItemImage
;_GUICtrlComboBoxEx_SetItemIndent
;_GUICtrlComboBoxEx_SetItemOverlayImage
;_GUICtrlComboBoxEx_SetItemParam
;_GUICtrlComboBoxEx_SetItemSelectedImage
;_GUICtrlComboBoxEx_SetMinVisible
;_GUICtrlComboBoxEx_SetTopIndex
;_GUICtrlComboBoxEx_SetUnicode
;_GUICtrlComboBoxEx_ShowDropDown
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_AddDir
; Description ...: Adds the names of directories and files
; Syntax.........: _GUICtrlComboBoxEx_AddDir($hWnd, $sFile[, $iAttributes = 0[, $fBrackets = True]])
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
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If there is insufficient space to store the new strings, the return value is $CB_ERRSPACE
;                  Needs Constants.au3 for pre-defined constants
; Related .......: _GUICtrlComboBoxEx_InitStorage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_AddDir($hWnd, $sFile, $iAttributes = 0, $fBrackets = True)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Local $cb_gui = GUICreate("combo gui")
	Local $combo = GUICtrlCreateCombo("", 240, 40, 120, 120)
	Local $iRet = GUICtrlSendMsg($combo, $CB_DIR, $iAttributes, $sFile)
	If $iRet = -1 Then
		GUIDelete($cb_gui)
		Return SetError(-1, -1, -1)
	EndIf
	Local $sText
	For $i = 0 To _GUICtrlComboBox_GetCount($combo) - 1
		_GUICtrlComboBox_GetLBText($combo, $i, $sText)
		If BitAND($iAttributes, $DDL_DRIVES) = $DDL_DRIVES And _
				Not $fBrackets Then $sText = StringReplace(StringReplace(StringReplace($sText, "[", ""), "]", ":"), "-", "")
		_GUICtrlComboBoxEx_InsertString($hWnd, $sText)
	Next
	GUIDelete($cb_gui)
	Return $iRet
EndFunc   ;==>_GUICtrlComboBoxEx_AddDir

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_AddString
; Description ...: Add a string
; Syntax.........: _GUICtrlComboBoxEx_AddString($hWnd, $sText[, $iImage = -1[, $iSelecteImage = -1[, $iOverlayImage = -1[, $iIndent = -1[, $iParam = -1]]]]])
; Parameters ....: $hWnd          - Handle to the control
;                  +To insert an item at the end of the list, set the $iIndex member to -1
;                  $sText         - Item text. If set to -1, the item set is set via the $CBEN_GETDISPINFO notification message.
;                  $iImage        - Zero based index of the item's icon in the control's image list
;                  $iSelecteImage - Zero based index of the item's icon in the control's image list
;                  $iOverlayImage - Zero based index of the item's icon in the control's image list
;                  $iIndent       - Number of image widths to indent the item. A single indentation equals the width of an image.
;                  $iParam        - Value specific to the item
; Return values .: Success        - The index of the new item
;                  Failure        - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_DeleteString, _GUICtrlComboBoxEx_InitStorage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_AddString($hWnd, $sText, $iImage = -1, $iSelecteImage = -1, $iOverlayImage = -1, $iIndent = -1, $iParam = -1)
	Return _GUICtrlComboBoxEx_InsertString($hWnd, $sText, -1, $iImage, $iSelecteImage, $iOverlayImage, $iIndent, $iParam)
EndFunc   ;==>_GUICtrlComboBoxEx_AddString

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_BeginUpdate
; Description ...: Prevents updating of the control until the EndUpdate function is called
; Syntax.........: _GUICtrlComboBoxEx_BeginUpdate($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_EndUpdate
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_BeginUpdate($hWnd)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Return _SendMessage($hWnd, $__COMBOBOXCONSTANT_WM_SETREDRAW) = 0
EndFunc   ;==>_GUICtrlComboBoxEx_BeginUpdate

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_Create
; Description ...: Create a ComboBoxEx control
; Syntax.........: _GUICtrlComboBoxEx_Create($hWnd, $sText, $iX, $iY[, $iWidth = 100[, $iHeight = 200[, $iStyle = 0x00200002[, $iExStyle = 0x00000000]]]])
; Parameters ....: $hWnd                       - Handle to parent or owner window
;                  $sText                      - Delimited text to add to ComboBox
;                  $iX                         - Horizontal position of the control
;                  $iY                         - Vertical position of the control
;                  $iWidth                     - Control width
;                  $iHeight                    - Control height
;                  $iStyle                     - Control style:
;                  |$CBS_DROPDOWN              - Similar to $CBS_SIMPLE, except that the list box is not displayed
;                  +unless the user selects an icon next to the edit control
;                  |$CBS_DROPDOWNLIST          - Similar to $CBS_DROPDOWN, except that the edit control is replaced
;                  +by a static text item that displays the current selection in the list box
;                  |$CBS_SIMPLE                - Displays the list box at all times
;                  -
;                  |Default: $CBS_DROPDOWN, $WS_VSCROLL
;                  |Forced : $WS_CHILD, $WS_TABSTOP, $WS_VISIBLE
;                  -
;                  $iExStyle    - Control extended style:
;                  |$CBES_EX_CASESENSITIVE     - Searches in the list will be case sensitive
;                  |$CBES_EX_NOEDITIMAGE       - The edit box and the dropdown list will not display item images
;                  |$CBES_EX_NOEDITIMAGEINDENT - The edit box and the dropdown list will not display item images
;                  |$CBES_EX_NOSIZELIMIT       - Allows the ComboBoxEx control to be vertically sized smaller than its contained combo box control
;                  |$CBES_EX_PATHWORDBREAKPROC - Microsoft Windows NT only.
;                  +The edit box will use the slash (/), backslash (\), and period (.) characters as word delimiters.
;                  +This makes keyboard shortcuts for word-by-word cursor movement () effective in path names and URLs.
; Return values .: Success      - Handle to the Listbox control
;                  Failure      - 0
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_Destroy
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_Create($hWnd, $sText, $iX, $iY, $iWidth = 100, $iHeight = 200, $iStyle = 0x00200002, $iExStyle = 0x00000000)
	If Not IsHWnd($hWnd) Then Return SetError(1, 0, 0) ; Invalid Window handle for _GUICtrlComboBoxEx_Create 1st parameter
	If Not IsString($sText) Then Return SetError(2, 0, 0) ; 2nd parameter not a string for _GUICtrlComboBoxEx_Create

	Local $sDelimiter = Opt("GUIDataSeparatorChar")

	If $iWidth = -1 Then $iWidth = 100
	If $iHeight = -1 Then $iHeight = 200
	Local Const $WS_VSCROLL = 0x00200000
	If $iStyle = -1 Then $iStyle = BitOR($WS_VSCROLL, $CBS_DROPDOWN)
	If $iExStyle = -1 Then $iExStyle = 0x00000000

	$iStyle = BitOR($iStyle, $__UDFGUICONSTANT_WS_CHILD, $__COMBOBOXCONSTANT_WS_TABSTOP, $__UDFGUICONSTANT_WS_VISIBLE)

	Local $nCtrlID = __UDF_GetNextGlobalID($hWnd)
	If @error Then Return SetError(@error, @extended, 0)

	Local $hCombo = _WinAPI_CreateWindowEx($iExStyle, $__COMBOBOXEXCONSTANT_ClassName, "", $iStyle, $iX, $iY, $iWidth, $iHeight, $hWnd, $nCtrlID)
	_WinAPI_SetFont($hCombo, _WinAPI_GetStockObject($__COMBOBOXCONSTANT_DEFAULT_GUI_FONT))
	If StringLen($sText) Then
		Local $aText = StringSplit($sText, $sDelimiter)
		For $x = 1 To $aText[0]
			_GUICtrlComboBoxEx_AddString($hCombo, $aText[$x])
		Next
	EndIf
	Return $hCombo
EndFunc   ;==>_GUICtrlComboBoxEx_Create

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_CreateSolidBitMap
; Description ...: Creates a solid color bitmap
; Syntax.........: _GUICtrlComboBoxEx_CreateSolidBitMap($hWnd, $iColor, $iWidth, $iHeight)
; Parameters ....: $hWnd        - Handle to the window where the bitmap will be displayed
;                  $iColor      - The color of the bitmap, stated in RGB
;                  $iWidth      - The width of the bitmap
;                  $iHeight     - The height of the bitmap
; Return values .: Success      - Handle to the bitmap
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_CreateSolidBitMap($hWnd, $iColor, $iWidth, $iHeight)
	Return _WinAPI_CreateSolidBitmap($hWnd, $iColor, $iWidth, $iHeight)
EndFunc   ;==>_GUICtrlComboBoxEx_CreateSolidBitMap

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_DeleteString
; Description ...: Removes an item from a ComboBoxEx control
; Syntax.........: _GUICtrlComboBoxEx_DeleteString($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the Item to delete
; Return values .: Success      - Number of items remaining in the control
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_AddString
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_DeleteString($hWnd, $iIndex)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Return _SendMessage($hWnd, $CBEM_DELETEITEM, $iIndex)
EndFunc   ;==>_GUICtrlComboBoxEx_DeleteString

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_Destroy
; Description ...: Delete the control
; Syntax.........: _GUICtrlComboBoxEx_Destroy(ByRef $hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True, Handle is set to 0
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Restricted to only be used on ComboBox created with _GUICtrlComboBoxEx_Create
; Related .......: _GUICtrlComboBoxEx_Create
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_Destroy(ByRef $hWnd)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)
	If Not _WinAPI_IsClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName) Then Return SetError(2, 2, False)

	Local $Destroyed = 0
	If _WinAPI_InProcess($hWnd, $_ghCBExLastWnd) Then
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
	If $Destroyed Then $hWnd = 0
	Return $Destroyed <> 0
EndFunc   ;==>_GUICtrlComboBoxEx_Destroy

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_EndUpdate
; Description ...: Enables screen repainting that was turned off with the BeginUpdate function
; Syntax.........: _GUICtrlComboBoxEx_EndUpdate($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_BeginUpdate
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_EndUpdate($hWnd)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Return _SendMessage($hWnd, $__COMBOBOXCONSTANT_WM_SETREDRAW, 1) = 0
EndFunc   ;==>_GUICtrlComboBoxEx_EndUpdate

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_FindStringExact
; Description ...: Search for a string
; Syntax.........: _GUICtrlComboBoxEx_FindStringExact($hWnd, $sText[, $iIndex = -1])
; Parameters ....: $hWnd        - Handle to control
;                  $sText       - String to search for
;                  $iIndex      - Zero based index of the item preceding the first item to be searched
; Return values .: Success      - Zero based index of the matching item
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Find the first string that matches the string specified in the $sText parameter
;+
;                  When the search reaches the bottom of the ListBox, it continues from the top of the
;                  ListBox back to the item specified by $iIndex.
;+
;                  If $iIndex is –1, the entire ListBox is searched from the beginning.
; Related .......: _GUICtrlComboBox_SelectString
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_FindStringExact($hWnd, $sText, $iIndex = -1)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Return _SendMessage($hWnd, $CB_FINDSTRINGEXACT, $iIndex, $sText, 0, "wparam", "wstr")
EndFunc   ;==>_GUICtrlComboBoxEx_FindStringExact

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetComboBoxInfo
; Description ...: Gets information about the specified ComboBox
; Syntax.........: _GUICtrlComboBoxEx_GetComboBoxInfo($hWnd, ByRef $tInfo)
; Parameters ....: $hWnd        - Handle to control
;                  $tInfo       - The information about the ComboBox.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetComboBoxInfo($hWnd, ByRef $tInfo)
	Local $hCombo = _GUICtrlComboBoxEx_GetComboControl($hWnd)
	Return _GUICtrlComboBox_GetComboBoxInfo($hCombo, $tInfo)
EndFunc   ;==>_GUICtrlComboBoxEx_GetComboBoxInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetComboControl
; Description ...: Gets the handle to the child combo box control
; Syntax.........: _GUICtrlComboBoxEx_GetComboControl($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - handle to the combo box control within the ComboBoxEx control
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetComboControl($hWnd)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Return HWnd(_SendMessage($hWnd, $CBEM_GETCOMBOCONTROL))
EndFunc   ;==>_GUICtrlComboBoxEx_GetComboControl

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetCount
; Description ...: Retrieve the number of items
; Syntax.........: _GUICtrlComboBoxEx_GetCount($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - Number of items
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetCount($hWnd)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Return _SendMessage($hWnd, $CB_GETCOUNT)
EndFunc   ;==>_GUICtrlComboBoxEx_GetCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetCurSel
; Description ...: Retrieve the index of the currently selected item
; Syntax.........: _GUICtrlComboBoxEx_GetCurSel($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_SetCurSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetCurSel($hWnd)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Return _SendMessage($hWnd, $CB_GETCURSEL)
EndFunc   ;==>_GUICtrlComboBoxEx_GetCurSel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetDroppedControlRect
; Description ...: Retrieve the screen coordinates of a combo box in its dropped-down state
; Syntax.........: _GUICtrlComboBoxEx_GetDroppedControlRect($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - Array with the following format:
;                  |[0] - X coordinate of the upper left corner of the rectangle
;                  |[1] - Y coordinate of the upper left corner of the rectangle
;                  |[2] - X coordinate of the lower right corner of the rectangle
;                  |[3] - Y coordinate of the lower right corner of the rectangle
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_GetDroppedControlRectEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetDroppedControlRect($hWnd)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Local $tRECT = _GUICtrlComboBox_GetDroppedControlRectEx($hWnd)
	Local $aRect[4]
	$aRect[0] = DllStructGetData($tRECT, "Left")
	$aRect[1] = DllStructGetData($tRECT, "Top")
	$aRect[2] = DllStructGetData($tRECT, "Right")
	$aRect[3] = DllStructGetData($tRECT, "Bottom")

	Return $aRect
EndFunc   ;==>_GUICtrlComboBoxEx_GetDroppedControlRect

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetDroppedControlRectEx
; Description ...: Retrieve the screen coordinates of a combo box in its dropped-down state
; Syntax.........: _GUICtrlComboBoxEx_GetDroppedControlRectEx($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - $tagRECT structure that receives the screen coordinates
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_GetDroppedControlRect, $tagRECT
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetDroppedControlRectEx($hWnd)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Local $tRECT = DllStructCreate($tagRECT)
	_SendMessage($hWnd, $CB_GETDROPPEDCONTROLRECT, 0, $tRECT, 0, "wparam", "struct*")
	Return $tRECT
EndFunc   ;==>_GUICtrlComboBoxEx_GetDroppedControlRectEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetDroppedState
; Description ...: Determines whether the ListBox of a ComboBox is dropped down
; Syntax.........: _GUICtrlComboBoxEx_GetDroppedState($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: True         - Is dropped down
;                  False        - Not dropped down
; Author ........: Gary Frost (gafro_GUICtrlComboBox_GetDroppedState
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBox_GetDroppedWidth, _GUICtrlComboBox_SetDroppedWidth, _GUICtrlComboBox_ShowDropDown, _GUICtrlComboBoxEx_ShowDropDown
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetDroppedState($hWnd)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Return _SendMessage($hWnd, $CB_GETDROPPEDSTATE) <> 0
EndFunc   ;==>_GUICtrlComboBoxEx_GetDroppedState

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetDroppedWidth
; Description ...: Retrieve the minimum allowable width, of the ListBox of a ComboBox
; Syntax.........: _GUICtrlComboBoxEx_GetDroppedWidth($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - The width, in pixels
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The ComboBox must have $CBS_DROPDOWN or $CBS_DROPDOWNLIST style.
; Related .......: _GUICtrlComboBox_GetDroppedState, _GUICtrlComboBoxEx_SetDroppedWidth
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetDroppedWidth($hWnd)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Local $hCombo = _GUICtrlComboBoxEx_GetComboControl($hWnd)
	Return _GUICtrlComboBox_GetDroppedWidth($hCombo)
EndFunc   ;==>_GUICtrlComboBoxEx_GetDroppedWidth

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetEditControl
; Description ...: Gets the handle to the edit control portion of a ComboBoxEx control
; Syntax.........: _GUICtrlComboBoxEx_GetEditControl($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The handle to the edit control within the ComboBoxEx control if it uses the $CBS_DROPDOWN style
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetEditControl($hWnd)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Return HWnd(_SendMessage($hWnd, $CBEM_GETEDITCONTROL))
EndFunc   ;==>_GUICtrlComboBoxEx_GetEditControl

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetEditSel
; Description ...: Gets the starting and ending character positions of the current selection in the edit control of a ComboBox
; Syntax.........: _GUICtrlComboBoxEx_GetEditSel($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - Array in the following format:
;                  |[0]         - Starting position
;                  |[1]         - Ending position
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If the message is sent to a ComboBox with the $CBS_DROPDOWN or $CBS_DROPDOWNLIST style the Function will fail.
; Related .......: _GUICtrlComboBoxEx_SetEditSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetEditSel($hWnd)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Local $hCombo = _GUICtrlComboBoxEx_GetComboControl($hWnd)
	Return _GUICtrlComboBox_GetEditSel($hCombo)
EndFunc   ;==>_GUICtrlComboBoxEx_GetEditSel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetEditText
; Description ...: Get the text from the edit control of a ComboBoxEx
; Syntax.........: _GUICtrlComboBoxEx_GetEditText($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - String from the edit control
;                  Failure      - Empty string
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If the message is sent to a ComboBox with the $CBS_DROPDOWN or $CBS_DROPDOWNLIST style the Function will fail.
; Related .......: _GUICtrlComboBoxEx_SetEditText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetEditText($hWnd)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Local $hComboBox = _GUICtrlComboBoxEx_GetComboControl($hWnd)
	Return _GUICtrlComboBox_GetEditText($hComboBox)
EndFunc   ;==>_GUICtrlComboBoxEx_GetEditText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetExtendedStyle
; Description ...: Gets the extended styles that are in use for a ComboBoxEx control
; Syntax.........: _GUICtrlComboBoxEx_GetExtendedStyle($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - DWORD value that contains the ComboBoxEx control extended styles in use for the control
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_SetExtendedStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetExtendedStyle($hWnd)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Return _SendMessage($hWnd, $CBEM_GETEXTENDEDSTYLE)
EndFunc   ;==>_GUICtrlComboBoxEx_GetExtendedStyle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetExtendedUI
; Description ...: Determines whether a ComboBox has the default user interface or the extended user interface
; Syntax.........: _GUICtrlComboBoxEx_GetExtendedUI($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: True         - ComboBox has the extended user interface
;                  False        - ComboBox does "NOT" have the extended user interface
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: By default, the F4 key opens or closes the list and the DOWN ARROW changes the current selection.
;+
;                  In a ComboBox with the extended user interface, the F4 key is disabled and pressing the DOWN ARROW
;                  key opens the drop-down list
; Related .......: _GUICtrlComboBoxEx_SetExtendedUI
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetExtendedUI($hWnd)
	Return _GUICtrlComboBox_GetExtendedUI($hWnd)
EndFunc   ;==>_GUICtrlComboBoxEx_GetExtendedUI

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetImageList
; Description ...: Retrieves the handle to an image list assigned to a ComboBoxEx control
; Syntax.........: _GUICtrlComboBoxEx_GetImageList($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The handle to the image list
;                  Failure      - 0
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_SetImageList
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetImageList($hWnd)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Return Ptr(_SendMessage($hWnd, $CBEM_GETIMAGELIST))
EndFunc   ;==>_GUICtrlComboBoxEx_GetImageList

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetItem
; Description ...: Retrieves an item's attributes
; Syntax.........: _GUICtrlComboBoxEx_GetItem($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Array with the following format:
;                  |[0] - Item text
;                  |[1] - Length of Item text
;                  |[2] - Number of image widths to indent the item
;                  |[3] - Zero based item image index
;                  |[4] - Zero based item state image index
;                  |[5] - Zero based item image overlay index
;                  |[6] - Item application defined value
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_SetItem, _GUICtrlComboBoxEx_GetItemEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetItem($hWnd, $iIndex)
	Local $aItem[7], $sText

	Local $tItem = DllStructCreate($tagCOMBOBOXEXITEM)
	DllStructSetData($tItem, "Mask", BitOR($CBEIF_IMAGE, $CBEIF_INDENT, $CBEIF_LPARAM, $CBEIF_SELECTEDIMAGE, $CBEIF_OVERLAY))
	DllStructSetData($tItem, "Item", $iIndex)
	_GUICtrlComboBoxEx_GetItemEx($hWnd, $tItem)
	Local $iLen = _GUICtrlComboBoxEx_GetItemText($hWnd, $iIndex, $sText)
	$aItem[0] = $sText
	$aItem[1] = $iLen
	$aItem[2] = DllStructGetData($tItem, "Indent")
	$aItem[3] = DllStructGetData($tItem, "Image")
	$aItem[4] = DllStructGetData($tItem, "SelectedImage")
	$aItem[5] = DllStructGetData($tItem, "OverlayImage")
	$aItem[6] = DllStructGetData($tItem, "Param")
	Return $aItem
EndFunc   ;==>_GUICtrlComboBoxEx_GetItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetItemEx
; Description ...: Retrieves some or all of an item's attributes
; Syntax.........: _GUICtrlComboBoxEx_GetItemEx($hWnd, ByRef $tItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $tItem       - $tagCOMBOBOXEXITEM structure that specifies the information to retrieve
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_GetItem, _GUICtrlComboBoxEx_SetItemEx, $tagCOMBOBOXEXITEM
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetItemEx($hWnd, ByRef $tItem)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlComboBoxEx_GetUnicode($hWnd)

	Local $iRet
	If _WinAPI_InProcess($hWnd, $_ghCBExLastWnd) Then
		$iRet = _SendMessage($hWnd, $CBEM_GETITEMW, 0, $tItem, 0, "wparam", "struct*")
	Else
		Local $iItem = DllStructGetSize($tItem)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iItem, $tMemMap)
		_MemWrite($tMemMap, $tItem)
		If $fUnicode Then
			$iRet = _SendMessage($hWnd, $CBEM_GETITEMW, 0, $pMemory, 0, "wparam", "ptr")
		Else
			$iRet = _SendMessage($hWnd, $CBEM_GETITEMA, 0, $pMemory, 0, "wparam", "ptr")
		EndIf
		_MemRead($tMemMap, $pMemory, $tItem, $iItem)
		_MemFree($tMemMap)
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlComboBoxEx_GetItemEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetItemHeight
; Description ...: Determines the height of list items or the selection field in a ComboBox
; Syntax.........: _GUICtrlComboBoxEx_GetItemHeight($hWnd, $iComponent = -1)
; Parameters ....: $hWnd        - Handle to control
;                  $iComponent  - Use the following values:
;                  |–1          - Get the height of the selection field
;                  | 0          - Get the height of list items
; Return values .: Success      - The height, in pixels
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_SetItemHeight
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetItemHeight($hWnd, $iComponent = -1)
	Return _GUICtrlComboBox_GetItemHeight($hWnd, $iComponent)
EndFunc   ;==>_GUICtrlComboBoxEx_GetItemHeight

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetItemImage
; Description ...: Retrieves the index of the item's icon
; Syntax.........: _GUICtrlComboBoxEx_GetItemImage($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Zero based item image index
;                  Failue       - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_SetItemImage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetItemImage($hWnd, $iIndex)
	Local $tItem = DllStructCreate($tagCOMBOBOXEXITEM)
	DllStructSetData($tItem, "Mask", $CBEIF_IMAGE)
	DllStructSetData($tItem, "Item", $iIndex)
	_GUICtrlComboBoxEx_GetItemEx($hWnd, $tItem)
	Return DllStructGetData($tItem, "Image")
EndFunc   ;==>_GUICtrlComboBoxEx_GetItemImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetItemIndent
; Description ...: Retrieves the number of image widths the item is indented
; Syntax.........: _GUICtrlComboBoxEx_GetItemIndent($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Item indention
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_SetItemIndent
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetItemIndent($hWnd, $iIndex)
	Local $tItem = DllStructCreate($tagCOMBOBOXEXITEM)
	DllStructSetData($tItem, "Mask", $CBEIF_INDENT)
	DllStructSetData($tItem, "Item", $iIndex)
	_GUICtrlComboBoxEx_GetItemEx($hWnd, $tItem)
	Return DllStructGetData($tItem, "Indent")
EndFunc   ;==>_GUICtrlComboBoxEx_GetItemIndent

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetItemOverlayImage
; Description ...: Retrieves the index of the item's overlay image icon
; Syntax.........: _GUICtrlComboBoxEx_GetItemOverlayImage($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Zero based item overlay image index
;                  Failue       - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_SetItemOverlayImage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetItemOverlayImage($hWnd, $iIndex)
	Local $tItem = DllStructCreate($tagCOMBOBOXEXITEM)
	DllStructSetData($tItem, "Mask", $CBEIF_OVERLAY)
	DllStructSetData($tItem, "Item", $iIndex)
	_GUICtrlComboBoxEx_GetItemEx($hWnd, $tItem)
	Return DllStructGetData($tItem, "OverlayImage")
EndFunc   ;==>_GUICtrlComboBoxEx_GetItemOverlayImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetItemParam
; Description ...: Retrieves the application specific value of the item
; Syntax.........: _GUICtrlComboBoxEx_GetItemParam($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Application specific value
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_SetItemParam
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetItemParam($hWnd, $iIndex)
	Local $tItem = DllStructCreate($tagCOMBOBOXEXITEM)
	DllStructSetData($tItem, "Mask", $CBEIF_LPARAM)
	DllStructSetData($tItem, "Item", $iIndex)
	_GUICtrlComboBoxEx_GetItemEx($hWnd, $tItem)
	Return DllStructGetData($tItem, "Param")
EndFunc   ;==>_GUICtrlComboBoxEx_GetItemParam

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetItemSelectedImage
; Description ...: Retrieves the index of the item's selected image icon
; Syntax.........: _GUICtrlComboBoxEx_GetItemSelectedImage($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Zero based item selected image index
;                  Failue       - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_SetItemSelectedImage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetItemSelectedImage($hWnd, $iIndex)
	Local $tItem = DllStructCreate($tagCOMBOBOXEXITEM)
	DllStructSetData($tItem, "Mask", $CBEIF_SELECTEDIMAGE)
	DllStructSetData($tItem, "Item", $iIndex)
	_GUICtrlComboBoxEx_GetItemEx($hWnd, $tItem)
	Return DllStructGetData($tItem, "SelectedImage")
EndFunc   ;==>_GUICtrlComboBoxEx_GetItemSelectedImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetItemText
; Description ...: Retrieve a string from the list of a ComboBox
; Syntax.........: _GUICtrlComboBoxEx_GetItemText($hWnd, $iIndex, ByRef $sText)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based index to Retrieve from
;                  $sText       - Variable that will receive the string
; Return values .: Success      - The length of the string
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetItemText($hWnd, $iIndex, ByRef $sText)
	Return _GUICtrlComboBox_GetLBText($hWnd, $iIndex, $sText)
EndFunc   ;==>_GUICtrlComboBoxEx_GetItemText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetItemTextLen
; Description ...: Gets the length, in characters, of a string in the list of a combo box
; Syntax.........: _GUICtrlComboBoxEx_GetItemTextLen($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
; Return values .: Success      - The length of the string
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetItemTextLen($hWnd, $iIndex)
	Return _GUICtrlComboBox_GetLBTextLen($hWnd, $iIndex)
EndFunc   ;==>_GUICtrlComboBoxEx_GetItemTextLen

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetList
; Description ...: Retrieves all items from the list portion of a ComboBox control
; Syntax.........: _GUICtrlComboBoxEx_GetList($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - Delimited string of all ComboBox items
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Default delimiter is "|" this can be change using the Opt("GUIDataSeparatorChar", "new delimiter")
; Related .......: _GUICtrlComboBoxEx_GetListArray
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetList($hWnd)
	Return _GUICtrlComboBox_GetList($hWnd)
EndFunc   ;==>_GUICtrlComboBoxEx_GetList

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetListArray
; Description ...: Retrieves all items from the list portion of a ComboBox control
; Syntax.........: _GUICtrlComboBoxEx_GetListArray($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - Array in the following format:
;                  |[0]         - Number of items
;                  |[1]         - Item 1
;                  |[2]         - Item 2
;                  |[n]         - Item n
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_GetList
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetListArray($hWnd)
	Local $sDelimiter = Opt("GUIDataSeparatorChar")
	Return StringSplit(_GUICtrlComboBoxEx_GetList($hWnd), $sDelimiter)
EndFunc   ;==>_GUICtrlComboBoxEx_GetListArray

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetLocale
; Description ...: Retrieves the current locale
; Syntax.........: _GUICtrlComboBoxEx_GetLocale($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - The high order word contains the country code and the low order word contains the language identifier.
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_GetLocaleCountry, _GUICtrlComboBoxEx_GetLocaleLang, _GUICtrlComboBoxEx_GetLocalePrimLang, _GUICtrlComboBoxEx_GetLocaleSubLang
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetLocale($hWnd)
	Local $hCombo = _GUICtrlComboBoxEx_GetComboControl($hWnd)
	Return _GUICtrlComboBox_GetLocale($hCombo)
EndFunc   ;==>_GUICtrlComboBoxEx_GetLocale

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetLocaleCountry
; Description ...: Retrieves the current country code
; Syntax.........: _GUICtrlComboBoxEx_GetLocaleCountry($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - The country code of the ComboBox
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_GetLocale
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetLocaleCountry($hWnd)
	Return _WinAPI_HiWord(_GUICtrlComboBoxEx_GetLocale($hWnd))
EndFunc   ;==>_GUICtrlComboBoxEx_GetLocaleCountry

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetLocaleLang
; Description ...: Retrieves the current language identifier
; Syntax.........: _GUICtrlComboBoxEx_GetLocaleLang($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - The language code of the ComboBox
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_GetLocale
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetLocaleLang($hWnd)
	Return _WinAPI_LoWord(_GUICtrlComboBoxEx_GetLocale($hWnd))
EndFunc   ;==>_GUICtrlComboBoxEx_GetLocaleLang

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetLocalePrimLang
; Description ...: Extract primary language id from a language id
; Syntax.........: _GUICtrlComboBoxEx_GetLocalePrimLang($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - Primary language id
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_GetLocale
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetLocalePrimLang($hWnd)
	Return _WinAPI_PrimaryLangId(_GUICtrlComboBoxEx_GetLocaleLang($hWnd))
EndFunc   ;==>_GUICtrlComboBoxEx_GetLocalePrimLang

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetLocaleSubLang
; Description ...: Extract sublanguage id from a language id
; Syntax.........: _GUICtrlComboBoxEx_GetLocaleSubLang($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - Sub-Language id
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_GetLocale
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetLocaleSubLang($hWnd)
	Return _WinAPI_SubLangId(_GUICtrlComboBoxEx_GetLocaleLang($hWnd))
EndFunc   ;==>_GUICtrlComboBoxEx_GetLocaleSubLang

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetMinVisible
; Description ...: Retrieve the minimum number of visible items in the drop-down list of a ComboBox
; Syntax.........: _GUICtrlComboBoxEx_GetMinVisible($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: When the number of items in the drop-down list is greater than the minimum, the combo box uses a scrollbar.
;+
;                  This Function is ignored if the ComboBox control has style $CBS_NOINTEGRALHEIGHT
; Related .......: _GUICtrlComboBoxEx_SetMinVisible
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetMinVisible($hWnd)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Local $hCombo = _GUICtrlComboBoxEx_GetComboControl($hWnd)
	Return _GUICtrlComboBox_GetMinVisible($hCombo)
EndFunc   ;==>_GUICtrlComboBoxEx_GetMinVisible

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetTopIndex
; Description ...: Retrieve the zero-based index of the first visible item in the ListBox portion of a ComboBox
; Syntax.........: _GUICtrlComboBoxEx_GetTopIndex($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - The index of the first visible item in the ListBox of the ComboBox
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_SetTopIndex
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetTopIndex($hWnd)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Local $hCombo = _GUICtrlComboBoxEx_GetComboControl($hWnd)
	Return _GUICtrlComboBox_GetTopIndex($hCombo)
EndFunc   ;==>_GUICtrlComboBoxEx_GetTopIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_GetUnicode
; Description ...: Retrieves if control is using Unicode
; Syntax.........: _GUICtrlComboBoxEx_GetUnicode($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: True    - Using Unicode
;                  False   - Not using Unicode
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_SetUnicode
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_GetUnicode($hWnd)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Return _SendMessage($hWnd, $CBEM_GETUNICODEFORMAT) <> 0
EndFunc   ;==>_GUICtrlComboBoxEx_GetUnicode

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlComboBoxEx_HasEditChanged
; Description ...: Determines whether the user has changed the text of a ComboBoxEx edit control
; Syntax.........: _GUICtrlComboBoxEx_HasEditChanged($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: True         - Text in the control's edit box has changed
;                  False        - No change
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_HasEditChanged($hWnd)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Local $tInfo
	If _GUICtrlComboBoxEx_GetComboBoxInfo($hWnd, $tInfo) Then
		Local $hEdit = DllStructGetData($tInfo, "hEdit")
		Return _SendMessage($hEdit, $CBEM_HASEDITCHANGED) <> 0
	Else
		Return False
	EndIf
EndFunc   ;==>_GUICtrlComboBoxEx_HasEditChanged

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_InitStorage
; Description ...: Allocates memory for storing ListBox items
; Syntax.........: _GUICtrlComboBoxEx_InitStorage($hWnd, $iNum, $iBytes)
; Parameters ....: $hWnd        - Handle to control
;                  $iNum        - Number of items to add
;                  $iBytes      - The amount of memory to allocate for item strings, in bytes
; Return values .: Success      - The total number of items for which memory has been pre-allocated
;                  Failure      - $CB_ERRSPACE
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Helps speed up the initialization of ComboBoxes that have a large number of items (over 100).
;+
;                  You can use estimates for the $iNum and $iBytes parameters.
;                  If you overestimate, the extra memory is allocated.
;                  If you underestimate, the normal allocation is used for items that exceed the requested amount.
; Related .......: _GUICtrlComboBoxEx_AddDir, _GUICtrlComboBoxEx_AddString, _GUICtrlComboBoxEx_InsertString
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_InitStorage($hWnd, $iNum, $iBytes)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Local $hCombo = _GUICtrlComboBoxEx_GetComboControl($hWnd)
	Return _GUICtrlComboBox_InitStorage($hCombo, $iNum, $iBytes)
EndFunc   ;==>_GUICtrlComboBoxEx_InitStorage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_InsertString
; Description ...: Inserts a new item in the control
; Syntax.........: _GUICtrlComboBoxEx_InsertString($hWnd, $sText[, $iIndex = 0[, $iImage = -1[, $iSelecteImage = -1[, $iOverlayImage = -1[, $iIndent = -1[, $iParam = -1]]]]]])
; Parameters ....: $hWnd          - Handle to the control
;                  $sText         - Item text. If set to -1, the item set is set via the $CBEN_GETDISPINFO notification message.
;                  $iIndex        - Zero based index at which the new string should be inserted.
;                  +To insert an item at the end of the list, set the $iIndex member to -1
;                  $iImage        - Zero based index of the item's icon in the control's image list
;                  $iSelecteImage - Zero based index of the item's icon in the control's image list
;                  $iOverlayImage - Zero based index of the item's icon in the control's image list
;                  $iIndent       - Number of image widths to indent the item. A single indentation equals the width of an image.
;                  $iParam        - Value specific to the item
; Return values .: Success        - The index of the new item
;                  Failure        - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_InitStorage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_InsertString($hWnd, $sText, $iIndex = -1, $iImage = -1, $iSelecteImage = -1, $iOverlayImage = -1, $iIndent = -1, $iParam = -1)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Local $iBuffer = 0, $iMask, $iRet
	Local $fUnicode = _GUICtrlComboBoxEx_GetUnicode($hWnd)

	Local $tItem = DllStructCreate($tagCOMBOBOXEXITEM)
	If $sText <> -1 Then
		$iMask = BitOR($CBEIF_TEXT, $CBEIF_LPARAM)
		$iBuffer = StringLen($sText) + 1
		Local $tBuffer
		If $fUnicode Then
			$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
			$iBuffer *= 2
		Else
			$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
		EndIf
		DllStructSetData($tBuffer, "Text", $sText)
		DllStructSetData($tItem, "Text", DllStructGetPtr($tBuffer))
		DllStructSetData($tItem, "TextMax", $iBuffer)
	Else
		$iMask = BitOR($CBEIF_DI_SETITEM, $CBEIF_LPARAM)
	EndIf
	If $iImage >= 0 Then $iMask = BitOR($iMask, $CBEIF_IMAGE)
	If $iSelecteImage >= 0 Then $iMask = BitOR($iMask, $CBEIF_SELECTEDIMAGE)
	If $iOverlayImage >= 0 Then $iMask = BitOR($iMask, $CBEIF_OVERLAY)
	If $iIndent >= 1 Then $iMask = BitOR($iMask, $CBEIF_INDENT)
	If $iParam = -1 Then $iParam = _GUICtrlComboBoxEx_GetCount($hWnd)
	DllStructSetData($tItem, "Mask", $iMask)
	DllStructSetData($tItem, "Item", $iIndex)
	DllStructSetData($tItem, "Image", $iImage)
	DllStructSetData($tItem, "SelectedImage", $iSelecteImage)
	DllStructSetData($tItem, "OverlayImage", $iOverlayImage)
	DllStructSetData($tItem, "Indent", $iIndent)
	DllStructSetData($tItem, "Param", $iParam)
	If _WinAPI_InProcess($hWnd, $_ghCBExLastWnd) Or ($sText = -1) Then
		$iRet = _SendMessage($hWnd, $CBEM_INSERTITEMW, 0, $tItem, 0, "wparam", "struct*")
	Else
		Local $iItem = DllStructGetSize($tItem)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iItem + $iBuffer, $tMemMap)
		Local $pText = $pMemory + $iItem
		DllStructSetData($tItem, "Text", $pText)
		_MemWrite($tMemMap, $tItem, $pMemory, $iItem)
		_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
		If $fUnicode Then
			$iRet = _SendMessage($hWnd, $CBEM_INSERTITEMW, 0, $pMemory, 0, "wparam", "ptr")
		Else
			$iRet = _SendMessage($hWnd, $CBEM_INSERTITEMA, 0, $pMemory, 0, "wparam", "ptr")
		EndIf
		_MemFree($tMemMap)
	EndIf
	Return $iRet
EndFunc   ;==>_GUICtrlComboBoxEx_InsertString

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_LimitText
; Description ...: Limits the length of the text the user may type into the edit control of a ComboBox
; Syntax.........: _GUICtrlComboBoxEx_LimitText($hWnd[, $iLimit = 0])
; Parameters ....: $hWnd        - Handle to control
;                  $iLimit      - Limit length of the text
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If the $iLimit parameter is zero, the text length is limited to 0x7FFFFFFE characters.
;+
;                  If the ComboBox does not have the $CBS_AUTOHSCROLL style, setting the text limit to
;                  be larger than the size of the edit control has no effect.
;+
;                  The _GUICtrlComboBox_LimitText function limits only the text the user can enter.
;                  It has no effect on any text already in the edit control when the message is sent,
;                  nor does it affect the length of the text copied to the edit control when a string
;                  in the ListBox is selected.
;+
;                  The default limit to the text a user can enter in the edit control is 30,000 characters
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_LimitText($hWnd, $iLimit = 0)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	_SendMessage($hWnd, $CB_LIMITTEXT, $iLimit)
EndFunc   ;==>_GUICtrlComboBoxEx_LimitText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_ReplaceEditSel
; Description ...: Replace text selected in edit box
; Syntax.........: _GUICtrlComboBoxEx_ReplaceEditSel($hWnd, $sText)
; Parameters ....: $hWnd        - Handle to control
;                  $sText       - String containing the replacement text
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If the message is sent to a ComboBox with the $CBS_DROPDOWN or $CBS_DROPDOWNLIST style the Function will fail.
; Related .......: _GUICtrlComboBoxEx_SetEditText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_ReplaceEditSel($hWnd, $sText)
	Local $hCombo = _GUICtrlComboBoxEx_GetComboControl($hWnd)
	_GUICtrlComboBox_ReplaceEditSel($hCombo, $sText)
EndFunc   ;==>_GUICtrlComboBoxEx_ReplaceEditSel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_ResetContent
; Description ...: Removes all items
; Syntax.........: _GUICtrlComboBoxEx_ResetContent($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_ResetContent($hWnd)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	_SendMessage($hWnd, $CB_RESETCONTENT)
EndFunc   ;==>_GUICtrlComboBoxEx_ResetContent

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_SetCurSel
; Description ...: Select a string in the list of a ComboBox
; Syntax.........: _GUICtrlComboBoxEx_SetCurSel($hWnd[, $iIndex = -1])
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Specifies the zero-based index of the string to select
; Return values .: Success      - The index of the item selected
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If $iIndex is –1, any current selection in the list is removed and the edit control is cleared.
;+
;                  If $iIndex is greater than the number of items in the list or if $iIndex is –1, the return value
;                  is -1 and the selection is cleared.
; Related .......: _GUICtrlComboBoxEx_GetCurSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_SetCurSel($hWnd, $iIndex = -1)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Return _SendMessage($hWnd, $CB_SETCURSEL, $iIndex)
EndFunc   ;==>_GUICtrlComboBoxEx_SetCurSel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_SetDroppedWidth
; Description ...: Set the maximum allowable width, in pixels, of the ListBox of a ComboBox
; Syntax.........: _GUICtrlComboBoxEx_SetDroppedWidth($hWnd, $iWidth)
; Parameters ....: $hWnd        - Handle to control
;                  $iWidth      - The width of the ListBox, in pixels
; Return values .: Success      - The new width of the ListBox
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: By default, the minimum allowable width of the drop-down ListBox is zero.
;                  The width of the ListBox is either the minimum allowable width or the ComboBox width, whichever is larger.
;+
;                  Use $CBS_DROPDOWN or $CBS_DROPDOWNLIST style.
; Related .......: _GUICtrlComboBoxEx_GetDroppedWidth
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_SetDroppedWidth($hWnd, $iWidth)
	Local $hCombo = _GUICtrlComboBoxEx_GetComboControl($hWnd)
	Return _GUICtrlComboBox_SetDroppedWidth($hCombo, $iWidth)
EndFunc   ;==>_GUICtrlComboBoxEx_SetDroppedWidth

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_SetEditSel
; Description ...: Select characters in the edit control of a ComboBox
; Syntax.........: _GUICtrlComboBoxEx_SetEditSel($hWnd, $iStart, $iStop)
; Parameters ....: $hWnd        - Handle to control
;                  $iStart      - Starting position
;                  $iStop       - Ending postions
; Return values .: Success      - True
;                  Failure      - False If the message is sent to a ComboBox with the $CBS_DROPDOWN or $CBS_DROPDOWNLIST style
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The positions are zero-based. The first character of the edit control is in the zero position.
;                  If $iStop is –1, all text from the starting position to the last character in the edit control is selected.
;+
;                  The first character after the last selected character is in the ending position.
;+
;                  For example, to select the first four characters of the edit control, use a starting position
;                  of 0 and an ending position of 4.
; Related .......: _GUICtrlComboBox_GetEditSel, _GUICtrlComboBoxEx_GetEditSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_SetEditSel($hWnd, $iStart, $iStop)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Local $hCombo = _GUICtrlComboBoxEx_GetComboControl($hWnd)
	Return _GUICtrlComboBox_SetEditSel($hCombo, $iStart, $iStop)
EndFunc   ;==>_GUICtrlComboBoxEx_SetEditSel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_SetEditText
; Description ...: Set the text of the edit control of the ComboBox
; Syntax.........: _GUICtrlComboBoxEx_SetEditText($hWnd, $sText)
; Parameters ....: $hWnd        - Handle to control
;                  $sText       - Text to be set
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If the message is sent to a ComboBox with the $CBS_DROPDOWN or $CBS_DROPDOWNLIST style the Function will fail.
; Related .......: _GUICtrlComboBox_GetEditText, _GUICtrlComboBoxEx_GetEditText, _GUICtrlComboBoxEx_ReplaceEditSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_SetEditText($hWnd, $sText)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Local $hComboBox = _GUICtrlComboBoxEx_GetComboControl($hWnd)
	_GUICtrlComboBox_SetEditSel($hComboBox, 0, -1)
	_GUICtrlComboBox_ReplaceEditSel($hComboBox, $sText)
EndFunc   ;==>_GUICtrlComboBoxEx_SetEditText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_SetExtendedStyle
; Description ...: Sets extended styles within a ComboBoxEx control
; Syntax.........: _GUICtrlComboBoxEx_SetExtendedStyle($hWnd, $iExStyle[, $iExMask = 0])
; Parameters ....: $hWnd        - Handle to the control
;                  $iExStyle    - Extended control styles:
;                  |$CBES_EX_CASESENSITIVE     - Searches in the list will be case sensitive
;                  |$CBES_EX_NOEDITIMAGE       - The edit box and the dropdown list will not display item images
;                  |$CBES_EX_NOEDITIMAGEINDENT - The edit box and the dropdown list will not display item images
;                  |$CBES_EX_NOSIZELIMIT       - Allows the ComboBoxEx control to be vertically sized smaller than its contained combo box control
;                  |$CBES_EX_PATHWORDBREAKPROC - Microsoft Windows NT only.
;                  +The edit box will use the slash (/), backslash (\), and period (.) characters as word delimiters
;                  $iExMask     - Specifies which styles in $iExStyle are to be affected.  This parameter can be a combination of
;                  +extended styles. Only the extended styles in $iExMask will be changed. All other styles will be maintained as
;                  +they are. If this parameter is zero, all of the styles in $iExStyle will be affected.
; Return values .: Success      - The previous extended styles
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_GetExtendedStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_SetExtendedStyle($hWnd, $iExStyle, $iExMask = 0)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Local $iRet = _SendMessage($hWnd, $CBEM_SETEXTENDEDSTYLE, $iExMask, $iExStyle)
	_WinAPI_InvalidateRect($hWnd)
	Return $iRet
EndFunc   ;==>_GUICtrlComboBoxEx_SetExtendedStyle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_SetExtendedUI
; Description ...: Select either the default user interface or the extended user interface
; Syntax.........: _GUICtrlComboBoxEx_SetExtendedUI($hWnd[, $fExtended = False])
; Parameters ....: $hWnd        - Handle to control
;                  $fExtended   - Specifies whether the combo box uses the extended
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: By default, the F4 key opens or closes the list and the DOWN ARROW changes the current selection.
;+
;                  In a ComboBox with the extended user interface, the F4 key is disabled and pressing the DOWN ARROW
;                  key opens the drop-down list
; Related .......: _GUICtrlComboBoxEx_GetExtendedUI
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_SetExtendedUI($hWnd, $fExtended = False)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Local $hComboBox = _GUICtrlComboBoxEx_GetComboControl($hWnd)
	Return _SendMessage($hComboBox, $CB_SETEXTENDEDUI, $fExtended) = 0
EndFunc   ;==>_GUICtrlComboBoxEx_SetExtendedUI

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_SetImageList
; Description ...: Sets an image list for a ComboBoxEx control
; Syntax.........: _GUICtrlComboBoxEx_SetImageList($hWnd, $hHandle)
; Parameters ....: $hWnd        - Handle to the control
;                  $hHandle     - A handle to the image list to be set for the control
; Return values .: Success      - handle to the image list previously associated with the control,
;                  +or returns NULL if no image list was previously set
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_GetImageList
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_SetImageList($hWnd, $hHandle)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Local $hResult = _SendMessage($hWnd, $CBEM_SETIMAGELIST, 0, $hHandle, 0, "wparam", "handle", "handle")
	_SendMessage($hWnd, $__COMBOBOXEXCONSTANT_WM_SIZE)
	Return $hResult
EndFunc   ;==>_GUICtrlComboBoxEx_SetImageList

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_SetItem
; Description ...: Sets some or all of a item's attributes
; Syntax.........: _GUICtrlComboBoxEx_SetItem($hWnd, $sText[, $iIndex = 0[, $iImage = -1[, $iSelectedImage = -1[, $iOverlayImage = -1[, $iIndent = -1[, $iParam = -1]]]]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $sText       - Item text
;                  $iIndex      - The zero-based index of the item
;                  $iImage        - Zero based index of the item's icon in the control's image list
;                  $iSelectedImage - Zero based index of the item's icon in the control's image list
;                  $iOverlayImage - Zero based index of the item's icon in the control's image list
;                  $iIndent       - Number of image widths to indent the item. A single indentation equals the width of an image.
;                  $iParam        - Value specific to the item
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_GetItem, _GUICtrlComboBoxEx_SetItemEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_SetItem($hWnd, $sText, $iIndex = 0, $iImage = -1, $iSelectedImage = -1, $iOverlayImage = -1, $iIndent = -1, $iParam = -1)
	Local $iBuffer = StringLen($sText) + 1
	Local $tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
	Local $pBuffer = DllStructGetPtr($tBuffer)
	Local $tItem = DllStructCreate($tagCOMBOBOXEXITEM)
	Local $iMask = $CBEIF_TEXT
	If $iImage <> -1 Then $iMask = BitOR($iMask, $CBEIF_IMAGE)
	If $iSelectedImage <> -1 Then $iMask = BitOR($iMask, $CBEIF_SELECTEDIMAGE)
	If $iOverlayImage <> -1 Then $iMask = BitOR($iMask, $CBEIF_OVERLAY)
	If $iParam <> -1 Then $iMask = BitOR($iMask, $CBEIF_LPARAM)
	If $iIndent <> -1 Then $iMask = BitOR($iMask, $CBEIF_INDENT)
	DllStructSetData($tBuffer, "Text", $sText)
	DllStructSetData($tItem, "Mask", $iMask)
	DllStructSetData($tItem, "Item", $iIndex)
	DllStructSetData($tItem, "Text", $pBuffer)
	DllStructSetData($tItem, "TextMax", $iBuffer * 2)
	DllStructSetData($tItem, "Image", $iImage)
	DllStructSetData($tItem, "Param", $iParam)
	DllStructSetData($tItem, "Indent", $iIndent)
	DllStructSetData($tItem, "SelectedImage", $iSelectedImage)
	DllStructSetData($tItem, "OverlayImage", $iOverlayImage)
	Return _GUICtrlComboBoxEx_SetItemEx($hWnd, $tItem)
EndFunc   ;==>_GUICtrlComboBoxEx_SetItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_SetItemEx
; Description ...: Sets some or all of a item's attributes
; Syntax.........: _GUICtrlComboBoxEx_SetItemEx($hWnd, ByRef $tItem)
; Parameters ....: $hWnd  - Handle to the control
;                  $tItem       - $tagCOMBOBOXEXITEM structure
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: To set the attributes of an item set the Item member of the $tagCOMBOBOXEXITEM structure to the index of the item.
;                  For an item, you can set the Image, SelectedImage, OverlayImage, Ident, and Param members of the
;                  $tagCOMBOBOXEXITEM structure.
; Related .......: _GUICtrlComboBoxEx_GetItemEx, _GUICtrlComboBoxEx_SetItem, $tagCOMBOBOXEXITEM
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_SetItemEx($hWnd, ByRef $tItem)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Local $iItem = DllStructGetSize($tItem)
	Local $iBuffer = DllStructGetData($tItem, "TextMax")
	If $iBuffer = 0 Then $iBuffer = 1
	Local $pBuffer = DllStructGetData($tItem, "Text")
	Local $tMemMap
	Local $pMemory = _MemInit($hWnd, $iItem + $iBuffer, $tMemMap)
	Local $pText = $pMemory + $iItem
	DllStructSetData($tItem, "Text", $pText)
	_MemWrite($tMemMap, $tItem, $pMemory, $iItem)
	If $pBuffer <> 0 Then _MemWrite($tMemMap, $pBuffer, $pText, $iBuffer)
	Local $iRet = _SendMessage($hWnd, $CBEM_SETITEMW, 0, $pMemory, 0, "wparam", "ptr")
	_MemFree($tMemMap)

	Return $iRet <> 0
EndFunc   ;==>_GUICtrlComboBoxEx_SetItemEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_SetItemHeight
; Description ...: Set the height of list items or the selection field in a ComboBox
; Syntax.........: _GUICtrlComboBoxEx_SetItemHeight($hWnd, $iComponent, $iHeight)
; Parameters ....: $hWnd        - Handle to control
;                  $iComponent  - Use the following values:
;                  |–1          - Set the height of the selection field
;                  | 0          - Set the height of list items
;                  $iHeight     - The height, in pixels, of the combo box component identified by $iComponent
; Return values .: Failure      - If height is invalid, the return value is -1.
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_GetItemHeight
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_SetItemHeight($hWnd, $iComponent, $iHeight)
	Return _SendMessage($hWnd, $CB_SETITEMHEIGHT, $iComponent, $iHeight)
EndFunc   ;==>_GUICtrlComboBoxEx_SetItemHeight

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_SetItemImage
; Description ...: Sets the index of the item's icon in the control's image list
; Syntax.........: _GUICtrlComboBoxEx_SetItemImage($hWnd, $iIndex, $iImage)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $iImage      - Zero based index into the control's image list
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_GetItemImage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_SetItemImage($hWnd, $iIndex, $iImage)
	Local $tItem = DllStructCreate($tagCOMBOBOXEXITEM)
	DllStructSetData($tItem, "Mask", $CBEIF_IMAGE)
	DllStructSetData($tItem, "Item", $iIndex)
	DllStructSetData($tItem, "Image", $iImage)
	Return _GUICtrlComboBoxEx_SetItemEx($hWnd, $tItem)
EndFunc   ;==>_GUICtrlComboBoxEx_SetItemImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_SetItemIndent
; Description ...: Sets the number of image widths to indent the item
; Syntax.........: _GUICtrlComboBoxEx_SetItemIndent($hWnd, $iIndex, $iIndent)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $iIndent     - Indention value
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_GetItemIndent
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_SetItemIndent($hWnd, $iIndex, $iIndent)
	Local $tItem = DllStructCreate($tagCOMBOBOXEXITEM)
	DllStructSetData($tItem, "Mask", $CBEIF_INDENT)
	DllStructSetData($tItem, "Item", $iIndex)
	DllStructSetData($tItem, "Indent", $iIndent)
	Return _GUICtrlComboBoxEx_SetItemEx($hWnd, $tItem)
EndFunc   ;==>_GUICtrlComboBoxEx_SetItemIndent

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_SetItemOverlayImage
; Description ...: Sets the index of the item's overlay icon in the control's image list
; Syntax.........: _GUICtrlComboBoxEx_SetItemOverlayImage($hWnd, $iIndex, $iImage)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $iImage      - Zero based index into the control's image list
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_GetItemOverlayImage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_SetItemOverlayImage($hWnd, $iIndex, $iImage)
	Local $tItem = DllStructCreate($tagCOMBOBOXEXITEM)
	DllStructSetData($tItem, "Mask", $CBEIF_OVERLAY)
	DllStructSetData($tItem, "Item", $iIndex)
	DllStructSetData($tItem, "OverlayImage", $iImage)
	Return _GUICtrlComboBoxEx_SetItemEx($hWnd, $tItem)
EndFunc   ;==>_GUICtrlComboBoxEx_SetItemOverlayImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_SetItemParam
; Description ...: Sets the value specific to the item
; Syntax.........: _GUICtrlComboBoxEx_SetItemParam($hWnd, $iIndex, $iParam)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $iParam      - Item specific value
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_GetItemParam
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_SetItemParam($hWnd, $iIndex, $iParam)
	Local $tItem = DllStructCreate($tagCOMBOBOXEXITEM)
	DllStructSetData($tItem, "Mask", $CBEIF_LPARAM)
	DllStructSetData($tItem, "Item", $iIndex)
	DllStructSetData($tItem, "Param", $iParam)
	Return _GUICtrlComboBoxEx_SetItemEx($hWnd, $tItem)
EndFunc   ;==>_GUICtrlComboBoxEx_SetItemParam

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_SetItemSelectedImage
; Description ...: Sets the index of the item's overlay icon in the control's image list
; Syntax.........: _GUICtrlComboBoxEx_SetItemSelectedImage($hWnd, $iIndex, $iImage)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $iImage      - Zero based index into the control's image list
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_GetItemSelectedImage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_SetItemSelectedImage($hWnd, $iIndex, $iImage)
	Local $tItem = DllStructCreate($tagCOMBOBOXEXITEM)
	DllStructSetData($tItem, "Mask", $CBEIF_SELECTEDIMAGE)
	DllStructSetData($tItem, "Item", $iIndex)
	DllStructSetData($tItem, "SelectedImage", $iImage)
	Return _GUICtrlComboBoxEx_SetItemEx($hWnd, $tItem)
EndFunc   ;==>_GUICtrlComboBoxEx_SetItemSelectedImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_SetMinVisible
; Description ...: Set the minimum number of visible items in the drop-down list of a ComboBox
; Syntax.........: _GUICtrlComboBoxEx_SetMinVisible($hWnd, $iMinimum)
; Parameters ....: $hWnd        - Handle to control
;                  $iMinimum    - Specifies the minimum number of visible items
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: When the number of items in the drop-down list is greater than the minimum,
;                  the Combobbox uses a scrollbar. By default, 30 is the minimum number of visible items.
;+
;                  This message is ignored if the combo box control has style $CBS_NOINTEGRALHEIGHT.
; Related .......: _GUICtrlComboBoxEx_GetMinVisible
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_SetMinVisible($hWnd, $iMinimum)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Local $hCombo = _GUICtrlComboBoxEx_GetComboControl($hWnd)
	Return _GUICtrlComboBox_SetMinVisible($hCombo, $iMinimum)
EndFunc   ;==>_GUICtrlComboBoxEx_SetMinVisible

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_SetTopIndex
; Description ...: Ensure that a particular item is visible in the ListBox of a ComboBox
; Syntax.........: _GUICtrlComboBoxEx_SetTopIndex($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Specifies the zero-based index of the list item
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The system scrolls the ListBox contents so that either the specified item appears at the top
;                  of the list box or the maximum scroll range has been reached.
; Related .......: _GUICtrlComboBoxEx_GetTopIndex
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_SetTopIndex($hWnd, $iIndex)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Local $hCombo = _GUICtrlComboBoxEx_GetComboControl($hWnd)
	Return _GUICtrlComboBox_SetTopIndex($hCombo, $iIndex)
EndFunc   ;==>_GUICtrlComboBoxEx_SetTopIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_SetUnicode
; Description ...: Sets if control is using Unicode
; Syntax.........: _GUICtrlComboBoxEx_SetUnicode($hWnd[, $fUnicode = True])
; Parameters ....: $hWnd        - Handle to control
;                  $fUnicode    - May be one of the following
;                  |True - Turn on Unicode
;                  |False - Turn off Unicode
; Return values .: Success  - True
;                  Falure   - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlComboBoxEx_GetUnicode
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_SetUnicode($hWnd, $fUnicode = True)
	If $Debug_CB Then __UDF_ValidateClassName($hWnd, $__COMBOBOXEXCONSTANT_ClassName)

	Local $iUnicode = _SendMessage($hWnd, $CBEM_SETUNICODEFORMAT, $fUnicode) <> 0
	Return $iUnicode <> $fUnicode
EndFunc   ;==>_GUICtrlComboBoxEx_SetUnicode

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlComboBoxEx_ShowDropDown
; Description ...: Show or hide the ListBox of a ComboBox
; Syntax.........: _GUICtrlComboBoxEx_ShowDropDown($hWnd[, $fShow = False])
; Parameters ....: $hWnd        - Handle to control
;                  $fShow       - Specifies whether the drop-down ListBox is to be shown or hidden:
;                  | True       - Show ListBox
;                  |False       - Hide ListBox
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: This function has no effect on a ComboBox created with the $CBS_SIMPLE style.
; Related .......: _GUICtrlComboBoxEx_GetDroppedState
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlComboBoxEx_ShowDropDown($hWnd, $fShow = False)
	_GUICtrlComboBox_ShowDropDown($hWnd, $fShow)
EndFunc   ;==>_GUICtrlComboBoxEx_ShowDropDown
