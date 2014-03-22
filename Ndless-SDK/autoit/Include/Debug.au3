#include-once
#include "SendMessage.au3"
#include "WinAPIError.au3"


; #INDEX# =======================================================================================================================
; Title .........: Debug
; AutoIt Version : 3.2.3++
; Language ......: English
; Description ...: Functions to help script debugging.
; Author(s) .....: Nutster, Jpm, Valik
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__gsReportWindowText_Debug = "Debug Window hidden text"
; ===============================================================================================================================

; #VARIABLE# ===================================================================================================================
Global $__gsReportTitle_Debug = "AutoIt Debug Report"
Global $__giReportType_Debug = 0
Global $__gbReportWindowWaitClose_Debug = True, $__gbReportWindowClosed_Debug = True
Global $__ghReportEdit_Debug = 0
Global $__ghReportNotepadEdit_Debug = 0
Global $__gsReportCallBack_Debug
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_Assert
;_DebugBugReportEnv
;_DebugOut
;_DebugReport
;_DebugReportEx
;_DebugReportVar
;_DebugSetup
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;__Debug_DataFormat
;__Debug_DataType
;__Debug_ReportClose
;__Debug_ReportWrite
;__Debug_ReportWindowCreate
;__Debug_ReportWindowWrite
;__Debug_ReportWindowWaitClose
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _Assert
; Description ...: Display a message if assertion fails.
; Syntax.........:  _Assert($bCondition, $sMsg, $bExit = True, $nCode = 0x7FFFFFFF, $sLine = @ScriptLineNumber)
; Parameters ....: $sCondition - IN - The condition that must evaluate to true.
;                  $bExit - IN/OPTIONAL - If true, the script is aborted.
;                  $nCode - IN/OPTIONAL - The exit code to use if the script is aborted.
;                  $sLine - IN/OPTIONAL - Displays the line number where the assertion failed.  If this value is not
;                                         changed, then the default value will show the correct line.
; Return values .: The result of the condition (Only valid when not exiting).
; Author ........: Valik
; Modified.......: jpm
; Remarks .......: @error and @extended are not destroyed on return.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Assert($sCondition, $bExit = True, $nCode = 0x7FFFFFFF, $sLine = @ScriptLineNumber, Const $curerr = @error, Const $curext = @extended)
	Local $bCondition = Execute($sCondition)
	If Not $bCondition Then
		MsgBox(16 + 262144, "Autoit Assert", "Assertion Failed (Line " & $sLine & "): " & @CRLF & @CRLF & $sCondition)
		If $bExit Then Exit $nCode
	EndIf
	Return SetError($curerr, $curext, $bCondition)
EndFunc   ;==>_Assert

; #FUNCTION# ====================================================================================================================
; Name...........: _DebugBugReportEnv
; Description ...: Outputs a string containing information for Bug report submission.
; Syntax.........: _DebugBugReportEnv()
; Parameters ....:
; Return values .: Returns a string containing all information needed to submit.
; Author ........: Jean-Paul Mesnage (jpm)
; Modified.......:
; Remarks .......: @error and @extended are not destroyed on return
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _DebugBugReportEnv(Const $curerr = @error, Const $curext = @extended)
	Local $AutoItX64 = ""
	If @AutoItX64 Then $AutoItX64 = "/X64"
	Local $AdminMode = ""
	If IsAdmin() Then $AdminMode = " AdminMode"
	Local $Compiled = ""
	If @Compiled Then $Compiled = " Compiled"
	Local $OsServicePack = ""
	If @OSServicePack Then $OsServicePack = "/" & StringReplace(@OSServicePack, "Service Pack ", "SP")
	Local $MUIlang = ""
	If @OSLang <> @MUILang Then $MUIlang = " MUILang:" & @MUILang
	Local $KBLayout = ""
	If @OSLang <> StringRight(@KBLayout, 4) Then $KBLayout = " Keyboard:" & @KBLayout
	Local $CPUArch = ""
	If @OSArch <> @CPUArch Then $CPUArch = " CPUArch:" & @CPUArch
	Return SetError($curerr, $curext, "AutoIt:" & @AutoItVersion & $AutoItX64 & $AdminMode & $Compiled & _
			"   (Os:" & @OSVersion & $OsServicePack & "/" & @OSArch & _
			"   OSLang:" & @OSLang & $MUIlang & $KBLayout & $CPUArch & ")")
