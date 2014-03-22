#include-once

#include "Memory.au3"

; #INDEX# =======================================================================================================================
; Title .........: Clipboard
; AutoIt Version : 3.3.7.20++
; Language ......: English
; Description ...: Functions that assist with Clipboard management.
;                  The clipboard is a set of functions and messages that enable applications to transfer data.
;                  Because  all applications have access to the clipboard, data can be easily transferred
;                  between applications  or  within  an application.
; Author(s) .....: Paul Campbell (PaulIA)
; Dll(s) ........: user32.dll
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $CF_TEXT = 1 ; Text format
Global Const $CF_BITMAP = 2 ; Handle to a bitmap (HBITMAP)
Global Const $CF_METAFILEPICT = 3 ; Handle to a metafile picture (METAFILEPICT)
Global Const $CF_SYLK = 4 ; Microsoft Symbolic Link (SYLK) format
Global Const $CF_DIF = 5 ; Software Arts' Data Interchange Format
Global Const $CF_TIFF = 6 ; Tagged image file format
Global Const $CF_OEMTEXT = 7 ; Text format containing characters in the OEM character set
Global Const $CF_DIB = 8 ; BITMAPINFO structure followed by the bitmap bits
Global Const $CF_PALETTE = 9 ; Handle to a color palette
Global Const $CF_PENDATA = 10 ; Data for the pen extensions to Pen Computing
Global Const $CF_RIFF = 11 ; Represents audio data in RIFF format
Global Const $CF_WAVE = 12 ; Represents audio data in WAVE format
Global Const $CF_UNICODETEXT = 13 ; Unicode text format
Global Const $CF_ENHMETAFILE = 14 ; Handle to an enhanced metafile (HENHMETAFILE)
Global Const $CF_HDROP = 15 ; Handle to type HDROP that identifies a list of files
Global Const $CF_LOCALE = 16 ; Handle to the locale identifier associated with text in the clipboard
Global Const $CF_DIBV5 = 17 ; BITMAPV5HEADER structure followed by bitmap color and the bitmap bits
Global Const $CF_OWNERDISPLAY = 0x0080 ; Owner display format
Global Const $CF_DSPTEXT = 0x0081 ; Text display format associated with a private format
Global Const $CF_DSPBITMAP = 0x0082 ; Bitmap display format associated with a private format
Global Const $CF_DSPMETAFILEPICT = 0x0083 ; Metafile picture display format associated with a private format
Global Const $CF_DSPENHMETAFILE = 0x008E ; Enhanced metafile display format associated with a private format
Global Const $CF_PRIVATEFIRST = 0x0200 ; Range of integer values for private clipboard formats
Global Const $CF_PRIVATELAST = 0x02FF ; Range of integer values for private clipboard formats
Global Const $CF_GDIOBJFIRST = 0x0300 ; Range for (GDI) object clipboard formats
Global Const $CF_GDIOBJLAST = 0x03FF ; Range for (GDI) object clipboard formats
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_ClipBoard_ChangeChain
;_ClipBoard_Close
;_ClipBoard_CountFormats
;_ClipBoard_Empty
;_ClipBoard_EnumFormats
;_ClipBoard_FormatStr
;_ClipBoard_GetData
;_ClipBoard_GetDataEx
;_ClipBoard_GetFormatName
;_ClipBoard_GetOpenWindow
;_ClipBoard_GetOwner
;_ClipBoard_GetPriorityFormat
;_ClipBoard_GetSequenceNumber
;_ClipBoard_GetViewer
;_ClipBoard_IsFormatAvailable
;_ClipBoard_Open
;_ClipBoard_RegisterFormat
;_ClipBoard_SetData
;_ClipBoard_SetDataEx
;_ClipBoard_SetViewer
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _ClipBoard_ChangeChain
; Description ...: Removes a specified window from the chain of clipboard viewers
; Syntax.........: _ClipBoard_ChangeChain($hRemove, $hNewNext)
; Parameters ....: $hRemove     - Handle to the window to be removed from the chain.
;                  |The handle must have been passed to the _ClipBoard_SetClipboardViewer function.
;                  $hNewNext    - Handle to the window that follows the $hRemove window in the clipboard viewer chain.
;                  |This is the handle returned by _ClipBoard_SetViewer, unless the sequence was changed in response to a $WM_CHANGECBCHAIN message.
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The window identified by $hNewNext replaces the $hRemove window  in  the  chain.  The _ClipBoard_SetViewer function
;                  sends a $WM_CHANGECBCHAIN message to the first window in the clipboard viewer chain.
; Related .......: _ClipBoard_SetViewer
; Link ..........: @@MsdnLink@@ ChangeClipboardChain
; Example .......: Yes
; ===============================================================================================================================
Func _ClipBoard_ChangeChain($hRemove, $hNewNext)
	DllCall("user32.dll", "bool", "ChangeClipboardChain", "hwnd", $hRemove, "hwnd", $hNewNext)
	If @error Then Return SetError(@error, @extended)
