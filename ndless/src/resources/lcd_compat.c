#include <stdbool.h>
#include <stdint.h>

#include "lcd_compat.h"
#include "ndless.h"

/* This compatibility mode works by configuring the LCD controller to use a 320x320 framebuffer and
 * configuring the panel controller to display it as 320x240 on a 240x320 panel. To avoid that an
 * application overwrites the LCD controller timing, the LCD contoller is unmapped from 0xC0000000,
 * thus causing a data abort on access.
 * Additionally, on entry the framebuffer is swapped with a plain 320x240 version with the last frame
 * from the OS. */

// OS-specific: Location of the pointer used by the OS to implement 240x320 lcd support
static uint32_t lcd_mirror_ptr[NDLESS_MAX_OSID+1] = {0, 0, 0, 0, 0, 0,
                                                     0, 0, 0, 0,
                                                     0, 0, 0, 0,
                                                     0, 0, 0, 0,
                                                     0, 0,
                                                     0, 0,
                                                     0x110ED6D4, 0x111516D4,
						     0x110FD6DC, 0x111616DC,
						     0x113356DC, 0x113996DC,
						     0x113496E4, 0x113B16E4,
						     0x1134D6E4, 0x113B16E4,
						     0x1134D6E4, 0x113B16E4,
						     0x0, 0x0, 0x0,
						     0x1134D6E4, 0x113B56E4,
						     0x0, 0x0, 0x0};

static uint32_t *real_lcdc = (uint32_t*) 0xE0000000;
static uint32_t saved_lcd_regs[7];
bool is_hww;

void lcd_compat_load_hwrev()
{
    is_hww = lcd_mirror_ptr[ut_os_version_index] != 0 && *(uint32_t*)lcd_mirror_ptr[ut_os_version_index] != 0;
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

static void undo_lcdc_remap();

void lcd_compat_abort(uint32_t *regs)
{
    // Get the address that was tried to access
    uintptr_t fault_addr;
    asm volatile("mrc p15, 0, %[fault_addr], c6, c0, 0" : [fault_addr] "=r" (fault_addr));

    // Tried to access LCD controller?
    if(fault_addr >> 28 != 0xC)
        asm volatile("udf #0"); // Crash!

    // Manual memory translation: Access real_lcdc if not blacklisted
    uint32_t *translated_addr = (uint32_t*) (fault_addr - 0xC0000000 + (uintptr_t) real_lcdc);

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
        else if(fault_addr > 0xC000000C) // Don't change the LCD timings
            *translated_addr = *reg;
    }

    /* After triggering the abort this many times, program startup is most
     * likely complete, so timing registers are likely not touched again
     * (ignoring the potential restore on exit) so protecting them is no
     * longer necessary. */
    static int lcd_abort_counter = 12;
    if(--lcd_abort_counter == 0)
    {
        lcd_abort_counter = 12;
        undo_lcdc_remap();
    }
}

// OS-specific: Function for transferring data to the LCD controller over SPI
static uint32_t spi_send_ptr[NDLESS_MAX_OSID+1] = {0, 0, 0, 0, 0, 0,
                                                       0, 0, 0, 0,
                                                       0, 0, 0, 0,
                                                       0, 0, 0, 0,
                                                       0, 0,
                                                       0, 0,
                                                       0x100235BC, 0x1002354C,
                                                       0x10023B14, 0x10023AA4,
                                                       0x10023BF0, 0x10023B8C,
                                                       0x10023D08, 0x10023C98,
                                                       0x10023D2C, 0x10023CC8,
                                                       0x10023D2C, 0x10023CF8,
                                                       0x100106F4, 0x100106F4, 0x100106F4,
                                                       0x100241B4, 0x10024188,
                                                       0x10010734, 0x10010734, 0x10010734};

static void spi_send(uint8_t cmd, const uint8_t *data, unsigned int data_count)
{
    // Different method signatures
    if(!nl_is_cx2())
    {
        void (*os_spi_send)(uint16_t, const uint8_t *, int) = (typeof(os_spi_send))spi_send_ptr[ut_os_version_index];
        os_spi_send(cmd, data, data_count);
    }
    else
    {
        void (*os_spi_send)(const uint8_t *) = (typeof(os_spi_send))spi_send_ptr[ut_os_version_index];
        uint8_t transfer[data_count + 4];
        transfer[0] = cmd;
        transfer[1] = data_count;
        memcpy(transfer + 4, data, data_count);
        os_spi_send(transfer);
    }
}

