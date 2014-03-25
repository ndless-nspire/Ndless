#include-once

#include "TreeViewConstants.au3"
#include "GuiImageList.au3"
#include "Memory.au3"
#include "WinAPI.au3"
#include "StructureConstants.au3"
#include "SendMessage.au3"
#include "UDFGlobalID.au3"

; #INDEX# =======================================================================================================================
; Title .........: TreeView
; AutoIt Version : 3.3.7.20++
; Language ......: English
; Description ...: Functions that assist with TreeView control management.
;                  A TreeView control is a window that displays a hierarchical list of items, such as the headings in a document,
;                  the entries in an index, or the files and directories on a disk. Each item consists of a label and an optional
;                  bitmapped image, and each item can have a list of subitems associated with it.  By clicking an item, the  user
;                  can expand or collapse the associated list of subitems.
; Author(s) .....: Paul Campbell (PaulIA), Gary Frost (gafrost), Holger Kotsch
; Dll(s) ........: user32.dll, comctl32.dll, shell32.dll
; ===============================================================================================================================

; Default treeview item extended structure
; http://msdn.microsoft.com/en-us/library/bb773459.aspx
; Min.OS: 2K, NT4 with IE 4.0, 98, 95 with IE 4.0

; #VARIABLES# ===================================================================================================================
Global $__ghTVLastWnd
Global $Debug_TV = False
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__TREEVIEWCONSTANT_ClassName = "SysTreeView32"
Global Const $__TREEVIEWCONSTANT_WM_SETREDRAW = 0x000B
Global Const $__TREEVIEWCONSTANT_DEFAULT_GUI_FONT = 17
; ===============================================================================================================================

; #OLD_FUNCTIONS#================================================================================================================
; Old Function/Name                      ; --> New Function/Name/Replacement(s)
;
; deprecated functions will no longer work
;_GUICtrlTreeViewDeleteAllItems           ; --> _GUICtrlTreeView_DeleteAll
;_GUICtrlTreeViewDeleteItem               ; --> _GUICtrlTreeView_Delete
;_GUICtrlTreeViewExpand                   ; --> _GUICtrlTreeView_Expand
;_GUICtrlTreeViewGetBkColor               ; --> _GUICtrlTreeView_GetBkColor
;_GUICtrlTreeViewGetCount                 ; --> _GUICtrlTreeView_GetCount
;_GUICtrlTreeViewGetIndent                ; --> _GUICtrlTreeView_GetIndent
;_GUICtrlTreeViewGetLineColor             ; --> _GUICtrlTreeView_GetLineColor
;_GUICtrlTreeViewGetParentHandle          ; --> _GUICtrlTreeView_GetParentHandle
;_GUICtrlTreeViewGetParentID              ; --> _GUICtrlTreeView_GetParentParam
;_GUICtrlTreeViewGetState                 ; --> _GUICtrlTreeView_GetState
;_GUICtrlTreeViewGetText                  ; --> _GUICtrlTreeView_GetText
;_GUICtrlTreeViewGetTextColor             ; --> _GUICtrlTreeView_GetTextColor
;_GUICtrlTreeViewGetTree                  ; --> _GUICtrlTreeView_GetTree
;_GUICtrlTreeViewInsertItem               ; --> _GUICtrlTreeView_InsertItem
;_GUICtrlTreeViewSelectItem               ; --> _GUICtrlTreeView_SelectItem
;_GUICtrlTreeViewSetBkColor               ; --> _GUICtrlTreeView_SetBkColor
;_GUICtrlTreeViewSetIcon                  ; --> _GUICtrlTreeView_SetIcon
;_GUICtrlTreeViewSetIndent                ; --> _GUICtrlTreeView_SetIndent
;_GUICtrlTreeViewSetLineColor             ; --> _GUICtrlTreeView_SetLineColor
;_GUICtrlTreeViewSetState                 ; --> _GUICtrlTreeView_SetState
;_GUICtrlTreeViewSetText                  ; --> _GUICtrlTreeView_SetText
;_GUICtrlTreeViewSetTextColor             ; --> _GUICtrlTreeView_SetTextColor
;_GUICtrlTreeViewSort                     ; --> _GUICtrlTreeView_Sort

; #NO_DOC_FUNCTION# =============================================================================================================
; Not working/documented/implrmented at this time
;
;_GUICtrlTreeView_GetOverlayImageIndex
;_GUICtrlTreeView_MapAccIDToItem
;_GUICtrlTreeView_MapItemToAccID
;_GUICtrlTreeView_SetOverlayImageIndex
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_GUICtrlTreeView_Add
;_GUICtrlTreeView_AddChild
;_GUICtrlTreeView_AddChildFirst
;_GUICtrlTreeView_AddFirst
;_GUICtrlTreeView_BeginUpdate
;_GUICtrlTreeView_ClickItem
;_GUICtrlTreeView_Create
;_GUICtrlTreeView_CreateDragImage
;_GUICtrlTreeView_CreateSolidBitMap
;_GUICtrlTreeView_Delete
;_GUICtrlTreeView_DeleteAll
;_GUICtrlTreeView_DeleteChildren
;_GUICtrlTreeView_Destroy
;_GUICtrlTreeView_DisplayRect
;_GUICtrlTreeView_DisplayRectEx
;_GUICtrlTreeView_EditText
;_GUICtrlTreeView_EndEdit
;_GUICtrlTreeView_EndUpdate
;_GUICtrlTreeView_EnsureVisible
;_GUICtrlTreeView_Expand
;_GUICtrlTreeView_ExpandedOnce
;_GUICtrlTreeView_FindItem
;_GUICtrlTreeView_FindItemEx
;_GUICtrlTreeView_GetBkColor
;_GUICtrlTreeView_GetBold
;_GUICtrlTreeView_GetChecked
;_GUICtrlTreeView_GetChildCount
;_GUICtrlTreeView_GetChildren
;_GUICtrlTreeView_GetCount
;_GUICtrlTreeView_GetCut
;_GUICtrlTreeView_GetDropTarget
;_GUICtrlTreeView_GetEditControl
;_GUICtrlTreeView_GetExpanded
;_GUICtrlTreeView_GetFirstChild
;_GUICtrlTreeView_GetFirstItem
;_GUICtrlTreeView_GetFirstVisible
;_GUICtrlTreeView_GetFocused
;_GUICtrlTreeView_GetHeight
;_GUICtrlTreeView_GetImageIndex
;_GUICtrlTreeView_GetImageListIconHandle
;_GUICtrlTreeView_GetIndent
;_GUICtrlTreeView_GetInsertMarkColor
;_GUICtrlTreeView_GetISearchString
;_GUICtrlTreeView_GetItemByIndex
;_GUICtrlTreeView_GetItemHandle
;_GUICtrlTreeView_GetItemParam
;_GUICtrlTreeView_GetLastChild
;_GUICtrlTreeView_GetLineColor
;_GUICtrlTreeView_GetNext
;_GUICtrlTreeView_GetNextChild
;_GUICtrlTreeView_GetNextSibling
;_GUICtrlTreeView_GetNextVisible
;_GUICtrlTreeView_GetNormalImageList
;_GUICtrlTreeView_GetParentHandle
;_GUICtrlTreeView_GetParentParam
;_GUICtrlTreeView_GetPrev
;_GUICtrlTreeView_GetPrevChild
;_GUICtrlTreeView_GetPrevSibling
;_GUICtrlTreeView_GetPrevVisible
;_GUICtrlTreeView_GetScrollTime
;_GUICtrlTreeView_GetSelected
;_GUICtrlTreeView_GetSelectedImageIndex
;_GUICtrlTreeView_GetSelection
;_GUICtrlTreeView_GetSiblingCount
;_GUICtrlTreeView_GetState
;_GUICtrlTreeView_GetStateImageIndex
;_GUICtrlTreeView_GetStateImageList
;_GUICtrlTreeView_GetText
;_GUICtrlTreeView_GetTextColor
;_GUICtrlTreeView_GetToolTips
;_GUICtrlTreeView_GetTree
;_GUICtrlTreeView_GetUnicodeFormat
;_GUICtrlTreeView_GetVisible
;_GUICtrlTreeView_GetVisibleCount
;_GUICtrlTreeView_HitTest
;_GUICtrlTreeView_HitTestEx
;_GUICtrlTreeView_HitTestItem
;_GUICtrlTreeView_Index
;_GUICtrlTreeView_InsertItem
;_GUICtrlTreeView_IsFirstItem
;_GUICtrlTreeView_IsParent
;_GUICtrlTreeView_Level
;_GUICtrlTreeView_SelectItem
;_GUICtrlTreeView_SelectItemByIndex
;_GUICtrlTreeView_SetBkColor
;_GUICtrlTreeView_SetBold
;_GUICtrlTreeView_SetChecked
;_GUICtrlTreeView_SetCheckedByIndex
;_GUICtrlTreeView_SetChildren
;_GUICtrlTreeView_SetCut
;_GUICtrlTreeView_SetDropTarget
;_GUICtrlTreeView_SetFocused
;_GUICtrlTreeView_SetHeight
;_GUICtrlTreeView_SetIcon
;_GUICtrlTreeView_SetImageIndex
;_GUICtrlTreeView_SetIndent
;_GUICtrlTreeView_SetInsertMark
;_GUICtrlTreeView_SetInsertMarkColor
;_GUICtrlTreeView_SetItemHeight
;_GUICtrlTreeView_SetItemParam
;_GUICtrlTreeView_SetLineColor
;_GUICtrlTreeView_SetNormalImageList
;_GUICtrlTreeView_SetScrollTime
;_GUICtrlTreeView_SetSelected
;_GUICtrlTreeView_SetSelectedImageIndex
;_GUICtrlTreeView_SetState
;_GUICtrlTreeView_SetStateImageIndex
;_GUICtrlTreeView_SetStateImageList
;_GUICtrlTreeView_SetText
;_GUICtrlTreeView_SetTextColor
;_GUICtrlTreeView_SetToolTips
;_GUICtrlTreeView_SetUnicodeFormat
;_GUICtrlTreeView_Sort
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;$tagTVINSERTSTRUCT
;__GUICtrlTreeView_AddItem
;__GUICtrlTreeView_ExpandItem
;__GUICtrlTreeView_GetItem
;__GUICtrlTreeView_ReverseColorOrder
;__GUICtrlTreeView_SetItem
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagTVINSERTSTRUCT
; Description ...: Contains information used to add a new item to a tree-view control
; Fields ........: Parent        - Handle to the parent item. If this member is $TVI_ROOT, the item is inserted at the root
;                  InsertAfter   - Handle to the item after which the new item is to be inserted, or one of the following values:
;                  |$TVI_FIRST - Inserts the item at the beginning of the list
;                  |$TVI_LAST  - Inserts the item at the end of the list
;                  |$TVI_ROOT  - Add the item as a root item
;                  |$TVI_SORT  - Inserts the item into the list in alphabetical order
;                  Mask          - Flags that indicate which of the other structure members contain valid data:
;                  |$TVIF_CHILDREN      - The Children member is valid
;                  |$TVIF_DI_SETITEM    - The will retain the supplied information and will not request it again
;                  |$TVIF_HANDLE        - The hItem member is valid
;                  |$TVIF_IMAGE         - The Image member is valid
;                  |$TVIF_INTEGRAL      - The Integral member is valid
;                  |$TVIF_PARAM         - The Param member is valid
;                  |$TVIF_SELECTEDIMAGE - The SelectedImage member is valid
;                  |$TVIF_STATE         - The State and StateMask members are valid
;                  |$TVIF_TEXT          - The Text and TextMax members are valid
;                  hItem         - Item to which this structure refers
;                  State         - Set of bit flags and image list indexes that indicate the item's state. When setting the state
;                  +of an item, the StateMask member indicates the bits of this member that are valid.  When retrieving the state
;                  +of an item, this member returns the current state for the bits indicated in  the  StateMask  member.  Bits  0
;                  +through 7 of this member contain the item state flags. Bits 8 through 11 of this member specify the one based
;                  +overlay image index.
;                  StateMask     - Bits of the state member that are valid.  If you are retrieving an item's state, set the  bits
;                  +of the stateMask member to indicate the bits to be returned in the state member. If you are setting an item's
;                  +state, set the bits of the stateMask member to indicate the bits of the state member that you want to set.
;                  Text          - Pointer to a null-terminated string that contains the item text.
;                  TextMax       - Size of the buffer pointed to by the Text member, in characters
;                  Image         - Index in the image list of the icon image to use when the item is in the nonselected state
;                  SelectedImage - Index in the image list of the icon image to use when the item is in the selected state
;                  Children      - Flag that indicates whether the item has associated child items. This member can be one of the
;                  +following values:
;                  |0 - The item has no child items
;                  |1 - The item has one or more child items
;                  Param         - A value to associate with the item
;                  Integral      - Height of the item
; Author ........: Paul Campbell (PaulIA)
; Modified ......: jpm
; Remarks .......:
; ===============================================================================================================================
Global Const $tagTVINSERTSTRUCT = "handle Parent;handle InsertAfter;" & $tagTVITEMEX

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_Add
; Description ...: Adds a new item
; Syntax.........: _GUICtrlTreeView_Add($hWnd, $hSibling, $sText[, $iImage = -1[, $iSelImage = -1]])
; Parameters ....: $hWnd        - Handle to the control
;                  $hSibling    - Sibling item
;                  $sText       - Text of the item
;                  $iImage      - Zero based index of the item's icon in the control's image list
;                  $iSelImage   - Zero based index of the item's icon in the control's image list
; Return values .: Success      - The handle to the new item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: The item is added as the last sibling of $hSibling. If the control is sorted, the function inserts the item in
;                  the correct sort order position rather than as the last child of $hSibling.
; Related .......: _GUICtrlTreeView_AddFirst
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_Add($hWnd, $hSibling, $sText, $iImage = -1, $iSelImage = -1)
	Return __GUICtrlTreeView_AddItem($hWnd, $hSibling, $sText, $TVNA_ADD, $iImage, $iSelImage)
EndFunc   ;==>_GUICtrlTreeView_Add

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_AddChild
; Description ...: Adds a new item
; Syntax.........: _GUICtrlTreeView_AddChild($hWnd, $hParent, $sText[, $iImage = -1[, $iSelImage = -1]])
; Parameters ....: $hWnd        - Handle to the control
;                  $hParent     - Parent item
;                  $sText       - Text of the item
;                  $iImage      - Zero based index of the item's icon in the control's image list
;                  $iSelImage   - Zero based index of the item's icon in the control's image list
; Return values .: Success      - The handle to the new item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: The item is added as a child of $hParent.  It is added to the end of $hParent's list of child  items.  If  the
;                  control is sorted, this function inserts the item in the correct sort order position, rather than as the  last
;                  child of $hParent.
; Related .......: _GUICtrlTreeView_AddChildFirst
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_AddChild($hWnd, $hParent, $sText, $iImage = -1, $iSelImage = -1)
	Return __GUICtrlTreeView_AddItem($hWnd, $hParent, $sText, $TVNA_ADDCHILD, $iImage, $iSelImage)
EndFunc   ;==>_GUICtrlTreeView_AddChild

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_AddChildFirst
; Description ...: Adds a new item
; Syntax.........: _GUICtrlTreeView_AddChildFirst($hWnd, $hParent, $sText[, $iImage = -1[, $iSelImage = -1]])
; Parameters ....: $hWnd        - Handle to the control
;                  $hParent     - Parent item
;                  $sText       - Text of the item
;                  $iImage      - Zero based index of the item's icon in the control's image list
;                  $iSelImage   - Zero based index of the item's icon in the control's image list
; Return values .: Success      - The handle to the new item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: The item is added as the first child of $hParent. Items that appear after the added item are moved down.
; Related .......: _GUICtrlTreeView_AddChild
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_AddChildFirst($hWnd, $hParent, $sText, $iImage = -1, $iSelImage = -1)
	Return __GUICtrlTreeView_AddItem($hWnd, $hParent, $sText, $TVNA_ADDCHILDFIRST, $iImage, $iSelImage)
EndFunc   ;==>_GUICtrlTreeView_AddChildFirst

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_AddFirst
; Description ...: Adds a new item
; Syntax.........: _GUICtrlTreeView_AddFirst($hWnd, $hSibling, $sText[, $iImage = -1[, $iSelImage = -1]])
; Parameters ....: $hWnd        - Handle to the control
;                  $hSibling    - Sibling item
;                  $sText       - Text of the item
;                  $iImage      - Zero based index of the item's icon in the control's image list
;                  $iSelImage   - Zero based index of the item's icon in the control's image list
; Return values .: Success      - The handle to the new item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: The item is added as the first sibling of $hSibling.  Items that appear after the added item are moved down.
; Related .......: _GUICtrlTreeView_Add
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_AddFirst($hWnd, $hSibling, $sText, $iImage = -1, $iSelImage = -1)
	Return __GUICtrlTreeView_AddItem($hWnd, $hSibling, $sText, $TVNA_ADDFIRST, $iImage, $iSelImage)
