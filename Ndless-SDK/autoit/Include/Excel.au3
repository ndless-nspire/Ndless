#include-once

; #INDEX# =======================================================================================================================
; Title .........: Microsoft Excel COM UDF library for AutoIt v3
; AutoIt Version : 3.2.3++, Excel.au3 v 1.5 (07/18/2008 @ 8:25am PST)
; Language ......: English
; Description ...: Functions for creating, attaching to, reading from and manipulating Microsoft Excel.
; Author(s) .....: SEO (Locodarwin), DaLiMan, Stanley Lim, MikeOsdx, MRDev, big_daddy, PsaltyDS, litlmike
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $xlCalculationManual = -4135
Global Const $xlCalculationAutomatic = -4105
Global Const $xlLeft = -4131
Global Const $xlCenter = -4108
Global Const $xlRight = -4152
Global Const $xlEdgeLeft = 7
Global Const $xlEdgeTop = 8
Global Const $xlEdgeBottom = 9
Global Const $xlEdgeRight = 10
Global Const $xlInsideVertical = 11
Global Const $xlInsideHorizontal = 12
Global Const $xlTop = -4160
Global Const $xlBottom = -4107
Global Const $xlNormal = -4143
Global Const $xlWorkbookNormal = -4143
Global Const $xlCSVMSDOS = 24
Global Const $xlTextWindows = 20
Global Const $xlHtml = 44
Global Const $xlTemplate = 17
Global Const $xlThin = 2
Global Const $xlDouble = -4119
Global Const $xlThick = 4
Global Const $xl3DColumn = -4100
Global Const $xlColumns = 2
Global Const $xlLocationAsObject = 2
Global Const $xlVAlignBottom = -4107
Global Const $xlVAlignCenter = -4108
Global Const $xlVAlignDistributed = -4117
Global Const $xlVAlignJustify = -4130
Global Const $xlVAlignTop = -4160
Global Const $xlLine = 4
Global Const $xlValue = 2
Global Const $xlLinear = -4132
Global Const $xlNone = -4142
Global Const $xlDot = -4118
Global Const $xlCategory = 1
Global Const $xlContinuous = 1
Global Const $xlMedium = -4138
Global Const $xlLegendPositionLeft = -4131
Global Const $xlRadar = -4151
Global Const $xlAutomatic = -4105
Global Const $xlHairline = 1
Global Const $xlAscending = 1
Global Const $xlDescending = 2
Global Const $xlSortRows = 2
Global Const $xlSortColumns = 1
Global Const $xlSortLabels = 2
Global Const $xlSortValues = 1
Global Const $xlLeftToRight = 2
Global Const $xlTopToBottom = 1
Global Const $xlSortNormal = 0
Global Const $xlSortTextAsNumbers = 1
Global Const $xlGuess = 0
Global Const $xlNo = 2
Global Const $xlYes = 1
Global Const $xlFormulas = -4123
Global Const $xlPart = 2
Global Const $xlWhole = 1
Global Const $xlByColumns = 2
Global Const $xlByRows = 1
Global Const $xlNext = 1
Global Const $xlPrevious = 2
Global Const $xlCellTypeLastCell = 11
Global Const $xlR1C1 = -4150
Global Const $xlShiftDown = -4121
Global Const $xlShiftToRight = -4161
Global Const $xlValues = -4163
Global Const $xlNotes = -4144

Global Const $xlExclusive = 3
Global Const $xlNoChange = 1
Global Const $xlShared = 2

Global Const $xlLocalSessionChanges = 2
Global Const $xlOtherSessionChanges = 3
Global Const $xlUserResolution = 1

; Constants used for testing if a worksheet is visible or hidden.
Global Const $xlSheetHidden = 0
Global Const $xlSheetVisible = -1
Global Const $xlSheetVeryHidden = 2

; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_ExcelBookNew
;_ExcelBookOpen
;_ExcelBookAttach
;_ExcelBookSave
;_ExcelBookSaveAs
;_ExcelBookClose
;_ExcelWriteCell
;_ExcelWriteFormula
;_ExcelWriteArray
;_ExcelWriteSheetFromArray
;_ExcelHyperlinkInsert
;_ExcelNumberFormat
;_ExcelReadCell
;_ExcelReadArray
;_ExcelReadSheetToArray
;_ExcelRowDelete
;_ExcelColumnDelete
;_ExcelRowInsert
;_ExcelColumnInsert
;_ExcelSheetAddNew
;_ExcelSheetDelete
;_ExcelSheetNameGet
;_ExcelSheetNameSet
;_ExcelSheetList
;_ExcelSheetActivate
;_ExcelSheetMove
;_ExcelHorizontalAlignSet
;_ExcelFontSetProperties
;_ExcelNumberFormat
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelBookNew
; Description ...: Creates new workbook and returns its object identifier.
; Syntax.........: _ExcelBookNew([$fVisible = 1])
; Parameters ....: $fVisible - Flag, whether to show or hide the workbook (0=not visible, 1=visible)
; Return values .: Success		- Returns new object identifier
;                  Failure		- Returns 0 and Sets @Error:
;                  |@error = 1 - Unable to create the Excel COM object
;                  |@error = 2 - $fVisible parameter is not a number
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike
; Remarks .......:
; Related .......: _ExcelBookAttach
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelBookNew($fVisible = 1)
	Local $oExcel = ObjCreate("Excel.Application")
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	If Not IsNumber($fVisible) Then Return SetError(2, 0, 0)
	If $fVisible > 1 Then $fVisible = 1
	If $fVisible < 0 Then $fVisible = 0
	With $oExcel
		.Visible = $fVisible
		.WorkBooks.Add()
		.ActiveWorkbook.Sheets(1).Select()
	EndWith
	Return $oExcel
