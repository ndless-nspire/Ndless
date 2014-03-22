#include-once

#include "StructureConstants.au3"

; #INDEX# =======================================================================================================================
; Title .........: Pipes
; AutoIt Version : 3.3.7.20++
; Language ......: English
; Description ...: Functions that assist with Named Pipes.
;                  A named pipe is a named, one-way or duplex pipe for communication between the pipe server and one or more pipe
;                  clients.  All instances of a named pipe share the same pipe name, but each instance has its  own  buffers  and
;                  handles, and provides a separate conduit for  client  server  communication.  The  use  of  instances  enables
;                  multiple pipe clients to use the same named pipe simultaneously.  Any process can access named pipes,  subject
;                  to security checks, making named pipes an easy form of communication between related or  unrelated  processes.
;                  Any process can act as both a server and a client, making peer-to-peer communication possible.  As used  here,
;                  the term pipe server refers to a process that creates a named pipe, and the  term  pipe  client  refers  to  a
;                  process that connects to an instance of a named pipe. Named pipes can be used to provide communication between
;                  processes on the same computer or between processes on different computers across a  network.  If  the  server
;                  service is running, all named pipes are accessible remotely.
; Author(s) .....: Paul Campbell (PaulIA)
; Dll(s) ........: kernel32.dll
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $FILE_FLAG_FIRST_PIPE_INSTANCE = 1
Global Const $FILE_FLAG_OVERLAPPED = 2
Global Const $FILE_FLAG_WRITE_THROUGH = 4

Global Const $__FILE_FLAG_FIRST_PIPE_INSTANCE = 0x00080000
Global Const $__FILE_FLAG_OVERLAPPED = 0x40000000
Global Const $__FILE_FLAG_WRITE_THROUGH = 0x80000000

Global Const $__PIPE_ACCESS_INBOUND = 0x00000001
Global Const $__PIPE_ACCESS_OUTBOUND = 0x00000002
Global Const $__PIPE_ACCESS_DUPLEX = 0x00000003

Global Const $__PIPE_WAIT = 0x00000000
Global Const $__PIPE_NOWAIT = 0x00000001

Global Const $__PIPE_READMODE_BYTE = 0x00000000
Global Const $__PIPE_READMODE_MESSAGE = 0x00000002

Global Const $__PIPE_TYPE_BYTE = 0x00000000
Global Const $__PIPE_TYPE_MESSAGE = 0x00000004

Global Const $__PIPE_CLIENT_END = 0x00000000
Global Const $__PIPE_SERVER_END = 0x00000001

