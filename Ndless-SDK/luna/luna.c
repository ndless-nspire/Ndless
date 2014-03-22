#include <openssl/opensslconf.h>
#include OPENSSL_UNISTD
#include <openssl/des.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <zlib.h>
#include "minizip-1.1/zip.h"

#ifndef min
 #define min(a,b) (((a) < (b)) ? (a) : (b))
#endif

/* Reads an UTF-8 character from in to *c. Doesn't read at or after end. Returns a pointer to the next character. */
char *utf82unicode(char *in, char *end, unsigned long *c) {
	if (in == end) {
		*c = 0;
		return in;
	}
	if (!(*in & 0b10000000)) {
		*c = *in;
		return in + 1;
	}
	if ((*in & 0b11100000) == 0b11000000) {
		*c = (*in & 0b00011111) << 6;
		if (end > in + 1)
			*c |= *(in + 1) & 0b00111111;
		return min(end, in + 2);
	}
	if ((*in & 0b11110000) == 0b11100000) {
		*c = (*in & 0b00011111) << 12;
		if (end > in + 1)
			*c |= (*(in + 1) & 0b00111111) << 6;
		if (end > in + 2)
			*c |= *(in + 2) & 0b00111111;
		return min(end, in + 3);
	}
	if ((*in & 0b111110000) == 0b11110000) {
		*c = (*in & 0b00011111) << 18;
		if (end > in + 1)
			*c |= (*(in + 1) & 0b00111111) << 12;
		if (end > in + 2)
			*c |= (*(in + 2) & 0b00111111) << 6;
		if (end > in + 3)
			*c |= *(in + 3) & 0b00111111;
		return min(end, in + 4);
	}
	*c = 0;
	return in + 1;
}

/* sub-routine of xml_compress() to escape the unicode characters as required by the XML compression. Returns the new in_buf or NULL */
void *escape_unicode(char *in_buf, size_t header_size, size_t footer_size, size_t in_size, size_t *obuf_size) {
	char *p, *op;
	char *out_buf = malloc(header_size + in_size * 4 /* worst case */ + footer_size);
	if (!out_buf) {
		puts("escape_unicode: can't malloc");
		return NULL;
	}
	memcpy(out_buf, in_buf, header_size);

	p = in_buf + header_size;
	if (!memcmp(in_buf + header_size, "\xEF\xBB\xBF", 3)) // skip the UTF-8 BOM if any
		p += 3;
	for (op = out_buf + header_size; p < in_buf + header_size + in_size;) {
		unsigned long uc;
		p = utf82unicode(p, in_buf + header_size + in_size, &uc);
		if (uc < 0x80) {
			*op++ = (char)uc;
		} else if (uc < 0x800) {
			*op++ = (char)(uc >> 8);
			*op++ = (char)(uc);
		} else if (uc < 0x10000) {
			*op++ = 0b10000000;
			*op++ = (char)(uc >> 8);
			*op++ = (char)(uc);
		} else {
			*op++ = 0b00001000;
			*op++ = (char)(uc >> 16);
			*op++ = (char)(uc >> 8);
			*op++ = (char)(uc);
		}
	}
	*obuf_size = op - out_buf + footer_size;
	char *out_buf2 = realloc(out_buf, *obuf_size);
	if (!out_buf2) {
		free(out_buf);
		puts("escape_unicode: can't realloc");
		return NULL;
	}
	return out_buf2;
}

/* sub-routine of xml_compress() to escape the Lua script string. Returns the new in_buf or NULL */
void *escape_special_xml_chars(char *in_buf, size_t header_size, size_t in_size, size_t *obuf_size) {
	char *p;
	unsigned extend_with = 0;
	for (p = in_buf + header_size; p < in_buf + header_size + in_size; p++) {
		if (*p == '&') extend_with += 4; // amp;
		else if (*p == '<') extend_with += 3; // lt;
	}
	if (extend_with) {
		*obuf_size += extend_with;
		void *tmp_in_buf;
		if (!(tmp_in_buf = realloc(in_buf, *obuf_size))) {
			puts("can't realloc in_buf for special characters");
			free(in_buf);
			return NULL;
		}
		in_buf = tmp_in_buf;
		unsigned new_written = 0;
		for (p = in_buf + header_size; p < in_buf + header_size + in_size + new_written; p++) {
			if (*p == '&') {
				memmove(p + 5, p + 1, in_buf + header_size + in_size + new_written - p - 1);
				memcpy(p, "&amp;", 5);
				new_written += 4;
			} else if (*p == '<') {
				memmove(p + 4, p + 1, in_buf + header_size + in_size + new_written - p - 1);
				memcpy(p, "&lt;", 4);
				new_written += 3;
			}
		}
	}
	return in_buf;
}

