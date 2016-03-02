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

// Using the watchdog here as the second timer is used by gbc4nspire
// and the first one does not emit interrupts...
static volatile uint32_t *watchdog_load = (uint32_t*) 0x90060000,
                         *watchdog_control = (uint32_t*) 0x90060008,
                         *watchdog_intclear = (uint32_t*) 0x9006000C,
                         *watchdog_lock = (uint32_t*) 0x90060C00;

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
    *watchdog_lock = 0x1ACCE551;
    *watchdog_intclear = 1;

    // Convert the framebuffer
    uint16_t *out = (uint16_t*) real_lcdc[4], *in = (uint16_t*) current_lcd_mirror;
    for (int col = 0; col < 240; ++col)
    {
        uint16_t *outcol = out + col;
            for(int row = 0; row < 320; ++row, outcol += 240)
                *outcol = *in++;
    }
}

// sp and lr are special, they are banked and thus not easily accessible.
extern uint32_t sp_svc, lr_svc;

/* Handler for data aborts:
 * After storing all registers (r0-r12 + lr) on the stack
 * and storing the values of the banked registers sp_svc and lr_svc
 * in the globals, call lcd_compat_abort with the register array as first arg.
 * Restore sp_svc and lr_svc and jump back to the aborting instruction. */
asm(
"sp_svc: .word 0\n"
"lr_svc: .word 0\n"
"lcd_compat_abort_handler:\n"
"sub sp, sp, #8\n" // Somehow the OS uses this...
    "push {r0-r12, lr}\n"
        "mrs r0, spsr\n"
        "orr r0, r0, #0xc0\n"
        "msr cpsr_c, r0\n" // To SVC mode
            "str sp, sp_svc\n" // Save sp_svc
            "str lr, lr_svc\n" // Save lr_svc
        "msr cpsr_c, #0xd7\n" // Back to ABT mode
        "mov r0, sp\n" // First arg, array of r0-12, lr
        "bl lcd_compat_abort\n"
        "mrs r0, spsr\n"
        "orr r0, r0, #0xc0\n"
        "msr cpsr_c, r0\n" // To SVC mode
            "ldr sp, sp_svc\n" // Restore sp_svc
            "ldr lr, lr_svc\n" // Restore lr_svc
        "msr cpsr_c, #0xd7\n" // Back to ABT mode
    "pop {r0-r12, lr}\n"
"add sp, sp, #8\n"
"subs pc, lr, #4");

static void lcd_timer_enable()
{
    // Enable timer for conversion
    *watchdog_lock = 0x1ACCE551;
    *watchdog_load = 33000000 / 15; // 15 Hz
    *watchdog_control = 1;

    // Install FIQ handler
    *(volatile uint32_t*)0x3C = (uint32_t) lcd_compat_fiq;

    // Set first watchdog interrupt as FIQ
    *(volatile uint32_t*) 0xDC00000C = 1 << 3;
    // Activate watchdog IRQ
    *(volatile uint32_t*) 0xDC000010 = 1 << 3;

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
        if(inst == 0xE88C07F8) // Used by gbc4nspire (stmia r12, {r3-r10})
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
        else
             asm volatile("bkpt #0"); // For debugging
    }
    else
    {
        if((inst & (1 << 24)) == 0 || (inst & (1 << 21))) // Post-indexed
            asm volatile("bkpt #1");

        if((inst & (1 << 22))) // Byte
            asm volatile("bkpt #2");

        int rd = (inst >> 12) & 0xF;
	uint32_t *reg = 0;
        if(rd <= 12) // Not a banked register?
            reg = regs + rd;
        else if(rd == 13)
            reg = &sp_svc;
        else if(rd == 14)
            reg = &lr_svc;
        else // PC?
            asm volatile("bkpt #3");

        if(inst & (1 << 20)) // Load
            *reg = *translated_addr;
        else
            *translated_addr = *reg;
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
        // Set watchdog interrupt as IRQ again
        *(volatile uint32_t*) 0xDC00000C &= ~(1 << 3);
        // Deactivate watchdog IRQ
        *(volatile uint32_t*) 0xDC000014 = 1 << 3;

        *watchdog_lock = 0x1ACCE551;
        *watchdog_control = 0;

        lcd_timer_enabled = false;
    }
}
