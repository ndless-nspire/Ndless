#include-once

#include "GDIPlus.au3"
#include "WinAPI.au3"

; #INDEX# =======================================================================================================================
; Title .........: ScreenCapture
; AutoIt Version : 3.3.7.20++
; Language ......: English
; Description ...: Functions that assist with Screen Capture management.
;                  This module allows you to copy the screen or a region of the screen and save it to file. Depending on the type
;                  of image, you can set various image parameters such as pixel format, quality and compression.
; Author(s) .....: Paul Campbell (PaulIA)
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $giBMPFormat = $GDIP_PXF24RGB
Global $giJPGQuality = 100
Global $giTIFColorDepth = 24
Global $giTIFCompression = $GDIP_EVTCOMPRESSIONLZW
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__SCREENCAPTURECONSTANT_SM_CXSCREEN = 0
Global Const $__SCREENCAPTURECONSTANT_SM_CYSCREEN = 1
Global Const $__SCREENCAPTURECONSTANT_SRCCOPY = 0x00CC0020
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_ScreenCapture_Capture
;_ScreenCapture_CaptureWnd
;_ScreenCapture_SaveImage
;_ScreenCapture_SetBMPFormat
;_ScreenCapture_SetJPGQuality
;_ScreenCapture_SetTIFColorDepth
;_ScreenCapture_SetTIFCompression
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _ScreenCapture_Capture
; Description ...: Captures a region of the screen
; Syntax.........: _ScreenCapture_Capture([$sFileName = ""[, $iLeft = 0[, $iTop = 0[, $iRight = -1[, $iBottom = -1[, $fCursor = True]]]]]])
; Parameters ....: $sFileName   - Full path and extension of the image file
;                  $iLeft       - X coordinate of the upper left corner of the rectangle
;                  $iTop        - Y coordinate of the upper left corner of the rectangle
;                  $iRight      - X coordinate of the lower right corner of the rectangle.  If this is  -1,  the  current  screen
;                  +width will be used.
;                  $iBottom     - Y coordinate of the lower right corner of the rectangle.  If this is  -1,  the  current  screen
;                  +height will be used.
;                  $fCursor     - If True the cursor will be captured with the image
; Return values .: See remarks
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: If FileName is not blank this function will capture the screen and save it to file. If FileName is blank, this
;                  function will capture the screen and return a HBITMAP handle to the bitmap image.  In this case, after you are
;                  finished with the bitmap you must call _WinAPI_DeleteObject to delete the bitmap handle.
;+
;                  Requires GDI+: GDI+ requires a redistributable for applications  that
;                  run on the Microsoft Windows NT 4.0 SP6, Windows 2000, Windows 98, and Windows Me operating systems.
; Related .......: _WinAPI_DeleteObject, _ScreenCapture_SaveImage
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ScreenCapture_Capture($sFileName = "", $iLeft = 0, $iTop = 0, $iRight = -1, $iBottom = -1, $fCursor = True)
	If $iRight = -1 Then $iRight = _WinAPI_GetSystemMetrics($__SCREENCAPTURECONSTANT_SM_CXSCREEN)
	If $iBottom = -1 Then $iBottom = _WinAPI_GetSystemMetrics($__SCREENCAPTURECONSTANT_SM_CYSCREEN)
	If $iRight < $iLeft Then Return SetError(-1, 0, 0)
	If $iBottom < $iTop Then Return SetError(-2, 0, 0)

	Local $iW = ($iRight - $iLeft) + 1
	Local $iH = ($iBottom - $iTop) + 1
	Local $hWnd = _WinAPI_GetDesktopWindow()
	Local $hDDC = _WinAPI_GetDC($hWnd)
	Local $hCDC = _WinAPI_CreateCompatibleDC($hDDC)
	Local $hBMP = _WinAPI_CreateCompatibleBitmap($hDDC, $iW, $iH)
	_WinAPI_SelectObject($hCDC, $hBMP)
	_WinAPI_BitBlt($hCDC, 0, 0, $iW, $iH, $hDDC, $iLeft, $iTop, $__SCREENCAPTURECONSTANT_SRCCOPY)

	If $fCursor Then
		Local $aCursor = _WinAPI_GetCursorInfo()
		If $aCursor[1] Then
			Local $hIcon = _WinAPI_CopyIcon($aCursor[2])
			Local $aIcon = _WinAPI_GetIconInfo($hIcon)
			_WinAPI_DeleteObject($aIcon[4]) ; delete bitmap mask return by _WinAPI_GetIconInfo()
			If $aIcon[5] <> 0 Then _WinAPI_DeleteObject($aIcon[5]); delete bitmap hbmColor return by _WinAPI_GetIconInfo()
			_WinAPI_DrawIcon($hCDC, $aCursor[3] - $aIcon[2] - $iLeft, $aCursor[4] - $aIcon[3] - $iTop, $hIcon)
			_WinAPI_DestroyIcon($hIcon)
		EndIf
	EndIf

	_WinAPI_ReleaseDC($hWnd, $hDDC)
	_WinAPI_DeleteDC($hCDC)
	If $sFileName = "" Then Return $hBMP

	Local $ret = _ScreenCapture_SaveImage($sFileName, $hBMP, True)
	Return SetError(@error, @extended, $ret)
