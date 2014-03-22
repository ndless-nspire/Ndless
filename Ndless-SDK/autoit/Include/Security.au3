#include-once

#include "SecurityConstants.au3"
#include "StructureConstants.au3"
#include "WinAPIError.au3"
#include "WinAPI.au3"

; #INDEX# =======================================================================================================================
; Title .........: Security
; AutoIt Version : 3.3.7.20++
; Description ...: Functions that assist with Security management.
; Author(s) .....: Paul Campbell (PaulIA), trancexx
; Dll(s) ........: advapi32.dll
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_Security__AdjustTokenPrivileges
;_Security__CreateProcessWithToken
;_Security__DuplicateTokenEx
;_Security__GetAccountSid
;_Security__GetLengthSid
;_Security__GetTokenInformation
;_Security__ImpersonateSelf
;_Security__IsValidSid
;_Security__LookupAccountName
;_Security__LookupAccountSid
;_Security__LookupPrivilegeValue
;_Security__OpenProcessToken
;_Security__OpenThreadToken
;_Security__OpenThreadTokenEx
;_Security__SetPrivilege
;_Security__SetTokenInformation
;_Security__SidToStringSid
;_Security__SidTypeStr
;_Security__StringSidToSid
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _Security__AdjustTokenPrivileges
; Description ...: Enables or disables privileges in the specified access token
; Syntax.........: _Security__AdjustTokenPrivileges($hToken, $fDisableAll, $pNewState, $iBufferLen[, $pPrevState = 0[, $pRequired = 0]])
; Parameters ....: $hToken      - Handle to the access token that contains privileges to be modified
;                  $fDisableAll - If True, the function disables all privileges and ignores the NewState parameter. If False, the
;                  +function modifies privileges based on the information pointed to by the $pNewState parameter.
;                  $pNewState   - Pointer to a $tagTOKEN_PRIVILEGES structure that contains the privilege and it's attributes
;                  $iBufferLen  - Size, in bytes, of the buffer pointed to by $pNewState
;                  $pPrevState  - Pointer to a $tagTOKEN_PRIVILEGES structure that specifies the previous state of  the  privilege
;                  +that the function modified. This can be 0
;                  $pRequired   - Pointer to a variable that receives the required size, in bytes, of the buffer  pointed  to  by
;                  +$pPrevState. This parameter can be 0 if $pPrevState is 0.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: trancexx
; Remarks .......: This function cannot add new privileges to an access token. It can only enable or disable the token's existing
;                  privileges.
; Related .......: $tagTOKEN_PRIVILEGES
; Link ..........: @@MsdnLink@@ AdjustTokenPrivileges
; Example .......: Yes
; ===============================================================================================================================
Func _Security__AdjustTokenPrivileges($hToken, $fDisableAll, $pNewState, $iBufferLen, $pPrevState = 0, $pRequired = 0)
	Local $aCall = DllCall("advapi32.dll", "bool", "AdjustTokenPrivileges", "handle", $hToken, "bool", $fDisableAll, "struct*", $pNewState, "dword", $iBufferLen, "struct*", $pPrevState, "struct*", $pRequired)
	If @error Then Return SetError(1, @extended, False)

	Return Not ($aCall[0] = 0)
EndFunc   ;==>_Security__AdjustTokenPrivileges

; #FUNCTION# ====================================================================================================================
; Name...........: _Security__CreateProcessWithToken
; Description ...: Creates a new process and its primary thread running in the security context of the specified token.
; Syntax.........: _Security__CreateProcessWithToken($hToken, $iLogonFlags, $sCommandLine, $iCreationFlags, $sCurDir, $tSTARTUPINFO, $tPROCESS_INFORMATION)
; Parameters ....: $hToken               - A handle to the primary token that represents a user.
;                  $iLogonFlags          - The logon option.
;                  $sCommandLine         - The command line to be executed.
;                  $iCreationFlags       - The flags that control how the process is created.
;                  $sCurDir              - The full path to the current directory for the process.
;                  $tSTARTUPINFO         - A (pointer to a) STARTUPINFO structure.
;                  $tPROCESS_INFORMATION - A (pointer to a) PROCESS_INFORMATION structure that receives identification information for the new process.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: trancexx
; Modified.......:
; Remarks .......: The module name must be the first white space–delimited token in the $sCommandLine parameter.
; Related .......: _Security__DuplicateTokenEx
; Link ..........: @@MsdnLink@@ CreateProcessWithToken
; Example .......: Yes
; ===============================================================================================================================
Func _Security__CreateProcessWithToken($hToken, $iLogonFlags, $sCommandLine, $iCreationFlags, $sCurDir, $tSTARTUPINFO, $tPROCESS_INFORMATION)
	Local $aCall = DllCall("advapi32.dll", "bool", "CreateProcessWithTokenW", "handle", $hToken, "dword", $iLogonFlags, "ptr", 0, "wstr", $sCommandLine, "dword", $iCreationFlags, "struct*", 0, "wstr", $sCurDir, "struct*", $tSTARTUPINFO, "struct*", $tPROCESS_INFORMATION)
	If @error Or Not $aCall[0] Then Return SetError(1, @extended, False)

	Return True
