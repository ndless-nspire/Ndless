#include-once

#include "WinAPI.au3"
#include "StructureConstants.au3"

; #INDEX# =======================================================================================================================
; Title .........: WindowsNetworking
; AutoIt Version : 3.3.7.20++
; Language ......: English
; Description ...: Functions that assist with Windows Networking management.
;                  The Windows Networking (WNet) functions allow you to implement networking  capabilities  in  your  application
;                  without making allowances for a particular network  provider  or  physical  network  implementation.  This  is
;                  because the WNet functions are network independent.
; Author(s) .....: Paul Campbell (PaulIA)
; Dll(s) ........: mpr.dll
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $CONNDLG_RO_PATH = 0x00000001
Global Const $CONNDLG_CONN_POINT = 0x00000002
Global Const $CONNDLG_USE_MRU = 0x00000004
Global Const $CONNDLG_HIDE_BOX = 0x00000008
Global Const $CONNDLG_PERSIST = 0x00000010
Global Const $CONNDLG_NOT_PERSIST = 0x00000020

Global Const $CONNECT_UPDATE_PROFILE = 0x00000001
Global Const $CONNECT_UPDATE_RECENT = 0x00000002
Global Const $CONNECT_TEMPORARY = 0x00000004
Global Const $CONNECT_INTERACTIVE = 0x00000008
Global Const $CONNECT_PROMPT = 0x00000010
Global Const $CONNECT_NEED_DRIVE = 0x00000020
Global Const $CONNECT_REFCOUNT = 0x00000040
Global Const $CONNECT_REDIRECT = 0x00000080
Global Const $CONNECT_LOCALDRIVE = 0x00000100
Global Const $CONNECT_CURRENT_MEDIA = 0x00000200
Global Const $CONNECT_DEFERRED = 0x00000400
Global Const $CONNECT_COMMANDLINE = 0x00000800
Global Const $CONNECT_CMD_SAVECRED = 0x00001000
Global Const $CONNECT_RESERVED = 0xFF000000

Global Const $DISC_UPDATE_PROFILE = 0x00000001
Global Const $DISC_NO_FORCE = 0x00000040

Global Const $RESOURCE_CONNECTED = 0x00000001
Global Const $RESOURCE_GLOBALNET = 0x00000002
Global Const $RESOURCE_REMEMBERED = 0x00000003
Global Const $RESOURCE_RECENT = 0x00000004
Global Const $RESOURCE_CONTEXT = 0x00000005

Global Const $RESOURCETYPE_ANY = 0x00000000
Global Const $RESOURCETYPE_DISK = 0x00000001
Global Const $RESOURCETYPE_PRINT = 0x00000002
Global Const $RESOURCETYPE_RESERVED = 0x00000008
Global Const $RESOURCETYPE_UNKNOWN = 0xFFFFFFFF

Global Const $RESOURCEUSAGE_CONNECTABLE = 0x00000001
Global Const $RESOURCEUSAGE_CONTAINER = 0x00000002
Global Const $RESOURCEUSAGE_NOLOCALDEVICE = 0x00000004
Global Const $RESOURCEUSAGE_SIBLING = 0x00000008
Global Const $RESOURCEUSAGE_ATTACHED = 0x00000010
Global Const $RESOURCEUSAGE_RESERVED = 0x80000000

Global Const $WNNC_NET_MSNET = 0x00010000
Global Const $WNNC_NET_LANMAN = 0x00020000
Global Const $WNNC_NET_NETWARE = 0x00030000
Global Const $WNNC_NET_VINES = 0x00040000
Global Const $WNNC_NET_10NET = 0x00050000
Global Const $WNNC_NET_LOCUS = 0x00060000
Global Const $WNNC_NET_SUN_PC_NFS = 0x00070000
Global Const $WNNC_NET_LANSTEP = 0x00080000
Global Const $WNNC_NET_9TILES = 0x00090000
Global Const $WNNC_NET_LANTASTIC = 0x000A0000
Global Const $WNNC_NET_AS400 = 0x000B0000
Global Const $WNNC_NET_FTP_NFS = 0x000C0000
Global Const $WNNC_NET_PATHWORKS = 0x000D0000
Global Const $WNNC_NET_LIFENET = 0x000E0000
Global Const $WNNC_NET_POWERLAN = 0x000F0000
Global Const $WNNC_NET_BWNFS = 0x00100000
Global Const $WNNC_NET_COGENT = 0x00110000
Global Const $WNNC_NET_FARALLON = 0x00120000
Global Const $WNNC_NET_APPLETALK = 0x00130000
Global Const $WNNC_NET_INTERGRAPH = 0x00140000
Global Const $WNNC_NET_SYMFONET = 0x00150000
Global Const $WNNC_NET_CLEARCASE = 0x00160000
Global Const $WNNC_NET_FRONTIER = 0x00170000
Global Const $WNNC_NET_BMC = 0x00180000
Global Const $WNNC_NET_DCE = 0x00190000
Global Const $WNNC_NET_AVID = 0x001A0000
Global Const $WNNC_NET_DOCUSPACE = 0x001B0000
Global Const $WNNC_NET_MANGOSOFT = 0x001C0000
Global Const $WNNC_NET_SERNET = 0x001D0000
Global Const $WNNC_NET_RIVERFRONT1 = 0x001E0000
Global Const $WNNC_NET_RIVERFRONT2 = 0x001F0000
Global Const $WNNC_NET_DECORB = 0x00200000
Global Const $WNNC_NET_PROTSTOR = 0x00210000
Global Const $WNNC_NET_FJ_REDIR = 0x00220000
Global Const $WNNC_NET_DISTINCT = 0x00230000
Global Const $WNNC_NET_TWINS = 0x00240000
Global Const $WNNC_NET_RDR2SAMPLE = 0x00250000
Global Const $WNNC_NET_CSC = 0x00260000
Global Const $WNNC_NET_3IN1 = 0x00270000
Global Const $WNNC_NET_EXTENDNET = 0x00290000
Global Const $WNNC_NET_STAC = 0x002A0000
Global Const $WNNC_NET_FOXBAT = 0x002B0000
Global Const $WNNC_NET_YAHOO = 0x002C0000
Global Const $WNNC_NET_EXIFS = 0x002D0000
Global Const $WNNC_NET_DAV = 0x002E0000
Global Const $WNNC_NET_KNOWARE = 0x002F0000
Global Const $WNNC_NET_OBJECT_DIRE = 0x00300000
Global Const $WNNC_NET_MASFAX = 0x00310000
Global Const $WNNC_NET_HOB_NFS = 0x00320000
Global Const $WNNC_NET_SHIVA = 0x00330000
Global Const $WNNC_NET_IBMAL = 0x00340000
Global Const $WNNC_NET_LOCK = 0x00350000
Global Const $WNNC_NET_TERMSRV = 0x00360000
Global Const $WNNC_NET_SRT = 0x00370000
Global Const $WNNC_NET_QUINCY = 0x00380000
Global Const $WNNC_CRED_MANAGER = 0xFFFF0000
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_WinNet_AddConnection
;_WinNet_AddConnection2
;_WinNet_AddConnection3
;_WinNet_CancelConnection
;_WinNet_CancelConnection2
;_WinNet_CloseEnum
;_WinNet_ConnectionDialog
;_WinNet_ConnectionDialog1
;_WinNet_DisconnectDialog
;_WinNet_DisconnectDialog1
;_WinNet_EnumResource
;_WinNet_GetConnection
;_WinNet_GetConnectionPerformance
;_WinNet_GetLastError
;_WinNet_GetNetworkInformation
;_WinNet_GetProviderName
;_WinNet_GetResourceInformation
;_WinNet_GetResourceParent
;_WinNet_GetUniversalName
;_WinNet_GetUser
;_WinNet_OpenEnum
;_WinNet_RestoreConnection
;_WinNet_UseConnection
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;$tagCONNECTDLGSTRUCT
;$tagDISCDLGSTRUCT
;$tagNETCONNECTINFOSTRUCT
;$tagNETINFOSTRUCT
;$tagREMOTE_NAME_INFO
;__WinNet_NETRESOURCEToArray
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagCONNECTDLGSTRUCT
; Description ...: tagCONNECTDLGSTRUCT structure
; Fields ........: Size     - Size of this structure, in bytes
;                  hWnd     - Handle to the owner window for the dialog box
;                  Resource - Pointer to a tagNETRESOURCE structure.  If the lemoteName member of  tagNETRESOURCE  is  specified,
;                  +it will be entered into the path field of the dialog box.  With the exception of the Type member,  all  other
;                  +members of the tagNETRESOURCE structure must be set to 0.
;                  Flags    - Set of flags describing options for the dialog box display:
;                  |$SidTypeUser         - The account is a user account
;                  |$CONNDLG_RO_PATH     - Display a read-only path instead of allowing the user to type in a path
;                  |$CONNDLG_CONN_POINT  - Internal flag. Do not use.
;                  |$CONNDLG_USE_MRU     - Enter the most recently used paths into the combination box
;                  |$CONNDLG_HIDE_BOX    - Show the check box allowing the user to restore the connection at logon
;                  |$CONNDLG_PERSIST     - Restore the connection at logon
;                  |$CONNDLG_NOT_PERSIST - Do not restore the connection at logon
;                  DevNum   - If the call to the _WNet_ConnectionDialog1 function is successful, this member returns  the  number
;                  +of the connected device. The value is 1 for A:, 2 for B:, 3 for C:, and so on.  If the user made a deviceless
;                  +connection, the value is –1.
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagCONNECTDLGSTRUCT = "dword Size;hwnd hWnd;ptr Resource;dword Flags;dword DevNum"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagDISCDLGSTRUCT
; Description ...: tagDISCDLGSTRUCT structure
; Fields ........: Size       - Size of this structure, in bytes
;                  hWnd       - Handle to the owner window for the dialog box
;                  LocalName  - Pointer to a null-terminated string that specifies the local device name that  is  redirected  to
;                  +the network resource, such as "F:" or "LPT1".
;                  RemoteName - Pointer to a null-terminated string that specifies the name of the resource to  disconnect.  This
;                  +member can be 0 if the LocalName member is specified.  When LocalName is specified,  the  connection  to  the
;                  +network resource redirected from LocalName is disconnected.
;                  Flags      - Set of bit flags describing the connection:
;                  |$DISC_UPDATE_PROFILE - If this value is set, the specified connection is no longer  a  persistent  one.  This
;                  +flag is valid only if the LocalName member specifies a local device.
;                  |$DISC_NO_FORCE       - If this value is not set, the system applies force when attempting to disconnect  from
;                  +the network resource. This situation typically occurs when the user has files open over the connection.  This
;                  +value means that the user will be informed if there are open files on the connection, and asked if he or  she
;                  +still wants to disconnect. If the user wants to proceed, the disconnect procedure re-attempts with additional
;                  +force.
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagDISCDLGSTRUCT = "dword Size;hwnd hWnd;ptr LocalName;ptr RemoteName;dword Flags"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagNETCONNECTINFOSTRUCT
; Description ...: tagNETCONNECTINFOSTRUCT structure
; Fields ........: Size        - Size of this structure, in bytes
;                  Flags       - Set of bit flags describing the connection:
;                  |$WNCON_FORNETCARD  - In the absence of information about the  actual  connection,  the  information  returned
;                  +applies to the performance of the network card.  If this flag is not set, information is being  returned  for
;                  +the current connection with the resource, with any routing degradation taken into consideration.
;                  |$WNCON_NOTROUTED  - The connection is not being routed.  If this flag is not set, the connection may be going
;                  +through routers that limit performance.  Consequently, if WNCON_FORNETCARD is set, actual performance may  be
;                  +much less than the information returned.
;                  |$WNCON_SLOWLINK   - The connection is over a medium that is typically slow.  You should not set this  bit  if
;                  +the Speed member is set to a nonzero value.
;                  |$WNCON_DYNAMIC    - Some of the information returned is calculated dynamically, so reissuing this request may
;                  +return different (and more current) information.
;                  Speed       - Speed of the media to the network resource, in 100 bits-per-second
;                  Delay       - One-way delay time that the network introduces when sending information, in milliseconds
;                  OptDataSize - Size of data that an application should use when making a single request to the network resource
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNETCONNECTINFOSTRUCT = "dword Size;dword Flags;dword Speed;dword Delay;dword OptDataSize"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagNETINFOSTRUCT
; Description ...: tagNETINFOSTRUCT structure
; Fields ........: Size     - Size of this structure, in bytes
;                  Version  - Version number of the network provider software
;                  Status   - Current status of the network provider software:
;                  |$NO_ERROR         - The network is running
;                  |$ERROR_NO_NETWORK - The network is unavailable
;                  |$ERROR_BUSY       - The network is currently unavailable, but it should become available shortly
;                  Char     - Characteristics of the network provider software. This value is zero.
;                  Handle   - Instance handle for the network provider or for the 16-bit Windows network driver
;                  NetType  - Network type unique to the running network
;                  Printers - Set of bit flags indicating the valid print numbers for redirecting local printer devices, with the
;                  +low order bit corresponding to LPT1.
;                  Drives   - Set of bit flags indicating the valid local disk devices for redirecting disk drives, with the  low
;                  +order bit corresponding to A:.
;                  Reserved - Reserved, must be 0
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNETINFOSTRUCT = "dword Size;dword Version;dword Status;dword Char;ulong_ptr Handle;word NetType;dword Printers;dword Drives"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagREMOTE_NAME_INFO
; Description ...: tagREMOTE_NAME_INFO structure
; Fields ........: Universal  - Pointer to the null-terminated UNC name string that identifies a network resource
;                  Connection - Pointer to a null-terminated string that is the name of a network connection
;                  Remaining  - Pointer to a null-terminated name string
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagREMOTE_NAME_INFO = "ptr Universal;ptr Connection;ptr Remaining"

