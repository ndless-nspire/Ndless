#ifndef ZEHN_LOADER
#define ZEHN_LOADER

#ifdef __cplusplus
extern "C" {
#endif

int zehn_load(NUC_FILE *file, void **mem_ptr, int (**entry_address_ptr)(int,char*[]));

#ifdef __cpluspls
}
#endif

#endif // !ZEHN_LOADER