EndFunc   ;==>_ClipBoard_ChangeChain

; #FUNCTION# ====================================================================================================================
; Name...........: _ClipBoard_Close
; Description ...: Closes the clipboard
; Syntax.........: _ClipBoard_Close()
; Parameters ....:
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: When the window has finished examining or changing the clipboard close the clipboard by calling this function.
;                  This enables other windows to access the clipboard.  Do not place an object on the clipboard after calling
;                  this function.
; Related .......: _ClipBoard_Open
; Link ..........: @@MsdnLink@@ CloseClipboard
; Example .......: Yes
; ===============================================================================================================================
Func _ClipBoard_Close()
	Local $aResult = DllCall("user32.dll", "bool", "CloseClipboard")
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_ClipBoard_Close

; #FUNCTION# ====================================================================================================================
; Name...........: _ClipBoard_CountFormats
; Description ...: Retrieves the number of different data formats currently on the clipboard
; Syntax.........: _ClipBoard_CountFormats()
; Parameters ....:
; Return values .: Success      - The number of different data formats currently on the clipboard
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _ClipBoard_EnumFormats, _ClipBoard_GetPriorityFormat
; Link ..........: @@MsdnLink@@ CountClipboardFormats
; Example .......: Yes
; ===============================================================================================================================
Func _ClipBoard_CountFormats()
	Local $aResult = DllCall("user32.dll", "int", "CountClipboardFormats")
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_ClipBoard_CountFormats

; #FUNCTION# ====================================================================================================================
; Name...........: _ClipBoard_Empty
; Description ...: Empties the clipboard and frees handles to data in the clipboard
; Syntax.........: _ClipBoard_Empty()
; Parameters ....:
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Before calling this function, you must open the clipboard by using the _ClipBoard_Open function.  If you specified
;                  a NULL window handle when opening the clipboard, this function succeeds but sets the clipboard owner to NULL.
;                  Note that this causes _ClipBoard_SetData to fail.
; Related .......: _ClipBoard_Open, _ClipBoard_SetData, _ClipBoard_GetOwner, _ClipBoard_SetDataEx
; Link ..........: @@MsdnLink@@ EmptyClipboard
; Example .......: Yes
; ===============================================================================================================================
Func _ClipBoard_Empty()
	Local $aResult = DllCall("user32.dll", "bool", "EmptyClipboard")
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_ClipBoard_Empty

; #FUNCTION# ====================================================================================================================
; Name...........: _ClipBoard_EnumFormats
; Description ...: Enumerates the data formats currently available on the clipboard
; Syntax.........: _ClipBoard_EnumFormats($iFormat)
; Parameters ....: $iFormat     - Specifies a clipboard format that is known to be available. To start an enumeration of formats,
;                  +set $iFormat to zero. When $iFormat is zero, the function retrieves the first available clipboard format. For
;                  +subsequent calls during an enumeration, set $iFormat to the result of the previous call.
; Return values .: Success      - The clipboard format that follows the specified format
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: You must open the clipboard before enumerating its formats
; Related .......: _ClipBoard_Open, _ClipBoard_CountFormats, _ClipBoard_GetPriorityFormat, _ClipBoard_RegisterFormat
; Link ..........: @@MsdnLink@@ EnumClipboardFormats
; Example .......: Yes
; ===============================================================================================================================
Func _ClipBoard_EnumFormats($iFormat)
	Local $aResult = DllCall("user32.dll", "uint", "EnumClipboardFormats", "uint", $iFormat)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_ClipBoard_EnumFormats

; #FUNCTION# ====================================================================================================================
; Name...........: _ClipBoard_FormatStr
; Description ...: Returns a string representation of a standard clipboard format
; Syntax.........: _ClipBoard_FormatStr($iFormat)
; Parameters ....: $iFormat     - Specifies a clipboard format
; Return values .: Success      - String representation of the clipboard format
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ClipBoard_FormatStr($iFormat)
	Local $aFormat[18] = [17, "Text", "Bitmap", "Metafile Picture", "SYLK", "DIF", "TIFF", "OEM Text", "DIB", "Palette", _
			"Pen Data", "RIFF", "WAVE", "Unicode Text", "Enhanced Metafile", "HDROP", "Locale", "DIB V5"]

	If $iFormat >= 1 And $iFormat <= 17 Then Return $aFormat[$iFormat]

	Switch $iFormat
		Case $CF_OWNERDISPLAY
			Return "Owner Display"
		Case $CF_DSPTEXT
			Return "Private Text"
		Case $CF_DSPBITMAP
			Return "Private Bitmap"
		Case $CF_DSPMETAFILEPICT
			Return "Private Metafile Picture"
		Case $CF_DSPENHMETAFILE
			Return "Private Enhanced Metafile"
		Case Else
			Return _ClipBoard_GetFormatName($iFormat)
	EndSwitch
