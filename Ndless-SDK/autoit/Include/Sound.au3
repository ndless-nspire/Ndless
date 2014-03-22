#include-once

#include "File.au3"		; Using: _PathSplit

; #INDEX# =======================================================================================================================
; Title .........: Sound
; AutoIt Version : 3.2 ++
; Language ......: English
; Description ...: Functions that assist with Sound management.
; Author(s) .....: RazerM, Melba23, Simucal, PsaltyDS
; Dll ...........: winmm.dll
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__SOUNDCONSTANT_SNDID_MARKER = 0x49442d2d
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_SoundOpen
;_SoundClose
;_SoundPlay
;_SoundStop
;_SoundPause
;_SoundResume
;_SoundLength
;_SoundSeek
;_SoundStatus
;_SoundPos
; ===============================================================================================================================

; #INTERNAL_USE_ONLY#============================================================================================================
;__SoundChkSndID
;__SoundMciSendString
;__SoundReadTLENFromMP3
;__SoundReadXingFromMP3
;__SoundTicksToTime
;__SoundTimeToTicks
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _SoundOpen
; Description ...: Opens a sound file for use with other _Sound functions
; Syntax.........: _SoundOpen($sFile)
; Parameters ....: $sFile - The sound file
; Return values..: Success      - 3-element array (used as Sound ID)
;                  Failure      - 0 and Sets @error to:
;                  @error     1 - Open failed - @extended holds MCI error code
;                             2 - File does not exist
; Author ........: RazerM, Melba23, some code by Simucal, PsaltyDS
; Modified.......:
; Remarks .......:
; Related .......: _SoundClose, _SoundLength, _SoundPause, _SoundPlay, , _SoundResume, _SoundStatus, _SoundStop
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _SoundOpen($sFile)
	;check for file
	If Not FileExists($sFile) Then Return SetError(2, 0, 0)
	;create random string for file ID
	Local $aSndID[4]
	For $i = 1 To 10
		$aSndID[0] &= Chr(Random(97, 122, 1))
	Next

	Local $szDrive, $szDir, $szFName, $szExt
	_PathSplit($sFile, $szDrive, $szDir, $szFName, $szExt)

	Local $sSndDirName
	If $szDrive = "" Then
		$sSndDirName = @WorkingDir & "\"
	Else
		$sSndDirName = $szDrive & $szDir
	EndIf
	Local $sSndFileName = $szFName & $szExt

	Local $sSndDirShortName = FileGetShortName($sSndDirName, 1)

	;open file
	__SoundMciSendString("open """ & $sFile & """ alias " & $aSndID[0])
	If @error Then Return SetError(1, @error, 0) ; open failed

	Local $sTrackLength, $fTryNextMethod = False
	Local $oShell = ObjCreate("shell.application")
	If IsObj($oShell) Then
		Local $oShellDir = $oShell.NameSpace($sSndDirShortName)
		If IsObj($oShellDir) Then
			Local $oShellDirFile = $oShellDir.Parsename($sSndFileName)
			If IsObj($oShellDirFile) Then
				Local $sRaw = $oShellDir.GetDetailsOf($oShellDirFile, -1)
				Local $aInfo = StringRegExp($sRaw, ": ([0-9]{2}:[0-9]{2}:[0-9]{2})", 3)
				If Not IsArray($aInfo) Then
					$fTryNextMethod = True
				Else
					$sTrackLength = $aInfo[0]
				EndIf
			Else
				$fTryNextMethod = True
			EndIf
		Else
			$fTryNextMethod = True
		EndIf
	Else
		$fTryNextMethod = True
	EndIf

	Local $sTag
	If $fTryNextMethod Then
		$fTryNextMethod = False
		If $szExt = ".mp3" Then
			Local $hFile = FileOpen(FileGetShortName($sSndDirName & $sSndFileName), 4)
			$sTag = FileRead($hFile, 5156)
			FileClose($hFile)
			$sTrackLength = __SoundReadXingFromMP3($sTag)
			If @error Then $fTryNextMethod = True
		Else
			$fTryNextMethod = True
		EndIf
	EndIf

	If $fTryNextMethod Then
		$fTryNextMethod = False
		If $szExt = ".mp3" Then
			$sTrackLength = __SoundReadTLENFromMP3($sTag)
			If @error Then $fTryNextMethod = True
		Else
			$fTryNextMethod = True
		EndIf
	EndIf

	If $fTryNextMethod Then
		$fTryNextMethod = False
		;tell mci to use time in milliseconds
		__SoundMciSendString("set " & $aSndID[0] & " time format miliseconds")
		;receive length of sound
		Local $iSndLenMs = __SoundMciSendString("status " & $aSndID[0] & " length", 255)

		;assign modified data to variables
		Local $iSndLenMin, $iSndLenHour, $iSndLenSecs
		__SoundTicksToTime($iSndLenMs, $iSndLenHour, $iSndLenMin, $iSndLenSecs)

		;assign formatted data to $sSndLenFormat
		$sTrackLength = StringFormat("%02i:%02i:%02i", $iSndLenHour, $iSndLenMin, $iSndLenSecs)
	EndIf

	; Convert Track_Length to mSec
	Local $aiTime = StringSplit($sTrackLength, ":")
	Local $iActualTicks = __SoundTimeToTicks($aiTime[1], $aiTime[2], $aiTime[3])

	;tell mci to use time in milliseconds
	__SoundMciSendString("set " & $aSndID[0] & " time format miliseconds")

	;;Get estimated length
	Local $iSoundTicks = __SoundMciSendString("status " & $aSndID[0] & " length", 255)

	;Compare to actual length
	Local $iVBRRatio
	If Abs($iSoundTicks - $iActualTicks) < 1000 Then ;Assume CBR, as our track length from shell.application is only accurate within 1000ms
		$iVBRRatio = 0
	Else ;Set correction ratio for VBR operations
		$iVBRRatio = $iSoundTicks / $iActualTicks
	EndIf

	$aSndID[1] = $iVBRRatio
	$aSndID[2] = 0
	$aSndID[3] = $__SOUNDCONSTANT_SNDID_MARKER

	Return $aSndID
EndFunc   ;==>_SoundOpen

; #FUNCTION# ====================================================================================================================
; Name...........: _SoundClose
; Description ...: Closes a sound
; Syntax.........: _SoundClose($aSndID)
; Parameters ....: $aSndID - Sound ID returned by _SoundOpen()
; Return values..: Success      - 1
;                  Failure      - 0 and set @error
;                  @error     1 - Close failed
;                             3 - Invalid Sound ID
; Author ........: RazerM, Melba23
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _SoundClose($aSndID)
	If Not IsArray($aSndID) Or Not __SoundChkSndID($aSndID) Then Return SetError(3, 0, 0) ; invalid sound ID

	__SoundMciSendString("close " & $aSndID[0])
	If @error Then Return SetError(1, @error, 0)
	Return 1
EndFunc   ;==>_SoundClose

; #FUNCTION# ====================================================================================================================
; Name...........: _SoundPlay
; Description ...: Plays a sound from the current position (beginning is the default)
; Syntax.........:_SoundPlay($aSndID[, $iWait = 0])
; Parameters ....: $aSndID - Sound ID returned by _SoundOpen() or sound file
;				   $iWait - If set to 1 the script will wait for the sound to finish before continuing
; Return values..: Success      - 1
;                  Failure      - 0 and set @error
;                  @error     1 - Play failed
;                             2 - Invalid $iWait parameter
;                             3 - Invalid Sound ID or file name
; Author ........: RazerM, Melba23
; Modified.......:
; Remarks .......:
; Related .......: _SoundPause, _SoundStop, _SoundSeek, _SoundOpen, _SoundResume
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _SoundPlay($aSndID, $iWait = 0)
	;validate $iWait
	If $iWait <> 0 And $iWait <> 1 Then Return SetError(2, 0, 0) ; invalid $iWait parameter
	If Not __SoundChkSndID($aSndID) Then Return SetError(3, 0, 0) ; invalid Sound ID or file name

	;if sound has finished, seek to start
	If _SoundPos($aSndID, 2) = _SoundLength($aSndID, 2) Then __SoundMciSendString("seek " & $aSndID[0] & " to start")
	;If $iWait = 1 then pass wait to mci
	If $iWait = 1 Then
		__SoundMciSendString("play " & $aSndID[0] & " wait")
	Else
		__SoundMciSendString("play " & $aSndID[0])
	EndIf
	;return
	If @error Then Return SetError(1, @error, 0)
	Return 1
EndFunc   ;==>_SoundPlay

; #FUNCTION# ====================================================================================================================
; Name...........: _SoundStop
; Description ...: Stops the sound
; Syntax.........: _SoundStop(ByRef $aSndID)
; Parameters ....: $aSndID - Sound ID returned by _SoundOpen() or sound file (must be a variable)
; Return values..: Success    - 1
;                  Failure    - 0 and set @error
;                  @error   1 - Stop failed
;                           3 - Invalid Sound ID or file name
; Author ........: RazerM, Melba23
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _SoundStop(ByRef $aSndID)
	; create temp variable so file name variable is not changed ByRef
	Local $vTemp = $aSndID
	If Not __SoundChkSndID($vTemp) Then Return SetError(3, 0, 0) ; invalid Sound ID or file name

	;reset VBR factor if used
	If IsArray($aSndID) Then $aSndID[2] = 0

	;stop
	__SoundMciSendString("stop " & $vTemp[0])
	If @error Then Return SetError(2, @error, 0)
	;seek to start
	__SoundMciSendString("seek " & $vTemp[0] & " to start")
	If @error Then Return SetError(1, @error, 0)
	;return
	Return 1
EndFunc   ;==>_SoundStop

; #FUNCTION# ====================================================================================================================
; Name...........: _SoundPause
; Description ...: Pauses the sound
; Syntax.........: _SoundPause($aSndID)
; Parameters ....: $aSndID - Sound ID returned by _SoundOpen() or sound file
; Return values..: Success      - 1
;                  Failure      - 0 and sets @error
;                  @error     1 - Pause failed
;                             3 - Invalid Sound ID or file name
; Author ........: RazerM, Melba23
; Modified.......:
; Remarks .......:
; Related .......: _SoundResume, _SoundOpen, _SoundPlay
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _SoundPause($aSndID)
	If Not __SoundChkSndID($aSndID) Then Return SetError(3, 0, 0) ; invalid Sound ID or file name

	;pause sound
	__SoundMciSendString("pause " & $aSndID[0])
	;return
	If @error Then Return SetError(1, @error, 0)
	Return 1
EndFunc   ;==>_SoundPause

; #FUNCTION# ====================================================================================================================
; Name...........: _SoundResume
; Description ...: Resumes the sound after being paused
; Syntax.........: _SoundResume($aSndID)
; Parameters ....: $aSndID - Sound ID returned by _SoundOpen() or sound file
; Return values..: Success      - 1
;                  Failure      - 0 and set @error
;                  @error     1 - Resume failed
;                             3 - Invalid Sound ID or file name
; Author ........: RazerM, Melba23
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _SoundResume($aSndID)
	If Not __SoundChkSndID($aSndID) Then Return SetError(3, 0, 0) ; invalid Sound ID or file name

	;resume sound
	__SoundMciSendString("resume " & $aSndID[0])
	;return
	If @error Then Return SetError(1, @error, 0)
	Return 1
EndFunc   ;==>_SoundResume

; #FUNCTION# ====================================================================================================================
; Name...........: _SoundLength
; Description ...: Returns the length of the sound in the format hh:mm:ss
; Syntax.........: _SoundLength($aSndID[, $iMode = 1])
; Parameters ....: $aSndID - Sound ID returned by _SoundOpen() or sound file,
;				   $iMode = 1 - hh:mm:ss, $iMode = 2 - milliseconds
; Return values .: Success      - Length of the sound
;                  Failure      - 0 and set @error
;                  @error     1 - Invalid $iMode parameter
;                             3 - Invalid Sound ID or file name
; Author ........: RazerM, Melba23
; Modified.......: jpm
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _SoundLength($aSndID, $iMode = 1)
	;validate $iMode
	If $iMode <> 1 And $iMode <> 2 Then Return SetError(1, 0, 0)
	Local $bFile = False
	If Not IsArray($aSndID) Then
		If Not FileExists($aSndID) Then Return SetError(3, 0, 0) ; invalid file name
		$bFile = True
		$aSndID = _SoundOpen($aSndID)
	Else
		If Not __SoundChkSndID($aSndID) Then Return SetError(3, 0, 0) ; invalid Sound ID
	EndIf

	;tell mci to use time in milliseconds
	__SoundMciSendString("set " & $aSndID[0] & " time format miliseconds")
	;receive length of sound
	Local $iSndLenMs = Number(__SoundMciSendString("status " & $aSndID[0] & " length", 255))
	If $aSndID[1] <> 0 Then $iSndLenMs = Round($iSndLenMs / $aSndID[1])

	If $bFile Then _SoundClose($aSndID) ;if user called _SoundLength with a filename

	If $iMode = 2 Then Return $iSndLenMs

	; $iMode = 1 (hh:mm:ss)

	;assign modified data to variables
	Local $iSndLenMin, $iSndLenHour, $iSndLenSecs
	__SoundTicksToTime($iSndLenMs, $iSndLenHour, $iSndLenMin, $iSndLenSecs)

	;assign formatted data to $sSndLenFormat
	Local $sSndLenFormat = StringFormat("%02i:%02i:%02i", $iSndLenHour, $iSndLenMin, $iSndLenSecs)

	;return correct variable
	Return $sSndLenFormat
EndFunc   ;==>_SoundLength

; #FUNCTION# ====================================================================================================================
; Name...........: _SoundSeek
; Description ...: Seeks the sound to a specified time
; Syntax.........:  _SoundSeek(ByRef $aSndID, $iHour, $iMin, $iSec)
; Parameters ....: $aSndID - Sound ID returned by _SoundOpen() (must NOT be a file), $iHour, $iMin, $iSec
; Return values..: Success      - 1
;                  Failure      - 0 and set @error
;                  @error     1 - Seek failed
;                             3 - Invalid Sound ID
; Author ........: RazerM, Melba23
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _SoundSeek(ByRef $aSndID, $iHour, $iMin, $iSec)
	If Not IsArray($aSndID) Or Not __SoundChkSndID($aSndID) Then Return SetError(3, 0, 0) ; invalid Sound ID

	;prepare mci to receive time in milliseconds
	__SoundMciSendString("set " & $aSndID[0] & " time format miliseconds")
	;modify the $iHour, $iMin and $iSec parameters to be in milliseconds
	;and add to $iMs
	Local $iMs = $iSec * 1000
	$iMs += $iMin * 60 * 1000
	$iMs += $iHour * 60 * 60 * 1000
	If $aSndID[1] <> 0 Then
		$aSndID[2] = Round($iMs * $aSndID[1]) - $iMs
		$iMs = Round($iMs * $aSndID[1])
	EndIf
	; seek sound to time ($iMs)
	__SoundMciSendString("seek " & $aSndID[0] & " to " & $iMs)
	Local $iError = @error
	If _SoundPos($aSndID, 2) < 0 Then $aSndID[2] = 0
	;return
	If $iError Then Return SetError(1, $iError, 0)
	Return 1
EndFunc   ;==>_SoundSeek

; #FUNCTION# ====================================================================================================================
; Name...........: _SoundStatus
; Description ...: All devices can return the "not ready", "paused", "playing", and "stopped" values.
; Syntax.........: _SoundStatus($aSndID)
; Parameters ....: $aSndID - Sound ID returned by _SoundOpen() or sound file
; Return values..: Success      - Sound status
;                  Failure      - 0 and set @error
;                  @error     3 - Invalid Sound ID or file name
; Author ........: RazerM, Melba23
; Modified.......:
; Remarks .......: Some devices can return the additional "open", "parked", "recording", and "seeking" values.(MSDN)
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _SoundStatus($aSndID)
	If Not __SoundChkSndID($aSndID) Then Return SetError(3, 0, 0) ; invalid Sound ID or file name

	;return status
	Return __SoundMciSendString("status " & $aSndID[0] & " mode", 255)
EndFunc   ;==>_SoundStatus

; #FUNCTION# ====================================================================================================================
; Name...........: _SoundPos
; Description ...: Returns the current position of the song
; Syntax.........: _SoundPos($aSndID[, $iMode = 1])
; Parameters ....: $aSndID - Sound ID returned by _SoundOpen() or sound file,
;				   $iMode = 1 - hh:mm:ss, $iMode = 2 - milliseconds
; Return values..: Success      - Current position
;                  Failure      - 0 and set @error
;                  @error     1 - Invalid $iMode
;                  |3 - Invalid Sound ID or file name
; Author ........: RazerM, Melba23
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _SoundPos($aSndID, $iMode = 1)
	;validate $iMode
	If $iMode <> 1 And $iMode <> 2 Then Return SetError(1, 0, 0)
	If Not __SoundChkSndID($aSndID) Then Return SetError(3, 0, 0) ; invalid Sound ID or file name

	;tell mci to use time in milliseconds
	__SoundMciSendString("set " & $aSndID[0] & " time format miliseconds")
	;receive position of sound
	Local $iSndPosMs = Number(__SoundMciSendString("status " & $aSndID[0] & " position", 255))
	If $aSndID[1] <> 0 Then
		$iSndPosMs -= $aSndID[2]
	EndIf

	If $iMode = 2 Then Return $iSndPosMs

	;$iMode = 1 (hh:mm:ss)

	;modify data and assign to variables
	Local $iSndPosMin, $iSndPosHour, $iSndPosSecs
	__SoundTicksToTime($iSndPosMs, $iSndPosHour, $iSndPosMin, $iSndPosSecs)

	;assign formatted data to $sSndPosFormat
	Local $sSndPosHMS = StringFormat("%02i:%02i:%02i", $iSndPosHour, $iSndPosMin, $iSndPosSecs)

	;return correct variable
	Return $sSndPosHMS
EndFunc   ;==>_SoundPos

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __SoundChkSndID
; Description ...: Used internally within this file, not for general use
; Syntax.........: __SoundChkSndID(ByRef $aSndID, $bInit=False, $iPos=Default)
; Author ........: jpm
; Modified.......: Melba23
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __SoundChkSndID(ByRef $aSndID)
	If Not IsArray($aSndID) Then
		If Not FileExists($aSndID) Then Return 0 ; invalid Sound file
		Local $vTemp = FileGetShortName($aSndID)
		Dim $aSndID[4] = [$vTemp, 0, 0, $__SOUNDCONSTANT_SNDID_MARKER] ; create valid Sound ID array for use in UDF
	Else
		If UBound($aSndID) <> 4 And $aSndID[3] <> $__SOUNDCONSTANT_SNDID_MARKER Then Return 0 ; invalid Sound ID
	EndIf

	Return 1
EndFunc   ;==>__SoundChkSndID

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __SoundMciSendString
; Description ...: Used internally within this file, not for general use
; Syntax.........: __SoundMciSendString($string[, $iLen = 0])
; Author ........: RazerM, Melba23
; Modified.......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __SoundMciSendString($string, $iLen = 0)
	Local $iRet = DllCall("winmm.dll", "dword", "mciSendStringW", "wstr", $string, "wstr", "", "uint", $iLen, "ptr", 0)
	If @error Then Return SetError(@error, @extended, "")
	If $iRet[0] Then Return SetError(10, $iRet[0], $iRet[2])
	Return $iRet[2]
EndFunc   ;==>__SoundMciSendString

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __SoundReadTLENFromMP3
; Description ...: Used internally within this file, not for general use
; Syntax.........: __SoundReadTLENFromMP3($sTag)
; Parameters ....: $sTag - >= 1024 bytes from 'read raw' mode.
; Return values .: Success      - Sound length (hh:mm:ss)
;                  Failure      - 0 and @error = 1
; Author ........: Melba23
; Modified.......: RazerM
; Remarks .......: File must be an mp3 AFAIK
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __SoundReadTLENFromMP3($sTag)
	; Check that an ID3v2.3 tag is present
	If StringLeft($sTag, 10) <> "0x49443303" Then Return SetError(1, 0, 0) ; ID3

	Local $iTemp = StringInStr($sTag, "544C454E") + 21 ; TLEN
	$sTag = StringTrimLeft($sTag, $iTemp)
	Local $sTemp = ""

	For $i = 1 To 32 Step 2
		If StringMid($sTag, $i, 2) = "00" Then
			ExitLoop
		Else
			$sTemp &= StringMid($sTag, $i, 2)
		EndIf
	Next

	Local $iLengthMs = Number(BinaryToString("0x" & $sTemp)) ; Number( HexToString($sTemp) )

	If $iLengthMs <= 0 Then Return SetError(1, 0, 0)
	Local $iLengthHour, $iLengthMin, $iLengthSecs
	__SoundTicksToTime($iLengthMs, $iLengthHour, $iLengthMin, $iLengthSecs)

	;Convert to hh:mm:ss and return
	Return StringFormat("%02i:%02i:%02i", $iLengthHour, $iLengthMin, $iLengthSecs)
EndFunc   ;==>__SoundReadTLENFromMP3

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __SoundReadXingFromMP3
; Syntax.........: __SoundReadXingFromMP3($sTag)
; Parameters ....: $sTag - first 5156 bytes from 'read raw' mode.
; Return values .: Success      - Sound length (hh:mm:ss)
;                  Failure      - 0 and @error = 1
; Author ........: Melba23
; Modified.......: RazerM
; Remarks .......: File must be an mp3 AFAIK
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __SoundReadXingFromMP3($sTag)
	Local $iXingPos = StringInStr($sTag, "58696E67") ; Xing
	If $iXingPos = 0 Then Return SetError(1, 0, 0)

	; Read fields flag
	Local $iFrames, $iFlags = Number("0x" & StringMid($sTag, $iXingPos + 14, 2))
	If BitAND($iFlags, 1) = 1 Then
		$iFrames = Number("0x" & StringMid($sTag, $iXingPos + 16, 8))
	Else
		Return SetError(1, 0, 0); No frames field
	EndIf

	; Now to find Samples per frame & Sampling rate
	; Go back to the frame header start
	Local $sHeader = StringMid($sTag, $iXingPos - 72, 8)

	; Read the relevant bytes
	Local $iMPEGByte = Number("0x" & StringMid($sHeader, 4, 1))
	Local $iFreqByte = Number("0x" & StringMid($sHeader, 6, 1))

	; Decode them
	; 8 = MPEG-1, 0 = MPEG-2
	Local $iMPEGVer = BitAND($iMPEGByte, 8)

	; 2 = Layer III, 4 = Layer II, 6 = Layer I
	Local $iLayerNum = BitAND($iMPEGByte, 6)

	Local $iSamples
	Switch $iLayerNum
		Case 6
			$iSamples = 384
		Case 4
			$iSamples = 1152
		Case 2
			Switch $iMPEGVer
				Case 8
					$iSamples = 1152
				Case 0
					$iSamples = 576
				Case Else
					$iSamples = 0
			EndSwitch
		Case Else
			$iSamples = 0
	EndSwitch

	; If not valid return
	If $iSamples = 0 Then Return SetError(1, 0, 0)

	; 0 = bit 00, 4 = Bit 01, 8 = Bit 10
	Local $iFrequency, $iFreqNum = BitAND($iFreqByte, 12)
	Switch $iFreqNum
		Case 0
			$iFrequency = 44100
		Case 4
			$iFrequency = 48000
		Case 8
			$iFrequency = 32000
		Case Else
			$iFrequency = 0
	EndSwitch

	; If not valid return
	If $iFrequency = 0 Then Return SetError(1, 0, 0)

	; MPEG-2 halves the value
	If $iMPEGVer = 0 Then $iFrequency = $iFrequency / 2

	; Duration in secs = No of frames * Samples per frame / Sampling freq
	Local $iLengthMs = Int(($iFrames * $iSamples / $iFrequency) * 1000)

	; Convert to hh:mm:ss and return
	Local $iLengthHours, $iLengthMins, $iLengthSecs
	__SoundTicksToTime($iLengthMs, $iLengthHours, $iLengthMins, $iLengthSecs)

	Return StringFormat("%02i:%02i:%02i", $iLengthHours, $iLengthMins, $iLengthSecs)
EndFunc   ;==>__SoundReadXingFromMP3

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: _TicksToTime
; Description ...: Converts the specified tick amount to hours, minutes and seconds.
; Syntax.........: _TicksToTime($iTicks, ByRef $iHours, ByRef $iMins, ByRef $iSecs)
; Parameters ....: $iTicks - Tick amount.
;                  $iHours - Variable to store the hours.
;                  $iMins - Variable to store the minutes.
;                  $iSecs - Variable to store the seconds.
; Return values .: Success - 1
;                  Failure - 0
;                  @Error - 0 - No error.
;                  |1 - $iTicks isn't an integer.
; Author ........: Marc <mrd at gmx de>
; Modified.......:
; Remarks .......:
; Related .......: __SoundTimeToTicks
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func __SoundTicksToTime($iTicks, ByRef $iHours, ByRef $iMins, ByRef $iSecs)
	If Number($iTicks) < 0 Then Return SetError(1, 0, 0)
	If Number($iTicks) = 0 Then
		$iHours = 0
		$iTicks = 0
		$iMins = 0
		$iSecs = 0
		Return 1
	EndIf
	$iTicks = Round($iTicks / 1000)
	$iHours = Int($iTicks / 3600)
	$iTicks = Mod($iTicks, 3600)
	$iMins = Int($iTicks / 60)
	$iSecs = Round(Mod($iTicks, 60))
	; If $iHours = 0 then $iHours = 24
	Return 1
EndFunc   ;==>__SoundTicksToTime

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: _TimeToTicks
; Description ...: Converts the specified hours, minutes, and seconds to ticks.
; Syntax.........: _TimeToTicks([$iHours = @HOUR[, $iMins = @MIN[, $iSecs = @SEC]]])
; Parameters ....: $iHours - The hours.
;                  $iMins - The minutes.
;                  $iSecs - The seconds.
; Return values .: Success - Returns the number of ticks.
;                  Failure - 0
;                  @Error - 0 - No error.
;                  |1 - The specified hours, minutes, or seconds are not valid.
; Author ........: Marc <mrd at gmx de>
; Modified.......: SlimShady: added the default time and made parameters optional
; Remarks .......:
; Related .......: _TicksToTime
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func __SoundTimeToTicks($iHours = @HOUR, $iMins = @MIN, $iSecs = @SEC)
	If Not (StringIsInt($iHours) And StringIsInt($iMins) And StringIsInt($iSecs)) Then Return SetError(1, 0, 0)
	Return 1000 * ((3600 * $iHours) + (60 * $iMins) + $iSecs)
EndFunc   ;==>__SoundTimeToTicks
