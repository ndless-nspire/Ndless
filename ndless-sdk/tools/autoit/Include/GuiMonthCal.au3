#include-once

#include "DateTimeConstants.au3"
#include "Memory.au3"
#include "WinAPI.au3"
#include "StructureConstants.au3"
#include "SendMessage.au3"
#include "UDFGlobalID.au3"

; #INDEX# =======================================================================================================================
; Title .........: MonthCalendar
; AutoIt Version : 3.3.7.20++
; Language ......: English
; Description ...: Functions that assist with MonthCalendar control management.
;                  A month calendar control implements a calendar-like user  interface.  This  provides  the  user  with  a  very
;                  intuitive and recognizable method of entering or selecting a date.  The control also provides the  application
;                  with the means to obtain and set the date information in the control using existing data types.
; Author(s) .....: Paul Campbell (PaulIA), Gary Frost (gafrost)
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $_mc_ghMCLastWnd
Global $Debug_MC = False
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__MONTHCALCONSTANT_ClassName = "SysMonthCal32"
Global Const $__MONTHCALCONSTANT_SWP_NOZORDER = 0x0004
; ===============================================================================================================================

; #OLD_FUNCTIONS#================================================================================================================
; Old Function/Name                      ; --> New Function/Name/Replacement(s)
;
; deprecated functions functions will no longer work
;_GUICtrlMonthCalGet1stDOW              ; --> _GUICtrlMonthCal_GetFirstDOWStr
;_GUICtrlMonthCalGetColor               ; --> _GUICtrlMonthCal_GetColorArray
;_GUICtrlMonthCalGetMaxSelCount         ; --> _GUICtrlMonthCal_GetMaxSelCount
;_GUICtrlMonthCalGetMaxTodayWidth       ; --> _GUICtrlMonthCal_GetMaxTodayWidth
;_GUICtrlMonthCalGetMinReqRECT          ; --> _GUICtrlMonthCal_GetMinReqRectArray
;_GUICtrlMonthCalGetDelta               ; --> _GUICtrlMonthCal_GetMonthDelta
;_GUICtrlMonthCalSetColor               ; --> _GUICtrlMonthCal_SetColor
;_GUICtrlMonthCalSet1stDOW              ; --> _GUICtrlMonthCal_SetFirstDOW
;_GUICtrlMonthCalSetMaxSelCount         ; --> _GUICtrlMonthCal_SetMaxSelCount
;_GUICtrlMonthCalSetDelta               ; --> _GUICtrlMonthCal_SetMonthDelta
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_GUICtrlMonthCal_Create
;_GUICtrlMonthCal_Destroy
;_GUICtrlMonthCal_GetCalendarBorder
;_GUICtrlMonthCal_GetCalendarCount
;_GUICtrlMonthCal_GetColor
;_GUICtrlMonthCal_GetColorArray
;_GUICtrlMonthCal_GetCurSel
;_GUICtrlMonthCal_GetCurSelStr
;_GUICtrlMonthCal_GetFirstDOW
;_GUICtrlMonthCal_GetFirstDOWStr
;_GUICtrlMonthCal_GetMaxSelCount
;_GUICtrlMonthCal_GetMaxTodayWidth
;_GUICtrlMonthCal_GetMinReqHeight
;_GUICtrlMonthCal_GetMinReqRect
;_GUICtrlMonthCal_GetMinReqRectArray
;_GUICtrlMonthCal_GetMinReqWidth
;_GUICtrlMonthCal_GetMonthDelta
;_GUICtrlMonthCal_GetMonthRange
;_GUICtrlMonthCal_GetMonthRangeMax
;_GUICtrlMonthCal_GetMonthRangeMaxStr
;_GUICtrlMonthCal_GetMonthRangeMin
;_GUICtrlMonthCal_GetMonthRangeMinStr
;_GUICtrlMonthCal_GetMonthRangeSpan
;_GUICtrlMonthCal_GetRange
;_GUICtrlMonthCal_GetRangeMax
;_GUICtrlMonthCal_GetRangeMaxStr
;_GUICtrlMonthCal_GetRangeMin
;_GUICtrlMonthCal_GetRangeMinStr
;_GUICtrlMonthCal_GetSelRange
;_GUICtrlMonthCal_GetSelRangeMax
;_GUICtrlMonthCal_GetSelRangeMaxStr
;_GUICtrlMonthCal_GetSelRangeMin
;_GUICtrlMonthCal_GetSelRangeMinStr
;_GUICtrlMonthCal_GetToday
;_GUICtrlMonthCal_GetTodayStr
;_GUICtrlMonthCal_GetUnicodeFormat
;_GUICtrlMonthCal_HitTest
;_GUICtrlMonthCal_SetCalendarBorder
;_GUICtrlMonthCal_SetColor
;_GUICtrlMonthCal_SetCurSel
;_GUICtrlMonthCal_SetDayState
;_GUICtrlMonthCal_SetFirstDOW
;_GUICtrlMonthCal_SetMaxSelCount
;_GUICtrlMonthCal_SetMonthDelta
;_GUICtrlMonthCal_SetRange
;_GUICtrlMonthCal_SetSelRange
;_GUICtrlMonthCal_SetToday
;_GUICtrlMonthCal_SetUnicodeFormat
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;__GUICtrlMonthCal_Resize
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_Create
; Description ...: Creates a Month Calendar control
; Syntax.........: _GUICtrlMonthCal_Create($hWnd, $iX, $iY[, $iStyle = 0x00000000[, $iExStyle = 0x00000000]])
; Parameters ....: $hWnd        - Handle to parent or owner window
;                  $iX          - Horizontal position of the control
;                  $iY          - Vertical position of the control
;                  $iStyle      - Control styles:
;                  |$MCS_DAYSTATE      - The month calendar will send $MCN_GETDAYSTATE notifications to request information about
;                  +which days should be displayed in bold.
;                  |$MCS_MULTISELECT   - The month calendar will allow the user to select a range of dates within the control
;                  |$MCS_WEEKNUMBERS   - The month calendar control will display week numbers to the left of each row of days
;                  |$MCS_NOTODAYCIRCLE - The month calendar control will not circle the "today" date
;                  |$MCS_NOTODAY       - The month calendar control will not display the "today" date at the bottom
;                  -
;                  |Forced: $WS_CHILD, $WS_VISIBLE
;                  $iExStyle    - Control extended styles
; Return values .: Success      - The handle to the month calendar window
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......: This function is for Advanced users and for learning how the control works.
; Related .......: _GUICtrlMonthCal_Destroy, _GUICtrlMonthCal_GetColorArray
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_Create($hWnd, $iX, $iY, $iStyle = 0x00000000, $iExStyle = 0x00000000)
	If Not IsHWnd($hWnd) Then
		; Invalid Window handle for _GUICtrlMonthCal_Create 1st parameter
		Return SetError(1, 0, 0)
	EndIf

	Local $hMonCal, $nCtrlID

	If $iStyle = -1 Then $iStyle = 0x00000000
	If $iExStyle = -1 Then $iExStyle = 0x00000000

	$iStyle = BitOR($iStyle, $__UDFGUICONSTANT_WS_CHILD, $__UDFGUICONSTANT_WS_VISIBLE)

	$nCtrlID = __UDF_GetNextGlobalID($hWnd)
	If @error Then Return SetError(@error, @extended, 0)

	$hMonCal = _WinAPI_CreateWindowEx($iExStyle, $__MONTHCALCONSTANT_ClassName, "", $iStyle, $iX, $iY, 0, 0, $hWnd, $nCtrlID)
	__GUICtrlMonthCal_Resize($hMonCal, $iX, $iY)
	Return $hMonCal
