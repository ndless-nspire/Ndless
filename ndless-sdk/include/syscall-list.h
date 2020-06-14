/****************************************************************************
 * Ndless - Syscalls enumeration
 ****************************************************************************/

#ifndef _SYSCALLS_H_
#define _SYSCALLS_H_

/* OS syscalls.
 * The syscall's name must be prefixed with e_.
 * NEVER change the value of these constants for backward compatibility.
 * Append new syscalls at the end of the list, and increment the enumeration.
 * Don't try to sort the symbols.
 * If a syscall becomes deprecated and is deleted from the list, its value
 * cannot be reused.
 */

// START_OF_LIST (always keep this line before the fist constant, used by mksyscalls.sh)
#define e_fopen 0 // NUC_FILE* nuc_fopen(const char *p1, const char *p2)
#define e_fread 1 // size_t nuc_fread(void *p1, size_t p2, size_t p3, NUC_FILE *p4)
#define e_fwrite 2 // size_t nuc_fwrite(void *p1, size_t p2, size_t p3, NUC_FILE *p4)
#define e_fclose 3 // int nuc_fclose(NUC_FILE *p1)
#define e_fgets 4 // char* nuc_fgets(char *p1, int p2, NUC_FILE *p3)
#define e_malloc 5
#define e_free 6
#define e_memset 7
#define e_memcpy 8
#define e_memcmp 9
#define e_printf 10
#define e_sprintf 11
#define e_fprintf 12
#define e_ascii2utf16 13 // void ascii2utf16(void *p1, const char *p2, int p3)
#define e_TCT_Local_Control_Interrupts 14 // int TCT_Local_Control_Interrupts(int p1)
#define e_mkdir 15
#define e_rmdir 16
#define e_chdir 17
#define e_stat 18 // int nuc_stat(const char *p1, struct nuc_stat *p2)
#define e_unlink 19
#define e_rename 20
#define e_TCC_Terminate_Task 21 // int TCC_Terminate_Task(NU_TASK *p1)
#define e_puts 22 // int nuc_puts(const char *p1)
#define e_NU_Get_First 23 // int NU_Get_First(struct dstat *p1, const char *p2)
#define e_NU_Get_Next 24 // int NU_Get_Next(struct dstat *p1)
#define e_NU_Done 25 // void NU_Done(struct dstat *p1)
#define e_strcmp 26
#define e_strcpy 27
#define e_strncat 28
#define e_strlen 29
#define e_show_dialog_box2_ 30 // void show_dialog_box2_(int p1, const char *p2, const char *p3, const char **p4)
#define e_strrchr 31
#define e__vsprintf 32
#define e_fseek 33 // int nuc_fseek(NUC_FILE *p1, long p2, int p3)
#define e_NU_Current_Dir 34 // int NU_Current_Dir(const char *p1, const char *p2)
#define e_read_unaligned_longword 35
#define e_read_unaligned_word 36
#define e_strncpy 37
#define e_isalpha 38
#define e_isascii 39
#define e_isdigit 40
#define e_islower 41
#define e_isprint 42
#define e_isspace 43
#define e_isupper 44
#define e_isxdigit 45
#define e_tolower 46
#define e_atoi 47
#define e_atof 48
#define e_calloc 49
#define e_realloc 50
#define e_strpbrk 51
#define e_fgetc 52
#define e_NU_Set_Current_Dir 53 // int NU_Set_Current_Dir(const char *p1)
#define e_fputc 54
#define e_memmove 55
#define e_memrev 56
#define e_strchr 57
#define e_strncmp 58
#define e_keypad_type 59
#define e_freopen 60
#define e_errno_addr 61
#define e_toupper 62
#define e_strtod 63
#define e_strtol 64
#define e_ungetc 65
#define e_strerror 66
#define e_strcat 67
#define e_strstr 68
#define e_fflush 69
#define e_remove 70
#define e_stdin 71
#define e_stdout 72
#define e_stderr 73
#define e_ferror 74
#define e_touchpad_read 75 // int touchpad_read(unsigned char p1, unsigned char p2, void *p3)
#define e_touchpad_write 76 // int touchpad_write(unsigned char p1, unsigned char p2, void *p3)
#define e_adler32 77
#define e_crc32 78
#define e_crc32_combine 79
#define e_zlibVersion 80
#define e_zlibCompileFlags 81
#define e_deflateInit2_ 82
#define e_deflate 83
#define e_deflateEnd 84
#define e_inflateInit2_ 85
#define e_inflate 86
#define e_inflateEnd 87
#define e_TCC_Current_Task_Pointer 88 // NU_TASK* TCC_Current_Task_Pointer()
#define e_ftell 89 // long nuc_ftell(NUC_FILE *p1)
#define e_NU_Open 90 // PCFD NU_Open(char *p1, uint32_t p2, uint32_t p3)
#define e_NU_Close 91 // int NU_Close(PCFD p1)
#define e_NU_Truncate 92 // int NU_Truncate(PCFD p1, long int p2)
#define e__show_msgbox_2b 93 // int _show_msgbox_2b(int p1, const char *p2, const char *p3, const char *p4, int p5, const char *p6, int p7, const char **p8)
#define e__show_msgbox_3b 94 // int _show_msgbox_3b(int p1, const char *p2, const char *p3, const char *p4, int p5, const char *p6, int p7, const char *p8, int p9, const char **p10)
#define e_opendir 95 // NUC_DIR* nuc_opendir(const char *p1)
#define e_readdir 96 // (struct nuc_dirent*) nuc_readdir(NUC_DIR *p1)
#define e_closedir 97 // int nuc_closedir(NUC_DIR *p1)
#define e_luaL_register 98 // void luaL_register(lua_State *p1, const char *p2, const luaL_Reg *p3)
#define e_luaL_checklstring 99 // (const char*) luaL_checklstring(lua_State *p1, int p2, size_t *p3)
#define e_luaL_error 100 // int luaL_error(lua_State *p1, const char *fmt, ...)
#define e_luaI_openlib 101
#define e_luaL_getmetafield 102 // int luaL_getmetafield(lua_State *p1, int p2, const char *p3)
#define e_luaL_callmeta 103 // int luaL_callmeta(lua_State *p1, int p2, const char *p3)
#define e_luaL_typerror 104 // int luaL_typerror(lua_State *p1, int p2, const char *p3)
#define e_luaL_argerror 105 // int luaL_argerror(lua_State *p1, int p2, const char *p3)
#define e_luaL_optlstring 106 // (const char*) luaL_optlstring(lua_State *p1, int p2, const char *p3, size_t *p4)
#define e_luaL_checknumber 107 // lua_Number luaL_checknumber(lua_State *p1, int p2)
#define e_luaL_optnumber 108 // lua_Number luaL_optnumber(lua_State *p1, int p2, lua_Number p3)
#define e_luaL_checkinteger 109 // lua_Integer luaL_checkinteger(lua_State *p1, int p2)
#define e_luaL_optinteger 110 // lua_Integer luaL_optinteger(lua_State *p1, int p2, lua_Integer p3)
#define e_luaL_checkstack 111 // void luaL_checkstack(lua_State *p1, int p2, const char *p3)
#define e_luaL_checktype 112 // void luaL_checktype(lua_State *p1, int p2, int p3)
#define e_luaL_checkany 113 // void luaL_checkany(lua_State *p1, int p2)
#define e_luaL_newmetatable 114 // int luaL_newmetatable(lua_State *p1, const char *p2)
#define e_luaL_checkudata 115 // void* luaL_checkudata(lua_State *p1, int p2, const char *p3)
#define e_luaL_where 116 // void luaL_where(lua_State *p1, int p2)
#define e_luaL_checkoption 117 // int luaL_checkoption (lua_State *p1, int p2, const char *p3, const char *const p4[])
#define e_luaL_ref 118 // int luaL_ref(lua_State *p1, int p2)
#define e_luaL_unref 119 // void luaL_unref(lua_State *p1, int p2, int p3)
#define e_luaL_loadfile 120 // int luaL_loadfile(lua_State *p1, const char *p2)
#define e_luaL_loadbuffer 121 // int luaL_loadbuffer(lua_State *p1, const char *p2, size_t p3, const char *p4)
#define e_luaL_loadstring 122 // int luaL_loadstring(lua_State *p1, const char *p2)
#define e_luaL_newstate 123 // lua_State* luaL_newstate()
#define e_luaL_gsub 124 // (const char*) luaL_gsub (lua_State *p1, const char *p2, const char *p3, const char *p4)
#define e_luaL_findtable 125 // (const char*) luaL_findtable(lua_State *p1, int p2, const char *p3, int p4)
#define e_luaL_buffinit 126 // void luaL_buffinit(lua_State *p1, luaL_Buffer *p2)
#define e_luaL_prepbuffer 127 // char* luaL_prepbuffer(luaL_Buffer *p1)
#define e_luaL_addlstring 128 // void luaL_addlstring(luaL_Buffer *p1, const char *p2, size_t p3)
#define e_luaL_addstring 129 // void luaL_addstring(luaL_Buffer *p1, const char *p2)
#define e_luaL_addvalue 130 // void luaL_addvalue(luaL_Buffer *p1)
#define e_luaL_pushresult 131 // void luaL_pushresult(luaL_Buffer *p1)
#define e_lua_newstate 132 // lua_State* lua_newstate(lua_Alloc p1, void *p2)
#define e_lua_close 133 // void lua_close(lua_State *p1)
#define e_lua_newthread 134 // lua_State* lua_newthread(lua_State *p1)
#define e_lua_atpanic 135 // lua_CFunction lua_atpanic(lua_State *p1, lua_CFunction p2)
#define e_lua_gettop 136 // int lua_gettop(lua_State *p1)
#define e_lua_settop 137 // void lua_settop(lua_State *p1, int p2)
#define e_lua_pushvalue 138 // void lua_pushvalue(lua_State *p1, int p2)
#define e_lua_remove 139 // void lua_remove(lua_State *p1, int p2)
#define e_lua_insert 140 // void lua_insert (lua_State *p1, int p2)
#define e_lua_replace 141 // void lua_replace(lua_State *p1, int p2)
#define e_lua_checkstack 142 // int lua_checkstack(lua_State *p1, int p2)
#define e_lua_xmove 143 // void lua_xmove(lua_State *p1, lua_State *p2, int p3)
#define e_lua_isnumber 144 // int lua_isnumber(lua_State *p1, int p2)
#define e_lua_isstring 145 // int lua_isstring(lua_State *p1, int p2)
#define e_lua_iscfunction 146 // int lua_iscfunction(lua_State *p1, int p2)
#define e_lua_isuserdata 147 // int lua_isuserdata(lua_State *p1, int p2)
#define e_lua_type 148 // int lua_type(lua_State *p1, int p2)
#define e_lua_typename 149 // (const char*) lua_typename(lua_State *p1, int p2)
#define e_lua_equal 150 // int lua_equal(lua_State *p1, int p2, int p3)
#define e_lua_rawequal 151 // int lua_rawequal(lua_State *p1, int p2, int p3)
#define e_lua_lessthan 152 // int lua_lessthan(lua_State *p1, int p2, int p3)
#define e_lua_tonumber 153 // lua_Number lua_tonumber(lua_State *p1, int p2)
#define e_lua_tointeger 154 // lua_Integer lua_tointeger(lua_State *p1, int p2)
#define e_lua_toboolean 155 // int lua_toboolean(lua_State *p1, int p2)
#define e_lua_tolstring 156 // (const char*) lua_tolstring(lua_State *p1, int p2, size_t *p3)
#define e_lua_objlen 157 // size_t lua_objlen(lua_State *p1, int p2)
#define e_lua_tocfunction 158 // lua_CFunction lua_tocfunction(lua_State *p1, int p2)
#define e_lua_touserdata 159 // void* lua_touserdata(lua_State *p1, int p2)
#define e_lua_tothread 160 // lua_State* lua_tothread(lua_State *p1, int p2)
#define e_lua_topointer 161 // (const void*) lua_topointer(lua_State *p1, int p2)
#define e_lua_pushnil 162 // void lua_pushnil(lua_State *p1)
#define e_lua_pushnumber 163 // void lua_pushnumber(lua_State *p1, lua_Number p2)
#define e_lua_pushinteger 164 // void lua_pushinteger(lua_State *p1, lua_Integer p2)
#define e_lua_pushlstring 165 // void lua_pushlstring(lua_State *p1, const char *p2, size_t p3)
#define e_lua_pushstring 166 // void lua_pushstring(lua_State *p1, const char *p2)
#define e_lua_pushvfstring 167 /* Omitted, as va_list likely not binary-compatible */
#define e_lua_pushfstring 168 // (const char*) lua_pushfstring(lua_State *p1, const char *p2, ...)
#define e_lua_pushcclosure 169 // void lua_pushcclosure(lua_State *p1, lua_CFunction p2, int p3)
#define e_lua_pushboolean 170 // void lua_pushboolean(lua_State *p1, int p2)
#define e_lua_gettable 171 // void lua_gettable(lua_State *p1, int p2)
#define e_lua_getfield 172 // void lua_getfield(lua_State *p1, int p2, const char *p3)
#define e_lua_rawget 173 // void lua_rawget(lua_State *p1, int p2)
#define e_lua_rawgeti 174 // void lua_rawgeti(lua_State *p1, int p2, int p3)
#define e_lua_createtable 175 // void lua_createtable(lua_State *p1, int p2, int p3)
#define e_lua_newuserdata 176 // void* lua_newuserdata(lua_State *p1, size_t p2)
#define e_lua_getmetatable 177 // int lua_getmetatable(lua_State *p1, int p2)
#define e_lua_getfenv 178 // void lua_getfenv(lua_State *p1, int p2)
#define e_lua_settable 179 // void lua_settable (lua_State *p1, int p2)
#define e_lua_setfield 180 // void lua_setfield(lua_State *p1, int p2, const char *p3)
#define e_lua_rawset 181 // void lua_rawset(lua_State *p1, int p2)
#define e_lua_rawseti 182 // void lua_rawseti(lua_State *p1, int p2, int p3)
#define e_lua_setmetatable 183 // int lua_setmetatable(lua_State *p1, int p2)
#define e_lua_setfenv 184 // int lua_setfenv(lua_State *p1, int p2)
#define e_lua_call 185 // void lua_call(lua_State *p1, int p2, int p3)
#define e_lua_pcall 186 // int lua_pcall(lua_State *p1, int p2, int p3, int p4)
#define e_lua_cpcall 187 // int lua_cpcall(lua_State *p1, lua_CFunction p2, void *p3)
#define e_lua_load 188 // int lua_load(lua_State *p1, lua_Reader p2, void *p3, const char *p4)
#define e_lua_dump 189 // int lua_dump(lua_State *p1, lua_Writer p2, void *p3)
#define e_lua_yield 190 // int lua_yield(lua_State *p1, int p2)
#define e_lua_resume 191 // int lua_resume(lua_State *p1, int p2)
#define e_lua_status 192 // int lua_status(lua_State *p1)
#define e_lua_gc 193 // int lua_gc(lua_State *p1, int p2, int p3)
#define e_lua_error 194 // int lua_error(lua_State *p1)
#define e_lua_next 195 // int lua_next (lua_State *p1, int p2)
#define e_lua_concat 196 // void lua_concat(lua_State *p1, int p2)
#define e_lua_getstack 197 // int lua_getstack(lua_State *p1, int p2, lua_Debug *p3)
#define e_refresh_homescr 198 // void refresh_homescr()
#define e_refresh_docbrowser 199 // void refresh_docbrowser(int p1)
#define e_strtok 200
#define e_utf162ascii 201 // void utf162ascii(char *p1, const uint16_t *p2, int p3)
#define e_utf16_strlen 202 // size_t utf16_strlen(const uint16_t *p1)
#define e__show_1NumericInput 203 // int _show_1NumericInput(int p1, const char *p2, const char *p3, const char *p4, int *p5, int p6, int p7, int p8)
#define e__show_2NumericInput 204 // int _show_2NumericInput(int p1, const char *p2, const char *p3, const char *p4, int *p5, int p6, int p7, int p8, const char *p9, int *p10, int p11, int p12, int p13)
#define e__show_msgUserInput 205 // int _show_msgUserInput(int p1, String *p2, const char *p3, const char *p4)
#define e_rand 206
#define e_srand 207
#define e_strtoul 208
#define e_string_new 209 // String string_new()
#define e_string_free 210 // void string_free(String p1)
#define e_string_to_ascii 211 // char* string_to_ascii(String p1)
#define e_string_lower 212 // void string_lower(String p1)
#define e_string_charAt 213 // char string_charAt(String p1, int p2)
#define e_string_concat_utf16 214 // int string_concat_utf16(String p1, const char* p2)
#define e_string_set_ascii 215 // int string_set_ascii(String p1, const char *p2)
#define e_string_set_utf16 216 // int string_set_utf16(String p1, const char *p2)
#define e_string_indexOf_utf16 217 // int string_indexOf_utf16(String p1, int p2, const char *p3)
#define e_string_last_indexOf_utf16 218 // int string_last_indexOf_utf16(String p1, int p2, const char *p3)
#define e_string_compareTo_utf16 219 // int string_compareTo_utf16(String p1, const char *p2)
#define e_string_substring 220 // char* string_substring(String p1, String p2, int p3, int p4)
#define e_string_erase 221 // void string_erase(String p1, int p2)
#define e_string_truncate 222 // void string_truncate(String p1, int p2)
#define e_string_substring_utf16 223 // char* string_subtrsing_utf16(String p1, const char *p2, int *p3)
#define e_string_insert_replace_utf16 224 // int string_insert_replace_utf16(String p1, const char *p2, int p3, int p4)
#define e_string_insert_utf16 225 // int string_insert_utf16(String p1, const char *p2, int p3)
#define e_string_sprintf_utf16 226 // int string_sprintf_utf16(String p1, const char *fmt, ...)
#define e_usbd_open_pipe 227 // usbd_status usbd_open_pipe(usbd_interface_handle p1, uint8_t p2, uint8_t p3, usbd_pipe_handle *p4)
#define e_usbd_close_pipe 228 // usbd_status usbd_close_pipe(usbd_pipe_handle p1)
#define e_usbd_transfer 229 // usbd_status usbd_transfer(usbd_xfer_handle p1)
#define e_usbd_alloc_xfer 230 // usbd_xfer_handle usbd_alloc_xfer(usbd_device_handle p1)
#define e_usbd_free_xfer 231 // usbd_status usbd_free_xfer(usbd_xfer_handle p1)
#define e_usbd_setup_xfer 232 // void usbd_setup_xfer(usbd_xfer_handle p1, usbd_pipe_handle p2, usbd_private_handle p3, void *p4, uint32_t p5, uint16_t p6, uint32_t p7, usbd_callback p8)
#define e_usbd_setup_isoc_xfer 233 // void usbd_setup_isoc_xfer(usbd_xfer_handle p1, usbd_pipe_handle p2, usbd_private_handle p3, uint16_t *p4, uint32_t p5, uint16_t p6, usbd_callback p7)
#define e_usbd_get_xfer_status 234 // void usbd_get_xfer_status(usbd_xfer_handle p1, usbd_private_handle *p2, void **p3, uint32_t *p4, usbd_status *p5)
#define e_usbd_interface2endpoint_descriptor 235 // usb_endpoint_descriptor_t* usbd_interface2endpoint_descriptor(usbd_interface_handle p1, uint8_t p2)
#define e_usbd_abort_pipe 236 // usbd_status usbd_abort_pipe(usbd_pipe_handle p1)
#define e_usbd_clear_endpoint_stall 237 // usbd_status usbd_clear_endpoint_stall(usbd_pipe_handle p1)
#define e_usbd_endpoint_count 238 // usbd_status usbd_endpoint_count(usbd_interface_handle p1, uint8_t *p2)
#define e_usbd_interface_count 239 // usbd_status usbd_interface_count(usbd_device_handle p1, uint8_t *p2)
#define e_usbd_interface2device_handle 240 // usbd_status usbd_interface2device_handle(usbd_interface_handle p1, usbd_device_handle *p2)
#define e_usbd_device2interface_handle 241 // usbd_status usbd_device2interface_handle(usbd_device_handle p1, uint8_t p2, usbd_interface_handle *p3)
#define e_usbd_pipe2device_handle 242 // usbd_status usbd_pipe2device_handle(usbd_pipe_handle p1)
#define e_usbd_sync_transfer 243 // usbd_status usbd_sync_transfer(usbd_xfer_handle p1)
#define e_usbd_open_pipe_intr 244 // usbd_status usbd_open_pipe_intr(usbd_interface_handle p1, uint8_t p2, uint8_t p3, usbd_pipe_handle *p4, usbd_private_handle p5, void *p6, uint32_t *p8, usbd_callback p9, int p10)
#define e_usbd_do_request 245 // usbd_status usbd_do_request(usbd_device_handle p1, usb_device_request_t *p2, void *p3)
#define e_usbd_do_request_flags 246 // usbd_status usbd_do_request_flags(usbd_device_handle p1, usb_device_request_t *p2, void *p3, uint16_t p4, int *p5)
#define e_usbd_do_request_flags_pipe 247 // usbd_status usbd_do_request_flags_pipe(usbd_device_handle p1, usbd_pipe_handle p2, usb_device_request_t *p3, void *p4, uint16_t p5, int *p6)
#define e_usbd_get_interface_descriptor 248 // usb_interface_descriptor_t* usbd_get_interface_descriptor(usbd_interface_handle p1)
#define e_usbd_get_config_descriptor 249 // usb_config_descriptor_t* usbd_get_config_descriptor(usbd_device_handle p1)
#define e_usbd_get_device_descriptor 250 //usb_device_descriptor_t* usbd_get_device_descriptor(usbd_device_handle p2)
#define e_usbd_set_interface 251 // usbd_status usbd_set_interface(usbd_interface_handle p1, int p2)
#define e_usbd_get_interface 252 // usbd_status usbd_get_interface(usbd_interface_handle p1, uint8_t *p2)
#define e_usbd_find_idesc 253 // usb_interface_descriptor_t* usbd_find_idesc(usb_config_descriptor_t *p1, int p2, int p3)
#define e_usbd_errstr 254 // (const char*) usbd_errstr(usbd_status p1)
#define e_usbd_devinfo 255 // void usbd_devinfo(usbd_device_handle p1, int p2, char *p3)
#define e_usbd_get_quirks 256 // (const struct usbd_quirks*) usbd_get_quirks(usbd_device_handle p19
#define e_usbd_get_endpoint_descriptor 257 // usb_endpoint_descriptor_t* usbd_get_endpoint_descriptor(usbd_interface_handle p1, uint8_t p2)
#define e_usb_register_driver 258 // int usb_register_driver(int p1, int(*p2[])(device_t), const char* p3, int p4, unsigned int p5)
#define e_device_get_softc 259 // void* device_get_ivars(device_t p1)
#define e_device_get_ivars 260 // void* device_get_softc(device_t p1)
#define e_get_event 261 // int get_event(struct s_ns_event* p1)
#define e_send_key_event 262 // void send_key_event(struct s_ns_event* p1, unsigned short p2, BOOL p3, BOOL p4)
#define e_send_click_event 263 // void send_click_event(struct s_ns_event* p1, unsigned short p2, BOOL p3, BOOL p4)
#define e_send_pad_event 264 // void send_pad_event(struct s_ns_event* p1, unsigned short p2, BOOL p3, BOOL p4)
#define e_getcwd 265 // char* getcwd(char* p1, size_t p2)
#define e_sscanf 266
#define e_TI_NN_SendKeyPress 267
#define e_TI_NN_IsNodeResponsive 268
#define e_TI_NN_NodeEnumDone 269 // int16_t TI_NN_NodeEnumDone(nn_oh_t p1)
#define e_TI_NN_NodeEnumNext 270 // int16_t TI_NN_NodeEnumNext(nn_oh_t p1, nn_nh_t *p2)
#define e_TI_NN_GetConnMaxPktSize 271 // uint32_t TI_NN_GetConnMaxPktSize(nn_ch_t p1)
#define e_TI_NN_Read 272 // uint16_t TI_NN_Read(nn_ch_t p1, uint32_t p2, void *p3, uint32_t p4, uint32_t p5)
#define e_TI_NN_Write 273 // int16_t TI_NN_Write(nn_ch_t p1, void *p2, uint32_t p3)
#define e_TI_NN_StartService 274 // int16_t TI_NN_StartService(uint32_t p1, void *p2, void(*p3)(nn_ch_t,void*))
#define e_TI_NN_StopService 275 // int16_t TI_NN_StopService(uint32_t p1)
#define e_TI_NN_Connect 276 // int16_t TI_NN_Connect(nn_nh_t p1, uint32_t p2, nn_ch_t *p3)
#define e_TI_NN_Disconnect 277 // int16_t TI_NN_Disconnect(nn_ch_t p1)
#define e_TI_NN_NodeEnumInit 278 // int16_t TI_NN_NodeEnumInit(nn_oh_t p1)
#define e_TI_NN_UnregisterNotifyCallback 279 
#define e_TI_NN_RegisterNotifyCallback 280
#define e_TI_NN_InstallOS 281
#define e_TI_NN_GetNodeInfo 282
#define e_TI_NN_DestroyOperationHandle 283 // int16_t TI_NN_DestroyOperationHandle(nn_oh_t p1)
#define e_TI_NN_CreateOperationHandle 284 // nn_oh_t TI_NN_CreateOperationHandle()
#define e_TI_NN_GetNodeScreen 285
#define e_TI_NN_CopyFile 286
#define e_TI_NN_Rename 287
#define e_TI_NN_RmDir 288
#define e_TI_NN_MkDir 289
#define e_TI_NN_DeleteFile 290
#define e_TI_NN_GetFileAttributes 291
#define e_TI_NN_PutFile 292
#define e_TI_NN_DirEnumDone 293
#define e_TI_NN_DirEnumNext 294
#define e_TI_NN_DirEnumInit 295
#define e_TI_NN_GetFile 296
#define e_get_documents_dir 297 // (const char*) get_documents_dir()
#define e_gui_gc_global_GC_ptr 298
#define e_gui_gc_free 299 // void gui_gc_free(Gc p1)
#define e_gui_gc_copy 300 // Gc gui_gc_copy(Gc p1, int p2, int p3)
#define e_gui_gc_begin 301 // int gui_gc_begin(Gc p1)
#define e_gui_gc_finish 302 // void gui_gc_finish(Gc p1)
#define e_gui_gc_clipRect 303 // void gui_gc_clipRect(Gc p1, int p2, int p3, int p4, int p5, gui_gc_ClipRectOp p6)
#define e_gui_gc_setColorRGB 304 // void gui_gc_setColorRGB(Gc p1, int p2, int p3, int p4)
#define e_gui_gc_setColor 305 // void gui_gc_setColor(Gc p1, int p2)
#define e_gui_gc_setAlpha 306 // void gui_gc_setAlpha(Gc p1, gui_gc_Alpha p2)
#define e_gui_gc_setFont 307 // void gui_gc_setFont(Gc p1, gui_gc_Font p2)
#define e_gui_gc_getFont 308 // gui_gc_Font gui_gc_getFont(Gc p1)
#define e_gui_gc_setPen 309 // gui_gc_setPen(Gc p1, gui_gc_PenSize p2, gui_gc_PenMode p3)
#define e_gui_gc_setRegion 310 // void gui_gc_setRegion(Gc p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8, int p9)
#define e_gui_gc_drawArc 311 // void gui_gc_drawArc(Gc p1, int p2, int p3, int p4, int p5, int p6, int p7)
#define e_gui_gc_drawIcon 312 // void gui_gc_drawIcon(Gc p1, e_resourceID p2, int p3, int p4, int p5)
#define e_gui_gc_drawSprite 313 // void gui_gc_drawSprite(Gc p1, gui_gc_Sprite *p2, int p3, int p4)
#define e_gui_gc_drawLine 314 // void gui_gc_drawLine(Gc p1, int p2, int p3, int p4, int p5)
#define e_gui_gc_drawRect 315 // void gui_gc_drawRect(Gc p1, int p2, int p3, int p4, int p5)
#define e_gui_gc_drawString 316 // void gui_gc_drawString(Gc p1, char *p2, int p3, int p4, gui_gc_StringMode p5)
#define e_gui_gc_drawPoly 317 // void gui_gc_drawPoly(Gc p1, unsigned int* p2, unsigned int p3)
#define e_gui_gc_fillArc 318 // void gui_gc_fillArc(Gc p1, int p2, int p3, int p4, int p5, int p6, int p7)
#define e_gui_gc_fillPoly 319 // void gui_gc_fillPoly(Gc p1, unsigned int *p2, unsigned int p3)
#define e_gui_gc_fillRect 320 // void gui_gc_fillRect(Gc p1, int p2, int p3, int p4, int p5)
#define e_gui_gc_fillGradient 321 // void gui_gc_fillGradient(Gc p1, int p2, int p3, int p4, int p5, int p6, int p7, int p8)
#define e_gui_gc_drawImage 322 // void gui_gc_drawImage(Gc p1, char *p2, int p3, int p4)
#define e_gui_gc_getStringWidth 323 // int gui_gc_getStringWidth(Gc p1, gui_gc_Font p2, char *p3, int p4, int p5)
#define e_gui_gc_getCharWidth 324 // int gui_gc_getCharWidth(Gc p1, gui_gc_Font p2, short p3)
#define e_gui_gc_getStringSmallHeight 325 // int gui_gc_getStringSmallHeight(Gc p1, gui_gc_Font p2, char *p3, int p4, int p5)
#define e_gui_gc_getCharHeight 326 // int gui_gc_getCharHeight(Gc p1, gui_gc_Font p2, short p3)
#define e_gui_gc_getStringHeight 327 // int gui_gc_getStringHeight(Gc p1, gui_gc_Font p2, char *p3, int p4, int p5)
#define e_gui_gc_getFontHeight 328 // int gui_gc_getFontHeight(Gc p1, gui_gc_Font p2)
#define e_gui_gc_getIconSize 329 // int gui_gc_getIconSize(Gc p1, e_resourceID p2, unsigned int p3, unsigned int *p4, unsigned int *p5)
#define e_gui_gc_blit_gc 330 // void gui_gc_blit_gc(Gc p1, int p2, int p3, int p4, int p5, Gc p6, int p7, int p8, int p9, int p10)
#define e_gui_gc_blit_buffer 331 // void gui_gc_blit_buffer(Gc p1, char *p2, int p3, int p4, int p5, int p6)
#define e_snprintf 332
#define e__vprintf 333
#define e__vfprintf 334
#define e__vsnprintf 335
#define e_read_nand 336 // void read_nand(void* dest, int size, int nand_offset, int unknown, int percent_max, void* progress_cb)
#define e_write_nand 337 // int write_nand(void* p1, int p2, unsigned int p3)
#define e_nand_erase_range 338 // int nand_erase_range(int p1, int p2)
#define e_calc_cmd 339 // int TI_MS_evaluateExpr_ACBER(void *p1, void *p2, const uint16_t *p3, void *p4, void *p5)
#define e_get_res_string 340 // char* get_res_string(int p1, int p2)
#define e_disp_str 341 // void disp_str(const char *p1, int *p2, int p3)
#define e_TI_MS_MathExprToStr 342 // int TI_MS_MathExprToStr(void *p1, void *p2, uint16_t **p3)