EndFunc   ;==>_ScreenCapture_Capture

; #FUNCTION# ====================================================================================================================
; Name...........: _ScreenCapture_CaptureWnd
; Description ...: Captures a screen shot of a specified window or controlID
; Syntax.........: _ScreenCapture_CaptureWnd($sFileName, $hWnd[, $iLeft = 0[, $iTop = 0[, $iRight = -1[, $iBottom = -1[, $fCursor = True]]]]])
; Parameters ....: $sFileName   - Full path and extension of the image file
;                  $hWnd        - Handle to the window to be captured
;                  $iLeft       - X coordinate of the upper left corner of the client rectangle
;                  $iTop        - Y coordinate of the upper left corner of the client rectangle
;                  $iRight      - X coordinate of the lower right corner of the rectangle
;                  $iBottom     - Y coordinate of the lower right corner of the rectangle
;                  $fCursor     - If True the cursor will be captured with the image
; Return values .: See remarks
; Author ........: Paul Campbell (PaulIA)
; Modified.......: jpm based on Kafu
; Remarks .......: If FileName is not blank this function will capture the screen and save it to file. If FileName is blank, this
;                  function will capture the screen and return a HBITMAP handle to the bitmap image.  In this case, after you are
;                  finished with the bitmap you must call _WinAPI_DeleteObject to delete the bitmap handle.  All coordinates are  in
;                  client coordinate mode.
;+
;                  Requires GDI+: GDI+ requires a redistributable for applications  that
;                  run on the Microsoft Windows NT 4.0 SP6, Windows 2000, Windows 98, and Windows Me operating systems.
; Related .......: _WinAPI_DeleteObject
; Link ..........:
; Example .......: Yes
; Credits .......: Thanks to SmOke_N for his suggestion for capturing part of the client window
; ===============================================================================================================================
Func _ScreenCapture_CaptureWnd($sFileName, $hWnd, $iLeft = 0, $iTop = 0, $iRight = -1, $iBottom = -1, $fCursor = True)
	If Not IsHWnd($hWnd) Then $hWnd = WinGetHandle($hWnd)
	Local $tRect = DllStructCreate($tagRECT)
	; needed to get rect when Aero theme is active : Thanks Kafu, Zedna
	Local Const $DWMWA_EXTENDED_FRAME_BOUNDS = 9
	Local $bRet = DllCall("dwmapi.dll", "long", "DwmGetWindowAttribute", "hwnd", $hWnd, "dword", $DWMWA_EXTENDED_FRAME_BOUNDS, "struct*", $tRect, "dword", DllStructGetSize($tRect))
	If (@error Or $bRet[0] Or (Abs(DllStructGetData($tRect, "Left")) + Abs(DllStructGetData($tRect, "Top")) + _
			Abs(DllStructGetData($tRect, "Right")) + Abs(DllStructGetData($tRect, "Bottom"))) = 0) Then
		$tRect = _WinAPI_GetWindowRect($hWnd)
		If @error Then Return SetError(@error, @extended, 0)
	EndIf

	$iLeft += DllStructGetData($tRect, "Left")
	$iTop += DllStructGetData($tRect, "Top")
	If $iRight = -1 Then $iRight = DllStructGetData($tRect, "Right") - DllStructGetData($tRect, "Left") - 1
	If $iBottom = -1 Then $iBottom = DllStructGetData($tRect, "Bottom") - DllStructGetData($tRect, "Top") - 1
	$iRight += DllStructGetData($tRect, "Left")
	$iBottom += DllStructGetData($tRect, "Top")
	If $iLeft > DllStructGetData($tRect, "Right") Then $iLeft = DllStructGetData($tRect, "Left")
	If $iTop > DllStructGetData($tRect, "Bottom") Then $iTop = DllStructGetData($tRect, "Top")
	If $iRight > DllStructGetData($tRect, "Right") Then $iRight = DllStructGetData($tRect, "Right") - 1
	If $iBottom > DllStructGetData($tRect, "Bottom") Then $iBottom = DllStructGetData($tRect, "Bottom") - 1
	Return _ScreenCapture_Capture($sFileName, $iLeft, $iTop, $iRight, $iBottom, $fCursor)
