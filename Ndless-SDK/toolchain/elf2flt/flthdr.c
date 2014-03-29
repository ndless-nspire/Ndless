/****************************************************************************/
/*
 *	A simple program to manipulate flat files
 *
 *	Copyright (C) 2001-2003 SnapGear Inc, davidm@snapgear.com
 *	Copyright (C) 2001 Lineo, davidm@lineo.com
 *
 * This is Free Software, under the GNU Public Licence v2 or greater.
 *
 */
/****************************************************************************/

#include <stdio.h>    /* Userland pieces of the ANSI C standard I/O package  */
#include <unistd.h>   /* Userland prototypes of the Unix std system calls    */
#include <time.h>
#include <stdlib.h>   /* exit() */
#include <string.h>   /* strcat(), strcpy() */
#include <inttypes.h>
#include <assert.h>

#include "compress.h"
#include <libiberty.h>

#include "stubs.h"
const char *elf2flt_progname;

/* from uClinux-x.x.x/include/linux */
#include "flat.h"     /* Binary flat header description                      */

#if defined(__MINGW32__)
#include <getopt.h>

#define mkstemp(p) mktemp(p)

#endif

#if defined TARGET_bfin
# define flat_get_relocate_addr(addr) (addr & 0x03ffffff)
#else
# define flat_get_relocate_addr(addr) (addr)
#endif

/****************************************************************************/

static int print = 0, print_relocs = 0, docompress = 0, ramload = 0,
           stacksize = 0, ktrace = 0, l1stack = 0;

/****************************************************************************/

