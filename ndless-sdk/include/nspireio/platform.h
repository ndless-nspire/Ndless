/**
 * @file platform.h
 * @author Julian Mackeben aka compu <compujuckel@googlemail.com>
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
 * Decide which header to use...
 */

// Includes for the different platforms here.

#ifndef PLATFORM_H
#define PLATFORM_H

#define NIO_CHAR_WIDTH 6
#define NIO_CHAR_HEIGHT 8


#ifdef _TINSPIRE
	#include "platform-nspire.h"
#endif
#ifdef PRIZM
	#include "platform-prizm.h"
#endif


// These functions are the same on all platforms...

void nio_pixel_set(const int x, const int y, const unsigned int color);
void nio_vram_pixel_set(const int x, const int y, const unsigned int color);
void nio_vram_draw(void);
unsigned int nio_cursor_clock(void);
char nio_ascii_get(int* adaptive_cursor_state);

/** Checks if there is data available at the serial port.
	@return TRUE if new data is available.
*/
BOOL uart_ready(void);

/** See [getchar](http://www.cplusplus.com/reference/clibrary/cstdio/getchar/)
	@return Char
*/
char uart_getchar(void);

/** See [gets](http://www.cplusplus.com/reference/clibrary/cstdio/gets/)
	@return Destination
*/
char* uart_gets(char* str) __attribute__((deprecated));

/** Like [gets](http://www.cplusplus.com/reference/clibrary/cstdio/gets/), but with a maximum length parameter
*/
char* uart_getsn(char* str, int num);

/** See [putchar](http://www.cplusplus.com/reference/clibrary/cstdio/putchar/)
*/
char uart_putchar(char character);

/** See [puts](http://www.cplusplus.com/reference/clibrary/cstdio/puts/)
    \note This DOES NOT append a newline (\\n) character.
*/
int uart_puts(const char *str);

/** See [printf](http://www.cplusplus.com/reference/clibrary/cstdio/printf/)
*/
void uart_printf(char *format, ...);

#endif
