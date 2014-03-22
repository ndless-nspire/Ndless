#include-once

#include "FileConstants.au3"

; #INDEX# =======================================================================================================================
; Title .........: File
; AutoIt Version : 3.2
; Language ......: English
; Description ...: Functions that assist with files and directories.
; Author(s) .....: Brian Keene, SolidSnake, erifash, Jon, JdeB, Jeremy Landes, MrCreatoR, cdkid, Valik,Erik Pilsits, Kurt, Dale
; Dll(s) ........: shell32.dll
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_FileCountLines
;_FileCreate
;_FileListToArray
;_FilePrint
;_FileReadToArray
;_FileWriteFromArray
;_FileWriteLog
;_FileWriteToLine
;_PathFull
;_PathGetRelative
;_PathMake
;_PathSplit
;_ReplaceStringInFile
;_TempFile
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _FileCountLines
; Description ...: Returns the number of lines in the specified file.
; Syntax.........: _FileCountLines($sFilePath)
; Parameters ....: $sFilePath - Path and filename of the file to be read
; Return values .: Success - Returns number of lines in the file.
;                  Failure - Returns a 0
;                  @Error  - 0 = No error.
;                  |1 = File cannot be opened or found.
; Author ........: Tylo <tylo at start dot no>
; Modified.......: Xenobiologist, Gary
; Remarks .......: It does not count a final @LF as a line.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _FileCountLines($sFilePath)

	Local $hFile = FileOpen($sFilePath, $FO_READ)
	If $hFile = -1 Then Return SetError(1, 0, 0)
	Local $sFileContent = StringStripWS(FileRead($hFile), 2)
	FileClose($hFile)
	Local $aTmp
	If StringInStr($sFileContent, @LF) Then
		$aTmp = StringSplit(StringStripCR($sFileContent), @LF)
	ElseIf StringInStr($sFileContent, @CR) Then
		$aTmp = StringSplit($sFileContent, @CR)
	Else
		If StringLen($sFileContent) Then
			Return 1
		Else
			Return SetError(2, 0, 0)
		EndIf
	EndIf
	Return $aTmp[0]
EndFunc   ;==>_FileCountLines


; #FUNCTION# ====================================================================================================================
; Name...........: _FileCreate
; Description ...: Creates or zero's out the length of the file specified.
; Syntax.........: _FileCreate($sFilePath)
; Parameters ....: $sFilePath - Path and filename of the file to be created.
; Return values .: Success - Returns a 1
;                  Failure - Returns a 0
;                  @Error  - 0 = No error.
;                  |1 = Error opening specified file
;                  |2 = File could not be written to
; Author ........: Brian Keene <brian_keene at yahoo dot com>
; Modified.......:
; Remarks .......:
; Related .......: .FileOpen
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _FileCreate($sFilePath)
	Local $hOpenFile = FileOpen($sFilePath, $FO_OVERWRITE)
	If $hOpenFile = -1 Then Return SetError(1, 0, 0)

	Local $hWriteFile = FileWrite($hOpenFile, "")
	FileClose($hOpenFile)
	If $hWriteFile = -1 Then Return SetError(2, 0, 0)
	Return 1
EndFunc   ;==>_FileCreate

