#include <stdbool.h>
#include <stdint.h>

#include "lcd_compat.h"
#include "ndless.h"

/* This compatibility mode works by unmapping the LCD contoller from 0xC0000000,
 * thus causing a data abort on access. Access to the LCD controller's framebuffer address are emulated.
 * The abort handler also installs a 30 Hz FIQ timer, which blits the framebuffer in the correct way. */

// Location of the pointer used by the OS to implement 240x320 lcd support
static uint32_t lcd_mirror_ptr[NDLESS_MAX_OSID+1] = {0, 0, 0, 0, 0, 0,
                                                     0, 0, 0, 0,
                                                     0, 0, 0, 0,
                                                     0, 0, 0, 0,
                                                     0, 0,
                                                     0, 0,
                                                     0x110ED6D4, 0x111516D4};

static uint32_t *real_lcdc = (uint32_t*) 0xE0000000;
static uint16_t *lcd_mirror = 0x0, *current_lcd_mirror = 0x0;

static uint32_t old_timer_load = 0, old_timer_control = 0,
                old_timer_bgload = 0;

static volatile uint32_t *timer_load = (uint32_t*) 0x900D0000,
                         *timer_control = (uint32_t*) 0x900D0008,
                         *timer_intclear = (uint32_t*) 0x900D000C,
                         *timer_bgload = (uint32_t*) 0x900D0018;

static bool lcd_timer_enabled = false;

bool is_hww;

void lcd_compat_load_hwrev()
{
    is_hww = lcd_mirror_ptr[ut_os_version_index] != 0 && *(uint32_t*)lcd_mirror_ptr[ut_os_version_index] != 0;
}

// Handler for screen conversion
static __attribute__ ((interrupt("FIQ"))) void lcd_compat_fiq()
{
    // Acknowledge interrupt
    *timer_intclear = 1;

    // Convert the framebuffer
    uint16_t *out = (uint16_t*) real_lcdc[4], *in = (uint16_t*) current_lcd_mirror;
    for (int col = 0; col < 240; ++col)
    {
        uint16_t *outcol = out + col;
            for(int row = 0; row < 320; ++row, outcol += 240)
                *outcol = *in++;
    }
}

// Handler for data aborts
asm("lcd_compat_abort_handler:\n"
"sub sp, sp, #8\n" // Somehow the OS uses this...
"push {r0-r12, lr}\n"
"mov r0, sp\n"
"bl lcd_compat_abort\n"
"pop {r0-r12, lr}\n"
"add sp, sp, #8\n"
"subs pc, lr, #4");

static void lcd_timer_enable()
{
    // Save old timer state
    old_timer_load = *timer_load;
    old_timer_control = *timer_control;
    old_timer_bgload = *timer_bgload;

    // Enable timer for conversion
    *timer_control = 0; // Disable first
    *timer_intclear = 1;
    *timer_bgload = 32768 / 30; // 30 Hz
    *timer_control = (1 << 7) | (1 << 6) | (1 << 5) | (1 << 1); // Enable ints, 32-bit load and periodic mode

    // Install FIQ handler
    *(volatile uint32_t*)0x3C = (uint32_t) lcd_compat_fiq;

    // Set second timer interrupt as FIQ
    *(volatile uint32_t*) 0xDC00000C = 1 << 19;

    // Enable FIQs
    asm volatile("msr spsr_c, #0x93");

    lcd_timer_enabled = true;
}

void lcd_compat_abort(uint32_t *regs)
{
    // Get the address that was tried to access
    uintptr_t fault_addr;
    asm volatile("mrc p15, 0, %[fault_addr], c6, c0, 0" : [fault_addr] "=r" (fault_addr));

    // Tried to access LCD controller?
    if(fault_addr >> 28 != 0xC)
        asm volatile("udf #0"); // Crash!

    // Manual memory translation. Map 0xC0000010 to a custom variable,
    // but keep the rest.
    uint32_t *translated_addr = 0;
    if(fault_addr == 0xC0000010)
        translated_addr = (uint32_t*) &current_lcd_mirror;
    else
        translated_addr = (uint32_t*) (fault_addr - 0xC0000000 + (uintptr_t) real_lcdc);

    // Read instruction that caused fault
    uint32_t inst = *(uint32_t*)(regs[13] - 8);

    // Get rd and type (store, load) of instruction
    if((inst & 0xC000000) != 0x4000000) // Not ldr or str?
    {
        /*if(inst == 0xE88C07F8) // Used by gbc4nspire (stmia r12, {r3-r10})
        {
            *translated_addr++ = regs[3];
            *translated_addr++ = regs[4];
            *translated_addr++ = regs[5];
            *translated_addr++ = regs[6];
            *translated_addr++ = regs[7];
            *translated_addr++ = regs[8];
            *translated_addr++ = regs[9];
            *translated_addr++ = regs[10];
        }
        else*/
             asm volatile("bkpt #0"); // For debugging
    }
    else
    {
        if((inst & (1 << 24)) == 0 || (inst & (1 << 21))) // Post-indexed
            asm volatile("bkpt #1");

        if((inst & (1 << 22))) // Byte
            asm volatile("bkpt #1");

        int rd = (inst >> 12) & 0xF;
        if(inst & (1 << 20)) // Load
            regs[rd] = *translated_addr;
        else
            *translated_addr = regs[rd];
    }

    if(!lcd_timer_enabled)
        lcd_timer_enable();
}

bool lcd_compat_enable()
{
    // Only needed on HW-W+
    if(!is_hww)
        return true;

    if(!lcd_mirror)
    {
       lcd_mirror = calloc(sizeof(uint16_t), 320*240);
        if(!lcd_mirror)
            return false;
    }

    current_lcd_mirror = lcd_mirror;

    // Get address of translation table
    uint32_t *tt_base;
    asm volatile("mrc p15, 0, %[tt_base], c2, c0, 0" : [tt_base] "=r" (tt_base));

    // Map LCDC from 0xC0000000 to real_lcdc
    tt_base[(uint32_t) real_lcdc >> 20] = tt_base[0xC00];
    tt_base[0xC00] = 0;

    // Flush TLB for 0xC0000000 and real_lcdc
    asm volatile("mcr p15, 0, %[base], c8, c7, 1" :: [base] "r" (0xC0000000));
    asm volatile("mcr p15, 0, %[base], c8, c7, 1" :: [base] "r" (real_lcdc));

    // Install data abort handler
    void lcd_compat_abort_handler();
    *(volatile uint32_t*)0x30 = (uint32_t) lcd_compat_abort_handler;

    return true;
}

void lcd_compat_disable()
{
    if(!is_hww || !lcd_mirror)
        return;

    uint32_t *tt_base;
    asm volatile("mrc p15, 0, %[tt_base], c2, c0, 0" : [tt_base] "=r" (tt_base));

    // Map real lcdc at 0xC0000000
    tt_base[0xC00] = 0xC0000C12;

    // Flush TLB for 0xC0000000
    asm volatile("mcr p15, 0, %[base], c8, c7, 1" :: [base] "r" (0xC0000000));

    // Reset timers (if used)
    if(lcd_timer_enabled)
    {
        // Set second timer interrupt as IRQ again
        *(volatile uint32_t*) 0xDC00000C &= ~(1 << 19);

        *timer_control = 0;
        *timer_intclear = 1;
        *timer_bgload = old_timer_bgload;
        *timer_control = old_timer_control;
        *timer_load = old_timer_load;

        lcd_timer_enabled = false;
    }
}