; #FUNCTION# ====================================================================================================================
; Name...........: _WinNet_AddConnection
; Description ...: Connects a local device to a network resource
; Syntax.........: _WinNet_AddConnection($sLocalName, $sRemoteName[, $sPassword = 0])
; Parameters ....: $sLocalName  - Name of a local device to be redirected, such as "F:" or "LPT1".  The string is  treated  in  a
;                  +case-insensitive manner.  If 0, a connection to the network resource is made without  redirecting  the  local
;                  +device.
;                  $sRemoteName - Name of the network resource to connect to
;                  $sPassword   - Password to be used to make a connection.  This parameter is usually  the  password  associated
;                  +with the current user. If 0, the default password is used. If the string is empty, no password is used.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function is provided only for compatibility with 16-bit versions of Windows. Applications should call the
;                  WNet_AddConnection2 or the WNet_AddConnection3 function.  A successful connection is persistent  meaning  that
;                  the system automatically restores the connection during subsequent logon operations.
; Related .......: _WinNet_AddConnection2, _WinNet_AddConnection3
; Link ..........: @@MsdnLink@@ WNetAddConnection
; Example .......:
; ===============================================================================================================================
Func _WinNet_AddConnection($sLocalName, $sRemoteName, $sPassword = 0)
	Local $tPassword = 0
	If IsString($sPassword) Then
		$tPassword = DllStructCreate("wchar Text[4096]")
		DllStructSetData($tPassword, "Text", $sPassword)
	EndIf

	Local $aResult = DllCall("mpr.dll", "dword", "WNetAddConnectionW", "wstr", $sRemoteName, "struct*", $tPassword, "wstr", $sLocalName)
	If @error Then Return SetError(@error, @extended, False)
	Return SetError($aResult[0], 0, $aResult[0] = 0)
EndFunc   ;==>_WinNet_AddConnection

