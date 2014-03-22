#include-once

#include "EditConstants.au3"
#include "GuiStatusBar.au3"
#include "Memory.au3"
#include "WinAPI.au3"
#include "SendMessage.au3"
#include "UDFGlobalID.au3"

; #INDEX# =======================================================================================================================
; Title .........: Edit
; AutoIt Version : 3.3.7.20++
; Language ......: English
; Description ...: Functions that assist with Edit control management.
;                  An edit control is a rectangular control window typically used in a dialog box to permit the user to enter
;                  and edit text by typing on the keyboard.
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $_ghEditLastWnd
Global $Debug_Ed = False
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__EDITCONSTANT_ClassName = "Edit"
Global Const $__EDITCONSTANT_GUI_CHECKED = 1
Global Const $__EDITCONSTANT_GUI_HIDE = 32
Global Const $__EDITCONSTANT_GUI_EVENT_CLOSE = -3
Global Const $__EDITCONSTANT_GUI_ENABLE = 64
Global Const $__EDITCONSTANT_GUI_DISABLE = 128
Global Const $__EDITCONSTANT_SS_CENTER = 1
Global Const $__EDITCONSTANT_WM_SETREDRAW = 0x000B
Global Const $__EDITCONSTANT_WS_CAPTION = 0x00C00000
Global Const $__EDITCONSTANT_WS_POPUP = 0x80000000
Global Const $__EDITCONSTANT_WS_TABSTOP = 0x00010000
Global Const $__EDITCONSTANT_WS_SYSMENU = 0x00080000
Global Const $__EDITCONSTANT_WS_MINIMIZEBOX = 0x00020000
Global Const $__EDITCONSTANT_DEFAULT_GUI_FONT = 17
Global Const $__EDITCONSTANT_WM_SETFONT = 0x0030
Global Const $__EDITCONSTANT_WM_GETTEXTLENGTH = 0x000E
Global Const $__EDITCONSTANT_WM_GETTEXT = 0x000D
Global Const $__EDITCONSTANT_WM_SETTEXT = 0x000C
Global Const $__EDITCONSTANT_SB_LINEUP = 0
Global Const $__EDITCONSTANT_SB_LINEDOWN = 1
Global Const $__EDITCONSTANT_SB_PAGEDOWN = 3
Global Const $__EDITCONSTANT_SB_PAGEUP = 2
Global Const $__EDITCONSTANT_SB_SCROLLCARET = 4
; ===============================================================================================================================

; #OLD_FUNCTIONS#================================================================================================================
; Old Function/Name                      ; --> New Function/Name/Replacement(s)
;
; deprecated functions will no longer work
;_GUICtrlEditCanUndo                      ; --> _GUICtrlEdit_CanUndo
;_GUICtrlEditEmptyUndoBuffer              ; --> _GUICtrlEdit_EmptyUndoBuffer
;_GuiCtrlEditFind                         ; --> _GUICtrlEdit_Find
;_GuiCtrlEditFindText                     ; --> __GUICtrlEdit_FindText
;_GUICtrlEditGetFirstVisibleLine          ; --> _GUICtrlEdit_GetFirstVisibleLine
;_GUICtrlEditGetLine                      ; --> _GUICtrlEdit_GetLine
;_GUICtrlEditGetLineCount                 ; --> _GUICtrlEdit_GetLineCount
;_GUICtrlEditGetModify                    ; --> _GUICtrlEdit_GetModify
;_GUICtrlEditGetRECT                      ; --> _GUICtrlEdit_GetRECT
;_GUICtrlEditGetSel                       ; --> _GUICtrlEdit_GetSel
;_GUICtrlEditLineFromChar                 ; --> _GUICtrlEdit_LineFromChar
;_GUICtrlEditLineIndex                    ; --> _GUICtrlEdit_LineIndex
;_GUICtrlEditLineLength                   ; --> _GUICtrlEdit_LineLength
;_GUICtrlEditLineScroll                   ; --> _GUICtrlEdit_LineScroll
;_GUICtrlEditReplaceSel                   ; --> _GUICtrlEdit_ReplaceSel
;_GUICtrlEditScroll                       ; --> _GUICtrlEdit_Scroll
;_GUICtrlEditSetModify                    ; --> _GUICtrlEdit_SetModify
;_GUICtrlEditSetRECT                      ; --> _GUICtrlEdit_SetRECT
;_GUICtrlEditSetSel                       ; --> _GUICtrlEdit_SetSel
;_GUICtrlEditUndo                         ; --> _GUICtrlEdit_Undo
; ===============================================================================================================================

; #NO_DOC_FUNCTION# =============================================================================================================
; Not working/documented/implemented at this time
;
;_GUICtrlEdit_GetHandle
;_GUICtrlEdit_GetIMEStatus
;_GUICtrlEdit_GetThumb
;_GUICtrlEdit_GetWordBreakProc
;_GUICtrlEdit_SetHandle
;_GUICtrlEdit_SetIMEStatus
;_GUICtrlEdit_SetWordBreakProc
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_GUICtrlEdit_AppendText
;_GUICtrlEdit_BeginUpdate
;_GUICtrlEdit_CanUndo
;_GUICtrlEdit_CharFromPos
;_GUICtrlEdit_Create
;_GUICtrlEdit_Destroy
;_GUICtrlEdit_EmptyUndoBuffer
;_GUICtrlEdit_EndUpdate
;_GUICtrlEdit_FmtLines
;_GUICtrlEdit_Find
;_GUICtrlEdit_GetFirstVisibleLine
;_GUICtrlEdit_GetLimitText
;_GUICtrlEdit_GetLine
;_GUICtrlEdit_GetLineCount
;_GUICtrlEdit_GetMargins
;_GUICtrlEdit_GetModify
;_GUICtrlEdit_GetPasswordChar
;_GUICtrlEdit_GetRECT
;_GUICtrlEdit_GetRECTEx
;_GUICtrlEdit_GetSel
;_GUICtrlEdit_GetText
;_GUICtrlEdit_GetTextLen
;_GUICtrlEdit_HideBalloonTip
;_GUICtrlEdit_InsertText
;_GUICtrlEdit_LineFromChar
;_GUICtrlEdit_LineIndex
;_GUICtrlEdit_LineLength
;_GUICtrlEdit_LineScroll
;_GUICtrlEdit_PosFromChar
;_GUICtrlEdit_ReplaceSel
;_GUICtrlEdit_Scroll
;_GUICtrlEdit_SetLimitText
;_GUICtrlEdit_SetMargins
;_GUICtrlEdit_SetModify
;_GUICtrlEdit_SetPasswordChar
;_GUICtrlEdit_SetReadOnly
;_GUICtrlEdit_SetRECT
;_GUICtrlEdit_SetRECTEx
;_GUICtrlEdit_SetRECTNP
;_GUICtrlEdit_SetRectNPEx
;_GUICtrlEdit_SetSel
;_GUICtrlEdit_SetTabStops
;_GUICtrlEdit_SetText
;_GUICtrlEdit_ShowBalloonTip
;_GUICtrlEdit_Undo
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;$tagEDITBALLOONTIP
;__GUICtrlEdit_FindText
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagEDITBALLOONTIP
; Description ...: Contains information about a balloon tip
; Fields ........: Size     - Size of this structure, in bytes
;                  Title    - Pointer to the buffer that holds Title of the ToolTip
;                  Text     - Pointer to the buffer that holds Text of the ToolTip
;                  Icon     - Type of Icon.  This can be one of the following values:
;                  |$TTI_ERROR   - Use the error icon
;                  |$TTI_INFO    - Use the information icon
;                  |$TTI_NONE    - Use no icon
;                  |$TTI_WARNING - Use the warning icon
; Author ........: Gary Frost (gafrost)
; Remarks .......: For use with Edit control (minimum O.S. Win XP)
; ===============================================================================================================================
Global Const $tagEDITBALLOONTIP = "dword Size;ptr Title;ptr Text;int Icon"

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_AppendText
; Description ...: Append text
; Syntax.........: _GUICtrlEdit_AppendText($hWnd, $sText)
; Parameters ....: $hWnd        - Handle to the control
;                  $sText       - String to append
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlEdit_SetText, _GUICtrlEdit_InsertText, _GUICtrlEdit_GetText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_AppendText($hWnd, $sText)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $iLength = _GUICtrlEdit_GetTextLen($hWnd)
	_GUICtrlEdit_SetSel($hWnd, $iLength, $iLength)
	_SendMessage($hWnd, $EM_REPLACESEL, True, $sText, 0, "wparam", "wstr")