EndFunc   ;==>_DebugBugReportEnv

; #FUNCTION# ====================================================================================================================
; Name...........: _DebugOut
; Description ...: Outputs a string to the debugging session setup by _DebugSetup.
; Syntax.........: _DebugOut(Const $sOutput)
; Parameters ....: $sOutput = The string (or other printable value) to be output to the debugging session.
;                  $bActivate = Ignored, kept for backward compatibility.
; Return values .: Success - Returns 1.
;                  Failure - Returns 0 and Sets @Error:
;                  |0 - No error.
;                  |1 - $sOutput is an incompatible type.
;                  |3 - _DebugSetup() did not run properly.  Make sure _DebugSetup() ran properly before calling this function.
; Author ........: David Nuttall (Nutster)
; Modified.......: Jean-Paul Mesnage (jpm)
; Remarks .......: Before calling this function, _DebugSetup must be called first to create the debug session.
; Related .......: _DebugSetup
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _DebugOut(Const $sOutput, Const $bActivate = False, Const $curerr = @error, Const $curext = @extended)
	#forceref $bActivate
	If IsNumber($sOutput) = 0 And IsString($sOutput) = 0 And IsBool($sOutput) = 0 Then Return SetError(1, 0, 0) ; $sOutput can not be printed

;~ 	If WinExists($g_hWndDbg) = 0 Then Return SetError(4, 0, 0) ; The Notepad window no longer exists
	If _DebugReport($sOutput) = 0 Then Return SetError(3, 0, 0) ; _DebugSetup() as not been called.

	Return SetError($curerr, $curext, 1) ; Return @error and @extended as before calling _DebugOut()
EndFunc   ;==>_DebugOut

; #FUNCTION# ====================================================================================================================
; Name...........: _DebugSetup
; Description ...: Sets up a debug session using a specify reporting function.
; Syntax.........: _DebugSetup(Const $sTitle = Default, Const $bBugReportInfos = False, Const $vReportType = 1, $sReportCallBack = "")
; Parameters ....: $sTitle           - Title to be displayed on the report window.  Default value is "AutoIt Debug Report".
;                  $bBugReportInfos  - Display BugReport infos.  Default value is False.
;                  $vReportType      - 1 Report Log Window (Default).
;                                      2 ConsoleWrite.
;                                      3 MsgBox.
;                                      4 FileWrite into $sReportCallBack defines the filename.
;                                      any string value = name of specific report function to be used.
;                  $sLogFile         - Name of the file  if $vReportType = 4
; Return values .: Report type and set @error if already registered
; Author ........: jpm
; Modified.......:
; Remarks .......: If a specific reporting function is registered then on AutoIt exit it is called without parameter.
; Related .......: _DebugOut, _DebugReport, _DebugReportEx
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _DebugSetup(Const $sTitle = Default, Const $bBugReportInfos = False, $vReportType = 1, $sLogFile = "")
	If $__giReportType_Debug Then Return SetError(1, 0, $__giReportType_Debug) ; already registered

	Switch $vReportType
		Case 1
			; Report Log window
			$__gsReportCallBack_Debug = "__Debug_ReportWindowWrite("
		Case 2
			; ConsoleWrite
			$__gsReportCallBack_Debug = "ConsoleWrite("
		Case 3
			; Message box
			$__gsReportCallBack_Debug = "MsgBox(266256, '" & $__gsReportTitle_Debug & "',"
		Case 4
			; Log file
			$__gsReportCallBack_Debug = "FileWrite('" & $sLogFile & "',"
		Case 5
			; Report notepad window
			$__gsReportCallBack_Debug = "__Debug_ReportNotepadWrite("
		Case Else
			If Not IsString($vReportType) Then Return SetError(2, 0, 0) ; invalid Report type
			; private callback
			If $vReportType = "" Then Return SetError(3, 0, 0) ; invalid callback function
			$__gsReportCallBack_Debug = $vReportType & "("
			$vReportType = 6
	EndSwitch

	If Not IsKeyword($sTitle) Then $__gsReportTitle_Debug = $sTitle
	$__giReportType_Debug = $vReportType

	OnAutoItExitRegister("__Debug_ReportClose")

	If $bBugReportInfos Then _DebugReport(_DebugBugReportEnv() & @CRLF)

	Return $__giReportType_Debug