/* sub-routine of xml_compress() in case of an XML problem as input. Returns the new in_buf or NULL */
void *reformat_xml_doc(char *in_buf, size_t header_size, size_t in_size, size_t *obuf_size) {
	char *out_buf = malloc(header_size + in_size);
	if (!out_buf) {
		puts("reformat_xml_doc: can't alloc");
		return NULL;
	}
	memcpy(out_buf, in_buf, header_size);
	char *in_ptr = in_buf;
	char *xml_start = NULL;
	while(in_ptr < in_buf + in_size + header_size - 5) {
		if (!memcmp(in_ptr, "<prob", 5)) {
			xml_start = in_ptr;
			break;
		}
		in_ptr++;
	}
	if (!xml_start) {
		puts("input isn't a TI-Nspire problem");
reformat_xml_quit:
		free(out_buf);
		return NULL;
	}
	int size_written = 0, read_offset = -1, size_to_read = in_size + header_size - (xml_start - in_buf);
	unsigned tagid_stack[100];
	unsigned tagid_head_index = 0;
	int last_tagid = -1;
	char *out_ptr = out_buf + header_size;
	// very weak XML parsing: all < must be escaped
	while(++read_offset <= size_to_read - 1) {
		if (xml_start[read_offset] == '<') {
			if (read_offset + 1 >= size_to_read) {
invalid_problem:
				puts("input problem is not a valid XML document");
				goto reformat_xml_quit;
			}
			if (xml_start[read_offset + 1] == '/') { // closing tag
				if (tagid_head_index == 0) {
					goto invalid_problem;
				}
				read_offset++;
				out_ptr[size_written++] = 0x0E;
				out_ptr[size_written++] = tagid_stack[--tagid_head_index];
				// skip the closing tag
				while(++read_offset <= size_to_read - 1 && xml_start[read_offset] != '>')
					;
				if (read_offset > size_to_read - 1) {
					goto invalid_problem;
				}
			}
			else { // opening tag
				if (tagid_head_index >= sizeof(tagid_stack)) {
					puts("input problem XML too deep");
					goto reformat_xml_quit;
				}
				tagid_stack[tagid_head_index++] = ++last_tagid;
				out_ptr[size_written++] = xml_start[read_offset];
			}
		} else {
			out_ptr[size_written++] = xml_start[read_offset];
		}
	}
	*obuf_size = header_size + size_written;
	out_buf = realloc(out_buf, *obuf_size);
	if (!out_buf) {
		puts("reformat_xml_doc: can't realloc out_buf");
		goto reformat_xml_quit;
	}
	free(in_buf);
	return out_buf;
}