EndFunc   ;==>_ScreenCapture_CaptureWnd

; #FUNCTION# ====================================================================================================================
; Name...........: _ScreenCapture_SaveImage
; Description ...: Saves an image to file
; Syntax.........: _ScreenCapture_SaveImage($sFileName, $hBitmap[, $fFreeBmp = True])
; Parameters ....: $sFileName   - Full path and extension of the bitmap file to be saved
;                  $hBitmap     - HBITMAP handle
;                  $fFreeBmp    - If True, hBitmap will be freed on a successful save
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function saves a bitmap to file, converting it to the image format specified by the file name  extension.
;                  For Windows XP, the valid extensions are BMP, GIF, JPEG, PNG and TIF.
;+
;                  Requires GDI+: GDI+ requires a redistributable for applications  that
;                  run on the Microsoft Windows NT 4.0 SP6, Windows 2000, Windows 98, and Windows Me operating systems.
; Related .......: _ScreenCapture_Capture
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ScreenCapture_SaveImage($sFileName, $hBitmap, $fFreeBmp = True)
	_GDIPlus_Startup()
	If @error Then Return SetError(-1, -1, False)

	Local $sExt = StringUpper(__GDIPlus_ExtractFileExt($sFileName))
	Local $sCLSID = _GDIPlus_EncodersGetCLSID($sExt)
	If $sCLSID = "" Then Return SetError(-2, -2, False)
	Local $hImage = _GDIPlus_BitmapCreateFromHBITMAP($hBitmap)
	If @error Then Return SetError(-3, -3, False)

	Local $tData, $tParams
	Switch $sExt
		Case "BMP"
			Local $iX = _GDIPlus_ImageGetWidth($hImage)
			Local $iY = _GDIPlus_ImageGetHeight($hImage)
			Local $hClone = _GDIPlus_BitmapCloneArea($hImage, 0, 0, $iX, $iY, $giBMPFormat)
			_GDIPlus_ImageDispose($hImage)
			$hImage = $hClone
		Case "JPG", "JPEG"
			$tParams = _GDIPlus_ParamInit(1)
			$tData = DllStructCreate("int Quality")
			DllStructSetData($tData, "Quality", $giJPGQuality)
			_GDIPlus_ParamAdd($tParams, $GDIP_EPGQUALITY, 1, $GDIP_EPTLONG, DllStructGetPtr($tData))
		Case "TIF", "TIFF"
			$tParams = _GDIPlus_ParamInit(2)
			$tData = DllStructCreate("int ColorDepth;int Compression")
			DllStructSetData($tData, "ColorDepth", $giTIFColorDepth)
			DllStructSetData($tData, "Compression", $giTIFCompression)
			_GDIPlus_ParamAdd($tParams, $GDIP_EPGCOLORDEPTH, 1, $GDIP_EPTLONG, DllStructGetPtr($tData, "ColorDepth"))
			_GDIPlus_ParamAdd($tParams, $GDIP_EPGCOMPRESSION, 1, $GDIP_EPTLONG, DllStructGetPtr($tData, "Compression"))
	EndSwitch
	Local $pParams = 0
	If IsDllStruct($tParams) Then $pParams = $tParams

	Local $iRet = _GDIPlus_ImageSaveToFileEx($hImage, $sFileName, $sCLSID, $pParams)
	_GDIPlus_ImageDispose($hImage)
	If $fFreeBmp Then _WinAPI_DeleteObject($hBitmap)
	_GDIPlus_Shutdown()

	Return SetError($iRet = False, 0, $iRet = True)