EndFunc   ;==>_Security__CreateProcessWithToken

; #FUNCTION# ====================================================================================================================
; Name...........: _Security__DuplicateTokenEx
; Description ...: Creates a new access token that duplicates an existing token.
; Syntax.........: _Security__DuplicateTokenEx($hExistingToken, $iDesiredAccess, $iImpersonationLevel, $iTokenType)
; Parameters ....: $hExistingToken      - A handle to an access token opened with TOKEN_DUPLICATE access.
;                : $iDesiredAccess      - The requested access rights for the new token.
;                : $iImpersonationLevel - The impersonation level of the new token.
;                : $iTokenType          - The type of new token.
; Return values .: Success      - Returns handle that receives the new token.
;                  Failure      - 0
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......: _Security__OpenProcessToken, _Security__OpenThreadToken, _Security__OpenThreadTokenEx
; Link ..........: @@MsdnLink@@ DuplicateTokenEx
; Example .......: Yes
; ===============================================================================================================================
Func _Security__DuplicateTokenEx($hExistingToken, $iDesiredAccess, $iImpersonationLevel, $iTokenType)
	Local $aCall = DllCall("advapi32.dll", "bool", "DuplicateTokenEx", "handle", $hExistingToken, "dword", $iDesiredAccess, "struct*", 0, "int", $iImpersonationLevel, "int", $iTokenType, "handle*", 0)
	If @error Or Not $aCall[0] Then Return SetError(1, @extended, 0)

	Return $aCall[6]
EndFunc   ;==>_Security__DuplicateTokenEx

; #FUNCTION# ====================================================================================================================
; Name...........: _Security__GetAccountSid
; Description ...: Retrieves the security identifier (SID) for an account
; Syntax.........: _Security__GetAccountSid($sAccount[, $sSystem = ""])
; Parameters ....: $sAccount    - Specifies the account name. Use a fully qualified string in the domain_name\user_name format to
;                  +ensure that the function finds the account in the desired domain.
;                  $sSystem     - Name of the system. This string can be the name of a remote computer. If this string is  blank,
;                  +the account name translation begins on the local system.  If the name cannot be resolved on the local system,
;                  +this function will try to resolve the name using domain controllers trusted by the local system.
; Return values .: Success      - Returns a binary SID in a byte strucutre
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _Security__LookupAccountSid
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Security__GetAccountSid($sAccount, $sSystem = "")
	Local $aAcct = _Security__LookupAccountName($sAccount, $sSystem)
	If @error Then Return SetError(@error, @extended, 0)

	If IsArray($aAcct) Then Return _Security__StringSidToSid($aAcct[0])
	Return ''
EndFunc   ;==>_Security__GetAccountSid

; #FUNCTION# ====================================================================================================================
; Name...........: _Security__GetLengthSid
; Description ...: Returns the length, in bytes, of a valid SID
; Syntax.........: _Security__GetLengthSid($pSID)
; Parameters ....: $pSID        - Pointer to a SID
; Return values .: Success      - Length of SID
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: trancexx
; Remarks .......:
; Related .......: _Security__IsValidSid
; Link ..........: @@MsdnLink@@ GetLengthSid
; Example .......: Yes
; ===============================================================================================================================
Func _Security__GetLengthSid($pSID)
	If Not _Security__IsValidSid($pSID) Then Return SetError(1, @extended, 0)

	Local $aCall = DllCall("advapi32.dll", "dword", "GetLengthSid", "struct*", $pSID)
	If @error Then Return SetError(2, @extended, 0)

	Return $aCall[0]
EndFunc   ;==>_Security__GetLengthSid