Global Const $__WRITE_DAC = 0x00040000
Global Const $__WRITE_OWNER = 0x00080000
Global Const $__ACCESS_SYSTEM_SECURITY = 0x01000000
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_NamedPipes_CallNamedPipe
;_NamedPipes_ConnectNamedPipe
;_NamedPipes_CreateNamedPipe
;_NamedPipes_CreatePipe
;_NamedPipes_DisconnectNamedPipe
;_NamedPipes_GetNamedPipeHandleState
;_NamedPipes_GetNamedPipeInfo
;_NamedPipes_PeekNamedPipe
;_NamedPipes_SetNamedPipeHandleState
;_NamedPipes_TransactNamedPipe
;_NamedPipes_WaitNamedPipe
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _NamedPipes_CallNamedPipe
; Description ...: Performs a read/write operation on a named pipe
; Syntax.........: _NamedPipes_CallNamedPipe($sPipeName, $pInpBuf, $iInpSize, $pOutBuf, $iOutSize, ByRef $iRead[, $iTimeOut = 0])
; Parameters ....: $sPipeName   - Pipe name
;                  $pInpBuf     - Pointer to the buffer containing the data written to the pipe
;                  $iInpSize    - Size of the write buffer, in bytes
;                  $pOutBuf     - Pointer to the buffer that receives the data read from the pipe
;                  $iOutSize    - Size of the read buffer, in bytes
;                  $iRead       - On return, contains the number of bytes read from the pipe
;                  $iTimeOut    - Number of milliseconds to wait for the named pipe to  be  available.  In  addition  to  numeric
;                  +values, the following special values can be specified:
;                  |-1 - Wait indefinitely
;                  | 0 - Uses the default time-out specified in the call to the CreateNamedPipe
;                  | 1 - Do not wait. If the pipe is not available, return an error
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Calling CallNamedPipe is equivalent to calling the CreateFile (or WaitNamedPipe,  if  CreateFile  cannot  open
;                  the pipe immediately), TransactNamedPipe, and CloseHandle functions.  CreateFile is called with an access flag
;                  of GENERIC_READ | GENERIC_WRITE, and an inherit handle flag of False.  CallNamedPipe fails if the  pipe  is  a
;                  byte-type pipe.
; Related .......: _NamedPipes_WaitNamedPipe, _NamedPipes_TransactNamedPipe
; Link ..........: @@MsdnLink@@ CallNamedPipe
; Example .......:
; ===============================================================================================================================
Func _NamedPipes_CallNamedPipe($sPipeName, $pInpBuf, $iInpSize, $pOutBuf, $iOutSize, ByRef $iRead, $iTimeOut = 0)
	Local $aResult = DllCall("kernel32.dll", "bool", "CallNamedPipeW", "wstr", $sPipeName, "ptr", $pInpBuf, "dword", $iInpSize, "ptr", $pOutBuf, _
			"dword", $iOutSize, "dword*", 0, "dword", $iTimeOut)
	If @error Then Return SetError(@error, @extended, False)
	$iRead = $aResult[6]
	Return $aResult[0]
EndFunc   ;==>_NamedPipes_CallNamedPipe

; #FUNCTION# ====================================================================================================================
; Name...........: _NamedPipes_ConnectNamedPipe
; Description ...: Enables a named pipe server process to wait for a client process to connect
; Syntax.........: _NamedPipes_ConnectNamedPipe($hNamedPipe[, $pOverlapped = 0])
; Parameters ....: $hNamedPipe  - Handle to the server end of a named pipe instance
;                  $pOverlapped - Pointer to a $tagOVERLAPPED structure.  If hNamedPipe  was  opened  with  $FILE_FLAG_OVERLAPPED,
;                  +pOverlapped must not be 0. If hNamedPipe was created with $FILE_FLAG_OVERLAPPED and pOverlapped is not 0, the
;                  +$tagOVERLAPPED structure should contain a handle to a manual reset event object.  If hNamedPipe was not opened
;                  +with $FILE_FLAG_OVERLAPPED, the function does not return until a client is  connected  or  an  error  occurs.
;                  +Successful synchronous operations result in the function returning a nonzero value if a client connects after
;                  +the function is called.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: If a client connects before the function is called, the function returns zero  and  GetLastError  will  return
;                  ERROR_PIPE_CONNECTED. This can happen if a client connects in the interval between the call to CreateNamedPipe
;                  and the call to ConnectNamedPipe. In this situation, there is a good connection between client and server even
;                  though the function returns zero.
; Related .......: _NamedPipes_CreateNamedPipe, $tagOVERLAPPED
; Link ..........: @@MsdnLink@@ ConnectNamedPipe
; Example .......:
; ===============================================================================================================================
Func _NamedPipes_ConnectNamedPipe($hNamedPipe, $pOverlapped = 0)
	Local $aResult = DllCall("kernel32.dll", "bool", "ConnectNamedPipe", "handle", $hNamedPipe, "ptr", $pOverlapped)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_NamedPipes_ConnectNamedPipe

