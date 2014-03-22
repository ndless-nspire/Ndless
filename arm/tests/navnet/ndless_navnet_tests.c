/****************************************************************************
 * Automated NavNet tests
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

#include <sys/time.h>
#ifdef NAVNET_TESTS_CALC
#include <os.h>
#else
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <navnet.h>
#include <time.h>
#ifdef _WIN32
#include <windows.h>
#else
typedef enum {FALSE, TRUE} BOOL;
#endif
#endif

#if defined(_WIN32)
#define sleeps(d) Sleep((d)*1000)
#elif defined(NAVNET_TESTS_CALC)
//#define sleeps(d) sleep((d)*1000)
#define sleeps(d)
#else
#define sleeps(d) sleep(d)
#endif

nn_ch_t ch = NULL;
nn_oh_t oh = NULL;
nn_nh_t nh = NULL;

static char async_err[50] = "";

// positive check
#define NNCALL(f,p) do {if ((f p) < 0) exit_with_error("on " #f "()");} while(0)
#define NNCALL_ASYNC(f,p) do {if ((f p) < 0 && !strcmp("", async_err)) strncpy(async_err, "on async " #f "()", sizeof(async_err));} while(0)
// non-null check
#define NNCALLP(f,p) do {if ((f p) == NULL) exit_with_error("on " #f "()");} while(0)
#define assert_non_null(m,p) do {if ((p) == NULL) exit_with_error(m);} while(0)
#define assert_zero(m,p) do {if ((p)) exit_with_error(m);} while(0)
#define assert_zero_async(m,p) do {if ((p) && !strcmp("", async_err)) strncpy(async_err, m, sizeof(async_err));} while(0)
#define assert_non_zero(m,p) do {if (!(p)) exit_with_error(m);} while(0)
#define assert_true(m,p) do {if (!(p)) exit_with_error(m);} while(0)
#define assert_true_async(m,p) do {if (!(p) && !strcmp("", async_err)) strncpy(async_err, m, sizeof(async_err));} while(0)

#ifdef NAVNET_TESTS_PC
#define show_msgbox(t,m) do { puts(m); } while(0)
#endif

#ifdef NAVNET_TESTS_PC
static void nlog(const char *m) {
	time_t timer;
	char buf[25];
	struct tm* tm_info;
	time(&timer);
	tm_info = localtime(&timer);
	strftime(buf, sizeof(buf), "%H:%M:%S", tm_info);
	printf("%s - %s\n", buf, m);
	fflush(stdout);
}
#else
#define nlog(m)
#endif

static uint32_t local_service_id, remote_service_id;

static void show_error(const char *m) {
	char msg[50];
	snprintf(msg, sizeof(msg), "Failed: %s", m);
	show_msgbox("NavNet Tests - Failed", msg);
}
	
static __attribute__ ((noreturn)) void exit_with_error(const char *m) {
	show_error(m);
	TI_NN_StopService(local_service_id);
	if (oh)
		TI_NN_DestroyOperationHandle(oh);
	if (ch)
		TI_NN_Disconnect(ch);
#ifdef NAVNET_TESTS_PC
	TI_NN_Shutdown();
#endif
	exit(1);
}

static volatile BOOL service_called = FALSE;

static void service_cb(nn_ch_t ch, __attribute__((unused)) void *data) {
	nlog("Service called");
	uint32_t buf_size = TI_NN_GetConnMaxPktSize(ch);
	char buf[buf_size];
	uint32_t data_size;
	nlog("Read request");
	NNCALL_ASYNC(TI_NN_Read, (ch, 500, buf, buf_size, &data_size));
	assert_true_async("invalid request size", data_size <= buf_size);
	assert_zero_async("invalid request received", strncmp("request", buf, data_size));
	char *msg = "response";
	nlog("Write response");
	NNCALL_ASYNC(TI_NN_Write, (ch, msg, strlen(msg) + 1));
	service_called = TRUE;
	nlog("Response written");
}

static BOOL wait_for_service_call(void) {
	struct timeval init_tv, tv;
	gettimeofday(&init_tv, NULL);
	do {
		sleeps(1);
		gettimeofday(&tv, NULL);
	} while (!service_called && tv.tv_sec - init_tv.tv_sec < 10);
	return service_called;
}

static volatile BOOL partner_connected = FALSE;

#ifdef NAVNET_TESTS_PC
static void notify_cb(void) {
	partner_connected = TRUE;
}
#endif

// the test program makes the computer and the calculator each expose a service.
int main(void) {
	int16_t ret;
	struct timeval init_tv, tv;
#ifdef NAVNET_TESTS_PC
	local_service_id = 0x8001;
	remote_service_id = 0x8002;
#else
	local_service_id = 0x8002;
	remote_service_id = 0x8001;
#endif
#ifdef NAVNET_TESTS_CALC
	TCT_Local_Control_Interrupts(0);
#endif
#ifdef NAVNET_TESTS_PC
	NNCALL(TI_NN_Init, ("-c 0 -d 0"));
#endif
	TI_NN_StartService(local_service_id, NULL, &service_cb);
// strangely not working on calc
#ifdef NAVNET_TESTS_PC
	TI_NN_RegisterNotifyCallback(0, notify_cb);
	nlog("Wait for remote node");
	gettimeofday(&init_tv, NULL);
	while (!gettimeofday(&tv, NULL) && !partner_connected && tv.tv_sec - init_tv.tv_sec < 5) {
		sleeps(1);
	}
	assert_true("remote node not found", partner_connected);
	nlog("Notified of remote node");
#endif
#ifdef NAVNET_TESTS_CALC
	if (!wait_for_service_call()) {
		assert_true("service not called", service_called);
	}
#endif
	NNCALLP(oh = TI_NN_CreateOperationHandle, ());
	NNCALL(TI_NN_NodeEnumInit, (oh));
	NNCALL(TI_NN_NodeEnumNext, (oh, &nh));
	NNCALL(TI_NN_NodeEnumDone, (oh));
	NNCALL(TI_NN_DestroyOperationHandle, (oh));
	oh = NULL;
	assert_non_null("no remote node connected.", nh);
	NNCALL(TI_NN_Connect, (nh, remote_service_id, &ch));
	assert_non_null("can't connect to remote service.", ch);
	char *msg = "request";
	// our test sequence is pc->calc then calc->pc, because a calc->pc service availability check
	// with a TI_NN_Write() loop doesn't work.
	gettimeofday(&init_tv, NULL);
	// TI_NN_Connect will succeed even the if the service d oesn't exist, but TI_NN_Write will fail.
	// Wait until available or timeout.
	// Looping on a TI_NN_Write() for service availability check doesn't seem to work on calculator,
	// you must make sure that the service is available before with a pc->calc service call poll.
	nlog("Write request");
	while ((ret = TI_NN_Write(ch, msg, strlen(msg) + 1)) < 0 && !gettimeofday(&tv, NULL) && tv.tv_sec - init_tv.tv_sec < 10) {
		sleeps(2);
		nlog("Write request (retry)");
	}
	assert_true("can't write to remote service", ret >= 0);
	char recv_buf[100];
	uint32_t recv_size;
	nlog("Read response");
	NNCALL(TI_NN_Read, (ch, 500, recv_buf, sizeof(recv_buf), &recv_size));
	assert_true("invalid response size", recv_size <= sizeof(recv_buf));
	assert_zero("invalid response received", strncmp("response", recv_buf, recv_size));
#ifdef NAVNET_TESTS_PC
	nlog("Wait for service call");
	if (!wait_for_service_call()) {
		assert_true("service not called", service_called);
	}
#endif
	if (strcmp("", async_err)) {
		exit_with_error(async_err);
	}
	nlog("Disconnect");
	NNCALL(TI_NN_Disconnect, (ch));
	ch = NULL;
	nlog("Stop service");
	NNCALL(TI_NN_StopService, (local_service_id));
#ifdef NAVNET_TESTS_PC
	NNCALL(TI_NN_Shutdown, ());
#endif
	gettimeofday(&tv, NULL);
	show_msgbox("NavNet Tests - Success", "NavNet works well!    ");
	return 0;	
}
