#include-once

#include "WinAPIError.au3"

; #INDEX# =======================================================================================================================
; Title .........: Internet Explorer Automation UDF Library for AutoIt3
; AutoIt Version : 3.3.7.20++
; Language ......: English
; Description ...: A collection of functions for creating, attaching to, reading from and manipulating Internet Explorer.
; Author(s) .....: DaleHohm, big_daddy
; Dll ...........: user32.dll, ole32.dll, oleacc.dll
; ===============================================================================================================================

#region Header
#cs
	Title:   Internet Explorer Automation UDF Library for AutoIt3
	Filename:  IE.au3
	Description: A collection of functions for creating, attaching to, reading from and manipulating Internet Explorer
	Author:   DaleHohm
	Version:  V2.4-1
	Last Update: 4/26/08
	Requirements: AutoIt3 3.2 or higher, Developed/Tested on WindowsXP Pro with Internet Explorer6 and Internet Explorer7
	
	Note: Special thanks to big_daddy for working on documentation and creating helpfile for T2.0!
	
	Update History:
	===================================================
	V2.4-1 4/26/08
	
	Fixes
	_IEAttach, windowtitle, fixed bug matching window title when IE windowtitle registry key is not set
	_IEPropertyGet, toolbars, broken, now works
	
	New Features
	
	Enhancements
	_IEGetObjById added requested Id to console output on NoMatch
	_IEGetObjByName added requested Id and index to console output on NoMatch
	
	---------------------------------------------------
	V2.4-0 12/31/07
	
	Fixes
	_IELoadWait looping logic corrected to prevent nuisance console COM messages with small loadwait timeouts
	_IEAttach embedded and dialogbox modes update DllCall syntax (hopefully works with bugfix to DllCall post 3.2.10.0 that caused embedded to fail)
	_IEAttach moved Shell.Window object creation after embedded/dialogbox logic so that they can run without explorer.exe running
	_IECreate and _IENavigate documentation, added Windows Vista UAC information
	_IEFormElementGetValue returns NULL string if value is NULL instead of integer 0
	
	New Features
	Added uniqueID to _IEPropertyGet
	Added "instance" mode to _IEAttach
	Added "$i_instance" parameter to _IEAttach
	- thanks to my 13-year-old daughter for helping me think through the logic of the _IEAttach additions :-)
	
	---------------------------------------------------
	V2.3-1 8/13/07
	
	Fixes
	_IELoadWait to handle "Access is denied" errors in foreign language variants
	_IEFormElementCheckBoxSelect and _IEFormElementRadioSelect errors with singletons
	
	Enhancements
	Enhanced _IEPropertyGet() width and height to work for document elements in addition to the browser window
	
	New Features
	Added browserX, browserY, screenX and screenY to _IEPropertyGet()
	Added Transpose option to _IETableWriteToArray
	
	---------------------------------------------------
	V2.3-0 8/11/07
	
	This version was not released due to regression corrected in V2.3-1
	
	---------------------------------------------------
	V2.2-1 5/9/07
	
	Fixes
	Trap and report Client Disconnected errors in _IELoadWait when Browser is deleted prior to operation
	
	---------------------------------------------------
	V2.2-0 5/8/07
	
	Fixes
	Fixed typos in _IEPropertyGet() directives appversion and appminorversion
	Updated links in _IE_Introduction('basic')
	
	Enhancements
	Several documentation
	
	New Features
	_IEGetObjById() added
	
	---------------------------------------------------
	V2.1-0 12/16/06
	
	Fixes
	_IEFormElementOptionSelect() - fixed problem with using "byText" mode that resulted in always selecting a blank text choice if it existed
	_IEAttach() - fixed error generated if certain IE emulators were running (e.g. Firefox IETab extension, Maxathon etc.)
	Forced datatype to String for many internal variables where unexpected numerics could have caused erroneous condition matches
	Modified _IELoadWait() to trap and report more cases of "Access is Denied" cross-domain security errors
	Modified _IEFormElementCheckboxSelect() and _IEFormElementRadioSelect() so that element name resolution is scoped to the form (Thanks martijn)
	
	Enhancements
	Modified _IEFormElementSetValue() and _IEFormElement*Select() functions to fire onClick event in addition to onChange event
	Generate error if _IEFormElementSetValue() attempted on IMPUT TYPE=FILE element
	
	New Features
	_IEPropertyGet() - added referrer, theatermode, toolbar, contenteditable, innertext, outertext, innerhtml, outerhtml, title
	_IEPropertySet() - added theatermode, toolbar, contenteditable, innertext, outertext, innerhtml, outerhtml, title, silent
	_IEAttach() - added "windowtitle" mode that will attempt to match a substring in the full window title instead of document title
	_IEDocInsertText() function added
	_IEDocInsertHTML() function added
	
	Changes
	_IETableWriteToArray now reads TH (table header) cells into the output array instead of ignoring them
	_IEPropertySet removed LocationName and LocationURL that were read-only - please use _IENavigate instead
	
	Developer Notes
	added __IENavigate to Internal Functions to test 4 new parameters to the browser Navigate method - see header notes
	Previous version, T2.0-5, was released with AutoIt V3.2
	---------------------------------------------------
	
	===================================================
#ce
#endregion Header
#region Global Variables and Constants
Global Const $IEAU3VersionInfo[6] = ["V", 2, 4, 0, "20071231", "V2.4-0"]
Global Const $LSFW_LOCK = 1, $LSFW_UNLOCK = 2
Global $__IELoadWaitTimeout = 300000 ; 5 Minutes
Global $__IEAU3Debug = False
Global $__IEAU3V1Compatibility
Global $__IEAU3Debug_UseOldDLLCall = False
Global $_IEErrorNotify = True
Global $oIEErrorHandler, $sIEUserErrorHandler
Global _; Com Error Handler Status Strings
		$IEComErrorNumber, _
		$IEComErrorNumberHex, _
		$IEComErrorDescription, _
		$IEComErrorScriptline, _
		$IEComErrorWinDescription, _
		$IEComErrorSource, _
		$IEComErrorHelpFile, _
		$IEComErrorHelpContext, _
		$IEComErrorLastDllError, _
		$IEComErrorComObj, _
		$IEComErrorOutput
;
; Enums
;
Global Enum _; Error Status Types
		$_IEStatus_Success = 0, _
		$_IEStatus_GeneralError, _
		$_IEStatus_ComError, _
		$_IEStatus_InvalidDataType, _
		$_IEStatus_InvalidObjectType, _
		$_IEStatus_InvalidValue, _
		$_IEStatus_LoadWaitTimeout, _
		$_IEStatus_NoMatch, _
		$_IEStatus_AccessIsDenied, _
		$_IEStatus_ClientDisconnected
Global Enum Step * 2 _; NotificationLevel
		$_IENotifyLevel_None = 0, _
		$_IENotifyNotifyLevel_Warning = 1, _
		$_IENotifyNotifyLevel_Error, _
		$_IENotifyNotifyLevel_ComError
Global Enum Step * 2 _; NotificationMethod
		$_IENotifyMethod_Silent = 0, _
		$_IENotifyMethod_Console = 1, _
		$_IENotifyMethod_ToolTip, _
		$_IENotifyMethod_MsgBox
#endregion Global Variables and Constants
#region Core functions
; #FUNCTION# ====================================================================================================================
; Name...........: _IECreate
; Description ...: Create an Internet Explorer Browser Window
; Parameters ....: $s_Url			- Optional: specifies the Url to navigate to upon creation
;				   $f_tryAttach	- Optional: specifies whether to try to attach to an existing window
;										0 = (Default) do not try to attach
;										1 = Try to attach to an existing window
;				   $f_visible 		- Optional: specifies whether the browser window will be visible
;										0 = Browser Window is hidden
;										1 = (Default) Browser Window is visible
;				   $f_wait			- Optional: specifies whether to wait for page to load before returning
;										0 = Return immediately, not waiting for page to load
;										1 = (Default) Wait for page load to complete before returning
;				   $f_takeFocus	- Optional: specifies whether to bring the attached window to focus
;										0 =  Do Not Bring window into focus
;										1 = (Default) bring window into focus
; Return values .: On Success	- Returns an object variable pointing to an InternetExplorer.Application object
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 1 ($_IEStatus_GeneralError) = General Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 6 ($_IEStatus_LoadWaitTimeout) = Load Wait Timeout
;								- 8 ($_IEStatus_AccessIsDenied) = Access Is Denied
;								- 9 ($_IEStatus_ClientDisconnected) = Client Disconnected
;					@Extended	- Set to true (1) or false (0) depending on the success of $f_tryAttach
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IECreate($s_Url = "about:blank", $f_tryAttach = 0, $f_visible = 1, $f_wait = 1, $f_takeFocus = 1)

	; Temporary campatability mode for pre V2.0 code
	If $__IEAU3V1Compatibility Then
		Switch String($s_Url)
			Case "0"
				$s_Url = "about:blank"
				$f_visible = 0
				__IEErrorNotify("Warning", "_IECreate", "", _
						"Using deprecated behavior - $f_visible is now parameter 3 instead of parameter 1")
			Case "1"
				$s_Url = "about:blank"
				$f_visible = 1
				__IEErrorNotify("Warning", "_IECreate", "", _
						"Using deprecated behavior - $f_visible is now parameter 3 instead of parameter 1")
		EndSwitch
	EndIf

	If Not $f_visible Then $f_takeFocus = 0 ; Force takeFocus to 0 for hidden window

	If $f_tryAttach Then
		Local $oResult = _IEAttach($s_Url, "url")
		If IsObj($oResult) Then
			If $f_takeFocus Then WinActivate(HWnd($oResult.HWND))
			Return SetError($_IEStatus_Success, 1, $oResult)
		EndIf
	EndIf

	Local $f_mustUnlock = 0
	If Not $f_visible And __IELockSetForegroundWindow($LSFW_LOCK) Then $f_mustUnlock = 1

	Local $o_object = ObjCreate("InternetExplorer.Application")
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IECreate", "", "Browser Object Creation Failed")
		Return SetError($_IEStatus_GeneralError, 0, 0)
	EndIf

	$o_object.visible = $f_visible

	; If the unlock doesn't work we may have created an unwanted modal window
	If $f_mustUnlock And Not __IELockSetForegroundWindow($LSFW_UNLOCK) Then __IEErrorNotify("Warning", "_IECreate", "", "Foreground Window Unlock Failed!")
	_IENavigate($o_object, $s_Url, $f_wait)

	; Store @error after _IENavigate() so that it can be returned.
	Local $iError = @error

	; IE9 sets focus to the URL bar when an about: URI is displayed (such as about:blank).  This can cause
	; _IEAction(..., "focus") to work incorrectly.  It will give focus to the element (as shown by the elements's
	; appearance changing but) the input caret will not move.  The work-around for this "helpful" behavior is
	; to explicitly give focus to the document.  We should only do this for about: URIs and on successful
	; navigate.
	If Not $iError And StringLeft($s_Url, 6) = "about:" Then
		Local $oDocument = $o_object.document
		_IEAction($oDocument, "focus")
	EndIf

	Return SetError($iError, 0, $o_object)
EndFunc   ;==>_IECreate

; #FUNCTION# ====================================================================================================================
; Name...........: _IECreateEmbedded
; Description ...: Create a Webbrowser object suitable for embedding in an AutoIt GUI with GuiCtrlCreateObj().
; Parameters ....: None
; Return values .: On Success	- Returns a Webbrowser object reference
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 1 ($_IEStatus_GeneralError) = General Error
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IECreateEmbedded()

	Local $o_object = ObjCreate("Shell.Explorer.2")

	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IECreateEmbedded", "", "WebBrowser Object Creation Failed")
		Return SetError($_IEStatus_GeneralError, 0, 0)
	EndIf
	;
	Return SetError($_IEStatus_Success, 0, $o_object)
EndFunc   ;==>_IECreateEmbedded

; #FUNCTION# ====================================================================================================================
; Name...........: _IENavigate
; Description ...: Directs an existing browser window to navigate to the specified URL
; Parameters ....: $o_object 		- Object variable of an InternetExplorer.Application, Window or Frame object
;				   $s_Url 			- URL to navigate to (e.g. "http://www.autoitscript.com")
;				   $f_wait 		- Optional: specifies whether to wait for page to load before returning
;										0 = Return immediately, not waiting for page to load
;										1 = (Default) Wait for page load to complete before returning
; Return values .: On Success 	- Returns -1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 1 ($_IEStatus_GeneralError) = General Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 6 ($_IEStatus_LoadWaitTimeout) = Load Wait Timeout
;								- 8 ($_IEStatus_AccessIsDenied) = Access Is Denied
;								- 9 ($_IEStatus_ClientDisconnected) = Client Disconnected
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IENavigate(ByRef $o_object, $s_Url, $f_wait = 1)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IENavigate", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __IEIsObjType($o_object, "documentContainer") Then
		__IEErrorNotify("Error", "_IENavigate", "$_IEStatus_InvalidObjectType")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	$o_object.navigate($s_Url)
	If $f_wait Then
		_IELoadWait($o_object)
		Return SetError(@error, 0, -1)
	EndIf

	Return SetError($_IEStatus_Success, 0, -1)
EndFunc   ;==>_IENavigate

