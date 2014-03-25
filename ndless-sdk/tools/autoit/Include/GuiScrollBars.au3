#include-once

#include "StructureConstants.au3"

; #INDEX# =======================================================================================================================
; Title .........: ScrollBar
; AutoIt Version : 3.3.7.20++
; Language ......: English
; Description ...: Functions that assist with ScrollBar management.
;                  A scroll bar consists of a shaded shaft with an arrow button at each end and a scroll box (sometimes called a thumb)
;                  between the arrow buttons. A scroll bar represents the overall length or width of a data object in a window's client
;                  area, the scroll box represents the portion of the object that is visible in the client area. The position of the
;                  scroll box changes whenever the user scrolls a data object to display a different portion of it. The system also adjusts
;                  the size of a scroll bar's scroll box so that it indicates what portion of the entire data object is currently visible
;                  in the window. If most of the object is visible, the scroll box occupies most of the scroll bar shaft. Similarly,
;                  if only a small portion of the object is visible, the scroll box occupies a small part of the scroll bar shaft.
; Author(s) .....: Gary Frost
; Dll(s) ........: user32.dll, gdi32.dll
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $_SCROLLBARCONSTANTS_SB_HORZ = 0
Global Const $_SCROLLBARCONSTANTS_SB_VERT = 1
Global Const $_SCROLLBARCONSTANTS_SB_BOTH = 3
Global Const $_SCROLLBARCONSTANTS_SIF_POS = 0x4
Global Const $_SCROLLBARCONSTANTS_SIF_PAGE = 0x2
Global Const $_SCROLLBARCONSTANTS_SIF_RANGE = 0x1
Global Const $_SCROLLBARCONSTANTS_SIF_TRACKPOS = 0x10
Global Const $_SCROLLBARCONSTANTS_SIF_ALL = BitOR($_SCROLLBARCONSTANTS_SIF_RANGE, $_SCROLLBARCONSTANTS_SIF_PAGE, $_SCROLLBARCONSTANTS_SIF_POS, $_SCROLLBARCONSTANTS_SIF_TRACKPOS)
Global Const $_SCROLLBARCONSTANTS_ESB_ENABLE_BOTH = 0x0
Global Const $_SCROLLBARCONSTANTS_WS_CHILD = 0x40000000
Global Const $_SCROLLBARCONSTANTS_WS_VISIBLE = 0x10000000
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
;0 = hwnd;1 = xClientMax;2 cxChar;3 = cyChar;4 cxClient;5 = cyClient,6 = iHMax;7 = iVMax
Global $aSB_WindowInfo[1][8]
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_GUIScrollBars_EnableScrollBar
;_GUIScrollBars_GetScrollBarInfoEx
;_GUIScrollBars_GetScrollBarRect
;_GUIScrollBars_GetScrollBarRGState
;_GUIScrollBars_GetScrollBarXYLineButton
;_GUIScrollBars_GetScrollBarXYThumbTop
;_GUIScrollBars_GetScrollBarXYThumbBottom
;_GUIScrollBars_GetScrollInfo
;_GUIScrollBars_GetScrollInfoEx
;_GUIScrollBars_GetScrollInfoPage
;_GUIScrollBars_GetScrollInfoPos
;_GUIScrollBars_GetScrollInfoMin
;_GUIScrollBars_GetScrollInfoMax
;_GUIScrollBars_GetScrollInfoTrackPos
;_GUIScrollBars_GetScrollPos
;_GUIScrollBars_GetScrollRange
;_GUIScrollBars_Init
;_GUIScrollBars_ScrollWindow
;_GUIScrollBars_SetScrollInfo
;_GUIScrollBars_SetScrollInfoMin
;_GUIScrollBars_SetScrollInfoMax
;_GUIScrollBars_SetScrollInfoPage
;_GUIScrollBars_SetScrollInfoPos
;_GUIScrollBars_SetScrollRange
;_GUIScrollBars_ShowScrollBar
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_EnableScrollBar
; Description ...: Enable/Disable scrollbar
; Syntax.........: _GUIScrollBars_EnableScrollBar($hWnd[, $wSBflags = $SB_BOTH[, $wArrows = $ESB_ENABLE_BOTH]])
; Parameters ....: $hWnd        - Handle to the window
;                  $wSBflags    - Specifies the scroll bar type. This parameter can be one of the following values:
;                  |  $SB_BOTH - Enables or disables the arrows on the horizontal and vertical scroll bars associated with the specified window.
;                  |  $SB_CTL  - Indicates that the scroll bar is a scroll bar control. The $hWnd must be the handle to the scroll bar control.
;                  |  $SB_HORZ - Enables or disables the arrows on the horizontal scroll bar associated with the specified window.
;                  |  $SB_VERT - Enables or disables the arrows on the vertical scroll bar associated with the specified window.
;                  $wArrows  - Specifies whether the scroll bar arrows are enabled or disabled and indicates which arrows are enabled or disabled.
;                  |This parameter can be one of the following values
;                  |  $ESB_DISABLE_BOTH  - Disables both arrows on a scroll bar.
;                  |  $ESB_DISABLE_DOWN  - Disables the down arrow on a vertical scroll bar.
;                  |  $ESB_DISABLE_LEFT  - Disables the left arrow on a horizontal scroll bar.
;                  |  $ESB_DISABLE_LTUP  - Disables the left arrow on a horizontal scroll bar or the up arrow of a vertical scroll bar.
;                  |  $ESB_DISABLE_RIGHT - Disables the right arrow on a horizontal scroll bar.
;                  |  $ESB_DISABLE_RTDN  - Disables the right arrow on a horizontal scroll bar or the down arrow of a vertical scroll bar.
;                  |  $ESB_DISABLE_UP    - Disables the up arrow on a vertical scroll bar.
;                  |  $ESB_ENABLE_BOTH   - Enables both arrows on a scroll bar.
; Return values .: Success - True
;                  Failure - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Above constants require ScrollBarConstants.au3
; Related .......: _GUIScrollBars_ShowScrollBar
; Link ..........: @@MsdnLink@@ EnableScrollBar
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_EnableScrollBar($hWnd, $wSBflags = $_SCROLLBARCONSTANTS_SB_BOTH, $wArrows = $_SCROLLBARCONSTANTS_ESB_ENABLE_BOTH)
	If Not IsHWnd($hWnd) Then Return SetError(-2, -1, False)
	Local $aResult = DllCall("user32.dll", "bool", "EnableScrollBar", "hwnd", $hWnd, "uint", $wSBflags, "uint", $wArrows)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_GUIScrollBars_EnableScrollBar

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_GetScrollBarInfoEx
; Description ...: Retrieves information about the specified scroll bar
; Syntax.........: _GUIScrollBars_GetScrollBarInfoEx($hWnd, $idObject)
; Parameters ....: $hWnd        - Handle to the window
;                  $idObject    - Specifies the scroll bar object. This parameter can be one of the following values:
;                  |  $OBJID_CLIENT  - The $hWnd parameter is a handle to a scroll bar control.
;                  |  $OBJID_HSCROLL - The horizontal scroll bar of the $hWnd window.
;                  |  $OBJID_VSCROLL - The vertical scroll bar of the $hWnd window.
; Return values .: Success - Struct of type $tagSCROLLBARINFO
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Above constants require ScrollBarConstants.au3
; Related .......: $tagSCROLLBARINFO, _GUIScrollBars_GetScrollBarRect, _GUIScrollBars_GetScrollBarRGState, _GUIScrollBars_GetScrollBarXYLineButton, _GUIScrollBars_GetScrollBarXYThumbBottom, _GUIScrollBars_GetScrollBarXYThumbTop
; Link ..........: @@MsdnLink@@ GetScrollBarInfo
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_GetScrollBarInfoEx($hWnd, $idObject)
	If Not IsHWnd($hWnd) Then Return SetError(-2, -1, 0)
	Local $tSCROLLBARINFO = DllStructCreate($tagSCROLLBARINFO)
	DllStructSetData($tSCROLLBARINFO, "cbSize", DllStructGetSize($tSCROLLBARINFO))
	Local $aResult = DllCall("user32.dll", "bool", "GetScrollBarInfo", "hwnd", $hWnd, "long", $idObject, "struct*", $tSCROLLBARINFO)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($aResult[0], $tSCROLLBARINFO)
