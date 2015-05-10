#ifndef CALKHOOK_H
#define CALCHOOK_H

#include <stdint.h>

// uchar.h doesn't exist in newlib...
// #include <uchar.h>
#ifndef __cplusplus
	typedef uint16_t char16_t;
#else
	extern "C" {
#endif

void calchook_install();

#ifdef __cplusplus
	}
#endif

#endif
