#include-once

#include "ImageListConstants.au3"
#include "WinAPI.au3"
#include "StructureConstants.au3"
#include "ColorConstants.au3"

; #INDEX# =======================================================================================================================
; Title .........: ImageList
; AutoIt Version : 3.3.7.20++
; Description ...: Functions that assist with ImageList control management.
;                  An image list is a collection of images of the same size, each of which can be referred to by its index. Image
;                  lists are used to efficiently manage large sets of icons or bitmaps. All images in an image list are contained
;                  in a single, wide bitmap in screen device format.  An image list can also include  a  monochrome  bitmap  that
;                  contains masks used to draw images transparently (icon style).
; Author(s)......: Paul Campbell (PaulIA)
; Dll(s) ........: comctl32.dll
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__IMAGELISTCONSTANT_IMAGE_BITMAP = 0
Global Const $__IMAGELISTCONSTANT_LR_LOADFROMFILE = 0x0010
; ===============================================================================================================================

; #NO_DOC_FUNCTION# =============================================================================================================
; Not documented at this time
;
;_GUIImageList_DragShowNolock
;_GUIImageList_Merge
;_GUIImageList_Replace
;_GUIImageList_SetDragCursorImage
;_GUIImageList_SetOverlayImage
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_GUIImageList_Add
;_GUIImageList_AddMasked
;_GUIImageList_AddBitmap
;_GUIImageList_AddIcon
;_GUIImageList_BeginDrag
;_GUIImageList_Copy
;_GUIImageList_Create
;_GUIImageList_Destroy
;_GUIImageList_DestroyIcon
;_GUIImageList_DragEnter
;_GUIImageList_DragLeave
;_GUIImageList_DragMove
;_GUIImageList_Draw
;_GUIImageList_DrawEx
;_GUIImageList_Duplicate
;_GUIImageList_EndDrag
;_GUIImageList_GetBkColor
;_GUIImageList_GetIcon
;_GUIImageList_GetIconHeight
;_GUIImageList_GetIconSize
;_GUIImageList_GetIconSizeEx
;_GUIImageList_GetIconWidth
;_GUIImageList_GetImageCount
;_GUIImageList_GetImageInfoEx
;_GUIImageList_Remove
;_GUIImageList_ReplaceIcon
;_GUIImageList_SetBkColor
;_GUIImageList_SetIconSize
;_GUIImageList_SetImageCount
;_GUIImageList_Swap
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_Add
; Description ...: Adds an image or images to an image list
; Syntax.........: _GUIImageList_Add($hWnd, $hImage[, $hMask=0])
; Parameters ....: $hWnd        - Handle to the control
;                  $hImage      - Handle to the bitmap that contains the image or images.  The number of images is inferred  from
;                  +the width of the bitmap.
;                  $hMask       - Handle to the bitmap that contains the mask
; Return values .: Success      - The index of the first new image
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function copies the bitmap to an internal data structure.  Be sure to use the _WinAPI_DeleteObject  function
;                  to delete hImage and hMask after the function returns.
; Related .......:  _GUIImageList_AddMasked, _GUIImageList_AddBitmap, _GUIImageList_AddIcon
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_Add($hWnd, $hImage, $hMask = 0)
	Local $aResult = DllCall("comctl32.dll", "int", "ImageList_Add", "handle", $hWnd, "handle", $hImage, "handle", $hMask)
	If @error Then Return SetError(@error, @extended, -1)
	Return $aResult[0]
EndFunc   ;==>_GUIImageList_Add

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_AddMasked
; Description ...: Adds an image or images to an image list, generating a mask from the specified bitmap
; Syntax.........: _GUIImageList_AddMasked($hWnd, $hImage[, $iMask=0])
; Parameters ....: $hWnd        - Handle to the control
;                  $hImage      - Handle to the bitmap that contains the image or images.  The number of images is inferred  from
;                  +the width of the bitmap.
;                  $iMask       - Color used to generate the mask. Each pixel of this color in the specified bitmap is changed to
;                  +black, and the corresponding bit in the mask is set to 1.
; Return values .: Success      - The index of the first new image
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function copies the bitmap to an internal data structure.  Be sure to use the _WinAPI_DeleteObject  function
;                  to delete hImage after the function returns. Bitmaps with color depth greater than 8 bpp are not supported.
; Related .......:  _GUIImageList_Add
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_AddMasked($hWnd, $hImage, $iMask = 0)
	Local $aResult = DllCall("comctl32.dll", "int", "ImageList_AddMasked", "handle", $hWnd, "handle", $hImage, "dword", $iMask)
	If @error Then Return SetError(@error, @extended, -1)
	Return $aResult[0]