EndFunc   ;==>_GUICtrlTreeView_AddFirst

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlTreeView_AddItem
; Description ...: Add a new item
; Syntax.........: __GUICtrlTreeView_AddItem($hWnd, $hRelative, $sText, $iMethod[, $iImage = -1[, $iSelImage = -1]])
; Parameters ....: $hWnd        - Handle to the control
;                  $hRelative   - Handle to an existing item that will be either parent or sibling to the new item
;                  $sText       - The text for the new item
;                  $iMethod     - The relationship between the new item and the $hRelative item
;                  |$TVNA_ADD           - The item becomes the last sibling of the other item
;                  |$TVNA_ADDFIRST      - The item becomes the first sibling of the other item
;                  |$TVNA_ADDCHILD      - The item becomes the sibling before the other item
;                  |$TVNA_ADDCHILDFIRST - The item becomes the last child of the other item
;                  |$TVNA_INSERT        - The item becomes the first child of the other item
;                  $iImage      - Zero based index of the item's icon in the control's image list
;                  $iSelImage   - Zero based index of the item's icon in the control's image list
;                  $iParam      - Application Defined Data
; Return values .: Success      - The handle to the new item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: This function is for interall use only and should not normally be called by the end user
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GUICtrlTreeView_AddItem($hWnd, $hRelative, $sText, $iMethod, $iImage = -1, $iSelImage = -1, $iParam = 0)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	Local $iAddMode
	Switch $iMethod
		Case $TVNA_ADD, $TVNA_ADDCHILD
			$iAddMode = $TVTA_ADD
		Case $TVNA_ADDFIRST, $TVNA_ADDCHILDFIRST
			$iAddMode = $TVTA_ADDFIRST
		Case Else
			$iAddMode = $TVTA_INSERT
	EndSwitch

	Local $hItem, $hItemID = 0
	If $hRelative <> 0x00000000 Then
		Switch $iMethod
			Case $TVNA_ADD, $TVNA_ADDFIRST
				$hItem = _GUICtrlTreeView_GetParentHandle($hWnd, $hRelative)
			Case $TVNA_ADDCHILD, $TVNA_ADDCHILDFIRST
				$hItem = $hRelative
			Case Else
				$hItem = _GUICtrlTreeView_GetParentHandle($hWnd, $hRelative)
				$hItemID = _GUICtrlTreeView_GetPrevSibling($hWnd, $hRelative)
				If $hItemID = 0x00000000 Then $iAddMode = $TVTA_ADDFIRST
		EndSwitch
	EndIf

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $iBuffer = StringLen($sText) + 1
	Local $tBuffer
	Local $fUnicode = _GUICtrlTreeView_GetUnicodeFormat($hWnd)
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
		$iBuffer *= 2
	Else
		$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
	EndIf
	Local $tInsert = DllStructCreate($tagTVINSERTSTRUCT)
	Switch $iAddMode
		Case $TVTA_ADDFIRST
			DllStructSetData($tInsert, "InsertAfter", $TVI_FIRST)
		Case $TVTA_ADD
			DllStructSetData($tInsert, "InsertAfter", $TVI_LAST)
		Case $TVTA_INSERT
			DllStructSetData($tInsert, "InsertAfter", $hItemID)
	EndSwitch
	Local $iMask = BitOR($TVIF_TEXT, $TVIF_PARAM)
	If $iImage >= 0 Then $iMask = BitOR($iMask, $TVIF_IMAGE)
	If $iSelImage >= 0 Then $iMask = BitOR($iMask, $TVIF_SELECTEDIMAGE)
	DllStructSetData($tBuffer, "Text", $sText)
	DllStructSetData($tInsert, "Parent", $hItem)
	DllStructSetData($tInsert, "Mask", $iMask)
	DllStructSetData($tInsert, "TextMax", $iBuffer)
	DllStructSetData($tInsert, "Image", $iImage)
	DllStructSetData($tInsert, "SelectedImage", $iSelImage)
	DllStructSetData($tInsert, "Param", $iParam)

	Local $hResult
	If _WinAPI_InProcess($hWnd, $__ghTVLastWnd) Then
		DllStructSetData($tInsert, "Text", DllStructGetPtr($tBuffer))
		$hResult = _SendMessage($hWnd, $TVM_INSERTITEMW, 0, $tInsert, 0, "wparam", "struct*", "handle")
	Else
		Local $iInsert = DllStructGetSize($tInsert)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iInsert + $iBuffer, $tMemMap)
		Local $pText = $pMemory + $iInsert
		_MemWrite($tMemMap, $tInsert, $pMemory, $iInsert)
		_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
		DllStructSetData($tInsert, "Text", $pText)
		If $fUnicode Then
			$hResult = _SendMessage($hWnd, $TVM_INSERTITEMW, 0, $pMemory, 0, "wparam", "ptr", "handle")
		Else
			$hResult = _SendMessage($hWnd, $TVM_INSERTITEMA, 0, $pMemory, 0, "wparam", "ptr", "handle")
		EndIf
		_MemFree($tMemMap)
	EndIf
	Return $hResult