EndFunc   ;==>_GUICtrlEdit_AppendText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_BeginUpdate
; Description ...: Prevents updating of the control until the EndUpdate function is called
; Syntax.........: _GUICtrlEdit_BeginUpdate($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlEdit_EndUpdate
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_BeginUpdate($hWnd)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $__EDITCONSTANT_WM_SETREDRAW) = 0
EndFunc   ;==>_GUICtrlEdit_BeginUpdate

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_CanUndo
; Description ...: Determines whether there are any actions in an edit control's undo queue
; Syntax.........: _GUICtrlEdit_CanUndo($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: True         - If there are actions in the control's undo queue
;                  False        - If the undo queue is empty
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If the undo queue is not empty, you can call the _GUICtrlEdit_Undo to undo the most recent operation.
; Related .......: _GUICtrlEdit_EmptyUndoBuffer, _GUICtrlEdit_GetModify, _GUICtrlEdit_SetModify, _GUICtrlEdit_Undo
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_CanUndo($hWnd)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $EM_CANUNDO) <> 0
EndFunc   ;==>_GUICtrlEdit_CanUndo

; #FUNCTION# ====================================================================================================================
; Name...........:  _GUICtrlEdit_CharFromPos
; Description ...: Retrieve information about the character closest to a specified point in the client area
; Syntax.........: _GUICtrlEdit_CharFromPos($hWnd, $iX, $iY)
; Parameters ....: $hWnd        - Handle to the control
;                  $iX          - horizontal position
;                  $iY          - vertical position
; Return values .: Success      - Array in the following format:
;                  |[0]         - Zero-based index of the character nearest the specified point
;                  |[1]         - Zero-based index of the line that contains the character
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_CharFromPos($hWnd, $iX, $iY)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $aReturn[2]

	Local $iRet = _SendMessage($hWnd, $EM_CHARFROMPOS, 0, _WinAPI_MakeLong($iX, $iY))
	$aReturn[0] = _WinAPI_LoWord($iRet)
	$aReturn[1] = _WinAPI_HiWord($iRet)
	Return $aReturn
EndFunc   ;==>_GUICtrlEdit_CharFromPos

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_Create
; Description ...: Create a Edit control
; Syntax.........: _GUICtrlEdit_Create($hWnd, $sText, $iX, $iY[, $iWidth = 150[, $iHeight = 150[, $iStyle = 0x003010C4[, $iExStyle = 0x00000200]]]])
; Parameters ....: $hWnd        - Handle to parent or owner window
;                  $sText       - Text to be displayed in the control
;                  $iX          - Horizontal position of the control
;                  $iY          - Vertical position of the control
;                  $iWidth      - Control width
;                  $iHeight     - Control height
;                  $iStyle      - Control styles:
;                  |$ES_AUTOHSCROLL - Automatically scrolls text to the right by 10 characters when the user types a character at the end of the line.
;                  |$ES_AUTOVSCROLL - Automatically scrolls text up one page when the user presses the ENTER key on the last line.
;                  |$ES_CENTER      - Centers text in a edit control.
;                  |$ES_LEFT        - Aligns text with the left margin.
;                  |$ES_LOWERCASE   - Converts all characters to lowercase as they are typed into the edit control.
;                  |$ES_MULTILINE   - Forced
;                  |$ES_NOHIDESEL   - The selected text is inverted, even if the control does not have the focus.
;                  |$ES_NUMBER      - Allows only digits to be entered into the edit control.
;                  |$ES_OEMCONVERT  - Converts text entered in the edit control.
;                  |$ES_READONLY    - Prevents the user from typing or editing text in the edit control.
;                  |$ES_RIGHT       - Right-aligns text edit control.
;                  |$ES_UPPERCASE   - Converts all characters to uppercase as they are typed into the edit control.
;                  |$ES_WANTRETURN  - Specifies that a carriage return be inserted when the user presses the ENTER key.
;                  |$ES_PASSWORD    - Displays an asterisk (*) for each character that is typed into the edit control
;                  -
;                  |Default: $ES_MULTILINE, $ES_WANTRETURN, $WS_VSCROLL, $WS_HSCROLL, $ES_AUTOVSCROLL, $ES_AUTOHSCROLL
;                  |Forced : WS_CHILD, $WS_VISIBLE, $WS_TABSTOP unless $ES_READONLY
;                  $iExStyle    - Control extended style. These correspond to the standard $WS_EX_ constants.
; Return values .: Success      - Handle to the Edit control
;                  Failure      - 0
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: This function is for Advanced users and for learning how the control works.
; Related .......: _GUICtrlEdit_Destroy
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_Create($hWnd, $sText, $iX, $iY, $iWidth = 150, $iHeight = 150, $iStyle = 0x003010C4, $iExStyle = 0x00000200)
	If Not IsHWnd($hWnd) Then Return SetError(1, 0, 0) ; Invalid Window handle for _GUICtrlEdit_Create 1st parameter
	If Not IsString($sText) Then Return SetError(2, 0, 0) ; 2nd parameter not a string for _GUICtrlEdit_Create

	If $iWidth = -1 Then $iWidth = 150
	If $iHeight = -1 Then $iHeight = 150
	If $iStyle = -1 Then $iStyle = 0x003010C4
	If $iExStyle = -1 Then $iExStyle = 0x00000200

	If BitAND($iStyle, $ES_READONLY) = $ES_READONLY Then
		$iStyle = BitOR($__UDFGUICONSTANT_WS_CHILD, $__UDFGUICONSTANT_WS_VISIBLE, $iStyle)
	Else
		$iStyle = BitOR($__UDFGUICONSTANT_WS_CHILD, $__UDFGUICONSTANT_WS_VISIBLE, $__EDITCONSTANT_WS_TABSTOP, $iStyle)
	EndIf
	;=========================================================================================================

	Local $nCtrlID = __UDF_GetNextGlobalID($hWnd)
	If @error Then Return SetError(@error, @extended, 0)

	Local $hEdit = _WinAPI_CreateWindowEx($iExStyle, $__EDITCONSTANT_ClassName, "", $iStyle, $iX, $iY, $iWidth, $iHeight, $hWnd, $nCtrlID)
	_SendMessage($hEdit, $__EDITCONSTANT_WM_SETFONT, _WinAPI_GetStockObject($__EDITCONSTANT_DEFAULT_GUI_FONT), True)
	_GUICtrlEdit_SetText($hEdit, $sText)
	_GUICtrlEdit_SetLimitText($hEdit, 0)
	Return $hEdit
EndFunc   ;==>_GUICtrlEdit_Create

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_Destroy
; Description ...: Delete the Edit control
; Syntax.........: _GUICtrlEdit_Destroy(ByRef $hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True, Handle is set to 0
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Restricted to only be used on Edit created with _GUICtrlEdit_Create
; Related .......: _GUICtrlEdit_Create
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_Destroy(ByRef $hWnd)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not _WinAPI_IsClassName($hWnd, $__EDITCONSTANT_ClassName) Then Return SetError(2, 2, False)

	Local $Destroyed = 0
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_ghEditLastWnd) Then
			Local $nCtrlID = _WinAPI_GetDlgCtrlID($hWnd)
			Local $hParent = _WinAPI_GetParent($hWnd)
			$Destroyed = _WinAPI_DestroyWindow($hWnd)
			Local $iRet = __UDF_FreeGlobalID($hParent, $nCtrlID)
			If Not $iRet Then
				; can check for errors here if needed, for debug
			EndIf
		Else
			; Not Allowed to Destroy Other Applications Control(s)
			Return SetError(1, 1, False)
		EndIf
	Else
		$Destroyed = GUICtrlDelete($hWnd)
	EndIf
	If $Destroyed Then $hWnd = 0
	Return $Destroyed <> 0
