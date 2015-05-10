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

// The returned value is never freed, it should be allocated statically. argv may be modified freely.
typedef const char16_t *(*calchook_callback)(void *state1, void *state2, unsigned int argc, char16_t *argv[]);

// name has to end on a '(', like u"ndls_run(";
bool calchook_register(const char16_t *name, calchook_callback callback);
void calchook_install();

#ifdef __cplusplus
	}
#endif

#endif
