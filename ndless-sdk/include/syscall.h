#ifndef SYSCALL_H
#define SYSCALL_H

/* GCC has a bug which prevents use of the register keyword in templates :-(
 * These inline global functions are workarounds... */

static inline int wa_syscall(int nr)
{
	register int r0 asm("r0");
  
	asm volatile(
		"swi %[nr]\n"
		: "=r" (r0)
		: [nr] "i" (nr)
		: "memory", "r1", "r2", "r3", "r4", "r12", "lr");
  
	return r0;
}

static inline int wa_syscall1(int nr, int p1)
{
	register int r0 asm("r0") = p1;
  
	asm volatile(
		"swi %[nr]\n"
		: "=r" (r0)
		: [nr] "i" (nr), "r" (r0)
		: "memory", "r1", "r2", "r3", "r4", "r12", "lr");
  
	return r0;
}

static inline int wa_syscall2(int nr, int p1, int p2)
{
	register int r0 asm("r0") = p1;
	register int r1 asm("r1") = p2;
  
	asm volatile(
		"swi %[nr]\n"
		: "=r" (r0)
		: [nr] "i" (nr), "r" (r0), "r" (r1)
		: "memory", "r2", "r3", "r4", "r12", "lr");
  
	return r0;
}

static inline int wa_syscall3(int nr, int p1, int p2, int p3)
{
	register int r0 asm("r0") = p1;
	register int r1 asm("r1") = p2;
	register int r2 asm("r2") = p3;
	
	asm volatile(
		"swi %[nr]\n"
		: "=r" (r0)
		: [nr] "i" (nr), "r" (r0), "r" (r1), "r" (r2)
		: "memory", "r3", "r4", "r12", "lr");
  
	return r0;
}

static inline int wa_syscall4(int nr, int p1, int p2, int p3, int p4)
{
	register int r0 asm("r0") = p1;
	register int r1 asm("r1") = p2;
	register int r2 asm("r2") = p3;
	register int r3 asm("r3") = p4;
 
	asm volatile(
		"swi %[nr]\n"
		: "=r" (r0)
		: [nr] "i" (nr), "r" (r0), "r" (r1), "r" (r2), "r" (r3)
		: "memory", "r4", "r12", "lr");
  
	return r0;
}

template <int nr, typename RETTYPE> inline RETTYPE syscall()
{
	return (RETTYPE) wa_syscall(nr);
}

template <int nr, typename RETTYPE, typename PARAM1> inline RETTYPE syscall(PARAM1 p1)
{
	return (RETTYPE) wa_syscall1(nr, (int) p1);
}

template <int nr, typename RETTYPE, typename PARAM1, typename PARAM2> inline RETTYPE syscall(PARAM1 p1, PARAM2 p2)
{
	return (RETTYPE) wa_syscall2(nr, (int) p1, (int) p2);
}

template <int nr, typename RETTYPE, typename PARAM1, typename PARAM2, typename PARAM3> inline RETTYPE syscall(PARAM1 p1, PARAM2 p2, PARAM3 p3)
{
	return (RETTYPE) wa_syscall3(nr, (int) p1, (int) p2, (int) p3);
}

template <int nr, typename RETTYPE, typename PARAM1, typename PARAM2, typename PARAM3, typename PARAM4> inline RETTYPE syscall(PARAM1 p1, PARAM2 p2, PARAM3 p3, PARAM4 p4)
{
	return (RETTYPE) wa_syscall4(nr, (int) p1, (int) p2, (int) p3, (int) p4);
}

// If we are in stage1 (the installer) we use the OS' addresses directly.
#ifdef STAGE1

extern "C" int ut_os_version_index;

template <int nr> int syscall_addr()
{
	return 
		/* 0-5 is OS 3.1, not used in STAGE1
		ut_os_version_index == 0 ? syscall_addrs[0][nr] :
		ut_os_version_index == 1 ? syscall_addrs[1][nr] :
		ut_os_version_index == 2 ? syscall_addrs[2][nr] :
		ut_os_version_index == 3 ? syscall_addrs[3][nr] :
		ut_os_version_index == 4 ? syscall_addrs[4][nr] :
		ut_os_version_index == 5 ? syscall_addrs[5][nr] : */

#ifndef NDLESS_39
		ut_os_version_index == 6 ? syscall_addrs[6][nr] :
		ut_os_version_index == 7 ? syscall_addrs[7][nr] :
		ut_os_version_index == 8 ? syscall_addrs[8][nr] :
		syscall_addrs[9][nr];
#elif NDLESS_39 == 39
		ut_os_version_index == 10 ? syscall_addrs[10][nr] :
		ut_os_version_index == 11 ? syscall_addrs[11][nr] :
		ut_os_version_index == 12 ? syscall_addrs[12][nr] :
		syscall_addrs[13][nr];
#elif NDLESS_39 == 391
		ut_os_version_index == 14 ? syscall_addrs[14][nr] :
		ut_os_version_index == 15 ? syscall_addrs[15][nr] :
		ut_os_version_index == 16 ? syscall_addrs[16][nr] :
		syscall_addrs[17][nr];
#else
	#error No (known) STAGE1 OS version given!
#endif
}

template <int nr, typename RETTYPE> inline RETTYPE syscall_local()
{
	return ((RETTYPE (*)()) syscall_addr<nr>())();
}

template <int nr, typename RETTYPE, typename PARAM1> inline RETTYPE syscall_local(PARAM1 p1)
{
	return ((RETTYPE (*)(PARAM1)) syscall_addr<nr>())(p1);
}

template <int nr, typename RETTYPE, typename PARAM1, typename PARAM2> inline RETTYPE syscall_local(PARAM1 p1, PARAM2 p2)
{
	return ((RETTYPE (*)(PARAM1, PARAM2)) syscall_addr<nr>())(p1, p2);
}

template <int nr, typename RETTYPE, typename PARAM1, typename PARAM2, typename PARAM3> inline RETTYPE syscall_local(PARAM1 p1, PARAM2 p2, PARAM3 p3)
{
	return ((RETTYPE (*)(PARAM1, PARAM2, PARAM3)) syscall_addr<nr>())(p1, p2, p3);
}

template <int nr, typename RETTYPE, typename PARAM1, typename PARAM2, typename PARAM3, typename PARAM4> inline RETTYPE syscall_local(PARAM1 p1, PARAM2 p2, PARAM3 p3, PARAM4 p4)
{
	return ((RETTYPE (*)(PARAM1, PARAM2, PARAM3, PARAM4)) syscall_addr<nr>())(p1, p2, p3, p4);
}

template <int nr, typename RETTYPE, typename PARAM1, typename PARAM2, typename PARAM3, typename PARAM4, typename PARAM5> inline RETTYPE syscall_local(PARAM1 p1, PARAM2 p2, PARAM3 p3, PARAM4 p4, PARAM5 p5)
{
	return ((RETTYPE (*)(PARAM1, PARAM2, PARAM3, PARAM4, PARAM5)) syscall_addr<nr>())(p1, p2, p3, p4, p5);
}

template <int nr, typename RETTYPE, typename PARAM1, typename PARAM2, typename PARAM3, typename PARAM4, typename PARAM5, typename PARAM6> inline RETTYPE syscall_local(PARAM1 p1, PARAM2 p2, PARAM3 p3, PARAM4 p4, PARAM5 p5, PARAM6 p6)
{
	return ((RETTYPE (*)(PARAM1, PARAM2, PARAM3, PARAM4, PARAM5, PARAM6)) syscall_addr<nr>())(p1, p2, p3, p4, p5, p6);
}

#endif

#endif