EndFunc   ;==>_GUICtrlEdit_Destroy

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_EmptyUndoBuffer
; Description ...: Resets the undo flag of an edit control
; Syntax.........: _GUICtrlEdit_EmptyUndoBuffer($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The undo flag is automatically reset whenever the edit control receives a _GUICtrlEdit_SetText
; Related .......: _GUICtrlEdit_CanUndo, _GUICtrlEdit_Undo
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_EmptyUndoBuffer($hWnd)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $EM_EMPTYUNDOBUFFER)
EndFunc   ;==>_GUICtrlEdit_EmptyUndoBuffer

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_EndUpdate
; Description ...: Enables screen repainting that was turned off with the BeginUpdate function
; Syntax.........: _GUICtrlEdit_EndUpdate($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlEdit_BeginUpdate
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_EndUpdate($hWnd)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $__EDITCONSTANT_WM_SETREDRAW, 1) = 0
EndFunc   ;==>_GUICtrlEdit_EndUpdate

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_FmtLines
; Description ...: Determines whether a edit control includes soft line-break characters
; Syntax.........: _GUICtrlEdit_FmtLines($hWnd[, $fSoftBreak = False])
; Parameters ....: $hWnd        - Handle to the control
;                  $fSoftBreak  - Specifies whether soft line-break characters are to be inserted:
;                  | True       - Inserts the characters
;                  |False       - Removes them
; Return values .: Success      - Identical to the $fSoftBreak parameter
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: A soft line break consists of two carriage returns and a line feed and is inserted at the
;                  end of a line that is broken because of wordwrapping.
;+
;                  This function affects only the text returned by the _GUICtrlEdit_GetText function.
;+
;                  It has no effect on the display of the text within the edit control.
;+
;                  The _GUICtrlEdit_FmtLines function does not affect a line that ends with a hard line break.
;                  A hard line break consists of one carriage return and a line feed.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_FmtLines($hWnd, $fSoftBreak = False)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $EM_FMTLINES, $fSoftBreak)
EndFunc   ;==>_GUICtrlEdit_FmtLines

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_Find
; Description ...: Initiates a find dialog
; Syntax.........: _GUICtrlEdit_Find($hWnd[, $fReplace = False])
; Parameters ....: $hWnd        - Handle to the control
;                  $fReplace    - Replace Option:
;                  | True       - Show option
;                  |False       - Hide option
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If you use text from the edit control and that text gets replaced the function will no
;                  longer function correctly
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_Find($hWnd, $fReplace = False)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $iPos = 0, $iCase, $iOccurance = 0, $iReplacements = 0
	Local $aPartsRightEdge[3] = [125, 225, -1]
	Local $oldMode = Opt("GUIOnEventMode", 0)

	Local $aSel = _GUICtrlEdit_GetSel($hWnd)
	Local $sText = _GUICtrlEdit_GetText($hWnd)

	Local $guiSearch = GUICreate("Find", 349, 177, -1, -1, BitOR($__UDFGUICONSTANT_WS_CHILD, $__EDITCONSTANT_WS_MINIMIZEBOX, $__EDITCONSTANT_WS_CAPTION, $__EDITCONSTANT_WS_POPUP, $__EDITCONSTANT_WS_SYSMENU))
	Local $StatusBar1 = _GUICtrlStatusBar_Create($guiSearch, $aPartsRightEdge)
	_GUICtrlStatusBar_SetText($StatusBar1, "Find: ")

	GUISetIcon(@SystemDir & "\shell32.dll", 22, $guiSearch)
	GUICtrlCreateLabel("Find what:", 9, 10, 53, 16, $__EDITCONSTANT_SS_CENTER)
	Local $inputSearch = GUICtrlCreateInput("", 80, 8, 257, 21)
	Local $lblReplace = GUICtrlCreateLabel("Replace with:", 9, 42, 69, 17, $__EDITCONSTANT_SS_CENTER)
	Local $inputReplace = GUICtrlCreateInput("", 80, 40, 257, 21)
	Local $chkWholeOnly = GUICtrlCreateCheckbox("Match whole word only", 9, 72, 145, 17)
	Local $chkMatchCase = GUICtrlCreateCheckbox("Match case", 9, 96, 145, 17)
	Local $btnFindNext = GUICtrlCreateButton("Find Next", 168, 72, 161, 21, 0)
	Local $btnReplace = GUICtrlCreateButton("Replace", 168, 96, 161, 21, 0)
	Local $btnClose = GUICtrlCreateButton("Close", 104, 130, 161, 21, 0)
	If (IsArray($aSel) And $aSel <> $EC_ERR) Then
		GUICtrlSetData($inputSearch, StringMid($sText, $aSel[0] + 1, $aSel[1] - $aSel[0]))
		If $aSel[0] <> $aSel[1] Then ; text was selected when function was invoked
			$iPos = $aSel[0]
			If BitAND(GUICtrlRead($chkMatchCase), $__EDITCONSTANT_GUI_CHECKED) = $__EDITCONSTANT_GUI_CHECKED Then $iCase = 1
			$iOccurance = 1
			Local $iTPose
			While 1 ; set the current occurance so search starts from here
				$iTPose = StringInStr($sText, GUICtrlRead($inputSearch), $iCase, $iOccurance)
				If Not $iTPose Then ; this should never happen, but just in case
					$iOccurance = 0
					ExitLoop
				ElseIf $iTPose = $iPos + 1 Then ; found the occurance
					ExitLoop
				EndIf
				$iOccurance += 1
			WEnd
		EndIf
		_GUICtrlStatusBar_SetText($StatusBar1, "Find: " & GUICtrlRead($inputSearch))
	EndIf

	If $fReplace = False Then
		GUICtrlSetState($lblReplace, $__EDITCONSTANT_GUI_HIDE)
		GUICtrlSetState($inputReplace, $__EDITCONSTANT_GUI_HIDE)
		GUICtrlSetState($btnReplace, $__EDITCONSTANT_GUI_HIDE)
	Else
		_GUICtrlStatusBar_SetText($StatusBar1, "Replacements: " & $iReplacements, 1)
		_GUICtrlStatusBar_SetText($StatusBar1, "With: ", 2)
	EndIf
	GUISetState(@SW_SHOW)

	Local $msgFind
	While 1
		$msgFind = GUIGetMsg()
		Select
			Case $msgFind = $__EDITCONSTANT_GUI_EVENT_CLOSE Or $msgFind = $btnClose
				ExitLoop
			Case $msgFind = $btnFindNext
				GUICtrlSetState($btnFindNext, $__EDITCONSTANT_GUI_DISABLE)
				GUICtrlSetCursor($btnFindNext, 15)
				Sleep(100)
				_GUICtrlStatusBar_SetText($StatusBar1, "Find: " & GUICtrlRead($inputSearch))
				If $fReplace = True Then
					_GUICtrlStatusBar_SetText($StatusBar1, "Find: " & GUICtrlRead($inputSearch))
					_GUICtrlStatusBar_SetText($StatusBar1, "With: " & GUICtrlRead($inputReplace), 2)
				EndIf
				__GUICtrlEdit_FindText($hWnd, $inputSearch, $chkMatchCase, $chkWholeOnly, $iPos, $iOccurance, $iReplacements)
				Sleep(100)
				GUICtrlSetState($btnFindNext, $__EDITCONSTANT_GUI_ENABLE)
				GUICtrlSetCursor($btnFindNext, 2)
			Case $msgFind = $btnReplace
				GUICtrlSetState($btnReplace, $__EDITCONSTANT_GUI_DISABLE)
				GUICtrlSetCursor($btnReplace, 15)
				Sleep(100)
				_GUICtrlStatusBar_SetText($StatusBar1, "Find: " & GUICtrlRead($inputSearch))
				_GUICtrlStatusBar_SetText($StatusBar1, "With: " & GUICtrlRead($inputReplace), 2)
				If $iPos Then
					_GUICtrlEdit_ReplaceSel($hWnd, GUICtrlRead($inputReplace))
					$iReplacements += 1
					$iOccurance -= 1
					_GUICtrlStatusBar_SetText($StatusBar1, "Replacements: " & $iReplacements, 1)
				EndIf
				__GUICtrlEdit_FindText($hWnd, $inputSearch, $chkMatchCase, $chkWholeOnly, $iPos, $iOccurance, $iReplacements)
				Sleep(100)
				GUICtrlSetState($btnReplace, $__EDITCONSTANT_GUI_ENABLE)
				GUICtrlSetCursor($btnReplace, 2)
		EndSelect
	WEnd
	GUIDelete($guiSearch)
	Opt("GUIOnEventMode", $oldMode)