EndFunc   ;==>_GUICtrlMonthCal_Create

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_Destroy
; Description ...: Delete the MonthCal control
; Syntax.........: _GUICtrlMonthCal_Destroy(ByRef $hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True, Handle is set to 0
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Restricted to only be used on Month Calendars created with _GUICtrlMonthCal_Create
; Related .......: _GUICtrlMonthCal_Create
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_Destroy(ByRef $hWnd)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	If Not _WinAPI_IsClassName($hWnd, $__MONTHCALCONSTANT_ClassName) Then Return SetError(2, 2, False)

	Local $Destroyed = 0
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_mc_ghMCLastWnd) Then
			Local $nCtrlID = _WinAPI_GetDlgCtrlID($hWnd)
			Local $hParent = _WinAPI_GetParent($hWnd)
			$Destroyed = _WinAPI_DestroyWindow($hWnd)
			Local $iRet = __UDF_FreeGlobalID($hParent, $nCtrlID)
			If Not $iRet Then
				; can check for errors here if needed, for debug
			EndIf
		Else
			; Not Allowed to Delete Other Applications Month Calendar(s) Control(s)
			Return SetError(1, 1, False)
		EndIf
	Else
		$Destroyed = GUICtrlDelete($hWnd)
	EndIf
	If $Destroyed Then $hWnd = 0
	Return $Destroyed <> 0
EndFunc   ;==>_GUICtrlMonthCal_Destroy

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetCalendarBorder
; Description ...: Gets the size of the border, in pixels
; Syntax.........: _GUICtrlMonthCal_GetCalendarBorder($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - Border size, in pixels
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Minimum Operating Systems: Windows Vista
; Related .......: _GUICtrlMonthCal_SetCalendarBorder
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetCalendarBorder($hWnd)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $MCM_GETCALENDARBORDER)
	Else
		Return GUICtrlSendMsg($hWnd, $MCM_GETCALENDARBORDER, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlMonthCal_GetCalendarBorder

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetCalendarCount
; Description ...: Gets the number of calendars currently displayed in the calendar control
; Syntax.........: _GUICtrlMonthCal_GetCalendarCount($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - Number of calendars currently displayed in the calendar control.  The maximum number of allowed calendars is 12
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Minimum Operating Systems: Windows Vista
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetCalendarCount($hWnd)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $MCM_GETCALENDARCOUNT)
	Else
		Return GUICtrlSendMsg($hWnd, $MCM_GETCALENDARCOUNT, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlMonthCal_GetCalendarCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetColor
; Description ...: Retrieves a given color for the control
; Syntax.........: _GUICtrlMonthCal_GetColor($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Indicates which month calendar color to retrieve:
;                  |$MCSC_BACKGROUND   - Background color displayed between months
;                  |$MCSC_TEXT         - Color used to display text within a month
;                  |$MCSC_TITLEBK      - Background color displayed in the calendar title
;                  |$MCSC_TITLETEXT    - Color used to display text within the calendar title
;                  |$MCSC_MONTHBK      - Background color displayed within the month
;                  |$MCSC_TRAILINGTEXT - Color used to display header day and trailing day text
; Return values .: Success      - Indicated color
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlMonthCal_SetColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetColor($hWnd, $iIndex)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $MCM_GETCOLOR, $iIndex)
	Else
		Return GUICtrlSendMsg($hWnd, $MCM_GETCOLOR, $iIndex, 0)
	EndIf
EndFunc   ;==>_GUICtrlMonthCal_GetColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetColorArray
; Description ...: Retrieves the color for a given portion of a month calendar control
; Syntax.........: _GUICtrlMonthCal_GetColorArray($hWnd, $iColor)
; Parameters ....: $hWnd        - Handle to the control
;                  $iColor      - Value of type int specifying which month calendar color to retrieve
;                  +This value can be one of the following:
;                  |$MCSC_BACKGROUND   - Retrieve the background color displayed between months.
;                  |$MCSC_MONTHBK      - Retrieve the background color displayed within the month.
;                  |$MCSC_TEXT         - Retrieve the color used to display text within a month.
;                  |$MCSC_TITLEBK      - Retrieve the background color displayed in the calendar's title.
;                  |$MCSC_TITLETEXT    - Retrieve the color used to display text within the calendar's title.
;                  |$MCSC_TRAILINGTEXT - Retrieve the color used to display header day and trailing day text.
; Return values .: Success      - Array in the following format:
;                  |[0] - contains the number returned
;                  |[1] - contains COLORREF rgbcolor
;                  |[2] - contains Hex BGR color
;                  |[3] - contains Hex RGB color
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Header and trailing days are the days from the previous and following
;                  months that appear on the current month calendar.
; Related .......: _GUICtrlMonthCal_Create
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetColorArray($hWnd, $iColor)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	Local $iRet, $a_result[4]
	$a_result[0] = 3
	If IsHWnd($hWnd) Then
		$iRet = _SendMessage($hWnd, $MCM_GETCOLOR, $iColor)
	Else
		$iRet = GUICtrlSendMsg($hWnd, $MCM_GETCOLOR, $iColor, 0)
	EndIf
	$a_result[1] = Int($iRet) ; COLORREF rgbcolor
	$a_result[2] = "0x" & Hex(String($iRet), 6) ; Hex BGR color
	$a_result[3] = Hex(String($iRet), 6)
	$a_result[3] = "0x" & StringMid($a_result[3], 5, 2) & StringMid($a_result[3], 3, 2) & StringMid($a_result[3], 1, 2) ; Hex RGB Color
	Return $a_result
EndFunc   ;==>_GUICtrlMonthCal_GetColorArray

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetCurSel
; Description ...: Retrieves the currently selected date
; Syntax.........:  _GUICtrlMonthCal_GetCurSel($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - $tagSYSTEMTIME structure
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlMonthCal_SetCurSel, _GUICtrlMonthCal_GetCurSelStr, $tagSYSTEMTIME
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetCurSel($hWnd)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)

	Local $tBuffer = DllStructCreate($tagSYSTEMTIME)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_mc_ghMCLastWnd) Then
			_SendMessage($hWnd, $MCM_GETCURSEL, 0, $tBuffer, 0, "wparam", "struct*")
		Else
			Local $iBuffer = DllStructGetSize($tBuffer)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iBuffer, $tMemMap)
			_SendMessage($hWnd, $MCM_GETCURSEL, 0, $pMemory, 0, "wparam", "ptr")
			_MemRead($tMemMap, $pMemory, $tBuffer, $iBuffer)
			_MemFree($tMemMap)
		EndIf
	Else
		GUICtrlSendMsg($hWnd, $MCM_GETCURSEL, 0, DllStructGetPtr($tBuffer))
	EndIf
	Return $tBuffer
EndFunc   ;==>_GUICtrlMonthCal_GetCurSel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetCurSelStr
; Description ...: Retrieves the currently selected date in string format
; Syntax.........: _GUICtrlMonthCal_GetCurSelStr($hWnd[, $sFormat = "%02d/%02d/%04d"])
; Parameters ....: $hWnd        - Handle to control
;                  $sFormat     - StringFormat string used to format the date
; Return values .: Success      - Date in the specified format
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetCurSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetCurSelStr($hWnd, $sFormat = "%02d/%02d/%04d")
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	Local $tBuffer = _GUICtrlMonthCal_GetCurSel($hWnd)
	Return StringFormat($sFormat, DllStructGetData($tBuffer, "Month"), DllStructGetData($tBuffer, "Day"), DllStructGetData($tBuffer, "Year"))
