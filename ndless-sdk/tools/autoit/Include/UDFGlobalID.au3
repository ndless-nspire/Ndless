#include-once

#include "WinAPI.au3"

; #INDEX# =======================================================================================================================
; Title .........: UDF Global ID
; AutoIt Version : 3.2.3++
; Language ......: English
; Description ...: Global ID Generation for UDFs.
; Author(s) .....: Gary Frost
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $_UDF_GlobalIDs_OFFSET = 2
Global Const $_UDF_GlobalID_MAX_WIN = 16
Global Const $_UDF_STARTID = 10000
Global Const $_UDF_GlobalID_MAX_IDS = 55535

Global Const $__UDFGUICONSTANT_WS_VISIBLE = 0x10000000
Global Const $__UDFGUICONSTANT_WS_CHILD = 0x40000000
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $_UDF_GlobalIDs_Used[$_UDF_GlobalID_MAX_WIN][$_UDF_GlobalID_MAX_IDS + $_UDF_GlobalIDs_OFFSET + 1] ; [index][0] = HWND, [index][1] = NEXT ID
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;__UDF_GetNextGlobalID
;__UDF_FreeGlobalID
;__UDF_DebugPrint
;__UDF_ValidateClassName
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __UDF_GetNextGlobalID
; Description ...: Used for setting controlID to UDF controls
; Syntax.........: __UDF_GetNextGlobalID($hWnd)
; Parameters ....: $hWnd      - handle to Main Window
; Return values .: Success - Control ID
;                  Failure - 0 and @error is set, @extended may be set
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: For Internal Use Only
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __UDF_GetNextGlobalID($hWnd)
	Local $nCtrlID, $iUsedIndex = -1, $fAllUsed = True

	; check if window still exists
	If Not WinExists($hWnd) Then Return SetError(-1, -1, 0)

	; check that all slots still hold valid window handles
	For $iIndex = 0 To $_UDF_GlobalID_MAX_WIN - 1
		If $_UDF_GlobalIDs_Used[$iIndex][0] <> 0 Then
			; window no longer exist, free up the slot and reset the control id counter
			If Not WinExists($_UDF_GlobalIDs_Used[$iIndex][0]) Then
				For $x = 0 To UBound($_UDF_GlobalIDs_Used, 2) - 1
					$_UDF_GlobalIDs_Used[$iIndex][$x] = 0
				Next
				$_UDF_GlobalIDs_Used[$iIndex][1] = $_UDF_STARTID
				$fAllUsed = False
			EndIf
		EndIf
	Next

	; check if window has been used before with this function
	For $iIndex = 0 To $_UDF_GlobalID_MAX_WIN - 1
		If $_UDF_GlobalIDs_Used[$iIndex][0] = $hWnd Then
			$iUsedIndex = $iIndex
			ExitLoop ; $hWnd has been used before
		EndIf
	Next

	; window hasn't been used before, get 1st un-used index
	If $iUsedIndex = -1 Then
		For $iIndex = 0 To $_UDF_GlobalID_MAX_WIN - 1
			If $_UDF_GlobalIDs_Used[$iIndex][0] = 0 Then
				$_UDF_GlobalIDs_Used[$iIndex][0] = $hWnd
				$_UDF_GlobalIDs_Used[$iIndex][1] = $_UDF_STARTID
				$fAllUsed = False
				$iUsedIndex = $iIndex
				ExitLoop
			EndIf
		Next
	EndIf

	If $iUsedIndex = -1 And $fAllUsed Then Return SetError(16, 0, 0) ; used up all 16 window slots

	; used all control ids
	If $_UDF_GlobalIDs_Used[$iUsedIndex][1] = $_UDF_STARTID + $_UDF_GlobalID_MAX_IDS Then
		; check if control has been deleted, if so use that index in array
		For $iIDIndex = $_UDF_GlobalIDs_OFFSET To UBound($_UDF_GlobalIDs_Used, 2) - 1
			If $_UDF_GlobalIDs_Used[$iUsedIndex][$iIDIndex] = 0 Then
				$nCtrlID = ($iIDIndex - $_UDF_GlobalIDs_OFFSET) + 10000
				$_UDF_GlobalIDs_Used[$iUsedIndex][$iIDIndex] = $nCtrlID
				Return $nCtrlID
			EndIf
		Next
		Return SetError(-1, $_UDF_GlobalID_MAX_IDS, 0) ; we have used up all available control ids
	EndIf

	; new control id
	$nCtrlID = $_UDF_GlobalIDs_Used[$iUsedIndex][1]
	$_UDF_GlobalIDs_Used[$iUsedIndex][1] += 1
	$_UDF_GlobalIDs_Used[$iUsedIndex][($nCtrlID - 10000) + $_UDF_GlobalIDs_OFFSET] = $nCtrlID
	Return $nCtrlID
