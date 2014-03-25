#include-once

#include "ListViewConstants.au3"
#include "GuiHeader.au3"
#include "Array.au3"
#include "Memory.au3"
#include "WinAPI.au3"
#include "StructureConstants.au3"
#include "SendMessage.au3"
#include "UDFGlobalID.au3"

; #INDEX# =======================================================================================================================
; Title .........: ListView
; AutoIt Version : 3.3.7.20++
; Language ......: English
; Description ...: Functions that assist with ListView control management.
;                  A ListView control is a window that displays a collection of items; each item consists of an icon and a label.
;                  ListView controls provide several ways to arrange and display items. For example, additional information about
;                  each item can be displayed in columns to the right of the icon and label.
; Author(s) .....: Paul Campbell (PaulIA)
; Dll(s) ........: user32.dll
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $_lv_ghLastWnd
Global $Debug_LV = False

; for use with the sort call back functions
Global $iLListViewSortInfoSize = 11
Global $aListViewSortInfo[1][$iLListViewSortInfoSize]
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__LISTVIEWCONSTANT_ClassName = "SysListView32"
Global Const $__LISTVIEWCONSTANT_WS_MAXIMIZEBOX = 0x00010000
Global Const $__LISTVIEWCONSTANT_WS_MINIMIZEBOX = 0x00020000
Global Const $__LISTVIEWCONSTANT_GUI_RUNDEFMSG = 'GUI_RUNDEFMSG'
Global Const $__LISTVIEWCONSTANT_WM_SETREDRAW = 0x000B
Global Const $__LISTVIEWCONSTANT_WM_SETFONT = 0x0030
Global Const $__LISTVIEWCONSTANT_WM_NOTIFY = 0x004E
Global Const $__LISTVIEWCONSTANT_DEFAULT_GUI_FONT = 17
Global Const $__LISTVIEWCONSTANT_ILD_TRANSPARENT = 0x00000001
Global Const $__LISTVIEWCONSTANT_ILD_BLEND25 = 0x00000002
Global Const $__LISTVIEWCONSTANT_ILD_BLEND50 = 0x00000004
Global Const $__LISTVIEWCONSTANT_ILD_MASK = 0x00000010
Global Const $__LISTVIEWCONSTANT_VK_DOWN = 0x28
Global Const $__LISTVIEWCONSTANT_VK_END = 0x23
Global Const $__LISTVIEWCONSTANT_VK_HOME = 0x24
Global Const $__LISTVIEWCONSTANT_VK_LEFT = 0x25
Global Const $__LISTVIEWCONSTANT_VK_NEXT = 0x22
Global Const $__LISTVIEWCONSTANT_VK_PRIOR = 0x21
Global Const $__LISTVIEWCONSTANT_VK_RIGHT = 0x27
Global Const $__LISTVIEWCONSTANT_VK_UP = 0x26
; ===============================================================================================================================

; #OLD_FUNCTIONS#================================================================================================================
; Old Function/Name                      ; --> New Function/Name/Replacement(s)
;
; deprecated functions will no longer work
;_GUICtrlListViewCopyItems                ; --> _GUICtrlListView_CopyItems
;_GUICtrlListViewDeleteAllItems           ; --> _GUICtrlListView_DeleteAllItems
;_GUICtrlListViewDeleteColumn             ; --> _GUICtrlListView_DeleteColumn
;_GUICtrlListViewDeleteItem               ; --> _GUICtrlListView_DeleteItem
;_GUICtrlListViewDeleteItemsSelected      ; --> _GUICtrlListView_DeleteItemsSelected
;_GUICtrlListViewEnsureVisible            ; --> _GUICtrlListView_EnsureVisible
;_GUICtrlListViewFindItem                 ; --> _GUICtrlListView_FindInText, _GUICtrlListView_FindItem, _GUICtrlListView_FindNearest, _GUICtrlListView_FindParam, _GUICtrlListView_FindText
;_GUICtrlListViewGetBackColor             ; --> _GUICtrlListView_GetBkColor
;_GUICtrlListViewGetCallbackMask          ; --> _GUICtrlListView_GetCallbackMask
;_GUICtrlListViewGetCheckedState          ; --> _GUICtrlListView_GetItemChecked
;_GUICtrlListViewGetColumnOrder           ; --> _GUICtrlListView_GetColumnOrder
;_GUICtrlListViewGetColumnWidth           ; --> _GUICtrlListView_GetColumnWidth
;_GUICtrlListViewGetCounterPage           ; --> _GUICtrlListView_GetCounterPage
;_GUICtrlListViewGetCurSel                ; --> _GUICtrlListView_GetNextItem
;_GUICtrlListViewGetExtendedListViewStyle ; --> _GUICtrlListView_GetExtendedListViewStyle
;_GUICtrlListViewGetHeader                ; --> _GUICtrlListView_GetHeader
;_GUICtrlListViewGetHotCursor             ; --> _GUICtrlListView_GetHotCursor
;_GUICtrlListViewGetHotItem               ; --> _GUICtrlListView_GetHotItem
;_GUICtrlListViewGetHoverTime             ; --> _GUICtrlListView_GetHoverTime
;_GUICtrlListViewGetItemCount             ; --> _GUICtrlListView_GetItemCount
;_GUICtrlListViewGetItemTextArray         ; --> _GUICtrlListView_GetItemTextArray
;_GUICtrlListViewGetItemText              ; --> _GUICtrlListView_GetItemTextString
;_GUICtrlListViewGetNextItem              ; --> _GUICtrlListView_GetNextItem
;_GUICtrlListViewGetSelectedCount         ; --> _GUICtrlListView_GetSelectedCount
;_GUICtrlListViewGetSelectedIndices       ; --> _GUICtrlListView_GetSelectedIndices
;_GUICtrlListViewGetSubItemsCount         ; --> _GUICtrlListView_GetColumnCount
;_GUICtrlListViewGetTopIndex              ; --> _GUICtrlListView_GetTopIndex
;_GUICtrlListViewGetUnicodeFormat         ; --> _GUICtrlListView_GetUnicodeFormat
;_GUICtrlListViewGetView                  ; --> _GUICtrlListView_GetView
;_GUICtrlListViewHideColumn               ; --> _GUICtrlListView_HideColumn
;_GUICtrlListViewInsertColumn             ; --> _GUICtrlListView_InsertColumn
;_GUICtrlListViewInsertItem               ; --> _GUICtrlListView_InsertItem
;_GUICtrlListViewJustifyColumn            ; --> _GUICtrlListView_JustifyColumn
;_GUICtrlListViewScroll                   ; --> _GUICtrlListView_Scroll
;_GUICtrlListViewSetColumnHeaderText      ; --> _GUICtrlListView_SetColumn
;_GUICtrlListViewSetColumnWidth           ; --> _GUICtrlListView_SetColumnWidth
;_GUICtrlListViewSetColumnOrder           ; --> _GUICtrlListView_SetColumnOrder
;_GUICtrlListViewSetCheckState            ; --> _GUICtrlListView_SetItemChecked
;_GUICtrlListViewSetHotItem               ; --> _GUICtrlListView_SetHotItem
;_GUICtrlListViewSetHoverTime             ; --> _GUICtrlListView_SetHoverTime
;_GUICtrlListViewSetItemCount             ; --> _GUICtrlListView_SetItemCount
;_GUICtrlListViewSetItemSelState          ; --> _GUICtrlListView_SetItemSelected
;_GUICtrlListViewSetItemText              ; --> _GUICtrlListView_SetItemText
;_GUICtrlListViewSort                     ; --> _GUICtrlListView_SimpleSort

; #NO_DOC_FUNCTION# =============================================================================================================
; Not working/documented/implimented at this time
;
;_GUICtrlListView_GetEmptyText
;_GUICtrlListView_GetGroupState
;_GUICtrlListView_GetInsertMark
;_GUICtrlListView_GetInsertMarkColor
;_GUICtrlListView_GetInsertMarkRect
;_GUICtrlListView_InsertMarkHitTest
;_GUICtrlListView_IsItemVisible
;_GUICtrlListView_MoveGroup
;_GUICtrlListView_SetHotCursor
;_GUICtrlListView_SetInfoTip
;_GUICtrlListView_SetInsertMark
;_GUICtrlListView_SetInsertMarkColor
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_GUICtrlListView_AddArray
;_GUICtrlListView_AddColumn
;_GUICtrlListView_AddItem
;_GUICtrlListView_AddSubItem
;_GUICtrlListView_ApproximateViewHeight
;_GUICtrlListView_ApproximateViewRect
;_GUICtrlListView_ApproximateViewWidth
;_GUICtrlListView_Arrange
;_GUICtrlListView_BeginUpdate
;_GUICtrlListView_CancelEditLabel
;_GUICtrlListView_ClickItem
;_GUICtrlListView_CopyItems
;_GUICtrlListView_Create
;_GUICtrlListView_CreateDragImage
;_GUICtrlListView_CreateSolidBitMap
;_GUICtrlListView_DeleteAllItems
;_GUICtrlListView_DeleteColumn
;_GUICtrlListView_DeleteItem
;_GUICtrlListView_DeleteItemsSelected
;_GUICtrlListView_Destroy
;_GUICtrlListView_DrawDragImage
;_GUICtrlListView_EditLabel
;_GUICtrlListView_EnableGroupView
;_GUICtrlListView_EndUpdate
;_GUICtrlListView_EnsureVisible
;_GUICtrlListView_FindInText
;_GUICtrlListView_FindItem
;_GUICtrlListView_FindNearest
;_GUICtrlListView_FindParam
;_GUICtrlListView_FindText
;_GUICtrlListView_GetBkColor
;_GUICtrlListView_GetBkImage
;_GUICtrlListView_GetCallBackMask
;_GUICtrlListView_GetColumn
;_GUICtrlListView_GetColumnCount
;_GUICtrlListView_GetColumnOrder
;_GUICtrlListView_GetColumnOrderArray
;_GUICtrlListView_GetColumnWidth
;_GUICtrlListView_GetCounterPage
;_GUICtrlListView_GetEditControl
;_GUICtrlListView_GetExtendedListViewStyle
;_GUICtrlListView_GetFocusedGroup
;_GUICtrlListView_GetGroupCount
;_GUICtrlListView_GetGroupInfo
;_GUICtrlListView_GetGroupInfoByIndex
;_GUICtrlListView_GetGroupRect
;_GUICtrlListView_GetGroupViewEnabled
;_GUICtrlListView_GetHeader
;_GUICtrlListView_GetHotCursor
;_GUICtrlListView_GetHotItem
;_GUICtrlListView_GetHoverTime
;_GUICtrlListView_GetImageList
;_GUICtrlListView_GetISearchString
;_GUICtrlListView_GetItem
;_GUICtrlListView_GetItemChecked
;_GUICtrlListView_GetItemCount
;_GUICtrlListView_GetItemCut
;_GUICtrlListView_GetItemDropHilited
;_GUICtrlListView_GetItemEx
;_GUICtrlListView_GetItemFocused
;_GUICtrlListView_GetItemGroupID
;_GUICtrlListView_GetItemImage
;_GUICtrlListView_GetItemIndent
;_GUICtrlListView_GetItemParam
;_GUICtrlListView_GetItemPosition
;_GUICtrlListView_GetItemPositionX
;_GUICtrlListView_GetItemPositionY
;_GUICtrlListView_GetItemRect
;_GUICtrlListView_GetItemRectEx
;_GUICtrlListView_GetItemSelected
;_GUICtrlListView_GetItemSpacing
;_GUICtrlListView_GetItemSpacingX
;_GUICtrlListView_GetItemSpacingY
;_GUICtrlListView_GetItemState
;_GUICtrlListView_GetItemStateImage
;_GUICtrlListView_GetItemText
;_GUICtrlListView_GetItemTextArray
;_GUICtrlListView_GetItemTextString
;_GUICtrlListView_GetNextItem
;_GUICtrlListView_GetNumberOfWorkAreas
;_GUICtrlListView_GetOrigin
;_GUICtrlListView_GetOriginX
;_GUICtrlListView_GetOriginY
;_GUICtrlListView_GetOutlineColor
;_GUICtrlListView_GetSelectedColumn
;_GUICtrlListView_GetSelectedCount
;_GUICtrlListView_GetSelectedIndices
;_GUICtrlListView_GetSelectionMark
;_GUICtrlListView_GetStringWidth
;_GUICtrlListView_GetSubItemRect
;_GUICtrlListView_GetTextBkColor
;_GUICtrlListView_GetTextColor
;_GUICtrlListView_GetToolTips
;_GUICtrlListView_GetTopIndex
;_GUICtrlListView_GetUnicodeFormat
;_GUICtrlListView_GetView
;_GUICtrlListView_GetViewDetails
;_GUICtrlListView_GetViewLarge
;_GUICtrlListView_GetViewList
;_GUICtrlListView_GetViewSmall
;_GUICtrlListView_GetViewTile
;_GUICtrlListView_GetViewRect
;_GUICtrlListView_HideColumn
;_GUICtrlListView_HitTest
;_GUICtrlListView_InsertColumn
;_GUICtrlListView_InsertGroup
;_GUICtrlListView_InsertItem
;_GUICtrlListView_JustifyColumn
;_GUICtrlListView_MapIDToIndex
;_GUICtrlListView_MapIndexToID
;_GUICtrlListView_RedrawItems
;_GUICtrlListView_RegisterSortCallBack
;_GUICtrlListView_RemoveAllGroups
;_GUICtrlListView_RemoveGroup
;_GUICtrlListView_Scroll
;_GUICtrlListView_SetBkColor
;_GUICtrlListView_SetBkImage
;_GUICtrlListView_SetCallBackMask
;_GUICtrlListView_SetColumn
;_GUICtrlListView_SetColumnOrder
;_GUICtrlListView_SetColumnOrderArray
;_GUICtrlListView_SetColumnWidth
;_GUICtrlListView_SetExtendedListViewStyle
;_GUICtrlListView_SetGroupInfo
;_GUICtrlListView_SetHotItem
;_GUICtrlListView_SetHoverTime
;_GUICtrlListView_SetIconSpacing
;_GUICtrlListView_SetImageList
;_GUICtrlListView_SetItem
;_GUICtrlListView_SetItemChecked
;_GUICtrlListView_SetItemCount
;_GUICtrlListView_SetItemCut
;_GUICtrlListView_SetItemDropHilited
;_GUICtrlListView_SetItemEx
;_GUICtrlListView_SetItemFocused
;_GUICtrlListView_SetItemGroupID
;_GUICtrlListView_SetItemImage
;_GUICtrlListView_SetItemIndent
;_GUICtrlListView_SetItemParam
;_GUICtrlListView_SetItemPosition
;_GUICtrlListView_SetItemPosition32
;_GUICtrlListView_SetItemSelected
;_GUICtrlListView_SetItemState
;_GUICtrlListView_SetItemStateImage
;_GUICtrlListView_SetItemText
;_GUICtrlListView_SetOutlineColor
;_GUICtrlListView_SetSelectedColumn
;_GUICtrlListView_SetSelectionMark
;_GUICtrlListView_SetTextBkColor
;_GUICtrlListView_SetTextColor
;_GUICtrlListView_SetToolTips
;_GUICtrlListView_SetUnicodeFormat
;_GUICtrlListView_SetView
;_GUICtrlListView_SetWorkAreas
;_GUICtrlListView_SimpleSort
;_GUICtrlListView_SortItems
;_GUICtrlListView_SubItemHitTest
;_GUICtrlListView_UnRegisterSortCallBack
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;$tagLVBKIMAGE
;$tagLVCOLUMN
;$tagLVGROUP
;$tagLVINSERTMARK
;$tagLVSETINFOTIP
;__GUICtrlListView_ArrayDelete
;__GUICtrlListView_Draw
;__GUICtrlListView_GetItemOverlayImage
;__GUICtrlListView_IndexToOverlayImageMask
;__GUICtrlListView_IndexToStateImageMask
;__GUICtrlListView_OverlayImageMaskToIndex
;__GUICtrlListView_SetItemOverlayImage
;__GUICtrlListView_Sort
;__GUICtrlListView_StateImageMaskToIndex
;__GUICtrlListView_ReverseColorOrder
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagLVBKIMAGE
; Description ...: Contains information about the background image of a list-view control
; Fields ........: Flags      - This member may be one or more of the following flags.  You can use the LVBKIF_SOURCE_MASK value
;                  +to mask off all but the source flags.  You can use the LVBKIF_STYLE_MASK value to mask off all but the  style
;                  +flags.
;                  |$LVBKIF_SOURCE_NONE     - The control has no background image
;                  |$LVBKIF_SOURCE_URL      - The Image member contains the URL of the background image
;                  |$LVBKIF_STYLE_NORMAL    - The background image is displayed normally
;                  |$LVBKIF_STYLE_TILE      - The background image will be tiled to fill the entire background of the control
;                  |$LVBKIF_FLAG_TILEOFFSET - You use this flag to specify the coordinates of the first tile.  This flag is valid
;                  +only if the $LVBKIF_STYLE_TILE flag is also specified. If this flag is not specified the first tile begins at
;                  +the upper-left corner of the client area.
;                  hBmp        - Not used
;                  Image       - Address of a string that contains the URL of the background image. This member is only valid if
;                  +the $LVBKIF_SOURCE_URL flag is set in Flags.  This member must be initialized to point  to  the  buffer  that
;                  +contains or receives the text before sending the message.
;                  ImageMax    - Size of the buffer at the address in Image.  If information is being sent to the  control,  this
;                  +member is ignored.
;                  XOffPercent - Percentage of the client area that the image should be offset horizontally.  For example, at  0
;                  +percent, the image will be displayed against the left edge of the control's client area.  At 50 percent,  the
;                  +image will be displayed horizontally centered in the control's client area. At 100 percent, the image will be
;                  +displayed against the right edge  of  the  control's  client  area.  This  member  is  only  valid  when  the
;                  +$LVBKIF_STYLE_NORMAL is specified in  Flags.  If  both  $LVBKIF_FLAG_TILEOFFSET  and  $LVBKIF_STYLE_TILE  are
;                  +specified in Flags, then the value specifies the pixel, not percentage offset, of the first tile.  Otherwise,
;                  +the value is ignored.
;                  YOffPercent - Percentage of the control's client area that the image should be offset vertically. For example
;                  +at 0 percent, the image will be displayed against the top edge of the control's client area.  At 50  percent,
;                  +the image will be displayed vertically centered in the control's client area.  At 100 percent, the image will
;                  +be displayed against the bottom edge of the control's client  area.  This  member  is  only  valid  when  the
;                  +$LVBKIF_STYLE_NORMAL is specified in  Flags.  If  both  $LVBKIF_FLAG_TILEOFFSET  and  $LVBKIF_STYLE_TILE  are
;                  +specified in Flags, then the value specifies the pixel, not percentage offset, of the first tile.  Otherwise,
;                  +the value is ignored.
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagLVBKIMAGE = "ulong Flags;hwnd hBmp;ptr Image;uint ImageMax;int XOffPercent;int YOffPercent"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagLVCOLUMN
; Description ...: Contains information about a column in report view
; Fields ........: Mask    - Variable specifying which members contain valid information.  This member can be zero,  or  one  or
;                  +more of the following values:
;                  |LVCF_FMT     - The Fmt member is valid
;                  |LVCF_WIDTH   - The CX member is valid
;                  |LVCF_TEXT    - The Text member is valid
;                  |LVCF_SUBITEM - The SubItem member is valid
;                  |LVCF_IMAGE   - The Image member is valid
;                  |LVCF_ORDER   - The Order member is valid.
;                  Fmt     - Alignment of the column header and the subitem text in the column.  This member can be one  of  the
;                  +following values. The alignment of the leftmost column is always left-justified; it cannot be changed:
;                  |LVCFMT_LEFT            - Text is left-aligned
;                  |LVCFMT_RIGHT           - Text is right-aligned
;                  |LVCFMT_CENTER          - Text is centered
;                  |LVCFMT_JUSTIFYMASK     - A bitmask used to select those bits of Fmt that control field justification
;                  |LVCFMT_IMAGE           - The item displays an image from an image list
;                  |LVCFMT_BITMAP_ON_RIGHT - The bitmap appears to the right of text
;                  |LVCFMT_COL_HAS_IMAGES  - The header item contains an image in the image list.
;                  CX      - Width of the column, in pixels
;                  Text    - If column information is being set, this member is the address of a string that contains the column
;                  +header text.  If the structure is receiving information about a column, this member specifies the address  of
;                  +the buffer that receives the column header text.
;                  TextMax - Size of the buffer pointed to by the Text member.  If the structure is  not  receiving  information
;                  +about a column, this member is ignored.
;                  SubItem - Index of subitem associated with the column
;                  Image   - Zero based index of an image within the image list
;                  Order   - Zero-based column offset. Column offset is in left-to-right order.
;                  Microsoft Windos Vista or later
;                    cxMin;       // min snap point
;                    cxDefault;   // default snap point
;                    cxIdeal;     // read only. ideal may not eqaul current width if auto sized (LVS_EX_AUTOSIZECOLUMNS) to a lesser width.
; Author ........: Paul Campbell (PaulIA)
; Modified ......: jpm
; Remarks .......:
; ===============================================================================================================================
Global Const $tagLVCOLUMN = "uint Mask;int Fmt;int CX;ptr Text;int TextMax;int SubItem;int Image;int Order;int cxMin;int cxDefault;int cxIdeal"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagLVGROUP
; Description ...: Used to set and retrieve groups
; Fields ........: Size      - Size of this structure, in bytes
;                  Mask      - Mask that specifies which members of the structure are valid input.  Can be one or  more  of  the
;                  +following values:
;                  |$LVGF_NONE    - No other items are valid
;                  |$LVGF_HEADER  - Header and HeaderMax members are valid
;                  |$LVGF_FOOTER  - Reserved
;                  |$LVGF_STATE   - Reserved
;                  |$LVGF_ALIGN   - Align member is valid
;                  |$LVGF_GROUPID - GroupId member is valid
;                  Header    - Pointer to a string that contains the header text when item information is being  set.  If  group
;                  +information is being retrieved this member specifies the address of the buffer that receives the header text.
;                  HeaderMax - Size of the buffer pointed to by the Header member. If the structure is not receiving information
;                  +about a group, this member is ignored.
;                  Footer    - Reserved
;                  FooterMax - Reserved
;                  GroupID   - ID of the group
;                  StateMask - Reserved
;                  State     - Reserved
;                  Align     - Indicates the alignment of the header text.  It can have one or more of the following values. Use
;                  +one of the header flags.
;                  |LVGA_HEADER_CENTER - Header text is centered horizontally in the window
;                  |LVGA_HEADER_LEFT   - Header text is aligned at the left of the window
;                  |LVGA_HEADER_RIGHT  - Header text is aligned at the right of the window.
;                  Microsoft Windos Vista or later
;                      pszSubtitle;
;                      cchSubtitle;
;                      pszTask;
;                      cchTask;
;                      pszDescriptionTop;
;                      cchDescriptionTop;
;                      pszDescriptionBottom;
;                      cchDescriptionBottom;
;                      iTitleImage;
;                      iExtendedImage;
;                      iFirstItem;         // Read only
;                      cItems;             // Read only
;                      pszSubsetTitle;     // NULL if group is not subset
;                      cchSubsetTitle;
; Author ........: Paul Campbell (PaulIA)
; Modified ......: jpm
; Remarks .......:
; ===============================================================================================================================
Global Const $tagLVGROUP = "uint Size;uint Mask;ptr Header;int HeaderMax;ptr Footer;int FooterMax;int GroupID;uint StateMask;uint State;uint Align;" & _
		"ptr  pszSubtitle;uint cchSubtitle;ptr pszTask;uint cchTask;ptr pszDescriptionTop;uint cchDescriptionTop;ptr pszDescriptionBottom;" & _
		"uint cchDescriptionBottom;int iTitleImage;int iExtendedImage;int iFirstItem;uint cItems;ptr pszSubsetTitle;uint cchSubsetTitle"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagLVINSERTMARK
; Description ...: Used to describe insertion points
; Fields ........: Size     - Size of this structure, in bytes
;                  Flags    - Flag that specifies where the insertion point should appear:
;                  |$LVIM_AFTER - The insertion point appears after the item specified if the $LVIM_AFTER flag is set; otherwise
;                  +it appears before the specified item.
;                  Item     - Item next to which the insertion point appears. If -1, there is no insertion point.
;                  Reserved - Reserved. Must be set to 0.
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagLVINSERTMARK = "uint Size;dword Flags;int Item;dword Reserved"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagLVSETINFOTIP
; Description ...: Provides information about tooltip text that is to be set
; Fields ........: Size    - Size of this structure, in bytes
;                  Flags   - Flag that specifies how the text should be set. Set to zero.
;                  Text    - Pointer to a Unicode string that contains the tooltip text
;                  Item    - Contains the zero based index of the item to which this structure refers
;                  SubItem - Contains the one based index of the subitem to which this structure refers
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagLVSETINFOTIP = "uint Size;dword Flags;ptr Text;int Item;int SubItem"

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_AddArray
; Description ...: Adds items from an array to the control
; Syntax.........: _GUICtrlListView_AddArray($hWnd, ByRef $aItems)
; Parameters ....: $hWnd        - Handle to the control
;                  $aItems      - Array with the following format:
;                  |[0][0] - Item 1 Text
;                  |[0][1] - Item 1 Subitem 1 text
;                  |[0][2] - Item 1 Subitem 2 text
;                  |[0][n] - Item 1 Subitem n text
;                  |[1][0] - Item 2 Text
;                  |[1][1] - Item 2 Subitem 1 text
;                  |[1][2] - Item 2 Subitem 2 text
;                  |[1][n] - Item 2 Subitem n text
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_AddArray($hWnd, ByRef $aItems)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)

	Local $tItem = DllStructCreate($tagLVITEM)
	Local $tBuffer
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Text[4096]")
	Else
		$tBuffer = DllStructCreate("char Text[4096]")
	EndIf
	DllStructSetData($tItem, "Mask", $LVIF_TEXT)
	DllStructSetData($tItem, "Text", DllStructGetPtr($tBuffer))
	DllStructSetData($tItem, "TextMax", 4096)
	Local $iLastItem = _GUICtrlListView_GetItemCount($hWnd)
	_GUICtrlListView_BeginUpdate($hWnd)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			For $iI = 0 To UBound($aItems) - 1
				DllStructSetData($tItem, "Item", $iI)
				DllStructSetData($tItem, "SubItem", 0)
				DllStructSetData($tBuffer, "Text", $aItems[$iI][0])
				_SendMessage($hWnd, $LVM_INSERTITEMW, 0, $tItem, 0, "wparam", "struct*")
				For $iJ = 1 To UBound($aItems, 2) - 1
					DllStructSetData($tItem, "SubItem", $iJ)
					DllStructSetData($tBuffer, "Text", $aItems[$iI][$iJ])
					_SendMessage($hWnd, $LVM_SETITEMW, 0, $tItem, 0, "wparam", "struct*")
				Next
			Next
		Else
			Local $iBuffer = DllStructGetSize($tBuffer)
			Local $iItem = DllStructGetSize($tItem)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iItem + $iBuffer, $tMemMap)
			Local $pText = $pMemory + $iItem
			DllStructSetData($tItem, "Text", $pText)
			For $iI = 0 To UBound($aItems) - 1
				DllStructSetData($tItem, "Item", $iI + $iLastItem)
				DllStructSetData($tItem, "SubItem", 0)
				DllStructSetData($tBuffer, "Text", $aItems[$iI][0])
				_MemWrite($tMemMap, $tItem, $pMemory, $iItem)
				_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
				If $fUnicode Then
					_SendMessage($hWnd, $LVM_INSERTITEMW, 0, $pMemory, 0, "wparam", "ptr")
				Else
					_SendMessage($hWnd, $LVM_INSERTITEMA, 0, $pMemory, 0, "wparam", "ptr")
				EndIf
				For $iJ = 1 To UBound($aItems, 2) - 1
					DllStructSetData($tItem, "SubItem", $iJ)
					DllStructSetData($tBuffer, "Text", $aItems[$iI][$iJ])
					_MemWrite($tMemMap, $tItem, $pMemory, $iItem)
					_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
					If $fUnicode Then
						_SendMessage($hWnd, $LVM_SETITEMW, 0, $pMemory, 0, "wparam", "ptr")
					Else
						_SendMessage($hWnd, $LVM_SETITEMA, 0, $pMemory, 0, "wparam", "ptr")
					EndIf
				Next
			Next
			_MemFree($tMemMap)
		EndIf
	Else
		Local $pItem = DllStructGetPtr($tItem)
		For $iI = 0 To UBound($aItems) - 1
			DllStructSetData($tItem, "Item", $iI + $iLastItem)
			DllStructSetData($tItem, "SubItem", 0)
			DllStructSetData($tBuffer, "Text", $aItems[$iI][0])
			If $fUnicode Then
				GUICtrlSendMsg($hWnd, $LVM_INSERTITEMW, 0, $pItem)
			Else
				GUICtrlSendMsg($hWnd, $LVM_INSERTITEMA, 0, $pItem)
			EndIf
			For $iJ = 1 To UBound($aItems, 2) - 1
				DllStructSetData($tItem, "SubItem", $iJ)
				DllStructSetData($tBuffer, "Text", $aItems[$iI][$iJ])
				If $fUnicode Then
					GUICtrlSendMsg($hWnd, $LVM_SETITEMW, 0, $pItem)
				Else
					GUICtrlSendMsg($hWnd, $LVM_SETITEMA, 0, $pItem)
				EndIf
			Next
		Next
	EndIf
	_GUICtrlListView_EndUpdate($hWnd)
EndFunc   ;==>_GUICtrlListView_AddArray

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_AddColumn
; Description ...: Adds a new column in the control
; Syntax.........: _GUICtrlListView_AddColumn($hWnd, $sText[, $iWidth = 50[, $iAlign = -1[, $iImage = -1[, $fOnRight = False]]]])
; Parameters ....: $hWnd  - Handle to the control
;                  $sText       - Column header text
;                  $iWidth      - Width of the column, in pixels
;                  $iAlign      - Alignment of the column header and the subitem text in the column:
;                  |0 - Text is left aligned
;                  |1 - Text is right aligned
;                  |2 - Text is centered
;                  $iImage      - Zero based index of an image within the image list
;                  $fOnRight    - If True, the column image appears to the right of text
; Return values .: Success      - The index of the new column
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The alignment of the leftmost column is always left justified
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_AddColumn($hWnd, $sText, $iWidth = 50, $iAlign = -1, $iImage = -1, $fOnRight = False)
	Return _GUICtrlListView_InsertColumn($hWnd, _GUICtrlListView_GetColumnCount($hWnd), $sText, $iWidth, $iAlign, $iImage, $fOnRight)
EndFunc   ;==>_GUICtrlListView_AddColumn

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_AddItem
; Description ...: Adds a new item to the end of the list
; Syntax.........: _GUICtrlListView_AddItem($hWnd, $sText[, $iImage = -1[, $iParam = 0]])
; Parameters ....: $hWnd  - Handle to the control
;                  $sText       - Item text. If set to -1, the item set is set via the $LVN_GETDISPINFO notification message.
;                  $iImage      - Zero based index of the item's icon in the control's image list
;                  $iParam      - Application Defined data
; Return values .: Success      - The index of the new item
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: You can not use this function to insert subitems. Use _GUICtrlListView_AddSubItem to insert subitems.
; Related .......: _GUICtrlListView_AddSubItem
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_AddItem($hWnd, $sText, $iImage = -1, $iParam = 0)
	Return _GUICtrlListView_InsertItem($hWnd, $sText, -1, $iImage, $iParam)
