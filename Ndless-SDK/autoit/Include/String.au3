#include-once

; #INDEX# =======================================================================================================================
; Title .........: String
; AutoIt Version : 3.3.7.20++
; Description ...: Functions that assist with String management.
; Author(s) .....: Jarvis Stubblefield, SmOke_N, Valik, Wes Wolfe-Wolvereness, WeaponX, Louis Horvath, JdeB, Jeremy Landes, Jon
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_HexToString
;_StringBetween
;_StringEncrypt
;_StringExplode
;_StringInsert
;_StringProper
;_StringRepeat
;_StringReverse
;_StringToHex
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _HexToString
; Description ...: Convert a hex string to a string.
; Syntax.........: _HexToString($strHex)
; Parameters ....: $strHex - an hexadecimal string
; Return values .: Success - Returns a string.
;                  Failure - Returns -1 and sets @error to 1.
; Author ........: Jarvis Stubblefield
; Modified.......: SmOke_N - (Re-write using BinaryToString for speed)
; Remarks .......:
; Related .......: _StringToHex
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _HexToString($strHex)
	If StringLeft($strHex, 2) = "0x" Then Return BinaryToString($strHex)
	Return BinaryToString("0x" & $strHex)
EndFunc   ;==>_HexToString

; #FUNCTION# ====================================================================================================================
; Name...........: _StringBetween
; Description ...: Returns the string between the start search string and the end search string.
; Syntax.........: _StringBetween($s_String, $s_start, $s_end[, $v_Case = -1])
; Parameters ....: $s_String       - The string to search.
;                  $s_start        - The beginning of the string to find.  Passing a blank string starts at the beginning
;                  $s_end          - The end of the string to find.  Passing a blank string searches from $s_start to end
;                  $v_Case         - Optional: Case sensitive search. Default or -1 is not Case sensitive else Case sensitive.
; Return values .: Success - A 0 based $array[0] contains the first found string.
;                  Failure - 0
;                  |@Error  - 1 = No inbetween string found.
; Author ........: SmOke_N (Thanks to Valik for helping with the new StringRegExp (?s)(?i) isssue)
; Modified.......: SmOke_N - (Re-write for speed and accuracy)
; Remarks .......: 2009/05/03 Script breaking change, removed 5th parameter
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _StringBetween($s_String, $s_Start, $s_End, $v_Case = -1)

	; Set case type
	Local $s_case = ""
	If $v_Case = Default Or $v_Case = -1 Then $s_case = "(?i)"

	; Escape characters
	Local $s_pattern_escape = "(\.|\||\*|\?|\+|\(|\)|\{|\}|\[|\]|\^|\$|\\)"
	$s_Start = StringRegExpReplace($s_Start, $s_pattern_escape, "\\$1")
	$s_End = StringRegExpReplace($s_End, $s_pattern_escape, "\\$1")

	; If you want data from beginning then replace blank start with beginning of string
	If $s_Start = "" Then $s_Start = "\A"

	; If you want data from a start to an end then replace blank with end of string
	If $s_End = "" Then $s_End = "\z"

	Local $a_ret = StringRegExp($s_String, "(?s)" & $s_case & $s_Start & "(.*?)" & $s_End, 3)

	If @error Then Return SetError(1, 0, 0)
	Return $a_ret
EndFunc   ;==>_StringBetween