// END_OF_LIST (always keep this line after the last constant, used by mksyscalls.sh)

// Must be kept up-to-date with the value of the last syscall
#define __SYSCALLS_LAST 342

// Flag: 3 higher bits of the 3-bytes comment field of the swi instruction
#define __SYSCALLS_ISEXT 0x200000
#define __SYSCALLS_ISEMU 0x400000
/* Access to OS variables */
#define __SYSCALLS_ISVAR 0x800000

/* Ndless extensions.
 * Not automatically parsed. Starts from 0. The recommandations for the standard syscalls enumeration apply.
 * The order is the same as in arm/syscalls.c/sc_ext_table[]
 * Must always be or-ed with __SYSCALLS_ISEXT
 * The extensions cannot be called in thumb state (the swi number is too high for the swi thumb instruction */
#define e_nl_osvalue (__SYSCALLS_ISEXT | 0)
#define e_nl_relocdatab (__SYSCALLS_ISEXT | 1)
#define e_nl_hwtype (__SYSCALLS_ISEXT | 2)
#define e_nl_isstartup (__SYSCALLS_ISEXT | 3)
#define e_nl_lua_getstate (__SYSCALLS_ISEXT | 4)
#define e_nl_set_resident (__SYSCALLS_ISEXT | 5)
#define e_nl_ndless_rev (__SYSCALLS_ISEXT | 6)
#define e_nl_no_scr_redraw (__SYSCALLS_ISEXT | 7)
#define e_nl_loaded_by_3rd_party_loader (__SYSCALLS_ISEXT | 8)
#define e_nl_hwsubtype (__SYSCALLS_ISEXT | 9)
#define e_nl_exec (__SYSCALLS_ISEXT | 10)
#define e_nl_osid (__SYSCALLS_ISEXT | 11)
#define e__nl_hassyscall (__SYSCALLS_ISEXT | 12)
#define e_nl_lcd_blit (__SYSCALLS_ISEXT | 13)
#define e_nl_lcd_type (__SYSCALLS_ISEXT | 14)
#define e_nl_lcd_init (__SYSCALLS_ISEXT | 15)

// Must be kept up-to-date with the value of the last syscalls extension without __SYSCALLS_ISEXT
#define __SYSCALLS_LASTEXT 15

/* Ndless integration with emulators. Grouped to make the integration easier for the emulators (they require
 * only these constants).
 * Not automatically parsed. Starts from 0. The recommandations for the standard syscalls enumeration apply.
 * The order is the same as in arm/emu.c/emu_sysc_table[]
 * Must always be or-ed with __SYSCALLS_ISEMU */
#define NDLSEMU_DEBUG_ALLOC (__SYSCALLS_ISEMU | 0)
#define NDLSEMU_DEBUG_FREE (__SYSCALLS_ISEMU | 1)

// Must be kept up-to-date with the value of the last emu extension without __SYSCALLS_ISEMU
#define __SYSCALLS_LASTEMU 1

#endif