EndFunc   ;==>_GUICtrlMonthCal_GetCurSelStr

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetFirstDOW
; Description ...: Retrieves the first day of the week
; Syntax.........: _GUICtrlMonthCal_GetFirstDOW($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - One of the following values:
;                  |0 - Monday
;                  |1 - Tuesday
;                  |2 - Wednesday
;                  |3 - Thursday
;                  |4 - Friday
;                  |5 - Saturday
;                  |6 - Sunday
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlMonthCal_SetFirstDOW, _GUICtrlMonthCal_GetFirstDOWStr
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetFirstDOW($hWnd)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	If IsHWnd($hWnd) Then
		Return _WinAPI_LoWord(_SendMessage($hWnd, $MCM_GETFIRSTDAYOFWEEK))
	Else
		Return _WinAPI_LoWord(GUICtrlSendMsg($hWnd, $MCM_GETFIRSTDAYOFWEEK, 0, 0))
	EndIf
EndFunc   ;==>_GUICtrlMonthCal_GetFirstDOW

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetFirstDOWStr
; Description ...: Retrieves the first day of the week as a string
; Syntax.........: _GUICtrlMonthCal_GetFirstDOWStr($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - One of the following values:
;                  |Monday
;                  |Tuesday
;                  |Wednesday
;                  |Thursday
;                  |Friday
;                  |Saturday
;                  |Sunday
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetFirstDOW
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetFirstDOWStr($hWnd)
	Local $aDays[7] = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

	Return $aDays[_GUICtrlMonthCal_GetFirstDOW($hWnd)]
EndFunc   ;==>_GUICtrlMonthCal_GetFirstDOWStr

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetMaxSelCount
; Description ...: Retrieves the maximum date range that can be selected in a month calendar control
; Syntax.........: _GUICtrlMonthCal_GetMaxSelCount($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - INT value that represents the total number of days that can be selected for the control
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetMaxSelCount($hWnd)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $MCM_GETMAXSELCOUNT)
	Else
		Return GUICtrlSendMsg($hWnd, $MCM_GETMAXSELCOUNT, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlMonthCal_GetMaxSelCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetMaxTodayWidth
; Description ...: Retrieves the maximum width of the "today" string in a month calendar control
; Syntax.........: _GUICtrlMonthCal_GetMaxTodayWidth($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The width of the "today" string, in pixels
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetMaxTodayWidth($hWnd)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $MCM_GETMAXTODAYWIDTH)
	Else
		Return GUICtrlSendMsg($hWnd, $MCM_GETMAXTODAYWIDTH, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlMonthCal_GetMaxTodayWidth

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetMinReqHeight
; Description ...: Retrieves the minimum height required to display a full month
; Syntax.........: _GUICtrlMonthCal_GetMinReqHeight($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - Minimum height, in pixels
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetMinReqRect, _GUICtrlMonthCal_GetMinReqWidth
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetMinReqHeight($hWnd)
	Local $tRect = _GUICtrlMonthCal_GetMinReqRect($hWnd)
	Return DllStructGetData($tRect, "Bottom")
EndFunc   ;==>_GUICtrlMonthCal_GetMinReqHeight

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetMinReqRect
; Description ...: Retrieves the minimum size required to display a full month
; Syntax.........: _GUICtrlMonthCal_GetMinReqRect($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - $tagRECT structure
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetMinReqHeight, _GUICtrlMonthCal_GetMinReqWidth, $tagRECT
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetMinReqRect($hWnd)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)

	Local $tRect = DllStructCreate($tagRECT)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_mc_ghMCLastWnd) Then
			_SendMessage($hWnd, $MCM_GETMINREQRECT, 0, $tRect, 0, "wparam", "struct*")
		Else
			Local $iRect = DllStructGetSize($tRect)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iRect, $tMemMap)
			_SendMessage($hWnd, $MCM_GETMINREQRECT, 0, $pMemory, 0, "wparam", "ptr")
			_MemRead($tMemMap, $pMemory, $tRect, $iRect)
			_MemFree($tMemMap)
		EndIf
	Else
		GUICtrlSendMsg($hWnd, $MCM_GETMINREQRECT, 0, DllStructGetPtr($tRect))
	EndIf
	Return $tRect
EndFunc   ;==>_GUICtrlMonthCal_GetMinReqRect

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetMinReqRectArray
; Description ...: Retrieves the minimum size required to display a full month in a month calendar control
; Syntax.........: _GUICtrlMonthCal_GetMinReqRectArray($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True, Handle is set to 0
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The minimum required window size for a month calendar control depends on the currently selected font,
;                  control styles, system metrics, and regional settings.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetMinReqRectArray($hWnd)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	Local $v_ret
	Local $struct_RECT = DllStructCreate($tagRECT)
	If @error Then Return SetError(-1, -1, -1)
	If IsHWnd($hWnd) Then
		$v_ret = _SendMessage($hWnd, $MCM_GETMINREQRECT, 0, $struct_RECT, 0, "wparam", "struct*")
	Else
		$v_ret = GUICtrlSendMsg($hWnd, $MCM_GETMINREQRECT, 0, DllStructGetPtr($struct_RECT))
	EndIf
	If (Not $v_ret) Then Return SetError(-1, -1, -1)
	Return StringSplit(DllStructGetData($struct_RECT, "Left") & "," & DllStructGetData($struct_RECT, "Top") & "," & DllStructGetData($struct_RECT, "Right") & "," & DllStructGetData($struct_RECT, "Bottom"), ",")
EndFunc   ;==>_GUICtrlMonthCal_GetMinReqRectArray

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetMinReqWidth
; Description ...: Retrieves the minimum width required to display a full month
; Syntax.........: _GUICtrlMonthCal_GetMinReqWidth($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - Minimum width, in pixels
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetMinReqHeight, _GUICtrlMonthCal_GetMinReqRect
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetMinReqWidth($hWnd)
	Local $tRect = _GUICtrlMonthCal_GetMinReqRect($hWnd)
	Return DllStructGetData($tRect, "Right")
EndFunc   ;==>_GUICtrlMonthCal_GetMinReqWidth

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetMonthDelta
; Description ...: Retrieves the scroll rate for a month calendar control
; Syntax.........: _GUICtrlMonthCal_GetMonthDelta($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - If the month delta was previously set using the _GUICtrlMonthCal_SetMonthDelta,
;                  +returns an INT value that represents the month calendar's current scroll rate.
;                  +If the month delta was not previously set using the _GUICtrlMonthCal_SetMonthDelta,
;                  +or the month delta was reset to the default, returns an INT value that represents the current
;                  +number of months visible.
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetMonthDelta($hWnd)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $MCM_GETMONTHDELTA)
	Else
		Return GUICtrlSendMsg($hWnd, $MCM_GETMONTHDELTA, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlMonthCal_GetMonthDelta

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetMonthRange
; Description ...: Retrieves date information that represents the high and low display limits
; Syntax.........: _GUICtrlMonthCal_GetMonthRange($hWnd[, $fPartial = False])
; Parameters ....: $hWnd        - Handle to control
;                  $fPartial    - Specifies the scope of the range limits to be retrieved:
;                  | True - Preceding and trailing months are included
;                  |False - Only months that are entirely displayed are included
; Return values .: Success      - $tagMCMONTHRANGE structure
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetMonthRangeMax, _GUICtrlMonthCal_GetMonthRangeMin, $tagMCMONTHRANGE
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetMonthRange($hWnd, $fPartial = False)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)

	Local $tBuffer = DllStructCreate($tagMCMONTHRANGE)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_mc_ghMCLastWnd) Then
			DllStructSetData($tBuffer, "Span", _SendMessage($hWnd, $MCM_GETMONTHRANGE, $fPartial, $tBuffer, 0, "wparam", "struct*"))
		Else
			Local $iBuffer = DllStructGetSize($tBuffer)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iBuffer, $tMemMap)
			DllStructSetData($tBuffer, "Span", _SendMessage($hWnd, $MCM_GETMONTHRANGE, $fPartial, $pMemory, 0, "wparam", "ptr"))
			_MemRead($tMemMap, $pMemory, $tBuffer, $iBuffer)
			_MemFree($tMemMap)
		EndIf
	Else
		DllStructSetData($tBuffer, "Span", GUICtrlSendMsg($hWnd, $MCM_GETMONTHRANGE, $fPartial, DllStructGetPtr($tBuffer)))
	EndIf
	Return $tBuffer
EndFunc   ;==>_GUICtrlMonthCal_GetMonthRange

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetMonthRangeMax
; Description ...: Retrieves date information that represents the high limit of the controls display
; Syntax.........: _GUICtrlMonthCal_GetMonthRangeMax($hWnd[, $fPartial = False])
; Parameters ....: $hWnd        - Handle to control
;                  $fPartial    - Specifies the scope of the range limits to be retrieved:
;                  | True - Preceding and trailing months are included
;                  |False - Only months that are entirely displayed are included
; Return values .: Success      - $tagSYSTEMTIME structure
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetMonthRange, _GUICtrlMonthCal_GetMonthRangeMin, _GUICtrlMonthCal_GetMonthRangeMaxStr, $tagSYSTEMTIME
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetMonthRangeMax($hWnd, $fPartial = False)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)

	Local $tBuffer = _GUICtrlMonthCal_GetMonthRange($hWnd, $fPartial)
	Local $tRange = DllStructCreate($tagSYSTEMTIME)
	DllStructSetData($tRange, "Year", DllStructGetData($tBuffer, "MaxYear"))
	DllStructSetData($tRange, "Month", DllStructGetData($tBuffer, "MaxMonth"))
	DllStructSetData($tRange, "DOW", DllStructGetData($tBuffer, "MaxDOW"))
	DllStructSetData($tRange, "Day", DllStructGetData($tBuffer, "MaxDay"))
	Return $tRange
EndFunc   ;==>_GUICtrlMonthCal_GetMonthRangeMax

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetMonthRangeMaxStr
; Description ...: Retrieves date information that represents the high limit of the controls display in string format
; Syntax.........: _GUICtrlMonthCal_GetMonthRangeMaxStr($hWnd[, $sFormat = "%02d/%02d/%04d"])
; Parameters ....: $hWnd        - Handle to control
;                  $sFormat     - StringFormat string used to format the date
; Return values .: Success      - Date in the specified format
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetMonthRangeMax
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetMonthRangeMaxStr($hWnd, $sFormat = "%02d/%02d/%04d")
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	Local $tBuffer = _GUICtrlMonthCal_GetMonthRangeMax($hWnd)
	Return StringFormat($sFormat, DllStructGetData($tBuffer, "Month"), DllStructGetData($tBuffer, "Day"), DllStructGetData($tBuffer, "Year"))
EndFunc   ;==>_GUICtrlMonthCal_GetMonthRangeMaxStr

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetMonthRangeMin
; Description ...: Retrieves date information that represents the low limit of the controls display
; Syntax.........: _GUICtrlMonthCal_GetMonthRangeMin($hWnd[, $fPartial = False])
; Parameters ....: $hWnd        - Handle to control
;                  $fPartial    - Specifies the scope of the range limits to be retrieved:
;                  | True - Preceding and trailing months are included
;                  |False - Only months that are entirely displayed are included
; Return values .: Success      - $tagSYSTEMTIME structure
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetMonthRange, _GUICtrlMonthCal_GetMonthRangeMax, _GUICtrlMonthCal_GetMonthRangeMinStr, $tagSYSTEMTIME
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetMonthRangeMin($hWnd, $fPartial = False)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)

	Local $tBuffer = _GUICtrlMonthCal_GetMonthRange($hWnd, $fPartial)
	Local $tRange = DllStructCreate($tagSYSTEMTIME)
	DllStructSetData($tRange, "Year", DllStructGetData($tBuffer, "MinYear"))
	DllStructSetData($tRange, "Month", DllStructGetData($tBuffer, "MinMonth"))
	DllStructSetData($tRange, "DOW", DllStructGetData($tBuffer, "MinDOW"))
	DllStructSetData($tRange, "Day", DllStructGetData($tBuffer, "MinDay"))
	Return $tRange
EndFunc   ;==>_GUICtrlMonthCal_GetMonthRangeMin

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetMonthRangeMinStr
; Description ...: Retrieves date information that represents the low limit of the controls display in string format
; Syntax.........: _GUICtrlMonthCal_GetMonthRangeMinStr($hWnd[, $sFormat = "%02d/%02d/%04d"])
; Parameters ....: $hWnd        - Handle to control
;                  $sFormat     - StringFormat string used to format the date
; Return values .: Success      - Date in the specified format
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetMonthRangeMin
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetMonthRangeMinStr($hWnd, $sFormat = "%02d/%02d/%04d")
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	Local $tBuffer = _GUICtrlMonthCal_GetMonthRangeMin($hWnd)
	Return StringFormat($sFormat, DllStructGetData($tBuffer, "Month"), DllStructGetData($tBuffer, "Day"), DllStructGetData($tBuffer, "Year"))
EndFunc   ;==>_GUICtrlMonthCal_GetMonthRangeMinStr

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetMonthRangeSpan
; Description ...: Returns a value that represents the range, in months, spanned
; Syntax.........: _GUICtrlMonthCal_GetMonthRangeSpan($hWnd[, $fPartial = False])
; Parameters ....: $hWnd        - Handle to control
;                  $fPartial    - Specifies the scope of the range limits to be retrieved:
;                  | True - Preceding and trailing months are included
;                  |False - Only months that are entirely displayed are included
; Return values .: Success      - Spanned months
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetMonthRangeSpan($hWnd, $fPartial = False)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	Local $tBuffer = _GUICtrlMonthCal_GetMonthRange($hWnd, $fPartial)
	Return DllStructGetData($tBuffer, "Span")
EndFunc   ;==>_GUICtrlMonthCal_GetMonthRangeSpan

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetRange
; Description ...: Retrieves the minimum and maximum allowable dates
; Syntax.........: _GUICtrlMonthCal_GetRange($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - $tagMCRANGE structure
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlMonthCal_SetRange, _GUICtrlMonthCal_GetRangeMaxStr, _GUICtrlMonthCal_GetRangeMin, _GUICtrlMonthCal_GetRangeMinStr, $tagMCRANGE
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetRange($hWnd)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	Local $iRet

	Local $tBuffer = DllStructCreate($tagMCRANGE)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_mc_ghMCLastWnd) Then
			$iRet = _SendMessage($hWnd, $MCM_GETRANGE, 0, $tBuffer, 0, "wparam", "struct*")
		Else
			Local $iBuffer = DllStructGetSize($tBuffer)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iBuffer, $tMemMap)
			$iRet = _SendMessage($hWnd, $MCM_GETRANGE, 0, $pMemory, 0, "wparam", "ptr")
			_MemRead($tMemMap, $pMemory, $tBuffer, $iBuffer)
			_MemFree($tMemMap)
		EndIf
	Else
		$iRet = GUICtrlSendMsg($hWnd, $MCM_GETRANGE, 0, DllStructGetPtr($tBuffer))
	EndIf
	DllStructSetData($tBuffer, "MinSet", BitAND($iRet, $GDTR_MIN) <> 0)
	DllStructSetData($tBuffer, "MaxSet", BitAND($iRet, $GDTR_MAX) <> 0)
	Return $tBuffer