EndFunc   ;==>_ExcelBookNew

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelBookOpen
; Description ...: Opens an existing workbook and returns its object identifier.
; Syntax.........: _ExcelBookOpen($sFilePath[, $fVisible = 1[, $fReadOnly = False[, $sPassword = ""[, $sWritePassword = ""]]]])
; Parameters ....: $sFilePath - Path and filename of the file to be opened
;                  $fVisible - Flag, whether to show or hide the workbook (0=not visible, 1=visible) (default=1)
;                  $fReadOnly - Flag, whether to open the workbook as read-only (True or False) (default=False)
;                  $sPassword - The password that was used to read-protect the workbook, if any (default is none)
;                  $sWritePassword - The password that was used to write-protect the workbook, if any (default is none)
; Return values .: Success      - Returns new object identifier
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - Unable to create the object
;                  |@error=2     - File does not exist
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike
; Remarks .......: None
; Related .......: _ExcelBookAttach
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelBookOpen($sFilePath, $fVisible = 1, $fReadOnly = False, $sPassword = "", $sWritePassword = "")
	Local $oExcel = ObjCreate("Excel.Application")
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	If Not FileExists($sFilePath) Then Return SetError(2, 0, 0)
	If $fVisible > 1 Then $fVisible = 1
	If $fVisible < 0 Then $fVisible = 0
	If $fReadOnly > 1 Then $fReadOnly = 1
	If $fReadOnly < 0 Then $fReadOnly = 0
	With $oExcel
		.Visible = $fVisible
		If $sPassword <> "" And $sWritePassword <> "" Then .WorkBooks.Open($sFilePath, Default, $fReadOnly, Default, $sPassword, $sWritePassword)
		If $sPassword = "" And $sWritePassword <> "" Then .WorkBooks.Open($sFilePath, Default, $fReadOnly, Default, Default, $sWritePassword)
		If $sPassword <> "" And $sWritePassword = "" Then .WorkBooks.Open($sFilePath, Default, $fReadOnly, Default, $sPassword, Default)
		If $sPassword = "" And $sWritePassword = "" Then .WorkBooks.Open($sFilePath, Default, $fReadOnly)

		; Select the first *visible* worksheet.
		For $i = 1 To .ActiveWorkbook.Sheets.Count
			If .ActiveWorkbook.Sheets($i).Visible = $xlSheetVisible Then
				.ActiveWorkbook.Sheets($i).Select()
				ExitLoop
			EndIf
		Next
	EndWith
	Return $oExcel
EndFunc   ;==>_ExcelBookOpen

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelBookAttach
; Description ...: Attach to the first existing instance of Microsoft Excel where the search string matches based on the selected mode.
; Syntax.........: _ExcelBookAttach($s_string[, $s_mode = "FilePath"])
; Parameters ....: $s_string - String to search for
;                  $s_mode   - Optional: specifies search mode:
;                  |FileName - Name of the open workbook
;                  |FilePath - (Default) Full path to the open workbook
;                  |Title    - Title of the Excel window
; Return values .: Success   - Returns an object variable pointing to the Excel.Application, workbook object
;                  Failure   - Returns 0 and sets @ERROR = 1
; Author ........: Bob Anthony (big_daddy)
; Modified.......:
; Remarks .......:
; Related .......: _ExcelBookNew, _ExcelBookOpen
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelBookAttach($s_string, $s_mode = "FilePath")

	Local $o_Result

	If $s_mode = "filepath" Then
		$o_Result = ObjGet($s_string)
		If Not @error And IsObj($o_Result) Then
			Return $o_Result
		EndIf
	EndIf

	$o_Result = ObjGet("", "Excel.Application")
	If @error Or Not IsObj($o_Result) Then
;~ 		ConsoleWrite("--> Warning from function _ExcelAttach, No existing Excel.Application object" & @CRLF)
		Return SetError(1, 1, 0)
	EndIf

	Local $o_workbooks = $o_Result.Application.Workbooks
	If Not IsObj($o_workbooks) Or $o_workbooks.Count = 0 Then
;~ 		ConsoleWrite("--> Warning from function _ExcelAttach, No existing Excel.Application windows" & @CRLF)
		Return SetError(1, 2, 0)
	EndIf

	For $o_workbook In $o_workbooks

		Switch $s_mode
			Case "filename"
				If $o_workbook.Name = $s_string Then
					Return $o_workbook
				EndIf
			Case "filepath"
				If $o_workbook.FullName = $s_string Then
					Return $o_workbook
				EndIf
			Case "title"
				If ($o_workbook.Application.Caption) = $s_string Then
					Return $o_workbook
				EndIf
			Case Else
;~ 				ConsoleWrite("--> Error from function _ExcelAttach, Invalid Mode Specified" & @CRLF)
				Return SetError(1, 3, 0)
		EndSwitch
	Next

;~ 	ConsoleWrite("--> Warning from function _ExcelAttach, No Match" & @CRLF)
	Return SetError(1, 5, 0)
EndFunc   ;==>_ExcelBookAttach


; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelBookSave
; Description ...: Saves the active workbook of the specified Excel object.
; Syntax.........: _ExcelBookSave($oExcel[, $fAlerts = 0])
; Parameters ....: $oExcel - Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
;                  $fAlerts - Flag for disabling/enabling Excel message alerts (0=disable, 1=enable) (default = 0)
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - Specified object does not exist
;                  |@error=2     - File exists, overwrite flag not set
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelBookSave($oExcel, $fAlerts = 0)
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	If $fAlerts > 1 Then $fAlerts = 1
	If $fAlerts < 0 Then $fAlerts = 0
	With $oExcel
		.Application.DisplayAlerts = $fAlerts
		.Application.ScreenUpdating = $fAlerts
		.ActiveWorkBook.Save()
		If Not $fAlerts Then
			.Application.DisplayAlerts = 1
			.Application.ScreenUpdating = 1
		EndIf
	EndWith
	Return 1