; #FUNCTION# ====================================================================================================================
; Name...........: _Security__GetTokenInformation
; Description ...: Retrieves a specified type of information about an access token
; Syntax.........: _Security__GetTokenInformation($hToken, $iClass)
; Parameters ....: $hToken      - A handle to an  access  token  from  which  information  is  retrieved.  If  $iClass  specifies
;                  +$sTokenSource, the handle must have $TOKEN_QUERY_SOURCE access. For all other $iClass values, the handle must
;                  +have $TOKEN_QUERY access.
;                  $iClass      - Specifies a value to identify the type of information the function retrieves
; Return values .: Success      - A byte structure filled with the requested information
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: trancexx
; Remarks .......:
; Related .......: _Security__OpenProcessToken, _Security__OpenThreadToken, _Security__OpenThreadTokenEx
; Link ..........: @@MsdnLink@@ GetTokenInformation
; Example .......: Yes
; ===============================================================================================================================
Func _Security__GetTokenInformation($hToken, $iClass)
	Local $aCall = DllCall("advapi32.dll", "bool", "GetTokenInformation", "handle", $hToken, "int", $iClass, "struct*", 0, "dword", 0, "dword*", 0)
	If @error Or Not $aCall[5] Then Return SetError(1, @extended, 0)
	Local $iLen = $aCall[5]

	Local $tBuffer = DllStructCreate("byte[" & $iLen & "]")
	$aCall = DllCall("advapi32.dll", "bool", "GetTokenInformation", "handle", $hToken, "int", $iClass, "struct*", $tBuffer, "dword", DllStructGetSize($tBuffer), "dword*", 0)
	If @error Or Not $aCall[0] Then Return SetError(2, @extended, 0)

	Return $tBuffer
EndFunc   ;==>_Security__GetTokenInformation

; #FUNCTION# ====================================================================================================================
; Name...........: _Security__ImpersonateSelf
; Description ...: Obtains an access token that impersonates the calling process security context
; Syntax.........: _Security__ImpersonateSelf([$iLevel = $SECURITYIMPERSONATION])
; Parameters ....: $iLevel      - Impersonation level of the new token:
;                  |$SECURITYANONYMOUS - The server process cannot obtain identification information about the client, and  it  cannot
;                  +impersonate the client.
;                  |$SECURITYIDENTIFICATION - The server process can obtain information about the client, such as security identifiers
;                  +and privileges, but it cannot impersonate the client.
;                  |$SECURITYIMPERSONATION - The server process can impersonate the clients security context on its local  system.  The
;                  +server cannot impersonate the client on remote systems.
;                  |$SECURITYDELEGATION - The server process can impersonate the client's security context on remote systems.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: trancexx
; Remarks .......: The token is assigned to the calling thread.
; Related .......: _Security__OpenThreadTokenEx
; Link ..........: @@MsdnLink@@ ImpersonateSelf
; Example .......: Yes
; ===============================================================================================================================
Func _Security__ImpersonateSelf($iLevel = $SECURITYIMPERSONATION)
	Local $aCall = DllCall("advapi32.dll", "bool", "ImpersonateSelf", "int", $iLevel)
	If @error Then Return SetError(1, @extended, False)

	Return Not ($aCall[0] = 0)
EndFunc   ;==>_Security__ImpersonateSelf

; #FUNCTION# ====================================================================================================================
; Name...........: _Security__IsValidSid
; Description ...: Validates a SID
; Syntax.........: _Security__IsValidSid($pSID)
; Parameters ....: $pSID        - Pointer to a SID
; Return values .: True         - SID is valid
;                  False        - SID is not valid
; Author ........: Paul Campbell (PaulIA)
; Modified.......: trancexx
; Remarks .......:
; Related .......: _Security__GetLengthSid
; Link ..........: @@MsdnLink@@ IsValidSid
; Example .......: Yes
; ===============================================================================================================================
Func _Security__IsValidSid($pSID)
	Local $aCall = DllCall("advapi32.dll", "bool", "IsValidSid", "struct*", $pSID)
	If @error Then Return SetError(1, @extended, False)

	Return Not ($aCall[0] = 0)
EndFunc   ;==>_Security__IsValidSid

