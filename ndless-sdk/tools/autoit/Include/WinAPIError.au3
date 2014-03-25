#include-once

; #INDEX# =======================================================================================================================
; Title .........: Windows API
; AutoIt Version : 3.2
; Description ...: Windows API calls that have been translated to AutoIt functions.
; Author(s) .....: Paul Campbell (PaulIA)
; Dll ...........: kernel32.dll
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_WinAPI_GetLastError
;_WinAPI_SetLastError
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetLastError
; Description ...: Returns the calling thread's lasterror code value
; Syntax.........: _WinAPI_GetLastError()
; Parameters ....:
; Return values .: Success      - Last error code
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_GetLastErrorMessage
; Link ..........: @@MsdnLink@@ GetLastError
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetLastError($curErr = @error, $curExt = @extended)
	Local $aResult = DllCall("kernel32.dll", "dword", "GetLastError")
	Return SetError($curErr, $curExt, $aResult[0])
EndFunc   ;==>_WinAPI_GetLastError

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetLastError
; Description ...: Sets the last-error code for the calling thread
; Syntax.........: _WinAPI_SetLastError($iErrCode)
; Parameters ....: $iErrCode    - The last error code for the thread
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The last error code is kept in thread local storage so that multiple threads do  not  overwrite  each  other's
;                  values.
; Related .......:
; Link ..........: @@MsdnLink@@ SetLastError
; Example .......:
; ===============================================================================================================================
Func _WinAPI_SetLastError($iErrCode, $curErr = @error, $curExt = @extended)
	DllCall("kernel32.dll", "none", "SetLastError", "dword", $iErrCode)
	Return SetError($curErr, $curExt)
EndFunc   ;==>_WinAPI_SetLastError