; #FUNCTION# ====================================================================================================================
; Name...........: _WinNet_AddConnection2
; Description ...: Connects a local device to a network resource
; Syntax.........: _WinNet_AddConnection2($sLocalName, $sRemoteName[, $sUserName = 0[, $sPassword = 0[, $iType = 1[, $iOptions = 1]]]])
; Parameters ....: $sLocalName  - Name of a local device to be redirected, such as "F:" or "LPT1".  The string is  treated  in  a
;                  +case-insensitive manner.  If 0, a connection to the network resource is made without  redirecting  the  local
;                  +device.
;                  $sRemoteName - Name of the network resource to connect to
;                  $sUsername   - User name for making the connection. If 0, the function uses the default user name.
;                  $sPassword   - Password to be used to make a connection. If 0, the default password is used.  If the string is
;                  +empty, no password is used.
;                  $iType       - Specifies the type of network resource to connect to:
;                  |0 - Any (only if $sLocalName is 0)
;                  |1 - Disk
;                  |2 - Print
;                  $iOptions    - Connection options. Can be one or more of the following:
;                  | 1 - The network resource connection should be remembered
;                  | 2 - The operating system may interact with the user for authentication purposes
;                  | 4 - The system not to use any default setting for user names or passwords  without  offering  the  user  the
;                  +opportunity to supply an alternative. This flag is ignored unless bit 2 (interactive) is also set.
;                  | 8 - Forces the redirection of a local device when making the connection
;                  |16 - The operating system prompts the user for authentication using the command line instead of a  GUI.  This
;                  +flag is ignored unless bit 2 (interactive) is also set.
;                  |32 - If this bit is set, and the operating system prompts for a credential, the credential is  saved  by  the
;                  +credential manager.  If the credential manager is disabled for the caller's logon session, or if the  network
;                  +provider does not support saving credentials, this flag is ignored.  This flag is also ignored unless you set
;                  +bit 5 (command line instead of GUI).
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinNet_AddConnection, _WinNet_AddConnection3
; Link ..........: @@MsdnLink@@ WNetAddConnection2
; Example .......:
; ===============================================================================================================================
Func _WinNet_AddConnection2($sLocalName, $sRemoteName, $sUserName = 0, $sPassword = 0, $iType = 1, $iOptions = 1)
	Local $tLocalName = DllStructCreate("wchar Text[1024]")
	Local $pLocalName = DllStructGetPtr($tLocalName)
	DllStructSetData($tLocalName, "Text", $sLocalName)

	Local $tRemoteName = DllStructCreate("wchar Text[1024]")
	Local $pRemoteName = DllStructGetPtr($tRemoteName)
	DllStructSetData($tRemoteName, "Text", $sRemoteName)

	Local $tUserName = 0
	If IsString($sUserName) Then
		$tUserName = DllStructCreate("wchar Text[1024]")
		DllStructSetData($tUserName, "Text", $sUserName)
	EndIf

	Local $tPassword = 0
	If IsString($sPassword) Then
		$tPassword = DllStructCreate("wchar Text[1024]")
		DllStructSetData($tPassword, "Text", $sPassword)
	EndIf

	Local $iFlags = 0
	If BitAND($iOptions, 1) <> 0 Then $iFlags = BitOR($iFlags, $CONNECT_UPDATE_PROFILE)
	If BitAND($iOptions, 2) <> 0 Then $iFlags = BitOR($iFlags, $CONNECT_INTERACTIVE)
	If BitAND($iOptions, 4) <> 0 Then $iFlags = BitOR($iFlags, $CONNECT_PROMPT)
	If BitAND($iOptions, 8) <> 0 Then $iFlags = BitOR($iFlags, $CONNECT_REDIRECT)
	If BitAND($iOptions, 16) <> 0 Then $iFlags = BitOR($iFlags, $CONNECT_COMMANDLINE)
	If BitAND($iOptions, 32) <> 0 Then $iFlags = BitOR($iFlags, $CONNECT_CMD_SAVECRED)

	Local $tResource = DllStructCreate($tagNETRESOURCE)
	DllStructSetData($tResource, "Type", $iType)
	DllStructSetData($tResource, "LocalName", $pLocalName)
	DllStructSetData($tResource, "RemoteName", $pRemoteName)

	Local $aResult = DllCall("mpr.dll", "dword", "WNetAddConnection2W", "struct*", $tResource, "struct*", $tPassword, "struct*", $tUserName, "dword", $iFlags)
	If @error Then Return SetError(@error, @extended, False)
	Return SetError($aResult[0], 0, $aResult[0] = 0)
EndFunc   ;==>_WinNet_AddConnection2

; #FUNCTION# ====================================================================================================================
; Name...........: _WinNet_AddConnection3
; Description ...: Connects a local device to a network resource
; Syntax.........: _WinNet_AddConnection3($hWnd, $sLocalName, $sRemoteName[, $sUserName = 0[, $sPassword = 0[, $iType = 1[, $iOptions = 1]]]])
; Parameters ....: $hWnd        - Handle to a window that the provider of network resources  can  use  as  an  owner  window  for
;                  +dialogs. Use this parameter if you set bit 2 (interactive) in the Options parameter. This parameter can be 0.
;                  $sLocalName  - Name of a local device to be redirected, such as "F:" or "LPT1".  The string is  treated  in  a
;                  +case-insensitive manner.  If 0, a connection to the network resource is made without  redirecting  the  local
;                  +device.
;                  $sRemoteName - Name of the network resource to connect to
;                  $sUsername   - User name for making the connection.  If 0, the function uses the default user name.
;                  $sPassword   - Password to be used to make a connection.  If 0, the default password is used. If the string is
;                  +empty, no password is used.
;                  $iType       - Specifies the type of network resource to connect to:
;                  |0 - Any (only if $sLocalName is 0)
;                  |1 - Disk
;                  |2 - Print
;                  $iOptions    - Connection options. Can be one or more of the following:
;                  | 1 - The network resource connection should be remembered
;                  | 2 - The operating system may interact with the user for authentication purposes
;                  | 4 - The system not to use any default setting for user names or passwords  without  offering  the  user  the
;                  +opportunity to supply an alternative.  This flag is ignored unless bit 2 (interactive) is also set.
;                  | 8 - Forces the redirection of a local device when making the connection
;                  |16 - The operating system prompts the user for authentication using the command line instead of a  GUI.  This
;                  +flag is ignored unless bit 2 (interactive) is also set.
;                  |32 - If this bit is set, and the operating system prompts for a credential, the credential is  saved  by  the
;                  +credential manager.  If the credential manager is disabled for the caller's logon session, or if the  network
;                  +provider does not support saving credentials, this flag is ignored.  This flag is also ignored unless you set
;                  +bit 5 (command line instead of GUI).
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinNet_AddConnection, _WinNet_AddConnection2
; Link ..........: @@MsdnLink@@ WNetAddConnection3
; Example .......:
; ===============================================================================================================================
Func _WinNet_AddConnection3($hWnd, $sLocalName, $sRemoteName, $sUserName = 0, $sPassword = 0, $iType = 1, $iOptions = 1)
	Local $tLocalName = DllStructCreate("wchar Text[1024]")
	Local $pLocalName = DllStructGetPtr($tLocalName)
	DllStructSetData($tLocalName, "Text", $sLocalName)

	Local $tRemoteName = DllStructCreate("wchar Text[1024]")
	Local $pRemoteName = DllStructGetPtr($tRemoteName)
	DllStructSetData($tRemoteName, "Text", $sRemoteName)

	Local $tUserName = 0
	If IsString($sUserName) Then
		$tUserName = DllStructCreate("wchar Text[1024]")
		DllStructSetData($tUserName, "Text", $sUserName)
	EndIf

	Local $tPassword = 0
	If IsString($sPassword) Then
		$tPassword = DllStructCreate("wchar Text[1024]")
		DllStructSetData($tPassword, "Text", $sPassword)
	EndIf

	Local $iFlags = 0
	If BitAND($iOptions, 1) <> 0 Then $iFlags = BitOR($iFlags, $CONNECT_UPDATE_PROFILE)
	If BitAND($iOptions, 2) <> 0 Then $iFlags = BitOR($iFlags, $CONNECT_INTERACTIVE)
	If BitAND($iOptions, 4) <> 0 Then $iFlags = BitOR($iFlags, $CONNECT_PROMPT)
	If BitAND($iOptions, 8) <> 0 Then $iFlags = BitOR($iFlags, $CONNECT_REDIRECT)
	If BitAND($iOptions, 16) <> 0 Then $iFlags = BitOR($iFlags, $CONNECT_COMMANDLINE)
	If BitAND($iOptions, 32) <> 0 Then $iFlags = BitOR($iFlags, $CONNECT_CMD_SAVECRED)

	Local $tResource = DllStructCreate($tagNETRESOURCE)
	DllStructSetData($tResource, "Type", $iType)
	DllStructSetData($tResource, "LocalName", $pLocalName)
	DllStructSetData($tResource, "RemoteName", $pRemoteName)

	Local $aResult = DllCall("mpr.dll", "dword", "WNetAddConnection3W", "hwnd", $hWnd, "struct*", $tResource, "struct*", $tPassword, "struct*", $tUserName, "dword", $iFlags)
	If @error Then Return SetError(@error, @extended, False)
	Return SetError($aResult[0], 0, $aResult[0] = 0)
EndFunc   ;==>_WinNet_AddConnection3

; #FUNCTION# ====================================================================================================================
; Name...........: _WinNet_CancelConnection
; Description ...: Cancels an existing network connection
; Syntax.........: _WinNet_CancelConnection($sName[, $fForce = True])
; Parameters ....: $sName       - Name of either the redirected local device or the remote network resource to  disconnect  from.
;                  +When this parameter specifies a redirected local device, the  function  cancels  only  the  specified  device
;                  +redirection.  If the parameter specifies a remote network resource, only the connections to  remote  networks
;                  +without devices are canceled.
;                  $fForce      - Specifies whether or not the disconnection should occur if there are open files or jobs on  the
;                  +connection.  If this parameter is False, the function fails if there are open files or jobs.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function is provided for compatibility with 16-bit versions of  Windows. Other Windows-based applications
;                  should call the WNet_CancelConnection2 function.
; Related .......: _WinNet_CancelConnection2
; Link ..........: @@MsdnLink@@ WNetCancelConnection
; Example .......:
; ===============================================================================================================================
Func _WinNet_CancelConnection($sName, $fForce = True)
	Local $aResult = DllCall("mpr.dll", "dword", "WNetCancelConnectionW", "wstr", $sName, "bool", $fForce)
	If @error Then Return SetError(@error, @extended, False)
	Return SetError($aResult[0], 0, $aResult[0] = 0)