; #FUNCTION# ====================================================================================================================
; Name...........: _Security__LookupAccountName
; Description ...: Retrieves a security identifier (SID) for the account and the name of the domain
; Syntax.........: _Security__LookupAccountName($sAccount[, $sSystem = ""])
; Parameters ....: $sAccount    - Specifies the account name. Use a fully qualified string in the domain_name\user_name format to
;                  +ensure that the function finds the account in the desired domain.
;                  $sSystem     - Name of the system. This string can be the name of a remote computer.  If this string is blank,
;                  +the account name translation begins on the local system.  If the name cannot be resolved on the local system,
;                  +this function will try to resolve the name using domain controllers trusted by the local system.
; Return values .: Success      - Array with the following format:
;                  |$aAcct[0] - SID String
;                  |$aAcct[1] - Domain name
;                  |$aAcct[2] - SID type
; Author ........: Paul Campbell (PaulIA)
; Modified.......: trancexx
; Remarks .......:
; Related .......: _Security__LookupAccountSid
; Link ..........: @@MsdnLink@@ LookupAccountName
; Example .......: Yes
; ===============================================================================================================================
Func _Security__LookupAccountName($sAccount, $sSystem = "")
	Local $tData = DllStructCreate("byte SID[256]")
	Local $aCall = DllCall("advapi32.dll", "bool", "LookupAccountNameW", "wstr", $sSystem, "wstr", $sAccount, "struct*", $tData, "dword*", DllStructGetSize($tData), "wstr", "", "dword*", DllStructGetSize($tData), "int*", 0)
	If @error Or Not $aCall[0] Then Return SetError(1, @extended, 0)

	Local $aAcct[3]
	$aAcct[0] = _Security__SidToStringSid(DllStructGetPtr($tData, "SID"))
	$aAcct[1] = $aCall[5] ; Domain
	$aAcct[2] = $aCall[7] ; SNU

	Return $aAcct
EndFunc   ;==>_Security__LookupAccountName

; #FUNCTION# ====================================================================================================================
; Name...........: _Security__LookupAccountSid
; Description ...: Retrieves the name of the account for a SID
; Syntax.........: _Security__LookupAccountSid($vSID [, $sSystem = ""])
; Parameters ....: $vSID        - Either a binary SID or a string SID
;                  $sSystem     - Optional, the name of a remote computer. By default the local system.
; Return values .: Success      - Array with the following format:
;                  |$aAcct[0] - Account name
;                  |$aAcct[1] - Domain name
;                  |$aAcct[2] - SID type
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: trancexx
; Remarks .......:
; Related .......: _Security__LookupAccountName, _Security__GetAccountSid
; Link ..........: @@MsdnLink@@ LookupAccountSid
; Example .......: Yes
; ===============================================================================================================================
Func _Security__LookupAccountSid($vSID, $sSystem = "")
	Local $pSID, $aAcct[3]

	If IsString($vSID) Then
		$pSID = _Security__StringSidToSid($vSID)
	Else
		$pSID = $vSID
	EndIf
	If Not _Security__IsValidSid($pSID) Then Return SetError(1, @extended, 0)

	Local $typeSystem = "ptr"
	If $sSystem Then $typeSystem = "wstr" ; remote system is requested

	Local $aCall = DllCall("advapi32.dll", "bool", "LookupAccountSidW", $typeSystem, $sSystem, "struct*", $pSID, "wstr", "", "dword*", 65536, "wstr", "", "dword*", 65536, "int*", 0)
	If @error Or Not $aCall[0] Then Return SetError(2, @extended, 0)

	Local $aAcct[3]
	$aAcct[0] = $aCall[3] ; Name
	$aAcct[1] = $aCall[5] ; Domain
	$aAcct[2] = $aCall[7] ; SNU

	Return $aAcct
EndFunc   ;==>_Security__LookupAccountSid

; #FUNCTION# ====================================================================================================================
; Name...........: _Security__LookupPrivilegeValue
; Description ...: Retrieves the locally unique identifier (LUID) for a privilege value in form of 64bit integer.
; Syntax.........: _Security__LookupPrivilegeValue($sSystem, $sName)
; Parameters ....: $sSystem     - Specifies the name of the system on which the  privilege  name  is  retrieved.  If  blank,  the
;                  +function attempts to find the privilege name on the local system.
;                  $sName       - Specifies the name of the privilege
; Return values .: Success      - LUID by which the privilege is known
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: trancexx
; Remarks .......:
; Related .......: _Security__SetPrivilege
; Link ..........: @@MsdnLink@@ LookupPrivilegeValue
; Example .......: Yes
; ===============================================================================================================================
Func _Security__LookupPrivilegeValue($sSystem, $sName)
	Local $aCall = DllCall("advapi32.dll", "bool", "LookupPrivilegeValueW", "wstr", $sSystem, "wstr", $sName, "int64*", 0)
	If @error Or Not $aCall[0] Then Return SetError(1, @extended, 0)

	Return $aCall[3] ; LUID
