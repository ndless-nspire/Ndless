#include-once

; #INDEX# =======================================================================================================================
; Title .........: Microsoft Word Automation UDF Library for AutoIt3
; AutoIt Version : 3.2.0.1++
; Language ......: English
; Description ...: A collection of functions for creating, attaching to, reading from and manipulating Microsoft Word.
; Author(s) .....: Bob Anthony (Code based off IE.au3)
; Dll ...........: user32.dll
; ===============================================================================================================================

; ------------------------------------------------------------------------------
;	Version: V1.0-1
;	Last Update: 4/14/07
;	Requirements: AutoIt v3.2.0.1 or higher, Developed/Tested on WindowsXP Pro with Microsoft Word 2003
;	Notes: Errors associated with incorrect objects will be common user errors.
;	Special thanks to DaleHohm for letting me base this code off his IE.au3 Library!
;	Update History:	http://www.autoitscript.com/fileman/users/Big_Daddy/libraries/word/history.htm
; ------------------------------------------------------------------------------

; #VARIABLES# ===================================================================================================================
Global $__WordAU3Debug = False
Global $_WordErrorNotify = True
Global $oWordErrorHandler, $sWordUserErrorHandler
Global _; Com Error Handler Status Strings
		$WordComErrorNumber, _
		$WordComErrorNumberHex, _
		$WordComErrorDescription, _
		$WordComErrorScriptline, _
		$WordComErrorWinDescription, _
		$WordComErrorSource, _
		$WordComErrorHelpFile, _
		$WordComErrorHelpContext, _
		$WordComErrorLastDllError, _
		$WordComErrorComObj, _
		$WordComErrorOutput
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $WordAU3VersionInfo[6] = ["V", 1, 0, 1, "20070414", "V1.0-1"]
Global Const $WORD_LSFW_LOCK = 1, $WORD_LSFW_UNLOCK = 2
;
; Enums
;
Global Enum _; Error Status Types
		$_WordStatus_Success = 0, _
		$_WordStatus_GeneralError, _
		$_WordStatus_ComError, _
		$_WordStatus_InvalidDataType, _
		$_WordStatus_InvalidObjectType, _
		$_WordStatus_InvalidValue, _
		$_WordStatus_ReadOnly, _
		$_WordStatus_NoMatch
Global Enum Step * 2 _; NotificationLevel
		$_WordNotifyLevel_None = 0, _
		$_WordNotifyNotifyLevel_Warning = 1, _
		$_WordNotifyNotifyLevel_Error, _
		$_WordNotifyNotifyLevel_ComError
Global Enum Step * 2 _; NotificationMethod
		$_WordNotifyMethod_Silent = 0, _
		$_WordNotifyMethod_Console = 1, _
		$_WordNotifyMethod_ToolTip, _
		$_WordNotifyMethod_MsgBox
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_WordCreate
;_WordAttach
;_WordQuit
;_WordDocAdd
;_WordDocOpen
;_WordDocSave
;_WordDocSaveAs
;_WordDocClose
;_WordDocGetCollection
;_WordDocFindReplace
;_WordDocPrint
;_WordDocPropertyGet
;_WordDocPropertySet
;_WordDocLinkGetCollection
;_WordDocAddLink
;_WordDocAddPicture
;_WordErrorHandlerRegister
;_WordErrorHandlerDeRegister
;_WordErrorNotify
;_WordMacroRun
;_WordPropertyGet
;_WordPropertySet
;_Word_VersionInfo
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;__WordGetHWND
;__WordErrorNotify
;__WordInternalErrorHandlerRegister
;__WordInternalErrorHandlerDeRegister
;__WordInternalErrorHandler
;__WordLockSetForegroundWindow
;__WordIsObjType
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _WordCreate
; Description ...: Create a Microsoft Office Word Object
; Parameters ....: $s_FilePath		- Optional: specifies the file on open upon creation (See Remarks)
;				   $f_tryAttach	- Optional: specifies whether to try to attach to an existing window
;										0 = (Default) do not try to attach
;										1 = Try to attach to an existing window
;				   $f_visible 		- Optional: specifies whether the window will be visible
;										0 = Window is hidden
;										1 = (Default) Window is visible
;				   $f_takeFocus	- Optional: specifies whether to bring the attached window to focus
;										0 =  Do Not Bring window into focus
;										1 = (Default) bring window into focus
; Return values .: On Success	- Returns an object variable pointing to a Word.Application object
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_WordStatus_Success) = No Error
;								- 1 ($_WordStatus_GeneralError) = General Error
;								- 3 ($_WordStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_WordStatus_InvalidObjectType) = Invalid Object Type
;					@Extended	- Set to true (1) or false (0) depending on the success of $f_tryAttach
; Author ........: Bob Anthony
; Remarks .......: File will be created if it does not exist.
; ===============================================================================================================================
Func _WordCreate($s_FilePath = "", $f_tryAttach = 0, $f_visible = 1, $f_takeFocus = 1)
	If Not $f_visible Then $f_takeFocus = 0 ; Force takeFocus to 0 for hidden window
	If $s_FilePath = "" Then $f_tryAttach = 0 ; There is currently no way of attaching to a blank document

	If $f_tryAttach Then
		Local $o_Result = _WordAttach($s_FilePath)
		If IsObj($o_Result) Then
			If $f_takeFocus Then
				Local $o_win = $o_Result.ActiveWindow
				Local $h_hwnd = __WordGetHWND($o_win)
				If IsHWnd($h_hwnd) Then WinActivate($h_hwnd)
			EndIf
			Return SetError($_WordStatus_Success, 1, $o_Result)
		EndIf
	EndIf

	Local $result, $f_mustUnlock = 0, $i_ErrorStatusCode = $_WordStatus_Success
	If Not $f_visible Then
		$result = __WordLockSetForegroundWindow($WORD_LSFW_LOCK)
		If $result Then $f_mustUnlock = 1
	EndIf

	; Setup internal error handler to Trap COM errors, turn off error notification
	Local $status = __WordInternalErrorHandlerRegister()
	If Not $status Then __WordErrorNotify("Warning", "_WordCreate", _
			"Cannot register internal error handler, cannot trap COM errors", _
			"Use _WordErrorHandlerRegister() to register a user error handler")
	Local $f_NotifyStatus = _WordErrorNotify() ; save current error notify status
	_WordErrorNotify(False)

	Local $o_object = ObjGet("", "Word.Application")
	If Not IsObj($o_object) Or @error = $_WordStatus_ComError Then
		$i_ErrorStatusCode = $_WordStatus_NoMatch
	EndIf

	; restore error notify and error handler status
	_WordErrorNotify($f_NotifyStatus) ; restore notification status
	__WordInternalErrorHandlerDeRegister()

	If Not $i_ErrorStatusCode = $_WordStatus_Success Then
		$o_object = ObjCreate("Word.Application")
		If Not IsObj($o_object) Then
			__WordErrorNotify("Error", "_WordCreate", "", "Word Object Creation Failed")
			Return SetError($_WordStatus_GeneralError, 0, 0)
		EndIf
	EndIf

	$o_object.visible = $f_visible

	If $f_mustUnlock Then
		$result = __WordLockSetForegroundWindow($WORD_LSFW_UNLOCK)
		If Not $result Then __WordErrorNotify("Warning", "_WordCreate", "", "Foreground Window Unlock Failed!")
		; If the unlock doesn't work we will have created an unwanted modal window
	EndIf

	If $s_FilePath = "" Then
		_WordDocAdd($o_object)
	Else
		_WordDocOpen($o_object, $s_FilePath)
	EndIf
	Return SetError(@error, 0, $o_object)
EndFunc   ;==>_WordCreate

; #FUNCTION# ====================================================================================================================
; Name...........: _WordAttach
; Description ...: Attach to the first existing instance of Microsoft Word where the
;				   search string matches based on the selected mode.
; Parameters ....: $s_string	- String to search for
;				   $s_mode		- Optional: specifies search mode
;									FileName	= Name of the open document
;									FilePath	= (Default) Full path to the open document
;									HWND 		= hwnd of the word window
;									Text 		= Text from the body of the document
;									Title		= Title of the word window
; Return values .: On Success	- Returns an object variable pointing to the Word.Application object
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_WordStatus_Success) = No Error
;								- 1 ($_WordStatus_GeneralError) = General Error
;								- 5 ($_WordStatus_InvalidValue) = Invalid Value
;								- 7 ($_WordStatus_NoMatch) = No Match
;					@Extended	- Contains invalid parameter number
; Author ........: Bob Anthony
; ===============================================================================================================================
Func _WordAttach($s_string, $s_mode = "FilePath")
	$s_mode = StringLower($s_mode)

	Local $o_windows, $return, _
			$i_Extended, $s_ErrorMSG = "", $i_ErrorStatusCode = $_WordStatus_Success

	; Setup internal error handler to Trap COM errors, turn off error notification
	Local $status = __WordInternalErrorHandlerRegister()
	If Not $status Then __WordErrorNotify("Warning", "_WordAttach", _
			"Cannot register internal error handler, cannot trap COM errors", _
			"Use _WordErrorHandlerRegister() to register a user error handler")
	Local $f_NotifyStatus = _WordErrorNotify() ; save current error notify status
	_WordErrorNotify(False)

	Local $o_Result = ObjGet("", "Word.Application")
	If @error = $_WordStatus_ComError And $WordComErrorNumber = -2147221021 And $WordComErrorWinDescription = "Operation unavailable" Then
		$i_ErrorStatusCode = $_WordStatus_NoMatch
	EndIf

	If $i_ErrorStatusCode = $_WordStatus_Success Then
		$o_windows = $o_Result.Application.Windows
		If Not IsObj($o_windows) Then
			$i_ErrorStatusCode = $_WordStatus_NoMatch
		EndIf
	EndIf

	If $i_ErrorStatusCode = $_WordStatus_Success Then
		For $o_window In $o_windows

			Switch $s_mode
				Case "filename"
					If $o_window.Document.Name = $s_string Then
						$i_ErrorStatusCode = $_WordStatus_Success
						$o_window.Activate()
						$return = $o_window.Application
					EndIf
				Case "filepath"
					If $o_window.Document.FullName = $s_string Then
						$i_ErrorStatusCode = $_WordStatus_Success
						$o_window.Activate()
						$return = $o_window.Application
					EndIf
				Case "hwnd"
					Local $h_hwnd = __WordGetHWND($o_window)
					If IsHWnd($h_hwnd) Then
						If $h_hwnd = $s_string Then
							$i_ErrorStatusCode = $_WordStatus_Success
							$o_window.Activate()
							$return = $o_window.Application
						EndIf
					EndIf
				Case "text"
					If StringInStr($o_window.Document.Range().Text, $s_string) Then
						$i_ErrorStatusCode = $_WordStatus_Success
						$o_window.Activate()
						$return = $o_window.Application
					EndIf
				Case "title"
					If ($o_window.Caption & " - " & $o_window.Application.Caption) = $s_string Then
						$i_ErrorStatusCode = $_WordStatus_Success
						$o_window.Activate()
						$return = $o_window.Application
					EndIf
				Case Else
					; Invalid Mode
					$i_ErrorStatusCode = $_WordStatus_InvalidValue
					$s_ErrorMSG = "Invalid Mode Specified"
					$i_Extended = 2
			EndSwitch
		Next
		If Not IsObj($return) Then
			$i_ErrorStatusCode = $_WordStatus_NoMatch
		EndIf
	EndIf

	; restore error notify and error handler status
	_WordErrorNotify($f_NotifyStatus) ; restore notification status
	__WordInternalErrorHandlerDeRegister()

	Switch $i_ErrorStatusCode
		Case $_WordStatus_Success
			Return SetError($_WordStatus_Success, 0, $return)
		Case $_WordStatus_NoMatch
			__WordErrorNotify("Warning", "_WordAttach", "$_WordStatus_NoMatch")
			Return SetError($_WordStatus_NoMatch, 0, 0)
		Case $_WordStatus_InvalidValue
			__WordErrorNotify("Error", "_WordAttach", "$_WordStatus_InvalidValue", $s_ErrorMSG)
			Return SetError($_WordStatus_InvalidValue, $i_Extended, 0)
		Case Else
			__WordErrorNotify("Error", "_WordAttach", "$_WordStatus_GeneralError", "Invalid Error Status - Notify Word.au3 developer")
			Return SetError($_WordStatus_GeneralError, 0, 0)
	EndSwitch