/* Returns the output buffer, NULL on error. Fills obuf_size. */
void *xml_compress(char *inf_name, size_t *obuf_size, int infile_is_xml) {
	static const char lua_header[] =
		"\x54\x49\x58\x43\x30\x31\x30\x30\x2D\x31\x2E\x30\x3F\x3E\x3C\x70\x72"
		"\x6F\x62\x20\x78\x6D\x6C\x6E\x73\x3D\x22\x75\x72\x6E\x3A\x54\x49\x2E"
		"\x50\xA8\x5F\x5B\x1F\x0A\x22\x20\x76\x65\x72\x3D\x22\x31\x2E\x30\x22"
		"\x20\x70\x62\x6E\x61\x6D\x65\x3D\x22\x22\x3E\x3C\x73\x79\x6D\x3E\x0E"
		"\x01\x3C\x63\x61\x72\x64\x20\x63\x6C\x61\x79\x3D\x22\x30\x22\x20\x68"
		"\x31\x3D\x22\xF1\x00\x00\xFF\x22\x20\x68\x32\x3D\x22\xF1\x00\x00\xFF"
		"\x22\x20\x77\x31\x3D\x22\xF1\x00\x00\xFF\x22\x20\x77\x32\x3D\x22\xF1"
		"\x00\x00\xFF\x22\x3E\x3C\x69\x73\x44\x75\x6D\x6D\x79\x43\x61\x72\x64"
		"\x3E\x30\x0E\x03\x3C\x66\x6C\x61\x67\x3E\x30\x0E\x04\x3C\x77\x64\x67"
		"\x74\x20\x78\x6D\x6C\x6E\x73\x3A\x73\x63\x3D\x22\x75\x72\x6E\x3A\x54"
		"\x49\x2E\x53\xAC\x84\xF2\x2A\x41\x70\x70\x22\x20\x74\x79\x70\x65\x3D"
		"\x22\x54\x49\x2E\x53\xAC\x84\xF2\x2A\x41\x70\x70\x22\x20\x76\x65\x72"
		"\x3D\x22\x31\x2E\x30\x22\x3E\x3C\x73\x63\x3A\x6D\x46\x6C\x61\x67\x73"
		"\x3E\x30\x0E\x06\x3C\x73\x63\x3A\x76\x61\x6C\x75\x65\x3E\x2D\x31\x0E"
		"\x07\x3C\x73\x63\x3A\x73\x63\x72\x69\x70\x74\x20\x76\x65\x72\x73\x69"
		"\x6F\x6E\x3D\x22\x35\x31\x32\x22\x20\x69\x64\x3D\x22\x30\x22\x3E\x0A";
	static const char lua_footer[] = "\x0E\x08\x0E\x05\x0E\x02\x0E\x00";
	static const char xml_header[] =
		"\x54\x49\x58\x43\x30\x31\x30\x30\x2D\x31\x2E\x30\x3F\x3E";

	const char *header = infile_is_xml ? xml_header : lua_header;
	size_t header_size = (infile_is_xml ? sizeof(xml_header) : sizeof(lua_header)) - 1;
	size_t footer_size = infile_is_xml ? 0 : (sizeof(lua_footer) - 1);
	FILE *inf;
	if (!strcmp(inf_name, "-"))
		inf = stdin;
	else
		inf = fopen(inf_name, "rb");
	if (!inf) {
		puts("can't open input file");
		return NULL;
	}
	#define FREAD_BLOCK_SIZE 1024
	*obuf_size = header_size + FREAD_BLOCK_SIZE + footer_size;
	char *in_buf = malloc(*obuf_size);
	if (!in_buf) {
		puts("can't realloc in_buf");
		return NULL;
	}
	memcpy(in_buf, header, header_size);
	size_t in_offset = header_size;
	while(1) {
		size_t read_size;
		if ((read_size = fread(in_buf + in_offset, 1, FREAD_BLOCK_SIZE, inf)) != FREAD_BLOCK_SIZE) {
			*obuf_size -= FREAD_BLOCK_SIZE - read_size;
			if (!(in_buf = realloc(in_buf, *obuf_size))) {
				puts("can't realloc in_buf");
				return NULL;
			}
			break;
		}
		*obuf_size += FREAD_BLOCK_SIZE;
		if (!(in_buf = realloc(in_buf, *obuf_size))) {
			puts("can't realloc in_buf");
			return NULL;
		}
		in_offset += read_size;
	}
	size_t in_size = *obuf_size - header_size - footer_size;
	fclose(inf);

	in_buf = escape_unicode(in_buf, header_size, footer_size, in_size, obuf_size);
	if (!in_buf) return NULL;

	if (infile_is_xml) {
		return reformat_xml_doc(in_buf, header_size, in_size, obuf_size);
	} else {
		if (!(in_buf = escape_special_xml_chars(in_buf, header_size, in_size, obuf_size)))
			return NULL;
		in_size = *obuf_size - header_size - footer_size;
		memcpy(in_buf + header_size + in_size, lua_footer, sizeof(lua_footer) - 1);
		return in_buf;
	}
}

