#include <string.h>
#include "emu.h"

static u32 des_block[2];
static u32 des_key[6];
static struct des_ks_entry { u32 odd, even; } des_key_schedule[3][16];
static bool des_key_schedule_valid;

static u32 des_SP[8][64]; // Table of permuted S-box outputs

#define ROL(x, y) ((x) << (y) | (x) >> (32 - (y)))
#define ROR(x, y) ((x) >> (y) | (x) << (32 - (y)))

void des_initialize() {
	static const u32 S[8][8] = {
		{ 0x417df40e,0x18db2fe2,0xbcc66aa3,0x87305995,0x288ec1f4,0x7b12964d,0xe739bc5f,0xd0650aa3 },
		{ 0x7e48d13f,0xe4832bf6,0xad1207c9,0x5ab5906c,0x1ba78ed0,0x214df43a,0xc67c68b5,0x9fe25309 },
		{ 0x9e0970da,0xa56f4336,0xe75c8d21,0x18f2b4cb,0x09d4a61d,0x70839f68,0x3ce2f14b,0xc72e5ab5 },
		{ 0x53be8dd7,0x3a09f660,0xc5287241,0x9fe4ac1b,0x6009f63a,0x8dd71bac,0xbe53419f,0xe42872c5 },
		{ 0xc124bce2,0x16db7a47,0xaff30558,0x698e903d,0x7bc182b4,0xd827ed1a,0x950cf96f,0x3e5043a6 },
		{ 0x2f4af1ac,0x5896c279,0xe4d31d60,0x8b35b70e,0xc52f3e49,0xa3fc5892,0x7a14e0b7,0xd68b0d61 },
		{ 0x7eb20bd4,0xad18904f,0xc7593ce3,0x6186fa25,0x8ddbb461,0x7ea7431c,0xf8065f9a,0xc23925e0 },
		{ 0x84d8f21d,0x417b3fa6,0xbe6359ca,0x279ce005,0x71e41b27,0xd28eac49,0x0d9ac6f0,0xb865533f },
	};
	static const u8 P_inverse[8][4] = {
		{ 24, 16, 10,  2 },
		{ 20,  5, 31, 15 },
		{  9, 17,  3, 27 },
		{  7, 13, 23,  0 },
		{ 25, 19,  8, 30 },
		{ 29,  4, 22, 14 },
		{  1, 21, 11, 26 },
		{ 28,  6, 18, 12 },
	};
	int box, n;
	for (box = 0; box < 8; box++) {
		for (n = 0; n < 64; n++) {
			u32 value = S[box][n >> 3] >> (n << 2 & 31) & 15;
			des_SP[box][n] = (value >> 3 & 1) << P_inverse[box][0]
			               | (value >> 2 & 1) << P_inverse[box][1]
			               | (value >> 1 & 1) << P_inverse[box][2]
			               | (value      & 1) << P_inverse[box][3];
		}
	}
}

static void des_make_key_schedule() {
	/* Permuted choice 1. To simplify the code, the bit order is reversed
	 * (0 = lowest bit) and the parity bits (which are not present in the
	 * key registers of this hardware) are not counted. */
	static const u8 PC_1[56] = {
		24,17,10, 3,53,46,39, // Original: 57 49 41 33 25 17  9
		32,25,18,11, 4,54,47, //            1 58 50 42 34 26 18
		40,33,26,19,12, 5,55, //           10  2 59 51 43 35 27
		48,41,34,27,20,13, 6, //           19 11  3 60 52 44 36

		52,45,38,31,51,44,37, //           63 55 47 39 31 23 15
		30,23,16, 9, 2,50,43, //            7 62 54 46 38 30 22
		36,29,22,15, 8, 1,49, //           14  6 61 53 45 37 29
		42,35,28,21,14, 7, 0, //           21 13  5 28 20 12  4
	};

	/* Permuted choice 2. Again, bit order is reversed */
	static const u8 PC_2[48] = {
		26,15, 8, 1,21,12,    // Original: 14 17 11 24  1  5
		20, 2,24,16, 9, 5,    //            3 28 15  6 21 10
		18, 7,22,13, 0,25,    //           23 19 12  4 26  8
		23,27, 4,17,11,14,    //           16  7 27 20 13  2

		24,27,20, 6,14,10,    //           41 52 31 37 47 55
		 3,22, 0,17, 7,12,    //           30 40 51 45 33 48
		 8,23,11, 5,16,26,    //           44 49 39 56 34 53
		 1,9, 19,25, 4,15,    //           46 42 50 36 29 32
	};

	int keypart;
	int decrypting = des_key[1] >> 30 & 1;
	for (keypart = 0; keypart < 3; keypart++) {
		int bit, round;

		u32 C = 0, D = 0;
		for (bit = 0; bit < 28; bit++) {
			int keybit = PC_1[bit];
			C |= (des_key[keypart << 1 | keybit >> 5] >> (keybit & 31) & 1) << bit;
			keybit = PC_1[28 + bit];
			D |= (des_key[keypart << 1 | keybit >> 5] >> (keybit & 31) & 1) << bit;
		}

		for (round = 0; round < 16; round++) {
			static const u8 rctable[16] = { 1,1,2,2,2,2,2,2,1,2,2,2,2,2,2,1 };
			int rotcount = rctable[round];
			C = (C << rotcount | C >> (28 - rotcount)) & 0x0FFFFFFF;
			D = (D << rotcount | D >> (28 - rotcount)) & 0x0FFFFFFF;

			u32 K_left = 0, K_right = 0;
			for (bit = 0; bit < 24; bit++) {
				K_left  |= (C >> PC_2[     bit] & 1) << bit;
				K_right |= (D >> PC_2[24 + bit] & 1) << bit;
			}

			struct des_ks_entry *p = 
			        &des_key_schedule[decrypting ? 2 - keypart : keypart]
			                         [(decrypting ^ keypart) & 1 ? 15 - round : round];
			p->odd = (K_left  <<  6 & 0x3F000000)
			       | (K_left  << 10 & 0x003F0000)
			       | (K_right >> 10 & 0x00003F00)
			       | (K_right >>  6 & 0x0000003F);
			p->even = (K_left  << 12 & 0x3F000000)
			        | (K_left  << 16 & 0x003F0000)
			        | (K_right >>  4 & 0x00003F00)
			        | (K_right       & 0x0000003F);
		}
	}
	des_key_schedule_valid = true;
}

