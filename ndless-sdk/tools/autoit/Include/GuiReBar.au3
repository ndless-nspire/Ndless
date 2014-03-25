#include-once

#include "RebarConstants.au3"
#include "Memory.au3"
#include "WinAPI.au3"
#include "StructureConstants.au3"
#include "SendMessage.au3"
#include "UDFGlobalID.au3"

; #INDEX# =======================================================================================================================
; Title .........: Rebar
; AutoIt Version : 3.3.7.20++
; Language ......: English
; Description ...: Functions that assist with Rebar control management.
;                  Rebar controls act as containers for child windows. An application assigns child windows,
;                  which are often other controls, to a rebar control band. Rebar controls contain one or more bands,
;                  and each band can have any combination of a gripper bar, a bitmap, a text label, and a child window.
;                  However, bands cannot contain more than one child window.
; Author(s) .....: Gary Frost
; Dll(s) ........: user32.dll, comctl32.dll
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $Debug_RB = False
Global $gh_RBLastWnd
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__REBARCONSTANT_ClassName = "ReBarWindow32"
Global Const $__REBARCONSTANT_TB_GETBUTTONSIZE = $__REBARCONSTANT_WM_USER + 58
Global Const $__REBARCONSTANT_TB_BUTTONCOUNT = $__REBARCONSTANT_WM_USER + 24
Global Const $__REBARCONSTANT_WS_CLIPCHILDREN = 0x02000000
Global Const $__REBARCONSTANT_WS_CLIPSIBLINGS = 0x04000000
Global Const $__REBARCONSTANT_CCS_TOP = 0x01
; ==============================================================================================================================

