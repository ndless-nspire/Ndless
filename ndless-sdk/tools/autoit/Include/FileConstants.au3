#include-once

; #INDEX# =======================================================================================================================
; Title .........: File_Constants
; AutoIt Version : 3.3
; Language ......: English
; Description ...: Constants to be included in an AutoIt v3 script when using File functions.
; Author(s) .....: Valik, Gary Frost, ...
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; Indicates file copy and install options
Global Const $FC_NOOVERWRITE = 0 ; Do not overwrite existing files (default)
Global Const $FC_OVERWRITE = 1 ; Overwrite existing files

; Indicates file date and time options
Global Const $FT_MODIFIED = 0 ; Date and time file was last modified (default)
Global Const $FT_CREATED = 1 ; Date and time file was created
Global Const $FT_ACCESSED = 2 ; Date and time file was last accessed

; Indicates the mode to open a file
Global Const $FO_READ = 0 ; Read mode
Global Const $FO_APPEND = 1 ; Write mode (append)
Global Const $FO_OVERWRITE = 2 ; Write mode (erase previous contents)
Global Const $FO_BINARY = 16 ; Read/Write mode binary
Global Const $FO_UNICODE = 32 ; Write mode Unicode UTF16-LE
Global Const $FO_UTF16_LE = 32 ; Write mode Unicode UTF16-LE
Global Const $FO_UTF16_BE = 64 ; Write mode Unicode UTF16-BE
Global Const $FO_UTF8 = 128 ; Read/Write mode UTF8 with BOM
Global Const $FO_UTF8_NOBOM = 256 ; Read/Write mode UTF8 with no BOM

; Indicates file read options
Global Const $EOF = -1 ; End-of-file reached

; Indicates file open and save dialog options
Global Const $FD_FILEMUSTEXIST = 1 ; File must exist
Global Const $FD_PATHMUSTEXIST = 2 ; Path must exist
Global Const $FD_MULTISELECT = 4 ; Allow multi-select
Global Const $FD_PROMPTCREATENEW = 8 ; Prompt to create new file
Global Const $FD_PROMPTOVERWRITE = 16 ; Prompt to overWrite file

Global Const $CREATE_NEW = 1
Global Const $CREATE_ALWAYS = 2
Global Const $OPEN_EXISTING = 3
Global Const $OPEN_ALWAYS = 4
Global Const $TRUNCATE_EXISTING = 5

Global Const $INVALID_SET_FILE_POINTER = -1

; Indicates starting point for the file pointer move operations
Global Const $FILE_BEGIN = 0
Global Const $FILE_CURRENT = 1
Global Const $FILE_END = 2

Global Const $FILE_ATTRIBUTE_READONLY = 0x00000001
Global Const $FILE_ATTRIBUTE_HIDDEN = 0x00000002
Global Const $FILE_ATTRIBUTE_SYSTEM = 0x00000004
Global Const $FILE_ATTRIBUTE_DIRECTORY = 0x00000010
Global Const $FILE_ATTRIBUTE_ARCHIVE = 0x00000020
Global Const $FILE_ATTRIBUTE_DEVICE = 0x00000040
Global Const $FILE_ATTRIBUTE_NORMAL = 0x00000080
Global Const $FILE_ATTRIBUTE_TEMPORARY = 0x00000100
Global Const $FILE_ATTRIBUTE_SPARSE_FILE = 0x00000200
Global Const $FILE_ATTRIBUTE_REPARSE_POINT = 0x00000400
Global Const $FILE_ATTRIBUTE_COMPRESSED = 0x00000800
Global Const $FILE_ATTRIBUTE_OFFLINE = 0x00001000
Global Const $FILE_ATTRIBUTE_NOT_CONTENT_INDEXED = 0x00002000
Global Const $FILE_ATTRIBUTE_ENCRYPTED = 0x00004000

Global Const $FILE_SHARE_READ = 0x00000001
Global Const $FILE_SHARE_WRITE = 0x00000002
Global Const $FILE_SHARE_DELETE = 0x00000004

Global Const $GENERIC_ALL = 0x10000000
Global Const $GENERIC_EXECUTE = 0x20000000
Global Const $GENERIC_WRITE = 0x40000000
Global Const $GENERIC_READ = 0x80000000
; ===============================================================================================================================
