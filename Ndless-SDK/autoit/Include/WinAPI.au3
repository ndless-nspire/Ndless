#include-once

#include "StructureConstants.au3"
#include "FileConstants.au3"
#include "Security.au3"
#include "SendMessage.au3"
#include "WinAPIError.au3"

; #INDEX# =======================================================================================================================
; Title .........: Windows API
; AutoIt Version : 3.3.7.20++
; Description ...: Windows API calls that have been translated to AutoIt functions.
; Author(s) .....: Paul Campbell (PaulIA), gafrost, Siao, Zedna, arcker, Prog@ndy, PsaltyDS, Raik, jpm
; Dll ...........: kernel32.dll, user32.dll, gdi32.dll, comdlg32.dll, shell32.dll, ole32.dll, winspool.drv
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $__gaInProcess_WinAPI[64][2] = [[0, 0]]
Global $__gaWinList_WinAPI[64][2] = [[0, 0]]
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__WINAPICONSTANT_WM_SETFONT = 0x0030
Global Const $__WINAPICONSTANT_FW_NORMAL = 400
Global Const $__WINAPICONSTANT_DEFAULT_CHARSET = 1
Global Const $__WINAPICONSTANT_OUT_DEFAULT_PRECIS = 0
Global Const $__WINAPICONSTANT_CLIP_DEFAULT_PRECIS = 0
Global Const $__WINAPICONSTANT_DEFAULT_QUALITY = 0

Global Const $__WINAPICONSTANT_FORMAT_MESSAGE_ALLOCATE_BUFFER = 0x100
Global Const $__WINAPICONSTANT_FORMAT_MESSAGE_FROM_SYSTEM = 0x1000

Global Const $__WINAPICONSTANT_LOGPIXELSX = 88
Global Const $__WINAPICONSTANT_LOGPIXELSY = 90

Global Const $HGDI_ERROR = Ptr(-1)
Global Const $INVALID_HANDLE_VALUE = Ptr(-1)
Global Const $CLR_INVALID = -1

; FlashWindowEx Constants
Global Const $__WINAPICONSTANT_FLASHW_CAPTION = 0x00000001
Global Const $__WINAPICONSTANT_FLASHW_TRAY = 0x00000002
Global Const $__WINAPICONSTANT_FLASHW_TIMER = 0x00000004
Global Const $__WINAPICONSTANT_FLASHW_TIMERNOFG = 0x0000000C

; GetWindows Constants
Global Const $__WINAPICONSTANT_GW_HWNDNEXT = 2
Global Const $__WINAPICONSTANT_GW_CHILD = 5

; DrawIconEx Constants
Global Const $__WINAPICONSTANT_DI_MASK = 0x0001
Global Const $__WINAPICONSTANT_DI_IMAGE = 0x0002
Global Const $__WINAPICONSTANT_DI_NORMAL = 0x0003
Global Const $__WINAPICONSTANT_DI_COMPAT = 0x0004
Global Const $__WINAPICONSTANT_DI_DEFAULTSIZE = 0x0008
Global Const $__WINAPICONSTANT_DI_NOMIRROR = 0x0010

; EnumDisplayDevice Constants
Global Const $__WINAPICONSTANT_DISPLAY_DEVICE_ATTACHED_TO_DESKTOP = 0x00000001
Global Const $__WINAPICONSTANT_DISPLAY_DEVICE_PRIMARY_DEVICE = 0x00000004
Global Const $__WINAPICONSTANT_DISPLAY_DEVICE_MIRRORING_DRIVER = 0x00000008
Global Const $__WINAPICONSTANT_DISPLAY_DEVICE_VGA_COMPATIBLE = 0x00000010
Global Const $__WINAPICONSTANT_DISPLAY_DEVICE_REMOVABLE = 0x00000020
Global Const $__WINAPICONSTANT_DISPLAY_DEVICE_MODESPRUNED = 0x08000000

; Stock Object Constants
Global Const $NULL_BRUSH = 5 ; Null brush (equivalent to HOLLOW_BRUSH)
Global Const $NULL_PEN = 8 ; NULL pen. The null pen draws nothing
Global Const $BLACK_BRUSH = 4 ; Black brush
Global Const $DKGRAY_BRUSH = 3 ; Dark gray brush
Global Const $DC_BRUSH = 18 ; Windows 2000/XP: Solid color brush. The default color is white
Global Const $GRAY_BRUSH = 2 ; Gray brush
Global Const $HOLLOW_BRUSH = $NULL_BRUSH ; Hollow brush (equivalent to NULL_BRUSH)
Global Const $LTGRAY_BRUSH = 1 ; Light gray brush
Global Const $WHITE_BRUSH = 0 ; White brush
Global Const $BLACK_PEN = 7 ; Black pen
Global Const $DC_PEN = 19 ; Windows 2000/XP: Solid pen color. The default color is white
Global Const $WHITE_PEN = 6 ; White pen
Global Const $ANSI_FIXED_FONT = 11 ; Windows fixed-pitch (monospace) system font
Global Const $ANSI_VAR_FONT = 12 ; Windows variable-pitch (proportional space) system font
Global Const $DEVICE_DEFAULT_FONT = 14 ; Windows NT/2000/XP: Device-dependent font
Global Const $DEFAULT_GUI_FONT = 17 ; Default font for user interface objects such as menus and dialog boxes
Global Const $OEM_FIXED_FONT = 10 ; Original equipment manufacturer (OEM) dependent fixed-pitch (monospace) font
Global Const $SYSTEM_FONT = 13 ; System font. By default, the system uses the system font to draw menus, dialog box controls, and text
Global Const $SYSTEM_FIXED_FONT = 16 ; Fixed-pitch (monospace) system font. This stock object is provided only for compatibility with 16-bit Windows versions earlier than 3.0
Global Const $DEFAULT_PALETTE = 15 ; Default palette. This palette consists of the static colors in the system palette

; conversion type
Global Const $MB_PRECOMPOSED = 0x01
Global Const $MB_COMPOSITE = 0x02
Global Const $MB_USEGLYPHCHARS = 0x04

;translucency flags
Global Const $ULW_ALPHA = 0x02
Global Const $ULW_COLORKEY = 0x01
Global Const $ULW_OPAQUE = 0x04

;Window Hooks
Global Const $WH_CALLWNDPROC = 4
Global Const $WH_CALLWNDPROCRET = 12
Global Const $WH_CBT = 5
Global Const $WH_DEBUG = 9
Global Const $WH_FOREGROUNDIDLE = 11
Global Const $WH_GETMESSAGE = 3
Global Const $WH_JOURNALPLAYBACK = 1
Global Const $WH_JOURNALRECORD = 0
Global Const $WH_KEYBOARD = 2
Global Const $WH_KEYBOARD_LL = 13
Global Const $WH_MOUSE = 7
Global Const $WH_MOUSE_LL = 14
Global Const $WH_MSGFILTER = -1
Global Const $WH_SHELL = 10
Global Const $WH_SYSMSGFILTER = 6

;Window Placement
Global Const $WPF_ASYNCWINDOWPLACEMENT = 0x04
Global Const $WPF_RESTORETOMAXIMIZED = 0x02
Global Const $WPF_SETMINPOSITION = 0x01

;flags for $tagKBDLLHOOKSTRUCT
Global Const $KF_EXTENDED = 0x0100
Global Const $KF_ALTDOWN = 0x2000
Global Const $KF_UP = 0x8000
Global Const $LLKHF_EXTENDED = BitShift($KF_EXTENDED, 8)
Global Const $LLKHF_INJECTED = 0x10
Global Const $LLKHF_ALTDOWN = BitShift($KF_ALTDOWN, 8)
Global Const $LLKHF_UP = BitShift($KF_UP, 8)

;flags for $tagOPENFILENAME
Global Const $OFN_ALLOWMULTISELECT = 0x00000200
Global Const $OFN_CREATEPROMPT = 0x00002000
Global Const $OFN_DONTADDTORECENT = 0x02000000
Global Const $OFN_ENABLEHOOK = 0x00000020
Global Const $OFN_ENABLEINCLUDENOTIFY = 0x00400000
Global Const $OFN_ENABLESIZING = 0x00800000
Global Const $OFN_ENABLETEMPLATE = 0x00000040
Global Const $OFN_ENABLETEMPLATEHANDLE = 0x00000080
Global Const $OFN_EXPLORER = 0x00080000
Global Const $OFN_EXTENSIONDIFFERENT = 0x00000400
Global Const $OFN_FILEMUSTEXIST = 0x00001000
Global Const $OFN_FORCESHOWHIDDEN = 0x10000000
Global Const $OFN_HIDEREADONLY = 0x00000004
Global Const $OFN_LONGNAMES = 0x00200000
Global Const $OFN_NOCHANGEDIR = 0x00000008
Global Const $OFN_NODEREFERENCELINKS = 0x00100000
Global Const $OFN_NOLONGNAMES = 0x00040000
Global Const $OFN_NONETWORKBUTTON = 0x00020000
Global Const $OFN_NOREADONLYRETURN = 0x00008000
Global Const $OFN_NOTESTFILECREATE = 0x00010000
Global Const $OFN_NOVALIDATE = 0x00000100
Global Const $OFN_OVERWRITEPROMPT = 0x00000002
Global Const $OFN_PATHMUSTEXIST = 0x00000800
Global Const $OFN_READONLY = 0x00000001
Global Const $OFN_SHAREAWARE = 0x00004000
Global Const $OFN_SHOWHELP = 0x00000010
Global Const $OFN_EX_NOPLACESBAR = 0x00000001

;GetTextMetrics flags
Global Const $TMPF_FIXED_PITCH = 0x01
Global Const $TMPF_VECTOR = 0x02
Global Const $TMPF_TRUETYPE = 0x04
Global Const $TMPF_DEVICE = 0x08

;DuplicateHandle options
Global Const $DUPLICATE_CLOSE_SOURCE = 0x00000001
Global Const $DUPLICATE_SAME_ACCESS = 0x00000002
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_WinAPI_AttachConsole
;_WinAPI_AttachThreadInput
;_WinAPI_Beep
;_WinAPI_BitBlt
;_WinAPI_CallNextHookEx
;_WinAPI_CallWindowProc
;_WinAPI_ClientToScreen
;_WinAPI_CloseHandle
;_WinAPI_CombineRgn
;_WinAPI_CommDlgExtendedError
;_WinAPI_CopyIcon
;_WinAPI_CreateBitmap
;_WinAPI_CreateCompatibleBitmap
;_WinAPI_CreateCompatibleDC
;_WinAPI_CreateEvent
;_WinAPI_CreateFile
;_WinAPI_CreateFont
;_WinAPI_CreateFontIndirect
;_WinAPI_CreatePen
;_WinAPI_CreateProcess
;_WinAPI_CreateRectRgn
;_WinAPI_CreateRoundRectRgn
;_WinAPI_CreateSolidBitmap
;_WinAPI_CreateSolidBrush
;_WinAPI_CreateWindowEx
;_WinAPI_DefWindowProc
;_WinAPI_DeleteDC
;_WinAPI_DeleteObject
;_WinAPI_DestroyIcon
;_WinAPI_DestroyWindow
;_WinAPI_DrawEdge
;_WinAPI_DrawFrameControl
;_WinAPI_DrawIcon
;_WinAPI_DrawIconEx
;_WinAPI_DrawLine
;_WinAPI_DrawText
;_WinAPI_DuplicateHandle
;_WinAPI_EnableWindow
;_WinAPI_EnumDisplayDevices
;_WinAPI_EnumWindows
;_WinAPI_EnumWindowsPopup
;_WinAPI_EnumWindowsTop
;_WinAPI_ExpandEnvironmentStrings
;_WinAPI_ExtractIconEx
;_WinAPI_FatalAppExit
;_WinAPI_FillRect
;_WinAPI_FindExecutable
;_WinAPI_FindWindow
;_WinAPI_FlashWindow
;_WinAPI_FlashWindowEx
;_WinAPI_FloatToInt
;_WinAPI_FlushFileBuffers
;_WinAPI_FormatMessage
;_WinAPI_FrameRect
;_WinAPI_FreeLibrary
;_WinAPI_GetAncestor
;_WinAPI_GetAsyncKeyState
;_WinAPI_GetBkMode
;_WinAPI_GetClassName
;_WinAPI_GetClientHeight
;_WinAPI_GetClientWidth
;_WinAPI_GetClientRect
;_WinAPI_GetCurrentProcess
;_WinAPI_GetCurrentProcessID
;_WinAPI_GetCurrentThread
;_WinAPI_GetCurrentThreadId
;_WinAPI_GetCursorInfo
;_WinAPI_GetDC
;_WinAPI_GetDesktopWindow
;_WinAPI_GetDeviceCaps
;_WinAPI_GetDIBits
;_WinAPI_GetDlgCtrlID
;_WinAPI_GetDlgItem
;_WinAPI_GetFocus
;_WinAPI_GetForegroundWindow
;_WinAPI_GetGuiResources
;_WinAPI_GetIconInfo
;_WinAPI_GetFileSizeEx
;_WinAPI_GetLastErrorMessage
;_WinAPI_GetLayeredWindowAttributes
;_WinAPI_GetModuleHandle
;_WinAPI_GetMousePos
;_WinAPI_GetMousePosX
;_WinAPI_GetMousePosY
;_WinAPI_GetObject
;_WinAPI_GetOpenFileName
;_WinAPI_GetOverlappedResult
;_WinAPI_GetParent
;_WinAPI_GetProcessAffinityMask
;_WinAPI_GetSaveFileName
;_WinAPI_GetStockObject
;_WinAPI_GetStdHandle
;_WinAPI_GetSysColor
;_WinAPI_GetSysColorBrush
;_WinAPI_GetSystemMetrics
;_WinAPI_GetTextExtentPoint32
;_WinAPI_GetTextMetrics
;_WinAPI_GetWindow
;_WinAPI_GetWindowDC
;_WinAPI_GetWindowHeight
;_WinAPI_GetWindowLong
;_WinAPI_GetWindowPlacement
;_WinAPI_GetWindowRect
;_WinAPI_GetWindowRgn
;_WinAPI_GetWindowText
;_WinAPI_GetWindowThreadProcessId
;_WinAPI_GetWindowWidth
;_WinAPI_GetXYFromPoint
;_WinAPI_GlobalMemStatus
;_WinAPI_GUIDFromString
;_WinAPI_GUIDFromStringEx
;_WinAPI_HiWord
;_WinAPI_InProcess
;_WinAPI_IntToFloat
;_WinAPI_IsClassName
;_WinAPI_IsWindow
;_WinAPI_IsWindowVisible
;_WinAPI_InvalidateRect
;_WinAPI_LineTo
;_WinAPI_LoadBitmap
;_WinAPI_LoadImage
;_WinAPI_LoadLibrary
;_WinAPI_LoadLibraryEx
;_WinAPI_LoadShell32Icon
;_WinAPI_LoadString
;_WinAPI_LocalFree
;_WinAPI_LoWord
;_WinAPI_MAKELANGID
;_WinAPI_MAKELCID
;_WinAPI_MakeLong
;_WinAPI_MakeQWord
;_WinAPI_MessageBeep
;_WinAPI_Mouse_Event
;_WinAPI_MoveTo
;_WinAPI_MoveWindow
;_WinAPI_MsgBox
;_WinAPI_MulDiv
;_WinAPI_MultiByteToWideChar
;_WinAPI_MultiByteToWideCharEx
;_WinAPI_OpenProcess
;_WinAPI_PathFindOnPath
;_WinAPI_PointFromRect
;_WinAPI_PostMessage
;_WinAPI_PrimaryLangId
;_WinAPI_PtInRect
;_WinAPI_ReadFile
;_WinAPI_ReadProcessMemory
;_WinAPI_RectIsEmpty
;_WinAPI_RedrawWindow
;_WinAPI_RegisterWindowMessage
;_WinAPI_ReleaseCapture
;_WinAPI_ReleaseDC
;_WinAPI_ScreenToClient
;_WinAPI_SelectObject
;_WinAPI_SetBkColor
;_WinAPI_SetBkMode
;_WinAPI_SetCapture
;_WinAPI_SetCursor
;_WinAPI_SetDefaultPrinter
;_WinAPI_SetDIBits
;_WinAPI_SetEndOfFile
;_WinAPI_SetEvent
;_WinAPI_SetFilePointer
;_WinAPI_SetFocus
;_WinAPI_SetFont
;_WinAPI_SetHandleInformation
;_WinAPI_SetLayeredWindowAttributes
;_WinAPI_SetParent
;_WinAPI_SetProcessAffinityMask
;_WinAPI_SetSysColors
;_WinAPI_SetTextColor
;_WinAPI_SetWindowLong
;_WinAPI_SetWindowPlacement
;_WinAPI_SetWindowPos
;_WinAPI_SetWindowRgn
;_WinAPI_SetWindowsHookEx
;_WinAPI_SetWindowText
;_WinAPI_ShowCursor
;_WinAPI_ShowError
;_WinAPI_ShowMsg
;_WinAPI_ShowWindow
;_WinAPI_StringFromGUID
;_WinAPI_StringLenA
;_WinAPI_StringLenW
;_WinAPI_SubLangId
;_WinAPI_SystemParametersInfo
;_WinAPI_TwipsPerPixelX
;_WinAPI_TwipsPerPixelY
;_WinAPI_UnhookWindowsHookEx
;_WinAPI_UpdateLayeredWindow
;_WinAPI_UpdateWindow
;_WinAPI_WaitForInputIdle
;_WinAPI_WaitForMultipleObjects
;_WinAPI_WaitForSingleObject
;_WinAPI_WideCharToMultiByte
;_WinAPI_WindowFromPoint
;_WinAPI_WriteConsole
;_WinAPI_WriteFile
;_WinAPI_WriteProcessMemory
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;$tagCURSORINFO
;$tagDISPLAY_DEVICE
;$tagFLASHWINFO
;$tagICONINFO
;$tagMEMORYSTATUSEX
;__WinAPI_EnumWindowsAdd
;__WinAPI_EnumWindowsChild
;__WinAPI_EnumWindowsInit
;__WinAPI_ParseFileDialogPath
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagCURSORINFO
; Description ...: Contains global cursor information
; Fields ........: Size    - Specifies the size, in bytes, of the structure
;                  Flags   - Specifies the cursor state. This parameter can be one of the following values:
;                  |0               - The cursor is hidden
;                  |$CURSOR_SHOWING - The cursor is showing
;                  hCursor - Handle to the cursor
;                  X       - X position of the cursor, in screen coordinates
;                  Y       - Y position of the cursor, in screen coordinates
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagCURSORINFO = "dword Size;dword Flags;handle hCursor;" & $tagPOINT

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagDISPLAY_DEVICE
; Description ...: Receives information about the display device
; Fields ........: Size   - Specifies the size, in bytes, of the structure
;                  Name   - Either the adapter device or the monitor device
;                  String - Either a description of the display adapter or of the display monitor
;                  Flags  - Device state flags:
;                  |$DISPLAY_DEVICE_ATTACHED_TO_DESKTOP - The device is part of the desktop
;                  |$DISPLAY_DEVICE_MIRRORING_DRIVER    - Represents a pseudo device used to mirror drawing for remoting or other
;                  +purposes. An invisible pseudo monitor is associated with this device.
;                  |$DISPLAY_DEVICE_MODESPRUNED         - The device has more display modes than its output devices support
;                  |$DISPLAY_DEVICE_PRIMARY_DEVICE      - The primary desktop is on the device
;                  |$DISPLAY_DEVICE_REMOVABLE           - The device is removable; it cannot be the primary display
;                  |$DISPLAY_DEVICE_VGA_COMPATIBLE      - The device is VGA compatible.
;                  ID     - This is the Plug and Play identifier
;                  Key    - Reserved
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagDISPLAY_DEVICE = "dword Size;wchar Name[32];wchar String[128];dword Flags;wchar ID[128];wchar Key[128]"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagFLASHWINFO
; Description ...: Contains the flash status for a window and the number of times the system should flash the window
; Fields ........: Size    - The size of the structure, in bytes
;                  hWnd    - A handle to the window to be flashed. The window can be either opened or minimized.
;                  Flags   - The flash status. This parameter can be one or more of the following values:
;                  |$FLASHW_ALL       - Flash both the window caption and taskbar button
;                  |$FLASHW_CAPTION   - Flash the window caption
;                  |$FLASHW_STOP      - Stop flashing
;                  |$FLASHW_TIMER     - Flash continuously, until the $FLASHW_STOP flag is set
;                  |$FLASHW_TIMERNOFG - Flash continuously until the window comes to the foreground
;                  |$FLASHW_TRAY      - Flash the taskbar button
;                  Count   - The number of times to flash the window
;                  Timeout - The rate at which the window is to be flashed, in milliseconds
; Author ........: Paul Campbell (PaulIA)
; Remarks .......: Needs Constants.au3 for pre-defined constants
; ===============================================================================================================================
Global Const $tagFLASHWINFO = "uint Size;hwnd hWnd;dword Flags;uint Count;dword TimeOut"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagICONINFO
; Description ...: Contains information about an icon or a cursor
; Fields ........: Icon     - Specifies the contents of the structure:
;                  |True  - Icon
;                  |False - Cursor
;                  XHotSpot - Specifies the x-coordinate of a cursor's hot spot
;                  YHotSpot - Specifies the y-coordinate of the cursor's hot spot
;                  hMask    - Specifies the icon bitmask bitmap
;                  hColor   - Handle to the icon color bitmap
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagICONINFO = "bool Icon;dword XHotSpot;dword YHotSpot;handle hMask;handle hColor"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagMEMORYSTATUSEX
; Description ...: Contains information memory usage
; Fields ........: Length         - size of the structure, must be set before calling GlobalMemoryStatusEx
;                  MemoryLoad     -
;                  TotalPhys      -
;                  AvailPhys      -
;                  TotalPageFile  -
;                  AvailPageFile  -
;                  TotalVirtual   -
;                  AvailVirtual   -
;                  AvailExtendedVirtual   - Reserved
; Author ........: jpm
; Remarks .......:
; ===============================================================================================================================
Global Const $tagMEMORYSTATUSEX = "dword Length;dword MemoryLoad;" & _
		"uint64 TotalPhys;uint64 AvailPhys;uint64 TotalPageFile;uint64 AvailPageFile;" & _
		"uint64 TotalVirtual;uint64 AvailVirtual;uint64 AvailExtendedVirtual"

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_AttachConsole
; Description ...: Attaches the calling process to the console of the specified process
; Syntax.........: _WinAPI_AttachConsole([$iProcessID = -1])
; Parameters ....: $iProcessID  - Identifier of the process. Set to -1 to attach to the current process.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Requires Windows XP
; Related .......:
; Link ..........: @@MsdnLink@@ AttachConsole
; Example .......:
; ===============================================================================================================================
Func _WinAPI_AttachConsole($iProcessID = -1)
	Local $aResult = DllCall("kernel32.dll", "bool", "AttachConsole", "dword", $iProcessID)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_AttachConsole

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_AttachThreadInput
; Description ...: Attaches the input processing mechanism of one thread to that of another thread
; Syntax.........: _WinAPI_AttachThreadInput($iAttach, $iAttachTo, $fAttach)
; Parameters ....: $iAttach     - Identifier of the thread to be attached to another thread
;                  $iAttachTo   - Identifier of the thread to be attached to
;                  $fAttach     - Attachment mode:
;                  |True  - The threads are attached
;                  |False - The threads are detached
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ AttachThreadInput
; Example .......:
; ===============================================================================================================================
Func _WinAPI_AttachThreadInput($iAttach, $iAttachTo, $fAttach)
	Local $aResult = DllCall("user32.dll", "bool", "AttachThreadInput", "dword", $iAttach, "dword", $iAttachTo, "bool", $fAttach)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_AttachThreadInput

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_Beep
; Description ...: Generates simple tones on the speaker
; Syntax.........: _WinAPI_Beep($iFreq = 500, $iDuration = 1000)
; Parameters ....: $iFreq       - The frequency of the sound, in hertz.  This parameter must be in the range 37  through  32,767.
;                  +Windows Me/98/95: This parameter is ignored.
;                  $iDuration   - The duration of the sound, in milliseconds.  Windows Me/98/95:  This parameter is ignored.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Muting and volume control have no effect on Beep. You will still hear the tone.
; Related .......:
; Link ..........: @@MsdnLink@@ Beep
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_Beep($iFreq = 500, $iDuration = 1000)
	Local $aResult = DllCall("kernel32.dll", "bool", "Beep", "dword", $iFreq, "dword", $iDuration)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_Beep

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_BitBlt
; Description ...: Performs a bit-block transfer of color data
; Syntax.........: _WinAPI_BitBlt($hDestDC, $iXDest, $iYDest, $iWidth, $iHeight, $hSrcDC, $iXSrc, $iYSrc, $iROP)
; Parameters ....: $hDestDC     - Handle to the destination device context
;                  $iXDest      - X value of the upper-left corner of the destination rectangle
;                  $iYDest      - Y value of the upper-left corner of the destination rectangle
;                  $iWidth      - Width of the source and destination rectangles
;                  $iHeight     - Height of the source and destination rectangles
;                  $hSrcDC      - Handle to the source device context
;                  $iXSrc       - X value of the upper-left corner of the source rectangle
;                  $iYSrc       - Y value of the upper-left corner of the source rectangle
;                  $iROP        - Specifies a raster operation code.  These codes define  how  the  color  data  for  the  source
;                  +rectangle is to be combined with the color data for the destination rectangle to achieve the final color:
;                  |$BLACKNESS      - Fills the destination rectangle using the color associated with palette index 0
;                  |$CAPTUREBLT     - Includes any window that are layered on top of your window in the resulting image
;                  |$DSTINVERT      - Inverts the destination rectangle
;                  |$MERGECOPY      - Merges the color of the source rectangle with the brush currently  selected  in  hDest,  by
;                  +using the AND operator.
;                  |$MERGEPAINT     - Merges the color of the inverted source  rectangle  with  the  colors  of  the  destination
;                  +rectangle by using the OR operator.
;                  |$NOMIRRORBITMAP - Prevents the bitmap from being mirrored
;                  |$NOTSRCCOPY     - Copies the inverted source rectangle to the destination
;                  |$NOTSRCERASE    - Combines the colors of the source and destination rectangles by using the OR  operator  and
;                  +then inverts the resultant color.
;                  |$PATCOPY        - Copies the brush selected in hdcDest, into the destination bitmap
;                  |$PATINVERT      - Combines the colors of the brush currently selected  in  hDest,  with  the  colors  of  the
;                  +destination rectangle by using the XOR operator.
;                  |$PATPAINT       - Combines the colors of the brush currently selected  in  hDest,  with  the  colors  of  the
;                  +inverted source rectangle by using the OR operator.  The result of this operation is combined with the  color
;                  +of the destination rectangle by using the OR operator.
;                  |$SRCAND         - Combines the colors of the source and destination rectangles by using the AND operator
;                  |$SRCCOPY        - Copies the source rectangle directly to the destination rectangle
;                  |$SRCERASE       - Combines the inverted color of the destination rectangle with  the  colors  of  the  source
;                  +rectangle by using the AND operator.
;                  |$SRCINVERT      - Combines the colors of the source and destination rectangles by using the XOR operator
;                  |$SRCPAINT       - Combines the colors of the source and destination rectangles by using the OR operator
;                  |$WHITENESS      - Fills the destination rectangle using the color associated with index  1  in  the  physical
;                  +palette.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ BitBlt
; Example .......:
; ===============================================================================================================================
Func _WinAPI_BitBlt($hDestDC, $iXDest, $iYDest, $iWidth, $iHeight, $hSrcDC, $iXSrc, $iYSrc, $iROP)
	Local $aResult = DllCall("gdi32.dll", "bool", "BitBlt", "handle", $hDestDC, "int", $iXDest, "int", $iYDest, "int", $iWidth, "int", $iHeight, _
			"handle", $hSrcDC, "int", $iXSrc, "int", $iYSrc, "dword", $iROP)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_BitBlt

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CallNextHookEx
; Description ...: Passes the hook information to the next hook procedure in the current hook chain
; Syntax.........: _WinAPI_CallNextHookEx($hhk, $iCode, $wParam, $lParam)
; Parameters ....: $hhk - Windows 95/98/ME: Handle to the current hook. An application receives this handle as a result of a previous call to the _WinAPI_SetWindowsHookEx function.
;                  |Windows NT/XP/2003: Ignored
;                  $iCode - Specifies the hook code passed to the current hook procedure. The next hook procedure uses this code to determine how to process the hook information
;                  $wParam  - Specifies the wParam value passed to the current hook procedure.
;                  |The meaning of this parameter depends on the type of hook associated with the current hook chain
;                  $lParam - Specifies the lParam value passed to the current hook procedure.
;                  |The meaning of this parameter depends on the type of hook associated with the current hook chain
; Return values .: Success      - This value is returned by the next hook procedure in the chain
;                  Failure      - -1 and @error is set
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_SetWindowsHookEx, $tagKBDLLHOOKSTRUCT
; Link ..........: @@MsdnLink@@ CallNextHookEx
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_CallNextHookEx($hhk, $iCode, $wParam, $lParam)
	Local $aResult = DllCall("user32.dll", "lresult", "CallNextHookEx", "handle", $hhk, "int", $iCode, "wparam", $wParam, "lparam", $lParam)
	If @error Then Return SetError(@error, @extended, -1)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_CallNextHookEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CallWindowProc
; Description ...: Passes the hook information to the next hook procedure in the current hook chain
; Syntax.........: _WinAPI_CallWindowProc($lpPrevWndFunc, $hWnd, $Msg, $wParam, $lParam)
; Parameters ....: $lpPrevWndFunc - Pointer to the previous window procedure.
;                  |  If this value is obtained by calling the _WinAPI_GetWindowLong function with the $iIndex parameter set to $GWL_WNDPROC or $DWL_DLGPROC,
;                  |  it is actually either the address of a window or dialog box procedure, or a special internal value meaningful only to _WinAPI_CallWindowProc.
;                  $hWnd          - Handle to the window procedure to receive the message
;                  $Msg           - Specifies the message
;                  $wParam        - Specifies additional message-specific information. The contents of this parameter depend on the value of the Msg parameter
;                  $lParam        - Specifies additional message-specific information. The contents of this parameter depend on the value of the Msg parameter
; Return values .: Success      - The return value specifies the result of the message processing and depends on the message sent
;                  Failure      - -1 and @error is set
; Author ........: Siao
; Modified.......:
; Remarks .......: Use the _WinAPI_CallWindowProc function for window subclassing. Usually, all windows with the same class share one window procedure.
;                  A subclass is a window or set of windows with the same class whose messages are intercepted and processed by another window procedure
;                 (or procedures) before being passed to the window procedure of the class.
;+
;                 The _WinAPI_SetWindowLong function creates the subclass by changing the window procedure associated with a particular window, causing
;                 the system to call the new window procedure instead of the previous one. An application must pass any messages not processed by the
;                 new window procedure to the previous window procedure by calling _WinAPI_CallWindowProc. This allows the application to create a chain
;                 of window procedures
; Related .......: DllCallbackRegister, _WinAPI_SetWindowLong
; Link ..........: @@MsdnLink@@ CallWindowProc
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_CallWindowProc($lpPrevWndFunc, $hWnd, $Msg, $wParam, $lParam)
	Local $aResult = DllCall("user32.dll", "lresult", "CallWindowProc", "ptr", $lpPrevWndFunc, "hwnd", $hWnd, "uint", $Msg, "wparam", $wParam, "lparam", $lParam)
	If @error Then Return SetError(@error, @extended, -1)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_CallWindowProc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ClientToScreen
; Description ...: Converts the client coordinates of a specified point to screen coordinates
; Syntax.........: _WinAPI_ClientToScreen($hWnd, ByRef $tPoint)
; Parameters ....: $hWnd        - Identifies the window that will be used for the conversion
;                  $tPoint      - $tagPOINT structure that contains the client coordinates to be converted
; Return values .: Success      - $tagPOINT structure
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The function replaces the client coordinates in the  $tagPOINT  structure  with  the  screen  coordinates.  The
;                  screen coordinates are relative to the upper-left corner of the screen.
; Related .......: _WinAPI_ScreenToClient, $tagPOINT
; Link ..........: @@MsdnLink@@ ClientToScreen
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_ClientToScreen($hWnd, ByRef $tPoint)
	DllCall("user32.dll", "bool", "ClientToScreen", "hwnd", $hWnd, "struct*", $tPoint)
	Return SetError(@error, @extended, $tPoint)
EndFunc   ;==>_WinAPI_ClientToScreen

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CloseHandle
; Description ...: Closes an open object handle
; Syntax.........: _WinAPI_CloseHandle($hObject)
; Parameters ....: $hObject     - Handle of object to close
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_CreateFile, _WinAPI_FlushFileBuffers, _WinAPI_GetFileSizeEx, _WinAPI_ReadFile, _WinAPI_SetEndOfFile, _WinAPI_SetFilePointer, _WinAPI_WriteFile
; Link ..........: @@MsdnLink@@ CloseHandle
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_CloseHandle($hObject)
	Local $aResult = DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hObject)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_CloseHandle

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CombineRgn
; Description ...: Combines two regions and stores the result in a third region
; Syntax.........: _WinAPI_CombineRgn($hRgnDest, $hRgnSrc1, $hRgnSrc2, $iCombineMode)
; Parameters ....: $hRgnDest - Handle to a new region with dimensions defined by combining two other regions. (This region must exist before CombineRgn is called.)
;                  $hRgnSrc1 - Handle to the first of two regions to be combined.
;                  $hRgnSrc2 - Handle to the second of two regions to be combined.
;                  $iCombineMode - Specifies a mode indicating how the two regions will be combined. This parameter can be one of the following values.
;                  |RGN_AND - Creates the intersection of the two combined regions.
;                  |RGN_COPY - Creates a copy of the region identified by hrgnSrc1.
;                  |RGN_DIFF - Combines the parts of hrgnSrc1 that are not part of hrgnSrc2.
;                  |RGN_OR - Creates the union of two combined regions.
;                  |RGN_XOR - Creates the union of two combined regions except for any overlapping areas.
; Return values .: Success      - Specifies the type of the resulting region. It can be one of the following values.
;                  |NULLREGION - The region is empty.
;                  |SIMPLEREGION - The region is a single rectangle.
;                  |COMPLEXREGION - The region is more than a single rectangle.
;                  |ERRORREGION - No region is created.
;                  Failure      - 0
; Author ........: Zedna
; Modified.......:
; Remarks .......: The two regions are combined according to the specified mode.
;                  The three regions need not be distinct. For example, the hrgnSrc1 parameter can equal the hrgnDest parameter.
; Related .......: _WinAPI_CreateRectRgn, _WinAPI_CreateRoundRectRgn, _WinAPI_SetWindowRgn
; Link ..........: @@MsdnLink@@ CombineRgn
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_CombineRgn($hRgnDest, $hRgnSrc1, $hRgnSrc2, $iCombineMode)
	Local $aResult = DllCall("gdi32.dll", "int", "CombineRgn", "handle", $hRgnDest, "handle", $hRgnSrc1, "handle", $hRgnSrc2, "int", $iCombineMode)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_CombineRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CommDlgExtendedError
