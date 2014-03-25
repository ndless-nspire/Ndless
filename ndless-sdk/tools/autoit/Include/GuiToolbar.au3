#include-once

#include "ToolbarConstants.au3"
#include "Memory.au3"
#include "WinAPI.au3"
#include "StructureConstants.au3"
#include "SendMessage.au3"
#include "UDFGlobalID.au3"

; #INDEX# =======================================================================================================================
; Title .........: Toolbar
; AutoIt Version : 3.3.7.20++
; Language ......: English
; Description ...: Functions that assist with Toolbar control management.
;                  A toolbar is a control window that contains one or more buttons.  Each button, when clicked by a user, sends a
;                  command message to the parent window.  Typically, the  buttons  in  a  toolbar  correspond  to  items  in  the
;                  application's menu, providing an additional and more direct way  for  the  user  to  access  an  application's
;                  commands.
; Author(s) .....: Paul Campbell (PaulIA)
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $gh_TBLastWnd
Global $Debug_TB = False
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__TOOLBARCONSTANT_ClassName = "ToolbarWindow32"
Global Const $__TOOLBARCONSTANT_WS_CLIPSIBLINGS = 0x04000000
Global Const $__TOOLBARCONSTANT_LR_LOADFROMFILE = 0x0010
Global Const $__TOOLBARCONSTANT_HINST_COMMCTRL = -1
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_GUICtrlToolbar_AddBitmap
;_GUICtrlToolbar_AddButton
;_GUICtrlToolbar_AddButtonSep
;_GUICtrlToolbar_AddString
;_GUICtrlToolbar_ButtonCount
;_GUICtrlToolbar_CheckButton
;_GUICtrlToolbar_ClickAccel
;_GUICtrlToolbar_ClickButton
;_GUICtrlToolbar_ClickIndex
;_GUICtrlToolbar_CommandToIndex
;_GUICtrlToolbar_Create
;_GUICtrlToolbar_Customize
;_GUICtrlToolbar_DeleteButton
;_GUICtrlToolbar_Destroy
;_GUICtrlToolbar_EnableButton
;_GUICtrlToolbar_FindToolbar
;_GUICtrlToolbar_GetAnchorHighlight
;_GUICtrlToolbar_GetBitmapFlags
;_GUICtrlToolbar_GetButtonBitmap
;_GUICtrlToolbar_GetButtonInfo
;_GUICtrlToolbar_GetButtonInfoEx
;_GUICtrlToolbar_GetButtonParam
;_GUICtrlToolbar_GetButtonRect
;_GUICtrlToolbar_GetButtonRectEx
;_GUICtrlToolbar_GetButtonSize
;_GUICtrlToolbar_GetButtonState
;_GUICtrlToolbar_GetButtonStyle
;_GUICtrlToolbar_GetButtonText
;_GUICtrlToolbar_GetColorScheme
;_GUICtrlToolbar_GetDisabledImageList
;_GUICtrlToolbar_GetExtendedStyle
;_GUICtrlToolbar_GetHotImageList
;_GUICtrlToolbar_GetHotItem
;_GUICtrlToolbar_GetImageList
;_GUICtrlToolbar_GetInsertMark
;_GUICtrlToolbar_GetInsertMarkColor
;_GUICtrlToolbar_GetMaxSize
;_GUICtrlToolbar_GetMetrics
;_GUICtrlToolbar_GetPadding
;_GUICtrlToolbar_GetRows
;_GUICtrlToolbar_GetString
;_GUICtrlToolbar_GetStyle
;_GUICtrlToolbar_GetStyleAltDrag
;_GUICtrlToolbar_GetStyleCustomErase
;_GUICtrlToolbar_GetStyleFlat
;_GUICtrlToolbar_GetStyleList
;_GUICtrlToolbar_GetStyleRegisterDrop
;_GUICtrlToolbar_GetStyleToolTips
;_GUICtrlToolbar_GetStyleTransparent
;_GUICtrlToolbar_GetStyleWrapable
;_GUICtrlToolbar_GetTextRows
;_GUICtrlToolbar_GetToolTips
;_GUICtrlToolbar_GetUnicodeFormat
;_GUICtrlToolbar_HideButton
;_GUICtrlToolbar_HighlightButton
;_GUICtrlToolbar_HitTest
;_GUICtrlToolbar_IndexToCommand
;_GUICtrlToolbar_InsertButton
;_GUICtrlToolbar_InsertMarkHitTest
;_GUICtrlToolbar_IsButtonChecked
;_GUICtrlToolbar_IsButtonEnabled
;_GUICtrlToolbar_IsButtonHidden
;_GUICtrlToolbar_IsButtonHighlighted
;_GUICtrlToolbar_IsButtonIndeterminate
;_GUICtrlToolbar_IsButtonPressed
;_GUICtrlToolbar_LoadBitmap
;_GUICtrlToolbar_LoadImages
;_GUICtrlToolbar_MapAccelerator
;_GUICtrlToolbar_MoveButton
;_GUICtrlToolbar_PressButton
;_GUICtrlToolbar_SetAnchorHighlight
;_GUICtrlToolbar_SetBitmapSize
;_GUICtrlToolbar_SetButtonBitMap
;_GUICtrlToolbar_SetButtonInfo
;_GUICtrlToolbar_SetButtonInfoEx
;_GUICtrlToolbar_SetButtonParam
;_GUICtrlToolbar_SetButtonSize
;_GUICtrlToolbar_SetButtonState
;_GUICtrlToolbar_SetButtonStyle
;_GUICtrlToolbar_SetButtonText
;_GUICtrlToolbar_SetButtonWidth
;_GUICtrlToolbar_SetCmdID
;_GUICtrlToolbar_SetColorScheme
;_GUICtrlToolbar_SetDisabledImageList
;_GUICtrlToolbar_SetDrawTextFlags
;_GUICtrlToolbar_SetExtendedStyle
;_GUICtrlToolbar_SetHotImageList
;_GUICtrlToolbar_SetHotItem
;_GUICtrlToolbar_SetImageList
;_GUICtrlToolbar_SetIndent
;_GUICtrlToolbar_SetIndeterminate
;_GUICtrlToolbar_SetInsertMark
;_GUICtrlToolbar_SetInsertMarkColor
;_GUICtrlToolbar_SetMaxTextRows
;_GUICtrlToolbar_SetMetrics
;_GUICtrlToolbar_SetPadding
;_GUICtrlToolbar_SetParent
;_GUICtrlToolbar_SetRows
;_GUICtrlToolbar_SetStyle
;_GUICtrlToolbar_SetStyleAltDrag
;_GUICtrlToolbar_SetStyleCustomErase
;_GUICtrlToolbar_SetStyleFlat
;_GUICtrlToolbar_SetStyleList
;_GUICtrlToolbar_SetStyleRegisterDrop
;_GUICtrlToolbar_SetStyleToolTips
;_GUICtrlToolbar_SetStyleTransparent
;_GUICtrlToolbar_SetStyleWrapable
;_GUICtrlToolbar_SetToolTips
;_GUICtrlToolbar_SetUnicodeFormat
;_GUICtrlToolbar_SetWindowTheme
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;$tagTBADDBITMAP
;$tagTBINSERTMARK
;$tagTBMETRICS
;__GUICtrlToolbar_AutoSize
;__GUICtrlToolbar_ButtonStructSize
;__GUICtrlToolbar_SetStyleEx
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagTBADDBITMAP
; Description ...: Adds a bitmap that contains button images to a toolbar
; Fields ........: hInst - Handle to the module instance with the executable file that contains a bitmap resource.  To use bitmap
;                  +handles instead of resource IDs, set this member to 0.  You can add the system-defined button bitmaps to  the
;                  +list by specifying $HINST_COMMCTRL as the hInst member and one of the following values as the ID member:
;                  |$IDB_STD_LARGE_COLOR  - Adds large, color standard bitmaps
;                  |$IDB_STD_SMALL_COLOR  - Adds small, color standard bitmaps
;                  |$IDB_VIEW_LARGE_COLOR - Adds large, color view bitmaps
;                  |$IDB_VIEW_SMALL_COLOR - Adds small, color view bitmaps
;                  ID    - If hInst is 0, set this member to the bitmap handle of the bitmap with the button  images.  Otherwise,
;                  +set it to the resource identifier of the bitmap with the button images.
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagTBADDBITMAP = "handle hInst;uint_ptr ID"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagTBINSERTMARK
; Description ...: Contains information on the insertion mark in a toolbar control
; Fields ........: Button - Zero based index of the insertion mark. If this member is -1, there is no insertion mark
;                  Flags  - Defines where the insertion mark is in relation to Button. This can be one of the following values:
;                  |0                   - The insertion mark is to the left of the specified button
;                  |$TBIMHT_AFTER       - The insertion mark is to the right of the specified button
;                  |$TBIMHT_BACKGROUND  - The insertion mark is on the background of the toolbar.  This flag is  only  used  with
;                  +the $TB_INSERTMARKHITTEST message.
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagTBINSERTMARK = "int Button;dword Flags"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagTBMETRICS
; Description ...: Defines the metrics of a toolbar that are used to shrink or expand toolbar items
; Fields ........: Size     - Size of this structure, in bytes
;                  Mask     - Mask that determines the metric to retrieve. It can be any combination of the following:
;                  |$TBMF_PAD           - Retrieve the XPad and YPad values
;                  |$TBMF_BARPAD        - Retrieve the XBarPad and YBarPad values
;                  |$TBMF_BUTTONSPACING - Retrieve the XSpacing and YSpacing values
;                  XPad     - Width of the padding inside the toolbar buttons
;                  YPad     - Height of the padding inside the toolbar buttons
;                  XBarPad  - Width of the toolbar. Not used.
;                  YBarPad  - Height of the toolbar. Not used.
;                  XSpacing - Width of the space between toolbar buttons
;                  YSpacing - Height of the space between toolbar buttons
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagTBMETRICS = "uint Size;dword Mask;int XPad;int YPad;int XBarPad;int YBarPad;int XSpacing;int YSpacing"

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_AddBitmap
; Description ...: Adds images to the image list
; Syntax.........: _GUICtrlToolbar_AddBitmap($hWnd, $iButtons, $hInst, $iID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iButtons    - Number of button images in the bitmap
;                  $hInst       - Handle to the module instance with the executable file that contains a bitmap resource.  To use
;                  +bitmap handles instead of resource IDs, set this to 0.  You can add system defined button bitmaps to the list
;                  +by specifying -1 as the hInst member and one of the following values as the iID member:
;                  |$IDB_STD_LARGE_COLOR  - Adds large, color standard bitmaps
;                  |$IDB_STD_SMALL_COLOR  - Adds small, color standard bitmaps
;                  |$IDB_VIEW_LARGE_COLOR - Adds large, color view bitmaps
;                  |$IDB_VIEW_SMALL_COLOR - Adds small, color view bitmaps
;                  $iID         - If hInst is 0, set this member to the bitmap handle of  the  bitmap  with  the  button  images.
;                  +Otherwise, set it to the resource identifier of the bitmap with the button images. The following are resource
;                  +IDs to the standard and view bitmaps:
;                  |$STD_COPY        - Copy image
;                  |$STD_CUT         - Cut image
;                  |$STD_DELETE      - Delete image
;                  |$STD_FILENEW     - New file image
;                  |$STD_FILEOPEN    - Open file image
;                  |$STD_FILESAVE    - Save file image
;                  |$STD_FIND        - Find image
;                  |$STD_HELP        - Help image
;                  |$STD_PASTE       - Paste image
;                  |$STD_PRINT       - Print image
;                  |$STD_PRINTPRE    - Print preview image
;                  |$STD_PROPERTIES  - Properties image
;                  |$STD_REDOW       - Redo image
;                  |$STD_REPLACE     - Replace image
;                  |$STD_UNDO        - Undo image
;                  |$VIEW_DETAILS    - View details image
;                  |$VIEW_LARGEICONS - View large icons image
;                  |$VIEW_LIST       - View list image
;                  |$VIEW_SMALLICONS - View small icons image.
;                  |$VIEW_SORTDATE   - Sort by date image.
;                  |$VIEW_SORTNAME   - Sort by name image.
;                  |$VIEW_SORTSIZE   - Sort by size image.
;                  |$VIEW_SORTTYPE   - Sort by type image.
; Return values .: Success      - The zero based index of the first new image
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......: _GUICtrlToolbar_LoadBitmap
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_AddBitmap($hWnd, $iButtons, $hInst, $iID)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $tBitmap = DllStructCreate($tagTBADDBITMAP)
	DllStructSetData($tBitmap, "hInst", $hInst)
	DllStructSetData($tBitmap, "ID", $iID)
	Local $iRet
	If _WinAPI_InProcess($hWnd, $gh_TBLastWnd) Then
		$iRet = _SendMessage($hWnd, $TB_ADDBITMAP, $iButtons, $tBitmap, 0, "wparam", "struct*")
	Else
		Local $iBitmap = DllStructGetSize($tBitmap)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iBitmap, $tMemMap)
		_MemWrite($tMemMap, $tBitmap, $pMemory, $iBitmap)
		$iRet = _SendMessage($hWnd, $TB_ADDBITMAP, $iButtons, $pMemory, 0, "wparam", "ptr")
		_MemFree($tMemMap)
	EndIf
	Return $iRet
