/* Any copyright is dedicated to the Public Domain.
 * http://creativecommons.org/publicdomain/zero/1.0/ */
/* for C++ support */
 
.section .init_array
    .long -1 /* Terminating character for ctor list */
    
.section .fini_array
    .long -1
