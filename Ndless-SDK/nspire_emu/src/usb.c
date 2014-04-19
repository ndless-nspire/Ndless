#include <stdio.h>
#include <string.h>
#include "emu.h"

extern void usblink_receive(int ep, u8 *buf, u32 size);
extern void usblink_complete_send(int ep);

struct usb_state usb;

struct usb_qh { // Queue head
	u32 flags;
	u32 current_td;
	struct usb_td { // Transfer descriptor
		u32 next_td;
		u32 flags;
		u32 bufptr[5];
	} overlay;
	u32 reserved;
	struct usb_setup {
		u8 bmRequestType;
		u8 bRequest;
		u16 wValue;
		u16 wIndex;
		u16 wLength;
	} setup;
};

static void usb_int_check() {
	int_set(INT_USB, (usb.usbsts & usb.usbintr) | ((usb.otgsc >> 24) & (usb.otgsc >> 16)));
}

void usb_reset() {
	memset(&usb, 0, sizeof usb);
	usb.usbcmd = 0x80000;
	usb.portsc = 0xEC000004;
	usb.otgsc = 0x0F20; // 1120 if nothing plugged in
	usb_int_check();
}

void usb_bus_reset_on() {
	usb.portsc &= ~1;
	usb.portsc |= 0x0C000100;
	usb.deviceaddr = 0;
	usb.usbsts |= 0x40;
	usb.epsr = 0;
	usb_int_check();
}

void usb_bus_reset_off() {
	usb.portsc &= ~0x0C000100;
	usb.portsc |= 1;
	usb.usbsts |= 4;
	usb_int_check();
}

static void usb_prime(struct usb_qh *qh, u32 epbit) {
	u32 tda = qh->overlay.next_td;
	if (tda & 0x1F)
		error("USB: TD not 32-byte aligned");
	struct usb_td *td = phys_mem_ptr(tda, 0x1C);
	if (!td)
		error("USB: bad TD");

	qh->current_td = tda;
	memcpy(&qh->overlay, td, 0x1C);
	usb.epsr |= epbit;
}

static void usb_complete(struct usb_qh *qh, u32 epbit, u32 size) {
	u32 tda = qh->current_td;
	if (tda & 0x1F)
		error("USB: TD not 32-byte aligned");
	struct usb_td *td = phys_mem_ptr(tda, 0x1C);
	if (!td)
		error("USB: bad TD");

	td->flags -= size << 16;
	td->flags &= ~0xFF; // clear status bits
	usb.epsr &= ~epbit;
	usb.epcomplete |= epbit;
	if (qh->overlay.flags & 0x8000) { // IOC (interrupt on complete)
		usb.usbsts |= 1;
		usb_int_check();
	}
}

void usb_receive_setup_packet(int endpoint, const void *packet) {
	struct usb_qh *qh = phys_mem_ptr(usb.eplistaddr + (endpoint * 0x80), 0x30);
	if (!qh)
		error("USB: bad QH");
	memcpy(&qh->setup, packet, 8);
	//printf("Receive setup packet\n");
	usb.epsetupsr |= 1 << endpoint;
	if (qh->flags & 0x8000) { // IOS (interrupt on setup)
		usb.usbsts |= 1;
		usb_int_check();
	}
}

void usb_receive_packet(int endpoint, const void *packet, u32 size) {
	if (!(usb.epsr & (1 << endpoint))) {
		printf("USB: can't receive packet, endpoint not primed\n");
		return;
	}
	struct usb_qh *qh = phys_mem_ptr(usb.eplistaddr + (endpoint * 0x80), 0x30);
	if (!qh)
		error("USB: bad QH");
	u32 maxsize = qh->overlay.flags >> 16 & 0x7FFF;
	//printf("USB: receiving %d, max %d\n", size, maxsize);
	if (size > maxsize) {
		printf("USB: too big\n");
		return;
	}
	if (size) {
		// assumes contiguous buffer
		void *buf = phys_mem_ptr(qh->overlay.bufptr[0], size);
		if (!buf)
			error("USB: bad buffer");
		memcpy(buf, packet, size);
	}
	usb_complete(qh, 1 << endpoint, size);
}