EndFunc   ;==>_ExcelBookSave

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelBookSaveAs
; Description ...: Saves the active workbook of the specified Excel object with a new filename and/or type.
; Syntax.........: _ExcelBookSaveAs($oExcel, $sFilePath[, $sType = "xls"[, $fAlerts = 0[, $fOverWrite = 0[, $sPassword = ""[, $sWritePassword = ""[, $iAccessMode = 1[, $iConflictResolution = 2]]]]]]])
; Parameters ....: $oExcel - Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
;                  $sFilePath - Path and filename of the file to be read
;                  $sType - Excel writable filetype string = "xls|csv|txt|template|html", default "xls"
;                  $fAlerts - Flag for disabling/enabling Excel message alerts (0=disable, 1=enable)
;                  $fOverWrite - Flag for overwriting the file, if it already exists (0=no, 1=yes)
;                  $sPassword - The string password to protect the sheet with; if blank, no password will be used (default = blank)
;                  $sWritePassword - The string write-access password to protect the sheet with; if blank, no password will be used (default = blank)
;                  $iAccessMode - The document sharing mode to assign to the workbook:
;                  $xlNoChange - Leaves the sharing mode as it is (default) (numeric value = 1)
;                  $xlExclusive - Disables sharing on the workbook (numeric value = 3)
;                  $xlShared - Enable sharing on the workbook (numeric value = 2)
;                  $iConflictResolution - For shared documents, how to resolve sharing conflicts:
;                  $xlUserResolution - Pop up a dialog box asking the user how to resolve (numeric value = 1)
;                  $xlLocalSessionChanges - The local user's changes are always accepted (default) (numeric value = 2)
;                  $xlOtherSessionChanges - The local user's changes are always rejected (numeric value = 3)
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - Specified object does not exist
;                  |@error=2     - Invalid filetype string
;                  |@error=3 - File exists, overwrite flag not set
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike
; Remarks .......: You can only SaveAs back to the same working path the workbook was originally opened from at this time
;                  (not applicable to newly created, unsaved books).
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelBookSaveAs($oExcel, $sFilePath, $sType = "xls", $fAlerts = 0, $fOverWrite = 0, $sPassword = "", $sWritePassword = "", $iAccessMode = 1, _
		$iConflictResolution = 2)
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	If $sType = "xls" Or $sType = "csv" Or $sType = "txt" Or $sType = "template" Or $sType = "html" Then
		If $sType = "xls" Then $sType = $xlNormal
		If $sType = "csv" Then $sType = $xlCSVMSDOS
		If $sType = "txt" Then $sType = $xlTextWindows
		If $sType = "template" Then $sType = $xlTemplate
		If $sType = "html" Then $sType = $xlHtml
	Else
		Return SetError(2, 0, 0)
	EndIf
	If $fAlerts > 1 Then $fAlerts = 1
	If $fAlerts < 0 Then $fAlerts = 0
	$oExcel.Application.DisplayAlerts = $fAlerts
	$oExcel.Application.ScreenUpdating = $fAlerts
	If FileExists($sFilePath) Then
		If Not $fOverWrite Then Return SetError(3, 0, 0)
		FileDelete($sFilePath)
	EndIf
	If $sPassword = "" And $sWritePassword = "" Then $oExcel.ActiveWorkBook.SaveAs($sFilePath, $sType, Default, Default, Default, Default, $iAccessMode, $iConflictResolution)
	If $sPassword <> "" And $sWritePassword = "" Then $oExcel.ActiveWorkBook.SaveAs($sFilePath, $sType, $sPassword, Default, Default, Default, $iAccessMode, $iConflictResolution)
	If $sPassword <> "" And $sWritePassword <> "" Then $oExcel.ActiveWorkBook.SaveAs($sFilePath, $sType, $sPassword, $sWritePassword, Default, Default, $iAccessMode, $iConflictResolution)
	If $sPassword = "" And $sWritePassword <> "" Then $oExcel.ActiveWorkBook.SaveAs($sFilePath, $sType, Default, $sWritePassword, Default, Default, $iAccessMode, $iConflictResolution)
	If Not $fAlerts Then
		$oExcel.Application.DisplayAlerts = 1
		$oExcel.Application.ScreenUpdating = 1
	EndIf
	Return 1
EndFunc   ;==>_ExcelBookSaveAs

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelBookClose
; Description ...: Closes the active workbook and removes the specified Excel object.
; Syntax.........: _ExcelBookClose($oExcel[, $fSave = 1[, $fAlerts = 0]])
; Parameters ....: $oExcel - Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
;                  $fSave - Flag for saving the file before closing (0=no save, 1=save) (default = 1)
;                  $fAlerts - Flag for disabling/enabling Excel message alerts (0=disable, 1=enable) (default = 0)
; Return values .: On Success - Returns 1
;                  On Failure - Returns 0 and sets @error on errors:
;                  |@error=1 - Specified object does not exist
;                  |@error=2 - File exists, overwrite flag not set
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: 07/17/2008 by bid_daddy; litlmike
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelBookClose($oExcel, $fSave = 1, $fAlerts = 0)
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)

	Local $sObjName = ObjName($oExcel)

	If $fSave > 1 Then $fSave = 1
	If $fSave < 0 Then $fSave = 0
	If $fAlerts > 1 Then $fAlerts = 1
	If $fAlerts < 0 Then $fAlerts = 0

	; Save the users specified settings
	Local $fDisplayAlerts = $oExcel.Application.DisplayAlerts
	Local $fScreenUpdating = $oExcel.Application.ScreenUpdating
	; Make necessary changes
	$oExcel.Application.DisplayAlerts = $fAlerts
	$oExcel.Application.ScreenUpdating = $fAlerts

	Switch $sObjName
		Case "_Workbook"
			If $fSave Then $oExcel.Save()
			; Check if multiple workbooks are open
			; Do not close application if there are
			If $oExcel.Application.Workbooks.Count > 1 Then
				$oExcel.Close()
				; Restore the users specified settings
				$oExcel.Application.DisplayAlerts = $fDisplayAlerts
				$oExcel.Application.ScreenUpdating = $fScreenUpdating
			Else
				$oExcel.Application.Quit()
			EndIf
		Case "_Application"
			If $fSave Then $oExcel.ActiveWorkBook.Save()
			$oExcel.Quit()
		Case Else
			Return SetError(1, 0, 0)
	EndSwitch

	Return 1
EndFunc   ;==>_ExcelBookClose

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelWriteCell
; Description ...: Write information to a cell on the active worksheet of the specified Excel object.
; Syntax.........: _ExcelWriteCell($oExcel, $sValue, $sRangeOrRow[, $iColumn = 1])
; Parameters ....: $oExcel - Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
;                  $sValue - Value to be written
;                  $sRangeOrRow - Either an A1 range, or an integer row number to write to if using R1C1
;                  $iColumn - The column to write to if using R1C1 (default = 1)
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - Specified object does not exist
;                  |@error=2     - Parameter out of range
;                  |@extended=0 - Row out of range
;                  |@extended=1 - Column out of range
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelWriteCell($oExcel, $sValue, $sRangeOrRow, $iColumn = 1)
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	If Not StringRegExp($sRangeOrRow, "[A-Z,a-z]", 0) Then
		If $sRangeOrRow < 1 Then Return SetError(2, 0, 0)
		If $iColumn < 1 Then Return SetError(2, 1, 0)
		$oExcel.Activesheet.Cells($sRangeOrRow, $iColumn).Value = $sValue
		Return 1
	Else
		$oExcel.Activesheet.Range($sRangeOrRow).Value = $sValue
		Return 1
	EndIf
EndFunc   ;==>_ExcelWriteCell

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelWriteFormula
; Description ...: Write a formula to a cell on the active worksheet of the specified Excel object.
; Syntax.........: _ExcelWriteFormula($oExcel, $sFormula, $sRangeOrRow[, $iColumn = 1])
; Parameters ....: $oExcel - Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
;                  $sFormula - Formula to be written
;                  $sRangeOrRow - Either an A1 range, or an integer row number to write to if using R1C1
;                  $iColumn - The column to write to if using R1C1 (default = 1)
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - Specified object does not exist
;                  |@error=2     - Parameter out of range
;                  |@extended=0 - Row out of range
;                  |@extended=1 - Column out of range
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelWriteFormula($oExcel, $sFormula, $sRangeOrRow, $iColumn = 1)
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	If Not StringRegExp($sRangeOrRow, "[A-Z,a-z]", 0) Then
		If $sRangeOrRow < 1 Then Return SetError(2, 0, 0)
		If $iColumn < 1 Then Return SetError(2, 1, 0)
		$oExcel.Activesheet.Cells($sRangeOrRow, $iColumn).FormulaR1C1 = $sFormula
		Return 1
	Else
		$oExcel.Activesheet.Range($sRangeOrRow).Formula = $sFormula
		Return 1
	EndIf
