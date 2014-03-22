#include-once

#include "Clipboard.au3"
#include "RichEditConstants.au3"
#include "EditConstants.au3"
#include "Misc.au3"
#include "UDFGlobalID.au3"
#include "StructureConstants.au3"
#include "SendMessage.au3"
#include "WinAPI.au3"

; #INDEX# =======================================================================================================================
; Title .........: Rich Edit
; AutoIt Version : 3.3.7.20++
; Language:        English
; Description:     Programmer-friendly Rich Edit control
; Author(s): GaryFrost, grham, Prog@ndy, KIP, c.haslam
; Dll(s) ........: kernel32.dll, ole32.dll
; OLE stuff: example from http://www.powerbasic.com/support/pbforums/showpost.php?p=294112&postcount=7
; ===============================================================================================================================

; #VARIABLES# =====================================================================================
Global $Debug_RE = False
Global $_GRE_sRTFClassName, $h_GUICtrlRTF_lib, $_GRE_Version, $_GRE_TwipsPeSpaceUnit = 1440 ; inches
Global $_GRE_hUser32dll, $_GRE_CF_RTF, $_GRE_CF_RETEXTOBJ
Global $_GRC_StreamFromFileCallback = DllCallbackRegister("__GCR_StreamFromFileCallback", "dword", "long_ptr;ptr;long;ptr")
Global $_GRC_StreamFromVarCallback = DllCallbackRegister("__GCR_StreamFromVarCallback", "dword", "long_ptr;ptr;long;ptr")
Global $_GRC_StreamToFileCallback = DllCallbackRegister("__GCR_StreamToFileCallback", "dword", "long_ptr;ptr;long;ptr")
Global $_GRC_StreamToVarCallback = DllCallbackRegister("__GCR_StreamToVarCallback", "dword", "long_ptr;ptr;long;ptr")
Global $_GRC_sStreamVar
Global $gh_RELastWnd
; Functions translated from http://www.powerbasic.com/support/pbforums/showpost.php?p=294112&postcount=7
; by Prog@ndy
Global $pObj_RichComObject = DllStructCreate("ptr pIntf; dword  Refcount")
Global $pCall_RichCom, $pObj_RichCom
Global $hLib_RichCom_OLE32 = DllOpen("OLE32.DLL")
Global $__RichCom_Object_QueryInterface = DllCallbackRegister("__RichCom_Object_QueryInterface", "long", "ptr;dword;dword")
Global $__RichCom_Object_AddRef = DllCallbackRegister("__RichCom_Object_AddRef", "long", "ptr")
Global $__RichCom_Object_Release = DllCallbackRegister("__RichCom_Object_Release", "long", "ptr")
Global $__RichCom_Object_GetNewStorage = DllCallbackRegister("__RichCom_Object_GetNewStorage", "long", "ptr;ptr")
Global $__RichCom_Object_GetInPlaceContext = DllCallbackRegister("__RichCom_Object_GetInPlaceContext", "long", "ptr;dword;dword;dword")
Global $__RichCom_Object_ShowContainerUI = DllCallbackRegister("__RichCom_Object_ShowContainerUI", "long", "ptr;long")
Global $__RichCom_Object_QueryInsertObject = DllCallbackRegister("__RichCom_Object_QueryInsertObject", "long", "ptr;dword;ptr;long")
Global $__RichCom_Object_DeleteObject = DllCallbackRegister("__RichCom_Object_DeleteObject", "long", "ptr;ptr")
Global $__RichCom_Object_QueryAcceptData = DllCallbackRegister("__RichCom_Object_QueryAcceptData", "long", "ptr;ptr;dword;dword;dword;ptr")
Global $__RichCom_Object_ContextSensitiveHelp = DllCallbackRegister("__RichCom_Object_ContextSensitiveHelp", "long", "ptr;long")
Global $__RichCom_Object_GetClipboardData = DllCallbackRegister("__RichCom_Object_GetClipboardData", "long", "ptr;ptr;dword;ptr")
Global $__RichCom_Object_GetDragDropEffect = DllCallbackRegister("__RichCom_Object_GetDragDropEffect", "long", "ptr;dword;dword;dword")
Global $__RichCom_Object_GetContextMenu = DllCallbackRegister("__RichCom_Object_GetContextMenu", "long", "ptr;short;ptr;ptr;ptr")

; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__RICHEDITCONSTANT_SB_LINEDOWN = 1
Global Const $__RICHEDITCONSTANT_SB_LINEUP = 0
Global Const $__RICHEDITCONSTANT_SB_PAGEDOWN = 3
Global Const $__RICHEDITCONSTANT_SB_PAGEUP = 2

Global Const $__RICHEDITCONSTANT_WM_COPY = 0x00000301
Global Const $__RICHEDITCONSTANT_WS_VISIBLE = 0x10000000
Global Const $__RICHEDITCONSTANT_WS_CHILD = 0x40000000
Global Const $__RICHEDITCONSTANT_WS_TABSTOP = 0x00010000

Global Const $__RICHEDITCONSTANT_WM_SETFONT = 0x0030
Global Const $__RICHEDITCONSTANT_WM_CUT = 0x00000300
Global Const $__RICHEDITCONSTANT_WM_PASTE = 0x00000302
Global Const $__RICHEDITCONSTANT_WM_SETREDRAW = 0x000B

Global Const $__RICHEDITCONSTANT_COLOR_WINDOWTEXT = 8

Global Const $_GCR_S_OK = 0
Global Const $_GCR_E_NOTIMPL = 0x80004001
Global Const $_GCR_E_INVALIDARG = 0x80070057

; ===============================================================================================================================