static void des_process_block(u32 L, u32 R) {
	u32 temp;
	int keypart, round;

	/* Do the (annoying and cryptographically useless) initial permutation.
	 * Also rotate both L and R one bit to the left, which saves a rotation
	 * inside the loop */
	temp = (L >>  4 ^ R) & 0x0F0F0F0F; R ^= temp; L ^= temp <<  4;
	temp = (L >> 16 ^ R) & 0x0000FFFF; R ^= temp; L ^= temp << 16;
	temp = (R >>  2 ^ L) & 0x33333333; L ^= temp; R ^= temp <<  2;
	temp = (R >>  8 ^ L) & 0x00FF00FF; L ^= temp; R ^= temp <<  8;
	R = ROL(R, 1);
	temp = (L       ^ R) & 0xAAAAAAAA; R ^= temp; L ^= temp;
	L = ROL(L, 1);

	if (!des_key_schedule_valid)
		des_make_key_schedule();

	for (keypart = 0; keypart < 3; keypart++) {
		for (round = 0; round < 16; round++) {
			u32 odd  = des_key_schedule[keypart][round].odd  ^ ROR(R, 4);
			u32 even = des_key_schedule[keypart][round].even ^ R;
			L ^= des_SP[1-1][odd >> 24 & 0x3F] ^ des_SP[2-1][even >> 24 & 0x3F]
			   ^ des_SP[3-1][odd >> 16 & 0x3F] ^ des_SP[4-1][even >> 16 & 0x3F]
			   ^ des_SP[5-1][odd >>  8 & 0x3F] ^ des_SP[6-1][even >>  8 & 0x3F]
			   ^ des_SP[7-1][odd       & 0x3F] ^ des_SP[8-1][even       & 0x3F];
			temp = L; L = R; R = temp;
		}
		temp = L; L = R; R = temp;
	}

	/* Reverse the initial permutation */
	L = ROR(L, 1);
	temp = (L       ^ R) & 0xAAAAAAAA; R ^= temp; L ^= temp;
	R = ROR(R, 1);
	temp = (R >>  8 ^ L) & 0x00FF00FF; L ^= temp; R ^= temp <<  8;
	temp = (R >>  2 ^ L) & 0x33333333; L ^= temp; R ^= temp <<  2;
	temp = (L >> 16 ^ R) & 0x0000FFFF; R ^= temp; L ^= temp << 16;
	temp = (L >>  4 ^ R) & 0x0F0F0F0F; R ^= temp; L ^= temp <<  4;

	des_block[0] = R;
	des_block[1] = L;
}

void des_reset(void) {
	memset(des_block, 0, sizeof des_block);
	memset(des_key, 0, sizeof des_key);
	des_key_schedule_valid = false;
}

u32 des_read_word(u32 addr) {
	switch (addr & 0x3FFFFFF) {
		case 0x10000: return des_block[0];
		case 0x10004: return des_block[1];
	}
	return bad_read_word(addr);
}

void des_write_word(u32 addr, u32 value) {
	switch (addr & 0x3FFFFFF) {
		case 0x10000: des_block[0] = value; return;
		case 0x10004: des_process_block(value, des_block[0]); return;
		case 0x10008: case 0x1000C:
		case 0x10010: case 0x10014:
		case 0x10018: case 0x1001C:
			des_key[(addr - 8) >> 2 & 7] = value;
			des_key_schedule_valid = false;
			return;
	}
	bad_write_word(addr, value);
}

#if 0
void *des_save_state(size_t *size) {
	(void)size;
	return NULL;
}

void des_reload_state(void *state) {
	(void)state;
}
#endif