EndFunc   ;==>_GUICtrlMonthCal_GetRange

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetRangeMax
; Description ...: Retrieves the upper limit date range
; Syntax.........: _GUICtrlMonthCal_GetRangeMax($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - $tagSYSTEMTIME
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetRange, _GUICtrlMonthCal_GetRangeMin, _GUICtrlMonthCal_GetRangeMaxStr, $tagSYSTEMTIME
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetRangeMax($hWnd)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)

	Local $tBuffer = _GUICtrlMonthCal_GetRange($hWnd)
	Local $tRange = DllStructCreate($tagSYSTEMTIME)
	DllStructSetData($tRange, "Year", DllStructGetData($tBuffer, "MaxYear"))
	DllStructSetData($tRange, "Month", DllStructGetData($tBuffer, "MaxMonth"))
	DllStructSetData($tRange, "DOW", DllStructGetData($tBuffer, "MaxDOW"))
	DllStructSetData($tRange, "Day", DllStructGetData($tBuffer, "MaxDay"))
	Return $tRange
EndFunc   ;==>_GUICtrlMonthCal_GetRangeMax

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetRangeMaxStr
; Description ...: Retrieves the upper limit date range in string format
; Syntax.........: _GUICtrlMonthCal_GetRangeMaxStr($hWnd[, $sFormat = "%02d/%02d/%04d"])
; Parameters ....: $hWnd        - Handle to control
;                  $sFormat     - StringFormat string used to format the date
; Return values .: Success      - Date in the specified format
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetRange, _GUICtrlMonthCal_GetRangeMax
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetRangeMaxStr($hWnd, $sFormat = "%02d/%02d/%04d")
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	Local $tBuffer = _GUICtrlMonthCal_GetRangeMax($hWnd)
	Return StringFormat($sFormat, DllStructGetData($tBuffer, "Month"), DllStructGetData($tBuffer, "Day"), DllStructGetData($tBuffer, "Year"))
