/****************************************************************************
 * Automated test cases
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
 * Portions created by the Initial Developer are Copyright (C) 2010-2014
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): 
 ****************************************************************************/

#ifndef _TINSPIRE
#error _TINSPIRE not defined as it should be
#endif

// For the "nl_hassyscall" test
#define e_dummy 100000
#include <os.h>
#include "ndless_tests.h"
#include "../ndless.h"

int global_int;
int *nl_relocdata_data[] = {&global_int};

static const unsigned custom_sprintf_addrs[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0x103FA1C0}; // only CAS CX 3.6
#define custom_sprintf SYSCALL_CUSTOM(custom_sprintf_addrs, int __attribute__((__format__(__printf__,2,3))), char *s, const char *format, ...)

/* the actual parameters should be: dummy, (char)1, char(0x20) */
static void test_va(char __attribute__((unused)) dummy, ...) {
	char buf[10];
	va_list vl, vl2;
	va_start(vl, dummy);
	va_copy(vl2, vl);
	unsigned char c = va_arg(vl2, int);
	assertUIntEquals("va_arg", 1, c);
	vsprintf(buf, "%c", vl2);
	assertStrEquals("vsprintf", " ", buf);
	vsnprintf(buf, sizeof(buf), "%c", vl2);
	assertStrEquals("vsnprintf", " ", buf);
	vprintf("%c\n", vl2);
	FILE *file = fopen("__testfile.tns", "wb+");
	assertUIntEquals("vfprintf", 1, vfprintf(file, "%c", vl2));
	assertZero("fclose", fclose(file));
	va_end(vl2);
	va_end(vl);
}

void print_string(String s) {
  puts(string_to_ascii(s));
}