; #FUNCTION# ====================================================================================================================
; Name...........: _StringEncrypt
; Description ...: An RC4 based string encryption function.
; Syntax.........: _StringEncrypt($i_Encrypt, $s_EncryptText, $s_EncryptPassword[, $i_EncryptLevel = 1])
; Parameters ....: $i_Encrypt         - 1 to encrypt, 0 to decrypt.
;                  $s_EncryptText     - Text to encrypt/decrypt.
;                  $s_EncryptPassword - Password to encrypt/decrypt with.
;                  $i_EncryptLevel    - Optional: Level to encrypt/decrypt. Default = 1
; Return values .: Success - The Encrypted/Decrypted string.
;                  Failure - Blank string and @error = 1
; Author ........: Wes Wolfe-Wolvereness <Weswolf at aol dot com>
; Modified.......:
; Remarks .......: WARNING: This function has an extreme timespan if the encryption level or encrypted string are too large!
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _StringEncrypt($i_Encrypt, $s_EncryptText, $s_EncryptPassword, $i_EncryptLevel = 1)
	If $i_Encrypt <> 0 And $i_Encrypt <> 1 Then
		SetError(1, 0, '')
	ElseIf $s_EncryptText = '' Or $s_EncryptPassword = '' Then
		SetError(1, 0, '')
	Else
		If Number($i_EncryptLevel) <= 0 Or Int($i_EncryptLevel) <> $i_EncryptLevel Then $i_EncryptLevel = 1
		Local $v_EncryptModified
		Local $i_EncryptCountH
		Local $i_EncryptCountG
		Local $v_EncryptSwap
		Local $av_EncryptBox[256][2]
		Local $i_EncryptCountA
		Local $i_EncryptCountB
		Local $i_EncryptCountC
		Local $i_EncryptCountD
		Local $i_EncryptCountE
		Local $v_EncryptCipher
		Local $v_EncryptCipherBy
		If $i_Encrypt = 1 Then
			For $i_EncryptCountF = 0 To $i_EncryptLevel Step 1
				$i_EncryptCountG = ''
				$i_EncryptCountH = ''
				$v_EncryptModified = ''
				For $i_EncryptCountG = 1 To StringLen($s_EncryptText)
					If $i_EncryptCountH = StringLen($s_EncryptPassword) Then
						$i_EncryptCountH = 1
					Else
						$i_EncryptCountH += 1
					EndIf
					$v_EncryptModified = $v_EncryptModified & Chr(BitXOR(Asc(StringMid($s_EncryptText, $i_EncryptCountG, 1)), Asc(StringMid($s_EncryptPassword, $i_EncryptCountH, 1)), 255))
				Next
				$s_EncryptText = $v_EncryptModified
				$i_EncryptCountA = ''
				$i_EncryptCountB = 0
				$i_EncryptCountC = ''
				$i_EncryptCountD = ''
				$i_EncryptCountE = ''
				$v_EncryptCipherBy = ''
				$v_EncryptCipher = ''
				$v_EncryptSwap = ''
				$av_EncryptBox = ''
				Local $av_EncryptBox[256][2]
				For $i_EncryptCountA = 0 To 255
					$av_EncryptBox[$i_EncryptCountA][1] = Asc(StringMid($s_EncryptPassword, Mod($i_EncryptCountA, StringLen($s_EncryptPassword)) + 1, 1))
					$av_EncryptBox[$i_EncryptCountA][0] = $i_EncryptCountA
				Next
				For $i_EncryptCountA = 0 To 255
					$i_EncryptCountB = Mod(($i_EncryptCountB + $av_EncryptBox[$i_EncryptCountA][0] + $av_EncryptBox[$i_EncryptCountA][1]), 256)
					$v_EncryptSwap = $av_EncryptBox[$i_EncryptCountA][0]
					$av_EncryptBox[$i_EncryptCountA][0] = $av_EncryptBox[$i_EncryptCountB][0]
					$av_EncryptBox[$i_EncryptCountB][0] = $v_EncryptSwap
				Next
				For $i_EncryptCountA = 1 To StringLen($s_EncryptText)
					$i_EncryptCountC = Mod(($i_EncryptCountC + 1), 256)
					$i_EncryptCountD = Mod(($i_EncryptCountD + $av_EncryptBox[$i_EncryptCountC][0]), 256)
					$i_EncryptCountE = $av_EncryptBox[Mod(($av_EncryptBox[$i_EncryptCountC][0] + $av_EncryptBox[$i_EncryptCountD][0]), 256)][0]
					$v_EncryptCipherBy = BitXOR(Asc(StringMid($s_EncryptText, $i_EncryptCountA, 1)), $i_EncryptCountE)
					$v_EncryptCipher &= Hex($v_EncryptCipherBy, 2)
				Next
				$s_EncryptText = $v_EncryptCipher
			Next
		Else
			For $i_EncryptCountF = 0 To $i_EncryptLevel Step 1
				$i_EncryptCountB = 0
				$i_EncryptCountC = ''
				$i_EncryptCountD = ''
				$i_EncryptCountE = ''
				$v_EncryptCipherBy = ''
				$v_EncryptCipher = ''
				$v_EncryptSwap = ''
				$av_EncryptBox = ''
				Local $av_EncryptBox[256][2]
				For $i_EncryptCountA = 0 To 255
					$av_EncryptBox[$i_EncryptCountA][1] = Asc(StringMid($s_EncryptPassword, Mod($i_EncryptCountA, StringLen($s_EncryptPassword)) + 1, 1))
					$av_EncryptBox[$i_EncryptCountA][0] = $i_EncryptCountA
				Next
				For $i_EncryptCountA = 0 To 255
					$i_EncryptCountB = Mod(($i_EncryptCountB + $av_EncryptBox[$i_EncryptCountA][0] + $av_EncryptBox[$i_EncryptCountA][1]), 256)
					$v_EncryptSwap = $av_EncryptBox[$i_EncryptCountA][0]
					$av_EncryptBox[$i_EncryptCountA][0] = $av_EncryptBox[$i_EncryptCountB][0]
					$av_EncryptBox[$i_EncryptCountB][0] = $v_EncryptSwap
				Next
				For $i_EncryptCountA = 1 To StringLen($s_EncryptText) Step 2
					$i_EncryptCountC = Mod(($i_EncryptCountC + 1), 256)
					$i_EncryptCountD = Mod(($i_EncryptCountD + $av_EncryptBox[$i_EncryptCountC][0]), 256)
					$i_EncryptCountE = $av_EncryptBox[Mod(($av_EncryptBox[$i_EncryptCountC][0] + $av_EncryptBox[$i_EncryptCountD][0]), 256)][0]
					$v_EncryptCipherBy = BitXOR(Dec(StringMid($s_EncryptText, $i_EncryptCountA, 2)), $i_EncryptCountE)
					$v_EncryptCipher = $v_EncryptCipher & Chr($v_EncryptCipherBy)
				Next
				$s_EncryptText = $v_EncryptCipher
				$i_EncryptCountG = ''
				$i_EncryptCountH = ''
				$v_EncryptModified = ''
				For $i_EncryptCountG = 1 To StringLen($s_EncryptText)
					If $i_EncryptCountH = StringLen($s_EncryptPassword) Then
						$i_EncryptCountH = 1
					Else
						$i_EncryptCountH += 1
					EndIf
					$v_EncryptModified &= Chr(BitXOR(Asc(StringMid($s_EncryptText, $i_EncryptCountG, 1)), Asc(StringMid($s_EncryptPassword, $i_EncryptCountH, 1)), 255))
				Next
				$s_EncryptText = $v_EncryptModified
			Next
		EndIf
		Return $s_EncryptText
	EndIf