EndFunc   ;==>_DebugSetup

; #FUNCTION# ====================================================================================================================
; Name...........: _DebugReport
; Description ...: Writes to debugging session
; Syntax.........: _DebugReport($sData [,$bLastError = False [,$bExit = False]])
; Parameters ....: $sData      - Data to be reported
;                  $bLastError - True if GetLastErrorMessage() must be append to the data being reported
;                  $bExit      - True if the script must be terminated
; Return values .: Success : 1.
;                  Failure : 0.
; Author ........: jpm
; Modified.......:
; Remarks .......: If no _DebugSetup() have been issued the function always returns.
;                  @error of the caller is preserved.
;                  @extended can be set to Windows API GetlastError() if  $bLastError = True. Otherwise it is preserved.
; Related .......: _DebugSetup
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _DebugReport($sData, $bLastError = False, $bExit = False, $curerr = @error, $curext = @extended)
	If $__giReportType_Debug <= 0 Or $__giReportType_Debug > 6 Then Return SetError($curerr, $curext, 0)

	$curext = __Debug_ReportWrite($sData, $bLastError)

	If $bExit Then Exit

	Return SetError($curerr, $curext, 1)
EndFunc   ;==>_DebugReport

; #FUNCTION# ====================================================================================================================
; Name...........: _DebugReportEx
; Description ...: Writes to debugging session a formatted message
; Syntax.........: _DebugReportEx($sData [,$bLastError = False [,$bExit = False]])
; Parameters ....: $sData      - Data to be reported as "DLL|FUNCTION". See remarks.
;                  $bLastError - True if GetLastErrorMessage() must be append to the data being reported
;                  $bExit      - True if the script must be terminated
; Return values .: Success : 1.
;                  Failure : 0.
; Author ........: jpm
; Modified.......:
; Remarks .......: According to @error value the message will be formatted as follow:
;                              0 - report "Bad return from FUNCTION in DLL".
;                              1 - report "unable to open a dll"
;                              3 - report "unable to find FUNCTION in DLL".
;                  If $sData is does not contain a "|" or @error not as specified above the reported message will not be formated.
;                  If no _DebugSetup() have been issued the function always returns.
;                  @error of the caller is preserved.
;                  @extended can be set to Windows API GetlastError() if  $bLastError = True. Otherwise it is preserved.
; Related .......: _DebugSetup
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _DebugReportEx($sData, $bLastError = False, $bExit = False, $curerr = @error, $curext = @extended)
	If $__giReportType_Debug <= 0 Or $__giReportType_Debug > 6 Then Return SetError($curerr, $curext, 0)

	If IsInt($curerr) Then
		Local $sTemp = StringSplit($sData, "|", 2)
		If UBound($sTemp) > 1 Then
			If $bExit Then
				$sData = "<<< "
			Else
				$sData = ">>> "
			EndIf

			Switch $curerr
				Case 0
					$sData &= "Bad return from " & $sTemp[1] & " in " & $sTemp[0] & ".dll"
				Case 1
					$sData &= "Unable to open " & $sTemp[0] & ".dll"
				Case 3
					$sData &= "Unable to find " & $sTemp[1] & " in " & $sTemp[0] & ".dll"
			EndSwitch
		EndIf
	EndIf

	$curext = __Debug_ReportWrite($sData, $bLastError)

	If $bExit Then Exit

	Return SetError($curerr, $curext, 1)
EndFunc   ;==>_DebugReportEx

