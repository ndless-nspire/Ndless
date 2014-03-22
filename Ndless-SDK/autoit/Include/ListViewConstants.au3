#include-once

; #INDEX# =======================================================================================================================
; Title .........: ListView_Constants
; AutoIt Version : 3.2
; Language ......: English
; Description ...: <a href="../appendix/GUIStyles.htm#ListView">GUI control ListView styles</a> and much more constants.
; Author(s) .....: Valik, Gary Frost, ...
; ===============================================================================================================================

; #STYLES# ======================================================================================================================
Global Const $LVS_ALIGNLEFT = 0x0800 ; Items are left aligned in icon and small icon view
Global Const $LVS_ALIGNMASK = 0x0c00 ; Determines the control's current alignment
Global Const $LVS_ALIGNTOP = 0x0000 ; Items are aligned at the top in icon and small icon view
Global Const $LVS_AUTOARRANGE = 0x0100 ; Icons are automatically kept arranged in icon and small icon view
Global Const $LVS_DEFAULT = 0x0000000D ; Default control style  $LVS_SHOWSELALWAYS + $LVS_SINGLESEL + $LVS_REPORT
Global Const $LVS_EDITLABELS = 0x0200 ; Item text can be edited in place
Global Const $LVS_ICON = 0x0000 ; This style specifies icon view
Global Const $LVS_LIST = 0x0003 ; This style specifies list view
Global Const $LVS_NOCOLUMNHEADER = 0x4000 ; Column headers are not displayed in report view
Global Const $LVS_NOLABELWRAP = 0x0080 ; Item text is displayed on a single line in icon view
Global Const $LVS_NOSCROLL = 0x2000 ; Scrolling is disabled
Global Const $LVS_NOSORTHEADER = 0x8000 ; Column headers do not work like buttons
Global Const $LVS_OWNERDATA = 0x1000
Global Const $LVS_OWNERDRAWFIXED = 0x0400 ; The owner window can paint items in report view
Global Const $LVS_REPORT = 0x0001 ; This style specifies report view
Global Const $LVS_SHAREIMAGELISTS = 0x0040 ; The image list will not be deleted when the control is destroyed
Global Const $LVS_SHOWSELALWAYS = 0x0008 ; The selection is always shown
Global Const $LVS_SINGLESEL = 0x0004 ; Only one item at a time can be selected
Global Const $LVS_SMALLICON = 0x0002 ; This style specifies small icon view
Global Const $LVS_SORTASCENDING = 0x0010 ; Item indexes are sorted based on item text in ascending order
Global Const $LVS_SORTDESCENDING = 0x0020 ; Item indexes are sorted based on item text in descending order
Global Const $LVS_TYPEMASK = 0x0003 ; Determines the control's current window style
Global Const $LVS_TYPESTYLEMASK = 0xfc00 ; Determines the window styles