; #FUNCTION# ====================================================================================================================
; Name...........: _FileListToArray
; Description ...: Lists files and\or folders in a specified path (Similar to using Dir with the /B Switch)
; Syntax.........: _FileListToArray($sPath[, $sFilter = "*"[, $iFlag = 0]])
; Parameters ....: $sPath   - Path to generate filelist for.
;                  $sFilter - Optional the filter to use, default is *. Search the Autoit3 helpfile for the word "WildCards" For details.
;                  $iFlag   - Optional: specifies whether to return files folders or both
;                  |$iFlag=0(Default) Return both files and folders
;                  |$iFlag=1 Return files only
;                  |$iFlag=2 Return Folders only
; Return values .: @Error - 1 = Path not found or invalid
;                  |2 = Invalid $sFilter
;                  |3 = Invalid $iFlag
;                  |4 = No File(s) Found
; Author ........: SolidSnake <MetalGX91 at GMail dot com>
; Modified.......:
; Remarks .......: The array returned is one-dimensional and is made up as follows:
;                                $array[0] = Number of Files\Folders returned
;                                $array[1] = 1st File\Folder
;                                $array[2] = 2nd File\Folder
;                                $array[3] = 3rd File\Folder
;                                $array[n] = nth File\Folder
; Related .......:
; Link ..........:
; Example .......: Yes
; Note ..........: Special Thanks to Helge and Layer for help with the $iFlag update speed optimization by code65536, pdaughe
; ===============================================================================================================================
Func _FileListToArray($sPath, $sFilter = "*", $iFlag = 0)
	Local $hSearch, $sFile, $sFileList, $sDelim = "|"
	$sPath = StringRegExpReplace($sPath, "[\\/]+\z", "") & "\" ; ensure single trailing backslash
	If Not FileExists($sPath) Then Return SetError(1, 1, "")
	If StringRegExp($sFilter, "[\\/:><\|]|(?s)\A\s*\z") Then Return SetError(2, 2, "")
	If Not ($iFlag = 0 Or $iFlag = 1 Or $iFlag = 2) Then Return SetError(3, 3, "")
	$hSearch = FileFindFirstFile($sPath & $sFilter)
	If @error Then Return SetError(4, 4, "")
	While 1
		$sFile = FileFindNextFile($hSearch)
		If @error Then ExitLoop
		If ($iFlag + @extended = 2) Then ContinueLoop
		$sFileList &= $sDelim & $sFile
	WEnd
	FileClose($hSearch)
	If Not $sFileList Then Return SetError(4, 4, "")
	Return StringSplit(StringTrimLeft($sFileList, 1), "|")
EndFunc   ;==>_FileListToArray

; #FUNCTION# ====================================================================================================================
; Name...........: _FilePrint
; Description ...: Prints a plain text file.
; Syntax.........: _FilePrint($s_File[, $i_Show = @SW_HIDE])
; Parameters ....: $s_File - The file to print.
;                  $i_Show - The state of the window. (default = @SW_HIDE)
; Return values .: Success - Returns 1.
;                  Failure - Returns 0 and sets @error according to the global constants list.
; Author ........: erifash <erifash [at] gmail [dot] com>
; Modified.......:
; Remarks .......: Uses the ShellExecute function of shell32.dll.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _FilePrint($s_File, $i_Show = @SW_HIDE)
	Local $a_Ret = DllCall("shell32.dll", "int", "ShellExecuteW", _
			"hwnd", 0, _
			"wstr", "print", _
			"wstr", $s_File, _
			"wstr", "", _
			"wstr", "", _
			"int", $i_Show)
	If @error Then Return SetError(@error, @extended, 0)
	If $a_Ret[0] <= 32 Then Return SetError(10, $a_Ret[0], 0)
	Return 1
EndFunc   ;==>_FilePrint

; #FUNCTION# ====================================================================================================================
; Name...........: _FileReadToArray
; Description ...: Reads the specified file into an array.
; Syntax.........: _FileReadToArray($sFilePath, ByRef $aArray)
; Parameters ....: $sFilePath - Path and filename of the file to be read.
;                  $aArray    - The array to store the contents of the file.
; Return values .: Success - Returns a 1
;                  Failure - Returns a 0
;                  @Error  - 0 = No error.
;                  |1 = Error opening specified file
;                  |2 = Unable to Split the file
; Author ........: Jonathan Bennett <jon at hiddensoft dot com>, Valik - Support Windows Unix and Mac line separator
; Modified.......: Jpm - fixed empty line at the end, Gary Fixed file contains only 1 line.
; Remarks .......: $aArray[0] will contain the number of records read into the array.
; Related .......: _FileWriteFromArray
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _FileReadToArray($sFilePath, ByRef $aArray)
	Local $hFile = FileOpen($sFilePath, $FO_READ)
	If $hFile = -1 Then Return SetError(1, 0, 0);; unable to open the file
	;; Read the file and remove any trailing white spaces
	Local $aFile = FileRead($hFile, FileGetSize($sFilePath))
