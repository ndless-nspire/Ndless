#include-once

; #INDEX# =======================================================================================================================
; Title .........: DateTime_Constants
; AutoIt Version : 3.1.1 (beta)
; Language ......: English
; Description ...: Constants for <a href="../appendix/GUIStyles.htm#Date">GUI control Date styles</a> and much more.
; Author(s) .....: Valik, Gary Frost
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; Date
Global Const $DTS_SHORTDATEFORMAT = 0
Global Const $DTS_UPDOWN = 1
Global Const $DTS_SHOWNONE = 2
Global Const $DTS_LONGDATEFORMAT = 4
Global Const $DTS_TIMEFORMAT = 9
Global Const $DTS_RIGHTALIGN = 32
Global Const $DTS_SHORTDATECENTURYFORMAT = 0x0000000C ; The year is a four-digit field
Global Const $DTS_APPCANPARSE = 0x00000010 ; Allows the owner to parse user input and take necessary action

; Success/Failure
Global Const $GDT_ERROR = -1
Global Const $GDT_VALID = 0
Global Const $GDT_NONE = 1
Global Const $GDTR_MIN = 0x0001
Global Const $GDTR_MAX = 0x0002

; MonthCal
Global Const $MCHT_NOWHERE = 0x00000000
Global Const $MCHT_TITLE = 0x00010000
Global Const $MCHT_CALENDAR = 0x00020000
Global Const $MCHT_TODAYLINK = 0x00030000
Global Const $MCHT_NEXT = 0x01000000
Global Const $MCHT_PREV = 0x02000000

Global Const $MCHT_TITLEBK = 0x00010000
Global Const $MCHT_TITLEMONTH = 0x00010001
Global Const $MCHT_TITLEYEAR = 0x00010002
Global Const $MCHT_TITLEBTNNEXT = 0x01010003
Global Const $MCHT_TITLEBTNPREV = 0x02010003

Global Const $MCHT_CALENDARBK = 0x00020000
Global Const $MCHT_CALENDARDATE = 0x00020001
Global Const $MCHT_CALENDARDAY = 0x00020002
Global Const $MCHT_CALENDARWEEKNUM = 0x00020003
Global Const $MCHT_CALENDARDATENEXT = 0x01020000
Global Const $MCHT_CALENDARDATEPREV = 0x02020000

; #STYLES# ======================================================================================================================
; Month Calendar
Global Const $MCS_DAYSTATE = 0x0001 ; The control sends $MCN_GETDAYSTATE notifications to request information
Global Const $MCS_MULTISELECT = 0x0002
Global Const $MCS_WEEKNUMBERS = 0x0004
Global Const $MCS_NOTODAYCIRCLE = 0x0008
Global Const $MCS_NOTODAY = 0x0010
Global Const $MCS_NOTRAILINGDATES = 0x0040
Global Const $MCS_SHORTDAYSOFWEEK = 0x0080
Global Const $MCS_NOSELCHANGEONNAV = 0x0100

; Month Calendar Messages
Global Const $MCM_FIRST = 0x1000
Global Const $MCM_GETCALENDARBORDER = ($MCM_FIRST + 31)
Global Const $MCM_GETCALENDARCOUNT = ($MCM_FIRST + 23)
Global Const $MCM_GETCALENDARGRIDINFO = ($MCM_FIRST + 24)
Global Const $MCM_GETCALID = ($MCM_FIRST + 27)
Global Const $MCM_GETCOLOR = ($MCM_FIRST + 11)
Global Const $MCM_GETCURRENTVIEW = ($MCM_FIRST + 22)
Global Const $MCM_GETCURSEL = ($MCM_FIRST + 1)
Global Const $MCM_GETFIRSTDAYOFWEEK = ($MCM_FIRST + 16)
Global Const $MCM_GETMAXSELCOUNT = ($MCM_FIRST + 3)
Global Const $MCM_GETMAXTODAYWIDTH = ($MCM_FIRST + 21)
Global Const $MCM_GETMINREQRECT = ($MCM_FIRST + 9)
Global Const $MCM_GETMONTHDELTA = ($MCM_FIRST + 19)
Global Const $MCM_GETMONTHRANGE = ($MCM_FIRST + 7)
Global Const $MCM_GETRANGE = ($MCM_FIRST + 17)
Global Const $MCM_GETSELRANGE = ($MCM_FIRST + 5)
Global Const $MCM_GETTODAY = ($MCM_FIRST + 13)
Global Const $MCM_GETUNICODEFORMAT = 0x2000 + 6
Global Const $MCM_HITTEST = ($MCM_FIRST + 14)
Global Const $MCM_SETCALENDARBORDER = ($MCM_FIRST + 30)
Global Const $MCM_SETCALID = ($MCM_FIRST + 28)
Global Const $MCM_SETCOLOR = ($MCM_FIRST + 10)
Global Const $MCM_SETCURRENTVIEW = ($MCM_FIRST + 32)
Global Const $MCM_SETCURSEL = ($MCM_FIRST + 2)
Global Const $MCM_SETDAYSTATE = ($MCM_FIRST + 8)
Global Const $MCM_SETFIRSTDAYOFWEEK = ($MCM_FIRST + 15)
Global Const $MCM_SETMAXSELCOUNT = ($MCM_FIRST + 4)
Global Const $MCM_SETMONTHDELTA = ($MCM_FIRST + 20)
Global Const $MCM_SETRANGE = ($MCM_FIRST + 18)
Global Const $MCM_SETSELRANGE = ($MCM_FIRST + 6)
Global Const $MCM_SETTODAY = ($MCM_FIRST + 12)
Global Const $MCM_SETUNICODEFORMAT = 0x2000 + 5
Global Const $MCM_SIZERECTTOMIN = ($MCM_FIRST + 29)
; ===============================================================================================================================