; Description ...: Returns a common dialog box error string. This string indicates the most recent error to occur during the execution of one of the common dialog box functions.
; Syntax.........: _WinAPI_CommDlgExtendedError()
; Parameters ....:
; Return values .: Success      - error string
;                  Failure       - 0
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Can return general error strings for any of the common dialog box functions.
; Related .......: _WinAPI_GetOpenFileName, _WinAPI_GetSaveFileName
; Link ..........: @@MsdnLink@@ CommDlgExtendedError
; Example .......:
; ===============================================================================================================================
Func _WinAPI_CommDlgExtendedError()
	Local Const $CDERR_DIALOGFAILURE = 0xFFFF
	Local Const $CDERR_FINDRESFAILURE = 0x06
	Local Const $CDERR_INITIALIZATION = 0x02
	Local Const $CDERR_LOADRESFAILURE = 0x07
	Local Const $CDERR_LOADSTRFAILURE = 0x05
	Local Const $CDERR_LOCKRESFAILURE = 0x08
	Local Const $CDERR_MEMALLOCFAILURE = 0x09
	Local Const $CDERR_MEMLOCKFAILURE = 0x0A
	Local Const $CDERR_NOHINSTANCE = 0x04
	Local Const $CDERR_NOHOOK = 0x0B
	Local Const $CDERR_NOTEMPLATE = 0x03
	Local Const $CDERR_REGISTERMSGFAIL = 0x0C
	Local Const $CDERR_STRUCTSIZE = 0x01
	Local Const $FNERR_BUFFERTOOSMALL = 0x3003
	Local Const $FNERR_INVALIDFILENAME = 0x3002
	Local Const $FNERR_SUBCLASSFAILURE = 0x3001
	Local $aResult = DllCall("comdlg32.dll", "dword", "CommDlgExtendedError")
	If @error Then Return SetError(@error, @extended, 0)
	Switch $aResult[0]
		Case $CDERR_DIALOGFAILURE
			Return SetError($aResult[0], 0, "The dialog box could not be created." & @LF & _
					"The common dialog box function's call to the DialogBox function failed." & @LF & _
					"For example, this error occurs if the common dialog box call specifies an invalid window handle.")
		Case $CDERR_FINDRESFAILURE
			Return SetError($aResult[0], 0, "The common dialog box function failed to find a specified resource.")
		Case $CDERR_INITIALIZATION
			Return SetError($aResult[0], 0, "The common dialog box function failed during initialization." & @LF & "This error often occurs when sufficient memory is not available.")
		Case $CDERR_LOADRESFAILURE
			Return SetError($aResult[0], 0, "The common dialog box function failed to load a specified resource.")
		Case $CDERR_LOADSTRFAILURE
			Return SetError($aResult[0], 0, "The common dialog box function failed to load a specified string.")
		Case $CDERR_LOCKRESFAILURE
			Return SetError($aResult[0], 0, "The common dialog box function failed to lock a specified resource.")
		Case $CDERR_MEMALLOCFAILURE
			Return SetError($aResult[0], 0, "The common dialog box function was unable to allocate memory for internal structures.")
		Case $CDERR_MEMLOCKFAILURE
			Return SetError($aResult[0], 0, "The common dialog box function was unable to lock the memory associated with a handle.")
		Case $CDERR_NOHINSTANCE
			Return SetError($aResult[0], 0, "The ENABLETEMPLATE flag was set in the Flags member of the initialization structure for the corresponding common dialog box," & @LF & _
					"but you failed to provide a corresponding instance handle.")
		Case $CDERR_NOHOOK
			Return SetError($aResult[0], 0, "The ENABLEHOOK flag was set in the Flags member of the initialization structure for the corresponding common dialog box," & @LF & _
					"but you failed to provide a pointer to a corresponding hook procedure.")
		Case $CDERR_NOTEMPLATE
			Return SetError($aResult[0], 0, "The ENABLETEMPLATE flag was set in the Flags member of the initialization structure for the corresponding common dialog box," & @LF & _
					"but you failed to provide a corresponding template.")
		Case $CDERR_REGISTERMSGFAIL
			Return SetError($aResult[0], 0, "The RegisterWindowMessage function returned an error code when it was called by the common dialog box function.")
		Case $CDERR_STRUCTSIZE
			Return SetError($aResult[0], 0, "The lStructSize member of the initialization structure for the corresponding common dialog box is invalid")
		Case $FNERR_BUFFERTOOSMALL
			Return SetError($aResult[0], 0, "The buffer pointed to by the lpstrFile member of the OPENFILENAME structure is too small for the file name specified by the user." & @LF & _
					"The first two bytes of the lpstrFile buffer contain an integer value specifying the size, in TCHARs, required to receive the full name.")
		Case $FNERR_INVALIDFILENAME
			Return SetError($aResult[0], 0, "A file name is invalid.")
		Case $FNERR_SUBCLASSFAILURE
			Return SetError($aResult[0], 0, "An attempt to subclass a list box failed because sufficient memory was not available.")
	EndSwitch
	Return Hex($aResult[0])
EndFunc   ;==>_WinAPI_CommDlgExtendedError

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CopyIcon
; Description ...: Copies the specified icon from another module
; Syntax.........: _WinAPI_CopyIcon($hIcon)
; Parameters ....: $hIcon       - Handle to the icon to be copied
; Return values .: Success      - The handle to the duplicate icon
;                  Failure       - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The CopyIcon function enables an application or DLL to get its own handle to an icon owned by another  module.
;                  If the other module is freed, the application icon will still be able to use the icon.  Before  closing,  call
;                  the _WinAPI_DestroyIcon function to free any system resources associated with the icon.
; Related .......: _WinAPI_DestroyIcon
; Link ..........: @@MsdnLink@@ CopyIcon
; Example .......:
; ===============================================================================================================================
Func _WinAPI_CopyIcon($hIcon)
	Local $aResult = DllCall("user32.dll", "handle", "CopyIcon", "handle", $hIcon)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_CopyIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateBitmap
; Description ...: Creates a bitmap with the specified width, height, and color format
; Syntax.........: _WinAPI_CreateBitmap($iWidth, $iHeight[, $iPlanes = 1[, $iBitsPerPel = 1[, $pBits = 0]]])
; Parameters ....: $iWidth      - Specifies the bitmap width, in pixels
;                  $iHeight     - Specifies the bitmap height, in pixels
;                  $iPlanes     - Specifies the number of color planes used by the device
;                  $iBitsPerPel - Specifies the number of bits required to identify the color of a single pixel
;                  $pBits       - Pointer to an array of color data used to set the colors in a rectangle of  pixels.  Each  scan
;                  +line in the rectangle must be word aligned (scan lines that are not word aligned must be padded with  zeros).
;                  +If this parameter is 0, the contents of the new bitmap is undefined.
; Return values .: Success      - The handle to a bitmap
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ CreateBitmap
; Example .......:
; ===============================================================================================================================
Func _WinAPI_CreateBitmap($iWidth, $iHeight, $iPlanes = 1, $iBitsPerPel = 1, $pBits = 0)
	Local $aResult = DllCall("gdi32.dll", "handle", "CreateBitmap", "int", $iWidth, "int", $iHeight, "uint", $iPlanes, "uint", $iBitsPerPel, "ptr", $pBits)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_CreateBitmap

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateCompatibleBitmap
; Description ...: Creates a bitmap compatible with the specified device context
; Syntax.........: _WinAPI_CreateCompatibleBitmap($hDC, $iWidth, $iHeight)
; Parameters ....: $hDC         - Identifies a device context
;                  $iWidth      - Specifies the bitmap width, in pixels
;                  $iHeight     - Specifies the bitmap height, in pixels
; Return values .: Success      - The handle to the bitmap
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: When you no longer need the bitmap, call the _WinAPI_DeleteObject function to delete it
; Related .......: _WinAPI_DeleteObject, _WinAPI_CreateSolidBitmap
; Link ..........: @@MsdnLink@@ CreateCompatibleBitmap
; Example .......:
; ===============================================================================================================================
Func _WinAPI_CreateCompatibleBitmap($hDC, $iWidth, $iHeight)
	Local $aResult = DllCall("gdi32.dll", "handle", "CreateCompatibleBitmap", "handle", $hDC, "int", $iWidth, "int", $iHeight)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_CreateCompatibleBitmap

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateCompatibleDC
; Description ...: Creates a memory device context compatible with the specified device
; Syntax.........: _WinAPI_CreateCompatibleDC($hDC)
; Parameters ....: $hDC         - Handle to an existing DC. If this handle is 0, the function creates a memory DC compatible with
;                  +the application's current screen.
; Return values .: Success      - Handle to a memory DC
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: When you no longer need the memory DC, call the _WinAPI_DeleteDC function
; Related .......: _WinAPI_DeleteDC
; Link ..........: @@MsdnLink@@ CreateCompatibleDC
; Example .......:
; ===============================================================================================================================
Func _WinAPI_CreateCompatibleDC($hDC)
	Local $aResult = DllCall("gdi32.dll", "handle", "CreateCompatibleDC", "handle", $hDC)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_CreateCompatibleDC

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateEvent
; Description ...: Creates or opens a named or unnamed event object
; Syntax.........: _WinAPI_CreateEvent([$pAttributes = 0[, $fManualReset = True[, $fInitialState = True[, $sName = ""]]]])
; Parameters ....: $pAttributes - Pointer to a $tagSECURITY_ATTRIBUTES structure.  If 0, the  handle cannot be inherited by  child
;                  +processes.  The Descriptor member of the structure specifies a security descriptor  for  the  new  event.  If
;                  +pAttributes is 0, the event gets a default security descriptor.  The ACLs in the default security  descriptor
;                  +for an event come from the primary or impersonation token of the creator.
;                  $fManualReset - If True, the function creates a manual-reset event object,  which  requires  the  use  of  the
;                  +ResetEvent function to set the event state to nonsignaled. If False, the function creates an auto-reset event
;                  +object and system automatically resets the event state to nonsignaled after a single waiting thread has  been
;                  +released.
;                  $fInitialState - If True, the initial state of the event object is signaled; otherwise, it is nonsignaled
;                  $sName        - The name of the event object. Name comparison is case sensitive.  If sName matches the name of
;                  +an existing named event object, this function requests the EVENT_ALL_ACCESS access right.  In this  case  the
;                  +fManualReset and fInitialState parameters are ignored because they have already  been  set  by  the  creating
;                  +process. If the pAttributes parameter is not 0, it determines whether the handle can be  inherited,  but  its
;                  +security-descriptor member is ignored. If Name is blank, the event object is created without a name.
; Return values .: Success      - The handle to the event object.  If the named event object existed before the function call the
;                  +function returns a handle to the existing object and GetLastError returns ERROR_ALREADY_EXISTS.
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......: $tagSECURITY_ATTRIBUTES
; Link ..........: @@MsdnLink@@ CreateEvent
; Example .......:
; ===============================================================================================================================
Func _WinAPI_CreateEvent($pAttributes = 0, $fManualReset = True, $fInitialState = True, $sName = "")
	Local $sNameType = "wstr"
	If $sName = "" Then
		$sName = 0
		$sNameType = "ptr"
	EndIf
	Local $aResult = DllCall("kernel32.dll", "handle", "CreateEventW", "ptr", $pAttributes, "bool", $fManualReset, "bool", $fInitialState, $sNameType, $sName)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_CreateEvent

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateFile
; Description ...: Creates or opens a file or other device
; Syntax.........: _WinAPI_CreateFile($sFileName, $iCreation[, $iAccess = 4[, $iShare = 0[, $iAttributes = 0[, $pSecurity = 0]]]])
; Parameters ....: $sFileName   - Name of an object to create or open
;                  $iCreation   - Action to take on files that exist and do not exist:
;                  |0 - Creates a new file. The function fails if the file exists
;                  |1 - Creates a new file. If a file exists, it is overwritten
;                  |2 - Opens a file. The function fails if the file does not exist
;                  |3 - Opens a file. If the file does not exist, the function creates the file
;                  |4 - Opens a file and truncates it so that its size is 0 bytes.  The function fails if the file does not exist.
;                  $iAccess     - Access to the object:
;                  |1 - Execute
;                  |2 - Read
;                  |4 - Write
;                  $iShare      - Sharing mode of an object:
;                  |1 - Delete
;                  |2 - Read
;                  |4 - Write
;                  $iAttributes - The file attributes:
;                  |1 - File should be archived
;                  |2 - File is hidden
;                  |4 - File is read only
;                  |8 - File is part of or used exclusively by an operating system.
;                  $pSecurity   - Pointer to a $tagSECURITY_ATTRIBUTES structure that determines if the  returned  handle  can  be
;                  +inherited by child processes. If pSecurity is 0, the handle cannot be inherited.
; Return values .: Success      - The open handle to a specified file
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......: $tagSECURITY_ATTRIBUTES, _WinAPI_CloseHandle, _WinAPI_FlushFileBuffers, _WinAPI_GetFileSizeEx, _WinAPI_ReadFile, _WinAPI_SetEndOfFile, _WinAPI_SetFilePointer, _WinAPI_WriteFile
; Link ..........: @@MsdnLink@@ CreateFile
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_CreateFile($sFileName, $iCreation, $iAccess = 4, $iShare = 0, $iAttributes = 0, $pSecurity = 0)
	Local $iDA = 0, $iSM = 0, $iCD = 0, $iFA = 0

	If BitAND($iAccess, 1) <> 0 Then $iDA = BitOR($iDA, $GENERIC_EXECUTE)
	If BitAND($iAccess, 2) <> 0 Then $iDA = BitOR($iDA, $GENERIC_READ)
	If BitAND($iAccess, 4) <> 0 Then $iDA = BitOR($iDA, $GENERIC_WRITE)

	If BitAND($iShare, 1) <> 0 Then $iSM = BitOR($iSM, $FILE_SHARE_DELETE)
	If BitAND($iShare, 2) <> 0 Then $iSM = BitOR($iSM, $FILE_SHARE_READ)
	If BitAND($iShare, 4) <> 0 Then $iSM = BitOR($iSM, $FILE_SHARE_WRITE)

	Switch $iCreation
		Case 0
			$iCD = $CREATE_NEW
		Case 1
			$iCD = $CREATE_ALWAYS
		Case 2
			$iCD = $OPEN_EXISTING
		Case 3
			$iCD = $OPEN_ALWAYS
		Case 4
			$iCD = $TRUNCATE_EXISTING
	EndSwitch

	If BitAND($iAttributes, 1) <> 0 Then $iFA = BitOR($iFA, $FILE_ATTRIBUTE_ARCHIVE)
	If BitAND($iAttributes, 2) <> 0 Then $iFA = BitOR($iFA, $FILE_ATTRIBUTE_HIDDEN)
	If BitAND($iAttributes, 4) <> 0 Then $iFA = BitOR($iFA, $FILE_ATTRIBUTE_READONLY)
	If BitAND($iAttributes, 8) <> 0 Then $iFA = BitOR($iFA, $FILE_ATTRIBUTE_SYSTEM)

	Local $aResult = DllCall("kernel32.dll", "handle", "CreateFileW", "wstr", $sFileName, "dword", $iDA, "dword", $iSM, "ptr", $pSecurity, "dword", $iCD, "dword", $iFA, "ptr", 0)
	If @error Or $aResult[0] = Ptr(-1) Then Return SetError(@error, @extended, 0) ; INVALID_HANDLE_VALUE
	Return $aResult[0]
EndFunc   ;==>_WinAPI_CreateFile

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateFont
; Description ...: Creates a logical font with the specified characteristics
; Syntax.........: _WinAPI_CreateFont($nHeight, $nWidth[, $nEscape = 0[, $nOrientn = 0[, $fnWeight = $FW_NORMAL[, $bItalic = False[, $bUnderline = False[, $bStrikeout = False[, $nCharset = $DEFAULT_CHARSET[, $nOutputPrec = $OUT_DEFAULT_PRECIS[, $nClipPrec = $CLIP_DEFAULT_PRECIS[, $nQuality = $DEFAULT_QUALITY[, $nPitch = 0[, $szFace = 'Arial']]]]]]]]]]]])
; Parameters ....: $nHeight            - height of font
;                  $nWidth             - average character width
;                  $nEscape            - angle of escapement
;                  $nOrientn           - base-line orientation angle
;                  $fnWeight           - font weight, The following values are defined for convenience:
;                  |$FW_DONTCARE   - 0
;                  |$FW_THIN       - 100
;                  |$FW_EXTRALIGHT - 200
;                  |$FW_LIGHT      - 300
;                  |$FW_NORMAL     - 400
;                  |$FW_MEDIUM     - 500
;                  |$FW_SEMIBOLD   - 600
;                  |$FW_BOLD       - 700
;                  |$FW_EXTRABOLD  - 800
;                  |$FW_HEAVY      - 900
;                  $bItalic            - italic attribute option
;                  $bUnderline         - underline attribute option
;                  $bStrikeout         - strikeout attribute option
;                  $nCharset           - Specifies the character set. The following values are predefined:
;                  |$ANSI_CHARSET        - 0
;                  |$BALTIC_CHARSET      - 186
;                  |$CHINESEBIG5_CHARSET - 136
;                  |$DEFAULT_CHARSET     - 1
;                  |$EASTEUROPE_CHARSET  - 238
;                  |$GB2312_CHARSET      - 134
;                  |$GREEK_CHARSET       - 161
;                  |$HANGEUL_CHARSET     - 129
;                  |$MAC_CHARSET         - 77
;                  |$OEM_CHARSET         - 255
;                  |$RUSSIAN_CHARSET     - 204
;                  |$SHIFTJIS_CHARSET    - 128
;                  |$SYMBOL_CHARSET      - 2
;                  |$TURKISH_CHARSET     - 162
;                  |$VIETNAMESE_CHARSET  - 163
;                  $nOutputPrec        - Specifies the output precision, It can be one of the following values:
;                  |$OUT_CHARACTER_PRECIS - Not used
;                  |$OUT_DEFAULT_PRECIS   - Specifies the default font mapper behavior
;                  |$OUT_DEVICE_PRECIS    - Instructs the font mapper to choose a Device font when the system contains multiple fonts with the same name
;                  |$OUT_OUTLINE_PRECIS   - Windows NT/2000/XP: This value instructs the font mapper to choose from TrueType and other outline-based fonts
;                  |$OUT_PS_ONLY_PRECIS   - Windows 2000/XP: Instructs the font mapper to choose from only PostScript fonts.
;                  +If there are no PostScript fonts installed in the system, the font mapper returns to default behavior
;                  |$OUT_RASTER_PRECIS    - Instructs the font mapper to choose a raster font when the system contains multiple fonts with the same name
;                  |$OUT_STRING_PRECIS    - This value is not used by the font mapper, but it is returned when raster fonts are enumerated
;                  |$OUT_STROKE_PRECIS    - Windows NT/2000/XP: This value is not used by the font mapper, but it is returned when TrueType,
;                  +other outline-based fonts, and vector fonts are enumerated
;                  |$OUT_TT_ONLY_PRECIS   - Instructs the font mapper to choose from only TrueType fonts. If there are no TrueType fonts installed in the system,
;                  +the font mapper returns to default behavior
;                  |$OUT_TT_PRECIS        - Instructs the font mapper to choose a TrueType font when the system contains multiple fonts with the same name
;                  $nClipPrec             - Specifies the clipping precision, It can be one or more of the following values:
;                  |$CLIP_CHARACTER_PRECIS - Not used
;                  |$CLIP_DEFAULT_PRECIS   - Specifies default clipping behavior
;                  |$CLIP_EMBEDDED         - You must specify this flag to use an embedded read-only font
;                  |$CLIP_LH_ANGLES        - When this value is used, the rotation for all fonts depends on whether the orientation of the coordinate system is left-handed or right-handed.
;                  |If not used, device fonts always rotate counterclockwise, but the rotation of other fonts is dependent on the orientation of the coordinate system.
;                  |$CLIP_MASK             - Not used
;                  |$CLIP_STROKE_PRECIS    - Not used by the font mapper, but is returned when raster, vector, or TrueType fonts are enumerated
;                  |Windows NT/2000/XP: For compatibility, this value is always returned when enumerating fonts
;                  |$CLIP_TT_ALWAYS        - Not used
;                  $nQuality               - Specifies the output quality, It can be one of the following values:
;                  |$ANTIALIASED_QUALITY    - Windows NT 4.0 and later: Font is antialiased, or smoothed, if the font supports it and the size of the font is not too small or too large.
;                  |Windows 95 with Plus!, Windows 98/Me: The display must greater than 8-bit color, it must be a single plane device, it cannot be a palette display, and it cannot be in a multiple display monitor setup.
;                  |In addition, you must select a TrueType font into a screen DC prior to using it in a DIBSection, otherwise antialiasing does not happen
;                  |$DEFAULT_QUALITY        - Appearance of the font does not matter
;                  |$DRAFT_QUALITY          - Appearance of the font is less important than when the PROOF_QUALITY value is used.
;                  |For GDI raster fonts, scaling is enabled, which means that more font sizes are available, but the quality may be lower.
;                  |Bold, italic, underline, and strikeout fonts are synthesized, if necessary
;                  |$NONANTIALIASED_QUALITY - Windows 95 with Plus!, Windows 98/Me, Windows NT 4.0 and later: Font is never antialiased, that is, font smoothing is not done
;                  |$PROOF_QUALITY          - Character quality of the font is more important than exact matching of the logical-font attributes.
;                  |For GDI raster fonts, scaling is disabled and the font closest in size is chosen.
;                  |Although the chosen font size may not be mapped exactly when PROOF_QUALITY is used, the quality of the font is high and there is no distortion of appearance.
;                  |Bold, italic, underline, and strikeout fonts are synthesized, if necessary
;                  $nPitch             - Specifies the pitch and family of the font. The two low-order bits specify the pitch of the font and can be one of the following values:
;                  +$DEFAULT_PITCH, $FIXED_PITCH, $VARIABLE_PITCH
;                  |The four high-order bits specify the font family and can be one of the following values:
;                  |$FF_DECORATIVE  - Novelty fonts. Old English is an example
;                  |$FF_DONTCARE    - Use default font
;                  |$FF_MODERN      - Fonts with constant stroke width, with or without serifs. Pica, Elite, and Courier New are examples
;                  |$FF_ROMAN       - Fonts with variable stroke width and with serifs. MS Serif is an example
;                  |$FF_SCRIPT      - Fonts designed to look like handwriting. Script and Cursive are examples
;                  |$FF_SWISS       - Fonts with variable stroke width and without serifs. MS Sans Serif is an example
;                  $szFace             - typeface name
; Return values .: Success      - The handle to a logical font
;                  Failure      - 0
; Author ........: Gary Frost
; Modified.......: jpm
; Remarks .......: When you no longer need the font, call the _WinAPI_DeleteObject function to delete it
;                  Needs FontConstants.au3 for pre-defined constants.
; Related .......:
; Link ..........: @@MsdnLink@@ CreateFont
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_CreateFont($nHeight, $nWidth, $nEscape = 0, $nOrientn = 0, $fnWeight = $__WINAPICONSTANT_FW_NORMAL, $bItalic = False, $bUnderline = False, $bStrikeout = False, $nCharset = $__WINAPICONSTANT_DEFAULT_CHARSET, $nOutputPrec = $__WINAPICONSTANT_OUT_DEFAULT_PRECIS, $nClipPrec = $__WINAPICONSTANT_CLIP_DEFAULT_PRECIS, $nQuality = $__WINAPICONSTANT_DEFAULT_QUALITY, $nPitch = 0, $szFace = 'Arial')
	Local $aResult = DllCall("gdi32.dll", "handle", "CreateFontW", "int", $nHeight, "int", $nWidth, "int", $nEscape, "int", $nOrientn, _
			"int", $fnWeight, "dword", $bItalic, "dword", $bUnderline, "dword", $bStrikeout, "dword", $nCharset, "dword", $nOutputPrec, _
			"dword", $nClipPrec, "dword", $nQuality, "dword", $nPitch, "wstr", $szFace)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_CreateFont

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateFontIndirect
; Description ...: Creates a logical font that has specific characteristics
; Syntax.........: _WinAPI_CreateFontIndirect($tLogFont)
; Parameters ....: $tLogFont    - $tagLOGFONT structure that defines the characteristics of the logical font
; Return values .: Success      - Handle to a logical font
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function creates a logical font with the characteristics specified in the $tagLOGFONT structure. When this
;                  font is selected by using the SelectObject function, GDI's font mapper attempts to match the logical font with
;                  an existing physical font. If it fails to find an exact match it provides an alternative whose characteristics
;                  match as many of the requested characteristics as possible.
; Related .......: $tagLOGFONT
; Link ..........: @@MsdnLink@@ CreateFontIndirect
; Example .......:
; ===============================================================================================================================
Func _WinAPI_CreateFontIndirect($tLogFont)
	Local $aResult = DllCall("gdi32.dll", "handle", "CreateFontIndirectW", "struct*", $tLogFont)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_CreateFontIndirect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreatePen
; Description ...: Creates a logical pen that has the specified style, width, and color.
; Syntax.........: _WinAPI_CreatePen($iPenStyle, $iWidth, $nColor)
; Parameters ....: $iPenStyle - Specifies the pen style. It can be any one of the following values.
;                  |PS_SOLID - The pen is solid.
;                  |PS_DASH - The pen is dashed. This style is valid only when the pen width is one or less in device units.
;                  |PS_DOT - The pen is dotted. This style is valid only when the pen width is one or less in device units.
;                  |PS_DASHDOT - The pen has alternating dashes and dots. This style is valid only when the pen width is one or less in device units.
;                  |PS_DASHDOTDOT - The pen has alternating dashes and double dots. This style is valid only when the pen width is one or less in device units.
;                  |PS_NULL - The pen is invisible.
;                  |PS_INSIDEFRAME - The pen is solid. When this pen is used in any GDI drawing function that takes a bounding rectangle, the dimensions of the figure are shrunk so that it fits entirely in the bounding rectangle, taking into account the width of the pen. This applies only to geometric pens.
;                  $iWidth - Specifies the width of the pen, in logical units.
;                  CreatePen returns a pen with the specified width bit with the PS_SOLID style if you specify a width greater than one for the following styles: PS_DASH, PS_DOT, PS_DASHDOT, PS_DASHDOTDOT.
;                  If nWidth is zero, the pen is a single pixel wide, regardless of the current transformation.
;                  $nColor - Specifies the color of the pen (BGR)
; Return values .: Success      - HPEN Value that identifies a logical pen
;                  Failure      - 0
; Author ........: Zedna
; Modified.......:
; Remarks .......: The pen can subsequently be selected into a device context and used to draw lines and curves.
;                  After an application creates a logical pen, it can select that pen into a device context by calling the SelectObject function. After a pen is selected into a device context, it can be used to draw lines and curves.
;                  If the value specified by the nWidth parameter is zero, a line drawn with the created pen always is a single pixel wide regardless of the current transformation.
;                  If the value specified by nWidth is greater than 1, the fnPenStyle parameter must be PS_NULL, PS_SOLID, or PS_INSIDEFRAME.
;                  When you no longer need the pen, call the DeleteObject function to delete it.
; Related .......: _WinAPI_MoveTo, _WinAPI_LineTo, _WinAPI_SelectObject, _WinAPI_DeleteObject, _WinAPI_DrawLine, _WinAPI_GetBkMode, _WinAPI_SetBkMode
; Link ..........: @@MsdnLink@@ CreatePen
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_CreatePen($iPenStyle, $iWidth, $nColor)
	Local $aResult = DllCall("gdi32.dll", "handle", "CreatePen", "int", $iPenStyle, "int", $iWidth, "dword", $nColor)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_CreatePen

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateProcess
; Description ...: Creates a new process and its primary thread
; Syntax.........: _WinAPI_CreateProcess($sAppName, $sCommand, $pSecurity, $pThread, $fInherit, $iFlags, $pEnviron, $sDir, $pStartupInfo, $pProcess)
; Parameters ....: $sAppName    - The name of the module to be executed
;                  $sCommand    - The command line to be executed
;                  $pSecurity   - Pointer to $tagSECURITY_ATTRIBUTES structure that determines whether the returned handle can  be
;                  +inherited by child processes.
;                  $pThread     - Pointer to $tagSECURITY_ATTRIBUTES structure that determines whether the returned handle can  be
;                  +inherited by child processes.
;                  $fInherit    - If True, each inheritable handle in the calling process is inherited by the new process
;                  $iFlags      - Flags that control the priority class and creation of the process
;                  $pEnviron    - Pointer to the environment block for the new process
;                  $sDir        - The full path to the current directory for the process
;                  $pStartupInfo - Pointer to a $tagSTARTUPINFO structure
;                  $pProcess    - Pointer to a $tagPROCESS_INFORMATION structure
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......: $tagSECURITY_ATTRIBUTES, $tagSTARTUPINFO, $tagPROCESS_INFORMATION
; Link ..........: @@MsdnLink@@ CreateProcess
; Example .......:
; ===============================================================================================================================
Func _WinAPI_CreateProcess($sAppName, $sCommand, $pSecurity, $pThread, $fInherit, $iFlags, $pEnviron, $sDir, $pStartupInfo, $pProcess)
	Local $tCommand = 0
	Local $sAppNameType = "wstr", $sDirType = "wstr"

	If $sAppName = "" Then
		$sAppNameType = "ptr"
		$sAppName = 0
	EndIf
	If $sCommand <> "" Then
		; must be MAX_PATH characters, can be updated by CreateProcessW
		$tCommand = DllStructCreate("wchar Text[" & 260 + 1 & "]")
		DllStructSetData($tCommand, "Text", $sCommand)
	EndIf
	If $sDir = "" Then
		$sDirType = "ptr"
		$sDir = 0
	EndIf
	Local $aResult = DllCall("kernel32.dll", "bool", "CreateProcessW", $sAppNameType, $sAppName, "struct*", $tCommand, "ptr", $pSecurity, "ptr", $pThread, _
			"bool", $fInherit, "dword", $iFlags, "ptr", $pEnviron, $sDirType, $sDir, "ptr", $pStartupInfo, "ptr", $pProcess)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_CreateProcess

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateRectRgn
; Description ...: Creates a rectangular region
; Syntax.........: _WinAPI_CreateRectRgn($iLeftRect, $iTopRect, $iRightRect, $iBottomRect)
; Parameters ....: $iLeftRect - X-coordinate of the upper-left corner of the region
;                  $iTopRect - Y-coordinate of the upper-left corner of the region
;                  $iRightRect - X-coordinate of the lower-right corner of the region
;                  $iBottomRect - Y-coordinate of the lower-right corner of the region
; Return values .: Success      - Returns the handle to the region
;                  Failure      - 0
; Author ........: Zedna
; Modified.......:
; Remarks .......: When you no longer need the HRGN object call the _WinAPI_DeleteObject function to delete it.
;                  Region coordinates are represented as 27-bit signed integers.
;                  The region will be exclusive of the bottom and right edges.
; Related .......: _WinAPI_CreateRoundRectRgn, _WinAPI_SetWindowRgn, _WinAPI_DeleteObject, _WinAPI_CombineRgn
; Link ..........: @@MsdnLink@@ CreateRectRgn
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_CreateRectRgn($iLeftRect, $iTopRect, $iRightRect, $iBottomRect)
	Local $aResult = DllCall("gdi32.dll", "handle", "CreateRectRgn", "int", $iLeftRect, "int", $iTopRect, "int", $iRightRect, "int", $iBottomRect)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_CreateRectRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateRoundRectRgn
; Description ...: Creates a rectangular region with rounded corners
; Syntax.........: _WinAPI_CreateRoundRectRgn($iLeftRect, $iTopRect, $iRightRect, $iBottomRect, $iWidthEllipse, $iHeightEllipse)
; Parameters ....: $iLeftRect - X-coordinate of the upper-left corner of the region
;                  $iTopRect - Y-coordinate of the upper-left corner of the region
;                  $iRightRect - X-coordinate of the lower-right corner of the region
;                  $iBottomRect - Y-coordinate of the lower-right corner of the region
;                  $iWidthEllipse - Width of the ellipse used to create the rounded corners
;                  $iHeightEllipse - Height of the ellipse used to create the rounded corners
; Return values .: Success      - Returns the handle to the region
;                  Failure      - 0
; Author ........: Zedna
; Modified.......:
; Remarks .......: When you no longer need the HRGN object call the _WinAPI_DeleteObject function to delete it.
;                  Region coordinates are represented as 27-bit signed integers.
; Related .......: _WinAPI_CreateRectRgn, _WinAPI_SetWindowRgn, _WinAPI_DeleteObject, _WinAPI_CombineRgn
; Link ..........: @@MsdnLink@@ CreateRoundRectRgn
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_CreateRoundRectRgn($iLeftRect, $iTopRect, $iRightRect, $iBottomRect, $iWidthEllipse, $iHeightEllipse)
	Local $aResult = DllCall("gdi32.dll", "handle", "CreateRoundRectRgn", "int", $iLeftRect, "int", $iTopRect, "int", $iRightRect, "int", $iBottomRect, _
			"int", $iWidthEllipse, "int", $iHeightEllipse)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_CreateRoundRectRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateSolidBitmap
; Description ...: Creates a solid color bitmap
; Syntax.........: _WinAPI_CreateSolidBitmap($hWnd, $iColor, $iWidth, $iHeight [, $bRGB = 1])
; Parameters ....: $hWnd        - Handle to the window where the bitmap will be displayed
;                  $iColor      - The color of the bitmap, stated in RGB
;                  $iWidth      - The width of the bitmap
;                  $iHeight     - The height of the bitmap
;                  $bRGB        - If True converts to COLOREF (0x00bbggrr)
; Return values .: Success      - Handle to the bitmap
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (Release DC), Yashied (rewritten)
; Remarks .......:
; Related .......: _WinAPI_CreateCompatibleBitmap
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_CreateSolidBitmap($hWnd, $iColor, $iWidth, $iHeight, $bRGB = 1)
	Local $hDC = _WinAPI_GetDC($hWnd)
	Local $hDestDC = _WinAPI_CreateCompatibleDC($hDC)
	Local $hBitmap = _WinAPI_CreateCompatibleBitmap($hDC, $iWidth, $iHeight)
	Local $hOld = _WinAPI_SelectObject($hDestDC, $hBitmap)
	Local $tRect = DllStructCreate($tagRECT)
	DllStructSetData($tRect, 1, 0)
	DllStructSetData($tRect, 2, 0)
	DllStructSetData($tRect, 3, $iWidth)
	DllStructSetData($tRect, 4, $iHeight)
	If $bRGB Then
		$iColor = BitOR(BitAND($iColor, 0x00FF00), BitShift(BitAND($iColor, 0x0000FF), -16), BitShift(BitAND($iColor, 0xFF0000), 16))
	EndIf
	Local $hBrush = _WinAPI_CreateSolidBrush($iColor)
	_WinAPI_FillRect($hDestDC, $tRect, $hBrush)
	If @error Then
		_WinAPI_DeleteObject($hBitmap)
		$hBitmap = 0
	EndIf
	_WinAPI_DeleteObject($hBrush)
	_WinAPI_ReleaseDC($hWnd, $hDC)
	_WinAPI_SelectObject($hDestDC, $hOld)
	_WinAPI_DeleteDC($hDestDC)
	If Not $hBitmap Then Return SetError(1, 0, 0)
	Return $hBitmap
EndFunc   ;==>_WinAPI_CreateSolidBitmap

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateSolidBrush
; Description ...: Creates a logical brush that has the specified solid color
; Syntax.........: _WinAPI_CreateSolidBrush($nColor)
; Parameters ....: $nColor      - Specifies the color of the brush
; Return values .: Success      - HBRUSH Value that identifies a logical brush
;                  Failure      - 0
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: When you no longer need the HBRUSH object call the _WinAPI_DeleteObject function to delete it
; Related .......:
; Link ..........: @@MsdnLink@@ CreateSolidBrush
; Example .......:
; ===============================================================================================================================
Func _WinAPI_CreateSolidBrush($nColor)
	Local $aResult = DllCall("gdi32.dll", "handle", "CreateSolidBrush", "dword", $nColor)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_CreateSolidBrush

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_CreateWindowEx
; Description ...: Creates an overlapped, pop-up, or child window
; Syntax.........: _WinAPI_CreateWindowEx($iExStyle, $sClass, $sName, $iStyle, $iX, $iY, $iWidth, $iHeight, $hParent[, $hMenu = 0[, $hInstance = 0[, $pParam = 0]]])
; Parameters ....: $iExStyle    - Extended window style
;                  $sClass      - Registered class name
;                  $sName       - Window name
;                  $iStyle      - Window style
;                  $iX          - Horizontal position of window
;                  $iY          - Vertical position of window
;                  $iWidth      - Window width
;                  $iHeight     - Window height
;                  $hParent     - Handle to parent or owner window
;                  $hMenu       - Handle to menu or child-window identifier
;                  $hInstance   - Handle to application instance
;                  $pParam      - Pointer to window-creation data
; Return values .: Success      - The handle to the new window
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......: _WinAPI_DestroyWindow
; Link ..........: @@MsdnLink@@ CreateWindowEx
; Example .......:
; ===============================================================================================================================
Func _WinAPI_CreateWindowEx($iExStyle, $sClass, $sName, $iStyle, $iX, $iY, $iWidth, $iHeight, $hParent, $hMenu = 0, $hInstance = 0, $pParam = 0)
	If $hInstance = 0 Then $hInstance = _WinAPI_GetModuleHandle("")
	Local $aResult = DllCall("user32.dll", "hwnd", "CreateWindowExW", "dword", $iExStyle, "wstr", $sClass, "wstr", $sName, "dword", $iStyle, "int", $iX, _
			"int", $iY, "int", $iWidth, "int", $iHeight, "hwnd", $hParent, "handle", $hMenu, "handle", $hInstance, "ptr", $pParam)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_CreateWindowEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DefWindowProc
