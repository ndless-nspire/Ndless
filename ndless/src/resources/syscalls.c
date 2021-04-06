/****************************************************************************
 * Ndless syscalls setup and handlers
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 *
 * The Original Code is Ndless code.
 *
 * The Initial Developer of the Original Code is Olivier ARMAND
 * <olivier.calc@gmail.com>.
 * Portions created by the Initial Developer are Copyright (C) 2010-2014
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): 
 ****************************************************************************/

#include <libndls.h>
#include <os.h>
#include <syscall-list.h>

#include "lcd_compat.h"
#include "ndless.h"

/* Ndless extensions exposed as syscalls. See os.h for documentation. */

/* Values is an array of values for
 * non-CAS 3.1, CAS 3.1, non-CAS CX 3.1, CAS CX 3.1, CM-C 3.1, CAS CM-C 3.1,
 * non-CAS 3.6, CAS 3.6, non-CAS CX 3.6, CAS CX 3.6,
 * non-CAS 3.9.0, CAS 3.9.0, non-CAS CX 3.9.0, CAS CX 3.9.0,
 * non-CAS 3.9.1, CAS 3.9.1, non-CAS CX 3.9.1, CAS CX 3.9.1,
 * non-CAS CX 4.0.0, CAS CX 4.0.0,
 * non-CAS CX 4.0.3 and CAS CX 4.0.3,
 * non-CAS CX 4.2.0 and CAS CX 4.2.0,
 * non-CAS CX 4.3.0.702 and CAS CX 4.3.0.702,
 * non-CAS CX 4.4.0.532 and CAS CX 4.4.0.532,
 * non-CAS CX 4.5.0.1180 and CAS CX 4.5.0.1180,
 * non-CAS CX 4.5.1.12 and CAS CX 4.5.1.12,
 * non-CAS CX 4.5.3.14 and CAS CX 4.5.3.14,
 * non-CAS CX II 5.2.0.771, non-CAS CX II-T 5.2.0.771, CAS CX II 5.2.0.771,
 * non-CAS CX 4.5.4.48 and CAS CX 4.5.4.48, 
 * non-CAS CX II 5.3.0.564, non-CAS CX II-T 5.3.0.564, CAS CX II 5.3.0.564 */
int sc_nl_osvalue(const int *values, unsigned size) {
    unsigned index = ut_os_version_index;
    if (index >= size)
        return 0;
    return values[index];
}

/* The lightweight relocation support unfortunately cannot handle 
 * initializers with relocation (for example arrays of function pointers).
 * data.rel and data.rel.ro sections are created, but may contain both
 * non-relocable and relocable data, for which we have no clue.
 * This function allows to relocate an array of pointers.
 * This function is useless if the PRG binary format is not used. */
void sc_ext_relocdatab(unsigned *dataptr, unsigned size, void *base) {
    unsigned i;
    if (ld_bin_format != LD_PRG_BIN) return;
    for (i = size; i > 0; i--) {
        *dataptr++ += (unsigned)base;
    }
}

unsigned sc_nl_hwtype(void) {
    switch(ut_os_version_index)
    {
        case 0:
        case 1:
        case 6:
        case 7:
        case 10:
        case 11:
        case 14:
        case 15:
            return 0;
        default:
            return 1;
    }
}

// same as ut_os_version_index
unsigned sc_nl_osid(void) {
    return ut_os_version_index;
}

BOOL nl_is_cx2(void) {
    static uint32_t model_id = 0;
    if(model_id == 0)
        model_id = *(volatile uint32_t*)0x900A0000;

    return model_id == 0x202;
}

unsigned sc_nl_hwsubtype(void) {
    if(nl_is_cx2())
        return 2; // 2 if CX II

    unsigned asic_user_flags_model = (*(volatile unsigned*)0x900A002C & 0x7C000000) >> 26;
    return (/* CM */ asic_user_flags_model == 2 || /* CM CAS */ asic_user_flags_model == 3); // 1 if CM
}

BOOL sc_nl_isstartup(void) {
    return plh_isstartup;
}

unsigned sc_nl_ndless_rev(void) {
    return NDLESS_REVISION;
}

void sc_nl_no_scr_redraw(void) {
    plh_noscrredraw = TRUE;
}

int sc_nl_exec(const char *prgm_path, int argsn, char *args[]) {
    return ld_exec_with_args(prgm_path, argsn, args, NULL);
}

typedef void (*lcd_blit_func)(void *buffer);

static void lcd_blit_simple_565(void *buffer)
{
    memcpy(REAL_SCREEN_BASE_ADDRESS, buffer, 320 * 240 * sizeof(uint16_t));
}

static void lcd_blit_simple_8(void *buffer)
{
    memcpy(REAL_SCREEN_BASE_ADDRESS, buffer, 320 * 240 * sizeof(uint8_t));
}

static void lcd_blit_simple_4(void *buffer)
{
    memcpy(REAL_SCREEN_BASE_ADDRESS, buffer, 320 * 240 / 2);
}