; #FUNCTION# ====================================================================================================================
; Name...........: _IEAttach
; Description ...: Attach to the first existing instance of Internet Explorer where the
;					search string sub-string matches based on the selected mode.
; Parameters ....: $s_string	- String to search for (for "embedded" or "dialogbox", use Title sub-string or HWND of window)
;				   $s_mode		- Optional: specifies search mode
;									Title		= (Default) browser title
;									URL			= url of the current page
;									Text 		= text from the body of the current page
;									HTML 		= html from the body of the current page
;									HWND 		= hwnd of the browser window
;									Embedded 	= title sub-string or hwnd of the window embedding the control
;									DialogBox 	= title sub-string or hwnd of modal/modeless dialogbox
;				   $i_instance	- Optional: specifies the 1-based instance when multiple windows match the criteria.
;									For Embedded, DialogBox and HWND it specifies the embedded browser occurance within
;									the matching window
; Return values .: On Success	- Returns an object variable pointing to the IE Window Object
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 5 ($_IEStatus_InvalidValue) = Invalid Value
;								- 7 ($_IEStatus_NoMatch) = No Match
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEAttach($s_string, $s_mode = "Title", $i_instance = 1)
	$s_mode = StringLower($s_mode)

	$i_instance = Int($i_instance)
	If $i_instance < 1 Then
		__IEErrorNotify("Error", "_IEAttach", "$_IEStatus_InvalidValue", "$i_instance < 1")
		Return SetError($_IEStatus_InvalidValue, 3, 0)
	EndIf

	If $s_mode = "embedded" Or $s_mode = "dialogbox" Then
		Local $iWinTitleMatchMode = Opt("WinTitleMatchMode", 2)
		If $s_mode = "dialogbox" And $i_instance > 1 Then
			If IsHWnd($s_string) Then
				$i_instance = 1
				__IEErrorNotify("Warning", "_IEAttach", "$_IEStatus_GeneralError", "$i_instance > 1 invalid with HWnd and DialogBox.  Setting to 1.")
			Else
				Local $a_winlist = WinList($s_string, "")
				If $i_instance <= $a_winlist[0][0] Then
					$s_string = $a_winlist[$i_instance][1]
					$i_instance = 1
				Else
					__IEErrorNotify("Warning", "_IEAttach", "$_IEStatus_NoMatch")
					Opt("WinTitleMatchMode", $iWinTitleMatchMode)
					Return SetError($_IEStatus_NoMatch, 1, 0)
				EndIf
			EndIf
		EndIf
		Local $h_control = ControlGetHandle($s_string, "", "[CLASS:Internet Explorer_Server; INSTANCE:" & $i_instance & "]")
		Local $oResult = __IEControlGetObjFromHWND($h_control)
		Opt("WinTitleMatchMode", $iWinTitleMatchMode)
		If IsObj($oResult) Then
			Return SetError($_IEStatus_Success, 0, $oResult)
		Else
			__IEErrorNotify("Warning", "_IEAttach", "$_IEStatus_NoMatch")
			Return SetError($_IEStatus_NoMatch, 1, 0)
		EndIf
	EndIf

	Local $o_Shell = ObjCreate("Shell.Application")
	Local $o_ShellWindows = $o_Shell.Windows(); collection of all ShellWindows (IE and File Explorer)
	Local $i_tmp = 1
	Local $f_NotifyStatus, $status, $f_isBrowser, $s_tmp
	For $o_window In $o_ShellWindows
		;------------------------------------------------------------------------------------------
		; Check to verify that the window object is a valid browser, if not, skip it
		;
		; Setup internal error handler to Trap COM errors, turn off error notification,
		;     check object property validity, set a flag and reset error handler and notification
		;
		$f_isBrowser = True
		; Trap COM errors and turn off error notification
		$status = __IEInternalErrorHandlerRegister()
		If Not $status Then __IEErrorNotify("Warning", "_IEAttach", _
				"Cannot register internal error handler, cannot trap COM errors", _
				"Use _IEErrorHandlerRegister() to register a user error handler")
		$f_NotifyStatus = _IEErrorNotify() ; save current error notify status
		_IEErrorNotify(False)

		; Check conditions to verify that the object is a browser
		If $f_isBrowser Then
			$s_tmp = $o_window.type ; Is .type a valid property?
			If @error Then $f_isBrowser = False
		EndIf
		If $f_isBrowser Then
			$s_tmp = $o_window.document.title ; Does object have a .document and .title property?
			If @error Then $f_isBrowser = False
		EndIf

		; restore error notify and error handler status
		_IEErrorNotify($f_NotifyStatus) ; restore notification status
		__IEInternalErrorHandlerDeRegister()
		;------------------------------------------------------------------------------------------

		If $f_isBrowser Then
			Switch $s_mode
				Case "title"
					If StringInStr($o_window.document.title, $s_string) > 0 Then
						If $i_instance = $i_tmp Then
							Return SetError($_IEStatus_Success, 0, $o_window)
						Else
							$i_tmp += 1
						EndIf
					EndIf
				Case "instance"
					If $i_instance = $i_tmp Then
						Return SetError($_IEStatus_Success, 0, $o_window)
					Else
						$i_tmp += 1
					EndIf
				Case "windowtitle"
					Local $f_found = False
					$s_tmp = RegRead("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main\", "Window Title")
					If Not @error Then
						If StringInStr($o_window.document.title & " - " & $s_tmp, $s_string) Then $f_found = True
					Else
						If StringInStr($o_window.document.title & " - Microsoft Internet Explorer", $s_string) Then $f_found = True
						If StringInStr($o_window.document.title & " - Windows Internet Explorer", $s_string) Then $f_found = True
					EndIf
					If $f_found Then
						If $i_instance = $i_tmp Then
							Return SetError($_IEStatus_Success, 0, $o_window)
						Else
							$i_tmp += 1
						EndIf
					EndIf
				Case "url"
					If StringInStr($o_window.LocationURL, $s_string) > 0 Then
						If $i_instance = $i_tmp Then
							Return SetError($_IEStatus_Success, 0, $o_window)
						Else
							$i_tmp += 1
						EndIf
					EndIf
				Case "text"
					If StringInStr($o_window.document.body.innerText, $s_string) > 0 Then
						If $i_instance = $i_tmp Then
							Return SetError($_IEStatus_Success, 0, $o_window)
						Else
							$i_tmp += 1
						EndIf
					EndIf
				Case "html"
					If StringInStr($o_window.document.body.innerHTML, $s_string) > 0 Then
						If $i_instance = $i_tmp Then
							Return SetError($_IEStatus_Success, 0, $o_window)
						Else
							$i_tmp += 1
						EndIf
					EndIf
				Case "hwnd"
					If $i_instance > 1 Then
						$i_instance = 1
						__IEErrorNotify("Warning", "_IEAttach", "$_IEStatus_GeneralError", "$i_instance > 1 invalid with HWnd.  Setting to 1.")
					EndIf
					If _IEPropertyGet($o_window, "hwnd") = $s_string Then
						Return SetError($_IEStatus_Success, 0, $o_window)
					EndIf
				Case Else
					; Invalid Mode
					__IEErrorNotify("Error", "_IEAttach", "$_IEStatus_InvalidValue", "Invalid Mode Specified")
					Return SetError($_IEStatus_InvalidValue, 2, 0)
			EndSwitch
		EndIf
	Next
	__IEErrorNotify("Warning", "_IEAttach", "$_IEStatus_NoMatch")
	Return SetError($_IEStatus_NoMatch, 1, 0)
EndFunc   ;==>_IEAttach

; #FUNCTION# ====================================================================================================================
; Name...........: _IELoadWait
; Description ...: Wait for a browser page load to complete before returning
; Parameters ....: $o_object 	- Object variable of an InternetExplorer.Application
;				   $i_delay	    - Optional: Milliseconds to wait before checking status
;				   $i_timeout	- Optional: Period of time to wait before exiting function
;									(default = 300000 ms aka 5 min)
; Return values .: On Success 	- Returns 1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 1 ($_IEStatus_GeneralError) = General Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 6 ($_IEStatus_LoadWaitTimeout) = Load Wait Timeout
;								- 8 ($_IEStatus_AccessIsDenied) = Access Is Denied
;								- 9 ($_IEStatus_ClientDisconnected) = Client Disconnected
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
;
; Remarks .......: Error codes are found in Winerror.h supplied with Visual C++ and also on MSDN
;					http://support.microsoft.com/kb/186063
;
;					There appear to be multiple error numbers besides 169 assigned to the "Access is Denied" description. This version
;					uses an OR condition rather than an AND to try to capture these.  This will be an issue in non-English language
;					versions of windows where the description string will not match for those other error numbers.  More research needed.
; ===============================================================================================================================
Func _IELoadWait(ByRef $o_object, $i_delay = 0, $i_timeout = -1)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IELoadWait", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf

	If Not __IEIsObjType($o_object, "browserdom") Then
		__IEErrorNotify("Error", "_IELoadWait", "$_IEStatus_InvalidObjectType", ObjName($o_object))
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf

	Local $oTemp, $f_Abort = False, $i_ErrorStatusCode = $_IEStatus_Success

	; Setup internal error handler to Trap COM errors, turn off error notification
	Local $status = __IEInternalErrorHandlerRegister()
	If Not $status Then __IEErrorNotify("Warning", "_IELoadWait", _
			"Cannot register internal error handler, cannot trap COM errors", _
			"Use _IEErrorHandlerRegister() to register a user error handler")
	Local $f_NotifyStatus = _IEErrorNotify() ; save current error notify status
	_IEErrorNotify(False)

	Sleep($i_delay)
	;
	Local $IELoadWaitTimer = TimerInit()
	If $i_timeout = -1 Then $i_timeout = $__IELoadWaitTimeout

	Select
		Case __IEIsObjType($o_object, "browser"); InternetExplorer
			While Not (String($o_object.readyState) = "complete" Or $o_object.readyState = 4 Or $f_Abort)
				; Trap unrecoverable COM errors
				If (TimerDiff($IELoadWaitTimer) > $i_timeout) Then
					$i_ErrorStatusCode = $_IEStatus_LoadWaitTimeout
					$f_Abort = True
				EndIf
				If @error = $_IEStatus_ComError And __IEComErrorUnrecoverable() Then
					$i_ErrorStatusCode = __IEComErrorUnrecoverable()
					$f_Abort = True
				EndIf
				Sleep(100)
			WEnd
			While Not (String($o_object.document.readyState) = "complete" Or $o_object.document.readyState = 4 Or $f_Abort)
				If (TimerDiff($IELoadWaitTimer) > $i_timeout) Then
					$i_ErrorStatusCode = $_IEStatus_LoadWaitTimeout
					$f_Abort = True
				EndIf
				; Trap unrecoverable COM errors
				If @error = $_IEStatus_ComError And __IEComErrorUnrecoverable() Then
					$i_ErrorStatusCode = __IEComErrorUnrecoverable()
					$f_Abort = True
				EndIf
				Sleep(100)
			WEnd
		Case __IEIsObjType($o_object, "window") ; Window, Frame, iFrame
			While Not (String($o_object.document.readyState) = "complete" Or $o_object.document.readyState = 4 Or $f_Abort)
				If (TimerDiff($IELoadWaitTimer) > $i_timeout) Then
					$i_ErrorStatusCode = $_IEStatus_LoadWaitTimeout
					$f_Abort = True
				EndIf
				; Trap unrecoverable COM errors
				If @error = $_IEStatus_ComError And __IEComErrorUnrecoverable() Then
					$i_ErrorStatusCode = __IEComErrorUnrecoverable()
					$f_Abort = True
				EndIf
				Sleep(100)
			WEnd
			While Not (String($o_object.top.document.readyState) = "complete" Or $o_object.top.document.readyState = 4 Or $f_Abort)
				If (TimerDiff($IELoadWaitTimer) > $i_timeout) Then
					$i_ErrorStatusCode = $_IEStatus_LoadWaitTimeout
					$f_Abort = True
				EndIf
				; Trap unrecoverable COM errors
				If @error = $_IEStatus_ComError And __IEComErrorUnrecoverable() Then
					$i_ErrorStatusCode = __IEComErrorUnrecoverable()
					$f_Abort = True
				EndIf
				Sleep(100)
			WEnd
		Case __IEIsObjType($o_object, "document") ; Document
			$oTemp = $o_object.parentWindow
			While Not (String($oTemp.document.readyState) = "complete" Or $oTemp.document.readyState = 4 Or $f_Abort)
				If (TimerDiff($IELoadWaitTimer) > $i_timeout) Then
					$i_ErrorStatusCode = $_IEStatus_LoadWaitTimeout
					$f_Abort = True
				EndIf
				; Trap unrecoverable COM errors
				If @error = $_IEStatus_ComError And __IEComErrorUnrecoverable() Then
					$i_ErrorStatusCode = __IEComErrorUnrecoverable()
					$f_Abort = True
				EndIf
				Sleep(100)
			WEnd
			While Not (String($oTemp.top.document.readyState) = "complete" Or $oTemp.top.document.readyState = 4 Or $f_Abort)
				If (TimerDiff($IELoadWaitTimer) > $i_timeout) Then
					$i_ErrorStatusCode = $_IEStatus_LoadWaitTimeout
					$f_Abort = True
				EndIf
				; Trap unrecoverable COM errors
				If @error = $_IEStatus_ComError And __IEComErrorUnrecoverable() Then
					$i_ErrorStatusCode = __IEComErrorUnrecoverable()
					$f_Abort = True
				EndIf
				Sleep(100)
			WEnd
		Case Else ; this should work with any other DOM object
			$oTemp = $o_object.document.parentWindow
			While Not (String($oTemp.document.readyState) = "complete" Or $oTemp.document.readyState = 4 Or $f_Abort)
				If (TimerDiff($IELoadWaitTimer) > $i_timeout) Then
					$i_ErrorStatusCode = $_IEStatus_LoadWaitTimeout
					$f_Abort = True
				EndIf
				; Trap unrecoverable COM errors
				If @error = $_IEStatus_ComError And __IEComErrorUnrecoverable() Then
					$i_ErrorStatusCode = __IEComErrorUnrecoverable()
					$f_Abort = True
				EndIf
				Sleep(100)
			WEnd
			While Not (String($oTemp.top.document.readyState) = "complete" Or $o_object.top.document.readyState = 4 Or $f_Abort)
				If (TimerDiff($IELoadWaitTimer) > $i_timeout) Then
					$i_ErrorStatusCode = $_IEStatus_LoadWaitTimeout
					$f_Abort = True
				EndIf
				; Trap unrecoverable COM errors
				If @error = $_IEStatus_ComError And __IEComErrorUnrecoverable() Then
					$i_ErrorStatusCode = __IEComErrorUnrecoverable()
					$f_Abort = True
				EndIf
				Sleep(100)
			WEnd
	EndSelect

	; restore error notify and error handler status
	_IEErrorNotify($f_NotifyStatus) ; restore notification status
	__IEInternalErrorHandlerDeRegister()

	Switch $i_ErrorStatusCode
		Case $_IEStatus_Success
			Return SetError($_IEStatus_Success, 0, 1)
		Case $_IEStatus_LoadWaitTimeout
			__IEErrorNotify("Warning", "_IELoadWait", "$_IEStatus_LoadWaitTimeout")
			Return SetError($_IEStatus_LoadWaitTimeout, 3, 0)
		Case $_IEStatus_AccessIsDenied
			__IEErrorNotify("Warning", "_IELoadWait", "$_IEStatus_AccessIsDenied", _
					"Cannot verify readyState.  Likely casue: cross-site scripting security restriction.")

			Return SetError($_IEStatus_AccessIsDenied, 0, 0)
		Case $_IEStatus_ClientDisconnected
			__IEErrorNotify("Error", "_IELoadWait", "$_IEStatus_ClientDisconnected", _
					"Browser has been deleted prior to operation.")
			Return SetError($_IEStatus_ClientDisconnected, 0, 0)
		Case Else
			__IEErrorNotify("Error", "_IELoadWait", "$_IEStatus_GeneralError", "Invalid Error Status - Notify IE.au3 developer")
			Return SetError($_IEStatus_GeneralError, 0, 0)
	EndSwitch
EndFunc   ;==>_IELoadWait

; #FUNCTION# ====================================================================================================================
; Name...........: _IELoadWaitTimeout
; Description ...: Retrieve or set the current value in milliseconds _IELoadWait will try before timing out
; Parameters ....: $i_timeout	- Optional: retrieve or specify the number of milliseconds
;								- 0 or positive integer sets timeout to this value
;								- -1 = (Default) returns the current timeout value
;									(stored in global variable $__IELoadWaitTimeout)
; Return values .: On Success 	- If $i_timeout = -1, returns the current timeout value, else returns 1
;                  On Failure 	- None
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IELoadWaitTimeout($i_timeout = -1)
	If $i_timeout = -1 Then
		Return SetError($_IEStatus_Success, 0, $__IELoadWaitTimeout)
	Else
		$__IELoadWaitTimeout = $i_timeout
		Return SetError($_IEStatus_Success, 0, 1)
	EndIf
EndFunc   ;==>_IELoadWaitTimeout

#endregion Core functions
#region Frame Functions
; Security Note on Frame functions:
; Note that security restriction in Internet Explorer related to cross-site scripting
; between frames can cause serious problems with the frame functions.  Functions that
; work connected to one site will fail when connected to another depending on the sites
; referenced in the frames.  In general, if all the referenced pages are on the same
; webserver these functions should work as described; if not, unexpected COM failures
; can occur.
; #FUNCTION# ====================================================================================================================
; Name...........: _IEIsFrameSet
; Description ...: Checks to see if the specified Window contains a FrameSet
; Parameters ....: $o_object 	- Object variable of an InternetExplorer.Application, Window or Frame object
; Return values .: On Success 	- Returns 1 if the object references a FrameSet page
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEIsFrameSet(ByRef $o_object)
	; Note: this is more reliable test for a FrameSet than checking the
	; number of frames (document.frames.length) because iFrames embedded on a normal
	; page are included in the frame collection even though it is not a FrameSet
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEIsFrameSet", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If String($o_object.document.body.tagName) = "FRAMESET" Then
		Return SetError($_IEStatus_Success, 0, 1)
	Else
		Return SetError($_IEStatus_Success, 0, 0)
	EndIf
EndFunc   ;==>_IEIsFrameSet

; #FUNCTION# ====================================================================================================================
; Name...........: _IEFrameGetCollection
; Description ...: Returns a collection object containing the frames in a FrameSet or the iFrames on a normal page
; Parameters ....: $o_object 	- Object variable of an InternetExplorer.Application, Window or Frame object
;				   $i_index	- Optional: specifies whether to return a collection or indexed instance
;								- 0 or positive integer returns an indexed instance
;								- -1 = (Default) returns a collection
; Return values .: On Success 	- Returns an object variable containing the Frames collection, @EXTENDED = Frame count
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 5 ($_IEStatus_InvalidValue) = Invalid Value
;								- 7 ($_IEStatus_NoMatch) = No Match
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEFrameGetCollection(ByRef $o_object, $i_index = -1)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEFrameGetCollection", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	$i_index = Number($i_index)
	Select
		Case $i_index = -1
			Return SetError($_IEStatus_Success, $o_object.document.parentwindow.frames.length, _
					$o_object.document.parentwindow.frames)
		Case $i_index > -1 And $i_index < $o_object.document.parentwindow.frames.length
			Return SetError($_IEStatus_Success, $o_object.document.parentwindow.frames.length, _
					$o_object.document.parentwindow.frames.item($i_index))
		Case $i_index < -1
			__IEErrorNotify("Error", "_IEFrameGetCollection", "$_IEStatus_InvalidValue", "$i_index < -1")
			Return SetError($_IEStatus_InvalidValue, 2, 0)
		Case Else
			__IEErrorNotify("Warning", "_IEFrameGetCollection", "$_IEStatus_NoMatch")
			Return SetError($_IEStatus_NoMatch, 2, 0)
	EndSelect
EndFunc   ;==>_IEFrameGetCollection

; #FUNCTION# ====================================================================================================================
; Name...........: _IEFrameGetObjByName
; Description ...: Returns an object reference to a Frame by name
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application, Window or Frame object
;				   $s_name		- Name of the Frame you wish to match
; Return values .: On Success 	- Returns an object variable pointing to the Window object in a Frame, @EXTENDED = Frame count
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 7 ($_IEStatus_NoMatch) = No Match
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEFrameGetObjByName(ByRef $o_object, $s_Name)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEFrameGetObjByName", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	Local $oTemp, $oFrames

	If Not __IEIsObjType($o_object, "browserdom") Then
		__IEErrorNotify("Error", "_IEFrameGetObjByName", "$_IEStatus_InvalidObjectType")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf

	If __IEIsObjType($o_object, "document") Then
		$oTemp = $o_object.parentWindow
	Else
		$oTemp = $o_object.document.parentWindow
	EndIf

	If _IEIsFrameSet($oTemp) Then
		$oFrames = _IETagNameGetCollection($oTemp, "frame")
	Else
		$oFrames = _IETagNameGetCollection($oTemp, "iframe")
	EndIf

	If $oFrames.length Then
		For $oFrame In $oFrames
			If $oFrame.name = $s_Name Then Return SetError($_IEStatus_Success, 0, $oTemp.frames($s_Name))
		Next
		__IEErrorNotify("Warning", "_IEFrameGetObjByName", "$_IEStatus_NoMatch", "No frames matching name")
		Return SetError($_IEStatus_NoMatch, 2, 0)
	Else
		__IEErrorNotify("Warning", "_IEFrameGetObjByName", "$_IEStatus_NoMatch", "No Frames found")
		Return SetError($_IEStatus_NoMatch, 2, 0)
	EndIf
EndFunc   ;==>_IEFrameGetObjByName

#endregion Frame Functions
#region Link functions
; #FUNCTION# ====================================================================================================================
; Name...........: _IELinkClickByText
; Description ...: Simulate a mouse click on a link with text sub-string matching the string provided
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application, Window or Frame object
;				   $s_linkText	- Text displayed on the web page for the desired link to click
;				   $i_index	- Optional: If the link text occurs more than once, specify which instance
;									you want to click by 0-based index
;				   $f_wait 	- Optional: specifies whether to wait for page to load before returning
;									0 = Return immediately, not waiting for page to load
;									1 = (Default) Wait for page load to complete before returning
; Return values .: On Success 	- Returns -1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 1 ($_IEStatus_GeneralError) = General Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 6 ($_IEStatus_LoadWaitTimeout) = Load Wait Timeout
;								- 7 ($_IEStatus_NoMatch) = No Match
;								- 8 ($_IEStatus_AccessIsDenied) = Access Is Denied
;								- 9 ($_IEStatus_ClientDisconnected) = Client Disconnected
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IELinkClickByText(ByRef $o_object, $s_linkText, $i_index = 0, $f_wait = 1)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IELinkClickByText", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	Local $found = 0, $linktext, $links = $o_object.document.links
	$i_index = Number($i_index)
	For $link In $links
		$linktext = $link.outerText & "" ; Append empty string to prevent problem with no outerText (image) links
		If $linktext = $s_linkText Then
			If ($found = $i_index) Then
				$link.click()
				If $f_wait Then
					_IELoadWait($o_object)
					Return SetError(@error, 0, -1)
				EndIf
				Return SetError($_IEStatus_Success, 0, -1)
			EndIf
			$found = $found + 1
		EndIf
	Next
	__IEErrorNotify("Warning", "_IELinkClickByText", "$_IEStatus_NoMatch")
	Return SetError($_IEStatus_NoMatch, 0, 0) ; Could be caused by parameter 2, 3 or both
EndFunc   ;==>_IELinkClickByText

; #FUNCTION# ====================================================================================================================
; Name...........: _IELinkClickByIndex
; Description ...: Simulate a mouse click on a link by 0-based index (in source order)
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application, Window or Frame object
;				   $i_index	- Optional: 0-based index of the link you wish to match
;				   $f_wait 	- Optional: specifies whether to wait for page to load before returning
;									0 = Return immediately, not waiting for page to load
;									1 = (Default) Wait for page load to complete before returning
; Return values .: On Success 	- Returns -1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 1 ($_IEStatus_GeneralError) = General Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 6 ($_IEStatus_LoadWaitTimeout) = Load Wait Timeout
;								- 7 ($_IEStatus_NoMatch) = No Match
;								- 8 ($_IEStatus_AccessIsDenied) = Access Is Denied
;								- 9 ($_IEStatus_ClientDisconnected) = Client Disconnected
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IELinkClickByIndex(ByRef $o_object, $i_index, $f_wait = 1)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IELinkClickByIndex", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	Local $oLinks = $o_object.document.links, $oLink
	$i_index = Number($i_index)
	If ($i_index >= 0) And ($i_index <= $oLinks.length - 1) Then
		$oLink = $oLinks($i_index)
		$oLink.click()
		If $f_wait Then
			_IELoadWait($o_object)
			Return SetError(@error, 0, -1)
		EndIf
		Return SetError($_IEStatus_Success, 0, -1)
	Else
		__IEErrorNotify("Warning", "_IELinkClickByIndex", "$_IEStatus_NoMatch")
		Return SetError($_IEStatus_NoMatch, 2, 0)
	EndIf
EndFunc   ;==>_IELinkClickByIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _IELinkGetCollection
; Description ...: Returns a collection object containing all links in the document
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application, Window or Frame object
;				   $i_index	- Optional: specifies whether to return a collection or indexed instance
;								- 0 or positive integer returns an indexed instance
;								- -1 = (Default) returns a collection
; Return values .: On Success 	- Returns an object collection of all links in the document, @EXTENDED = link count
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 5 ($_IEStatus_InvalidValue) = Invalid Value
;								- 7 ($_IEStatus_NoMatch) = No Match
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IELinkGetCollection(ByRef $o_object, $i_index = -1)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IELinkGetCollection", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	$i_index = Number($i_index)
	Select
		Case $i_index = -1
			Return SetError($_IEStatus_Success, $o_object.document.links.length, _
					$o_object.document.links)
		Case $i_index > -1 And $i_index < $o_object.document.links.length
			Return SetError($_IEStatus_Success, $o_object.document.links.length, _
					$o_object.document.links.item($i_index))
		Case $i_index < -1
			__IEErrorNotify("Error", "_IELinkGetCollection", "$_IEStatus_InvalidValue")
			Return SetError($_IEStatus_InvalidValue, 2, 0)
		Case Else
			__IEErrorNotify("Warning", "_IELinkGetCollection", "$_IEStatus_NoMatch")
			Return SetError($_IEStatus_NoMatch, 2, 0)
	EndSelect
EndFunc   ;==>_IELinkGetCollection
#endregion Link functions
#region Image functions
; #FUNCTION# ====================================================================================================================
; Name...........: _IEImgClick
; Description ...: Simulate a mouse click on an image.  Match by sub-string match of alt text, name or src
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application, Window or Frame object
;				   $s_linkText	- Text to match the content of the attribute specified in $s_mode
;				   $s_mode		- Optional: specifies search mode
;									src = (Default) match the url of the image
;									name = match the name of the image
;									alt = match the alternate text of the image
;				   $i_index	- Optional: If the img text occurs more than once, specify which instance
;									you want to click by 0-based index
;				   $f_wait 	- Optional: specifies whether to wait for page to load before returning
;									0 = Return immediately, not waiting for page to load
;									1 = (Default) Wait for page load to complete before returning
; Return values .: On Success 	- Returns -1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 1 ($_IEStatus_GeneralError) = General Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 5 ($_IEStatus_InvalidValue) = Invalid Value
;								- 6 ($_IEStatus_LoadWaitTimeout) = Load Wait Timeout
;								- 7 ($_IEStatus_NoMatch) = No Match
;								- 8 ($_IEStatus_AccessIsDenied) = Access Is Denied
;								- 9 ($_IEStatus_ClientDisconnected) = Client Disconnected
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEImgClick(ByRef $o_object, $s_linkText, $s_mode = "src", $i_index = 0, $f_wait = 1)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEImgClick", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	Local $linktext, $found = 0, $imgs = $o_object.document.images
	$s_mode = StringLower($s_mode)
	$i_index = Number($i_index)
	For $img In $imgs
		Select
			Case $s_mode = "alt"
				$linktext = $img.alt
			Case $s_mode = "name"
				$linktext = $img.name
			Case $s_mode = "src"
				$linktext = $img.src
			Case Else
				__IEErrorNotify("Error", "_IEImgClick", "$_IEStatus_InvalidValue", "Invalid mode: " & $s_mode)
				Return SetError($_IEStatus_InvalidValue, 3, 0)
		EndSelect
		If StringInStr($linktext, $s_linkText) Then
			If ($found = $i_index) Then
				$img.click()
				If $f_wait Then
					_IELoadWait($o_object)
					Return SetError(@error, 0, -1)
				EndIf
				Return SetError($_IEStatus_Success, 0, -1)
			EndIf
			$found = $found + 1
		EndIf
	Next
	__IEErrorNotify("Warning", "_IEImgClick", "$_IEStatus_NoMatch")
	Return SetError($_IEStatus_NoMatch, 0, 0) ; Could be caused by parameter 2, 4 or both
EndFunc   ;==>_IEImgClick

; #FUNCTION# ====================================================================================================================
; Name...........: _IEImgGetCollection
; Description ...: Returns a collection object variable representing the IMG tags in the document
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application, Window, Frame or iFrame object
;				   $i_index	- Optional: specifies whether to return a collection or indexed instance
;								- 0 or positive integer returns an indexed instance
;								- -1 = (Default) returns a collection
; Return values .: On Success 	- Returns an object variable with a collection of all IMG tags in the document, @EXTENDED = img count
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 5 ($_IEStatus_InvalidValue) = Invalid Value
;								- 7 ($_IEStatus_NoMatch) = No Match
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEImgGetCollection(ByRef $o_object, $i_index = -1)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEImgGetCollection", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	Local $oTemp = _IEDocGetObj($o_object)
	$i_index = Number($i_index)
	Select
		Case $i_index = -1
			Return SetError($_IEStatus_Success, $oTemp.images.length, $oTemp.images)
		Case $i_index > -1 And $i_index < $oTemp.images.length
			Return SetError($_IEStatus_Success, $oTemp.images.length, $oTemp.images.item($i_index))
		Case $i_index < -1
			__IEErrorNotify("Error", "_IEImgGetCollection", "$_IEStatus_InvalidValue", "$i_index < -1")
			Return SetError($_IEStatus_InvalidValue, 2, 0)
		Case Else
			__IEErrorNotify("Warning", "_IEImgGetCollection", "$_IEStatus_NoMatch")
			Return SetError($_IEStatus_NoMatch, 1, 0)
	EndSelect
EndFunc   ;==>_IEImgGetCollection

#endregion Image functions
#region Form functions
; #FUNCTION# ====================================================================================================================
; Name...........: _IEFormGetCollection
; Description ...: Returns a collection object variable representing the Forms in the document
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application, Window, Frame or iFrame object
;				   $i_index	- Optional: specifies whether to return a collection or indexed instance
;								- 0 or positive integer returns an indexed instance
;								- -1 = (Default) returns a collection
; Return values .: On Success	- Returns an object variable with a collection of all forms in the document, @EXTENDED = form count
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 5 ($_IEStatus_InvalidValue) = Invalid Value
;								- 7 ($_IEStatus_NoMatch) = No Match
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEFormGetCollection(ByRef $o_object, $i_index = -1)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEFormGetCollection", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	Local $oTemp = _IEDocGetObj($o_object)
	$i_index = Number($i_index)
	Select
		Case $i_index = -1
			Return SetError($_IEStatus_Success, $oTemp.forms.length, $oTemp.forms)
		Case $i_index > -1 And $i_index < $oTemp.forms.length
			Return SetError($_IEStatus_Success, $oTemp.forms.length, $oTemp.forms.item($i_index))
		Case $i_index < -1
			__IEErrorNotify("Error", "_IEFormGetCollection", "$_IEStatus_InvalidValue", "$i_index < -1")
			Return SetError($_IEStatus_InvalidValue, 2, 0)
		Case Else
			__IEErrorNotify("Warning", "_IEFormGetCollection", "$_IEStatus_NoMatch")
			Return SetError($_IEStatus_NoMatch, 1, 0)
	EndSelect
EndFunc   ;==>_IEFormGetCollection

; #FUNCTION# ====================================================================================================================
; Name...........: _IEFormGetObjByName
; Description ...: Returns an object reference to a Form by name
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application, Window or Frame object
;				   $s_name		- Specifies the name of the Form you wish to match
;				   $i_index	- Optional: If Form name occurs more than once, specifies instance by 0-based index
;								- 0 (Default) or positive integer returns an indexed instance
;								- -1 returns a collection of the specified Forms
; Return values .: On Success 	- Returns an object variable pointing to the Form object, @EXTENDED = form count
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 7 ($_IEStatus_NoMatch) = No Match
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEFormGetObjByName(ByRef $o_object, $s_Name, $i_index = 0)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEFormGetObjByName", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	;----- Determine valid collection length
	Local $i_length = 0
	Local $o_col = $o_object.document.forms.item($s_Name)
	If IsObj($o_col) Then
		If __IEIsObjType($o_col, "elementcollection") Then
			$i_length = $o_col.length
		Else
			$i_length = 1
		EndIf
	EndIf
	;-----
	$i_index = Number($i_index)
	If $i_index = -1 Then
		Return SetError($_IEStatus_Success, $i_length, $o_object.document.forms.item($s_Name))
	Else
		If IsObj($o_object.document.forms.item($s_Name, $i_index)) Then
			Return SetError($_IEStatus_Success, $i_length, $o_object.document.forms.item($s_Name, $i_index))
		Else
			__IEErrorNotify("Warning", "_IEFormGetObjByName", "$_IEStatus_NoMatch")
			Return SetError($_IEStatus_NoMatch, 0, 0) ; Could be caused by parameter 2, 3 or both
		EndIf
	EndIf
EndFunc   ;==>_IEFormGetObjByName

; #FUNCTION# ====================================================================================================================
; Name...........: _IEFormElementGetCollection
; Description ...: Returns a collection object variable representing all Form Elements within a given Form
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application, Form object
;				   $i_index	- Optional: specifies whether to return a collection or indexed instance
;								- 0 or positive integer returns an indexed instance
;								- -1 = (Default) returns a collection
; Return values .: On Success 	- Returns an object variable containing the Form Elements collection, @EXTENDED = form element count
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 5 ($_IEStatus_InvalidValue) = Invalid Value
;								- 7 ($_IEStatus_NoMatch) = No Match
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEFormElementGetCollection(ByRef $o_object, $i_index = -1)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEFormElementGetCollection", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __IEIsObjType($o_object, "form") Then
		__IEErrorNotify("Error", "_IEFormElementGetCollection", "$_IEStatus_InvalidObjectType")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	$i_index = Number($i_index)
	Select
		Case $i_index = -1
			Return SetError($_IEStatus_Success, $o_object.elements.length, $o_object.elements)
		Case $i_index > -1 And $i_index < $o_object.elements.length
			Return SetError($_IEStatus_Success, $o_object.elements.length, $o_object.elements.item($i_index))
		Case $i_index < -1
			__IEErrorNotify("Error", "_IEFormElementGetCollection", "$_IEStatus_InvalidValue", "$i_index < -1")
			Return SetError($_IEStatus_InvalidValue, 2, 0)
		Case Else
			Return SetError($_IEStatus_NoMatch, 1, 0)
	EndSelect
EndFunc   ;==>_IEFormElementGetCollection

; #FUNCTION# ====================================================================================================================
; Name...........: _IEFormElementGetObjByName
; Description ...: Returns an object reference to a Form Element by name
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application, Form object
;				   $s_name		- Specifies the name of the Form Element you wish to match
;				   $i_index	- Optional: If the Form Element name occurs more than once, specifies instance by 0-based index
;								- 0 (Default) or positive integer returns an indexed instance
;								- -1 returns a collection of the specified Form Elements
; Return values .: On Success 	- Returns an object variable pointing to the Form Element object, @EXTENDED = form count
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 7 ($_IEStatus_NoMatch) = No Match
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEFormElementGetObjByName(ByRef $o_object, $s_Name, $i_index = 0)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEFormElementGetObjByName", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __IEIsObjType($o_object, "form") Then
		__IEErrorNotify("Error", "_IEFormElementGetObjByName", "$_IEStatus_InvalidObjectType")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	;----- Determine valid collection length
	Local $i_length = 0
	Local $o_col = $o_object.elements.item($s_Name)
	If IsObj($o_col) Then
		If __IEIsObjType($o_col, "elementcollection") Then
			$i_length = $o_col.length
		Else
			$i_length = 1
		EndIf
	EndIf
	;-----
	$i_index = Number($i_index)
	If $i_index = -1 Then
		Return SetError($_IEStatus_Success, $i_length, $o_object.elements.item($s_Name))
	Else
		If IsObj($o_object.elements.item($s_Name, $i_index)) Then
			Return SetError($_IEStatus_Success, $i_length, $o_object.elements.item($s_Name, $i_index))
		Else
			__IEErrorNotify("Warning", "_IEFormElementGetObjByName", "$_IEStatus_NoMatch")
			Return SetError($_IEStatus_NoMatch, 0, 0) ; Could be caused by parameter 2, 3 or both
		EndIf
	EndIf
EndFunc   ;==>_IEFormElementGetObjByName

; #FUNCTION# ====================================================================================================================
; Name...........: _IEFormElementGetValue
; Description ...: Returns the value of a given Form Element
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application, Form Element object
; Return values .: On Success 	- Returns the string value of the given Form Element
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEFormElementGetValue(ByRef $o_object)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEFormElementGetValue", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __IEIsObjType($o_object, "forminputelement") Then
		__IEErrorNotify("Error", "_IEFormElementGetValue", "$_IEStatus_InvalidObjectType")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	SetError($_IEStatus_Success)
	; Any non-NULL value is True, If the value is NULL, AutoIt represents it as integer 0 - aka False
	If $o_object.value Then
		Return $o_object.value
	Else
		Return ""
	EndIf
EndFunc   ;==>_IEFormElementGetValue

; #FUNCTION# ====================================================================================================================
; Name...........: _IEFormElementSetValue
; Description ...: Set the value of a specified Form Element
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application, Form Element object
;				   $s_newvalue	- The new value to be set into the Form Element
;				   $f_fireEvent- Optional: specifies whether to fire an OnChange event after changing value
;										0 = Do not fire OnChange event after setting value
;										1 = (Default) fire OnChange event after setting value
; Return values .: On Success 	- Returns 1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEFormElementSetValue(ByRef $o_object, $s_newvalue, $f_fireEvent = 1)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEFormElementSetValue", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __IEIsObjType($o_object, "forminputelement") Then
		__IEErrorNotify("Error", "_IEFormElementSetValue", "$_IEStatus_InvalidObjectType")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	If String($o_object.type) = "file" Then
		__IEErrorNotify("Error", "_IEFormElementSetValue", "$_IEStatus_InvalidObjectType", "Browser securuty prevents SetValue of TYPE=FILE")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	$o_object.value = $s_newvalue
	If $f_fireEvent Then
		$o_object.fireEvent("OnChange")
		$o_object.fireEvent("OnClick")
	EndIf
	Return SetError($_IEStatus_Success, 0, 1)
EndFunc   ;==>_IEFormElementSetValue

; #FUNCTION# ====================================================================================================================
; Name...........: _IEFormElementOptionSelect
; Description ...: Set the value of a specified form element
; Parameters ....: $o_object	- Form Element Object of type "Select Option"
;				   $s_string	- Value used to match element - treatment based on $s_mode
;				   $f_select	- Optional: specifies whether element should be selected or deselected
;									-1 = Return selected state
;									0 = Deselect the element
;									1 = (Default) Select the element
;				   $s_mode 	- Optional: specifies search mode
;									byValue = (Default) value of the option you wish to select
;									byText	= text of the option you wish to select
;									byIndex = 0-based index of option you wish to select
;				   $f_fireEvent- Optional: specifies whether to fire an OnChange event after changing value
;									0 = do not fire OnChange event after setting value
;									1 = (Default) fire OnChange event after setting value
; Return values .: On Success 	- If $f_select = -1, returns the current selected state, else returns 1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 5 ($_IEStatus_InvalidValue) = Invalid Value
;								- 7 ($_IEStatus_NoMatch) = No Match
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEFormElementOptionSelect(ByRef $o_object, $s_string, $f_select = 1, $s_mode = "byValue", $f_fireEvent = 1)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEFormElementOptionSelect", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __IEIsObjType($o_object, "formselectelement") Then
		__IEErrorNotify("Error", "_IEFormElementOptionSelect", "$_IEStatus_InvalidObjectType")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	Local $oItem, $oItems = $o_object.options, $iNumItems = $o_object.options.length, $f_isMultiple = $o_object.multiple

	Switch $s_mode
		Case "byValue"
			For $oItem In $oItems
				If $oItem.value = $s_string Then
					Switch $f_select
						Case -1
							Return SetError($_IEStatus_Success, 0, $oItem.selected)
						Case 0
							If Not $f_isMultiple Then
								__IEErrorNotify("Error", "_IEFormElementOptionSelect", "$_IEStatus_InvalidValue", _
										"$f_select=0 only valid for type=select multiple")
								SetError($_IEStatus_InvalidValue, 3)
							EndIf
							If $oItem.selected Then
								$oItem.selected = False
								If $f_fireEvent Then
									$o_object.fireEvent("onChange")
									$o_object.fireEvent("OnClick")
								EndIf
							EndIf
							Return SetError($_IEStatus_Success, 0, 1)
						Case 1
							If Not $oItem.selected Then
								$oItem.selected = True
								If $f_fireEvent Then
									$o_object.fireEvent("onChange")
									$o_object.fireEvent("OnClick")
								EndIf
							EndIf
							Return SetError($_IEStatus_Success, 0, 1)
						Case Else
							__IEErrorNotify("Error", "_IEFormElementOptionSelect", "$_IEStatus_InvalidValue", "Invalid $f_select value")
							Return SetError($_IEStatus_InvalidValue, 3, 0)
					EndSwitch
					__IEErrorNotify("Warning", "_IEFormElementOptionSelect", "$_IEStatus_NoMatch", "Value not matched")
					Return SetError($_IEStatus_NoMatch, 2, 0)
				EndIf
			Next
		Case "byText"
			For $oItem In $oItems
				If String($oItem.text) = $s_string Then
					Switch $f_select
						Case -1
							Return SetError($_IEStatus_Success, 0, $oItem.selected)
						Case 0
							If Not $f_isMultiple Then
								__IEErrorNotify("Error", "_IEFormElementOptionSelect", "$_IEStatus_InvalidValue", _
										"$f_select=0 only valid for type=select multiple")
								SetError($_IEStatus_InvalidValue, 3)
							EndIf
							If $oItem.selected Then
								$oItem.selected = False
								If $f_fireEvent Then
									$o_object.fireEvent("onChange")
									$o_object.fireEvent("OnClick")
								EndIf
							EndIf
							Return SetError($_IEStatus_Success, 0, 1)
						Case 1
							If Not $oItem.selected Then
								$oItem.selected = True
								If $f_fireEvent Then
									$o_object.fireEvent("onChange")
									$o_object.fireEvent("OnClick")
								EndIf
							EndIf
							Return SetError($_IEStatus_Success, 0, 1)
						Case Else
							__IEErrorNotify("Error", "_IEFormElementOptionSelect", "$_IEStatus_InvalidValue", "Invalid $f_select value")
							Return SetError($_IEStatus_InvalidValue, 3, 0)
					EndSwitch
					__IEErrorNotify("Warning", "_IEFormElementOptionSelect", "$_IEStatus_NoMatch", "Text not matched")
					Return SetError($_IEStatus_NoMatch, 2, 0)
				EndIf
			Next
		Case "byIndex"
			Local $i_index = Number($s_string)
			If $i_index < 0 Or $i_index >= $iNumItems Then
				__IEErrorNotify("Error", "_IEFormElementOptionSelect", "$_IEStatus_InvalidValue", "Invalid index value, " & $i_index)
				Return SetError($_IEStatus_InvalidValue, 2, 0)
			EndIf
			$oItem = $oItems.item($i_index)
			Switch $f_select
				Case -1
					Return SetError($_IEStatus_Success, 0, $oItems.item($i_index).selected)
				Case 0
					If Not $f_isMultiple Then
						__IEErrorNotify("Error", "_IEFormElementOptionSelect", "$_IEStatus_InvalidValue", _
								"$f_select=0 only valid for type=select multiple")
						SetError($_IEStatus_InvalidValue, 3)
					EndIf
					If $oItem.selected Then
						$oItems.item($i_index).selected = False
						If $f_fireEvent Then
							$o_object.fireEvent("onChange")
							$o_object.fireEvent("OnClick")
						EndIf
					EndIf
					Return SetError($_IEStatus_Success, 0, 1)
				Case 1
					If Not $oItem.selected Then
						$oItems.item($i_index).selected = True
						If $f_fireEvent Then
							$o_object.fireEvent("onChange")
							$o_object.fireEvent("OnClick")
						EndIf
					EndIf
					Return SetError($_IEStatus_Success, 0, 1)
				Case Else
					__IEErrorNotify("Error", "_IEFormElementOptionSelect", "$_IEStatus_InvalidValue", "Invalid $f_select value")
					Return SetError($_IEStatus_InvalidValue, 3, 0)
			EndSwitch
		Case Else
			__IEErrorNotify("Error", "_IEFormElementOptionSelect", "$_IEStatus_InvalidValue", "Invalid Mode")
			Return SetError($_IEStatus_InvalidValue, 4, 0)
	EndSwitch
EndFunc   ;==>_IEFormElementOptionSelect

; #FUNCTION# ====================================================================================================================
; Name...........: _IEFormElementCheckboxSelect
; Description ...: Set the value of a specified form element
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application, Form object
;				   $s_string	- Value used to match element - treatment based on $s_mode
;				   $s_name		- Optional: Name or Id of checkbox(es)
;				   $f_select	- Optional: specifies whether element should be checked or unchecked
;									-1 = Return checked state
;									0 = Uncheck the element
;									1 = (Default) Check the element
;				   $s_mode 	- Optional: specifies search mode
;									byValue = (Default) value of the checkbox you wish to select
;									byIndex = 0-based index of checkbox you wish to select
;				   $f_fireEvent- Optional: specifies whether to fire an OnChange event after changing value
;									0 = do not fire OnChange event after setting value
;									1 = (Default) fire OnChange event after setting value
; Return values .: On Success 	- If $f_select = -1, returns the current checked state, else returns 1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 5 ($_IEStatus_InvalidValue) = Invalid Value
;								- 7 ($_IEStatus_NoMatch) = No Match
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEFormElementCheckBoxSelect(ByRef $o_object, $s_string, $s_Name = "", $f_select = 1, $s_mode = "byValue", $f_fireEvent = 1)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEFormElementCheckboxSelect", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __IEIsObjType($o_object, "form") Then
		__IEErrorNotify("Error", "_IEFormElementCheckboxSelect", "$_IEStatus_InvalidObjectType")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	$s_string = String($s_string)
	$s_Name = String($s_Name)

	Local $oItems
	If $s_Name = "" Then
		$oItems = _IETagNameGetCollection($o_object, "input")
	Else
		$oItems = Execute("$o_object.elements('" & $s_Name & "')")
	EndIf

	If Not IsObj($oItems) Then
		__IEErrorNotify("Warning", "_IEFormElementCheckboxSelect", "$_IEStatus_NoMatch")
		Return SetError($_IEStatus_NoMatch, 3, 0)
	EndIf

	Local $oItem, $f_found = False
	Switch $s_mode
		Case "byValue"
			If __IEIsObjType($oItems, "forminputelement") Then
				$oItem = $oItems
				If String($oItem.type) = "checkbox" And String($oItem.value) = $s_string Then $f_found = True
			Else
				For $oItem In $oItems
					If String($oItem.type) = "checkbox" And String($oItem.value) = $s_string Then
						$f_found = True
						ExitLoop
					EndIf
				Next
			EndIf
		Case "byIndex"
			If __IEIsObjType($oItems, "forminputelement") Then
				$oItem = $oItems
				If String($oItem.type) = "checkbox" And Number($s_string) = 0 Then $f_found = True
			Else
				Local $iCount = 0
				For $oItem In $oItems
					If String($oItem.type) = "checkbox" And Number($s_string) = $iCount Then
						$f_found = True
						ExitLoop
					Else
						If String($oItem.type) = "checkbox" Then $iCount += 1
					EndIf
				Next
			EndIf
		Case Else
			__IEErrorNotify("Error", "_IEFormElementCheckboxSelect", "$_IEStatus_InvalidValue", "Invalid Mode")
			Return SetError($_IEStatus_InvalidValue, 5, 0)
	EndSwitch

	If Not $f_found Then
		__IEErrorNotify("Warning", "_IEFormElementCheckboxSelect", "$_IEStatus_NoMatch")
		Return SetError($_IEStatus_NoMatch, 2, 0)
	EndIf

	Switch $f_select
		Case -1
			Return SetError($_IEStatus_Success, 0, $oItem.checked)
		Case 0
			If $oItem.checked Then
				$oItem.checked = False
				If $f_fireEvent Then
					$oItem.fireEvent("onChange")
					$oItem.fireEvent("OnClick")
				EndIf
			EndIf
			Return SetError($_IEStatus_Success, 0, 1)
		Case 1
			If Not $oItem.checked Then
				$oItem.checked = True
				If $f_fireEvent Then
					$oItem.fireEvent("onChange")
					$oItem.fireEvent("OnClick")
				EndIf
			EndIf
			Return SetError($_IEStatus_Success, 0, 1)
		Case Else
			__IEErrorNotify("Error", "_IEFormElementCheckboxSelect", "$_IEStatus_InvalidValue", "Invalid $f_select value")
			Return SetError($_IEStatus_InvalidValue, 3, 0)
	EndSwitch

EndFunc   ;==>_IEFormElementCheckBoxSelect

; #FUNCTION# ====================================================================================================================
; Name...........: _IEFormElementRadioSelect
; Description ...: Set the value of a specified form element
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application, Form object
;				   $s_string	- Value used to match element - treatment based on $s_mode
;				   $s_name		- Name or Id of Radio Group (required)
;				   $f_select	- Optional: specifies whether element should be selected or deselected
;									-1 = Return selected state
;									0 = Deselect the element
;									1 = (Default) Select the element
;				   $s_mode 	- Optional: specifies search mode
;									byValue = (Default) value of the radio you wish to select
;									byIndex = 0-based index of radio you wish to select
;				   $f_fireEvent- Optional: specifies whether to fire an OnChange event after changing value
;									0 = do not fire OnChange event after setting value
;									1 = (Default) fire OnChange event after setting value
; Return values .: On Success 	- If $f_select = -1, returns the current selected state, else returns 1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 5 ($_IEStatus_InvalidValue) = Invalid Value
;								- 7 ($_IEStatus_NoMatch) = No Match
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEFormElementRadioSelect(ByRef $o_object, $s_string, $s_Name, $f_select = 1, $s_mode = "byValue", $f_fireEvent = 1)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEFormElementRadioSelect", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __IEIsObjType($o_object, "form") Then
		__IEErrorNotify("Error", "_IEFormElementRadioSelect", "$_IEStatus_InvalidObjectType")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	$s_string = String($s_string)
	$s_Name = String($s_Name)

	Local $oItems = Execute("$o_object.elements('" & $s_Name & "')")
	If Not IsObj($oItems) Then
		__IEErrorNotify("Warning", "_IEFormElementRadioSelect", "$_IEStatus_NoMatch")
		Return SetError($_IEStatus_NoMatch, 3, 0)
	EndIf

	Local $oItem, $f_found = False
	Switch $s_mode
		Case "byValue"
			If __IEIsObjType($oItems, "forminputelement") Then
				$oItem = $oItems
				If String($oItem.type) = "radio" And String($oItem.value) = $s_string Then $f_found = True
			Else
				For $oItem In $oItems
					If String($oItem.type) = "radio" And String($oItem.value) = $s_string Then
						$f_found = True
						ExitLoop
					EndIf
				Next
			EndIf
		Case "byIndex"
			If __IEIsObjType($oItems, "forminputelement") Then
				$oItem = $oItems
				If String($oItem.type) = "radio" And Number($s_string) = 0 Then $f_found = True
			Else
				Local $iCount = 0
				For $oItem In $oItems
					If String($oItem.type) = "radio" And Number($s_string) = $iCount Then
						$f_found = True
						ExitLoop
					Else
						$iCount += 1
					EndIf
				Next
			EndIf
		Case Else
			__IEErrorNotify("Error", "_IEFormElementRadioSelect", "$_IEStatus_InvalidValue", "Invalid Mode")
			Return SetError($_IEStatus_InvalidValue, 5, 0)
	EndSwitch

	If Not $f_found Then
		__IEErrorNotify("Warning", "_IEFormElementRadioSelect", "$_IEStatus_NoMatch")
		Return SetError($_IEStatus_NoMatch, 2, 0)
	EndIf

	Switch $f_select
		Case -1
			Return SetError($_IEStatus_Success, 0, $oItem.checked)
		Case 0
			If $oItem.checked Then
				$oItem.checked = False
				If $f_fireEvent Then
					$oItem.fireEvent("onChange")
					$oItem.fireEvent("OnClick")
				EndIf
			EndIf
			Return SetError($_IEStatus_Success, 0, 1)
		Case 1
			If Not $oItem.checked Then
				$oItem.checked = True
				If $f_fireEvent Then
					$oItem.fireEvent("onChange")
					$oItem.fireEvent("OnClick")
				EndIf
			EndIf
			Return SetError($_IEStatus_Success, 0, 1)
		Case Else
			__IEErrorNotify("Error", "_IEFormElementRadioSelect", "$_IEStatus_InvalidValue", "$f_select value invalid")
			Return SetError($_IEStatus_InvalidValue, 4, 0)
	EndSwitch

EndFunc   ;==>_IEFormElementRadioSelect

; #FUNCTION# ====================================================================================================================
; Name...........: _IEFormImageClick
; Description ...: Simulate a mouse click on an <INPUT TYPE="Image">.  Match by sub-string match of alt text, name or src
; Parameters ....: $o_object	- Object variable of any DOM element (will be converted to the associated document object)
;				   $s_linkText	- Value used to match element - treatment based on $s_mode
;				   $s_mode		- Optional: specifies search mode
;									src = (Default) match the url of the image
;									name = match the name of the image
;									alt = match the alternate text of the image
;				   $i_index	- Optional: If the img text occurs more than once, specifies which instance
;									you want to click by 0-based index
;				   $f_wait 	- Optional: specifies whether to wait for page to load before returning
;									0 = Return immediately, not waiting for page to load
;									1 = (Default) Wait for page load to complete before returning
; Return values .: On Success 	- Returns -1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 1 ($_IEStatus_GeneralError) = General Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 5 ($_IEStatus_InvalidValue) = Invalid Value
;								- 6 ($_IEStatus_LoadWaitTimeout) = Load Wait Timeout
;								- 7 ($_IEStatus_NoMatch) = No Match
;								- 8 ($_IEStatus_AccessIsDenied) = Access Is Denied
;								- 9 ($_IEStatus_ClientDisconnected) = Client Disconnected
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEFormImageClick(ByRef $o_object, $s_linkText, $s_mode = "src", $i_index = 0, $f_wait = 1)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEFormImageClick", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	Local $linktext, $found = 0
	Local $oTemp = _IEDocGetObj($o_object)
	Local $imgs = _IETagNameGetCollection($oTemp, "input")
	$s_mode = StringLower($s_mode)
	$i_index = Number($i_index)
	For $img In $imgs
		If String($img.type) = "image" Then
			Select
				Case $s_mode = "alt"
					$linktext = $img.alt
				Case $s_mode = "name"
					$linktext = $img.name
				Case $s_mode = "src"
					$linktext = $img.src
				Case Else
					__IEErrorNotify("Error", "_IEFormImageClick", "$_IEStatus_InvalidValue", "Invalid mode: " & $s_mode)
					Return SetError($_IEStatus_InvalidValue, 3, 0)
			EndSelect
			If StringInStr($linktext, $s_linkText) Then
				If ($found = $i_index) Then
					$img.click()
					If $f_wait Then
						_IELoadWait($o_object)
						Return SetError(@error, 0, -1)
					EndIf
					Return SetError($_IEStatus_Success, 0, -1)
				EndIf
				$found = $found + 1
			EndIf
		EndIf
	Next
	__IEErrorNotify("Warning", "_IEFormImageClick", "$_IEStatus_NoMatch")
	Return SetError($_IEStatus_NoMatch, 2, 0)
EndFunc   ;==>_IEFormImageClick

; #FUNCTION# ====================================================================================================================
; Name...........: _IEFormSubmit
; Description ...: Submit a specified Form
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application, Form object
;				   $f_wait		- Optional: specifies whether to wait for page to load before returning
;									0 = Return immediately, not waiting for page to load
;									1 = (Default) Wait for page load to complete before returning
; Return values .: On Success 	- Returns -1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 1 ($_IEStatus_GeneralError) = General Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 6 ($_IEStatus_LoadWaitTimeout) = Load Wait Timeout
;								- 8 ($_IEStatus_AccessIsDenied) = Access Is Denied
;								- 9 ($_IEStatus_ClientDisconnected) = Client Disconnected
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEFormSubmit(ByRef $o_object, $f_wait = 1)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEFormSubmit", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __IEIsObjType($o_object, "form") Then
		__IEErrorNotify("Error", "_IEFormSubmit", "$_IEStatus_InvalidObjectType")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf
	;

	Local $o_window = $o_object.document.parentWindow
	$o_object.submit()
	If $f_wait Then
		_IELoadWait($o_window)
		Return SetError(@error, 0, -1)
	EndIf
	Return SetError($_IEStatus_Success, 0, -1)
EndFunc   ;==>_IEFormSubmit

; #FUNCTION# ====================================================================================================================
; Name...........: _IEFormReset
; Description ...: Reset a specified Form
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application, Form object
; Return values .: On Success 	- Returns 1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEFormReset(ByRef $o_object)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEFormReset", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __IEIsObjType($o_object, "form") Then
		__IEErrorNotify("Error", "_IEFormReset", "$_IEStatus_InvalidObjectType")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	$o_object.reset()
	Return SetError($_IEStatus_Success, 0, 1)
EndFunc   ;==>_IEFormReset
#endregion Form functions
#region Table functions
; #FUNCTION# ====================================================================================================================
; Name...........: _IETableGetCollection
; Description ...: Returns a collection object variable representing all the tables in a document
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application, Window or Frame object
;				   $i_index	- Optional: specifies whether to return a collection or indexed instance
;								- 0 or positive integer returns an indexed instance
;								- -1 = (Default) returns a collection
; Return values .: On Success 	- Returns an object collection of all tables in the document, @EXTENDED = table count
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 5 ($_IEStatus_InvalidValue) = Invalid Value
;								- 7 ($_IEStatus_NoMatch) = No Match
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IETableGetCollection(ByRef $o_object, $i_index = -1)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IETableGetCollection", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	$i_index = Number($i_index)
	Select
		Case $i_index = -1
			Return SetError($_IEStatus_Success, $o_object.document.GetElementsByTagName("table").length, _
					$o_object.document.GetElementsByTagName("table"))
		Case $i_index > -1 And $i_index < $o_object.document.GetElementsByTagName("table").length
			Return SetError($_IEStatus_Success, $o_object.document.GetElementsByTagName("table").length, _
					$o_object.document.GetElementsByTagName("table").item($i_index))
		Case $i_index < -1
			__IEErrorNotify("Error", "_IETableGetCollection", "$_IEStatus_InvalidValue", "$i_index < -1")
			Return SetError($_IEStatus_InvalidValue, 2, 0)
		Case Else
			__IEErrorNotify("Warning", "_IETableGetCollection", "$_IEStatus_NoMatch")
			Return SetError($_IEStatus_NoMatch, 1, 0)
	EndSelect
EndFunc   ;==>_IETableGetCollection

; #FUNCTION# ====================================================================================================================
; Name...........: _IETableWriteToArray
; Description ...: Reads the contents of a Table into an array
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application, Table object
;				   $f_transpose- Boolean value.  If True, swap rows and columns in output array
; Return values .: On Success 	- Returns a 2-dimensional array containing the contents of the Table
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IETableWriteToArray(ByRef $o_object, $f_transpose = False)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IETableWriteToArray", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __IEIsObjType($o_object, "table") Then
		__IEErrorNotify("Error", "_IETableWriteToArray", "$_IEStatus_InvalidObjectType")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	Local $i_cols = 0, $tds, $i_col
	Local $trs = $o_object.rows
	For $tr In $trs
		$tds = $tr.cells
		$i_col = 0
		For $td In $tds
			$i_col = $i_col + $td.colSpan
		Next
		If $i_col > $i_cols Then $i_cols = $i_col
	Next
	Local $i_rows = $trs.length
	Local $a_TableCells[$i_cols][$i_rows]
	Local $col, $row = 0
	For $tr In $trs
		$tds = $tr.cells
		$col = 0
		For $td In $tds
			$a_TableCells[$col][$row] = $td.innerText
			$col = $col + $td.colSpan
		Next
		$row = $row + 1
	Next
	If $f_transpose Then
		Local $i_d1 = UBound($a_TableCells, 1), $i_d2 = UBound($a_TableCells, 2), $aTmp[$i_d2][$i_d1]
		For $i = 0 To $i_d2 - 1
			For $j = 0 To $i_d1 - 1
				$aTmp[$i][$j] = $a_TableCells[$j][$i]
			Next
		Next
		$a_TableCells = $aTmp
	EndIf
	Return SetError($_IEStatus_Success, 0, $a_TableCells)
EndFunc   ;==>_IETableWriteToArray
#endregion Table functions
#region Read/Write functions
; #FUNCTION# ====================================================================================================================
; Name...........: _IEBodyReadHTML
; Description ...: Returns the HTML inside the <body> tag of the document
; Parameters ....: $o_object 	- Object variable of an InternetExplorer.Application, Window or Frame object
; Return values .: On Success 	- Returns HTML included in the <body> of the docuement
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEBodyReadHTML(ByRef $o_object)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEBodyReadHTML", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	Return SetError($_IEStatus_Success, 0, $o_object.document.body.innerHTML)
EndFunc   ;==>_IEBodyReadHTML

; #FUNCTION# ====================================================================================================================
; Name...........: _IEBodyReadText
; Description ...: Returns the Text inside the <body> tag of the document
; Parameters ....: $o_object 	- Object variable of an InternetExplorer.Application, Window or Frame object
; Return values .: On Success 	- Returns the Text included in the <body> of the docuement
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEBodyReadText(ByRef $o_object)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEBodyReadText", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	If Not __IEIsObjType($o_object, "browserdom") Then
		__IEErrorNotify("Error", "_IEBodyReadText", "$_IEStatus_InvalidObjectType", "Expected document element")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	Return SetError($_IEStatus_Success, 0, $o_object.document.body.innerText)
EndFunc   ;==>_IEBodyReadText

; #FUNCTION# ====================================================================================================================
; Name...........: _IEBodyWriteHTML
; Description ...: Replaces the HTML inside the <body> tag of the document
; Parameters ....: $o_object 	- Object variable of an InternetExplorer.Application, Window or Frame object
;				   $s_html		- The HTML string to write to the document
; Return values .: On Success 	- Returns -1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 1 ($_IEStatus_GeneralError) = General Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 6 ($_IEStatus_LoadWaitTimeout) = Load Wait Timeout
;								- 8 ($_IEStatus_AccessIsDenied) = Access Is Denied
;								- 9 ($_IEStatus_ClientDisconnected) = Client Disconnected
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEBodyWriteHTML(ByRef $o_object, $s_html)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEBodyWriteHTML", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	If Not __IEIsObjType($o_object, "browserdom") Then
		__IEErrorNotify("Error", "_IEBodyWriteHTML", "$_IEStatus_InvalidObjectType", "Expected document element")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	$o_object.document.body.innerHTML = $s_html
	Local $oTemp = $o_object.document
	_IELoadWait($oTemp)
	Return SetError(@error, 0, -1)
EndFunc   ;==>_IEBodyWriteHTML

; #FUNCTION# ====================================================================================================================
; Name...........: _IEDocReadHTML
; Description ...: Returns the full HTML source of a document
; Parameters ....: $o_object 	- Object variable of an InternetExplorer.Application, Window or Frame object
; Return values .: On Success 	- Returns the HTML included in the <HTML> of the docuement, including the <HTML> and </HTML> tags
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEDocReadHTML(ByRef $o_object)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEDocReadHTML", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	If Not __IEIsObjType($o_object, "browserdom") Then
		__IEErrorNotify("Error", "_IEDocReadHTML", "$_IEStatus_InvalidObjectType", "Expected document element")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	Return SetError($_IEStatus_Success, 0, $o_object.document.documentElement.outerHTML)
EndFunc   ;==>_IEDocReadHTML

; #FUNCTION# ====================================================================================================================
; Name...........: _IEDocWriteHTML
; Description ...: Replaces the HTML for the entire document
; Parameters ....: $o_object 	- Object variable of an InternetExplorer.Application, Window or Frame object
;				   $s_html		- The HTML string to write to the document
; Return values .: On Success 	- Returns -1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 1 ($_IEStatus_GeneralError) = General Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 6 ($_IEStatus_LoadWaitTimeout) = Load Wait Timeout
;								- 8 ($_IEStatus_AccessIsDenied) = Access Is Denied
;								- 9 ($_IEStatus_ClientDisconnected) = Client Disconnected
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEDocWriteHTML(ByRef $o_object, $s_html)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEDocWriteHTML", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	If Not __IEIsObjType($o_object, "browserdom") Then
		__IEErrorNotify("Error", "_IEDocWriteHTML", "$_IEStatus_InvalidObjectType", "Expected document element")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	$o_object.document.Write($s_html)
	$o_object.document.close()
	Local $oTemp = $o_object.document
	_IELoadWait($oTemp)
	Return SetError(@error, 0, -1)
EndFunc   ;==>_IEDocWriteHTML

; #FUNCTION# ====================================================================================================================
; Name...........: _IEDocInsertText
; Description ...: Inserts text adjacent to a specified document element
; Parameters ....: $o_object	- Object variable of a document element
;                  $s_string   - String containing text to insert
;                  $s_where    - String value signifying where to insert relative to $o_object
;								- BeforeBegin = before start tag of specified object
;								- AfterBegin = after start tag of specified object
;								- BeforeEnd = (Default) before end tag of specified object
;								- AfterEnd = after end tag of specified object
; Return values .: On Success 	- Returns 1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 5 ($_IEStatus_InvalidValue) = Invalid Value
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEDocInsertText(ByRef $o_object, $s_string, $s_where = "beforeend")
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEDocInsertText", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	If Not __IEIsObjType($o_object, "browserdom") Or __IEIsObjType($o_object, "documentcontainer") Or __IEIsObjType($o_object, "document") Then
		__IEErrorNotify("Error", "_IEDocInsertText", "$_IEStatus_InvalidObjectType", "Expected document element")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf

	$s_where = StringLower($s_where)
	Select
		Case $s_where = "beforebegin"
			$o_object.insertAdjacentText($s_where, $s_string)
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_where = "afterbegin"
			$o_object.insertAdjacentText($s_where, $s_string)
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_where = "beforeend"
			$o_object.insertAdjacentText($s_where, $s_string)
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_where = "afterend"
			$o_object.insertAdjacentText($s_where, $s_string)
			Return SetError($_IEStatus_Success, 0, 1)
		Case Else
			; Unsupported Where
			__IEErrorNotify("Error", "_IEDocInsertText", "$_IEStatus_InvalidValue", "Invalid where value")
			Return SetError($_IEStatus_InvalidValue, 3, 0)
	EndSelect
EndFunc   ;==>_IEDocInsertText

; #FUNCTION# ====================================================================================================================
; Name...........: _IEDocInsertHTML
; Description ...: Inserts HTML adjacent to a specified document element
; Parameters ....: $o_object	- Object variable of a document element
;                  $s_string   - String containing text to insert
;                  $s_where    - String value signifying where to insert relative to $o_object
;								- BeforeBegin = before start tag of specified object
;								- AfterBegin = after start tag of specified object
;								- BeforeEnd = (Default) before end tag of specified object
;								- AfterEnd = after end tag of specified object
; Return values .: On Success 	- Returns 1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 5 ($_IEStatus_InvalidValue) = Invalid Value
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEDocInsertHTML(ByRef $o_object, $s_string, $s_where = "beforeend")
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEDocInsertHTML", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	If Not __IEIsObjType($o_object, "browserdom") Or __IEIsObjType($o_object, "documentcontainer") Or __IEIsObjType($o_object, "document") Then
		__IEErrorNotify("Error", "_IEDocInsertHTML", "$_IEStatus_InvalidObjectType", "Expected document element")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf

	$s_where = StringLower($s_where)
	Select
		Case $s_where = "beforebegin"
			$o_object.insertAdjacentHTML($s_where, $s_string)
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_where = "afterbegin"
			$o_object.insertAdjacentHTML($s_where, $s_string)
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_where = "beforeend"
			$o_object.insertAdjacentHTML($s_where, $s_string)
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_where = "afterend"
			$o_object.insertAdjacentHTML($s_where, $s_string)
			Return SetError($_IEStatus_Success, 0, 1)
		Case Else
			; Unsupported Where
			__IEErrorNotify("Error", "_IEDocInsertHTML", "$_IEStatus_InvalidValue", "Invalid where value")
			Return SetError($_IEStatus_InvalidValue, 3, 0)
	EndSelect
EndFunc   ;==>_IEDocInsertHTML

; #FUNCTION# ====================================================================================================================
; Name...........: _IEHeadInsertEventScript
; Description ...: Inserts a Javascript into the Head of the document
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application, Window or Frame object
;                  $s_htmlFor  - The HTML element for event monitoring (e.g. "document" or an element ID)
;                  $s_event    - The event to monitor (e.g. "onclick" or "oncontextmenu")
;                  $s_script   - Javascript string to be executed
; Return values .: On Success 	- Returns 1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEHeadInsertEventScript(ByRef $o_object, $s_htmlFor, $s_event, $s_script)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEHeadInsertEventScript", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf

	Local $o_head = $o_object.document.all.tags("HEAD").Item(0)
	Local $o_script = $o_object.document.createElement("script")
	With $o_script
		.defer = True
		.language = "jscript"
		.type = "text/javascript"
		.htmlFor = $s_htmlFor
		.event = $s_event
		.text = $s_script
	EndWith
	$o_head.appendChild($o_script)
	Return SetError($_IEStatus_Success, 0, 1)
EndFunc   ;==>_IEHeadInsertEventScript
#endregion Read/Write functions
#region Utility functions
; #FUNCTION# ====================================================================================================================
; Name...........: _IEDocGetObj
; Description ...: Given any DOM object, returns a reference to the associated document object
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application, Window or Frame object
; Return values .: On Success 	- Returns an object variable pointing to the Document object
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEDocGetObj(ByRef $o_object)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEDocGetObj", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	Switch __IEIsObjType($o_object, "document")
		Case True
			Return SetError($_IEStatus_Success, 0, $o_object)
		Case False
			Return SetError($_IEStatus_Success, 0, $o_object.document)
	EndSwitch
EndFunc   ;==>_IEDocGetObj

; #FUNCTION# ====================================================================================================================
; Name...........: _IETagNameGetCollection
; Description ...: Returns a collection object of all elements in the object with the specified TagName.
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application, Window, Frame, iFrame or any object in the DOM
;				   $s_TagName	- TagName of collection to return (e.g. IMG, TR etc.)
;				   $i_index	- Optional: specifies whether to return a collection or indexed instance
;								- 0 or positive integer returns an indexed instance
;								- -1 = (Default) returns a collection
; Return values .: On Success 	- Returns an object variable containing the specified Tag collection, @EXTENDED = specified Tag count
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 5 ($_IEStatus_InvalidValue) = Invalid Value
;								- 7 ($_IEStatus_NoMatch) = No Match
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IETagNameGetCollection(ByRef $o_object, $s_TagName, $i_index = -1)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IETagNameGetCollection", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __IEIsObjType($o_object, "browserdom") Then
		__IEErrorNotify("Error", "_IETagNameGetCollection", "$_IEStatus_InvalidObjectType")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf

	Local $oTemp
	If __IEIsObjType($o_object, "documentcontainer") Then
		$oTemp = _IEDocGetObj($o_object)
	Else
		$oTemp = $o_object
	EndIf

	$i_index = Number($i_index)
	Select
		Case $i_index = -1
			Return SetError($_IEStatus_Success, $oTemp.GetElementsByTagName($s_TagName).length, _
					$oTemp.GetElementsByTagName($s_TagName))
		Case $i_index > -1 And $i_index < $oTemp.GetElementsByTagName($s_TagName).length
			Return SetError($_IEStatus_Success, $oTemp.GetElementsByTagName($s_TagName).length, _
					$oTemp.GetElementsByTagName($s_TagName).item($i_index))
		Case $i_index < -1
			__IEErrorNotify("Error", "_IETagNameGetCollection", "$_IEStatus_InvalidValue", "$i_index < -1")
			Return SetError($_IEStatus_InvalidValue, 3, 0)
		Case Else
			__IEErrorNotify("Error", "_IETagNameGetCollection", "$_IEStatus_NoMatch")
			Return SetError($_IEStatus_NoMatch, 0, 0) ; Could be caused by parameter 2, 3 or both
	EndSelect
EndFunc   ;==>_IETagNameGetCollection

; #FUNCTION# ====================================================================================================================
; Name...........: _IETagNameAllGetCollection
; Description ...: Returns a collection object all elements in the document or document hierarchy in source order.
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application, Window, Frame, iFrame or any object in the DOM
;				   $i_index	- Optional: specifies whether to return a collection or indexed instance
;								- 0 or positive integer returns an indexed instance
;								- -1 = (Default) returns a collection
; Return values .: On Success 	- Returns an object variable containing the Tag collection, @EXTENDED = Tag count
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 5 ($_IEStatus_InvalidValue) = Invalid Value
;								- 7 ($_IEStatus_NoMatch) = No Match
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IETagNameAllGetCollection(ByRef $o_object, $i_index = -1)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IETagNameAllGetCollection", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __IEIsObjType($o_object, "browserdom") Then
		__IEErrorNotify("Error", "_IETagNameAllGetCollection", "$_IEStatus_InvalidObjectType")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf

	Local $oTemp
	If __IEIsObjType($o_object, "documentcontainer") Then
		$oTemp = _IEDocGetObj($o_object)
	Else
		$oTemp = $o_object
	EndIf

	$i_index = Number($i_index)
	Select
		Case $i_index = -1
			Return SetError($_IEStatus_Success, $oTemp.all.length, $oTemp.all)
		Case $i_index > -1 And $i_index < $oTemp.all.length
			Return SetError($_IEStatus_Success, $oTemp.all.length, $oTemp.all.item($i_index))
		Case $i_index < -1
			__IEErrorNotify("Error", "_IETagNameAllGetCollection", "$_IEStatus_InvalidValue", "$i_index < -1")
			Return SetError($_IEStatus_InvalidValue, 2, 0)
		Case Else
			__IEErrorNotify("Error", "_IETagNameAllGetCollection", "$_IEStatus_NoMatch")
			Return SetError($_IEStatus_NoMatch, 1, 0)
	EndSelect
EndFunc   ;==>_IETagNameAllGetCollection

; #FUNCTION# ====================================================================================================================
; Name...........: _IEGetObjByName
; Description ...: Returns an object variable by Id or name
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application, Window or Frame object
;				   $s_Id		- Specifies name or id of the object you wish to match
;				   $i_index	- Optional: If Name of Id occurs more than once, specifies instance by 0-based index
;								- 0 (Default) or positive integer returns an indexed instance
;								- -1 returns a collection of the specified objects
; Return values .: On Success 	- Returns an object variable pointing to the specified Object, @EXTENDED = specified object count
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 7 ($_IEStatus_NoMatch) = No Match
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEGetObjByName(ByRef $o_object, $s_Id, $i_index = 0)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEGetObjByName", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	$i_index = Number($i_index)
	If $i_index = -1 Then
		Return SetError($_IEStatus_Success, $o_object.document.GetElementsByName($s_Id).length, _
				$o_object.document.GetElementsByName($s_Id))
	Else
		If IsObj($o_object.document.GetElementsByName($s_Id).item($i_index)) Then
			Return SetError($_IEStatus_Success, $o_object.document.GetElementsByName($s_Id).length, _
					$o_object.document.GetElementsByName($s_Id).item($i_index))
		Else
			__IEErrorNotify("Warning", "_IEGetObjByName", "$_IEStatus_NoMatch", "Name: " & $s_Id & ", Index: " & $i_index)
			Return SetError($_IEStatus_NoMatch, 0, 0) ; Could be caused by parameter 2, 3 or both
		EndIf
	EndIf
EndFunc   ;==>_IEGetObjByName

; #FUNCTION# ====================================================================================================================
; Name...........: _IEGetObjById
; Description ...: Returns an object variable by Id or name
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application, Window or Frame object
;				   $s_Id		- Specifies id of the object you wish to match
; Return values .: On Success 	- Returns an object variable pointing to the specified Object
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 7 ($_IEStatus_NoMatch) = No Match
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEGetObjById(ByRef $o_object, $s_Id)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEGetObjById", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __IEIsObjType($o_object, "browserdom") Then
		__IEErrorNotify("Error", "_IEGetObById", "$_IEStatus_InvalidObjectType")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	If IsObj($o_object.document.getElementById($s_Id)) Then
		Return SetError($_IEStatus_Success, 0, $o_object.document.getElementById($s_Id))
	Else
		__IEErrorNotify("Warning", "_IEGetObjById", "$_IEStatus_NoMatch", $s_Id)
		Return SetError($_IEStatus_NoMatch, 2, 0)
	EndIf
EndFunc   ;==>_IEGetObjById

; #FUNCTION# ====================================================================================================================
; Name...........: _IEAction
; Description ...: Perform any of a set of simple actions on the Browser
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application
;				   $s_action	- Action selection
; Return values .: On Success 	- Returns 1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 5 ($_IEStatus_InvalidValue) = Invalid Value
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEAction(ByRef $o_object, $s_action)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEAction", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	$s_action = StringLower($s_action)
	Select
		; DOM objects
		Case $s_action = "click"
			If __IEIsObjType($o_object, "documentContainer") Then
				__IEErrorNotify("Error", "_IEAction", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$o_object.Click()
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_action = "disable"
			If __IEIsObjType($o_object, "documentContainer") Then
				__IEErrorNotify("Error", "_IEAction", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$o_object.disabled = True
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_action = "enable"
			If __IEIsObjType($o_object, "documentContainer") Then
				__IEErrorNotify("Error", "_IEAction", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$o_object.disabled = False
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_action = "focus"
			If __IEIsObjType($o_object, "documentContainer") Then
				__IEErrorNotify("Error", "_IEAction", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$o_object.Focus()
			Return SetError($_IEStatus_Success, 0, 1)
			; Browser Object
		Case $s_action = "copy"
			$o_object.document.execCommand("Copy")
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_action = "cut"
			$o_object.document.execCommand("Cut")
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_action = "paste"
			$o_object.document.execCommand("Paste")
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_action = "delete"
			$o_object.document.execCommand("Delete")
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_action = "saveas"
			$o_object.document.execCommand("SaveAs")
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_action = "refresh"
			$o_object.document.execCommand("Refresh")
			_IELoadWait($o_object)
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_action = "selectall"
			$o_object.document.execCommand("SelectAll")
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_action = "unselect"
			$o_object.document.execCommand("Unselect")
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_action = "print"
			$o_object.document.parentwindow.Print()
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_action = "printdefault"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEAction", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$o_object.execWB(6, 2)
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_action = "back"
			If Not __IEIsObjType($o_object, "documentContainer") Then
				__IEErrorNotify("Error", "_IEAction", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$o_object.GoBack()
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_action = "blur"
			$o_object.Blur()
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_action = "forward"
			If Not __IEIsObjType($o_object, "documentContainer") Then
				__IEErrorNotify("Error", "_IEAction", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$o_object.GoForward()
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_action = "home"
			If Not __IEIsObjType($o_object, "documentContainer") Then
				__IEErrorNotify("Error", "_IEAction", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$o_object.GoHome()
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_action = "invisible"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEAction", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$o_object.visible = 0
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_action = "visible"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEAction", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$o_object.visible = 1
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_action = "search"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEAction", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$o_object.GoSearch()
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_action = "stop"
			If Not __IEIsObjType($o_object, "documentContainer") Then
				__IEErrorNotify("Error", "_IEAction", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$o_object.Stop()
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_action = "quit"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEAction", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$o_object.Quit()
			$o_object = 0
			Return SetError($_IEStatus_Success, 0, 1)
		Case Else
			; Unsupported Action
			__IEErrorNotify("Error", "_IEAction", "$_IEStatus_InvalidValue", "Invalid Action")
			Return SetError($_IEStatus_InvalidValue, 2, 0)
	EndSelect
EndFunc   ;==>_IEAction

; #FUNCTION# ====================================================================================================================
; Name...........: _IEPropertyGet
; Description ...: Returns a select property of the browser
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application
;				   $s_property	- Property selection
; Return values .: On Success 	- Value of selected Property
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 5 ($_IEStatus_InvalidValue) = Invalid Value
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEPropertyGet(ByRef $o_object, $s_property)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	If Not __IEIsObjType($o_object, "browserdom") Then
		__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	Local $oTemp, $iTemp
	$s_property = StringLower($s_property)
	Select
		Case $s_property = "browserx"
			If __IEIsObjType($o_object, "browsercontainer") Or __IEIsObjType($o_object, "document") Then
				__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$oTemp = $o_object
			$iTemp = 0
			While IsObj($oTemp)
				$iTemp += $oTemp.offsetLeft
				$oTemp = $oTemp.offsetParent
			WEnd
			Return SetError($_IEStatus_Success, 0, $iTemp)
		Case $s_property = "browsery"
			If __IEIsObjType($o_object, "browsercontainer") Or __IEIsObjType($o_object, "document") Then
				__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$oTemp = $o_object
			$iTemp = 0
			While IsObj($oTemp)
				$iTemp += $oTemp.offsetTop
				$oTemp = $oTemp.offsetParent
			WEnd
			Return SetError($_IEStatus_Success, 0, $iTemp)
		Case $s_property = "screenx"
			If __IEIsObjType($o_object, "window") Or __IEIsObjType($o_object, "document") Then
				__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			If __IEIsObjType($o_object, "browser") Then
				Return SetError($_IEStatus_Success, 0, $o_object.left())
			Else
				$oTemp = $o_object
				$iTemp = 0
				While IsObj($oTemp)
					$iTemp += $oTemp.offsetLeft
					$oTemp = $oTemp.offsetParent
				WEnd
			EndIf
			Return SetError($_IEStatus_Success, 0, _
					$iTemp + $o_object.document.parentWindow.screenLeft)
		Case $s_property = "screeny"
			If __IEIsObjType($o_object, "window") Or __IEIsObjType($o_object, "document") Then
				__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			If __IEIsObjType($o_object, "browser") Then
				Return SetError($_IEStatus_Success, 0, $o_object.top())
			Else
				$oTemp = $o_object
				$iTemp = 0
				While IsObj($oTemp)
					$iTemp += $oTemp.offsetTop
					$oTemp = $oTemp.offsetParent
				WEnd
			EndIf
			Return SetError($_IEStatus_Success, 0, _
					$iTemp + $o_object.document.parentWindow.screenTop)
		Case $s_property = "height"
			If __IEIsObjType($o_object, "window") Or __IEIsObjType($o_object, "document") Then
				__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			If __IEIsObjType($o_object, "browser") Then
				Return SetError($_IEStatus_Success, 0, $o_object.Height())
			Else
				Return SetError($_IEStatus_Success, 0, $o_object.offsetHeight)
			EndIf
		Case $s_property = "width"
			If __IEIsObjType($o_object, "window") Or __IEIsObjType($o_object, "document") Then
				__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			If __IEIsObjType($o_object, "browser") Then
				Return SetError($_IEStatus_Success, 0, $o_object.Width())
			Else
				Return SetError($_IEStatus_Success, 0, $o_object.offsetWidth)
			EndIf
		Case $s_property = "isdisabled"
			Return SetError($_IEStatus_Success, 0, $o_object.isDisabled())
		Case $s_property = "addressbar"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.AddressBar())
		Case $s_property = "busy"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.Busy())
		Case $s_property = "fullscreen"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.fullScreen())
		Case $s_property = "hwnd"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, HWnd($o_object.HWnd()))
		Case $s_property = "left"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.Left())
		Case $s_property = "locationname"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.LocationName())
		Case $s_property = "locationurl"
			If __IEIsObjType($o_object, "browser") Then
				Return SetError($_IEStatus_Success, 0, $o_object.locationURL())
			EndIf
			If __IEIsObjType($o_object, "window") Then
				Return SetError($_IEStatus_Success, 0, $o_object.location.href())
			EndIf
			If __IEIsObjType($o_object, "document") Then
				Return SetError($_IEStatus_Success, 0, $o_object.parentwindow.location.href())
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentwindow.location.href())
		Case $s_property = "menubar"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.MenuBar())
		Case $s_property = "offline"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.OffLine())
		Case $s_property = "readystate"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.ReadyState())
		Case $s_property = "resizable"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.Resizable())
		Case $s_property = "silent"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.Silent())
		Case $s_property = "statusbar"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.StatusBar())
		Case $s_property = "statustext"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.StatusText())
		Case $s_property = "top"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.Top())
		Case $s_property = "visible"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.Visible())
		Case $s_property = "appcodename"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.appCodeName())
		Case $s_property = "appminorversion"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.appMinorVersion())
		Case $s_property = "appname"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.appName())
		Case $s_property = "appversion"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.appVersion())
		Case $s_property = "browserlanguage"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.browserLanguage())
		Case $s_property = "cookieenabled"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.cookieEnabled())
		Case $s_property = "cpuclass"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.cpuClass())
		Case $s_property = "javaenabled"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.javaEnabled())
		Case $s_property = "online"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.onLine())
		Case $s_property = "platform"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.platform())
		Case $s_property = "systemlanguage"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.systemLanguage())
		Case $s_property = "useragent"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.userAgent())
		Case $s_property = "userlanguage"
			Return SetError($_IEStatus_Success, 0, $o_object.document.parentWindow.top.navigator.userLanguage())
		Case $s_property = "vcard"
			Local $aVcard[1][29]
			$aVcard[0][0] = "Business.City"
			$aVcard[0][1] = "Business.Country"
			$aVcard[0][2] = "Business.Fax"
			$aVcard[0][3] = "Business.Phone"
			$aVcard[0][4] = "Business.State"
			$aVcard[0][5] = "Business.StreetAddress"
			$aVcard[0][6] = "Business.URL"
			$aVcard[0][7] = "Business.Zipcode"
			$aVcard[0][8] = "Cellular"
			$aVcard[0][9] = "Company"
			$aVcard[0][10] = "Department"
			$aVcard[0][11] = "DisplayName"
			$aVcard[0][12] = "Email"
			$aVcard[0][13] = "FirstName"
			$aVcard[0][14] = "Gender"
			$aVcard[0][15] = "Home.City"
			$aVcard[0][16] = "Home.Country"
			$aVcard[0][17] = "Home.Fax"
			$aVcard[0][18] = "Home.Phone"
			$aVcard[0][19] = "Home.State"
			$aVcard[0][20] = "Home.StreetAddress"
			$aVcard[0][21] = "Home.Zipcode"
			$aVcard[0][22] = "Homepage"
			$aVcard[0][23] = "JobTitle"
			$aVcard[0][24] = "LastName"
			$aVcard[0][25] = "MiddleName"
			$aVcard[0][26] = "Notes"
			$aVcard[0][27] = "Office"
			$aVcard[0][28] = "Pager"
			For $i = 0 To 28
				$aVcard[1][$i] = Execute('$o_object.document.parentWindow.top.navigator.userProfile.getAttribute("' & $aVcard[0][$i] & '")')
			Next
			Return SetError($_IEStatus_Success, 0, $aVcard)
		Case $s_property = "referrer"
			Return SetError($_IEStatus_Success, 0, $o_object.document.referrer)
		Case $s_property = "theatermode"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.TheaterMode)
		Case $s_property = "toolbar"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			Return SetError($_IEStatus_Success, 0, $o_object.ToolBar)
		Case $s_property = "contenteditable"
			If __IEIsObjType($o_object, "browser") Or __IEIsObjType($o_object, "document") Then
				$oTemp = $o_object.document.body
			Else
				$oTemp = $o_object
			EndIf
			Return SetError($_IEStatus_Success, 0, $oTemp.isContentEditable)
		Case $s_property = "innertext"
			If __IEIsObjType($o_object, "documentcontainer") Or __IEIsObjType($o_object, "document") Then
				$oTemp = $o_object.document.body
			Else
				$oTemp = $o_object
			EndIf
			Return SetError($_IEStatus_Success, 0, $oTemp.innerText)
		Case $s_property = "outertext"
			If __IEIsObjType($o_object, "documentcontainer") Or __IEIsObjType($o_object, "document") Then
				$oTemp = $o_object.document.body
			Else
				$oTemp = $o_object
			EndIf
			Return SetError($_IEStatus_Success, 0, $oTemp.outerText)
		Case $s_property = "innerhtml"
			If __IEIsObjType($o_object, "documentcontainer") Or __IEIsObjType($o_object, "document") Then
				$oTemp = $o_object.document.body
			Else
				$oTemp = $o_object
			EndIf
			Return SetError($_IEStatus_Success, 0, $oTemp.innerHTML)
		Case $s_property = "outerhtml"
			If __IEIsObjType($o_object, "documentcontainer") Or __IEIsObjType($o_object, "document") Then
				$oTemp = $o_object.document.body
			Else
				$oTemp = $o_object
			EndIf
			Return SetError($_IEStatus_Success, 0, $oTemp.outerHTML)
		Case $s_property = "title"
			Return SetError($_IEStatus_Success, 0, $o_object.document.title)
		Case $s_property = "uniqueid"
			If __IEIsObjType($o_object, "window") Then
				__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			Else
				Return SetError($_IEStatus_Success, 0, $o_object.uniqueID)
			EndIf
		Case Else
			; Unsupported Property
			__IEErrorNotify("Error", "_IEPropertyGet", "$_IEStatus_InvalidValue", "Invalid Property")
			Return SetError($_IEStatus_InvalidValue, 2, 0)
	EndSelect
