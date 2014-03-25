#include-once

; #INDEX# =======================================================================================================================
; Title .........: Structures_Constants
; AutoIt Version : 3.2.++
; Description ...: Constants for Windows API functions.
; Author(s) .....: Paul Campbell (PaulIA), Gary Frost, Jpm
; ===============================================================================================================================

; #LISTING# =====================================================================================================================
;$tagPOINT
;$tagRECT
;$tagMARGINS
;$tagSIZE
;$tagFILETIME
;$tagSYSTEMTIME
;$tagTIME_ZONE_INFORMATION
;$tagNMHDR
;$tagCOMBOBOXEXITEM
;$tagNMCBEDRAGBEGIN
;$tagNMCBEENDEDIT
;$tagNMCOMBOBOXEX
;$tagDTPRANGE
;$tagNMDATETIMECHANGE
;$tagNMDATETIMEFORMAT
;$tagNMDATETIMEFORMATQUERY
;$tagNMDATETIMEKEYDOWN
;$tagNMDATETIMESTRING
;$tagEVENTLOGRECORD
;$tagGDIPBITMAPDATA
;$tagGDIPENCODERPARAM
;$tagGDIPENCODERPARAMS
;$tagGDIPRECTF
;$tagGDIPSTARTUPINPUT
;$tagGDIPSTARTUPOUTPUT
;$tagGDIPIMAGECODECINFO
;$tagGDIPPENCODERPARAMS
;$tagHDITEM
;$tagNMHDDISPINFO
;$tagNMHDFILTERBTNCLICK
;$tagNMHEADER
;$tagGETIPAddress
;$tagNMIPADDRESS
;$tagLVHITTESTINFO
;$tagLVITEM
;$tagNMLISTVIEW
;$tagNMLVCUSTOMDRAW
;$tagNMLVDISPINFO
;$tagNMLVFINDITEM
;$tagNMLVGETINFOTIP
;$tagNMITEMACTIVATE
;$tagNMLVKEYDOWN
;$tagNMLVSCROLL
;$tagMCHITTESTINFO
;$tagMCMONTHRANGE
;$tagMCRANGE
;$tagMCSELRANGE
;$tagNMDAYSTATE
;$tagNMSELCHANGE
;$tagNMOBJECTNOTIFY
;$tagNMTCKEYDOWN
;$tagTVITEMEX
;$tagNMTREEVIEW
;$tagNMTVCUSTOMDRAW
;$tagNMTVDISPINFO
;$tagNMTVGETINFOTIP
;$tagTVHITTESTINFO
;$tagNMTVKEYDOWN
;$tagNMMOUSE
;$tagTOKEN_PRIVILEGES
;$tagIMAGEINFO
;$tagMENUINFO
;$tagMENUITEMINFO
;$tagREBARBANDINFO
;$tagNMREBARAUTOBREAK
;$tagNMRBAUTOSIZE
;$tagNMREBAR
;$tagNMREBARCHEVRON
;$tagNMREBARCHILDSIZE
;$tagCOLORSCHEME
;$tagNMTOOLBAR
;$tagNMTBHOTITEM
;$tagTBBUTTON
;$tagTBBUTTONINFO
;$tagNETRESOURCE
;$tagOVERLAPPED
;$tagOPENFILENAME
;$tagBITMAPINFO
;$tagBLENDFUNCTION
;$tagGUID
;$tagWINDOWPLACEMENT
;$tagWINDOWPOS
;$tagSCROLLINFO
;$tagSCROLLBARINFO
;$tagLOGFONT
;$tagKBDLLHOOKSTRUCT
;$tagPROCESS_INFORMATION
;$tagSTARTUPINFO
;$tagSECURITY_ATTRIBUTES
;$tagWIN32_FIND_DATA
;$tagTEXTMETRIC
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;$tagTVITEM
;$tagLVFINDINFO
; ===============================================================================================================================

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagPOINT
; Description ...: Defines the x- and y- coordinates of a point
; Fields ........: X - Specifies the x-coordinate of the point
;                  Y - Specifies the y-coordinate of the point
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagPOINT = "struct;long X;long Y;endstruct"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagRECT
; Description ...: Defines the coordinates of the upper-left and lower-right corners of a rectangle
; Fields ........: Left   - Specifies the x-coordinate of the upper-left corner of the rectangle
;                  Top    - Specifies the y-coordinate of the upper-left corner of the rectangle
;                  Right  - Specifies the x-coordinate of the lower-right corner of the rectangle
;                  Bottom - Specifies the y-coordinate of the lower-right corner of the rectangle
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagRECT = "struct;long Left;long Top;long Right;long Bottom;endstruct"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagSIZE
; Description ...: Stores an ordered pair of integers, typically the width and height of a rectangle
; Fields ........: X - Width
;                  Y - Height
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagSIZE = "struct;long X;long Y;endstruct"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagMARGINS
; Description ...: Defines the margins of windows that have visual styles applied
; Fields ........: cxLeftWidth    - Width of the left border that retains its size
;                  cxRightWidth   - Width of the right border that retains its size
;                  cyTopHeight    - Height of the top border that retains its size
;                  cyBottomHeight - Height of the bottom border that retains its size
; Author ........: Gary Frost
; Remarks .......:
; ===============================================================================================================================
Global Const $tagMARGINS = "int cxLeftWidth;int cxRightWidth;int cyTopHeight;int cyBottomHeight"

; *******************************************************************************************************************************
; Time Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #STRUCTURE# ===================================================================================================================
; Name...........: $tagFILETIME
; Description ...: Contains the number of 100-nanosecond intervals since January 1, 1601
; Fields ........: Lo - The low order part of the file time
;                  Hi - The high order part of the file time
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagFILETIME = "struct;dword Lo;dword Hi;endstruct"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagSYSTEMTIME
; Description ...: Specifies a date and time, in coordinated universal time (UTC)
; Fields ........: Year     - Year
;                  Month    - Month
;                  Dow      - Day of week
;                  Day      - Day
;                  Hour     - Hour
;                  Minute   - Minute
;                  Second   - Second
;                  MSeconds - MSeconds
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagSYSTEMTIME = "struct;word Year;word Month;word Dow;word Day;word Hour;word Minute;word Second;word MSeconds;endstruct"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagTIME_ZONE_INFORMATION
; Description ...: Specifies information specific to the time zone
; Fields ........: Bias    - The current bias for local time translation on this computer, in minutes
;                  StdName - A description for standard time
;                  StdDate - A SYSTEMTIME structure that contains a date and local time when the transition from daylight  saving
;                  +time to standard time occurs on this operating system.
;                  StdBias - The bias value to be used during local time translations that occur during standard time
;                  DayName - A description for daylight saving time
;                  DayDate - A SYSTEMTIME structure that contains a date and local time when the transition  from  standard  time
;                  +to daylight saving time occurs on this operating system.
;                  DayBias - The bias value to be used during local time translations that occur during daylight saving time
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagTIME_ZONE_INFORMATION = "struct;long Bias;wchar StdName[32];word StdDate[8];long StdBias;wchar DayName[32];word DayDate[8];long DayBias;endstruct"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMHDR
; Description ...: Contains information about a notification message
; Fields ........: hWndFrom - Window handle to the control sending a message
;                  IDFrom   - Identifier of the control sending a message
;                  Code     - Notification code (define as UINT in MSDN but tested with negative value)
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMHDR = "struct;hwnd hWndFrom;uint_ptr IDFrom;INT Code;endstruct"

; ===============================================================================================================================
; *******************************************************************************************************************************
; ComboBoxEx Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #STRUCTURE# ===================================================================================================================
; Name...........: $tagCOMBOBOXEXITEM
; Description ...: Contains information about an item in a ComboBoxEx control
; Fields ........: Mask                 - A set of bit flags that specify attributes.  Can be a combination of the following values.
;                  |CBEIF_DI_SETITEM    - Set this flag when processing CBEN_GETDISPINFO
;                  |CBEIF_IMAGE         - The iImage member is valid or must be filled in.
;                  |CBEIF_INDENT        - The iIndent member is valid or must be filled in.
;                  |CBEIF_LPARAM        - The lParam member is valid or must be filled in.
;                  |CBEIF_OVERLAY       - The iOverlay member is valid or must be filled in.
;                  |CBEIF_SELECTEDIMAGE - The iSelectedImage member is valid or must be filled in.
;                  |CBEIF_TEXT          - The pszText member is valid or must be filled in.
;                  Item                 - The zero-based index of the item.
;                  Text              - A pointer to a character buffer that contains or receives the item's text.
;                  TextMax              - The length of pszText, in TCHARs. If text information is being set, this member is ignored.
;                  Image                - The zero-based index of an image within the image list.
;                  SelectedImage        - The zero-based index of an image within the image list.
;                  OverlayImage         - The one-based index of an overlay image within the image list.
;                  Indent               - The number of indent spaces to display for the item. Each indentation equals 10 pixels.
;                  Param                - A value specific to the item.
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagCOMBOBOXEXITEM = "uint Mask;int_ptr Item;ptr Text;int TextMax;int Image;int SelectedImage;int OverlayImage;" & _
		"int Indent;lparam Param"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMCBEDRAGBEGIN
; Description ...: Contains information used with the $CBEN_DRAGBEGIN notification message
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  ItemID               - The zero-based index of the item being dragged.  This value will always be -1,
;                  +indicating that the item being dragged is the item displayed in the edit portion of the control.
;                  szText                 - The character buffer that contains the text of the item being dragged
; Author ........: Gary Frost (gafrost)
; Modified ......: jpm
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMCBEDRAGBEGIN = $tagNMHDR & ";int ItemID;wchar szText[260]"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMCBEENDEDIT
; Description ...: Contains information about the conclusion of an edit operation within a ComboBoxEx control
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  fChanged             - Indicating whether the contents of the control's edit box have changed
;                  NewSelection         - The zero-based index of the item that will be selected after completing the edit operation
;                  +This value can be $CB_ERR if no item will be selected
;                  szText                  - A zero-terminated string that contains the text from within the control's edit box
;                  Why                   - The action that generated the $CBEN_ENDEDIT notification message
;                  +This value can be one of the following:
;                  |$CBENF_DROPDOWN      - The user activated the drop-down list
;                  |$CBENF_ESCAPE        - The user pressed ESC
;                  |$CBENF_KILLFOCUS     - The edit box lost the keyboard focus
;                  |$CBENF_RETURN        - The user completed the edit operation by pressing ENTER
; Author ........: Gary Frost (gafrost)
; Modified ......: jpm
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMCBEENDEDIT = $tagNMHDR & ";bool fChanged;int NewSelection;wchar szText[260];int Why"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMCOMBOBOXEX
; Description ...: Contains information specific to ComboBoxEx items for use with notification messages
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  Mask                 - A set of bit flags that specify attributes.  Can be a combination of the following values.
;                  |CBEIF_DI_SETITEM    - Set this flag when processing CBEN_GETDISPINFO
;                  |CBEIF_IMAGE         - The iImage member is valid or must be filled in.
;                  |CBEIF_INDENT        - The iIndent member is valid or must be filled in.
;                  |CBEIF_LPARAM        - The lParam member is valid or must be filled in.
;                  |CBEIF_OVERLAY       - The iOverlay member is valid or must be filled in.
;                  |CBEIF_SELECTEDIMAGE - The iSelectedImage member is valid or must be filled in.
;                  |CBEIF_TEXT          - The pszText member is valid or must be filled in.
;                  Item                 - The zero-based index of the item.
;                  Text              - A pointer to a character buffer that contains or receives the item's text.
;                  TextMax              - The length of pszText, in TCHARs. If text information is being set, this member is ignored.
;                  Image                - The zero-based index of an image within the image list.
;                  SelectedImage        - The zero-based index of an image within the image list.
;                  OverlayImage         - The one-based index of an overlay image within the image list.
;                  Indent               - The number of indent spaces to display for the item. Each indentation equals 10 pixels.
;                  Param                - A value specific to the item.
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMCOMBOBOXEX = $tagNMHDR & ";uint Mask;int_ptr Item;ptr Text;int TextMax;int Image;" & _
		"int SelectedImage;int OverlayImage;int Indent;lparam Param"

; ===============================================================================================================================
; *******************************************************************************************************************************
; Date/Time Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #STRUCTURE# ===================================================================================================================
; Name...........: $tagDTPRANGE
; Description ...: Specifies a date and time, in coordinated universal time (UTC)
; Fields ........: MinYear    - Minimum year
;                  MinMonth   - Minimum month
;                  MinDOW     - Minimum day of week
;                  MinDay     - Minimum day
;                  MinHour    - Minimum hour
;                  MinMinute  - Minimum minute
;                  MinSecond  - Minimum second
;                  MinMSecond - Minimum milliseconds
;                  MaxYear    - Maximum year
;                  MaxMonth   - Maximum month
;                  MaxDOW     - Maximum day of week
;                  MaxDay     - Maximum day
;                  MaxHour    - Maximum hour
;                  MaxMinute  - Maximum Minute
;                  MaxSecond  - Maximum second
;                  MaxMSecond - Maximum milliseconds
;                  MinValid   - If True, minimum data is valid
;                  MaxValid   - If True, maximum data is valid
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagDTPRANGE = "word MinYear;word MinMonth;word MinDOW;word MinDay;word MinHour;word MinMinute;" & _
		"word MinSecond;word MinMSecond;word MaxYear;word MaxMonth;word MaxDOW;word MaxDay;word MaxHour;" & _
		"word MaxMinute;word MaxSecond;word MaxMSecond;bool MinValid;bool MaxValid"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMDATETIMECHANGE
; Description ...: Contains information about a change that has taken place in a date and time picker (DTP) control
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  Flag   - Indicates if the control is set to "no date" status.  This flag also specifies whether the  contents
;                  +of the date are valid and contain current time information. This value can be one of the following:
;                  | $GDT_NONE  - The control is set to "no date" status
;                  | $GDT_VALID - The control is not set to the "no date" status
;                  Year    - Year
;                  Month   - Month
;                  DOW     - Day of week
;                  Day     - Day
;                  Hour    - Hour
;                  Minute  - Minute
;                  Second  - Second
;                  MSecond - Milliseconds
; Author ........: Paul Campbell (PaulIA)
; Remarks .......: This  structure  is  used  with  the $DTN_DATETIMECHANGE notification message
; ===============================================================================================================================
Global Const $tagNMDATETIMECHANGE = $tagNMHDR & ";dword Flag;" & $tagSYSTEMTIME

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMDATETIMEFORMAT
; Description ...: Contains information about a portion of the format string that defines a callback field within a date and time picker (DTP) control
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  Format   - Pointer to a null terminated string that defines the control callback field.  The string  comprises
;                  +one or more "X" characters.
;                  Year     - Year
;                  Month    - Month
;                  DOW      - Day of week
;                  Day      - Day
;                  Hour     - Hour
;                  Minute   - Minute
;                  Second   - Second
;                  MSecond  - Milliseconds
;                  pDisplay - Pointer to a null terminated string that contains the display text of the control. By default, this
;                  +is the address of the Display member of this structure.  It is acceptable to have pDisplay point to an
;                  +existing string. In this case, you don't need to assign a value to Display. However, the string that pDisplay
;                  +points to must remain valid until another $DTN_FORMAT notification is sent or until the control is destroyed.
;                  Display  - 64 character buffer that is to receive the null terminated string that the control will display. It
;                  +is not necessary to fill the entire buffer.
; Author ........: Paul Campbell (PaulIA)
; Remarks .......: It carries the string that defines the callback field and contains a buffer to receive the string that will
;                  be displayed in the callback field. This structure is used with the $DTN_FORMAT notification message.
; ===============================================================================================================================
Global Const $tagNMDATETIMEFORMAT = $tagNMHDR & ";ptr Format;" & $tagSYSTEMTIME & ";ptr pDisplay;wchar Display[64]"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMDATETIMEFORMATQUERY
; Description ...: Contains information about the control callback field
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  Format  - Pointer to a null terminated string that defines the control callback field.  The string  comprises
;                  +one or more "X" characters.
;                  SizeX   - Must be filled with the maximum width of the text that will be displayed in the callback field
;                  SizeY   - Must be filled with the maximum height of the text that will be displayed in the callback field
; Author ........: Paul Campbell (PaulIA)
; Remarks .......: It contains a string (taken from the control's format string) that defines a callback field. The structure
;                  receives the maximum allowable size of the text that will be displayed in the callback field. This structure
;                  is used with the $DTN_FORMATQUERY notification message.
; ===============================================================================================================================
Global Const $tagNMDATETIMEFORMATQUERY = $tagNMHDR & ";ptr Format;struct;long SizeX;long SizeY;endstruct"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMDATETIMEKEYDOWN
; Description ...: Carries information used to describe and handle a $DTN_WMKEYDOWN notification message
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  VirtKey - Virtual key code that represents the key that the user pressed
;                  Format  - Pointer to a null terminated string that defines the control callback field.  The  string  comprises
;                  +one or more "X" characters.
;                  Year    - Year
;                  Month   - Month
;                  DOW     - Day of week
;                  Day     - Day
;                  Hour    - Hour
;                  Minute  - Minute
;                  Second  - Second
;                  MSecond - Milliseconds
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMDATETIMEKEYDOWN = $tagNMHDR & ";int VirtKey;ptr Format;" & $tagSYSTEMTIME

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMDATETIMESTRING
; Description ...: Contains information specific to an edit operation that has taken place in the control
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  UserString - Address of the null terminated string that the user entered
;                  Year       - Year
;                  Month      - Month
;                  DOW        - Day of week
;                  Day        - Day
;                  Hour       - Hour
;                  Minute     - Minute
;                  Second     - Second
;                  MSecond    - Milliseconds
;                  Flags      - Return field. Set this member to $GDT_VALID to indicate that the date is valid or to $GDT_NONE to
;                  +set the control to "no date" status ($DTS_SHOWNONE style only).
; Author ........: Paul Campbell (PaulIA)
; Remarks .......: This message is used with the $DTN_USERSTRING notification message.
; ===============================================================================================================================
Global Const $tagNMDATETIMESTRING = $tagNMHDR & ";ptr UserString;" & $tagSYSTEMTIME & ";dword Flags"

; ===============================================================================================================================
; *******************************************************************************************************************************
; Event Log Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #STRUCTURE# ===================================================================================================================
; Name...........: $tagEVENTLOGRECORD
; Description ...: Contains information about an event record
; Fields ........: Length              - The size of this event record, in bytes
;                  Reserved            - Reserved
;                  RecordNumber        - The number of the record
;                  TimeGenerated       - The time at which this entry was submitted
;                  TimeWritten         - The time at which this entry was received by the service to be written to the log
;                  EventID             - The event identifier
;                  EventType           - The type of event
;                  NumStrings          - The number of strings present in the log
;                  EventCategory       - The category for this event
;                  ReservedFlags       - Reserved
;                  ClosingRecordNumber - Reserved
;                  StringOffset        - The offset of the description strings within this event log record
;                  UserSidLength       - The size of the UserSid member, in bytes
;                  UserSidOffset       - The offset of the security identifier (SID) within this event log record
;                  DataLength          - The size of the event-specific data (at the position indicated by DataOffset), in bytes
;                  DataOffset          - The offset of the event-specific information within this event log record, in bytes
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagEVENTLOGRECORD = "dword Length;dword Reserved;dword RecordNumber;dword TimeGenerated;dword TimeWritten;dword EventID;" & _
		"word EventType;word NumStrings;word EventCategory;word ReservedFlags;dword ClosingRecordNumber;dword StringOffset;" & _
		"dword UserSidLength;dword UserSidOffset;dword DataLength;dword DataOffset"

; ===============================================================================================================================
; *******************************************************************************************************************************
; GDI+ Structures
; *******************************************************************************************************************************
; ===============================================================================================================================

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagGDIPBITMAPDATA
; Description ...: Bitmap Data
; Fields ........: Width    - Number of pixels in one scan line of the bitmap
;                  Height   - Number of scan lines in the bitmap
;                  Stride   - Offset, in bytes, between consecutive scan lines of the bitmap.  If the  stride  is  positive,  the
;                  +bitmap is top-down. If the stride is negative, the bitmap is bottom-up
;                  Format   - Specifies the pixel format of the bitmap
;                  Scan0    - Pointer to the first (index 0) scan line of the bitmap
;                  Reserved - Reserved for future use
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagGDIPBITMAPDATA = "uint Width;uint Height;int Stride;int Format;ptr Scan0;uint_ptr Reserved"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagGDIPENCODERPARAM
; Description ...: $tagGDIPENCODERPARAM structure
; Fields ........: GUID   - Indentifies the parameter category (GDI_EPG constants)
;                  Count  - Number of values in the array pointed to by the Value member
;                  Type   - Identifies the data type of the parameters (GDI_EPT constants)
;                  Values - Pointer to an array of values. Each value has the type specified by the Type member.
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagGDIPENCODERPARAM = "byte GUID[16];ulong Count;ulong Type;ptr Values"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagGDIPENCODERPARAMS
; Description ...: $tagGDIPENCODERPARAMS structure
; Fields ........: Count  - Number of $tagGDIPENCODERPARAM structures in the array
;                  Params - Start of $tagGDIPENCODERPARAM structures
; Author ........: Paul Campbell (PaulIA)
; Modified ......: jpm
; Remarks .......:
; ===============================================================================================================================
Global Const $tagGDIPENCODERPARAMS = "uint Count;byte Params[1]"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagGDIPRECTF
; Description ...: $tagGDIPRECTF structure
; Fields ........: X      - X coordinate of upper left hand corner of rectangle
;                  Y      - Y coordinate of upper left hand corner of rectangle
;                  Width  - Rectangle width
;                  Height - Rectangle height
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagGDIPRECTF = "float X;float Y;float Width;float Height"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagGDIPSTARTUPINPUT
; Description ...: $tagGDIPSTARTUPINPUT structure
; Fields ........: Version  - Specifies the version of Microsoft Windows GDI+
;                  Callback - Pointer to a callback function that GDI+ can call, on debug builds, for assertions and warnings
;                  NoThread - Boolean value that specifies whether to suppress the GDI+ background thread. If you set this member
;                  +to True, GdiplusStartup returns a pointer to a hook function and a pointer to an  unhook  function.  You must
;                  +call those functions appropriately to replace the background thread. If you do not want to be responsible for
;                  +calling the hook and unhook functions, set this member to False.
;                  NoCodecs - Boolean value that specifies whether you want GDI+ to suppress external image codecs.  GDI+ version
;                  +1.0 does not support external image codecs, so this parameter is ignored.
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagGDIPSTARTUPINPUT = "uint Version;ptr Callback;bool NoThread;bool NoCodecs"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagGDIPSTARTUPOUTPUT
; Description ...: $tagGDIPSTARTUPOUTPUT structure
; Fields ........: HookProc   - Receives a pointer to a hook function
;                  UnhookProc - Receives a pointer to an unhook function
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagGDIPSTARTUPOUTPUT = "ptr HookProc;ptr UnhookProc"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagGDIPIMAGECODECINFO
; Description ...: $tagGDIPIMAGECODECINFO structure
; Fields ........: CLSID      - Codec identifier (GUID structure)
;                  FormatID   - File format identifier (GUID structure)
;                  CodecName  - Pointer to a Unicode null terminated string that contains the codec name
;                  DllName    - Pointer to a Unicode null terminated string that contains the path name of the DLL in  which  the
;                  +codec resides. If the codec is not in a DLL, this pointer is 0.
;                  FormatDesc - Pointer to a Unicode null terminated string that contains the name of the file format used by the
;                  +codec.
;                  FileExt    - Pointer to a Unicode null terminated string that contains all filename extensions associated with
;                  +the codec. The extensions are separated by semicolons.
;                  MimeType   - Pointer to a null-terminated string that contains the mime type of the codec
;                  Flags      - Combination of $GDIP_ICF flags
;                  Version    - Indicates the version of the codec
;                  SigCount   - Indicates the number of signatures used by the file format associated with the codec
;                  SigSize    - Indicates the number of bytes in each signature
;                  SigPattern - Pointer to an array of bytes that contains the pattern for each signature
;                  SigMask    - Pointer to an array of bytes that contains the mask for each signature
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagGDIPIMAGECODECINFO = "byte CLSID[16];byte FormatID[16];ptr CodecName;ptr DllName;ptr FormatDesc;ptr FileExt;" & _
		"ptr MimeType;dword Flags;dword Version;dword SigCount;dword SigSize;ptr SigPattern;ptr SigMask"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagGDIPPENCODERPARAMS
; Description ...: tagGDIPPENCODERPARAMS structure
; Fields ........: Count  - Number of tagGDIPENCODERPARAM structures in the array
;                  Params - Start of tagGDIPENCODERPARAM structures
; Author ........: Paul Campbell (PaulIA)
; Modified ......: jpm
; Remarks .......:
; ===============================================================================================================================
Global Const $tagGDIPPENCODERPARAMS = "uint Count;byte Params[1]"

; ===============================================================================================================================
; *******************************************************************************************************************************
; Header Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #STRUCTURE# ===================================================================================================================
; Name...........: $tagHDITEM
; Description ...: Contains information about an item in a header control
; Fields ........: Mask    - Flags indicating which other structure members contain valid data or must be filled in
;                  XY      - Width or height of the item
;                  Text    - Address of Item string
;                  hBMP    - Handle to the item bitmap
;                  TextMax - Length of the item string
;                  Fmt     - Flags that specify the item's format
;                  Param   - Application-defined item data
;                  Image   - Zero-based index of an image within the image list
;                  Order   - Order in which the item appears within the header control, from left to right
;                  Type    - Type of filter specified by pFilter
;                  pFilter - Address of an application-defined data item
;                  State   - Item state
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagHDITEM = "uint Mask;int XY;ptr Text;handle hBMP;int TextMax;int Fmt;lparam Param;int Image;int Order;uint Type;ptr pFilter;uint State"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMHDDISPINFO
; Description ...: Contains information used in handling $HDN_GETDISPINFO notification messages
; Fields ........: hWndFrom - Window handle to the control sending a message
;                  IDFrom  - Identifier of the control sending a message
;                  Code    - Notification code
;                  Item    - Zero based index of the item in the header control
;                  Mask    - Set of bit flags specifying which members of the structure must be filled in by  the  owner  of  the
;                  +control. This value can be a combination of the following values:
;                  |$HDI_TEXT       - The Text field must be filled in
;                  |$HDI_IMAGE      - The Image field must be filled in
;                  |$HDI_LPARAM     - The lParam field must be filled in
;                  |$HDI_DI_SETITEM - A return value. Indicates that the control should store the item information  and  not  ask
;                  +for it again.
;                  Text    - Pointer to a null terminated string containing the text that will be displayed for the header item
;                  TextMax - Size of the buffer that Text points to
;                  Image   - Zero based index of an image within the image list.  The specified image will be displayed with  the
;                  +header item, but it does not take the place of the item's bitmap.  If iImage is set to $I_IMAGECALLBACK,  the
;                  +control requests image information for this item by using an $HDN_GETDISPINFO notification message.
;                  lParam  - An application-defined value to associate with the item
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMHDDISPINFO = $tagNMHDR & ";int Item;uint Mask;ptr Text;int TextMax;int Image;lparam lParam"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMHDFILTERBTNCLICK
; Description ...: Specifies or receives the attributes of a filter button click
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  Item     - Zero based index of the control to which this structure refers
;                  Left     - X coordinate of the upper left corner of the rectangle
;                  Top      - Y coordinate of the upper left corner of the rectangle
;                  Right    - X coordinate of the lower right corner of the rectangle
;                  Bottom   - Y coordinate of the lower right corner of the rectangle
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMHDFILTERBTNCLICK = $tagNMHDR & ";int Item;" & $tagRECT

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMHEADER
; Description ...: Contains information about control notification messages
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  Item     - Zero based index of the control to which this structure refers
;                  Button   - Index of the mouse button used to generate the notification message.  This member can be one of  the
;                  +following values:
;                  |0 - Left button
;                  |1 - Right button
;                  |2 - Middle button
;                  pItem   - Optional pointer to a tagHDITEM structure containing information about the item specified  by  Item.
;                  +The mask member of the tagHDITEM structure indicates which of its members are valid.
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMHEADER = $tagNMHDR & ";int Item;int Button;ptr pItem"

; ===============================================================================================================================
; *******************************************************************************************************************************
; IPAddress Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #STRUCTURE# ===================================================================================================================
; Name...........: $tagGETIPAddress
; Description ...: Contains information for all 4 fields of the IP Address control
; Fields ........: Field4   - contains bits 0 through 7
;                  Field3   - contains bits 8 through 15
;                  Field2   - contains bits 16 through 23
;                  Field1   - contains bits 24 through 31
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagGETIPAddress = "byte Field4;byte Field3;byte Field2;byte Field1"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMIPADDRESS
; Description ...: Contains information for the $IPN_FIELDCHANGED notification message
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  Field      - The zero-based number of the field that was changed.
;                  Value      - The new value of the field specified in the iField member.
;                  +While processing the $IPN_FIELDCHANGED notification, this member can be set to any value that is within the
;                  +range of the field and the control will place this new value in the field.
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMIPADDRESS = $tagNMHDR & ";int Field;int Value"

; ===============================================================================================================================
; *******************************************************************************************************************************
; ListView Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagLVFINDINFO
; Description ...: Contains information used when searching for a list-view item
; Fields ........: Flags     - Type of search to perform. This member can be set to one or more of the following values:
;                  |$LVFI_PARAM    - Searches for a match between this structure's Param member and the Param member of an item.
;                  +If $LVFI_PARAM is specified, all other flags are ignored.
;                  |$LVFI_PARTIAL  - Checks to see if the item text begins with the string pointed to by the Text  member.  This
;                  +value implies use of $LVFI_STRING.
;                  |$LVFI_STRING   - Searches based on the item text.  Unless additional values are specified, the item text  of
;                  +the matching item must exactly match the string pointed to by the Text member.
;                  |$LVFI_WRAP     - Continues the search at the beginning if no match is found
;                  |LVFI_NEARESTXY - Finds the item nearest to the position specified in the X and Y members, in  the  direction
;                  +specified by the Direction member. This flag is supported only by large icon and small icon modes.
;                  Text      - Address of a string to compare with the item text.  It is valid if $LVFI_STRING or  $LVFI_PARTIAL
;                  +is set in the Flags member.
;                  Param     - Value to compare with the Param member of an item's  $LVITEM  structure.  It  is  valid  only  if
;                  +$LVFI_PARAM is set in the flags member.
;                  X         - Initial X search position. It is valid only if $LVFI_NEARESTXY is set in the Flags member.
;                  Y         - Initial Y search position. It is valid only if $LVFI_NEARESTXY is set in the Flags member.
;                  Direction - Virtual key code that specifies the direction to search. The following codes are supported:
;                  |VK_LEFT
;                  |VK_RIGHT
;                  |VK_UP
;                  |VK_DOWN
;                  |VK_HOME
;                  |VK_END
;                  |VK_PRIOR
;                  |VK_NEXT
;                  |This member is valid only if $LVFI_NEARESTXY is set in the flags member.
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagLVFINDINFO = "struct;uint Flags;ptr Text;lparam Param;" & $tagPOINT & ";uint Direction;endstruct"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagLVHITTESTINFO
; Description ...: Contains information about a hit test
; Fields ........: X       - X position to hit test
;                  Y       - Y position to hit test
;                  Flags   - Results of a hit test. Can be one or more of the following values:
;                  |$LVHT_ABOVE           - The position is above the control's client area
;                  |$LVHT_BELOW           - The position is below the control's client area
;                  |$LVHT_NOWHERE         - The position is inside the client window, but it is not over a list item
;                  |$LVHT_ONITEMICON      - The position is over an item's icon
;                  |$LVHT_ONITEMLABEL     - The position is over an item's text
;                  |$LVHT_ONITEMSTATEICON - The position is over the state image of an item
;                  |$LVHT_TOLEFT          - The position is to the left of the client area
;                  |$LVHT_TORIGHT         - The position is to the right of the client area
;                  Item    - Receives the index of the matching item. Or if hit-testing a subitem,  this  value  represents  the
;                  +subitem's parent item.
;                  SubItem - Receives the index of the matching subitem. When hit-testing an item, this member will be zero.
;                  iGroup  - Group index of the item hit (read only). Valid only for owner data. If the point is within an item that is displayed in multiple groups then iGroup will specify the group index of the item.
; Author ........: Paul Campbell (PaulIA)
; Modified ......: jpm
; Remarks .......:
; ===============================================================================================================================
Global Const $tagLVHITTESTINFO = $tagPOINT & ";uint Flags;int Item;int SubItem;int iGroup"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagLVITEM
; Description ...: Specifies or receives the attributes of a list-view item
; Fields ........: Mask      - Set of flags that specify which members of this structure contain data to be set or which members
;                  +are being requested. This member can have one or more of the following flags set:
;				   |$LVIF_COLFMT Microsoft Windows Vista and later. The piColFmt member is valid or must be set. If this flag is used, the cColumns member is valid or must be set.
;                  |$LVIF_COLUMNS     - The Columns member is valid
;                  |$LVIF_DI_SETITEM  - The operating system should store the requested list item information
;                  |$LVIF_GROUPID     - The GroupID member is valid
;                  |$LVIF_IMAGE       - The Image member is valid
;                  |$LVIF_INDENT      - The Indent member is valid
;                  |$LVIF_NORECOMPUTE - The control will not generate LVN_GETDISPINFO to retrieve text information
;                  |$LVIF_PARAM       - The Param member is valid
;                  |$LVIF_STATE       - The State member is valid
;                  |$LVIF_TEXT        - The Text member is valid
;                  Item      - Zero based index of the item to which this structure refers
;                  SubItem   - One based index of the subitem to which this structure refers
;                  State     - Indicates the item's state, state image, and overlay image
;                  StateMask - Value specifying which bits of the state member will be retrieved or modified
;                  Text      - Pointer to a string containing the item text
;                  TextMax   - Number of bytes in the buffer pointed to by Text, including the string terminator
;                  Image     - Index of the item's icon in the control's image list
;                  Param     - Value specific to the item
;                  Indent    - Number of image widths to indent the item
;                  GroupID   - Identifier of the tile view group that receives the item
;                  Columns   - Number of tile view columns to display for this item
;                  pColumns  - Pointer to the array of column indices
;                  piColFmt  - A pointer to an array of the following flags (alone or in combination, specifying the format of each subitem in extended tile view (Windows 7 and later).
;                  iGroup    - Group index of the item. Valid only for owner data/callback (single item in multiple groups).
; Author ........: Paul Campbell (PaulIA)
; Modified ......: jpm
; Remarks .......:
; ===============================================================================================================================
Global Const $tagLVITEM = "struct;uint Mask;int Item;int SubItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;lparam Param;" & _
		"int Indent;int GroupID;uint Columns;ptr pColumns;ptr piColFmt;int iGroup;endstruct"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMLISTVIEW
; Description ...: Contains information about a list-view notification message
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  Item     - Identifies the item, or -1 if not used
;                  SubItem  - Identifies the subitem, or zero if none
;                  NewState - New item state
;                  OldState - Old item state
;                  Changed  - Set of flags that indicate the item attributes that have changed
;                  ActionX  - X position at which the event occurred
;                  ActionY  - Y position at which the event occurred
;                  Param    - Application-defined value of the item
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMLISTVIEW = $tagNMHDR & ";int Item;int SubItem;uint NewState;uint OldState;uint Changed;" & _
		"struct;long ActionX;long ActionY;endstruct;lparam Param"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMLVCUSTOMDRAW
; Description ...: Contains information specific to an NM_CUSTOMDRAW (list view) notification message sent by a list-view control
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  dwDrawStage - The current drawing stage. This is one of the following values:
;                  |Global Values:
;                  |  $CDDS_POSTERASE     - After the erasing cycle is complete.
;                  |  $CDDS_POSTPAINT     - After the painting cycle is complete.
;                  |  $CDDS_PREERASE      - Before the erasing cycle begins.
;                  |  $CDDS_PREPAINT      - Before the painting cycle begins.
;                  |Item-specific Values:
;                  |  $CDDS_ITEM          - Indicates that the dwItemSpec, uItemState, and lItemlParam members are valid.
;                  |  $CDDS_ITEMPOSTERASE - After an item has been erased.
;                  |  $CDDS_ITEMPOSTPAINT - After an item has been drawn.
;                  |  $CDDS_ITEMPREERASE  - Before an item is erased.
;                  |  $CDDS_ITEMPREPAINT  - Before an item is drawn.
;                  |  $CDDS_SUBITEM       - Flag combined with $CDDS_ITEMPREPAINT or $CDDS_ITEMPOSTPAINT if a subitem is being drawn.
;                  |  This will only be set if $CDRF_NOTIFYITEMDRAW is returned from $CDDS_PREPAINT.
;                  hdc        - A handle to the control's device context.
;                  |  Use this handle to a device context (HDC) to perform any Microsoft Windows Graphics Device Interface (GDI) functions.
;                  Left        - X coordinate of the upper left corner of the rectangle of the area being drawn. This member is initialized only by the $CDDS_ITEMPREPAINT notification
;                  Top         - Y coordinate of the upper left corner of the rectangle of the area being drawn. This member is initialized only by the $CDDS_ITEMPREPAINT notification
;                  Right       - X coordinate of the lower right corner of the rectangle of the area being drawn. This member is initialized only by the $CDDS_ITEMPREPAINT notification
;                  Bottom      - Y coordinate of the lower right corner of the rectangle of the area being drawn. This member is initialized only by the $CDDS_ITEMPREPAINT notification
;                  dwItemSpec  - The item number
;                  uItemState  - The current item state. This value is a combination of the following flags:
;                  |  $CDIS_CHECKED          - The item is checked.
;                  |  $CDIS_DEFAULT          - The item is in its default state.
;                  |  $CDIS_DISABLED         - The item is disabled.
;                  |  $CDIS_FOCUS            - The item is in focus.
;                  |  $CDIS_GRAYED           - The item is grayed.
;                  |  $CDIS_HOT              - The item is currently under the pointer ("hot").
;                  |  $CDIS_INDETERMINATE    - The item is in an indeterminate state.
;                  |  $CDIS_MARKED           - The item is marked. The meaning of this is determined by the implementation.
;                  |  $CDIS_SELECTED         - The item is selected.
;                  |  $CDIS_SHOWKEYBOARDCUES - Version 6.0 Comctl32.  The item is a keyboard cue.
;                  |  $CDIS_NEARHOT          - The item is part of a control that is currently under the mouse pointer ("hot"), but the item is not "hot" itself.
;                  |    The meaning of this is determined by the implementation.
;                  |  $CDIS_OTHERSIDEHOT     - The item is part of a splitbutton that is currently under the mouse pointer ("hot"), but the item is not "hot" itself.
;                  |    The meaning of this is determined by the implementation.
;                  |  $CDIS_DROPHILITED      - The item is currently the drop target of a drag-and-drop operation.
;                  lItemlParam - Application-defined item data.
;                  clrText     - COLORREF value representing the color that will be used to display text foreground in the list-view control.
;                  clrTextBk   - COLORREF value representing the color that will be used to display text background in the list-view control.
;                  iSubItem    - Index of the subitem that is being drawn. If the main item is being drawn, this member will be zero.
;                  dwItemType  - Version 6.0. DWORD that contains the type of the item to draw. This member can be one of the following values:
;                  |  $LVCDI_ITEM            - An item is to be drawn.
;                  |  $LVCDI_GROUP           - A group is to be drawn.
;                  clrFace     - Version 6.0. COLORREF value representing the color that will be used to display the face of an item.
;                  iIconEffect - Version 6.0.  Value of type int that specifies the effect that is applied to an icon, such as Glow, Shadow, or Pulse.
;                  iIconPhase  - Version 6.0.  Value of type int that specifies the phase of an icon.
;                  iPartId     - Version 6.0.  Value of type int that specifies the ID of the part of an item to draw.
;                  iStateId    - Version 6.0.  Value of type int that specifies the ID of the state of an item to draw.
;                  TextLeft    - X coordinate of the upper left corner of the rectangle in which the text is to be drawn
;                  TextTop     - Y coordinate of the upper left corner of the rectangle in which the text is to be drawn
;                  TextRight   - X coordinate of the lower right corner of the rectangle in which the text is to be drawn
;                  TextBottom  - Y coordinate of the lower right corner of the rectangle in which the text is to be drawn
;                  uAlign      - Version 6.0. UINT that specifies how a group should be aligned. This member can be one of the following values:
;                  |  $LVGA_HEADER_CENTER    - Center the group.
;                  |  $LVGA_HEADER_LEFT      - Align the group on the left.
;                  |  $LVGA_HEADER_RIGHT     - Align the group on the right.
; Author ........: Gary Frost
; Remarks .......: $LVxxx_ constants require ListViewConstants.au3, $CDxx_ constants require WindowsConstants.au3
; ===============================================================================================================================
Global Const $tagNMLVCUSTOMDRAW = "struct;" & $tagNMHDR & ";dword dwDrawStage;handle hdc;" & $tagRECT & _
		";dword_ptr dwItemSpec;uint uItemState;lparam lItemlParam;endstruct" & _
		";dword clrText;dword clrTextBk;int iSubItem;dword dwItemType;dword clrFace;int iIconEffect;" & _
		"int iIconPhase;int iPartId;int iStateId;struct;long TextLeft;long TextTop;long TextRight;long TextBottom;endstruct;uint uAlign"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMLVDISPINFO
; Description ...: Contains information about an $LVN_GETDISPINFO or $LVN_SETDISPINFO notification message
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  Mask      - Set of flags that specify which members of this structure contain data to be set or which members
;                  +are being requested. This member can have one or more of the following flags set:
;                  |$LVIF_COLUMNS     - The Columns member is valid
;                  |$LVIF_DI_SETITEM  - The operating system should store the requested list item information
;                  |$LVIF_GROUPID     - The GroupID member is valid
;                  |$LVIF_IMAGE       - The Image member is valid
;                  |$LVIF_INDENT      - The Indent member is valid
;                  |$LVIF_NORECOMPUTE - The control will not generate LVN_GETDISPINFO to retrieve text information
;                  |$LVIF_PARAM       - The Param member is valid
;                  |$LVIF_STATE       - The State member is valid
;                  |$LVIF_TEXT        - The Text member is valid
;                  Item      - Zero based index of the item to which this structure refers
;                  SubItem   - One based index of the subitem to which this structure refers
;                  State     - Indicates the item's state, state image, and overlay image
;                  StateMask - Value specifying which bits of the state member will be retrieved or modified
;                  Text      - Pointer to a string containing the item text
;                  TextMax   - Number of bytes in the buffer pointed to by Text, including the string terminator
;                  Image     - Index of the item's icon in the control's image list
;                  Param     - Value specific to the item
;                  Indent    - Number of image widths to indent the item
;                  GroupID   - Identifier of the tile view group that receives the item
;                  Columns   - Number of tile view columns to display for this item
;                  pColumns  - Pointer to the array of column indices
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMLVDISPINFO = $tagNMHDR & ";" & $tagLVITEM

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMLVFINDITEM
; Description ...: Contains information the owner needs to find items requested by a virtual list view control
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  Start    - Index of the item at which the search will start
;                  Flags     - Type of search to perform. This member can be set to one or more of the following values:
;                  |$LVFI_PARAM    - Searches for a match between this structure's Param member and the Param member of an item.
;                  +If $LVFI_PARAM is specified, all other flags are ignored.
;                  |$LVFI_PARTIAL  - Checks to see if the item text begins with the string pointed to by the Text  member.  This
;                  +value implies use of $LVFI_STRING.
;                  |$LVFI_STRING   - Searches based on the item text.  Unless additional values are specified, the item text  of
;                  +the matching item must exactly match the string pointed to by the Text member.
;                  |$LVFI_WRAP     - Continues the search at the beginning if no match is found
;                  |LVFI_NEARESTXY - Finds the item nearest to the position specified in the X and Y members, in  the  direction
;                  +specified by the Direction member. This flag is supported only by large icon and small icon modes.
;                  Text      - Address of a string to compare with the item text.  It is valid if $LVFI_STRING or  $LVFI_PARTIAL
;                  +is set in the Flags member.
;                  Param     - Value to compare with the Param member of an item's  $LVITEM  structure.  It  is  valid  only  if
;                  +$LVFI_PARAM is set in the flags member.
;                  X         - Initial X search position. It is valid only if $LVFI_NEARESTXY is set in the Flags member.
;                  Y         - Initial Y search position. It is valid only if $LVFI_NEARESTXY is set in the Flags member.
;                  Direction - Virtual key code that specifies the direction to search. The following codes are supported:
;                  |VK_LEFT
;                  |VK_RIGHT
;                  |VK_UP
;                  |VK_DOWN
;                  |VK_HOME
;                  |VK_END
;                  |VK_PRIOR
;                  |VK_NEXT
;                  |This member is valid only if $LVFI_NEARESTXY is set in the flags member.
; Author ........: Gary Frost (gafrost)
; Modified ......: jpm
; Remarks .......: This notification gives an application (or the notification receiver) the opportunity to customize an incremental search.
;                  For example, if the search items are numeric, the application can perform a numerical search instead of a string search.
;                  The application sets the Param member to the result of the search, or to another application defined value to fail the
;                  search and indicate to the control how to proceed
; ===============================================================================================================================
Global Const $tagNMLVFINDITEM = $tagNMHDR & ";int Start;" & $tagLVFINDINFO

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMLVGETINFOTIP
; Description ...: Contains and receives list-view item information needed to display a ToolTip for an item
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  Flags      - Either zero or $LVGIT_UNFOLDED
;                  Text       - Address of a string buffer that receives any additional text information
;                  +If Flags is zero, this member will contain the existing item text
;                  +In this case, you should append any additional text onto the end of this string
;                  TextMax     - Size, in characters, of the buffer pointed to by Text
;                  +Although you should never assume that this buffer will be of any particular size, the $INFOTIPSIZE value can
;                  +be used for design purposes
;                  Item        - Zero-based index of the item to which this structure refers.
;                  SubItem     - One-based index of the subitem to which this structure refers
;                  +If this member is zero, the structure is referring to the item and not a subitem
;                  +This member is not currently used and will always be zero
;                  lParam      - Application-defined value associated with the item
;                  +This member is not currently used and will always be zero.
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMLVGETINFOTIP = $tagNMHDR & ";dword Flags;ptr Text;int TextMax;int Item;int SubItem;lparam lParam"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMITEMACTIVATE
; Description ...: Sent by a list-view control when the user activates an item
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  Index      - Index of the list-view item. If the item index is not used for the notification,
;                  +this member will contain -1
;                  SubItem    - One-based index of the subitem. If the subitem index is not used for the notification or the
;                  +notification does not apply to a subitem, this member will contain zero.
;                  NewState   - New item state. This member is zero for notification messages that do not use it
;                  OldState   - Old item state. This member is zero for notification messages that do not use it
;                  Changed    - Set of flags that indicate the item attributes that have changed.
;                  +This member is zero for notifications that do not use it.
;                  +This member can have one or more of the following flags set:
;                  |$LVIF_COLUMNS     - The Columns member is valid
;                  |$LVIF_DI_SETITEM  - The operating system should store the requested list item information
;                  |$LVIF_GROUPID     - The GroupID member is valid
;                  |$LVIF_IMAGE       - The Image member is valid
;                  |$LVIF_INDENT      - The Indent member is valid
;                  |$LVIF_NORECOMPUTE - The control will not generate LVN_GETDISPINFO to retrieve text information
;                  |$LVIF_PARAM       - The Param member is valid
;                  |$LVIF_STATE       - The State member is valid
;                  |$LVIF_TEXT        - The Text member is valid
;                  X - Specifies the x-coordinate of the point
;                  Y - Specifies the y-coordinate of the point
;                  lParam             - Application-defined value of the item. This member is undefined for notification messages that do not use it
;                  KeyFlags           - Modifier keys that were pressed at the time of the activation.
;                  +This member contains zero or a combination of the following flags:
;                  |$LVKF_ALT         - The key is pressed.
;                  |$LVKF_CONTROL     - The key is pressed.
;                  |$LVKF_SHIFT       - The key is pressed.
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMITEMACTIVATE = $tagNMHDR & ";int Index;int SubItem;uint NewState;uint OldState;uint Changed;" & _
		$tagPOINT & ";lparam lParam;uint KeyFlags"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMLVKEYDOWN
; Description ...: Contains information used in processing the $LVN_KEYDOWN notification message
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  VKey     - Virtual key code
;                  Flags    - This member must always be zero
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMLVKEYDOWN = "align 1;" & $tagNMHDR & ";word VKey;uint Flags"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMLVSCROLL
; Description ...: Provides information about a scrolling operation
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  DX         - Specifies in pixels the horizontal position where a scrolling operation should begin or end
;                  DY         - Specifies in pixels the vertical position where a scrolling operation should begin or end
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMLVSCROLL = $tagNMHDR & ";int DX;int DY"

; ===============================================================================================================================
; *******************************************************************************************************************************
; Month Calendar Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #STRUCTURE# ===================================================================================================================
; Name...........: $tagMCHITTESTINFO
; Description ...: Carries information specific to hit-testing points for a month calendar control
; Fields ........: Size     - Size of this structure, in bytes
;                  X        - X position of the point to be hit tested
;                  Y        - Y position of the point to be hit tested
;                  Hit      - Results of the hit test operation. This value will be one of the following:
;                  |$MCHT_CALENDARBK       - The given point was in the calendar's background
;                  |$MCHT_CALENDARDATE     - The given point was on a particular date within the calendar
;                  |$MCHT_CALENDARDATENEXT - The given point was over a date from the next month
;                  |$MCHT_CALENDARDATEPREV - The given point was over a date from the previous month
;                  |$MCHT_CALENDARDAY      - The given point was over a day abbreviation
;                  |$MCHT_CALENDARWEEKNUM  - The given point was over a week number
;                  |$MCHT_NOWHERE          - The given point was not on the month calendar control
;                  |$MCHT_TITLEBK          - The given point was over the background of a month's title
;                  |$MCHT_TITLEBTNNEXT     - The given point was over the button at the top right corner
;                  |$MCHT_TITLEBTNPREV     - The given point was over the button at the top left corner
;                  |$MCHT_TITLEMONTH       - The given point was in a month's title bar, over a month name
;                  |$MCHT_TITLEYEAR        - The given point was in a month's title bar, over the year value
;                  Year     - Year
;                  Month    - Month
;                  DOW      - DOW
;                  Day      - Day
;                  Hour     - Hour
;                  Minute   - Minute
;                  Second   - Seconds
;                  MSeconds - Milliseconds
;                  $tagRECT - The RECT of the hit-tested location.
;                  iOffset  - When displaying more than one calendar, this is the offset of the calendar at the hit-tested point (zero-based).
;                  iRow     - The row number for the calendar grid that the given hit point was over.
;                  iCol     - The column number for the calendar grid that the given point was over.
; Author ........: Paul Campbell (PaulIA)
; Modified ......: jpm
; Remarks .......:
; ===============================================================================================================================
Global Const $tagMCHITTESTINFO = "uint Size;" & $tagPOINT & ";uint Hit;" & $tagSYSTEMTIME & _
		";" & $tagRECT & ";int iOffset;int iRow;int iCol"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagMCMONTHRANGE
; Description ...: Retrieves date information that represents the high and low limits of a month calendar control's display
; Fields ........: MinYear     - Year
;                  MinMonth    - Month
;                  MinDOW      - DOW
;                  MinDay      - Day
;                  MinHour     - Hour
;                  MinMinute   - Minute
;                  MinSecond   - Seconds
;                  MinMSeconds - Milliseconds
;                  MaxYear 	   - Year
;                  MaxMonth    - Month
;                  MaxDOW      - DOW
;                  MaxDay      - Day
;                  MaxHour     - Hour
;                  MaxMinute   - Minute
;                  MaxSecond   - Seconds
;                  MaxMSeconds - Milliseconds
;                  Span        - Range, in months, spanned by the two limits
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagMCMONTHRANGE = "word MinYear;word MinMonth;word MinDOW;word MinDay;word MinHour;word MinMinute;word MinSecond;" & _
		"word MinMSeconds;word MaxYear;word MaxMonth;word MaxDOW;word MaxDay;word MaxHour;word MaxMinute;word MaxSecond;" & _
		"word MaxMSeconds;short Span"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagMCRANGE
; Description ...: Contains information for setting the minimum and maximum allowable dates for a month calendar control
; Fields ........: MinYear     - Year
;                  MinMonth    - Month
;                  MinDOW      - DOW
;                  MinDay      - Day
;                  MinHour     - Hour
;                  MinMinute   - Minute
;                  MinSecond   - Seconds
;                  MinMSeconds - Milliseconds
;                  MaxYear 	   - Year
;                  MaxMonth    - Month
;                  MaxDOW      - DOW
;                  MaxDay      - Day
;                  MaxHour     - Hour
;                  MaxMinute   - Minute
;                  MaxSecond   - Seconds
;                  MaxMSeconds - Milliseconds
;                  MinSet      - A minimum limit is set for the control
;                  MaxSet      - A maximum limit is set for the control
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagMCRANGE = "word MinYear;word MinMonth;word MinDOW;word MinDay;word MinHour;word MinMinute;word MinSecond;" & _
		"word MinMSeconds;word MaxYear;word MaxMonth;word MaxDOW;word MaxDay;word MaxHour;word MaxMinute;word MaxSecond;" & _
		"word MaxMSeconds;short MinSet;short MaxSet"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagMCSELRANGE
; Description ...: Specifies a date and time, in coordinated universal time (UTC)
; Fields ........: MinYear     - Year
;                  MinMonth    - Month
;                  MinDOW      - DOW
;                  MinDay      - Day
;                  MinHour     - Hour
;                  MinMinute   - Minute
;                  MinSecond   - Seconds
;                  MinMSeconds - Milliseconds
;                  MaxYear 	   - Year
;                  MaxMonth    - Month
;                  MaxDOW      - DOW
;                  MaxDay      - Day
;                  MaxHour     - Hour
;                  MaxMinute   - Minute
;                  MaxSecond   - Seconds
;                  MaxMSeconds - Milliseconds
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagMCSELRANGE = "word MinYear;word MinMonth;word MinDOW;word MinDay;word MinHour;word MinMinute;word MinSecond;" & _
		"word MinMSeconds;word MaxYear;word MaxMonth;word MaxDOW;word MaxDay;word MaxHour;word MaxMinute;word MaxSecond;" & _
		"word MaxMSeconds"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMDAYSTATE
; Description ...: Carries information required to process the $MCN_GETDAYSTATE notification me
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  Year      - Year
;                  Month     - Month
;                  DOW       - DOW
;                  Day       - Day
;                  Hour      - Hour
;                  Minute    - Minute
;                  Second    - Seconds
;                  MSeconds  - Milliseconds
;                  DayState  - The total number of elements that must be in the array at pDayState
;                  pDayState - Address of an array of MONTHDAYSTATE (DWORD bit field that holds the state of each day in a month)
;                  +Each bit (1 through 31) represents the state of a day in a month. If a bit is on, the corresponding day will
;                  +be displayed in bold; otherwise it will be displayed with no emphasis.
;                  +The buffer at this address must be large enough to contain at least DayState elements.
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMDAYSTATE = $tagNMHDR & ";" & $tagSYSTEMTIME & ";int DayState;ptr pDayState"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMSELCHANGE
; Description ...: Carries information required to process the $MCN_SELCHANGE notification message
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  BegYear     - Year
;                  BegMonth    - Month
;                  BegDOW      - DOW
;                  BegDay      - Day
;                  BegHour     - Hour
;                  BegMinute   - Minute
;                  BegSecond   - Seconds
;                  BegMSeconds - Milliseconds
;                  EndYear     - Year
;                  EndMonth    - Month
;                  EndDOW      - DOW
;                  EndDay      - Day
;                  EndHour     - Hour
;                  EndMinute   - Minute
;                  EndSecond   - Seconds
;                  EndMSeconds - Milliseconds
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMSELCHANGE = $tagNMHDR & _
		";struct;word BegYear;word BegMonth;word BegDOW;word BegDay;word BegHour;word BegMinute;word BegSecond;word BegMSeconds;endstruct;" & _
		"struct;word EndYear;word EndMonth;word EndDOW;word EndDay;word EndHour;word EndMinute;word EndSecond;word EndMSeconds;endstruct"

; ===============================================================================================================================
; *******************************************************************************************************************************
; Tab Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMOBJECTNOTIFY
; Description ...: Contains information used with the $TBN_GETOBJECT, $TCN_GETOBJECT, $RBN_GETOBJECT, and $PSN_GETOBJECT notification messages
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  Item     - A control-specific item identifier
;                  piid     - A pointer to an interface identifier of the requested object
;                  pObject  - A pointer to an object provided by the window processing the notification message
;                  +The application processing the notification message sets this member
;                  Result   - COM success or failure flags. The application processing the notification message sets this member
;                  dwFlags  - control specific flags (hints as to where in iItem it hit)
; Author ........: Gary Frost (gafrost)
; Modified ......: jpm
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMOBJECTNOTIFY = $tagNMHDR & ";int Item;ptr piid;ptr pObject;long Result;dword dwFlags"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMTCKEYDOWN
; Description ...: Contains information used in processing the $LVN_KEYDOWN notification message
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  VKey     - Virtual key code
;                  Flags    - Bits as shown in the following table:
;                  |0-15    - Specifies the repeat count for the current message.
;                  |16-23   - Specifies the scan code. The value depends on the OEM.
;                  |24      - Specifies whether the key is an extended key, such as the right-hand ALT and CTRL keys that appear
;                  +on an enhanced 101- or 102-key keyboard. The value is 1 if it is an extended key; otherwise, it is 0.
;                  |25-28   - Reserved; do not use.
;                  |29      - Specifies the context code. The value is always 0 for a $WM_KEYDOWN message.
;                  |30      - Specifies the previous key state. The value is 1 if the key is down before the message is sent,
;                  +or it is zero if the key is up.
;                  |31      - Specifies the transition state. The value is always zero for a $WM_KEYDOWN message
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMTCKEYDOWN = "align 1;" & $tagNMHDR & ";word VKey;uint Flags"

; ===============================================================================================================================
; *******************************************************************************************************************************
; TreeView Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagTVITEM
; Description ...: Specifies or receives attributes of a tree-view item
; Fields ........: Mask          - Flags that indicate which of the other structure members contain valid data:
;                  ...
;                  Param         - A value to associate with the item
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagTVITEM = "struct;uint Mask;handle hItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;int SelectedImage;" & _
		"int Children;lparam Param;endstruct"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagTVITEMEX
; Description ...: Specifies or receives attributes of a tree-view item
; Fields ........: Mask          - Flags that indicate which of the other structure members contain valid data:
;                  |$TVIF_CHILDREN      - The Children member is valid
;                  |$TVIF_DI_SETITEM    - The will retain the supplied information and will not request it again
;                  |$TVIF_HANDLE        - The hItem member is valid
;                  |$TVIF_IMAGE         - The Image member is valid
;                  |$TVIF_INTEGRAL      - The Integral member is valid
;                  |$TVIF_PARAM         - The Param member is valid
;                  |$TVIF_SELECTEDIMAGE - The SelectedImage member is valid
;                  |$TVIF_STATE         - The State and StateMask members are valid
;                  |$TVIF_TEXT          - The Text and TextMax members are valid
;                  hItem         - Item to which this structure refers
;                  State         - Set of bit flags and image list indexes that indicate the item's state. When setting the state
;                  +of an item, the StateMask member indicates the bits of this member that are valid.  When retrieving the state
;                  +of an item, this member returns the current state for the bits indicated in  the  StateMask  member.  Bits  0
;                  +through 7 of this member contain the item state flags. Bits 8 through 11 of this member specify the one based
;                  +overlay image index.
;                  StateMask     - Bits of the state member that are valid.  If you are retrieving an item's state, set the  bits
;                  +of the stateMask member to indicate the bits to be returned in the state member. If you are setting an item's
;                  +state, set the bits of the stateMask member to indicate the bits of the state member that you want to set.
;                  Text          - Pointer to a null-terminated string that contains the item text.
;                  TextMax       - Size of the buffer pointed to by the Text member, in characters
;                  Image         - Index in the image list of the icon image to use when the item is in the nonselected state
;                  SelectedImage - Index in the image list of the icon image to use when the item is in the selected state
;                  Children      - Flag that indicates whether the item has associated child items. This member can be one of the
;                  +following values:
;                  |0 - The item has no child items
;                  |1 - The item has one or more child items
;                  Param         - A value to associate with the item
;                  Integral      - Height of the item
;                  uStateEx      - One or more (as a bitwise combination) of the following extended states.
;                                  Value Meaning:
;									TVIS_EX_DISABLED Windows Vista and later. Creates a control that is drawn in grey, that the user cannot interact with.
;									TVIS_EX_FLAT Creates a flat item—the item is virtual and is not visible in the tree; instead, its children take its place in the tree hierarchy.
;									TVIS_EX_HWND Creates a separate HWND for the item.
;                  hwnd          - Not used; must be NULL.
;                  iExpandedImage- Index of the image in the control's image list to display when the item is in the expanded state.
;                  iReserved     - Reserved member. Do not use.
; Author ........: Paul Campbell (PaulIA)
; Modified ......: jpm
; Remarks .......:
; ===============================================================================================================================
Global Const $tagTVITEMEX = "struct;" & $tagTVITEM & ";int Integral;uint uStateEx;hwnd hwnd;int iExpandedImage;int iReserved;endstruct"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMTREEVIEW
; Description ...: Contains information about a tree-view notification message
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  Action           - Notification-specific action flag
;                  OldMask          - Flags that indicate which of the other structure members contain valid data.
;                  OldhItem         - Item to which this structure refers
;                  OldState         - Set of bit flags and image list indexes that indicate the item's state
;                  OldStateMask     - Bits of the state member that are valid
;                  OldText          - Pointer to a null-terminated string that contains the item text.
;                  OldTextMax       - Size of the buffer pointed to by the Text member, in characters
;                  OldImage         - Index in the image list of the icon image to use when the item is in the nonselected state
;                  OldSelectedImage - Index in the image list of the icon image to use when the item is in the selected state
;                  OldChildren      - Flag that indicates whether the item has associated child items
;                  OldParam         - A value to associate with the item
;                  NewMask          - Flags that indicate which of the other structure members contain valid data.
;                  NewhItem         - Item to which this structure refers
;                  NewState         - Set of bit flags and image list indexes that indicate the item's state
;                  NewStateMask     - Bits of the state member that are valid
;                  NewText          - Pointer to a null-terminated string that contains the item text.
;                  NewTextMax       - Size of the buffer pointed to by the Text member, in characters
;                  NewImage         - Index in the image list of the icon image to use when the item is in the nonselected state
;                  NewSelectedImage - Index in the image list of the icon image to use when the item is in the selected state
;                  NewChildren      - Flag that indicates whether the item has associated child items
;                  NewParam         - A value to associate with the item
;                  PointX           - X position that of the mouse at the time the event occurred
;                  PointY           - Y position that of the mouse at the time the event occurred
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMTREEVIEW = $tagNMHDR & ";uint Action;" & _
		"struct;uint OldMask;handle OldhItem;uint OldState;uint OldStateMask;" & _
		"ptr OldText;int OldTextMax;int OldImage;int OldSelectedImage;int OldChildren;lparam OldParam;endstruct;" & _
		"struct;uint NewMask;handle NewhItem;uint NewState;uint NewStateMask;" & _
		"ptr NewText;int NewTextMax;int NewImage;int NewSelectedImage;int NewChildren;lparam NewParam;endstruct;" & _
		"struct;long PointX;long PointY;endstruct"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMTVCUSTOMDRAW
; Description ...: Contains information specific to an NM_CUSTOMDRAW (tree view) notification message sent by a tree-view control
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  DrawStage - Current drawing stage. This value is one of the following:
;                  |Global Values:
;                  |  $CDDS_POSTERASE - After the erasing cycle is complete
;                  |  $CDDS_POSTPAINT - After the painting cycle is complete
;                  |  $CDDS_PREERASE  - Before the erasing cycle begins
;                  |  $CDDS_PREPAINT  - Before the painting cycle begins
;                  |Item-specific Values:
;                  |  $CDDS_ITEM          - Indicates that the ItemSpec, ItemState, and ItemParam members are valid
;                  |  $CDDS_ITEMPOSTERASE - After an item has been erased
;                  |  $CDDS_ITEMPOSTPAINT - After an item has been drawn
;                  |  $CDDS_ITEMPREERASE  - Before an item is erased
;                  |  $CDDS_ITEMPREPAINT  - Before an item is drawn
;                  |  $CDDS_SUBITEM       - Flag combined with $CDDS_ITEMPREPAINT or $CDDS_ITEMPOSTPAINT if a subitem is being drawn
;                  HDC       - Handle to the control's device context
;                  Left      - X coordinate of upper left corner of bounding rectangle being drawn
;                  Top       - Y coordinate of upper left corner of bounding rectangle being drawn
;                  Right     - X coordinate of lower right corner of bounding rectangle being drawn
;                  Bottom    - Y coordinate of lower right corner of bounding rectangle being drawn
;                  ItemSpec  - Item number
;                  ItemState - Current item state. This value is a combination of the following:
;                  |  $CDIS_CHECKED          - The item is checked
;                  |  $CDIS_DEFAULT          - The item is in its default state
;                  |  $CDIS_DISABLED         - The item is disabled
;                  |  $CDIS_FOCUS            - The item is in focus
;                  |  $CDIS_GRAYED           - The item is grayed
;                  |  $CDIS_HOT              - The item is currently under the pointer
;                  |  $CDIS_INDETERMINATE    - The item is in an indeterminate state
;                  |  $CDIS_MARKED           - The item is marked
;                  |  $CDIS_SELECTED         - The item is selected
;                  |  $CDIS_SHOWKEYBOARDCUES - The item is a keyboard cue
;                  ItemParam - Application defined item data
;                  ClrText   - The color that will be used to display text foreground in the control
;                  ClrTextBk - The color that will be used to display text background in the control
;                  Level     - Zero based level of the item being drawn
; Author ........: Paul Campbell (PaulIA)
; Remarks .......: $CDxx_ constants require WindowsConstants.au3
; ===============================================================================================================================
Global Const $tagNMTVCUSTOMDRAW = "struct;" & $tagNMHDR & ";dword DrawStage;handle HDC;" & $tagRECT & _
		";dword_ptr ItemSpec;uint ItemState;lparam ItemParam;endstruct" & _
		";dword ClrText;dword ClrTextBk;int Level"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMTVDISPINFO
; Description ...: Contains and receives display information for a tree-view item
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  Mask          - Specifies which information is being set or retrieved. It can be one or more of the following values:
;                  |$TVIF_CHILDREN      - The Children member is valid
;                  |$TVIF_IMAGE         - The Image member is valid
;                  |$TVIF_SELECTEDIMAGE - The SelectedImage member is valid
;                  |$TVIF_TEXT          - The Text and TextMax members are valid
;                  hItem         - Item to which this structure refers
;                  State         - Set of bit flags and image list indexes that indicate the item's state. When setting the state
;                  +of an item, the StateMask member indicates the bits of this member that are valid.  When retrieving the state
;                  +of an item, this member returns the current state for the bits indicated in  the  StateMask  member.  Bits  0
;                  +through 7 of this member contain the item state flags. Bits 8 through 11 of this member specify the one based
;                  +overlay image index.
;                  StateMask     - Bits of the state member that are valid.  If you are retrieving an item's state, set the  bits
;                  +of the stateMask member to indicate the bits to be returned in the state member. If you are setting an item's
;                  +state, set the bits of the stateMask member to indicate the bits of the state member that you want to set.
;                  Text          - Pointer to a null-terminated string that contains the item text.
;                  TextMax       - Size of the buffer pointed to by the Text member, in characters
;                  Image         - Index in the image list of the icon image to use when the item is in the nonselected state
;                  SelectedImage - Index in the image list of the icon image to use when the item is in the selected state
;                  Children      - Flag that indicates whether the item has associated child items. This member can be one of the
;                  +following values:
;                  |0 - The item has no child items
;                  |1 - The item has one or more child items
;                  Param         - A value to associate with the item
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMTVDISPINFO = $tagNMHDR & ";" & $tagTVITEM

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMTVGETINFOTIP
; Description ...: Contains and receives tree-view item information needed to display a ToolTip for an item
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  Text      - Address of a character buffer that contains the text to be displayed
;                  TextMax   - Size of the buffer at Text, in characters. Although you should never assume that this buffer will be
;                  +of any particular size, the $INFOTIPSIZE value can be used for design purposes
;                  hItem     - Tree handle to the item for which the ToolTip is being displayed
;                  lParam    - Application-defined data associated with the item for which the ToolTip is being displayed
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMTVGETINFOTIP = $tagNMHDR & ";ptr Text;int TextMax;handle hItem;lparam lParam"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagTVHITTESTINFO
; Description ...: Contains information used to determine the location of a point relative to a tree-view control
; Fields ........: X     - X position, in client coordiantes, to be tested
;                  Y     - Y position, in client coordiantes, to be tested
;                  Flags - Results of a hit test. This member can be one or more of the following values:
;                  |$TVHT_ABOVE           - Above the client area
;                  |$TVHT_BELOW           - Below the client area
;                  |$TVHT_NOWHERE         - In the client area, but below the last item
;                  |$TVHT_ONITEM          - On the bitmap or label associated with an item
;                  |$TVHT_ONITEMBUTTON    - On the button associated with an item
;                  |$TVHT_ONITEMICON      - On the bitmap associated with an item
;                  |$TVHT_ONITEMINDENT    - In the indentation associated with an item
;                  |$TVHT_ONITEMLABEL     - On the label (string) associated with an item
;                  |$TVHT_ONITEMRIGHT     - In the area to the right of an item
;                  |DllStructGetData($TVHT_ONITEMSTATEICON - On the state icon for an item that is in a user-defined state, "")
;                  |$TVHT_TOLEFT          - To the left of the client area
;                  |$TVHT_TORIGHT         - To the right of the client area
;                  Item  - Handle to the item that occupies the position
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagTVHITTESTINFO = $tagPOINT & ";uint Flags;handle Item"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMTVKEYDOWN
; Description ...: Contains information about a keyboard event in a tree-view control
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  VKey     - Virtual key code
;                  Flags    - Always zero
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMTVKEYDOWN = "align 1;" & $tagNMHDR & ";word VKey;uint Flags"

; ===============================================================================================================================
; *******************************************************************************************************************************
; ToolTip Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMMOUSE
; Description ...: Contains information used with mouse notification messages
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  ItemSpec - A control-specific item identifier
;                  ItemData - A control-specific item data
;                  X        - Specifies the x-coordinate of the point
;                  Y        - Specifies the y-coordinate of the point
;                  HitInfo  - Carries information about where on the item or control the cursor is pointing
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMMOUSE = $tagNMHDR & ";dword_ptr ItemSpec;dword_ptr ItemData;" & $tagPOINT & ";lparam HitInfo"

; ===============================================================================================================================
; *******************************************************************************************************************************
; Security Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #STRUCTURE# ===================================================================================================================
; Name...........: $tagTOKEN_PRIVILEGES
; Description ...: Contains information about a set of privileges for an access token
; Fields ........: Count      - Specifies the number of entries
;                  LUID       - Specifies a LUID value
;                  Attributes - Specifies attributes of the LUID
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagTOKEN_PRIVILEGES = "dword Count;align 4;int64 LUID;dword Attributes"

; ===============================================================================================================================
; *******************************************************************************************************************************
; ImageList Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #STRUCTURE# ===================================================================================================================
; Name...........: $tagIMAGEINFO
; Description ...: Contains information about an image in an image list
; Fields ........: hBitmap - Handle to the bitmap that contains the images
;                  hMask   - Handle to a monochrome bitmap that contains the masks for the images
;                  Unused1 - Not used
;                  Unused2 - Not used
;                  Left    - Left side of the rectangle of the image
;                  Top     - Top of the rectangle of the image
;                  Right   - Right side of the rectangle of the image
;                  Bottom  - Bottom of the rectangle of the image
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagIMAGEINFO = "handle hBitmap;handle hMask;int Unused1;int Unused2;" & $tagRECT

; ===============================================================================================================================
; *******************************************************************************************************************************
; Menu Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #STRUCTURE# ===================================================================================================================
; Name...........: $tagMENUINFO
; Description ...: Contains information about a menu
; Fields ........: Size          - Specifies the size, in bytes, of the structure
;                  Mask          - Members to retrieve or set. This member can be one or more of the following values:
;                  |$MIM_APPLYTOSUBMENUS - Settings apply to the menu and all of its submenus
;                  |$MIM_BACKGROUND      - Retrieves or sets the hBack member
;                  |$MIM_HELPID          - Retrieves or sets the ContextHelpID member
;                  |$MIM_MAXHEIGHT       - Retrieves or sets the YMax member
;                  |$MIM_MENUDATA        - Retrieves or sets the MenuData member
;                  |$MIM_STYLE           - Retrieves or sets the Style member
;                  Style         - Style of the menu. It can be one or more of the following values:
;                  |$MNS_AUTODISMISS - Menu automatically ends when mouse is outside the menu for approximately 10 seconds
;                  |$MNS_CHECKORBMP  - The same space is reserved for the check mark and the bitmap
;                  |$MNS_DRAGDROP    - Menu items are OLE drop targets or drag sources
;                  |$MNS_MODELESS    - Menu is modeless
;                  |$MNS_NOCHECK     - No space is reserved to the left of an item for a check mark
;                  |$MNS_NOTIFYBYPOS - A WM_MENUCOMMAND message is sent instead of a WM_COMMAND message when a selection is made
;                  YMax          - Maximum height of the menu in pixels
;                  hBack         - Brush to use for the menu's background
;                  ContextHelpID - The context help identifier
;                  MenuData      - An application defined value
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagMENUINFO = "dword Size;INT Mask;dword Style;uint YMax;handle hBack;dword ContextHelpID;ulong_ptr MenuData"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagMENUITEMINFO
; Description ...: Contains information about a menu item
; Fields ........: Size         - Specifies the size, in bytes, of the structure
;                  Mask         - Members to retrieve or set. This member can be one or more of these values:
;                  |$MIIM_BITMAP     - Retrieves or sets the BmpItem member
;                  |$MIIM_CHECKMARKS - Retrieves or sets the BmpChecked and BmpUnchecked members
;                  |$MIIM_DATA       - Retrieves or sets the ItemData member
;                  |$MIIM_FTYPE      - Retrieves or sets the Type member
;                  |$MIIM_ID         - Retrieves or sets the ID member
;                  |$MIIM_STATE      - Retrieves or sets the State member
;                  |$MIIM_STRING     - Retrieves or sets the TypeData member
;                  |$MIIM_SUBMENU    - Retrieves or sets the SubMenu member
;                  |$MIIM_TYPE       - Retrieves or sets the Type and TypeData members
;                  Type         - Menu item type. This member can be one or more of the following values:
;                  |$MFT_BITMAP       - Displays the menu item using a bitmap
;                  |$MFT_MENUBARBREAK - Places the menu item on a new line or in a new column
;                  |$MFT_MENUBREAK    - Places the menu item on a new line or in a new column
;                  |$MFT_OWNERDRAW    - Assigns responsibility for drawing the menu item to the menu owner
;                  |$MFT_RADIOCHECK   - Displays selected menu items using a radio button mark
;                  |$MFT_RIGHTJUSTIFY - Right justifies the menu item and any subsequent items
;                  |$MFT_RIGHTORDER   - Specifies that menus cascade right to left
;                  |$MFT_SEPARATOR    - Specifies that the menu item is a separator
;                  State        - Menu item state. This member can be one or more of these values:
;                  |$MFS_CHECKED   - Checks the menu item
;                  |$MFS_DEFAULT   - Specifies that the menu item is the default
;                  |$MFS_DISABLED  - Disables the menu item and grays it so that it cannot be selected
;                  |$MFS_ENABLED   - Enables the menu item so that it can be selected
;                  |$MFS_GRAYED    - Disables the menu item and grays it so that it cannot be selected
;                  |$MFS_HILITE    - Highlights the menu item
;                  ID           - Application-defined 16-bit value that identifies the menu item
;                  SubMenu      - Handle to the drop down menu or submenu associated with the menu item
;                  BmpChecked   - Handle to the bitmap to display next to the item if it is selected
;                  BmpUnchecked - Handle to the bitmap to display next to the item if it is not selected
;                  ItemData     - Application-defined value associated with the menu item
;                  TypeData     - Content of the menu item
;                  CCH          - Length of the menu item text
;                  BmpItem      - Handle to the bitmap to be displayed
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagMENUITEMINFO = "uint Size;uint Mask;uint Type;uint State;uint ID;handle SubMenu;handle BmpChecked;handle BmpUnchecked;" & _
		"ulong_ptr ItemData;ptr TypeData;uint CCH;handle BmpItem"

; ===============================================================================================================================
; *******************************************************************************************************************************
; Rebar Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #STRUCTURE# ===================================================================================================================
; Name...........: $tagREBARBANDINFO
; Description ...: Contains information about an item in a ComboBoxEx control
; Fields ........: cbSize     - Size of this structure, in bytes. Your application must fill this member before sending any messages that use the address of this structure as a parameter.
;                  fMask      - Flags that indicate which members of this structure are valid or must be filled. This value can be a combination of the following:;
;                  |$RBBIM_BACKGROUND      - The hbmBack member is valid or must be set.
;                  |$RBBIM_CHILD           - The hwndChild member is valid or must be set.
;                  |$RBBIM_CHILDSIZE       - The cxMinChild, cyMinChild, cyChild, cyMaxChild, and cyIntegral members are valid or must be set.
;                  |$RBBIM_COLORS          - The clrFore and clrBack members are valid or must be set.
;                  |$RBBIM_HEADERSIZE      - Version 4.71. The cxHeader member is valid or must be set.
;                  |$RBBIM_IDEALSIZE       - Version 4.71. The cxIdeal member is valid or must be set.
;                  |$RBBIM_ID              - The wID member is valid or must be set.
;                  |$RBBIM_IMAGE           - The iImage member is valid or must be set.
;                  |$RBBIM_LPARAM          - Version 4.71. The lParam member is valid or must be set.
;                  |$RBBIM_SIZE            - The cx member is valid or must be set.
;                  |$RBBIM_STYLE           - The fStyle member is valid or must be set.
;                  |$RBBIM_TEXT            - The lpText member is valid or must be set.
;                  |$RBBIM_CHEVRONLOCATION - The rcChevronLocation member is valid or must be set.
;                  |$RBBIM_CHEVRONSTATE    - The uChevronState member is valid or must be set.
;                  fStyle     - Flags that specify the band style. This value can be a combination of the following:
;                  |$RBBS_BREAK            - The band is on a new line.
;                  |$RBBS_CHILDEDGE        - The band has an edge at the top and bottom of the child window.
;                  |$RBBS_FIXEDBMP         - The background bitmap does not move when the band is resized.
;                  |$RBBS_FIXEDSIZE        - The band can't be sized. With this style, the sizing grip is not displayed on the band.
;                  |$RBBS_GRIPPERALWAYS    - Version 4.71. The band will always have a sizing grip, even if it is the only band in the rebar.
;                  |$RBBS_HIDDEN           - The band will not be visible.
;                  |$RBBS_NOGRIPPER        - Version 4.71. The band will never have a sizing grip, even if there is more than one band in the rebar.
;                  |$RBBS_USECHEVRON       - Version 5.80. Show a chevron button if the band is smaller than cxIdeal.
;                  |$RBBS_VARIABLEHEIGHT   - Version 4.71. The band can be resized by the rebar control; cyIntegral and cyMaxChild affect how the rebar will resize the band.
;                  |$RBBS_NOVERT           - Don't show when vertical.
;                  |$RBBS_USECHEVRON       - Display drop-down button.
;                  |$RBBS_HIDETITLE        - Keep band title hidden.
;                  |$RBBS_TOPALIGN         - Keep band in top row.
;                  clrFore    - Band foreground colors.
;                  clrBack    - Band background colors.
;                  |If hbmBack specifies a background bitmap, these members are ignored.
;                  |By default, the band will use the background color of the rebar control set with the $RB_SETBKCOLOR message.
;                  |If a background color is specified here, then this background color will be used instead.
;                  lpText     - Pointer to a buffer that contains the display text for the band.
;                  |If band information is being requested from the control and $RBBIM_TEXT is specified in fMask,
;                  |this member must be initialized to the address of the buffer that will receive the text.
;                  cch        - Size of the buffer at lpText, in bytes. If information is not being requested from the control, this member is ignored.
;                  iImage     - Zero-based index of any image that should be displayed in the band. The image list is set using the $RB_SETBARINFO message.
;                  hwndChild  - Handle to the child window contained in the band, if any.
;                  cxMinChild - Minimum width of the child window, in pixels. The band can't be sized smaller than this value.
;                  cyMinChild - Minimum height of the child window, in pixels. The band can't be sized smaller than this value.
;                  cx         - Length of the band, in pixels.
;                  hbmBack    - Handle to a bitmap that is used as the background for this band.
;                  wID        - UINT value that the control uses to identify this band for custom draw notification messages.
;                  cyChild    - Version 4.71. Initial height of the band, in pixels. This member is ignored unless the $RBBS_VARIABLEHEIGHT style is specified.
;                  cyMaxChild - Version 4.71. Maximum height of the band, in pixels. This member is ignored unless the $RBBS_VARIABLEHEIGHT style is specified.
;                  cyIntegral - Version 4.71. Step value by which the band can grow or shrink, in pixels.
;                  |If the band is resized, it will be resized in steps specified by this value.
;                  |This member is ignored unless the $RBBS_VARIABLEHEIGHT style is specified.
;                  cxIdeal    - Version 4.71. Ideal width of the band, in pixels.
;                  |If the band is maximized to the ideal width (see $RB_MAXIMIZEBAND), the rebar control will attempt to make the band this width.
;                  lParam     - Version 4.71. Application-defined value.
;                  cxHeader   - Version 4.71. Size of the band's header, in pixels.
;                  |The band header is the area between the edge of the band and the edge of the child window.
;                  |This is the area where band text and images are displayed, if they are specified.
;                  |If this value is specified, it will override the normal header dimensions that the control caculates for the band.
;				   $tagRECT   - Version 6. Location of the chevron.
;                  uChevronState - Version 6. A combination of the Object State Constants.
; Author ........: Gary Frost
; Modified ......: jpm
; Remarks .......:
; ===============================================================================================================================
Global Const $tagREBARBANDINFO = "uint cbSize;uint fMask;uint fStyle;dword clrFore;dword clrBack;ptr lpText;uint cch;" & _
		"int iImage;hwnd hwndChild;uint cxMinChild;uint cyMinChild;uint cx;handle hbmBack;uint wID;uint cyChild;uint cyMaxChild;" & _
		"uint cyIntegral;uint cxIdeal;lparam lParam;uint cxHeader;" & $tagRECT & ";uint uChevronState"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMREBARAUTOBREAK
; Description ...: Contains information used with the $RBN_AUTOBREAK notification
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  uBand         - Zero-based index of the band affected by the notification. This is -1 if no band is affected.
;                  wID           - Application-defined ID of the band.
;                  lParam        - Application-defined value from the lParam member of the $tagREBARBANDINFO structure that defines the rebar band.
;                  uMsg          - ID of the message.
;                  fStyleCurrent - Style of the specified band.
;                  fAutoBreak    - indicates whether a break should occur.
; Author ........: Gary Frost
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMREBARAUTOBREAK = $tagNMHDR & ";uint uBand;uint wID;lparam lParam;uint uMsg;uint fStyleCurrent;bool fAutoBreak"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMRBAUTOSIZE
; Description ...: Contains information used in handling the $RBN_AUTOSIZE notification messages
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  fChanged      - Member that indicates if the size or layout of the rebar control has changed (nonzero if a change occurred or zero otherwise)
;                  TargetLeft   - Specifies the x-coordinate of the upper-left corner of the rectangle to which the rebar control tried to size itself
;                  TargetTop    - Specifies the y-coordinate of the upper-left corner of the rectangle to which the rebar control tried to size itself
;                  TargetRight  - Specifies the x-coordinate of the lower-right corner of the rectangle to which the rebar control tried to size itself
;                  TargetBottom - Specifies the y-coordinate of the lower-right corner of the rectangle to which the rebar control tried to size itself
;                  ActualLeft   - Specifies the x-coordinate of the upper-left corner of the rectangle to which the rebar control actually sized itself
;                  ActualTop    - Specifies the y-coordinate of the upper-left corner of the rectangle to which the rebar control actually sized itself
;                  ActualRight  - Specifies the x-coordinate of the lower-right corner of the rectangle to which the rebar control actually sized itself
;                  ActualBottom - Specifies the y-coordinate of the lower-right corner of the rectangle to which the rebar control actually sized itself
; Author ........: Gary Frost
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMRBAUTOSIZE = $tagNMHDR & ";bool fChanged;" & _
		"struct;long TargetLeft;long TargetTop;long TargetRight;long TargetBottom;endstruct;" & _
		"struct;long ActualLeft;long ActualTop;long ActualRight;long ActualBottom;endstruct"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMREBAR
; Description ...: Contains information used in handling various rebar notification messages
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  dwMask        - Set of flags that define which members of this structure contain valid information. This can be one or more of the following values:
;                  |$RBNM_ID     - The wID member contains valid information.
;                  |$RBNM_LPARAM - The lParam member contains valid information.
;                  |$RBNM_STYLE  - The fStyle member contains valid information.
;                  uBand         - Zero-based index of the band affected by the notification. This will be -1 if no band is affected.
;                  fStyle        - The style of the band. This is one or more of the $RBBS_ styles detailed in the fStyle member of the $tagREBARBANDINFO structure.
;                  |This member is only valid if dwMask contains $RBNM_STYLE.
;                  wID           - Application-defined identifier of the band. This member is only valid if dwMask contains $RBNM_ID.
;                  lParam        - Application-defined value associated with the band. This member is only valid if dwMask contains $RBNM_LPARAM
; Author ........: Gary Frost
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMREBAR = $tagNMHDR & ";dword dwMask;uint uBand;uint fStyle;uint wID;lparam lParam"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMREBARCHEVRON
; Description ...: Contains information used in handling the RBN_CHEVRONPUSHED notification message
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  uBand         - Zero-based index of the band sending the notification
;                  wID           - Application-defined identifier for the band
;                  lParam        - Application-defined value associated with the band
;                  Left          - Specifies the x-coordinate of the upper-left corner of the rectangle
;                  Top           - Specifies the y-coordinate of the upper-left corner of the rectangle
;                  Right         - Specifies the x-coordinate of the lower-right corner of the rectangle
;                  Bottom        - Specifies the y-coordinate of the lower-right corner of the rectangle
;                  lParamNM      - An application-defined value
;                  |If the $RBN_CHEVRONPUSHED notification was sent as a result of an $RB_PUSHCHEVRON message, this member contains the message's lAppValue value.
;                  |Otherwise, it is set to zero.
; Author ........: Gary Frost
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMREBARCHEVRON = $tagNMHDR & ";uint uBand;uint wID;lparam lParam;" & $tagRECT & ";lparam lParamNM"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMREBARCHILDSIZE
; Description ...: Contains information used in handling the RBN_CHILDSIZE notification message
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  uBand         - Zero-based index of the band sending the notification
;                  wID           - Application-defined identifier for the band
;                  CLeft     - Specifies the x-coordinate of the upper-left corner of the rectangle of the new size of the child window
;                  |This member can be changed during the notification to modify the child window's position and size
;                  CTop      - Specifies the y-coordinate of the upper-left corner of the rectangle of the new size of the child window
;                  |This member can be changed during the notification to modify the child window's position and size
;                  CRight    - Specifies the x-coordinate of the lower-right corner of the rectangle of the new size of the child window
;                  |This member can be changed during the notification to modify the child window's position and size
;                  CBottom   - Specifies the y-coordinate of the lower-right corner of the rectangle of the new size of the child window
;                  |This member can be changed during the notification to modify the child window's position and size
;                  BLeft     - Specifies the x-coordinate of the upper-left corner of the rectangle of the new size of the band
;                  BTop      - Specifies the y-coordinate of the upper-left corner of the rectangle of the new size of the band
;                  BRight    - Specifies the x-coordinate of the lower-right corner of the rectangle of the new size of the band
;                  BBottom   - Specifies the y-coordinate of the lower-right corner of the rectangle of the new size of the band
; Author ........: Gary Frost
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMREBARCHILDSIZE = $tagNMHDR & ";uint uBand;uint wID;" & _
		"struct;long CLeft;long CTop;long CRight;long CBottom;endstruct;" & _
		"struct;long BLeft;long BTop;long BRight;long BBottom;endstruct"

; ===============================================================================================================================
; *******************************************************************************************************************************
; ToolBar Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #STRUCTURE# ===================================================================================================================
; Name...........: $tagCOLORSCHEME
; Description ...: Contains information for the drawing of buttons in a toolbar or rebar
; Fields ........: Size         - Size of this structure, in bytes
;                  BtnHighlight - The COLORREF value that represents the highlight color of the buttons. Use $CLR_DEFAULT for the
;                  +default highlight color.
;                  BtnShadow    - The COLORREF value that represents the shadow color of the buttons.  Use $CLR_DEFAULT  for  the
;                  +default shadow color.
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagCOLORSCHEME = "dword Size;dword BtnHighlight;dword BtnShadow"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMTOOLBAR
; Description ...: Contains information used to process toolbar notification messages
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  iItem    - Command identifier of the button associated with the notification
;                  iBitmap  - Zero-based index of the button image.
;                  |If the button is a separator, that is, if fsStyle is set to $BTNS_SEP, iBitmap determines the width of the separator, in pixels
;                  idCommand - Command identifier associated with the button. This identifier is used in a WM_COMMAND message when the button is chosen
;                  fsState   - Button state flags. This member can be a combination of the values listed in Toolbar Button States
;                  fsStyle   - Button style. This member can be a combination of the button style values listed in Toolbar Control and Button Styles
;                  dwData    - Application-defined value
;                  iString   - Zero-based index of the button string, or a pointer to a string buffer that contains text for the button
;                  cchText  - Count of characters in the button text
;                  pszText  - Address of a character buffer that contains the button text
;                  Left   - Specifies the x-coordinate of the upper-left corner of the rectangle
;                  Top    - Specifies the y-coordinate of the upper-left corner of the rectangle
;                  Right  - Specifies the x-coordinate of the lower-right corner of the rectangle
;                  Bottom - Specifies the y-coordinate of the lower-right corner of the rectangle
; Author ........: Gary Frost
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNMTOOLBAR = $tagNMHDR & ";int iItem;" & _
		"struct;int iBitmap;int idCommand;byte fsState;byte fsStyle;dword_ptr dwData;int_ptr iString;endstruct" & _
		";int cchText;ptr pszText;" & $tagRECT

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNMTBHOTITEM
; Description ...: Contains information used with the $TBN_HOTITEMCHANGE notification
; Fields ........: $tagNMHDR - Contains information about a notification message
;                  idOld    - Command identifier of the previously highlighted item
;                  idNew    - Command identifier of the item about to be highlighted
;                  dwFlags  - Flags that indicate why the hot item has changed. This can be one or more of the following values:
;                  |$HICF_ACCELERATOR - The change in the hot item was caused by a shortcut key
;                  |$HICF_ARROWKEYS   - The change in the hot item was caused by an arrow key
;                  |$HICF_DUPACCEL    - Modifies $HICF_ACCELERATOR. If this flag is set, more than one item has the same shortcut key character
;                  |$HICF_ENTERING    - Modifies the other reason flags. If this flag is set, there is no previous hot item and idOld does not contain valid information
;                  |$HICF_LEAVING     - Modifies the other reason flags. If this flag is set, there is no new hot item and idNew does not contain valid information
;                  |$HICF_LMOUSE      - The change in the hot item resulted from a left-click mouse event
;                  |$HICF_MOUSE       - The change in the hot item resulted from a mouse event
;                  |$HICF_OTHER       - The change in the hot item resulted from an event that could not be determined. This will most often be due to a change in focus or the $TB_SETHOTITEM message
;                  |$HICF_RESELECT    - The change in the hot item resulted from the user entering the shortcut key for an item that was already hot
;                  |$HICF_TOGGLEDROPDOWN - Version 5.80. Causes the button to switch states
; Author ........: Gary Frost
; Remarks .......: Needs alignment for x64
; ===============================================================================================================================
Global Const $tagNMTBHOTITEM = $tagNMHDR & ";int idOld;int idNew;dword dwFlags"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagTBBUTTON
; Description ...: Contains information about a button in a toolbar
; Fields ........: Bitmap   - Zero based index of the button image. Set this member to $I_IMAGECALLBACK,  and  the  toolbar  will
;                  +send the $TBN_GETDISPINFO notification to retrieve the image index when it is  needed.  Set  this  member  to
;                  +$I_IMAGENONE to indicate that the button does not have an image. The button layout will not include any space
;                  +for a bitmap, only text.  If the button is a separator, Bitmap determines the  width  of  the  separator,  in
;                  +pixels.
;                  Command  - Command identifier associated with the button.  This identifier is used in a  $WM_COMMAND  message
;                  +when the button is chosen.
;                  State    - Button state flags
;                  Style    - Button style flags
;                  Param    - Application defined value
;                  String   - Zero based index of the button string, or a pointer to a string that contains text for the button
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagTBBUTTON = "int Bitmap;int Command;byte State;byte Style;align;dword_ptr Param;int_ptr String"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagTBBUTTONINFO
; Description ...: Contains or receives information for a specific button in a toolbar
; Fields ........: Size       - Size of this structure, in bytes
;                  Mask       - Set of flags that indicate which members contain valid information:
;                  |$TBIF_BYINDEX    - The Param sent with a $TB_GETBUTTONINFO or $TB_SETBUTTONINFO message is an index
;                  |$TBIF_COMMAND    - The Command member contains valid information or is being requested
;                  |$TBIF_IMAGE      - The Image member contains valid information or is being requested
;                  |$TBIF_IMAGELABEL - Indicates that ImageLabel should be used
;                  |$TBIF_LPARAM     - The Param member contains valid information or is being requested
;                  |$TBIF_SIZE       - The CX member contains valid information or is being requested
;                  |$TBIF_STATE      - The State member contains valid information or is being requested
;                  |$TBIF_STYLE      - The Style member contains valid information or is being requested
;                  |$TBIF_TEXT       - The Text member contains valid information or is being requested
;                  Command    - Command identifier of the button
;                  Image      - Image index of the button. Set this member to $I_IMAGECALLBACK, and the  toolbar  will  send  the
;                  +$TBN_GETDISPINFO notification to retrieve the image index when it is needed.  Set this member to $I_IMAGENONE
;                  +to indicate that the button does not have an image.
;                  State      - State flags of the button
;                  Style      - Style flags of the button
;                  CX         - Width of the button, in pixels
;                  Param      - Application defined value associated with the button
;                  Text       - Address of a character buffer that contains or receives the button text
;                  TextMax    - Size of the buffer at Text. If the button information is being set, this member is ignored
;                  ImageLabel - Provides the ability to replace the text label of an item with an image
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagTBBUTTONINFO = "uint Size;dword Mask;int Command;int Image;byte State;byte Style;word CX;dword_ptr Param;ptr Text;int TextMax"

; ===============================================================================================================================
; *******************************************************************************************************************************
; Windows Networking Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #STRUCTURE# ===================================================================================================================
; Name...........: $tagNETRESOURCE
; Description ...: tagNETRESOURCE structure
; Fields ........: Scope       - Scope of the enumeration:
;                  |$RESOURCE_CONNECTED  - Enumerate currently connected resources
;                  |$RESOURCE_GLOBALNET  - Enumerate all resources on the network
;                  |$RESOURCE_REMEMBERED - Enumerate remembered connections
;                  Type        - Set of bit flags identifying the type of resource:
;                  |$RESOURCETYPE_ANY   - All resources
;                  |$RESOURCETYPE_DISK  - Disk resources
;                  |$RESOURCETYPE_PRINT - Print resources
;                  DisplayType - Display options for the network object in a network browsing user interface:
;                  |$RESOURCEDISPLAYTYPE_DOMAIN  - The object should be displayed as a domain
;                  |$RESOURCEDISPLAYTYPE_SERVER  - The object should be displayed as a server
;                  |$RESOURCEDISPLAYTYPE_SHARE   - The object should be displayed as a share
;                  |$RESOURCEDISPLAYTYPE_GENERIC - The method used to display the object does not matter
;                  Usage       - Set of bit flags describing how the resource can be used. Note that this member can be specified
;                  +only if the Scope member is equal to $RESOURCE_GLOBALNET. This member can be one of the following values:
;                  |$RESOURCEUSAGE_CONNECTABLE - The resource is a connectable resource; the name pointed to by RemoteName can be
;                  +passed to the _WNet_AddConnection function to make a network connection.
;                  |$RESOURCEUSAGE_CONTAINER   - The resource is a container resource; the name pointed to by RemoteName  can  be
;                  +passed to the WNet_OpenEnum function to enumerate the resources in the container.
;                  LocalName   - If the Scope member is equal to $RESOURCE_CONNECTED or $RESOURCE_REMEMBERED, this  member  is  a
;                  +pointer to a null terminated character string that specifies the name of a local device.  This member is 0 if
;                  +the connection does not use a device.
;                  RemoteName  - If the entry is a network resource, this member is a pointer to a null  terminated  string  that
;                  +specifies the remote network name. If the entry is a current or persistent connection, RemoteName  points  to
;                  +the network name associated with the name pointed to by the LocalName member.
;                  Comment     - Pointer to a null-terminated string that contains a comment supplied by the network provider
;                  Provider    - Pointer to a null-terminated string that contains  the  name  of  the  provider  that  owns  the
;                  +resource. This member can be NULL if the provider name is unknown.  To retrieve the provider  name,  you  can
;                  +call the _WNet_GetProviderName function.
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagNETRESOURCE = "dword Scope;dword Type;dword DisplayType;dword Usage;ptr LocalName;ptr RemoteName;ptr Comment;ptr Provider"

; ===============================================================================================================================
; *******************************************************************************************************************************
; Odds and Ends Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; ===============================================================================================================================
; #STRUCTURE# ===================================================================================================================
; Name...........: $tagOVERLAPPED
; Description ...: Contains information used in asynchronous (or overlapped) input and output (I/O).
; Fields ........: Internal     - Reserved for operating system use.  This member, which specifies a system-dependent status,  is
;                  +valid when the GetOverlappedResult function  returns  without  setting  the  extended  error  information  to
;                  +ERROR_IO_PENDING.
;                  InternalHigh - Reserved for operating system use.  This  member,  which  specifies  the  length  of  the  data
;                  +transferred, is valid when the GetOverlappedResult function returns True.
;                  Offset       - File position at which to start the transfer. The file position is a byte offset from the start
;                  +of the file. The calling process must set this member before calling the ReadFile or WriteFile function. This
;                  +member is used only when the device is a file. Otherwise, this member must be zero.
;                  OffsetHigh   - High-order word of the file position at which to start the transfer.  This member is used  only
;                  +when the device is a file. Otherwise, this member must be zero.
;                  hEvent       - Handle to an event that will be set to the signaled state when the operation has completed. The
;                  +calling process must set this member either to zero or a valid event handle  before  calling  any  overlapped
;                  +functions.
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagOVERLAPPED = "ulong_ptr Internal;ulong_ptr InternalHigh;struct;dword Offset;dword OffsetHigh;endstruct;handle hEvent"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagOPENFILENAME
; Description ...: Contains information information that the GetOpenFileName and GetSaveFileName functions use to initialize an Open or Save As dialog box
; Fields ........: StructSize - Specifies the length, in bytes, of the structure.
;                  hwndOwner  - Handle to the window that owns the dialog box. This member can be any valid window handle, or it can be NULL if the dialog box has no owner.
;                  hInstance  - If the $OFN_ENABLETEMPLATEHANDLE flag is set in the Flags member, hInstance is a handle to a memory object containing a dialog box template.
;                  |If the $OFN_ENABLETEMPLATE flag is set, hInstance is a handle to a module that contains a dialog box template named by the lpTemplateName member.
;                  |If neither flag is set, this member is ignored.
;                  |If the $OFN_EXPLORER flag is set, the system uses the specified template to create a dialog box that is a child of the default Explorer-style dialog box.
;                  |If the $OFN_EXPLORER flag is not set, the system uses the template to create an old-style dialog box that replaces the default dialog box.
;                  lpstrFilter - Pointer to a buffer containing pairs of null-terminated filter strings. The last string in the buffer must be terminated by two NULL characters.
;                  lpstrCustomFilter - Pointer to a static buffer that contains a pair of null-terminated filter strings for preserving the filter pattern chosen by the user.
;                  |The first string is your display string that describes the custom filter, and the second string is the filter pattern selected by the user.
;                  |The first time your application creates the dialog box, you specify the first string, which can be any nonempty string.
;                  |When the user selects a file, the dialog box copies the current filter pattern to the second string.
;                  |The preserved filter pattern can be one of the patterns specified in the lpstrFilter buffer, or it can be a filter pattern typed by the user.
;                  |The system uses the strings to initialize the user-defined file filter the next time the dialog box is created.
;                  |If the nFilterIndex member is zero, the dialog box uses the custom filter.
;                  |If this member is NULL, the dialog box does not preserve user-defined filter patterns.
;                  |If this member is not NULL, the value of the nMaxCustFilter member must specify the size, in TCHARs, of the lpstrCustomFilter buffer.
;                  |For the ANSI version, this is the number of bytes; for the Unicode version, this is the number of characters.
;                  nMaxCustFilter - Specifies the size, in TCHARs, of the buffer identified by lpstrCustomFilter.
;                  |For the ANSI version, this is the number of bytes; for the Unicode version, this is the number of characters.
;                  |This buffer should be at least 40 characters long. This member is ignored if lpstrCustomFilter is NULL or points to a NULL string.
;                  nFilterIndex - Specifies the index of the currently selected filter in the File Types control.
;                  |The buffer pointed to by lpstrFilter contains pairs of strings that define the filters.
;                  |The first pair of strings has an index value of 1, the second pair 2, and so on.
;                  |An index of zero indicates the custom filter specified by lpstrCustomFilter.
;                  |You can specify an index on input to indicate the initial filter description and filter pattern for the dialog box.
;                  |When the user selects a file, nFilterIndex returns the index of the currently displayed filter.
;                  |If nFilterIndex is zero and lpstrCustomFilter is NULL, the system uses the first filter in the lpstrFilter buffer.
;                  |If all three members are zero or NULL, the system does not use any filters and does not show any files in the file list control of the dialog box.
;                  lpstrFile - Pointer to a buffer that contains a file name used to initialize the File Name edit control.
;                  |The first character of this buffer must be NULL if initialization is not necessary.
;                  |When the _WinAPI_GetOpenFileName or _WinAPI_GetSaveFileName function returns successfully, this buffer contains the drive designator, path, file name, and extension of the selected file.
;                  |If the $OFN_ALLOWMULTISELECT flag is set and the user selects multiple files, the buffer contains the current directory followed by the file names of the selected files.
;                  |For Explorer-style dialog boxes, the directory and file name strings are NULL separated, with an extra NULL character after the last file name.
;                  |For old-style dialog boxes, the strings are space separated and the function uses short file names for file names with spaces.
;                  |You can use the FindFirstFile function to convert between long and short file names.
;                  |If the user selects only one file, the lpstrFile string does not have a separator between the path and file name.
;                  |If the buffer is too small, the function returns FALSE and the _WinAPI_CommDlgExtendedError function returns $FNERR_BUFFERTOOSMALL.
;                  |In this case, the first two bytes of the lpstrFile buffer contain the required size, in bytes or characters.
;                  nMaxFile - Specifies the size, in TCHARs, of the buffer pointed to by lpstrFile.
;                  |For the ANSI version, this is the number of bytes; for the Unicode version, this is the number of characters.
;                  |The buffer must be large enough to store the path and file name string or strings, including the terminating NULL character.
;                  |The _WinAPI_GetOpenFileName and _WinAPI_GetSaveFileName functions return FALSE if the buffer is too small to contain the file information.
;                  |The buffer should be at least 256 characters long.
;                  lpstrFileTitle - Pointer to a buffer that receives the file name and extension (without path information) of the selected file. This member can be NULL.
;                  nMaxFileTitle - Specifies the size, in TCHARs, of the buffer pointed to by lpstrFileTitle.
;                  |For the ANSI version, this is the number of bytes; for the Unicode version, this is the number of characters. This member is ignored if lpstrFileTitle is NULL.
;                  lpstrInitialDir - Pointer to a NULL terminated string that can specify the initial directory.
;                  lpstrTitle - Pointer to a string to be placed in the title bar of the dialog box. If this member is NULL, the system uses the default title (that is, Save As or Open).
;                  Flags - A set of bit flags you can use to initialize the dialog box. When the dialog box returns, it sets these flags to indicate the user's input. This member can be a combination of the following flags.
;                  |  $OFN_ALLOWMULTISELECT - Specifies that the File Name list box allows multiple selections.
;                  |    If you also set the $OFN_EXPLORER flag, the dialog box uses the Explorer-style user interface; otherwise, it uses the old-style user interface.
;                  |  $OFN_CREATEPROMPT - If the user specifies a file that does not exist, this flag causes the dialog box to prompt the user for permission to create the file.
;                  |    If the user chooses to create the file, the dialog box closes and the function returns the specified name; otherwise, the dialog box remains open.
;                  |    If you use this flag with the $OFN_ALLOWMULTISELECT flag, the dialog box allows the user to specify only one nonexistent file.
;                  |  $OFN_DONTADDTORECENT - Windows 2000/XP: Prevents the system from adding a link to the selected file in the file system directory that contains the user's most recently used documents.
;                  |  $OFN_ENABLEHOOK - Enables the hook function specified in the lpfnHook member.
;                  |  $OFN_ENABLEINCLUDENOTIFY - Windows 2000/XP: Causes the dialog box to send CDN_INCLUDEITEM notification messages to your OFNHookProc hook procedure when the user opens a folder.
;                  |    The dialog box sends a notification for each item in the newly opened folder.
;                  |    These messages enable you to control which items the dialog box displays in the folder's item list.
;                  |  $OFN_ENABLESIZING - Windows 2000/XP, Windows 98/Me: Enables the Explorer-style dialog box to be resized using either the mouse or the keyboard.
;                  |    By default, the Explorer-style Open and Save As dialog boxes allow the dialog box to be resized regardless of whether this flag is set.
;                  |    This flag is necessary only if you provide a hook procedure or custom template. The old-style dialog box does not permit resizing.
;                  |  $OFN_ENABLETEMPLATE - Indicates that the lpTemplateName member is a pointer to the name of a dialog template resource in the module identified by the hInstance member.
;                  |    If the $OFN_EXPLORER flag is set, the system uses the specified template to create a dialog box that is a child of the default Explorer-style dialog box.
;                  |    If the $OFN_EXPLORER flag is not set, the system uses the template to create an old-style dialog box that replaces the default dialog box.
;                  |  $OFN_ENABLETEMPLATEHANDLE - Indicates that the hInstance member identifies a data block that contains a preloaded dialog box template.
;                  |    The system ignores lpTemplateName if this flag is specified.
;                  |    If the $OFN_EXPLORER flag is set, the system uses the specified template to create a dialog box that is a child of the default Explorer-style dialog box.
;                  |    If the $OFN_EXPLORER flag is not set, the system uses the template to create an old-style dialog box that replaces the default dialog box.
;                  |  $OFN_EXPLORER - Indicates that any customizations made to the Open or Save As dialog box use the new Explorer-style customization methods.
;                  |    By default, the Open and Save As dialog boxes use the Explorer-style user interface regardless of whether this flag is set.
;                  |    This flag is necessary only if you provide a hook procedure or custom template, or set the $OFN_ALLOWMULTISELECT flag.
;                  |    If you want the old-style user interface, omit the $OFN_EXPLORER flag and provide a replacement old-style template or hook procedure.
;                  |    If you want the old style but do not need a custom template or hook procedure, simply provide a hook procedure that always returns FALSE.
;                  |  $OFN_EXTENSIONDIFFERENT - Specifies that the user typed a file name extension that differs from the extension specified by lpstrDefExt.
;                  |    The function does not use this flag if lpstrDefExt is NULL.
;                  |  $OFN_FILEMUSTEXIST - Specifies that the user can type only names of existing files in the File Name entry field.
;                  |    If this flag is specified and the user enters an invalid name, the dialog box procedure displays a warning in a message box.
;                  |    If this flag is specified, the $OFN_PATHMUSTEXIST flag is also used. This flag can be used in an Open dialog box. It cannot be used with a Save As dialog box.
;                  |  $OFN_FORCESHOWHIDDEN - Windows 2000/XP: Forces the showing of system and hidden files, thus overriding the user setting to show or not show hidden files.
;                  |    However, a file that is marked both system and hidden is not shown.
;                  |  $OFN_HIDEREADONLY - Hides the Read Only check box.
;                  |  $OFN_LONGNAMES - For old-style dialog boxes, this flag causes the dialog box to use long file names.
;                  |    If this flag is not specified, or if the $OFN_ALLOWMULTISELECT flag is also set, old-style dialog boxes use short file names (8.3 format) for file names with spaces.
;                  |    Explorer-style dialog boxes ignore this flag and always display long file names.
;                  |  $OFN_NOCHANGEDIR - Restores the current directory to its original value if the user changed the directory while searching for files.
;                  |    Windows NT 4.0/2000/XP: This flag is ineffective for GetOpenFileName.
;                  |  $OFN_NODEREFERENCELINKS - Directs the dialog box to return the path and file name of the selected shortcut (.LNK) file.
;                  |    If this value is not specified, the dialog box returns the path and file name of the file referenced by the shortcut.
;                  |  $OFN_NOLONGNAMES - For old-style dialog boxes, this flag causes the dialog box to use short file names (8.3 format).
;                  |    Explorer-style dialog boxes ignore this flag and always display long file names.
;                  |  $OFN_NONETWORKBUTTON - Hides and disables the Network button.
;                  |  $OFN_NOREADONLYRETURN - Specifies that the returned file does not have the Read Only check box selected and is not in a write-protected directory.
;                  |  $OFN_NOTESTFILECREATE - Specifies that the file is not created before the dialog box is closed.
;                  |    This flag should be specified if the application saves the file on a create-nonmodify network share.
;                  |    When an application specifies this flag, the library does not check for write protection, a full disk, an open drive door, or network protection.
;                  |    Applications using this flag must perform file operations carefully, because a file cannot be reopened once it is closed.
;                  |  $OFN_NOVALIDATE - Specifies that the common dialog boxes allow invalid characters in the returned file name.
;                  |    Typically, the calling application uses a hook procedure that checks the file name by using the FILEOKSTRING message.
;                  |    If the text box in the edit control is empty or contains nothing but spaces, the lists of files and directories are updated.
;                  |    If the text box in the edit control contains anything else, nFileOffset and nFileExtension are set to values generated by parsing the text.
;                  |    No default extension is added to the text, nor is text copied to the buffer specified by lpstrFileTitle.
;                  |    If the value specified by nFileOffset is less than zero, the file name is invalid.
;                  |    Otherwise, the file name is valid, and nFileExtension and nFileOffset can be used as if the $OFN_NOVALIDATE flag had not been specified.
;                  |  $OFN_OVERWRITEPROMPT - Causes the Save As dialog box to generate a message box if the selected file already exists.
;                  |    The user must confirm whether to overwrite the file.
;                  |  $OFN_PATHMUSTEXIST - Specifies that the user can type only valid paths and file names.
;                  |    If this flag is used and the user types an invalid path and file name in the File Name entry field, the dialog box function displays a warning in a message box.
;                  |  $OFN_READONLY - Causes the Read Only check box to be selected initially when the dialog box is created.
;                  |    This flag indicates the state of the Read Only check box when the dialog box is closed.
;                  |  $OFN_SHAREAWARE - Specifies that if a call to the OpenFile function fails because of a network sharing violation, the error is ignored and the dialog box returns the selected file name.
;                  |    If this flag is not set, the dialog box notifies your hook procedure when a network sharing violation occurs for the file name specified by the user.
;                  |    If you set the $OFN_EXPLORER flag, the dialog box sends the CDN_SHAREVIOLATION message to the hook procedure.
;                  |    If you do not set $OFN_EXPLORER, the dialog box sends the SHAREVISTRING registered message to the hook procedure.
;                  |  $OFN_SHOWHELP - Causes the dialog box to display the Help button.
;                  |    The hwndOwner member must specify the window to receive the HELPMSGSTRING registered messages that the dialog box sends when the user clicks the Help button.
;                  |    An Explorer-style dialog box sends a CDN_HELP notification message to your hook procedure when the user clicks the Help button.
;                  |  $OFN_USESHELLITEM - Do not use.
;                  nFileOffset - Specifies the zero-based offset, in TCHARs, from the beginning of the path to the file name in the string pointed to by lpstrFile.
;                  |For the ANSI version, this is the number of bytes; for the Unicode version, this is the number of characters.
;                  nFileExtension - Specifies the zero-based offset, in TCHARs, from the beginning of the path to the file name extension in the string pointed to by lpstrFile.
;                  |For the ANSI version, this is the number of bytes; for the Unicode version, this is the number of characters.
;                  lpstrDefExt - Pointer to a buffer that contains the default extension.
;                  lCustData - Specifies application-defined data that the system passes to the hook procedure identified by the lpfnHook member.
;                  lpfnHook - Pointer to a hook procedure. This member is ignored unless the Flags member includes the $OFN_ENABLEHOOK flag.
;                  lpTemplateName - Pointer to a null-terminated string that names a dialog template resource in the module identified by the hInstance member.
;                  pvReserved - Reserved. Must be set to NULL.
;                  dwReserved - Reserved. Must be set to 0.
;                  FlagsEx - Windows 2000/XP: A set of bit flags you can use to initialize the dialog box. Currently, this member can be zero or the following flag.
;                  |  $OFN_EX_NOPLACESBAR - If this flag is set, the places bar is not displayed.
;                  |    If this flag is not set, Explorer-style dialog boxes include a places bar containing icons for commonly-used folders, such as Favorites and Desktop.
; Author ........: Gary Frost
; Remarks .......:
; ===============================================================================================================================
Global Const $tagOPENFILENAME = "dword StructSize;hwnd hwndOwner;handle hInstance;ptr lpstrFilter;ptr lpstrCustomFilter;" & _
		"dword nMaxCustFilter;dword nFilterIndex;ptr lpstrFile;dword nMaxFile;ptr lpstrFileTitle;dword nMaxFileTitle;" & _
		"ptr lpstrInitialDir;ptr lpstrTitle;dword Flags;word nFileOffset;word nFileExtension;ptr lpstrDefExt;lparam lCustData;" & _
		"ptr lpfnHook;ptr lpTemplateName;ptr pvReserved;dword dwReserved;dword FlagsEx"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagBITMAPINFO
; Description ...: This structure defines the dimensions and color information of a Windows-based device-independent bitmap (DIB).
; Fields ........: Size          - The number of bytes required by the structure, minus the size of the RGBQuad data
;                  Width         - Specifies the width of the bitmap, in pixels
;                  Height        - Specifies the height of the bitmap, in pixels
;                  Planes        - Specifies the number of planes for the target device. This must be set to 1
;                  BitCount      - Specifies the number of bits-per-pixel
;                  Compression   - Specifies the type of compression for a compressed bottom-up bitmap
;                  SizeImage     - Specifies the size, in bytes, of the image
;                  XPelsPerMeter - Specifies the horizontal resolution, in pixels-per-meter, of the target device for the bitmap
;                  YPelsPerMeter - Specifies the vertical resolution, in pixels-per-meter, of the target device for the bitmap
;                  ClrUsed       - Specifies the number of color indexes in the color table that are actually used by the bitmap
;                  ClrImportant  - Specifies the number of color indexes that are required for displaying the bitmap
;                  RGBQuad       - An array of tagRGBQUAD structures. The elements of the array that make up the color table.
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagBITMAPINFO = "struct;dword Size;long Width;long Height;word Planes;word BitCount;dword Compression;dword SizeImage;" & _
		"long XPelsPerMeter;long YPelsPerMeter;dword ClrUsed;dword ClrImportant;endstruct;dword RGBQuad"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagBLENDFUNCTION
; Description ...: $tagBLENDFUNCTION structure controls blending by specifying the blending functions for source and destination bitmaps
; Fields ........: Op     - Specifies the source blend operation:
;                  Flags  - Must be zero
;                  Alpha  - Specifies an alpha transparency value to be used on the entire source bitmap.  This value is combined
;                  +with any per-pixel alpha values in the source bitmap.  If set  to  0,  it  is  assumed  that  your  image  is
;                  +transparent. Set to 255 (opaque) when you only want to use per-pixel alpha values.
;                  Format - This member controls the way the source and destination bitmaps are interpreted:
;                  |$AC_SRC_ALPHA - This flag is set when the bitmap has an Alpha channel (that is, per-pixel alpha).  Note  that
;                  +the APIs use premultiplied alpha, which means that the red, green and blue channel values in the bitmap  must
;                  +be premultiplied with the alpha channel value.
; Author ........: Paul Campbell (PaulIA)
; Remarks .......: The source bitmap used with $tagBLENDFUNCTION must be 32 bpp
; ===============================================================================================================================
Global Const $tagBLENDFUNCTION = "byte Op;byte Flags;byte Alpha;byte Format"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagGUID
; Description ...: Represents a globally unique identifier (GUID)
; Fields ........: Data1 - Data 1 element
;                  Data2 - Data 2 element
;                  Data3 - Data 2 element
;                  Data4 - Data 2 element
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagGUID = "ulong Data1;ushort Data2;ushort Data3;byte Data4[8]"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagWINDOWPLACEMENT
; Description ...: The WINDOWPLACEMENT structure contains information about the placement of a window on the screen
; Fields ........: length      - Specifies the length, in bytes, of the structure
;                  flags       - Specifies flags that control the position of the minimized window and the method by which the window is restored. This member can be one or more of the following values
;                  |$WPF_ASYNCWINDOWPLACEMENT - Windows 2000/XP: If the calling thread and the thread that owns the window are attached to different input queues, the system posts the request to the thread that owns the window.
;                  |$WPF_RESTORETOMAXIMIZED   - Specifies that the restored window will be maximized, regardless of whether it was maximized before it was minimized.
;                  |  This setting is only valid the next time the window is restored. It does not change the default restoration behavior.
;                  |  This flag is only valid when the @SW_SHOWMINIMIZED value is specified for the showCmd member.
;                  |$WPF_SETMINPOSITION       - Specifies that the coordinates of the minimized window may be specified.
;                  |  This flag must be specified if the coordinates are set in the ptMinPosition member.
;                  showCmd - Specifies the current show state of the window. This member can be one of the following values:
;                  |@SW_HIDE            - Hides the window and activates another window.
;                  |@SW_MAXIMIZE        - Maximizes the specified window.
;                  |@SW_MINIMIZE        - Minimizes the specified window and activates the next top-level window in the z-order.
;                  |@SW_RESTORE         - Activates and displays the window. If the window is minimized or maximized, the system restores it to its original size and position.
;                  |  An application should specify this flag when restoring a minimized window.
;                  |@SW_SHOW            - Activates the window and displays it in its current size and position.
;                  |@SW_SHOWMAXIMIZED   - Activates the window and displays it as a maximized window.
;                  |@SW_SHOWMINIMIZED   - Activates the window and displays it as a minimized window.
;                  |@SW_SHOWMINNOACTIVE - Displays the window as a minimized window.
;                  |  This value is similar to @SW_SHOWMINIMIZED, except the window is not activated.
;                  |@SW_SHOWNA - Displays the window in its current size and position.
;                  |  This value is similar to @SW_SHOW, except the window is not activated.
;                  |@SW_SHOWNOACTIVATE - Displays a window in its most recent size and position.
;                  |  This value is similar to @SW_SHOWNORMAL, except the window is not actived.
;                  |@SW_SHOWNORMAL     - Activates and displays a window.
;                  |  If the window is minimized or maximized, the system restores it to its original size and position.
;                  |  An application should specify this flag when displaying the window for the first time.
;                  ptMinPosition    - Specifies the coordinates of the window's upper-left corner when the window is minimized.
;                  ptMaxPosition    - Specifies the coordinates of the window's upper-left corner when the window is maximized.
;                  rcNormalPosition - Specifies the window's coordinates when the window is in the restored position.
; Author ........: PsaltyDS
; Remarks .......:
; ===============================================================================================================================
Global Const $tagWINDOWPLACEMENT = "uint length;uint flags;uint showCmd;long ptMinPosition[2];long ptMaxPosition[2];long rcNormalPosition[4]"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagWINDOWPOS
; Description ...: The WINDOWPOS structure contains information about the size and position of a window
; Fields ........: hWnd        - Handle to the window
;                  InsertAfter - Specifies the position of the window in Z order
;                  X           - Specifies the position of the left edge of the window
;                  Y           - Specifies the position of the top edge of the window
;                  CX          - Specifies the window width, in pixels
;                  CY          - Specifies the window height, in pixels
;                  Flags       - Specifies the window position. This member can be one or more of the following values:
;                  |$SWP_DRAWFRAME      - Draws a frame around the window
;                  |$SWP_FRAMECHANGED   - Sends a WM_NCCALCSIZE message to the window, even if the window's size is not being changed
;                  |$SWP_HIDEWINDOW     - Hides the window
;                  |$SWP_NOACTIVATE     - Does not activate the window
;                  |$SWP_NOCOPYBITS     - Discards the entire contents of the client area
;                  |$SWP_NOMOVE         - Retains the current position (ignores the x and y parameters)
;                  |$SWP_ NOOWNERZORDER - Does not change the owner window's position in the Z order
;                  |$SWP_NOREDRAW       - Does not redraw changes
;                  |$SWP_NOREPOSITION   - Same as the SWP_NOOWNERZORDER flag
;                  |$SWP_NOSENDCHANGING - Prevents the window from receiving the WM_WINDOWPOSCHANGING message
;                  |$SWP_NOSIZE         - Retains the current size (ignores the cx and cy parameters)
;                  |$SWP_NOZORDER       - Retains the current Z order (ignores the InsertAfter parameter)
;                  |$SWP_SHOWWINDOW     - Displays the window
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagWINDOWPOS = "hwnd hWnd;hwnd InsertAfter;int X;int Y;int CX;int CY;uint Flags"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagSCROLLINFO
; Description ...: Contains scroll bar parameters to be set by the $SBM_SETSCROLLINFO message, or retrieved by the $SBM_GETSCROLLINFO message
; Fields ........: cbSize - Specifies the size, in bytes, of this structure. The caller must set this to DllStructGetSize($tagSCROLLINFO).
;                  fMask  - Specifies the scroll bar parameters to set or retrieve. This member can be a combination of the following values:
;                  |$SIF_ALL - Combination of $SIF_PAGE, $SIF_POS, $SIF_RANGE, and $SIF_TRACKPOS.
;                  |$SIF_DISABLENOSCROLL - This value is used only when setting a scroll bar's parameters.
;                  |  If the scroll bar's new parameters make the scroll bar unnecessary, disable the scroll bar instead of removing it.
;                  |$SIF_PAGE - The nPage member contains the page size for a proportional scroll bar.
;                  |$SIF_POS  - The nPos member contains the scroll box position, which is not updated while the user drags the scroll box.
;                  |$SIF_RANGE - The nMin and nMax members contain the minimum and maximum values for the scrolling range.
;                  |$SIF_TRACKPOS - The nTrackPos member contains the current position of the scroll box while the user is dragging it.
;                  nMin - Specifies the minimum scrolling position.
;                  nMax - Specifies the maximum scrolling position.
;                  nPage - Specifies the page size. A scroll bar uses this value to determine the appropriate size of the proportional scroll box.
;                  nPos  - Specifies the position of the scroll box.
;                  nTrackPos - Specifies the immediate position of a scroll box that the user is dragging.
;                  |An application can retrieve this value while processing the $SB_THUMBTRACK request code.
;                  |An application cannot set the immediate scroll position, the SetScrollInfo function ignores this member.
; Author ........: Gary Frost
; Remarks .......: $SIF_xxxxx and $SB_xxxxx for scrollbar require WindowsConstants.au3
; ===============================================================================================================================
Global Const $tagSCROLLINFO = "uint cbSize;uint fMask;int nMin;int nMax;uint nPage;int nPos;int nTrackPos"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagSCROLLBARINFO
; Description ...: Contains scroll bar information
; Fields ........: cbSize - Specifies the size, in bytes, of this structure. The caller must set this to DllStructGetSize($tagSCROLLBARINFO).
;                  Left   - Specifies the x-coordinate of the upper-left corner of the rectangle coordinates of the scroll bar
;                  Top    - Specifies the y-coordinate of the upper-left corner of the rectangle coordinates of the scroll bar
;                  Right  - Specifies the x-coordinate of the lower-right corner of the rectangle coordinates of the scroll bar
;                  Bottom - Specifies the y-coordinate of the lower-right corner of the rectangle coordinates of the scroll bar
;                  dxyLineButton - Height or width of the thumb.
;                  xyThumbTop    - Position of the top or left of the thumb.
;                  xyThumbBottom - Position of the bottom or right of the thumb.
;                  reserved      - Reserved.
;                  rgstate       - An array of DWORD elements. Each element indicates the state of a scroll bar component.
;                  |The following values show the scroll bar component that corresponds to each array index:
;                  |  0 The scroll bar itself.
;                  |  1 The top or right arrow button.
;                  |  2 The page up or page right region.
;                  |  3 The scroll box (thumb).
;                  |  4 The page down or page left region.
;                  |  5 The bottom or left arrow button.
;                  -
;                  |The DWORD element for each scroll bar component can include a combination of the following bit flags.
;                  |  STATE_SYSTEM_INVISIBLE   - For the scroll bar itself, indicates the specified vertical or horizontal scroll bar does not exist.
;                  |    For the page up or page down regions, indicates the thumb is positioned such that the region does not exist.
;                  |  STATE_SYSTEM_OFFSCREEN   - For the scroll bar itself, indicates the window is sized such that the specified vertical or horizontal scroll bar is not currently displayed.
;                  |  STATE_SYSTEM_PRESSED     - The arrow button or page region is pressed.
;                  |  STATE_SYSTEM_UNAVAILABLE - The component is disabled.
; Author ........: Gary Frost
; Remarks .......: $SIF_xxxxx and $SB_xxxxx for scrollbar require WindowsConstants.au3
; ===============================================================================================================================
Global Const $tagSCROLLBARINFO = "dword cbSize;" & $tagRECT & ";int dxyLineButton;int xyThumbTop;" & _
		"int xyThumbBottom;int reserved;dword rgstate[6]"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagLOGFONT
; Description ...: Defines the attributes of a font
; Fields ........: Height         - Height, in logical units, of the font's character cell or character
;                  Width          - Specifies the average width, in logical units, of characters in the font
;                  Escapement     - Specifies the angle, in tenths of degrees, between the escapement vector and the X axis
;                  Orientation    - Specifies the angle, in tenths of degrees, between each character's base line and the X axis
;                  Weight         - Specifies the weight of the font in the range 0 through 1000
;                  Italic         - Specifies an italic font if set to True
;                  Underline      - Specifies an underlined font if set to True
;                  StrikeOut      - Specifies a strikeout font if set to True
;                  CharSet        - Specifies the character set
;                  OutPrecision   - Specifies the output precision
;                  ClipPrecision  - Specifies the clipping precision
;                  Quality        - Specifies the output quality
;                  PitchAndFamily - Specifies the pitch and family of the font
;                  FaceName       - Specifies the typeface name of the font
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagLOGFONT = "long Height;long Width;long Escapement;long Orientation;long Weight;byte Italic;byte Underline;" & _
		"byte Strikeout;byte CharSet;byte OutPrecision;byte ClipPrecision;byte Quality;byte PitchAndFamily;wchar FaceName[32]"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagKBDLLHOOKSTRUCT
; Description ...: Contains information about a low-level keyboard input event
; Fields ........: vkCode               - Specifies a virtual-key code. The code must be a value in the range 1 to 254
;                  scanCode             - Specifies a hardware scan code for the key
;                  flags                - Specifies the extended-key flag, event-injected flag, context code, and transition-state flag. This member is specified as follows.
;                  +  An application can use the following values to test the keystroke flags:
;                  |$LLKHF_EXTENDED     - Test the extended-key flag
;                  |$LLKHF_INJECTED     - Test the event-injected flag
;                  |$LLKHF_ALTDOWN      - Test the context code
;                  |$LLKHF_UP           - Test the transition-state flag
;                  |  0      - Specifies whether the key is an extended key, such as a function key or a key on the numeric keypad
;                  |    The value is 1 if the key is an extended key; otherwise, it is 0
;                  |  1 to 3 - Reserved
;                  |  4      - Specifies whether the event was injected. The value is 1 if the event was injected; otherwise, it is 0
;                  |  5      - Specifies the context code. The value is 1 if the ALT key is pressed; otherwise, it is 0
;                  |  6      - Reserved
;                  |  7      - Specifies the transition state. The value is 0 if the key is pressed and 1 if it is being released
;                  time                 - Specifies the time stamp for this message, equivalent to what GetMessageTime would return for this message
;                  dwExtraInfo          - Specifies extra information associated with the message
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagKBDLLHOOKSTRUCT = "dword vkCode;dword scanCode;dword flags;dword time;ulong_ptr dwExtraInfo"

; ===============================================================================================================================
; *******************************************************************************************************************************
; Process and Thread Structures
; *******************************************************************************************************************************
; ===============================================================================================================================

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagPROCESS_INFORMATION
; Description ...: Contains information about a newly created process and its primary thread
; Fields ........: hProcess  - A handle to the newly created process
;                  hThread   - A handle to the primary thread of the newly created process
;                  ProcessID - A value that can be used to identify a process
;                  ThreadID  - A value that can be used to identify a thread
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagPROCESS_INFORMATION = "handle hProcess;handle hThread;dword ProcessID;dword ThreadID"

; #STRUCTURE# ===================================================================================================================
; Name...........: $tagSTARTUPINFO
; Description ...: Specifies the window station, desktop, standard handles, and appearance of the main window for a process at creation time
; Fields ........: Size          - The size of the structure, in bytes
;                  Reserved1     - Reserved, must be zero
;                  Desktop       - The name of the desktop, or the name of both the desktop and window station for this process
;                  Title         - For console processes, the title displayed in the title bar if a new console is created
;                  X             - If Flags specifies $STARTF_USEPOSITION, this member is the x offset of the upper  left  corner
;                  +of a window if a new window is created, in pixels.
;                  Y             - If Flags specifies $STARTF_USEPOSITION, this member is the y offset of the upper  left  corner
;                  +of a window if a new window is created, in pixels.
;                  XSize         - If Flags specifies $STARTF_USESIZE, this member is the height of the window, in pixels
;                  YSize         - If Flags specifies $STARTF_USESIZE, this member is the width of the window, in pixels
;                  XCountChars   - If Flags specifies $STARTF_USECOUNTCHARS, if a new console window  is  created  in  a  console
;                  +process, this member specifies the screen buffer width, in character columns.
;                  YCountChars   - If Flags specifies $STARTF_USECOUNTCHARS, if a new console window  is  created  in  a  console
;                  +process, this member specifies the screen buffer height, in character rows.
;                  FillAttribute - If Flags specifies $STARTF_USEFILLATTRIBUTE, this member is the initial  text  and  background
;                  +colors if a new console window is created in a console application.
;                  Flags         - Determines which members are used when the process creates a window:
;                  |$STARTF_FORCEONFEEDBACK  - The cursor is in feedback mode for two seconds after CreateProcess is  called. The
;                  +Working in Background cursor is displayed.  If during those two seconds the process makes the first GUI call,
;                  +the system gives five more seconds to the process.  If during those five seconds the process shows a  window,
;                  +the system gives five more seconds to the process to finish drawing the window. The system turns the feedback
;                  +cursor off after the first call to GetMessage, regardless of whether the process is drawing.
;                  |$STARTF_FORCEOFFFEEDBACK - Indicates that the feedback cursor is forced off while the  process  is  starting.
;                  +The Normal Select cursor is displayed.
;                  |$STARTF_RUNFULLSCREEN    - Indicates that the process should be run in  full  screen  mode,  rather  than  in
;                  +windowed mode. This flag is only valid for console applications running on an x86 computer.
;                  |$STARTF_USECOUNTCHARS    - The XCountChars and YCountChars members are valid
;                  |$STARTF_USEFILLATTRIBUTE - The FillAttribute member is valid
;                  |$STARTF_USEPOSITION      - The X and Y members are valid
;                  |$STARTF_USESHOWWINDOW    - The ShowWindow member is valid
;                  |$STARTF_USESIZE          - The XSize and YSize members are valid
;                  |$STARTF_USESTDHANDLES    - The hStdInput, hStdOutput, and hStdError members are valid
;                  ShowWindow    - If Flags specifies $STARTF_USESHOWWINDOW, this member can be any of the SW_ constants
;                  Reserved2     -  Reserved, must be zero
;                  Reserved3     -  Reserved, must be zero
;                  StdInput      - If Flags specifies $STARTF_USESTDHANDLES, this member is the standard input handle
;                  StdOutput     - If Flags specifies $STARTF_USESTDHANDLES, this member is the standard output handle
;                  StdError      - If Flags specifies $STARTF_USESTDHANDLES, this member is the standard error handle
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagSTARTUPINFO = "dword Size;ptr Reserved1;ptr Desktop;ptr Title;dword X;dword Y;dword XSize;dword YSize;dword XCountChars;" & _
		"dword YCountChars;dword FillAttribute;dword Flags;word ShowWindow;word Reserved2;ptr Reserved3;handle StdInput;" & _
		"handle StdOutput;handle StdError"

; ===============================================================================================================================
; *******************************************************************************************************************************
; Authorization Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #STRUCTURE# ===================================================================================================================
; Name...........: $tagSECURITY_ATTRIBUTES
; Description ...: Contains the security descriptor for an object and specifies whether the handle retrieved by specifying this structure is inheritable
; Fields ........: Length        - The size, in bytes, of this structure
;                  Descriptor    - A pointer to a security descriptor for the object that controls the sharing of it
;                  InheritHandle - If True, the new process inherits the handle.
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagSECURITY_ATTRIBUTES = "dword Length;ptr Descriptor;bool InheritHandle"

; ===============================================================================================================================
; *******************************************************************************************************************************
; FileFind Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #STRUCTURE# ===================================================================================================================
; Name...........: $tagWIN32_FIND_DATA
; Description ...: Contains the data found when finding a file
; Fields ........: dwFileAttributes   - The file attributes of a file.
;                  ftCreationTime     - A FILETIME structure that specifies when a file or directory was created.
;                  ftLastAccessTime   - A FILETIME structure that specifies when the file was last read from, written to, or for executable files, run.
;                  ftLastWriteTime    - A FILETIME structure that specifies when when the file was last written to, truncated, or overwritten.
;                  nFileSizeHigh      - The high-order DWORD value of the file size, in bytes.
;                  nFileSizeLow       - The low-order DWORD value of the file size, in bytes.
;                  dwReserved0        - If the dwFileAttributes member includes the $FILE_ATTRIBUTE_REPARSE_POINT attribute,
;                  +this member specifies the reparse tag.
;                  dwReserved1        - Reserved.
;                  cFileName          - The name of the file.
;                  cAlternateFileName - An alternative name for the file, the classic 8.3 (filename.ext) file name format.
; Author ........: Jpm
; Remarks .......:
; ===============================================================================================================================
Global Const $tagWIN32_FIND_DATA = "dword dwFileAttributes;dword ftCreationTime[2];dword ftLastAccessTime[2];dword ftLastWriteTime[2];dword nFileSizeHigh;dword nFileSizeLow;dword dwReserved0;dword dwReserved1;wchar cFileName[260];wchar cAlternateFileName[14]"

; ===============================================================================================================================
; *******************************************************************************************************************************
; GetTextMetrics Structures
; *******************************************************************************************************************************
; ===============================================================================================================================
; #STRUCTURE# ===================================================================================================================
; Name...........: $tagTEXTMETRIC
; Description ...: Contains basic information about a physical font. All sizes are specified in logical units, that is, they depend on the current mapping mode of the display context.
; Fields ........: tmHeight - Specifies the height (ascent + descent) of characters.
;                  tmAscent - Specifies the ascent (units above the base line) of characters.
;                  tmDescent - Specifies the descent (units below the base line) of characters.
;                  tmInternalLeading - Specifies the amount of leading (space) inside the bounds set by the tmHeight member.
;                  |  Accent marks and other diacritical characters may occur in this area. The designer may set this member to zero.
;                  tmExternalLeading - Specifies the amount of extra leading (space) that the application adds between rows.
;                  |  Since this area is outside the font, it contains no marks and is not altered by text output calls in either OPAQUE or TRANSPARENT mode.
;                  |  The designer may set this member to zero.
;                  tmAveCharWidth - Specifies the average width of characters in the font (generally defined as the width of the letter x).
;                  |  This value does not include the overhang required for bold or italic characters.
;                  tmMaxCharWidth - Specifies the width of the widest character in the font.
;                  tmWeight - Specifies the weight of the font.
;                  tmOverhang - Specifies the extra width per string that may be added to some synthesized fonts.
;                  |  When synthesizing some attributes, such as bold or italic, graphics device interface (GDI) or a device may have to add width to a string on both a per-character and per-string basis.
;                  |  For example, GDI makes a string bold by expanding the spacing of each character and overstriking by an offset value
;                  |  it italicizes a font by shearing the string. In either case, there is an overhang past the basic string.
;                  |  For bold strings, the overhang is the distance by which the overstrike is offset. For italic strings, the overhang is the amount the top of the font is sheared past the bottom of the font.
;                  |  The tmOverhang member enables the application to determine how much of the character width returned by a GetTextExtentPoint32 function call on a single character is the actual character width and how much is the per-string extra width.
;                  |  The actual width is the extent minus the overhang.
;                  tmDigitizedAspectX - Specifies the horizontal aspect of the device for which the font was designed.
;                  tmDigitizedAspectY - Specifies the vertical aspect of the device for which the font was designed.
;                  |  The ratio of the tmDigitizedAspectX and tmDigitizedAspectY members is the aspect ratio of the device for which the font was designed.
;                  tmFirstChar - Specifies the value of the first character defined in the font.
;                  tmLastChar - Specifies the value of the last character defined in the font.
;                  tmDefaultChar - Specifies the value of the character to be substituted for characters not in the font.
;                  tmBreakChar - Specifies the value of the character that will be used to define word breaks for text justification.
;                  tmItalic - Specifies an italic font if it is nonzero.
;                  tmUnderlined - Specifies an underlined font if it is nonzero.
;                  tmStruckOut - Specifies a strikeout font if it is nonzero.
;                  tmPitchAndFamily - Specifies information about the pitch, the technology, and the family of a physical font.
;					The four low-order bits of this member specify information about the pitch and the technology of the font. A constant is defined for each of the four bits.
;					$TMPF_FIXED_PITCH If this bit is set the font is a variable pitch font. If this bit is clear the font is a fixed pitch font. Note very carefully that those meanings are the opposite of what the constant name implies.
;					$TMPF_VECTOR If this bit is set the font is a vector font.
;					$TMPF_TRUETYPE If this bit is set the font is a TrueType font.
;					$TMPF_DEVICE If this bit is set the font is a device font.
;                  tmCharSet - Specifies the character set of the font. The character set can be one of the following values.
;                  |ANSI_CHARSET
;                  |BALTIC_CHARSET
;                  |CHINESEBIG5_CHARSET
;                  |DEFAULT_CHARSET
;                  |EASTEUROPE_CHARSET
;                  |GB2312_CHARSET
;                  |GREEK_CHARSET
;                  |HANGUL_CHARSET
;                  |MAC_CHARSET
;                  |OEM_CHARSET
;                  |RUSSIAN_CHARSET
;                  |SHIFTJIS_CHARSET
;                  |SYMBOL_CHARSET
;                  |TURKISH_CHARSET
;                  |VIETNAMESE_CHARSET
; Author ........: Gary Frost
; Remarks .......:
; ===============================================================================================================================
Global Const $tagTEXTMETRIC = "long tmHeight;long tmAscent;long tmDescent;long tmInternalLeading;long tmExternalLeading;" & _
		"long tmAveCharWidth;long tmMaxCharWidth;long tmWeight;long tmOverhang;long tmDigitizedAspectX;long tmDigitizedAspectY;" & _
		"wchar tmFirstChar;wchar tmLastChar;wchar tmDefaultChar;wchar tmBreakChar;byte tmItalic;byte tmUnderlined;byte tmStruckOut;" & _
		"byte tmPitchAndFamily;byte tmCharSet"

; == Leave this line at the end of the file =====================================================================================
