/**
 * @file prizm.h
 * @author Julian Mackeben aka compu <compujuckel@googlemail.com>
 * @author Julien Savard aka Juju <juju2143@gmail.com>
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
 * Header for Prizm platform
 */
 
#ifndef PRIZM_H
#define PRIZM_H

// Put headers required for our platform here
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <fxcg/display.h>
#include <fxcg/keyboard.h>
#include <fxcg/serial.h>

typedef enum { FALSE, TRUE } BOOL;

// Functions undefined on the Prizm who are defined on the Nspire
#define idle() 0 // Power saver on the Nspire, useless on the Prizm
void wait_key_pressed(void); // blocks until a key is pressed
void wait_no_key_pressed(void); // blocks until all keys are released
BOOL any_key_pressed(void); // non-blocking, TRUE if any key pressed
int isKeyPressed(int key);

void keyupdate(void);

// not defined yet on the prizm, so we make dumb definitions so the 
// functions who uses it fails, remove it when it gets defined in the SDK
struct stat {
	off_t st_size;
};
#define stat(a,b) -1
#define strerror(errno) errno

#define SCREEN_WIDTH LCD_WIDTH_PX
#define SCREEN_HEIGHT LCD_HEIGHT_PX
#define VRAM (unsigned short*)0xA8000000;

// Fullscreen definitions

#define NIO_MAX_ROWS 27
#define NIO_MAX_COLS 64

#endif