EndFunc   ;==>_GUIImageList_AddMasked

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_AddBitmap
; Description ...: Adds a bitmap to an image list
; Syntax.........: _GUIImageList_AddBitmap($hWnd, $sImage[, $sMask=""])
; Parameters ....: $hWnd        - Handle to the control
;                  $sImage      - Path to the bitmap that contains the image
;                  $sMask       - Path to the bitmap that contains the mask
; Return values .: Success      - The index of the image
;                  Failrue      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUIImageList_Add, _GUIImageList_AddIcon
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_AddBitmap($hWnd, $sImage, $sMask = "")
	Local $aSize = _GUIImageList_GetIconSize($hWnd)
	Local $hImage = _WinAPI_LoadImage(0, $sImage, $__IMAGELISTCONSTANT_IMAGE_BITMAP, $aSize[0], $aSize[1], $__IMAGELISTCONSTANT_LR_LOADFROMFILE)
	If $hImage = 0 Then Return SetError(_WinAPI_GetLastError(), 1, -1)
	Local $hMask = 0
	If $sMask <> "" Then
		$hMask = _WinAPI_LoadImage(0, $sMask, $__IMAGELISTCONSTANT_IMAGE_BITMAP, $aSize[0], $aSize[1], $__IMAGELISTCONSTANT_LR_LOADFROMFILE)
		If $hMask = 0 Then Return SetError(_WinAPI_GetLastError(), 2, -1)
	EndIf

	Local $iRet = _GUIImageList_Add($hWnd, $hImage, $hMask)
	_WinAPI_DeleteObject($hImage)
	If $hMask <> 0 Then _WinAPI_DeleteObject($hMask)
	Return $iRet
EndFunc   ;==>_GUIImageList_AddBitmap

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_AddIcon
; Description ...: Adds an icon to an image list
; Syntax.........: _GUIImageList_AddIcon($hWnd, $sFile[, $iIndex=0[, $fLarge = False])
; Parameters ....: $hWnd        - Handle to the control
;                  $sFile       - Path to the icon that contains the image
;                  $iIndex      - Specifies the zero-based index of the icon to extract
;                  $fLarge      - Extract Large Icon
; Return values .: Success      - The index of the image
;                  Failrue      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUIImageList_Add, _GUIImageList_AddBitmap
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_AddIcon($hWnd, $sFile, $iIndex = 0, $fLarge = False)
	Local $iRet, $tIcon = DllStructCreate("handle Handle")
	If $fLarge Then
		$iRet = _WinAPI_ExtractIconEx($sFile, $iIndex, $tIcon, 0, 1)
	Else
		$iRet = _WinAPI_ExtractIconEx($sFile, $iIndex, 0, $tIcon, 1)
	EndIf
	If $iRet <= 0 Then Return SetError(-1, $iRet, -1)

	Local $hIcon = DllStructGetData($tIcon, "Handle")
	$iRet = _GUIImageList_ReplaceIcon($hWnd, -1, $hIcon)
	_WinAPI_DestroyIcon($hIcon)
	If $iRet = -1 Then Return SetError(-2, $iRet, -1)
	Return $iRet
EndFunc   ;==>_GUIImageList_AddIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_BeginDrag
; Description ...: Begins dragging an image
; Syntax.........: _GUIImageList_BeginDrag($hWnd, $iTrack, $iXHotSpot, $iYHotSpot)
; Parameters ....: $hWnd        - Handle to the control
;                  $iTrack      - Index of the image to drag
;                  $iXHotSpot   - X coordinate of the location of the drag position relative to image upper left corner
;                  $iYHotSpot   - Y coordinate of the location of the drag position relative to image upper left corner
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: This function creates a temporary image list that is used for dragging. In response to subsequent WM_MOUSEMOVE
;                  messages, you can move the drag image by using the ImageList_DragMove function. To end the drag operation, you
;                  can use the ImageList_EndDrag function.
; Related .......:  _GUIImageList_EndDrag
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_BeginDrag($hWnd, $iTrack, $iXHotSpot, $iYHotSpot)
	Local $aResult = DllCall("comctl32.dll", "bool", "ImageList_BeginDrag", "handle", $hWnd, "int", $iTrack, "int", $iXHotSpot, "int", $iYHotSpot)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0] <> 0
