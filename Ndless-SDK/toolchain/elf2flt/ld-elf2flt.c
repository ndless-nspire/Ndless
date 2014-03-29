/*
 * Wrapper for the real linker and the elf2flt converter.  This was
 * originally a simple shell script, but that doesn't work on a
 * Windows host without cygwin.
 * The proper long term solution is to add FLT as a BFD output format.
 *
 * Converted from ld-elf2flt.in by Nathan Sidwell, nathan@codesourcery.com.
 * Updated to latest elf2flt code by Mike Frysinger, vapier@gentoo.org.
 *
 * This is Free Software, under the GNU General Public License V2 or greater.
 *
 * Copyright (C) 2006, CodeSourcery Inc.
 * Copyright (C) 2009, Analog Devices, Inc.
 * Copyright (C) 2002-2003 David McCullough <davidm@snapgear.com>
 * Copyright (C) 2000, Lineo. <davidm@lineo.com>
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>
#include <libiberty.h>
#include <filenames.h>

#include "stubs.h"
const char *elf2flt_progname;

static int flag_verbose = 0, flag_final = 1, have_elf2flt_options = 0,
	flag_move_data = 0, want_shared = 0;
static const char *shared_lib_id = NULL;
static const char *output_file = "a.out";
static const char *linker_script = NULL;
static const char *emulation = NULL;
static const char *tmp_file = NULL;
static const char *output_gdb = NULL;
static const char *output_elf = NULL;
static const char *output_flt = NULL;
static options_t search_dirs, all_options, other_options, flt_options;

static const char *linker = NULL;
static const char *elf2flt = NULL;
static const char *nm = NULL;
static const char *objdump = NULL;
static const char *objcopy = NULL;
static const char *ldscriptpath = BINUTILS_LDSCRIPTDIR;

/* A list of sed commands */
typedef struct {
	options_t *pattern;      /* '^' for start of line match, everything else verbatim */
	options_t *replacement;  /* Delete line, if NULL */
} sed_commands_t;

/* Initialize a sed structure */
#define init_sed(DST) ( \
	(DST)->pattern = xmalloc(sizeof(*(DST)->pattern)), \
	(DST)->replacement = xmalloc(sizeof(*(DST)->replacement)), \
	init_options((DST)->pattern), \
	init_options((DST)->replacement) \
)
#define free_sed(DST) (free((DST)->pattern), free((DST)->replacement))

/* Append a slot for a new sed command.  */
static void append_sed(sed_commands_t *dst, const char *pattern,
		       const char *replacement)
{
	debug1("adding pattern '%s' with replacement '%s'\n",
		pattern, replacement);
	append_option(dst->pattern, pattern);
	append_option(dst->replacement, replacement);
}

/* Execute an external program COMMAND.  Write its stdout to OUTPUT,
   unless that is NULL.  Pass the trailing NULL terminated list of
   options, followed by all those in OPTIONS, if that is non-NULL.
   Order of options is important here as we may run on systems that
   do not allow options after non-options (i.e. many BSDs).  So the
   final command line will look like:
   <command> [options] [... va args ...]
   This is because [options] will (should?) never contain non-options,
   while non-options will always be passed via the [va args].
 */
