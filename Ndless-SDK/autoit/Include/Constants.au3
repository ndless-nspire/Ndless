#include-once

#include "ProcessConstants.au3"
#include "FileConstants.au3"
#include "DirConstants.au3"
#include "ColorConstants.au3"

; #INDEX# =======================================================================================================================
; Title .........: Constants
; AutoIt Version : 3.2
; Language ......: English
; Description ...: Constants to be included in an AutoIt v3 script.
; Author(s) .....: JLandes, Nutster, CyberSlug, Holger, ...
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; Sets the way coords are used in the mouse and pixel functions
Global Const $OPT_COORDSRELATIVE = 0 ; Relative coords to the active window
Global Const $OPT_COORDSABSOLUTE = 1 ; Absolute screen coordinates (default)
Global Const $OPT_COORDSCLIENT = 2 ; Relative coords to client area

; Sets how errors are handled if a Run/RunWait function fails
Global Const $OPT_ERRORSILENT = 0 ; Silent error (@error set to 1)
Global Const $OPT_ERRORFATAL = 1 ; Fatal error (default)

; Alters the use of Caps Lock
Global Const $OPT_CAPSNOSTORE = 0 ; Don't store/restore Caps Lock state
Global Const $OPT_CAPSSTORE = 1 ; Store/restore Caps Lock state (default)

; Alters the method that is used to match window titles
Global Const $OPT_MATCHSTART = 1 ; Match the title from the start (default)
Global Const $OPT_MATCHANY = 2 ; Match any substring in the title
Global Const $OPT_MATCHEXACT = 3 ; Match the title exactly
Global Const $OPT_MATCHADVANCED = 4 ; Use advanced window matching (deprecated)

; Common Control Styles
Global Const $CCS_TOP = 0x01
Global Const $CCS_NOMOVEY = 0x02
Global Const $CCS_BOTTOM = 0x03
Global Const $CCS_NORESIZE = 0x04
Global Const $CCS_NOPARENTALIGN = 0x08
Global Const $CCS_NOHILITE = 0x10
Global Const $CCS_ADJUSTABLE = 0x20
Global Const $CCS_NODIVIDER = 0x40
Global Const $CCS_VERT = 0x0080
Global Const $CCS_LEFT = 0x0081
Global Const $CCS_NOMOVEX = 0x0082
Global Const $CCS_RIGHT = 0x0083

; DrawIconEx Constants
Global Const $DI_MASK = 0x0001
Global Const $DI_IMAGE = 0x0002
Global Const $DI_NORMAL = 0x0003
Global Const $DI_COMPAT = 0x0004
Global Const $DI_DEFAULTSIZE = 0x0008
Global Const $DI_NOMIRROR = 0x0010

; EnumDisplayDevice Constants
Global Const $DISPLAY_DEVICE_ATTACHED_TO_DESKTOP = 0x00000001
Global Const $DISPLAY_DEVICE_MULTI_DRIVER = 0x00000002
Global Const $DISPLAY_DEVICE_PRIMARY_DEVICE = 0x00000004
Global Const $DISPLAY_DEVICE_MIRRORING_DRIVER = 0x00000008
Global Const $DISPLAY_DEVICE_VGA_COMPATIBLE = 0x00000010
Global Const $DISPLAY_DEVICE_REMOVABLE = 0x00000020
Global Const $DISPLAY_DEVICE_DISCONNECT = 0x02000000
Global Const $DISPLAY_DEVICE_REMOTE = 0x04000000
Global Const $DISPLAY_DEVICE_MODESPRUNED = 0x08000000

; Dir Constants
; in DirConstants.au3

; File Constants
; in FileConstants.au3

; FlashWindowEx Constants
Global Const $FLASHW_CAPTION = 0x00000001
Global Const $FLASHW_TRAY = 0x00000002
Global Const $FLASHW_TIMER = 0x00000004
Global Const $FLASHW_TIMERNOFG = 0x0000000C