EndFunc   ;==>_Security__LookupPrivilegeValue

; #FUNCTION# ====================================================================================================================
; Name...........: _Security__OpenProcessToken
; Description ...: Returns the access token associated with a process
; Syntax.........: _Security__OpenProcessToken($hProcess, $iAccess)
; Parameters ....: $hProcess    - A handle to the process whose access token is opened. The process must  have  been  given  the
;                  +$PROCESS_QUERY_INFORMATION access permission.
;                  $iAccess     - Specifies an access mask that specifies the requested types of access to the access token.
; Return values .: Success      - An handle that identifies the newly opened access token when the function returns.
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: trancexx
; Remarks .......: Close the access token handle returned by calling _WinAPI_CloseHandle
; Related .......: _Security__OpenThreadToken
; Link ..........: @@MsdnLink@@ OpenProcessToken
; Example .......: Yes
; ===============================================================================================================================
Func _Security__OpenProcessToken($hProcess, $iAccess)
	Local $aCall = DllCall("advapi32.dll", "bool", "OpenProcessToken", "handle", $hProcess, "dword", $iAccess, "handle*", 0)
	If @error Or Not $aCall[0] Then Return SetError(1, @extended, 0)

	Return $aCall[3]
EndFunc   ;==>_Security__OpenProcessToken

; #FUNCTION# ====================================================================================================================
; Name...........: _Security__OpenThreadToken
; Description ...: Opens the access token associated with a thread
; Syntax.........: _Security__OpenThreadToken($iAccess[, $hThread = 0[, $fOpenAsSelf = False]])
; Parameters ....: $iAccess     - Access mask that specifies the requested types of access to the access token.  These  requested
;                  +access types are reconciled against the token's discretionary access control list (DACL) to  determine  which
;                  +accesses are granted or denied.
;                  $hThread     - Handle to the thread whose access token is opened
;                  $fOpenAsSelf - Indicates whether the access check is to be made against the security  context  of  the  thread
;                  +calling the OpenThreadToken function or against the security context of the process for the  calling  thread.
;                  +If this parameter is False, the access check is performed using the security context for the calling  thread.
;                  +If the thread is impersonating a client, this security context can be that  of  a  client  process.  If  this
;                  +parameter is True, the access check is made using the security context of the process for the calling thread.
; Return values .: Success      - Handle to the newly opened access token
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: trancexx
; Remarks .......: OpenThreadToken will fail if not impersonating.
; Related .......: _Security__OpenThreadTokenEx, _Security__OpenProcessToken
; Link ..........: @@MsdnLink@@ OpenThreadToken
; Example .......: Yes
; ===============================================================================================================================
Func _Security__OpenThreadToken($iAccess, $hThread = 0, $fOpenAsSelf = False)
	If $hThread = 0 Then $hThread = _WinAPI_GetCurrentThread()
	If @error Then Return SetError(1, @extended, 0)

	Local $aCall = DllCall("advapi32.dll", "bool", "OpenThreadToken", "handle", $hThread, "dword", $iAccess, "bool", $fOpenAsSelf, "handle*", 0)
	If @error Or Not $aCall[0] Then Return SetError(2, @extended, 0)

	Return $aCall[4] ; Token
EndFunc   ;==>_Security__OpenThreadToken