EndFunc   ;==>_IEPropertyGet

; #FUNCTION# ====================================================================================================================
; Name...........: _IEPropertySet
; Description ...: Set a select property of the Browser
; Parameters ....: $o_object	- Object variable of an InternetExplorer.Application
;				   $s_property	- Property selection
;				   $newvalue	- The new value to be set into the Browser Property
; Return values .: On Success 	- Returns 1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 5 ($_IEStatus_InvalidValue) = Invalid Value
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEPropertySet(ByRef $o_object, $s_property, $newvalue)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEPropertySet", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	Local $oTemp
	#forceref $oTemp
	$s_property = StringLower($s_property)
	Select
		Case $s_property = "addressbar"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertySet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$o_object.AddressBar = $newvalue
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_property = "height"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertySet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$o_object.Height = $newvalue
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_property = "left"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertySet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$o_object.Left = $newvalue
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_property = "menubar"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertySet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$o_object.MenuBar = $newvalue
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_property = "offline"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertySet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$o_object.OffLine = $newvalue
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_property = "resizable"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertySet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$o_object.Resizable = $newvalue
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_property = "statusbar"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertySet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$o_object.StatusBar = $newvalue
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_property = "statustext"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertySet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$o_object.StatusText = $newvalue
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_property = "top"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertySet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$o_object.Top = $newvalue
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_property = "width"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertySet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			$o_object.Width = $newvalue
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_property = "theatermode"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertySet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			If $newvalue Then
				$o_object.TheaterMode = True
			Else
				$o_object.TheaterMode = False
			EndIf
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_property = "toolbar"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertySet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			If $newvalue Then
				$o_object.ToolBar = True
			Else
				$o_object.ToolBar = False
			EndIf
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_property = "contenteditable"
			If __IEIsObjType($o_object, "browser") Or __IEIsObjType($o_object, "document") Then
				$oTemp = $o_object.document.body
			Else
				$oTemp = $o_object
			EndIf
			If $newvalue Then
				$oTemp.contentEditable = "true"
			Else
				$oTemp.contentEditable = "false"
			EndIf
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_property = "innertext"
			If __IEIsObjType($o_object, "documentcontainer") Or __IEIsObjType($o_object, "document") Then
				$oTemp = $o_object.document.body
			Else
				$oTemp = $o_object
			EndIf
			$oTemp.innerText = $newvalue
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_property = "outertext"
			If __IEIsObjType($o_object, "documentcontainer") Or __IEIsObjType($o_object, "document") Then
				$oTemp = $o_object.document.body
			Else
				$oTemp = $o_object
			EndIf
			$oTemp.outerText = $newvalue
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_property = "innerhtml"
			If __IEIsObjType($o_object, "documentcontainer") Or __IEIsObjType($o_object, "document") Then
				$oTemp = $o_object.document.body
			Else
				$oTemp = $o_object
			EndIf
			$oTemp.innerHTML = $newvalue
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_property = "outerhtml"
			If __IEIsObjType($o_object, "documentcontainer") Or __IEIsObjType($o_object, "document") Then
				$oTemp = $o_object.document.body
			Else
				$oTemp = $o_object
			EndIf
			$oTemp.outerHTML = $newvalue
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_property = "title"
			$o_object.document.title = $newvalue
			Return SetError($_IEStatus_Success, 0, 1)
		Case $s_property = "silent"
			If Not __IEIsObjType($o_object, "browser") Then
				__IEErrorNotify("Error", "_IEPropertySet", "$_IEStatus_InvalidObjectType")
				Return SetError($_IEStatus_InvalidObjectType, 1, 0)
			EndIf
			If $newvalue Then
				$o_object.silent = True
			Else
				$o_object.silent = False
			EndIf
			Return SetError($_IEStatus_Success, 0, 0)
		Case Else
			; Unsupported Property
			__IEErrorNotify("Error", "_IEPropertySet", "$_IEStatus_InvalidValue", "Invalid Property")
			Return SetError($_IEStatus_InvalidValue, 2, 0)
	EndSelect