; FormatMessage Constants
Global Const $FORMAT_MESSAGE_ALLOCATE_BUFFER = 0x00000100
Global Const $FORMAT_MESSAGE_IGNORE_INSERTS = 0x00000200
Global Const $FORMAT_MESSAGE_FROM_STRING = 0x00000400
Global Const $FORMAT_MESSAGE_FROM_HMODULE = 0x00000800
Global Const $FORMAT_MESSAGE_FROM_SYSTEM = 0x00001000
Global Const $FORMAT_MESSAGE_ARGUMENT_ARRAY = 0x00002000

; GetWindows Constants
Global Const $GW_HWNDFIRST = 0
Global Const $GW_HWNDLAST = 1
Global Const $GW_HWNDNEXT = 2
Global Const $GW_HWNDPREV = 3
Global Const $GW_OWNER = 4
Global Const $GW_CHILD = 5

; GetWindowLong Constants
Global Const $GWL_WNDPROC = 0xFFFFFFFC
Global Const $GWL_HINSTANCE = 0xFFFFFFFA
Global Const $GWL_HWNDPARENT = 0xFFFFFFF8
Global Const $GWL_ID = 0xFFFFFFF4
Global Const $GWL_STYLE = 0xFFFFFFF0
Global Const $GWL_EXSTYLE = 0xFFFFFFEC
Global Const $GWL_USERDATA = 0xFFFFFFEB

; Standard Icon Index Constants
Global Const $STD_CUT = 0
Global Const $STD_COPY = 1
Global Const $STD_PASTE = 2
Global Const $STD_UNDO = 3
Global Const $STD_REDOW = 4
Global Const $STD_DELETE = 5
Global Const $STD_FILENEW = 6
Global Const $STD_FILEOPEN = 7
Global Const $STD_FILESAVE = 8
Global Const $STD_PRINTPRE = 9
Global Const $STD_PROPERTIES = 10
Global Const $STD_HELP = 11
Global Const $STD_FIND = 12
Global Const $STD_REPLACE = 13
Global Const $STD_PRINT = 14

; Image Load Constants
Global Const $LR_DEFAULTCOLOR = 0x0000
Global Const $LR_MONOCHROME = 0x0001
Global Const $LR_COLOR = 0x0002
Global Const $LR_COPYRETURNORG = 0x0004
Global Const $LR_COPYDELETEORG = 0x0008
Global Const $LR_LOADFROMFILE = 0x0010
Global Const $LR_LOADTRANSPARENT = 0x0020
Global Const $LR_DEFAULTSIZE = 0x0040
Global Const $LR_VGACOLOR = 0x0080
Global Const $LR_LOADMAP3DCOLORS = 0x1000
Global Const $LR_CREATEDIBSECTION = 0x2000
Global Const $LR_COPYFROMRESOURCE = 0x4000
Global Const $LR_SHARED = 0x8000

; Image Type Constants
Global Const $IMAGE_BITMAP = 0
Global Const $IMAGE_ICON = 1
Global Const $IMAGE_CURSOR = 2

; Keyboard Constants
; Changes how keys are processed
Global Const $KB_SENDSPECIAL = 0 ; Special characters indicate key presses (default)
Global Const $KB_SENDRAW = 1 ; Keys are sent raw

; Sets the state of the Caps Lock key
Global Const $KB_CAPSOFF = 0 ; Caps Lock is off
Global Const $KB_CAPSON = 1 ; Caps Lock is on

; LoadLibraryEx Constants
Global Const $DONT_RESOLVE_DLL_REFERENCES = 0x01
Global Const $LOAD_LIBRARY_AS_DATAFILE = 0x02
Global Const $LOAD_WITH_ALTERED_SEARCH_PATH = 0x08

; Reserved IDs for System Objects
; in MenuConstants.au3

; in ScrollBarConstants.au3

Global Const $OBJID_WINDOW = 0x00000000
Global Const $OBJID_TITLEBAR = 0xFFFFFFFE
Global Const $OBJID_SIZEGRIP = 0xFFFFFFF9
Global Const $OBJID_CARET = 0xFFFFFFF8
Global Const $OBJID_CURSOR = 0xFFFFFFF7
Global Const $OBJID_ALERT = 0xFFFFFFF6
Global Const $OBJID_SOUND = 0xFFFFFFF5