EndFunc   ;==>_GUIScrollBars_GetScrollBarInfoEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_GetScrollBarRect
; Description ...: Retrieves coordinates of the scroll bar
; Syntax.........: _GUIScrollBars_GetScrollBarRect($hWnd, $idObject)
; Parameters ....: $hWnd        - Handle to the window
;                  $idObject    - Specifies the scroll bar object. This parameter can be one of the following values:
;                  |  $OBJID_CLIENT  - The $hWnd parameter is a handle to a scroll bar control.
;                  |  $OBJID_HSCROLL - The horizontal scroll bar of the $hWnd window.
;                  |  $OBJID_VSCROLL - The vertical scroll bar of the $hWnd window.
; Return values .: Success - Array in the following format:
;                  |  [0] - Left
;                  |  [1] - Top
;                  |  [2] - Right
;                  |  [3] - Bottom
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Above constants require ScrollBarConstants.au3
; Related .......: _GUIScrollBars_GetScrollBarInfoEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_GetScrollBarRect($hWnd, $idObject)
	Local $aRect[4]
	If Not IsHWnd($hWnd) Then Return SetError(-2, -1, 0)
	Local $tSCROLLBARINFO = _GUIScrollBars_GetScrollBarInfoEx($hWnd, $idObject)
	If @error Then Return SetError(@error, @extended, 0)
	$aRect[0] = DllStructGetData($tSCROLLBARINFO, "Left")
	$aRect[1] = DllStructGetData($tSCROLLBARINFO, "Top")
	$aRect[2] = DllStructGetData($tSCROLLBARINFO, "Right")
	$aRect[3] = DllStructGetData($tSCROLLBARINFO, "Bottom")
	Return $aRect
EndFunc   ;==>_GUIScrollBars_GetScrollBarRect

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_GetScrollBarRGState
; Description ...: Retrieves the state of a scroll bar component
; Syntax.........: _GUIScrollBars_GetScrollBarRGState($hWnd, $idObject)
; Parameters ....: $hWnd        - Handle to the window
;                  $idObject    - Specifies the scroll bar object. This parameter can be one of the following values:
;                  |  $OBJID_CLIENT  - The $hWnd parameter is a handle to a scroll bar control.
;                  |  $OBJID_HSCROLL - The horizontal scroll bar of the $hWnd window.
;                  |  $OBJID_VSCROLL - The vertical scroll bar of the $hWnd window.
; Return values .: Success - Array in the following format:
;                  |  [0] - The scroll bar itself.
;                  |  [1] - The top or right arrow button.
;                  |  [2] - The page up or page right region.
;                  |  [3] - The scroll box (thumb).
;                  |  [4] - The page down or page left region.
;                  |  [5] - The bottom or left arrow button.
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Above constants require ScrollBarConstants.au3
; Related .......: _GUIScrollBars_GetScrollBarInfoEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_GetScrollBarRGState($hWnd, $idObject)
	Local $aRGState[6]
	If Not IsHWnd($hWnd) Then Return SetError(-2, -1, 0)
	Local $tSCROLLBARINFO = _GUIScrollBars_GetScrollBarInfoEx($hWnd, $idObject)
	If @error Then Return SetError(@error, @extended, 0)
	For $x = 0 To 5
		$aRGState[$x] = DllStructGetData($tSCROLLBARINFO, "rgstate", $x + 1)
	Next
	Return $aRGState