EndFunc   ;==>__UDF_GetNextGlobalID

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __UDF_FreeGlobalID
; Description ...: Used for freeing controlID used for UDF controls
; Syntax.........: __UDF_FreeGlobalID($hWnd, $iGlobalID)
; Parameters ....: $hWnd      - handle to Main Window
;                  $iGlobalID - Control ID to free up for re-use if needed
; Return values .: None
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: For Internal Use Only
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __UDF_FreeGlobalID($hWnd, $iGlobalID)
	; invalid udf global id passed in
	If $iGlobalID - $_UDF_STARTID < 0 Or $iGlobalID - $_UDF_STARTID > $_UDF_GlobalID_MAX_IDS Then Return SetError(-1, 0, False)

	For $iIndex = 0 To $_UDF_GlobalID_MAX_WIN - 1
		If $_UDF_GlobalIDs_Used[$iIndex][0] = $hWnd Then
			For $x = $_UDF_GlobalIDs_OFFSET To UBound($_UDF_GlobalIDs_Used, 2) - 1
				If $_UDF_GlobalIDs_Used[$iIndex][$x] = $iGlobalID Then
					; free up control id
					$_UDF_GlobalIDs_Used[$iIndex][$x] = 0
					Return True
				EndIf
			Next
			; $iGlobalID wasn't found in the used list
			Return SetError(-3, 0, False)
		EndIf
	Next
	; $hWnd wasn't found in the used list
	Return SetError(-2, 0, False)
EndFunc   ;==>__UDF_FreeGlobalID

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __UDF_DebugPrint; Description ...: Used for debugging when creating examples
; Syntax.........: __UDF_DebugPrint($hWnd[, $iLine = @ScriptLineNumber])
; Parameters ....: $sText       - String to printed to console
;                  $iLine       - Line number function was called from
; Return values .: None
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: For Internal Use Only
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __UDF_DebugPrint($sText, $iLine = @ScriptLineNumber, $err = @error, $ext = @extended)
	ConsoleWrite( _
			"!===========================================================" & @CRLF & _
			"+======================================================" & @CRLF & _
			"-->Line(" & StringFormat("%04d", $iLine) & "):" & @TAB & $sText & @CRLF & _
			"+======================================================" & @CRLF)
	Return SetError($err, $ext, 1)
EndFunc   ;==>__UDF_DebugPrint

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __UDF_ValidateClassName
; Description ...: Used for debugging when creating examples
; Syntax.........: __UDF_ValidateClassName($hWnd, $sType)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: None
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: For Internal Use Only
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __UDF_ValidateClassName($hWnd, $sClassNames)
	__UDF_DebugPrint("This is for debugging only, set the debug variable to false before submitting")
	If _WinAPI_IsClassName($hWnd, $sClassNames) Then Return True
	Local $sSeparator = Opt("GUIDataSeparatorChar")
	$sClassNames = StringReplace($sClassNames, $sSeparator, ",")

	__UDF_DebugPrint("Invalid Class Type(s):" & @LF & @TAB & "Expecting Type(s): " & $sClassNames & @LF & @TAB & "Received Type : " & _WinAPI_GetClassName($hWnd))
	Exit
EndFunc   ;==>__UDF_ValidateClassName