EndFunc   ;==>_ExcelWriteFormula

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelWriteArray
; Description ...: Write an array to a row or column on the active worksheet of the specified Excel object.
; Syntax.........: _ExcelWriteArray($oExcel, $iStartRow, $iStartColumn, $aArray[, $iDirection = 0[, $iIndexBase = 0]])
; Parameters ....: $oExcel - Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
;                  $iStartRow - The table row to start writing the array to
;                  $iStartColumn - The table column to start writing the array to
;                  $aArray - The array to write into the sheet
;                  $iDirection - The direction to write the array (0=right, 1=down)
;                  $iIndexBase - Specify an array index base of either 0 or 1
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - Specified object does not exist
;                  |@error=2     - Parameter out of range
;                  |@extended=0 - Row out of range
;                  |@extended=1 - Column out of range
;                  |@error=3 - Array doesn't exist / variable is not an array
;                  |@error=4 - Invalid direction parameter
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelWriteArray($oExcel, $iStartRow, $iStartColumn, $aArray, $iDirection = 0, $iIndexBase = 0)
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	If $iStartRow < 1 Then Return SetError(2, 0, 0)
	If $iStartColumn < 1 Then Return SetError(2, 1, 0)
	If Not IsArray($aArray) Then Return SetError(3, 0, 0)
	If $iDirection < 0 Or $iDirection > 1 Then Return SetError(4, 0, 0)
	If Not $iDirection Then
		For $xx = $iIndexBase To UBound($aArray) - 1
			$oExcel.Activesheet.Cells($iStartRow, ($xx - $iIndexBase) + $iStartColumn).Value = $aArray[$xx]
		Next
	Else
		For $xx = $iIndexBase To UBound($aArray) - 1
			$oExcel.Activesheet.Cells(($xx - $iIndexBase) + $iStartRow, $iStartColumn).Value = $aArray[$xx]
		Next
	EndIf
	Return 1
EndFunc   ;==>_ExcelWriteArray

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelWriteSheetFromArray
; Description ...: Writes a 2D array to the active worksheet
; Syntax.........: _ExcelWriteSheetFromArray($oExcel, ByRef $aArray[, $iStartRow = 1[, $iStartColumn = 1[, $iRowBase = 1[, $iColBase = 1]]]])
; Parameters ....: $oExcel - Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
;                  $aArray - The array ByRef to write data from (array is not modified)
;                  $iStartRow - The table row to start writing the array to, default is 1
;                  $iStartColumn - The table column to start writing the array to, default is 1
;                  $iRowBase - array index base for rows, default is 1
;                  $iColBase - array index base for columns, default is 1
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - Specified object does not exist
;                  |@error=2     - Parameter out of range
;                  |@extended=0 - $iStartRow out of range
;                  |@extended=1 - $iStartColumn out of range
;                  |@error=3 - Array invalid
;                  |@extended=0 - doesn't exist / variable is not an array
;                  |@extended=1 - not a 2D array
;                  |@error=4 - Base index out of range
;                  |@extended=0 - $iRowBase out of range
;                  |@extended=1 - $iColBase out of range
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike and PsaltyDS 01/04/08 - 2D version _ExcelWriteSheetFromArray()
; Remarks .......: Default base indexes in the array are both = 1, so first cell written is from $aArray[1][1].
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelWriteSheetFromArray($oExcel, ByRef $aArray, $iStartRow = 1, $iStartColumn = 1, $iRowBase = 1, $iColBase = 1)
	; Test inputs
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	If $iStartRow < 1 Then Return SetError(2, 0, 0)
	If $iStartColumn < 1 Then Return SetError(2, 1, 0)
	If Not IsArray($aArray) Then Return SetError(3, 0, 0)
	Local $iDims = UBound($aArray, 0), $iLastRow = UBound($aArray, 1) - 1, $iLastColumn = UBound($aArray, 2) - 1
	If $iDims <> 2 Then Return SetError(3, 1, 0)
	If $iRowBase > $iLastRow Then Return SetError(4, 0, 0)
	If $iColBase > $iLastColumn Then Return SetError(4, 1, 0)

	Local $iCurrCol
	For $r = $iRowBase To $iLastRow
		$iCurrCol = $iStartColumn
		For $c = $iColBase To $iLastColumn
			$oExcel.Activesheet.Cells($iStartRow, $iCurrCol).Value = $aArray[$r][$c]
			$iCurrCol += 1
		Next
		$iStartRow += 1
	Next
	Return 1
EndFunc   ;==>_ExcelWriteSheetFromArray

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelHyperlinkInsert
; Description ...: Inserts a hyperlink into the active page.
; Syntax.........: _ExcelHyperlinkInsert($oExcel, $sLinkText, $sAddress, $sScreenTip, $sRangeOrRow[, $iColumn = 1])
; Parameters ....: $oExcel - An Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
;                  $sLinkText - The text to display the hyperlink as
;                  $sAddress - The URL to link to, as a string
;                  $sScreenTip - The popup screen tip, as a string
;                  $sRangeOrRow - The range in A1 format, or a row number for R1C1 format
;                  $iColumn - The specified column number for R1C1 format (default = 1)
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - Specified object does not exist
;                  |@error=2     - Row or column invalid
;                  |@extended=0 - Row invalid
;                  |@extended=1 - Column invalid
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelHyperlinkInsert($oExcel, $sLinkText, $sAddress, $sScreenTip, $sRangeOrRow, $iColumn = 1)
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	If Not StringRegExp($sRangeOrRow, "[A-Z,a-z]", 0) Then
		If $sRangeOrRow < 1 Then Return SetError(2, 0, 0)
		If $iColumn < 1 Then Return SetError(2, 1, 0)
		$oExcel.ActiveSheet.Cells($sRangeOrRow, $iColumn).Select()
	Else
		$oExcel.ActiveSheet.Range($sRangeOrRow).Select()
	EndIf
	$oExcel.ActiveSheet.Hyperlinks.Add($oExcel.Selection, $sAddress, "", $sScreenTip, $sLinkText)
	Return 1