EndFunc   ;==>_GUIScrollBars_GetScrollBarRGState

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_GetScrollBarXYLineButton
; Description ...: Retrieves the Height or width of the thumb
; Syntax.........: _GUIScrollBars_GetScrollBarXYLineButton($hWnd, $idObject)
; Parameters ....: $hWnd        - Handle to the window
;                  $idObject    - Specifies the scroll bar object. This parameter can be one of the following values:
;                  |  $OBJID_CLIENT  - The $hWnd parameter is a handle to a scroll bar control.
;                  |  $OBJID_HSCROLL - The horizontal scroll bar of the $hWnd window.
;                  |  $OBJID_VSCROLL - The vertical scroll bar of the $hWnd window.
; Return values .: Success - Height or width of the thumb
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Above constants require ScrollBarConstants.au3
; Related .......: _GUIScrollBars_GetScrollBarInfoEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_GetScrollBarXYLineButton($hWnd, $idObject)
	If Not IsHWnd($hWnd) Then Return SetError(-2, -1, -1)
	Local $tSCROLLBARINFO = _GUIScrollBars_GetScrollBarInfoEx($hWnd, $idObject)
	If @error Then Return SetError(@error, @extended, -1)
	Return DllStructGetData($tSCROLLBARINFO, "dxyLineButton")
EndFunc   ;==>_GUIScrollBars_GetScrollBarXYLineButton

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_GetScrollBarXYThumbTop
; Description ...: Retrieves the Position of the top or left of the thumb
; Syntax.........: _GUIScrollBars_GetScrollBarXYThumbTop($hWnd, $idObject)
; Parameters ....: $hWnd        - Handle to the window
;                  $idObject    - Specifies the scroll bar object. This parameter can be one of the following values:
;                  |  $OBJID_CLIENT  - The $hWnd parameter is a handle to a scroll bar control.
;                  |  $OBJID_HSCROLL - The horizontal scroll bar of the $hWnd window.
;                  |  $OBJID_VSCROLL - The vertical scroll bar of the $hWnd window.
; Return values .: Success - Position of the top or left of the thumb
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Above constants require ScrollBarConstants.au3
; Related .......: _GUIScrollBars_GetScrollBarInfoEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_GetScrollBarXYThumbTop($hWnd, $idObject)
	If Not IsHWnd($hWnd) Then Return SetError(-2, -1, -1)
	Local $tSCROLLBARINFO = _GUIScrollBars_GetScrollBarInfoEx($hWnd, $idObject)
	If @error Then Return SetError(@error, @extended, -1)
	Return DllStructGetData($tSCROLLBARINFO, "xyThumbTop")
EndFunc   ;==>_GUIScrollBars_GetScrollBarXYThumbTop

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_GetScrollBarXYThumbBottom
; Description ...: Retrieves the Position of the bottom or right of the thumb
; Syntax.........: _GUIScrollBars_GetScrollBarXYThumbBottom($hWnd, $idObject)
; Parameters ....: $hWnd        - Handle to the window
;                  $idObject    - Specifies the scroll bar object. This parameter can be one of the following values:
;                  |  $OBJID_CLIENT  - The $hWnd parameter is a handle to a scroll bar control.
;                  |  $OBJID_HSCROLL - The horizontal scroll bar of the $hWnd window.
;                  |  $OBJID_VSCROLL - The vertical scroll bar of the $hWnd window.
; Return values .: Success - Position of the bottom or right of the thumb
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Above constants require ScrollBarConstants.au3
; Related .......: _GUIScrollBars_GetScrollBarInfoEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_GetScrollBarXYThumbBottom($hWnd, $idObject)
	If Not IsHWnd($hWnd) Then Return SetError(-1, -1, -1)
	Local $tSCROLLBARINFO = _GUIScrollBars_GetScrollBarInfoEx($hWnd, $idObject)
	If @error Then Return SetError(-1, -1, -1)
	Return DllStructGetData($tSCROLLBARINFO, "xyThumbBottom")
EndFunc   ;==>_GUIScrollBars_GetScrollBarXYThumbBottom

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_GetScrollInfo
; Description ...: Retrieves the parameters of a scroll bar
; Syntax.........: _GUIScrollBars_GetScrollInfo($hWnd, $fnBar, ByRef $tSCROLLINFO)
; Parameters ....: $hWnd        - Handle to the window
;                  $fnBar       - Specifies the type of scroll bar. This parameter can be one of the following values:
;                  |  $SB_CTL  - Retrieves the parameters for a scroll bar control. The $hWnd parameter must be the handle to the scroll bar control.
;                  |  $SB_HORZ - Retrieves the parameters for the window's standard horizontal scroll bar.
;                  |  $SB_VERT - Retrieves the parameters for the window's standard vertical scroll bar.
;                  $tSCROLLINFO - Structure of type $tagSCROLLINFO
; Return values .: Success - True
;                  Failure - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Above constants require ScrollBarConstants.au3
; Related .......: _GUIScrollBars_GetScrollInfoEx, $tagSCROLLINFO, _GUIScrollBars_SetScrollInfo
; Link ..........: @@MsdnLink@@ GetScrollInfo
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_GetScrollInfo($hWnd, $fnBar, ByRef $tSCROLLINFO)
	If Not IsHWnd($hWnd) Then Return SetError(-2, -1, False)
	Local $aResult = DllCall("user32.dll", "bool", "GetScrollInfo", "hwnd", $hWnd, "int", $fnBar, "struct*", $tSCROLLINFO)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_GUIScrollBars_GetScrollInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_GetScrollInfoEx