static void lcd_blit_320x240_240x320_8(void *buffer)
{
    uint8_t *out = REAL_SCREEN_BASE_ADDRESS, *in = buffer;
    for (int col = 0; col < 240; ++col)
    {
        uint8_t *outcol = out + col;
        for(int row = 0; row < 320; ++row, outcol += 240)
            *outcol = *in++;
    }
}

static void lcd_blit_320x240_240x320_565(void *buffer)
{
    uint16_t *out = REAL_SCREEN_BASE_ADDRESS, *in = buffer;
    for (int col = 0; col < 240; ++col)
    {
        uint16_t *outcol = out + col;
        for(int row = 0; row < 320; ++row, outcol += 240)
            *outcol = *in++;
    }
}

static void lcd_blit_240x320_320x240_565(void *buffer)
{
    uint16_t *out = REAL_SCREEN_BASE_ADDRESS, *in = buffer;
    for (int col = 0; col < 320; ++col)
    {
        uint16_t *outcol = out + col;
        for(int row = 0; row < 240; ++row, outcol += 320)
            *outcol = *in++;
    }
}

lcd_blit_func sc_nl_lcd_blit(scr_type_t buffer_type)
{
    switch(buffer_type)
    {
    case SCR_320x240_4:
        if (is_hww)
            return NULL; // Not implemented on HW-W
        return lcd_blit_simple_4;
    case SCR_320x240_8:
        if (is_hww)
            return lcd_blit_320x240_240x320_8;
        return lcd_blit_simple_8;
    case SCR_320x240_16:
    case SCR_320x240_565:
    case SCR_320x240_555:
        if (is_hww)
            return lcd_blit_320x240_240x320_565;
        return lcd_blit_simple_565;
    case SCR_240x320_565:
    case SCR_240x320_555:
        if (is_hww)
            return lcd_blit_simple_565;
        return lcd_blit_240x320_320x240_565;
    default:
        return NULL;
    }
}

scr_type_t sc_nl_lcd_type()
{
    if (!has_colors)
        return SCR_320x240_4;
    else if(!is_hww)
        return SCR_320x240_565;
    else
        return SCR_240x320_565;
}

static void set_lcd_mode(unsigned int mode)
{
    uint32_t control = *IO_LCD_CONTROL;
    control &= ~0b1110;
    control |= mode << 1;
    *IO_LCD_CONTROL = control;
}

bool sc_nl_lcd_init(scr_type_t type)
{
    static void *old_buffer = NULL;

    // Switch to orginal buffer first to free the allocated space
    if(old_buffer && type != SCR_TYPE_INVALID)
        sc_nl_lcd_init(SCR_TYPE_INVALID);

    switch(type)
    {
    case SCR_TYPE_INVALID:
        if(old_buffer)
        {
            void *new_buffer = REAL_SCREEN_BASE_ADDRESS;
            REAL_SCREEN_BASE_ADDRESS = old_buffer;
            old_buffer = NULL;
            free(new_buffer);
        }
        if(has_colors)
            set_lcd_mode(6);
        else
            set_lcd_mode(2);
        return true;
    case SCR_320x240_4:
        // No need to allocate a new buffer
        set_lcd_mode(2);
        return true;
    case SCR_320x240_8:
    {
        if (!has_colors)
        {
            // Need more space
            old_buffer = REAL_SCREEN_BASE_ADDRESS;
            void *new_buffer = calloc(320*240, sizeof(uint8_t));
            if(!new_buffer)
                return old_buffer = NULL, false;
            REAL_SCREEN_BASE_ADDRESS = new_buffer;
        }

        set_lcd_mode(3);
        return true;
    }
    case SCR_320x240_16:
    case SCR_320x240_565:
    case SCR_240x320_565:
    case SCR_320x240_555:
    case SCR_240x320_555:
    {
        if (!has_colors)
        {
            // Need more space
            old_buffer = REAL_SCREEN_BASE_ADDRESS;
            void *new_buffer = calloc(320*240, sizeof(uint16_t));
            if(!new_buffer)
                return old_buffer = NULL, false;
            REAL_SCREEN_BASE_ADDRESS = new_buffer;

            set_lcd_mode(4);
        }
        else if(type == SCR_320x240_555 || type == SCR_240x320_555)
            set_lcd_mode(4);
        else
            set_lcd_mode(6);

        return true;
    }
    default:
        return false;
    }
}

unsigned const sc_syscall_num = __SYSCALLS_LAST;

bool sc_nl_hassyscall(unsigned syscall_id) {
    return syscall_id <= sc_syscall_num && sc_addrs_ptr[syscall_id];
}

/* Extension syscalls table */
/* Caution, these ones cannot call themselves other syscalls, because of the non-reentrant swi handler */
unsigned sc_ext_table[] = {
    (unsigned)sc_nl_osvalue, (unsigned)sc_ext_relocdatab, (unsigned)sc_nl_hwtype, (unsigned)sc_nl_isstartup,
    (unsigned)luaext_getstate, (unsigned)ld_set_resident, (unsigned)sc_nl_ndless_rev, (unsigned)sc_nl_no_scr_redraw,
    (unsigned)ins_loaded_by_3rd_party_loader, (unsigned)sc_nl_hwsubtype, (unsigned)sc_nl_exec, (unsigned)sc_nl_osid,
    (unsigned)sc_nl_hassyscall, (unsigned)sc_nl_lcd_blit, (unsigned)sc_nl_lcd_type, (unsigned)sc_nl_lcd_init
};