static int
execute(const char *command, const char *output, const options_t *options, ...)
{
	struct pex_obj *pex;
	const char *errmsg;
	int err;
	int status;
	va_list args;
	const char *opt;
	options_t opts;

	debug("command=%s\n", command);

	init_options(&opts);
	append_option(&opts, command);
	if (options)
		append_options(&opts, options);
	va_start(args, options);
	while ((opt = va_arg(args, const char *)))
		append_option(&opts, opt);
	va_end(args);
	append_option(&opts, NULL);

	fflush(stdout);
	fflush(stderr);

	pex = pex_init(0, elf2flt_progname, NULL);
	if (pex == NULL)
		fatal_perror("pex_init failed");

	if (flag_verbose) {
		unsigned ix;

		fprintf(stderr, "Invoking:");
		for (ix = 0; ix != opts.num - 1; ix++)
			fprintf(stderr, " '%s'", opts.options[ix]);
		if (output)
			fprintf(stderr, " > '%s'", output);
		fprintf(stderr, "\n");
	}

	errmsg = pex_run(pex, PEX_LAST | PEX_SEARCH, command,
		(char *const *)opts.options, output, NULL, &err);
	if (errmsg != NULL) {
		if (err != 0) {
			errno = err;
			fatal_perror(errmsg);
		} else
			fatal(errmsg);
	}

	if (!pex_get_status(pex, 1, &status))
		fatal_perror("can't get program status");
	pex_free(pex);

	if (status) {
		if (WIFSIGNALED(status)) {
			int sig = WTERMSIG(status);

			fatal("%s terminated with signal %d [%s]%s",
			      command, sig, strsignal(sig),
			      WCOREDUMP(status) ? ", core dumped" : "");
		}

		if (WIFEXITED(status))
			return WEXITSTATUS(status);
	}
	return 0;
}
/* Auto NULL terminate */
#define execute(...) execute(__VA_ARGS__, NULL)

/* Apply the sed commands in SED to file NAME_IN producing file NAME_OUT */
static void
do_sed(const sed_commands_t *sed, const char *name_in, const char *name_out)
{
	FILE *in, *out;
	size_t alloc = 0;
	char *line = NULL;
	ssize_t len;
	const char *pattern, *replacement;
	int ix;

	if (flag_verbose) {
		fprintf(stderr, "emulating: sed \\\n");
		for (ix = 0; ix != sed->pattern->num; ix++) {
			pattern = sed->pattern->options[ix];
			replacement = sed->replacement->options[ix];
			if (replacement)
				fprintf(stderr, "\t-e 's/%s/%s/' \\\n", pattern, replacement);
			else
				fprintf(stderr, "\t-e '/%s/d' \\\n", pattern);
		}
		fprintf(stderr, "\t%s > %s\n", name_in, name_out);
	}

	in = xfopen(name_in, "r");
	out = xfopen(name_out, "w");

	while ((len = getline(&line, &alloc, in)) > 0) {
		debug2("len=%2zi line=%s", len, line);

		for (ix = 0; ix != sed->pattern->num; ix++) {
			const char *ptr;
			int bol;
			size_t pat_len;

			pattern = sed->pattern->options[ix];
			replacement = sed->replacement->options[ix];
			ptr = line;
			bol = pattern[0] == '^';

			pattern += bol;
			pat_len = strlen(pattern);

			if (!bol) {
				do {
					ptr = strchr(ptr, pattern[0]);
					if (!ptr) ;
					else if (!strncmp(ptr, pattern, pat_len))
						goto found;
					else
						ptr++;
				}
				while (ptr);
			} else if (!strncmp(ptr, pattern, pat_len)) {
 found:
				if (replacement) {
					debug2(" [modified]\n");
					fwrite(line, 1, ptr - line, out);
					fwrite(replacement, 1, strlen(replacement), out);
					fwrite(ptr + pat_len, 1,
					       len - pat_len - (ptr - line),
					       out);
				} else
					debug2("   {dropped}\n");
				goto next_line;
			}
		}

		debug2("(untouched)\n");
		fwrite(line, 1, len, out);
 next_line:
		;
	}
	fclose(in);
	if (fclose(out))
		fatal_perror("error writing temporary script '%s'", name_out);
	free(line);
}

/* Generate the flt binary along with any other necessary pieces.  */
#define exec_or_ret(...) \
	do { \
		int status = execute(__VA_ARGS__); \
		if (status) return status; \
	} while (0)