EndFunc   ;==>_GUICtrlMonthCal_GetRangeMaxStr

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetRangeMin
; Description ...: Retrieves the lower limit date range
; Syntax.........: _GUICtrlMonthCal_GetRangeMin($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - $tagSYSTEMTIME
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetRange, _GUICtrlMonthCal_GetRangeMax, _GUICtrlMonthCal_GetRangeMinStr, $tagSYSTEMTIME
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetRangeMin($hWnd)

	Local $tBuffer = _GUICtrlMonthCal_GetRange($hWnd)
	Local $tRange = DllStructCreate($tagSYSTEMTIME)
	DllStructSetData($tRange, "Year", DllStructGetData($tBuffer, "MinYear"))
	DllStructSetData($tRange, "Month", DllStructGetData($tBuffer, "MinMonth"))
	DllStructSetData($tRange, "DOW", DllStructGetData($tBuffer, "MinDOW"))
	DllStructSetData($tRange, "Day", DllStructGetData($tBuffer, "MinDay"))
	Return $tRange
EndFunc   ;==>_GUICtrlMonthCal_GetRangeMin

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetRangeMinStr
; Description ...: Retrieves the lower limit date range in string form
; Syntax.........: _GUICtrlMonthCal_GetRangeMinStr($hWnd[, $sFormat = "%02d/%02d/%04d"])
; Parameters ....: $hWnd        - Handle to control
;                  $sFormat     - StringFormat string used to format the date
; Return values .: Success      - Date in the specified format
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetRange, _GUICtrlMonthCal_GetRangeMin
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetRangeMinStr($hWnd, $sFormat = "%02d/%02d/%04d")
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	Local $tBuffer = _GUICtrlMonthCal_GetRangeMin($hWnd)
	Return StringFormat($sFormat, DllStructGetData($tBuffer, "Month"), DllStructGetData($tBuffer, "Day"), DllStructGetData($tBuffer, "Year"))
EndFunc   ;==>_GUICtrlMonthCal_GetRangeMinStr

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetSelRange
; Description ...: Retrieves the upper and lower limits of the date range currently selected
; Syntax.........: _GUICtrlMonthCal_GetSelRange($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - $tagMCSELRANGE structure
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlMonthCal_SetSelRange, $tagMCSELRANGE
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetSelRange($hWnd)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	Local $iRet

	Local $tBuffer = DllStructCreate($tagMCSELRANGE)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_mc_ghMCLastWnd) Then
			$iRet = _SendMessage($hWnd, $MCM_GETSELRANGE, 0, $tBuffer, 0, "wparam", "ptr")
		Else
			Local $iBuffer = DllStructGetSize($tBuffer)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iBuffer, $tMemMap)
			$iRet = _SendMessage($hWnd, $MCM_GETSELRANGE, 0, $pMemory, 0, "wparam", "ptr")
			_MemRead($tMemMap, $pMemory, $tBuffer, $iBuffer)
			_MemFree($tMemMap)
		EndIf
	Else
		$iRet = GUICtrlSendMsg($hWnd, $MCM_GETSELRANGE, 0, DllStructGetPtr($tBuffer))
	EndIf
	Return SetError($iRet = 0, 0, $tBuffer)
