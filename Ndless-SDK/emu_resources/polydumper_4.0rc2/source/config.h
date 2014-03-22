#undef NDLESS11
#undef NDLESS12
#undef NDLESSPROTO

#undef NDLESS17
#undef NDLESS20

#define NDLESS31


#ifdef NDLESS11
	#undef TOUCHPAD_SUPPORT
	#undef ANYKEY_SUPPORT
	#define SLEEP_SUPPORT
	#ifdef NDLESSPROTO
		#define HAS_NAND
	#else
		#undef HAS_NAND
	#endif
	#undef HAS_NO_NAND
#endif

#ifdef NDLESS12
	#undef TOUCHPAD_SUPPORT
	#undef ANYKEY_SUPPORT
	#define SLEEP_SUPPORT
	#define HAS_NAND
	#undef HAS_NO_NAND
#endif

#ifdef NDLESS17
	#undef TOUCHPAD_SUPPORT
	#undef ANYKEY_SUPPORT
	#undef SLEEP_SUPPORT
	#undef HAS_NAND
	#undef HAS_NO_NAND
#endif

#ifdef NDLESS20
	#define TOUCHPAD_SUPPORT
	#define ANYKEY_SUPPORT
	#define SLEEP_SUPPORT
	#undef HAS_NAND
	#undef HAS_NO_NAND
#endif

#ifdef NDLESS31
	#define TOUCHPAD_SUPPORT
	#define ANYKEY_SUPPORT
	#define SLEEP_SUPPORT
	#undef HAS_NAND
	#undef HAS_NO_NAND
#endif