/* On the CX II, touchpad_read/_write have to be wrapped to preserve compatibility:
 * - The return value is inverted (now 0 indicates success)
 * - On more revent HW revisions (around AK), the touchpad model changed and is now
 *   using a different protocol. */

static int (*touchpad_read_real)(unsigned char, unsigned char, char*) = 0;
static int (*touchpad_write_real)(unsigned char, unsigned char, char*) = 0;

static int touchpad_read_compat_synaptics(unsigned char first, unsigned char last, char *buf)
{
    return !touchpad_read_real(first, last, buf);
}

static int touchpad_write_compat_synaptics(unsigned char first, unsigned char last, char *buf)
{
    return !touchpad_write_real(first, last, buf);
}

static int8_t clamp_to_int8(int val)
{
	if(val < SCHAR_MIN)
		return SCHAR_MIN;
	if(val > SCHAR_MAX)
		return SCHAR_MAX;

	return val;
}

static int bswap16(short s)
{
        return ((s & 0xFF) << 8) | ((s & 0xFF00) >> 8);
}

static int touchpad_read_compat_captivate(unsigned char first, unsigned char last, char *buf)
{
    // libndls' touchpad_getinfo, also works for nespire
    if(first == 0x04 && last == 0x07) {
        uint8_t captivate_info[6];
        if(touchpad_read_real(0x07, 0x07+sizeof(captivate_info)-1, (char*)&captivate_info))
            return false;

        buf[0] = captivate_info[3];
        buf[1] = captivate_info[2];
        buf[2] = captivate_info[5];
        buf[3] = captivate_info[4];
        return true;
    }

    // libndls' touchpad_scan (0x0-0xA) and nespire (0x2-0xA)
    if(first <= last && last == 0x0A) {
        uint8_t captivate_report[6];
        if(touchpad_read_real(0x01, 0x01+sizeof(captivate_report)-1, (char*)&captivate_report))
            return false;

        touchpad_report_t libndls_report = {0};
        libndls_report.contact = (bool)(captivate_report[1] & 0b10);
        libndls_report.pressed = (bool)(captivate_report[1] & 0b01);
        libndls_report.proximity = libndls_report.pressed ? 100 : (libndls_report.contact ? 30 : 0);
        libndls_report.x = (captivate_report[2] << 8) | captivate_report[3];
        libndls_report.y = (captivate_report[4] << 8) | captivate_report[5];

        // Calculate relative values
        static touchpad_report_t report_last = {0};
        if(libndls_report.contact && report_last.contact) {
            libndls_report.x_velocity = clamp_to_int8(bswap16(libndls_report.x) - bswap16(report_last.x));
            libndls_report.y_velocity = clamp_to_int8(bswap16(libndls_report.y) - bswap16(report_last.y));
        }
        // The reference is the last time they're read, which is every time this function is called
        report_last = libndls_report;

        memcpy(buf, (char*)(&libndls_report) + first, last-first+1);
        return true;
    }

    return false;
}

static int touchpad_write_compat_captivate(unsigned char first, unsigned char last, char *buf)
{
    // Only page switching is expected
    return first == 0xFF && last == 0xFF && (buf[0] == 0x4 || buf[0] == 0x10);
}

#define FIRST_CXII_OSID 34
typedef uint32_t (*manuf_hwflags_func)(void);
/* OS-specific: Function which returns HW flags (field 5400) */
static uintptr_t manuf_hwflags_ptr[NDLESS_MAX_OSID-FIRST_CXII_OSID+1] = {
    0x100114A8, 0x100114A8, 0x100114A8,
    0x0, 0x0,
    0x100114E8, 0x100114E8, 0x100114E8,
};

static bool has_captivate()
{
    // Bit 0 of field 5400 in the manuf
    return ((manuf_hwflags_func)manuf_hwflags_ptr[ut_os_version_index - FIRST_CXII_OSID])() & 0b1;
}

void sc_install_compat(void) {
    if(nl_is_cx2()) {
        // keypad_type was part of the old manuf driver, which does not exist anymore.
        static int keypad_type_compat = 4;
        sc_addrs_ptr[e_keypad_type] = (uintptr_t)&keypad_type_compat;

        touchpad_read_real = (typeof(touchpad_read_real)) sc_addrs_ptr[e_touchpad_read];
        touchpad_write_real = (typeof(touchpad_write_real)) sc_addrs_ptr[e_touchpad_write];

        if(has_captivate()) {
            sc_addrs_ptr[e_touchpad_read] = (uintptr_t)&touchpad_read_compat_captivate;
            sc_addrs_ptr[e_touchpad_write] = (uintptr_t)&touchpad_write_compat_captivate;
        } else {
            sc_addrs_ptr[e_touchpad_read] = (uintptr_t)&touchpad_read_compat_synaptics;
            sc_addrs_ptr[e_touchpad_write] = (uintptr_t)&touchpad_write_compat_synaptics;
        }
    }
}
