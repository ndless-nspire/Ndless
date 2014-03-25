#include-once

#include "TabConstants.au3"
#include "Memory.au3"
#include "WinAPI.au3"
#include "SendMessage.au3"
#include "UDFGlobalID.au3"

; #INDEX# =======================================================================================================================
; Title .........: Tab_Control
; AutoIt Version : 3.3.7.20++
; Language ......: English
; Description ...: Functions that assist with Tab control management.
;                  A tab control is analogous to the dividers in a notebook or the labels in a  file  cabinet.  By  using  a  tab
;                  control, an application can define multiple pages for the same area of a  window  or  dialog  box.  Each  page
;                  consists of a certain type of information or a group of controls that the application displays when  the  user
;                  selects the corresponding tab.
; Author(s) .....: Paul Campbell (PaulIA), Gary Frost (gafrost)
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $_ghTabLastWnd
Global $Debug_TAB = False
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__TABCONSTANT_ClassName = "SysTabControl32"
Global Const $__TABCONSTANT_WS_CLIPSIBLINGS = 0x04000000
Global Const $__TABCONSTANT_WM_NOTIFY = 0x004E
Global Const $__TABCONSTANT_DEFAULT_GUI_FONT = 17
; ===============================================================================================================================

; #OLD_FUNCTIONS#================================================================================================================
; Old Function/Name                      ; --> New Function/Name/Replacement(s)
;
; deprecated functions will no longer work
; _GUICtrlTabDeleteAllItems             ; --> _GUICtrlTab_DeleteAllItems
; _GUICtrlTabDeleteItem                 ; --> _GUICtrlTab_DeleteItem
; _GUICtrlTabDeselectAll                ; --> _GUICtrlTab_DeselectAll
; _GUICtrlTabGetCurFocus                ; --> _GUICtrlTab_GetCurFocus
; _GUICtrlTabGetCurSel                  ; --> _GUICtrlTab_GetCurSel
; _GUICtrlTabGetExtendedStyle           ; --> _GUICtrlTab_GetExtendedStyle
; _GUICtrlTabGetItemCount               ; --> _GUICtrlTab_GetItemCount
; _GUICtrlTabGetItemRECT                ; --> _GUICtrlTab_GetItemRect
; _GUICtrlTabGetRowCount                ; --> _GUICtrlTab_GetRowCount
; _GUICtrlTabGetUnicodeFormat           ; --> _GUICtrlTab_GetUnicodeFormat
; _GUICtrlTabHighlightItem              ; --> _GUICtrlTab_HighlightItem
; _GUICtrlTabSetCurFocus                ; --> _GUICtrlTab_SetCurFocus
; _GUICtrlTabSetCurSel                  ; --> _GUICtrlTab_SetCurSel
; _GUICtrlTabSetMinTabWidth             ; --> _GUICtrlTab_SetMinTabWidth
; _GUICtrlTabSetUnicodeFormat           ; --> _GUICtrlTab_SetUnicodeFormat
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_GUICtrlTab_ActivateTab
;_GUICtrlTab_ClickTab
;_GUICtrlTab_Create
;_GUICtrlTab_DeleteAllItems
;_GUICtrlTab_DeleteItem
;_GUICtrlTab_DeselectAll
;_GUICtrlTab_Destroy
;_GUICtrlTab_FindTab
;_GUICtrlTab_GetCurFocus
;_GUICtrlTab_GetCurSel
;_GUICtrlTab_GetDisplayRect
;_GUICtrlTab_GetDisplayRectEx
;_GUICtrlTab_GetExtendedStyle
;_GUICtrlTab_GetImageList
;_GUICtrlTab_GetItem
;_GUICtrlTab_GetItemCount
;_GUICtrlTab_GetItemImage
;_GUICtrlTab_GetItemParam
;_GUICtrlTab_GetItemRect
;_GUICtrlTab_GetItemRectEx
;_GUICtrlTab_GetItemState
;_GUICtrlTab_GetItemText
;_GUICtrlTab_GetRowCount
;_GUICtrlTab_GetToolTips
;_GUICtrlTab_GetUnicodeFormat
;_GUICtrlTab_HighlightItem
;_GUICtrlTab_HitTest
;_GUICtrlTab_InsertItem
;_GUICtrlTab_RemoveImage
;_GUICtrlTab_SetCurFocus
;_GUICtrlTab_SetCurSel
;_GUICtrlTab_SetExtendedStyle
;_GUICtrlTab_SetImageList
;_GUICtrlTab_SetItem
;_GUICtrlTab_SetItemImage
;_GUICtrlTab_SetItemParam
;_GUICtrlTab_SetItemSize
;_GUICtrlTab_SetItemState
;_GUICtrlTab_SetItemText
;_GUICtrlTab_SetMinTabWidth
;_GUICtrlTab_SetPadding
;_GUICtrlTab_SetToolTips
;_GUICtrlTab_SetUnicodeFormat
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;$tagTCITEM
;$tagTCHITTESTINFO
;__GUICtrlTab_AdjustRect
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagTCITEM
; Description ...: Specifies or receives the attributes of a tab item
; Fields ........: Mask      - Value that specifies which members to retrieve or set:
;                  |$TCIF_IMAGE      - The Image member is valid
;                  |$TCIF_PARAM      - The Param member is valid
;                  |$TCIF_RTLREADING - The string pointed to by Text will be displayed in the opposite direction
;                  |$TCIF_STATE      - The State member is valid
;                  |$TCIF_TEXT       - The Text member is valid
;                  State     - Specifies the item's current state if information is being retrieved. If item information is being
;                  +set this member contains the state value to be set for the item.
;                  StateMask - Specifies which bits of the dwState member contain valid information
;                  Text      - String that contains the tab text when item information is being set. If item information is being
;                  +retrieved, this member specifies the address of the buffer that receives the tab text.
;                  TextMax   - Size of the buffer pointed to by the Text member.  If the structure is not receiving  information,
;                  +this member is ignored.
;                  Image     - Index in the tab control's image list, or -1 if there is no image for the tab.
;                  Param     - Application-defined data associated with the tab control item
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagTCITEM = "uint Mask;dword State;dword StateMask;ptr Text;int TextMax;int Image;lparam Param"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagTCHITTESTINFO
; Description ...: Contains information about a hit test
; Fields ........: X     - X position to hit test
;                  Y     - Y position to hit test
;                  Flags - Results of a hit test. The control sets this member to one of the following values:
;                  |$TCHT_NOWHERE     - The position is not over a tab
;                  |$TCHT_ONITEM      - The position is over a tab but not over its icon or its text
;                  |$TCHT_ONITEMICON  - The position is over a tab's icon
;                  |$TCHT_ONITEMLABEL - The position is over a tab's text
;                  |$TCHT_ONITEM      - Bitwise OR of $TCHT_ONITEMICON and $TCHT_ONITEMLABEL
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagTCHITTESTINFO = $tagPOINT & ";uint Flags"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlTab_AdjustRect
; Description ...: Calculates a tab control's display area given a window rectangle
; Syntax.........: __GUICtrlTab_AdjustRect($hWnd, ByRef $tRect[, $fLarger=False])
; Parameters ....: $hWnd        - Handle to the control
;                  $tRect       - $tagRECT structure that holds a window or text display rectangle
;                  $fLarger     - Value that specifies which operation to perform.  If True, $tRect is used to specify a text
;                  +display rectangle and it receives the corresponding window rectangle.  If False, $tRect is used to specify a
;                  +window rectangle and it receives the corresponding text display rectangle.
; Return values .: Success      - $tagRECT structure with requested coordinates
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: This message applies only to tab controls that are at the top.  It does not apply to tab controls that are on
;                  the sides or bottom.
; Related .......: $tagRECT
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GUICtrlTab_AdjustRect($hWnd, ByRef $tRect, $fLarger = False)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_ghTabLastWnd) Then
			_SendMessage($hWnd, $TCM_ADJUSTRECT, $fLarger, $tRect, 0, "wparam", "struct*")
		Else
			Local $iRect = DllStructGetSize($tRect)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iRect, $tMemMap)
			_MemWrite($tMemMap, $tRect)
			_SendMessage($hWnd, $TCM_ADJUSTRECT, $fLarger, $pMemory, 0, "wparam", "ptr")
			_MemRead($tMemMap, $pMemory, $tRect, $iRect)
			_MemFree($tMemMap)
		EndIf
	EndIf
	Return $tRect
