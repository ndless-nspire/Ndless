#include <cstdint>
#include <algorithm>
#include <functional>
#include <iostream>
#include <iterator>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>

std::string luaForOS(std::string installer_filename)
{
  	//Build the buffer content
	std::ifstream installer_bin(installer_filename, std::ios::binary);

	//Padding for the installer
	std::vector<uint8_t> buffer_content(0);

	buffer_content.insert(buffer_content.end(), std::istreambuf_iterator<char>{installer_bin}, std::istreambuf_iterator<char>{});

	//4-byte alignment
	buffer_content.resize((buffer_content.size() + 4) & ~3);

	std::cout << "Size of buffer: 0x" << std::hex << buffer_content.size() << std::endl;

	//Now generate a lua formatted string
	std::ostringstream ss(std::ios_base::ate);
	std::ostringstream line(std::ios_base::ate);
	line.str("s = \"");

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
		std::cout << "Usage: " << argv[0] << " installer.bin Problem1.xml" << std::endl;
		return 1;
	}

	//Write LUA
	std::ostringstream lua;

	lua << luaForOS(argv[1]) << std::endl;

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
	
	output << lua_escaped;

	return 0;
}