/* B0000000 (and B4000000?): USB */
u8 usb_read_byte(u32 addr) {
	//printf("[usb readb %08x]\n", addr);
	if ((addr & 0x1FF) == 0x100) return 0x40; // CAPLENGTH: operational registers start at +40
	return bad_read_byte(addr);
}
u16 usb_read_half(u32 addr) {
	//printf("[usb readh %08x]\n", addr);
	if ((addr & 0x1FF) == 0x102) return 0x0100; // HCIVERSION: EHCI 1.0
	return bad_read_half(addr);
}
u32 usb_read_word(u32 addr) {
	//printf("[usb read  %08x]\n", addr);
	switch (addr & 0x1FF) {
		/* Module identification registers */
		case 0x000: return 0x0042FA05; // ID: revision 0x42, ID 5
		case 0x004: return 0x000002C5; // HWGENERAL
		case 0x008: return 0x10020001; // HWHOST
		case 0x00C: return 0x00000009; // HWDEVICE
		case 0x010: return 0x80050708; // HWTXBUF
		case 0x014: return 0x00000508; // HWRXBUF

		/* Capability registers */
		case 0x100: return 0x01000040; // CAPLENGTH and HCIVERSION
		case 0x104: return 0x00010011; // HCSPARAMS: Port indicator control, port power control, 1 port
		case 0x108: return 0x00000006; // HCCPARAMS: Asynchronous schedule park, programmable frame list
		case 0x10C: return 0x00000000; // HCSP-PORTROUTE

		case 0x120: return 0x00000001; // DCIVERSION: 0.1
		case 0x124: return 0x00000184; // DCCPARAMS: Host capable, device capable, 4 endpoints

		/* Operational registers */
		case 0x140: return usb.usbcmd;
		case 0x144: return usb.usbsts;
		case 0x148: return usb.usbintr;
		case 0x154: return usb.deviceaddr;
		case 0x158: return usb.eplistaddr;
		case 0x184: return usb.portsc;
		case 0x1A4: return usb.otgsc;
		case 0x1A8: if (!emulate_cx) break; return 0; //fixme
		case 0x1AC: return usb.epsetupsr;
		case 0x1B0: return 0; // EPPRIME
		case 0x1B4: return 0; // EPFLUSH
		case 0x1B8: return usb.epsr;
		case 0x1BC: return usb.epcomplete;
		case 0x1C0: return 0x800080; // EPCR0
		case 0x1C4: return 0; // EPCR1
		case 0x1C8: return 0; // EPCR2
		case 0x1CC: return 0; // EPCR3
	}
	return bad_read_word(addr);
}
void usb_write_word(u32 addr, u32 value) {
	//printf("[usb write %08x %08x]\n", addr, value);
	switch (addr & 0x1FF) {
		/* Device/host timer registers */
		case 0x080: return; // used by diags
		case 0x084: return; // used by diags

		/* Operational registers */
		case 0x140: // USBCMD
			if (value & 2) {
				//printf("usb reset\n");
				usb_reset();
				return;
			}
			usb.usbcmd = value;
			return;
		case 0x144: // USBSTS
			usb.usbsts &= ~value;
			usb_int_check();
			return;
		case 0x148: // USBINTR
			usb.usbintr = value & 0x030101D7;
			usb_int_check();
			return;
		case 0x154: // DEVICEADDR
			usb.deviceaddr = value & 0xFE000000;
			return;
		case 0x158: // EPLISTADDR
			usb.eplistaddr = value & 0xFFFFF800;
			return;
		case 0x184: // PORTSC
			return;
		case 0x1A4: // OTGSC
			usb.otgsc = (usb.otgsc & ~0x7F00003B) | (value & 0x7F00003B);
			usb.otgsc &= ~(value & 0x007F0000);
			usb_int_check();
			return;
		case 0x1A8: // USBMODE
			return;
		case 0x1AC: // EPSETUPSR
			usb.epsetupsr &= ~value;
			return;
		case 0x1B0: { // EPPRIME
			int ep;
			for (ep = 0; ep < 4; ep++) {
				if (value & (1 << ep)) {
					//printf("Priming endpoint %d for receive\n", ep);
					struct usb_qh *qh = phys_mem_ptr(usb.eplistaddr + (ep * 0x80), 0x30);
					if (!qh)
						error("USB: bad QH");
					usb_prime(qh, 1 << ep);

					usblink_complete_send(ep);
				}
				if (value & (0x10000 << ep)) {
					//printf("Priming endpoint %d for transmit\n", ep);
					struct usb_qh *qh = phys_mem_ptr(usb.eplistaddr + (ep * 0x80) + 0x40, 0x30);
					if (!qh)
						error("USB: bad QH");
					usb_prime(qh, 0x10000 << ep);

					u32 size = qh->overlay.flags >> 16 & 0x7FFF;
					u8 *buf = phys_mem_ptr(qh->overlay.bufptr[0], size);
					usblink_receive(ep, buf, size);

					usb_complete(qh, 0x10000 << ep, size);
				}
			}
			return;
		}
		case 0x1B4: // EPFLUSH
			usb.epsr &= ~value;
			// anything else that needs to be done? :/
			return;
		case 0x1BC: // EPCOMPLETE
			usb.epcomplete &= ~value;
			return;
		case 0x1C0: // EPCR0
		case 0x1C4: // EPCR1
		case 0x1C8: // EPCR2
		case 0x1CC: // EPCR3
			return;
	}
	bad_write_word(addr, value);
}