; #NOTIFICATIONS# ===============================================================================================================
Global Const $MCN_FIRST = -746
Global Const $MCN_SELCHANGE = ($MCN_FIRST - 3) ; The currently selected date or range of dates changed
Global Const $MCN_GETDAYSTATE = ($MCN_FIRST - 1) ; Request information about how individual days should be displayed
Global Const $MCN_SELECT = ($MCN_FIRST) ; The user makes an explicit date selection
Global Const $MCN_VIEWCHANGE = ($MCN_FIRST - 4)
; ===============================================================================================================================

Global Const $MCSC_BACKGROUND = 0
Global Const $MCSC_MONTHBK = 4
Global Const $MCSC_TEXT = 1
Global Const $MCSC_TITLEBK = 2
Global Const $MCSC_TITLETEXT = 3
Global Const $MCSC_TRAILINGTEXT = 5

; #MESSAGES# ====================================================================================================================
; Date Time Picker
Global Const $DTM_FIRST = 0x1000
Global Const $DTM_GETSYSTEMTIME = $DTM_FIRST + 1
Global Const $DTM_SETSYSTEMTIME = $DTM_FIRST + 2
Global Const $DTM_GETRANGE = $DTM_FIRST + 3
Global Const $DTM_SETRANGE = $DTM_FIRST + 4
Global Const $DTM_SETFORMAT = $DTM_FIRST + 5
Global Const $DTM_SETMCCOLOR = $DTM_FIRST + 6
Global Const $DTM_GETMCCOLOR = $DTM_FIRST + 7
Global Const $DTM_GETMONTHCAL = $DTM_FIRST + 8
Global Const $DTM_SETMCFONT = $DTM_FIRST + 9
Global Const $DTM_GETMCFONT = $DTM_FIRST + 10
Global Const $DTM_SETFORMATW = $DTM_FIRST + 50 ; [Unicode]
; ===============================================================================================================================

; #NOTIFICATIONS# ===============================================================================================================
; Date Time Picker
Global Const $DTN_FIRST = -740
Global Const $DTN_FIRST2 = -753
Global Const $DTN_DATETIMECHANGE = $DTN_FIRST2 - 6 ; Sent whenever a change occurs
Global Const $DTN_USERSTRING = $DTN_FIRST2 - 5 ; Sent when a user finishes editing a string in the control
Global Const $DTN_WMKEYDOWN = $DTN_FIRST2 - 4 ; Sent when the user types in a callback field
Global Const $DTN_FORMAT = $DTN_FIRST2 - 3 ; Sent to request text to be displayed in a callback field
Global Const $DTN_FORMATQUERY = $DTN_FIRST2 - 2 ; Sent to retrieve the size of the callback field string
Global Const $DTN_DROPDOWN = $DTN_FIRST2 - 1 ; Sent when the user activates the drop-down month calendar
Global Const $DTN_CLOSEUP = $DTN_FIRST2 - 0 ; Sent when the user closes the drop-down month calendar
Global Const $DTN_USERSTRINGW = $DTN_FIRST - 5 ; [Unicode] Sent when a user finishes editing a string in the control
Global Const $DTN_WMKEYDOWNW = $DTN_FIRST - 4 ; [Unicode] Sent when the user types in a callback field
Global Const $DTN_FORMATW = $DTN_FIRST - 3 ; [Unicode] Sent to request text to be displayed in a callback field
Global Const $DTN_FORMATQUERYW = $DTN_FIRST - 2 ; [Unicode] Sent to retrieve the size of the callback field string
; ===============================================================================================================================

; Control default styles
Global Const $GUI_SS_DEFAULT_DATE = $DTS_LONGDATEFORMAT
Global Const $GUI_SS_DEFAULT_MONTHCAL = 0