; listView Extended Styles
Global Const $LVS_EX_AUTOAUTOARRANGE = 0x01000000 ; Vista - Automatically arrange icons if no icon positions have been set (Similar to LVS_AUTOARRANGE).
Global Const $LVS_EX_AUTOCHECKSELECT = 0x08000000 ; Vista - Automatically select check boxes on single click
Global Const $LVS_EX_AUTOSIZECOLUMNS = 0x10000000 ; Vista - Automatically size listview columns
Global Const $LVS_EX_BORDERSELECT = 0x00008000 ; The border color of the item changes when selected
Global Const $LVS_EX_CHECKBOXES = 0x00000004 ; Enables check boxes for items
Global Const $LVS_EX_COLUMNOVERFLOW = 0x80000000 ; Indicates that an overflow button should be displayed in icon/tile view if there is not enough client width to display the complete set of header items
Global Const $LVS_EX_COLUMNSNAPPOINTS = 0x40000000 ; Vista - Snap to minimum column width when the user resizes a column
Global Const $LVS_EX_DOUBLEBUFFER = 0x00010000 ; Paints via double-buffering, which reduces flicker
Global Const $LVS_EX_FLATSB = 0x00000100 ; Enables flat scroll bars
Global Const $LVS_EX_FULLROWSELECT = 0x00000020 ; When an item is selected, the item and all its subitems are highlighted
Global Const $LVS_EX_GRIDLINES = 0x00000001 ; Displays gridlines around items and subitems
Global Const $LVS_EX_HEADERDRAGDROP = 0x00000010 ; Enables drag-and-drop reordering of columns
Global Const $LVS_EX_HEADERINALLVIEWS = 0x02000000 ; Vista - Show column headers in all view modes
Global Const $LVS_EX_HIDELABELS = 0x20000 ; Hides the labels in icon and small icon view
Global Const $LVS_EX_INFOTIP = 0x00000400 ; A message is sent to the parent before displaying an item's ToolTip
Global Const $LVS_EX_JUSTIFYCOLUMNS = 0x00200000 ; Vista - Icons are lined up in columns that use up the whole view
Global Const $LVS_EX_LABELTIP = 0x00004000 ; If a partially hidden label lacks ToolTip text, the label will unfold
Global Const $LVS_EX_MULTIWORKAREAS = 0x00002000 ; The control will not autoarrange its icons until a work area is defined
Global Const $LVS_EX_ONECLICKACTIVATE = 0x00000040 ; Sends an $LVN_ITEMACTIVATE message when the user clicks an item
Global Const $LVS_EX_REGIONAL = 0x00000200 ; Sets the region to include only the icons and text using SetWindowRgn
Global Const $LVS_EX_SIMPLESELECT = 0x00100000 ; Moves the state image to the top right of the large icon rendering#cs
Global Const $LVS_EX_SNAPTOGRID = 0x00080000 ; Icons automatically snap to grid
Global Const $LVS_EX_SUBITEMIMAGES = 0x00000002 ; Allows images to be displayed for subitems
Global Const $LVS_EX_TRACKSELECT = 0x00000008 ; Enables hot-track selection
Global Const $LVS_EX_TRANSPARENTBKGND = 0x00400000 ; Vista - Background is painted by the parent via WM_PRINTCLIENT
Global Const $LVS_EX_TRANSPARENTSHADOWTEXT = 0x00800000 ; Vista - Enable shadow text on transparent backgrounds only
Global Const $LVS_EX_TWOCLICKACTIVATE = 0x00000080 ; Sends an $LVN_ITEMACTIVATE message when the user double clicks an item
Global Const $LVS_EX_UNDERLINECOLD = 0x00001000 ; Causes non-hot items to be displayed with underlined text
Global Const $LVS_EX_UNDERLINEHOT = 0x00000800 ; Causes hot items to be displayed with underlined text
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; Group state - Vista
Global Const $LVGS_NORMAL = 0x00000000
Global Const $LVGS_COLLAPSED = 0x00000001
Global Const $LVGS_HIDDEN = 0x00000002
Global Const $LVGS_NOHEADER = 0x00000004
Global Const $LVGS_COLLAPSIBLE = 0x00000008
Global Const $LVGS_FOCUSED = 0x00000010
Global Const $LVGS_SELECTED = 0x00000020
Global Const $LVGS_SUBSETED = 0x00000040
Global Const $LVGS_SUBSETLINKFOCUSED = 0x00000080

; Group Rect - Vista
Global Const $LVGGR_GROUP = 0 ;// Entire expanded group
Global Const $LVGGR_HEADER = 1 ; // Header only (collapsed group)
Global Const $LVGGR_LABEL = 2 ; // Label only
Global Const $LVGGR_SUBSETLINK = 3 ; // subset link only

; error
Global Const $LV_ERR = -1

Global Const $LVBKIF_SOURCE_NONE = 0x00000000
Global Const $LVBKIF_SOURCE_HBITMAP = 0x00000001
Global Const $LVBKIF_SOURCE_URL = 0x00000002
Global Const $LVBKIF_SOURCE_MASK = 0x00000003
Global Const $LVBKIF_STYLE_NORMAL = 0x00000000
Global Const $LVBKIF_STYLE_TILE = 0x00000010
Global Const $LVBKIF_STYLE_MASK = 0x00000010
Global Const $LVBKIF_FLAG_TILEOFFSET = 0x00000100
Global Const $LVBKIF_TYPE_WATERMARK = 0x10000000