; Description ...: Retrieves the parameters of a scroll bar
; Syntax.........: _GUIScrollBars_GetScrollInfoEx($hWnd, $fnBar)
; Parameters ....: $hWnd        - Handle to the window
;                  $fnBar       - Specifies the type of scroll bar. This parameter can be one of the following values:
;                  |  $SB_CTL  - Retrieves the parameters for a scroll bar control. The $hWnd parameter must be the handle to the scroll bar control.
;                  |  $SB_HORZ - Retrieves the parameters for the window's standard horizontal scroll bar.
;                  |  $SB_VERT - Retrieves the parameters for the window's standard vertical scroll bar.
; Return values .: Success - $tagSCROLLINFO structure
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Above constants require ScrollBarConstants.au3
; Related .......: _GUIScrollBars_GetScrollInfo, $tagSCROLLINFO, _GUIScrollBars_GetScrollInfoMax, _GUIScrollBars_GetScrollInfoMin, _GUIScrollBars_GetScrollInfoPage, _GUIScrollBars_GetScrollInfoPos, _GUIScrollBars_GetScrollInfoTrackPos
; Link ..........: @@MsdnLink@@ GetScrollInfo
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_GetScrollInfoEx($hWnd, $fnBar)
	If Not IsHWnd($hWnd) Then Return SetError(-2, -1, 0)
	Local $tSCROLLINFO = DllStructCreate($tagSCROLLINFO)
	DllStructSetData($tSCROLLINFO, "cbSize", DllStructGetSize($tSCROLLINFO))
	DllStructSetData($tSCROLLINFO, "fMask", $_SCROLLBARCONSTANTS_SIF_ALL)
	If Not _GUIScrollBars_GetScrollInfo($hWnd, $fnBar, $tSCROLLINFO) Then Return SetError(@error, @extended, 0)
	Return $tSCROLLINFO
EndFunc   ;==>_GUIScrollBars_GetScrollInfoEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_GetScrollInfoPage
; Description ...: Retrieves the page size
; Syntax.........: _GUIScrollBars_GetScrollInfoPage($hWnd, $fnBar)
; Parameters ....: $hWnd        - Handle to the window
;                  $fnBar       - Specifies the type of scroll bar. This parameter can be one of the following values:
;                  |  $SB_CTL  - Retrieves the parameters for a scroll bar control. The $hWnd parameter must be the handle to the scroll bar control.
;                  |  $SB_HORZ - Retrieves the parameters for the window's standard horizontal scroll bar.
;                  |  $SB_VERT - Retrieves the parameters for the window's standard vertical scroll bar.
; Return values .: Success - The page size
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Above constants require ScrollBarConstants.au3
; Related .......: _GUIScrollBars_GetScrollInfoEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_GetScrollInfoPage($hWnd, $fnBar)
	If Not IsHWnd($hWnd) Then Return SetError(-2, -1, -1)
	Local $tSCROLLINFO = _GUIScrollBars_GetScrollInfoEx($hWnd, $fnBar)
	If @error Then Return SetError(@error, @extended, -1)
	Return DllStructGetData($tSCROLLINFO, "nPage")
EndFunc   ;==>_GUIScrollBars_GetScrollInfoPage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_GetScrollInfoPos
; Description ...: Retrieves the position of the scroll box
; Syntax.........: _GUIScrollBars_GetScrollInfoPos($hWnd, $fnBar)
; Parameters ....: $hWnd        - Handle to the window
;                  $fnBar       - Specifies the type of scroll bar. This parameter can be one of the following values:
;                  |  $SB_CTL  - Retrieves the parameters for a scroll bar control. The $hWnd parameter must be the handle to the scroll bar control.
;                  |  $SB_HORZ - Retrieves the parameters for the window's standard horizontal scroll bar.
;                  |  $SB_VERT - Retrieves the parameters for the window's standard vertical scroll bar.
; Return values .: Success - The position of the scroll box
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Above constants require ScrollBarConstants.au3
; Related .......: _GUIScrollBars_GetScrollInfoEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_GetScrollInfoPos($hWnd, $fnBar)
	If Not IsHWnd($hWnd) Then Return SetError(-2, -1, -1)
	Local $tSCROLLINFO = _GUIScrollBars_GetScrollInfoEx($hWnd, $fnBar)
	If @error Then Return SetError(@error, @extended, -1)
	Return DllStructGetData($tSCROLLINFO, "nPos")
EndFunc   ;==>_GUIScrollBars_GetScrollInfoPos

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_GetScrollInfoMin
; Description ...: Retrieves the minimum scrolling position
; Syntax.........: _GUIScrollBars_GetScrollInfoMin($hWnd, $fnBar)
; Parameters ....: $hWnd        - Handle to the window
;                  $fnBar       - Specifies the type of scroll bar. This parameter can be one of the following values:
;                  |  $SB_CTL  - Retrieves the parameters for a scroll bar control. The $hWnd parameter must be the handle to the scroll bar control.
;                  |  $SB_HORZ - Retrieves the parameters for the window's standard horizontal scroll bar.
;                  |  $SB_VERT - Retrieves the parameters for the window's standard vertical scroll bar.
; Return values .: Success - The minimum scrolling position
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Above constants require ScrollBarConstants.au3
; Related .......: _GUIScrollBars_GetScrollInfoEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_GetScrollInfoMin($hWnd, $fnBar)
	If Not IsHWnd($hWnd) Then Return SetError(-2, -1, -1)
	Local $tSCROLLINFO = _GUIScrollBars_GetScrollInfoEx($hWnd, $fnBar)
	If @error Then Return SetError(@error, @extended, -1)
	Return DllStructGetData($tSCROLLINFO, "nMin")
EndFunc   ;==>_GUIScrollBars_GetScrollInfoMin

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_GetScrollInfoMax
; Description ...: Retrieves the maximum scrolling position
; Syntax.........: _GUIScrollBars_GetScrollInfoMax($hWnd, $fnBar)
; Parameters ....: $hWnd        - Handle to the window
;                  $fnBar       - Specifies the type of scroll bar. This parameter can be one of the following values:
;                  |  $SB_CTL  - Retrieves the parameters for a scroll bar control. The $hWnd parameter must be the handle to the scroll bar control.
;                  |  $SB_HORZ - Retrieves the parameters for the window's standard horizontal scroll bar.
;                  |  $SB_VERT - Retrieves the parameters for the window's standard vertical scroll bar.
; Return values .: Success - The maximum scrolling position
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Above constants require ScrollBarConstants.au3
; Related .......: _GUIScrollBars_GetScrollInfoEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_GetScrollInfoMax($hWnd, $fnBar)
	If Not IsHWnd($hWnd) Then Return SetError(-2, -1, -1)
	Local $tSCROLLINFO = _GUIScrollBars_GetScrollInfoEx($hWnd, $fnBar)
	If @error Then Return SetError(@error, @extended, -1)
	Return DllStructGetData($tSCROLLINFO, "nMax")