EndFunc   ;==>_ExcelHyperlinkInsert

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelNumberFormat
; Description ...: Applies the specified formatting to the cells in the specified R1C1 Range.
; Syntax.........: _ExcelNumberFormat($oExcel, $sFormat, $sRangeOrRowStart[, $iColStart = 1[, $iRowEnd = 1[, $iColEnd = 1]]])
; Parameters ....: $oExcel - An Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
;                  $sFormat - The formatting string to apply to the specified range (see Notes below)
;                  $sRangeOrRowStart - Either an A1 range, or an integer row number to start from if using R1C1
;                  $iColStart - The starting column for the number format(left)
;                  $iRowEnd - The ending row for the number format (bottom)
;                  $iColEnd - The ending column for the number format (right)
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - Specified object does not exist
;                  |@error=2     - Starting row or column invalid
;                  |@extended=0 - Starting row invalid
;                  |@extended=1 - Starting column invalid
;                  |@error=3 - Ending row or column invalid
;                  |@extended=0 - Ending row invalid
;                  |@extended=1 - Ending column invalid
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike
; Remarks .......: For more information about possible formatting strings that can be used with this command, consult the book:
;                  "Programming Excel With VBA and .NET," by Steven Saunders and Jeff Webb, ISBN: 978-0-59-600766-9
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelNumberFormat($oExcel, $sFormat, $sRangeOrRowStart, $iColStart = 1, $iRowEnd = 1, $iColEnd = 1)
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	If Not StringRegExp($sRangeOrRowStart, "[A-Z,a-z]", 0) Then
		If $sRangeOrRowStart < 1 Then Return SetError(2, 0, 0)
		If $iColStart < 1 Then Return SetError(2, 1, 0)
		If $iRowEnd < $sRangeOrRowStart Then Return SetError(3, 0, 0)
		If $iColEnd < $iColStart Then Return SetError(3, 1, 0)
		With $oExcel.ActiveSheet
			.Range(.Cells($sRangeOrRowStart, $iColStart), .Cells($iRowEnd, $iColEnd)).NumberFormat = $sFormat
		EndWith
		Return 1
	Else
		$oExcel.ActiveSheet.Range($sRangeOrRowStart).NumberFormat = $sFormat
		Return 1
	EndIf
EndFunc   ;==>_ExcelNumberFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelReadCell
; Description ...: Read information from the active worksheet of the specified Excel object.
; Syntax.........: _ExcelReadCell($oExcel, $sRangeOrRow[, $iColumn = 1])
; Parameters ....: $oExcel - Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
;                  $sRangeOrRow - Either an A1 range, or an integer row number to read from if using R1C1
;                  $iColumn - The column to read from if using R1C1 (default = 1)
; Return values .: Success      - Returns the data from the specified cell
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - Specified object does not exist
;                  |@error=2     - Specified parameter is incorrect
;                  |@extended=0 - Row out of valid range
;                  |@extended=1 - Column out of valid range
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike
; Remarks .......: This function will only read one cell per call - if the specified range spans
;                  multiple cells, only the content of the top left cell will be returned.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelReadCell($oExcel, $sRangeOrRow, $iColumn = 1)
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	If Not StringRegExp($sRangeOrRow, "[A-Z,a-z]", 0) Then
		If $sRangeOrRow < 1 Then Return SetError(2, 0, 0)
		If $iColumn < 1 Then Return SetError(2, 1, 0)
		Return $oExcel.Activesheet.Cells($sRangeOrRow, $iColumn).Value
	Else
		Return $oExcel.Activesheet.Range($sRangeOrRow).Value
	EndIf
EndFunc   ;==>_ExcelReadCell

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelReadArray
; Description ...: Create an array from a row or column of the active worksheet.
; Syntax.........: _ExcelReadArray($oExcel, $iStartRow, $iStartColumn, $iNumCells[, $iDirection = 0[, $iIndexBase = 0]])
; Parameters ....: $oExcel - Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
;                  $iStartRow - The table row to start reading the array from
;                  $iStartColumn - The table column to start reading the array from
;                  $iNumCells - The number of cells to read into the array
;                  $iDirection - The direction of the cells to read into array (0=right, 1=down)
;                  $iIndexBase - Specify whether array created is to have index base of either 0 or 1
; Return values .: Success      - Returns an array with the specified cell contents
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - Specified object does not exist
;                  |@error=2     - Parameter out of range
;                  |@extended=0 - Row out of range
;                  |@extended=1 - Column out of range
;                  |@error=3 - Invalid number of cells
;                  |@error=4 - Invalid direction parameter
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelReadArray($oExcel, $iStartRow, $iStartColumn, $iNumCells, $iDirection = 0, $iIndexBase = 0)
	Local $aArray[$iNumCells + $iIndexBase]
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	If $iStartRow < 1 Then Return SetError(2, 0, 0)
	If $iStartColumn < 1 Then Return SetError(2, 1, 0)
	If Not IsNumber($iNumCells) Or $iNumCells < 1 Then Return SetError(3, 0, 0)
	If $iDirection < 0 Or $iDirection > 1 Then Return SetError(4, 0, 0)
	If Not $iDirection Then
		For $xx = $iIndexBase To UBound($aArray) - 1
			$aArray[$xx] = $oExcel.Activesheet.Cells($iStartRow, ($xx - $iIndexBase) + $iStartColumn).Value
		Next
	Else
		For $xx = $iIndexBase To UBound($aArray) - 1
			$aArray[$xx] = $oExcel.Activesheet.Cells(($xx - $iIndexBase) + $iStartRow, $iStartColumn).Value
		Next
	EndIf
	If $iIndexBase Then $aArray[0] = UBound($aArray) - 1
	Return $aArray