EndFunc   ;==>_WinNet_CancelConnection

; #FUNCTION# ====================================================================================================================
; Name...........: _WinNet_CancelConnection2
; Description ...: Cancels an existing network connection
; Syntax.........: _WinNet_CancelConnection2($sName[, $fUpdate = True[, $fForce = True]])
; Parameters ....: $sName       - Name of either the redirected local device or the remote network resource to  disconnect  from.
;                  +When this parameter specifies a redirected local device, the  function  cancels  only  the  specified  device
;                  +redirection.  If the parameter specifies a remote network resource, only the connections to  remote  networks
;                  +without devices are canceled.
;                  $fUpdate     - If True, the users profile is updated with the information that the connection is no  longer  a
;                  +persistent one.
;                  $fForce      - Specifies whether or not the disconnection should occur if there are open files or jobs on  the
;                  +connection.  If this parameter is False, the function fails if there are open files or jobs.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinNet_CancelConnection
; Link ..........: @@MsdnLink@@ WNetCancelConnection2
; Example .......:
; ===============================================================================================================================
Func _WinNet_CancelConnection2($sName, $fUpdate = True, $fForce = True)
	Local $aResult = DllCall("mpr.dll", "dword", "WNetCancelConnection2W", "wstr", $sName, "dword", $fUpdate, "bool", $fForce)
	If @error Then Return SetError(@error, @extended, False)
	Return SetError($aResult[0], 0, $aResult[0] = 0)
EndFunc   ;==>_WinNet_CancelConnection2

; #FUNCTION# ====================================================================================================================
; Name...........: _WinNet_CloseEnum
; Description ...: Ends a network resource enumeration started by a call to WNetOpenEnum
; Syntax.........: _WinNet_CloseEnum($hEnum)
; Parameters ....: $hEnum       - Handle that identifies an enumeration instance.  The handle is returned  by  the  WNet_OpenEnum
;                  +function
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinNet_OpenEnum
; Link ..........: @@MsdnLink@@ WNetCloseEnum
; Example .......:
; ===============================================================================================================================
Func _WinNet_CloseEnum($hEnum)
	Local $aResult = DllCall("mpr.dll", "dword", "WNetCloseEnum", "handle", $hEnum)
	If @error Then Return SetError(@error, @extended, False)
	Return SetError($aResult[0], 0, $aResult[0] = 0)
EndFunc   ;==>_WinNet_CloseEnum

; #FUNCTION# ====================================================================================================================
; Name...........: _WinNet_ConnectionDialog
; Description ...: Starts a general browsing dialog box for connecting to network resources
; Syntax.........: _WinNet_ConnectionDialog($hWnd)
; Parameters ....: $hWnd        - Handle to the owner window for the dialog box
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinNet_ConnectionDialog1
; Link ..........: @@MsdnLink@@ WNetConnectionDialog
; Example .......:
; ===============================================================================================================================
Func _WinNet_ConnectionDialog($hWnd)
	Local $aResult = DllCall("mpr.dll", "dword", "WNetConnectionDialog", "hwnd", $hWnd, "dword", $RESOURCETYPE_DISK)
	If @error Then Return SetError(@error, @extended, False)
	Return SetError($aResult[0], 0, $aResult[0] = 0)
EndFunc   ;==>_WinNet_ConnectionDialog

; #FUNCTION# ====================================================================================================================
; Name...........: _WinNet_ConnectionDialog1
; Description ...: Starts a general browsing dialog box for connecting to network resources
; Syntax.........: _WinNet_ConnectionDialog1($hWnd[, $sRemoteName = ""[, $iFlags = 2]])
; Parameters ....: $hWnd        - Handle to the owner window for the dialog box
;                  $sRemoteName - Name of the network resource to connect to
;                  $iFlags      - Dialog box options. Can be one or more of the following:
;                  | 1 - Display a read-only path instead of allowing the user to type in a path
;                  | 2 - Enter the most recently used paths into the combination box
;                  | 4 - Do not show the restore the connection at logon checkbox
;                  | 8 - Restore the connection at logon
;                  |16 - Do not restore the connection at logon
; Return values .: Success      - The number of the connected device.  The value is 1 for A:, 2 for B:, 3 for C: and  so  on.  If
;                  +the user made a deviceless connection, the value is –1.
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinNet_ConnectionDialog
; Link ..........: @@MsdnLink@@ WNetConnectionDialog1
; Example .......:
; ===============================================================================================================================
Func _WinNet_ConnectionDialog1($hWnd, $sRemoteName = "", $iFlags = 2)
	Local $tRemoteName = DllStructCreate("wchar Text[1024]")
	Local $pRemoteName = DllStructGetPtr($tRemoteName)
	DllStructSetData($tRemoteName, "Text", $sRemoteName)

	Local $tResource = DllStructCreate($tagNETRESOURCE)
	Local $pResource = DllStructGetPtr($tResource)
	DllStructSetData($tResource, "Type", $RESOURCETYPE_DISK)
	DllStructSetData($tResource, "RemoteName", $pRemoteName)

	Local $iDialog = 0
	If BitAND($iFlags, 1) <> 0 Then $iDialog = BitOR($iDialog, $CONNDLG_RO_PATH)
	If BitAND($iFlags, 2) <> 0 Then $iDialog = BitOR($iDialog, $CONNDLG_USE_MRU)
	If BitAND($iFlags, 4) <> 0 Then $iDialog = BitOR($iDialog, $CONNDLG_HIDE_BOX)
	If BitAND($iFlags, 8) <> 0 Then $iDialog = BitOR($iDialog, $CONNDLG_PERSIST)
	If BitAND($iFlags, 16) <> 0 Then $iDialog = BitOR($iDialog, $CONNDLG_NOT_PERSIST)

	Local $tConnect = DllStructCreate($tagCONNECTDLGSTRUCT)
	DllStructSetData($tConnect, "Size", DllStructGetSize($tConnect))
	DllStructSetData($tConnect, "hWnd", $hWnd)
	DllStructSetData($tConnect, "Resource", $pResource)
	DllStructSetData($tConnect, "Flags", $iDialog)

	Local $aResult = DllCall("mpr.dll", "dword", "WNetConnectionDialog1W", "struct*", $tConnect)
	If @error Then Return SetError(@error, @extended, 0)
	If $aResult[0] = -1 Then Return -1 ; user cancels the dialog box
	If $aResult[0] <> 0 Then Return SetError($aResult[0], 0, 0)
	Return DllStructGetData($tConnect, "DevNum")
EndFunc   ;==>_WinNet_ConnectionDialog1

; #FUNCTION# ====================================================================================================================
; Name...........: _WinNet_DisconnectDialog
; Description ...: Starts a general browsing dialog box for disconnecting from network resources
; Syntax.........: _WinNet_DisconnectDialog($hWnd)
; Parameters ....: $hWnd        - Handle to the owner window for the dialog box
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinNet_DisconnectDialog1
; Link ..........: @@MsdnLink@@ WNetDisconnectDialog
; Example .......:
; ===============================================================================================================================
Func _WinNet_DisconnectDialog($hWnd)
	Local $aResult = DllCall("mpr.dll", "dword", "WNetDisconnectDialog", "hwnd", $hWnd, "dword", $RESOURCETYPE_DISK)
	If @error Then Return SetError(@error, @extended, False)
	Return SetError($aResult[0], 0, $aResult[0] = 0)
EndFunc   ;==>_WinNet_DisconnectDialog