; #FUNCTION# ====================================================================================================================
; Name...........: _DebugReportVar
; Description ...: Writes to debugging session the content of a variable
; Syntax.........: _DebugReportVar($sVar [,$bErrExt = False])
; Parameters ....: $sVarname - string representing name of the variable or a comment
;                  $sVar     - the variable to be reported
;                  $bErrExt  - True if @error and @extended must be also displayed
; Return values .:
; Author ........: jpm
; Modified.......:
; Remarks .......: If no _DebugSetup() have been issued the function always returns.
;                  @error of the caller is preserved.
; Related .......: _DebugSetup
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _DebugReportVar($varName, $vVar, $bErrExt = False, $ScriptLineNumber = @ScriptLineNumber, $curerr = @error, $curext = @extended)
	If $__giReportType_Debug <= 0 Or $__giReportType_Debug > 6 Then Return SetError($curerr, $curext, 0)

	If IsBool($vVar) And IsInt($bErrExt) Then
		; to kept some compatibility with 3.3.1.3 if really needed for non breaking
		If StringLeft($varName, 1) = "$" Then $varName = StringTrimLeft($varName, 1)
		$vVar = Eval($varName)
		$varName = "???"
	EndIf

	Local $sData = "@@ Debug(" & $ScriptLineNumber & ") : " & __Debug_DataType($vVar) & " -> " & $varName

	If IsArray($vVar) Then
		Local $nDims = UBound($vVar, 0)
		Local $nRows = UBound($vVar, 1)
		Local $nCols = UBound($vVar, 2)
		For $d = 1 To $nDims
			$sData &= "[" & UBound($vVar, $d) & "]"
		Next

		If $nDims <= 2 Then
			For $r = 0 To $nRows - 1
				$sData &= @CRLF & "[" & $r & "] "
				If $nDims = 1 Then
					$sData &= __Debug_DataFormat($vVar[$r]) & @TAB
				Else
					For $c = 0 To $nCols - 1
						$sData &= __Debug_DataFormat($vVar[$r][$c]) & @TAB
					Next
				EndIf
			Next
		EndIf
	ElseIf IsDllStruct($vVar) Or IsObj($vVar) Then
	Else
		$sData &= ' = ' & __Debug_DataFormat($vVar)
	EndIf

	If $bErrExt Then $sData &= @CRLF & @TAB & "@error=" & $curerr & " @extended=0x" & Hex($curext)

	__Debug_ReportWrite($sData)

	Return SetError($curerr, $curext)
EndFunc   ;==>_DebugReportVar

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Debug_DataFormat
; Description ...: Returns a formatted data
; Syntax.........: __Debug_DataFormat($vData)
; Parameters ....: $vData - a data to be formatted
; Return values .: the data truncated if needed or the Datatype for not editable as Dllstruct, Obj or Array
; Author ........: jpm
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Debug_DataFormat($vData)
	Local $nLenMax = 25 ; to truncate String, Binary
	Local $sTruncated = ""
	If IsString($vData) Then
		If StringLen($vData) > $nLenMax Then
			$vData = StringLeft($vData, $nLenMax)
			$sTruncated = " ..."
		EndIf
		Return '"' & $vData & '"' & $sTruncated
	ElseIf IsBinary($vData) Then
		If BinaryLen($vData) > $nLenMax Then
			$vData = BinaryMid($vData, 1, $nLenMax)
			$sTruncated = " ..."
		EndIf
		Return $vData & $sTruncated
	ElseIf IsDllStruct($vData) Or IsArray($vData) Or IsObj($vData) Then
		Return __Debug_DataType($vData)
	Else
		Return $vData
	EndIf
EndFunc   ;==>__Debug_DataFormat

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Debug_DataType
; Description ...: Truncate a data
; Syntax.........: __Debug_DataType($vData)
; Parameters ....: $vData - a data
; Return values .: the data truncated if needed
; Author ........: jpm
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Debug_DataType($vData)
	Local $sType = VarGetType($vData)
	Switch $sType
		Case "DllStruct"
			$sType &= ":" & DllStructGetSize($vData)
		Case "Array"
			$sType &= " " & UBound($vData, 0) & "D"
		Case "String"
			$sType &= ":" & StringLen($vData)
		Case "Binary"
			$sType &= ":" & BinaryLen($vData)
		Case "Ptr"
			If IsHWnd($vData) Then $sType = "Hwnd"
	EndSwitch
	Return "{" & $sType & "}"
EndFunc   ;==>__Debug_DataType

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Debug_ReportClose
; Description ...: Close the debug session
; Syntax.........: __Debug_ReportClose()
; Parameters ....:
; Return values .:
; Author ........: jpm
; Modified.......:
; Remarks .......: If a specific reporting function has been registered then it is called without parameter.
; Related .......: _DebugSetup
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Debug_ReportClose()
	If $__giReportType_Debug = 1 Then
		__Debug_ReportWindowWaitClose()
	ElseIf $__giReportType_Debug = 6 Then
		Execute($__gsReportCallBack_Debug & ")")
	EndIf

	$__giReportType_Debug = 0
