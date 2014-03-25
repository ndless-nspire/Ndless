#include-once

; #INDEX# =======================================================================================================================
; Title .........: Mathematical calculations
; AutoIt Version : 3.0
; Language ......: English
; Description ...: Functions that assist with mathematical calculations.
; Author(s) .....: Valik, Gary Frost, ...
; ===============================================================================================================================

; #NO_DOC_FUNCTION# =============================================================================================================
; Not working/documented/implimented at this time
;
;_ATan2
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _ATan2()
; Description ...: Returns the standard position angle (in radians) to the point ($nX, $nY).
; Syntax.........: _ATan2(Const $nY, Const $nX )
; Parameters ....: $nY = y co-ordinate of the point to check.
;                  $nX = x co-ordinate of the point to check.
; Return values .: On Success: = Returns the angle, between 0 and 2 pi.
;                  On Failure: = Sets @Error and returns 0, which can be a valid responce, so check @Error first.
;                  @ERROR:     = 0 = No error.
;                                1 = $nY or $nX is not a number.
;                                2 = Point is at the origin.  Can not determine direction.
; Author ........: "Nutster" David Nuttall <danuttall at rocketmail dot com>
; Remarks .......: Angles start from right being 0, and increasing upward from there.  All angles are in radians.
; Example .......: MsgBox(4096, "ATan2() Test", "_ATan2( 3, 4 ) = " & _ATan2( 3, 4 ))
; ===============================================================================================================================
Func _ATan2(Const $nY, Const $nX)
	Const $nPi = 3.14159265358979323846264338328
	Local $nResult

	; Check if given numeric arguments
	If IsNumber($nY) = 0 Then
		SetError(1)
		Return 0
	ElseIf IsNumber($nX) = 0 Then
		SetError(1)
		Return 0
	EndIf
	If $nX = 0 Then
		If $nY > 0 Then
			$nResult = $nPi / 2.0
		ElseIf $nY < 0 Then
			$nResult = 3.0 * $nPi / 2.0
		Else
			SetError(2) ; no direction can be determined.
			Return 0
		EndIf
	ElseIf $nX < 0 Then
		$nResult = ATan($nY / $nX) + $nPi
	Else
		$nResult = ATan($nY / $nX)
	EndIf
	While $nResult < 0
		$nResult += 2.0 * $nPi
	WEnd
	Return $nResult
EndFunc   ;==>_ATan2

; #FUNCTION# ====================================================================================================================
; Name...........: _Degree()
; Description ...: Converts radians to degrees.
; Syntax.........: _Degree( $nRadians )
; Parameters ....: $nRadians   = Radians to be converted into degrees.
; Return values .: On Success: = Returns the degrees converted from radians.
;                  On Failure: = Returns a blank string.
;                  @ERROR:     = 0 = No error.
;                                1 = $nRadians is not a number.
; Author ........: Erifash <erifash at gmail dot com>
; Remarks .......: Multiplies instead of dividing.
; Example .......: MsgBox(4096, "_Degree() Test", "_Degree( 3.1415 ) = " & _Degree( 3.1415 ))
; ===============================================================================================================================
Func _Degree($nRadians)
	If IsNumber($nRadians) Then Return $nRadians * 57.2957795130823
	Return SetError(1, 0, "")
EndFunc   ;==>_Degree

; #FUNCTION# ====================================================================================================================
; Name...........:  _MathCheckDiv()
; Description ...:  Checks to see if numberA is divisable by numberB
; Parameters ....:  $i_NumA   - Dividend
;                   $i_NumB   - Divisor
; Return values .:  On Success - 1 if not evenly divisable
;                              - 2 if evenly divisable
;                   On Failure - -1 and @error = 1
; Author ........:  Wes Wolfe-Wolvereness <Weswolf at aol dot com>
; ===============================================================================================================================
Func _MathCheckDiv($i_NumA, $i_NumB = 2)
	If Number($i_NumA) = 0 Or Number($i_NumB) = 0 Or Int($i_NumA) <> $i_NumA Or Int($i_NumB) <> $i_NumB Then
		Return SetError(1, 0, -1)
	ElseIf Int($i_NumA / $i_NumB) <> $i_NumA / $i_NumB Then
		Return 1
	Else
		Return 2
	EndIf
