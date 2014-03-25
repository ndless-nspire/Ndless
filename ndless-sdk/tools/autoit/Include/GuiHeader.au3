#include-once

#include "HeaderConstants.au3"
#include "Memory.au3"
#include "WinAPI.au3"
#include "StructureConstants.au3"
#include "SendMessage.au3"
#include "UDFGlobalID.au3"

; #INDEX# =======================================================================================================================
; Title .........: Header
; AutoIt Version : 3.3.7.20++
; Description ...: Functions that assist with Header control management.
;                  A header control is a window that is usually positioned above columns of text or numbers.  It contains a title
;                  for each column, and it can be divided into parts.
; Author(s) .....: Paul Campbell (PaulIA)
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $_ghHDRLastWnd
Global $Debug_HDR = False
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__HEADERCONSTANT_ClassName = "SysHeader32"
Global Const $__HEADERCONSTANT_DEFAULT_GUI_FONT = 17
Global Const $__HEADERCONSTANT_SWP_SHOWWINDOW = 0x0040
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_GUICtrlHeader_AddItem
;_GUICtrlHeader_ClearFilter
;_GUICtrlHeader_ClearFilterAll
;_GUICtrlHeader_Create
;_GUICtrlHeader_CreateDragImage
;_GUICtrlHeader_DeleteItem
;_GUICtrlHeader_Destroy
;_GUICtrlHeader_EditFilter
;_GUICtrlHeader_GetBitmapMargin
;_GUICtrlHeader_GetImageList
;_GUICtrlHeader_GetItem
;_GUICtrlHeader_GetItemAlign
;_GUICtrlHeader_GetItemBitmap
;_GUICtrlHeader_GetItemCount
;_GUICtrlHeader_GetItemDisplay
;_GUICtrlHeader_GetItemFlags
;_GUICtrlHeader_GetItemFormat
;_GUICtrlHeader_GetItemImage
;_GUICtrlHeader_GetItemOrder
;_GUICtrlHeader_GetItemParam
;_GUICtrlHeader_GetItemRect
;_GUICtrlHeader_GetItemRectEx
;_GUICtrlHeader_GetItemText
;_GUICtrlHeader_GetItemWidth
;_GUICtrlHeader_GetOrderArray
;_GUICtrlHeader_GetUnicodeFormat
;_GUICtrlHeader_HitTest
;_GUICtrlHeader_InsertItem
;_GUICtrlHeader_Layout
;_GUICtrlHeader_OrderToIndex
;_GUICtrlHeader_SetBitmapMargin
;_GUICtrlHeader_SetFilterChangeTimeout
;_GUICtrlHeader_SetHotDivider
;_GUICtrlHeader_SetImageList
;_GUICtrlHeader_SetItem
;_GUICtrlHeader_SetItemAlign
;_GUICtrlHeader_SetItemBitmap
;_GUICtrlHeader_SetItemDisplay
;_GUICtrlHeader_SetItemFlags
;_GUICtrlHeader_SetItemFormat
;_GUICtrlHeader_SetItemImage
;_GUICtrlHeader_SetItemOrder
;_GUICtrlHeader_SetItemParam
;_GUICtrlHeader_SetItemText
;_GUICtrlHeader_SetItemWidth
;_GUICtrlHeader_SetOrderArray
;_GUICtrlHeader_SetUnicodeFormat
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;$tagHDHITTESTINFO
;$tagHDLAYOUT
;$tagHDTEXTFILTER
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagHDHITTESTINFO
; Description ...: Contains information about a hit test
; Fields ........: X     - Horizontal postion to be hit test, in client coordinates
;                  Y     - Vertical position to be hit test, in client coordinates
;                  Flags - Information about the results of a hit test
;                  Item  - If the hit test is successful, contains the index of the item at the hit test point
; Author ........: Paul Campbell (PaulIA)
; Remarks .......: This structure is used with the $HDM_HITTEST message.
; ===============================================================================================================================
Global Const $tagHDHITTESTINFO = $tagPOINT & ";uint Flags;int Item"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagHDLAYOUT
; Description ...: Contains information used to set the size and position of the control
; Fields ........: Rect      - Pointer to a RECT structure that contains the rectangle that the header control will occupy
;                  WindowPos - Pointer to a WINDOWPOS structure that receives information about the size/position of the control
; Author ........: Paul Campbell (PaulIA)
; Remarks .......: This structure is used with the $HDM_LAYOUT message
; ===============================================================================================================================
Global Const $tagHDLAYOUT = "ptr Rect;ptr WindowPos"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagHDTEXTFILTER
; Description ...: Contains information about header control text filters
; Fields ........: Text    - Pointer to the buffer containing the filter
;                  TextMax - The maximum size, in characters, for an edit control buffer
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagHDTEXTFILTER = "ptr Text;int TextMax"

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_AddItem
; Description ...: Adds a new header item
; Syntax.........: _GUICtrlHeader_AddItem($hWnd, $sText[, $iWidth = 50[, $iAlign = 0[, $iImage = -1[, $fOnRight = False]]]])
; Parameters ....: $hWnd        - Handle to control
;                  $sText       - Item text
;                  $iWidth      - Item width
;                  $iAlign      - Text alignment:
;                  |0 - Text is left-aligned
;                  |1 - Text is right-aligned
;                  |2 - Text is centered
;                  $iImage      - Zero based index of an image within the image list
;                  $fOnRight    - If True, the column image appears to the right of text
; Return values .: Success      - The index of the new item
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlHeader_InsertItem, _GUICtrlHeader_DeleteItem
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_AddItem($hWnd, $sText, $iWidth = 50, $iAlign = 0, $iImage = -1, $fOnRight = False)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Return _GUICtrlHeader_InsertItem($hWnd, _GUICtrlHeader_GetItemCount($hWnd), $sText, $iWidth, $iAlign, $iImage, $fOnRight)
EndFunc   ;==>_GUICtrlHeader_AddItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_ClearFilter
; Description ...: Clears the filter
; Syntax.........: _GUICtrlHeader_ClearFilter($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_ClearFilterAll, _GUICtrlHeader_EditFilter
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_ClearFilter($hWnd, $iIndex)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Return _SendMessage($hWnd, $HDM_CLEARFILTER, $iIndex) <> 0
EndFunc   ;==>_GUICtrlHeader_ClearFilter

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_ClearFilterAll
; Description ...: Clears all of the filters
; Syntax.........: _GUICtrlHeader_ClearFilterAll($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_ClearFilter, _GUICtrlHeader_EditFilter
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_ClearFilterAll($hWnd)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Return _SendMessage($hWnd, $HDM_CLEARFILTER, -1) <> 0
EndFunc   ;==>_GUICtrlHeader_ClearFilterAll

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_Create
; Description ...: Creates a Header control
; Syntax.........: _GUICtrlHeader_Create($hWnd[, $iStyle = 0x00000046])
; Parameters ....: $hWnd        - Handle to parent or owner window
;                  $iStyle      - Control styles:
;                  |$HDS_BUTTONS   - Each item in the control looks and behaves like a push button
;                  |$HDS_DRAGDROP  - Allows drag-and-drop reordering of header items
;                  |$HDS_FILTERBAR - Include a filter bar as part of the standard header control
;                  |$HDS_FLAT      - Causes the header control to be drawn flat
;                  |$HDS_FULLDRAG  - Causes the header control to display column contents
;                  |$HDS_HIDDEN    - Indicates a header control that is intended to be hidden
;                  |$HDS_HORZ      - Creates a header control with a horizontal orientation
;                  |$HDS_HOTTRACK  - Enables hot tracking
;                  -
;                  |Default: $HDS_BUTTONS, $HDS_HOTTRACK, $HDS_DRAGDROP
;                  |Forced : $WS_CHILD, $WS_VISIBLE
; Return values .: Success      - Handle to the Header control
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......: _GUICtrlHeader_Destroy
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_Create($hWnd, $iStyle = 0x00000046)

	$iStyle = BitOR($iStyle, $__UDFGUICONSTANT_WS_CHILD, $__UDFGUICONSTANT_WS_VISIBLE)

	Local $nCtrlID = __UDF_GetNextGlobalID($hWnd)
	If @error Then Return SetError(@error, @extended, 0)

	Local $hHeader = _WinAPI_CreateWindowEx(0, $__HEADERCONSTANT_ClassName, "", $iStyle, 0, 0, 0, 0, $hWnd, $nCtrlID)
	Local $tRect = _WinAPI_GetClientRect($hWnd)
	Local $tWindowPos = _GUICtrlHeader_Layout($hHeader, $tRect)
	Local $iFlags = BitOR(DllStructGetData($tWindowPos, "Flags"), $__HEADERCONSTANT_SWP_SHOWWINDOW)
	_WinAPI_SetWindowPos($hHeader, DllStructGetData($tWindowPos, "InsertAfter"), _
			DllStructGetData($tWindowPos, "X"), DllStructGetData($tWindowPos, "Y"), _
			DllStructGetData($tWindowPos, "CX"), DllStructGetData($tWindowPos, "CY"), $iFlags)
	_WinAPI_SetFont($hHeader, _WinAPI_GetStockObject($__HEADERCONSTANT_DEFAULT_GUI_FONT))
	Return $hHeader
EndFunc   ;==>_GUICtrlHeader_Create

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_CreateDragImage
; Description ...: Creates a semi-transparent version of an item's image for use as a dragging image
; Syntax.........: _GUICtrlHeader_CreateDragImage($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index.  The image assigned to the item is the basis for the transparent image.
; Return values .: Success      - Handle to an image list that contains the new image as its only element
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_GetImageList
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_CreateDragImage($hWnd, $iIndex)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Return Ptr(_SendMessage($hWnd, $HDM_CREATEDRAGIMAGE, $iIndex))
EndFunc   ;==>_GUICtrlHeader_CreateDragImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_DeleteItem
; Description ...: Deletes a header item
; Syntax.........: _GUICtrlHeader_DeleteItem($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_AddItem, _GUICtrlHeader_InsertItem
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_DeleteItem($hWnd, $iIndex)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Return _SendMessage($hWnd, $HDM_DELETEITEM, $iIndex) <> 0
EndFunc   ;==>_GUICtrlHeader_DeleteItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_Destroy
; Description ...: Delete the Header control
; Syntax.........: _GUICtrlHeader_Destroy(ByRef $hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True, Handle is set to 0
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Restricted to only be used on Edit created with _GUICtrlHeader_Create
; Related .......: _GUICtrlHeader_Create
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_Destroy(ByRef $hWnd)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)
	If Not _WinAPI_IsClassName($hWnd, $__HEADERCONSTANT_ClassName) Then Return SetError(2, 2, False)

	Local $Destroyed = 0
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_ghHDRLastWnd) Then
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
EndFunc   ;==>_GUICtrlHeader_Destroy

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_EditFilter
; Description ...: Starts editing the specified filter
; Syntax.........: _GUICtrlHeader_EditFilter($hWnd, $iIndex[, $fDiscard = True])
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
;                  $fDiscard    - Flag that specifies how to handle the user's editing changes.  Use this flag to specify what to
;                  +do if the user is in the process of editing the filter when the message is sent:
;                  | True - Discard the changes made by the user
;                  |False - Accept the changes made by the user
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_ClearFilter, _GUICtrlHeader_ClearFilterAll
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_EditFilter($hWnd, $iIndex, $fDiscard = True)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Return _SendMessage($hWnd, $HDM_EDITFILTER, $iIndex, $fDiscard) <> 0
EndFunc   ;==>_GUICtrlHeader_EditFilter

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_GetBitmapMargin
; Description ...: Retrieves the width of the bitmap margin
; Syntax.........: _GUICtrlHeader_GetBitmapMargin($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - The width of the bitmap margin in pixels.  If the bitmap margin was not  previously  specified,
;                  +the default value of 3 * GetSystemMetrics(SM_CXEDGE) is returned.
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_SetBitmapMargin
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_GetBitmapMargin($hWnd)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Return _SendMessage($hWnd, $HDM_GETBITMAPMARGIN)
EndFunc   ;==>_GUICtrlHeader_GetBitmapMargin

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_GetImageList
; Description ...: Retrieves the handle to the image list
; Syntax.........: _GUICtrlHeader_GetImageList($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - A handle to the image list set for the header control
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_SetImageList, _GUICtrlHeader_CreateDragImage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_GetImageList($hWnd)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Return Ptr(_SendMessage($hWnd, $HDM_GETIMAGELIST))
EndFunc   ;==>_GUICtrlHeader_GetImageList

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_GetItem
; Description ...: Retrieves information about an item
; Syntax.........: _GUICtrlHeader_GetItem($hWnd, $iIndex, ByRef $tItem)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
;                  $tItem       - $tagHDITEM structure
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: When the message is sent, the mask member indicates the type of information being requested.  When the message
;                  returns, the other members receive the requested information.  If the mask member specifies zero, the  message
;                  returns True but copies no information to the structure.
; Related .......: _GUICtrlHeader_SetItem, $tagHDITEM
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_GetItem($hWnd, $iIndex, ByRef $tItem)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlHeader_GetUnicodeFormat($hWnd)

	Local $iRet
	If _WinAPI_InProcess($hWnd, $_ghHDRLastWnd) Then
		$iRet = _SendMessage($hWnd, $HDM_GETITEMW, $iIndex, $tItem, 0, "wparam", "struct*")
	Else
		Local $iItem = DllStructGetSize($tItem)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iItem, $tMemMap)
		_MemWrite($tMemMap, $tItem)
		If $fUnicode Then
			$iRet = _SendMessage($hWnd, $HDM_GETITEMW, $iIndex, $pMemory, 0, "wparam", "ptr")
		Else
			$iRet = _SendMessage($hWnd, $HDM_GETITEMA, $iIndex, $pMemory, 0, "wparam", "ptr")
		EndIf
		_MemRead($tMemMap, $pMemory, $tItem, $iItem)
		_MemFree($tMemMap)
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlHeader_GetItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_GetItemAlign
; Description ...: Retrieves the item text alignment
; Syntax.........: _GUICtrlHeader_GetItemAlign($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Item text alignment:
;                  |0 - Left
;                  |1 - Right
;                  |2 - Center
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlHeader_SetItemAlign
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemAlign($hWnd, $iIndex)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Switch BitAND(_GUICtrlHeader_GetItemFormat($hWnd, $iIndex), $HDF_JUSTIFYMASK)
		Case $HDF_LEFT
			Return 0
		Case $HDF_RIGHT
			Return 1
		Case $HDF_CENTER
			Return 2
		Case Else
			Return -1
	EndSwitch
EndFunc   ;==>_GUICtrlHeader_GetItemAlign

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_GetItemBitmap
; Description ...: Retrieves the item bitmap handle
; Syntax.........: _GUICtrlHeader_GetItemBitmap($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Item bitmap handle
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_SetItemBitmap
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemBitmap($hWnd, $iIndex)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_BITMAP)
	_GUICtrlHeader_GetItem($hWnd, $iIndex, $tItem)
	Return DllStructGetData($tItem, "hBmp")
EndFunc   ;==>_GUICtrlHeader_GetItemBitmap

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_GetItemCount
; Description ...: Retrieves a count of the items
; Syntax.........: _GUICtrlHeader_GetItemCount($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - The number of items
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemCount($hWnd)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Return _SendMessage($hWnd, $HDM_GETITEMCOUNT)
EndFunc   ;==>_GUICtrlHeader_GetItemCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_GetItemDisplay
; Description ...: Returns the item display information
; Syntax.........: _GUICtrlHeader_GetItemDisplay($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Item display information:
;                  |1 - The item displays a bitmap
;                  |2 - The bitmap appears to the right of text
;                  |4 - The control's owner draws the item
;                  |8 - The item displays a string
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlHeader_SetItemDisplay
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemDisplay($hWnd, $iIndex)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $iRet = 0

	Local $iFormat = _GUICtrlHeader_GetItemFormat($hWnd, $iIndex)
	If BitAND($iFormat, $HDF_BITMAP) <> 0 Then $iRet = BitOR($iRet, 1)
	If BitAND($iFormat, $HDF_BITMAP_ON_RIGHT) <> 0 Then $iRet = BitOR($iRet, 2)
	If BitAND($iFormat, $HDF_OWNERDRAW) <> 0 Then $iRet = BitOR($iRet, 4)
	If BitAND($iFormat, $HDF_STRING) <> 0 Then $iRet = BitOR($iRet, 8)
	Return $iRet
EndFunc   ;==>_GUICtrlHeader_GetItemDisplay

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_GetItemFlags
; Description ...: Returns the item flag information
; Syntax.........: _GUICtrlHeader_GetItemFlags($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Item flag information:
;                  |1 - Displays an image from an image list
;                  |2 - Text reads in the opposite direction from the text in the parent window
;                  |4 - Draws a down arrow on this item
;                  |8 - Draws a up arrow on this item
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlHeader_SetItemFlags
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemFlags($hWnd, $iIndex)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $iRet = 0

	Local $iFormat = _GUICtrlHeader_GetItemFormat($hWnd, $iIndex)
	If BitAND($iFormat, $HDF_IMAGE) <> 0 Then $iRet = BitOR($iRet, 1)
	If BitAND($iFormat, $HDF_RTLREADING) <> 0 Then $iRet = BitOR($iRet, 2)
	If BitAND($iFormat, $HDF_SORTDOWN) <> 0 Then $iRet = BitOR($iRet, 4)
	If BitAND($iFormat, $HDF_SORTUP) <> 0 Then $iRet = BitOR($iRet, 8)
	Return $iRet
EndFunc   ;==>_GUICtrlHeader_GetItemFlags

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_GetItemFormat
; Description ...: Returns the format of the item
; Syntax.........: _GUICtrlHeader_GetItemFormat($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Item format:
;                  |HDF_CENTER          - The item's contents are centered
;                  |HDF_LEFT            - The item's contents are left-aligned.
;                  |HDF_RIGHT           - The item's contents are right-aligned.
;                  |HDF_BITMAP          - The item displays a bitmap.
;                  |HDF_BITMAP_ON_RIGHT - The bitmap appears to the right of text.
;                  |HDF_OWNERDRAW       - The control's owner draws the item.
;                  |HDF_STRING          - The item displays a string.
;                  |HDF_IMAGE           - Display an image from an image list
;                  |HDF_RTLREADING      - Text will read in the opposite direction
;                  |HDF_SORTDOWN        - Draw a down-arrow on this item
;                  |HDF_SORTUP          - Draw an up-arrow on this item
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_SetItemFormat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemFormat($hWnd, $iIndex)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_FORMAT)
	_GUICtrlHeader_GetItem($hWnd, $iIndex, $tItem)
	Return DllStructGetData($tItem, "Fmt")
EndFunc   ;==>_GUICtrlHeader_GetItemFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_GetItemImage
; Description ...: Retrieves the index of an image within the image list
; Syntax.........: _GUICtrlHeader_GetItemImage($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Zero based index of the image
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_SetItemImage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemImage($hWnd, $iIndex)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_IMAGE)
	_GUICtrlHeader_GetItem($hWnd, $iIndex, $tItem)
	Return DllStructGetData($tItem, "Image")
EndFunc   ;==>_GUICtrlHeader_GetItemImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_GetItemOrder
; Description ...: Retrieves the order in which the item appears
; Syntax.........: _GUICtrlHeader_GetItemOrder($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Zero based item order
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_SetItemOrder
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemOrder($hWnd, $iIndex)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_ORDER)
	_GUICtrlHeader_GetItem($hWnd, $iIndex, $tItem)
	Return DllStructGetData($tItem, "Order")
EndFunc   ;==>_GUICtrlHeader_GetItemOrder

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_GetItemParam
; Description ...: Retrieves the param value of the item
; Syntax.........: _GUICtrlHeader_GetItemParam($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Item param value
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_SetItemParam
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemParam($hWnd, $iIndex)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_PARAM)
	_GUICtrlHeader_GetItem($hWnd, $iIndex, $tItem)
	Return DllStructGetData($tItem, "Param")
EndFunc   ;==>_GUICtrlHeader_GetItemParam

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_GetItemRect
; Description ...: Retrieves the bounding rectangle for a given item
; Syntax.........: _GUICtrlHeader_GetItemRect($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Array with the following format:
;                  |[0] - X coordinate of the upper left corner of the rectangle
;                  |[1] - Y coordinate of the upper left corner of the rectangle
;                  |[2] - X coordinate of the lower right corner of the rectangle
;                  |[3] - Y coordinate of the lower right corner of the rectangle
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_GetItemRectEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemRect($hWnd, $iIndex)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $aRect[4]

	Local $tRect = _GUICtrlHeader_GetItemRectEx($hWnd, $iIndex)
	$aRect[0] = DllStructGetData($tRect, "Left")
	$aRect[1] = DllStructGetData($tRect, "Top")
	$aRect[2] = DllStructGetData($tRect, "Right")
	$aRect[3] = DllStructGetData($tRect, "Bottom")
	Return $aRect
EndFunc   ;==>_GUICtrlHeader_GetItemRect

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_GetItemRectEx
; Description ...: Retrieves the bounding rectangle for a given item
; Syntax.........: _GUICtrlHeader_GetItemRectEx($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
; Return values .: Success      - $tagRECT structure that receives the bounding rectangle
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_GetItemRect
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemRectEx($hWnd, $iIndex)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $tRect = DllStructCreate($tagRECT)
	If _WinAPI_InProcess($hWnd, $_ghHDRLastWnd) Then
		_SendMessage($hWnd, $HDM_GETITEMRECT, $iIndex, $tRect, 0, "wparam", "struct*")
	Else
		Local $iRect = DllStructGetSize($tRect)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iRect, $tMemMap)
		_MemWrite($tMemMap, $tRect)
		_SendMessage($hWnd, $HDM_GETITEMRECT, $iIndex, $pMemory, 0, "wparam", "ptr")
		_MemRead($tMemMap, $pMemory, $tRect, $iRect)
		_MemFree($tMemMap)
	EndIf
	Return $tRect
EndFunc   ;==>_GUICtrlHeader_GetItemRectEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_GetItemText
; Description ...: Retrieves the item text
; Syntax.........: _GUICtrlHeader_GetItemText($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Item text
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_SetItemText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemText($hWnd, $iIndex)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlHeader_GetUnicodeFormat($hWnd)

	Local $tBuffer
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Text[4096]")
	Else
		$tBuffer = DllStructCreate("char Text[4096]")
	EndIf
	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_TEXT)
	DllStructSetData($tItem, "TextMax", 4096)
	If _WinAPI_InProcess($hWnd, $_ghHDRLastWnd) Then
		DllStructSetData($tItem, "Text", DllStructGetPtr($tBuffer))
		_SendMessage($hWnd, $HDM_GETITEMW, $iIndex, $tItem, 0, "wparam", "struct*")
	Else
		Local $iItem = DllStructGetSize($tItem)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iItem + DllStructGetSize($tBuffer), $tMemMap)
		Local $pText = $pMemory + $iItem
		DllStructSetData($tItem, "Text", $pText)
		_MemWrite($tMemMap, $tItem, $pMemory, $iItem)
		If $fUnicode Then
			_SendMessage($hWnd, $HDM_GETITEMW, $iIndex, $pMemory, 0, "wparam", "ptr")
		Else
			_SendMessage($hWnd, $HDM_GETITEMA, $iIndex, $pMemory, 0, "wparam", "ptr")
		EndIf
		_MemRead($tMemMap, $pText, $tBuffer, DllStructGetSize($tBuffer))
		_MemFree($tMemMap)
	EndIf
	Return DllStructGetData($tBuffer, "Text")
EndFunc   ;==>_GUICtrlHeader_GetItemText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_GetItemWidth
; Description ...: Retrieves the item's width
; Syntax.........: _GUICtrlHeader_GetItemWidth($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Width of the item
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_SetItemWidth
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemWidth($hWnd, $iIndex)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_WIDTH)
	_GUICtrlHeader_GetItem($hWnd, $iIndex, $tItem)
	Return DllStructGetData($tItem, "XY")
EndFunc   ;==>_GUICtrlHeader_GetItemWidth

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_GetOrderArray
; Description ...: Retrieves the current left-to-right order of items in a header control
; Syntax.........: _GUICtrlHeader_GetOrderArray($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - Array with the following format:
;                  |[0] - Number of items in array
;                  |[1] - Item index 1
;                  |[2] - Item index 2
;                  |[n] - Item index n
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_SetOrderArray
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_GetOrderArray($hWnd)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $iItems = _GUICtrlHeader_GetItemCount($hWnd)
	Local $tBuffer = DllStructCreate("int[" & $iItems & "]")
	If _WinAPI_InProcess($hWnd, $_ghHDRLastWnd) Then
		_SendMessage($hWnd, $HDM_GETORDERARRAY, $iItems, $tBuffer, 0, "wparam", "struct*")
	Else
		Local $iBuffer = DllStructGetSize($tBuffer)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iBuffer, $tMemMap)
		_SendMessage($hWnd, $HDM_GETORDERARRAY, $iItems, $pMemory, 0, "wparam", "ptr")
		_MemRead($tMemMap, $pMemory, $tBuffer, $iBuffer)
		_MemFree($tMemMap)
	EndIf

	Local $aBuffer[$iItems + 1]
	$aBuffer[0] = $iItems
	For $iI = 1 To $iItems
		$aBuffer[$iI] = DllStructGetData($tBuffer, 1, $iI)
	Next
	Return $aBuffer
EndFunc   ;==>_GUICtrlHeader_GetOrderArray

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_GetUnicodeFormat
; Description ...: Retrieves the Unicode character format flag for the control
; Syntax.........: _GUICtrlHeader_GetUnicodeFormat($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: True         - Control uses Unicode characters
;                  False        - Control uses ANSI characters
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_SetUnicodeFormat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_GetUnicodeFormat($hWnd)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Return _SendMessage($hWnd, $HDM_GETUNICODEFORMAT) <> 0
EndFunc   ;==>_GUICtrlHeader_GetUnicodeFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_HitTest
; Description ...: Tests a point to determine which item is at the specified point
; Syntax.........: _GUICtrlHeader_HitTest($hWnd, $iX, $iY)
; Parameters ....: $hWnd        - Handle to control
;                  $iX          - X position to test
;                  $iY          - Y position to text
; Return values .: Success      - Array with the following format:
;                  |[ 0] - Zero based index of the item at the specified position, or -1 if no item was found
;                  |[ 1] - If True, position is in control's client window but not on an item
;                  |[ 2] - If True, position is in the control's bounding rectangle
;                  |[ 3] - If True, position is on the divider between two items
;                  |[ 4] - If True, position is on the divider of an item that has a zero width
;                  |[ 5] - If True, position is over the filter area
;                  |[ 6] - If True, position is on the filter button
;                  |[ 7] - If True, position is above the control's bounding rectangle
;                  |[ 8] - If True, position is below the control's bounding rectangle
;                  |[ 9] - If True, position is to the right of the control's bounding rectangle
;                  |[10] - If True, position is to the left of the control's bounding rectangle
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_HitTest($hWnd, $iX, $iY)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $tTest = DllStructCreate($tagHDHITTESTINFO)
	DllStructSetData($tTest, "X", $iX)
	DllStructSetData($tTest, "Y", $iY)
	Local $aTest[11]
	If _WinAPI_InProcess($hWnd, $_ghHDRLastWnd) Then
		$aTest[0] = _SendMessage($hWnd, $HDM_HITTEST, 0, $tTest, 0, "wparam", "struct*")
	Else
		Local $iTest = DllStructGetSize($tTest)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iTest, $tMemMap)
		_MemWrite($tMemMap, $tTest)
		$aTest[0] = _SendMessage($hWnd, $HDM_HITTEST, 0, $pMemory, 0, "wparam", "ptr")
		_MemRead($tMemMap, $pMemory, $tTest, $iTest)
		_MemFree($tMemMap)
	EndIf
	Local $iFlags = DllStructGetData($tTest, "Flags")
	$aTest[1] = BitAND($iFlags, $HHT_NOWHERE) <> 0
	$aTest[2] = BitAND($iFlags, $HHT_ONHEADER) <> 0
	$aTest[3] = BitAND($iFlags, $HHT_ONDIVIDER) <> 0
	$aTest[4] = BitAND($iFlags, $HHT_ONDIVOPEN) <> 0
	$aTest[5] = BitAND($iFlags, $HHT_ONFILTER) <> 0
	$aTest[6] = BitAND($iFlags, $HHT_ONFILTERBUTTON) <> 0
	$aTest[7] = BitAND($iFlags, $HHT_ABOVE) <> 0
	$aTest[8] = BitAND($iFlags, $HHT_BELOW) <> 0
	$aTest[9] = BitAND($iFlags, $HHT_TORIGHT) <> 0
	$aTest[10] = BitAND($iFlags, $HHT_TOLEFT) <> 0
	Return $aTest
EndFunc   ;==>_GUICtrlHeader_HitTest

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_InsertItem
; Description ...: Inserts a new header item
; Syntax.........: _GUICtrlHeader_InsertItem($hWnd, $iIndex, $sText[, $iWidth = 50[, $iAlign = 0[, $iImage = -1[, $fOnRight = False]]]])
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Index of the item after which the new item is to be inserted.  The new item is inserted at  the
;                  +end of the control if index is greater than or equal to the number of items in the control. If index is zero,
;                  +the new item is inserted at the beginning of the control.
;                  $sText       - Item text
;                  $iWidth      - Item width
;                  $iAlign      - Text alignment:
;                  |0 - Text is left-aligned
;                  |1 - Text is right-aligned
;                  |2 - Text is centered
;                  $iImage      - Zero based index of an image within the image list
;                  $fOnRight    - If True, the column image appears to the right of text
; Return values .: Success      - The index of the new item
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_AddItem, _GUICtrlHeader_DeleteItem
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_InsertItem($hWnd, $iIndex, $sText, $iWidth = 50, $iAlign = 0, $iImage = -1, $fOnRight = False)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $aAlign[3] = [$HDF_LEFT, $HDF_RIGHT, $HDF_CENTER]
	Local $fUnicode = _GUICtrlHeader_GetUnicodeFormat($hWnd)

	Local $pBuffer, $iBuffer
	If $sText <> -1 Then
		$iBuffer = StringLen($sText) + 1
		Local $tBuffer
		If $fUnicode Then
			$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
			$iBuffer *= 2
		Else
			$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
		EndIf
		DllStructSetData($tBuffer, "Text", $sText)
		$pBuffer = DllStructGetPtr($tBuffer)
	Else
		$iBuffer = 0
		$pBuffer = -1 ; LPSTR_TEXTCALLBACK
	EndIf
	Local $tItem = DllStructCreate($tagHDITEM)
	Local $iFmt = $aAlign[$iAlign]
	Local $iMask = BitOR($HDI_WIDTH, $HDI_FORMAT)
	If $sText <> "" Then
		$iMask = BitOR($iMask, $HDI_TEXT)
		$iFmt = BitOR($iFmt, $HDF_STRING)
	EndIf
	If $iImage <> -1 Then
		$iMask = BitOR($iMask, $HDI_IMAGE)
		$iFmt = BitOR($iFmt, $HDF_IMAGE)
	EndIf
	If $fOnRight Then $iFmt = BitOR($iFmt, $HDF_BITMAP_ON_RIGHT)
	DllStructSetData($tItem, "Mask", $iMask)
	DllStructSetData($tItem, "XY", $iWidth)
	DllStructSetData($tItem, "Fmt", $iFmt)
	DllStructSetData($tItem, "Image", $iImage)
	Local $iRet
	If _WinAPI_InProcess($hWnd, $_ghHDRLastWnd) Then
		DllStructSetData($tItem, "Text", $pBuffer)
		$iRet = _SendMessage($hWnd, $HDM_INSERTITEMW, $iIndex, $tItem, 0, "wparam", "struct*")
	Else
		Local $iItem = DllStructGetSize($tItem)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iItem + $iBuffer, $tMemMap)
		If $sText <> -1 Then
			Local $pText = $pMemory + $iItem
			DllStructSetData($tItem, "Text", $pText)
			_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
		Else
			DllStructSetData($tItem, "Text", -1) ; LPSTR_TEXTCALLBACK
		EndIf
		_MemWrite($tMemMap, $tItem, $pMemory, $iItem)
		If $fUnicode Then
			$iRet = _SendMessage($hWnd, $HDM_INSERTITEMW, $iIndex, $pMemory, 0, "wparam", "ptr")
		Else
			$iRet = _SendMessage($hWnd, $HDM_INSERTITEMA, $iIndex, $pMemory, 0, "wparam", "ptr")
		EndIf
		_MemFree($tMemMap)
	EndIf
	Return $iRet
EndFunc   ;==>_GUICtrlHeader_InsertItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_Layout
; Description ...: Retrieves the correct size and position of the control
; Syntax.........: _GUICtrlHeader_Layout($hWnd, ByRef $tRect)
; Parameters ....: $hWnd        - Handle to control
;                  $tRect       - $tagRECT structure that contains the rectangle the control will occupy.
; Return values .: Success      - $tagWINDOWPOS structure that contains the control size and position
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: $tagRECT, $tagWINDOWPOS
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_Layout($hWnd, ByRef $tRect)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $tLayout = DllStructCreate($tagHDLAYOUT)
	Local $tWindowPos = DllStructCreate($tagWINDOWPOS)
	If _WinAPI_InProcess($hWnd, $_ghHDRLastWnd) Then
		DllStructSetData($tLayout, "Rect", DllStructGetPtr($tRect))
		DllStructSetData($tLayout, "WindowPos", DllStructGetPtr($tWindowPos))
		_SendMessage($hWnd, $HDM_LAYOUT, 0, $tLayout, 0, "wparam", "struct*")
	Else
		Local $iLayout = DllStructGetSize($tLayout)
		Local $iRect = DllStructGetSize($tRect)
		Local $iWindowPos = DllStructGetSize($tWindowPos)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iLayout + $iRect + $iWindowPos, $tMemMap)
		DllStructSetData($tLayout, "Rect", $pMemory + $iLayout)
		DllStructSetData($tLayout, "WindowPos", $pMemory + $iLayout + $iRect)
		_MemWrite($tMemMap, $tLayout, $pMemory, $iLayout)
		_MemWrite($tMemMap, $tRect, $pMemory + $iLayout, $iRect)
		_SendMessage($hWnd, $HDM_LAYOUT, 0, $pMemory, 0, "wparam", "ptr")
		_MemRead($tMemMap, $pMemory + $iLayout + $iRect, $tWindowPos, $iWindowPos)
		_MemFree($tMemMap)
	EndIf
	Return $tWindowPos
EndFunc   ;==>_GUICtrlHeader_Layout

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_OrderToIndex
; Description ...: Retrieves an index value for an item based on its order
; Syntax.........: _GUICtrlHeader_OrderToIndex($hWnd, $iOrder)
; Parameters ....: $hWnd        - Handle to control
;                  $iOrder      - Order in which the item appears within the header control, from left to right
; Return values .: Success      - Returns the item index
;                  Failure      - iOrder
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_OrderToIndex($hWnd, $iOrder)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Return _SendMessage($hWnd, $HDM_ORDERTOINDEX, $iOrder)
EndFunc   ;==>_GUICtrlHeader_OrderToIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_SetBitmapMargin
; Description ...: Sets the width of the margin, specified in pixels, of a bitmap
; Syntax.........: _GUICtrlHeader_SetBitmapMargin($hWnd, $iWidth)
; Parameters ....: $hWnd        - Handle to control
;                  $iWidth      - Width, specified in pixels, of the bitmap margin
; Return values .: Success      - The previous bitmap margin width
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_GetBitmapMargin
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_SetBitmapMargin($hWnd, $iWidth)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Return _SendMessage($hWnd, $HDM_SETBITMAPMARGIN, $iWidth)
EndFunc   ;==>_GUICtrlHeader_SetBitmapMargin

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_SetFilterChangeTimeout
; Description ...: Sets the filter change timeout interval
; Syntax.........: _GUICtrlHeader_SetFilterChangeTimeout($hWnd, $iTimeOut)
; Parameters ....: $hWnd        - Handle to control
;                  $iTimeOut    - Timeout value, in milliseconds
; Return values .: Success      - The index of the filter control being modified
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_SetFilterChangeTimeout($hWnd, $iTimeOut)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Return _SendMessage($hWnd, $HDM_SETFILTERCHANGETIMEOUT, 0, $iTimeOut)
EndFunc   ;==>_GUICtrlHeader_SetFilterChangeTimeout

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_SetHotDivider
; Description ...: Changes the hot divider color
; Syntax.........: _GUICtrlHeader_SetHotDivider($hWnd, $iFlag, $iInputValue)
; Parameters ....: $hWnd        - Handle to control
;                  $iFlag       - Value specifying the type of value represented by $iInputValue.  This value can be one  of  the
;                  +following:
;                  | True - Indicates that $iInputValue holds the client coordinates of the pointer
;                  |False - Indicates that $iInputValue holds a divider index value
;                  $iInputValue  - Value interpreted by $iFlag
; Return values .: Success      - A value equal to the index of the divider that the control highlighted
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: This function creates an effect that a header control automatically produces  when  it  has  the  HDS_DRAGDROP
;                  style. It is intended to be used when the owner of the control handles drag-and-drop operations manually.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_SetHotDivider($hWnd, $iFlag, $iInputValue)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Return _SendMessage($hWnd, $HDM_SETHOTDIVIDER, $iFlag, $iInputValue)
EndFunc   ;==>_GUICtrlHeader_SetHotDivider

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_SetImageList
; Description ...: Assigns an image list
; Syntax.........: _GUICtrlHeader_SetImageList($hWnd, $hImage)
; Parameters ....: $hWnd        - Handle to control
;                  $hImage      - Handle to an image list
; Return values .: Success      - The handle to the image list previously associated with the control
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_GetImageList
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_SetImageList($hWnd, $hImage)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Return _SendMessage($hWnd, $HDM_SETIMAGELIST, 0, $hImage, 0, "wparam", "handle", "handle")
EndFunc   ;==>_GUICtrlHeader_SetImageList

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_SetItem
; Description ...: Sets information about an item
; Syntax.........: _GUICtrlHeader_SetItem($hWnd, $iIndex, ByRef $tItem)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
;                  $tItem       - DllStructCreate($tagHDITEM) structure
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_GetItem, $tagHDITEM
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_SetItem($hWnd, $iIndex, ByRef $tItem)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlHeader_GetUnicodeFormat($hWnd)

	Local $iRet
	If _WinAPI_InProcess($hWnd, $_ghHDRLastWnd) Then
		$iRet = _SendMessage($hWnd, $HDM_SETITEMW, $iIndex, $tItem, 0, "wparam", "struct*")
	Else
		Local $iItem = DllStructGetSize($tItem)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iItem, $tMemMap)
		_MemWrite($tMemMap, $tItem)
		If $fUnicode Then
			$iRet = _SendMessage($hWnd, $HDM_SETITEMW, $iIndex, $pMemory, 0, "wparam", "ptr")
		Else
			$iRet = _SendMessage($hWnd, $HDM_SETITEMA, $iIndex, $pMemory, 0, "wparam", "ptr")
		EndIf
		_MemFree($tMemMap)
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlHeader_SetItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_SetItemAlign
; Description ...: Sets the item text alignment
; Syntax.........: _GUICtrlHeader_SetItemAlign($hWnd, $iIndex, $iAlign)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
;                  $iAlign      - Text alignment:
;                  |0 - Text is left-aligned
;                  |1 - Text is right-aligned
;                  |2 - Text is centered
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlHeader_GetItemAlign
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_SetItemAlign($hWnd, $iIndex, $iAlign)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $aAlign[3] = [$HDF_LEFT, $HDF_RIGHT, $HDF_CENTER]

	Local $iFormat = _GUICtrlHeader_GetItemFormat($hWnd, $iIndex)
	$iFormat = BitAND($iFormat, BitNOT($HDF_JUSTIFYMASK))
	$iFormat = BitOR($iFormat, $aAlign[$iAlign])
	Return _GUICtrlHeader_SetItemFormat($hWnd, $iIndex, $iFormat)
EndFunc   ;==>_GUICtrlHeader_SetItemAlign

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_SetItemBitmap
; Description ...: Sets the item bitmap handle
; Syntax.........: _GUICtrlHeader_SetItemBitmap($hWnd, $iIndex, $hBmp)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
;                  $hBmp        - Item bitmap handle
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: After calling this function, make sure you call _GUICtrlHeader_SetItemDisplay to set the items display information
; Related .......: _GUICtrlHeader_GetItemBitmap, _GUICtrlHeader_SetItemDisplay
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_SetItemBitmap($hWnd, $iIndex, $hBmp)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", BitOR($HDI_FORMAT, $HDI_BITMAP))
	DllStructSetData($tItem, "Fmt", $HDF_BITMAP)
	DllStructSetData($tItem, "hBMP", $hBmp)
	Return _GUICtrlHeader_SetItem($hWnd, $iIndex, $tItem)
EndFunc   ;==>_GUICtrlHeader_SetItemBitmap

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_SetItemDisplay
; Description ...: Returns the item display information
; Syntax.........: _GUICtrlHeader_SetItemDisplay($hWnd, $iIndex, $iDisplay)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
;                  $iDisplay    - Item display information. Can be a combination of the following:
;                  |1 - The item displays a bitmap
;                  |2 - The bitmap appears to the right of text
;                  |4 - The control's owner draws the item
;                  |8 - The item displays a string
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlHeader_GetItemDisplay, _GUICtrlHeader_SetItemBitmap
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_SetItemDisplay($hWnd, $iIndex, $iDisplay)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $iFormat = BitAND(_GUICtrlHeader_GetItemFormat($hWnd, $iIndex), Not $HDF_DISPLAYMASK)
	If BitAND($iDisplay, 1) <> 0 Then $iFormat = BitOR($iFormat, $HDF_BITMAP)
	If BitAND($iDisplay, 2) <> 0 Then $iFormat = BitOR($iFormat, $HDF_BITMAP_ON_RIGHT)
	If BitAND($iDisplay, 4) <> 0 Then $iFormat = BitOR($iFormat, $HDF_OWNERDRAW)
	If BitAND($iDisplay, 8) <> 0 Then $iFormat = BitOR($iFormat, $HDF_STRING)
	Return _GUICtrlHeader_SetItemFormat($hWnd, $iIndex, $iFormat)
EndFunc   ;==>_GUICtrlHeader_SetItemDisplay

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_SetItemFlags
; Description ...: Returns the item flag information
; Syntax.........: _GUICtrlHeader_SetItemFlags($hWnd, $iIndex, $iFlags)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
;                  $iFlags      - Item flag information.  Can be a combination of the following:
;                  |1 - Displays an image from an image list
;                  |2 - Text reads in the opposite direction from the text in the parent window
;                  |4 - Draws a down arrow on this item
;                  |8 - Draws a up arrow on this item
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlHeader_GetItemFlags
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_SetItemFlags($hWnd, $iIndex, $iFlags)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $iFormat = _GUICtrlHeader_GetItemFormat($hWnd, $iIndex)
	$iFormat = BitAND($iFormat, BitNOT($HDF_FLAGMASK))
	If BitAND($iFlags, 1) <> 0 Then $iFormat = BitOR($iFormat, $HDF_IMAGE)
	If BitAND($iFlags, 2) <> 0 Then $iFormat = BitOR($iFormat, $HDF_RTLREADING)
	If BitAND($iFlags, 4) <> 0 Then $iFormat = BitOR($iFormat, $HDF_SORTDOWN)
	If BitAND($iFlags, 8) <> 0 Then $iFormat = BitOR($iFormat, $HDF_SORTUP)
	Return _GUICtrlHeader_SetItemFormat($hWnd, $iIndex, $iFormat)
EndFunc   ;==>_GUICtrlHeader_SetItemFlags

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_SetItemFormat
; Description ...: Sets the format of the item
; Syntax.........: _GUICtrlHeader_SetItemFormat($hWnd, $iIndex, $iFormat)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
;                  $iFormat     - Combination of the following format identifiers:
;                  |$HDF_CENTER          - The item's contents are centered
;                  |$HDF_LEFT            - The item's contents are left-aligned
;                  |$HDF_RIGHT           - The item's contents are right-aligned
;                  |$HDF_BITMAP          - The item displays a bitmap
;                  |$HDF_BITMAP_ON_RIGHT - The bitmap appears to the right of text
;                  |$HDF_OWNERDRAW       - The header control's owner draws the item
;                  |$HDF_STRING          - The item displays a string
;                  |$HDF_IMAGE           - Display an image from an image list
;                  |$HDF_RTLREADING      - Text will read in the opposite direction from the text in the parent window
;                  |$HDF_SORTDOWN        - Draws a down-arrow on this item (Windows XP and above)
;                  |$HDF_SORTUP          - Draws an up-arrow on this item (Windows XP and above)
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_GetItemFormat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_SetItemFormat($hWnd, $iIndex, $iFormat)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_FORMAT)
	DllStructSetData($tItem, "Fmt", $iFormat)
	Return _GUICtrlHeader_SetItem($hWnd, $iIndex, $tItem)
EndFunc   ;==>_GUICtrlHeader_SetItemFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_SetItemImage
; Description ...: Sets the index of an image within the image list
; Syntax.........: _GUICtrlHeader_SetItemImage($hWnd, $iIndex, $iImage)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
;                  $iImage      - Zero based image index
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_GetItemImage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_SetItemImage($hWnd, $iIndex, $iImage)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_IMAGE)
	DllStructSetData($tItem, "Image", $iImage)
	Return _GUICtrlHeader_SetItem($hWnd, $iIndex, $tItem)
EndFunc   ;==>_GUICtrlHeader_SetItemImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_SetItemOrder
; Description ...: Sets the order in which the item appears
; Syntax.........: _GUICtrlHeader_SetItemOrder($hWnd, $iIndex, $iOrder)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
;                  $iOrder      - Zero based item order
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_GetItemOrder
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_SetItemOrder($hWnd, $iIndex, $iOrder)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_ORDER)
	DllStructSetData($tItem, "Order", $iOrder)
	Return _GUICtrlHeader_SetItem($hWnd, $iIndex, $tItem)
EndFunc   ;==>_GUICtrlHeader_SetItemOrder

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_SetItemParam
; Description ...: Sets the param value of the item
; Syntax.........: _GUICtrlHeader_SetItemParam($hWnd, $iIndex, $iParam)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
;                  $iParam      - Item param value
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_GetItemParam
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_SetItemParam($hWnd, $iIndex, $iParam)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_PARAM)
	DllStructSetData($tItem, "Param", $iParam)
	Return _GUICtrlHeader_SetItem($hWnd, $iIndex, $tItem)
EndFunc   ;==>_GUICtrlHeader_SetItemParam

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_SetItemText
; Description ...: Sets the item text
; Syntax.........: _GUICtrlHeader_SetItemText($hWnd, $iIndex, $sText)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
;                  $sText       - New item text
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_GetItemText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_SetItemText($hWnd, $iIndex, $sText)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlHeader_GetUnicodeFormat($hWnd)

	Local $iBuffer, $pBuffer
	If $sText <> -1 Then
		$iBuffer = StringLen($sText) + 1
		Local $tBuffer
		If $fUnicode Then
			$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
			$iBuffer *= 2
		Else
			$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
		EndIf
		DllStructSetData($tBuffer, "Text", $sText)
		$pBuffer = DllStructGetPtr($tBuffer)
	Else
		$iBuffer = 0
		$pBuffer = -1 ; LPSTR_TEXTCALLBACK
	EndIf
	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_TEXT)
	DllStructSetData($tItem, "TextMax", $iBuffer)
	Local $iRet
	If _WinAPI_InProcess($hWnd, $_ghHDRLastWnd) Then
		DllStructSetData($tItem, "Text", $pBuffer)
		$iRet = _SendMessage($hWnd, $HDM_SETITEMW, $iIndex, $tItem, 0, "wparam", "struct*")
	Else
		Local $iItem = DllStructGetSize($tItem)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iItem + $iBuffer, $tMemMap)
		If $sText <> -1 Then
			Local $pText = $pMemory + $iItem
			DllStructSetData($tItem, "Text", $pText)
			_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
		Else
			DllStructSetData($tItem, "Text", -1) ; LPSTR_TEXTCALLBACK
		EndIf
		_MemWrite($tMemMap, $tItem, $pMemory, $iItem)
		If $fUnicode Then
			$iRet = _SendMessage($hWnd, $HDM_SETITEMW, $iIndex, $pMemory, 0, "wparam", "ptr")
		Else
			$iRet = _SendMessage($hWnd, $HDM_SETITEMA, $iIndex, $pMemory, 0, "wparam", "ptr")
		EndIf
		_MemFree($tMemMap)
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlHeader_SetItemText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_SetItemWidth
; Description ...: Sets the item's width
; Syntax.........: _GUICtrlHeader_SetItemWidth($hWnd, $iIndex, $iWidth)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Zero based item index
;                  $iWidth      - New width for item
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_GetItemWidth
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_SetItemWidth($hWnd, $iIndex, $iWidth)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_WIDTH)
	DllStructSetData($tItem, "XY", $iWidth)
	Return _GUICtrlHeader_SetItem($hWnd, $iIndex, $tItem)
