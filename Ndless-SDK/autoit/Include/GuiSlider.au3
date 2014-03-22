#include-once

#include "SliderConstants.au3"
#include "WinAPI.au3"
#include "StructureConstants.au3"
#include "SendMessage.au3"
#include "UDFGlobalID.au3"

; #INDEX# =======================================================================================================================
; Title .........: Slider
; AutoIt Version : 3.3.7.20++
; Language ......: English
; Description ...: Functions that assist with Slider Control "Trackbar" management.
; Author(s) .....: Gary Frost (gafrost)
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $_ghSLastWnd
Global $Debug_S = False
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__SLIDERCONSTANT_ClassName = "msctls_trackbar32"
; ===============================================================================================================================

; #OLD_FUNCTIONS#================================================================================================================
; Old Function/Name                      ; --> New Function/Name/Replacement(s)
;
; deprecated functions will no longer work
;_GUICtrlSliderClearTics                  ; --> _GUICtrlSlider_ClearTics
;_GUICtrlSliderGetLineSize                ; --> _GUICtrlSlider_GetLineSize
;_GUICtrlSliderGetNumTics                 ; --> _GUICtrlSlider_GetNumTics
;_GUICtrlSliderGetPageSize                ; --> _GUICtrlSlider_GetPageSize
;_GUICtrlSliderGetPos                     ; --> _GUICtrlSlider_GetPos
;_GUICtrlSliderGetRangeMax                ; --> _GUICtrlSlider_GetRangeMax
;_GUICtrlSliderGetRangeMin                ; --> _GUICtrlSlider_GetRangeMin
;_GUICtrlSliderSetLineSize                ; --> _GUICtrlSlider_SetLineSize
;_GUICtrlSliderSetPageSize                ; --> _GUICtrlSlider_SetPageSize
;_GUICtrlSliderSetPos                     ; --> _GUICtrlSlider_SetPos
;_GUICtrlSliderSetTicFreq                 ; --> _GUICtrlSlider_SetTicFreq
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_GUICtrlSlider_ClearSel
;_GUICtrlSlider_ClearTics
;_GUICtrlSlider_Create
;_GUICtrlSlider_Destroy
;_GUICtrlSlider_GetBuddy
;_GUICtrlSlider_GetChannelRect
;_GUICtrlSlider_GetChannelRectEx
;_GUICtrlSlider_GetLineSize
;_GUICtrlSlider_GetLogicalTics
;_GUICtrlSlider_GetNumTics
;_GUICtrlSlider_GetPageSize
;_GUICtrlSlider_GetPos
;_GUICtrlSlider_GetRange
;_GUICtrlSlider_GetRangeMax
;_GUICtrlSlider_GetRangeMin
;_GUICtrlSlider_GetSel
;_GUICtrlSlider_GetSelEnd
;_GUICtrlSlider_GetSelStart
;_GUICtrlSlider_GetThumbLength
;_GUICtrlSlider_GetThumbRect
;_GUICtrlSlider_GetThumbRectEx
;_GUICtrlSlider_GetTic
;_GUICtrlSlider_GetTicPos
;_GUICtrlSlider_GetToolTips
;_GUICtrlSlider_GetUnicodeFormat
;_GUICtrlSlider_SetBuddy
;_GUICtrlSlider_SetLineSize
;_GUICtrlSlider_SetPageSize
;_GUICtrlSlider_SetPos
;_GUICtrlSlider_SetRange
;_GUICtrlSlider_SetRangeMax
;_GUICtrlSlider_SetRangeMin
;_GUICtrlSlider_SetSel
;_GUICtrlSlider_SetSelEnd
;_GUICtrlSlider_SetSelStart
;_GUICtrlSlider_SetThumbLength
;_GUICtrlSlider_SetTic
;_GUICtrlSlider_SetTicFreq
;_GUICtrlSlider_SetTipSide
;_GUICtrlSlider_SetToolTips
;_GUICtrlSlider_SetUnicodeFormat
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_ClearSel
; Description ...: Clears the current selection range
; Syntax.........: _GUICtrlSlider_ClearSel($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlSlider_SetSel, _GUICtrlSlider_SetSelEnd, _GUICtrlSlider_SetSelStart
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_ClearSel($hWnd)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $TBM_CLEARSEL, True)
EndFunc   ;==>_GUICtrlSlider_ClearSel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_ClearTics
; Description ...: Removes the current tick marks from a slider
; Syntax.........: _GUICtrlSlider_ClearTics($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: This does not remove the first and last tick marks, which are created automatically
; Related .......: _GUICtrlSlider_SetTic, _GUICtrlSlider_SetTicFreq
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_ClearTics($hWnd)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $TBM_CLEARTICS, True)
EndFunc   ;==>_GUICtrlSlider_ClearTics

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_Create
; Description ...: Create a Slider control
; Syntax.........: _GUICtrlSlider_Create($hWnd, $iX, $iY[, $iWidth = 100[, $iHeight = 20[, $iStyle = 0x0001[, $iExStyle = 0x00000000]]]])
; Parameters ....: $hWnd        - Handle to parent or owner window
;                  $iX          - Horizontal position of the control
;                  $iY          - Vertical position of the control
;                  $iWidth      - Control width
;                  $iHeight     - Control height
;                  $iStyle      - Control style:
;                  |$TBS_AUTOTICKS      - Adds tick marks when you set the range on the slider by using the TBM_SETRANGE message.
;                  |$TBS_BOTH           - Places ticks on both sides of the slider.
;                  |$TBS_BOTTOM         - Places ticks on the bottom of a horizontal slider.
;                  |$TBS_DOWNISLEFT     - Down equal left and up equal right
;                  |$TBS_ENABLESELRANGE - The tick marks at the starting and ending positions of a selection range are displayed as triangles
;                  +(instead of vertical dashes), and the selection range is highlighted
;                  |$TBS_FIXEDLENGTH    - allows the size of the slider to be changed with the $TBM_SETTHUMBLENGTH message
;                  |$TBS_HORZ           - Specifies a horizontal slider. This is the default.
;                  |$TBS_LEFT           - Places ticks on the left side of a vertical slider.
;                  |$TBS_NOTHUMB        - Specifies that the slider has no slider.
;                  |$TBS_NOTICKS        - Specifies that no ticks are placed on the slider.
;                  |$TBS_REVERSED       - Smaller number indicates "higher" and a larger number indicates "lower"
;                  |$TBS_RIGHT          - Places ticks on the right side of a vertical slider.
;                  |$TBS_TOP            - Places ticks on the top of a horizontal slider.
;                  |$TBS_TOOLTIPS       - Creates a default ToolTip control that displays the slider's current position
;                  |$TBS_VERT           - Places ticks on the left side of a vertical slider.
;                  -
;                  |Default: $TBS_AUTOTICKS
;                  |Forced : $WS_CHILD, $WS_TABSTOP, $WS_VISIBLE
;                  -
;                  $iExStyle    - Control extended style. These correspond to the standard $WS_EX_ constants.
;                  |Default: $WS_EX_STATICEDGE
; Return values .: Success      - Handle to the Slider control
;                  Failure      - 0
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: This function is for Advanced users and for learning how the control works.
; Related .......: _GUICtrlSlider_Destroy
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_Create($hWnd, $iX, $iY, $iWidth = 100, $iHeight = 20, $iStyle = 0x0001, $iExStyle = 0x00000000)
	If Not IsHWnd($hWnd) Then Return SetError(1, 0, 0) ; Invalid Window handle for _GUICtrlSlider_Create 1st parameter

	If $iWidth = -1 Then $iWidth = 100
	If $iHeight = -1 Then $iHeight = 20
	If $iStyle = -1 Then $iStyle = $TBS_AUTOTICKS
	If $iExStyle = -1 Then $iExStyle = 0x00000000

	$iStyle = BitOR($iStyle, $__UDFGUICONSTANT_WS_CHILD, $__UDFGUICONSTANT_WS_VISIBLE)

	Local $nCtrlID = __UDF_GetNextGlobalID($hWnd)
	If @error Then Return SetError(@error, @extended, 0)

	Local $hSlider = _WinAPI_CreateWindowEx($iExStyle, $__SLIDERCONSTANT_ClassName, "", $iStyle, $iX, $iY, $iWidth, $iHeight, $hWnd, $nCtrlID)
	_SendMessage($hSlider, $TBM_SETRANGE, True, _WinAPI_MakeLong(0, 100));  // min. & max. positions
	_GUICtrlSlider_SetTicFreq($hSlider, 5)
	Return $hSlider
