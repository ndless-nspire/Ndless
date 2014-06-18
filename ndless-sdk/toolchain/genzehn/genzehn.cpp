#include <iostream>

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

int main(int argc, char **argv)
{   
    opt::options_description required("Required options");
    required.add_options()
            ("input", opt::value<std::string>(), "ELF input file")
            ("output", opt::value<std::string>(), "Zehn output file");

    opt::options_description additional("Additional options");
    additional.add_options()
            ("help", "show this message")
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
            ("32MB-support", opt::value<bool>()->default_value(true), "Whether 32MB SDRAM is supported");

    opt::options_description all;
    all.add(required).add(additional);

    opt::variables_map args;
    opt::store(opt::command_line_parser(argc, argv).options(all).run(), args);

    if(args.count("help"))
    {
        std::cout << all << std::endl;
        return 0;
    }

    if(args.count("input") != 1 || args.count("output") != 1)
    {
        std::cerr << "Input and output file names not provided!" << std::endl;
        return 1;
    }

    bool verbose = args.count("verbose") > 0;

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
        flag_table.push_back({Zehn_flag_type::NDLESS_VERSION_MIN, args["ndless-rev-min"].as<uint32_t>()});
    if(args.count("ndless-max"))
        flag_table.push_back({Zehn_flag_type::NDLESS_VERSION_MIN, args["ndless-max"].as<uint32_t>()});
    if(args.count("ndless-rev-max"))
        flag_table.push_back({Zehn_flag_type::NDLESS_VERSION_MIN, args["ndless-rev-max"].as<uint32_t>()});

    flag_table.push_back({Zehn_flag_type::RUNS_ON_COLOR, args["color-support"].as<bool>()});
    flag_table.push_back({Zehn_flag_type::RUNS_ON_CLICKPAD, args["clickpad-support"].as<bool>()});
    flag_table.push_back({Zehn_flag_type::RUNS_ON_TOUCHPAD, args["touchpad-support"].as<bool>()});
    flag_table.push_back({Zehn_flag_type::RUNS_ON_32MB, args["32MB-support"].as<bool>()});

    //Now the important stuff, go through every section with LOAD attribute
    for(unsigned int i = 0; i < input_reader.sections.size(); ++i)
    {
        section *s = input_reader.sections[i];

        if(verbose)
            std::cout << "Section '" << s->get_name() << "' has flags 0x" << std::hex << s->get_flags() << "." << std::endl;

        if((s->get_flags() & SHF_ALLOC) == 0)
        {
            if(verbose)
                std::cout << "\tSkipping." << std::endl;
            continue;
        }

        if(verbose)
            std::cout << "\tIt will be placed at 0x" << std::hex << s->get_address() << " (size 0x" << s->get_size() << ")." << std::endl;

        if(s->get_address() < exec_data.size())
        {
            std::cerr << "\tSection '" << s->get_name() << "' is overlapping!" << std::endl;
            return 1;
        }
        else if(s->get_address() > exec_data.size())
        {
            std::cerr << "\tWarning: Section '" << s->get_name() << "' not directly following! (is at 0x" << std::hex << s->get_address() << " but I'm currently at 0x" << exec_data.size() << ")" << std::endl;

            exec_data.resize(s->get_address());
        }

        //Skip .bss
        if(s->get_type() == SHT_NOBITS)
        {
            if(verbose)
                std::cout << "\tNOBITS section at 0x" << std::hex << s->get_address() << "." << std::endl;

            skipped_nobits = s->get_size();
            continue;
        }
        else if(skipped_nobits != 0)
        {
            std::cerr << "Warning: NOBITS section (like .bss) not at the end! (" << s->get_name() << " is after it)" << std::endl;

            exec_data.resize(exec_data.size() + skipped_nobits);
            skipped_nobits = 0; //Now there is no additional space at the end anymore
        }

        exec_data.resize(exec_data.size() + s->get_size());
        std::copy(s->get_data(), s->get_data() + s->get_size(), exec_data.data() + s->get_address());
    }

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

            reloc_table.push_back({Zehn_reloc_type::ADD_BASE_GOT, static_cast<uint32_t>(s->get_address())});
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
            uint8_t type = ELF32_R_TYPE(entry->r_info);
            switch(type)
            {
            case 2: //R_ARM_ABS32
            case 38: //R_ARM_TARGET1
                if(verbose)
                    std::cout << "\tNeed Reloc at 0x" << std::hex << entry->r_offset << "." << std::endl;

                reloc_table.push_back({Zehn_reloc_type::ADD_BASE, static_cast<uint32_t>(entry->r_offset)});
                break;
            }
        }
    }

    //Add padding for extra_data if necessary
    if(extra_data.size() % 8 != 0)
        extra_data.resize((extra_data.size() + 8) & ~7);

    header.reloc_count = reloc_table.size();
    header.flag_count = flag_table.size();
    header.extra_size = extra_data.size();
    header.file_size = sizeof(header)
                    + reloc_table.size() * sizeof(Zehn_reloc)
                    + flag_table.size() * sizeof(Zehn_flag)
                    + extra_data.size() * sizeof(uint8_t)
                    + exec_data.size() * sizeof(uint8_t);
    header.alloc_size = header.file_size + skipped_nobits;

    if(verbose)
    {
        std::cout << std::endl << "Zehn creation succeeded:" << std::endl << std::dec
                     << "\t" << header.reloc_count << "\trelocations" << std::endl
                     << "\t" << header.flag_count << "\tflags" << std::endl
                     << "\t" << header.extra_size << "\tbytes extra data" << std::endl
                     << "\t" << header.alloc_size << "\tbytes needed to load this file" << std::endl
                     << "\t" << header.file_size << "\tbytes Zehn executable file" << std::endl;
    }

    output_writer.write(reinterpret_cast<const char*>(&header), sizeof(header));
    output_writer.write(reinterpret_cast<const char*>(reloc_table.data()), reloc_table.size() * sizeof(Zehn_reloc));
    output_writer.write(reinterpret_cast<const char*>(flag_table.data()), flag_table.size() * sizeof(Zehn_flag));
    output_writer.write(reinterpret_cast<const char*>(extra_data.data()), extra_data.size() * sizeof(uint8_t));
    output_writer.write(reinterpret_cast<const char*>(exec_data.data()), exec_data.size() * sizeof(uint8_t));

    output_writer.close();

    return 0;
}