EndFunc   ;==>_GUIScrollBars_GetScrollInfoMax

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_GetScrollInfoTrackPos
; Description ...: Retrieves the immediate position of a scroll box that the user is dragging
; Syntax.........: _GUIScrollBars_GetScrollInfoTrackPos($hWnd, $fnBar)
; Parameters ....: $hWnd        - Handle to the window
;                  $fnBar       - Specifies the type of scroll bar. This parameter can be one of the following values:
;                  |  $SB_CTL  - Retrieves the parameters for a scroll bar control. The $hWnd parameter must be the handle to the scroll bar control.
;                  |  $SB_HORZ - Retrieves the parameters for the window's standard horizontal scroll bar.
;                  |  $SB_VERT - Retrieves the parameters for the window's standard vertical scroll bar.
; Return values .: Success - The immediate position of a scroll box
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Above constants require ScrollBarConstants.au3
; Related .......: _GUIScrollBars_GetScrollInfoEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_GetScrollInfoTrackPos($hWnd, $fnBar)
	If Not IsHWnd($hWnd) Then Return SetError(-2, -1, -1)
	Local $tSCROLLINFO = _GUIScrollBars_GetScrollInfoEx($hWnd, $fnBar)
	If @error Then Return SetError(@error, @extended, -1)
	Return DllStructGetData($tSCROLLINFO, "nTrackPos")
EndFunc   ;==>_GUIScrollBars_GetScrollInfoTrackPos

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_GetScrollPos
; Description ...: Retrieves the current position of the scroll box (thumb) in the specified scroll bar
; Syntax.........: _GUIScrollBars_GetScrollPos($hWnd, $nBar)
; Parameters ....: $hWnd        - Handle to the window
;                  $nBar       - Specifies the type of scroll bar. This parameter can be one of the following values:
;                  |  $SB_CTL  - Retrieves the position of the scroll box in a scroll bar control. The $hWnd parameter must be the handle to the scroll bar control.
;                  |  $SB_HORZ - Retrieves the position of the scroll box in a window's standard horizontal scroll bar
;                  |  $SB_VERT - Retrieves the position of the scroll box in a window's standard vertical scroll bar.
; Return values .: Success - Current position of the scroll box
;                  Failure - -1
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Above constants require ScrollBarConstants.au3
; Related .......: _GUIScrollBars_SetScrollInfoPos
; Link ..........: @@MsdnLink@@ GetScrollPos
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_GetScrollPos($hWnd, $nBar)
	If Not IsHWnd($hWnd) Then Return SetError(-2, -1, -1)
	Local $aResult = DllCall("user32.dll", "int", "GetScrollPos", "hwnd", $hWnd, "int", $nBar)
	If @error Then Return SetError(@error, @extended, -1)
	Return $aResult[0]
EndFunc   ;==>_GUIScrollBars_GetScrollPos

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_GetScrollRange
; Description ...: Retrieves the current minimum and maximum scroll box (thumb) positions for the specified scroll bar
; Syntax.........: _GUIScrollBars_GetScrollRange($hWnd, $nBar)
; Parameters ....: $hWnd        - Handle to the window
;                  $nBar       - Specifies the type of scroll bar. This parameter can be one of the following values:
;                  |  $SB_CTL  - Retrieves the positions of a scroll bar control. The $hWnd parameter must be the handle to the scroll bar control.
;                  |  $SB_HORZ - Retrieves the positions of the window's standard horizontal scroll bar.
;                  |  $SB_VERT - Retrieves the positions of the window's standard vertical scroll bar.
; Return values .: Success - current minimum and maximum scroll box (thumb) positions for the specified scroll bar, in the following format:
;                  |[0] - minimum position
;                  |[1] - maximum position
;                  Failure - -1
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Above constants require ScrollBarConstants.au3
; Related .......: _GUIScrollBars_SetScrollRange
; Link ..........: @@MsdnLink@@ GetScrollRange
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_GetScrollRange($hWnd, $nBar)
	If Not IsHWnd($hWnd) Then Return SetError(-2, -1, -1)
	Local $aResult = DllCall("user32.dll", "bool", "GetScrollRange", "hwnd", $hWnd, "int", $nBar, "int*", 0, "int*", 0)
	If @error Then Return SetError(@error, @extended, -1)
	Local $Min_Max[2]
	$Min_Max[0] = $aResult[3]
	$Min_Max[1] = $aResult[4]
	Return SetExtended($aResult[0], $Min_Max)