EndFunc   ;==>_ClipBoard_FormatStr

; #FUNCTION# ====================================================================================================================
; Name...........: _ClipBoard_GetData
; Description ...: Retrieves data from the clipboard in a specified format
; Syntax.........: _ClipBoard_GetData([$iFormat = 1])
; Parameters ....: $iFormat     - Specifies a clipboard format:
;                  |$CF_TEXT            - Text format
;                  |$CF_BITMAP          - Handle to a bitmap (HBITMAP)
;                  |$CF_METAFILEPICT    - Handle to a metafile picture (METAFILEPICT)
;                  |$CF_SYLK            - Microsoft Symbolic Link (SYLK) format
;                  |$CF_DIF             - Software Arts' Data Interchange Format
;                  |$CF_TIFF            - Tagged image file format
;                  |$CF_OEMTEXT         - Text format containing characters in the OEM character set
;                  |$CF_DIB             - BITMAPINFO structure followed by the bitmap bits
;                  |$CF_PALETTE         - Handle to a color palette
;                  |$CF_PENDATA         - Data for the pen extensions to Pen Computing
;                  |$CF_RIFF            - Represents audio data in RIFF format
;                  |$CF_WAVE            - Represents audio data in WAVE format
;                  |$CF_UNICODETEXT     - Unicode text format
;                  |$CF_ENHMETAFILE     - Handle to an enhanced metafile (HENHMETAFILE)
;                  |$CF_HDROP           - Handle to type HDROP that identifies a list of files
;                  |$CF_LOCALE          - Handle to the locale identifier associated with text in the clipboard
;                  |$CF_DIBV5           - BITMAPV5HEADER structure followed by bitmap color and the bitmap bits
;                  |$CF_OWNERDISPLAY    - Owner display format
;                  |$CF_DSPTEXT         - Text display format associated with a private format
;                  |$CF_DSPBITMAP       - Bitmap display format associated with a private format
;                  |$CF_DSPMETAFILEPICT - Metafile picture display format associated with a private format
;                  |$CF_DSPENHMETAFILE  - Enhanced metafile display format associated with a private format
; Return values .: Success      - Text for text based formats or Binary data for all other formats
;                               -  @extended is set to the # of characters for Text, or # of bytes for Binary
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost,
;                  Ascend4nt (now follows traditional ClipBoard 'get' code, fixed $CF_UNICODETEXT errors)
; Remarks .......: This function performs all of the steps neccesary to get data from the clipboard. It checks to see if
;                  the data format is available, opens the clipboard, closes the clipboard and returns the data in one of
;                  two formats: String format for datatypes $CF_TEXT, $CF_OEMTEXT, or $CF_UNICODETEXT,
;                  or Binary format for every other type. If you need a finer degree of control over retrieving data from
;                  the clipboard, you may want to use the _ClipBoard_GetDataEx function.
; Related .......: _ClipBoard_GetDataEx, _ClipBoard_SetData
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _ClipBoard_GetData($iFormat = 1)
	If Not _ClipBoard_IsFormatAvailable($iFormat) Then Return SetError(-1, 0, 0)
	If Not _ClipBoard_Open(0) Then Return SetError(-2, 0, 0)
	Local $hMemory = _ClipBoard_GetDataEx($iFormat)

	;_ClipBoard_Close()		; moved to end: traditionally done *after* copying over the memory

	If $hMemory = 0 Then
		_ClipBoard_Close()
		Return SetError(-3, 0, 0)
	EndIf

	Local $pMemoryBlock = _MemGlobalLock($hMemory)

	If $pMemoryBlock = 0 Then
		_ClipBoard_Close()
		Return SetError(-4, 0, 0)
	EndIf

	; Get the actual memory size of the ClipBoard memory object (in bytes)
	Local $iDataSize = _MemGlobalSize($hMemory)

	If $iDataSize = 0 Then
		_MemGlobalUnlock($hMemory)
		_ClipBoard_Close()
		Return SetError(-5, 0, "")
	EndIf

	Local $tData
	Switch $iFormat
		Case $CF_TEXT, $CF_OEMTEXT
			$tData = DllStructCreate("char[" & $iDataSize & "]", $pMemoryBlock)
		Case $CF_UNICODETEXT
			; Round() shouldn't be necessary, as CF_UNICODETEXT should be 2-bytes wide & thus evenly-divisible
			$iDataSize = Round($iDataSize / 2)
			$tData = DllStructCreate("wchar[" & $iDataSize & "]", $pMemoryBlock)
		Case Else
			; Binary data return for all other formats
			$tData = DllStructCreate("byte[" & $iDataSize & "]", $pMemoryBlock)
	EndSwitch
	; Grab the data from the Structure so the Memory can be unlocked
	Local $vReturn = DllStructGetData($tData, 1)

	; Unlock the memory & Close the clipboard now that we have grabbed what we needed
	_MemGlobalUnlock($hMemory)
	_ClipBoard_Close()

	; Return the size of the string or binary object in @extended
	Return SetExtended($iDataSize, $vReturn)
