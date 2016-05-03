/* This file is in the public domain.
 * See http://creativecommons.org/licenses/publicdomain/deed.fr */

#ifndef _BSDCOMPAT
#define _BSDCOMPAT

// For compatibility with some *BSD specificities
#include <stdint.h>
// BSD's sys/types.h
typedef uint8_t u_int8_t;
typedef uint16_t u_int16_t;
typedef uint32_t u_int32_t;
typedef struct device  *device_t;
typedef unsigned int u_int;
typedef unsigned char u_char;
typedef unsigned long u_long;

// BSD's sys/dev/usb/usb_port.h
#define device_ptr_t device_t

// BSD's sys/tty.h
struct clist {
        int     c_cc;           /* Number of characters in the clist. */
        int     c_cbcount;      /* Number of cblocks. */
        int     c_cbmax;        /* Max # cblocks allowed for this clist. */
        int     c_cbreserved;   /* # cblocks reserved for this clist. */
        char    *c_cf;          /* Pointer to the first cblock. */
        char    *c_cl;          /* Pointer to the last cblock. */
};

#ifndef __packed
#define __packed __attribute__((packed))
#endif

// sys/errno.h
#ifndef ENXIO
#define ENXIO 6 /* Device not configured */
#endif

#endif