EndFunc   ;==>__GUICtrlTab_AdjustRect

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_ActivateTab
; Description ...: Activates a tab by its index
; Syntax.........: _GUICtrlTab_ActivateTab($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Specifies the zero based index of the item
; Return values .: Success      - The index of the previously selected tab
;                  Failure      - -1
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlTab_ActivateTab($hWnd, $iIndex)
	Local $nIndX
	; first, get Handle and CtrlID of TabControl
	If $hWnd = -1 Then $hWnd = GUICtrlGetHandle(-1)
	If IsHWnd($hWnd) Then
		$nIndX = _WinAPI_GetDlgCtrlID($hWnd)
	Else
		$nIndX = $hWnd
		$hWnd = GUICtrlGetHandle($hWnd)
	EndIf
	Local $hParent = _WinAPI_GetParent($hWnd)
	If @error Then Return SetError(1, 0, -1)

	; create Struct for the Messages
	Local $tNmhdr = DllStructCreate($tagNMHDR)
	DllStructSetData($tNmhdr, 1, $hWnd)
	DllStructSetData($tNmhdr, 2, $nIndX)
	DllStructSetData($tNmhdr, 3, $TCN_SELCHANGING)

	_SendMessage($hParent, $__TABCONSTANT_WM_NOTIFY, $nIndX, $tNmhdr, 0, "wparam", "struct*")
	; select TabItem
	Local $iRet = _GUICtrlTab_SetCurSel($hWnd, $iIndex)

	DllStructSetData($tNmhdr, 3, $TCN_SELCHANGE)
	_SendMessage($hParent, $__TABCONSTANT_WM_NOTIFY, $nIndX, $tNmhdr, 0, "wparam", "struct*")
	Return $iRet
EndFunc   ;==>_GUICtrlTab_ActivateTab

; #FUNCTION# =====================================================
; Name...........: _GUICtrlTab_ClickTab
; Description ...: Clicks a tab
; Syntax.........: _GUICtrlTab_ClickTab($hWnd, $iIndex[, $sButton = "left"[, $fMove = False[, $iClicks = 1[, $iSpeed = 1]]]])
; Parameters ....: $hWnd        - Handle to control
;                 $iIndex     - Specifies the zero based index of the item
;                 $sButton   - Button to click with
;                 $fMove       - If True, the mouse will be moved.
;                          - If False, the mouse does not move.
;                 $iClicks   - Number of clicks
;                 $iSpeed     - Mouse movement speed
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost), PsaltyDS
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_ClickTab($hWnd, $iIndex, $sButton = "left", $fMove = False, $iClicks = 1, $iSpeed = 1)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $iX, $iY
	If Not $fMove Then
		; Don't move mouse, use ControlClick()
		Local $hWinParent = _WinAPI_GetParent($hWnd)
		Local $avTabPos = _GUICtrlTab_GetItemRect($hWnd, $iIndex)
		$iX = $avTabPos[0] + (($avTabPos[2] - $avTabPos[0]) / 2)
		$iY = $avTabPos[1] + (($avTabPos[3] - $avTabPos[1]) / 2)
		ControlClick($hWinParent, "", $hWnd, $sButton, $iClicks, $iX, $iY)
	Else
		; Original code to move mouse and click (requires active window)
		Local $tRect = _GUICtrlTab_GetItemRectEx($hWnd, $iIndex)
		Local $tPoint = _WinAPI_PointFromRect($tRect, True)
		$tPoint = _WinAPI_ClientToScreen($hWnd, $tPoint)
		_WinAPI_GetXYFromPoint($tPoint, $iX, $iY)
		Local $iMode = Opt("MouseCoordMode", 1)
		MouseClick($sButton, $iX, $iY, $iClicks, $iSpeed)
		Opt("MouseCoordMode", $iMode)
	EndIf