EndFunc   ;==>_GUICtrlEdit_Find

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlEdit_FindText
; Description ...:
; Syntax.........: __GUICtrlEdit_FindText($hWnd, $inputSearch, $chkMatchCase, $chkWholeOnly, ByRef $iPos, ByRef $iOccurance, ByRef $iReplacements)
; Parameters ....: $hWnd          - Handle to the control
;                  $inputSearch   - controlID
;                  $chkMatchCase  - controlID
;                  $chkWholeOnly  - controlID
;                  $iPos          - position of text found
;                  $iOccurance    - occurance to find
;                  $iReplacements - # of occurances replaced
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlEdit_Find
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GUICtrlEdit_FindText($hWnd, $inputSearch, $chkMatchCase, $chkWholeOnly, ByRef $iPos, ByRef $iOccurance, ByRef $iReplacements)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $iCase = 0, $iWhole = 0
	Local $fExact = False
	Local $sFind = GUICtrlRead($inputSearch)

	Local $sText = _GUICtrlEdit_GetText($hWnd)

	If BitAND(GUICtrlRead($chkMatchCase), $__EDITCONSTANT_GUI_CHECKED) = $__EDITCONSTANT_GUI_CHECKED Then $iCase = 1
	If BitAND(GUICtrlRead($chkWholeOnly), $__EDITCONSTANT_GUI_CHECKED) = $__EDITCONSTANT_GUI_CHECKED Then $iWhole = 1
	If $sFind <> "" Then
		$iOccurance += 1
		$iPos = StringInStr($sText, $sFind, $iCase, $iOccurance)
		If $iWhole And $iPos Then
			Local $c_compare2 = StringMid($sText, $iPos + StringLen($sFind), 1)
			If $iPos = 1 Then
				If ($iPos + StringLen($sFind)) - 1 = StringLen($sText) Or _
						($c_compare2 = " " Or $c_compare2 = @LF Or $c_compare2 = @CR Or _
						$c_compare2 = @CRLF Or $c_compare2 = @TAB) Then $fExact = True
			Else
				Local $c_compare1 = StringMid($sText, $iPos - 1, 1)
				If ($iPos + StringLen($sFind)) - 1 = StringLen($sText) Then
					If ($c_compare1 = " " Or $c_compare1 = @LF Or $c_compare1 = @CR Or _
							$c_compare1 = @CRLF Or $c_compare1 = @TAB) Then $fExact = True
				Else
					If ($c_compare1 = " " Or $c_compare1 = @LF Or $c_compare1 = @CR Or _
							$c_compare1 = @CRLF Or $c_compare1 = @TAB) And _
							($c_compare2 = " " Or $c_compare2 = @LF Or $c_compare2 = @CR Or _
							$c_compare2 = @CRLF Or $c_compare2 = @TAB) Then $fExact = True
				EndIf
			EndIf
			If $fExact = False Then ; found word, but as part of another word, so search again
				__GUICtrlEdit_FindText($hWnd, $inputSearch, $chkMatchCase, $chkWholeOnly, $iPos, $iOccurance, $iReplacements)
			Else ; found it
				_GUICtrlEdit_SetSel($hWnd, $iPos - 1, ($iPos + StringLen($sFind)) - 1)
				_GUICtrlEdit_Scroll($hWnd, $__EDITCONSTANT_SB_SCROLLCARET)
			EndIf
		ElseIf $iWhole And Not $iPos Then ; no more to find
			$iOccurance = 0
			MsgBox(48, "Find", "Reached End of document, Can not find the string '" & $sFind & "'")
		ElseIf Not $iWhole Then
			If Not $iPos Then ; wrap around search and select
				$iOccurance = 1
				_GUICtrlEdit_SetSel($hWnd, -1, 0)
				_GUICtrlEdit_Scroll($hWnd, $__EDITCONSTANT_SB_SCROLLCARET)
				$iPos = StringInStr($sText, $sFind, $iCase, $iOccurance)
				If Not $iPos Then ; no more to find
					$iOccurance = 0
					MsgBox(48, "Find", "Reached End of document, Can not find the string  '" & $sFind & "'")
				Else ; found it
					_GUICtrlEdit_SetSel($hWnd, $iPos - 1, ($iPos + StringLen($sFind)) - 1)
					_GUICtrlEdit_Scroll($hWnd, $__EDITCONSTANT_SB_SCROLLCARET)
				EndIf
			Else ; set selection
				_GUICtrlEdit_SetSel($hWnd, $iPos - 1, ($iPos + StringLen($sFind)) - 1)
				_GUICtrlEdit_Scroll($hWnd, $__EDITCONSTANT_SB_SCROLLCARET)
			EndIf
		EndIf
	EndIf