static int do_final_link(void)
{
	sed_commands_t sed;
	struct stat buf;
	const char *script;
	const char *rel_output;
	int have_got = 0;
	FILE *in;
	char *line = NULL;
	size_t alloc = 0;
	ssize_t len;

	init_sed(&sed);

	if (flag_move_data) {
		FILE *in;

		/* See if the .rodata section contains any relocations.  */
		if (!output_flt)
			output_flt = make_temp_file(NULL);
		exec_or_ret(linker, NULL, &other_options, "-r", "-d", "-o", output_flt);
		exec_or_ret(objdump, tmp_file, NULL, "-h", output_flt);

		in = xfopen(tmp_file, "r");
		while ((len = getline(&line, &alloc, in)) > 0) {
			const char *ptr = line;

			while (1) {
				ptr = strchr(ptr, '.');
				if (!ptr)
					break;
				if (streqn(ptr, ".rodata")) {
					getline(&line, &alloc, in);
					ptr = line;
					while (1) {
						ptr = strchr(ptr, 'R');
						if (!ptr)
							break;
						if (streqn(ptr, "RELOC")) {
							flag_move_data = 0;
							fprintf(stderr, "warning: .rodata section contains relocations");
							break;
						} else
							ptr++;
					}
					break;
				} else
					ptr++;
			}
		}
		fclose(in);
	}
	append_sed(&sed, "^R_RODAT", flag_move_data ? NULL : "");
	append_sed(&sed, "^W_RODAT", flag_move_data ? "" : NULL);
	append_sed(&sed, "^SINGLE_LINK:", USE_EMIT_RELOCS ? "" : NULL);
	append_sed(&sed, "^TOR:", EMIT_CTOR_DTOR ? "" : NULL);

	if (shared_lib_id) {
		const char *got_offset;
		int adj, id = strtol(shared_lib_id, NULL, 0);
		char buf[30];

		/* Replace addresses using the shared object id.   */
		sprintf(buf, "%.2X", id);
		append_sed(&sed, "ORIGIN = 0x0,", concat("ORIGIN = 0x", buf, "000000,", NULL));
		append_sed(&sed, ".text 0x0 :", concat(".text 0x0", buf, "000000 :", NULL));
		if (id)
			append_sed(&sed, "ENTRY (" SYMBOL_PREFIX "_start)", "ENTRY (lib_main)");

		/* Provide the symbol specifying the library's data segment
		   pointer offset.  */
		adj = 4;
		if (streq(TARGET_CPU, "h8300"))
			got_offset = "__current_shared_library_er5_offset_";
		else if (streq(TARGET_CPU, "bfin"))
			got_offset = "_current_shared_library_p5_offset_", adj = 1;
		else
			got_offset = "_current_shared_library_a5_offset_";
		append_option(&other_options, "-defsym");
		sprintf(buf, "%d", id * -adj - adj);
		append_option(&other_options, concat(got_offset, "=", buf, NULL));
	}

	/* Locate the default linker script, if we don't have one provided. */
	if (!linker_script)
		linker_script = concat(ldscriptpath, "/elf2flt.ld", NULL);

	/* Try and locate the linker script.  */
	script = linker_script;
	if (stat(script, &buf) || !S_ISREG(buf.st_mode)) {
		script = concat(ldscriptpath, "/", linker_script, NULL);
		if (stat(script, &buf) || !S_ISREG(buf.st_mode)) {
			script = concat(ldscriptpath, "/ldscripts/", linker_script, NULL);
			if (stat(script, &buf) || !S_ISREG(buf.st_mode))
				script = NULL;
		}
	}
	/* And process it if we can -- if we can't find it, the user must
	   know what they are doing.  */
	if (script) {
		do_sed(&sed, linker_script, tmp_file);
		linker_script = tmp_file;
	}
	free_sed(&sed);

	if (USE_EMIT_RELOCS) {

		exec_or_ret(linker, NULL, &other_options,
			"-T", linker_script, "-q", "-o", output_gdb, emulation);

		append_option(&flt_options, "-a");
		rel_output = output_gdb;

	} else if (NO_GOT_CHECK) {

		output_elf = make_temp_file(NULL);

		exec_or_ret(linker, NULL, &other_options,
			"-T", linker_script, "-Ur", "-d", "-o", output_elf, emulation);
		exec_or_ret(linker, NULL, &other_options,
			"-T", linker_script, "-o", output_gdb, emulation);

		rel_output = output_elf;

	} else {

		output_flt = make_temp_file(NULL);
		exec_or_ret(linker, NULL, &other_options,
			"-r", "-d", "-o", output_flt, emulation);

		output_elf = make_temp_file(NULL);
		exec_or_ret(linker, NULL, &search_dirs,
			"-T", linker_script, "-Ur", "-o", output_elf, output_flt, emulation);

		exec_or_ret(linker, NULL, &search_dirs,
			"-T", linker_script, "-o", output_gdb, output_flt, emulation);

		rel_output = output_elf;

	}

	if (shared_lib_id && strtol(shared_lib_id, NULL, 0) != 0)
		exec_or_ret(objcopy, NULL, NULL, "--localize-hidden", "--weaken", output_gdb);

	exec_or_ret(nm, tmp_file, NULL, "-p", output_gdb);
	in = xfopen(tmp_file, "r");
	while ((len = getline(&line, &alloc, in)) > 0) {
		const char *ptr = strchr(line, '_');
		if (ptr && streqn(ptr, "_GLOBAL_OFFSET_TABLE")) {
			have_got = 1;
			break;
		}
	}
	fclose(in);
	if (have_got)
		exec_or_ret(elf2flt, NULL, &flt_options,
			"-o", output_file, "-p", output_gdb, rel_output);
	else
		exec_or_ret(elf2flt, NULL, &flt_options,
			"-o", output_file, "-r", rel_output);

	return 0;
}