EndFunc   ;==>_GUICtrlToolbar_AddBitmap

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_AddButton
; Description ...: Adds a button
; Syntax.........: _GUICtrlToolbar_AddButton($hWnd, $iID, $iImage[, $iString = 0[, $iStyle = 0[, $iState = 4[, $iParam = 0]]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $iID         - Command ID
;                  $iImage      - Zero based index of the button image.  Set this parameter to -1 and the control will  send  the
;                  +$TBN_GETDISPINFO notification to retrieve the image index when it is needed.  Set this to -2 to indicate that
;                  +the button does not have an image.  The button layout will only include space for the text.  If the button is
;                  +a separator, this is the width of the separator, in pixels.
;                  $iString     - Zero based index of the button string that was set with AddString
;                  $iStyle      - Button style. Can be a combination of the following:
;                  |$BTNS_AUTOSIZE      - The toolbar control should not assign the standard width to the button
;                  |$BTNS_BUTTON        - Standard button
;                  |$BTNS_CHECK         - Toggles between the pressed and nonpressed
;                  |$BTNS_CHECKGROUP    - Button that stays pressed until another button in the group is pressed
;                  |$BTNS_DROPDOWN      - Creates a drop-down style button that can display a list
;                  |$BTNS_GROUP         - Button that stays pressed until another button in the group is pressed
;                  |$BTNS_NOPREFIX      - The button text will not have an accelerator prefix
;                  |$BTNS_SEP           - Creates a separator
;                  |$BTNS_SHOWTEXT      - Specifies that button text should be displayed
;                  |$BTNS_WHOLEDROPDOWN - Specifies that the button will have a drop-down arrow
;                  $iState      - Button state. Can be a combination of the following:
;                  |$TBSTATE_CHECKED       - The button has the $TBSTYLE_CHECK style and is being clicked
;                  |$TBSTATE_PRESSED       - The button is being clicked
;                  |$TBSTATE_ENABLED       - The button accepts user input
;                  |$TBSTATE_HIDDEN        - The button is not visible and cannot receive user input
;                  |$TBSTATE_INDETERMINATE - The button is grayed
;                  |$TBSTATE_WRAP          - The button is followed by a line break
;                  |$TBSTATE_ELLIPSES      - The button's text is cut off and an ellipsis is displayed
;                  |$TBSTATE_MARKED        - The button is marked
;                  $iParam      - Application-defined value
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......: _GUICtrlToolbar_DeleteButton, _GUICtrlToolbar_InsertButton
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_AddButton($hWnd, $iID, $iImage, $iString = 0, $iStyle = 0, $iState = 4, $iParam = 0)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlToolbar_GetUnicodeFormat($hWnd)

	Local $tButton = DllStructCreate($tagTBBUTTON)
	DllStructSetData($tButton, "Bitmap", $iImage)
	DllStructSetData($tButton, "Command", $iID)
	DllStructSetData($tButton, "State", $iState)
	DllStructSetData($tButton, "Style", $iStyle)
	DllStructSetData($tButton, "Param", $iParam)
	DllStructSetData($tButton, "String", $iString)
	Local $iRet
	If _WinAPI_InProcess($hWnd, $gh_TBLastWnd) Then
		$iRet = _SendMessage($hWnd, $TB_ADDBUTTONSW, 1, $tButton, 0, "wparam", "struct*")
	Else
		Local $iButton = DllStructGetSize($tButton)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iButton, $tMemMap)
		_MemWrite($tMemMap, $tButton, $pMemory, $iButton)
		If $fUnicode Then
			$iRet = _SendMessage($hWnd, $TB_ADDBUTTONSW, 1, $pMemory, 0, "wparam", "ptr")
		Else
			$iRet = _SendMessage($hWnd, $TB_ADDBUTTONSA, 1, $pMemory, 0, "wparam", "ptr")
		EndIf
		_MemFree($tMemMap)
	EndIf
	__GUICtrlToolbar_AutoSize($hWnd)
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlToolbar_AddButton

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_AddButtonSep
; Description ...: Adds a separator
; Syntax.........: _GUICtrlToolbar_AddButtonSep($hWnd[, $iWidth = 6])
; Parameters ....: $hWnd        - Handle to toolbar
;                  $iWidth      - Separator width
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_AddButtonSep($hWnd, $iWidth = 6)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	_GUICtrlToolbar_AddButton($hWnd, 0, $iWidth, 0, $BTNS_SEP)
EndFunc   ;==>_GUICtrlToolbar_AddButtonSep

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_AddString
; Description ...: Adds a new string to the toolbar's string pool
; Syntax.........: _GUICtrlToolbar_AddString($hWnd, $sString)
; Parameters ....: $hWnd        - Handle to the control
;                  $sString     - String to add
; Return values .: Success      - Zero based index of the new string
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetStrings
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_AddString($hWnd, $sString)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlToolbar_GetUnicodeFormat($hWnd)

	Local $iBuffer = StringLen($sString) + 2
	Local $tBuffer
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
		$iBuffer *= 2
	Else
		$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
	EndIf
	DllStructSetData($tBuffer, "Text", $sString)
	Local $iRet
	If _WinAPI_InProcess($hWnd, $gh_TBLastWnd) Then
		$iRet = _SendMessage($hWnd, $TB_ADDSTRINGW, 0, $tBuffer, 0, "wparam", "struct*")
	Else
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iBuffer, $tMemMap)
		_MemWrite($tMemMap, $tBuffer, $pMemory, $iBuffer)
		If $fUnicode Then
			$iRet = _SendMessage($hWnd, $TB_ADDSTRINGW, 0, $pMemory, 0, "wparam", "ptr")
		Else
			$iRet = _SendMessage($hWnd, $TB_ADDSTRINGA, 0, $pMemory, 0, "wparam", "ptr")
		EndIf
		_MemFree($tMemMap)
	EndIf
	Return $iRet
EndFunc   ;==>_GUICtrlToolbar_AddString

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlToolbar_AutoSize
; Description ...: Causes a toolbar to be resized
; Syntax.........: __GUICtrlToolbar_AutoSize($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: An application calls this function after causing the size of a toolbar to change  by  setting  the  button  or
;                  bitmap size or by adding strings for the first time.  Normally, you do not need to use this function as it  is
;                  called internally as needed.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GUICtrlToolbar_AutoSize($hWnd)
	_SendMessage($hWnd, $TB_AUTOSIZE)
EndFunc   ;==>__GUICtrlToolbar_AutoSize

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_ButtonCount
; Description ...: Retrieves a count of the buttons
; Syntax.........: _GUICtrlToolbar_ButtonCount($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Number of buttons on toolbar
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_ButtonCount($hWnd)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_BUTTONCOUNT)
EndFunc   ;==>_GUICtrlToolbar_ButtonCount

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlToolbar_ButtonStructSize
; Description ...: Specifies the size of the $tagTBBUTTON structure
; Syntax.........: __GUICtrlToolbar_ButtonStructSize($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......: This function is used to tell the control the size of a $tagTBBUTTON structure.  Normally, you do not  need  to
;                  use this function as it is called internally when the control is created.
; Related .......: $tagTBBUTTON
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GUICtrlToolbar_ButtonStructSize($hWnd)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $tButton = DllStructCreate($tagTBBUTTON)
	_SendMessage($hWnd, $TB_BUTTONSTRUCTSIZE, DllStructGetSize($tButton), 0, 0, "wparam", "ptr")
EndFunc   ;==>__GUICtrlToolbar_ButtonStructSize

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_CheckButton
; Description ...: Checks or unchecks a given button
; Syntax.........: _GUICtrlToolbar_CheckButton($hWnd, $iCommandID[, $fCheck = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
;                  $fCheck      - Check state:
;                  | True - Button will be checked
;                  |False - Button will be unchecked
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: When a button is checked, it is displayed in the pressed state
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_CheckButton($hWnd, $iCommandID, $fCheck = True)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_CHECKBUTTON, $iCommandID, $fCheck) <> 0
EndFunc   ;==>_GUICtrlToolbar_CheckButton

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_ClickAccel
; Description ...: Clicks a specific button using it's accelerator
; Syntax.........: _GUICtrlToolbar_ClickAccel($hWnd, $cAccel[, $sButton = "left"[, $fMove = False[, $iClicks = 1[, $iSpeed = 1]]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $cAccel      - Button accelerator
;                  $sButton     - Button to click
;                  $fMove       - Mouse movement flag:
;                  | True - Mouse will be moved
;                  |False - Mouse will not be moved
;                  $iClicks     - Number of clicks
;                  $iSpeed      - Mouse movement speed
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_ClickButton, _GUICtrlToolbar_ClickIndex
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_ClickAccel($hWnd, $cAccel, $sButton = "left", $fMove = False, $iClicks = 1, $iSpeed = 1)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $iID = _GUICtrlToolbar_MapAccelerator($hWnd, $cAccel)
	_GUICtrlToolbar_ClickButton($hWnd, $iID, $sButton, $fMove, $iClicks, $iSpeed)
EndFunc   ;==>_GUICtrlToolbar_ClickAccel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_ClickButton
; Description ...: Clicks a specific button
; Syntax.........: _GUICtrlToolbar_ClickButton($hWnd, $iCommandID[, $sButton = "left"[, $fMove = False[, $iClicks = 1[, $iSpeed = 1]]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
;                  $sButton     - Button to click
;                  $fMove       - Mouse movement flag:
;                  | True - Mouse will be moved
;                  |False - Mouse will not be moved
;                  $iClicks     - Number of clicks
;                  $iSpeed      - Mouse movement speed
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......: _GUICtrlToolbar_ClickAccel, _GUICtrlToolbar_ClickIndex
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_ClickButton($hWnd, $iCommandID, $sButton = "left", $fMove = False, $iClicks = 1, $iSpeed = 1)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $tRect = _GUICtrlToolbar_GetButtonRectEx($hWnd, $iCommandID)
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
EndFunc   ;==>_GUICtrlToolbar_ClickButton

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_ClickIndex
; Description ...: Clicks a specific button using it's index
; Syntax.........: _GUICtrlToolbar_ClickIndex($hWnd, $iIndex[, $sButton = "left"[, $fMove = False[, $iClicks = 1[, $iSpeed = 1]]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Button index
;                  $sButton     - Button to click
;                  $fMove       - Mouse movement flag:
;                  | True - Mouse will be moved
;                  |False - Mouse will not be moved
;                  $iClicks     - Number of clicks
;                  $iSpeed      - Mouse movement speed
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_ClickAccel, _GUICtrlToolbar_ClickButton
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_ClickIndex($hWnd, $iIndex, $sButton = "left", $fMove = False, $iClicks = 1, $iSpeed = 1)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $iCommandID = _GUICtrlToolbar_IndexToCommand($hWnd, $iIndex)
	_GUICtrlToolbar_ClickButton($hWnd, $iCommandID, $sButton, $fMove, $iClicks, $iSpeed)
EndFunc   ;==>_GUICtrlToolbar_ClickIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_CommandToIndex
; Description ...: Retrieves the index for the button associated with the specified command identifier
; Syntax.........: _GUICtrlToolbar_CommandToIndex($hWnd, $iCommandID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
; Return values .: Success      - Zero based button index
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_IndexToCommand
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_CommandToIndex($hWnd, $iCommandID)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_COMMANDTOINDEX, $iCommandID)
EndFunc   ;==>_GUICtrlToolbar_CommandToIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_Create
; Description ...: Create a Toolbar control
; Syntax.........: _GUICtrlToolbar_Create($hWnd[, $iStyle = 0x00000800[, $iExStyle = 0x00000000]])
; Parameters ....: $hWnd        - Handle to parent or owner window
;                  $iStyle      - Control styles:
;                  |$BTNS_AUTOSIZE        - Specifies that the toolbar control should not assign the standard width to the button.
;                  +Instead, the button's width will be calculated based on the width of the text plus the image of the button.
;                  |$BTNS_BUTTON          - Creates a standard button
;                  |$BTNS_CHECK           - Creates a dual-state push button that toggles  between  the  pressed  and  nonpressed
;                  +states each time the user clicks it.  The button has a different background color when it is in  the  pressed
;                  +state.
;                  |$BTNS_CHECKGROUP      - Creates a button that stays pressed until another button in  the  group  is  pressed,
;                  +similar to option buttons. It is equivalent to combining $BTNS_CHECK and $BTNS_GROUP.
;                  |$BTNS_DROPDOWN        - Creates a drop-down style button that can display a list when the button is  clicked.
;                  +Instead of the $WM_COMMAND message used for normal buttons, drop-down buttons send a  $TBN_DROPDOWN  message
;                  +An application can then have the notification handler display a list of  options.  If  the  toolbar  has  the
;                  +$TBSTYLE_EX_DRAWDDARROWS extended style, drop-down buttons will  have  a  drop  down  arrow  displayed  in  a
;                  +separate section to their right.  If the arrow is clicked, a $TBN_DROPDOWN notification will be sent.  If the
;                  +associated button is clicked, a $WM_COMMAND message will be sent.
;                  |$BTNS_GROUP           - When combined with $BTNS_CHECK, creates a button that  stays  pressed  until  another
;                  +button in the group is pressed.
;                  |$BTNS_NOPREFIX        - Specifies that the button text will not have an accelerator prefix associated with it
;                  |$BTNS_SEP             - Creates a separator, providing a small gap between button groups.  A button that  has
;                  +this style does not receive user input.
;                  |$BTNS_SHOWTEXT        - Specifies that button text should be displayed.  All buttons can have text, but  only
;                  +those buttons with the $BTNS_SHOWTEXT button style will display it.  This button style must be used with  the
;                  +$TBSTYLE_LIST style and the $TBSTYLE_EX_MIXEDBUTTONS extended style.  If you set text for buttons that do not
;                  +have the $BTNS_SHOWTEXT style, the toolbar control will automatically display it as a ToolTip when the cursor
;                  +hovers over the button.  This feature allows your application to avoid handling the  $TBN_GETINFOTIP  message
;                  +for the toolbar.
;                  |$BTNS_WHOLEDROPDOWN   - Specifies that the button will have a drop down arrow, but not as a separate section.
;                  +Buttons with this style behave the same, regardless of whether the $TBSTYLE_EX_DRAWDDARROWS extended style is
;                  +set.
;                  -
;                  |$TBSTYLE_ALTDRAG      - Allows users to change a toolbar button's position by dragging it while holding  down
;                  +the ALT key.  If this style is not specified, the user must hold down the SHIFT key while dragging a  button.
;                  +Note that the $CCS_ADJUSTABLE style must be specified to enable toolbar buttons to be dragged.
;                  |$TBSTYLE_CUSTOMERASE  - Generates $NM_CUSTOMDRAW messages when the toolbar processes $WM_ERASEBKGND messages
;                  |$TBSTYLE_FLAT         - Creates a flat toolbar
;                  |$TBSTYLE_LIST         - Creates a flat toolbar with button text to the right of the bitmap
;                  |$TBSTYLE_REGISTERDROP - Generates $TBN_GETOBJECT notification messages to request drop  target  objects  when
;                  +the cursor passes over toolbar buttons.
;                  |$TBSTYLE_TOOLTIPS     - Creates a ToolTip control that an application can use to display descriptive text for
;                  +the buttons in the toolbar.
;                  |$TBSTYLE_TRANSPARENT - Creates a transparent toolbar.  In a transparent toolbar, the toolbar  is  transparent
;                  +but the buttons are not. Button text appears under button bitmaps. To prevent repainting problems, this style
;                  +should be set before the toolbar control becomes visible.
;                  |$TBSTYLE_WRAPABLE    - Creates a toolbar that can have multiple lines of buttons.  Toolbar buttons can "wrap"
;                  +to the next line when the toolbar becomes too narrow to include all  buttons  on  the  same  line.  When  the
;                  +toolbar is wrapped, the break will occur on either the rightmost separator or the rightmost button  if  there
;                  +are no separators on the bar.  This style must be set to display a vertical toolbar control when the  toolbar
;                  +is part of a vertical rebar control.
;                  -
;                  |Default: $TBSTYLE_FLAT
;                  |Forced: $WS_CHILD, $WS_CLIPSIBLINGS, $WS_VISIBLE
;                  $iExStyle    - Control extended styles:
;                  |$TBSTYLE_EX_DRAWDDARROWS       - Allows buttons to have a separate dropdown  arrow.  Buttons  that  have  the
;                  +$BTNS_DROPDOWN style will be drawn with a drop down arrow in a separate section, to the right of the  button.
;                  +If the arrow is clicked, only the arrow portion of the button will depress, and the toolbar control will send
;                  +a $TBN_DROPDOWN notification to prompt the application to display the dropdown menu.  If the main part of the
;                  +button is clicked, the toolbar control sends a $WM_COMMAND message with the button's ID.
;                  |$TBSTYLE_EX_HIDECLIPPEDBUTTONS - Hides partially clipped buttons
;                  |$TBSTYLE_EX_DOUBLEBUFFER       - Requires the toolbar to be double buffered
;                  |$TBSTYLE_EX_MIXEDBUTTONS       - Allows you to set text for all buttons, but only display it for the  buttons
;                  +with the $BTNS_SHOWTEXT button style.  The $TBSTYLE_LIST style must also be set. Normally, when a button does
;                  +not display text, you must handle $TBN_GETINFOTIP to display a  ToolTip.  With  the  $TBSTYLE_EX_MIXEDBUTTONS
;                  +extended style, text that is set but not displayed on a button will automatically be  used  as  the  button's
;                  +ToolTip text.  You only need to handle $TBN_GETINFOTIP if it needs more flexibility in specifying the ToolTip
;                  +text.
; Return values .: Success      - Handle to the Toolbar control
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......: _GUICtrlToolbar_Destroy
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_Create($hWnd, $iStyle = 0x00000800, $iExStyle = 0x00000000)
	$iStyle = BitOR($iStyle, $__UDFGUICONSTANT_WS_CHILD, $__TOOLBARCONSTANT_WS_CLIPSIBLINGS, $__UDFGUICONSTANT_WS_VISIBLE)

	Local $nCtrlID = __UDF_GetNextGlobalID($hWnd)
	If @error Then Return SetError(@error, @extended, 0)

	Local $hTool = _WinAPI_CreateWindowEx($iExStyle, $__TOOLBARCONSTANT_ClassName, "", $iStyle, 0, 0, 0, 0, $hWnd, $nCtrlID)
	__GUICtrlToolbar_ButtonStructSize($hTool)
	Return $hTool
EndFunc   ;==>_GUICtrlToolbar_Create

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_Customize
; Description ...: Displays the Customize Toolbar dialog box
; Syntax.........: _GUICtrlToolbar_Customize($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The toolbar must handle the $TBN_QUERYINSERT and $TBN_QUERYDELETE  notifications  for  the  Customize  Toolbar
;                  dialog box to appear. If the toolbar does not handle those notifications, $TB_CUSTOMIZE has no effect.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlToolbar_Customize($hWnd)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	_SendMessage($hWnd, $TB_CUSTOMIZE)
EndFunc   ;==>_GUICtrlToolbar_Customize

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_DeleteButton
; Description ...: Deletes a button from the toolbar
; Syntax.........: _GUICtrlToolbar_DeleteButton($hWnd, $iCommandID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_AddButton
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_DeleteButton($hWnd, $iCommandID)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $iIndex = _GUICtrlToolbar_CommandToIndex($hWnd, $iCommandID)
	If $iIndex = -1 Then Return SetError(-1, 0, False)
	Return _SendMessage($hWnd, $TB_DELETEBUTTON, $iIndex) <> 0
EndFunc   ;==>_GUICtrlToolbar_DeleteButton

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_Destroy
; Description ...: Delete the control
; Syntax.........: _GUICtrlToolbar_Destroy(ByRef $hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True, Handle is set to 0
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Restricted to only be used on Listbox created with _GUICtrlToolbar_Create
; Related .......: _GUICtrlToolbar_Create
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_Destroy(ByRef $hWnd)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)
	If Not _WinAPI_IsClassName($hWnd, $__TOOLBARCONSTANT_ClassName) Then Return SetError(2, 2, False)

	Local $Destroyed = 0
	If _WinAPI_InProcess($hWnd, $gh_TBLastWnd) Then
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
EndFunc   ;==>_GUICtrlToolbar_Destroy

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_EnableButton
; Description ...: Enables or disables the specified button
; Syntax.........: _GUICtrlToolbar_EnableButton($hWnd, $iCommandID[, $fEnable = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
;                  $fEnable     - Enable flag:
;                  | True - Button will be enabled
;                  |False - Button will be disabled
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_HideButton
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_EnableButton($hWnd, $iCommandID, $fEnable = True)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_ENABLEBUTTON, $iCommandID, $fEnable) <> 0
EndFunc   ;==>_GUICtrlToolbar_EnableButton

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_FindToolbar
; Description ...: Finds a specific toolbar
; Syntax.........: _GUICtrlToolbar_FindToolbar($hWnd, $sText)
; Parameters ....: $hWnd        - Window handle or text of window
;                  $sText       - Button text to search for
; Return values .: Success      - Handle of the toolbar
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_FindToolbar($hWnd, $sText)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $iCommandID, $hToolbar

	If Not _WinAPI_IsWindow($hWnd) Then
		$hWnd = WinGetHandle($hWnd)
		If @error Then Return SetError(-1, -1, 0)
	EndIf
	Local $aWinList = _WinAPI_EnumWindows(True, $hWnd)
	For $iI = 1 To $aWinList[0][0]
		If $aWinList[$iI][1] = $__TOOLBARCONSTANT_ClassName Then
			$hToolbar = $aWinList[$iI][0]
			For $iJ = 0 To _GUICtrlToolbar_ButtonCount($hToolbar) - 1
				$iCommandID = _GUICtrlToolbar_IndexToCommand($hToolbar, $iJ)
				If _GUICtrlToolbar_GetButtonText($hToolbar, $iCommandID) = $sText Then Return $hToolbar
			Next
		EndIf
	Next
	Return SetError(-2, -2, 0)
EndFunc   ;==>_GUICtrlToolbar_FindToolbar

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetAnchorHighlight
; Description ...: Retrieves the anchor highlight setting
; Syntax.........: _GUICtrlToolbar_GetAnchorHighlight($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: True         - Anchor highlighting is enabled
;                  False        - Anchor highlighting is not enabled
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Anchor highlighting means that the last highlighted  item  will  remain  highlighted  until  another  item  is
;                  highlighted. This occurs even if the cursor leaves the toolbar control.
; Related .......: _GUICtrlToolbar_SetAnchorHighlight
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetAnchorHighlight($hWnd)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_GETANCHORHIGHLIGHT) <> 0
EndFunc   ;==>_GUICtrlToolbar_GetAnchorHighlight

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetBitmapFlags
; Description ...: Retrieves the flags that describe the type of bitmap to be used
; Syntax.........: _GUICtrlToolbar_GetBitmapFlags($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - A value that describes the type of bitmap that should be used:
;                  |0 - Use small (16 x 16) bitmaps
;                  |1 - Use large (24 x 24) bitmaps
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The value returned is only advisory. The control recommends large or small bitmaps based upon whether the user
;                  has chosen large or small fonts.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetBitmapFlags($hWnd)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_GETBITMAPFLAGS)
EndFunc   ;==>_GUICtrlToolbar_GetBitmapFlags

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetButtonBitmap
; Description ...: Retrieves the index of the bitmap associated with a button
; Syntax.........: _GUICtrlToolbar_GetButtonBitmap($hWnd, $iCommandID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
; Return values .: Success      - Zero based button bitmap index
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetButtonBitmap
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetButtonBitmap($hWnd, $iCommandID)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_GETBITMAP, $iCommandID)
EndFunc   ;==>_GUICtrlToolbar_GetButtonBitmap

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetButtonInfo
; Description ...: Retrieves information for a button
; Syntax.........: _GUICtrlToolbar_GetButtonInfo($hWnd, $iCommandID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
; Return values .: Success      - Array with the following format:
;                  |[0] - Zero based button image index
;                  |[1] - Button state. Can be a combination of the following:
;                  | $TBSTATE_CHECKED       - The button has is being clicked
;                  | $TBSTATE_PRESSED       - The button is being clicked
;                  | $TBSTATE_ENABLED       - The button accepts user input
;                  | $TBSTATE_HIDDEN        - The button is not visible
;                  | $TBSTATE_INDETERMINATE - The button is grayed
;                  | $TBSTATE_WRAP          - The button is followed by a line break
;                  | $TBSTATE_ELLIPSES      - The button's text is cut off
;                  | $TBSTATE_MARKED        - The button is marked
;                  |[2] - Button style. Can be a combination of the following:
;                  | $BTNS_AUTOSIZE      - The control should not assign the standard width
;                  | $BTNS_BUTTON        - Standard button
;                  | $BTNS_CHECK         - Toggles between the pressed and nonpressed
;                  | $BTNS_CHECKGROUP    - Button that stays pressed until another button is pressed
;                  | $BTNS_DROPDOWN      - Creates a drop-down style button that can display a list
;                  | $BTNS_GROUP         - Button that stays pressed until another button is pressed
;                  | $BTNS_NOPREFIX      - The button text will not have an accelerator prefix
;                  | $BTNS_SEP           - Creates a separator
;                  | $BTNS_SHOWTEXT      - Specifies that button text should be displayed
;                  | $BTNS_WHOLEDROPDOWN - Specifies that the button will have a drop-down arrow
;                  |[3] - Button width
;                  |[4] - Button parameter
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetButtonInfo
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetButtonInfo($hWnd, $iCommandID)
	Local $aButton[5]

	Local $tButton = _GUICtrlToolbar_GetButtonInfoEx($hWnd, $iCommandID)
	$aButton[0] = DllStructGetData($tButton, "Image")
	$aButton[1] = DllStructGetData($tButton, "State")
	$aButton[2] = DllStructGetData($tButton, "Style")
	$aButton[3] = DllStructGetData($tButton, "CX")
	$aButton[4] = DllStructGetData($tButton, "Param")
	Return $aButton
EndFunc   ;==>_GUICtrlToolbar_GetButtonInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetButtonInfoEx
; Description ...: Retrieves information for a button
; Syntax.........: _GUICtrlToolbar_GetButtonInfoEx($hWnd, $iCommandID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
; Return values .: Success      - $tagTBBUTTONINFO structure
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetButtonInfoEx, $tagTBBUTTONINFO
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetButtonInfoEx($hWnd, $iCommandID)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)
	Local $fUnicode = _GUICtrlToolbar_GetUnicodeFormat($hWnd)

	Local $tButton = DllStructCreate($tagTBBUTTONINFO)
	Local $iButton = DllStructGetSize($tButton)
	Local $iMask = BitOR($TBIF_IMAGE, $TBIF_STATE, $TBIF_STYLE, $TBIF_LPARAM, $TBIF_SIZE)
	DllStructSetData($tButton, "Size", $iButton)
	DllStructSetData($tButton, "Mask", $iMask)
	Local $iRet
	If _WinAPI_InProcess($hWnd, $gh_TBLastWnd) Then
		$iRet = _SendMessage($hWnd, $TB_GETBUTTONINFOW, $iCommandID, $tButton, 0, "wparam", "struct*")
	Else
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iButton, $tMemMap)
		_MemWrite($tMemMap, $tButton, $pMemory, $iButton)
		If $fUnicode Then
			$iRet = _SendMessage($hWnd, $TB_GETBUTTONINFOW, $iCommandID, $pMemory, 0, "wparam", "ptr")
		Else
			$iRet = _SendMessage($hWnd, $TB_GETBUTTONINFOA, $iCommandID, $pMemory, 0, "wparam", "ptr")
		EndIf
		_MemRead($tMemMap, $pMemory, $tButton, $iButton)
		_MemFree($tMemMap)
	EndIf
	Return SetError($iRet = -1, 0, $tButton)
EndFunc   ;==>_GUICtrlToolbar_GetButtonInfoEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetButtonParam
; Description ...: Retrieves the button param value
; Syntax.........: _GUICtrlToolbar_GetButtonParam($hWnd, $iCommandID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
; Return values .: Success      - Application-defined value
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetButtonParam
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetButtonParam($hWnd, $iCommandID)
	Local $tButton = _GUICtrlToolbar_GetButtonInfoEx($hWnd, $iCommandID)
	Return DllStructGetData($tButton, "Param")
EndFunc   ;==>_GUICtrlToolbar_GetButtonParam

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetButtonRect
; Description ...: Retrieves the bounding rectangle for a button
; Syntax.........: _GUICtrlToolbar_GetButtonRect($hWnd, $iCommandID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
; Return values .: Success      - Array with the following format:
;                  |[0] - X coordinate of the upper left corner of the rectangle
;                  |[1] - Y coordinate of the upper left corner of the rectangle
;                  |[2] - X coordinate of the lower right corner of the rectangle
;                  |[3] - Y coordinate of the lower right corner of the rectangle
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetButtonRectEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetButtonRect($hWnd, $iCommandID)
	Local $aRect[4]

	Local $tRect = _GUICtrlToolbar_GetButtonRectEx($hWnd, $iCommandID)
	$aRect[0] = DllStructGetData($tRect, "Left")
	$aRect[1] = DllStructGetData($tRect, "Top")
	$aRect[2] = DllStructGetData($tRect, "Right")
	$aRect[3] = DllStructGetData($tRect, "Bottom")
	Return $aRect
EndFunc   ;==>_GUICtrlToolbar_GetButtonRect

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetButtonRectEx
; Description ...: Retrieves the bounding rectangle for a specified toolbar button
; Syntax.........: _GUICtrlToolbar_GetButtonRectEx($hWnd, $iCommandID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
; Return values .: Success      - $tagRECT structure
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetButtonRect, $tagRECT
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetButtonRectEx($hWnd, $iCommandID)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $tRect = DllStructCreate($tagRECT)
	If _WinAPI_InProcess($hWnd, $gh_TBLastWnd) Then
		_SendMessage($hWnd, $TB_GETRECT, $iCommandID, $tRect, 0, "wparam", "struct*")
	Else
		Local $iRect = DllStructGetSize($tRect)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iRect, $tMemMap)
		_SendMessage($hWnd, $TB_GETRECT, $iCommandID, $pMemory, 0, "wparam", "ptr")
		_MemRead($tMemMap, $pMemory, $tRect, $iRect)
		_MemFree($tMemMap)
	EndIf
	Return $tRect
EndFunc   ;==>_GUICtrlToolbar_GetButtonRectEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetButtonSize
; Description ...: Retrieves the current button width and height, in pixels
; Syntax.........: _GUICtrlToolbar_GetButtonSize($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Array with the following format:
;                  |[0] - Button height
;                  |[1] - Button width
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetButtonSize
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetButtonSize($hWnd)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $aSize[2]

	Local $iRet = _SendMessage($hWnd, $TB_GETBUTTONSIZE)
	$aSize[0] = _WinAPI_HiWord($iRet)
	$aSize[1] = _WinAPI_LoWord($iRet)
	Return $aSize
EndFunc   ;==>_GUICtrlToolbar_GetButtonSize

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetButtonState
; Description ...: Retrieves information about the state of the specified button
; Syntax.........: _GUICtrlToolbar_GetButtonState($hWnd, $iCommandID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
; Return values .: Success      - Button state. Can be one or more of the following
;                  |$TBSTATE_CHECKED       - The button has the $TBSTYLE_CHECK style and is being clicked
;                  |$TBSTATE_PRESSED       - The button is being clicked
;                  |$TBSTATE_ENABLED       - The button accepts user input
;                  |$TBSTATE_HIDDEN        - The button is not visible and cannot receive user input
;                  |$TBSTATE_INDETERMINATE - The button is grayed
;                  |$TBSTATE_WRAP          - The button is followed by a line break
;                  |$TBSTATE_ELLIPSES      - The button's text is cut off and an ellipsis is displayed
;                  |$TBSTATE_MARKED        - The button is marked
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetButtonState
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetButtonState($hWnd, $iCommandID)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_GETSTATE, $iCommandID)
EndFunc   ;==>_GUICtrlToolbar_GetButtonState

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetButtonStyle
; Description ...: Retrieves the style flags of a button
; Syntax.........: _GUICtrlToolbar_GetButtonStyle($hWnd, $iCommandID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
; Return values .: Success      - Button style. Can be a combination of the following:
;                  |$BTNS_AUTOSIZE      - The toolbar control should not assign the standard width to the button
;                  |$BTNS_CHECK         - Toggles between the pressed and nonpressed
;                  |$BTNS_CHECKGROUP    - Button that stays pressed until another button in the group is pressed
;                  |$BTNS_DROPDOWN      - Drop-down style button that can display a list
;                  |$BTNS_GROUP         - Button that stays pressed until another button in the group is pressed
;                  |$BTNS_NOPREFIX      - The button text will not have an accelerator prefix
;                  |$BTNS_SEP           - Separator
;                  |$BTNS_SHOWTEXT      - Button text should be displayed
;                  |$BTNS_WHOLEDROPDOWN - The button has a drop-down arrow
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetButtonStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetButtonStyle($hWnd, $iCommandID)
	Local $tButton = _GUICtrlToolbar_GetButtonInfoEx($hWnd, $iCommandID)
	Return DllStructGetData($tButton, "Style")
EndFunc   ;==>_GUICtrlToolbar_GetButtonStyle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetButtonText
; Description ...: Retrieves the display text of a button
; Syntax.........: _GUICtrlToolbar_GetButtonText($hWnd, $iCommandID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
; Return values .: Success      - Button text
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetButtonText, _GUICtrlToolbar_GetString
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetButtonText($hWnd, $iCommandID)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlToolbar_GetUnicodeFormat($hWnd)

	Local $iBuffer
	If $fUnicode Then
		$iBuffer = _SendMessage($hWnd, $TB_GETBUTTONTEXTW, $iCommandID)
	Else
		$iBuffer = _SendMessage($hWnd, $TB_GETBUTTONTEXTA, $iCommandID)
	EndIf
	If $iBuffer = 0 Then Return SetError(True, 0, "")
	If $iBuffer = 1 Then Return SetError(False, 0, "")
	If $iBuffer <= -1 Then Return SetError(False, -1, "")
	$iBuffer += 1
	Local $tBuffer
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
		$iBuffer *= 2
	Else
		$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
	EndIf
	Local $iRet
	If _WinAPI_InProcess($hWnd, $gh_TBLastWnd) Then
		$iRet = _SendMessage($hWnd, $TB_GETBUTTONTEXTW, $iCommandID, $tBuffer, 0, "wparam", "struct*")
	Else
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iBuffer, $tMemMap)
		If $fUnicode Then
			$iRet = _SendMessage($hWnd, $TB_GETBUTTONTEXTW, $iCommandID, $pMemory, 0, "wparam", "ptr")
		Else
			$iRet = _SendMessage($hWnd, $TB_GETBUTTONTEXTA, $iCommandID, $pMemory, 0, "wparam", "ptr")
		EndIf
		_MemRead($tMemMap, $pMemory, $tBuffer, $iBuffer)
		_MemFree($tMemMap)
	EndIf
	Return SetError($iRet > 0, 0, DllStructGetData($tBuffer, "Text"))
EndFunc   ;==>_GUICtrlToolbar_GetButtonText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetColorScheme
; Description ...: Retrieves the color scheme information
; Syntax.........: _GUICtrlToolbar_GetColorScheme($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Array with the following format:
;                  |[0] - The highlight color of the buttons
;                  |[1] - The shadow color of the buttons
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......: The control uses the color scheme information when drawing the 3-D elements in the control
; Related .......: _GUICtrlToolbar_SetColorScheme
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetColorScheme($hWnd)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)
	Local $aColor[2], $iRet

	Local $tColor = DllStructCreate($tagCOLORSCHEME)
	Local $iColor = DllStructGetSize($tColor)
	DllStructSetData($tColor, "Size", $iColor)
	If _WinAPI_InProcess($hWnd, $gh_TBLastWnd) Then
		$iRet = _SendMessage($hWnd, $TB_GETCOLORSCHEME, 0, $tColor, 0, "wparam", "struct*")
	Else
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iColor, $tMemMap)
		$iRet = _SendMessage($hWnd, $TB_GETCOLORSCHEME, 0, $pMemory, 0, "wparam", "ptr")
		_MemRead($tMemMap, $pMemory, $tColor, $iColor)
		_MemFree($tMemMap)
	EndIf
	$aColor[0] = DllStructGetData($tColor, "BtnHighlight")
	$aColor[1] = DllStructGetData($tColor, "BtnShadow")
	Return SetError($iRet = 0, 0, $aColor)
EndFunc   ;==>_GUICtrlToolbar_GetColorScheme

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetDisabledImageList
; Description ...: Retrieves the disabled button image list
; Syntax.........: _GUICtrlToolbar_GetDisabledImageList($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Handle to the disabled image list
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetDisabledImageList
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetDisabledImageList($hWnd)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return Ptr(_SendMessage($hWnd, $TB_GETDISABLEDIMAGELIST))
EndFunc   ;==>_GUICtrlToolbar_GetDisabledImageList

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetExtendedStyle
; Description ...: Retrieves the extended styles
; Syntax.........: _GUICtrlToolbar_GetExtendedStyle($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Control extended styles. Can be one or more of the following:
;                  |$TBSTYLE_EX_DRAWDDARROWS       - Allows buttons to have a separate dropdown arrow
;                  |$TBSTYLE_EX_MIXEDBUTTONS       - Allows mixing buttons with text and images
;                  |$TBSTYLE_EX_HIDECLIPPEDBUTTONS - Hides partially clipped buttons
;                  |$TBSTYLE_EX_DOUBLEBUFFER       - Requires the toolbar to be double buffered
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetExtendedStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetExtendedStyle($hWnd)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_GETEXTENDEDSTYLE)
EndFunc   ;==>_GUICtrlToolbar_GetExtendedStyle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetHotImageList
; Description ...: Retrieves the hot button image list
; Syntax.........: _GUICtrlToolbar_GetHotImageList($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Handle to the hot image list
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: A button is considered hot when the cursor is over it
; Related .......: _GUICtrlToolbar_SetHotImageList
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetHotImageList($hWnd)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return Ptr(_SendMessage($hWnd, $TB_GETHOTIMAGELIST))
EndFunc   ;==>_GUICtrlToolbar_GetHotImageList

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetHotItem
; Description ...: Retrieves the index of the hot item
; Syntax.........: _GUICtrlToolbar_GetHotItem($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The zero based index of the hot item
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:  A button is considered hot when the cursor is over it
; Related .......: _GUICtrlToolbar_SetHotItem
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetHotItem($hWnd)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_GETHOTITEM)
EndFunc   ;==>_GUICtrlToolbar_GetHotItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetImageList
; Description ...: Retrieves the default state image list
; Syntax.........: _GUICtrlToolbar_GetImageList($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Handle to the image list
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: A toolbar control uses this image list to display buttons when they are not hot or disabled
; Related .......: _GUICtrlToolbar_SetImageList
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetImageList($hWnd)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return Ptr(_SendMessage($hWnd, $TB_GETIMAGELIST))
EndFunc   ;==>_GUICtrlToolbar_GetImageList

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetInsertMark
; Description ...: Retrieves the current insertion mark
; Syntax.........: _GUICtrlToolbar_GetInsertMark($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Array with the following format:
;                  |[0] - Zero based index of the insertion mark or -1 for no insertion mark
;                  |[1] - Defines where the insertion mark is in relation to the button:
;                  | 0 - To the left
;                  | 1 - To the right
;                  | 2 - On the background of the toolbar
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetInsertMark
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetInsertMark($hWnd)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $aMark[2], $iRet

	Local $tMark = DllStructCreate($tagTBINSERTMARK)
	If _WinAPI_InProcess($hWnd, $gh_TBLastWnd) Then
		$iRet = _SendMessage($hWnd, $TB_GETINSERTMARK, 0, $tMark, 0, "wparam", "struct*")
	Else
		Local $iMark = DllStructGetSize($tMark)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iMark, $tMemMap)
		$iRet = _SendMessage($hWnd, $TB_GETINSERTMARK, 0, $pMemory, 0, "wparam", "ptr")
		_MemRead($tMemMap, $pMemory, $tMark, $iMark)
		_MemFree($tMemMap)
	EndIf
	$aMark[0] = DllStructGetData($tMark, "Button")
	$aMark[1] = DllStructGetData($tMark, "Flags")
	Return SetError($iRet <> 0, 0, $aMark)
EndFunc   ;==>_GUICtrlToolbar_GetInsertMark

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetInsertMarkColor
; Description ...: Retrieves the color used to draw the insertion mark
; Syntax.........: _GUICtrlToolbar_GetInsertMarkColor($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Insertion mark color
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetInsertMarkColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetInsertMarkColor($hWnd)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_GETINSERTMARKCOLOR)
EndFunc   ;==>_GUICtrlToolbar_GetInsertMarkColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetMaxSize
; Description ...: Retrieves the total size of all of the visible buttons and separators
; Syntax.........: _GUICtrlToolbar_GetMaxSize($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Array with the following format:
;                  |[0] - Maximum width
;                  |[1] - Maximum height
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetMaxSize($hWnd)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $aSize[2], $iRet

	Local $tSize = DllStructCreate($tagSIZE)
	If _WinAPI_InProcess($hWnd, $gh_TBLastWnd) Then
		$iRet = _SendMessage($hWnd, $TB_GETMAXSIZE, 0, $tSize, 0, "wparam", "struct*")
	Else
		Local $iSize = DllStructGetSize($tSize)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iSize, $tMemMap)
		$iRet = _SendMessage($hWnd, $TB_GETMAXSIZE, 0, $pMemory, 0, "wparam", "ptr")
		_MemRead($tMemMap, $pMemory, $tSize, $iSize)
		_MemFree($tMemMap)
	EndIf
	$aSize[0] = DllStructGetData($tSize, "X")
	$aSize[1] = DllStructGetData($tSize, "Y")
	Return SetError($iRet = 0, 0, $aSize)
EndFunc   ;==>_GUICtrlToolbar_GetMaxSize

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetMetrics
; Description ...: Retrieves the metrics of a toolbar control
; Syntax.........: _GUICtrlToolbar_GetMetrics($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Array with the following format:
;                  |[0] - Width of the padding inside the toolbar buttons
;                  |[1] - Height of the padding inside the toolbar buttons
;                  |[2] - Width of the space between toolbar buttons
;                  |[3] - Height of the space between toolbar buttons
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......: Minimum OS - Windows XP
; Related .......: _GUICtrlToolbar_SetMetrics
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetMetrics($hWnd)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)
	Local $aMetrics[4]

	Local $tMetrics = DllStructCreate($tagTBMETRICS)
	Local $iMetrics = DllStructGetSize($tMetrics)
	Local $iMask = BitOR($TBMF_PAD, $TBMF_BUTTONSPACING)
	DllStructSetData($tMetrics, "Size", $iMetrics)
	DllStructSetData($tMetrics, "Mask", $iMask)
	If _WinAPI_InProcess($hWnd, $gh_TBLastWnd) Then
		_SendMessage($hWnd, $TB_GETMETRICS, 0, $tMetrics, 0, "wparam", "struct*")
	Else
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iMetrics, $tMemMap)
		_SendMessage($hWnd, $TB_GETMETRICS, 0, $pMemory, 0, "wparam", "ptr")
		_MemRead($tMemMap, $pMemory, $tMetrics, $iMetrics)
		_MemFree($tMemMap)
	EndIf
	$aMetrics[0] = DllStructGetData($tMetrics, "XPad")
	$aMetrics[1] = DllStructGetData($tMetrics, "YPad")
	$aMetrics[2] = DllStructGetData($tMetrics, "XSpacing")
	$aMetrics[3] = DllStructGetData($tMetrics, "YSpacing")
	Return $aMetrics
EndFunc   ;==>_GUICtrlToolbar_GetMetrics

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetPadding
; Description ...: Retrieves the horizontal and vertical padding
; Syntax.........: _GUICtrlToolbar_GetPadding($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Array with the following format:
;                  |[0] - Horizontal padding
;                  |[1] - Vertical padding
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetPadding
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetPadding($hWnd)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $aPad[2]

	Local $iPad = _SendMessage($hWnd, $TB_GETPADDING)
	$aPad[0] = _WinAPI_LoWord($iPad)
	$aPad[1] = _WinAPI_HiWord($iPad)
	Return $aPad
EndFunc   ;==>_GUICtrlToolbar_GetPadding

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetRows
; Description ...: Retrieves the number of rows of buttons
; Syntax.........: _GUICtrlToolbar_GetRows($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Number of rows
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetRows
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetRows($hWnd)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_GETROWS)
EndFunc   ;==>_GUICtrlToolbar_GetRows

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetString
; Description ...: Retrieves a string from the string pool
; Syntax.........: _GUICtrlToolbar_GetString($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Index of the string
; Return values .: Success      - Specified string
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......: This message returns the specified string from the control's string pool.  It does not necessarily  correspond
;                  to the text string currently being displayed by a button. To retrieve a button's current text string, send use
;                  _GUICtrlToolbar_GetButtonText.
; Related .......: _GUICtrlToolbar_AddString, _GUICtrlToolbar_GetButtonText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetString($hWnd, $iIndex)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlToolbar_GetUnicodeFormat($hWnd)

	Local $iBuffer
	If $fUnicode Then
		$iBuffer = _SendMessage($hWnd, $TB_GETSTRINGW, _WinAPI_MakeLong(0, $iIndex), 0, 0, "long") + 1
	Else
		$iBuffer = _SendMessage($hWnd, $TB_GETSTRINGA, _WinAPI_MakeLong(0, $iIndex), 0, 0, "long") + 1
	EndIf

	If $iBuffer = 0 Then Return SetError(-1, 0, "")
	If $iBuffer = 1 Then Return ""
	Local $tBuffer
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
		$iBuffer *= 2
	Else
		$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
	EndIf
	Local $iRet
	If _WinAPI_InProcess($hWnd, $gh_TBLastWnd) Then
		$iRet = _SendMessage($hWnd, $TB_GETSTRINGW, _WinAPI_MakeLong($iBuffer, $iIndex), $tBuffer, 0, "long", "struct*")
	Else
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iBuffer, $tMemMap)
		If $fUnicode Then
			$iRet = _SendMessage($hWnd, $TB_GETSTRINGW, _WinAPI_MakeLong($iBuffer, $iIndex), $pMemory, 0, "long", "ptr")
		Else
			$iRet = _SendMessage($hWnd, $TB_GETSTRINGA, _WinAPI_MakeLong($iBuffer, $iIndex), $pMemory, 0, "long", "ptr")
		EndIf
		_MemRead($tMemMap, $pMemory, $tBuffer, $iBuffer)
		_MemFree($tMemMap)
	EndIf
	Return SetError($iRet = -1, 0, DllStructGetData($tBuffer, "Text"))
EndFunc   ;==>_GUICtrlToolbar_GetString

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetStyle
; Description ...: Retrieves the styles currently in use for a toolbar control
; Syntax.........: _GUICtrlToolbar_GetStyle($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Control styles. Can be a combination of the following:
;                  |$TBSTYLE_TOOLTIPS     - Creates a ToolTip control
;                  |$TBSTYLE_WRAPABLE     - Creates a toolbar that can have multiple lines of buttons
;                  |$TBSTYLE_ALTDRAG      - Allows users to change a toolbar button's position by dragging it
;                  |$TBSTYLE_FLAT         - Creates a flat toolbar
;                  |$TBSTYLE_LIST         - Creates a flat toolbar with button text to the right of the bitmap
;                  |$TBSTYLE_CUSTOMERASE  - Sends $NM_CUSTOMDRAW messages when processing $WM_ERASEBKGND messages
;                  |$TBSTYLE_REGISTERDROP - Sends $TBN_GETOBJECT messages to request drop target objects
;                  |$TBSTYLE_TRANSPARENT  - Creates a transparent toolbar
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetStyle($hWnd)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_GETSTYLE)
EndFunc   ;==>_GUICtrlToolbar_GetStyle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetStyleAltDrag
; Description ...: Indicates that the control allows buttons to be dragged
; Syntax.........: _GUICtrlToolbar_GetStyleAltDrag($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: True         - Style is present
;                  False        - Style is not present
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetStyleAltDrag
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetStyleAltDrag($hWnd)
	Return BitAND(_GUICtrlToolbar_GetStyle($hWnd), $TBSTYLE_ALTDRAG) <> 0
EndFunc   ;==>_GUICtrlToolbar_GetStyleAltDrag

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetStyleCustomErase
; Description ...: Indicates that the control generates NM_CUSTOMDRAW notification messages
; Syntax.........: _GUICtrlToolbar_GetStyleCustomErase($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: True         - Style is present
;                  False        - Style is not present
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetStyleCustomErase
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetStyleCustomErase($hWnd)
	Return BitAND(_GUICtrlToolbar_GetStyle($hWnd), $TBSTYLE_CUSTOMERASE) <> 0
EndFunc   ;==>_GUICtrlToolbar_GetStyleCustomErase

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetStyleFlat
; Description ...: Indicates that the control is flat
; Syntax.........: _GUICtrlToolbar_GetStyleFlat($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: True         - Style is present
;                  False        - Style is not present
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetStyleFlat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetStyleFlat($hWnd)
	Return BitAND(_GUICtrlToolbar_GetStyle($hWnd), $TBSTYLE_FLAT) <> 0
EndFunc   ;==>_GUICtrlToolbar_GetStyleFlat

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetStyleList
; Description ...: Indicates that the control has button text to the right of the bitmap
; Syntax.........: _GUICtrlToolbar_GetStyleList($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: True         - Style is present
;                  False        - Style is not present
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetStyleList
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetStyleList($hWnd)
	Return BitAND(_GUICtrlToolbar_GetStyle($hWnd), $TBSTYLE_LIST) <> 0
EndFunc   ;==>_GUICtrlToolbar_GetStyleList

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetStyleRegisterDrop
; Description ...: Indicates that the control generates TBN_GETOBJECT notification messages
; Syntax.........: _GUICtrlToolbar_GetStyleRegisterDrop($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: True         - Style is present
;                  False        - Style is not present
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetStyleRegisterDrop
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetStyleRegisterDrop($hWnd)
	Return BitAND(_GUICtrlToolbar_GetStyle($hWnd), $TBSTYLE_REGISTERDROP) <> 0
EndFunc   ;==>_GUICtrlToolbar_GetStyleRegisterDrop

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetStyleToolTips
; Description ...: Indicates that the control has tooltips
; Syntax.........: _GUICtrlToolbar_GetStyleToolTips($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: True         - Style is present
;                  False        - Style is not present
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetStyleToolTips
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetStyleToolTips($hWnd)
	Return BitAND(_GUICtrlToolbar_GetStyle($hWnd), $TBSTYLE_TOOLTIPS) <> 0
EndFunc   ;==>_GUICtrlToolbar_GetStyleToolTips

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetStyleTransparent
; Description ...: Indicates that the control is transparent
; Syntax.........: _GUICtrlToolbar_GetStyleTransparent($hWnd)
; Parameters ....: $hWnd         - Handle to the control
; Return values .: True         - Style is present
;                  False        - Style is not present
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetStyleTransparent
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetStyleTransparent($hWnd)
	Return BitAND(_GUICtrlToolbar_GetStyle($hWnd), $TBSTYLE_TRANSPARENT) <> 0
EndFunc   ;==>_GUICtrlToolbar_GetStyleTransparent

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetStyleWrapable
; Description ...: Indicates that the control is wrapable
; Syntax.........: _GUICtrlToolbar_GetStyleWrapable($hWnd)
; Parameters ....: $hWnd         - Handle to the control
; Return values .: True         - Style is present
;                  False        - Style is not present
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetStyleWrapable
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetStyleWrapable($hWnd)
	Return BitAND(_GUICtrlToolbar_GetStyle($hWnd), $TBSTYLE_WRAPABLE) <> 0
EndFunc   ;==>_GUICtrlToolbar_GetStyleWrapable

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetTextRows
; Description ...: Retrieves the maximum number of text rows that can be displayed on a button
; Syntax.........: _GUICtrlToolbar_GetTextRows($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Maximum number of text rows that can be displayed on a button
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetTextRows($hWnd)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_GETTEXTROWS)
EndFunc   ;==>_GUICtrlToolbar_GetTextRows

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetToolTips
; Description ...: Retrieves the handle to the ToolTip control
; Syntax.........: _GUICtrlToolbar_GetToolTips($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - ToolTip handle
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetToolTips
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetToolTips($hWnd)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return HWnd(_SendMessage($hWnd, $TB_GETTOOLTIPS))
EndFunc   ;==>_GUICtrlToolbar_GetToolTips

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_GetUnicodeFormat
; Description ...: Retrieves the Unicode character format flag
; Syntax.........: _GUICtrlToolbar_GetUnicodeFormat($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: True         - Control is using Unicode characters
;                  False        - Control is using ANSI characters
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_SetUnicodeFormat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_GetUnicodeFormat($hWnd)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_GETUNICODEFORMAT) <> 0
EndFunc   ;==>_GUICtrlToolbar_GetUnicodeFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_HideButton
; Description ...: Hides or shows the specified button
; Syntax.........: _GUICtrlToolbar_HideButton($hWnd, $iCommandID[, $fHide = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
;                  $fHide       - State indicator:
;                  | True - Button will be hidden
;                  |False - Button will be made visible
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_EnableButton
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_HideButton($hWnd, $iCommandID, $fHide = True)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_HIDEBUTTON, $iCommandID, $fHide) <> 0
EndFunc   ;==>_GUICtrlToolbar_HideButton

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_HighlightButton
; Description ...: Sets the highlight state of a given button control
; Syntax.........: _GUICtrlToolbar_HighlightButton($hWnd, $iCommandID[, $fHighlight = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
;                  $fHighlight  - Highlight state:
;                  | True - Button will be highlighted
;                  |False - Button will be unhighlighted
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_HighlightButton($hWnd, $iCommandID, $fHighlight = True)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_MARKBUTTON, $iCommandID, $fHighlight) <> 0
EndFunc   ;==>_GUICtrlToolbar_HighlightButton

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_HitTest
; Description ...: Determines where a point lies within the control
; Syntax.........: _GUICtrlToolbar_HitTest($hWnd, $iX, $iY)
; Parameters ....: $hWnd        - Handle to the control
;                  $iX          - X position to test
;                  $iY          - Y position to test
; Return values .: Success      - If the value is zero or a positive value, it is the zero based index of the  nonseparator  item
;                  +in which the point lies.
;                  Failure      - If the value is negative, the point does not lie within a button
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......: The absolute value of the return value is the index of a separator item or the nearest nonseparator item.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_HitTest($hWnd, $iX, $iY)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $tPoint = DllStructCreate($tagPOINT)
	DllStructSetData($tPoint, "X", $iX)
	DllStructSetData($tPoint, "Y", $iY)
	Local $iRet
	If _WinAPI_InProcess($hWnd, $gh_TBLastWnd) Then
		$iRet = _SendMessage($hWnd, $TB_HITTEST, 0, $tPoint, 0, "wparam", "struct*")
	Else
		Local $iPoint = DllStructGetSize($tPoint)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iPoint, $tMemMap)
		_MemWrite($tMemMap, $tPoint, $pMemory, $iPoint)
		$iRet = _SendMessage($hWnd, $TB_HITTEST, 0, $pMemory, 0, "wparam", "ptr")
		_MemFree($tMemMap)
	EndIf
	Return $iRet
EndFunc   ;==>_GUICtrlToolbar_HitTest

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_IndexToCommand
; Description ...: Retrieves the command identifier associated with the button
; Syntax.........: _GUICtrlToolbar_IndexToCommand($hWnd, $iIndex)
; Parameters ....: $hWnd       - Handle to the control
;                  $iIndex     - Button index
; Return values .: Success      - Button command identifier
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_CommandToIndex
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_IndexToCommand($hWnd, $iIndex)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $tButton = DllStructCreate($tagTBBUTTON)
	If _WinAPI_InProcess($hWnd, $gh_TBLastWnd) Then
		_SendMessage($hWnd, $TB_GETBUTTON, $iIndex, $tButton, 0, "wparam", "struct*")
	Else
		Local $iButton = DllStructGetSize($tButton)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iButton, $tMemMap)
		_MemWrite($tMemMap, $tButton, $pMemory, $iButton)
		_SendMessage($hWnd, $TB_GETBUTTON, $iIndex, $pMemory, 0, "wparam", "ptr")
		_MemRead($tMemMap, $pMemory, $tButton, $iButton)
		_MemFree($tMemMap)
	EndIf
	Return DllStructGetData($tButton, "Command")
EndFunc   ;==>_GUICtrlToolbar_IndexToCommand

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_InsertButton
; Description ...: Inserts a button
; Syntax.........: _GUICtrlToolbar_InsertButton($hWnd, $iIndex, $iID, $iImage[, $sText = ""[, $iStyle = 0[, $iState = 4[, $iParam = 0]]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of a button
;                  $iID         - Command ID
;                  $iImage      - Zero based image index
;                  $sText       - Button text
;                  $iStyle      - Button style. Can be a combination of the following:
;                  |$BTNS_AUTOSIZE      - The toolbar control should not assign the standard width to the button
;                  |$BTNS_BUTTON        - Standard button
;                  |$BTNS_CHECK         - Toggles between the pressed and nonpressed
;                  |$BTNS_CHECKGROUP    - Button that stays pressed until another button in the group is pressed
;                  |$BTNS_DROPDOWN      - Creates a drop-down style button that can display a list
;                  |$BTNS_GROUP         - Button that stays pressed until another button in the group is pressed
;                  |$BTNS_NOPREFIX      - The button text will not have an accelerator prefix
;                  |$BTNS_SEP           - Creates a separator
;                  |$BTNS_SHOWTEXT      - Specifies that button text should be displayed
;                  |$BTNS_WHOLEDROPDOWN - Specifies that the button will have a drop-down arrow
;                  $iState      - Button state. Can be a combination of the following:
;                  |$TBSTATE_CHECKED       - The button has the $TBSTYLE_CHECK style and is being clicked
;                  |$TBSTATE_PRESSED       - The button is being clicked
;                  |$TBSTATE_ENABLED       - The button accepts user input
;                  |$TBSTATE_HIDDEN        - The button is not visible and cannot receive user input
;                  |$TBSTATE_INDETERMINATE - The button is grayed
;                  |$TBSTATE_WRAP          - The button is followed by a line break
;                  |$TBSTATE_ELLIPSES      - The button's text is cut off and an ellipsis is displayed
;                  |$TBSTATE_MARKED        - The button is marked
;                  $iParam      - Application-defined value
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......: Inserts the new button to the left of the button at iIndex
; Related .......: _GUICtrlToolbar_AddButton
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_InsertButton($hWnd, $iIndex, $iID, $iImage, $sText = "", $iStyle = 0, $iState = 4, $iParam = 0)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlToolbar_GetUnicodeFormat($hWnd)

	Local $tBuffer, $iRet

	Local $tButton = DllStructCreate($tagTBBUTTON)
	Local $iBuffer = StringLen($sText) + 1
	If $iBuffer > 1 Then
		If $fUnicode Then
			$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
			$iBuffer *= 2
		Else
			$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
		EndIf
		DllStructSetData($tBuffer, "Text", $sText)
		DllStructSetData($tButton, "String", DllStructGetPtr($tBuffer))
	EndIf
	DllStructSetData($tButton, "Bitmap", $iImage)
	DllStructSetData($tButton, "Command", $iID)
	DllStructSetData($tButton, "State", $iState)
	DllStructSetData($tButton, "Style", $iStyle)
	DllStructSetData($tButton, "Param", $iParam)
	If _WinAPI_InProcess($hWnd, $gh_TBLastWnd) Then
		$iRet = _SendMessage($hWnd, $TB_INSERTBUTTONW, $iIndex, $tButton, 0, "wparam", "struct*")
	Else
		Local $iButton = DllStructGetSize($tButton)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iButton + $iBuffer, $tMemMap)
		Local $pText = $pMemory + $iButton
		_MemWrite($tMemMap, $tButton, $pMemory, $iButton)
		If $iBuffer > 1 Then
			DllStructSetData($tButton, "String", $pText)
			_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
		EndIf
		If $fUnicode Then
			$iRet = _SendMessage($hWnd, $TB_INSERTBUTTONW, $iIndex, $pMemory, 0, "wparam", "ptr")
		Else
			$iRet = _SendMessage($hWnd, $TB_INSERTBUTTONA, $iIndex, $pMemory, 0, "wparam", "ptr")
		EndIf
		_MemFree($tMemMap)
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlToolbar_InsertButton

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_InsertMarkHitTest
; Description ...: Retrieves the insertion mark information for a point
; Syntax.........: _GUICtrlToolbar_InsertMarkHitTest($hWnd, $iX, $iY)
; Parameters ....: $hWnd        - Handle to the control
;                  $iX          - X position relative to the client area
;                  $iY          - Y position relative to the client area
; Return values .: Success      - Array with the following format:
;                  |[0] - Zero based index of the insertion mark or -1 for no insertion mark
;                  |[1] - Defines the insertion position. This can be one of the following values:
;                  | 0 - To the left
;                  | 1 - To the right
;                  | 2 - On the background of the toolbar
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_InsertMarkHitTest($hWnd, $iX, $iY)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $aMark[2], $iRet

	Local $tPoint = DllStructCreate($tagPOINT)
	Local $tMark = DllStructCreate($tagTBINSERTMARK)
	DllStructSetData($tPoint, "X", $iX)
	DllStructSetData($tPoint, "Y", $iY)
	If _WinAPI_InProcess($hWnd, $gh_TBLastWnd) Then
		$iRet = _SendMessage($hWnd, $TB_INSERTMARKHITTEST, $tPoint, $tMark, 0, "struct*", "struct*")
	Else
		Local $iPoint = DllStructGetSize($tPoint)
		Local $iMark = DllStructGetSize($tMark)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iPoint + $iMark, $tMemMap)
		Local $pMarkPtr = $pMemory + $iPoint
		_MemWrite($tMemMap, $tPoint, $pMemory, $iPoint)
		$iRet = _SendMessage($hWnd, $TB_INSERTMARKHITTEST, $pMemory, $pMarkPtr, 0, "wparam", "ptr")
		_MemRead($tMemMap, $pMarkPtr, $tMark, $iMark)
		_MemFree($tMemMap)
	EndIf
	$aMark[0] = DllStructGetData($tMark, "Button")
	$aMark[1] = DllStructGetData($tMark, "Flags")
	Return SetError($iRet <> 0, 0, $aMark)
EndFunc   ;==>_GUICtrlToolbar_InsertMarkHitTest

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_IsButtonChecked
; Description ...: Indicates whether the specified button is checked
; Syntax.........: _GUICtrlToolbar_IsButtonChecked($hWnd, $iCommandID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
; Return values .: True         - Button is checked
;                  False        - Button is not checked
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_IsButtonChecked($hWnd, $iCommandID)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_ISBUTTONCHECKED, $iCommandID) <> 0
EndFunc   ;==>_GUICtrlToolbar_IsButtonChecked

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_IsButtonEnabled
; Description ...: Indicates whether the specified button is enabled
; Syntax.........: _GUICtrlToolbar_IsButtonEnabled($hWnd, $iCommandID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
; Return values .: True         - Button is enabled
;                  False        - Button is not enabled
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_IsButtonEnabled($hWnd, $iCommandID)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_ISBUTTONENABLED, $iCommandID) <> 0
EndFunc   ;==>_GUICtrlToolbar_IsButtonEnabled

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_IsButtonHidden
; Description ...: Indicates whether the specified button is hidden
; Syntax.........: _GUICtrlToolbar_IsButtonHidden($hWnd, $iCommandID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
; Return values .: True         - Button is hidden
;                  False        - Button is not hidden
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_IsButtonHidden($hWnd, $iCommandID)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_ISBUTTONHIDDEN, $iCommandID) <> 0
EndFunc   ;==>_GUICtrlToolbar_IsButtonHidden

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_IsButtonHighlighted
; Description ...: Indicates whether the specified button is hilighted
; Syntax.........: _GUICtrlToolbar_IsButtonHighlighted($hWnd, $iCommandID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
; Return values .: True         - Button is hilighted
;                  False        - Button is not hilighted
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_IsButtonHighlighted($hWnd, $iCommandID)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_ISBUTTONHIGHLIGHTED, $iCommandID) <> 0
EndFunc   ;==>_GUICtrlToolbar_IsButtonHighlighted

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_IsButtonIndeterminate
; Description ...: Indicates whether the specified button is indeterminate
; Syntax.........: _GUICtrlToolbar_IsButtonIndeterminate($hWnd, $iCommandID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
; Return values .: True         - Button is indeterminate
;                  False        - Button is not indeterminate
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_IsButtonIndeterminate($hWnd, $iCommandID)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_ISBUTTONINDETERMINATE, $iCommandID) <> 0
EndFunc   ;==>_GUICtrlToolbar_IsButtonIndeterminate

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_IsButtonPressed
; Description ...: Indicates that the button is being clicked
; Syntax.........: _GUICtrlToolbar_IsButtonPressed($hWnd, $iCommandID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
; Return values .: True         - Button is pressed
;                  False        - Button is not pressed
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_IsButtonPressed($hWnd, $iCommandID)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_ISBUTTONPRESSED, $iCommandID) <> 0
EndFunc   ;==>_GUICtrlToolbar_IsButtonPressed

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_LoadBitmap
; Description ...: Adds a bitmap to the image list from a file
; Syntax.........: _GUICtrlToolbar_LoadBitmap($hWnd, $sFileName)
; Parameters ....: $hWnd        - Handle to toolbar
;                  $sFileName   - Fully qualified path to bitmap file
; Return values .: Success      - The zero based index of the new image
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_AddBitmap
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_LoadBitmap($hWnd, $sFileName)

	Local $aSize = _GUICtrlToolbar_GetButtonSize($hWnd)
	Local $hBitmap = _WinAPI_LoadImage(0, $sFileName, 0, $aSize[1], $aSize[0], $__TOOLBARCONSTANT_LR_LOADFROMFILE)
	If $hBitmap = 0 Then Return SetError(-1, -1, -1)
	Return _GUICtrlToolbar_AddBitmap($hWnd, 1, 0, $hBitmap)
EndFunc   ;==>_GUICtrlToolbar_LoadBitmap

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_LoadImages
; Description ...: Loads system defined button images into a toolbar control's image list
; Syntax.........: _GUICtrlToolbar_LoadImages($hWnd, $iBitMapID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iBitMapID   - Identifier of a system-defined button image list. Can be set to one of the following values:
;                  |$IDB_HIST_LARGE_COLOR
;                  |$IDB_HIST_SMALL_COLOR
;                  |$IDB_STD_LARGE_COLOR
;                  |$IDB_STD_SMALL_COLOR
;                  |$IDB_VIEW_LARGE_COLOR
;                  |$IDB_VIEW_SMALL_COLOR
;                  |$IDB_HIST_NORMAL
;                  |$IDB_HIST_HOT
;                  |$IDB_HIST_DISABLED
;                  |$IDB_HIST_PRESSED
; Return values .: Success      - The count of images in the image list, not including the ones just added
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_LoadImages($hWnd, $iBitMapID)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_LOADIMAGES, $iBitMapID, $__TOOLBARCONSTANT_HINST_COMMCTRL)
EndFunc   ;==>_GUICtrlToolbar_LoadImages

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_MapAccelerator
; Description ...: Determines the ID of the button that corresponds to the specified accelerator
; Syntax.........: _GUICtrlToolbar_MapAccelerator($hWnd, $cAccel)
; Parameters ....: $hWnd        - Handle to the control
;                  $cAccel      - Accelerator character
; Return values .: Success      - Command ID of the button that has cAccel as its accelerator character
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_MapAccelerator($hWnd, $cAccel)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $tCommand = DllStructCreate("int Data")
	If _WinAPI_InProcess($hWnd, $gh_TBLastWnd) Then
		_SendMessage($hWnd, $TB_MAPACCELERATORW, Asc($cAccel), $tCommand, 0, "wparam", "struct*")
	Else
		Local $iCommand = DllStructGetSize($tCommand)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iCommand, $tMemMap)
		_SendMessage($hWnd, $TB_MAPACCELERATORW, Asc($cAccel), $pMemory, 0, "wparam", "ptr")
		_MemRead($tMemMap, $pMemory, $tCommand, $iCommand)
		_MemFree($tMemMap)
	EndIf
	Return DllStructGetData($tCommand, "Data")
EndFunc   ;==>_GUICtrlToolbar_MapAccelerator

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_MoveButton
; Description ...: Moves a button from one index to another
; Syntax.........: _GUICtrlToolbar_MoveButton($hWnd, $iOldPos, $iNewPos)
; Parameters ....: $hWnd        - Handle to the control
;                  $iOldPos     - Zero based index of the button to be moved
;                  $iNewPos     - Zero based index where the button will be moved
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_MoveButton($hWnd, $iOldPos, $iNewPos)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_MOVEBUTTON, $iOldPos, $iNewPos) <> 0
EndFunc   ;==>_GUICtrlToolbar_MoveButton

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_PressButton
; Description ...: Presses or releases the specified button
; Syntax.........: _GUICtrlToolbar_PressButton($hWnd, $iCommandID[, $fPress = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
;                  $fPress      - Pressed state:
;                  | True - Button will be set to a pressed state
;                  |False - Button will be set to an unpressed state
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function does not fire the click event on dropdown style buttons. You should use the _GUICtrlToolbar_ClickButton
;                  function if you want to ensure that the button click event is fired, regardless of the button style.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_PressButton($hWnd, $iCommandID, $fPress = True)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_PRESSBUTTON, $iCommandID, $fPress) <> 0
EndFunc   ;==>_GUICtrlToolbar_PressButton

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetAnchorHighlight
; Description ...: Sets the anchor highlight setting
; Syntax.........: _GUICtrlToolbar_SetAnchorHighlight($hWnd, $fAnchor)
; Parameters ....: $hWnd        - Handle to the control
;                  $fAnchor     - Anchor highlighting setting:
;                  | True - Anchor highlighting will be enabled
;                  |False - Anchor highlighting will be disabled
; Return values .: Success      - The previous anchor highlight setting
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Anchor highlighting means that the last highlighted  item  will  remain  highlighted  until  another  item  is
;                  highlighted. This occurs even if the cursor leaves the toolbar control.
; Related .......: _GUICtrlToolbar_GetAnchorHighlight
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetAnchorHighlight($hWnd, $fAnchor)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_SETANCHORHIGHLIGHT, $fAnchor)
EndFunc   ;==>_GUICtrlToolbar_SetAnchorHighlight

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetBitmapSize
; Description ...: Sets the size of the bitmapped images to be added to a toolbar
; Syntax.........: _GUICtrlToolbar_SetBitmapSize($hWnd, $iWidth, $iHeight)
; Parameters ....: $hWnd        - Handle to the control
;                  $iWidth      - Width, in pixels, of the bitmapped images
;                  $iHeight     - Height, in pixels, of the bitmapped images
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......: The size can be set only before adding any bitmaps to the toolbar.  If an application does not explicitly  set
;                  the bitmap size, the size defaults to 16 by 15 pixels.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetBitmapSize($hWnd, $iWidth, $iHeight)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_SETBITMAPSIZE, 0, _WinAPI_MakeLong($iWidth, $iHeight), 0, "wparam", "long") <> 0
EndFunc   ;==>_GUICtrlToolbar_SetBitmapSize

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetButtonBitMap
; Description ...: Sets the index of the bitmap associated with a button
; Syntax.........: _GUICtrlToolbar_SetButtonBitMap($hWnd, $iCommandID, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
;                  $iIndex      - Zero based index of an images image list
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetButtonBitmap
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetButtonBitMap($hWnd, $iCommandID, $iIndex)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_CHANGEBITMAP, $iCommandID, $iIndex) <> 0
EndFunc   ;==>_GUICtrlToolbar_SetButtonBitMap

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetButtonInfo
; Description ...: Sets extended information for a button
; Syntax.........: _GUICtrlToolbar_SetButtonInfo($hWnd, $iCommandID[, $iImage = -3[, $iState = -1[, $iStyle = -1[, $iWidth = -1[, $iParam = -1]]]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
;                  $iImage      - Zero based index of the button image.  Set this parameter to -1 and the control will  send  the
;                  +$TBN_GETDISPINFO notification to retrieve the image index when it is needed.  Set this to -2 to indicate that
;                  +the button does not have an image.  The button layout will only include space for the text.  If the button is
;                  +a separator, this is the width of the separator, in pixels.
;                  $iState      - Button state. Can be a combination of the following:
;                  |$TBSTATE_CHECKED       - The button being clicked
;                  |$TBSTATE_PRESSED       - The button is being clicked
;                  |$TBSTATE_ENABLED       - The button accepts user input
;                  |$TBSTATE_HIDDEN        - The button is not visible
;                  |$TBSTATE_INDETERMINATE - The button is grayed
;                  |$TBSTATE_WRAP          - The button is followed by a line break
;                  |$TBSTATE_ELLIPSES      - The button's text is cut off
;                  |$TBSTATE_MARKED        - The button is marked
;                  $iStyle      - Button style. Can be a combination of the following:
;                  |$BTNS_AUTOSIZE      - The control should not assign the standard width
;                  |$BTNS_BUTTON        - Standard button
;                  |$BTNS_CHECK         - Toggles between the pressed and nonpressed
;                  |$BTNS_CHECKGROUP    - Button that stays pressed until another button is pressed
;                  |$BTNS_DROPDOWN      - Creates a drop-down style button that can display a list
;                  |$BTNS_GROUP         - Button that stays pressed until another button is pressed
;                  |$BTNS_NOPREFIX      - The button text will not have an accelerator prefix
;                  |$BTNS_SEP           - Creates a separator
;                  |$BTNS_SHOWTEXT      - Specifies that button text should be displayed
;                  |$BTNS_WHOLEDROPDOWN - Specifies that the button will have a drop-down arrow
;                  $iWidth      - Button width
;                  $iParam      - Application-defined value
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetButtonInfo, $tagTBBUTTONINFO
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetButtonInfo($hWnd, $iCommandID, $iImage = -3, $iState = -1, $iStyle = -1, $iWidth = -1, $iParam = -1)
	Local $iMask = 0

	Local $tButton = DllStructCreate($tagTBBUTTONINFO)
	If $iImage <> -3 Then
		$iMask = $TBIF_IMAGE
		DllStructSetData($tButton, "Image", $iImage)
	EndIf
	If $iState <> -1 Then
		$iMask = BitOR($iMask, $TBIF_STATE)
		DllStructSetData($tButton, "State", $iState)
	EndIf
	If $iStyle <> -1 Then
		$iMask = BitOR($iMask, $TBIF_STYLE)
		DllStructSetData($tButton, "Style", $iStyle)
	EndIf
	If $iWidth <> -1 Then
		$iMask = BitOR($iMask, $TBIF_SIZE)
		DllStructSetData($tButton, "CX", $iWidth)
	EndIf
	If $iParam <> -1 Then
		$iMask = BitOR($iMask, $TBIF_LPARAM)
		DllStructSetData($tButton, "Param", $iParam)
	EndIf
	DllStructSetData($tButton, "Mask", $iMask)
	Return _GUICtrlToolbar_SetButtonInfoEx($hWnd, $iCommandID, $tButton)
EndFunc   ;==>_GUICtrlToolbar_SetButtonInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetButtonInfoEx
; Description ...: Sets extended information for a button
; Syntax.........: _GUICtrlToolbar_SetButtonInfoEx($hWnd, $iCommandID, $tButton)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
;                  $tButton     - $tagBUTTONINFO structure
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetButtonInfoEx, $tagTBBUTTONINFO
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetButtonInfoEx($hWnd, $iCommandID, $tButton)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $iButton = DllStructGetSize($tButton)
	DllStructSetData($tButton, "Size", $iButton)
	Local $iRet
	If _WinAPI_InProcess($hWnd, $gh_TBLastWnd) Then
		$iRet = _SendMessage($hWnd, $TB_SETBUTTONINFOW, $iCommandID, $tButton, 0, "wparam", "struct*")
	Else
		Local $iBuffer = DllStructGetData($tButton, "TextMax")
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iButton + $iBuffer, $tMemMap)
		Local $pBuffer = $pMemory + $iButton
		DllStructSetData($tButton, "Text", $pBuffer)
		_MemWrite($tMemMap, $tButton, $pMemory, $iButton)
		_MemWrite($tMemMap, $pBuffer, $pBuffer, $iBuffer)
		$iRet = _SendMessage($hWnd, $TB_SETBUTTONINFOW, $iCommandID, $pMemory, 0, "wparam", "ptr")
		_MemFree($tMemMap)
	EndIf

	Return $iRet <> 0
EndFunc   ;==>_GUICtrlToolbar_SetButtonInfoEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetButtonParam
; Description ...: Sets the button param value
; Syntax.........: _GUICtrlToolbar_SetButtonParam($hWnd, $iCommandID, $iParam)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
;                  $iParam      - Application-defined value
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetButtonParam
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetButtonParam($hWnd, $iCommandID, $iParam)
	Local $tButton = DllStructCreate($tagTBBUTTONINFO)
	DllStructSetData($tButton, "Mask", $TBIF_LPARAM)
	DllStructSetData($tButton, "Param", $iParam)
	Return _GUICtrlToolbar_SetButtonInfoEx($hWnd, $iCommandID, $tButton)
EndFunc   ;==>_GUICtrlToolbar_SetButtonParam

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetButtonSize
; Description ...: Sets the size of the buttons to be added to a toolbar
; Syntax.........: _GUICtrlToolbar_SetButtonSize($hWnd, $iHeight, $iWidth)
; Parameters ....: $hWnd        - Handle to the control
;                  $iHeight     - Height, in pixels, of the buttons
;                  $iWidth      - Width, in pixels, of the buttons
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......: The size can be set only before adding any buttons to the toolbar.  If an application does not explicitly  set
;                  the button size, the size defaults to 24 by 22 pixels.
; Related .......: _GUICtrlToolbar_GetButtonSize
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetButtonSize($hWnd, $iHeight, $iWidth)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_SETBUTTONSIZE, 0, _WinAPI_MakeLong($iWidth, $iHeight), 0, "wparam", "long") <> 0
EndFunc   ;==>_GUICtrlToolbar_SetButtonSize

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetButtonState
; Description ...: Sets information about the state of the specified button
; Syntax.........: _GUICtrlToolbar_SetButtonState($hWnd, $iCommandID, $iState)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
;                  $iState      - Button state. Can be one or more of the following:
;                  |$TBSTATE_CHECKED       - The button has the $TBSTYLE_CHECK style and is being clicked
;                  |$TBSTATE_PRESSED       - The button is being clicked
;                  |$TBSTATE_ENABLED       - The button accepts user input
;                  |$TBSTATE_HIDDEN        - The button is not visible and cannot receive user input
;                  |$TBSTATE_INDETERMINATE - The button is grayed
;                  |$TBSTATE_WRAP          - The button is followed by a line break
;                  |$TBSTATE_ELLIPSES      - The button's text is cut off and an ellipsis is displayed
;                  |$TBSTATE_MARKED        - The button is marked
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetButtonState
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetButtonState($hWnd, $iCommandID, $iState)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_SETSTATE, $iCommandID, $iState) <> 0
EndFunc   ;==>_GUICtrlToolbar_SetButtonState

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetButtonStyle
; Description ...: Sets the style flags of a button
; Syntax.........: _GUICtrlToolbar_SetButtonStyle($hWnd, $iCommandID, $iStyle)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
;                  $iStyle      - Button style. Can be one or more of the following:
;                  |$BTNS_AUTOSIZE      - The toolbar control should not assign the standard width to the button
;                  |$BTNS_CHECK         - Toggles between the pressed and nonpressed
;                  |$BTNS_CHECKGROUP    - Button that stays pressed until another button in the group is pressed
;                  |$BTNS_DROPDOWN      - Drop-down style button that can display a list
;                  |$BTNS_GROUP         - Button that stays pressed until another button in the group is pressed
;                  |$BTNS_NOPREFIX      - The button text will not have an accelerator prefix
;                  |$BTNS_SEP           - Separator
;                  |$BTNS_SHOWTEXT      - Button text should be displayed
;                  |$BTNS_WHOLEDROPDOWN - The button has a drop-down arrow
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetButtonStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetButtonStyle($hWnd, $iCommandID, $iStyle)
	Local $tButton = DllStructCreate($tagTBBUTTONINFO)
	DllStructSetData($tButton, "Mask", $TBIF_STYLE)
	DllStructSetData($tButton, "Style", $iStyle)
	Return _GUICtrlToolbar_SetButtonInfoEx($hWnd, $iCommandID, $tButton)
EndFunc   ;==>_GUICtrlToolbar_SetButtonStyle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetButtonText
; Description ...: Sets the display text of a button
; Syntax.........: _GUICtrlToolbar_SetButtonText($hWnd, $iCommandID, $sText)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
;                  $sText       - Button text
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetButtonText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetButtonText($hWnd, $iCommandID, $sText)
	Local $iBuffer = StringLen($sText) + 1
	Local $tBuffer = DllStructCreate("wchar Text[" & $iBuffer * 2 & "]")
	$iBuffer *= 2
	Local $pBuffer = DllStructGetPtr($tBuffer)
	Local $tButton = DllStructCreate($tagTBBUTTONINFO)
	DllStructSetData($tBuffer, "Text", $sText)
	DllStructSetData($tButton, "Mask", $TBIF_TEXT)
	DllStructSetData($tButton, "Text", $pBuffer)
	DllStructSetData($tButton, "TextMax", $iBuffer)
	Return _GUICtrlToolbar_SetButtonInfoEx($hWnd, $iCommandID, $tButton)
EndFunc   ;==>_GUICtrlToolbar_SetButtonText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetButtonWidth
; Description ...: Sets the minimum and maximum button widths in the toolbar control
; Syntax.........: _GUICtrlToolbar_SetButtonWidth($hWnd, $iMin, $iMax)
; Parameters ....: $hWnd        - Handle to the control
;                  $iMin        - Minimum button width, in pixels
;                  $iMax        - Maximum button width, in pixels
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetButtonWidth($hWnd, $iMin, $iMax)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_SETBUTTONWIDTH, 0, _WinAPI_MakeLong($iMin, $iMax), 0, "wparam", "long") <> 0
EndFunc   ;==>_GUICtrlToolbar_SetButtonWidth

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetCmdID
; Description ...: Sets the command identifier of a toolbar button
; Syntax.........: _GUICtrlToolbar_SetCmdID($hWnd, $iIndex, $iCommandID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the button whose command identifier is to be set
;                  $iCommandID  - Command identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetCmdID($hWnd, $iIndex, $iCommandID)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_SETCMDID, $iIndex, $iCommandID) <> 0
EndFunc   ;==>_GUICtrlToolbar_SetCmdID

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetColorScheme
; Description ...: Sets the color scheme information
; Syntax.........: _GUICtrlToolbar_SetColorScheme($hWnd, $iHighlight, $iShadow)
; Parameters ....: $hWnd        - Handle to the control
;                  $iHighlight  - Highlight color
;                  $iShadow     - Shadow color
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......: The control uses the color scheme information when drawing the 3-D elements in the control
; Related .......: _GUICtrlToolbar_GetColorScheme
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetColorScheme($hWnd, $iHighlight, $iShadow)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $tColor = DllStructCreate($tagCOLORSCHEME)
	Local $iColor = DllStructGetSize($tColor)
	DllStructSetData($tColor, "Size", $iColor)
	DllStructSetData($tColor, "BtnHighlight", $iHighlight)
	DllStructSetData($tColor, "BtnShadow", $iShadow)
	If _WinAPI_InProcess($hWnd, $gh_TBLastWnd) Then
		_SendMessage($hWnd, $TB_SETCOLORSCHEME, 0, $tColor, 0, "wparam", "struct*")
	Else
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iColor, $tMemMap)
		_MemWrite($tMemMap, $tColor, $pMemory, $iColor)
		_SendMessage($hWnd, $TB_SETCOLORSCHEME, 0, $pMemory, 0, "wparam", "ptr")
		_MemFree($tMemMap)
	EndIf
EndFunc   ;==>_GUICtrlToolbar_SetColorScheme

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetDisabledImageList
; Description ...: Sets the disabled image list
; Syntax.........: _GUICtrlToolbar_SetDisabledImageList($hWnd, $hImageList)
; Parameters ....: $hWnd        - Handle to the control
;                  $hImageList  - Handle to the image list that will be set
; Return values .: Success      - The handle to the image list previously used to display disabled buttons
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetDisabledImageList
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetDisabledImageList($hWnd, $hImageList)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_SETDISABLEDIMAGELIST, 0, $hImageList, 0, "wparam", "handle", "handle")
EndFunc   ;==>_GUICtrlToolbar_SetDisabledImageList

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetDrawTextFlags
; Description ...: Sets the text drawing flags for the toolbar
; Syntax.........: _GUICtrlToolbar_SetDrawTextFlags($hWnd, $iMask, $iDTFlags)
; Parameters ....: $hWnd        - Handle to the control
;                  $iMask       - One or more of the DT_ flags, specified in DrawText, that indicate which bits in iDTFlags  will
;                  +be used when drawing the text.
;                  $iDTFlags    - One or more of the DT_ flags, specified in DrawText, that indicate how the button text will  be
;                  +drawn. This value will be passed to the DrawText API when the button text is drawn.
; Return values .: Success      - Returns the previous text drawing flags
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The iMask parameter allows you to specify which flags will be used when drawing the text, even if these  flags
;                  are turned off. For example, if you don't want the $DT_CENTER flag used when drawing text you  would  add  the
;                  $DT_CENTER flag to iMask and not specify the $DT_CENTER flag in  iDTFlags.  This  prevents  the  control  from
;                  passing the $DT_CENTER flag to the DrawText API.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlToolbar_SetDrawTextFlags($hWnd, $iMask, $iDTFlags)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_SETDRAWTEXTFLAGS, $iMask, $iDTFlags)
EndFunc   ;==>_GUICtrlToolbar_SetDrawTextFlags

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetExtendedStyle
; Description ...: Sets the extended styles control
; Syntax.........: _GUICtrlToolbar_SetExtendedStyle($hWnd, $iStyle)
; Parameters ....: $hWnd        - Handle to the control
;                  $iStyle      - Control extended styles. Can be one or more of the following:
;                  |$TBSTYLE_EX_DRAWDDARROWS       - Allows buttons to have a separate dropdown arrow
;                  |$TBSTYLE_EX_MIXEDBUTTONS       - Allows mixing buttons with text and images
;                  |$TBSTYLE_EX_HIDECLIPPEDBUTTONS - Hides partially clipped buttons
;                  |$TBSTYLE_EX_DOUBLEBUFFER       - Requires the toolbar to be double buffered
; Return values .: Success      - The previous extended styles
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetExtendedStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetExtendedStyle($hWnd, $iStyle)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_SETEXTENDEDSTYLE, 0, $iStyle)
EndFunc   ;==>_GUICtrlToolbar_SetExtendedStyle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetHotImageList
; Description ...: Sets the hot button image list
; Syntax.........: _GUICtrlToolbar_SetHotImageList($hWnd, $hImageList)
; Parameters ....: $hWnd        - Handle to the control
;                  $hImageList  - Handle to the image list that will be set
; Return values .: Success      - The handle to the image list previously used to display hot buttons
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetHotImageList
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetHotImageList($hWnd, $hImageList)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_SETHOTIMAGELIST, 0, $hImageList, 0, "wparam", "handle", "handle")
EndFunc   ;==>_GUICtrlToolbar_SetHotImageList

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetHotItem
; Description ...: Sets the hot item
; Syntax.........: _GUICtrlToolbar_SetHotItem($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Index of the item that will be made hot. If this value is -1, none of the items will be hot.
; Return values .: Success      - The index of the previous hot item, or -1 if there was no hot item
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:  A button is considered hot when the cursor is over it
; Related .......: _GUICtrlToolbar_GetHotItem
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetHotItem($hWnd, $iIndex)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_SETHOTITEM, $iIndex)
EndFunc   ;==>_GUICtrlToolbar_SetHotItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetImageList
; Description ...: Sets the default button image list
; Syntax.........: _GUICtrlToolbar_SetImageList($hWnd, $hImageList)
; Parameters ....: $hWnd        - Handle to the control
;                  $hImageList  - Handle to the image list to set. If this parameter is 0, no images are displayed in the buttons.
; Return values .: Success      - The handle to the image list previously used to display buttons in their default state
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetImageList
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetImageList($hWnd, $hImageList)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_SETIMAGELIST, 0, $hImageList, 0, "wparam", "handle", "handle")
EndFunc   ;==>_GUICtrlToolbar_SetImageList

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetIndent
; Description ...: Sets the indentation for the first button control
; Syntax.........: _GUICtrlToolbar_SetIndent($hWnd, $iIndent)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndent     - Indentation in pixels
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetIndent($hWnd, $iIndent)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_SETINDENT, $iIndent) <> 0
EndFunc   ;==>_GUICtrlToolbar_SetIndent

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetIndeterminate
; Description ...: Sets or clears the indeterminate state of the specified button
; Syntax.........: _GUICtrlToolbar_SetIndeterminate($hWnd, $iCommandID[, $fState = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $iCommandID  - Button command ID
;                  $fState      - True if indeterminate, otherwise False
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetIndeterminate($hWnd, $iCommandID, $fState = True)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_INDETERMINATE, $iCommandID, $fState) <> 0
EndFunc   ;==>_GUICtrlToolbar_SetIndeterminate

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetInsertMark
; Description ...: Sets the current insertion mark for the toolbar
; Syntax.........: _GUICtrlToolbar_SetInsertMark($hWnd, $iButton[, $iFlags = 0])
; Parameters ....: $hWnd        - Handle to the control
;                  $iButton     - Zero based index of the insertion mark. If -1, there is no mark.
;                  $iFlags      - Defines where the insertion mark is in relation to iButton:
;                  |0 - Left of the specified button
;                  |1 - Right of the specified button
;                  |2 - Background of the toolbar
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetInsertMark
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetInsertMark($hWnd, $iButton, $iFlags = 0)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $tMark = DllStructCreate($tagTBINSERTMARK)
	DllStructSetData($tMark, "Button", $iButton)
	DllStructSetData($tMark, "Flags", $iFlags)
	If _WinAPI_InProcess($hWnd, $gh_TBLastWnd) Then
		_SendMessage($hWnd, $TB_SETINSERTMARK, 0, $tMark, 0, "wparam", "struct*")
	Else
		Local $iMark = DllStructGetSize($tMark)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iMark, $tMemMap)
		_MemWrite($tMemMap, $tMark, $pMemory, $iMark)
		_SendMessage($hWnd, $TB_SETINSERTMARK, 0, $pMemory, 0, "wparam", "ptr")
		_MemFree($tMemMap)
	EndIf
EndFunc   ;==>_GUICtrlToolbar_SetInsertMark

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetInsertMarkColor
; Description ...: Sets the color used to draw the insertion mark
; Syntax.........: _GUICtrlToolbar_SetInsertMarkColor($hWnd, $iColor)
; Parameters ....: $hWnd        - Handle to the control
;                  $iColor      - Insertion mark color
; Return values .: Success      - Previous insertion mark color
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetInsertMarkColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetInsertMarkColor($hWnd, $iColor)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_SETINSERTMARKCOLOR, 0, $iColor)
EndFunc   ;==>_GUICtrlToolbar_SetInsertMarkColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetMaxTextRows
; Description ...: Sets the maximum number of text rows displayed button
; Syntax.........: _GUICtrlToolbar_SetMaxTextRows($hWnd, $iMaxRows)
; Parameters ....: $hWnd        - Handle to the control
;                  $iMaxRows    - Maximum number of rows of text that can be displayed
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetMaxTextRows($hWnd, $iMaxRows)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_SETMAXTEXTROWS, $iMaxRows) <> 0
EndFunc   ;==>_GUICtrlToolbar_SetMaxTextRows

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetMetrics
; Description ...: Retrieves the metrics of a toolbar control
; Syntax.........: _GUICtrlToolbar_SetMetrics($hWnd, $iXPad, $iYPad, $iXSpacing, $iYSpacing)
; Parameters ....: $hWnd        - Handle to the control
;                  $iXPad       - Width of the padding inside the toolbar buttons
;                  $iYPad       - Height of the padding inside the toolbar buttons
;                  $iXSpacing   - Width of the space between toolbar buttons
;                  $iYSpacing   - Height of the space between toolbar buttons
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......: Minimum OS - Windows XP
; Related .......: _GUICtrlToolbar_GetMetrics
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetMetrics($hWnd, $iXPad, $iYPad, $iXSpacing, $iYSpacing)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $tMetrics = DllStructCreate($tagTBMETRICS)
	Local $iMetrics = DllStructGetSize($tMetrics)
	Local $iMask = BitOR($TBMF_PAD, $TBMF_BUTTONSPACING)
	DllStructSetData($tMetrics, "Size", $iMetrics)
	DllStructSetData($tMetrics, "Mask", $iMask)
	DllStructSetData($tMetrics, "XPad", $iXPad)
	DllStructSetData($tMetrics, "YPad", $iYPad)
	DllStructSetData($tMetrics, "XSpacing", $iXSpacing)
	DllStructSetData($tMetrics, "YSpacing", $iYSpacing)
	If _WinAPI_InProcess($hWnd, $gh_TBLastWnd) Then
		_SendMessage($hWnd, $TB_SETMETRICS, 0, $tMetrics, 0, "wparam", "struct*")
	Else
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iMetrics, $tMemMap)
		_MemWrite($tMemMap, $tMetrics, $pMemory, $iMetrics)
		_SendMessage($hWnd, $TB_SETMETRICS, 0, $pMemory, 0, "wparam", "ptr")
		_MemFree($tMemMap)
	EndIf
EndFunc   ;==>_GUICtrlToolbar_SetMetrics

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetPadding
; Description ...: Sets the padding control
; Syntax.........: _GUICtrlToolbar_SetPadding($hWnd, $iCX, $iCY)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCX         - The horizontal padding, in pixels
;                  $iCY         - The vertical padding, in pixels
; Return values .: Success      - Previous horizontal padding in the low word and the previous vertical padding in the high word
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......: The padding values are used to create a blank area between the edge of  the  button  and  the  button's  image
;                  and/or text. The horizontal padding value is applied to both the right and left of the button and the vertical
;                  padding value is applied to both the top and bottom of the button.  Padding is only applied  to  buttons  that
;                  have the $TBSTYLE_AUTOSIZE style.
; Related .......: _GUICtrlToolbar_GetPadding
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetPadding($hWnd, $iCX, $iCY)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_SETPADDING, 0, _WinAPI_MakeLong($iCX, $iCY), 0, "wparam", "long")
EndFunc   ;==>_GUICtrlToolbar_SetPadding

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetParent
; Description ...: Sets the window to which the control sends notification messages
; Syntax.........: _GUICtrlToolbar_SetParent($hWnd, $hParent)
; Parameters ....: $hWnd        - Handle to the control
;                  $hParent     - Handle to the window to receive notification messages
; Return values .: Success      - Handle to the previous notification window
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The $TB_SETPARENT message does not change the parent window that was specified when the control  was  created.
;                  Calling the _WinAPI_GetParent function control will return the actual parent window, not the window specified  in
;                  $TB_SETPARENT. To change the control's parent window, call the _WinAPI_SetParent function.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlToolbar_SetParent($hWnd, $hParent)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return HWnd(_SendMessage($hWnd, $TB_SETPARENT, $hParent))
EndFunc   ;==>_GUICtrlToolbar_SetParent

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetRows
; Description ...: Sets the number of rows of buttons
; Syntax.........: _GUICtrlToolbar_SetRows($hWnd, $iRows[, $fLarger = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $iRows       - Number of rows requested.  The minimum number of rows is one, and the maximum number of rows is
;                  +equal to the total number of buttons.
;                  $fLarger     - Flag that indicates whether to create more rows than requested when the system  can not  create
;                  +the number of rows specified by $iRows.  If this parameter is True, the system creates more rows.   If it  is
;                  +False, the system creates fewer rows.
; Return values .: Success      - Array with the following format:
;                  |[0] - X coordinate of the upper left corner of the rectangle
;                  |[1] - Y coordinate of the upper left corner of the rectangle
;                  |[2] - X coordinate of the lower right corner of the rectangle
;                  |[3] - Y coordinate of the lower right corner of the rectangle
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......: Because the system does not break up button groups when setting the number of rows, the  resulting  number  of
;                  rows might differ from the number requested.
; Related .......: _GUICtrlToolbar_GetRows
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetRows($hWnd, $iRows, $fLarger = True)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $tRect = DllStructCreate($tagRECT)
	If _WinAPI_InProcess($hWnd, $gh_TBLastWnd) Then
		_SendMessage($hWnd, $TB_SETROWS, _WinAPI_MakeLong($iRows, $fLarger), $tRect, 0, "long", "struct*")
	Else
		Local $iRect = DllStructGetSize($tRect)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iRect, $tMemMap)
		_SendMessage($hWnd, $TB_SETROWS, _WinAPI_MakeLong($iRows, $fLarger), $pMemory, 0, "long", "ptr")
		_MemRead($tMemMap, $pMemory, $tRect, $iRect)
		_MemFree($tMemMap)
	EndIf
	Local $aRect[4]
	$aRect[0] = DllStructGetData($tRect, "Left")
	$aRect[1] = DllStructGetData($tRect, "Top")
	$aRect[2] = DllStructGetData($tRect, "Right")
	$aRect[3] = DllStructGetData($tRect, "Bottom")
	Return $aRect
EndFunc   ;==>_GUICtrlToolbar_SetRows

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetStyle
; Description ...: Sets the style control
; Syntax.........: _GUICtrlToolbar_SetStyle($hWnd, $iStyle)
; Parameters ....: $hWnd        - Handle to the control
;                  $iStyle      - Control styles. Can be a combination of the following:
;                  |$TBSTYLE_TOOLTIPS     - Creates a ToolTip control
;                  |$TBSTYLE_WRAPABLE     - Creates a toolbar that can have multiple lines of buttons
;                  |$TBSTYLE_ALTDRAG      - Allows users to change a toolbar button's position by dragging it
;                  |$TBSTYLE_FLAT         - Creates a flat toolbar
;                  |$TBSTYLE_LIST         - Creates a flat toolbar with button text to the right of the bitmap
;                  |$TBSTYLE_CUSTOMERASE  - Sends $NM_CUSTOMDRAW messages when processing $WM_ERASEBKGND messages
;                  |$TBSTYLE_REGISTERDROP - Sends $TBN_GETOBJECT messages to request drop target objects
;                  |$TBSTYLE_TRANSPARENT  - Creates a transparent toolbar
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetStyle($hWnd, $iStyle)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	$iStyle = BitOR($iStyle, $__UDFGUICONSTANT_WS_CHILD, $__TOOLBARCONSTANT_WS_CLIPSIBLINGS, $__UDFGUICONSTANT_WS_VISIBLE)
	_SendMessage($hWnd, $TB_SETSTYLE, 0, $iStyle)
EndFunc   ;==>_GUICtrlToolbar_SetStyle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetStyleAltDrag
; Description ...: Sets whether that the control allows buttons to be dragged
; Syntax.........: _GUICtrlToolbar_SetStyleAltDrag($hWnd[, $fState = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $fState      - True to set, False to unset
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetStyleAltDrag
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetStyleAltDrag($hWnd, $fState = True)
	Return __GUICtrlToolbar_SetStyleEx($hWnd, $TBSTYLE_ALTDRAG, $fState)
EndFunc   ;==>_GUICtrlToolbar_SetStyleAltDrag

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetStyleCustomErase
; Description ...: Sets whether the control generates NM_CUSTOMDRAW notification messages
; Syntax.........: _GUICtrlToolbar_SetStyleCustomErase($hWnd[, $fState = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $fState      - True to set, False to unset
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetStyleCustomErase
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetStyleCustomErase($hWnd, $fState = True)
	Return __GUICtrlToolbar_SetStyleEx($hWnd, $TBSTYLE_CUSTOMERASE, $fState)
EndFunc   ;==>_GUICtrlToolbar_SetStyleCustomErase

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlToolbar_SetStyleEx
; Description ...: Changes a style for the toolbar
; Syntax.........: __GUICtrlToolbar_SetStyleEx($hWnd, $iStyle, $fStyle)
; Parameters ....: $hWnd        - Handle to the control
;                  $iStyle      - Style to be changed
;                  $fStyle      - True to set, false to unset
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function is used internally to implement the SetStylex functions
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GUICtrlToolbar_SetStyleEx($hWnd, $iStyle, $fStyle)
	Local $iN = _GUICtrlToolbar_GetStyle($hWnd)
	If $fStyle Then
		$iN = BitOR($iN, $iStyle)
	Else
		$iN = BitAND($iN, BitNOT($iStyle))
	EndIf
	Return _GUICtrlToolbar_SetStyle($hWnd, $iN)
EndFunc   ;==>__GUICtrlToolbar_SetStyleEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetStyleFlat
; Description ...: Sets whether the control is flat
; Syntax.........: _GUICtrlToolbar_SetStyleFlat($hWnd, $fState)
; Parameters ....: $hWnd        - Handle to the control
;                  $fState      - True to set, false to unset
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetStyleFlat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetStyleFlat($hWnd, $fState)
	Return __GUICtrlToolbar_SetStyleEx($hWnd, $TBSTYLE_FLAT, $fState)
EndFunc   ;==>_GUICtrlToolbar_SetStyleFlat

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetStyleList
; Description ...: Sets whether the control has button text to the right of the bitmap
; Syntax.........: _GUICtrlToolbar_SetStyleList($hWnd, $fState)
; Parameters ....: $hWnd        - Handle to the control
;                  $fState      - True to set, false to unset
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetStyleList
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetStyleList($hWnd, $fState)
	Return __GUICtrlToolbar_SetStyleEx($hWnd, $TBSTYLE_LIST, $fState)
EndFunc   ;==>_GUICtrlToolbar_SetStyleList

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetStyleRegisterDrop
; Description ...: Sets whether the control generates TBN_GETOBJECT notification messages
; Syntax.........: _GUICtrlToolbar_SetStyleRegisterDrop($hWnd, $fState)
; Parameters ....: $hWnd        - Handle to the control
;                  $fState      - True to set, false to unset
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetStyleRegisterDrop
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetStyleRegisterDrop($hWnd, $fState)
	Return __GUICtrlToolbar_SetStyleEx($hWnd, $TBSTYLE_REGISTERDROP, $fState)
EndFunc   ;==>_GUICtrlToolbar_SetStyleRegisterDrop

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetStyleToolTips
; Description ...: Sets whether the control has tooltips
; Syntax.........: _GUICtrlToolbar_SetStyleToolTips($hWnd, $fState)
; Parameters ....: $hWnd        - Handle to the control
;                  $fState      - True to set, false to unset
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetStyleToolTips
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetStyleToolTips($hWnd, $fState)
	Return __GUICtrlToolbar_SetStyleEx($hWnd, $TBSTYLE_TOOLTIPS, $fState)
EndFunc   ;==>_GUICtrlToolbar_SetStyleToolTips

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetStyleTransparent
; Description ...: Sets whether the control is transparent
; Syntax.........: _GUICtrlToolbar_SetStyleTransparent($hWnd, $fState)
; Parameters ....: $hWnd        - Handle to the control
;                  $fState      - True to set, false to unset
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetStyleTransparent
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetStyleTransparent($hWnd, $fState)
	Return __GUICtrlToolbar_SetStyleEx($hWnd, $TBSTYLE_TRANSPARENT, $fState)
EndFunc   ;==>_GUICtrlToolbar_SetStyleTransparent

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetStyleWrapable
; Description ...: Sets whether the control is wrapable
; Syntax.........: _GUICtrlToolbar_SetStyleWrapable($hWnd, $fState)
; Parameters ....: $hWnd        - Handle to the control
;                  $fState      - True to set, false to unset
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetStyleWrapable
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetStyleWrapable($hWnd, $fState)
	Return __GUICtrlToolbar_SetStyleEx($hWnd, $TBSTYLE_WRAPABLE, $fState)
EndFunc   ;==>_GUICtrlToolbar_SetStyleWrapable

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetToolTips
; Description ...: Associates a ToolTip control with a toolbar
; Syntax.........: _GUICtrlToolbar_SetToolTips($hWnd, $hToolTip)
; Parameters ....: $hWnd        - Handle to the control
;                  $hToolTip    - Handle to the ToolTip control
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......: Any buttons that are added to the control before sending the calling this function will not be registered with
;                  the ToolTip control.
; Related .......: _GUICtrlToolbar_GetToolTips
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetToolTips($hWnd, $hToolTip)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	_SendMessage($hWnd, $TB_SETTOOLTIPS, $hToolTip, 0, 0, "hwnd")
EndFunc   ;==>_GUICtrlToolbar_SetToolTips

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetUnicodeFormat
; Description ...: Sets the Unicode character format flag
; Syntax.........: _GUICtrlToolbar_SetUnicodeFormat($hWnd, $fUnicode = False)
; Parameters ....: $hWnd        - Handle to the control
;                  $fUnicode    - Unicode character setting:
;                  | True - Control uses Unicode characters
;                  |False - Control uses ANSI characters
; Return values .: Success      - Previous character format flag setting
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlToolbar_GetUnicodeFormat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlToolbar_SetUnicodeFormat($hWnd, $fUnicode = False)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $TB_SETUNICODEFORMAT, $fUnicode)
EndFunc   ;==>_GUICtrlToolbar_SetUnicodeFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlToolbar_SetWindowTheme
; Description ...: Sets the visual style
; Syntax.........: _GUICtrlToolbar_SetWindowTheme($hWnd, $sTheme)
; Parameters ....: $hWnd        - Handle to the control
;                  $sTheme      - String that contains the toolbar visual style
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......: Minimum OS - Windows XP
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlToolbar_SetWindowTheme($hWnd, $sTheme)
	If $Debug_TB Then __UDF_ValidateClassName($hWnd, $__TOOLBARCONSTANT_ClassName)

	Local $tTheme = _WinAPI_MultiByteToWideChar($sTheme)
	If _WinAPI_InProcess($hWnd, $gh_TBLastWnd) Then
		_SendMessage($hWnd, $TB_SETWINDOWTHEME, 0, $tTheme, 0, "wparam", "struct*")
	Else
		Local $iTheme = DllStructGetSize($tTheme)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iTheme, $tMemMap)
		_MemWrite($tMemMap, $tTheme, $pMemory, $iTheme)
		_SendMessage($hWnd, $TB_SETWINDOWTHEME, 0, $pMemory, 0, "wparam", "ptr")
		_MemFree($tMemMap)
	EndIf
EndFunc   ;==>_GUICtrlToolbar_SetWindowTheme
