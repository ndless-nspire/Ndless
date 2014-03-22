#include-once

; #INDEX# =======================================================================================================================
; Title .........: Visa
; AutoIt Version : 3.0
; Language ......: English
; Description ...: VISA (GPIB & TCP) library for AutoIt.
;                  Functions that allow controlling instruments (e.g. oscilloscopes,
;                  signal generators, spectrum analyzers, power supplies, etc)
;                  that have a GPIB or Ethernet port through the VISA interface
;                  (GPIB, TCP or Serial Interface)
; Author(s) .....: Angel Ezquerra
; Dll ...........: visa32.dll
; ===============================================================================================================================

; ------------------------------------------------------------------------------
;
; Requirements:   The VISA libraries must be installed (you can check whether
;                 visa32.dll is in {WINDOWS}\system32)
;                 For GPIB communication a GPIB card (such as a National Instruments
;                 NI PCI-GPIB card or an Agilent 82350B PCI High-Performance GPIB card
; Limitations:    The VISA queries only return the 1st line of the device answer
;                 This is not a problem in most cases, as most devices will always
;                 answer with a single line.
; Notes:
;                 If you are interested in this library you probably already know
;                 what is VISA and GPIB, but here there is a short description
;                 for those that don't know about it:
;
;                 Basically GPIB allows you to control instruments like Power
;                 Supplies, Signal Generators, Oscilloscopes, Signal Generators, etc.
;                 You need to install or connect a GPIB interface card (PCI, PCMCIA
;                 or USB) to your PC and install the corresponding GPIB driver.
;
;                 VISA is a standard API that sits on top of the GPIB driver and
;                 it allows you to use the same programs to control your
;                 instruments regardless of the type of GPIB card that you have
;                 installed in your PC (most cards are made either by National
;                 Instruments(R) or by Agilent/Hewlett-Packard(R)).
;
;                 This library is that it opens AutoIt to a different kind of
;                 automation (instrument automation). Normally you would need to
;                 use some expensive "instrumentation" environment like
;                 Labwindows/CVI (TM), LabView (TM) or Matlab (TM) to automate
;                 instruments but now you can do so with AutoIt.
;                 The only requirement is that you need a VISA compatible GPIB
;                 card (all cards that I know are) and the corresponding VISA
;                 driver must be installed (look for visa32.dll in the
;                 windows\system32 folder).
;
;                 Basically you have 4 main functions:
;                 _viExecCommand - Executes commands and queries through GPIB
;                 _viOpen, _viClose - Open/Close a connection to a GPIB instrument.
;                 _viFindGpib - Find all the instruments in the GPIB bus
;
;                 There are other less important functions, like:
;                 _viGTL - Go to local mode (exeit the "remote control mode")
;                 _viGpibBusReset - Reset the GPIB bus if it is in a bad state
;                 _viSetTimeout - Sets the GPIB Query timeout
;                 _viSetAttribute - Set any VISA attribute
;
;                 There is one known limitation of this library:
;                 - The GPIB queries do not support binary transfer.
;
;                 It is recommended that you try first to execute the _viFindGpib
;                 function (as shown in the example in the _viFindGpib header)
;                 and see if you can find any instruments. You can also have a
;                 look at the examples in the _viExecCommand function description.
;
; ------------------------------------------------------------------------------
; VERSION       DATE       DESCRIPTION
; -------    ----------    -----------------------------------------------------
; v1.0.00    02/01/2005    Initial release
; v1.0.01    02/06/2005    Formatted according to Standard UDF rules
;                          Fixed _viGpibBusReset
;                          Renamed _viFindGPIB to _viFindGpib
;                          Removed unnecessary MsgBox calls
;                          More detailed function headers
;                          Added Serial Interface related Attribute/Value Constants
; v1.0.02    02/11/2005    Fixed _viQueryf only executing "*IDN?" queries
;                          Fixed _viQueryf only returning characters up to the first space
;                          Fixed _viQuertf returning only first line of answer
;                          Added _viInterativeControl for interactive VISA control
;                          Added GPIB message termination attributes
; ------------------------------------------------------------------------------

; #VARIABLES# ===================================================================================================================
; The VISA Resource Manager is used by the _viOpen functions (see below)
; This is the only (non constant) Global required by this library
Global $VISA_DEFAULT_RM = -1
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; NOTE: There are more attribute values. Please refer to the VISA Programmer's Guide
Global Const $VI_SUCCESS = 0 ; (0L)
Global Const $VI_NULL = 0

Global Const $VI_TRUE = 1
Global Const $VI_FALSE = 0

;- VISA GPIB BUS control macros (for __viGpibControlREN, see below) -------------
Global Const $VI_GPIB_REN_DEASSERT = 0
Global Const $VI_GPIB_REN_ASSERT = 1
Global Const $VI_GPIB_REN_DEASSERT_GTL = 2
Global Const $VI_GPIB_REN_ASSERT_ADDRESS = 3
Global Const $VI_GPIB_REN_ASSERT_LLO = 4
Global Const $VI_GPIB_REN_ASSERT_ADDRESS_LLO = 5
Global Const $VI_GPIB_REN_ADDRESS_GTL = 6


;- VISA interface ATTRIBUTE NAMES ----------------------------------------------
; General Attributes
Global Const $VI_ATTR_TMO_VALUE = 0x3FFF001A

; Serial Interface related Attributes
Global Const $VI_ATTR_ASRL_BAUD = 0x3FFF0021
Global Const $VI_ATTR_ASRL_DATA_BITS = 0x3FFF0022
Global Const $VI_ATTR_ASRL_PARITY = 0x3FFF0023
Global Const $VI_ATTR_ASRL_STOP_BITS = 0x3FFF0024
Global Const $VI_ATTR_ASRL_FLOW_CNTRL = 0x3FFF0025

; GPIB message termination attributes
Global Const $VI_ATTR_TERMCHAR = 0x3FFF0018
Global Const $VI_ATTR_TERMCHAR_EN = 0x3FFF0038
Global Const $VI_ATTR_SEND_END_EN = 0x3FFF0016

;- VISA interface ATTRIBUTE VALUES ---------------------------------------------
;* TIMEOUT VALUES:
Global Const $VI_TMO_IMMEDIATE = 0
Global Const $VI_TMO_INFINITE = 0xFFFFFFF

; Serial Interface related Attribute Values
Global Const $VI_ASRL_PAR_NONE = 0
Global Const $VI_ASRL_PAR_ODD = 1
Global Const $VI_ASRL_PAR_EVEN = 2
Global Const $VI_ASRL_PAR_MARK = 3
Global Const $VI_ASRL_PAR_SPACE = 4

Global Const $VI_ASRL_STOP_ONE = 10
Global Const $VI_ASRL_STOP_ONE5 = 15
Global Const $VI_ASRL_STOP_TWO = 20

Global Const $VI_ASRL_FLOW_NONE = 0
Global Const $VI_ASRL_FLOW_XON_XOFF = 1
Global Const $VI_ASRL_FLOW_RTS_CTS = 2
Global Const $VI_ASRL_FLOW_DTR_DSR = 4
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_viClose
;_viExecCommand
;_viFindGpib
;_viGpibBusReset
;_viGTL
;_viInteractiveControl
;_viOpen
;_viSetAttribute
;_viSetTimeout
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;__viOpenDefaultRM
;__viPrintf
;__viQueryf
;__viGpibControlREN
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
;
; Description ...: MAIN FUNCTION - Send a Command/Query to an Instrument/Device
; Syntax.........: _viExecCommand($h_session, $s_command, $i_timeout_ms = -1)
; Parameters ....: $h_session - A VISA descriptor (STRING) OR a VISA session handle (INTEGER)
;                              * STRING -> A VISA DESCRIPTOR is a string which
;                                specifies the resource with which to establish a
;                                communication session. An example descriptor is
;                                "GPIB::20::0". This function supports all valid
;                                VISA descriptors, including GPIB, TCP, VXI and
;                                Serial Interface instruments. A detailed explanation
;                                of VISA descriptors is shown in the Notes section
;                                of this function.
;                                As a SHORTCUT you can use a STRING containing
;                                the address number (e.g. "20") of a GPIB
;                                instrument instead of typing the full descriptor
;                                (in that case, "GPIB::20::0")
;                              * INTEGER -> A VISA session handle is an integer
;                                value returned by _viOpen (see below).
;                                It is recommended that instead you use _viOpen
;                                and VISA session handles instead of descriptors
;                                if you plan to communicate repeteadly with an
;                                Instrument or Device, as otherwise each time that
;                                you contact the instrument you would incur the
;                                overhead of opening and closing the communication
;                                link.
;                                Once you are done using the instrument you must
;                                remember to close the link with _viClose (see below)
;                   $s_command - Command/Query to execute.
;                                A query MUST contain a QUESTION MARK (?)
;                                When the command is a QUERY the function will
;                                automatically wait for the instrument's answer
;                                (or until the operation times out)
;                   $i_timeout_ms - The operation timeout in MILISECONDS
;                                This is mostly important for QUERIES only
;                                This is an OPTIONAL PARAMETER.
;                                If it is not specified the last set timeout will
;                                be used. If it was never set before the default
;                                timeout (which depends on the VISA implementation)
;                                will be used. Timeouts can also be set separatelly
;                                with the _viSetTimeout function (see below)
;                   $s_mode - Control the mode in which the VISA viPrintf is called
;                                This is an OPTIONAL PARAMETER.
;                                Check the __viPrintf help for more info on
;                                this OPTIONAL PARAMETER (whose default value is @LF)
;                                This is normally NOT necessary and should only be set
;                                if your GPIB card or instrument require it.
; Return values .: The return value depends on whether the command is a QUERY
;                   or not and in whether the operation was successful or not.
;
;                   * Command, NON QUERY:
;                     On Success - Returns ZERO
;                     On Failure - Returns -1 if the VISA DLL could not be open
;                                  or a NON ZERO value representing the VISA
;                                  error code (see the VISA programmer's guide)
;                   * QUERY:
;                     On Success - Returns the answer of the instrument to the QUERY
;                     On Failure - Returns -1 if the VISA DLL could not be open
;                                  Returns -3 if the VISA DLL returned an unexpected
;                                  number of results
;                                  or returns a NON ZERO value representing the VISA
;                                  error code (see the VISA programmer's guide)
;
;                   This function always sets @error to 1 in case of error
; Author ........: Angel Ezquerra <ezquerra at gmail dot com>
; Example .......:
;                 - Simple communication examples:
;                   Get instrument ID:
;                     $s_idn = _viExecCommand("GPIB::20::0","*IDN?")
;                   This is the same as:
;                     $s_idn = _viExecCommand("20","*IDN?") -> Note that "20" is a STRING
;
;                 - More efficient way to communicate many times
;                   You must use _viOpen and _viClose
;                   In this example we measure a POWER 100 times:
;                     $h_session = _viOpen("GPIB::1::0") ; or $h_session = _viOpen("1")
;                     For $n = 0 To 99
;                       $power_array[$n] = _viExecCommand($h_session,"POWER?")
;                     Next
;                     _viClose($h_session)
;
;                   A more complex example, using 2 instruments, a signal generator
;                   and a spectrum analyzer, to measure the average power error of
;                   the generator:
;
;                     $h_spec_analyzer = _viOpen("GPIB::1::0") ; or $h_session = _viOpen("1")
;                     $h_signal_gen = _viOpen("GPIB::12::0") ; or $h_session = _viOpen("1")
;                     $average_power_error = 0
;                     For $ideal_power = -100 To -10 ; dBM
;                       _viExecCommand($h_signal_gen,"SOURCE:POWER " & $ideal_power & "dBm")
;                       $current_power_error = Abs($ideal_power - _viExecCommand($h_spec_analyzer,"POWER?"))
;                       $average_power_error = $average_power_error + $current_power_error
;                     Next
;                     $average_power_error = $average_power_error / 91
;                     _viClose($h_spec_analyzer)
;                     _viClose($h_signal_gen)
;
; Notes .........:
;                 The following is a description of the MOST COMMON VISA DESCRIPTORS
;                 Note that there are some more types. For more info please
;                 refer to a VISA programmer's guide (available at www.ni.com)
;                 Optional segments are shown in square brackets ([]).
;                 Required segments that must be filled in are denoted by angle
;                 brackets (<>).
;
;                 Interface   Syntax
;                 ------------------------------------------------------------
;                 GPIB INSTR      GPIB[board]::primary address
;                                 [::secondary address] [::INSTR]
;                 GPIB INTFC      GPIB[board]::INTFC
;                 TCPIP SOCKET    TCPIP[board]::host address::port::SOCKET
;                 Serial INSTR    ASRL[board][::INSTR]
;                 PXI INSTR       PXI[board]::device[::function][::INSTR]
;                 VXI INSTR       VXI[board]::VXI logical address[::INSTR]
;                 GPIB-VXI INSTR  GPIB-VXI[board]::VXI logical address[::INSTR]
;                 TCPIP INSTR     TCPIP[board]::host address[::LAN device name]
;                                 [::INSTR]
;
;                 The GPIB keyword is used for GPIB instruments.
;                 The TCPIP keyword is used for TCP/IP communication.
;                 The ASRL keyword is used for serial instruments.
;                 The PXI keyword is used for PXI instruments.
;                 The VXI keyword is used for VXI instruments via either embedded
;                 or MXIbus controllers.
;                 The GPIB-VXI keyword is used for VXI instruments via a GPIB-VXI
;                 controller.
;
;                 The default values for optional parameters are shown below.
;
;                 Optional Segment          Default Value
;                 ---------------------------------------
;                 board                     0
;                 secondary address         none
;                 LAN device name           inst0
;
;
;                 Example Resource Strings:
;                 --------------------------------------------------------------
;                 GPIB::1::0::INSTR     A GPIB device at primary address 1 and
;                                       secondary address 0 in GPIB interface 0.
;
;                 GPIB2::INTFC          Interface or raw resource for GPIB
;                                       interface 2.
;
;                 TCPIP0::1.2.3.4::999::SOCKET    Raw TCP/IP access to port 999
;                                                 at the specified IP address.
;
;                 ASRL1::INSTR          A serial device attached to interface
;                                       ASRL1.  VXI::MEMACC Board-level register
;                                       access to the VXI interface.
;
;                 PXI::15::INSTR        PXI device number 15 on bus 0.
;
;                 VXI0::1::INSTR        A VXI device at logical address 1 in VXI
;                                       interface VXI0.
;
;                 GPIB-VXI::9::INSTR    A VXI device at logical address 9 in a
;                                       GPIB-VXI controlled system.
;
; ===============================================================================================================================
Func _viExecCommand($h_session, $s_command, $i_timeout_ms = -1, $s_mode = @LF)
	If StringInStr($s_command, "?") = 0 Then
		; The Command is NOT a QUERY
		Return __viPrintf($h_session, $s_command, $i_timeout_ms, $s_mode)
	Else
		; The Command is a QUERY
		Return __viQueryf($h_session, $s_command, $i_timeout_ms)
	EndIf
EndFunc   ;==>_viExecCommand

; #FUNCTION# ====================================================================================================================
;
; Description ...: Opens a VISA connection to an Instrument/Device
; Syntax.........: _viOpen($s_visa_address, $s_visa_secondary_address = 0)
; Parameters ....: $s_visa_address - A VISA resource descriptor STRING (see the
;                   NOTES of _viExecCommand above for more info)
;                   As as shortcut you can also directly pass a GPIB address as
;                   an integer
;                   $s_visa_secondary_address - Some GPIB instruments have
;                   secondary addresses. This parameter is ZERO by default, which
;                   means NO SECONDARY ADDRESS.
;                   Only use this optional parameter if the primary address is
;                   passed as an integer
; Return values .: On Success - Returns a (POSITIVE) VISA Instrument Handle
;                   On Failure - Returns -1 and SETS @error to 1
; Author ........: Angel Ezquerra <ezquerra at gmail dot com>
; Notes .........: For simple usage there is no need to use this function, as
;                   _viExecCommand automatically opens/closes a VISA connection
;                   if you pass it a VISA resource descriptor (see the NOTES of
;                   _viExecCommand above for more info)
;
;                   However, if you want to repeteadly send commands/queries to
;                   a device, you should call this function followed by using the
;                   returned instrument handle instead of the VISA descriptor
;
;                   Do not forget to use _viClose when you are done, though
;
; ===============================================================================================================================
Func _viOpen($s_visa_address, $s_visa_secondary_address = 0)
	Local $h_session = -1 ; The session handle by default is invalid (-1)

	If IsNumber($s_visa_address) Or StringInStr($s_visa_address, "::") = 0 Then
		; We passed a number => Create the VISA string:
		$s_visa_address = "GPIB0::" & $s_visa_address & "::" & $s_visa_secondary_address
	EndIf

	;- Do not open an instrument connection twice
	; TODO

	;- Make sure that there is a Resource Manager open (Note: this will NOT open it twice!)
	__viOpenDefaultRM()

	;- Open the INSTRUMENT CONNECTION
	; errStatus = viOpen (VISA_DEFAULT_RM, "GPIB0::20::0", VI_NULL, VI_NULL, &h_session);
	; signed int viOpen(unsigned long, char*, unsigned long, unsigned long, *unsigned long)
	Local $a_results
	$a_results = DllCall("visa32.dll", "long", "viOpen", "long", $VISA_DEFAULT_RM, "str", $s_visa_address, "long", $VI_NULL, "long", $VI_NULL, "long*", -1)
	If @error Then Return SetError(@error, @extended, -1)
	Local $errStatus = $a_results[0]
	If $errStatus <> 0 Then
		; Could not open VISA instrument/resource
		;MsgBox(16,"VISA error","Could not open VISA instrument/resource: " & $s_visa_address)
		Return SetError(1, 0, -2)

	EndIf
	; Make sure that the DllCall returned enough values
	If UBound($a_results) < 6 Then
		;MsgBox(16,"VISA error","Call to viOpen did not return the right number of values")
		Return SetError(1, 0, -3)
	EndIf

	$h_session = $a_results[5]
	If $h_session <= 0 Then
		; viOpen did not return a valid handle
		;MsgBox(16,"VISA error","viOpen did not return a valid handle")
		Return SetError(1, 0, -4)
	EndIf

	; We have a valid handle for the device
	Return $h_session
EndFunc   ;==>_viOpen

; #FUNCTION# ====================================================================================================================
;
; Description ...: Closes a VISA connection to an Instrument/Device
; Syntax.........: _viClose($h_session)
; Parameters ....: $h_session - A VISA session handle (as returned by _viOpen)
; Return values .: On Success - Returns 0
;                   On Failure - Returns -1 if the VISA DLL could not be open
;                                or a NON ZERO value representing the VISA
;                                error code (see the VISA programmer's guide)

; Author ........: Angel Ezquerra <ezquerra at gmail dot com>
; Notes .........: For simple usage there is no need to use this function, as
;                   _viExecCommand automatically opens/closes a VISA connection
;                   if you pass it a VISA resource descriptor (see the NOTES of
;                   _viExecCommand above for more info)
;
;                   However, if you want to repeteadly send commands/queries to
;                   a device, you should use _viOpen followed by using the
;                   returned instrument handle instead of the VISA descriptor
;                   and then calling this function
;
; ===============================================================================================================================
Func _viClose($h_session)
	;- Close INSTRUMENT Connection
	; viClose(h_session);
	Local $a_results
	$a_results = DllCall("visa32.dll", "int", "viClose", "int", $h_session)
	If @error Then Return SetError(@error, @extended, -1)
	Local $errStatus = $a_results[0]
	If $errStatus <> 0 Then
		; Could not close VISA instrument/resource
		;MsgBox(16,"VISA error","Could not close VISA instrument/resource: " & $h_session)
		Return SetError(1, 0, $errStatus)
	EndIf

	Return 0
EndFunc   ;==>_viClose

; #FUNCTION# ====================================================================================================================
;
; Description ...: Find all the DEVICES found in the GPIB bus
; Syntax.........: _viFindGpib(ByRef $a_descriptor_list, ByRef $a_idn_list, $f_show_search_results = 0)
; Parameters ....: $a_descriptor_list (ByRef) - RETURNS an array of the VISA resource
;                   descriptors (see the NOTES of _viExecCommand above for more
;                   info) of the instruments that were found in the GPIB bus
;                   $a_idn_list (ByRef) - RETURNS an array of the IDNs (i.e names)
;                   of the instruments that were found in the GPIB bus
;                   $f_show_search_results - If 1 a message box showing the
;                   results of the search will be shown
;                   The default is 0, which means that the results are not shown
; Return values .: On Success - The number of instruments found (0 or more)
;                   On Failure - Returns a NEGATIVE value and SETS @error to 1
; Author ........: Angel Ezquerra <ezquerra at gmail dot com>
; Example .......:
;  ; This example performs a search on the GPIB bus and shows the results in a MsgBox
;  Dim $a_descriptor_list[1], $a_idn_list[1]
;  _viFindGpib($a_descriptor_list, $a_idn_list, 1)
;
; Notes .........: For simple usage there is no need to use this function, as
;                   _viExecCommand automatically opens/closes a VISA connection
;                   if you pass it a VISA resource descriptor (see the NOTES of
;                   _viExecCommand above for more info)
;
;                   However, if you want to repeteadly send commands/queries to
;                   a device, you should call this function followed by using the
;                   returned instrument handle instead of the VISA descriptor
;
;                   Do not forget to use _viClose when you are done, though
;
; ===============================================================================================================================
Func _viFindGpib(ByRef $a_descriptor_list, ByRef $a_idn_list, $f_show_search_results = 0)
	;- Make sure that there is a Resource Manager open (Note: this will NOT open it twice!)
	__viOpenDefaultRM()

	; Create the GPIB instrument list and return the 1st instrument descriptor
	; viStatus viFindRsrc (viSession, char*, *ViFindList, *ViUInt32, char*);
	; errStatus = viFindRsrc (VISA_DEFAULT_RM, "GPIB?*INSTR", &h_current_instr, &num_matches, s_found_instr_descriptor);
	Local $a_results = DllCall("visa32.dll", "long", "viFindRsrc", _
			"long", $VISA_DEFAULT_RM, "str", "GPIB?*INSTR", "long*", -1, _
			"int*", -1, "str", "")
	If @error Then Return SetError(@error, @extended, -1)
	Local $errStatus = $a_results[0]
	If $errStatus <> 0 Then
		; Could not perform GPIB FIND operation
		;MsgBox(16,"VISA error","Could not perform GPIB FIND operation")
		Return SetError(1, 0, -2)
	EndIf
	; Make sure that the DllCall returned enough values
	If UBound($a_results) < 5 Then
		;MsgBox(16,"VISA error","Call to viFindRsrc did not return the right number of values")
		Return SetError(1, 0, -3)
	EndIf

	; Assign the outputs of the DllCall
	Local $h_list_pointer = $a_results[3] ; The pointer to the list of found instruments
	Local $i_num_instr = $a_results[4] ; The number of instruments that were found
	Local $s_first_descriptor = $a_results[5] ; The descriptor of the first instrument found
	If $i_num_instr < 1 Then ; No insturments were found
		If $f_show_search_results = 1 Then
			MsgBox(64, "GPIB search results", "NO INSTRUMENTS FOUND in the GPIB bus")
		EndIf

		Return $i_num_instr
	EndIf

	; At least 1 instrument was found
	ReDim $a_descriptor_list[$i_num_instr], $a_idn_list[$i_num_instr]
	$a_descriptor_list[0] = $s_first_descriptor
	; Get the IDN of the 1st instrument
	$a_idn_list[0] = _viExecCommand($s_first_descriptor, "*IDN?")

	; Get the IDN of all the remaining instruments
	For $n = 1 To $i_num_instr - 1
		; If more than 1 instrument was found, get the handle of the next instrument
		; and get its IDN

		;- Get the handle and descriptor of the next instrument in the GPIB bus
		; We do this by calling "viFindNext"
		; viFindNext (*ViFindList, char*);
		; viFindNext (h_current_instr,s_found_instr_descriptor);
		$a_results = DllCall("visa32.dll", "long", "viFindNext", "long", $h_list_pointer, "str", "")
		If @error Then Return SetError(@error, @extended, -1)
		$errStatus = $a_results[0]
		If $errStatus <> 0 Then
			; Could not perform GPIB FIND NEXT operation
			;MsgBox(16,"VISA error","Could not perform GPIB FIND NEXT operation")
			Return SetError(1, 0, -2)
		EndIf
		; Make sure that the DllCall returned enough values
		If UBound($a_results) < 3 Then
			;MsgBox(16,"VISA error","Call to viFindNext did not return the right number of values")
			Return SetError(1, 0, -3)
		EndIf
		$a_descriptor_list[$n] = $a_results[2]
		$a_idn_list[$n] = _viExecCommand($a_descriptor_list[$n], "*IDN?")
	Next

	If $f_show_search_results = 1 Then
		; Create the GPIB instrument list and show it in a MsgBox
		Local $s_search_results = ""
		For $n = 0 To $i_num_instr - 1
			$s_search_results = $s_search_results & $a_descriptor_list[$n] & " - " & $a_idn_list[$n] & @CR
		Next
		MsgBox(64, "GPIB search results", $s_search_results)
	EndIf

	Return $i_num_instr

EndFunc   ;==>_viFindGpib

; #INTERNAL_USE_ONLY# ===========================================================================================================
;
; Description ...: Open the VISA Resource Manager
; Syntax.........: __viOpenDefaultRM()
; Parameters ....: None
; Return values .: On Success - The Default Resource Manager Handle (also stored
;                   in the $VISA_DEFAULT_RM global)
;                   On Failure - Returns -1 if the VISA DLL could not be open
;                                Returns -2 if there was an error opening the
;                                Default Resource Manager
;                                Returns -3 if the returned Resource Manager is
;                                invalid
;                   This function always sets @error to 1 in case of error
; Author ........: Angel Ezquerra <ezquerra at gmail dot com>
; Notes .........: You should not need to directly call this function under
;                   normal use as _viOpen calls it when necessary
;
; ===============================================================================================================================
Func __viOpenDefaultRM()
	Local $h_visa_rm = $VISA_DEFAULT_RM
	If $VISA_DEFAULT_RM < 0 Then
		; Only open the Resource Manager once (i.e. when $VISA_DEFAULT_RM is still -1)
		$h_visa_rm = $VISA_DEFAULT_RM ; Initialize the output result with the default value (-1)

		; errStatus = viOpenDefaultRM (&VISA_DEFAULT_RM);
		; signed int viOpenDefaultRM(*unsigned long)
		Local $a_results
		$a_results = DllCall("visa32.dll", "int", "viOpenDefaultRM", "int*", $VISA_DEFAULT_RM)
		If @error Then Return SetError(@error, @extended, -1)
		Local $errStatus = $a_results[0]
		If $errStatus <> 0 Then
			; Could not create VISA Resource Manager
			;MsgBox(16,"VISA error","Could not create VISA Resource Manager")
			Return SetError(1, 0, -2)
		EndIf
		; Everything went fine => Set the Resource Manager global
		$VISA_DEFAULT_RM = $a_results[1]
		If $VISA_DEFAULT_RM <= 0 Then
			; There was an error, reset the $VISA_DEFAULT_RM
			$VISA_DEFAULT_RM = -1 ; Default value
			SetError(1)
			Return -3
		EndIf
		$h_visa_rm = $VISA_DEFAULT_RM
	EndIf

	Return $h_visa_rm
EndFunc   ;==>__viOpenDefaultRM

; #INTERNAL_USE_ONLY# ===========================================================================================================
;
; Description ...: Send a COMMAND (NOT a QUERY) to an Instrument/Device
; Syntax.........: __viPrintf($h_session, $s_command, $i_timeout_ms = -1)
; Parameters ....: $h_session - A VISA descriptor (STRING) OR a VISA session handle (INTEGER)
;                                Look at the _viExecCommand function for more
;                                details
;                   $s_command - Command/Query to execute.
;                                A query MUST contain a QUESTION MARK (?)
;                                When the command is a QUERY the function will
;                                automatically wait for the instrument's answer
;                                (or until the operation times out)
;                   $i_timeout_ms - The operation timeout in MILISECONDS
;                                This is mostly important for QUERIES only
;                                This is an OPTIONAL PARAMETER.
;                                If it is not specified the last set timeout will
;                                be used. If it was never set before the default
;                                timeout (which depends on the VISA implementation)
;                                will be used. Timeouts can also be set separatelly
;                                with the _viSetTimeout function (see below).
;                                Depending on the bus type (GPIB, TCP, etc) the
;                                timeout might not be set to the exact value that
;                                you request. Instead the closest valid timeout
;                                bigger than the one that you requested will be used.
;                   $s_mode - Control the mode in which the VISA viPrintf is called
;                                This is an OPTIONAL PARAMETER
;                                The DEFAULT VALUE is @LF, which means "attach @LF mode".
;                                Some instruments and in particular many GPIB cards
;                                Do not honor the terminator character attribute
;                                In those cases an @LF terminator needs to be added.
;                                As this is the most common case, by default the mode
;                                is set to @LF, which appends @LF to the SCPI command
;                                You can also set this mode to @CR and @CRLF if your card
;                                uses those terminators.
;                                If you do not want to use a terminator, set this parameter
;                                to an empty string ("")
;                                Also, some cards support the execution of a "sprintf" on the
;                                SCPI string prior to sending it through the VISA interface.
;                                For those who do, it is possible, by setting this
;                                parameter to "str" to "protect" the VISa interface from
;                                accidentally applying an escape sequence when a "/" is
;                                found within the VISA command string.
;                                This is normally NOT necessary and should only be set
;                                if your GPIB card or instrument require it.
; Return values .: On Success - Returns ZERO
;                   On Failure - Returns -1 if the VISA DLL could not be open
;                                or a NON ZERO value representing the VISA
;                                error code (see the VISA programmer's guide)
;                   This function always sets @error to 1 in case of error
; Author ........: Angel Ezquerra <ezquerra at gmail dot com>
; Notes .........:
;                   Normally you do not need to use this function,
;                   as _viExecCommand automatically choses between _viPrintf and
;                   __viQueryf depending on the command type.
;
;                   If you need to use it anyway, it is recommended that you do
;                   not use this command for sending QUERIES, only for GPIB
;                   commands that DO NOT RETURN AN ANSWER
;
;                   Also, this is not really a "PRINTF-like" function, as it
;                   does not allow you to pass multiple parameters. This is only
;                   called _viPrintf because it uses the VISA function viPrintf
;
;                   See _viExecCommand for more details
;
; ===============================================================================================================================
Func __viPrintf($h_session, $s_command, $i_timeout_ms = -1, $s_option = @LF)
	Local $f_close_session_before_return = 0 ; By default do not close the session at the end
	If IsString($h_session) Then
		; When we pass a string, i.e. a VISA ID (like GPIB::20::0, for instance) instead
		; of a VISA session handler, we will automatically OPEN and CLOSE the instrument
		; session for the user.
		; This is of course slower if you need to do more than one GPIB call but much
		; more convenient for short tests
		$f_close_session_before_return = 1
		$h_session = _viOpen($h_session)
	EndIf

	;- Set the VISA timeout if necessary
	If $i_timeout_ms >= 0 Then
		_viSetTimeout($h_session, $i_timeout_ms)
	EndIf

	;- Send Command to instrument (using viPrintf VISA function)
	; The syntax of the viPrintf VISA function is:
	; errStatus = viPrintf (h_session, "%s", "*RST");
	; signed int viPrintf (unsigned long, char*, char*);

	; For symmetry with the viQueryf function, and to solve compatibility issues
	; with some instruments, call viPrintf WITHOUT protecting from escape sequences
	; The user MUST thus be careful when passing commands containing the '/' character
	Local $a_results
	Select
		Case $s_option = "str"
			; Use the "str" mode to pass the SCPI command to the VISA interface
			$a_results = DllCall("visa32.dll", "int:cdecl", "viPrintf", "int", $h_session, "str", "%s", "str", $s_command) ; Call viPrintf with escape sequence protection
		Case ($s_option = @CR Or $s_option = @LF Or $s_option = @CRLF)
			; Append the selected terminator to the SCPI command
			$a_results = DllCall("visa32.dll", "int:cdecl", "viPrintf", "int", $h_session, "str", $s_command & $s_option)
		Case Else ; In all other cases, ignore the "mode" and do not use any terminator string
			$a_results = DllCall("visa32.dll", "int:cdecl", "viPrintf", "int", $h_session, "str", $s_command) ; Call viPrintf without escape sequence protection
	EndSelect

	If @error Then Return SetError(@error, @extended, -1)
	Local $errStatus = $a_results[0]
	If $errStatus <> 0 Then
		; Could not send command to VISA instrument/resource
		;MsgBox(16,"VISA error","Could not send command to VISA instrument/resource: " & $h_session)
		Return SetError(1, 0, $errStatus)
	EndIf

	If $f_close_session_before_return = 1 Then
		_viClose($h_session)
	EndIf
EndFunc   ;==>__viPrintf

; #INTERNAL_USE_ONLY# ===========================================================================================================
;
; Description ...: Send a QUERY (a Command that returns an answer) to an Instrument/Device
; Syntax.........: __viQueryf($h_session, $s_query, $i_timeout_ms = -1)
; Parameters ....: $h_session - A VISA descriptor (STRING) OR a VISA session handle (INTEGER)
;                                Look at the _viExecCommand function for more
;                                details
;                   $s_command - The query to execute (e.g. "*IDN?").
;                                A query MUST contain a QUESTION MARK (?)
;                                The function willautomatically wait for the
;                                instrument's answer (or until the operation
;                                times out)
;                   $i_timeout_ms - The operation timeout in MILISECONDS
;                                This is mostly important for QUERIES only
;                                This is an OPTIONAL PARAMETER.
;                                If it is not specified the last set timeout will
;                                be used. If it was never set before the default
;                                timeout (which depends on the VISA implementation)
;                                will be used. Timeouts can also be set separatelly
;                                with the _viSetTimeout function (see below)
; Return values .: On Success - Returns a STRING containing the answer of the
;                                instrument to the QUERY
;                   On Failure - Returns -1 if the VISA DLL could not be open
;                                Returns -3 if the VISA DLL returned an unexpected
;                                number of results
;                                or returns a NON ZERO value representing the VISA
;                                error code (see the VISA programmer's guide)
;                   This function always sets @error to 1 in case of error
; Author ........: Angel Ezquerra <ezquerra at gmail dot com>
; Notes .........:
;                   Normally you do not need to use this function,
;                   as _viExecCommand automatically choses between _viPrintf and
;                   __viQueryf depending on the command type.
;
;                   If you need to use it anyway, make sure that you use it for
;                   a command that RETURNS an ANSWER or you will be stuck until
;                   the Timeout expires, which could never happen if the Timeout
;                   is infinite ("INF")!
;
;                   Also, this is not really a "SCANF-like" function, as it
;                   does not allow you to specify the format of the output
;
;                   There are two known limitations of this function:
;                   - The GPIB queries only return the 1st line of the device
;                     answer. This is normally not a problem as most devices
;                     always return a single line answer.
;                   - The GPIB queries do not support binary transfer.
;
;                   See _viExecCommand for more details
;
; ===============================================================================================================================
Func __viQueryf($h_session, $s_query, $i_timeout_ms = -1)
	Local $f_close_session_before_return = 0 ; By default do not close the session at the end
	If IsString($h_session) Then
		; When we pass a string, i.e. a VISA ID (like GPIB::20::0, for instance) instead
		; of a VISA session handler, we will automatically OPEN and CLOSE the instrument
		; session for the user.
		; This is of course slower if you need to do more than one GPIB call but much
		; more convenient for short tests
		$f_close_session_before_return = 1
		$h_session = _viOpen($h_session)
	EndIf

	;- Set the VISA timeout if necessary
	If $i_timeout_ms >= 0 Then
		_viSetTimeout($h_session, $i_timeout_ms)
	EndIf

	;- Send QUERY to instrument and get ANSWER
	; errStatus = viQueryf (h_session, "*IDN?\n", "%s", s_answer);
	; signed int viQueryf (unsigned long, char*, char*, char*);
	;errStatus = viQueryf (h_instr, s_command, "%s", string);
	Local $a_results, $s_answer = ""
	$a_results = DllCall("visa32.dll", "int:cdecl", "viQueryf", "int", $h_session, "str", $s_query, "str", "%t", "str", $s_answer)
	If @error Then Return SetError(@error, @extended, -1)
	Local $errStatus = $a_results[0]
	If $errStatus <> 0 Then
		; Could not query VISA instrument/resource
		;MsgBox(16,"VISA error","Could not query VISA instrument/resource: " & $h_session)
		Return SetError(1, 0, $errStatus)
	EndIf
	; Make sure that the DllCall returned enough values
	If UBound($a_results) < 5 Then
		; Call to viQuery did not return the right number of values
		;MsgBox(16,"VISA error","Call to viQuery did not return the right number of values")
		Return SetError(1, 0, -3)
	EndIf
	$s_answer = $a_results[4]

	If $f_close_session_before_return = 1 Then
		_viClose($h_session)
	EndIf

	Return $s_answer
EndFunc   ;==>__viQueryf

; #FUNCTION# ====================================================================================================================
;
; Description ...: Sets the VISA timeout in MILISECONDS (uses _viSetAttribute)
; Syntax.........: _viSetTimeout($h_session, $i_timeout_ms)
; Parameters ....: $h_session - A VISA descriptor (STRING) OR a VISA session
;                   handle (INTEGER). Look the explanation in _viExecCommand
;                   (you can find it above)
;                   $i_timeout_ms - The timeout IN MILISECONDS for VISA operations
;                   (mainly for GPIB queries)
;                   If you set it to 0 the tiemouts are DISABLED
;                   If you set it to "INF" the VISA operations will NEVER timeout.
;                   Be careful with this as it could easly hung your program if
;                   your instrument does not respond to one of your queries
;                   Depending on the bus type (GPIB, TCP, etc) the timeout might
;                   not be set to the exact value that you request. Instead the
;                   closest valid timeout bigger than the one that you requested
;                   will be used.
; Return values .: On Success - Returns 0
;                   On Failure - Returns -1 if the VISA DLL could not be open
;                                or a NON ZERO value representing the VISA
;                                error code (see the VISA programmer's guide)
;                   This function always sets @error to 1 in case of error
; Author ........: Angel Ezquerra <ezquerra at gmail dot com>
; Notes .........: You can avoid directly calling this function most of the time,
;                   as _viExecCommand accepts a timeout (in ms) as its 3rd argument.
;                   If you do not pass this 3rd argument then the previous timeout
;                   will be used (or the default timeout, which depends on the
;                   VISA driver, if it was never set before)
;
; ===============================================================================================================================
Func _viSetTimeout($h_session, $i_timeout_ms)
	If String($i_timeout_ms) = "INF" Then
		$i_timeout_ms = $VI_TMO_INFINITE
	EndIf
	Return _viSetAttribute($h_session, $VI_ATTR_TMO_VALUE, $i_timeout_ms)
EndFunc   ;==>_viSetTimeout

; #FUNCTION# ====================================================================================================================
;
; Description ...: VISA attribute set (GENERIC)
;                   Called by _viSetTimeout, this function can ALSO be used to
;                   set many other VISA specific attributes, like the Serial
;                   Interface Attributes.
;                   Read the VISA documentation for more information
; Syntax.........: _viSetAttribute($h_session, $i_attribute, $i_value)
; Parameters ....: $h_session - A VISA descriptor (STRING) OR a VISA session
;                   handle (INTEGER). Look the explanation in _viExecCommand
;                   (you can find it above)
;                   $i_attribute - The index of the attribute that must be changed
;                   Attributes are defined in the VISA library. This AutoIt
;                   implementation only defines a CONSTANT for the TIMEOUT
;                   attribute ($VI_ATTR_TMO_VALUE) but you can pass any other
;                   index if you want to.
;                   $i_value - The value of the attribute. It must be an integer
;                   and the possible values depend on the attribute type
; Return values .: On Success - Returns 0
;                   On Failure - Returns -1 if the VISA DLL could not be open
;                                or a NON ZERO value representing the VISA
;                                error code (see the VISA programmer's guide)
;                   This function always sets @error to 1 in case of error
; Author ........: Angel Ezquerra <ezquerra at gmail dot com>
; Notes .........:
;                   This is a list of the currently pre-defined attributes and
;                   values. Remember that you can use any other valid
;                   attribute/value by passing the corresponding integer index
;                   (as defined in the VISA programmer's guide) to this function.
;
;                   * Attribute: $VI_ATTR_TMO_VALUE -> Set Timeout
;                   * Values:
;                             A timeout in MILLISECONDS or
;                             $VI_TMO_IMMEDIATE (or 0) for "Return immediatly"
;                             VI_TMO_INFINITE (or "INF") for "No timeout"
;
;                   * Attribute: $VI_ATTR_TERMCHAR -> Set Termination Character
;                   * Values:
;                             The ASCII code number of the terminator character
;                             which is used for VISA messages.
;                             - Typical values are:
;                                0x0A: Linefeed or newline ("\n")
;                                0x0C: Form feed ("\f")
;                                0x0D: Carriage return ("\r")
;
;                   * Attribute: $VI_ATTR_TERMCHAR_EN -> Set Termination Character
;                   * Values:
;                             For many instruments this attribute has no effect.
;                             For those who take it into account:
;                             $VI_FALSE: Wait for the TIMEOUT before returning from
;                                        a viRead operation
;                             $VI_TRUE: Allow read operations to terminate as soon
;                                       as the "VI_ATTR_TERMCHAR" character is received
;                                       during a viRead.
;                             which is used for VISA messages (e.g. 10)
;                             $VI_TMO_IMMEDIATE (or 0) for "Return immediatly"
;                             VI_TMO_INFINITE (or "INF") for "No timeout"
;                   * Default Value: $VI_FALSE. Note that many instruments ignore this.
;
;                   * Attribute: $VI_ATTR_ASRL_BAUD
;                   * Values:
;                             Any valid baudrate (9600, 115200, etc)
;
;                   * Attribute: $VI_ATTR_ASRL_DATA_BITS
;                   * Values:
;                             From 5 to 8
;
;                   * Attribute: $VI_ATTR_ASRL_PARITY
;                   * Values:
;                             $VI_ASRL_PAR_NONE
;                             $VI_ASRL_PAR_ODD
;                             $VI_ASRL_PAR_EVEN
;                             $VI_ASRL_PAR_MARK
;                             $VI_ASRL_PAR_SPACE
;
;                   * Attribute: $VI_ATTR_ASRL_STOP_BITS
;                   * Values:
;                             $VI_ASRL_STOP_ONE
;                             $VI_ASRL_STOP_ONE5
;                             $VI_ASRL_STOP_TWO
;
;                   * Attribute: $VI_ATTR_ASRL_FLOW_CNTRL
;                   * Values:
;                             $VI_ASRL_FLOW_NONE
;                             $VI_ASRL_FLOW_XON_XOFF
;                             $VI_ASRL_FLOW_RTS_CTS
;                             $VI_ASRL_FLOW_DTR_DSR


;
; ===============================================================================================================================
Func _viSetAttribute($h_session, $i_attribute, $i_value)
	Local $f_close_session_before_return = 0 ; By default do not close the session at the end
	If IsString($h_session) Then
		; When we pass a string, i.e. a VISA ID (like GPIB::20::0, for instance) instead
		; of a VISA session handler, we will automatically OPEN and CLOSE the instrument
		; session for the user.
		; This is of course slower if you need to do more than one GPIB call but much
		; more convenient for short tests
		$f_close_session_before_return = 1
		$h_session = _viOpen($h_session)
	EndIf

	; errStatus = _viSetAttribute ($h_session, $VI_ATTR_TMO_VALUE, $timeout_value);
	; signed int viGpibControlREN (unsigned long, int, int);
	Local $a_results
	$a_results = DllCall("visa32.dll", "int", "viSetAttribute", "int", $h_session, "int", $i_attribute, "int", $i_value)
	If @error Then Return SetError(@error, @extended, -1)
	Local $errStatus = $a_results[0]
	If $errStatus <> 0 Then
		; Could not set attribute of VISA instrument/resource
		;MsgBox(16,"VISA error","Could not set attribute of VISA instrument/resource: " & $h_session)
		Return SetError(1, 0, $errStatus)
	EndIf

	If $f_close_session_before_return = 1 Then
		_viClose($h_session)
	EndIf

	Return 0
EndFunc   ;==>_viSetAttribute

; #FUNCTION# ====================================================================================================================
;
; Description ...: Go To Local mode (uses _viGpibControlREN)
;                   Instruments that accept this command will exit the "Remote
;                   Control mode" and go to "Local mode"
;                   If the instrument is already in "Local mode" this is simply
;                   ignored.
;                   Normally, if an instrument does not support this command it
;                   will simply stay in the "Remote Control mode"
; Syntax.........: _viGTL($h_session)
; Parameters ....: $h_session - A VISA descriptor (STRING) OR a VISA session
;                   handle (INTEGER). Look the explanation in _viExecCommand
;                   (you can find it above)
; Return values .: On Success - Returns 0
;                   On Failure - Returns -1 if the VISA DLL could not be open
;                                or a NON ZERO value representing the VISA
;                                error code (see the VISA programmer's guide)
;                   This function always sets @error to 1 in case of error
; Author ........: Angel Ezquerra <ezquerra at gmail dot com>
; Notes .........: None
;
; ===============================================================================================================================
Func _viGTL($h_session)
	Return __viGpibControlREN($h_session, $VI_GPIB_REN_ADDRESS_GTL)
EndFunc   ;==>_viGTL

; #FUNCTION# ====================================================================================================================
;
; Description ...: GPIB BUS "reset" (uses _viGpibControlREN)
;                   Use this function when the GPIB BUS gets stuck for some reason.
;                   You might be lucky and resolve the problem by calling this
;                   function
; Syntax.........: _viGpibBusReset()
; Parameters ....: None
; Return values .: On Success - Returns 0
;                   On Failure - Returns -1 if the VISA DLL could not be open
;                                or a NON ZERO value representing the VISA
;                                error code (see the VISA programmer's guide)
;                   This function always sets @error to 1 in case of error
; Author ........: Angel Ezquerra <ezquerra at gmail dot com>
; Notes .........: None
;
; ===============================================================================================================================
Func _viGpibBusReset()
	Return __viGpibControlREN("GPIB0::INTFC", $VI_GPIB_REN_DEASSERT)
EndFunc   ;==>_viGpibBusReset

; #INTERNAL_USE_ONLY# ===========================================================================================================
;
; Description ...: Control the VISA REN bus line
; Syntax.........: __viGpibControlREN ($h_session, $i_mode)
; Parameters ....: $h_session - A VISA descriptor (STRING) OR a VISA session
;                   handle (INTEGER). Look the explanation in _viExecCommand
;                   (you can find it above)
;                   $i_mode - The mode into which the REN line of the GPIB bus
;                   will be set.
;                   Modes are defined in the VISA library. Look at the top of
;                   this file for valid modes
; Return values .: On Success - Returns 0
;                   On Failure - Returns -1 if the VISA DLL could not be open
;                                or a NON ZERO value representing the VISA
;                                error code (see the VISA programmer's guide)
;                   This function always sets @error to 1 in case of error
; Author ........: Angel Ezquerra <ezquerra at gmail dot com>
; Notes .........: This function is used by _viGTL and _viGpibBusReset
;
; ===============================================================================================================================
Func __viGpibControlREN($h_session, $i_mode)
	Local $f_close_session_before_return = 0 ; By default do not close the session at the end
	If IsString($h_session) Then
		; When we pass a string, i.e. a VISA ID (like GPIB::20::0, for instance) instead
		; of a VISA session handler, we will automatically OPEN and CLOSE the instrument
		; session for the user.
		; This is of course slower if you need to do more than one GPIB call but much
		; more convenient for short tests
		$f_close_session_before_return = 1
		$h_session = _viOpen($h_session)
	EndIf

	; errStatus = viGpibControlREN ($h_session, VI_GPIB_REN_ASSERT);
	; signed int viGpibControlREN (unsigned long, int);
	Local $a_results
	$a_results = DllCall("visa32.dll", "int", "viGpibControlREN", "int", $h_session, "int", $i_mode)
	If @error Then Return SetError(@error, @extended, -1)
	Local $errStatus = $a_results[0]
	If $errStatus <> 0 Then
		; Could not send to Local VISA instrument/resource
		;MsgBox(16,"VISA error","Could not send to Local VISA instrument/resource: " & $h_session)
		Return SetError(1, 0, $errStatus)
	EndIf

	If $f_close_session_before_return = 1 Then
		_viClose($h_session)
	EndIf

	Return 0
EndFunc   ;==>__viGpibControlREN

; #FUNCTION# ====================================================================================================================
;
; Description ...: Interactive VISA control.
;                   This function lets you easily test your SCPI commands
;                   interactively.
;                   It also lets you save these commands into a file
;                   Simply answer the questions (Device Descriptor, SCPI command
;                   and timeout).
;                   * If you click Cancel on the 1st question the interactive
;                     control ends.
;                   * If you click Cancel to the other queries, you will go back
;                     to the Device Descriptor question.
; Syntax.........: _viInteractiveControl($s_command_save_filename = "")
; Parameters ....: $s_command_save_filename - This is an OPTIONAL PARAMETER
;                     The name of the file in which the SCPI commands issued
;                     during the interactive session will be saved.
;                     If no filename is passed the funcion asks the user if and
;                     where does the user want to save the issued commands.
; Return values .: The list of AutoIt3 VISA commands that were executed by the tool.
;                   This is the same list that is saved into the file if the a
;                   filename is passed to the function.
; Author ........: Angel Ezquerra <ezquerra at gmail dot com>
; Notes .........: Type "FIND" in the Device Descriptor query to perform a GPIB
;                   search
;
; ===============================================================================================================================
Func _viInteractiveControl($s_command_save_filename = "")
	;- Define variables, set their default values
	Local $s_vi_id = "FIND" ; "GPIB::1::0" ; Default values
	Local $s_command = "*IDN?"
	Local $i_timeout_ms = 10000 ; ms
	Local $s_answer = ""
	Local $a_descriptor_list[1], $a_idn_list[1] ; The results of the GPIB search
	; The variables used to save the commands to a file
	Local $s_empty_command_list = "#include <Visa.au3>" & @CR & @CR & "Local $s_answer" & @CR & @CR
	Local $s_new_command = ""
	Local $s_command_list = $s_empty_command_list

	;- Loop until the user Cancles the Instrument Device Descriptor request
	While 1
		;- Request the Instrument Descriptor (reuse the previous descriptor)
		$s_vi_id = InputBox("Instrument Device Descriptor", _
				"- Type the Instrument Device Descriptor (e.g. 'GPIB::1::0' or 'GPIB::1::INSTR')" & _
				@CR & @CR & _
				"- Type FIND to perform a GPIB search" & _
				@CR & @CR & _
				"- Click CANCEL to STOP the VISA interactive tool", $s_vi_id, "", 500, 250)
		If @error = 1 Then
			; The Cancel button was pushed -> Exit the loop
			ExitLoop
		EndIf
		If $s_vi_id = "FIND" Then
			; Perform a GPIB search
			$s_command_list = $s_command_list & _
					"Local $a_descriptor_list[1], $a_idn_list[1]" & @CR & @CR & _
					"_viFindGpib($a_descriptor_list, $a_idn_list, 1)" & @CR & @CR
			_viFindGpib($a_descriptor_list, $a_idn_list, 1)
			If UBound($a_descriptor_list) >= 1 Then
				; If an instrument was found, use the 1st found instrument as the default
				; for the next query
				$s_vi_id = $a_descriptor_list[0]
			EndIf
			ContinueLoop
		EndIf

		;- Request the command that must be executed (reuse the previous command)
		$s_answer = InputBox("SCPI command", "Type the SCPI command", $s_command)
		If @error = 1 Then
			; The Cancel button was pushed -> Restart the process
			ContinueLoop
		EndIf
		$s_command = $s_answer ; We got a valid command

		;- Request the timeout (reuse the previous timout)
		$s_answer = InputBox("Command Timeout (ms)", _
				"Type the command timeout (in milliseconds)", $i_timeout_ms)
		If @error = 1 Then
			; The Cancel button was pushed -> Restart the process
			ContinueLoop
		EndIf
		$i_timeout_ms = 0 + $s_answer ; We got a valid timeout

		;- Add the command to the command list
		$s_new_command = '$s_answer = _viExecCommand("' & $s_vi_id & '", "' & _
				$s_command & '", ' & $i_timeout_ms & ')'
		$s_command_list = $s_command_list & $s_new_command & @CR

		;- Execute the requested command
		$s_answer = _viExecCommand($s_vi_id, $s_command, $i_timeout_ms)

		If IsString($s_answer) Then
			;- The command was a query and the instrument answered it
			; Show the query results
			MsgBox(64, "Query results", "[" & $s_vi_id & "] " & $s_command & " -> " & $s_answer)
		ElseIf $s_answer = 0 Then
			;- The command was not a query but it was exuced successfully
			MsgBox(64, "Command result", "The command:" & @CR & @CR & _
					"         '" & $s_command & "'" & @CR & @CR & _
					"was SUCCESSFULLY executed on the device: " & @CR & @CR & _
					"         '" & $s_vi_id & "'")
		ElseIf $s_answer < 0 Then
			;- There was an error -> Show an error message
			$s_answer = MsgBox(16 + 4, "VISA Error", _
					"There was a VISA error when executing the command:" & @CR & @CR & _
					"'" & $s_command & "'" & @CR & @CR & "on the Device '" & $s_vi_id & "'" & _
					@CR & @CR & _
					"Do you want to RESET the GPIB bus before continuing?")
			If $s_answer = 6 Then ; Yes
				_viGpibBusReset()
				MsgBox(0, "VISA", "The GPIB bus was RESET!")
			EndIf
		EndIf
	WEnd

	If $s_command_list <> $s_empty_command_list Then
		; If at least one command was issued we might want to save the file

		If $s_command_save_filename = "" Then
			; The user did not pass an explicit file name in which to save the commands
			; Ask him if he wants to save the m now
			$s_answer = MsgBox(64 + 4, "Save commands to AutoIt3 script?", _
					"Do you want to save the commands that you issued into an AutoIt3 script?")
			If $s_answer = 6 Then ; Yes
				$s_command_save_filename = FileSaveDialog("Save as...", @ScriptDir, _
						"AutoIt3 scripts (*.au3)", 16, "visa_log.au3")
				If @error <> 0 Then
					$s_command_save_filename = ""
				EndIf
			EndIf
		EndIf

		If $s_command_save_filename <> "" Then
			;- Save the SCPI commands into a file
			If FileExists($s_command_save_filename) Then
				; Delete the save file if it already exists
				FileDelete($s_command_save_filename)
			EndIf
			FileWrite($s_command_save_filename, $s_command_list)
		EndIf
	EndIf

	Return $s_command_list ; Return the list of executed commands
EndFunc   ;==>_viInteractiveControl