;~ 	$aFile = StringStripWS($aFile, 2)
	; remove last line separator if any at the end of the file
	If StringRight($aFile, 1) = @LF Then $aFile = StringTrimRight($aFile, 1)
	If StringRight($aFile, 1) = @CR Then $aFile = StringTrimRight($aFile, 1)
	FileClose($hFile)
	If StringInStr($aFile, @LF) Then
		$aArray = StringSplit(StringStripCR($aFile), @LF)
	ElseIf StringInStr($aFile, @CR) Then ;; @LF does not exist so split on the @CR
		$aArray = StringSplit($aFile, @CR)
	Else ;; unable to split the file
		If StringLen($aFile) Then
			Dim $aArray[2] = [1, $aFile]
		Else
			Return SetError(2, 0, 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_FileReadToArray

; #FUNCTION# ====================================================================================================================
; Name...........: _FileWriteFromArray
; Description ...: Writes Array records to the specified file.
; Syntax.........: _FileWriteFromArray($File, $a_Array[, $i_Base = 0[, $i_UBound = 0 [, $s_Delim= "|"]])
; Parameters ....: $File     - String path of the file to write to, or a file handle returned from FileOpen().
;                  $a_Array  - The array to be written to the file.
;                  $i_Base   - Optional: Start Array index to read, normally set to 0 or 1. Default=0
;                  $i_Ubound - Optional: Set to the last record you want to write to the File. default=0 - whole array.
;                  $s_Delim  - Optional: Delimiter character(s) for 2-dimension arrays. default="|"
; Return values .: Success - Returns a 1
;                  Failure - Returns a 0
;                  @Error  - 0 = No error.
;                  |1 = Error opening specified file
;                  |2 = Input is not an Array
;                  |3 = Error writing to file
;                  |4 = Array dimensions > 2
; Author ........: Jos van der Zande <jdeb at autoitscript dot com>
; Modified.......: Updated for file handles by PsaltyDS, @error = 4 msg and 2-dimension capability added by SPiff59
; Remarks .......: If a string path is provided, the file is overwritten and closed.
;                  To use other write modes, like append or Unicode formats, open the file with FileOpen() first and pass the file handle instead.
;                  If a file handle is passed, the file will still be open after writing.
; Related .......: _FileReadToArray
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _FileWriteFromArray($File, $a_Array, $i_Base = 0, $i_UBound = 0, $s_Delim = "|")
	; Check if we have a valid array as input
	If Not IsArray($a_Array) Then Return SetError(2, 0, 0)
	Local $iDims = UBound($a_Array, 0)
	If $iDims > 2 Then Return SetError(4, 0, 0)

	; determine last entry
	Local $last = UBound($a_Array) - 1
	If $i_UBound < 1 Or $i_UBound > $last Then $i_UBound = $last
	If $i_Base < 0 Or $i_Base > $last Then $i_Base = 0

	; Open output file for overwrite by default, or use input file handle if passed
	Local $hFile
	If IsString($File) Then
		$hFile = FileOpen($File, $FO_OVERWRITE)
	Else
		$hFile = $File
	EndIf
	If $hFile = -1 Then Return SetError(1, 0, 0)

	; Write array data to file
	Local $ErrorSav = 0
	Switch $iDims
		Case 1
			For $x = $i_Base To $i_UBound
				If FileWrite($hFile, $a_Array[$x] & @CRLF) = 0 Then
					$ErrorSav = 3
					ExitLoop
				EndIf
			Next
		Case 2
			Local $s_Temp
			For $x = $i_Base To $i_UBound
				$s_Temp = $a_Array[$x][0]
				For $y = 1 To $iDims
					$s_Temp &= $s_Delim & $a_Array[$x][$y]
				Next
				If FileWrite($hFile, $s_Temp & @CRLF) = 0 Then
					$ErrorSav = 3
					ExitLoop
				EndIf
			Next
	EndSwitch

	; Close file only if specified by a string path
	If IsString($File) Then FileClose($hFile)

	; Return results
	If $ErrorSav Then Return SetError($ErrorSav, 0, 0)
	Return 1
EndFunc   ;==>_FileWriteFromArray

; #FUNCTION# ====================================================================================================================
; Name...........: _FileWriteLog
; Description ...: Writes current date,time and the specified text to a log file.
; Syntax.........: _FileWriteLog($sLogPath, $sLogMsg[, $iFlag = -1])
; Parameters ....: $sLogPath  - Path and filename of the file to be written to
;                  $sLogMsg   - Message to be written to the log file
;                  $iFlag     - [Optional] - Flag that defines if $sLogMsg will be written to the end of file, or to the begining.
;                  |If $iFlag = -1 (default) $sLogMsg will be written to the end of file.
;                  |If $iFlag &lt;&gt; -1 $sLogMsg will be written to begining of file.
; Return values .: Success - Returns a 1
;                  Failure - Returns a 0
;                  @Error  - 0 = No error.
;                  |1 = Error opening specified file
;                  |2 = File could not be written to
; Author ........: Jeremy Landes <jlandes at landeserve dot com>
; Modified.......: MrCreatoR - added $iFlag parameter
; Remarks .......:
; Related .......: .FileOpen
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _FileWriteLog($sLogPath, $sLogMsg, $iFlag = -1)
	Local $hOpenFile = $sLogPath, $iOpenMode = $FO_APPEND

	Local $sDateNow = @YEAR & "-" & @MON & "-" & @MDAY
	Local $sTimeNow = @HOUR & ":" & @MIN & ":" & @SEC
	Local $sMsg = $sDateNow & " " & $sTimeNow & " : " & $sLogMsg

	If $iFlag <> -1 Then
		$sMsg &= @CRLF & FileRead($sLogPath)
		$iOpenMode = $FO_OVERWRITE
	EndIf

	; Open output file for appending to the end/overwriting, or use input file handle if passed
	If IsString($sLogPath) Then
		$hOpenFile = FileOpen($sLogPath, $iOpenMode)
		If $hOpenFile = -1 Then
			Return SetError(1, 0, 0)
		EndIf
	EndIf

	Local $iReturn = FileWriteLine($hOpenFile, $sMsg)

	; Close file only if specified by a string path
	If IsString($sLogPath) Then
		$iReturn = FileClose($hOpenFile)
	EndIf
	If $iReturn <= 0 Then
		Return SetError(2, $iReturn, 0)
	EndIf
	Return $iReturn
EndFunc   ;==>_FileWriteLog

; #FUNCTION# ====================================================================================================================
; Name...........: _FileWriteToLine
; Description ...: Writes text to a specific line in a file.
; Syntax.........: _FileWriteToLine($sFile, $iLine, $sText[, $fOverWrite = 0])
; Parameters ....: $sFile      - The file to write to
;                  $iLine      - The line number to write to
;                  $sText      - The text to write
;                  $fOverWrite - If set to 1 will overwrite the old line
;                  |If set to 0 will not overwrite
; Return values .: Success - 1
;                  Failure - 0
;                  @Error  - 0 = No error
;                  |1 = File has less lines than $iLine
;                  |2 = File does not exist
;                  |3 = Error when opening file
;                  |4 = $iLine is invalid
;                  |5 = $fOverWrite is invalid
;                  |6 = $sText is invalid
; Author ........: cdkid
; Modified.......: partypooper, MrCreatoR
; Remarks .......: If _FileWriteToLine is called with $fOverWrite as 1 and $sText as "", it will delete the line.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _FileWriteToLine($sFile, $iLine, $sText, $fOverWrite = 0)
	If $iLine <= 0 Then Return SetError(4, 0, 0)
	If Not IsString($sText) Then
		$sText = String($sText)
		If $sText = "" Then Return SetError(6, 0, 0)
	EndIf
	If $fOverWrite <> 0 And $fOverWrite <> 1 Then Return SetError(5, 0, 0)
	If Not FileExists($sFile) Then Return SetError(2, 0, 0)

	Local $sRead_File = FileRead($sFile)
	Local $aSplit_File = StringSplit(StringStripCR($sRead_File), @LF)
	If UBound($aSplit_File) < $iLine Then Return SetError(1, 0, 0)
	Local $iEncoding = FileGetEncoding($sFile)
	Local $hFile = FileOpen($sFile, $iEncoding + $FO_OVERWRITE)
	If $hFile = -1 Then Return SetError(3, 0, 0)

	$sRead_File = ""

	For $i = 1 To $aSplit_File[0]
		If $i = $iLine Then
			If $fOverWrite = 1 Then
				If $sText <> '' Then $sRead_File &= $sText & @CRLF
			Else
				$sRead_File &= $sText & @CRLF & $aSplit_File[$i] & @CRLF
			EndIf
		ElseIf $i < $aSplit_File[0] Then
			$sRead_File &= $aSplit_File[$i] & @CRLF
		ElseIf $i = $aSplit_File[0] Then
			$sRead_File &= $aSplit_File[$i]
		EndIf
	Next

	FileWrite($hFile, $sRead_File)
	FileClose($hFile)

	Return 1
EndFunc   ;==>_FileWriteToLine

; #FUNCTION# ====================================================================================================================
; Name...........: _PathFull
; Description ...: Creates a path based on the relative path you provide. The newly created absolute path is returned
; Syntax.........: _PathFull($sRelativePath [, $sBasePath = @WorkingDir])
; Parameters ....: $sRelativePath - The relative path to be created
;                  $sBasePath - The base path. default = @WorkingDir
; Return values .: Success - Returns the newly created absolute path.
; Author ........: Valik (Original function and modification to rewrite), tittoproject (Rewrite)
; Modified.......:
; Remarks .......:
; Related .......: _PathMake, _PathSplit, .DirCreate, .FileChangeDir
; Link ..........:
; Example .......: Yes
; Notes .........: UNC paths are supported.
;                  Pass "\" to get the root drive of $sBasePath.
;                  Pass "" or "." to return $sBasePath.
;                  A relative path will be built relative to $sBasePath.  To bypass this behavior, use an absolute path.
; ===============================================================================================================================
Func _PathFull($sRelativePath, $sBasePath = @WorkingDir)
	If Not $sRelativePath Or $sRelativePath = "." Then Return $sBasePath

	; Normalize slash direction.
	Local $sFullPath = StringReplace($sRelativePath, "/", "\") ; Holds the full path (later, minus the root)
	Local Const $sFullPathConst = $sFullPath ; Holds a constant version of the full path.
	Local $sPath ; Holds the root drive/server
	Local $bRootOnly = StringLeft($sFullPath, 1) = "\" And StringMid($sFullPath, 2, 1) <> "\"

	; Check for UNC paths or local drives.  We run this twice at most.  The
	; first time, we check if the relative path is absolute.  If it's not, then
	; we use the base path which should be absolute.
	For $i = 1 To 2
		$sPath = StringLeft($sFullPath, 2)
		If $sPath = "\\" Then
			$sFullPath = StringTrimLeft($sFullPath, 2)
			Local $nServerLen = StringInStr($sFullPath, "\") - 1
			$sPath = "\\" & StringLeft($sFullPath, $nServerLen)
			$sFullPath = StringTrimLeft($sFullPath, $nServerLen)
			ExitLoop
		ElseIf StringRight($sPath, 1) = ":" Then
			$sFullPath = StringTrimLeft($sFullPath, 2)
			ExitLoop
		Else
			$sFullPath = $sBasePath & "\" & $sFullPath
		EndIf
	Next

	; If this happens, we've found a funky path and don't know what to do
	; except for get out as fast as possible.  We've also screwed up our
	; variables so we definitely need to quit.
	If $i = 3 Then Return ""

	; A path with a drive but no slash (e.g. C:Path\To\File) has the following
	; behavior.  If the relative drive is the same as the $BasePath drive then
	; insert the base path.  If the drives differ then just insert a leading
	; slash to make the path valid.
	If StringLeft($sFullPath, 1) <> "\" Then
		If StringLeft($sFullPathConst, 2) = StringLeft($sBasePath, 2) Then
			$sFullPath = $sBasePath & "\" & $sFullPath
		Else
			$sFullPath = "\" & $sFullPath
		EndIf
	EndIf

	; Build an array of the path parts we want to use.
	Local $aTemp = StringSplit($sFullPath, "\")
	Local $aPathParts[$aTemp[0]], $j = 0
	For $i = 2 To $aTemp[0]
		If $aTemp[$i] = ".." Then
			If $j Then $j -= 1
		ElseIf Not ($aTemp[$i] = "" And $i <> $aTemp[0]) And $aTemp[$i] <> "." Then
			$aPathParts[$j] = $aTemp[$i]
			$j += 1
		EndIf
	Next

	; Here we re-build the path from the parts above.  We skip the
	; loop if we are only returning the root.
	$sFullPath = $sPath
	If Not $bRootOnly Then
		For $i = 0 To $j - 1
			$sFullPath &= "\" & $aPathParts[$i]
		Next
	Else
		$sFullPath &= $sFullPathConst
		; If we detect more relative parts, remove them by calling ourself recursively.
		If StringInStr($sFullPath, "..") Then $sFullPath = _PathFull($sFullPath)
	EndIf

	; Clean up the path.
	While StringInStr($sFullPath, ".\")
		$sFullPath = StringReplace($sFullPath, ".\", "\")
	WEnd
	Return $sFullPath
EndFunc   ;==>_PathFull

; #FUNCTION# ====================================================================================================================
; Name...........: _PathGetRelative
; Description ...: Returns the relative path to a directory
; Syntax.........: _PathGetRelative($sFrom, $sTo)
; Parameters ....: $sFrom  - Path to the source directory
;                  $sTo    - Path to the destination file or directory
; Return values .: Success - Relative path to the destination.
;                  Failure - Returns the destination and Sets @Error:
;                  |1 - $sFrom equlas $sTo
;                  |2 - Root drives of $sFrom and $sTo are different, a relative path is impossible.
; Author ........: Erik Pilsits
; Modified.......:
; Remarks .......: The returned path will not have a trailing "\", even if it is a root
;                  drive returned after a failure.
; Related .......:
; Link ..........:
; Example .......: Yes
; Notes .........: Original function by Yann Perrin <yann.perrin+clef@gmail.com> and
;                  Lahire Biette <tuxmouraille@gmail.com>, authors of C.A.F.E. Mod.
; ===============================================================================================================================
Func _PathGetRelative($sFrom, $sTo)
	If StringRight($sFrom, 1) <> "\" Then $sFrom &= "\" ; add missing trailing \ to $sFrom path
	If StringRight($sTo, 1) <> "\" Then $sTo &= "\" ; add trailing \ to $sTo
	If $sFrom = $sTo Then Return SetError(1, 0, StringTrimRight($sTo, 1)) ; $sFrom equals $sTo
	Local $asFrom = StringSplit($sFrom, "\")
	Local $asTo = StringSplit($sTo, "\")
	If $asFrom[1] <> $asTo[1] Then Return SetError(2, 0, StringTrimRight($sTo, 1)) ; drives are different, rel path not possible
	; create rel path
	Local $i = 2
	Local $iDiff = 1
	While 1
		If $asFrom[$i] <> $asTo[$i] Then
			$iDiff = $i
			ExitLoop
		EndIf
		$i += 1
	WEnd
	$i = 1
	Local $sRelPath = ""
	For $j = 1 To $asTo[0]
		If $i >= $iDiff Then
			$sRelPath &= "\" & $asTo[$i]
		EndIf
		$i += 1
	Next
	$sRelPath = StringTrimLeft($sRelPath, 1)
	$i = 1
	For $j = 1 To $asFrom[0]
		If $i > $iDiff Then
			$sRelPath = "..\" & $sRelPath
		EndIf
		$i += 1
	Next
	If StringRight($sRelPath, 1) == "\" Then $sRelPath = StringTrimRight($sRelPath, 1) ; remove trailing \
	Return $sRelPath
EndFunc   ;==>_PathGetRelative

; #FUNCTION# ====================================================================================================================
; Name...........: _PathMake
; Description ...: Creates a path from drive, directory, file name and file extension parts. Not all parts must be passed.
; Syntax.........: _PathMake($szDrive, $szDir, $szFName, $szExt)
; Parameters ....: $szDrive - Drive (Can be UNC). If it's a drive letter, a : is automatically appended
;                  $szDir   - Directory. A trailing slash is added if not found (No preceeding slash is added)
;                  $szFName - The name of the file
;                  $szExt   - The file extension. A period is supplied if not found in the extension
; Return values .: Success - Returns the string containing the full path
; Author ........: Valik
; Modified.......:
; Remarks .......: The path will still be built with what is passed. This doesn't check the validity of the path created, it could contain characters which are invalid on your filesystem.
; Related .......: _PathFull, _PathSplit, .DirCreate, .FileChangeDir
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _PathMake($szDrive, $szDir, $szFName, $szExt)
	; Format $szDrive, if it's not a UNC server name, then just get the drive letter and add a colon
	;
	If StringLen($szDrive) Then
		If Not (StringLeft($szDrive, 2) = "\\") Then $szDrive = StringLeft($szDrive, 1) & ":"
	EndIf

	; Format the directory by adding any necessary slashes
	If StringLen($szDir) Then
		If Not (StringRight($szDir, 1) = "\") And Not (StringRight($szDir, 1) = "/") Then $szDir = $szDir & "\"
	EndIf

	; Nothing to be done for the filename

	; Add the period to the extension if necessary
	If StringLen($szExt) Then
		If Not (StringLeft($szExt, 1) = ".") Then $szExt = "." & $szExt
	EndIf

	Return $szDrive & $szDir & $szFName & $szExt
EndFunc   ;==>_PathMake

; #FUNCTION# ====================================================================================================================
; Name...........: _PathSplit
; Description ...: Splits a path into the drive, directory, file name and file extension parts. An empty string is set if a part is missing.
; Syntax.........: _PathSplit($szPath, ByRef $szDrive, ByRef $szDir, ByRef $szFName, ByRef $szExt)
; Parameters ....: $szPath  - The path to be split (Can contain a UNC server or drive letter)
;                  $szDrive - String to hold the drive
;                  $szDir   - String to hold the directory
;                  $szFName - String to hold the file name
;                  $szExt   - String to hold the file extension
; Return values .: Success - Returns an array with 5 elements where 0 = original path, 1 = drive, 2 = directory, 3 = filename, 4 = extension
; Author ........: Valik
; Modified.......:
; Remarks .......: This function does not take a command line string. It works on paths, not paths with arguments.
; Related .......: _PathFull, _PathMake
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _PathSplit($szPath, ByRef $szDrive, ByRef $szDir, ByRef $szFName, ByRef $szExt)
	; Set local strings to null (We use local strings in case one of the arguments is the same variable)
	Local $drive = ""
	Local $dir = ""
	Local $fname = ""
	Local $ext = ""
	Local $pos

	; Create an array which will be filled and returned later
	Local $array[5]
	$array[0] = $szPath; $szPath can get destroyed, so it needs set now

	; Get drive letter if present (Can be a UNC server)
	If StringMid($szPath, 2, 1) = ":" Then
		$drive = StringLeft($szPath, 2)
		$szPath = StringTrimLeft($szPath, 2)
	ElseIf StringLeft($szPath, 2) = "\\" Then
		$szPath = StringTrimLeft($szPath, 2) ; Trim the \\
		$pos = StringInStr($szPath, "\")
		If $pos = 0 Then $pos = StringInStr($szPath, "/")
		If $pos = 0 Then
			$drive = "\\" & $szPath; Prepend the \\ we stripped earlier
			$szPath = ""; Set to null because the whole path was just the UNC server name
		Else
			$drive = "\\" & StringLeft($szPath, $pos - 1) ; Prepend the \\ we stripped earlier
			$szPath = StringTrimLeft($szPath, $pos - 1)
		EndIf
	EndIf

	; Set the directory and file name if present
	Local $nPosForward = StringInStr($szPath, "/", 0, -1)
	Local $nPosBackward = StringInStr($szPath, "\", 0, -1)
	If $nPosForward >= $nPosBackward Then
		$pos = $nPosForward
	Else
		$pos = $nPosBackward
	EndIf
	$dir = StringLeft($szPath, $pos)
	$fname = StringRight($szPath, StringLen($szPath) - $pos)

	; If $szDir wasn't set, then the whole path must just be a file, so set the filename
	If StringLen($dir) = 0 Then $fname = $szPath

	$pos = StringInStr($fname, ".", 0, -1)
	If $pos Then
		$ext = StringRight($fname, StringLen($fname) - ($pos - 1))
		$fname = StringLeft($fname, $pos - 1)
	EndIf

	; Set the strings and array to what we found
	$szDrive = $drive
	$szDir = $dir
	$szFName = $fname
	$szExt = $ext
	$array[1] = $drive
	$array[2] = $dir
	$array[3] = $fname
	$array[4] = $ext
	Return $array
EndFunc   ;==>_PathSplit

; #FUNCTION# ====================================================================================================================
; Name...........: _ReplaceStringInFile
; Description ...: Replaces a string with another string in the given text file (binary won't work!)
; Syntax.........: _ReplaceStringInFile($szFileName, $szSearchString, $szReplaceString[, $fCaseness = 0[, $fOccurance = 1]])
; Parameters ....: $szFileName      - name of the file to open. ATTENTION !! Needs the FULL path, not just the name returned by eg. FileFindNextFile
;                  $szSearchString  - The string we want to replace in the file
;                  $szReplaceString - The string we want as a replacement for $szSearchString
;                  $fCaseness       - 0 = Not Case sensitive (default), 1 = Case sensitive, case does matter
;                  $fOccurance      - 0 = Only first found is replaced, 1 = ALL occurrences are replaced (default)
; Return values .: Success - Returns the number of occurrences of $szSearchString we found
;                  Failure - Returns -1 and sets @error
;                  |@error=1 - Cannot open file
;                  |@error=2 - Cannot open temp file
;                  |@error=3 - Cannot write to temp file
;                  |@error=4 - Cannot delete original file
;                  |@error=5 - Cannot rename/move temp file
;                  |@error=6 - ReadOnly Attribute set.
; Author ........: Kurt (aka /dev/null) and JdeB
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ReplaceStringInFile($szFileName, $szSearchString, $szReplaceString, $fCaseness = 0, $fOccurance = 1)

	Local $iRetVal = 0
	Local $nCount, $sEndsWith
	; Check if file is readonly ..
	If StringInStr(FileGetAttrib($szFileName), "R") Then Return SetError(6, 0, -1)
	;===============================================================================
	;== Read the file into an array
	;===============================================================================
	Local $hFile = FileOpen($szFileName, $FO_READ)
	If $hFile = -1 Then Return SetError(1, 0, -1)
	Local $s_TotFile = FileRead($hFile, FileGetSize($szFileName))
	If StringRight($s_TotFile, 2) = @CRLF Then
		$sEndsWith = @CRLF
	ElseIf StringRight($s_TotFile, 1) = @CR Then
		$sEndsWith = @CR
	ElseIf StringRight($s_TotFile, 1) = @LF Then
		$sEndsWith = @LF
	Else
		$sEndsWith = ""
	EndIf
	Local $aFileLines = StringSplit(StringStripCR($s_TotFile), @LF)
	FileClose($hFile)
	;===============================================================================
	;== Open the output file in write mode
	;===============================================================================
	Local $iEncoding = FileGetEncoding($szFileName)
	Local $hWriteHandle = FileOpen($szFileName, $iEncoding + $FO_OVERWRITE)
	If $hWriteHandle = -1 Then Return SetError(2, 0, -1)
	;===============================================================================
	;== Loop through the array and search for $szSearchString
	;===============================================================================
	For $nCount = 1 To $aFileLines[0]
		If StringInStr($aFileLines[$nCount], $szSearchString, $fCaseness) Then
			$aFileLines[$nCount] = StringReplace($aFileLines[$nCount], $szSearchString, $szReplaceString, 1 - $fOccurance, $fCaseness)
			$iRetVal = $iRetVal + 1

			;======================================================================
			;== If we want just the first string replaced, copy the rest of the lines
			;== and stop
			;======================================================================
			If $fOccurance = 0 Then
				$iRetVal = 1
				ExitLoop
			EndIf
		EndIf
	Next
	;===============================================================================
	;== Write the lines back to original file.
	;===============================================================================
	For $nCount = 1 To $aFileLines[0] - 1
		If FileWriteLine($hWriteHandle, $aFileLines[$nCount]) = 0 Then
			FileClose($hWriteHandle)
			Return SetError(3, 0, -1)
		EndIf
	Next
	; Write the last record and ensure it ends with the same as the input file
	If $aFileLines[$nCount] <> "" Then FileWrite($hWriteHandle, $aFileLines[$nCount] & $sEndsWith)
	FileClose($hWriteHandle)

	Return $iRetVal
EndFunc   ;==>_ReplaceStringInFile

; #FUNCTION# ====================================================================================================================
; Name...........: _TempFile
; Description ...: Generate a name for a temporary file. The file is guaranteed not to exist yet.
; Syntax.........: _TempFile([$s_DirectoryName = @TempDir[, $s_FilePrefix = "~"[, $s_FileExtension = ".tmp"[, $i_RandomLength = 7]]]])
; Parameters ....: $s_DirectoryName - Optional: Name of directory for filename, defaults to the users %TEMP% directory
;                  $s_FilePrefix    - Optional: File prefixname, defaults to "~"
;                  $s_FileExtension - Optional: File extenstion, defaults to ".tmp"
;                  $i_RandomLength  - Optional: Number of characters to use to generate a unique name, defaults to 7
; Return values .: Success - Filename of a temporary file which does not exist
; Author ........: Dale (Klaatu) Thompson
; Modified.......: Hans Harder - Added Optional parameters
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _TempFile($s_DirectoryName = @TempDir, $s_FilePrefix = "~", $s_FileExtension = ".tmp", $i_RandomLength = 7)
	; Check parameters
	If IsKeyword($s_FilePrefix) Then $s_FilePrefix = "~"
	If IsKeyword($s_FileExtension) Then $s_FileExtension = ".tmp"
	If IsKeyword($i_RandomLength) Then $i_RandomLength = 7
	If Not FileExists($s_DirectoryName) Then $s_DirectoryName = @TempDir ; First reset to default temp dir
	If Not FileExists($s_DirectoryName) Then $s_DirectoryName = @ScriptDir ; Still wrong then set to Scriptdir
	; add trailing \ for directory name
	If StringRight($s_DirectoryName, 1) <> "\" Then $s_DirectoryName = $s_DirectoryName & "\"
	;
	Local $s_TempName
	Do
		$s_TempName = ""
		While StringLen($s_TempName) < $i_RandomLength
			$s_TempName = $s_TempName & Chr(Random(97, 122, 1))
		WEnd
		$s_TempName = $s_DirectoryName & $s_FilePrefix & $s_TempName & $s_FileExtension
	Until Not FileExists($s_TempName)

	Return $s_TempName
EndFunc   ;==>_TempFile