void
process_file(char *ifile, char *ofile)
{
	int old_flags, old_stack, new_flags, new_stack;
	stream ifp, ofp;
	struct flat_hdr old_hdr, new_hdr;
	char *tfile, tmpbuf[256];
	int input_error, output_error;

	*tmpbuf = '\0';

	if (fopen_stream_u(&ifp, ifile, "r" BINARY_FILE_OPTS)) {
		fprintf(stderr, "Cannot open %s\n", ifile);
		return;
	}

	if (fread_stream(&old_hdr, sizeof(old_hdr), 1, &ifp) != 1) {
		fprintf(stderr, "Cannot read header of %s\n", ifile);
		fclose_stream(&ifp);
		return;
	}

	if (strncmp(old_hdr.magic, "bFLT", 4) != 0) {
		fprintf(stderr, "Cannot read header of %s\n", ifile);
		fclose_stream(&ifp);
		return;
	}

	new_flags = old_flags = ntohl(old_hdr.flags);
	new_stack = old_stack = ntohl(old_hdr.stack_size);
	new_hdr = old_hdr;

	if (docompress == 1) {
		new_flags |= FLAT_FLAG_GZIP;
		new_flags &= ~FLAT_FLAG_GZDATA;
	} else if (docompress == 2) {
		new_flags |= FLAT_FLAG_GZDATA;
		new_flags &= ~FLAT_FLAG_GZIP;
	} else if (docompress < 0)
		new_flags &= ~(FLAT_FLAG_GZIP|FLAT_FLAG_GZDATA);
	
	if (ramload > 0)
		new_flags |= FLAT_FLAG_RAM;
	else if (ramload < 0)
		new_flags &= ~FLAT_FLAG_RAM;
	
	if (ktrace > 0)
		new_flags |= FLAT_FLAG_KTRACE;
	else if (ktrace < 0)
		new_flags &= ~FLAT_FLAG_KTRACE;
	
	if (l1stack > 0)
		new_flags |= FLAT_FLAG_L1STK;
	else if (l1stack < 0)
		new_flags &= ~FLAT_FLAG_L1STK;

	if (stacksize)
		new_stack = stacksize;

	if (print == 1) {
		time_t t;
		uint32_t reloc_count, reloc_start;

		printf("%s\n", ifile);
		printf("    Magic:        %4.4s\n", old_hdr.magic);
		printf("    Rev:          %d\n",    ntohl(old_hdr.rev));
		t = (time_t) htonl(old_hdr.build_date);
		printf("    Build Date:   %s",      t?ctime(&t):"not specified\n");
		printf("    Entry:        0x%x\n",  ntohl(old_hdr.entry));
		printf("    Data Start:   0x%x\n",  ntohl(old_hdr.data_start));
		printf("    Data End:     0x%x\n",  ntohl(old_hdr.data_end));
		printf("    BSS End:      0x%x\n",  ntohl(old_hdr.bss_end));
		printf("    Stack Size:   0x%x\n",  ntohl(old_hdr.stack_size));
		reloc_start = ntohl(old_hdr.reloc_start);
		printf("    Reloc Start:  0x%x\n",  reloc_start);
		reloc_count = ntohl(old_hdr.reloc_count);
		printf("    Reloc Count:  0x%x\n",  reloc_count);
		printf("    Flags:        0x%x ( ",  ntohl(old_hdr.flags));
		if (old_flags) {
			if (old_flags & FLAT_FLAG_RAM)
				printf("Load-to-Ram ");
			if (old_flags & FLAT_FLAG_GOTPIC)
				printf("Has-PIC-GOT ");
			if (old_flags & FLAT_FLAG_GZIP)
				printf("Gzip-Compressed ");
			if (old_flags & FLAT_FLAG_GZDATA)
				printf("Gzip-Data-Compressed ");
			if (old_flags & FLAT_FLAG_KTRACE)
				printf("Kernel-Traced-Load ");
			if (old_flags & FLAT_FLAG_L1STK)
				printf("L1-Scratch-Stack ");
			printf(")\n");
		}

		if (print_relocs) {
			uint32_t *relocs = xcalloc(reloc_count, sizeof(uint32_t));
			uint32_t i;
			unsigned long r;

			printf("    Relocs:\n");
			printf("    #\treloc      (  address )\tdata\n");

			if (old_flags & FLAT_FLAG_GZIP)
				reopen_stream_compressed(&ifp);
			if (fseek_stream(&ifp, reloc_start, SEEK_SET)) {
				fprintf(stderr, "Cannot seek to relocs of %s\n", ifile);
				fclose_stream(&ifp);
				return;
			}
			if (fread_stream(relocs, sizeof(uint32_t), reloc_count, &ifp) == -1) {
				fprintf(stderr, "Cannot read relocs of %s\n", ifile);
				fclose_stream(&ifp);
				return;
			}

			for (i = 0; i < reloc_count; ++i) {
				uint32_t raddr, addr;
				r = ntohl(relocs[i]);
				raddr = flat_get_relocate_addr(r);
				printf("    %u\t0x%08lx (0x%08"PRIx32")\t", i, r, raddr);
				fseek_stream(&ifp, sizeof(old_hdr) + raddr, SEEK_SET);
				fread_stream(&addr, sizeof(addr), 1, &ifp);
				printf("%"PRIx32"\n", addr);
			}

			/* reset file position for below */
			fseek_stream(&ifp, sizeof(old_hdr), SEEK_SET);
		}
	} else if (print > 1) {
		static int first = 1;
		unsigned int text, data, bss, stk, rel, tot;

		if (first) {
			printf("Flag Rev   Text   Data    BSS  Stack Relocs    RAM Filename\n");
			printf("-----------------------------------------------------------\n");
			first = 0;
		}
		*tmpbuf = '\0';
		strcat(tmpbuf, (old_flags & FLAT_FLAG_KTRACE) ? "k" : "");
		strcat(tmpbuf, (old_flags & FLAT_FLAG_RAM) ? "r" : "");
		strcat(tmpbuf, (old_flags & FLAT_FLAG_GOTPIC) ? "p" : "");
		strcat(tmpbuf, (old_flags & FLAT_FLAG_GZIP) ? "z" :
					((old_flags & FLAT_FLAG_GZDATA) ? "d" : ""));
		printf("-%-3.3s ", tmpbuf);
		printf("%3d ", ntohl(old_hdr.rev));
		printf("%6d ", text=ntohl(old_hdr.data_start)-sizeof(struct flat_hdr));
		printf("%6d ", data=ntohl(old_hdr.data_end)-ntohl(old_hdr.data_start));
		printf("%6d ", bss=ntohl(old_hdr.bss_end)-ntohl(old_hdr.data_end));
		printf("%6d ", stk=ntohl(old_hdr.stack_size));
		printf("%6d ", rel=ntohl(old_hdr.reloc_count) * 4);
		/*
		 * work out how much RAM is needed per invocation, this
		 * calculation is dependent on the binfmt_flat implementation
		 */
		tot = data; /* always need data */

		if (old_flags & (FLAT_FLAG_RAM|FLAT_FLAG_GZIP))
			tot += text + sizeof(struct flat_hdr);
		
		if (bss + stk > rel) /* which is bigger ? */
			tot += bss + stk;
		else
			tot += rel;

		printf("%6d ", tot);
		/*
		 * the total depends on whether the relocs are smaller/bigger than
		 * the BSS
		 */
		printf("%s\n", ifile);
	}

	/* if there is nothing else to do, leave */
	if (new_flags == old_flags && new_stack == old_stack) {
		fclose_stream(&ifp);
		return;
	}

	new_hdr.flags = htonl(new_flags);
	new_hdr.stack_size = htonl(new_stack);

	tfile = make_temp_file("flthdr");

	if (fopen_stream_u(&ofp, tfile, "w" BINARY_FILE_OPTS)) {
		unlink(tfile);
		fatal("Failed to open %s for writing\n", tfile);
	}

	/* Copy header (always uncompressed).  */
	if (fwrite_stream(&new_hdr, sizeof(new_hdr), 1, &ofp) != 1) {
		unlink(tfile);
		fatal("Failed to write to  %s\n", tfile);
	}

	/* Whole input file (including text) is compressed: start decompressing
	   now.  */
	if (old_flags & FLAT_FLAG_GZIP)
		reopen_stream_compressed(&ifp);

	/* Likewise, output file is compressed. Start compressing now.  */
	if (new_flags & FLAT_FLAG_GZIP) {
		printf("zflat %s --> %s\n", ifile, ofile);
		reopen_stream_compressed(&ofp);
	}

	transfer(&ifp, &ofp,
		  ntohl(old_hdr.data_start) - sizeof(struct flat_hdr));

	/* Only data and relocs were compressed in input.  Start decompressing
	   from here.  */
	if (old_flags & FLAT_FLAG_GZDATA)
		reopen_stream_compressed(&ifp);

	/* Only data/relocs to be compressed in output.  Start compressing
	   from here.  */
	if (new_flags & FLAT_FLAG_GZDATA) {
		printf("zflat-data %s --> %s\n", ifile, ofile);
		reopen_stream_compressed(&ofp);
	}

	transfer(&ifp, &ofp, -1);

	input_error = ferror_stream(&ifp);
	output_error = ferror_stream(&ofp);

	if (input_error || output_error) {
		unlink(tfile);
		fatal("Error on file pointer%s%s\n",
				input_error ? " input" : "",
				output_error ? " output" : "");
	}

	fclose_stream(&ifp);
	fclose_stream(&ofp);

	/* Copy temporary file to output location.  */
	fopen_stream_u(&ifp, tfile, "r" BINARY_FILE_OPTS);
	fopen_stream_u(&ofp, ofile, "w" BINARY_FILE_OPTS);

	transfer(&ifp, &ofp, -1);

	fclose_stream(&ifp);
	fclose_stream(&ofp);

	unlink(tfile);
	free(tfile);
}