; #OLD_FUNCTIONS# ===============================================================================================================
; Function/Name                      ; --> New Function/Name/Replacement(s)
;
;_GUICtrlRichEdit_FindTextInRange       returns as an array[2]
;_GUICtrlRichEdit_GetCharBkColor        returning an integer
;_GUICtrlRichEdit_GetCharColor          returning an integer
;_GUICtrlRichEdit_GetCtrlBkColor        _GUICtrlRichEdit_GetBkColor returning an integer
;_GUICtrlRichEdit_GetCtrlText           _GUICtrlRichEdit_GetText
;_GUICtrlRichEdit_GetCtrlTextLength     _GUICtrlRichEdit_GetTextLength
;_GUICtrlRichEdit_GetCtrlZoom           _GUICtrlRichEdit_GetZoom
;_GUICtrlRichEdit_GetFont               returns as an array[3]
;_GUICtrlRichEdit_GetFormattingRect     _GUICtrlRichEdit_GetRECT returning an array
;_GUICtrlRichEdit_GetSel                returns as an array[2]
;_GUICtrlRichEdit_GetSelAA              returns as an array[2]
;_GUICtrlRichEdit_GetScrollPos          returns as an array[2]
;_GUICtrlRichEdit_GetXYFromCharPos      returns as an array[2]
;_GUICtrlRichEdit_SetCharBkColor        "sys" -> Default
;_GUICtrlRichEdit_SetCharColor          "sys" -> Default
;_GUICtrlRichEdit_SetCtrlBkColor        _GUICtrlRichEdit_SetBkColor "sys" -> Default
;_GUICtrlRichEdit_SetCtrlLimitOnText    _GUICtrlRichEdit_SetLimitOnText
;_GUICtrlRichEdit_SetCtrlTabStops       _GUICtrlRichEdit_SetTabStops
;_GUICtrlRichEdit_SetCtrlZoom           _GUICtrlRichEdit_SetZoom
;_GUICtrlRichEdit_SetFormattingRect     _GUICtrlRichEdit_SetRECT
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_GUICtrlRichEdit_AppendText
;_GUICtrlRichEdit_AutoDetectURL
;_GUICtrlRichEdit_CanPaste
;_GUICtrlRichEdit_CanPasteSpecial
;_GUICtrlRichEdit_CanRedo
;_GUICtrlRichEdit_CanUndo
;_GUICtrlRichEdit_ChangeFontSize
;_GUICtrlRichEdit_Copy
;_GUICtrlRichEdit_Create
;_GUICtrlRichEdit_Cut
;_GUICtrlRichEdit_Deselect
;_GUICtrlRichEdit_Destroy
;_GUICtrlRichEdit_EmptyUndoBuffer
;_GUICtrlRichEdit_FindText
;_GUICtrlRichEdit_FindTextInRange
;_GUICtrlRichEdit_GetCharAttributes
;_GUICtrlRichEdit_GetCharBkColor
;_GUICtrlRichEdit_GetCharColor
;_GUICtrlRichEdit_GetCharPosFromXY
;_GUICtrlRichEdit_GetCharPosOfNextWord
;_GUICtrlRichEdit_GetCharPosOfPreviousWord
;_GUICtrlRichEdit_GetCharWordBreakInfo
;_GUICtrlRichEdit_GetBkColor
;_GUICtrlRichEdit_GetText
;_GUICtrlRichEdit_GetTextLength
;_GUICtrlRichEdit_GetZoom
;_GUICtrlRichEdit_GetFirstCharPosOnLine
;_GUICtrlRichEdit_GetFont
;_GUICtrlRichEdit_GetRECT
;_GUICtrlRichEdit_GetLineCount
;_GUICtrlRichEdit_GetLineLength
;_GUICtrlRichEdit_GetLineNumberFromCharPos
;_GUICtrlRichEdit_GetNextRedo
;_GUICtrlRichEdit_GetNextUndo
;_GUICtrlRichEdit_GetNumberOfFirstVisibleLine
;_GUICtrlRichEdit_GetParaAlignment
;_GUICtrlRichEdit_GetParaAttributes
;_GUICtrlRichEdit_GetParaBorder
;_GUICtrlRichEdit_GetParaIndents
;_GUICtrlRichEdit_GetParaNumbering
;_GUICtrlRichEdit_GetParaShading
;_GUICtrlRichEdit_GetParaSpacing
;_GUICtrlRichEdit_GetParaTabStops
;_GUICtrlRichEdit_GetPasswordChar
;_GUICtrlRichEdit_GetScrollPos
;_GUICtrlRichEdit_GetSel
;_GUICtrlRichEdit_GetSelAA
;_GUICtrlRichEdit_GetSelText
;_GUICtrlRichEdit_GetSpaceUnit
;_GUICtrlRichEdit_GetTextinLine
;_GUICtrlRichEdit_GetTextInRange
;_GUICtrlRichEdit_GetVersion
;_GUICtrlRichEdit_GetXYFromCharPos
;_GUICtrlRichEdit_GotoCharPos
;_GUICtrlRichEdit_HideSelection
;_GUICtrlRichEdit_InsertText
;_GUICtrlRichEdit_IsModified
;_GUICtrlRichEdit_IsTextSelected
;_GUICtrlRichEdit_Paste
;_GUICtrlRichEdit_PasteSpecial
;_GUICtrlRichEdit_PauseRedraw
;_GUICtrlRichEdit_Redo
;_GUICtrlRichEdit_ReplaceText
;_GUICtrlRichEdit_ResumeRedraw
;_GUICtrlRichEdit_ScrollLineOrPage
;_GUICtrlRichEdit_ScrollLines
;_GUICtrlRichEdit_ScrollToCaret
;_GUICtrlRichEdit_SetCharAttributes
;_GUICtrlRichEdit_SetCharBkColor
;_GUICtrlRichEdit_SetCharColor
;_GUICtrlRichEdit_SetBkColor
;_GUICtrlRichEdit_SetLimitOnText
;_GUICtrlRichEdit_SetTabStops
;_GUICtrlRichEdit_SetZoom
;_GUICtrlRichEdit_SetEventMask
;_GUICtrlRichEdit_SetFont
;_GUICtrlRichEdit_SetRECT
;_GUICtrlRichEdit_SetModified
;_GUICtrlRichEdit_SetParaAlignment
;_GUICtrlRichEdit_SetParaAttributes
;_GUICtrlRichEdit_SetParaBorder
;_GUICtrlRichEdit_SetParaIndents
;_GUICtrlRichEdit_SetParaNumbering
;_GUICtrlRichEdit_SetParaShading
;_GUICtrlRichEdit_SetParaSpacing
;_GUICtrlRichEdit_SetParaTabStops
;_GUICtrlRichEdit_SetPasswordChar
;_GUICtrlRichEdit_SetReadOnly
;_GUICtrlRichEdit_SetScrollPos
;_GUICtrlRichEdit_SetSel
;_GUICtrlRichEdit_SetSpaceUnit
;_GUICtrlRichEdit_SetText
;_GUICtrlRichEdit_SetUndoLimit
;_GUICtrlRichEdit_StreamFromFile
;_GUICtrlRichEdit_StreamFromVar
;_GUICtrlRichEdit_StreamToFile
;_GUICtrlRichEdit_StreamToVar
;_GUICtrlRichEdit_Undo
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;$tagEDITSTREAM
;$tagBIDIOPTIONS
;$tagCHARFORMAT
;$tagCHARFORMAT2
;$tagCHARRANGE
;$tagFINDTEXT
;$tagFINDTEXTEX
;$tagGETTEXTEX
;$tagGETTEXTLENGTHEX
;$tagPARAFORMAT
;$tagPARAFORMAT2
;$tagSETTEXTEX
;$tagTEXTRANGE
;$tagMSGFILTER
;$tagENLINK
;__GCR_ConvertRomanToNumber
;__GCR_ConvertTwipsToSpaceUnit
;__GCR_GetParaScopeChar
;__GCR_Init
;__GCR_IsNumeric
;__GCR_ParseParaNumberingStyle
;__GCR_SendGetCharFormatMessage
;__GCR_SendGetParaFormatMessage
;__GCR_SetOLECallback
;__GCR_StreamFromFileCallback
;__GCR_StreamFromVarCallback
;__GCR_StreamToFileCallback
;__GCR_StreamToVarCallback
;__RichCom_Object_AddRef
;__RichCom_Object_ContextSensitiveHelp
;__RichCom_Object_DeleteObject
;__RichCom_Object_GetClipboardData
;__RichCom_Object_GetContextMenu
;__RichCom_Object_GetDragDropEffect
;__RichCom_Object_GetInPlaceContext
;__RichCom_Object_GetNewStorage
;__RichCom_Object_QueryAcceptData
;__RichCom_Object_QueryInsertObject
;__RichCom_Object_QueryInterface
;__RichCom_Object_Release
;__RichCom_Object_ShowContainerUI
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagEDITSTREAM
; Description ...: Contains information that an application passes to a rich edit control in a EM_STREAMIN or EM_STREAMOUT message
; Fields ........: dwCookie     - Specifies an application-defined value that the rich edit control passes to the EditStreamCallback callback function specified by the pfnCallback member
;                  dwError      - Indicates the results of the stream-in (read) or stream-out (write) operation
;                  pfnCallback  - Pointer to an EditStreamCallback function
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagEDITSTREAM = "align 4;dword_ptr dwCookie;dword dwError;ptr pfnCallback"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagBIDIOPTIONS
; Description ...: Contains bidirectional information about a rich edit control
; Fields ........: cbSize    - Specifies the size, in bytes, of the structure
;                  wMask     - A set of mask bits that determine which of the wEffects flags will be set to 1 or 0 by the rich edit control. This approach eliminates the need to read the effects flags before changing them.
;                  |Obsolete bits are valid only for the bidirectional version of Rich Edit 1.0.
;                  |  $BOM_DEFPARADIR       - Default paragraph direction—implies alignment (obsolete).
;                  |  $BOM_PLAINTEXT        - Use plain text layout (obsolete).
;                  |  $BOM_NEUTRALOVERRIDE  - Override neutral layout.
;                  |  $BOM_CONTEXTREADING   - Context reading order.
;                  |  $BOM_CONTEXTALIGNMENT - Context alignment.
;                  |  $BOM_LEGACYBIDICLASS  - Treatment of plus, minus, and slash characters in right-to-left (LTR) or bidirectional text.
;                  wEffects  - A set of flags that indicate the desired or current state of the effects flags. Obsolete bits are valid only for the bidirectional version of Rich Edit 1.0.
;                  |Obsolete bits are valid only for the bidirectional version of Rich Edit 1.0.
;                  |  $BOE_RTLDIR           - Default paragraph direction—implies alignment (obsolete).
;                  |  $BOE_PLAINTEXT        - Uses plain text layout (obsolete).
;                  |  $BOE_NEUTRALOVERRIDE  - Overrides neutral layout.
;                  |  $BOE_CONTEXTREADING   - Context reading order.
;                  |  $BOE_CONTEXTALIGNMENT - Context alignment.
;                  |  $BOE_LEGACYBIDICLASS  - Causes the plus and minus characters to be treated as neutral characters with no implied direction. Also causes the slash character to be treated as a common separator.
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagBIDIOPTIONS = "uint cbSize;word wMask;word wEffects"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagCHARFORMAT
; Description ...: Contains information about character formatting in a rich edit control
; Fields ........: cbSize          - Size in bytes of the specified structure
;                  dwMask          - Members containing valid information or attributes to set. This member can be zero, one, or more than one of the following values.
;                  |  $CFM_BOLD      - The $CFE_BOLD value of the dwEffects member is valid.
;                  |  $CFM_CHARSET   - The bCharSet member is valid.
;                  |  $CFM_COLOR     - The crTextColor member and the $CFE_AUTOCOLOR value of the dwEffects member are valid.
;                  |  $CFM_FACE      - The szFaceName member is valid.
;                  |  $CFM_ITALIC    - The $CFE_ITALIC value of the dwEffects member is valid.
;                  |  $CFM_OFFSET    - The yOffset member is valid.
;                  |  $CFM_PROTECTED - The $CFE_PROTECTED value of the dwEffects member is valid.
;                  |  $CFM_SIZE      - The yHeight member is valid.
;                  |  $CFM_STRIKEOUT - The $CFE_STRIKEOUT value of the dwEffects member is valid.
;                  |  $CFM_UNDERLINE - The $CFE_UNDERLINE value of the dwEffects member is valid.
;                  dwEffects       - Character effects. This member can be a combination of the following values.
;                  |  $CFE_AUTOCOLOR - The text color is the return value of GetSysColor(COLOR_WINDOWTEXT).
;                  |  $CFE_BOLD      - Characters are bold.
;                  |  $CFE_DISABLED  - RichEdit 2.0 and later: Characters are displayed with a shadow that is offset by 3/4 point or one pixel, whichever is larger.
;                  |  $CFE_ITALIC    - Characters are italic.
;                  |  $CFE_STRIKEOUT - Characters are struck.
;                  |  $CFE_UNDERLINE - Characters are underlined.
;                  |  $CFE_PROTECTED - Characters are protected; an attempt to modify them will cause an EN_PROTECTED notification message.
;                  yHeight         - Character height, in twips (1/1440 of an inch or 1/20 of a printer's point).
;                  yOffset         - Character offset, in twips, from the baseline. If the value of this member is positive, the character is a superscript; if it is negative, the character is a subscript.
;                  crCharColor     - Text color. This member is ignored if the $CFE_AUTOCOLOR character effect is specified. To generate a COLORREF, use the RGB macro.
;                  bCharSet        - Character set value. The bCharSet member can be one of the values specified for the lfCharSet member of the LOGFONT structure. Rich Edit 3.0 may override this value if it is invalid for the target characters.
;                  bPitchAndFamily - Font family and pitch. This member is the same as the lfPitchAndFamily member of the LOGFONT structure.
;                  szFaceName      - Null-terminated character array specifying the font name.
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagCHARFORMAT = "struct;uint cbSize;dword dwMask;dword dwEffects;long yHeight;long yOffset;dword crCharColor;" & _
		"byte bCharSet;byte bPitchAndFamily;wchar szFaceName[32];endstruct"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagCHARFORMAT2
; Description ...: Contains information about character formatting in a rich edit control
; Fields ........: cbSize          - Size in bytes of the specified structure
;                  dwMask          - Members containing valid information or attributes to set. This member can be zero, one, or more than one of the following values.
;                  |  $CFM_BOLD          - The $CFE_BOLD value of the dwEffects member is valid.
;                  |  $CFM_CHARSET       - The bCharSet member is valid.
;                  |  $CFM_COLOR         - The crTextColor member and the $CFE_AUTOCOLOR value of the dwEffects member are valid.
;                  |  $CFM_FACE          - The szFaceName member is valid.
;                  |  $CFM_ITALIC        - The $CFE_ITALIC value of the dwEffects member is valid.
;                  |  $CFM_OFFSET        - The yOffset member is valid.
;                  |  $CFM_PROTECTED     - The $CFE_PROTECTED value of the dwEffects member is valid.
;                  |  $CFM_SIZE          - The yHeight member is valid.
;                  |  $CFM_STRIKEOUT     - The $CFE_STRIKEOUT value of the dwEffects member is valid.
;                  |  $CFM_UNDERLINE     - The $CFE_UNDERLINE value of the dwEffects member is valid.
;                  |Set the following values to indicate the valid structure members.
;                  |  $CFM_ANIMATION     - The bAnimation member is valid.
;                  |  $CFM_BACKCOLOR     - The crBackColor member is valid.
;                  |  $CFM_CHARSET       - The bCharSet member is valid.
;                  |  $CFM_COLOR         - The crTextColor member is valid unless the CFE_AUTOCOLOR flag is set in the dwEffects member.
;                  |  $CFM_FACE          - The szFaceName member is valid.
;                  |  $CFM_KERNING       - The wKerning member is valid.
;                  |  $CFM_LCID          - The lcid member is valid.
;                  |  $CFM_OFFSET        - The yOffset member is valid.
;                  |  $CFM_REVAUTHOR     - The bRevAuthor member is valid.
;                  |  $CFM_SIZE          - The yHeight member is valid.
;                  |  $CFM_SPACING       - The sSpacing member is valid.
;                  |  $CFM_STYLE         - The sStyle member is valid.
;                  |  $CFM_UNDERLINETYPE - The bUnderlineType member is valid.
;                  |  $CFM_WEIGHT        - The wWeight member is valid.
;                  dwEffects       - A set of bit flags that specify character effects. Some of the flags are included only for compatibility with Microsoft Text Object Model (TOM) interfaces; the rich edit control stores the value but does not use it to display text.
;                  |This member can be a combination of the following values.
;                  |  $CFE_ALLCAPS       - Characters are all capital letters. The value does not affect the way the control displays the text. This value applies only to versions earlier than Rich Edit 3.0.
;                  |  $CFE_AUTOBACKCOLOR - The background color is the return value of GetSysColor(COLOR_WINDOW). If this flag is set, crBackColor member is ignored.
;                  |  $CFE_AUTOCOLOR     - The text color is the return value of GetSysColor(COLOR_WINDOWTEXT). If this flag is set, the crTextColor member is ignored.
;                  |  $CFE_BOLD          - Characters are bold.
;                  |  $CFE_DISABLED      - Characters are displayed with a shadow that is offset by 3/4 point or one pixel, whichever is larger.
;                  |  $CFE_EMBOSS        - Characters are embossed. The value does not affect how the control displays the text.
;                  |  $CFE_HIDDEN        - For Rich Edit 3.0 and later, characters are not displayed.
;                  |  $CFE_IMPRINT       - Characters are displayed as imprinted characters. The value does not affect how the control displays the text.
;                  |  $CFE_ITALIC        - Characters are italic.
;                  |  $CFE_LINK          - A rich edit control can send EN_LINK notification messages when it receives mouse messages while the mouse pointer is over text with the CFE_LINK effect.
;                  |  $CFE_OUTLINE       - Characters are displayed as outlined characters. The value does not affect how the control displays the text.
;                  |  $CFE_PROTECTED     - Characters are protected; an attempt to modify them will cause an EN_PROTECTED notification message.
;                  |  $CFE_REVISED       - Characters are marked as revised.
;                  |  $CFE_SHADOW        - Characters are displayed as shadowed characters. The value does not affect how the control displays the text.
;                  |  $CFE_SMALLCAPS     - Characters are in small capital letters. The value does not affect how the control displays the text.
;                  |  $CFE_STRIKEOUT     - Characters are struck out.
;                  |  $CFE_SUBSCRIPT     - Characters are subscript. The CFE_SUPERSCRIPT and CFE_SUBSCRIPT values are mutually exclusive. For both values, the control automatically calculates an offset and a smaller font size. Alternatively, you can use the yHeight and yOffset members to explicitly specify font size and offset for subscript and superscript characters.
;                  |  $CFE_SUPERSCRIPT   - Characters are superscript.
;                  |  $CFE_UNDERLINE     - Characters are underlined.
;                  yHeight         - Character height, in twips (1/1440 of an inch or 1/20 of a printer's point).
;                  yOffset         - Character offset, in twips, from the baseline. If the value of this member is positive, the character is a superscript; if it is negative, the character is a subscript.
;                  crCharColor     - Text color. This member is ignored if the $CFE_AUTOCOLOR character effect is specified. To generate a COLORREF, use the RGB macro.
;                  bCharSet        - Character set value. The bCharSet member can be one of the values specified for the lfCharSet member of the LOGFONT structure. Rich Edit 3.0 may override this value if it is invalid for the target characters.
;                  bPitchAndFamily - Font family and pitch. This member is the same as the lfPitchAndFamily member of the LOGFONT structure.
;                  szFaceName      - Null-terminated character array specifying the font name.
;                  wWeight         - Font weight. This member is the same as the lfWeight member of the LOGFONT structure. To use this member, set the CFM_WEIGHT flag in the dwMask member.
;                  sSpacing        - Horizontal space between letters, in twips. This value has no effect on the text displayed by a rich edit control; it is included for compatibility with Microsoft WindowsText Object Model (TOM) interfaces. To use this member, set the CFM_SPACING flag in the dwMask member.
;                  crBackColor     - Background color. To use this member, set the CFM_BACKCOLOR flag in the dwMask member. This member is ignored if the CFE_AUTOBACKCOLOR character effect is specified. To generate a , use the macro.
;                  lcid            - A 32-bit locale identifier that contains a language identifier in the lower word and a sorting identifier and reserved value in the upper word. This member has no effect on the text displayed by a rich edit control, but spelling and grammar checkers can use it to deal with language-dependent problems. You can use the macro to create an LCID value. To use this member, set the CFM_LCID flag in the dwMask member.
;                  dwReserved      - Reserved; the value must be zero.
;                  sStyle          - Character style handle. This value has no effect on the text displayed by a rich edit control; it is included for compatibility with WindowsTOM interfaces. To use this member, set the CFM_STYLE flag in the dwMask member. For more information see the Text Object Model documentation.
;                  wKerning        - Value of the font size, above which to kern the character (yHeight). This value has no effect on the text displayed by a rich edit control; it is included for compatibility with TOM interfaces. To use this member, set the CFM_KERNING flag in the dwMask member.
;                  bUnderlineType  - Specifies the underline type. To use this member, set the CFM_UNDERLINETYPE flag in the dwMask member. This member can be one of the following values.
;                  |  $CFU_CF1UNDERLINE    - The structure maps CHARFORMAT's bit underline to CHARFORMAT2, (that is, it performs a CHARFORMAT type of underline on this text).
;                  |  $CFU_UNDERLINE       - Solid underlined text.
;                  |  $CFU_UNDERLINEDOTTED - Dotted underlined text. For versions earlier than Rich Edit 3.0, text is displayed with a solid underline.
;                  |  $CFU_UNDERLINEDOUBLE - Double-underlined text. The rich edit control displays the text with a solid underline.
;                  |  $CFU_UNDERLINENONE   - No underline. This is the default.
;                  |  $CFU_UNDERLINEWORD   - Underline words only. The rich edit control displays the text with a solid underline.
;                  bAnimation      - Text animation type. This value has no effect on the text displayed by a rich edit control; it is included for compatibility with TOM interfaces. To use this member, set the CFM_ANIMATION flag in the dwMask member.
;                  bRevAuthor      - An index that identifies the author making a revision. The rich edit control uses different text colors for each different author index. To use this member, set the CFM_REVAUTHOR flag in the dwMask member.
;                  bReserved1      - Reserved; the value must be zero.
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagCHARFORMAT2 = $tagCHARFORMAT & ";word wWeight;short sSpacing;dword crBackColor;dword lcid;dword dwReserved;" & _
		"short sStyle;word wKerning;byte bUnderlineType;byte bAnimation;byte bRevAuthor;byte bReserved1"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagCHARRANGE
; Description ...: Specifies a range of characters in a rich edit control
; Fields ........: cpMin     - Character position index immediately preceding the first character in the range.
;                  cpMax     - Character position immediately following the last character in the range.
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagCHARRANGE = "struct;long cpMin;long cpMax;endstruct"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagFINDTEXT
; Description ...: Contains information about a search operation in a rich edit control
; Fields ........: cpMin     - Character position index immediately preceding the first character in the range.
;                  cpMax     - Character position immediately following the last character in the range.
;                  lpstrText - Pointer to the null-terminated string used in the find operation.
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagFINDTEXT = $tagCHARRANGE & ";ptr lpstrText"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagFINDTEXTEX
; Description ...: Contains information about text to search for in a rich edit control.
; Fields ........: cpMin       - Character position index immediately preceding the first character in the range to search.
;                  cpMax       - Character position immediately following the last character in the range to search.
;                  lpstrText   - Pointer to the null-terminated string used in the find operation.
;                  cpMinRang - Character position index immediately preceding the first character in the range found.
;                  cpMaxRange - Character position immediately following the last character in the range found.
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagFINDTEXTEX = $tagCHARRANGE & ";ptr lpstrText;long cpMinRang;long cpMaxRange"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagGETTEXTEX
; Description ...: Contains information about an operation to get text from a rich edit control.
; Fields ........: cb            - Count of bytes in the fetched string.
;                  flags         - Value specifying a text operation. This member can be one of the following values.
;                  |  $GT_DEFAULT   - No CR translation.
;                  |  $GT_SELECTION - Retrieves the text for the current selection.
;                  |  $GT_USECRLF   - Indicates that when copying text, each CR should be translated into a CRLF.
;                  codepage      - Code page used in the translation. It is $CP_ACP for ANSI Code Page and 1200 for Unicode.
;                  lpDefaultChar - Points to the character used if a wide character cannot be represented in the specified code page.
;                  |It is used only if the code page is not 1200 (Unicode). If this member is NULL, a system default value is used.
;                  lpUsedDefChar - Points to a flag that indicates whether a default character was used.
;                  |It is used only if the code page is not 1200 (Unicode).
;                  |The flag is set to TRUE if one or more wide characters in the source string cannot be represented in the specified code page.
;                  |Otherwise, the flag is set to FALSE. This member may be NULL.
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagGETTEXTEX = "align 4;dword cb;dword flags;uint codepage;ptr lpDefaultChar;ptr lpbUsedDefChar"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagGETTEXTLENGTHEX
; Description ...: Contains information about how the text length of a rich edit control should be calculated.
; Fields ........: flags    - Value specifying the method to be used in determining the text length. This member can be one or more of the following values (some values are mutually exclusive).
;                  |  $GTL_DEFAULT  - Returns the number of characters. This is the default.
;                  |  $GTL_USECRLF  - Computes the answer by using CR/LFs at the end of paragraphs.
;                  |  $GTL_PRECISE  - Computes a precise answer. This approach could necessitate a conversion and thereby take longer. This flag cannot be used with the GTL_CLOSE flag. E_INVALIDARG will be returned if both are used.
;                  |  $GTL_CLOSE    - Computes an approximate (close) answer. It is obtained quickly and can be used to set the buffer size. This flag cannot be used with the GTL_PRECISE flag. E_INVALIDARG will be returned if both are used.
;                  |  $GTL_NUMCHARS - Returns the number of characters. This flag cannot be used with the GTL_NUMBYTES flag. E_INVALIDARG will be returned if both are used.
;                  |  $GTL_NUMBYTES - Returns the number of bytes. This flag cannot be used with the GTL_NUMCHARS flag. E_INVALIDARG will be returned if both are used.
;                  codepage - Code page used in the translation. It is $CP_ACP for ANSI Code Page and 1200 for Unicode.
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagGETTEXTLENGTHEX = "dword flags;uint codepage"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagPARAFORMAT
; Description ...: Contains information about paragraph formatting attributes in a rich edit control.
; Fields ........: cbSize        - Structure size, in bytes.
;                  dwMask        - Members containing valid information or attributes to set. This parameter can be none or a combination of the following values. If both PFM_STARTINDENT and PFM_OFFSETINDENT are specified, PFM_STARTINDENT takes precedence.
;                  |  $PFM_ALIGNMENT    - The wAlignment member is valid.
;                  |  $PFM_NUMBERING    - The wNumbering member is valid.
;                  |  $PFM_OFFSET       - The dxOffset member is valid.
;                  |  $PFM_OFFSETINDENT - The dxStartIndent member is valid and specifies a relative value.
;                  |  $PFM_RIGHTINDENT  - The dxRightIndent member is valid.
;                  |  $PFM_RTLPARA      - Rich Edit 2.0: The wEffects member is valid
;                  |  $PFM_STARTINDENT  - The dxStartIndent member is valid.
;                  |  $PFM_TABSTOPS     - The cTabStobs and rgxTabStops members are valid.
;                  wNumbering    - Value specifying numbering options. This member can be zero or $PFN_BULLET.
;                  wEffects      - A bit flag that specifies a paragraph effect. It is included only for compatibility with Text Object Model (TOM) interfaces; the rich edit control stores the value but does not use it to display the text. This parameter can be one of the following values.
;                  |  0                 - Displays text using left-to-right reading order. This is the default.
;                  |  $PFE_RLTPARA      - Displays text using right-to-left reading order.
;                  dxStartIndent - Indentation of the first line in the paragraph, in twips.
;                  |If the paragraph formatting is being set and PFM_OFFSETINDENT is specified, this member is treated as a relative value that is added to the starting indentation of each affected paragraph.
;                  dxRightIndent - Size, of the right indentation relative to the right margin, in twips.
;                  dxOffset      - Indentation of the second and subsequent lines of a paragraph relative to the starting indentation, in twips.
;                  |The first line is indented if this member is negative or outdented if this member is positive.
;                  wAlignment    - Value specifying the paragraph alignment. This member can be one of the following values.
;                  |  $PFA_CENTER       - Paragraphs are centered.
;                  |  $PFA_LEFT         - Paragraphs are aligned with the left margin.
;                  |  $PFA_RIGHT        - Paragraphs are aligned with the right margin.
;                  cTabCount     - Number of tab stops.
;                  rgxTabs       - Array of absolute tab stop positions. Each element in the array specifies information about a tab stop. The 24 low-order bits specify the absolute offset, in twips. To use this member, set the PFM_TABSTOPS flag in the dwMask member.
;                  |Rich Edit 2.0: For compatibility with TOM interfaces, you can use the eight high-order bits to store additional information about each tab stop.
;                  |  Bits 24-27 can specify one of the following values to indicate the tab alignment. These bits do not affect the rich edit control display for versions earlier than Rich Edit 3.0.
;                  |    0               - Ordinary tab
;                  |    1               - Center tab
;                  |    2               - Right-aligned tab
;                  |    3               - Decimal tab
;                  |    4               - Word bar tab (vertical bar)
;                  |  Bits 28-31 can specify one of the following values to indicate the type of tab leader. These bits do not affect the rich edit control display.
;                  |    0               - No leader
;                  |    1               - Dotted leader
;                  |    2               - Dashed leader
;                  |    3               - Underlined leader
;                  |    4               - Thick line leader
;                  |    5               - Double line leader
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagPARAFORMAT = "uint cbSize;dword dwMask;word wNumbering;word wEffects;long dxStartIndent;" _
		 & "long dxRightIndent;long dxOffset;word wAlignment;short cTabCount;long rgxTabs[32]"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagPARAFORMAT2
; Description ...: Contains information about paragraph formatting attributes in a rich edit control.
; Fields ........: cbSize        - Structure size, in bytes.
;                  dwMask        - The members of the PARAFORMAT2 structure that contain valid information. The dwMask member can be a combination of the values from two sets of bit flags. One set indicates the structure members that are valid; another set indicates the valid attributes in the wEffects member.
;                  |Set the following values to indicate the valid structure members.
;                  |  $PFM_ALIGNMENT       - The wAlignment member is valid.
;                  |  $PFM_BORDER          - The wBorderSpace, wBorderWidth, and wBorders members are valid.
;                  |  $PFM_LINESPACING     - The dyLineSpacing and bLineSpacingRule members are valid.
;                  |  $PFM_NUMBERING       - The wNumbering member is valid.
;                  |  $PFM_NUMBERINGSTART  - The wNumberingStart member is valid.
;                  |  $PFM_NUMBERINGSTYLE  - The wNumberingStyle member is valid.
;                  |  $PFM_NUMBERINGTAB    - The wNumberingTab member is valid.
;                  |  $PFM_OFFSET          - The dxOffset member is valid.
;                  |  $PFM_OFFSETINDENT    - The dxStartIndent member is valid. If you are setting the indentation, dxStartIndent specifies the amount to indent relative to the current indentation.
;                  |  $PFM_RIGHTINDENT     - The dxRightIndent member is valid.
;                  |  $PFM_SHADING         - The wShadingWeight and wShadingStyle members are valid.
;                  |  $PFM_SPACEAFTER      - The dySpaceAfter member is valid.
;                  |  $PFM_SPACEBEFORE     - The dySpaceBefore member is valid.
;                  |  $PFM_STARTINDENT     - The dxStartIndent member is valid and specifies the indentation from the left margin. If both PFM_STARTINDENT and PFM_OFFSETINDENT are specified, PFM_STARTINDENT takes precedence.
;                  |  $PFM_STYLE           - The sStyle member is valid.
;                  |  $PFM_TABSTOPS        - The cTabCount and rgxTabs members are valid.
;                  |Set the following values to indicate the valid attributes of the wEffects member.
;                  |  $PFM_DONOTHYPHEN     - The PFE_DONOTHYPHEN value is valid.
;                  |  $PFM_KEEP            - The PFE_KEEP value is valid.
;                  |  $PFM_KEEPNEXT        - The PFE_KEEPNEXT value is valid.
;                  |  $PFM_NOLINENUMBER    - The PFE_NOLINENUMBER value is valid.
;                  |  $PFM_NOWIDOWCONTROL  - The PFE_NOWIDOWCONTROL value is valid.
;                  |  $PFM_PAGEBREAKBEFORE - The PFE_PAGEBREAKBEFORE value is valid.
;                  |  $PFM_RTLPARA         - The PFE_RTLPARA value is valid.
;                  |  $PFM_SIDEBYSIDE      - The PFE_SIDEBYSIDE value is valid.
;                  |  $PFM_TABLE           - The PFE_TABLE value is valid.
;                  wNumbering    - Options used for bulleted or numbered paragraphs. To use this member, set the PFM_NUMBERING flag in the dwMask member.
;                  |This member can be one of the following values.
;                  |  zero                 - No paragraph numbering or bullets.
;                  |  $PFN_BULLET          - Insert a bullet at the beginning of each selected paragraph.
;                  |                         Rich Edit versions earlier than version 3.0 do not display paragraph numbers.
;                  |                         However, for compatibility with Microsoft Text Object Model (TOM) interfaces,
;                  |                         wNumbering can specify one of the following values.
;                  |                         (The rich edit control stores the value but does not use it to display the text.)
;                  |  2                    - Uses Arabic numbers (1, 2, 3, ...).
;                  |  3                    - Uses lowercase letters (a, b, c, ...).
;                  |  4                    - Uses uppercase letters (A, B, C, ...).
;                  |  5                    - Uses lowercase Roman numerals (i, ii, iii, ...).
;                  |  6                    - Uses uppercase Roman numerals (I, II, III, ...).
;                  |  7                    - Uses a sequence of characters beginning with the Unicode character specified by the wNumberingStart member.
;                  wEffects      - A set of bit flags that specify paragraph effects. These flags are included only for compatibility with Text Object Model (TOM) interfaces; the rich edit control stores the value but does not use it to display the text.
;                  |This member can be a combination of the following values.
;                  |  $PFE_DONOTHYPHEN     - Disables automatic hyphenation.
;                  |  $PFE_KEEP            - No page break within the paragraph.
;                  |  $PFE_KEEPNEXT        - No page break between this paragraph and the next.
;                  |  $PFE_NOLINENUMBER    - Disables line numbering (in Rich Edit 3.0 only).
;                  |  $PFE_NOWIDOWCONTROL  - Disables widow and orphan control for the selected paragraph.
;                  |  $PFE_PAGEBREAKBEFORE - Inserts a page break before the selected paragraph.
;                  |  $PFE_RTLPARA         - Displays text using right-to-left reading order (in Rich Edit 2.1 and later).
;                  |  $PFE_SIDEBYSIDE      - Displays paragraphs side by side.
;                  |  $PFE_TABLE           - The paragraph is a table row.
;                  dxStartIndent - Indentation of the paragraph's first line, in twips.
;                  |The indentation of subsequent lines depends on the dxOffset member.
;                  |To use the dxStartIndent member, set the $PFM_STARTINDENT or $PFM_OFFSETINDENT flag in the dwMask member.
;                  |If you are setting the indentation, use the $PFM_STARTINDENT flag to specify an absolute indentation from the left margin
;                  |or use the $PFM_OFFSETINDENT flag to specify an indentation relative to the paragraph's current indentation.
;                  |Use either flag to retrieve the current indentation.
;                  dxRightIndent - Indentation of the right side of the paragraph, relative to the right margin, in twips.
;                  |To use this member, set the $PFM_RIGHTINDENT flag in the dwMask member.
;                  dxOffset      - Indentation of the second and subsequent lines, relative to the indentation of the first line, in twips.
;                  |The first line is indented if this member is negative or outdented if this member is positive.
;                  |To use this member, set the $PFM_OFFSET flag in the dwMask member.
;                  wAlignment    - Paragraph alignment. To use this member, set the PFM_ALIGNMENT flag in the dwMask member. This member can be one of the following values.
;                  |  $PFA_LEFT            - Paragraphs are aligned with the left margin.
;                  |  $PFA_RIGHT           - Paragraphs are aligned with the right margin.
;                  |  $PFA_CENTER          - Paragraphs are centered.
;                  |  $PFA_JUSTIFY         - Rich Edit 2.0: Paragraphs are justified.
;                  |                         This value is included for compatibility with TOM interfaces;
;                  |                         rich edit controls earlier than Rich Edit 3.0 display the text aligned with the left margin.
;                  |  $PFA_FULL_INTERWORD  - Paragraphs are justified by expanding the blanks alone.
;                  cTabCount     - Number of tab stops defined in the rgxTabs array.
;                  rgxTabs       - Array of absolute tab stop positions. Each element in the array specifies information about a tab stop. The 24 low-order bits specify the absolute offset, in twips. To use this member, set the PFM_TABSTOPS flag in the dwMask member.
;                  |Rich Edit 2.0: For compatibility with TOM interfaces, you can use the eight high-order bits to store additional information about each tab stop.
;                  |  Bits 24-27 can specify one of the following values to indicate the tab alignment. These bits do not affect the rich edit control display for versions earlier than Rich Edit 3.0.
;                  |    0                  - Ordinary tab
;                  |    1                  - Center tab
;                  |    2                  - Right-aligned tab
;                  |    3                  - Decimal tab
;                  |    4                  - Word bar tab (vertical bar)
;                  |  Bits 28-31 can specify one of the following values to indicate the type of tab leader. These bits do not affect the rich edit control display.
;                  |    0                  - No leader
;                  |    1                  - Dotted leader
;                  |    2                  - Dashed leader
;                  |    3                  - Underlined leader
;                  |    4                  - Thick line leader
;                  |    5                  - Double line leader
;                  dySpaceBefore - Size of the spacing above the paragraph, in twips. To use this member, set the PFM_SPACEBEFORE flag in the dwMask member. The value must be greater than or equal to zero.
;                  dySpaceAfter  - Specifies the size of the spacing below the paragraph, in twips. To use this member, set the PFM_SPACEAFTER flag in the dwMask member. The value must be greater than or equal to zero.
;                  dyLineSpacing - Spacing between lines. For a description of how this value is interpreted, see the bLineSpacingRule member. To use this member, set the PFM_LINESPACING flag in the dwMask member.
;                  sStyle        - Text style. To use this member, set the PFM_STYLE flag in the dwMask member. This member is included only for compatibility with TOM interfaces and Microsoft Word; the rich edit control stores the value but does not use it to display the text.
;                  bLineSpacingRule - Type of line spacing. To use this member, set the PFM_SPACEAFTER flag in the dwMask member. This member can be one of the following values.
;                  |    0                  - Single spacing. The dyLineSpacing member is ignored.
;                  |    1                  - One-and-a-half spacing. The dyLineSpacing member is ignored.
;                  |    2                  - Double spacing. The dyLineSpacing member is ignored.
;                  |    3                  - The dyLineSpacing member specifies the spacingfrom one line to the next, in twips. However, if dyLineSpacing specifies a value that is less than single spacing, the control displays single-spaced text.
;                  |    4                  - The dyLineSpacing member specifies the spacing from one line to the next, in twips. The control uses the exact spacing specified, even if dyLineSpacing specifies a value that is less than single spacing.
;                  |    5                  - The value of dyLineSpacing / 20 is the spacing, in lines, from one line to the next. Thus, setting dyLineSpacing to 20 produces single-spaced text, 40 is double spaced, 60 is triple spaced, and so on.
;                  bOutlineLevel - Reserved; must be zero.
;                  wShadingWeight - Percentage foreground color used in shading. The wShadingStyle member specifies the foreground and background shading colors. A value of 5 indicates a shading color consisting of 5 percent foreground color and 95 percent background color. To use these members, set the PFM_SHADING flag in the dwMask member. This member is included only for compatibility with Word; the rich edit control stores the value but does not use it to display the text.
;                  wShadingStyle - Style and colors used for background shading. Bits 0 to 3 contain the shading style, bits 4 to 7 contain the foreground color index, and bits 8 to 11 contain the background color index. To use this member, set the PFM_SHADING flag in the dwMask member. This member is included only for compatibility with Word; the rich edit control stores the value but does not use it to display the text.
;                  |  The shading style can be one of the following values.
;                  |    0                  - None
;                  |    1                  - Dark horizontal
;                  |    2                  - Dark vertical
;                  |    3                  - Dark down diagonal
;                  |    4                  - Dark up diagonal
;                  |    5                  - Dark grid
;                  |    6                  - Dark trellis
;                  |    7                  - Light horizontal
;                  |    8                  - Light vertical
;                  |    9                  - Light down diagonal
;                  |    10                 - Light up diagonal
;                  |    11                 - Light grid
;                  |    12                 - Light trellis
;                  |  The foreground and background color indexes can be one of the following values.
;                  |    0                  - Black
;                  |    1                  - Blue
;                  |    2                  - Cyan
;                  |    3                  - Green
;                  |    4                  - Magenta
;                  |    5                  - Red
;                  |    6                  - Yellow
;                  |    7                  - White
;                  |    8                  - Dark blue
;                  |    9                  - Dark cyan
;                  |    10                 - Dark green
;                  |    11                 - Dark magenta
;                  |    12                 - Dark red
;                  |    13                 - Dark yellow
;                  |    14                 - Dark gray
;                  |    15                 - Light gray
;                  wNumberingStart - Starting number or Unicode value used for numbered paragraphs. Use this member in conjunction with the wNumbering member. This member is included only for compatibility with TOM interfaces; the rich edit control stores the value but does not use it to display the text or bullets. To use this member, set the PFM_NUMBERINGSTART flag in the dwMask member.
;                  wNumberingStyle - Numbering style used with numbered paragraphs. Use this member in conjunction with the wNumbering member. This member is included only for compatibility with TOM interfaces; the rich edit control stores the value but rich edit versions earlier than 3.0 do not use it to display the text or bullets. To use this member, set the PFM_NUMBERINGSTYLE flag in the dwMask member. This member can be one of the following values.
;                  |    0                  - Follows the number with a right parenthesis.
;                  |    0x100              - Encloses the number in parentheses.
;                  |    0x200              - Follows the number with a period.
;                  |    0x300              - Displays only the number.
;                  |    0x400              - Continues a numbered list without applying the next number or bullet.
;                  |    0x8000             - Starts a new number with wNumberingStart.
;                  wNumberingTab - Minimum space between a paragraph number and the paragraph text, in twips. Use this member in conjunction with the wNumbering member. The wNumberingTab member is included for compatibility with TOM interfaces; previous to Rich Edit 3.0, the rich edit control stores the value but does not use it to display text. To use this member, set the PFM_NUMBERINGTAB flag in the dwMask member.
;                  wBorderSpace - The space between the border and the paragraph text, in twips. The wBorderSpace member is included for compatibility with Word; the rich edit control stores the values but does not use them to display text. To use this member, set the PFM_BORDER flag in the dwMask member.
;                  wBorderWidth - Border width, in twips. To use this member, set the PFM_BORDER flag in the dwMask member.
;                  wBorders - Border location, style, and color. Bits 0 to 7 specify the border locations, bits 8 to 11 specify the border style, and bits 12 to 15 specify the border color index. To use this member, set the PFM_BORDER flag in the dwMask member.
;                  |  Specify the border locations using a combination of the following values in bits 0 to 7.
;                  |    1                  - Left border.
;                  |    2                  - Right border.
;                  |    4                  - Top border.
;                  |    8                  - Bottom border.
;                  |    16                 - Inside borders.
;                  |    32                 - Outside borders.
;                  |    64                 - Autocolor. If this bit is set, the color index in bits 12 to 15 is not used.
;                  |  Specify the border style using one of the following values for bits 8 to 11.
;                  |    0                  - None
;                  |    1                  - 3/4 point
;                  |    2                  - 11/2 point
;                  |    3                  - 21/4 point
;                  |    4                  - 3 point
;                  |    5                  - 41/2 point
;                  |    6                  - 6 point
;                  |    7                  - 3/4 point double
;                  |    8                  - 11/2 point double
;                  |    9                  - 21/4 point double
;                  |    10                 - 3/4 point gray
;                  |    11                 - 3/4 point gray dashed
;                  |  Specify the border color using one of the following values for bits 12 to 15. This value is ignored if the autocolor bit (bit 6) is set.
;                  |    0                  - Black
;                  |    1                  - Blue
;                  |    2                  - Cyan
;                  |    3                  - Green
;                  |    4                  - Magenta
;                  |    5                  - Red
;                  |    6                  - Yellow
;                  |    7                  - White
;                  |    8                  - Dark blue
;                  |    9                  - Dark cyan
;                  |    10                 - Dark green
;                  |    11                 - Dark magenta
;                  |    12                 - Dark red
;                  |    13                 - Dark yellow
;                  |    14                 - Dark gray
;                  |    15                 - Light gray
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagPARAFORMAT2 = $tagPARAFORMAT _
		 & ";long dySpaceBefore;long dySpaceAfter;long dyLineSpacing;short sStyle;byte bLineSpacingRule;" _
		 & "byte bOutlineLevel;word wShadingWeight;word wShadingStyle;word wNumberingStart;word wNumberingStyle;" _
		 & "word wNumberingTab;word wBorderSpace;word wBorderWidth;word wBorders"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagSETTEXTEX
; Description ...: Specifies which code page (if any) to use in setting text, whether the text replaces all the text in the control or just the selection, and whether the undo state is to be preserved.
; Fields ........: flags    - Option flags. It can be any reasonable combination of the following flags.
;                  |  $ST_DEFAULT   - Deletes the undo stack, discards rich-text formatting, replaces all text.
;                  |  $ST_KEEPUNDO  - Keeps the undo stack.
;                  |  $ST_SELECTION - Replaces selection and keeps rich-text formatting.
;                  codepage - Code page used in the translation. It is $CP_ACP for ANSI Code Page and 1200 for Unicode.
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagSETTEXTEX = "dword flags;uint codepage"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagTEXTRANGE
; Description ...: Specifies a range of characters in a rich edit control
; Fields ........: cpMin     - Character position index immediately preceding the first character in the range.
;                  cpMax     - Character position immediately following the last character in the range.
;                  lpstrText - Pointer to buffer that receives the text.
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagTEXTRANGE = $tagCHARRANGE & ";ptr lpstrText"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagMSGFILTER
; Description ...: Contains information about a keyboard or mouse event.
; Fields ........: hWndFrom - Window handle to the control sending a message
;                  IDFrom   - Identifier of the control sending a message
;                  Code     - Notification code
;                  msg       - Keyboard or mouse message identifier.
;                  wParam    - The wParam parameter of the message.
;                  lParam    - The lParam parameter of the message.
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagMSGFILTER = "align 4;" & $tagNMHDR & ";uint msg;wparam wParam;lparam lParam"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagENLINK
; Description ...: Contains information about an EN_LINK notification message from a rich edit control.
; Fields ........: hWndFrom - Window handle to the control sending a message
;                  IDFrom   - Identifier of the control sending a message
;                  Code     - Notification code
;                  msg       - Keyboard or mouse message identifier.
;                  wParam    - The wParam parameter of the message.
;                  lParam    - The lParam parameter of the message.
;                  cpMin     - Character position index immediately preceding the first character in the range.
;                  cpMax     - Character position immediately following the last character in the range.
; Author ........: Gary Frost (gafrost)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagENLINK = "align 4;" & $tagNMHDR & ";uint msg;wparam wParam;lparam lParam;" & $tagCHARRANGE

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_AppendText
; Description....: Appends text at the end of the client area
; Syntax ........: _GUICtrlRichEdit_AppendText($hWnd, $sText)
; Parameters.....: hWnd		- Handle to the control
;                  $sText    - Text to be appended
; Return values..: Succcess - True
;                  |Failure - False, and sets @error:
;                  |101 - $hWnd is not a handle
; Authors........: Gary Frost (gafrost (custompcs@charter.net))
; Modified ......: Prog@ndy, Chris Haslam (c.haslam)
; Remarks .......:
; Related .......: _GUICtrlRichEdit_InsertText, _GUICtrlRichEdit_ReplaceText, _GUICtrlRichEdit_SetText
; Link ..........: @@MsdnLink@@ EM_SETTEXTEX
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_AppendText($hWnd, $sText)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	Local $iLength = _GUICtrlRichEdit_GetTextLength($hWnd)
	_GUICtrlRichEdit_SetSel($hWnd, $iLength, $iLength) ; go to end of text
	Local $tSetText = DllStructCreate($tagSETTEXTEX)
	DllStructSetData($tSetText, 1, $ST_SELECTION)
	Local $iRet
	If StringLeft($sText, 5) <> "{\rtf" And StringLeft($sText, 5) <> "{urtf" Then
		DllStructSetData($tSetText, 2, $CP_UNICODE)
		$iRet = _SendMessage($hWnd, $EM_SETTEXTEX, $tSetText, $sText, 0, "struct*", "wstr")
	Else
		DllStructSetData($tSetText, 2, $CP_ACP)
		$iRet = _SendMessage($hWnd, $EM_SETTEXTEX, $tSetText, $sText, 0, "struct*", "STR")
	EndIf
	If Not $iRet Then Return SetError(700, 0, False)
	Return True
EndFunc   ;==>_GUICtrlRichEdit_AppendText

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_AutoDetectURL
; Description....: Enables or disables automatic detection of URLS
; Syntax ........: _GUICtrlRichEdit_AutoDetectURL($hWnd, $fState)
; Parameters.....: hWnd		- Handle to the control
;                  $fState - True to detect URLs in text, False not to
; Return values..: Succcess - True
;                  |Failure - False, and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - $fState is neither True nor False
;                  |700 - internal error, e.g. insufficient memory
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: If enabled, any modified text is scanned for text that matches the format of a URL. It recognizes strings
;                  starting with the following as URLs: http:, file:, mailto:, ftp:, https:, gopher:, nntp:, prospero:,
;                  telnet:, news:, wais:. When a URL is detected, Windows sets the link attribute for all characters in the
;                  URL string, and highlights the string.
;+
;                  When automatic URL detection is on and a URL is detected, Windows removes the link attribute of all
;                  characters that are not URLs.
;+
;                  For notification to happen, call _GUICtrlRichEdit_SetEventMask with $ENM_LINK
; Related .......: _GUICtrlRichEdit_SetEventMask
; Link ..........: @@MsdnLink@@ EM_AUTOURLDETECT, @@MsdnLink@@ EN_LINK notification
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_AutoDetectURL($hWnd, $fState)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not IsBool($fState) Then Return SetError(102, 0, False)

	If _SendMessage($hWnd, $EM_AUTOURLDETECT, $fState) Then Return SetError(700, 0, False)
	Return True
EndFunc   ;==>_GUICtrlRichEdit_AutoDetectURL

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_CanPaste
; Description....: Can the contents of the clipboard be pasted into the control?
; Syntax ........: _GUICtrlRichEdit_CanPaste($hWnd)
; Parameters.....: hWnd		- Handle to the control
; Return values..: Succcess - True or False
;                  Failure - False and sets @error
;                  |101 - $hWnd is not a handle
; Authors........: Prog@ndy
; Modified ......: Chris Haslam (c.haslam)
; Remarks .......: Data in two clipboard formats can be pasted: RTF and RTF with Objects.
;                  This function determines whether data in either format is on the clipboard.
; Related .......: _GUICtrlRichEdit_Paste
; Link ..........: @@MsdnLink@@ EM_CANPASTE
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_CanPaste($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	Local $iRet = _SendMessage($hWnd, $EM_CANPASTE, 0, 0)
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlRichEdit_CanPaste

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_CanPasteSpecial
; Description....: Can the contents of the clipboard be pasted into the control in both formats?
; Syntax ........: _GUICtrlRichEdit_CanPasteSpecial($hWnd)
; Parameters.....: hWnd		- Handle to the control
; Return values..: Succcess - True or False
;                  Failure - False and sets @error
;                  |101 - $hWnd is not a handle
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: Data in two clipboard formats can be pasted: RTF and RTF with Objects.
;                  This function determines whether data in both formats is on the clipboard.
; Related .......: _GUICtrlRichEdit_PasteSpecial
; Link ..........: @@MsdnLink@@ EM_CANPASTE
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_CanPasteSpecial($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	Return _SendMessage($hWnd, $EM_CANPASTE, $_GRE_CF_RTF, 0) <> 0 _
			And _SendMessage($hWnd, $EM_CANPASTE, $_GRE_CF_RETEXTOBJ, 0) <> 0
EndFunc   ;==>_GUICtrlRichEdit_CanPasteSpecial

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_CanRedo
; Description....: Can an undone action be redone?
; Syntax ........: _GUICtrlRichEdit_CanRedo($hWnd)
; Parameters.....: hWnd		- Handle to the control
; Return values..: Succcess - True or False
;                  |Failure - False and sets @error
;                  |101 - $hWnd is not a handle
; Authors........: Prog@ndy
; Modified ......: Chris Haslam (c.haslam)
; Remarks .......:
; Related .......: _GUICtrlRichEdit_Redo
; Link ..........: @@MsdnLink@@ EM_CANREDO
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_CanRedo($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	Return _SendMessage($hWnd, $EM_CANREDO, 0, 0) <> 0
EndFunc   ;==>_GUICtrlRichEdit_CanRedo

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_CanUndo
; Description....: Can an action be undone?
; Syntax ........: _GUICtrlRichEdit_CanUndo($hWnd)
; Parameters.....: $hWnd		- Handle to the control
; Return values..: Succcess - True - there are action(s) in the undo queue
;                  Failure - False and may set @error
;                  |0 - there are no actions in the undo queue
;                  |101 - $hWnd is not a handle
; Authors........: Prog@ndy
; Modified ......: Chris Haslam (c.haslam)
; Remarks .......:
; Related .......: _GUICtrlRichEdit_Undo
; Link ..........: @@MsdnLink@@ EM_CANUNDO
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_CanUndo($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	Return _SendMessage($hWnd, $EM_CANUNDO, 0, 0) <> 0
EndFunc   ;==>_GUICtrlRichEdit_CanUndo

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_ChangeFontSize
; Description....: Increment or decrement font size(s) of selected text
; Syntax ........: _GUICtrlRichEdit_ChangeFontSize($hWnd, $iIncrement)
; Parameters.....: $hWnd		 - Handle to the control
;                  $iIncrement - Positive to increase, negative to decrease
; Return values..: Succcess - True - Font sizes were changed
;                  Failure - False and may set @error
;                  |101  - $hWnd is not a handle
;                  |102  - $iIncrement is not a number
;                  |-1 - no text selected
; Authors........: Prog@ndy
; Modified ......: Chris Haslam (c.haslam)
; Remarks .......: If there are several font sizes in the selected text, all are incremented/decremented
;+
;                  For $iIncrement positive, font sizes are rounded up; for $iIncrement negative, they are rounded down.
;+
;                  Rich Edit first adds $iIncrement to the existing font size. It then rounds up (or down) as follows:
;                  <= 12 points: 1 e.g. 7 + 1 => 8 points, 14 - 3 => 10 points
;                  12.05 to 28 points: 20 + 2.25 => 24 points
;                  28.05 to 80 points: rounded to next of 28, 36, 48, 72 or 80, e.g. 28 + 1 => 36 points, 80 - 1 => 72 points
;                  > 80 points: 10, e.g. 80 + 1 => 90
; Related .......: _GUICtrlRichEdit_SetFont
; Link ..........: @@MsdnLink@@ EM_SETFONTSIZE
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_ChangeFontSize($hWnd, $iIncrement)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not __GCR_IsNumeric($iIncrement) Then SetError(102, 0, False)

	If Not _GUICtrlRichEdit_IsTextSelected($hWnd) Then Return SetError(-1, 0, False)
	Return _SendMessage($hWnd, $EM_SETFONTSIZE, $iIncrement, 0) <> 0
EndFunc   ;==>_GUICtrlRichEdit_ChangeFontSize

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_Copy
; Description....: Copy text to clipboard
; Syntax ........: _GUICtrlRichEdit_Copy($hWnd)
; Parameters.....: hWnd		- Handle to the control
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
; Authors........: Prog@ndy
; Modified ......: Chris Haslam (c.haslam)
; Remarks .......:
; Related .......: _GUICtrlRichEdit_Paste
; Link ..........: @@MsdnLink@@ WM_COPY
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_Copy($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	_SendMessage($hWnd, $__RICHEDITCONSTANT_WM_COPY, 0, 0)
	Return True
EndFunc   ;==>_GUICtrlRichEdit_Copy

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRichEdit_Create
; Description ...: Create a Edit control
; Syntax.........: _GUICtrlRichEdit_Create($hWnd, $sText, $iLeft, $iTop[, $iWidth = 150[, $iHeight = 150[, $iStyle = -1[, $iExStyle = -1]]]])
; Parameters ....: $hWnd        - Handle to parent or owner window
;                  $sText       - Text to be displayed in the control
;                  $iLeft       - Horizontal position of the control
;                  $iTop        - Vertical position of the control
;                  $iWidth      - Control width
;                  $iHeight     - Control height
;                  $iStyle      - Control styles:
;                  |$ES_AUTOHSCROLL - Automatically scrolls text to the right by 10 characters when the user types a character at the end of the line.
;                  |$ES_AUTOVSCROLL - Automatically scrolls text up one page when the user presses the ENTER key on the last line.
;                  |$WS_HSCROLL     - Control has horizontal scroll bar
;                  |$WS_VSCROLL     - Control has vertical scroll bar
;                  |$ES_CENTER      - Centers text in a edit control.
;                  |$ES_LEFT        - Aligns text with the left margin.
;                  |$ES_MULTILINE   - Generates a multi-line control (Default)
;                  |$ES_NOHIDESEL   - The selected text is inverted, even if the control does not have the focus.
;                  |$ES_NUMBER      - Allows only digits to be entered into the edit control.
;                  |$ES_READONLY    - Prevents the user from typing or editing text in the edit control.
;                  |$ES_RIGHT       - Right-aligns text edit control.
;                  |$ES_WANTRETURN  - Specifies that a carriage return be inserted when the user presses the ENTER key. (Default)
;                  |$ES_PASSWORD    - Displays an asterisk (*) for each character that is typed into the edit control
;                  -
;                  |Default: 0
;                  |Forced : WS_CHILD, $WS_VISIBLE, $WS_TABSTOP unless $ES_READONLY
;                  $iExStyle    - Control extended style. These correspond to the standard $WS_EX_ constants.
; Return values .: Success      - Handle to the Rich Edit control
;                  Failure      - 0 and sets @error:
;                  |103 - $iLeft is neither a positive number nor zero
;                  |104 - $iTop is is neither a positive number nor zero
;                  |105 - $iWidth is neither a positive number nor -1
;                  |106 - $iHeight is neither a positive number nor -1
;                  |107 - $iStyle is is neither a positive number nor zero nor -1
;                  |108 - $iExStyle is is neither a positive number nor zero nor -1
; Author ........: Gary Frost
; Modified.......: Chris Haslam (c.haslam)
; Remarks .......:
; Related .......: _GUICtrlRichEdit_Destroy
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_Create($hWnd, $sText, $iLeft, $iTop, $iWidth = 150, $iHeight = 150, $iStyle = -1, $iExStyle = -1)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(1, 0, 0) ; Invalid Window handle for _GUICtrlRichEdit_Create 1st parameter
	If Not IsString($sText) Then Return SetError(2, 0, 0) ; 2nd parameter not a string for _GUICtrlRichEdit_Create

	If Not __GCR_IsNumeric($iLeft, ">=0") Then Return SetError(103, 0, 0)
	If Not __GCR_IsNumeric($iTop, ">=0") Then Return SetError(104, 0, 0)
	If Not __GCR_IsNumeric($iWidth, ">0,-1") Then Return SetError(105, 0, 0)
	If Not __GCR_IsNumeric($iHeight, ">0,-1") Then Return SetError(106, 0, 0)
	If Not __GCR_IsNumeric($iStyle, ">=0,-1") Then Return SetError(107, 0, 0)
	If Not __GCR_IsNumeric($iExStyle, ">=0,-1") Then Return SetError(108, 0, 0)

	If $iWidth = -1 Then $iWidth = 150
	If $iHeight = -1 Then $iHeight = 150
	If $iStyle = -1 Then $iStyle = BitOR($ES_WANTRETURN, $ES_MULTILINE)

	If BitAND($iStyle, $ES_MULTILINE) <> 0 Then $iStyle = BitOR($iStyle, $ES_WANTRETURN)
	If $iExStyle = -1 Then $iExStyle = 0x200 ;	$DS_FOREGROUND

	$iStyle = BitOR($iStyle, $__RICHEDITCONSTANT_WS_CHILD, $__RICHEDITCONSTANT_WS_VISIBLE)
	If BitAND($iStyle, $ES_READONLY) = 0 Then $iStyle = BitOR($iStyle, $__RICHEDITCONSTANT_WS_TABSTOP)

	Local $nCtrlID = __UDF_GetNextGlobalID($hWnd)
	If @error Then Return SetError(@error, @extended, 0)

	__GCR_Init()

	Local $hRichEdit = _WinAPI_CreateWindowEx($iExStyle, $_GRE_sRTFClassName, "", $iStyle, $iLeft, $iTop, $iWidth, _
			$iHeight, $hWnd, $nCtrlID)
	If $hRichEdit = 0 Then Return SetError(700, 0, False)

	__GCR_SetOLECallback($hRichEdit)
	_SendMessage($hRichEdit, $__RICHEDITCONSTANT_WM_SETFONT, _WinAPI_GetStockObject($DEFAULT_GUI_FONT), True)
	_GUICtrlRichEdit_AppendText($hRichEdit, $sText)
	Return $hRichEdit
EndFunc   ;==>_GUICtrlRichEdit_Create

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_Cut
; Description....: Cut text to clipboard
; Syntax ........: _GUICtrlRichEdit_Cut($hWnd)
; Parameters.....: hWnd		- Handle to the control
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
; Authors........: Prog@ndy
; Modified ......: Chris Haslam (c.haslam)
; Remarks .......:
; Related .......: _GUICtrlRichEdit_Copy, _GUICtrlRichEdit_Paste
; Link ..........: @@MsdnLink@@ WM_CUT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_Cut($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	_SendMessage($hWnd, $__RICHEDITCONSTANT_WM_CUT, 0, 0)
	Return True
EndFunc   ;==>_GUICtrlRichEdit_Cut

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_Deselect
; Description....: Deselects text, leaving none selected
; Syntax ........: _GUICtrlRichEdit_Deselect($hWnd)
; Parameters.....: hWnd		- Handle to the control
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: Leaves the insertion point at the anchor point of the selection
; Related .......: _GUICtrlRichEdit_SetSel, _GUICtrlRichEdit_GetSel, _GUICtrlRichEdit_IsTextSelected
; Link ..........: @@MsdnLink@@ EM_SETSEL
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_Deselect($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	_SendMessage($hWnd, $EM_SETSEL, -1, 0)
	Return True
EndFunc   ;==>_GUICtrlRichEdit_Deselect

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRichEdit_Destroy
; Description ...: Delete the Rich Edit control
; Syntax.........: _GUICtrlRichEdit_Destroy(ByRef $hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True, Handle is set to 0
;                  Failure      - False and sets @error:
;                  |1 - attempt to destroy a control belonging to another application
; Author ........: Gary Frost (gafrost)
; Modified.......: Chris Haslam (c.haslam)
; Remarks .......: Only be used on Rich Edit controls created with _GUICtrlRichEdit_Create
; Related .......: _GUICtrlRichEdit_Create
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_Destroy(ByRef $hWnd)
	If $Debug_RE Then __UDF_ValidateClassName($hWnd, $_GRE_sRTFClassName)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(2, 2, False)

	Local $Destroyed = 0
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $gh_RELastWnd) Then
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
EndFunc   ;==>_GUICtrlRichEdit_Destroy

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRichEdit_EmptyUndoBuffer
; Description ...: Resets the undo flag of the control
; Syntax.........: _GUICtrlRichEdit_EmptyUndoBuffer($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False and sets @error:
;                  |101 - $hWnd is not a handle
; Author ........: Chris Haslam (c.haslam)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRichEdit_Undo, _GUICtrlRichEdit_Redo
; Link ..........: @@MsdnLink@@ EM_SETEMPTYUNDOBUFFER
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_EmptyUndoBuffer($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	_SendMessage($hWnd, $EM_EMPTYUNDOBUFFER, 0, 0)
	Return True
EndFunc   ;==>_GUICtrlRichEdit_EmptyUndoBuffer

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_FindText
; Description ...: Search for a text starting at insertion point or at anchor point of selection
; Syntax ........: _GUICtrlRichEdit_FindText($hWnd, $sText[, $fForward = True[, $fMatchCase = False[, $fWholeWord = False[, $iBehavior = 0]]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $s_Text      - Text to find
;                  $fForward    - Search direction (Optional)
;                  !Default: forward
;                  |(Win 95: search is always forward)
;                  $fMatchCase  - Search is case-sensitive (Optional)
;                  |Default: case-insensitive
;                  $fWholeWord  - Search only for text as a whole word (Optional)
;                  |Default: partial or full word
;                  $behavior    - Any BitOr combination of $FR_MATCHALEFHAMZA, $FR_MATCHDIAC and $FR_MATCHKASHIDA
;                  |Default: 0
; Return Values. : Success - If found, inter-character position before start of matching text, else -1
;                  Failure - -1 and sets @error
;                  |101  - $hWnd is not a handle
;                  |102  - $sText = ""
;                  |103  - $fForward is neither True nor False
;                  |104  - $fMatchCase is neither True nor False
;                  |105  - $fWholeWord is neither True nor False
;                  |1061 - $iBehavior is not a number
;                  |1062 - $iBehavior is invalid
; Authors........: Chris Haslam (c.haslam)
; Modified ......: jpm
; Remarks .......:
; Related .......: _GUICtrlRichEdit_FindTextInRange
; Link ..........: @@MsdnLink@@ EM_FINDTEXT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_FindText($hWnd, $sText, $fForward = True, $fMatchCase = False, $fWholeWord = False, $iBehavior = 0)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, -1)
	If $sText = "" Then Return SetError(102, 0, -1)
	If Not IsBool($fForward) Then Return SetError(103, 0, -1)
	If Not IsBool($fMatchCase) Then Return SetError(104, 0, -1)
	If Not IsBool($fWholeWord) Then Return SetError(105, 0, -1)
	If Not __GCR_IsNumeric($iBehavior) Then Return SetError(1061, 0, -1)
	If BitAND($iBehavior, BitNOT(BitOR($FR_MATCHALEFHAMZA, $FR_MATCHDIAC, $FR_MATCHKASHIDA))) <> 0 Then Return SetError(1062, 0, -1)

	Local $iLen = StringLen($sText) + 3
	Local $tText = DllStructCreate("wchar[" & $iLen & "]")
	DllStructSetData($tText, 1, $sText)
	Local $tFindtext = DllStructCreate($tagFINDTEXT)
	Local $aiAnchorActive
	Local $fSel = _GUICtrlRichEdit_IsTextSelected($hWnd)
	If $fSel Then
		$aiAnchorActive = _GUICtrlRichEdit_GetSelAA($hWnd)
	Else
		$aiAnchorActive = _GUICtrlRichEdit_GetSel($hWnd)
	EndIf
	DllStructSetData($tFindtext, 1, $aiAnchorActive[0])
	DllStructSetData($tFindtext, 2, _Iif($fForward, -1, 0)) ; to end else to start
	DllStructSetData($tFindtext, 3, DllStructGetPtr($tText))
	Local $iWparam = 0
	If $fForward Then $iWparam = $FR_DOWN
	If $fWholeWord Then $iWparam = BitOR($iWparam, $FR_WHOLEWORD)
	If $fMatchCase Then $iWparam = BitOR($iWparam, $FR_MATCHCASE)
	$iWparam = BitOR($iWparam, $iBehavior)
	Return _SendMessage($hWnd, $EM_FINDTEXTW, $iWparam, $tFindtext, "wparam", "ptr", "struct*")
EndFunc   ;==>_GUICtrlRichEdit_FindText

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_FindTextInRange
; Description ...: Search for a text in a range of inter-character positions
; Syntax ........: _GUICtrlRichEdit_FindTextInRange($hWnd, $sText[, $iStart = 0[, $iEnd = -1[, $fMatchCase = False[, $fwholeWord = False[, $iBehavior = 0]]]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $s_Text      - Text to find
;                  $iStart      - Starting inter-character position of search (Optional)
;                  |Default: beginning of control
;                  $iEnd        - Ending inter-character position of search (Optional)
;                  |Default: end of control
;                  $fMatchCase  - Search is case-sensitive (Optional)
;                  |Default: case-insensitive
;                  $fWholeWord  - Search only for text as a whole word (Optional)
;                  |Default: partial or full word
;                  $behavior    - Any BitOr combination of $FR_MATCHALEFHAMZA, $FR_MATCHDIAC and $FR_MATCHKASHIDA
;                  |Default: 0
; Return Values. : Success - an array[2] containing values
;                  |If target string found, range of inter-character positions containing the matching text, e.g. [45,52]
;                  |If not found, [-1,-1]
;                  Failure - 0 and sets @error:
;                  |101  - $hWnd is not a handle
;                  |102  - $sText = ""
;                  |103  - $iStart is neither a positive number nor zero nor -1
;                  |104  - $iEnd is neither a positive number nor zero nor -1
;                  |105  - $fMatchCase must be True or False
;                  |106  - $fwholeWord must be True or False
;                  |1071 - $iBehavior is not a number
;                  |1072 - $iBehavior is invalid
; Authors........: Chris Haslam (c.haslam)
; Modified ......: jpm
; Remarks:         The inter-character position at the beginning of the control is 0.
;                  The default character range, 0 to -1, searches the whole text downwwards.
;                  Setting $iEnd to -1 searches down to the end of the control
;                  Setting $iStart to -1 searches up to the start of the control
; Related .......: _GUICtrlRichEdit_FindText
; Link ..........: @@MsdnLink@@ EM_FINDTEXTEX
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_FindTextInRange($hWnd, $sText, $iStart = 0, $iEnd = -1, $fMatchCase = False, $fWholeWord = False, $iBehavior = 0)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, 0)
	If $sText = "" Then Return SetError(102, 0, 0)
	If Not __GCR_IsNumeric($iStart, ">=0,-1") Then Return SetError(103, 0, 0)
	If Not __GCR_IsNumeric($iEnd, ">=0,-1") Then Return SetError(104, 0, 0)
	If Not IsBool($fMatchCase) Then Return SetError(105, 0, 0)
	If Not IsBool($fWholeWord) Then Return SetError(106, 0, 0)
	If Not __GCR_IsNumeric($iBehavior) Then Return SetError(1071, 0, 0)
	If BitAND($iBehavior, BitNOT(BitOR($FR_MATCHALEFHAMZA, $FR_MATCHDIAC, $FR_MATCHKASHIDA))) <> 0 Then Return SetError(1072, 0, 0)

	Local $iLen = StringLen($sText) + 3
	Local $tText = DllStructCreate("wchar Text[" & $iLen & "]")
	DllStructSetData($tText, "Text", $sText)
	Local $tFindtext = DllStructCreate($tagFINDTEXTEX)
	DllStructSetData($tFindtext, "cpMin", $iStart)
	DllStructSetData($tFindtext, "cpMax", $iEnd)
	DllStructSetData($tFindtext, "lpstrText", DllStructGetPtr($tText))
	Local $iWparam = 0
	If $iEnd >= $iStart Or $iEnd = -1 Then
		$iWparam = $FR_DOWN
	EndIf
	If $fWholeWord Then $iWparam = BitOR($iWparam, $FR_WHOLEWORD)
	If $fMatchCase Then $iWparam = BitOR($iWparam, $FR_MATCHCASE)
	$iWparam = BitOR($iWparam, $iBehavior)
	_SendMessage($hWnd, $EM_FINDTEXTEXW, $iWparam, $tFindtext, "iWparam", "ptr", "struct*")
	Local $aRet[2]
	$aRet[0] = DllStructGetData($tFindtext, "cpMinRang")
	$aRet[1] = DllStructGetData($tFindtext, "cpMaxRange")
	Return $aRet
EndFunc   ;==>_GUICtrlRichEdit_FindTextInRange

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_GetCharAttributes
; Description....: Returns attributes of selected text
; Syntax ........: _GUICtrlRichEdit_GetCharAttributes($hWnd)
; Parameters.....: $hWnd		- Handle to the control
; Return values..: Success -  a string consisting of three-character groups. Each group consists of:
;                  |   first and second character: any of:
;                  |      bo - bolded
;                  |      di - disabled - characters displayed with a shadow [nd]
;                  |      em - embossed [nd]
;                  |      hi - hidden, i.e. not displayed
;                  |      im - imprinted [nd]
;                  |      it - italcized
;                  |      li - EN_LINK messages are sent when mouse is over text with this attribute
;                  |      ou - outlined [nd]
;                  |      pr - EN_PROTECT sent when user attempts to modify
;                  |      re - marked as revised [nd]
;                  |      sh - shadowed [nd]
;                  |      sm - small capital letters [nd]
;                  |      st - struck out
;                  |      sb - subscript [nd]
;                  |      sp - superscript [nd]
;                  |      un - underlined
;                  |   third character: + for on, ~ for mixed
;                  Failure - "" and sets @error
;                  |101 - $hWnd is not a handle
;                  |-1  - no text is selected
; Authors........: Chris Haslam (c.haslam)
; Modified ......: jpm
; Remarks .......: Some attributes do not display in a Rich Edit control; they are marked with [nd] above.
;+
;                  Returns "" if no attributes are on
; Related .......: _GUICtrlRichEdit_SetCharAttributes
; Link ..........: @@MsdnLink@@ EM_GETCHARFORMAT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetCharAttributes($hWnd)
	Local Const $av[17][3] = [ _
			["bo", $CFM_BOLD, $CFE_BOLD],["di", $CFM_DISABLED, $CFE_DISABLED], _
			["em", $CFM_EMBOSS, $CFE_EMBOSS],["hi", $CFM_HIDDEN, $CFE_HIDDEN], _
			["im", $CFM_IMPRINT, $CFE_IMPRINT],["it", $CFM_ITALIC, $CFE_ITALIC], _
			["li", $CFM_LINK, $CFE_LINK],["ou", $CFM_OUTLINE, $CFE_OUTLINE], _
			["pr", $CFM_PROTECTED, $CFE_PROTECTED],["re", $CFM_REVISED, $CFE_REVISED], _
			["sh", $CFM_SHADOW, $CFE_SHADOW],["sm", $CFM_SMALLCAPS, $CFE_SMALLCAPS], _
			["st", $CFM_STRIKEOUT, $CFE_STRIKEOUT],["sb", $CFM_SUBSCRIPT, $CFE_SUBSCRIPT], _
			["sp", $CFM_SUPERSCRIPT, $CFE_SUPERSCRIPT],["un", $CFM_UNDERLINE, $CFE_UNDERLINE], _
			["al", $CFM_ALLCAPS, $CFE_ALLCAPS]]

	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, "")

	Local $fSel = _GUICtrlRichEdit_IsTextSelected($hWnd)
	If Not $fSel Then Return SetError(-1, 0, "")
	Local $tCharFormat = DllStructCreate($tagCHARFORMAT2)
	DllStructSetData($tCharFormat, 1, DllStructGetSize($tCharFormat))
	;	$iWparam = _Iif($fDefault,$SCF_DEFAULT,$SCF_SELECTION)	; SCF_DEFAULT doesn't work
	Local $iMask = _SendMessage($hWnd, $EM_GETCHARFORMAT, $SCF_SELECTION, $tCharFormat, 0, "wparam", "struct*")

	Local $iEffects = DllStructGetData($tCharFormat, 3)

	Local $sStatesAndAtts = "", $sState, $fM, $fE
	For $i = 0 To UBound($av, 1) - 1
		$fM = BitAND($iMask, $av[$i][1]) = $av[$i][1]
		$fE = BitAND($iEffects, $av[$i][2]) = $av[$i][2]
		If $fSel Then
			If $fM Then
				If $fE Then
					$sState = "+"
				Else
					$sState = "-"
				EndIf
			Else
				$sState = "~"
			EndIf
		Else
			If $fM Then
				$sState = "+"
			Else
				$sState = "-"
			EndIf
		EndIf
		If $sState <> "-" Then $sStatesAndAtts &= $av[$i][0] & $sState
	Next
	Return $sStatesAndAtts
EndFunc   ;==>_GUICtrlRichEdit_GetCharAttributes

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_GetCharBkColor
; Description ...: Retrieves the background color of the selected text or, if none selected, of the character to the right of the insertion point
; Syntax ........: _GUICtrlRichEdit_GetCharBkColor($hWnd)
; Parameters ....: $hWnd 			- Handle to control
; Return Values. : Success -	COLORREF value an @extended set to 1 if the color is the same throught the selection
;                  Failure - sets @error to:
;                  |101 - $hWnd is not a handle
; Authors........: grham
; Modified ......: Chris Haslam (c.haslam), jpm
; Remarks .......:
; Related .......: _GUICtrlRichEdit_SetCharBkColor
; Link ..........: @@MsdnLink@@ EM_GETCHARFORMAT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetCharBkColor($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, 0)

	Local $tCharFormat = DllStructCreate($tagCHARFORMAT2)
	DllStructSetData($tCharFormat, 1, DllStructGetSize($tCharFormat))
	__GCR_SendGetCharFormatMessage($hWnd, $tCharFormat)
	Local $iEffects = DllStructGetData($tCharFormat, 3)
	Local $iBkColor
	If BitAND($iEffects, $CFE_AUTOBACKCOLOR) = $CFE_AUTOBACKCOLOR Then
		$iBkColor = _WinAPI_GetSysColor($__RICHEDITCONSTANT_COLOR_WINDOWTEXT)
	Else
		$iBkColor = DllStructGetData($tCharFormat, 12)
	EndIf
	Return SetExtended(BitAND($iEffects, $CFM_BACKCOLOR) <> 0, $iBkColor)
EndFunc   ;==>_GUICtrlRichEdit_GetCharBkColor

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_GetCharColor
; Description ...: Retrieves the color of the selected text or, if none selected, of the character to the right of the insertion point
; Syntax ........: _GUICtrlRichEdit_GetCharColor($hWnd)
; Parameters ....: $hWnd 			- Handle to control
; Return Values. : Success -	COLORREF value an @extended set to 1 if the color is the same throught the selection
;                  Failure - sets @error to:
;                  |101 - $hWnd is not a handle
; Authors........: grham
; Modified ......: Chris Haslam (c.haslam), jpm
; Remarks .......:
; Related .......: _GUICtrlRichEdit_SetCharColor
; Link ..........: @@MsdnLink@@ EM_GETCHARFORMAT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetCharColor($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, 0)

	Local $tCharFormat = DllStructCreate($tagCHARFORMAT)
	DllStructSetData($tCharFormat, 1, DllStructGetSize($tCharFormat))
	__GCR_SendGetCharFormatMessage($hWnd, $tCharFormat)
	Local $iEffects = DllStructGetData($tCharFormat, 3)
	Local $iColor
	If BitAND($iEffects, $CFE_AUTOCOLOR) = $CFE_AUTOCOLOR Then
		$iColor = _WinAPI_GetSysColor($__RICHEDITCONSTANT_COLOR_WINDOWTEXT)
	Else
		$iColor = DllStructGetData($tCharFormat, 6)
	EndIf
	Return SetExtended(BitAND($iEffects, $CFM_COLOR) <> 0, $iColor)
EndFunc   ;==>_GUICtrlRichEdit_GetCharColor

; #FUNCTION# ====================================================================================================================
; Name...........:  _GUICtrlRichEdit_GetCharPosFromXY
; Description ...:  Gets inter-character position closest to a specified point in the client area
; Syntax.........: _GUICtrlRichEdit_GetCharPosFromXY($hWnd, $iX, $iY)
; Parameters ....: $hWnd        - Handle to the control
;                  |$iX         - horizontal screen coordinate relative to left side of control
;                  |$iY         - vertical screen coordinate relative to top of control
; Return values .: Success      - one-based character index of the character nearest the specified point
;                  |(index of last character in the control if the specified point is beyond text)
;                  Failure      -  0 and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - $iX is not a number
;                  |103 - $iY is not a number
;                  |-1 - ($iX,$iY) outside client area
; Author ........: Gary Frost (gafrost)
; Modified.......: Prog@ndy, Chris Haslam (c.haslam)
; Remarks .......:
; Related .......: _GUICtrlRichEdit_GetXYFromCharPos
; Link ..........: @@MsdnLink@@ EM_CHARFROMPOS
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetCharPosFromXY($hWnd, $iX, $iY)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, 0)
	If Not __GCR_IsNumeric($iX) Then Return SetError(102, 0, 0)
	If Not __GCR_IsNumeric($iY) Then Return SetError(103, 0, 0)

	Local $aiRect = _GUICtrlRichEdit_GetRECT($hWnd)
	If $iX < $aiRect[0] Or $iX > $aiRect[2] Or $iY < $aiRect[1] Or $iY > $aiRect[3] Then Return -1
	Local $tPointL = DllStructCreate("LONG x; LONG y;")
	DllStructSetData($tPointL, 1, $iX)
	DllStructSetData($tPointL, 2, $iY)
	Local $iRet = _SendMessage($hWnd, $EM_CHARFROMPOS, 0, $tPointL, 0, "wparam", "struct*")
	If Not $iRet Then Return SetError(-1, 0, 0)
	Return $iRet
EndFunc   ;==>_GUICtrlRichEdit_GetCharPosFromXY

; #FUNCTION# ====================================================================================================================
; Name...........:  _GUICtrlRichEdit_GetCharPosOfNextWord
; Description ...:  Gets inter-character position before the next word
; Syntax.........: _GUICtrlRichEdit_GetCharPosOfNextWord($hWnd, $iCpStart)
; Parameters ....: $hWnd      - Handle to the control
;                  |$iCPStart - inter-character position to start from
; Return values .: Success      - inter-character position before next word
;                  Failure      -  0 and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - $iCpStart is not a number
; Author ........: Chris Haslam (c.haslam)
; Modified.......:
; Remarks .......: "Word" is defined broadly; it includes punctuation, parentheses and hyphens.
; Related .......: _GUICtrlRichEdit_GetCharPosofPreviousWord
; Link ..........: @@MsdnLink@@ EM_FINDWORDBREAK
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetCharPosOfNextWord($hWnd, $iCpStart)
	; WB_RIGHT, WB_LEFT, WB_RIGHTBREAK, WB_LEFTBREAK and WB_ISDELIMITER don't work properly or at all
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, 0)
	If Not __GCR_IsNumeric($iCpStart) Then Return SetError(102, 0, 0)

	Return _SendMessage($hWnd, $EM_FINDWORDBREAK, $WB_MOVEWORDRIGHT, $iCpStart)
EndFunc   ;==>_GUICtrlRichEdit_GetCharPosOfNextWord

; #FUNCTION# ====================================================================================================================
; Name...........:  _GUICtrlRichEdit_GetCharPosOfPreviousWord
; Description ...:  Gets inter-character position before the Previous word
; Syntax.........: _GUICtrlRichEdit_GetCharPosOfPreviousWord($hWnd, $iCpStart)
; Parameters ....: $hWnd      - Handle to the control
;                  |$iCPStart - inter-character position to start from
; Return values .: Success      - inter-character position before Previous word
;                  Failure      -  0 and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - $iCpStart is not a number
; Author ........: Chris Haslam (c.haslam)
; Modified.......:
; Remarks .......: "Word" is defined broadly; it includes punctuation, parentheses and hyphens.
; Related .......: _GUICtrlRichEdit_GetCharPosofNextWord
; Link ..........: @@MsdnLink@@ EM_FINDWORDBREAK
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetCharPosOfPreviousWord($hWnd, $iCpStart)
	; WB_RIGHT, WB_LEFT, WB_RIGHTBREAK, WB_LEFTBREAK and WB_ISDELIMITER don't work properly or at all
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, 0)
	If Not __GCR_IsNumeric($iCpStart) Then Return SetError(102, 0, 0)

	Return _SendMessage($hWnd, $EM_FINDWORDBREAK, $WB_MOVEWORDLEFT, $iCpStart)
EndFunc   ;==>_GUICtrlRichEdit_GetCharPosOfPreviousWord

; #FUNCTION# ====================================================================================================================
; Name...........:  _GUICtrlRichEdit_GetCharWordBreakInfo
; Description ...:  Gets inter-character position before the Previous word
; Syntax.........: _GUICtrlRichEdit_GetCharWordBreakInfo($hWnd, $iCp)
; Parameters ....: $hWnd - Handle to the control
;                  |$iCP - inter-character position to left of character of interest
; Return values .: Success      - string consisting of comma-separated values:
;                  |value 1 - word-break flag(s):
;                  |  c - line may be broken after this character
;                  |  d - character is an end-of-word delimiter. Lines may be broken after delimiters
;                  |  w - character is white-space. (Trailing white-spaces are not included in line length.)
;                  |value 2 - character class: a number
;                  Failure      -  "" and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - $iCp is not a number
; Author ........: Chris Haslam (c.haslam)
; Modified.......:
; Remarks .......: Lines may be broken at delimiters or between characters od different classes.
;+
;                  Character classes are defined in word-break procedures. The classes in the default
;                  procedure are: 0 = alphanumeric character, 1 = other printing character (except hyphen),
;                  2 = space, 3 = tab, 4 = hyphen or end-of-paragraph.
; Related .......: _GUICtrlRichEdit_GetCharPosofNextWord
; Link ..........: @@MsdnLink@@ EM_FINDWORDBREAK
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetCharWordBreakInfo($hWnd, $iCp)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, "")
	If Not __GCR_IsNumeric($iCp) Then Return SetError(102, 0, "")

	Local $iRet = _SendMessage($hWnd, $EM_FINDWORDBREAK, $WB_CLASSIFY, $iCp)
	Local $iClass = BitAND($iRet, 0xF0)
	Local $sRet = ""
	If BitAND($iClass, $WBF_BREAKAFTER) Then $sRet &= "c"
	If BitAND($iClass, $WBF_BREAKLINE) Then $sRet &= "d"
	If BitAND($iClass, $WBF_ISWHITE) Then $sRet &= "w"
	$sRet &= ";" & BitAND($iRet, 0xF)
	Return $sRet
EndFunc   ;==>_GUICtrlRichEdit_GetCharWordBreakInfo

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_GetBkColor
; Description....: Gets the background color of the control
; Syntax ........: _GUICtrlRichEdit_GetBkColor($hWnd)
; Parameters ....: $hWnd 			- Handle to control
; Return Values. : Success -	COLORREF value
;                  Failure - sets @error to:
;                  |101 - $hWnd is not a handle
; Authors........: jpm
; Modified ......:
; Remarks .......:
; Related .......: _GUICtrlRichEdit_SetBkColor
; Link ..........: @@MsdnLink@@ EM_SETBKGNDCOLOR
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetBkColor($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, 0)

	Local $iBkColor = _SendMessage($hWnd, $EM_SETBKGNDCOLOR, False, 0)
	_SendMessage($hWnd, $EM_SETBKGNDCOLOR, False, $iBkColor)
	Return $iBkColor
EndFunc   ;==>_GUICtrlRichEdit_GetBkColor

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_GetText
; Description ...: Get all of the text in the control
; Syntax ........: _GUICtrlRichEdit_GetText($hWnd[, $fCrToCrLf = False[, $iCodePage = 0[, $sReplChar = ""]]])
; Parameters ....: $hWnd 			- Handle to control
;                  $fCrToCrLf - Convert each CR to a CrLf (Optional)
;                  |True - do it
;                  | don't (Default)
;                  $iCodePage - code page used in translation (Optional)
;                  |Default: use system default
;                  |CP_ACP for ANSI, 1200 for Unicode
;                  $sReplaChar - Character used if $iCodePage is not 1200 and a wide character cannot be represented in
;                  +specified code page (Optional)
; Return Values. : Success -	the text
;                  Failure - "" and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - $fCrToCrLf must be True or False
;                  |103 - $iCodePage is not a number
;                  |700 - internal error
; Authors........: Prog@ndy
; Modified ......: Chris Haslam (c.haslam), jpm, Prog@ndy
; Remarks .......: On success, if $sReplChar set, @extended contains whether this character was used
;+
;                  Call _GUICtrlRichEdit_IsModified() to determine whether the text has changed
; Related .......: _GUICtrlRichEdit_SetText, _GUICtrlRichEdit_AppendText, _GUICtrlRichEdit_InsertText, _GUICtrlRichEdit_IsModified
; Link ..........: @@MsdnLink@@ EM_GETTEXTEX
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetText($hWnd, $fCrToCrLf = False, $iCodePage = 0, $sReplChar = "")
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, "")
	If Not IsBool($fCrToCrLf) Then Return SetError(102, 0, "")
	If Not __GCR_IsNumeric($iCodePage) Then Return SetError(103, 0, "")

	Local $iLen = _GUICtrlRichEdit_GetTextLength($hWnd, False, True) + 1
	Local $sUni = ''
	If $iCodePage = $CP_UNICODE Or Not $iCodePage Then $sUni = "w"
	Local $tText = DllStructCreate($sUni & "char[" & $iLen & "]")

	Local $tGetTextEx = DllStructCreate($tagGETTEXTEX)
	DllStructSetData($tGetTextEx, "cb", DllStructGetSize($tText))

	Local $iFlags = 0
	If $fCrToCrLf Then $iFlags = $GT_USECRLF
	DllStructSetData($tGetTextEx, "flags", $iFlags)

	If $iCodePage = 0 Then $iCodePage = $CP_UNICODE
	DllStructSetData($tGetTextEx, "codepage", $iCodePage)

	Local $pUsedDefChar = 0, $pDefaultChar = 0
	If $sReplChar <> "" Then
		Local $tDefaultChar = DllStructCreate("char")
		$pDefaultChar = DllStructGetPtr($tDefaultChar, 1)
		DllStructSetData($tDefaultChar, 1, $sReplChar)
		Local $tUsedDefChar = DllStructCreate("bool")
		$pUsedDefChar = DllStructGetPtr($tUsedDefChar, 1)
	EndIf
	DllStructSetData($tGetTextEx, "lpDefaultChar", $pDefaultChar)
	DllStructSetData($tGetTextEx, "lpbUsedDefChar", $pUsedDefChar)

	Local $iRet = _SendMessage($hWnd, $EM_GETTEXTEX, $tGetTextEx, $tText, 0, "struct*", "struct*")
	If $iRet = 0 Then Return SetError(700, 0, "")
	If $sReplChar <> "" Then SetExtended(DllStructGetData($tUsedDefChar, 1) <> 0)
	Return DllStructGetData($tText, 1)
EndFunc   ;==>_GUICtrlRichEdit_GetText

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_GetTextLength
; Description ...: Get the length of the whole text in the control
; Syntax ........: _GUICtrlRichEdit_GetTextLength($hWnd[, $fExact = True[, $fChars = False]])
; Parameters ....: $hWnd 			- Handle to control
;                  $fExact -   = True Return the exact length (Optional)
;                  |       -  = False return at least the number of characters in the control (faster)
;                  |Default: exact length
;                  $fChars - = True - return length in characters
;                  |          = False - return length in bytes
;                  |Default: bytes
; Return Values. : Success -	length, in bytes or characters
;                  Failure - 0 and sets @error to:
;                  |101 - $hWnd is not a handle
;                  |102 - $fExact must be True or False
;                  |103 - $fChars must be True or False
; Authors........: Prog@ndy
; Modified ......: Chris Haslam (c.haslam)
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ EM_GETTEXTLENGTHEX
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetTextLength($hWnd, $fExact = True, $fChars = False)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, 0)
	If Not IsBool($fExact) Then Return SetError(102, 0, 0)
	If Not IsBool($fChars) Then Return SetError(103, 0, 0)

	Local $tGetTextLen = DllStructCreate($tagGETTEXTLENGTHEX)
	Local $iFlags = BitOR($GTL_USECRLF, _Iif($fExact, $GTL_PRECISE, $GTL_CLOSE))
	$iFlags = BitOR($iFlags, _Iif($fChars, $GTL_DEFAULT, $GTL_NUMBYTES))
	DllStructSetData($tGetTextLen, 1, $iFlags)
	DllStructSetData($tGetTextLen, 2, _Iif($fChars, $CP_ACP, $CP_UNICODE))
	Local $iRet = _SendMessage($hWnd, $EM_GETTEXTLENGTHEX, $tGetTextLen, 0, 0, "struct*")
	Return $iRet
EndFunc   ;==>_GUICtrlRichEdit_GetTextLength

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRichEdit_GetZoom
; Description ...: Gets the zoom level of the control
; Syntax.........: _GUICtrlRichEdit_GetZoom($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success - zoom level, in percent
;                  Failure  - 0 and sets @error:
;                  |101 - $hWnd is not a handle
;                  |700 - internal error
; Author ........: Chris Haslam (c.haslam)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRichEdit_SetZoom
; Link ..........: @@MsdnLink@@ EM_GETZOOM
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetZoom($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, 0)

	Local $wParam = 0, $lparam = 0
	Local $ai = _SendMessage($hWnd, $EM_GETZOOM, $wParam, $lparam, -1, "int*", "int*")
	If Not $ai[0] Then Return SetError(700, 0, 0)
	Local $iRet
	If $ai[3] = 0 And $ai[4] = 0 Then ; if a control that has not been zoomed
		$iRet = 100
	Else
		$iRet = $ai[3] / $ai[4] * 100
	EndIf
	Return StringFormat("%.2f", $iRet)
EndFunc   ;==>_GUICtrlRichEdit_GetZoom

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_GetFirstCharPosOnLine
; Description ...: Retrieves the inter-character position preceding the first character of a line
; Syntax ........: _GUICtrlRichEdit_GetFirstCharPosOnLine($h_RichEdit[, $iLine = -1])
; Parameters ....: $hWnd 			- Handle to control
;                  $iLine - Line number (Optional)
;                  |Default: current line
; Return Values. : Success - Character position of the first character of the line
;                  Failure - 0  and sets @error:
;                  |101 - $hWnd is not a handle
;                  |1021 - $iLine is neither positive nor -1
;                  |1022 - $iLine greater than number of lines of text
; Authors........: Gary Frost (custompcs at charter dot net)
; Modified ......: Chris Haslam (c.haslam)
; Remarks .......: A control that contains no text has one line.
;+
;                  The first line is line 1. The first character position in the client area is 0.
; Related .......:
; Link ..........: @@MsdnLink@@ EM_GETLINEINDEX
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetFirstCharPosOnLine($hWnd, $iLine = -1)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, 0)
	If Not __GCR_IsNumeric($iLine, ">0,-1") Then Return SetError(1021, 0, 0)

	If $iLine <> -1 Then $iLine -= 1
	Local $iRet = _SendMessage($hWnd, $EM_LINEINDEX, $iLine)
	If $iRet = -1 Then Return SetError(1022, 0, 0)
	Return $iRet
EndFunc   ;==>_GUICtrlRichEdit_GetFirstCharPosOnLine

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRichEdit_GetFont
; Description ...: Gets the font attributes of a selection or, if no selection, at the insertion point
; Syntax.........: _GUICtrlRichEdit_GetFont($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success - an array containing values:
;                  |[0] - point size
;                  |   0 if sizes are mixed in selection
;                  |[1] - the name of the font
;                  |   "" if fonts are mixed in selection
;                  |[2] - the character set
;                  |   $ANSI_CHARSET        - 0
;                  |   $BALTIC_CHARSET      - 186
;                  |   $CHINESEBIG5_CHARSET - 136
;                  |   $EASTEUROPE_CHARSET  - 238
;                  |   $GB2312_CHARSET      - 134
;                  |   $GREEK_CHARSET       - 161
;                  |   $HANGEUL_CHARSET     - 129
;                  |   $MAC_CHARSET         - 77
;                  |   $OEM_CHARSET         - 255
;                  |   $RUSSIAN_CHARSET     - 204
;                  |   $SHIFTJIS_CHARSET    - 128
;                  |   $SYMBOL_CHARSET      - 2
;                  |   $TURKISH_CHARSET     - 162
;                  |   $VIETNAMESE_CHARSET  - 163
;                  Failure - sets @error
;                  |101 - $hWnd is not a handle
; Author ........: Chris Haslam (c.haslam)
; Modified.......: jpm
; Remarks .......:
; Related .......: _GUICtrlRichEdit_SetFont
; Link ..........: @@MsdnLink@@ EM_GETCHARFORMAT, @@MsdnLink@@ LOGFONT, http://www.hep.wisc.edu/~pinghc/books/apirefeng/l/logfont.html
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetFont($hWnd)
	; MSDN does not give a mask (CFM) for bPitchAndFamily so it appears that there is no way of knowing when it is valid => omitted here
	Local $aRet[3] = [0, 0, ""]
;~ 	, $iLcid = 1033
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, 0)

	Local $tCharFormat = DllStructCreate($tagCHARFORMAT)
	DllStructSetData($tCharFormat, "cbSize", DllStructGetSize($tCharFormat))

	__GCR_SendGetCharFormatMessage($hWnd, $tCharFormat)

	If BitAND(DllStructGetData($tCharFormat, "dwMask"), $CFM_FACE) = $CFM_FACE Then _
			$aRet[1] = DllStructGetData($tCharFormat, "szFaceName")

	If BitAND(DllStructGetData($tCharFormat, "dwMask"), $CFM_SIZE) = $CFM_SIZE Then _
			$aRet[0] = DllStructGetData($tCharFormat, "yHeight") / 20

	If BitAND(DllStructGetData($tCharFormat, "dwMask"), $CFM_CHARSET) = $CFM_CHARSET Then _
			$aRet[2] = DllStructGetData($tCharFormat, "bCharSet")

	; available if using $tagCHARFORMAT2
;~ 	If BitAND(DllStructGetData($tCharFormat, "dwMask"), $CFM_LCID) = $CFM_LCID Then _
;~ 			$iLcid = DllStructGetData($tCharFormat, 13)

	Return $aRet
EndFunc   ;==>_GUICtrlRichEdit_GetFont

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRichEdit_GetRECT
; Description ...: Retrieves the formatting rectangle of a control
; Syntax.........: _GUICtrlRichEdit_GetRECT($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - an array consisting of x and y coordinates - [<left>, <top>, <right>, <bottom>]
;                  Failure - sets @error:
;                  |101 - $hWnd is not a handle
; Author ........: Gary Frost (gafrost)
; Modified.......: Chris Haslam (c.haslam), jpm
; Remarks .......: The formatting rectangle is the area in which text is drawn, part of which may not be visible.
;+
;                  All returned values are in dialog units referenced to the control
;+
;                  Per MSDN, the values returned by this function may not be exactly what may be set by _GUICtrlRichEdit_SetRECT
; Related .......:
; Link ..........: @@MsdnLink@@ EM_GETRECT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetRECT($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, 0)

	Local $tRect = DllStructCreate($tagRECT)
	_SendMessage($hWnd, $EM_GETRECT, 0, $tRect, 0, "wparam", "struct*")
	Local $aiRect[4]
	$aiRect[0] = DllStructGetData($tRect, "Left")
	$aiRect[1] = DllStructGetData($tRect, "Top")
	$aiRect[2] = DllStructGetData($tRect, "Right")
	$aiRect[3] = DllStructGetData($tRect, "Bottom")
	Return $aiRect
EndFunc   ;==>_GUICtrlRichEdit_GetRECT

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_GetLineCount
; Description ...: Retrieves the number of lines in a multi-line edit control
; Syntax ........: _GUICtrlRichEdit_GetLineCount($hWnd)
; Parameters ....: $hWnd 			- Handle to control
; Return Values. : Success - Total number of text lines
;                  Failure - 0  and sets @error:
;                  |101 - $hWnd is not a handle
; Authors........: Gary Frost (custompcs at charter dot net)
; Modified ......: Chris Haslam (c.haslam)
; Remarks .......: A control that contains no text has one line
;+
;                  Lines that are not currently visible are included in the count
;+
;                  If Wordwrap is enabled, the number of lines can change when the dimensions of the editing window change.
; Related .......:
; Link ..........: @@MsdnLink@@ EM_GETLINECOUNT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetLineCount($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, 0)

	Return _SendMessage($hWnd, $EM_GETLINECOUNT)
EndFunc   ;==>_GUICtrlRichEdit_GetLineCount

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_GetLineLength
; Description ...: Retrieves the length of a line
; Syntax ........: _GUICtrlRichEdit_GetLineLength($hWnd, $iLine)
; Parameters ....: $hWnd 			- Handle to control
;                  $iLine - line number
;                  |Special value: -1 - return number of unselected characters on lines containing selected characters
; Return Values..: Success - Multi-line control - Length of the line (in characters)
;                  |Single-line control - number of characters in the control
;                  Failure - 0 and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - $iLine is neither positive nor -1
;                  |1022 - $iLine is greater than number of characters in the control
; Authors........: Gary Frost (custompcs at charter dot net)
; Modified ......: Chris Haslam (c.haslam)
; Remarks .......: A control that contains no text has one line
;                  The first inter-character position in a control is 0.
;+
;                  The result does not include carriage-return characters at the end of the line.
; Related .......:
; Link ..........: @@MsdnLink@@ EM_GETLINELENGTH
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetLineLength($hWnd, $iLine)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, 0)
	If Not __GCR_IsNumeric($iLine, ">0,-1") Then Return SetError(102, 0, 0)

	Local $iCharPos = _GUICtrlRichEdit_GetFirstCharPosOnLine($hWnd, $iLine)
	Local $iRet = _SendMessage($hWnd, $EM_LINELENGTH, $iCharPos)
	Return $iRet
EndFunc   ;==>_GUICtrlRichEdit_GetLineLength

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_GetLineNumberFromCharPos
; Description ...: Retrieves the line number on which an inter-character position is found
; Syntax ........: _GUICtrlRichEdit_GetLineNumberFromCharPos($hWnd, $iCharPos)
; Parameters ....: $hWnd 			- Handle to control
;                  $iCharPos - Inter-character position
; Return Values..: Success - Line number (one-based)
;                  Failure - 0 and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - $iCharPos is not a positive number
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: A control that contains no text has one line
;                  The first inter-character position in a control is 0.
;+
;                  The first line is line 1.
;+
;                  If $iCharPos is negative or more than the number of characters in the control,
;                  returns the number of lines in the control
; Related .......:
; Link ..........: @@MsdnLink@@ EM_EXLINEFROMCHAR
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetLineNumberFromCharPos($hWnd, $iCharPos)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, 0)
	If Not __GCR_IsNumeric($iCharPos, ">=0") Then Return SetError(102, 0, 0)

	Return _SendMessage($hWnd, $EM_EXLINEFROMCHAR, 0, $iCharPos) + 1
EndFunc   ;==>_GUICtrlRichEdit_GetLineNumberFromCharPos

; #FUNCTION# =====================================================================================================================
; Name...........: _GUICtrlRichEdit_GetNextRedo
; Description ...: Retrieves the name or type ID of the next possible redo action
; Syntax.........: _GUICtrlRichEdit_GetNextRedo($hWnd, $fName = True)
; Parameters ....: $hWnd        - Handle to the control
;                  $fName       - True (return name, default) or False (return ID number)
; Return values .: Success - depends on value of $fName:
;                  |If $fName is True: "Unknown", "Typing", "Delete", "Drag and drop", "Cut" or "Paste"
;                  |If $Name is False: the corresponding number (0 to 5)
;                  Failure - "" and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - $fName is neither True nor False
; Author ........: Prog@ndy
; Modified.......: Chris Haslam (c.haslam)
; Remarks .......: Note that EM_GETREDONAME does not distinguish between Unknown and redo queue empty
; Related .......: _GUICtrlRichEdit_Redo, _GUICtrlRichEdit_Undo
; Link ..........: @@MsdnLink@@ EM_GETREDONAME
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetNextRedo($hWnd, $fName = True)
	Local Const $as[6] = ["Unknown", "Typing", "Delete", "Drag and drop", "Cut", "Paste"]
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, "")
	If Not IsBool($fName) Then Return SetError(102, 0, "")

	Local $iUid = _SendMessage($hWnd, $EM_GETREDONAME, 0, 0)
	If $fName Then
		Return $as[$iUid]
	Else
		Return $iUid
	EndIf
EndFunc   ;==>_GUICtrlRichEdit_GetNextRedo

; #FUNCTION# =====================================================================================================================
; Name...........: _GUICtrlRichEdit_GetNextUndo
; Description ...: Retrieves the name or type ID of the next possible Undo action
; Syntax.........: _GUICtrlRichEdit_GetNextUndo($hWnd, $fName = True)
; Parameters ....: $hWnd        - Handle to the control
;                  $fName       - True (return name, default) or False (return ID number)
; Return values .: Success - depends on value of $fName:
;                  |If $fName is True: "Unknown", "Typing", "Delete", "Drag and drop", "Cut" or "Paste"
;                  |If $Name is False: the corresponding number (0 to 5)
;                  Failure - "" and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - $fName is neither True nor False
; Author ........: Prog@ndy
; Modified.......: Chris Haslam (c.haslam)
; Remarks .......: Note that EM_GETUndoNAME does not distinguish between Unknown and Undo queue empty
; Related .......: _GUICtrlRichEdit_Undo, _GUICtrlRichEdit_Undo
; Link ..........: @@MsdnLink@@ EM_GETUndoNAME
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetNextUndo($hWnd, $fName = True)
	Local Const $as[6] = ["Unknown", "Typing", "Delete", "Drag and drop", "Cut", "Paste"]
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, "")
	If Not IsBool($fName) Then Return SetError(102, 0, "")

	Local $iUid = _SendMessage($hWnd, $EM_GETUNDONAME, 0, 0)
	If $fName Then
		Return $as[$iUid]
	Else
		Return $iUid
	EndIf
EndFunc   ;==>_GUICtrlRichEdit_GetNextUndo

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRichEdit_GetNumberOfFirstVisibleLine
; Description ...: Gets number of the first line which is visible in the control
; Syntax.........: _GUICtrlRichEdit_GetNumberOfFirstVisibleLine($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - line number (one-based)
;                  0 - False and sets @error:
;                  |101 - $hWnd is not a handle
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The first line is numbered 1
; Related .......:
; Link ..........: @@MsdnLink@@ EM_GETFIRSTVISIBLELINE
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetNumberOfFirstVisibleLine($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, 0)
	Return _SendMessage($hWnd, $EM_GETFIRSTVISIBLELINE) + 1
EndFunc   ;==>_GUICtrlRichEdit_GetNumberOfFirstVisibleLine

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_GetParaAlignment
; Description....: Gets the alignment of selected paragraph(s), or (if no selection) of the current paragraph
; Syntax ........: _GUICtrlRichEdit_GetParaAlignment($hWnd)
; Parameters.....: $hWnd		- Handle to the control
; Return values..: Success - a string consisting of a value, a semicolon (;), and a scope character:
;                  |alignment:
;                  |   l - aligned with the left margin.
;                  |   r - aligned with the right margin.
;                  |   c - centered between margins
;                  |   j - justified between margins
;                  |   f - justified between margins
;                  |   w - justified between margins by only expanding spaces
;                  |scope:
;                  |   a - all (or only) selected paragraphs have this alignment
;                  |   f - the first selected paragraph has this alignment, but other(s) don't
;                  |   c - the current paragraph has this alignment
;                  Failure - "" and sets @error:
;                  |101 - $hWnd is not a handle
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: In Richedit 2.0, justify does not display
; Related .......: _GUICtrlRichEdit_SetParaAlignment
; Link ..........: @@MsdnLink@@ EM_SETPARAFORMAT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetParaAlignment($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, "")

	Local $tParaFormat = DllStructCreate($tagPARAFORMAT2)
	DllStructSetData($tParaFormat, 1, DllStructGetSize($tParaFormat))

	__GCR_SendGetParaFormatMessage($hWnd, $tParaFormat)
	If @error Then Return SetError(@error, 0, "")
	Local $iMask = DllStructGetData($tParaFormat, 2)
	Local $iAlignment = DllStructGetData($tParaFormat, 8)
	Local $sRet = ""
	Switch ($iAlignment)
		Case $PFA_LEFT
			$sRet = "l"
		Case $PFA_CENTER
			$sRet = "c"
		Case $PFA_RIGHT
			$sRet = "r"
		Case $PFA_JUSTIFY
			$sRet = "j"
		Case $PFA_FULL_INTERWORD
			$sRet = "w"
	EndSwitch
	$sRet &= ";" & __GCR_GetParaScopeChar($hWnd, $iMask, $PFM_ALIGNMENT)
	Return $sRet
EndFunc   ;==>_GUICtrlRichEdit_GetParaAlignment

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_GetParaAttributes
; Description....: Gets the attributes of (first) selected paragraph or (if no selection) of the current paragraph
; Syntax ........: _GUICtrlRichEdit_SetParaAtttributes($hWnd)
; Parameters.....: $hWnd		- Handle to the control
; Return values..: Success - a string consisting of values separated by semicolons (;}.
;                  |Values 1 to 10: a group consisting of:
;                  |   Characters 1 to 3 - attribute
;                  |      fpg  -  force this/these paragraphs on to new page(s) (Initially off)
;                  |      hyp  -  automatic hypthenation (Initially on)
;                  |      kpt  -  keep this/these paragraph(s) together on a page (Initially off}
;                  |      kpn  -  keep this/these paragraph(s) and the next together on a page (Initially off)
;                  |      pwo  -  prevent widows and orphans, i.e. avoid a single line of this/these paragraph(s)
;                  +on a page (Initially off)
;                  |      r2l  -  display text using right-to-left reading order (Initially off)
;                  |      sbs  -  display paragraphs side by side (Initially off)
;                  |      sln  -  suppress line numbers in documents or sections with line numbers (Initially off)
;                  |      tbl  -  paragraph(s) is/are table row(s) (Initially off)
;                  |   Character 4 - state:
;                  |      +  -  attribute is on
;                  |      -  -  attribute is off
;                  |Value 11 - scope:
;                  |   f - the first selected paragraph has these attributes
;                  |   c - the current paragraph has these attributes
;                  Failure - "" and sets @error:
;                  |101 - $hWnd is not a handle
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......:
; Related .......: _GUICtrlRichEdit_SetParaAttributes
; Link ..........: @@MsdnLink@@ EM_SETPARAFORMAT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetParaAttributes($hWnd)
	; dwMask is always bitor of all PFMs
	Local Enum $kAbbrev = 0, $kEffect, $kInverted
	; MS seems to mean LINENUMBER and WIDOWCONTROL, not NOLINENUMBER and NOWIDOWCONTROL
	Local Const $av[9][3] = [ _	; abbrev, mask, effect, inverted
			["fpg", $PFE_PAGEBREAKBEFORE, False], _
			["hyp", $PFE_DONOTHYPHEN, True], _
			["kpt", $PFE_KEEP, False], _
			["kpn", $PFE_KEEPNEXT, False], _
			["pwo", $PFE_NOWIDOWCONTROL, False], _
			["r2l", $PFE_RTLPARA, False], _
			["row", $PFE_TABLE, False], _
			["sbs", $PFE_SIDEBYSIDE, False], _
			["sln", $PFE_NOLINENUMBER, False]]
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, "")

	Local $tParaFormat = DllStructCreate($tagPARAFORMAT2)
	DllStructSetData($tParaFormat, 1, DllStructGetSize($tParaFormat))
	__GCR_SendGetParaFormatMessage($hWnd, $tParaFormat)
	If @error Then Return SetError(@error, 0, "")

	Local $iEffects = DllStructGetData($tParaFormat, "wEffects")

	Local $sStatesAndAtts = "", $sState
	For $i = 0 To UBound($av, 1) - 1
		$sStatesAndAtts &= $av[$i][$kAbbrev]
		If BitAND($iEffects, $av[$i][$kEffect]) = $av[$i][$kEffect] Then
			$sState = _Iif($av[$i][$kInverted], "-", "+")
		Else
			$sState = _Iif($av[$i][$kInverted], "+", "-")
		EndIf
		$sStatesAndAtts &= $sState & ";"
	Next
	$sStatesAndAtts &= _Iif(_GUICtrlRichEdit_IsTextSelected($hWnd), "f", "c")
	Return $sStatesAndAtts
EndFunc   ;==>_GUICtrlRichEdit_GetParaAttributes

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_GetParaBorder
; Description....: Gets the border settings of (first) selected paragraph or (if no selection) of the current paragraph
; Syntax ........: _GUICtrlRichEdit_GetParaBorder($hWnd)
; Parameters.....: $hWnd		- Handle to the control
; Return values..: Success -  settings of first selected paragraph - a string consisting of values separated by semicolons (:):
;                  Value 1 - one or more of:
;                  |   l - left border
;                  |   r - right border
;                  |   t - top border
;                  |   b - bottom border
;                  |   i - inside border
;                  |   o - outside border
;                  |   or empty - no border
;                  |Value 2 -  line style - one of:
;                  |   none - no line
;                  |   .75   -  3/4 point
;                  |   1.5   -  1 1/2 points
;                  |   2.25  -  2 1/4 points
;                  |   3     -  3 points
;                  |   4.5   -  4 1/2 points
;                  |   6     -  6 points
;                  |   .75d  -  1/2 points, double
;                  |   1.5d  -  1 1/2 points, double
;                  |   2.25d -  2 1/4 points, double
;                  |   .75g  -  3/4 point grey
;                  |   .75gd - 3/4 point grey dashed
;                  |Value 3 - one of:
;                  |   aut   - autocolor
;                  |   blk   - black
;                  |   blu   - blue
;                  |   cyn   - cyan
;                  |   grn   - green
;                  |   mag   - magenta
;                  |   red   - red
;                  |   yel   - yellow
;                  |   whi   - white
;                  |   dbl   - dark blue
;                  |   dgn   - dark green
;                  |   dmg   - dark magenta
;                  |   drd   - dark red
;                  |   dyl   - dark yellow
;                  |   dgy   - dark grey
;                  |   lgy   - light grey
;                  |Value 4 - space between the border and the text (in space units)
;                  |Value 5 - scope:
;                  |   a - all (or only) selected paragraphs have these settings
;                  |   f - the first selected paragraph has these settings, but other(s) don't
;                  |   c - the current paragraph has these settings
;                  Failure - "" and sets @error:
;                  |101 - $hWnd is not a handle
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: Borders do not show in Rich Edit, but borders created here will show in Word
; Related .......: _GUICtrlRichEdit_SetParaBorder
; Link ..........: @@MsdnLink@@ EM_GETPARAFORMAT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetParaBorder($hWnd)
	Local Const $avLocs[6][2] = [["l", 1],["r", 2],["t", 4],["b", 8],["i", 16],["o", 32]]
	Local Const $avLS[12] = ["none", .75, 1.5, 2.25, 3, 4.5, 6, ".75d", "1.5d", "2.25d", ".75g", ".75gd"]
	Local Const $sClrs = "blk;blu;cyn;grn;mag;red;yel;whi;dbl;dgn;dmg;drd;dyl;dgy;lgy;"
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, "")

	Local $tParaFormat = DllStructCreate($tagPARAFORMAT2)
	DllStructSetData($tParaFormat, 1, DllStructGetSize($tParaFormat))
	__GCR_SendGetParaFormatMessage($hWnd, $tParaFormat)
	If @error Then Return SetError(@error, 0, "")

	Local $iMask = DllStructGetData($tParaFormat, 2)
	Local $iSpace = DllStructGetData($tParaFormat, 22)
	;	$iWidth = DllStructGetData($tParaFormat, 23)	; wBorderWidth does not round-trip in Rich Edit 3.0
	Local $iBorders = DllStructGetData($tParaFormat, 24)

	Local $sRet = ""
	For $i = 0 To UBound($avLocs, 1) - 1
		If BitAND($iBorders, $avLocs[$i][1]) Then $sRet &= $avLocs[$i][0]
	Next
	$sRet &= ";"
	$sRet &= $avLS[BitShift(BitAND($iBorders, 0xF00), 8)]
	$sRet &= ";"
	If BitAND($iBorders, 64) Then
		$sRet &= "aut"
	Else
		$sRet &= StringMid($sClrs, BitShift(BitAND($iBorders, 0xF000), 12) * 4 + 1, 3)
	EndIf
	$sRet &= ";"
	$sRet &= __GCR_ConvertTwipsToSpaceUnit($iSpace) & ";" ; & __GCR_ConvertTwipsToSpaceUnit($iWidth) & ";"
	$sRet &= __GCR_GetParaScopeChar($hWnd, $iMask, $PFM_BORDER)
	Return $sRet
EndFunc   ;==>_GUICtrlRichEdit_GetParaBorder

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_GetParaIndents
; Description....: Gets the border indent settings of (first) selected paragraph or (if no selection) of the current paragraph
; Syntax ........: _GUICtrlRichEdit_GetParaIndents($hWnd)
; Parameters.....: $hWnd		- Handle to the control
; Return values..: Success -  settings - a string consisting of values separated by semicolons (:):
;                  |Value 1 - Left - indentation of left side of the body of the paragraph (of lines after the first) (in space units)
;                  |Value 2 - Right - indentation of  right side of the paragraph (in space units)
;                  |Value 3 - FirstLine - indentation of the first line relative to other lines (in space units)
;                  |Value 4 - scope:
;                  |   a - all (or only) selected paragraphs have these settings
;                  |   f - the first selected paragraph has these settings, but other(s) don't
;                  |   c - the current paragraph has these settings
;                  Failure - "" and sets @error:
;                  |101 - $hWnd is not a handle
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: Postive values of $iLeft, $iRight and $iFirstLine indent towards the center of the paragraph
;+To set "space units", call _GUICtrlRichEdit_SetSpaceUnits. Initially inches
; Related .......: _GUICtrlRichEdit_SetParaIndents, _GUICtrlRichEdit_SetSpaceUnit
; Link ..........: @@MsdnLink@@ EM_GETPARAFORMAT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetParaIndents($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, "")

	Local $tParaFormat = DllStructCreate($tagPARAFORMAT2)
	DllStructSetData($tParaFormat, 1, DllStructGetSize($tParaFormat))
	DllStructSetData($tParaFormat, "dwMask", BitOR($PFM_STARTINDENT, $PFM_OFFSET))
	__GCR_SendGetParaFormatMessage($hWnd, $tParaFormat)
	If @error Then Return SetError(@error, 0, "")

	Local $iMask = DllStructGetData($tParaFormat, "dwMask")
	Local $idxSI = DllStructGetData($tParaFormat, "dxStartIndent") ; absolute
	Local $iDxOfs = DllStructGetData($tParaFormat, "dxOffset")
	Local $iDxRI = DllStructGetData($tParaFormat, "dxRightIndent")

	Local $iLeft = __GCR_ConvertTwipsToSpaceUnit($idxSI + $iDxOfs)
	Local $iFirstLine = __GCR_ConvertTwipsToSpaceUnit(-$iDxOfs)
	Local $iRight = __GCR_ConvertTwipsToSpaceUnit($iDxRI)

	Local $iRet = $iLeft & ";" & $iRight & ";" & $iFirstLine & ";" & __GCR_GetParaScopeChar($hWnd, $iMask, $PFM_STARTINDENT)
	Return $iRet
EndFunc   ;==>_GUICtrlRichEdit_GetParaIndents

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_GetParaNumbering
; Description....: Gets the numbering style of (first) selected paragraph or (if no selection) of the current paragraph
; Syntax ........: _GUICtrlRichEdit_SetParaNumbering($hWnd)
; Parameters.....: $hWnd		- Handle to the control
; Return values..: Success - values separated by semicolons (;):
;                  |value 1 - a string showing the style and starting "number"
;                  +e.g. "." (bullet), "1)","(b)", "C.", "iv", "V)"
;                  |   Trailing spaces indicate the minimum spaces between the number and the paragraph
;                  |   Special cases:
;                  |      "=" - This paragraph is an unnumbered paragraph within the preceding list element
;                  |       "" - removed the numbering from the selected paragraph(s)
;                  |value 2 - If Roman numbers, "Roman" else ""
;                  |value 3 - space between number/bullet and paragraph (in space units)
;                  |Value 4 - scope:
;                  |   a - all (or only) selected paragraphs have these settings
;                  |   f - the first selected paragraph has these settings, but other(s) don't
;                  |   c - the current paragraph has these settings
;                  Failure - "" and sets @error:
;                  |101 - $hWnd is not a handle
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: To set "space units", call _GUICtrlRichEdit_SetSpaceUnit. Initially inches
; Related .......: _GUICtrlRichEdit_SetParaNumbering, _GUICtrlRichEdit_SetSpaceUnit
; Link ..........: @@MsdnLink@@ EM_GETPARAFORMAT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetParaNumbering($hWnd)
	Local Const $avRoman[7][2] = [[1000, "m"],[500, "d"],[100, "c"],[50, "l"],[10, "x"],[5, "v"],[1, "i"]]

	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, "")

	Local $tParaFormat = DllStructCreate($tagPARAFORMAT2)
	DllStructSetData($tParaFormat, 1, DllStructGetSize($tParaFormat))
	DllStructSetData($tParaFormat, 2, BitOR($PFM_NUMBERING, $PFM_NUMBERINGSTART, $PFM_NUMBERINGSTYLE))
	__GCR_SendGetParaFormatMessage($hWnd, $tParaFormat)
	If @error Then Return SetError(@error, 0, "")

	Local $iMask = DllStructGetData($tParaFormat, "dwMask")
	Local $iChar = DllStructGetData($tParaFormat, "wNumbering")
	Local $iStart = DllStructGetData($tParaFormat, "wNumberingStart")
	Local $iStyle = DllStructGetData($tParaFormat, "wNumberingStyle")
	Local $iTab = DllStructGetData($tParaFormat, "wNumberingTab")
	Local $sRet = ""
	Switch $iChar
		Case 0 ; no numbering
			$sRet = ""
		Case 1 ; bullet
			$sRet = "."
		Case 2 ; Arabic
			$sRet = $iStart
		Case 3
			$sRet = Chr(Asc("a") + $iStart - 1)
		Case 4
			$sRet = Chr(Asc("a") + $iStart - 1)
		Case 5, 6 ; lower case Roman
			For $i = 0 To UBound($avRoman, 1) - 2 Step 2
				For $j = $i To $i + 1
					While $iStart >= $avRoman[$j][0]
						$sRet &= $avRoman[$j][1]
						$iStart -= $avRoman[$j][0]
					WEnd
					If $iStart = $avRoman[$j][0] - 1 Then
						$sRet &= $avRoman[$i + 2][1] & $avRoman[$j][1]
						$iStart -= $avRoman[$j][0] - $avRoman[$i + 2][0]
					EndIf
				Next
			Next
			While $iStart > 0
				$sRet &= "i"
				$iStart -= 1
			WEnd
			If $iChar = 6 Then $sRet = StringUpper($sRet)
	EndSwitch
	If $iChar > 1 Then
		Switch $iStyle
			Case 0
				$sRet &= ")"
			Case 0x100
				$sRet = "(" & $sRet & ")"
			Case 0x200
				$sRet &= "."
			Case 0x300 ; display only number
				; do nothing
		EndSwitch
	EndIf
	; set number-to-text spacing based on font at anchor
	Local $av = _GUICtrlRichEdit_GetFont($hWnd)
	Local $iPoints = $av[0]
	Local $iQspaces = Round($iTab / ($iPoints * 20), 0)
	For $i = 1 To $iQspaces
		$sRet &= " "
	Next
	$sRet &= ";"
	$sRet &= _Iif($iChar = 5 Or $iChar = 6, "Roman;", ";")
	$sRet &= __GCR_ConvertTwipsToSpaceUnit($iTab) & ";"
	$sRet &= __GCR_GetParaScopeChar($hWnd, $iMask, BitOR($PFM_NUMBERING, $PFM_NUMBERINGSTART, $PFM_NUMBERINGSTYLE))
	Return $sRet
EndFunc   ;==>_GUICtrlRichEdit_GetParaNumbering

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_GetParaShading
; Description....: Gets the shading settings of (first) selected paragraph or (if no selection) of the current paragraph
; Syntax ........: _GUICtrlRichEdit_GetParaShading($hWnd)
; Parameters.....: $hWnd		- Handle to the control
; Return values..: Success -  settings of first selected paragraph - a string consisting of values separated by semicolons (:):
;                  |value 1 - Weight - percent of foreground color, the rest being background color
;                  |value 2 - style  - a string containing one of the following:
;                  |   non - none
;                  |   dhz - dark horizontal
;                  |   dvt - dark vertical
;                  |   ddd - dark down diagonal
;                  |   dud - dark up diagonal
;                  |   dgr - dark grid
;                  |   dtr - dark trellis
;                  |   lhz - light horizontal
;                  |   lvt - light vertical
;                  |   ldd - light down diagonal
;                  |   lud - light up diagonal
;                  |   lgr - light grid
;                  |   ltr - light trellis
;                  |value 3 - Foreground color - one of the following:
;                  |   "blk"   - black
;                  |   "blu"   - blue
;                  |   "cyn"   - cyan
;                  |   "grn"   - green
;                  |   "mag"   - magenta
;                  |   "red"   - red
;                  |   "yel"   - yellow
;                  |   "whi"   - white
;                  |   "dbl"   - dark blue
;                  |   "dgn"   - dark green
;                  |   "dmg"   - dark magenta
;                  |   "drd"   - dark red
;                  |   "dyl"   - dark yellow
;                  |   "dgy"   - dark grey
;                  |   "lgy"   - light grey
;                  |value 4 - Background color - same values as for Foreground color
;                  |Value 5 - scope:
;                  |   a - all (or only) selected paragraphs have these settings
;                  |   f - the first selected paragraph has these settings, but other(s) don't
;                  |   c - the current paragraph has these settings
;                  Failure - "" and sets @error:
;                  |101 - $hWnd is not a handle
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: Shading does not show in Rich Edit, but shading created here will show in Word
; Related .......: _GUICtrlRichEdit_SetParaShading
; Link ..........: @@MsdnLink@@ EM_SETPARAFORMAT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetParaShading($hWnd)
	Local Const $asStyles[13] = ["non", "dhz", "dvt", "ddd", "dud", "dgr", "dtr", "lhz", "lrt", "ldd", "lud", _
			"lgr", "ltr"]
	Local Const $asClrs[16] = ["blk", "blu", "cyn", "grn", "mag", "red", "yel", "whi", "dbl", "dgn", "dmg", _
			"drd", "dyl", "dgy", "lgy"]

	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, "")

	Local $tParaFormat = DllStructCreate($tagPARAFORMAT2)
	DllStructSetData($tParaFormat, 1, DllStructGetSize($tParaFormat))
	__GCR_SendGetParaFormatMessage($hWnd, $tParaFormat)
	If @error Then Return SetError(@error, 0, "")

	Local $iMask = DllStructGetData($tParaFormat, "dwMask")
	Local $iWeight = DllStructGetData($tParaFormat, "wShadingWeight")
	Local $iS = DllStructGetData($tParaFormat, "wShadingStyle")

	Local $sRet = $iWeight & ";"
	Local $iN = BitAND($iS, 0xF)
	$sRet &= $asStyles[$iN] & ";"
	$iN = BitShift(BitAND($iS, 0xF0), 4)
	$sRet &= $asClrs[$iN] & ";"
	$iN = BitShift(BitAND($iS, 0xF00), 8)
	$sRet &= $asClrs[$iN] & ";"
	$sRet &= __GCR_GetParaScopeChar($hWnd, $iMask, $PFM_SHADING)
	Return $sRet
EndFunc   ;==>_GUICtrlRichEdit_GetParaShading

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_GetParaSpacing
; Description....: Gets the spacing settings of (first) selected paragraph or (if no selection) of the current paragraph
; Syntax ........: _GUICtrlRichEdit_GetParaSpacing($hWnd)
; Parameters.....: $hWnd		- Handle to the control
; Return values..: Success - a string consisting of the settings separated by semicolons (;):
;                  |value 1 - inter-line spacing:
;                  |   either a number - in space units
;                  |   or "<number> lines" - in lines
;                  |Value 2 - scope of value 1:
;                  |   a - all (or only) selected paragraph(s) have the above setting
;                  |   f - the first selected paragraph has this setting, but other(s) don't
;                  |   c - the current paragraph has this setting
;                  |value 3 - spacing before paragraphs (in space units)
;                  |value 4 - scope of value 3 - see above
;                  |value 5 - spacing after paragraphs (in space units)
;                  |value 6 - scope of value 5 - see above
;                  Failure - "" and sets @error:
;                  |101 - $hWnd is not a handle
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: To set "space units", call _GUICtrlRichEdit_SetSpaceUnit. Initially inches
; Related .......: _GUICtrlRichEdit_SetParaSpacing, _GUICtrlRichEdit_SetSpaceUnit
; Link ..........: @@MsdnLink@@ EM_SETPARAFORMAT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetParaSpacing($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, "")

	Local $tParaFormat = DllStructCreate($tagPARAFORMAT2)
	DllStructSetData($tParaFormat, "cbSize", DllStructGetSize($tParaFormat))
	__GCR_SendGetParaFormatMessage($hWnd, $tParaFormat)
	If @error Then Return SetError(@error, 0, "")
	Local $iInter = DllStructGetData($tParaFormat, "dyLineSpacing")
	Local $iRule = DllStructGetData($tParaFormat, "bLineSpacingRule")
	Local $sRet = ""
	Switch $iRule
		Case 0
			$sRet = "1 line;"
		Case 1
			$sRet = "1.5 lines;"
		Case 2
			$sRet = "2 lines;"
		Case 3, 4
			$sRet = __GCR_ConvertTwipsToSpaceUnit($iInter) & ";"
		Case 5
			$sRet = StringFormat("%.2f", $iInter / 20) & " lines;"
	EndSwitch
	Local $iMask = 0 ; perhaps a BUG (jpm) always 0
	$sRet &= __GCR_GetParaScopeChar($hWnd, $iMask, $PFM_LINESPACING) & ";"

	Local $iBefore = DllStructGetData($tParaFormat, "dySpaceBefore")
	$sRet &= __GCR_ConvertTwipsToSpaceUnit($iBefore) & ";"
	$sRet &= __GCR_GetParaScopeChar($hWnd, $iMask, $PFM_SPACEBEFORE) & ";"

	Local $iAfter = DllStructGetData($tParaFormat, "dySPaceAfter")
	$sRet &= __GCR_ConvertTwipsToSpaceUnit($iAfter) & ";"
	$sRet &= __GCR_GetParaScopeChar($hWnd, $iMask, $PFM_SPACEAFTER)
	Return $sRet
EndFunc   ;==>_GUICtrlRichEdit_GetParaSpacing

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_GetParaTabStops
; Description....: Gets the tabstops of (first) selected paragraph or (if no selection) of the current paragraph
; Syntax ........: _GUICtrlRichEdit_GetParaTabStops($hWnd)
; Parameters.....: $hWnd		- Handle to the control
; Return values..: Success - A string consisting of values separated by ; (semicolons).
;                  |value 1 - number of tabstops
;                  |values 2 to <value 1> + 1 - description of a tabstop:
;                  | absolute position of a tab stop (in space units)
;                  | kind of tab
;                  |   l - left tab
;                  |   c - center tab
;                  |   r - decimal tab
;                  |   b - bar tab (a vertical bar, as in Word)
;                  | kind of dot leader
;                  |   . - dotted leader
;                  |   - - dashed leader
;                  |   _ - underline leader
;                  |   = - double line leader
;                  |   t - thick-line leader
;                  |   a space - no leader
;                  |Value <value 1> + 2 - scope:
;                  |   a - all (or only) selected paragraphs have these settings
;                  |   f - the first selected paragraph has these settings, but other(s) don't
;                  |   c - the current paragraph has these settings
;                  Failure - "" and sets @error:
;                  |101 - $hWnd is not a handle
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: To set "space units", call _GUICtrlRichEdit_SetSpaceUnits. Initially inches
;+
;                  To enter a tab into a control, press Ctrl_Tab
; Related .......:  _GUICtrlRichEdit_SetParaTabStops, _GUICtrlRichEdit_SetSpaceUnit
; Link ..........: @@MsdnLink@@ EM_GETPARAFORMAT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetParaTabStops($hWnd)
	Local Const $asKind[5] = ["l", "c", "r", "d", "b"], $asLeader[6] = [" ", ".", "-", "_", "t", "="]
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, "")

	Local $tParaFormat = DllStructCreate($tagPARAFORMAT)
	DllStructSetData($tParaFormat, "cbSize", DllStructGetSize($tParaFormat))
	__GCR_SendGetParaFormatMessage($hWnd, $tParaFormat)
	If @error Then Return SetError(@error, 0, "")

	Local $iMask = DllStructGetData($tParaFormat, "dwMask")
	Local $iQtabs = DllStructGetData($tParaFormat, "cTabCount")
	Local $sRet = $iQtabs & ";"
	Local $iN, $iM
	For $i = 1 To $iQtabs
		$iN = DllStructGetData($tParaFormat, "rgxTabs", $i)
		$sRet &= __GCR_ConvertTwipsToSpaceUnit(BitAND($iN, 0xFFFFF))
		$iM = BitAND(BitShift($iN, 24), 0xF)
		$sRet &= $asKind[$iM]
		$iM = BitAND(BitShift($iN, 28), 0xF)
		$sRet &= $asLeader[$iM] & ";"
	Next
	$sRet &= __GCR_GetParaScopeChar($hWnd, $iMask, $PFM_TABSTOPS)
	Return $sRet
EndFunc   ;==>_GUICtrlRichEdit_GetParaTabStops

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRichEdit_GetPasswordChar
; Description ...: Gets the password character that a rich edit control displays when the user enters text
; Syntax.........: _GUICtrlRichEdit_GetPasswordChar($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The character to be displayed in place of any characters typed by the user
;                  |Special case: 0 - there is no password character, so the control displays the characters typed by the user
;                  Failure - 0 and sets @error:
;                  |101 - $hWnd is not a handle
; Author ........: Gary Frost
; Modified.......: Chris Haslam (c.haslam)
; Remarks .......:
; Related .......: _GUICtrlRichEdit_SetPasswordChar
; Link ..........: @@MsdnLink@@ EM_GETPASSWORDCHAR
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetPasswordChar($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, 0)

	Local $n = _SendMessage($hWnd, $EM_GETPASSWORDCHAR)
	Return _Iif($n = 0, "", Chr($n))
EndFunc   ;==>_GUICtrlRichEdit_GetPasswordChar

; #FUNCTION# =====================================================================================================================
; Name...........: _GUICtrlRichEdit_GetScrollPos
; Description ...: Gets the Scrolling position of the control
; Syntax.........: _GUICtrlRichEdit_GetScrollPos($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success - an array containing [x, y]
;                  Failure - sets @error:
;                  |101 - $hWnd is not a handle
; Author ........: unknown
; Modified.......: Chris Haslam (c.haslam), jpm
; Remarks .......: The scrolling position is the upper left corner of the control
; Related .......: _GUICtrlRichEdit_SetScrollPos
; Link ..........: @@MsdnLink@@ EM_GETSCROLLPOS
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetScrollPos($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, 0)

	Local $tPoint = DllStructCreate($tagPOINT)
	_SendMessage($hWnd, $EM_GETSCROLLPOS, 0, $tPoint, 0, "wparam", "struct*")
	Local $aRet[2]
	$aRet[0] = DllStructGetData($tPoint, "x")
	$aRet[1] = DllStructGetData($tPoint, "y")
	Return $aRet
EndFunc   ;==>_GUICtrlRichEdit_GetScrollPos

; #FUNCTION# =====================================================================================================================
; Name...........: _GUICtrlRichEdit_GetSel
; Description ...: Gets the low and high inter-character positions of a selection
; Syntax.........: _GUICtrlRichEdit_GetSel($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success - an array in the format [<low>, <high>]
;                  Failure - sets @error:
;                  |101 - $hWnd is not a handle
; Author ........: Prog@ndy
; Modified.......: Chris Haslam (c.haslam), jpm
; Remarks .......: The first character of the text is after inter-character position 0.
;                  If high = low, no text is selected
; Related .......: _GUICtrlRichEdit_GetSel, _GUICtrlRichEdit_GetSelAA
; Link ..........: @@MsdnLink@@ EM_EXGETSEL
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetSel($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, 0)

	Local $tCharRange = DllStructCreate($tagCHARRANGE)
	_SendMessage($hWnd, $EM_EXGETSEL, 0, $tCharRange, 0, "wparam", "struct*")
	Local $aRet[2]
	$aRet[0] = DllStructGetData($tCharRange, 1)
	$aRet[1] = DllStructGetData($tCharRange, 2)
	Return $aRet
EndFunc   ;==>_GUICtrlRichEdit_GetSel

; #FUNCTION# =====================================================================================================================
; Name...........: _GUICtrlRichEdit_GetSelAA
; Description ...: Gets the anchor and active inter-character positions of a selection, in that order
; Syntax.........: _GUICtrlRichEdit_GetSelAA($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success - an array in the format [<anchor>, <active>]
;                  Failure - sets @error:
;                  |-1  - no text is selected
;                  |101 - $hWnd is not a handle
; Author ........: Prog@ndy
; Modified.......: Chris Haslam (c.haslam), jpm
; Remarks .......: The first character of the text is after inter-character position 0.
; Related .......: _GUICtrlRichEdit_SetSel
; Link ..........: @@MsdnLink@@ EM_EXGETSEL
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetSelAA($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, 0)

	Local $aiLowHigh = _GUICtrlRichEdit_GetSel($hWnd)

	If $aiLowHigh[0] = $aiLowHigh[1] Then Return SetError(-1, 0, 0) ; no text selected

	_SendMessage($hWnd, $EM_SETSEL, -1, 0) ; deselect

	Local $aiNoSel = _GUICtrlRichEdit_GetSel($hWnd)

	Local $aRet[2]
	If $aiLowHigh[0] = $aiNoSel[0] Then ; if active < anchor
		$aRet[0] = $aiLowHigh[1]
		$aRet[1] = $aiLowHigh[0]
	Else
		$aRet = $aiLowHigh
	EndIf
	; restore selection
	_SendMessage($hWnd, $EM_SETSEL, $aiLowHigh[0], $aiLowHigh[1])
	_WinAPI_SetFocus($hWnd) ; need to have the selection updated
	Return $aRet
EndFunc   ;==>_GUICtrlRichEdit_GetSelAA

; #FUNCTION# =====================================================================================================================
; Name...........: _GUICtrlRichEdit_GetSelText
; Description ...: Retrieves the currently selected text
; Syntax.........: _GUICtrlRichEdit_GetSelText($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success - the selected text
;                  Failure - False and sets @error:
;                  |-1  - no text is selected
;                  |101 - $hWnd is not a handle
; Author ........: Prog@ndy
; Modified.......: Chris Haslam (c.haslam)
; Remarks .......:
; Related .......: _GUICtrlRichEdit_GetSel
; Link ..........: @@MsdnLink@@ EM_EXGETSELTEXT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetSelText($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not _GUICtrlRichEdit_IsTextSelected($hWnd) Then Return SetError(-1, 0, -1)

	Local $aiLowHigh = _GUICtrlRichEdit_GetSel($hWnd)
	Local $tText = DllStructCreate("wchar[" & $aiLowHigh[1] - $aiLowHigh[0] + 1 & "]")
	_SendMessage($hWnd, $EM_GETSELTEXT, 0, $tText, 0, "wparam", "struct*")
	Return DllStructGetData($tText, 1)
EndFunc   ;==>_GUICtrlRichEdit_GetSelText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRichEdit_GetSpaceUnit
; Description ...: Gets the unit of measure of horizontal and vertical space used in parameters of various _GUICtrlRichEdit functions
; Syntax.........: _GUICtrlRichEdit_GetSpaceUnit()
; Parameters ....: none
; Return values .: Success - "in", "cm", "mm", "pt" (points), or "tw" (twips, 1/1440 inches, 1/567 centimetres)
; Author ........: Chris Haslam (c.haslam)
; Modified.......:
; Remarks .......: Initially, space is measured in inches
; Related .......: _GUICtrlRichEdit_SetSpaceUnit
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetSpaceUnit()
	Switch $_GRE_TwipsPeSpaceUnit
		Case 1440
			Return "in"
		Case 567
			Return "cm"
		Case 56.7
			Return "mm"
		Case 20
			Return "pt"
		Case 1
			Return "tw"
	EndSwitch
EndFunc   ;==>_GUICtrlRichEdit_GetSpaceUnit

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_GetTextInLine
; Description....: Gets a line of text
; Syntax ........: _GUICtrlRichEdit_GetTextInLine($hWnd, $iLine)
; Parameters.....: $hWnd		- Handle to the control
;                  $iLine    - Line number
; Return values..: Success - the text
;                  |Failure - False, and sets @error:
;                  |101  - $hWnd is not a handle
;                  |1021 - $iLine is not a positive number
;                  |1022 - $iLine exceeds number of lines in control
;                  |700  - internal error
; Authors........: Gary Frost (gafrost (custompcs@charter.net))
; Modified ......: Chris Haslam (c.haslam)
; Remarks .......: The first line in a control  is 1
; Related .......: _GUICtrlRichEdit_GetSel
; Link ..........: @@MsdnLink@@ EM_GETLINE
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetTextInLine($hWnd, $iLine)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not __GCR_IsNumeric($iLine, ">0,-1") Then Return SetError(1021, 0, False)
	If $iLine > _GUICtrlRichEdit_GetLineCount($hWnd) Then Return SetError(1022, 0, False)

	Local $iLen = _GUICtrlRichEdit_GetLineLength($hWnd, $iLine)
	If $iLen = 0 Then Return ""
	Local $tBuffer = DllStructCreate("short Len;wchar Text[" & $iLen + 2 & "]")
	DllStructSetData($tBuffer, "Len", $iLen + 2)
	If $iLine <> -1 Then $iLine -= 1
	Local $iRet = _SendMessage($hWnd, $EM_GETLINE, $iLine, $tBuffer, 10, "wparam", "struct*")
	If $iRet = 0 Then Return SetError(700, 0, False)
	Local $tString = DllStructCreate("wchar Text[" & $iLen + 1 & "]", DllStructGetPtr($tBuffer))
	Return StringLeft(DllStructGetData($tString, "Text"), $iLen)
EndFunc   ;==>_GUICtrlRichEdit_GetTextInLine

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_GetTextInRange
; Description....: Gets the text from from one inter-character position to another
; Syntax ........: _GUICtrlRichEdit_GetTextRange($hWnd, $iStart, $iEnd)
; Parameters.....: $hWnd		- Handle to the control
;                  $iStart    - Inter-character position before the text
;                  $iEnd       - Inter-character position after the text
;                  |Special value: -1 - end of text
; Return values..: Success - the text
;                  |Failure - False, and sets @error:
;                  |101  - $hWnd is not a handle
;                  |102 - $iStart is neither positive nor zero
;                  |1031 - $iEnd is neither positive nor zero nor -1
;                  |1032 - $iStart < $iEnd and $iEnd <> -1
; Authors........: Gary Frost (gafrost (custompcs@charter.net))
; Modified ......: Prog@ndy, Chris Haslam (c.haslam)
; Remarks .......: The first character position in the control is 0
; Related .......: _GUICtrlRichEdit_GetTextinLine
; Link ..........: @@MsdnLink@@ EM_GETTEXTRANGE
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetTextInRange($hWnd, $iStart, $iEnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not __GCR_IsNumeric($iStart, ">=0") Then Return SetError(102, 0, False)
	If Not __GCR_IsNumeric($iEnd, ">=0,-1") Then Return SetError(1031, 0, False)
	If Not ($iEnd > $iStart Or $iEnd = -1) Then Return SetError(1032, 0, False)

	Local $iLen = _GUICtrlRichEdit_GetTextLength($hWnd) ; can't use $iEnd - $iStart + 1 because of Unicode
	Local $tText = DllStructCreate("wchar[" & ($iLen + 4) & "]")
	Local $tTextRange = DllStructCreate($tagTEXTRANGE)
	DllStructSetData($tTextRange, 1, $iStart)
	DllStructSetData($tTextRange, 2, $iEnd)
	DllStructSetData($tTextRange, 3, DllStructGetPtr($tText))
	_SendMessage($hWnd, $EM_GETTEXTRANGE, 0, $tTextRange, 0, "wparam", "struct*")
	Return DllStructGetData($tText, 1)
EndFunc   ;==>_GUICtrlRichEdit_GetTextInRange

; #FUNCTION# =====================================================================================================================
; Name...........: _GUICtrlRichEdit_GetVersion
; Description ...: Retrieves the version of Rich Edit
; Syntax.........: _GUICtrlRichEdit_GetVersion()
; Parameters ....: none
; Return values .: Version of Rich Edit
; Author ........: Chris Haslam (c.haslam)
; Modified.......:
; Remarks .......: The versions of Rich Edit included in versions of Windows are:
;                  3.0 - Windows 2000, XP
;                  3.1 - Windows Vista
;                  4.0 - Windows XP SP1
;                  4.1 - Windows Vista
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetVersion()
	Return $_GRE_Version
EndFunc   ;==>_GUICtrlRichEdit_GetVersion

; #FUNCTION# =====================================================================================================================
; Name...........: _GUICtrlRichEdit_GetXYFromCharPos
; Description ...: Retrieves the XY coordinates of an inter-character position
; Syntax.........: _GUICtrlRichEdit_GetXYFromCharPos($hWnd, $iCharPos)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCharPos    - Inter-character position
; Return values .: Success _ an array [<x>, <y>] - coordinates of the inter-character position, relative to the top-left corner of the client area
;                  Failure - sets @error:
;                  |101 - $hWnd is not a handle
;                  |1021 - $iCharPos is neither a positive number nor zero
;                  |1022 - $iCharPos exceeds the number of characters in the control
; Author ........: Chris Haslam (c.haslam)
; Modified.......: jpm
; Remarks .......: The first inter-character position is numbered 0
;+
;                  With a multi-line control, coordinates are returned even for inter-character positions
;                  that are not visible.
; Related .......:
; Link ..........: @@MsdnLink@@ EM_POSFROMCHAR
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GetXYFromCharPos($hWnd, $iCharPos)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, 0)
	If Not __GCR_IsNumeric($iCharPos, ">=0") Then Return SetError(1021, 0, 0)
	If $iCharPos > _GUICtrlRichEdit_GetTextLength($hWnd) Then Return SetError(1022, 0, 0)

	Local $tPoint = DllStructCreate($tagPOINT)
	_SendMessage($hWnd, $EM_POSFROMCHAR, $tPoint, $iCharPos, 0, "struct*", "lparam")
	Local $aRet[2]
	$aRet[0] = DllStructGetData($tPoint, "X")
	$aRet[1] = DllStructGetData($tPoint, "Y")
	Return $aRet
EndFunc   ;==>_GUICtrlRichEdit_GetXYFromCharPos

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRichEdit_GotoCharPos
; Description ...: Moves the insertion point to an inter-character position
; Syntax.........: _GUICtrlRichEdit_GotoCharPos($hWnd, $iCharPos)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCharPos  the inter-character position
;                  |Special value: -1 - end of text
; Return values .: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - $iCharPos is neither a positive number nor zero nor -1
; Author ........: Chris Haslam (c.haslam)
; Modified.......:
; Remarks .......: The first character of the text in a control is at character position 1
;+
;                  Cancels text selection (if any)
; Related .......: _GUICtrlRichEdit_GetSel, _GUICtrlRichEdit_Deselect, _GUICtrlRichEdit_IsTextSelected, _GUICtrlRichEdit_SetSel
; Link ..........: @@MsdnLink@@ EM_EXSETSEL
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_GotoCharPos($hWnd, $iCharPos)
	_GUICtrlRichEdit_SetSel($hWnd, $iCharPos, $iCharPos)
	If @error Then Return SetError(@error, 0, False)
	Return True
EndFunc   ;==>_GUICtrlRichEdit_GotoCharPos

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRichEdit_HideSelection
; Description ...: Hides (or shows) a selection
; Syntax.........: _GUICtrlRichEdit_HideSelection($hWnd[, $fHide = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $fHide - = True - hide
;                  | = False - show
;                  | Default: hide
; Return values .: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - $fHide must be True or False
; Author ........: Prog@ndy
; Modified.......: Chris Haslam (c.haslam), jpm
; Remarks .......:
; Related .......: _GUICtrlRichEdit_GetSel, _GUICtrlRichEdit_SetSel
; Link ..........: @@MsdnLink@@ EM_HIDESELECTION
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_HideSelection($hWnd, $fHide = True)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not IsBool($fHide) Then Return SetError(102, 0, False)

	_SendMessage($hWnd, $EM_HIDESELECTION, $fHide, 0)
	_WinAPI_SetFocus($hWnd) ; need to have the selection updated
EndFunc   ;==>_GUICtrlRichEdit_HideSelection

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_InsertText
; Description....: Inserts text at insertion point or anchor point of selection
; Syntax ........: _GUICtrlRichEdit_InsertText($hWnd, $sText)
; Parameters.....: hWnd		- Handle to the control
;                  $sText    - Text to be inserted
; Return values..: Succcess - True
;                  Failure - False, and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - $sText = ""
;                  |700 - Operation failed
; Authors........: Gary Frost (gafrost (custompcs@charter.net)
; Modified ......: Prog@ndy, Chris Haslam (c.haslam)
; Remarks .......:
; Related .......: _GUICtrlRichEdit_AppendText, _GUICtrlRichEdit_ReplaceText, _GUICtrlRichEdit_SetText
; Link ..........: @@MsdnLink@@ EM_SETTEXTEX
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_InsertText($hWnd, $sText)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If $sText = "" Then Return SetError(102, 0, False)

	Local $tSetText = DllStructCreate($tagSETTEXTEX)
	DllStructSetData($tSetText, 1, $ST_SELECTION)
	_GUICtrlRichEdit_Deselect($hWnd)
	Local $iRet
	If StringLeft($sText, 5) <> "{\rtf" And StringLeft($sText, 5) <> "{urtf" Then
		DllStructSetData($tSetText, 2, $CP_UNICODE)
		$iRet = _SendMessage($hWnd, $EM_SETTEXTEX, $tSetText, $sText, 0, "struct*", "wstr")
	Else
		DllStructSetData($tSetText, 2, $CP_ACP)
		$iRet = _SendMessage($hWnd, $EM_SETTEXTEX, $tSetText, $sText, 0, "struct*", "STR")
	EndIf
	If Not $iRet Then Return SetError(103, 0, False) ; cannot be set
	Return True
EndFunc   ;==>_GUICtrlRichEdit_InsertText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRichEdit_IsModified
; Description ...: Retrieves the state of a rich edit control's modification flag
; Syntax.........: _GUICtrlRichEdit_IsModified($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True or False
;                  Failure - Sets @error:
;                  |101 - $hWnd is not a handle
; Author ........: Gary Frost (gafrost)
; Modified.......: Chris Haslam (c.haslam)
; Remarks .......: The system automatically sets the modification flag to False when the control is created.
;                  If the control's text is changed, either by the user or programmatically, the system sets the flag to True
;                  Call _GUICtrlRichEdit_SetModified to set or clear the flag
; Related .......: _GUICtrlRichEdit_SetModified
; Link ..........: @@MsdnLink@@ EM_GETMODIFY
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_IsModified($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	Return _SendMessage($hWnd, $EM_GETMODIFY) <> 0
EndFunc   ;==>_GUICtrlRichEdit_IsModified

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_IsTextSelected
; Description....: Is text selected?
; Syntax ........: _GUICtrlRichEdit_IsTextSelected($hWnd)
; Parameters.....: hWnd		- Handle to the control
; Return values..: Succcess - True or False
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......:
; Related .......: _GUICtrlRichEdit_GetSel, _GUICtrlRichEdit_SetSel
; Link ..........: @@MsdnLink@@ EM_EXGETSEL
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_IsTextSelected($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	Local $tCharRange = DllStructCreate($tagCHARRANGE)
	_SendMessage($hWnd, $EM_EXGETSEL, 0, $tCharRange, 0, "wparam", "struct*")
	Return DllStructGetData($tCharRange, 2) <> DllStructGetData($tCharRange, 1)
EndFunc   ;==>_GUICtrlRichEdit_IsTextSelected

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_Paste
; Description....: Paste RTF or RTF with Objects from clipboard
; Syntax ........: _GUICtrlRichEdit_Paste($hWnd)
; Parameters.....: hWnd		- Handle to the control
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
; Authors........: Prog@ndy
; Modified ......: Chris Haslam (c.haslam)
; Remarks .......: Pastes with objects if available, else without
; Related .......: _GUICtrlRichEdit_CanPaste, _GUICtrlRichEdit_PasteSpecial, _GUICtrlRichEdit_Cut, _GUICtrlRichEdit_Copy
; Link ..........: @@MsdnLink@@ WM_PASTE
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_Paste($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	_SendMessage($hWnd, $__RICHEDITCONSTANT_WM_PASTE, 0, 0)
	Return True
EndFunc   ;==>_GUICtrlRichEdit_Paste

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_PasteSpecial
; Description....: Paste RTF or RTF and Objects from clipboard
; Syntax ........: _GUICtrlRichEdit_PasteSpecial($hWnd, $fAndObjects = True)
; Parameters.....: hWnd		- Handle to the control
;                  $fAndObjects - Paste objects as well as RTF - True (default) or False
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - $fAndObjects is neither True nor False
; Authors........: Prog@ndy
; Modified ......: Chris Haslam (c.haslam)
; Remarks .......:
; Related .......: _GUICtrlRichEdit_CanPasteSpecial, _GUICtrlRichEdit_Paste, _GUICtrlRichEdit_Cut, _GUICtrlRichEdit_Copy
; Link ..........: @@MsdnLink@@ WM_PASTESPECIAL
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_PasteSpecial($hWnd, $fAndObjects = True)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	Local $iN = _Iif($fAndObjects, $_GRE_CF_RETEXTOBJ, $_GRE_CF_RTF)
	_SendMessage($hWnd, $EM_PASTESPECIAL, $iN, 0)
	Return True
EndFunc   ;==>_GUICtrlRichEdit_PasteSpecial

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_PauseRedraw
; Description....: Pauses redrawing of the control
; Syntax ........: _GUICtrlRichEdit_PauseRedraw($hWnd)
; Parameters.....: hWnd		- Handle to the control
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
; Authors........: unknown
; Modified ......: Chris Haslam (c.haslam)
; Remarks .......:
; Related .......: _GUICtrlRichEdit_ResumeRedraw
; Link ..........: @@MsdnLink@@ WM_SETREDRAW
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_PauseRedraw($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	_SendMessage($hWnd, $__RICHEDITCONSTANT_WM_SETREDRAW, False, 0)
EndFunc   ;==>_GUICtrlRichEdit_PauseRedraw

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_Redo
; Description....: Redoes last undone action
; Syntax ........: _GUICtrlRichEdit_Redo($hWnd)
; Parameters.....: $hWnd		- Handle to the control
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
; Authors........: Prog@ndy
; Modified ......: Chris Haslam (c.haslam)
; Remarks .......:
; Related .......: _GUICtrlRichEdit_Undo, _GUICtrlRichEdit_CanRedo, _GUICtrlRichEdit_GetNextRedo
; Link ..........: @@MsdnLink@@ EM_REDO
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_Redo($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	Return _SendMessage($hWnd, $EM_REDO, 0, 0) <> 0
EndFunc   ;==>_GUICtrlRichEdit_Redo

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_ReplaceText
; Description....: Replaces selected text
; Syntax ........: _GUICtrlRichEdit_ReplaceText($hWnd, $sText[, $fCanUndo = True])
; Parameters.....: $hWnd		- Handle to the control
;                  $sText     - Replacement text
;                  $fCanUndo  - Can operation can be undone? True (Default) or False
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
;                  |103 - $fCanUndo must be True or False
;                  |-1  - no text is selected
; Authors........: Gary Frost (gafrost)
; Modified ......: Chris Haslam (c.haslam), jpm
; Remarks .......:
; Related .......: _GUICtrlRichEdit_InsertText, _GUICtrlRichEdit_SetText, _GUICtrlRichEdit_Undo
; Link ..........: @@MsdnLink@@ EM_REPLACESEL
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_ReplaceText($hWnd, $sText, $fCanUndo = True)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not IsBool($fCanUndo) Then Return SetError(103, 0, False)
	If Not _GUICtrlRichEdit_IsTextSelected($hWnd) Then Return SetError(-1, 0, False)

	Local $tText = DllStructCreate("wchar Text[" & StringLen($sText) + 1 & "]")
	DllStructSetData($tText, "Text", $sText)
	If _WinAPI_InProcess($hWnd, $gh_RELastWnd) Then
		_SendMessage($hWnd, $EM_REPLACESEL, $fCanUndo, $tText, 0, "wparam", "struct*")
	Else
		Local $iText = DllStructGetSize($tText)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iText, $tMemMap)
		_MemWrite($tMemMap, $tText)
		_SendMessage($hWnd, $EM_REPLACESEL, $fCanUndo, $pMemory, 0, "wparam", "ptr")
		_MemFree($tMemMap)
	EndIf
	Return True
EndFunc   ;==>_GUICtrlRichEdit_ReplaceText

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_ResumeRedraw
; Description....: Resumes redrawing of the control
; Syntax ........: _GUICtrlRichEdit_ResumeRedraw($hWnd)
; Parameters.....: hWnd		- Handle to the control
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
; Authors........: unknown
; Modified ......:
; Remarks .......:
; Related .......: _GUICtrlRichEdit_PauseRedraw
; Link ..........: @@MsdnLink@@ WM_SETREDRAW
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_ResumeRedraw($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	_SendMessage($hWnd, $__RICHEDITCONSTANT_WM_SETREDRAW, True, 0)
	Return _WinAPI_InvalidateRect($hWnd)
EndFunc   ;==>_GUICtrlRichEdit_ResumeRedraw

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRichEdit_ScrollLineOrPage
; Description ...: Scrolls the text down or up a line or a page
; Syntax.........: _GUICtrlRichEdit_ScrollLineOrPage($hWnd, $sAction)
; Parameters ....: $hWnd        - Handle to the control
;                  $sAction     - one of the following:
;                  |"ld" - line down
;                  |"lu" - line up
;                  |"pd" - page down
;                  |"pu" - page up
; Return values .: Success      -  the number of lines actually scrolled (positive if down)
;                  Failure      -  0 and sets @error:
;                  |101  - $hWnd is not a handle
;                  |1021 - $sAction is not two characters
;                  |1022 - first character must be l or p
;                  |1023 - second character must be d or u
; Author ........: Chris Haslam (c.haslam)
; Modified.......:
; Remarks .......: This function is well behaved: it never scrolls such that lines beyond the last one are shown.
; Related .......: _GUICtrlRichEdit_ScrollLines, _GUICtrlRichEdit_ScrollToCaret
; Link ..........: @@MsdnLink@@ EM_SCROLL
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_ScrollLineOrPage($hWnd, $sAction)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, 0)
	If StringLen($sAction) <> 2 Then Return SetError(1021, 0, 0)

	Local $sCh = StringLeft($sAction, 1)
	If Not ($sCh = "l" Or $sCh = "p") Then Return SetError(1022, 0, 0)
	$sCh = StringRight($sAction, 1)
	If Not ($sCh = "d" Or $sCh = "u") Then Return SetError(1023, 0, 0)

	Local $iWparam = 0
	Switch $sAction
		Case "ld"
			$iWparam = $__RICHEDITCONSTANT_SB_LINEDOWN
		Case "lu"
			$iWparam = $__RICHEDITCONSTANT_SB_LINEUP
		Case "pd"
			$iWparam = $__RICHEDITCONSTANT_SB_PAGEDOWN
		Case "pu"
			$iWparam = $__RICHEDITCONSTANT_SB_PAGEUP
	EndSwitch
	Local $iRet = _SendMessage($hWnd, $EM_SCROLL, $iWparam, 0)
	$iRet = BitAND($iRet, 0xFFFF) ; low word
	If BitAND($iRet, 0x8000) <> 0 Then $iRet = BitOR($iRet, 0xFFFF0000) ; extend sign bit
	Return $iRet
EndFunc   ;==>_GUICtrlRichEdit_ScrollLineOrPage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRichEdit_ScrollLines
; Description ...: Scrolls the text down or up a number of lines
; Syntax.........: _GUICtrlRichEdit_ScrollLines($hWnd, $iQlines)
; Parameters ....: $hWnd        - Handle to the control
;                  $iQlines     - number of lines to scroll
; Return values .: Success      -  True
;                  Failure      -  False and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - $iQlines is not numeric
;                  |700 - attempt to scroll a single-line control
; Author ........: Gary Frost (gafrost)
; Modified.......: Chris Haslam (c.haslam)
; Remarks .......: To scroll down, set $iQlines to a positive value; to scroll up, a negative value.
;+
;                  _GUICtrlRichEdit_ScrollLines is well behaved: if $iQlines is more than the number of lines below
;                  the current line, it scrolls to show only the last line; if $iQlines is negative and specifies
;                  a line before the first one, it scrolls to show the first line at the top of the control window.
; Related .......: _GUICtrlRichEdit_ScrollLineOrPage, _GUICtrlRichEdit_ScrollToCaret
; Link ..........: @@MsdnLink@@ EM_LINESCROLL
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_ScrollLines($hWnd, $iQlines)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not __GCR_IsNumeric($iQlines) Then SetError(102, 0, False)

	Local $iRet = _SendMessage($hWnd, $EM_LINESCROLL, 0, $iQlines)
	If $iRet = 0 Then Return SetError(700, 0, False)
	Return True
EndFunc   ;==>_GUICtrlRichEdit_ScrollLines

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRichEdit_ScrollToCaret
; Description ...: Scrolls to show line on which caret (insertion point) is
; Syntax.........: _GUICtrlRichEdit_ScrollToCaret($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      -  True
;                  Failure      -  False and sets @error:
;                  |101 - $hWnd is not a handle
; Author ........: Chris Haslam (c.haslam)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlRichEdit_ScrollLineOrPage, _GUICtrlRichEdit_ScrollLines
; Link ..........: @@MsdnLink@@ EM_SCROLLCARET
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_ScrollToCaret($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	_SendMessage($hWnd, $EM_SCROLLCARET, 0, 0)
	Return True
EndFunc   ;==>_GUICtrlRichEdit_ScrollToCaret

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_SetCharAttributes
; Description....: Turns an attribute on or off for selected text or, if none selected, for text inserted at the insertion point
; Syntax ........: _GUICtrlRichEdit_SetCharAttributes($hWnd, $sStatesAndEffects[, $fWord = False])
; Parameters.....: $hWnd		- Handle to the control
;                  $sStatesAndAtts -  a string consisting of three character groups: + (or -) for the state, and a two-letter abbreviation for the attribute
;                  |   first character: + for on, - for off
;                  |   second and third character: any of:
;                  |      bo - bold
;                  |      di - disable - displays characters with a shadow [nd]
;                  |      em - emboss [nd]
;                  |      hi - hide, i.e. don't display
;                  |      im - imprint [nd]
;                  |      it - italcize
;                  |      li - send EN_LINK messages when mouse is over text with this attribute
;                  |      ou - outline [nd]
;                  |      pr - send EN_PROTECT when user attempts to modify
;                  |      re - mark as revised [nd]
;                  |      sh - shadow [nd]
;                  |      sm - small capital letters [nd]
;                  |      st - strike out
;                  |      sb - subscript [nd]
;                  |      sp - superscript [nd]
;                  |      un - underline
;                  $fWord - (Optional)
;                  | True
;                  |   If text is selected, apply the attribute to whole words in the selected text
;                  |   If not:
;                  |      If the insertion point is in a word, or at the end of it, apply the attribute to the word
;                  |      If not, apply the attribute to text inserted at the insertion point
;                  | False (Default)
;                  |   If text is selected, apply the attribute to the selected text
;                  |   If not, apply the attribute to text inserted at the insertion point
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
;                  |1021 - length of $sStatesAndAtts is not  multiple of 3
;                  |1022 - first character of group not + or -. The character is in @extended
;                  |1023 - an abbreviation for an attribute is invalid. It is in @extended
;                  |103  - $fWord must be True or False
; Authors........: Chris Haslam (c.haslam)
; Modified ......: jpm
; Remarks .......: Some attributes do not display; they are marked with [nd] above.
; Related .......: _GUICtrlRichEdit_GetCharAttributes
; Link ..........: @@MsdnLink@@ EM_SETCHARFORMAT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetCharAttributes($hWnd, $sStatesAndAtts, $fWord = False)
	Local Const $av[17][3] = [ _
			["bo", $CFM_BOLD, $CFE_BOLD],["di", $CFM_DISABLED, $CFE_DISABLED], _
			["em", $CFM_EMBOSS, $CFE_EMBOSS],["hi", $CFM_HIDDEN, $CFE_HIDDEN], _
			["im", $CFM_IMPRINT, $CFE_IMPRINT],["it", $CFM_ITALIC, $CFE_ITALIC], _
			["li", $CFM_LINK, $CFE_LINK],["ou", $CFM_OUTLINE, $CFE_OUTLINE], _
			["pr", $CFM_PROTECTED, $CFE_PROTECTED],["re", $CFM_REVISED, $CFE_REVISED], _
			["sh", $CFM_SHADOW, $CFE_SHADOW],["sm", $CFM_SMALLCAPS, $CFE_SMALLCAPS], _
			["st", $CFM_STRIKEOUT, $CFE_STRIKEOUT],["sb", $CFM_SUBSCRIPT, $CFE_SUBSCRIPT], _
			["sp", $CFM_SUPERSCRIPT, $CFE_SUPERSCRIPT],["un", $CFM_UNDERLINE, $CFE_UNDERLINE], _
			["al", $CFM_ALLCAPS, $CFE_ALLCAPS]]

	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not IsBool($fWord) Then Return SetError(103, 0, False)

	Local $iMask = 0, $iEffects = 0, $n, $s
	For $i = 1 To StringLen($sStatesAndAtts) Step 3
		$s = StringMid($sStatesAndAtts, $i + 1, 2)
		$n = -1
		For $j = 0 To UBound($av) - 1
			If $av[$j][0] = $s Then
				$n = $j
				ExitLoop
			EndIf
		Next
		If $n = -1 Then Return SetError(1023, $s, False) ; not found
		$iMask = BitOR($iMask, $av[$n][1])
		$s = StringMid($sStatesAndAtts, $i, 1)
		Switch $s
			Case "+"
				$iEffects = BitOR($iEffects, $av[$n][2])
			Case "-"
				; do nothing
			Case Else
				Return SetError(1022, $s, False)
		EndSwitch
	Next
	Local $tCharFormat = DllStructCreate($tagCHARFORMAT)
	DllStructSetData($tCharFormat, 1, DllStructGetSize($tCharFormat))
	DllStructSetData($tCharFormat, 2, $iMask)
	DllStructSetData($tCharFormat, 3, $iEffects)
	Local $iWparam = _Iif($fWord, BitOR($SCF_WORD, $SCF_SELECTION), $SCF_SELECTION)
	Local $iRet = _SendMessage($hWnd, $EM_SETCHARFORMAT, $iWparam, $tCharFormat, 0, "wparam", "struct*")
	If Not $iRet Then Return SetError(700, 0, False)
	Return True
EndFunc   ;==>_GUICtrlRichEdit_SetCharAttributes

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_SetCharBkColor
; Description....: Sets the background color of selected text or, if none selected, sets the background color of text inserted at the insertion point
; Syntax ........: _GUICtrlRichEdit_SetCharBkColor($hWnd[, $iColor])
; Parameters.....: $hWnd		- Handle to the control
;                  $iColor - one of the following: (Optional)
;                  |a number - a COLORREF value
;                  |Default keyword - the system color (default)
; Return values..: Success - True
;                  Failure - False and sets @error
;                  |101  - $hWnd is not a handle
;                  |1022 - $iColor is invalid
; Authors........: Chris Haslam (c.haslam)
; Modified ......: jpm
; Remarks .......:
; Related .......: _GUICtrlRichEdit_GetCharBkColor
; Link ..........: @@MsdnLink@@ EM_SETCHARFORMAT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetCharBkColor($hWnd, $iBkColor = Default)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	Local $tCharFormat = DllStructCreate($tagCHARFORMAT2)
	DllStructSetData($tCharFormat, 1, DllStructGetSize($tCharFormat))
	If IsKeyword($iBkColor) Then
		DllStructSetData($tCharFormat, 3, $CFE_AUTOBACKCOLOR)
		$iBkColor = 0
	Else
		If BitAND($iBkColor, 0xff000000) Then Return SetError(1022, 0, False)
	EndIf

	DllStructSetData($tCharFormat, 2, $CFM_BACKCOLOR)
	DllStructSetData($tCharFormat, 12, $iBkColor)
	Local $ai = _GUICtrlRichEdit_GetSel($hWnd)
	If $ai[0] = $ai[1] Then
		Return _SendMessage($hWnd, $EM_SETCHARFORMAT, $SCF_ALL, $tCharFormat, 0, "wparam", "struct*") <> 0
	Else
		Return _SendMessage($hWnd, $EM_SETCHARFORMAT, $SCF_SELECTION, $tCharFormat, 0, "wparam", "struct*") <> 0
	EndIf
EndFunc   ;==>_GUICtrlRichEdit_SetCharBkColor

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_SetCharColor
; Description....: Sets the color of selected text or, if none selected, sets the background color of text inserted at the insertion point
; Syntax ........: _GUICtrlRichEdit_SetCharColor($hWnd[, $iColor])
; Parameters.....: $hWnd		- Handle to the control
;                  $iColor - one of the following: (Optional)
;                  |a number - a COLORREF value
;                  |Default keyword - the system color (default)
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
;                  |1022 - $iColor is invalid
; Authors........: Chris Haslam (c.haslam)
; Modified ......: Jpm
; Remarks .......:
; Related .......: _GUICtrlRichEdit_GetCharColor
; Link ..........: @@MsdnLink@@ EM_SETCHARFORMAT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetCharColor($hWnd, $iColor = Default)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	Local $tCharFormat = DllStructCreate($tagCHARFORMAT)
	DllStructSetData($tCharFormat, 1, DllStructGetSize($tCharFormat))
	If IsKeyword($iColor) Then
		DllStructSetData($tCharFormat, 3, $CFE_AUTOCOLOR)
		$iColor = 0
	Else
		If BitAND($iColor, 0xff000000) Then Return SetError(1022, 0, False)
	EndIf

	DllStructSetData($tCharFormat, 2, $CFM_COLOR)
	DllStructSetData($tCharFormat, 6, $iColor)
	Local $ai = _GUICtrlRichEdit_GetSel($hWnd)
	If $ai[0] = $ai[1] Then
		Return _SendMessage($hWnd, $EM_SETCHARFORMAT, $SCF_ALL, $tCharFormat, 0, "wparam", "struct*") <> 0
	Else
		Return _SendMessage($hWnd, $EM_SETCHARFORMAT, $SCF_SELECTION, $tCharFormat, 0, "wparam", "struct*") <> 0
	EndIf
EndFunc   ;==>_GUICtrlRichEdit_SetCharColor

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_SetBkColor
; Description....: Sets the background color of the control
; Syntax ........: _GUICtrlRichEdit_SetBkColor($hWnd, $vColor = "sys")
; Parameters.....: $hWnd		- Handle to the control
;                  $vColor - one of the following: (Optional)
;                  |a number - a COLORREF value
;                  |Default keyword - the system color (default)
; Return values..: Success - True
;                  Failure - False and sets @error
;                  |101 - $hWnd is not a handle
;                  |1022 - $vColor: value not 0 to 100
; Authors........: Chris Haslam (c.haslam)
; Modified ......: Jpm
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ EM_SETBKGNDCOLOR
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetBkColor($hWnd, $iBngColor = Default)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	Local $fSysColor = False
	If IsKeyword($iBngColor) Then
		$fSysColor = True
		$iBngColor = 0
	Else
		If BitAND($iBngColor, 0xff000000) Then Return SetError(1022, 0, False)
	EndIf

	_SendMessage($hWnd, $EM_SETBKGNDCOLOR, $fSysColor, $iBngColor)
	Return True
EndFunc   ;==>_GUICtrlRichEdit_SetBkColor

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_SetLimitOnText
; Description....: Change number of characters that can be typed, pasted or streamed in as Rich Text Format
; Syntax ........: _GUICtrlRichEdit_SetLimitOnText($hWnd, $iNewLimit)
; Parameters.....: hWnd		- Handle to the control
;                  $iNewLimit - new limit
;                  Special value: 0 - 65,535 characters
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - $iNewLimit is neither a positive number nor zero
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: This function sets the limit on the number of characters a user can type in or paste into a control.
;+
;                  It also limits the number of characters of RTF text that can be streamed in using
;                  _GUICtrlRichEdit_StreamFromFile and _GUICtrlRichEdit_StreamFromVar.
;+
;                  It does not limit the amount of plain text that can be streamed in.
;+
;                  The initial limit is 32,767 characters.
; Related .......: _GUICtrlRichEdit_StreamToFile, _GUICtrlRichEdit_StreamToVar
; Link ..........: @@MsdnLink@@ EM_EXLIMITTEXT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetLimitOnText($hWnd, $iNewLimit)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not __GCR_IsNumeric($iNewLimit, ">=0") Then Return SetError(102, 0, False)

	If $iNewLimit < 65535 Then $iNewLimit = 0 ; default max is 64K
	_SendMessage($hWnd, $EM_EXLIMITTEXT, 0, $iNewLimit)
	Return True
EndFunc   ;==>_GUICtrlRichEdit_SetLimitOnText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRichEdit_SetTabStops
; Description ...: Sets tab stops for the control
; Syntax.........: _GUICtrlRichEdit_SetTabStops($hWnd, $vTabStops[, $fRedraw = True])
; Parameters ....: $hWnd - handle of control
;                  $VTabStops - tab stop(s) to set in space units:
;                  |If a string, semicolon-separated tab stop positions
;                  |If numeric: set a tab stop every <n> space units
;                  $fRedraw - whether to redraw the control - True (default) or False
; Return values .: Success - True
;                : Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
;                  |1021 - $vTabStops is neither a string nor a number
;                  |1022 - $vTabStops is a string but a tab stop in it is not a positive number
;                  |1023 - $vTabStops is an empty string
;                  |1024 - $vTabStops is a number but it is zero or negative
;                  |103  - $fRedraw must be True or False
; Author ........: KIP
; Modified.......: Chris Haslam (c.haslam)
; Remarks .......: Space units are initially inches
;                   To enter a tab into a control, press Ctrl_Tab
; Related .......: _GUICtrlRichEdit_SetParaTabStops, _GUICtrlRichEdit_SetSpaceUnit
; Link ..........: @@MsdnLink@@ EM_SETTABSTOPS
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetTabStops($hWnd, $vTabStops, $fRedraw = True)
	; Should take tabstops in space units (like EM_SETPARAFORMAT PFM_TABSTOPS, but how to convert inches, etc.
	; to dialog units? For now, a kludge based on experimentation
	Local Const $kTwipsPerDU = 18.75
	Local $tTabStops, $tagTabStops = "", $iWparam

	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not IsBool($fRedraw) Then Return SetError(103, 0, False)

	If IsString($vTabStops) Then ; Set every tabstop manually
		If $vTabStops = "" Then Return SetError(103, 0, False)
		Local $as = StringSplit($vTabStops, ";")
		Local $iNumTabStops = $as[0]
		For $i = 1 To $iNumTabStops
			If Not __GCR_IsNumeric($as[$i], ">0") Then Return SetError(1022, 0, False)
			$tagTabStops &= "int;"
		Next
		$tagTabStops = StringTrimRight($tagTabStops, 1)
		$tTabStops = DllStructCreate($tagTabStops)
		For $i = 1 To $iNumTabStops
			DllStructSetData($tTabStops, $i, $as[$i] * $_GRE_TwipsPeSpaceUnit / $kTwipsPerDU)
		Next
		$iWparam = $iNumTabStops
	ElseIf IsNumber($vTabStops) Then
		If __GCR_IsNumeric($vTabStops, ">0") Then
			$tTabStops = DllStructCreate("int")
			DllStructSetData($tTabStops, 1, $vTabStops * $_GRE_TwipsPeSpaceUnit / $kTwipsPerDU)
			$iWparam = 1
		Else
			Return SetError(1024, 9, False)
		EndIf
	Else
		Return SetError(1021, 0, False)
	EndIf
	Local $fResult = _SendMessage($hWnd, $EM_SETTABSTOPS, $iWparam, $tTabStops, 0, "wparam", "struct*") <> 0
	If $fRedraw Then _WinAPI_InvalidateRect($hWnd) ; redraw the control
	Return $fResult
EndFunc   ;==>_GUICtrlRichEdit_SetTabStops

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_SetZoom
; Description....: Sets zoom level of the control
; Syntax ........: _GUICtrlRichEdit_SetZoom($hWnd, $iPercent)
; Parameters.....: $hWnd		- Handle to the control
;                  $iPercent - percentage zoom
;                  |values: 100 and 200 to 6400
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101  - $hWnd is not a handle
;                  |1021 - $iPercent is not a positive number
;                  |1022 - $iPercent neither 100 nor in the range 200 to 6400
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: MSDN claims that EM_SETZOOM works from 1.56% (1/64) to 6400$ (64/1) but testing shows that
;                  it only works reliably for the values shown above
; Related .......: _GUICtrlRichEdit_GetZoom
; Link ..........: @@MsdnLink@@ EM_SETZOOM
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetZoom($hWnd, $iPercent)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not __GCR_IsNumeric($iPercent, ">0") Then Return SetError(1021, 0, False)

	Local $iNumerator, $iDenominator
	Select
		Case Not ($iPercent = 100 Or ($iPercent >= 200 And $iPercent < 6400))
			Return SetError(1022, 0, False)
		Case $iPercent >= 100
			$iNumerator = 10000
			$iDenominator = 10000 / ($iPercent / 100)
		Case Else
			$iNumerator = 10000 * ($iPercent / 100)
			$iDenominator = 10000
	EndSelect
	Return _SendMessage($hWnd, $EM_SETZOOM, $iNumerator, $iDenominator) <> 0
EndFunc   ;==>_GUICtrlRichEdit_SetZoom

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_SetEventMask
; Description....: Specifies which notification messages are sent to the parent window
; Syntax ........: _GUICtrlRichEdit_SetEventMask($hWnd, $iFlags)
; Parameters.....: $hWnd		- Handle to the control
;                  $iEventMask - BitOr combination of :
;                  |$ENM_CHANGE - Sends $EN_CHANGE  notifications (user may have altered text)
;                  |$ENM_CORRECTTEXT - Sends $EN_CORRECTTEXT notifications (parent window can cancel correction of text)
;                  |$ENM_DRAGDROPDONE - Sends $EN_DRAGDROPDONE notifications (drag and drop operation completed)
;                  |$ENM_DROPFILES - Sends $EN_DROPFILES notifications (user is attempting to drop files into the control)
;                  |$ENM_KEYEVENTS - Sends $EN_MSGFILTER notifications for keyboard events
;                  |$ENM_LINK - Sends $EN_LINK notifications when the mouse pointer is over text having the link character
;                  +attribute set and when user clicks the mouse [2.0+]
;                  |$ENM_MOUSEEVENTS - Sends $EN_MSGFILTER notifications for mouse events to parent window
;                  |$ENM_OBJECTPOSITIONS - Sends $EN_OBJECTPOSITIONS notifications when the control reads in objects
;                  |$ENM_PROTECTED - Sends $EN_PROTECTED notifications when the user attempts to change characters having
;                  +the protected attribute set
;                  |$ENM_REQUESTRESIZE - Sends $EN_REQUESTRESIZE notifications that the control's contents are either smaller or
;                  +larger than the control's window size
;                  |$ENM_SCROLL - Sends $EN_HSCROLL and $EN_VSCROLL notifications when the user clicks the horizontal/vertical
;                  +scroll bar
;                  |$ENM_SCROLLEVENTS - Sends EN_MSGFILTER notifications for mouse wheel events
;                  |$ENM_SELCHANGE - Sends EN_SELCHANGE notifications when the current selection changes
;                  |$ENM_UPDATE - Sends EN_UPDATE notifications when a control is about to redraw itself
;                  |or
;                  |$ENM_NONE - Disables sending of notification messages to the parent window
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - $iEventMask is not a number
; Authors........: Yoan Roblet (Arcker)
; Modified ......: Chris Haslam (c.haslam)
; Remarks .......: The number in parentheses indicate which versions mask settings apply to.
;+
;                  $ENM_IMECHANGE only applies to Asian-language versions of Windows
;+
;                  $EN_UPDATE notifications are always sent except for when 4.0 is emulating 1.0
; Related .......: _GUICtrlRichEdit_SetCharAttributes, _GUICtrlRichEdit_GetCharAttributes
; Link ..........: @@MsdnLink@@ EM_SETEVENTMASK
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetEventMask($hWnd, $iEventMask)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not __GCR_IsNumeric($iEventMask) Then Return SetError(102, 0, False)

	_SendMessage($hWnd, $EM_SETEVENTMASK, 0, $iEventMask)
	Return True
EndFunc   ;==>_GUICtrlRichEdit_SetEventMask

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRichEdit_SetFont
; Description ...: Sets the font attributes of selected text or, if none selected, sets those of text inserted at the insertion point
; Syntax.........: _GUICtrlRichEdit_SetFont($hWnd,  $iPoints = Default[, $sName = Default[, $iCharset = Default[, $iLcid = Default]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $iPoints - point size (Optional)
;                  $sName - the name of the font face, e.g. "Courier" not "Courier Bold" (Optional)
;                  $iCharSet -  the character set (Optional) - one of:
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
;                  $iLcid - see http://www.microsoft.com/globaldev/reference/lcid-all.mspx (Optional)
; Return values .: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - $iPoints is not a positive number
;                  |103 - $sName is not alphabetic
;                  |104 - $iLcid is not a number
; Author ........: Chris Haslam (c.haslam)
; Modified.......:
; Remarks .......: If a parameter is omitted (or is Default), the value is unchanged
; Related .......: _GUICtrlRichEdit_GetFont
; Link ..........: @@MsdnLink@@ EM_SETCHARFORMAT, @@MsdnLink@@ LOGFONT, http://www.hep.wisc.edu/~pinghc/books/apirefeng/l/logfont.html
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetFont($hWnd, $iPoints = Default, $sName = Default, $iCharset = Default, $iLcid = Default)
	; MSDN does not give a mask (CFM) for bPitchAndFamily so it appears that it cannot be set => omitted here
	Local $iDwMask = 0

	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not ($iPoints = Default Or __GCR_IsNumeric($iPoints, ">0")) Then Return SetError(102, 0, False)
	If $sName <> Default Then
		Local $as = StringSplit($sName, " ")
		For $i = 1 To UBound($as) - 1
			If Not StringIsAlpha($as[$i]) Then Return SetError(103, 0, False)
		Next
	EndIf
	If Not ($iCharset = Default Or __GCR_IsNumeric($iCharset)) Then Return SetError(104, 0, False)
	If Not ($iLcid = Default Or __GCR_IsNumeric($iLcid)) Then Return SetError(105, 0, False)

	Local $tCharFormat = DllStructCreate($tagCHARFORMAT2)
	DllStructSetData($tCharFormat, 1, DllStructGetSize($tCharFormat))

	If $iPoints <> Default Then
		$iDwMask = $CFM_SIZE
		DllStructSetData($tCharFormat, 4, Int($iPoints * 20))
	EndIf
	If $sName <> Default Then
		If StringLen($sName) > $LF_FACESIZE - 1 Then SetError(-1, 0, False)
		$iDwMask = BitOR($iDwMask, $CFM_FACE)
		DllStructSetData($tCharFormat, 9, $sName)
	EndIf
	If $iCharset <> Default Then
		$iDwMask = BitOR($iDwMask, $CFM_CHARSET)
		DllStructSetData($tCharFormat, 7, $iCharset)
	EndIf
	If $iLcid <> Default Then
		$iDwMask = BitOR($iDwMask, $CFM_LCID)
		DllStructSetData($tCharFormat, 13, $iLcid)
	EndIf
	DllStructSetData($tCharFormat, 2, $iDwMask)

	Local $iRet = _SendMessage($hWnd, $EM_SETCHARFORMAT, $SCF_SELECTION, $tCharFormat, 0, "wparam", "struct*")
	If Not $iRet Then Return SetError(@error + 200, 0, False)
	Return True
EndFunc   ;==>_GUICtrlRichEdit_SetFont

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRichEdit_SetRECT
; Description ...: Sets the formatting rectangle of a control
; Syntax.........: _GUICtrlRichEdit_SetRECT($hWnd [,$iLeft = Default [, $iTop = Default [, $iRight = Default [, $iBottom = Default [, $bRedraw = True]]]]]])
; Parameters ....: $hWnd    - Handle to the control
;                  $iLeft   - Left position in dialog units
;                  $iTop    - Top position in dialog units
;                  $iRight  - Right position in dialog units
;                  $iBottom - Bottom position in dialog unit
; Return values .: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
;                  |1021 - $iLeft is not a positive number
;                  |1022 - $iTop is not a positive number
;                  |1023 - $iRight is not a positive number
;                  |1024 - $iBottom is not a positive number
;                  |1025 - $iLeft >= $iRight
;                  |1026 - $iTop >= $iBottom
; Author ........: Chris Haslam (c.haslam)
; Modified.......: jpm
; Remarks .......: The formatting rectangle is the area in which text is drawn, part of which may not be visible.
;                  Parameters default = no change to previous values
;                  If only $hWnd defined, formatting is reset as at creation time.
; Related .......: _GUICtrlRichEdit_GetRECT
; Link ..........: @@MsdnLink@@ EM_SETRECT
; Example .......:
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetRECT($hWnd, $iLeft = Default, $iTop = Default, $iRight = Default, $iBottom = Default, $bRedraw = True)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not ($iLeft = Default Or __GCR_IsNumeric($iLeft, ">0")) Then Return SetError(1021, 0, False)
	If Not ($iTop = Default Or __GCR_IsNumeric($iTop, ">0")) Then Return SetError(10322, 0, False)
	If Not ($iRight = Default Or __GCR_IsNumeric($iRight, ">0")) Then Return SetError(1023, 0, False)
	If Not ($iBottom = Default Or __GCR_IsNumeric($iBottom, ">0")) Then Return SetError(1024, 0, False)

	If @NumParams = 1 Then
		Local $aPos = ControlGetPos($hWnd, "", "")
		$iLeft = 2
		$iTop = 2
		$iRight = $aPos[2]
		$iBottom = $aPos[3]
		_GUICtrlRichEdit_SetRECT($hWnd, $iLeft, $iTop, $iRight, $iBottom)
		Return True
	Else
		Local $as = _GUICtrlRichEdit_GetRECT($hWnd)
		If $iLeft = Default Then
			$iLeft = $as[0]
		EndIf
		If $iTop = Default Then
			$iTop = $as[1]
		EndIf
		If $iRight = Default Then
			$iRight = $as[2]
		EndIf
		If $iBottom = Default Then
			$iBottom = $as[3]
		EndIf
		If $iLeft >= $iRight Then Return SetError(1025, 0, False)
		If $iTop >= $iBottom Then Return SetError(1026, 0, False)
		Local $tRect = DllStructCreate($tagRECT)
		DllStructSetData($tRect, "Left", Number($iLeft))
		DllStructSetData($tRect, "Top", Number($iTop))
		DllStructSetData($tRect, "Right", Number($iRight))
		DllStructSetData($tRect, "Bottom", Number($iBottom))
		Local $iMsg = _Iif($bRedraw, $EM_SETRECT, $EM_SETRECTNP)
		_SendMessage($hWnd, $iMsg, 0, $tRect, 0, "wparam", "struct*")
	EndIf
	Return True
EndFunc   ;==>_GUICtrlRichEdit_SetRECT

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRichEdit_SetModified
; Description ...: Sets or clears the modification flag
; Syntax.........: _GUICtrlRichEdit_SetModified($hWnd, $fState = True)
; Parameters ....: $hWnd        - Handle to the control
;                  $fState   - Specifies the new value for the modification flag:
;                  | True       - Indicates that the text has been modified (default)
;                  |False       - Indicates it has not been modified.
; Return values .: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - $fState must be True or False
; Author ........: Gary Frost (gafrost)
; Modified.......: Chris Haslam (c.haslam)
; Remarks .......: The system automatically sets the modification flag to False when the control is created.
;                  If the control's text is changed, either by the user or programmatically, the system sets the flag to True
;                  Call _GUICtrlRichEdit_IsModified to retrieve the current state of the flag.
; Related .......: _GUICtrlRichEdit_IsModified
; Link ..........: @@MsdnLink@@ EM_SETMODIFY
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetModified($hWnd, $fState = True)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not IsBool($fState) Then Return SetError(102, 0, False)

	_SendMessage($hWnd, $EM_SETMODIFY, $fState)
	Return True
EndFunc   ;==>_GUICtrlRichEdit_SetModified

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_SetParaAlignment
; Description....: Sets alignment of paragraph(s) in the current selection or, if no selection, of paragraphs inserted at the insertion point
; Syntax ........: _GUICtrlRichEdit_SetParaAlignment($hWnd, $iAlignment)
; Parameters.....: $hWnd		- Handle to the control
;                  $sAlignment - values:
;                  |"l" - align with the left margin.
;                  |"r" - align with the right margin.
;                  |"c" - center between margins
;                  |"j" - justify between margins
;                  |"f" - justify between margins by only expanding spaces
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - invalid $sAlignment
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: In Richedit 2.0, justify does not display
; Related .......: _GUICtrlRichEdit_GetParaAlignment
; Link ..........: @@MsdnLink@@ EM_SETPARAFORMAT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetParaAlignment($hWnd, $sAlignment)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	Local $iAlignment
	Switch $sAlignment
		Case "l"
			$iAlignment = $PFA_LEFT
		Case "c"
			$iAlignment = $PFA_CENTER
		Case "r"
			$iAlignment = $PFA_RIGHT
		Case "j"
			$iAlignment = $PFA_JUSTIFY
		Case "w"
			$iAlignment = $PFA_FULL_INTERWORD
		Case Else
			Return SetError(101, 0, False)
	EndSwitch
	Local $tParaFormat = DllStructCreate($tagPARAFORMAT2)
	DllStructSetData($tParaFormat, 1, DllStructGetSize($tParaFormat))
	DllStructSetData($tParaFormat, 2, $PFM_ALIGNMENT)
	DllStructSetData($tParaFormat, 8, $iAlignment)
	Return _SendMessage($hWnd, $EM_SETPARAFORMAT, 0, $tParaFormat, 0, "wparam", "struct*") <> 0
EndFunc   ;==>_GUICtrlRichEdit_SetParaAlignment

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_SetParaAttributes
; Description....: Sets attributes of paragraph(s) in the current selection or, if no selection, of paragraphs inserted at the insertion point
; Syntax ........: _GUICtrlRichEdit_SetParaAttributes($hWnd, $sStatesAndAtts)
; Parameters.....: $hWnd		- Handle to the control
;                  $sStatesAndAtts -  a string consisting of groups separated by semicolons (;}.
;                  + Each group consists of:
;                  |First character - state:
;                  |   +  -  turn attribute on
;                  |   -  -  turn attribute off
;                  Characters 2 to 4 - attribute
;                  |   "fpg"  -  force this/these paragraphs on to new page(s) (Initially off)
;                  |   "hyp"  -  automatic hypthenation (Initially on)
;                  |   "kpt"  -  keep this/these paragraph(s) together on a page (Initially off}
;                  |   "kpn"  -  keep this/these paragraph(s) and the next together on a page (Initially off)
;                  |   "pwo"  -  prevent widows and orphans, i.e. avoid a single line of this/these paragraphs
;                  +on a page (Initially off)
;                  |   "r2l"  -  display text using right-to-left reading order (Initially off)
;                  |   "row"  -  paragraph(s) is/are table row(s) (Initially off)
;                  |   "sbs"  -  display paragraphs side by side (Initially off)
;                  |   "sln"  -  suppress line numbers in documents or sections with line numbers (Initially off)
; Return values..: Success - True
;                  Failure - False and sets @error
;                  |101  - $hWnd is not a handle
;                  |1021 - a state character in $sStatesAndAtts is invalid. It is in @extended
;                  |1022 - an attribute abbreviation in $sStatesAndAtts is invalid. It is in @extended
;                  |1023 - length of $sStatesAndAtts is invalid
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: Displays results in Word but not in Rich Edit
; Related .......: _GUICtrlRichEdit_GetParaAttributes
; Link ..........: @@MsdnLink@@ EM_SETPARAFORMAT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetParaAttributes($hWnd, $sStatesAndAtts)
	Local Enum $kAbbrev = 0, $kMask, $kEffect, $kInverted
	; MS seems to mean LINENUMBER and WIDOWCONTROL, not NOLINENUMBER and NOWIDOWCONTROL
	Local Const $av[9][4] = [ _	; abbrev, mask, effect, inverted
			["fpg", $PFM_PAGEBREAKBEFORE, $PFE_PAGEBREAKBEFORE, False], _
			["hyp", $PFM_DONOTHYPHEN, $PFE_DONOTHYPHEN, True], _
			["kpt", $PFM_KEEP, $PFE_KEEP, False], _
			["kpn", $PFM_KEEPNEXT, $PFE_KEEPNEXT, False], _
			["pwo", $PFM_NOWIDOWCONTROL, $PFE_NOWIDOWCONTROL, False], _
			["r2l", $PFM_RTLPARA, $PFE_RTLPARA, False], _
			["row", $PFM_TABLE, $PFE_TABLE, False], _
			["sbs", $PFM_SIDEBYSIDE, $PFE_SIDEBYSIDE, False], _
			["sln", $PFM_NOLINENUMBER, $PFE_NOLINENUMBER, False]]

	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	If Mod(StringLen($sStatesAndAtts) + 1, 5) <> 0 Then Return SetError(1023, 0, False)
	Local $as = StringSplit($sStatesAndAtts, ";")
	Local $iMask = 0, $iEffects = 0, $s, $n
	For $i = 1 To UBound($as, 1) - 1
		$s = StringMid($as[$i], 2)
		$n = -1
		For $j = 0 To UBound($av, 1) - 1
			If $av[$j][$kAbbrev] = $s Then
				$n = $j
				ExitLoop
			EndIf
		Next
		If $n = -1 Then Return SetError(1022, $s, False)
		$iMask = BitOR($iMask, $av[$n][$kMask])
		$s = StringLeft($as[$i], 1)
		Switch $s
			Case "+"
				If Not $av[$n][$kInverted] Then ; if normal sense
					$iEffects = BitOR($iEffects, $av[$n][$kEffect])
				EndIf
			Case "-"
				If $av[$n][$kInverted] Then ; if inverted sense
					$iEffects = BitOR($iEffects, $av[$n][$kEffect])
				EndIf
			Case Else
				Return SetError(1021, $s, False)
		EndSwitch
	Next
	Local $tParaFormat = DllStructCreate($tagPARAFORMAT2)
	DllStructSetData($tParaFormat, 1, DllStructGetSize($tParaFormat))
	DllStructSetData($tParaFormat, 2, $iMask)
	DllStructSetData($tParaFormat, 4, $iEffects)
	Return _SendMessage($hWnd, $EM_SETPARAFORMAT, 0, $tParaFormat, 0, "wparam", "struct*") <> 0
EndFunc   ;==>_GUICtrlRichEdit_SetParaAttributes

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_SetParaBorder
; Description....: Sets the border  of paragraph(s) in the current selection or, if no selection, of paragraphs inserted at the insertion point
; Syntax ........: _GUICtrlRichEdit_SetParaBorder($hWnd[, $sLocation[, $vLineStyle[, $sColor[, $iSpace]]]])
; Parameters.....: $hWnd		- Handle to the control
;                  $sLocation (Optional) - a string consisting of any logical combination of:
;                  |   l - left border
;                  |   r - right border
;                  |   t - top border
;                  |   b - bottom border
;                  |   i - inside border
;                  |   o - outside border
;                  |or  ""  - no border  (initial value)
;                  $vLineStyle {Optional) - line style - one of:
;                  |   "none" - no line  (initial value)
;                  |   .75    -  3/4 point
;                  |   1.5    -  1 1/2 points
;                  |   2.25   -  2 1/4 points
;                  |   3      -  3 points
;                  |   4.5    -  4 1/2 points
;                  |   6      -  6 points
;                  |   ".75d" -  1/2 points, double
;                  |   "1.5d" -  1 1/2 points, double
;                  |   "2.25d" - 2 1/4 points, double
;                  |   ".75g"  - 3/4 point grey
;                  |   ".75gd" - 3/4 point grey dashed
;                  $sColor {Optional) - one of:
;                  |   "aut"   - autocolor
;                  |   "blk"   - black  (initial value)
;                  |   "blu"   - blue
;                  |   "cyn"   - cyan
;                  |   "grn"   - green
;                  |   "mag"   - magenta
;                  |   "red"   - red
;                  |   "yel"   - yellow
;                  |   "whi"   - white
;                  |   "dbl"   - dark blue
;                  |   "dgn"   - dark green
;                  |   "dmg"   - dark magenta
;                  |   "drd"   - dark red
;                  |   "dyl"   - dark yellow
;                  |   "dgy"   - dark grey
;                  |   "lgy"   - light grey
;                  $iSpace (Optional) - space between the border and the text (in space units) ( (initial value): 0)
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102  -  value of $sLocation is invalid
;                  |103 -  value of $ivLineStyle is invalid
;                  |104 -  value of $sColor is invalid
;                  |106 - $iSpace is neither a positive number nor zero
;                  |106  -  $iWidth is neither a positive number nor zero
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: To set "space units", call _GUICtrlRichEdit_SetSpaceUnit. Initially inches
;+
;                  If text is selected, the defaults are the values of the first paragraph with text selected.
;                  If none is selected, the defaults are the values of the current paragraph.
;+
;                  To remove a border, call with two parameters: ($hWnd, "")
;+
;                  Borders do not show in Rich Edit, but ones created here should show in Word
; Related .......: _GUICtrlRichEdit_GetParaBorder, _GUICtrlRichEdit_SetSpaceUnit
; Link ..........: @@MsdnLink@@ EM_SETPARAFORMAT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetParaBorder($hWnd, $sLocation = Default, $vLineStyle = Default, $sColor = Default, $iSpace = Default)
	; wBorderWidth doesn't appear to work
	Local $iBorders
	;	Local $tOldParaFormat,$iOldLoc, $iOldSpace, $iOldLineStyle, $iOldColor, $iN
	Local Const $avLocs[6][2] = [["l", 1],["r", 2],["t", 4],["b", 8],["i", 16],["o", 32]]
	Local Const $avLS[12] = ["none", .75, 1.5, 2.25, 3, 4.5, 6, ".75d", "1.5d", "2.25d", ".75g", ".75gd"]
	Local Const $sClrs = ";blk;blu;cyn;grn;mag;red;yel;whi;dbl;dgn;dmg;drd;dyl;dgy;lgy;aut;"

	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not ($iSpace = Default Or __GCR_IsNumeric($iSpace, ">=0")) Then Return SetError(105, 0, False)
	;	If Not ($iWidth = Default Or __GCR_IsNumeric($iWidth, ">=0")) Then  Return SetError(106, 0, False)	; wBorderWidth does not round-trip

	If $sLocation = "" Then
		$iBorders = 0
		$iSpace = 0
		;		$iWidth = 0
	Else
		If $sLocation = Default Or $vLineStyle = Default Or $sColor = Default Or $iSpace = Default Then
			Local $as = StringSplit(_GUICtrlRichEdit_GetParaBorder($hWnd), ";")
			If $sLocation = Default Then $sLocation = $as[1]
			If $vLineStyle = Default Then $vLineStyle = $as[2]
			If $sColor = Default Then $sColor = $as[3]
			If $iSpace = Default Then $iSpace = $as[4]
		EndIf
		Local $iLoc = 0, $n, $s
		For $i = 1 To StringLen($sLocation)
			$s = StringMid($sLocation, $i, 1)
			$n = -1
			For $j = 0 To UBound($avLocs, 1) - 1
				If $avLocs[$j][0] = $s Then
					$n = $j
					ExitLoop
				EndIf
			Next
			If $n = -1 Then Return SetError(102, $s, False)
			$iLoc = BitOR($iLoc, $avLocs[$n][1])
		Next
		$n = -1
		For $i = 0 To UBound($avLS, 1) - 1
			If $vLineStyle = $avLS[$i] Then
				$n = $i
				ExitLoop
			EndIf
		Next
		If $n = -1 Then Return SetError(103, 0, False)
		Local $iLineStyle = $n
		$n = StringInStr($sClrs, ";" & $sColor & ";")
		If $n = 0 Then Return SetError(104, 0, False)
		Local $iColor = Int($n / 4)
		If $iColor = 16 Then ; if autocolor
			$iLoc = BitOR($iLoc, 64)
			$iColor = 0
		EndIf
		$iBorders = $iLoc + BitShift($iLineStyle, -8) + BitShift($iColor, -12)
		;		If $iWidth = Default Then $iWidth = $iOldWidth
	EndIf
	Local $tParaFormat = DllStructCreate($tagPARAFORMAT2)
	DllStructSetData($tParaFormat, "cbSize", DllStructGetSize($tParaFormat))
	DllStructSetData($tParaFormat, "wBorderSpace", $iSpace * $_GRE_TwipsPeSpaceUnit)
	;	DllStructGetData($tParaFormat, 23, $iWidth * $_GRE_TwipsPeSpaceUnit)
	DllStructSetData($tParaFormat, "wBorders", $iBorders)
	DllStructSetData($tParaFormat, "dwMask", $PFM_BORDER)
	Return _SendMessage($hWnd, $EM_SETPARAFORMAT, 0, $tParaFormat, 0, "wparam", "struct*") <> 0
EndFunc   ;==>_GUICtrlRichEdit_SetParaBorder

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_SetParaIndents
; Description....: Sets indents of paragraph(s) in the current selection or, if no selection, of paragraphs inserted at the insertion point
; Syntax ........: _GUICtrlRichEdit_SetParaIndents($hWnd, $vLeft[ = Default, $iRight[ = Default, $iFirstLine[ = Default]]])
; Parameters.....: $hWnd		- Handle to the control
;                  $vLeft - indentation of left side of the body of the paragraph (in space units) (Optional)
;                  | absolute - a number
;                  | relative to previous - a string - "+<number>" or "-<number>"
;                  $iRght - indentation of  right side of the paragraph (in space units) (Optional)
;                  $iFirstLine - indentation of the first line relative to other lines (in space units) (Optional)
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
;                  |1021 - $vLeft is neither a number nor a string consisting of a number
;                  |1022 - $vLeft would start body of paragrpah to left of client area
;                  |103 - $iRight is not a number
;                  |105 - $iFirstLine is not a number
;                  |700 - Operation failed
;                  |200 - First line would be outdented beyond the client area
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: Postive values of $iLeft, $iRight and $iFirstLine indent towards the center of the paragraph
;+
;                  All three values are initially zero.
;+
;                  To set "space units", call _GUICtrlRichEdit_SetSpaceUnit. Initially inches
;+
;                  If text is selected, the defaults are the values of the first paragraph with text selected.
;                  If none is selected, the defaults are the values of the current paragraph.
; Related .......: _GUICtrlRichEdit_GetParaIndents, _GUICtrlRichEdit_SetSpaceUnit
; Link ..........: @@MsdnLink@@ EM_SETPARAFORMAT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetParaIndents($hWnd, $vLeft = Default, $iRight = Default, $iFirstLine = Default)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not ($vLeft = Default Or __GCR_IsNumeric($vLeft)) Then Return SetError(1021, 0, False)
	If Not ($iRight = Default Or __GCR_IsNumeric($iRight, ">=0")) Then Return SetError(103, 0, False)
	If Not ($iFirstLine = Default Or __GCR_IsNumeric($iFirstLine)) Then Return SetError(104, 0, False)

	Local $s = _GUICtrlRichEdit_GetParaIndents($hWnd)
	Local $as = StringSplit($s, ";")
	If $vLeft = Default Then $vLeft = $as[1]
	If $iRight = Default Then $iRight = $as[2]
	If $iFirstLine = Default Then $iFirstLine = $as[3]
	If $vLeft < 0 Then Return SetError(1022, 0, False)
	If $vLeft + $iFirstLine < 0 Then Return SetError(200, 0, False)

	If StringInStr("+-", StringLeft($vLeft, 1)) <> 0 Then $vLeft = $as[1] + $vLeft

	Local $idxSI = $vLeft + $iFirstLine
	Local $iDxOfs = -$iFirstLine

	Local $tParaFormat = DllStructCreate($tagPARAFORMAT)
	DllStructSetData($tParaFormat, 1, DllStructGetSize($tParaFormat))
	DllStructSetData($tParaFormat, "dxStartIndent", $idxSI * $_GRE_TwipsPeSpaceUnit)
	DllStructSetData($tParaFormat, "dxOffset", $iDxOfs * $_GRE_TwipsPeSpaceUnit)
	DllStructSetData($tParaFormat, "dxRightIndent", $iRight * $_GRE_TwipsPeSpaceUnit)
	DllStructSetData($tParaFormat, 2, BitOR($PFM_STARTINDENT, $PFM_OFFSET, $PFM_RIGHTINDENT)) ; absolute
	Local $iRet = _SendMessage($hWnd, $EM_SETPARAFORMAT, 0, $tParaFormat, 0, "wparam", "struct*")
	If Not $iRet Then Return SetError(700, 0, False)
	Return True
EndFunc   ;==>_GUICtrlRichEdit_SetParaIndents

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_SetParaNumbering
; Description....: Sets numbering of paragraph(s) in the current selection or, if no selection, of paragraph(s) inserted at the insertion point
; Syntax ........: _GUICtrlRichEdit_SetParaNumbering($hWnd, $sStyle, $iTextToNbrSpace = Default,$fForceRoman=False)
; Parameters.....: $hWnd		- Handle to the control
;                  $sStyle - a string specifying style and starting "number": e.g. "." (bullet), "1)","(b)", "C.", "iv", "V)"
;                  |   This is the "numbering" that will display for the first paragraph.
;                  |   Trailing spaces indicate the minimum spaces between the number and the paragraph unless iTextToNbrSpace is entered
;                  |   Special cases:
;                  |      "=" - This paragraph is an unnumbered paragraph within the preceding list element
;                  |       "" - removed the numbering from the selected paragraph(s)
;                  $iTextToNbrSpace - space between number/bullet and paragraph (in space units) (Optional)
;                  |Default: number of trailing spaces times point size
;                  $fForceRoman - (Optional)
;                   |True - i, v, x ... in $sStyle is Roman numeral 1, 5, 10 ...
;                  |False - i, v, x ... in $sStyle is letter i, v, x ... {Default)
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - $sStyle is invalid
;                  |103 - $iTextToNbrSpace is not a postive number
;                  |104 - $fForceRoman must be True or False
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: To set "space units", call _GUICtrlRichEdit_SetSpaceUnit. Initially inches
; Related .......: _GUICtrlRichEdit_GetParaNumbering, _GUICtrlRichEdit_SetSpaceUnit
; Link ..........: @@MsdnLink@@ EM_SETPARAFORMAT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetParaNumbering($hWnd, $sStyle, $iTextToNbrSpace = Default, $fForceRoman = False)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not ($iTextToNbrSpace = Default Or __GCR_IsNumeric($iTextToNbrSpace, ">0")) Then Return SetError(103, 0, False)
	If Not IsBool($fForceRoman) Then Return SetError(104, 0, False)

	Local $iPFM, $iWNumbering, $iWnumStart, $iWnumStyle, $iQspaces
	__GCR_ParseParaNumberingStyle($sStyle, $fForceRoman, $iPFM, $iWNumbering, $iWnumStart, $iWnumStyle, $iQspaces)
	If @error Then Return SetError(@error, 0, False)

	Local $tParaFormat = DllStructCreate($tagPARAFORMAT2)
	DllStructSetData($tParaFormat, 1, DllStructGetSize($tParaFormat))
	If BitAND($iPFM, $PFM_NUMBERING) Then DllStructSetData($tParaFormat, 3, $iWNumbering)
	If BitAND($iPFM, $PFM_NUMBERINGSTART) Then DllStructSetData($tParaFormat, 19, $iWnumStart)
	If BitAND($iPFM, $PFM_NUMBERINGSTYLE) Then DllStructSetData($tParaFormat, 20, $iWnumStyle)
	If BitAND($iPFM, $PFM_NUMBERINGTAB) Then
		Local $iTwips
		If $iTextToNbrSpace = Default Then
			; set number-to-text spacing based on font at anchor or onsertion point
			Local $av = _GUICtrlRichEdit_GetFont($hWnd)
			Local $iPoints = $av[0]
			$iTwips = $iQspaces * $iPoints * 20
		Else
			$iTwips = $iTextToNbrSpace * $_GRE_TwipsPeSpaceUnit
		EndIf
		DllStructSetData($tParaFormat, 21, $iTwips)
	EndIf
	DllStructSetData($tParaFormat, 2, $iPFM)
	Return _SendMessage($hWnd, $EM_SETPARAFORMAT, 0, $tParaFormat, 0, "wparam", "struct*") <> 0
EndFunc   ;==>_GUICtrlRichEdit_SetParaNumbering

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_SetParaShading
; Description....: Sets the shading of paragraph(s) in the current selection or, if no selection, of paragraphs inserted at the insertion point
; Syntax ........: _GUICtrlRichEdit_SetParaShading($hWnd, $iWeight[ = Default, $sStyle[ = Default, $sForeColor[ = Default, $sBackColor[ = Default]]]])
; Parameters.....: $hWnd		- Handle to the control
;                  $iWeight (Optional) - percent of foreground color, the rest being background color
;                  $sStyle {Optional) - shading style - a string containing one of the following:
;                  |   non - none
;                  |   dhz - dark horizontal
;                  |   dvt - dark vertical
;                  |   ddd - dark down diagonal
;                  |   dud - dark up diagonal
;                  |   dgr - dark grid
;                  |   dtr - dark trellis
;                  |   lhz - light horizontal
;                  |   lvt - light vertical
;                  |   ldd - light down diagonal
;                  |   lud - light up diagonal
;                  |   lgr - light grid
;                  |   ltr - light trellis
;                  $sForeColour (Optional) - one of the following:
;                  |   "blk"   - black  (initial value)
;                  |   "blu"   - blue
;                  |   "cyn"   - cyan
;                  |   "grn"   - green
;                  |   "mag"   - magenta
;                  |   "red"   - red
;                  |   "yel"   - yellow
;                  |   "whi"   - white
;                  |   "dbl"   - dark blue
;                  |   "dgn"   - dark green
;                  |   "dmg"   - dark magenta
;                  |   "drd"   - dark red
;                  |   "dyl"   - dark yellow
;                  |   "dgy"   - dark grey
;                  |   "lgy"   - light grey
;                  $sBackColor (Optional) - same values as for $sForeColor
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101  - $hWnd is not a handle
;                  |1021 - $iWeight is not a positive number
;                  |1022 -  value of $iWeight is invalid
;                  |103  -  value of $sStyle is invalid
;                  |104  -  value of $sForeColor is invalid
;                  |105  -  value of $sBackColor is invalid
;                  |700  -  operation failed
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: If text is selected, the defaults are the values of the first paragraph with text selected.
;                  If none is selected, the defaults are the values of the current paragraph.
;+
;                  Shading does not show in Rich Edit, but shading created here will show in Word
; Related .......: _GUICtrlRichEdit_GetParaShading
; Link ..........: @@MsdnLink@@ EM_SETPARAFORMAT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetParaShading($hWnd, $iWeight = Default, $sStyle = Default, $sForeColor = Default, $sBackColor = Default)
	Local $iS = 0 ; perhaps a BUG (jpm) only referenced
	Local Const $sStyles = ";non;dhz;dvt;ddd;dud;dgr;dtr;lhz;lrt;ldd;lud;lgr;ltr;"
	Local Const $sClrs = ";blk;blu;cyn;grn;mag;red;yel;whi;dbl;dgn;dmg;drd;dyl;dgy;lgy;"

	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not ($iWeight = Default Or __GCR_IsNumeric($iWeight, ">=0")) Then Return SetError(1021, 0, False)

	If $iWeight <> Default Or $sStyle <> Default Or $sForeColor <> Default Or $sBackColor <> Default Then
		Local $as = StringSplit(_GUICtrlRichEdit_GetParaShading($hWnd), ";")
		If $iWeight = Default Then $iWeight = $as[1]
		If $sStyle = Default Then $sStyle = $as[2]
		If $sForeColor = Default Then $sForeColor = $as[3]
		If $sBackColor = Default Then $sBackColor = $as[4]
		#cs
			$tOldParaFormat = DllStructCreate($tagPARAFORMAT2)
			DllStructSetData($tOldParaFormat, 1, DllStructGetSize($tOldParaFormat))
			_SendMessage($hWnd, $EM_GETPARAFORMAT, 0, DllStructGetPtr($tOldParaFormat))
		#ce
	EndIf
	;	If $iWeight = Default Then
	;		$iWeight = DllStructGetData($tOldParaFormat, 17)
	;	Else
	If $iWeight < 0 Or $iWeight > 100 Then Return SetError(1022, 0, False)
	;	EndIf
	;	If $sStyle = Default Or $sForeColor = Default Or $sBackColor = Default Then
	;		$iS = DllStructGetData($tOldParaFormat, 18)
	;	EndIf
	;	If $sStyle = Default Then
	;		$iStyle = BitAND($iS, 0xF)
	;	Else
	Local $iN = StringInStr($sStyles, ";" & $sStyle & ";")
	If $iN = 0 Then Return SetError(103, 0, False)
	Local $iStyle = Int($iN / 4)
	;	EndIf
	;	If $sForeColor = Default Then
	Local $iFore = BitShift(BitAND($iS, 0xF0), 4)
	;	Else
	$iN = StringInStr($sClrs, ";" & $sForeColor & ";")
	If $iN = 0 Then Return SetError(104, 0, False)
	$iFore = Int($iN / 4)
	;	EndIf
	;	If $sBackColor = Default Then
	;		$iBack = BitShift(BitAND($iS, 0xF00), 8)
	;	Else
	$iN = StringInStr($sClrs, ";" & $sBackColor & ";")
	If $iN = 0 Then Return SetError(105, 0, False)
	Local $iBack = Int($iN / 4)
	;	EndIf
	Local $tParaFormat = DllStructCreate($tagPARAFORMAT2)
	DllStructSetData($tParaFormat, "cbSize", DllStructGetSize($tParaFormat))
	DllStructSetData($tParaFormat, "wShadingWeight", $iWeight)
	$iN = $iStyle + BitShift($iFore, -4) + BitShift($iBack, -8)
	DllStructSetData($tParaFormat, "wShadingStyle", $iN)
	DllStructSetData($tParaFormat, "dwMask", $PFM_SHADING)
	Local $iRet = _SendMessage($hWnd, $EM_SETPARAFORMAT, 0, $tParaFormat, 0, "wparam", "struct*")
	If Not $iRet Then Return SetError(700, 0, False)
	Return True
EndFunc   ;==>_GUICtrlRichEdit_SetParaShading

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_SetParaSpacing
; Description....: Sets paragraph spacing of paragraphs having selected text or, if none selected, sets it for text inserted at the insertion point
; Syntax ........: _GUICtrlRichEdit_SetParaSpacing($hWnd, [$vInter=Default[, $iBefore=Default[, $iAfter=Default]]])
; Parameters.....: $hWnd		- Handle to the control
;                  $vInter - spacing between lines: (Optional)
;                  |either: a number - in space units
;                  |or: "<number> lines" - in lines
;                  $iBefore - spacing before paragraph(s) (in space units) (Optional)
;                  $iAfter  - spacing after paragraph(s) (in space units) (Optional)
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101  - $hWnd is not a handle
;                  |1021 - $vInter is invalid
;                  |1022 - Only 1, 1.5 and 2 line spacing can be set via "<n> lines"
;                  |103  - $iBefore is neither a positive number nor zero
;                  |104  - $iAfter is neither a positive number nor zero
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: Only settings which are not defaulted are set
;+
;                  To set "space units", call _GUICtrlRichEdit_SetSpaceUnit. Initially inches
; Related .......: _GUICtrlRichEdit_GetParaSpacing, _GUICtrlRichEdit_SetSpaceUnit
; Link ..........: @@MsdnLink@@ EM_SETPARAFORMAT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetParaSpacing($hWnd, $vInter = Default, $iBefore = Default, $iAfter = Default)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not ($iBefore = Default Or __GCR_IsNumeric($iBefore, ">=0")) Then Return SetError(103, 0, False)
	If Not ($iAfter = Default Or __GCR_IsNumeric($iAfter, ">=0")) Then Return SetError(104, 0, False)

	Local $tParaFormat = DllStructCreate($tagPARAFORMAT2)
	DllStructSetData($tParaFormat, "cbSize", DllStructGetSize($tParaFormat))
	Local $iMask = 0
	If $vInter <> Default Then
		$vInter = StringStripWS($vInter, 8) ; strip all spaces
		Local $iP = StringInStr($vInter, "line", 2) ; case-insensitive, faster
		If $iP <> 0 Then
			$vInter = StringLeft($vInter, $iP - 1)
		EndIf
		If Not __GCR_IsNumeric($vInter, ">=0") Then Return SetError(1021, 0, False)
		Local $iRule, $iLnSp = 0
		If $iP <> 0 Then ; if in lines
			Switch $vInter
				Case 1
					$iRule = 0
				Case 1.5
					$iRule = 1
				Case 2
					$iRule = 2
				Case Else
					If $vInter < 1 Then Return SetError(1022, 0, False)
					$iRule = 5 ; spacing in lines
					$iLnSp = $vInter * 20
			EndSwitch
		Else
			$iRule = 4 ; spacing in twips
			$iLnSp = $vInter * $_GRE_TwipsPeSpaceUnit
		EndIf
		$iMask = $PFM_LINESPACING
		DllStructSetData($tParaFormat, "bLineSpacingRule", $iRule)
		If $iLnSp <> 0 Then DllStructSetData($tParaFormat, 13, $iLnSp)
	EndIf
	If $iBefore <> Default Then
		$iMask = BitOR($iMask, $PFM_SPACEBEFORE)
		DllStructSetData($tParaFormat, "dySpaceBefore", $iBefore * $_GRE_TwipsPeSpaceUnit)
	EndIf
	If $iAfter <> Default Then
		$iMask = BitOR($iMask, $PFM_SPACEAFTER)
		DllStructSetData($tParaFormat, "dySpaceAfter", $iAfter * $_GRE_TwipsPeSpaceUnit)
	EndIf
	If $iMask <> 0 Then
		DllStructSetData($tParaFormat, "dwMask", $iMask)
		Return _SendMessage($hWnd, $EM_SETPARAFORMAT, 0, $tParaFormat, 0, "wparam", "struct*") <> 0
	Else
		Return True
	EndIf
EndFunc   ;==>_GUICtrlRichEdit_SetParaSpacing

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_SetParaTabStops
; Description....: Sets tab stops  of paragraphs having selected text or, if none selected, sets it for text inserted at the insertion point
; Syntax ........: _GUICtrlRichEdit_SetParaTabStops($hWnd, $sTabStops)
; Parameters.....: $hWnd		- Handle to the control
;                  $sTabStops - A string consisting of groups separated by ; (semicolon). Format of a group:
;                  | absolute position of a tab stop (in space units)
;                  | kind of tab
;                  |   l - left tab
;                  |   c - center tab
;                  |   r - decimal tab
;                  |   b - bar tab
;                  | kind of dot leader
;                  |   . - dotted leader
;                  |   - - dashed leader
;                  |   _ - underline leader
;                  |   = - double line leader
;                  |   t - thick-line leader
;                  |   a space - no leader
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
;                  |1021 - absolute position of a tab stop missing or invalid
;                  |1022 - kind of tab missing or invalid
;                  |1023 - kind of tab leader missing or invalid
;                  |1024 - attempt to set too many tab stops
;                  |   @extended contains the tab number (ref 1) in $sTabStops where the error occurred.
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: To reset the tab stops, do _GUICtrlRichEdit_SetParaTabStops($hWnd, "")
;+
;                  To set "space units", call _GUICtrlRichEdit_SetSpaceUnit. Initially inches
;+
;                  To enter a tab into a control, press Ctrl_Tab
; Related .......: _GUICtrlRichEdit_GetParaTabStops, _GUICtrlRichEdit_SetSpaceUnit
; Link ..........: @@MsdnLink@@ EM_SETCHARFORMAT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetParaTabStops($hWnd, $sTabStops)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	Local $tParaFormat = DllStructCreate($tagPARAFORMAT2)
	DllStructSetData($tParaFormat, "cbSize", DllStructGetSize($tParaFormat))

	If $sTabStops = "" Then
		DllStructSetData($tParaFormat, "cTabCount", 0)
	Else
		Local $asTabs = StringSplit($sTabStops, ";")
		If $asTabs[0] > $MAX_TAB_STOPS Then Return SetError(1021, 0, False)
		Local $asAtab, $i, $s, $iN, $iP
		For $iTab = 1 To $asTabs[0]
			$asAtab = StringSplit($asTabs[$iTab], "") ; split into characters
			$i = 1
			While $i <= $asAtab[0] And StringInStr("01234567890.", $asAtab[$i]) <> 0
				$i += 1
			WEnd
			If $i = 1 Then Return SetError(1021, $iTab, False)
			$s = StringLeft($asTabs[$iTab], $i - 1)
			If Not __GCR_IsNumeric($s, ">=0") Then Return SetError(1021, $iTab, False)
			$iN = $s * $_GRE_TwipsPeSpaceUnit
			If $i <= $asAtab[0] Then
				$iP = StringInStr("lcrdb", $asAtab[$i])
				If $iP = 0 Then Return SetError(1022, $iTab, False)
				$iN = BitOR($iN, BitShift($iP - 1, -24))
			EndIf
			$i += 1
			If $i <= $asAtab[0] Then
				$iP = StringInStr(" .-_t=", $asAtab[$i])
				If $iP = 0 Then Return SetError(1023, $iTab, False)
				$iN = BitOR($iN, BitShift($iP - 1, -28))
			EndIf
			DllStructSetData($tParaFormat, "rgxTabs", $iN, $iTab)
		Next
		DllStructSetData($tParaFormat, "cTabCount", $asTabs[0])
	EndIf
	DllStructSetData($tParaFormat, "dwMask", $PFM_TABSTOPS)
	Return _SendMessage($hWnd, $EM_SETPARAFORMAT, 0, $tParaFormat, 0, "wparam", "struct*") <> 0
EndFunc   ;==>_GUICtrlRichEdit_SetParaTabStops

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRichEdit_SetPasswordChar
; Description ...: Sets the characters to be displayed instead of those typed, or causes typed characters to show
; Syntax.........: _GUICtrlRichEdit_SetPasswordChar($hWnd[, $cDisplayChar = "0"])
; Parameters ....: $hWnd         - Handle to the control
;                  $cDisplayChar - The character to be displayed in place of the characters typed by the user.
;                  |Special value: "" - characters typed are displayed
; Return values .: Succcess - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - $cDisplayChar is not a character
; Author ........: Gary Frost
; Modified.......: Chris Haslam (c.haslam)
; Remarks .......:
; Related .......: _GUICtrlRichEdit_GetPasswordChar
; Link ..........: @@MsdnLink@@ EM_SETPASSWORDCHAR
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetPasswordChar($hWnd, $cDisplayChar)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not IsString($cDisplayChar) Then SetError(102, 0, False)

	If $cDisplayChar = "" Then
		_SendMessage($hWnd, $EM_SETPASSWORDCHAR)
	Else
		_SendMessage($hWnd, $EM_SETPASSWORDCHAR, Asc($cDisplayChar))
	EndIf
	Return True
EndFunc   ;==>_GUICtrlRichEdit_SetPasswordChar

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRichEdit_SetReadOnly
; Description ...: Sets or removes the read-only state
; Syntax.........: _GUICtrlRichEdit_SetReadOnly($hWnd[, $fState = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $fState   - one of the following values:
;                  |True       - Sets control to read-only (default)
;                  |False      - Sets control to read-write
; Return values .: Success      - True
;                  Failure      - False and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - $fState is neither true nor false
;                  |700 - operation failed
; Author ........: Gary Frost (gafrost)
; Modified.......: Chris Haslam (c.haslam)
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ EM_SETREADONLY
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetReadOnly($hWnd, $fState = True)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not IsBool($fState) Then Return SetError(102, 0, False)

	Local $iRet = _SendMessage($hWnd, $EM_SETREADONLY, $fState)
	If $iRet = 0 Then Return SetError(700, 0, False)
	Return True
EndFunc   ;==>_GUICtrlRichEdit_SetReadOnly

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_SetScrollPos
; Description....: Scrolls the display such that ($ix,$iY) is in the upper left corner of the control
; Syntax ........: _GUICtrlRichEdit_SetScrollPos($hWnd, $iX, $iY)
; Parameters.....: $hWnd		- Handle to the control
;                  $iX - x coorindate (in pixels)
;                  $iY - y coorindate (in pixels)
; Return values..: Success - True
;                  Failure - False and sets @error
;                  |101 - $hWnd is not a handle
;                  |102 - $iX is neither a positive number nor zero
;                  |103 - $iY is neither a positive number nor zero
; Authors........: Prog@ndy
; Modified ......: Chris Haslam (c.haslam)
; Remarks .......: Never scrolls the text completely off the view rectangle
; Related .......:
; Link ..........: @@MsdnLink@@ EM_SETSCROLLPOS
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetScrollPos($hWnd, $iX, $iY)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not __GCR_IsNumeric($iX, ">=0") Then Return SetError(102, 0, False)
	If Not __GCR_IsNumeric($iY, ">=0") Then Return SetError(103, 0, False)

	Local $tPoint = DllStructCreate($tagPOINT)
	DllStructSetData($tPoint, 1, $iX)
	DllStructSetData($tPoint, 2, $iY)
	Return _SendMessage($hWnd, $EM_SETSCROLLPOS, 0, $tPoint, 0, "wparam", "struct*") <> 0
EndFunc   ;==>_GUICtrlRichEdit_SetScrollPos

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRichEdit_SetSel
; Description ...: Sets the low and high character position of a selection
; Syntax.........: _GUICtrlRichEdit_SetSel($hWnd, $iAnchor, $iActive[, $fHideSel = False])
; Parameters ....: $hWnd        - Handle to the control
;                  $iAnchor -  the character position of the first character to select
;                  |Special value: -1 - end of text
;                  $iActive -  the character position of the last character to select
;                  |Special value: -1 - end of text
; Return values .: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - $iAnchor is neither a positive number nor zero nor -1
;                  |103 - $iActive is neither a positive number nor zero nor -1
;                  |104 - $fHideSel must be True or False
; Author ........: Chris Haslam (c.haslam)
; Modified.......: jpm
; Remarks .......: The first character of the text in a control is at character position 1
;+
;                  $iActive can be less than $iAnchor
; Related .......: _GUICtrlRichEdit_GetSel, _GUICtrlRichEdit_Deselect, _GUICtrlRichEdit_IsTextSelected, _GUICtrlRichEdit_GotoCharPos
; Link ..........: @@MsdnLink@@ EM_EXSETSEL
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetSel($hWnd, $iAnchor, $iActive, $fHideSel = False)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not __GCR_IsNumeric($iAnchor, ">=0,-1") Then Return SetError(102, 0, False)
	If Not __GCR_IsNumeric($iActive, ">=0,-1") Then Return SetError(103, 0, False)
	If Not IsBool($fHideSel) Then Return SetError(104, 0, False)
	_SendMessage($hWnd, $EM_SETSEL, $iAnchor, $iActive)
	If $fHideSel Then _SendMessage($hWnd, $EM_HIDESELECTION, $fHideSel)
	_WinAPI_SetFocus($hWnd) ; need to have the selection updated
	Return True
EndFunc   ;==>_GUICtrlRichEdit_SetSel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRichEdit_SetSpaceUnit
; Description ...: Gets the unit of measure of horizontal and vertical space used in parameters of various _GUICtrlRichEdit functions
; Syntax.........: _GUICtrlRichEdit_SetSpaceUnit()
; Parameters ....: $sUnit - "in", "cm", "mm", "pt" (points), or "tw" (twips, 1/1440 inches, 1/567 centimetres
; Return values .: Success - True
;                  Failure - False and sets @error to 1
; Author ........: Chris Haslam (c.haslam)
; Modified.......:
; Remarks .......: Initially, space is measured in inches
; Related .......: _GUICtrlRichEdit_GetSpaceUnit
; Link ..........:
; Example .......: Yes
; ==================================================================================================================================================
Func _GUICtrlRichEdit_SetSpaceUnit($sUnit)
	Switch StringLower($sUnit)
		Case "in"
			$_GRE_TwipsPeSpaceUnit = 1440
		Case "cm"
			$_GRE_TwipsPeSpaceUnit = 567
		Case "mm"
			$_GRE_TwipsPeSpaceUnit = 56.7
		Case "pt"
			$_GRE_TwipsPeSpaceUnit = 20
		Case "tw"
			$_GRE_TwipsPeSpaceUnit = 1
		Case Else
			Return SetError(1, 0, False)
	EndSwitch
	Return True
EndFunc   ;==>_GUICtrlRichEdit_SetSpaceUnit

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_SetText
; Description....: Sets the text of a control
; Syntax ........: _GUICtrlRichEdit_SetText($hWnd, $sText)
; Parameters.....: hWnd		- Handle to the control
;                  $sText         - Plain or RTF text to put into the control
; Return values..: Succcess - True
;                  |Failure - False, and sets @error:
;                  |101 - $hWnd is not a handle
; Authors........: Gary Frost (gafrost (custompcs@charter.net))
; Modified ......: Prog@ndy, Chris Haslam (c.haslam)
; Remarks .......: Sets all of the text
;                  |Text can be plain or RTF text
;                  |Keeps the undo stack
; Related .......: _GUICtrlRichEdit_GetText, _GUICtrlRichEdit_AppendText, _GUICtrlRichEdit_InsertText, _GUICtrlRichEdit_ReplaceText, _GUICtrlRichEdit_EmptyUndoBuffer
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetText($hWnd, $sText)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	Local $tSetText = DllStructCreate($tagSETTEXTEX)
	;	DllStructSetData($tSetText, 1, $ST_KEEPUNDO)
	DllStructSetData($tSetText, 1, $ST_DEFAULT)
	DllStructSetData($tSetText, 2, $CP_ACP)
	Local $iRet
	If StringLeft($sText, 5) <> "{\rtf" And StringLeft($sText, 5) <> "{urtf" Then
		DllStructSetData($tSetText, 2, $CP_UNICODE)
		$iRet = _SendMessage($hWnd, $EM_SETTEXTEX, $tSetText, $sText, 0, "struct*", "wstr")
	Else
		$iRet = _SendMessage($hWnd, $EM_SETTEXTEX, $tSetText, $sText, 0, "struct*", "STR")
	EndIf
	If Not $iRet Then Return SetError(700, 0, False)
	Return True
EndFunc   ;==>_GUICtrlRichEdit_SetText

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_SetUndoLimit
; Description....: Sets the maximum number of actions that can stored in the undo queue
; Syntax ........: _GUICtrlRichEdit_SetUndoLimit($hWnd, $iLimit)
; Parameters.....: $hWnd		- Handle to the control
;                  $iLimit - the maximum number of actions that can be stored in the undo queue
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
;                  |102 - $iLimit is neither a positive number nor zero
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: To disable the Undo feature, set $iLimit to zero
;+
;                  The initial value of $iLimit is 100.
; Related .......: _GUICtrlRichEdit_Undo, _GUICtrlRichEdit_CanRedo, _GUICtrlRichEdit_CanUndo, _GUICtrlRichEdit_GetNextRedo, _GUICtrlRichEdit_Redo
; Link ..........: @@MsdnLink@@ EM_SETUNDOLIMIT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_SetUndoLimit($hWnd, $iLimit)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	If Not __GCR_IsNumeric($iLimit, ">=0") Then Return SetError(102, 0, False)

	Return _SendMessage($hWnd, $EM_SETUNDOLIMIT, $iLimit) <> 0 Or $iLimit = 0
EndFunc   ;==>_GUICtrlRichEdit_SetUndoLimit

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_StreamFromFile
; Description....: Sets text in a control from a file
; Syntax ........: _GUICtrlRichEdit_StreamFromFile($hWnd, $sFilespec)
; Parameters.....: $hWnd		- Handle to the control
;                  $sFileSpec - file specification
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
;                  |1021 - unable to open $sFilespec
;                  |1022 - file is empty
;                  |700  - attempt to stream in too many characters
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: If text is selected, replaces selection, else replaces all text in the control
;+
;                  Call _GUICtrlRichEdit_SetLimitonText to increase the number of characters the control can contain
; Related .......: _GUICtrlRichEdit_SetLimitOnText, _GUICtrlRichEdit_StreamFromVar, _GUICtrlRichEdit_StreamToFile
; Link ..........: @@MsdnLink@@ EM_STREAMIN
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_StreamFromFile($hWnd, $sFilespec)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	Local $tEditStream = DllStructCreate($tagEDITSTREAM)
	DllStructSetData($tEditStream, "pfnCallback", DllCallbackGetPtr($_GRC_StreamFromFileCallback))
	Local $hFile = FileOpen($sFilespec, 0) ; read
	If $hFile = -1 Then Return SetError(1021, 0, False)
	Local $buf = FileRead($hFile, 5)
	FileClose($hFile)
	$hFile = FileOpen($sFilespec, 0) ; read           reopen it at the start
	DllStructSetData($tEditStream, "dwCookie", $hFile) ; -> Send handle to CallbackFunc
	Local $iWparam = _Iif($buf == "{\rtf" Or $buf == "{urtf", $SF_RTF, $SF_TEXT)
	$iWparam = BitOR($iWparam, $SFF_SELECTION)
	If Not _GUICtrlRichEdit_IsTextSelected($hWnd) Then
		_GUICtrlRichEdit_SetText($hWnd, "")
	EndIf
	Local $iQchs = _SendMessage($hWnd, $EM_STREAMIN, $iWparam, $tEditStream, 0, "wparam", "struct*")
	FileClose($hFile)
	Local $iError = DllStructGetData($tEditStream, "dwError")
	If $iError <> 1 Then SetError(700, $iError, False)
	If $iQchs = 0 Then
		If FileGetSize($sFilespec) = 0 Then Return SetError(1022, 0, False)
		Return SetError(700, $iError, False)
	EndIf
	Return True
EndFunc   ;==>_GUICtrlRichEdit_StreamFromFile

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_StreamFromVar
; Description....: Sets text in a control from a variable
; Syntax ........: _GUICtrlRichEdit_StreamFromVar($hWnd, $sVar)
; Parameters.....: $hWnd		- Handle to the control
;                  $sVar - a string
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101 - $hWnd is not a handle
;                  |700  - attempt to stream in too many characters
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: If text is selected, replaces selection, else replaces all text in the control
;+
;                  Call _GUICtrlRichEdit_SetLimitonText to increase the number of characters the control can contain
; Related .......: _GUICtrlRichEdit_SetLimitOnText, _GUICtrlRichEdit_StreamFromFile, _GUICtrlRichEdit_StreamToVar
; Link ..........: @@MsdnLink@@ EM_STREAMIN
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_StreamFromVar($hWnd, $sVar)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	Local $tEditStream = DllStructCreate($tagEDITSTREAM)
	DllStructSetData($tEditStream, "pfnCallback", DllCallbackGetPtr($_GRC_StreamFromVarCallback))
	$_GRC_sStreamVar = $sVar
	Local $s = StringLeft($sVar, 5)
	Local $iWparam = _Iif($s == "{\rtf" Or $s == "{urtf", $SF_RTF, $SF_TEXT)
	$iWparam = BitOR($iWparam, $SFF_SELECTION)
	If Not _GUICtrlRichEdit_IsTextSelected($hWnd) Then
		_GUICtrlRichEdit_SetText($hWnd, "")
	EndIf
	_SendMessage($hWnd, $EM_STREAMIN, $iWparam, $tEditStream, 0, "wparam", "struct*")
	Local $iError = DllStructGetData($tEditStream, "dwError")
	If $iError <> 1 Then Return SetError(700, $iError, False)
	Return True
EndFunc   ;==>_GUICtrlRichEdit_StreamFromVar

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_StreamToFile
; Description....: Writes contens of a control to a file
; Syntax ........: _GUICtrlRichEdit_StreamToFile($hWnd, $sFilespec[, $fIncludeCOM=True[, $iOpts=0[, $iCodePage = 0]]])
; Parameters.....: $hWnd		- Handle to the control
;                  $sFileSpec - file specification
;                  $fIncludeCOM - (Optional)
;                  |True (default):
;                  |    If writing to a .rtf file, includes any COM objects (space consuming)
;                  |    If writing to any other file, writes a text represntation of COM objects
;                  |False: Writes spaces instead of COM objects
;                  $iOpts - additional options: (Optional) (default: 0)
;                  |$SFF_PLAINTRTF - write only rich text keywords common to all languages
;                  |$SF_UNICODE    - write Unicode
;                  $iCodePage - Generate UTF-8 and text using this code page (Optional)
;                  |Default: do not
; Return values..: Success - True
;                  Failure - False and sets @error:
;                  |101  - $hWnd is not a handle
;                  |102  - Can't create $sFilespec
;                  |1041 - $SFF_PLAINRTF is invalid for a text file
;                  |1042 - $opts: invalid option
;                  |1043 - $SF_UNICODE is only valid for a text file
;                  |700  - internal error
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: If text is selected, writes only the selection, else writes all text in the control
;+
;                  If the extension in $sFileSpec is .rtf, RTF is written, else text
; Related .......: _GUICtrlRichEdit_SetLimitOnText, _GUICtrlRichEdit_StreamFromVar, _GUICtrlRichEdit_StreamToFile
; Link ..........: @@MsdnLink@@ EM_STREAMIN
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_StreamToFile($hWnd, $sFilespec, $fIncludeCOM = True, $iOpts = 0, $iCodePage = 0)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)

	Local $iWparam
	If StringRight($sFilespec, 4) = ".rtf" Then
		$iWparam = _Iif($fIncludeCOM, $SF_RTF, $SF_RTFNOOBJS)
	Else
		$iWparam = _Iif($fIncludeCOM, $SF_TEXTIZED, $SF_TEXT)
		If BitAND($iOpts, $SFF_PLAINRTF) Then Return SetError(1041, 0, False)
	EndIf
	; only opts are $SFF_PLAINRTF and $SF_UNICODE
	If BitAND($iOpts, BitNOT(BitOR($SFF_PLAINRTF, $SF_UNICODE))) Then Return SetError(1042, 0, False)
	If BitAND($iOpts, $SF_UNICODE) Then
		If Not BitAND($iWparam, $SF_TEXT) Then Return SetError(1043, 0, False)
	EndIf

	If _GUICtrlRichEdit_IsTextSelected($hWnd) Then $iWparam = BitOR($iWparam, $SFF_SELECTION)

	$iWparam = BitOR($iWparam, $iOpts)
	If $iCodePage <> 0 Then
		$iWparam = BitOR($iWparam, $SF_USECODEPAGE, BitShift($iCodePage, -16))
	EndIf
	Local $tEditStream = DllStructCreate($tagEDITSTREAM)
	DllStructSetData($tEditStream, "pfnCallback", DllCallbackGetPtr($_GRC_StreamToFileCallback))
	Local $hFile = FileOpen($sFilespec, 2) ; overwrite
	If $hFile - 1 Then Return SetError(102, 0, False)

	DllStructSetData($tEditStream, "dwCookie", $hFile) ; -> Send handle to CallbackFunc
	_SendMessage($hWnd, $EM_STREAMOUT, $iWparam, $tEditStream, 0, "wparam", "struct*")
	FileClose($hFile)
	Local $iError = DllStructGetData($tEditStream, "dwError")
	If $iError <> 0 Then SetError(700, $iError, False)
	Return True
EndFunc   ;==>_GUICtrlRichEdit_StreamToFile

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_StreamToVar
; Description....: Writes contents of a control to a variable
; Syntax ........: _GUICtrlRichEdit_StreamToVar($hWnd, $fRtf = True[, $fIncludeCOM=True[, $iOpts=0[, $iCodePage = 0]]])
; Parameters.....: $hWnd		- Handle to the control
;                  $fRtf - (Optional)
;                  |True  - write Rich Text Format (RTF) (Default)
;                  |False - write only text
;                  $fIncludeCOM - (Optional)
;                  |True (default):
;                  |    If writing RTF, include any COM objects (space consuming)
;                  |    If writing only text, write a text represntation of COM objects
;                  |False: Write spaces instead of COM objects
;                  $iOpts - additional options:
;                  |$SFF_PLAINTRTF - write only rich text keywords common to all languages
;                  |$SF_UNICODE    - write Unicode
;                  $iCodePage - Generate UTF-8 and text using this code page (Optional)
;                  |Default: do not
; Return values..: Success - the RTF or text
;                  Failure - "" and sets @error:
;                  |101 - $hWnd is not a handle
;                  |1041 - $SFF_PLAINRTF is invalid for a text file
;                  |1042 - $opts: invalid option
;                  |1043 - $SF_UNICODE is only valid for a text file
;                  |700  - internal error
; Authors........: Chris Haslam (c.haslam)
; Modified ......:
; Remarks .......: If text is selected, writes only the selection, else writes all text in the control
;+
;                  If the extension in $sFileSpec is .rtf, RTF is written, else text
;+
;                  Call _GUICtrlRichEdit_IsModified() to determine whether the text has changed
; Related .......: _GUICtrlRichEdit_SetLimitOnText, _GUICtrlRichEdit_StreamFromVar, _GUICtrlRichEdit_StreamToFile, _GUICtrlRichEdit_IsModified
; Link ..........: @@MsdnLink@@ EM_STREAMIN
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_StreamToVar($hWnd, $fRtf = True, $fIncludeCOM = True, $iOpts = 0, $iCodePage = 0)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, "")

	Local $iWparam
	If $fRtf Then
		$iWparam = _Iif($fIncludeCOM, $SF_RTF, $SF_RTFNOOBJS)
	Else
		$iWparam = _Iif($fIncludeCOM, $SF_TEXTIZED, $SF_TEXT)
		If BitAND($iOpts, $SFF_PLAINRTF) Then Return SetError(1041, 0, "")
	EndIf
	; only opts are $SFF_PLAINRTF and $SF_UNICODE
	If BitAND($iOpts, BitNOT(BitOR($SFF_PLAINRTF, $SF_UNICODE))) Then Return SetError(1042, 0, "")
	If BitAND($iOpts, $SF_UNICODE) Then
		If Not BitAND($iWparam, $SF_TEXT) Then Return SetError(1043, 0, "")
	EndIf
	If _GUICtrlRichEdit_IsTextSelected($hWnd) Then $iWparam = BitOR($iWparam, $SFF_SELECTION)

	$iWparam = BitOR($iWparam, $iOpts)
	If $iCodePage <> 0 Then
		$iWparam = BitOR($iWparam, $SF_USECODEPAGE, BitShift($iCodePage, -16))
	EndIf

	Local $tEditStream = DllStructCreate($tagEDITSTREAM)
	DllStructSetData($tEditStream, "pfnCallback", DllCallbackGetPtr($_GRC_StreamToVarCallback))

	$_GRC_sStreamVar = ""
	_SendMessage($hWnd, $EM_STREAMOUT, $iWparam, $tEditStream, 0, "wparam", "struct*")
	Local $iError = DllStructGetData($tEditStream, "dwError")
	If $iError <> 0 Then SetError(700, $iError, "")
	Return $_GRC_sStreamVar
EndFunc   ;==>_GUICtrlRichEdit_StreamToVar

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUICtrlRichEdit_Undo
; Description....: Undoes the last edit control operation in the control's undo queue
; Syntax ........: _GUICtrlRichEdit_Undo($hWnd)
; Parameters.....: $hWnd		- Handle to the control
; Return values..: Success - True - undo operation succeeded
;                  Failure - False - undo operation failed. May set @error:
;                  |101 - $hWnd is not a handle
; Authors........: Prog@ndy
; Modified ......: Chris Haslam (c.haslam)
; Remarks .......: For a single-line edit control, the return value is always True
; Related .......: _GUICtrlRichEdit_CanUndo, _GUICtrlRichEdit_GetNextUndo, _GUICtrlRichEdit_Redo
; Link ..........: @@MsdnLink@@ EM_UNDO
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlRichEdit_Undo($hWnd)
	If Not _WinAPI_IsClassName($hWnd, $_GRE_sRTFClassName) Then Return SetError(101, 0, False)
	Return _SendMessage($hWnd, $EM_UNDO, 0, 0) <> 0
EndFunc   ;==>_GUICtrlRichEdit_Undo

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GCR_Init
; Description ...: Sets global variables $_GRE_sRTFClassName, $h_GUICtrlRTF_lib, $_GRE_Version, $_GRE_CF_RTF and $_GRE_CF_RETEXTOBJ
; Syntax.........: __GCR_Init{}
; Parameters ....:
; Return values .:
; Author ........: Prog@ndy
; Modified.......: Chris Haslam (c.haslam)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GCR_Init()
	$h_GUICtrlRTF_lib = DllCall("kernel32.dll", "ptr", "LoadLibraryW", "wstr", "MSFTEDIT.DLL")
	If $h_GUICtrlRTF_lib[0] <> 0 Then
		$_GRE_sRTFClassName = "RichEdit50W"
		$_GRE_Version = 4.1
	Else
		;RICHED20.DLL
		$h_GUICtrlRTF_lib = DllCall("kernel32.dll", "ptr", "LoadLibraryW", "wstr", "RICHED20.DLL")
		$_GRE_Version = FileGetVersion(@SystemDir & "\riched20.dll", "ProductVersion")
		Switch $_GRE_Version
			Case 3.0
				$_GRE_sRTFClassName = "RichEdit20W"
			Case 5.0
				$_GRE_sRTFClassName = "RichEdit50W"
			Case 6.0
				$_GRE_sRTFClassName = "RichEdit60W"
		EndSwitch
	EndIf
	$_GRE_CF_RTF = _ClipBoard_RegisterFormat("Rich Text Format")
	$_GRE_CF_RETEXTOBJ = _ClipBoard_RegisterFormat("Rich Text Format with Objects")
EndFunc   ;==>__GCR_Init

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GCR_StreamFromFileCallback
; Description ...: Callback function for streaming in from a file
; Syntax.........: __GCR_StreamFromFileCallback($hFile, $pBuf, $iBuflen, $ptrQbytes)
; Parameters ....: $hFile - Handle to the file
;                  $pBuf - pointer to a buffer in the control
;                  $iBuflen - length of this buffer
;                  $ptrQbytes - pointer to number of bytes set in buffer
; Return values .: More bytes to "return"  - 0
;                  All bytes have been "returned" - 1
; Author ........: Prog@ndy
; Modified.......: Chris Haslam (c.haslam)
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ EditStreamCallback Function
; Example .......:
; ===============================================================================================================================
Func __GCR_StreamFromFileCallback($hFile, $pBuf, $iBuflen, $ptrQbytes)
	Local $tQbytes = DllStructCreate("long", $ptrQbytes)
	DllStructSetData($tQbytes, 1, 0)
	Local $tBuf = DllStructCreate("char[" & $iBuflen & "]", $pBuf)
	Local $buf = FileRead($hFile, $iBuflen - 1)
	If @error <> 0 Then Return 1
	DllStructSetData($tBuf, 1, $buf)
	DllStructSetData($tQbytes, 1, StringLen($buf))
	Return 0
EndFunc   ;==>__GCR_StreamFromFileCallback

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GCR_StreamFromVarCallback
; Description ...: Callback function for streaming in from a variable
; Syntax.........: __GCR_StreamFromVarCallback($dwCookie, $pBuf, $iBufLen, $ptrQbytes)
; Parameters ....: $dwCookie - not used
;                  $pBuf - pointer to a buffer in the control
;                  $iBuflen - length of this buffer
;                  $ptrQbytes - pointer to number of bytes set in buffer
; Return values .: More bytes to "return"  - 0
;                  All bytes have been "returned" - 1
; Author ........: Chris Haslam (c.haslam)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ EditStreamCallback Function
; Example .......:
; ===============================================================================================================================
Func __GCR_StreamFromVarCallback($dwCookie, $pBuf, $iBuflen, $ptrQbytes)
	#forceref $dwCookie
	Local $tQbytes = DllStructCreate("long", $ptrQbytes)
	DllStructSetData($tQbytes, 1, 0)

	Local $tCtl = DllStructCreate("char[" & $iBuflen & "]", $pBuf)
	Local $sCtl = StringLeft($_GRC_sStreamVar, $iBuflen - 1)
	If $sCtl = "" Then Return 1
	DllStructSetData($tCtl, 1, $sCtl)

	Local $iLen = StringLen($sCtl)
	DllStructSetData($tQbytes, 1, $iLen)
	$_GRC_sStreamVar = StringMid($_GRC_sStreamVar, $iLen + 1)
	Return 0
EndFunc   ;==>__GCR_StreamFromVarCallback

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GCR_StreamFToFileCallback
; Description ...: Callback function for streaming out to a file
; Syntax.........: __GCR_StreamToFileCallback($hFile, $pBuf, $iBuflen, $ptrQbytes
; Parameters ....: $hFile - Handle to the file
;                  $pBuf - pointer to a buffer in the control
;                  $iBuflen - length of this buffer
;                  $ptrQbytes - pointer to number of bytes set in buffer
; Return values .: 0
; Author ........: Prog@ndy
; Modified.......: Chris Haslam (c.haslam)
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ EditStreamCallback Function
; Example .......:
; ===============================================================================================================================
Func __GCR_StreamToFileCallback($hFile, $pBuf, $iBuflen, $ptrQbytes)
	Local $tQbytes = DllStructCreate("long", $ptrQbytes)
	DllStructSetData($tQbytes, 1, 0)
	Local $tBuf = DllStructCreate("char[" & $iBuflen & "]", $pBuf)
	Local $s = DllStructGetData($tBuf, 1)
	FileWrite($hFile, $s)
	DllStructSetData($tQbytes, 1, StringLen($s))
	Return 0
EndFunc   ;==>__GCR_StreamToFileCallback

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GCR_StreamFToVarCallback
; Description ...: Callback function for streaming out to a variable
; Syntax.........: __GCR_StreamToVarCallback($dwCookie, $pBuf, $iBufLen, $ptrQbytes)
; Parameters ....: $dwCookie - not used
;                  $pBuf - pointer to a buffer in the control
;                  $iBuflen - length of this buffer
;                  $ptrQbytes - pointer to number of bytes set in buffer
; Return values .: 0
; Author ........: Chris Haslam (c.haslam)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ EditStreamCallback Function
; Example .......:
; ===============================================================================================================================
Func __GCR_StreamToVarCallback($dwCookie, $pBuf, $iBuflen, $ptrQbytes)
	$dwCookie = $dwCookie ; to satisfy AutoItWrapper
	Local $tQbytes = DllStructCreate("long", $ptrQbytes)
	DllStructSetData($tQbytes, 1, 0)
	Local $tBuf = DllStructCreate("char[" & $iBuflen & "]", $pBuf)
	Local $s = DllStructGetData($tBuf, 1)
	$_GRC_sStreamVar &= $s
	Return 0
EndFunc   ;==>__GCR_StreamToVarCallback

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GCR_ConvertTwipsToSpaceUnit
; Description ...: Converts Twips (1/1440 inch) to user space units
; Syntax.........: __GCR_ConvertTwipsToSpaceUnit
; Parameters ....: $nIn - space in twips
; Return values .: Success - value in space units (inches, cm, mm, points or twips)
; Author ........: Chris Haslam (c.haslam)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GCR_ConvertTwipsToSpaceUnit($nIn)
	Local $ret
	Switch $_GRE_TwipsPeSpaceUnit
		Case 1440, 567 ; inches, cm
			$ret = StringFormat("%.2f", $nIn / $_GRE_TwipsPeSpaceUnit)
			If $ret = "-0.00" Then $ret = "0.00"
		Case 56.7, 72 ; mm, points
			$ret = StringFormat("%.1f", $nIn / $_GRE_TwipsPeSpaceUnit)
			If $ret = "-0.0" Then $ret = "0.0"
		Case Else
			$ret = $nIn
	EndSwitch
	Return $ret
EndFunc   ;==>__GCR_ConvertTwipsToSpaceUnit

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GCR_IsNumeric
; Description ...: Does a variable contain a numeric value?
; Syntax.........: __GCR_IsNumeric($vN)
; Parameters ....: $VN - the variable
;                  $SRange - ">0", ">=0", ">0,-1", ">=0,-1"
; Return values .: Success - True or False
;                  Failure - can't fail
; Author ........: Chris Haslam (c.haslam)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GCR_IsNumeric($vN, $sRange = "")
	If Not (IsNumber($vN) Or StringIsInt($vN) Or StringIsFloat($vN)) Then Return False
	Switch $sRange
		Case ">0"
			If $vN <= 0 Then Return False
		Case ">=0"
			If $vN < 0 Then Return False
		Case ">0,-1"
			If Not ($vN > 0 Or $vN = -1) Then Return False
		Case ">=0,-1"
			If Not ($vN >= 0 Or $vN = -1) Then Return False
	EndSwitch
	Return True
EndFunc   ;==>__GCR_IsNumeric

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GCR_GetParaScopeChar
; Description ...: Gets the scope to which paragraph format settings apply
; Syntax.........:  __GCR_GetParaScopeChar($hWnd, $iMask, $iPFM)
; Parameters ....: $hWnd - handle to control
;                  $iMask - mask returned by _SendMessage
; Return values .: Success - the scope character
;                  Failure - can't fail
; Author ........: Chris Haslam (c.haslam)
; Modified.......:
; Remarks .......: Takes advantage of an undocumented feature of EM_GETPARAFORMAT
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GCR_GetParaScopeChar($hWnd, $iMask, $iPFM)
	If Not _GUICtrlRichEdit_IsTextSelected($hWnd) Then
		Return "c"
	ElseIf BitAND($iMask, $iPFM) = $iPFM Then
		Return "a"
	Else
		Return "f"
	EndIf
EndFunc   ;==>__GCR_GetParaScopeChar

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GCR_ParseParaNumberingStyle
; Description ...: For _GUICtrlRichEdit_SetParaNumbering(), parses $vStyle
; Syntax.........: __GCR_ParseParaNumberingStyle($sIn, $fForceRoman, ByRef $iPFM, ByRef $iWNumbering, ByRef $iWnumStart, ByRef $iWnumStyle, ByRef $iQspaces)
; Parameters ....: $sIn - style string: see _GUICtrlRichEdit_SetParaNumbering()
;                  $ForceRoman - If $vStyle contains numner i, interpret as Roman one else as letter i
;                  $iPFM - BitOr combination of $PFM_ constants (Returned)
;                  $iWNumbering - wNumbering member of PARAFORMAT2 structure
;                  $iWnumStart - wNumbering Start  member of PARAFORMAT2 structure (Returned)
;                  $iWNumStyle - wNumberingStyle  member of PARAFORMAT2 structure  (Returned)
;                  $iQspaces - for wNumberingTab  member of PARAFORMAT2 structure  (Returned)
; Return values .: Success - True
;                  Failure - False and sets @error:
;                  |102 - $sIn is invalid
; Author ........: Chris Haslam (c.haslam)
; Modified.......:
; Remarks .......:
; Related .......: GuiCtrlRichEdit_SetParaNumbering()
; Link ..........: @@MsdnLink@@ EM_PARAMFORMAT
; Example .......:
; ===============================================================================================================================
Func __GCR_ParseParaNumberingStyle($sIn, $fForceRoman, ByRef $iPFM, ByRef $iWNumbering, ByRef $iWnumStart, ByRef $iWnumStyle, ByRef $iQspaces)
	Local Const $sRoman = "mdclxviMDCLXVI", $kRpar = 0, $k2par = 0x100, $kPeriod = 0x200, $kNbrOnly = 0x300
	If $sIn = "" Then
		$iWNumbering = 0
		$iPFM = $PFM_NUMBERING
	Else
		Local $s = StringStripWS($sIn, 2) ; trialing whitespace
		$iQspaces = StringLen($sIn) - StringLen($s)
		$sIn = $s
		$iPFM = $PFM_NUMBERINGTAB
		If $sIn = "." Then
			$iWNumbering = $PFN_BULLET
			$iPFM = BitOR($iPFM, $PFM_NUMBERING)
		ElseIf $sIn = "=" Then
			$iWnumStyle = 0x400
			$iPFM = BitOR($iPFM, $PFM_NUMBERINGSTYLE)
		Else
			Switch StringRight($sIn, 1)
				Case ")"
					If StringLeft($sIn, 1) = "(" Then
						$iWnumStyle = $k2par
						$sIn = StringTrimLeft($sIn, 1)
					Else
						$iWnumStyle = $kRpar
					EndIf
				Case "."
					$iWnumStyle = $kPeriod
				Case Else ; display only number
					$iWnumStyle = $kNbrOnly
			EndSwitch
			$iPFM = BitOR($iPFM, $PFM_NUMBERINGSTYLE)
			If $iWnumStyle <> 0x300 Then $sIn = StringTrimRight($sIn, 1)
			If StringIsDigit($sIn) Then
				$iWnumStart = Number($sIn)
				$iWNumbering = 2
				$iPFM = BitOR($iPFM, $PFM_NUMBERINGSTART, $PFM_NUMBERING)
			Else
				Local $fMayBeRoman = True
				For $i = 1 To StringLen($sIn)
					If Not StringInStr($sRoman, StringMid($sIn, $i, 1)) Then
						$fMayBeRoman = False
						ExitLoop
					EndIf
				Next
				Local $fIsRoman
				If $fMayBeRoman Then
					$fIsRoman = $fForceRoman
				Else
					$fIsRoman = False
				EndIf
				Switch True
					Case $fIsRoman
						$iWnumStart = __GCR_ConvertRomanToNumber($sIn)
						If $iWnumStart = -1 Then Return SetError(102, 0, False)
						$iWNumbering = _Iif(StringIsLower($sIn), 5, 6)
						$iPFM = BitOR($iPFM, $PFM_NUMBERINGSTART, $PFM_NUMBERING)
					Case StringIsAlpha($sIn)
						If StringIsLower($sIn) Then
							$iWNumbering = 3
						Else
							$iWNumbering = 4
							$sIn = StringLower($sIn)
						EndIf
						$iWnumStart = 0
						Local $iN
						For $iP = 1 To StringLen($sIn)
							$iN = Asc(StringMid($sIn, $i))
							If $iN >= Asc("a") And $iN <= Asc("z") Then
								$iWnumStart = $iWnumStart * 26 + ($iN - Asc("a") + 1)
							EndIf
						Next
						$iPFM = BitOR($iPFM, $PFM_NUMBERINGSTART, $PFM_NUMBERING)
					Case Else
						Return SetError(102, 0, False)
				EndSwitch
			EndIf
		EndIf
	EndIf
	Return True
EndFunc   ;==>__GCR_ParseParaNumberingStyle

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GCR_ConvertRomanToNumber
; Description ...: Converts a Roman number to a number
; Syntax.........: __GCR_ConvertRomanToNumber($sRnum)
; Parameters ....: $sRnum - string containing Roman number
; Return values .: Success - the (Arabic) number
;                  Failure - -1
; Author ........: Chris Haslam (c.haslam)
; Modified.......:
; Remarks .......: Is case-insensitive
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GCR_ConvertRomanToNumber($sRnum)
	Local Enum $k9, $k5, $k4, $k1, $kMult, $kHigher
	Local Const $av[3][6] = [["cm", "d", "cd", "c", 100, "m"],["xc", "l", "xl", "x", 10, "mdc"],["ix", "v", "iv", "i", 1, "mdclx"]]
	$sRnum = StringLower($sRnum)
	Local $i = 1
	While StringMid($sRnum, $i, 1) = "m"
		$i += 1
	WEnd
	Local $iDigit, $iQ1s, $iRet = ($i - 1) * 1000
	For $j = 0 To 2
		$iDigit = 0
		If StringMid($sRnum, $i, 2) = $av[$j][$k9] Then
			$iDigit = 9
			$i += 2
		ElseIf StringMid($sRnum, $i, 1) = $av[$j][$k5] Then
			$iDigit = 5
			$i += 1
		ElseIf StringMid($sRnum, $i, 2) = $av[$j][$k4] Then
			$iDigit = 4
			$i += 2
		ElseIf StringInStr($av[$j][$kHigher], StringMid($sRnum, $i, 1)) Then
			Return -1
		EndIf
		If $iDigit = 0 Or $iDigit = 5 Then
			$iQ1s = 0
			While StringMid($sRnum, $i, 1) = $av[$j][$k1]
				$iQ1s += 1
				If $iQ1s > 3 Then Return 0
				$i += 1
			WEnd
			$iDigit += $iQ1s
		EndIf
		$iRet += $iDigit * $av[$j][$kMult]
	Next
	If $i <= StringLen($sRnum) Then Return -1
	Return $iRet
EndFunc   ;==>__GCR_ConvertRomanToNumber

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GCR_SendGetCharFormatMessage
; Description ...: Gets character format of character just after the anchor point (if text is selected) or after the inserton point
; Syntax.........: __GCR_SendGetCharFormatMessage($hWnd, $tCharFormat)
; Parameters ....: $hWnd - handle of control
;                : $tCharFormat - CHARFORMAT or CHARFORMAT2 structure
; Return values .: Success - True
;                  Failure - error of _SendMessage EM_GETCHARFORMAT SCF_SELECTION
; Author ........: Chris Haslam (c.haslam)
; Modified.......:
; Remarks .......: If there is a selection, restores it before returning, with the anchor and actove positions correct,
;                  even if active < anchor
; Related .......:
; Link ..........: @@MsdnLink@@ EM_GETCHARFORMAT
; Example .......:
; ===============================================================================================================================
Func __GCR_SendGetCharFormatMessage($hWnd, $tCharFormat)
	Local $fIsSel = _GUICtrlRichEdit_IsTextSelected($hWnd)
	Local $aiAnchAct
	If $fIsSel Then
		$aiAnchAct = _GUICtrlRichEdit_GetSelAA($hWnd)
		_GUICtrlRichEdit_SetSel($hWnd, $aiAnchAct[0], $aiAnchAct[0] + 1, True) ; select first char, hiding selection
	EndIf
	Local $iRet = _SendMessage($hWnd, $EM_GETCHARFORMAT, $SCF_SELECTION, $tCharFormat, 0, "wparam", "struct*")
	If $fIsSel Then _GUICtrlRichEdit_SetSel($hWnd, $aiAnchAct[0], $aiAnchAct[1])
	Return $iRet
EndFunc   ;==>__GCR_SendGetCharFormatMessage

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GCR_SendGetParaFormatMessage
; Description ...: Gets format of (first) selected paragraph or, if no selection, of the paragraph containing the insertion point
; Syntax.........: __GCR_SendGetParaFormatMessage($hWnd, $tParaFormat)
; Parameters ....: $hWnd - handle of control
;                : $tParaFormat - PARAFORMAT or PARAFORMAT2 structure
; Return values .: Success - True
;                  Failure - error of _SendMessage EM_PARAFORMAT
; Author ........: Chris Haslam (c.haslam)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ EM_PARAFORMAT
; Example .......:
; ===============================================================================================================================
Func __GCR_SendGetParaFormatMessage($hWnd, $tParaFormat)
	Local $fIsSel = _GUICtrlRichEdit_IsTextSelected($hWnd)
	Local $iInsPt = 0
	If Not $fIsSel Then
		Local $as = _GUICtrlRichEdit_GetSel($hWnd)
		$iInsPt = $as[0]
		Local $iN = _GUICtrlRichEdit_GetFirstCharPosOnLine($hWnd)
		_GUICtrlRichEdit_SetSel($hWnd, $iN, $iN + 1, True)
	EndIf

	_SendMessage($hWnd, $EM_GETPARAFORMAT, 0, $tParaFormat, 0, "wparam", "struct*")

	If Not $fIsSel Then _GUICtrlRichEdit_SetSel($hWnd, $iInsPt, $iInsPt)

	Return True
EndFunc   ;==>__GCR_SendGetParaFormatMessage

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __GCR_SetOLECallback
; Description....: Enables OLE-relationed functionality
; Syntax ........: _GUICtrlRichEdit_SetOLECallback($hWnd)
; Parameters.....: $hWnd		- Handle to the control
; Return values..: Success - True
;                  Failure - False and set @error:
;                  |101 - $hWnd is not a handle
;                  |700 - internal error
; Authors........: Prog@ndy
; Modified ......: Chris Haslam (c.haslam)
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ EM_SETOLECALLBACK
; Example .......:
; ===============================================================================================================================
Func __GCR_SetOLECallback($hWnd)
	If Not IsHWnd($hWnd) Then Return SetError(101, 0, False)

	;'// Initialize the OLE part.
	If Not $pObj_RichCom Then
		$pCall_RichCom = DllStructCreate("ptr[20]");  '(With some extra space for the future)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_QueryInterface), 1)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_AddRef), 2)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_Release), 3)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_GetNewStorage), 4)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_GetInPlaceContext), 5)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_ShowContainerUI), 6)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_QueryInsertObject), 7)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_DeleteObject), 8)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_QueryAcceptData), 9)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_ContextSensitiveHelp), 10)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_GetClipboardData), 11)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_GetDragDropEffect), 12)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_GetContextMenu), 13)
		DllStructSetData($pObj_RichComObject, 1, DllStructGetPtr($pCall_RichCom))
		DllStructSetData($pObj_RichComObject, 2, 1)
		$pObj_RichCom = DllStructGetPtr($pObj_RichComObject)
	EndIf
	Local Const $EM_SETOLECALLBACK = 0x400 + 70
	If _SendMessage($hWnd, $EM_SETOLECALLBACK, 0, $pObj_RichCom) = 0 Then Return SetError(700, 0, False)
	Return True
EndFunc   ;==>__GCR_SetOLECallback

;~ '/////////////////////////////////////
;~ '// OLE stuff, don't use yourself..
;~ '/////////////////////////////////////
;~ '// Useless procedure, never called..
; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __RichCom_Object_QueryInterface
; Description ...:
; Syntax.........: __RichCom_Object_QueryInterface($pObject, $REFIID, $ppvObj)
; Parameters ....:
; Return values .:
; Author ........:
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __RichCom_Object_QueryInterface($pObject, $REFIID, $ppvObj)
	#forceref $pObject, $REFIID, $ppvObj
	Return $_GCR_S_OK
EndFunc   ;==>__RichCom_Object_QueryInterface

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __RichCom_Object_AddRef
; Description ...:
; Syntax.........: __RichCom_Object_AddRef($pObject)
; Parameters ....:
; Return values .:
; Author ........:
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __RichCom_Object_AddRef($pObject)
;~ Exit Function
	Local $data = DllStructCreate("ptr;dword", $pObject)
	DllStructSetData($data, 2, DllStructGetData($data, 2) + 1)
	Return DllStructGetData($data, 2)
EndFunc   ;==>__RichCom_Object_AddRef

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __RichCom_Object_Release
; Description ...:
; Syntax.........: __RichCom_Object_Release($pObject)
; Parameters ....:
; Return values .:
; Author ........:
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __RichCom_Object_Release($pObject)
;~ Exit Function
	Local $data = DllStructCreate("ptr;dword", $pObject)
	If DllStructGetData($data, 2) > 0 Then
		DllStructSetData($data, 2, DllStructGetData($data, 2) - 1)
		Return DllStructGetData($data, 2)
	EndIf
;~     If @pObject[1] > 0 Then
;~         Decr @pObject[1]
;~         Func = @pObject[1]
;~     Else
;~         pObject = 0
;~     End If
EndFunc   ;==>__RichCom_Object_Release

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __RichCom_Object_GetInPlaceContext
; Description ...:
; Syntax.........: __RichCom_Object_GetInPlaceContext($pObject, $lplpFrame, $lplpDoc, $lpFrameInfo)
; Parameters ....:
; Return values .:
; Author ........:
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __RichCom_Object_GetInPlaceContext($pObject, $lplpFrame, $lplpDoc, $lpFrameInfo)
	#forceref $pObject, $lplpFrame, $lplpDoc, $lpFrameInfo
	Return $_GCR_E_NOTIMPL
EndFunc   ;==>__RichCom_Object_GetInPlaceContext

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __RichCom_Object_ShowContainerUI
; Description ...:
; Syntax.........: __RichCom_Object_ShowContainerUI($pObject, $fShow)
; Parameters ....:
; Return values .:
; Author ........:
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __RichCom_Object_ShowContainerUI($pObject, $fShow)
	#forceref $pObject, $fShow
	Return $_GCR_E_NOTIMPL
EndFunc   ;==>__RichCom_Object_ShowContainerUI

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __RichCom_Object_QueryInsertObject
; Description ...:
; Syntax.........: __RichCom_Object_QueryInsertObject($pObject, $lpclsid, $lpstg, $cp)
; Parameters ....:
; Return values .:
; Author ........:
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __RichCom_Object_QueryInsertObject($pObject, $lpclsid, $lpstg, $cp)
	#forceref $pObject, $lpclsid, $lpstg, $cp
	Return $_GCR_S_OK
EndFunc   ;==>__RichCom_Object_QueryInsertObject

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __RichCom_Object_DeleteObject
; Description ...:
; Syntax.........: __RichCom_Object_DeleteObject($pObject, $lpoleobj)
; Parameters ....:
; Return values .:
; Author ........:
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __RichCom_Object_DeleteObject($pObject, $lpoleobj)
	#forceref $pObject, $lpoleobj
	Return $_GCR_E_NOTIMPL
EndFunc   ;==>__RichCom_Object_DeleteObject

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __RichCom_Object_QueryAcceptData
; Description ...:
; Syntax.........: __RichCom_Object_QueryAcceptData($pObject, $lpdataobj, $lpcfFormat, $reco, $fReally, $hMetaPict)
; Parameters ....:
; Return values .:
; Author ........:
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __RichCom_Object_QueryAcceptData($pObject, $lpdataobj, $lpcfFormat, $reco, $fReally, $hMetaPict)
	#forceref $pObject, $lpdataobj, $lpcfFormat, $reco, $fReally, $hMetaPict
	Return $_GCR_S_OK
EndFunc   ;==>__RichCom_Object_QueryAcceptData

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __RichCom_Object_ContextSensitiveHelp
; Description ...:
; Syntax.........: __RichCom_Object_ContextSensitiveHelp($pObject, $fEnterMode)
; Parameters ....:
; Return values .:
; Author ........:
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __RichCom_Object_ContextSensitiveHelp($pObject, $fEnterMode)
	#forceref $pObject, $fEnterMode
	Return $_GCR_E_NOTIMPL
EndFunc   ;==>__RichCom_Object_ContextSensitiveHelp

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __RichCom_Object_GetClipboardData
; Description ...:
; Syntax.........: __RichCom_Object_GetClipboardData($pObject, $lpchrg, $reco, $lplpdataobj)
; Parameters ....:
; Return values .:
; Author ........:
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __RichCom_Object_GetClipboardData($pObject, $lpchrg, $reco, $lplpdataobj)
	#forceref $pObject, $lpchrg, $reco, $lplpdataobj
	Return $_GCR_E_NOTIMPL
EndFunc   ;==>__RichCom_Object_GetClipboardData

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __RichCom_Object_GetDragDropEffect
; Description ...:
; Syntax.........: __RichCom_Object_GetDragDropEffect($pObject, $fDrag, $grfKeyState, $pdwEffect)
; Parameters ....:
; Return values .:
; Author ........:
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __RichCom_Object_GetDragDropEffect($pObject, $fDrag, $grfKeyState, $pdwEffect)
	#forceref $pObject, $fDrag, $grfKeyState, $pdwEffect
	Return $_GCR_E_NOTIMPL
EndFunc   ;==>__RichCom_Object_GetDragDropEffect

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __RichCom_Object_GetContextMenu
; Description ...:
; Syntax.........: __RichCom_Object_GetContextMenu($pObject, $seltype, $lpoleobj, $lpchrg, $lphmenu)
; Parameters ....:
; Return values .:
; Author ........:
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __RichCom_Object_GetContextMenu($pObject, $seltype, $lpoleobj, $lpchrg, $lphmenu)
	#forceref $pObject, $seltype, $lpoleobj, $lpchrg, $lphmenu
	Return $_GCR_E_NOTIMPL
EndFunc   ;==>__RichCom_Object_GetContextMenu

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __RichCom_Object_GetNewStorage
; Description ...:
; Syntax.........: __RichCom_Object_GetNewStorage($pObject, $lplpstg)
; Parameters ....:
; Return values .:
; Author ........:
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __RichCom_Object_GetNewStorage($pObject, $lplpstg)
	#forceref $pObject
;~     If pCall_RichCom_CreateILockBytesOnHGlobal = 0 Or pCall_RichCom_StgCreateDocfileOnILockBytes = 0 Then Exit Function
	Local $sc = DllCall($hLib_RichCom_OLE32, "dword", "CreateILockBytesOnHGlobal", "hwnd", 0, "int", 1, "ptr*", 0)
	Local $lpLockBytes = $sc[3]
	$sc = $sc[0]
;~     Call Dword pCall_RichCom_CreateILockBytesOnHGlobal Using _
;~         RichCom_CreateILockBytesOnHGlobal( ByVal 0&, ByVal 1&, lpLockBytes ) To sc
	If $sc Then Return $sc
	$sc = DllCall($hLib_RichCom_OLE32, "dword", "StgCreateDocfileOnILockBytes", "ptr", $lpLockBytes, "dword", BitOR(0x10, 2, 0x1000), "dword", 0, "ptr*", 0)
	Local $lpstg = DllStructCreate("ptr", $lplpstg)
	DllStructSetData($lpstg, 1, $sc[4])
	$sc = $sc[0]
;~     Call Dword pCall_RichCom_StgCreateDocfileOnILockBytes Using _
;~         RichCom_StgCreateDocfileOnILockBytes( _
;~           @lpLockBytes _
;~         , ByVal %STGM_SHARE_EXCLUSIVE Or %STGM_READWRITE Or %STGM_CREATE _
;~         , ByVal 0& _
;~         , lplpstg _
;~         ) To sc
	If $sc Then
		Local $obj = DllStructCreate("ptr", $lpLockBytes)
		Local $iUnknownFuncTable = DllStructCreate("ptr[3]", DllStructGetData($obj, 1))
		Local $lpReleaseFunc = DllStructGetData($iUnknownFuncTable, 3)
		Call("MemoryFuncCall" & "", "long", $lpReleaseFunc, "ptr", $lpLockBytes)
		If @error = 1 Then ConsoleWrite("!> Needs MemoryDLL.au3 for correct release of ILockBytes" & @CRLF)
	EndIf
;~ '   If sc Then Call Dword @@lpLockBytes[2] Using __RichCom_Object_Release( @lpLockBytes )
	Return $sc
EndFunc   ;==>__RichCom_Object_GetNewStorage
