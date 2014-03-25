#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include "emu.h"

/* Emulation of the TI-84 Plus I/O link port */

union packet {
	u8 raw[4 + 65535 + 2];
	struct {
		u8 machine_ID;
		u8 command_ID;
		u16 data_length;
		u8 data[65535 + 2]; /* plus checksum if not zero length */
	};
};

static u16 checksum(union packet *p) {
	u16 i, checksum = 0;
	for (i = 0; i < p->data_length; i++)
		checksum += p->data[i];
	return checksum;
}

/* Current packet being sent/received to/from calculator */
union packet packet_buf;
int packet_size;
int packet_pos;
int packet_bit;

bool sending = false;
bool start_send = false;

static void send_packet() {
	if (packet_buf.data_length != 0) /* Append a checksum */
		*(u16 *)&packet_buf.data[packet_buf.data_length] = checksum(&packet_buf);

	/* We can't start sending immediately, because we may have just finished
	 * receiving the last bit of a packet, and the calc wants to see that we
	 * released our acknowledgement pulldown.
	 * Set a flag and start sending next time the calc checks the port. */
	start_send = true;
}

/* Function to call when a complete packet has been sent or received */
void (*packet_callback)();

/* Code for sending variable files (.8XP and such) to the calculator */
FILE *var_file;
int state;
int bytes_remaining;

static void send_variable_callback() {
	printf("Sending variable: part %d of 7\n", state);
	switch (state++) {
		case 0: /* Send RTS */
			packet_buf.machine_ID = 0x23; /* computer sending to TI-83+ or TI-84+ */
			packet_buf.command_ID = 0xC9;
			/* Variable name */
			if (!fread(&packet_buf.data_length, 2, 1, var_file))
				goto read_error;
			if (!fread(&packet_buf.data, packet_buf.data_length, 1, var_file))
				goto read_error;
			bytes_remaining -= (2 + packet_buf.data_length);
			send_packet();
			return;
		case 1: /* RTS sent; receive ACK */
			return;
		case 2: /* ACK received; receive CTS */
			if (packet_buf.command_ID != 0x56) break;
			return;
		case 3: /* CTS received; send ACK */
			if (packet_buf.command_ID != 0x09) break;
			packet_buf.machine_ID = 0x23;
			packet_buf.command_ID = 0x56;
			packet_buf.data_length = 0;
			send_packet();
			return;
		case 4: /* ACK sent; send DATA */
			packet_buf.machine_ID = 0x23;
			packet_buf.command_ID = 0x15;
			/* Variable contents */
			if (!fread(&packet_buf.data_length, 2, 1, var_file))
				goto read_error;
			if (!fread(&packet_buf.data, packet_buf.data_length, 1, var_file))
				goto read_error;
			bytes_remaining -= (2 + packet_buf.data_length);
			send_packet();
			return;
		case 5: /* DATA sent; receive ACK */
			return;
		case 6: /* ACK received; send EOT */
			if (packet_buf.command_ID != 0x56) break;
			packet_buf.machine_ID = 0x23;
			packet_buf.command_ID = 0x92;
			packet_buf.data_length = 0;
			send_packet();
			printf("%d bytes left in file\n", bytes_remaining);
			if (bytes_remaining > 0) /* more variables in file */
				state = 0;
			return;
		case 7: /* EOT sent */
			printf("Variable transfer complete.\n");
			goto cleanup;
	}
	printf("Unexpectedly got command %02X\n", packet_buf.command_ID);
	goto cleanup;
read_error:
	printf("Error reading variable file\n");
cleanup:
	fclose(var_file);
	var_file = NULL;
	packet_callback = NULL;
	return;
}

#define APP_PACKET_SIZE 128
int app_page;
int app_offset;
int app_buffer_pos;
u8 app_buffer[(APP_PACKET_SIZE - 1) + 255];
u16 app_packet_size;