EndFunc   ;==>_GUICtrlMonthCal_GetSelRange

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetSelRangeMax
; Description ...: Retrieves the upper date range currently selected by the user
; Syntax.........: _GUICtrlMonthCal_GetSelRangeMax($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - $tagSYSTEMTIME
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetSelRangeMin, $tagSYSTEMTIME
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetSelRangeMax($hWnd)

	Local $tBuffer = _GUICtrlMonthCal_GetSelRange($hWnd)
	Local $tRange = DllStructCreate($tagSYSTEMTIME)
	DllStructSetData($tRange, "Year", DllStructGetData($tBuffer, "MaxYear"))
	DllStructSetData($tRange, "Month", DllStructGetData($tBuffer, "MaxMonth"))
	DllStructSetData($tRange, "DOW", DllStructGetData($tBuffer, "MaxDOW"))
	DllStructSetData($tRange, "Day", DllStructGetData($tBuffer, "MaxDay"))
	Return $tRange
EndFunc   ;==>_GUICtrlMonthCal_GetSelRangeMax

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetSelRangeMaxStr
; Description ...: Retrieves the upper date range currently selected by the user in string form
; Syntax.........: _GUICtrlMonthCal_GetSelRangeMaxStr($hWnd[, $sFormat = "%02d/%02d/%04d"])
; Parameters ....: $hWnd        - Handle to control
;                  $sFormat     - StringFormat string used to format the date
; Return values .: Success      - Date in the specified format
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetSelRangeMinStr
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetSelRangeMaxStr($hWnd, $sFormat = "%02d/%02d/%04d")
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	Local $tBuffer = _GUICtrlMonthCal_GetSelRangeMax($hWnd)
	Return StringFormat($sFormat, DllStructGetData($tBuffer, "Month"), DllStructGetData($tBuffer, "Day"), DllStructGetData($tBuffer, "Year"))
EndFunc   ;==>_GUICtrlMonthCal_GetSelRangeMaxStr

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetSelRangeMin
; Description ...: Retrieves the lower date range currently selected by the user
; Syntax.........: _GUICtrlMonthCal_GetSelRangeMin($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - $tagSYSTEMTIME
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetSelRangeMax, $tagSYSTEMTIME
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetSelRangeMin($hWnd)

	Local $tBuffer = _GUICtrlMonthCal_GetSelRange($hWnd)
	Local $tRange = DllStructCreate($tagSYSTEMTIME)
	DllStructSetData($tRange, "Year", DllStructGetData($tBuffer, "MinYear"))
	DllStructSetData($tRange, "Month", DllStructGetData($tBuffer, "MinMonth"))
	DllStructSetData($tRange, "DOW", DllStructGetData($tBuffer, "MinDOW"))
	DllStructSetData($tRange, "Day", DllStructGetData($tBuffer, "MinDay"))
	Return $tRange
EndFunc   ;==>_GUICtrlMonthCal_GetSelRangeMin

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetSelRangeMinStr
; Description ...: Retrieves the lower date range currently selected by the user in string form
; Syntax.........: _GUICtrlMonthCal_GetSelRangeMinStr($hWnd[, $sFormat = "%02d/%02d/%04d"])
; Parameters ....: $hWnd        - Handle to control
;                  $sFormat     - StringFormat string used to format the date
; Return values .: Success      - Date in the specified format
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetSelRangeMaxStr
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetSelRangeMinStr($hWnd, $sFormat = "%02d/%02d/%04d")
	Local $tBuffer = _GUICtrlMonthCal_GetSelRangeMin($hWnd)
	Return StringFormat($sFormat, DllStructGetData($tBuffer, "Month"), DllStructGetData($tBuffer, "Day"), DllStructGetData($tBuffer, "Year"))
EndFunc   ;==>_GUICtrlMonthCal_GetSelRangeMinStr

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetToday
; Description ...: Retrieves the date information for the date specified as "today"
; Syntax.........: _GUICtrlMonthCal_GetToday($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - $tagSYSTEMTIME
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlMonthCal_SetToday, _GUICtrlMonthCal_GetRangeMinStr, $tagSYSTEMTIME
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetToday($hWnd)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	Local $iRet

	Local $tBuffer = DllStructCreate($tagSYSTEMTIME)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_mc_ghMCLastWnd) Then
			$iRet = _SendMessage($hWnd, $MCM_GETTODAY, 0, $tBuffer, 0, "wparam", "ptr") <> 0
		Else
			Local $iBuffer = DllStructGetSize($tBuffer)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iBuffer, $tMemMap)
			$iRet = _SendMessage($hWnd, $MCM_GETTODAY, 0, $pMemory, 0, "wparam", "ptr") <> 0
			_MemRead($tMemMap, $pMemory, $tBuffer, $iBuffer)
			_MemFree($tMemMap)
		EndIf
	Else
		$iRet = GUICtrlSendMsg($hWnd, $MCM_GETTODAY, 0, DllStructGetPtr($tBuffer)) <> 0
	EndIf
	Return SetError($iRet = 0, 0, $tBuffer)
EndFunc   ;==>_GUICtrlMonthCal_GetToday

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetTodayStr
; Description ...: Retrieves the date information for the date specified as "today" in string format
; Syntax.........: _GUICtrlMonthCal_GetTodayStr($hWnd[, $sFormat = "%02d/%02d/%04d"])
; Parameters ....: $hWnd        - Handle to control
;                  $sFormat     - StringFormat string used to format the date
; Return values .: Success      - Date in the specified format
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetToday
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetTodayStr($hWnd, $sFormat = "%02d/%02d/%04d")
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	Local $tBuffer = _GUICtrlMonthCal_GetToday($hWnd)
	Return StringFormat($sFormat, DllStructGetData($tBuffer, "Month"), DllStructGetData($tBuffer, "Day"), DllStructGetData($tBuffer, "Year"))
EndFunc   ;==>_GUICtrlMonthCal_GetTodayStr

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_GetUnicodeFormat
; Description ...: Retrieves the Unicode character format flag for the control
; Syntax.........: _GUICtrlMonthCal_GetUnicodeFormat($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: True         - Control is using Unicode characters
;                  False        - Control is using ANSI characters
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlMonthCal_SetUnicodeFormat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_GetUnicodeFormat($hWnd)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $MCM_GETUNICODEFORMAT) <> 0
	Else
		Return GUICtrlSendMsg($hWnd, $MCM_GETUNICODEFORMAT, 0, 0) <> 0
	EndIf
EndFunc   ;==>_GUICtrlMonthCal_GetUnicodeFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_HitTest
; Description ...: Determines which portion of a month calendar control is at a given point
; Syntax.........: _GUICtrlMonthCal_HitTest($hWnd, $iX, $iY)
; Parameters ....: $hWnd        - Handle to control
;                  $iX          - X position to test
;                  $iY          - Y position to test
; Return values .: Success      - $tagMCHITTESTINFO structure
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: $tagMCHITTESTINFO
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_HitTest($hWnd, $iX, $iY)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)

	Local $tTest = DllStructCreate($tagMCHITTESTINFO)
	Local $iTest = DllStructGetSize($tTest)
	DllStructSetData($tTest, "Size", $iTest)
	DllStructSetData($tTest, "X", $iX)
	DllStructSetData($tTest, "Y", $iY)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_mc_ghMCLastWnd) Then
			_SendMessage($hWnd, $MCM_HITTEST, 0, $tTest, 0, "wparam", "struct*")
		Else
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iTest, $tMemMap)
			_SendMessage($hWnd, $MCM_HITTEST, 0, $pMemory, 0, "wparam", "ptr")
			_MemRead($tMemMap, $pMemory, $tTest, $iTest)
			_MemFree($tMemMap)
		EndIf
	Else
		GUICtrlSendMsg($hWnd, $MCM_HITTEST, 0, DllStructGetPtr($tTest))
	EndIf
	Return $tTest
EndFunc   ;==>_GUICtrlMonthCal_HitTest

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlMonthCal_Resize
; Description ...: Adjusts the control size so that it is fully shown
; Syntax.........: __GUICtrlMonthCal_Resize($hWnd[, $iX = -1[, $iY = -1]])
; Parameters ....: $hWnd        - Handle to control
;                  $iX          - Left position of calendar. If -1, the current position will be used
;                  $iY          - Top position of calendar. If -1, the current position will be used
; Return values .: None
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......: This function is called internally by _GUICtrlMonthCal_Create and should not normally be called by the end user.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GUICtrlMonthCal_Resize($hWnd, $iX = -1, $iY = -1)

	Local $iN = _GUICtrlMonthCal_GetMaxTodayWidth($hWnd)
	Local $iH = _GUICtrlMonthCal_GetMinReqHeight($hWnd)
	Local $iW = _GUICtrlMonthCal_GetMinReqWidth($hWnd)
	If $iN > $iW Then $iW = $iN
	If ($iX = -1) Or ($iY = -1) Then
		Local $tRect = _WinAPI_GetWindowRect($hWnd)
		If $iX = -1 Then $iX = DllStructGetData($tRect, "Left")
		If $iY = -1 Then $iY = DllStructGetData($tRect, "Top")
	EndIf
;~ 	_WinAPI_SetWindowPos($hWnd, 0, $iX, $iY, $iX + $iW, $iY + $iH, $__MONTHCALCONSTANT_SWP_NOZORDER)
	_WinAPI_SetWindowPos($hWnd, 0, $iX, $iY, $iW, $iH, $__MONTHCALCONSTANT_SWP_NOZORDER)