EndFunc   ;==>_StringEncrypt

; #FUNCTION# ====================================================================================================================
; Name...........: _StringExplode
; Description ...: Splits up a string into substrings depending on the given delimiters as PHP Explode v5.
; Syntax.........: _StringExplode($sString, $sDelimiter [, $iLimit] )
; Parameters ....: $sString    - String to be split
;                  $sDelimiter - Delimiter to split on (split is performed on entire string, not individual characters)
;                  $iLimit     - [optional] Maximum elements to be returned
;                  |=0 : (default) Split on every instance of the delimiter
;                  |>0 : Split until limit, last element will contain remaining portion of the string
;                  |<0 : Split on every instance, removing limit count from end of the array
; Return values .: Success - an array containing the exploded strings.
; Author ........: WeaponX
; Modified.......:
; Remarks .......: Use negative limit values to remove the first possible elements.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _StringExplode($sString, $sDelimiter, $iLimit = 0)
	If $iLimit > 0 Then
		;Replace delimiter with NULL character using given limit
		$sString = StringReplace($sString, $sDelimiter, Chr(0), $iLimit)

		;Split on NULL character, this will leave the remainder in the last element
		$sDelimiter = Chr(0)
	ElseIf $iLimit < 0 Then
		;Find delimiter occurence from right-to-left
		Local $iIndex = StringInStr($sString, $sDelimiter, 0, $iLimit)

		If $iIndex Then
			;Split on left side of string only
			$sString = StringLeft($sString, $iIndex - 1)
		EndIf
	EndIf

	Return StringSplit($sString, $sDelimiter, 3)
