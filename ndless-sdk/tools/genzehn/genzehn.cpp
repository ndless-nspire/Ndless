#include <zlib.h>

#include <cstring>
#include <iostream>
#include <algorithm>
#include <vector>

#include <boost/program_options.hpp>

#include <elfio/elfio.hpp>

#include "zehn.h"

using namespace ELFIO;
namespace opt = boost::program_options;

//Appends s to extra_data, returns position
uint32_t zehn_extra_string(std::string s, std::vector<uint8_t> &extra_data)
{
    uint32_t pos = extra_data.size();
    extra_data.reserve(extra_data.size() + s.length() + 1);
    auto data = s.c_str();
    while(*data)
        extra_data.push_back(*data++);
    extra_data.push_back(0);

    return pos;
}

std::string zehn_get_string(uint32_t pos, std::vector<uint8_t> &extra_data)
{
    if(pos > extra_data.size() - 1)
        return "<invalid>";

    const char *start = reinterpret_cast<const char*>(extra_data.data() + pos);
    return std::string(start, strnlen(start, extra_data.size() - pos - 1));
}

int main(int argc, char **argv)
{   
    opt::options_description required("Required options");
    required.add_options()
            ("input", opt::value<std::string>(), "ELF input file")
            ("output", opt::value<std::string>(), "Zehn output file");

    opt::options_description additional("Additional options");
    additional.add_options()
            ("help", "show this message")
            ("info", "print information about a zehn file")
            ("include-bss", "include the contents of the NOBITS sections in the file")
            ("compress", "compress the executable's contents")
            ("name", opt::value<std::string>(), "executable name")
            ("verbose", "output something, even if no error occured")
            ("author", opt::value<std::string>(), "executable author")
            ("version", opt::value<uint32_t>()->default_value(1), "executable version")
            ("notice", opt::value<std::string>(), "executable notice")
            ("ndless-min", opt::value<uint32_t>(), "min. ndless version * 10, e.g 3.1 = 31")
            ("ndless-rev-min", opt::value<uint32_t>(), "min. ndless revision")
            ("ndless-max", opt::value<uint32_t>(), "max. ndless version * 10")
            ("ndless-rev-max", opt::value<uint32_t>(), "max. ndless revision")
            ("color-support", opt::value<bool>()->default_value(true), "Whether CX and CM are supported")
            ("clickpad-support", opt::value<bool>()->default_value(true), "Whether clickpads are supported")
            ("touchpad-support", opt::value<bool>()->default_value(true), "Whether touchpads (classic) are supported")
            ("32MB-support", opt::value<bool>()->default_value(true), "Whether 32MB SDRAM is supported")
            ("240x320-support", opt::value<bool>(), "Whether a 240x320x16 LCD (HW-W) is supported")
            ("uses-lcd-blit", opt::value<bool>(), "Whether the new lcd_blit API is being used");

    opt::options_description all("All options");
    all.add(required).add(additional);

    opt::variables_map args;
    opt::store(opt::command_line_parser(argc, argv).options(all).run(), args);

    if(args.count("help"))
    {
        std::cout << "genzehn 1.5.0 by Fabian Vogt" << std::endl
                  << all << std::endl;
        return 0;
    }

    if(args.count("info"))
    {
        if(args.count("input") != 1)
        {
            std::cerr << "You need to supply an input file: genzehn --info --input=file.tns" << std::endl;
            return 1;
        }

        Zehn_header header;
        uint32_t buffer[5120];
        std::ifstream zehn_file(args["input"].as<std::string>(), std::ifstream::binary);
        if(!zehn_file || (zehn_file.read(reinterpret_cast<char*>(buffer), sizeof(buffer)), zehn_file.gcount()) == 0)
        {
            std::cerr << "Failed to load '" << args["input"].as<std::string>() << "'!" << std::endl;
            return 1;
        }

        //Try to find a Zehn signature in the first sizeof(buffer) bytes (same as in ndless_resources)
        size_t words_read = zehn_file.gcount() / sizeof(uint32_t);
        int zehn_start = -1;
        for(unsigned int i = 0; i < words_read - 1; ++i)
        {
            if(buffer[i] == ZEHN_SIGNATURE && buffer[i + 1] == ZEHN_VERSION)
            {
                zehn_start = i * sizeof(uint32_t);
                break;
            }
        }

        if(zehn_start == -1)
        {
            std::cerr << "Input is not a supported Zehn file!" << std::endl;
            return 1;
        }

        //Clear the EOF-bit, otherwise seekg will fail (wtf)
        zehn_file.clear();
        zehn_file.seekg(zehn_start, std::ios::beg);
        if(!zehn_file.read(reinterpret_cast<char*>(&header), sizeof(header)))
        {
            std::cerr << "Failed to read header!" << std::endl;
            return 1;
        }

        std::cout << std::hex << "Zehn header starts at byte 0x" << zehn_start << std::endl;

        std::cout << std::dec
                     << header.reloc_count << "\trelocations" << std::endl
                     << header.flag_count << "\tflags" << std::endl
                     << header.extra_size << "\tbytes extra data" << std::endl
                     << header.alloc_size << "\tbytes needed to load this file" << std::endl
                     << header.file_size << "\tbytes Zehn executable file" << std::endl;

	std::cout << std::hex << "Entry point:\t" << header.entry_offset << std::endl;

        std::vector<Zehn_reloc> relocs(header.reloc_count);
        std::vector<Zehn_flag> flags(header.flag_count);
        std::vector<uint8_t> extra_data(header.extra_size);

        if(!zehn_file.read(reinterpret_cast<char*>(relocs.data()), sizeof(Zehn_reloc) * header.reloc_count))
        {
            std::cerr << "Failed to read relocs!" << std::endl;
            return 1;
        }

        if(!zehn_file.read(reinterpret_cast<char*>(flags.data()), sizeof(Zehn_flag) * header.flag_count))
        {
            std::cerr << "Failed to read flags!" << std::endl;
            return 1;
        }

        if(!zehn_file.read(reinterpret_cast<char*>(extra_data.data()), sizeof(uint8_t) * header.extra_size))
        {
            std::cerr << "Failed to read extra data!" << std::endl;
            return 1;
        }

        if(header.reloc_count != 0 && relocs[0].type == Zehn_reloc_type::FILE_COMPRESSED)
            std::cout << "This file is compressed (type " << relocs[0].offset << ")" << std::endl;

        std::cout << std::endl;
        for(auto flag : flags)
        {
            switch(flag.type)
            {
            case Zehn_flag_type::EXECUTABLE_NAME:
                std::cout << "Application: " << zehn_get_string(flag.data, extra_data) << std::endl;
                break;
            case Zehn_flag_type::EXECUTABLE_VERSION:
                std::cout << "Version: " << flag.data << std::endl;
                break;
            case Zehn_flag_type::EXECUTABLE_AUTHOR:
                std::cout << "Author: " << zehn_get_string(flag.data, extra_data) << std::endl;
                break;
            case Zehn_flag_type::EXECUTABLE_NOTICE:
                std::cout << "Notice: " << zehn_get_string(flag.data, extra_data) << std::endl;
                break;
            case Zehn_flag_type::NDLESS_VERSION_MAX:
            case Zehn_flag_type::NDLESS_VERSION_MIN:
            case Zehn_flag_type::NDLESS_REVISION_MAX:
            case Zehn_flag_type::NDLESS_REVISION_MIN:
            case Zehn_flag_type::RUNS_ON_32MB:
            case Zehn_flag_type::RUNS_ON_CLICKPAD:
            case Zehn_flag_type::RUNS_ON_COLOR:
            case Zehn_flag_type::RUNS_ON_TOUCHPAD:
                //TODO
                break;
            case Zehn_flag_type::RUNS_ON_HWW:
                if(flag.data)
                    std::cout << "This executable supports the HW-W 240x320 LCD." << std::endl;
                break;
            case Zehn_flag_type::USES_LCD_BLIT:
                if(flag.data)
                    std::cout << "This executable uses the new lcd_blit API." << std::endl;
                break;

            default:
                std::cout << "Unknown flag type " << static_cast<int>(flag.type) << std::endl;
                break;
            }
        }

        return 0;
    }

    if(args.count("input") != 1 || args.count("output") != 1)
    {
        std::cerr << "Input and output file names not provided!" << std::endl;
        return 1;
    }

    bool verbose = args.count("verbose") > 0, should_compress = args.count("compress") > 0;

    elfio input_reader;

    if(!input_reader.load(args["input"].as<std::string>()))
    {
        std::cerr << "Failed to load '" << args["input"].as<std::string>() << "'!" << std::endl;
        return 1;
    }

    if(input_reader.get_machine() != EM_ARM)
    {
        std::cerr << "Input not for ARM!" << std::endl;
        return 1;
    }

    std::ofstream output_writer;
    output_writer.open(args["output"].as<std::string>(), std::ios::out | std::ios::trunc | std::ios::binary);
    if(!output_writer.is_open())
    {
        std::cerr << "Failed to open '" << args["output"].as<std::string>() << std::endl;
        return 2;
    }

    Zehn_header header;
    uint32_t skipped_nobits = 0; //e.g. size of skipped .bss at the end
    std::vector<Zehn_reloc> reloc_table;
    std::vector<Zehn_flag> flag_table;
    std::vector<uint8_t> extra_data;
    std::vector<uint8_t> exec_data;

    //For SET_ZERO
    std::set<Elf_Xword> undefined_symbols; uint32_t got_address = 0; std::set<uint32_t> undo_relocs;

    if(verbose)
        std::cout << "Generating Zehn file, version " << ZEHN_VERSION << "." << std::endl;

    header.signature = ZEHN_SIGNATURE;
    header.version = ZEHN_VERSION;
    header.entry_offset = input_reader.get_entry();

    if(verbose)
        std::cout << "Entry at 0x" << std::hex << header.entry_offset << "." << std::endl;

    //Fill flags using the command line options
    if(args.count("name"))
        flag_table.push_back({Zehn_flag_type::EXECUTABLE_NAME, zehn_extra_string(args["name"].as<std::string>(), extra_data)});
    if(args.count("author"))
        flag_table.push_back({Zehn_flag_type::EXECUTABLE_AUTHOR, zehn_extra_string(args["author"].as<std::string>(), extra_data)});
    if(args.count("version"))
        flag_table.push_back({Zehn_flag_type::EXECUTABLE_VERSION, args["version"].as<uint32_t>()});
    if(args.count("notice"))
        flag_table.push_back({Zehn_flag_type::EXECUTABLE_NOTICE, zehn_extra_string(args["notice"].as<std::string>(), extra_data)});

    if(args.count("ndless-min"))
        flag_table.push_back({Zehn_flag_type::NDLESS_VERSION_MIN, args["ndless-min"].as<uint32_t>()});
    if(args.count("ndless-rev-min"))
        flag_table.push_back({Zehn_flag_type::NDLESS_REVISION_MIN, args["ndless-rev-min"].as<uint32_t>()});
    if(args.count("ndless-max"))
        flag_table.push_back({Zehn_flag_type::NDLESS_VERSION_MAX, args["ndless-max"].as<uint32_t>()});
    if(args.count("ndless-rev-max"))
        flag_table.push_back({Zehn_flag_type::NDLESS_REVISION_MAX, args["ndless-rev-max"].as<uint32_t>()});

    flag_table.push_back({Zehn_flag_type::RUNS_ON_COLOR, args["color-support"].as<bool>()});
    flag_table.push_back({Zehn_flag_type::RUNS_ON_CLICKPAD, args["clickpad-support"].as<bool>()});
    flag_table.push_back({Zehn_flag_type::RUNS_ON_TOUCHPAD, args["touchpad-support"].as<bool>()});
    flag_table.push_back({Zehn_flag_type::RUNS_ON_32MB, args["32MB-support"].as<bool>()});

    // libndls.h places markers into the .data section
    bool using_old_lcd_api = false, using_new_lcd_api = false;

    //Now the important stuff, go through every section with ALLOC attribute and find all undefined symbols
    for(unsigned int i = 0; i < input_reader.sections.size(); ++i)
    {
        section *s = input_reader.sections[i];

        if(verbose)
            std::cout << "Section '" << s->get_name() << "' has flags 0x" << std::hex << s->get_flags() << "." << std::endl;

        if(s->get_type() == SHT_SYMTAB)
        {
            symbol_section_accessor ssa(input_reader, s);
            Elf_Xword count = ssa.get_symbols_num();
            for(Elf_Xword i = 0; i < count; ++i)
            {
                Elf_Half section; std::string name; unsigned char bind, type;
                Elf64_Addr u1; Elf_Xword u2; unsigned char u3; //Unused
                if(!ssa.get_symbol(i, name, u1, u2, bind, type, section, u3))
                    continue;

                // Markers that were placed into the .elf by libndls.h
                if(name == "_genzehn_new_lcd_api")
                    using_new_lcd_api = true;
                else if(name == "_genzehn_old_lcd_api")
                    using_old_lcd_api = true;

                if(section == SHN_UNDEF)
                {
                    if(bind != STB_WEAK && type != STT_NOTYPE)
                    {
                        std::cerr << "\tSymbol '" << name << "' isn't defined anywhere and not weak!" << std::endl;
                        return 1;
                    }

                    undefined_symbols.insert(i);

                    if(verbose)
                        std::cout << "\tSymbol '" << name << "' is undefined, but weak." << std::endl;
                }
            }

            continue;
        }

        if((s->get_flags() & SHF_ALLOC) == 0)
        {
            if(verbose)
                std::cout << "\tSkipping." << std::endl;
            continue;
        }

        if(s->get_name() == ".got")
            got_address = s->get_address();

        if(verbose)
            std::cout << "\tIt will be placed at 0x" << std::hex << s->get_address() << " (size 0x" << s->get_size() << ")." << std::endl;

        if(s->get_address() < exec_data.size())
        {
            std::cerr << "\tSection '" << s->get_name() << "' is overlapping!" << std::endl;
            return 1;
        }
        else if(s->get_address() > exec_data.size())
        {
            //This is likely to happen for alignment reasons
            if(verbose)
                std::cerr << "\tWarning: Section '" << s->get_name() << "' not directly following! (is at 0x" << std::hex << s->get_address() << " but I'm currently at 0x" << exec_data.size() << ")" << std::endl;

            exec_data.resize(s->get_address());
        }

        //Skip .bss
        if(s->get_type() == SHT_NOBITS)
        {
            if(verbose)
                std::cout << "\tNOBITS section at 0x" << std::hex << s->get_address() << "." << std::endl;

            if(args.count("include-bss") == 0)
                skipped_nobits = s->get_size();
            else
                exec_data.resize(exec_data.size() + s->get_size());

            continue;
        }
        else if(skipped_nobits != 0)
        {
            std::cerr << "\tWarning: NOBITS section (like .bss) not at the end! (" << s->get_name() << " is after it)" << std::endl;

            exec_data.resize(exec_data.size() + skipped_nobits);
            skipped_nobits = 0; //Now there is no additional space at the end anymore
        }

        exec_data.resize(exec_data.size() + s->get_size());
        std::copy(s->get_data(), s->get_data() + s->get_size(), exec_data.data() + s->get_address());
    }

    bool uses_lcd_blit = false;
    if(args.count("uses-lcd-blit"))
        uses_lcd_blit = args["uses-lcd-blit"].as<bool>();
    else
    {
        if(using_old_lcd_api == true && using_new_lcd_api == true)
        {
            std::cerr << "Warning: Using both the old (SCREEN_BASE_ADDRESS) and new (lcd_blit) API!" << std::endl
                      << "Assuming '--uses-lcd-blit false'!" << std::endl;
        }
        else if(using_old_lcd_api == false && using_new_lcd_api == false)
        {
            std::cerr << "Warning: Using neither old (SCREEN_BASE_ADDRESS) nor new (lcd_blit) API!" << std::endl
                      << "Assuming '--uses-lcd-blit false'!" << std::endl;
        }
        else if(using_new_lcd_api)
            uses_lcd_blit = true;
    }

    flag_table.push_back({Zehn_flag_type::USES_LCD_BLIT, uses_lcd_blit});

    bool hww_compat = uses_lcd_blit;
    if(args.count("240x320-support"))
        hww_compat = args["240x320-support"].as<bool>();

    if(!hww_compat)
        std::cerr << "Warning: Your application does not appear to support 240x320px displays!" << std::endl
                  << "If it does, override with '--240x320-support true'." << std::endl;

    flag_table.push_back({Zehn_flag_type::RUNS_ON_HWW, hww_compat});

    // Whether there is a relocation at an unaligned address
    bool unaligned_reloc_found = false;

    //Find all relocations that have to be made at startup
    for(unsigned int i = 0; i < input_reader.sections.size(); ++i)
    {
        section *s = input_reader.sections[i];

        if(s->get_name() == ".got")
        {
            if(verbose)
                std::cout << "Found .got section." << std::endl;

            if(*reinterpret_cast<const uint32_t*>(s->get_data() + s->get_size() - 4) != 0xFFFFFFFF)
            {
                std::cerr << "Error: .got section doesn't end with 0xFFFFFFFF!" << std::endl;
                return 1;
            }

            if(s->get_address() & 0b11)
            {
                std::cerr << "Error: .got section not aligned to 4-byte boundary!" << std::endl;
                return 1;
            }

            reloc_table.push_back({Zehn_reloc_type::ADD_BASE_GOT, static_cast<uint32_t>(s->get_address())});

            continue;
        }

        if(s->get_type() == SHT_RELA)
        {
            std::cerr << "RELA type relocation is not supported!" << std::endl;
            return 1;
        }
        else if(s->get_type() != SHT_REL)
            continue;

        //Find out whether the associated section has to be ALLOC'd
        std::string name_of_relocated_section = s->get_name().substr(4);
        bool need_to_reloc = false;
        for(unsigned int i = 0; i < input_reader.sections.size(); ++i)
        {
            if(input_reader.sections[i]->get_name() == name_of_relocated_section)
            {
                need_to_reloc = (input_reader.sections[i]->get_flags() & SHF_ALLOC);
                break;
            }
        }

        if(!need_to_reloc)
        {
            if(verbose)
                std::cout << "Skipping relocation section '" << s->get_name() << "' as it will not be loaded." << std::endl;

            continue;
        }

        unsigned int entries_count = s->get_size() / sizeof(Elf32_Rel);

        if(verbose)
            std::cout << "Found relocation section '" << s->get_name() << "' (" << std::dec << entries_count << " entries)." << std::endl;

        //Iterate through each entry
        const Elf32_Rel *entries = reinterpret_cast<const Elf32_Rel*>(s->get_data()), *entries_end = entries + entries_count;
        for(const Elf32_Rel *entry = entries; entry < entries_end; ++entry)
        {
            if(undefined_symbols.find(ELF32_R_SYM(entry->r_info)) != undefined_symbols.end())
            {
                if(verbose)
                    std::cout << "\tSkipping relocation of 0x" << std::hex << entry->r_offset << ", because it's undefined." << std::endl;

                if(ELF32_R_TYPE(entry->r_info) == 26) //R_ARM_GOT_BREL -> Undo reloc, as the whole got has been relocated
                {
                    uint32_t got_entry_addr = *reinterpret_cast<uint32_t*>(exec_data.data() + entry->r_offset);

                    //Only undo relocs that haven't already been undone
                    if(undo_relocs.find(got_address + got_entry_addr) == undo_relocs.end())
                    {
                        undo_relocs.insert(got_address + got_entry_addr);

                        if(verbose)
                            std::cout << "\tUndo-reloc for 0x" << std::hex << got_address + got_entry_addr << "." << std::endl;
                    }
                }

                continue;
            }

            uint8_t type = ELF32_R_TYPE(entry->r_info);
            switch(type)
            {
            case 2: //R_ARM_ABS32
            case 38: //R_ARM_TARGET1
                if(verbose)
                    std::cout << "\tNeed Reloc at 0x" << std::hex << entry->r_offset << "." << std::endl;

                if(entry->r_offset & 0b11)
                {
                    if(verbose)
                        std::cout << "\t\tReloc is unaligned." << std::endl;

                    if(!unaligned_reloc_found) //Only add marker if not already added
                    {
                        unaligned_reloc_found = true;
                        reloc_table.push_back({Zehn_reloc_type::UNALIGNED_RELOC, 0});
                        if(verbose)
                            std::cout << "\t\tUnaligned marker added." << std::endl;
                    }
                }

                reloc_table.push_back({Zehn_reloc_type::ADD_BASE, static_cast<uint32_t>(entry->r_offset)});
                break;
            }
        }
    }

    //Insert the undo relocs at the end
    for(uint32_t offset : undo_relocs)
        reloc_table.push_back({Zehn_reloc_type::SET_ZERO, offset});

    //Add padding for extra_data if necessary
    if(extra_data.size() % 4 != 0)
        extra_data.resize((extra_data.size() + 4) & ~3);

    std::vector<uint8_t> compressed_exec;

    if(should_compress)
    {
        if(verbose)
            std::cout << "Compressing executable... ";

        uLongf compressed_size = compressBound(exec_data.size());
        compressed_exec.resize(compressed_size);
        if(compress(compressed_exec.data(), &compressed_size, exec_data.data(), exec_data.size()) != Z_OK)
        {
            std::cerr << "Compression failed!" << std::endl;
            return 1;
        }

        compressed_exec.resize(compressed_size);

        //The compress marker has to come before other relocs
        reloc_table.insert(reloc_table.begin(), {Zehn_reloc_type::FILE_COMPRESSED, static_cast<uint32_t>(Zehn_compress_type::ZLIB)});

        if(verbose)
            std::cout << "done!" << std::endl;
    }

    header.reloc_count = reloc_table.size();
    header.flag_count = flag_table.size();
    header.extra_size = extra_data.size();

    header.file_size = sizeof(header)
                    + reloc_table.size() * sizeof(Zehn_reloc)
                    + flag_table.size() * sizeof(Zehn_flag)
                    + extra_data.size() * sizeof(uint8_t)
                    + exec_data.size() * sizeof(uint8_t);
    header.alloc_size = header.file_size + skipped_nobits;

    if(should_compress)
    {
        header.file_size -= exec_data.size();
        header.file_size += compressed_exec.size();
    }
    

    if(verbose)
    {
        std::cout << std::endl << "Zehn creation succeeded:" << std::endl << std::dec
                     << "\t" << header.reloc_count << "\trelocations" << std::endl
                     << "\t\t" << undo_relocs.size() << "\tundo-relocations" << std::endl
                     << "\t" << header.flag_count << "\tflags" << std::endl
                     << "\t" << header.extra_size << "\tbytes extra data" << std::endl
                     << "\t" << header.alloc_size << "\tbytes needed to load this file" << std::endl
                     << "\t" << header.file_size << "\tbytes Zehn executable file" << std::endl;

        if(should_compress)
            std::cout << "\t" << (exec_data.size() - compressed_exec.size()) << "\tbytes saved by compression" << std::endl;
    }

    output_writer.write(reinterpret_cast<const char*>(&header), sizeof(header));
    output_writer.write(reinterpret_cast<const char*>(reloc_table.data()), reloc_table.size() * sizeof(Zehn_reloc));
    output_writer.write(reinterpret_cast<const char*>(flag_table.data()), flag_table.size() * sizeof(Zehn_flag));
    output_writer.write(reinterpret_cast<const char*>(extra_data.data()), extra_data.size() * sizeof(uint8_t));

    if(should_compress)
        output_writer.write(reinterpret_cast<const char*>(compressed_exec.data()), compressed_exec.size() * sizeof(uint8_t));
    else
        output_writer.write(reinterpret_cast<const char*>(exec_data.data()), exec_data.size() * sizeof(uint8_t));

    output_writer.close();

    return 0;
}