EndFunc   ;==>_ClipBoard_GetData

; #FUNCTION# ====================================================================================================================
; Name...........: _ClipBoard_GetDataEx
; Description ...: Retrieves data from the clipboard in a specified format
; Syntax.........: _ClipBoard_GetDataEx([$iFormat = 1])
; Parameters ....: $iFormat     - Specifies a clipboard format:
;                  |$CF_TEXT            - Text format
;                  |$CF_BITMAP          - Handle to a bitmap (HBITMAP)
;                  |$CF_METAFILEPICT    - Handle to a metafile picture (METAFILEPICT)
;                  |$CF_SYLK            - Microsoft Symbolic Link (SYLK) format
;                  |$CF_DIF             - Software Arts' Data Interchange Format
;                  |$CF_TIFF            - Tagged image file format
;                  |$CF_OEMTEXT         - Text format containing characters in the OEM character set
;                  |$CF_DIB             - BITMAPINFO structure followed by the bitmap bits
;                  |$CF_PALETTE         - Handle to a color palette
;                  |$CF_PENDATA         - Data for the pen extensions to Pen Computing
;                  |$CF_RIFF            - Represents audio data in RIFF format
;                  |$CF_WAVE            - Represents audio data in WAVE format
;                  |$CF_UNICODETEXT     - Unicode text format
;                  |$CF_ENHMETAFILE     - Handle to an enhanced metafile (HENHMETAFILE)
;                  |$CF_HDROP           - Handle to type HDROP that identifies a list of files
;                  |$CF_LOCALE          - Handle to the locale identifier associated with text in the clipboard
;                  |$CF_DIBV5           - BITMAPV5HEADER structure followed by bitmap color and the bitmap bits
;                  |$CF_OWNERDISPLAY    - Owner display format
;                  |$CF_DSPTEXT         - Text display format associated with a private format
;                  |$CF_DSPBITMAP       - Bitmap display format associated with a private format
;                  |$CF_DSPMETAFILEPICT - Metafile picture display format associated with a private format
;                  |$CF_DSPENHMETAFILE  - Enhanced metafile display format associated with a private format
; Return values .: Success      - Handle to a clipboard object in the specified format
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The clipboard controls the handle that the _ClipBoard_GetData function returns, not the application.  You should
;                  copy the data immediately.  The application must not free the handle nor leave it locked. The application must
;                  not use the handle after the _ClipBoard_Empty or  _ClipBoard_Close function is called, or after the _ClipBoard_SetData
;                  function is called with the same clipboard format.
; Related .......: _ClipBoard_SetData, _ClipBoard_GetData
; Link ..........: @@MsdnLink@@ GetClipboardData
; Example .......: Yes
; ===============================================================================================================================
Func _ClipBoard_GetDataEx($iFormat = 1)
	Local $aResult = DllCall("user32.dll", "handle", "GetClipboardData", "uint", $iFormat)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_ClipBoard_GetDataEx

; #FUNCTION# ====================================================================================================================
; Name...........: _ClipBoard_GetFormatName
; Description ...: Retrieves the name of the specified registered format
; Syntax.........: _ClipBoard_GetFormatName($iFormat)
; Parameters ....: $iFormat     - Specifies the type of format to be retrieved
; Return values .: Success      - Format name
;                  Failure      - Blank string
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Ascend4nt
; Remarks .......: The $iFormat parameter must not specify any of the predefined clipboard formats
; Related .......:
; Link ..........: @@MsdnLink@@ GetClipboardFormatName
; Example .......: Yes
; ===============================================================================================================================
Func _ClipBoard_GetFormatName($iFormat)
	Local $aResult = DllCall("user32.dll", "int", "GetClipboardFormatNameW", "uint", $iFormat, "wstr", "", "int", 4096)
	If @error Then Return SetError(@error, @extended, "")
	Return $aResult[2]
EndFunc   ;==>_ClipBoard_GetFormatName

