#include <cstdint>
#include <algorithm>
#include <functional>
#include <iostream>
#include <iterator>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>

enum OS : int {
	NCAS = 0,
	CAS,
	CX,
	CXCAS
};

static uint32_t overflow_addr[4] = { 0x10000000, 0x10000000, 0x1110d843, 0x1116d752 };
static const uint32_t struct_ptr[4] = { 0x10000000, 0x10000000, 0x10000000, 0x1122d6f4 };
static const uint32_t loc_code[4] = { 0x10000000, 0x10000000, 0x10000000, 0x1122D004 };
static uint32_t orig_struct[][32] = {{}, {}, {},
{
0x11767E90,
0x117E7F08,
0x11767FE0,
0x11768BA4,
0x11768638,
0x11769110,
0x117691B4,
0x11769258,
0x117693E0,
0x00000001,
0x1009AE7C,
0x00008001,
0x11769568,
0x11767F68,
0x11767EAC,
0x11767E38,
0x00000000,
0x1122d99c,
0x00000000,
0x11767ebc,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x11767ef8,
0x11767e80,
0x00000000,
0x1122d99c,
0x11767bc0,
0x11767f94,
0x00000000
}};

int main(int argc, char **argv)
{
	if(argc != 3)
	{
		std::cout << "Usage: installer.bin Problem1.xml" << std::endl;
		return 1;
	}

	int os = OS::CXCAS;

	//Build the buffer content
	std::ifstream installer_bin(argv[1], std::ios::binary);

	std::vector<uint8_t> toplevel_pad(4 - (overflow_addr[os] & 3));
	overflow_addr[os] = (overflow_addr[os] + 4) & ~3;

	//Padding for the installer
	std::vector<uint8_t> buffer_content(loc_code[os] - overflow_addr[os]);

	buffer_content.insert(buffer_content.end(), std::istreambuf_iterator<char>{installer_bin}, std::istreambuf_iterator<char>{});

	//4-byte alignment
	buffer_content.resize((buffer_content.size() + 4) & ~3);

	uint32_t newstruct_addr = buffer_content.size() + overflow_addr[os];
	orig_struct[os][10] = loc_code[os];

	//Copy patched struct into the buffer	
	std::vector<uint8_t> patched_struct(reinterpret_cast<uint8_t*>(orig_struct[os]), reinterpret_cast<uint8_t*>(orig_struct[os] + sizeof(orig_struct[os])));
	buffer_content.insert(buffer_content.end(), patched_struct.begin(), patched_struct.end());

	//And write the address of the patched struct at the correct position
	uint32_t ptr_pos = struct_ptr[os] - overflow_addr[os];

	if(ptr_pos < buffer_content.size())
	{
		std::cerr << "Binary too large!" << std::endl;
		return 1;
	}

	buffer_content.resize(ptr_pos);
	buffer_content.push_back(newstruct_addr);
	buffer_content.push_back(newstruct_addr >> 8);
	buffer_content.push_back(newstruct_addr >> 16);
	buffer_content.push_back(newstruct_addr >> 24);

	buffer_content.insert(buffer_content.begin(), toplevel_pad.begin(), toplevel_pad.end());

	//The buffer mustn't contain any 0s
	std::replace(buffer_content.begin(), buffer_content.end(), 0, 1);

	std::cout << "Size of buffer: 0x" << std::hex << buffer_content.size() << std::endl;

	//Now generate a lua formatted string
	std::ostringstream ss(std::ios_base::ate);
	ss.str("u = string.uchar\ns = \"\"\n");

	std::ostringstream line(std::ios_base::ate);
	line.str("s = s..\"");

	auto i = buffer_content.begin();
	while(i != buffer_content.end())
	{
		auto j = std::adjacent_find(i, buffer_content.end(), std::not_equal_to<uint8_t>());
		int count = std::distance(i, j) + (j == buffer_content.end() ? 0 : 1);

		if(count < 8)
			count = 1;

		if(count == 1)
			line << "\\" << (int)*i;
		else
		{
			ss << line.str() << "\"" << std::endl;
			line.str("s = s..string.rep(\"\\"); line << (int)*i << "\", " << count << ")..\"";
		}

		if(line.tellp() >= 320 || i + count == buffer_content.end())
		{
			ss << line.str() << "\"" << std::endl;
			line.str("s = s..\"");
		}

		i += count;
	}

	//Write LUA
	std::ostringstream lua;

	lua << ss.str() << std::endl;

	lua << "on = {}" << std::endl
		<< "function on.restore()" << std::endl
		<< "tiassert.assert(false, 0, s)" << std::endl
		<< "end" << std::endl
		<< "return {QuestionProperties={prompt=\"\"}, DropZone={vScreen={}}}" << std::endl;

	//XML-Escape LUA
	std::string lua_escaped = lua.str();

	size_t pos;
	while((pos = lua_escaped.find("\"", pos)) != std::string::npos)
	{
		lua_escaped.replace(pos, 1, "&quot;");
		pos += 5;
	}

	//Write XML
	std::ofstream output(argv[2]);
	
	output << "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>" << std::endl
		<< "<prob xmlns=\"urn:TI.Problem\" ver=\"1.0\" pbname=\"\">" << std::endl
		<< "<sym></sym><card clay=\"0\" h1=\"10000\" h2=\"10000\" w1=\"10000\" w2=\"10000\"><isDummyCard>0</isDummyCard>" << std::endl
		<< "<flag>0</flag><wdgt xmlns:sc=\"urn:TI.ScriptApp\" type=\"TI.ScriptApp\" ver=\"1.0\">" << std::endl
		<< "<sc:mFlags>1024</sc:mFlags><sc:value>0</sc:value><sc:script version=\"512\" id=\"3\"></sc:script>" << std::endl
		<< "<sc:state>" << std::endl
		<< lua_escaped << std::endl
		<< "</sc:state><sc:scriptTitle></sc:scriptTitle></wdgt></card></prob>" << std::endl;

	return 0;
}