EndFunc   ;==>_GUICtrlTab_ClickTab

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_Create
; Description ...: Create a TabControl control
; Syntax.........: _GUICtrlTab_Create($hWnd, $iX, $iY[, $iWidth=150[, $iHeight=150[, $iStyle=0x00000040[, $iExStyle=0x00000000]]]])
; Parameters ....: $hWnd        - Handle to parent or owner window
;                  $iX          - Horizontal position of the control
;                  $iY          - Vertical position of the control
;                  $iWidth      - Control width
;                  $iHeight     - Control height
;                  $iStyle      - Control styles:
;                  |$TCS_BOTTOM            - Tabs appear at the bottom of the control
;                  |$TCS_BUTTONS           - Tabs appear as buttons, and no border is drawn around the display area
;                  |$TCS_FIXEDWIDTH        - All tabs are the same width
;                  |$TCS_FLATBUTTONS       - Selected tabs appear as being indented into the background while other  tabs  appear
;                  +as being on the same plane as the background. This only affects tab controls with the $TCS_BUTTONS style.
;                  |$TCS_FOCUSNEVER        - The control does not receive the input focus when clicked
;                  |$TCS_FOCUSONBUTTONDOWN - The control receives the input focus when clicked
;                  |$TCS_FORCEICONLEFT     - Icons are aligned with the left edge of each fixed width tab. This style can only be
;                  +used with the $TCS_FIXEDWIDTH style.
;                  |$TCS_FORCELABELLEFT    - Labels are aligned on the left edge of each fixed width tab.  The label is displayed
;                  +immediately to the right of the icon instead of being  centered.  This  style  can  only  be  used  with  the
;                  +$TCS_FIXEDWIDTH style and it implies the $TCS_FORCEICONLEFT style.
;                  |$TCS_HOTTRACK          - Items under the pointer are automatically highlighted.  You can check whether or not
;                  +hot tracking is enabled by calling SystemParametersInfo.
;                  |$TCS_MULTILINE         - Multiple rows of tabs are displayed, if necessary, so all tabs are visible at once
;                  |$TCS_MULTISELECT       - Multiple tabs can be selected by holding down the CTRL key when clicking. This style
;                  +must be used with the $TCS_BUTTONS style.
;                  |$TCS_OWNERDRAWFIXED    - The parent window is responsible for drawing tabs
;                  |$TCS_RAGGEDRIGHT       - Rows of tabs will not be stretched to fill the entire width  of  the  control.  This
;                  +style is the default.
;                  |$TCS_RIGHT             - Tabs appear vertically on the right side of  controls  that  use  the  $TCS_VERTICAL
;                  +style. This value equals $TCS_BOTTOM. This style is not supported if you use visual styles.
;                  |$TCS_RIGHTJUSTIFY      - The width of each tab is increased, if necessary, so that each row of tabs fills the
;                  +entire width of the tab control. This style is ignored unless the $TCS_MULTILINE style is also specified.
;                  |$TCS_SCROLLOPPOSITE    - Unneeded tabs scroll to the opposite side of the control when a tab is selected
;                  |$TCS_SINGLELINE        - Only one row of tabs is displayed.  The  user  can  scroll  to  see  more  tabs,  if
;                  +necessary. This style is the default.
;                  |$TCS_TABS              - Tabs appear as tabs, and a border is drawn around the display area.  This  style  is
;                  +the default.
;                  |$TCS_TOOLTIPS          - The tab control has a ToolTip control associated with it
;                  |$TCS_VERTICAL          - Tabs appear at the left side of the control with tab text displayed vertically. This
;                  +style is valid only when used with the $TCS_MULTILINE style.  To make tabs appear on the right  side  of  the
;                  +control, also use the $TCS_RIGHT style.
;                  -
;                  |Default: $TCS_HOTTRACK
;                  |Forced: $WS_CHILD, $WS_CLIPSIBLINGS, $WS_VISIBLE
;                  $iExStyle     - Control extended styles:
;                  |$TCS_EX_FLATSEPARATORS - The control will draw separators between the tab items
;                  |$TCS_EX_REGISTERDROP   - The control generates $TCN_GETOBJECT notification messages to request a drop  target
;                  +object when an object is dragged over the tab items.
; Return values .: Success      - Handle to the control
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......: This function is for Advanced users and for learning how the control works.
; Related .......: _GUICtrlTab_Destroy
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_Create($hWnd, $iX, $iY, $iWidth = 150, $iHeight = 150, $iStyle = 0x00000040, $iExStyle = 0x00000000)
	If Not IsHWnd($hWnd) Then
		; Invalid Window handle for _GUICtrlTab_Create 1st parameter
		Return SetError(1, 0, 0)
	EndIf

	If $iWidth = -1 Then $iWidth = 150
	If $iHeight = -1 Then $iHeight = 150
	If $iStyle = -1 Then $iStyle = $TCS_HOTTRACK
	If $iExStyle = -1 Then $iExStyle = 0x00000000

	$iStyle = BitOR($iStyle, $__UDFGUICONSTANT_WS_CHILD, $__TABCONSTANT_WS_CLIPSIBLINGS, $__UDFGUICONSTANT_WS_VISIBLE)

	Local $nCtrlID = __UDF_GetNextGlobalID($hWnd)
	If @error Then Return SetError(@error, @extended, 0)

	Local $hTab = _WinAPI_CreateWindowEx($iExStyle, $__TABCONSTANT_ClassName, "", $iStyle, $iX, $iY, $iWidth, $iHeight, $hWnd, $nCtrlID)
	_WinAPI_SetFont($hTab, _WinAPI_GetStockObject($__TABCONSTANT_DEFAULT_GUI_FONT))
	Return $hTab
EndFunc   ;==>_GUICtrlTab_Create

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_DeleteAllItems
; Description ...: Deletes all tabs
; Syntax.........: _GUICtrlTab_DeleteAllItems($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: This does not delete the controls on the tabitems
; Related .......: _GUICtrlTab_DeleteItem
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_DeleteAllItems($hWnd)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $TCM_DELETEALLITEMS) <> 0
	Else
		Return GUICtrlSendMsg($hWnd, $TCM_DELETEALLITEMS, 0, 0) <> 0
	EndIf
EndFunc   ;==>_GUICtrlTab_DeleteAllItems

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_DeleteItem
; Description ...: Deletes a tab
; Syntax.........: _GUICtrlTab_DeleteItem($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: This does not delete the controls on the tabitems
; Related .......: _GUICtrlTab_DeleteAllItems
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_DeleteItem($hWnd, $iIndex)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $TCM_DELETEITEM, $iIndex) <> 0
	Else
		Return GUICtrlSendMsg($hWnd, $TCM_DELETEITEM, $iIndex, 0) <> 0
	EndIf