; #FUNCTION# ====================================================================================================================
; Name...........: _ClipBoard_GetOpenWindow
; Description ...: Retrieves the handle to the window that currently has the clipboard open
; Syntax.........: _ClipBoard_GetOpenWindow()
; Parameters ....:
; Return values .: Success      - The handle to the window that has the clipboard open
;                  Failure      - Zero if no window has the clipboard open
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: If an application or DLL specifies a NULL window handle when calling the _ClipBoard_Open function, the clipboard
;                  is opened but is not associated with a window.  In such a case, _ClipBoard_GetOpenWindow returns 0.
; Related .......: _ClipBoard_GetOwner, _ClipBoard_Open
; Link ..........: @@MsdnLink@@ GetOpenClipboardWindow
; Example .......: Yes
; ===============================================================================================================================
Func _ClipBoard_GetOpenWindow()
	Local $aResult = DllCall("user32.dll", "hwnd", "GetOpenClipboardWindow")
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_ClipBoard_GetOpenWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _ClipBoard_GetOwner
; Description ...: Retrieves the window handle of the current owner of the clipboard
; Syntax.........: _ClipBoard_GetOwner()
; Parameters ....:
; Return values .: Success      - The handle to the window that owns the clipboard
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The clipboard can still contain data even if the clipboard is not currently owned.  In general, the clipboard
;                  owner is the window that last placed data in clipboard. The _ClipBoard_Empty function assigns clipboard ownership.
; Related .......: _ClipBoard_Empty, _ClipBoard_GetOpenWindow
; Link ..........: @@MsdnLink@@ GetClipboardOwner
; Example .......: Yes
; ===============================================================================================================================
Func _ClipBoard_GetOwner()
	Local $aResult = DllCall("user32.dll", "hwnd", "GetClipboardOwner")
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_ClipBoard_GetOwner

; #FUNCTION# ====================================================================================================================
; Name...........: _ClipBoard_GetPriorityFormat
; Description ...: Retrieves the first available clipboard format in the specified list
; Syntax.........: _ClipBoard_GetPriorityFormat($aFormats)
; Parameters ....: $aFormats    - Array with the following format:
;                  |[0] - Number of formats (n)
;                  |[1] - Format 1
;                  |[2] - Format 2
;                  |[n] - Format n
; Return values .: Success      - The first clipboard format in the list for which data is available
;                  Failure      - Format not found due to:
;                  |-1 - Clipboard has data, but not in any of the formats requested
;                  | 0 - Clipboard is empty
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _ClipBoard_CountFormats, _ClipBoard_EnumFormats
; Link ..........: @@MsdnLink@@ GetPriorityClipboardFormat
; Example .......: Yes
; ===============================================================================================================================
Func _ClipBoard_GetPriorityFormat($aFormats)
	If Not IsArray($aFormats) Then Return SetError(-1, 0, 0)
	If $aFormats[0] <= 0 Then Return SetError(-2, 0, 0)

	Local $tData = DllStructCreate("uint[" & $aFormats[0] & "]")
	For $iI = 1 To $aFormats[0]
		DllStructSetData($tData, 1, $aFormats[$iI], $iI)
	Next

	Local $aResult = DllCall("user32.dll", "int", "GetPriorityClipboardFormat", "struct*", $tData, "int", $aFormats[0])
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_ClipBoard_GetPriorityFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _ClipBoard_GetSequenceNumber
; Description ...: Retrieves the clipboard sequence number for the current window station
; Syntax.........: _ClipBoard_GetSequenceNumber()
; Parameters ....:
; Return values .: Success      - The clipboard sequence number
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The system keeps a serial number for the clipboard for each window station.  This number is incremented when
;                  the contents of the clipboard change or the clipboard is emptied. You can track this value to determine if the
;                  clipboard contents have changed and optimize creating data objects.  If clipboard rendering is delayed, the
;                  sequence number is not incremented until the changes are rendered.
; Related .......:
; Link ..........: @@MsdnLink@@ GetClipboardSequenceNumber
; Example .......: Yes
; ===============================================================================================================================
Func _ClipBoard_GetSequenceNumber()
	Local $aResult = DllCall("user32.dll", "dword", "GetClipboardSequenceNumber")
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_ClipBoard_GetSequenceNumber

; #FUNCTION# ====================================================================================================================
; Name...........: _ClipBoard_GetViewer
; Description ...: Retrieves the handle to the first window in the clipboard viewer chain
; Syntax.........: _ClipBoard_GetViewer()
; Parameters ....:
; Return values .: Success      - The handle to the first window in the clipboard viewer chain
;                  Failure      - Zero if there is no clipboard viewer
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _ClipBoard_SetViewer
; Link ..........: @@MsdnLink@@ GetClipboardViewer
; Example .......: Yes
; ===============================================================================================================================
Func _ClipBoard_GetViewer()
	Local $aResult = DllCall("user32.dll", "hwnd", "GetClipboardViewer")
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_ClipBoard_GetViewer