static void send_app_callback() {
	more:
	//printf("send_app_callback() state=%d pos=%d\n", state, app_buffer_pos);
	switch (state++) {
		case 0:
		new_page:
			*(u16 *)&packet_buf.data[6] = app_offset;
			*(u16 *)&packet_buf.data[8] = app_page;

			while (app_buffer_pos < APP_PACKET_SIZE) {
				/* Read a record from the file */
				struct {
					unsigned char reclen;
					unsigned char offset[2];
					unsigned char rectyp;
					unsigned char data[255+1]; // + checksum
				} record;
				u8 checksum = 0;
				int pos, i, c;
				do {
					c = fgetc(var_file);
					bytes_remaining--;
				} while (isspace(c));
				if (c != ':')
					goto error;
				for (pos = 0; pos < record.reclen + 5; pos++) {
					int byte = 0;
					for (i = 0; i < 2; i++) {
						c = fgetc(var_file);
						bytes_remaining--;
						if (c >= '0' && c <= '9')
							c -= '0';
						else if (c >= 'A' && c <= 'F')
							c -= 'A' - 10;
						else
							goto error;
						byte = byte << 4 | c;
					}
					((u8 *)&record)[pos] = byte;
					checksum += byte;
				}
				if (checksum != 0)
					goto error;

				int offset = record.offset[0] << 8 | record.offset[1];
				if (record.rectyp == 2 && record.reclen == 2) {
					/* Start of a new page */
					app_page = record.data[0] << 8 | record.data[1];
					app_offset = 0x4000;
					if (app_buffer_pos != 0)
						break;
					goto new_page;
				} else if (record.rectyp == 0 && offset == (app_offset + app_buffer_pos)) {
					/* Page contents */
					memcpy(&app_buffer[app_buffer_pos], record.data, record.reclen);
					app_buffer_pos += record.reclen;
				} else if (record.rectyp == 1 && record.reclen == 0) {
					/* End-of-file record */
					bytes_remaining = 0;
					if (app_buffer_pos == 0)
						goto send_EOT;
					break;
				} else {
					goto error;
				}
			}
			app_packet_size = app_buffer_pos;
			if (app_packet_size > APP_PACKET_SIZE)
				app_packet_size = APP_PACKET_SIZE;

			/* Send VAR */
			packet_buf.machine_ID = 0x23;
			packet_buf.command_ID = 0x06;
			packet_buf.data_length = 0x0A;
			*(u16 *)&packet_buf.data[0] = app_packet_size;
			memcpy(&packet_buf.data[2], "\x24\x00\x00\x04", 4);
			/* Offset and page number set above */
			send_packet();
			return;
		case 1: /* VAR sent, receive ACK */
			return;
		case 2: /* ACK received, receive CTS */
			if (packet_buf.command_ID != 0x56) break;
			return;
		case 3: /* CTS received, send ACK */
			if (packet_buf.command_ID != 0x09) break;
			packet_buf.machine_ID = 0x23;
			packet_buf.command_ID = 0x56;
			packet_buf.data_length = 0;
			send_packet();
			return;
		case 4: /* ACK sent, send DATA */
			packet_buf.machine_ID = 0x23;
			packet_buf.command_ID = 0x15;
			packet_buf.data_length = app_packet_size;
			memcpy(packet_buf.data, app_buffer, app_packet_size);
			app_buffer_pos -= app_packet_size;
			app_offset += app_packet_size;
			memmove(&app_buffer[0], &app_buffer[packet_buf.data_length], app_buffer_pos);
			send_packet();
			printf("%d bytes left in file\n", bytes_remaining);
			return;
		case 5: /* DATA sent, receive ACK */
			return;
		case 6: /* ACK received */
			if (packet_buf.command_ID != 0x56) break;
			if (bytes_remaining != 0) {
				state = 0;
				goto more;
			}
		send_EOT:
			packet_buf.machine_ID = 0x23;
			packet_buf.command_ID = 0x92;
			packet_buf.data_length = 0;
			send_packet();
			state = 7;
			return;
		case 7: /* EOT sent */
			printf("App transfer complete\n");
			goto cleanup;
	}
	printf("Unexpectedly got command %02X\n", packet_buf.command_ID);
	goto cleanup;
error:
	printf("Error reading app file\n");
cleanup:
	fclose(var_file);
	var_file = NULL;
	packet_callback = NULL;
	return;
}

void send_file(char *filename) {
	FILE *f = fopen(filename, "rb");
	if (!f) {
		perror(filename);
		return;
	}

	char sig[8];
	if (!fread(sig, 8, 1, f)) {
bad_format:
		printf("Not a valid variable file.\n");
		fclose(f);
		return;
	}

	if (memcmp(sig, "**TI82**", 8) == 0 ||
	    memcmp(sig, "**TI83**", 8) == 0 ||
	    memcmp(sig, "**TI83F*", 8) == 0)
	{
#pragma pack(1)
		struct {
			char sig2[3];
			char comment[42];
			u16 data_size;
		} varheader;
#pragma pack(0)
		if (!fread(&varheader, sizeof varheader, 1, f))
			goto bad_format;
		if (strcmp(varheader.sig2, "\x1A\x0A"))
			goto bad_format;

		bytes_remaining = varheader.data_size;
		packet_callback = send_variable_callback;
	} else if (memcmp(sig, "**TIFL**", 8) == 0) {
#pragma pack(1)
		struct {
			char unknown[9];
			char name[31];
			char unknown2[26];
			u32 data_size;
		} appheader;
#pragma pack(0)
		if (!fread(&appheader, sizeof appheader, 1, f))
			goto bad_format;

		bytes_remaining = appheader.data_size;
		app_buffer_pos = 0;
		packet_callback = send_app_callback;
	} else {
		goto bad_format;
	}

	if (var_file)
		fclose(var_file);
	var_file = f;
	state = 0;
	packet_callback();
}