EndFunc   ;==>_GUIScrollBars_GetScrollRange

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_Init
; Description ...: Initialize the scrollbars for the window
; Syntax.........: _GUIScrollBars_Init($hWnd[, $iHMax = -1[, $ivMax = -1]])
; Parameters ....: $hWnd        - Handle to the window
;                  $iHMax       - Max size of Horizontal scrollbar
;                  $ivMax       - Max size of Vertical scrollbar
; Return values .:
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_Init($hWnd, $iHMax = -1, $ivMax = -1)
	If Not IsHWnd($hWnd) Then Return SetError(-2, -1, 0)
	If $aSB_WindowInfo[0][0] <> 0 Then ReDim $aSB_WindowInfo[UBound($aSB_WindowInfo) + 1][8]

	Local $tSCROLLINFO = DllStructCreate($tagSCROLLINFO)
	Local $tRect = DllStructCreate($tagRECT)

	Local $index = UBound($aSB_WindowInfo) - 1
	Local $iError, $iExtended

	$aSB_WindowInfo[$index][0] = $hWnd
	$aSB_WindowInfo[$index][1] = $iHMax
	$aSB_WindowInfo[$index][6] = $iHMax
	$aSB_WindowInfo[$index][7] = $ivMax
	If $ivMax = -1 Then $aSB_WindowInfo[$index][7] = 27

	Local $hdc = DllCall("user32.dll", "handle", "GetDC", "hwnd", $hWnd)
	If @error Then Return SetError(@error, @extended)
	$hdc = $hdc[0]

	Local $tTEXTMETRIC = DllStructCreate($tagTEXTMETRIC)

	DllStructSetData($tSCROLLINFO, "cbSize", DllStructGetSize($tSCROLLINFO))

	DllCall("gdi32.dll", "bool", "GetTextMetricsW", "handle", $hdc, "struct*", $tTEXTMETRIC)
	If @error Then
		$iError = @error
		$iExtended = @extended
	EndIf

	DllCall("user32.dll", "int", "ReleaseDC", "hwnd", $hWnd, "handle", $hdc)
	; Skip @error test as the results don't matter.

	; Test previous error from GetTextMetrics call.
	If $iError Then Return SetError($iError, $iExtended)

	Local $xUpper, $xChar = DllStructGetData($tTEXTMETRIC, "tmAveCharWidth")
	If BitAND(DllStructGetData($tTEXTMETRIC, "tmPitchAndFamily"), 1) Then
		$xUpper = 3 * $xChar / 2
	Else
		$xUpper = 2 * $xChar / 2
	EndIf

	Local $yChar = DllStructGetData($tTEXTMETRIC, "tmHeight") + DllStructGetData($tTEXTMETRIC, "tmExternalLeading")

	If $iHMax = -1 Then $aSB_WindowInfo[$index][1] = 48 * $xChar + 12 * $xUpper
	$aSB_WindowInfo[$index][2] = $xChar
	$aSB_WindowInfo[$index][3] = $yChar

	_GUIScrollBars_ShowScrollBar($hWnd, $_SCROLLBARCONSTANTS_SB_HORZ, False)
	_GUIScrollBars_ShowScrollBar($hWnd, $_SCROLLBARCONSTANTS_SB_VERT, False)
	_GUIScrollBars_ShowScrollBar($hWnd, $_SCROLLBARCONSTANTS_SB_HORZ)
	_GUIScrollBars_ShowScrollBar($hWnd, $_SCROLLBARCONSTANTS_SB_VERT)

	DllCall("user32.dll", "bool", "GetClientRect", "hwnd", $hWnd, "struct*", $tRect)
	If @error Then Return SetError(@error, @extended)

	Local $xClient = DllStructGetData($tRect, "Right") - DllStructGetData($tRect, "Left")
	Local $yClient = DllStructGetData($tRect, "Bottom") - DllStructGetData($tRect, "Top")
	$aSB_WindowInfo[$index][4] = $xClient
	$aSB_WindowInfo[$index][5] = $yClient

	$tSCROLLINFO = DllStructCreate($tagSCROLLINFO)

	; Set the vertical scrolling range and page size
	DllStructSetData($tSCROLLINFO, "fMask", BitOR($_SCROLLBARCONSTANTS_SIF_RANGE, $_SCROLLBARCONSTANTS_SIF_PAGE))
	DllStructSetData($tSCROLLINFO, "nMin", 0)
	DllStructSetData($tSCROLLINFO, "nMax", $aSB_WindowInfo[$index][7])
	DllStructSetData($tSCROLLINFO, "nPage", $yClient / $yChar)
	_GUIScrollBars_SetScrollInfo($hWnd, $_SCROLLBARCONSTANTS_SB_VERT, $tSCROLLINFO)

	; Set the horizontal scrolling range and page size
	DllStructSetData($tSCROLLINFO, "fMask", BitOR($_SCROLLBARCONSTANTS_SIF_RANGE, $_SCROLLBARCONSTANTS_SIF_PAGE))
	DllStructSetData($tSCROLLINFO, "nMin", 0)
	DllStructSetData($tSCROLLINFO, "nMax", 2 + $aSB_WindowInfo[$index][1] / $xChar)
	DllStructSetData($tSCROLLINFO, "nPage", $xClient / $xChar)
	_GUIScrollBars_SetScrollInfo($hWnd, $_SCROLLBARCONSTANTS_SB_HORZ, $tSCROLLINFO)

EndFunc   ;==>_GUIScrollBars_Init

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_ScrollWindow
; Description ...: Scrolls the contents of the specified window's client area
; Syntax.........: _GUIScrollBars_ScrollWindow($hWnd, $iXAmount, $iYAmount)
; Parameters ....: $hWnd      - Handle to the window
;                  $iXAmount  - Specifies the amount, in device units, of horizontal scrolling
;                  $iYAmount  - Specifies the amount, in device units, of vertical scrolling
; Return values .: Success - True
;                  Failure - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ ScrollWindow
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_ScrollWindow($hWnd, $iXAmount, $iYAmount)
	If Not IsHWnd($hWnd) Then Return SetError(-2, -1, False)
	Local $aResult = DllCall("user32.dll", "bool", "ScrollWindow", "hwnd", $hWnd, "int", $iXAmount, "int", $iYAmount, "ptr", 0, "ptr", 0)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_GUIScrollBars_ScrollWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_SetScrollInfo