; Description ...: Call the default window procedure to provide default processing
; Syntax.........: _WinAPI_DefWindowProc($hWnd, $iMsg, $iwParam, $ilParam)
; Parameters ....: $hWnd        - Handle to the window procedure that received the message
;                  $iMsg        - Specifies the message
;                  $iwParam     - Specifies additional message information
;                  $ilParam     - Specifies additional message information
; Return values .: Success - The return value is the result of the message processing and depends on the message
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ DefWindowProc
; Example .......:
; ===============================================================================================================================
Func _WinAPI_DefWindowProc($hWnd, $iMsg, $iwParam, $ilParam)
	Local $aResult = DllCall("user32.dll", "lresult", "DefWindowProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $iwParam, "lparam", $ilParam)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_DefWindowProc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DeleteDC
; Description ...: Deletes the specified device context
; Syntax.........: _WinAPI_DeleteDC($hDC)
; Parameters ....: $hDC         - Identifies the device context to be deleted
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: An application must not delete a DC whose handle was obtained by calling the _WinAPI_GetDC function.  Instead, it
;                  must call the _WinAPI_ReleaseDC function to free the DC.
; Related .......: _WinAPI_GetDC, _WinAPI_ReleaseDC, _WinAPI_CreateCompatibleDC
; Link ..........: @@MsdnLink@@ DeleteDC
; Example .......:
; ===============================================================================================================================
Func _WinAPI_DeleteDC($hDC)
	Local $aResult = DllCall("gdi32.dll", "bool", "DeleteDC", "handle", $hDC)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_DeleteDC

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DeleteObject
; Description ...: Deletes a logical pen, brush, font, bitmap, region, or palette
; Syntax.........: _WinAPI_DeleteObject($hObject)
; Parameters ....: $hObject     - Identifies a logical pen, brush, font, bitmap, region, or palette
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Do not delete a drawing object while it is still  selected  into  a  device  context.  When  a  pattern  brush
;                  is deleted the bitmap associated with the brush is not deleted. The bitmap must be deleted independently.
; Related .......: _GDIPlus_BitmapCloneArea, _GDIPlus_BitmapCreateFromFile, _GDIPlus_BitmapCreateFromGraphics, _GDIPlus_BitmapCreateFromHBITMAP, _GDIPlus_BitmapCreateHBITMAPFromBitmap, _GDIPlus_BitmapLockBits, _GDIPlus_BitmapUnlockBits, _ScreenCapture_Capture, _ScreenCapture_CaptureWnd, _WinAPI_CreateCompatibleBitmap, _WinAPI_CreatePen, _WinAPI_CreateRectRgn, _WinAPI_CreateRoundRectRgn
; Link ..........: @@MsdnLink@@ DeleteObject
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_DeleteObject($hObject)
	Local $aResult = DllCall("gdi32.dll", "bool", "DeleteObject", "handle", $hObject)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_DeleteObject

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DestroyIcon
; Description ...: Destroys an icon and frees any memory the icon occupied
; Syntax.........: _WinAPI_DestroyIcon($hIcon)
; Parameters ....: $hIcon       - Handle to the icon to be destroyed. The icon must not be in use.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_CopyIcon, _WinAPI_LoadShell32Icon
; Link ..........: @@MsdnLink@@ DestroyIcon
; Example .......:
; ===============================================================================================================================
Func _WinAPI_DestroyIcon($hIcon)
	Local $aResult = DllCall("user32.dll", "bool", "DestroyIcon", "handle", $hIcon)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_DestroyIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DestroyWindow
; Description ...: Destroys the specified window
; Syntax.........: _WinAPI_DestroyWindow($hWnd)
; Parameters ....: $hWnd        - Handle to the window to be destroyed
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: You cannot use _WinAPI_DestroyWindow to destroy a window created by a different thread
; Related .......: _WinAPI_CreateWindowEx
; Link ..........: @@MsdnLink@@ DestroyWindow
; Example .......:
; ===============================================================================================================================
Func _WinAPI_DestroyWindow($hWnd)
	Local $aResult = DllCall("user32.dll", "bool", "DestroyWindow", "hwnd", $hWnd)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_DestroyWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DrawEdge
; Description ...: Draws one or more edges of rectangle
; Syntax.........: _WinAPI_DrawEdge($hDC, $ptrRect, $nEdgeType, $grfFlags)
; Parameters ....: $hDC         - Handle to the device context into which the icon or cursor is drawn
;                  $ptrRect     - Pointer to a $tagRECT structure that contains the logical coordinates of the rectangle
;                  $nEdgeType   - Specifies the type of inner and outer edges to draw. This parameter must be a combination of one inner-border flag and one outer-border flag.
;                  |The inner-border flags are as follows:
;                  |$BDR_RAISEDINNER - Raised inner edge
;                  |$BDR_SUNKENINNER - Sunken inner edge
;                  |The outer-border flags are as follows:
;                  |$BDR_RAISEDOUTER - Raised outer edge
;                  |$BDR_SUNKENOUTER - Sunken outer edge
;                  |Alternatively, the edge parameter can specify one of the following flags:
;                  |$EDGE_BUMP       - Combination of $BDR_RAISEDOUTER and $BDR_SUNKENINNER
;                  |$EDGE_ETCHED     - Combination of $BDR_SUNKENOUTER and $BDR_RAISEDINNER
;                  |$EDGE_RAISED     - Combination of $BDR_RAISEDOUTER and $BDR_RAISEDINNER
;                  |$EDGE_SUNKEN     - Combination of $BDR_SUNKENOUTER and $BDR_SUNKENINNER
;                  $grfFlags   - Specifies the type of border. This parameter can be a combination of the following values:
;                  |$BF_ADJUST                  - If this flag is passed, shrink the rectangle pointed to by the $ptrRect parameter to exclude the edges that were drawn.
;                  |If this flag is not passed, then do not change the rectangle pointed to by the $ptrRect parameter
;                  |$BF_BOTTOM                  - Bottom of border rectangle
;                  |$BF_BOTTOMLEFT              - Bottom and left side of border rectangle
;                  |$BF_BOTTOMRIGHT             - Bottom and right side of border rectangle
;                  |$BF_DIAGONAL                - Diagonal border
;                  |$BF_DIAGONAL_ENDBOTTOMLEFT  - Diagonal border. The end point is the bottom-left corner of the rectangle; the origin is top-right corner
;                  |$BF_DIAGONAL_ENDBOTTOMRIGHT - Diagonal border. The end point is the bottom-right corner of the rectangle; the origin is top-left corner
;                  |$BF_DIAGONAL_ENDTOPLEFT     - Diagonal border. The end point is the top-left corner of the rectangle; the origin is bottom-right corner
;                  |$BF_DIAGONAL_ENDTOPRIGHT    - Diagonal border. The end point is the top-right corner of the rectangle; the origin is bottom-left corner
;                  |$BF_FLAT                    - Flat border
;                  |$BF_LEFT                    - Left side of border rectangle
;                  |$BF_MIDDLE                  - Interior of rectangle to be filled
;                  |$BF_MONO                    - One-dimensional border
;                  |$BF_RECT                    - Entire border rectangle
;                  |$BF_RIGHT                   - Right side of border rectangle
;                  |$BF_SOFT                    - Soft buttons instead of tiles
;                  |$BF_TOP                     - Top of border rectangle
;                  |$BF_TOPLEFT                 - Top and left side of border rectangle
;                  |$BF_TOPRIGHT                - Top and right side of border rectangle
; Return values .: Success     - True
;                  Failure     - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Needs BorderConstants.au3 for pre-defined constants
; Related .......: $tagRECT
; Link ..........: @@MsdnLink@@ DrawEdge
; Example .......:
; ===============================================================================================================================
Func _WinAPI_DrawEdge($hDC, $ptrRect, $nEdgeType, $grfFlags)
	Local $aResult = DllCall("user32.dll", "bool", "DrawEdge", "handle", $hDC, "ptr", $ptrRect, "uint", $nEdgeType, "uint", $grfFlags)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_DrawEdge

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DrawFrameControl
; Description ...: Draws a frame control of the specified type and style
; Syntax.........: _WinAPI_DrawFrameControl($hDC, $ptrRect, $nType, $nState)
; Parameters ....: $hDC         - Handle to the device context into which the icon or cursor is drawn
;                  $ptrRect     - Pointer to a $tagRECT structure that contains the logical coordinates of the rectangle
;                  $nType   - Specifies the type of frame control to draw. This parameter can be one of the following values:
;                  |$DFC_BUTTON    - Standard button
;                  |$DFC_CAPTION   - Title bar
;                  |$DFC_MENU      - Menu bar
;                  |$DFC_POPUPMENU - Windows 98/Me, Windows 2000/XP: Popup menu item
;                  |$DFC_SCROLL    - Scroll bar
;                  $nState   - Specifies the initial state of the frame control. If $nType is $DFC_BUTTON, $nState can be one of the following values:
;                  |$DFCS_BUTTON3STATE     - Three-state button
;                  |$DFCS_BUTTONCHECK      - Check box
;                  |$DFCS_BUTTONPUSH       - Push button
;                  |$DFCS_BUTTONRADIO      - Radio button
;                  |$DFCS_BUTTONRADIOIMAGE - Image for radio button (nonsquare needs image)
;                  |$DFCS_BUTTONRADIOMASK  - Mask for radio button (nonsquare needs mask)
;                  |If $nType is $DFC_CAPTION, $nState can be one of the following values:
;                  |$DFCS_CAPTIONCLOSE     - Close button
;                  |$DFCS_CAPTIONHELP      - Help button
;                  |$DFCS_CAPTIONMAX       - Maximize button
;                  |$DFCS_CAPTIONMIN       - Minimize button
;                  |$DFCS_CAPTIONRESTORE   - Restore button
;                  |If $nType is $DFC_MENU, $nState can be one of the following values:
;                  |$DFCS_MENUARROW        - Submenu arrow
;                  |$DFCS_MENUARROWRIGHT   - Submenu arrow pointing left. This is used for the right-to-left cascading menus used with right-to-left languages such as Arabic or Hebrew
;                  |$DFCS_MENUBULLET       - Bullet
;                  |$DFCS_MENUCHECK        - Check mark
;                  |If $nType is $DFC_SCROLL, $nState can be one of the following values:
;                  |$DFCS_SCROLLCOMBOBOX      - Combo box scroll bar
;                  |$DFCS_SCROLLDOWN          - Down arrow of scroll bar
;                  |$DFCS_SCROLLLEFT          - Left arrow of scroll bar
;                  |$DFCS_SCROLLRIGHT         - Right arrow of scroll bar
;                  |$DFCS_SCROLLSIZEGRIP      - Size grip in bottom-right corner of window
;                  |$DFCS_SCROLLSIZEGRIPRIGHT - Size grip in bottom-left corner of window. This is used with right-to-left languages such as Arabic or Hebrew
;                  |$DFCS_SCROLLUP            - Up arrow of scroll bar
;                  |The following style can be used to adjust the bounding rectangle of the push button:
;                  |$DFCS_ADJUSTRECT          - Bounding rectangle is adjusted to exclude the surrounding edge of the push button
;                  |One or more of the following values can be used to set the state of the control to be drawn:
;                  |$DFCS_CHECKED     - Button is checked
;                  |$DFCS_FLAT        - Button has a flat border
;                  |$DFCS_HOT         - Windows 98/Me, Windows 2000/XP: Button is hot-tracked
;                  |$DFCS_INACTIVE    - Button is inactive (grayed)
;                  |$DFCS_PUSHED      - Button is pushed
;                  |$DFCS_TRANSPARENT - Windows 98/Me, Windows 2000/XP: The background remains untouched. This flag can only be combined with $DFCS_MENUARROWUP or $DFCS_MENUARROWDOWN
; Return values .: Success     - True
;                  Failure     - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Needs FrameConstants.au3 for pre-defined constants
; Related .......: $tagRECT
; Link ..........: @@MsdnLink@@ DrawFrameControl
; Example .......:
; ===============================================================================================================================
Func _WinAPI_DrawFrameControl($hDC, $ptrRect, $nType, $nState)
	Local $aResult = DllCall("user32.dll", "bool", "DrawFrameControl", "handle", $hDC, "ptr", $ptrRect, "uint", $nType, "uint", $nState)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_DrawFrameControl

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DrawIcon
; Description ...: Draws an icon or cursor into the specified device context
; Syntax.........: _WinAPI_DrawIcon($hDC, $iX, $iY, $hIcon)
; Parameters ....: $hDC         - Handle to the device context into which the icon or cursor is drawn
;                  $iX          - X coordinate of the upper-left corner of the icon
;                  $iY          - Y coordinate of the upper-left corner of the icon
;                  $hIcon       - Handle to the icon to be drawn
; Return values .: Success     - True
;                  Failure     - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_DrawIconEx
; Link ..........: @@MsdnLink@@ DrawIcon
; Example .......:
; ===============================================================================================================================
Func _WinAPI_DrawIcon($hDC, $iX, $iY, $hIcon)
	Local $aResult = DllCall("user32.dll", "bool", "DrawIcon", "handle", $hDC, "int", $iX, "int", $iY, "handle", $hIcon)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_DrawIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DrawIconEx
; Description ...: Draws an icon or cursor into the specified device context
; Syntax.........: _WinAPI_DrawIconEx($hDC, $iX, $iY, $hIcon[, $iWidth = 0[, $iHeight = 0[, $iStep = 0[, $hBrush = 0[, $iFlags = 3]]]]])
; Parameters ....: $hDC         - Handle to the device context into which the icon or cursor is drawn
;                  $iX          - X coordinate of the upper-left corner of the icon
;                  $iY          - Y coordinate of the upper-left corner of the icon
;                  $hIcon       - Handle to the icon to be drawn
;                  $iWidth      - Specifies the logical width of the icon or cursor.  If this parameter is zero and the iFlags
;                  +parameter is "default size", the function uses the $SM_CXICON or $SM_CXCURSOR system metric value to set the
;                  +width. If this is zero and "default size" is not used, the function uses the actual resource width.
;                  $iHeight     - Specifies the logical height of the icon or cursor.  If this parameter is zero and the iFlags
;                  +parameter is "default size", the function uses the $SM_CYICON or $SM_CYCURSOR system metric value to set the
;                  +width. If this is zero and "default size" is not used, the function uses the actual resource height.
;                  $iStep       - Specifies the index of the frame to draw if hIcon identifies an animated cursor. This parameter
;                  +is ignored if hIcon does not identify an animated cursor.
;                  $hBrush      - Handle to a brush that the system uses for flicker-free drawing.  If hBrush is a valid brush
;                  +handle, the system creates an offscreen bitmap using the specified brush for the background color, draws the
;                  +icon or cursor into the bitmap, and then copies the bitmap into the device context identified by hDC. If
;                  +hBrush is 0, the system draws the icon or cursor directly into the device context.
;                  $iFlags      - Specifies the drawing flags. This parameter can be one of the following values:
;                  |1 - Draws the icon or cursor using the mask
;                  |2 - Draws the icon or cursor using the image
;                  |3 - Draws the icon or cursor using the mask and image
;                  |4 - Draws the icon or cursor using the system default image rather than the user-specified image
;                  |5 - Draws the icon or cursor using the width and height specified by the system metric values for cursors  or
;                  +icons, if the iWidth and iWidth parameters are set to zero.  If this flag is not  specified  and  iWidth  and
;                  +iWidth are set to zero, the function uses the actual resource size.
;                  |6 - Draws the icon as an unmirrored icon
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_DrawIcon
; Link ..........: @@MsdnLink@@ DrawIconEx
; Example .......:
; ===============================================================================================================================
Func _WinAPI_DrawIconEx($hDC, $iX, $iY, $hIcon, $iWidth = 0, $iHeight = 0, $iStep = 0, $hBrush = 0, $iFlags = 3)
	Local $iOptions

	Switch $iFlags
		Case 1
			$iOptions = $__WINAPICONSTANT_DI_MASK
		Case 2
			$iOptions = $__WINAPICONSTANT_DI_IMAGE
		Case 3
			$iOptions = $__WINAPICONSTANT_DI_NORMAL
		Case 4
			$iOptions = $__WINAPICONSTANT_DI_COMPAT
		Case 5
			$iOptions = $__WINAPICONSTANT_DI_DEFAULTSIZE
		Case Else
			$iOptions = $__WINAPICONSTANT_DI_NOMIRROR
	EndSwitch

	Local $aResult = DllCall("user32.dll", "bool", "DrawIconEx", "handle", $hDC, "int", $iX, "int", $iY, "handle", $hIcon, "int", $iWidth, _
			"int", $iHeight, "uint", $iStep, "handle", $hBrush, "uint", $iOptions)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_DrawIconEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DrawLine
; Description ...: Draws a line
; Syntax.........: _WinAPI_DrawLine($hDC, $iX1, $iY1, $iX2, $iY2)
; Parameters ....: $hDC - Handle to device context
;                  $iX1 - X coordinate of the line's starting point.
;                  $iY1 - Y coordinate of the line's starting point.
;                  $iX2 - X coordinate of the line's ending point.
;                  $iY2 - Y coordinate of the line's ending point.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Zedna
; Modified.......:
; Remarks .......: Internally calls _WinAPI_MoveTo() and _WinAPI_LineTo(), see _WinAPI_LineTo() for details
; Related .......: _WinAPI_MoveTo, _WinAPI_LineTo, _WinAPI_SelectObject, _WinAPI_CreatePen
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_DrawLine($hDC, $iX1, $iY1, $iX2, $iY2)
	_WinAPI_MoveTo($hDC, $iX1, $iY1)
	If @error Then Return SetError(@error, @extended, False)
	_WinAPI_LineTo($hDC, $iX2, $iY2)
	If @error Then Return SetError(@error, @extended, False)
	Return True
EndFunc   ;==>_WinAPI_DrawLine

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DrawText
; Description ...: Draws formatted text in the specified rectangle
; Syntax.........: _WinAPI_DrawText($hDC, $sText, ByRef $tRect, $iFlags)
; Parameters ....: $hDC         - Identifies the device context
;                  $sText       - The string to be drawn
;                  $tRect       - $tagRECT structure that contains the rectangle for the text
;                  $iFlags      - Specifies the method of formatting the text:
;                  |$DT_BOTTOM          - Justifies the text to the bottom of the rectangle
;                  |$DT_CALCRECT        - Determines the width and height of the rectangle
;                  |$DT_CENTER          - Centers text horizontally in the rectangle
;                  |$DT_EDITCONTROL     - Duplicates the text-displaying characteristics of a multiline edit control
;                  |$DT_END_ELLIPSIS    - Replaces part of the given string with ellipses if necessary
;                  |$DT_EXPANDTABS      - Expands tab characters
;                  |$DT_EXTERNALLEADING - Includes the font external leading in line height
;                  |$DT_HIDEPREFIX      - Ignores the ampersand (&) prefix character in the text.
;                  |  The letter that follows will not be underlined, but other mnemonic-prefix characters are still processed.
;                  |$DT_INTERNAL        - Uses the system font to calculate text metrics
;                  |$DT_LEFT            - Aligns text to the left
;                  |$DT_MODIFYSTRING    - Modifies the given string to match the displayed text
;                  |$DT_NOCLIP          - Draws without clipping
;                  |$DT_NOFULLWIDTHCHARBREAK - Prevents a line break at a DBCS (double-wide character string), so that the line breaking rule is equivalent to SBCS strings.
;                  |  For example, this can be used in Korean windows, for more readability of icon labels.
;                  |  This value has no effect unless $DT_WORDBREAK is specified
;                  |$DT_NOPREFIX        - Turns off processing of prefix characters
;                  |$DT_PATH_ELLIPSIS   - For displayed text, replaces characters in the middle of the string with ellipses so that the result fits in the specified rectangle.
;                  |  If the string contains backslash (\) characters, $DT_PATH_ELLIPSIS preserves as much as possible of the text after the last backslash.
;                  |  The string is not modified unless the $DT_MODIFYSTRING flag is specified
;                  |$DT_PREFIXONLY      - Draws only an underline at the position of the character following the ampersand (&) prefix character.
;                  |  Does not draw any other characters in the string
;                  |$DT_RIGHT           - Aligns text to the right
;                  |$DT_RTLREADING      - Layout in right to left reading order for bi-directional text
;                  |$DT_SINGLELINE      - Displays text on a single line only
;                  |$DT_TABSTOP         - Sets tab stops. Bits 15-8 of $iFlags specify the number of characters for each tab
;                  |$DT_TOP             - Top-justifies text (single line only)
;                  |$DT_VCENTER         - Centers text vertically (single line only)
;                  |$DT_WORDBREAK       - Breaks words
;                  |$DT_WORD_ELLIPSIS   - Truncates any word that does not fit in the rectangle and adds ellipses
; Return values .: Success      - The height of the text
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......: The DrawText function uses the device context's selected font, text color, and background color to draw the
;                  text.  Unless the $DT_NOCLIP format is used,  DrawText clips the text so that it does not appear outside the
;                  specified rectangle.  All formatting is assumed to have multiple lines unless the $DT_SINGLELINE format is
;                  specified. If the selected font is too large, DrawText does not attempt to substitute a smaller font.
;+
;                  Needs WindowsConstants.au3 for pre-defined constants
; Related .......: $tagRECT, _WinAPI_GetBkMode, _WinAPI_SetBkMode
; Link ..........: @@MsdnLink@@ DrawText
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_DrawText($hDC, $sText, ByRef $tRect, $iFlags)
	Local $aResult = DllCall("user32.dll", "int", "DrawTextW", "handle", $hDC, "wstr", $sText, "int", -1, "struct*", $tRect, "uint", $iFlags)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_DrawText

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_DuplicateHandle
; Description ...: Duplicates an object handle
; Syntax.........: _WinAPI_DuplicateHandle($hSourceProcessHandle, $hSourceHandle, $hTargetProcessHandle, $iDesiredAccess, $fInheritHandle, $iOptions)
; Parameters ....: $hSourceProcessHandle        - A handle to the process with the handle to be duplicated.
;                  $hSourceHandle     ..........- The handle to be duplicated.
;                  $hTargetProcessHandle........- A handle to the process that is to receive the duplicated handle.
;                  $iDesiredAccess..............- The access requested for the new handle.
;                  $fInheritHandle..............- A variable that indicates whether the handle is inheritable.
;                  $iOptions....................- Optional actions.
; Return values .: Success      - New handle
;                  Failure      - 0
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_OpenProcess, _WinAPI_CloseHandle
; Link ..........: @@MsdnLink@@ DuplicateHandle
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_DuplicateHandle($hSourceProcessHandle, $hSourceHandle, $hTargetProcessHandle, $iDesiredAccess, $fInheritHandle, $iOptions)
	Local $aCall = DllCall("kernel32.dll", "bool", "DuplicateHandle", _
			"handle", $hSourceProcessHandle, _
			"handle", $hSourceHandle, _
			"handle", $hTargetProcessHandle, _
			"handle*", 0, _
			"dword", $iDesiredAccess, _
			"bool", $fInheritHandle, _
			"dword", $iOptions)
	If @error Or Not $aCall[0] Then Return SetError(1, @extended, 0)
	Return $aCall[4]
EndFunc   ;==>_WinAPI_DuplicateHandle

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EnableWindow
; Description ...: Enables or disables mouse and keyboard input to the specified window or control
; Syntax.........: _WinAPI_EnableWindow($hWnd[, $fEnable = True])
; Parameters ....: $hWnd        - Handle to the window to be enabled or disabled
;                  $fEnable     - Specifies whether to enable or disable the window:
;                  | True - The window or control is enabled
;                  |False - The window or control is disabled
; Return values .: True - The window or control was previously disabled
;                  False - The window or control was previously enabled
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ EnableWindow
; Example .......:
; ===============================================================================================================================
Func _WinAPI_EnableWindow($hWnd, $fEnable = True)
	Local $aResult = DllCall("user32.dll", "bool", "EnableWindow", "hwnd", $hWnd, "bool", $fEnable)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_EnableWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EnumDisplayDevices
; Description ...: Obtains information about the display devices in a system
; Syntax.........: _WinAPI_EnumDisplayDevices($sDevice, $iDevNum)
; Parameters ....: $sDevice     - Device name. If blank, the function returns information for the display adapters on the machine
;                  +based on iDevNum.
;                  $iDevNum     - Zero based index value that specifies the display device of interest
; Return values .: Success      - Array with the following format:
;                  |$aDevice[0] - True
;                  |$aDevice[1] - Either the adapter device or the monitor device
;                  |$aDevice[2] - Either a description of the adapter or the monitor
;                  |$aDevice[3] - Device state flags:
;                  | 1 - The device is part of the desktop
;                  | 2 - The primary desktop is on the device
;                  | 4 - Represents a pseudo device used to mirror application drawing for remoting
;                  | 8 - The device is VGA compatible
;                  |16 - The device is removable; it cannot be the primary display
;                  |32 - The device has more display modes than its output devices support
;                  |$aDevice[4] - Plug and Play identifier string (Windows 98/ME)
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ EnumDisplayDevices
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_EnumDisplayDevices($sDevice, $iDevNum)
	Local $tName = 0, $iFlags = 0, $aDevice[5]

	If $sDevice <> "" Then
		$tName = DllStructCreate("wchar Text[" & StringLen($sDevice) + 1 & "]")
		DllStructSetData($tName, "Text", $sDevice)
	EndIf
	Local $tDevice = DllStructCreate($tagDISPLAY_DEVICE)
	Local $iDevice = DllStructGetSize($tDevice)
	DllStructSetData($tDevice, "Size", $iDevice)
	DllCall("user32.dll", "bool", "EnumDisplayDevicesW", "struct*", $tName, "dword", $iDevNum, "struct*", $tDevice, "dword", 1)
	If @error Then Return SetError(@error, @extended, 0)

	Local $iN = DllStructGetData($tDevice, "Flags")
	If BitAND($iN, $__WINAPICONSTANT_DISPLAY_DEVICE_ATTACHED_TO_DESKTOP) <> 0 Then $iFlags = BitOR($iFlags, 1)
	If BitAND($iN, $__WINAPICONSTANT_DISPLAY_DEVICE_PRIMARY_DEVICE) <> 0 Then $iFlags = BitOR($iFlags, 2)
	If BitAND($iN, $__WINAPICONSTANT_DISPLAY_DEVICE_MIRRORING_DRIVER) <> 0 Then $iFlags = BitOR($iFlags, 4)
	If BitAND($iN, $__WINAPICONSTANT_DISPLAY_DEVICE_VGA_COMPATIBLE) <> 0 Then $iFlags = BitOR($iFlags, 8)
	If BitAND($iN, $__WINAPICONSTANT_DISPLAY_DEVICE_REMOVABLE) <> 0 Then $iFlags = BitOR($iFlags, 16)
	If BitAND($iN, $__WINAPICONSTANT_DISPLAY_DEVICE_MODESPRUNED) <> 0 Then $iFlags = BitOR($iFlags, 32)
	$aDevice[0] = True
	$aDevice[1] = DllStructGetData($tDevice, "Name")
	$aDevice[2] = DllStructGetData($tDevice, "String")
	$aDevice[3] = $iFlags
	$aDevice[4] = DllStructGetData($tDevice, "ID")
	Return $aDevice
EndFunc   ;==>_WinAPI_EnumDisplayDevices

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EnumWindows
; Description ...: Enumerates all windows
; Syntax.........: _WinAPI_EnumWindows([$fVisible = True [, $hwnd = Default]])
; Parameters ....: $fVisible    - Window selection flag:
;                  |True - Returns only visible windows
;                  |False - Returns all windows
;                  $hWnd        - Handle of the starting windows (default Desktop windows)
; Return values .: Success      - Array with the following format:
;                  |[0][0] - Number of rows in array (n)
;                  |[1][0] - Window handle
;                  |[1][1] - Window class name
;                  |[n][0] - Window handle
;                  |[n][1] - Window class name
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......: _WinAPI_EnumWindowsPopup, _WinAPI_EnumWindowsTop
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_EnumWindows($fVisible = True, $hWnd = Default)
	__WinAPI_EnumWindowsInit()
	If $hWnd = Default Then $hWnd = _WinAPI_GetDesktopWindow()
	__WinAPI_EnumWindowsChild($hWnd, $fVisible)
	Return $__gaWinList_WinAPI
EndFunc   ;==>_WinAPI_EnumWindows

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __WinAPI_EnumWindowsAdd
; Description ...: Adds window information to the windows enumeration list
; Syntax.........: __WinAPI_EnumWindowsAdd($hWnd[, $sClass = ""])
; Parameters ....: $hWnd        - Handle to the window
;                  $sClass      - Window class name
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function is used internally by the windows enumeration functions
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __WinAPI_EnumWindowsAdd($hWnd, $sClass = "")
	If $sClass = "" Then $sClass = _WinAPI_GetClassName($hWnd)
	$__gaWinList_WinAPI[0][0] += 1
	Local $iCount = $__gaWinList_WinAPI[0][0]
	If $iCount >= $__gaWinList_WinAPI[0][1] Then
		ReDim $__gaWinList_WinAPI[$iCount + 64][2]
		$__gaWinList_WinAPI[0][1] += 64
	EndIf
	$__gaWinList_WinAPI[$iCount][0] = $hWnd
	$__gaWinList_WinAPI[$iCount][1] = $sClass
EndFunc   ;==>__WinAPI_EnumWindowsAdd

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __WinAPI_EnumWindowsChild
; Description ...: Enumerates child windows of a specific window
; Syntax.........: __WinAPI_EnumWindowsChild($hWnd[, $fVisible = True])
; Parameters ....: $hWnd        - Handle of parent window
;                  $fVisible    - Window selection flag:
;                  | True - Returns only visible windows
;                  |False - Returns all windows
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function is used internally by the windows enumeration functions
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __WinAPI_EnumWindowsChild($hWnd, $fVisible = True)
	$hWnd = _WinAPI_GetWindow($hWnd, $__WINAPICONSTANT_GW_CHILD)
	While $hWnd <> 0
		If (Not $fVisible) Or _WinAPI_IsWindowVisible($hWnd) Then
			__WinAPI_EnumWindowsChild($hWnd, $fVisible)
			__WinAPI_EnumWindowsAdd($hWnd)
		EndIf
		$hWnd = _WinAPI_GetWindow($hWnd, $__WINAPICONSTANT_GW_HWNDNEXT)
	WEnd
EndFunc   ;==>__WinAPI_EnumWindowsChild

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __WinAPI_EnumWindowsInit
; Description ...: Initializes the windows enumeration list
; Syntax.........: __WinAPI_EnumWindowsInit()
; Parameters ....:
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function is used internally by the windows enumeration functions
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __WinAPI_EnumWindowsInit()
	ReDim $__gaWinList_WinAPI[64][2]
	$__gaWinList_WinAPI[0][0] = 0
	$__gaWinList_WinAPI[0][1] = 64
EndFunc   ;==>__WinAPI_EnumWindowsInit

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EnumWindowsPopup
; Description ...: Enumerates popup windows
; Syntax.........: _WinAPI_EnumWindowsPopup()
; Parameters ....:
; Return values .: Success      - Array with the following format:
;                  |[0][0] - Number of rows in array (n)
;                  |[1][0] - Window handle
;                  |[1][1] - Window class name
;                  |[n][0] - Window handle
;                  |[n][1] - Window class name
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_EnumWindows, _WinAPI_EnumWindowsTop
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_EnumWindowsPopup()
	__WinAPI_EnumWindowsInit()
	Local $hWnd = _WinAPI_GetWindow(_WinAPI_GetDesktopWindow(), $__WINAPICONSTANT_GW_CHILD)
	Local $sClass
	While $hWnd <> 0
		If _WinAPI_IsWindowVisible($hWnd) Then
			$sClass = _WinAPI_GetClassName($hWnd)
			If $sClass = "#32768" Then
				__WinAPI_EnumWindowsAdd($hWnd)
			ElseIf $sClass = "ToolbarWindow32" Then
				__WinAPI_EnumWindowsAdd($hWnd)
			ElseIf $sClass = "ToolTips_Class32" Then
				__WinAPI_EnumWindowsAdd($hWnd)
			ElseIf $sClass = "BaseBar" Then
				__WinAPI_EnumWindowsChild($hWnd)
			EndIf
		EndIf
		$hWnd = _WinAPI_GetWindow($hWnd, $__WINAPICONSTANT_GW_HWNDNEXT)
	WEnd
	Return $__gaWinList_WinAPI
EndFunc   ;==>_WinAPI_EnumWindowsPopup

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_EnumWindowsTop
; Description ...: Enumerates all top level windows
; Syntax.........: _WinAPI_EnumWindowsTop()
; Parameters ....:
; Return values .: Success      - Array with the following format:
;                  |[0][0] - Number of rows in array (n)
;                  |[1][0] - Window handle
;                  |[1][1] - Window class name
;                  |[n][0] - Window handle
;                  |[n][1] - Window class name
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_EnumWindows, _WinAPI_EnumWindowsPopup
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_EnumWindowsTop()
	__WinAPI_EnumWindowsInit()
	Local $hWnd = _WinAPI_GetWindow(_WinAPI_GetDesktopWindow(), $__WINAPICONSTANT_GW_CHILD)
	While $hWnd <> 0
		If _WinAPI_IsWindowVisible($hWnd) Then __WinAPI_EnumWindowsAdd($hWnd)
		$hWnd = _WinAPI_GetWindow($hWnd, $__WINAPICONSTANT_GW_HWNDNEXT)
	WEnd
	Return $__gaWinList_WinAPI
EndFunc   ;==>_WinAPI_EnumWindowsTop

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ExpandEnvironmentStrings
; Description ...: Expands environment variable strings and replaces them with their defined values
; Syntax.........: _WinAPI_ExpandEnvironmentStrings($sString)
; Parameters ....: $sString     - String to convert for environment variables
; Return values .: Success      - Converted string
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ ExpandEnvironmentStrings
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_ExpandEnvironmentStrings($sString)
	Local $aResult = DllCall("kernel32.dll", "dword", "ExpandEnvironmentStringsW", "wstr", $sString, "wstr", "", "dword", 4096)
	If @error Then Return SetError(@error, @extended, "")
	Return $aResult[2]
EndFunc   ;==>_WinAPI_ExpandEnvironmentStrings

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ExtractIconEx
; Description ...: Creates an array of handles to large or small icons extracted from a file
; Syntax.........: _WinAPI_ExtractIconEx($sFile, $iIndex, $pLarge, $pSmall, $iIcons)
; Parameters ....: $sFile       - Name of an executable file, DLL, or icon file from which icons will be extracted
;                  $iIndex      - Specifies the zero-based index of the first icon to extract
;                  $pLarge      - Pointer to an array of icon handles that receives handles to the large icons extracted from the
;                  +file. If this parameter is 0, no large icons are extracted from the file.
;                  $pSmall      - Pointer to an array of icon handles that receives handles to the small icons extracted from the
;                  +file. If this parameter is 0, no small icons are extracted from the file.
;                  $iIcons      - Specifies the number of icons to extract from the file
; Return values .: Success      - If iIndex is -1, pLarge parameter is 0, and pSmall is 0, then the return value is the number of
;                  |icons contained in the specified file.  Otherwise, the return value  is  the  number  of  icons  successfully
;                  |extracted from the file.
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ ExtractIconEx
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_ExtractIconEx($sFile, $iIndex, $pLarge, $pSmall, $iIcons)
	Local $aResult = DllCall("shell32.dll", "uint", "ExtractIconExW", "wstr", $sFile, "int", $iIndex, "struct*", $pLarge, "struct*", $pSmall, "uint", $iIcons)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_ExtractIconEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FatalAppExit
; Description ...: Displays a message box and terminates the application
; Syntax.........: _WinAPI_FatalAppExit($sMessage)
; Parameters ....: $sMessage    - The string that is displayed in the message box
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......: An application calls FatalAppExit only when it is not capable of terminating any other way.  FatalAppExit  may
;                  not always free an application's memory or close its files, and it may cause a general failure of the  system.
;                  An application that encounters an unexpected error should terminate by freeing all its  memory  and  returning
;                  from its main message loop.
; Related .......:
; Link ..........: @@MsdnLink@@ FatalAppExit
; Example .......:
; ===============================================================================================================================
Func _WinAPI_FatalAppExit($sMessage)
	DllCall("kernel32.dll", "none", "FatalAppExitW", "uint", 0, "wstr", $sMessage)
	If @error Then Return SetError(@error, @extended)
EndFunc   ;==>_WinAPI_FatalAppExit

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FillRect
; Description ...: Fills a rectangle by using the specified brush
; Syntax.........: _WinAPI_FillRect($hDC, $ptrRect, $hBrush)
; Parameters ....: $hDC     - Handle to the device context
;                  $ptrRect - Pointer to a $tagRECT structure that contains the logical coordinates of the rectangle to be filled
;                  $hBrush  - Handle to the brush used to fill the rectangle
; Return values .: Success - True
;                  Failure - False
; Author ........: Gary Frost
; Modified.......: jpm
; Remarks .......: The brush identified by the $hBrush parameter may be either a handle to a logical brush or a color value.
;                  If specifying a handle to a logical brush, call _WinAPI_CreateSolidBrush.
;                  Additionally, you may retrieve a handle to one of the stock brushes by using the _WinAPI_GetStockObject function.
;                  If specifying a color value for the $hBrush parameter, it must be one of the standard system colors (the value 1 must be added to the chosen color)
; Related .......:
; Link ..........: @@MsdnLink@@ FillRect
; Example .......:
; ===============================================================================================================================
Func _WinAPI_FillRect($hDC, $ptrRect, $hBrush)
	Local $aResult
	If IsPtr($hBrush) Then
		$aResult = DllCall("user32.dll", "int", "FillRect", "handle", $hDC, "struct*", $ptrRect, "handle", $hBrush)
	Else
		$aResult = DllCall("user32.dll", "int", "FillRect", "handle", $hDC, "struct*", $ptrRect, "dword_ptr", $hBrush)
	EndIf
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_FillRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FindExecutable
; Description ...: Retrieves the name of the executable file associated with the specified file name
; Syntax.........: _WinAPI_FindExecutable($sFileName[, $sDirectory = ""])
; Parameters ....: $sFileName    - Fully qualified path to existing file
;                  $sDirectory   - Default directory
; Return values .: Success      - Full path to the executable file started when an "open" by association is run on the file
;                  |specified or blank if no association was found.
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ FindExecutable
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_FindExecutable($sFileName, $sDirectory = "")
	Local $aResult = DllCall("shell32.dll", "INT", "FindExecutableW", "wstr", $sFileName, "wstr", $sDirectory, "wstr", "")
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($aResult[0], $aResult[3])
EndFunc   ;==>_WinAPI_FindExecutable

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FindWindow
; Description ...: Retrieves the handle to the top-level window whose class name and window name match
; Syntax.........: _WinAPI_FindWindow($sClassName, $sWindowName)
; Parameters ....: $sClassName  - A string that specifies the class name or is an atom that identifies the class-name string.  If
;                  +this parameter is an atom, it must be a global atom created by a call to  the  GlobalAddAtom  function.   The
;                  +atom, a 16-bit value, must be placed in the low-order word of the $sClassName string and the high-order  word
;                  +must be zero.
;                  $sWindowName  - A string that specifies the window name.  If this parameter is blank, all window names match.
; Return values .: Success      - The handle to the window
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ FindWindow
; Example .......:
; ===============================================================================================================================
Func _WinAPI_FindWindow($sClassName, $sWindowName)
	Local $aResult = DllCall("user32.dll", "hwnd", "FindWindowW", "wstr", $sClassName, "wstr", $sWindowName)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_FindWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FlashWindow
; Description ...: Flashes the specified window one time
; Syntax.........: _WinAPI_FlashWindow($hWnd[, $fInvert = True])
; Parameters ....: $hWnd        - Handle to the window to be flashed. The window can be either open or minimized.
;                  $fInvert     - If True, the window is flashed from one state to the other.  If False the window is returned to
;                  +its original state. When an application is minimized and this parameter is True, the  taskbar  window  button
;                  +flashes active/inactive.  If it is False, the taskbar window button flashes inactive, meaning  that  it  does
;                  +not change colors.  It flashes as if it were being redrawn, but it does not provide the visual invert clue to
;                  +the user.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function does not change the active state of the window. To flash the window a specified number of times,
;                  use the FlashWindowEx function.
; Related .......: _WinAPI_FlashWindowEx
; Link ..........: @@MsdnLink@@ FlashWindow
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_FlashWindow($hWnd, $fInvert = True)
	Local $aResult = DllCall("user32.dll", "bool", "FlashWindow", "hwnd", $hWnd, "bool", $fInvert)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_FlashWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FlashWindowEx
; Description ...: Flashes the specified window
; Syntax.........: _WinAPI_FlashWindowEx($hWnd[, $iFlags = 3[, $iCount = 3[, $iTimeout = 0]]])
; Parameters ....: $hWnd        - Handle to the window to be flashed. The window can be either open or minimized.
;                  $iFlags      - The flash status. Can be one or more of the following values:
;                  |0 - Stop flashing. The system restores the window to its original state.
;                  |1 - Flash the window caption
;                  |2 - Flash the taskbar button
;                  |4 - Flash continuously until stopped
;                  |8 - Flash continuously until the window comes to the foreground
;                  $iCount      - The number of times to flash the window
;                  $iTimeout    - The rate at which the window is to be flashed, in  milliseconds.  If 0, the function  uses  the
;                  +default cursor blink rate.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Yoan Roblet (arcker)
; Modified.......:
; Remarks .......: Typically, you flash a window to inform the user that the window requires attention  but  does  not  currently
;                  have the keyboard focus.  When a window flashes, it appears to change  from  inactive  to  active  status.  An
;                  inactive caption bar changes to an active caption bar; an active caption bar changes to  an  inactive  caption
;                  bar.
; Related .......: _WinAPI_FlashWindow
; Link ..........: @@MsdnLink@@ FlashWindowEx
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_FlashWindowEx($hWnd, $iFlags = 3, $iCount = 3, $iTimeout = 0)
	Local $tFlash = DllStructCreate($tagFLASHWINFO)
	Local $iFlash = DllStructGetSize($tFlash)
	Local $iMode = 0
	If BitAND($iFlags, 1) <> 0 Then $iMode = BitOR($iMode, $__WINAPICONSTANT_FLASHW_CAPTION)
	If BitAND($iFlags, 2) <> 0 Then $iMode = BitOR($iMode, $__WINAPICONSTANT_FLASHW_TRAY)
	If BitAND($iFlags, 4) <> 0 Then $iMode = BitOR($iMode, $__WINAPICONSTANT_FLASHW_TIMER)
	If BitAND($iFlags, 8) <> 0 Then $iMode = BitOR($iMode, $__WINAPICONSTANT_FLASHW_TIMERNOFG)
	DllStructSetData($tFlash, "Size", $iFlash)
	DllStructSetData($tFlash, "hWnd", $hWnd)
	DllStructSetData($tFlash, "Flags", $iMode)
	DllStructSetData($tFlash, "Count", $iCount)
	DllStructSetData($tFlash, "Timeout", $iTimeout)
	Local $aResult = DllCall("user32.dll", "bool", "FlashWindowEx", "struct*", $tFlash)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_FlashWindowEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FloatToInt
; Description ...: Returns a 4 byte float as an integer value
; Syntax.........: _WinAPI_FloatToInt($nFloat)
; Parameters ....: $nFloat      - Float value
; Return values .: Success      - 4 byte float value as an integer
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_FloatToInt($nFloat)
	Local $tFloat = DllStructCreate("float")
	Local $tInt = DllStructCreate("int", DllStructGetPtr($tFloat))
	DllStructSetData($tFloat, 1, $nFloat)
	Return DllStructGetData($tInt, 1)
EndFunc   ;==>_WinAPI_FloatToInt

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FlushFileBuffers
; Description ...: Flushes the buffers of a specified file and causes all buffered data to be written
; Syntax.........: _WinAPI_FlushFileBuffers($hFile)
; Parameters ....: $hFile       - Handle to an open file.  The file handle must have the $GENERIC_WRITE access right.  If hFile is
;                  +a handle to a communications device, the function only flushes the transmit buffer.  If hFile is a handle  to
;                  +the server end of a named pipe the function does not return until the client has read all buffered data  from
;                  +the pipe.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_CloseHandle, _WinAPI_CreateFile, _WinAPI_GetFileSizeEx, _WinAPI_ReadFile, _WinAPI_SetEndOfFile, _WinAPI_SetFilePointer, _WinAPI_WriteFile
; Link ..........: @@MsdnLink@@ FlushFileBuffers
; Example .......:
; ===============================================================================================================================
Func _WinAPI_FlushFileBuffers($hFile)
	Local $aResult = DllCall("kernel32.dll", "bool", "FlushFileBuffers", "handle", $hFile)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_FlushFileBuffers

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FormatMessage
; Description ...: Formats a message string
; Syntax.........: _WinAPI_FormatMessage($iFlags, $pSource, $iMessageID, $iLanguageID, $pBuffer, $iSize, $vArguments)
; Parameters ....: $iFlags      - Contains a set of bit flags that specify aspects of the formatting process and how to interpret
;                  +the pSource parameter.  The low-order byte of $iFlags specifies how the function handles line breaks  in  the
;                  +output buffer. The low-order byte can also specify the maximum width of a formatted output line.
;                  $pSource     - Pointer to message source
;                  $iMessageID  - Requested message identifier
;                  $iLanguageID - Language identifier for requested message
;                  $pBuffer     - Pointer to message buffer
;                  $iSize       - Maximum size of message buffer
;                  $vArguments  - Address of array of message inserts
; Return values .: Success      - Number of bytes stored in message buffer
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ FormatMessage
; Example .......:
; ===============================================================================================================================
Func _WinAPI_FormatMessage($iFlags, $pSource, $iMessageID, $iLanguageID, ByRef $pBuffer, $iSize, $vArguments)
	Local $sBufferType = "struct*"
	If IsString($pBuffer) Then $sBufferType = "wstr"
	Local $aResult = DllCall("Kernel32.dll", "dword", "FormatMessageW", "dword", $iFlags, "ptr", $pSource, "dword", $iMessageID, "dword", $iLanguageID, _
			$sBufferType, $pBuffer, "dword", $iSize, "ptr", $vArguments)
	If @error Then Return SetError(@error, @extended, 0)
	If $sBufferType = "wstr" Then $pBuffer = $aResult[5]
	Return $aResult[0]
EndFunc   ;==>_WinAPI_FormatMessage

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FrameRect
; Description ...: Draws a border around the specified rectangle by using the specified brush
; Syntax.........: _WinAPI_FrameRect($hDC, $ptrRect, $hBrush)
; Parameters ....: $hDC     - Handle to the device context in which the border is drawn
;                  $ptrRect - Pointer to a $tagRECT structure that contains the logical coordinates of the upper-left and lower-right corners of the rectangle
;                  $hBrush  - Handle to the brush used to draw the border
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: The brush identified by the $hBrush parameter must have been created by using the _WinAPI_CreateSolidBrush function,
;                  or retrieved by using the _WinAPI_GetStockObject function
; Related .......: $tagRECT
; Link ..........: @@MsdnLink@@ FrameRect
; Example .......:
; ===============================================================================================================================
Func _WinAPI_FrameRect($hDC, $ptrRect, $hBrush)
	Local $aResult = DllCall("user32.dll", "int", "FrameRect", "handle", $hDC, "ptr", $ptrRect, "handle", $hBrush)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_FrameRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_FreeLibrary
; Description ...: Decrements the reference count of the loaded dynamic-link library (DLL) module
; Syntax.........: _WinAPI_FreeLibrary($hModule)
; Parameters ....: $hModule     - Identifies the loaded library module
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......: _WinAPI_LoadLibrary, _WinAPI_LoadLibraryEx, _WinAPI_LoadString
; Link ..........: @@MsdnLink@@ FreeLibrary
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_FreeLibrary($hModule)
	Local $aResult = DllCall("kernel32.dll", "bool", "FreeLibrary", "handle", $hModule)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_FreeLibrary

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetAncestor
; Description ...: Retrieves the handle to the ancestor of the specified window
; Syntax.........: _WinAPI_GetAncestor($hWnd[, $iFlags = 1])
; Parameters ....: $hWnd        - Handle to the window whose ancestor is to be retrieved.  If this is  the  desktop  window,  the
;                  +function returns 0.
;                  $iFlags      - Specifies the ancestor to be retrieved. This parameter can be one of the following values:
;                  |$GA_PARENT    - Retrieves the parent window
;                  |$GA_ROOT      - Retrieves the root window by walking the chain of parent windows
;                  |$GA_ROOTOWNER - Retrieves the owned root window by walking the chain of parent and owner windows returned  by
;                  +GetParent.
; Return values .: Success      - The handle of the ancestor window
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Needs WindowsConstants.au3 for pre-definded constants
; Related .......:
; Link ..........: @@MsdnLink@@ GetAncestor
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetAncestor($hWnd, $iFlags = 1)
	Local $aResult = DllCall("user32.dll", "hwnd", "GetAncestor", "hwnd", $hWnd, "uint", $iFlags)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetAncestor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetAsyncKeyState
; Description ...: Determines whether a key is up or down at the time the function is called
; Syntax.........: _WinAPI_GetAsyncKeyState($iKey)
; Parameters ....: $iKey        - Key to test for
; Return values .: Success      - If the most significant bit is set the key is down, and if the least significant bit is set,
;                  |the key was pressed after the previous call to GetAsyncKeyState.  The return value is zero if a window in
;                  |another thread or process currently has the keyboard focus.
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GetAsyncKeyState
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetAsyncKeyState($iKey)
	Local $aResult = DllCall("user32.dll", "short", "GetAsyncKeyState", "int", $iKey)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetAsyncKeyState

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetBkMode
; Description ...: Returns the current background mix mode for a specified device context
; Syntax.........: _WinAPI_GetBkMode($hDC)
; Parameters ....: $hDC - Handle to the device context whose background mode is to be returned
; Return values .: Success      - Value specifies the current background mix mode, either OPAQUE or TRANSPARENT
;                  Failure      - 0
; Author ........: Zedna
; Modified.......:
; Remarks .......: The background mix mode of a device context affects text, hatched brushes, and pen styles that are not solid lines.
; Related .......: _WinAPI_SetBkMode, _WinAPI_DrawText, _WinAPI_CreatePen, _WinAPI_SelectObject
; Link ..........: @@MsdnLink@@ GetBkMode
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetBkMode($hDC)
	Local $aResult = DllCall("gdi32.dll", "int", "GetBkMode", "handle", $hDC)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetBkMode

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetClassName
; Description ...: Retrieves the name of the class to which the specified window belongs
; Syntax.........: _WinAPI_GetClassName($hWnd)
; Parameters ....: $hWnd        - Handle of window
; Return values .: Success      - The window class name
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GetClassName
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetClassName($hWnd)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	Local $aResult = DllCall("user32.dll", "int", "GetClassNameW", "hwnd", $hWnd, "wstr", "", "int", 4096)
	If @error Then Return SetError(@error, @extended, False)
	Return SetExtended($aResult[0], $aResult[2])
EndFunc   ;==>_WinAPI_GetClassName

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetClientHeight
; Description ...: Retrieves the height of a window's client area
; Syntax.........: _WinAPI_GetClientHeight($hWnd)
; Parameters ....: $hWnd        - Handle of window
; Return values .: Success      - Client area height
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_GetClientWidth
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetClientHeight($hWnd)
	Local $tRect = _WinAPI_GetClientRect($hWnd)
	If @error Then Return SetError(@error, @extended, 0)
	Return DllStructGetData($tRect, "Bottom") - DllStructGetData($tRect, "Top")
EndFunc   ;==>_WinAPI_GetClientHeight

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetClientWidth
; Description ...: Retrieves the width of a window's client area
; Syntax.........: _WinAPI_GetClientWidth($hWnd)
; Parameters ....: $hWnd        - Handle of window
; Return values .: Success      - Client area width
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_GetClientHeight
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetClientWidth($hWnd)
	Local $tRect = _WinAPI_GetClientRect($hWnd)
	If @error Then Return SetError(@error, @extended, 0)
	Return DllStructGetData($tRect, "Right") - DllStructGetData($tRect, "Left")
EndFunc   ;==>_WinAPI_GetClientWidth

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetClientRect
; Description ...: Retrieves the coordinates of a window's client area
; Syntax.........: _WinAPI_GetClientRect($hWnd)
; Parameters ....: $hWnd        - Handle of window
; Return values .: Success      - $tagRECT structure that receives the client coordinates
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: $tagRECT
; Link ..........: @@MsdnLink@@ GetClientRect
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetClientRect($hWnd)
	Local $tRect = DllStructCreate($tagRECT)
	DllCall("user32.dll", "bool", "GetClientRect", "hwnd", $hWnd, "struct*", $tRect)
	If @error Then Return SetError(@error, @extended, 0)
	Return $tRect
EndFunc   ;==>_WinAPI_GetClientRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetCurrentProcess
; Description ...: Returns the process handle of the calling process
; Syntax.........: _WinAPI_GetCurrentProcess()
; Parameters ....:
; Return values .: Success      - Process handle of the calling process
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_GetCurrentProcessID
; Link ..........: @@MsdnLink@@ GetCurrentProcess
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetCurrentProcess()
	Local $aResult = DllCall("kernel32.dll", "handle", "GetCurrentProcess")
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetCurrentProcess

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetCurrentProcessID
; Description ...: Returns the process identifier of the calling process
; Syntax.........: _WinAPI_GetCurrentProcessID()
; Parameters ....:
; Return values .: Success      - Process identifier of the calling process
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_GetWindowThreadProcessID, _WinAPI_GetCurrentProcess
; Link ..........: @@MsdnLink@@ GetCurrentProcessId
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetCurrentProcessID()
	Local $aResult = DllCall("kernel32.dll", "dword", "GetCurrentProcessId")
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetCurrentProcessID

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetCurrentThread
; Description ...: Retrieves a pseudo handle for the calling thread.
; Syntax.........: _WinAPI_GetCurrentThread()
; Parameters ....:
; Return values .: Success      - Pseudo handle for the current thread
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: A pseudo handle is a special constant that is interpreted as the current thread handle. The calling thread can
;                  use this handle to specify itself whenever a thread handle is required.
; Related .......:
; Link ..........: @@MsdnLink@@ GetCurrentThread
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetCurrentThread()
	Local $aResult = DllCall("kernel32.dll", "handle", "GetCurrentThread")
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetCurrentThread

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetCurrentThreadId
; Description ...: Returns the thread identifier of the calling thread
; Syntax.........: _WinAPI_GetCurrentThreadId()
; Parameters ....:
; Return values .: Success      - Thread identifier of the calling thread
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GetCurrentThreadId
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetCurrentThreadId()
	Local $aResult = DllCall("kernel32.dll", "dword", "GetCurrentThreadId")
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetCurrentThreadId

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetCursorInfo
; Description ...: Retrieves information about the global cursor
; Syntax.........: _WinAPI_GetCursorInfo()
; Parameters ....:
; Return values .: Success      - Array with the following format:
;                  |$aCursor[0] - True
;                  |$aCursor[1] - True if cursor is showing, otherwise False
;                  |$aCursor[2] - Handle to the cursor
;                  |$aCursor[3] - X coordinate of the cursor
;                  |$aCursor[4] - Y coordinate of the cursor
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GetCursorInfo
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetCursorInfo()
	Local $tCursor = DllStructCreate($tagCURSORINFO)
	Local $iCursor = DllStructGetSize($tCursor)
	DllStructSetData($tCursor, "Size", $iCursor)
	DllCall("user32.dll", "bool", "GetCursorInfo", "struct*", $tCursor)
	If @error Then Return SetError(@error, @extended, 0)
	Local $aCursor[5]
	$aCursor[0] = True
	$aCursor[1] = DllStructGetData($tCursor, "Flags") <> 0
	$aCursor[2] = DllStructGetData($tCursor, "hCursor")
	$aCursor[3] = DllStructGetData($tCursor, "X")
	$aCursor[4] = DllStructGetData($tCursor, "Y")
	Return $aCursor
EndFunc   ;==>_WinAPI_GetCursorInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetDC
; Description ...: Retrieves a handle of a display device context for the client area a window
; Syntax.........: _WinAPI_GetDC($hWnd)
; Parameters ....: $hWnd        - Handle of window
; Return values .: Success      - The device context for the given window's client area
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: After painting with a common device context, the _WinAPI_ReleaseDC function must be called to release the DC
; Related .......: _WinAPI_DeleteDC, _WinAPI_ReleaseDC
; Link ..........: @@MsdnLink@@ GetDC
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetDC($hWnd)
	Local $aResult = DllCall("user32.dll", "handle", "GetDC", "hwnd", $hWnd)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetDC

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetDesktopWindow
; Description ...: Returns the handle of the Windows desktop window
; Syntax.........: _WinAPI_GetDesktopWindow()
; Parameters ....:
; Return values .: Success      - Handle of the desktop window
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GetDesktopWindow
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetDesktopWindow()
	Local $aResult = DllCall("user32.dll", "hwnd", "GetDesktopWindow")
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetDesktopWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetDeviceCaps
; Description ...: Retrieves device specific information about a specified device
; Syntax.........: _WinAPI_GetDeviceCaps($hDC, $iIndex)
; Parameters ....: $hDC         - Identifies the device context
;                  $iIndex      - Specifies the item to return
; Return values .: Success      - The value of the desired item
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GetDeviceCaps
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetDeviceCaps($hDC, $iIndex)
	Local $aResult = DllCall("gdi32.dll", "int", "GetDeviceCaps", "handle", $hDC, "int", $iIndex)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetDeviceCaps

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetDIBits
; Description ...: Retrieves the bits of the specified bitmap and copies them into a buffer as a DIB
; Syntax.........: _WinAPI_GetDIBits($hDC, $hBmp, $iStartScan, $iScanLines, $pBits, $pBI, $iUsage)
; Parameters ....: $hDC         - Handle to the device context
;                  $hBmp        - Handle to the bitmap. This must be a compatible bitmap (DDB).
;                  $iStartScan  - Specifies the first scan line to retrieve
;                  $iScanLines  - Specifies the number of scan lines to retrieve
;                  $pBits       - Pointer to a buffer to receive the bitmap data. If this parameter is 0, the function passes the
;                  +dimensions and format of the bitmap to the $tagBITMAPINFO structure pointed to by the pBI parameter.
;                  $pBI         - Pointer to a $tagBITMAPINFO structure that specifies the desired format for the DIB data
;                  $iUsage      - Specifies the format of the bmiColors member of the $tagBITMAPINFO structure. It must be one  of
;                  +the following values:
;                  |$DIB_PAL_COLORS - The color table should consist of an array of 16-bit indexes into the current palette
;                  |$DIB_RGB_COLORS - The color table should consist of literal red, green, blue values
; Return values .: Success      - If pBits is not 0 and the function succeeds, the return value is the number of scan lines
;                  |copied from the bitmap.  If pBits is 0 and GetDIBits successfully fills the structure, the return value is
;                  |True.
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: $tagBITMAPINFO
; Link ..........: @@MsdnLink@@ GetDIBits
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetDIBits($hDC, $hBmp, $iStartScan, $iScanLines, $pBits, $pBI, $iUsage)
	Local $aResult = DllCall("gdi32.dll", "int", "GetDIBits", "handle", $hDC, "handle", $hBmp, "uint", $iStartScan, "uint", $iScanLines, _
			"ptr", $pBits, "ptr", $pBI, "uint", $iUsage)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetDIBits

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetDlgCtrlID
; Description ...: Returns the identifier of the specified control
; Syntax.........: _WinAPI_GetDlgCtrlID($hWnd)
; Parameters ....: $hWnd        - Handle to control
; Return values .: Success      - Identifier of the control
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......: GetDlgCtrlID accepts child window handles as well as handles of controls in dialog boxes.  An application sets
;                  the identifier for a child window when it creates the window by assigning the identifier value  to  the  hmenu
;                  parameter when calling the CreateWindow or CreateWindowEx function.  Although GetDlgCtrlID may return a  value
;                  if $hWnd identifies a top-level window, top-level windows cannot have identifiers and such a return  value  is
;                  never valid.
; Related .......:
; Link ..........: @@MsdnLink@@ GetDlgCtrlID
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetDlgCtrlID($hWnd)
	Local $aResult = DllCall("user32.dll", "int", "GetDlgCtrlID", "hwnd", $hWnd)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetDlgCtrlID

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetDlgItem
; Description ...: Retrieves the handle of a control in the specified dialog box
; Syntax.........: _WinAPI_GetDlgItem($hWnd, $iItemID)
; Parameters ....: $hWnd        - Handle to the dialog box
;                  $iItemID     - Specifies the identifier of the control to be retrieved
; Return values .: Success      - The window handle of the given control
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: You can use the GetDlgItem function with any parent-child window pair, not just with dialog boxes.  As long as
;                  the $hWnd parameter specifies a parent window and the child window has a unique identifier, GetDlgItem returns
;                  a valid handle to the child window.
; Related .......:
; Link ..........: @@MsdnLink@@ GetDlgItem
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetDlgItem($hWnd, $iItemID)
	Local $aResult = DllCall("user32.dll", "hwnd", "GetDlgItem", "hwnd", $hWnd, "int", $iItemID)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetDlgItem

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetFocus
; Description ...: Retrieves the handle of the window that has the keyboard focus
; Syntax.........: _WinAPI_GetFocus()
; Parameters ....:
; Return values .: Success      - The handle of the window with the keyboard focus
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GetFocus
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetFocus()
	Local $aResult = DllCall("user32.dll", "hwnd", "GetFocus")
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetFocus

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetForegroundWindow
; Description ...: Returns the handle of the foreground window
; Syntax.........: _WinAPI_GetForegroundWindow()
; Parameters ....:
; Return values .: Success      - Handle of the foreground window
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GetForegroundWindow
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetForegroundWindow()
	Local $aResult = DllCall("user32.dll", "hwnd", "GetForegroundWindow")
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetForegroundWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetGuiResources
; Description ...: Retrieves the count of handles to graphical user interface (GUI) objects in use by the specified process
; Syntax.........: _WinAPI_GetGuiResources([$iflag = 1 [, $hProcess = -1}})
; Parameters ....: $iflag    - Optional: 0 (Default) Return the count of GDI objects.
;                                        1 Return the count of USER objects.
;                  $hProcess - Optional: A handle to the process. By default the current process.
; Return values .: Success      - returns the count of handles to GUI objects in use by the process, according to $iFlag
;                  Failure      - set @error
; Author ........: jpm
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GetGuiResources
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetGuiResources($iFlag = 0, $hProcess = -1)
	If $hProcess = -1 Then $hProcess = _WinAPI_GetCurrentProcess()
	Local $aResult = DllCall("user32.dll", "dword", "GetGuiResources", "handle", $hProcess, "dword", $iFlag)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetGuiResources

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetIconInfo
; Description ...: Retrieves information about the specified icon or cursor
; Syntax.........: _WinAPI_GetIconInfo($hIcon)
; Parameters ....: $hIcon       - Handle to the icon or cursor. To retrieve information on a standard icon or cursor, specify one
;                  +of the following values:
;                  |$IDC_APPSTARTING - Standard arrow and small hourglass cursor
;                  |$IDC_ARROW       - Standard arrow cursor
;                  |$IDC_CROSS       - Crosshair cursor
;                  |$IDC_HAND        - Hand cursor
;                  |$IDC_HELP        - Arrow and question mark cursor
;                  |$IDC_IBEAM       - I-beam cursor
;                  |$IDC_NO          - Slashed circle cursor
;                  |$IDC_SIZEALL     - Four-pointed arrow cursor
;                  |$IDC_SIZENESW    - Double-pointed arrow cursor pointing NE and SW
;                  |$IDC_SIZENS      - Double-pointed arrow cursor pointing N and S
;                  |$IDC_SIZENWSE    - Double-pointed arrow cursor pointing NW and SE
;                  |$IDC_SIZEWE      - Double-pointed arrow cursor pointing W and E
;                  |$IDC_UPARROW     - Vertical arrow cursor
;                  |$IDC_WAIT        - Hourglass cursor
;                  |$IDI_APPLICATION - Application icon
;                  |$IDI_ASTERISK    - Asterisk icon
;                  |$IDI_EXCLAMATION - Exclamation point icon
;                  |$IDI_HAND        - Stop sign icon
;                  |$IDI_QUESTION    - Question-mark icon
;                  |$IDI_WINLOGO     - Windows logo icon
; Return values .: Success      - Array with the following format:
;                  |$aIcon[0] - True
;                  |$aIcon[1] - True specifies an icon, False specifies a cursor
;                  |$aIcon[2] - Specifies the X coordinate of a cursor's hot spot
;                  |$aIcon[3] - Specifies the Y coordinate of a cursor's hot spot
;                  |$aIcon[4] - Specifies the icon bitmask bitmap
;                  |$aIcon[5] - Handle to the icon color bitmap
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function creates bitmaps for the bitmask and color members.  You must manage  these  bitmaps  and  delete
;                  them when they are no longer necessary.
; Related .......:
; Link ..........: @@MsdnLink@@ GetIconInfo
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetIconInfo($hIcon)
	Local $tInfo = DllStructCreate($tagICONINFO)
	DllCall("user32.dll", "bool", "GetIconInfo", "handle", $hIcon, "struct*", $tInfo)
	If @error Then Return SetError(@error, @extended, 0)
	Local $aIcon[6]
	$aIcon[0] = True
	$aIcon[1] = DllStructGetData($tInfo, "Icon") <> 0
	$aIcon[2] = DllStructGetData($tInfo, "XHotSpot")
	$aIcon[3] = DllStructGetData($tInfo, "YHotSpot")
	$aIcon[4] = DllStructGetData($tInfo, "hMask")
	$aIcon[5] = DllStructGetData($tInfo, "hColor")
	Return $aIcon
EndFunc   ;==>_WinAPI_GetIconInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetFileSizeEx
; Description ...: Retrieves the size of the specified file
; Syntax.........: _WinAPI_GetFileSizeEx($hFile)
; Parameters ....: $hFile       - Handle to the file whose size is to be returned
; Return values .: Success      - File size
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......: _WinAPI_CloseHandle, _WinAPI_CreateFile, _WinAPI_FlushFileBuffers, _WinAPI_ReadFile, _WinAPI_SetEndOfFile, _WinAPI_SetFilePointer, _WinAPI_WriteFile
; Link ..........: @@MsdnLink@@ GetFileSizeEx
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetFileSizeEx($hFile)
	Local $aResult = DllCall("kernel32.dll", "bool", "GetFileSizeEx", "handle", $hFile, "int64*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[2]
EndFunc   ;==>_WinAPI_GetFileSizeEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetLastErrorMessage
; Description ...: Returns the calling threads last error message
; Syntax.........: _WinAPI_GetLastErrorMessage()
; Parameters ....:
; Return values .: Success      - Last error message
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm, danielkza, Valik
; Remarks .......:
; Related .......: _WinAPI_GetLastError
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetLastErrorMessage()
	Local $tBufferPtr = DllStructCreate("ptr")

	Local $nCount = _WinAPI_FormatMessage(BitOR($__WINAPICONSTANT_FORMAT_MESSAGE_ALLOCATE_BUFFER, $__WINAPICONSTANT_FORMAT_MESSAGE_FROM_SYSTEM), _
			0, _WinAPI_GetLastError(), 0, $tBufferPtr, 0, 0)
	If @error Then Return SetError(@error, 0, "")

	Local $sText = ""
	Local $pBuffer = DllStructGetData($tBufferPtr, 1)
	If $pBuffer Then
		If $nCount > 0 Then
			Local $tBuffer = DllStructCreate("wchar[" & ($nCount + 1) & "]", $pBuffer)
			$sText = DllStructGetData($tBuffer, 1)
		EndIf
		_WinAPI_LocalFree($pBuffer)
	EndIf

	Return $sText
EndFunc   ;==>_WinAPI_GetLastErrorMessage

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetLayeredWindowAttributes
; Description ...: Gets Layered Window Attributes
; Syntax.........: _WinAPI_GetLayeredWindowAttributes($hWnd, ByRef $i_transcolor, ByRef $Transparency[, $asColorRef = False])
; Parameters ....: $hwnd - Handle of GUI to work on
;                  $i_transcolor - Returns Transparent color ( dword as 0x00bbggrr  or string "0xRRGGBB")
;                  $Transparency - Returns Transparancy of GUI
;                  $asColorRef   - If True, $i_transcolor will be a COLORREF( 0x00bbggrr ), else an RGB-Color
; Return values .: Success - Usage of LWA_ALPHA and LWA_COLORKEY (use BitAnd)
;                  Failure - 0, @error set to non-zero.
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......: use _WinAPI_GetLastErrorMessage to get more information
; Related .......: _WinAPI_SetLayeredWindowAttributes, _WinAPI_GetLastError
; Link ..........: @@MsdnLink@@ GetLayeredWindowAttributes
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetLayeredWindowAttributes($hWnd, ByRef $i_transcolor, ByRef $Transparency, $asColorRef = False)
	$i_transcolor = -1
	$Transparency = -1
	Local $aResult = DllCall("user32.dll", "bool", "GetLayeredWindowAttributes", "hwnd", $hWnd, "dword*", $i_transcolor, "byte*", $Transparency, "dword*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	If Not $asColorRef Then
		$aResult[2] = Int(BinaryMid($aResult[2], 3, 1) & BinaryMid($aResult[2], 2, 1) & BinaryMid($aResult[2], 1, 1))
	EndIf
	$i_transcolor = $aResult[2]
	$Transparency = $aResult[3]
	Return $aResult[4]
EndFunc   ;==>_WinAPI_GetLayeredWindowAttributes

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetModuleHandle
; Description ...: Returns a module handle for the specified module
; Syntax.........: _WinAPI_GetModuleHandle($sModuleName)
; Parameters ....: $sModuleName - Names a Win32 module (either a .DLL or .EXE file).  If the filename extension is  omitted,  the
;                  +default library extension .DLL is appended. The filename string can include a trailing point character (.) to
;                  +indicate that the module name has no extension.  The string does not have to specify  a  path.  The  name  is
;                  +compared (case independently) to the names of modules currently mapped into the address space of the  calling
;                  +process. If this parameter is 0 the function returns a handle of the file used to create the calling process.
; Return values .: Success      - The handle to the specified module
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GetModuleHandle
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetModuleHandle($sModuleName)
	Local $sModuleNameType = "wstr"
	If $sModuleName = "" Then
		$sModuleName = 0
		$sModuleNameType = "ptr"
	EndIf
	Local $aResult = DllCall("kernel32.dll", "handle", "GetModuleHandleW", $sModuleNameType, $sModuleName)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetModuleHandle

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetMousePos
; Description ...: Returns the current mouse position
; Syntax.........: _WinAPI_GetMousePos([$fToClient = False], $hWnd = 0]])
; Parameters ....: $fToClient   - If True, the coordinates will be converted to client coordinates
;                  $hWnd        - Window handle used to convert coordinates if $fToClient is True
; Return values .: Success      - $tagPOINT structure with current mouse position
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function takes into account the current MouseCoordMode setting when  obtaining  the  mouse  position.  It
;                  will also convert screen to client coordinates based on the parameters passed.
; Related .......: $tagPOINT, _WinAPI_GetMousePosX, _WinAPI_GetMousePosY
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetMousePos($fToClient = False, $hWnd = 0)
	Local $iMode = Opt("MouseCoordMode", 1)
	Local $aPos = MouseGetPos()
	Opt("MouseCoordMode", $iMode)
	Local $tPoint = DllStructCreate($tagPOINT)
	DllStructSetData($tPoint, "X", $aPos[0])
	DllStructSetData($tPoint, "Y", $aPos[1])
	If $fToClient Then
		_WinAPI_ScreenToClient($hWnd, $tPoint)
		If @error Then Return SetError(@error, @extended, 0)
	EndIf
	Return $tPoint
EndFunc   ;==>_WinAPI_GetMousePos

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetMousePosX
; Description ...: Returns the current mouse X position
; Syntax.........: _WinAPI_GetMousePosX([$fToClient = False[, $hWnd = 0]])
; Parameters ....: $fToClient   - If True, the coordinates will be converted to client coordinates
;                  $hWnd        - Window handle used to convert coordinates if $fToClient is True
; Return values .: Success      - Mouse X position
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function takes into account the current MouseCoordMode setting when  obtaining  the  mouse  position.  It
;                  will also convert screen to client coordinates based on the parameters passed.
; Related .......: _WinAPI_GetMousePos
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetMousePosX($fToClient = False, $hWnd = 0)
	Local $tPoint = _WinAPI_GetMousePos($fToClient, $hWnd)
	If @error Then Return SetError(@error, @extended, 0)
	Return DllStructGetData($tPoint, "X")
EndFunc   ;==>_WinAPI_GetMousePosX

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetMousePosY
; Description ...: Returns the current mouse Y position
; Syntax.........: _WinAPI_GetMousePosY([$fToClient = False[, $hWnd = 0]])
; Parameters ....: $fToClient   - If True, the coordinates will be converted to client coordinates
;                  $hWnd        - Window handle used to convert coordinates if $fToClient is True
; Return values .: Success      - Mouse Y position
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function takes into account the current MouseCoordMode setting when  obtaining  the  mouse  position.  It
;                  will also convert screen to client coordinates based on the parameters passed.
; Related .......: _WinAPI_GetMousePos
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetMousePosY($fToClient = False, $hWnd = 0)
	Local $tPoint = _WinAPI_GetMousePos($fToClient, $hWnd)
	If @error Then Return SetError(@error, @extended, 0)
	Return DllStructGetData($tPoint, "Y")
EndFunc   ;==>_WinAPI_GetMousePosY

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetObject
; Description ...: Retrieves information for the specified graphics object
; Syntax.........: _WinAPI_GetObject($hObject, $iSize, $pObject)
; Parameters ....: $hObject     - Identifies a logical pen, brush, font, bitmap, region, or palette
;                  $iSize       - Specifies the number of bytes to be written to the buffer
;                  $pObject     - Pointer to a buffer that receives the information.  The following shows the type of information
;                  +the buffer receives for each type of graphics object you can specify:
;                  |HBITMAP  - BITMAP or DIBSECTION
;                  |HPALETTE - A count of the number of entries in the logical palette
;                  |HPEN     - EXTLOGPEN or LOGPEN
;                  |HBRUSH   - LOGBRUSH
;                  |HFONT    - LOGFONT
;                  -
;                  |If $pObject is 0 the function return value is the number of bytes required to store the information it writes
;                  +to the buffer for the specified graphics object.
; Return values .: Success      - If $pObject is a valid pointer, the return value is the number of bytes stored into the buffer.
;                  |If the function succeeds, and $pObject is 0, the return value is the number of bytes required to hold the
;                  |information the function would store into the buffer.
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GetObject
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetObject($hObject, $iSize, $pObject)
	Local $aResult = DllCall("gdi32.dll", "int", "GetObjectW", "handle", $hObject, "int", $iSize, "ptr", $pObject)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetObject

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetOpenFileName
; Description ...: Creates an Open dialog box that lets the user specify the drive, directory, and the name of a file or set of files to open
; Syntax.........: _WinAPI_GetOpenFileName([$sTitle = ""[, $sFilter = "All files (*.*)"[, $sInitalDir = "."[, $sDefaultFile = ""[, $sDefaultExt = ""[, $iFilterIndex = 1[, $iFlags = 0[, $iFlagsEx = 0[, $hwndOwner = 0]]]]]]]]])
; Parameters ....: $sTitle       - string to be placed in the title bar of the dialog box
;                  $sFilter      - Pairs of filter strings (for example "Text Files (*.txt)|All Files (*.*)")
;                  |The first string in each pair is a display string that describes the filter (for example, "Text Files")
;                  |The second string specifies the filter pattern (for example, "*.TXT")
;                  |To specify multiple filter patterns for a single display string, use a semicolon to separate the patterns (for example, "*.TXT;*.DOC;*.BAK")
;                  |A pattern string can be a combination of valid file name characters and the asterisk (*) wildcard character
;                  |Do not include spaces in the pattern string.
;                  $sInitalDir   - String that can specify the initial directory
;                  $sDefaultFile - A file name used to initialize the File Name edit control
;                  $sDefaultExt  - String that contains the default extension
;                  $iFilterIndex - Specifies the index of the currently selected filter in the File Types control
;                  $iFlags       - See Flags in $tagOPENFILENAME information
;                  $iFlagsEx     - See FlagEx in  $tagOPENFILENAME information
;                  $hwndOwner    - Handle to the window that owns the dialog box. This member can be any valid window handle, or it can be 0 if the dialog box has no owner
; Return values .: Success      - Array in the following format:
;                  |[0] - Contains the number of strings
;                  |[1] - Contains the path selected
;                  |[2] - Contains file selected
;                  |[n] - Contains file selected
;                  Failure      - Array of 1 item set to 0
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: $tagOPENFILENAME, _WinAPI_GetSaveFileName, _WinAPI_CommDlgExtendedError
; Link ..........: @@MsdnLink@@ GetOpenFileName
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetOpenFileName($sTitle = "", $sFilter = "All files (*.*)", $sInitalDir = ".", $sDefaultFile = "", $sDefaultExt = "", $iFilterIndex = 1, $iFlags = 0, $iFlagsEx = 0, $hwndOwner = 0)
	Local $iPathLen = 4096 ; Max chars in returned string
	Local $iNulls = 0
	Local $tOFN = DllStructCreate($tagOPENFILENAME)
	Local $aFiles[1] = [0]

	Local $iFlag = $iFlags

	; Filter string to array conversion
	Local $asFLines = StringSplit($sFilter, "|")
	Local $asFilter[$asFLines[0] * 2 + 1]
	Local $iStart, $iFinal, $stFilter
	$asFilter[0] = $asFLines[0] * 2
	For $i = 1 To $asFLines[0]
		$iStart = StringInStr($asFLines[$i], "(", 0, 1)
		$iFinal = StringInStr($asFLines[$i], ")", 0, -1)
		$asFilter[$i * 2 - 1] = StringStripWS(StringLeft($asFLines[$i], $iStart - 1), 3)
		$asFilter[$i * 2] = StringStripWS(StringTrimRight(StringTrimLeft($asFLines[$i], $iStart), StringLen($asFLines[$i]) - $iFinal + 1), 3)
		$stFilter &= "wchar[" & StringLen($asFilter[$i * 2 - 1]) + 1 & "];wchar[" & StringLen($asFilter[$i * 2]) + 1 & "];"
	Next

	Local $tTitle = DllStructCreate("wchar Title[" & StringLen($sTitle) + 1 & "]")
	Local $tInitialDir = DllStructCreate("wchar InitDir[" & StringLen($sInitalDir) + 1 & "]")
	Local $tFilter = DllStructCreate($stFilter & "wchar")
	Local $tPath = DllStructCreate("wchar Path[" & $iPathLen & "]")
	Local $tExtn = DllStructCreate("wchar Extension[" & StringLen($sDefaultExt) + 1 & "]")
	For $i = 1 To $asFilter[0]
		DllStructSetData($tFilter, $i, $asFilter[$i])
	Next

	; Set Data of API structures
	DllStructSetData($tTitle, "Title", $sTitle)
	DllStructSetData($tInitialDir, "InitDir", $sInitalDir)
	DllStructSetData($tPath, "Path", $sDefaultFile)
	DllStructSetData($tExtn, "Extension", $sDefaultExt)

	DllStructSetData($tOFN, "StructSize", DllStructGetSize($tOFN))
	DllStructSetData($tOFN, "hwndOwner", $hwndOwner)
	DllStructSetData($tOFN, "lpstrFilter", DllStructGetPtr($tFilter))
	DllStructSetData($tOFN, "nFilterIndex", $iFilterIndex)
	DllStructSetData($tOFN, "lpstrFile", DllStructGetPtr($tPath))
	DllStructSetData($tOFN, "nMaxFile", $iPathLen)
	DllStructSetData($tOFN, "lpstrInitialDir", DllStructGetPtr($tInitialDir))
	DllStructSetData($tOFN, "lpstrTitle", DllStructGetPtr($tTitle))
	DllStructSetData($tOFN, "Flags", $iFlag)
	DllStructSetData($tOFN, "lpstrDefExt", DllStructGetPtr($tExtn))
	DllStructSetData($tOFN, "FlagsEx", $iFlagsEx)
	DllCall("comdlg32.dll", "bool", "GetOpenFileNameW", "struct*", $tOFN)
	If @error Then Return SetError(@error, @extended, $aFiles)
	If BitAND($iFlags, $OFN_ALLOWMULTISELECT) = $OFN_ALLOWMULTISELECT And BitAND($iFlags, $OFN_EXPLORER) = $OFN_EXPLORER Then
		For $x = 1 To $iPathLen
			If DllStructGetData($tPath, "Path", $x) = Chr(0) Then
				DllStructSetData($tPath, "Path", "|", $x)
				$iNulls += 1
			Else
				$iNulls = 0
			EndIf
			If $iNulls = 2 Then ExitLoop
		Next
		DllStructSetData($tPath, "Path", Chr(0), $x - 1)
		$aFiles = StringSplit(DllStructGetData($tPath, "Path"), "|")
		If $aFiles[0] = 1 Then Return __WinAPI_ParseFileDialogPath(DllStructGetData($tPath, "Path"))
		Return StringSplit(DllStructGetData($tPath, "Path"), "|")
	ElseIf BitAND($iFlags, $OFN_ALLOWMULTISELECT) = $OFN_ALLOWMULTISELECT Then
		$aFiles = StringSplit(DllStructGetData($tPath, "Path"), " ")
		If $aFiles[0] = 1 Then Return __WinAPI_ParseFileDialogPath(DllStructGetData($tPath, "Path"))
		Return StringSplit(StringReplace(DllStructGetData($tPath, "Path"), " ", "|"), "|")
	Else
		Return __WinAPI_ParseFileDialogPath(DllStructGetData($tPath, "Path"))
	EndIf
EndFunc   ;==>_WinAPI_GetOpenFileName

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetOverlappedResult
; Description ...: Retrieves the results of an overlapped operation
; Syntax.........: _WinAPI_GetOverlappedResult($hFile, $pOverlapped, ByRef $iBytes[, $fWait = False])
; Parameters ....: $hFile       - Handle to the file, named pipe, or communications device.  This is the  same  handle  that  was
;                  +specified when the overlapped operation was started by  a  call  to  ReadFile,  WriteFile,  ConnectNamedPipe,
;                  +TransactNamedPipe, DeviceIoControl, or WaitCommEvent.
;                  $pOverlapped - Pointer to the $tagOVERLAPPED structure that was specified when  the  overlapped  operation  was
;                  +started.
;                  $iBytes      - The number of bytes that were actually  transferred  by  a  read  or  write  operation.  For  a
;                  +TransactNamedPipe operation, this is the number of bytes that were read from the pipe.  For a DeviceIoControl
;                  +operation this is the number of bytes of output data returned by the device driver. For a ConnectNamedPipe or
;                  +WaitCommEvent operation, this value is undefined.
;                  $fWait       - If True, the function does not return until the operation has been completed.  If False and the
;                  +operation  is  still  pending,  the  function  returns  False  and  the  GetLastError  function  will  return
;                  +ERROR_IO_INCOMPLETE.
; Return values .: Success      - The number of bytes that were actually transferred by a read or write operation
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......: $tagOVERLAPPED
; Link ..........: @@MsdnLink@@ GetOverlappedResult
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetOverlappedResult($hFile, $pOverlapped, ByRef $iBytes, $fWait = False)
	Local $aResult = DllCall("kernel32.dll", "bool", "GetOverlappedResult", "handle", $hFile, "ptr", $pOverlapped, "dword*", 0, "bool", $fWait)
	If @error Then Return SetError(@error, @extended, False)
	$iBytes = $aResult[3]
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetOverlappedResult

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetParent
; Description ...: Retrieves the handle of the specified child window's parent window
; Syntax.........: _WinAPI_GetParent($hWnd)
; Parameters ....: $hWnd        - Window handle of child window
; Return values .: Success      - The handle of the parent window
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GetParent
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetParent($hWnd)
	Local $aResult = DllCall("user32.dll", "hwnd", "GetParent", "hwnd", $hWnd)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetParent

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetProcessAffinityMask
; Description ...: Obtains a affinity masks for the process and the system
; Syntax.........: _WinAPI_GetProcessAffinityMask($hProcess)
; Parameters ....: $hProcess    - An open handle to the process whose affinity mask is desired.
; Return values .: Success      - Array with the following format:
;                  |$aMask[0] - True
;                  |$aMask[1] - Process affinity mask
;                  |$aMask[2] - System affinity mask
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......: An affinity mask is a bit mask in which each bit represents a processor on which the threads  of  the  process
;                  are allowed to run.  For example, if you pass a mask of 0x05, processors 1 and 3 are allowed to run.
; Related .......:
; Link ..........: @@MsdnLink@@ GetProcessAffinityMask
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetProcessAffinityMask($hProcess)
	Local $aResult = DllCall("kernel32.dll", "bool", "GetProcessAffinityMask", "handle", $hProcess, "dword_ptr*", 0, "dword_ptr*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	Local $aMask[3]
	$aMask[0] = True
	$aMask[1] = $aResult[2]
	$aMask[2] = $aResult[3]
	Return $aMask
EndFunc   ;==>_WinAPI_GetProcessAffinityMask

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetSaveFileName
; Description ...: Creates a Save dialog box that lets the user specify the drive, directory, and name of a file to save
; Syntax.........: _WinAPI_GetSaveFileName([$sTitle = ""[, $sFilter = "All files (*.*)"[, $sInitalDir = "."[, $sDefaultFile = ""[, $sDefaultExt = ""[, $iFilterIndex = 1[, $iFlags = 0[, $iFlagsEx = 0[, $hwndOwner = 0]]]]]]]]])
; Parameters ....: $sTitle       - string to be placed in the title bar of the dialog box
;                  $sFilter      - Pairs of filter strings (for example "Text Files (*.txt)|All Files (*.*)")
;                  |The first string in each pair is a display string that describes the filter (for example, "Text Files")
;                  |The second string specifies the filter pattern (for example, "*.TXT")
;                  |To specify multiple filter patterns for a single display string, use a semicolon to separate the patterns (for example, "*.TXT;*.DOC;*.BAK")
;                  |A pattern string can be a combination of valid file name characters and the asterisk (*) wildcard character
;                  |Do not include spaces in the pattern string.
;                  $sInitalDir   - String that can specify the initial directory
;                  $sDefaultFile - A file name used to initialize the File Name edit control
;                  $sDefaultExt  - String that contains the default extension
;                  $iFilterIndex - Specifies the index of the currently selected filter in the File Types control
;                  $iFlags       - See Flags in $tagOPENFILENAME information
;                  $iFlagsEx     - See FlagEx in  $tagOPENFILENAME information
;                  $hwndOwner    - Handle to the window that owns the dialog box. This member can be any valid window handle, or it can be 0 if the dialog box has no owner
; Return values .: Success      - Array in the following format:
;                  |[0] - Contains the number of strings (2)
;                  |[1] - Contains the path selected
;                  |[2] - Contains file selected
;                  Failure      - Array of 1 item set to 0
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: $tagOPENFILENAME, _WinAPI_GetOpenFileName, _WinAPI_CommDlgExtendedError
; Link ..........: @@MsdnLink@@ GetSaveFileName
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetSaveFileName($sTitle = "", $sFilter = "All files (*.*)", $sInitalDir = ".", $sDefaultFile = "", $sDefaultExt = "", $iFilterIndex = 1, $iFlags = 0, $iFlagsEx = 0, $hwndOwner = 0)
	Local $iPathLen = 4096 ; Max chars in returned string
	Local $tOFN = DllStructCreate($tagOPENFILENAME)
	Local $aFiles[1] = [0]

	Local $iFlag = $iFlags

	; Filter string to array conversion
	Local $asFLines = StringSplit($sFilter, "|")
	Local $asFilter[$asFLines[0] * 2 + 1]
	Local $iStart, $iFinal, $stFilter
	$asFilter[0] = $asFLines[0] * 2
	For $i = 1 To $asFLines[0]
		$iStart = StringInStr($asFLines[$i], "(", 0, 1)
		$iFinal = StringInStr($asFLines[$i], ")", 0, -1)
		$asFilter[$i * 2 - 1] = StringStripWS(StringLeft($asFLines[$i], $iStart - 1), 3)
		$asFilter[$i * 2] = StringStripWS(StringTrimRight(StringTrimLeft($asFLines[$i], $iStart), StringLen($asFLines[$i]) - $iFinal + 1), 3)
		$stFilter &= "wchar[" & StringLen($asFilter[$i * 2 - 1]) + 1 & "];wchar[" & StringLen($asFilter[$i * 2]) + 1 & "];"
	Next

	Local $tTitle = DllStructCreate("wchar Title[" & StringLen($sTitle) + 1 & "]")
	Local $tInitialDir = DllStructCreate("wchar InitDir[" & StringLen($sInitalDir) + 1 & "]")
	Local $tFilter = DllStructCreate($stFilter & "wchar")
	Local $tPath = DllStructCreate("wchar Path[" & $iPathLen & "]")
	Local $tExtn = DllStructCreate("wchar Extension[" & StringLen($sDefaultExt) + 1 & "]")
	For $i = 1 To $asFilter[0]
		DllStructSetData($tFilter, $i, $asFilter[$i])
	Next

	; Set Data of API structures
	DllStructSetData($tTitle, "Title", $sTitle)
	DllStructSetData($tInitialDir, "InitDir", $sInitalDir)
	DllStructSetData($tPath, "Path", $sDefaultFile)
	DllStructSetData($tExtn, "Extension", $sDefaultExt)

	DllStructSetData($tOFN, "StructSize", DllStructGetSize($tOFN))
	DllStructSetData($tOFN, "hwndOwner", $hwndOwner)
	DllStructSetData($tOFN, "lpstrFilter", DllStructGetPtr($tFilter))
	DllStructSetData($tOFN, "nFilterIndex", $iFilterIndex)
	DllStructSetData($tOFN, "lpstrFile", DllStructGetPtr($tPath))
	DllStructSetData($tOFN, "nMaxFile", $iPathLen)
	DllStructSetData($tOFN, "lpstrInitialDir", DllStructGetPtr($tInitialDir))
	DllStructSetData($tOFN, "lpstrTitle", DllStructGetPtr($tTitle))
	DllStructSetData($tOFN, "Flags", $iFlag)
	DllStructSetData($tOFN, "lpstrDefExt", DllStructGetPtr($tExtn))
	DllStructSetData($tOFN, "FlagsEx", $iFlagsEx)
	DllCall("comdlg32.dll", "bool", "GetSaveFileNameW", "struct*", $tOFN)
	If @error Then Return SetError(@error, @extended, $aFiles)
	Return __WinAPI_ParseFileDialogPath(DllStructGetData($tPath, "Path"))
EndFunc   ;==>_WinAPI_GetSaveFileName

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetStockObject
; Description ...: Retrieves a handle to one of the predefined stock pens, brushes, fonts, or palettes
; Syntax.........: _WinAPI_GetStockObject($iObject)
; Parameters ....: $iObject     - Specifies the type of stock object. This parameter can be any one of the following values:
;                  |$BLACK_BRUSH         - Black brush
;                  |$DKGRAY_BRUSH        - Dark gray brush
;                  |$GRAY_BRUSH          - Gray brush
;                  |$HOLLOW_BRUSH        - Hollow brush (equivalent to NULL_BRUSH)
;                  |$LTGRAY_BRUSH        - Light gray brush
;                  |$NULL_BRUSH          - Null brush (equivalent to HOLLOW_BRUSH)
;                  |$WHITE_BRUSH         - White brush
;                  |$BLACK_PEN           - Black pen
;                  |$NULL_PEN            - Null pen
;                  |$WHITE_PEN           - White pen
;                  |$ANSI_FIXED_FONT     - Windows fixed-pitch (monospace) system font
;                  |$ANSI_VAR_FONT       - Windows variable-pitch (proportional space) system font
;                  |$DEVICE_DEFAULT_FONT - Device-dependent font
;                  |$DEFAULT_GUI_FONT    - Default font for user interface objects
;                  |$OEM_FIXED_FONT      - OEM dependent fixed-pitch (monospace) font
;                  |$SYSTEM_FONT         - System font
;                  |$SYSTEM_FIXED_FONT   - Fixed-pitch (monospace) system font used in Windows versions earlier than 3.0
;                  |$DEFAULT_PALETTE     - Default palette. This palette consists of the static colors in the system palette.
; Return values .: Success      - The logical object requested
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GetStockObject
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetStockObject($iObject)
	Local $aResult = DllCall("gdi32.dll", "handle", "GetStockObject", "int", $iObject)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetStockObject

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetStdHandle
; Description ...: Retrieves a handle for the standard input, standard output, or standard error device
; Syntax.........: _WinAPI_GetStdHandle($iStdHandle)
; Parameters ....: $iStdHandle  - Standard device for which a handle is to be returned. This can be one of the following values:
;                  |0 - Handle to the standard input device
;                  |1 - Handle to the standard output device
;                  |2 - Handle to the standard error device
; Return values .: Success      - Handle to the specified device
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The handle has GENERIC_READ and GENERIC_WRITE access rights, unless the application has used  SetStdHandle  to
;                  set a standard handle with lesser access.  If an application does not have associated  standard  handles,  the
;                  return value is 0.
; Related .......:
; Link ..........: @@MsdnLink@@ GetStdHandle
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetStdHandle($iStdHandle)
	If $iStdHandle < 0 Or $iStdHandle > 2 Then Return SetError(2, 0, -1)
	Local Const $aHandle[3] = [-10, -11, -12]

	Local $aResult = DllCall("kernel32.dll", "handle", "GetStdHandle", "dword", $aHandle[$iStdHandle])
	If @error Then Return SetError(@error, @extended, -1)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetStdHandle

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetSysColor
; Description ...: Retrieves the current color of the specified display element
; Syntax.........: _WinAPI_GetSysColor($iIndex)
; Parameters ....: $iIndex      - The display element whose color is to be retrieved. Can be one of the following:
;                  |$COLOR_3DDKSHADOW              - Dark shadow for three-dimensional display elements.
;                  |$COLOR_3DFACE                  - Face color for three-dimensional display elements and for dialog box backgrounds.
;                  |$COLOR_3DHIGHLIGHT             - Highlight color for three-dimensional display elements (for edges facing the light source.)
;                  |$COLOR_3DHILIGHT               - Highlight color for three-dimensional display elements (for edges facing the light source.)
;                  |$COLOR_3DLIGHT                 - Light color for three-dimensional display elements (for edges facing the light source.)
;                  |$COLOR_3DSHADOW                - Shadow color for three-dimensional display elements (for edges facing away from the light source).
;                  |$COLOR_ACTIVEBORDER            - Active window border.
;                  |$COLOR_ACTIVECAPTION           - Active window title bar.
;                  |  Specifies the left side color in the color gradient of an active window's title bar if the gradient effect is enabled.
;                  |$COLOR_APPWORKSPACE            - Background color of multiple document interface (MDI) applications.
;                  |$COLOR_BACKGROUND              - Desktop.
;                  |$COLOR_BTNFACE                 - Face color for three-dimensional display elements and for dialog box backgrounds.
;                  |$COLOR_BTNHIGHLIGHT            - Highlight color for three-dimensional display elements (for edges facing the light source.)
;                  |$COLOR_BTNHILIGHT              - Highlight color for three-dimensional display elements (for edges facing the light source.)
;                  |$COLOR_BTNSHADOW               - Shadow color for three-dimensional display elements (for edges facing away from the light source).
;                  |$COLOR_BTNTEXT                 - Text on push buttons.
;                  |$COLOR_CAPTIONTEXT             - Text in caption, size box, and scroll bar arrow box.
;                  |$COLOR_DESKTOP                 - Desktop.
;                  |$COLOR_GRADIENTACTIVECAPTION   - Right side color in the color gradient of an active window's title bar.
;                  |  $COLOR_ACTIVECAPTION specifies the left side color.
;                  |  Use SPI_GETGRADIENTCAPTIONS with the SystemParametersInfo function to determine whether the gradient effect is enabled.
;                  |$COLOR_GRADIENTINACTIVECAPTION - Right side color in the color gradient of an inactive window's title bar.
;                  |  $COLOR_INACTIVECAPTION specifies the left side color.
;                  |$COLOR_GRAYTEXT                - Grayed (disabled) text. This color is set to 0 if the current display driver does not support a solid gray color.
;                  |$COLOR_HIGHLIGHT               - Item(s) selected in a control.
;                  |$COLOR_HIGHLIGHTTEXT           - Text of item(s) selected in a control.
;                  |$COLOR_HOTLIGHT                - Color for a hyperlink or hot-tracked item.
;                  |$COLOR_INACTIVEBORDER          - Inactive window border.
;                  |$COLOR_INACTIVECAPTION         - Inactive window caption.
;                  |  Specifies the left side color in the color gradient of an inactive window's title bar if the gradient effect is enabled.
;                  |$COLOR_INACTIVECAPTIONTEXT     - Color of text in an inactive caption.
;                  |$COLOR_INFOBK                  - Background color for tooltip controls.
;                  |$COLOR_INFOTEXT                - Text color for tooltip controls.
;                  |$COLOR_MENU                    - Menu background.
;                  |$COLOR_MENUHILIGHT             - The color used to highlight menu items when the menu appears as a flat menu.
;                  |  The highlighted menu item is outlined with $COLOR_HIGHLIGHT.
;                  |  Windows 2000:  This value is not supported.
;                  |$COLOR_MENUBAR                 - The background color for the menu bar when menus appear as flat menus.
;                  |  However, $COLOR_MENU continues to specify the background color of the menu popup.
;                  |  Windows 2000:  This value is not supported.
;                  |$COLOR_MENUTEXT                - Text in menus.
;                  |$COLOR_SCROLLBAR               - Scroll bar gray area.
;                  |$COLOR_WINDOW                  - Window background.
;                  |$COLOR_WINDOWFRAME             - Window frame.
;                  |$COLOR_WINDOWTEXT              - Text in windows.
; Return values .: Success      - The red, green, blue (RGB) color value of the given element
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Requires WindowsConstants.au3 for above constants.
; Related .......: _WinAPI_SetSysColors
; Link ..........: @@MsdnLink@@ GetSysColor
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_GetSysColor($iIndex)
	Local $aResult = DllCall("user32.dll", "dword", "GetSysColor", "int", $iIndex)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetSysColor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetSysColorBrush
; Description ...: retrieves a handle identifying a logical brush that corresponds to the specified color index
; Syntax.........: _WinAPI_GetSysColorBrush($iIndex)
; Parameters ....: $iIndex      - The display element whose color is to be retrieved
; Return values .: Success      - A logical brush if $iIndex is supported by the current platform
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GetSysColorBrush
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetSysColorBrush($iIndex)
	Local $aResult = DllCall("user32.dll", "handle", "GetSysColorBrush", "int", $iIndex)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetSysColorBrush

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetSystemMetrics
; Description ...: Retrieves the specified system metric or system configuration setting
; Syntax.........: _WinAPI_GetSystemMetrics($iIndex)
; Parameters ....: $iIndex      - The system metric or configuration setting to be retrieved
; Return values .: Success      - The requested system metric
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GetSystemMetrics
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetSystemMetrics($iIndex)
	Local $aResult = DllCall("user32.dll", "int", "GetSystemMetrics", "int", $iIndex)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetSystemMetrics

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetTextExtentPoint32
; Description ...: Computes the width and height of the specified string of text
; Syntax.........: _WinAPI_GetTextExtentPoint32($hDC, $sText)
; Parameters ....: $hDC         - Identifies the device contex
;                  $sText       - String of text
; Return values .: Success      - $tagSIZE structure in which the dimensions of the string are to be returned
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......: $tagSIZE
; Link ..........: @@MsdnLink@@ GetTextExtentPoint32
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetTextExtentPoint32($hDC, $sText)
	Local $tSize = DllStructCreate($tagSIZE)
	Local $iSize = StringLen($sText)
	DllCall("gdi32.dll", "bool", "GetTextExtentPoint32W", "handle", $hDC, "wstr", $sText, "int", $iSize, "struct*", $tSize)
	If @error Then Return SetError(@error, @extended, 0)
	Return $tSize
EndFunc   ;==>_WinAPI_GetTextExtentPoint32

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetTextMetrics
; Description....: Retrieves basic information for the currently selected font.
; Syntax.........: _WinAPI_GetTextMetrics ( $hDC )
; Parameters.....: $hDC    - Handle to the device context.
; Return values..: Success - $tagTEXTMETRIC structure that contains the information about the currently selected font.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ GetTextMetrics
; Example........:
; ===============================================================================================================================
Func _WinAPI_GetTextMetrics($hDC)
	Local $tTEXTMETRIC = DllStructCreate($tagTEXTMETRIC)
	Local $Ret = DllCall('gdi32.dll', 'bool', 'GetTextMetricsW', 'handle', $hDC, 'struct*', $tTEXTMETRIC)
	If @error Then Return SetError(@error, @extended, 0)
	If Not $Ret[0] Then Return SetError(-1, 0, 0)

	Return $tTEXTMETRIC
EndFunc   ;==>_WinAPI_GetTextMetrics

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetWindow
; Description ...: Retrieves the handle of a window that has a specified relationship to the specified window
; Syntax.........: _WinAPI_GetWindow($hWnd, $iCmd)
; Parameters ....: $hWnd        - Handle of the window
;                  $iCmd        - Specifies the relationship between the specified window and the window whose handle  is  to  be
;                  +retrieved. This parameter can be one of the following values:
;                  |$GW_CHILD    - The retrieved handle identifies the child window at the top of the Z order, if  the  specified
;                  +window is a parent window; otherwise, the retrieved handle is 0.  The function examines only child windows of
;                  +the specified window. It does not examine descendant windows.
;                  |$GW_HWNDFIRST - The retrieved handle identifies the window of the same type that is highest in the  Z  order.
;                  +If the specified window is a topmost window, the handle identifies the topmost window that is highest in  the
;                  +Z order.  If the specified window is a top-level window, the handle identifies the top level window  that  is
;                  +highest in the Z order.  If the specified window is a child window, the handle identifies the sibling  window
;                  +that is highest in the Z order.
;                  |$GW_HWNDLAST - The retrieved handle identifies the window of the same type that is lowest in the Z order.  If
;                  +the specified window is a topmost window, the handle identifies the topmost window that is lowest  in  the  Z
;                  +order. If the specified window is a top-level window the handle identifies the top-level window that's lowest
;                  +in the Z order.  If the specified window is a child window, the handle identifies the sibling window  that is
;                  +lowest in the Z order.
;                  |$GW_HWNDNEXT - The retrieved handle identifies the window below the specified window in the Z order.   If the
;                  +specified window is a topmost window, the handle identifies the topmost window below the specified window. If
;                  +the specified window is a top-level window, the handle identifies the top-level  window  below  the specified
;                  +window.  If the specified window is a child window  the  handle  identifies  the  sibling  window  below  the
;                  +specified window.
;                  |$GW_HWNDPREV - The retrieved handle identifies the window above the specified window in the Z order.   If the
;                  +specified window is a topmost window, the handle identifies the topmost window above the specified window. If
;                  +the specified window is a top-level window, the handle identifies the top-level window  above  the  specified
;                  +window.  If the specified window is a child window, the  handle  identifies  the  sibling  window  above  the
;                  +specified window.
;                  |$GW_OWNER    - The retrieved handle identifies the specified window's owner window if any
; Return values .: Success      - The window handle
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Needs Constants.au3 for pre-defined constants
; Related .......:
; Link ..........: @@MsdnLink@@ GetWindow
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetWindow($hWnd, $iCmd)
	Local $aResult = DllCall("user32.dll", "hwnd", "GetWindow", "hwnd", $hWnd, "uint", $iCmd)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetWindowDC
; Description ...: Retrieves the device context (DC) for the entire window
; Syntax.........: _WinAPI_GetWindowDC($hWnd)
; Parameters ....: $hWnd        - Handle of window
; Return values .: Success      - The handle of a device context for the specified window
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: GetWindowDC is intended for special painting effects within a window's nonclient area.  Painting in  nonclient
;                  areas of any window is normally not recommended.  The GetSystemMetrics function can be used  to  retrieve  the
;                  dimensions of various parts of the nonclient area, such as  the  title  bar,  menu,  and  scroll  bars.  After
;                  painting is complete, the _WinAPI_ReleaseDC function must be called to release the device context.  Not releasing
;                  the window device context has serious effects on painting requested by applications.
; Related .......: _WinAPI_ReleaseDC
; Link ..........: @@MsdnLink@@ GetWindowDC
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetWindowDC($hWnd)
	Local $aResult = DllCall("user32.dll", "handle", "GetWindowDC", "hwnd", $hWnd)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetWindowDC

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetWindowHeight
; Description ...: Returns the height of the window
; Syntax.........: _WinAPI_GetWindowHeight($hWnd)
; Parameters ....: $hWnd        - Handle to a window
; Return values .: Success      - Height of window
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_GetWindowWidth
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetWindowHeight($hWnd)
	Local $tRect = _WinAPI_GetWindowRect($hWnd)
	If @error Then Return SetError(@error, @extended, 0)
	Return DllStructGetData($tRect, "Bottom") - DllStructGetData($tRect, "Top")
EndFunc   ;==>_WinAPI_GetWindowHeight

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetWindowLong
; Description ...: Retrieves information about the specified window
; Syntax.........: _WinAPI_GetWindowLong($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle of the window
;                  $iIndex      - Specifies the zero based offset to the value to be retrieved.  Valid values are  in  the  range
;                  +zero through the number of bytes of extra window memory, minus four; for example, if you specified 12 or more
;                  +bytes of extra memory, a value of 8 would be an index to the third 32 bit  integer.  To  retrieve  any  other
;                  +value, specify one of the following values:
;                  |$GWL_EXSTYLE    - Retrieves the extended window styles
;                  |$GWL_STYLE      - Retrieves the window styles
;                  |$GWL_WNDPROC    - Retrieves the address of the window procedure
;                  |$GWL_HINSTANCE  - Retrieves the handle of the application instance
;                  |$GWL_HWNDPARENT - Retrieves the handle of the parent window, if any
;                  |$GWL_ID         - Retrieves the identifier of the window
;                  |$GWL_USERDATA   - Retrieves the 32-bit value associated with the window
; Return values .: Success      - The requested value
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......: Needs Constants.au3 for pre-defined constants
; Related .......: _WinAPI_SetWindowLong
; Link ..........: @@MsdnLink@@ GetWindowLongPtr
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetWindowLong($hWnd, $iIndex)
	Local $sFuncName = "GetWindowLongW"
	If @AutoItX64 Then $sFuncName = "GetWindowLongPtrW"
	Local $aResult = DllCall("user32.dll", "long_ptr", $sFuncName, "hwnd", $hWnd, "int", $iIndex)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetWindowLong

; #FUNCTION# ====================================================================================
; Name...........: _WinAPI_GetWindowPlacement
; Description ...: Retrieves the placement of the window for Min, Max, and normal positions
; Syntax.........: _WinAPI_GetWindowPlacement($hWnd)
; Parameters ....: $hWnd        - Handle of the window
; Return values .: Success      - returns $tagWINDOWPLACEMENT structure with the placement coordinates
;                  Failure      - returns 0, @error = 1, @extended = _WinAPI_GetLastError()
; Author ........: PsaltyDS, with help from Siao and SmOke_N, at www.autoitscript.com/forum
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_SetWindowPlacement, $tagWINDOWPLACEMENT
; Link ..........: @@MsdnLink@@ GetWindowPlacement
; Example .......: Yes
; =============================================================================================
Func _WinAPI_GetWindowPlacement($hWnd)
	; Create struct to receive data
	Local $tWindowPlacement = DllStructCreate($tagWINDOWPLACEMENT)
	DllStructSetData($tWindowPlacement, "length", DllStructGetSize($tWindowPlacement))
	DllCall("user32.dll", "bool", "GetWindowPlacement", "hwnd", $hWnd, "struct*", $tWindowPlacement)
	If @error Then Return SetError(@error, @extended, 0)
	Return $tWindowPlacement
EndFunc   ;==>_WinAPI_GetWindowPlacement

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetWindowRect
; Description ...: Retrieves the dimensions of the bounding rectangle of the specified window
; Syntax.........: _WinAPI_GetWindowRect($hWnd)
; Parameters ....: $hWnd        - Handle of the window
; Return values .: Success      - $tagRECT structure that receives the screen coordinates
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: $tagRECT
; Link ..........: @@MsdnLink@@ GetWindowRect
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetWindowRect($hWnd)
	Local $tRect = DllStructCreate($tagRECT)
	DllCall("user32.dll", "bool", "GetWindowRect", "hwnd", $hWnd, "struct*", $tRect)
	If @error Then Return SetError(@error, @extended, 0)
	Return $tRect
EndFunc   ;==>_WinAPI_GetWindowRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetWindowRgn
; Description ...: Obtains a copy of the window region of a window
; Syntax.........: _WinAPI_GetWindowRgn($hWnd, $hRgn)
; Parameters ....: $hWnd - Handle to the window whose window region is to be obtained.
;                  $hRgn - Handle to the region which will be modified to represent the window region.
; Return values .: Success      - Specifies the type of the region that the function obtains. It can be one of the following values.
;                  |NULLREGION - The region is empty.
;                  |SIMPLEREGION - The region is a single rectangle.
;                  |COMPLEXREGION - The region is more than one rectangle.
;                  |ERRORREGION - The specified window does not have a region, or an error occurred while attempting to return the region.
;                  Failure      - 0
; Author ........: Zedna
; Modified.......:
; Remarks .......: The window region of a window is set by calling the SetWindowRgn function.
;                  The window region determines the area within the window where the system permits drawing.
;                  The system does not display any portion of a window that lies outside of the window region
;                  The coordinates of a window's window region are relative to the upper-left corner of the window, not the client area of the window.
;                  To set the window region of a window, call the SetWindowRgn function.
; Related .......: _WinAPI_CreateRectRgn, _WinAPI_CreateRoundRectRgn, _WinAPI_CombineRgn, _WinAPI_SetWindowRgn
; Link ..........: @@MsdnLink@@ GetWindowRgn
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetWindowRgn($hWnd, $hRgn)
	Local $aResult = DllCall("user32.dll", "int", "GetWindowRgn", "hwnd", $hWnd, "handle", $hRgn)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetWindowRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetWindowText
; Description ...: Retrieves the text of the specified window's title bar
; Syntax.........: _WinAPI_GetWindowText($hWnd)
; Parameters ....: $hWnd        - Handle of the window
; Return values .: Success      - Windows title bar
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GetWindowText
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetWindowText($hWnd)
	Local $aResult = DllCall("user32.dll", "int", "GetWindowTextW", "hwnd", $hWnd, "wstr", "", "int", 4096)
	If @error Then Return SetError(@error, @extended, "")
	Return SetExtended($aResult[0], $aResult[2])
EndFunc   ;==>_WinAPI_GetWindowText

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetWindowThreadProcessId
; Description ...: Retrieves the identifier of the thread that created the specified window
; Syntax.........: _WinAPI_GetWindowThreadProcessId($hWnd, ByRef $iPID)
; Parameters ....: $hWnd        - Window handle
;                  $iPID        - Process ID of the specified window
; Return values .: Success      - Thread ID of the specified window
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......: _WinAPI_GetCurrentProcessID
; Link ..........: @@MsdnLink@@ GetWindowThreadProcessId
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetWindowThreadProcessId($hWnd, ByRef $iPID)
	Local $aResult = DllCall("user32.dll", "dword", "GetWindowThreadProcessId", "hwnd", $hWnd, "dword*", 0)
	If @error Then Return SetError(@error, @extended, 0)
	$iPID = $aResult[2]
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GetWindowThreadProcessId

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetWindowWidth
; Description ...: Returns the width of the window
; Syntax.........: _WinAPI_GetWindowWidth($hWnd)
; Parameters ....: $hWnd        - Handle to a window
; Return values .: Success      - Width of window
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_GetWindowHeight
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetWindowWidth($hWnd)
	Local $tRect = _WinAPI_GetWindowRect($hWnd)
	If @error Then Return SetError(@error, @extended, 0)
	Return DllStructGetData($tRect, "Right") - DllStructGetData($tRect, "Left")
EndFunc   ;==>_WinAPI_GetWindowWidth

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GetXYFromPoint
; Description ...: Returns the X/Y values from a $tagPOINT structure
; Syntax.........: _WinAPI_GetXYFromPoint(ByRef $tPoint, ByRef $iX, ByRef $iY)
; Parameters ....: $tPoint      - $tagPOINT structure
;                  $iX          - X value
;                  $iY          - Y value
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function extracts the X/Y values from a $tagPOINT structure
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GetXYFromPoint(ByRef $tPoint, ByRef $iX, ByRef $iY)
	$iX = DllStructGetData($tPoint, "X")
	$iY = DllStructGetData($tPoint, "Y")
EndFunc   ;==>_WinAPI_GetXYFromPoint

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GlobalMemoryStatus
; Description ...: Retrieves information about current available memory
; Syntax.........: _WinAPI_GlobalMemoryStatus()
; Parameters ....:
; Return values .: Success      - Array with the following format:
;                  |$aMem[0] - Percent of Mem in use
;                  |$aMem[1] - Physical Mem: Total
;                  |$aMem[2] - Physical Mem: Free
;                  |$aMem[3] - Paging file: Total
;                  |$aMem[4] - Paging file: Free
;                  |$aMem[5] - User Mem: Total
;                  |$aMem[6] - User Mem: Free
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......: Unlike the AutoIt MemGetStats() function, this function returns the values in bytes
; Related .......:
; Link ..........: @@MsdnLink@@ GlobalMemoryStatusEx
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GlobalMemoryStatus()
	Local $tMem = DllStructCreate($tagMEMORYSTATUSEX)
	Local $iMem = DllStructGetSize($tMem)
	DllStructSetData($tMem, 1, $iMem)
	DllCall("kernel32.dll", "none", "GlobalMemoryStatusEx", "ptr", $tMem)
	If @error Then Return SetError(@error, @extended, 0)
	Local $aMem[7]
	$aMem[0] = DllStructGetData($tMem, 2)
	$aMem[1] = DllStructGetData($tMem, 3)
	$aMem[2] = DllStructGetData($tMem, 4)
	$aMem[3] = DllStructGetData($tMem, 5)
	$aMem[4] = DllStructGetData($tMem, 6)
	$aMem[5] = DllStructGetData($tMem, 7)
	$aMem[6] = DllStructGetData($tMem, 8)
	Return $aMem
EndFunc   ;==>_WinAPI_GlobalMemoryStatus

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GUIDFromString
; Description ...: Converts a string GUID to binary form
; Syntax.........: _WinAPI_GUIDFromString($sGUID)
; Parameters ....: $sGUID       - GUID in string form
; Return values .: Success      - $tagGUID structure
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_StringFromGUID, $tagGUID
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GUIDFromString($sGUID)
	Local $tGUID = DllStructCreate($tagGUID)
	_WinAPI_GUIDFromStringEx($sGUID, $tGUID)
	If @error Then Return SetError(@error, @extended, 0)
	Return $tGUID
EndFunc   ;==>_WinAPI_GUIDFromString

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_GUIDFromStringEx
; Description ...: Converts a string GUID to binary form
; Syntax.........: _WinAPI_GUIDFromStringEx($sGUID, $pGUID)
; Parameters ....: $sGUID       - GUID in string form
;                  $pGUID       - Pointer to a $tagGUID structure where the GUID will be stored
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_StringFromGUID, $tagGUID
; Link ..........: @@MsdnLink@@ CLSIDFromString
; Example .......:
; ===============================================================================================================================
Func _WinAPI_GUIDFromStringEx($sGUID, $pGUID)
	Local $aResult = DllCall("ole32.dll", "long", "CLSIDFromString", "wstr", $sGUID, "struct*", $pGUID)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_GUIDFromStringEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_HiWord
; Description ...: Returns the high word of a longword value
; Syntax.........: _WinAPI_HiWord($iLong)
; Parameters ....: $iLong       - Longword value
; Return values .: Success      - High order word of the longword value
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_LoWord, _WinAPI_MakeLong
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_HiWord($iLong)
	Return BitShift($iLong, 16)
EndFunc   ;==>_WinAPI_HiWord

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_InProcess
; Description ...: Determines whether a window belongs to the current process
; Syntax.........: _WinAPI_InProcess($hWnd, ByRef $hLastWnd)
; Parameters ....: $hWnd        - Window handle to be tested
;                  $hLastWnd    - Last window tested. If $hWnd = $hLastWnd, this process will immediately return True. Otherwise,
;                  +_WinAPI_InProcess will be called. If $hWnd is in process, $hLastWnd will be set to $hWnd on return.
; Return values .: True         - Window handle belongs to the current process
;                  False        - Window handle does not belong to the current process
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This is one of the key functions to the control memory mapping technique.  It checks the process ID of the
;                  window to determine if it belongs to the current process, which means it can be accessed without mapping the control memory.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_InProcess($hWnd, ByRef $hLastWnd)
	If $hWnd = $hLastWnd Then Return True
	For $iI = $__gaInProcess_WinAPI[0][0] To 1 Step -1
		If $hWnd = $__gaInProcess_WinAPI[$iI][0] Then
			If $__gaInProcess_WinAPI[$iI][1] Then
				$hLastWnd = $hWnd
				Return True
			Else
				Return False
			EndIf
		EndIf
	Next
	Local $iProcessID
	_WinAPI_GetWindowThreadProcessId($hWnd, $iProcessID)
	Local $iCount = $__gaInProcess_WinAPI[0][0] + 1
	If $iCount >= 64 Then $iCount = 1
	$__gaInProcess_WinAPI[0][0] = $iCount
	$__gaInProcess_WinAPI[$iCount][0] = $hWnd
	$__gaInProcess_WinAPI[$iCount][1] = ($iProcessID = @AutoItPID)
	Return $__gaInProcess_WinAPI[$iCount][1]
EndFunc   ;==>_WinAPI_InProcess

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IntToFloat
; Description ...: Returns a 4 byte integer as a float value
; Syntax.........: _WinAPI_IntToFloat($iInt)
; Parameters ....: $iInt    - Integer value
; Return values .: Success      - 4 byte integer value as a float
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_IntToFloat($iInt)
	Local $tInt = DllStructCreate("int")
	Local $tFloat = DllStructCreate("float", DllStructGetPtr($tInt))
	DllStructSetData($tInt, 1, $iInt)
	Return DllStructGetData($tFloat, 1)
EndFunc   ;==>_WinAPI_IntToFloat

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IsClassName
; Description ...: Wrapper to check ClassName of the control.
; Syntax.........: _WinAPI_IsClassName($hWnd, $sClassName)
; Parameters ....: $hWnd        - Handle to a control
;                  $sClassName  - Class name to check
; Return values .: True         - $sClassName matches ClassName retrieved from $hWnd
;                  False        - $sClassName does not match ClassName retrieved from $hWnd
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Used for checking correct $hWnd is passed into function
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_IsClassName($hWnd, $sClassName)
	Local $sSeparator = Opt("GUIDataSeparatorChar")
	Local $aClassName = StringSplit($sClassName, $sSeparator)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	Local $sClassCheck = _WinAPI_GetClassName($hWnd) ; ClassName from Handle
	; check array of ClassNames against ClassName Returned
	For $x = 1 To UBound($aClassName) - 1
		If StringUpper(StringMid($sClassCheck, 1, StringLen($aClassName[$x]))) = StringUpper($aClassName[$x]) Then Return True
	Next
	Return False
EndFunc   ;==>_WinAPI_IsClassName

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IsWindow
; Description ...: Determines whether the specified window handle identifies an existing window
; Syntax.........: _WinAPI_IsWindow($hWnd)
; Parameters ....: $hWnd        - Handle to be tested
; Return values .: Success      - Handle is a window
;                  Failure      - Handle is not a window
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ IsWindow
; Example .......:
; ===============================================================================================================================
Func _WinAPI_IsWindow($hWnd)
	Local $aResult = DllCall("user32.dll", "bool", "IsWindow", "hwnd", $hWnd)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_IsWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_IsWindowVisible
; Description ...: Retrieves the visibility state of the specified window
; Syntax.........: _WinAPI_IsWindowVisible($hWnd)
; Parameters ....: $hWnd        - Handle of window
; Return values .: True         - Window is visible
;                  Failse       - Window is not visible
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The visibility state of a window is indicated by the $WS_VISIBLE style bit. When $WS_VISIBLE is set, the window
;                  is displayed and subsequent drawing into it is displayed as long as the window has the $WS_VISIBLE style.
; Related .......:
; Link ..........: @@MsdnLink@@ IsWindowVisible
; Example .......:
; ===============================================================================================================================
Func _WinAPI_IsWindowVisible($hWnd)
	Local $aResult = DllCall("user32.dll", "bool", "IsWindowVisible", "hwnd", $hWnd)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_IsWindowVisible

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_InvalidateRect
; Description ...: Adds a rectangle to the specified window's update region
; Syntax.........: _WinAPI_InvalidateRect($hWnd[, $tRect = 0[, $fErase = True]])
; Parameters ....: $hWnd        - Handle to windows
;                  $tRect       - $tagRECT structure that contains the client coordinates of the rectangle  to  be  added  to  the
;                  +update region. If this parameter is 0 the entire client area is added to the update region.
;                  $fErase      - Specifies whether the background within the update region is  to  be  erased  when  the  update
;                  +region is processed.  If this parameter is True the background is erased  when  the  BeginPaint  function  is
;                  +called. If this parameter is False, the background remains unchanged.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......: $tagRECT
; Link ..........: @@MsdnLink@@ InvalidateRect
; Example .......:
; ===============================================================================================================================
Func _WinAPI_InvalidateRect($hWnd, $tRect = 0, $fErase = True)
	Local $aResult = DllCall("user32.dll", "bool", "InvalidateRect", "hwnd", $hWnd, "struct*", $tRect, "bool", $fErase)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_InvalidateRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LineTo
; Description ...: Draws a line from the current position up to, but not including, the specified point.
; Syntax.........: _WinAPI_LineTo($hDC, $iX, $iY)
; Parameters ....: $hDC - Handle to device context
;                  $iX - X coordinate of the line's ending point.
;                  $iY - Y coordinate of the line's ending point.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Zedna
; Modified.......:
; Remarks .......: The line is drawn by using the current pen and, if the pen is a geometric pen, the current brush.
;                  If LineTo succeeds, the current position is set to the specified ending point.
; Related .......: _WinAPI_MoveTo, _WinAPI_DrawLine, _WinAPI_SelectObject, _WinAPI_CreatePen
; Link ..........: @@MsdnLink@@ LineTo
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_LineTo($hDC, $iX, $iY)
	Local $aResult = DllCall("gdi32.dll", "bool", "LineTo", "handle", $hDC, "int", $iX, "int", $iY)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_LineTo

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LoadBitmap
; Description ...: Loads the specified bitmap resource from a module's executable file
; Syntax.........: _WinAPI_LoadBitmap($hInstance, $sBitmap)
; Parameters ....: $hInstance   - Handle to the instance of the module whose executable file contains the bitmap to be loaded
;                  $sBitmap      - The name of the bitmap resource to be loaded.  Alternatively this can consist of the  resource
;                  +identifier in the low order word and 0 in the high order word.
; Return values .: Success      - The handle to the specified bitmap
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ LoadBitmap
; Example .......:
; ===============================================================================================================================
Func _WinAPI_LoadBitmap($hInstance, $sBitmap)
	Local $sBitmapType = "int"
	If IsString($sBitmap) Then $sBitmapType = "wstr"
	Local $aResult = DllCall("user32.dll", "handle", "LoadBitmapW", "handle", $hInstance, $sBitmapType, $sBitmap)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_LoadBitmap

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LoadImage
; Description ...: Loads an icon, cursor, or bitmap
; Syntax.........: _WinAPI_LoadImage($hInstance, $sImage, $iType, $iXDesired, $iYDesired, $iLoad)
; Parameters ....: $hInstance   - Identifies an instance of the module that contains the image to  be  loaded.  To  load  an  OEM
;                  +image, set this parameter to zero.
;                  $sImage      - Identifies the image to load.  If the $hInstance parameter is not 0 and  the  $iLoad  parameter
;                  + does not include $LR_LOADFROMFILE $sImage is a string that contains the name of the  image  resource  in  the
;                  + $hInstance module.  If $hInstance is 0 and $LR_LOADFROMFILE is not specified,  the  low-order  word  of  this
;                  + parameter must be the identifier of the OEM image to load.
;                  $iType       - Specifies the type of image to be loaded.  This parameter can be one of the following values:
;                  |$IMAGE_BITMAP - Loads a bitmap
;                  |$IMAGE_CURSOR - Loads a cursor
;                  |$IMAGE_ICON   - Loads an icon
;                  $iXDesired   - Specifies the width, in pixels, of the icon or cursor.  If this is 0
;                  + and $iLoad is LR_DEFAULTSIZE the function uses the SM_CXICON or SM_CXCURSOR system
;                  + metric value to set the width.   If this parameter is 0 and LR_DEFAULTSIZE is  not
;                  + used, the function uses the actual resource width.
;                  $iYDesired   - Specifies the height, in pixels, of the icon or cursor. If this is 0
;                  + and $iLoad is LR_DEFAULTSIZE the function uses the SM_CYICON or SM_CYCURSOR system
;                  + metric value to set the height.   If this parameter is 0 and LR_DEFAULTSIZE is not
;                  + used, the function uses the actual resource height.
;                  $iLoad       - Specifies a combination of the following values:
;                  |$LR_DEFAULTCOLOR     - The default flag
;                  |$LR_CREATEDIBSECTION - When the $iType parameter specifies $IMAGE_BITMAP, causes the function to return a DIB
;                  +section bitmap rather than a compatible bitmap.  This flag is useful for loading a bitmap without mapping  it
;                  +to the colors of the display device.
;                  |$LR_DEFAULTSIZE      - Uses the width or height specified by the system metric values for cursors or icons if
;                  +the $iXDesired or $iYDesired values are set to 0. If this flag is not specified and $iXDesired and $iYDesired
;                  +are set to zero, the function uses the actual resource size. If the resource  contains  multiple  images  the
;                  +function uses the size of the first image.
;                  |$LR_LOADFROMFILE     - Loads the image from the file specified by the $sImage parameter.  If this flag is not
;                  +specified, $sImage is the name of the resource.
;                  |$LR_LOADMAP3DCOLORS  - Searches the color table for the image and replaces the following shades of gray  with
;                  +the corresponding 3D color:
;                  | Dk Gray: RGB(128,128,128) COLOR_3DSHADOW
;                  | Gray   : RGB(192,192,192) COLOR_3DFACE
;                  | Lt Gray: RGB(223,223,223) COLOR_3DLIGHT
;                  |$LR_LOADTRANSPARENT - Gets the color value of the first pixel in the image  and  replaces  the  corresponding
;                  +entry in the color table with the default window color.  All pixels in the image that use that  entry  become
;                  +the default window color. This value applies only to images that have corresponding color tables.  If  $iLoad
;                  +includes both the $LR_LOADTRANSPARENT and $LR_LOADMAP3DCOLORS values,  $LRLOADTRANSPARENT  takes  precedence.
;                  +However, the color table entry is replaced with COLOR_3DFACE rather than COLOR_WINDOW.
;                  |$LR_MONOCHROME      - Loads the image in black and white
;                  |$LR_SHARED          - Shares the image handle if the image is loaded multiple times. If LR_SHARED is not set,
;                  +a second call to LoadImage for the same resource will load the image again and return a different handle.  Do
;                  +not use $LR_SHARED for images that have non-standard sizes, that may change after loading, or that are loaded
;                  +from a file.
; Return values .: Success      - The handle of the newly loaded image
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Needs Constants.au3 for pre-definded constants
; Related .......:
; Link ..........: @@MsdnLink@@ LoadImage
; Example .......:
; ===============================================================================================================================
Func _WinAPI_LoadImage($hInstance, $sImage, $iType, $iXDesired, $iYDesired, $iLoad)
	Local $aResult, $sImageType = "int"
	If IsString($sImage) Then $sImageType = "wstr"
	$aResult = DllCall("user32.dll", "handle", "LoadImageW", "handle", $hInstance, $sImageType, $sImage, "uint", $iType, "int", $iXDesired, _
			"int", $iYDesired, "uint", $iLoad)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_LoadImage

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LoadLibrary
; Description ...: Maps a specified executable module into the address space of the calling process
; Syntax.........: _WinAPI_LoadLibrary($sFileName)
; Parameters ....: $sFileName   - Names a Win32 executable module (either a .DLL or an .EXE file).  The  name  specified  is  the
;                  +filename of the executable module.
; Return values .: Success      - A handle to the executable module
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_LoadLibraryEx, _WinAPI_FreeLibrary
; Link ..........: @@MsdnLink@@ LoadLibrary
; Example .......:
; ===============================================================================================================================
Func _WinAPI_LoadLibrary($sFileName)
	Local $aResult = DllCall("kernel32.dll", "handle", "LoadLibraryW", "wstr", $sFileName)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_LoadLibrary

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LoadLibraryEx
; Description ...: Maps a specified executable module into the address space of the calling process
; Syntax.........: _WinAPI_LoadLibraryEx($sFileName[, $iFlags = 0])
; Parameters ....: $sFileName   - Names a Win32 executable module (either a .DLL or an .EXE file).  The  name  specified  is  the
;                  +filename of the executable module.
;                  $iFlags      - Specifies the action to take when loading  the  module.  This  parameter  can  be  one  of  the
;                  +following values:
;                  |$DONT_RESOLVE_DLL_REFERENCES   - If this value is used and the executable module is a DLL  the  system  does
;                  +not call DllMain for process and thread initialization and  termination.  Also,  the  system  does  not  load
;                  +additional executable modules that are referenced by the specified module.
;                  |$LOAD_LIBRARY_AS_DATAFILE      - If this value is used, the system maps the file into the  calling  process's
;                  +address space as if it were a data file.  Nothing is done to execute or prepare to execute the mapped file.
;                  |$LOAD_WITH_ALTERED_SEARCH_PATH - If this value is used, and $FileName specifies a path, the system  uses  the
;                  +alternate file search strategy to find the associated executable modules that the specified module causes  to
;                  +be loaded.
; Return values .: Success      - A handle to the executable module
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Needs Constants.au3 for pre-defined constants
; Related .......: _WinAPI_LoadLibrary, _WinAPI_FreeLibrary, _WinAPI_LoadString
; Link ..........: @@MsdnLink@@ LoadLibraryEx
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_LoadLibraryEx($sFileName, $iFlags = 0)
	Local $aResult = DllCall("kernel32.dll", "handle", "LoadLibraryExW", "wstr", $sFileName, "ptr", 0, "dword", $iFlags)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_LoadLibraryEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LoadShell32Icon
; Description ...: Extracts an icon from the Shell32.dll file
; Syntax.........: _WinAPI_LoadShell32Icon($iIconID)
; Parameters ....: $iIconID     - ID of the icon to extract
; Return values .: Success      - Handle to the specified icon
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: When you are done with the icon, call _WinAPI_DestroyIcon to release the icon handle
; Related .......: _WinAPI_DestroyIcon
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_LoadShell32Icon($iIconID)
	Local $tIcons = DllStructCreate("ptr Data")
	Local $iIcons = _WinAPI_ExtractIconEx("shell32.dll", $iIconID, 0, $tIcons, 1)
	If @error Then Return SetError(@error, @extended, 0)
	If $iIcons <= 0 Then Return SetError(1, 0, 0)
	Return DllStructGetData($tIcons, "Data")
EndFunc   ;==>_WinAPI_LoadShell32Icon

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LoadString
; Description ...: loads a string resource from the executable file associated with a specified module
; Syntax.........: _WinAPI_LoadString($hInstance, $iStringId)
; Parameters ....: $hInstance   - Handle to an instance of the module whose executable file contains the string resource
;                  $iStringId   - Specifies the integer identifier of the string to be loaded
; Return values .: Success      - The string requested, @extended is the number of TCHARS copied
;                  Failure      - Empty string and @error is set
; Author ........: Gary Frost used correct syntax, Original concept Raik
; Modified.......: jpm
; Remarks .......:
; Related .......: _WinAPI_LoadLibraryEx, _WinAPI_FreeLibrary
; Link ..........: @@MsdnLink@@ LoadString
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_LoadString($hInstance, $iStringId)
	Local $aResult = DllCall("user32.dll", "int", "LoadStringW", "handle", $hInstance, "uint", $iStringId, "wstr", "", "int", 4096)
	If @error Then Return SetError(@error, @extended, "")
	Return SetExtended($aResult[0], $aResult[3])
EndFunc   ;==>_WinAPI_LoadString

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LocalFree
; Description ...: Frees the specified local memory object and invalidates its handle
; Syntax.........: _WinAPI_LocalFree($hMem)
; Parameters ....: $hMem        - A handle to the local memory object
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ LocalFree
; Example .......:
; ===============================================================================================================================
Func _WinAPI_LocalFree($hMem)
	Local $aResult = DllCall("kernel32.dll", "handle", "LocalFree", "handle", $hMem)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_LocalFree

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LoWord
; Description ...: Returns the low word of a longword
; Syntax.........: _WinAPI_LoWord($iLong)
; Parameters ....: $iLong       - Longword value
; Return values .: Success      - Low order word of the longword value
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_HiWord, _WinAPI_MakeLong
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_LoWord($iLong)
	Return BitAND($iLong, 0xFFFF)
EndFunc   ;==>_WinAPI_LoWord

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_MAKELANGID
; Description ...: Construct language id from a primary language id and a sublanguage id
; Syntax.........: _WinAPI_MAKELANGID($lgidPrimary, $lgidSub)
; Parameters ....: $lgidPrimary - Primary Language id
;                  $lgidSub     - Sub-Language id
; Return values .: Success      - Language identifier
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_MAKELANGID($lgidPrimary, $lgidSub)
	Return BitOR(BitShift($lgidSub, -10), $lgidPrimary)
EndFunc   ;==>_WinAPI_MAKELANGID

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_MAKELCID
; Description ...: Construct locale id from a language id and a sort id
; Syntax.........: _WinAPI_MAKELCID($lgid, $srtid)
; Parameters ....: $lgid        - Language id
;                  $srtid       - Sort id
; Return values .: Success      - Locale identifier
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_MAKELCID($lgid, $srtid)
	Return BitOR(BitShift($srtid, -16), $lgid)
EndFunc   ;==>_WinAPI_MAKELCID

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_MakeLong
; Description ...: Returns a longint value from two int values
; Syntax.........: _WinAPI_MakeLong($iLo, $iHi)
; Parameters ....: $iLo         - Low word
;                  $iHi         - Hi word
; Return values .: Success      - Longint value
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_HiWord, _WinAPI_LoWord
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_MakeLong($iLo, $iHi)
	Return BitOR(BitShift($iHi, -16), BitAND($iLo, 0xFFFF))
EndFunc   ;==>_WinAPI_MakeLong

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_MakeQWord
; Description ...: Returns a QWORD value from two int values
; Syntax.........: _WinAPI_MakeQWord($LoDWORD, $HiDWORD)
; Parameters ....: $LoDWORD         - Low DWORD (int)
;                  $HiDWORD         - Hi DWORD (int)
; Return values .: Success      - QWORD (int64) value
; Author ........: jpm
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _WinAPI_MakeQWord($LoDWORD, $HiDWORD)
	Local $tInt64 = DllStructCreate("uint64")
	Local $tDwords = DllStructCreate("dword;dword", DllStructGetPtr($tInt64))
	DllStructSetData($tDwords, 1, $LoDWORD)
	DllStructSetData($tDwords, 2, $HiDWORD)
	Return DllStructGetData($tInt64, 1)
EndFunc   ;==>_WinAPI_MakeQWord

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_MessageBeep
; Description ...: Plays a waveform sound
; Syntax.........: _WinAPI_MessageBeep([$iType = 1])
; Parameters ....: $iType       - The sound type, as identified by an entry in the registry.  This can be one  of  the  following
;                  +values:
;                  |0 - Simple beep. If a sound card is not available, the speaker is used.
;                  |1 - OK
;                  |2 - Hand
;                  |3 - Question
;                  |4 - Exclamation
;                  |5 - Asterisk
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: After queuing the sound, the MessageBeep function returns control to the calling function and plays the  sound
;                  asynchronously.  If it cannot play the specified alert sound, MessageBeep attempts to play the system  default
;                  sound.  If it cannot play the system default sound, the function produces a standard beep  sound  through  the
;                  computer speaker.
; Related .......:
; Link ..........: @@MsdnLink@@ MessageBeep
; Example .......:
; ===============================================================================================================================
Func _WinAPI_MessageBeep($iType = 1)
	Local $iSound
	Switch $iType
		Case 1
			$iSound = 0
		Case 2
			$iSound = 16
		Case 3
			$iSound = 32
		Case 4
			$iSound = 48
		Case 5
			$iSound = 64
		Case Else
			$iSound = -1
	EndSwitch

	Local $aResult = DllCall("user32.dll", "bool", "MessageBeep", "uint", $iSound)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_MessageBeep

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_MsgBox
; Description ...: Displays a message box with wider margin than original
; Syntax.........: _WinAPI_MsgBox($iFlags, $sTitle, $sText)
; Parameters ....: $iFlags      - Flags to use during window creation
;                  $sTitle      - Window title
;                  $sText       - Window text
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function produces (IMO) a better looking message box.  It also makes sure that BlockInput is  turned  off
;                  so the user can move the mouse.
; Related .......: _WinAPI_ShowMsg, _WinAPI_ShowError
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_MsgBox($iFlags, $sTitle, $sText)
	BlockInput(0)
	MsgBox($iFlags, $sTitle, $sText & "      ")
EndFunc   ;==>_WinAPI_MsgBox

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_Mouse_Event
; Description ...: Synthesizes mouse motion and button clicks
; Syntax.........: _WinAPI_Mouse_Event($iFlags[, $iX = 0[, $iY = 0[, $iData = 0[, $iExtraInfo = 0]]]])
; Parameters ....: $iFlags      - A set of flag bits that specify various aspects of mouse motion and button clicking.  The  bits
;                  +in this parameter can be any reasonable combination of the following values:
;                  |$MOUSEEVENTF_ABSOLUTE   - Specifies that the $iX and $iY parameters contain normal absolute  coordinates.  If
;                  +not set, those parameters contain relative data.  The change in position since the  last  reported  position.
;                  +This flag can be set, or not set, regardless of what kind of mouse or mouse-like device, if any, is connected
;                  +to the system.
;                  |$MOUSEEVENTF_ABSOLUTE   - Specifies that the dx and dy parameters contain normalized absolute coordinates.
;                  +If not set, those parameters contain relative data: the change in position since the last reported position.
;                  +This flag can be set, or not set, regardless of what kind of mouse or mouse-like device, if any, is connected to the system.
;                  |$MOUSEEVENTF_MOVE       - Specifies that movement occurred
;                  |$MOUSEEVENTF_LEFTDOWN   - Specifies that the left button changed to down
;                  |$MOUSEEVENTF_LEFTUP     - Specifies that the left button changed to up
;                  |$MOUSEEVENTF_RIGHTDOWN  - Specifies that the right button changed to down
;                  |$MOUSEEVENTF_RIGHTUP    - Specifies that the right button changed to up
;                  |$MOUSEEVENTF_MIDDLEDOWN - Specifies that the middle button changed to down
;                  |$MOUSEEVENTF_MIDDLEUP   - Specifies that the middle button changed to up
;                  |$MOUSEEVENTF_WHEEL      - Specifies that the wheel has been moved, if the mouse has a wheel
;                  |$MOUSEEVENTF_XDOWN      - Specifies that an X button was pressed
;                  |$MOUSEEVENTF_XUP        - Specifies that an X button was released
;                  $iX           - Specifies the mouse's absolute position along the X axis or its amount  of  motion  since  the
;                  +last mouse event was generated depending on the setting of $MOUSEEVENTF_ABSOLUTE.  Absolute data is given  as
;                  +the mouse's actual X coordinate relative data is given as the number of mickeys moved.
;                  $iY           - Specifies the mouse's absolute position along the Y axis or its amount  of  motion  since  the
;                  +last mouse event was generated depending on the setting of $MOUSEEVENTF_ABSOLUTE.  Absolute data is given  as
;                  +the mouse's actual Y coordinate relative data is given as the number of mickeys moved.
;                  $iData        - If iFlags is $MOUSEEVENTF_WHEEL, then iData specifies the amount of wheel movement. A positive
;                  +value indicates that the wheel was rotated forward away from the user.  A negative value indicates  that  the
;                  +wheel was rotated backward, toward the user. One wheel click is defined as $WHEEL_DELTA, which  is  120.   If
;                  +iFlags is not $MOUSEEVENTF_WHEEL, then $iData should be zero.
;                  $iExtraInfo   - Specifies a 32 bit value associated with the mouse event
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......: Needs Constants.au3 for pre-defined constants
; Related .......:
; Link ..........: @@MsdnLink@@ mouse_event
; Example .......:
; ===============================================================================================================================
Func _WinAPI_Mouse_Event($iFlags, $iX = 0, $iY = 0, $iData = 0, $iExtraInfo = 0)
	DllCall("user32.dll", "none", "mouse_event", "dword", $iFlags, "dword", $iX, "dword", $iY, "dword", $iData, "ulong_ptr", $iExtraInfo)
	If @error Then Return SetError(@error, @extended)
EndFunc   ;==>_WinAPI_Mouse_Event

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_MoveTo
; Description ...: Updates the current position to the specified point
; Syntax.........: _WinAPI_MoveTo($hDC, $iX, $iY)
; Parameters ....: $hDC - Handle to device context
;                  $iX - X coordinate of the new position.
;                  $iY - Y coordinate of the new position.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Zedna
; Modified.......:
; Remarks .......: The MoveTo function affects all drawing functions.
; Related .......: _WinAPI_LineTo, _WinAPI_DrawLine, _WinAPI_SelectObject, _WinAPI_CreatePen
; Link ..........: @@MsdnLink@@ MoveToEx
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_MoveTo($hDC, $iX, $iY)
	Local $aResult = DllCall("gdi32.dll", "bool", "MoveToEx", "handle", $hDC, "int", $iX, "int", $iY, "ptr", 0)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_MoveTo

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_MoveWindow
; Description ...: Changes the position and dimensions of the specified window
; Syntax.........: _WinAPI_MoveWindow($hWnd, $iX, $iY, $iWidth, $iHeight[, $fRepaint = True])
; Parameters ....: $hWnd        - Handle of window
;                  $iX          - New position of the left side of the window
;                  $iY          - New position of the top of the window
;                  $iWidth      - New width of the window
;                  $iHeight     - New height of the window
;                  $fRepaint    - Specifies whether the window is to be repainted.  If True,  the  window  receives  a  $WM_PAINT
;                  +message. If False, no repainting of any kind occurs. This applies to the client area, the nonclient area, and
;                  +any part of the parent window uncovered as a result of moving a child window. If False, the application  must
;                  +explicitly invalidate or redraw any parts of the window and parent window that need redrawing.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ MoveWindow
; Example .......:
; ===============================================================================================================================
Func _WinAPI_MoveWindow($hWnd, $iX, $iY, $iWidth, $iHeight, $fRepaint = True)
	Local $aResult = DllCall("user32.dll", "bool", "MoveWindow", "hwnd", $hWnd, "int", $iX, "int", $iY, "int", $iWidth, "int", $iHeight, "bool", $fRepaint)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_MoveWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_MulDiv
; Description ...: Multiplies two 32-bit values and then divides the 64-bit result by a third 32-bit value
; Syntax.........: _WinAPI_MulDiv($iNumber, $iNumerator, $iDenominator)
; Parameters ....: $iNumber      - Specifies the multiplicand
;                  $iNumerator   - Specifies the multiplier
;                  $iDenominator - Specifies the number by which the result of the multiplication is to be divided
; Return values .: Success      - The result of the multiplication and division
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ MulDiv
; Example .......:
; ===============================================================================================================================
Func _WinAPI_MulDiv($iNumber, $iNumerator, $iDenominator)
	Local $aResult = DllCall("kernel32.dll", "int", "MulDiv", "int", $iNumber, "int", $iNumerator, "int", $iDenominator)
	If @error Then Return SetError(@error, @extended, -1)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_MulDiv

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_MultiByteToWideChar
; Description ...: Maps a character string to a wide-character (Unicode) string
; Syntax.........: _WinAPI_MultiByteToWideChar($sText[, $iCodePage = 0[, $iFlags = 0 [, $bRetString = False]]])
; Parameters ....: $sText       - Text to be converted
;                  $iCodePage   - Specifies the code page to be used to perform the conversion:
;                  |0 - ANSI code page
;                  |1 - OEM code page
;                  |2 - Macintosh code page
;                  $iFlags      - Flags that indicate whether to translate to precomposed or composite wide characters:
;                  |$MB_PRECOMPOSED   - Always use precomposed characters
;                  |$MB_COMPOSITE     - Always use composite characters
;                  |$MB_USEGLYPHCHARS - Use glyph characters instead of control characters
;                  $bRetString   - Specifies if a string or a structure must be returned (default False = structure)
; Return values .: Success      - Structure that contains the Unicode character string
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm, Alexander Samuelsson (AdmiralAlkex)
; Remarks .......:
; Related .......: _WinAPI_WideCharToMultiByte, _WinAPI_MultiByteToWideCharEx
; Link ..........: @@MsdnLink@@ MultiByteToWideChar
; Example .......:
; ===============================================================================================================================
Func _WinAPI_MultiByteToWideChar($sText, $iCodePage = 0, $iFlags = 0, $bRetString = False)
	Local $sTextType = "str"
	If Not IsString($sText) Then $sTextType = "struct*"

	; compute size for the output WideChar
	Local $aResult = DllCall("kernel32.dll", "int", "MultiByteToWideChar", "uint", $iCodePage, "dword", $iFlags, $sTextType, $sText, _
			"int", -1, "ptr", 0, "int", 0)
	If @error Then Return SetError(@error, @extended, 0)

	; allocate space for output WideChar
	Local $iOut = $aResult[0]
	Local $tOut = DllStructCreate("wchar[" & $iOut & "]")

	$aResult = DllCall("kernel32.dll", "int", "MultiByteToWideChar", "uint", $iCodePage, "dword", $iFlags, $sTextType, $sText, _
			"int", -1, "struct*", $tOut, "int", $iOut)
	If @error Then Return SetError(@error, @extended, 0)

	If $bRetString Then Return DllStructGetData($tOut, 1)
	Return $tOut
EndFunc   ;==>_WinAPI_MultiByteToWideChar

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_MultiByteToWideCharEx
; Description ...: Maps a character string to a wide-character (Unicode) string
; Syntax.........: _WinAPI_MultiByteToWideCharEx($sText, $pText[, $iCodePage = 0[, $iFlags = 0]])
; Parameters ....: $sText       - Text to be converted
;                  $pText       - Pointer to a byte structure where the converted string will be stored
;                  $iCodePage   - Specifies the code page to be used to perform the conversion:
;                  |0 - ANSI code page
;                  |1 - OEM code page
;                  |2 - Macintosh code page
;                  $iFlags      - Flags that indicate whether to translate to precomposed or composite wide characters:
;                  |$MB_PRECOMPOSED   - Always use precomposed characters
;                  |$MB_COMPOSITE     - Always use composite characters
;                  |$MB_USEGLYPHCHARS - Use glyph characters instead of control characters
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The byte structure must be at least twice the length of $sText
; Related .......: _WinAPI_MultiByteToWideChar
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_MultiByteToWideCharEx($sText, $pText, $iCodePage = 0, $iFlags = 0)
	Local $aResult = DllCall("kernel32.dll", "int", "MultiByteToWideChar", "uint", $iCodePage, "dword", $iFlags, "STR", $sText, "int", -1, _
			"struct*", $pText, "int", (StringLen($sText) + 1) * 2)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_MultiByteToWideCharEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_OpenProcess
; Description ...: Returns a handle of an existing process object
; Syntax.........: _WinAPI_OpenProcess($iAccess, $fInherit, $iProcessID[, $fDebugPriv = False])
; Parameters ....: $iAccess     - Specifies the access to the process object
;                  $fInherit    - Specifies whether the returned handle can be inherited
;                  $iProcessID  - Specifies the process identifier of the process to open
;                  $fDebugPriv  - Certain system processes can not be opened unless you have the  debug  security  privilege.  If
;                  +True, this function will attempt to open the process with debug priviliges if the process can not  be  opened
;                  +with standard access privileges.
; Return values .: Success      - Process handle to the object
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ OpenProcess
; Example .......:
; ===============================================================================================================================
Func _WinAPI_OpenProcess($iAccess, $fInherit, $iProcessID, $fDebugPriv = False)
	; Attempt to open process with standard security priviliges
	Local $aResult = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $iAccess, "bool", $fInherit, "dword", $iProcessID)
	If @error Then Return SetError(@error, @extended, 0)
	If $aResult[0] Then Return $aResult[0]
	If Not $fDebugPriv Then Return 0

	; Enable debug privileged mode
	Local $hToken = _Security__OpenThreadTokenEx(BitOR($TOKEN_ADJUST_PRIVILEGES, $TOKEN_QUERY))
	If @error Then Return SetError(@error, @extended, 0)
	_Security__SetPrivilege($hToken, "SeDebugPrivilege", True)
	Local $iError = @error
	Local $iLastError = @extended
	Local $iRet = 0
	If Not @error Then
		; Attempt to open process with debug privileges
		$aResult = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $iAccess, "bool", $fInherit, "dword", $iProcessID)
		$iError = @error
		$iLastError = @extended
		If $aResult[0] Then $iRet = $aResult[0]

		; Disable debug privileged mode
		_Security__SetPrivilege($hToken, "SeDebugPrivilege", False)
		If @error Then
			$iError = @error
			$iLastError = @extended
		EndIf
	EndIf
	_WinAPI_CloseHandle($hToken)

	Return SetError($iError, $iLastError, $iRet)
EndFunc   ;==>_WinAPI_OpenProcess

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __WinAPI_ParseFileDialogPath
; Description ...: Returns array from the path string
; Syntax.........: __WinAPI_ParseFileDialogPath($sPath)
; Parameters ....: $sPath       - string conataining the path and file(s)
; Return values .: Success      - array containing path and file(s)
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __WinAPI_ParseFileDialogPath($sPath)
	Local $aFiles[3]
	$aFiles[0] = 2
	Local $stemp = StringMid($sPath, 1, StringInStr($sPath, "\", 0, -1) - 1)
	$aFiles[1] = $stemp
	$aFiles[2] = StringMid($sPath, StringInStr($sPath, "\", 0, -1) + 1)
	Return $aFiles
EndFunc   ;==>__WinAPI_ParseFileDialogPath

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PathFindOnPath
; Description ...: Searchs for a file in the default system paths
; Syntax.........: _WinAPI_PathFindOnPath($szFile, $aExtraPaths="", $szPathDelimiter=@LF)
; Parameters ....: $szFile          - Filename to search for
;                  $aExtraPaths     - Extra paths to check before any others.
;                  $szPathDelimiter - Delimiter used to split $aExtraPaths if it's an non-empty string (StringSplit with flag 2).
; Return values .: Success      - Full path of found file
;                  Failure      - Unchanged filename, @error=1
; Author ........: Daniel Miranda (danielkza)
; Modified.......:
; Remarks .......: $aExtraPaths can contain a list of paths to be checked before any system defaults.
;                  It can be an array or a string. If the former, it shall not have a count in it's first element.
;                  If the latter, it will be split using $szPathDelimiter as the delimiter, that defaults to @LF.
; Related .......:
; Link ..........; @@MsdnLink@@ PathFindOnpath
; Example .......; Yes
; ===============================================================================================================================

Func _WinAPI_PathFindOnPath(Const $szFile, $aExtraPaths = "", Const $szPathDelimiter = @LF)
	Local $iExtraCount = 0
	If IsString($aExtraPaths) Then
		If StringLen($aExtraPaths) Then
			$aExtraPaths = StringSplit($aExtraPaths, $szPathDelimiter, 1 + 2)
			$iExtraCount = UBound($aExtraPaths, 1)
		EndIf
	ElseIf IsArray($aExtraPaths) Then
		$iExtraCount = UBound($aExtraPaths)
	EndIf

	Local $tPaths, $tPathPtrs
	If $iExtraCount Then
		Local $szStruct = ""
		For $path In $aExtraPaths
			$szStruct &= "wchar[" & StringLen($path) + 1 & "];"
		Next

		$tPaths = DllStructCreate($szStruct)
		$tPathPtrs = DllStructCreate("ptr[" & $iExtraCount + 1 & "]")

		For $i = 1 To $iExtraCount
			DllStructSetData($tPaths, $i, $aExtraPaths[$i - 1])
			DllStructSetData($tPathPtrs, 1, DllStructGetPtr($tPaths, $i), $i)
		Next
		DllStructSetData($tPathPtrs, 1, Ptr(0), $iExtraCount + 1)
	EndIf

	Local $aResult = DllCall("shlwapi.dll", "bool", "PathFindOnPathW", "wstr", $szFile, "struct*", $tPathPtrs)
	If @error Then Return SetError(@error, @extended, False)
	If $aResult[0] = 0 Then Return SetError(1, 0, $szFile)

	Return $aResult[1]
EndFunc   ;==>_WinAPI_PathFindOnPath

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PointFromRect
; Description ...: Returns the top/left coordinates of a $tagRECT as a $tagPOINT structure
; Syntax.........: _WinAPI_PointFromRect(ByRef $tRect[, $fCenter = True])
; Parameters ....: $tRect       - $tagRECT structure
;                  $fCenter     - If True, the return will be a point at the center of  the  rectangle,  otherwise  the  left/top
;                  +coordinates are returned.
; Return values .: Success      - $tagPOINT structure
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function is used to get the click position for many of the click functions
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_PointFromRect(ByRef $tRect, $fCenter = True)
	Local $iX1 = DllStructGetData($tRect, "Left")
	Local $iY1 = DllStructGetData($tRect, "Top")
	Local $iX2 = DllStructGetData($tRect, "Right")
	Local $iY2 = DllStructGetData($tRect, "Bottom")
	If $fCenter Then
		$iX1 = $iX1 + (($iX2 - $iX1) / 2)
		$iY1 = $iY1 + (($iY2 - $iY1) / 2)
	EndIf
	Local $tPoint = DllStructCreate($tagPOINT)
	DllStructSetData($tPoint, "X", $iX1)
	DllStructSetData($tPoint, "Y", $iY1)
	Return $tPoint
EndFunc   ;==>_WinAPI_PointFromRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PostMessage
; Description ...: Places a message in the message queue and then returns
; Syntax.........: _WinAPI_PostMessage($hWnd, $iMsg, $iwParam, $ilParam)
; Parameters ....: $hWnd        - Identifies the window whose window procedure will receive the message.  If this parameter is
;                  +0xFFFF (HWND_BROADCAST), the message is sent to all top-level windows in the system, including disabled or invisible
;                  +unowned windows, overlapped windows, and pop-up windows; but the message is not sent to child windows.
;                  $iMsg        - Specifies the message to be sent
;                  $iwParam     - First message parameter
;                  $ilParam     - Second message parameter
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ PostMessageA
; Example .......:
; ===============================================================================================================================
Func _WinAPI_PostMessage($hWnd, $iMsg, $iwParam, $ilParam)
	Local $aResult = DllCall("user32.dll", "bool", "PostMessage", "hwnd", $hWnd, "uint", $iMsg, "wparam", $iwParam, "lparam", $ilParam)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_PostMessage

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PrimaryLangId
; Description ...: Extract primary language id from a language id
; Syntax.........: _WinAPI_PrimaryLangId($lgid)
; Parameters ....: $lgid        - Language id
; Return values .: Success      - Primary language id
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_PrimaryLangId($lgid)
	Return BitAND($lgid, 0x3FF)
EndFunc   ;==>_WinAPI_PrimaryLangId

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_PtInRect
; Description ...: Determines whether the specified point lies within the specified rectangle
; Syntax.........: _WinAPI_PtInRect(ByRef $tRect, ByRef $tPoint)
; Parameters ....: $tRect       - $tagRECT structure that contains the specified rectangle
;                  $tPoint      - $tagPOINT structure that contains the specified point
; Return values .: True  - Point lies within the rectangle
;                  False - Point does not lie within the rectangle
; Author ........: Paul Campbell (PaulIA)
; Modified.......: trancexx
; Remarks .......:
; Related .......: $tagRECT, $tagPOINT
; Link ..........: @@MsdnLink@@ PtInRect
; Example .......:
; ===============================================================================================================================
Func _WinAPI_PtInRect(ByRef $tRect, ByRef $tPoint)
	Local $aResult = DllCall("user32.dll", "bool", "PtInRect", "struct*", $tRect, "struct", $tPoint)
	If @error Then Return SetError(1, @extended, False)
	Return Not ($aResult[0] = 0)
EndFunc   ;==>_WinAPI_PtInRect

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ReadFile
; Description ...: Reads data from a file
; Syntax.........: _WinAPI_ReadFile($hFile, $pBuffer, $iToRead, ByRef $iRead[, $pOverlapped = 0])
; Parameters ....: $hFile       - Handle to the file to be read
;                  $pBuffer     - Pointer to the buffer that receives the data read from a file
;                  $iToRead     - Maximum number of bytes to read
;                  $iRead       - Number of bytes read
;                  $pOverlapped - Pointer to a $tagOVERLAPPED structure
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......: $tagOVERLAPPED, _WinAPI_CloseHandle, _WinAPI_CreateFile, _WinAPI_FlushFileBuffers, _WinAPI_GetFileSizeEx, _WinAPI_SetEndOfFile, _WinAPI_SetFilePointer, _WinAPI_WriteFile
; Link ..........: @@MsdnLink@@ ReadFile
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_ReadFile($hFile, $pBuffer, $iToRead, ByRef $iRead, $pOverlapped = 0)
	Local $aResult = DllCall("kernel32.dll", "bool", "ReadFile", "handle", $hFile, "ptr", $pBuffer, "dword", $iToRead, "dword*", 0, "ptr", $pOverlapped)
	If @error Then Return SetError(@error, @extended, False)
	$iRead = $aResult[4]
	Return $aResult[0]
EndFunc   ;==>_WinAPI_ReadFile

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ReadProcessMemory
; Description ...: Reads memory in a specified process
; Syntax.........: _WinAPI_ReadProcessMemory($hProcess, $pBaseAddress, $pBuffer, $iSize, ByRef $iRead)
; Parameters ....: $hProcess     - Identifies an open handle of a process whose memory is read
;                  $pBaseAddress - Points to the base address in the specified process to be read
;                  $pBuffer      - Points to a buffer that receives the contents from the address space
;                  $iSize        - Specifies the requested number of bytes to read from the specified process
;                  $iRead        - The actual number of bytes transferred into the specified buffer
; Return values .: Success       - True
;                  Failure       - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......: _WinAPI_WriteProcessMemory
; Link ..........: @@MsdnLink@@ ReadProcessMemory
; Example .......:
; ===============================================================================================================================
Func _WinAPI_ReadProcessMemory($hProcess, $pBaseAddress, $pBuffer, $iSize, ByRef $iRead)
	Local $aResult = DllCall("kernel32.dll", "bool", "ReadProcessMemory", "handle", $hProcess, _
			"ptr", $pBaseAddress, "ptr", $pBuffer, "ulong_ptr", $iSize, "ulong_ptr*", 0)
	If @error Then Return SetError(@error, @extended, False)
	$iRead = $aResult[5]
	Return $aResult[0]
EndFunc   ;==>_WinAPI_ReadProcessMemory

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RectIsEmpty
; Description ...: Determins whether a rectangle is empty
; Syntax.........: _WinAPI_RectIsEmpty(ByRef $tRect)
; Parameters ....: $tRect       - $tagRect structure
; Return values .: True         - Rectangle is empty (all values are zero)
;                  False        - Rectangle is not empty
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: $tagRect
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_RectIsEmpty(ByRef $tRect)
	Return (DllStructGetData($tRect, "Left") = 0) And (DllStructGetData($tRect, "Top") = 0) And _
			(DllStructGetData($tRect, "Right") = 0) And (DllStructGetData($tRect, "Bottom") = 0)
EndFunc   ;==>_WinAPI_RectIsEmpty

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RedrawWindow
; Description ...: Updates the specified rectangle or region in a window's client area
; Syntax.........: _WinAPI_RedrawWindow($hWnd[, $tRect = 0[, $hRegion = 0[, $iFlags = 5]]])
; Parameters ....: $hWnd        - Handle to a Window
;                  $tRect       - $tagRECT structure containing the  coordinates  of  the  update  rectangle.  This  parameter  is
;                  +ignored if the $hRegion parameter identifies a region.
;                  $hRegion     - Identifies the update region.  If the $hRegion and $tRect parameters are 0, the  entire  client
;                  +area is added to the update region.
;                  $iFlags      - Specifies the redraw flags.  This parameter can be a combination of flags  that  invalidate  or
;                  +validate a window, control repainting, and control which windows are affected:
;                  |$RDW_ERASE           - Causes the window to receive a WM_ERASEBKGND message when the window is repainted
;                  |$RDW_FRAME           - Causes any part of the nonclient area of the window that intersects the update  region
;                  +to receive a WM_NCPAINT message.
;                  |$RDW_INTERNALPAINT   - Causes a WM_PAINT message to be posted to the window regardless of whether any portion
;                  +of the window is invalid.
;                  |$RDW_INVALIDATE      - Invalidates DllStructGetData($tRect or $hRegion, "") If both are 0, the entire window is invalidated.
;                  |$RDW_NOERASE         - Suppresses any pending $WM_ERASEBKGND messages
;                  |$RDW_NOFRAME         - Suppresses any pending $WM_NCPAINT messages
;                  |$RDW_NOINTERNALPAINT - Suppresses any pending internal $WM_PAINT messages
;                  |$RDW_VALIDATE        - Validates $tRect or $hRegion
;                  |$RDW_ERASENOW        - Causes the affected windows to receive $WM_NCPAINT  and  $WM_ERASEBKGND  messages,  if
;                  +necessary, before the function returns
;                  |$RDW_UPDATENOW       - Causes the affected windows to  receive  $WM_NCPAINT,  $WM_ERASEBKGND,  and  $WM_PAINT
;                  +messages, if necessary, before the function returns.
;                  |$RDW_ALLCHILDREN     - Includes child windows in the repainting operation
;                  |$RDW_NOCHILDREN      - Excludes child windows from the repainting operation
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: When RedrawWindow is used to invalidate part of the desktop window, the desktop  window  does  not  receive  a
;                  $WM_PAINT message. To repaint the desktop an application uses the $RDW_ERASE flag to generate a $WM_ERASEBKGND
;                  message.
;+
;                  Needs WindowsConstants.au3 for pre-defined constants
; Related .......: $tagRECT
; Link ..........: @@MsdnLink@@ RedrawWindow
; Example .......:
; ===============================================================================================================================
Func _WinAPI_RedrawWindow($hWnd, $tRect = 0, $hRegion = 0, $iFlags = 5)
	Local $aResult = DllCall("user32.dll", "bool", "RedrawWindow", "hwnd", $hWnd, "struct*", $tRect, "handle", $hRegion, "uint", $iFlags)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_RedrawWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_RegisterWindowMessage
; Description ...: Defines a new window message that is guaranteed to be unique throughout the system
; Syntax.........: _WinAPI_RegisterWindowMessage($sMessage)
; Parameters ....: $sMessage    - String that specifies the message to be registered
; Return values .: Success      - A message identifier in the range 0xC000 through 0xFFFF
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The RegisterWindowMessage function is used to register messages  for  communicating  between  two  cooperating
;                  applications. If two different applications register the same message string, the applications return the same
;                  message  value. The message remains registered until the session ends.
; Related .......:
; Link ..........: @@MsdnLink@@ RegisterWindowMessage
; Example .......:
; ===============================================================================================================================
Func _WinAPI_RegisterWindowMessage($sMessage)
	Local $aResult = DllCall("user32.dll", "uint", "RegisterWindowMessageW", "wstr", $sMessage)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_RegisterWindowMessage

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ReleaseCapture
; Description ...: Releases the mouse capture from a window in the current thread and restores normal mouse input processing
; Syntax.........: _WinAPI_ReleaseCapture()
; Parameters ....:
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ ReleaseCapture
; Example .......:
; ===============================================================================================================================
Func _WinAPI_ReleaseCapture()
	Local $aResult = DllCall("user32.dll", "bool", "ReleaseCapture")
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_ReleaseCapture

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ReleaseDC
; Description ...: Releases a device context
; Syntax.........: _WinAPI_ReleaseDC($hWnd, $hDC)
; Parameters ....: $hWnd        - Handle of window
;                  $hDC         - Identifies the device context to be released
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The application must call the _WinAPI_ReleaseDC function for each call to the _WinAPI_GetWindowDC function  and  for
;                  each call to the _WinAPI_GetDC function that retrieves a common device context.
; Related .......: _WinAPI_GetDC, _WinAPI_GetWindowDC, _WinAPI_DeleteDC
; Link ..........: @@MsdnLink@@ ReleaseDC
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_ReleaseDC($hWnd, $hDC)
	Local $aResult = DllCall("user32.dll", "int", "ReleaseDC", "hwnd", $hWnd, "handle", $hDC)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_ReleaseDC

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ScreenToClient
; Description ...: Converts screen coordinates of a specified point on the screen to client coordinates
; Syntax.........: _WinAPI_ScreenToClient($hWnd, ByRef $tPoint)
; Parameters ....: $hWnd        - Identifies the window that be used for the conversion
;                  $tPoint      - $tagPOINT structure that contains the screen coordinates to be converted
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The function uses the window identified by the $hWnd  parameter  and  the  screen  coordinates  given  in  the
;                  $tagPOINT structure to compute client coordinates.  It then replaces the screen  coordinates  with  the  client
;                  coordinates. The new coordinates are relative to the upper-left corner of the specified window's client area.
; Related .......: _WinAPI_ClientToScreen, $tagPOINT
; Link ..........: @@MsdnLink@@ ScreenToClient
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_ScreenToClient($hWnd, ByRef $tPoint)
	Local $aResult = DllCall("user32.dll", "bool", "ScreenToClient", "hwnd", $hWnd, "struct*", $tPoint)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_ScreenToClient

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SelectObject
; Description ...: Selects an object into the specified device context
; Syntax.........: _WinAPI_SelectObject($hDC, $hGDIObj)
; Parameters ....: $hDC         - Identifies the device context
;                  $hGDIObj     - Identifies the object to be selected
; Return values .: Success      - The handle of the object being replaced
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_CreatePen, _WinAPI_DrawLine, _WinAPI_GetBkMode, _WinAPI_LineTo, _WinAPI_MoveTo, _WinAPI_SetBkMode
; Link ..........: @@MsdnLink@@ SelectObject
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_SelectObject($hDC, $hGDIObj)
	Local $aResult = DllCall("gdi32.dll", "handle", "SelectObject", "handle", $hDC, "handle", $hGDIObj)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SelectObject

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetBkColor
; Description ...: Sets the current background color to the specified color value
; Syntax.........: _WinAPI_SetBkColor($hDC, $iColor)
; Parameters ....: $hDC         - Handle to the device context
;                  $iColor      - Specifies the new background color
; Return values .: Success      - The previous background color
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ SetBkColor
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_SetBkColor($hDC, $iColor)
	Local $aResult = DllCall("gdi32.dll", "INT", "SetBkColor", "handle", $hDC, "dword", $iColor)
	If @error Then Return SetError(@error, @extended, -1)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetBkColor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetBkMode
; Description ...: Sets the background mix mode of the specified device context
; Syntax.........: _WinAPI_SetBkMode($hDC, $iBkMode)
; Parameters ....: $hDC - Handle to device context
;                  $iBkMode - Specifies the background mix mode. This parameter can be one of the following values.
;                  |OPAQUE - Background is filled with the current background color before the text, hatched brush, or pen is drawn.
;                  |TRANSPARENT - Background remains untouched.
; Return values .: Success      - Value specifies the previous background mix mode.
;                  Failure      - 0
; Author ........: Zedna
; Modified.......:
; Remarks .......: The background mix mode is used with text, hatched brushes, and pen styles that are not solid lines.
;                  The SetBkMode function affects the line styles for lines drawn using a pen created by the CreatePen function.
;                  SetBkMode does not affect lines drawn using a pen created by the ExtCreatePen function.
;                  The $iBkMode parameter can also be set to driver-specific values. GDI passes such values to the device driver and otherwise ignores them.
; Related .......: _WinAPI_GetBkMode, _WinAPI_DrawText, _WinAPI_CreatePen, _WinAPI_SelectObject
; Link ..........: @@MsdnLink@@ SetBkMode
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_SetBkMode($hDC, $iBkMode)
	Local $aResult = DllCall("gdi32.dll", "int", "SetBkMode", "handle", $hDC, "int", $iBkMode)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetBkMode

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetCapture
; Description ...: Sets the mouse capture to the specified window belonging to the current thread
; Syntax.........: _WinAPI_SetCapture($hWnd)
; Parameters ....: $hWnd        - Handle to the window in the current thread that is to capture the mouse
; Return values .: Success      - handle to the window that had previously captured the mouse
;                  Failure      - 0
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ SetCapture
; Example .......:
; ===============================================================================================================================
Func _WinAPI_SetCapture($hWnd)
	Local $aResult = DllCall("user32.dll", "hwnd", "SetCapture", "hwnd", $hWnd)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetCapture

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetCursor
; Description ...: Establishes the cursor shape
; Syntax.........: _WinAPI_SetCursor($hCursor)
; Parameters ....: $hCursor     - Identifies the cursor
; Return values .: Success      - The handle of the previous cursor, if there was one.  If there  was  no  previous  cursor,  the
;                  +return value is 0.
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ SetCursor
; Example .......:
; ===============================================================================================================================
Func _WinAPI_SetCursor($hCursor)
	Local $aResult = DllCall("user32.dll", "handle", "SetCursor", "handle", $hCursor)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetCursor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetDefaultPrinter
; Description ...: Sets the default printer for the current user on the local computer
; Syntax.........: _WinAPI_SetDefaultPrinter($sPrinter)
; Parameters ....: $sPrinter    - The default printer name. For a remote printer, the name format is \\server\printername.  For a
;                  +local printer, the name format is printername.  If this parameter is "", this function does nothing if  there
;                  +is already a default printer. However, if there is no default printer, this function sets the default printer
;                  +to the first printer, if any, in an enumeration of printers installed on the local computer.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ SetDefaultPrinter
; Example .......:
; ===============================================================================================================================
Func _WinAPI_SetDefaultPrinter($sPrinter)
	Local $aResult = DllCall("winspool.drv", "bool", "SetDefaultPrinterW", "wstr", $sPrinter)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetDefaultPrinter

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetDIBits
; Description ...: Sets the pixels in a compatible bitmap using the color data found in a DIB
; Syntax.........: _WinAPI_SetDIBits($hDC, $hBmp, $iStartScan, $iScanLines, $pBits, $pBMI[, $iColorUse = 0])
; Parameters ....: $hDC         - Handle to a device context
;                  $hBmp        - Handle to the compatible bitmap (DDB) that is to be altered using the color data from the DIB
;                  $iStartScan  - Specifies the starting scan line for the device-independent color data in the array pointed  to
;                  +by the pBits parameter.
;                  $iScanLines  - Specifies the number of scan lines found in the array containing device-independent color data
;                  $pBits       - Pointer to the DIB color data, stored as an array of bytes.  The format of  the  bitmap  values
;                  +depends on the biBitCount member of the $tagBITMAPINFO structure pointed to by the pBMI parameter.
;                  $pBMI        - Pointer to a $tagBITMAPINFO structure that contains information about the DIB
;                  $iColorUse   - Specifies whether the iColors member of the $tagBITMAPINFO structure was provided  and,  if  so,
;                  +whether iColors contains explicit red, green, blue (RGB) values or palette indexes.  The iColorUse  parameter
;                  +must be one of the following values:
;                  |0 - The color table is provided and contains literal RGB values
;                  |1 - The color table consists of an array of 16-bit indexes into the logical palette of hDC
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The device context identified by the hDC parameter is used only if the iColorUse is set to 1, otherwise it  is
;                  ignored.  The bitmap identified by the hBmp parameter must not be selected into a  device  context  when  this
;                  function is called. The scan lines must be aligned on a DWORD except for RLE compressed  bitmaps.  The  origin
;                  for bottom up DIBs is the lower left corner of the bitmap; the origin for top down  DIBs  is  the  upper  left
;                  corner of the bitmap.
; Related .......: $tagBITMAPINFO
; Link ..........: @@MsdnLink@@ SetDIBits
; Example .......:
; ===============================================================================================================================
Func _WinAPI_SetDIBits($hDC, $hBmp, $iStartScan, $iScanLines, $pBits, $pBMI, $iColorUse = 0)
	Local $aResult = DllCall("gdi32.dll", "int", "SetDIBits", "handle", $hDC, "handle", $hBmp, "uint", $iStartScan, "uint", $iScanLines, _
			"ptr", $pBits, "ptr", $pBMI, "uint", $iColorUse)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetDIBits

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetEndOfFile
; Description ...: Sets the physical file size for the specified file to the current position of the file pointer.
; Syntax.........: _WinAPI_SetEndOfFile($hFile)
; Parameters ....: $hFile - Handle to the file to be extended or truncated.
;                  +The file handle must have the $GENERIC_WRITE access right.
; Return values .: Success - True
;                  Failure - False, Use GetLastError() to get details
; Author ........: Zedna
; Modified.......:
; Remarks .......: This function can be used to truncate or extend a file.
;                  +If the file is extended, the contents of the file between the old end of the file and the new end of the file are not defined.
;                  +This function sets the file size.
; Related .......: _WinAPI_CloseHandle, _WinAPI_CreateFile, _WinAPI_FlushFileBuffers, _WinAPI_GetFileSizeEx, _WinAPI_ReadFile, _WinAPI_SetFilePointer, _WinAPI_WriteFile
; Link ..........: @@MsdnLink@@ SetEndOfFile
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_SetEndOfFile($hFile)
	Local $aResult = DllCall("kernel32.dll", "bool", "SetEndOfFile", "handle", $hFile)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetEndOfFile

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetEvent
; Description ...: Sets the specified event object to the signaled state
; Syntax.........: _WinAPI_SetEvent($hEvent)
; Parameters ....: $hEvent      - Handle to the event objec
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The state of a manual-reset event object remains signaled until it is set explicitly to the nonsignaled  state
;                  by the ResetEvent function.  Any number of waiting threads, or threads that subsequently begin wait operations
;                  for the specified event object by calling one of the wait functions, can be released when the  object's  state
;                  is signaled.
; Related .......:
; Link ..........: @@MsdnLink@@ SetEvent
; Example .......:
; ===============================================================================================================================
Func _WinAPI_SetEvent($hEvent)
	Local $aResult = DllCall("kernel32.dll", "bool", "SetEvent", "handle", $hEvent)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetEvent

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetFilePointer
; Description ...: Moves the file pointer of the specified file
; Syntax.........: _WinAPI_SetFilePointer($hFile, $iPos[, $iMethod = 0])
; Parameters ....: $hFile - Handle to the file to be processed
;                  $iPos - Number of bytes to move the file pointer. Maximum value is 2^32
;                  +A positive value moves the file pointer forward in the file, and a negative value moves the file pointer back.
;                  $iMethod - The starting point for the file pointer move.
;                  +Can be one of the predefined values:
;                  |$FILE_BEGIN = 0 - The starting point is zero (0) or the beginning of the file
;                  |$FILE_CURRENT = 1 - The starting point is the current value of the file pointer.
;                  |$FILE_END = 2 - The starting point is the current end-of-file position.
;                  +Implicit value is $FILE_BEGIN = 0
; Return values .: Success - New file pointer.
;                  Failure - Returns INVALID_SET_FILE_POINTER (-1) and Sets @Error:
;                  |0 - No error
;                  |1 - API returned @error
;                  |2 - API returned INVALID_SET_FILE_POINTER
; Author ........: Zedna
; Modified.......: jpm
; Remarks .......: This function can also be used to query the current file pointer position by specifying a move method of FILE_CURRENT and a distance of zero.
;                  +This function stores the file pointer in LONG value. To work with file pointers that are larger than a single LONG value, it must be used the SetFilePointerEx function.
;                  +File pointer is the position in the file to read/write to/from by _WinAPI_ReadFile/_WinAPI_WriteFile
; Related .......: _WinAPI_CloseHandle, _WinAPI_CreateFile, _WinAPI_FlushFileBuffers, _WinAPI_GetFileSizeEx, _WinAPI_ReadFile, _WinAPI_SetEndOfFile, _WinAPI_WriteFile
; Link ..........: @@MsdnLink@@ SetFilePointer
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_SetFilePointer($hFile, $iPos, $iMethod = 0)
	Local $aResult = DllCall("kernel32.dll", "INT", "SetFilePointer", "handle", $hFile, "long", $iPos, "ptr", 0, "long", $iMethod)
	If @error Then Return SetError(@error, @extended, -1)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetFilePointer

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetFocus
; Description ...: Sets the keyboard focus to the specified window
; Syntax.........: _WinAPI_SetFocus($hWnd)
; Parameters ....: $hWnd        - Identifies the window that will receive the keyboard input.  If this parameter is 0, keystrokes
;                  +are ignored.
; Return values .: Success      - The handle of the window that had the keyboard focus
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ SetFocus
; Example .......:
; ===============================================================================================================================
Func _WinAPI_SetFocus($hWnd)
	Local $aResult = DllCall("user32.dll", "hwnd", "SetFocus", "hwnd", $hWnd)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetFocus

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetFont
; Description ...: Sets a window font
; Syntax.........: _WinAPI_SetFont($hWnd, $hFont[, $fRedraw = True])
; Parameters ....: $hWnd        - Window handle
;                  $hFont       - Font handle
;                  $fRedraw     - True to redraw the control
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_SetFont($hWnd, $hFont, $fRedraw = True)
	_SendMessage($hWnd, $__WINAPICONSTANT_WM_SETFONT, $hFont, $fRedraw, 0, "hwnd")
EndFunc   ;==>_WinAPI_SetFont

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetHandleInformation
; Description ...: Sets certain properties of an object handle
; Syntax.........: _WinAPI_SetHandleInformation($hObject, $iMask, $iFlags)
; Parameters ....: $hObject     - Handle to an object
;                  $iMask       - Specifies the bit flags to be changed
;                  $iFlags      - Specifies properties of the object handle
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ SetHandleInformation
; Example .......:
; ===============================================================================================================================
Func _WinAPI_SetHandleInformation($hObject, $iMask, $iFlags)
	Local $aResult = DllCall("kernel32.dll", "bool", "SetHandleInformation", "handle", $hObject, "dword", $iMask, "dword", $iFlags)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetHandleInformation

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetLayeredWindowAttributes
; Description ...: Sets Layered Window Attributes
; Syntax.........: _WinAPI_SetLayeredWindowAttributes($hWnd, $i_transcolor[, $Transparency = 255[, $dwFlags = 0x03[, $isColorRef = False]]])
; Parameters ....: $hwnd - Handle of GUI to work on
;                  $i_transcolor - Transparent color
;                  $Transparency - Set Transparancy of GUI
;				   $dwFlags - Flags.
;                  $isColorRef - If True, $i_transcolor is a COLORREF( 0x00bbggrr ), else an RGB-Color
; Return values .: Success - 1
;                  @Error - 0
;                  |@error: 1 to 3 - Error from DllCall
;                  |@error: 4 - Function did not succeed - use _WinAPI_GetLastErrorMessage to get more information
; Author ........: Prog@ndy
; Modified.......: PsaltyDS
; Remarks .......:
; Related .......: _WinAPI_GetLayeredWindowAttributes, _WinAPI_GetLastError
; Link ..........: @@MsdnLink@@ SetLayeredWindowAttributes
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_SetLayeredWindowAttributes($hWnd, $i_transcolor, $Transparency = 255, $dwFlags = 0x03, $isColorRef = False)
	If $dwFlags = Default Or $dwFlags = "" Or $dwFlags < 0 Then $dwFlags = 0x03
	If Not $isColorRef Then
		$i_transcolor = Int(BinaryMid($i_transcolor, 3, 1) & BinaryMid($i_transcolor, 2, 1) & BinaryMid($i_transcolor, 1, 1))
	EndIf
	Local $aResult = DllCall("user32.dll", "bool", "SetLayeredWindowAttributes", "hwnd", $hWnd, "dword", $i_transcolor, "byte", $Transparency, "dword", $dwFlags)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetLayeredWindowAttributes

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetParent
; Description ...: Changes the parent window of the specified child window
; Syntax.........: _WinAPI_SetParent($hWndChild, $hWndParent)
; Parameters ....: $hWndChild   - Window handle of child window
;                  $hWndParent  - Handle to the new parent window. If 0, the desktop window becomes the new parent window.
; Return values .: Success      - A handle to the previous parent window
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: An application can use the SetParent function to set the parent window  of  a  pop-up,  overlapped,  or  child
;                  window.  The new parent window and the child window must belong to the same application.
; Related .......:
; Link ..........: @@MsdnLink@@ SetParent
; Example .......:
; ===============================================================================================================================
Func _WinAPI_SetParent($hWndChild, $hWndParent)
	Local $aResult = DllCall("user32.dll", "hwnd", "SetParent", "hwnd", $hWndChild, "hwnd", $hWndParent)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetParent

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetProcessAffinityMask
; Description ...: Sets a processor affinity mask for the threads of a specified process
; Syntax.........: _WinAPI_SetProcessAffinityMask($hProcess, $iMask)
; Parameters ....: $hProcess    - A handle to the process whose affinity mask the function sets
;                  $iMask       - Affinity mask
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......: An affinity mask is a bit mask in which each bit represents a processor on which the threads  of  the  process
;                  are allowed to run.  For example, if you pass a mask of 0x05, processors 1 and 3 are allowed to run.
; Related .......:
; Link ..........: @@MsdnLink@@ SetProcessAffinityMask
; Example .......:
; ===============================================================================================================================
Func _WinAPI_SetProcessAffinityMask($hProcess, $iMask)
	Local $aResult = DllCall("kernel32.dll", "bool", "SetProcessAffinityMask", "handle", $hProcess, "ulong_ptr", $iMask)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetProcessAffinityMask

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetSysColors
; Description ...: Obtains information about the display devices in a system
; Syntax.........: _WinAPI_SetSysColors($vElements, $vColors)
; Parameters ....: $vElements - Single element or Array of elements
;                  $vColors - Single Color or Array of colors
; Return values .: Success - Trie
;                  Failure - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: See _WinAPI_GetSysColor for list of Element indexes and requirements.
; Related .......: _WinAPI_GetSysColor
; Link ..........: @@MsdnLink@@ SetSysColors
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_SetSysColors($vElements, $vColors)
	Local $isEArray = IsArray($vElements), $isCArray = IsArray($vColors)
	Local $iElementNum

	If Not $isCArray And Not $isEArray Then
		$iElementNum = 1
	ElseIf $isCArray Or $isEArray Then
		If Not $isCArray Or Not $isEArray Then Return SetError(-1, -1, False)
		If UBound($vElements) <> UBound($vColors) Then Return SetError(-1, -1, False)
		$iElementNum = UBound($vElements)
	EndIf

	Local $tElements = DllStructCreate("int Element[" & $iElementNum & "]")
	Local $tColors = DllStructCreate("dword NewColor[" & $iElementNum & "]")


	If Not $isEArray Then
		DllStructSetData($tElements, "Element", $vElements, 1)
	Else
		For $x = 0 To $iElementNum - 1
			DllStructSetData($tElements, "Element", $vElements[$x], $x + 1)
		Next
	EndIf

	If Not $isCArray Then
		DllStructSetData($tColors, "NewColor", $vColors, 1)
	Else
		For $x = 0 To $iElementNum - 1
			DllStructSetData($tColors, "NewColor", $vColors[$x], $x + 1)
		Next
	EndIf
	Local $aResult = DllCall("user32.dll", "bool", "SetSysColors", "int", $iElementNum, "struct*", $tElements, "struct*", $tColors)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetSysColors

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetTextColor
; Description ...: Sets the current text color to the specified color value
; Syntax.........: _WinAPI_SetTextColor($hDC, $iColor)
; Parameters ....: $hDC         - Handle to the device context
;                  $iColor      - Specifies the new text color
; Return values .: Success      - The previous text color
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ SetTextColor
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_SetTextColor($hDC, $iColor)
	Local $aResult = DllCall("gdi32.dll", "INT", "SetTextColor", "handle", $hDC, "dword", $iColor)
	If @error Then Return SetError(@error, @extended, -1)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetTextColor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetWindowLong
; Description ...: Sets information about the specified window
; Syntax.........: _WinAPI_SetWindowLong($hWnd, $iIndex, $iValue)
; Parameters ....: $hWnd        - Handle of the window
;                  $iIndex      - Specifies the zero based offset to the value to be set.  Valid values are  in  the  range  zero
;                  +through the number of bytes of extra window memory, minus four; for example, if  you  specified  12  or  more
;                  +bytes of extra memory, a value of 8 would be an index to the third 32-bit  integer.  To  retrieve  any  other
;                  +value specify one of the following values:
;                  |$GWL_EXSTYLE    - Sets the extended window styles
;                  |$GWL_STYLE      - Sets the window styles
;                  |$GWL_WNDPROC    - Sets the address of the window procedure
;                  |$GWL_HINSTANCE  - Sets the handle of the application instance
;                  |$GWL_HWNDPARENT - Sets the handle of the parent window, if any
;                  |$GWL_ID         - Sets the identifier of the window
;                  |$GWL_USERDATA   - Sets the 32-bit value associated with the window
;                  $iValue      - Specifies the replacement value
; Return values .: Success      - The previous value
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......: Needs Constants.au3 for pre-defined constants
; Related .......: _WinAPI_GetWindowLong, _WinAPI_CallWindowProc
; Link ..........: @@MsdnLink@@ SetWindowLong
; Example .......:
; ===============================================================================================================================
Func _WinAPI_SetWindowLong($hWnd, $iIndex, $iValue)
	_WinAPI_SetLastError(0) ; as suggested in MSDN
	Local $sFuncName = "SetWindowLongW"
	If @AutoItX64 Then $sFuncName = "SetWindowLongPtrW"
	Local $aResult = DllCall("user32.dll", "long_ptr", $sFuncName, "hwnd", $hWnd, "int", $iIndex, "long_ptr", $iValue)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetWindowLong

; #FUNCTION# =====================================================================================
; Name...........: _WinAPI_SetWindowPlacement
; Description ...: Sets the placement of the window for Min, Max, and normal positions
; Syntax.........: _WinAPI_SetWindowPlacement($hWnd, $pWindowPlacement)
; Parameters ....: $hWnd        - Handle of the window
;                  $pWindowPlacement - pointer to $tagWINDOWPLACEMENT structure
; Return values .: Success      - Returns non-zero
;                  Failure      - Returns 0, @error = 1, @extended = _WinAPI_GetLastError()
; Author ........: PsaltyDS at www.autoitscript.com/forum
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_GetWindowPlacement, $tagWINDOWPLACEMENT
; Link ..........: @@MsdnLink@@ SetWindowPlacement
; Example .......: Yes
; ===============================================================================================
Func _WinAPI_SetWindowPlacement($hWnd, $pWindowPlacement)
	Local $aResult = DllCall("user32.dll", "bool", "SetWindowPlacement", "hwnd", $hWnd, "ptr", $pWindowPlacement)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetWindowPlacement

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetWindowPos
; Description ...: Changes the size, position, and Z order of a child, pop-up, or top-level  window
; Syntax.........: _WinAPI_SetWindowPos($hWnd, $hAfter, $iX, $iY, $iCX, $iCY, $iFlags)
; Parameters ....: $hWnd        - Handle of window
;                  $hAfter      - Identifies the window to precede the positioned window in the Z order. This parameter must be a
;                  +window handle or one of the following values:
;                  |$HWND_BOTTOM    - Places the window at the bottom of the Z order
;                  |$HWND_NOTOPMOST - Places the window above all non-topmost windows
;                  |$HWND_TOP       - Places the window at the top of the Z order
;                  |$HWND_TOPMOST   - Places the window above all non-topmost windows
;                  $iX          - Specifies the new position of the left side of the window
;                  $iY          - Specifies the new position of the top of the window
;                  $iCX         - Specifies the new width of the window, in pixels
;                  $iCY         - Specifies the new height of the window, in pixels
;                  $iFlags      - Specifies the window sizing and positioning flags:
;                  |$SWP_DRAWFRAME      - Draws a frame around the window
;                  |$SWP_FRAMECHANGED   - Sends a $WM_NCCALCSIZE message to the window, even if the window's size is not changed
;                  |$SWP_HIDEWINDOW     - Hides the window
;                  |$SWP_NOACTIVATE     - Does not activate the window
;                  |$SWP_NOCOPYBITS     - Discards the entire contents of the client area
;                  |$SWP_NOMOVE         - Retains the current position
;                  |$SWP_NOOWNERZORDER  - Does not change the owner window's position in the Z order
;                  |$SWP_NOREDRAW       - Does not redraw changes
;                  |$SWP_NOREPOSITION   - Same as the $SWP_NOOWNERZORDER flag
;                  |$SWP_NOSENDCHANGING - Prevents the window from receiving $WM_WINDOWPOSCHANGING
;                  |$SWP_NOSIZE         - Retains the current size
;                  |$SWP_NOZORDER       - Retains the current Z order
;                  |$SWP_SHOWWINDOW     - Displays the window
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Needs Constants.au3 for pre-defined constants
; Related .......:
; Link ..........: @@MsdnLink@@ SetWindowPos
; Example .......:
; ===============================================================================================================================
Func _WinAPI_SetWindowPos($hWnd, $hAfter, $iX, $iY, $iCX, $iCY, $iFlags)
	Local $aResult = DllCall("user32.dll", "bool", "SetWindowPos", "hwnd", $hWnd, "hwnd", $hAfter, "int", $iX, "int", $iY, "int", $iCX, _
			"int", $iCY, "uint", $iFlags)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetWindowPos

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetWindowRgn
; Description ...: Sets the window region of a window
; Syntax.........: _WinAPI_SetWindowRgn($hWnd, $hRgn[, $bRedraw])
; Parameters ....: $hWnd - Handle to the window whose window region is to be set.
;                  $hRgn - Handle to a region. The function sets the window region of the window to this region.
;                  If hRgn is NULL, the function sets the window region to NULL.
;                  $bRedraw - Specifies whether the system redraws the window after setting the window region.
;                  If bRedraw is TRUE, the system does so otherwise, it does not. Default value is True.
;                  Typically, you set bRedraw to TRUE if the window is visible.
; Return values .: Success      - Nonzero
;                  Failure      - 0
; Author ........: Zedna
; Modified.......:
; Remarks .......: The window region determines the area within the window where the system permits drawing.
;                  The system does not display any portion of a window that lies outside of the window region
;                  When this function is called, the system sends the WM_WINDOWPOSCHANGING and WM_WINDOWPOSCHANGED messages to the window.
;                  The coordinates of a window's window region are relative to the upper-left corner of the window, not the client area of the window.
;                  After a successful call to SetWindowRgn, the system owns the region specified by the region handle hRgn.
;                  The system does not make a copy of the region. Thus, you should not make any further function calls with this region handle.
;                  In particular, do not delete this region handle. The system deletes the region handle when it no longer needed.
; Related .......: _WinAPI_CreateRectRgn, _WinAPI_CreateRoundRectRgn, _WinAPI_CombineRgn
; Link ..........: @@MsdnLink@@ SetWindowRgn
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_SetWindowRgn($hWnd, $hRgn, $bRedraw = True)
	Local $aResult = DllCall("user32.dll", "int", "SetWindowRgn", "hwnd", $hWnd, "handle", $hRgn, "bool", $bRedraw)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetWindowRgn

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetWindowsHookEx
; Description ...: Installs an application-defined hook procedure into a hook chain
; Syntax.........: _WinAPI_SetWindowsHookEx($idHook, $lpfn, $hmod[, $dwThreadId = 0])
; Parameters ....: $idHook  - Specifies the type of hook procedure to be installed. This parameter can be one of the following values:
;                  |$WH_CALLWNDPROC     - Installs a hook procedure that monitors messages before the system sends them to the destination window procedure
;                  |$WH_CALLWNDPROCRET  - Installs a hook procedure that monitors messages after they have been processed by the destination window procedure
;                  |$WH_CBT             - Installs a hook procedure that receives notifications useful to a computer-based training (CBT) application
;                  |$WH_DEBUG           - Installs a hook procedure useful for debugging other hook procedures
;                  |$WH_FOREGROUNDIDLE  - Installs a hook procedure that will be called when the application's foreground thread is about to become idle
;                  |$WH_GETMESSAGE      - Installs a hook procedure that monitors messages posted to a message queue
;                  |$WH_JOURNALPLAYBACK - Installs a hook procedure that posts messages previously recorded by a $WH_JOURNALRECORD hook procedure
;                  |$WH_JOURNALRECORD   - Installs a hook procedure that records input messages posted to the system message queue
;                  |$WH_KEYBOARD        - Installs a hook procedure that monitors keystroke messages
;                  |$WH_KEYBOARD_LL     - Windows NT/2000/XP: Installs a hook procedure that monitors low-level keyboard input events
;                  |$WH_MOUSE           - Installs a hook procedure that monitors mouse messages
;                  |$WH_MOUSE_LL        - Windows NT/2000/XP: Installs a hook procedure that monitors low-level mouse input events
;                  |$WH_MSGFILTER       - Installs a hook procedure that monitors messages generated as a result of an input event in a dialog box, message box, menu, or scroll bar
;                  |$WH_SHELL           - Installs a hook procedure that receives notifications useful to shell applications
;                  |$WH_SYSMSGFILTER    - Installs a hook procedure that monitors messages generated as a result of an input event in a dialog box, message box, menu, or scroll bar
;                  $lpfn  - Pointer to the hook procedure. If the $dwThreadId parameter is zero or specifies the identifier of a thread created by a different process,
;                  + the $lpfn parameter must point to a hook procedure in a DLL.
;                  |Otherwise, $lpfn can point to a hook procedure in the code associated with the current process
;                  $hmod  - Handle to the DLL containing the hook procedure pointed to by the $lpfn parameter.
;                  |The $hMod parameter must be set to NULL if the $dwThreadId parameter specifies a thread created by the current process and if the hook procedure is within the
;                  + code associated with the current process
;                  $dwThreadId - Specifies the identifier of the thread with which the hook procedure is to be associated.
;                  |If this parameter is zero, the hook procedure is associated with all existing threads running in the same desktop as the calling thread
; Return values .: Success      - Handle to the hook procedure
;                  Failure      - 0 and @error is set
; Author ........: Gary Frost
; Modified.......: jpm
; Remarks .......:
; Related .......: _WinAPI_UnhookWindowsHookEx, _WinAPI_CallNextHookEx, DllCallbackRegister, DllCallbackGetPtr, DllCallbackFree
; Link ..........: @@MsdnLink@@ SetWindowsHookEx
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_SetWindowsHookEx($idHook, $lpfn, $hmod, $dwThreadId = 0)
	Local $aResult = DllCall("user32.dll", "handle", "SetWindowsHookEx", "int", $idHook, "ptr", $lpfn, "handle", $hmod, "dword", $dwThreadId)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetWindowsHookEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SetWindowText
; Description ...: Changes the text of the specified window's title bar
; Syntax.........: _WinAPI_SetWindowText($hWnd, $sText)
; Parameters ....: $hWnd        - Handle to the window or control whose text is to be changed
;                  $sText       - String to be used as the new title or control te
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......: If the target window is owned by the current process, SetWindowText causes a $WM_SETTEXT message to be sent to
;                  the specified window or control.  If the control is a list box control created  with  the  $WS_CAPTION  style,
;                  however, SetWindowText sets the text for the control, not for the list box entries.  To  set  the  text  of  a
;                  control in another process, send the $WM_SETTEXT message directly instead of calling SetWindowText.
; Related .......:
; Link ..........: @@MsdnLink@@ SetWindowText
; Example .......:
; ===============================================================================================================================
Func _WinAPI_SetWindowText($hWnd, $sText)
	Local $aResult = DllCall("user32.dll", "bool", "SetWindowTextW", "hwnd", $hWnd, "wstr", $sText)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SetWindowText

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShowCursor
; Description ...: Displays or hides the cursor
; Syntax.........: _WinAPI_ShowCursor($fShow)
; Parameters ....: $fShow       - If True, the curor is shown, otherwise it is hidden
; Return values .: Success      - The new display counter
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function sets an internal display counter that determines whether the cursor  should  be  displayed.  The
;                  cursor is displayed only if the display count is greater than or equal to 0.  If a  mouse  is  installed,  the
;                  initial display count is 0. If no mouse is installed, the display count is -1.
; Related .......:
; Link ..........: @@MsdnLink@@ ShowCursor
; Example .......:
; ===============================================================================================================================
Func _WinAPI_ShowCursor($fShow)
	Local $aResult = DllCall("user32.dll", "int", "ShowCursor", "bool", $fShow)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_ShowCursor

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShowError
; Description ...: Displays an error message box with an optional exit
; Syntax.........: _WinAPI_ShowError($sText[, $fExit = True])
; Parameters ....: $sText       - Error text to display
;                  $fExit       - Specifies whether to exit after the display:
;                  |True  - Exit program after display
;                  |False - Return normally after display
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_ShowMsg, _WinAPI_MsgBox
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_ShowError($sText, $fExit = True)
	_WinAPI_MsgBox(266256, "Error", $sText)
	If $fExit Then Exit
EndFunc   ;==>_WinAPI_ShowError

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShowMsg
; Description ...: Displays an "Information" message box
; Syntax.........: _WinAPI_ShowMsg($sText)
; Parameters ....: $sText       - "Information" text to display
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_ShowError, _WinAPI_MsgBox
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_ShowMsg($sText)
	_WinAPI_MsgBox(64 + 4096, "Information", $sText)
EndFunc   ;==>_WinAPI_ShowMsg

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShowWindow
; Description ...: Sets the specified window's show state
; Syntax.........: _WinAPI_ShowWindow($hWnd[, $iCmdShow = 5])
; Parameters ....: $hWnd        - Handle of window
;                  $iCmdShow    - Specifies how the window is to be shown:
;                  |@SW_HIDE            - Hides the window and activates another window
;                  |@SW_MAXIMIZE        - Maximizes the specified window
;                  |@SW_MINIMIZE        - Minimizes the specified window and activates the next top-level window in the Z order
;                  |@SW_RESTORE         - Activates and displays the window
;                  |@SW_SHOW            - Activates the window and displays it in its current size and position
;                  |@SW_SHOWDEFAULT     - Sets the show state based on the SW_ flag specified in the STARTUPINFO structure
;                  |@SW_SHOWMAXIMIZED   - Activates the window and displays it as a maximized window
;                  |@SW_SHOWMINIMIZED   - Activates the window and displays it as a minimized window
;                  |@SW_SHOWMINNOACTIVE - Displays the window as a minimized window
;                  |@SW_SHOWNA          - Displays the window in its current state
;                  |@SW_SHOWNOACTIVATE  - Displays a window in its most recent size and position
;                  |@SW_SHOWNORMAL      - Activates and displays a window
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ ShowWindow
; Example .......:
; ===============================================================================================================================
Func _WinAPI_ShowWindow($hWnd, $iCmdShow = 5)
	Local $aResult = DllCall("user32.dll", "bool", "ShowWindow", "hwnd", $hWnd, "int", $iCmdShow)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_ShowWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_StringFromGUID
; Description ...: Converts a binary GUID to string form
; Syntax.........: _WinAPI_StringFromGUID($pGUID)
; Parameters ....: $pGUID       - Pointer to a $tagGUID structure
; Return values .: Success      - GUID in string form
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_GUIDFromString, _WinAPI_GUIDFromStringEx, $tagGUID
; Link ..........: @@MsdnLink@@ StringFromGUID2
; Example .......:
; ===============================================================================================================================
Func _WinAPI_StringFromGUID($pGUID)
	Local $aResult = DllCall("ole32.dll", "int", "StringFromGUID2", "struct*", $pGUID, "wstr", "", "int", 40)
	If @error Then Return SetError(@error, @extended, "")
	Return SetExtended($aResult[0], $aResult[2])
EndFunc   ;==>_WinAPI_StringFromGUID

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_StringLenA
; Description ...: Calculates the size of ANSI string (not including the terminating null character).
; Syntax.........: _WinAPI_StringLenA($vString)
; Parameters ....: $vString     - String buffer to process.
; Return values .: Success      - String length in characters
;                  Failure      - 0
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_StringLenW
; Link ..........: @@MsdnLink@@ lstrlenA
; Example .......:
; ===============================================================================================================================
Func _WinAPI_StringLenA($vString)
	Local $aCall = DllCall("kernel32.dll", "int", "lstrlenA", "struct*", $vString)
	If @error Then Return SetError(1, @extended, 0)
	Return $aCall[0]
EndFunc   ;==>_WinAPI_StringLenA

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_StringLenW
; Description ...: Calculates the size of wide string (not including the terminating null character).
; Syntax.........: _WinAPI_StringLenW($vString)
; Parameters ....: $vString     - String buffer to process.
; Return values .: Success      - String length in characters
;                  Failure      - 0
; Author ........: trancexx
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_StringLenA
; Link ..........: @@MsdnLink@@ lstrlenW
; Example .......:
; ===============================================================================================================================
Func _WinAPI_StringLenW($vString)
	Local $aCall = DllCall("kernel32.dll", "int", "lstrlenW", "struct*", $vString)
	If @error Then Return SetError(1, @extended, 0)
	Return $aCall[0]
EndFunc   ;==>_WinAPI_StringLenW

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SubLangId
; Description ...: Extract sublanguage id from a language id
; Syntax.........: _WinAPI_SubLangId($lgid)
; Parameters ....: $lgid        - Language id
; Return values .: Success      - Sub-Language id
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_SubLangId($lgid)
	Return BitShift($lgid, 10)
EndFunc   ;==>_WinAPI_SubLangId

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_SystemParametersInfo
; Description ...: Retrieves or sets the value of one of the system-wide parameters
; Syntax.........: _WinAPI_SystemParametersInfo($iAction[, $iParam = 0[, $vParam = 0[, $iWinIni = 0]]])
; Parameters ....: $iAction     - The system-wide parameter to be retrieved or set
;                  $iParam      - A parameter whose usage and format depends on the parameter being queried or set
;                  $vParam      - A parameter whose usage and format depends on the parameter being queried or set
;                  $iWinIni      - If a system parameter is being set, specifies whether the user profile is to be  updated,  and
;                  +if so, whether the $WM_SETTINGCHANGE message is to be broadcast. This parameter can be zero if you don't want
;                  +to update the user profile or it can be one or more of the following values:
;                  |$SPIF_UPDATEINIFILE - Writes the new setting to the user profile
;                  |$SPIF_SENDCHANGE    - Broadcasts the $WM_SETTINGCHANGE message after updating the user profile
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ SystemParametersInfo
; Example .......:
; ===============================================================================================================================
Func _WinAPI_SystemParametersInfo($iAction, $iParam = 0, $vParam = 0, $iWinIni = 0)
	Local $aResult = DllCall("user32.dll", "bool", "SystemParametersInfoW", "uint", $iAction, "uint", $iParam, "ptr", $vParam, "uint", $iWinIni)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_SystemParametersInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_TwipsPerPixelX
; Description ...: Returns the width of a pixel, in twips.
; Syntax.........: _WinAPI_TwipsPerPixelX()
; Parameters ....:
; Return values .: The width of a pixel, in twips.
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_TwipsPerPixelX()
	Local $lngDC, $TwipsPerPixelX
	$lngDC = _WinAPI_GetDC(0)
	$TwipsPerPixelX = 1440 / _WinAPI_GetDeviceCaps($lngDC, $__WINAPICONSTANT_LOGPIXELSX)
	_WinAPI_ReleaseDC(0, $lngDC)
	Return $TwipsPerPixelX
EndFunc   ;==>_WinAPI_TwipsPerPixelX

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_TwipsPerPixelY
; Description ...: Returns the height of a pixel, in twips.
; Syntax.........: _WinAPI_TwipsPerPixelY()
; Parameters ....:
; Return values .: The height of a pixel, in twips.
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _WinAPI_TwipsPerPixelY()
	Local $lngDC, $TwipsPerPixelY
	$lngDC = _WinAPI_GetDC(0)
	$TwipsPerPixelY = 1440 / _WinAPI_GetDeviceCaps($lngDC, $__WINAPICONSTANT_LOGPIXELSY)
	_WinAPI_ReleaseDC(0, $lngDC)
	Return $TwipsPerPixelY
EndFunc   ;==>_WinAPI_TwipsPerPixelY

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_UnhookWindowsHookEx
; Description ...: Removes a hook procedure installed in a hook chain by the _WinAPI_SetWindowsHookEx function
; Syntax.........: _WinAPI_UnhookWindowsHookEx($hhk)
; Parameters ....: $hhk - Handle to the hook to be removed
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_SetWindowsHookEx, DllCallbackFree
; Link ..........: @@MsdnLink@@ UnhookWindowsHookEx
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_UnhookWindowsHookEx($hhk)
	Local $aResult = DllCall("user32.dll", "bool", "UnhookWindowsHookEx", "handle", $hhk)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_UnhookWindowsHookEx

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_UpdateLayeredWindow
; Description ...: Updates the position, size, shape, content, and translucency of a layered window
; Syntax.........: _WinAPI_UpdateLayeredWindow($hWnd, $hDCDest, $pPTDest, $pSize, $hDCSrce, $pPTSrce, $iRGB, $pBlend, $iFlags)
; Parameters ....: $hWnd        - Handle to a layered window.  A layered window is  created  by  specifying  $WS_EX_LAYERED  when
;                  +creating the window.
;                  $hDCDest     - Handle to a device context for the screen
;                  $pPTDest     - Pointer to a $tagPOINT structure that specifies the new screen position of the  layered  window.
;                  +If the current position is not changing, this can be zero.
;                  $pSize       - Pointer to a $tagSIZE structure that specifies the new size of the layered window.  If the  size
;                  +of the window is not changing, this can be 0.
;                  $hDCSrce     - Handle to a device context for the surface that defines the layered window.  This handle can be
;                  +obtained by calling the _WinAPI_CreateCompatibleDC function.
;                  $pPTSrce     - Pointer to a $tagPOINT structure that specifies the location of the layer in the device context
;                  $iRGB        - The color key to be used when composing the layered window
;                  $pBlend      - Pointer to a $tagBLENDFUNCTION structure that specifies the transparency value to be  used  when
;                  +composing the layered window.
;                  $iFlags      - This parameter can be one of the following values.
;                  |$ULW_ALPHA    - Use $tblend as the blend function
;                  |$ULW_COLORKEY - Use $iRGB as the transparency color
;                  |$ULW_OPAQUE   - Draw an opaque layered window
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: $tagBLENDFUNCTION, $tagPOINT, $tagSIZE
; Link ..........: @@MsdnLink@@ UpdateLayeredWindow
; Example .......:
; ===============================================================================================================================
Func _WinAPI_UpdateLayeredWindow($hWnd, $hDCDest, $pPTDest, $pSize, $hDCSrce, $pPTSrce, $iRGB, $pBlend, $iFlags)
	Local $aResult = DllCall("user32.dll", "bool", "UpdateLayeredWindow", "hwnd", $hWnd, "handle", $hDCDest, "ptr", $pPTDest, "ptr", $pSize, _
			"handle", $hDCSrce, "ptr", $pPTSrce, "dword", $iRGB, "ptr", $pBlend, "dword", $iFlags)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_UpdateLayeredWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_UpdateWindow
; Description ...: Updates the client area of a window by sending a WM_PAINT message to the window
; Syntax.........: _WinAPI_UpdateWindow($hWnd)
; Parameters ....: $hWnd        - Handle of window to update
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ UpdateWindow
; Example .......:
; ===============================================================================================================================
Func _WinAPI_UpdateWindow($hWnd)
	Local $aResult = DllCall("user32.dll", "bool", "UpdateWindow", "hwnd", $hWnd)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_UpdateWindow

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WaitForInputIdle
; Description ...: Waits until a process is waiting for user input with no input pending, or a time out
; Syntax.........: _WinAPI_WaitForInputIdle($hProcess[, $iTimeout = -1])
; Parameters ....: $hProcess    - A handle to the process.  If this process is a console application or does not have  a  message
;                  +queue, this function returns immediately.
;                  $iTimeOut    - The time out interval, in milliseconds.  If set to -1, the function does not return  until  the
;                  +process is idle.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function causes a thread to suspend execution until the specified process has finished its initialization
;                  and is waiting for user input with no input pending. This can be useful for synchronizing a parent process and
;                  a newly created child process.  When a parent process creates a  child  process,  the  CreateProcess  function
;                  returns without waiting for the child process to finish its initialization.  Before trying to communicate with
;                  the child process, the parent process can use this function to determine when the child's  initialization  has
;                  been completed. This function can be used at any time, not just during application startup.
; Related .......:
; Link ..........: @@MsdnLink@@ WaitForInputIdle
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WaitForInputIdle($hProcess, $iTimeout = -1)
	Local $aResult = DllCall("user32.dll", "dword", "WaitForInputIdle", "handle", $hProcess, "dword", $iTimeout)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_WaitForInputIdle

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WaitForMultipleObjects
; Description ...: Waits until one or all of the specified objects are in the signaled state
; Syntax.........: _WinAPI_WaitForMultipleObjects($iCount, $pHandles[, $fWaitAll = False[, $iTimeout = -1]])
; Parameters ....: $iCount      - The number of object handles in the array pointed to by pHandles
;                  $pHandles    - Pointer to an array of object handles
;                  $fWaitAll    - If True, the function returns when the state of all objects in the pHandles array is  signaled.
;                  +If False, the function returns when the state of any one of the objects is set to  signaled.  In  the  latter
;                  +case, the return value indicates the object whose state caused the function to return.
;                  $iTimeout    - The time-out interval, in milliseconds.  The function returns if the interval elapses, even  if
;                  +the conditions specified by the fWaitAll parameter are not met.  If 0, the function tests the states  of  the
;                  +specified objects and returns immediately. If -1, the function's time-out interval never elapses.
; Return values .: Success      - Indicates the event that caused the function to return
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_WaitForSingleObject
; Link ..........: @@MsdnLink@@ WaitForMultipleObjects
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WaitForMultipleObjects($iCount, $pHandles, $fWaitAll = False, $iTimeout = -1)
	Local $aResult = DllCall("kernel32.dll", "INT", "WaitForMultipleObjects", "dword", $iCount, "ptr", $pHandles, "bool", $fWaitAll, "dword", $iTimeout)
	If @error Then Return SetError(@error, @extended, -1)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_WaitForMultipleObjects

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WaitForSingleObject
; Description ...: Waits until the specified object is in the signaled state
; Syntax.........: _WinAPI_WaitForSingleObject($hHandle[, $iTimeout = -1])
; Parameters ....: $hHandle     - A handle to the object
;                  $iTimeout    - The time-out interval, in milliseconds.  The function returns if the interval elapses, even  if
;                  +the conditions specified by the fWaitAll parameter are not met.  If 0, the function tests the states  of  the
;                  +specified objects and returns immediately. If -1, the function's time-out interval never elapses.
; Return values .: Success      - Indicates the event that caused the function to return
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_WaitForMultipleObjects
; Link ..........: @@MsdnLink@@ WaitForSingleObject
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WaitForSingleObject($hHandle, $iTimeout = -1)
	Local $aResult = DllCall("kernel32.dll", "INT", "WaitForSingleObject", "handle", $hHandle, "dword", $iTimeout)
	If @error Then Return SetError(@error, @extended, -1)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_WaitForSingleObject

; #FUNCTION#====================================================================================================================
; Name...........: _WinAPI_WideCharToMultiByte
; Description ...: Converts a Unicode string to an multibyte string
; Syntax.........: _WinAPI_WideCharToMultiByte($pUnicode[, $iCodePage = 0 [, $bRetString = True]])
; Parameters ....: $pUnicode    - Pointer to a byte array structure containing Unicode text to be converted
;                  $iCodePage   - Code page to use in performing the conversion:
;                  |0           - The current system Windows ANSI code page
;                  |1           - The current system OEM code page
;                  |2           - The current system Macintosh code page
;                  |3           - The Windows ANSI code page for the current thread
;                  |42          - Symbol code page
;                  |65000       - UTF-7
;                  |65001       - UTF-8
;                  $bRetString  - Flags indicating that a string or a structure will be returned (default True = string)
; Return values .: Success      - Converted string
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm, Alexander Samuelsson (AdmiralAlkex)
; Remarks .......:
; Related .......: _WinAPI_MultiByteToWideChar
; Link ..........: @@MsdnLink@@ WideCharToMultiByte
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WideCharToMultiByte($pUnicode, $iCodePage = 0, $bRetString = True)
	Local $sUnicodeType = "wstr"
	If Not IsString($pUnicode) Then $sUnicodeType = "struct*"
	Local $aResult = DllCall("kernel32.dll", "int", "WideCharToMultiByte", "uint", $iCodePage, "dword", 0, $sUnicodeType, $pUnicode, "int", -1, _
			"ptr", 0, "int", 0, "ptr", 0, "ptr", 0)
	If @error Then Return SetError(@error, @extended, "")

	Local $tMultiByte = DllStructCreate("char[" & $aResult[0] & "]")

	$aResult = DllCall("kernel32.dll", "int", "WideCharToMultiByte", "uint", $iCodePage, "dword", 0, $sUnicodeType, $pUnicode, "int", -1, _
			"struct*", $tMultiByte, "int", $aResult[0], "ptr", 0, "ptr", 0)
	If @error Then Return SetError(@error, @extended, "")

	If $bRetString Then Return DllStructGetData($tMultiByte, 1)
	Return $tMultiByte
EndFunc   ;==>_WinAPI_WideCharToMultiByte

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WindowFromPoint
; Description ...: Retrieves the handle of the window that contains the specified point
; Syntax.........: _WinAPI_WindowFromPoint(ByRef $tPoint)
; Parameters ....: $tPoint      - $tagPOINT structure that defines the point to be checked
; Return values .: Success      - The handle of the window thatcontains the point
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost, trancexx
; Remarks .......: The WindowFromPoint function does not retrieve the handle of a hidden or disabled window, even if the point is
;                  within the window.
; Related .......: $tagPOINT
; Link ..........: @@MsdnLink@@ WindowFromPoint
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WindowFromPoint(ByRef $tPoint)
	Local $aResult = DllCall("user32.dll", "hwnd", "WindowFromPoint", "struct", $tPoint)
	If @error Then Return SetError(1, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_WindowFromPoint

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WriteConsole
; Description ...: Writes a character string to a console screen buffer
; Syntax.........: _WinAPI_WriteConsole($hConsole, $sText)
; Parameters ....: $hConsole    - Handle to the console screen buffer
;                  $sText       - Text to be written to the console screen buffer
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ WriteConsole
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WriteConsole($hConsole, $sText)
	Local $aResult = DllCall("kernel32.dll", "bool", "WriteConsoleW", "handle", $hConsole, "wstr", $sText, "dword", StringLen($sText), "dword*", 0, "ptr", 0)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_WriteConsole

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WriteFile
; Description ...: Writes data to a file at the position specified by the file pointer
; Syntax.........: _WinAPI_WriteFile($hFile, $pBuffer, $iToWrite, ByRef $iWritten[, $pOverlapped = 0])
; Parameters ....: $hFile       - Handle to the file to be written
;                  $pBuffer     - Pointer to the buffer containing the data to be written
;                  $iToWrite    - Number of bytes to be written to the file
;                  $iWritten    - The number of bytes written
;                  $pOverlapped - Pointer to a $tagOVERLAPPED structure
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......: $tagOVERLAPPED, _WinAPI_CloseHandle, _WinAPI_CreateFile, _WinAPI_FlushFileBuffers, _WinAPI_GetFileSizeEx, _WinAPI_ReadFile, _WinAPI_SetEndOfFile, _WinAPI_SetFilePointer
; Link ..........: @@MsdnLink@@ WriteFile
; Example .......: Yes
; ===============================================================================================================================
Func _WinAPI_WriteFile($hFile, $pBuffer, $iToWrite, ByRef $iWritten, $pOverlapped = 0)
	Local $aResult = DllCall("kernel32.dll", "bool", "WriteFile", "handle", $hFile, "ptr", $pBuffer, "dword", $iToWrite, "dword*", 0, "ptr", $pOverlapped)
	If @error Then Return SetError(@error, @extended, False)
	$iWritten = $aResult[4]
	Return $aResult[0]
EndFunc   ;==>_WinAPI_WriteFile

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WriteProcessMemory
; Description ...: Writes memory in a specified process
; Syntax.........: _WinAPI_WriteProcessMemory($hProcess, $pBaseAddress, $pBuffer, $iSize, ByRef $iWritten[, $sBuffer = "ptr"])
; Parameters ....: $hProcess     - Identifies an open handle to a process whose memory is to be written to
;                  $pBaseAddress - Points to the base address in the specified process to be written to
;                  $pBuffer      - Points to the buffer that supplies data to be written into the address space
;                  $iSize        - Specifies the number of bytes to write into the specified process
;                  $iWritten     - The actual number of bytes transferred into the  specified  process
;                  $sBuffer      - Contains the data type that $pBuffer represents
; Return values .: Success       - True
;                  Failure       - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm
; Remarks .......:
; Related .......: _WinAPI_ReadProcessMemory
; Link ..........: @@MsdnLink@@ WriteProcessMemory
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WriteProcessMemory($hProcess, $pBaseAddress, $pBuffer, $iSize, ByRef $iWritten, $sBuffer = "ptr")
	Local $aResult = DllCall("kernel32.dll", "bool", "WriteProcessMemory", "handle", $hProcess, "ptr", $pBaseAddress, $sBuffer, $pBuffer, _
			"ulong_ptr", $iSize, "ulong_ptr*", 0)
	If @error Then Return SetError(@error, @extended, False)
	$iWritten = $aResult[5]
	Return $aResult[0]
EndFunc   ;==>_WinAPI_WriteProcessMemory