EndFunc   ;==>_GUICtrlSlider_Create

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_Destroy
; Description ...: Delete the control
; Syntax.........: _GUICtrlSlider_Destroy(ByRef $hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True, Handle is set to 0
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Restricted to only be used on slider created with _GUICtrlSlider_Create
; Related .......: _GUICtrlSlider_Create
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_Destroy(ByRef $hWnd)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not _WinAPI_IsClassName($hWnd, $__SLIDERCONSTANT_ClassName) Then Return SetError(2, 2, False)

	Local $Destroyed = 0
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_ghSLastWnd) Then
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
EndFunc   ;==>_GUICtrlSlider_Destroy

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_GetBuddy
; Description ...: Retrieves the handle to a slider control buddy window at a given location
; Syntax.........: _GUICtrlSlider_GetBuddy($hWnd, $fLocation)
; Parameters ....: $hWnd        - Handle to the control
;                  $fLocation   - Which buddy window handle will be retrieved. This value can be one of the following:
;                  | True       - Retrieves the handle to the buddy to the left of the slider.
;                  +If the slider control uses the $TBS_VERT style, the message will retrieve the buddy above the slider.
;                  |False       - Retrieves the handle to the buddy to the right of the slider.
;                  +If the slider control uses the $TBS_VERT style, the message will retrieve the buddy below the slider.
; Return values .: Success      - Returns the handle to the buddy window at the location specified by $fLocation
;                  Failure      - 0
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlSlider_SetBuddy
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_GetBuddy($hWnd, $fLocation)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TBM_GETBUDDY, $fLocation, 0, 0, "wparam", "lparam", "hwnd")
EndFunc   ;==>_GUICtrlSlider_GetBuddy

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_GetChannelRect
; Description ...: Retrieves the size and position of the bounding rectangle for a sliders's channel
; Syntax.........: _GUICtrlSlider_GetChannelRect($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Array in the following format:
;                  |[0] - X coordinate of the upper left corner of the rectangle
;                  |[1] - Y coordinate of the upper left corner of the rectangle
;                  |[2] - X coordinate of the lower right corner of the rectangle
;                  |[3] - Y coordinate of the lower right corner of the rectangle
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlSlider_GetChannelRectEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_GetChannelRect($hWnd)
	Local $tRect = _GUICtrlSlider_GetChannelRectEx($hWnd)
	Local $aRect[4]
	$aRect[0] = DllStructGetData($tRect, "Left")
	$aRect[1] = DllStructGetData($tRect, "Top")
	$aRect[2] = DllStructGetData($tRect, "Right")
	$aRect[3] = DllStructGetData($tRect, "Bottom")
	Return $aRect
EndFunc   ;==>_GUICtrlSlider_GetChannelRect

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_GetChannelRectEx
; Description ...: Retrieves the size and position of the bounding rectangle for a sliders's channel
; Syntax.........: _GUICtrlSlider_GetChannelRectEx($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - $tagRECT structure that receives the channel coordinates
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlSlider_GetChannelRect, $tagRECT
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_GetChannelRectEx($hWnd)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tRect = DllStructCreate($tagRECT)
	_SendMessage($hWnd, $TBM_GETCHANNELRECT, 0, $tRect, 0, "wparam", "struct*")
	Return $tRect
EndFunc   ;==>_GUICtrlSlider_GetChannelRectEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_GetLineSize
; Description ...: Retrieves the number of logical positions the slider moves
; Syntax.........: _GUICtrlSlider_GetLineSize($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Line size for the slider
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The default setting for the line size is 1
; Related .......: _GUICtrlSlider_SetLineSize
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_GetLineSize($hWnd)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TBM_GETLINESIZE)
EndFunc   ;==>_GUICtrlSlider_GetLineSize

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_GetLogicalTics
; Description ...: Retrieves an array that contains the logical positions of the tick marks for a slider
; Syntax.........: _GUICtrlSlider_GetLogicalTics($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Returns array logical positions
;                  Failure      - @error is set
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: The number of elements in the array is two less than the tick count returned by the
;                  _GUICtrlSlider_GetNumTics function. Note that the values in the array may include duplicate
;                  positions and may not be in sequential order. The data in the returned array is valid until
;                  you change the slider's tick marks
;+
;                  The elements of the array specify the logical positions of the sliders's tick marks, not including
;                  the first and last tick marks created by the slider. The logical positions can be any of the integer
;                  values in the sliders's range of minimum to maximum slider positions.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_GetLogicalTics($hWnd)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $iArraySize = _GUICtrlSlider_GetNumTics($hWnd) - 2
	Local $aTics[$iArraySize]

	Local $pArray = _SendMessage($hWnd, $TBM_GETPTICS)
	If @error Then Return SetError(@error, @extended, $aTics)
	Local $tArray = DllStructCreate("dword[" & $iArraySize & "]", $pArray)
	For $x = 1 To $iArraySize
		$aTics[$x - 1] = _GUICtrlSlider_GetTicPos($hWnd, DllStructGetData($tArray, 1, $x))
	Next
	Return $aTics
EndFunc   ;==>_GUICtrlSlider_GetLogicalTics

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_GetNumTics
; Description ...: Retrieves the number of tick marks from a slider
; Syntax.........: _GUICtrlSlider_GetNumTics($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - 	If no tick flag is set, it returns 2 for the beginning and ending ticks.
;                  |If $TBS_NOTICKS is set, it returns zero.
;                  |Otherwise, it takes the difference between the range minimum and maximum, divides
;                  |by the tick frequency, and adds 2.
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlSlider_SetTicFreq
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_GetNumTics($hWnd)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TBM_GETNUMTICS)
EndFunc   ;==>_GUICtrlSlider_GetNumTics

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_GetPageSize
; Description ...: Retrieves the number of logical positions the slider moves
; Syntax.........: _GUICtrlSlider_GetPageSize($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The page size for the slider
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlSlider_SetPageSize
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_GetPageSize($hWnd)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TBM_GETPAGESIZE)
EndFunc   ;==>_GUICtrlSlider_GetPageSize

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_GetPos
; Description ...: Retrieves the logical position the slider
; Syntax.........: _GUICtrlSlider_GetPos($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The current logical position of the slider
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlSlider_SetPos
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_GetPos($hWnd)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TBM_GETPOS)
EndFunc   ;==>_GUICtrlSlider_GetPos

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_GetRange
; Description ...: Retrieves the maximum and minimum position for the slider
; Syntax.........: _GUICtrlSlider_GetRange($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The array in the following format:
;                  |[0]         - Minimum position in the slider's range of minimum to maximum slider positions
;                  |[1]         - Maximum position in the slider's range of minimum to maximum slider positions
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlSlider_SetRange, _GUICtrlSlider_GetRangeMax, _GUICtrlSlider_GetRangeMin
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_GetRange($hWnd)
	Local $aMinMax[2]
	$aMinMax[0] = _GUICtrlSlider_GetRangeMin($hWnd)
	$aMinMax[1] = _GUICtrlSlider_GetRangeMax($hWnd)
	Return $aMinMax
EndFunc   ;==>_GUICtrlSlider_GetRange

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_GetRangeMax
; Description ...: Retrieves the maximum position for the slider
; Syntax.........: _GUICtrlSlider_GetRangeMax($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The maximum position in the slider's range of minimum to maximum slider positions
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlSlider_SetRangeMax, _GUICtrlSlider_GetRange
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_GetRangeMax($hWnd)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TBM_GETRANGEMAX)
EndFunc   ;==>_GUICtrlSlider_GetRangeMax

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_GetRangeMin
; Description ...: Retrieves the minimum position for the slider
; Syntax.........: _GUICtrlSlider_GetRangeMin($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The minimum position in the slider's range of minimum to maximum slider positions
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlSlider_SetRangeMin, _GUICtrlSlider_GetRange
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_GetRangeMin($hWnd)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TBM_GETRANGEMIN)
EndFunc   ;==>_GUICtrlSlider_GetRangeMin

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_GetSel
; Description ...: Retrieves the ending and starting position of the current selection range
; Syntax.........: _GUICtrlSlider_GetSel($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Array in the following format:
;                  |[0]         - The starting position of the current selection range
;                  |[1]         - The ending position of the current selection range
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlSlider_SetSel, _GUICtrlSlider_SetSelEnd, _GUICtrlSlider_SetSelStart
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_GetSel($hWnd)
	Local $aSelStartEnd[2]
	$aSelStartEnd[0] = _GUICtrlSlider_GetSelStart($hWnd)
	$aSelStartEnd[1] = _GUICtrlSlider_GetSelEnd($hWnd)

	Return $aSelStartEnd
EndFunc   ;==>_GUICtrlSlider_GetSel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_GetSelEnd
; Description ...: Retrieves the ending position of the current selection range
; Syntax.........: _GUICtrlSlider_GetSelEnd($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The ending position of the current selection range
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlSlider_SetSelEnd
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_GetSelEnd($hWnd)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TBM_GETSELEND)
EndFunc   ;==>_GUICtrlSlider_GetSelEnd

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_GetSelStart
; Description ...: Retrieves the starting position of the current selection range
; Syntax.........: _GUICtrlSlider_GetSelStart($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The starting position of the current selection range
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlSlider_SetSelStart
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_GetSelStart($hWnd)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TBM_GETSELSTART)
EndFunc   ;==>_GUICtrlSlider_GetSelStart

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_GetThumbLength
; Description ...: Retrieves the length of the slider
; Syntax.........: _GUICtrlSlider_GetThumbLength($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The length, in pixels, of the slider
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlSlider_SetThumbLength
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_GetThumbLength($hWnd)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TBM_GETTHUMBLENGTH)
EndFunc   ;==>_GUICtrlSlider_GetThumbLength

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_GetThumbRect
; Description ...: Retrieves the size and position of the bounding rectangle for the slider
; Syntax.........: _GUICtrlSlider_GetThumbRect($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Array in the following format:
;                  |[0] - X coordinate of the upper left corner of the rectangle
;                  |[1] - Y coordinate of the upper left corner of the rectangle
;                  |[2] - X coordinate of the lower right corner of the rectangle
;                  |[3] - Y coordinate of the lower right corner of the rectangle
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlSlider_GetThumbRectEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_GetThumbRect($hWnd)
	Local $tRect = _GUICtrlSlider_GetThumbRectEx($hWnd)
	Local $aRect[4]
	$aRect[0] = DllStructGetData($tRect, "Left")
	$aRect[1] = DllStructGetData($tRect, "Top")
	$aRect[2] = DllStructGetData($tRect, "Right")
	$aRect[3] = DllStructGetData($tRect, "Bottom")
	Return $aRect
EndFunc   ;==>_GUICtrlSlider_GetThumbRect

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_GetThumbRectEx
; Description ...: Retrieves the size and position of the bounding rectangle for the slider
; Syntax.........: _GUICtrlSlider_GetThumbRectEx($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - $tagRECT structure that receives the bounding rectangle of the slider in client coordinates
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlSlider_GetThumbRect, $tagRECT
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_GetThumbRectEx($hWnd)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tRect = DllStructCreate($tagRECT)
	_SendMessage($hWnd, $TBM_GETTHUMBRECT, 0, $tRect, 0, "wparam", "struct*")
	Return $tRect
EndFunc   ;==>_GUICtrlSlider_GetThumbRectEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_GetTic
; Description ...: Retrieves the logical position of a tick mark
; Syntax.........: _GUICtrlSlider_GetTic($hWnd, $iTic)
; Parameters ....: $hWnd        - Handle to the control
;                  $iTic        - Zero-based index identifying a tick mark
;                  +Valid indexes are in the range from zero to two less than the tick count returned by the
;                  +_GUICtrlSlider_GetNumTics function.
; Return values .: Success      - The logical position of the specified tick mark
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlSlider_SetTic
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_GetTic($hWnd, $iTic)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TBM_GETTIC, $iTic)
EndFunc   ;==>_GUICtrlSlider_GetTic

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_GetTicPos
; Description ...: Retrieves the current physical position of a tick mark
; Syntax.........: _GUICtrlSlider_GetTicPos($hWnd, $iTic)
; Parameters ....: $hWnd        - Handle to the control
;                  $iTic        - Zero-based index identifying a tick mark. The positions of the first and last tick
;                  +marks are not directly available via this message.
; Return values .: Success      - The following values for type of slider:
;                  |horizontal  - The x-coordinate of the tick mark
;                  |vertical    - The y-coordinate of the tick mark
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Because the first and last tick marks are not available through this function, valid indexes are offset
;                  from their tick position on the slider. If the difference between _GUICtrlSlider_GetRangeMin and
;                  _GUICtrlSlider_GetRangeMax is less than two, then there is no valid index and this message will fail.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_GetTicPos($hWnd, $iTic)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TBM_GETTICPOS, $iTic)
EndFunc   ;==>_GUICtrlSlider_GetTicPos

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_GetToolTips
; Description ...: Retrieves the handle to the ToolTip control assigned to the slider, if any.
; Syntax.........: _GUICtrlSlider_GetToolTips($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - the handle to the ToolTip control assigned to the slider
;                  Failure      - 0
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If the slider control does not use the $TBS_TOOLTIPS style, the return value is 0.
; Related .......: _GUICtrlSlider_SetToolTips
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_GetToolTips($hWnd)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TBM_GETTOOLTIPS, 0, 0, 0, "wparam", "lparam", "hwnd")
EndFunc   ;==>_GUICtrlSlider_GetToolTips

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_GetUnicodeFormat
; Description ...: Retrieves the Unicode character format flag for the control
; Syntax.........: _GUICtrlSlider_GetUnicodeFormat($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .:  True        - The control is using Unicode characters
;                  False        - The control is using ANSI characters
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlSlider_SetUnicodeFormat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_GetUnicodeFormat($hWnd)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TBM_GETUNICODEFORMAT) <> 0
EndFunc   ;==>_GUICtrlSlider_GetUnicodeFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_SetBuddy
; Description ...: Assigns a window as the buddy window for a slider control
; Syntax.........: _GUICtrlSlider_SetBuddy($hWnd, $fLocation, $hBuddy)
; Parameters ....: $hWnd        - Handle to the control
;                  $fLocation   - Following values:
;                  | True       - The buddy will appear to the left of the slider if the control uses the $TBS_HORZ style
;                  +The buddy will appear above the slider if the control uses the $TBS_VERT style
;                  |False       - The buddy will appear to the right of the slider if the control uses the $TBS_HORZ style
;                  +The buddy will appear below the slider if the control uses the $TBS_VERT style
;                  $hBuddy      - Handle to buddy control
; Return values .: Success      - The handle to the window that was previously assigned to the control at that location
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlSlider_GetBuddy
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_SetBuddy($hWnd, $fLocation, $hBuddy)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	If Not IsHWnd($hBuddy) Then $hBuddy = GUICtrlGetHandle($hBuddy)

	Return _SendMessage($hWnd, $TBM_SETBUDDY, $fLocation, $hBuddy, 0, "wparam", "hwnd", "hwnd")
EndFunc   ;==>_GUICtrlSlider_SetBuddy

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_SetLineSize
; Description ...: Sets the number of logical positions the slider moves
; Syntax.........: _GUICtrlSlider_SetLineSize($hWnd, $iLineSize)
; Parameters ....: $hWnd        - Handle to the control
;                  $iLineSize   - New line size
; Return values .: Success      - The previous line size
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The default setting for the line size is 1
; Related .......: _GUICtrlSlider_GetLineSize
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_SetLineSize($hWnd, $iLineSize)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TBM_SETLINESIZE, 0, $iLineSize)
EndFunc   ;==>_GUICtrlSlider_SetLineSize

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_SetPageSize
; Description ...: Sets the number of logical positions the slider moves
; Syntax.........: _GUICtrlSlider_SetPageSize($hWnd, $iPageSize)
; Parameters ....: $hWnd        - Handle to the control
;                  $iPageSize   - New page size
; Return values .: Success      - The previous page size
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlSlider_GetPageSize
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_SetPageSize($hWnd, $iPageSize)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TBM_SETPAGESIZE, 0, $iPageSize)
EndFunc   ;==>_GUICtrlSlider_SetPageSize

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_SetPos
; Description ...: Sets the current logical position of the slider
; Syntax.........: _GUICtrlSlider_SetPos($hWnd, $iPosition)
; Parameters ....: $hWnd        - Handle to the control
;                  $iPosition   - New logical position of the slider
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlSlider_GetPos
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_SetPos($hWnd, $iPosition)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $TBM_SETPOS, True, $iPosition)
EndFunc   ;==>_GUICtrlSlider_SetPos

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_SetRange
; Description ...: Sets the range of minimum and maximum logical positions for the slider
; Syntax.........: _GUICtrlSlider_SetRange($hWnd, $iMinimum, $iMaximum)
; Parameters ....: $hWnd        - Handle to the control
;                  $iMinimum    - Minimum position for the slider
;                  $iMaximum    - Maximum position for the slider
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If the current slider position is outside the new range, the _GUICtrlSlider_SetRange function
;                  sets the slider position to the new maximum or minimum value.
; Related .......: _GUICtrlSlider_GetRange, _GUICtrlSlider_SetRangeMax, _GUICtrlSlider_SetRangeMin
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_SetRange($hWnd, $iMinimum, $iMaximum)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $TBM_SETRANGE, True, _WinAPI_MakeLong($iMinimum, $iMaximum))
EndFunc   ;==>_GUICtrlSlider_SetRange

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_SetRangeMax
; Description ...: Sets the maximum logical position for the slider
; Syntax.........: _GUICtrlSlider_SetRangeMax($hWnd, $iMaximum)
; Parameters ....: $hWnd        - Handle to the control
;                  $iMaximum    - Maximum position for the slider
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If the current slider position is greater than the new maximum, the _GUICtrlSlider_SetRangeMax function
;                  sets the slider position to the new maximum value.
; Related .......: _GUICtrlSlider_GetRangeMax, _GUICtrlSlider_SetRange, _GUICtrlSlider_SetRangeMin
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_SetRangeMax($hWnd, $iMaximum)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $TBM_SETRANGEMAX, True, $iMaximum)
EndFunc   ;==>_GUICtrlSlider_SetRangeMax

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_SetRangeMin
; Description ...: Sets the minimum logical position for the slider
; Syntax.........: _GUICtrlSlider_SetRangeMin($hWnd, $iMinimum)
; Parameters ....: $hWnd        - Handle to the control
;                  $iMinimum    - Minimum position for the slider
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If the current slider position is less than the new minimum, the _GUICtrlSlider_SetRangeMin function
;                  sets the slider position to the new minimum value.
; Related .......: _GUICtrlSlider_GetRangeMin, _GUICtrlSlider_SetRange, _GUICtrlSlider_SetRangeMax
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_SetRangeMin($hWnd, $iMinimum)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $TBM_SETRANGEMIN, True, $iMinimum)
EndFunc   ;==>_GUICtrlSlider_SetRangeMin

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_SetSel
; Description ...: Sets the starting and ending positions for the available selection range
; Syntax.........: _GUICtrlSlider_SetSel($hWnd, $iMinimum, $iMaximum)
; Parameters ....: $hWnd        - Handle to the control
;                  $iMinimum    - Starting logical position for the selection range
;                  $iMaximum    - Ending logical position for the selection range
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: This function is ignored if the slider does not have the $TBS_ENABLESELRANGE style.
;                  _GUICtrlSlider_SetSel allows you to restrict the pointer to only a portion of the range
;                  available to the slider.
; Related .......: _GUICtrlSlider_GetSel, _GUICtrlSlider_SetSelEnd, _GUICtrlSlider_SetSelStart, _GUICtrlSlider_ClearSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_SetSel($hWnd, $iMinimum, $iMaximum)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $TBM_SETSEL, True, _WinAPI_MakeLong($iMinimum, $iMaximum))
EndFunc   ;==>_GUICtrlSlider_SetSel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_SetSelEnd
; Description ...: Sets the ending logical position of the current selection range
; Syntax.........: _GUICtrlSlider_SetSelEnd($hWnd, $iMaximum)
; Parameters ....: $hWnd        - Handle to the control
;                  $iMaximum    - Ending logical position for the selection range
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlSlider_GetSelEnd, _GUICtrlSlider_SetSel, _GUICtrlSlider_SetSelStart, _GUICtrlSlider_ClearSel, _GUICtrlSlider_GetSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_SetSelEnd($hWnd, $iMaximum)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $TBM_SETSELEND, True, $iMaximum)
EndFunc   ;==>_GUICtrlSlider_SetSelEnd

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_SetSelStart
; Description ...: Sets the starting logical position of the current selection range
; Syntax.........: _GUICtrlSlider_SetSelStart($hWnd, $iMinimum)
; Parameters ....: $hWnd        - Handle to the control
;                  $iMinimum    - Starting logical position for the selection range
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlSlider_GetSelStart, _GUICtrlSlider_SetSel, _GUICtrlSlider_SetSelEnd, _GUICtrlSlider_ClearSel, _GUICtrlSlider_GetSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_SetSelStart($hWnd, $iMinimum)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $TBM_SETSELSTART, True, $iMinimum)
EndFunc   ;==>_GUICtrlSlider_SetSelStart

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_SetThumbLength
; Description ...: Sets the length of the slider
; Syntax.........: _GUICtrlSlider_SetThumbLength($hWnd, $iLength)
; Parameters ....: $hWnd        - Handle to the control
;                  $iLength     - Length, in pixels, of the slider
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: This function is ignored if the trackbar does not have the $TBS_FIXEDLENGTH style
; Related .......: _GUICtrlSlider_GetThumbLength
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_SetThumbLength($hWnd, $iLength)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $TBM_SETTHUMBLENGTH, $iLength)
EndFunc   ;==>_GUICtrlSlider_SetThumbLength

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_SetTic
; Description ...: Sets a tick mark in a slider at the specified logical position
; Syntax.........: _GUICtrlSlider_SetTic($hWnd, $iPosition)
; Parameters ....: $hWnd        - Handle to the control
;                  $iPosition   - Position of the tick mark
;                  +This parameter can be any of the integer values in the slider's range of minimum to maximum positions
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: A slider creates its own first and last tick marks.
;                  Do not use this message to set the first and last tick marks.
; Related .......: _GUICtrlSlider_GetTic, _GUICtrlSlider_ClearTics
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_SetTic($hWnd, $iPosition)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $TBM_SETTIC, 0, $iPosition)
EndFunc   ;==>_GUICtrlSlider_SetTic

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_SetTicFreq
; Description ...: Sets the interval frequency for tick marks in a slider
; Syntax.........: _GUICtrlSlider_SetTicFreq($hWnd, $iFreg)
; Parameters ....: $hWnd        - Handle to the control
;                  $iFreg       - Frequency of the tick marks.
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The slider must have the $TBS_AUTOTICKS style to use this function
; Related .......: _GUICtrlSlider_GetNumTics, _GUICtrlSlider_ClearTics
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_SetTicFreq($hWnd, $iFreg)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $TBM_SETTICFREQ, $iFreg)
EndFunc   ;==>_GUICtrlSlider_SetTicFreq

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_SetTipSide
; Description ...: Positions a ToolTip control
; Syntax.........: _GUICtrlSlider_SetTipSide($hWnd, $fLocation)
; Parameters ....: $hWnd        - Handle to the control
;                  $fLocation   - The location at which to display the ToolTip control. This value can be one of the following:
;                  |$TBTS_TOP    - Will be positioned above the slider. This flag is for use with horizontal sliders.
;                  |$TBTS_LEFT   - Will be positioned to the left of the slider. This flag is for use with vertical sliders.
;                  |$TBTS_BOTTOM - Will be positioned below the slider This flag is for use with horizontal sliders.
;                  |$TBTS_RIGHT  - Will be positioned to the right of the slider. This flag is for use with vertical sliders.
; Return values .: Success      - The ToolTip control's previous location
;                  +The return value equals one of the possible values for $fLocation
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Use the $TBS_TOOLTIPS style display ToolTips
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_SetTipSide($hWnd, $fLocation)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $TBM_SETTIPSIDE, $fLocation)
EndFunc   ;==>_GUICtrlSlider_SetTipSide

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_SetToolTips
; Description ...: Assigns a ToolTip control to a slider control
; Syntax.........: _GUICtrlSlider_SetToolTips($hWnd, $hWndTT)
; Parameters ....: $hWnd        - Handle to the control
;                  $hWndTT      - Handle to an existing ToolTip control
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: When a slidert control is created with the $TBS_TOOLTIPS style, it creates a default ToolTip control
;                  that appears next to the slider, displaying the slider's current position.
; Related .......: _GUICtrlSlider_GetToolTips
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_SetToolTips($hWnd, $hWndTT)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $TBM_SETTOOLTIPS, $hWndTT, 0, 0, "hwnd")
EndFunc   ;==>_GUICtrlSlider_SetToolTips

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlSlider_SetUnicodeFormat
; Description ...: Sets the Unicode character format flag for the control
; Syntax.........: _GUICtrlSlider_SetUnicodeFormat($hWnd, $fUnicode)
; Parameters ....: $hWnd        - Handle to the control
;                  $fUnicode    - Determines the character set that is used by the control:
;                  | True       - The control will use Unicode characters
;                  |False       - The control will use ANSI characters
; Return values .: Success      - The previous Unicode format flag for the control
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlSlider_GetUnicodeFormat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlSlider_SetUnicodeFormat($hWnd, $fUnicode)
	If $Debug_S Then __UDF_ValidateClassName($hWnd, $__SLIDERCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $TBM_SETUNICODEFORMAT, $fUnicode) <> 0
EndFunc   ;==>_GUICtrlSlider_SetUnicodeFormat
