#ifndef ZEHN_H
#define ZEHN_H

#include <cstdint>

/*  Definitions and declaration of all Zehn-Related structures.
    Also the main source of documentation. You'll hopefully not need more than this. */

#define ZEHN_SIGNATURE 0x6e68655a // "Zehn"
#define ZEHN_VERSION 1

//Everything little endian
#if __BYTE_ORDER__ != __ORDER_LITTLE_ENDIAN__
    #error "This header may only be used on little endian machines!"
#endif

struct Zehn_header
{
    uint32_t signature; // Must be ZEHN_SIGNATURE
    uint32_t version; //Must be ZEHN_VERSION
    uint32_t file_size; //Size of the file in bytes
    uint32_t reloc_count; //Count of relocation entries
    uint32_t flag_count; //Count of flags
    uint32_t extra_size; //Size of extra data in bytes
    uint32_t alloc_size; //Size of file + needed zeros at the end in bytes
    uint32_t entry_offset; //Offset of entry point in executable
    //Reloc table: reloc_count times Zehn_reloc
    //Flag table: flag_count times Zehn_flag
    //Extra data: May contain anything
    //Start of executable (4-byte aligned by extra_size)
} __attribute__((packed));

//If the type is unknown, the loader must exit
enum class Zehn_reloc_type : uint8_t
{
    ADD_BASE = 0, //Just add the address of the executable start
    ADD_BASE_GOT, //Add the start address until you hit 0xFFFFFFFF
    SET_ZERO, //Set the value to 0, e.g. to undo got relocs for undef. symbols
    FILE_COMPRESSED, //Marks that the file is compressed. Has to come before other relocs. Offset is the Zehn_compress_type
    UNALIGNED_RELOC, //If this occurs anywhere in the reloc list, there is at least one unaligned relocation. Offset must be 0.
};

enum class Zehn_compress_type : uint32_t
{
    ZLIB = 0 //Compressed using zlib
};

struct Zehn_reloc
{
    Zehn_reloc_type type : 8;
    uint32_t offset : 24;
} __attribute__((packed));

//The loader must ignore unknown flags
enum class Zehn_flag_type : uint8_t
{
    NDLESS_VERSION_MIN = 0, //Data contains ndless version * 10 (3.1 = 31, 3.6 = 36)
    NDLESS_VERSION_MAX,
    NDLESS_REVISION_MIN, //Only applicable if also ndless_version_min
    NDLESS_REVISION_MAX, //Only applicable if also ndless_version_max
    RUNS_ON_COLOR, //Whether the executable works on CX or CM
    RUNS_ON_CLICKPAD,
    RUNS_ON_TOUCHPAD,
    RUNS_ON_32MB, //Whether the executable also runs on less than 64MB of SDRAM
    EXECUTABLE_NAME, //Data contains offset into extra data which points to a 0-terminated string
    EXECUTABLE_AUTHOR, //Also as string
    EXECUTABLE_VERSION, //Integer for easier comparision
    EXECUTABLE_NOTICE, //May contain anything as string
    RUNS_ON_HWW, //Whether the executable support the 90° rotated 240x320 LCD on HW-W
    USES_LCD_BLIT, //Whether the executable uses the new screen API (lcd_blit)
};

struct Zehn_flag
{
    Zehn_flag_type type : 8;
    uint32_t data : 24;
} __attribute__((packed));

#endif // ZEHN_H