; Description ...: Sets the parameters of a scroll bar
; Syntax.........: _GUIScrollBars_SetScrollInfo($hWnd, $fnBar, $tSCROLLINFO[, $fRedraw = True])
; Parameters ....: $hWnd        - Handle to the window
;                  $fnBar       - Specifies the type of scroll bar. This parameter can be one of the following values:
;                  |  $SB_CTL  - Sets the parameters of a scroll bar control. The $hWnd parameter must be the handle to the scroll bar control.
;                  |  $SB_HORZ - Sets the parameters of the window's standard horizontal scroll bar.
;                  |  $SB_VERT - Sets the parameters of the window's standard vertical scroll bar.
;                  $tSCROLLINFO - Structure of type $tagSCROLLINFO
;                  $fRedraw     - Specifies whether the scroll bar is redrawn to reflect the changes to the scroll bar
; Return values .: Success - Current position of the scroll box
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Above constants require ScrollBarConstants.au3
; Related .......: _GUIScrollBars_GetScrollInfo, _GUIScrollBars_SetScrollInfoMax, _GUIScrollBars_SetScrollInfoMin, _GUIScrollBars_SetScrollInfoPage, _GUIScrollBars_SetScrollInfoPos
; Link ..........: @@MsdnLink@@ SetScrollInfo
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_SetScrollInfo($hWnd, $fnBar, $tSCROLLINFO, $fRedraw = True)
	If Not IsHWnd($hWnd) Then Return SetError(-2, -1, -1)
	DllStructSetData($tSCROLLINFO, "cbSize", DllStructGetSize($tSCROLLINFO))
	Local $aResult = DllCall("user32.dll", "int", "SetScrollInfo", "hwnd", $hWnd, "int", $fnBar, "struct*", $tSCROLLINFO, "bool", $fRedraw)
	If @error Then Return SetError(@error, @extended, -1)
	Return $aResult[0]
EndFunc   ;==>_GUIScrollBars_SetScrollInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_SetScrollInfoMin
; Description ...: Sets the minimum scrolling position
; Syntax.........: _GUIScrollBars_SetScrollInfoMin($hWnd, $fnBar, $nMin)
; Parameters ....: $hWnd  - Handle to the window
;                  $fnBar       - Specifies the type of scroll bar. This parameter can be one of the following values:
;                  |  $SB_CTL  - Sets the parameters of a scroll bar control. The $hWnd parameter must be the handle to the scroll bar control.
;                  |  $SB_HORZ - Sets the parameters of the window's standard horizontal scroll bar.
;                  |  $SB_VERT - Sets the parameters of the window's standard vertical scroll bar.
;                  $nMin  - Minimum scrolling position
; Return values .: Success - True
;                  Failure - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Above constants require ScrollBarConstants.au3
; Related .......: _GUIScrollBars_SetScrollInfo, _GUIScrollBars_SetScrollRange
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_SetScrollInfoMin($hWnd, $fnBar, $nMin)
	If Not IsHWnd($hWnd) Then Return SetError(-2, -1, False)
	Local $aRange = _GUIScrollBars_GetScrollRange($hWnd, $fnBar)
	_GUIScrollBars_SetScrollRange($hWnd, $fnBar, $nMin, $aRange[1])
	Local $aRange_check = _GUIScrollBars_GetScrollRange($hWnd, $fnBar)
	; invalid range check if invalid reset to previous values
	If $aRange[1] <> $aRange_check[1] Or $nMin <> $aRange_check[0] Then
		_GUIScrollBars_SetScrollRange($hWnd, $fnBar, $aRange[0], $aRange[1])
		Return False
	EndIf
	Return True
EndFunc   ;==>_GUIScrollBars_SetScrollInfoMin

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_SetScrollInfoMax
; Description ...: Sets the maximum scrolling position
; Syntax.........: _GUIScrollBars_SetScrollInfoMax($hWnd, $fnBar, $nMax)
; Parameters ....: $hWnd  - Handle to the window
;                  $fnBar       - Specifies the type of scroll bar. This parameter can be one of the following values:
;                  |  $SB_CTL  - Sets the parameters of a scroll bar control. The $hWnd parameter must be the handle to the scroll bar control.
;                  |  $SB_HORZ - Sets the parameters of the window's standard horizontal scroll bar.
;                  |  $SB_VERT - Sets the parameters of the window's standard vertical scroll bar.
;                  $nMax  - Maximum scrolling position
; Return values .: Success - True
;                  Failure - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Above constants require ScrollBarConstants.au3
; Related .......: _GUIScrollBars_SetScrollInfo, _GUIScrollBars_SetScrollRange
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_SetScrollInfoMax($hWnd, $fnBar, $nMax)
	If Not IsHWnd($hWnd) Then Return SetError(-2, -1, False)
	Local $aRange = _GUIScrollBars_GetScrollRange($hWnd, $fnBar)
	_GUIScrollBars_SetScrollRange($hWnd, $fnBar, $aRange[0], $nMax)
	Local $aRange_check = _GUIScrollBars_GetScrollRange($hWnd, $fnBar)
	; invalid range check if invalid reset to previous values
	If $aRange[0] <> $aRange_check[0] Or $nMax <> $aRange_check[1] Then
		_GUIScrollBars_SetScrollRange($hWnd, $fnBar, $aRange[0], $aRange[1])
		Return False
	EndIf
	Return True
EndFunc   ;==>_GUIScrollBars_SetScrollInfoMax

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_SetScrollInfoPage
; Description ...: Sets the page size
; Syntax.........: _GUIScrollBars_SetScrollInfoPage($hWnd, $fnBar, $nPage)
; Parameters ....: $hWnd  - Handle to the window
;                  $fnBar       - Specifies the type of scroll bar. This parameter can be one of the following values:
;                  |  $SB_CTL  - Sets the parameters of a scroll bar control. The $hWnd parameter must be the handle to the scroll bar control.
;                  |  $SB_HORZ - Sets the parameters of the window's standard horizontal scroll bar.
;                  |  $SB_VERT - Sets the parameters of the window's standard vertical scroll bar.
;                  $nPage  - Page size
; Return values .: Success - Current position of the scroll box
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Above constants require ScrollBarConstants.au3
; Related .......: _GUIScrollBars_SetScrollInfo
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_SetScrollInfoPage($hWnd, $fnBar, $nPage)
	If Not IsHWnd($hWnd) Then Return SetError(-2, -1, -1)
	Local $tSCROLLINFO = DllStructCreate($tagSCROLLINFO)
	DllStructSetData($tSCROLLINFO, "fMask", $_SCROLLBARCONSTANTS_SIF_PAGE)
	DllStructSetData($tSCROLLINFO, "nPage", $nPage)
	Return _GUIScrollBars_SetScrollInfo($hWnd, $fnBar, $tSCROLLINFO)