; #FUNCTION# ====================================================================================================================
; Name...........: _ClipBoard_IsFormatAvailable
; Description ...: Determines whether the clipboard contains data in the specified format
; Syntax.........: _ClipBoard_IsFormatAvailable($iFormat)
; Parameters ....: $iFormat     - Specifies a standard or registered clipboard format
; Return values .: True         - Clipboard contains data in the specified format
;                  False        - Clipboard does not contain data in the specified format
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ IsClipboardFormatAvailable
; Example .......: Yes
; ===============================================================================================================================
Func _ClipBoard_IsFormatAvailable($iFormat)
	Local $aResult = DllCall("user32.dll", "bool", "IsClipboardFormatAvailable", "uint", $iFormat)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_ClipBoard_IsFormatAvailable

; #FUNCTION# ====================================================================================================================
; Name...........: _ClipBoard_Open
; Description ...: Opens the clipboard and prevents other applications from modifying the clipboard
; Syntax.........: _ClipBoard_Open($hOwner)
; Parameters ....: $hOwner      - Handle to the window to be associated with the open clipboard. If this parameter is 0, the open
;                  +clipboard is associated with the current task.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function fails if another window has the clipboard  open.  Call the _ClipBoard_Close function after every
;                  successful call to this function. The window identified by the $hOwner parameter does not become the clipboard
;                  owner unless the _ClipBoard_Empty function is called.  If you call _ClipBoard_Open with hwnd set to 0, _ClipBoard_Empty sets
;                  the clipboard owner to0 which causes _ClipBoard_SetData to fail.
; Related .......: _ClipBoard_Close, _ClipBoard_Empty, _ClipBoard_EnumFormats, _ClipBoard_GetOpenWindow, _ClipBoard_SetDataEx
; Link ..........: @@MsdnLink@@ OpenClipboard
; Example .......: Yes
; ===============================================================================================================================
Func _ClipBoard_Open($hOwner)
	Local $aResult = DllCall("user32.dll", "bool", "OpenClipboard", "hwnd", $hOwner)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_ClipBoard_Open

; #FUNCTION# ====================================================================================================================
; Name...........: _ClipBoard_RegisterFormat
; Description ...: Registers a new clipboard format
; Syntax.........: _ClipBoard_RegisterFormat($sFormat)
; Parameters ....: $sFormat     - The name of the new format
; Return values .: Success      - The registered clipboard format
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: If a registered format with the specified name already exists, a new format is not registered and the return
;                  value identifies the existing format.  This enables more than one application to copy and paste data using the
;                  same registered clipboard format. Note that the format name comparison is case-insensitive.
; Related .......: _ClipBoard_EnumFormats
; Link ..........: @@MsdnLink@@ RegisterClipboardFormat
; Example .......: Yes
; ===============================================================================================================================
Func _ClipBoard_RegisterFormat($sFormat)
	Local $aResult = DllCall("user32.dll", "uint", "RegisterClipboardFormatW", "wstr", $sFormat)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_ClipBoard_RegisterFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _ClipBoard_SetData