; Virtual Keys Constants
Global Const $VK_DOWN = 0x28
Global Const $VK_END = 0x23
Global Const $VK_HOME = 0x24
Global Const $VK_LEFT = 0x25
Global Const $VK_NEXT = 0x22
Global Const $VK_PRIOR = 0x21
Global Const $VK_RIGHT = 0x27
Global Const $VK_UP = 0x26

Global Const $VK_LBUTTON = 0x01
Global Const $VK_RBUTTON = 0x02
Global Const $VK_MBUTTON = 0x04

; Message Box Constants
; Indicates the buttons displayed in the message box
Global Const $MB_OK = 0 ; One push button: OK
Global Const $MB_OKCANCEL = 1 ; Two push buttons: OK and Cancel
Global Const $MB_ABORTRETRYIGNORE = 2 ; Three push buttons: Abort, Retry, and Ignore
Global Const $MB_YESNOCANCEL = 3 ; Three push buttons: Yes, No, and Cancel
Global Const $MB_YESNO = 4 ; Two push buttons: Yes and No
Global Const $MB_RETRYCANCEL = 5 ; Two push buttons: Retry and Cancel

; Displays an icon in the message box
Global Const $MB_ICONHAND = 16 ; Stop-sign icon
Global Const $MB_ICONQUESTION = 32 ; Question-mark icon
Global Const $MB_ICONEXCLAMATION = 48 ; Exclamation-point icon
Global Const $MB_ICONASTERISK = 64 ; Icon consisting of an 'i' in a circle

; Indicates the default button
Global Const $MB_DEFBUTTON1 = 0 ; The first button is the default button
Global Const $MB_DEFBUTTON2 = 256 ; The second button is the default button
Global Const $MB_DEFBUTTON3 = 512 ; The third button is the default button

; Indicates the modality of the dialog box
Global Const $MB_APPLMODAL = 0 ; Application modal
Global Const $MB_SYSTEMMODAL = 4096 ; System modal
Global Const $MB_TASKMODAL = 8192 ; Task modal

; Indicates miscellaneous message box attributes
Global Const $MB_TOPMOST = 262144 ; top-most attribute
Global Const $MB_RIGHTJUSTIFIED = 524288 ; right-justified title and text

; Indicates the button selected in the message box
Global Const $IDTIMEOUT = -1 ; The message box timed out
Global Const $IDOK = 1 ; OK button was selected
Global Const $IDCANCEL = 2 ; Cancel button was selected
Global Const $IDABORT = 3 ; Abort button was selected
Global Const $IDRETRY = 4 ; Retry button was selected
Global Const $IDIGNORE = 5 ; Ignore button was selected
Global Const $IDYES = 6 ; Yes button was selected
Global Const $IDNO = 7 ; No button was selected
Global Const $IDTRYAGAIN = 10 ; Try Again button was selected
Global Const $IDCONTINUE = 11 ; Continue button was selected


; Progress and Splash Constants
; Indicates properties of the displayed progress or splash dialog
Global Const $DLG_NOTITLE = 1 ; Titleless window
Global Const $DLG_NOTONTOP = 2 ; Without "always on top" attribute
Global Const $DLG_TEXTLEFT = 4 ; Left justified text
Global Const $DLG_TEXTRIGHT = 8 ; Right justified text
Global Const $DLG_MOVEABLE = 16 ; Window can be moved
Global Const $DLG_TEXTVCENTER = 32 ; Splash text centered vertically


; Tray Tip Constants
; Indicates the type of Balloon Tip to display
Global Const $TIP_ICONNONE = 0 ; No icon (default)
Global Const $TIP_ICONASTERISK = 1 ; Info icon
Global Const $TIP_ICONEXCLAMATION = 2 ; Warning icon
Global Const $TIP_ICONHAND = 3 ; Error icon
Global Const $TIP_NOSOUND = 16 ; No sound