; #FUNCTION# ====================================================================================================================
; Name...........: _WinNet_DisconnectDialog1
; Description ...: Starts a general browsing dialog box for disconnecting from network resources
; Syntax.........: _WinNet_DisconnectDialog1($hWnd, $sLocalName[, $sRemoteName = ""[, $iFlags = 1]])
; Parameters ....: $hWnd        - Handle to the owner window for the dialog box
;                  $sLocalName  - Name of a local device, such as "F:" or "LPT1"
;                  $sRemoteName - Name of the network resource to disconnect.  This member can be 0 if $LocalName  is  specified.
;                  +When sLocalName is  specified,  the  connection  to  the  network  resource  redirected  from  sLocalName  is
;                  +disconnected.
;                  $iFlags      - Flags describing the connection. Can be a combination of:
;                  |1 - If this value is set, the specified connection is no longer a persistent one.  This flag is valid only if
;                  +sLocalName specifies a local device.
;                  |2 - If this value is NOT set, the system applies force when disconnecting
; Return values .: Success      - 1
;                  Failure      - 0 and set @error
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinNet_DisconnectDialog
; Link ..........: @@MsdnLink@@ WNetDisconnectDialog1
; Example .......:
; ===============================================================================================================================
Func _WinNet_DisconnectDialog1($hWnd, $sLocalName, $sRemoteName = "", $iFlags = 1)
	Local $tLocalName = DllStructCreate("wchar Text[1024]")
	Local $pLocalName = DllStructGetPtr($tLocalName)
	DllStructSetData($tLocalName, "Text", $sLocalName)

	Local $pRemoteName = 0
	If $sRemoteName <> "" Then
		Local $tRemoteName = DllStructCreate("wchar Text[1024]")
		$pRemoteName = DllStructGetPtr($tRemoteName)
		DllStructSetData($tRemoteName, "Text", $sRemoteName)
	EndIf

	Local $iOptions = 0
	If BitAND($iFlags, 1) <> 0 Then $iOptions = BitOR($iOptions, $DISC_UPDATE_PROFILE)
	If BitAND($iFlags, 2) <> 0 Then $iOptions = BitOR($iOptions, $DISC_NO_FORCE)

	Local $tDialog = DllStructCreate($tagDISCDLGSTRUCT)
	DllStructSetData($tDialog, "Size", DllStructGetSize($tDialog))
	DllStructSetData($tDialog, "hWnd", $hWnd)
	DllStructSetData($tDialog, "LocalName", $pLocalName)
	DllStructSetData($tDialog, "RemoteName", $pRemoteName)
	DllStructSetData($tDialog, "Flags", $iOptions)

	Local $aResult = DllCall("mpr.dll", "dword", "WNetDisconnectDialog1W", "struct*", $tDialog)
	If @error Then Return SetError(@error, @extended, 0)
	If $aResult[0] > 0 Then Return SetError($aResult[0], 0, 0)
	If $aResult[0] = -1 Then Return -1
	Return 1
EndFunc   ;==>_WinNet_DisconnectDialog1

; #FUNCTION# ====================================================================================================================
; Name...........: _WinNet_EnumResource
; Description ...: Continues an enumeration of network resources
; Syntax.........: _WinNet_EnumResource($hEnum, ByRef $iCount, $pBuffer, ByRef $iBufSize)
; Parameters ....: $hEnum       - Handle that identifies an enumeration instance.  The handle is returned by  the  _WinNet_OpenEnum
;                  +function.
;                  $iCount      - Number of entries requested.  If the number requested is  –1,  the  function  returns  as  many
;                  +entries as possible. If the function succeeds, on return the variable contains the number of entries actually
;                  +read
;                  $pBuffer     - Pointer to the buffer that receives the enumeration results.  The results are  returned  as  an
;                  +array of $tagNETRESOURCE structures.  The buffer must be large enough to hold the structures plus the  strings
;                  +to which their members point.  The buffer is valid until the next call using the handle specified  by  hEnum.
;                  +The order of $tagNETRESOURCE structures in the array is not predictable.
;                  $iBufSize    - The size of the buffer, in bytes.  If the buffer is too small to receive even one  entry,  this
;                  +parameter receives the required size of the buffer.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinNet_OpenEnum, $tagNETRESOURCE
; Link ..........: @@MsdnLink@@ WNetEnumResource
; Example .......:
; ===============================================================================================================================
Func _WinNet_EnumResource($hEnum, ByRef $iCount, $pBuffer, ByRef $iBufSize)
	Local $aResult = DllCall("mpr.dll", "dword", "WNetEnumResourceW", "handle", $hEnum, "dword*", $iCount, "ptr", $pBuffer, "dword*", $iBufSize)
	If @error Then Return SetError(@error, @extended, False)
	$iCount = $aResult[2]
	$iBufSize = $aResult[4]
	Return $aResult[0]
EndFunc   ;==>_WinNet_EnumResource

; #FUNCTION# ====================================================================================================================
; Name...........: _WinNet_GetConnection
; Description ...: Retrieves the name of the network resource associated with a local device
; Syntax.........: _WinNet_GetConnection($sLocalName)
; Parameters ....: $sLocalName  - The name of the local device to get the network name for
; Return values .: Success      - The remote name used to make the connection
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ WNetGetConnection
; Example .......:
; ===============================================================================================================================
Func _WinNet_GetConnection($sLocalName)
	Local $aResult = DllCall("mpr.dll", "dword", "WNetGetConnectionW", "wstr", $sLocalName, "wstr", "", "dword*", 4096)
	If @error Then Return SetError(@error, @extended, False)
	Return SetExtended($aResult[0], $aResult[2])
EndFunc   ;==>_WinNet_GetConnection

; #FUNCTION# ====================================================================================================================
; Name...........: _WinNet_GetConnectionPerformance
; Description ...: Returns information about the performance of a network connection resource
; Syntax.........: _WinNet_GetConnectionPerformance($sLocalName, $sRemoteName)
; Parameters ....: $sLocalName  - Name of a local device, such as "F:" or "LPT1", that is redirected to a network resource to  be
;                  +queried.  If blank, the network resource is specified in sRemoteName.  If this parameter  specifies  a  local
;                  +device sRemoteName is ignored.
;                  $sRemoteName - Name of the network resource  to  query.  The  resource  must  currently  have  an  established
;                  +connection.  For example, if the resource is a file on a file server, then having the file open  will  ensure
;                  +the connection.
; Return values .: Success      - Array with the following format:
;                  |$aInfo[0] - Connection description. Can be one of more of the following:
;                  | 1 - The information returned applies to the performance of the network card
;                  | 2 - The connection is not being routed
;                  | 4 - The connection is over a medium that is typically slow
;                  | 8 - Some of the information returned is calculated dynamically
;                  |$aInfo[1] - Speed of the media to the network resource, in 100 bps
;                  |$aInfo[2] - One-way delay time introduced when sending information
;                  |$aInfo[3] - Size of data that an application should use when making a single request to the resource
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ MultinetGetConnectionPerformance
; Example .......:
; ===============================================================================================================================
Func _WinNet_GetConnectionPerformance($sLocalName, $sRemoteName)

	Local $tLocalName = DllStructCreate("wchar Text[4096]")
	DllStructSetData($tLocalName, "Text", $sLocalName)

	Local $tRemoteName = DllStructCreate("wchar Text[4096]")
	DllStructSetData($tRemoteName, "Text", $sRemoteName)

	Local $tResource = DllStructCreate($tagNETRESOURCE)
	DllStructSetData($tResource, "LocalName", DllStructGetPtr($tLocalName))
	DllStructSetData($tResource, "RemoteName", DllStructGetPtr($tRemoteName))

	Local $tInfo = DllStructCreate($tagNETCONNECTINFOSTRUCT)
	DllStructSetData($tInfo, "Size", DllStructGetSize($tInfo))

	Local $aResult = DllCall("mpr.dll", "dword", "MultinetGetConnectionPerformanceW", "struct*", $tResource, "struct*", $tInfo)
	If @error Then Return SetError(@error, @extended, False)
	Local $aInfo[4]
	$aInfo[0] = DllStructGetData($tInfo, "Flags")
	$aInfo[1] = DllStructGetData($tInfo, "Speed")
	$aInfo[2] = DllStructGetData($tInfo, "Delay")
	$aInfo[3] = DllStructGetData($tInfo, "OptDataSize")
	Return SetExtended($aResult[0], $aInfo)
EndFunc   ;==>_WinNet_GetConnectionPerformance

; #FUNCTION# ====================================================================================================================
; Name...........: _WinNet_GetLastError
; Description ...: Retrieves the most recent extended error
; Syntax.........: _WinNet_GetLastError(ByRef $iError, ByRef $sError, ByRef $sName)
; Parameters ....: $iError      - On return, contains the most recent extended error code
;                  $sError      - On return, contains the most recent extended error code message
;                  $sName       - On return, the network provider that raised the error
; Return values .: Success      - The most recent error message
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ WNetGetLastError
; Example .......:
; ===============================================================================================================================
Func _WinNet_GetLastError(ByRef $iError, ByRef $sError, ByRef $sName)
	Local $aResult = DllCall("mpr.dll", "dword", "WNetGetLastErrorW", "dword*", $iError, "wstr", "", "dword", 1024, "wstr", "", "dword", 1024)
	If @error Then Return SetError(@error, @extended, False)
	$iError = $aResult[1]
	$sError = $aResult[2]
	$sName = $aResult[3]
	Return $aResult[0]
EndFunc   ;==>_WinNet_GetLastError