; Description ...: Places data on the clipboard in a specified clipboard format
; Syntax.........: _ClipBoard_SetData($vData[, $iFormat = 1])
; Parameters ....: $vData     - Data in Binary or String format, or optionally NULL (0) (owner must render, see below).
;                  +IMPORTANT: If a String is passed, and it is not of type $CF_TEXT, $CF_OEMTEXT, or $CF_UNICODETEXT,
;                  + it will be treated as an ANSI string. To force Unicode strings for other types, you must pass the data
;                  + in Binary format. Also, do NOT pass $CF_UNICODETEXT in Binary format (causes garbled data).
;                  +When $vData is NULL, it indicates that the window provides data in the specified clipboard format upon request.
;                  +If a window delays rendering, it must process the $WM_RENDERFORMAT and $WM_RENDERALLFORMATS messages.  If this
;                  +function succeeds, the system owns the object identified by the $hMemory parameter.  The application may not
;                  +write to or free the data once ownership has been transferred to the system, but it can lock and read from the
;                  +data until the _ClipBoard_Close function is called.  The memory must be unlocked before the clipboard is
;                  +closed.  If the $hMemory parameter identifies a memory object, the object must have been allocated using the
;                  +function with the $GMEM_MOVEABLE
;                  +flag.
;                  $iFormat     - Specifies a clipboard format:
;                  |$CF_TEXT            - Text format
;                  |$CF_BITMAP          - Handle to a bitmap (HBITMAP)
;                  |$CF_METAFILEPICT    - Handle to a metafile picture (METAFILEPICT)
;                  |$CF_SYLK            - Microsoft Symbolic Link (SYLK) format
;                  |$CF_DIF             - Software Arts' Data Interchange Format
;                  |$CF_TIFF            - Tagged image file format
;                  |$CF_OEMTEXT         - Text format containing characters in the OEM character set
;                  |$CF_DIB             - BITMAPINFO structure followed by the bitmap bits
;                  |$CF_PALETTE         - Handle to a color palette
;                  |$CF_PENDATA         - Data for the pen extensions to Pen Computing
;                  |$CF_RIFF            - Represents audio data in RIFF format
;                  |$CF_WAVE            - Represents audio data in WAVE format
;                  |$CF_UNICODETEXT     - Unicode text format
;                  |$CF_ENHMETAFILE     - Handle to an enhanced metafile (HENHMETAFILE)
;                  |$CF_HDROP           - Handle to type HDROP that identifies a list of files
;                  |$CF_LOCALE          - Handle to the locale identifier associated with text in the clipboard
;                  |$CF_DIBV5           - BITMAPV5HEADER structure followed by bitmap color and the bitmap bits
;                  |$CF_OWNERDISPLAY    - Owner display format
;                  |$CF_DSPTEXT         - Text display format associated with a private format
;                  |$CF_DSPBITMAP       - Bitmap display format associated with a private format
;                  |$CF_DSPMETAFILEPICT - Metafile picture display format associated with a private format
;                  |$CF_DSPENHMETAFILE  - Enhanced metafile display format associated with a private format
; Return values .: Success      - The handle to the data
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Ascend4nt
; Remarks .......: This function performs all of the steps neccesary to put data on the clipboard.  It will allocate the global
;                  memory object, open the clipboard, place the data on the clipboard and close the clipboard.  If you need more
;                  control over putting data on the clipboard, you may want to use the _ClipBoard_SetDataEx function.
; Related .......: _ClipBoard_GetData, _ClipBoard_SetDataEx, _ClipBoard_Empty, _ClipBoard_GetDataEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ClipBoard_SetData($vData, $iFormat = 1)
	Local $tData, $hLock, $hMemory, $iSize

	; Special NULL case? (the option to provide clipboard formats upon request)
	If IsNumber($vData) And $vData = 0 Then
		; No need to allocate/set memory
		$hMemory = $vData
	Else
		; Test if the format is Binary or String format (only supported formats)
		If IsBinary($vData) Then
			$iSize = BinaryLen($vData)
		ElseIf IsString($vData) Then
			$iSize = StringLen($vData)
		Else
			; Unsupported data type
			Return SetError(2, 0, 0)
		EndIf
		$iSize += 1

		; Memory allocation is in bytes, yet Unicode text is 2-bytes wide
		If $iFormat = $CF_UNICODETEXT Then
			; Multiply $iSize (Character length for Unicode text) by 2 for Unicode
			$hMemory = _MemGlobalAlloc($iSize * 2, $GHND)
		Else
			$hMemory = _MemGlobalAlloc($iSize, $GHND)
		EndIf

		If $hMemory = 0 Then Return SetError(-1, 0, 0)
		$hLock = _MemGlobalLock($hMemory)
		If $hLock = 0 Then Return SetError(-2, 0, 0)

		Switch $iFormat
			Case $CF_TEXT, $CF_OEMTEXT
				$tData = DllStructCreate("char[" & $iSize & "]", $hLock)
			Case $CF_UNICODETEXT
				$tData = DllStructCreate("wchar[" & $iSize & "]", $hLock)
			Case Else
				; Every other type is treated as Binary, or ASCII Strings
				$tData = DllStructCreate("byte[" & $iSize & "]", $hLock)
		EndSwitch

		DllStructSetData($tData, 1, $vData)
		_MemGlobalUnlock($hMemory)
	EndIf

	If Not _ClipBoard_Open(0) Then Return SetError(-5, 0, 0)
	If Not _ClipBoard_Empty() Then Return SetError(-6, 0, 0)
	If Not _ClipBoard_SetDataEx($hMemory, $iFormat) Then
		_ClipBoard_Close()
		Return SetError(-7, 0, 0)
	EndIf

	_ClipBoard_Close()
	Return $hMemory
EndFunc   ;==>_ClipBoard_SetData

