/* newlib stub that makes newlib happy. When a function is implemented by both newlib and the TI-Nspire OS,
 * the OS version should be used. That's why these functions ar empty. */

#include <os.h>
#include <sys/types.h>

struct _reent{};

long _read_r(__attribute__((unused)) struct _reent *r, __attribute__((unused)) int file, __attribute__((unused)) void *ptr, __attribute__((unused)) size_t len) {
  return 0;
}

long _write_r(__attribute__((unused)) struct _reent *r, __attribute__((unused)) int file, __attribute__((unused)) const void *ptr, __attribute__((unused)) size_t len) {
  return 0;
}

int _open_r(__attribute__((unused))  void *reent, __attribute__((unused)) const char *file, __attribute__((unused)) int flags, __attribute__((unused)) int mode) {
  return 0;
}

int _close_r(__attribute__((unused)) struct _reent *r, __attribute__((unused)) int file) {
  return 0;
}

off_t _lseek_r(__attribute__((unused)) struct _reent *r, __attribute__((unused)) int file, __attribute__((unused)) off_t ptr, __attribute__((unused)) int dir) {
  return 0;
}

int _fstat_r(__attribute__((unused)) struct _reent *r, __attribute__((unused)) int file, __attribute__((unused)) struct stat *st) {
  return 0;
}

void* _sbrk_r(__attribute__((unused)) struct _reent *_s_r, __attribute__((unused)) ptrdiff_t nbytes) {
  return (void*)0;
}

int _getpid_r(void) {
	return 1;
}

int _kill_r(__attribute__((unused)) int pid, __attribute__((unused)) int sig){
	return-1;
}

int _link_r(__attribute__((unused)) char *old, __attribute__((unused)) char *new) {
	return -1;
}

int _times_r(__attribute__((unused)) void *buf){
	return -1;
}

int _wait_r(__attribute__((unused)) int *status) {
	return -1;
}

void _exit(void) {
	exit(-1);
}

int _isatty(__attribute__((unused)) int file) {
	return 1;
}

int _gettimeofday_r(__attribute__((unused)) struct _reent *ptr, struct timeval *tp, __attribute__((unused)) void *tz) {
	tp->tv_sec = *(volatile unsigned*)0x90090000;
	tp->tv_usec = 0;
	return 0;
}
