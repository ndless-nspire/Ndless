#include-once

#include "AVIConstants.au3"
#include "Memory.au3"
#include "SendMessage.au3"
#include "WinAPI.au3"
#include "UDFGlobalID.au3"

; #INDEX# =======================================================================================================================
; Title .........: Animation
; AutoIt Version : 3.3.7.20++
; Language ......: English
; Description ...: Functions that assist with AVI control management.
;                  An animation control is a window that displays an Audio-Video Interleaved (AVI) clip.  An AVI clip is a series
;                  of bitmap frames like a movie. Animation controls can only display AVI clips that do not  contain  audio.  One
;                  common use for an animation control is to indicate  system  activity  during  a  lengthy  operation.  This  is
;                  possible because the operation thread continues executing while the AVI clip is displayed.  For  example,  the
;                  Find dialog box of Microsoft Windows Explorer displays a moving magnifying glass as the system searches for  a
;                  file.
;
;                  If you are using ComCtl32.dll version 6 the thread is not supported, therefore make sure that your application
;                  does not block the UI or the animation  will  not  occur.  An  animation  control  can  display  an  AVI  clip
;                  originating from either an uncompressed AVI file or from an AVI file that  was  compressed  using  run  length
;                  (BI_RLE8) encoding. You can add the AVI clip to your application as an AVI resource, or the clip can accompany
;                  your application as a separate AVI file.
;
;                  The AVI file, or resource, must not have a sound channel.  The capabilities of the animation control are  very
;                  limited and are subject to change.  If you need  a  control  to  provide  multimedia  playback  and  recording
;                  capabilities for your application, you can use the MCIWnd control.
; Author(s) .....: Paul Campbell (PaulIA)
; Dll(s .........: user32.dll
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $Debug_AVI = False
Global $gh_AVLastWnd
; ===============================================================================================================================

; #MESSAGES# ====================================================================================================================
Global Const $__AVICONSTANT_WM_USER = 0X400
Global Const $ACM_OPENA = $__AVICONSTANT_WM_USER + 100
Global Const $ACM_PLAY = $__AVICONSTANT_WM_USER + 101
Global Const $ACM_STOP = $__AVICONSTANT_WM_USER + 102
Global Const $ACM_ISPLAYING = $__AVICONSTANT_WM_USER + 104
Global Const $ACM_OPENW = $__AVICONSTANT_WM_USER + 103
; ===============================================================================================================================

; #NOTIFICATIONS# ===============================================================================================================
Global Const $ACN_START = 0x00000001 ; Notifies the control's parent that the AVI has started playing
Global Const $ACN_STOP = 0x00000002 ; Notifies the control's parent that the AVI has stopped playing
; ===============================================================================================================================

; #STYLES# ======================================================================================================================
; Global Const $ACS_CENTER              = 0x00000001    ; Centers the animation in the animation control's window
; Global Const $ACS_TRANSPARENT         = 0x00000002    ; Creates the control with a transparent background
; Global Const $ACS_AUTOPLAY            = 0x00000004    ; Starts playing the animation as soon as the AVI clip is opened
; Global Const $ACS_TIMER               = 0x00000008    ; The control plays the clip without creating a thread
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__AVICONSTANT_ClassName = "SysAnimate32"
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_GUICtrlAVI_Close
;_GUICtrlAVI_Create
;_GUICtrlAVI_Destroy
;_GUICtrlAVI_IsPlaying
;_GUICtrlAVI_Open
;_GUICtrlAVI_OpenEx
;_GUICtrlAVI_Play
;_GUICtrlAVI_Seek
;_GUICtrlAVI_Show
;_GUICtrlAVI_Stop
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlAVI_Close
; Description ...: Closes an AVI clip
; Syntax.........: _GUICtrlAVI_Close($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......: _GUICtrlAVI_Open
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlAVI_Close($hWnd)
	If $Debug_AVI Then __UDF_ValidateClassName($hWnd, $__AVICONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $iRet = _SendMessage($hWnd, $ACM_OPENA)
	Return SetError(@error, @extended, $iRet <> 0)
EndFunc   ;==>_GUICtrlAVI_Close

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlAVI_Create
; Description ...: Creates an AVI control
; Syntax.........: _GUICtrlAVI_Create($hWnd[, $sFile = ""[, $subfileid = -1[, $iX = 0[, $iY = 0[, $iWidth = 0[, $iHeight = 0[, $iStyle = 0x00000006[, $iExStyle = 0x00000000]]]]]]]])
; Parameters ....: $hWnd        - Handle to parent or owner window
;                  $sFile       - The filename of the video. Only .avi files are supported
;                  $subfileid   - id of the subfile to be used.
;                  $iX          - Horizontal position of the control
;                  $iY          - Vertical position of the control
;                  $iWidth      - Control width
;                  $iHeight     - Control height
;                  $iStyle      - Control styles:
;                  |$ACS_CENTER      - Centers the animation in the animation control's window
;                  |$ACS_TRANSPARENT - Creates the control with a transparent background
;                  |$ACS_AUTOPLAY    - Starts playing the animation as soon as the AVI clip is opened
;                  |$ACS_TIMER       - The control plays the clip without creating a thread
;                  -
;                  |Default: $ACS_TRANSPARENT, $ACS_AUTOPLAY
;                  |Forced : $WS_CHILD, $WS_VISIBLE
;                  $iExStyle    - Control external styles
; Return values .: Success      - Handle of the animation control
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (Added params, Added Open calls "sets the avi to 1st frame")
; Remarks .......: This function is for Advanced users and for learning how the control works.
; Related .......: _GUICtrlAVI_Destroy
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlAVI_Create($hWnd, $sFile = "", $subfileid = -1, $iX = 0, $iY = 0, $iWidth = 0, $iHeight = 0, $iStyle = 0x00000006, $iExStyle = 0x00000000)
	If Not IsHWnd($hWnd) Then Return SetError(1, 0, 0) ; Invalid Window handle for 1st parameter
	If Not IsString($sFile) Then Return SetError(2, 0, 0) ; 2nd parameter not a string for _GUICtrlAVI_Create

	$iStyle = BitOR($iStyle, $__UDFGUICONSTANT_WS_CHILD, $__UDFGUICONSTANT_WS_VISIBLE)

	Local $nCtrlID = __UDF_GetNextGlobalID($hWnd)
	If @error Then Return SetError(@error, @extended, 0)

	Local $hAVI = _WinAPI_CreateWindowEx($iExStyle, $__AVICONSTANT_ClassName, "", $iStyle, $iX, $iY, $iWidth, $iHeight, $hWnd, $nCtrlID)
	If $subfileid <> -1 And $sFile <> "" Then
		_GUICtrlAVI_OpenEx($hAVI, $sFile, $subfileid)
	ElseIf $sFile <> "" Then
		_GUICtrlAVI_Open($hAVI, $sFile)
	EndIf
	Return $hAVI
EndFunc   ;==>_GUICtrlAVI_Create

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlAVI_Destroy
; Description ...: Delete the control
; Syntax.........: _GUICtrlAVI_Destroy(ByRef $hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True, Handle is set to 0
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Restricted to only be used on AVI Control created with _GUICtrlAVI_Create
; Related .......: _GUICtrlAVI_Create
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlAVI_Destroy(ByRef $hWnd)
	If $Debug_AVI Then __UDF_ValidateClassName($hWnd, $__AVICONSTANT_ClassName)
	If Not _WinAPI_IsClassName($hWnd, $__AVICONSTANT_ClassName) Then Return SetError(2, 2, False)

	Local $Destroyed = 0
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $gh_AVLastWnd) Then
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
EndFunc   ;==>_GUICtrlAVI_Destroy

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlAVI_IsPlaying
; Description ...: Checks whether an Audio-Video Interleaved (AVI) clip is playing
; Syntax.........: _GUICtrlAVI_IsPlaying($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Minimum OS: Windows Vista
; Related .......:
; Link ..........: @@MsdnLink@@ ACM_ISPLAYING
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlAVI_IsPlaying($hWnd)
	If $Debug_AVI Then __UDF_ValidateClassName($hWnd, $__AVICONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $ACM_ISPLAYING) <> 0
EndFunc   ;==>_GUICtrlAVI_IsPlaying

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlAVI_Open
; Description ...: Opens an AVI clip and displays its first frame in an animation control
; Syntax.........: _GUICtrlAVI_Open($hWnd, $sFileName)
; Parameters ....: $hWnd        - Handle to the control
;                  $sFileName   - Fully qualified path to the AVI file
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (Added seek "sets the avi to 1st frame")
; Remarks .......: You can only open silent AVI clips
; Related .......: _GUICtrlAVI_Close, _GUICtrlAVI_OpenEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlAVI_Open($hWnd, $sFileName)
	If $Debug_AVI Then __UDF_ValidateClassName($hWnd, $__AVICONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $iRet
	If _WinAPI_InProcess($hWnd, $gh_AVLastWnd) Then
		$iRet = _SendMessage($hWnd, $ACM_OPENW, 0, $sFileName, 0, "wparam", "wstr")
	Else
		Local $tBuffer = DllStructCreate("wchar Text[" & StringLen($sFileName) + 1 & "]")
		DllStructSetData($tBuffer, "Text", $sFileName)
		Local $tMemMap
		_MemInit($hWnd, DllStructGetSize($tBuffer), $tMemMap)
		_MemWrite($tMemMap, $tBuffer)
		$iRet = _SendMessage($hWnd, $ACM_OPENW, True, $tBuffer, 0, "wparam", "struct*")
		_MemFree($tMemMap)
	EndIf
	If $iRet <> 0 Then _GUICtrlAVI_Seek($hWnd, 0)
	Return SetError(@error, @extended, $iRet <> 0)
EndFunc   ;==>_GUICtrlAVI_Open

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlAVI_OpenEx
; Description ...: Opens an AVI clip and displays its first frame in an animation control
; Syntax.........: _GUICtrlAVI_OpenEx($hWnd, $sFileName, $iResourceID)
; Parameters ....: $hWnd        - Handle to the control
;                  $sFileName   - Fully qualified path to resource file
;                  $iResourceID - AVI resource identifier
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (Added seek "sets the avi to 1st frame")
; Remarks .......: You can only open silent AVI clips
; Related .......: _GUICtrlAVI_Open
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlAVI_OpenEx($hWnd, $sFileName, $iResourceID)
	If $Debug_AVI Then __UDF_ValidateClassName($hWnd, $__AVICONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $hInst = _WinAPI_LoadLibrary($sFileName)
	If @error Then Return SetError(@error, @extended, False)
	Local $iRet = _SendMessage($hWnd, $ACM_OPENW, $hInst, $iResourceID)
	_WinAPI_FreeLibrary($hInst)
	If $iRet <> 0 Then _GUICtrlAVI_Seek($hWnd, 0)
	Return SetError(@error, @extended, $iRet <> 0)
EndFunc   ;==>_GUICtrlAVI_OpenEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlAVI_Play
; Description ...: Plays an AVI clip in an animation control
; Syntax.........: _GUICtrlAVI_Play($hWnd[, $iFrom = 0[, $iTo = -1[, $iRepeat = -1]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $iFrom       - Zero based index of the frame where playing begins. The value must be less than 65,536. A value
;                  +of 0 means begin with the first frame in the clip.
;                  $iTo         - Zero based index of the frame where playing ends.  The value must be less than 65,536.  A value
;                  +of -1 means end with the last frame in the clip.
;                  $iRepeat     - Number of times to replay the AVI clip.  A value of -1 means replay the clip indefinitely.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......: The control plays the clip in the background while the thread continues executing
; Related .......: _GUICtrlAVI_Stop, _GUICtrlAVI_Seek
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlAVI_Play($hWnd, $iFrom = 0, $iTo = -1, $iRepeat = -1)
	If $Debug_AVI Then __UDF_ValidateClassName($hWnd, $__AVICONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $iRet = _SendMessage($hWnd, $ACM_PLAY, $iRepeat, _WinAPI_MakeLong($iFrom, $iTo))
	Return SetError(@error, @extended, $iRet <> 0)
EndFunc   ;==>_GUICtrlAVI_Play

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlAVI_Seek
; Description ...: Directs an AVI control to display a particular frame of an AVI clip
; Syntax.........: _GUICtrlAVI_Seek($hWnd, $iFrame)
; Parameters ....: $hWnd        - Handle to the control
;                  $iFrame      - Zero based index of the frame to display
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......: _GUICtrlAVI_Play
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlAVI_Seek($hWnd, $iFrame)
	If $Debug_AVI Then __UDF_ValidateClassName($hWnd, $__AVICONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $iRet = _SendMessage($hWnd, $ACM_PLAY, 1, _WinAPI_MakeLong($iFrame, $iFrame))
	Return SetError(@error, @extended, $iRet <> 0)
EndFunc   ;==>_GUICtrlAVI_Seek

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlAVI_Show
; Description ...: Show/Hide the AVI control
; Syntax.........: _GUICtrlAVI_Show($hWnd, $iState)
; Parameters ....: $hWnd        - Handle to the control
;                  $iState      - State of the AVI, can be the following values:
;                 |@SW_SHOW
;                 |@SW_HIDE
; Return values .: True         - The control was previously visible
;                  False        - The control was previously hidden
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlAVI_Show($hWnd, $iState)
	If $Debug_AVI Then __UDF_ValidateClassName($hWnd, $__AVICONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	If $iState <> @SW_HIDE And $iState <> @SW_SHOW Then Return SetError(1, 1, 0)
	Return _WinAPI_ShowWindow($hWnd, $iState)
EndFunc   ;==>_GUICtrlAVI_Show

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlAVI_Stop
; Description ...: Stops playing an AVI clip
; Syntax.........: _GUICtrlAVI_Stop($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......: _GUICtrlAVI_Play
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlAVI_Stop($hWnd)
	If $Debug_AVI Then __UDF_ValidateClassName($hWnd, $__AVICONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $iRet = _SendMessage($hWnd, $ACM_STOP)
	Return SetError(@error, @extended, $iRet <> 0)
EndFunc   ;==>_GUICtrlAVI_Stop
