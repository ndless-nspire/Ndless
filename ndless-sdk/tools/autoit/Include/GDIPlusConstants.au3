#include-once

; #INDEX# =======================================================================================================================
; Title .........: GDIPlus_Constants
; AutoIt Version : 3.2
; Language ......: English
; Description ...: Constants for GDI+
; Author(s) .....: Valik, Gary Frost
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; Pen Dash Cap Types
Global Const $GDIP_DASHCAPFLAT = 0 ; A square cap that squares off both ends of each dash
Global Const $GDIP_DASHCAPROUND = 2 ; A circular cap that rounds off both ends of each dash
Global Const $GDIP_DASHCAPTRIANGLE = 3 ; A triangular cap that points both ends of each dash

; Pen Dash Style Types
Global Const $GDIP_DASHSTYLESOLID = 0 ; A solid line
Global Const $GDIP_DASHSTYLEDASH = 1 ; A dashed line
Global Const $GDIP_DASHSTYLEDOT = 2 ; A dotted line
Global Const $GDIP_DASHSTYLEDASHDOT = 3 ; An alternating dash-dot line
Global Const $GDIP_DASHSTYLEDASHDOTDOT = 4 ; An alternating dash-dot-dot line
Global Const $GDIP_DASHSTYLECUSTOM = 5 ; A a user-defined, custom dashed line

; Enocder Parameter GUIDs
Global Const $GDIP_EPGCHROMINANCETABLE = '{F2E455DC-09B3-4316-8260-676ADA32481C}'
Global Const $GDIP_EPGCOLORDEPTH = '{66087055-AD66-4C7C-9A18-38A2310B8337}'
Global Const $GDIP_EPGCOMPRESSION = '{E09D739D-CCD4-44EE-8EBA-3FBF8BE4FC58}'
Global Const $GDIP_EPGLUMINANCETABLE = '{EDB33BCE-0266-4A77-B904-27216099E717}'
Global Const $GDIP_EPGQUALITY = '{1D5BE4B5-FA4A-452D-9CDD-5DB35105E7EB}'
Global Const $GDIP_EPGRENDERMETHOD = '{6D42C53A-229A-4825-8BB7-5C99E2B9A8B8}'
Global Const $GDIP_EPGSAVEFLAG = '{292266FC-AC40-47BF-8CFC-A85B89A655DE}'
Global Const $GDIP_EPGSCANMETHOD = '{3A4E2661-3109-4E56-8536-42C156E7DCFA}'
Global Const $GDIP_EPGTRANSFORMATION = '{8D0EB2D1-A58E-4EA8-AA14-108074B7B6F9}'
Global Const $GDIP_EPGVERSION = '{24D18C76-814A-41A4-BF53-1C219CCCF797}'

; Encoder Parameter Types
Global Const $GDIP_EPTBYTE = 1 ; 8 bit unsigned integer
Global Const $GDIP_EPTASCII = 2 ; Null terminated character string
Global Const $GDIP_EPTSHORT = 3 ; 16 bit unsigned integer
Global Const $GDIP_EPTLONG = 4 ; 32 bit unsigned integer
Global Const $GDIP_EPTRATIONAL = 5 ; Two longs (numerator, denomintor)
Global Const $GDIP_EPTLONGRANGE = 6 ; Two longs (low, high)
Global Const $GDIP_EPTUNDEFINED = 7 ; Array of bytes of any type
Global Const $GDIP_EPTRATIONALRANGE = 8 ; Two ratationals (low, high)

