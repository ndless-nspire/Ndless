/**
 * @file ios_base.hpp
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
 * C++ basic implementation of ios_base class
 */

extern "C" {
	#include "platform.h"
}

#ifndef IOS_BASE_HPP
#define IOS_BASE_HPP

namespace nio
{
	typedef int streamsize;
	
	template<class T>
	class ios_base
	{
	public:
		enum fmtflags
		{
			boolalpha	= (1u <<  0),
			showbase	= (1u <<  1),
			showpoint	= (1u <<  2),
			showpos		= (1u <<  3),
			skipws		= (1u <<  4),
			unitbuf		= (1u <<  5),
			uppercase	= (1u <<  6),
			dec			= (1u <<  7),
			hex			= (1u <<  8),
			oct			= (1u <<  9),
			fixed		= (1u << 10),
			scientific	= (1u << 11),
			internal	= (1u << 12),
			left		= (1u << 13),
			right		= (1u << 14),
			
			adjustfield	= left | right | internal,
			basefield 	= dec | oct | hex,
			floatfield	= scientific | fixed
		};
		
		enum iostate
		{
			eofbit		= (1u <<  0),
			failbit		= (1u <<  1),
			badbit		= (1u <<  2),
			goodbit		= (1u <<  3)
		};
		
		fmtflags flags() const;
		fmtflags flags(fmtflags fmtfl);
		
		fmtflags setf(fmtflags fmtl);
		fmtflags setf(fmtflags fmtl, fmtflags mask);
		
		void unsetf(fmtflags mask);
		
		streamsize precision() const;
		streamsize precision(streamsize prec);
		
		streamsize width() const;
		streamsize width(streamsize wide);
		
		bool good() const;
		bool eof() const;
		bool fail() const;
		bool bad() const;
		bool operator!() const;
		
		iostate rdstate() const;
		void setstate(iostate state);
		void clear(iostate state = goodbit);
		
		virtual void put(char ch) = 0;
		virtual void write(const char* s, streamsize n) = 0;
		virtual void flush() = 0;
		
		virtual streamsize gcount() const = 0;
		virtual int get() = 0;
		virtual void get(int& c) = 0;
		virtual void get(char* s, streamsize n) = 0;
		virtual void getline(char* s, streamsize b) = 0;
		
		T& operator<<(const char* val);
		T& operator<<(const int val);
		T& operator<<(const bool val);
		T& operator<<(ios_base& (*pf)(ios_base&));
		
		T& operator>>(char* val);
		T& operator>>(int& val);
		T& operator>>(bool& val);
		T& operator>>(ios_base& (*pf)(ios_base&));
		
	protected:
		iostate s;
		fmtflags f;
		streamsize p;
		streamsize w;
		streamsize count;
	};
	
	template<class T>
	ios_base<T>& dec(ios_base<T>& ios)
	{
		ios.setf(ios_base<T>::dec, ios_base<T>::basefield);
		return ios;
	}

	template<class T>
	ios_base<T>& hex(ios_base<T>& ios)
	{
		ios.setf(ios_base<T>::hex, ios_base<T>::basefield);
		return ios;
	}

	template<class T>
	ios_base<T>& oct(ios_base<T>& ios)
	{
		ios.setf(ios_base<T>::oct, ios_base<T>::basefield);
		return ios;
	}
	
	template<class T>
	ios_base<T>& boolalpha(ios_base<T>& ios)
	{
		ios.setf(ios_base<T>::boolalpha);
		return ios;
	}

	template<class T>
	ios_base<T>& noboolalpha(ios_base<T>& ios)
	{
		ios.unsetf(ios_base<T>::boolalpha);
		return ios;
	}

	template<class T>
	ios_base<T>& showbase(ios_base<T>& ios)
	{
		ios.setf(ios_base<T>::showbase);
		return ios;
	}

	template<class T>
	ios_base<T>& noshowbase(ios_base<T>& ios)
	{
		ios.unsetf(ios_base<T>::showbase);
		return ios;
	}

	template<class T>
	ios_base<T>& showpoint(ios_base<T>& ios)
	{
		ios.setf(ios_base<T>::showpoint);
		return ios;
	}

	template<class T>
	ios_base<T>& noshowpoint(ios_base<T>& ios)
	{
		ios.unsetf(ios_base<T>::showpoint);
		return ios;
	}

	template<class T>
	ios_base<T>& showpos(ios_base<T>& ios)
	{
		ios.setf(ios_base<T>::showpos);
		return ios;
	}

	template<class T>
	ios_base<T>& noshowpos(ios_base<T>& ios)
	{
		ios.unsetf(ios_base<T>::showpos);
		return ios;
	}

	template<class T>
	ios_base<T>& unitbuf(ios_base<T>& ios)
	{
		ios.setf(ios_base<T>::unitbuf);
		return ios;
	}

	template<class T>
	ios_base<T>& nounitbuf(ios_base<T>& ios)
	{
		ios.unsetf(ios_base<T>::unitbuf);
		return ios;
	}

	template<class T>
	ios_base<T>& skipws(ios_base<T>& ios)
	{
		ios.setf(ios_base<T>::skipws);
		return ios;
	}

	template<class T>
	ios_base<T>& noskipws(ios_base<T>& ios)
	{
		ios.unsetf(ios_base<T>::skipws);
		return ios;
	}

	template<class T>
	ios_base<T>& uppercase(ios_base<T>& ios)
	{
		ios.setf(ios_base<T>::uppercase);
		return ios;
	}

	template<class T>
	ios_base<T>& nouppercase(ios_base<T>& ios)
	{
		ios.unsetf(ios_base<T>::uppercase);
		return ios;
	}

	template<class T>
	ios_base<T>& internal(ios_base<T>& ios)
	{
		ios.setf(ios_base<T>::internal, ios_base<T>::adjustfield);
		return ios;
	}

	template<class T>
	ios_base<T>& left(ios_base<T>& ios)
	{
		ios.setf(ios_base<T>::left, ios_base<T>::adjustfield);
		return ios;
	}

	template<class T>
	ios_base<T>& right(ios_base<T>& ios)
	{
		ios.setf(ios_base<T>::right, ios_base<T>::adjustfield);
		return ios;
	}

	template<class T>
	ios_base<T>& fixed(ios_base<T>& ios)
	{
		ios.setf(ios_base<T>::fixed, ios_base<T>::floatfield);
		return ios;
	}

	template<class T>
	ios_base<T>& scientific(ios_base<T>& ios)
	{
		ios.setf(ios_base<T>::scientific, ios_base<T>::floatfield);
		return ios;
	}
	
	template<class T>
	ios_base<T>& endl(ios_base<T>& ios)
	{
		ios.put('\n');
		return ios;
	}

	template<class T>
	ios_base<T>& ends(ios_base<T>& ios)
	{
		ios.put('\0');
		return ios;
	}

	template<class T>
	ios_base<T>& flush(ios_base<T>& ios)
	{
		ios.flush();
		return ios;
	}
}

#endif