; #FUNCTION# ====================================================================================================================
; Name...........: _WinNet_GetNetworkInformation
; Description ...: Returns extended information about a specific network provider
; Syntax.........: _WinNet_GetNetworkInformation($sName)
; Parameters ....: $sName       - The network provider for which information is required
; Return values .: Success      - Array with the following format:
;                  |$aInfo[0] - Version number of the network provider software
;                  |$aInfo[1] - Current status of the network provider software:
;                  | 0 - The network is running
;                  | 1 - The network is unavailable
;                  | 2 - The network is not currently able to service requests
;                  |$aInfo[2] - Instance handle for the network provider
;                  |$aInfo[3] - High word of the network type unique to the running network
;                  |$aInfo[4] - Set of bit flags indicating the valid print numbers for redirecting local printer  devices,  with
;                  +the low-order bit corresponding to LPT1.
;                  |$aInfo[5] - Set of bit flags indicating the valid local disk devices that can be used  for  redirecting  disk
;                  +drives, with the low-order bit corresponding to A:.
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ WNetGetNetworkInformationA
; Example .......:
; ===============================================================================================================================
Func _WinNet_GetNetworkInformation($sName)
	Local $tInfo = DllStructCreate($tagNETINFOSTRUCT)
	DllStructSetData($tInfo, "Size", DllStructGetSize($tInfo))

	Local $aResult = DllCall("mpr.dll", "dword", "WNetGetNetworkInformationW", "wstr", $sName, "struct*", $tInfo)
	If @error Then Return SetError(@error, @extended, False)
	Local $aInfo[6]
	$aInfo[0] = DllStructGetData($tInfo, "Version")
	$aInfo[1] = DllStructGetData($tInfo, "Status")
	$aInfo[2] = DllStructGetData($tInfo, "Handle")
	$aInfo[3] = DllStructGetData($tInfo, "NetType")
	$aInfo[4] = DllStructGetData($tInfo, "Printers")
	$aInfo[5] = DllStructGetData($tInfo, "Drives")
	Return SetExtended($aResult[0], $aInfo)
EndFunc   ;==>_WinNet_GetNetworkInformation

; #FUNCTION# ====================================================================================================================
; Name...........: _WinNet_GetProviderName
; Description ...: Obtains the provider name for a specific type of network
; Syntax.........: _WinNet_GetProviderName($iType)
; Parameters ....: $iType       - Network type that is unique to the network
; Return values .: Success      - Network provider name
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ WNetGetProviderName
; Example .......:
; ===============================================================================================================================
Func _WinNet_GetProviderName($iType)
	Local $aResult = DllCall("mpr.dll", "dword", "WNetGetProviderNameW", "dword", $iType, "wstr", "", "dword*", 4096)
	If @error Then Return SetError(@error, @extended, "")
	Return SetExtended($aResult[0], $aResult[2])
EndFunc   ;==>_WinNet_GetProviderName

; #FUNCTION# ====================================================================================================================
; Name...........: _WinNet_GetResourceInformation
; Description ...: Identifies the network provider that owns the resource
; Syntax.........: _WinNet_GetResourceInformation($sRemoteName[, $sProvider = ""[, $iType = 0]])
; Parameters ....: $sRemoteName - The remote path name of the resource
;                  $sProvider   - The name of the provider that owns the resource.  This member can be blank if the provider name
;                  +is unknown.
;                  $iType       - Type of resource. This member can be 0 if it is not known.
; Return values .: Success      - Array with the following format:
;                  |$aResource[0] - Scope of enumeration:
;                  | 0 - Connected
;                  | 1 - All resources
;                  | 2 - Remembered
;                  |$aResource[1] - Type of resource:
;                  | 0 - Disk
;                  | 1 - Print
;                  | 2 - Unknown
;                  |$aResource[2] - Display option:
;                  | 0 - Generic
;                  | 1 - Domain
;                  | 2 - Server
;                  | 3 - Share
;                  | 4 - File
;                  | 5 - Group
;                  | 6 - Network
;                  | 7 - Root
;                  | 8 - Admin Share
;                  | 9 - Directory
;                  |10 - Tree
;                  |11 - NDS Container
;                  |$aResource[3] - Resource usage. Can be one or more of the following:
;                  | 1 - The resource is a connectable resource
;                  | 2 - The resource is a container resource
;                  | 4 - The resource is attached
;                  | 8 - Thre resource is reserved
;                  |$aResource[4] - Local name
;                  |$aResource[5] - Remote name
;                  |$aResource[6] - Comment supplied by the network provider
;                  |$aResource[7] - The name of the provider that owns the resource
;                  |$aResource[8] - The part of the resource that is accessed through system functions
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ WNetGetResourceInformation
; Example .......:
; ===============================================================================================================================
Func _WinNet_GetResourceInformation($sRemoteName, $sProvider = "", $iType = 0)
	Local $iRemote = StringLen($sRemoteName) + 1
	Local $tRemote = DllStructCreate("wchar Text[" & $iRemote & "]")
	Local $pRemote = DllStructGetPtr($tRemote)
	DllStructSetData($tRemote, "Text", $sRemoteName)

	Local $pProvider = 0
	If $sProvider <> "" Then
		Local $iProvider = StringLen($sProvider) + 1
		Local $tProvider = DllStructCreate("wchar Text[" & $iProvider & "]")
		$pProvider = DllStructGetPtr($tProvider)
		DllStructSetData($tProvider, "Text", $sProvider)
	EndIf

	Local $tBuffer = DllStructCreate("wchar Text[16384]")

	Local $tResource = DllStructCreate($tagNETRESOURCE)

	DllStructSetData($tResource, "RemoteName", $pRemote)
	DllStructSetData($tResource, "Type", $iType)
	DllStructSetData($tResource, "Provider", $pProvider)

	Local $aResult = DllCall("mpr.dll", "dword", "WNetGetResourceInformationW", "struct*", $tResource, "struct*", $tBuffer, "dword*", 16384, "wstr", "")
	If @error Then Return SetError(@error, @extended, False)
	Local $aResource = __WinNet_NETRESOURCEToArray(DllStructGetPtr($tBuffer))
	$aResource[8] = $aResult[4]
	Return SetExtended($aResult[0], $aResource)
EndFunc   ;==>_WinNet_GetResourceInformation

; #FUNCTION# ====================================================================================================================
; Name...........: _WinNet_GetResourceParent
; Description ...: Returns the parent of a network resource in the network browse hierarchy
; Syntax.........: _WinNet_GetResourceParent($sRemoteName, $sProvider[, $iType = 0])
; Parameters ....: $sRemoteName - The remote path name of the resource
;                  $sProvider   - The name of the provider that owns the resource
;                  $iType       - Type of resource. This member can be 0 if it is not known.
; Return values .: Success      - Array with the following format:
;                  |$aResource[0] - Scope of enumeration:
;                  | 0 - Connected
;                  | 1 - All resources
;                  | 2 - Remembered
;                  |$aResource[1] - Type of resource:
;                  | 0 - Disk
;                  | 1 - Print
;                  | 2 - Unknown
;                  |$aResource[2] - Display option:
;                  | 0 - Generic
;                  | 1 - Domain
;                  | 2 - Server
;                  | 3 - Share
;                  | 4 - File
;                  | 5 - Group
;                  | 6 - Network
;                  | 7 - Root
;                  | 8 - Admin Share
;                  | 9 - Directory
;                  |10 - Tree
;                  |11 - NDS Container
;                  |$aResource[3] - Resource usage. Can be one or more of the following:
;                  | 1 - The resource is a connectable resource
;                  | 2 - The resource is a container resource
;                  | 4 - The resource is attached
;                  | 8 - Thre resource is reserved
;                  |$aResource[4] - Local name
;                  |$aResource[5] - Remote name
;                  |$aResource[6] - Comment supplied by the network provider
;                  |$aResource[7] - The name of the provider that owns the resource
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ WNetGetResourceParent
; Example .......:
; ===============================================================================================================================
Func _WinNet_GetResourceParent($sRemoteName, $sProvider, $iType = 0)
	Local $iRemote = StringLen($sRemoteName) + 1
	Local $tRemote = DllStructCreate("wchar Text[" & $iRemote & "]")
	Local $pRemote = DllStructGetPtr($tRemote)
	DllStructSetData($tRemote, "Text", $sRemoteName)

	Local $iProvider = StringLen($sProvider) + 1
	Local $tProvider = DllStructCreate("wchar Text[" & $iProvider & "]")
	Local $pProvider = DllStructGetPtr($tProvider)
	DllStructSetData($tProvider, "Text", $sProvider)

	Local $tBuffer = DllStructCreate("byte[16384]")

	Local $tResource = DllStructCreate($tagNETRESOURCE)

	DllStructSetData($tResource, "RemoteName", $pRemote)
	DllStructSetData($tResource, "Type", $iType)
	DllStructSetData($tResource, "Provider", $pProvider)

	Local $aResult = DllCall("mpr.dll", "dword", "WNetGetResourceParentW", "struct*", $tResource, "struct*", $tBuffer, "dword*", 16384)
	If @error Then Return SetError(@error, @extended, False)
	Return SetExtended($aResult[0], __WinNet_NETRESOURCEToArray(DllStructGetPtr($tBuffer)))