; Mouse Constants
; Indicates current mouse cursor
Global Const $IDC_UNKNOWN = 0 ; Unknown cursor
Global Const $IDC_APPSTARTING = 1 ; Standard arrow and small hourglass
Global Const $IDC_ARROW = 2 ; Standard arrow
Global Const $IDC_CROSS = 3 ; Crosshair
Global Const $IDC_HAND = 32649 ; Hand cursor
Global Const $IDC_HELP = 4 ; Arrow and question mark
Global Const $IDC_IBEAM = 5 ; I-beam
Global Const $IDC_ICON = 6 ; Obsolete
Global Const $IDC_NO = 7 ; Slashed circle
Global Const $IDC_SIZE = 8 ; Obsolete
Global Const $IDC_SIZEALL = 9 ; Four-pointed arrow pointing N, S, E, and W
Global Const $IDC_SIZENESW = 10 ; Double-pointed arrow pointing NE and SW
Global Const $IDC_SIZENS = 11 ; Double-pointed arrow pointing N and S
Global Const $IDC_SIZENWSE = 12 ; Double-pointed arrow pointing NW and SE
Global Const $IDC_SIZEWE = 13 ; Double-pointed arrow pointing W and E
Global Const $IDC_UPARROW = 14 ; Vertical arrow
Global Const $IDC_WAIT = 15 ; Hourglass

Global Const $IDI_APPLICATION = 32512 ; Application icon
Global Const $IDI_ASTERISK = 32516 ; Asterisk icon
Global Const $IDI_EXCLAMATION = 32515 ; Exclamation point icon
Global Const $IDI_HAND = 32513 ; Stop sign icon
Global Const $IDI_QUESTION = 32514 ; Question-mark icon
Global Const $IDI_WINLOGO = 32517 ; Windows logo icon. Windows XP: Application icon


; Process Constants
; Indicates the type of shutdown
Global Const $SD_LOGOFF = 0 ; Logoff
Global Const $SD_SHUTDOWN = 1 ; Shutdown
Global Const $SD_REBOOT = 2 ; Reboot
Global Const $SD_FORCE = 4 ; Force
Global Const $SD_POWERDOWN = 8 ; Power down

; OpenProcess Constants
; in ProcessConstants.au3

; String Constants
; Indicates if string operations should be case sensitive
Global Const $STR_NOCASESENSE = 0 ; Not case sensitive (default)
Global Const $STR_CASESENSE = 1 ; Case sensitive

; IndicateS the type of stripping that should be performed
Global Const $STR_STRIPLEADING = 1 ; Strip leading whitespace
Global Const $STR_STRIPTRAILING = 2 ; Strip trailing whitespace
Global Const $STR_STRIPSPACES = 4 ; Strip double (or more) spaces between words
Global Const $STR_STRIPALL = 8 ; Strip all spaces (over-rides all other flags)

; Token Constants
; in SecurityConstants.au3

; Tray Constants
; Tray predefined ID's
Global Const $TRAY_ITEM_EXIT = 3
Global Const $TRAY_ITEM_PAUSE = 4
Global Const $TRAY_ITEM_FIRST = 7

; Tray menu/item state values
Global Const $TRAY_CHECKED = 1
Global Const $TRAY_UNCHECKED = 4
Global Const $TRAY_ENABLE = 64
Global Const $TRAY_DISABLE = 128
Global Const $TRAY_FOCUS = 256
Global Const $TRAY_DEFAULT = 512

; Tray event values
Global Const $TRAY_EVENT_SHOWICON = -3
Global Const $TRAY_EVENT_HIDEICON = -4
Global Const $TRAY_EVENT_FLASHICON = -5
Global Const $TRAY_EVENT_NOFLASHICON = -6
Global Const $TRAY_EVENT_PRIMARYDOWN = -7
Global Const $TRAY_EVENT_PRIMARYUP = -8
Global Const $TRAY_EVENT_SECONDARYDOWN = -9
Global Const $TRAY_EVENT_SECONDARYUP = -10
Global Const $TRAY_EVENT_MOUSEOVER = -11
Global Const $TRAY_EVENT_MOUSEOUT = -12
Global Const $TRAY_EVENT_PRIMARYDOUBLE = -13
Global Const $TRAY_EVENT_SECONDARYDOUBLE = -14

