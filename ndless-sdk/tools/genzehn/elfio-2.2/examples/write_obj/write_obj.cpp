/*
 * This example shows how to create ELF object file for Linux on x86
 *
 * Instructions:
 * 1. Compile and link this file with ELFIO library
 *    g++ write_obj.cpp -o writer_obj
 * 2. Execute result file write_obj
 *    ./write_obj
 * 3. Link output file hello.o:
 *    gcc -m32 -s -nostartfiles -nostdlib hello.o -o hello
 * 4. Run the result file:
 *    ./hello
 */

#include <elfio/elfio.hpp>

using namespace ELFIO;

int main( void )
{
    elfio writer;

    // You can't proceed before this function call!
    writer.create( ELFCLASS32, ELFDATA2LSB );

    writer.set_os_abi( ELFOSABI_LINUX );
    writer.set_type( ET_REL );
    writer.set_machine( EM_386 );

    // This is our code
    char text[] = { '\xB8', '\x04', '\x00', '\x00', '\x00',   // mov eax, 4
                    '\xBB', '\x01', '\x00', '\x00', '\x00',   // mov ebx, 1
                    '\xB9', '\x00', '\x00', '\x00', '\x00',   // mov ecx, msg
                    '\xBA', '\x0E', '\x00', '\x00', '\x00',   // mov edx, 14
                    '\xCD', '\x80',                           // int 0x80
                    '\xB8', '\x01', '\x00', '\x00', '\x00',   // mov eax, 1
                    '\xCD', '\x80',                           // int 0x80
                    '\x48', '\x65', '\x6C', '\x6C', '\x6F',   // msg: db   'Hello, World!', 10
                    '\x2C', '\x20', '\x57', '\x6F', '\x72',
                    '\x6C', '\x64', '\x21', '\x0A'
                  };
    Elf64_Addr place_to_adjust = 11;

    // Create code section
    section* text_sec = writer.sections.add( ".text" );
    text_sec->set_type      ( SHT_PROGBITS );
    text_sec->set_flags     ( SHF_ALLOC | SHF_EXECINSTR );
    text_sec->set_addr_align( 0x10 );
    text_sec->set_data      ( text, sizeof( text ) );

    // Create string table section
    section* str_sec = writer.sections.add( ".strtab" );
    str_sec->set_type      ( SHT_STRTAB );

    // Create string table writer
    string_section_accessor stra( str_sec );
    // Add label name
    Elf32_Word str_index = stra.add_string( "msg" );

    // Create symbol table section
    section* sym_sec = writer.sections.add( ".symtab" );
    sym_sec->set_type      ( SHT_SYMTAB );
    sym_sec->set_info      ( 2 );
    sym_sec->set_addr_align( 0x4 );
    sym_sec->set_entry_size( writer.get_default_entry_size( SHT_SYMTAB ) );
    sym_sec->set_link      ( str_sec->get_index() );

    // Create symbol table writer
    symbol_section_accessor syma( writer, sym_sec );
    // Add symbol entry (msg has offset == 29)
    Elf_Word sym_to_adjust = syma.add_symbol( str_index, 29, 0, STB_GLOBAL,
                                              STT_OBJECT, 0,
                                              text_sec->get_index() );
    // Another way to add symbol
    syma.add_symbol( stra, "_start", 0x00000000, 0, STB_WEAK, STT_FUNC, 0,
                     text_sec->get_index() );

    // Create relocation table section
    section* rel_sec = writer.sections.add( ".rel.text" );
    rel_sec->set_type      ( SHT_REL );
    rel_sec->set_info      ( text_sec->get_index() );
    rel_sec->set_addr_align( 0x4 );
    rel_sec->set_entry_size( writer.get_default_entry_size( SHT_REL ) );
    rel_sec->set_link      ( sym_sec->get_index() );

    // Create relocation table writer
    relocation_section_accessor rela( writer, rel_sec );
    // Add relocation entry (adjust address at offset 11)
    rela.add_entry( place_to_adjust, sym_to_adjust,
                    (unsigned char)R_386_RELATIVE );

    // Another method to add the same relocation entry at one step is:
    // rela.add_entry( stra, "msg",
    //                 syma, 29, 0,
    //                 ELF_ST_INFO( STB_GLOBAL, STT_OBJECT ), 0,
    //                 text_sec->get_index(),
    //                 place_to_adjust, (unsigned char)R_386_RELATIVE );

    // Create note section
    section* note_sec = writer.sections.add( ".note" );
    note_sec->set_type( SHT_NOTE );

    note_section_accessor note_writer( writer, note_sec );
    note_writer.add_note( 0x01, "Created by ELFIO", 0, 0 );
    char descr[6] = {0x31, 0x32, 0x33, 0x34, 0x35, 0x36};
    note_writer.add_note( 0x01, "Never easier!", descr, sizeof( descr ) );

    // Create ELF object file
    writer.save( "hello.o" );

    return 0;
}