; #FUNCTION# ====================================================================================================================
; Name...........: _NamedPipes_CreateNamedPipe
; Description ...: Creates an instance of a named pipe
; Syntax.........: _NamedPipes_CreateNamedPipe($sName[, $iAccess = 2[, $iFlags = 2[, $iACL = 0[, $iType = 1[, $iRead = 1[, $iWait = 0[, $iMaxInst = 25[, $iOutBufSize = 4096[, $iInpBufSize = 4096[, $iDefTimeout = 5000[, $pSecurity = 0]]]]]]]]]]])
; Parameters ....: $sName       - Pipe name with the following format: \\.\pipe\pipename.  The pipename  part  of  the  name  can
;                  +include any character other than a backslash, including numbers and special characters.  The pipe name string
;                  +can be up to 256 characters long. Pipe names are not case sensitive.
;                  $iAccess     - The pipe access mode. Must be one of the following:
;                  |0 - The flow of data in the pipe goes from client to server only (inbound)
;                  |1 - The flow of data in the pipe goes from server to client only (outbound)
;                  |2 - The pipe is bi-directional (duplex)
;                  $iFlags      - The pipe flags. Can be any combination of the following:
;                  |1 - If you attempt to create multiple instances of a pipe with this flag,  creation  of  the  first  instance
;                  +succeeds, but creation of the next instance fails.
;                  |2 - Overlapped mode is enabled. If this mode  is  enabled  functions  performing  read,  write,  and  connect
;                  +operations that may take a significant time to be completed can return immediately.
;                  |4 - Write-through mode is enabled. This mode affects only write operations on byte type pipes and  only  when
;                  +the client and server are on different computers.
;                  $iACL        - Security ACL flags. Can be any combination of the following:
;                  |1 - The caller will have write access to the named pipe's discretionary ACL
;                  |2 - The caller will have write access to the named pipe's owner
;                  |4 - The caller will have write access to the named pipe's security ACL
;                  $iType       - Pipe type mode. Must be one of the following:
;                  |0 - Data is written to the pipe as a stream of bytes
;                  |1 - Data is written to the pipe as a stream of messages
;                  $iRead        - Pipe read mode. Must be one of the following:
;                  |0 - Data is read from the pipe as a stream of bytes
;                  |1 - Data is read from the pipe as a stream of messages
;                  $iWait       - Pipe wait mode. Must be one of the following:
;                  |0 - Blocking mode is enabled.  When the pipe handle is specified in ReadFile, WriteFile, or ConnectNamedPipe,
;                  +the operation is not completed until there is data to read, all data is written, or a client is connected.
;                  |1 - Nonblocking mode is enabled. ReadFile, WriteFile, and ConnectNamedPipe always return immediately.
;                  $iMaxInst    - The maximum number of instances that can be created for this pipe
;                  $iOutBufSize - The number of bytes to reserve for the output buffer
;                  $iInpBufSize - The number of bytes to reserve for the input buffer
;                  $iDefTimeOut - The default time out value, in milliseconds
;                  $pSecurity   - A pointer to a tagSECURITY_ATTRIBUTES structure that specifies a security  descriptor  for  the
;                  +new named pipe and determines whether child processes can inherit the returned handle. If pSecurity is 0, the
;                  +named pipe gets a default security descriptor and the handle cannot be inherited.  The ACLs  in  the  default
;                  +security descriptor for a named pipe grant full control to the LocalSystem account  administrators,  and  the
;                  +creator owner. They also grant read access to members of the Everyone group and the anonymous account.
; Return values .: Success      - Handle to the server end of a named pipe instance
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _NamedPipes_ConnectNamedPipe, _NamedPipes_CreatePipe
; Link ..........: @@MsdnLink@@ CreateNamedPipe
; Example .......:
; ===============================================================================================================================
Func _NamedPipes_CreateNamedPipe($sName, $iAccess = 2, $iFlags = 2, $iACL = 0, $iType = 1, $iRead = 1, $iWait = 0, $iMaxInst = 25, _
		$iOutBufSize = 4096, $iInpBufSize = 4096, $iDefTimeout = 5000, $pSecurity = 0)
	Local $iOpenMode, $iPipeMode

	Switch $iAccess
		Case 1
			$iOpenMode = $__PIPE_ACCESS_OUTBOUND
		Case 2
			$iOpenMode = $__PIPE_ACCESS_DUPLEX
		Case Else
			$iOpenMode = $__PIPE_ACCESS_INBOUND
	EndSwitch
	If BitAND($iFlags, 1) <> 0 Then $iOpenMode = BitOR($iOpenMode, $__FILE_FLAG_FIRST_PIPE_INSTANCE)
	If BitAND($iFlags, 2) <> 0 Then $iOpenMode = BitOR($iOpenMode, $__FILE_FLAG_OVERLAPPED)
	If BitAND($iFlags, 4) <> 0 Then $iOpenMode = BitOR($iOpenMode, $__FILE_FLAG_WRITE_THROUGH)

	If BitAND($iACL, 1) <> 0 Then $iOpenMode = BitOR($iOpenMode, $__WRITE_DAC)
	If BitAND($iACL, 2) <> 0 Then $iOpenMode = BitOR($iOpenMode, $__WRITE_OWNER)
	If BitAND($iACL, 4) <> 0 Then $iOpenMode = BitOR($iOpenMode, $__ACCESS_SYSTEM_SECURITY)

	Switch $iType
		Case 1
			$iPipeMode = $__PIPE_TYPE_MESSAGE
		Case Else
			$iPipeMode = $__PIPE_TYPE_BYTE
	EndSwitch

	Switch $iRead
		Case 1
			$iPipeMode = BitOR($iPipeMode, $__PIPE_READMODE_MESSAGE)
		Case Else
			$iPipeMode = BitOR($iPipeMode, $__PIPE_READMODE_BYTE)
	EndSwitch

	Switch $iWait
		Case 1
			$iPipeMode = BitOR($iPipeMode, $__PIPE_NOWAIT)
		Case Else
			$iPipeMode = BitOR($iPipeMode, $__PIPE_WAIT)
	EndSwitch

	Local $aResult = DllCall("kernel32.dll", "handle", "CreateNamedPipeW", "wstr", $sName, "dword", $iOpenMode, "dword", $iPipeMode, "dword", $iMaxInst, _
			"dword", $iOutBufSize, "dword", $iInpBufSize, "dword", $iDefTimeout, "ptr", $pSecurity)
	If @error Then Return SetError(@error, @extended, -1)
	Return $aResult[0]