/* parse all the arguments provided to us */
static void parse_args(int argc, char **argv)
{
	char *fltflags;
	int argno;

	for (argno = 1; argno < argc; argno++) {
		char const *arg = argv[argno];
		int to_all = argno;

		if (streq(arg, "-elf2flt")) {
			have_elf2flt_options = 1;
			to_all++;
		} else if (streqn(arg, "-elf2flt=")) {
			have_elf2flt_options = 1;
			append_option_str(&flt_options, &arg[9], "\t ");
			to_all++;
		} else if (streq(arg, "-move-rodata")) {
			flag_move_data = 1;
		} else if (streq(arg, "-shared-lib-id")) {
			shared_lib_id = argv[++argno];
		} else if (streq(arg, "-shared") || streq(arg, "-G")) {
			want_shared = 1;
		} else if (streqn(arg, "-o")) {
			output_file = arg[2] ? &arg[2] : argv[++argno];
		} else if (streqn(arg, "-T")) {
			linker_script = arg[2] ? &arg[2] : argv[++argno];
		} else if (streq(arg, "-c")) {
			linker_script = argv[++argno];
		} else if (streqn(arg, "-L")) {
			const char *merged =
				(arg[2] ? arg : concat("-L", argv[++argno], NULL));
			append_option(&other_options, merged);
			append_option(&search_dirs, merged);
		} else if (streq(arg, "-EB")) {
			append_option(&other_options, arg);
			append_option(&search_dirs, arg);
		} else if (streq(arg, "-relax")) {
			;
		} else if (streq(arg, "-s") || streq(arg, "--strip-all") ||
		           streq(arg, "-S") || streq(arg, "--strip-debug")) {
			/* Ignore these strip options for links involving elf2flt.
			   The final flat output will be stripped by definition, and we
			   don't want to strip the .gdb helper file.  The strip options
			   are also incompatible with -r and --emit-relocs.  */
			;
		} else if (streq(arg, "-r") || streq(arg, "-Ur")) {
			flag_final = 0;
			append_option(&other_options, arg);
		} else if (streq(arg, "--verbose")) {
			flag_verbose = 1;
			append_option(&other_options, arg);
		} else if (streqn(arg, "-m")) {
			emulation = arg[2] ? arg : concat("-m", argv[++argno], NULL);
		} else
			append_option(&other_options, arg);

		while (to_all <= argno)
			append_option(&all_options, argv[to_all++]);
	}

	fltflags = getenv("FLTFLAGS");
	if (fltflags)
		append_option_str(&flt_options, fltflags, "\t ");
}