EndFunc   ;==>_GUICtrlListView_AddItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_AddSubItem
; Description ...: Adds a new subitem to the control
; Syntax.........: _GUICtrlListView_AddSubItem($hWnd, $iIndex, $sText, $iSubItem[, $iImage = -1])
; Parameters ....: $hWnd  - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $sText       - Item or subitem text
;                  $iSubItem    - One based index of the subitem
;                  $iImage      - Zero based index of the icon in the control's image list
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_AddItem
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_AddSubItem($hWnd, $iIndex, $sText, $iSubItem, $iImage = -1)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)

	Local $iBuffer = StringLen($sText) + 1
	Local $tBuffer
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
		$iBuffer *= 2
	Else
		$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
	EndIf
	Local $pBuffer = DllStructGetPtr($tBuffer)
	Local $tItem = DllStructCreate($tagLVITEM)
	Local $iMask = $LVIF_TEXT
	If $iImage <> -1 Then $iMask = BitOR($iMask, $LVIF_IMAGE)
	DllStructSetData($tBuffer, "Text", $sText)
	DllStructSetData($tItem, "Mask", $iMask)
	DllStructSetData($tItem, "Item", $iIndex)
	DllStructSetData($tItem, "SubItem", $iSubItem)
	DllStructSetData($tItem, "Image", $iImage)
	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			DllStructSetData($tItem, "Text", $pBuffer)
			$iRet = _SendMessage($hWnd, $LVM_SETITEMW, 0, $tItem, 0, "wparam", "struct*")
		Else
			Local $iItem = DllStructGetSize($tItem)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iItem + $iBuffer, $tMemMap)
			Local $pText = $pMemory + $iItem
			DllStructSetData($tItem, "Text", $pText)
			_MemWrite($tMemMap, $tItem, $pMemory, $iItem)
			_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
			If $fUnicode Then
				$iRet = _SendMessage($hWnd, $LVM_SETITEMW, 0, $pMemory, 0, "wparam", "ptr")
			Else
				$iRet = _SendMessage($hWnd, $LVM_SETITEMA, 0, $pMemory, 0, "wparam", "ptr")
			EndIf
			_MemFree($tMemMap)
		EndIf
	Else
		Local $pItem = DllStructGetPtr($tItem)
		DllStructSetData($tItem, "Text", $pBuffer)
		If $fUnicode Then
			$iRet = GUICtrlSendMsg($hWnd, $LVM_SETITEMW, 0, $pItem)
		Else
			$iRet = GUICtrlSendMsg($hWnd, $LVM_SETITEMA, 0, $pItem)
		EndIf
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlListView_AddSubItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_ApproximateViewHeight
; Description ...: Calculates the approximate height required to display a given number of items
; Syntax.........: _GUICtrlListView_ApproximateViewHeight($hWnd[, $iCount = -1[, $iCX = -1[, $iCY = -1]]])
; Parameters ....: $hWnd  - Handle to the control
;                  $iCount      - Number of items to be displayed in the control. If this parameter is set to -1 the message uses
;                  +the total number of items in the control.
;                  $iCX         - Proposed X dimension of the control, in pixels.  This parameter can be set to -1 to  allow  the
;                  +message to use the current width value.
;                  $iCY         - Proposed Y dimension of the control, in pixels.  This parameter can be set to -1 to  allow  the
;                  +message to use the current height value.
; Return values .: Success      - Approximate height, in pixels, needed to display the items
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Setting the size of the control based on the dimensions provided by this message can optimize redraw and
;                  reduce flicker.
; Related .......: _GUICtrlListView_ApproximateViewWidth, _GUICtrlListView_ApproximateViewRect
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_ApproximateViewHeight($hWnd, $iCount = -1, $iCX = -1, $iCY = -1)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return BitShift((_SendMessage($hWnd, $LVM_APPROXIMATEVIEWRECT, $iCount, _WinAPI_MakeLong($iCX, $iCY))), 16)
	Else
		Return BitShift((GUICtrlSendMsg($hWnd, $LVM_APPROXIMATEVIEWRECT, $iCount, _WinAPI_MakeLong($iCX, $iCY))), 16)
	EndIf
EndFunc   ;==>_GUICtrlListView_ApproximateViewHeight

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_ApproximateViewRect
; Description ...: Calculates the approximate size required to display a given number of items
; Syntax.........: _GUICtrlListView_ApproximateViewRect($hWnd[, $iCount = -1[, $iCX = -1[, $iCY = -1]]])
; Parameters ....: $hWnd  - Handle to the control
;                  $iCount      - Number of items to be displayed in the control. If this parameter is set to -1 the message uses
;                  +the total number of items in the control.
;                  $iCX         - Proposed X dimension of the control, in pixels.  This parameter can be set to -1 to  allow  the
;                  +message to use the current width value.
;                  $iCY         - Proposed Y dimension of the control, in pixels.  This parameter can be set to -1 to  allow  the
;                  +message to use the current height value.
; Return values .: Success      - Array with the following format:
;                  |[0] - Approximate width, in pixels, needed to display the items
;                  |[1] - Approximate height, in pixels, needed to display the items
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Setting the size of the control based on the dimensions provided by this message can optimize redraw and
;                  reduce flicker.
; Related .......: _GUICtrlListView_ApproximateViewHeight, _GUICtrlListView_ApproximateViewWidth
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_ApproximateViewRect($hWnd, $iCount = -1, $iCX = -1, $iCY = -1)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $iView
	If IsHWnd($hWnd) Then
		$iView = _SendMessage($hWnd, $LVM_APPROXIMATEVIEWRECT, $iCount, _WinAPI_MakeLong($iCX, $iCY))
	Else
		$iView = GUICtrlSendMsg($hWnd, $LVM_APPROXIMATEVIEWRECT, $iCount, _WinAPI_MakeLong($iCX, $iCY))
	EndIf
	Local $aView[2]
	$aView[0] = BitAND($iView, 0xFFFF)
	$aView[1] = BitShift($iView, 16)
	Return $aView
EndFunc   ;==>_GUICtrlListView_ApproximateViewRect

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_ApproximateViewWidth
; Description ...: Calculates the approximate width required to display a given number of items
; Syntax.........: _GUICtrlListView_ApproximateViewWidth($hWnd[, $iCount = -1[, $iCX = -1[, $iCY = -1]]])
; Parameters ....: $hWnd  - Handle to the control
;                  $iCount      - Number of items to be displayed in the control. If this parameter is set to -1 the message uses
;                  +the total number of items in the control
;                  $iCX         - Proposed X dimension of the control, in pixels.  This parameter can be set to -1  to  allow the
;                  +message to use the current width value.
;                  $iCY         - Proposed Y dimension of the control, in pixels.  This parameter can be set to -1  to  allow the
;                  +message to use the current height value.
; Return values .: Success      - Approximate width, in pixels, needed to display the items
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Setting the size of the control based on the dimensions provided by this message can optimize redraw and
;                  reduce flicker.
; Related .......: _GUICtrlListView_ApproximateViewHeight, _GUICtrlListView_ApproximateViewRect
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_ApproximateViewWidth($hWnd, $iCount = -1, $iCX = -1, $iCY = -1)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return BitAND((_SendMessage($hWnd, $LVM_APPROXIMATEVIEWRECT, $iCount, _WinAPI_MakeLong($iCX, $iCY))), 0xFFFF)
	Else
		Return BitAND((GUICtrlSendMsg($hWnd, $LVM_APPROXIMATEVIEWRECT, $iCount, _WinAPI_MakeLong($iCX, $iCY))), 0xFFFF)
	EndIf
EndFunc   ;==>_GUICtrlListView_ApproximateViewWidth

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_Arrange
; Description ...: Arranges items in icon view
; Syntax.........: _GUICtrlListView_Arrange($hWnd[, $iArrange = 0])
; Parameters ....: $hWnd  - Handle to the control
;                  $iArrange    - Alignment. This can be one of the following values:
;                  |0 - Aligns items according to the controls default value
;                  |1 - Aligns items along the left edge of the window
;                  |2 - Aligns items along the top edge of the window
;                  |3 - Snaps all icons to the nearest grid position.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_SetItemPosition
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_Arrange($hWnd, $iArrange = 0)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $aArrange[4] = [$LVA_DEFAULT, $LVA_ALIGNLEFT, $LVA_ALIGNTOP, $LVA_SNAPTOGRID]
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_ARRANGE, $aArrange[$iArrange]) <> 0
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_ARRANGE, $aArrange[$iArrange], 0) <> 0
	EndIf
EndFunc   ;==>_GUICtrlListView_Arrange

; #INTERNAL_USE_ONLY#==============================================================================
; Name...........: __GUICtrlListView_ArrayDelete
; Description ...: Deletes the specified element from the given array, returning the adjusted array.
; Syntax.........: __GUICtrlListView_ArrayDelete(ByRef $avArray, $iElement)
; Parameters ....: $avArray     - The array from which an element is to be deleted
;                  $iElement    - The index of the element to be deleted
; Return values .: Success - Returns 1 and the original Array is updated
;                  Failure - Returns 0 and the original Array
; Author ........: Cephas <cephas at clergy dot net>
; Modified.......: Array is passed via Byref  - Jos van der zande, for exclusive use with listview sort - GaryFrost
; Remarks .......: For Internal Use Only
; Related .......:
; Link ..........:
; Example .......:
; =================================================================================================
Func __GUICtrlListView_ArrayDelete(ByRef $avArray, $iElement)
	If Not IsArray($avArray) Then Return SetError(1, 0, "")

	; We have to define this here so that we're sure that $avArray is an array
	; before we get it's size.
	Local $iUpper = UBound($avArray) ; Size of original array

	; If the array is only 1 element in size then we can't delete the 1 element.
	If $iUpper = 1 Then
		SetError(2)
		Return ""
	EndIf

	Local $avNewArray[$iUpper - 1][$iLListViewSortInfoSize]
	$avNewArray[0][0] = $avArray[0][0]
	If $iElement < 0 Then
		$iElement = 0
	EndIf
	If $iElement > ($iUpper - 1) Then
		$iElement = ($iUpper - 1)
	EndIf
	If $iElement > 0 Then
		For $iCntr = 0 To $iElement - 1
			For $x = 1 To $iLListViewSortInfoSize - 1
				$avNewArray[$iCntr][$x] = $avArray[$iCntr][$x]
			Next
		Next
	EndIf
	If $iElement < ($iUpper - 1) Then
		For $iCntr = ($iElement + 1) To ($iUpper - 1)
			For $x = 1 To $iLListViewSortInfoSize - 1
				$avNewArray[$iCntr - 1][$x] = $avArray[$iCntr][$x]
			Next
		Next
	EndIf
	$avArray = $avNewArray
	SetError(0)
	Return 1