EndFunc   ;==>_NamedPipes_CreateNamedPipe

; #FUNCTION# ====================================================================================================================
; Name...........: _NamedPipes_CreatePipe
; Description ...: Creates an anonymous pipe
; Syntax.........: _NamedPipes_CreatePipe(ByRef $hReadPipe, ByRef $hWritePipe[, $tSecurity = 0[, $iSize = 0]])
; Parameters ....: $hReadPipe   - Variable that receives the read handle for the pipe
;                  $hWritePipe  - Variable that receives the write handle for the pipe
;                  $tSecurity   - tagSECURITY_ATTRIBUTES structure that determines if the returned handle  can  be  inherited  by
;                  +child processes. If 0, the handles cannot be inherited.
;                  $iSize       - The size of the buffer for the pipe, in bytes. If 0, the system uses the default buffer size.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _NamedPipes_CreateNamedPipe
; Link ..........: @@MsdnLink@@ CreatePipe
; Example .......:
; ===============================================================================================================================
Func _NamedPipes_CreatePipe(ByRef $hReadPipe, ByRef $hWritePipe, $tSecurity = 0, $iSize = 0)
	Local $aResult = DllCall("kernel32.dll", "bool", "CreatePipe", "handle*", 0, "handle*", 0, "struct*", $tSecurity, "dword", $iSize)
	If @error Then Return SetError(@error, @extended, False)
	$hReadPipe = $aResult[1] ; read pipe handle
	$hWritePipe = $aResult[2] ; write pipe handle
	Return $aResult[0]
EndFunc   ;==>_NamedPipes_CreatePipe

