/**
 * @file nspire.h
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
 * Header for Nspire platform
 */
 
#ifndef NSPIRE_H
#define NSPIRE_H

// Put headers required for our platform here
#include <os.h>

// wait_key_pressed() - blocks until a key is pressed
// wait_no_key_pressed() - blocks until all keys are released
// any_key_pressed() - non-blocking, TRUE if any key pressed


// color utility functions. By totorigolo.

#define getR(c) ((((c) & 0xF800) >> 11) * 8)
#define getG(c) ((((c) & 0x7E0) >> 5) * 4)
#define getB(c) (((c) & 0x1F) * 8)
#define getBW(c) ((((getR(c)) / 16) + ((getG(c)) / 16) + ((getB(c)) / 16)) / 3)

// Fullscreen definitions

#define NIO_MAX_ROWS 30
#define NIO_MAX_COLS 53

// Double buffering is Nspire-only at the moment

/** Initializes double buffering.
*/
void nio_scrbuf_init();

/** Clears the screen buffer.
*/
void nio_scrbuf_clear();

/** Flips screen and screenbuffer.
*/
void nio_scrbuf_flip();

/** Frees the screenbuffer and restores the screen to its original state.
*/
void nio_scrbuf_free();

#endif