EndFunc   ;==>__GUICtrlTreeView_AddItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_BeginUpdate
; Description ...: Prevents updating of the control until the EndUpdate function is called
; Syntax.........: _GUICtrlTreeView_BeginUpdate($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_EndUpdate
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_BeginUpdate($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $__TREEVIEWCONSTANT_WM_SETREDRAW) = 0
EndFunc   ;==>_GUICtrlTreeView_BeginUpdate

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_ClickItem
; Description ...: Click on a item
; Syntax.........: _GUICtrlTreeView_ClickItem($hWnd, $hItem[, $sButton = "left"[, $fMove = False[, $iClicks = 1[, $iSpeed = 0]]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
;                  $sButton     - Button to click
;                  $fMove       - If True, the mouse will be moved. If False, the mouse does not move.
;                  $iClicks     - Number of clicks
;                  $iSpeed      - Mouse movement speed
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_ClickItem($hWnd, $hItem, $sButton = "left", $fMove = False, $iClicks = 1, $iSpeed = 0)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tRect = _GUICtrlTreeView_DisplayRectEx($hWnd, $hItem, True)
	If @error Then Return SetError(@error, @error, 0)
	; Always click on the left-most portion of the control, not the center.  A
	; very wide control may be off-screen which means clicking on it's center
	; will click outside the window.
	Local $tPoint = _WinAPI_PointFromRect($tRect, False)
	_WinAPI_ClientToScreen($hWnd, $tPoint)
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
	Return 1
EndFunc   ;==>_GUICtrlTreeView_ClickItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_Create
; Description ...: Create a TreeView control
; Syntax.........: _GUICtrlTreeView_Create($hWnd, $iX, $iY[, $iWidth=150[, $iHeight=150[, $iStyle=0x00000037[, $iExStyle=0x00000000]]]])
; Parameters ....: $hWnd        - Handle to parent or owner window
;                  $iX          - Horizontal position of the control
;                  $iY          - Vertical position of the control
;                  $iWidth      - Control width
;                  $iHeight     - Control height
;                  $iStyle      - Control style:
;                  |DllStructGetData($TVS_CHECKBOXES - Enables check boxes for items, "") A check box will be displayed only if an image is
;                  +associated with the item. When set to this style, the control effectively uses DrawFrameControl to create and
;                  +set a state image list containing two images.  State image 1 is the unchecked box and state image  2  is  the
;                  +checked box.   Setting the state image to zero removes the check box.  Version 5.80 displays a check box even
;                  +if no image is associated with the item.
;                  |$TVS_DISABLEDRAGDROP - Prevents the control from sending $TVN_BEGINDRAG notification messages
;                  |$TVS_EDITLABELS      - Allows the user to edit the item labels
;                  |DllStructGetData($TVS_FULLROWSELECT - Enables full row selection, "") The entire row of the selected item is highlighted, and
;                  +clicking anywhere on an item's row causes it to be selected.  This style cannot be used in  conjunction  with
;                  +the DllStructGetData($TVS_HASLINES style, "")
;                  |DllStructGetData($TVS_HASBUTTONS - Displays plus and minus buttons next to parent items, "") The user clicks the buttons to
;                  +expand or collapse a parent item's list of child items.  To include buttons with items at the root, you  must
;                  +also specify DllStructGetData($TVS_LINESATROOT, "")
;                  |$TVS_HASLINES        - Uses lines to show the hierarchy of items
;                  |$TVS_INFOTIP         - Obtains ToolTip information by sending the $TVN_GETINFOTIP notification
;                  |DllStructGetData($TVS_LINESATROOT - Uses lines to link items at the root of the control, "") This value is ignored if
;                  +DllStructGetData($TVS_HASLINES is not also specified, "")
;                  |DllStructGetData($TVS_NOHSCROLL - Disables horizontal scrolling in the control, "") The control will not display any
;                  +horizontal scroll bars.
;                  |DllStructGetData($TVS_NONEVENHEIGHT - Sets the height of the items to an odd height with the $TVM_SETITEMHEIGHT message, "") By
;                  +default the height of items must be an even value.
;                  |DllStructGetData($TVS_NOSCROLL - Disables both horizontal and vertical scrolling in the control, "") The control will not
;                  +display any scroll bars.
;                  |$TVS_NOTOOLTIPS      - Disables ToolTips
;                  |$TVS_RTLREADING      - Causes text to be displayed from right to left
;                  |$TVS_SHOWSELALWAYS   - Causes a selected item to remain selected when the control loses focus
;                  |$TVS_SINGLEEXPAND    - Causes the item being selected to expand and the item  being  unselected  to  collapse
;                  +upon selection.  If the mouse is used to single-click the selected item and that item is closed, it  will  be
;                  +expanded.  If the user holds down the CTRL key while selecting an item, the item being unselected will not be
;                  +collapsed.  Version 5.80 causes the item being selected to expand and the item being unselected  to  collapse
;                  +upon selection.  If the user holds down the CTRL key while selecting an item, the item being unselected  will
;                  +not be collapsed.
;                  |$TVS_TRACKSELECT     - Enables hot tracking
;                  -
;                  |Default: $TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS
;                  |Forced: $WS_CHILD, $WS_VISIBLE
;                  $iExStyle    - Control extended style
; Return values .: Success      - Handle to the control
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......: This function is for Advanced users and for learning how the control works.
; Related .......: _GUICtrlTreeView_Destroy
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_Create($hWnd, $iX, $iY, $iWidth = 150, $iHeight = 150, $iStyle = 0x00000037, $iExStyle = 0x00000000)
	If Not IsHWnd($hWnd) Then
		; Invalid Window handle for _GUICtrlTreeView_Create 1st parameter
		Return SetError(1, 0, 0)
	EndIf


	If $iWidth = -1 Then $iWidth = 150
	If $iHeight = -1 Then $iHeight = 150
	If $iStyle = -1 Then $iStyle = BitOR($TVS_SHOWSELALWAYS, $TVS_DISABLEDRAGDROP, $TVS_LINESATROOT, $TVS_HASLINES, $TVS_HASBUTTONS)
	If $iExStyle = -1 Then $iExStyle = 0x00000000

	$iStyle = BitOR($iStyle, $__UDFGUICONSTANT_WS_CHILD, $__UDFGUICONSTANT_WS_VISIBLE)

	Local $nCtrlID = __UDF_GetNextGlobalID($hWnd)
	If @error Then Return SetError(@error, @extended, 0)

	Local $hTree = _WinAPI_CreateWindowEx($iExStyle, $__TREEVIEWCONSTANT_ClassName, "", $iStyle, $iX, $iY, $iWidth, $iHeight, $hWnd, $nCtrlID)
	_WinAPI_SetFont($hTree, _WinAPI_GetStockObject($__TREEVIEWCONSTANT_DEFAULT_GUI_FONT))
	Return $hTree
EndFunc   ;==>_GUICtrlTreeView_Create

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_CreateDragImage
; Description ...: Creates a dragging bitmap for the specified item
; Syntax.........: _GUICtrlTreeView_CreateDragImage($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: Success      - The image list handle to which the dragging bitmap was added
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: If you create the control without an associated image list, you cannot use this function to create  the  image
;                  to display during a drag operation.  You must implement your own method of creating a drag  cursor.   You  are
;                  responsible for destroying the image list when it is no longer needed.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_CreateDragImage($hWnd, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_CREATEDRAGIMAGE, 0, $hItem, 0, "wparam", "handle", "handle")
EndFunc   ;==>_GUICtrlTreeView_CreateDragImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_CreateSolidBitMap
; Description ...: Creates a solid color bitmap
; Syntax.........: _GUICtrlTreeView_CreateSolidBitMap($hWnd, $iColor, $iWidth, $iHeight)
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
Func _GUICtrlTreeView_CreateSolidBitMap($hWnd, $iColor, $iWidth, $iHeight)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	Return _WinAPI_CreateSolidBitmap($hWnd, $iColor, $iWidth, $iHeight)
EndFunc   ;==>_GUICtrlTreeView_CreateSolidBitMap

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_Delete
; Description ...: Removes an item and all its children
; Syntax.........: _GUICtrlTreeView_Delete($hWnd[, $hItem = 0])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle/Control ID of item
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......: re-written by Holger Kotsch, re-written again by Gary Frost
; Remarks .......:
; Related .......: _GUICtrlTreeView_DeleteAll, _GUICtrlTreeView_DeleteChildren
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_Delete($hWnd, $hItem = 0)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If $hItem = 0 Then $hItem = 0x00000000

	If IsHWnd($hWnd) Then
		If $hItem = 0x00000000 Then
			$hItem = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_CARET, 0, 0, "wparam", "handle", "handle")
			If $hItem <> 0x00000000 Then Return _SendMessage($hWnd, $TVM_DELETEITEM, 0, $hItem, 0, "wparam", "handle", "hwnd") <> 0
			Return False
		Else
			If GUICtrlDelete($hItem) Then Return True
			Return _SendMessage($hWnd, $TVM_DELETEITEM, 0, $hItem, 0, "wparam", "handle", "hwnd") <> 0
		EndIf
	Else
		If $hItem = 0x00000000 Then
			$hItem = GUICtrlSendMsg($hWnd, $TVM_GETNEXTITEM, $TVGN_CARET, 0)
			If $hItem <> 0x00000000 Then Return GUICtrlSendMsg($hWnd, $TVM_DELETEITEM, 0, $hItem) <> 0
			Return False
		Else
			If GUICtrlDelete($hItem) Then Return True
			Return GUICtrlSendMsg($hWnd, $TVM_DELETEITEM, 0, $hItem) <> 0
		EndIf
	EndIf
EndFunc   ;==>_GUICtrlTreeView_Delete

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_DeleteAll
; Description ...: Removes all items from a tree-view control
; Syntax.........: _GUICtrlTreeView_DeleteAll($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_Delete, _GUICtrlTreeView_DeleteChildren
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_DeleteAll($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	Local $Count
	If IsHWnd($hWnd) Then
		_SendMessage($hWnd, $TVM_DELETEITEM, 0, $TVI_ROOT)
		$Count = _GUICtrlTreeView_GetCount($hWnd) ; might be created with autoit create
		If $Count Then Return GUICtrlSendMsg($hWnd, $TVM_DELETEITEM, 0, $TVI_ROOT) <> 0
		Return True
	Else
		GUICtrlSendMsg($hWnd, $TVM_DELETEITEM, 0, $TVI_ROOT)
		$Count = _GUICtrlTreeView_GetCount($hWnd) ; might be created with udf
		If $Count Then Return _SendMessage($hWnd, $TVM_DELETEITEM, 0, $TVI_ROOT) <> 0
		Return True
	EndIf
	Return False
EndFunc   ;==>_GUICtrlTreeView_DeleteAll

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_DeleteChildren
; Description ...: Deletes all children of a item
; Syntax.........: _GUICtrlTreeView_DeleteChildren($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item whose children will be deleted
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_Delete, _GUICtrlTreeView_DeleteAll
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_DeleteChildren($hWnd, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	Local $fResult
	If IsHWnd($hWnd) Then
		$fResult = _SendMessage($hWnd, $TVM_EXPAND, BitOR($TVE_COLLAPSE, $TVE_COLLAPSERESET), $hItem, 0, "wparam", "handle")
	Else
		$fResult = GUICtrlSendMsg($hWnd, $TVM_EXPAND, BitOR($TVE_COLLAPSE, $TVE_COLLAPSERESET), $hItem)
	EndIf
	Return $fResult
EndFunc   ;==>_GUICtrlTreeView_DeleteChildren

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_Destroy
; Description ...: Delete the control
; Syntax.........: _GUICtrlTreeView_Destroy(ByRef $hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True, Handle is set to 0
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Restricted to only be used on TreeViews created with _GUICtrlTreeView_Create
; Related .......: _GUICtrlTreeView_Create
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_Destroy(ByRef $hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)
;~ 	If Not _WinAPI_IsClassName($hWnd, $__TREEVIEWCONSTANT_ClassName) Then Return SetError(2, 2, False)

	Local $Destroyed = 0
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $__ghTVLastWnd) Then
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
EndFunc   ;==>_GUICtrlTreeView_Destroy

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_DisplayRect
; Description ...: Returns the bounding rectangle for a tree item
; Syntax.........: _GUICtrlTreeView_DisplayRect($hWnd, $hItem[, $fTextOnly = False])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item whose rectangle will be returned
;                  $fTextOnly   - If the True, the bounding rectangle includes only the text of the item.  Otherwise, it includes
;                  +the entire line that the item occupies.
; Return values .: Success      - Array with the following format:
;                  |$aRect[0] - X coordinate of the upper left corner of the rectangle
;                  |$aRect[1] - Y coordinate of the upper left corner of the rectangle
;                  |$aRect[2] - X coordinate of the lower right corner of the rectangle
;                  |$aRect[3] - Y coordinate of the lower right corner of the rectangle
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_DisplayRectEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_DisplayRect($hWnd, $hItem, $fTextOnly = False)

	Local $tRect = _GUICtrlTreeView_DisplayRectEx($hWnd, $hItem, $fTextOnly)
	If @error Then Return SetError(@error, @error, 0)
	Local $aRect[4]
	$aRect[0] = DllStructGetData($tRect, "Left")
	$aRect[1] = DllStructGetData($tRect, "Top")
	$aRect[2] = DllStructGetData($tRect, "Right")
	$aRect[3] = DllStructGetData($tRect, "Bottom")
	Return $aRect
EndFunc   ;==>_GUICtrlTreeView_DisplayRect

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_DisplayRectEx
; Description ...: Returns the bounding rectangle for a tree item
; Syntax.........: _GUICtrlTreeView_DisplayRectEx($hWnd, $hItem[, $fTextOnly = False])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item whose rectangle will be returned
;                  $fTextOnly   - If the True, the bounding rectangle includes only the text of the item.  Otherwise, it includes
;                  +the entire line that the item occupies.
; Return values .: Success      - $tagRECT structure that holds the bounding rectangle.  The coordinates are relative to the upper
;                  +left corner of the control.
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_DisplayRect, $tagRECT
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_DisplayRectEx($hWnd, $hItem, $fTextOnly = False)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	Local $tRect = DllStructCreate($tagRECT)
	Local $iRet
	If IsHWnd($hWnd) Then
		; RECT is expected to point to the item in its first member.
		DllStructSetData($tRect, "Left", $hItem)
		If _WinAPI_InProcess($hWnd, $__ghTVLastWnd) Then
			$iRet = _SendMessage($hWnd, $TVM_GETITEMRECT, $fTextOnly, $tRect, 0, "wparam", "struct*")
		Else
			Local $iRect = DllStructGetSize($tRect)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iRect, $tMemMap)
			_MemWrite($tMemMap, $tRect)
			$iRet = _SendMessage($hWnd, $TVM_GETITEMRECT, $fTextOnly, $pMemory, 0, "wparam", "ptr")
			_MemRead($tMemMap, $pMemory, $tRect, $iRect)
			_MemFree($tMemMap)
		EndIf
	Else
		If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
		; RECT is expected to point to the item in its first member.
		DllStructSetData($tRect, "Left", $hItem)
		$iRet = GUICtrlSendMsg($hWnd, $TVM_GETITEMRECT, $fTextOnly, DllStructGetPtr($tRect))
	EndIf

	; On failure ensure Left is set to 0 and not the item handle.
	If Not $iRet Then DllStructSetData($tRect, "Left", 0)
	Return SetError($iRet = 0, $iRet, $tRect)
EndFunc   ;==>_GUICtrlTreeView_DisplayRectEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_EditText
; Description ...: Begins in-place editing of the specified item's text
; Syntax.........: _GUICtrlTreeView_EditText($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item to edit
; Return values .: Success      - The handle to the edit control
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_EndEdit, _GUICtrlTreeView_GetEditControl
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_EditText($hWnd, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_WinAPI_SetFocus($hWnd)
	Local $fUnicode = _GUICtrlTreeView_GetUnicodeFormat($hWnd)
	If $fUnicode Then
		Return _SendMessage($hWnd, $TVM_EDITLABELW, 0, $hItem, 0, "wparam", "handle", "handle")
	Else
		Return _SendMessage($hWnd, $TVM_EDITLABELA, 0, $hItem, 0, "wparam", "handle", "handle")
	EndIf
EndFunc   ;==>_GUICtrlTreeView_EditText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_EndEdit
; Description ...: Ends the editing of the item's text
; Syntax.........: _GUICtrlTreeView_EndEdit($hWnd, $fCancel = False)
; Parameters ....: $hWnd        - Handle to the control
;                  $fCancel     - Indicates whether the editing is canceled without being saved to the item.  If True, the system
;                  +cancels editing without saving the changes.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_EditText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_EndEdit($hWnd, $fCancel = False)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_ENDEDITLABELNOW, $fCancel) <> 0
EndFunc   ;==>_GUICtrlTreeView_EndEdit

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_EndUpdate
; Description ...: Enables screen repainting that was turned off with the BeginUpdate function
; Syntax.........: _GUICtrlTreeView_EndUpdate($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_BeginUpdate
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_EndUpdate($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $__TREEVIEWCONSTANT_WM_SETREDRAW, 1) = 0
EndFunc   ;==>_GUICtrlTreeView_EndUpdate

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_EnsureVisible
; Description ...: Ensures that a item is visible, expanding the parent item or scrolling the control if necessary
; Syntax.........: _GUICtrlTreeView_EnsureVisible($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .:  True        - if the system scrolled the items in the tree-view control and no items were expanded
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetVisible
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_EnsureVisible($hWnd, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_ENSUREVISIBLE, 0, $hItem, 0, "wparam", "handle") <> 0
EndFunc   ;==>_GUICtrlTreeView_EnsureVisible

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_Expand
; Description ...: Expands or collapses the list of child items associated with the specified parent item, if any
; Syntax.........: _GUICtrlTreeView_Expand($hWnd[, $hItem = 0[, $fExpand = True]])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
;                  $fExpand     - Expand or Collapse, use the following values:
;                  | True       - Expand items
;                  |False       - Collapse items
; Return values .:
; Author ........: Holger Kotsch
; Modified.......: Gary Frost
; Remarks .......:
; Related .......: _GUICtrlTreeView_ExpandedOnce, _GUICtrlTreeView_GetExpanded
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_Expand($hWnd, $hItem = 0, $fExpand = True)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	If $hItem = 0 Then $hItem = 0x00000000

	If $hItem = 0x00000000 Then
		$hItem = $TVI_ROOT
	Else
		If Not IsHWnd($hItem) Then
			Local $hItem_tmp = GUICtrlGetHandle($hItem)
			If $hItem_tmp <> 0x00000000 Then $hItem = $hItem_tmp
		EndIf
	EndIf

	If $fExpand Then
		__GUICtrlTreeView_ExpandItem($hWnd, $TVE_EXPAND, $hItem)
	Else
		__GUICtrlTreeView_ExpandItem($hWnd, $TVE_COLLAPSE, $hItem)
	EndIf
EndFunc   ;==>_GUICtrlTreeView_Expand

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlTreeView_ExpandItem($hWnd, $iExpand, $hItem)
; Description ...: Expands/Collapes the item and child(ren), if any
; Syntax.........: __GUICtrlTreeView_ExpandItem($hWnd, $iExpand, $hItem)
; Parameters ....: $hWnd  - Handle to the control
; Return values .:
; Author ........: Holger Kotsch
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GUICtrlTreeView_ExpandItem($hWnd, $iExpand, $hItem)
	If Not IsHWnd($hWnd) Then

		If $hItem = 0x00000000 Then
			$hItem = $TVI_ROOT
		Else
			$hItem = GUICtrlGetHandle($hItem)
			If $hItem = 0 Then Return
		EndIf
		$hWnd = GUICtrlGetHandle($hWnd)
	EndIf

	_SendMessage($hWnd, $TVM_EXPAND, $iExpand, $hItem, 0, "wparam", "handle")

	If $iExpand = $TVE_EXPAND And $hItem > 0 Then _SendMessage($hWnd, $TVM_ENSUREVISIBLE, 0, $hItem, 0, "wparam", "handle")

	$hItem = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_CHILD, $hItem, 0, "wparam", "handle")

	While $hItem <> 0x00000000
		Local $h_child = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_CHILD, $hItem, 0, "wparam", "handle")
		If $h_child <> 0x00000000 Then __GUICtrlTreeView_ExpandItem($hWnd, $iExpand, $hItem)
		$hItem = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_NEXT, $hItem, 0, "wparam", "handle")
	WEnd
EndFunc   ;==>__GUICtrlTreeView_ExpandItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_ExpandedOnce
; Description ...: Indicates if the item's list of child items has been expanded at least once
; Syntax.........: _GUICtrlTreeView_ExpandedOnce($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: True         - Item has been expanded at least once
;                  False        - Item has not been expanded at least once
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_Expand
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_ExpandedOnce($hWnd, $hItem)
	Return BitAND(_GUICtrlTreeView_GetState($hWnd, $hItem), $TVIS_EXPANDEDONCE) <> 0
EndFunc   ;==>_GUICtrlTreeView_ExpandedOnce

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_FindItem
; Description ...: Retrieves a item based on it's text
; Syntax.........: _GUICtrlTreeView_FindItem($hWnd, $sText[, $fInStr = False[, $hStart = 0]])
; Parameters ....: $hWnd        - Handle to the control
;                  $sText       - Text to search for
;                  $fInStr      - If True, the text can be anywhere in the item's text.
;                  $hStart      - Item to start searching from.  If 0, the root item is used.
; Return values .: Success      - The handle of the first item that contains the item text
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The search is case insensitive
; Related .......: _GUICtrlTreeView_FindItemEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_FindItem($hWnd, $sText, $fInStr = False, $hStart = 0)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	If $hStart = 0 Then $hStart = _GUICtrlTreeView_GetFirstItem($hWnd)
	While $hStart <> 0x00000000
		Local $sItem = _GUICtrlTreeView_GetText($hWnd, $hStart)
		Switch $fInStr
			Case False
				If $sItem = $sText Then Return $hStart
			Case True
				If StringInStr($sItem, $sText) Then Return $hStart
		EndSwitch
		$hStart = _GUICtrlTreeView_GetNext($hWnd, $hStart)
	WEnd
EndFunc   ;==>_GUICtrlTreeView_FindItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_FindItemEx
; Description ...: Retrieves a item based on a tree path
; Syntax.........: _GUICtrlTreeView_FindItemEx($hWnd, $sPath[, $hStart = 0])
; Parameters ....: $hWnd        - Handle to the control
;                  $sPath       - The path to take, delimiter of your choice, see Opt("GUIDataSeparatorChar")
;                  $hStart      - Item to start searching from.  If 0, the root item is used.
; Return values .: Success      - The handle of the first item that matches the tree path
;                  Failure      - 0
; Author ........: Miguel Pilar (luckyb), Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The search is case insensitive
; Related .......: _GUICtrlTreeView_FindItem
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_FindItemEx($hWnd, $sPath, $hStart = 0)
	Local $sDelimiter = Opt("GUIDataSeparatorChar")

	Local $iIndex = 1
	Local $aParts = StringSplit($sPath, $sDelimiter)
	If $hStart = 0 Then $hStart = _GUICtrlTreeView_GetFirstItem($hWnd)
	While ($iIndex <= $aParts[0]) And ($hStart <> 0x00000000)
		If StringStripWS(_GUICtrlTreeView_GetText($hWnd, $hStart), 3) = StringStripWS($aParts[$iIndex], 3) Then
			If $iIndex = $aParts[0] Then Return $hStart
			$iIndex += 1
			__GUICtrlTreeView_ExpandItem($hWnd, $TVE_EXPAND, $hStart)
			$hStart = _GUICtrlTreeView_GetFirstChild($hWnd, $hStart)
		Else
			$hStart = _GUICtrlTreeView_GetNextSibling($hWnd, $hStart)
			__GUICtrlTreeView_ExpandItem($hWnd, $TVE_COLLAPSE, $hStart)
		EndIf
	WEnd
	Return $hStart
EndFunc   ;==>_GUICtrlTreeView_FindItemEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetBkColor
; Description ...: Retrieve the text back color
; Syntax.........: _GUICtrlTreeView_GetBkColor($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Hex RGB Back Color
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetBkColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetBkColor($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tc = Hex(String(_SendMessage($hWnd, $TVM_GETBKCOLOR)), 6)
	Return '0x' & StringMid($tc, 5, 2) & StringMid($tc, 3, 2) & StringMid($tc, 1, 2)
EndFunc   ;==>_GUICtrlTreeView_GetBkColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetBold
; Description ...: Indicates if the item is drawn in a bold style
; Syntax.........: _GUICtrlTreeView_GetBold($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: True         - Item is drawn in bold
;                  False        - Item is not drawn in bold
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetBold
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetBold($hWnd, $hItem)
	Return BitAND(_GUICtrlTreeView_GetState($hWnd, $hItem), $TVIS_BOLD) <> 0
EndFunc   ;==>_GUICtrlTreeView_GetBold

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetChecked
; Description ...: Indicates if a item has its checkbox checked
; Syntax.........: _GUICtrlTreeView_GetChecked($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: True         - Item's checkbox is checked
;                  False        - Item's checkbox is not checked
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetChecked
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetChecked($hWnd, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tItem = DllStructCreate($tagTVITEMEX)
	DllStructSetData($tItem, "Mask", $TVIF_STATE)
	DllStructSetData($tItem, "hItem", $hItem)
	__GUICtrlTreeView_GetItem($hWnd, $tItem)
	Return BitAND(DllStructGetData($tItem, "State"), $TVIS_CHECKED) = $TVIS_CHECKED
EndFunc   ;==>_GUICtrlTreeView_GetChecked

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetChildCount
; Description ...: Retrieves the number of children of an parent item
; Syntax.........: _GUICtrlTreeView_GetChildCount($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to item
; Return values .: Success      - Number of Children
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetCount, _GUICtrlTreeView_GetSiblingCount
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetChildCount($hWnd, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $iRet = 0

	Local $hNext = _GUICtrlTreeView_GetFirstChild($hWnd, $hItem)
	If $hNext = 0x00000000 Then Return -1
	Do
		$iRet += 1
		$hNext = _GUICtrlTreeView_GetNextSibling($hWnd, $hNext)
	Until $hNext = 0x00000000
	Return $iRet
EndFunc   ;==>_GUICtrlTreeView_GetChildCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetChildren
; Description ...: Indicates whether the item children flag is set
; Syntax.........: _GUICtrlTreeView_GetChildren($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: True         - Item children flag is set
;                  False        - Item children flag is not set
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetChildren
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetChildren($hWnd, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tItem = DllStructCreate($tagTVITEMEX)
	DllStructSetData($tItem, "Mask", $TVIF_CHILDREN)
	DllStructSetData($tItem, "hItem", $hItem)
	__GUICtrlTreeView_GetItem($hWnd, $tItem)
	Return DllStructGetData($tItem, "Children") <> 0
EndFunc   ;==>_GUICtrlTreeView_GetChildren

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetCount
; Description ...: Retrieves a count of the items
; Syntax.........: _GUICtrlTreeView_GetCount($hWnd)
; Parameters ....: $hWnd  - Handle to the control
; Return values .: Success      - Count of items
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetChildCount, _GUICtrlTreeView_GetSiblingCount
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetCount($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_GETCOUNT)
EndFunc   ;==>_GUICtrlTreeView_GetCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetCut
; Description ...: Indicates if the item is drawn as if selected as part of a cut and paste operation
; Syntax.........: _GUICtrlTreeView_GetCut($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: True         - Item is cut
;                  False        - Item is not cut
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetCut
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetCut($hWnd, $hItem)
	Return BitAND(_GUICtrlTreeView_GetState($hWnd, $hItem), $TVIS_CUT) <> 0
EndFunc   ;==>_GUICtrlTreeView_GetCut

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetDropTarget
; Description ...: Indicates whether the item is drawn as a drag and drop target
; Syntax.........: _GUICtrlTreeView_GetDropTarget($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: True         - Item is drawn as a drop target
;                  False        - Item is not drawn as a drop target
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetDropTarget
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetDropTarget($hWnd, $hItem)
	Return BitAND(_GUICtrlTreeView_GetState($hWnd, $hItem), $TVIS_DROPHILITED) <> 0
EndFunc   ;==>_GUICtrlTreeView_GetDropTarget

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetEditControl
; Description ...: Retrieves the handle to the edit control being used to edit a item's text
; Syntax.........: _GUICtrlTreeView_GetEditControl($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Handle to the edit control
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_EditText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetEditControl($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_GETEDITCONTROL, 0, 0, 0, "wparam", "lparam", "handle")
EndFunc   ;==>_GUICtrlTreeView_GetEditControl

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetExpanded
; Description ...: Indicates whether the item is expanded
; Syntax.........: _GUICtrlTreeView_GetExpanded($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: True         - Item is expanded
;                  False        - Item is not expanded
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_Expand
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetExpanded($hWnd, $hItem)
	Return BitAND(_GUICtrlTreeView_GetState($hWnd, $hItem), $TVIS_EXPANDED) <> 0
EndFunc   ;==>_GUICtrlTreeView_GetExpanded

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetFirstChild
; Description ...: Retrieves the first child item of the specified item
; Syntax.........: _GUICtrlTreeView_GetFirstChild($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: Success      - The handle of the first child item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetLastChild, _GUICtrlTreeView_GetNextChild, _GUICtrlTreeView_GetPrevChild
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetFirstChild($hWnd, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)
	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_CHILD, $hItem, 0, "wparam", "handle", "handle")
EndFunc   ;==>_GUICtrlTreeView_GetFirstChild

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetFirstItem
; Description ...: Retrieves the topmost or very first item
; Syntax.........: _GUICtrlTreeView_GetFirstItem($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The handle of the first item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetFirstVisible
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetFirstItem($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_ROOT, 0, 0, "wparam", "lparam", "handle")
EndFunc   ;==>_GUICtrlTreeView_GetFirstItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetFirstVisible
; Description ...: Retrieves the first visible item in the control
; Syntax.........: _GUICtrlTreeView_GetFirstVisible($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The handle of the first visible item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetFirstItem
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetFirstVisible($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_FIRSTVISIBLE, 0, 0, "wparam", "lparam", "handle")
EndFunc   ;==>_GUICtrlTreeView_GetFirstVisible

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetFocused
; Description ...: Indicates whether the item has focus
; Syntax.........: _GUICtrlTreeView_GetFocused($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: True         - Item has focus
;                  False        - Item does not have focus
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetFocused
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetFocused($hWnd, $hItem)
	Return BitAND(_GUICtrlTreeView_GetState($hWnd, $hItem), $TVIS_FOCUSED) <> 0
EndFunc   ;==>_GUICtrlTreeView_GetFocused

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetHeight
; Description ...: Retrieves the current height of the each item
; Syntax.........: _GUICtrlTreeView_GetHeight($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Item height in pixels
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetHeight
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetHeight($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_GETITEMHEIGHT)
EndFunc   ;==>_GUICtrlTreeView_GetHeight

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetImageIndex
; Description ...: Retrieves the normal state image index
; Syntax.........: _GUICtrlTreeView_GetImageIndex($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: Success      - Image list index
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetImageIndex
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetImageIndex($hWnd, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)

	Local $tItem = DllStructCreate($tagTVITEMEX)
	DllStructSetData($tItem, "Mask", $TVIF_IMAGE)
	DllStructSetData($tItem, "hItem", $hItem)
	__GUICtrlTreeView_GetItem($hWnd, $tItem)
	Return DllStructGetData($tItem, "Image")
EndFunc   ;==>_GUICtrlTreeView_GetImageIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetImageListIconHandle
; Description ...: Retrieve ImageList handle
; Syntax.........: _GUICtrlTreeView_GetImageListIconHandle($hWnd, $iIndex)
; Parameters ....: $hWnd  - Handle to the control
;                  $iIndex      - ImageList index to retrieve
; Return values .: Success      - ImageList handle
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetImageListIconHandle($hWnd, $iIndex)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $hImageList = _SendMessage($hWnd, $TVM_GETIMAGELIST, 0, 0, 0, "wparam", "lparam", "handle")
	Local $hIcon = DllCall("comctl32.dll", "handle", "ImageList_GetIcon", "handle", $hImageList, "int", $iIndex, "uint", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return $hIcon[0]
EndFunc   ;==>_GUICtrlTreeView_GetImageListIconHandle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetIndent
; Description ...: Retrieves the amount, in pixels, that child items are indented relative to their parent items
; Syntax.........: _GUICtrlTreeView_GetIndent($hWnd)
; Parameters ....: $hWnd  - Handle to the control
; Return values .: Success      - The amount of indentation
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetIndent
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetIndent($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_GETINDENT)
EndFunc   ;==>_GUICtrlTreeView_GetIndent

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetInsertMarkColor
; Description ...: Retrieves the color used to draw the insertion mark
; Syntax.........: _GUICtrlTreeView_GetInsertMarkColor($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Current insertion mark color
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetInsertMarkColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetInsertMarkColor($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_GETINSERTMARKCOLOR)
EndFunc   ;==>_GUICtrlTreeView_GetInsertMarkColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetISearchString
; Description ...: Retrieves the incremental search string
; Syntax.........: _GUICtrlTreeView_GetISearchString($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Incremental search string if the control is in incremental search mode, otherwise ""
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: The incremental search string is used to select an item based on characters typed by the user
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetISearchString($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $fUnicode = _GUICtrlTreeView_GetUnicodeFormat($hWnd)
	Local $iBuffer
	If $fUnicode Then
		$iBuffer = _SendMessage($hWnd, $TVM_GETISEARCHSTRINGW) + 1
	Else
		$iBuffer = _SendMessage($hWnd, $TVM_GETISEARCHSTRINGA) + 1
	EndIf
	If $iBuffer = 1 Then Return ""

	Local $tBuffer
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
		$iBuffer *= 2
	Else
		$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
	EndIf
	If _WinAPI_InProcess($hWnd, $__ghTVLastWnd) Then
		_SendMessage($hWnd, $TVM_GETISEARCHSTRINGW, 0, $tBuffer, 0, "wparam", "struct*")
	Else
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iBuffer, $tMemMap)
		If $fUnicode Then
			_SendMessage($hWnd, $TVM_GETISEARCHSTRINGW, 0, $pMemory, 0, "wparam", "ptr")
		Else
			_SendMessage($hWnd, $TVM_GETISEARCHSTRINGA, 0, $pMemory, 0, "wparam", "ptr")
		EndIf
		_MemRead($tMemMap, $pMemory, $tBuffer, $iBuffer)
		_MemFree($tMemMap)
	EndIf

	Return DllStructGetData($tBuffer, "Text")
EndFunc   ;==>_GUICtrlTreeView_GetISearchString

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlTreeView_GetItem
; Description ...: Retrieves some or all of a item's attributes
; Syntax.........: __GUICtrlTreeView_GetItem($hWnd, ByRef $tItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $tItem       - $tagTVITEMEX structure used to request/receive item information
;                  +the item
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: This function is used internally and should not normally be called by the end user
; Related .......: __GUICtrlTreeView_SetItem
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GUICtrlTreeView_GetItem($hWnd, ByRef $tItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $fUnicode = _GUICtrlTreeView_GetUnicodeFormat($hWnd)

	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $__ghTVLastWnd) Then
			$iRet = _SendMessage($hWnd, $TVM_GETITEMW, 0, $tItem, 0, "wparam", "struct*")
		Else
			Local $iItem = DllStructGetSize($tItem)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iItem, $tMemMap)
			_MemWrite($tMemMap, $tItem)
			If $fUnicode Then
				$iRet = _SendMessage($hWnd, $TVM_GETITEMW, 0, $pMemory, 0, "wparam", "ptr")
			Else
				$iRet = _SendMessage($hWnd, $TVM_GETITEMA, 0, $pMemory, 0, "wparam", "ptr")
			EndIf
			_MemRead($tMemMap, $pMemory, $tItem, $iItem)
			_MemFree($tMemMap)
		EndIf
	Else
		Local $pItem = DllStructGetPtr($tItem)
		If $fUnicode Then
			$iRet = GUICtrlSendMsg($hWnd, $TVM_GETITEMW, 0, $pItem)
		Else
			$iRet = GUICtrlSendMsg($hWnd, $TVM_GETITEMA, 0, $pItem)
		EndIf
	EndIf
	Return $iRet <> 0
EndFunc   ;==>__GUICtrlTreeView_GetItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetItemByIndex
; Description ...: Retrieve a item by its position in the list of child items
; Syntax.........: _GUICtrlTreeView_GetItemByIndex($hWnd, $hItem, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
;                  $iIndex      - Zero based index of item in the list of child items
; Return values .: Success      - Handle of the item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_Index
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetItemByIndex($hWnd, $hItem, $iIndex)
	Local $hResult = _GUICtrlTreeView_GetFirstChild($hWnd, $hItem)
	While ($hResult <> 0x00000000) And ($iIndex > 0)
		$hResult = _GUICtrlTreeView_GetNextSibling($hWnd, $hResult)
		$iIndex -= 1
	WEnd
	Return $hResult
EndFunc   ;==>_GUICtrlTreeView_GetItemByIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetItemHandle
; Description ...: Retrieve the item handle
; Syntax.........: _GUICtrlTreeView_GetItemHandle($hWnd[, $hItem = 0])
; Parameters ....: $hWnd  - Handle to the control
;                  $hItem       - Item ID
; Return values .: Success      - Item handle
;                  Failure      - 0
; Author ........: Holger Kotsch
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetItemHandle($hWnd, $hItem = 0)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If $hItem = 0 Then $hItem = 0x00000000
	If IsHWnd($hWnd) Then
		If $hItem = 0x00000000 Then $hItem = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_ROOT, 0, 0, "wparam", "lparam", "handle")
	Else
		If $hItem = 0x00000000 Then
			$hItem = Ptr(GUICtrlSendMsg($hWnd, $TVM_GETNEXTITEM, $TVGN_ROOT, 0))
		Else
			Local $hTempItem = GUICtrlGetHandle($hItem)
			If $hTempItem <> 0x00000000 Then $hItem = $hTempItem
		EndIf
	EndIf

	Return $hItem
EndFunc   ;==>_GUICtrlTreeView_GetItemHandle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetItemParam
; Description ...: Retrieves the application specific value of the item
; Syntax.........: _GUICtrlTreeView_GetItemParam($hWnd[, $hItem = 0])
; Parameters ....: $hWnd  - Handle to the control
;                  $hItem       - Item ID
; Return values .: Success      - Item Param
;                  Failure      - 0
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetItemParam
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetItemParam($hWnd, $hItem = 0)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	Local $tItem = DllStructCreate($tagTVITEMEX)
	DllStructSetData($tItem, "Mask", $TVIF_PARAM)
	DllStructSetData($tItem, "Param", 0)
	Local $fUnicode = _GUICtrlTreeView_GetUnicodeFormat($hWnd)
	If IsHWnd($hWnd) Then
		; get the handle to item selected
		If $hItem = 0x00000000 Then $hItem = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_CARET, 0, 0, "wparam", "lparam", "handle")
		If $hItem = 0x00000000 Then Return False
		DllStructSetData($tItem, "hItem", $hItem)
		; get the item properties
		If $fUnicode Then
			If _SendMessage($hWnd, $TVM_GETITEMW, 0, $tItem, 0, "wparam", "struct*") = 0 Then Return False
		Else
			If _SendMessage($hWnd, $TVM_GETITEMA, 0, $tItem, 0, "wparam", "struct*") = 0 Then Return False
		EndIf
	Else
		; get the handle to item selected
		If $hItem = 0x00000000 Then
			$hItem = Ptr(GUICtrlSendMsg($hWnd, $TVM_GETNEXTITEM, $TVGN_CARET, 0))
			If $hItem = 0x00000000 Then Return False
		Else
			Local $hTempItem = GUICtrlGetHandle($hItem)
			If $hTempItem <> 0x00000000 Then
				$hItem = $hTempItem
			Else
				Return False
			EndIf
		EndIf
		DllStructSetData($tItem, "hItem", $hItem)
		; get the item properties
		If $fUnicode Then
			If GUICtrlSendMsg($hWnd, $TVM_GETITEMW, 0, DllStructGetPtr($tItem)) = 0 Then Return False
		Else
			If GUICtrlSendMsg($hWnd, $TVM_GETITEMA, 0, DllStructGetPtr($tItem)) = 0 Then Return False
		EndIf
	EndIf

	Return DllStructGetData($tItem, "Param")
EndFunc   ;==>_GUICtrlTreeView_GetItemParam

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetLastChild
; Description ...: Retrieves the last child item of the specified item
; Syntax.........: _GUICtrlTreeView_GetLastChild($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: Success      - The handle of the last child item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetFirstChild, _GUICtrlTreeView_GetNextChild, _GUICtrlTreeView_GetPrevChild
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetLastChild($hWnd, $hItem)
	Local $hResult = _GUICtrlTreeView_GetFirstChild($hWnd, $hItem)
	If $hResult <> 0x00000000 Then
		Local $hNext = $hResult
		Do
			$hResult = $hNext
			$hNext = _GUICtrlTreeView_GetNextSibling($hWnd, $hNext)
		Until $hNext = 0x00000000
	EndIf
	Return $hResult
EndFunc   ;==>_GUICtrlTreeView_GetLastChild

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetLineColor
; Description ...: Retrieve the line color
; Syntax.........: _GUICtrlTreeView_GetLineColor($hWnd)
; Parameters ....: $hWnd  - Handle to the control
; Return values .: Success      - Hex RGB Line Color
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetLineColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetLineColor($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tc = Hex(String(_SendMessage($hWnd, $TVM_GETLINECOLOR)), 6)
	Return '0x' & StringMid($tc, 5, 2) & StringMid($tc, 3, 2) & StringMid($tc, 1, 2)
EndFunc   ;==>_GUICtrlTreeView_GetLineColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetNext
; Description ...: Retrieves the next item after the calling item
; Syntax.........: _GUICtrlTreeView_GetNext($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: Success      - Handle of the next item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......: If the calling item is the last item, _GUICtrlTreeView_GetNext returns 0, otherwise it  will  return  the  next  item
;                  including items that aren't visible and child items.  To get the next item at the same level  as  the  calling
;                  item use _GUICtrlTreeView_GetNextSibling.  To get the next visible item, use _GUICtrlTreeView_GetNextVisible.
; Related .......: _GUICtrlTreeView_GetNextVisible, _GUICtrlTreeView_GetNextSibling, _GUICtrlTreeView_GetPrev
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetNext($hWnd, $hItem)
	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $hResult = 0
	If $hItem <> 0x00000000 And $hItem <> 0 Then
		Local $hNext = _GUICtrlTreeView_GetFirstChild($hWnd, $hItem)
		If $hNext = 0x00000000 Then
			$hNext = _GUICtrlTreeView_GetNextSibling($hWnd, $hItem)
		EndIf
		Local $hParent = $hItem
		While ($hNext = 0x00000000) And ($hParent <> 0x00000000)
			$hParent = _GUICtrlTreeView_GetParentHandle($hWnd, $hParent)
			If $hParent = 0x00000000 Then
				$hNext = 0x00000000
				ExitLoop
			EndIf
			$hNext = _GUICtrlTreeView_GetNextSibling($hWnd, $hParent)
		WEnd
		If $hNext = 0x00000000 Then $hNext = 0
		$hResult = $hNext
	EndIf
	Return $hResult
EndFunc   ;==>_GUICtrlTreeView_GetNext

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetNextChild
; Description ...: Returns the next item at the same level as the specified item
; Syntax.........: _GUICtrlTreeView_GetNextChild($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the child item
; Return values .: Success      - Handle to the next child item
;                  Failure      - 0
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetFirstChild, _GUICtrlTreeView_GetLastChild, _GUICtrlTreeView_GetPrevChild
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetNextChild($hWnd, $hItem)
	Return _GUICtrlTreeView_GetNextSibling($hWnd, $hItem)
EndFunc   ;==>_GUICtrlTreeView_GetNextChild

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetNextSibling
; Description ...: Returns the next item at the same level as the specified item
; Syntax.........: _GUICtrlTreeView_GetNextSibling($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: Success      - Handle to the next sibling item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetNext, _GUICtrlTreeView_GetPrevSibling
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetNextSibling($hWnd, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_NEXT, $hItem, 0, "wparam", "handle", "handle")
EndFunc   ;==>_GUICtrlTreeView_GetNextSibling

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetNextVisible
; Description ...: Retrieves the next visible item that follows the specified item
; Syntax.........: _GUICtrlTreeView_GetNextVisible($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: Success      - Handle to the next visible item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:  The specified item must be visible
; Related .......: _GUICtrlTreeView_GetNext, _GUICtrlTreeView_GetPrevVisible
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetNextVisible($hWnd, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_NEXTVISIBLE, $hItem, 0, "wparam", "handle", "handle")
EndFunc   ;==>_GUICtrlTreeView_GetNextVisible

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetNormalImageList
; Description ...: Retrieves the normal image list
; Syntax.........: _GUICtrlTreeView_GetNormalImageList($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Handle to image list
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetNormalImageList
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetNormalImageList($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_GETIMAGELIST, $TVSIL_NORMAL, 0, 0, "wparam", "lparam", "handle")
EndFunc   ;==>_GUICtrlTreeView_GetNormalImageList

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlTreeView_GetOverlayImageIndex
; Description ...: Returns the index of the image from the image list that is used as an overlay mask
; Syntax.........: _GUICtrlTreeView_GetOverlayImageIndex($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: Success      - Overlay list index
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetOverlayImageIndex
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlTreeView_GetOverlayImageIndex($hWnd, $hItem)
	Local $tItem = DllStructCreate($tagTVITEMEX)
	DllStructSetData($tItem, "Mask", $TVIF_STATE)
	DllStructSetData($tItem, "hItem", $hItem)
	DllStructSetData($tItem, "StateMask", $TVIS_OVERLAYMASK)
	__GUICtrlTreeView_GetItem($hWnd, $tItem)
	Return DllStructGetData($tItem, "Image")
EndFunc   ;==>_GUICtrlTreeView_GetOverlayImageIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetParentHandle
; Description ...: Retrieve the parent handle of item
; Syntax.........: _GUICtrlTreeView_GetParentHandle($hWnd[, $hItem = 0])
; Parameters ....: $hWnd  - Handle to the control
;                  $hItem - item ID/handle
; Return values .: Success      - Handle to Parent item
;                  Failure      - 0
; Author ........: Gary Frost (gafrost), Holger Kotsch
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetParentHandle($hWnd, $hItem = 0)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

;~ 	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	If $hItem = 0 Then $hItem = 0x00000000

	; get the handle to item selected
	If $hItem = 0x00000000 Then
		If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
		$hItem = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_CARET, 0, 0, "wparam", "handle", "handle")
		If $hItem = 0x00000000 Then Return False
	Else
		If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
		If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	EndIf
	; get the handle of the parent item
	Local $hParent = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_PARENT, $hItem, 0, "wparam", "handle", "handle")

	Return $hParent
EndFunc   ;==>_GUICtrlTreeView_GetParentHandle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetParentParam
; Description ...: Retrieve the parent control ID/Param of item
; Syntax.........: _GUICtrlTreeView_GetParentParam($hWnd, $hItem = 0)
; Parameters ....: $hWnd  - Handle to the control
;                  $hItem - item ID/Param
; Return values .: Success      - The parent control Param
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetParentParam($hWnd, $hItem = 0)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If $hItem = 0 Then $hItem = 0x00000000

	Local $tTVITEM = DllStructCreate($tagTVITEMEX)
	DllStructSetData($tTVITEM, "Mask", $TVIF_PARAM)
	DllStructSetData($tTVITEM, "Param", 0)

	Local $hParent
	If IsHWnd($hWnd) Then
		; get the handle to item selected
		If $hItem = 0x00000000 Then $hItem = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_CARET, 0, 0, "wparam", "handle", "handle")
		If $hItem = 0x00000000 Then Return False
		; get the handle of the parent item
		$hParent = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_PARENT, $hItem, 0, "wparam", "handle", "handle")
		DllStructSetData($tTVITEM, "hItem", $hParent)
		; get the item properties
		If _SendMessage($hWnd, $TVM_GETITEMA, 0, $tTVITEM, 0, "wparam", "struct*") = 0 Then Return False
	Else
		; get the handle to item selected
		If $hItem = 0x00000000 Then
			$hItem = GUICtrlSendMsg($hWnd, $TVM_GETNEXTITEM, $TVGN_CARET, 0)
			If $hItem = 0x00000000 Then Return False
		Else
			Local $hTempItem = GUICtrlGetHandle($hItem)
			If $hTempItem <> 0x00000000 Then
				$hItem = $hTempItem
			Else
				Return False
			EndIf
		EndIf
		; get the handle of the parent item
		$hParent = GUICtrlSendMsg($hWnd, $TVM_GETNEXTITEM, $TVGN_PARENT, $hItem)
		DllStructSetData($tTVITEM, "hItem", $hParent)
		; get the item properties
		If GUICtrlSendMsg($hWnd, $TVM_GETITEMA, 0, DllStructGetPtr($tTVITEM)) = 0 Then Return False
	EndIf

	Return DllStructGetData($tTVITEM, "Param")
EndFunc   ;==>_GUICtrlTreeView_GetParentParam

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetPrev
; Description ...: Retrieves the previous item before the calling item
; Syntax.........: _GUICtrlTreeView_GetPrev($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: Success      - Handle of the previous item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: If the calling item is the first item _GUICtrlTreeView_GetPrev returns 0, otherwise it will return the previous
;                  item including items that aren't visible and child items. To get the previous item at the same level as the
;                  calling item use  _GUICtrlTreeView_GetPrevChild. To get the previous visible item, use
;                  _GUICtrlTreeView_GetPrevVisible.
; Related .......: _GUICtrlTreeView_GetNext, _GUICtrlTreeView_GetPrevChild, _GUICtrlTreeView_GetPrevVisible
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetPrev($hWnd, $hItem)
	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $hResult = _GUICtrlTreeView_GetPrevChild($hWnd, $hItem)
	If $hResult <> 0x00000000 Then
		Local $hPrev = $hResult
		Do
			$hResult = $hPrev
			$hPrev = _GUICtrlTreeView_GetLastChild($hWnd, $hPrev)
		Until $hPrev = 0x00000000
	Else
		$hResult = _GUICtrlTreeView_GetParentHandle($hWnd, $hItem)
	EndIf
	Return $hResult
EndFunc   ;==>_GUICtrlTreeView_GetPrev

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetPrevChild
; Description ...: Retrieves the previous child item of a specified item
; Syntax.........: _GUICtrlTreeView_GetPrevChild($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: Success      - Handle to the previous child item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetNextChild, _GUICtrlTreeView_GetFirstChild, _GUICtrlTreeView_GetLastChild, _GUICtrlTreeView_GetPrev
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetPrevChild($hWnd, $hItem)
	Return _GUICtrlTreeView_GetPrevSibling($hWnd, $hItem)
EndFunc   ;==>_GUICtrlTreeView_GetPrevChild

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetPrevSibling
; Description ...: Returns the previous item before the calling item at the same level
; Syntax.........: _GUICtrlTreeView_GetPrevSibling($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: Success      - Handle to the previous sibling item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetNextSibling
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetPrevSibling($hWnd, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_PREVIOUS, $hItem, 0, "wparam", "handle", "handle")
EndFunc   ;==>_GUICtrlTreeView_GetPrevSibling

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetPrevVisible
; Description ...: Retrieves the first visible item that precedes the specified item
; Syntax.........: _GUICtrlTreeView_GetPrevVisible($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: Success      - Handle to the previous visible item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetNextVisible, _GUICtrlTreeView_GetPrev
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetPrevVisible($hWnd, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_PREVIOUSVISIBLE, $hItem, 0, "wparam", "handle", "handle")
EndFunc   ;==>_GUICtrlTreeView_GetPrevVisible

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetScrollTime
; Description ...: Retrieves the maximum scroll time
; Syntax.........: _GUICtrlTreeView_GetScrollTime($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Maximum scroll time, in milliseconds
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: The maximum scroll time is the longest amount of time that a scroll operation can take.  Scrolling will be
;                  adjusted so that the scroll will take place within the maximum scroll time.  A scroll operation may take less
;                  time than the maximum.
; Related .......: _GUICtrlTreeView_SetScrollTime
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetScrollTime($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_GETSCROLLTIME)
EndFunc   ;==>_GUICtrlTreeView_GetScrollTime

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetSelected
; Description ...: Indicates whether the item appears in the selected state
; Syntax.........: _GUICtrlTreeView_GetSelected($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: True         - Item is in the selected state
;                  False        - Item is not in the selected state
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetSelected
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetSelected($hWnd, $hItem)
	Return BitAND(_GUICtrlTreeView_GetState($hWnd, $hItem), $TVIS_SELECTED) <> 0
EndFunc   ;==>_GUICtrlTreeView_GetSelected

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetSelectedImageIndex
; Description ...: Retrieves the index in the image list of the image displayed for the item when it is selected
; Syntax.........: _GUICtrlTreeView_GetSelectedImageIndex($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: Success      - Selected list index
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetSelectedImageIndex
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetSelectedImageIndex($hWnd, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tItem = DllStructCreate($tagTVITEMEX)
	DllStructSetData($tItem, "Mask", $TVIF_SELECTEDIMAGE)
	DllStructSetData($tItem, "hItem", $hItem)
	__GUICtrlTreeView_GetItem($hWnd, $tItem)
	Return DllStructGetData($tItem, "SelectedImage")
EndFunc   ;==>_GUICtrlTreeView_GetSelectedImageIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetSelection
; Description ...: Retrieves the currently selected item
; Syntax.........: _GUICtrlTreeView_GetSelection($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Handle to the currently selected item or 0 in no item is selected
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetSelection($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_CARET, 0, 0, "wparam", "handle", "handle")
EndFunc   ;==>_GUICtrlTreeView_GetSelection

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetSiblingCount
; Description ...: Retrieves the number of siblings at the level of an item
; Syntax.........: _GUICtrlTreeView_GetSiblingCount($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to item
; Return values .: Success      - Number of siblings
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetCount, _GUICtrlTreeView_GetChildCount
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetSiblingCount($hWnd, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $hNext, $iRet = 0

	Local $hParent = _GUICtrlTreeView_GetParentHandle($hWnd, $hItem)
	If $hParent <> 0x00000000 Then
		$hNext = _GUICtrlTreeView_GetFirstChild($hWnd, $hParent)
		If $hNext = 0x00000000 Then Return -1
		Do
			$iRet += 1
			$hNext = _GUICtrlTreeView_GetNextSibling($hWnd, $hNext)
		Until $hNext = 0x00000000
	Else
		$hNext = _GUICtrlTreeView_GetFirstItem($hWnd)
		If $hNext = 0x00000000 Then Return -1
		Do
			$iRet += 1
			$hNext = _GUICtrlTreeView_GetNextSibling($hWnd, $hNext)
		Until $hNext = 0x00000000
	EndIf
	Return $iRet
EndFunc   ;==>_GUICtrlTreeView_GetSiblingCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetState
; Description ...: Retrieve the state of the item
; Syntax.........: _GUICtrlTreeView_GetState($hWnd[, $hItem = 0])
; Parameters ....: $hWnd  - Handle to the control
;                  $hItem - item ID/handle
; Return values .: Success      - The state of the item
;                  Failure      - False
; Author ........: Holger Kotsch
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetState
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetState($hWnd, $hItem = 0)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If $hItem = 0 Then $hItem = 0x00000000

	$hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If $hItem = 0x00000000 Then Return SetError(1, 1, 0)

	Local $tTVITEM = DllStructCreate($tagTVITEMEX)
	DllStructSetData($tTVITEM, "Mask", $TVIF_STATE)
	DllStructSetData($tTVITEM, "hItem", $hItem)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	If _WinAPI_InProcess($hWnd, $__ghTVLastWnd) Then
		_SendMessage($hWnd, $TVM_GETITEMA, 0, $tTVITEM, 0, "wparam", "struct*")
	Else
		Local $iSize = DllStructGetSize($tTVITEM)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iSize, $tMemMap)
		_MemWrite($tMemMap, $tTVITEM)
		_SendMessage($hWnd, $TVM_GETITEMA, 0, $pMemory)
		_MemRead($tMemMap, $pMemory, $tTVITEM, $iSize)
		_MemFree($tMemMap)
	EndIf

	Return DllStructGetData($tTVITEM, "State")
EndFunc   ;==>_GUICtrlTreeView_GetState

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetStateImageIndex
; Description ...: Retrieves the index of the state image to display for the item
; Syntax.........: _GUICtrlTreeView_GetStateImageIndex($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: Success      - State image index
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetStateImageIndex
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetStateImageIndex($hWnd, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	$hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)

	Local $tItem = DllStructCreate($tagTVITEMEX)
	DllStructSetData($tItem, "Mask", $TVIF_STATE)
	DllStructSetData($tItem, "hItem", $hItem)
	__GUICtrlTreeView_GetItem($hWnd, $tItem)
	Return BitShift(BitAND(DllStructGetData($tItem, "State"), $TVIS_STATEIMAGEMASK), 12)
EndFunc   ;==>_GUICtrlTreeView_GetStateImageIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetStateImageList
; Description ...: Retrieves the handle to the state image list
; Syntax.........: _GUICtrlTreeView_GetStateImageList($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Handle to image list on success
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetStateImageList
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetStateImageList($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_GETIMAGELIST, $TVSIL_STATE, 0, 0, "wparam", "handle", "handle")
EndFunc   ;==>_GUICtrlTreeView_GetStateImageList

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetText
; Description ...: Retrieve the item text
; Syntax.........: _GUICtrlTreeView_GetText($hWnd[, $hItem = 0])
; Parameters ....: $hWnd  - Handle to the control
;                  $hItem - item ID/handle
; Return values .: Success      - Text from item
;                  Failure      - Empty string
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetText($hWnd, $hItem = 0)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	If $hItem = 0x00000000 Then Return SetError(1, 1, "")

	Local $tTVITEM = DllStructCreate($tagTVITEMEX)
	Local $tText
	Local $fUnicode = _GUICtrlTreeView_GetUnicodeFormat($hWnd)
	If $fUnicode Then
		$tText = DllStructCreate("wchar Buffer[4096]"); create a text 'area' for receiving the text
	Else
		$tText = DllStructCreate("char Buffer[4096]"); create a text 'area' for receiving the text
	EndIf

	DllStructSetData($tTVITEM, "Mask", $TVIF_TEXT)
	DllStructSetData($tTVITEM, "hItem", $hItem)
	DllStructSetData($tTVITEM, "TextMax", 4096)

	If _WinAPI_InProcess($hWnd, $__ghTVLastWnd) Then
		DllStructSetData($tTVITEM, "Text", DllStructGetPtr($tText))
		_SendMessage($hWnd, $TVM_GETITEMW, 0, $tTVITEM, 0, "wparam", "struct*")
	Else
		Local $iItem = DllStructGetSize($tTVITEM)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iItem + 4096, $tMemMap)
		Local $pText = $pMemory + $iItem
		DllStructSetData($tTVITEM, "Text", $pText)
		_MemWrite($tMemMap, $tTVITEM, $pMemory, $iItem)
		If $fUnicode Then
			_SendMessage($hWnd, $TVM_GETITEMW, 0, $pMemory, 0, "wparam", "ptr")
		Else
			_SendMessage($hWnd, $TVM_GETITEMA, 0, $pMemory, 0, "wparam", "ptr")
		EndIf
		_MemRead($tMemMap, $pText, $tText, 4096)
		_MemFree($tMemMap)
	EndIf

	Return DllStructGetData($tText, "Buffer")
EndFunc   ;==>_GUICtrlTreeView_GetText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetTextColor
; Description ...: Retrieve the text color
; Syntax.........: _GUICtrlTreeView_GetTextColor($hWnd)
; Parameters ....: $hWnd  - Handle to the control
; Return values .: Success      - Hex RGB Text Color
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetTextColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetTextColor($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tc = Hex(String(_SendMessage($hWnd, $TVM_GETTEXTCOLOR)), 6)
	Return '0x' & StringMid($tc, 5, 2) & StringMid($tc, 3, 2) & StringMid($tc, 1, 2)
EndFunc   ;==>_GUICtrlTreeView_GetTextColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetToolTips
; Description ...: Retrieves the handle to the child ToolTip control
; Syntax.........: _GUICtrlTreeView_GetToolTips($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Handle to the child ToolTip control, or 0 if the control is not using ToolTips
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: When created, controls automatically create a ToolTip control.  To cause a control not to use ToolTips, create
;                  the control with the $TVS_NOTOOLTIPS style
; Related .......: _GUICtrlTreeView_SetToolTips
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetToolTips($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_GETTOOLTIPS, 0, 0, 0, "wparam", "lparam", "hwnd")
EndFunc   ;==>_GUICtrlTreeView_GetToolTips

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetTree
; Description ...: Retrieve all items text
; Syntax.........: _GUICtrlTreeView_GetTree($hWnd, $hItem)
; Parameters ....: $hWnd  - Handle to the control
;                  $hItem - item ID/handle
; Return values .: Success      - Tree Path of Item
;                  Failure      - Empty string
; Author ........: Gary Frost (gafrost), Holger Kotsch
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Use Opt("GUIDataSeparatorChar", param) to change the separator char used
;                  If $hItem is 0 then an attempt to use current selected is used
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetTree($hWnd, $hItem = 0)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If $hItem = 0 Then
		$hItem = 0x00000000
	Else
		If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	EndIf
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $szPath = ""

	If $hItem = 0x00000000 Then $hItem = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_CARET, 0, 0, "wparam", "handle", "handle")
	If $hItem <> 0x00000000 Then
		$szPath = _GUICtrlTreeView_GetText($hWnd, $hItem)

		Local $hParent, $sSeparator = Opt("GUIDataSeparatorChar")
		Do; Get now the parent item handle if there is one
			$hParent = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_PARENT, $hItem, 0, "wparam", "handle", "handle")
			If $hParent <> 0x00000000 Then $szPath = _GUICtrlTreeView_GetText($hWnd, $hParent) & $sSeparator & $szPath
			$hItem = $hParent
		Until $hItem = 0x00000000
	EndIf

	Return $szPath
EndFunc   ;==>_GUICtrlTreeView_GetTree

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetUnicodeFormat
; Description ...: Retrieves the Unicode character format flag
; Syntax.........: _GUICtrlTreeView_GetUnicodeFormat($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: True         - Control is using Unicode characters
;                  False        - Control is using ANSI characters
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_SetUnicodeFormat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetUnicodeFormat($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_GETUNICODEFORMAT) <> 0
EndFunc   ;==>_GUICtrlTreeView_GetUnicodeFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetVisible
; Description ...: Indicates whether the item is currently visible in the control image
; Syntax.........: _GUICtrlTreeView_GetVisible($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: True         - Item is visible in the control image
;                  False        - Item is not visible in the control image
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_EnsureVisible
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetVisible($hWnd, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tRect = DllStructCreate($tagRECT)
	DllStructSetData($tRect, "Left", $hItem)
	Local $iRet
	If _WinAPI_InProcess($hWnd, $__ghTVLastWnd) Then
		$iRet = _SendMessage($hWnd, $TVM_GETITEMRECT, True, $tRect, 0, "wparam", "struct*")
	Else
		Local $iRect = DllStructGetSize($tRect)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iRect, $tMemMap)
		_MemWrite($tMemMap, $tRect)
		$iRet = _SendMessage($hWnd, $TVM_GETITEMRECT, True, $pMemory, 0, "wparam", "ptr")
		_MemRead($tMemMap, $pMemory, $tRect, $iRect)
		_MemFree($tMemMap)
	EndIf
	If $iRet = 0 Then Return False ; item is child item, collapsed and not visible

	; item may not be collapsed or may be at the root level the above will give a rect even it isn't in the view
	; check to see if it is visible to the eye
	Local $iControlHeight = _WinAPI_GetWindowHeight($hWnd)
	If DllStructGetData($tRect, "Top") >= $iControlHeight Or _
			DllStructGetData($tRect, "Bottom") <= 0 Then
		Return False
	Else
		Return True
	EndIf
EndFunc   ;==>_GUICtrlTreeView_GetVisible

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_GetVisibleCount
; Description ...: Returns the number of items that can be fully visible in the control
; Syntax.........: _GUICtrlTreeView_GetVisibleCount($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Maximum number of items possibly visible in the control
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: The number of items that can be fully visible may be greater than the number of  items  in  the  control.  The
;                  control calculates this value by dividing the height of the client window by the height of an item.  Note that
;                  the return value is the number of items that can be fully visible.  If you can see all of 20 items and part of
;                  one more item, the return value is 20 not 21.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_GetVisibleCount($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_GETVISIBLECOUNT)
EndFunc   ;==>_GUICtrlTreeView_GetVisibleCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_HitTest
; Description ...: Returns information about the location of a point relative to the control
; Syntax.........: _GUICtrlTreeView_HitTest($hWnd, $iX, $iY)
; Parameters ....: $hWnd        - Handle to the control
;                  $iX          - X position, relative to the control, to test
;                  $iY          - Y position, relative to the control, to test
; Return values .: Success      - Value indicating the results of the hit test:
;                  |   1 - In the client area, but below the last item.
;                  |   2 - On the bitmap associated with an item
;                  |   4 - On the text associated with an item
;                  |   8 - In the indentation associated with an item
;                  |  16 - On the button associated with an item
;                  |  32 - In the area to the right of an item
;                  |  64 - On the state icon for a item that is in a user-defined state
;                  | 128 - Above the client area
;                  | 256 - Below the client area
;                  | 512 - To the left of the client area
;                  |1024 - To the right of the client area
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_HitTestItem, _GUICtrlTreeView_HitTestEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_HitTest($hWnd, $iX, $iY)
	Local $tHitTest = _GUICtrlTreeView_HitTestEx($hWnd, $iX, $iY)
	Local $iFlags = DllStructGetData($tHitTest, "Flags")
	Local $iRet = 0
	If BitAND($iFlags, $TVHT_NOWHERE) <> 0 Then $iRet = BitOR($iRet, 1)
	If BitAND($iFlags, $TVHT_ONITEMICON) <> 0 Then $iRet = BitOR($iRet, 2)
	If BitAND($iFlags, $TVHT_ONITEMLABEL) <> 0 Then $iRet = BitOR($iRet, 4)
	If BitAND($iFlags, $TVHT_ONITEMINDENT) <> 0 Then $iRet = BitOR($iRet, 8)
	If BitAND($iFlags, $TVHT_ONITEMBUTTON) <> 0 Then $iRet = BitOR($iRet, 16)
	If BitAND($iFlags, $TVHT_ONITEMRIGHT) <> 0 Then $iRet = BitOR($iRet, 32)
	If BitAND($iFlags, $TVHT_ONITEMSTATEICON) <> 0 Then $iRet = BitOR($iRet, 64)
	If BitAND($iFlags, $TVHT_ABOVE) <> 0 Then $iRet = BitOR($iRet, 128)
	If BitAND($iFlags, $TVHT_BELOW) <> 0 Then $iRet = BitOR($iRet, 256)
	If BitAND($iFlags, $TVHT_TORIGHT) <> 0 Then $iRet = BitOR($iRet, 512)
	If BitAND($iFlags, $TVHT_TOLEFT) <> 0 Then $iRet = BitOR($iRet, 1024)
	Return $iRet
EndFunc   ;==>_GUICtrlTreeView_HitTest

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_HitTestEx
; Description ...: Returns information about the location of a point relative to the control
; Syntax.........: _GUICtrlTreeView_HitTestEx($hWnd, $iX, $iY)
; Parameters ....: $hWnd        - Handle to the control
;                  $iX          - X position to test
;                  $iY          - Y position to test
; Return values .: Success      - $tagTVHITTESTINFO structure
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_HitTest, _GUICtrlTreeView_HitTestItem, $tagTVHITTESTINFO
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_HitTestEx($hWnd, $iX, $iY)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tHitTest = DllStructCreate($tagTVHITTESTINFO)
	DllStructSetData($tHitTest, "X", $iX)
	DllStructSetData($tHitTest, "Y", $iY)
	If _WinAPI_InProcess($hWnd, $__ghTVLastWnd) Then
		_SendMessage($hWnd, $TVM_HITTEST, 0, $tHitTest, 0, "wparam", "struct*")
	Else
		Local $iHitTest = DllStructGetSize($tHitTest)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iHitTest, $tMemMap)
		_MemWrite($tMemMap, $tHitTest)
		_SendMessage($hWnd, $TVM_HITTEST, 0, $pMemory, 0, "wparam", "ptr")
		_MemRead($tMemMap, $pMemory, $tHitTest, $iHitTest)
		_MemFree($tMemMap)
	EndIf
	Return $tHitTest
EndFunc   ;==>_GUICtrlTreeView_HitTestEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_HitTestItem
; Description ...: Returns the item at the specified coordinates
; Syntax.........: _GUICtrlTreeView_HitTestItem($hWnd, $iX, $iY)
; Parameters ....: $hWnd        - Handle to the control
;                  $iX          - X position to test
;                  $iY          - Y position to test
; Return values .: Success      - Handle to the item at the specified point or 0 if no item occupies the point
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_HitTest, _GUICtrlTreeView_HitTestEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_HitTestItem($hWnd, $iX, $iY)
	Local $tHitTest = _GUICtrlTreeView_HitTestEx($hWnd, $iX, $iY)
	Return DllStructGetData($tHitTest, "Item")
EndFunc   ;==>_GUICtrlTreeView_HitTestItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_Index
; Description ...: Retrieves the position of the item in the list
; Syntax.........: _GUICtrlTreeView_Index($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to item
; Return values .: Success      - Index position
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: If $hItem is a child item the index is the position under the parent
;                  If $hItem has no parent this function will get the index of that item
; Related .......: _GUICtrlTreeView_GetItemByIndex
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_Index($hWnd, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $iRet = -1
	Local $hParent = _GUICtrlTreeView_GetParentHandle($hWnd, $hItem)
	Local $hNext
	If $hParent <> 0x00000000 Then
		$hNext = _GUICtrlTreeView_GetFirstChild($hWnd, $hParent)
		While $hNext <> 0x00000000
			$iRet += 1
			If $hNext = $hItem Then ExitLoop
			$hNext = _GUICtrlTreeView_GetNextSibling($hWnd, $hNext)
		WEnd
	Else
		$hNext = _GUICtrlTreeView_GetFirstItem($hWnd)
		While $hNext <> 0x00000000
			$iRet += 1
			If $hNext = $hItem Then ExitLoop
			$hNext = _GUICtrlTreeView_GetNextSibling($hWnd, $hNext)
		WEnd
	EndIf
	If $hNext = 0x00000000 Then $iRet = -1
	Return $iRet
EndFunc   ;==>_GUICtrlTreeView_Index

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_InsertItem
; Description ...: Insert an item
; Syntax.........: _GUICtrlTreeView_InsertItem($hWnd, $sItem_Text[, $hItem_Parent = 0[, $hItem_After = 0[, $iImage = -1[, $iSelImage = -1]]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $sItem_Text  - Text of new item
;                  $hItem_Parent- parent item ID/handle/item
;                  $hItem_After - item ID/handle/flag to insert new item after
;                  $iImage      - Zero based index of the item's icon in the control's image list
;                  $iSelImage   - Zero based index of the item's icon in the control's image list
; Return values .: Success      - The new item handle
;                  Failure      - 0
; Author ........: Holger Kotsch
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_InsertItem($hWnd, $sItem_Text, $hItem_Parent = 0, $hItem_After = 0, $iImage = -1, $iSelImage = -1)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	Local $tTVI = DllStructCreate($tagTVINSERTSTRUCT)

	Local $iBuffer, $pBuffer
	If $sItem_Text <> -1 Then
		$iBuffer = StringLen($sItem_Text) + 1
		Local $tText
		Local $fUnicode = _GUICtrlTreeView_GetUnicodeFormat($hWnd)
		If $fUnicode Then
			$tText = DllStructCreate("wchar Buffer[" & $iBuffer & "]")
			$iBuffer *= 2
		Else
			$tText = DllStructCreate("char Buffer[" & $iBuffer & "]")
		EndIf
		DllStructSetData($tText, "Buffer", $sItem_Text)
		$pBuffer = DllStructGetPtr($tText)
	Else
		$iBuffer = 0
		$pBuffer = -1 ; LPSTR_TEXTCALLBACK
	EndIf

	Local $hItem_tmp
	If $hItem_Parent = 0 Then ; setting to root level
		$hItem_Parent = $TVI_ROOT
	ElseIf Not IsHWnd($hItem_Parent) Then ; control created by autoit create
		$hItem_tmp = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem_Parent)
		If $hItem_tmp Then $hItem_Parent = $hItem_tmp
	EndIf

	If $hItem_After = 0 Then ; using default
		$hItem_After = $TVI_LAST
	ElseIf ($hItem_After <> $TVI_ROOT And _
			$hItem_After <> $TVI_FIRST And _
			$hItem_After <> $TVI_LAST And _
			$hItem_After <> $TVI_SORT) Then ; not using flag
		If Not IsHWnd($hItem_After) Then
			$hItem_tmp = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem_After)
			If Not $hItem_tmp Then ; item not found or invalid flag used
				$hItem_After = $TVI_LAST
			Else ; setting handle
				$hItem_After = $hItem_tmp
			EndIf
		EndIf
	EndIf

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $hIcon
	Local $iMask = $TVIF_TEXT
	If $iImage >= 0 Then
		$iMask = BitOR($iMask, $TVIF_IMAGE)
		$iMask = BitOR($iMask, $TVIF_IMAGE)
		DllStructSetData($tTVI, "Image", $iImage)
	Else
		$hIcon = _GUICtrlTreeView_GetImageListIconHandle($hWnd, 0)
		If $hIcon <> 0x00000000 Then
			$iMask = BitOR($iMask, $TVIF_IMAGE)
			DllStructSetData($tTVI, "Image", 0)
			DllCall("user32.dll", "int", "DestroyIcon", "handle", $hIcon)
			; No @error test because results are unimportant.
		EndIf
	EndIf

	If $iSelImage >= 0 Then
		$iMask = BitOR($iMask, $TVIF_SELECTEDIMAGE)
		$iMask = BitOR($iMask, $TVIF_SELECTEDIMAGE)
		DllStructSetData($tTVI, "SelectedImage", $iSelImage)
	Else
		$hIcon = _GUICtrlTreeView_GetImageListIconHandle($hWnd, 1)
		If $hIcon <> 0x00000000 Then
			$iMask = BitOR($iMask, $TVIF_SELECTEDIMAGE)
			DllStructSetData($tTVI, "SelectedImage", 0)
			DllCall("user32.dll", "int", "DestroyIcon", "handle", $hIcon)
			; No @error test because results are unimportant.
		EndIf
	EndIf

	DllStructSetData($tTVI, "Parent", $hItem_Parent)
	DllStructSetData($tTVI, "InsertAfter", $hItem_After)
	DllStructSetData($tTVI, "Mask", $iMask)
	DllStructSetData($tTVI, "TextMax", $iBuffer)
	$iMask = BitOR($iMask, $TVIF_PARAM)
	DllStructSetData($tTVI, "Param", 0)


	Local $hItem
	If _WinAPI_InProcess($hWnd, $__ghTVLastWnd) Then
		DllStructSetData($tTVI, "Text", $pBuffer)
		$hItem = _SendMessage($hWnd, $TVM_INSERTITEMW, 0, $tTVI, 0, "wparam", "struct*", "handle")

	Else
		Local $iInsert = DllStructGetSize($tTVI)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iInsert + $iBuffer, $tMemMap)
		If $sItem_Text <> -1 Then
			Local $pText = $pMemory + $iInsert
			DllStructSetData($tTVI, "Text", $pText)
			_MemWrite($tMemMap, $tText, $pText, $iBuffer)
		Else
			DllStructSetData($tTVI, "Text", -1) ; LPSTR_TEXTCALLBACK
		EndIf
		_MemWrite($tMemMap, $tTVI, $pMemory, $iInsert)
		If $fUnicode Then
			$hItem = _SendMessage($hWnd, $TVM_INSERTITEMW, 0, $pMemory, 0, "wparam", "ptr", "handle")
		Else
			$hItem = _SendMessage($hWnd, $TVM_INSERTITEMA, 0, $pMemory, 0, "wparam", "ptr", "handle")
		EndIf
		_MemFree($tMemMap)
	EndIf
	Return $hItem
EndFunc   ;==>_GUICtrlTreeView_InsertItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_IsFirstItem
; Description ...: Indicates whether the tree item is very first
; Syntax.........: _GUICtrlTreeView_IsFirstItem($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: True         - Item is the first item
;                  False        - Item is not the first item
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_IsFirstItem($hWnd, $hItem)
	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _GUICtrlTreeView_GetFirstItem($hWnd) = $hItem
EndFunc   ;==>_GUICtrlTreeView_IsFirstItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_IsParent
; Description ...: Indicates whether one item is the parent of another item
; Syntax.........: _GUICtrlTreeView_IsParent($hWnd, $hParent, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hParent     - Handle to parent item
;                  $hItem       - Handle to the item to test
; Return values .: True         - $hParent is a parent of $hItem
;                  False        - $hParent is not a parent of $hItem
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_IsParent($hWnd, $hParent, $hItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hParent) Then $hParent = _GUICtrlTreeView_GetItemHandle($hWnd, $hParent)
	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _GUICtrlTreeView_GetParentHandle($hWnd, $hItem) = $hParent
EndFunc   ;==>_GUICtrlTreeView_IsParent

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_Level
; Description ...: Indicates the level of indentation of a item
; Syntax.........: _GUICtrlTreeView_Level($hWnd, $hItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
; Return values .: Success      - Zero based item indentation level
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_Level($hWnd, $hItem)
	Local $iRet = 0
	Local $hNext = _GUICtrlTreeView_GetParentHandle($hWnd, $hItem)
	While $hNext <> 0x00000000
		$iRet += 1
		$hNext = _GUICtrlTreeView_GetParentHandle($hWnd, $hNext)
	WEnd
	Return $iRet
EndFunc   ;==>_GUICtrlTreeView_Level

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlTreeView_MapAccIDToItem
; Description ...: Maps an accessibility ID to an HTREEITEM
; Syntax.........: _GUICtrlTreeView_MapAccIDToItem($hWnd, $iID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iID         - Accessibility ID
; Return values .: Success      - The HTREEITEM that the specified accessibility ID is mapped to
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Minimum OS Windows XP.
;+
;                  When you add an item to a control an HTREEITEM returns, which uniquely identifies the item.
; Related .......: _GUICtrlTreeView_MapItemToAccID
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlTreeView_MapAccIDToItem($hWnd, $iID)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_MAPACCIDTOHTREEITEM, $iID, 0, 0, "wparam", "lparam", "handle")
EndFunc   ;==>_GUICtrlTreeView_MapAccIDToItem

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlTreeView_MapItemToAccID
; Description ...: Maps an HTREEITEM to an accessibility ID
; Syntax.........: _GUICtrlTreeView_MapItemToAccID($hWnd, $hTreeItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $hTreeItem   - HTREEITEM that is mapped to an accessibility ID
; Return values .: Success      - Returns an accessibility ID
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Minimum OS Windows XP.
;+
;                  When you add an item to a control an HTREEITEM returns, which uniquely identifies the item.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlTreeView_MapItemToAccID($hWnd, $hTreeItem)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hTreeItem) Then $hTreeItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hTreeItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_MAPHTREEITEMTOACCID, $hTreeItem, 0, 0, "handle")
EndFunc   ;==>_GUICtrlTreeView_MapItemToAccID

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlTreeView_ReverseColorOrder
; Description ...: Convert Hex RGB or BGR Color to Hex RGB or BGR Color
; Syntax.........: __GUICtrlTreeView_ReverseColorOrder($vColor)
; Parameters ....: $vColor      - Hex Color
; Return values .: Success      - Hex RGB or BGR Color
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GUICtrlTreeView_ReverseColorOrder($vColor)
	Local $tc = Hex(String($vColor), 6)
	Return '0x' & StringMid($tc, 5, 2) & StringMid($tc, 3, 2) & StringMid($tc, 1, 2)
EndFunc   ;==>__GUICtrlTreeView_ReverseColorOrder

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SelectItem
; Description ...: Selects the specified item, scrolls the item into view, or redraws the item
; Syntax.........: _GUICtrlTreeView_SelectItem($hWnd, $hItem[, $iFlag=0])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
;                  $iFlag       - Action flag:
;                  |$TVGN_CARET        - Sets the selection to the given item
;                  |$TVGN_DROPHILITE   - Redraws the given item in the style used to indicate the target of a drag/drop operation
;                  |$TVGN_FIRSTVISIBLE - Scrolls the tree view vertically so that the given item is the first visible item
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SelectItem($hWnd, $hItem, $iFlag = 0)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) And $hItem <> 0 Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	If $iFlag = 0 Then $iFlag = $TVGN_CARET
	Return _SendMessage($hWnd, $TVM_SELECTITEM, $iFlag, $hItem, 0, "wparam", "handle") <> 0
EndFunc   ;==>_GUICtrlTreeView_SelectItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SelectItemByIndex
; Description ...: Selects the item based on it's index in the parent list
; Syntax.........: _GUICtrlTreeView_SelectItemByIndex($hWnd, $hItem, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
;                  $iIndex      - Zero based index of item in the parent list
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SelectItemByIndex($hWnd, $hItem, $iIndex)
	Return _GUICtrlTreeView_SelectItem($hWnd, _GUICtrlTreeView_GetItemByIndex($hWnd, $hItem, $iIndex))
EndFunc   ;==>_GUICtrlTreeView_SelectItemByIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetBkColor
; Description ...: Sets the back color
; Syntax.........: _GUICtrlTreeView_SetBkColor($hWnd, $vRGBColor)
; Parameters ....: $hWnd        - Handle to the control
;                  $vRGBColor   - New hex RGB Color
; Return values .: Success      - Previous Hex RGB color
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetBkColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetBkColor($hWnd, $vRGBColor)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return __GUICtrlTreeView_ReverseColorOrder(_SendMessage($hWnd, $TVM_SETBKCOLOR, 0, Int(__GUICtrlTreeView_ReverseColorOrder($vRGBColor))))
EndFunc   ;==>_GUICtrlTreeView_SetBkColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetBold
; Description ...: Sets whether the item is drawn using a bold sytle
; Syntax.........: _GUICtrlTreeView_SetBold($hWnd, $hItem[, $fFlag = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
;                  $fFlag       - True if item is drawn bold, otherwise False
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetBold
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetBold($hWnd, $hItem, $fFlag = True)
	Return _GUICtrlTreeView_SetState($hWnd, $hItem, $TVIS_BOLD, $fFlag)
EndFunc   ;==>_GUICtrlTreeView_SetBold

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetChecked
; Description ...: Sets whether a item has it's checkbox checked or not
; Syntax.........: _GUICtrlTreeView_SetChecked($hWnd, $hItem[, $fCheck = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
;                  $fCheck      - Value to set checked state to:
;                  | True       - Checked
;                  |False       - Not checked
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetChecked
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetChecked($hWnd, $hItem, $fCheck = True)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tItem = DllStructCreate($tagTVITEMEX)
	DllStructSetData($tItem, "Mask", $TVIF_STATE)
	DllStructSetData($tItem, "hItem", $hItem)
	If ($fCheck) Then
		DllStructSetData($tItem, "State", 0x2000)
	Else
		DllStructSetData($tItem, "State", 0x1000)
	EndIf
	DllStructSetData($tItem, "StateMask", 0xf000)
	Return __GUICtrlTreeView_SetItem($hWnd, $tItem)
EndFunc   ;==>_GUICtrlTreeView_SetChecked

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetCheckedByIndex
; Description ...: Sets whether an item has it's checkbox checked or not by it's index
; Syntax.........: _GUICtrlTreeView_SetCheckedByIndex($hWnd, $hItem, $iIndex[, $fCheck = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
;                  $iIndex      - Zero based index into $hItem list of items
;                  $fCheck      - Value to set checked state to:
;                  | True       - Checked
;                  |False       - Not checked
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetCheckedByIndex($hWnd, $hItem, $iIndex, $fCheck = True)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $hChild = _GUICtrlTreeView_GetItemByIndex($hWnd, $hItem, $iIndex)
	Return _GUICtrlTreeView_SetChecked($hWnd, $hChild, $fCheck)
EndFunc   ;==>_GUICtrlTreeView_SetCheckedByIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetChildren
; Description ...: Sets whether the item children flag
; Syntax.........: _GUICtrlTreeView_SetChildren($hWnd, $hItem[, $fFlag = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
;                  $fFlag       - Flag setting:
;                  | True - Item children flag is set
;                  |False - Item children flag is cleared
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetChildren
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetChildren($hWnd, $hItem, $fFlag = True)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tItem = DllStructCreate($tagTVITEMEX)
	DllStructSetData($tItem, "Mask", BitOR($TVIF_HANDLE, $TVIF_CHILDREN))
	DllStructSetData($tItem, "hItem", $hItem)
	DllStructSetData($tItem, "Children", $fFlag)
	Return __GUICtrlTreeView_SetItem($hWnd, $tItem)
EndFunc   ;==>_GUICtrlTreeView_SetChildren

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetCut
; Description ...: Sets whether the item is drawn as if selected as part of a cut and paste operation
; Syntax.........: _GUICtrlTreeView_SetCut($hWnd, $hItem[, $fFlag = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
;                  $fFlag       - Flag setting:
;                  | True - Item is cut
;                  |False - Item is not
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetCut
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetCut($hWnd, $hItem, $fFlag = True)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _GUICtrlTreeView_SetState($hWnd, $hItem, $TVIS_CUT, $fFlag)
EndFunc   ;==>_GUICtrlTreeView_SetCut

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetDropTarget
; Description ...: Sets whether the item is drawn as a drag and drop target
; Syntax.........: _GUICtrlTreeView_SetDropTarget($hWnd, $hItem[, $fFlag = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
;                  $fFlag       - Flag setting:
;                  | True - Item is drawn as a drag and drop target
;                  |False - Item is not
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetDropTarget
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetDropTarget($hWnd, $hItem, $fFlag = True)
	If $fFlag Then
		Return _GUICtrlTreeView_SelectItem($hWnd, $hItem, $TVGN_DROPHILITE)
	ElseIf _GUICtrlTreeView_GetDropTarget($hWnd, $hItem) Then
		Return _GUICtrlTreeView_SelectItem($hWnd, 0)
	EndIf
	Return False
EndFunc   ;==>_GUICtrlTreeView_SetDropTarget

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetFocused
; Description ...: Sets whether the item appears to have focus
; Syntax.........: _GUICtrlTreeView_SetFocused($hWnd, $hItem[, $fFlag = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
;                  $fFlag       - Flag setting:
;                  | True - Item appears to have focus
;                  |False - Item does not
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetFocused
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetFocused($hWnd, $hItem, $fFlag = True)
	Return _GUICtrlTreeView_SetState($hWnd, $hItem, $TVIS_FOCUSED, $fFlag)
EndFunc   ;==>_GUICtrlTreeView_SetFocused

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetHeight
; Description ...: Sets the height of the each item
; Syntax.........: _GUICtrlTreeView_SetHeight($hWnd, $iHeight)
; Parameters ....: $hWnd        - Handle to the control
;                  $iHeight     - New height of every item in pixels.  Heights less than 1 will be set to 1.  If not even and the
;                  +control does not have the DllStructGetData($TVS_NONEVENHEIGHT style this value will be rounded down to the nearest even value, "")
;                  +If -1, the control will revert to using its default item height.
; Return values .: Success      - Previous height of the items, in pixels
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetHeight
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetHeight($hWnd, $iHeight)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_SETITEMHEIGHT, $iHeight)
EndFunc   ;==>_GUICtrlTreeView_SetHeight

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetIcon
; Description ...: Set an item icon
; Syntax.........: _GUICtrlTreeView_SetIcon($hWnd[, $hItem = 0[, $sIconFile =""[, $iIconID = 0[, $iImageMode = 6]]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - item ID/handle
;                  $sIconFile   - The file to extract the icon of
;                  $iIconID     - The iconID to extract of the file
;                  $iImageMode  - 2=normal image / 4=seletected image to set
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Holger Kotsch
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetIcon($hWnd, $hItem = 0, $sIconFile = "", $iIconID = 0, $iImageMode = 6)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If $hItem = 0 Then $hItem = 0x00000000

	If $hItem <> 0x00000000 And Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If $hItem = 0x00000000 Or $sIconFile = "" Then Return SetError(1, 1, False)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tTVITEM = DllStructCreate($tagTVITEMEX)

	Local $tIcon = DllStructCreate("handle")
	Local $i_count = DllCall("shell32.dll", "uint", "ExtractIconExW", "wstr", $sIconFile, "int", $iIconID, _
			"handle", 0, "struct*", $tIcon, "uint", 1)
	If @error Then Return SetError(@error, @extended, 0)
	If $i_count[0] = 0 Then Return 0

	Local $hImageList = _SendMessage($hWnd, $TVM_GETIMAGELIST, 0, 0, 0, "wparam", "lparam", "handle")
	If $hImageList = 0x00000000 Then
		$hImageList = DllCall("comctl32.dll", "handle", "ImageList_Create", "int", 16, "int", 16, "uint", 0x0021, "int", 0, "int", 1)
		If @error Then Return SetError(@error, @extended, 0)
		$hImageList = $hImageList[0]
		If $hImageList = 0 Then Return SetError(1, 1, False)

		_SendMessage($hWnd, $TVM_SETIMAGELIST, 0, $hImageList, 0, "wparam", "handle")
	EndIf

	Local $hIcon = DllStructGetData($tIcon, 1)
	Local $i_icon = DllCall("comctl32.dll", "int", "ImageList_AddIcon", "handle", $hImageList, "handle", $hIcon)
	$i_icon = $i_icon[0]
	If @error Then
		Local $iError = @error, $iExtended = @extended
		DllCall("user32.dll", "int", "DestroyIcon", "handle", $hIcon)
		; No @error test because results are unimportant.
		Return SetError($iError, $iExtended, 0)
	EndIf

	DllCall("user32.dll", "int", "DestroyIcon", "handle", $hIcon)
	; No @error test because results are unimportant.

	Local $iMask = BitOR($TVIF_IMAGE, $TVIF_SELECTEDIMAGE)

	If BitAND($iImageMode, 2) Then
		DllStructSetData($tTVITEM, "Image", $i_icon)
		If Not BitAND($iImageMode, 4) Then $iMask = $TVIF_IMAGE
	EndIf

	If BitAND($iImageMode, 4) Then
		DllStructSetData($tTVITEM, "SelectedImage", $i_icon)
		If Not BitAND($iImageMode, 2) Then
			$iMask = $TVIF_SELECTEDIMAGE
		Else
			$iMask = BitOR($TVIF_IMAGE, $TVIF_SELECTEDIMAGE)
		EndIf
	EndIf

	DllStructSetData($tTVITEM, "Mask", $iMask)
	DllStructSetData($tTVITEM, "hItem", $hItem)

	Return __GUICtrlTreeView_SetItem($hWnd, $tTVITEM)
EndFunc   ;==>_GUICtrlTreeView_SetIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetImageIndex
; Description ...: Sets the index into image list for which image is displayed when a item is in its normal state
; Syntax.........: _GUICtrlTreeView_SetImageIndex($hWnd, $hItem, $iIndex)
; Parameters ....: $hWnd       - Handle to the control
;                  $hItem      - Handle to the item
;                  $iIndex     - Image list index
; Return values .: Success     - True
;                  Failure     - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetImageIndex
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetImageIndex($hWnd, $hItem, $iIndex)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tItem = DllStructCreate($tagTVITEMEX)
	DllStructSetData($tItem, "Mask", BitOR($TVIF_HANDLE, $TVIF_IMAGE))
	DllStructSetData($tItem, "hItem", $hItem)
	DllStructSetData($tItem, "Image", $iIndex)
	Return __GUICtrlTreeView_SetItem($hWnd, $tItem)
EndFunc   ;==>_GUICtrlTreeView_SetImageIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetIndent
; Description ...: Sets the width of indentation for a tree-view control and redraws the control to reflect the new width
; Syntax.........: _GUICtrlTreeView_SetIndent($hWnd, $iIndent)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndent     - Width, in pixels, of the indentation.
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If the $iIndent parameter is less than the system-defined minimum width, the new width is set to the
;                  system-defined minimum.
; Related .......: _GUICtrlTreeView_GetIndent
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetIndent($hWnd, $iIndent)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $TVM_SETINDENT, $iIndent)
EndFunc   ;==>_GUICtrlTreeView_SetIndent

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetInsertMark
; Description ...: Sets the insertion mark
; Syntax.........: _GUICtrlTreeView_SetInsertMark($hWnd, $hItem[, $fAfter = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Specifies at which item the insertion mark will be placed.  If this is 0, the insertion mark is
;                  +removed.
;                  $fAfter      - Specifies if the insertion mark is placed before or after  the  item.  If  this  is  True,  the
;                  +insertion mark will be placed after the item.  If this is False, the insertion mark will be placed before the
;                  +item.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetInsertMark($hWnd, $hItem, $fAfter = True)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) And $hItem <> 0 Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_SETINSERTMARK, $fAfter, $hItem, 0, "wparam", "handle") <> 0
EndFunc   ;==>_GUICtrlTreeView_SetInsertMark

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetInsertMarkColor
; Description ...: Sets the color used to draw the insertion mark
; Syntax.........: _GUICtrlTreeView_SetInsertMarkColor($hWnd, $iColor)
; Parameters ....: $hWnd        - Handle to the control
;                  $iColor      - Insertion mark color
; Return values .: Success      - Previous insertion mark color
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetInsertMarkColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetInsertMarkColor($hWnd, $iColor)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_SETINSERTMARKCOLOR, 0, $iColor)
EndFunc   ;==>_GUICtrlTreeView_SetInsertMarkColor

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlTreeView_SetItem
; Description ...: Sets some or all of a items attributes
; Syntax.........: __GUICtrlTreeView_SetItem($hWnd, ByRef $tItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $tItem       - $tagTVITEMEX structure that contains the new item attributes
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: This function is used internally and should not normally be called by the end user
; Related .......: __GUICtrlTreeView_GetItem
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GUICtrlTreeView_SetItem($hWnd, ByRef $tItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $fUnicode = _GUICtrlTreeView_GetUnicodeFormat($hWnd)

	Local $iRet
	If _WinAPI_InProcess($hWnd, $__ghTVLastWnd) Then
		$iRet = _SendMessage($hWnd, $TVM_SETITEMW, 0, $tItem, 0, "wparam", "struct*")
	Else
		Local $iItem = DllStructGetSize($tItem)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iItem, $tMemMap)
		_MemWrite($tMemMap, $tItem)
		If $fUnicode Then
			$iRet = _SendMessage($hWnd, $TVM_SETITEMW, 0, $pMemory, 0, "wparam", "ptr")
		Else
			$iRet = _SendMessage($hWnd, $TVM_SETITEMA, 0, $pMemory, 0, "wparam", "ptr")
		EndIf
		_MemFree($tMemMap)
	EndIf
	Return $iRet <> 0
EndFunc   ;==>__GUICtrlTreeView_SetItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetItemHeight
; Description ...: Sets the height of an individual item
; Syntax.........: _GUICtrlTreeView_SetItemHeight($hWnd, $hItem, $iIntegral)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
;                  $iIntegral   - Height of the item.  This height is in increments of the standard item height. By default, each
;                  +item gets one increment of item height. Setting this field to 2 will give the item twice the standard height;
;                  +setting this field to 3 will give the item three times the standard height; and so on.  The control does  not
;                  +draw in this extra area.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetItemHeight($hWnd, $hItem, $iIntegral)
	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)

	_GUICtrlTreeView_BeginUpdate($hWnd)
	Local $tItem = DllStructCreate($tagTVITEMEX)
	DllStructSetData($tItem, "Mask", BitOR($TVIF_HANDLE, $TVIF_INTEGRAL))
	DllStructSetData($tItem, "hItem", $hItem)
	DllStructSetData($tItem, "Integral", $iIntegral)
	Local $fResult = __GUICtrlTreeView_SetItem($hWnd, $tItem)
	_GUICtrlTreeView_EndUpdate($hWnd)
	Return $fResult
EndFunc   ;==>_GUICtrlTreeView_SetItemHeight

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetItemParam
; Description ...: Sets the value specific to the item
; Syntax.........: _GUICtrlTreeView_SetItemParam($hWnd, $hItem, $iParam)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
;                  $iParam      - A value to associate with the item
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetItemParam
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetItemParam($hWnd, $hItem, $iParam)
	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)

	Local $tItem = DllStructCreate($tagTVITEMEX)
	DllStructSetData($tItem, "Mask", BitOR($TVIF_HANDLE, $TVIF_PARAM))
	DllStructSetData($tItem, "hItem", $hItem)
	DllStructSetData($tItem, "Param", $iParam)
	Local $fResult = __GUICtrlTreeView_SetItem($hWnd, $tItem)
	Return $fResult
EndFunc   ;==>_GUICtrlTreeView_SetItemParam

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetLineColor
; Description ...: Sets the line color
; Syntax.........: _GUICtrlTreeView_SetLineColor($hWnd, $vRGBColor)
; Parameters ....: $hWnd        - Handle to the control
;                  $vRGBColor   - New Hex RGB line color
; Return values .: Success      - Previous Hex RGB line color
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetLineColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetLineColor($hWnd, $vRGBColor)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return __GUICtrlTreeView_ReverseColorOrder(_SendMessage($hWnd, $TVM_SETLINECOLOR, 0, Int(__GUICtrlTreeView_ReverseColorOrder($vRGBColor))))
EndFunc   ;==>_GUICtrlTreeView_SetLineColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetNormalImageList
; Description ...: Sets the normal image list for the control
; Syntax.........: _GUICtrlTreeView_SetNormalImageList($hWnd, $hImageList)
; Parameters ....: $hWnd        - Handle to the control
;                  $hImageList  - Handle to the image list.  If 0, all images are removed
; Return values .: Success      - The handle to the previous image list
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetNormalImageList
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetNormalImageList($hWnd, $hImageList)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_SETIMAGELIST, $TVSIL_NORMAL, $hImageList, 0, "wparam", "handle", "handle")
EndFunc   ;==>_GUICtrlTreeView_SetNormalImageList

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlTreeView_SetOverlayImageIndex
; Description ...: Sets the index into image list for the state image
; Syntax.........: _GUICtrlTreeView_SetOverlayImageIndex($hWnd, $hItem, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
;                  $iIndex      - Image list index
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetOverlayImageIndex
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlTreeView_SetOverlayImageIndex($hWnd, $hItem, $iIndex)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tItem = DllStructCreate($tagTVITEMEX)
	DllStructSetData($tItem, "Mask", BitOR($TVIF_HANDLE, $TVIF_STATE))
	DllStructSetData($tItem, "hItem", $hItem)
	DllStructSetData($tItem, "State", BitShift($iIndex, -8))
	DllStructSetData($tItem, "StateMask", $TVIS_OVERLAYMASK)
	Return __GUICtrlTreeView_SetItem($hWnd, $tItem)
EndFunc   ;==>_GUICtrlTreeView_SetOverlayImageIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetScrollTime
; Description ...: Sets the maximum scroll time
; Syntax.........: _GUICtrlTreeView_SetScrollTime($hWnd, $iTime)
; Parameters ....: $hWnd        - Handle to the control
;                  $iTime       - New maximum scroll time, in milliseconds
; Return values .: Success      - Previous scroll time, in milliseconds
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: The maximum scroll time is the longest amount of time that a scroll operation can  take.   Scrolling  will  be
;                  adjusted so that the scroll will take place within the maximum scroll time.  A scroll operation may take  less
;                  time than the maximum.
; Related .......: _GUICtrlTreeView_GetScrollTime
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetScrollTime($hWnd, $iTime)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_SETSCROLLTIME, $iTime)
EndFunc   ;==>_GUICtrlTreeView_SetScrollTime

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetSelected
; Description ...: Sets whether the item appears in the selected state
; Syntax.........: _GUICtrlTreeView_SetSelected($hWnd, $hItem[, $fFlag = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
;                  $fFlag       - True if item is to be selected, otherwise False
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetSelected
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetSelected($hWnd, $hItem, $fFlag = True)
	Return _GUICtrlTreeView_SetState($hWnd, $hItem, $TVIS_SELECTED, $fFlag)
EndFunc   ;==>_GUICtrlTreeView_SetSelected

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetSelectedImageIndex
; Description ...: Sets the selected image index
; Syntax.........: _GUICtrlTreeView_SetSelectedImageIndex($hWnd, $hItem, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
;                  $iIndex      - Image list index
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetSelectedImageIndex
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetSelectedImageIndex($hWnd, $hItem, $iIndex)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tItem = DllStructCreate($tagTVITEMEX)
	DllStructSetData($tItem, "Mask", BitOR($TVIF_HANDLE, $TVIF_SELECTEDIMAGE))
	DllStructSetData($tItem, "hItem", $hItem)
	DllStructSetData($tItem, "SelectedImage", $iIndex)
	Return __GUICtrlTreeView_SetItem($hWnd, $tItem)
EndFunc   ;==>_GUICtrlTreeView_SetSelectedImageIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetState
; Description ...: Set the state of the specified item
; Syntax.........: _GUICtrlTreeView_SetState($hWnd, $hItem[, $iState = 0[, $iSetState = 0]])
; Parameters ....: $hWnd                - Handle to the control
;                  $hItem               - item ID/handle to set the icon
;                  $iState              - The new item state, can be one or more of the following:
;                  |$TVIS_SELECTED      - Set item selected
;                  |$TVIS_CUT           - Set item as part of a cut-and-paste operation
;                  |$TVIS_DROPHILITED   - Set item as a drag-and-drop target
;                  |$TVIS_BOLD          - Set item as bold
;                  |$TVIS_EXPANDED      - Expand item
;                  |$TVIS_EXPANDEDONCE  - Set item's list of child items has been expanded at least once
;                  |$TVIS_EXPANDPARTIAL - Set item as partially expanded
;                  $iSetState - True if item state is to be set, False remove item state
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Holger Kotsch
; Modified.......: Gary Frost (gafrost)
; Remarks .......: State values can BitOr'ed together as for example BitOr($TVIS_SELECTED, $TVIS_BOLD).
; Related .......: _GUICtrlTreeView_GetState
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetState($hWnd, $hItem, $iState = 0, $iSetState = True)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If $hItem = 0x00000000 Or ($iState = 0 And $iSetState = False) Then Return False

	Local $tTVITEM = DllStructCreate($tagTVITEMEX)
	If @error Then Return SetError(1, 1, 0)
	DllStructSetData($tTVITEM, "Mask", $TVIF_STATE)
	DllStructSetData($tTVITEM, "hItem", $hItem)
	If $iSetState Then
		DllStructSetData($tTVITEM, "State", $iState)
	Else
		DllStructSetData($tTVITEM, "State", BitAND($iSetState, $iState))
	EndIf
	DllStructSetData($tTVITEM, "StateMask", $iState)
	If $iSetState Then DllStructSetData($tTVITEM, "StateMask", BitOR($iSetState, $iState))
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	Return __GUICtrlTreeView_SetItem($hWnd, $tTVITEM)
EndFunc   ;==>_GUICtrlTreeView_SetState

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetStateImageIndex
; Description ...: Sets the index into image list for the state image
; Syntax.........: _GUICtrlTreeView_SetStateImageIndex($hWnd, $hItem, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - Handle to the item
;                  $iIndex      - Image list index
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: This is a 1 based index list
; Related .......: _GUICtrlTreeView_GetStateImageIndex
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetStateImageIndex($hWnd, $hItem, $iIndex)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	If $iIndex < 0 Then
		; Invalid index for State Image" & @LF & "State Image List is One-based list
		Return SetError(1, 0, False)
	EndIf

	Local $tItem = DllStructCreate($tagTVITEMEX)
	DllStructSetData($tItem, "Mask", $TVIF_STATE)
	DllStructSetData($tItem, "hItem", $hItem)
	DllStructSetData($tItem, "State", BitShift($iIndex, -12))
	DllStructSetData($tItem, "StateMask", $TVIS_STATEIMAGEMASK)
	Return __GUICtrlTreeView_SetItem($hWnd, $tItem)
EndFunc   ;==>_GUICtrlTreeView_SetStateImageIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetStateImageList
; Description ...: Sets the state image list for the control
; Syntax.........: _GUICtrlTreeView_SetStateImageList($hWnd, $hImageList)
; Parameters ....: $hWnd        - Handle to the control
;                  $hImageList  - Handle to the image list.  If 0, all images are removed
; Return values .: Success      - The handle to the previous image list
;                  Failure      - 0
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: This is a 1 based index list
; Related .......: _GUICtrlTreeView_GetStateImageList
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetStateImageList($hWnd, $hImageList)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	; haven't figured out why but the state image list appears to use a 1 based index
	; add and icon
	_GUIImageList_AddIcon($hImageList, "shell32.dll", 0)
	Local $iCount = _GUIImageList_GetImageCount($hImageList)
	; shift it to the zero index, won't be used
	For $x = $iCount - 1 To 1 Step -1
		_GUIImageList_Swap($hImageList, $x, $x - 1)
	Next
	Return _SendMessage($hWnd, $TVM_SETIMAGELIST, $TVSIL_STATE, $hImageList, 0, "wparam", "handle", "handle")
EndFunc   ;==>_GUICtrlTreeView_SetStateImageList

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetText
; Description ...: Set the text of an item
; Syntax.........: _GUICtrlTreeView_SetText($hWnd[, $hItem = 0[, $sText = ""]])
; Parameters ....: $hWnd        - Handle to the control
;                  $hItem       - item ID/handle to set the icon
;                  $sText       - The new item text
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Holger Kotsch
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetText($hWnd, $hItem = 0, $sText = "")
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hItem) Then $hItem = _GUICtrlTreeView_GetItemHandle($hWnd, $hItem)
	If $hItem = 0x00000000 Or $sText = "" Then Return SetError(1, 1, 0)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tTVITEM = DllStructCreate($tagTVITEMEX)
	Local $iBuffer = StringLen($sText) + 1
	Local $tBuffer
	Local $fUnicode = _GUICtrlTreeView_GetUnicodeFormat($hWnd)
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Buffer[" & $iBuffer & "]")
		$iBuffer *= 2
	Else
		$tBuffer = DllStructCreate("char Buffer[" & $iBuffer & "]")
	EndIf
	DllStructSetData($tBuffer, "Buffer", $sText)
	DllStructSetData($tTVITEM, "Mask", BitOR($TVIF_HANDLE, $TVIF_TEXT))
	DllStructSetData($tTVITEM, "hItem", $hItem)
	DllStructSetData($tTVITEM, "TextMax", $iBuffer)
	Local $fResult
	If _WinAPI_InProcess($hWnd, $__ghTVLastWnd) Then
		DllStructSetData($tTVITEM, "Text", DllStructGetPtr($tBuffer))
		$fResult = _SendMessage($hWnd, $TVM_SETITEMW, 0, $tTVITEM, 0, "wparam", "struct*")
	Else
		Local $iItem = DllStructGetSize($tTVITEM)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iItem + $iBuffer, $tMemMap)
		Local $pText = $pMemory + $iItem
		DllStructSetData($tTVITEM, "Text", $pText)
		_MemWrite($tMemMap, $tTVITEM, $pMemory, $iItem)
		_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
		If $fUnicode Then
			$fResult = _SendMessage($hWnd, $TVM_SETITEMW, 0, $pMemory, 0, "wparam", "ptr")
		Else
			$fResult = _SendMessage($hWnd, $TVM_SETITEMA, 0, $pMemory, 0, "wparam", "ptr")
		EndIf
		_MemFree($tMemMap)
	EndIf

	Return $fResult <> 0
EndFunc   ;==>_GUICtrlTreeView_SetText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetTextColor
; Description ...: Sets the text color
; Syntax.........: _GUICtrlTreeView_SetTextColor($hWnd, $vRGBColor)
; Parameters ....: $hWnd        - Handle to the control
;                  $vRGBColor   - New Hex text color
; Return values .: Success      - Previous Hex RGB text color
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetTextColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetTextColor($hWnd, $vRGBColor)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return __GUICtrlTreeView_ReverseColorOrder(_SendMessage($hWnd, $TVM_SETTEXTCOLOR, 0, Int(__GUICtrlTreeView_ReverseColorOrder($vRGBColor))))
EndFunc   ;==>_GUICtrlTreeView_SetTextColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetToolTips
; Description ...: Sets the handle to the child ToolTip control
; Syntax.........: _GUICtrlTreeView_SetToolTips($hWnd, $hToolTip)
; Parameters ....: $hWnd        - Handle to the control
;                  $hToolTip    - Handle to a ToolTip control
; Return values .: Success      - Handle to the previous ToolTip control, or 0 if the control is not using ToolTips
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: When created, controls automatically create a ToolTip control.  To cause a control not to use ToolTips, create
;                  the control with the DllStructGetData($TVS_NOTOOLTIPS style, "")
; Related .......: _GUICtrlTreeView_GetToolTips
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetToolTips($hWnd, $hToolTip)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_SETTOOLTIPS, $hToolTip, 0, 0, "wparam", "int", "hwnd")
EndFunc   ;==>_GUICtrlTreeView_SetToolTips

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_SetUnicodeFormat
; Description ...: Sets the Unicode character format flag
; Syntax.........: _GUICtrlTreeView_SetUnicodeFormat($hWnd[, $iFormat = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $iFormat     - Determines the character set that is used by the control.
;                  |True  - The control will use Unicode characters
;                  |False - The control will use ANSI characters.
; Return values .: Success      - Previous character format flag setting
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTreeView_GetUnicodeFormat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_SetUnicodeFormat($hWnd, $iFormat = True)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TVM_SETUNICODEFORMAT, $iFormat)
EndFunc   ;==>_GUICtrlTreeView_SetUnicodeFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTreeView_Sort
; Description ...: Sorts the items
; Syntax.........: _GUICtrlTreeView_Sort($hWnd)
; Parameters ....: $hWnd  - Handle to the control
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTreeView_Sort($hWnd)
	If $Debug_TV Then __UDF_ValidateClassName($hWnd, $__TREEVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $hItem, $a_tree
	For $i = 0 To _GUICtrlTreeView_GetCount($hWnd)
		If $i == 0 Then
			$hItem = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_CHILD, $TVI_ROOT, 0, "wparam", "handle", "handle")
		Else
			$hItem = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_NEXT, $hItem, 0, "wparam", "handle", "handle")
		EndIf
		If IsArray($a_tree) Then
			ReDim $a_tree[UBound($a_tree) + 1]
		Else
			Dim $a_tree[1]
		EndIf
		$a_tree[UBound($a_tree) - 1] = $hItem
	Next
	If IsArray($a_tree) Then
		Local $hChild, $i_Recursive = 1
		For $i = 0 To UBound($a_tree) - 1
			_SendMessage($hWnd, $TVM_SORTCHILDREN, $i_Recursive, $a_tree[$i], 0, "wparam", "handle") ; sort the items in root
			Do ; sort all the children
				$hChild = _SendMessage($hWnd, $TVM_GETNEXTITEM, $TVGN_CHILD, $hItem, 0, "wparam", "handle", "handle")
				If $hChild > 0 Then
					_SendMessage($hWnd, $TVM_SORTCHILDREN, $i_Recursive, $hChild, 0, "wparam", "handle")
				EndIf
				$hItem = $hChild
			Until $hItem = 0x00000000
		Next
	EndIf
EndFunc   ;==>_GUICtrlTreeView_Sort