EndFunc   ;==>_ExcelReadArray

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelReadSheetToArray
; Description ...: Create a 2D array from the rows/columns of the active worksheet.
; Syntax.........: _ExcelReadSheetToArray($oExcel[, $iStartRow = 1[, $iStartColumn = 1[, $iRowCnt = 0[, $iColCnt = 0[, $iColShift = False]]]]])
; Parameters ....: $oExcel - Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
;                  $iStartRow - Row number to start reading, defaults to 1 (first row)
;                  $iStartColumn - Column number to start reading, defaults to 1 (first column)
;                  $iRowCnt - Count of rows to read, defaults to 0 (all)
;                  $iColCnt - Count of columns to read, defaults to 0 (all)
;                  $iColShift - Determines if the Array returned, from Excel, will begin in the 0-index base or 1-index base Column.  False by Default to match R1C1 values.
; Return values .: Success      - Returns a 2D array with the specified cell contents by [$row][$col]
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - Specified object does not exist
;                  |@error=2     - Start parameter out of range
;                  |@extended=0 - Row out of range
;                  |@extended=1 - Column out of range
;                  |@error=3 - Count parameter out of range
;                  |@extended=0 - Row count out of range
;                  |@extended=1 - Column count out of range
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike (added Column shift parameter to Start Array Column on 0) and PsaltyDS 01/04/08 - 2D version _ExcelReadSheetToArray()
; Remarks .......: Returned array has row count in [0][0] and column count in [0][1].
;                  Except for the counts above, row 0 and col 0 of the returned array are empty, as actual
;                  cell data starts at [1][1] to match R1C1 numbers.
;                  By default the entire sheet is returned.
;                  If the sheet is empty [0][0] and [0][1] both = 0.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelReadSheetToArray($oExcel, $iStartRow = 1, $iStartColumn = 1, $iRowCnt = 0, $iColCnt = 0, $iColShift = False)
	Local $avRET[1][2] = [[0, 0]] ; 2D return array

	; Test inputs
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	If $iStartRow < 1 Then Return SetError(2, 0, 0)
	If $iStartColumn < 1 Then Return SetError(2, 1, 0)
	If $iRowCnt < 0 Then Return SetError(3, 0, 0)
	If $iColCnt < 0 Then Return SetError(3, 1, 0)

	; Get size of current sheet as R1C1 string
	;     Note: $xlCellTypeLastCell and $x1R1C1 are constants declared in ExcelCOM_UDF.au3
	Local $sLastCell = $oExcel.Application.Selection.SpecialCells($xlCellTypeLastCell).Address(True, True, $xlR1C1)

	; Extract integer last row and col
	$sLastCell = StringRegExp($sLastCell, "\A[^0-9]*(\d+)[^0-9]*(\d+)\Z", 3)
	Local $iLastRow = $sLastCell[0]
	Local $iLastColumn = $sLastCell[1]

	; Return 0's if the sheet is blank
	If $sLastCell = "R1C1" And $oExcel.Activesheet.Cells($iLastRow, $iLastColumn).Value = "" Then Return $avRET

	; Check input range is in bounds
	If $iStartRow > $iLastRow Then Return SetError(2, 0, 0)
	If $iStartColumn > $iLastColumn Then Return SetError(2, 1, 0)
	If $iStartRow + $iRowCnt - 1 > $iLastRow Then Return SetError(3, 0, 0)
	If $iStartColumn + $iColCnt - 1 > $iLastColumn Then Return SetError(3, 1, 0)

	; Check for defaulted counts
	If $iRowCnt = 0 Then $iRowCnt = $iLastRow - $iStartRow + 1
	If $iColCnt = 0 Then $iColCnt = $iLastColumn - $iStartColumn + 1

	; Size the return array
	ReDim $avRET[$iRowCnt + 1][$iColCnt + 1]
	$avRET[0][0] = $iRowCnt
	$avRET[0][1] = $iColCnt

	If $iColShift Then ;Added by litlmike
		; Read data to array
		For $r = 1 To $iRowCnt
			For $c = 1 To $iColCnt
				$avRET[$r][$c - 1] = $oExcel.Activesheet.Cells($iStartRow + $r - 1, $iStartColumn + $c - 1).Value
			Next
		Next
	Else ;Default for $iColShift
		; Read data to array
		For $r = 1 To $iRowCnt
			For $c = 1 To $iColCnt
				$avRET[$r][$c] = $oExcel.Activesheet.Cells($iStartRow + $r - 1, $iStartColumn + $c - 1).Value
			Next
		Next
	EndIf
	;Return data
	Return $avRET
EndFunc   ;==>_ExcelReadSheetToArray

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelRowDelete
; Description ...: Delete a number of rows from the active worksheet.
; Syntax.........: _ExcelRowDelete($oExcel, $iRow[, $iNumRows = 1])
; Parameters ....: $oExcel - An Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
;                  $iRow - The specified row number to delete
;                  $iNumRows - The number of rows to delete
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - Specified object does not exist
;                  |@error=2     - Specified row is invalid
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike
; Remarks .......: This function will shift upward all rows after the deleted row(s)
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelRowDelete($oExcel, $iRow, $iNumRows = 1)
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	If $iRow < 1 Then Return SetError(2, 0, 0)
	For $x = 1 To $iNumRows
		$oExcel.ActiveSheet.Rows($iRow).Delete()
	Next
	Return 1
EndFunc   ;==>_ExcelRowDelete

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelColumnDelete
; Description ...: Delete a number of columns from the active worksheet.
; Syntax.........: _ExcelColumnDelete($oExcel, $iColumn[, $iNumCols = 1])
; Parameters ....: $oExcel - An Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
;                  $iColumn - The specified column number to delete
;                  $iNumCols - The number of columns to delete
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - Specified object does not exist
;                  |@error=2     - Specified column is invalid
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike
; Remarks .......: This function will shift left all columns after the deleted columns(s)
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelColumnDelete($oExcel, $iColumn, $iNumCols = 1)
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	If $iColumn < 1 Then Return SetError(2, 0, 0)
	For $x = 1 To $iNumCols
		$oExcel.ActiveSheet.Columns($iColumn).Delete()
	Next
	Return 1
EndFunc   ;==>_ExcelColumnDelete

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelRowInsert
; Description ...: Insert a number of rows into the active worksheet.
; Syntax.........: _ExcelRowInsert($oExcel, $iRow[, $iNumRows = 1])
; Parameters ....: $oExcel - An Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
;                  $iRow - The row position for insertion
;                  $iNumRows - The number of rows to insert
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - Specified object does not exist
;                  |@error=2     - Specified row postion is invalid
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike
; Remarks .......: This function will shift downward all rows before the inserted row(s)
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelRowInsert($oExcel, $iRow, $iNumRows = 1)
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	If $iRow < 1 Then Return SetError(2, 0, 0)
	For $x = 1 To $iNumRows
		$oExcel.ActiveSheet.Rows($iRow).Insert()
	Next
	Return 1
EndFunc   ;==>_ExcelRowInsert

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelColumnInsert
; Description ...: Insert a number of columns into the active worksheet.
; Syntax.........: _ExcelColumnInsert($oExcel, $iColumn[, $iNumCols = 1])
; Parameters ....: $oExcel - An Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
;                  $iColumn - The specified column number to begin insertion
;                  $iNumCols - The number of columns to insert
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - Specified object does not exist
;                  |@error=2     - Specified column is invalid
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike
; Remarks .......: This function will shift right all columns after the inserted columns(s)
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelColumnInsert($oExcel, $iColumn, $iNumCols = 1)
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	If $iColumn < 1 Then Return SetError(2, 0, 0)
	For $x = 1 To $iNumCols
		$oExcel.ActiveSheet.Columns($iColumn).Insert()
	Next
	Return 1