EndFunc   ;==>_IEPropertySet

; #FUNCTION# ====================================================================================================================
; Name...........: _IEErrorNotify
; Description ...: Specifies whether IE.au3 automatically notifies of Warnings and Errors (to the console)
; Parameters ....: $f_notify	- Optional: specifies whether notification should be on or off
;								- -1 = (Default) return current setting
;								- True = Turn On
;								- False = Turn Off
; Return values .: On Success 	- If $f_notify = -1, returns the current notification setting, else returns 1
;                  On Failure	- Returns 0
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEErrorNotify($f_notify = -1)
	Switch Number($f_notify)
		Case -1
			Return $_IEErrorNotify
		Case 0
			$_IEErrorNotify = False
			Return 1
		Case 1
			$_IEErrorNotify = True
			Return 1
		Case Else
			__IEErrorNotify("Error", "_IEErrorNotify", "$_IEStatus_InvalidValue")
			Return 0
	EndSwitch
EndFunc   ;==>_IEErrorNotify

; #FUNCTION# ====================================================================================================================
; Name...........: _IEErrorHandlerRegister
; Description ...: Register and enable a user COM error handler
; Parameters ....: $s_functionName - String variable with the name of a user-defined COM error handler
;									  defaults to the internal COM error handler in this UDF
; Return values .: On Success 	- Returns 1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 1 ($_IEStatus_GeneralError) = General Error
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEErrorHandlerRegister($s_functionName = "__IEInternalErrorHandler")
	$sIEUserErrorHandler = $s_functionName
	$oIEErrorHandler = ""
	$oIEErrorHandler = ObjEvent("AutoIt.Error", $s_functionName)
	If IsObj($oIEErrorHandler) Then
		Return SetError($_IEStatus_Success, 0, 1)
	Else
		__IEErrorNotify("Error", "_IEPropertySet", "$_IEStatus_GeneralError", _
				"Error Handler Not Registered - Check existance of error function")
		Return SetError($_IEStatus_GeneralError, 1, 0)
	EndIf
