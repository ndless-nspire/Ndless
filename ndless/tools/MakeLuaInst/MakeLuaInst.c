/****************************************************************************
 * Produce the dynamic part of the Lua installer file.
 * 
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 *
 * The Original Code is Ndless code.
 *
 * The Initial Developer of the Original Code is Olivier ARMAND
 * <olivier.calc@gmail.com>.
 * Portions created by the Initial Developer are Copyright (C) 2013
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): Excale
 ****************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdarg.h>

void error(const char* msg) {
	fprintf(stderr, "Error: %s.\n", msg);
	exit(1);	
}

unsigned file_size(FILE *f) {
  int pos, end;
  pos = ftell(f);
  fseek (f, 0, SEEK_END);
  end = ftell(f);
  fseek (f, pos, SEEK_SET);
  return end;
}

int sfprintf(FILE *stream, const char *format, ... ) {
	va_list argptr;
	va_start(argptr, format);
	int ret = vfprintf(stream, format, argptr);
	va_end(argptr);
	if (ret <= 0)
		error("can't write to output file");
	return ret;
}

int main(int argc, const char* argv[]) {
	if (argc != 3) {
		puts("Usage: MakeLuaInst <escaped_installer.bin> <output.lua>");
		return 0;
	}
	FILE *finst = fopen(argv[1], "rb");
	if (!finst) error("can't open input file");
	FILE *flua = fopen(argv[2], "wt");
	if (!flua) error("can't open output file");
	unsigned inst_size = file_size(finst);
	unsigned char *inbuf = malloc(inst_size);
	if (fread(inbuf, inst_size, 1, finst) != 1) error("can't read installer file");
	
	// header
	sfprintf(flua, "u=string.uchar\n");
	sfprintf(flua, "s=\"\"");
	
	// code. Use string.rep when possible to avoid any Lua memory error.
	unsigned char *p = inbuf;
	unsigned short prev_word = 0;
	unsigned line_size = 0;
	unsigned seq_length = 0;
	for (; 1; p += 2) {
		unsigned short word = 0;
		int end_of_file = 0;
		if (p >= inbuf + inst_size)
			end_of_file = 1;
		else
			word = (((unsigned short)*p) << 8) | ((unsigned short)(*(p+1)));
		// end of sequence
		if ( (seq_length > 0)
			 && ( end_of_file || (prev_word != word) ) ) {
			// flush
			if (line_size >= 50) // avoid "chunk has too many syntax levels" Lua error
				line_size = 0;
			if (line_size) {
				sfprintf(flua, "..");
			}
			else {
				sfprintf(flua, "\ns=s..");
			}
			line_size++;
            if (seq_length == 1) {
				sfprintf(flua, "u(0x%04hx)", (prev_word >> 8) | (prev_word << 8));
			} else {
               sfprintf(flua, "string.rep(u(0x%04hx),%u)", (prev_word >> 8) | (prev_word << 8), seq_length);
            }
			seq_length = 0;
		}
		// end of file
		if (end_of_file) break;
		// new sequence
		if (!seq_length)
			prev_word = word;
		// longer sequence
		seq_length++;
	}

	// padding
	int size_to_pad;
	size_to_pad = 0x13534 - inst_size; // to the OS pointer variable
	if (size_to_pad < 0)
		error("installer is too long");
	sfprintf(flua, "\ns=s..string.rep(u(0x0001),%i)", size_to_pad/2);
	
	// OS-specific addresses to jump to
	char *var_names[]      = {"ncas",    "cas",       "ncascx",   "cascx"};
	unsigned code_addr[]   = {0x10E60D14, 0x10E34D14, 0x110AEE5C, 0x11112E5C};
	unsigned i;
	for (i = 0; i < sizeof(var_names)/sizeof(var_names[0]); i++) {
		sfprintf(flua, "\ns_%s = u(0x%02hx%02hx) .. u(0x%02hx%02hx)", var_names[i],
				 (code_addr[i] & 0x0000FF00) >> 8, (code_addr[i] & 0x000000FF) >> 0, (code_addr[i] & 0xFF000000) >> 24, (code_addr[i] & 0x00FF0000) >> 16);
	}
	
	free(inbuf);
	fclose(finst);
	fclose(flua);
	return 0;
}