; #FUNCTION# ====================================================================================================================
; Name...........: _NamedPipes_DisconnectNamedPipe
; Description ...: Disconnects the server end of a named pipe instance from a client process
; Syntax.........: _NamedPipes_DisconnectNamedPipe($hNamedPipe)
; Parameters ....: $hNamedPipe  - Handle to the server end of a named pipe instance.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: If the client end of the named pipe is open, the DisconnectNamedPipe function forces that  end  of  the  named
;                  pipe closed.  The client receives an error the next time it attempts to access the  pipe.  A  client  that  is
;                  forced off a pipe must still use the CloseHandle function to close its end of the pipe.
; Related .......:
; Link ..........: @@MsdnLink@@ DisconnectNamedPipe
; Example .......:
; ===============================================================================================================================
Func _NamedPipes_DisconnectNamedPipe($hNamedPipe)
	Local $aResult = DllCall("kernel32.dll", "bool", "DisconnectNamedPipe", "handle", $hNamedPipe)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_NamedPipes_DisconnectNamedPipe

; #FUNCTION# ====================================================================================================================
; Name...........: _NamedPipes_GetNamedPipeHandleState
; Description ...: Retrieves information about a specified named pipe
; Syntax.........: _NamedPipes_GetNamedPipeHandleState($hNamedPipe)
; Parameters ....: $hNamedPipe  - Handle to the server end of a named pipe instance
; Return values .: Success      - Array with the following format:
;                  |$aState[0] - True if pipe handle is in nonblocking mode, otherwise blocking mode
;                  |$aState[1] - True if pipe handle is in message-read mode, otherwise byte read mode
;                  |$aState[2] - Number of current pipe instances
;                  |$aState[3] - Maximum number of bytes to be collected on the client's computer before transmission
;                  |$aState[4] - Maximum time, in milliseconds, that can pass before a remote named  pipe  transfers  information
;                  +over the network.
;                  |$aState[5] - User name string associated with the client application.  The  server  can  only  retrieve  this
;                  +information if the client opened the pipe with the SECURITY_IMPERSONATION access privilige.
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _NamedPipes_SetNamedPipeHandleState
; Link ..........: @@MsdnLink@@ GetNamedPipeHandleState
; Example .......:
; ===============================================================================================================================
Func _NamedPipes_GetNamedPipeHandleState($hNamedPipe)
	Local $aResult = DllCall("kernel32.dll", "bool", "GetNamedPipeHandleStateW", "handle", $hNamedPipe, "dword*", 0, "dword*", 0, _
			"dword*", 0, "dword*", 0, "wstr", "", "dword", 4096)
	If @error Then Return SetError(@error, @extended, 0)
	Local $aState[6]
	$aState[0] = BitAND($aResult[2], $__PIPE_NOWAIT) <> 0 ;	State
	$aState[1] = BitAND($aResult[2], $__PIPE_READMODE_MESSAGE) <> 0 ;	State
	$aState[2] = $aResult[3] ;	CurInst
	$aState[3] = $aResult[4] ;	MaxCount
	$aState[4] = $aResult[5] ;	TimeOut
	$aState[5] = $aResult[6] ;	Username
	Return SetError(0, $aResult[0], $aState)
EndFunc   ;==>_NamedPipes_GetNamedPipeHandleState