int main(int argc, char *argv[])
{
	const char *argv0 = argv[0];
	const char *argv0_dir = make_relative_prefix(argv0, "/", "/");
	char *tooldir = argv0_dir;
	char *bindir = argv0_dir;
	char *tmp;
	struct stat buf;
	const char *have_exe = NULL;
	int status;

#ifdef __WIN32
	/* Remove the .exe extension, if it's there.  */
	size_t len = strlen(argv0);
	if (len > 4 && streq(&argv0[len - 4], ".exe")) {
		have_exe = ".exe";
		len -= 4;
		argv0 = tmp = xstrdup(argv0);
		tmp[len] = 0;
		argv[0][len] = '\0';
	}
#endif
	elf2flt_progname = lbasename(argv0);

	/* The standard binutils tool layout has:

	   bin/<TARGET_ALIAS>-foo
	   lib/
	   <TARGET_ALIAS>/bin/foo
	   <TARGET_ALIAS>/lib

	   It's <TARGET_ALIAS>/ that we want here: files in lib/ are for
	   the host while those in <TARGET_ALIAS>/lib are for the target.
	   Make bindir point to the bin dir for bin/<TARGET_ALIAS>-foo.
	   Make tooldir point to the bin dir for <TARGET_ALIAS>/bin/foo.  */
	if (streqn(elf2flt_progname, TARGET_ALIAS)) {
		tmp = concat(argv0_dir, "../" TARGET_ALIAS "/bin", NULL);
		if (stat(tmp, &buf) == 0 && S_ISDIR(buf.st_mode)) {
			tooldir = concat(tmp, "/", NULL);
		}
	} else {
		tmp = concat(argv0_dir, "../../bin", NULL);
		if (stat(tmp, &buf) == 0 && S_ISDIR(buf.st_mode)) {
			bindir = concat(tmp, "/", NULL);
		}
	}

	/* Typically ld-elf2flt is invoked as `ld` which means error
	 * messages from it will look like "ld: " which is completely
	 * confusing.  So append an identifier to keep things clear.
	 */
	elf2flt_progname = concat(elf2flt_progname, " (ld-elf2flt)", NULL);

	xmalloc_set_program_name(elf2flt_progname);

	linker = concat(tooldir, "ld.real", have_exe, NULL);
	elf2flt = concat(tooldir, "elf2flt", have_exe, NULL);
	nm = concat(tooldir, "nm", have_exe, NULL);
	objdump = concat(bindir, TARGET_ALIAS "-objdump", have_exe, NULL);
	objcopy = concat(bindir, TARGET_ALIAS "-objcopy", have_exe, NULL);

	if (stat(ldscriptpath, &buf) || !S_ISDIR(buf.st_mode))
		ldscriptpath = concat(tooldir, "../lib", NULL);

	parse_args(argc, argv);

	if (flag_verbose) {
		fprintf(stderr, "argv[0]      = '%s'\n", argv[0]);
		fprintf(stderr, "bindir       = '%s'\n", bindir);
		fprintf(stderr, "tooldir      = '%s'\n", tooldir);
		fprintf(stderr, "linker       = '%s'\n", linker);
		fprintf(stderr, "elf2flt      = '%s'\n", elf2flt);
		fprintf(stderr, "nm           = '%s'\n", nm);
		fprintf(stderr, "objdump      = '%s'\n", objdump);
		fprintf(stderr, "objcopy      = '%s'\n", objcopy);
		fprintf(stderr, "ldscriptpath = '%s'\n", ldscriptpath);
	}

	/* Pass off to regular linker, if there's nothing elf2flt-like */
	if (!have_elf2flt_options)
		return execute(linker, NULL, &all_options);

	/* Pass off to regular linker, minus the elf2flt options, if it's
	   not the final link.  */
	if (!flag_final)
		return execute(linker, NULL, &other_options, "-o", output_file);

	if (want_shared && !shared_lib_id)
		fatal("-shared used without passing a shared library ID");

	/* Otherwise link & convert to flt.  */
	output_gdb = concat(output_file, ".gdb", NULL);
	tmp_file = make_temp_file(NULL);
	status = do_final_link();
	if (!flag_verbose) {
		unlink(tmp_file);
		unlink(output_flt);
		unlink(output_elf);
	} else {
		fprintf(stderr,
			"leaving elf2flt temp files behind:\n"
			"tmp_file   = %s\n"
			"output_flt = %s\n"
			"output_elf = %s\n",
			tmp_file, output_flt, output_elf);
	}
	return status;
}