EndFunc   ;==>__GUICtrlMonthCal_Resize

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_SetCalendarBorder
; Description ...: Sets the size of the border, in pixels
; Syntax.........: _GUICtrlMonthCal_SetCalendarBorder($hWnd[, $iBorderSize = 4[, $fSetBorder = True]])
; Parameters ....: $hWnd        - Handle to control
;                  $iBorderSize - Number of pixels of the border size
;                  $fSetBorder  - One of the Following:
;                  |   True - The border size is set to the number of pixels that $iBorderSize specifies
;                  |  False - The border size is reset to the default value specified by the theme, or zero if themes are not being used
; Return values .:
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Minimum Operating Systems: Windows Vista
; Related .......: _GUICtrlMonthCal_GetCalendarBorder
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_SetCalendarBorder($hWnd, $iBorderSize = 4, $fSetBorder = True)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	If IsHWnd($hWnd) Then
		_SendMessage($hWnd, $MCM_SETCALENDARBORDER, $fSetBorder, $iBorderSize)
	Else
		GUICtrlSendMsg($hWnd, $MCM_SETCALENDARBORDER, $fSetBorder, $iBorderSize)
	EndIf
EndFunc   ;==>_GUICtrlMonthCal_SetCalendarBorder

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_SetColor
; Description ...: Sets the color for a given portion of the month calendar
; Syntax.........: _GUICtrlMonthCal_SetColor($hWnd, $iIndex, $iColor)
; Parameters ....: $hWnd        - Handle to control
;                  $iIndex      - Indicates which month calendar color to set:
;                  |$MCSC_BACKGROUND   - Background color displayed between months
;                  |$MCSC_TEXT         - Color used to display text within a month
;                  |$MCSC_TITLEBK      - Background color displayed in the calendar title
;                  |$MCSC_TITLETEXT    - Color used to display text within the calendar title
;                  |$MCSC_MONTHBK      - Background color displayed within the month
;                  |$MCSC_TRAILINGTEXT - Color used to display header day and trailing day text
;                  $iColor      - Color value
; Return values .: Success      - The previous color setting for the specified portion of the control
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_SetColor($hWnd, $iIndex, $iColor)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $MCM_SETCOLOR, $iIndex, $iColor)
	Else
		Return GUICtrlSendMsg($hWnd, $MCM_SETCOLOR, $iIndex, $iColor)
	EndIf
EndFunc   ;==>_GUICtrlMonthCal_SetColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_SetCurSel
; Description ...: Sets the currently selected date
; Syntax.........: _GUICtrlMonthCal_SetCurSel($hWnd, $iYear, $iMonth, $iDay)
; Parameters ....: $hWnd        - Handle to control
;                  $iYear       - Year value
;                  $iMonth      - Month value
;                  $iDay        - Day value
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetCurSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_SetCurSel($hWnd, $iYear, $iMonth, $iDay)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	Local $iRet

	Local $tBuffer = DllStructCreate($tagSYSTEMTIME)
	DllStructSetData($tBuffer, "Month", $iMonth)
	DllStructSetData($tBuffer, "Day", $iDay)
	DllStructSetData($tBuffer, "Year", $iYear)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_mc_ghMCLastWnd) Then
			$iRet = _SendMessage($hWnd, $MCM_SETCURSEL, 0, $tBuffer, 0, "wparam", "ptr")
		Else
			Local $iBuffer = DllStructGetSize($tBuffer)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iBuffer, $tMemMap)
			_MemWrite($tMemMap, $tBuffer)
			$iRet = _SendMessage($hWnd, $MCM_SETCURSEL, 0, $pMemory, 0, "wparam", "ptr")
			_MemFree($tMemMap)
		EndIf
	Else
		$iRet = GUICtrlSendMsg($hWnd, $MCM_SETCURSEL, 0, DllStructGetPtr($tBuffer))
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlMonthCal_SetCurSel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_SetDayState
; Description ...: Sets the day states for all months that are currently visible
; Syntax.........: _GUICtrlMonthCal_SetDayState($hWnd, $aMasks)
; Parameters ....: $hWnd        - Handle to control
;                  $aMasks      - An array of integers that corresponds to the months that are visible in the calendar
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: You must create the calendar control with the $MCS_DAYSTATE style if you want to use this function
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_SetDayState($hWnd, $aMasks)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	Local $iRet

	Local $iMasks = _GUICtrlMonthCal_GetMonthRangeSpan($hWnd, True)
	Local $tBuffer = DllStructCreate("int;int;int")
	For $iI = 0 To $iMasks - 1
		DllStructSetData($tBuffer, $iI + 1, $aMasks[$iI])
	Next
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_mc_ghMCLastWnd) Then
			$iRet = _SendMessage($hWnd, $MCM_SETDAYSTATE, $iMasks, $tBuffer, 0, "wparam", "struct*")
		Else
			Local $iBuffer = DllStructGetSize($tBuffer)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iBuffer, $tMemMap)
			_MemWrite($tMemMap, $tBuffer)
			$iRet = _SendMessage($hWnd, $MCM_SETDAYSTATE, $iMasks, $pMemory, 0, "wparam", "ptr")
			_MemFree($tMemMap)
		EndIf
	Else
		$iRet = GUICtrlSendMsg($hWnd, $MCM_SETDAYSTATE, $iMasks, DllStructGetPtr($tBuffer))
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlMonthCal_SetDayState

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_SetFirstDOW
; Description ...: Sets the first day of the week for a month calendar control
; Syntax.........: _GUICtrlMonthCal_SetFirstDOW($hWnd, $sDay)
; Parameters ....: $hWnd        - Handle to the control
;                  $sDay        - In the following format:
;                  |0 or "Monday"
;                  |1 or "Tuesday"
;                  |2 or "Wednesday"
;                  |3 or "Thursday"
;                  |4 or "Friday"
;                  |5 or "Saturday"
;                  |6 or "Sunday"
; Return values .: Success      - The previous first day of the week
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetFirstDOW
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_SetFirstDOW($hWnd, $sDay)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	Local $i_day
	If $sDay >= 0 Or $sDay <= 6 Then
		$i_day = $sDay
	ElseIf StringInStr("MONDAY TUESDAY WEDNESDAY THURSDAY FRIDAY SATURDAY SUNDAY", $sDay) Then
		Switch StringUpper($sDay)
			Case "MONDAY"
				$i_day = 0
			Case "TUESDAY"
				$i_day = 1
			Case "WEDNESDAY"
				$i_day = 2
			Case "THURSDAY"
				$i_day = 3
			Case "FRIDAY"
				$i_day = 4
			Case "SATURDAY"
				$i_day = 5
			Case "SUNDAY"
				$i_day = 6
		EndSwitch
	Else
		Return SetError(-1, -1, -1)
	EndIf
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $MCM_SETFIRSTDAYOFWEEK, 0, $i_day)
	Else
		Return GUICtrlSendMsg($hWnd, $MCM_SETFIRSTDAYOFWEEK, 0, $i_day)
	EndIf
EndFunc   ;==>_GUICtrlMonthCal_SetFirstDOW

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_SetMaxSelCount
; Description ...: Sets the maximum number of days that can be selected in a month calendar control
; Syntax.........: _GUICtrlMonthCal_SetMaxSelCount($hWnd, $iMaxSel)
; Parameters ....: $hWnd        - Handle to the control
;                  $iMaxSel     - Value of type int that will be set to represent the maximum number of days that can be selected
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: This will fail if applied to a month calendar control that does not use the $MCS_MULTISELECT style
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_SetMaxSelCount($hWnd, $iMaxSel)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $MCM_SETMAXSELCOUNT, $iMaxSel) <> 0
	Else
		Return GUICtrlSendMsg($hWnd, $MCM_SETMAXSELCOUNT, $iMaxSel, 0) <> 0
	EndIf