#define SPI_SEND(cmd, ...) do { \
    const uint8_t data[] = {__VA_ARGS__}; \
    spi_send(cmd, data, sizeof(data)); \
} while(0)

bool lcd_compat_enable()
{
    // Only needed on HW-W+
    if(!is_hww && !nl_is_cx2())
        return true;

    const char *dlg[] = {"DLG", NULL};
    int intmask = TCT_Local_Control_Interrupts(-1);
    show_dialog_box2_(0, (const char*) u"Ndless", (const char*) u"Activating compatibility mode.\n"
                                     "This application hasn't been updated\n"
                                     "to work with your hardware.\n"
                                     "You may run into weird issues!", dlg);
    TCT_Local_Control_Interrupts(intmask);
    wait_no_key_pressed();

    static uint16_t *new_framebuffer = NULL;
    if(!new_framebuffer)
    {
        // Try to reuse the OS' internal mirror
        new_framebuffer = lcd_mirror_ptr[ut_os_version_index] == 0 ? NULL : *(uint16_t**)lcd_mirror_ptr[ut_os_version_index];
        if(!new_framebuffer)
            new_framebuffer = calloc(sizeof(uint16_t), 320*240);
        if(!new_framebuffer)
            return false;
    }

    volatile uint32_t *lcdc = (volatile uint32_t*) 0xC0000000;
    for(unsigned int i = 0; i < sizeof(saved_lcd_regs)/sizeof(*saved_lcd_regs); ++i)
        saved_lcd_regs[i] = lcdc[i];

    SPI_SEND(0xB0, 0x91, 0xF0); // Enable RGB bypass mode
    SPI_SEND(0x36, 0x28); // Set MADCTL to XY-Swap + BGR panel
    SPI_SEND(0x2A, 0x00, 0x00, 0x01, 0x3F); // Set column address to (0, 320)
    SPI_SEND(0x2B, 0x00, 0x00, 0x00, 0xEF); // Set page address to (0, 240)

    *(volatile uint32_t*)0xC0000018 &= ~0x800; // Disable the LCD
    // Timing params experimentally determined
    *(volatile uint32_t*)0xC0000000 = 0x1414094C; // Horizontal timing for 320px
    *(volatile uint32_t*)0xC0000004 = 0x0505093F; // Vertical timing for 320px
    *(volatile uint32_t*)0xC0000010 = (uint32_t) new_framebuffer;
    *(volatile uint32_t*)0xC0000018 |= 0x800; // Enable the LCD

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

static void undo_lcdc_remap()
{
    uint32_t *tt_base;
    asm volatile("mrc p15, 0, %[tt_base], c2, c0, 0" : [tt_base] "=r" (tt_base));

    // Map real lcdc at 0xC0000000
    tt_base[0xC00] = 0xC0000C12;

    // Flush TLB for 0xC0000000
    asm volatile("mcr p15, 0, %[base], c8, c7, 1" :: [base] "r" (0xC0000000));
}

void lcd_compat_disable()
{
    if(!is_hww && !nl_is_cx2())
        return;

    // Undo the changes again
    SPI_SEND(0xB0, 0x11, 0xF0);
    SPI_SEND(0x36, nl_is_cx2() ? 0x48 : 0x08);
    SPI_SEND(0x2A, 0x00, 0x00, 0x00, 0xEF);
    SPI_SEND(0x2B, 0x00, 0x00, 0x01, 0x3F);

    undo_lcdc_remap();

    // Restore the LCD params
    volatile uint32_t *lcdc = (volatile uint32_t*) 0xC0000000;
    lcdc[6] &= ~0x800; // Disable the LCD, the restoration below will reenable it
    for(unsigned int i = 0; i < sizeof(saved_lcd_regs)/sizeof(*saved_lcd_regs); ++i)
        lcdc[i] = saved_lcd_regs[i];
}