EndFunc   ;==>__GUICtrlListView_ArrayDelete

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_BeginUpdate
; Description ...: Prevents updating of the control until the EndUpdate function is called
; Syntax.........: _GUICtrlListView_BeginUpdate($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_EndUpdate
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_BeginUpdate($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $__LISTVIEWCONSTANT_WM_SETREDRAW) = 0
EndFunc   ;==>_GUICtrlListView_BeginUpdate

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_CancelEditLabel
; Description ...: Cancels an item text editing operation
; Syntax.........: _GUICtrlListView_CancelEditLabel($hWnd)
; Parameters ....: $hWnd - Handle to the control
; Return values .: None
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Windows XP only
; Related .......: _GUICtrlListView_EditLabel, _GUICtrlListView_GetEditControl
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_CancelEditLabel($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		_SendMessage($hWnd, $LVM_CANCELEDITLABEL)
	Else
		GUICtrlSendMsg($hWnd, $LVM_CANCELEDITLABEL, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_CancelEditLabel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_ClickItem
; Description ...: Clicks an item
; Syntax.........: _GUICtrlListView_ClickItem($hWnd, $iIndex[, $sButton = "left"[, $fMove = False[, $iClicks = 1[, $iSpeed = 1]]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $sButton     - Button to click
;                  $fMove       - If True, the mouse will be moved. If False, the mouse does not move.
;                  $iClicks     - Number of clicks
;                  $iSpeed      - Delay between clicks
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_ClickItem($hWnd, $iIndex, $sButton = "left", $fMove = False, $iClicks = 1, $iSpeed = 1)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	_GUICtrlListView_EnsureVisible($hWnd, $iIndex, False)
	Local $tRect = _GUICtrlListView_GetItemRectEx($hWnd, $iIndex, $LVIR_LABEL)
	Local $tPoint = _WinAPI_PointFromRect($tRect, True)
	$tPoint = _WinAPI_ClientToScreen($hWnd, $tPoint)
	Local $iX, $iY
	_WinAPI_GetXYFromPoint($tPoint, $iX, $iY)
	Local $iMode = Opt("MouseCoordMode", 1)
	If Not $fMove Then
		Local $aPos = MouseGetPos()
		_WinAPI_ShowCursor(False)
		MouseClick($sButton, $iX, $iY, $iClicks, $iSpeed)
		MouseMove($aPos[0], $aPos[1], 0)
		_WinAPI_ShowCursor(True)
	Else
		MouseClick($sButton, $iX, $iY, $iClicks, $iSpeed)
	EndIf
	Opt("MouseCoordMode", $iMode)
EndFunc   ;==>_GUICtrlListView_ClickItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_CopyItems
; Description ...: Copy Items between 2 list-view controls
; Syntax.........: _GUICtrlListView_CopyItems($hWnd_Source, $hWnd_Destination[, $fDelFlag = False])
; Parameters ....: $hWnd_Source      - controlID
;                  $hWnd_Destination - control ID
;                  $fDelFlag         - Delete after copying
; Return values .: None
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_CopyItems($hWnd_Source, $hWnd_Destination, $fDelFlag = False)
	If $Debug_LV Then
		__UDF_ValidateClassName($hWnd_Source, $__LISTVIEWCONSTANT_ClassName)
		__UDF_ValidateClassName($hWnd_Destination, $__LISTVIEWCONSTANT_ClassName)
	EndIf

	Local $a_indices, $tItem = DllStructCreate($tagLVITEM), $iIndex
	Local $cols = _GUICtrlListView_GetColumnCount($hWnd_Source)

	Local $items = _GUICtrlListView_GetItemCount($hWnd_Source)
	_GUICtrlListView_BeginUpdate($hWnd_Source)
	_GUICtrlListView_BeginUpdate($hWnd_Destination)
	If BitAND(_GUICtrlListView_GetExtendedListViewStyle($hWnd_Source), $LVS_EX_CHECKBOXES) == $LVS_EX_CHECKBOXES Then
		For $i = 0 To $items - 1
			If (_GUICtrlListView_GetItemChecked($hWnd_Source, $i)) Then
				If IsArray($a_indices) Then
					ReDim $a_indices[UBound($a_indices) + 1]
				Else
					Local $a_indices[2]
				EndIf
				$a_indices[0] = $a_indices[0] + 1
				$a_indices[UBound($a_indices) - 1] = $i
			EndIf
		Next

		If (IsArray($a_indices)) Then
			For $i = 1 To $a_indices[0]
				DllStructSetData($tItem, "Mask", BitOR($LVIF_GROUPID, $LVIF_IMAGE, $LVIF_INDENT, $LVIF_PARAM, $LVIF_STATE))
				DllStructSetData($tItem, "Item", $a_indices[$i])
				DllStructSetData($tItem, "SubItem", 0)
				DllStructSetData($tItem, "StateMask", -1)
				_GUICtrlListView_GetItemEx($hWnd_Source, $tItem)
				$iIndex = _GUICtrlListView_AddItem($hWnd_Destination, _GUICtrlListView_GetItemText($hWnd_Source, $a_indices[$i], 0), DllStructGetData($tItem, "Image"))
				_GUICtrlListView_SetItemChecked($hWnd_Destination, $iIndex)
				For $x = 1 To $cols - 1
					DllStructSetData($tItem, "Item", $a_indices[$i])
					DllStructSetData($tItem, "SubItem", $x)
					_GUICtrlListView_GetItemEx($hWnd_Source, $tItem)
					_GUICtrlListView_AddSubItem($hWnd_Destination, $iIndex, _GUICtrlListView_GetItemText($hWnd_Source, $a_indices[$i], $x), $x, DllStructGetData($tItem, "Image"))
				Next
;~ 				_GUICtrlListView_SetItemChecked($hWnd_Source, $a_indices[$i], False)
			Next
			If $fDelFlag Then
				For $i = $a_indices[0] To 1 Step -1
					_GUICtrlListView_DeleteItem($hWnd_Source, $a_indices[$i])
				Next
			EndIf
		EndIf
	EndIf
	If (_GUICtrlListView_GetSelectedCount($hWnd_Source)) Then
		$a_indices = _GUICtrlListView_GetSelectedIndices($hWnd_Source, 1)
		For $i = 1 To $a_indices[0]
			DllStructSetData($tItem, "Mask", BitOR($LVIF_GROUPID, $LVIF_IMAGE, $LVIF_INDENT, $LVIF_PARAM, $LVIF_STATE))
			DllStructSetData($tItem, "Item", $a_indices[$i])
			DllStructSetData($tItem, "SubItem", 0)
			DllStructSetData($tItem, "StateMask", -1)
			_GUICtrlListView_GetItemEx($hWnd_Source, $tItem)
			$iIndex = _GUICtrlListView_AddItem($hWnd_Destination, _GUICtrlListView_GetItemText($hWnd_Source, $a_indices[$i], 0), DllStructGetData($tItem, "Image"))
			For $x = 1 To $cols - 1
				DllStructSetData($tItem, "Item", $a_indices[$i])
				DllStructSetData($tItem, "SubItem", $x)
				_GUICtrlListView_GetItemEx($hWnd_Source, $tItem)
				_GUICtrlListView_AddSubItem($hWnd_Destination, $iIndex, _GUICtrlListView_GetItemText($hWnd_Source, $a_indices[$i], $x), $x, DllStructGetData($tItem, "Image"))
			Next
		Next
		_GUICtrlListView_SetItemSelected($hWnd_Source, -1, False)
		If $fDelFlag Then
			For $i = $a_indices[0] To 1 Step -1
				_GUICtrlListView_DeleteItem($hWnd_Source, $a_indices[$i])
			Next
		EndIf
	EndIf
	_GUICtrlListView_EndUpdate($hWnd_Source)
	_GUICtrlListView_EndUpdate($hWnd_Destination)
EndFunc   ;==>_GUICtrlListView_CopyItems

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_Create
; Description ...: Create a ListView control
; Syntax.........: _GUICtrlListView_Create($hWnd, $sHeaderText, $iX, $iY[, $iWidth = 150[, $iHeight = 150[, $iStyle = 0x0000000D[, $iExStyle = 0x00000000[, $fCoInit = False]]]]])
; Parameters ....: $hWnd        - Handle to parent or owner window
;                  $sHeaderText - Text to be displayed in the header. Pipe "|" delimited.
;                  $iX          - Horizontal position of the control
;                  $iY          - Vertical position of the control
;                  $iWidth      - Control width
;                  $iHeight     - Control height
;                  $iStyle      - Control styles:
;                  |$LVS_ALIGNLEFT       - Items are left aligned in icon and small icon view
;                  |$LVS_ALIGNTOP        - Items are aligned with the top of the control in icon and small icon view
;                  |$LVS_AUTOARRANGE     - Icons are automatically kept arranged in icon and small icon view
;                  |$LVS_EDITLABELS      - Item text can be edited in place
;                  |$LVS_ICON            - This style specifies icon view
;                  |$LVS_LIST            - This style specifies list view
;                  |$LVS_NOCOLUMNHEADER  - Column headers are not displayed in report view
;                  |$LVS_NOLABELWRAP     - Item text is displayed on a single line in icon view
;                  |$LVS_NOSCROLL        - Scrolling is disabled
;                  |$LVS_NOSORTHEADER    - Column headers do not work like buttons
;                  |$LVS_OWNERDATA       - This style specifies a virtual control
;                  |$LVS_OWNERDRAWFIXED  - The owner window can paint items in report view
;                  |$LVS_REPORT          - This style specifies report view
;                  |$LVS_SHAREIMAGELISTS - The image list will not be deleted
;                  |$LVS_SHOWSELALWAYS   - The selection, if any, is always shown
;                  |$LVS_SINGLESEL       - Only one item at a time can be selected
;                  |$LVS_SMALLICON       - This style specifies small icon view
;                  |$LVS_SORTASCENDING   - Item indexes are sorted in ascending order
;                  |$LVS_SORTDESCENDING  - Item indexes are sorted in descending order
;                  -
;                  |Default: $LVS_REPORT, $LVS_SINGLESEL, $LVS_SHOWSELALWAYS
;                  |Forced : $WS_CHILD, $WS_VISIBLE
;                  $iExStyle    - Extended control styles. Can be a combination of the following:
;                  |$LVS_EX_BORDERSELECT     - When an item is selected the border color of the item changes
;                  |$LVS_EX_CHECKBOXES       - Enables check boxes for items in a list-view control
;                  |$LVS_EX_DOUBLEBUFFER     - Paints via double-buffering, which reduces flicker
;                  |$LVS_EX_FLATSB           - Enables flat scroll bars in the list view
;                  |$LVS_EX_FULLROWSELECT    - When an item is selected, the item and all its subitems are highlighted
;                  |$LVS_EX_GRIDLINES        - Displays gridlines around items and subitems
;                  |$LVS_EX_HEADERDRAGDROP   - Enables drag-and-drop reordering of columns
;                  |$LVS_EX_INFOTIP          - The $LVN_GETINFOTIP notification message is sent before displaying a ToolTip
;                  |$LVS_EX_LABELTIP         - If not set, the unfolds partly hidden labels only for the large icon mode
;                  |$LVS_EX_MULTIWORKAREAS   - The control will not autoarrange its icons until one or more work areas are defined
;                  |$LVS_EX_ONECLICKACTIVATE - The control sends an $LVN_ITEMACTIVATE messages when the user clicks an item
;                  |$LVS_EX_REGIONAL         - Sets the control region to include only the item icons and text
;                  |$LVS_EX_SIMPLESELECT     - In icon view moves the state image of the control to the top right
;                  |$LVS_EX_SUBITEMIMAGES    - Allows images to be displayed for subitems
;                  |$LVS_EX_TRACKSELECT      - Enables hot-track selection in the control
;                  |$LVS_EX_TWOCLICKACTIVATE - The control sends an $LVN_ITEMACTIVATE message when the user double-clicks an item
;                  |$LVS_EX_UNDERLINECOLD    - Causes non-hot items that may be activated to be displayed with underlined text
;                  |$LVS_EX_UNDERLINEHOT     - Causes hot items that may be activated to be displayed with underlined text
;                  -
;                  $fCoInit     - Initializes the COM library for use by the calling thread.
; Return values .: Success      - Handle to the ListView control
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; Remarks .......: This function is for Advanced users and for learning how the control works.
; Related .......: _GUICtrlListView_Destroy, _GUICtrlListView_SetBkImage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_Create($hWnd, $sHeaderText, $iX, $iY, $iWidth = 150, $iHeight = 150, $iStyle = 0x0000000D, $iExStyle = 0x00000000, $fCoInit = False)
	If Not IsHWnd($hWnd) Then Return SetError(1, 0, 0) ; Invalid Window handle for _GUICtrlListViewCreate 1st parameter
	If Not IsString($sHeaderText) Then Return SetError(2, 0, 0) ; 2nd parameter not a string for _GUICtrlListViewCreate

	If $iWidth = -1 Then $iWidth = 150
	If $iHeight = -1 Then $iHeight = 150
	If $iStyle = -1 Then $iStyle = $LVS_DEFAULT
	If $iExStyle = -1 Then $iExStyle = 0x00000000

	Local Const $S_OK = 0x0
	Local Const $S_FALSE = 0x1
	Local Const $RPC_E_CHANGED_MODE = 0x80010106
	Local Const $E_INVALIDARG = 0x80070057
	Local Const $E_OUTOFMEMORY = 0x8007000E
	Local Const $E_UNEXPECTED = 0x8000FFFF
	Local $SeparatorChar = Opt('GUIDataSeparatorChar')
	;======================================
	Local Const $COINIT_APARTMENTTHREADED = 0x02
	;======================================
	Local $str_len = StringLen($sHeaderText)
	If $str_len Then $sHeaderText = StringSplit($sHeaderText, $SeparatorChar)

	$iStyle = BitOR($__UDFGUICONSTANT_WS_CHILD, $__UDFGUICONSTANT_WS_VISIBLE, $iStyle)

	;=========================================================================================================
	If $fCoInit Then
		Local $aResult = DllCall('ole32.dll', 'long', 'CoInitializeEx', 'ptr', 0, 'dword', $COINIT_APARTMENTTHREADED)
		If @error Then Return SetError(@error, @extended, 0)
		Switch $aResult[0]
			Case $S_OK
				If $Debug_LV Then __UDF_DebugPrint("The COM library was initialized successfully on the calling thread.")
			Case $S_FALSE
				If $Debug_LV Then __UDF_DebugPrint("The COM library is already initialized on the calling thread.")
			Case $RPC_E_CHANGED_MODE
				If $Debug_LV Then __UDF_DebugPrint("A previous call to CoInitializeEx specified a different concurrency model for the calling thread," & @LF & _
						"-->or the thread that called CoInitializeEx currently belongs to the neutral threaded apartment.")
			Case $E_INVALIDARG
				If $Debug_LV Then __UDF_DebugPrint("Invalid Arg")
			Case $E_OUTOFMEMORY
				If $Debug_LV Then __UDF_DebugPrint("Out of memory")
			Case $E_UNEXPECTED
				If $Debug_LV Then __UDF_DebugPrint("Unexpected error")
		EndSwitch
	EndIf
	;=========================================================================================================
	Local $nCtrlID = __UDF_GetNextGlobalID($hWnd)
	If @error Then Return SetError(@error, @extended, 0)

	Local $hList = _WinAPI_CreateWindowEx($iExStyle, $__LISTVIEWCONSTANT_ClassName, "", $iStyle, $iX, $iY, $iWidth, $iHeight, $hWnd, $nCtrlID)
	_SendMessage($hList, $__LISTVIEWCONSTANT_WM_SETFONT, _WinAPI_GetStockObject($__LISTVIEWCONSTANT_DEFAULT_GUI_FONT), True)
	If $str_len Then
		For $x = 1 To $sHeaderText[0]
			_GUICtrlListView_InsertColumn($hList, $x - 1, $sHeaderText[$x], 75)
		Next
	EndIf
	Return $hList
EndFunc   ;==>_GUICtrlListView_Create

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_CreateDragImage
; Description ...: Creates a drag image list for the specified item
; Syntax.........: _GUICtrlListView_CreateDragImage($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
; Return values .: Success      - Array with the following format:
;                  |[0] - Handle to the drag image list if successful, otherwise 0
;                  |[1] - X coordinate of the upper left corner of the image
;                  |[2] - Y coordinate of the upper left corner of the image
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: You are responsible for destroying the image list when it is no longer needed
; Related .......: _GUICtrlListView_DrawDragImage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_CreateDragImage($hWnd, $iIndex)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $aDrag[3]

	Local $tPoint = DllStructCreate($tagPOINT)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			$aDrag[0] = _SendMessage($hWnd, $LVM_CREATEDRAGIMAGE, $iIndex, $tPoint, 0, "wparam", "struct*", "handle")
		Else
			Local $iPoint = DllStructGetSize($tPoint)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iPoint, $tMemMap)
			$aDrag[0] = _SendMessage($hWnd, $LVM_CREATEDRAGIMAGE, $iIndex, $pMemory, 0, "wparam", "ptr", "handle")
			_MemRead($tMemMap, $pMemory, $tPoint, $iPoint)
			_MemFree($tMemMap)
		EndIf
	Else
		$aDrag[0] = Ptr(GUICtrlSendMsg($hWnd, $LVM_CREATEDRAGIMAGE, $iIndex, DllStructGetPtr($tPoint)))
	EndIf
	$aDrag[1] = DllStructGetData($tPoint, "X")
	$aDrag[2] = DllStructGetData($tPoint, "Y")
	Return $aDrag
EndFunc   ;==>_GUICtrlListView_CreateDragImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_CreateSolidBitMap
; Description ...: Creates a solid color bitmap
; Syntax.........: _GUICtrlListView_CreateSolidBitMap($hWnd, $iColor, $iWidth, $iHeight)
; Parameters ....: $hWnd        - Handle to the window where the bitmap will be displayed
;                  $iColor      - The color of the bitmap, stated in RGB
;                  $iWidth      - The width of the bitmap
;                  $iHeight     - The height of the bitmap
; Return values .: Success      - Handle to the bitmap
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_CreateSolidBitMap($hWnd, $iColor, $iWidth, $iHeight)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
	Return _WinAPI_CreateSolidBitmap($hWnd, $iColor, $iWidth, $iHeight)
EndFunc   ;==>_GUICtrlListView_CreateSolidBitMap

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_DeleteAllItems
; Description ...: Removes all items from a list-view control
; Syntax.........: _GUICtrlListView_DeleteAllItems($hWnd)
; Parameters ....: $hWnd        - Control ID/Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_DeleteItem, _GUICtrlListView_DeleteItemsSelected
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_DeleteAllItems($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If _GUICtrlListView_GetItemCount($hWnd) == 0 Then Return True
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_DELETEALLITEMS) <> 0
	Else
		Local $ctrlID
		For $index = _GUICtrlListView_GetItemCount($hWnd) - 1 To 0 Step -1
			$ctrlID = _GUICtrlListView_GetItemParam($hWnd, $index)
			If $ctrlID Then GUICtrlDelete($ctrlID)
		Next
		If _GUICtrlListView_GetItemCount($hWnd) == 0 Then Return True
	EndIf
	Return False
EndFunc   ;==>_GUICtrlListView_DeleteAllItems

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_DeleteColumn
; Description ...: Removes a column from a list-view control
; Syntax.........: _GUICtrlListView_DeleteColumn($hWnd, $iCol)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCol        - Index of the column to delete
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Column zero of the list-view control cannot be deleted.
;+
;                  If you must delete column zero, insert a zero length dummy
;                  column zero, and delete column one and above
; Related .......: _GUICtrlListView_InsertColumn
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_DeleteColumn($hWnd, $iCol)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_DELETECOLUMN, $iCol) <> 0
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_DELETECOLUMN, $iCol, 0) <> 0
	EndIf
EndFunc   ;==>_GUICtrlListView_DeleteColumn

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_DeleteItem
; Description ...: Removes an item from a list-view control
; Syntax.........: _GUICtrlListView_DeleteItem($hWnd, $iIndex)
; Parameters ....: $hWnd        - Control ID/Handle to the control
;                  $iIndex      - Zero based index of the list-view item to delete
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_DeleteAllItems, _GUICtrlListView_DeleteItemsSelected
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_DeleteItem($hWnd, $iIndex)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_DELETEITEM, $iIndex) <> 0
	Else
		Local $ctrlID = _GUICtrlListView_GetItemParam($hWnd, $iIndex)
		If $ctrlID Then Return GUICtrlDelete($ctrlID) <> 0
	EndIf
	Return False
EndFunc   ;==>_GUICtrlListView_DeleteItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_DeleteItemsSelected
; Description ...: Deletes item(s) selected
; Syntax.........: _GUICtrlListView_DeleteItemsSelected($hWnd)
; Parameters ....: $hWnd        - Control ID/Handle to the control
; Return values .: Success - True
;                  Failure - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_DeleteItem, _GUICtrlListView_DeleteAllItems
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_DeleteItemsSelected($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $ItemCount = _GUICtrlListView_GetItemCount($hWnd)
	If (_GUICtrlListView_GetSelectedCount($hWnd) == $ItemCount) Then
		Return _GUICtrlListView_DeleteAllItems($hWnd)
	Else
		Local $items = _GUICtrlListView_GetSelectedIndices($hWnd, 1)
		If Not IsArray($items) Then Return SetError($LV_ERR, $LV_ERR, 0)
		_GUICtrlListView_SetItemSelected($hWnd, -1, False)
		For $i = $items[0] To 1 Step -1
			If Not _GUICtrlListView_DeleteItem($hWnd, $items[$i]) Then Return False
		Next
		Return True
	EndIf
EndFunc   ;==>_GUICtrlListView_DeleteItemsSelected

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_Destroy
; Description ...: Delete the listview control
; Syntax.........: _GUICtrlListView_Destroy(ByRef $hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True, Handle is set to 0
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Restricted to only be used on ListViews created with _GUICtrlListView_Create
; Related .......: _GUICtrlListView_Create
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_Destroy(ByRef $hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)
	If Not _WinAPI_IsClassName($hWnd, $__LISTVIEWCONSTANT_ClassName) Then Return SetError(2, 2, False)

	Local $Destroyed = 0
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
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
EndFunc   ;==>_GUICtrlListView_Destroy

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlListView_Draw
; Description ...: Draws an image list item in the specified device context
; Syntax.........: __GUICtrlListView_Draw($hWnd, $iIndex, $hDC, $iX, $iY[, $iStyle=0])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the image to draw
;                  $hDC         - Handle to the destination device context
;                  $iX          - X coordinate where the image will be drawn
;                  $iY          - Y coordinate where the image will be drawn
;                  $iStyle      - Drawing style and overlay image:
;                  |1 - Draws the image transparently using the mask, regardless of the background color
;                  |2 - Draws the image, blending 25 percent with the system highlight color
;                  |4 - Draws the image, blending 50 percent with the system highlight color
;                  |8 - Draws the mask
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func __GUICtrlListView_Draw($hWnd, $iIndex, $hDC, $iX, $iY, $iStyle = 0)
	Local $iFlags = 0

	If BitAND($iStyle, 1) <> 0 Then $iFlags = BitOR($iFlags, $__LISTVIEWCONSTANT_ILD_TRANSPARENT)
	If BitAND($iStyle, 2) <> 0 Then $iFlags = BitOR($iFlags, $__LISTVIEWCONSTANT_ILD_BLEND25)
	If BitAND($iStyle, 4) <> 0 Then $iFlags = BitOR($iFlags, $__LISTVIEWCONSTANT_ILD_BLEND50)
	If BitAND($iStyle, 8) <> 0 Then $iFlags = BitOR($iFlags, $__LISTVIEWCONSTANT_ILD_MASK)
	Local $aResult = DllCall("ComCtl32.dll", "bool", "ImageList_Draw", "handle", $hWnd, "int", $iIndex, "handle", $hDC, "int", $iX, "int", $iY, "uint", $iFlags)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0]
EndFunc   ;==>__GUICtrlListView_Draw

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_DrawDragImage
; Description ...: Draw the Drage Image
; Syntax.........: _GUICtrlListView_DrawDragImage(ByRef $hWnd, ByRef $aDrag)
; Parameters ....: $hWnd        - Handle to the control
;                  $aDrag       - Array with the following format:
;                  |[0] - Handle to the drag image list
;                  |[1] - X coordinate of the upper left corner of the image
;                  |[2] - Y coordinate of the upper left corner of the image
; Return values .: None
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_CreateDragImage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_DrawDragImage(ByRef $hWnd, ByRef $aDrag)
	Local $hDC = _WinAPI_GetWindowDC($hWnd)
	Local $tPoint = _WinAPI_GetMousePos(True, $hWnd)
	_WinAPI_InvalidateRect($hWnd)
	__GUICtrlListView_Draw($aDrag[0], 0, $hDC, DllStructGetData($tPoint, "X"), DllStructGetData($tPoint, "Y"))
	_WinAPI_ReleaseDC($hWnd, $hDC)
EndFunc   ;==>_GUICtrlListView_DrawDragImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_EditLabel
; Description ...: Begins in place editing of the specified item text
; Syntax.........: _GUICtrlListView_EditLabel($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item to edit
; Return values .: Success      - Returns the handle to the edit control that is used to edit the item
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: When the user completes or cancels editing, the edit control is destroyed and the handle is no longer valid.
;                  You can subclass the edit control, but you should not destroy it.
; Related .......: _GUICtrlListView_CancelEditLabel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_EditLabel($hWnd, $iIndex)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)

	Local $aResult
	If IsHWnd($hWnd) Then
		$aResult = DllCall("user32.dll", "hwnd", "SetFocus", "hwnd", $hWnd)
		If @error Then Return SetError(@error, @extended, 0)
		If $aResult = 0 Then Return 0

		If $fUnicode Then
			Return _SendMessage($hWnd, $LVM_EDITLABELW, $iIndex, 0, 0, "wparam", "lparam", "hwnd")
		Else
			Return _SendMessage($hWnd, $LVM_EDITLABEL, $iIndex, 0, 0, "wparam", "lparam", "hwnd")
		EndIf
	Else
		$aResult = DllCall("user32.dll", "hwnd", "SetFocus", "hwnd", GUICtrlGetHandle($hWnd))
		If @error Then Return SetError(@error, @extended, 0)
		If $aResult = 0 Then Return 0

		If $fUnicode Then
			Return HWnd(GUICtrlSendMsg($hWnd, $LVM_EDITLABELW, $iIndex, 0))
		Else
			Return HWnd(GUICtrlSendMsg($hWnd, $LVM_EDITLABEL, $iIndex, 0))
		EndIf
	EndIf
EndFunc   ;==>_GUICtrlListView_EditLabel

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_EnableGroupView
; Description ...: Enables or disables whether the items in the control display as a group
; Syntax.........: _GUICtrlListView_EnableGroupView($hWnd[, $fEnable = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $fEnable     - Indicates whether to enable group displayed items
;                  | True       - Enable group view
;                  |False       - Disable group view
; Return values .: 0            - The ability to display listview items as a group is already enabled or disabled
;                  1            - The state of the control was successfully changed
;                  -1           - The operation failed
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Minimum operating systems Windows XP.
;+
;                  This function is not supported under the $LVS_OWNERDATA style.
; Related .......: _GUICtrlListView_GetGroupViewEnabled
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_EnableGroupView($hWnd, $fEnable = True)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_ENABLEGROUPVIEW, $fEnable)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_ENABLEGROUPVIEW, $fEnable, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_EnableGroupView

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_EndUpdate
; Description ...: Enables screen repainting that was turned off with the BeginUpdate function
; Syntax.........: _GUICtrlListView_EndUpdate($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_BeginUpdate
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_EndUpdate($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Return _SendMessage($hWnd, $__LISTVIEWCONSTANT_WM_SETREDRAW, 1) = 0
EndFunc   ;==>_GUICtrlListView_EndUpdate

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_EnsureVisible
; Description ...: Ensures that a list-view item is either entirely or partially visible
; Syntax.........: _GUICtrlListView_EnsureVisible($hWnd, $iIndex[, $fPartialOK = False])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Index of the list-view item
;                  $fPartialOK  - Value specifying whether the item must be entirely visible
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If $fPartialOK parameter is TRUE, no scrolling occurs if the item is at least partially visible
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_EnsureVisible($hWnd, $iIndex, $fPartialOK = False)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_ENSUREVISIBLE, $iIndex, $fPartialOK)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_ENSUREVISIBLE, $iIndex, $fPartialOK)
	EndIf
EndFunc   ;==>_GUICtrlListView_EnsureVisible

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_FindInText
; Description ...: Searches for an item that contains the specified text anywhere in its text
; Syntax.........: _GUICtrlListView_FindInText($hWnd, $sText[, $iStart = -1[, $fWrapOK = True[, $fReverse = False]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $sText       - Text to match
;                  $iStart      - Zero based index of the item to begin the search with or -1 to start from  the  beginning.  The
;                  +specified item is itself excluded from the search.
;                  $fWrapOK     - If True, the search will continue with the first item if no match is found
;                  $fReverse    - If True, the search will start at $iStart - 1 to Zero. If $fWrapOK = True search will continue
;                 +from the end to 1 item before $iStart.
; Return values .: Success      - The zero based index of the item
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (added reverse search)
; Remarks .......: The search is case insensitive. Unlike _GUICtrlListView_FindText, this function will search all subitems for the text
;                  as well.
; Related .......: _GUICtrlListView_FindText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_FindInText($hWnd, $sText, $iStart = -1, $fWrapOK = True, $fReverse = False)

	Local $iCount = _GUICtrlListView_GetItemCount($hWnd)
	Local $iColumns = _GUICtrlListView_GetColumnCount($hWnd)
	If $iColumns = 0 Then $iColumns = 1

	If $fReverse And $iStart = -1 Then Return -1

	Local $sList
	If $fReverse Then
		For $iI = $iStart - 1 To 0 Step -1
			For $iJ = 0 To $iColumns - 1
				$sList = _GUICtrlListView_GetItemText($hWnd, $iI, $iJ)
				If StringInStr($sList, $sText) Then Return $iI
			Next
		Next
	Else
		For $iI = $iStart + 1 To $iCount - 1
			For $iJ = 0 To $iColumns - 1
				$sList = _GUICtrlListView_GetItemText($hWnd, $iI, $iJ)
				If StringInStr($sList, $sText) Then Return $iI
			Next
		Next
	EndIf

	If (($iStart = -1) Or Not $fWrapOK) And Not $fReverse Then Return -1

	If $fReverse And $fWrapOK Then
		For $iI = $iCount - 1 To $iStart + 1 Step -1
			For $iJ = 0 To $iColumns - 1
				$sList = _GUICtrlListView_GetItemText($hWnd, $iI, $iJ)
				If StringInStr($sList, $sText) Then Return $iI
			Next
		Next
	Else
		For $iI = 0 To $iStart - 1
			For $iJ = 0 To $iColumns - 1
				$sList = _GUICtrlListView_GetItemText($hWnd, $iI, $iJ)
				If StringInStr($sList, $sText) Then Return $iI
			Next
		Next
	EndIf

	Return -1
EndFunc   ;==>_GUICtrlListView_FindInText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_FindItem
; Description ...: Searches for an item with the specified characteristics
; Syntax.........: _GUICtrlListView_FindItem($hWnd, $iStart, ByRef $tFindInfo[, $sText = ""])
; Parameters ....: $hWnd  - Handle to the control
;                  $iStart      - Zero based index of the item to begin the search with or -1 to start from  the  beginning.  The
;                  +specified item is itself excluded from the search.
;                  $tFindInfo   - $tagLVFINDINFO structure that contains the search information
;                  $sText       - String to compare with the item text. It is valid if $LVFI_STRING or $LVFI_PARTIAL is set in the
;                  +Flags member
; Return values .: Success      - The zero based index of the item
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_FindParam, _GUICtrlListView_FindNearest, $tagLVFINDINFO
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_FindItem($hWnd, $iStart, ByRef $tFindInfo, $sText = "")
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $iBuffer = StringLen($sText) + 1
	Local $tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
	Local $pBuffer = DllStructGetPtr($tBuffer)
	DllStructSetData($tBuffer, "Text", $sText)
	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			DllStructSetData($tFindInfo, "Text", $pBuffer)
			$iRet = _SendMessage($hWnd, $LVM_FINDITEM, $iStart, $tFindInfo, 0, "wparam", "struct*")
		Else
			Local $iFindInfo = DllStructGetSize($tFindInfo)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iFindInfo + $iBuffer, $tMemMap)
			Local $pText = $pMemory + $iFindInfo
			DllStructSetData($tFindInfo, "Text", $pText)
			_MemWrite($tMemMap, $tFindInfo, $pMemory, $iFindInfo)
			_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
			$iRet = _SendMessage($hWnd, $LVM_FINDITEM, $iStart, $pMemory, 0, "wparam", "ptr")
			_MemFree($tMemMap)
		EndIf
	Else
		DllStructSetData($tFindInfo, "Text", $pBuffer)
		$iRet = GUICtrlSendMsg($hWnd, $LVM_FINDITEM, $iStart, DllStructGetPtr($tFindInfo))
	EndIf
	Return $iRet
EndFunc   ;==>_GUICtrlListView_FindItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_FindNearest
; Description ...: Finds the item nearest to the position specified
; Syntax.........: _GUICtrlListView_FindNearest($hWnd, $iX, $iY[, $iDir = 0[, $iStart = -1[, $fWrapOK = True]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $iX          - X position
;                  $iY          - Y position
;                  $iDir        - Specifies which direction to search:
;                  |0 - Left
;                  |1 - Right
;                  |2 - Up
;                  |3 - Down
;                  |4 - From start
;                  |5 - From end
;                  |6 - From prior item
;                  |7 - From next item
;                  $iStart      - Zero based index of the item to begin the search with or -1 to start from  the  beginning.  The
;                  +specified item is itself excluded from the search.
;                  $fWrapOK     - If True, the search will continue with the first item if no match is found
; Return values .: Success      - The zero based index of the item
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function is supported only by large icon and small icon modes
; Related .......: _GUICtrlListView_FindItem
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_FindNearest($hWnd, $iX, $iY, $iDir = 0, $iStart = -1, $fWrapOK = True)
	Local $aDir[8] = [$__LISTVIEWCONSTANT_VK_LEFT, $__LISTVIEWCONSTANT_VK_RIGHT, $__LISTVIEWCONSTANT_VK_UP, $__LISTVIEWCONSTANT_VK_DOWN, $__LISTVIEWCONSTANT_VK_HOME, $__LISTVIEWCONSTANT_VK_END, $__LISTVIEWCONSTANT_VK_PRIOR, $__LISTVIEWCONSTANT_VK_NEXT]

	Local $tFindInfo = DllStructCreate($tagLVFINDINFO)
	Local $iFlags = $LVFI_NEARESTXY
	If $fWrapOK Then $iFlags = BitOR($iFlags, $LVFI_WRAP)
	DllStructSetData($tFindInfo, "Flags", $iFlags)
	DllStructSetData($tFindInfo, "X", $iX)
	DllStructSetData($tFindInfo, "Y", $iY)
	DllStructSetData($tFindInfo, "Direction", $aDir[$iDir])
	Return _GUICtrlListView_FindItem($hWnd, $iStart, $tFindInfo)
EndFunc   ;==>_GUICtrlListView_FindNearest

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_FindParam
; Description ...: Searches for an item with the specified lParam
; Syntax.........: _GUICtrlListView_FindParam($hWnd, $iParam[, $iStart = -1])
; Parameters ....: $hWnd        - Handle to the control
;                  $iParam      - Param value to search for
;                  $iStart      - Zero based index of the item to begin the search with or -1 to start from  the  beginning.  The
;                  +specified item is itself excluded from the search.
; Return values .: Success      - The zero based index of the item
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_FindItem
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_FindParam($hWnd, $iParam, $iStart = -1)
	Local $tFindInfo = DllStructCreate($tagLVFINDINFO)
	DllStructSetData($tFindInfo, "Flags", $LVFI_PARAM)
	DllStructSetData($tFindInfo, "Param", $iParam)
	Return _GUICtrlListView_FindItem($hWnd, $iStart, $tFindInfo)
EndFunc   ;==>_GUICtrlListView_FindParam

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_FindText
; Description ...: Searches for an item with the specified text
; Syntax.........: _GUICtrlListView_FindText($hWnd, $sText[, $iStart = -1[, $fPartialOK = True[, $fWrapOK = True]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $sText       - Text to match
;                  $iStart      - Zero based index of the item to begin the search with or -1 to start from  the  beginning.  The
;                  +specified item is itself excluded from the search.
;                  $fPartialOK  - If True, a match will occur if the item text begins with the text
;                  $fWrapOK     - If True, the search will continue with the first item if no match is  found
; Return values .: Success      - The zero based index of the item
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The search is case insensitive. The search is performed on the item only. Use _GUICtrlListView_FindInText if you want
;                  to search for the text in subitems.
; Related .......: _GUICtrlListView_FindInText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_FindText($hWnd, $sText, $iStart = -1, $fPartialOK = True, $fWrapOK = True)
	Local $tFindInfo = DllStructCreate($tagLVFINDINFO)
	Local $iFlags = $LVFI_STRING
	If $fPartialOK Then $iFlags = BitOR($iFlags, $LVFI_PARTIAL)
	If $fWrapOK Then $iFlags = BitOR($iFlags, $LVFI_WRAP)
	DllStructSetData($tFindInfo, "Flags", $iFlags)
	Return _GUICtrlListView_FindItem($hWnd, $iStart, $tFindInfo, $sText)
EndFunc   ;==>_GUICtrlListView_FindText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetBkColor
; Description ...: Retrieves the background color of a list-view control
; Syntax.........: _GUICtrlListView_GetBkColor($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Hex RGB background color
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_SetBkColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetBkColor($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $v_color
	If IsHWnd($hWnd) Then
		$v_color = _SendMessage($hWnd, $LVM_GETBKCOLOR)
	Else
		$v_color = GUICtrlSendMsg($hWnd, $LVM_GETBKCOLOR, 0, 0)
	EndIf
	Return __GUICtrlListView_ReverseColorOrder($v_color)
EndFunc   ;==>_GUICtrlListView_GetBkColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetBkImage
; Description ...: Retrieves the background image in the control
; Syntax.........: _GUICtrlListView_GetBkImage($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Array with the following format:
;                  |[0] - One or more of the following flags:
;                  | 0 - The control has no background
;                  | 1 - The background is from a bitmap
;                  | 2 - The background is from a URL
;                  |[1] - URL of the background image
;                  |[2] - Percentage of the client area that the image should be X offset
;                  |[3] - Percentage of the client area that the image should be Y offset
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_SetBkImage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetBkImage($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)
	Local $fUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)

	Local $tBuffer
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Text[4096]")
	Else
		$tBuffer = DllStructCreate("char Text[4096]")
	EndIf
	Local $pBuffer = DllStructGetPtr($tBuffer)
	Local $tImage = DllStructCreate($tagLVBKIMAGE)
	DllStructSetData($tImage, "ImageMax", 4096)
	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			DllStructSetData($tImage, "Image", $pBuffer)
			$iRet = _SendMessage($hWnd, $LVM_GETBKIMAGEW, 0, $tImage, 0, "wparam", "struct*")
		Else
			Local $iBuffer = DllStructGetSize($tBuffer)
			Local $iImage = DllStructGetSize($tImage)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iImage + $iBuffer, $tMemMap)
			Local $pText = $pMemory + $iImage
			DllStructSetData($tImage, "Image", $pText)
			_MemWrite($tMemMap, $tImage, $pMemory, $iImage)
			If $fUnicode Then
				$iRet = _SendMessage($hWnd, $LVM_GETBKIMAGEW, 0, $pMemory, 0, "wparam", "ptr")
			Else
				$iRet = _SendMessage($hWnd, $LVM_GETBKIMAGEA, 0, $pMemory, 0, "wparam", "ptr")
			EndIf
			_MemRead($tMemMap, $pMemory, $tImage, $iImage)
			_MemRead($tMemMap, $pText, $tBuffer, $iBuffer)
			_MemFree($tMemMap)
		EndIf
	Else
		Local $pImage = DllStructGetPtr($tImage)
		DllStructSetData($tImage, "Image", $pBuffer)
		If $fUnicode Then
			$iRet = GUICtrlSendMsg($hWnd, $LVM_GETBKIMAGEW, 0, $pImage)
		Else
			$iRet = GUICtrlSendMsg($hWnd, $LVM_GETBKIMAGEA, 0, $pImage)
		EndIf
	EndIf
	Local $aImage[4]
	Switch BitAND(DllStructGetData($tImage, "Flags"), $LVBKIF_SOURCE_MASK)
		Case $LVBKIF_SOURCE_HBITMAP
			$aImage[0] = 1
		Case $LVBKIF_SOURCE_URL
			$aImage[0] = 2
	EndSwitch
	$aImage[1] = DllStructGetData($tBuffer, "Text")
	$aImage[2] = DllStructGetData($tImage, "XOffPercent")
	$aImage[3] = DllStructGetData($tImage, "YOffPercent")
	Return SetError($iRet <> 0, 0, $aImage)
EndFunc   ;==>_GUICtrlListView_GetBkImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetCallbackMask
; Description ...: Retrieves the callback mask for the control
; Syntax.........: _GUICtrlListView_GetCallbackMask($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Value of the callback mask. The bits of the mask indicate the item states or images  for  which
;                  +the application stores the current state data.  This value can be any combination of the following:
;                  | 1 - The item is marked for a cut-and-paste operation
;                  | 2 - The item is highlighted as a drag-and-drop target
;                  | 4 - The item has the focus
;                  | 8 - The item is selected
;                  |16 - The application stores the image list index of the current overlay image
;                  |32 - The application stores the image list index of the current state image
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: The callback mask is a set of bit flags that specify the item states for which the application, rather than
;                  the control, stores the current data.
;+
;                  The callback mask applies to all of the control's items, unlike the callback item designation, which applies
;                  to a specific item.  The callback mask is zero by default, meaning that the control stores all item state
;                  information.
; Related .......: _GUICtrlListView_SetCallBackMask
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetCallbackMask($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $iFlags = 0
	Local $iMask = _SendMessage($hWnd, $LVM_GETCALLBACKMASK)
	If BitAND($iMask, $LVIS_CUT) <> 0 Then $iFlags = BitOR($iFlags, 1)
	If BitAND($iMask, $LVIS_DROPHILITED) <> 0 Then $iFlags = BitOR($iFlags, 2)
	If BitAND($iMask, $LVIS_FOCUSED) <> 0 Then $iFlags = BitOR($iFlags, 4)
	If BitAND($iMask, $LVIS_SELECTED) <> 0 Then $iFlags = BitOR($iFlags, 8)
	If BitAND($iMask, $LVIS_OVERLAYMASK) <> 0 Then $iFlags = BitOR($iFlags, 16)
	If BitAND($iMask, $LVIS_STATEIMAGEMASK) <> 0 Then $iFlags = BitOR($iFlags, 32)
	Return $iFlags
EndFunc   ;==>_GUICtrlListView_GetCallbackMask

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetColumn
; Description ...: Retrieves the attributes of a column
; Syntax.........: _GUICtrlListView_GetColumn($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of column
; Return values .: Success      - Array with the following format:
;                  |[0] - Alignment of the column header and the subitem text in the column:
;                  | 0 - Text is left-aligned
;                  | 1 - Text is right-aligned
;                  | 2 - Text is centered
;                  |[1] - True if item displays an image from an image list
;                  |[2] - True if bitmap appears to the right of text
;                  |[3] - True header contains an image
;                  |[4] - Width of the column, in pixels
;                  |[5] - Column header text
;                  |[6] - Index of subitem associated with the column
;                  |[7] - Zero-based index of an image within the image list
;                  |[8] - Zero-based column order
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_SetColumnn, _GUICtrlListView_JustifyColumn
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetColumn($hWnd, $iIndex)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)
	Local $fUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)

	Local $tBuffer
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Text[4096]")
	Else
		$tBuffer = DllStructCreate("char Text[4096]")
	EndIf
	Local $pBuffer = DllStructGetPtr($tBuffer)
	Local $tColumn = DllStructCreate($tagLVCOLUMN)
	DllStructSetData($tColumn, "Mask", $LVCF_ALLDATA)
	DllStructSetData($tColumn, "TextMax", 4096)
	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			DllStructSetData($tColumn, "Text", $pBuffer)
			$iRet = _SendMessage($hWnd, $LVM_GETCOLUMNW, $iIndex, $tColumn, 0, "wparam", "struct*")
		Else
			Local $iBuffer = DllStructGetSize($tBuffer)
			Local $iColumn = DllStructGetSize($tColumn)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iColumn + $iBuffer, $tMemMap)
			Local $pText = $pMemory + $iColumn
			DllStructSetData($tColumn, "Text", $pText)
			_MemWrite($tMemMap, $tColumn, $pMemory, $iColumn)
			If $fUnicode Then
				$iRet = _SendMessage($hWnd, $LVM_GETCOLUMNW, $iIndex, $pMemory, 0, "wparam", "ptr")
			Else
				$iRet = _SendMessage($hWnd, $LVM_GETCOLUMNA, $iIndex, $pMemory, 0, "wparam", "ptr")
			EndIf
			_MemRead($tMemMap, $pMemory, $tColumn, $iColumn)
			_MemRead($tMemMap, $pText, $tBuffer, $iBuffer)
			_MemFree($tMemMap)
		EndIf
	Else
		Local $pColumn = DllStructGetPtr($tColumn)
		DllStructSetData($tColumn, "Text", $pBuffer)
		If $fUnicode Then
			$iRet = GUICtrlSendMsg($hWnd, $LVM_GETCOLUMNW, $iIndex, $pColumn)
		Else
			$iRet = GUICtrlSendMsg($hWnd, $LVM_GETCOLUMNA, $iIndex, $pColumn)
		EndIf
	EndIf
	Local $aColumn[9]
	Switch BitAND(DllStructGetData($tColumn, "Fmt"), $LVCFMT_JUSTIFYMASK)
		Case $LVCFMT_RIGHT
			$aColumn[0] = 1
		Case $LVCFMT_CENTER
			$aColumn[0] = 2
		Case Else
			$aColumn[0] = 0
	EndSwitch
	$aColumn[1] = BitAND(DllStructGetData($tColumn, "Fmt"), $LVCFMT_IMAGE) <> 0
	$aColumn[2] = BitAND(DllStructGetData($tColumn, "Fmt"), $LVCFMT_BITMAP_ON_RIGHT) <> 0
	$aColumn[3] = BitAND(DllStructGetData($tColumn, "Fmt"), $LVCFMT_COL_HAS_IMAGES) <> 0
	$aColumn[4] = DllStructGetData($tColumn, "CX")
	$aColumn[5] = DllStructGetData($tBuffer, "Text")
	$aColumn[6] = DllStructGetData($tColumn, "SubItem")
	$aColumn[7] = DllStructGetData($tColumn, "Image")
	$aColumn[8] = DllStructGetData($tColumn, "Order")
	Return SetError($iRet = 0, 0, $aColumn)
EndFunc   ;==>_GUICtrlListView_GetColumn

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetColumnCount
; Description ...: Retrieve the number of columns
; Syntax.........: _GUICtrlListView_GetColumnCount($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Number of columns
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetColumnCount($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

;~ 	Local Const $HDM_GETITEMCOUNT = 0x1200
	Return _SendMessage(_GUICtrlListView_GetHeader($hWnd), 0x1200)
EndFunc   ;==>_GUICtrlListView_GetColumnCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetColumnOrder
; Description ...: Retrieves the current left-to-right order of columns
; Syntax.........: _GUICtrlListView_GetColumnOrder($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - delimited string
;                  Failure      - $LV_ERR
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_SetColumnOrder, _GUICtrlListView_SetColumnOrderArray
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetColumnOrder($hWnd)
	Local $a_cols = _GUICtrlListView_GetColumnOrderArray($hWnd), $s_cols = ""
	Local $SeparatorChar = Opt('GUIDataSeparatorChar')
	For $i = 1 To $a_cols[0]
		$s_cols &= $a_cols[$i] & $SeparatorChar
	Next
	$s_cols = StringTrimRight($s_cols, 1)
	Return $s_cols
EndFunc   ;==>_GUICtrlListView_GetColumnOrder

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetColumnOrderArray
; Description ...: Retrieves the current left-to-right order of columns in the control
; Syntax.........: _GUICtrlListView_GetColumnOrderArray($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Array with the following format:
;                  |[0] - Number of items in array (n)
;                  |[1] - First column index
;                  |[2] - First column index
;                  |[n] - Last column index
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_SetColumnOrderArray
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetColumnOrderArray($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $iColumns = _GUICtrlListView_GetColumnCount($hWnd)
	Local $tBuffer = DllStructCreate("int[" & $iColumns & "]")
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			_SendMessage($hWnd, $LVM_GETCOLUMNORDERARRAY, $iColumns, $tBuffer, 0, "wparam", "struct*")
		Else
			Local $iBuffer = DllStructGetSize($tBuffer)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iBuffer, $tMemMap)
			_SendMessage($hWnd, $LVM_GETCOLUMNORDERARRAY, $iColumns, $pMemory, 0, "wparam", "ptr")
			_MemRead($tMemMap, $pMemory, $tBuffer, $iBuffer)
			_MemFree($tMemMap)
		EndIf
	Else
		GUICtrlSendMsg($hWnd, $LVM_GETCOLUMNORDERARRAY, $iColumns, DllStructGetPtr($tBuffer))
	EndIf

	Local $aBuffer[$iColumns + 1]
	$aBuffer[0] = $iColumns
	For $iI = 1 To $iColumns
		$aBuffer[$iI] = DllStructGetData($tBuffer, 1, $iI)
	Next
	Return $aBuffer
EndFunc   ;==>_GUICtrlListView_GetColumnOrderArray

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetColumnWidth
; Description ...: Retrieves the width of a column in report or list view
; Syntax.........: _GUICtrlListView_GetColumnWidth($hWnd, $iCol)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCol        - The index of the column. This parameter is ignored in list view.
; Return values .: Success      - Column width
;                  Failure      - Zero
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If this message is sent to a list-view control with the $LVS_REPORT style
;                  and the specified column doesn't exist, the return value is undefined.
; Related .......: _GUICtrlListView_SetColumnWidth
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetColumnWidth($hWnd, $iCol)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETCOLUMNWIDTH, $iCol)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_GETCOLUMNWIDTH, $iCol, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetColumnWidth

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetCounterPage
; Description ...: Calculates the number of items that can fit vertically in the visible area
; Syntax.........: _GUICtrlListView_GetCounterPage($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The number of fully visible items
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If the current view is icon or small icon view, the return value is the total number
;                  of items in the list-view control.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetCounterPage($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETCOUNTPERPAGE)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_GETCOUNTPERPAGE, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetCounterPage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetEditControl
; Description ...: Retrieves the handle to the edit control being used to edit an item's text
; Syntax.........: _GUICtrlListView_GetEditControl($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The handle to the edit control
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: When label editing begins, an edit control is created, positioned, and initialized.  Before displayed, the
;                  control sends its parent window an $LVN_BEGINLABELEDIT notification message.
;+
;                  If you want to customize label editing implement a handler for $LVN_BEGINLABELEDITA,  $LVN_BEGINLABELEDITAW
;                  and have it send an $LVM_GETEDITCONTROL message to the control. If a label is being edited, the return value
;                  will be a handle to the edit control. Use this handle to customize the edit control by sending the usual EM_XXX messages.
;+
;                  When the user completes or cancels editing, the edit control is destroyed and the handle is no longer valid.
;                  You can subclass the edit control, but you should not destroy it.  To cancel editing, send the control a
;                  $WM_CANCELMODE message.
;+
;                  The control item  being edited is the currently focused item. To find an item based on its state, use the
;                  $LVM_GETNEXTITEM message.
; Related .......: _GUICtrlListView_CancelEditLabel
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetEditControl($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return HWnd(_SendMessage($hWnd, $LVM_GETEDITCONTROL))
	Else
		Return HWnd(GUICtrlSendMsg($hWnd, $LVM_GETEDITCONTROL, 0, 0))
	EndIf
EndFunc   ;==>_GUICtrlListView_GetEditControl

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlListView_GetEmptyText
; Description ...: Gets the text meant for display when the list-view control appears empty
; Syntax.........: _GUICtrlListView_GetEmptyText($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Text meant for display when the list-view control appears emtpy
;                  Failure      - ""
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Minimum OS: Windows Vista
; Related .......:
; Link ..........: @@MsdnLink@@ LVM_GETEMPTYTEXT
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetEmptyText($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $tText = DllStructCreate("char[4096]")
	Local $iRet

	If IsHWnd($hWnd) Then
		Local $iText = DllStructGetSize($tText)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iText + 4096, $tMemMap)
		Local $pText = $pMemory + $iText
		DllStructSetData($tText, "Text", $pText)
		_MemWrite($tMemMap, $pText, $pMemory, $iText)
		$iRet = _SendMessage($hWnd, $LVM_GETEMPTYTEXT, 4096, $pMemory)
		_MemRead($tMemMap, $pText, $tText, 4096)
		_MemFree($tMemMap)
		If $iRet = 0 Then Return SetError(-1, 0, "")
		Return DllStructGetData($tText, 1)
	Else
		$iRet = GUICtrlSendMsg($hWnd, $LVM_GETEMPTYTEXT, 4096, DllStructGetPtr($tText))
		If $iRet = 0 Then Return SetError(-1, 0, "")
		Return DllStructGetData($tText, 1)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetEmptyText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetExtendedListViewStyle
; Description ...: Retrieves the extended styles that are currently in use
; Syntax.........: _GUICtrlListView_GetExtendedListViewStyle($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - DWORD that represents the styles currently in use for a given list-view
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_SetExtendedListViewStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetExtendedListViewStyle($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETEXTENDEDLISTVIEWSTYLE)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetExtendedListViewStyle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetFocusedGroup
; Description ...: Gets the group that has the focus
; Syntax.........: _GUICtrlListView_GetFocusedGroup($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Returns the index of the group with state of $LVGS_FOCUSED, or -1 if there is no group with state of $LVGS_FOCUSED
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Minimum operating systems: Windows Vista
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetFocusedGroup($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETFOCUSEDGROUP)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_GETFOCUSEDGROUP, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetFocusedGroup

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetGroupCount
; Description ...: Gets the number of groups
; Syntax.........: _GUICtrlListView_GetGroupCount($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Returns the number of groups
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Minimum operating systems: Windows Vista
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetGroupCount($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETGROUPCOUNT)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_GETGROUPCOUNT, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetGroupCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetGroupInfo
; Description ...: Retrieves group information
; Syntax.........: _GUICtrlListView_GetGroupInfo($hWnd, $iGroupID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iGroupID    - ID that specifies the group whose information is retrieved
; Return values .: Success      - Array with the following format:
;                  |[0] - Header text
;                  |[1] - Header alignment:
;                  | 0 - Left
;                  | 1 - Center
;                  | 2 - Right
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Minimum operating systems: Windows XP
; Related .......: _GUICtrlListView_SetGroupInfo, _GUICtrlListView_GetGroupInfoByIndex
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetGroupInfo($hWnd, $iGroupID)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $tGroup = DllStructCreate($tagLVGROUP)
	Local $iGroup = DllStructGetSize($tGroup)
	DllStructSetData($tGroup, "Size", $iGroup)
	DllStructSetData($tGroup, "Mask", BitOR($LVGF_HEADER, $LVGF_ALIGN))
	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			$iRet = _SendMessage($hWnd, $LVM_GETGROUPINFO, $iGroupID, $tGroup, 0, "wparam", "struct*")
		Else
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iGroup, $tMemMap)
			_MemWrite($tMemMap, $tGroup, $pMemory, $iGroup)
			$iRet = _SendMessage($hWnd, $LVM_GETGROUPINFO, $iGroupID, $pMemory, 0, "wparam", "ptr")
			_MemRead($tMemMap, $pMemory, $tGroup, $iGroup)
			_MemFree($tMemMap)
		EndIf
	Else
		$iRet = GUICtrlSendMsg($hWnd, $LVM_GETGROUPINFO, $iGroupID, DllStructGetPtr($tGroup))
	EndIf
	Local $aGroup[2]
	$aGroup[0] = _WinAPI_WideCharToMultiByte(DllStructGetData($tGroup, "Header"))
	Select
		Case BitAND(DllStructGetData($tGroup, "Align"), $LVGA_HEADER_CENTER) <> 0
			$aGroup[1] = 1
		Case BitAND(DllStructGetData($tGroup, "Align"), $LVGA_HEADER_RIGHT) <> 0
			$aGroup[1] = 2
		Case Else
			$aGroup[1] = 0
	EndSelect
	Return SetError($iRet <> $iGroupID, 0, $aGroup)
EndFunc   ;==>_GUICtrlListView_GetGroupInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetGroupInfoByIndex
; Description ...: Retrieves group information
; Syntax.........: _GUICtrlListView_GetGroupInfoByIndex($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex    - Zero based index that specifies the group whose information is retrieved
; Return values .: Success      - Array with the following format:
;                  |[0] - Header text
;                  |[1] - Header alignment:
;                  | 0 - Left
;                  | 1 - Center
;                  | 2 - Right
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Minimum operating systems: Windows Vista
; Related .......: _GUICtrlListView_SetGroupInfo, _GUICtrlListView_GetGroupInfo
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetGroupInfoByIndex($hWnd, $iIndex)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $tGroup = DllStructCreate($tagLVGROUP)
	Local $iGroup = DllStructGetSize($tGroup)
	DllStructSetData($tGroup, "Size", $iGroup)
	DllStructSetData($tGroup, "Mask", BitOR($LVGF_HEADER, $LVGF_ALIGN))
	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			$iRet = _SendMessage($hWnd, $LVM_GETGROUPINFOBYINDEX, $iIndex, $tGroup, 0, "wparam", "struct*")
		Else
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iGroup, $tMemMap)
			_MemWrite($tMemMap, $tGroup, $pMemory, $iGroup)
			$iRet = _SendMessage($hWnd, $LVM_GETGROUPINFOBYINDEX, $iIndex, $pMemory, 0, "wparam", "ptr")
			_MemRead($tMemMap, $pMemory, $tGroup, $iGroup)
			_MemFree($tMemMap)
		EndIf
	Else
		$iRet = GUICtrlSendMsg($hWnd, $LVM_GETGROUPINFOBYINDEX, $iIndex, DllStructGetPtr($tGroup))
	EndIf
	Local $aGroup[2]
	$aGroup[0] = _WinAPI_WideCharToMultiByte(DllStructGetData($tGroup, "Header"))
	Select
		Case BitAND(DllStructGetData($tGroup, "Align"), $LVGA_HEADER_CENTER) <> 0
			$aGroup[1] = 1
		Case BitAND(DllStructGetData($tGroup, "Align"), $LVGA_HEADER_RIGHT) <> 0
			$aGroup[1] = 2
		Case Else
			$aGroup[1] = 0
	EndSelect
	Return SetError($iRet = 0, 0, $aGroup)
EndFunc   ;==>_GUICtrlListView_GetGroupInfoByIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetGroupRect
; Description ...: Gets the rectangle for a specified group
; Syntax.........: _GUICtrlListView_GetGroupRect($hWnd, $iGroupID[, $iGet = $LVGGR_GROUP])
; Parameters ....: $hWnd        - Handle to the control
;                  $iGroupID    - ID that specifies the group whose information is retrieved
;                  $iGet        - Flag to specify the coordinates of the rectangle to get, can be one of the following:
;                  |  $LVGGR_GROUP      - Coordinates of the entire expanded group
;                  |  $LVGGR_HEADER     - Coordinates of the header only (collapsed group)
;                  |  $LVGGR_LABEL      - Coordinates of the label only
;                  |  $LVGGR_SUBSETLINK - Coordinates of the subset link only (markup subset)
; Return values .: Success      - Array with the following format:
;                  |[0] - Specifies the x-coordinate of the upper-left corner of the rectangle
;                  |[1] - Specifies the y-coordinate of the upper-left corner of the rectangle
;                  |[2] - Specifies the x-coordinate of the lower-right corner of the rectangle
;                  |[3] - Specifies the y-coordinate of the lower-right corner of the rectangle
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Minimum operating systems: Windows Vista
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetGroupRect($hWnd, $iGroupID, $iGet = $LVGGR_GROUP)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $tGroup = DllStructCreate($tagRECT)
	DllStructSetData($tGroup, "Left", $iGet)
	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			$iRet = _SendMessage($hWnd, $LVM_GETGROUPRECT, $iGroupID, $tGroup, 0, "wparam", "struct*")
		Else
			Local $iGroup = DllStructGetSize($tGroup)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iGroup, $tMemMap)
			_MemWrite($tMemMap, $tGroup, $pMemory, $iGroup)
			$iRet = _SendMessage($hWnd, $LVM_GETGROUPRECT, $iGroupID, $pMemory, 0, "wparam", "ptr")
			_MemRead($tMemMap, $pMemory, $tGroup, $iGroup)
			_MemFree($tMemMap)
		EndIf
	Else
		$iRet = GUICtrlSendMsg($hWnd, $LVM_GETGROUPRECT, $iGroupID, DllStructGetPtr($tGroup))
	EndIf
	Local $aGroup[4]
	For $x = 0 To 3
		$aGroup[$x] = DllStructGetData($tGroup, $x + 1)
	Next
	Return SetError($iRet = 0, 0, $aGroup)
EndFunc   ;==>_GUICtrlListView_GetGroupRect

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlListView_GetGroupState
; Description ...: Gets the state for a specified group
; Syntax.........: _GUICtrlListView_GetGroupState($hWnd, $iGroupID, $iMask)
; Parameters ....: $hWnd        - Handle to the control
;                  $iGroupID    - ID that specifies the group whose information is retrieved
;                  $iMask       - Can be a combination of the following:
;                  |  $LVGS_NORMAL            - Groups are expanded, the group name is displayed, and all items in the group are displayed.
;                  |  $LVGS_COLLAPSED         - The group is collapsed.
;                  |  $LVGS_HIDDEN            - The group is hidden.
;                  |  $LVGS_NOHEADER          - The group does not display a header
;                  |  $LVGS_COLLAPSIBLE       - The group can be collapsed
;                  |  $LVGS_FOCUSED           - The group has keyboard focus
;                  |  $LVGS_SELECTED          - The group is selected
;                  |  $LVGS_SUBSETED          - The group displays only a portion of its items
;                  |  $LVGS_SUBSETLINKFOCUSED - The subset link of the group has keyboard focus
; Return values .: Success      - Returns the combination of state values that are set
;                  Failure      - 0
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Minimum operating systems: Windows Vista
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetGroupState($hWnd, $iGroupID, $iMask)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETGROUPSTATE, $iGroupID, $iMask)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_GETGROUPSTATE, $iGroupID, $iMask)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetGroupState

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetGroupViewEnabled
; Description ...: Checks whether the control has group view enabled
; Syntax.........: _GUICtrlListView_GetGroupViewEnabled($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Group view setting:
;                  | True - Group view is enabled
;                  |False - Group view is not enabled
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Minimum operating systems Windows XP.
; Related .......: _GUICtrlListView_EnableGroupView
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetGroupViewEnabled($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_ISGROUPVIEWENABLED) <> 0
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_ISGROUPVIEWENABLED, 0, 0) <> 0
	EndIf
EndFunc   ;==>_GUICtrlListView_GetGroupViewEnabled

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetHeader
; Description ...: Retrieves the handle to the header control
; Syntax.........: _GUICtrlListView_GetHeader($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The handle to the header control
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetHeader($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return HWnd(_SendMessage($hWnd, $LVM_GETHEADER))
	Else
		Return HWnd(GUICtrlSendMsg($hWnd, $LVM_GETHEADER, 0, 0))
	EndIf
EndFunc   ;==>_GUICtrlListView_GetHeader

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetHotCursor
; Description ...: Retrieves the HCURSOR value used when the pointer is over an item while hot tracking is enabled
; Syntax.........: _GUICtrlListView_GetHotCursor($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - An HCURSOR value that is the handle to the cursor that the list-view
;                  +control uses when hot tracking is enabled.
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: A list-view control uses hot tracking and hover selection when the $LVS_EX_TRACKSELECT style is set.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetHotCursor($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETHOTCURSOR, 0, 0, 0, "wparam", "lparam", "handle")
	Else
		Return Ptr(GUICtrlSendMsg($hWnd, $LVM_GETHOTCURSOR, 0, 0))
	EndIf
EndFunc   ;==>_GUICtrlListView_GetHotCursor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetHotItem
; Description ...: Retrieves the index of the hot item
; Syntax.........: _GUICtrlListView_GetHotItem($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The index of the item that is hot
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_SetHotItem
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetHotItem($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETHOTITEM)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_GETHOTITEM, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetHotItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetHoverTime
; Description ...: Retrieves the amount of time that the mouse cursor must hover over an item before it is selected
; Syntax.........: _GUICtrlListView_GetHoverTime($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The amount of time, in milliseconds, that the mouse cursor must hover over an item
;                  +before it is selected.  If the return value is (DWORD)-1, then the hover time is the
;                  +default hover time.
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The hover time only affects list-view controls that have the $LVS_EX_TRACKSELECT, $LVS_EX_ONECLICKACTIVATE,
;                  or $LVS_EX_TWOCLICKACTIVATE extended list-view style.
; Related .......: _GUICtrlListView_SetHoverTime
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetHoverTime($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETHOVERTIME)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_GETHOVERTIME, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetHoverTime

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetImageList
; Description ...: Retrieves the handle to an image list used for drawing listview items
; Syntax.........: _GUICtrlListView_GetImageList($hWnd, $iImageList)
; Parameters ....: $hWnd        - Handle to the control
;                  $iImageList  - Image list to retrieve:
;                  |0 - Image list with large icons
;                  |1 - Image list with small icons
;                  |2 - Image list with state images
; Return values .: Success      - The handle to the specified image list
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_SetImageList
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetImageList($hWnd, $iImageList)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $aImageList[3] = [$LVSIL_NORMAL, $LVSIL_SMALL, $LVSIL_STATE]
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETIMAGELIST, $aImageList[$iImageList], 0, 0, "wparam", "lparam", "handle")
	Else
		Return Ptr(GUICtrlSendMsg($hWnd, $LVM_GETIMAGELIST, $aImageList[$iImageList], 0))
	EndIf
EndFunc   ;==>_GUICtrlListView_GetImageList

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlListView_GetInsertMark
; Description ...: Retrieves the position of the insertion point
; Syntax.........: _GUICtrlListView_GetInsertMark($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Array with the following format:
;                  |[0] - True if the insertion point appears after the item, otherwise False
;                  |[1] - Item next to which the insertion point appears.  If this is -1, there is no insertion point.
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Minimum operating systems Windows XP.
;+
;                  An insertion point can appear only if the control is in icon view, small icon view, or tile view,
;                  and is not in group view mode.
; Related .......: _GUICtrlListView_SetInsertMark
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlListView_GetInsertMark($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $tMark = DllStructCreate($tagLVINSERTMARK)
	Local $iMark = DllStructGetSize($tMark)
	DllStructSetData($tMark, "Size", $iMark)
	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			$iRet = _SendMessage($hWnd, $LVM_GETINSERTMARK, 0, $tMark, 0, "wparam", "struct*")
		Else
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iMark, $tMemMap)
			_MemWrite($tMemMap, $tMark)
			$iRet = _SendMessage($hWnd, $LVM_GETINSERTMARK, 0, $pMemory, 0, "wparam", "ptr")
			_MemRead($tMemMap, $pMemory, $tMark, $iMark)
			_MemFree($tMemMap)
		EndIf
	Else
		$iRet = GUICtrlSendMsg($hWnd, $LVM_GETINSERTMARK, 0, DllStructGetPtr($tMark))
	EndIf
	Local $aMark[2]
	$aMark[0] = DllStructGetData($tMark, "Flags") = $LVIM_AFTER
	$aMark[1] = DllStructGetData($tMark, "Item")
	Return SetError($iRet = 0, 0, $aMark)
EndFunc   ;==>_GUICtrlListView_GetInsertMark

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlListView_GetInsertMarkColor
; Description ...: Retrieves the color of the insertion point
; Syntax.........: _GUICtrlListView_GetInsertMarkColor($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Color of the insertion point
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Minimum operating systems Windows XP.
; Related .......: _GUICtrlListView_SetInsertMarkColor
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlListView_GetInsertMarkColor($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETINSERTMARKCOLOR, $LVSIL_STATE)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_GETINSERTMARKCOLOR, $LVSIL_STATE, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetInsertMarkColor

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlListView_GetInsertMarkRect
; Description ...: Retrieves the rectangle that bounds the insertion point
; Syntax.........: _GUICtrlListView_GetInsertMarkRect($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Array with the following format:
;                  |[0] = True if insertion point found, otherwise False
;                  |[1] = X coordinate of the upper left corner of the rectangle
;                  |[2] = Y coordinate of the upper left corner of the rectangle
;                  |[3] = X coordinate of the lower right corner of the rectangle
;                  |[4] = Y coordinate of the lower right corner of the rectangle
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Minimum operating systems Windows XP.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlListView_GetInsertMarkRect($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $aRect[5]

	Local $tRect = DllStructCreate($tagRECT)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			$aRect[0] = _SendMessage($hWnd, $LVM_GETINSERTMARKRECT, 0, $tRect, 0, "wparam", "struct*") <> 0
		Else
			Local $iRect = DllStructGetSize($tRect)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iRect, $tMemMap)
			$aRect[0] = _SendMessage($hWnd, $LVM_GETINSERTMARKRECT, 0, $pMemory, 0, "wparam", "ptr") <> 0
			_MemRead($tMemMap, $pMemory, $tRect, $iRect)
			_MemFree($tMemMap)
		EndIf
	Else
		$aRect[0] = GUICtrlSendMsg($hWnd, $LVM_GETINSERTMARKRECT, 0, DllStructGetPtr($tRect)) <> 0
	EndIf
	$aRect[1] = DllStructGetData($tRect, "Left")
	$aRect[2] = DllStructGetData($tRect, "Top")
	$aRect[3] = DllStructGetData($tRect, "Right")
	$aRect[4] = DllStructGetData($tRect, "Bottom")
	Return $aRect
EndFunc   ;==>_GUICtrlListView_GetInsertMarkRect

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetISearchString
; Description ...: Retrieves the incremental search string of the control
; Syntax.........: _GUICtrlListView_GetISearchString($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Incremental search string or a blank string if no search string exists
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: The incremental search string is the character sequence that the user types while the list view
;                  has the input focus. Each time the user types a character, the system appends the character to
;                  the search string and then searches for a matching item. If the system finds a match, it selects
;                  the item and, if necessary, scrolls it into view.
;+
;                  A time-out period is associated with each character that the user types. If the time-out period
;                  elapses before the user types another character, the incremental search string is reset.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetISearchString($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)

	Local $iBuffer
	If IsHWnd($hWnd) Then
		If $fUnicode Then
			$iBuffer = _SendMessage($hWnd, $LVM_GETISEARCHSTRINGW) + 1
		Else
			$iBuffer = _SendMessage($hWnd, $LVM_GETISEARCHSTRINGA) + 1
		EndIf
	Else
		If $fUnicode Then
			$iBuffer = GUICtrlSendMsg($hWnd, $LVM_GETISEARCHSTRINGW, 0, 0) + 1
		Else
			$iBuffer = GUICtrlSendMsg($hWnd, $LVM_GETISEARCHSTRINGA, 0, 0) + 1
		EndIf
	EndIf
	If $iBuffer = 1 Then Return ""
	Local $tBuffer
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
		$iBuffer *= 2
	Else
		$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
	EndIf
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			_SendMessage($hWnd, $LVM_GETISEARCHSTRINGW, 0, $tBuffer, 0, "wparam", "struct*")
		Else
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iBuffer, $tMemMap)
			If $fUnicode Then
				_SendMessage($hWnd, $LVM_GETISEARCHSTRINGW, 0, $pMemory)
			Else
				_SendMessage($hWnd, $LVM_GETISEARCHSTRINGA, 0, $pMemory)
			EndIf
			_MemRead($tMemMap, $pMemory, $tBuffer, $iBuffer)
			_MemFree($tMemMap)
		EndIf
	Else
		Local $pBuffer = DllStructGetPtr($tBuffer)
		If $fUnicode Then
			GUICtrlSendMsg($hWnd, $LVM_GETISEARCHSTRINGW, 0, $pBuffer)
		Else
			GUICtrlSendMsg($hWnd, $LVM_GETISEARCHSTRINGA, 0, $pBuffer)
		EndIf
	EndIf
	Return DllStructGetData($tBuffer, "Text")
EndFunc   ;==>_GUICtrlListView_GetISearchString

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItem
; Description ...: Retrieves an item's attributes
; Syntax.........: _GUICtrlListView_GetItem($hWnd, $iIndex[, $iSubItem = 0])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index
;                  $iSubItem    - One based subitem index
; Return values .: Success      - Array with the following format:
;                  |[0] - Item state, which can be a combination of the following:
;                  | 1 - The item is marked for a cut-and-paste operation
;                  | 2 - The item is highlighted as a drag-and-drop target
;                  | 4 - The item has the focus
;                  | 8 - The item is selected
;                  |[1] - One based item image overlay index
;                  |[2] - One based item state image index
;                  |[3] - Item text
;                  |[4] - Zero based item image index
;                  |[5] - Item application defined value
;                  |[6] - Number of image widths to indent the item
;                  |[7] - Identifier of the tile view group that receives the item
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_SetItem, _GUICtrlListView_GetItemEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItem($hWnd, $iIndex, $iSubItem = 0)
	Local $aItem[8]

	Local $tItem = DllStructCreate($tagLVITEM)
	DllStructSetData($tItem, "Mask", BitOR($LVIF_GROUPID, $LVIF_IMAGE, $LVIF_INDENT, $LVIF_PARAM, $LVIF_STATE))
	DllStructSetData($tItem, "Item", $iIndex)
	DllStructSetData($tItem, "SubItem", $iSubItem)
	DllStructSetData($tItem, "StateMask", -1)
	_GUICtrlListView_GetItemEx($hWnd, $tItem)
	Local $iState = DllStructGetData($tItem, "State")
	If BitAND($iState, $LVIS_CUT) <> 0 Then $aItem[0] = BitOR($aItem[0], 1)
	If BitAND($iState, $LVIS_DROPHILITED) <> 0 Then $aItem[0] = BitOR($aItem[0], 2)
	If BitAND($iState, $LVIS_FOCUSED) <> 0 Then $aItem[0] = BitOR($aItem[0], 4)
	If BitAND($iState, $LVIS_SELECTED) <> 0 Then $aItem[0] = BitOR($aItem[0], 8)
	$aItem[1] = __GUICtrlListView_OverlayImageMaskToIndex($iState)
	$aItem[2] = __GUICtrlListView_StateImageMaskToIndex($iState)
	$aItem[3] = _GUICtrlListView_GetItemText($hWnd, $iIndex, $iSubItem)
	$aItem[4] = DllStructGetData($tItem, "Image")
	$aItem[5] = DllStructGetData($tItem, "Param")
	$aItem[6] = DllStructGetData($tItem, "Indent")
	$aItem[7] = DllStructGetData($tItem, "GroupID")
	Return $aItem
EndFunc   ;==>_GUICtrlListView_GetItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemChecked
; Description ...: Returns the check state for a list-view control item
; Syntax.........: _GUICtrlListView_GetItemChecked($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index to retrieve item check state from
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......: Siao for external control
; Remarks .......:
; Related .......: _GUICtrlListView_SetItemChecked
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemChecked($hWnd, $iIndex)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)

	Local $tLVITEM = DllStructCreate($tagLVITEM)
	Local $iSize = DllStructGetSize($tLVITEM)
	If @error Then Return SetError($LV_ERR, $LV_ERR, False)
	DllStructSetData($tLVITEM, "Mask", $LVIF_STATE)
	DllStructSetData($tLVITEM, "Item", $iIndex)
	DllStructSetData($tLVITEM, "StateMask", 0xffff)

	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			$iRet = _SendMessage($hWnd, $LVM_GETITEMW, 0, $tLVITEM, 0, "wparam", "struct*") <> 0
		Else
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iSize, $tMemMap)
			_MemWrite($tMemMap, $tLVITEM)
			If $fUnicode Then
				$iRet = _SendMessage($hWnd, $LVM_GETITEMW, 0, $pMemory, 0, "wparam", "ptr") <> 0
			Else
				$iRet = _SendMessage($hWnd, $LVM_GETITEMA, 0, $pMemory, 0, "wparam", "ptr") <> 0
			EndIf
			_MemRead($tMemMap, $pMemory, $tLVITEM, $iSize)
			_MemFree($tMemMap)
		EndIf
	Else
		Local $pItem = DllStructGetPtr($tLVITEM)
		If $fUnicode Then
			$iRet = GUICtrlSendMsg($hWnd, $LVM_GETITEMW, 0, $pItem) <> 0
		Else
			$iRet = GUICtrlSendMsg($hWnd, $LVM_GETITEMA, 0, $pItem) <> 0
		EndIf
	EndIf

	If Not $iRet Then Return SetError($LV_ERR, $LV_ERR, False)
	Return BitAND(DllStructGetData($tLVITEM, "State"), 0x2000) <> 0
EndFunc   ;==>_GUICtrlListView_GetItemChecked

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemCount
; Description ...: Retrieves the number of items in a list-view control
; Syntax.........: _GUICtrlListView_GetItemCount($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The number of items
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_SetItemCount
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemCount($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETITEMCOUNT)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_GETITEMCOUNT, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetItemCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemCut
; Description ...: Determines whether the item is marked for a cut and paste operation
; Syntax.........: _GUICtrlListView_GetItemCut($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
; Return values .: True         - Item is marked for a cut and paste operation
;                  False        - Item is not marked for a cut and paste operation
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_SetItemCut
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemCut($hWnd, $iIndex)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Return _GUICtrlListView_GetItemState($hWnd, $iIndex, $LVIS_CUT) <> 0
EndFunc   ;==>_GUICtrlListView_GetItemCut

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemDropHilited
; Description ...: Determines whether the item is highlighted as a drag-and-drop target
; Syntax.........: _GUICtrlListView_GetItemDropHilited($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_SetItemDropHilited
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemDropHilited($hWnd, $iIndex)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Return _GUICtrlListView_GetItemState($hWnd, $iIndex, $LVIS_DROPHILITED) <> 0
EndFunc   ;==>_GUICtrlListView_GetItemDropHilited

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemEx
; Description ...: Retrieves some or all of an item's attributes
; Syntax.........: _GUICtrlListView_GetItemEx($hWnd, ByRef $tItem)
; Parameters ....: $hWnd        - Handle to the control
;                  $tItem       - $tagLVITEM structure that specifies the information to retrieve
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_GetItem, $tagLVITEM
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemEx($hWnd, ByRef $tItem)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)

	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			$iRet = _SendMessage($hWnd, $LVM_GETITEMW, 0, $tItem, 0, "wparam", "struct*")
		Else
			Local $iItem = DllStructGetSize($tItem)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iItem, $tMemMap)
			_MemWrite($tMemMap, $tItem)
			If $fUnicode Then
				_SendMessage($hWnd, $LVM_GETITEMW, 0, $pMemory, 0, "wparam", "ptr")
			Else
				_SendMessage($hWnd, $LVM_GETITEMA, 0, $pMemory, 0, "wparam", "ptr")
			EndIf
			_MemRead($tMemMap, $pMemory, $tItem, $iItem)
			_MemFree($tMemMap)
		EndIf
	Else
		Local $pItem = DllStructGetPtr($tItem)
		If $fUnicode Then
			$iRet = GUICtrlSendMsg($hWnd, $LVM_GETITEMW, 0, $pItem)
		Else
			$iRet = GUICtrlSendMsg($hWnd, $LVM_GETITEMA, 0, $pItem)
		EndIf
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlListView_GetItemEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemFocused
; Description ...: Determines whether the item is highlighted as a drag-and-drop target
; Syntax.........: _GUICtrlListView_GetItemFocused($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_SetItemFocused
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemFocused($hWnd, $iIndex)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Return _GUICtrlListView_GetItemState($hWnd, $iIndex, $LVIS_FOCUSED) <> 0
EndFunc   ;==>_GUICtrlListView_GetItemFocused

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemGroupID
; Description ...: Gets the item group ID
; Syntax.........: _GUICtrlListView_GetItemGroupID($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
; Return values .: Success      - Item group ID
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Minimum operating systems Windows XP.
; Related .......: _GUICtrlListView_SetItemGroupID
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemGroupID($hWnd, $iIndex)
	Local $tItem = DllStructCreate($tagLVITEM)
	DllStructSetData($tItem, "Mask", $LVIF_GROUPID)
	DllStructSetData($tItem, "Item", $iIndex)
	_GUICtrlListView_GetItemEx($hWnd, $tItem)
	Return DllStructGetData($tItem, "GroupID")
EndFunc   ;==>_GUICtrlListView_GetItemGroupID

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemImage
; Description ...: Retrieves the index of the item's icon
; Syntax.........: _GUICtrlListView_GetItemImage($hWnd, $iIndex[, $iSubItem = 0])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index
;                  $iSubItem    - One based item sub item index
; Return values .: Success      - Zero based item image index
;                  Failue       - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_SetItemImage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemImage($hWnd, $iIndex, $iSubItem = 0)
	Local $tItem = DllStructCreate($tagLVITEM)
	DllStructSetData($tItem, "Mask", $LVIF_IMAGE)
	DllStructSetData($tItem, "Item", $iIndex)
	DllStructSetData($tItem, "SubItem", $iSubItem)
	_GUICtrlListView_GetItemEx($hWnd, $tItem)
	Return DllStructGetData($tItem, "Image")
EndFunc   ;==>_GUICtrlListView_GetItemImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemIndent
; Description ...: Retrieves the number of image widths the item is indented
; Syntax.........: _GUICtrlListView_GetItemIndent($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Item indention
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_SetItemIndent
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemIndent($hWnd, $iIndex)
	Local $tItem = DllStructCreate($tagLVITEM)
	DllStructSetData($tItem, "Mask", $LVIF_INDENT)
	DllStructSetData($tItem, "Item", $iIndex)
	_GUICtrlListView_GetItemEx($hWnd, $tItem)
	Return DllStructGetData($tItem, "Indent")
EndFunc   ;==>_GUICtrlListView_GetItemIndent

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlListView_GetItemOverlayImage
; Description ...: Gets the overlay image that is superimposed over the item's icon image
; Syntax.........: __GUICtrlListView_GetItemOverlayImage($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
; Return values .: Success      - Zero based image index
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function is used internally and should not normally be called
; Related .......: __GUICtrlListView_SetItemOverlayImage
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GUICtrlListView_GetItemOverlayImage($hWnd, $iIndex)
	Return BitShift(_GUICtrlListView_GetItemState($hWnd, $iIndex, $LVIS_OVERLAYMASK), 8)
EndFunc   ;==>__GUICtrlListView_GetItemOverlayImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemParam
; Description ...: Retrieves the application specific value of the item
; Syntax.........: _GUICtrlListView_GetItemParam($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based item index
; Return values .: Success      - Application specific value
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_SetItemParam
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemParam($hWnd, $iIndex)
	Local $tItem = DllStructCreate($tagLVITEM)
	DllStructSetData($tItem, "Mask", $LVIF_PARAM)
	DllStructSetData($tItem, "Item", $iIndex)
	_GUICtrlListView_GetItemEx($hWnd, $tItem)
	Return DllStructGetData($tItem, "Param")
EndFunc   ;==>_GUICtrlListView_GetItemParam

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemPosition
; Description ...: Retrieves the position of an item
; Syntax.........: _GUICtrlListView_GetItemPosition($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
; Return values .: Success      - Array with the following format:
;                  |[0] - X position of item
;                  |[1] - Y position of item
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_SetItemPosition, _GUICtrlListView_GetItemPositionX, _GUICtrlListView_GetItemPositionY
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemPosition($hWnd, $iIndex)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $aPoint[2], $iRet

	Local $tPoint = DllStructCreate($tagPOINT)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			If Not _SendMessage($hWnd, $LVM_GETITEMPOSITION, $iIndex, $tPoint, 0, "wparam", "struct*") Then Return $aPoint
		Else
			Local $iPoint = DllStructGetSize($tPoint)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iPoint, $tMemMap)
			If Not _SendMessage($hWnd, $LVM_GETITEMPOSITION, $iIndex, $pMemory, 0, "wparam", "ptr") Then Return $aPoint
			_MemRead($tMemMap, $pMemory, $tPoint, $iPoint)
			_MemFree($tMemMap)
		EndIf
	Else
		$iRet = GUICtrlSendMsg($hWnd, $LVM_GETITEMPOSITION, $iIndex, DllStructGetPtr($tPoint))
		If Not $iRet Then Return $aPoint
	EndIf
	$aPoint[0] = DllStructGetData($tPoint, "X")
	$aPoint[1] = DllStructGetData($tPoint, "Y")
	Return $aPoint
EndFunc   ;==>_GUICtrlListView_GetItemPosition

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemPositionX
; Description ...: Retrieves the X position of an item
; Syntax.........: _GUICtrlListView_GetItemPositionX($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
; Return values .: Success      - X position of item
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_GetItemPosition
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemPositionX($hWnd, $iIndex)
	Local $aPoint = _GUICtrlListView_GetItemPosition($hWnd, $iIndex)
	Return $aPoint[0]
EndFunc   ;==>_GUICtrlListView_GetItemPositionX

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemPositionY
; Description ...: Retrieves the Y position of an item
; Syntax.........: _GUICtrlListView_GetItemPositionY($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
; Return values .: Success      - Y position of item
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_GetItemPosition
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemPositionY($hWnd, $iIndex)
	Local $aPoint = _GUICtrlListView_GetItemPosition($hWnd, $iIndex)
	Return $aPoint[1]
EndFunc   ;==>_GUICtrlListView_GetItemPositionY

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemRect
; Description ...: Retrieves the bounding rectangle for all or part of an item
; Syntax.........: _GUICtrlListView_GetItemRect($hWnd, $iIndex[, $iPart = 3])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $iPart       - The portion of the item to retrieve:
;                  |0 - The bounding rectangle of the entire item
;                  |1 - The bounding rectangle of the icon or small icon
;                  |2 - The bounding rectangle of the item text
;                  |3 - The union of 1 and 2, but excludes columns in report view
; Return values .: Success      - Array with the following format:
;                  |[0] - X coordinate of the upper left corner of the rectangle
;                  |[1] - Y coordinate of the upper left corner of the rectangle
;                  |[2] - X coordinate of the lower right corner of the rectangle
;                  |[3] - Y coordinate of the lower right corner of the rectangle
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_GetItemRectEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemRect($hWnd, $iIndex, $iPart = 3)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $tRect = _GUICtrlListView_GetItemRectEx($hWnd, $iIndex, $iPart)
	Local $aRect[4]
	$aRect[0] = DllStructGetData($tRect, "Left")
	$aRect[1] = DllStructGetData($tRect, "Top")
	$aRect[2] = DllStructGetData($tRect, "Right")
	$aRect[3] = DllStructGetData($tRect, "Bottom")
	Return $aRect
EndFunc   ;==>_GUICtrlListView_GetItemRect

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemRectEx
; Description ...: Retrieves the bounding rectangle for all or part of an item
; Syntax.........: _GUICtrlListView_GetItemRectEx($hWnd, $iIndex[, $iPart = 3])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $iPart       - The portion of the item to retrieve:
;                  |$LVIR_BOUNDS       - Returns the bounding rectangle of the entire item, including the icon and label
;                  |$LVIR_ICON         - Returns the bounding rectangle of the icon or small icon
;                  |$LVIR_LABEL        - Returns the bounding rectangle of the item text
;                  |$LVIR_SELECTBOUNDS - Returns the union of the $LVIR_ICON and $LVIR_LABEL rectangles, but excludes columns  in
;                  +report view.
; Return values .: Success      - $tagRECT structure
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_GetItemRect, $tagRECT
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemRectEx($hWnd, $iIndex, $iPart = 3)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $tRect = DllStructCreate($tagRECT)
	DllStructSetData($tRect, "Left", $iPart)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			_SendMessage($hWnd, $LVM_GETITEMRECT, $iIndex, $tRect, 0, "wparam", "struct*")
		Else
			Local $iRect = DllStructGetSize($tRect)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iRect, $tMemMap)
			_MemWrite($tMemMap, $tRect, $pMemory, $iRect)
			_SendMessage($hWnd, $LVM_GETITEMRECT, $iIndex, $pMemory, 0, "wparam", "ptr")
			_MemRead($tMemMap, $pMemory, $tRect, $iRect)
			_MemFree($tMemMap)
		EndIf
	Else
		GUICtrlSendMsg($hWnd, $LVM_GETITEMRECT, $iIndex, DllStructGetPtr($tRect))
	EndIf
	Return $tRect
EndFunc   ;==>_GUICtrlListView_GetItemRectEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemSelected
; Description ...: Determines whether the item is selected
; Syntax.........: _GUICtrlListView_GetItemSelected($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_SetItemSelected
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemSelected($hWnd, $iIndex)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Return _GUICtrlListView_GetItemState($hWnd, $iIndex, $LVIS_SELECTED) <> 0
EndFunc   ;==>_GUICtrlListView_GetItemSelected

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemSpacing
; Description ...: Determines the spacing between items in the control
; Syntax.........: _GUICtrlListView_GetItemSpacing($hWnd[, $fSmall = False])
; Parameters ....: $hWnd        - Handle to the control
;                  $fSmall      - View for which to retrieve the item spacing:
;                  | True - Small icon view
;                  |False - Icon view
; Return values .: Success      - Array with the following format:
;                  |[0] - Horizontal spacing
;                  |[1] - Vertical spacing
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_GetItemSpacingX, _GUICtrlListView_GetItemSpacingY
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemSpacing($hWnd, $fSmall = False)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $iSpace
	If IsHWnd($hWnd) Then
		$iSpace = _SendMessage($hWnd, $LVM_GETITEMSPACING, $fSmall)
	Else
		$iSpace = GUICtrlSendMsg($hWnd, $LVM_GETITEMSPACING, $fSmall, 0)
	EndIf
	Local $aSpace[2]
	$aSpace[0] = BitAND($iSpace, 0xFFFF)
	$aSpace[1] = BitShift($iSpace, 16)
	Return $aSpace
EndFunc   ;==>_GUICtrlListView_GetItemSpacing

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemSpacingX
; Description ...: Determines the horizontal spacing between items in the control
; Syntax.........: _GUICtrlListView_GetItemSpacingX($hWnd[, $fSmall = False])
; Parameters ....: $hWnd        - Handle to the control
;                  $fSmall      - View for which to retrieve the item spacing:
;                  | True - Small icon view
;                  |False - Icon view
; Return values .: Success      - Horizontal spacing
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_GetItemSpacing
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemSpacingX($hWnd, $fSmall = False)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return BitAND(_SendMessage($hWnd, $LVM_GETITEMSPACING, $fSmall, 0), 0xFFFF)
	Else
		Return BitAND(GUICtrlSendMsg($hWnd, $LVM_GETITEMSPACING, $fSmall, 0), 0xFFFF)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetItemSpacingX

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemSpacingY
; Description ...: Determines the vertical spacing between items in the control
; Syntax.........: _GUICtrlListView_GetItemSpacingY($hWnd[, $fSmall = False])
; Parameters ....: $hWnd  - Handle to the control
;                  $fSmall      - View for which to retrieve the item spacing:
;                  | True - Small icon view
;                  |False - Icon view
; Return values .: Success      - Vertical spacing
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_GetItemSpacing
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemSpacingY($hWnd, $fSmall = False)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return BitShift(_SendMessage($hWnd, $LVM_GETITEMSPACING, $fSmall, 0), 16)
	Else
		Return BitShift(GUICtrlSendMsg($hWnd, $LVM_GETITEMSPACING, $fSmall, 0), 16)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetItemSpacingY

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemState
; Description ...: Retrieves the state of a listview item
; Syntax.........: _GUICtrlListView_GetItemState($hWnd, $iIndex, $iMask)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $iMask       - State information to retrieve. This can be a combination of:
;                  |$LVIS_CUT            - The item is marked for a cut-and-paste operation
;                  |$LVIS_DROPHILITED    - The item is highlighted as a drag-and-drop target
;                  |$LVIS_FOCUSED        - The item has the focus, so it is surrounded by a standard focus rectangle
;                  |$LVIS_SELECTED       - The item is selected
;                  |$LVIS_OVERLAYMASK    - Use this mask to retrieve the item's overlay image index
;                  |$LVIS_STATEIMAGEMASK - Use this mask to retrieve the item's state image index
; Return values .: Success      - The current state for the specified item
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: An items state information includes a set of bit flags as well as image list indexes that indicate the item's
;                  state image and overlay image
; Related .......: _GUICtrlListView_SetItemState
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemState($hWnd, $iIndex, $iMask)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETITEMSTATE, $iIndex, $iMask)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_GETITEMSTATE, $iIndex, $iMask)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetItemState

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemStateImage
; Description ...: Gets the state image that is displayed
; Syntax.........: _GUICtrlListView_GetItemStateImage($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
; Return values .: Success      - One based overlay image index
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_SetItemStateImage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemStateImage($hWnd, $iIndex)
	Return BitShift(_GUICtrlListView_GetItemState($hWnd, $iIndex, $LVIS_STATEIMAGEMASK), 12)
EndFunc   ;==>_GUICtrlListView_GetItemStateImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemText
; Description ...: Retrieves the text of an item or subitem
; Syntax.........: _GUICtrlListView_GetItemText($hWnd, $iIndex[, $iSubItem = 0])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $iSubItem    - One based sub item index
; Return values .: Success      - Item or subitem text
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: To retrieve the item text, set iSubItem to zero. To retrieve the text of a subitem, set iSubItem to the one
;                  based subitem's index.
; Related .......: _GUICtrlListView_SetItemText, _GUICtrlListView_GetItemTextArray, _GUICtrlListView_GetItemTextString
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemText($hWnd, $iIndex, $iSubItem = 0)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)

	Local $tBuffer
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Text[4096]")
	Else
		$tBuffer = DllStructCreate("char Text[4096]")
	EndIf
	Local $pBuffer = DllStructGetPtr($tBuffer)
	Local $tItem = DllStructCreate($tagLVITEM)
	DllStructSetData($tItem, "SubItem", $iSubItem)
	DllStructSetData($tItem, "TextMax", 4096)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			DllStructSetData($tItem, "Text", $pBuffer)
			_SendMessage($hWnd, $LVM_GETITEMTEXTW, $iIndex, $tItem, 0, "wparam", "struct*")
		Else
			Local $iItem = DllStructGetSize($tItem)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iItem + 4096, $tMemMap)
			Local $pText = $pMemory + $iItem
			DllStructSetData($tItem, "Text", $pText)
			_MemWrite($tMemMap, $tItem, $pMemory, $iItem)
			If $fUnicode Then
				_SendMessage($hWnd, $LVM_GETITEMTEXTW, $iIndex, $pMemory, 0, "wparam", "ptr")
			Else
				_SendMessage($hWnd, $LVM_GETITEMTEXTA, $iIndex, $pMemory, 0, "wparam", "ptr")
			EndIf
			_MemRead($tMemMap, $pText, $tBuffer, 4096)
			_MemFree($tMemMap)
		EndIf
	Else
		Local $pItem = DllStructGetPtr($tItem)
		DllStructSetData($tItem, "Text", $pBuffer)
		If $fUnicode Then
			GUICtrlSendMsg($hWnd, $LVM_GETITEMTEXTW, $iIndex, $pItem)
		Else
			GUICtrlSendMsg($hWnd, $LVM_GETITEMTEXTA, $iIndex, $pItem)
		EndIf
	EndIf
	Return DllStructGetData($tBuffer, "Text")
EndFunc   ;==>_GUICtrlListView_GetItemText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemTextArray
; Description ...: Retrieves all of a list-view item
; Syntax.........: _GUICtrlListView_GetItemTextArray($hWnd[, $iItem = -1])
; Parameters ....: $hWnd        - Handle to the control
;                  $iItem       - Zero based index of item to retrieve
; Return values .: Success      - Array with the following format:
;                  |[0] - Number of Columns in array (n)
;                  |[1] - First column index
;                  |[2] - Second column index
;                  |[n] - Last column index
;                  Failure      - Array with the following format:
;                  |[0] - Number of Columns in array (0)
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If $iItem = -1 then will attempt to get the Currently Selected item.
; Related .......: _GUICtrlListView_SetItemText, _GUICtrlListView_GetItemText, _GUICtrlListView_GetItemTextString
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemTextArray($hWnd, $iItem = -1)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $sItems = _GUICtrlListView_GetItemTextString($hWnd, $iItem)
	If $sItems = "" Then
		Local $vItems[1] = [0]
		Return SetError($LV_ERR, $LV_ERR, $vItems)
	EndIf
	Return StringSplit($sItems, Opt('GUIDataSeparatorChar'))
EndFunc   ;==>_GUICtrlListView_GetItemTextArray

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetItemTextString
; Description ...: Retrieves all of a list-view item
; Syntax.........: _GUICtrlListView_GetItemTextString($hWnd[, $iItem = -1])
; Parameters ....: $hWnd        - Handle to the control
;                  $iItem       - Zero based index of item to retrieve
; Return values .: Success      - delimited string
;                  Failure      - Empty string
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If $iItem = -1 then will attempt to get the Currently Selected item.
; Related .......: _GUICtrlListView_SetItemText, _GUICtrlListView_GetItemText, _GUICtrlListView_GetItemTextArray
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetItemTextString($hWnd, $iItem = -1)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $sRow = "", $SeparatorChar = Opt('GUIDataSeparatorChar'), $iSelected
	If $iItem = -1 Then
		$iSelected = _GUICtrlListView_GetNextItem($hWnd) ; get current row selected
	Else
		$iSelected = $iItem ; get row
	EndIf
	For $x = 0 To _GUICtrlListView_GetColumnCount($hWnd) - 1
		$sRow &= _GUICtrlListView_GetItemText($hWnd, $iSelected, $x) & $SeparatorChar
	Next
	Return StringTrimRight($sRow, 1)
EndFunc   ;==>_GUICtrlListView_GetItemTextString

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetNextItem
; Description ...: Searches for an item that has the specified properties
; Syntax.........:  _GUICtrlListView_GetNextItem($hWnd[, $iStart = -1[, $iSearch = 0[, $iState = 8]]])
; Parameters ....: $hWnd  - Handle to the control
;                  $iStart      - Index of the item to begin the search with, or -1 to find  the  first  item  that  matches  the
;                  +specified flags.  The specified item itself is excluded from the search.
;                  $iSearch     - Relationship to the index of the item where the search is to begin:
;                  |0 - Searches for a subsequent item by index
;                  |1 - Searches for an item that is above the specified item
;                  |2 - Searches for an item that is below the specified item
;                  |3 - Searches for an item to the left of the specified item
;                  |4 - Searches for an item to the right of the specified item
;                  $iState      - State of the item to find. Can be a combination of:
;                  |1 - The item is cut
;                  |2 - The item is highlighted
;                  |4 - The item is focused
;                  |8 - The item is selected
; Return values .: Success      - The zero based index of the next item
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetNextItem($hWnd, $iStart = -1, $iSearch = 0, $iState = 8)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $aSearch[5] = [$LVNI_ALL, $LVNI_ABOVE, $LVNI_BELOW, $LVNI_TOLEFT, $LVNI_TORIGHT]

	Local $iFlags = $aSearch[$iSearch]
	If BitAND($iState, 1) <> 0 Then $iFlags = BitOR($iFlags, $LVNI_CUT)
	If BitAND($iState, 2) <> 0 Then $iFlags = BitOR($iFlags, $LVNI_DROPHILITED)
	If BitAND($iState, 4) <> 0 Then $iFlags = BitOR($iFlags, $LVNI_FOCUSED)
	If BitAND($iState, 8) <> 0 Then $iFlags = BitOR($iFlags, $LVNI_SELECTED)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETNEXTITEM, $iStart, $iFlags)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_GETNEXTITEM, $iStart, $iFlags)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetNextItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetNumberOfWorkAreas
; Description ...: Retrieves the number of working areas in the control
; Syntax.........: _GUICtrlListView_GetNumberOfWorkAreas($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Number of working areas
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_SetWorkAreas
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetNumberOfWorkAreas($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $tBuffer = DllStructCreate("int Data")
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			_SendMessage($hWnd, $LVM_GETNUMBEROFWORKAREAS, 0, $tBuffer, 0, "wparam", "struct*")
		Else
			Local $iBuffer = DllStructGetSize($tBuffer)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iBuffer, $tMemMap)
			_SendMessage($hWnd, $LVM_GETNUMBEROFWORKAREAS, 0, $pMemory, 0, "wparam", "ptr")
			_MemRead($tMemMap, $pMemory, $tBuffer, $iBuffer)
			_MemFree($tMemMap)
		EndIf
	Else
		GUICtrlSendMsg($hWnd, $LVM_GETNUMBEROFWORKAREAS, 0, DllStructGetPtr($tBuffer))
	EndIf

	Return DllStructGetData($tBuffer, "Data")
EndFunc   ;==>_GUICtrlListView_GetNumberOfWorkAreas

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetOrigin
; Description ...: Retrieves the current view origin for the control
; Syntax.........: _GUICtrlListView_GetOrigin($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Array with the following format:
;                  |[0] - View X position
;                  |[1] - View Y position
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_GetOriginX, _GUICtrlListView_GetOriginY
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetOrigin($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)


	Local $tPoint = DllStructCreate($tagPOINT)
	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			$iRet = _SendMessage($hWnd, $LVM_GETORIGIN, 0, $tPoint, 0, "wparam", "struct*")
		Else
			Local $iPoint = DllStructGetSize($tPoint)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iPoint, $tMemMap)
			$iRet = _SendMessage($hWnd, $LVM_GETORIGIN, 0, $pMemory, 0, "wparam", "ptr")
			_MemRead($tMemMap, $pMemory, $tPoint, $iPoint)
			_MemFree($tMemMap)
		EndIf
	Else
		$iRet = GUICtrlSendMsg($hWnd, $LVM_GETORIGIN, 0, DllStructGetPtr($tPoint))
	EndIf
	Local $aOrigin[2]
	$aOrigin[0] = DllStructGetData($tPoint, "X")
	$aOrigin[1] = DllStructGetData($tPoint, "Y")
	Return SetError(@error, $iRet = 1, $aOrigin)
EndFunc   ;==>_GUICtrlListView_GetOrigin

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetOriginX
; Description ...: Retrieves the current horizontal view origin for the control
; Syntax.........: _GUICtrlListView_GetOriginX($hWnd)
; Parameters ....: $hWnd  - Handle to the control
; Return values .: Success      - View X position
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_GetOrigin
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetOriginX($hWnd)
	Local $aOrigin = _GUICtrlListView_GetOrigin($hWnd)
	Return $aOrigin[0]
EndFunc   ;==>_GUICtrlListView_GetOriginX

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetOriginY
; Description ...: Retrieves the current horizontal view origin for the control
; Syntax.........: _GUICtrlListView_GetOriginY($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - View Y position
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_GetOrigin
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetOriginY($hWnd)
	Local $aOrigin = _GUICtrlListView_GetOrigin($hWnd)
	Return $aOrigin[1]
EndFunc   ;==>_GUICtrlListView_GetOriginY

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetOutlineColor
; Description ...: Retrieves the color of the border of the control
; Syntax.........: _GUICtrlListView_GetOutlineColor($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Border color of the control
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Minimum operating systems Windows XP. Control must have the $LVS_EX_BORDERSELECT extended window style set
; Related .......: _GUICtrlListView_SetOutlineColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetOutlineColor($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETOUTLINECOLOR)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_GETOUTLINECOLOR, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetOutlineColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetSelectedColumn
; Description ...: Retrieves the index of the selected column
; Syntax.........: _GUICtrlListView_GetSelectedColumn($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The zero based index of the selected column
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Minimum operating systems Windows XP.
; Related .......: _GUICtrlListView_SetSelectedColumn
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetSelectedColumn($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETSELECTEDCOLUMN)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_GETSELECTEDCOLUMN, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetSelectedColumn

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetSelectedCount
; Description ...: Determines the number of selected items
; Syntax.........: _GUICtrlListView_GetSelectedCount($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The number of selected items
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetSelectedCount($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETSELECTEDCOUNT)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_GETSELECTEDCOUNT, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetSelectedCount

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlListView_GetCheckedIndices
; Description ...: Retrieve indices of checked item(s)
; Syntax.........: __GUICtrlListView_GetCheckedIndices($hWnd, $fArray = False)
; Parameters ....: $hWnd        - Handle to the control
;                  $fArray      - Return string or Array
;                  |True - Returns array
;                  |False - Returns pipe "|" delimited string
; Return values .: Success      - Checked indices Based on $fArray:
;                  +Array       - With the following format
;                  |[0] - Number of Items in array (n)
;                  |[1] - First item index
;                  |[2] - Second item index
;                  |[n] - Last item index
;                  |String      - With the following format
;                  |"0|1|2|n"
;                  Failure      - Based on $fArray
;                  |Array       - With the following format
;                  |[0] - Number of Items in array (0)
;                  |String      - Empty ("")
; Author ........: jpm
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func __GUICtrlListView_GetCheckedIndices($hWnd, $fArray = False)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $sIndices, $aIndices[1] = [0]
	Local $iRet, $iCount = _GUICtrlListView_GetItemCount($hWnd)
	For $iItem = 0 To $iCount - 1
		$iRet = _GUICtrlListView_GetItemChecked($hWnd, $iItem)
		If $iRet Then
			If (Not $fArray) Then
				If StringLen($sIndices) Then
					$sIndices &= "|" & $iItem
				Else
					$sIndices = $iItem
				EndIf
			Else
				ReDim $aIndices[UBound($aIndices) + 1]
				$aIndices[0] = UBound($aIndices) - 1
				$aIndices[UBound($aIndices) - 1] = $iItem
			EndIf
		EndIf
	Next
	If (Not $fArray) Then
		Return String($sIndices)
	Else
		Return $aIndices
	EndIf
EndFunc   ;==>__GUICtrlListView_GetCheckedIndices

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetSelectedIndices
; Description ...: Retrieve indices of selected item(s)
; Syntax.........: _GUICtrlListView_GetSelectedIndices($hWnd, $fArray = False)
; Parameters ....: $hWnd        - Handle to the control
;                  $fArray      - Return string or Array
;                  |True - Returns array
;                  |False - Returns pipe "|" delimited string
; Return values .: Success      - Selected indices Based on $fArray:
;                  +Array       - With the following format
;                  |[0] - Number of Items in array (n)
;                  |[1] - First item index
;                  |[2] - Second item index
;                  |[n] - Last item index
;                  |String      - With the following format
;                  |"0|1|2|n"
;                  Failure      - Based on $fArray
;                  |Array       - With the following format
;                  |[0] - Number of Items in array (0)
;                  |String      - Empty ("")
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetSelectedIndices($hWnd, $fArray = False)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $sIndices, $aIndices[1] = [0]
	Local $iRet, $iCount = _GUICtrlListView_GetItemCount($hWnd)
	For $iItem = 0 To $iCount
		If IsHWnd($hWnd) Then
			$iRet = _SendMessage($hWnd, $LVM_GETITEMSTATE, $iItem, $LVIS_SELECTED)
		Else
			$iRet = GUICtrlSendMsg($hWnd, $LVM_GETITEMSTATE, $iItem, $LVIS_SELECTED)
		EndIf
		If $iRet Then
			If (Not $fArray) Then
				If StringLen($sIndices) Then
					$sIndices &= "|" & $iItem
				Else
					$sIndices = $iItem
				EndIf
			Else
				ReDim $aIndices[UBound($aIndices) + 1]
				$aIndices[0] = UBound($aIndices) - 1
				$aIndices[UBound($aIndices) - 1] = $iItem
			EndIf
		EndIf
	Next
	If (Not $fArray) Then
		Return String($sIndices)
	Else
		Return $aIndices
	EndIf
EndFunc   ;==>_GUICtrlListView_GetSelectedIndices

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetSelectionMark
; Description ...: Retrieves the selection mark from the control
; Syntax.........: _GUICtrlListView_GetSelectionMark($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The zero based selection mark
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: The selection mark is the item index from which a multiple selection starts
; Related .......: _GUICtrlListView_SetSelectionMark
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetSelectionMark($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETSELECTIONMARK)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_GETSELECTIONMARK, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetSelectionMark

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetStringWidth
; Description ...: Determines the width of a specified string
; Syntax.........: _GUICtrlListView_GetStringWidth($hWnd, $sString)
; Parameters ....: $hWnd        - Handle to the control
;                  $sString     - String for which the width will be calculated
; Return values .: Success      - The string width
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: This function returns the exact width, in pixels, of the specified string.  If you use the returned string
;                  width as the column width in the SetColumnWidth function the string will be truncated.  To retrieve the column
;                  width that can contain the string without truncating it, you must add padding to the returned string width.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetStringWidth($hWnd, $sString)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)

	Local $iBuffer = StringLen($sString) + 1
	Local $tBuffer
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
		$iBuffer *= 2
	Else
		$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
	EndIf
	DllStructSetData($tBuffer, "Text", $sString)
	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			$iRet = _SendMessage($hWnd, $LVM_GETSTRINGWIDTHW, 0, $tBuffer, 0, "wparam", "struct*")
		Else
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iBuffer, $tMemMap)
			_MemWrite($tMemMap, $tBuffer, $pMemory, $iBuffer)
			If $fUnicode Then
				$iRet = _SendMessage($hWnd, $LVM_GETSTRINGWIDTHW, 0, $pMemory, 0, "wparam", "ptr")
			Else
				$iRet = _SendMessage($hWnd, $LVM_GETSTRINGWIDTHA, 0, $pMemory, 0, "wparam", "ptr")
			EndIf
			_MemRead($tMemMap, $pMemory, $tBuffer, $iBuffer)
			_MemFree($tMemMap)
		EndIf
	Else
		Local $pBuffer = DllStructGetPtr($tBuffer)
		If $fUnicode Then
			$iRet = GUICtrlSendMsg($hWnd, $LVM_GETSTRINGWIDTHW, 0, $pBuffer)
		Else
			$iRet = GUICtrlSendMsg($hWnd, $LVM_GETSTRINGWIDTHA, 0, $pBuffer)
		EndIf
	EndIf
	Return $iRet
EndFunc   ;==>_GUICtrlListView_GetStringWidth

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetSubItemRect
; Description ...: Retrieves information about an item bounding rectangle
; Syntax.........: _GUICtrlListView_GetSubItemRect($hWnd, $iIndex, $iSubItem[, $iPart = 0])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the subitem's parent item
;                  $iSubItem    - One based index of the subitem
;                  $iPart       - The portion of the subitem item to retrieve:
;                  |0 - The rectangle of the entire subitem, including the icon and label
;                  |1 - The rectangle of the icon or small icon
; Return values .: Success      - Array with the following format:
;                  |[0] - X coordinate of the upper left corner of the rectangle
;                  |[1] - Y coordinate of the upper left corner of the rectangle
;                  |[2] - X coordinate of the lower right corner of the rectangle
;                  |[3] - Y coordinate of the lower right corner of the rectangle
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: This function is used only with controls that use the $LVS_REPORT style
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetSubItemRect($hWnd, $iIndex, $iSubItem, $iPart = 0)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $aPart[2] = [$LVIR_BOUNDS, $LVIR_ICON]

	Local $tRect = DllStructCreate($tagRECT)
	DllStructSetData($tRect, "Top", $iSubItem)
	DllStructSetData($tRect, "Left", $aPart[$iPart])
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			_SendMessage($hWnd, $LVM_GETSUBITEMRECT, $iIndex, $tRect, 0, "wparam", "struct*")
		Else
			Local $iRect = DllStructGetSize($tRect)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iRect, $tMemMap)
			_MemWrite($tMemMap, $tRect, $pMemory, $iRect)
			_SendMessage($hWnd, $LVM_GETSUBITEMRECT, $iIndex, $pMemory, 0, "wparam", "ptr")
			_MemRead($tMemMap, $pMemory, $tRect, $iRect)
			_MemFree($tMemMap)
		EndIf
	Else
		GUICtrlSendMsg($hWnd, $LVM_GETSUBITEMRECT, $iIndex, DllStructGetPtr($tRect))
	EndIf
	Local $aRect[4]
	$aRect[0] = DllStructGetData($tRect, "Left")
	$aRect[1] = DllStructGetData($tRect, "Top")
	$aRect[2] = DllStructGetData($tRect, "Right")
	$aRect[3] = DllStructGetData($tRect, "Bottom")
	Return $aRect
EndFunc   ;==>_GUICtrlListView_GetSubItemRect

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetTextBkColor
; Description ...: Retrieves the text background color of the control
; Syntax.........: _GUICtrlListView_GetTextBkColor($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Text background color
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_SetTextBkColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetTextBkColor($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETTEXTBKCOLOR)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_GETTEXTBKCOLOR, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetTextBkColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetTextColor
; Description ...: Retrieves the text color of the control
; Syntax.........: _GUICtrlListView_GetTextColor($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Text color
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_SetTextColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetTextColor($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETTEXTCOLOR)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_GETTEXTCOLOR, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetTextColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetToolTips
; Description ...: Retrieves the ToolTip control handle
; Syntax.........: _GUICtrlListView_GetToolTips($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The handle of the ToolTip control
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_SetToolTips
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetToolTips($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return HWnd(_SendMessage($hWnd, $LVM_GETTOOLTIPS))
	Else
		Return HWnd(GUICtrlSendMsg($hWnd, $LVM_GETTOOLTIPS, 0, 0))
	EndIf
EndFunc   ;==>_GUICtrlListView_GetToolTips

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetTopIndex
; Description ...: Retrieves the index of the topmost visible item when in list or report view
; Syntax.........: _GUICtrlListView_GetTopIndex($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Zero based index of the item
;                  +Zero if the list-view control is in icon or small icon view
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetTopIndex($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETTOPINDEX)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_GETTOPINDEX, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_GetTopIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetUnicodeFormat
; Description ...: Retrieves the UNICODE character format flag
; Syntax.........: _GUICtrlListView_GetUnicodeFormat($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: True         - Using Unicode characters
;                  False        - Using ANSI characters
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_SetUnicodeFormat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetUnicodeFormat($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_GETUNICODEFORMAT) <> 0
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_GETUNICODEFORMAT, 0, 0) <> 0
	EndIf
EndFunc   ;==>_GUICtrlListView_GetUnicodeFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetView
; Description ...: Retrieves the current view of the control
; Syntax.........: _GUICtrlListView_GetView($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The current view:
;                  |0 - Details
;                  |1 - Large Icon
;                  |2 - List
;                  |3 - Small Icon
;                  |4 - Tile
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Minimum operating systems Windows XP.
; Related .......: _GUICtrlListView_SetView, _GUICtrlListView_GetViewDetails, _GUICtrlListView_GetViewLarge, _GUICtrlListView_GetViewList, _GUICtrlListView_GetViewSmall, _GUICtrlListView_GetViewTile
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetView($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $view
	If IsHWnd($hWnd) Then
		$view = _SendMessage($hWnd, $LVM_GETVIEW)
	Else
		$view = GUICtrlSendMsg($hWnd, $LVM_GETVIEW, 0, 0)
	EndIf
	Switch $view
		Case $LV_VIEW_DETAILS
			Return 0
		Case $LV_VIEW_ICON
			Return 1
		Case $LV_VIEW_LIST
			Return 2
		Case $LV_VIEW_SMALLICON
			Return 3
		Case $LV_VIEW_TILE
			Return 4
		Case Else
			Return -1
	EndSwitch
EndFunc   ;==>_GUICtrlListView_GetView

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetViewDetails
; Description ...: Determines whether the view mode is in detail mode
; Syntax.........: _GUICtrlListView_GetViewDetails($hWnd)
; Parameters ....: $hWnd  - Handle to the control
; Return values .: True         - View is in detail mode
;                  False        - View is not in detail mode
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Minimum operating systems Windows XP.
; Related .......: _GUICtrlListView_GetView
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetViewDetails($hWnd)
	Return _GUICtrlListView_GetView($hWnd) = 0
EndFunc   ;==>_GUICtrlListView_GetViewDetails

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetViewLarge
; Description ...: Determines whether the view mode is in large icon mode
; Syntax.........: _GUICtrlListView_GetViewLarge($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: True         - View is in large icon mode
;                  False        - View is not in large icon mode
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Minimum operating systems Windows XP.
; Related .......: _GUICtrlListView_GetView
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetViewLarge($hWnd)
	Return _GUICtrlListView_GetView($hWnd) = 1
EndFunc   ;==>_GUICtrlListView_GetViewLarge

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetViewList
; Description ...: Determines whether the view mode is in list mode
; Syntax.........: _GUICtrlListView_GetViewList($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: True         - View is in list mode
;                  False        - View is not in list mode
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Minimum operating systems Windows XP.
; Related .......: _GUICtrlListView_GetView
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetViewList($hWnd)
	Return _GUICtrlListView_GetView($hWnd) = 2
EndFunc   ;==>_GUICtrlListView_GetViewList

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetViewSmall
; Description ...: Determines whether the view mode is in small icon mode
; Syntax.........: _GUICtrlListView_GetViewSmall($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: True         - View is in small icon mode
;                  False        - View is not in small icon mode
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Minimum operating systems Windows XP.
; Related .......: _GUICtrlListView_GetView
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetViewSmall($hWnd)
	Return _GUICtrlListView_GetView($hWnd) = 3
EndFunc   ;==>_GUICtrlListView_GetViewSmall

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetViewTile
; Description ...: Determines whether the view mode is in tile mode
; Syntax.........: _GUICtrlListView_GetViewTile($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: True         - View is in tile mode
;                  False        - View is not in tile mode
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Minimum operating systems Windows XP.
; Related .......: _GUICtrlListView_GetView
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetViewTile($hWnd)
	Return _GUICtrlListView_GetView($hWnd) = 4
EndFunc   ;==>_GUICtrlListView_GetViewTile

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_GetViewRect
; Description ...: Retrieves the bounding rectangle of all items in the control
; Syntax.........: _GUICtrlListView_GetViewRect($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Array with the following format:
;                  |[0] - X coordinate of the upper left corner of the rectangle
;                  |[1] - Y coordinate of the upper left corner of the rectangle
;                  |[2] - X coordinate of the lower right corner of the rectangle
;                  |[3] - Y coordinate of the lower right corner of the rectangle
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: The control must be in icon or small icon view
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_GetViewRect($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $aRect[4] = [0, 0, 0, 0]

	Local $iView = _GUICtrlListView_GetView($hWnd)
	If ($iView <> 1) And ($iView <> 3) Then Return $aRect

	Local $tRect = DllStructCreate($tagRECT)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			_SendMessage($hWnd, $LVM_GETVIEWRECT, 0, $tRect, 0, "wparam", "struct*")
		Else
			Local $iRect = DllStructGetSize($tRect)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iRect, $tMemMap)
			_SendMessage($hWnd, $LVM_GETVIEWRECT, 0, $pMemory, 0, "wparam", "ptr")
			_MemRead($tMemMap, $pMemory, $tRect, $iRect)
			_MemFree($tMemMap)
		EndIf
	Else
		GUICtrlSendMsg($hWnd, $LVM_GETVIEWRECT, 0, DllStructGetPtr($tRect))
	EndIf
	$aRect[0] = DllStructGetData($tRect, "Left")
	$aRect[1] = DllStructGetData($tRect, "Top")
	$aRect[2] = DllStructGetData($tRect, "Right")
	$aRect[3] = DllStructGetData($tRect, "Bottom")
	Return $aRect
EndFunc   ;==>_GUICtrlListView_GetViewRect

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_HideColumn
; Description ...: Hides the column "sets column width to zero"
; Syntax.........: _GUICtrlListView_HideColumn($hWnd, $iCol)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCol        - Column to hide
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_SetColumnWidth
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_HideColumn($hWnd, $iCol)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_SETCOLUMNWIDTH, $iCol) <> 0
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_SETCOLUMNWIDTH, $iCol, 0) <> 0
	EndIf
EndFunc   ;==>_GUICtrlListView_HideColumn

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_HitTest
; Description ...: Determines which item is at a specified position
; Syntax.........: _GUICtrlListView_HitTest($hWnd[, $iX = -1[, $iY = -1]])
; Parameters ....: $hWnd        - Handle to the control
;                  $iX          - X position, in client coordinates, to be tested or -1 to use the current mouse position
;                  $iY          - Y position, in client coordinates, to be tested or -1 to use the current mouse position
; Return values .: Success      - Array with the following format:
;                  |[0] - Zero based index of the item at the specified position, or -1
;                  |[1] - If True, position is in control's client window but not on an item
;                  |[2] - If True, position is over item icon
;                  |[3] - If True, position is over item text
;                  |[4] - If True, position is over item state image
;                  |[5] - If True, position is somewhere on the item
;                  |[6] - If True, position is above the control's client area
;                  |[7] - If True, position is below the control's client area
;                  |[8] - If True, position is to the left of the client area
;                  |[9] - If True, position is to the right of the client area
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_SubItemHitTest
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_HitTest($hWnd, $iX = -1, $iY = -1)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $aTest[10]

	Local $iMode = Opt("MouseCoordMode", 1)
	Local $aPos = MouseGetPos()
	Opt("MouseCoordMode", $iMode)
	Local $tPoint = DllStructCreate($tagPOINT)
	DllStructSetData($tPoint, "X", $aPos[0])
	DllStructSetData($tPoint, "Y", $aPos[1])
	Local $aResult = DllCall("user32.dll", "bool", "ScreenToClient", "hwnd", $hWnd, "struct*", $tPoint)
	If @error Then Return SetError(@error, @extended, 0)
	If $aResult[0] = 0 Then Return 0

	If $iX = -1 Then $iX = DllStructGetData($tPoint, "X")
	If $iY = -1 Then $iY = DllStructGetData($tPoint, "Y")

	Local $tTest = DllStructCreate($tagLVHITTESTINFO)
	DllStructSetData($tTest, "X", $iX)
	DllStructSetData($tTest, "Y", $iY)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			$aTest[0] = _SendMessage($hWnd, $LVM_HITTEST, 0, $tTest, 0, "wparam", "struct*")
		Else
			Local $iTest = DllStructGetSize($tTest)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iTest, $tMemMap)
			_MemWrite($tMemMap, $tTest, $pMemory, $iTest)
			$aTest[0] = _SendMessage($hWnd, $LVM_HITTEST, 0, $pMemory, 0, "wparam", "ptr")
			_MemRead($tMemMap, $pMemory, $tTest, $iTest)
			_MemFree($tMemMap)
		EndIf
	Else
		$aTest[0] = GUICtrlSendMsg($hWnd, $LVM_HITTEST, 0, DllStructGetPtr($tTest))
	EndIf
	Local $iFlags = DllStructGetData($tTest, "Flags")
	$aTest[1] = BitAND($iFlags, $LVHT_NOWHERE) <> 0
	$aTest[2] = BitAND($iFlags, $LVHT_ONITEMICON) <> 0
	$aTest[3] = BitAND($iFlags, $LVHT_ONITEMLABEL) <> 0
	$aTest[4] = BitAND($iFlags, $LVHT_ONITEMSTATEICON) <> 0
	$aTest[5] = BitAND($iFlags, $LVHT_ONITEM) <> 0
	$aTest[6] = BitAND($iFlags, $LVHT_ABOVE) <> 0
	$aTest[7] = BitAND($iFlags, $LVHT_BELOW) <> 0
	$aTest[8] = BitAND($iFlags, $LVHT_TOLEFT) <> 0
	$aTest[9] = BitAND($iFlags, $LVHT_TORIGHT) <> 0
	Return $aTest
EndFunc   ;==>_GUICtrlListView_HitTest

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlListView_IndexToOverlayImageMask
; Description ...: Converts an image index to a overlay image mask
; Syntax.........: __GUICtrlListView_IndexToOverlayImageMask($iIndex)
; Parameters ....: $iIndex      - One based overlay index
; Return values .: Success      - Image index mask
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function is used internally and should not normally be called
; Related .......: __GUICtrlListView_OverlayImageMaskToIndex
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GUICtrlListView_IndexToOverlayImageMask($iIndex)
	Return BitShift($iIndex, -8)
EndFunc   ;==>__GUICtrlListView_IndexToOverlayImageMask

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlListView_IndexToStateImageMask
; Description ...: Converts an image index to a state image mask
; Syntax.........: __GUICtrlListView_IndexToStateImageMask($iIndex)
; Parameters ....: $iIndex      - One based image index
; Return values .: Success      - Image index mask
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function is used internally and should not normally be called
; Related .......: __GUICtrlListView_StateImageMaskToIndex
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GUICtrlListView_IndexToStateImageMask($iIndex)
	Return BitShift($iIndex, -12)
EndFunc   ;==>__GUICtrlListView_IndexToStateImageMask

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_InsertColumn
; Description ...: Inserts a new column in the control
; Syntax.........: _GUICtrlListView_InsertColumn($hWnd, $iIndex, $sText[, $iWidth = 50[, $iAlign = -1[, $iImage = -1[, $fOnRight = False]]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of new column
;                  $sText       - Column header text
;                  $iWidth      - Width of the column, in pixels
;                  $iAlign      - Alignment of the column header and the subitem text in the column:
;                  |0 - Text is left aligned
;                  |1 - Text is right aligned
;                  |2 - Text is centered
;                  $iImage      - Zero based index of an image within the image list
;                  $fOnRight    - If True, the column image appears to the right of text
; Return values .: Success      - The index of the new column
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: The alignment of the leftmost column is always left-justified; it cannot be changed
; Related .......: _GUICtrlListView_DeleteColumn
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_InsertColumn($hWnd, $iIndex, $sText, $iWidth = 50, $iAlign = -1, $iImage = -1, $fOnRight = False)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $aAlign[3] = [$LVCFMT_LEFT, $LVCFMT_RIGHT, $LVCFMT_CENTER]
	Local $fUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)

	Local $iBuffer = StringLen($sText) + 1
	Local $tBuffer
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
		$iBuffer *= 2
	Else
		$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
	EndIf
	Local $pBuffer = DllStructGetPtr($tBuffer)
	Local $tColumn = DllStructCreate($tagLVCOLUMN)
	Local $iMask = BitOR($LVCF_FMT, $LVCF_WIDTH, $LVCF_TEXT)
	If $iAlign < 0 Or $iAlign > 2 Then $iAlign = 0
	Local $iFmt = $aAlign[$iAlign]
	If $iImage <> -1 Then
		$iMask = BitOR($iMask, $LVCF_IMAGE)
		$iFmt = BitOR($iFmt, $LVCFMT_COL_HAS_IMAGES, $LVCFMT_IMAGE)
	EndIf
	If $fOnRight Then $iFmt = BitOR($iFmt, $LVCFMT_BITMAP_ON_RIGHT)
	DllStructSetData($tBuffer, "Text", $sText)
	DllStructSetData($tColumn, "Mask", $iMask)
	DllStructSetData($tColumn, "Fmt", $iFmt)
	DllStructSetData($tColumn, "CX", $iWidth)
	DllStructSetData($tColumn, "TextMax", $iBuffer)
	DllStructSetData($tColumn, "Image", $iImage)
	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			DllStructSetData($tColumn, "Text", $pBuffer)
			$iRet = _SendMessage($hWnd, $LVM_INSERTCOLUMNW, $iIndex, $tColumn, 0, "wparam", "struct*")
		Else
			Local $iColumn = DllStructGetSize($tColumn)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iColumn + $iBuffer, $tMemMap)
			Local $pText = $pMemory + $iColumn
			DllStructSetData($tColumn, "Text", $pText)
			_MemWrite($tMemMap, $tColumn, $pMemory, $iColumn)
			_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
			If $fUnicode Then
				$iRet = _SendMessage($hWnd, $LVM_INSERTCOLUMNW, $iIndex, $pMemory, 0, "wparam", "ptr")
			Else
				$iRet = _SendMessage($hWnd, $LVM_INSERTCOLUMNA, $iIndex, $pMemory, 0, "wparam", "ptr")
			EndIf
			_MemFree($tMemMap)
		EndIf
	Else
		Local $pColumn = DllStructGetPtr($tColumn)
		DllStructSetData($tColumn, "Text", $pBuffer)
		If $fUnicode Then
			$iRet = GUICtrlSendMsg($hWnd, $LVM_INSERTCOLUMNW, $iIndex, $pColumn)
		Else
			$iRet = GUICtrlSendMsg($hWnd, $LVM_INSERTCOLUMNA, $iIndex, $pColumn)
		EndIf
	EndIf
	; added, not sure why justification is not working on insert
	If $iAlign > 0 Then _GUICtrlListView_SetColumn($hWnd, $iRet, $sText, $iWidth, $iAlign, $iImage, $fOnRight)
	Return $iRet
EndFunc   ;==>_GUICtrlListView_InsertColumn

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_InsertGroup
; Description ...: Inserts a group
; Syntax.........: _GUICtrlListView_InsertGroup($hWnd, $iIndex, $iGroupID, $sHeader[, $iAlign = 0])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Index where the group is to be added. If this is -1, the group is added at the end of the list.
;                  $iGroupID    - ID of the group
;                  $sHeader     - Header text
;                  $iAlign      - Alignment of the header text for the group:
;                  |0 - Left
;                  |1 - Center
;                  |2 - Right
; Return values .: Success      - Returns the index of the item that the group was added to
;                  Failure      - -1
; Author ........: Yoan Roblet (Arcker), Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Minimum operating systems Windows XP.
;+
;                  A group cannot be inserted into an empty control.
; Related .......: _GUICtrlListView_SetItemGroupID
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_InsertGroup($hWnd, $iIndex, $iGroupID, $sHeader, $iAlign = 0)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $aAlign[3] = [$LVGA_HEADER_LEFT, $LVGA_HEADER_CENTER, $LVGA_HEADER_RIGHT]

	If $iAlign < 0 Or $iAlign > 2 Then $iAlign = 0

	Local $tHeader = _WinAPI_MultiByteToWideChar($sHeader)
	Local $pHeader = DllStructGetPtr($tHeader)
	Local $iHeader = StringLen($sHeader)
	Local $tGroup = DllStructCreate($tagLVGROUP)
	Local $iGroup = DllStructGetSize($tGroup)
	Local $iMask = BitOR($LVGF_HEADER, $LVGF_ALIGN, $LVGF_GROUPID)
	DllStructSetData($tGroup, "Size", $iGroup)
	DllStructSetData($tGroup, "Mask", $iMask)
	DllStructSetData($tGroup, "HeaderMax", $iHeader)
	DllStructSetData($tGroup, "GroupID", $iGroupID)
	DllStructSetData($tGroup, "Align", $aAlign[$iAlign])
	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			DllStructSetData($tGroup, "Header", $pHeader)
			$iRet = _SendMessage($hWnd, $LVM_INSERTGROUP, $iIndex, $tGroup, 0, "wparam", "struct*")
		Else
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iGroup + $iHeader, $tMemMap)
			Local $pText = $pMemory + $iGroup
			DllStructSetData($tGroup, "Header", $pText)
			_MemWrite($tMemMap, $tGroup, $pMemory, $iGroup)
			_MemWrite($tMemMap, $tHeader, $pText, $iHeader)
			$iRet = _SendMessage($hWnd, $LVM_INSERTGROUP, $iIndex, $tGroup, 0, "wparam", "struct*")
			_MemFree($tMemMap)
		EndIf
	Else
		DllStructSetData($tGroup, "Header", $pHeader)
		$iRet = GUICtrlSendMsg($hWnd, $LVM_INSERTGROUP, $iIndex, DllStructGetPtr($tGroup))
	EndIf
	Return $iRet
EndFunc   ;==>_GUICtrlListView_InsertGroup

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_InsertItem
; Description ...: Inserts a new item in the control
; Syntax.........: _GUICtrlListView_InsertItem($hWnd, $sText[, $iIndex = -1[, $iImage = -1[, $iParam = 0]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $sText       - Item text. If set to -1, the item text is set via the $LVN_GETDISPINFO notification message.
;                  $iIndex      - Zero based index at which the new item should be inserted.  If this value is greater  than  the
;                  +number of items currently contained by the control, the new item will be appended to the end of the list  and
;                  +assigned the correct index.
;                  $iImage      - Zero based index of the item's icon in the control's image list
;                  $iParam      - Application Defined Data
; Return values .: Success      - The index of the new item
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: You can not use this function to insert subitems. Use _GUICtrlListView_SetItemText to insert subitems.
; Related .......: _GUICtrlListView_SetItemText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_InsertItem($hWnd, $sText, $iIndex = -1, $iImage = -1, $iParam = 0)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)

	Local $iBuffer, $tBuffer, $iRet
	If $iIndex = -1 Then $iIndex = 999999999

	Local $tItem = DllStructCreate($tagLVITEM)
	DllStructSetData($tItem, "Param", $iParam)
	If $sText <> -1 Then
		$iBuffer = StringLen($sText) + 1
		If $fUnicode Then
			$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
			$iBuffer *= 2
		Else
			$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
		EndIf
		DllStructSetData($tBuffer, "Text", $sText)
		DllStructSetData($tItem, "Text", DllStructGetPtr($tBuffer))
		DllStructSetData($tItem, "TextMax", $iBuffer)
	Else
		DllStructSetData($tItem, "Text", -1)
	EndIf
	Local $iMask = BitOR($LVIF_TEXT, $LVIF_PARAM)
	If $iImage >= 0 Then $iMask = BitOR($iMask, $LVIF_IMAGE)
	DllStructSetData($tItem, "Mask", $iMask)
	DllStructSetData($tItem, "Item", $iIndex)
	DllStructSetData($tItem, "Image", $iImage)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Or ($sText = -1) Then
			$iRet = _SendMessage($hWnd, $LVM_INSERTITEMW, 0, $tItem, 0, "wparam", "struct*")
		Else
			Local $iItem = DllStructGetSize($tItem)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iItem + $iBuffer, $tMemMap)
			Local $pText = $pMemory + $iItem
			DllStructSetData($tItem, "Text", $pText)
			_MemWrite($tMemMap, $tItem, $pMemory, $iItem)
			_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
			If $fUnicode Then
				$iRet = _SendMessage($hWnd, $LVM_INSERTITEMW, 0, $pMemory, 0, "wparam", "ptr")
			Else
				$iRet = _SendMessage($hWnd, $LVM_INSERTITEMA, 0, $pMemory, 0, "wparam", "ptr")
			EndIf
			_MemFree($tMemMap)
		EndIf
	Else
		Local $pItem = DllStructGetPtr($tItem)
		If $fUnicode Then
			$iRet = GUICtrlSendMsg($hWnd, $LVM_INSERTITEMW, 0, $pItem)
		Else
			$iRet = GUICtrlSendMsg($hWnd, $LVM_INSERTITEMA, 0, $pItem)
		EndIf
	EndIf
	Return $iRet
EndFunc   ;==>_GUICtrlListView_InsertItem

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlListView_InsertMarkHitTest
; Description ...: Retrieves the insertion point closest to a specified point
; Syntax.........: _GUICtrlListView_InsertMarkHitTest($hWnd[, $iX = -1[, $iY = -1]])
; Parameters ....: $hWnd        - Handle to the control
;                  $iX          - X position test point or -1 to use the current mouse position
;                  $iY          - Y position test point or -1 to use the current mouse position
; Return values .: Success      - Array with the following format:
;                  |[0] - True if the insertion point appears after the item, otherwise False
;                  |[1] - Item next to which the insertion point appears. If this is -1, there is no insertion point.
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Minimum operating systems Windows XP.
; Related .......: _GUICtrlListView_GetInsertMark
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlListView_InsertMarkHitTest($hWnd, $iX = -1, $iY = -1)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $iMode = Opt("MouseCoordMode", 1)
	Local $aPos = MouseGetPos()
	Opt("MouseCoordMode", $iMode)
	Local $tPoint = DllStructCreate($tagPOINT)
	DllStructSetData($tPoint, "X", $aPos[0])
	DllStructSetData($tPoint, "Y", $aPos[1])
	Local $aResult = DllCall("user32.dll", "bool", "ScreenToClient", "hwnd", $hWnd, "struct*", $tPoint)
	If @error Then Return SetError(@error, @extended, 0)
	If $aResult[0] = 0 Then Return 0

	If $iX = -1 Then $iX = DllStructGetData($tPoint, "X")
	If $iY = -1 Then $iY = DllStructGetData($tPoint, "Y")

	Local $tMark = DllStructCreate($tagLVINSERTMARK)
	Local $iMark = DllStructGetSize($tMark)
	DllStructSetData($tPoint, "X", $iX)
	DllStructSetData($tPoint, "Y", $iY)
	DllStructSetData($tMark, "Size", $iMark)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			_SendMessage($hWnd, $LVM_INSERTMARKHITTEST, $tPoint, $tMark, 0, "struct*", "struct*")
		Else
			Local $iPoint = DllStructGetSize($tPoint)
			Local $tMemMap
			Local $pMemM = _MemInit($hWnd, $iPoint + $iMark, $tMemMap)
			Local $pMemP = $pMemM + $iPoint ; BUG ??? was referencing $pMemP
			_MemWrite($tMemMap, $tMark, $pMemM, $iMark)
			_MemWrite($tMemMap, $tPoint, $pMemP, $iPoint)
			_SendMessage($hWnd, $LVM_INSERTMARKHITTEST, $pMemP, $pMemM, 0, "wparam", "ptr")
			_MemRead($tMemMap, $pMemM, $tMark, $iMark)
			_MemFree($tMemMap)
		EndIf
	Else
		GUICtrlSendMsg($hWnd, $LVM_INSERTMARKHITTEST, DllStructGetPtr($tPoint), DllStructGetPtr($tMark))
	EndIf
	Local $aTest[2]
	$aTest[0] = DllStructGetData($tMark, "Flags") = $LVIM_AFTER
	$aTest[1] = DllStructGetData($tMark, "Item")
	Return $aTest
EndFunc   ;==>_GUICtrlListView_InsertMarkHitTest

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlListView_IsItemVisible
; Description ...: Gets the state for a specified group
; Syntax.........: _GUICtrlListView_IsItemVisible($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - An index of the item in the list-view control
; Return values .:  True        - Visible
;                  False        - Not Visible
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: Minimum operating systems: Windows Vista
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_IsItemVisible($hWnd, $iIndex)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_ISITEMVISIBLE, $iIndex) <> 0
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_ISITEMVISIBLE, $iIndex, 0) <> 0
	EndIf
EndFunc   ;==>_GUICtrlListView_IsItemVisible

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_JustifyColumn
; Description ...: Set Justification of a column for a list-view control
; Syntax.........: _GUICtrlListView_JustifyColumn($hWnd, $iIndex[, $iAlign = -1])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of new column
;                  $iAlign      - Alignment of the column header and the subitem text in the column:
;                  |0 - Text is left aligned
;                  |1 - Text is right aligned
;                  |2 - Text is centered
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_GetColumn, _GUICtrlListView_SetColumn
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_JustifyColumn($hWnd, $iIndex, $iAlign = -1)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $aAlign[3] = [$LVCFMT_LEFT, $LVCFMT_RIGHT, $LVCFMT_CENTER]
	Local $fUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)

	Local $tColumn = DllStructCreate($tagLVCOLUMN)
	If $iAlign < 0 Or $iAlign > 2 Then $iAlign = 0
	Local $iMask = $LVCF_FMT
	Local $iFmt = $aAlign[$iAlign]
	DllStructSetData($tColumn, "Mask", $iMask)
	DllStructSetData($tColumn, "Fmt", $iFmt)
	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			$iRet = _SendMessage($hWnd, $LVM_SETCOLUMNW, $iIndex, $tColumn, 0, "wparam", "struct*")
		Else
			Local $iColumn = DllStructGetSize($tColumn)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iColumn, $tMemMap)
			_MemWrite($tMemMap, $tColumn, $pMemory, $iColumn)
			If $fUnicode Then
				$iRet = _SendMessage($hWnd, $LVM_SETCOLUMNW, $iIndex, $pMemory, 0, "wparam", "ptr")
			Else
				$iRet = _SendMessage($hWnd, $LVM_SETCOLUMNA, $iIndex, $pMemory, 0, "wparam", "ptr")
			EndIf
			_MemFree($tMemMap)
		EndIf
	Else
		Local $pColumn = DllStructGetPtr($tColumn)
		If $fUnicode Then
			$iRet = GUICtrlSendMsg($hWnd, $LVM_SETCOLUMNW, $iIndex, $pColumn)
		Else
			$iRet = GUICtrlSendMsg($hWnd, $LVM_SETCOLUMNA, $iIndex, $pColumn)
		EndIf
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlListView_JustifyColumn

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_MapIDToIndex
; Description ...: Maps the ID of an item to an index
; Syntax.........: _GUICtrlListView_MapIDToIndex($hWnd, $iID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iID         - ID of an item
; Return values .: Success      - The most current index
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Minimum operating systems Windows XP.
;+
;                  ListView controls internally track items by index. This can present problems because indexes can change during
;                  the control's lifetime.
;+
;                  The ListView control can tag an item with an ID when the item is created.  You can use this ID to guarantee
;                  uniqueness during the lifetime of the control.
; Related .......: _GUICtrlListView_MapIndexToID
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_MapIDToIndex($hWnd, $iID)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_MAPIDTOINDEX, $iID)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_MAPIDTOINDEX, $iID, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_MapIDToIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_MapIndexToID
; Description ...: Maps an index to an item ID
; Syntax.........: _GUICtrlListView_MapIndexToID($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of an item
; Return values .: Success      - The ID of the item
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Minimum operating systems Windows XP.
;+
;                  ListView controls internally track items by index. This can present problems because indexes can change during
;                  the control's lifetime.
;+
;                  The ListView control can tag an item with an ID when the item is created.  You can use this ID to guarantee
;                  uniqueness during the lifetime of the control.
; Related .......: _GUICtrlListView_MapIDToIndex
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_MapIndexToID($hWnd, $iIndex)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_MAPINDEXTOID, $iIndex)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_MAPINDEXTOID, $iIndex, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_MapIndexToID

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlListView_MoveGroup
; Description ...: Moves the group to the specified zero based index
; Syntax.........: _GUICtrlListView_MoveGroup($hWnd, $iGroupID[, $iIndex = -1])
; Parameters ....: $hWnd        - Handle to the control
;                  $iGroupID    - ID of the group to move
;                  $iIndex      - Zero based index of an item where the group will move
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Minimum operating systems Windows XP.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlListView_MoveGroup($hWnd, $iGroupID, $iIndex = -1)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_MOVEGROUP, $iGroupID, $iIndex)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_MOVEGROUP, $iGroupID, $iIndex)
	EndIf
EndFunc   ;==>_GUICtrlListView_MoveGroup

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlListView_OverlayImageMaskToIndex
; Description ...: Converts an overlay image mask to an image index
; Syntax.........: __GUICtrlListView_OverlayImageMaskToIndex($iMask)
; Parameters ....: $iMask       - Image index mask
; Return values .: Success      - Image index
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function is used internally and should not normally be called
; Related .......: __GUICtrlListView_IndexToOverlayImageMask
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GUICtrlListView_OverlayImageMaskToIndex($iMask)
	Return BitShift(BitAND($LVIS_OVERLAYMASK, $iMask), 8)
EndFunc   ;==>__GUICtrlListView_OverlayImageMaskToIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_RedrawItems
; Description ...: Forces the control to redraw a range of items
; Syntax.........: _GUICtrlListView_RedrawItems($hWnd, $iFirst, $iLast)
; Parameters ....: $hWnd        - Handle to the control
;                  $iFirst      - Zero based index of the first item to redraw
;                  $iLast       - Zero based index of the last item to redraw
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: The specified items are not actually redrawn until the control receives a $WM_PAINT message to repaint.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_RedrawItems($hWnd, $iFirst, $iLast)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_REDRAWITEMS, $iFirst, $iLast) <> 0
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_REDRAWITEMS, $iFirst, $iLast) <> 0
	EndIf
EndFunc   ;==>_GUICtrlListView_RedrawItems

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_RegisterSortCallBack
; Description ...: Register the Simple Sort callback function
; Syntax.........: _GUICtrlListView_RegisterSortCallBack($hWnd[, $fNumbers = True[, $fArrows = True]])
; Parameters ....: $hWnd        - Handle of the control
;                  $fNumbers    - Treat number strings as numbers
;                  $fArrows     - Draws a down-arrow/up-arrow on column selected (Windows XP and above)
; Return values .: Success - True
;                  Failure - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......: For each call to _GUICtrlListView_RegisterSortCallBack there must be a call
;                  to _GUICtrlListView_UnRegisterSortCallBack when done (before exit)
;+
;                  It is up to the user to call _GUICtrlListView_UnRegisterSortCallBack for each
;                  _GUICtrlListView_RegisterSortCallBack call made.
;+
;                  This is an alternative to the _GUICtrlListView_SimpleSort.
;                  This function will sort listviews that have icons, checkboxes, sub-item icons
; Related .......: _GUICtrlListView_UnRegisterSortCallBack, _GUICtrlListView_SortItems
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_RegisterSortCallBack($hWnd, $fNumbers = True, $fArrows = True)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)
	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	Local $hHeader = _GUICtrlListView_GetHeader($hWnd)

	ReDim $aListViewSortInfo[UBound($aListViewSortInfo) + 1][$iLListViewSortInfoSize]

	$aListViewSortInfo[0][0] = UBound($aListViewSortInfo) - 1
	Local $iIndex = $aListViewSortInfo[0][0]

	$aListViewSortInfo[$iIndex][1] = $hWnd ; Handle/ID of listview

	$aListViewSortInfo[$iIndex][2] = _
			DllCallbackRegister("__GUICtrlListView_Sort", "int", "int;int;hwnd") ; Handle of callback
	$aListViewSortInfo[$iIndex][3] = -1 ; $nColumn
	$aListViewSortInfo[$iIndex][4] = -1 ; nCurCol
	$aListViewSortInfo[$iIndex][5] = 1 ; $nSortDir
	$aListViewSortInfo[$iIndex][6] = -1 ; $nCol
	$aListViewSortInfo[$iIndex][7] = 0 ; $bSet
	$aListViewSortInfo[$iIndex][8] = $fNumbers ; Treat as numbers?
	$aListViewSortInfo[$iIndex][9] = $fArrows ; Use arrows in the header of the columns?
	$aListViewSortInfo[$iIndex][10] = $hHeader ; Handle to the Header

	Return $aListViewSortInfo[$iIndex][2] <> 0
EndFunc   ;==>_GUICtrlListView_RegisterSortCallBack

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_RemoveAllGroups
; Description ...: Removes all groups from the control
; Syntax.........: _GUICtrlListView_RemoveAllGroups($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: None
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Minimum operating systems Windows XP.
; Related .......: _GUICtrlListView_RemoveGroup
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_RemoveAllGroups($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		_SendMessage($hWnd, $LVM_REMOVEALLGROUPS)
	Else
		GUICtrlSendMsg($hWnd, $LVM_REMOVEALLGROUPS, 0, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_RemoveAllGroups

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_RemoveGroup
; Description ...: Removes a group from the control
; Syntax.........: _GUICtrlListView_RemoveGroup($hWnd, $iGroupID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iGroupID    - ID that specifies the group to remove
; Return values .: Success      - The index of the group
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Minimum operating systems Windows XP.
; Related .......: _GUICtrlListView_RemoveAllGroups
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_RemoveGroup($hWnd, $iGroupID)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_REMOVEGROUP, $iGroupID)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_REMOVEGROUP, $iGroupID, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_RemoveGroup

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlListView_ReverseColorOrder
; Description ...: Convert Hex RGB or BGR Color to Hex RGB or BGR Color
; Syntax.........: __GUICtrlListView_ReverseColorOrder($iColor)
; Parameters ....: $iColor      - Color to convert
; Return values .: Color        - Hex RGB or BGR Color
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: This function is used interanally only
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GUICtrlListView_ReverseColorOrder($iColor)
	Local $tc = Hex(String($iColor), 6)
	Return '0x' & StringMid($tc, 5, 2) & StringMid($tc, 3, 2) & StringMid($tc, 1, 2)
EndFunc   ;==>__GUICtrlListView_ReverseColorOrder

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_Scroll
; Description ...: Scrolls the content of a list-view
; Syntax.........: _GUICtrlListView_Scroll($hWnd, $iDX, $iDY)
; Parameters ....: $hWnd        - Handle to the control
;                  $iDX         - Value of type int that specifies the amount of horizontal scrolling in pixels.
;                  +If the list-view control is in list-view, this value specifies the number of columns to scroll
;                  $iDY         - Value of type int that specifies the amount of vertical scrolling in pixels
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: When the list-view control is in report view, the control can only be scrolled vertically in whole
;                  line increments.  Therefore, the $iDY parameter will be rounded to the nearest number of pixels
;                  that form a whole line increment.  For example, if the height of a line is 16 pixels and 8 is passed
;                  for $iDY, the list will be scrolled by 16 pixels (1 line). If 7 is passed for $iDY, the list will be
;                  scrolled 0 pixels (0 lines).
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_Scroll($hWnd, $iDX, $iDY)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_SCROLL, $iDX, $iDY) <> 0
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_SCROLL, $iDX, $iDY) <> 0
	EndIf
EndFunc   ;==>_GUICtrlListView_Scroll

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetBkColor
; Description ...: Sets the background color of the control
; Syntax.........: _GUICtrlListView_SetBkColor($hWnd, $iColor)
; Parameters ....: $hWnd        - Handle to the control
;                  $iColor      - Background color to set or CLR_NONE value for no background color
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_GetBkColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetBkColor($hWnd, $iColor)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $iRet
	If IsHWnd($hWnd) Then
		$iRet = _SendMessage($hWnd, $LVM_SETBKCOLOR, 0, $iColor)
		_WinAPI_InvalidateRect($hWnd)
	Else
		$iRet = GUICtrlSendMsg($hWnd, $LVM_SETBKCOLOR, 0, $iColor)
		_WinAPI_InvalidateRect(GUICtrlGetHandle($hWnd))
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlListView_SetBkColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetBkImage
; Description ...: Sets the background image in the control
; Syntax.........: _GUICtrlListView_SetBkImage($hWnd[, $sURL = ""[, $iStyle = 0[, $iXOffset = 0[, $iYOffset = 0]]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $sURL        - URL of the background image. If blank, the control has no background
;                  $iStyle      - Determines the background image style:
;                  |0 - Normal
;                  |1 - Tiled
;                  $iXOffset    - Percentage of the control's client area that the image  should  be  offset  horizontally.  Only
;                  +valid when 0 is used in $iStyle.
;                  $iYOffset    - Percentage of the control's client area that the image should be offset vertically.  Only valid
;                  +when 0 is used in $iStyle.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Call CoUninitialize when the application is terminating.
;                  At this time this function only works with _GUICtrlListView_Create or External ListViews.
; Related .......: _GUICtrlListView_Create, _GUICtrlListView_GetBkImage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetBkImage($hWnd, $sURL = "", $iStyle = 0, $iXOffset = 0, $iYOffset = 0)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)

	If Not IsHWnd($hWnd) Then Return SetError($LV_ERR, $LV_ERR, False)
	Local $aStyle[2] = [$LVBKIF_STYLE_NORMAL, $LVBKIF_STYLE_TILE]

	Local $iBuffer = StringLen($sURL) + 1
	Local $tBuffer
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
		$iBuffer *= 2
	Else
		$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
	EndIf
	If @error Then Return SetError($LV_ERR, $LV_ERR, $LV_ERR)
	Local $pBuffer = DllStructGetPtr($tBuffer)
	Local $tImage = DllStructCreate($tagLVBKIMAGE)
	Local $iRet = 0
	If $sURL <> "" Then $iRet = $LVBKIF_SOURCE_URL
	$iRet = BitOR($iRet, $aStyle[$iStyle])
	DllStructSetData($tBuffer, "Text", $sURL)
	DllStructSetData($tImage, "Flags", $iRet)
	DllStructSetData($tImage, "XOffPercent", $iXOffset)
	DllStructSetData($tImage, "YOffPercent", $iYOffset)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			DllStructSetData($tImage, "Image", $pBuffer)
			$iRet = _SendMessage($hWnd, $LVM_SETBKIMAGEW, 0, $tImage, 0, "wparam", "struct*")
		Else
			Local $iImage = DllStructGetSize($tImage)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iImage + $iBuffer, $tMemMap)
			Local $pText = $pMemory + $iImage
			DllStructSetData($tImage, "Image", $pText)
			_MemWrite($tMemMap, $tImage, $pMemory, $iImage)
			_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
			If $fUnicode Then
				$iRet = _SendMessage($hWnd, $LVM_SETBKIMAGEW, 0, $pMemory, 0, "wparam", "ptr")
			Else
				$iRet = _SendMessage($hWnd, $LVM_SETBKIMAGEA, 0, $pMemory, 0, "wparam", "ptr")
			EndIf
			_MemFree($tMemMap)
		EndIf
	Else
		Local $pImage = DllStructGetPtr($tImage)
		DllStructSetData($tImage, "Image", $pBuffer)
		If $fUnicode Then
			$iRet = GUICtrlSendMsg($hWnd, $LVM_SETBKIMAGEW, 0, $pImage)
		Else
			$iRet = GUICtrlSendMsg($hWnd, $LVM_SETBKIMAGEA, 0, $pImage)
		EndIf
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlListView_SetBkImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetCallBackMask
; Description ...: Changes the callback mask for the control
; Syntax.........: _GUICtrlListView_SetCallBackMask($hWnd, $iMask)
; Parameters ....: $hWnd        - Handle to the control
;                  $iMask       - Value of the callback mask. The bits of the mask indicate the item states or images  for  which
;                  +the application stores the current state data.  This value can be any combination of the following:
;                  | 1 - The item is marked for a cut-and-paste operation
;                  | 2 - The item is highlighted as a drag-and-drop target
;                  | 4 - The item has the focus
;                  | 8 - The item is selected
;                  |16 - The application stores the image list index of the current overlay image
;                  |32 - The application stores the image list index of the current state image
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: The callback mask is a set of bit flags that specify the item states for which the application, rather than
;                  the control, stores the current data.  The callback mask applies to all of the control's items, unlike the
;                  callback item designation, which applies to a specific item.  The callback mask is zero by default, meaning
;                  that the control stores all item state information.
; Related .......: _GUICtrlListView_GetCallbackMask
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetCallBackMask($hWnd, $iMask)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $iFlags = 0

	If BitAND($iMask, 1) <> 0 Then $iFlags = BitOR($iFlags, $LVIS_CUT)
	If BitAND($iMask, 2) <> 0 Then $iFlags = BitOR($iFlags, $LVIS_DROPHILITED)
	If BitAND($iMask, 4) <> 0 Then $iFlags = BitOR($iFlags, $LVIS_FOCUSED)
	If BitAND($iMask, 8) <> 0 Then $iFlags = BitOR($iFlags, $LVIS_SELECTED)
	If BitAND($iMask, 16) <> 0 Then $iFlags = BitOR($iFlags, $LVIS_OVERLAYMASK)
	If BitAND($iMask, 32) <> 0 Then $iFlags = BitOR($iFlags, $LVIS_STATEIMAGEMASK)
	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_SETCALLBACKMASK, $iFlags) <> 0
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_SETCALLBACKMASK, $iFlags, 0) <> 0
	EndIf
EndFunc   ;==>_GUICtrlListView_SetCallBackMask

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetColumn
; Description ...: Sets the attributes of a column
; Syntax.........: _GUICtrlListView_SetColumn($hWnd, $iIndex, $sText[, $iWidth = -1[, $iAlign = -1[, $iImage = -1[, $fOnRight = False]]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of new column
;                  $sText       - Column header text
;                  $iWidth      - Width of the column, in pixels
;                  $iAlign      - Alignment of the column header and the subitem text in the column:
;                  |0 - Text is left aligned
;                  |1 - Text is right aligned
;                  |2 - Text is centered
;                  $iImage      - Zero based index of an image within the image list
;                  $fOnRight    - If True, the column image appears to the right of text
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_GetColumn, _GUICtrlListView_JustifyColumn
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetColumn($hWnd, $iIndex, $sText, $iWidth = -1, $iAlign = -1, $iImage = -1, $fOnRight = False)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)

	Local $aAlign[3] = [$LVCFMT_LEFT, $LVCFMT_RIGHT, $LVCFMT_CENTER]

	Local $iBuffer = StringLen($sText) + 1
	Local $tBuffer
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
		$iBuffer *= 2
	Else
		$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
	EndIf
	Local $pBuffer = DllStructGetPtr($tBuffer)
	Local $tColumn = DllStructCreate($tagLVCOLUMN)
	Local $iMask = $LVCF_TEXT
	If $iAlign < 0 Or $iAlign > 2 Then $iAlign = 0
	$iMask = BitOR($iMask, $LVCF_FMT)
	Local $iFmt = $aAlign[$iAlign]
	If $iWidth <> -1 Then $iMask = BitOR($iMask, $LVCF_WIDTH)
	If $iImage <> -1 Then
		$iMask = BitOR($iMask, $LVCF_IMAGE)
		$iFmt = BitOR($iFmt, $LVCFMT_COL_HAS_IMAGES, $LVCFMT_IMAGE)
	Else
		$iImage = 0
	EndIf
	If $fOnRight Then $iFmt = BitOR($iFmt, $LVCFMT_BITMAP_ON_RIGHT)
	DllStructSetData($tBuffer, "Text", $sText)
	DllStructSetData($tColumn, "Mask", $iMask)
	DllStructSetData($tColumn, "Fmt", $iFmt)
	DllStructSetData($tColumn, "CX", $iWidth)
	DllStructSetData($tColumn, "TextMax", $iBuffer)
	DllStructSetData($tColumn, "Image", $iImage)
	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			DllStructSetData($tColumn, "Text", $pBuffer)
			$iRet = _SendMessage($hWnd, $LVM_SETCOLUMNW, $iIndex, $tColumn, 0, "wparam", "struct*")
		Else
			Local $iColumn = DllStructGetSize($tColumn)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iColumn + $iBuffer, $tMemMap)
			Local $pText = $pMemory + $iColumn
			DllStructSetData($tColumn, "Text", $pText)
			_MemWrite($tMemMap, $tColumn, $pMemory, $iColumn)
			_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
			If $fUnicode Then
				$iRet = _SendMessage($hWnd, $LVM_SETCOLUMNW, $iIndex, $pMemory, 0, "wparam", "ptr")
			Else
				$iRet = _SendMessage($hWnd, $LVM_SETCOLUMNA, $iIndex, $pMemory, 0, "wparam", "ptr")
			EndIf
			_MemFree($tMemMap)
		EndIf
	Else
		Local $pColumn = DllStructGetPtr($tColumn)
		DllStructSetData($tColumn, "Text", $pBuffer)
		If $fUnicode Then
			$iRet = GUICtrlSendMsg($hWnd, $LVM_SETCOLUMNW, $iIndex, $pColumn)
		Else
			$iRet = GUICtrlSendMsg($hWnd, $LVM_SETCOLUMNA, $iIndex, $pColumn)
		EndIf
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlListView_SetColumn

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetColumnOrder
; Description ...: Sets the left-to-right order of columns
; Syntax.........: _GUICtrlListView_SetColumnOrder($hWnd, $sOrder)
; Parameters ....: $hWnd        - Handle to the control
;                  $sOrder      - Use Opt('GUIDataSeparatorChar', param) to set Separator Char,
;                  +delimited column order, must be formated as follows:
;                  |"2|0|3|1"
; Return values .: None
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Columns are zero-based
; Related .......: _GUICtrlListView_GetColumnOrder, _GUICtrlListView_SetColumnOrderArray
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetColumnOrder($hWnd, $sOrder)
	Local $SeparatorChar = Opt('GUIDataSeparatorChar')
	Return _GUICtrlListView_SetColumnOrderArray($hWnd, StringSplit($sOrder, $SeparatorChar))
EndFunc   ;==>_GUICtrlListView_SetColumnOrder

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetColumnOrderArray
; Description ...: Sets the left-to-right order of columns in the control
; Syntax.........: _GUICtrlListView_SetColumnOrderArray($hWnd, $aOrder)
; Parameters ....: $hWnd        - Handle to the control
;                  $aOrder      - Array of integers that holds the index values of the columsn in the control.  The array must be
;                  +formatted as follows:
;                  |[0] - Number of items in array
;                  |[1] - First column index
;                  |[2] - Second column index
;                  |[n] - Last column index
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_GetColumnOrder, _GUICtrlListView_GetColumnOrderArray, _GUICtrlListView_SetColumnOrder
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetColumnOrderArray($hWnd, $aOrder)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $tBuffer = DllStructCreate("int[" & $aOrder[0] & "]")
	For $iI = 1 To $aOrder[0]
		DllStructSetData($tBuffer, 1, $aOrder[$iI], $iI)
	Next

	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			$iRet = _SendMessage($hWnd, $LVM_SETCOLUMNORDERARRAY, $aOrder[0], $tBuffer, 0, "wparam", "struct*")
		Else
			Local $iBuffer = DllStructGetSize($tBuffer)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iBuffer, $tMemMap)
			_MemWrite($tMemMap, $tBuffer, $pMemory, $iBuffer)
			$iRet = _SendMessage($hWnd, $LVM_SETCOLUMNORDERARRAY, $aOrder[0], $pMemory, 0, "wparam", "ptr")
			_MemFree($tMemMap)
		EndIf
	Else
		$iRet = GUICtrlSendMsg($hWnd, $LVM_SETCOLUMNORDERARRAY, $aOrder[0], DllStructGetPtr($tBuffer))
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlListView_SetColumnOrderArray

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetColumnWidth
; Description ...: Changes the width of a column
; Syntax.........: _GUICtrlListView_SetColumnWidth($hWnd, $iCol, $iWidth)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCol        - Zero-based index of a valid column. For list-view mode, this parameter must be set to zero
;                  $iWidth      - New width of the column, in pixels.
;                  +For report-view mode, the following special values are supported:
;                  |$LVSCW_AUTOSIZE - Automatically sizes the column.
;                  |$LVSCW_AUTOSIZE_USEHEADER - Automatically sizes the column to fit the header text.
;                  +If you use this value with the last column, its width
;                  +is set to fill the remaining width of the list-view control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_GetColumnWidth, _GUICtrlListView_HideColumn
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetColumnWidth($hWnd, $iCol, $iWidth)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_SETCOLUMNWIDTH, $iCol, $iWidth)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_SETCOLUMNWIDTH, $iCol, $iWidth)
	EndIf
EndFunc   ;==>_GUICtrlListView_SetColumnWidth

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetExtendedListViewStyle
; Description ...: Sets extended styles
; Syntax.........: _GUICtrlListView_SetExtendedListViewStyle($hWnd, $iExStyle[, $iExMask = 0])
; Parameters ....: $hWnd        - Handle to the control
;                  $iExStyle    - Extended control styles:
;                  |$LVS_EX_BORDERSELECT     - When an item is selected the border color of the item changes
;                  |$LVS_EX_CHECKBOXES       - Enables check boxes for items in a list-view control
;                  |$LVS_EX_DOUBLEBUFFER     - Paints via double-buffering, which reduces flicker
;                  |$LVS_EX_FLATSB           - Enables flat scroll bars in the list view
;                  |$LVS_EX_FULLROWSELECT    - When an item is selected, the item and all its subitems are highlighted
;                  |$LVS_EX_GRIDLINES        - Displays gridlines around items and subitems
;                  |$LVS_EX_HEADERDRAGDROP   - Enables drag-and-drop reordering of columns
;                  |$LVS_EX_INFOTIP          - The $LVN_GETINFOTIP notification message is sent before displaying a ToolTip
;                  |$LVS_EX_LABELTIP         - If not set, the unfolds partly hidden labels only for the large icon mode
;                  |$LVS_EX_MULTIWORKAREAS   - The control will not autoarrange its icons until one or more work areas are defined
;                  |$LVS_EX_ONECLICKACTIVATE - The control sends an $LVN_ITEMACTIVATE messages when the user clicks an item
;                  |$LVS_EX_REGIONAL         - Sets the control region to include only the item icons and text
;                  |$LVS_EX_SIMPLESELECT     - In icon view moves the state image of the control to the top right
;                  |$LVS_EX_SUBITEMIMAGES    - Allows images to be displayed for subitems
;                  |$LVS_EX_TRACKSELECT      - Enables hot-track selection in the control
;                  |$LVS_EX_TWOCLICKACTIVATE - The control sends an $LVN_ITEMACTIVATE message when the user double-clicks an item
;                  |$LVS_EX_UNDERLINECOLD    - Causes non-hot items that may be activated to be displayed with underlined text
;                  |$LVS_EX_UNDERLINEHOT     - Causes hot items that may be activated to be displayed with underlined text
;                  $iExMask     - Specifies which styles in $iExStyle are to be affected.  This parameter can be a combination of
;                  +extended styles. Only the extended styles in $iExMask will be changed. All other styles will be maintained as
;                  +they are. If this parameter is zero, all of the styles in $iExStyle will be affected.
; Return values .: Success      - The previous extended styles
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_GetExtendedListViewStyle
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetExtendedListViewStyle($hWnd, $iExStyle, $iExMask = 0)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $iRet
	If IsHWnd($hWnd) Then
		$iRet = _SendMessage($hWnd, $LVM_SETEXTENDEDLISTVIEWSTYLE, $iExMask, $iExStyle)
		_WinAPI_InvalidateRect($hWnd)
	Else
		$iRet = GUICtrlSendMsg($hWnd, $LVM_SETEXTENDEDLISTVIEWSTYLE, $iExMask, $iExStyle)
		_WinAPI_InvalidateRect(GUICtrlGetHandle($hWnd))
	EndIf
	Return $iRet
EndFunc   ;==>_GUICtrlListView_SetExtendedListViewStyle

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetGroupInfo
; Description ...: Sets group information
; Syntax.........: _GUICtrlListView_SetGroupInfo($hWnd, $iGroupID, $sHeader[, $iAlign = 0[, $iState = $LVGS_NORMAL]])
; Parameters ....: $hWnd        - Handle to the control
;                  $iGroupID    - ID of the group
;                  $sHeader     - Header text
;                  $iAlign      - Alignment of the header text for the group:
;                  |  0 - Left
;                  |  1 - Center
;                  |  2 - Right
;                  $iState      - Vista and above, can have one of the following values:
;                  |  $LVGS_NORMAL      - Groups are expanded, the group name is displayed, and all items in the group are displayed.
;                  |  $LVGS_COLLAPSED         - The group is collapsed.
;                  |  $LVGS_HIDDEN            - The group is hidden.
;                  |  $LVGS_NOHEADER          - The group does not display a header.
;                  |  $LVGS_COLLAPSIBLE       - The group can be collapsed.
;                  |  $LVGS_FOCUSED           - The group has keyboard focus.
;                  |  $LVGS_SELECTED          - The group is selected.
;                  |  $LVGS_SUBSETED          - The group displays only a portion of its items.
;                  |  $LVGS_SUBSETLINKFOCUSED - The subset link of the group has keyboard focus
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Minimum operating systems Windows XP.
; Related .......: _GUICtrlListView_GetGroupInfo, _GUICtrlListView_GetGroupInfoByIndex
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetGroupInfo($hWnd, $iGroupID, $sHeader, $iAlign = 0, $iState = $LVGS_NORMAL)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $aAlign[3] = [$LVGA_HEADER_LEFT, $LVGA_HEADER_CENTER, $LVGA_HEADER_RIGHT]

	If $iAlign < 0 Or $iAlign > 2 Then $iAlign = 0

	Local $tHeader = _WinAPI_MultiByteToWideChar($sHeader)
	Local $pHeader = DllStructGetPtr($tHeader)
	Local $iHeader = StringLen($sHeader)
	Local $tGroup = DllStructCreate($tagLVGROUP)
	Local $pGroup = DllStructGetPtr($tGroup)
	Local $iGroup = DllStructGetSize($tGroup)
	Local $iMask = BitOR($LVGF_HEADER, $LVGF_ALIGN, $LVGF_STATE)
	DllStructSetData($tGroup, "Size", $iGroup)
	DllStructSetData($tGroup, "Mask", $iMask)
	DllStructSetData($tGroup, "HeaderMax", $iHeader)
	DllStructSetData($tGroup, "Align", $aAlign[$iAlign])
	DllStructSetData($tGroup, "State", $iState)
	DllStructSetData($tGroup, "StateMask", $iState)
	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			DllStructSetData($tGroup, "Header", $pHeader)
			$iRet = _SendMessage($hWnd, $LVM_SETGROUPINFO, $iGroupID, $pGroup)
			DllStructSetData($tGroup, "Mask", $LVGF_GROUPID)
			DllStructSetData($tGroup, "GroupID", $iGroupID)
			_SendMessage($hWnd, $LVM_SETGROUPINFO, 0, $pGroup)
		Else
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iGroup + $iHeader, $tMemMap)
			Local $pText = $pMemory + $iGroup
			DllStructSetData($tGroup, "Header", $pText)
			_MemWrite($tMemMap, $tGroup, $pMemory, $iGroup)
			_MemWrite($tMemMap, $tHeader, $pText, $iHeader)
			$iRet = _SendMessage($hWnd, $LVM_SETGROUPINFO, $iGroupID, $pMemory)
			DllStructSetData($tGroup, "Mask", $LVGF_GROUPID)
			DllStructSetData($tGroup, "GroupID", $iGroupID)
			_SendMessage($hWnd, $LVM_SETGROUPINFO, 0, $pMemory)
			_MemFree($tMemMap)
		EndIf
		_WinAPI_InvalidateRect($hWnd)
	Else
		DllStructSetData($tGroup, "Header", $pHeader)
		$iRet = GUICtrlSendMsg($hWnd, $LVM_SETGROUPINFO, $iGroupID, $pGroup)
		DllStructSetData($tGroup, "Mask", $LVGF_GROUPID)
		DllStructSetData($tGroup, "GroupID", $iGroupID)
		GUICtrlSendMsg($hWnd, $LVM_SETGROUPINFO, 0, $pGroup)
		_WinAPI_InvalidateRect(GUICtrlGetHandle($hWnd))
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlListView_SetGroupInfo

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlListView_SetHotCursor
; Description ...: Sets the cursor handle that the control uses
; Syntax.........: _GUICtrlListView_SetHotCursor($hWnd, $hCursor)
; Parameters ....: $hWnd        - Handle to the control
;                  $hCursor     - Handle to the cursor to be set
; Return values .: Success      - Handle to the previous hot cursor
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Currently not tested
; Related .......: _GUICtrlListView_GetHotCursor
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlListView_SetHotCursor($hWnd, $hCursor)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_SETHOTCURSOR, 0, $hCursor, 0, "wparam", "handle", "handle")
	Else
		Return Ptr(GUICtrlSendMsg($hWnd, $LVM_SETHOTCURSOR, 0, $hCursor))
	EndIf
EndFunc   ;==>_GUICtrlListView_SetHotCursor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetHotItem
; Description ...: Sets the hot item
; Syntax.........: _GUICtrlListView_SetHotItem($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero-based index of the item to be set as the hot item
; Return values .: Success      - Index of the item that was previously hot
;                  Failure      - -1
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_GetHotItem
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetHotItem($hWnd, $iIndex)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_SETHOTITEM, $iIndex)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_SETHOTITEM, $iIndex, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_SetHotItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetHoverTime
; Description ...: Sets the amount of time which the mouse cursor must hover over an item before it is selected
; Syntax.........: _GUICtrlListView_SetHoverTime($hWnd, $iTime)
; Parameters ....: $hWnd        - Handle to the control
;                  $iTime       - The new amount of time, in milliseconds, that the mouse cursor must hover over
;                  +an item before it is selected. If this value is (DWORD)-1, then the hover time is set to the
;                  +default hover time.
; Return values .: Success      - The previous hover time
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The hover time only affects list-view controls that have the $LVS_EX_TRACKSELECT,
;                  $LVS_EX_ONECLICKACTIVATE, or $LVS_EX_TWOCLICKACTIVATE extended list-view style
; Related .......: _GUICtrlListView_GetHoverTime
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetHoverTime($hWnd, $iTime)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_SETHOVERTIME, 0, $iTime)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_SETHOVERTIME, 0, $iTime)
	EndIf
EndFunc   ;==>_GUICtrlListView_SetHoverTime

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetIconSpacing
; Description ...: Sets the spacing between icons where the style is large icon
; Syntax.........: _GUICtrlListView_SetIconSpacing($hWnd, $iCX, $iCY)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCX         - Distance, in pixels, to set between icons on the x-axis
;                  $iCY         - Distance, in pixels, to set between icons on the y-axis
; Return values .: Success      - Array with the following format:
;                  |[0] - Previous CX value
;                  |[1] - Previous CY value
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Values for $iCX and $iCY are relative to the upper-left corner of an icon bitmap. To set spacing between icons
;                  that do not overlap, the $iCX or $iCY values must include the size of the icon, plus the amount of empty space
;                  desired between icons. Values that do not include the width of the icon will result in overlaps.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetIconSpacing($hWnd, $iCX, $iCY)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $iRet, $aPadding[2]

	If IsHWnd($hWnd) Then
		$iRet = _SendMessage($hWnd, $LVM_SETICONSPACING, 0, _WinAPI_MakeLong($iCX, $iCY))
		_WinAPI_InvalidateRect($hWnd)
	Else
		$iRet = GUICtrlSendMsg($hWnd, $LVM_SETICONSPACING, 0, _WinAPI_MakeLong($iCX, $iCY))
		_WinAPI_InvalidateRect(GUICtrlGetHandle($hWnd))
	EndIf
	$aPadding[0] = BitAND($iRet, 0xFFFF)
	$aPadding[1] = BitShift($iRet, 16)
	Return $aPadding
EndFunc   ;==>_GUICtrlListView_SetIconSpacing

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetImageList
; Description ...: Assigns an image list to the control
; Syntax.........: _GUICtrlListView_SetImageList($hWnd, $hHandle[, $iType = 0])
; Parameters ....: $hWnd  - Handle to the control
;                  $hHandle     - Handle to the image list to assign
;                  $iType       - Type of image list:
;                  |0 - Image list with large icons
;                  |1 - Image list with small icons
;                  |2 - Image list with state images
; Return values .: Success      - The handle to the previous image list
;                  Failue       - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: The current image list will be destroyed when the control is destroyed unless you set the $LVS_SHAREIMAGELISTS
;                  style. If you use this message to replace one image list with another your application must explicitly destroy
;                  all image lists other than the current one.
; Related .......: _GUICtrlListView_GetImageList
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetImageList($hWnd, $hHandle, $iType = 0)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $aType[3] = [$LVSIL_NORMAL, $LVSIL_SMALL, $LVSIL_STATE]

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_SETIMAGELIST, $aType[$iType], $hHandle, 0, "wparam", "handle", "handle")
	Else
		Return Ptr(GUICtrlSendMsg($hWnd, $LVM_SETIMAGELIST, $aType[$iType], $hHandle))
	EndIf
EndFunc   ;==>_GUICtrlListView_SetImageList

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlListView_SetInfoTip
; Description ...: Sets ToolTip text
; Syntax.........: _GUICtrlListView_SetInfoTip($hWnd, $iIndex, $sText[, $iSubItem = 0])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $sText       - String that contains the tooltip text
;                  $iSubItem    - One based index of the subitem
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Minimum operating systems Windows XP.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlListView_SetInfoTip($hWnd, $iIndex, $sText, $iSubItem = 0)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $tBuffer = _WinAPI_MultiByteToWideChar($sText)
	Local $pBuffer = DllStructGetPtr($tBuffer)
	Local $iBuffer = StringLen($sText)
	Local $tInfo = DllStructCreate($tagLVSETINFOTIP)
	Local $iInfo = DllStructGetSize($tInfo)
	DllStructSetData($tInfo, "Size", $iInfo)
	DllStructSetData($tInfo, "Item", $iIndex)
	DllStructSetData($tInfo, "SubItem", $iSubItem)
	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			DllStructSetData($tInfo, "Text", $pBuffer)
			$iRet = _SendMessage($hWnd, $LVM_SETINFOTIP, 0, $tInfo, 0, "wparam", "struct*")
		Else
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iInfo + $iBuffer, $tMemMap)
			Local $pText = $pMemory + $iInfo
			DllStructSetData($tInfo, "Text", $pText)
			_MemWrite($tMemMap, $tInfo, $pMemory, $iInfo)
			_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
			$iRet = _SendMessage($hWnd, $LVM_SETINFOTIP, 0, $pMemory, 0, "wparam", "ptr")
			_MemFree($tMemMap)
		EndIf
	Else
		DllStructSetData($tInfo, "Text", $pBuffer)
		$iRet = GUICtrlSendMsg($hWnd, $LVM_SETINFOTIP, 0, DllStructGetPtr($tInfo))
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlListView_SetInfoTip

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlListView_SetInsertMark
; Description ...: Sets the insertion point to the defined position
; Syntax.........: _GUICtrlListView_SetInsertMark($hWnd, $iIndex[, $fAfter = False])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $fAfter      - Insertion point:
;                  | True - The insertion point will appear after the item
;                  |False - The insertion point will appear before the item
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Minimum operating systems Windows XP.
;+
;                  An insertion point can only appear if the control is in icon view, small icon view,  or  tile
;                  view, and not in group view mode.
; Related .......: _GUICtrlListView_GetInsertMark
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlListView_SetInsertMark($hWnd, $iIndex, $fAfter = False)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $tMark = DllStructCreate($tagLVINSERTMARK)
	Local $iMark = DllStructGetSize($tMark)
	DllStructSetData($tMark, "Size", $iMark)
	If $fAfter Then DllStructSetData($tMark, "Flags", $LVIM_AFTER)
	DllStructSetData($tMark, "Item", $iIndex)
	DllStructSetData($tMark, "Reserved", 0)
	Local $iRet
	If IsHWnd($hWnd) Then
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iMark, $tMemMap)
		_MemWrite($tMemMap, $tMark, $pMemory, $iMark)
		$iRet = _SendMessage($hWnd, $LVM_SETINSERTMARK, 0, $pMemory, 0, "wparam", "ptr")
		_MemFree($tMemMap)
	Else
		$iRet = GUICtrlSendMsg($hWnd, $LVM_SETINSERTMARK, 0, DllStructGetPtr($tMark))
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlListView_SetInsertMark

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUICtrlListView_SetInsertMarkColor
; Description ...: Sets the color of the insertion point
; Syntax.........: _GUICtrlListView_SetInsertMarkColor($hWnd, $iColor)
; Parameters ....: $hWnd        - Handle to the control
;                  $iColor      - Color to set the insertion point
; Return values .: Success      - The previous insertion point color
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Minimum operating systems Windows XP.
; Related .......: _GUICtrlListView_GetInsertMarkColor
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlListView_SetInsertMarkColor($hWnd, $iColor)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_SETINSERTMARKCOLOR, 0, $iColor)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_SETINSERTMARKCOLOR, 0, $iColor)
	EndIf
EndFunc   ;==>_GUICtrlListView_SetInsertMarkColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetItem
; Description ...: Sets some or all of a item's attributes
; Syntax.........: _GUICtrlListView_SetItem($hWnd, $sText[, $iIndex = 0[, $iSubItem = 0[, $iImage = -1[, $iParam = -1[, $iIndent = -1]]]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $sText       - Item text
;                  $iIndex      - The zero-based index of the item
;                  $iSubItem    - One based index of the subitem or zero if this refers to an item
;                  $iImage      - Zero base index of the item's icon in the control's image list
;                  $iParam      - Value specific to the item
;                  $iIndent     - Number of image widths to indent the item. A single indentation equals the width of an image.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_GetItem, _GUICtrlListView_SetItemEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetItem($hWnd, $sText, $iIndex = 0, $iSubItem = 0, $iImage = -1, $iParam = -1, $iIndent = -1)
	Local $pBuffer, $iBuffer
	If $sText <> -1 Then
		$iBuffer = StringLen($sText) + 1
		Local $tBuffer
		If _GUICtrlListView_GetUnicodeFormat($hWnd) Then
			$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
		Else
			$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
		EndIf
		$pBuffer = DllStructGetPtr($tBuffer)
		DllStructSetData($tBuffer, "Text", $sText)
	Else
		$iBuffer = 0
		$pBuffer = -1 ; LPSTR_TEXTCALLBACK
	EndIf

	Local $tItem = DllStructCreate($tagLVITEM)
	Local $iMask = $LVIF_TEXT
	If $iImage <> -1 Then $iMask = BitOR($iMask, $LVIF_IMAGE)
	If $iParam <> -1 Then $iMask = BitOR($iMask, $LVIF_PARAM)
	If $iIndent <> -1 Then $iMask = BitOR($iMask, $LVIF_INDENT)
	DllStructSetData($tItem, "Mask", $iMask)
	DllStructSetData($tItem, "Item", $iIndex)
	DllStructSetData($tItem, "SubItem", $iSubItem)
	DllStructSetData($tItem, "Text", $pBuffer)
	DllStructSetData($tItem, "TextMax", $iBuffer)
	DllStructSetData($tItem, "Image", $iImage)
	DllStructSetData($tItem, "Param", $iParam)
	DllStructSetData($tItem, "Indent", $iIndent)
	Return _GUICtrlListView_SetItemEx($hWnd, $tItem)
EndFunc   ;==>_GUICtrlListView_SetItem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetItemChecked
; Description ...: Sets the checked state
; Syntax.........: _GUICtrlListView_SetItemChecked($hWnd, $iIndex[, $fCheck = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero-based index of the item, -1 sets all items
;                  $fCheck      - Value to set checked state to:
;                  | True       - Checked
;                  |False       - Not checked
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Use only on controls that have the $LVS_EX_CHECKBOXES extended style
; Related .......: _GUICtrlListView_GetItemChecked
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetItemChecked($hWnd, $iIndex, $fCheck = True)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)

	Local $pMemory, $tMemMap, $iRet

	Local $tItem = DllStructCreate($tagLVITEM)
	Local $pItem = DllStructGetPtr($tItem)
	Local $iItem = DllStructGetSize($tItem)
	If @error Then Return SetError($LV_ERR, $LV_ERR, $LV_ERR)
	If $iIndex <> -1 Then
		DllStructSetData($tItem, "Mask", $LVIF_STATE)
		DllStructSetData($tItem, "Item", $iIndex)
		If ($fCheck) Then
			DllStructSetData($tItem, "State", 0x2000)
		Else
			DllStructSetData($tItem, "State", 0x1000)
		EndIf
		DllStructSetData($tItem, "StateMask", 0xf000)
		If IsHWnd($hWnd) Then
			If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
				Return _SendMessage($hWnd, $LVM_SETITEMW, 0, $tItem, 0, "wparam", "struct*") <> 0
			Else
				$pMemory = _MemInit($hWnd, $iItem, $tMemMap)
				_MemWrite($tMemMap, $tItem)
				If $fUnicode Then
					$iRet = _SendMessage($hWnd, $LVM_SETITEMW, 0, $pMemory, 0, "wparam", "ptr")
				Else
					$iRet = _SendMessage($hWnd, $LVM_SETITEMA, 0, $pMemory, 0, "wparam", "ptr")
				EndIf
				_MemFree($tMemMap)
				Return $iRet <> 0
			EndIf
		Else
			If $fUnicode Then
				Return GUICtrlSendMsg($hWnd, $LVM_SETITEMW, 0, $pItem) <> 0
			Else
				Return GUICtrlSendMsg($hWnd, $LVM_SETITEMA, 0, $pItem) <> 0
			EndIf
		EndIf
	Else
		For $x = 0 To _GUICtrlListView_GetItemCount($hWnd) - 1
			DllStructSetData($tItem, "Mask", $LVIF_STATE)
			DllStructSetData($tItem, "Item", $x)
			If ($fCheck) Then
				DllStructSetData($tItem, "State", 0x2000)
			Else
				DllStructSetData($tItem, "State", 0x1000)
			EndIf
			DllStructSetData($tItem, "StateMask", 0xf000)
			If IsHWnd($hWnd) Then
				If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
					If Not _SendMessage($hWnd, $LVM_SETITEMW, 0, $tItem, 0, "wparam", "struct*") <> 0 Then Return SetError($LV_ERR, $LV_ERR, $LV_ERR)
				Else
					$pMemory = _MemInit($hWnd, $iItem, $tMemMap)
					_MemWrite($tMemMap, $tItem)
					If $fUnicode Then
						$iRet = _SendMessage($hWnd, $LVM_SETITEMW, 0, $pMemory, 0, "wparam", "ptr")
					Else
						$iRet = _SendMessage($hWnd, $LVM_SETITEMA, 0, $pMemory, 0, "wparam", "ptr")
					EndIf
					_MemFree($tMemMap)
					If Not $iRet <> 0 Then Return SetError($LV_ERR, $LV_ERR, $LV_ERR)
				EndIf
			Else
				If $fUnicode Then
					If Not GUICtrlSendMsg($hWnd, $LVM_SETITEMW, 0, $pItem) <> 0 Then Return SetError($LV_ERR, $LV_ERR, $LV_ERR)
				Else
					If Not GUICtrlSendMsg($hWnd, $LVM_SETITEMA, 0, $pItem) <> 0 Then Return SetError($LV_ERR, $LV_ERR, $LV_ERR)
				EndIf
			EndIf
		Next
		Return True
	EndIf
	Return False
EndFunc   ;==>_GUICtrlListView_SetItemChecked

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetItemCount
; Description ...: Causes the list-view control to allocate memory for the specified number of items
; Syntax.........: _GUICtrlListView_SetItemCount($hWnd, $iItems)
; Parameters ....: $hWnd        - Handle to the control
;                  $iItems      - Number of items that the list-view control will ultimately contain
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Causes the control to allocate its internal data structures for the specified number of items.
;                  This prevents the control from having to allocate the data structures every time an item is added.
; Related .......: _GUICtrlListView_GetItemCount
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetItemCount($hWnd, $iItems)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_SETITEMCOUNT, $iItems, BitOR($LVSICF_NOINVALIDATEALL, $LVSICF_NOSCROLL)) <> 0
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_SETITEMCOUNT, $iItems, BitOR($LVSICF_NOINVALIDATEALL, $LVSICF_NOSCROLL)) <> 0
	EndIf
EndFunc   ;==>_GUICtrlListView_SetItemCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetItemCut
; Description ...: Sets whether the item is marked for a cut-and-paste operation
; Syntax.........: _GUICtrlListView_SetItemCut($hWnd, $iIndex[, $fEnabled = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $fEnabled    - If True the item state is set, otherwise it is not set.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_GetItemCut
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetItemCut($hWnd, $iIndex, $fEnabled = True)
	Local $iState = 0

	If $fEnabled Then $iState = $LVIS_CUT
	Return _GUICtrlListView_SetItemState($hWnd, $iIndex, $iState, $LVIS_CUT)
EndFunc   ;==>_GUICtrlListView_SetItemCut

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetItemDropHilited
; Description ...: Sets whether the item is highlighted as a drag-and-drop target
; Syntax.........: _GUICtrlListView_SetItemDropHilited($hWnd, $iIndex[, $fEnabled = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $fEnabled    - If True the item state is set, otherwise it is not set.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_GetItemDropHilited
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetItemDropHilited($hWnd, $iIndex, $fEnabled = True)
	Local $iState = 0

	If $fEnabled Then $iState = $LVIS_DROPHILITED
	Return _GUICtrlListView_SetItemState($hWnd, $iIndex, $iState, $LVIS_DROPHILITED)
EndFunc   ;==>_GUICtrlListView_SetItemDropHilited

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetItemEx
; Description ...: Sets some or all of a item's attributes
; Syntax.........: _GUICtrlListView_SetItemEx($hWnd, ByRef $tItem)
; Parameters ....: $hWnd  - Handle to the control
;                  $tItem       - $tagLVITEM structure
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: To set the attributes of an item set the Item member of the $tagLVITEM structure to the index of the item, and
;                  set the SubItem member to zero.  For an item, you can set the State, Text, Image, and Param members of the
;                  $tagLVITEM structure.
;+
;                  To set the text of a subitem, set the Item and SubItem members to indicate the specific subitem, and use the
;                  Text member to specify the text.  You cannot set the State or Param members for subitems because subitems do
;                  not have these attributes.
; Related .......: _GUICtrlListView_SetItem, $tagLVITEM
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetItemEx($hWnd, ByRef $tItem)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)

	Local $iRet
	If IsHWnd($hWnd) Then
		Local $iItem = DllStructGetSize($tItem)
		Local $iBuffer = DllStructGetData($tItem, "TextMax")
		Local $pBuffer = DllStructGetData($tItem, "Text")
		If $fUnicode Then $iBuffer *= 2
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iItem + $iBuffer, $tMemMap)
		Local $pText = $pMemory + $iItem
		DllStructSetData($tItem, "Text", $pText)
		_MemWrite($tMemMap, $tItem, $pMemory, $iItem)
		If $pBuffer <> 0 Then _MemWrite($tMemMap, $pBuffer, $pText, $iBuffer)
		If $fUnicode Then
			$iRet = _SendMessage($hWnd, $LVM_SETITEMW, 0, $pMemory, 0, "wparam", "ptr")
		Else
			$iRet = _SendMessage($hWnd, $LVM_SETITEMA, 0, $pMemory, 0, "wparam", "ptr")
		EndIf
		_MemFree($tMemMap)
	Else
		Local $pItem = DllStructGetPtr($tItem)
		If $fUnicode Then
			$iRet = GUICtrlSendMsg($hWnd, $LVM_SETITEMW, 0, $pItem)
		Else
			$iRet = GUICtrlSendMsg($hWnd, $LVM_SETITEMA, 0, $pItem)
		EndIf
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlListView_SetItemEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetItemFocused
; Description ...: Sets whether the item has the focus
; Syntax.........: _GUICtrlListView_SetItemFocused($hWnd, $iIndex[, $fEnabled = True])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $fEnabled    - If True the item state is set, otherwise it is not set.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_GetItemFocused
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetItemFocused($hWnd, $iIndex, $fEnabled = True)
	Local $iState = 0

	If $fEnabled Then $iState = $LVIS_FOCUSED
	Return _GUICtrlListView_SetItemState($hWnd, $iIndex, $iState, $LVIS_FOCUSED)
EndFunc   ;==>_GUICtrlListView_SetItemFocused

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetItemGroupID
; Description ...: Sets the item group ID
; Syntax.........: _GUICtrlListView_SetItemGroupID($hWnd, $iIndex, $iGroupID)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $iGroupID    - Group ID
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Yoan Roblet (Arcker), Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: Minimum operating systems Windows XP.
; Related .......: _GUICtrlListView_GetItemGroupID, _GUICtrlListView_InsertGroup
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetItemGroupID($hWnd, $iIndex, $iGroupID)
	Local $tItem = DllStructCreate($tagLVITEM)
	DllStructSetData($tItem, "Mask", $LVIF_GROUPID)
	DllStructSetData($tItem, "Item", $iIndex)
	DllStructSetData($tItem, "GroupID", $iGroupID)
	_GUICtrlListView_SetItemEx($hWnd, $tItem)
EndFunc   ;==>_GUICtrlListView_SetItemGroupID

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetItemImage
; Description ...: Sets the index of the item's icon in the control's image list
; Syntax.........: _GUICtrlListView_SetItemImage($hWnd, $iIndex, $iImage[, $iSubItem = 0])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $iImage      - Zero based index into the control's image list
;                  $iSubItem    - One based index of the subitem
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_GetItemImage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetItemImage($hWnd, $iIndex, $iImage, $iSubItem = 0)
	Local $tItem = DllStructCreate($tagLVITEM)
	DllStructSetData($tItem, "Mask", $LVIF_IMAGE)
	DllStructSetData($tItem, "Item", $iIndex)
	DllStructSetData($tItem, "SubItem", $iSubItem)
	DllStructSetData($tItem, "Image", $iImage)
	Return _GUICtrlListView_SetItemEx($hWnd, $tItem)
EndFunc   ;==>_GUICtrlListView_SetItemImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetItemIndent
; Description ...: Sets the number of image widths to indent the item
; Syntax.........: _GUICtrlListView_SetItemIndent($hWnd, $iIndex, $iIndent)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $iIndent     - Indention value
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_GetItemIndent
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetItemIndent($hWnd, $iIndex, $iIndent)
	Local $tItem = DllStructCreate($tagLVITEM)
	DllStructSetData($tItem, "Mask", $LVIF_INDENT)
	DllStructSetData($tItem, "Item", $iIndex)
	DllStructSetData($tItem, "Indent", $iIndent)
	Return _GUICtrlListView_SetItemEx($hWnd, $tItem)
EndFunc   ;==>_GUICtrlListView_SetItemIndent

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlListView_SetItemOverlayImage
; Description ...: Sets the overlay image is superimposed over the item's icon image
; Syntax.........: __GUICtrlListView_SetItemOverlayImage($hWnd, $iIndex, $iImage)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $iImage      - One based overlay image index
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function is used internally and should not normally be called
; Related .......: __GUICtrlListView_GetItemOverlayImage
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GUICtrlListView_SetItemOverlayImage($hWnd, $iIndex, $iImage)
	Return _GUICtrlListView_SetItemState($hWnd, $iIndex, __GUICtrlListView_IndexToOverlayImageMask($iImage), $LVIS_OVERLAYMASK)
EndFunc   ;==>__GUICtrlListView_SetItemOverlayImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetItemParam
; Description ...: Sets the value specific to the item
; Syntax.........: _GUICtrlListView_SetItemParam($hWnd, $iIndex, $iParam)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $iParam      - A value to associate with the item
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_GetItemParam
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetItemParam($hWnd, $iIndex, $iParam)
	Local $tItem = DllStructCreate($tagLVITEM)
	DllStructSetData($tItem, "Mask", $LVIF_PARAM)
	DllStructSetData($tItem, "Item", $iIndex)
	DllStructSetData($tItem, "Param", $iParam)
	Return _GUICtrlListView_SetItemEx($hWnd, $tItem)
EndFunc   ;==>_GUICtrlListView_SetItemParam

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetItemPosition
; Description ...: Moves an item to a specified position in the control
; Syntax.........: _GUICtrlListView_SetItemPosition($hWnd, $iIndex, $iCX, $iCY)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $iCX         - New x-position of the item's upper-left corner, in view coordinates
;                  $iCY         - New y-position of the item's upper-left corner, in view coordinates
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: If the control has the $LVS_AUTOARRANGE style, the items in the control are arranged after the position of the
;                  item is set. The control must be in icon or small icon view mode.
; Related .......: _GUICtrlListView_GetItemPosition, _GUICtrlListView_Arrange, _GUICtrlListView_SetItemPosition32
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetItemPosition($hWnd, $iIndex, $iCX, $iCY)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_SETITEMPOSITION, $iIndex, _WinAPI_MakeLong($iCX, $iCY)) <> 0
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_SETITEMPOSITION, $iIndex, _WinAPI_MakeLong($iCX, $iCY)) <> 0
	EndIf
EndFunc   ;==>_GUICtrlListView_SetItemPosition

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetItemPosition32
; Description ...: Moves an item to a specified position in the control
; Syntax.........: _GUICtrlListView_SetItemPosition32($hWnd, $iIndex, $iCX, $iCY)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $iCX         - New x-position of the item's upper-left corner, in view coordinates
;                  $iCY         - New y-position of the item's upper-left corner, in view coordinates
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: If the control has the $LVS_AUTOARRANGE style, the items in the control are arranged after the position of the
;                  item is set. The control must be in icon or small icon view mode.
;+
;                  This message differs from the _GUICtrlListView_SetItemPosition function in that it uses 32-bit coordinates.
; Related .......: _GUICtrlListView_SetItemPosition
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetItemPosition32($hWnd, $iIndex, $iCX, $iCY)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $tPoint = DllStructCreate($tagPOINT)
	DllStructSetData($tPoint, "X", $iCX)
	DllStructSetData($tPoint, "Y", $iCY)
	Local $iRet
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			$iRet = _SendMessage($hWnd, $LVM_SETITEMPOSITION32, $iIndex, $tPoint, 0, "wparam", "struct*")
		Else
			Local $iPoint = DllStructGetSize($tPoint)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iPoint, $tMemMap)
			_MemWrite($tMemMap, $tPoint)
			$iRet = _SendMessage($hWnd, $LVM_SETITEMPOSITION32, $iIndex, $pMemory, 0, "wparam", "ptr")
			_MemFree($tMemMap)
		EndIf
	Else
		$iRet = GUICtrlSendMsg($hWnd, $LVM_SETITEMPOSITION32, $iIndex, DllStructGetPtr($tPoint))
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlListView_SetItemPosition32

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetItemSelected
; Description ...: Sets whether the item is selected
; Syntax.........: _GUICtrlListView_SetItemSelected($hWnd, $iIndex[, $fSelected = True[, $fFocused = False]])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item, -1 to set selected state of all items
;                  $fSelected   - If True the item(s) are selected, otherwise not.
;                  $fFocused    - If True the item has focus, otherwise not.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_GetItemSelected
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetItemSelected($hWnd, $iIndex, $fSelected = True, $fFocused = False)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $tStruct = DllStructCreate($tagLVITEM)
	Local $iRet, $iSelected = 0, $iFocused = 0, $iSize, $tMemMap, $pMemory
	If ($fSelected = True) Then $iSelected = $LVIS_SELECTED
	If ($fFocused = True And $iIndex <> -1) Then $iFocused = $LVIS_FOCUSED
	DllStructSetData($tStruct, "Mask", $LVIF_STATE)
	DllStructSetData($tStruct, "Item", $iIndex)
	DllStructSetData($tStruct, "State", BitOR($iSelected, $iFocused))
	DllStructSetData($tStruct, "StateMask", BitOR($LVIS_SELECTED, $iFocused))
	$iSize = DllStructGetSize($tStruct)
	If IsHWnd($hWnd) Then
		$pMemory = _MemInit($hWnd, $iSize, $tMemMap)
		_MemWrite($tMemMap, $tStruct, $pMemory, $iSize)
		$iRet = _SendMessage($hWnd, $LVM_SETITEMSTATE, $iIndex, $pMemory)
		_MemFree($tMemMap)
	Else
		$iRet = GUICtrlSendMsg($hWnd, $LVM_SETITEMSTATE, $iIndex, DllStructGetPtr($tStruct))
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlListView_SetItemSelected

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetItemState
; Description ...: Changes the state of an item in the control
; Syntax.........: _GUICtrlListView_SetItemState($hWnd, $iIndex, $iState, $iStateMask)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $iState      - Item state to be changed
;                  $iStateMask  - Bits that determine whether state is active or inactive
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_GetItemState
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetItemState($hWnd, $iIndex, $iState, $iStateMask)
	Local $tItem = DllStructCreate($tagLVITEM)
	DllStructSetData($tItem, "Mask", $LVIF_STATE)
	DllStructSetData($tItem, "Item", $iIndex)
	DllStructSetData($tItem, "State", $iState)
	DllStructSetData($tItem, "StateMask", $iStateMask)
	Return _GUICtrlListView_SetItemEx($hWnd, $tItem) <> 0
EndFunc   ;==>_GUICtrlListView_SetItemState

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetItemStateImage
; Description ...: Sets the state image that is displayed
; Syntax.........: _GUICtrlListView_SetItemStateImage($hWnd, $iIndex, $iImage)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $iImage      - One based overlay image index
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_GetItemStateImage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetItemStateImage($hWnd, $iIndex, $iImage)
	Return _GUICtrlListView_SetItemState($hWnd, $iIndex, BitShift($iImage, -12), $LVIS_STATEIMAGEMASK)
EndFunc   ;==>_GUICtrlListView_SetItemStateImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetItemText
; Description ...: Changes the text of an item or subitem
; Syntax.........: _GUICtrlListView_SetItemText($hWnd, $iIndex, $sText[, $iSubItem = 0])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the item
;                  $sText       - Item or subitem text
;                  $iSubItem    - One based index of the subitem or 0 to set the item
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost), added code by Ultima to set row text
; Remarks .......: If $iSubItem = -1 row is set
; Related .......: _GUICtrlListView_GetItemText, _GUICtrlListView_GetItemTextArray, _GUICtrlListView_GetItemTextString, _GUICtrlListView_InsertItem
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetItemText($hWnd, $iIndex, $sText, $iSubItem = 0)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $fUnicode = _GUICtrlListView_GetUnicodeFormat($hWnd)

	Local $iRet

	If $iSubItem = -1 Then
		Local $SeparatorChar = Opt('GUIDataSeparatorChar')
		Local $i_cols = _GUICtrlListView_GetColumnCount($hWnd)
		Local $a_text = StringSplit($sText, $SeparatorChar)
		If $i_cols > $a_text[0] Then $i_cols = $a_text[0]
		For $i = 1 To $i_cols
			$iRet = _GUICtrlListView_SetItemText($hWnd, $iIndex, $a_text[$i], $i - 1)
			If Not $iRet Then ExitLoop
		Next
		Return $iRet
	EndIf

	Local $iBuffer = StringLen($sText) + 1
	Local $tBuffer
	If $fUnicode Then
		$tBuffer = DllStructCreate("wchar Text[" & $iBuffer & "]")
		$iBuffer *= 2
	Else
		$tBuffer = DllStructCreate("char Text[" & $iBuffer & "]")
	EndIf
	Local $pBuffer = DllStructGetPtr($tBuffer)
	Local $tItem = DllStructCreate($tagLVITEM)
	DllStructSetData($tBuffer, "Text", $sText)
	DllStructSetData($tItem, "Mask", $LVIF_TEXT)
	DllStructSetData($tItem, "item", $iIndex)
	DllStructSetData($tItem, "SubItem", $iSubItem)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			DllStructSetData($tItem, "Text", $pBuffer)
			$iRet = _SendMessage($hWnd, $LVM_SETITEMW, 0, $tItem, 0, "wparam", "struct*")
		Else
			Local $iItem = DllStructGetSize($tItem)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iItem + $iBuffer, $tMemMap)
			Local $pText = $pMemory + $iItem
			DllStructSetData($tItem, "Text", $pText)
			_MemWrite($tMemMap, $tItem, $pMemory, $iItem)
			_MemWrite($tMemMap, $tBuffer, $pText, $iBuffer)
			If $fUnicode Then
				$iRet = _SendMessage($hWnd, $LVM_SETITEMW, 0, $pMemory, 0, "wparam", "ptr")
			Else
				$iRet = _SendMessage($hWnd, $LVM_SETITEMA, 0, $pMemory, 0, "wparam", "ptr")
			EndIf
			_MemFree($tMemMap)
		EndIf
	Else
		Local $pItem = DllStructGetPtr($tItem)
		DllStructSetData($tItem, "Text", $pBuffer)
		If $fUnicode Then
			$iRet = GUICtrlSendMsg($hWnd, $LVM_SETITEMW, 0, $pItem)
		Else
			$iRet = GUICtrlSendMsg($hWnd, $LVM_SETITEMA, 0, $pItem)
		EndIf
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlListView_SetItemText

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetOutlineColor
; Description ...: Sets the color of the border
; Syntax.........: _GUICtrlListView_SetOutlineColor($hWnd, $iColor)
; Parameters ....: $hWnd        - Handle to the control
;                  $iColor      - Color to set the border
; Return values .: Success      - Previous outline color
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Minimum operating systems Windows XP.
;+
;                  Control must have the $LVS_EX_BORDERSELECT extended window style set
; Related .......: _GUICtrlListView_GetOutlineColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetOutlineColor($hWnd, $iColor)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_SETOUTLINECOLOR, 0, $iColor)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_SETOUTLINECOLOR, 0, $iColor)
	EndIf
EndFunc   ;==>_GUICtrlListView_SetOutlineColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetSelectedColumn
; Description ...: Sets the index of the selected column
; Syntax.........: _GUICtrlListView_SetSelectedColumn($hWnd, $iCol)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCol        - Specifies the column index
; Return values .: None
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Columns are Zero based index
; Related .......: _GUICtrlListView_GetSelectedColumn
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetSelectedColumn($hWnd, $iCol)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		_SendMessage($hWnd, $LVM_SETSELECTEDCOLUMN, $iCol)
		_WinAPI_InvalidateRect($hWnd)
	Else
		GUICtrlSendMsg($hWnd, $LVM_SETSELECTEDCOLUMN, $iCol, 0)
		_WinAPI_InvalidateRect(GUICtrlGetHandle($hWnd))
	EndIf
EndFunc   ;==>_GUICtrlListView_SetSelectedColumn

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetSelectionMark
; Description ...: Sets the selection mark in the control
; Syntax.........: _GUICtrlListView_SetSelectionMark($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the new selection mark. If -1,the selection mark is removed.
; Return values .: Success      - The previous selection mark
;                  Failure      - -1 if there is no previous selection mark
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: The selection mark is the item index from which a multiple selection starts.  This message does not affect the
;                  selection state of the item.
; Related .......: _GUICtrlListView_GetSelectionMark
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetSelectionMark($hWnd, $iIndex)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_SETSELECTIONMARK, 0, $iIndex)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_SETSELECTIONMARK, 0, $iIndex)
	EndIf
EndFunc   ;==>_GUICtrlListView_SetSelectionMark

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetTextBkColor
; Description ...: Sets the background color of text in the control
; Syntax.........: _GUICtrlListView_SetTextBkColor($hWnd, $iColor)
; Parameters ....: $hWnd        - Handle to the control
;                  $iColor      - Text color
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_GetTextBkColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetTextBkColor($hWnd, $iColor)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_SETTEXTBKCOLOR, 0, $iColor) <> 0
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_SETTEXTBKCOLOR, 0, $iColor) <> 0
	EndIf
EndFunc   ;==>_GUICtrlListView_SetTextBkColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetTextColor
; Description ...: Sets the color of text in the control
; Syntax.........: _GUICtrlListView_SetTextColor($hWnd, $iColor)
; Parameters ....: $hWnd        - Handle to the control
;                  $iColor      - Text color
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_GetTextColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetTextColor($hWnd, $iColor)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $iRet
	If IsHWnd($hWnd) Then
		$iRet = _SendMessage($hWnd, $LVM_SETTEXTCOLOR, 0, $iColor)
		_WinAPI_InvalidateRect($hWnd)
	Else
		$iRet = GUICtrlSendMsg($hWnd, $LVM_SETTEXTCOLOR, 0, $iColor)
		_WinAPI_InvalidateRect(GUICtrlGetHandle($hWnd))
	EndIf
	Return $iRet <> 0
EndFunc   ;==>_GUICtrlListView_SetTextColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetToolTips
; Description ...: Sets the ToolTip control that the control will use to display ToolTips
; Syntax.........: _GUICtrlListView_SetToolTips($hWnd, $hToolTip)
; Parameters ....: $hWnd        - Handle to the control
;                  $hToolTip    - Handle to the ToolTip control to be set
; Return values .: Success      - The handle to the previous ToolTip control
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_GetToolTips
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetToolTips($hWnd, $hToolTip)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_SETTOOLTIPS, 0, $hToolTip, 0, "wparam", "hwnd", "hwnd")
	Else
		Return HWnd(GUICtrlSendMsg($hWnd, $LVM_SETTOOLTIPS, 0, $hToolTip))
	EndIf
EndFunc   ;==>_GUICtrlListView_SetToolTips

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetUnicodeFormat
; Description ...: Sets the UNICODE character format flag for the control
; Syntax.........: _GUICtrlListView_SetUnicodeFormat($hWnd, $fUnicode)
; Parameters ....: $hWnd        - Handle to the control
;                  $fUnicode    - Determines the character set that is used by the control. If True, the control will use Unicode
;                  +characters.  If this value is zero, the control will use ANSI characters.
; Return values .: Success      - The previous Unicode format flag for the control
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_GetUnicodeFormat
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetUnicodeFormat($hWnd, $fUnicode)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_SETUNICODEFORMAT, $fUnicode)
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_SETUNICODEFORMAT, $fUnicode, 0)
	EndIf
EndFunc   ;==>_GUICtrlListView_SetUnicodeFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetView
; Description ...: Sets the view of the control
; Syntax.........: _GUICtrlListView_SetView($hWnd, $iView)
; Parameters ....: $hWnd        - Handle to the control
;                  $iView       - View state for the control:
;                  |0 - Details
;                  |1 - Large Icon
;                  |2 - List
;                  |3 - Small Icon
;                  |4 - Tile
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......: Minimum operating systems Windows XP.
; Related .......: _GUICtrlListView_GetView
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetView($hWnd, $iView)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $aView[5] = [$LV_VIEW_DETAILS, $LV_VIEW_ICON, $LV_VIEW_LIST, $LV_VIEW_SMALLICON, $LV_VIEW_TILE]

	If IsHWnd($hWnd) Then
		Return _SendMessage($hWnd, $LVM_SETVIEW, $aView[$iView]) <> -1
	Else
		Return GUICtrlSendMsg($hWnd, $LVM_SETVIEW, $aView[$iView], 0) <> -1
	EndIf
EndFunc   ;==>_GUICtrlListView_SetView

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SetWorkAreas
; Description ...: Creates a work area within the control
; Syntax.........: _GUICtrlListView_SetWorkAreas($hWnd, $iLeft, $iTop, $iRight, $iBottom)
; Parameters ....: $hWnd        - Handle to the control
;                  $iLeft       - X coordinate of the upper left corner of the rectangle
;                  $iTop        - Y coordinate of the upper left corner of the rectangle
;                  $iRight      - X coordinate of the lower right corner of the rectangle
;                  $iBottom     - Y coordinate of the lower right corner of the rectangle
; Return values .: None
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_GetNumberOfWorkAreas
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SetWorkAreas($hWnd, $iLeft, $iTop, $iRight, $iBottom)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $tRect = DllStructCreate($tagRECT)
	DllStructSetData($tRect, "Left", $iLeft)
	DllStructSetData($tRect, "Top", $iTop)
	DllStructSetData($tRect, "Right", $iRight)
	DllStructSetData($tRect, "Bottom", $iBottom)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			_SendMessage($hWnd, $LVM_SETWORKAREAS, 1, $tRect, 0, "wparam", "struct*")
		Else
			Local $iRect = DllStructGetSize($tRect)
			Local $tMemMap
			Local $pMemory = _MemInit($hWnd, $iRect, $tMemMap)
			_MemWrite($tMemMap, $tRect, $pMemory, $iRect)
			_SendMessage($hWnd, $LVM_SETWORKAREAS, 1, $pMemory, 0, "wparam", "ptr")
			_MemFree($tMemMap)
		EndIf
	Else
		GUICtrlSendMsg($hWnd, $LVM_SETWORKAREAS, 1, DllStructGetPtr($tRect))
	EndIf
EndFunc   ;==>_GUICtrlListView_SetWorkAreas

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SimpleSort
; Description ...: Sorts a list-view control (limited)
; Syntax.........: _GUICtrlListView_SimpleSort($hWnd, ByRef $vDescending, $iCol)
; Parameters ....: $hWnd        - Handle to the control
;                  $vDescending - Can be:
;                  | True       - Sort Descending
;                  | False      - Sort Ascending
;                  +Array       - With the following format:
;                  |[0]         - First Column
;                  |[1]         - Second Column
;                  |[n]         - Last Column
;                  $iCol        - Column number
; Return values .: None
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: This is a basic sort fuction, for advanced sort see GUICtrlRegisterListViewSort
; Related .......: GUICtrlRegisterListViewSort
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SimpleSort($hWnd, ByRef $vDescending, $iCol)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If _GUICtrlListView_GetItemCount($hWnd) Then
		Local $b_desc
		If (IsArray($vDescending)) Then
			$b_desc = $vDescending[$iCol]
		Else
			$b_desc = $vDescending
		EndIf
		Local $columns = _GUICtrlListView_GetColumnCount($hWnd)
		Local $items = _GUICtrlListView_GetItemCount($hWnd)
		Local $temp_item = ""
		Local $SeparatorChar = Opt('GUIDataSeparatorChar')
		For $x = 1 To $columns
			$temp_item = $temp_item & " " & $SeparatorChar
		Next
		$temp_item = StringTrimRight($temp_item, 1)
		Local $a_lv[$items][$columns + 1]
		Local $i_selected = StringSplit(_GUICtrlListView_GetSelectedIndices($hWnd), $SeparatorChar)
		Local $i_checked = StringSplit(__GUICtrlListView_GetCheckedIndices($hWnd), $SeparatorChar)
		Local $v_item, $iFocused = -1
		For $x = 0 To UBound($a_lv) - 1 Step 1
			If $iFocused = -1 Then
				If _GUICtrlListView_GetItemFocused($hWnd, $x) Then $iFocused = $x
			EndIf
			_GUICtrlListView_SetItemSelected($hWnd, $x, False)
			_GUICtrlListView_SetItemChecked($hWnd, $x, False)
			For $Y = 0 To UBound($a_lv, 2) - 2 Step 1
				$v_item = StringStripWS(_GUICtrlListView_GetItemText($hWnd, $x, $Y), 2)
				If (StringIsFloat($v_item) Or StringIsInt($v_item)) Then
					$a_lv[$x][$Y] = Number($v_item)
				Else
					$a_lv[$x][$Y] = $v_item
				EndIf
			Next
			$a_lv[$x][$Y] = $x
		Next
		_ArraySort($a_lv, $b_desc, 0, 0, $iCol)
		For $x = 0 To UBound($a_lv) - 1 Step 1
			For $Y = 0 To UBound($a_lv, 2) - 2 Step 1
				_GUICtrlListView_SetItemText($hWnd, $x, $a_lv[$x][$Y], $Y)
			Next
			For $Z = 1 To $i_selected[0]
				If $a_lv[$x][UBound($a_lv, 2) - 1] = $i_selected[$Z] Then
					If $a_lv[$x][UBound($a_lv, 2) - 1] = $iFocused Then
						_GUICtrlListView_SetItemSelected($hWnd, $x, True, True)
					Else
						_GUICtrlListView_SetItemSelected($hWnd, $x, True)
					EndIf
					ExitLoop
				EndIf
			Next
			For $Z = 1 To $i_checked[0]
				If $a_lv[$x][UBound($a_lv, 2) - 1] = $i_checked[$Z] Then
					_GUICtrlListView_SetItemChecked($hWnd, $x, True)
					ExitLoop
				EndIf
			Next
		Next
		If (IsArray($vDescending)) Then
			$vDescending[$iCol] = Not $b_desc
		Else
			$vDescending = Not $b_desc
		EndIf
	EndIf
EndFunc   ;==>_GUICtrlListView_SimpleSort

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlListView_Sort
; Description ...: Our sorting callback function
; Syntax.........: __GUICtrlListView_Sort($nItem1, $nItem2, $hWnd)
; Parameters ....: $nItem1      - Param of 1st item
;                  $nItem2      - Param of 2nd item
;                  $hWnd        - Handle of the control
; Return values .: None
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: For Internal Use Only
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GUICtrlListView_Sort($nItem1, $nItem2, $hWnd)
	Local $iIndex, $tInfo, $val1, $val2, $nResult
	$tInfo = DllStructCreate($tagLVFINDINFO)
	DllStructSetData($tInfo, "Flags", $LVFI_PARAM)

	For $x = 1 To $aListViewSortInfo[0][0]
		If $hWnd = $aListViewSortInfo[$x][1] Then
			$iIndex = $x
			ExitLoop
		EndIf
	Next

	; Switch the sorting direction
	If $aListViewSortInfo[$iIndex][3] = $aListViewSortInfo[$iIndex][4] Then ; $nColumn = nCurCol ?
		If Not $aListViewSortInfo[$iIndex][7] Then ; $bSet
			$aListViewSortInfo[$iIndex][5] *= -1 ; $nSortDir
			$aListViewSortInfo[$iIndex][7] = 1 ; $bSet
		EndIf
	Else
		$aListViewSortInfo[$iIndex][7] = 1 ; $bSet
	EndIf
	$aListViewSortInfo[$iIndex][6] = $aListViewSortInfo[$iIndex][3] ; $nCol = $nColumn
	DllStructSetData($tInfo, "Param", $nItem1)
	$val1 = _GUICtrlListView_FindItem($hWnd, -1, $tInfo)
	DllStructSetData($tInfo, "Param", $nItem2)
	$val2 = _GUICtrlListView_FindItem($hWnd, -1, $tInfo)
	$val1 = _GUICtrlListView_GetItemText($hWnd, $val1, $aListViewSortInfo[$iIndex][3])
	$val2 = _GUICtrlListView_GetItemText($hWnd, $val2, $aListViewSortInfo[$iIndex][3])
	If $aListViewSortInfo[$iIndex][8] Then ; Treat As Number
		If (StringIsFloat($val1) Or StringIsInt($val1)) Then $val1 = Number($val1)
		If (StringIsFloat($val2) Or StringIsInt($val2)) Then $val2 = Number($val2)
	EndIf

	$nResult = 0 ; No change of item1 and item2 positions

	If $val1 < $val2 Then
		$nResult = -1 ; Put item2 before item1
	ElseIf $val1 > $val2 Then
		$nResult = 1 ; Put item2 behind item1
	EndIf

	$nResult = $nResult * $aListViewSortInfo[$iIndex][5] ; $nSortDir

	Return $nResult
EndFunc   ;==>__GUICtrlListView_Sort

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SortItems
; Description ...: Starts the sort call back, also sets the Arrow in the Header
; Syntax.........: _GUICtrlListView_SortItems($hWnd, $iCol)
; Parameters ....: $hWnd        - Handle of the control
;                  $iCol        - Column clicked
; Return values .: None
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: For use only in conjunction with _GUICtrlListView_RegisterSortCallBack
;+
;                  A down-arrow/up-arrow is drawn on column selected for Windows XP and above if the option was set
;                  when calling _GUICtrlListView_RegisterSortCallBack
; Related .......: _GUICtrlListView_RegisterSortCallBack
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SortItems($hWnd, $iCol)
	Local $iRet, $iIndex, $pFunction, $hHeader, $iFormat

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	For $x = 1 To $aListViewSortInfo[0][0]
		If $hWnd = $aListViewSortInfo[$x][1] Then
			$iIndex = $x
			ExitLoop
		EndIf
	Next

	$pFunction = DllCallbackGetPtr($aListViewSortInfo[$iIndex][2]) ; get pointer to call back
	$aListViewSortInfo[$iIndex][3] = $iCol ; $nColumn = column clicked
	$aListViewSortInfo[$iIndex][7] = 0 ; $bSet
	$aListViewSortInfo[$iIndex][4] = $aListViewSortInfo[$iIndex][6] ; nCurCol = $nCol
	$iRet = _SendMessage($hWnd, $LVM_SORTITEMS, $hWnd, $pFunction, 0, "hwnd", "ptr")
	If $iRet <> 0 Then
		If $aListViewSortInfo[$iIndex][9] Then ; Use arrow in header
			$hHeader = $aListViewSortInfo[$iIndex][10]
			For $x = 0 To _GUICtrlHeader_GetItemCount($hHeader) - 1
				$iFormat = _GUICtrlHeader_GetItemFormat($hHeader, $x)
				If BitAND($iFormat, $HDF_SORTDOWN) Then
					_GUICtrlHeader_SetItemFormat($hHeader, $x, BitXOR($iFormat, $HDF_SORTDOWN))
				ElseIf BitAND($iFormat, $HDF_SORTUP) Then
					_GUICtrlHeader_SetItemFormat($hHeader, $x, BitXOR($iFormat, $HDF_SORTUP))
				EndIf
			Next
			$iFormat = _GUICtrlHeader_GetItemFormat($hHeader, $iCol)
			If $aListViewSortInfo[$iIndex][5] = 1 Then ; ascending
				_GUICtrlHeader_SetItemFormat($hHeader, $iCol, BitOR($iFormat, $HDF_SORTUP))
			Else ; descending
				_GUICtrlHeader_SetItemFormat($hHeader, $iCol, BitOR($iFormat, $HDF_SORTDOWN))
			EndIf
		EndIf
	EndIf

	Return $iRet <> 0
EndFunc   ;==>_GUICtrlListView_SortItems

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GUICtrlListView_StateImageMaskToIndex
; Description ...: Converts a state image mask to an image index
; Syntax.........: __GUICtrlListView_StateImageMaskToIndex($iMask)
; Parameters ....: $iMask       - State image mask
; Return values .: Success      - One base state image index
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function is used internally and should not normally be called
; Related .......: __GUICtrlListView_IndexToStateImageMask
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __GUICtrlListView_StateImageMaskToIndex($iMask)
	Return BitShift(BitAND($iMask, $LVIS_STATEIMAGEMASK), 12)
EndFunc   ;==>__GUICtrlListView_StateImageMaskToIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_SubItemHitTest
; Description ...: Determines which listview item or subitem is at a given position
; Syntax.........: _GUICtrlListView_SubItemHitTest($hWnd[, $iX = -1[, $iY = -1]])
; Parameters ....: $hWnd        - Handle to the control
;                  $iX          - X position to test or -1 to use the current mouse position
;                  $iY          - Y position to test or -1 to use the current mouse position
; Return values .: Success      - Array with the following format:
;                  |[ 0] - Zero based index of the item at the specified position, or -1
;                  |[ 1] - Zero based index of the subitem at the specified position, or -1
;                  |[ 2] - If True, position is in control's client window but not on an item
;                  |[ 3] - If True, position is over item icon
;                  |[ 4] - If True, position is over item text
;                  |[ 5] - If True, position is over item state image
;                  |[ 6] - If True, position is somewhere on the item
;                  |[ 7] - If True, the position is above the control's client area
;                  |[ 8] - If True, the position is below the control's client area
;                  |[ 9] - If True, the position is to the left of the client area
;                  |[10] - If True, the position is to the right of the client area
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; Remarks .......:
; Related .......: _GUICtrlListView_HitTest
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_SubItemHitTest($hWnd, $iX = -1, $iY = -1)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	Local $iTest, $tTest, $pMemory, $tMemMap, $iFlags, $aTest[11]

	If $iX = -1 Then $iX = _WinAPI_GetMousePosX(True, $hWnd)
	If $iY = -1 Then $iY = _WinAPI_GetMousePosY(True, $hWnd)
	$tTest = DllStructCreate($tagLVHITTESTINFO)
	DllStructSetData($tTest, "X", $iX)
	DllStructSetData($tTest, "Y", $iY)
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $_lv_ghLastWnd) Then
			_SendMessage($hWnd, $LVM_SUBITEMHITTEST, 0, $tTest, 0, "wparam", "struct*")
		Else
			$iTest = DllStructGetSize($tTest)
			$pMemory = _MemInit($hWnd, $iTest, $tMemMap)
			_MemWrite($tMemMap, $tTest)
			_SendMessage($hWnd, $LVM_SUBITEMHITTEST, 0, $pMemory, 0, "wparam", "ptr")
			_MemRead($tMemMap, $pMemory, $tTest, $iTest)
			_MemFree($tMemMap)
		EndIf
	Else
		GUICtrlSendMsg($hWnd, $LVM_SUBITEMHITTEST, 0, DllStructGetPtr($tTest))
	EndIf
	$iFlags = DllStructGetData($tTest, "Flags")
	$aTest[0] = DllStructGetData($tTest, "Item")
	$aTest[1] = DllStructGetData($tTest, "SubItem")
	$aTest[2] = BitAND($iFlags, $LVHT_NOWHERE) <> 0
	$aTest[3] = BitAND($iFlags, $LVHT_ONITEMICON) <> 0
	$aTest[4] = BitAND($iFlags, $LVHT_ONITEMLABEL) <> 0
	$aTest[5] = BitAND($iFlags, $LVHT_ONITEMSTATEICON) <> 0
	$aTest[6] = BitAND($iFlags, $LVHT_ONITEM) <> 0
	$aTest[7] = BitAND($iFlags, $LVHT_ABOVE) <> 0
	$aTest[8] = BitAND($iFlags, $LVHT_BELOW) <> 0
	$aTest[9] = BitAND($iFlags, $LVHT_TOLEFT) <> 0
	$aTest[10] = BitAND($iFlags, $LVHT_TORIGHT) <> 0
	Return $aTest
EndFunc   ;==>_GUICtrlListView_SubItemHitTest

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlListView_UnRegisterSortCallBack
; Description ...: UnRegister the Sort callback function
; Syntax.........: _GUICtrlListView_UnRegisterSortCallBack($hWnd)
; Parameters ....: $hWnd        - Handle of the control
; Return values .: None
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUICtrlListView_RegisterSortCallBack
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUICtrlListView_UnRegisterSortCallBack($hWnd)
	If $Debug_LV Then __UDF_ValidateClassName($hWnd, $__LISTVIEWCONSTANT_ClassName)

	If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)

	For $x = 1 To $aListViewSortInfo[0][0]
		If $hWnd = $aListViewSortInfo[$x][1] Then
			DllCallbackFree($aListViewSortInfo[$x][2])
			__GUICtrlListView_ArrayDelete($aListViewSortInfo, $x)
			$aListViewSortInfo[0][0] -= 1
			ExitLoop
		EndIf
	Next
EndFunc   ;==>_GUICtrlListView_UnRegisterSortCallBack