; #FUNCTION# ====================================================================================================================
; Name...........: _Security__OpenThreadTokenEx
; Description ...: Opens the access token associated with a thread, impersonating the client's security context if required
; Syntax.........: _Security__OpenThreadTokenEx($iAccess[, $hThread = 0[, $fOpenAsSelf = False]])
; Parameters ....: $iAccess     - Access mask that specifies the requested types of access to the access token.  These  requested
;                  +access types are reconciled against the token's discretionary access control list (DACL) to  determine  which
;                  +accesses are granted or denied.
;                  $hThread     - Handle to the thread whose access token is opened
;                  $fOpenAsSelf - Indicates whether the access check is to be made against the security  context  of  the  thread
;                  +calling the OpenThreadToken function or against the security context of the process for the  calling  thread.
;                  +If this parameter is False, the access check is performed using the security context for the calling  thread.
;                  +If the thread is impersonating a client, this security context can be that  of  a  client  process.  If  this
;                  +parameter is True, the access check is made using the security context of the process for the calling thread.
; Return values .: Success      - Handle to the newly opened access token
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: trancexx
; Remarks .......:
; Related .......: _Security__OpenThreadToken, _Security__ImpersonateSelf
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Security__OpenThreadTokenEx($iAccess, $hThread = 0, $fOpenAsSelf = False)
	Local $hToken = _Security__OpenThreadToken($iAccess, $hThread, $fOpenAsSelf)
	If $hToken = 0 Then
		If _WinAPI_GetLastError() <> $ERROR_NO_TOKEN Then Return SetError(3, _WinAPI_GetLastError(), 0)
		If Not _Security__ImpersonateSelf() Then Return SetError(1, _WinAPI_GetLastError(), 0)
		$hToken = _Security__OpenThreadToken($iAccess, $hThread, $fOpenAsSelf)
		If $hToken = 0 Then Return SetError(2, _WinAPI_GetLastError(), 0)
	EndIf

	Return $hToken
EndFunc   ;==>_Security__OpenThreadTokenEx

; #FUNCTION# ====================================================================================================================
; Name...........: _Security__SetPrivilege
; Description ...: Enables or disables a local token privilege
; Syntax.........: _Security__SetPrivilege($hToken, $sPrivilege, $fEnable)
; Parameters ....: $hToken      - Handle to a token
;                  $sPrivilege  - Privilege name
;                  $fEnable     - Privilege setting:
;                  | True - Enable privilege
;                  |False - Disable privilege
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: trancexx
; Remarks .......:
; Related .......:
; Link ..........: _Security__AdjustTokenPrivileges
; Example .......: Yes
; ===============================================================================================================================
Func _Security__SetPrivilege($hToken, $sPrivilege, $fEnable)
	Local $iLUID = _Security__LookupPrivilegeValue("", $sPrivilege)
	If $iLUID = 0 Then Return SetError(1, @extended, False)

	Local $tCurrState = DllStructCreate($tagTOKEN_PRIVILEGES)
	Local $iCurrState = DllStructGetSize($tCurrState)
	Local $tPrevState = DllStructCreate($tagTOKEN_PRIVILEGES)
	Local $iPrevState = DllStructGetSize($tPrevState)
	Local $tRequired = DllStructCreate("int Data")
	; Get current privilege setting
	DllStructSetData($tCurrState, "Count", 1)
	DllStructSetData($tCurrState, "LUID", $iLUID)
	If Not _Security__AdjustTokenPrivileges($hToken, False, $tCurrState, $iCurrState, $tPrevState, $tRequired) Then Return SetError(2, @error, False)

	; Set privilege based on prior setting
	DllStructSetData($tPrevState, "Count", 1)
	DllStructSetData($tPrevState, "LUID", $iLUID)
	Local $iAttributes = DllStructGetData($tPrevState, "Attributes")
	If $fEnable Then
		$iAttributes = BitOR($iAttributes, $SE_PRIVILEGE_ENABLED)
	Else
		$iAttributes = BitAND($iAttributes, BitNOT($SE_PRIVILEGE_ENABLED))
	EndIf
	DllStructSetData($tPrevState, "Attributes", $iAttributes)

	If Not _Security__AdjustTokenPrivileges($hToken, False, $tPrevState, $iPrevState, $tCurrState, $tRequired) Then _
			Return SetError(3, @error, False)

	Return True
EndFunc   ;==>_Security__SetPrivilege

; #FUNCTION# ====================================================================================================================
; Name...........: _Security__SetTokenInformation
; Description ...: Sets various types of information for a specified access token.
; Syntax.........: _Security__SetTokenInformation($hToken, $iTokenInformation, $vTokenInformation, $iTokenInformationLength)
; Parameters ....: $hToken                  - A handle to the access token for which information is to be set.
;                : $iTokenInformation       - The type of information the function sets.
;                : $vTokenInformation       - A (pointer to a) structure that contains the information set in the access token.
;                : $iTokenInformationLength - The length, in bytes, of the buffer pointed to by $vTokenInformation
; Return values .: Success      - True
;                  Failure      - False
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......: _Security__GetTokenInformation
; Link ..........: @@MsdnLink@@ SetTokenInformation
; Example .......: Yes
; ===============================================================================================================================
Func _Security__SetTokenInformation($hToken, $iTokenInformation, $vTokenInformation, $iTokenInformationLength)
	Local $aCall = DllCall("advapi32.dll", "bool", "SetTokenInformation", "handle", $hToken, "int", $iTokenInformation, "struct*", $vTokenInformation, "dword", $iTokenInformationLength)
	If @error Or Not $aCall[0] Then Return SetError(1, @extended, False)

	Return True