EndFunc   ;==>__Debug_ReportClose

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Debug_ReportWindowCreate
; Description ...: Create an report log window
; Syntax.........: __Debug_ReportWindowCreate()
; Parameters ....:
; Return values .: 0 if already created
; Author ........: jpm
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Debug_ReportWindowCreate()
	Local $nOld = Opt("WinDetectHiddenText", True)
	Local $bExists = WinExists($__gsReportTitle_Debug, $__gsReportWindowText_Debug)

	If $bExists Then
		If $__ghReportEdit_Debug = 0 Then
			; first time we try to access an open window in the running script,
			; get the control handle needed for writing in
			$__ghReportEdit_Debug = ControlGetHandle($__gsReportTitle_Debug, $__gsReportWindowText_Debug, "Edit1")
			; force no closing no waiting on report closing
			$__gbReportWindowWaitClose_Debug = False
		EndIf
	EndIf

	Opt("WinDetectHiddenText", $nOld)

	; change the state of the report Window as it is already opened or will be
	$__gbReportWindowClosed_Debug = False
	If Not $__gbReportWindowWaitClose_Debug Then Return 0 ; use of the already opened window

	Local Const $WS_OVERLAPPEDWINDOW = 0x00CF0000
	Local Const $WS_HSCROLL = 0x00100000
	Local Const $WS_VSCROLL = 0x00200000
	Local Const $ES_READONLY = 2048
	Local Const $EM_LIMITTEXT = 0xC5
	Local Const $GUI_HIDE = 32

	; Variables used to control different aspects of the GUI.
	Local $w = 580, $h = 280

	GUICreate($__gsReportTitle_Debug, $w, $h, -1, -1, $WS_OVERLAPPEDWINDOW)
	; We use a hidden label with unique test so we can reliably identify the window.
	Local $idLabelHidden = GUICtrlCreateLabel($__gsReportWindowText_Debug, 0, 0, 1, 1)
	GUICtrlSetState($idLabelHidden, $GUI_HIDE)
	Local $idEdit = GUICtrlCreateEdit("", 4, 4, $w - 8, $h - 8, BitOR($WS_HSCROLL, $WS_VSCROLL, $ES_READONLY))
	$__ghReportEdit_Debug = GUICtrlGetHandle($idEdit)
	GUICtrlSetBkColor($idEdit, 0xFFFFFF)
	GUICtrlSendMsg($idEdit, $EM_LIMITTEXT, 0, 0) ; Max the size of the edit control.

	GUISetState()

	; by default report closing will wait closing by user
	$__gbReportWindowWaitClose_Debug = True
	Return 1
EndFunc   ;==>__Debug_ReportWindowCreate

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Debug_ReportWindowWrite
; Description ...: Append text to the report log window
; Syntax.........: __Debug_ReportWindowWrite($sData)
; Parameters ....: $sData text to be append to the window
; Return values .:
; Author ........: jpm
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
#obfuscator_off
Func __Debug_ReportWindowWrite($sData)
	#obfuscator_on
	If $__gbReportWindowClosed_Debug Then __Debug_ReportWindowCreate()

	Local Const $WM_GETTEXTLENGTH = 0x000E
	Local Const $EM_SETSEL = 0xB1
	Local Const $EM_REPLACESEL = 0xC2

	Local $nLen = _SendMessage($__ghReportEdit_Debug, $WM_GETTEXTLENGTH, 0, 0, 0, "int", "int")
	_SendMessage($__ghReportEdit_Debug, $EM_SETSEL, $nLen, $nLen, 0, "int", "int")
	_SendMessage($__ghReportEdit_Debug, $EM_REPLACESEL, True, $sData, 0, "int", "wstr")