EndFunc   ;==>_ExcelColumnInsert

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelSheetAddNew
; Description ...: Add new sheet to workbook - optionally with a name.
; Syntax.........: _ExcelSheetAddNew($oExcel[, $sName = ""])
; Parameters ....: $oExcel - An Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
;                  $sName - The name of the sheet to create (default follows standard Excel new sheet convention)
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - Specified object does not exist
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelSheetAddNew($oExcel, $sName = "")
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	$oExcel.ActiveWorkBook.WorkSheets.Add().Activate()
	If $sName = "" Then Return 1
	$oExcel.ActiveSheet.Name = $sName
	Return 1
EndFunc   ;==>_ExcelSheetAddNew

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelSheetDelete
; Description ...: Delete the specified sheet by string name or by number.
; Syntax.........: _ExcelSheetDelete($oExcel, $vSheet[, $fAlerts = False])
; Parameters ....: $oExcel - An Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
;                  $vSheet - The sheet to delete, either by string name or by number
;                  $fAlerts - Allow modal alerts (True or False) (default=False)
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - Specified object does not exist
;                  |@error=2     - Specified sheet number does not exist
;                  |@error=3 - Specified sheet name does not exist
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelSheetDelete($oExcel, $vSheet, $fAlerts = False)
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	If IsNumber($vSheet) Then
		If $oExcel.ActiveWorkbook.Sheets.Count < $vSheet Then Return SetError(2, 0, 0)
	Else
		Local $fFound = 0
		Local $aSheetList = _ExcelSheetList($oExcel)
		For $xx = 1 To $aSheetList[0]
			If $aSheetList[$xx] = $vSheet Then $fFound = 1
		Next
		If Not $fFound Then Return SetError(3, 0, 0)
	EndIf
	If $fAlerts > 1 Then $fAlerts = 1
	If $fAlerts < 0 Then $fAlerts = 0
	$oExcel.Application.DisplayAlerts = $fAlerts
	$oExcel.Application.ScreenUpdating = $fAlerts
	$oExcel.ActiveWorkbook.Sheets($vSheet).Delete()
	$oExcel.Application.DisplayAlerts = True
	$oExcel.Application.ScreenUpdating = True
	Return 1
EndFunc   ;==>_ExcelSheetDelete

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelSheetNameGet
; Description ...: Return the name of the active sheet.
; Syntax.........: _ExcelSheetNameGet($oExcel)
; Parameters ....: $oExcel - An Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
; Return values .: Success      - Returns the name of the active sheet (string)
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - Specified object does not exist
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelSheetNameGet($oExcel)
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	Return $oExcel.ActiveSheet.Name
EndFunc   ;==>_ExcelSheetNameGet

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelSheetNameSet
; Description ...: Set the name of the active sheet.
; Syntax.........: _ExcelSheetNameSet($oExcel, $sSheetName)
; Parameters ....: $oExcel - An Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
;                  $sSheetName - The new name for the sheet
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - Specified object does not exist
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelSheetNameSet($oExcel, $sSheetName)
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	$oExcel.ActiveSheet.Name = $sSheetName
	Return 1
EndFunc   ;==>_ExcelSheetNameSet

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelSheetList
; Description ...: Return a list of all sheets in workbook, by name, as an array.
; Syntax.........: _ExcelSheetList($oExcel)
; Parameters ....: $oExcel - An Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
; Return values .: Success      - Returns an array of the sheet names in the workbook (the zero index stores the sheet count)
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - Specified object does not exist
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelSheetList($oExcel)
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	Local $iTemp = $oExcel.ActiveWorkbook.Sheets.Count
	Local $aSheets[$iTemp + 1]
	$aSheets[0] = $iTemp
	For $xx = 1 To $iTemp
		$aSheets[$xx] = $oExcel.ActiveWorkbook.Sheets($xx).Name
	Next
	Return $aSheets
EndFunc   ;==>_ExcelSheetList

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelSheetActivate
; Description ...: Activate the specified sheet by string name or by number.
; Syntax.........: _ExcelSheetActivate($oExcel, $vSheet)
; Parameters ....: $oExcel - An Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
;                  $vSheet - The sheet to activate, either by string name or by number
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - Specified object does not exist
;                  |@error=2     - Specified sheet number does not exist
;                  |@error=3 - Specified sheet name does not exist
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelSheetActivate($oExcel, $vSheet)
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	If IsNumber($vSheet) Then
		If $oExcel.ActiveWorkbook.Sheets.Count < $vSheet Then Return SetError(2, 0, 0)
	Else
		Local $fFound = 0
		Local $aSheetList = _ExcelSheetList($oExcel)
		For $xx = 1 To $aSheetList[0]
			If $aSheetList[$xx] = $vSheet Then $fFound = 1
		Next
		If Not $fFound Then Return SetError(3, 0, 0)
	EndIf
	$oExcel.ActiveWorkbook.Sheets($vSheet).Select()
	Return 1
EndFunc   ;==>_ExcelSheetActivate

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelSheetMove
; Description ...: Move the specified sheet before another specified sheet.
; Syntax.........: _ExcelSheetMove($oExcel, $vMoveSheet[, $vRelativeSheet = 1[, $fBefore = True]])
; Parameters ....: $oExcel - An Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
;                  $vMoveSheet - The name or number of the sheet to move (a string or integer)
;                  $vRelativeSheet - The moved sheet will be placed before or after this sheet (a string or integer, defaults to first sheet)
;                  $fBefore - The moved sheet will be placed before the relative sheet if true, after it if false (True or False) (default=True)
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - Specified object does not exist
;                  |@error=2     - Specified sheet number to move does not exist
;                  |@error=3 - Specified sheet name to move does not exist
;                  |@error=4 - Specified relative sheet number does not exist
;                  |@error=5 - Specified relative sheet name does not exist
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelSheetMove($oExcel, $vMoveSheet, $vRelativeSheet = 1, $fBefore = True)
	Local $aSheetList, $iFoundMove = 0, $iFoundBefore = 0
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	If IsNumber($vMoveSheet) Then
		If $oExcel.ActiveWorkbook.Sheets.Count < $vMoveSheet Then Return SetError(2, 0, 0)
	Else
		$aSheetList = _ExcelSheetList($oExcel)
		For $xx = 1 To $aSheetList[0]
			If $aSheetList[$xx] = $vMoveSheet Then $iFoundMove = $xx
		Next
		If Not $iFoundMove Then Return SetError(3, 0, 0)
	EndIf
	If IsNumber($vRelativeSheet) Then
		If $oExcel.ActiveWorkbook.Sheets.Count < $vRelativeSheet Then Return SetError(4, 0, 0)
	Else
		$aSheetList = _ExcelSheetList($oExcel)
		For $xx = 1 To $aSheetList[0]
			If $aSheetList[$xx] = $vRelativeSheet Then $iFoundBefore = $xx
		Next
		If Not $iFoundBefore Then Return SetError(5, 0, 0)
	EndIf
	If $fBefore Then
		$oExcel.Sheets($vMoveSheet).Move($oExcel.Sheets($vRelativeSheet))
	Else
		$oExcel.Sheets($vMoveSheet).Move(Default, $oExcel.Sheets($vRelativeSheet))
	EndIf
	Return 1