EndFunc   ;==>_GUIScrollBars_SetScrollInfoPage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_SetScrollInfoPos
; Description ...: Sets the position of the scroll box (thumb) in the specified scroll bar
; Syntax.........: _GUIScrollBars_SetScrollInfoPos($hWnd, $fnBar, $nPos)
; Parameters ....: $hWnd  - Handle to the window
;                  $fnBar       - Specifies the type of scroll bar. This parameter can be one of the following values:
;                  |  $SB_CTL  - Sets the parameters of a scroll bar control. The $hWnd parameter must be the handle to the scroll bar control.
;                  |  $SB_HORZ - Sets the parameters of the window's standard horizontal scroll bar.
;                  |  $SB_VERT - Sets the parameters of the window's standard vertical scroll bar.
;                  $nPos  - Position of the scroll box
; Return values .:
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Above constants require ScrollBarConstants.au3
; Related .......: _GUIScrollBars_SetScrollInfo, _GUIScrollBars_GetScrollPos
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_SetScrollInfoPos($hWnd, $fnBar, $nPos)
	Local $index = -1, $yChar, $xChar

	For $x = 0 To UBound($aSB_WindowInfo) - 1
		If $aSB_WindowInfo[$x][0] = $hWnd Then
			$index = $x
			$xChar = $aSB_WindowInfo[$index][2]
			$yChar = $aSB_WindowInfo[$index][3]
			ExitLoop
		EndIf
	Next
	If $index = -1 Then Return 0

	; Save the position for comparison later on
	Local $tSCROLLINFO = _GUIScrollBars_GetScrollInfoEx($hWnd, $fnBar)
	Local $xyPos = DllStructGetData($tSCROLLINFO, "nPos")

	DllStructSetData($tSCROLLINFO, "fMask", $_SCROLLBARCONSTANTS_SIF_POS)
	DllStructSetData($tSCROLLINFO, "nPos", $nPos)
	_GUIScrollBars_SetScrollInfo($hWnd, $fnBar, $tSCROLLINFO)
	_GUIScrollBars_GetScrollInfo($hWnd, $fnBar, $tSCROLLINFO)
	;// If the position has changed, scroll the window and update it
	$nPos = DllStructGetData($tSCROLLINFO, "nPos")
	If $fnBar = $_SCROLLBARCONSTANTS_SB_HORZ Then
		If ($nPos <> $xyPos) Then _GUIScrollBars_ScrollWindow($hWnd, $xChar * ($xyPos - $nPos), 0)
	Else
		If ($nPos <> $xyPos) Then _GUIScrollBars_ScrollWindow($hWnd, 0, $yChar * ($xyPos - $nPos))
	EndIf
EndFunc   ;==>_GUIScrollBars_SetScrollInfoPos

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_SetScrollRange
; Description ...: Sets the minimum and maximum scroll box positions for the specified scroll bar
; Syntax.........: _GUIScrollBars_SetScrollRange($hWnd, $nBar, $nMinPos, $nMaxPos)
; Parameters ....: $hWnd   - Handle to the window
;                  $nBar   - Specifies the type of scroll bar. This parameter can be one of the following values:
;                  |  $SB_CTL  - Sets the range of a scroll bar control. The $hWnd parameter must be the handle to the scroll bar control.
;                  |  $SB_HORZ - Sets the range of a window's standard horizontal scroll bar.
;                  |  $SB_VERT - Sets the range of a window's standard vertical scroll bar.
;                  $nMinPos - Specifies the minimum scrolling position
;                  $nMaxPos - Specifies the maximum scrolling position
; Return values .: Success - True
;                  Failure - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Above constants require ScrollBarConstants.au3
; Related .......: _GUIScrollBars_SetScrollInfoMin, _GUIScrollBars_SetScrollInfoMax, _GUIScrollBars_GetScrollRange
; Link ..........: @@MsdnLink@@ SetScrollRange
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_SetScrollRange($hWnd, $nBar, $nMinPos, $nMaxPos)
	Local $aResult = DllCall("user32.dll", "bool", "SetScrollRange", "hwnd", $hWnd, "int", $nBar, "int", $nMinPos, "int", $nMaxPos, "bool", True)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_GUIScrollBars_SetScrollRange

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIScrollBars_ShowScrollBar
; Description ...: Shows or hides the specified scroll bar
; Syntax.........: _GUIScrollBars_ShowScrollBar($hWnd, $nBar[, $fShow = True])
; Parameters ....: $hWnd   - Handle to the window
;                  $nBar   - Specifies the type of scroll bar. This parameter can be one of the following values:
;                  |  $SB_BOTH - Shows or hides a window's standard horizontal and vertical scroll bars.
;                  |  $SB_CTL  - Shows or hides a scroll bar control. The $hWnd parameter must be the handle to the scroll bar control.
;                  |  $SB_HORZ - Shows or hides a window's standard horizontal scroll bars.
;                  |  $SB_VERT - Shows or hides a window's standard vertical scroll bar.
;                  $fShow - Specifies whether the scroll bar is shown or hidden
; Return values .: Success - True
;                  Failure - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Above constants require ScrollBarConstants.au3
; Related .......: _GUIScrollBars_EnableScrollBar
; Link ..........: @@MsdnLink@@ ShowScrollBar
; Example .......: Yes
; ===============================================================================================================================
Func _GUIScrollBars_ShowScrollBar($hWnd, $nBar, $fShow = True)
	Local $aResult = DllCall("user32.dll", "bool", "ShowScrollBar", "hwnd", $hWnd, "int", $nBar, "bool", $fShow)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_GUIScrollBars_ShowScrollBar