EndFunc   ;==>_GUIImageList_BeginDrag

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_Copy
; Description ...: Source image is copied to the destination image's index
; Syntax.........: _GUIImageList_Copy($hWnd, $iSource, $iDestination)
; Parameters ....: $hWnd         - Handle to the control
;                  $iSource      - The zero-based index of the image to be used as the source of the copy operation
;                  $iDestination - The zero-based index of the image to be used as the destination of the copy operation
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUIImageList_Swap
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_Copy($hWnd, $iSource, $iDestination)
	Local $aResult = DllCall("comctl32.dll", "bool", "ImageList_Copy", "handle", $hWnd, "int", $iDestination, "handle", $hWnd, "int", $iSource, "uint", $ILCF_MOVE)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0] <> 0
EndFunc   ;==>_GUIImageList_Copy

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_Create
; Description ...: Create an ImageList control
; Syntax.........: _GUIImageList_Create([$iCX=16[, $iCY=16[, $iColor=4[, $iOptions=0[, $iInitial=4[, $iGrow=4]]]]]])
; Parameters ....: $iCX         - Width, in pixels, of each image
;                  $iCY         - Height, in pixels, of each image
;                  $iColor      - Image color depth:
;                  |0 - Use the default behavior
;                  |1 - Use a  4 bit DIB section
;                  |2 - Use a  8 bit DIB section
;                  |3 - Use a 16 bit DIB section
;                  |4 - Use a 24 bit DIB section
;                  |5 - Use a 32 bit DIB section
;                  |6 - Use a device-dependent bitmap
;                  $iOptions    - Option flags.  Can be a combination of the following:
;                  |1 - Use a mask
;                  |2 - The images in the lists are mirrored
;                  |4 - The image list contains a strip of images
;                  $iInitial    - Number of images that the image list initially contains
;                  $iGrow       - Number of images by which the image list can grow when the system needs to make  room  for  new
;                  +images. This parameter represents the number of new images that the resized image list can contain.
; Return values .: Success      - Handle to the new control
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUIImageList_Destroy
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_Create($iCX = 16, $iCY = 16, $iColor = 4, $iOptions = 0, $iInitial = 4, $iGrow = 4)
	Local Const $aColor[7] = [$ILC_COLOR, $ILC_COLOR4, $ILC_COLOR8, $ILC_COLOR16, $ILC_COLOR24, $ILC_COLOR32, $ILC_COLORDDB]
	Local $iFlags = 0

	If BitAND($iOptions, 1) <> 0 Then $iFlags = BitOR($iFlags, $ILC_MASK)
	If BitAND($iOptions, 2) <> 0 Then $iFlags = BitOR($iFlags, $ILC_MIRROR)
	If BitAND($iOptions, 4) <> 0 Then $iFlags = BitOR($iFlags, $ILC_PERITEMMIRROR)
	$iFlags = BitOR($iFlags, $aColor[$iColor])
	Local $aResult = DllCall("comctl32.dll", "handle", "ImageList_Create", "int", $iCX, "int", $iCY, "uint", $iFlags, "int", $iInitial, "int", $iGrow)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_GUIImageList_Create

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_Destroy
; Description ...: Destroys an image list
; Syntax.........: _GUIImageList_Destroy($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUIImageList_Create
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_Destroy($hWnd)
	Local $aResult = DllCall("comctl32.dll", "bool", "ImageList_Destroy", "handle", $hWnd)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0] <> 0
EndFunc   ;==>_GUIImageList_Destroy

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_DestroyIcon
; Description ...: Destroys an icon and frees any memory the icon occupied
; Syntax.........: _GUIImageList_DestroyIcon($hIcon)
; Parameters ....: $hIcon       - Handle to the icon
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_DestroyIcon($hIcon)
	Return _WinAPI_DestroyIcon($hIcon)
EndFunc   ;==>_GUIImageList_DestroyIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_DragEnter
; Description ...: Displays the drag image at the specified position within the window
; Syntax.........: _GUIImageList_DragEnter($hWnd, $iX, $iY)
; Parameters ....: $hWnd        - Handle to the control
;                  $iX          - The x-coordinate at which to display the drag image.
;                  +The coordinate is relative to the upper-left corner of the window, not the client area
;                  $iY          - The y-coordinate at which to display the drag image.
;                  +The coordinate is relative to the upper-left corner of the window, not the client area
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUIImageList_BeginDrag, _GUIImageList_DragEnter
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_DragEnter($hWnd, $iX, $iY)
	Local $aResult = DllCall("comctl32.dll", "bool", "ImageList_DragEnter", "hwnd", $hWnd, "int", $iX, "int", $iY)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0] <> 0