/****************************************************************************/

void
usage(char *s)
{
	if (s)
		fprintf(stderr, "%s\n", s);
	fprintf(stderr, "usage: %s [options] flat-file\n", elf2flt_progname);
	fprintf(stderr, "       Allows you to change an existing flat file\n\n");
	fprintf(stderr, "       -p      : print current settings\n");
	fprintf(stderr, "       -P      : print relocations\n");
	fprintf(stderr, "       -z      : compressed flat file\n");
	fprintf(stderr, "       -d      : compressed data-only flat file\n");
	fprintf(stderr, "       -Z      : un-compressed flat file\n");
	fprintf(stderr, "       -r      : ram load\n");
	fprintf(stderr, "       -R      : do not RAM load\n");
	fprintf(stderr, "       -k      : kernel traced load (for debug)\n");
	fprintf(stderr, "       -K      : normal non-kernel traced load\n");
	fprintf(stderr, "       -u      : place stack in L1 scratchpad memory\n");
	fprintf(stderr, "       -U      : place stack in normal SDRAM memory\n");
	fprintf(stderr, "       -s size : stack size\n");
	fprintf(stderr, "       -o file : output-file\n"
	                "                 (default is to modify input file)\n");
	exit(1);
}

/****************************************************************************/

int
main(int argc, char *argv[])
{
	int c, noargs;
	char *ofile = NULL, *ifile;

	elf2flt_progname = argv[0];

	noargs = 1;
	while ((c = getopt(argc, argv, "pPdzZrRuUkKs:o:")) != EOF) {
		switch (c) {
		case 'p': print = 1;                break;
		case 'P': print_relocs = 1;         break;
		case 'z': docompress = 1;           break;
		case 'd': docompress = 2;           break;
		case 'Z': docompress = -1;          break;
		case 'r': ramload = 1;              break;
		case 'R': ramload = -1;             break;
		case 'k': ktrace = 1;               break;
		case 'K': ktrace = -1;              break;
		case 'u': l1stack = 1;              break;
		case 'U': l1stack = -1;             break;
		case 'o': ofile = optarg;           break;
		case 's':
			if (sscanf(optarg, "%i", &stacksize) != 1)
				usage("invalid stack size");
			break;
		default:
			usage("invalid option");
			break;
		}
		noargs = 0;
	}

	if (optind >= argc)
		usage("No input files provided");

	if (ofile && argc - optind > 1)
		usage("-o can only be used with a single file");

	if (!print && noargs) /* no args == print */
		print = argc - optind; /* greater than 1 is short format */

	for (c = optind; c < argc; c++) {
		ifile = argv[c];
		if (!ofile)
			ofile = ifile;
		process_file(ifile, ofile);
		ofile = NULL;
	}
	
	exit(0);
}

/****************************************************************************/
