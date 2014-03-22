#include-once

#include "ButtonConstants.au3"
#include "SendMessage.au3"
#include "WinAPI.au3"
#include "UDFGlobalID.au3"

; #INDEX# =======================================================================================================================
; Title .........: Button
; AutoIt Version : 3.3.7.20++
; Language ......: English
; Description ...: Functions that assist with Button control management.
;                  A button is a control the user can click to provide input to an application.
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $_ghButtonLastWnd
Global $Debug_Btn = False
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $tagBUTTON_IMAGELIST = "ptr ImageList;" & $tagRECT & ";uint Align"
Global Const $tagBUTTON_SPLITINFO = "uint mask;handle himlGlyph;uint uSplitStyle;" & $tagSIZE
;~ mask
;~ A set of flags that specify which members of this structure contain data to be set or which members are being requested. Set this member to one or more of the following flags.
;~ BCSIF_GLYPH
;~ himlGlyph is valid.
;~ BCSIF_IMAGE
;~ himlGlyph is valid. Use when uSplitStyle is set to BCSS_IMAGE.
;~ BCSIF_SIZE
;~ size is valid.
;~ BCSIF_STYLE
;~ uSplitStyle is valid.
;~ himlGlyph
;~ A handle to the image list. The provider retains ownership of the image list and is ultimately responsible for its disposal.
;~ uSplitStyle
;~ The split button style. Value must be one or more of the following flags.
;~ BCSS_ALIGNLEFT
;~ Align the image or glyph horizontally with the left margin.
;~ BCSS_IMAGE
;~ Draw an icon image as the glyph.
;~ BCSS_NOSPLIT
;~ No split.
;~ BCSS_STRETCH
;~ Stretch glyph, but try to retain aspect ratio.
;~ size
; Fields ........: X - Width
;                  Y - Height

Global Const $__BUTTONCONSTANT_ClassName = "Button"

Global Const $__BUTTONCONSTANT_GWL_STYLE = 0xFFFFFFF0
Global Const $__BUTTONCONSTANT_LR_LOADFROMFILE = 0x0010
Global Const $__BUTTONCONSTANT_LR_CREATEDIBSECTION = 0x2000

Global Const $__BUTTONCONSTANT_WS_TABSTOP = 0x00010000
Global Const $__BUTTONCONSTANT_WM_SETFONT = 0x0030
Global Const $__BUTTONCONSTANT_DEFAULT_GUI_FONT = 17
; ===============================================================================================================================