EndFunc   ;==>_GUICtrlMonthCal_SetMaxSelCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_SetMonthDelta
; Description ...: Sets the scroll rate for a month calendar control
; Syntax.........: _GUICtrlMonthCal_SetMonthDelta($hWnd, $iDelta)
; Parameters ....: $hWnd        - Handle to the control
;                  $iDelta      - Value representing the number of months to be set as the control's scroll rate
;                  +If this value is zero, the month delta is reset to the default
;                  +which is the number of months displayed in the control
; Return values .: Success      - INT value that represents the previous scroll rate
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_SetMonthDelta($hWnd, $iDelta)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $MCM_SETMONTHDELTA, $iDelta)
	Else
		Return GUICtrlSendMsg($hWnd, $MCM_SETMONTHDELTA, $iDelta, 0)
	EndIf
EndFunc   ;==>_GUICtrlMonthCal_SetMonthDelta

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_SetRange
; Description ...: Sets date information that represents the high and low limits
; Syntax.........: _GUICtrlMonthCal_SetRange($hWnd, $iMinYear, $iMinMonth, $iMinDay, $iMaxYear, $iMaxMonth, $iMaxDay)
; Parameters ....: $hWnd        - Handle to control
;                  $iMinYear    - Minimum year
;                  $iMinMonth   - Minimum month
;                  $iMinDay     - Minimum day
;                  $iMaxYear    - Maximum year
;                  $iMaxMonth   - Maximum month
;                  $iMaxDay     - Maximum day
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetRange
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_SetRange($hWnd, $iMinYear, $iMinMonth, $iMinDay, $iMaxYear, $iMaxMonth, $iMaxDay)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	Local $iRet

	Local $tRange = DllStructCreate($tagMCRANGE)
	Local $iFlags = BitOR($GDTR_MIN, $GDTR_MAX)
	DllStructSetData($tRange, "MinYear", $iMinYear)
	DllStructSetData($tRange, "MinMonth", $iMinMonth)
	DllStructSetData($tRange, "MinDay", $iMinDay)
	DllStructSetData($tRange, "MaxYear", $iMaxYear)
	DllStructSetData($tRange, "MaxMonth", $iMaxMonth)
	DllStructSetData($tRange, "MaxDay", $iMaxDay)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_mc_ghMCLastWnd) Then
			$iRet = _SendMessage($hWnd, $MCM_SETRANGE, $iFlags, $tRange, 0, "wparam", "ptr")
		Else
			Local $iRange = DllStructGetSize($tRange)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iRange, $tMemMap)
			_MemWrite($tMemMap, $tRange)
			$iRet = _SendMessage($hWnd, $MCM_SETRANGE, $iFlags, $pMemory, 0, "wparam", "ptr")
			_MemFree($tMemMap)
		EndIf
	Else
		$iRet = GUICtrlSendMsg($hWnd, $MCM_SETRANGE, $iFlags, DllStructGetPtr($tRange))
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlMonthCal_SetRange

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_SetSelRange
; Description ...: Sets the selection for a month calendar control to a given date range
; Syntax.........: _GUICtrlMonthCal_SetSelRange($hWnd, $iMinYear, $iMinMonth, $iMinDay, $iMaxYear, $iMaxMonth, $iMaxDay)
; Parameters ....: $hWnd        - Handle to control
;                  $iMinYear    - Minimum year
;                  $iMinMonth   - Minimum month
;                  $iMinDay     - Minimum day
;                  $iMaxYear    - Maximum year
;                  $iMaxMonth   - Maximum month
;                  $iMaxDay     - Maximum day
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: This message will fail if applied to a month calendar control that does not use the $MCS_MULTISELECT style
; Related .......: _GUICtrlMonthCal_GetSelRange
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_SetSelRange($hWnd, $iMinYear, $iMinMonth, $iMinDay, $iMaxYear, $iMaxMonth, $iMaxDay)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)

	Local $tBuffer = DllStructCreate($tagMCRANGE)
	DllStructSetData($tBuffer, "MinYear", $iMinYear)
	DllStructSetData($tBuffer, "MinMonth", $iMinMonth)
	DllStructSetData($tBuffer, "MinDay", $iMinDay)
	DllStructSetData($tBuffer, "MaxYear", $iMaxYear)
	DllStructSetData($tBuffer, "MaxMonth", $iMaxMonth)
	DllStructSetData($tBuffer, "MaxDay", $iMaxDay)
	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_mc_ghMCLastWnd) Then
			$iRet = _SendMessage($hWnd, $MCM_SETSELRANGE, 0, $tBuffer, 0, "wparam", "struct*")
		Else
			Local $iBuffer = DllStructGetSize($tBuffer)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iBuffer, $tMemMap)
			_MemWrite($tMemMap, $tBuffer)
			$iRet = _SendMessage($hWnd, $MCM_SETSELRANGE, 0, $pMemory, 0, "wparam", "ptr")
			_MemFree($tMemMap)
		EndIf
	Else
		$iRet = GUICtrlSendMsg($hWnd, $MCM_SETSELRANGE, 0, DllStructGetPtr($tBuffer))
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlMonthCal_SetSelRange

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_SetToday
; Description ...: Sets the date information for the date specified as "today"
; Syntax.........: _GUICtrlMonthCal_SetToday($hWnd, $iYear, $iMonth, $iDay)
; Parameters ....: $hWnd        - Handle to control
;                  $iYear       - Year
;                  $iMonth      - Month
;                  $iDay        - Day
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetToday
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_SetToday($hWnd, $iYear, $iMonth, $iDay)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)

	Local $tBuffer = DllStructCreate($tagSYSTEMTIME)
	DllStructSetData($tBuffer, "Month", $iMonth)
	DllStructSetData($tBuffer, "Day", $iDay)
	DllStructSetData($tBuffer, "Year", $iYear)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_mc_ghMCLastWnd) Then
			_SendMessage($hWnd, $MCM_SETTODAY, 0, $tBuffer, 0, "wparam", "struct*")
		Else
			Local $iBuffer = DllStructGetSize($tBuffer)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iBuffer, $tMemMap)
			_MemWrite($tMemMap, $tBuffer)
			_SendMessage($hWnd, $MCM_SETTODAY, 0, $pMemory, 0, "wparam", "ptr")
			_MemFree($tMemMap)
		EndIf
	Else
		GUICtrlSendMsg($hWnd, $MCM_SETTODAY, 0, DllStructGetPtr($tBuffer))
	EndIf
EndFunc   ;==>_GUICtrlMonthCal_SetToday

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlMonthCal_SetUnicodeFormat
; Description ...: Sets the Unicode character format flag for the control
; Syntax.........: _GUICtrlMonthCal_SetUnicodeFormat($hWnd[, $fUnicode = False])
; Parameters ....: $hWnd        - Handle to control
;                  $fUnicode    - Unicode format flag:
;                  | True - Control uses Unicode characters
;                  |False - Control uses ANSI characters
; Return values .: Success      - The previous Unicode format flag
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlMonthCal_GetUnicodeFormat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlMonthCal_SetUnicodeFormat($hWnd, $fUnicode = False)
	If $Debug_MC Then __UDF_ValidateClassName($hWnd, $__MONTHCALCONSTANT_ClassName)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $MCM_SETUNICODEFORMAT, $fUnicode) <> 0
	Else
		Return GUICtrlSendMsg($hWnd, $MCM_SETUNICODEFORMAT, $fUnicode, 0) <> 0
	EndIf
EndFunc   ;==>_GUICtrlMonthCal_SetUnicodeFormat