int doccrypt(void *inout, long in_size) {
	int r;
	unsigned i;
	des_key_schedule ks1, ks2, ks3;
	des_cblock cbc_data;
	/* Compatible with tien_crypted_header below from which they are derived */
	static unsigned char cbc1_key[8] = {0x16, 0xA7, 0xA7, 0x32, 0x68, 0xA7, 0xBA, 0x73};
	static unsigned char cbc2_key[8] = {0xD9, 0xA8, 0x86, 0xA4, 0x34, 0x45, 0x94, 0x10};
	static unsigned char cbc3_key[8] = {0x3D, 0x80, 0x8C, 0xB5, 0xDF, 0xB3, 0x80, 0x6B};
	unsigned char ivec[8] = {0x00, 0x00, 0x00, 0x00}; /* the last 4 bytes are incremented each time, LSB first */
	unsigned ivec_incr = 0;
	/* As stored in tien_crypted_header below */
	#define IVEC_BASE 0x6fe21307

	if (   (r = des_set_key_checked(&cbc1_key, ks1))
			|| (r = des_set_key_checked(&cbc2_key, ks2)) != 0
			|| (r = des_set_key_checked(&cbc3_key, ks3)) != 0) {
		printf("doccrypt - key error: %d\n", r);
		return 1;
	}
	
	do {
		unsigned current_ivec = IVEC_BASE + ivec_incr++;
		if (ivec_incr == 1024)
			ivec_incr = 0;
		ivec[4] = (unsigned char)(current_ivec >> 0);
		ivec[5] = (unsigned char)(current_ivec >> 8);
		ivec[6] = (unsigned char)(current_ivec >> 16);
		ivec[7] = (unsigned char)(current_ivec >> 24);
		memcpy(&cbc_data, ivec, sizeof(des_cblock));
		des_ecb3_encrypt(&cbc_data, &cbc_data, ks1, ks2, ks3, DES_ENCRYPT);
 		for (i = 0; i < ((unsigned)in_size >= sizeof(des_cblock) ? sizeof(des_cblock) : (unsigned)in_size); i++) {
			*(unsigned char*)inout++ ^= ((unsigned char*)cbc_data)[i];
		}
		in_size -= sizeof(des_cblock);
	} while (in_size > 0);
	return 0;
}

int make_tns(void *in_buf, long in_size, const char *of_name) {
	static const char document_xml[] =
		"\x0F\xCE\xD8\xD2\x81\x06\x86\x5B\x4A\x4A\xC5\xCE\xA9\x16\xF2\xD5\x1D\xA8\x2F\x6E"
		"\x00\x22\xF2\xF0\xC1\xA6\x06\x77\x4D\x7E\xA6\xC0\x3A\xF0\x5C\x74\xBA\xAA\x44\x60"
		"\xCD\x58\xE6\x70\xD7\x40\xF6\x9C\x17\xDC\xF0\x94\x77\xBF\xCA\xDE\xF7\x02\x09\xC9"
		"\x62\xB1\x5D\xEF\x22\xFA\x51\x37\xA0\x81\x91\x48\xE1\x83\x4D\xAD\x08\x31\x2D\xD0"
		"\xD3\xE3\x2D\x60\xAB\x13\xC2\x98\x2B\xED\x39\x5B\x09\x24\x39\x92\x2F\x0C\x7A\x4C"
		"\x95\x74\x91\x3B\x0C\xF4\x60\xCC\x73\x27\xCB\x07\x7E\x7F\xA9\x17\x87\xE2\xAC\xA2"
		"\x3B\xCC\xA0\xC4\xE3\x8E\x89\xF0\xC0\x51\x9F\xC2\xBE\xCE\x28\x45\xC3\xD4\x11\x90"
		"\xA6\xEC\x53\xA0\xFB\x5B\x46\x6B\x41\xAD\xE9\x53\xBB\x97\xDB\xB1\xD2\x68\xE2\xF6"
		"\x36\x0F\x26\x36\x75\x9B\xE9\x1F\x48\xAD\xE9\x29\x67\x00\x58\x19\xC3\xC0\x12\x76"
		"\xA0\x4A\x73\xF3\xB1\xD3\x09\x18\xD6\x06\xDD\x97\x24\x53\x3E\x22\xA4\xFB\x82\x50"
		"\x7B\x7C\x12\x88\x4E\x7D\x41\x80\xFE\x72\x92\x29\x87\xE8\x5C\x56\x72\xFF\x29\x16"
		"\x8C\x42\x5B\x8B\x9B\xA7\xD2\x08\x6D\xD3\x98\xFF\x91\xA9\x9E\xF3\x93\xA8\x2E\x1C"
		"\xB2\xA9\x6B\x6A\xDF\xF6\xCE\x2D\x15\x17\xCE\x6E\xC0\x4F\x9A\x9C\x0E\xDF\x19\x8D"
		"\x2D\xFA\x69\x9F\x11\xD2\x20\x12\xE0\x79\x14\x04\x4E\x62\x8F\x0A\x2A\x18\x72\x5A"
		"\x8B\x80\xB3\x3C\x9B\xD5\x67\x59\x4B\x51\x4D\xE0\xC3\x38\x28\xC3\xDC\xCD\x39\x22"
		"\x12\x8C\x40\x55";

	zip_fileinfo zi;
	zipFile zf;
	#define MAXFILENAME 256
	char filename[MAXFILENAME + 6];
	strncpy(filename, of_name, MAXFILENAME - 1);
	/* strncpy doesnt append the trailing NULL, if the string is too long. */
	filename[MAXFILENAME] = '\0';
	if (!(zf = zipOpen(filename, 0))) {
		puts("can't open zip file for writing");
		return 1;
	}
	
	zi.tmz_date.tm_sec = zi.tmz_date.tm_min = zi.tmz_date.tm_hour =
		zi.tmz_date.tm_mday = zi.tmz_date.tm_mon = zi.tmz_date.tm_year = 0;
	zi.dosDate = 0; zi.internal_fa = 0; zi.external_fa = 0;
	if (zipOpenNewFileInZip2(zf, "Document.xml", &zi, NULL, 0, NULL, 0, NULL, 0xD, 0, 1) != ZIP_OK) {
		puts("can't open Document in zip file for writing");
close_quit:
		zipClose(zf, NULL);
unlink_quit:
		unlink(of_name);
		return 1;
	}
	if (zipWriteInFileInZip(zf, document_xml, sizeof(document_xml) - 1) != ZIP_OK) {
		puts("can't write document in zip file");
		goto close_quit;
	}
	if (zipCloseFileInZipRaw(zf, sizeof(document_xml) - 1, 0) != ZIP_OK) {
		puts("can't close document in zip file");
		goto unlink_quit;
	}
	if (zipOpenNewFileInZip2(zf, "Problem1.xml", &zi, NULL, 0, NULL, 0, NULL, 0xD, 0, 1) != ZIP_OK) {
		puts("can't zip problem");
		goto close_quit;
	}
	if (zipWriteInFileInZip(zf, in_buf, in_size) != ZIP_OK) {
		puts("can't add file to zip file");
		goto close_quit;
	}
	if (zipCloseFileInZipRaw(zf, in_size, 0) != ZIP_OK || zipClose(zf, NULL) != ZIP_OK) {
		puts("can't close zip file");
		goto unlink_quit;
	}
	return 0;
}