; GDI Error Codes
Global Const $GDIP_ERROK = 0 ; Method call was successful
Global Const $GDIP_ERRGENERICERROR = 1 ; Generic method call error
Global Const $GDIP_ERRINVALIDPARAMETER = 2 ; One of the arguments passed to the method was not valid
Global Const $GDIP_ERROUTOFMEMORY = 3 ; The operating system is out of memory
Global Const $GDIP_ERROBJECTBUSY = 4 ; One of the arguments in the call is already in use
Global Const $GDIP_ERRINSUFFICIENTBUFFER = 5 ; A buffer is not large enough
Global Const $GDIP_ERRNOTIMPLEMENTED = 6 ; The method is not implemented
Global Const $GDIP_ERRWIN32ERROR = 7 ; The method generated a Microsoft Win32 error
Global Const $GDIP_ERRWRONGSTATE = 8 ; The object is in an invalid state to satisfy the API call
Global Const $GDIP_ERRABORTED = 9 ; The method was aborted
Global Const $GDIP_ERRFILENOTFOUND = 10 ; The specified image file or metafile cannot be found
Global Const $GDIP_ERRVALUEOVERFLOW = 11 ; The method produced a numeric overflow
Global Const $GDIP_ERRACCESSDENIED = 12 ; A write operation is not allowed on the specified file
Global Const $GDIP_ERRUNKNOWNIMAGEFORMAT = 13 ; The specified image file format is not known
Global Const $GDIP_ERRFONTFAMILYNOTFOUND = 14 ; The specified font family cannot be found
Global Const $GDIP_ERRFONTSTYLENOTFOUND = 15 ; The specified style is not available for the specified font
Global Const $GDIP_ERRNOTTRUETYPEFONT = 16 ; The font retrieved is not a TrueType font
Global Const $GDIP_ERRUNSUPPORTEDGDIVERSION = 17 ; The installed GDI+ version is incompatible
Global Const $GDIP_ERRGDIPLUSNOTINITIALIZED = 18 ; The GDI+ API is not in an initialized state
Global Const $GDIP_ERRPROPERTYNOTFOUND = 19 ; The specified property does not exist in the image
Global Const $GDIP_ERRPROPERTYNOTSUPPORTED = 20 ; The specified property is not supported

; Encoder Value Types
Global Const $GDIP_EVTCOMPRESSIONLZW = 2 ; TIFF: LZW compression
Global Const $GDIP_EVTCOMPRESSIONCCITT3 = 3 ; TIFF: CCITT3 compression
Global Const $GDIP_EVTCOMPRESSIONCCITT4 = 4 ; TIFF: CCITT4 compression
Global Const $GDIP_EVTCOMPRESSIONRLE = 5 ; TIFF: RLE compression
Global Const $GDIP_EVTCOMPRESSIONNONE = 6 ; TIFF: No compression
Global Const $GDIP_EVTTRANSFORMROTATE90 = 13 ; JPEG: Lossless 90 degree clockwise rotation
Global Const $GDIP_EVTTRANSFORMROTATE180 = 14 ; JPEG: Lossless 180 degree clockwise rotation
Global Const $GDIP_EVTTRANSFORMROTATE270 = 15 ; JPEG: Lossless 270 degree clockwise rotation
Global Const $GDIP_EVTTRANSFORMFLIPHORIZONTAL = 16 ; JPEG: Lossless horizontal flip
Global Const $GDIP_EVTTRANSFORMFLIPVERTICAL = 17 ; JPEG: Lossless vertical flip
Global Const $GDIP_EVTMULTIFRAME = 18 ; Multiple frame encoding
Global Const $GDIP_EVTLASTFRAME = 19 ; Last frame of a multiple frame image
Global Const $GDIP_EVTFLUSH = 20 ; The encoder object is to be closed
Global Const $GDIP_EVTFRAMEDIMENSIONPAGE = 23 ; TIFF: Page frame dimension

; Image Codec Flags constants
Global Const $GDIP_ICFENCODER = 0x00000001 ; The codec supports encoding (saving)
Global Const $GDIP_ICFDECODER = 0x00000002 ; The codec supports decoding (reading)
Global Const $GDIP_ICFSUPPORTBITMAP = 0x00000004 ; The codec supports raster images (bitmaps)
Global Const $GDIP_ICFSUPPORTVECTOR = 0x00000008 ; The codec supports vector images (metafiles)
Global Const $GDIP_ICFSEEKABLEENCODE = 0x00000010 ; The encoder requires a seekable output stream
Global Const $GDIP_ICFBLOCKINGDECODE = 0x00000020 ; The decoder has blocking behavior during the decoding process
Global Const $GDIP_ICFBUILTIN = 0x00010000 ; The codec is built in to GDI+
Global Const $GDIP_ICFSYSTEM = 0x00020000 ; Not used in GDI+ version 1.0
Global Const $GDIP_ICFUSER = 0x00040000 ; Not used in GDI+ version 1.0