Global Const $LV_VIEW_DETAILS = 0x0001
Global Const $LV_VIEW_ICON = 0x0000
Global Const $LV_VIEW_LIST = 0x0003
Global Const $LV_VIEW_SMALLICON = 0x0002
Global Const $LV_VIEW_TILE = 0x0004

Global Const $LVA_ALIGNLEFT = 0x0001
Global Const $LVA_ALIGNTOP = 0x0002
Global Const $LVA_DEFAULT = 0x0000
Global Const $LVA_SNAPTOGRID = 0x0005

Global Const $LVCDI_ITEM = 0x00000000
Global Const $LVCDI_GROUP = 0x00000001

Global Const $LVCF_ALLDATA = 0X0000003F
Global Const $LVCF_FMT = 0x0001
Global Const $LVCF_IMAGE = 0x0010
Global Const $LVCFMT_JUSTIFYMASK = 0x0003
Global Const $LVCF_TEXT = 0x0004
Global Const $LVCF_WIDTH = 0x0002

Global Const $LVCFMT_BITMAP_ON_RIGHT = 0x1000
Global Const $LVCFMT_CENTER = 0x0002
Global Const $LVCFMT_COL_HAS_IMAGES = 0x8000
Global Const $LVCFMT_IMAGE = 0x0800
Global Const $LVCFMT_LEFT = 0x0000
Global Const $LVCFMT_RIGHT = 0x0001

Global Const $LVCFMT_LINE_BREAK = 0x100000
Global Const $LVCFMT_FILL = 0x200000
Global Const $LVCFMT_WRAP = 0x400000
Global Const $LVCFMT_NO_TITLE = 0x800000
Global Const $LVCFMT_TILE_PLACEMENTMASK = BitOR($LVCFMT_LINE_BREAK, $LVCFMT_FILL)

Global Const $LVFI_NEARESTXY = 0x0040
Global Const $LVFI_PARAM = 0x0001
Global Const $LVFI_PARTIAL = 0x0008
Global Const $LVFI_STRING = 0x0002
Global Const $LVFI_SUBSTRING = 0x0004
Global Const $LVFI_WRAP = 0x0020

Global Const $LVGA_FOOTER_LEFT = 0x00000008
Global Const $LVGA_FOOTER_CENTER = 0x00000010
Global Const $LVGA_FOOTER_RIGHT = 0x00000020
Global Const $LVGA_HEADER_LEFT = 0x00000001
Global Const $LVGA_HEADER_CENTER = 0x00000002
Global Const $LVGA_HEADER_RIGHT = 0x00000004

Global Const $LVGF_ALIGN = 0x00000008
Global Const $LVGF_DESCRIPTIONTOP = 0x00000400
Global Const $LVGF_DESCRIPTIONBOTTOM = 0x00000800
Global Const $LVGF_EXTENDEDIMAGE = 0x00002000
Global Const $LVGF_FOOTER = 0x00000002
Global Const $LVGF_GROUPID = 0x00000010
Global Const $LVGF_HEADER = 0x00000001
Global Const $LVGF_ITEMS = 0x00004000
Global Const $LVGF_NONE = 0x00000000
Global Const $LVGF_STATE = 0x00000004
Global Const $LVGF_SUBSET = 0x00008000
Global Const $LVGF_SUBSETITEMS = 0x00010000
Global Const $LVGF_SUBTITLE = 0x00000100
Global Const $LVGF_TASK = 0x00000200
Global Const $LVGF_TITLEIMAGE = 0x00001000

Global Const $LVHT_ABOVE = 0x00000008
Global Const $LVHT_BELOW = 0x00000010
Global Const $LVHT_NOWHERE = 0x00000001
Global Const $LVHT_ONITEMICON = 0x00000002
Global Const $LVHT_ONITEMLABEL = 0x00000004
Global Const $LVHT_ONITEMSTATEICON = 0x00000008
Global Const $LVHT_TOLEFT = 0x00000040
Global Const $LVHT_TORIGHT = 0x00000020
Global Const $LVHT_ONITEM = BitOR($LVHT_ONITEMICON, $LVHT_ONITEMLABEL, $LVHT_ONITEMSTATEICON)

