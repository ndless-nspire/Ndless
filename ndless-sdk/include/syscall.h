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
#ifndef NDLESS_39
		ut_os_version_index == 0 ? syscall_addrs[0][nr] :
		ut_os_version_index == 1 ? syscall_addrs[1][nr] :
		ut_os_version_index == 2 ? syscall_addrs[2][nr] :
		ut_os_version_index == 3 ? syscall_addrs[3][nr] :
#endif
		ut_os_version_index == 4 ? syscall_addrs[4][nr] :
		ut_os_version_index == 5 ? syscall_addrs[5][nr] :
		ut_os_version_index == 6 ? syscall_addrs[6][nr] :
		syscall_addrs[7][nr];
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

#endif

#endif