; Image Lock Mode constants
Global Const $GDIP_ILMREAD = 0x0001 ; A portion of the image is locked for reading
Global Const $GDIP_ILMWRITE = 0x0002 ; A portion of the image is locked for writing
Global Const $GDIP_ILMUSERINPUTBUF = 0x0004 ; The buffer is allocated by the user

; LineCap constants
Global Const $GDIP_LINECAPFLAT = 0x00 ; Specifies a flat cap
Global Const $GDIP_LINECAPSQUARE = 0x01 ; Specifies a square cap
Global Const $GDIP_LINECAPROUND = 0x02 ; Specifies a circular cap
Global Const $GDIP_LINECAPTRIANGLE = 0x03 ; Specifies a triangular cap
Global Const $GDIP_LINECAPNOANCHOR = 0x10 ; Specifies that the line ends are not anchored
Global Const $GDIP_LINECAPSQUAREANCHOR = 0x11 ; Specifies that the line ends are anchored with a square
Global Const $GDIP_LINECAPROUNDANCHOR = 0x12 ; Specifies that the line ends are anchored with a circle
Global Const $GDIP_LINECAPDIAMONDANCHOR = 0x13 ; Specifies that the line ends are anchored with a diamond
Global Const $GDIP_LINECAPARROWANCHOR = 0x14 ; Specifies that the line ends are anchored with arrowheads
Global Const $GDIP_LINECAPCUSTOM = 0xFF ; Specifies that the line ends are made from a CustomLineCap

; Pixel Format constants
Global Const $GDIP_PXF01INDEXED = 0x00030101 ; 1 bpp, indexed
Global Const $GDIP_PXF04INDEXED = 0x00030402 ; 4 bpp, indexed
Global Const $GDIP_PXF08INDEXED = 0x00030803 ; 8 bpp, indexed
Global Const $GDIP_PXF16GRAYSCALE = 0x00101004 ; 16 bpp, grayscale
Global Const $GDIP_PXF16RGB555 = 0x00021005 ; 16 bpp; 5 bits for each RGB
Global Const $GDIP_PXF16RGB565 = 0x00021006 ; 16 bpp; 5 bits red, 6 bits green, and 5 bits blue
Global Const $GDIP_PXF16ARGB1555 = 0x00061007 ; 16 bpp; 1 bit for alpha and 5 bits for each RGB component
Global Const $GDIP_PXF24RGB = 0x00021808 ; 24 bpp; 8 bits for each RGB
Global Const $GDIP_PXF32RGB = 0x00022009 ; 32 bpp; 8 bits for each RGB. No alpha.
Global Const $GDIP_PXF32ARGB = 0x0026200A ; 32 bpp; 8 bits for each RGB and alpha
Global Const $GDIP_PXF32PARGB = 0x000D200B ; 32 bpp; 8 bits for each RGB and alpha, pre-mulitiplied
Global Const $GDIP_PXF48RGB = 0x0010300C ; 48 bpp; 16 bits for each RGB
Global Const $GDIP_PXF64ARGB = 0x0034400D ; 64 bpp; 16 bits for each RGB and alpha
Global Const $GDIP_PXF64PARGB = 0x001C400E ; 64 bpp; 16 bits for each RGB and alpha, pre-multiplied