; Run Constants
Global Const $STDIN_CHILD = 1
Global Const $STDOUT_CHILD = 2
Global Const $STDERR_CHILD = 4
Global Const $STDERR_MERGED = 8
Global Const $STDIO_INHERIT_PARENT = 0x10
Global Const $RUN_CREATE_NEW_CONSOLE = 0x00010000

; Colour Constants
; in ColorConstants.au3

; Mouse Event Constants
Global Const $MOUSEEVENTF_ABSOLUTE = 0x8000 ; Specifies that the dx and dy parameters contain normalized absolute coordinates
Global Const $MOUSEEVENTF_MOVE = 0x0001 ; Specifies that movement occurred
Global Const $MOUSEEVENTF_LEFTDOWN = 0x0002 ; Specifies that the left button changed to down
Global Const $MOUSEEVENTF_LEFTUP = 0x0004 ; Specifies that the left button changed to up
Global Const $MOUSEEVENTF_RIGHTDOWN = 0x0008 ; Specifies that the right button changed to down
Global Const $MOUSEEVENTF_RIGHTUP = 0x0010 ; Specifies that the right button changed to up
Global Const $MOUSEEVENTF_MIDDLEDOWN = 0x0020 ; Specifies that the middle button changed to down
Global Const $MOUSEEVENTF_MIDDLEUP = 0x0040 ; Specifies that the middle button changed to up
Global Const $MOUSEEVENTF_WHEEL = 0x0800 ; Specifies that the wheel has been moved, if the mouse has a wheel
Global Const $MOUSEEVENTF_XDOWN = 0x0080 ; Specifies that an X button was pressed
Global Const $MOUSEEVENTF_XUP = 0x0100 ; Specifies that an X button was released

; Reg Value type Constants
Global Const $REG_NONE = 0
Global Const $REG_SZ = 1
Global Const $REG_EXPAND_SZ = 2
Global Const $REG_BINARY = 3
Global Const $REG_DWORD = 4
Global Const $REG_DWORD_BIG_ENDIAN = 5
Global Const $REG_LINK = 6
Global Const $REG_MULTI_SZ = 7
Global Const $REG_RESOURCE_LIST = 8
Global Const $REG_FULL_RESOURCE_DESCRIPTOR = 9
Global Const $REG_RESOURCE_REQUIREMENTS_LIST = 10

; Z order
Global Const $HWND_BOTTOM = 1 ; Places the window at the bottom of the Z order
Global Const $HWND_NOTOPMOST = -2 ; Places the window above all non-topmost windows
Global Const $HWND_TOP = 0 ; Places the window at the top of the Z order
Global Const $HWND_TOPMOST = -1 ; Places the window above all non-topmost windows

; SetWindowPos Constants
Global Const $SWP_NOSIZE = 0x0001
Global Const $SWP_NOMOVE = 0x0002
Global Const $SWP_NOZORDER = 0x0004
Global Const $SWP_NOREDRAW = 0x0008
Global Const $SWP_NOACTIVATE = 0x0010
Global Const $SWP_FRAMECHANGED = 0x0020
Global Const $SWP_DRAWFRAME = 0x0020
Global Const $SWP_SHOWWINDOW = 0x0040
Global Const $SWP_HIDEWINDOW = 0x0080
Global Const $SWP_NOCOPYBITS = 0x0100
Global Const $SWP_NOOWNERZORDER = 0x0200
Global Const $SWP_NOREPOSITION = 0x0200
Global Const $SWP_NOSENDCHANGING = 0x0400
Global Const $SWP_DEFERERASE = 0x2000
Global Const $SWP_ASYNCWINDOWPOS = 0x4000


