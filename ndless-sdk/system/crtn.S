/* Any copyright is dedicated to the Public Domain.
 * http://creativecommons.org/publicdomain/zero/1.0/ */
/* for C++ support */

.section .text.crtn
exit: .weak exit /* If linked without newlib, used by crt0. Can't be defined in crt0, as newlibs exit is also weak */
	bl __crt0_exit

.section .init_array
	.long -1 /* Terminating character for ctor list */
    
.section .fini_array
	.long -1
