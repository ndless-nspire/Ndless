@ startup code

#include <os.h>

__base: .global __base
lib_main: .global lib_main
    stmfd sp!, {r4-r11,lr}
	str  sp, __crt0_savedsp
#ifdef CRT0_CPP
	bl __cpp_init /* C++ static initializers */
#endif
	bl   main
#ifdef CRT0_CPP
	bl __cpp_fini /* C++ static destructors */
#endif
__crt0exit: .global __crt0exit
	ldmfd sp!, {r4-r11,pc}

__crt0_savedsp: .global __crt0_savedsp
	.long 0