; language identifiers
Global Const $LANG_AFRIKAANS = 0x36
Global Const $LANG_ALBANIAN = 0x1c
Global Const $LANG_ARABIC = 0x01
Global Const $LANG_ARMENIAN = 0x2b
Global Const $LANG_ASSAMESE = 0x4d
Global Const $LANG_AZERI = 0x2c
Global Const $LANG_BASQUE = 0x2d
Global Const $LANG_BELARUSIAN = 0x23
Global Const $LANG_BENGALI = 0x45
Global Const $LANG_BULGARIAN = 0x02
Global Const $LANG_CATALAN = 0x03
Global Const $LANG_CHINESE = 0x04
Global Const $LANG_CROATIAN = 0x1A
Global Const $LANG_CZECH = 0x05
Global Const $LANG_DANISH = 0x06
Global Const $LANG_DUTCH = 0x13
Global Const $LANG_ENGLISH = 0x09
Global Const $LANG_ESTONIAN = 0x25
Global Const $LANG_FAEROESE = 0x38
Global Const $LANG_FARSI = 0x29
Global Const $LANG_FINNISH = 0x0B
Global Const $LANG_FRENCH = 0x9C
Global Const $LANG_GEORGIAN = 0x37
Global Const $LANG_GERMAN = 0x07
Global Const $LANG_GREEK = 0x08
Global Const $LANG_GUJARATI = 0x47
Global Const $LANG_HEBREW = 0x0D
Global Const $LANG_HINDI = 0x39
Global Const $LANG_HUNGARIAN = 0x0E
Global Const $LANG_ICELANDIC = 0x0F
Global Const $LANG_INDONESIAN = 0x21
Global Const $LANG_ITALIAN = 0x10
Global Const $LANG_JAPANESE = 0x11
Global Const $LANG_KANNADA = 0x4b
Global Const $LANG_KASHMIRI = 0x60
Global Const $LANG_KAZAK = 0x3f
Global Const $LANG_KONKANI = 0x57
Global Const $LANG_KOREAN = 0x12
Global Const $LANG_LATVIAN = 0x26
Global Const $LANG_LITHUANIAN = 0x27
Global Const $LANG_MACEDONIAN = 0x2f
Global Const $LANG_MALAY = 0x3e
Global Const $LANG_MALAYALAM = 0x4c
Global Const $LANG_MANIPURI = 0x58
Global Const $LANG_MARATHI = 0x4e
Global Const $LANG_NEPALI = 0x61
Global Const $LANG_NEUTRAL = 0x0
Global Const $LANG_NORWEGIAN = 0x14
Global Const $LANG_ORIYA = 0x48
Global Const $LANG_POLISH = 0x15
Global Const $LANG_PORTUGUESE = 0x16
Global Const $LANG_PUNJABI = 0x46
Global Const $LANG_ROMANIAN = 0x18
Global Const $LANG_RUSSIAN = 0x19
Global Const $LANG_SANSKRIT = 0x4f
Global Const $LANG_SERBIAN = 0x1a
Global Const $LANG_SINDHI = 0x59
Global Const $LANG_SLOVAK = 0x1B
Global Const $LANG_SLOVENIAN = 0x24
Global Const $LANG_SPANISH = 0x0A
Global Const $LANG_SWAHILI = 0x41
Global Const $LANG_SWEDISH = 0x1D
Global Const $LANG_TAMIL = 0x49
Global Const $LANG_TATAR = 0x44
Global Const $LANG_TELUGU = 0x4a
Global Const $LANG_THAI = 0x1e
Global Const $LANG_TURKISH = 0x1F
Global Const $LANG_UKRAINIAN = 0x22
Global Const $LANG_URDU = 0x20
Global Const $LANG_UZBEK = 0x43
Global Const $LANG_VIETNAMESE = 0x2a