EndFunc   ;==>_ExcelSheetMove

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelHorizontalAlignSet
; Description ...: Set the horizontal alignment of each cell in a range.
; Syntax.........: _ExcelHorizontalAlignSet($oExcel, $sRangeOrRowStart[, $iColStart = 1[, $iRowEnd = 1[, $iColEnd = 1[, $sHorizAlign = "left"]]]])
; Parameters ....: $oExcel - An Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
;                  $sRangeOrRowStart - Either an A1 range, or an integer row number to start from if using R1C1
;                  $iColStart - The starting column for the number format(left) (default=1)
;                  $iRowEnd - The ending row for the number format (bottom) (default=1)
;                  $iColEnd - The ending column for the number format (right) (default=1)
;                  $sHorizAlign - Horizontal alignment ("left"|"center"|"right") (default="left")
; Return values .: On Success - Returns 1
;                  On Failure - Returns 0 and sets @error on errors:
;                  |@error=1 - Specified object does not exist
;                  |@error=2 - Starting row or column invalid
;                  |@extended=0 - Starting row invalid
;                  |@extended=1 - Starting column invalid
;                  |@error=3 - Ending row or column invalid
;                  |@extended=0 - Ending row invalid
;                  |@extended=1 - Ending column invalid
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelHorizontalAlignSet($oExcel, $sRangeOrRowStart, $iColStart = 1, $iRowEnd = 1, $iColEnd = 1, $sHorizAlign = "left")
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	If Not StringRegExp($sRangeOrRowStart, "[A-Z,a-z]", 0) Then
		If $sRangeOrRowStart < 1 Then Return SetError(2, 0, 0)
		If $iColStart < 1 Then Return SetError(2, 1, 0)
		If $iRowEnd < $sRangeOrRowStart Then Return SetError(3, 0, 0)
		If $iColEnd < $iColStart Then Return SetError(3, 1, 0)
		Switch ($sHorizAlign)
			Case "left"
				$oExcel.Activesheet.Range($oExcel.Cells($sRangeOrRowStart, $iColStart), $oExcel.Cells($iRowEnd, $iColEnd)).HorizontalAlignment = $xlLeft
			Case "center", "centre"
				$oExcel.Activesheet.Range($oExcel.Cells($sRangeOrRowStart, $iColStart), $oExcel.Cells($iRowEnd, $iColEnd)).HorizontalAlignment = $xlCenter
			Case "right"
				$oExcel.Activesheet.Range($oExcel.Cells($sRangeOrRowStart, $iColStart), $oExcel.Cells($iRowEnd, $iColEnd)).HorizontalAlignment = $xlRight
		EndSwitch
	Else
		Switch ($sHorizAlign)
			Case "left"
				$oExcel.Activesheet.Range($sRangeOrRowStart).HorizontalAlignment = $xlLeft
			Case "center", "centre"
				$oExcel.Activesheet.Range($sRangeOrRowStart).HorizontalAlignment = $xlCenter
			Case "right"
				$oExcel.Activesheet.Range($sRangeOrRowStart).HorizontalAlignment = $xlRight
		EndSwitch
	EndIf
	Return 1
EndFunc   ;==>_ExcelHorizontalAlignSet

; #FUNCTION# ====================================================================================================================
; Name...........: _ExcelFontSetProperties
; Description ...: Set the bold, italic, and underline font properties of a range in an Excel object.
; Syntax.........: _ExcelFontSetProperties($oExcel, $sRangeOrRowStart[, $iColStart = 1[, $iRowEnd = 1[, $iColEnd = 1[, $fBold = False[, $fItalic = False[, $fUnderline = False]]]]]])
; Parameters ....: $oExcel - An Excel object opened by a preceding call to _ExcelBookOpen() or _ExcelBookNew()
;                  $sRangeOrRowStart - Either an A1 range, or an integer row number to start from if using R1C1
;                  $iColStart - The starting column for the number format(left) (default=1)
;                  $iRowEnd - The ending row for the number format (bottom) (default=1)
;                  $iColEnd - The ending column for the number format (right) (default=1)
;                  $fBold - Bold flag: TRUE=Bold, FALSE=No Bold (remove bold type)
;                  $fItalic - Italic flag: TRUE=Italic, FALSE=No Italic (remove italic type)
;                  $fUnderline - Underline flag: TRUE=Underline, FALSE=No Underline (remove underline type)
; Return values .: On Success - Returns 1
;                  On Failure - Returns 0 and sets @error on errors:
;                  |@error=1 - Specified object does not exist
;                  |@error=2 - Starting row or column invalid
;                  |@extended=0 - Starting row invalid
;                  |@extended=1 - Starting column invalid
;                  |@error=3 - Ending row or column invalid
;                  |@extended=0 - Ending row invalid
;                  |@extended=1 - Ending column invalid
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ExcelFontSetProperties($oExcel, $sRangeOrRowStart, $iColStart = 1, $iRowEnd = 1, $iColEnd = 1, $fBold = False, $fItalic = False, $fUnderline = False)
	If Not IsObj($oExcel) Then Return SetError(1, 0, 0)
	If Not StringRegExp($sRangeOrRowStart, "[A-Z,a-z]", 0) Then
		If $sRangeOrRowStart < 1 Then Return SetError(2, 0, 0)
		If $iColStart < 1 Then Return SetError(2, 1, 0)
		If $iRowEnd < $sRangeOrRowStart Then Return SetError(3, 0, 0)
		If $iColEnd < $iColStart Then Return SetError(3, 1, 0)
		$oExcel.Activesheet.Range($oExcel.Cells($sRangeOrRowStart, $iColStart), $oExcel.Cells($iRowEnd, $iColEnd)).Font.Bold = $fBold
		$oExcel.Activesheet.Range($oExcel.Cells($sRangeOrRowStart, $iColStart), $oExcel.Cells($iRowEnd, $iColEnd)).Font.Italic = $fItalic
		$oExcel.Activesheet.Range($oExcel.Cells($sRangeOrRowStart, $iColStart), $oExcel.Cells($iRowEnd, $iColEnd)).Font.Underline = $fUnderline
	Else
		$oExcel.Activesheet.Range($sRangeOrRowStart).Font.Bold = $fBold
		$oExcel.Activesheet.Range($sRangeOrRowStart).Font.Italic = $fItalic
		$oExcel.Activesheet.Range($sRangeOrRowStart).Font.Underline = $fUnderline
	EndIf
	Return 1
EndFunc   ;==>_ExcelFontSetProperties
