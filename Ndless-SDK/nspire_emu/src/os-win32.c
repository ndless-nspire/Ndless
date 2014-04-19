#include <stdio.h>
#include <stdlib.h>
#include "emu.h"
#include "os-win32.h"
#include <mmsystem.h>

static int addr_cache_exception(PEXCEPTION_RECORD er, void *x, void *y, void *z) {
	x = x; y = y; z = z; // unused parameters
	if (er->ExceptionCode == EXCEPTION_ACCESS_VIOLATION) {
		if (addr_cache_pagefault((void *)er->ExceptionInformation[1]))
			return 0; // Continue execution
	}
	return 1; // Continue search
}

void addr_cache_init(os_exception_frame_t *frame) {
	addr_cache = VirtualAlloc(NULL, AC_NUM_ENTRIES * sizeof(ac_entry), MEM_RESERVE, PAGE_READWRITE);

	frame->function = (void *)addr_cache_exception;
	asm ("movl %%fs:(%1), %0" : "=r" (frame->prev) : "r" (0));
	asm ("movl %0, %%fs:(%1)" : : "r" (frame), "r" (0));

	// Relocate the assembly code that wants addr_cache at a fixed address
	extern DWORD *ac_reloc_start[], *ac_reloc_end[];
	DWORD **reloc;
	for (reloc = ac_reloc_start; reloc != ac_reloc_end; reloc++) {
		DWORD prot;
		VirtualProtect(*reloc, 4, PAGE_EXECUTE_READWRITE, &prot);
		**reloc += (DWORD)addr_cache;
		VirtualProtect(*reloc, 4, prot, &prot);
	}
}

HANDLE hTimerEvent;
UINT uTimerID;
void throttle_timer_on() {
	hTimerEvent = CreateEvent(NULL, FALSE, FALSE, NULL);
	uTimerID = timeSetEvent(throttle_delay, throttle_delay, (LPTIMECALLBACK)hTimerEvent, 0,
	                        TIME_PERIODIC | TIME_CALLBACK_EVENT_SET);
	if (uTimerID == 0) {
		printf("timeSetEvent failed\n");
		exit(1);
	}
}
void throttle_timer_wait() {
	WaitForSingleObject(hTimerEvent, INFINITE);
}
void throttle_timer_off() {
	if (uTimerID != 0) {
		timeKillEvent(uTimerID);
		uTimerID = 0;
		CloseHandle(hTimerEvent);
	}
}