; #FUNCTION# ====================================================================================================================
; Name...........: _ClipBoard_SetDataEx
; Description ...: Places data on the clipboard in a specified clipboard format
; Syntax.........: _ClipBoard_SetDataEx(ByRef $hMemory[, $iFormat = 1])
; Parameters ....: $hMemory     - Handle to the data in the specified format.  This parameter can be NULL, indicating that the
;                  +window provides data in the specified clipboard format upon request.  If a window delays rendering, it must
;                  +process the $WM_RENDERFORMAT and $WM_RENDERALLFORMATS messages.  If this function succeeds, the system owns
;                  +the object identified by the $hMemory parameter.  The application may not write to or free the data once
;                  +ownership has been transferred to the system, but it can lock and read from the data until the _ClipBoard_Close
;                  +function is called.  The memory must be unlocked before the clipboard is closed.  If the $hMemory parameter
;                  +identifies a memory object, the object must have been allocated using the function with the $GMEM_MOVEABLE
;                  +flag.
;                  $iFormat     - Specifies a clipboard format:
;                  |$CF_TEXT            - Text format
;                  |$CF_BITMAP          - Handle to a bitmap (HBITMAP)
;                  |$CF_METAFILEPICT    - Handle to a metafile picture (METAFILEPICT)
;                  |$CF_SYLK            - Microsoft Symbolic Link (SYLK) format
;                  |$CF_DIF             - Software Arts' Data Interchange Format
;                  |$CF_TIFF            - Tagged image file format
;                  |$CF_OEMTEXT         - Text format containing characters in the OEM character set
;                  |$CF_DIB             - BITMAPINFO structure followed by the bitmap bits
;                  |$CF_PALETTE         - Handle to a color palette
;                  |$CF_PENDATA         - Data for the pen extensions to Pen Computing
;                  |$CF_RIFF            - Represents audio data in RIFF format
;                  |$CF_WAVE            - Represents audio data in WAVE format
;                  |$CF_UNICODETEXT     - Unicode text format
;                  |$CF_ENHMETAFILE     - Handle to an enhanced metafile (HENHMETAFILE)
;                  |$CF_HDROP           - Handle to type HDROP that identifies a list of files
;                  |$CF_LOCALE          - Handle to the locale identifier associated with text in the clipboard
;                  |$CF_DIBV5           - BITMAPV5HEADER structure followed by bitmap color and the bitmap bits
;                  |$CF_OWNERDISPLAY    - Owner display format
;                  |$CF_DSPTEXT         - Text display format associated with a private format
;                  |$CF_DSPBITMAP       - Bitmap display format associated with a private format
;                  |$CF_DSPMETAFILEPICT - Metafile picture display format associated with a private format
;                  |$CF_DSPENHMETAFILE  - Enhanced metafile display format associated with a private format
; Return values .: Success      - The handle to the data
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The $iFormat parameter can identify a registered clipboard format, or it can be one of the standard clipboard
;                  formats. If an application calls this function in response to $WM_RENDERFORMAT or $WM_RENDERALLFORMATS, the
;                  application should not use the handle after this function has been called.  If an application calls _ClipBoard_Open
;                  with a NULL handle, _ClipBoard_Empty sets the clipboard owner to NULL; this causes this function to fail.
; Related .......: _ClipBoard_Empty, _ClipBoard_GetData, _ClipBoard_Open, _ClipBoard_SetData
; Link ..........: @@MsdnLink@@ SetClipboardData
; Example .......: Yes
; ===============================================================================================================================
Func _ClipBoard_SetDataEx(ByRef $hMemory, $iFormat = 1)
	Local $aResult = DllCall("user32.dll", "handle", "SetClipboardData", "uint", $iFormat, "handle", $hMemory)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_ClipBoard_SetDataEx

; #FUNCTION# ====================================================================================================================
; Name...........: _ClipBoard_SetViewer
; Description ...: Adds the specified window to the chain of clipboard viewers
; Syntax.........: _ClipBoard_SetViewer($hViewer)
; Parameters ....: $hViewer     - Handle to the window to be added to the clipboard chain
; Return values .: Success      - The handle to the next window in the clipboard viewer chain
;                  Failure      - Zero if there is no clipboard viewer
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The windows that are part of the clipboard viewer chain must process the clipboard messages $WM_CHANGECBCHAIN
;                  and $WM_DRAWCLIPBOARD. Each clipboard viewer window calls the _SendMessage function to pass these messages
;                  to the next window in the clipboard viewer chain. A clipboard viewer window must eventually remove itself from
;                  the clipboard viewer chain by calling the _ClipBoard_ChangeChain function.
; Related .......: _ClipBoard_ChangeChain, _ClipBoard_GetViewer
; Link ..........: @@MsdnLink@@ SetClipboardViewer
; Example .......: Yes
; ===============================================================================================================================
Func _ClipBoard_SetViewer($hViewer)
	Local $aResult = DllCall("user32.dll", "hwnd", "SetClipboardViewer", "hwnd", $hViewer)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_ClipBoard_SetViewer