Global Const $LVHT_EX_GROUP_HEADER = 0x10000000
Global Const $LVHT_EX_GROUP_FOOTER = 0x20000000
Global Const $LVHT_EX_GROUP_COLLAPSE = 0x40000000
Global Const $LVHT_EX_GROUP_BACKGROUND = 0x80000000
Global Const $LVHT_EX_GROUP_STATEICON = 0x01000000
Global Const $LVHT_EX_GROUP_SUBSETLINK = 0x02000000
Global Const $LVHT_EX_GROUP = BitOR($LVHT_EX_GROUP_BACKGROUND, $LVHT_EX_GROUP_COLLAPSE, $LVHT_EX_GROUP_FOOTER, $LVHT_EX_GROUP_HEADER, $LVHT_EX_GROUP_STATEICON, $LVHT_EX_GROUP_SUBSETLINK)
Global Const $LVHT_EX_ONCONTENTS = 0x04000000 ; On item AND not on the background
Global Const $LVHT_EX_FOOTER = 0x08000000

Global Const $LVIF_COLFMT = 0x00010000
Global Const $LVIF_COLUMNS = 0x00000200
Global Const $LVIF_GROUPID = 0x00000100
Global Const $LVIF_IMAGE = 0x00000002
Global Const $LVIF_INDENT = 0x00000010
Global Const $LVIF_NORECOMPUTE = 0x00000800
Global Const $LVIF_PARAM = 0x00000004
Global Const $LVIF_STATE = 0x00000008
Global Const $LVIF_TEXT = 0x00000001

Global Const $LVIM_AFTER = 0x00000001

Global Const $LVIR_BOUNDS = 0
Global Const $LVIR_ICON = 1
Global Const $LVIR_LABEL = 2
Global Const $LVIR_SELECTBOUNDS = 3

Global Const $LVIS_CUT = 0x0004
Global Const $LVIS_DROPHILITED = 0x0008
Global Const $LVIS_FOCUSED = 0x0001
Global Const $LVIS_OVERLAYMASK = 0x0F00
Global Const $LVIS_SELECTED = 0x0002
Global Const $LVIS_STATEIMAGEMASK = 0xF000
; ===============================================================================================================================

; #MESSAGES# ====================================================================================================================
Global Const $LVM_FIRST = 0x1000

