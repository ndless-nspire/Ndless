/*
Copyright (C) 2001-2012 by Serge Lamikhov-Center

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#ifndef ELFIO_HPP
#define ELFIO_HPP

#ifdef _MSC_VER
#pragma warning ( push )
#pragma warning(disable:4996)
#pragma warning(disable:4355)
#pragma warning(disable:4244)
#endif

#include <string>
#include <fstream>
#include <algorithm>
#include <vector>
#include <typeinfo>

#include <elfio/elf_types.hpp>
#include <elfio/elfio_utils.hpp>
#include <elfio/elfio_header.hpp>
#include <elfio/elfio_section.hpp>
#include <elfio/elfio_segment.hpp>
#include <elfio/elfio_strings.hpp>

#define ELFIO_HEADER_ACCESS_GET( TYPE, FNAME ) \
TYPE                                           \
get_##FNAME() const                            \
{                                              \
    return header->get_##FNAME();              \
}

#define ELFIO_HEADER_ACCESS_GET_SET( TYPE, FNAME ) \
TYPE                                               \
get_##FNAME() const                                \
{                                                  \
    return header->get_##FNAME();                  \
}                                                  \
void                                               \
set_##FNAME( TYPE val )                            \
{                                                  \
    header->set_##FNAME( val );                    \
}                                                  \

namespace ELFIO {

//------------------------------------------------------------------------------
class elfio
{
  public:
//------------------------------------------------------------------------------
    elfio() : sections( this ), segments( this )
    {
        header      = 0;
        create( ELFCLASS32, ELFDATA2LSB );
    }

//------------------------------------------------------------------------------
    ~elfio()
    {
        clean();
    }

//------------------------------------------------------------------------------
    void create( unsigned char file_class, unsigned char encoding )
    {
        clean();
        convertor.setup( encoding );
        header = create_header( file_class, encoding );
        create_mandatory_sections();
    }

//------------------------------------------------------------------------------
    bool load( const std::string& file_name )
    {
        clean();

        std::ifstream stream;
        stream.open( file_name.c_str(), std::ios::in | std::ios::binary );
        if ( !stream ) {
            return false;
        }

        unsigned char e_ident[EI_NIDENT];

        // Read ELF file signature
        stream.seekg( 0 );
        stream.read( reinterpret_cast<char*>( &e_ident ), sizeof( e_ident ) );

        // Is it ELF file?
        if ( stream.gcount() != sizeof( e_ident ) ||
             e_ident[EI_MAG0] != ELFMAG0    ||
             e_ident[EI_MAG1] != ELFMAG1    ||
             e_ident[EI_MAG2] != ELFMAG2    ||
             e_ident[EI_MAG3] != ELFMAG3 ) {
            return false;
        }

        if ( ( e_ident[EI_CLASS] != ELFCLASS64 ) &&
             ( e_ident[EI_CLASS] != ELFCLASS32 )) {
            return false;
        }

        convertor.setup( e_ident[EI_DATA] );

        header = create_header( e_ident[EI_CLASS], e_ident[EI_DATA] );
        if ( 0 == header ) {
            return false;
        }
        if ( !header->load( stream ) ) {
            return false;
        }

        load_sections( stream );
        load_segments( stream );

        return true;
    }

//------------------------------------------------------------------------------
    bool save( const std::string& file_name )
    {
        std::ofstream f( file_name.c_str(), std::ios::out | std::ios::binary );

        if ( !f ) {
            return false;
        }

        bool is_still_good = true;
        fill_final_attributes();
        set_current_file_position();

        is_still_good = is_still_good && save_header( f );
        is_still_good = is_still_good && save_sections_without_segments( f );
        is_still_good = is_still_good && save_segments_and_their_sections( f );

        f.close();

        return is_still_good;
    }

//------------------------------------------------------------------------------
    // ELF header access functions
    ELFIO_HEADER_ACCESS_GET( unsigned char, class              );
    ELFIO_HEADER_ACCESS_GET( unsigned char, elf_version        );
    ELFIO_HEADER_ACCESS_GET( unsigned char, encoding           );
    ELFIO_HEADER_ACCESS_GET( Elf_Word,      version            );
    ELFIO_HEADER_ACCESS_GET( Elf_Half,      header_size        );
    ELFIO_HEADER_ACCESS_GET( Elf_Half,      section_entry_size );
    ELFIO_HEADER_ACCESS_GET( Elf_Half,      segment_entry_size );

    ELFIO_HEADER_ACCESS_GET_SET( unsigned char, os_abi                 );
    ELFIO_HEADER_ACCESS_GET_SET( unsigned char, abi_version            );
    ELFIO_HEADER_ACCESS_GET_SET( Elf_Half,      type                   );
    ELFIO_HEADER_ACCESS_GET_SET( Elf_Half,      machine                );
    ELFIO_HEADER_ACCESS_GET_SET( Elf_Word,      flags                  );
    ELFIO_HEADER_ACCESS_GET_SET( Elf64_Addr,    entry                  );
    ELFIO_HEADER_ACCESS_GET_SET( Elf64_Off,     sections_offset        );
    ELFIO_HEADER_ACCESS_GET_SET( Elf64_Off,     segments_offset        );
    ELFIO_HEADER_ACCESS_GET_SET( Elf_Half,      section_name_str_index );

//------------------------------------------------------------------------------
    const endianess_convertor& get_convertor() const
    {
        return convertor;
    }

//------------------------------------------------------------------------------
    Elf_Xword get_default_entry_size( Elf_Word section_type ) const
    {
        switch( section_type ) {
        case SHT_RELA:
            if ( header->get_class() == ELFCLASS64 ) {
                return sizeof( Elf64_Rela );
            }
            else {
                return sizeof( Elf32_Rela );
            }
        case SHT_REL:
            if ( header->get_class() == ELFCLASS64 ) {
                return sizeof( Elf64_Rel );
            }
            else {
                return sizeof( Elf32_Rel );
            }
        case SHT_SYMTAB:
            if ( header->get_class() == ELFCLASS64 ) {
                return sizeof( Elf64_Sym );
            }
            else {
                return sizeof( Elf32_Sym );
            }
        case SHT_DYNAMIC:
            if ( header->get_class() == ELFCLASS64 ) {
                return sizeof( Elf64_Dyn );
            }
            else {
                return sizeof( Elf32_Dyn );
            }
        default:
            return 0;
        }
    }

//------------------------------------------------------------------------------
  private:
//------------------------------------------------------------------------------
    void clean()
    {
        delete header;
        header = 0;

        std::vector<section*>::const_iterator it;
        for ( it = sections_.begin(); it != sections_.end(); ++it ) {
            delete *it;
        }
        sections_.clear();

        std::vector<segment*>::const_iterator it1;
        for ( it1 = segments_.begin(); it1 != segments_.end(); ++it1 ) {
            delete *it1;
        }
        segments_.clear();
    }

//------------------------------------------------------------------------------
    elf_header* create_header( unsigned char file_class, unsigned char encoding )
    {
        elf_header* new_header = 0;

        if ( file_class == ELFCLASS64 ) {
            new_header = new elf_header_impl< Elf64_Ehdr >( &convertor,
                                                            encoding );
        }
        else if ( file_class == ELFCLASS32 ) {
            new_header = new elf_header_impl< Elf32_Ehdr >( &convertor,
                                                            encoding );
        }
        else {
            return 0;
        }

        return new_header;
    }

//------------------------------------------------------------------------------
    section* create_section()
    {
        section*      new_section;
        unsigned char file_class = get_class();

        if ( file_class == ELFCLASS64 ) {
            new_section = new section_impl<Elf64_Shdr>( &convertor );
        }
        else if ( file_class == ELFCLASS32 ) {
            new_section = new section_impl<Elf32_Shdr>( &convertor );
        }
        else {
            return 0;
        }

        new_section->set_index( (Elf_Half)sections_.size() );
        sections_.push_back( new_section );

        return new_section;
    }


//------------------------------------------------------------------------------
    segment* create_segment()
    {
        segment*      new_segment;
        unsigned char file_class = header->get_class();

        if ( file_class == ELFCLASS64 ) {
            new_segment = new segment_impl<Elf64_Phdr>( &convertor );
        }
        else if ( file_class == ELFCLASS32 ) {
            new_segment = new segment_impl<Elf32_Phdr>( &convertor );
        }
        else {
            return 0;
        }

        segments_.push_back( new_segment );

        return new_segment;
    }

//------------------------------------------------------------------------------
    void create_mandatory_sections()
    {
        // Create null section without calling to 'add_section' as no string
        // section containing section names exists yet
        section* sec0 = create_section();
        sec0->set_index( 0 );
        sec0->set_name( "" );
        sec0->set_name_string_offset( 0 );

        set_section_name_str_index( 1 );
        section* shstrtab = sections.add( ".shstrtab" );
        shstrtab->set_type( SHT_STRTAB );
    }

//------------------------------------------------------------------------------
    Elf_Half load_sections( std::ifstream& stream )
    {
        Elf_Half  entry_size = header->get_section_entry_size();
        Elf_Half  num        = header->get_sections_num();
        Elf64_Off offset     = header->get_sections_offset();

        for ( Elf_Half i = 0; i < num; ++i ) {
            section* sec = create_section();
            sec->load( stream, (std::streamoff)offset + i * entry_size );
            sec->set_index( i );
            // To mark that the section is not permitted to reassign address
            // during layout calculation
            sec->set_address( sec->get_address() );
        }

        Elf_Half shstrndx = get_section_name_str_index();

        if ( SHN_UNDEF != shstrndx ) {
            string_section_accessor str_reader( sections[shstrndx] );
            for ( Elf_Half i = 0; i < num; ++i ) {
                Elf_Word offset = sections[i]->get_name_string_offset();
                const char* p = str_reader.get_string( offset );
                if ( p != 0 ) {
                    sections[i]->set_name( p );
                }
            }
        }

        return num;
    }

//------------------------------------------------------------------------------
    bool load_segments( std::ifstream& stream )
    {
        Elf_Half  entry_size = header->get_segment_entry_size();
        Elf_Half  num        = header->get_segments_num();
        Elf64_Off offset     = header->get_segments_offset();

        for ( Elf_Half i = 0; i < num; ++i ) {
            segment* seg;
            unsigned char file_class = header->get_class();

            if ( file_class == ELFCLASS64 ) {
                seg = new segment_impl<Elf64_Phdr>( &convertor );
            }
            else if ( file_class == ELFCLASS32 ) {
                seg = new segment_impl<Elf32_Phdr>( &convertor );
            }
            else {
                return false;
            }

            seg->load( stream, (std::streamoff)offset + i * entry_size );
            seg->set_index( i );

            // Add section into the segments' container
            segments_.push_back( seg );
        }

        return true;
    }

//------------------------------------------------------------------------------
    void fill_final_attributes()
    {
        // Fill not completed fields in the header
        header->set_segments_num( segments.size() );
        if ( segments.size() == 0 ) {
            header->set_segments_offset( 0 );
        }
        else {
            header->set_segments_offset( header->get_header_size() );
        }
        header->set_sections_num( sections.size() );
        header->set_sections_offset( header->get_header_size() +
            header->get_segment_entry_size() * segments.size() );
    }

//------------------------------------------------------------------------------
    bool save_header( std::ofstream& f )
    {
        return header->save( f );
    }


//------------------------------------------------------------------------------
    void set_current_file_position()
    {
        current_file_pos = header->get_header_size() +
               header->get_segment_entry_size() * header->get_segments_num() +
               header->get_section_entry_size() * header->get_sections_num();
    }


//------------------------------------------------------------------------------
    bool is_section_without_segment( unsigned int section_index )
    {
        bool found = false;
        for ( unsigned int j = 0; !found && ( j < segments.size() ); ++j ) {
            for ( unsigned int k = 0; !found && ( k < segments[j]->get_sections_num() ); ++k ) {
                found = segments[j]->get_section_index_at( k ) == section_index;
            }
        }

        return !found;
    }


//------------------------------------------------------------------------------
    bool save_sections_without_segments( std::ofstream& f )
    {
        for ( unsigned int i = 0; i < sections_.size(); ++i ) {
            if ( is_section_without_segment( i ) ) {
                Elf_Xword section_align = sections_[i]->get_addr_align();
                if ( section_align > 1 && current_file_pos % section_align != 0 ) {
                    current_file_pos += section_align -
                                            current_file_pos % section_align;
                }

                std::streampos headerPosition = (std::streamoff)header->get_sections_offset() +
                    header->get_section_entry_size() * sections_[i]->get_index();

                sections_[i]->save( f, headerPosition, (std::streamoff)current_file_pos );

                if ( SHT_NOBITS != sections_[i]->get_type() &&
                     SHT_NULL   != sections_[i]->get_type() ) {
                    current_file_pos += sections_[i]->get_size();
                }
            }
        }

        return true;
    }


//------------------------------------------------------------------------------
    bool save_segments_and_their_sections( std::ofstream& f )
    {
        Elf64_Off segment_header_position = header->get_segments_offset();

        for ( unsigned int i = 0; i < segments.size(); ++i ) {
            Elf_Xword segment_align = segments[i]->get_align();
            if ( segment_align > 1 && current_file_pos % segment_align != 0 ) {
                current_file_pos += segment_align - current_file_pos % segment_align;
            }

            Elf_Xword current_data_pos   = current_file_pos;
            Elf_Xword add_to_memory_size = 0;
            // Write segment's data
            for ( unsigned int j = 0; j <segments[i]->get_sections_num(); ++j ) {
                section* sec = sections[ segments[i]->get_section_index_at( j )];

                Elf_Xword secAlign = sec->get_addr_align();
                if ( secAlign > 1 && current_data_pos % secAlign != 0 ) {
                    current_data_pos += secAlign - current_data_pos % secAlign;
                }

                std::streampos headerPosition = (std::streamoff)header->get_sections_offset() +
                    header->get_section_entry_size()*sec->get_index();
                if ( !sec->is_address_initialized() ) {
                    sec->set_address( segments[i]->get_virtual_address() );
                }
                sec->save( f, headerPosition, (std::streamoff)current_data_pos );

                if ( SHT_NOBITS != sec->get_type() && SHT_NULL != sec->get_type() ) {
                    current_data_pos += sec->get_size();
                }
                else {
                    add_to_memory_size += sec->get_size();
                }
            }

            segments[i]->set_file_size( current_data_pos - current_file_pos );
            segments[i]->set_memory_size( current_data_pos - current_file_pos +
                                          add_to_memory_size );
            segments[i]->save( f, (std::streamoff)segment_header_position, (std::streamoff)current_file_pos );
            current_file_pos = current_data_pos;
            segment_header_position += header->get_segment_entry_size();
        }

        return true;
    }


//------------------------------------------------------------------------------
  public:
    friend class Sections;
    class Sections {
      public:
//------------------------------------------------------------------------------
        Sections( elfio* parent_ ) :
            parent( parent_ )
        {
        }

//------------------------------------------------------------------------------
        Elf_Half size() const
        {
            return (Elf_Half)parent->sections_.size();
        }

//------------------------------------------------------------------------------
        section* operator[]( unsigned int index ) const
        {
            section* sec = 0;
            
            if ( index < parent->sections_.size() ) {
                sec = parent->sections_[index];
            }
            
            return sec;
        }

//------------------------------------------------------------------------------
        section* operator[]( const std::string& name ) const
        {
            section* sec = 0;

            std::vector<section*>::const_iterator it;
            for ( it = parent->sections_.begin(); it != parent->sections_.end(); ++it ) {
                if ( (*it)->get_name() == name ) {
                    sec = *it;
                    break;
                }
            }

            return sec;
        }

//------------------------------------------------------------------------------
        section* add( const std::string& name )
        {
            section* new_section = parent->create_section();
            new_section->set_name( name );

            Elf_Half str_index = parent->get_section_name_str_index();
            section* string_table( parent->sections_[str_index] );
            string_section_accessor str_writer( string_table );
            Elf_Word pos = str_writer.add_string( name );
            new_section->set_name_string_offset( pos );

            return new_section;
        }

//------------------------------------------------------------------------------
      private:
        elfio* parent;
    } sections;

//------------------------------------------------------------------------------
  public:
    friend class Segments;
    class Segments {
      public:
//------------------------------------------------------------------------------
        Segments( elfio* parent_ ) :
            parent( parent_ )
        {
        }

//------------------------------------------------------------------------------
        Elf_Half size() const
        {
            return (Elf_Half)parent->segments_.size();
        }

//------------------------------------------------------------------------------
        segment* operator[]( unsigned int index ) const
        {
            return parent->segments_[index];
        }


//------------------------------------------------------------------------------
        segment* add()
        {
            return parent->create_segment();
        }

//------------------------------------------------------------------------------
      private:
        elfio* parent;
    } segments;

//------------------------------------------------------------------------------
  private:
    elf_header*           header;
    std::vector<section*> sections_;
    std::vector<segment*> segments_;
    endianess_convertor   convertor;

    Elf_Xword current_file_pos;
};

} // namespace ELFIO

#include <elfio/elfio_symbols.hpp>
#include <elfio/elfio_note.hpp>
#include <elfio/elfio_relocation.hpp>
#include <elfio/elfio_dynamic.hpp>

#ifdef _MSC_VER
#pragma warning ( pop )
#endif

#endif // ELFIO_HPP