int main(int argc, char *argv[]) {
	if (argc != 3) {
		puts("Usage: luna [INFILE.lua|Problem.xml] [OUTFILE.tns]\n"
				 "Converts a Lua script or a Problem to a TNS document.\n"
				 "If the input file '-', reads it from the standard input.");
		return 0;
	}
	size_t xmlc_buf_size;
	int infile_is_xml = strlen(argv[1]) >= 5 && !strcmp(".xml", argv[1] + strlen(argv[1]) - 4);
	void *xmlc_buf = xml_compress(argv[1], &xmlc_buf_size, infile_is_xml);
	if (!xmlc_buf)
		return 1;

	/* As expected by zlib */
	unsigned long def_size = xmlc_buf_size + (xmlc_buf_size * 0.1) + 12;
	static const char tien_crypted_header[] = 
		"\x0F\xCE\xD8\xD2\x81\x06\x86\x5B\x99\xDD\xA2\x3D\xD9\xE9\x4B\xD4\x31\xBB\x50\xB6"
		"\x4D\xB3\x29\x24\x70\x60\x49\x38\x1C\x30\xF8\x99\x00\x4B\x92\x64\xE4\x58\xE6\xBC";
	void *def_buf = malloc(def_size + sizeof(tien_crypted_header) - 1);
	if (!def_buf) {
		puts("can't realloc def_buf");
		return 1;
	}
	z_stream zstream;
	zstream.next_in = (Bytef*)xmlc_buf;
	zstream.next_out = (Bytef*)def_buf + sizeof(tien_crypted_header) - 1;
	zstream.avail_in = xmlc_buf_size;
	zstream.avail_out = def_size;
	zstream.zalloc = Z_NULL;
	zstream.zfree  = Z_NULL;
	/* -windowBits=-15: no zlib header */
	if (deflateInit2(&zstream, Z_DEFAULT_COMPRESSION, Z_DEFLATED, -15, 8, Z_DEFAULT_STRATEGY)) {
		puts("can't deflateInit2");
		return 1;
	}
	if (deflate(&zstream, Z_FINISH) != Z_STREAM_END) {
		puts("can't deflate");
		return 1;
	}
	if (deflateEnd(&zstream)) {
		puts("can't deflateEnd");
		return 1;
	}
	if (doccrypt(def_buf + sizeof(tien_crypted_header) - 1, zstream.total_out))
		return 1;
	memcpy(def_buf, tien_crypted_header, sizeof(tien_crypted_header) - 1);
	if (make_tns(def_buf, zstream.total_out + sizeof(tien_crypted_header) - 1, argv[2]))
		return 1;

	return 0;
}