Global Const $LVM_APPROXIMATEVIEWRECT = ($LVM_FIRST + 64)
Global Const $LVM_ARRANGE = ($LVM_FIRST + 22)
Global Const $LVM_CANCELEDITLABEL = ($LVM_FIRST + 179)
Global Const $LVM_CREATEDRAGIMAGE = ($LVM_FIRST + 33)
Global Const $LVM_DELETEALLITEMS = ($LVM_FIRST + 9)
Global Const $LVM_DELETECOLUMN = ($LVM_FIRST + 28)
Global Const $LVM_DELETEITEM = ($LVM_FIRST + 8)
Global Const $LVM_EDITLABELA = ($LVM_FIRST + 23)
Global Const $LVM_EDITLABELW = ($LVM_FIRST + 118)
Global Const $LVM_EDITLABEL = $LVM_EDITLABELA
Global Const $LVM_ENABLEGROUPVIEW = ($LVM_FIRST + 157)
Global Const $LVM_ENSUREVISIBLE = ($LVM_FIRST + 19)
Global Const $LVM_FINDITEM = ($LVM_FIRST + 13)
Global Const $LVM_GETBKCOLOR = ($LVM_FIRST + 0)
Global Const $LVM_GETBKIMAGEA = ($LVM_FIRST + 69)
Global Const $LVM_GETBKIMAGEW = ($LVM_FIRST + 139)
Global Const $LVM_GETCALLBACKMASK = ($LVM_FIRST + 10)
Global Const $LVM_GETCOLUMNA = ($LVM_FIRST + 25)
Global Const $LVM_GETCOLUMNW = ($LVM_FIRST + 95)
Global Const $LVM_GETCOLUMNORDERARRAY = ($LVM_FIRST + 59)
Global Const $LVM_GETCOLUMNWIDTH = ($LVM_FIRST + 29)
Global Const $LVM_GETCOUNTPERPAGE = ($LVM_FIRST + 40)
Global Const $LVM_GETEDITCONTROL = ($LVM_FIRST + 24)
Global Const $LVM_GETEMPTYTEXT = ($LVM_FIRST + 204)
Global Const $LVM_GETEXTENDEDLISTVIEWSTYLE = ($LVM_FIRST + 55)
Global Const $LVM_GETFOCUSEDGROUP = ($LVM_FIRST + 93)
Global Const $LVM_GETFOOTERINFO = ($LVM_FIRST + 206)
Global Const $LVM_GETFOOTERITEM = ($LVM_FIRST + 208)
Global Const $LVM_GETFOOTERITEMRECT = ($LVM_FIRST + 207)
Global Const $LVM_GETFOOTERRECT = ($LVM_FIRST + 205)
Global Const $LVM_GETGROUPCOUNT = ($LVM_FIRST + 152)
Global Const $LVM_GETGROUPINFO = ($LVM_FIRST + 149)
Global Const $LVM_GETGROUPINFOBYINDEX = ($LVM_FIRST + 153)
Global Const $LVM_GETGROUPMETRICS = ($LVM_FIRST + 156)
Global Const $LVM_GETGROUPRECT = ($LVM_FIRST + 98)
Global Const $LVM_GETGROUPSTATE = ($LVM_FIRST + 92)
Global Const $LVM_GETHEADER = ($LVM_FIRST + 31)
Global Const $LVM_GETHOTCURSOR = ($LVM_FIRST + 63)
Global Const $LVM_GETHOTITEM = ($LVM_FIRST + 61)
Global Const $LVM_GETHOVERTIME = ($LVM_FIRST + 72)
Global Const $LVM_GETIMAGELIST = ($LVM_FIRST + 2)
Global Const $LVM_GETINSERTMARK = ($LVM_FIRST + 167)
Global Const $LVM_GETINSERTMARKCOLOR = ($LVM_FIRST + 171)
Global Const $LVM_GETINSERTMARKRECT = ($LVM_FIRST + 169)
Global Const $LVM_GETISEARCHSTRINGA = ($LVM_FIRST + 52)
Global Const $LVM_GETISEARCHSTRINGW = ($LVM_FIRST + 117)
Global Const $LVM_GETITEMA = ($LVM_FIRST + 5)
Global Const $LVM_GETITEMW = ($LVM_FIRST + 75)
Global Const $LVM_GETITEMCOUNT = ($LVM_FIRST + 4)
Global Const $LVM_GETITEMINDEXRECT = ($LVM_FIRST + 209)
Global Const $LVM_GETITEMPOSITION = ($LVM_FIRST + 16)
Global Const $LVM_GETITEMRECT = ($LVM_FIRST + 14)
Global Const $LVM_GETITEMSPACING = ($LVM_FIRST + 51)
Global Const $LVM_GETITEMSTATE = ($LVM_FIRST + 44)
Global Const $LVM_GETITEMTEXTA = ($LVM_FIRST + 45)
Global Const $LVM_GETITEMTEXTW = ($LVM_FIRST + 115)
Global Const $LVM_GETNEXTITEM = ($LVM_FIRST + 12)
Global Const $LVM_GETNEXTITEMINDEX = ($LVM_FIRST + 211)
Global Const $LVM_GETNUMBEROFWORKAREAS = ($LVM_FIRST + 73)
Global Const $LVM_GETORIGIN = ($LVM_FIRST + 41)
Global Const $LVM_GETOUTLINECOLOR = ($LVM_FIRST + 176)
Global Const $LVM_GETSELECTEDCOLUMN = ($LVM_FIRST + 174)
Global Const $LVM_GETSELECTEDCOUNT = ($LVM_FIRST + 50)
Global Const $LVM_GETSELECTIONMARK = ($LVM_FIRST + 66)
Global Const $LVM_GETSTRINGWIDTHA = ($LVM_FIRST + 17)
Global Const $LVM_GETSTRINGWIDTHW = ($LVM_FIRST + 87)
Global Const $LVM_GETSUBITEMRECT = ($LVM_FIRST + 56)
Global Const $LVM_GETTEXTBKCOLOR = ($LVM_FIRST + 37)
Global Const $LVM_GETTEXTCOLOR = ($LVM_FIRST + 35)
Global Const $LVM_GETTILEINFO = ($LVM_FIRST + 165)
Global Const $LVM_GETTILEVIEWINFO = ($LVM_FIRST + 163)
Global Const $LVM_GETTOOLTIPS = ($LVM_FIRST + 78)
Global Const $LVM_GETTOPINDEX = ($LVM_FIRST + 39)
Global Const $LVM_GETUNICODEFORMAT = 0x2000 + 6
Global Const $LVM_GETVIEW = ($LVM_FIRST + 143)
Global Const $LVM_GETVIEWRECT = ($LVM_FIRST + 34)
Global Const $LVM_GETWORKAREAS = ($LVM_FIRST + 70)
Global Const $LVM_HASGROUP = ($LVM_FIRST + 161)
Global Const $LVM_HITTEST = ($LVM_FIRST + 18)
Global Const $LVM_INSERTCOLUMNA = ($LVM_FIRST + 27)
Global Const $LVM_INSERTCOLUMNW = ($LVM_FIRST + 97)
Global Const $LVM_INSERTGROUP = ($LVM_FIRST + 145)
Global Const $LVM_INSERTGROUPSORTED = ($LVM_FIRST + 159)
Global Const $LVM_INSERTITEMA = ($LVM_FIRST + 7)
Global Const $LVM_INSERTITEMW = ($LVM_FIRST + 77)
Global Const $LVM_INSERTMARKHITTEST = ($LVM_FIRST + 168)
Global Const $LVM_ISGROUPVIEWENABLED = ($LVM_FIRST + 175)
Global Const $LVM_ISITEMVISIBLE = ($LVM_FIRST + 182)
Global Const $LVM_MAPIDTOINDEX = ($LVM_FIRST + 181)
Global Const $LVM_MAPINDEXTOID = ($LVM_FIRST + 180)
Global Const $LVM_MOVEGROUP = ($LVM_FIRST + 151)
Global Const $LVM_REDRAWITEMS = ($LVM_FIRST + 21)
Global Const $LVM_REMOVEALLGROUPS = ($LVM_FIRST + 160)
Global Const $LVM_REMOVEGROUP = ($LVM_FIRST + 150)
Global Const $LVM_SCROLL = ($LVM_FIRST + 20)
Global Const $LVM_SETBKCOLOR = ($LVM_FIRST + 1)
Global Const $LVM_SETBKIMAGEA = ($LVM_FIRST + 68)
Global Const $LVM_SETBKIMAGEW = ($LVM_FIRST + 138)
Global Const $LVM_SETCALLBACKMASK = ($LVM_FIRST + 11)
Global Const $LVM_SETCOLUMNA = ($LVM_FIRST + 26)
Global Const $LVM_SETCOLUMNW = ($LVM_FIRST + 96)
Global Const $LVM_SETCOLUMNORDERARRAY = ($LVM_FIRST + 58)
Global Const $LVM_SETCOLUMNWIDTH = ($LVM_FIRST + 30)
Global Const $LVM_SETEXTENDEDLISTVIEWSTYLE = ($LVM_FIRST + 54)
Global Const $LVM_SETGROUPINFO = ($LVM_FIRST + 147)
Global Const $LVM_SETGROUPMETRICS = ($LVM_FIRST + 155)
Global Const $LVM_SETHOTCURSOR = ($LVM_FIRST + 62)
Global Const $LVM_SETHOTITEM = ($LVM_FIRST + 60)
Global Const $LVM_SETHOVERTIME = ($LVM_FIRST + 71)
Global Const $LVM_SETICONSPACING = ($LVM_FIRST + 53)
Global Const $LVM_SETIMAGELIST = ($LVM_FIRST + 3)
Global Const $LVM_SETINFOTIP = ($LVM_FIRST + 173)
Global Const $LVM_SETINSERTMARK = ($LVM_FIRST + 166)
Global Const $LVM_SETINSERTMARKCOLOR = ($LVM_FIRST + 170)
Global Const $LVM_SETITEMA = ($LVM_FIRST + 6)
Global Const $LVM_SETITEMW = ($LVM_FIRST + 76)
Global Const $LVM_SETITEMCOUNT = ($LVM_FIRST + 47)
Global Const $LVM_SETITEMINDEXSTATE = ($LVM_FIRST + 210)
Global Const $LVM_SETITEMPOSITION = ($LVM_FIRST + 15)
Global Const $LVM_SETITEMPOSITION32 = ($LVM_FIRST + 49)
Global Const $LVM_SETITEMSTATE = ($LVM_FIRST + 43)
Global Const $LVM_SETITEMTEXTA = ($LVM_FIRST + 46)
Global Const $LVM_SETITEMTEXTW = ($LVM_FIRST + 116)
Global Const $LVM_SETOUTLINECOLOR = ($LVM_FIRST + 177)
Global Const $LVM_SETSELECTEDCOLUMN = ($LVM_FIRST + 140)
Global Const $LVM_SETSELECTIONMARK = ($LVM_FIRST + 67)
Global Const $LVM_SETTEXTBKCOLOR = ($LVM_FIRST + 38)
Global Const $LVM_SETTEXTCOLOR = ($LVM_FIRST + 36)
Global Const $LVM_SETTILEINFO = ($LVM_FIRST + 164)
Global Const $LVM_SETTILEVIEWINFO = ($LVM_FIRST + 162)
Global Const $LVM_SETTILEWIDTH = ($LVM_FIRST + 141)
Global Const $LVM_SETTOOLTIPS = ($LVM_FIRST + 74)
Global Const $LVM_SETUNICODEFORMAT = 0x2000 + 5
Global Const $LVM_SETVIEW = ($LVM_FIRST + 142)
Global Const $LVM_SETWORKAREAS = ($LVM_FIRST + 65)
Global Const $LVM_SORTGROUPS = ($LVM_FIRST + 158)
Global Const $LVM_SORTITEMS = ($LVM_FIRST + 48)
Global Const $LVM_SORTITEMSEX = ($LVM_FIRST + 81)
Global Const $LVM_SUBITEMHITTEST = ($LVM_FIRST + 57)
Global Const $LVM_UPDATE = ($LVM_FIRST + 42)
; ===============================================================================================================================