EndFunc   ;==>_StringExplode

; #FUNCTION# ====================================================================================================================
; Name...........: _StringInsert
; Description ...: Inserts a string within another string.
; Syntax.........: _StringInsert($s_String, $s_InsertString, $i_Position)
; Parameters ....: $s_String   - Original string
;                  $s_InsertString   - String to be inserted
;                  $i_Position - Position to insert string (negatives values count from right hand side)
; Return values .: Success - Returns new modified string
;                  Failure - Returns original string and sets the @error to the following values:
;                  |@error = 1 : Source string empty
;                  |@error = 2 : Insert string empty
;                  |@error = 3 : Invalid position
; Author ........: Louis Horvath <celeri at videotron dot ca>
; Modified.......:
; Remarks .......: Use negative position values to insert string from the right hand side.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _StringInsert($s_String, $s_InsertString, $i_Position)
	Local $i_Length, $s_Start, $s_End

	If $s_String = "" Or (Not IsString($s_String)) Then
		Return SetError(1, 0, $s_String) ; Source string empty / not a string
	ElseIf $s_InsertString = "" Or (Not IsString($s_String)) Then
		Return SetError(2, 0, $s_String) ; Insert string empty / not a string
	Else
		$i_Length = StringLen($s_String) ; Take a note of the length of the source string
		If (Abs($i_Position) > $i_Length) Or (Not IsInt($i_Position)) Then
			Return SetError(3, 0, $s_String) ; Invalid position
		EndIf
	EndIf

	; If $i_Position at start of string
	If $i_Position = 0 Then
		Return $s_InsertString & $s_String ; Just add them up :) Easy :)
		; If $i_Position is positive
	ElseIf $i_Position > 0 Then
		$s_Start = StringLeft($s_String, $i_Position) ; Chop off first part
		$s_End = StringRight($s_String, $i_Length - $i_Position) ; and the second part
		Return $s_Start & $s_InsertString & $s_End ; Assemble all three pieces together
		; If $i_Position is negative
	ElseIf $i_Position < 0 Then
		$s_Start = StringLeft($s_String, Abs($i_Length + $i_Position)) ; Chop off first part
		$s_End = StringRight($s_String, Abs($i_Position)) ; and the second part
		Return $s_Start & $s_InsertString & $s_End ; Assemble all three pieces together
	EndIf
EndFunc   ;==>_StringInsert

