/**
 * @file console.c
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
 * C++ specific console header
 */

extern "C" {
	#include "nspireio.h"
}

#include "ios_base.ipp"

#ifndef CONSOLE_HPP
#define CONSOLE_HPP

namespace nio
{
	enum color
	{
		COLOR_BLACK,
		COLOR_RED,
		COLOR_GREEN,
		COLOR_YELLOW,
		COLOR_BLUE,
		COLOR_MAGENTA,
		COLOR_CYAN,
		COLOR_GRAY,
		COLOR_LIGHTBLACK,
		COLOR_LIGHTRED,
		COLOR_LIGHTGREEN,
		COLOR_LIGHTYELLOW,
		COLOR_LIGHTBLUE,
		COLOR_LIGHTMAGENTA,
		COLOR_LIGHTCYAN,
		COLOR_WHITE
	};
	
	enum cursor
	{
		CURSOR_BLOCK,
		CURSOR_UNDERSCORE,
		CURSOR_VERTICAL,
		CURSOR_CUSTOM,
		CURSOR_ADAPTIVE
	};
	
	extern const int MAX_ROWS;
	extern const int MAX_COLS;
	
	class console : public ios_base<console>
	{
	public:
		console(const int size_x = MAX_COLS, const int size_y = MAX_ROWS, const int offset_x = 0, const int offset_y = 0, enum color background_color = COLOR_WHITE, enum color foreground_color = COLOR_BLACK, const bool drawing_enabled = true);
		console(const char* path);
		~console();
		
		void cls();
		void color(enum color background_color, enum color foreground_color);
		enum color foreground_color() const;
		void foreground_color(enum color clr);
		enum color background_color() const;
		void background_color(enum color clr);
		void drawing_enable(const bool enable_drawing);
		
		void cursor_enable(const bool enable_cursor);
		void cursor_type(enum cursor crsr);
		void cursor_width(int width);
		void cursor_custom(unsigned char cursor_data[6]);
		
		void save(const char* path);
		
		virtual void put(char ch);
		virtual void write(const char* s, streamsize n);
		virtual void flush();
		
		virtual int gcount() const;
		virtual int get();
		virtual void get(int& c);
		virtual void get(char* s, streamsize n);
		virtual void getline(char* s, streamsize n);
		
	protected:
		void csl_drawchar(const int pos_x, const int pos_y);
		void vram_csl_drawchar(const int pos_x, const int pos_y);
		void csl_savechar(const char ch, const int pos_x, const int pos_y);
		void scroll();
		
	private:
		nio_console* c;
	};
}

#endif