EndFunc   ;==>_Security__SetTokenInformation

; #FUNCTION# ====================================================================================================================
; Name...........: _Security__SidToStringSid
; Description ...: Converts a binary SID to a string
; Syntax.........: _Security__SidToStringSid($pSID)
; Parameters ....: $pSID        - Pointer to a binary SID to be converted
; Return values .: Success      - SID in string form
;                  Failure      - Empty string
; Author ........: Paul Campbell (PaulIA)
; Modified.......: trancexx
; Remarks .......:
; Related .......: _Security__StringSidToSid
; Link ..........: @@MsdnLink@@ ConvertSidToStringSid
; Example .......: Yes
; ===============================================================================================================================
Func _Security__SidToStringSid($pSID)
	If Not _Security__IsValidSid($pSID) Then Return SetError(1, 0, "")

	Local $aCall = DllCall("advapi32.dll", "bool", "ConvertSidToStringSidW", "struct*", $pSID, "ptr*", 0)
	If @error Or Not $aCall[0] Then Return SetError(2, @extended, "")
	Local $pStringSid = $aCall[2]

	Local $sSID = DllStructGetData(DllStructCreate("wchar Text[" & _WinAPI_StringLenW($pStringSid) + 1 & "]", $pStringSid), "Text")
	_WinAPI_LocalFree($pStringSid)

	Return $sSID
EndFunc   ;==>_Security__SidToStringSid

; #FUNCTION# ====================================================================================================================
; Name...........: _Security__SidTypeStr
; Description ...: Converts a Sid type to string form
; Syntax.........: _Security__SidTypeStr($iType)
; Parameters ....: $iType       - Sid type
; Return values .: Success      - Sid type in string form
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Security__SidTypeStr($iType)
	Switch $iType
		Case $SIDTYPEUSER
			Return "User"
		Case $SIDTYPEGROUP
			Return "Group"
		Case $SIDTYPEDOMAIN
			Return "Domain"
		Case $SIDTYPEALIAS
			Return "Alias"
		Case $SIDTYPEWELLKNOWNGROUP
			Return "Well Known Group"
		Case $SIDTYPEDELETEDACCOUNT
			Return "Deleted Account"
		Case $SIDTYPEINVALID
			Return "Invalid"
		Case $SIDTYPEUNKNOWN
			Return "Unknown Type"
		Case $SIDTYPECOMPUTER
			Return "Computer"
		Case $SIDTYPELABEL
			Return "A mandatory integrity label SID"
		Case Else
			Return "Unknown SID Type"
	EndSwitch
EndFunc   ;==>_Security__SidTypeStr

; #FUNCTION# ====================================================================================================================
; Name...........: _Security__StringSidToSid
; Description ...: Converts a String SID to a binary SID
; Syntax.........: _Security__StringSidToSid($sSID)
; Parameters ....: $sSID        - String SID to be converted
; Return values .: Success      - SID in a byte structure
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: trancexx
; Remarks .......:
; Related .......: _Security__SidToStringSid
; Link ..........: @@MsdnLink@@ ConvertStringSidToSid
; Example .......: Yes
; ===============================================================================================================================
Func _Security__StringSidToSid($sSID)
	Local $aCall = DllCall("advapi32.dll", "bool", "ConvertStringSidToSidW", "wstr", $sSID, "ptr*", 0)
	If @error Or Not $aCall[0] Then Return SetError(1, @extended, 0)
	Local $pSID = $aCall[2]

	Local $tBuffer = DllStructCreate("byte Data[" & _Security__GetLengthSid($pSID) & "]", $pSID)
	Local $tSID = DllStructCreate("byte Data[" & DllStructGetSize($tBuffer) & "]")
	DllStructSetData($tSID, "Data", DllStructGetData($tBuffer, "Data"))
	_WinAPI_LocalFree($pSID)

	Return $tSID
EndFunc   ;==>_Security__StringSidToSid