EndFunc   ;==>__GUICtrlEdit_FindText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_GetFirstVisibleLine
; Description ...: Retrieves the zero-based index of the uppermost visible line in a multiline edit control
; Syntax.........: _GUICtrlEdit_GetFirstVisibleLine($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - zero-based index of the uppermost visible line in a multiline edit control
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The number of lines and the length of the lines in an edit control depend on the width of the control
;                  and the current Wordwrap setting.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_GetFirstVisibleLine($hWnd)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $EM_GETFIRSTVISIBLELINE)
EndFunc   ;==>_GUICtrlEdit_GetFirstVisibleLine

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlEdit_GetHandle
; Description ...: Gets a handle of the memory currently allocated for a multiline edit control's text
; Syntax.........: _GUICtrlEdit_GetHandle($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Memory handle identifying the buffer that holds the content of the edit control
;                  Failure      - 0
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If the function succeeds, the application can access the contents of the edit control by casting the
;                  return value to HLOCAL and passing it to LocalLock. LocalLock returns a pointer to a buffer that is a
;                  null-terminated array of CHARs or WCHARs, depending on whether an ANSI or Unicode function created the control.
;                  For example, if CreateWindowExA was used the buffer is an array of CHARs, but if CreateWindowExW was used the
;                  buffer is an array of WCHARs. The application may not change the contents of the buffer. To unlock the buffer,
;                  the application calls LocalUnlock before allowing the edit control to receive new messages.
;+
;                  If your application cannot abide by the restrictions imposed by EM_GETHANDLE, use the GetWindowTextLength and
;                  GetWindowText functions to copy the contents of the edit control into an application-provided buffer.
; Related .......: _GUICtrlEdit_SetHandle
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlEdit_GetHandle($hWnd)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return Ptr(_SendMessage($hWnd, $EM_GETHANDLE))
EndFunc   ;==>_GUICtrlEdit_GetHandle

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlEdit_GetIMEStatus
; Description ...: Gets a set of status flags that indicate how the edit control interacts with the Input Method Editor (IME)
; Syntax.........: _GUICtrlEdit_GetIMEStatus($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - One or More of the Following Flags
;                  |$EIMES_GETCOMPSTRATONCE - The edit control hooks the WM_IME_COMPOSITION message
;                  |$EIMES_CANCELCOMPSTRINFOCUS - The edit control cancels the composition string when it receives the WM_SETFOCUS message
;                  |$EIMES_COMPLETECOMPSTRKILLFOCUS - The edit control completes the composition string upon receiving the WM_KILLFOCUS message
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlEdit_GetIMEStatus($hWnd)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $EM_GETIMESTATUS, $EMSIS_COMPOSITIONSTRING)
EndFunc   ;==>_GUICtrlEdit_GetIMEStatus

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_GetLimitText
; Description ...: Gets the current text limit for an edit control
; Syntax.........: _GUICtrlEdit_GetLimitText($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Text limit
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The text limit is the maximum amount of text, in TCHARs, that the control can contain.
;                  For ANSI text, this is the number of bytes; for Unicode text, this is the number of characters.
;                  Two documents with the same character limit will yield the same text limit, even if one is ANSI
;                  and the other is Unicode.
; Related .......: _GUICtrlEdit_SetLimitText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_GetLimitText($hWnd)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $EM_GETLIMITTEXT)
EndFunc   ;==>_GUICtrlEdit_GetLimitText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_GetLine
; Description ...: Retrieves a line of text from an edit control
; Syntax.........: _GUICtrlEdit_GetLine($hWnd, $iLine)
; Parameters ....: $hWnd        - Handle to the control
;                  $iLine       - Zero-based line index to get
; Return values .: Success      - The line of text
;                  Failure      - Empty string
; Author ........: Gary Frost (gafrost), Jos van der Zande <jdeb at autoitscript com >
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_GetLine($hWnd, $iLine)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $iLength = _GUICtrlEdit_LineLength($hWnd, $iLine)
	If $iLength = 0 Then Return ""
	Local $tBuffer = DllStructCreate("short Len;wchar Text[" & $iLength & "]")
	DllStructSetData($tBuffer, "Len", $iLength + 1)
	Local $iRet = _SendMessage($hWnd, $EM_GETLINE, $iLine, $tBuffer, 0, "wparam", "struct*")

	If $iRet = 0 Then Return SetError($EC_ERR, $EC_ERR, "")

	Local $tText = DllStructCreate("wchar Text[" & $iLength & "]", DllStructGetPtr($tBuffer))
	Return DllStructGetData($tText, "Text")
EndFunc   ;==>_GUICtrlEdit_GetLine

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_GetLineCount
; Description ...: Retrieves the number of lines
; Syntax.........: _GUICtrlEdit_GetLineCount($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Total number of text lines
;                  Failure      - 1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If the control has no text, the return value is 1.
;                  The return value will never be less than 1.
;+
;                  The _GUICtrlEdit_GetLineCount retrieves the total number of text lines, not just the number of lines
;                  that are currently visible.
;+
;                  If the Wordwrap feature is enabled, the number of lines can change when the dimensions of the editing
;                  window change
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_GetLineCount($hWnd)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $EM_GETLINECOUNT)
EndFunc   ;==>_GUICtrlEdit_GetLineCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_GetMargins
; Description ...: Retrieves the widths of the left and right margins
; Syntax.........: _GUICtrlEdit_GetMargins($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Array in the following format:
;                  |[0]         - The width of the left margin
;                  |[1]         - The width of the right margin
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlEdit_SetMargins
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_GetMargins($hWnd)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $aMargins[2]
	Local $iMargins = _SendMessage($hWnd, $EM_GETMARGINS)
	$aMargins[0] = _WinAPI_LoWord($iMargins) ; Left Margin
	$aMargins[1] = _WinAPI_HiWord($iMargins) ; Right Margin
	Return $aMargins
EndFunc   ;==>_GUICtrlEdit_GetMargins

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_GetModify
; Description ...: Retrieves the state of an edit control's modification flag
; Syntax.........: _GUICtrlEdit_GetModify($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Return values as follows:
;                  | True       - Edit control contents have been modified
;                  |False       - Edit control contents have not been modified
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The system automatically clears the modification flag to zero when the control is created
;                  If the user changes the control's text, the system sets the flag to True
;                  You can call _GUICtrlEdit_SetModify to set or clear the flag
; Related .......: _GUICtrlEdit_CanUndo, _GUICtrlEdit_SetModify, _GUICtrlEdit_Undo
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_GetModify($hWnd)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $EM_GETMODIFY) <> 0
EndFunc   ;==>_GUICtrlEdit_GetModify

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_GetPasswordChar
; Description ...: Gets the password character that an edit control displays when the user enters text
; Syntax.........: _GUICtrlEdit_GetPasswordChar($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The return value specifies the character to be displayed in place of any characters typed by the user
;                  |If the return value is 0, there is no password character, and the control displays the characters typed by the user
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlEdit_SetPasswordChar
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_GetPasswordChar($hWnd)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $EM_GETPASSWORDCHAR)
EndFunc   ;==>_GUICtrlEdit_GetPasswordChar

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_GetRECT
; Description ...: Retrieves the formatting rectangle of an edit control
; Syntax.........: _GUICtrlEdit_GetRECT($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Array containing the RECT in the following format:
;                  |[0] - X coordinate of the upper left corner of the rectangle
;                  |[1] - Y coordinate of the upper left corner of the rectangle
;                  |[2] - X coordinate of the lower right corner of the rectangle
;                  |[3] - Y coordinate of the lower right corner of the rectangle
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Under certain conditions, _GUICtrlEdit_GetRECT might not return the exact values that
;                  _GUICtrlEdit_SetRECT set—it will be approximately correct, but it can be off by a few pixels.
; Related .......: _GUICtrlEdit_GetRECTEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_GetRECT($hWnd)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $aRect[4]

	Local $tRect = _GUICtrlEdit_GetRECTEx($hWnd)
	$aRect[0] = DllStructGetData($tRect, "Left")
	$aRect[1] = DllStructGetData($tRect, "Top")
	$aRect[2] = DllStructGetData($tRect, "Right")
	$aRect[3] = DllStructGetData($tRect, "Bottom")
	Return $aRect
EndFunc   ;==>_GUICtrlEdit_GetRECT

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_GetRECTEx
; Description ...: Retrieves the formatting rectangle of an edit control
; Syntax.........: _GUICtrlEdit_GetRECTEx($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - $tagRECT structure that recieves formatting rectangle of an edit control
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Under certain conditions, _GUICtrlEdit_GetRECT might not return the exact values that
;                  _GUICtrlEdit_SetRECTEx set—it will be approximately correct, but it can be off by a few pixels.
; Related .......: _GUICtrlEdit_GetRECT, $tagRECT
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_GetRECTEx($hWnd)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tRect = DllStructCreate($tagRECT)
	_SendMessage($hWnd, $EM_GETRECT, 0, $tRect, 0, "wparam", "struct*")
	Return $tRect
EndFunc   ;==>_GUICtrlEdit_GetRECTEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_GetSel
; Description ...: Retrieves the starting and ending character positions of the current selection
; Syntax.........: _GUICtrlEdit_GetSel($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Array in the following format:
;                  |[0]         - Starting position
;                  |[1]         - Ending position
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlEdit_ReplaceSel, _GUICtrlEdit_SetSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_GetSel($hWnd)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $aSel[2]
	Local $wparam = DllStructCreate("uint Start")
	Local $lparam = DllStructCreate("uint End")
	_SendMessage($hWnd, $EM_GETSEL, $wparam, $lparam, 0, "struct*", "struct*")
	$aSel[0] = DllStructGetData($wparam, "Start")
	$aSel[1] = DllStructGetData($lparam, "End")
	Return $aSel
EndFunc   ;==>_GUICtrlEdit_GetSel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_GetText
; Description ...: Get the text from the edit control
; Syntax.........: _GUICtrlEdit_GetText($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - String from the edit control
;                  Failure      - Empty string
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlEdit_SetText, _GUICtrlEdit_AppendText, _GUICtrlEdit_GetTextLen
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_GetText($hWnd)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $iTextLen = _GUICtrlEdit_GetTextLen($hWnd) + 1
	Local $tText = DllStructCreate("wchar Text[" & $iTextLen & "]")
	_SendMessage($hWnd, $__EDITCONSTANT_WM_GETTEXT, $iTextLen, $tText, 0, "wparam", "struct*")
	Return DllStructGetData($tText, "Text")
EndFunc   ;==>_GUICtrlEdit_GetText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_GetTextLen
; Description ...: Get the length of all the text from the edit control
; Syntax.........: _GUICtrlEdit_GetTextLen($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - Length of text in edit control
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlEdit_GetText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_GetTextLen($hWnd)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $__EDITCONSTANT_WM_GETTEXTLENGTH)
EndFunc   ;==>_GUICtrlEdit_GetTextLen

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlEdit_GetThumb
; Description ...: Retrieves the position of the scroll box (thumb) in the vertical scroll
; Syntax.........: _GUICtrlEdit_GetThumb($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The position of the scroll box
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: I think WM_VSCROLL events probably work better
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlEdit_GetThumb($hWnd)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $EM_GETTHUMB)
EndFunc   ;==>_GUICtrlEdit_GetThumb

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlEdit_GetWordBreakProc
; Description ...: Retrieves the address of the current Wordwrap function
; Syntax.........: _GUICtrlEdit_GetWordBreakProc($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The address of the application-defined Wordwrap function
;                  Failure      - 0
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlEdit_SetWordBreakProc
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlEdit_GetWordBreakProc($hWnd)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $EM_GETWORDBREAKPROC)
EndFunc   ;==>_GUICtrlEdit_GetWordBreakProc

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_HideBalloonTip
; Description ...: Hides any balloon tip associated with an edit control
; Syntax.........: _GUICtrlEdit_HideBalloonTip($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success - True
;                  Failure - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Minimun OS Windows XP
; Related .......: _GUICtrlEdit_ShowBalloonTip
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_HideBalloonTip($hWnd)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $EM_HIDEBALLOONTIP) <> 0
EndFunc   ;==>_GUICtrlEdit_HideBalloonTip

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_InsertText
; Description ...: Insert text
; Syntax.........: _GUICtrlEdit_InsertText($hWnd, $sText, $iIndex = -1)
; Parameters ....: $hWnd        - Handle to the control
;                  $sText       - String to insert
;                  $iIndex      - character position to insert
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlEdit_AppendText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_InsertText($hWnd, $sText, $iIndex = -1)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	If $iIndex = -1 Then
		_GUICtrlEdit_AppendText($hWnd, $sText)
	Else
		_GUICtrlEdit_SetSel($hWnd, $iIndex, $iIndex)
		_SendMessage($hWnd, $EM_REPLACESEL, True, $sText, 0, "wparam", "wstr")
	EndIf
EndFunc   ;==>_GUICtrlEdit_InsertText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_LineFromChar
; Description ...: Retrieves the index of the line that contains the specified character index
; Syntax.........: _GUICtrlEdit_LineFromChar($hWnd[, $iIndex = -1])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - The character index of the character contained in the line whose number is to be retrieved
; Return values .: Success      - Zero-based line number of the line containing the character index specified by $iIndex
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If $iIndex is –1, _GUICtrlEdit_LineFromChar retrieves either the line number of the current line
;                  (the line containing the caret) or, if there is a selection, the line number of the line containing
;                   the beginning of the selection.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_LineFromChar($hWnd, $iIndex = -1)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $EM_LINEFROMCHAR, $iIndex)
EndFunc   ;==>_GUICtrlEdit_LineFromChar

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_LineIndex
; Description ...: Retrieves the character index of the first character of a specified line
; Syntax.........: _GUICtrlEdit_LineIndex($hWnd[, $iIndex = 0])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Specifies the zero-based line number
; Return values .: Success      - the character index of the line specified in the $iIndex parameter
;                  Failure      - –1 if the specified line number is greater than the number of lines in the edit control
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: $iIndex = –1 specifies the current line number (the line that contains the caret)
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_LineIndex($hWnd, $iIndex = -1)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $EM_LINEINDEX, $iIndex)
EndFunc   ;==>_GUICtrlEdit_LineIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_LineLength
; Description ...: Retrieves the length, in characters, of a line
; Syntax.........: _GUICtrlEdit_LineLength($hWnd[, $iIndex = -1])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Specifies the zero-based line index of the line whose length is to be retrieved
; Return values .: Success      - The length, in TCHARs, of the line specified by the $iIndex parameter
;                  Failure      - 0 If $iIndex is greater than the number of characters in the control
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: $iIndex = –1 specifies the current line number (the line that contains the caret)
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_LineLength($hWnd, $iIndex = -1)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $CharIndex = _GUICtrlEdit_LineIndex($hWnd, $iIndex)
	Return _SendMessage($hWnd, $EM_LINELENGTH, $CharIndex)
EndFunc   ;==>_GUICtrlEdit_LineLength

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_LineScroll
; Description ...: Scrolls the text
; Syntax.........: _GUICtrlEdit_LineScroll($hWnd, $iHoriz, $iVert)
; Parameters ....: $hWnd        - Handle to the control
;                  $iHoriz      - Specifies the number of characters to scroll horizontally.
;                  $iVert       - Specifies the number of lines to scroll vertically.
; Return values .: Success      -  True
;                  Failure      -  False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The control does not scroll vertically past the last line of text in the edit control.
;+
;                  If the current line plus the number of lines specified by the $iVert parameter exceeds the total number
;                  of lines in the edit control, the value is adjusted so that the last line of the edit control is scrolled
;                  to the top of the edit-control window.
;+
;                  _GUICtrlEdit_LineScroll scrolls the text vertically or horizontally.
;                  _GUICtrlEdit_LineScroll can be used to scroll horizontally past the last character of any line.
; Related .......: _GUICtrlEdit_Scroll
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_LineScroll($hWnd, $iHoriz, $iVert)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $EM_LINESCROLL, $iHoriz, $iVert) <> 0
EndFunc   ;==>_GUICtrlEdit_LineScroll

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_PosFromChar
; Description ...: Retrieves the client area coordinates of a specified character in an edit control
; Syntax.........: _GUICtrlEdit_PosFromChar($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - The zero-based index of the character
; Return values .: Success      - Array in the following format:
;                  |[0] - The horizontal coordinate
;                  |[1] - The vertical coordinate
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_PosFromChar($hWnd, $iIndex)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $aCoord[2]
	Local $iRet = _SendMessage($hWnd, $EM_POSFROMCHAR, $iIndex)
	$aCoord[0] = _WinAPI_LoWord($iRet)
	$aCoord[1] = _WinAPI_HiWord($iRet)
	Return $aCoord
EndFunc   ;==>_GUICtrlEdit_PosFromChar

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_ReplaceSel
; Description ...: Replaces the current selection
; Syntax.........: _GUICtrlEdit_ReplaceSel($hWnd, $sText[, $fUndo = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $sText       - String containing the replacement text.
;                  $fUndo       - Specifies whether the replacement operation can be undone:
;                  | True       - The operation can be undone.
;                  |False       - The operation cannot be undone.
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Use the _GUICtrlEdit_ReplaceSel to replace only a portion of the text in an edit control.
;                  If there is no current selection, the replacement text is inserted at the current location of the caret.
; Related .......: _GUICtrlEdit_GetSel, _GUICtrlEdit_SetSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_ReplaceSel($hWnd, $sText, $fUndo = True)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $EM_REPLACESEL, $fUndo, $sText, 0, "wparam", "wstr")
EndFunc   ;==>_GUICtrlEdit_ReplaceSel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_Scroll
; Description ...: Scrolls the text vertically
; Syntax.........: _GUICtrlEdit_Scroll($hWnd, $iDirection)
; Parameters ....: $hWnd        - Handle to the control
;                  $iDirection  - This parameter can be one of the following values:
;                  |$SB_LINEDOWN    - Scrolls down one line
;                  |$SB_LINEUP      - Scrolls up one line
;                  |$SB_PAGEDOWN    - Scrolls down one page
;                  |$SB_PAGEUP      - Scrolls up one page
;                  |$SB_SCROLLCARET - Scrolls the caret into view
; Return values .: Success      - The high-order word of the return value is TRUE
;                  +The low-order word is the number of lines that the command scrolls
;                  Failure      - 0
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: $SB_xxxxx require include of ScrollBarConstants.au3
; Related .......: _GUICtrlEdit_LineScroll
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_Scroll($hWnd, $iDirection)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	If BitAND($iDirection, $__EDITCONSTANT_SB_LINEDOWN) <> $__EDITCONSTANT_SB_LINEDOWN And _
			BitAND($iDirection, $__EDITCONSTANT_SB_LINEUP) <> $__EDITCONSTANT_SB_LINEUP And _
			BitAND($iDirection, $__EDITCONSTANT_SB_PAGEDOWN) <> $__EDITCONSTANT_SB_PAGEDOWN And _
			BitAND($iDirection, $__EDITCONSTANT_SB_PAGEUP) <> $__EDITCONSTANT_SB_PAGEUP And _
			BitAND($iDirection, $__EDITCONSTANT_SB_SCROLLCARET) <> $__EDITCONSTANT_SB_SCROLLCARET Then Return 0

	If $iDirection == $__EDITCONSTANT_SB_SCROLLCARET Then
		Return _SendMessage($hWnd, $EM_SCROLLCARET)
	Else
		Return _SendMessage($hWnd, $EM_SCROLL, $iDirection)
	EndIf
EndFunc   ;==>_GUICtrlEdit_Scroll

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlEdit_SetHandle
; Description ...: Sets the handle of the memory that will be used
; Syntax.........: _GUICtrlEdit_SetHandle($hWnd, $hMemory)
; Parameters ....: $hWnd        - Handle to the control
;                  $hMemory     - A handle to the memory buffer the edit control uses to store the currently displayed text
;                  +instead of allocating its own memory
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlEdit_GetHandle
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlEdit_SetHandle($hWnd, $hMemory)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $EM_SETHANDLE, $hMemory, 0, 0, "handle")
EndFunc   ;==>_GUICtrlEdit_SetHandle

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlEdit_SetIMEStatus
; Description ...: Sets the status flags that determine how an edit control interacts with the Input Method Editor (IME)
; Syntax.........: _GUICtrlEdit_SetIMEStatus($hWnd, $iComposition)
; Parameters ....: $hWnd         - Handle to the control
;                  $iComposition - One or more of the following:
;                  |$EIMES_GETCOMPSTRATONCE - The edit control hooks the WM_IME_COMPOSITION message
;                  |$EIMES_CANCELCOMPSTRINFOCUS - The edit control cancels the composition string when it receives the WM_SETFOCUS message
;                  |$EIMES_COMPLETECOMPSTRKILLFOCUS - The edit control completes the composition string upon receiving the WM_KILLFOCUS message
; Return values .: Success      - the previous value of the $iComposition parameter
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlEdit_SetIMEStatus($hWnd, $iComposition)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $EM_SETIMESTATUS, $EMSIS_COMPOSITIONSTRING, $iComposition)
EndFunc   ;==>_GUICtrlEdit_SetIMEStatus

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_SetLimitText
; Description ...: Sets the text limit
; Syntax.........: _GUICtrlEdit_SetLimitText($hWnd, $iLimit)
; Parameters ....: $hWnd        - Handle to the control
;                  $iLimit      - The maximum number of TCHARs the user can enter
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The _GUICtrlEdit_SetLimitText function limits only the text the user can enter.
;                  It does not affect any text already in the edit control when the message is sent, nor does it affect
;                  the length of the text copied to the edit control by the _GUICtrlEdit_SetText function.
;                  If an application uses the _GUICtrlEdit_SetText function to place more text into an edit control than
;                  is specified in the _GUICtrlEdit_SetLimitText function, the user can edit the entire contents of the
;                  edit control.
; Related .......: _GUICtrlEdit_GetLimitText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_SetLimitText($hWnd, $iLimit)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $EM_SETLIMITTEXT, $iLimit)
EndFunc   ;==>_GUICtrlEdit_SetLimitText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_SetMargins
; Description ...: Sets the widths of the left and right margins
; Syntax.........: _GUICtrlEdit_SetMargins($hWnd[, $iMargin = 0x1[, $iLeft = 0xFFFF[, $iRight = 0xFFFF]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $iMargin     - Can be one or more of the following
;                  |$EC_LEFTMARGIN  - Sets the left margin
;                  |$EC_RIGHTMARGIN - Sets the right margin
;                  -
;                  |Default: $EC_LEFTMARGIN
;                  $iLeft       - The new width of the left margin
;                  -
;                  |Default: $EC_USEFONTINFO
;                  $iRight      - The new width of the right margin
;                  -
;                  |Default: $EC_USEFONTINFO
; Return values .: Success      -
;                  Failure      -
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlEdit_GetMargins
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_SetMargins($hWnd, $iMargin = 0x1, $iLeft = 0xFFFF, $iRight = 0xFFFF)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $EM_SETMARGINS, $iMargin, _WinAPI_MakeLong($iLeft, $iRight))
EndFunc   ;==>_GUICtrlEdit_SetMargins

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_SetModify
; Description ...: Sets or clears the modification flag
; Syntax.........: _GUICtrlEdit_SetModify($hWnd, $fModified)
; Parameters ....: $hWnd        - Handle to the control
;                  $fModified   - Specifies the new value for the modification flag:
;                  | True       - Indicates the text has been modified.
;                  |False       - Indicates it has not been modified.
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The system automatically clears the modification flag to zero when the control is created.
;                  If the user changes the control's text, the system sets the flag to nonzero.
;                  You can use the _GUICtrlEdit_GetModify to retrieve the current state of the flag.
; Related .......: _GUICtrlEdit_GetModify, _GUICtrlEdit_CanUndo
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_SetModify($hWnd, $fModified)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $EM_SETMODIFY, $fModified)
EndFunc   ;==>_GUICtrlEdit_SetModify

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_SetPasswordChar
; Description ...: Sets or removes the password character for an edit control
; Syntax.........: _GUICtrlEdit_SetPasswordChar($hWnd[, $cDisplayChar = "0"])
; Parameters ....: $hWnd         - Handle to the control
;                  $cDisplayChar - The character to be displayed in place of the characters typed by the user
;                  |If this parameter is zero, the control removes the current password character and displays the characters typed by the user
; Return values .:
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlEdit_GetPasswordChar
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_SetPasswordChar($hWnd, $cDisplayChar = "0")
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	$cDisplayChar = StringLeft($cDisplayChar, 1)
	If Asc($cDisplayChar) = 48 Then
		_SendMessage($hWnd, $EM_SETPASSWORDCHAR)
	Else
		_SendMessage($hWnd, $EM_SETPASSWORDCHAR, Asc($cDisplayChar))
	EndIf
EndFunc   ;==>_GUICtrlEdit_SetPasswordChar

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_SetReadOnly
; Description ...: Sets or removes the read-only style ($ES_READONLY)
; Syntax.........: _GUICtrlEdit_SetReadOnly($hWnd, $fReadOnly)
; Parameters ....: $hWnd        - Handle to the control
;                  $fReadOnly   - Followin values:
;                  | True       - Sets the $ES_READONLY style
;                  |False       - Removes the $ES_READONLY style
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_SetReadOnly($hWnd, $fReadOnly)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $EM_SETREADONLY, $fReadOnly) <> 0
EndFunc   ;==>_GUICtrlEdit_SetReadOnly

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_SetRECT
; Description ...: Sets the formatting rectangle of a multiline edit control
; Syntax.........: _GUICtrlEdit_SetRECT($hWnd, $aRect)
; Parameters ....: $hWnd        - Handle to the control
;                  $aRect       - Array in the following format:
;                  |[0]         - Specifies the x-coordinate of the upper-left corner of the rectangle.
;                  |[1]         - Specifies the y-coordinate of the upper-left corner of the rectangle.
;                  |[2]         - Specifies the x-coordinate of the lower-right corner of the rectangle.
;                  |[3]         - Specifies the y-coordinate of the lower-right corner of the rectangle.
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlEdit_SetRectEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_SetRECT($hWnd, $aRect)
	Local $tRect = DllStructCreate($tagRECT)
	DllStructSetData($tRect, "Left", $aRect[0])
	DllStructSetData($tRect, "Top", $aRect[1])
	DllStructSetData($tRect, "Right", $aRect[2])
	DllStructSetData($tRect, "Bottom", $aRect[3])
	_GUICtrlEdit_SetRECTEx($hWnd, $tRect)
EndFunc   ;==>_GUICtrlEdit_SetRECT

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_SetRECTEx
; Description ...: Sets the formatting rectangle of a multiline edit control
; Syntax.........: _GUICtrlEdit_SetRECTEx($hWnd, $tRect)
; Parameters ....: $hWnd        - Handle to the control
;                  $tRect       - $tagRECT structure that contains formatting rectangle of an edit control
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlEdit_SetRect, $tagRECT
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_SetRECTEx($hWnd, $tRect)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $EM_SETRECT, 0, $tRect, 0, "wparam", "struct*")
EndFunc   ;==>_GUICtrlEdit_SetRECTEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_SetRECTNP
; Description ...: Sets the formatting rectangle of a multiline edit control
; Syntax.........: _GUICtrlEdit_SetRECTNP($hWnd, $aRect)
; Parameters ....: $hWnd        - Handle to the control
;                  $aRect       - Array in the following format:
;                  |[0]         - Specifies the x-coordinate of the upper-left corner of the rectangle.
;                  |[1]         - Specifies the y-coordinate of the upper-left corner of the rectangle.
;                  |[2]         - Specifies the x-coordinate of the lower-right corner of the rectangle.
;                  |[3]         - Specifies the y-coordinate of the lower-right corner of the rectangle.
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The _GUICtrlEdit_SetRECTNP function is identical to the _GUICtrlEdit_SetRECT function,
;                  except that _GUICtrlEdit_SetRECTNP does not redraw the edit control window.
; Related .......: _GUICtrlEdit_SetRectNPEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_SetRECTNP($hWnd, $aRect)
	Local $tRect = DllStructCreate($tagRECT)
	DllStructSetData($tRect, "Left", $aRect[0])
	DllStructSetData($tRect, "Top", $aRect[1])
	DllStructSetData($tRect, "Right", $aRect[2])
	DllStructSetData($tRect, "Bottom", $aRect[3])
	_GUICtrlEdit_SetRectNPEx($hWnd, $tRect)
EndFunc   ;==>_GUICtrlEdit_SetRECTNP

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_SetRectNPEx
; Description ...: Sets the formatting rectangle of a multiline edit control
; Syntax.........: _GUICtrlEdit_SetRectNPEx($hWnd, $tRect)
; Parameters ....: $hWnd        - Handle to the control
;                  $tRect       - $tagRECT structure that contains formatting rectangle of an edit control
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The _GUICtrlEdit_SetRECTNPEx function is identical to the _GUICtrlEdit_SetRECTEx function,
;                  except that _GUICtrlEdit_SetRECTNPEx does not redraw the edit control window.
; Related .......: _GUICtrlEdit_SetRectNP, $tagRECT
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_SetRectNPEx($hWnd, $tRect)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $EM_SETRECTNP, 0, $tRect, 0, "wparam", "struct*")
EndFunc   ;==>_GUICtrlEdit_SetRectNPEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_SetSel
; Description ...: Selects a range of characters
; Syntax.........: _GUICtrlEdit_SetSel($hWnd, $iStart, $iEnd)
; Parameters ....: $hWnd        - Handle to the control
;                  $iStart      - Specifies the starting character position of the selection.
;                  $iEnd        - Specifies the ending character position of the selection.
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The start value can be greater than the end value.
;                  The lower of the two values specifies the character position of the first character in the selection.
;                  The higher value specifies the position of the first character beyond the selection.
;+
;                  The start value is the anchor point of the selection, and the end value is the active end.
;                  If the user uses the SHIFT key to adjust the size of the selection, the active end can move but the
;                  anchor point remains the same.
;+
;                  If the $iStart is 0 and the $iEnd is –1, all the text in the edit control is selected.
;                  If the $iStart is –1, any current selection is deselected.
;+
;                  The control displays a flashing caret at the $iEnd position regardless of the relative values of $iStart and $iEnd.
; Related .......: _GUICtrlEdit_GetSel, _GUICtrlEdit_ReplaceSel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_SetSel($hWnd, $iStart, $iEnd)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $EM_SETSEL, $iStart, $iEnd)
EndFunc   ;==>_GUICtrlEdit_SetSel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_SetTabStops
; Description ...: Sets the tab stops
; Syntax.........: _GUICtrlEdit_SetTabStops($hWnd, $aTabStops)
; Parameters ....: $hWnd        - Handle to the control
;                  $aTabStops   - Array of tab stops in the following format:
;                  |[0]         - Tab stop 1
;                  |[2]         - Tab stop 2
;                  |[n]         - Tab stop n
; Return values .: True         - All the tabs are set
;                  False        - All the tabs are not set
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_SetTabStops($hWnd, $aTabStops)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	If Not IsArray($aTabStops) Then Return SetError(-1, -1, False)

	Local $sTabStops = ""
	Local $iNumTabStops = UBound($aTabStops)

	For $x = 0 To $iNumTabStops - 1
		$sTabStops &= "int;"
	Next
	$sTabStops = StringTrimRight($sTabStops, 1)
	Local $tTabStops = DllStructCreate($sTabStops)
	For $x = 0 To $iNumTabStops - 1
		DllStructSetData($tTabStops, $x + 1, $aTabStops[$x])
	Next
	Local $iRet = _SendMessage($hWnd, $EM_SETTABSTOPS, $iNumTabStops, $tTabStops, 0, "wparam", "struct*") <> 0
	_WinAPI_InvalidateRect($hWnd)
	Return $iRet