EndFunc   ;==>_IEErrorHandlerRegister

; #FUNCTION# ====================================================================================================================
; Name...........: _IEErrorHandlerDeRegister
; Description ...: Disable a registered user COM error handler
; Parameters ....: None
; Return values .: On Success 	- Returns 1
;                  On Failure	- None
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEErrorHandlerDeRegister()
	$sIEUserErrorHandler = ""
	$oIEErrorHandler = ""
	Return SetError($_IEStatus_Success, 0, 1)
EndFunc   ;==>_IEErrorHandlerDeRegister

; #FUNCTION# ====================================================================================================================
; Name...........: _IEQuit
; Description ...: Close the browser and remove the object reference to it
; Parameters ....: $o_object 	- Object variable of an InternetExplorer.Application
; Return values .: On Success 	- Returns 1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IEQuit(ByRef $o_object)
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "_IEQuit", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __IEIsObjType($o_object, "browser") Then
		__IEErrorNotify("Error", "_IEAction", "$_IEStatus_InvalidObjectType")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	$o_object.quit()
	$o_object = 0
	Return SetError($_IEStatus_Success, 0, 1)
EndFunc   ;==>_IEQuit

#endregion Utility functions
#region General
; #FUNCTION# ====================================================================================================================
; Name...........: _IE_Introduction
; Description ...: Display introductory information about IE.au3 in a new browser window
; Parameters ....: $s_module	- Optional: specifies which module to run
;								- basic = (Default) basic introduction
; Return values .: On Success 	- Returns an object variable pointing to an InternetExplorer.Application object
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 5 ($_IEStatus_InvalidValue) = Invalid Value
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IE_Introduction($s_module = "basic")
	Local $s_html = ""
	Switch $s_module
		Case "basic"
			$s_html &= "<HTML>" & @CR
			$s_html &= "<HEAD>" & @CR
			$s_html &= "<TITLE>_IE_Introduction ('basic')</TITLE>" & @CR
			$s_html &= "<STYLE>body {font-family: Arial}</STYLE>" & @CR
			$s_html &= "</HEAD>" & @CR
			$s_html &= "<BODY>" & @CR
			$s_html &= "<table border=1 width=600 id='table1' cellspacing=6 cellpadding=6>" & @CR
			$s_html &= "<tr>" & @CR
			$s_html &= "<td>" & @CR
			$s_html &= "<h1>Welcome to IE.au3</h1>" & @CR
			$s_html &= "IE.au3 is a UDF (User Defined Function) library for the " & @CR
			$s_html &= "<a href='http://www.autoitscript.com'>AutoIt</a> scripting language." & @CR
			$s_html &= "<p>  " & @CR
			$s_html &= "IE.au3 allows you to either create or attach to an Internet Explorer browser and do " & @CR
			$s_html &= "just about anything you could do with it interactively with the mouse and " & @CR
			$s_html &= "keyboard, but do it through script." & @CR
			$s_html &= "<p>" & @CR
			$s_html &= "You can navigate to pages, click links, fill and submit forms etc. You can " & @CR
			$s_html &= "also do things you cannot do interactively like change or rewrite page " & @CR
			$s_html &= "content and JavaScripts, read, parse and save page content and monitor and act " & @CR
			$s_html &= "upon browser 'events'.<p>" & @CR
			$s_html &= "IE.au3 uses the COM interface in AutoIt to interact with the Internet Explorer " & @CR
			$s_html &= "object model and the DOM (Document Object Model) supported by the browser." & @CR
			$s_html &= "<p>" & @CR
			$s_html &= "Here are some links for more information and helpful tools:<p>" & @CR
			$s_html &= "Reference Material: " & @CR
			$s_html &= "<ul>" & @CR
			$s_html &= "<li><a href='http://msdn1.microsoft.com/'>MSDN (Microsoft Developer Network)</a></li>" & @CR
			$s_html &= "<li><a href='http://msdn2.microsoft.com/en-us/library/aa752084.aspx' target='_blank'>InternetExplorer Object</a></li>" & @CR
			$s_html &= "<li><a href='http://msdn2.microsoft.com/en-us/library/ms531073.aspx' target='_blank'>Document Object</a></li>" & @CR
			$s_html &= "<li><a href='http://msdn2.microsoft.com/en-us/ie/aa740473.aspx' target='_blank'>Overviews and Tutorials</a></li>" & @CR
			$s_html &= "<li><a href='http://msdn2.microsoft.com/en-us/library/ms533029.aspx' target='_blank'>DHTML Objects</a></li>" & @CR
			$s_html &= "<li><a href='http://msdn2.microsoft.com/en-us/library/ms533051.aspx' target='_blank'>DHTML Events</a></li>" & @CR
			$s_html &= "</ul><p>" & @CR
			$s_html &= "Helpful Tools: " & @CR
			$s_html &= "<ul>" & @CR
			$s_html &= "<li><a href='http://www.autoitscript.com/forum/index.php?showtopic=19368' target='_blank'>AutoIt IE Builder</a> (build IE scripts interactively)</li>" & @CR
			$s_html &= "<li><a href='http://www.debugbar.com/' target='_blank'>DebugBar</a> (DOM inspector, HTTP inspector, HTML validator and more - free for personal use) Recommended</li>" & @CR
			$s_html &= "<li><a href='http://www.microsoft.com/downloads/details.aspx?FamilyID=e59c3964-672d-4511-bb3e-2d5e1db91038&amp;displaylang=en' target='_blank'>IE Developer Toolbar</a> (comprehensive DOM analysis tool)</li>" & @CR
			$s_html &= "<li><a href='http://slayeroffice.com/tools/modi/v2.0/modi_help.html' target='_blank'>MODIV2</a> (view the DOM of a web page by mousing around)</li>" & @CR
			$s_html &= "<li><a href='http://validator.w3.org/' target='_blank'>HTML Validator</a> (verify HTML follows format rules)</li>" & @CR
			$s_html &= "<li><a href='http://www.fiddlertool.com/fiddler/' target='_blank'>Fiddler</a> (examine HTTP traffic)</li>" & @CR
			$s_html &= "</ul>" & @CR
			$s_html &= "</td>" & @CR
			$s_html &= "</tr>" & @CR
			$s_html &= "</table>" & @CR
			$s_html &= "</BODY>" & @CR
			$s_html &= "</HTML>"
		Case Else
			__IEErrorNotify("Error", "_IE_Introduction", "$_IEStatus_InvalidValue")
			Return SetError($_IEStatus_InvalidValue, 1, 0)
	EndSwitch
	Local $o_object = _IECreate()
	_IEDocWriteHTML($o_object, $s_html)
	Return SetError($_IEStatus_Success, 0, $o_object)