EndFunc   ;==>_WordAttach

; #FUNCTION# ====================================================================================================================
; Name...........: _WordQuit
; Description ...: Close the window and remove the object reference to it
; Parameters ....: $o_object			- Object variable of a Word.Application
;				   $i_SaveChanges		- Optional: specifies the save action for the document
;											 0 = Do not save changes
;											-1 = Save changes
;											-2 = (Default) Prompt to save changes
;				   $i_OriginalFormat	- Optional: specifies the save format for the document
;											0 = Word Document
;											1 = (Default) Original Document Format
;											2 = Prompt User
;				   $f_RouteDocument	- Optional: specifies whether to route the document to the next recipient
;											0 = (Default) do not route
;											1 = route to next recipient
; Return values .: On Success	- Returns 1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_WordStatus_Success) = No Error
;								- 1 ($_WordStatus_GeneralError) = General Error
;								- 3 ($_WordStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_WordStatus_InvalidObjectType) = Invalid Object Type
;					@Extended	- Contains invalid parameter number
; Author ........: Bob Anthony
; ===============================================================================================================================
Func _WordQuit(ByRef $o_object, $i_SaveChanges = -2, $i_OriginalFormat = 1, $f_RouteDocument = 0)
	If Not IsObj($o_object) Then
		__WordErrorNotify("Error", "_WordQuit", "$_WordStatus_InvalidDataType")
		Return SetError($_WordStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __WordIsObjType($o_object, "application") Then
		__WordErrorNotify("Error", "_WordQuit", "$_WordStatus_InvalidObjectType")
		Return SetError($_WordStatus_InvalidObjectType, 1, 0)
	EndIf

	$o_object.Quit($i_SaveChanges, $i_OriginalFormat, $f_RouteDocument)
	$o_object = 0
	Return SetError($_WordStatus_Success, 0, 1)
EndFunc   ;==>_WordQuit

; #FUNCTION# ====================================================================================================================
; Name...........: _WordDocAdd
; Description ...: Returns an object variable representing a new empty document
; Parameters ....: $o_object		- Object variable of a Word.Application object
;				   $i_DocumentType	- Optional: specifies the new document type
;										0 = (Default) blank document
;										1 = Web page
;										2 = Email Message (need to figure out why this doesn't open)
;										3 = Frameset
;										4 = XML Document
;				   $s_Template		- Optional: specifies name of the template to be used for the new document
;										"" = (Default) normal template is used
;				   $f_NewTemplate	- Optional: specifies whether to open the document as a template
;										0 = (Default) do not open as template
;										1 = open as template
; Return values .: On Success	- Returns an object variable pointing to a Word.Application, document object
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_WordStatus_Success) = No Error
;								- 1 ($_WordStatus_GeneralError) = General Error
;								- 3 ($_WordStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_WordStatus_InvalidObjectType) = Invalid Object Type
;					@Extended	- Contains invalid parameter number
; Author ........: Bob Anthony
; ===============================================================================================================================
Func _WordDocAdd(ByRef $o_object, $i_DocumentType = 0, $s_Template = "", $f_NewTemplate = 0)
	If Not IsObj($o_object) Then
		__WordErrorNotify("Error", "_WordDocAdd", "$_WordStatus_InvalidDataType")
		Return SetError($_WordStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __WordIsObjType($o_object, "application") Then
		__WordErrorNotify("Error", "_WordDocAdd", "$_WordStatus_InvalidObjectType")
		Return SetError($_WordStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	Local $o_doc = $o_object.Documents.Add($s_Template, $f_NewTemplate, $i_DocumentType)
	If Not IsObj($o_doc) Then
		__WordErrorNotify("Error", "_WordDocAdd", "", "Document Object Creation Failed")
		Return SetError($_WordStatus_GeneralError, 0, 0)
	EndIf

	Return SetError($_WordStatus_Success, 0, $o_doc)
EndFunc   ;==>_WordDocAdd

; #FUNCTION# ====================================================================================================================
; Name...........: _WordDocOpen
; Description ...: Opens a Microsoft Word Document
; Parameters ....: $o_object				- Object variable of a Word.Application object
;				   $s_FilePath				- Full path of the document to open (See Remarks)
;				   $f_ConfirmConversions	- Optional: Specifies whether to display the Convert File dialog box
;												if the file isn't in Microsoft Word format.
;												0 = (Default) Do not display
;												1 = Display
;				   $i_Format				- Optional: The file converter to be used to open the document.
;												0 = (Default) The existing format
;												1 = Microsoft Word Document format
;												2 = Microsoft Word Template format
;												3 = Rich text format (RTF)
;												4 = Unencoded text format
;												5 = Unicode text format or Encoded text format
;												6 = Microsoft Word format that is backward compatible with earlier versions of Microsoft Word
;												7 = HTML format
;												8 = XML format
;				   $f_ReadOnly				- Optional: Specifies whether to open the document as read-only.
;												Note: This argument doesn't override the read-only recommended setting on a saved document.
;												0 = (Default) Open as Read/Write
;												1 = Open as Read Only
;				   $f_Revert				- Optional: Controls what happens if $s_FilePath is an open document.
;												0 = (Default) Activate the open document
;												1 = Discard any unsaved changes to the open document and reopen the file
;				   $f_AddToRecentFiles		- Optional: Specifies whether to add the file name to the list of recently used
;												files at the bottom of the File menu.
;												0 = (Default) Do not add
;												1 = Add
;				   $s_PasswordDocument		- Optional: The password for opening the document.
;												"" = (Default) Null
;				   $s_WritePasswordDocument- Optional: The password for saving changes to the document.
;												"" = (Default) Null
; Return values .: On Success	- Returns an object variable pointing to a Word.Application, document object
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_WordStatus_Success) = No Error
;								- 1 ($_WordStatus_GeneralError) = General Error
;								- 3 ($_WordStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_WordStatus_InvalidObjectType) = Invalid Object Type
;					@Extended	- Contains invalid parameter number
; Author ........: Bob Anthony
; Remarks .......: File will be created if it does not exist.
; ===============================================================================================================================
Func _WordDocOpen(ByRef $o_object, $s_FilePath, $f_ConfirmConversions = 0, $i_Format = 0, $f_ReadOnly = 0, $f_Revert = 0, $f_AddToRecentFiles = 0, $s_PasswordDocument = "", $s_WritePasswordDocument = "")
	If Not IsObj($o_object) Then
		__WordErrorNotify("Error", "_WordDocOpen", "$_WordStatus_InvalidDataType")
		Return SetError($_WordStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __WordIsObjType($o_object, "application") Then
		__WordErrorNotify("Error", "_WordDocOpen", "$_WordStatus_InvalidObjectType")
		Return SetError($_WordStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	Local $o_doc

	If Not FileExists($s_FilePath) Then
		__WordErrorNotify("Warning", "_WordDocOpen", "", "The specified file does not exist, but we will attempt to create it.")
		$o_doc = _WordDocAdd($o_object)
		If @error Then Return SetError(@error, 0, $o_doc)

		_WordDocSaveAs($o_doc, $s_FilePath)
		If @error Then
			__WordErrorNotify("Error", "_WordDocOpen", "", "The specified file could not be created.")
			Return SetError($_WordStatus_GeneralError, 2, 0)
		Else
			__WordErrorNotify("Info", "_WordDocOpen", "", "The specified file was created successfully.")
			Return SetError($_WordStatus_Success, 0, $o_doc)
		EndIf
	EndIf

	$o_doc = $o_object.Documents.Open($s_FilePath, $f_ConfirmConversions, $f_ReadOnly, $f_AddToRecentFiles, _
			$s_PasswordDocument, "", $f_Revert, $s_WritePasswordDocument, "", $i_Format)
	If Not IsObj($o_doc) Then
		__WordErrorNotify("Error", "_WordDocOpen", "", "Document Object Creation Failed")
		Return SetError($_WordStatus_GeneralError, 0, 0)
	EndIf

	Return SetError($_WordStatus_Success, 0, $o_doc)
EndFunc   ;==>_WordDocOpen

; #FUNCTION# ====================================================================================================================
; Name...........: _WordDocSave
; Description ...: Saves a previously opened document
; Parameters ....: $o_object			- Object variable of a Word.Application, document object
; Return values .: On Success	- Returns 1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_WordStatus_Success) = No Error
;								- 1 ($_WordStatus_GeneralError) = General Error
;								- 3 ($_WordStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_WordStatus_InvalidObjectType) = Invalid Object Type
;					@Extended	- Contains invalid parameter number
; Remarks .......: If a document hasn't been saved before, the Save As dialog box prompts the user for a file name
; Author ........: Bob Anthony
; ===============================================================================================================================
Func _WordDocSave(ByRef $o_object)
	If Not IsObj($o_object) Then
		__WordErrorNotify("Error", "_WordDocSave", "$_WordStatus_InvalidDataType")
		Return SetError($_WordStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __WordIsObjType($o_object, "document") Then
		__WordErrorNotify("Error", "_WordDocSave", "$_WordStatus_InvalidObjectType")
		Return SetError($_WordStatus_InvalidObjectType, 1, 0)
	EndIf

	If Not FileExists($o_object.FullName) Then
		__WordErrorNotify("Error", "_WordDocSave", "", "The specified document has not be saved, please use _WordDocSaveAs first.")
		Return SetError($_WordStatus_GeneralError, 1, 0)
	EndIf

	$o_object.Save
	Return SetError($_WordStatus_Success, 0, 1)
EndFunc   ;==>_WordDocSave

; #FUNCTION# ====================================================================================================================
; Name...........: _WordDocSaveAs
; Description ...: Saves the specified document with a new name or format.
; Parameters ....: $o_object				- Object variable of a Word.Application, document object
;				   $s_FilePath				- Optional: The full file path for saving the document. (See Remarks)
;												"" = (Default) If the document has never been saved,
;													the default name is used (for example, Document1.doc)
;				   $i_Format				- Optional: The format in which the document is saved.
;												0 = (Default) Microsoft Word format
;												1 = Microsoft Word template format
;												2 = Microsoft Windows text format
;												3 = Microsoft Windows text format with line breaks preserved
;												4 = Microsoft DOS text format
;												5 = Microsoft DOS text with line breaks preserved
;												6 = Rich text format (RTF)
;												7 = Unicode text format or Encoded text format
;												8 = Standard HTML format
;												9 = Web archive format
;												10 = Filtered HTML format
;												11 = Extensible Markup Language (XML) format
;				   $f_ReadOnlyRecommended	- Optional: Specifies whether to have Microsoft Word suggest
;												read-only status whenever the document is opened.
;												0 = (Default) Do not suggest read only
;												1 = Suggest read only
;				   $f_AddToRecentFiles		- Optional: Specifies whether to add the file name to the list of recently used
;												files at the bottom of the File menu.
;												0 = (Default) Do not add
;												1 = Add
;				   $f_LockComments			- Optional: Specifies whether to lock the document for comments.
;												0 = (Default) Do not lock for comments
;												1 = Lock for comments
;				   $s_Password				- Optional: A password string for opening the document. (See Remarks)
;				   $s_WritePassword		- Optional: A password string for saving changes to the document. (See Remarks)
; Return values .: On Success	- Returns 1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_WordStatus_Success) = No Error
;								- 1 ($_WordStatus_GeneralError) = General Error
;								- 3 ($_WordStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_WordStatus_InvalidObjectType) = Invalid Object Type
;					@Extended	- Contains invalid parameter number
; Author ........: Bob Anthony
; Remarks .......: If a document with the specified file name already exists, the document is overwritten without the user being prompted first.
;				   Avoid using hard-coded passwords in your applications. If a password is required in a procedure,
;				   request the password from the user, store it in a variable, and then use the variable in your code.
; ===============================================================================================================================
Func _WordDocSaveAs(ByRef $o_object, $s_FilePath = "", $i_Format = 0, $f_ReadOnlyRecommended = 0, $f_AddToRecentFiles = 0, $f_LockComments = 0, $s_Password = "", $s_WritePassword = "")
	If Not IsObj($o_object) Then
		__WordErrorNotify("Error", "_WordDocSaveAs", "$_WordStatus_InvalidDataType")
		Return SetError($_WordStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __WordIsObjType($o_object, "document") Then
		__WordErrorNotify("Error", "_WordDocSaveAs", "$_WordStatus_InvalidObjectType")
		Return SetError($_WordStatus_InvalidObjectType, 1, 0)
	EndIf

	If FileExists($s_FilePath) Then
		__WordErrorNotify("Warning", "_WordDocSaveAs", "", "The specified file path already exists and will be overwritten.")
	EndIf

	If $s_FilePath = "" Then
		$s_FilePath = $o_object.FullName
	EndIf

	$o_object.SaveAs($s_FilePath, $i_Format, $f_LockComments, $s_Password, _
			$f_AddToRecentFiles, $s_WritePassword, $f_ReadOnlyRecommended)
	Return SetError($_WordStatus_Success, 0, 1)
EndFunc   ;==>_WordDocSaveAs

; #FUNCTION# ====================================================================================================================
; Name...........: _WordDocClose
; Description ...: Closes a previously opened word document
; Parameters ....: $o_object			- Object variable of a Word.Application, document object
;				   $i_SaveChanges		- Optional: specifies the save action for the document
;											 0 = Do not save changes
;											-1 = Save changes
;											-2 = (Default) Prompt to save changes
;				   $i_OriginalFormat	- Optional: specifies the save format for the document
;											0 = Word Document
;											1 = Original Document Format
;											2 = (Default) Prompt User
;				   $f_RouteDocument	- Optional: specifies whether to route the document to the next recipient
;										0 = (Default) do not route
;										1 = route to next recipient
; Return values .: On Success	- Returns 1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_WordStatus_Success) = No Error
;								- 3 ($_WordStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_WordStatus_InvalidObjectType) = Invalid Object Type
;					@Extended	- Contains invalid parameter number
; Author ........: Bob Anthony
; ===============================================================================================================================
Func _WordDocClose(ByRef $o_object, $i_SaveChanges = -2, $i_OriginalFormat = 2, $f_RouteDocument = 0)
	If Not IsObj($o_object) Then
		__WordErrorNotify("Error", "_WordDocClose", "$_WordStatus_InvalidDataType")
		Return SetError($_WordStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __WordIsObjType($o_object, "document") Then
		__WordErrorNotify("Error", "_WordDocClose", "$_WordStatus_InvalidObjectType")
		Return SetError($_WordStatus_InvalidObjectType, 1, 0)
	EndIf

	$o_object.Close($i_SaveChanges, $i_OriginalFormat, $f_RouteDocument)
	Return SetError($_WordStatus_Success, 0, 1)
EndFunc   ;==>_WordDocClose

; #FUNCTION# ====================================================================================================================
; Name...........: _WordDocGetCollection
; Description ...: Returns a collection object containing all documents
; Parameters ....: $o_object	- Object variable of a Word.Application object
;				   $v_index	- Optional: Specifies whether to return a collection or indexed instance.
;									-1 = (Default) Returns a collection
;									 0 = Returns the Active Document
;									 The document name or index number to return (1 based)
; Return values .: On Success 	- Returns an object collection of all documents, @EXTENDED = document count
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_WordStatus_Success) = No Error
;								- 3 ($_WordStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_WordStatus_InvalidObjectType) = Invalid Object Type
;								- 5 ($_WordStatus_InvalidValue) = Invalid Value
;								- 7 ($_WordStatus_NoMatch) = No Match
;					@Extended	- Contains invalid parameter number
; Author ........: Bob Anthony
; ===============================================================================================================================
Func _WordDocGetCollection(ByRef $o_object, $v_index = -1)
	If Not IsObj($o_object) Then
		__WordErrorNotify("Error", "_WordDocGetCollection", "$_WordStatus_InvalidDataType")
		Return SetError($_WordStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __WordIsObjType($o_object, "application") Then
		__WordErrorNotify("Error", "_WordDocGetCollection", "$_WordStatus_InvalidObjectType")
		Return SetError($_WordStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	If IsNumber($v_index) Then
		Select
			Case $v_index = -1
				Return SetError($_WordStatus_Success, $o_object.Documents.Count, $o_object.Documents)
			Case $v_index = 0
				Return SetError($_WordStatus_Success, $o_object.Documents.Count, $o_object.ActiveDocument)
			Case $v_index > 0 And $v_index <= $o_object.Documents.Count
				Return SetError($_WordStatus_Success, $o_object.Documents.Count, $o_object.Documents($v_index))
			Case $v_index < -1
				__WordErrorNotify("Error", "_WordDocGetCollection", "$_WordStatus_InvalidValue")
				Return SetError($_WordStatus_InvalidValue, 2, 0)
			Case Else
				__WordErrorNotify("Warning", "_WordDocGetCollection", "$_WordStatus_NoMatch")
				Return SetError($_WordStatus_NoMatch, 2, 0)
		EndSelect
	Else
		For $o_doc In $o_object.Documents
			If $o_doc.Name = $v_index Then
				Return SetError($_WordStatus_Success, $o_object.Documents.Count, $o_doc)
			EndIf
		Next
		__WordErrorNotify("Warning", "_WordDocGetCollection", "$_WordStatus_NoMatch")
		Return SetError($_WordStatus_NoMatch, 2, 0)
	EndIf
EndFunc   ;==>_WordDocGetCollection

; #FUNCTION# ====================================================================================================================
; Name...........: _WordDocFindReplace
; Description ...: Runs the specified find and replace operation.
; Parameters ....: $o_object			- Object variable of a Word.Application, document object
;					$s_FindText			- Optional: The text to be searched for. (See Remarks)
;											"" = (Default) Used to search for formatting only.
;					$s_ReplaceWith		- Optional: The replacement text. (See Remarks)
;											"" = (Default) Delete the text specified by $s_FindText
;					$i_Replace			- Optional: Specifies how many replacements are to be made.
;											0 = Replace no occurrences
;											1 = Replace the first occurrence encountered
;											2 = (Default) Replace all occurrences
;					$v_SearchRange		- Optional: Specifies the Selection or Range to search.
;											-1 = Specifies the current selection
;											0 = (Default) Specifies the entire document
;											Any range object
;					$f_MatchCase		- Optional: Specifies whether the find text will be case-sensitive.
;											0 = (Default) Not case-sensitive
;											1 = Case-sensitive
;					$f_MatchWholeWord	- Optional: Specifies whether to have the find operation locate only entire words,
;											not text that's part of a larger word.
;											0 = (Default) Match partial words
;											1 = Only match entire words
;					$f_MatchWildcards	- Optional: Specifies whether to have $s_FindText be a special search operator.
;											0 = (Default) Not a special search operator
;											1 = Special search operator
;					$f_MatchSoundsLike	- Optional: Specifies whether to have the find operation locate words that sound similar to $s_FindText.
;											0 = (Default) Do not find similar sounding words
;											1 = Find similar sounding words
;					$f_MatchAllWordForms- Optional: Specifies whether to have the find operation locate all forms of the find text
;											(for example, "sit" locates "sitting" and "sat").
;											0 = (Default) Do not match other word forms
;											1 = Match all word forms
;					$f_Forward			- Optional: Specifies which direction to search.
;											0 = Search backward (toward the start of the document)
;											1 = (Default) Search forward (toward the end of the document)
;					$i_Wrap				- Optional: Controls what happens if the search begins at a point other than the beginning of the document
;											and the end of the document is reached (or vice versa if $f_Forward is set to 0).
;											0 = The find operation ends if the beginning or end of the search range is reached
;											1 = (Default) The find operation continues if the beginning or end of the search range is reached
;					$f_Format			- Optional: Specifies whether to have the find operation locate formatting in addition to or instead of the find text.
;											0 = (Default) Do not locate formatting
;											1 = Locate formatting
; Return values .: On Success	- Returns 1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_WordStatus_Success) = No Error
;								- 3 ($_WordStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_WordStatus_InvalidObjectType) = Invalid Object Type
;								- 5 ($_WordStatus_InvalidValue) = Invalid Value
;								- 7 ($_WordStatus_NoMatch) = No Match
;					@Extended	- Contains invalid parameter number
; Author ........: Bob Anthony
; ===============================================================================================================================
Func _WordDocFindReplace(ByRef $o_object, $s_FindText = "", $s_ReplaceWith = "", $i_Replace = 2, $v_SearchRange = 0, $f_MatchCase = 0, $f_MatchWholeWord = 0, $f_MatchWildcards = 0, $f_MatchSoundsLike = 0, $f_MatchAllWordForms = 0, $f_Forward = 1, $i_Wrap = 1, $f_Format = 0)
	If Not IsObj($o_object) Then
		__WordErrorNotify("Error", "_WordDocFindReplace", "$_WordStatus_InvalidDataType")
		Return SetError($_WordStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __WordIsObjType($o_object, "document") Then
		__WordErrorNotify("Error", "_WordDocFindReplace", "$_WordStatus_InvalidObjectType")
		Return SetError($_WordStatus_InvalidObjectType, 1, 0)
	EndIf
	;

	Select
		Case $v_SearchRange = -1
			$v_SearchRange = $o_object.Application.Selection.Range
		Case $v_SearchRange = 0
			$v_SearchRange = $o_object.Range()
		Case $v_SearchRange > -1
			__WordErrorNotify("Error", "_WordDocFindReplace", "$_WordStatus_InvalidValue")
			Return SetError($_WordStatus_InvalidValue, 5, 0)
		Case Else
			If Not __WordIsObjType($v_SearchRange, "range") Then
				__WordErrorNotify("Error", "_WordDocFindReplace", "$_WordStatus_InvalidObjectType")
				Return SetError($_WordStatus_InvalidObjectType, 5, 0)
			EndIf
	EndSelect

	Local $return
	Local $o_Find = $v_SearchRange.Find
	With $o_Find
		.ClearFormatting()
		.Replacement.ClearFormatting()
		$return = .Execute($s_FindText, $f_MatchCase, $f_MatchWholeWord, $f_MatchWildcards, $f_MatchSoundsLike, _
				$f_MatchAllWordForms, $f_Forward, $i_Wrap, $f_Format, $s_ReplaceWith, $i_Replace)
	EndWith

	If $return Then
		Return SetError($_WordStatus_Success, 0, 1)
	Else
		__WordErrorNotify("Warning", "_WordDocFindReplace", "$_WordStatus_NoMatch")
		Return SetError($_WordStatus_NoMatch, 0, 0)
	EndIf
EndFunc   ;==>_WordDocFindReplace

; #FUNCTION# ====================================================================================================================
; Name...........: _WordDocPrint
; Description ...: Prints all or part of the specified document.
; Parameters ....: $o_object		- Object variable of a Word.Application, document object
;					$f_Background	- Optional: Specifies whether to have the script continue while
;										Microsoft Word prints the document. (See Remarks)
;										0 = (Default) Wait for document to print
;										1 = Continue script without waiting
;					$i_Copies		- Optional: The number of copies to be printed.
;					$i_Orientation	- Optional: Sets the orientation of the page.
;										-1 = (Default) Current document orientation
;										 0 = Portrait
;										 1 = Landscape
;					$f_Collate		- Optional: Specifies whether to print all pages of the document before printing the next copy.
;										0 = Do not collate
;										1 = (Default) Collate
;					$s_Printer		- Optional: Sets the name of the printer.
;					$i_Range		- Optional: Specifies the page range.
;										0 = (Default) The entire document
;										1 = The current selection
;										2 = The current page
;										3 = A specified range (must specify $i_From and $i_To)
;										4 = A specified range of pages (must specify $s_Pages)
;					$i_From			- Optional: The starting page number when $i_Range is set to 3.
;					$i_To			- Optional: The ending page number when $i_Range is set to 3.
;					$s_Pages		- Optional: The page numbers and page ranges to be printed, separated by commas,
;										when $i_Range is set to 4. For example, "2, 6-10" prints page 2 and pages 6 through 10.
;					$i_PageType		- Optional: The type of pages to be printed.
;										0 = (Default) All pages
;										1 = Odd-numbered pages only
;										2 = Even-numbered pages only
;					$i_Item			- Optional: The item to be printed.
;										0 = (Default) Current document content
;										1 = Properties in the current document
;										2 = Comments and Markup in the current document
;										3 = Styles in the current document
;										4 = Autotext entries in the current document
;										5 = Key assignments in the current document
;										6 = An envelope
;										7 = Current document content including markup
; Return values .: On Success	- Returns 1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_WordStatus_Success) = No Error
;								- 1 ($_WordStatus_GeneralError) = General Error
;								- 2 ($_WordStatus_ComError) = Com Error
;								- 3 ($_WordStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_WordStatus_InvalidObjectType) = Invalid Object Type
;								- 5 ($_WordStatus_InvalidValue) = Invalid Value
;					@Extended	- Contains invalid parameter number
; Author ........: Bob Anthony
; Remarks .......: Specifying $f_Background does NOT pause the script until the document is finished printing,
;				   it only pauses until Microsoft Word finishes sending the document to the printer.
; ===============================================================================================================================
Func _WordDocPrint(ByRef $o_object, $f_Background = 0, $i_Copies = 1, $i_Orientation = -1, $f_Collate = 1, $s_Printer = "", $i_Range = 0, $i_From = "", $i_To = "", $s_Pages = "", $i_PageType = 0, $i_Item = 0)
	If Not IsObj($o_object) Then
		__WordErrorNotify("Error", "_WordDocPrint", "$_WordStatus_InvalidDataType")
		Return SetError($_WordStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __WordIsObjType($o_object, "document") Then
		__WordErrorNotify("Error", "_WordDocPrint", "$_WordStatus_InvalidObjectType")
		Return SetError($_WordStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	Local $s_ActivePrinter, $i_Extended, $i_DocOrientation = "", $i_ErrorStatusCode = $_WordStatus_Success, $s_ErrorMSG = ""

	Switch $i_Range
		Case 3
			If Not $i_From Or Not $i_To Then
				__WordErrorNotify("Error", "_WordDocPrint", "$_WordStatus_InvalidValue", _
						"When $i_Range is set to 3, then you must specify $i_From and $i_To.")
				Return SetError($_WordStatus_InvalidValue, 7, 0)
			EndIf
		Case 4
			If Not $s_Pages Then
				__WordErrorNotify("Error", "_WordDocPrint", "$_WordStatus_InvalidValue", _
						"When $i_Range is set to 4, you must specify $s_Pages.")
				Return SetError($_WordStatus_InvalidValue, 7, 0)
			EndIf
	EndSwitch

	$i_Orientation = String($i_Orientation)
	If $i_Orientation <> "-1" Then
		Switch $i_Orientation
			Case "0", "1"
				$i_DocOrientation = String($o_object.PageSetup.Orientation)
				If $i_DocOrientation <> $i_Orientation Then
					$o_object.PageSetup.Orientation = $i_Orientation
				EndIf
			Case Else
				__WordErrorNotify("Error", "_WordDocPrint", "$_WordStatus_InvalidValue")
				Return SetError($_WordStatus_InvalidValue, 4, 0)
		EndSwitch
	EndIf

	; Setup internal error handler to Trap COM errors, turn off error notification
	Local $status = __WordInternalErrorHandlerRegister()
	If Not $status Then __WordErrorNotify("Warning", "_WordDocPrint", _
			"Cannot register internal error handler, cannot trap COM errors", _
			"Use _WordErrorHandlerRegister() to register a user error handler")
	Local $f_NotifyStatus = _WordErrorNotify() ; save current error notify status
	_WordErrorNotify(False)

	If $s_Printer Then
		$s_ActivePrinter = $o_object.Application.ActivePrinter
		$o_object.Application.ActivePrinter = $s_Printer
		If @error = $_WordStatus_ComError And $WordComErrorNumber = -2147352567 And $WordComErrorDescription = "There is a printer error." Then
			$i_ErrorStatusCode = $_WordStatus_InvalidValue
			$s_ErrorMSG = "Invalid printer name specified."
			$i_Extended = 6
		EndIf
	EndIf

	$i_From = String($i_From)
	$i_To = String($i_To)
	If Not $i_ErrorStatusCode Then
		$o_object.PrintOut($f_Background, 0, $i_Range, "", $i_From, $i_To, $i_Item, $i_Copies, $s_Pages, $i_PageType, 0, $f_Collate)
		If @error = $_WordStatus_ComError Then
			$i_ErrorStatusCode = $_WordStatus_ComError
		EndIf
	EndIf

	If $i_DocOrientation <> "" And $i_DocOrientation <> $i_Orientation Then
		$o_object.PageSetup.Orientation = $i_DocOrientation
	EndIf
	If $s_ActivePrinter Then
		$o_object.Application.ActivePrinter = $s_ActivePrinter
	EndIf

	; restore error notify and error handler status
	_WordErrorNotify($f_NotifyStatus) ; restore notification status
	__WordInternalErrorHandlerDeRegister()

	Switch $i_ErrorStatusCode
		Case $_WordStatus_Success
			Return SetError($_WordStatus_Success, 0, 1)
		Case $_WordStatus_InvalidValue
			__WordErrorNotify("Error", "_WordDocPrint", "$_WordStatus_InvalidValue", $s_ErrorMSG)
			Return SetError($_WordStatus_InvalidValue, $i_Extended, 0)
		Case $_WordStatus_ComError
			__WordErrorNotify("Error", "_WordDocPrint", "$_WordStatus_ComError", "There was an error while executing the 'PrintOut' Method.")
			Return SetError($_WordStatus_ComError, 0, 0)
		Case Else
			__WordErrorNotify("Error", "_WordDocPrint", "$_WordStatus_GeneralError", "Invalid Error Status - Notify Word.au3 developer")
			Return SetError($_WordStatus_GeneralError, 0, 0)
	EndSwitch
EndFunc   ;==>_WordDocPrint

; #FUNCTION# ====================================================================================================================
; Name...........: _WordDocPropertyGet
; Description ...: Returns a select property of the Word Document.
; Parameters ....: $o_object	- Object variable of a Word.Application, document object
;				   $v_property	- Property selection
; Requirement(s):   AutoIt3 Beta with COM support (post 3.1.1)
; Return values .: On Success	- Value of selected Property
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_WordStatus_Success) = No Error
;								- 1 ($_WordStatus_GeneralError) = General Error
;								- 2 ($_WordStatus_ComError) = Com Error
;								- 3 ($_WordStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_WordStatus_InvalidObjectType) = Invalid Object Type
;								- 5 ($_WordStatus_InvalidValue) = Invalid Value
;					@Extended	- Contains invalid parameter number
; Author ........: Bob Anthony
; ===============================================================================================================================
Func _WordDocPropertyGet(ByRef $o_object, $v_property)
	If Not IsObj($o_object) Then
		__WordErrorNotify("Error", "_WordDocPropertyGet", "$_WordStatus_InvalidDataType")
		Return SetError($_WordStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __WordIsObjType($o_object, "document") Then
		__WordErrorNotify("Error", "_WordDocPropertyGet", "$_WordStatus_InvalidObjectType")
		Return SetError($_WordStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	Local $s_Property, $s_ErrorMSG, $i_Extended, $i_ErrorStatusCode = $_WordStatus_Success

	; Setup internal error handler to Trap COM errors, turn off error notification
	Local $status = __WordInternalErrorHandlerRegister()
	If Not $status Then __WordErrorNotify("Warning", "_WordDocPropertyGet", _
			"Cannot register internal error handler, cannot trap COM errors", _
			"Use _WordErrorHandlerRegister() to register a user error handler")
	Local $f_NotifyStatus = _WordErrorNotify() ; save current error notify status
	_WordErrorNotify(False)

	If IsNumber($v_property) Then
		Switch $v_property
			Case 19, 25 To 28
				$i_ErrorStatusCode = $_WordStatus_InvalidValue
				$s_ErrorMSG = "The specified property is not supported."
				$i_Extended = 2
			Case 1 To 30
				$s_Property = $o_object.BuiltInDocumentProperties($v_property).value
				If @error = $_WordStatus_ComError Then
					$i_ErrorStatusCode = $_WordStatus_ComError
					$s_ErrorMSG = "The specified property has not been defined."
					$i_Extended = 2
				EndIf
			Case Else
				$i_ErrorStatusCode = $_WordStatus_InvalidValue
				$s_ErrorMSG = "The specified property does not exist."
				$i_Extended = 2
		EndSwitch
	Else
		Switch $v_property
			Case "Title", "Subject", "Author", "Keywords", "Comments", "Template", "Last Author", "Revision Number", "Application Name", _
					"Last Print Date", "Creation Date", "Last Save Time", "Total Editing Time", "Security", "Category", "Manager", "Company", "Hyperlink base"
				$s_Property = $o_object.BuiltInDocumentProperties($v_property).value
				If @error = $_WordStatus_ComError Then
					$i_ErrorStatusCode = $_WordStatus_ComError
					$s_ErrorMSG = "The specified property has not been defined."
					$i_Extended = 2
				EndIf
			Case "Pages", "Words", "Characters", "Characters (with spaces)", "Bytes", "Lines", "Paragraphs"
				$s_Property = $o_object.BuiltInDocumentProperties("Number of " & $v_property).value
				If @error = $_WordStatus_ComError Then
					$i_ErrorStatusCode = $_WordStatus_ComError
					$s_ErrorMSG = "The specified property has not been defined."
					$i_Extended = 2
				EndIf
			Case Else
				$i_ErrorStatusCode = $_WordStatus_InvalidValue
				$s_ErrorMSG = "The specified property does not exist."
				$i_Extended = 2
		EndSwitch
	EndIf

	; restore error notify and error handler status
	_WordErrorNotify($f_NotifyStatus) ; restore notification status
	__WordInternalErrorHandlerDeRegister()

	Switch $i_ErrorStatusCode
		Case $_WordStatus_Success
			Return SetError($_WordStatus_Success, 0, $s_Property)
		Case $_WordStatus_InvalidValue
			__WordErrorNotify("Error", "_WordDocPropertyGet", "$_WordStatus_InvalidValue", $s_ErrorMSG)
			Return SetError($_WordStatus_InvalidValue, $i_Extended, 0)
		Case $_WordStatus_ComError
			__WordErrorNotify("Error", "_WordDocPropertyGet", "$_WordStatus_ComError", $s_ErrorMSG)
			Return SetError($_WordStatus_ComError, $i_Extended, 0)
		Case Else
			__WordErrorNotify("Error", "_WordDocPropertyGet", "$_WordStatus_GeneralError", "Invalid Error Status - Notify Word.au3 developer")
			Return SetError($_WordStatus_GeneralError, 0, 0)
	EndSwitch
EndFunc   ;==>_WordDocPropertyGet

; #FUNCTION# ====================================================================================================================
; Name...........: _WordDocPropertySet
; Description ...: Set a select property of the Word Document.
; Parameters ....: $o_object	- Object variable of a Word.Application, document object
;				   $v_property	- Property selection
;				   $v_newvalue	- The new value to be set into the Word Document Property
; Return values .: On Success	- Returns 1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_WordStatus_Success) = No Error
;								- 1 ($_WordStatus_GeneralError) = General Error
;								- 2 ($_WordStatus_ComError) = Com Error
;								- 3 ($_WordStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_WordStatus_InvalidObjectType) = Invalid Object Type
;								- 5 ($_WordStatus_InvalidValue) = Invalid Value
;					@Extended	- Contains invalid parameter number
; Author ........: Bob Anthony
; ===============================================================================================================================
Func _WordDocPropertySet(ByRef $o_object, $v_property, $v_newvalue)
	If Not IsObj($o_object) Then
		__WordErrorNotify("Error", "_WordDocPropertySet", "$_WordStatus_InvalidDataType")
		Return SetError($_WordStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __WordIsObjType($o_object, "document") Then
		__WordErrorNotify("Error", "_WordDocPropertySet", "$_WordStatus_InvalidObjectType")
		Return SetError($_WordStatus_InvalidObjectType, 1, 0)
	EndIf

	Local $s_ErrorMSG, $i_Extended, $i_ErrorStatusCode = $_WordStatus_Success

	; Setup internal error handler to Trap COM errors, turn off error notification
	Local $status = __WordInternalErrorHandlerRegister()
	If Not $status Then __WordErrorNotify("Warning", "_WordDocPropertySet", _
			"Cannot register internal error handler, cannot trap COM errors", _
			"Use _WordErrorHandlerRegister() to register a user error handler")
	Local $f_NotifyStatus = _WordErrorNotify() ; save current error notify status
	_WordErrorNotify(False)

	If IsNumber($v_property) Then
		Switch $v_property
			Case 1 To 6, 9, 18, 20, 21, 29
				$o_object.BuiltInDocumentProperties($v_property).value = $v_newvalue
				If @error = $_WordStatus_ComError Then
					$i_ErrorStatusCode = $_WordStatus_ComError
					$s_ErrorMSG = "There was an error while setting the selected property."
					$i_Extended = 3
				EndIf
			Case 1 To 30
				$i_ErrorStatusCode = $_WordStatus_InvalidValue
				$s_ErrorMSG = "The specified property is not supported."
				$i_Extended = 2
			Case Else
				$i_ErrorStatusCode = $_WordStatus_InvalidValue
				$s_ErrorMSG = "The specified property does not exist."
				$i_Extended = 2
		EndSwitch
	Else
		Switch $v_property
			Case "Title", "Subject", "Author", "Keywords", "Comments", "Template", _
					"Application Name", "Category", "Manager", "Company", "Hyperlink base"
				$o_object.BuiltInDocumentProperties($v_property).value = $v_newvalue
				If @error = $_WordStatus_ComError Then
					$i_ErrorStatusCode = $_WordStatus_ComError
					$s_ErrorMSG = "There was an error while setting the selected property."
					$i_Extended = 3
				EndIf
			Case Else
				$i_ErrorStatusCode = $_WordStatus_InvalidValue
				$s_ErrorMSG = "The specified property does not exist."
				$i_Extended = 2
		EndSwitch
	EndIf

	; restore error notify and error handler status
	_WordErrorNotify($f_NotifyStatus) ; restore notification status
	__WordInternalErrorHandlerDeRegister()

	Switch $i_ErrorStatusCode
		Case $_WordStatus_Success
			Return SetError($_WordStatus_Success, 0, 1)
		Case $_WordStatus_InvalidValue
			__WordErrorNotify("Error", "_WordDocPropertySet", "$_WordStatus_InvalidValue", $s_ErrorMSG)
			Return SetError($_WordStatus_InvalidValue, $i_Extended, 0)
		Case $_WordStatus_ComError
			__WordErrorNotify("Error", "_WordDocPropertySet", "$_WordStatus_ComError", $s_ErrorMSG)
			Return SetError($_WordStatus_ComError, $i_Extended, 0)
		Case Else
			__WordErrorNotify("Error", "_WordDocPropertySet", "$_WordStatus_GeneralError", "Invalid Error Status - Notify Word.au3 developer")
			Return SetError($_WordStatus_GeneralError, 0, 0)
	EndSwitch
EndFunc   ;==>_WordDocPropertySet

; #FUNCTION# ====================================================================================================================
; Name...........: _WordDocLinkGetCollection
; Description ...: Returns a collection object containing all links in the document
; Parameters ....: $o_object - Object variable of an Word.Application, document object
;				   $i_index	 - Optional: specifies whether to return a collection or indexed instance
;								- Positive integer returns an indexed instance (1 based)
;								- -1 = (Default) returns a collection
; Return values .: On Success 	- Returns an object collection of all links in the document, @EXTENDED = link count
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_WordStatus_Success) = No Error
;								- 3 ($_WordStatus_InvalidDataType) = Invalid Data Type
;								- 5 ($_WordStatus_InvalidValue) = Invalid Value
;								- 7 ($_WordStatus_NoMatch) = No Match
;					@Extended	- Contains invalid parameter number
; Author ........: Bob Anthony
; ===============================================================================================================================
Func _WordDocLinkGetCollection(ByRef $o_object, $i_index = -1)
	If Not IsObj($o_object) Then
		__WordErrorNotify("Error", "_WordDocLinkGetCollection", "$_WordStatus_InvalidDataType")
		Return SetError($_WordStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __WordIsObjType($o_object, "document") Then
		__WordErrorNotify("Error", "_WordDocLinkGetCollection", "$_WordStatus_InvalidObjectType")
		Return SetError($_WordStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	$i_index = Number($i_index)
	Select
		Case $i_index = -1
			Return SetError($_WordStatus_Success, $o_object.Hyperlinks.Count, $o_object.Hyperlinks)
		Case $i_index > 0 And $i_index <= $o_object.Hyperlinks.Count
			Return SetError($_WordStatus_Success, $o_object.Hyperlinks.Count, $o_object.Hyperlinks.Item($i_index))
		Case $i_index < -1 Or $i_index = 0
			__WordErrorNotify("Error", "_WordDocLinkGetCollection", "$_WordStatus_InvalidValue")
			Return SetError($_WordStatus_InvalidValue, 2, 0)
		Case Else
			__WordErrorNotify("Warning", "_WordDocLinkGetCollection", "$_WordStatus_NoMatch")
			Return SetError($_WordStatus_NoMatch, 2, 0)
	EndSelect
EndFunc   ;==>_WordDocLinkGetCollection

; #FUNCTION# ====================================================================================================================
; Name...........: _WordDocAddLink
; Description ...: Add a hyperlink to the document
; Parameters ....: $o_object			- Object variable of a Word.Application, document object
;				   $o_Anchor			- Optional: The text or graphic that you want turned into a hyperlink.
;											"" = (Default) Uses entire document as range
;				   $s_Address			- Optional: The address for the specified link. The address can be an
;											e-mail address, an Internet address, or a file name.
;											"" = (Default) Link to the specified document is used
;				   $s_SubAddress		- Optional: The name of a location within the destination file, such as
;											a bookmark, named range, or slide number.
;				   $s_ScreenTip		- Optional: The text that appears as a ScreenTip when the mouse pointer is
;											positioned over the specified hyperlink.
;											"" = (Default) Uses value of $s_Address
;				   $s_TextToDisplay	- Optional: The display text of the specified hyperlink. The value of this
;											argument replaces the text or graphic specified by Anchor.
;											"" = (Default) Uses value of $s_Address
;				   $s_Target			- Optional: The name of the frame or window in which you want to load the specified hyperlink.
; Return values .: On Success	- Returns 1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_WordStatus_Success) = No Error
;								- 3 ($_WordStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_WordStatus_InvalidObjectType) = Invalid Object Type
;					@Extended	- Contains invalid parameter number
; Author ........: Bob Anthony
; ===============================================================================================================================
Func _WordDocAddLink(ByRef $o_object, $o_Anchor = "", $s_Address = "", $s_SubAddress = "", $s_ScreenTip = "", $s_TextToDisplay = "", $s_Target = "")
	If Not IsObj($o_object) Then
		__WordErrorNotify("Error", "_WordDocAddLink", "$_WordStatus_InvalidDataType")
		Return SetError($_WordStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __WordIsObjType($o_object, "document") Then
		__WordErrorNotify("Error", "_WordDocAddLink", "$_WordStatus_InvalidObjectType")
		Return SetError($_WordStatus_InvalidObjectType, 1, 0)
	EndIf

	If $o_Anchor = "" Then
		$o_Anchor = $o_object.Range()
	EndIf

	If $s_Address = "" Then
		$s_Address = $o_object.FullName
	EndIf

	$o_object.Hyperlinks.Add($o_Anchor, $s_Address, $s_SubAddress, $s_ScreenTip, $s_TextToDisplay, $s_Target)
	Return SetError($_WordStatus_Success, 0, 1)
EndFunc   ;==>_WordDocAddLink

; #FUNCTION# ====================================================================================================================
; Name...........: _WordDocAddPicture
; Description ...: Add a picture to the document
; Parameters ....: $o_object			- Object variable of a Word.Application, document object.
;				   $s_FilePath			- The path and file name of the picture.
;				   $f_LinkToFile		- Optional: Specifies whether to link the picture to the file from which it was created.
;											0 = (Default) Make the picture an independent copy of the file
;											1 = Link the picture to the file from which it was created
;				   $f_SaveWithDocument	- Optional: Specifies whether to save the linked picture with the document.
;											0 = (Default) Do not save the linked picture with the document
;											1 = Save the linked picture with the document
;				   $o_Range			- Optional: The location where the picture will be placed in the text.
;											"" = (Default) The picture is placed automatically
;											Any range object
; Return values .: On Success	- Returns an object variable pointing to a Word.Application, shape object
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_WordStatus_Success) = No Error
;								- 1 ($_WordStatus_GeneralError) = General Error
;								- 2 ($_WordStatus_ComError) = Com Error
;								- 3 ($_WordStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_WordStatus_InvalidObjectType) = Invalid Object Type
;								- 5 ($_WordStatus_InvalidValue) = Invalid Value
;					@Extended	- Contains invalid parameter number
; Author ........: Bob Anthony
; ===============================================================================================================================
Func _WordDocAddPicture(ByRef $o_object, $s_FilePath, $f_LinkToFile = 0, $f_SaveWithDocument = 0, $o_Range = "")
	If Not IsObj($o_object) Then
		__WordErrorNotify("Error", "_WordDocAddPicture", "$_WordStatus_InvalidDataType")
		Return SetError($_WordStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __WordIsObjType($o_object, "document") Then
		__WordErrorNotify("Error", "_WordDocAddPicture", "$_WordStatus_InvalidObjectType")
		Return SetError($_WordStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	If Not FileExists($s_FilePath) Then
		__WordErrorNotify("Error", "_WordDocAddPicture", "$_WordStatus_InvalidValue", "The specified file does not exist.")
		Return SetError($_WordStatus_InvalidValue, 2, 0)
	EndIf
	;
	Local $o_Shape, $f_Range, $i_ErrorStatusCode = $_WordStatus_Success

	If $o_Range = "" Then
		$f_Range = False
	Else
		If Not __WordIsObjType($o_Range, "range") Then
			__WordErrorNotify("Error", "_WordDocAddPicture", "$_WordStatus_InvalidObjectType")
			Return SetError($_WordStatus_InvalidObjectType, 5, 0)
		EndIf
		$f_Range = True
	EndIf

	; Setup internal error handler to Trap COM errors, turn off error notification
	Local $status = __WordInternalErrorHandlerRegister()
	If Not $status Then __WordErrorNotify("Warning", "_WordDocAddPicture", _
			"Cannot register internal error handler, cannot trap COM errors", _
			"Use _WordErrorHandlerRegister() to register a user error handler")
	Local $f_NotifyStatus = _WordErrorNotify() ; save current error notify status
	_WordErrorNotify(False)

	If $f_Range Then
		$o_Shape = $o_object.InlineShapes.AddPicture($s_FilePath, $f_LinkToFile, $f_SaveWithDocument, $o_Range)
	Else
		$o_Shape = $o_object.InlineShapes.AddPicture($s_FilePath, $f_LinkToFile, $f_SaveWithDocument)
	EndIf
	If @error = $_WordStatus_ComError Then $i_ErrorStatusCode = $_WordStatus_ComError

	; restore error notify and error handler status
	_WordErrorNotify($f_NotifyStatus) ; restore notification status
	__WordInternalErrorHandlerDeRegister()

	Switch $i_ErrorStatusCode
		Case $_WordStatus_Success
			Return SetError($_WordStatus_Success, 0, $o_Shape)
		Case $_WordStatus_ComError
			__WordErrorNotify("Error", "_WordDocAddPicture", "$_WordStatus_ComError", "There was an error while executing the 'AddPicture' Method.")
			Return SetError($_WordStatus_ComError, 0, 0)
		Case Else
			__WordErrorNotify("Error", "_WordDocAddPicture", "$_WordStatus_GeneralError", "Invalid Error Status - Notify Word.au3 developer")
			Return SetError($_WordStatus_GeneralError, 0, 0)
	EndSwitch
EndFunc   ;==>_WordDocAddPicture

; #FUNCTION# ====================================================================================================================
; Function Name:   _WordErrorHandlerRegister
; Description ...: Register and enable a user COM error handler
; Parameters ....: $s_functionName - String variable with the name of a user-defined COM error handler
;									  defaults to the internal COM error handler in this UDF
; Requirement(s):   AutoIt3 Beta with COM support (post 3.1.1)
; Return values .: On Success 	- Returns 1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_WordStatus_Success) = No Error
;								- 1 ($_WordStatus_GeneralError) = General Error
;					@Extended	- Contains invalid parameter number
; Author ........: Bob Anthony
; ===============================================================================================================================
Func _WordErrorHandlerRegister($s_functionName = "__WordInternalErrorHandler")
	$sWordUserErrorHandler = $s_functionName
	$oWordErrorHandler = ""
	$oWordErrorHandler = ObjEvent("AutoIt.Error", $s_functionName)
	If IsObj($oWordErrorHandler) Then
		Return SetError($_WordStatus_Success, 0, 1)
	Else
		__WordErrorNotify("Error", "_WordErrorHandlerRegister", "$_WordStatus_GeneralError", _
				"Error Handler Not Registered - Check existance of error function")
		Return SetError($_WordStatus_GeneralError, 1, 0)
	EndIf
EndFunc   ;==>_WordErrorHandlerRegister

; #FUNCTION# ====================================================================================================================
; Function Name:   _WordErrorHandlerDeRegister
; Description ...: Disable a registered user COM error handler
; Parameters ....: None
; Return values .: On Success 	- Returns 1
;                  On Failure	- None
; Author ........: Bob Anthony
;
; ===============================================================================================================================
Func _WordErrorHandlerDeRegister()
	$sWordUserErrorHandler = ""
	$oWordErrorHandler = ""
	Return SetError($_WordStatus_Success, 0, 1)
EndFunc   ;==>_WordErrorHandlerDeRegister

; #FUNCTION# ====================================================================================================================
; Function Name:   _WordErrorNotify
; Description ...: Specifies whether Word.au3 automatically notifies of Warnings and Errors (to the console)
; Parameters ....: $f_notify	- Optional: specifies whether notification should be on or off
;								- -1 = (Default) return current setting
;								- True = Turn On
;								- False = Turn Off
; Return values .: On Success 	- If $f_notify = -1, returns the current notification setting, else returns 1
;                  On Failure	- Returns 0
; Author ........: Bob Anthony
; ===============================================================================================================================
Func _WordErrorNotify($f_notify = -1)
	Switch Number($f_notify)
		Case -1
			Return $_WordErrorNotify
		Case 0
			$_WordErrorNotify = False
			Return 1
		Case 1
			$_WordErrorNotify = True
			Return 1
		Case Else
			__WordErrorNotify("Error", "_WordErrorNotify", "$_WordStatus_InvalidValue")
			Return 0
	EndSwitch
EndFunc   ;==>_WordErrorNotify

; #FUNCTION# ====================================================================================================================
; Name...........: _WordMacroRun
; Description ...: Runs a Visual Basic macro
; Parameters ....: $o_object			- Object variable of a Word.Application object
;				   $s_MacroName		- The name of the macro. Can be any combination of template,
;											module, and macro name. (See Remarks)
;				   $v_Arg1				- Optional: The first parameter to pass to the macro
;					$v_Argn			- ...
;				   $v_Arg30			- Optional: The thirtieth parameter to pass to the macro
; Return values .: On Success	- Returns 1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_WordStatus_Success) = No Error
;								- 1 ($_WordStatus_GeneralError) = General Error
;								- 2 ($_WordStatus_ComError) = Com Error
;								- 3 ($_WordStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_WordStatus_InvalidObjectType) = Invalid Object Type
;					@Extended	- Contains invalid parameter number
; Author ........: Bob Anthony
; Remarks .......: If you specify the document name, your code can only run macros in documents
;				   related to the current context — not just any macro in any document.
; ===============================================================================================================================
Func _WordMacroRun(ByRef $o_object, $s_MacroName, $v_Arg1 = Default, $v_Arg2 = Default, $v_Arg3 = Default, $v_Arg4 = Default, $v_Arg5 = Default, $v_Arg6 = Default, $v_Arg7 = Default, $v_Arg8 = Default, $v_Arg9 = Default, $v_Arg10 = Default, $v_Arg11 = Default, $v_Arg12 = Default, $v_Arg13 = Default, $v_Arg14 = Default, $v_Arg15 = Default, $v_Arg16 = Default, $v_Arg17 = Default, $v_Arg18 = Default, $v_Arg19 = Default, $v_Arg20 = Default, $v_Arg21 = Default, $v_Arg22 = Default, $v_Arg23 = Default, $v_Arg24 = Default, $v_Arg25 = Default, $v_Arg26 = Default, $v_Arg27 = Default, $v_Arg28 = Default, $v_Arg29 = Default, $v_Arg30 = Default)

	If Not IsObj($o_object) Then
		__WordErrorNotify("Error", "_WordMacroRun", "$_WordStatus_InvalidDataType")
		Return SetError($_WordStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __WordIsObjType($o_object, "application") Then
		__WordErrorNotify("Error", "_WordMacroRun", "$_WordStatus_InvalidObjectType")
		Return SetError($_WordStatus_InvalidObjectType, 1, 0)
	EndIf
	;
	Local $s_ErrorMSG, $i_Extended, $i_ErrorStatusCode = $_WordStatus_Success

	; Setup internal error handler to Trap COM errors, turn off error notification
	Local $status = __WordInternalErrorHandlerRegister()
	If Not $status Then __WordErrorNotify("Warning", "_WordMacroRun", _
			"Cannot register internal error handler, cannot trap COM errors", _
			"Use _WordErrorHandlerRegister() to register a user error handler")
	Local $f_NotifyStatus = _WordErrorNotify() ; save current error notify status
	_WordErrorNotify(False)

	$o_object.Run($s_MacroName, $v_Arg1, $v_Arg2, $v_Arg3, $v_Arg4, $v_Arg5, _
			$v_Arg6, $v_Arg7, $v_Arg8, $v_Arg9, $v_Arg10, _
			$v_Arg11, $v_Arg12, $v_Arg13, $v_Arg14, $v_Arg15, _
			$v_Arg16, $v_Arg17, $v_Arg18, $v_Arg19, $v_Arg20, _
			$v_Arg21, $v_Arg22, $v_Arg23, $v_Arg24, $v_Arg25, _
			$v_Arg26, $v_Arg27, $v_Arg28, $v_Arg29, $v_Arg30)

	If @error = $_WordStatus_ComError Then
		If $WordComErrorNumber = -2147352567 Then
			$i_ErrorStatusCode = $_WordStatus_InvalidValue
			Switch $WordComErrorWinDescription
				Case "Member not found."
					$s_ErrorMSG = "The specified macro does not exist."
					$i_Extended = 2
				Case "Invalid number of parameters."
					$s_ErrorMSG = "Invalid number of parameters."
					$i_Extended = -1
			EndSwitch
		Else
			$i_ErrorStatusCode = $_WordStatus_ComError
		EndIf
	EndIf

	; restore error notify and error handler status
	_WordErrorNotify($f_NotifyStatus) ; restore notification status
	__WordInternalErrorHandlerDeRegister()

	Switch $i_ErrorStatusCode
		Case $_WordStatus_Success
			Return SetError($_WordStatus_Success, 0, 1)
		Case $_WordStatus_InvalidValue
			__WordErrorNotify("Error", "_WordMacroRun", "$_WordStatus_InvalidValue", $s_ErrorMSG)
			Return SetError($_WordStatus_InvalidValue, $i_Extended, 0)
		Case $_WordStatus_ComError
			__WordErrorNotify("Error", "_WordMacroRun", "$_WordStatus_ComError", "There was an error while executing the 'Run' Method.")
			Return SetError($_WordStatus_ComError, 0, 0)
		Case Else
			__WordErrorNotify("Error", "_WordMacroRun", "$_WordStatus_GeneralError", "Invalid Error Status - Notify Word.au3 developer.")
			Return SetError($_WordStatus_GeneralError, 0, 0)
	EndSwitch
EndFunc   ;==>_WordMacroRun

; #FUNCTION# ====================================================================================================================
; Name...........: _WordPropertyGet
; Description ...: Returns a select property of the Word Application
; Parameters ....: $o_object	- Object variable of a Word.Application
;				   $s_property	- Property selection
; Return values .: On Success	- Value of selected Property
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_WordStatus_Success) = No Error
;								- 3 ($_WordStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_WordStatus_InvalidObjectType) = Invalid Object Type
;								- 5 ($_WordStatus_InvalidValue) = Invalid Value
;					@Extended	- Contains invalid parameter number
; Author ........: Bob Anthony
; ===============================================================================================================================
Func _WordPropertyGet(ByRef $o_object, $s_Property)
	If Not IsObj($o_object) Then
		__WordErrorNotify("Error", "_WordPropertyGet", "$_WordStatus_InvalidDataType")
		Return SetError($_WordStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __WordIsObjType($o_object, "wordobj") Then
		__WordErrorNotify("Error", "_WordPropertyGet", "$_WordStatus_InvalidObjectType")
		Return SetError($_WordStatus_InvalidObjectType, 1, 0)
	EndIf

	$s_Property = StringLower($s_Property)
	Switch $s_Property
		Case "activeprinter"
			Return SetError($_WordStatus_Success, 0, $o_object.Application.ActivePrinter)
		Case "capslock"
			Return SetError($_WordStatus_Success, 0, $o_object.Application.CapsLock)
		Case "screentips"
			If __WordIsObjType($o_object, "window") Then
				Return SetError($_WordStatus_Success, 0, $o_object.DisplayScreenTips)
			Else
				Return SetError($_WordStatus_Success, 0, $o_object.Application.DisplayScreenTips)
			EndIf
		Case "scrollbars"
			Return SetError($_WordStatus_Success, 0, $o_object.Application.DisplayScrollBars)
		Case "statusbar"
			Return SetError($_WordStatus_Success, 0, $o_object.Application.DisplayStatusBar)
		Case "height"
			If __WordIsObjType($o_object, "window") Then
				Return SetError($_WordStatus_Success, 0, $o_object.Height)
			Else
				Return SetError($_WordStatus_Success, 0, $o_object.Application.Height)
			EndIf
		Case "language"
			Return SetError($_WordStatus_Success, 0, $o_object.Application.Language)
		Case "left"
			If __WordIsObjType($o_object, "window") Then
				Return SetError($_WordStatus_Success, 0, $o_object.Left)
			Else
				Return SetError($_WordStatus_Success, 0, $o_object.Application.Left)
			EndIf
		Case "numlock"
			Return SetError($_WordStatus_Success, 0, $o_object.Application.Numlock)
		Case "path"
			If __WordIsObjType($o_object, "document") Then
				Return SetError($_WordStatus_Success, 0, $o_object.Path)
			Else
				Return SetError($_WordStatus_Success, 0, $o_object.Application.Path)
			EndIf
		Case "screenupdating"
			Return SetError($_WordStatus_Success, 0, $o_object.Application.ScreenUpdating)
		Case "startuppath"
			Return SetError($_WordStatus_Success, 0, $o_object.Application.StartupPath)
		Case "top"
			If __WordIsObjType($o_object, "window") Then
				Return SetError($_WordStatus_Success, 0, $o_object.Top)
			Else
				Return SetError($_WordStatus_Success, 0, $o_object.Application.Top)
			EndIf
		Case "version"
			Return SetError($_WordStatus_Success, 0, $o_object.Application.Version)
		Case "visible"
			If __WordIsObjType($o_object, "window") Then
				Return SetError($_WordStatus_Success, 0, $o_object.Visible)
			Else
				Return SetError($_WordStatus_Success, 0, $o_object.Application.Visible)
			EndIf
		Case "width"
			If __WordIsObjType($o_object, "window") Then
				Return SetError($_WordStatus_Success, 0, $o_object.Width)
			Else
				Return SetError($_WordStatus_Success, 0, $o_object.Application.Width)
			EndIf
		Case "windowstate"
			If __WordIsObjType($o_object, "window") Then
				Return SetError($_WordStatus_Success, 0, $o_object.WindowState)
			Else
				Return SetError($_WordStatus_Success, 0, $o_object.Application.WindowState)
			EndIf
		Case Else
			; Unsupported Property
			__WordErrorNotify("Error", "_WordPropertyGet", "$_WordStatus_InvalidValue", "Invalid Property")
			Return SetError($_WordStatus_InvalidValue, 2, 0)
	EndSwitch
EndFunc   ;==>_WordPropertyGet

; #FUNCTION# ====================================================================================================================
; Name...........: _WordPropertySet
; Description ...: Set a select property of the Word Application
; Parameters ....: $o_object	- Object variable of a Word.Application Object
;				   $s_property	- Property selection
;				   $v_newvalue	- The new value to be set into the Word Application Property
; Return values .: On Success	- Returns 1
;                  On Failure	- Returns 0 and sets @ERROR
;					@ERROR		- 0 ($_WordStatus_Success) = No Error
;								- 3 ($_WordStatus_InvalidDataType) = Invalid Data Type
;								- 4 ($_WordStatus_InvalidObjectType) = Invalid Object Type
;								- 5 ($_WordStatus_InvalidValue) = Invalid Value
;					@Extended	- Contains invalid parameter number
; Author ........: Bob Anthony
; ===============================================================================================================================
Func _WordPropertySet(ByRef $o_object, $s_Property, $v_newvalue)
	If Not IsObj($o_object) Then
		__WordErrorNotify("Error", "_WordPropertySet", "$_WordStatus_InvalidDataType")
		Return SetError($_WordStatus_InvalidDataType, 1, 0)
	EndIf
	;
	If Not __WordIsObjType($o_object, "wordobj") Then
		__WordErrorNotify("Error", "_WordPropertySet", "$_WordStatus_InvalidObjectType")
		Return SetError($_WordStatus_InvalidObjectType, 1, 0)
	EndIf

	$s_Property = StringLower($s_Property)
	Switch $s_Property
		Case "activeprinter"
			$o_object.Application.ActivePrinter = $v_newvalue
			Return SetError($_WordStatus_Success, 0, 1)
		Case "screentips"
			If __WordIsObjType($o_object, "window") Then
				$o_object.DisplayScreenTips = $v_newvalue
				Return SetError($_WordStatus_Success, 0, 1)
			Else
				$o_object.Application.DisplayScreenTips = $v_newvalue
				Return SetError($_WordStatus_Success, 0, 1)
			EndIf
		Case "scrollbars"
			$o_object.Application.DisplayScrollBars = $v_newvalue
		Case "statusbar"
			$o_object.Application.DisplayStatusBar = $v_newvalue
		Case "height"
			If __WordIsObjType($o_object, "window") Then
				$o_object.Height = $v_newvalue
			Else
				$o_object.Application.Height = $v_newvalue
			EndIf
		Case "left"
			If __WordIsObjType($o_object, "window") Then
				$o_object.Left = $v_newvalue
			Else
				$o_object.Application.Left = $v_newvalue
			EndIf
		Case "screenupdating"
			$o_object.Application.ScreenUpdating = $v_newvalue
		Case "startuppath"
			$o_object.AApplication.StartupPath = $v_newvalue
		Case "top"
			If __WordIsObjType($o_object, "window") Then
				$o_object.Top = $v_newvalue
			Else
				$o_object.Application.Top = $v_newvalue
			EndIf
		Case "visible"
			If __WordIsObjType($o_object, "window") Then
				$o_object.Visible = $v_newvalue
			Else
				$o_object.Application.Visible = $v_newvalue
			EndIf
		Case "width"
			If __WordIsObjType($o_object, "window") Then
				$o_object.Width = $v_newvalue
			Else
				$o_object.Application.Width = $v_newvalue
			EndIf
		Case "windowstate"
			If __WordIsObjType($o_object, "window") Then
				$o_object.WindowState = $v_newvalue
			Else
				$o_object.Application.WindowState = $v_newvalue
			EndIf
		Case Else
			; Unsupported Property
			__WordErrorNotify("Error", "_WordPropertySet", "$_WordStatus_InvalidValue", "Invalid Property")
			Return SetError($_WordStatus_InvalidValue, 2, 0)
	EndSwitch
	Return SetError($_WordStatus_Success, 0, 1)
EndFunc   ;==>_WordPropertySet

; #FUNCTION# ====================================================================================================================
; Name...........: _Word_VersionInfo
; Description ...: Returns an array of information about the Word.au3 version
; Parameters ....: None
; Return values .: On Success 	- Returns an array ($WordAU3VersionInfo)
;								- $WordAU3VersionInfo[0] = Release Type (T=Test or V=Production)
;								- $WordAU3VersionInfo[1] = Major Version
;								- $WordAU3VersionInfo[2] = Minor Version
;								- $WordAU3VersionInfo[3] = Sub Version
;								- $WordAU3VersionInfo[4] = Release Date (YYYYMMDD)
;								- $WordAU3VersionInfo[5] = Display Version (e.g. T0.1-0)
;                  On Failure	- None
; Author ........: Bob Anthony
; ===============================================================================================================================
Func _Word_VersionInfo()
	__WordErrorNotify("Information", "_Word_VersionInfo", "version " & _
			$WordAU3VersionInfo[0] & _
			$WordAU3VersionInfo[1] & "." & _
			$WordAU3VersionInfo[2] & "-" & _
			$WordAU3VersionInfo[3], "Release date: " & $WordAU3VersionInfo[4])
	Return SetError($_WordStatus_Success, 0, $WordAU3VersionInfo)
EndFunc   ;==>_Word_VersionInfo

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __WordGetHWND
; Description ...: Returns the hwnd of a word object
; Parameters ....: None
; Return values .: On Success 	- Returns 1
;                  On Failure	- None
; Author(s):        Bob Anthony
; ===============================================================================================================================
Func __WordGetHWND(ByRef $o_object)
	If Not IsObj($o_object) Then
		Return SetError($_WordStatus_InvalidDataType, 1, 0)
	EndIf

	If Not __WordIsObjType($o_object, "window") Then
		Return SetError($_WordStatus_InvalidObjectType, 1, 0)
	EndIf

	; Setup internal error handler to Trap COM errors, turn off error notification
	Local $status = __WordInternalErrorHandlerRegister()
	If Not $status Then __WordErrorNotify("Warning", "internal function __WordGetHWND", _
			"Cannot register internal error handler, cannot trap COM errors", _
			"Use _WordErrorHandlerRegister() to register a user error handler")
	Local $f_NotifyStatus = _WordErrorNotify() ; save current error notify status
	_WordErrorNotify(False)
	;
	Local $s_Title = ($o_object.Caption & " - " & $o_object.Application.Caption)
	If Not $oWordErrorHandler.number = 0 Then Return SetError($_WordStatus_ComError, 0, 0)

	; restore error notify and error handler status
	_WordErrorNotify($f_NotifyStatus) ; restore notification status
	__WordInternalErrorHandlerDeRegister()

	Local $h_hwnd = WinGetHandle($s_Title)
	If @error Then Return SetError($_WordStatus_GeneralError, 0, 0)

	Return SetError($_WordStatus_Success, 0, $h_hwnd)
EndFunc   ;==>__WordGetHWND

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __WordErrorNotify
; Description ...:
; Parameters ....:
; Return values .:
; Author ........: Bob Anthony
; Modified.......:
; Remarks .......:
; ===============================================================================================================================
Func __WordErrorNotify($s_severity, $s_func, $s_status = "", $s_message = "")
	If $_WordErrorNotify Or $__WordAU3Debug Then
		Local $sStr = "--> Word.au3 " & $s_severity & " from function " & $s_func
		If Not $s_status = "" Then $sStr &= ", " & $s_status
		If Not $s_message = "" Then $sStr &= " (" & $s_message & ")"
		ConsoleWrite($sStr & @CRLF)
	EndIf
	Return 1
EndFunc   ;==>__WordErrorNotify

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __WordInternalErrorHandlerRegister
; Description ...: Register and enable the internal Word COM error handler
; Parameters ....: None
; Return values .: Success  - 1
;                  Failure  - 0
; Author ........: Bob Anthony
; Modified.......:
; Remarks .......:
; ===============================================================================================================================
Func __WordInternalErrorHandlerRegister()
	Local $sCurrentErrorHandler = ObjEvent("AutoIt.Error")
	If $sCurrentErrorHandler <> "" And Not IsObj($oWordErrorHandler) Then
		; We've got trouble... User COM Error handler assigned without using _WordErrorHandlerRegister
		Return SetError($_WordStatus_GeneralError, 0, 0)
	EndIf
	$oWordErrorHandler = ""
	$oWordErrorHandler = ObjEvent("AutoIt.Error", "__WordInternalErrorHandler")
	If IsObj($oWordErrorHandler) Then Return SetError($_WordStatus_Success, 0, 1)
	Return SetError($_WordStatus_GeneralError, 0, 0)
EndFunc   ;==>__WordInternalErrorHandlerRegister

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __WordInternalErrorHandlerDeRegister
; Description ...: DeRegister the internal Word COM error handler and register User Word COM error handler if defined
; Parameters ....: None
; Return values .: 1
; Author ........: Bob Anthony
; Modified.......:
; Remarks .......:
; ===============================================================================================================================
Func __WordInternalErrorHandlerDeRegister()
	$oWordErrorHandler = ""
	If $sWordUserErrorHandler <> "" Then
		$oWordErrorHandler = ObjEvent("AutoIt.Error", $sWordUserErrorHandler)
	EndIf
	Return SetError($_WordStatus_Success, 0, 1)
EndFunc   ;==>__WordInternalErrorHandlerDeRegister

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __WordInternalErrorHandler
; Description ...: Update $WordComError... global variables
; Parameters ....: None
; Return values .: @error = $_WordStatus_ComError
; Author ........: Bob Anthony
; Modified.......:
; Remarks .......:
; ===============================================================================================================================
Func __WordInternalErrorHandler()
	$WordComErrorScriptline = $oWordErrorHandler.scriptline
	$WordComErrorNumber = $oWordErrorHandler.number
	$WordComErrorNumberHex = Hex($oWordErrorHandler.number, 8)
	$WordComErrorDescription = StringStripWS($oWordErrorHandler.description, 2)
	$WordComErrorWinDescription = StringStripWS($oWordErrorHandler.WinDescription, 2)
	$WordComErrorSource = $oWordErrorHandler.Source
	$WordComErrorHelpFile = $oWordErrorHandler.HelpFile
	$WordComErrorHelpContext = $oWordErrorHandler.HelpContext
	$WordComErrorLastDllError = $oWordErrorHandler.LastDllError
	$WordComErrorOutput = ""
	$WordComErrorOutput &= "--> COM Error Encountered in " & @ScriptName & @CRLF
	$WordComErrorOutput &= "----> $WordComErrorScriptline = " & $WordComErrorScriptline & @CRLF
	$WordComErrorOutput &= "----> $WordComErrorNumberHex = " & $WordComErrorNumberHex & @CRLF
	$WordComErrorOutput &= "----> $WordComErrorNumber = " & $WordComErrorNumber & @CRLF
	$WordComErrorOutput &= "----> $WordComErrorWinDescription = " & $WordComErrorWinDescription & @CRLF
	$WordComErrorOutput &= "----> $WordComErrorDescription = " & $WordComErrorDescription & @CR
	$WordComErrorOutput &= "----> $WordComErrorSource = " & $WordComErrorSource & @CRLF
	$WordComErrorOutput &= "----> $WordComErrorHelpFile = " & $WordComErrorHelpFile & @CRLF
	$WordComErrorOutput &= "----> $WordComErrorHelpContext = " & $WordComErrorHelpContext & @CRLF
	$WordComErrorOutput &= "----> $WordComErrorLastDllError = " & $WordComErrorLastDllError & @CRLF
	If $_WordErrorNotify Or $__WordAU3Debug Then ConsoleWrite($WordComErrorOutput & @CRLF)
	Return SetError($_WordStatus_ComError)
EndFunc   ;==>__WordInternalErrorHandler

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __WordLockSetForegroundWindow()
; Description ...: Locks (and Unlocks) current Foreground Window focus to prevent a new window
;				   from stealing it (e.g. when creating invisible window)
; Parameters ....: $nLockCode	- 1 Lock Foreground Window Focus, 2 Unlock Foreground Window Focus
; Return values .: On Success 	- 1
;                  On Failure 	- 0  and sets @ERROR and @EXTENDED to non-zero values
; Author ........:  Valik
; ===============================================================================================================================
Func __WordLockSetForegroundWindow($nLockCode)
	Local $aRet = DllCall("user32.dll", "int", "LockSetForegroundWindow", "int", $nLockCode)
	If @error Then Return SetError(@error, @extended, False)
	Return $aRet[0]
EndFunc   ;==>__WordLockSetForegroundWindow

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __WordIsObjType()
; Description ...: Check to see if an object variable is of a specific type
; Author ........: Bob Anthony
; ===============================================================================================================================
Func __WordIsObjType(ByRef $o_object, $s_type)
	If Not IsObj($o_object) Then Return SetError($_WordStatus_InvalidDataType, 1, 0)

	; Setup internal error handler to Trap COM errors, turn off error notification
	Local $status = __WordInternalErrorHandlerRegister()
	If Not $status Then __WordErrorNotify("Warning", "internal function __WordIsObjType", _
			"Cannot register internal error handler, cannot trap COM errors", _
			"Use _WordErrorHandlerRegister() to register a user error handler")
	Local $f_NotifyStatus = _WordErrorNotify() ; save current error notify status
	_WordErrorNotify(False)
	;
	Local $s_Name = ObjName($o_object), $objectOK = False

	Switch $s_type
		Case "wordobj"
			If __WordIsObjType($o_object, "application") Then
				$objectOK = True
			ElseIf __WordIsObjType($o_object, "window") Then
				$objectOK = True
			ElseIf __WordIsObjType($o_object, "document") Then
				$objectOK = True
			EndIf
		Case "application"
			If $s_Name = "Application" Then $objectOK = True
		Case "document"
			If $s_Name = "Document" Then $objectOK = True
		Case "documents"
			If $s_Name = "Documents" Then $objectOK = True
		Case "range"
			If $s_Name = "Range" Then $objectOK = True
		Case "window"
			If $s_Name = "Window" Then $objectOK = True
		Case "windows"
			If $s_Name = "Windows" Then $objectOK = True
		Case Else
			; Unsupported ObjType specified
			Return SetError($_WordStatus_InvalidValue, 2, 0)
	EndSwitch

	; restore error notify and error handler status
	_WordErrorNotify($f_NotifyStatus) ; restore notification status
	__WordInternalErrorHandlerDeRegister()

	If $objectOK Then
		Return SetError($_WordStatus_Success, 0, 1)
	Else
		Return SetError($_WordStatus_InvalidObjectType, 1, 0)
	EndIf

EndFunc   ;==>__WordIsObjType