EndFunc   ;==>_GUICtrlTab_DeleteItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_DeselectAll
; Description ...: Resets tabs, clearing any that were set to the pressed state
; Syntax.........: _GUICtrlTab_DeselectAll($hWnd[, $fExclude = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $fExclude    - Exclusion flag:
;                  | True       - All tabs except for the one currently selected will be reset
;                  |False       - All tab items will be reset
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: This only works if $TCS_BUTTONS style flag has been set
; Related .......: _GUICtrlTab_SetCurSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_DeselectAll($hWnd, $fExclude = True)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		_SendMessage($hWnd, $TCM_DESELECTALL, $fExclude)
	Else
		GUICtrlSendMsg($hWnd, $TCM_DESELECTALL, $fExclude, 0)
	EndIf
EndFunc   ;==>_GUICtrlTab_DeselectAll

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_Destroy
; Description ...: Delete the control
; Syntax.........: _GUICtrlTab_Destroy(ByRef $hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True, Handle is set to 0
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Restricted to only be used on Tab created with _GUICtrlTab_Create
; Related .......: _GUICtrlTab_Create
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_Destroy(ByRef $hWnd)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)
	If Not _WinAPI_IsClassName($hWnd, $__TABCONSTANT_ClassName) Then Return SetError(2, 2, False)

	Local $Destroyed = 0
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_ghTabLastWnd) Then
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
EndFunc   ;==>_GUICtrlTab_Destroy

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_FindTab
; Description ...: Searches for a tab with the specific text
; Syntax.........: _GUICtrlTab_FindTab($hWnd, $sText[, $fInStr = False[, $iStart = 0]])
; Parameters ....: $hWnd        - Handle to the control
;                  $sText       - Text to search for
;                  $fInStr      - If True, the text can be anywhere in the tab's text.
;                  $iStart      - Zero based index of the tab to start searching from
; Return values .: Success      - The zero based tab index that matches the search
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The search is case insensitive
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_FindTab($hWnd, $sText, $fInStr = False, $iStart = 0)
	Local $sTab

	For $iI = $iStart To _GUICtrlTab_GetItemCount($hWnd)
		$sTab = _GUICtrlTab_GetItemText($hWnd, $iI)
		Switch $fInStr
			Case False
				If $sTab = $sText Then Return $iI
			Case True
				If StringInStr($sTab, $sText) Then Return $iI
		EndSwitch
	Next
	Return -1
EndFunc   ;==>_GUICtrlTab_FindTab

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_GetCurFocus
; Description ...: Returns the index of the item that has the focus in a tab control
; Syntax.........: _GUICtrlTab_GetCurFocus($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The zero based index of the tab item that has the focus
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The item that has the focus may be different than the selected item
; Related .......: _GUICtrlTab_SetCurFocus
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_GetCurFocus($hWnd)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $TCM_GETCURFOCUS)
	Else
		Return GUICtrlSendMsg($hWnd, $TCM_GETCURFOCUS, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlTab_GetCurFocus

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_GetCurSel
; Description ...: Determines the currently selected tab
; Syntax.........: _GUICtrlTab_GetCurSel($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The zero based index of the selected tab
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTab_SetCurSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_GetCurSel($hWnd)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $TCM_GETCURSEL)
	Else
		Return GUICtrlSendMsg($hWnd, $TCM_GETCURSEL, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlTab_GetCurSel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_GetDisplayRect
; Description ...: Retrieves the display rectangle of the client area
; Syntax.........: _GUICtrlTab_GetDisplayRect($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Array with the following format:
;                  |[0] = X coordinate of the upper left corner of the rectangle
;                  |[1] = Y coordinate of the upper left corner of the rectangle
;                  |[2] = X coordinate of the lower right corner of the rectangle
;                  |[3] = Y coordinate of the lower right corner of the rectangle
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Use this function to obtain the coordinates, in pixels, of the portion of the tab control that represents the
;                  contents of the tab pages.  The appearance of this portion of the tab control does not change when different
;                  tabs are selected.
; Related .......: _GUICtrlTab_GetDisplayRectEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_GetDisplayRect($hWnd)
	Local $aRect[4]

	Local $tRect = _GUICtrlTab_GetDisplayRectEx($hWnd)
	$aRect[0] = DllStructGetData($tRect, "Left")
	$aRect[1] = DllStructGetData($tRect, "Top")
	$aRect[2] = DllStructGetData($tRect, "Right")
	$aRect[3] = DllStructGetData($tRect, "Bottom")
	Return $aRect
EndFunc   ;==>_GUICtrlTab_GetDisplayRect

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_GetDisplayRectEx
; Description ...: Retrieves the display rectangle of the client area
; Syntax.........: _GUICtrlTab_GetDisplayRectEx($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - $tagRECT structure that receives the rectangle of the tab, in viewport coordinates
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Use this function to obtain the coordinates, in pixels, of the portion of the tab control that represents  the
;                  contents of the tab pages.  The appearance of this portion of the tab control does not change  when  different
;                  tabs are selected.
; Related .......: _GUICtrlTab_GetDisplayRect, $tagRECT
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_GetDisplayRectEx($hWnd)
	Local $tRect = _WinAPI_GetClientRect($hWnd)
	Return __GUICtrlTab_AdjustRect($hWnd, $tRect)
EndFunc   ;==>_GUICtrlTab_GetDisplayRectEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_GetExtendedStyle
; Description ...: Retrieves the extended styles that are currently in use
; Syntax.........: _GUICtrlTab_GetExtendedStyle($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Extended styles currently in use:
;                  |$TCS_EX_FLATSEPARATORS - The control will draw separators between the tab items
;                  |$TCS_EX_REGISTERDROP   - The control generates $TCN_GETOBJECT notification messages to request a drop target
;                  +object when an object is dragged over the tab items.
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTab_SetExtendedStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_GetExtendedStyle($hWnd)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $TCM_GETEXTENDEDSTYLE)
	Else
		Return GUICtrlSendMsg($hWnd, $TCM_GETEXTENDEDSTYLE, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlTab_GetExtendedStyle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_GetImageList
; Description ...: Retrieves the tab control image list
; Syntax.........: _GUICtrlTab_GetImageList($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Handle to the image list
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTab_SetImageList
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_GetImageList($hWnd)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return Ptr(_SendMessage($hWnd, $TCM_GETIMAGELIST))
	Else
		Return Ptr(GUICtrlSendMsg($hWnd, $TCM_GETIMAGELIST, 0, 0))
	EndIf
EndFunc   ;==>_GUICtrlTab_GetImageList

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_GetItem
; Description ...: Retrieves information about a tab
; Syntax.........: _GUICtrlTab_GetItem($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Array with the following format:
;                  |[0] - Item state flags:
;                  | $TCIS_BUTTONPRESSED - The tab control item is selected
;                  | $TCIS_HIGHLIGHTED   - The tab control item is highlighted
;                  |[1] - Item text
;                  |[2] - Zero based item image index or -1 if item has no image
;                  |[3] - Application-defined data
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTab_SetItem
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_GetItem($hWnd, $iIndex)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	Local $fUnicode = _GUICtrlTab_GetUnicodeFormat($hWnd)

	Local $iBuffer = 4096
	Local $tagTCITEMEx = $tagTCITEM & ";ptr Filler" ; strange the Filler is erased by TCM_GETITEM : MS Bug!!!
	Local $tItem = DllStructCreate($tagTCITEMEx)
	DllStructSetData($tItem, "Mask", $TCIF_ALLDATA)
	DllStructSetData($tItem, "TextMax", $iBuffer)
	DllStructSetData($tItem, "StateMask", BitOR($TCIS_HIGHLIGHTED, $TCIS_BUTTONPRESSED))
	Local $iItem = DllStructGetSize($tItem)
	Local $tBuffer
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
		$iBuffer *= 2
	Else
		$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
	EndIf
	Local $tMemMap
	Local $pMemory = _MemInit($hWnd, $iItem + $iBuffer, $tMemMap)
	Local $pText = $pMemory + $iItem
	DllStructSetData($tItem, "Text", $pText)
	_MemWrite($tMemMap, $tItem, $pMemory, $iItem)
	Local $iRet
	If $fUnicode Then
		$iRet = _SendMessage($hWnd, $TCM_GETITEMW, $iIndex, $pMemory)
	Else
		$iRet = _SendMessage($hWnd, $TCM_GETITEMA, $iIndex, $pMemory)
	EndIf
	_MemRead($tMemMap, $pMemory, $tItem, $iItem)
	_MemRead($tMemMap, $pText, $tBuffer, $iBuffer)
	_MemFree($tMemMap)
	Local $aItem[4]
	$aItem[0] = DllStructGetData($tItem, "State")
	$aItem[1] = DllStructGetData($tBuffer, "Text")
	$aItem[2] = DllStructGetData($tItem, "Image")
	$aItem[3] = DllStructGetData($tItem, "Param")
	Return SetError($iRet = 0, 0, $aItem)
EndFunc   ;==>_GUICtrlTab_GetItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_GetItemCount
; Description ...: Retrieves the number of tabs
; Syntax.........: _GUICtrlTab_GetItemCount($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Returns the number of tabs
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_GetItemCount($hWnd)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $TCM_GETITEMCOUNT)
	Else
		Return GUICtrlSendMsg($hWnd, $TCM_GETITEMCOUNT, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlTab_GetItemCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_GetItemImage
; Description ...: Retrieves the image index for a tab
; Syntax.........: _GUICtrlTab_GetItemImage($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Zero based image index of the tab
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTab_SetItemImage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_GetItemImage($hWnd, $iIndex)
	Local $aItem = _GUICtrlTab_GetItem($hWnd, $iIndex)
	Return $aItem[2]
EndFunc   ;==>_GUICtrlTab_GetItemImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_GetItemParam
; Description ...: Retrieves the param data for a tab
; Syntax.........: _GUICtrlTab_GetItemParam($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Tab param data
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTab_SetItemParam
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_GetItemParam($hWnd, $iIndex)
	Local $aItem = _GUICtrlTab_GetItem($hWnd, $iIndex)
	Return $aItem[3]
EndFunc   ;==>_GUICtrlTab_GetItemParam

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_GetItemRect
; Description ...: Retrieves the bounding rectangle for a tab
; Syntax.........: _GUICtrlTab_GetItemRect($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item item
; Return values .: Success      - Array with the following format:
;                  |[0] = X coordinate of the upper left corner of the rectangle
;                  |[1] = Y coordinate of the upper left corner of the rectangle
;                  |[2] = X coordinate of the lower right corner of the rectangle
;                  |[3] = Y coordinate of the lower right corner of the rectangle
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTab_GetItemRectEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_GetItemRect($hWnd, $iIndex)
	Local $aRect[4]

	Local $tRect = _GUICtrlTab_GetItemRectEx($hWnd, $iIndex)
	$aRect[0] = DllStructGetData($tRect, "Left")
	$aRect[1] = DllStructGetData($tRect, "Top")
	$aRect[2] = DllStructGetData($tRect, "Right")
	$aRect[3] = DllStructGetData($tRect, "Bottom")
	Return $aRect
EndFunc   ;==>_GUICtrlTab_GetItemRect

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_GetItemRectEx
; Description ...: Retrieves the bounding rectangle for a tab
; Syntax.........: _GUICtrlTab_GetItemRectEx($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item item
; Return values .: Success      - $tagRECT structure that receives the rectangle of the tab, in viewport coordinates
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTab_GetItemRect, $tagRECT
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_GetItemRectEx($hWnd, $iIndex)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	Local $tRect = DllStructCreate($tagRECT)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_ghTabLastWnd) Then
			_SendMessage($hWnd, $TCM_GETITEMRECT, $iIndex, $tRect, 0, "wparam", "struct*")
		Else
			Local $iRect = DllStructGetSize($tRect)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iRect, $tMemMap)
			_SendMessage($hWnd, $TCM_GETITEMRECT, $iIndex, $pMemory, 0, "wparam", "ptr")
			_MemRead($tMemMap, $pMemory, $tRect, $iRect)
			_MemFree($tMemMap)
		EndIf
	Else
		GUICtrlSendMsg($hWnd, $TCM_GETITEMRECT, $iIndex, DllStructGetPtr($tRect))
	EndIf
	Return $tRect
EndFunc   ;==>_GUICtrlTab_GetItemRectEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_GetItemState
; Description ...: Retrieves the state of a tab
; Syntax.........: _GUICtrlTab_GetItemState($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Integer with the following tab states:
;                  |$TCIS_BUTTONPRESSED - The tab control item is selected
;                  |$TCIS_HIGHLIGHTED   - The tab control item is highlighted
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTab_SetItemState
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_GetItemState($hWnd, $iIndex)
	Local $aItem = _GUICtrlTab_GetItem($hWnd, $iIndex)
	Return $aItem[0]
EndFunc   ;==>_GUICtrlTab_GetItemState

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_GetItemText
; Description ...: Retrieves the text of a tab
; Syntax.........: _GUICtrlTab_GetItemText($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Tab text
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTab_SetItemText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_GetItemText($hWnd, $iIndex)
	Local $aItem = _GUICtrlTab_GetItem($hWnd, $iIndex)
	Return $aItem[1]
EndFunc   ;==>_GUICtrlTab_GetItemText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_GetRowCount
; Description ...: Retrieves the current number of rows of tabs
; Syntax.........: _GUICtrlTab_GetRowCount($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Number of rows of tabs
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Only tab controls that have the $TCS_MULTILINE style can have multiple rows of tabs
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_GetRowCount($hWnd)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $TCM_GETROWCOUNT)
	Else
		Return GUICtrlSendMsg($hWnd, $TCM_GETROWCOUNT, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlTab_GetRowCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_GetToolTips
; Description ...: Retrieves the handle to the ToolTip control associated with the control
; Syntax.........: _GUICtrlTab_GetToolTips($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Handle to the ToolTip control
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTab_SetToolTips
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_GetToolTips($hWnd)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return HWnd(_SendMessage($hWnd, $TCM_GETTOOLTIPS))
	Else
		Return HWnd(GUICtrlSendMsg($hWnd, $TCM_GETTOOLTIPS, 0, 0))
	EndIf
EndFunc   ;==>_GUICtrlTab_GetToolTips

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_GetUnicodeFormat
; Description ...: Retrieves the Unicode character format flag for the control
; Syntax.........: _GUICtrlTab_GetUnicodeFormat($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: True         - Control is using Unicode characters
;                  False        - Control is using ANSI characters
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTab_SetUnicodeFormat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_GetUnicodeFormat($hWnd)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $TCM_GETUNICODEFORMAT) <> 0
	Else
		Return GUICtrlSendMsg($hWnd, $TCM_GETUNICODEFORMAT, 0, 0) <> 0
	EndIf
EndFunc   ;==>_GUICtrlTab_GetUnicodeFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_HighlightItem
; Description ...: Sets the highlight state of a tab item
; Syntax.........: _GUICtrlTab_HighlightItem($hWnd, $iIndex[, $fHighlight = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index
;                  $fHighlight  - If True, the tab is highlighted, otherwise the tab is reset
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTab_SetCurSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_HighlightItem($hWnd, $iIndex, $fHighlight = True)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $TCM_HIGHLIGHTITEM, $iIndex, $fHighlight) <> 0
	Else
		Return GUICtrlSendMsg($hWnd, $TCM_HIGHLIGHTITEM, $iIndex, $fHighlight) <> 0
	EndIf
EndFunc   ;==>_GUICtrlTab_HighlightItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_HitTest
; Description ...: Determines where a point lies control
; Syntax.........: _GUICtrlTab_HitTest($hWnd, $iX, $iY)
; Parameters ....: $hWnd        - Handle to the control
;                  $iX          - X position to test
;                  $iY          - Y position to test
; Return values .: Success      - Array with the following format:
;                  |[0] - Zero based index of the tab, or -1 if no tab is at the position
;                  |[1] - Results of the hit test:
;                  | 1 - The position is not over a tab
;                  | 2 - The position is over a tab's icon
;                  | 4 - The position is over a tab's text
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_HitTest($hWnd, $iX, $iY)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	Local $aHit[2] = [-1, 1]

	Local $tHit = DllStructCreate($tagTCHITTESTINFO)
	DllStructSetData($tHit, "X", $iX)
	DllStructSetData($tHit, "Y", $iY)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_ghTabLastWnd) Then
			$aHit[0] = _SendMessage($hWnd, $TCM_HITTEST, 0, $tHit, 0, "wparam", "struct*")
		Else
			Local $iHit = DllStructGetSize($tHit)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iHit, $tMemMap)
			_MemWrite($tMemMap, $tHit)
			$aHit[0] = _SendMessage($hWnd, $TCM_HITTEST, 0, $pMemory, 0, "wparam", "ptr")
			_MemRead($tMemMap, $pMemory, $tHit, $iHit)
			_MemFree($tMemMap)
		EndIf
	Else
		$aHit[0] = GUICtrlSendMsg($hWnd, $TCM_HITTEST, 0, DllStructGetPtr($tHit))
	EndIf
	$aHit[1] = DllStructGetData($tHit, "Flags")
	Return $aHit
EndFunc   ;==>_GUICtrlTab_HitTest

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_InsertItem
; Description ...: Inserts a new tab
; Syntax.........: _GUICtrlTab_InsertItem($hWnd, $iIndex, $sText[, $iImage = -1[, $iParam = 0]])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Index of the new tab
;                  $sText       - Tab text
;                  $iImage      - Zero based tab image index
;                  $iParam      - Application defined data
; Return values .: Success      - The zero based index of the new tab
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_InsertItem($hWnd, $iIndex, $sText, $iImage = -1, $iParam = 0)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlTab_GetUnicodeFormat($hWnd)

	Local $iBuffer = StringLen($sText) + 1
	Local $tBuffer
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
		$iBuffer *= 2
	Else
		$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
	EndIf
	Local $pBuffer = DllStructGetPtr($tBuffer)
	Local $tItem = DllStructCreate($tagTCITEM)
	DllStructSetData($tBuffer, "Text", $sText)
	DllStructSetData($tItem, "Mask", BitOR($TCIF_TEXT, $TCIF_IMAGE, $TCIF_PARAM))
	DllStructSetData($tItem, "TextMax", $iBuffer)
	DllStructSetData($tItem, "Image", $iImage)
	DllStructSetData($tItem, "Param", $iParam)
	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_ghTabLastWnd) Then
			DllStructSetData($tItem, "Text", $pBuffer)
			$iRet = _SendMessage($hWnd, $TCM_INSERTITEMW, $iIndex, $tItem, 0, "wparam", "struct*")
		Else
			Local $iItem = DllStructGetSize($tItem)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iItem + $iBuffer, $tMemMap)
			Local $pText = $pMemory + $iItem
			DllStructSetData($tItem, "Text", $pText)
			_MemWrite($tMemMap, $tItem, $pMemory, $iItem)
			_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
			If $fUnicode Then
				$iRet = _SendMessage($hWnd, $TCM_INSERTITEMW, $iIndex, $pMemory, 0, "wparam", "ptr")
			Else
				$iRet = _SendMessage($hWnd, $TCM_INSERTITEMA, $iIndex, $pMemory, 0, "wparam", "ptr")
			EndIf
			_MemFree($tMemMap)
		EndIf
	Else
		Local $pItem = DllStructGetPtr($tItem)
		DllStructSetData($tItem, "Text", $pBuffer)
		If $fUnicode Then
			$iRet = GUICtrlSendMsg($hWnd, $TCM_INSERTITEMW, $iIndex, $pItem)
		Else
			$iRet = GUICtrlSendMsg($hWnd, $TCM_INSERTITEMA, $iIndex, $pItem)
		EndIf
	EndIf
	Return $iRet
EndFunc   ;==>_GUICtrlTab_InsertItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_RemoveImage
; Description ...: Removes an image from the control's image list
; Syntax.........: _GUICtrlTab_RemoveImage($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the image to remove
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: The tab control updates each tab's image index, so each tab remains associated with the same image as before.
;                  If a tab is using the image being removed, the tab will be set to have no image.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_RemoveImage($hWnd, $iIndex)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		_SendMessage($hWnd, $TCM_REMOVEIMAGE, $iIndex)
		_WinAPI_InvalidateRect($hWnd)
	Else
		GUICtrlSendMsg($hWnd, $TCM_REMOVEIMAGE, $iIndex, 0)
	EndIf
EndFunc   ;==>_GUICtrlTab_RemoveImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_SetCurFocus
; Description ...: Sets the focus to a specified tab
; Syntax.........: _GUICtrlTab_SetCurFocus($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If the tab control has the $TCS_BUTTONS style (button mode), the tab with the focus may be
;                  different from the selected tab.  For example, when a tab is selected, the user can press the
;                  arrow keys to set the focus to a different tab without changing the selected tab.  In button
;                  mode, $TCM_SETCURFOCUS sets the input focus to the button associated with the specified tab,
;                  but it does not change the selected tab.
;+
;                  If the tab control does not have the $TCS_BUTTONS style, changing the focus also changes the selected tab.
; Related .......: _GUICtrlTab_GetCurFocus
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_SetCurFocus($hWnd, $iIndex)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		_SendMessage($hWnd, $TCM_SETCURFOCUS, $iIndex)
	Else
		GUICtrlSendMsg($hWnd, $TCM_SETCURFOCUS, $iIndex, 0)
	EndIf
EndFunc   ;==>_GUICtrlTab_SetCurFocus

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_SetCurSel
; Description ...: Selects a tab
; Syntax.........: _GUICtrlTab_SetCurSel($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index
; Return values .: Success      - The index of the previously selected tab
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: A tab control does not send a $TCN_SELCHANGING or $TCN_SELCHANGE notification message when
;                  a tab is selected using this function.
; Related .......: _GUICtrlTab_GetCurSel, _GUICtrlTab_DeselectAll, _GUICtrlTab_HighlightItem
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_SetCurSel($hWnd, $iIndex)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $TCM_SETCURSEL, $iIndex)
	Else
		Return GUICtrlSendMsg($hWnd, $TCM_SETCURSEL, $iIndex, 0)
	EndIf
EndFunc   ;==>_GUICtrlTab_SetCurSel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_SetExtendedStyle
; Description ...: Sets the extended styles that are currently in use
; Syntax.........: _GUICtrlTab_SetExtendedStyle($hWnd, $iStyle)
; Parameters ....: $hWnd        - Handle to the control
;                  $iStyle      - Extended styles currently in use:
;                  |$TCS_EX_FLATSEPARATORS - The control will draw separators between the tab items
;                  |$TCS_EX_REGISTERDROP   - The control generates TCN_GETOBJECT notification messages to request a
;                  +drop target object when an object is dragged over the tab items.
; Return values .: Success      - Previous extended styles
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTab_GetExtendedStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_SetExtendedStyle($hWnd, $iStyle)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $TCM_SETEXTENDEDSTYLE, 0, $iStyle)
	Else
		Return GUICtrlSendMsg($hWnd, $TCM_SETEXTENDEDSTYLE, 0, $iStyle)
	EndIf
EndFunc   ;==>_GUICtrlTab_SetExtendedStyle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_SetImageList
; Description ...: Sets the image list associated with a tab control
; Syntax.........: _GUICtrlTab_SetImageList($hWnd, $hImage)
; Parameters ....: $hWnd        - Handle to the control
;                  $hImage      - Handle to the image list to assign to the tab control
; Return values .: Success      - Handle to the previous image list
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTab_GetImageList
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_SetImageList($hWnd, $hImage)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $TCM_SETIMAGELIST, 0, $hImage, 0, "wparam", "handle", "handle")
	Else
		Return Ptr(GUICtrlSendMsg($hWnd, $TCM_SETIMAGELIST, 0, $hImage))
	EndIf
EndFunc   ;==>_GUICtrlTab_SetImageList

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_SetItem
; Description ...: Sets information about a tab
; Syntax.........: _GUICtrlTab_SetItem($hWnd, $iIndex[, $sText = -1[, $iState = -1[, $iImage = -1[, $iParam = -1]]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index
;                  $sText       - Item text
;                  $iState      - Item state
;                  $iImage      - Zero based item image
;                  $iParam      - Application defined data
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTab_GetItem
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_SetItem($hWnd, $iIndex, $sText = -1, $iState = -1, $iImage = -1, $iParam = -1)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tItem = DllStructCreate($tagTCITEM)
	Local $iBuffer, $tBuffer, $iMask = 0, $iRet
	Local $fUnicode = _GUICtrlTab_GetUnicodeFormat($hWnd)
	If IsString($sText) Then
		$iBuffer = StringLen($sText) + 1
		If $fUnicode Then
			$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
			$iBuffer *= 2
		Else
			$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
		EndIf
		DllStructSetData($tBuffer, "Text", $sText)
		DllStructSetData($tItem, "Text", DllStructGetPtr($tBuffer))
		$iMask = $TCIF_TEXT
	EndIf
	If $iState <> -1 Then
		DllStructSetData($tItem, "State", $iState)
		DllStructSetData($tItem, "StateMask", $iState)
		$iMask = BitOR($iMask, $TCIF_STATE)
	EndIf
	If $iImage <> -1 Then
		DllStructSetData($tItem, "Image", $iImage)
		$iMask = BitOR($iMask, $TCIF_IMAGE)
	EndIf
	If $iParam <> -1 Then
		DllStructSetData($tItem, "Param", $iParam)
		$iMask = BitOR($iMask, $TCIF_PARAM)
	EndIf
	DllStructSetData($tItem, "Mask", $iMask)
	Local $iItem = DllStructGetSize($tItem)
	Local $tMemMap
	Local $pMemory = _MemInit($hWnd, $iItem + 8192, $tMemMap)
	Local $pText = $pMemory + 4096
	DllStructSetData($tItem, "Text", $pText)
	_MemWrite($tMemMap, $tItem, $pMemory, $iItem)
	If IsString($sText) Then _MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
	If $fUnicode Then
		$iRet = _SendMessage($hWnd, $TCM_SETITEMW, $iIndex, $pMemory) <> 0
	Else
		$iRet = _SendMessage($hWnd, $TCM_SETITEMA, $iIndex, $pMemory) <> 0
	EndIf
	_MemFree($tMemMap)
	Return $iRet
EndFunc   ;==>_GUICtrlTab_SetItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_SetItemImage
; Description ...: Sets the image of a tab
; Syntax.........: _GUICtrlTab_SetItemImage($hWnd, $iIndex, $iImage)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index
;                  $iImage      - Zero based item image
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTab_GetItemImage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_SetItemImage($hWnd, $iIndex, $iImage)
	Return _GUICtrlTab_SetItem($hWnd, $iIndex, -1, -1, $iImage)
EndFunc   ;==>_GUICtrlTab_SetItemImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_SetItemParam
; Description ...: Sets the param data of a tab
; Syntax.........: _GUICtrlTab_SetItemParam($hWnd, $iIndex, $iParam)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index
;                  $iParam      - Application defined data
; Return values .: Success      - True
;                  Failure       - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTab_GetItemParam
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_SetItemParam($hWnd, $iIndex, $iParam)
	Return _GUICtrlTab_SetItem($hWnd, $iIndex, -1, -1, -1, $iParam)
EndFunc   ;==>_GUICtrlTab_SetItemParam

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_SetItemSize
; Description ...: Sets the width and height of tabs in a fixed width or owner drawn control
; Syntax.........: _GUICtrlTab_SetItemSize($hWnd, $iWidth, $iHeight)
; Parameters ....: $hWnd        - Handle to the control
;                  $iWidth      - New width, in pixels
;                  $iHeight     - New height, in pixels
; Return values .: Success      - Returns the old width and height.  The width is in the low order word of the return value,  and
;                  +the height is in the high-order word.
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_SetItemSize($hWnd, $iWidth, $iHeight)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $TCM_SETITEMSIZE, 0, _WinAPI_MakeLong($iWidth, $iHeight))
	Else
		Return GUICtrlSendMsg($hWnd, $TCM_SETITEMSIZE, 0, _WinAPI_MakeLong($iWidth, $iHeight))
	EndIf
EndFunc   ;==>_GUICtrlTab_SetItemSize

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_SetItemState
; Description ...: Sets the state of a tab
; Syntax.........: _GUICtrlTab_SetItemState($hWnd, $iIndex, $iState)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index
;                  $iState      - Item state. Can be a combination of:
;                  |$TCIS_BUTTONPRESSED - The tab control item is selected
;                  |$TCIS_HIGHLIGHTED   - The tab control item is highlighted
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTab_GetItemState
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_SetItemState($hWnd, $iIndex, $iState)
	Return _GUICtrlTab_SetItem($hWnd, $iIndex, -1, $iState)
EndFunc   ;==>_GUICtrlTab_SetItemState

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_SetItemText
; Description ...: Sets the text of a tab
; Syntax.........: _GUICtrlTab_SetItemText($hWnd, $iIndex, $sText)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index
;                  $sText       - Item text
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTab_GetItemText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_SetItemText($hWnd, $iIndex, $sText)
	Return _GUICtrlTab_SetItem($hWnd, $iIndex, $sText)
EndFunc   ;==>_GUICtrlTab_SetItemText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_SetMinTabWidth
; Description ...: Sets the minimum width of items in a tab control
; Syntax.........: _GUICtrlTab_SetMinTabWidth($hWnd, $iMinWidth)
; Parameters ....: $hWnd        - Handle to the control
;                  $iMinWidth   - Minimum width to be set for a tab control item.
;                  +If -1, the control will use the default width.
; Return values .: Success      - The previous minimum tab width
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_SetMinTabWidth($hWnd, $iMinWidth)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $TCM_SETMINTABWIDTH, 0, $iMinWidth)
	Else
		Return GUICtrlSendMsg($hWnd, $TCM_SETMINTABWIDTH, 0, $iMinWidth)
	EndIf
EndFunc   ;==>_GUICtrlTab_SetMinTabWidth

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_SetPadding
; Description ...: Sets the amount of space around each tab's icon and label
; Syntax.........: _GUICtrlTab_SetPadding($hWnd, $iHorz, $iVert)
; Parameters ....: $hWnd        - Handle to the control
;                  $iHorz       - Amount of horizontal padding, in pixels
;                  $iVert       - Amount of vertical padding, in pixels
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_SetPadding($hWnd, $iHorz, $iVert)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		_SendMessage($hWnd, $TCM_SETPADDING, 0, _WinAPI_MakeLong($iHorz, $iVert))
	Else
		GUICtrlSendMsg($hWnd, $TCM_SETPADDING, 0, _WinAPI_MakeLong($iHorz, $iVert))
	EndIf
EndFunc   ;==>_GUICtrlTab_SetPadding

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_SetToolTips
; Description ...: Sets the handle to the ToolTip control associated with the control
; Syntax.........: _GUICtrlTab_SetToolTips($hWnd, $hToolTip)
; Parameters ....: $hWnd        - Handle to the control
;                  $hToolTip    - Handle to the ToolTip control
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlTab_GetToolTips
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_SetToolTips($hWnd, $hToolTip)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		_SendMessage($hWnd, $TCM_SETTOOLTIPS, $hToolTip, 0, 0, "hwnd")
	Else
		GUICtrlSendMsg($hWnd, $TCM_SETTOOLTIPS, $hToolTip, 0)
	EndIf
EndFunc   ;==>_GUICtrlTab_SetToolTips

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlTab_SetUnicodeFormat
; Description ...: Sets the Unicode character format flag for the control
; Syntax.........: _GUICtrlTab_SetUnicodeFormat($hWnd, $fUnicode)
; Parameters ....: $hWnd        - Handle to the control
;                  $fUnicode    - Unicode character flag:
;                  |True  - Control uses Unicode characters
;                  |False - Control uses ANSI characters
; Return values .: Success      - Previous character format flag setting
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlTab_GetUnicodeFormat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlTab_SetUnicodeFormat($hWnd, $fUnicode)
	If $Debug_TAB Then __UDF_ValidateClassName($hWnd, $__TABCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $TCM_SETUNICODEFORMAT, $fUnicode) <> 0
	Else
		Return GUICtrlSendMsg($hWnd, $TCM_SETUNICODEFORMAT, $fUnicode, 0) <> 0
	EndIf
EndFunc   ;==>_GUICtrlTab_SetUnicodeFormat