EndFunc   ;==>_GUICtrlEdit_SetTabStops

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_SetText
; Description ...: Set the text
; Syntax.........: _GUICtrlEdit_SetText($hWnd, $sText)
; Parameters ....: $hWnd        - Handle to control
;                  $sText       - String to place in edit control
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlEdit_GetText, _GUICtrlEdit_AppendText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_SetText($hWnd, $sText)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $__EDITCONSTANT_WM_SETTEXT, 0, $sText, 0, "wparam", "wstr")
EndFunc   ;==>_GUICtrlEdit_SetText

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlEdit_SetWordBreakProc
; Description ...: Replaces an edit control's default Wordwrap function with an application-defined Wordwrap function
; Syntax.........: _GUICtrlEdit_SetWordBreakProc($hWnd, $iAddressFunc)
; Parameters ....: $hWnd         - Handle to the control
;                  $iAddressFunc - The address of the application-defined Wordwrap function
; Return values .:
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlEdit_GetWordBreakProc
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlEdit_SetWordBreakProc($hWnd, $iAddressFunc)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_SendMessage($hWnd, $EM_SETWORDBREAKPROC, 0, $iAddressFunc)
EndFunc   ;==>_GUICtrlEdit_SetWordBreakProc

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_ShowBalloonTip
; Description ...: Displays a balloon tip associated with an edit control
; Syntax.........: _GUICtrlEdit_ShowBalloonTip($hWnd, $sTitle, $sText, $iIcon)
; Parameters ....: $hWnd         - Handle to the control
;                  $sTitle       - String for title of ToolTip (Unicode)
;                  $sText        - String for text of ToolTip (Unicode)
;                  $iIcon        - Icon can be one of the following:
;                  |$TTI_ERROR   - Use the error icon
;                  |$TTI_INFO    - Use the information icon
;                  |$TTI_NONE    - Use no icon
;                  |$TTI_WARNING - Use the warning icon
;                  |The following for Vista and above OS
;                  |$TTI_ERROR_LARGE - Use the error icon
;                  |$TTI_INFO_LARGE - Use the information icon
;                  |$TTI_WARNING_LARGE - Use the warning icon
; Return values .: Success       - True
;                  Failure       - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Minimun OS Windows XP
; Related .......: _GUICtrlEdit_HideBalloonTip
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_ShowBalloonTip($hWnd, $sTitle, $sText, $iIcon)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tTitle = _WinAPI_MultiByteToWideChar($sTitle)
	Local $tText = _WinAPI_MultiByteToWideChar($sText)
	Local $tTT = DllStructCreate($tagEDITBALLOONTIP)
	DllStructSetData($tTT, "Size", DllStructGetSize($tTT))
	DllStructSetData($tTT, "Title", DllStructGetPtr($tTitle))
	DllStructSetData($tTT, "Text", DllStructGetPtr($tText))
	DllStructSetData($tTT, "Icon", $iIcon)
	Return _SendMessage($hWnd, $EM_SHOWBALLOONTIP, 0, $tTT, 0, "wparam", "struct*") <> 0
EndFunc   ;==>_GUICtrlEdit_ShowBalloonTip

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlEdit_Undo
; Description ...: Undoes the last edit control operation in the control's undo queue
; Syntax.........: _GUICtrlEdit_Undo($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: An undo operation can also be undone.
;                  For example, you can restore deleted text with the first _GUICtrlEdit_Undo,
;                  and remove the text again with a second _GUICtrlEdit_Undo as long as there
;                  is no intervening edit operation.
; Related .......: _GUICtrlEdit_CanUndo, _GUICtrlEdit_EmptyUndoBuffer, _GUICtrlEdit_GetModify
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlEdit_Undo($hWnd)
	If $Debug_Ed Then __UDF_ValidateClassName($hWnd, $__EDITCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $EM_UNDO) <> 0
EndFunc   ;==>_GUICtrlEdit_Undo
