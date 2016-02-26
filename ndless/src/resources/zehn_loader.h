#ifndef ZEHN_LOADER
#define ZEHN_LOADER

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

int zehn_load(NUC_FILE *file, void **mem_ptr, int (**entry_address_ptr)(int,char*[]), bool *supports_hww);

#ifdef __cplusplus
}
#endif

#endif // !ZEHN_LOADER