EndFunc   ;==>_IE_Introduction

; #FUNCTION# ====================================================================================================================
; Name...........: _IE_Example
; Description ...: Display a new browser window pre-loaded with documents to be used in IE.au3 examples
; Parameters ....: $s_module	- Optional: specifies which module to run
;								- basic = (Default) simple HTML page with text, links and images
;								- form = simple HTML page with multiple form elements
;								- frameset = simple HTML page with frames
;								- iframe = simple HTML page with iframes
;								- table = simple HTML page with tables
; Return values .: On Success 	- Returns an object variable pointing to an InternetExplorer.Application object
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 5 ($_IEStatus_InvalidValue) = Invalid Value
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IE_Example($s_module = "basic")
	Local $s_html = "", $o_object
	Switch $s_module
		Case "basic"
			$s_html &= "<HEAD>" & @CR
			$s_html &= "<TITLE>_IE_Example('basic')</TITLE>" & @CR
			$s_html &= "<STYLE>body {font-family: Arial}</STYLE>" & @CR
			$s_html &= "</HEAD>" & @CR
			$s_html &= "<BODY>" & @CR
			$s_html &= "<a href='http://www.autoitscript.com'><img src='http://www.autoitscript.com/images/autoit_6_240x100.jpg' name='AutoItImage' alt='AutoIt Homepage Image'></a>" & @CR
			$s_html &= "<p>" & @CR
			$s_html &= "<div id=line1>This is a simple HTML page with text, links and images.</div>" & @CR
			$s_html &= "<p>" & @CR
			$s_html &= "<div id=line2><a href='http://www.autoitscript.com'>AutoIt</a> is a wonderful automation scripting language.</div>" & @CR
			$s_html &= "<p>" & @CR
			$s_html &= "<div id=line3>It is supported by a very active and supporting <a href='http://www.autoitscript.com/forum/'>user forum</a>.</div>" & @CR
			$s_html &= "<p>" & @CR
			$s_html &= "<div id=IEAu3Data></div>" & @CR
			$s_html &= "</BODY>" & @CR
			$s_html &= "</HTML>"
			$o_object = _IECreate()
			_IEDocWriteHTML($o_object, $s_html)
		Case "table"
			$s_html &= "<HTML>" & @CR
			$s_html &= "<HEAD>" & @CR
			$s_html &= "<TITLE>_IE_Example('table')</TITLE>" & @CR
			$s_html &= "<STYLE>body {font-family: Arial}</STYLE>" & @CR
			$s_html &= "</HEAD>" & @CR
			$s_html &= "<BODY>" & @CR
			$s_html &= "$oTableOne = _IETableGetObjByName($oIE, &quot;tableOne&quot;)<br>" & @CR
			$s_html &= "&lt;table border=1 id='tableOne'&gt;<p>" & @CR
			$s_html &= "<table border=1 id='tableOne'>" & @CR
			$s_html &= "	<tr>" & @CR
			$s_html &= "		<td>AutoIt</td>" & @CR
			$s_html &= "		<td>is</td>" & @CR
			$s_html &= "		<td>really</td>" & @CR
			$s_html &= "		<td>great</td>" & @CR
			$s_html &= "		<td>with</td>" & @CR
			$s_html &= "		<td>IE.au3</td>" & @CR
			$s_html &= "	</tr>" & @CR
			$s_html &= "	<tr>" & @CR
			$s_html &= "		<td>1</td>" & @CR
			$s_html &= "		<td>2</td>" & @CR
			$s_html &= "		<td>3</td>" & @CR
			$s_html &= "		<td>4</td>" & @CR
			$s_html &= "		<td>5</td>" & @CR
			$s_html &= "		<td>6</td>" & @CR
			$s_html &= "	</tr>" & @CR
			$s_html &= "	<tr>" & @CR
			$s_html &= "		<td>the</td>" & @CR
			$s_html &= "		<td>quick</td>" & @CR
			$s_html &= "		<td>red</td>" & @CR
			$s_html &= "		<td>fox</td>" & @CR
			$s_html &= "		<td>jumped</td>" & @CR
			$s_html &= "		<td>over</td>" & @CR
			$s_html &= "	</tr>" & @CR
			$s_html &= "	<tr>" & @CR
			$s_html &= "		<td>the</td>" & @CR
			$s_html &= "		<td>lazy</td>" & @CR
			$s_html &= "		<td>brown</td>" & @CR
			$s_html &= "		<td>dog</td>" & @CR
			$s_html &= "		<td>the</td>" & @CR
			$s_html &= "		<td>time</td>" & @CR
			$s_html &= "	</tr>" & @CR
			$s_html &= "	<tr>" & @CR
			$s_html &= "		<td>has</td>" & @CR
			$s_html &= "		<td>come</td>" & @CR
			$s_html &= "		<td>for</td>" & @CR
			$s_html &= "		<td>all</td>" & @CR
			$s_html &= "		<td>good</td>" & @CR
			$s_html &= "		<td>men</td>" & @CR
			$s_html &= "	</tr>" & @CR
			$s_html &= "	<tr>" & @CR
			$s_html &= "		<td>to</td>" & @CR
			$s_html &= "		<td>come</td>" & @CR
			$s_html &= "		<td>to</td>" & @CR
			$s_html &= "		<td>the</td>" & @CR
			$s_html &= "		<td>aid</td>" & @CR
			$s_html &= "		<td>of</td>" & @CR
			$s_html &= "	</tr>" & @CR
			$s_html &= "</table>" & @CR
			$s_html &= "<p>" & @CR
			$s_html &= "$oTableTwo = _IETableGetObjByName($oIE, &quot;tableTwo&quot;)<br>" & @CR
			$s_html &= "&lt;table border=&quot;1&quot; id='tableTwo'&gt;<p>" & @CR
			$s_html &= "<table border=1 id='tableTwo'>" & @CR
			$s_html &= "	<tr>" & @CR
			$s_html &= "		<td colspan='4'>Table Top</td>" & @CR
			$s_html &= "	</tr>" & @CR
			$s_html &= "	<tr>" & @CR
			$s_html &= "		<td>One</td>" & @CR
			$s_html &= "		<td colspan='3'>Two</td>" & @CR
			$s_html &= "	</tr>" & @CR
			$s_html &= "	<tr>" & @CR
			$s_html &= "		<td>Three</td>" & @CR
			$s_html &= "		<td>Four</td>" & @CR
			$s_html &= "		<td colspan='2'>Five</td>" & @CR
			$s_html &= "	</tr>" & @CR
			$s_html &= "	<tr>" & @CR
			$s_html &= "		<td>Six</td>" & @CR
			$s_html &= "		<td colspan='3'>Seven</td>" & @CR
			$s_html &= "	</tr>" & @CR
			$s_html &= "	<tr>" & @CR
			$s_html &= "		<td>Eight</td>" & @CR
			$s_html &= "		<td>Nine</td>" & @CR
			$s_html &= "		<td>Ten</td>" & @CR
			$s_html &= "		<td>Eleven</td>" & @CR
			$s_html &= "	</tr>" & @CR
			$s_html &= "</table>" & @CR
			$s_html &= "</BODY>" & @CR
			$s_html &= "</HTML>"
			$o_object = _IECreate()
			_IEDocWriteHTML($o_object, $s_html)
		Case "form"
			$s_html &= "<HTML>" & @CR
			$s_html &= "<HEAD>" & @CR
			$s_html &= "<TITLE>_IE_Example('form')</TITLE>" & @CR
			$s_html &= "<STYLE>body {font-family: Arial}</STYLE>" & @CR
			$s_html &= "</HEAD>" & @CR
			$s_html &= "<BODY>" & @CR
			$s_html &= "<form name='ExampleForm' onSubmit='javascript:alert(""ExampleFormSubmitted"");' method='post'>" & @CR
			$s_html &= "<table cellspacing=6 cellpadding=6 border=1>" & @CR
			$s_html &= "<tr>" & @CR
			$s_html &= "<td>ExampleForm</td>" & @CR
			$s_html &= "<td>&lt;form name='ExampleForm' onSubmit='javascript:alert(""ExampleFormSubmitted"");' method='post'&gt;</td>" & @CR
			$s_html &= "</tr>" & @CR
			$s_html &= "<tr>" & @CR
			$s_html &= "<td>Hidden Input Element<input type='hidden' name='hiddenExample' value='secret value'></td>" & @CR
			$s_html &= "<td>&lt;input type='hidden' name='hiddenExample' value='secret value'&gt;</td>" & @CR
			$s_html &= "</tr>" & @CR
			$s_html &= "<tr>" & @CR
			$s_html &= "<td>" & @CR
			$s_html &= "<input type='text' name='textExample' value='http://' size='20' maxlength='30'>" & @CR
			$s_html &= "</td>" & @CR
			$s_html &= "<td>&lt;input type='text' name='textExample' value='http://' size='20' maxlength='30'&gt;</td>" & @CR
			$s_html &= "</tr>" & @CR
			$s_html &= "<tr>" & @CR
			$s_html &= "<td>" & @CR
			$s_html &= "<input type='password' name='passwordExample' size='10'>" & @CR
			$s_html &= "</td>" & @CR
			$s_html &= "<td>&lt;input type='password' name='passwordExample' size='10'&gt;</td>" & @CR
			$s_html &= "</tr>" & @CR
			$s_html &= "<tr>" & @CR
			$s_html &= "<td>" & @CR
			$s_html &= "<input type='file' name='fileExample'>" & @CR
			$s_html &= "</td>" & @CR
			$s_html &= "<td>&lt;input type='file' name='fileExample'&gt;</td>" & @CR
			$s_html &= "</tr>" & @CR
			$s_html &= "<tr>" & @CR
			$s_html &= "<td>" & @CR
			$s_html &= "<input type='image' name='imageExample' alt='AutoIt Homepage' src='http://www.autoitscript.com/images/autoit_6_240x100.jpg'>" & @CR
			$s_html &= "</td>" & @CR
			$s_html &= "<td>&lt;input type='image' name='imageExample' alt='AutoIt Homepage' src='http://www.autoitscript.com/images/autoit_6_240x100.jpg'&gt;</td>" & @CR
			$s_html &= "</tr>" & @CR
			$s_html &= "<tr>" & @CR
			$s_html &= "<td>" & @CR
			$s_html &= "<textarea name='textareaExample' rows='5' cols='15'>Hello!</textarea>" & @CR
			$s_html &= "</td>" & @CR
			$s_html &= "<td>&lt;textarea name='textareaExample' rows='5' cols='15'&gt;Hello!&lt;/textarea&gt;</td>" & @CR
			$s_html &= "</tr>" & @CR
			$s_html &= "<tr>" & @CR
			$s_html &= "<td>" & @CR
			$s_html &= "<input type='checkbox' name='checkboxG1Example' value='gameBasketball'>Basketball<br>" & @CR
			$s_html &= "<input type='checkbox' name='checkboxG1Example' value='gameFootball'>Football<br>" & @CR
			$s_html &= "<input type='checkbox' name='checkboxG2Example' value='gameTennis' checked>Tennis<br>" & @CR
			$s_html &= "<input type='checkbox' name='checkboxG2Example' value='gameBaseball'>Baseball" & @CR
			$s_html &= "</td>" & @CR
			$s_html &= "<td>&lt;input type='checkbox' name='checkboxG1Example' value='gameBasketball'&gt;Basketball&lt;br&gt;<br>" & @CR
			$s_html &= "&lt;input type='checkbox' name='checkboxG1Example' value='gameFootball'&gt;Football&lt;br&gt;<br>" & @CR
			$s_html &= "&lt;input type='checkbox' name='checkboxG2Example' value='gameTennis' checked&gt;Tennis&lt;br&gt;<br>" & @CR
			$s_html &= "&lt;input type='checkbox' name='checkboxG2Example' value='gameBaseball'&gt;Baseball</td>" & @CR
			$s_html &= "</tr>" & @CR
			$s_html &= "<tr>" & @CR
			$s_html &= "<td>" & @CR
			$s_html &= "<input type='radio' name='radioExample' value='vehicleAirplane'>Airplane<br>" & @CR
			$s_html &= "<input type='radio' name='radioExample' value='vehicleTrain' checked>Train<br>" & @CR
			$s_html &= "<input type='radio' name='radioExample' value='vehicleBoat'>Boat<br>" & @CR
			$s_html &= "<input type='radio' name='radioExample' value='vehicleCar'>Car</td>" & @CR
			$s_html &= "<td>&lt;input type='radio' name='radioExample' value='vehicleAirplane'&gt;Airplane&lt;br&gt;<br>" & @CR
			$s_html &= "&lt;input type='radio' name='radioExample' value='vehicleTrain' checked&gt;Train&lt;br&gt;<br>" & @CR
			$s_html &= "&lt;input type='radio' name='radioExample' value='vehicleBoat'&gt;Boat&lt;br&gt;<br>" & @CR
			$s_html &= "&lt;input type='radio' name='radioExample' value='vehicleCar'&gt;Car&lt;br&gt;</td>" & @CR
			$s_html &= "</tr>" & @CR
			$s_html &= "<tr>" & @CR
			$s_html &= "<td>" & @CR
			$s_html &= "<select name='selectExample'>" & @CR
			$s_html &= "<option value='homepage.html'>Homepage" & @CR
			$s_html &= "<option value='midipage.html'>Midipage" & @CR
			$s_html &= "<option value='freepage.html'>Freepage" & @CR
			$s_html &= "</select>" & @CR
			$s_html &= "</td>" & @CR
			$s_html &= "<td>&lt;select name='selectExample'&gt;<br>" & @CR
			$s_html &= "&lt;option value='homepage.html'&gt;Homepage<br>" & @CR
			$s_html &= "&lt;option value='midipage.html'&gt;Midipage<br>" & @CR
			$s_html &= "&lt;option value='freepage.html'&gt;Freepage<br>" & @CR
			$s_html &= "&lt;/select&gt;</td>" & @CR
			$s_html &= "</tr>" & @CR
			$s_html &= "<tr>" & @CR
			$s_html &= "<td>" & @CR
			$s_html &= "<select name='multipleSelectExample' size='6' multiple>" & @CR
			$s_html &= "<option value='Name1'>Aaron" & @CR
			$s_html &= "<option value='Name2'>Bruce" & @CR
			$s_html &= "<option value='Name3'>Carlos" & @CR
			$s_html &= "<option value='Name4'>Denis" & @CR
			$s_html &= "<option value='Name5'>Ed" & @CR
			$s_html &= "<option value='Name6'>Freddy" & @CR
			$s_html &= "</select>" & @CR
			$s_html &= "</td>" & @CR
			$s_html &= "<td>&lt;select name='multipleSelectExample' size='6' multiple&gt;<br>" & @CR
			$s_html &= "&lt;option value='Name1'&gt;Aaron<br>" & @CR
			$s_html &= "&lt;option value='Name2'&gt;Bruce<br>" & @CR
			$s_html &= "&lt;option value='Name3'&gt;Carlos<br>" & @CR
			$s_html &= "&lt;option value='Name4'&gt;Denis<br>" & @CR
			$s_html &= "&lt;option value='Name5'&gt;Ed<br>" & @CR
			$s_html &= "&lt;option value='Name6'&gt;Freddy<br>" & @CR
			$s_html &= "&lt;/select&gt;</td>" & @CR
			$s_html &= "</tr>" & @CR
			$s_html &= "<tr>" & @CR
			$s_html &= "<td>" & @CR
			$s_html &= "<input name='submitExample' type='submit' value='Submit'>" & @CR
			$s_html &= "<input name='resetExample' type='reset' value='Reset'>" & @CR
			$s_html &= "</td>" & @CR
			$s_html &= "<td>&lt;input name='submitExample' type='submit' value='Submit'&gt;<br>" & @CR
			$s_html &= "&lt;input name='resetExample' type='reset' value='Reset'&gt;</td>" & @CR
			$s_html &= "</tr>" & @CR
			$s_html &= "</table>" & @CR
			$s_html &= "<input type='hidden' name='hiddenExample' value='secret value'>" & @CR
			$s_html &= "</FORM>" & @CR
			$s_html &= "</BODY>" & @CR
			$s_html &= "</HTML>"
			$o_object = _IECreate()
			_IEDocWriteHTML($o_object, $s_html)
		Case "frameset"
			$s_html &= "<HTML>" & @CR
			$s_html &= "<HEAD>" & @CR
			$s_html &= "<TITLE>_IE_Example('frameset')</TITLE>" & @CR
			$s_html &= "</HEAD>" & @CR
			$s_html &= "<FRAMESET rows='25,200'>" & @CR
			$s_html &= "	<FRAME NAME=Top SRC=about:blank>" & @CR
			$s_html &= "	<FRAMESET cols='100,500'>" & @CR
			$s_html &= "		<FRAME NAME=Menu SRC=about:blank>" & @CR
			$s_html &= "		<FRAME NAME=Main SRC=about:blank>" & @CR
			$s_html &= "	</FRAMESET>" & @CR
			$s_html &= "</FRAMESET>" & @CR
			$s_html &= "</HTML>"
			$o_object = _IECreate()
			_IEDocWriteHTML($o_object, $s_html)
			_IEAction($o_object, "refresh")
			Local $oFrameTop = _IEFrameGetObjByName($o_object, "Top")
			Local $oFrameMenu = _IEFrameGetObjByName($o_object, "Menu")
			Local $oFrameMain = _IEFrameGetObjByName($o_object, "Main")
			_IEBodyWriteHTML($oFrameTop, '$oFrameTop = _IEFrameGetObjByName($oIE, "Top")')
			_IEBodyWriteHTML($oFrameMenu, '$oFrameMenu = _IEFrameGetObjByName($oIE, "Menu")')
			_IEBodyWriteHTML($oFrameMain, '$oFrameMain = _IEFrameGetObjByName($oIE, "Main")')
		Case "iframe"
			$s_html &= "<HTML>" & @CR
			$s_html &= "<HEAD>" & @CR
			$s_html &= "<TITLE>_IE_Example('iframe')</TITLE>" & @CR
			$s_html &= "</HEAD>" & @CR
			$s_html &= "<BODY>" & @CR
			$s_html &= "<table cellspacing=6 cellpadding=6 border=1>" & @CR
			$s_html &= "<tr>" & @CR
			$s_html &= "<td><iframe name='iFrameOne' src='about:blank' title='iFrameOne'></iframe></td>" & @CR
			$s_html &= "<td>&lt;iframe name=&quot;iFrameOne&quot; src=&quot;about:blank&quot; title=&quot;iFrameOne&quot;&gt;</td>" & @CR
			$s_html &= "</tr>" & @CR
			$s_html &= "<tr>" & @CR
			$s_html &= "<td><iframe name='iFrameTwo' src='about:blank' title='iFrameTwo'></iframe></td>" & @CR
			$s_html &= "<td>&lt;iframe name=&quot;iFrameTwo&quot; src=&quot;about:blank&quot; title=&quot;iFrameTwo&quot;&gt;</td>" & @CR
			$s_html &= "</tr>" & @CR
			$s_html &= "</table>" & @CR
			$s_html &= "</BODY>" & @CR
			$s_html &= "</HTML>"
			$o_object = _IECreate()
			_IEDocWriteHTML($o_object, $s_html)
			_IEAction($o_object, "refresh")
			Local $oIFrameOne = _IEFrameGetObjByName($o_object, "iFrameOne")
			Local $oIFrameTwo = _IEFrameGetObjByName($o_object, "iFrameTwo")
			_IEBodyWriteHTML($oIFrameOne, '$oIFrameOne = _IEFrameGetObjByName($oIE, "iFrameOne")')
			_IEBodyWriteHTML($oIFrameTwo, '$oIFrameTwo = _IEFrameGetObjByName($oIE, "iFrameTwo")')
		Case Else
			__IEErrorNotify("Error", "_IE_Example", "$_IEStatus_InvalidValue")
			Return SetError($_IEStatus_InvalidValue, 1, 0)
	EndSwitch

	Return SetError($_IEStatus_Success, 0, $o_object)