EndFunc   ;==>_MathCheckDiv

; #FUNCTION# ====================================================================================================================
; Name...........: _Max()
; Description ...: Evaluates which of the two numbers is higher.
; Syntax.........: _Max( $nNum1, $nNum2 )
; Parameters ....: $nNum1      = First number
;                  $nNum2      = Second number
; Return values .: On Success: = Returns the higher of the two numbers
;                  On Failure: = Returns 0.
;                  @ERROR:     = 0 = No error.
;                                1 = $nNum1 isn't a number.
;                                2 = $nNum2 isn't a number.
; Author ........: Jeremy Landes <jlandes at landeserve dot com>
; Remarks .......: Works with floats as well as integers
;
; Example .......: MsgBox( 4096, "_Max() - Test", "_Max( 3.5, 10 )	= " & _Max( 3.5, 10 ) )
; ===============================================================================================================================
Func _Max($nNum1, $nNum2)
	; Check to see if the parameters are indeed numbers of some sort.
	If Not IsNumber($nNum1) Then Return SetError(1, 0, 0)
	If Not IsNumber($nNum2) Then Return SetError(2, 0, 0)

	If $nNum1 > $nNum2 Then
		Return $nNum1
	Else
		Return $nNum2
	EndIf
EndFunc   ;==>_Max

; #FUNCTION# ====================================================================================================================
; Name...........: _Min()
; Description ...: Evaluates which of the two numbers is lower.
; Syntax.........: _Min( $nNum1, $nNum2 )
; Parameters ....: $nNum1      = First number
;                  $nNum2      = Second number
; Return values .: On Success: = Returns the higher of the two numbers
;                  On Failure: = Returns 0.
;                  @ERROR:     = 0 = No error.
;                                1 = $nNum1 isn't a number.
;                                2 = $nNum2 isn't a number.
; Author ........: Jeremy Landes <jlandes at landeserve dot com>
; Remarks .......: Works with floats as well as integers
; Example .......: MsgBox( 4096, "_Min() - Test", "_Min( 3.5, 10 )	= " & _Min( 3.5, 10 ) )
; ===============================================================================================================================
Func _Min($nNum1, $nNum2)
	; Check to see if the parameters are indeed numbers of some sort.
	If (Not IsNumber($nNum1)) Then Return SetError(1, 0, 0)
	If (Not IsNumber($nNum2)) Then Return SetError(2, 0, 0)

	If $nNum1 > $nNum2 Then
		Return $nNum2
	Else
		Return $nNum1
	EndIf
EndFunc   ;==>_Min

; #FUNCTION# ====================================================================================================================
; Name...........: _Radian()
; Description ...: Converts degrees to radians.
; Syntax.........: _Radian( $nDegrees )
; Parameters ....: $nDegrees   = Degrees to be converted into radians.
; Return values .: On Success: = Returns the radians converted from degrees.
;                  On Failure: = Returns a blank string.
;                  @ERROR:     = 0 = No error.
;                                1 = $nDegrees is not a number.
; Author ........: Erifash <erifash at gmail dot com>
; Remarks .......: In mathmatics and physics, the radian is a unit of
;                  angle measurement. One radian is approximately
;                  57.2957795130823 degrees. To figure out that number,
;                  use the formula ( 180 / pi ). Because pi is used in
;                  the formula, the result is infinite in decimal places.
;                  The fact that AutoIt has a limited number of decimal
;                  places makes the result more innaccurate as you move
;                  down the decimal line. This is quite suitable for basic
;                  physics calculations though.
; Example .......: MsgBox(4096, "_Radian() Test", "_Radian( 35 ) = " & _Radian( 35 ))
; ===============================================================================================================================
Func _Radian($nDegrees)
	If Number($nDegrees) Then Return $nDegrees / 57.2957795130823
	Return SetError(1, 0, "")
EndFunc   ;==>_Radian