EndFunc   ;==>_WinNet_GetResourceParent

; #FUNCTION# ====================================================================================================================
; Name...........: _WinNet_GetUniversalName
; Description ...: Converts drived based path to universal form
; Syntax.........: _WinNet_GetUniversalName($sLocalPath)
; Parameters ....: $sLocalPath  - Drive based path for a network resource
; Return values .: Success      - Array with the following format:
;                  |$aPath[0] - UNC name string that identifies a network resource
;                  |$aPath[1] - Name of the network connection
;                  |$aPath[2] - Remaining path string
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ WNetGetUniversalName
; Example .......:
; ===============================================================================================================================
Func _WinNet_GetUniversalName($sLocalPath)
	Local $iLocal = StringLen($sLocalPath) + 1
	Local $tLocal = DllStructCreate("wchar Text[" & $iLocal & "]")
	DllStructSetData($tLocal, "Text", $sLocalPath)

	Local $tBuffer = DllStructCreate("byte[16384]")

	Local $aResult = DllCall("mpr.dll", "dword", "WNetGetUniversalNameW", "struct*", $tLocal, "dword", 2, "struct*", $tBuffer, "dword*", 16384)
	If @error Then Return SetError(@error, @extended, False)
	Local $tRemote = DllStructCreate($tagREMOTE_NAME_INFO, DllStructGetPtr($tBuffer))
	Local $pText = DllStructGetData($tRemote, "Universal")
	Local $tText = DllStructCreate("wchar Text[4096]", $pText)
	Local $aPath[3]
	$aPath[0] = DllStructGetData($tText, "Text")
	$pText = DllStructGetData($tRemote, "Connection")
	$tText = DllStructCreate("wchar Text[4096]", $pText)
	$aPath[1] = DllStructGetData($tText, "Text")
	$pText = DllStructGetData($tRemote, "Remaining")
	$tText = DllStructCreate("wchar Text[4096]", $pText)
	$aPath[2] = DllStructGetData($tText, "Text")
	Return SetExtended($aResult[0], $aPath)
EndFunc   ;==>_WinNet_GetUniversalName

; #FUNCTION# ====================================================================================================================
; Name...........: _WinNet_GetUser
; Description ...: Retrieves the default user name, or the user name used to establish a connection
; Syntax.........: _WinNet_GetUser($sName)
; Parameters ....: $sName       - Either the name of a local device that has been redirected to a network resource, or the remote
;                  +name of a network resource to which a connection has been made without redirecting a local device.  If blank,
;                  +the system returns the name of the current user for the process.
; Return values .: Success      - User name
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ WNetGetUser
; Example .......:
; ===============================================================================================================================
Func _WinNet_GetUser($sName)
	Local $aResult = DllCall("mpr.dll", "dword", "WNetGetUserW", "wstr", $sName, "wstr", "", "dword*", 4096)
	If @error Then Return SetError(@error, @extended, False)
	Return SetExtended($aResult[0], $aResult[2])
EndFunc   ;==>_WinNet_GetUser

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __WinNet_NETRESOURCEToArray
; Description ...: Returns an array from a $tagNETRESOURCE structure
; Syntax.........: __WinNet_NETRESOURCEToArray($pResource)
; Parameters ....: $pResource   - Pointer to a $tagNETRESOURCE structure
; Return values .: Success      - Array with the following format:
;                  |$aResource[0] - Scope of enumeration:
;                  | 0 - Connected
;                  | 1 - All resources
;                  | 2 - Remembered
;                  |$aResource[1] - Type of resource:
;                  | 0 - Disk
;                  | 1 - Print
;                  | 2 - Unknown
;                  |$aResource[2] - Display option:
;                  | 0 - Generic
;                  | 1 - Domain
;                  | 2 - Server
;                  | 3 - Share
;                  | 4 - File
;                  | 5 - Group
;                  | 6 - Network
;                  | 7 - Root
;                  | 8 - Admin Share
;                  | 9 - Directory
;                  |10 - Tree
;                  |11 - NDS Container
;                  |$aResource[3] - Resource usage. Can be one or more of the following:
;                  | 1 - The resource is a connectable resource
;                  | 2 - The resource is a container resource
;                  | 4 - The resource is attached
;                  | 8 - Thre resource is reserved
;                  |$aResource[4] - Local name
;                  |$aResource[5] - Remote name
;                  |$aResource[6] - Comment supplied by the network provider
;                  |$aResource[7] - The name of the provider that owns the resource
;                  |$aResource[8] - The part of the resource that is accessed through system functions
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function is used internally and should not normally be called by the end user
; Related .......: $tagNETRESOURCE
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __WinNet_NETRESOURCEToArray($pResource)
	Local $aResource[9]

	Local $tResource = DllStructCreate($tagNETRESOURCE, $pResource)
	Local $iFlag = DllStructGetData($tResource, "Scope")
	Switch $iFlag
		Case $RESOURCE_CONNECTED
			$aResource[0] = 0
		Case $RESOURCE_GLOBALNET
			$aResource[0] = 1
		Case $RESOURCE_REMEMBERED
			$aResource[0] = 2
		Case Else
			$aResource[0] = $iFlag
	EndSwitch

	$aResource[1] = DllStructGetData($tResource, "Type")
	$aResource[2] = DllStructGetData($tResource, "DisplayType")

	Local $iRet = 0
	$iFlag = DllStructGetData($tResource, "Usage")
	If BitAND($iFlag, $RESOURCEUSAGE_CONNECTABLE) <> 0 Then $iRet = BitOR($iRet, 1)
	If BitAND($iFlag, $RESOURCEUSAGE_CONTAINER) <> 0 Then $iRet = BitOR($iRet, 2)
	If BitAND($iFlag, $RESOURCEUSAGE_ATTACHED) <> 0 Then $iRet = BitOR($iRet, 4)
	If BitAND($iFlag, $RESOURCEUSAGE_RESERVED) <> 0 Then $iRet = BitOR($iRet, 8)
	$aResource[3] = $iRet

	Local $pText = DllStructGetData($tResource, "LocalName")
	Local $tText
	If $pText <> 0 Then
		$tText = DllStructCreate("wchar Text[4096]", $pText)
		$aResource[4] = DllStructGetData($tText, "Text")
	EndIf
	$pText = DllStructGetData($tResource, "RemoteName")
	If $pText <> 0 Then
		$tText = DllStructCreate("wchar Text[4096]", $pText)
		$aResource[5] = DllStructGetData($tText, "Text")
	EndIf
	$pText = DllStructGetData($tResource, "Comment")
	If $pText <> 0 Then
		$tText = DllStructCreate("wchar Text[4096]", $pText)
		$aResource[6] = DllStructGetData($tText, "Text")
	EndIf
	$pText = DllStructGetData($tResource, "Provider")
	If $pText <> 0 Then
		$tText = DllStructCreate("wchar Text[4096]", $pText)
		$aResource[7] = DllStructGetData($tText, "Text")
	EndIf
	Return $aResource
EndFunc   ;==>__WinNet_NETRESOURCEToArray