; ImageFormat constants (Globally Unique Identifier (GUID))
Global Const $GDIP_IMAGEFORMAT_UNDEFINED = "{B96B3CA9-0728-11D3-9D7B-0000F81EF32E}" ; Windows GDI+ is unable to determine the format.
Global Const $GDIP_IMAGEFORMAT_MEMORYBMP = "{B96B3CAA-0728-11D3-9D7B-0000F81EF32E}" ; Image was constructed from a memory bitmap.
Global Const $GDIP_IMAGEFORMAT_BMP = "{B96B3CAB-0728-11D3-9D7B-0000F81EF32E}" ; Microsoft Windows Bitmap (BMP) format.
Global Const $GDIP_IMAGEFORMAT_EMF = "{B96B3CAC-0728-11D3-9D7B-0000F81EF32E}" ; Enhanced Metafile (EMF) format.
Global Const $GDIP_IMAGEFORMAT_WMF = "{B96B3CAD-0728-11D3-9D7B-0000F81EF32E}" ; Windows Metafile Format (WMF) format.
Global Const $GDIP_IMAGEFORMAT_JPEG = "{B96B3CAE-0728-11D3-9D7B-0000F81EF32E}" ; Joint Photographic Experts Group (JPEG) format.
Global Const $GDIP_IMAGEFORMAT_PNG = "{B96B3CAF-0728-11D3-9D7B-0000F81EF32E}" ; Portable Network Graphics (PNG) format.
Global Const $GDIP_IMAGEFORMAT_GIF = "{B96B3CB0-0728-11D3-9D7B-0000F81EF32E}" ; Graphics Interchange Format (GIF) format.
Global Const $GDIP_IMAGEFORMAT_TIFF = "{B96B3CB1-0728-11D3-9D7B-0000F81EF32E}" ; Tagged Image File Format (TIFF) format.
Global Const $GDIP_IMAGEFORMAT_EXIF = "{B96B3CB2-0728-11D3-9D7B-0000F81EF32E}" ; Exchangeable Image File (EXIF) format.
Global Const $GDIP_IMAGEFORMAT_ICON = "{B96B3CB5-0728-11D3-9D7B-0000F81EF32E}" ; Microsoft Windows Icon Image (ICO)format.

; ImageType constants
Global Const $GDIP_IMAGETYPE_UNKNOWN = 0
Global Const $GDIP_IMAGETYPE_BITMAP = 1
Global Const $GDIP_IMAGETYPE_METAFILE = 2

; ImageFlags flags constants
Global Const $GDIP_IMAGEFLAGS_NONE = 0x0 ; no format information.
Global Const $GDIP_IMAGEFLAGS_SCALABLE = 0x0001 ; image can be scaled.
Global Const $GDIP_IMAGEFLAGS_HASALPHA = 0x0002 ; pixel data contains alpha values.
Global Const $GDIP_IMAGEFLAGS_HASTRANSLUCENT = 0x0004 ; pixel data has alpha values other than 0 (transparent) and 255 (opaque).
Global Const $GDIP_IMAGEFLAGS_PARTIALLYSCALABLE = 0x0008 ; pixel data is partially scalable with some limitations.
Global Const $GDIP_IMAGEFLAGS_COLORSPACE_RGB = 0x0010 ; image is stored using an RGB color space.
Global Const $GDIP_IMAGEFLAGS_COLORSPACE_CMYK = 0x0020 ; image is stored using a CMYK color space.
Global Const $GDIP_IMAGEFLAGS_COLORSPACE_GRAY = 0x0040 ; image is a grayscale image.
Global Const $GDIP_IMAGEFLAGS_COLORSPACE_YCBCR = 0x0080 ; image is stored using a YCBCR color space.
Global Const $GDIP_IMAGEFLAGS_COLORSPACE_YCCK = 0x0100 ; image is stored using a YCCK color space.
Global Const $GDIP_IMAGEFLAGS_HASREALDPI = 0x1000 ; dots per inch information is stored in the image.
Global Const $GDIP_IMAGEFLAGS_HASREALPIXELSIZE = 0x2000 ; pixel size is stored in the image.
Global Const $GDIP_IMAGEFLAGS_READONLY = 0x00010000 ; pixel data is read-only.
Global Const $GDIP_IMAGEFLAGS_CACHING = 0x00020000 ; pixel data can be cached for faster access.

; ===============================================================================================================================