int main(int argc, char *argv[]) {
	char buf[100];
	char buf2[100];
	int ret, i;
	char *ptr;
	FILE *file;
	struct stat sstat;
	DSTAT dstat;

	assertUIntEquals("TCT_Local_Control_Interrupts", 0xFFFFFFFF, TCT_Local_Control_Interrupts(0));
	if (argc == 3) {
		// called with nl_exec(), return special value for test case
		unsigned orig_errcount = errcount;
		assertStrEquals("nl_exec_parms-argv1", "ndless_tests.test.tns", strrchr(argv[1], '/') + 1); // file association (run with ourself)
		assertStrEquals("nl_exec_parms-argv2", "hello", argv[2]);
		if (errcount != orig_errcount)
			return -1; // make sure the parent program counts it as an error
		return 0xBEEF;
	}
	else if (argc != 2)
		puts("Make sure to use ndless.cfg from the tests/ directory. test argv1 will be skipped.");
	assertStrEquals("argv0", "ndless_tests.test.tns", strrchr(argv[0], '/') + 1);
	if (argc == 2)
		assertStrEquals("argv1", "ndless_tests.test.tns", strrchr(argv[1], '/') + 1); // file association (run with ourself)
	assertIntEquals("enable_relative_paths", 0, enable_relative_paths(argv));
	
	ret = sprintf(buf, "%i%i%i", 1, 2, 3);
	assertStrEquals("_syscallsvar >4 params", "123", buf); // tests sprintf. uses _syscallvar_savedlr.
	assertUIntEquals("_syscallsvar return", 3, ret);
	
	if (nl_osid() == 3) { // we are on CAS CX 3.6: execute tests which only work on this version.
		unsigned nl_osvalue_data[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
		assertUIntEquals("nl_osvalue", 10, nl_osvalue((int*)nl_osvalue_data, 10)); // Also tests syscalls extensions
		custom_sprintf(buf, "%s", "custom");
		assertStrEquals("_syscall_custom", "custom", buf);
		assertTrue("nl_hassyscall-1", nl_hassyscall(strlen));
		assertFalse("nl_hassyscall-2", nl_hassyscall(TI_NN_SendKeyPress));
		assertFalse("nl_hassyscall-3", nl_hassyscall(dummy));
	}
	
	global_int = 1; // tests relocation of global variables 
	assertUIntEquals("nl_relocdata_data bflt", 1, (unsigned)*nl_relocdata_data[0]);
	
	assertIntEquals("nl_exec", 0xBEEF, nl_exec(argv[0], 1, (char*[]){"hello"}));
	nl_set_resident(); // caution, will leak. This at least checks that it doesn't crash.
	
	/* syscalls */
	buf[0] = 1; buf[1] = 2; buf[2] = 3; buf[3] = 4; buf[4] = 5;
	assertUIntEquals("read_unaligned_longword", 0x05040302, read_unaligned_longword(buf + 1));
	assertUIntEquals("read_unaligned_word", 0x0302, read_unaligned_word(buf + 1));
	ascii2utf16(buf, "abc", sizeof(buf));
	assertUIntEquals("ascii2utf16", 'a', buf[0]);
	assertUIntEquals("utf16_strlen", 3, utf16_strlen(buf));
	utf162ascii(buf2, buf, sizeof(buf2));
	assertStrEquals("utf162ascii", "abc", buf2);
	
	assertTrue("isalpha", isalpha('a'));
	assertTrue("isascii", isascii('+'));
	assertTrue("isdigit", isdigit('0'));
	assertTrue("islower", islower('a'));
	assertTrue("isprint", isprint('a'));
	assertTrue("isspace", isspace(' '));
	assertTrue("isupper", isupper('A'));
	assertTrue("isxdigit", isxdigit('f'));
	assertUIntEquals("tolower", 'a', tolower('A'));
	assertUIntEquals("toupper", 'A', toupper('a'));
	assertUIntEquals("atoi", 1, atoi("1"));
	// assertDblEquals("atof", 1.1, atof("1.1")); // TODO fails
	// strtod TODO fails
	
	ptr = malloc(100);
	assertNotNull("malloc", ptr);
	free(ptr);
	ptr = calloc(5, 4);
	assertNotNull("calloc", ptr);
	assertZero("calloc[0]", *(char*)ptr);
	ptr = realloc(ptr, 100);
	assertNotNull("realloc", ptr);
	free(ptr);
	
	memset(buf, 1, sizeof(buf));
	assertUIntEquals("memset", 1, buf[10]);
	buf[0] = 0; buf[10] = 1;
	memcpy(buf, buf + 10, 1);
	assertUIntEquals("memcpy", 1, buf[0]);
	buf[0] = 0; buf[10] = 1;
	memmove(buf, buf + 10, 1);
	assertUIntEquals("memmove", 1, buf[0]);
	buf[0] = 1; buf[10] = 1;
	assertZero("memcmp", memcmp(buf, buf + 10, 1));
	buf[0] = 0; ; buf[10] = 1;
	memrev(buf, 11);
	assertUIntEquals("memrev", 1, buf[0]);
	assertUIntEquals("strlen", 3, strlen("abc"));
	strcpy(buf, "abc");
	assertZero("strcpy,strcmp", strcmp(buf, "abc"));
	buf[2] = 0;
	strncpy(buf, "abc", 2);
	assertZero("strncpy", strcmp(buf, "ab"));
	strcpy(buf, "abc");
	assertZero("strncmp", strncmp(buf, "a", 1));
	strcpy(buf, "a");
	strcat(buf, "bc");
	assertZero("strcat", strcmp(buf, "abc"));
	strcpy(buf, "a");
	strncat(buf, "bc", 1);
	assertZero("strncat", strcmp(buf, "ab"));
	ptr = strchr("abc", 'b');
	assertUIntEquals("strchr", 'b', *ptr);
	ptr = strrchr("abc", 'a');
	assertUIntEquals("strrchr", 'a', *ptr);
	ptr = strpbrk("abc", "dc");
	assertUIntEquals("strpbrk", 'c', *ptr);
	assertUIntEquals("strcspn", 3, strcspn("123abc", "abc"));
	assertUIntEquals("strspn", 3, strspn("abcdef", "abc"));
	file = fopen("unexist.ent", "r");
	assertStrEquals("strerror,errno", "No Such File Or Directory", strerror(errno));
	assertIntEquals("strtol", -1, strtol("-1", NULL, 10));
	assertUIntEquals("strtoul", 0xA0000000, strtoul("0xA0000000", NULL, 16));
	assertStrEquals("strstr", "def", strstr("abcdef", "def"));
	
	test_va(0, (char)1, (char)0x20);
	sprintf(buf, "%s", "abc 123");
	assertStrEquals("sprintf", "abc 123", buf);
	assertIntEquals("sscanf-ret", 1, sscanf(buf, "%*s %d", &i));
	assertIntEquals("sscanf", 123, i);
	srand(5050);
	assertUIntEquals("rand-1", 0x6A5, rand());
	assertUIntEquals("rand-2", 0x6B5D, rand());
	srand(1818);
	assertUIntEquals("rand-2", 0x264, rand());
	
	file = fopen("__testfile.tns", "wb+");
	assertNotNull("fopen", file);
	file = freopen("__testfile.tns", "wb+", file);
	assertNotNull("freopen", file);
	assertUIntEquals("fwrite", 4, fwrite("abc", 1, 4, file));
	assertZero("fflush", fflush(file));
	rewind(file);
	assertUIntEquals("fread-1", 4, fread(buf2, 1, 4, file));
	assertStrEquals("fread-2", "abc", buf2);
	assertZero("fseek", fseek(file, 0, SEEK_SET));
	assertUIntEquals("fprintf", 3, fprintf(file, "%s", "abc"));
	rewind(file);
	assertUIntEquals("fputc", 'a', fputc('a', file));
	fseek(file, -1, SEEK_CUR);
	assertUIntEquals("fgetc", 'a', fgetc(file));
	rewind(file);
	assertUIntEquals("getc", 'a', getc(file));
	rewind(file);
	assertNonZero("fputs", fputs("abc\ndef", file));
	rewind(file);
	assertStrEquals("fgets-1", "abc\n", fgets(buf2, 10, file));
	assertStrEquals("fgets-2", "def", fgets(buf2, 10, file));
	assertNull("fgets-eof", fgets(buf2, 10, file));
	rewind(file);
	fputc('a', file);
	rewind(file);
	assertUIntEquals("ungetc-1", 'a', ungetc(fgetc(file), file));
	assertUIntEquals("ungetc-2", 'a', fgetc(file));
	assertZero("fclose", fclose(file));
	assertZero("truncate", truncate("__testfile.tns", 2));
	assertZero("stat", stat("__testfile.tns", &sstat));
	assertIntEquals("stat-truncate", sstat.st_size, 2);
	
	assertZero("unlink", unlink("__testfile.tns"));
	file = fopen("__testfile.tns", "wb+");
	assertNonZero("feof-1", feof(file));
	fputc('a', file);
	rewind(file);
	assertZero("feof-2", feof(file));
	fclose(file);
	file = fopen("__testfile.tns", "wb");
	fread(buf2, 1, 1, file);
	assertNonZero("ferror", ferror(file));
	fclose(file);
	assertZero("remove", remove("__testfile.tns"));
	assertZero("mkdir", mkdir("/tmp/__testdir", 0));
	assertZero("rename", rename("/tmp/__testdir", "/tmp/__testdir2"));
	assertZero("chdir", chdir("/tmp"));
	assertStrEquals("getcwd", getcwd(buf, sizeof(buf)), "/tmp/");
	assertZero("rmdir", rmdir("__testdir2"));
	
	assertZero("NU_Set_Current_Dir", NU_Set_Current_Dir("A:\\tmp"));
	assertZero("NU_Current_Dir-1", NU_Current_Dir("A:", buf));
	assertStrEquals("NU_Current_Dir-2", "\\tmp\\", buf);
	assertZero("NU_Get_First", NU_Get_First(&dstat, "A:\\*.*"));
	assertZero("NU_Get_Next-1", NU_Get_Next(&dstat));
	assertStrEquals("NU_Get_Next-2", "tmp", dstat.filepath);
	NU_Done(&dstat);
	
	DIR	*dp;
	struct dirent *ep;		 
	assertNotNull("opendir", (dp = opendir("/")));
	assertNotNull("readdir-1", (ep = readdir(dp)));
	assertNotNull("readdir-2", (ep = readdir(dp)));
	assertStrEquals("readdir.d_name",	"tmp", ep->d_name);
	assertZero("closedir", closedir(dp));
	
	assertStrEquals("get_documents_dir", "/documents/", get_documents_dir());
	
	assertUIntLower("keypad_type-1", 5, *keypad_type);
	assertNonZero("keypad_type-2", *keypad_type);

	/* strings */
	String s = string_new();
	assertNotNull("String", s);
	String s2 = string_new();
	assertUIntEquals("string_set_ascii", 1, string_set_ascii(s2, " Lorem Ipsum"));
	string_set_ascii(s, "hello world!");
	assertUIntEquals("string_concat_utf16", 1, string_concat_utf16(s, s2->str));
	string_free(s2);
	assertTrue("string_free", TRUE);
	assertStrEquals("string_set_ascii", "hello world! Lorem Ipsum", string_to_ascii(s));
	char * l = "l\0\0";
	assertUIntEquals("string_indexOf_utf16", 2, string_indexOf_utf16(s, 0, l));
	assertUIntEquals("string_last_indexOf_utf16", 9, string_last_indexOf_utf16(s, 0, l));
	assertUIntEquals("string_indexOf_utf16", 6, string_indexOf_utf16(s, 0, "w\0o\0r\0l\0d\0\0"));
	int pos = 1;
	assertUIntEquals("string_substring_utf16", 5, utf16_strlen(string_substring_utf16(s, "w\0o\0r\0l\0d\0\0", &pos)));
	String t = string_new();
	string_set_ascii(t, "%d");
	string_sprintf_utf16(s, t->str, 42);
	assertStrEquals("string_sprintf_utf16", "42", string_to_ascii(s));
	
	String s42 = string_new();
	string_set_ascii(s42, "42");
	assertZero("string_compareTo_utf16", string_compareTo_utf16(s, s42->str));

	string_set_ascii(s, "String erased ; hello:3");
	String s3 = string_new();
	string_set_ascii(s3, "The Game");
	string_substring(s, s3, 4, 7);
	assertStrEquals("string_substring", "Game", string_to_ascii(s));
	string_free(s3);
	
	String s4 = string_new();
	string_set_ascii(s4, " Lorem ");
	string_insert_utf16(s, s4->str, 2);
	assertStrEquals("string_lower", "Ga Lorem me", string_to_ascii(s));
	string_free(s4);
	
	string_lower(s);
	assertStrEquals("string_lower", "ga lorem me", string_to_ascii(s));

	string_erase(s, 2);
	assertStrEquals("string_erase", " lorem me", string_to_ascii(s));
	assertCharEquals("string_charAt", 'e', string_charAt(s, 4));
	string_free(s);
	
	s = string_new();
	string_set_ascii(s, "Save As...");
	assertZero("get_res_string", string_compareTo_utf16(s, get_res_string(RES_SYST, 0x15)));
	
	/* libndls */
	assertTrue("isalnum", isalnum('0'));
	assertTrue("iscntrl", iscntrl('\0'));
	assertUIntEquals("abs,min,max", 4, max(min(abs(-3), 2), 4));
	assertUIntEquals("bswap16", 0x0100, bswap16(0x0001));
	assertUIntEquals("bswap32", 0x03020100, bswap32(0x00010203));
	
	assertTrue("has_colors", (has_colors && *(unsigned*)0x900A0000 == 0x101) || (!has_colors && *(unsigned*)0x900A0000 == 0x01000010));
	unsigned asic_user_flags_model = (*(volatile unsigned*)0x900A002C & 0x7C000000) >> 26;
	assertTrue("is_cm", (is_cm && asic_user_flags_model == 2) || (is_cm && asic_user_flags_model == 3) || !is_cm);
	assertTrue("is_touchpad", (*keypad_type != 3  &&  *keypad_type != 4) || is_touchpad);
	assertTrue("isstartup", nl_isstartup()); // will only pass if run as startup program
	assertFalse("nl_loaded_by_3rd_party_loader", nl_loaded_by_3rd_party_loader());
	
	sleep(100);
	
	/* Ndless internals */
	char * cfg_path = "/tmp/ndless_tests.cfg";
	FILE *cfg_file = fopen(cfg_path, "wb");
	fputs("# comment\n", cfg_file);
	fputs("   key  = value # comment\n", cfg_file);
	fputs("\n", cfg_file);
	fputs("   windows=win\r\n", cfg_file);
	fputs("empty=\n", cfg_file);
	fputs("dummy", cfg_file);
	fclose(cfg_file);
	cfg_open_file(cfg_path);
	assertStrEquals("cfg_get_key", "value", cfg_get("key"));
	assertStrEquals("cfg_get_win", "win", cfg_get("windows"));
	assertStrEquals("cfg_get_empty", "", cfg_get("empty"));
	assertNull("cfg_get_dummy", cfg_get("dummy"));
	cfg_close();
	cfg_register_fileext_file(cfg_path, "dummy", "prgm");
	cfg_open_file(cfg_path);
	assertStrEquals("cfg_register_fileext", "prgm", cfg_get("ext.dummy"));
	cfg_close();
	remove(cfg_path);
	
	if (!errcount) {
		fputc('S', stdout);
		puts("uccessful!");
	}
	else
		printf("%u test(s) failed.\n", errcount);
	exit(0); // tests exit()
}