; #FUNCTION# ====================================================================================================================
; Name...........: _StringProper
; Description ...: Changes a string to proper case, same a =Proper function in Excel
; Syntax.........: _StringProper($s_String)
; Parameters ....: $s_String - Input string
; Return values .: Success - Returns proper string.
;                  Failure - Returns "".
; Author ........: Jos van der Zande <jdeb at autoitscript dot com>
; Modified.......:
; Remarks .......: This function will capitalize every character following a None Apha character.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _StringProper($s_String)
	Local $iX = 0
	Local $CapNext = 1
	Local $s_nStr = ""
	Local $s_CurChar
	For $iX = 1 To StringLen($s_String)
		$s_CurChar = StringMid($s_String, $iX, 1)
		Select
			Case $CapNext = 1
				If StringRegExp($s_CurChar, '[a-zA-ZÀ-ÿšœžŸ]') Then
					$s_CurChar = StringUpper($s_CurChar)
					$CapNext = 0
				EndIf
			Case Not StringRegExp($s_CurChar, '[a-zA-ZÀ-ÿšœžŸ]')
				$CapNext = 1
			Case Else
				$s_CurChar = StringLower($s_CurChar)
		EndSelect
		$s_nStr &= $s_CurChar
	Next
	Return $s_nStr
EndFunc   ;==>_StringProper

; #FUNCTION# ====================================================================================================================
; Name...........: _StringRepeat
; Description ...: Repeats a string a specified number of times.
; Syntax.........: _StringRepeat($sString, $iRepeatCount)
; Parameters ....: $sString      - String to repeat
;                  $iRepeatCount - Number of times to repeat the string
; Return values .: Success - Returns string with specified number of repeats
;                  Failure - Returns an empty string and sets @error = 1
;                  |@Error  - 0 = No error.
;                  |@Error  - 1 = One of the parameters is invalid
; Author ........: Jeremy Landes <jlandes at landeserve dot com>
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _StringRepeat($sString, $iRepeatCount)
	;==============================================
	; Local Constant/Variable Declaration Section
	;==============================================
	Local $sResult

	Select
		Case Not StringIsInt($iRepeatCount)
			SetError(1)
			Return ""
		Case StringLen($sString) < 1
			SetError(1)
			Return ""
		Case $iRepeatCount <= 0
			SetError(1)
			Return ""
		Case Else
			For $iCount = 1 To $iRepeatCount
				$sResult &= $sString
			Next

			Return $sResult
	EndSelect
EndFunc   ;==>_StringRepeat

; #FUNCTION# ====================================================================================================================
; Name...........: _StringReverse
; Description ...: Reverses the contents of the specified string.
; Syntax.........: _StringReverse($s_String)
; Parameters ....: $s_String - String to reverse
; Return values .: Success - Returns reversed string
;                  Failure - Returns an empty string and sets @error = 1
;                  |@Error  - 0 = No error.
;                  |@Error  - 1 = One of the parameters is invalid
;                  |@Error  - 2 = Dll error
; Author ........: Jon
; Modified.......: SmOke_N (Re-written using msvcrt.dll for speed)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _StringReverse($s_String)

	Local $i_len = StringLen($s_String)
	If $i_len < 1 Then Return SetError(1, 0, "")

	Local $t_chars = DllStructCreate("char[" & $i_len + 1 & "]")
	DllStructSetData($t_chars, 1, $s_String)

	Local $a_rev = DllCall("msvcrt.dll", "ptr:cdecl", "_strrev", "struct*", $t_chars)
	If @error Or $a_rev[0] = 0 Then Return SetError(2, 0, "")

	Return DllStructGetData($t_chars, 1)
EndFunc   ;==>_StringReverse

; #FUNCTION# ====================================================================================================================
; Name...........: _StringToHex
; Description ...: Convert a string to a hex string.
; Syntax.........: _StringToHex($strChar)
; Parameters ....: $strChar - string to be converted.
; Return values .: Success - Returns an hex string.
;                  Failure - Returns -1 and sets @error to 1.
; Author ........: Jarvis Stubblefield
; Modified.......: SmOke_N - (Re-write using StringToBinary for speed)
; Remarks .......:
; Related .......: _HexToString
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _StringToHex($strChar)
	Return Hex(StringToBinary($strChar))
EndFunc   ;==>_StringToHex