; sublanguage identifiers
Global Const $SUBLANG_ARABIC_ALGERIA = 0x05
Global Const $SUBLANG_ARABIC_BAHRAIN = 0x0f
Global Const $SUBLANG_ARABIC_EGYPT = 0x03
Global Const $SUBLANG_ARABIC_IRAQ = 0x02
Global Const $SUBLANG_ARABIC_JORDAN = 0x0b
Global Const $SUBLANG_ARABIC_KUWAIT = 0x0d
Global Const $SUBLANG_ARABIC_LEBANON = 0x0c
Global Const $SUBLANG_ARABIC_LIBYA = 0x04
Global Const $SUBLANG_ARABIC_MOROCCO = 0x06
Global Const $SUBLANG_ARABIC_OMAN = 0x08
Global Const $SUBLANG_ARABIC_QATAR = 0x10
Global Const $SUBLANG_ARABIC_SAUDI_ARABIA = 0x01
Global Const $SUBLANG_ARABIC_SYRIA = 0x0a
Global Const $SUBLANG_ARABIC_TUNISIA = 0x07
Global Const $SUBLANG_ARABIC_UAE = 0x0e
Global Const $SUBLANG_ARABIC_YEMEN = 0x09
Global Const $SUBLANG_AZERI_CYRILLIC = 0x02
Global Const $SUBLANG_AZERI_LATIN = 0x01
Global Const $SUBLANG_CHINESE_HONGKONG = 0x03
Global Const $SUBLANG_CHINESE_MACAU = 0x05
Global Const $SUBLANG_CHINESE_SIMPLIFIED = 0x02
Global Const $SUBLANG_CHINESE_SINGAPORE = 0x04
Global Const $SUBLANG_CHINESE_TRADITIONAL = 0x01
Global Const $SUBLANG_DEFAULT = 0x01
Global Const $SUBLANG_DUTCH = 0x01
Global Const $SUBLANG_DUTCH_BELGIAN = 0x02
Global Const $SUBLANG_ENGLISH_AUS = 0x03
Global Const $SUBLANG_ENGLISH_BELIZE = 0x0a
Global Const $SUBLANG_ENGLISH_CAN = 0x04
Global Const $SUBLANG_ENGLISH_CARIBBEAN = 0x09
Global Const $SUBLANG_ENGLISH_EIRE = 0x06
Global Const $SUBLANG_ENGLISH_JAMAICA = 0x08
Global Const $SUBLANG_ENGLISH_NZ = 0x05
Global Const $SUBLANG_ENGLISH_PHILIPPINES = 0x0d
Global Const $SUBLANG_ENGLISH_SOUTH_AFRICA = 0x07
Global Const $SUBLANG_ENGLISH_TRINIDAD = 0x0b
Global Const $SUBLANG_ENGLISH_UK = 0x02
Global Const $SUBLANG_ENGLISH_US = 0x01
Global Const $SUBLANG_ENGLISH_ZIMBABWE = 0x0c
Global Const $SUBLANG_FRENCH = 0x01
Global Const $SUBLANG_FRENCH_BELGIAN = 0x02
Global Const $SUBLANG_FRENCH_CANADIAN = 0x03
Global Const $SUBLANG_FRENCH_LUXEMBOURG = 0x05
Global Const $SUBLANG_FRENCH_MONACO = 0x06
Global Const $SUBLANG_FRENCH_SWISS = 0x04
Global Const $SUBLANG_GERMAN = 0x01
Global Const $SUBLANG_GERMAN_AUSTRIAN = 0x03
Global Const $SUBLANG_GERMAN_LIECHTENSTEIN = 0x05
Global Const $SUBLANG_GERMAN_LUXEMBOURG = 0x04
Global Const $SUBLANG_GERMAN_SWISS = 0x02
Global Const $SUBLANG_ITALIAN = 0x01
Global Const $SUBLANG_ITALIAN_SWISS = 0x02
Global Const $SUBLANG_KASHMIRI_INDIA = 0x02
Global Const $SUBLANG_KOREAN = 0x01
Global Const $SUBLANG_LITHUANIAN = 0x01
Global Const $SUBLANG_MALAY_BRUNEI_DARUSSALAM = 0x02
Global Const $SUBLANG_MALAY_MALAYSIA = 0x01
Global Const $SUBLANG_NEPALI_INDIA = 0x02
Global Const $SUBLANG_NEUTRAL = 0x0
Global Const $SUBLANG_NORWEGIAN_BOKMAL = 0x01
Global Const $SUBLANG_NORWEGIAN_NYNORSK = 0x02
Global Const $SUBLANG_PORTUGUESE = 0x02
Global Const $SUBLANG_PORTUGUESE_BRAZILIAN = 0x01
Global Const $SUBLANG_SERBIAN_CYRILLIC = 0x03
Global Const $SUBLANG_SERBIAN_LATIN = 0x02
Global Const $SUBLANG_SPANISH = 0x01
Global Const $SUBLANG_SPANISH_ARGENTINA = 0x0b
Global Const $SUBLANG_SPANISH_BOLIVIA = 0x10
Global Const $SUBLANG_SPANISH_CHILE = 0x0d
Global Const $SUBLANG_SPANISH_COLOMBIA = 0x09
Global Const $SUBLANG_SPANISH_COSTA_RICA = 0x05
Global Const $SUBLANG_SPANISH_DOMINICAN_REPUBLIC = 0x07
Global Const $SUBLANG_SPANISH_ECUADOR = 0x0c
Global Const $SUBLANG_SPANISH_EL_SALVADOR = 0x11
Global Const $SUBLANG_SPANISH_GUATEMALA = 0x04
Global Const $SUBLANG_SPANISH_HONDURAS = 0x12
Global Const $SUBLANG_SPANISH_MEXICAN = 0x02
Global Const $SUBLANG_SPANISH_MODERN = 0x03
Global Const $SUBLANG_SPANISH_NICARAGUA = 0x13
Global Const $SUBLANG_SPANISH_PANAMA = 0x06
Global Const $SUBLANG_SPANISH_PARAGUAY = 0x0f
Global Const $SUBLANG_SPANISH_PERU = 0x0a
Global Const $SUBLANG_SPANISH_PUERTO_RICO = 0x14
Global Const $SUBLANG_SPANISH_URUGUAY = 0x0e
Global Const $SUBLANG_SPANISH_VENEZUELA = 0x08
Global Const $SUBLANG_SWEDISH = 0x01
Global Const $SUBLANG_SWEDISH_FINLAND = 0x02
Global Const $SUBLANG_SYS_DEFAULT = 0x02
Global Const $SUBLANG_URDU_INDIA = 0x02
Global Const $SUBLANG_URDU_PAKISTAN = 0x01
Global Const $SUBLANG_UZBEK_CYRILLIC = 0x02