EndFunc   ;==>_GUIImageList_DragEnter

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_DragLeave
; Description ...: Unlocks the specified window and hides the drag image, allowing the window to be updated
; Syntax.........: _GUIImageList_DragLeave($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUIImageList_EndDrag
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_DragLeave($hWnd)
	Local $aResult = DllCall("comctl32.dll", "bool", "ImageList_DragLeave", "hwnd", $hWnd)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0] <> 0
EndFunc   ;==>_GUIImageList_DragLeave

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_DragMove
; Description ...: Moves the image that is being dragged during a drag-and-drop operation
; Syntax.........: _GUIImageList_DragMove($iX, $iY)
; Parameters ....: $hWnd        - Handle to the control.
;                  $iX          - The x-coordinate at which to display the drag image.
;                  +The coordinate is relative to the upper-left corner of the window, not the client area
;                  $iY          - The y-coordinate at which to display the drag image.
;                  +The coordinate is relative to the upper-left corner of the window, not the client area
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_DragMove($iX, $iY)
	Local $aResult = DllCall("comCtl32.dll", "bool", "ImageList_DragMove", "int", $iX, "int", $iY)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0] <> 0
EndFunc   ;==>_GUIImageList_DragMove

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUIImageList_DragShowNolock
; Description ...: Shows or hides the image being dragged
; Syntax.........: _GUIImageList_DragShowNolock($fShow)
; Parameters ....: $fShow       - Show or hide the image being dragged
;                  | True       - Show
;                  |False       - Hide
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUIImageList_DragShowNolock($fShow)
	Local $aResult = DllCall("comctl32.dll", "bool", "ImageList_DragShowNolock", "bool", $fShow)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0] <> 0
EndFunc   ;==>_GUIImageList_DragShowNolock

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_Draw
; Description ...: Draws an image list item in the specified device context
; Syntax.........: _GUIImageList_Draw($hWnd, $iIndex, $hDC, $iX, $iY[, $iStyle=0])
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
; Related .......: _GUIImageList_DrawEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_Draw($hWnd, $iIndex, $hDC, $iX, $iY, $iStyle = 0)
	Local $iFlags = 0

	If BitAND($iStyle, 1) <> 0 Then $iFlags = BitOR($iFlags, $ILD_TRANSPARENT)
	If BitAND($iStyle, 2) <> 0 Then $iFlags = BitOR($iFlags, $ILD_BLEND25)
	If BitAND($iStyle, 4) <> 0 Then $iFlags = BitOR($iFlags, $ILD_BLEND50)
	If BitAND($iStyle, 8) <> 0 Then $iFlags = BitOR($iFlags, $ILD_MASK)
	Local $aResult = DllCall("comctl32.dll", "bool", "ImageList_Draw", "handle", $hWnd, "int", $iIndex, "handle", $hDC, "int", $iX, "int", $iY, "uint", $iFlags)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0] <> 0
EndFunc   ;==>_GUIImageList_Draw

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_DrawEx
; Description ...: Draws an image list item in the specified device context
; Syntax.........: _GUIImageList_DrawEx($hWnd, $iIndex, $hDC, $iX, $iY[, $iDX = 0[, $iDY = 0[, $iRGBBk = 0xFFFFFFFF[, $iRGBFg = 0xFFFFFFFF[, $iStyle=0]]]]])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the image to draw
;                  $hDC         - Handle to the destination device context
;                  $iX          - X coordinate where the image will be drawn
;                  $iY          - Y coordinate where the image will be drawn
;                  $iDX         - The width of the portion of the image to draw relative to the upper-left corner of the image.
;                  +If $iDX and $iDY are zero, the function draws the entire image. The function does not ensure that the parameters are valid.
;                  $iDY         - The height of the portion of the image to draw, relative to the upper-left corner of the image.
;                  +If $iDX and $iDY are zero, the function draws the entire image. The function does not ensure that the parameters are valid.
;                  $iRGBBk      - The background color of the image. This parameter can be an application-defined RGB value or one of the following values:
;                  |$CLR_NONE    - No background color. The image is drawn transparently.
;                  |$CLR_DEFAULT - The default background color. The image is drawn using the background color of the image list.
;                  $iRGBFg      - The foreground color of the image. This parameter can be an application-defined RGB value or one of the following values:
;                  |$CLR_NONE    - No blend color. The image is blended with the color of the destination device context.
;                  |$CLR_DEFAULT - The default foreground color. The image is drawn using the system highlight color as the foreground color.
;                  $iStyle      - Drawing style and overlay image:
;                  |1 - Draws the image transparently using the mask, regardless of the background color
;                  |2 - Draws the image, blending 25 percent with the system highlight color
;                  |4 - Draws the image, blending 50 percent with the system highlight color
;                  |8 - Draws the mask
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUIImageList_Draw
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_DrawEx($hWnd, $iIndex, $hDC, $iX, $iY, $iDX = 0, $iDY = 0, $iRGBBk = 0xFFFFFFFF, $iRGBFg = 0xFFFFFFFF, $iStyle = 0)
	If $iDX = -1 Then $iDX = 0
	If $iDY = -1 Then $iDY = 0
	If $iRGBBk = -1 Then $iRGBBk = 0xFFFFFFFF
	If $iRGBFg = -1 Then $iRGBFg = 0xFFFFFFFF
	Local $iFlags = 0
	If BitAND($iStyle, 1) <> 0 Then $iFlags = BitOR($iFlags, $ILD_TRANSPARENT)
	If BitAND($iStyle, 2) <> 0 Then $iFlags = BitOR($iFlags, $ILD_BLEND25)
	If BitAND($iStyle, 4) <> 0 Then $iFlags = BitOR($iFlags, $ILD_BLEND50)
	If BitAND($iStyle, 8) <> 0 Then $iFlags = BitOR($iFlags, $ILD_MASK)
	Local $aResult = DllCall("comctl32.dll", "bool", "ImageList_DrawEx", "handle", $hWnd, "int", $iIndex, "handle", $hDC, "int", $iX, "int", $iY, _
			"int", $iDX, "int", $iDY, "dword", $iRGBBk, "dword", $iRGBFg, "uint", $iFlags)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0] <> 0
