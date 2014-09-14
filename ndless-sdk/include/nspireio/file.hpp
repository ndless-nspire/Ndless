/**
 * @file file.hpp
 * @author  Julian Mackeben aka compu <compujuckel@googlemail.com>
 * @version 3.1
 *
 * @section LICENSE
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 *
 * @section DESCRIPTION
 *
 * C++ specific file header
 */

#include "platform.h"
#include "ios_base.ipp"

#ifndef FILE_HPP
#define FILE_HPP

namespace nio
{
	class file : public ios_base<file>
	{
	public:
		enum seekdir
		{
			beg = SEEK_SET,
			cur = SEEK_CUR,
			end = SEEK_END
		};
		
		file();
		file(const char* filename, const char* mode);
		~file();
		
		void open(const char* filename, const char* mode);
		bool is_open();
		void close();
		
		virtual void put(char ch);
		virtual void write(const char* s, streamsize n);
		virtual void flush();
		
		virtual int gcount() const;
		virtual int get();
		virtual void get(int& c);
		virtual void get(char* s, streamsize n);
		virtual void getline(char* s, streamsize n);
		
		int tellp();
		void seekp(int pos);
		void seekp(int off, seekdir way);
		
	private:
		FILE* fd;
	};
}

#endif