; #FUNCTION# ====================================================================================================================
; Name...........: _WinNet_OpenEnum
; Description ...: Starts an enumeration of network resources or existing connections
; Syntax.........: _WinNet_OpenEnum($iScope, $iType, $iUsage, $pResource, ByRef $hEnum)
; Parameters ....: $iScope      - Scope of the enumeration:
;                  |0 - Enumerate all currently connected resources
;                  |1 - Enumerate all resources on the network
;                  |2 - Enumerate all remembered (persistent) connections
;                  |3 - Enumerate only resources in the network context of the caller
;                  $iType       - Resource types:
;                  |0 - All resources
;                  |1 - Disk resources
;                  |2 - Print resources
;                  $iUsage      - Resource usage types:
;                  |0 - All resources
;                  |1 - All connectable resources
;                  |2 - All container resources
;                  |4 - Forces the function to fail if the user is not authenticated
;                  $pResource   - Pointer to a $tagNETRESOURCE structure that specifies the container to enumerate.  If iScope  is
;                  +not 1, this must be 0. If 0, the root of the network is assumed.
;                  $hEnum       - On return, a handle that can be used in calls to WNet_EnumResource
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinNet_EnumResource, _WinNet_CloseEnum, $tagNETRESOURCE
; Link ..........: @@MsdnLink@@ WNetOpenEnum
; Example .......:
; ===============================================================================================================================
Func _WinNet_OpenEnum($iScope, $iType, $iUsage, $pResource, ByRef $hEnum)
	Switch $iScope
		Case 1
			$iScope = $RESOURCE_GLOBALNET
		Case 2
			$iScope = $RESOURCE_REMEMBERED
		Case 3
			$iScope = $RESOURCE_CONTEXT
		Case Else
			$iScope = $RESOURCE_CONNECTED
	EndSwitch

	Local $iFlags = 0
	If BitAND($iUsage, 1) <> 0 Then $iFlags = BitOR($iFlags, $RESOURCEUSAGE_CONNECTABLE)
	If BitAND($iUsage, 2) <> 0 Then $iFlags = BitOR($iFlags, $RESOURCEUSAGE_CONTAINER)
	If BitAND($iUsage, 4) <> 0 Then $iFlags = BitOR($iFlags, $RESOURCEUSAGE_ATTACHED)

	Local $aResult = DllCall("mpr.dll", "dword", "WNetOpenEnum", "dword", $iScope, "dword", $iType, "dword", $iFlags, "ptr", $pResource, "handle*", 0)
	If @error Then Return SetError(@error, @extended, False)

	$hEnum = $aResult[5]
	Return SetError($aResult[0], 0, $aResult[0] = 0)
EndFunc   ;==>_WinNet_OpenEnum

; #FUNCTION# ====================================================================================================================
; Name...........: _WinNet_RestoreConnection
; Description ...: Restores the connection to a network resource
; Syntax.........: _WinNet_RestoreConnection([$sDevice = ""[, $hWnd = 0[, $fUseUI = True]]])
; Parameters ....: $sDevice     - The local name of the drive to connect to, such as "Z:".  If blank, the function reconnects all
;                  +persistent drives stored in the registry for the current user.
;                  $hWnd        - Handle to the parent window that the function uses to display the user interface  that  prompts
;                  +the user for a name and password when making the network connection. If 0, there is no owner window.
;                  $fUseUI      - If True, display a username/password prompt to the caller
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ WNetRestoreConnection
; Example .......:
; ===============================================================================================================================
Func _WinNet_RestoreConnection($sDevice = "", $hWnd = 0, $fUseUI = True)
	Local $tDevice = 0
	If $sDevice <> "" Then
		$tDevice = _WinAPI_MultiByteToWideChar($sDevice)
	EndIf

	Local $aResult = DllCall("mpr.dll", "dword", "WNetRestoreConnectionW", "hwnd", $hWnd, "struct*", $tDevice, "bool", $fUseUI)
	If @error Then Return SetError(@error, @extended, False)
	Return SetError($aResult[0], 0, $aResult[0] = 0)
EndFunc   ;==>_WinNet_RestoreConnection

; #FUNCTION# ====================================================================================================================
; Name...........: _WinNet_UseConnection
; Description ...: Connects a local device to a network resource
; Syntax.........: _WinNet_UseConnection($hWnd, $sLocalName, $sRemoteName[, $sUserName = 0[, $sPassword = 0[, $iType = 1[, $iOptions = 1]]]])
; Parameters ....: $hWnd        - Handle to a window that the provider of network resources  can  use  as  an  owner  window  for
;                  +dialogs. Use this parameter if you set bit 2 (interactive) in the Options parameter. This parameter can be 0.
;                  $sLocalName  - Name of a local device to be redirected, such as "F:" or "LPT1".  The string is  treated  in  a
;                  +case-insensitive manner.  If 0, a connection to the network resource is made without  redirecting  the  local
;                  +device.
;                  $sRemoteName - Name of the network resource to connect to
;                  $sUsername   - User name for making the connection.  If 0, the  function uses the default user name.
;                  $sPassword   - Password to be used to make a connection. If 0, the default password is used.  If the string is
;                  +empty, no password is used.
;                  $iType       - Specifies the type of network resource to connect to:
;                  |0 - Any (only if $sLocalName is blank)
;                  |1 - Disk
;                  |2 - Print
;                  $iOptions    - Connection options. Can be one or more of the following:
;                  | 1 - The network resource connection should be remembered
;                  | 2 - The operating system may interact with the user for authentication purposes
;                  | 4 - The system does not use any default setting for user names or passwords without offering  the  user  the
;                  +opportunity to supply an alternative.  This flag is ignored unless bit 2 (interactive) is also set.
;                  | 8 - Forces the redirection of a local device when making the connection
;                  |16 - The operating system prompts the user for authentication using the command line instead of a  GUI.  This
;                  +flag is ignored unless bit 2 (interactive) is also set.
;                  |32 - If this bit is set, and the operating system prompts for a credential, the credential is  saved  by  the
;                  +credential manager.  If the credential manager is disabled for the caller's logon session, or if the  network
;                  +provider does not support saving credentials, this flag is ignored.  This flag is also ignored unless you set
;                  +bit 5 (command line instead of GUI).
; Return values .: Success      - Array with the following format:
;                  |$aInfo[0] - If True, the connection was made using a local device redirection
;                  |$aInfo[1] - If sLocalName specifies a local device, this is the local device name.  If  sLocalName  does  not
;                  +specify a device and the network requires a local device redirection, or if bit 4 (force redirection) is set,
;                  +this buffer receives the name of the redirected local device.  Otherwise, the name copied into the buffer  is
;                  +that of a remote resource.
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ WNetUseConnection
; Example .......:
; ===============================================================================================================================
Func _WinNet_UseConnection($hWnd, $sLocalName, $sRemoteName, $sUserName = 0, $sPassword = 0, $iType = 1, $iOptions = 1)
	Local $iLocalName = StringLen($sLocalName) + 1
	Local $tLocalName = DllStructCreate("wchar Text[" & $iLocalName & "]")
	Local $pLocalName = DllStructGetPtr($tLocalName)

	Local $iRemoteName = StringLen($sRemoteName) + 1
	Local $tRemoteName = DllStructCreate("wchar Text[" & $iRemoteName & "]")
	Local $pRemoteName = DllStructGetPtr($tRemoteName)

	Local $tUserName = 0
	If IsString($sUserName) Then
		Local $iUserName = StringLen($sUserName) + 1
		$tUserName = DllStructCreate("wchar Text[" & $iUserName & "]")
		DllStructSetData($tUserName, "Text", $sUserName)
	EndIf

	Local $tPassword = 0
	If IsString($sPassword) Then
		Local $iPassword = StringLen($sPassword) + 1
		$tPassword = DllStructCreate("wchar Text[" & $iPassword & "]")
		DllStructSetData($tPassword, "Text", $sPassword)
	EndIf

	Local $iFlags = 0
	If BitAND($iOptions, 1) <> 0 Then $iFlags = BitOR($iFlags, $CONNECT_UPDATE_PROFILE)
	If BitAND($iOptions, 2) <> 0 Then $iFlags = BitOR($iFlags, $CONNECT_INTERACTIVE)
	If BitAND($iOptions, 4) <> 0 Then $iFlags = BitOR($iFlags, $CONNECT_PROMPT)
	If BitAND($iOptions, 8) <> 0 Then $iFlags = BitOR($iFlags, $CONNECT_REDIRECT)
	If BitAND($iOptions, 16) <> 0 Then $iFlags = BitOR($iFlags, $CONNECT_COMMANDLINE)
	If BitAND($iOptions, 32) <> 0 Then $iFlags = BitOR($iFlags, $CONNECT_CMD_SAVECRED)

	Local $tResource = DllStructCreate($tagNETRESOURCE)

	DllStructSetData($tLocalName, "Text", $sLocalName)
	DllStructSetData($tRemoteName, "Text", $sRemoteName)
	DllStructSetData($tResource, "Type", $iType)
	DllStructSetData($tResource, "LocalName", $pLocalName)
	DllStructSetData($tResource, "RemoteName", $pRemoteName)

	Local $aResult = DllCall("mpr.dll", "dword", "WNetUseConnectionW", "hwnd", $hWnd, "struct*", $tResource, "struct*", $tPassword, "struct*", $tUserName, _
			"dword", $iFlags, "wstr", "", "dword*", 4096, "dword*", 0)
	If @error Then Return SetError(@error, @extended, False)
	Local $aInfo[2]
	$aInfo[0] = BitAND($aResult[8], $CONNECT_LOCALDRIVE) <> 0
	$aInfo[1] = $aResult[6] ; AccessName
	Return SetExtended($aResult[0], $aInfo)
EndFunc   ;==>_WinNet_UseConnection