EndFunc   ;==>_ScreenCapture_SaveImage

; #FUNCTION# ====================================================================================================================
; Name...........: _ScreenCapture_SetBMPFormat
; Description ...: Sets the bit format that will be used for BMP screen captures
; Syntax.........: _ScreenCapture_SetBMPFormat($iFormat)
; Parameters ....: $iFormat     - Image bits per pixel (bpp) setting:
;                  |0 = 16 bpp; 5 bits for each RGB component
;                  |1 = 16 bpp; 5 bits for red, 6 bits for green and 5 bits blue
;                  |2 = 24 bpp; 8 bits for each RGB component
;                  |3 = 32 bpp; 8 bits for each RGB component. No alpha component.
;                  |4 = 32 bpp; 8 bits for each RGB and alpha component
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: If not explicitly set, BMP screen captures default to 24 bpp
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _ScreenCapture_SetBMPFormat($iFormat)
	Switch $iFormat
		Case 0
			$giBMPFormat = $GDIP_PXF16RGB555
		Case 1
			$giBMPFormat = $GDIP_PXF16RGB565
		Case 2
			$giBMPFormat = $GDIP_PXF24RGB
		Case 3
			$giBMPFormat = $GDIP_PXF32RGB
		Case 4
			$giBMPFormat = $GDIP_PXF32ARGB
		Case Else
			$giBMPFormat = $GDIP_PXF24RGB
	EndSwitch
EndFunc   ;==>_ScreenCapture_SetBMPFormat

; #FUNCTION# ====================================================================================================================
; Name...........: _ScreenCapture_SetJPGQuality
; Description ...: Sets the quality level that will be used for JPEG screen captures
; Syntax.........: _ScreenCapture_SetJPGQuality($iQuality)
; Parameters ....: $iQuality    - The quality level of the image. Must be in the range of 0 to 100.
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: If not explicitly set, JPEG screen captures default to a quality level of 100
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _ScreenCapture_SetJPGQuality($iQuality)
	If $iQuality < 0 Then $iQuality = 0
	If $iQuality > 100 Then $iQuality = 100
	$giJPGQuality = $iQuality
EndFunc   ;==>_ScreenCapture_SetJPGQuality

; #FUNCTION# ====================================================================================================================
; Name...........: _ScreenCapture_SetTIFColorDepth
; Description ...: Sets the color depth used for TIFF screen captures
; Syntax.........: _ScreenCapture_SetTIFColorDepth($iDepth)
; Parameters ....: $iDepth      - Image color depth:
;                  | 0 - Default encoder color depth
;                  |24 - 24 bit
;                  |32 - 32 bit
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: If not explicitly set, TIFF screen captures default to 24 bits
; Related .......: _ScreenCapture_SetTIFCompression
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _ScreenCapture_SetTIFColorDepth($iDepth)
	Switch $iDepth
		Case 24
			$giTIFColorDepth = 24
		Case 32
			$giTIFColorDepth = 32
		Case Else
			$giTIFColorDepth = 0
	EndSwitch
EndFunc   ;==>_ScreenCapture_SetTIFColorDepth

; #FUNCTION# ====================================================================================================================
; Name...........: _ScreenCapture_SetTIFCompression
; Description ...: Sets the compression used for TIFF screen captures
; Syntax.........: _ScreenCapture_SetTIFCompression($iCompress)
; Parameters ....: $iCompress   - Image compression type:
;                  |0 - Default encoder compression
;                  |1 - No compression
;                  |2 - LZW compression
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: If not explicitly set, TIF screen captures default to LZW compression
; Related .......: _ScreenCapture_SetTIFColorDepth
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _ScreenCapture_SetTIFCompression($iCompress)
	Switch $iCompress
		Case 1
			$giTIFCompression = $GDIP_EVTCOMPRESSIONNONE
		Case 2
			$giTIFCompression = $GDIP_EVTCOMPRESSIONLZW
		Case Else
			$giTIFCompression = 0
	EndSwitch
EndFunc   ;==>_ScreenCapture_SetTIFCompression