EndFunc   ;==>_GUICtrlHeader_SetItemWidth

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_SetOrderArray
; Description ...: Sets the current left-to-right order of items
; Syntax.........: _GUICtrlHeader_SetOrderArray($hWnd, ByRef $aOrder)
; Parameters ....: $hWnd        - Handle to control
;                  $aOrder      - Array that specifies the index values for items in the header:
;                  |[0] - Number of items in array
;                  |[1] - Item index 1
;                  |[2] - Item index 2
;                  |[n] - Item index n
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_GetOrderArray
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_SetOrderArray($hWnd, ByRef $aOrder)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Local $tBuffer = DllStructCreate("int[" & $aOrder[0] & "]")
	For $iI = 1 To $aOrder[0]
		DllStructSetData($tBuffer, 1, $aOrder[$iI], $iI)
	Next
	Local $iRet
	If _WinAPI_InProcess($hWnd, $_ghHDRLastWnd) Then
		$iRet = _SendMessage($hWnd, $HDM_SETORDERARRAY, $aOrder[0], $tBuffer, 0, "wparam", "struct*")
	Else
		Local $iBuffer = DllStructGetSize($tBuffer)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iBuffer, $tMemMap)
		_MemWrite($tMemMap, $tBuffer)
		$iRet = _SendMessage($hWnd, $HDM_SETORDERARRAY, $aOrder[0], $pMemory, 0, "wparam", "ptr")
		_MemFree($tMemMap)
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlHeader_SetOrderArray

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlHeader_SetUnicodeFormat
; Description ...: Sets the Unicode character format flag for the control
; Syntax.........: _GUICtrlHeader_SetUnicodeFormat($hWnd, $fUnicode)
; Parameters ....: $hWnd        - Handle to control
;                  $fUnicode    - Unicode flag:
;                  | True - Control uses Unicode characters
;                  |False - Control uses ANSI characters
; Return values .: Success      - The previous Unicode format flag
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlHeader_GetUnicodeFormat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlHeader_SetUnicodeFormat($hWnd, $fUnicode)
	If $Debug_HDR Then __UDF_ValidateClassName($hWnd, $__HEADERCONSTANT_ClassName)

	Return _SendMessage($hWnd, $HDM_SETUNICODEFORMAT, $fUnicode)
EndFunc   ;==>_GUICtrlHeader_SetUnicodeFormat