/* Advance to next bit in packet being read/written */
static void next_bit() {
	packet_bit = (packet_bit + 1) & 7;
	if (packet_bit == 0) {
		packet_pos++;
		if (packet_pos >= 4) {
			if (packet_pos == 4) {
				/* Check packet header to determine size. Packets from the TI-84+
				 * don't always have the data length field set correctly for
				 * command types which don't contain any data. */
				switch (packet_buf.command_ID) {
					case 0x09: case 0x2D: case 0x56: case 0x5A: case 0x68: case 0x6D: case 0x92:
						packet_size = 4;
						break;
					case 0x06: case 0x15: case 0x36: case 0x88: case 0xA2: case 0xC9:
						packet_size = 4 + packet_buf.data_length + 2;
						break;
				}
			}
			if (packet_pos == packet_size) {
#if 0
				printf("Packet %s calc\n", sending ? "sent to" : "received from");
				int i;
				for (i = 0; i < packet_pos; i++)
					printf("%02X ", packet_buf.raw[i]);
				printf("\n");
#endif
				sending = false;
				packet_pos = 0;
				if (packet_callback)
					packet_callback();
			}
		}
	}
}

u8 link_input;  /* Lines not pulled down by emulator. */
u8 link_output; /* Lines not pulled down by calculator. */

void ti84_io_link_reset() {
	sending = false;
	start_send = false;
	if (var_file)
		fclose(var_file);
	var_file = NULL;

	link_input = 3;
	link_output = 3;
}
u32 ti84_io_link_read(u32 addr) {
	//printf("read %08x (in=%d out=%d)\n", addr, link_input, link_output);
	switch (addr & 0xFFFF) {
		case 0x00: {
			u8 ret = link_input & link_output;
			if (start_send) {
				/* Start sending with first bit */
				sending = true;
				packet_pos = 0;
				packet_bit = 0;
				link_input = (packet_buf.raw[0] & 1) ? 1 : 2;
				start_send = false;
			}
			return ret;
		}
		case 0x04:
			return 0;
	}
	return bad_read_word(addr);
}
void ti84_io_link_write(u32 addr, u32 value) {
	switch (addr & 0xFFFF) {
		case 0x00:
			if (value > 3)
				error("Link output %08x not in range 0-3", value);
			/* Bit is set bit to leave line high, reset for pulldown
			 * (NB: logic is opposite of TI-84+'s port 00) */
			link_output = value;

			if (sending) {
				if (link_input != 3) {
					/* We are pulling a line and waiting for acknowledgement */
					if (!(link_input & link_output)) {
						/* Got acknowledgement. Release line, wait for calc to release ack */
						link_input = 3;
					}
				} else {
					if (link_output == 3) {
						/* Acknowledgement released; this bit is done */
						next_bit();
						/* Still more data? Load the next bit */
						if (sending)
							link_input = (packet_buf.raw[packet_pos] >> packet_bit & 1) ? 1 : 2;
					}
				}
			} else {
				if (link_input == 3) {
					/* We are waiting for a bit */
					if (link_output == 0) {
						printf("Send cancelled\n");
						packet_pos = 0;
					} else if (link_output == 1 || link_output == 2) {
						/* Calc has pulled a line down. Pull down the other line to acknowledge */
						link_input = link_output ^ 3;
						/* Store the bit */
						packet_buf.raw[packet_pos] = packet_buf.raw[packet_pos] >> 1 | link_output << 7;
					}
				} else {
					/* We are acknowledging */
					if (link_output & link_input) {
						/* Calc released sent bit; release our acknowledgement */
						link_input = 3;
						next_bit();
					}
				}
			}
			return;
		case 0x04:
			return;
	}
	bad_write_word(addr, value);
}

#if 0
void *link_save_state(size_t *size) {
	(void)size;
	return NULL;
}

void link_reload_state(void *state) {
	(void)state;
}
#endif