EndFunc   ;==>__Debug_ReportWindowWrite

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Debug_ReportWindowWaitClose
; Description ...: Wait the closing of the report log window
; Syntax.........: __Debug_ReportWindowWaitClose()
; Parameters ....:
; Return values .:
; Author ........: jpm
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Debug_ReportWindowWaitClose()
	If Not $__gbReportWindowWaitClose_Debug Then Return 0 ; use of the already opened window so no need to wait
	Local $nOld = Opt("WinDetectHiddenText", True)
	Local $hWndReportWindow = WinGetHandle($__gsReportTitle_Debug, $__gsReportWindowText_Debug)
	Opt("WinDetectHiddenText", $nOld)

	$nOld = Opt('GUIOnEventMode', 0) ; save event mode in case user script was using event mode
	Local Const $GUI_EVENT_CLOSE = -3
	Local $aMsg
	While WinExists(HWnd($hWndReportWindow))
		$aMsg = GUIGetMsg(1)
		If $aMsg[1] = $hWndReportWindow And $aMsg[0] = $GUI_EVENT_CLOSE Then GUIDelete($hWndReportWindow)
	WEnd
	Opt('GUIOnEventMode', $nOld) ; restore event mode

	$__ghReportEdit_Debug = 0
	$__gbReportWindowWaitClose_Debug = True
	$__gbReportWindowClosed_Debug = True
EndFunc   ;==>__Debug_ReportWindowWaitClose

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Debug_ReportNotepadCreate
; Description ...: Create an report log window
; Syntax.........: __Debug_ReportNotepadCreate()
; Parameters ....:
; Return values .: 0 if already created
; Author ........: jpm
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Debug_ReportNotepadCreate()
	Local $bExists = WinExists($__gsReportTitle_Debug)

	If $bExists Then
		If $__ghReportEdit_Debug = 0 Then
			; first time we try to access an open window in the running script,
			; get the control handle needed for writing in
			$__ghReportEdit_Debug = WinGetHandle($__gsReportTitle_Debug)
			Return 0 ; use of the already opened window
		EndIf
	EndIf

	Local $pNotepad = Run("Notepad.exe") ; process ID of the Notepad started by this function
	$__ghReportEdit_Debug = WinWait("[CLASS:Notepad]")
	If $pNotepad <> WinGetProcess($__ghReportEdit_Debug) Then
		Return SetError(3, 0, 0)
	EndIf

	WinActivate($__ghReportEdit_Debug)
	WinSetTitle($__ghReportEdit_Debug, "", String($__gsReportTitle_Debug))

	Return 1
EndFunc   ;==>__Debug_ReportNotepadCreate

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Debug_ReportNotepadWrite
; Description ...: Append text to the report notepad window
; Syntax.........: __Debug_ReportNotepadWrite($sData)
; Parameters ....: $sData text to be append to the window
; Return values .:
; Author ........: jpm
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
#obfuscator_off
Func __Debug_ReportNotepadWrite($sData)
	#obfuscator_on
	If $__ghReportEdit_Debug = 0 Then __Debug_ReportNotepadCreate()

	ControlCommand($__ghReportEdit_Debug, "", "Edit1", "EditPaste", String($sData))
EndFunc   ;==>__Debug_ReportNotepadWrite

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Debug_ReportWrite
; Description ...: Write on Report
; Syntax.........: __Debug_ReportWrite($sData, $bLastError [, $curext = @extended])
; Parameters ....:
; Return values .:
; Author ........: jpm
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Debug_ReportWrite($sData, $bLastError = False, $curext = @extended)
	Local $sError = @CRLF
	If $bLastError Then
		$curext = _WinAPI_GetLastError()

		Local Const $FORMAT_MESSAGE_FROM_SYSTEM = 0x1000
		Local $aResult = DllCall("kernel32.dll", "dword", "FormatMessageW", "dword", $FORMAT_MESSAGE_FROM_SYSTEM, "ptr", 0, _
				"dword", $curext, "dword", 0, "wstr", "", "dword", 4096, "ptr", 0)
		; Don't test @error since this is a debugging function.
		$sError = " : " & $aResult[5]
	EndIf

	$sData &= $sError

	Local $bBlock = BlockInput(1)
	BlockInput(0) ; force enable state so user can move mouse if needed

	$sData = StringReplace($sData, "'", "''") ; in case the data contains '
	Execute($__gsReportCallBack_Debug & "'" & $sData & "')")

	If Not $bBlock Then BlockInput(1) ; restore disable state

	Return $curext
EndFunc   ;==>__Debug_ReportWrite