EndFunc   ;==>_GUIImageList_DrawEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_Duplicate
; Description ...: Creates a duplicate of an existing image list
; Syntax.........: _GUIImageList_Duplicate($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The handle to the new duplicate image list
;                  Failure      - 0
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: All information contained in the original image list for normal images is copied to the new image list.
;                  Overlay images are not copied.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_Duplicate($hWnd)
	Local $aResult = DllCall("comctl32.dll", "handle", "ImageList_Duplicate", "handle", $hWnd)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_GUIImageList_Duplicate

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_EndDrag
; Description ...: Ends a drag operation
; Syntax.........: _GUIImageList_EndDrag()
; Parameters ....:
; Return values .:
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......:  _GUIImageList_BeginDrag, _GUIImageList_DragLeave
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_EndDrag()
	DllCall("comctl32.dll", "none", "ImageList_EndDrag")
	If @error Then Return SetError(@error, @extended)
EndFunc   ;==>_GUIImageList_EndDrag

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_GetBkColor
; Description ...: Retrieves the current background color for an image list
; Syntax.........: _GUIImageList_GetBkColor($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The background color
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUIImageList_SetBkColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_GetBkColor($hWnd)
	Local $aResult = DllCall("comctl32.dll", "dword", "ImageList_GetBkColor", "handle", $hWnd)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_GUIImageList_GetBkColor

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_GetIcon
; Description ...: Creates an icon from an image and mask in an image list
; Syntax.........: _GUIImageList_GetIcon($hWnd, $iIndex[, $iStyle = 0])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Zero based index of the image
;                  $iStyle      - Drawing style and overlay image:
;                  |1 - Draws the image transparently using the mask, regardless of the background color
;                  |2 - Draws the image, blending 25 percent with the system highlight color
;                  |4 - Draws the image, blending 50 percent with the system highlight color
;                  |8 - Draws the mask
; Return values .: Success      - The handle to the icon if successful
;                  Failure      - 0
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: It is the responsibility of the calling application to destroy the icon returned from this function
;                  using _GUIImageList_DestroyIcon
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_GetIcon($hWnd, $iIndex, $iStyle = 0)
	Local $iFlags = 0

	If BitAND($iStyle, 1) <> 0 Then $iFlags = BitOR($iFlags, $ILD_TRANSPARENT)
	If BitAND($iStyle, 2) <> 0 Then $iFlags = BitOR($iFlags, $ILD_BLEND25)
	If BitAND($iStyle, 4) <> 0 Then $iFlags = BitOR($iFlags, $ILD_BLEND50)
	If BitAND($iStyle, 8) <> 0 Then $iFlags = BitOR($iFlags, $ILD_MASK)

	Local $aResult = DllCall("comctl32.dll", "handle", "ImageList_GetIcon", "handle", $hWnd, "int", $iIndex, "uint", $iFlags)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_GUIImageList_GetIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_GetIconHeight
; Description ...: Retrieves the height of the images in an image list
; Syntax.........: _GUIImageList_GetIconHeight($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Height, in pixels, of each image
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUIImageList_GetIconSize, _GUIImageList_GetIconWidth, _GUIImageList_GetIconSizeEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_GetIconHeight($hWnd)
	Local $aSize = _GUIImageList_GetIconSize($hWnd)
	Return $aSize[1]
EndFunc   ;==>_GUIImageList_GetIconHeight

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_GetIconSize
; Description ...: Retrieves the dimensions of images in an image list
; Syntax.........: _GUIImageList_GetIconSize($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Array with the following format:
;                  |[0] - Width, in pixels, of each image
;                  |[1] - Height, in pixels, of each image
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUIImageList_GetIconHeight, _GUIImageList_GetIconSizeEx, _GUIImageList_GetIconWidth, _GUIImageList_SetIconSize
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_GetIconSize($hWnd)
	Local $aSize[2]

	Local $tPoint = _GUIImageList_GetIconSizeEx($hWnd)
	$aSize[0] = DllStructGetData($tPoint, "X")
	$aSize[1] = DllStructGetData($tPoint, "Y")
	Return $aSize
EndFunc   ;==>_GUIImageList_GetIconSize

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_GetIconSizeEx
; Description ...: Retrieves the dimensions of images in an image list
; Syntax.........: _GUIImageList_GetIconSizeEx($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - $tagPOINT structure
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUIImageList_GetIconHeight, _GUIImageList_GetIconSize, _GUIImageList_GetIconWidth
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_GetIconSizeEx($hWnd)
	Local $tPoint = DllStructCreate($tagPOINT)
	Local $pPointX = DllStructGetPtr($tPoint, "X")
	Local $pPointY = DllStructGetPtr($tPoint, "Y")
	Local $aResult = DllCall("comctl32.dll", "bool", "ImageList_GetIconSize", "hwnd", $hWnd, "struct*", $pPointX, "struct*", $pPointY)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($aResult[0], $tPoint)
EndFunc   ;==>_GUIImageList_GetIconSizeEx

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_GetIconWidth
; Description ...: Retrieves the width of the images in an image list
; Syntax.........: _GUIImageList_GetIconWidth($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Width, in pixels, of each image
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: _GUIImageList_GetIconHeight, _GUIImageList_GetIconSize, _GUIImageList_GetIconSizeEx
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_GetIconWidth($hWnd)
	Local $aSize = _GUIImageList_GetIconSize($hWnd)
	Return $aSize[0]
EndFunc   ;==>_GUIImageList_GetIconWidth

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_GetImageCount
; Description ...: Retrieves the number of images in an image list
; Syntax.........: _GUIImageList_GetImageCount($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - The number of images
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUIImageList_SetImageCount
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_GetImageCount($hWnd)
	Local $aResult = DllCall("comctl32.dll", "int", "ImageList_GetImageCount", "handle", $hWnd)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_GUIImageList_GetImageCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_GetImageInfoEx
; Description ...: Retrieves information about an image
; Syntax.........: _GUIImageList_GetImageInfoEx($hWnd, $iIndex)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Index of the image
; Return values .: Success      - $tagIMAGEINFO structure that receives information about the image
;                  Failure      - 0
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......:
; Related .......: $tagIMAGEINFO
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_GetImageInfoEx($hWnd, $iIndex)
	Local $tImage = DllStructCreate($tagIMAGEINFO)
	Local $aResult = DllCall("comctl32.dll", "bool", "ImageList_GetImageInfo", "handle", $hWnd, "int", $iIndex, "struct*", $tImage)
	If @error Then Return SetError(@error, @extended, 0)
	Return SetExtended($aResult[0], $tImage)
EndFunc   ;==>_GUIImageList_GetImageInfoEx

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUIImageList_Merge
; Description ...: Creates a new image by combining two existing images
; Syntax.........: _GUIImageList_Merge($hWnd1, $iIndex1, $hwnd2, $iIndex2, $iDX, $IDY)
; Parameters ....: $hWnd1       - Handle to the 1st image control
;                  $iIndex1     - Zero based of the first existing image
;                  $hWnd2       - Handle to the 2nd image control
;                  $iIndex2     - Zero based of the second existing image
;                  $iDX         - The x-offset of the second image relative to the first image
;                  $iDY         - The y-offset of the second image relative to the first image
; Return values .: Success      - The handle to the new image list
;                  Failure      - 0
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The new image consists of the second existing image drawn transparently over the first.
;                  The mask for the new image is the result of performing a logical OR operation on the masks
;                  of the two existing images.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUIImageList_Merge($hWnd1, $iIndex1, $hwnd2, $iIndex2, $iDX, $iDY)
	Local $aResult = DllCall("comctl32.dll", "handle", "ImageList_Merge", "handle", $hWnd1, "int", $iIndex1, _
			"handle", $hwnd2, "int", $iIndex2, "int", $iDX, "int", $iDY)
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[0]
EndFunc   ;==>_GUIImageList_Merge

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_Remove
; Description ...: Remove Image(s) from the ImageList
; Syntax.........: _GUIImageList_Remove($hWnd[, $iIndex = -1])
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - The index of the image to remove. If this parameter is -1, the function removes all images
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: When an image is removed, the indexes of the remaining images are adjusted so that the image indexes
;                  always range from zero to one less than the number of images in the image list.
;                  For example, if you remove the image at index 0, then image 1 becomes image 0, image 2 becomes
;                  image 1, and so on.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_Remove($hWnd, $iIndex = -1)
	Local $aResult = DllCall("comctl32.dll", "bool", "ImageList_Remove", "handle", $hWnd, "int", $iIndex)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0] <> 0
EndFunc   ;==>_GUIImageList_Remove

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUIImageList_Replace
; Description ...: Replaces an image with an icon or cursor
; Syntax.........: _GUIImageList_ReplaceIcon($hWnd, $iIndex, $hIcon)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Index of the image to replace.
;                  $hImage      - Handle to the bitmap that contains the image
;                  $hMask       - A handle to the bitmap that contains the mask.
;                  +If no mask is used with the image list, this parameter is ignored
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: The _GUIImageList_Replace function copies the bitmap to an internal data structure.
;                  Be sure to use the _WinAPI_DeleteObject function to delete $hImage and $hMask after the function returns.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUIImageList_Replace($hWnd, $iIndex, $hImage, $hMask = 0)
	Local $aResult = DllCall("comctl32.dll", "bool", "ImageList_Replace", "handle", $hWnd, "int", $iIndex, "handle", $hImage, "handle", $hMask)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0] <> 0
EndFunc   ;==>_GUIImageList_Replace

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_ReplaceIcon
; Description ...: Replaces an image with an icon or cursor
; Syntax.........: _GUIImageList_ReplaceIcon($hWnd, $iIndex, $hIcon)
; Parameters ....: $hWnd        - Handle to the control
;                  $iIndex      - Index of the image to replace. If -1, the function appends the image to the end of the list.
;                  $hIcon       - Handle to the icon or cursor that contains the bitmap and mask for the new image
; Return values .: Success      - The index of the image
;                  Failure      - -1
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (GaryFrost) changed return type from hwnd to int
; Remarks .......: Because the system does not save hIcon you can destroy it after the function returns if the icon or cursor was
;                  created by the CreateIcon function. You do not need to destroy hIcon if it was loaded by the LoadIcon function
;                  the system automatically frees an icon resource when it is no longer needed.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_ReplaceIcon($hWnd, $iIndex, $hIcon)
	Local $aResult = DllCall("comctl32.dll", "int", "ImageList_ReplaceIcon", "handle", $hWnd, "int", $iIndex, "handle", $hIcon)
	If @error Then Return SetError(@error, @extended, -1)
	Return $aResult[0]
EndFunc   ;==>_GUIImageList_ReplaceIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_SetBkColor
; Description ...: Sets the background color for an image list
; Syntax.........: _GUIImageList_SetBkColor($hWnd, $iClrBk)
; Parameters ....: $hWnd        - Handle to the control
;                  $iClrBk      - The background color to set.
;                  +This parameter can be the $CLR_NONE value; in that case, images are drawn transparently using the mask.
; Return values .: Success      - The previous background color if successful
;                  Failure      - $CLR_NONE
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUIImageList_GetBkColor
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_SetBkColor($hWnd, $iClrBk)
	Local $aResult = DllCall("comctl32.dll", "dword", "ImageList_SetBkColor", "handle", $hWnd, "dword", $iClrBk)
	If @error Then Return SetError(@error, @extended, $CLR_NONE)
	Return $aResult[0]
EndFunc   ;==>_GUIImageList_SetBkColor

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUIImageList_SetDragCursorImage
; Description ...: Creates a new drag image
; Syntax.........: _GUIImageList_SetDragCursorImage($hWnd, $iDrag, $iDXHotSpot, $iDYHotSpot)
; Parameters ....: $hWnd        - A handle to the image list that contains the new image to combine with the drag image
;                  $iDrag       - The index of the new image to combine with the drag image
;                  $iDXHotSpot  - The x-position of the hot spot within the new image
;                  $iDYHotSpot  - The y-position of the hot spot within the new image
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: Creates a new drag image by combining the specified image (typically a mouse cursor image)
;                  with the current drag image
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUIImageList_SetDragCursorImage($hWnd, $iDrag, $iDXHotSpot, $iDYHotSpot)
	Local $aResult = DllCall("comctl32.dll", "bool", "ImageList_SetDragCursorImage", "handle", $hWnd, "int", $iDrag, "int", $iDXHotSpot, "int", $iDYHotSpot)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0] <> 0
EndFunc   ;==>_GUIImageList_SetDragCursorImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_SetIconSize
; Description ...: Sets the dimensions of images in an image list and removes all images from the list
; Syntax.........: _GUIImageList_SetIconSize($hWnd, $iCX, $iCY)
; Parameters ....: $hWnd        - Handle to the control
;                  $iCX         - The width, in pixels, of the images in the image list
;                  $iCY         - The height, in pixels, of the images in the image list
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: All images in an image list have the same dimensions
; Related .......: _GUIImageList_GetIconSize
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_SetIconSize($hWnd, $iCX, $iCY)
	Local $aResult = DllCall("comctl32.dll", "bool", "ImageList_SetIconSize", "handle", $hWnd, "int", $iCX, "int", $iCY)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0] <> 0
EndFunc   ;==>_GUIImageList_SetIconSize

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_SetImageCount
; Description ...: Resizes an existing image list
; Syntax.........: _GUIImageList_SetImageCount($hWnd, $iNewCount)
; Parameters ....: $hWnd        - Handle to the control
;                  $iNewCount   - The new size of the image list
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: If an application expands an image list with this function, it must add new images by using
;                  the GUIImageList_Replace function. If your application does not add valid images at the new indexes,
;                  draw operations that use the new indexes will be unpredictable.
;+
;                  If you decrease the size of an image list by using this function, the truncated images are freed.
; Related .......: _GUIImageList_GetImageCount
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_SetImageCount($hWnd, $iNewCount)
	Local $aResult = DllCall("comctl32.dll", "bool", "ImageList_SetImageCount", "handle", $hWnd, "uint", $iNewCount)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0] <> 0
EndFunc   ;==>_GUIImageList_SetImageCount

; #NO_DOC_FUNCTION# =============================================================================================================
; Name...........: _GUIImageList_SetOverlayImage
; Description ...: Adds a specified image to the list of images to be used as overlay masks
; Syntax.........: _GUIImageList_SetOverlayImage($hWnd, $iImage, $iOverlay)
; Parameters ....: $hWnd        - Handle to the control
;                  $iImage      - The zero-based index of an image in the himl image list
;                  +This index identifies the image to use as an overlay mask
;                  $iOverlay    - The one-based index of the overlay mask
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......: An image list can have up to four overlay masks in (comctl32.dll) version 4.70 and earlier
;                  and up to 15 in version 4.71. The function assigns an overlay mask index to the specified image.
;+
;                  An overlay mask is an image drawn transparently over another image.
;                  To draw an overlay mask over an image, call the _GUIImageList_Draw or _GUIImageList_DrawEx function.
;+
;                  A call to this method fails and returns $E_INVALIDARG unless the image list is created using a mask.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUIImageList_SetOverlayImage($hWnd, $iImage, $iOverlay)
	Local $aResult = DllCall("comctl32.dll", "bool", "ImageList_SetOverlayImage", "handle", $hWnd, "int", $iImage, "int", $iOverlay)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0] <> 0
EndFunc   ;==>_GUIImageList_SetOverlayImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUIImageList_Swap
; Description ...: Source image is copied to the destination image's index
; Syntax.........: _GUIImageList_Swap($hWnd, $iSource, $iDestination)
; Parameters ....: $hWnd         - Handle to the control
;                  $iSource      - The zero-based index of the image to be used as the source of the swap operation
;                  $iDestination - The zero-based index of the image to be used as the destination of the swap operation
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Gary Frost (gafrost)
; Modified.......:
; Remarks .......:
; Related .......: _GUIImageList_Copy
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GUIImageList_Swap($hWnd, $iSource, $iDestination)
	Local $aResult = DllCall("comctl32.dll", "bool", "ImageList_Copy", "handle", $hWnd, "int", $iDestination, "handle", $hWnd, "int", $iSource, "uint", $ILCF_SWAP)
	If @error Then Return SetError(@error, @extended, False)
	Return $aResult[0] <> 0
EndFunc   ;==>_GUIImageList_Swap