; #NO_DOC_FUNCTION# =============================================================================================================
; Not working/documented/implemented at this time
;
;_GUICtrlButton_SetDropDownState
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_GUICtrlButton_Click
;_GUICtrlButton_Create
;_GUICtrlButton_Destroy
;_GUICtrlButton_Enable
;_GUICtrlButton_GetCheck
;_GUICtrlButton_GetFocus
;_GUICtrlButton_GetIdealSize
;_GUICtrlButton_GetImage
;_GUICtrlButton_GetImageList
;_GUICtrlButton_GetNote
;_GUICtrlButton_GetNoteLength
;_GUICtrlButton_GetSplitInfo
;_GUICtrlButton_GetState
;_GUICtrlButton_GetText
;_GUICtrlButton_GetTextMargin
;_GUICtrlButton_SetCheck
;_GUICtrlButton_SetDontClick
;_GUICtrlButton_SetFocus
;_GUICtrlButton_SetImage
;_GUICtrlButton_SetImageList
;_GUICtrlButton_SetNote
;_GUICtrlButton_SetShield
;_GUICtrlButton_SetSize
;_GUICtrlButton_SetSplitInfo
;_GUICtrlButton_SetState
;_GUICtrlButton_SetStyle
;_GUICtrlButton_SetText
;_GUICtrlButton_SetTextMargin
;_GUICtrlButton_Show
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_Click
; Description ...: Simulates the user clicking a button
; Syntax.........: _GUICtrlButton_Click($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .:
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: If the button is in a dialog box and the dialog box is not active, the _GUICtrlButton_Click might fail.
;                  To ensure success in this situation, call the WinActivate function to activate the dialog box before sending
;                  the _GUICtrlButton_Click to the button.
; Related .......:
; Link ..........:  @@MsdnLink@@ BM_CLICK
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_Click($hWnd)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	_SendMessage($hWnd, $BM_CLICK)
EndFunc   ;==>_GUICtrlButton_Click

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_Create
; Description ...: Creates a Button control
; Syntax.........: _GUICtrlButton_Create($hWnd, $sText, $iX, $iY, $iWidth, $iHeight[, $iStyle = -1[, $iExStyle = -1]])
; Parameters ....: $hWnd                       - Handle to parent or owner window
;                  $sText                      - Text to add to Button
;                  $iX                         - Horizontal position of the control
;                  $iY                         - Vertical position of the control
;                  $iWidth                     - Control width
;                  $iHeight                    - Control height
;                  $iStyle                     - Control style:
;                  |  $BS_AUTO3STATE      - Creates a three-state check box in which the state cycles through selected, unavailable, and cleared each time the user selects the check box.
;                  |  $BS_AUTOCHECKBOX    - Creates a check box in which the check state switches between selected and cleared each time the user selects the check box.
;                  |  $BS_AUTORADIOBUTTON - Same as a radio button, except that when the user selects it, the button automatically highlights itself and removes the selection from any other radio buttons with the same style in the same group.
;                  |  $BS_FLAT            - Specifies that the button is two-dimensional; it does not use the default shading to create a 3-D image.
;                  |  $BS_GROUPBOX        - Creates a rectangle in which other buttons can be grouped. Any text associated with this style is displayed in the rectangle’s upper-left corner.
;                  |  $BS_PUSHLIKE        - Makes a button (such as a check box, three-state check box, or radio button) look and act like a push button. The button looks raised when it isn't pushed or checked, and sunken when it is pushed or checked.
;                  -
;                  |  $BS_DEFPUSHBUTTON   - Creates a push button with a heavy black border. If the button is in a dialog box, the user can select the button by pressing the ENTER key, even when the button does not have the input focus. This style is useful for enabling the user to quickly select the most likely option, or default.
;                  -
;                  |  $BS_BOTTOM          - Places the text at the bottom of the button rectangle.
;                  |  $BS_CENTER          - Centers the text horizontally in the button rectangle.
;                  |  $BS_LEFT            - Left-aligns the text in the button rectangle on the right side of the check box.
;                  |  $BS_MULTILINE       - Wraps the button text to multiple lines if the text string is too long to fit on a single line in the button rectangle.
;                  |  $BS_RIGHT           - Right-aligns text in the button rectangle on the right side of the check box.
;                  |  $BS_RIGHTBUTTON     - Positions a check box square on the right side of the button rectangle.
;                  |  $BS_TOP             - Places text at the top of the button rectangle.
;                  |  $BS_VCENTER         - Vertically centers text in the button rectangle.
;                  -
;                  |  $BS_ICON            - Specifies that the button displays an icon.
;                  |  $BS_BITMAP          - Specifies that the button displays a bitmap.
;                  -
;                  |  $BS_NOTIFY          - Enables a button to send BN_KILLFOCUS and BN_SETFOCUS notification messages to its parent window. Note that buttons send the BN_CLICKED notification message regardless of whether it has this style. To get BN_DBLCLK notification messages, the button must have the BS_RADIOBUTTON or BS_OWNERDRAW style.
;                  -
;                  |  Vista Sytles:
;                  |    $BS_SPLITBUTTON    - Creates a split button. A split button has a drop down arrow
;                  |    $BS_DEFSPLITBUTTON - Creates a split button that behaves like a $BS_PUSHBUTTON style button, but also has a distinctive appearance.
;                  |    $BS_COMMANDLINK    - Creates a command link button
;                  |    $BS_DEFCOMMANDLINK - Creates a command link button that behaves like a $BS_PUSHBUTTON style button.
;                  -
;                  |Default: ( -1) : none
;                  |Forced : $WS_CHILD, $WS_TABSTOP, $WS_VISIBLE, $BS_NOTIFY
;                  -
;                  $iExStyle    - Control extended style. These correspond to the standard $WS_EX_ constants.
; Return values .: Success      - Handle to the Button control
;                  Failure      - 0
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Above constants require ButtonConstants.au3
;+
;                  This function is for Advanced users and for learning how the control works.
; Related .......: _GUICtrlButton_Destroy
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_Create($hWnd, $sText, $iX, $iY, $iWidth, $iHeight, $iStyle = -1, $iExStyle = -1)
	If Not IsHWnd($hWnd) Then
		; Invalid Window handle for _GUICtrlButton_Create 1st parameter
		Return SetError(1, 0, 0)
	EndIf
	If Not IsString($sText) Then
		; 2nd parameter not a string for _GUICtrlButton_Create
		Return SetError(2, 0, 0)
	EndIf

	Local $iForcedStyle = BitOR($__BUTTONCONSTANT_WS_TABSTOP, $__UDFGUICONSTANT_WS_VISIBLE, $__UDFGUICONSTANT_WS_CHILD, $BS_NOTIFY)

	If $iStyle = -1 Then
		$iStyle = $iForcedStyle
	Else
		$iStyle = BitOR($iStyle, $iForcedStyle)
	EndIf
	If $iExStyle = -1 Then $iExStyle = 0
	Local $nCtrlID = __UDF_GetNextGlobalID($hWnd)
	If @error Then Return SetError(@error, @extended, 0)
	Local $hButton = _WinAPI_CreateWindowEx($iExStyle, $__BUTTONCONSTANT_ClassName, $sText, $iStyle, $iX, $iY, $iWidth, $iHeight, $hWnd, $nCtrlID)
	_SendMessage($hButton, $__BUTTONCONSTANT_WM_SETFONT, _WinAPI_GetStockObject($__BUTTONCONSTANT_DEFAULT_GUI_FONT), True)
	Return $hButton
EndFunc   ;==>_GUICtrlButton_Create

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_Destroy
; Description ...: Delete the Button control
; Syntax.........: _GUICtrlButton_Destroy(ByRef $hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True, Handle is set to 0
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Restricted to only be used on Edit created with _GUICtrlButton_Create
; Related .......: _GUICtrlButton_Create
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_Destroy(ByRef $hWnd)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not _WinAPI_IsClassName($hWnd, $__BUTTONCONSTANT_ClassName) Then Return SetError(2, 2, False)

	Local $Destroyed = 0
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_ghButtonLastWnd) Then
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
EndFunc   ;==>_GUICtrlButton_Destroy

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_Enable
; Description ...: Enables or disables mouse and keyboard input to the specified button
; Syntax.........: _GUICtrlButton_Enable($hWnd[, $fEnable = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $fEnable     - Specifies whether to enable or disable the button:
;                  | True - The button is enabled
;                  |False - The button is disabled
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_Enable($hWnd, $fEnable = True)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	If _WinAPI_IsClassName($hWnd, $__BUTTONCONSTANT_ClassName) Then Return _WinAPI_EnableWindow($hWnd, $fEnable) = $fEnable
EndFunc   ;==>_GUICtrlButton_Enable

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_GetCheck
; Description ...: Gets the check state of a radio button or check box
; Syntax.........: _GUICtrlButton_GetCheck($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success - The return value from a button created with the $BS_AUTOCHECKBOX, $BS_AUTORADIOBUTTON,
;                  |$BS_AUTO3STATE, $BS_CHECKBOX, $BS_RADIOBUTTON, or $BS_3STATE style can be one of the following:
;                  |  $BST_CHECKED - Button is checked.
;                  |  $BST_INDETERMINATE - Button is grayed, indicating an indeterminate state (applies only if the button has the $BS_3STATE or $BS_AUTO3STATE style).
;                  |  $BST_UNCHECKED Button is cleared
;                  Failuer - 0
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: If the button has a style other than those listed, the return value is zero.
; Related .......: _GUICtrlButton_GetState, _GUICtrlButton_SetCheck
; Link ..........: @@MsdnLink@@ BM_GETCHECK
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_GetCheck($hWnd)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	Return _SendMessage($hWnd, $BM_GETCHECK)
EndFunc   ;==>_GUICtrlButton_GetCheck

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_GetFocus
; Description ...: Retrieves if the button has keyboard focus
; Syntax.........: _GUICtrlButton_GetFocus($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: True  - Button has focus
;                  False - Button does not have focus
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlButton_SetFocus
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_GetFocus($hWnd)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	If _WinAPI_IsClassName($hWnd, $__BUTTONCONSTANT_ClassName) Then Return _WinAPI_GetFocus() = $hWnd
EndFunc   ;==>_GUICtrlButton_GetFocus

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_GetIdealSize
; Description ...: Gets the size of the button that best fits its text and image, if an image list is present
; Syntax.........: _GUICtrlButton_GetIdealSize($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success - Array containing the followin:
;                  |  [0] - Ideal width
;                  |  [1] - Ideal height
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Minimum Operating Systems: Windows XP
; Related .......: _GUICtrlButton_SetSize
; Link ..........: @@MsdnLink@@ BCM_GETIDEALSIZE
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_GetIdealSize($hWnd)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tSize = DllStructCreate($tagSIZE), $aSize[2]
	Local $iRet = _SendMessage($hWnd, $BCM_GETIDEALSIZE, 0, $tSize, 0, "wparam", "struct*")
	If Not $iRet Then Return SetError(-1, -1, $aSize)
	$aSize[0] = DllStructGetData($tSize, "X")
	$aSize[1] = DllStructGetData($tSize, "Y")
	Return $aSize
EndFunc   ;==>_GUICtrlButton_GetIdealSize

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_GetImage
; Description ...: Retrieves a handle to the image (icon or bitmap) associated with the button
; Syntax.........: _GUICtrlButton_GetImage($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success - Handle to the image
;                  Failure - 0
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlButton_SetImage
; Link ..........: @@MsdnLink@@ BM_GETIMAGE
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_GetImage($hWnd)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	Local $iRet = _SendMessage($hWnd, $BM_GETIMAGE, 0, 0, 0, "wparam", "lparam", "hwnd") ; check IMAGE_BITMAP
	If $iRet <> 0x00000000 Then Return $iRet
	$iRet = _SendMessage($hWnd, $BM_GETIMAGE, 1, 0, 0, "wparam", "lparam", "hwnd") ; check IMAGE_ICON
	If $iRet = 0x00000000 Then Return 0
	Return $iRet
EndFunc   ;==>_GUICtrlButton_GetImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_GetImageList
; Description ...: Retrieves an array that describes the image list assigned to a button control
; Syntax.........: _GUICtrlButton_GetImageList($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success - Array containing the following:
;                  |  [0] - Image list handle
;                  |  [1] - Left margin of the icon
;                  |  [2] - Top margin of the icon
;                  |  [3] - Right margin of the icon
;                  |  [4] - Bottom margin of the icon
;                  |  [5] - Specifies the alignment. This will be one of the following values:
;                  |      0 - Image aligned with the left margin.
;                  |      1 - Image aligned with the right margin.
;                  |      2 - Image aligned with the top margin.
;                  |      3 - Image aligned with the bottom margin.
;                  |      4 - Image centered.
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Minimum Operating Systems: Windows XP
; Related .......: _GUICtrlButton_SetImageList
; Link ..........: @@MsdnLink@@ BCM_GETIMAGELIST
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_GetImageList($hWnd)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	Local $tBUTTON_IMAGELIST = DllStructCreate($tagBUTTON_IMAGELIST), $aImageList[6]
	If Not _SendMessage($hWnd, $BCM_GETIMAGELIST, 0, $tBUTTON_IMAGELIST, 0, "wparam", "struct*") Then Return SetError(-1, -1, $aImageList)
	$aImageList[0] = DllStructGetData($tBUTTON_IMAGELIST, "ImageList")
	$aImageList[1] = DllStructGetData($tBUTTON_IMAGELIST, "Left")
	$aImageList[2] = DllStructGetData($tBUTTON_IMAGELIST, "Right")
	$aImageList[3] = DllStructGetData($tBUTTON_IMAGELIST, "Top")
	$aImageList[4] = DllStructGetData($tBUTTON_IMAGELIST, "Bottom")
	$aImageList[5] = DllStructGetData($tBUTTON_IMAGELIST, "Align")
	Return $aImageList
EndFunc   ;==>_GUICtrlButton_GetImageList

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_GetNote
; Description ...: Gets the text of the note associated with the Command Link button
; Syntax.........: _GUICtrlButton_GetNote($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success - Text associated with the Command Link Button
;                  Failure - ""
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: This function works only with the $BS_COMMANDLINK and $BS_DEFCOMMANDLINK button styles
;+
;                  Minimum Operating Systems: Windows Vista
; Related .......: _GUICtrlButton_SetNote, _GUICtrlButton_GetNoteLength
; Link ..........: @@MsdnLink@@ BCM_GETNOTE
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_GetNote($hWnd)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $iLen = _GUICtrlButton_GetNoteLength($hWnd) + 1
	Local $tNote = DllStructCreate("wchar Note[" & $iLen & "]")
	Local $tLen = DllStructCreate("dword")
	DllStructSetData($tLen, 1, $iLen)
	If Not _SendMessage($hWnd, $BCM_GETNOTE, $tLen, $tNote, 0, "struct*", "struct*") Then Return SetError(-1, 0, "")
	Return _WinAPI_WideCharToMultiByte($tNote)
EndFunc   ;==>_GUICtrlButton_GetNote

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_GetNoteLength
; Description ...: Gets the length of the note text that may be displayed in the description for a command link button
; Syntax.........: _GUICtrlButton_GetNoteLength($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success - Returns the length of the note text in WCHARs—not including any terminating NULL WCHAR
;                  Failure - 0
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: This function works only with the $BS_COMMANDLINK and $BS_DEFCOMMANDLINK button styles
;+
;                  Minimum Operating Systems: Windows Vista
; Related .......: _GUICtrlButton_GetNote, _GUICtrlButton_SetNote
; Link ..........: @@MsdnLink@@ BCM_GETNOTELENGTH
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_GetNoteLength($hWnd)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	Return _SendMessage($hWnd, $BCM_GETNOTELENGTH)
EndFunc   ;==>_GUICtrlButton_GetNoteLength

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_GetSplitInfo
; Description ...: Gets information for a split button control
; Syntax.........: _GUICtrlButton_GetSplitInfo($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success - Returns array of the following
;                  |[0] - A handle to the image list
;                  |[1] - The split button style, can be one or more of the following:
;                  |  $BCSS_ALIGNLEFT - Align the image or glyph horizontally with the left margin
;                  |  $BCSS_IMAGE     - Draw an icon image as the glyph
;                  |  $BCSS_NOSPLIT   - No split
;                  |  $BCSS_STRETCH   - Stretch glyph, but try to retain aspect ratio
;                  |[2] - Width of the glyph
;                  |[3] - Height of the glyph
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: This function works only with the $BS_SPLITBUTTON and $BS_DEFSPLITBUTTON button styles
;+
;                  Minimum Operating Systems: Windows Vista
; Related .......: _GUICtrlButton_SetSplitInfo
; Link ..........: @@MsdnLink@@ BCM_GETSPLITINFO
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_GetSplitInfo($hWnd)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $tSplitInfo = DllStructCreate($tagBUTTON_SPLITINFO), $aInfo[4]
	DllStructSetData($tSplitInfo, "mask", BitOR($BCSIF_GLYPH, $BCSIF_IMAGE, $BCSIF_SIZE, $BCSIF_STYLE))
	If Not _SendMessage($hWnd, $BCM_GETSPLITINFO, 0, $tSplitInfo, 0, "wparam", "struct*") Then Return SetError(-1, 0, $aInfo)
	$aInfo[0] = DllStructGetData($tSplitInfo, "himlGlyph")
	$aInfo[1] = DllStructGetData($tSplitInfo, "uSplitStyle")
	$aInfo[2] = DllStructGetData($tSplitInfo, "X")
	$aInfo[3] = DllStructGetData($tSplitInfo, "Y")
	Return $aInfo
EndFunc   ;==>_GUICtrlButton_GetSplitInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_GetState
; Description ...: Determines the state of a button or check box
; Syntax.........: _GUICtrlButton_GetState($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success - The current state of the button. You can use the following values to extract information about the state:
;                  |  $BST_CHECKED       - Indicates the button is checked.
;                  |  $BST_FOCUS         - Specifies the focus state. A nonzero value indicates that the button has the keyboard focus.
;                  |  $BST_INDETERMINATE - Indicates the button is grayed because the state of the button is indeterminate.
;                  |    This value applies only if the button has the $BS_3STATE or $BS_AUTO3STATE style.
;                  |  $BST_PUSHED        - Specifies the highlight state. A nonzero value indicates that the button is highlighted.
;                  |    A button is automatically highlighted when the user positions the cursor over it and presses and holds the
;                  |    left mouse button. The highlighting is removed when the user releases the mouse button.
;                  |  $BST_UNCHECKED     - Indicates the button is cleared. Same as a return value of zero.
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlButton_SetState, _GUICtrlButton_GetCheck, _GUICtrlButton_SetCheck
; Link ..........: @@MsdnLink@@ BM_GETSTATE
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_GetState($hWnd)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	Return _SendMessage($hWnd, $BM_GETSTATE)
EndFunc   ;==>_GUICtrlButton_GetState

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_GetText
; Description ...: Retrieve the text of the button
; Syntax.........: _GUICtrlButton_GetText($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success - The text of the button
;                  Failure - Empty string ""
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlButton_SetText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_GetText($hWnd)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	If _WinAPI_IsClassName($hWnd, $__BUTTONCONSTANT_ClassName) Then Return _WinAPI_GetWindowText($hWnd)
	Return ""
EndFunc   ;==>_GUICtrlButton_GetText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_GetTextMargin
; Description ...: Gets the margins used to draw text in a button control
; Syntax.........: _GUICtrlButton_GetTextMargin($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success - Array with the following format:
;                  |  [0] - Left margin to use for drawing text
;                  |  [1] - Top  margin to use for drawing text
;                  |  [2] - Right  margin to use for drawing text
;                  |  [3] - Bottom  margin to use for drawing text
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Minimum Operating Systems: Windows XP
; Related .......: _GUICtrlButton_SetTextMargin
; Link ..........: @@MsdnLink@@ BCM_GETTEXTMARGIN
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_GetTextMargin($hWnd)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	Local $tRect = DllStructCreate($tagRECT), $aRect[4]
	If Not _SendMessage($hWnd, $BCM_GETTEXTMARGIN, 0, $tRect, 0, "wparam", "struct*") Then Return SetError(-1, -1, $aRect)
	$aRect[0] = DllStructGetData($tRect, "Left")
	$aRect[1] = DllStructGetData($tRect, "Top")
	$aRect[2] = DllStructGetData($tRect, "Right")
	$aRect[3] = DllStructGetData($tRect, "Bottom")
	Return $aRect
EndFunc   ;==>_GUICtrlButton_GetTextMargin

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_SetCheck
; Description ...: Sets the check state of a radio button or check box
; Syntax.........: _GUICtrlButton_SetCheck($hWnd[, $iState = $BST_CHECKED]])
; Parameters ....: $hWnd        - Handle to the control
;                  $iState      - The check state. This parameter can be one of the following values:
;                  |  $BST_CHECKED       - Sets the button state to checked.
;                  |  $BST_INDETERMINATE - Sets the button state to grayed, indicating an indeterminate state.
;                  |    Use this value only if the button has the $BS_3STATE or $BS_AUTO3STATE style.
;                  |  $BST_UNCHECKED     - Sets the button state to cleared.
; Return values .:
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: _GUICtrlButton_SetCheck has no effect on push buttons.
; Related .......: _GUICtrlButton_GetCheck, _GUICtrlButton_GetState, _GUICtrlButton_SetState
; Link ..........: @@MsdnLink@@ BCM_GETTEXTMARGIN
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_SetCheck($hWnd, $iState = $BST_CHECKED)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	_SendMessage($hWnd, $BM_SETCHECK, $iState)
EndFunc   ;==>_GUICtrlButton_SetCheck

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_SetDontClick
; Description ...: Sets the state of $BST_DONTCLICK flag on a button
; Syntax.........: _GUICtrlButton_SetDontClick($hWnd[, $fState = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $fState      - The state. True to set the $BST_DONTCLICK, otherwise False
; Return values .:
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Minimum Operating Systems: Windows Vista
; Related .......:
; Link ..........: @@MsdnLink@@ BM_SETDONTCLICK
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_SetDontClick($hWnd, $fState = True)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	_SendMessage($hWnd, $BM_SETDONTCLICK, $fState)
EndFunc   ;==>_GUICtrlButton_SetDontClick

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlButton_SetDropDownState
; Description ...: Sets the drop down state for a button with style $TBSTYLE_DROPDOWN
; Syntax.........: _GUICtrlButton_SetDropDownState($hWnd[, $fState = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $iState      - Drop down state
;                  |  True  - For state of $BST_DROPDOWNPUSHED
;                  |  False - otherwise
; Return values .: Success - True
;                  Failure - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Minimum Operating Systems: Windows Vista
; Related .......:
; Link ..........: @@MsdnLink@@ BCM_SETDROPDOWNSTATE
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_SetDropDownState($hWnd, $fState = True)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	Return _SendMessage($hWnd, $BCM_SETDROPDOWNSTATE, $fState) <> 0
EndFunc   ;==>_GUICtrlButton_SetDropDownState

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_SetFocus
; Description ...: Sets the keyboard focus to the specified button
; Syntax.........: _GUICtrlButton_SetFocus($hWnd[, $fFocus = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $fFocus      - This parameter can be one of the following values:
;                  |  True      - Sets the keyboard focus to the button
;                  |  False     - Removes the keyboard focus from the button
; Return values .: Success - True
;                  Failure - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlButton_GetFocus
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_SetFocus($hWnd, $fFocus = True)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	If _WinAPI_IsClassName($hWnd, $__BUTTONCONSTANT_ClassName) Then
		If $fFocus Then
			Return _WinAPI_SetFocus($hWnd) <> 0
		Else
			Return _WinAPI_SetFocus(_WinAPI_GetParent($hWnd)) <> 0
		EndIf
	EndIf
EndFunc   ;==>_GUICtrlButton_SetFocus

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_SetImage
; Description ...: Sets the check state of a radio button or check box
; Syntax.........: _GUICtrlButton_SetImage($hWnd, $sImageFile[, $nIconId = -1[, $fLarge = False]])
; Parameters ....: $hWnd        - Handle to the control
;                  $sImageFile  - File containing the Image
;                  $nIconId     - Specifies the zero-based index of the icon to extract
;                  $fLarge      - Extract Large Icon
; Return values .: Success - True
;                  Failure - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlButton_GetImage
; Link ..........: @@MsdnLink@@ BM_SETIMAGE
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_SetImage($hWnd, $sImageFile, $nIconId = -1, $fLarge = False)
	Local $hImage, $hPrevImage
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	If StringUpper(StringMid($sImageFile, StringLen($sImageFile) - 2)) = "BMP" Then
		If BitAND(_WinAPI_GetWindowLong($hWnd, $__BUTTONCONSTANT_GWL_STYLE), $BS_BITMAP) = $BS_BITMAP Then
			$hImage = _WinAPI_LoadImage(0, $sImageFile, 0, 0, 0, BitOR($__BUTTONCONSTANT_LR_LOADFROMFILE, $__BUTTONCONSTANT_LR_CREATEDIBSECTION))
			If Not $hImage Then Return SetError(-1, -1, False)
			$hPrevImage = _SendMessage($hWnd, $BM_SETIMAGE, 0, $hImage)
			If $hPrevImage Then
				If Not _WinAPI_DeleteObject($hPrevImage) Then _WinAPI_DestroyIcon($hPrevImage)
			EndIf
			_WinAPI_UpdateWindow($hWnd) ; force a WM_PAINT
			Return True
		EndIf
	Else
		If $nIconId = -1 Then
			$hImage = _WinAPI_LoadImage(0, $sImageFile, 1, 0, 0, BitOR($__BUTTONCONSTANT_LR_LOADFROMFILE, $__BUTTONCONSTANT_LR_CREATEDIBSECTION))
			If Not $hImage Then Return SetError(-1, -1, False)
			$hPrevImage = _SendMessage($hWnd, $BM_SETIMAGE, 1, $hImage)
			If $hPrevImage Then
				If Not _WinAPI_DeleteObject($hPrevImage) Then _WinAPI_DestroyIcon($hPrevImage)
			EndIf
			_WinAPI_UpdateWindow($hWnd) ; force a WM_PAINT
			Return True
		Else
			Local $tIcon = DllStructCreate("handle Handle")
			Local $iRet
			If $fLarge Then
				$iRet = _WinAPI_ExtractIconEx($sImageFile, $nIconId, $tIcon, 0, 1)
			Else
				$iRet = _WinAPI_ExtractIconEx($sImageFile, $nIconId, 0, $tIcon, 1)
			EndIf
			If Not $iRet Then Return SetError(-1, -1, False)
			$hPrevImage = _SendMessage($hWnd, $BM_SETIMAGE, 1, DllStructGetData($tIcon, "Handle"))
			If $hPrevImage Then
				If Not _WinAPI_DeleteObject($hPrevImage) Then _WinAPI_DestroyIcon($hPrevImage)
			EndIf
			_WinAPI_UpdateWindow($hWnd) ; force a WM_PAINT
			Return True
		EndIf
	EndIf
	Return False
EndFunc   ;==>_GUICtrlButton_SetImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_SetImageList
; Description ...: Assigns an image list to a button control
; Syntax.........: _GUICtrlButton_SetImageList($hWnd, $hImage[, $nAlign = 0[, $iLeft = 1[, $iTop = 1[, $iRight = 1[, $iBottom = 1]]]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $hImage  - A handle to the image list.
;                  |  Should contain either a single image to be used for all states or individual images for each state listed in the following:
;                  |    1 - Normal
;                  |    2 - Hot
;                  |    3 - Pressed
;                  |    4 - Disabled
;                  |    5 - Defaulted
;                  |    6 - Stylus Hot (tablet computers only)
;                  $nAlign      - Specifies the alignment to use. This parameter can be one of the following values:
;                  |  0 - Align the image with the left margin.
;                  |  1 - Align the image with the right margin.
;                  |  2 - Align the image with the top margin.
;                  |  3 - Align the image with the bottom margin.
;                  |  4 - Center the image.
;                  $iLeft   - Left margin of the icon
;                  $iTop    - Top margin of the icon
;                  $iRight  - Right margin of the icon
;                  $iBottom - Bottom margin of the icon
; Return values .: Success - True
;                  Failure - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Minimum Operating Systems: Windows XP.
;                  Image list with multiple images will only show the images other than the 1st image when
;                  Themes is being used.
; Related .......: _GUICtrlButton_GetImageList
; Link ..........: @@MsdnLink@@ BCM_SETIMAGELIST
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_SetImageList($hWnd, $hImage, $nAlign = 0, $iLeft = 1, $iTop = 1, $iRight = 1, $iBottom = 1)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	If $nAlign < 0 Or $nAlign > 4 Then $nAlign = 0

	Local $tBUTTON_IMAGELIST = DllStructCreate($tagBUTTON_IMAGELIST)

	DllStructSetData($tBUTTON_IMAGELIST, "ImageList", $hImage)
	DllStructSetData($tBUTTON_IMAGELIST, "Left", $iLeft)
	DllStructSetData($tBUTTON_IMAGELIST, "Top", $iTop)
	DllStructSetData($tBUTTON_IMAGELIST, "Right", $iRight)
	DllStructSetData($tBUTTON_IMAGELIST, "Bottom", $iBottom)
	DllStructSetData($tBUTTON_IMAGELIST, "Align", $nAlign)

	Local $fEnabled = _GUICtrlButton_Enable($hWnd, False)
	Local $iRet = _SendMessage($hWnd, $BCM_SETIMAGELIST, 0, $tBUTTON_IMAGELIST, 0, "wparam", "struct*") <> 0
	_GUICtrlButton_Enable($hWnd)
	If Not $fEnabled Then _GUICtrlButton_Enable($hWnd, False)
	Return $iRet
EndFunc   ;==>_GUICtrlButton_SetImageList

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_SetNote
; Description ...: Sets the text of the note associated with a command link button
; Syntax.........: _GUICtrlButton_SetNote($hWnd, $sNote)
; Parameters ....: $hWnd        - Handle to the control
;                  $sNote       - String that contains the note
; Return values .: Success - True
;                  Failure - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Minimum Operating Systems: Windows Vista
; Related .......: _GUICtrlButton_GetNote, _GUICtrlButton_GetNoteLength
; Link ..........: @@MsdnLink@@ BCM_SETNOTE
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_SetNote($hWnd, $sNote)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	Local $tNote = _WinAPI_MultiByteToWideChar($sNote)
	Return _SendMessage($hWnd, $BCM_SETNOTE, 0, $tNote, 0, "wparam", "struct*") <> 0
EndFunc   ;==>_GUICtrlButton_SetNote

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_SetShield
; Description ...: Sets the elevation required state for a specified button or command link to display an elevated icon
; Syntax.........: _GUICtrlButton_SetShield($hWnd[, $fRequired = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $fRequired   - True to draw an elevated icon, or False otherwise
; Return values .: Success - True
;                  Failure - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Minimum Operating Systems: Windows Vista
; Related .......:
; Link ..........: @@MsdnLink@@ BCM_SETSHIELD
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_SetShield($hWnd, $fRequired = True)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	Return _SendMessage($hWnd, $BCM_SETSHIELD, 0, $fRequired) = 1
EndFunc   ;==>_GUICtrlButton_SetShield

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_SetSize
; Description ...: Sets the size of the button
; Syntax.........: _GUICtrlButton_SetSize($hWnd, $iWidth, $iHeight)
; Parameters ....: $hWnd    - Handle to the control
;                  $iWidth  - New width of the button
;                  $iHeight - New height of the button
; Return values .: Success - True
;                  Failure - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlButton_GetIdealSize
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_SetSize($hWnd, $iWidth, $iHeight)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	If Not _WinAPI_IsClassName($hWnd, $__BUTTONCONSTANT_ClassName) Then Return SetError(-1, -1, False)
	Local $hParent = _WinAPI_GetParent($hWnd)
	If Not $hParent Then Return SetError(-1, -1, False)
	Local $aPos = WinGetPos($hWnd)
	If Not IsArray($aPos) Then Return SetError(-1, -1, False)
	Local $tPoint = DllStructCreate($tagPOINT)
	DllStructSetData($tPoint, "X", $aPos[0])
	DllStructSetData($tPoint, "Y", $aPos[1])
	If Not _WinAPI_ScreenToClient($hParent, $tPoint) Then Return SetError(-1, -1, False)
	Local $iRet = WinMove($hWnd, "", DllStructGetData($tPoint, "X"), DllStructGetData($tPoint, "Y"), $iWidth, $iHeight)
	Return SetError($iRet - 1, $iRet - 1, $iRet <> 0)
EndFunc   ;==>_GUICtrlButton_SetSize

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_SetSplitInfo
; Description ...: Gets information for a split button control
; Syntax.........: _GUICtrlButton_SetSplitInfo($hWnd[, $himlGlyph = -1[, $iSplitStyle = $BCSS_ALIGNLEFT[, $iWidth = 0[, $iHeight = 0]]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $himlGlyph   - Handle to the image list
;                  $iSplitStyle - The split button style. Value must be one or more of the following flags.
;                  |  $BCSS_ALIGNLEFT - Align the image or glyph horizontally with the left margin
;                  |  $BCSS_IMAGE     - Draw an icon image as the glyph
;                  |  $BCSS_NOSPLIT   - No split
;                  |  $BCSS_STRETCH   - Stretch glyph, but try to retain aspect ratio
;                  $iWidth    - Width of the glyph
;                  $iHeight - Height of the glyph
; Return values .: Success - True
;                  Failure - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: This function works only with the $BS_SPLITBUTTON and $BS_DEFSPLITBUTTON button styles
;+
;                  Minimum Operating Systems: Windows Vista
; Related .......: _GUICtrlButton_GetSplitInfo
; Link ..........: @@MsdnLink@@ BCM_SETSPLITINFO
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_SetSplitInfo($hWnd, $himlGlyph = -1, $iSplitStyle = $BCSS_ALIGNLEFT, $iWidth = 0, $iHeight = 0)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	Local $tSplitInfo = DllStructCreate($tagBUTTON_SPLITINFO), $iMask = 0

	If $himlGlyph <> -1 Then
		$iMask = BitOR($iMask, $BCSIF_GLYPH)
		DllStructSetData($tSplitInfo, "himlGlyph", $himlGlyph)
	EndIf

	$iMask = BitOR($iMask, $BCSIF_STYLE)
	If BitAND($iSplitStyle, $BCSS_IMAGE) = $BCSS_IMAGE Then $iMask = BitOR($iMask, $BCSIF_IMAGE)
	DllStructSetData($tSplitInfo, "uSplitStyle", $iSplitStyle)

	If $iWidth > 0 Or $iHeight > 0 Then
		$iMask = BitOR($iMask, $BCSIF_SIZE)
		DllStructSetData($tSplitInfo, "X", $iWidth)
		DllStructSetData($tSplitInfo, "Y", $iHeight)
	EndIf

	DllStructSetData($tSplitInfo, "mask", $iMask)

	Return _SendMessage($hWnd, $BCM_SETSPLITINFO, 0, $tSplitInfo, 0, "wparam", "struct*") <> 0
EndFunc   ;==>_GUICtrlButton_SetSplitInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_SetState
; Description ...: Sets the highlight state of a button. The highlight state indicates whether the button is highlighted as if the user had pushed it.
; Syntax.........: _GUICtrlButton_SetState($hWnd[, $fHighlighted = True]])
; Parameters ....: $hWnd         - Handle to the control
;                  $fHighlighted - Specifies whether the button is highlighted.
; Return values .:
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Highlighting affects only the appearance of a button. It has no effect on the check state of a radio button or check box.
;+
;                  A button is automatically highlighted when the user positions the cursor over it and presses and holds the left mouse button.
;                  The highlighting is removed when the user releases the mouse button.
; Related .......: _GUICtrlButton_GetState, _GUICtrlButton_SetCheck
; Link ..........: @@MsdnLink@@ BM_SETSTATE
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_SetState($hWnd, $fHighlighted = True)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	_SendMessage($hWnd, $BM_SETSTATE, $fHighlighted)
EndFunc   ;==>_GUICtrlButton_SetState

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_SetStyle
; Description ...: Sets the style of a button
; Syntax.........: _GUICtrlButton_SetStyle($hWnd, $iStyle)
; Parameters ....: $hWnd   - Handle to the control
;                  $iStyle - Can be a combination of button styles
; Return values .:
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ BM_SETSTYLE
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_SetStyle($hWnd, $iStyle)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	_SendMessage($hWnd, $BM_SETSTYLE, $iStyle, True)
	_WinAPI_UpdateWindow($hWnd) ; force a WM_PAINT
EndFunc   ;==>_GUICtrlButton_SetStyle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_SetText
; Description ...: Sets the text of the button
; Syntax.........: _GUICtrlButton_SetText($hWnd, $sText)
; Parameters ....: $hWnd  - Handle to the control
;                  $sText - New text
; Return values .: Success - True
;                  Failure - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlButton_GetText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_SetText($hWnd, $sText)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	If _WinAPI_IsClassName($hWnd, $__BUTTONCONSTANT_ClassName) Then Return _WinAPI_SetWindowText($hWnd, $sText)
EndFunc   ;==>_GUICtrlButton_SetText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_SetTextMargin
; Description ...: Sets the margins for drawing text in a button control
; Syntax.........: _GUICtrlButton_SetTextMargin($hWnd[, $iLeft = 1[, $iTop = 1[, $iRight = 1[, $iBottom = 1]]]])
; Parameters ....: $hWnd   - Handle to the control
;                  $iLeft   - Left margin to use for drawing text
;                  $iTop    - Top margin to use for drawing text
;                  $iRight  - Right margin to use for drawing text
;                  $iBottom - Bottom margin to use for drawing text
; Return values .: Success - True
;                  Failure - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Minimum Operating Systems: Windows XP
; Related .......: _GUICtrlButton_GetTextMargin
; Link ..........:  @@MsdnLink@@ BCM_SETTEXTMARGIN
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_SetTextMargin($hWnd, $iLeft = 1, $iTop = 1, $iRight = 1, $iBottom = 1)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	Local $tRect = DllStructCreate($tagRECT)
	DllStructSetData($tRect, "Left", $iLeft)
	DllStructSetData($tRect, "Top", $iTop)
	DllStructSetData($tRect, "Right", $iRight)
	DllStructSetData($tRect, "Bottom", $iBottom)
	Return _SendMessage($hWnd, $BCM_SETTEXTMARGIN, 0, $tRect, 0, "wparam", "struct*") <> 0
EndFunc   ;==>_GUICtrlButton_SetTextMargin

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlButton_Show
; Description ...: Show/Hide button
; Syntax.........: _GUICtrlButton_Show($hWnd[, $fShow = True])
; Parameters ....: $hWnd   - Handle to the control
;                  $fShow   - One of the following:
;                  | True - Show button
;                  |False - Hide button
; Return values .: Success      - One of the Following:
;                  |1 - If the button was previously visible
;                  |0 - If the button was previously hidden
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlButton_Show($hWnd, $fShow = True)
	If $Debug_Btn Then __UDF_ValidateClassName($hWnd, $__BUTTONCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	If _WinAPI_IsClassName($hWnd, $__BUTTONCONSTANT_ClassName) Then
		If $fShow Then
			Return _WinAPI_ShowWindow($hWnd, @SW_SHOW)
		Else
			Return _WinAPI_ShowWindow($hWnd, @SW_HIDE)
		EndIf
	EndIf
EndFunc   ;==>_GUICtrlButton_Show