; Sorting IDs. (from WINNT.H)
Global Const $SORT_DEFAULT = 0x0 ; sorting default
Global Const $SORT_JAPANESE_XJIS = 0x0 ; Japanese XJIS order
Global Const $SORT_JAPANESE_UNICODE = 0x1 ; Japanese Unicode order
Global Const $SORT_CHINESE_BIG5 = 0x0 ; Chinese BIG5 order
Global Const $SORT_CHINESE_PRCP = 0x0 ; PRC Chinese Phonetic order
Global Const $SORT_CHINESE_UNICODE = 0x1 ; Chinese Unicode order
Global Const $SORT_CHINESE_PRC = 0x2 ; PRC Chinese Stroke Count order
Global Const $SORT_KOREAN_KSC = 0x0 ; Korean KSC order
Global Const $SORT_KOREAN_UNICODE = 0x1 ; Korean Unicode order
Global Const $SORT_GERMAN_PHONE_BOOK = 0x1 ; German Phone Book order
Global Const $SORT_HUNGARIAN_DEFAULT = 0x0 ; Hungarian Default order
Global Const $SORT_HUNGARIAN_TECHNICAL = 0x1 ; Hungarian Technical order
Global Const $SORT_GEORGIAN_TRADITIONAL = 0x0 ; Georgian Traditional order
Global Const $SORT_GEORGIAN_MODERN = 0x1 ; Georgian Modern order

; ===============================================================================================================================