; #FUNCTION# ====================================================================================================================
; Name...........: _NamedPipes_GetNamedPipeInfo
; Description ...: Retrieves information about the specified named pipe
; Syntax.........: _NamedPipes_GetNamedPipeInfo($hNamedPipe)
; Parameters ....: $hNamedPipe  - Handle to the named pipe instance. The handle must have GENERIC_READ access to the named pipe
; Return values .: Success      - Array with the following format:
;                  |$aInfo[0] - True if handle refers to server end, otherwise client end
;                  |$aInfo[1] - True for a message pipe, otherwise byte pipe
;                  |$aInfo[2] - Size of the buffer for outgoing data, in bytes
;                  |$aInfo[3] - Size of the buffer for incoming data, in bytes
;                  |$aInfo[4] - Maximum number of pipe instances that can be created
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GetNamedPipeInfo
; Example .......:
; ===============================================================================================================================
Func _NamedPipes_GetNamedPipeInfo($hNamedPipe)
	Local $aResult = DllCall("kernel32.dll", "bool", "GetNamedPipeInfo", "handle", $hNamedPipe, "dword*", 0, "dword*", 0, "dword*", 0, _
			"dword*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Local $aInfo[5]
	$aInfo[0] = BitAND($aResult[2], $__PIPE_SERVER_END) <> 0 ; Flags
	$aInfo[1] = BitAND($aResult[2], $__PIPE_TYPE_MESSAGE) <> 0 ; Flags
	$aInfo[2] = $aResult[3] ; OutSize
	$aInfo[3] = $aResult[4] ; InpSize
	$aInfo[4] = $aResult[5] ; MaxInst
	Return SetError(0, $aResult[0], $aInfo)
EndFunc   ;==>_NamedPipes_GetNamedPipeInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _NamedPipes_PeekNamedPipe
; Description ...: Copies data from a pipe into a buffer without removing it from the pipe
; Syntax.........: _NamedPipes_PeekNamedPipe($hNamedPipe)
; Parameters ....: $hNamedPipe  - Handle to the pipe
; Return values .: Success      - Array with the following format:
;                  |$aInfo[0] - Data read from the pipe
;                  |$aInfo[1] - Bytes read from the pipe
;                  |$aInfo[2] - Total bytes available to be read
;                  |$aInfo[3] - Bytes remaining to be read for this message
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ PeekNamedPipe
; Example .......:
; ===============================================================================================================================
Func _NamedPipes_PeekNamedPipe($hNamedPipe)
	Local $tBuffer = DllStructCreate("char Text[4096]")

	Local $aResult = DllCall("kernel32.dll", "bool", "PeekNamedPipe", "handle", $hNamedPipe, "struct*", $tBuffer, "int", 4096, "dword*", 0, _
			"dword*", 0, "dword*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Local $aInfo[4]
	$aInfo[0] = DllStructGetData($tBuffer, "Text")
	$aInfo[1] = $aResult[4] ; Read
	$aInfo[2] = $aResult[5] ; Total
	$aInfo[3] = $aResult[6] ; Left
	Return SetError(0, $aResult[0], $aInfo)
EndFunc   ;==>_NamedPipes_PeekNamedPipe

; #FUNCTION# ====================================================================================================================
; Name...........: _NamedPipes_SetNamedPipeHandleState
; Description ...: Sets the read mode and the blocking mode of the specified named pipe
; Syntax.........: _NamedPipes_SetNamedPipeHandleState($hNamedPipe, $iRead, $iWait[, $iBytes = 0[, $iTimeOut = 0]])
; Parameters ....: $hNamedPipe  - Handle to the named pipe instance
;                  $iRead       - Pipe read mode. Must be one of the following:
;                  |0 - Data is read from the pipe as a stream of bytes
;                  |1 - Data is read from the pipe as a stream of messages
;                  $iWait       - Pipe wait mode. Must be one of the following:
;                  |0 - Blocking mode is enabled
;                  |1 - Nonblocking mode is enabled
;                  $iBytes      - Maximum number of bytes collected on the client computer before transmission to the server
;                  $iTimeout     - Maximum time, in milliseconds, that can pass before a remote named pipe transfers information
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _NamedPipes_GetNamedPipeHandleState
; Link ..........: @@MsdnLink@@ SetNamedPipeHandleState
; Example .......:
; ===============================================================================================================================
Func _NamedPipes_SetNamedPipeHandleState($hNamedPipe, $iRead, $iWait, $iBytes = 0, $iTimeOut = 0)
	Local $iMode = 0, $pBytes = 0, $pTimeOut = 0

	Local $tInt = DllStructCreate("dword Bytes;dword Timeout")
	If $iRead = 1 Then $iMode = BitOR($iMode, $__PIPE_READMODE_MESSAGE)
	If $iWait = 1 Then $iMode = BitOR($iMode, $__PIPE_NOWAIT)

	If $iBytes <> 0 Then
		$pBytes = DllStructGetPtr($tInt, "Bytes")
		DllStructSetData($tInt, "Bytes", $iBytes)
	EndIf

	If $iTimeOut <> 0 Then
		$pTimeOut = DllStructGetPtr($tInt, "TimeOut")
		DllStructSetData($tInt, "TimeOut", $iTimeOut)
	EndIf

	Local $aResult = DllCall("kernel32.dll", "bool", "SetNamedPipeHandleState", "handle", $hNamedPipe, "dword*", $iMode, "ptr", $pBytes, "ptr", $pTimeOut)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_NamedPipes_SetNamedPipeHandleState

; #FUNCTION# ====================================================================================================================
; Name...........: _NamedPipes_TransactNamedPipe
; Description ...: Reads and writes to a named pipe in one network operation
; Syntax.........: _NamedPipes_TransactNamedPipe($hNamedPipe, $pInpBuf, $iInpSize, $pOutBuf, $iOutSize[, $pOverlapped = 0])
; Parameters ....: $hNamedPipe  - The handle to the named pipe
;                  $pInpBuf     - Pointer to the buffer containing the data to be written to the pipe
;                  $iInpSize    - Size of the write buffer, in bytes
;                  $pOutBuf     - Pointer to the buffer that receives the data read from the pipe
;                  $iOutSize    - Size of the read buffer, in bytes
;                  $pOverlapped - Pointer to a $tagOVERLAPPED structure.  This structure is required if hNamedPipe was opened with
;                  +$FILE_FLAG_OVERLAPPED. If hNamedPipe was opened with $FILE_FLAG_OVERLAPPED, pOverlapped must  not  be  0.  If
;                  +hNamedPipe was opened with $FILE_FLAG_OVERLAPPED and pOverlapped is not 0, TransactNamedPipe is  executed  as
;                  +an overlapped operation. The $tagOVERLAPPED structure should contain a  manual  reset  event  object.  If  the
;                  +operation cannot be completed immediately, TransactNamedPipe  returns  False  and  GetLastError  will  return
;                  +ERROR_IO_PENDING.
; Return values .: Success      - Number of bytes read from the pipe
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: TransactNamedPipe fails if the server did not create the pipe as a message-type pipe or if the pipe handle  is
;                  not in message-read mode.
; Related .......: $tagOVERLAPPED, _NamedPipes_CallNamedPipe
; Link ..........: @@MsdnLink@@ TransactNamedPipe
; Example .......:
; ===============================================================================================================================
Func _NamedPipes_TransactNamedPipe($hNamedPipe, $pInpBuf, $iInpSize, $pOutBuf, $iOutSize, $pOverlapped = 0)
	Local $aResult = DllCall("kernel32.dll", "bool", "TransactNamedPipe", "handle", $hNamedPipe, "ptr", $pInpBuf, "dword", $iInpSize, _
			"ptr", $pOutBuf, "dword", $iOutSize, "dword*", 0, "ptr", $pOverlapped)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetError(0, $aResult[0], $aResult[6])
EndFunc   ;==>_NamedPipes_TransactNamedPipe

; #FUNCTION# ====================================================================================================================
; Name...........: _NamedPipes_WaitNamedPipe
; Description ...: Waits for an instance of a named pipe to become available
; Syntax.........: _NamedPipes_WaitNamedPipe($sPipeName[, $iTimeOut = 0])
; Parameters ....: $sPipeName   - The name of the named pipe.  The string must include the name of  the  computer  on  which  the
;                  +server process is executing. A period may be used for the servername if the pipe is local.
;                  $iTimeout    - The number of milliseconds that the function will wait for the named pipe to be available.  You
;                  +can also use one of the following values:
;                  |-1 - The function does not return until an instance of the named pipe is available
;                  | 0 - The time-out interval is the default value specified by the server process
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: If no instances of the specified named pipe exist the WaitNamedPipe function returns immediately
; Related .......: _NamedPipes_CallNamedPipe
; Link ..........: @@MsdnLink@@ WaitNamedPipe
; Example .......:
; ===============================================================================================================================
Func _NamedPipes_WaitNamedPipe($sPipeName, $iTimeOut = 0)
	Local $aResult = DllCall("kernel32.dll", "bool", "WaitNamedPipeW", "wstr", $sPipeName, "dword", $iTimeOut)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_NamedPipes_WaitNamedPipe
