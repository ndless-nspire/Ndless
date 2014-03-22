/****************************************************************************
 * Command-line tool for NavNet
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
 * Contributor(s): 
 ****************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <string.h>
#include <unistd.h>
#include <navnet.h>
#include <time.h>
#include <windows.h>
#include <sys/time.h>

nn_ch_t ch = NULL;
nn_oh_t oh = NULL;
nn_nh_t nh = NULL;

// positive check
#define NNCALL(f,p) do {if ((f p) < 0) exit_with_error("on " #f "()");} while(0)
// non-null check
#define NNCALLP(f,p) do {if ((f p) == NULL) exit_with_error("on " #f "()");} while(0)
#define assert_non_null(m,p) do {if ((p) == NULL) exit_with_error(m);} while(0)
#define assert_zero(m,p) do {if ((p)) exit_with_error(m);} while(0)
#define assert_zero_async(m,p) do {if ((p) && !strcmp("", async_err)) strncpy(async_err, m, sizeof(async_err));} while(0)
#define assert_non_zero(m,p) do {if (!(p)) exit_with_error(m);} while(0)
#define assert_true(m,p) do {if (!(p)) exit_with_error(m);} while(0)

static void show_error(const char *m) {
	char msg[50];
	snprintf(msg, sizeof(msg), "Failed: %s", m);
	puts(msg);
}
	
static __attribute__ ((noreturn)) void exit_with_error(const char *m) {
	show_error(m);
	if (oh)
		TI_NN_DestroyOperationHandle(oh);
	if (ch)
		TI_NN_Disconnect(ch);
	TI_NN_Shutdown();
	exit(1);
}

static volatile BOOL partner_connected = FALSE;

static void notify_cb(void) {
	partner_connected = TRUE;
}

#define FILE_SERVICE_ID 0x4060

static void nconnect(uint32_t remote_service_id) {
	struct timeval init_tv, tv;
	NNCALL(TI_NN_Init, ("-c 1 -d 0"));
	TI_NN_RegisterNotifyCallback(0, notify_cb);
	gettimeofday(&init_tv, NULL);
	while (!gettimeofday(&tv, NULL) && !partner_connected && tv.tv_sec - init_tv.tv_sec < 5) {
		Sleep(1000);
	}
	assert_true("remote node not found", partner_connected);
	NNCALLP(oh = TI_NN_CreateOperationHandle, ());
	NNCALL(TI_NN_NodeEnumInit, (oh));
	NNCALL(TI_NN_NodeEnumNext, (oh, &nh));
	NNCALL(TI_NN_NodeEnumDone, (oh));
	NNCALL(TI_NN_DestroyOperationHandle, (oh));
	oh = NULL;
	assert_non_null("no remote node connected.", nh);
	NNCALL(TI_NN_Connect, (nh, remote_service_id, &ch));
	assert_non_null("can't connect to remote service.", ch);
}

static void ndisconnect(void) {
	NNCALL(TI_NN_Disconnect, (ch));
	ch = NULL;
	NNCALL(TI_NN_Shutdown, ());
}


static void putfile(const char *localfile, const char *remotefile) {
	nconnect(FILE_SERVICE_ID);
	char fullpath[PATH_MAX+1];;
	assert_non_zero("local file not found", GetFullPathNameA(localfile, sizeof(fullpath), fullpath, 0));
	NNCALLP(oh = TI_NN_CreateOperationHandle, ());
	NNCALL(TI_NN_PutFile, (ch, oh, fullpath, remotefile));
	NNCALL(TI_NN_DestroyOperationHandle, (oh));
	ndisconnect();
	printf("Successfully put '%s' to '%s'.\n", localfile, remotefile);
}

static void usage(void) {
	puts("usage: navnetcmd <cmd> opts...");
	puts("       navnetcmd put <localfile> <remotefile>");

}

int main(int argc, char *argv[]) {
	if (argc == 1) {
		usage();
		return 0;
	}
	if (!strcmp(argv[1], "put")) {
		if (argc != 4) {
			usage();
			return 1;
		}
		putfile(argv[2], argv[3]);
		return 0;
	}
	else {
		printf("unknown command: %s\n", argv[2]);
		usage();
		return 1;
	}
}