EndFunc   ;==>_IE_Example

; #FUNCTION# ====================================================================================================================
; Name...........: _IE_VersionInfo
; Description ...: Returns an array of information about the IE.au3 version
; Parameters ....:  None
; Return values .: On Success 	- Returns an array ($IEAU3VersionInfo)
;								- $IEAU3VersionInfo[0] = Release Type (T=Test or V=Production)
;								- $IEAU3VersionInfo[1] = Major Version
;								- $IEAU3VersionInfo[2] = Minor Version
;								- $IEAU3VersionInfo[3] = Sub Version
;								- $IEAU3VersionInfo[4] = Release Date (YYYYMMDD)
;								- $IEAU3VersionInfo[5] = Display Version (e.g. V2.0-0)
;                   On Failure	- None
; Author ........: Dale Hohm
; ===============================================================================================================================
Func _IE_VersionInfo()
	__IEErrorNotify("Information", "_IE_VersionInfo", "version " & _
			$IEAU3VersionInfo[0] & _
			$IEAU3VersionInfo[1] & "." & _
			$IEAU3VersionInfo[2] & "-" & _
			$IEAU3VersionInfo[3], "Release date: " & $IEAU3VersionInfo[4])
	Return SetError($_IEStatus_Success, 0, $IEAU3VersionInfo)
EndFunc   ;==>_IE_VersionInfo

#endregion General
#region Internal functions
;
; Internal Functions with names starting with two underscores will not be documented
; as user functions
;
; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __IELockSetForegroundWindow
; Description ...: Locks (and Unlocks) current Foregrouns Window focus to prevent a new window
;					from stealing it (e.g. when creating invisible IE browser)
; Parameters ....: $nLockCode	- 1 Lock Foreground Window Focus, 2 Unlock Foreground Window Focus
; Return values .: On Success 	- 1
;                   On Failure 	- 0  and sets @ERROR and @EXTENDED to non-zero values
; Author ........: Valik
; ===============================================================================================================================
Func __IELockSetForegroundWindow($nLockCode)
	Local $aRet = DllCall("user32.dll", "bool", "LockSetForegroundWindow", "uint", $nLockCode)
	If @error Or $aRet[0] Then Return SetError(1, _WinAPI_GetLastError(), 0)
	Return $aRet[0]
EndFunc   ;==>__IELockSetForegroundWindow

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __IEControlGetObjFromHWND
; Description ...: Returns a COM Object Window reference to an embebedded Webbrowser control
; Parameters ....: $hWin		- HWND of a Internet Explorer_Server1 control obtained for example:
;					$hwnd = ControlGetHandle("MyApp","","Internet Explorer_Server1")
; Return values .: On Success 	- Returns DOM Window object
;                   On Failure 	- 0  and sets @ERROR = 1
; Author ........: Larry with thanks to Valik
; Remarks .......: Windows XP, Windows 2003 or higher.
;				   Windows 2000; Windows 98; Windows ME; Windows NT may install the
;				   Microsoft Active Accessibility 2.0 Redistributable:
;					http://www.microsoft.com/downloads/details.aspx?FamilyId=9B14F6E1-888A-4F1D-B1A1-DA08EE4077DF&displaylang=en
; ===============================================================================================================================
Func __IEControlGetObjFromHWND(ByRef $hWin)
	; The code assumes CoInitialize() succeeded due to the number of different
	; yet successful return values it has.
	DllCall("ole32.dll", "long", "CoInitialize", "ptr", 0)
	If @error Then Return SetError(2, @error, 0)

	Local Const $WM_HTML_GETOBJECT = __IERegisterWindowMessage("WM_HTML_GETOBJECT")
	Local Const $SMTO_ABORTIFHUNG = 0x0002
	Local $lResult

	__IESendMessageTimeout($hWin, $WM_HTML_GETOBJECT, 0, 0, $SMTO_ABORTIFHUNG, 1000, $lResult)

	Local $typUUID = DllStructCreate("int;short;short;byte[8]")
	DllStructSetData($typUUID, 1, 0x626FC520)
	DllStructSetData($typUUID, 2, 0xA41E)
	DllStructSetData($typUUID, 3, 0x11CF)
	DllStructSetData($typUUID, 4, 0xA7, 1)
	DllStructSetData($typUUID, 4, 0x31, 2)
	DllStructSetData($typUUID, 4, 0x0, 3)
	DllStructSetData($typUUID, 4, 0xA0, 4)
	DllStructSetData($typUUID, 4, 0xC9, 5)
	DllStructSetData($typUUID, 4, 0x8, 6)
	DllStructSetData($typUUID, 4, 0x26, 7)
	DllStructSetData($typUUID, 4, 0x37, 8)

	Local $aRet = DllCall("oleacc.dll", "long", "ObjectFromLresult", "lresult", $lResult, "struct*", $typUUID, _
			"wparam", 0, "idispatch*", 0)
	If @error Then Return SetError(3, @error, 0)

	If IsObj($aRet[4]) Then
		Local $oIE = $aRet[4] .Script()
		; $oIE is now a valid IDispatch object
		Return $oIE.Document.parentwindow
	Else
		Return SetError(1, $aRet[0], 0)
	EndIf
