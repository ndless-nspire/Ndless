#include-once

#include "ProcessConstants.au3"

; #INDEX# =======================================================================================================================
; Title .........: Process
; AutoIt Version : 3.0
; Language ......: English
; Description ...: Functions that assist with Process management.
; Author(s) .....: Erifash, Wouter, Matthew Tucker, Jeremy Landes, Valik
; Dll ...........: kernel32.dll
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _ProcessGetName
; Description ...: Returns a string containing the process name that belongs to a given PID.
; Syntax.........: _ProcessGetName( $iPID )
; Parameters ....: $iPID - The PID of a currently running process
; Return values .: Success      - The name of the process
;                  Failure      - Blank string and sets @error
;                       1 - Process doesn't exist
;                       2 - Error getting process list
;                       3 - No processes found
; Author ........: Erifash <erifash [at] gmail [dot] com>, Wouter van Kesteren.
; Remarks .......: Supplementary to ProcessExists().
; ===============================================================================================================================
Func _ProcessGetName($i_PID)
	If Not ProcessExists($i_PID) Then Return SetError(1, 0, '')
	If Not @error Then
		Local $a_Processes = ProcessList()
		For $i = 1 To $a_Processes[0][0]
			If $a_Processes[$i][1] = $i_PID Then Return $a_Processes[$i][0]
		Next
	EndIf
	Return SetError(1, 0, '')
EndFunc   ;==>_ProcessGetName

; #FUNCTION# ====================================================================================================================
; Name...........: _ProcessGetPriority
; Description ...: Get the  priority of an open process.
; Syntax.........:  _ProcessGetPriority($vProcess)
; Parameters ....: $vProcess      - PID or name of a process.
; Return values .: Success      - Returns integer corressponding to
;                   the processes's priority:
;                     0 - Idle/Low
;                     1 - Below Normal (Not supported on Windows 95/98/ME)
;                     2 - Normal
;                     3 - Above Normal (Not supported on Windows 95/98/ME)
;                     4 - High
;                     5 - Realtime
;                  Failure      -1 and sets @Error to 1
; Author ........: Matthew Tucker
; Modifier ......: Valik added Pid or Processname logic
; ===============================================================================================================================
Func _ProcessGetPriority($vProcess)
	Local $iError, $iExtended, $iReturn = -1
	Local $i_PID = ProcessExists($vProcess)
	If Not $i_PID Then Return SetError(1, 0, -1)
	Local $hDLL = DllOpen('kernel32.dll')

	Do ; Pseudo loop
		Local $aProcessHandle = DllCall($hDLL, 'handle', 'OpenProcess', 'dword', $PROCESS_QUERY_INFORMATION, 'bool', False, 'dword', $i_PID)
		If @error Then
			$iError = @error
			$iExtended = @extended
			ExitLoop
		EndIf
		If Not $aProcessHandle[0] Then ExitLoop

		Local $aPriority = DllCall($hDLL, 'dword', 'GetPriorityClass', 'handle', $aProcessHandle[0])
		If @error Then
			$iError = @error
			$iExtended = @extended
			; Fall-through so the handle is closed.
		EndIf

		DllCall($hDLL, 'bool', 'CloseHandle', 'handle', $aProcessHandle[0])
		; No need to test @error.

		If $iError Then ExitLoop

		Switch $aPriority[0]
			Case 0x00000040 ; IDLE_PRIORITY_CLASS
				$iReturn = 0
			Case 0x00004000 ; BELOW_NORMAL_PRIORITY_CLASS
				$iReturn = 1
			Case 0x00000020 ; NORMAL_PRIORITY_CLASS
				$iReturn = 2
			Case 0x00008000 ; ABOVE_NORMAL_PRIORITY_CLASS
				$iReturn = 3
			Case 0x00000080 ; HIGH_PRIORITY_CLASS
				$iReturn = 4
			Case 0x00000100 ; REALTIME_PRIORITY_CLASS
				$iReturn = 5
			Case Else
				$iError = 1
				$iExtended = $aPriority[0]
				$iReturn = -1
		EndSwitch
	Until True ; Executes once
	DllClose($hDLL)
	Return SetError($iError, $iExtended, $iReturn)
EndFunc   ;==>_ProcessGetPriority

; #FUNCTION# ====================================================================================================================
; Name...........: _RunDOS
; Description ...: Executes a DOS command in a hidden command window.
; Syntax.........: _RunDOS($sCommand)
; Parameters ....: $sCommand - Command to execute
; Return values .: Success      - the exit code of the command
;                  Failure      - 0 and sets @Error to non-zero
; Author ........: Jeremy Landes <jlandes at landeserve dot com>
; ===============================================================================================================================
Func _RunDos($sCommand)
	Local $nResult = RunWait(@ComSpec & " /C " & $sCommand, "", @SW_HIDE)
	Return SetError(@error, @extended, $nResult)
EndFunc   ;==>_RunDos