; #NO_DOC_FUNCTION# =============================================================================================================
; Not working/documented/implemented at this time
;
;_GUICtrlRebar_GetBandStyleNoVert
;_GUICtrlRebar_SetBandStyleNoVert
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_GUICtrlRebar_AddBand
;_GUICtrlRebar_AddToolBarBand
;_GUICtrlRebar_BeginDrag
;_GUICtrlRebar_Create
;_GUICtrlRebar_DeleteBand
;_GUICtrlRebar_Destroy
;_GUICtrlRebar_DragMove
;_GUICtrlRebar_EndDrag
;_GUICtrlRebar_GetBandBackColor
;_GUICtrlRebar_GetBandBorders
;_GUICtrlRebar_GetBandBordersEx
;_GUICtrlRebar_GetBandChildHandle
;_GUICtrlRebar_GetBandChildSize
;_GUICtrlRebar_GetBandCount
;_GUICtrlRebar_GetBandForeColor
;_GUICtrlRebar_GetBandHeaderSize
;_GUICtrlRebar_GetBandID
;_GUICtrlRebar_GetBandIdealSize
;_GUICtrlRebar_GetBandLParam
;_GUICtrlRebar_GetBandLength
;_GUICtrlRebar_GetBandMargins
;_GUICtrlRebar_GetBandMarginsEx
;_GUICtrlRebar_GetBandStyle
;_GUICtrlRebar_GetBandStyleBreak
;_GUICtrlRebar_GetBandStyleChildEdge
;_GUICtrlRebar_GetBandStyleFixedBMP
;_GUICtrlRebar_GetBandStyleFixedSize
;_GUICtrlRebar_GetBandStyleGripperAlways
;_GUICtrlRebar_GetBandStyleHidden
;_GUICtrlRebar_GetBandStyleHideTitle
;_GUICtrlRebar_GetBandStyleNoGripper
;_GUICtrlRebar_GetBandStyleTopAlign
;_GUICtrlRebar_GetBandStyleUseChevron
;_GUICtrlRebar_GetBandStyleVariableHeight
;_GUICtrlRebar_GetBandRect
;_GUICtrlRebar_GetBandRectEx
;_GUICtrlRebar_GetBandText
;_GUICtrlRebar_GetBarHeight
;_GUICtrlRebar_GetBarInfo
;_GUICtrlRebar_GetBKColor
;_GUICtrlRebar_GetColorScheme
;_GUICtrlRebar_GetRowCount
;_GUICtrlRebar_GetRowHeight
;_GUICtrlRebar_GetTextColor
;_GUICtrlRebar_GetToolTips
;_GUICtrlRebar_GetUnicodeFormat
;_GUICtrlRebar_HitTest
;_GUICtrlRebar_IDToIndex
;_GUICtrlRebar_MaximizeBand
;_GUICtrlRebar_MinimizeBand
;_GUICtrlRebar_MoveBand
;_GUICtrlRebar_SetBandBackColor
;_GUICtrlRebar_SetBandForeColor
;_GUICtrlRebar_SetBandHeaderSize
;_GUICtrlRebar_SetBandID
;_GUICtrlRebar_SetBandIdealSize
;_GUICtrlRebar_SetBandLength
;_GUICtrlRebar_SetBandLParam
;_GUICtrlRebar_SetBandStyle
;_GUICtrlRebar_SetBandStyleBreak
;_GUICtrlRebar_SetBandStyleChildEdge
;_GUICtrlRebar_SetBandStyleFixedBMP
;_GUICtrlRebar_SetBandStyleFixedSize
;_GUICtrlRebar_SetBandStyleGripperAlways
;_GUICtrlRebar_SetBandStyleHidden
;_GUICtrlRebar_SetBandStyleHideTitle
;_GUICtrlRebar_SetBandStyleNoGripper
;_GUICtrlRebar_SetBandStyleTopAlign
;_GUICtrlRebar_SetBandStyleUseChevron
;_GUICtrlRebar_SetBandStyleVariableHeight
;_GUICtrlRebar_SetBandText
;_GUICtrlRebar_SetBKColor
;_GUICtrlRebar_SetBarInfo
;_GUICtrlRebar_SetColorScheme
;_GUICtrlRebar_SetTextColor
;_GUICtrlRebar_SetToolTips
;_GUICtrlRebar_SetUnicodeFormat
;_GUICtrlRebar_ShowBand
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;$tagREBARINFO
;$tagRBHITTESTINFO
;__GUICtrlRebar_GetBandInfo
;__GUICtrlRebar_GetColorSchemeEx
;__GUICtrlRebar_SetBandInfo
; ==============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagREBARINFO
; Description ...: Contains information that describes rebar control characteristics
; Fields ........: cbSize         - Size of this structure, in bytes. Your application must fill this member before sending any messages that use the address of this structure as a parameter.
;                  fMask          - Flag values that describe characteristics of the rebar control. Currently, rebar controls support only one value:
;                  |$RBIM_IMAGELIST - The himl member is valid or must be filled
;                  himl           - Handle to an image list. The rebar control will use the specified image list to obtain images
; Author ........: Gary Frost
; Remarks .......:
; ===============================================================================================================================
Global Const $tagREBARINFO = "uint cbSize;uint fMask;handle himl"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagRBHITTESTINFO
; Description ...: Contains information specific to a hit test operation
; Fields ........: X - Specifies the x-coordinate of the point
;                  Y - Specifies the y-coordinate of the point
;                  flags - Member that receives a flag value indicating the rebar band's component located at the point described by pt
;                  |This member will be one of the following:
;                  -
;                  |$RBHT_CAPTION - The point was in the rebar band's caption
;                  |$RBHT_CHEVRON - The point was in the rebar band's chevron (version 5.80 and greater)
;                  |$RBHT_CLIENT  - The point was in the rebar band's client area
;                  |$RBHT_GRABBER - The point was in the rebar band's gripper
;                  |$RBHT_NOWHERE - The point was not in a rebar band
;                  iBand - Member that receives the rebar band's index at the point described by pt
;                  |This value will be the zero-based index of the band, or -1 if no band was at the hit-tested point
; Author ........: Gary Frost
; Remarks .......:
; ===============================================================================================================================
Global Const $tagRBHITTESTINFO = $tagPOINT & ";uint flags;int iBand"

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_AddBand
; Description ...: Adds a new band in a rebar control
; Syntax.........: _GUICtrlRebar_AddBand($hwndRebar, $hwndChild[, $iMinWidth = 100[, $iDefaultWidth = 100[, $sText = ""[, $iIndex = -1[, $fStyle = -1]]]]])
; Parameters ....: $hwndRebar     - Handle to rebar control
;                  $hwndChild     - Handle of control to add
;                  $iMinWidth     - Minimum width for the band
;                  $iDefaultWidth - Length of the band, in pixels
;                  $sText         - Display text for the band
;                  $iIndex        - Zero-based index of the location where the band will be inserted.
;                  |If you set this parameter to -1, the control will add the new band at the last location
;                  $fStyle        - Flags that specify the band style. This value can be a combination of the following:
;                  |$RBBS_BREAK          - The band is on a new line.
;                  |$RBBS_CHILDEDGE      - The band has an edge at the top and bottom of the child window.
;                  |$RBBS_FIXEDBMP       - The background bitmap does not move when the band is resized.
;                  |$RBBS_FIXEDSIZE      - The band can't be sized. With this style, the sizing grip is not displayed on the band.
;                  |$RBBS_GRIPPERALWAYS  - Version 4.71. The band will always have a sizing grip, even if it is the only band in the rebar.
;                  |$RBBS_HIDDEN         - The band will not be visible.
;                  |$RBBS_NOGRIPPER      - Version 4.71. The band will never have a sizing grip, even if there is more than one band in the rebar.
;                  |$RBBS_USECHEVRON     - Version 5.80. Show a chevron button if the band is smaller than cxIdeal.
;                  |$RBBS_VARIABLEHEIGHT - Version 4.71. The band can be resized by the rebar control;
;                  |cyIntegral and cyMaxChild affect how the rebar will resize the band.
;                  |$RBBS_NOVERT         - Don't show when vertical.
;                  |$RBBS_USECHEVRON     - Display drop-down button.
;                  |$RBBS_HIDETITLE      - Keep band title hidden.
;                  |$RBBS_TOPALIGN       - Keep band in top row.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_AddToolBarBand, _GUICtrlRebar_DeleteBand
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_AddBand($hwndRebar, $hwndChild, $iMinWidth = 100, $iDefaultWidth = 100, $sText = "", $iIndex = -1, $fStyle = -1)
	If $Debug_RB Then __UDF_ValidateClassName($hwndRebar, $__REBARCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlRebar_GetUnicodeFormat($hwndRebar)

	If Not IsHWnd($hwndChild) Then $hwndChild = GUICtrlGetHandle($hwndChild)
	Local $tINFO = DllStructCreate($tagREBARBANDINFO)
	Local $iSize = DllStructGetSize($tINFO)

	If $iDefaultWidth < $iMinWidth Then $iDefaultWidth = $iMinWidth
	If $fStyle <> -1 Then
		$fStyle = BitOR($fStyle, $RBBS_CHILDEDGE, $RBBS_GRIPPERALWAYS)
	Else
		$fStyle = BitOR($RBBS_CHILDEDGE, $RBBS_GRIPPERALWAYS)
	EndIf
	;// Initialize band info used by the control
	DllStructSetData($tINFO, "cbSize", $iSize)
	DllStructSetData($tINFO, "fMask", BitOR($RBBIM_STYLE, $RBBIM_TEXT, $RBBIM_CHILD, $RBBIM_CHILDSIZE, $RBBIM_SIZE, $RBBIM_ID))
	DllStructSetData($tINFO, "fStyle", $fStyle)

	;// Set values unique to the band with the control
	Local $tRect = _WinAPI_GetWindowRect($hwndChild)
	Local $iBottom = DllStructGetData($tRect, "Bottom")
	Local $iTop = DllStructGetData($tRect, "Top")
	Local $iBuffer = StringLen($sText) + 1
	Local $tBuffer
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
		$iBuffer *= 2
	Else
		$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
	EndIf
	DllStructSetData($tBuffer, "Text", $sText)
	DllStructSetData($tINFO, "hwndChild", $hwndChild)
	DllStructSetData($tINFO, "cxMinChild", $iMinWidth)
	DllStructSetData($tINFO, "cyMinChild", $iBottom - $iTop)
	;// The default width should be set to some value wider than the text. The combo
	;// box itself will expand to fill the band.
	DllStructSetData($tINFO, "cx", $iDefaultWidth)
	DllStructSetData($tINFO, "wID", _GUICtrlRebar_GetBandCount($hwndRebar))

	Local $tMemMap
	Local $pMemory = _MemInit($hwndRebar, $iSize + $iBuffer, $tMemMap)
	Local $pText = $pMemory + $iSize
	DllStructSetData($tINFO, "lpText", $pText)
	_MemWrite($tMemMap, $tINFO, $pMemory, $iSize)
	_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
	;// Add the band that has the combobox
	Local $iRet
	If $fUnicode Then
		$iRet = _SendMessage($hwndRebar, $RB_INSERTBANDW, $iIndex, $pMemory, 0, "wparam", "ptr") <> 0
	Else
		$iRet = _SendMessage($hwndRebar, $RB_INSERTBANDA, $iIndex, $pMemory, 0, "wparam", "ptr") <> 0
	EndIf
	_MemFree($tMemMap)
	Return $iRet
EndFunc   ;==>_GUICtrlRebar_AddBand

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_AddToolBarBand
; Description ...: Adds a new band in a rebar control
; Syntax.........: _GUICtrlRebar_AddToolBarBand($hwndRebar, $hwndToolbar[, $sText = ""[, $iIndex = -1[, $fStyle = -1]]])
; Parameters ....: $hwndRebar   - Handle to rebar control
;                  $hwndToolbar - Handle of the Toolbar control to add
;                  $sText       - Display text for the band
;                  $iIndex      - Zero-based index of the location where the band will be inserted.
;                  |If you set this parameter to -1, the control will add the new band at the last location
;                  $fStyle        - Flags that specify the band style. This value can be a combination of the following:
;                  |$RBBS_BREAK          - The band is on a new line.
;                  |$RBBS_CHILDEDGE      - The band has an edge at the top and bottom of the child window.
;                  |$RBBS_FIXEDBMP       - The background bitmap does not move when the band is resized.
;                  |$RBBS_FIXEDSIZE      - The band can't be sized. With this style, the sizing grip is not displayed on the band.
;                  |$RBBS_GRIPPERALWAYS  - Version 4.71. The band will always have a sizing grip, even if it is the only band in the rebar.
;                  |$RBBS_HIDDEN         - The band will not be visible.
;                  |$RBBS_NOGRIPPER      - Version 4.71. The band will never have a sizing grip, even if there is more than one band in the rebar.
;                  |$RBBS_USECHEVRON     - Version 5.80. Show a chevron button if the band is smaller than cxIdeal.
;                  |$RBBS_VARIABLEHEIGHT - Version 4.71. The band can be resized by the rebar control;
;                  |cyIntegral and cyMaxChild affect how the rebar will resize the band.
;                  |$RBBS_NOVERT         - Don't show when vertical.
;                  |$RBBS_USECHEVRON     - Display drop-down button.
;                  |$RBBS_HIDETITLE      - Keep band title hidden.
;                  |$RBBS_TOPALIGN       - Keep band in top row.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_AddBand, _GUICtrlRebar_DeleteBand
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_AddToolBarBand($hwndRebar, $hwndToolbar, $sText = "", $iIndex = -1, $fStyle = -1)
	If $Debug_RB Then __UDF_ValidateClassName($hwndRebar, $__REBARCONSTANT_ClassName)
	If $Debug_RB Then __UDF_ValidateClassName($hwndToolbar, "ToolbarWindow32")

	Local $fUnicode = _GUICtrlRebar_GetUnicodeFormat($hwndRebar)

	Local $tINFO = DllStructCreate($tagREBARBANDINFO)
	Local $iSize = DllStructGetSize($tINFO)

	If $fStyle <> -1 Then
		$fStyle = BitOR($fStyle, $RBBS_CHILDEDGE, $RBBS_GRIPPERALWAYS)
	Else
		$fStyle = BitOR($RBBS_CHILDEDGE, $RBBS_GRIPPERALWAYS)
	EndIf

	;// Initialize band info used by the toolbar
	DllStructSetData($tINFO, "cbSize", $iSize)
	DllStructSetData($tINFO, "fMask", BitOR($RBBIM_STYLE, $RBBIM_TEXT, $RBBIM_CHILD, $RBBIM_CHILDSIZE, $RBBIM_SIZE, $RBBIM_ID))
	DllStructSetData($tINFO, "fStyle", $fStyle)

	;// Get the height of the toolbar.
	Local $dwBtnSize = _SendMessage($hwndToolbar, $__REBARCONSTANT_TB_GETBUTTONSIZE)
	; Get the number of buttons contained in toolbar for calculation
	Local $NumButtons = _SendMessage($hwndToolbar, $__REBARCONSTANT_TB_BUTTONCOUNT)
	Local $iDefaultWidth = $NumButtons * _WinAPI_LoWord($dwBtnSize)

	;// Set values unique to the band with the toolbar.
	Local $iBuffer = StringLen($sText) + 1
	Local $tBuffer
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
		$iBuffer *= 2
	Else
		$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
	EndIf
	DllStructSetData($tBuffer, "Text", $sText)
	DllStructSetData($tINFO, "hwndChild", $hwndToolbar)
	DllStructSetData($tINFO, "cyChild", _WinAPI_HiWord($dwBtnSize))
	DllStructSetData($tINFO, "cxMinChild", $iDefaultWidth)
	DllStructSetData($tINFO, "cyMinChild", _WinAPI_HiWord($dwBtnSize))
	DllStructSetData($tINFO, "cx", $iDefaultWidth) ;// The default width is the width of the buttons.
	DllStructSetData($tINFO, "wID", _GUICtrlRebar_GetBandCount($hwndRebar))

	;// Add the band that has the toolbar.
	Local $tMemMap, $iRet
	Local $pMemory = _MemInit($hwndRebar, $iSize + $iBuffer, $tMemMap)
	Local $pText = $pMemory + $iSize
	DllStructSetData($tINFO, "lpText", $pText)
	_MemWrite($tMemMap, $tINFO, $pMemory, $iSize)
	_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
	;// Add the band that has the combobox
	If $fUnicode Then
		$iRet = _SendMessage($hwndRebar, $RB_INSERTBANDW, $iIndex, $pMemory, 0, "wparam", "ptr") <> 0
	Else
		$iRet = _SendMessage($hwndRebar, $RB_INSERTBANDA, $iIndex, $pMemory, 0, "wparam", "ptr") <> 0
	EndIf
	_MemFree($tMemMap)
	Return $iRet
EndFunc   ;==>_GUICtrlRebar_AddToolBarBand

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_BeginDrag
; Description ...: Adds a new band in a rebar control
; Syntax.........: _GUICtrlRebar_BeginDrag($hWnd, $iIndex[, $dwPos = -1])
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of the band that the drag-and-drop operation will affect
;                  $dwPos       - DWORD value that contains the starting mouse coordinates.
;                  |The horizontal coordinate is contained in the LOWORD and the vertical coordinate is contained in the HIWORD.
;                  |If you pass (DWORD)-1, the rebar control will use the position of the mouse the last time the control's thread called GetMessage or PeekMessage
; Return values .:
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_DragMove, _GUICtrlRebar_EndDrag
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_BeginDrag($hWnd, $iIndex, $dwPos = -1)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	_SendMessage($hWnd, $RB_BEGINDRAG, $iIndex, $dwPos, 0, "wparam", "dword")
EndFunc   ;==>_GUICtrlRebar_BeginDrag

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_Create
; Description ...: Create a Rebar control
; Syntax.........: _GUICtrlRebar_Create($hWnd[, $iStyles = 0x513])
; Parameters ....: $hWnd        - Handle to parent or owner window
;                  $iStyles     - Rebar controls support a variety of control styles in addition to standard window styles:
;                  |$RBS_AUTOSIZE        - Version 4.71. The rebar control will automatically change the layout of the bands when
;                  +the size or position of the control changes. An $RBN_AUTOSIZE notification will be sent when this occurs
;                  |$RBS_BANDBORDERS     - Version 4.71. The rebar control displays narrow lines to separate adjacent bands
;                  |$RBS_DBLCLKTOGGLE    - Version 4.71. The rebar band will toggle its maximized or minimized state when the user
;                  +double-clicks the band.  Without this style, the maximized or minimized state is toggled when the user
;                  +single-clicks on the band
;                  |$RBS_FIXEDORDER      - Version 4.70. The rebar control always displays bands in the same order. You can move
;                  +bands to different rows, but the band order is static
;                  |$RBS_REGISTERDROP    - Version 4.71. The rebar control generates $RBN_GETOBJECT notification messages when an
;                  +object is dragged over a band in the control
;                  |$RBS_TOOLTIPS        - Version 4.71. Not yet supported
;                  |$RBS_VARHEIGHT       - Version 4.71. The rebar control displays bands at the minimum required height, when
;                  +possible. Without this style, the rebar control displays all bands at the same height, using the height of
;                  +the tallest visible band to determine the height of other bands
;                  |$RBS_VERTICALGRIPPER - Version 4.71. The size grip will be displayed vertically instead of horizontally in a
;                  +vertical rebar control. This style is ignored for rebar controls that do not have the $CCS_VERT style
;                  |$CCS_LEFT            - Version 4.70. Causes the control to be displayed vertically on the left side of the parent window
;                  |$CCS_NODIVIDER       - Prevents a two-pixel highlight from being drawn at the top of the control
;                  |$CCS_RIGHT           - Version 4.70. Causes the control to be displayed vertically on the right side of the parent window
;                  |$CCS_VERT            - Version 4.70. Causes the control to be displayed vertically
;                  -
;                  |Default: $CCS_TOP, $RBS_VARHEIGHT
;                  |Forced: $WS_CHILD, $WS_VISIBLE, $WS_CLIPCHILDREN, $WS_CLIPSIBLINGS
; Return values .: Success      - Handle to the Rebar control
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_Destroy
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_Create($hWnd, $iStyles = 0x513)
	Local Const $ICC_BAR_CLASSES = 0x00000004; toolbar
	Local Const $ICC_COOL_CLASSES = 0x00000400; rebar

	Local $iStyle = BitOR($__UDFGUICONSTANT_WS_CHILD, $__UDFGUICONSTANT_WS_VISIBLE, $__REBARCONSTANT_WS_CLIPCHILDREN, $__REBARCONSTANT_WS_CLIPSIBLINGS)
	If $iStyles <> BitOR($__REBARCONSTANT_CCS_TOP, $RBS_VARHEIGHT) Then
		$iStyle = BitOR($iStyle, $iStyles)
	Else
		$iStyle = BitOR($iStyle, $__REBARCONSTANT_CCS_TOP, $RBS_VARHEIGHT)
	EndIf

	Local $tICCE = DllStructCreate('dword;dword')
	DllStructSetData($tICCE, 1, DllStructGetSize($tICCE))
	DllStructSetData($tICCE, 2, BitOR($ICC_BAR_CLASSES, $ICC_COOL_CLASSES))

	Local $aResult = DllCall('comctl32.dll', 'int', 'InitCommonControlsEx', 'struct*', $tICCE)
	If @error Then Return SetError(@error, @extended, 0)
	If $aResult[0] = 0 Then Return SetError(-2, 0, 0)

	Local $nCtrlID = __UDF_GetNextGlobalID($hWnd)
	If @error Then Return SetError(@error, @extended, 0)

	Local $hReBar = _WinAPI_CreateWindowEx(0, $__REBARCONSTANT_ClassName, "", $iStyle, 0, 0, 0, 0, $hWnd, $nCtrlID)

	If @error Then Return SetError(-1, -1, 0)
	Return $hReBar
EndFunc   ;==>_GUICtrlRebar_Create

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_DeleteBand
; Description ...: Deletes a band from a rebar control
; Syntax.........: _GUICtrlRebar_DeleteBand($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band to be deleted
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_AddBand, _GUICtrlRebar_AddToolBarBand
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_DeleteBand($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $RB_DELETEBAND, $iIndex) <> 0
EndFunc   ;==>_GUICtrlRebar_DeleteBand

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_Destroy
; Description ...: Delete the control
; Syntax.........: _GUICtrlRebar_Destroy(ByRef $hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True, Handle is set to 0
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Restricted to only be used on control created with _GUICtrlRebar_Create
; Related .......: _GUICtrlRebar_Create
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_Destroy(ByRef $hWnd)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)
	If Not _WinAPI_IsClassName($hWnd, $__REBARCONSTANT_ClassName) Then Return SetError(2, 2, False)

	Local $Destroyed = 0
	If _WinAPI_InProcess($hWnd, $gh_RBLastWnd) Then
		Local $iRebarCount = _GUICtrlRebar_GetBandCount($hWnd)
		For $iIndex = $iRebarCount - 1 To 0 Step -1
			_GUICtrlRebar_DeleteBand($hWnd, $iIndex)
		Next
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
EndFunc   ;==>_GUICtrlRebar_Destroy

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_DragMove
; Description ...: Updates the drag position in the rebar control after a previous _GUICtrlRebar_BeginDrag message
; Syntax.........: _GUICtrlRebar_DragMove($hWnd[, $dwPos = -1])
; Parameters ....: $hWnd       - Handle to rebar control
;                  $dwPos       - DWORD value that contains the new mouse coordinates.
;                  |The horizontal coordinate is contained in the LOWORD and the vertical coordinate is contained in the HIWORD
;                  |If you pass (DWORD)-1, the rebar control will use the position of the mouse the last time the control's thread called GetMessage or PeekMessage
; Return values .:
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_BeginDrag
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_DragMove($hWnd, $dwPos = -1)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	_SendMessage($hWnd, $RB_DRAGMOVE, 0, $dwPos, 0, "wparam", "dword")
EndFunc   ;==>_GUICtrlRebar_DragMove

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_EndDrag
; Description ...: Terminates the rebar control's drag-and-drop operation. This message does not cause an $RBN_ENDDRAG notification to be sent
; Syntax.........: _GUICtrlRebar_EndDrag($hWnd)
; Parameters ....: $hWnd       - Handle to rebar control
; Return values .:
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_BeginDrag
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_EndDrag($hWnd)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	_SendMessage($hWnd, $RB_ENDDRAG)
EndFunc   ;==>_GUICtrlRebar_EndDrag

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandBackColor
; Description ...: Retrieves the Band background color
; Syntax.........: _GUICtrlRebar_GetBandBackColor($hWnd, $iIndex)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
; Return values .: Success      - Band background color
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetBandBackColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandBackColor($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Local $tINFO = __GUICtrlRebar_GetBandInfo($hWnd, $iIndex, $RBBIM_COLORS)
	If @error Then Return SetError(@error, @error, 0)
	Return DllStructGetData($tINFO, "clrBack")
EndFunc   ;==>_GUICtrlRebar_GetBandBackColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandBorders
; Description ...: Retrieves the borders of a band. The result of this message can be used to calculate the usable area in a band
; Syntax.........: _GUICtrlRebar_GetBandBorders($hWnd, $iIndex)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of the band for which the borders will be retrieved
; Return values .: Success      - Array with the following format:
;                  |[0] - X coordinate of the upper left corner of the rectangle
;                  |[1] - Y coordinate of the upper left corner of the rectangle
;                  |[2] - X coordinate of the lower right corner of the rectangle
;                  |[3] - Y coordinate of the lower right corner of the rectangle
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandBordersEx, _GUICtrlRebar_GetBandRect, _GUICtrlRebar_GetBandRectEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandBorders($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Local $tRect = _GUICtrlRebar_GetBandBordersEx($hWnd, $iIndex)
	Local $aRect[4]
	$aRect[0] = DllStructGetData($tRect, "Left")
	$aRect[1] = DllStructGetData($tRect, "Top")
	$aRect[2] = DllStructGetData($tRect, "Right")
	$aRect[3] = DllStructGetData($tRect, "Bottom")
	Return $aRect
EndFunc   ;==>_GUICtrlRebar_GetBandBorders

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandBordersEx
; Description ...: Retrieves the borders of a band. The result of this message can be used to calculate the usable area in a band
; Syntax.........: _GUICtrlRebar_GetBandBordersEx($hWnd, $iIndex)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of the band for which the borders will be retrieved
; Return values .: Success      - $tagRECT structure
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandBorders, _GUICtrlRebar_GetBandRect, _GUICtrlRebar_GetBandRectEx, $tagRECT
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandBordersEx($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Local $tRect = DllStructCreate($tagRECT)
	_SendMessage($hWnd, $RB_GETBANDBORDERS, $iIndex, $tRect, 0, "uint", "struct*")
	Return $tRect
EndFunc   ;==>_GUICtrlRebar_GetBandBordersEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandChildHandle
; Description ...: Retrieves the Handle to the child window contained in the band, if any
; Syntax.........: _GUICtrlRebar_GetBandChildHandle($hWnd, $iIndex)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of the band for which the borders will be retrieved
; Return values .: Success      - Handle to the child window contained in the band
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandChildHandle($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Local $tINFO = __GUICtrlRebar_GetBandInfo($hWnd, $iIndex, $RBBIM_CHILD)
	If @error Then Return SetError(@error, @error, 0)
	Return DllStructGetData($tINFO, "hwndChild")
EndFunc   ;==>_GUICtrlRebar_GetBandChildHandle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandChildSize
; Description ...: Retrieves the Child size settings
; Syntax.........: _GUICtrlRebar_GetBandChildSize($hWnd, $iIndex)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
; Return values .: Success      - Array with the following format:
;                  |[0] - Minimum width of the child window, in pixels.
;                  |[1] - Minimum height of the child window, in pixels.
;                  |[2] - Initial height of the band, in pixels.
;                  |[3] - Maximum height of the band, in pixels.
;                  |[4] - Step value by which the band can grow or shrink, in pixels.
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandChildSize($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)
	Local $aSizes[5]
	Local $tINFO = __GUICtrlRebar_GetBandInfo($hWnd, $iIndex, $RBBIM_CHILDSIZE)
	If @error Then Return SetError(@error, @error, $aSizes)
	$aSizes[0] = DllStructGetData($tINFO, "cxMinChild")
	$aSizes[1] = DllStructGetData($tINFO, "cyMinChild")
	$aSizes[2] = DllStructGetData($tINFO, "cyChild")
	$aSizes[3] = DllStructGetData($tINFO, "cyMaxChild")
	$aSizes[4] = DllStructGetData($tINFO, "cyIntegral")

	Return $aSizes
EndFunc   ;==>_GUICtrlRebar_GetBandChildSize

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandCount
; Description ...: Retrieves the count of bands currently in the rebar control
; Syntax.........: _GUICtrlRebar_GetBandCount($hWnd)
; Parameters ....: $hWnd       - Handle to rebar control
; Return values .: Success      - The number of bands assigned to the control
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandCount($hWnd)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $RB_GETBANDCOUNT)
EndFunc   ;==>_GUICtrlRebar_GetBandCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandForeColor
; Description ...: Retrieves the Band foreground color
; Syntax.........: _GUICtrlRebar_GetBandForeColor($hWnd, $iIndex)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
; Return values .: Success      - Band foreground color
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetBandForeColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandForeColor($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Local $tINFO = __GUICtrlRebar_GetBandInfo($hWnd, $iIndex, $RBBIM_COLORS)
	If @error Then Return SetError(@error, @error, 0)
	Return DllStructGetData($tINFO, "clrFore")
EndFunc   ;==>_GUICtrlRebar_GetBandForeColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandHeaderSize
; Description ...: Retrieves the size of the band's header, in pixels
; Syntax.........: _GUICtrlRebar_GetBandHeaderSize($hWnd, $iIndex)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
; Return values .: Success      - Size of the band's header
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetBandHeaderSize
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandHeaderSize($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Local $tINFO = __GUICtrlRebar_GetBandInfo($hWnd, $iIndex, $RBBIM_HEADERSIZE)
	If @error Then Return SetError(@error, @error, 0)
	Return DllStructGetData($tINFO, "cxHeader")
EndFunc   ;==>_GUICtrlRebar_GetBandHeaderSize

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandID
; Description ...: Get the value that the control uses to identify this band for custom draw notification messages
; Syntax.........: _GUICtrlRebar_GetBandID($hWnd, $iIndex)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
; Return values .: Success      - id of the band
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetBandID
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandID($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Local $tINFO = __GUICtrlRebar_GetBandInfo($hWnd, $iIndex, $RBBIM_ID)
	If @error Then Return SetError(@error, @error, 0)
	Return DllStructGetData($tINFO, "wID")
EndFunc   ;==>_GUICtrlRebar_GetBandID

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandIdealSize
; Description ...: Get Ideal width of the band, in pixels.
; Syntax.........: _GUICtrlRebar_GetBandIdealSize($hWnd, $iIndex)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
; Return values .: Success      - ideal width of the band
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: If the band is maximized to the ideal width (see _GUICtrlRebar_MaximizeBand), the rebar control will attempt to make the band this width.
; Related .......: _GUICtrlRebar_SetBandIdealSize, _GUICtrlRebar_MaximizeBand
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandIdealSize($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Local $tINFO = __GUICtrlRebar_GetBandInfo($hWnd, $iIndex, $RBBIM_IDEALSIZE)
	If @error Then Return SetError(@error, @error, 0)
	Return DllStructGetData($tINFO, "cxIdeal")
EndFunc   ;==>_GUICtrlRebar_GetBandIdealSize

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlRebar_GetBandInfo
; Description ...: Get Ideal width of the band, in pixels.
; Syntax.........: __GUICtrlRebar_GetBandInfo($hWnd, $iIndex, $fMask)
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
;                  $fMask       - Flags that indicate which members of this structure are valid
; Return values .: Success      - $tagREBARBANDINFO structure
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func __GUICtrlRebar_GetBandInfo($hWnd, $iIndex, $fMask)
	Local $tINFO = DllStructCreate($tagREBARBANDINFO)
	Local $iSize = DllStructGetSize($tINFO)
	DllStructSetData($tINFO, "cbSize", $iSize)
	DllStructSetData($tINFO, "fMask", $fMask)

	Local $iRet = _SendMessage($hWnd, $RB_GETBANDINFOW, $iIndex, $tINFO, 0, "wparam", "struct*")

	Return SetError($iRet = 0, 0, $tINFO)
EndFunc   ;==>__GUICtrlRebar_GetBandInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandLParam
; Description ...: Get Application-defined value
; Syntax.........: _GUICtrlRebar_GetBandLParam($hWnd, $iIndex)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
; Return values .: Success      - Application-defined value
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetBandLParam
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandLParam($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Local $tINFO = __GUICtrlRebar_GetBandInfo($hWnd, $iIndex, $RBBIM_LPARAM)
	If @error Then Return SetError(@error, @error, 0)
	Return DllStructGetData($tINFO, "lParam")
EndFunc   ;==>_GUICtrlRebar_GetBandLParam

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandLength
; Description ...: Get Length of the band, in pixels
; Syntax.........: _GUICtrlRebar_GetBandLength($hWnd, $iIndex)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
; Return values .: Success      - Length of the band, in pixels
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetBandLength
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandLength($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Local $tINFO = __GUICtrlRebar_GetBandInfo($hWnd, $iIndex, $RBBIM_SIZE)
	If @error Then Return SetError(@error, @error, 0)
	Return DllStructGetData($tINFO, "cx")
EndFunc   ;==>_GUICtrlRebar_GetBandLength

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandMargins
; Description ...: Get Length of the band, in pixels
; Syntax.........: _GUICtrlRebar_GetBandMargins($hWnd)
; Parameters ....: $hWnd       - Handle to rebar control
; Return values .: Success      - Array in the following:
;                  |[0] - Width of the left border that retains its size
;                  |[1] - Width of the right border that retains its size
;                  |[2] - Height of the top border that retains its size
;                  |[3] - Height of the bottom border that retains its size
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Minimum OS - Windows XP
; Related .......: _GUICtrlRebar_GetBandMarginsEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandMargins($hWnd)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Local $tMargins = _GUICtrlRebar_GetBandMarginsEx($hWnd)
	Local $aMargins[4]
	$aMargins[0] = DllStructGetData($tMargins, "cxLeftWidth")
	$aMargins[1] = DllStructGetData($tMargins, "cxRightWidth")
	$aMargins[2] = DllStructGetData($tMargins, "cyTopHeight")
	$aMargins[3] = DllStructGetData($tMargins, "cyBottomHeight")
	Return $aMargins
EndFunc   ;==>_GUICtrlRebar_GetBandMargins

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandMarginsEx
; Description ...: Get Length of the band, in pixels
; Syntax.........: _GUICtrlRebar_GetBandMarginsEx($hWnd)
; Parameters ....: $hWnd       - Handle to rebar control
; Return values .: Success     - $tagMARGINS structure
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Minimum OS - Windows XP
; Related .......: _GUICtrlRebar_GetBandMargins, $tagMARGINS
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandMarginsEx($hWnd)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Local $tMargins = DllStructCreate($tagMARGINS)

	_SendMessage($hWnd, $RB_GETBANDMARGINS, 0, $tMargins, 0, "wparam", "struct*")
	Return $tMargins
EndFunc   ;==>_GUICtrlRebar_GetBandMarginsEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandStyle
; Description ...: Get the band style Flags
; Syntax.........: _GUICtrlRebar_GetBandStyle($hWnd, $iIndex)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
; Return values .: Success      - A value of band flags, see fStyle of $tagREBARBANDINFO
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetBandStyle, $tagREBARBANDINFO, _GUICtrlRebar_GetBandStyleBreak, _GUICtrlRebar_GetBandStyleChildEdge, _GUICtrlRebar_GetBandStyleFixedBMP, _GUICtrlRebar_GetBandStyleFixedSize, _GUICtrlRebar_GetBandStyleGripperAlways, _GUICtrlRebar_GetBandStyleHidden, _GUICtrlRebar_GetBandStyleHideTitle, _GUICtrlRebar_GetBandStyleNoGripper, _GUICtrlRebar_GetBandStyleTopAlign, _GUICtrlRebar_GetBandStyleUseChevron, _GUICtrlRebar_GetBandStyleVariableHeight
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandStyle($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Local $tINFO = __GUICtrlRebar_GetBandInfo($hWnd, $iIndex, $RBBIM_STYLE)
	If @error Then Return SetError(@error, @error, 0)
	Return DllStructGetData($tINFO, "fStyle")
EndFunc   ;==>_GUICtrlRebar_GetBandStyle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandStyleBreak
; Description ...: Determine if flag is set
; Syntax.........: _GUICtrlRebar_GetBandStyleBreak($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
; Return values .:  True        - Flag is set (The band is on a new line)
;                  False        - Flag not set
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetBandStyleBreak, _GUICtrlRebar_GetBandStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandStyleBreak($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return BitAND(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_BREAK) = $RBBS_BREAK
EndFunc   ;==>_GUICtrlRebar_GetBandStyleBreak

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandStyleChildEdge
; Description ...: Determine if flag is set
; Syntax.........: _GUICtrlRebar_GetBandStyleChildEdge($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
; Return values .:  True        - Flag is set (The band has an edge at the top and bottom of the child window)
;                  False        - Flag not set
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetBandStyleChildEdge, _GUICtrlRebar_GetBandStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandStyleChildEdge($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return BitAND(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_CHILDEDGE) = $RBBS_CHILDEDGE
EndFunc   ;==>_GUICtrlRebar_GetBandStyleChildEdge

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandStyleFixedBMP
; Description ...: Determine if flag is set
; Syntax.........: _GUICtrlRebar_GetBandStyleFixedBMP($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
; Return values .:  True        - Flag is set (The background bitmap does not move when the band is resized)
;                  False        - Flag not set
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetBandStyleFixedBMP, _GUICtrlRebar_GetBandStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandStyleFixedBMP($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return BitAND(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_FIXEDBMP) = $RBBS_FIXEDBMP
EndFunc   ;==>_GUICtrlRebar_GetBandStyleFixedBMP

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandStyleFixedSize
; Description ...: Determine if flag is set
; Syntax.........: _GUICtrlRebar_GetBandStyleFixedSize($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
; Return values .:  True        - Flag is set (The band can't be sized. With this style, the sizing grip is not displayed on the band)
;                  False        - Flag not set
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetBandStyleFixedSize, _GUICtrlRebar_GetBandStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandStyleFixedSize($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return BitAND(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_FIXEDSIZE) = $RBBS_FIXEDSIZE
EndFunc   ;==>_GUICtrlRebar_GetBandStyleFixedSize

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandStyleGripperAlways
; Description ...: Determine if flag is set
; Syntax.........: _GUICtrlRebar_GetBandStyleGripperAlways($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
; Return values .:  True        - Flag is set (The band will always have a sizing grip, even if it is the only band in the rebar)
;                  False        - Flag not set
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetBandStyleGripperAlways, _GUICtrlRebar_GetBandStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandStyleGripperAlways($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return BitAND(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_GRIPPERALWAYS) = $RBBS_GRIPPERALWAYS
EndFunc   ;==>_GUICtrlRebar_GetBandStyleGripperAlways

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandStyleHidden
; Description ...: Determine if flag is set
; Syntax.........: _GUICtrlRebar_GetBandStyleHidden($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
; Return values .:  True        - Flag is set (The band will not be visible)
;                  False        - Flag not set
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetBandStyleHidden, _GUICtrlRebar_GetBandStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandStyleHidden($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return BitAND(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_HIDDEN) = $RBBS_HIDDEN
EndFunc   ;==>_GUICtrlRebar_GetBandStyleHidden

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandStyleHideTitle
; Description ...: Determine if flag is set
; Syntax.........: _GUICtrlRebar_GetBandStyleHideTitle($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
; Return values .:  True        - Flag is set (Keep band title hidden)
;                  False        - Flag not set
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetBandStyleHideTitle, _GUICtrlRebar_GetBandStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandStyleHideTitle($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return BitAND(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_HIDETITLE) = $RBBS_HIDETITLE
EndFunc   ;==>_GUICtrlRebar_GetBandStyleHideTitle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandStyleNoGripper
; Description ...: Determine if flag is set
; Syntax.........: _GUICtrlRebar_GetBandStyleNoGripper($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
; Return values .:  True        - Flag is set (The band will never have a sizing grip, even if there is more than one band in the rebar)
;                  False        - Flag not set
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetBandStyleNoGripper, _GUICtrlRebar_GetBandStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandStyleNoGripper($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return BitAND(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_NOGRIPPER) = $RBBS_NOGRIPPER
EndFunc   ;==>_GUICtrlRebar_GetBandStyleNoGripper

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlRebar_GetBandStyleNoVert
; Description ...: Determine if flag is set
; Syntax.........: _GUICtrlRebar_GetBandStyleNoVert($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
; Return values .:  True        - Flag is set (Don't show when vertical)
;                  False        - Flag not set
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetBandStyleNoVert, _GUICtrlRebar_GetBandStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandStyleNoVert($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return BitAND(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_NOVERT) = $RBBS_NOVERT
EndFunc   ;==>_GUICtrlRebar_GetBandStyleNoVert

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandStyleTopAlign
; Description ...: Determine if flag is set
; Syntax.........: _GUICtrlRebar_GetBandStyleTopAlign($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
; Return values .:  True        - Flag is set (Keep band in top row)
;                  False        - Flag not set
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetBandStyleTopAlign, _GUICtrlRebar_GetBandStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandStyleTopAlign($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return BitAND(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_TOPALIGN) = $RBBS_TOPALIGN
EndFunc   ;==>_GUICtrlRebar_GetBandStyleTopAlign

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandStyleUseChevron
; Description ...: Determine if flag is set
; Syntax.........: _GUICtrlRebar_GetBandStyleUseChevron($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
; Return values .:  True        - Flag is set (Display drop-down button)
;                  False        - Flag not set
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetBandStyleUseChevron, _GUICtrlRebar_GetBandStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandStyleUseChevron($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return BitAND(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_USECHEVRON) = $RBBS_USECHEVRON
EndFunc   ;==>_GUICtrlRebar_GetBandStyleUseChevron

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandStyleVariableHeight
; Description ...: Determine if flag is set
; Syntax.........: _GUICtrlRebar_GetBandStyleVariableHeight($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
; Return values .:  True        - Flag is set (The band can be resized by the rebar control)
;                  False        - Flag not set
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetBandStyleVariableHeight, _GUICtrlRebar_GetBandStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandStyleVariableHeight($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return BitAND(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_VARIABLEHEIGHT) = $RBBS_VARIABLEHEIGHT
EndFunc   ;==>_GUICtrlRebar_GetBandStyleVariableHeight

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandRect
; Description ...: Retrieves the bounding rectangle for a given band in a rebar control
; Syntax.........: _GUICtrlRebar_GetBandRect($hWnd, $iIndex)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of a band in the rebar control
; Return values .: Success      - Array with the following format:
;                  |[0] - X coordinate of the upper left corner of the rectangle
;                  |[1] - Y coordinate of the upper left corner of the rectangle
;                  |[2] - X coordinate of the lower right corner of the rectangle
;                  |[3] - Y coordinate of the lower right corner of the rectangle
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandRectEx, _GUICtrlRebar_GetBandBorders, _GUICtrlRebar_GetBandBordersEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandRect($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Local $tRect = _GUICtrlRebar_GetBandRectEx($hWnd, $iIndex)
	Local $aRect[4]
	$aRect[0] = DllStructGetData($tRect, "Left")
	$aRect[1] = DllStructGetData($tRect, "Top")
	$aRect[2] = DllStructGetData($tRect, "Right")
	$aRect[3] = DllStructGetData($tRect, "Bottom")
	Return $aRect
EndFunc   ;==>_GUICtrlRebar_GetBandRect

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandRectEx
; Description ...: Retrieves the bounding rectangle for a given band in a rebar control
; Syntax.........: _GUICtrlRebar_GetBandRectEx($hWnd, $iIndex)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of a band in the rebar control
; Return values .: Success      - $tagRECT structure
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandRect, _GUICtrlRebar_GetBandBorders, _GUICtrlRebar_GetBandBordersEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandRectEx($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Local $tRect = DllStructCreate($tagRECT)
	_SendMessage($hWnd, $RB_GETRECT, $iIndex, $tRect, 0, "uint", "struct*")
	Return $tRect
EndFunc   ;==>_GUICtrlRebar_GetBandRectEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBandText
; Description ...: Retrieves the display text for the band
; Syntax.........: _GUICtrlRebar_GetBandText($hWnd, $iIndex)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of the band for which the information will be retrieved
; Return values .: Success      - display text for the band
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetBandText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBandText($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlRebar_GetUnicodeFormat($hWnd)

	Local $tINFO = DllStructCreate($tagREBARBANDINFO)
	Local $iSize = DllStructGetSize($tINFO)
	Local $tBuffer
	Local $iBuffer = 4096
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Buffer[4096]")
		$iBuffer *= 2
	Else
		$tBuffer = DllStructCreate("char Buffer[4096]")
	EndIf

	DllStructSetData($tINFO, "cbSize", $iSize)
	DllStructSetData($tINFO, "fMask", $RBBIM_TEXT)
	DllStructSetData($tINFO, "cch", $iBuffer)

	Local $tMemMap
	Local $pMemory = _MemInit($hWnd, $iSize + $iBuffer, $tMemMap)
	Local $pText = $pMemory + $iSize
	DllStructSetData($tINFO, "lpText", $pText)
	_MemWrite($tMemMap, $tINFO, $pMemory, $iSize)
	Local $iRet
	If $fUnicode Then
		$iRet = _SendMessage($hWnd, $RB_GETBANDINFOW, $iIndex, $pMemory, 0, "wparam", "ptr")
	Else
		$iRet = _SendMessage($hWnd, $RB_GETBANDINFOA, $iIndex, $pMemory, 0, "wparam", "ptr")
	EndIf
	_MemRead($tMemMap, $pText, $tBuffer, $iBuffer)
	_MemFree($tMemMap)

	Return SetError($iRet = 0, 0, DllStructGetData($tBuffer, "Buffer"))
EndFunc   ;==>_GUICtrlRebar_GetBandText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBarHeight
; Description ...: Retrieves the height of the rebar control
; Syntax.........: _GUICtrlRebar_GetBarHeight($hWnd)
; Parameters ....: $hWnd       - Handle to rebar control
; Return values .: Success      - Value that represents the height, in pixels, of the control
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBarHeight($hWnd)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $RB_GETBARHEIGHT)
EndFunc   ;==>_GUICtrlRebar_GetBarHeight

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBarInfo
; Description ...: Retrieves information about the rebar control and the image list it uses
; Syntax.........: _GUICtrlRebar_GetBarInfo($hWnd)
; Parameters ....: $hWnd       - Handle to rebar control
; Return values .: Success      - Handle to an image list. The rebar control will use the specified image list to obtain images
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Currently, rebar controls support only image list handle
; Related .......: _GUICtrlRebar_SetBarInfo
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBarInfo($hWnd)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Local $tINFO = DllStructCreate($tagREBARINFO)

	DllStructSetData($tINFO, "cbSize", DllStructGetSize($tINFO))
	DllStructSetData($tINFO, "fMask", $RBIM_IMAGELIST)
	Local $iRet = _SendMessage($hWnd, $RB_GETBARINFO, 0, $tINFO, 0, "wparam", "struct*")

	Return SetError($iRet = 0, 0, DllStructGetData($tINFO, "himl"))
EndFunc   ;==>_GUICtrlRebar_GetBarInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetBKColor
; Description ...: Retrieves a rebar control's default background color
; Syntax.........: _GUICtrlRebar_GetBKColor($hWnd)
; Parameters ....: $hWnd       - Handle to rebar control
; Return values .: Success      -  A COLORREF value that represent the current default background color
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetBKColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetBKColor($hWnd)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $RB_GETBKCOLOR)
EndFunc   ;==>_GUICtrlRebar_GetBKColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetColorScheme
; Description ...: Retrieves the color scheme information from the rebar control
; Syntax.........: _GUICtrlRebar_GetColorScheme($hWnd)
; Parameters ....: $hWnd       - Handle to rebar control
; Return values .: Success      -  Array of the following:
;                  |[0] - The COLORREF value that represents the highlight color of the buttons
;                  |[1] - The COLORREF value that represents the shadow color of the buttons
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetColorScheme
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetColorScheme($hWnd)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Local $aColors[2]
	Local $tColorScheme = __GUICtrlRebar_GetColorSchemeEx($hWnd)
	If @error Then Return SetError(@error, @error, $aColors)
	$aColors[0] = DllStructGetData($tColorScheme, "BtnHighlight")
	$aColors[1] = DllStructGetData($tColorScheme, "BtnShadow")
	Return $aColors
EndFunc   ;==>_GUICtrlRebar_GetColorScheme

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlRebar_GetColorSchemeEx
; Description ...: Retrieves the color scheme information from the rebar control
; Syntax.........: __GUICtrlRebar_GetColorSchemeEx($hWnd)
; Parameters ....: $hWnd       - Handle to rebar control
; Return values .: Success      -  $tagCOLORSCHEME structure
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetColorScheme, $tagCOLORSCHEME
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func __GUICtrlRebar_GetColorSchemeEx($hWnd)
	Local $tColorScheme = DllStructCreate($tagCOLORSCHEME)
	DllStructSetData($tColorScheme, "Size", DllStructGetSize($tColorScheme))
	Local $iRet = _SendMessage($hWnd, $RB_GETCOLORSCHEME, 0, $tColorScheme, 0, "wparam", "struct*")
	Return SetError($iRet = 0, 0, $tColorScheme)
EndFunc   ;==>__GUICtrlRebar_GetColorSchemeEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetRowCount
; Description ...: Retrieves the number of rows of bands in a rebar control
; Syntax.........: _GUICtrlRebar_GetRowCount($hWnd)
; Parameters ....: $hWnd       - Handle to rebar control
; Return values .: Success      -  A value that represents the number of band rows in the control
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetRowCount($hWnd)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $RB_GETROWCOUNT)
EndFunc   ;==>_GUICtrlRebar_GetRowCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetRowHeight
; Description ...: Retrieves the height of a specified row in a rebar control
; Syntax.........: _GUICtrlRebar_GetRowHeight($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of a band. The height of the row that contains the specified band will be retrieved
; Return values .: Success      -  A value that represents the row height, in pixels
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetRowHeight($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $RB_GETROWHEIGHT, $iIndex)
EndFunc   ;==>_GUICtrlRebar_GetRowHeight

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetTextColor
; Description ...: Retrieves a rebar control's default text color
; Syntax.........: _GUICtrlRebar_GetTextColor($hWnd)
; Parameters ....: $hWnd       - Handle to rebar control
; Return values .: Success      -  A value that represent the current default text color
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetTextColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetTextColor($hWnd)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $RB_GETTEXTCOLOR)
EndFunc   ;==>_GUICtrlRebar_GetTextColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetToolTips
; Description ...: Retrieves the handle to any ToolTip control associated with the rebar control
; Syntax.........: _GUICtrlRebar_GetToolTips($hWnd)
; Parameters ....: $hWnd       - Handle to rebar control
; Return values .: Success      -  The handle to the ToolTip control associated with the rebar control
;                  |Or zero if no ToolTip control is associated with the rebar control
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetToolTips
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetToolTips($hWnd)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $RB_GETTOOLTIPS, 0, 0, 0, "wparam", "lparam", "hwnd")
EndFunc   ;==>_GUICtrlRebar_GetToolTips

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_GetUnicodeFormat
; Description ...: Retrieves the Unicode character format flag for the control
; Syntax.........: _GUICtrlRebar_GetUnicodeFormat($hWnd)
; Parameters ....: $hWnd       - Handle to rebar control
; Return values .:  True       - The control is using Unicode characters
;                  False       - The control is using ANSI characters
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetUnicodeFormat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_GetUnicodeFormat($hWnd)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $RB_GETUNICODEFORMAT) <> 0
EndFunc   ;==>_GUICtrlRebar_GetUnicodeFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_HitTest
; Description ...: Determines which item is at a specified position
; Syntax.........: _GUICtrlRebar_HitTest($hWnd[, $iX = -1[, $iY = -1]])
; Parameters ....: $hWnd        - Handle to the control
;                  $iX          - X position, in client coordinates, to be tested or -1 to use the current mouse position
;                  $iY          - Y position, in client coordinates, to be tested or -1 to use the current mouse position
; Return values .: Success      - Array with the following format:
;                  |[0] - Zero based index of the band at the specified position, or -1
;                  |[1] - If True, position is in control's client window but not on an band
;                  |[2] - If True, position is in control's client window
;                  |[3] - If True, position is over the rebar band's caption
;                  |[4] - If True, position is over the rebar band's chevron (version 5.80 and greater)
;                  |[5] - If True, position is over the rebar band's gripper
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_HitTest($hWnd, $iX = -1, $iY = -1)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Local $iMode = Opt("MouseCoordMode", 1)
	Local $aPos = MouseGetPos()
	Opt("MouseCoordMode", $iMode)
	Local $tPoint = DllStructCreate($tagPOINT)
	DllStructSetData($tPoint, "X", $aPos[0])
	DllStructSetData($tPoint, "Y", $aPos[1])
	DllCall("user32.dll", "bool", "ScreenToClient", "hwnd", $hWnd, "struct*", $tPoint)
	If @error Then Return SetError(@error, @extended, 0)

	If $iX = -1 Then $iX = DllStructGetData($tPoint, "X")
	If $iY = -1 Then $iY = DllStructGetData($tPoint, "Y")

	Local $tTest = DllStructCreate($tagRBHITTESTINFO)
	DllStructSetData($tTest, "X", $iX)
	DllStructSetData($tTest, "Y", $iY)
	Local $iTest = DllStructGetSize($tTest)
	Local $tMemMap, $aTest[6]
	Local $pMemory = _MemInit($hWnd, $iTest, $tMemMap)
	_MemWrite($tMemMap, $tTest, $pMemory, $iTest)
	$aTest[0] = _SendMessage($hWnd, $RB_HITTEST, 0, $pMemory, 0, "wparam", "ptr")
	_MemRead($tMemMap, $pMemory, $tTest, $iTest)
	_MemFree($tMemMap)
	Local $iFlags = DllStructGetData($tTest, "flags")
	$aTest[1] = BitAND($iFlags, $RBHT_NOWHERE) <> 0
	$aTest[2] = BitAND($iFlags, $RBHT_CLIENT) <> 0
	$aTest[3] = BitAND($iFlags, $RBHT_CAPTION) <> 0
	$aTest[4] = BitAND($iFlags, $RBHT_CHEVRON) <> 0
	$aTest[5] = BitAND($iFlags, $RBHT_GRABBER) <> 0
	Return $aTest
EndFunc   ;==>_GUICtrlRebar_HitTest

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_IDToIndex
; Description ...: Converts a band identifier to a band index in a rebar control
; Syntax.........: _GUICtrlRebar_IDToIndex($hWnd, $iID)
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iID         - The application-defined identifier of the band in question
; Return values .: Success      - zero-based band index
;                  Failure      - -1
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: If duplicate band identifiers exist, the first one is returned
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_IDToIndex($hWnd, $iID)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $RB_IDTOINDEX, $iID)
EndFunc   ;==>_GUICtrlRebar_IDToIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_MaximizeBand
; Description ...: Resizes a band in a rebar control to either its ideal or largest size
; Syntax.........: _GUICtrlRebar_MaximizeBand($hWnd, $iIndex[, $fIdeal = True])
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
;                  $fIdeal      - Indicates if the ideal width of the band should be used when the band is maximized
; Return values .:
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandIdealSize
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_MaximizeBand($hWnd, $iIndex, $fIdeal = True)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	_SendMessage($hWnd, $RB_MAXIMIZEBAND, $iIndex, $fIdeal)
EndFunc   ;==>_GUICtrlRebar_MaximizeBand

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_MinimizeBand
; Description ...: Resizes a band in a rebar control to its smallest size
; Syntax.........: _GUICtrlRebar_MinimizeBand($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
; Return values .:
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_MinimizeBand($hWnd, $iIndex)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	_SendMessage($hWnd, $RB_MINIMIZEBAND, $iIndex)
EndFunc   ;==>_GUICtrlRebar_MinimizeBand

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_MoveBand
; Description ...: Moves a band from one index to another
; Syntax.........: _GUICtrlRebar_MoveBand($hWnd, $iIndexFrom, $iIndexTo)
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndexFrom  - Zero-based index of the band to be moved
;                  $iIndexTo    - Zero-based index of the new band position
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: This message will most likely change the index of other bands in the rebar control.
;                  If a band is moved from index 6 to index 0, all of the bands in between will have their index incremented by one.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_MoveBand($hWnd, $iIndexFrom, $iIndexTo)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	If $iIndexTo > _GUICtrlRebar_GetBandCount($hWnd) - 1 Then Return False
	Return _SendMessage($hWnd, $RB_MOVEBAND, $iIndexFrom, $iIndexTo) <> 0
EndFunc   ;==>_GUICtrlRebar_MoveBand

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetBandBackColor
; Description ...: Set the Band background color
; Syntax.........: _GUICtrlRebar_SetBandBackColor($hWnd, $iIndex, $iColor)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
;                  $iColor      - New color for band background
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandBackColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetBandBackColor($hWnd, $iIndex, $iColor)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Local $tINFO = DllStructCreate($tagREBARBANDINFO)
	Local $iSize = DllStructGetSize($tINFO)

	DllStructSetData($tINFO, "cbSize", $iSize)
	DllStructSetData($tINFO, "fMask", $RBBIM_COLORS)
	DllStructSetData($tINFO, "clrBack", $iColor)
	DllStructGetData($tINFO, "clrFore", _GUICtrlRebar_GetBandForeColor($hWnd, $iIndex))

	Local $iRet, $tMemMap
	Local $pMemory = _MemInit($hWnd, $iSize, $tMemMap)
	_MemWrite($tMemMap, $tINFO, $pMemory, $iSize)
	If _GUICtrlRebar_GetUnicodeFormat($hWnd) Then
		$iRet = _SendMessage($hWnd, $RB_SETBANDINFOW, $iIndex, $pMemory, 0, "wparam", "ptr") <> 0
	Else
		$iRet = _SendMessage($hWnd, $RB_SETBANDINFOA, $iIndex, $pMemory, 0, "wparam", "ptr") <> 0
	EndIf
	_MemFree($tMemMap)
	Return $iRet
EndFunc   ;==>_GUICtrlRebar_SetBandBackColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetBandForeColor
; Description ...: Set the Band foreground color
; Syntax.........: _GUICtrlRebar_SetBandForeColor($hWnd, $iIndex, $iColor)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
;                  $iColor      - New color for band foreground
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandForeColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetBandForeColor($hWnd, $iIndex, $iColor)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Local $tINFO = DllStructCreate($tagREBARBANDINFO)
	Local $iSize = DllStructGetSize($tINFO)

	DllStructSetData($tINFO, "cbSize", $iSize)
	DllStructSetData($tINFO, "fMask", $RBBIM_COLORS)
	DllStructSetData($tINFO, "clrFore", $iColor)
	DllStructSetData($tINFO, "clrBack", _GUICtrlRebar_GetBandBackColor($hWnd, $iIndex))

	Local $iRet, $tMemMap
	Local $pMemory = _MemInit($hWnd, $iSize, $tMemMap)
	_MemWrite($tMemMap, $tINFO, $pMemory, $iSize)
	If _GUICtrlRebar_GetUnicodeFormat($hWnd) Then
		$iRet = _SendMessage($hWnd, $RB_SETBANDINFOW, $iIndex, $pMemory, 0, "wparam", "ptr") <> 0
	Else
		$iRet = _SendMessage($hWnd, $RB_SETBANDINFOA, $iIndex, $pMemory, 0, "wparam", "ptr") <> 0
	EndIf
	_MemFree($tMemMap)
	Return $iRet
EndFunc   ;==>_GUICtrlRebar_SetBandForeColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetBandHeaderSize
; Description ...: Set the size of the band's header, in pixels
; Syntax.........: _GUICtrlRebar_SetBandHeaderSize($hWnd, $iIndex, $iNewSize)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
;                  $iNewSize    - New size of the band's header
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandHeaderSize
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetBandHeaderSize($hWnd, $iIndex, $iNewSize)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_HEADERSIZE, "cxHeader", $iNewSize)
EndFunc   ;==>_GUICtrlRebar_SetBandHeaderSize

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetBandID
; Description ...: Set the value that the control uses to identify this band for custom draw notification messages
; Syntax.........: _GUICtrlRebar_SetBandID($hWnd, $iIndex, $iID)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
;                  $iID         - value that the control uses to identify this band for custom draw notification messages
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandID
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetBandID($hWnd, $iIndex, $iID)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_ID, "wID", $iID)
EndFunc   ;==>_GUICtrlRebar_SetBandID

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetBandIdealSize
; Description ...: Set Ideal width of the band, in pixels.
; Syntax.........: _GUICtrlRebar_SetBandIdealSize($hWnd, $iIndex, $iNewSize)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
;                  $iNewSize    - Ideal width of the band, in pixels
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandIdealSize
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetBandIdealSize($hWnd, $iIndex, $iNewSize)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_IDEALSIZE, "cxIdeal", $iNewSize)
EndFunc   ;==>_GUICtrlRebar_SetBandIdealSize

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlRebar_SetBandInfo
; Description ...: Set Ideal width of the band, in pixels.
; Syntax.........: __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $fMask, $sName, $iData)
; Parameters ....: $hWnd     - Handle to rebar control
;                  $iIndex   - Zero-based index of the band
;                  $fMask    - Flags that indicate which members of this structure are valid or must be filled
;                  $sName    - Name of the member
;                  $iData    - Data for the member
; Return values .: Success   - True
;                  Failure   - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: __GUICtrlRebar_GetBandInfo
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $fMask, $sName, $iData)
	Local $tINFO = DllStructCreate($tagREBARBANDINFO)
	Local $iSize = DllStructGetSize($tINFO)

	DllStructSetData($tINFO, "cbSize", $iSize)
	DllStructSetData($tINFO, "fMask", $fMask)
	DllStructSetData($tINFO, $sName, $iData)

	Local $iRet, $tMemMap
	Local $pMemory = _MemInit($hWnd, $iSize, $tMemMap)
	_MemWrite($tMemMap, $tINFO, $pMemory, $iSize)
	If _GUICtrlRebar_GetUnicodeFormat($hWnd) Then
		$iRet = _SendMessage($hWnd, $RB_SETBANDINFOW, $iIndex, $pMemory, 0, "wparam", "ptr") <> 0
	Else
		$iRet = _SendMessage($hWnd, $RB_SETBANDINFOA, $iIndex, $pMemory, 0, "wparam", "ptr") <> 0
	EndIf
	_MemFree($tMemMap)
	Return $iRet
EndFunc   ;==>__GUICtrlRebar_SetBandInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetBandLength
; Description ...: Set Application-defined value
; Syntax.........: _GUICtrlRebar_SetBandLength($hWnd, $iIndex, $icx)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
;                  $icx         - Length of the band, in pixels
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandLength
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetBandLength($hWnd, $iIndex, $icx)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_SIZE, "cx", $icx)
EndFunc   ;==>_GUICtrlRebar_SetBandLength

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetBandLParam
; Description ...: Set Application-defined value
; Syntax.........: _GUICtrlRebar_SetBandLParam($hWnd, $iIndex, $ilParam)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
;                  $ilParam    - Application-defined value
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandLParam
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetBandLParam($hWnd, $iIndex, $ilParam)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_LPARAM, "lParam", $ilParam)
EndFunc   ;==>_GUICtrlRebar_SetBandLParam

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetBandStyle
; Description ...: Set the band style Flags
; Syntax.........: _GUICtrlRebar_SetBandStyle($hWnd, $iIndex, $fStyle)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
;                  $fStyle      - see $tagREBARBANDINFO
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandStyle, $tagREBARBANDINFO, _GUICtrlRebar_SetBandStyleBreak, _GUICtrlRebar_SetBandStyleChildEdge, _GUICtrlRebar_SetBandStyleFixedBMP, _GUICtrlRebar_SetBandStyleFixedSize, _GUICtrlRebar_SetBandStyleGripperAlways, _GUICtrlRebar_SetBandStyleHidden, _GUICtrlRebar_SetBandStyleHideTitle, _GUICtrlRebar_SetBandStyleNoGripper, _GUICtrlRebar_SetBandStyleTopAlign, _GUICtrlRebar_SetBandStyleUseChevron, _GUICtrlRebar_SetBandStyleVariableHeight
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetBandStyle($hWnd, $iIndex, $fStyle)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", $fStyle)
EndFunc   ;==>_GUICtrlRebar_SetBandStyle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetBandStyleBreak
; Description ...: Set whether the band is on a new line
; Syntax.........: _GUICtrlRebar_SetBandStyleBreak($hWnd, $iIndex[, $fEnabled = True])
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
;                  $fEnabled    - If True the item state is set, otherwise it is not set
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandStyleBreak, _GUICtrlRebar_SetBandStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetBandStyleBreak($hWnd, $iIndex, $fEnabled = True)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	If $fEnabled Then
		Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", BitOR(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_BREAK))
	Else
		Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", BitXOR(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_BREAK))
	EndIf
EndFunc   ;==>_GUICtrlRebar_SetBandStyleBreak

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetBandStyleChildEdge
; Description ...: Set whether the band has an edge at the top and bottom of the child window
; Syntax.........: _GUICtrlRebar_SetBandStyleChildEdge($hWnd, $iIndex[, $fEnabled = True])
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
;                  $fEnabled    - If True the item state is set, otherwise it is not set
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandStyleChildEdge, _GUICtrlRebar_SetBandStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetBandStyleChildEdge($hWnd, $iIndex, $fEnabled = True)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	If $fEnabled Then
		Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", BitOR(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_CHILDEDGE))
	Else
		Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", BitXOR(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_CHILDEDGE))
	EndIf
EndFunc   ;==>_GUICtrlRebar_SetBandStyleChildEdge

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetBandStyleFixedBMP
; Description ...: Set whether the band background bitmap does not move when the band is resized
; Syntax.........: _GUICtrlRebar_SetBandStyleFixedBMP($hWnd, $iIndex[, $fEnabled = True])
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
;                  $fEnabled    - If True the item state is set, otherwise it is not set
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandStyleFixedBMP, _GUICtrlRebar_SetBandStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetBandStyleFixedBMP($hWnd, $iIndex, $fEnabled = True)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	If $fEnabled Then
		Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", BitOR(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_FIXEDBMP))
	Else
		Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", BitXOR(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_FIXEDBMP))
	EndIf
EndFunc   ;==>_GUICtrlRebar_SetBandStyleFixedBMP

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetBandStyleFixedSize
; Description ...: Set whether the band can't be sized. With this style, the sizing grip is not displayed on the band
; Syntax.........: _GUICtrlRebar_SetBandStyleFixedSize($hWnd, $iIndex[, $fEnabled = True])
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
;                  $fEnabled    - If True the item state is set, otherwise it is not set
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandStyleFixedSize, _GUICtrlRebar_SetBandStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetBandStyleFixedSize($hWnd, $iIndex, $fEnabled = True)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	If $fEnabled Then
		Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", BitOR(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_FIXEDSIZE))
	Else
		Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", BitXOR(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_FIXEDSIZE))
	EndIf
EndFunc   ;==>_GUICtrlRebar_SetBandStyleFixedSize

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetBandStyleGripperAlways
; Description ...: Set whether the band will always have a sizing grip, even if it is the only band in the rebar
; Syntax.........: _GUICtrlRebar_SetBandStyleGripperAlways($hWnd, $iIndex[, $fEnabled = True])
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
;                  $fEnabled    - If True the item state is set, otherwise it is not set
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandStyleGripperAlways, _GUICtrlRebar_SetBandStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetBandStyleGripperAlways($hWnd, $iIndex, $fEnabled = True)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	If $fEnabled Then
		Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", BitOR(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_GRIPPERALWAYS))
	Else
		Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", BitXOR(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_GRIPPERALWAYS))
	EndIf
EndFunc   ;==>_GUICtrlRebar_SetBandStyleGripperAlways

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetBandStyleHidden
; Description ...: Set whether the band will not be visible
; Syntax.........: _GUICtrlRebar_SetBandStyleHidden($hWnd, $iIndex[, $fEnabled = True])
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
;                  $fEnabled    - If True the item state is set, otherwise it is not set
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandStyleHidden, _GUICtrlRebar_SetBandStyle, _GUICtrlRebar_ShowBand
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetBandStyleHidden($hWnd, $iIndex, $fEnabled = True)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	If $fEnabled Then
		Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", BitOR(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_HIDDEN))
	Else
		Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", BitXOR(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_HIDDEN))
	EndIf
EndFunc   ;==>_GUICtrlRebar_SetBandStyleHidden

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetBandStyleHideTitle
; Description ...: Set whether to keep band title hidden
; Syntax.........: _GUICtrlRebar_SetBandStyleHideTitle($hWnd, $iIndex[, $fEnabled = True])
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
;                  $fEnabled    - If True the item state is set, otherwise it is not set
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandStyleHideTitle, _GUICtrlRebar_SetBandStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetBandStyleHideTitle($hWnd, $iIndex, $fEnabled = True)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	If $fEnabled Then
		Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", BitOR(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_HIDETITLE))
	Else
		Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", BitXOR(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_HIDETITLE))
	EndIf
EndFunc   ;==>_GUICtrlRebar_SetBandStyleHideTitle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetBandStyleNoGripper
; Description ...: Set whether the band will never have a sizing grip, even if there is more than one band in the rebar
; Syntax.........: _GUICtrlRebar_SetBandStyleNoGripper($hWnd, $iIndex[, $fEnabled = True])
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
;                  $fEnabled    - If True the item state is set, otherwise it is not set
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandStyleNoGripper, _GUICtrlRebar_SetBandStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetBandStyleNoGripper($hWnd, $iIndex, $fEnabled = True)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	If $fEnabled Then
		Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", BitOR(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_NOGRIPPER))
	Else
		Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", BitXOR(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_NOGRIPPER))
	EndIf
EndFunc   ;==>_GUICtrlRebar_SetBandStyleNoGripper

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlRebar_SetBandStyleNoVert
; Description ...: Set whether to Don't show when vertical
; Syntax.........: _GUICtrlRebar_SetBandStyleNoVert($hWnd, $iIndex[, $fEnabled = True])
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
;                  $fEnabled    - If True the item state is set, otherwise it is not set
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandStyleNoVert, _GUICtrlRebar_SetBandStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetBandStyleNoVert($hWnd, $iIndex, $fEnabled = True)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	If $fEnabled Then
		Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", BitOR(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_NOVERT))
	Else
		Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", BitXOR(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_NOVERT))
	EndIf
EndFunc   ;==>_GUICtrlRebar_SetBandStyleNoVert

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetBandStyleTopAlign
; Description ...: Set whether to keep band in top row
; Syntax.........: _GUICtrlRebar_SetBandStyleTopAlign($hWnd, $iIndex[, $fEnabled = True])
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
;                  $fEnabled    - If True the item state is set, otherwise it is not set
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandStyleTopAlign, _GUICtrlRebar_SetBandStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetBandStyleTopAlign($hWnd, $iIndex, $fEnabled = True)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	If $fEnabled Then
		Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", BitOR(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_TOPALIGN))
	Else
		Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", BitXOR(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_TOPALIGN))
	EndIf
EndFunc   ;==>_GUICtrlRebar_SetBandStyleTopAlign

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetBandStyleUseChevron
; Description ...: Set whether to display drop-down button
; Syntax.........: _GUICtrlRebar_SetBandStyleUseChevron($hWnd, $iIndex[, $fEnabled = True])
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
;                  $fEnabled    - If True the item state is set, otherwise it is not set
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Version 5.80. Show a chevron button if the band is smaller than cxIdeal
; Related .......: _GUICtrlRebar_GetBandStyleUseChevron, _GUICtrlRebar_SetBandStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetBandStyleUseChevron($hWnd, $iIndex, $fEnabled = True)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	If $fEnabled Then
		Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", BitOR(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_USECHEVRON))
	Else
		Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", BitXOR(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_USECHEVRON))
	EndIf
EndFunc   ;==>_GUICtrlRebar_SetBandStyleUseChevron

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetBandStyleVariableHeight
; Description ...: Set whether the band can be resized by the rebar control
; Syntax.........: _GUICtrlRebar_SetBandStyleVariableHeight($hWnd, $iIndex[, $fEnabled = True])
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
;                  $fEnabled    - If True the item state is set, otherwise it is not set
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandStyleVariableHeight, _GUICtrlRebar_SetBandStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetBandStyleVariableHeight($hWnd, $iIndex, $fEnabled = True)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	If $fEnabled Then
		Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", BitOR(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_VARIABLEHEIGHT))
	Else
		Return __GUICtrlRebar_SetBandInfo($hWnd, $iIndex, $RBBIM_STYLE, "fStyle", BitXOR(_GUICtrlRebar_GetBandStyle($hWnd, $iIndex), $RBBS_VARIABLEHEIGHT))
	EndIf
EndFunc   ;==>_GUICtrlRebar_SetBandStyleVariableHeight

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetBandText
; Description ...: Sets the display text for the band of a rebar control
; Syntax.........: _GUICtrlRebar_SetBandText($hWnd, $iIndex, $sText)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $iIndex      - Zero-based index of the band for which the information will be set
;                  $sText       - New display text for the band
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBandText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetBandText($hWnd, $iIndex, $sText)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlRebar_GetUnicodeFormat($hWnd)

	Local $tINFO = DllStructCreate($tagREBARBANDINFO)
	Local $iSize = DllStructGetSize($tINFO)
	Local $iBuffer = StringLen($sText) + 1
	Local $tBuffer
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Buffer[" & $iBuffer & "]")
		$iBuffer *= 2
	Else
		$tBuffer = DllStructCreate("char Buffer[" & $iBuffer & "]")
	EndIf

	DllStructSetData($tBuffer, "Buffer", $sText)
	DllStructSetData($tINFO, "cbSize", $iSize)
	DllStructSetData($tINFO, "fMask", $RBBIM_TEXT)
	DllStructSetData($tINFO, "cch", $iBuffer)

	Local $iRet, $tMemMap
	Local $pMemory = _MemInit($hWnd, $iSize + $iBuffer, $tMemMap)
	Local $pText = $pMemory + $iSize
	DllStructSetData($tINFO, "lpText", $pText)
	_MemWrite($tMemMap, $tINFO, $pMemory, $iSize)
	_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
	If $fUnicode Then
		$iRet = _SendMessage($hWnd, $RB_SETBANDINFOW, $iIndex, $pMemory, 0, "wparam", "ptr")
	Else
		$iRet = _SendMessage($hWnd, $RB_SETBANDINFOA, $iIndex, $pMemory, 0, "wparam", "ptr")
	EndIf
	_MemFree($tMemMap)

	Return $iRet <> 0
EndFunc   ;==>_GUICtrlRebar_SetBandText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetBKColor
; Description ...: Sets the default background color of a rebar control
; Syntax.........: _GUICtrlRebar_SetBKColor($hWnd, $iColor)
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iColor      - COLORREF value that represents the new default background color
; Return values .: Success      - A COLORREF value that represents the previous default background color
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetBKColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetBKColor($hWnd, $iColor)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $RB_SETBKCOLOR, 0, $iColor)
EndFunc   ;==>_GUICtrlRebar_SetBKColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetBarInfo
; Description ...: Sets the characteristics of a rebar control
; Syntax.........: _GUICtrlRebar_SetBarInfo($hWnd, $himl)
; Parameters ....: $hWnd       - Handle to rebar control
;                  $himl       - Handle to the Image list
; Return values .: Success     - True
;                  Failure     - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Currently, rebar controls support only image list handle
; Related .......: _GUICtrlRebar_GetBarInfo
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetBarInfo($hWnd, $himl)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Local $tINFO = DllStructCreate($tagREBARINFO)

	DllStructSetData($tINFO, "cbSize", DllStructGetSize($tINFO))
	DllStructSetData($tINFO, "fMask", $RBIM_IMAGELIST)
	DllStructSetData($tINFO, "himl", $himl)
	Return _SendMessage($hWnd, $RB_SETBARINFO, 0, $tINFO, 0, "wparam", "struct*") <> 0

EndFunc   ;==>_GUICtrlRebar_SetBarInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetColorScheme
; Description ...: Sets the color scheme of a rebar control
; Syntax.........: _GUICtrlRebar_SetColorScheme($hWnd, $BtnHighlight, $BtnShadow)
; Parameters ....: $hWnd         - Handle to rebar control
;                  $BtnHighlight - COLORREF value that represents the highlight color of the buttons
;                  $BtnShadow    - COLORREF value that represents the shadow color of the buttons
; Return values .:
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetColorScheme
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetColorScheme($hWnd, $BtnHighlight, $BtnShadow)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Local $tINFO = DllStructCreate($tagCOLORSCHEME)
	Local $iSize = DllStructGetSize($tINFO)

	DllStructSetData($tINFO, "Size", $iSize)
	DllStructSetData($tINFO, "BtnHighlight", $BtnHighlight)
	DllStructSetData($tINFO, "BtnShadow", $BtnShadow)

	Local $tMemMap
	Local $pMemory = _MemInit($hWnd, $iSize, $tMemMap)
	_MemWrite($tMemMap, $tINFO, $pMemory, $iSize)
	_SendMessage($hWnd, $RB_SETCOLORSCHEME, 0, $pMemory, 0, "wparam", "ptr")
	_MemFree($tMemMap)
EndFunc   ;==>_GUICtrlRebar_SetColorScheme

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetTextColor
; Description ...: Sets a rebar control's default text color
; Syntax.........: _GUICtrlRebar_SetTextColor($hWnd, $iColor)
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iColor      - COLORREF value that represents the new default text color
; Return values .: Success      - A COLORREF value that represents the previous default text color
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetTextColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetTextColor($hWnd, $iColor)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $RB_SETTEXTCOLOR, 0, $iColor)
EndFunc   ;==>_GUICtrlRebar_SetTextColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetToolTips
; Description ...: Associates a ToolTip control with the rebar control
; Syntax.........: _GUICtrlRebar_SetToolTips($hWnd, $hToolTip)
; Parameters ....: $hWnd        - Handle to rebar control
;                  $hToolTip    - Handle to the ToolTip control to be set
; Return values .:
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetToolTips
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetToolTips($hWnd, $hToolTip)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	_SendMessage($hWnd, $RB_SETTOOLTIPS, $hToolTip, 0, 0, "hwnd")
EndFunc   ;==>_GUICtrlRebar_SetToolTips

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_SetUnicodeFormat
; Description ...: Sets the Unicode character format flag for the control
; Syntax.........: _GUICtrlRebar_SetUnicodeFormat($hWnd[, $fUnicode = True])
; Parameters ....: $hWnd        - Handle to rebar control
;                  $fUnicode    - Determines the character set that is used by the control:
;                  | True       - The control will use Unicode characters
;                  |False       - The control will use ANSI characters
; Return values .:
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_GetUnicodeFormat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_SetUnicodeFormat($hWnd, $fUnicode = True)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $RB_SETUNICODEFORMAT, $fUnicode)
EndFunc   ;==>_GUICtrlRebar_SetUnicodeFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRebar_ShowBand
; Description ...: Shows or hides a given band in a rebar control
; Syntax.........: _GUICtrlRebar_ShowBand($hWnd, $iIndex[, $fShow = True])
; Parameters ....: $hWnd        - Handle to rebar control
;                  $iIndex      - Zero-based index of the band
;                  $fShow       - indicates if the band should be shown or hidden:
;                  | True       - Show
;                  |False       - Hide
; Return values .:
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRebar_SetBandStyleHidden
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRebar_ShowBand($hWnd, $iIndex, $fShow = True)
	If $Debug_RB Then __UDF_ValidateClassName($hWnd, $__REBARCONSTANT_ClassName)

	Return _SendMessage($hWnd, $RB_SHOWBAND, $iIndex, $fShow) <> 0
EndFunc   ;==>_GUICtrlRebar_ShowBand