EndFunc   ;==>__IEControlGetObjFromHWND

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __IERegisterWindowMessage
; Description ...: Required by __IEControlGetObjFromHWND()
; Author ........: Larry with thanks to Valik
; ===============================================================================================================================
Func __IERegisterWindowMessage($sMsg)
	Local $aRet = DllCall("user32.dll", "uint", "RegisterWindowMessageW", "wstr", $sMsg)
	If @error Then Return SetError(@error, @extended, 0)
	If $aRet[0] = 0 Then Return SetError(10, _WinAPI_GetLastError(), 0)
	Return $aRet[0]
EndFunc   ;==>__IERegisterWindowMessage

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __IESendMessageTimeout
; Description ...: Required by __IEControlGetObjFromHWND()
; Author ........: Larry with thanks to Valik
; ===============================================================================================================================
Func __IESendMessageTimeout($hWnd, $msg, $wParam, $lParam, $nFlags, $nTimeout, ByRef $vOut, $r = 0, $t1 = "int", $t2 = "int")
	Local $aRet = DllCall("user32.dll", "lresult", "SendMessageTimeout", "hwnd", $hWnd, "uint", $msg, $t1, $wParam, _
			$t2, $lParam, "uint", $nFlags, "uint", $nTimeout, "dword_ptr*", "")
	If @error Or $aRet[0] = 0 Then
		$vOut = 0
		Return SetError(1, _WinAPI_GetLastError(), 0)
	EndIf
	$vOut = $aRet[7]
	If $r >= 0 And $r <= 4 Then Return $aRet[$r]
	Return $aRet
EndFunc   ;==>__IESendMessageTimeout

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __IEIsObjType
; Description ...: Check to see if an object variable is of a specific type
; Author ........: Dale Hohm
; ===============================================================================================================================
Func __IEIsObjType(ByRef $o_object, $s_type)
	If Not IsObj($o_object) Then
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf

	; Setup internal error handler to Trap COM errors, turn off error notification
	Local $status = __IEInternalErrorHandlerRegister()
	If Not $status Then __IEErrorNotify("Warning", "internal function __IEIsObjType", _
			"Cannot register internal error handler, cannot trap COM errors", _
			"Use _IEErrorHandlerRegister() to register a user error handler")
	Local $f_NotifyStatus = _IEErrorNotify() ; save current error notify status
	_IEErrorNotify(False)
	;
	Local $s_Name = String(ObjName($o_object)), $objectOK = False

	Switch $s_type
		Case "browserdom"
			Local $oTemp = $o_object.document
			If __IEIsObjType($o_object, "documentcontainer") Then
				$objectOK = True
			ElseIf __IEIsObjType($o_object, "document") Then
				$objectOK = True
			ElseIf __IEIsObjType($oTemp, "document") Then
				$objectOK = True
			EndIf
		Case "browser"
			If ($s_Name = "IWebBrowser2") Or ($s_Name = "IWebBrowser") Or ($s_Name = "WebBrowser") Then $objectOK = True
		Case "window"
			If $s_Name = "HTMLWindow2" Then $objectOK = True
		Case "documentContainer"
			If __IEIsObjType($o_object, "window") Or __IEIsObjType($o_object, "browser") Then $objectOK = True
		Case "document"
			If $s_Name = "HTMLDocument" Then $objectOK = True
		Case "table"
			If $s_Name = "HTMLTable" Then $objectOK = True
		Case "form"
			If $s_Name = "HTMLFormElement" Then $objectOK = True
		Case "forminputelement"
			If ($s_Name = "HTMLInputElement") Or ($s_Name = "HTMLSelectElement") Or ($s_Name = "HTMLTextAreaElement") Then $objectOK = True
		Case "elementcollection"
			If ($s_Name = "HTMLElementCollection") Then $objectOK = True
		Case "formselectelement"
			If $s_Name = "HTMLSelectElement" Then $objectOK = True
		Case Else
			; Unsupported ObjType specified
			Return SetError($_IEStatus_InvalidValue, 2, 0)
	EndSwitch

	; restore error notify and error handler status
	_IEErrorNotify($f_NotifyStatus) ; restore notification status
	__IEInternalErrorHandlerDeRegister()

	If $objectOK Then
		Return SetError($_IEStatus_Success, 0, 1)
	Else
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf

EndFunc   ;==>__IEIsObjType

Func __IEErrorNotify($s_severity, $s_func, $s_status = "", $s_message = "")
	If $_IEErrorNotify Or $__IEAU3Debug Then
		Local $sStr = "--> IE.au3 " & $IEAU3VersionInfo[5] & " " & $s_severity & " from function " & $s_func
		If Not String($s_status) = "" Then $sStr &= ", " & $s_status
		If Not String($s_message) = "" Then $sStr &= " (" & $s_message & ")"
		ConsoleWrite($sStr & @CRLF)
	EndIf
	Return 1
EndFunc   ;==>__IEErrorNotify

Func __IEInternalErrorHandlerRegister()
	Local $sCurrentErrorHandler = ObjEvent("AutoIt.Error")
	If $sCurrentErrorHandler <> "" And Not IsObj($oIEErrorHandler) Then
		; We've got trouble... User COM Error handler assigned without using _IEUserErrorHandlerRegister
		Return SetError($_IEStatus_GeneralError, 0, 0)
	EndIf
	$oIEErrorHandler = ""
	$oIEErrorHandler = ObjEvent("AutoIt.Error", "__IEInternalErrorHandler")
	If IsObj($oIEErrorHandler) Then
		Return SetError($_IEStatus_Success, 0, 1)
	Else
		Return SetError($_IEStatus_GeneralError, 0, 0)
	EndIf
EndFunc   ;==>__IEInternalErrorHandlerRegister

Func __IEInternalErrorHandlerDeRegister()
	$oIEErrorHandler = ""
	If $sIEUserErrorHandler <> "" Then
		$oIEErrorHandler = ObjEvent("AutoIt.Error", $sIEUserErrorHandler)
	EndIf
	Return SetError($_IEStatus_Success, 0, 1)
EndFunc   ;==>__IEInternalErrorHandlerDeRegister

Func __IEInternalErrorHandler()
	$IEComErrorScriptline = $oIEErrorHandler.scriptline
	$IEComErrorNumber = $oIEErrorHandler.number
	$IEComErrorNumberHex = Hex($oIEErrorHandler.number, 8)
	$IEComErrorDescription = StringStripWS($oIEErrorHandler.description, 2)
	$IEComErrorWinDescription = StringStripWS($oIEErrorHandler.WinDescription, 2)
	$IEComErrorSource = $oIEErrorHandler.Source
	$IEComErrorHelpFile = $oIEErrorHandler.HelpFile
	$IEComErrorHelpContext = $oIEErrorHandler.HelpContext
	$IEComErrorLastDllError = $oIEErrorHandler.LastDllError
	$IEComErrorOutput = ""
	$IEComErrorOutput &= "--> COM Error Encountered in " & @ScriptName & @CRLF
	$IEComErrorOutput &= "----> $IEComErrorScriptline = " & $IEComErrorScriptline & @CRLF
	$IEComErrorOutput &= "----> $IEComErrorNumberHex = " & $IEComErrorNumberHex & @CRLF
	$IEComErrorOutput &= "----> $IEComErrorNumber = " & $IEComErrorNumber & @CRLF
	$IEComErrorOutput &= "----> $IEComErrorWinDescription = " & $IEComErrorWinDescription & @CRLF
	$IEComErrorOutput &= "----> $IEComErrorDescription = " & $IEComErrorDescription & @CRLF
	$IEComErrorOutput &= "----> $IEComErrorSource = " & $IEComErrorSource & @CRLF
	$IEComErrorOutput &= "----> $IEComErrorHelpFile = " & $IEComErrorHelpFile & @CRLF
	$IEComErrorOutput &= "----> $IEComErrorHelpContext = " & $IEComErrorHelpContext & @CRLF
	$IEComErrorOutput &= "----> $IEComErrorLastDllError = " & $IEComErrorLastDllError & @CRLF
	If $_IEErrorNotify Or $__IEAU3Debug Then ConsoleWrite($IEComErrorOutput & @CRLF)
	SetError($_IEStatus_ComError)
	Return
EndFunc   ;==>__IEInternalErrorHandler

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __IEComErrorUnrecoverable
; Description ...: Internal function to test a COM error condition and determine if it is considered unrecoverable
; Parameters ....: None, relies on Global variables
; Return values .: Unrecoverable: True, Else: False
; Author ........: Dale Hohm
; ===============================================================================================================================
Func __IEComErrorUnrecoverable()
	Select
		;
		; Cross-site scripting security error
		Case ($IEComErrorNumber = -2147352567) Or (String($IEComErrorDescription) = "Access is denied.")
			Return $_IEStatus_AccessIsDenied
			;
			; Browser object is destroyed before we try to operate upon it
		Case ($IEComErrorNumber = -2147417848) Or (String($IEComErrorWinDescription) = "The object invoked has disconnected from its clients.")
			Return $_IEStatus_ClientDisconnected
			;
		Case Else
			Return $_IEStatus_Success
	EndSelect
EndFunc   ;==>__IEComErrorUnrecoverable

#endregion Internal functions

#region ProtoType Functions
; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __IENavigate
; Description ...: ** Unsupported version of _IENavigate (note second underscore in function name)
;					** Last 4 parameters insufficiently tested.
;					**    - Flags and Target can create new windows and new browser object - causing confusion
;					**    - Postdata needs SAFEARRAY and we have no way to create one
;					Directs an existing browser window to navigate to the specified URL
; Parameters ....: $o_object 		- Object variable of an InternetExplorer.Application, Window or Frame object
;				   $s_Url 			- URL to navigate to (e.g. "http://www.autoitscript.com")
;				   $f_wait 		- Optional: specifies whether to wait for page to load before returning
;										0 = Return immediately, not waiting for page to load
;										1 = (Default) Wait for page load to complete before returning
;				   $i_flags		- URL to navigate to (e.g. "http://www.autoitscript.com")
;				   $s_target		- target frame
;				   $spostdata		- data for form method="POST", non-functional - requires safearray
;				   $s_headers		- additional headers to be passed
; Return values .: On Success 	- Returns -1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 1 ($_IEStatus_GeneralError) = General Error
;								- 3 ($_IEStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_IEStatus_InvalidObjectType) = Invalid Object Type
;								- 6 ($_IEStatus_LoadWaitTimeout) = Load Wait Timeout
;								- 8 ($_IEStatus_AccessIsDenied) = Access Is Denied
;								- 9 ($_IEStatus_ClientDisconnected) = Client Disconnected
;					@Extended	- Contains invalid parameter number
; Author ........: Dale Hohm
; Remarks .......:  AutoIt3 V3.2 or higher, flags for Tabs require IE7 or higher
; 					Additional information on the navigate2 method here: http://msdn.microsoft.com/en-us/library/aa752134.aspx
;
; Flags:
;    navOpenInNewWindow = 0x1,
;    navNoHistory = 0x2,
;    navNoReadFromCache = 0x4,
;    navNoWriteToCache = 0x8,
;    navAllowAutosearch = 0x10,
;    navBrowserBar = 0x20,
;    navHyperlink = 0x40,
;    navEnforceRestricted = 0x80,
;    navNewWindowsManaged = 0x0100,
;    navUntrustedForDownload = 0x0200,
;    navTrustedForActiveX = 0x0400,
;    navOpenInNewTab = 0x0800,
;    navOpenInBackgroundTab = 0x1000,
;    navKeepWordWheelText = 0x2000
;
; Additional documentation on the flags can be found here:
;    http://msdn.microsoft.com/en-us/library/aa768360.aspx
; ===============================================================================================================================
Func __IENavigate(ByRef $o_object, $s_Url, $f_wait = 1, $i_flags = 0, $s_target = "", $s_postdata = "", $s_headers = "")
	__IEErrorNotify("Warning", "__IENavigate", "Unsupported function called. Not fully tested.")
	If Not IsObj($o_object) Then
		__IEErrorNotify("Error", "__IENavigate", "$_IEStatus_InvalidDataType")
		Return SetError($_IEStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __IEIsObjType($o_object, "documentContainer") Then
		__IEErrorNotify("Error", "__IENavigate", "$_IEStatus_InvalidObjectType")
		Return SetError($_IEStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	$o_object.navigate($s_Url, $i_flags, $s_target, $s_postdata, $s_headers)
	If $f_wait Then
		_IELoadWait($o_object)
		Return SetError(@error, 0, $o_object)
	EndIf
	Return SetError($_IEStatus_Success, 0, $o_object)
EndFunc   ;==>__IENavigate

#cs
	#include <IE.au3>
	; Simulates the submission of the form from the page:
	;
	;    http://www.autoitscript.com/forum/index.php?act=Search
	;
	; searches for the string safearray and returns the results as posts
	
	$sFormAction = "http://www.autoitscript.com/forum/index.php?act=Search&CODE=01"
	$sHeader = "Content-Type: application/x-www-form-urlencoded"
	
	$sDataToPost = "keywords=safearray&namesearch=&forums%5B%5D=all&searchsubs=1&prune=0&prune_type=newer&sort_key=last_post&sort_order=desc&search_in=posts&result_type=posts"
	$oDataToPostBstr = __IEStringToBstr($sDataToPost) ; convert string to BSTR
	ConsoleWrite(__IEBstrToString($oDataToPostBstr) & @CRLF) ; prove we can convert it back to a string
	
	$oIE = _IECreate()
	$oIE.Navigate( $sFormAction, Default, Default, $oDataToPostBstr, $sHeader)
	; or
	;__IENavigate($oIE, $sFormAction, 1, 0, "", $oDataToPostBstr, $sHeader)
#ce

Func __IEStringToBstr($s_string, $s_charSet = "us-ascii")
	Local Const $adTypeBinary = 1, $adTypeText = 2

	Local $o_Stream = ObjCreate("ADODB.Stream")

	$o_Stream.Type = $adTypeText
	$o_Stream.CharSet = $s_charSet
	$o_Stream.Open
	$o_Stream.WriteText($s_string)
	$o_Stream.Position = 0

	$o_Stream.Type = $adTypeBinary
	$o_Stream.Position = 0

	Return $o_Stream.Read()
EndFunc   ;==>__IEStringToBstr

Func __IEBstrToString($o_bstr, $s_charSet = "us-ascii")
	Local Const $adTypeBinary = 1, $adTypeText = 2

	Local $o_Stream = ObjCreate("ADODB.Stream")

	$o_Stream.Type = $adTypeBinary
	$o_Stream.Open
	$o_Stream.Write($o_bstr)
	$o_Stream.Position = 0

	$o_Stream.Type = $adTypeText
	$o_Stream.CharSet = $s_charSet
	$o_Stream.Position = 0

	Return $o_Stream.ReadText()
EndFunc   ;==>__IEBstrToString

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __IECreateNewIE
; Description ...: Create a Webbrowser in a seperate process
; Parameters ....: None
; Return values .: On Success	- Returns a Webbrowser object reference
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_IEStatus_Success) = No Error
;								- 1 ($_IEStatus_GeneralError) = General Error
; Author ........: Dale Hohm
; Remarks .......: http://msdn2.microsoft.com/en-us/library/ms536471(vs.85).aspx
; ===============================================================================================================================
Func __IECreateNewIE($s_title, $s_head = "", $s_body = "")

	Local $s_Temp = __IETempFile("", "~IE~", ".htm")
	If @error Then
		__IEErrorNotify("Error", "_IECreateHTA", "", _
				"Error creating temporary file in @TempDir or @ScriptDir")
		Return SetError($_IEStatus_GeneralError, 1, 0)
	EndIf

	Local $s_html = ''
	$s_html &= '<HTML>' & @CR
	$s_html &= '<HEAD>' & @CR
	$s_html &= '<TITLE>' & $s_Temp & '</TITLE>' & @CR & $s_head & @CR
	$s_html &= '</HEAD>' & @CR
	$s_html &= '<BODY>' & @CR & $s_body & @CR
	$s_html &= '</BODY>' & @CR
	$s_html &= '</HTML>'

	Local $h_file = FileOpen($s_Temp, 2)
	FileWrite($h_file, $s_html)
	FileClose($h_file)
	If @error Then
		__IEErrorNotify("Error", "_IECreateNewIE", "", _
				"Error creating temporary file in @TempDir or @ScriptDir")
		Return SetError($_IEStatus_GeneralError, 2, 0)
	EndIf
	Run(@ProgramFilesDir & "\Internet Explorer\iexplore.exe " & $s_Temp)

	Local $s_PID
	If WinWait($s_Temp, "", 60) Then
		$s_PID = WinGetProcess($s_Temp)
	Else
		__IEErrorNotify("Error", "_IECreateNewIE", "", _
				"Timeout waiting for new IE window creation")
		Return SetError($_IEStatus_GeneralError, 3, 0)
	EndIf

	If Not FileDelete($s_Temp) Then
		__IEErrorNotify("Warning", "_IECreateNewIE", "", _
				"Could not delete temporary file " & FileGetLongName($s_Temp))
	EndIf

	Local $o_object = _IEAttach($s_Temp)
	_IELoadWait($o_object)
	_IEPropertySet($o_object, "title", $s_title)

	Return SetError($_IEStatus_Success, $s_PID, $o_object)
EndFunc   ;==>__IECreateNewIE

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __IETempFile
; Description ...: Generate a name for a temporary file. The file is guaranteed not to already exist.
; Parameters ....: $s_DirectoryName    optional  Name of directory for filename, defaults to @TempDir
;                  $s_FilePrefix       optional  File prefixname, defaults to "~"
;                  $s_FileExtension    optional  File extenstion, defaults to ".tmp"
;                  $i_RandomLength     optional  Number of characters to use to generate a unique name, defaults to 7
; Return values .: Filename of a temporary file which does not exist.
; Author ........: Dale (Klaatu) Thompson
; Modified.......: Hans Harder - Added Optional parameters
;
; Adapted from excellent _TempFile() in File.au3 for IE.au3 by Dale Hohm
; ===============================================================================================================================
Func __IETempFile($s_DirectoryName = @TempDir, $s_FilePrefix = "~", $s_FileExtension = ".tmp", $i_RandomLength = 7)
	Local $s_TempName, $i_tmp = 0
	; Check parameters
	If Not FileExists($s_DirectoryName) Then $s_DirectoryName = @TempDir ; First reset to default temp dir
	If Not FileExists($s_DirectoryName) Then $s_DirectoryName = @ScriptDir ; Still wrong then set to Scriptdir
	; add trailing \ for directory name
	If StringRight($s_DirectoryName, 1) <> "\" Then $s_DirectoryName = $s_DirectoryName & "\"
	;
	Do
		$s_TempName = ""
		While StringLen($s_TempName) < $i_RandomLength
			$s_TempName = $s_TempName & Chr(Random(97, 122, 1))
		WEnd
		$s_TempName = $s_DirectoryName & $s_FilePrefix & $s_TempName & $s_FileExtension
		$i_tmp += 1
		If $i_tmp > 200 Then ; If we fail over 200 times, there is something wrong
			Return SetError($_IEStatus_GeneralError, 1, 0)
		EndIf
	Until Not FileExists($s_TempName)

	Return $s_TempName
EndFunc   ;==>__IETempFile

#endregion ProtoType Functions