; #NOTIFICATIONS# ===============================================================================================================
Global Const $LVN_FIRST = -100
Global Const $LVN_LAST = -199
Global Const $LVN_BEGINDRAG = ($LVN_FIRST - 9) ; A drag and drop involving the left mouse button is being initiated
Global Const $LVN_BEGINLABELEDITA = ($LVN_FIRST - 5) ; The label editting is starting
Global Const $LVN_BEGINLABELEDITW = ($LVN_FIRST - 75) ; [Unicode] The label editting is starting
Global Const $LVN_BEGINRDRAG = ($LVN_FIRST - 11) ; A drag and drop involving the right mouse button is being initiated
Global Const $LVN_BEGINSCROLL = ($LVN_FIRST - 80)
Global Const $LVN_COLUMNCLICK = ($LVN_FIRST - 8) ; A column was clicked
Global Const $LVN_COLUMNDROPDOWN = ($LVN_FIRST - 64)
Global Const $LVN_COLUMNOVERFLOWCLICK = ($LVN_FIRST - 66)
Global Const $LVN_DELETEALLITEMS = ($LVN_FIRST - 4) ; All items are about to be deleted
Global Const $LVN_DELETEITEM = ($LVN_FIRST - 3) ; An item is about to be deleted
Global Const $LVN_ENDLABELEDITA = ($LVN_FIRST - 6) ; The label editting is ending
Global Const $LVN_ENDLABELEDITW = ($LVN_FIRST - 76) ; [Unicode] The label editting is ending
Global Const $LVN_ENDSCROLL = ($LVN_FIRST - 81)
Global Const $LVN_GETDISPINFOA = ($LVN_FIRST - 50) ; Request for the parent to provide information
Global Const $LVN_GETDISPINFOW = ($LVN_FIRST - 77) ; [Unicode] Request for the parent to provide information
Global Const $LVN_GETDISPINFO = $LVN_GETDISPINFOA
Global Const $LVN_GETEMPTYMARKUP = ($LVN_FIRST - 87) ; Vista - when the control has no items
Global Const $LVN_GETINFOTIPA = ($LVN_FIRST - 57)
Global Const $LVN_GETINFOTIPW = ($LVN_FIRST - 58)
Global Const $LVN_HOTTRACK = ($LVN_FIRST - 21) ; The user moved the mouse over an item
Global Const $LVN_INCREMENTALSEARCHA = ($LVN_FIRST - 62)
Global Const $LVN_INCREMENTALSEARCHW = ($LVN_FIRST - 63)
Global Const $LVN_INSERTITEM = ($LVN_FIRST - 2) ; A new item was inserted
Global Const $LVN_ITEMACTIVATE = ($LVN_FIRST - 14) ; The user activated an item
Global Const $LVN_ITEMCHANGED = ($LVN_FIRST - 1) ; An item has changed
Global Const $LVN_ITEMCHANGING = ($LVN_FIRST - 0) ; An item is changing
Global Const $LVN_KEYDOWN = ($LVN_FIRST - 55)
Global Const $LVN_LINKCLICK = ($LVN_FIRST - 84) ; Vista - a link has been clicked on
Global Const $LVN_MARQUEEBEGIN = ($LVN_FIRST - 56)
Global Const $LVN_ODCACHEHINT = ($LVN_FIRST - 13) ; The contents of its display area for a virtual control have changed
Global Const $LVN_ODFINDITEMA = ($LVN_FIRST - 52) ; Sent to the parent when it needs to find a callback item
Global Const $LVN_ODFINDITEMW = ($LVN_FIRST - 79) ; [Unicode] Sent to the parent when it needs to find a callback item
Global Const $LVN_ODFINDITEM = $LVN_ODFINDITEMA
Global Const $LVN_ODSTATECHANGED = ($LVN_FIRST - 15) ; The state of an item or range of items in a virtual control has changed
Global Const $LVN_SETDISPINFOA = ($LVN_FIRST - 51) ; Sent to the parent when it needs to update item information
Global Const $LVN_SETDISPINFOW = ($LVN_FIRST - 78) ; [Unicode] Sent to the parent when it needs to update item information
; ===============================================================================================================================


Global Const $LVNI_ABOVE = 0x0100
Global Const $LVNI_BELOW = 0x0200
Global Const $LVNI_TOLEFT = 0x0400
Global Const $LVNI_TORIGHT = 0x0800
Global Const $LVNI_ALL = 0x0000
Global Const $LVNI_CUT = 0x0004
Global Const $LVNI_DROPHILITED = 0x0008
Global Const $LVNI_FOCUSED = 0x0001
Global Const $LVNI_SELECTED = 0x0002

Global Const $LVSCW_AUTOSIZE = -1
Global Const $LVSCW_AUTOSIZE_USEHEADER = -2

Global Const $LVSICF_NOINVALIDATEALL = 0x00000001
Global Const $LVSICF_NOSCROLL = 0x00000002

Global Const $LVSIL_NORMAL = 0
Global Const $LVSIL_SMALL = 1
Global Const $LVSIL_STATE = 2

; Control default styles
Global Const $GUI_SS_DEFAULT_LISTVIEW = BitOR($LVS_SHOWSELALWAYS, $LVS_SINGLESEL)
