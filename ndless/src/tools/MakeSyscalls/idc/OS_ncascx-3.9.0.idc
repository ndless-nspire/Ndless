#define UNLOADED_FILE   1
#include <idc.idc>
static main(void)
{
	MakeRptCmt	(0x10000344,	"init BSS");
	MakeName	(0x1000552c,	"j_TMT_Retreive_Clock");
	MakeName	(0x10005b58,	"cursor_hide");
	MakeName	(0x10005b84,	"cursor_show");
	MakeName	(0x10005bbc,	"j_get_battery_door_detection_mode_0");
	MakeName	(0x10005bd0,	"j_get_battery_door_detection_mode");
	MakeName	(0x10005c8c,	"gui_gc_getGC");
//	MakeName	(0XFFFFFFFF,	"get_documents_dir");:0xfffffff:0x100002e8
	MakeName	(0x100074fc,	"Exitptt");
	MakeName	(0x100099b4,	"file_exists");
//	MakeName	(0XFFFFFFFF,	"ndless_ploader_hook");:0xfffffff:0x100082f8
	MakeName	(0x1000b3d4,	"_gui_gc_getFont");
	MakeName	(0x1000b4a8,	"_gui_gc_blit_buffer");
	MakeName	(0x1000b64c,	"_gui_gc_getIconSize");
	MakeName	(0x1000b698,	"j__gui_gc_getIconSize");
	MakeName	(0x1000b710,	"_gui_gc_setColorRGB");
//	MakeName	(0XFFFFFFFF,	"gui_gc_new");:0xfffffff:0x100002e8
	MakeName	(0x1000bf0c,	"_gui_gc_setFont");
	MakeName	(0x1000bf4c,	"_gui_gc_getCharHeight");
	MakeName	(0x1000bf60,	"j__gui_gc_stupid_GIMME_INPUT_FONT");
	MakeName	(0x1000bf64,	"_gui_gc_copy");
	MakeName	(0x1000bf98,	"_gui_gc_blit_gc");
	MakeName	(0x1000c420,	"_gui_gc_getCharWidth");
	MakeName	(0x1000c4cc,	"_gui_gc_getStringWidth");
	MakeName	(0x1000c9f8,	"_gui_gc_drawString");
	MakeName	(0x1000cca4,	"_gui_gc_drawImage");
	MakeName	(0x1000cd64,	"_gui_gc_drawIcon");
	MakeName	(0x1000cdfc,	"j__gui_gc_drawIcon");
	MakeName	(0x1000ce00,	"_gui_gc_fillPoly");
	MakeName	(0x1000d054,	"_gui_gc_drawPoly");
	MakeName	(0x1000d1a0,	"_gui_gc_setAlpha");
	MakeName	(0x1000d1c8,	"_gui_gc_fillRect");
	MakeName	(0x1000d1f0,	"_gui_gc_fillArc");
	MakeName	(0x1000d294,	"_gui_gc_drawArc");
	MakeName	(0x1000d330,	"_gui_gc_drawLine");
	MakeName	(0x1000d358,	"_gui_gc_fillGradient");
	MakeName	(0x1000d874,	"_gui_gc_clipRect");
	MakeName	(0x1000d938,	"_gui_gc_setRegion");
	MakeName	(0x1000d9c4,	"_gui_gc_finish");
	MakeName	(0x1000da40,	"_gui_gc_begin");
	MakeName	(0x1000db9c,	"_gui_gc_free");
	MakeName	(0x1000dbb8,	"_gui_gc_new");
//	MakeName	(0XFFFFFFFF,	"ndless_inst_resident_hook");:0xfffffff:0x10342724
	MakeName	(0x100123f4,	"ndless_end_of_init");
//	MakeRptCmt	(0XFFFFFFFF,	"never returns");:0xfffffff:0x10036be4
//	MakeName	(0XFFFFFFFF,	"j_j_free_7");:0xfffffff:0x1057d27c
	MakeName	(0x100153d0,	"j_unlink");
	MakeName	(0x1001aeb0,	"j_j_free_0");
	MakeName	(0x1001aeb4,	"j_j_free_1");
//	MakeName	(0XFFFFFFFF,	"nn_start_services");:0xfffffff:0x100011bc
	MakeName	(0x1021cce8,	"screenCallback");
//	MakeName	(0XFFFFFFFF,	"nn_ext_echo_callback");:0xfffffff:0x100011bc
//	MakeRptCmt	(0XFFFFFFFF,	"17000");:0xfffffff:0xfffffff
	MakeName	(0x1001f9e4,	"TI_Echo_UDP_Init");
	MakeName	(0x1001fb54,	"translateKey");
	MakeName	(0x100224fc,	"_show_msgbox_3b");
	MakeName	(0x10022d54,	"_show_msgbox_2b");
	MakeName	(0x10023468,	"show_dialog_box2_");
//	MakeName	(0XFFFFFFFF,	"j_j_msc2_free_0");:0xfffffff:0xfffffff
	MakeName	(0x1002cb88,	"gui_gc_begin");
	MakeName	(0x1002cbc0,	"gui_gc_finish");
//	MakeName	(0XFFFFFFFF,	"gui_gc_drawImage");:0xfffffff:0x1002cde8
	MakeName	(0x1002cf94,	"gui_gc_blit_buffer");
	MakeName	(0x1002d09c,	"gui_gc_blit_gc");
//	MakeName	(0XFFFFFFFF,	"gui_gc_getIconSize");:0xfffffff:0x1002cde8
	MakeName	(0x1002d374,	"gui_gc_getFontHeight");
//	MakeName	(0XFFFFFFFF,	"gui_gc_getCharHeight");:0xfffffff:0x1002d320
	MakeName	(0x1002d498,	"gui_gc_getStringSmallHeight");
//	MakeName	(0XFFFFFFFF,	"gui_gc_getCharWidth");:0xfffffff:0x1002d2c4
	MakeName	(0x1002d958,	"gui_gc_getStringWidth");
	MakeName	(0x1002d3c8,	"gui_gc_getStringHeight");
	MakeName	(0x1002d878,	"gui_gc_fillPoly");
	MakeName	(0x1002d5d8,	"gui_gc_getFont");
	MakeName	(0x1002d624,	"gui_gc_setFont");
	MakeName	(0x1002dcdc,	"gui_gc_drawString");
	MakeName	(0x1002dc60,	"gui_gc_drawSprite");
//	MakeName	(0XFFFFFFFF,	"gui_gc_drawIcon");:0xfffffff:0x1002cde8
//	MakeName	(0XFFFFFFFF,	"gui_gc_drawPoly");:0xfffffff:0x1002d2c4
	MakeName	(0x1002d8d0,	"gui_gc_fillGradient");
//	MakeName	(0XFFFFFFFF,	"gui_gc_fillRect");:0xfffffff:0x1002cde8
//	MakeName	(0XFFFFFFFF,	"gui_gc_drawRect");:0xfffffff:0x1002cde8
	MakeName	(0x1002daf4,	"gui_gc_setPen");
	MakeName	(0x1002db98,	"gui_gc_setAlpha");
//	MakeName	(0XFFFFFFFF,	"gui_gc_fillArc");:0xfffffff:0x1002d77c
//	MakeName	(0XFFFFFFFF,	"gui_gc_drawArc");:0xfffffff:0x1002d77c
	MakeName	(0x1002d800,	"gui_gc_drawLine");
	MakeName	(0x1002dd48,	"gui_gc_clipRect");
	MakeName	(0x1002df34,	"gui_gc_free");
	MakeName	(0x1002df60,	"gui_gc_setColorRGB");
	MakeName	(0x1002dff8,	"gui_gc_setColor");
	MakeName	(0x1002e010,	"gui_gc_setRegion");
	MakeName	(0x1002e138,	"gui_gc_copy");
	MakeName	(0x100361a8,	"j_j_free_2");
//	MakeRptCmt	(0XFFFFFFFF,	"ressources_syst");:0xfffffff:0x1000f0a8
	MakeName	(0x1003aa3c,	"compress_encrypt_tns");
	MakeName	(0x1003ca58,	"__OS_registerProgramEditor");
	MakeName	(0x1005001c,	"inflateInit");
	MakeName	(0x10055a64,	"j_j_free_3");
	MakeName	(0x10056078,	"j_j_free_4");
	MakeName	(0x10059004,	"_gui_gc_stupid_GIMME_INPUT_FONT");
	MakeName	(0x1006b4b8,	"send_key_event");
	MakeRptCmt	(0x1006b4dc,	"type");
	MakeRptCmt	(0x1006b540,	"ascii");
	MakeRptCmt	(0x1006b544,	"key");
	MakeName	(0x1006badc,	"send_click_event");
	MakeName	(0x1006bb9c,	"send_pad_event");
	MakeName	(0x100775a8,	"j_j_free_5");
	MakeName	(0x10078d74,	"j_j_free_6");
	MakeName	(0x1007c63c,	"j_j_free_8");
	MakeName	(0x1007c924,	"calc_cmd");
	MakeName	(0x1008199c,	"flash_debug_print");
	MakeName	(0x10083d4c,	"flash_ECC_word_to_bytes");
	MakeName	(0x10083d70,	"flash_query_status");
	MakeName	(0x10083d8c,	"flash_reset");
	MakeName	(0x10083dc8,	"flash_query_chip_type");
	MakeName	(0x100841dc,	"flash_write_with_ECC");
	MakeName	(0x10084428,	"check_for_nand");
	MakeName	(0x10085030,	"read_nand");
	MakeName	(0x1008536c,	"write_nand");
	MakeName	(0x100855a4,	"flash_get_block_data_size");
	MakeName	(0x100855d0,	"nand_erase_range");
//	MakeName	(0XFFFFFFFF,	"TI_NN_GetLocalNode");:0xfffffff:0x10005870
	MakeName	(0x100888d8,	"TI_NN_IsNodeResponsive");
//	MakeName	(0XFFFFFFFF,	"TI_NN_GetRemoteServiceId");:0xfffffff:0x1000218c
//	MakeName	(0XFFFFFFFF,	"TI_NN_GetNodeHandle");:0xfffffff:0x1021d8d4
//	MakeName	(0XFFFFFFFF,	"TI_NN_GetSessionHandle");:0xfffffff:0x100005e8
//	MakeName	(0XFFFFFFFF,	"TI_NN_AddServiceToList");:0xfffffff:0x10003948
//	MakeName	(0XFFFFFFFF,	"TI_NN_NodeEnumDone");:0xfffffff:0x10854bb0
//	MakeName	(0XFFFFFFFF,	"TI_NN_NodeEnumNext");:0xfffffff:0x10003794
//	MakeName	(0XFFFFFFFF,	"TI_NN_GetNodeMaxPktSize");:0xfffffff:0x10066c30
//	MakeName	(0XFFFFFFFF,	"TI_NN_GetConnMaxPktSize");:0xfffffff:0x1048e980
//	MakeName	(0XFFFFFFFF,	"j_TI_NN_GetConnMaxPktSize");:0xfffffff:0x10000308
//	MakeName	(0XFFFFFFFF,	"TI_NN_FreeServiceStuct");:0xfffffff:0x10000310
//	MakeName	(0XFFFFFFFF,	"TI_NN_LoadConnectors");:0xfffffff:0x1000454c
//	MakeName	(0XFFFFFFFF,	"TI_NN_LoadNavstack");:0xfffffff:0xfffffff
//	MakeName	(0XFFFFFFFF,	"TI_NN_InitializeGlobals");:0xfffffff:0x10003948
//	MakeName	(0XFFFFFFFF,	"TI_NN_ConstructPacket");:0xfffffff:0xfffffff
//	MakeName	(0XFFFFFFFF,	"TI_NN_Write");:0xfffffff:0x10001b28
//	MakeName	(0XFFFFFFFF,	"TI_NN_Read");:0xfffffff:0x10001b28
//	MakeName	(0XFFFFFFFF,	"TI_NN_NodeEnumInitProcResponse");:0xfffffff:0x1011656c
//	MakeRptCmt	(0XFFFFFFFF,	"15000");:0xfffffff:0x1010c7ec
//	MakeName	(0XFFFFFFFF,	"TI_NN_StartService");:0xfffffff:0x100031a0
//	MakeName	(0XFFFFFFFF,	"TI_NN_InvalidateConnectionHandle");:0xfffffff:0x1000454c
//	MakeName	(0XFFFFFFFF,	"TI_NN_StopService");:0xfffffff:0x100011bc
//	MakeName	(0XFFFFFFFF,	"TI_NN_DisconnectWithNoEclose");:0xfffffff:0x10001b28
//	MakeName	(0XFFFFFFFF,	"TI_NN_ProcessEclosePacket");:0xfffffff:0x10001b28
//	MakeName	(0XFFFFFFFF,	"TI_NN_IsPacketValid");:0xfffffff:0x10000310
//	MakeName	(0XFFFFFFFF,	"TI_NN_Connect2");:0xfffffff:0x10003794
//	MakeName	(0XFFFFFFFF,	"TI_NN_Connect");:0xfffffff:0x100011bc
//	MakeName	(0XFFFFFFFF,	"TI_NN_ConstructControlPacket");:0xfffffff:0xfffffff
//	MakeName	(0XFFFFFFFF,	"TI_NN_SendDisconnectPacket");:0xfffffff:0x100031a0
//	MakeName	(0XFFFFFFFF,	"TI_NN_SrvConnDisconnect");:0xfffffff:0x10001b28
//	MakeName	(0XFFFFFFFF,	"TI_NN_Activate_Callback");:0xfffffff:0x100031a0
//	MakeName	(0XFFFFFFFF,	"TI_NN_Disconnect");:0xfffffff:0x10001b28
//	MakeName	(0XFFFFFFFF,	"TI_NN_NodeEnumInit");:0xfffffff:0x1000454c
//	MakeName	(0XFFFFFFFF,	"TI_NN_Shutdown");:0xfffffff:0x10001b28
//	MakeName	(0XFFFFFFFF,	"TI_NN_Init");:0xfffffff:0xfffffff
//	MakeName	(0XFFFFFFFF,	"TI_NN_CheckNewConnection");:0xfffffff:0x10001b28
//	MakeName	(0XFFFFFFFF,	"TI_NN_ProcessPacket");:0xfffffff:0x10001b28
//	MakeName	(0XFFFFFFFF,	"TI_NN_readCallback");:0xfffffff:0x100011bc
//	MakeName	(0XFFFFFFFF,	"TI_NN_InvalidateConnections");:0xfffffff:0x10000310
//	MakeName	(0XFFFFFFFF,	"TI_NN_UnregisterNotifyCallback");:0xfffffff:0x1000454c
//	MakeName	(0XFFFFFFFF,	"TI_NN_NotifyCallback");:0xfffffff:0x100011bc
//	MakeName	(0XFFFFFFFF,	"TI_NN_RegisterNotifyCallback");:0xfffffff:0x10003948
//	MakeName	(0XFFFFFFFF,	"TI_NN_FreeConnectionHandle");:0xfffffff:0x1000454c
//	MakeName	(0XFFFFFFFF,	"TI_NN_DeleteNode");:0xfffffff:0x10003948
//	MakeName	(0XFFFFFFFF,	"TI_NN_AddNode");:0xfffffff:0x100bbe1c
	MakeName	(0x10087394,	"TI_NN_InstallOSServiceStart");
//	MakeName	(0XFFFFFFFF,	"performRqstToSendOS");:0xfffffff:0x100011bc
	MakeName	(0x10087908,	"install_os_check_file");
	MakeName	(0x10087f84,	"nn_perform_install_os");
//	MakeName	(0XFFFFFFFF,	"TI_NN_InstallOS");:0xfffffff:0x10003794
//	MakeName	(0XFFFFFFFF,	"MessageServiceRegister");:0xfffffff:0x1056a738
	MakeName	(0x10089808,	"start_msg_service");
//	MakeName	(0XFFFFFFFF,	"TI_NN_GetNodeInfo");:0xfffffff:0x10003794
	MakeName	(0x1008b650,	"TI_NN_GetOperationContext");
	MakeName	(0x1008b69c,	"TI_NN_ContinueOperation");
	MakeName	(0x1008b734,	"TI_NN_GetOperationResult");
	MakeName	(0x1008b780,	"TI_NN_SetOperationResult");
	MakeName	(0x1008b880,	"TI_NN_SetOperationProgress");
	MakeName	(0x1008b9bc,	"TI_NN_CancelOperation");
	MakeName	(0x1008bac4,	"TI_NN_SetOperationContext");
	MakeName	(0x1008bbd0,	"TI_NN_DestroyOperationHandle");
	MakeName	(0x1008bca4,	"TI_NN_CreateOperationHandle");
	MakeName	(0x1008c6a0,	"screen_get_error_code");
//	MakeName	(0XFFFFFFFF,	"screen_write_status_packet");:0xfffffff:0x10003ea0
//	MakeName	(0XFFFFFFFF,	"writeScreenRequestPacket");:0xfffffff:0x1032b944
//	MakeName	(0XFFFFFFFF,	"write_screen_data");:0xfffffff:0x10001b28
//	MakeName	(0XFFFFFFFF,	"nn_handle_screen_operation_cb");:0xfffffff:0x10001b28
//	MakeRptCmt	(0XFFFFFFFF,	"30000");:0xfffffff:0x1005e7e0
//	MakeName	(0XFFFFFFFF,	"TI_NN_GetNodeScreen");:0xfffffff:0x1036909c
//	MakeName	(0XFFFFFFFF,	"TI_HAL_getStatinfo");:0xfffffff:0x100011bc
//	MakeName	(0XFFFFFFFF,	"start_sync_service");:0xfffffff:0x10001b28
//	MakeName	(0XFFFFFFFF,	"TI_NN_CopyFile");:0xfffffff:0xfffffff
//	MakeName	(0XFFFFFFFF,	"TI_NN_Rename");:0xfffffff:0xfffffff
//	MakeName	(0XFFFFFFFF,	"TI_NN_RmDir");:0xfffffff:0x10147920
//	MakeName	(0XFFFFFFFF,	"TI_NN_MkDir");:0xfffffff:0x10147920
//	MakeName	(0XFFFFFFFF,	"TI_NN_DeleteFile");:0xfffffff:0x10147920
//	MakeName	(0XFFFFFFFF,	"TI_NN_GetFileAttributes");:0xfffffff:0x10003794
//	MakeName	(0XFFFFFFFF,	"TI_NN_PutFile");:0xfffffff:0x10001b28
//	MakeName	(0XFFFFFFFF,	"TI_NN_DirEnumDone");:0xfffffff:0xfffffff
//	MakeName	(0XFFFFFFFF,	"TI_NN_DirEnumNext");:0xfffffff:0xfffffff
//	MakeName	(0XFFFFFFFF,	"TI_NN_DirEnumInit");:0xfffffff:0x100031a0
//	MakeName	(0XFFFFFFFF,	"TI_NN_GetFile");:0xfffffff:0x105ea1a4
	MakeName	(0x1009d68c,	"find_connection");
	MakeName	(0x100a1b94,	"TI_NS_WritePacketToRemoteStream");
	MakeRptCmt	(0x100a1c10,	"cn_write?");
	MakeName	(0x100a1ea0,	"append_pkt_to_hold_q");
	MakeName	(0x100a1f94,	"send_remote_packet");
	MakeName	(0x100a22a4,	"q_pkt_n_wait_for_ack");
	MakeName	(0x100a31a8,	"process_received_pckt");
	MakeName	(0x100a52f0,	"create_pkt_list");
	MakeName	(0x100a554c,	"TI_NS_Write");
	MakeName	(0x100bd974,	"j_printf");
	MakeName	(0x100c0c20,	"get_battery_door_detection_mode");
	MakeName	(0x100c1688,	"set_task_name");
	MakeName	(0x100c5770,	"publish_send_immediate");
	MakeName	(0x100cbc60,	"disp_str");
	MakeName	(0x100d0f6c,	"ti_pm_register_dma");
	MakeName	(0x100d1644,	"reboot");
	MakeName	(0x100eaddc,	"j_string_free_1");
	MakeName	(0x100eade0,	"j_string_new_0");
	MakeName	(0x100eae58,	"j_string_concat_utf16_0");
	MakeName	(0x100eaee0,	"j_string_set_utf16_0");
	MakeName	(0x100f0e78,	"j_msc2_free_0");
//	MakeName	(0XFFFFFFFF,	"j_j_free_9");:0xfffffff:0x100e5e34
//	MakeName	(0XFFFFFFFF,	"get_res_string");:0xfffffff:0x100f3b0c
	MakeName	(0x10111234,	"get_res_string_sys");
	MakeName	(0x10110e9c,	"read_unaligned");
	MakeName	(0x1012b0c8,	"lua_string_usub");
	MakeName	(0x1012bd9c,	"luaL_openlibs");
	MakeName	(0x10133cec,	"lua_d2editor_newRichText");
	MakeName	(0x1013500c,	"lua_clipboard_getText");
	MakeName	(0x101383f0,	"lua_platform_isDeviceModeRendering");
	MakeName	(0x10138410,	"lua_platform_gc");
	MakeName	(0x1013cd7c,	"log_rs232");
	MakeName	(0x1013d228,	"j_log_rs232");
	MakeName	(0x1017aa8c,	"j_j_free_11");
	MakeName	(0x101a5bfc,	"j_j_free_24");
	MakeName	(0x101a75c4,	"j_j_free_10");
	MakeName	(0x101a77ec,	"j_j_free_16");
	MakeName	(0x101b3cbc,	"j_j_free_12");
//	MakeName	(0XFFFFFFFF,	"j_show_dialog_box?");:0x10000000:0x10000001
	MakeName	(0x101f7ecc,	"j_crypt_decrypt_tns_D_block");
	MakeName	(0x101f7f6c,	"des_start_decrypt");
	MakeName	(0x101f82a4,	"crypt_decrypt_tns_D_block");
	MakeName	(0x101f897c,	"des_get_keys");
	MakeName	(0x101f8ad8,	"DES_ecb3_encrypt");
	MakeName	(0x101f8d20,	"des_set_key_unchecked");
	MakeName	(0x101f9184,	"get_des_key");
	MakeName	(0x101f92b0,	"do_engine_init");
	MakeName	(0x101fe318,	"DES_encrypt2");
	MakeName	(0x101ff7a8,	"DES_encrypt3");
	MakeName	(0x101ff8cc,	"DES_decrypt3");
	MakeName	(0x10200780,	"engine_unlocked_finish");
	MakeName	(0x102007d0,	"ENGINE_finish");
	MakeName	(0x10200844,	"engine_unlocked_init");
	MakeName	(0x10200910,	"ENGINE_init");
	MakeName	(0x10201924,	"CRYPTO_w_lock_unlock");
	MakeName	(0x10204f88,	"engine_table_select");
	MakeName	(0x1021bca0,	"touchpad_write");
	MakeName	(0x1021bfec,	"touchpad_read");
	MakeName	(0x1027f618,	"j_j_free_13");
//	MakeName	(0XFFFFFFFF,	"get_event");:0xfffffff:0x100792c8
//	MakeRptCmt	(0XFFFFFFFF,	"pending event flag");:0xfffffff:0x1005494c
//	MakeRptCmt	(0XFFFFFFFF,	"fill up the event struct");:0xfffffff:0x10282930
	MakeRptCmt	(0x103fa878,	"pending event flag");
	MakeName	(0x1028cc20,	"j_get_documents_dir");
	MakeName	(0x1028dc70,	"string_len");
	MakeName	(0x1028dc78,	"string_charAt");
	MakeName	(0x1028dcc4,	"string_truncate");
	MakeName	(0x1028dcec,	"string_erase");
	MakeName	(0x1028e0bc,	"string_lower");
	MakeName	(0x1028e0fc,	"string_free");
	MakeName	(0x1028e150,	"string_new");
	MakeName	(0x1028e1dc,	"string_realloc_str");
	MakeName	(0x1028e2e8,	"string_to_ascii");
	MakeName	(0x1028e4e8,	"string_insert_utf16");
	MakeName	(0x1028e660,	"string_insert_replace_utf16");
	MakeName	(0x1028e6e8,	"string_substring");
	MakeName	(0x1028e778,	"string_set_utf16");
	MakeName	(0x1028e7f0,	"string_set_ascii_0");
	MakeName	(0x1028e93c,	"string_set_ascii");
	MakeName	(0x1028ea4c,	"string_concat_utf16");
	MakeName	(0x1028eac0,	"string_compareTo_utf16");
	MakeName	(0x1028eadc,	"string_indexOf_utf16");
	MakeName	(0x1028eb34,	"string_substring_utf16");
	MakeName	(0x1028ec78,	"string_last_indexOf_utf16");
	MakeName	(0x1028ecd4,	"string_formatNumber");
	MakeName	(0x1028f010,	"string_sprintf_utf16");
	MakeName	(0x1028f06c,	"string_formatInteger");
	MakeName	(0x102b1650,	"j_memcpy_0");
	MakeName	(0x102b1654,	"j_memset_0");
	MakeName	(0x102b1658,	"j_free");
	MakeName	(0x102b181c,	"unknown_TI_AllocateBlock_");
	MakeName	(0x102b1820,	"j_memcpy");
	MakeName	(0x102b1824,	"j_memset");
	MakeName	(0x102b1ac8,	"utf162ascii");
	MakeName	(0x102b465c,	"ascii2utf16");
//	MakeName	(0XFFFFFFFF,	"j_j_free_14");:0xfffffff:0xfffffff
	MakeName	(0x102bddec,	"refresh_homescr");
	MakeName	(0x102bea1c,	"refresh_docbrowser");
	MakeName	(0x102d539c,	"Expat_XML_Parse");
	MakeName	(0x102ed100,	"unknown_TI_ZIPArchive_UnallocateBuffers");
	MakeName	(0x102ed144,	"unknown_TI_ZIPArchive_Close");
	MakeName	(0x102ed274,	"unknown_TI_ZIPArchive_Uncompress_");
	MakeName	(0x102ed390,	"unknown_TI_ZIPArchive_Open");
	MakeName	(0x102ef298,	"tixc0100_compress");
	MakeName	(0x102f059c,	"tixc0100_uncompress");
	MakeName	(0x102f1504,	"read_unaligned_word");
	MakeName	(0x102f151c,	"read_unaligned_longword");
	MakeName	(0x102f1674,	"write_unaligned_word");
	MakeName	(0x102f1684,	"write_unaligned_longword");
	MakeName	(0x102f3014,	"crc32");
	MakeName	(0x102f30c8,	"crc32_combine");
	MakeName	(0x102f32b8,	"deflateEnd");
	MakeName	(0x102f4280,	"deflate");
	MakeName	(0x102f5bb8,	"deflateInit2_");
	MakeName	(0x102f5e54,	"deflateInit");
	MakeName	(0x102f5f5c,	"inflateInit2_");
	MakeName	(0x102f6094,	"inflateEnd");
	MakeName	(0x102f66c8,	"inflate");
//	MakeName	(0XFFFFFFFF,	"zlibVersion");:0xfffffff:0x100002e8
	MakeName	(0x102fce98,	"zlibCompileFlags");
	MakeName	(0x102fcec4,	"adler32");
	MakeName	(0x102fd35c,	"compress2");
	MakeName	(0x102fddd0,	"CSC_Place_On_List");
	MakeName	(0x102fde00,	"CSC_Priority_Place_On_List");
	MakeName	(0x102fde78,	"CSC_Remove_From_List");
	MakeName	(0x102fe0a0,	"ERC_System_Error");
	MakeName	(0x103009fc,	"QUC_Receive_From_Queue");
	MakeName	(0x103010cc,	"QUC_Send_To_Queue");
	MakeName	(0x10303080,	"TMS_Delete_Timer");
	MakeName	(0x103030f4,	"TMS_Create_Timer");
	MakeName	(0x1030346c,	"DMC_Cleanup");
	MakeName	(0x1030349c,	"net_free");
	MakeName	(0x10303844,	"DMC_Create_Memory_Pool");
	MakeName	(0x10303990,	"DMC_Allocate_Memory");
	MakeName	(0x10303ba0,	"DMC_Deallocate_Memory_0");
	MakeName	(0x1032214c,	"isspace");
	MakeRptCmt	(0x1035aeec,	"fill up the event struct");
	MakeName	(0x10361d74,	"cursor_hide2");
	MakeName	(0x10365910,	"nn_pkt_malloc");
//	MakeName	(0XFFFFFFFF,	"TCC_Current_Task_Pointer");:0xfffffff:0x1037b3e0
	MakeName	(0x1037b548,	"TCC_Dispatch_LISR");
	MakeName	(0x1037b864,	"TCC_Suspend_Task");
	MakeName	(0x1037bb6c,	"TCC_Resume_Task");
	MakeName	(0x1037be74,	"TCC_Terminate_Task");
	MakeName	(0x1037bfd8,	"TCC_Reset_Task");
	MakeName	(0x1037c1e0,	"TCC_Create_Task");
	MakeName	(0x1037c760,	"INT_Vectors");
	MakeName	(0x1037c81c,	"INT_Vectors_Loaded");
	MakeName	(0x1037c828,	"INT_Setup_Vectors");
	MakeName	(0x1037c840,	"int_irq_enable");
	MakeName	(0x1037c868,	"int_irq_disable");
	MakeName	(0x1037c890,	"INT_Retreive_Shell");
	MakeName	(0x1037c8a0,	"INT_Reset_Addr");
	MakeName	(0x1037c8dc,	"INT_Undef_Addr");
	MakeName	(0x1037c918,	"INT_Software_Addr");
	MakeName	(0x1037c954,	"Int_Prefetch_Addr");
	MakeName	(0x1037ca2c,	"Int_Reserved");
	MakeName	(0x1037cbb0,	"INT_C_Memory_Initialize");
	MakeName	(0x1037cbec,	"INT_Clear_BSS");
	MakeName	(0x1037cd88,	"io_init_table");
	MakeName	(0x1037d1d4,	"INT_Target_Initialize");
	MakeName	(0x1037d1f0,	"Int_IRQ");
	MakeName	(0x1037d260,	"Int_FIQ");
	MakeName	(0x1037d688,	"TCT_Local_Control_Interrupts");
	MakeName	(0x1037d6ac,	"TCT_Restore_Interrupts");
	MakeName	(0x1037d6d0,	"TCT_Build_Task_Stack");
	MakeName	(0x1037d7f8,	"TCT_Build_Signal_Frame");
	MakeName	(0x1037d868,	"TCT_Check_Stack");
	MakeName	(0x1037d8c4,	"TCT_Schedule");
	MakeName	(0x1037d9cc,	"TCT_Control_To_System");
	MakeName	(0x1037dc34,	"TCT_Protect_Switch");
	MakeName	(0x1037dc7c,	"TCT_Schedule_Protected");
	MakeName	(0x1037dfe8,	"TMT_Retreive_Clock");
	MakeName	(0x1037dff4,	"TMT_Read_Timer");
	MakeName	(0x1037e000,	"TMT_Enable_Timer");
	MakeName	(0x1037e018,	"TMT_Adjust_Timer");
	MakeName	(0x1037e03c,	"TMT_Disable_Timer");
	MakeName	(0x1037e04c,	"TMT_Retreive_TS_Task");
	MakeName	(0x1037e058,	"TMT_Timer_Interrupt");
	MakeName	(0x1037e1d8,	"luaopen_image");
	MakeName	(0x1037e7fc,	"get_internal_event");
	MakeRptCmt	(0x1037e804,	"'KSAT'");
	MakeRptCmt	(0x1037e818,	" = KSAT?");
	MakeRptCmt	(0x1037e84c,	"internal event dest");
	MakeRptCmt	(0x1037e85c,	"get the event");
	MakeRptCmt	(0x1037e890,	"internal event");
	MakeRptCmt	(0x1037e894,	"event struct dest");
	MakeName	(0x1037e8bc,	"create_event_queue");
	MakeName	(0x1037ead4,	"send_to_event_queue");
	MakeName	(0x1038deb4,	"FfxVSprintf");
	MakeName	(0x1039cc38,	"tftp_transfer");
	MakeName	(0x103a8f6c,	"tftpc_transfer");
	MakeName	(0x103bc754,	"setup_peap_version");
	MakeName	(0x103c053c,	"GenerateAuthenticatorResponse");
	MakeName	(0x103c091c,	"setup_eap_mschapv2");
	MakeName	(0x103dd468,	"btiosc_handler6");
	MakeName	(0x103dd470,	"btiosc_handler3");
	MakeName	(0x103dd478,	"btiosc_thread");
	MakeName	(0x103dd4e0,	"btiosc_handler2");
	MakeName	(0x103dd55c,	"btiosc_handler5");
	MakeName	(0x103dd638,	"btiosc_handler7");
	MakeName	(0x103dd73c,	"btiosc_handler4");
	MakeName	(0x103dd808,	"btiosc_handler1");
	MakeName	(0x103ddabc,	"get_usb_info");
	MakeName	(0x103ddb60,	"alloc_jbtio");
	MakeName	(0x103de354,	"device_get_ivars");
	MakeName	(0x103de364,	"USBDEVNAME");
	MakeName	(0x103de394,	"device_get_softc");
	MakeName	(0x103de47c,	"_usb_mk_device_name");
	MakeName	(0x103de578,	"usb_register_driver");
	MakeName	(0x103de66c,	"unregister_drivers");
	MakeRptCmt	(0x103de674,	"chained list of drivers");
	MakeName	(0x103de6b8,	"register_drivers");
	MakeRptCmt	(0x103de6c0,	"table of drivers");
	MakeName	(0x103de700,	"_usb_match");
	MakeRptCmt	(0x103de76c,	"call the match method");
	MakeRptCmt	(0x103de770,	"UMATCH_*");
	MakeRptCmt	(0x103de784,	"= 0");
	MakeRptCmt	(0x103de788,	"next in chained list");
	MakeRptCmt	(0x103de7cc,	"call the attach method");
	MakeName	(0x103ded78,	"usbd_errstr");
	MakeName	(0x103df7c0,	"alloc_tdi_4x_otg");
	MakeName	(0x103e2048,	"alloc_tdi_4x");
	MakeName	(0x103e2f90,	"dcd_free_pipe");
	MakeName	(0x103e326c,	"build_single_td");
	MakeRptCmt	(0x103e85d0,	"nSpireDev0");
	MakeName	(0x103e872c,	"cn_write");
	MakeName	(0x103e87d4,	"EOREAD4");
	MakeName	(0x103e87f8,	"EOWRITE4");
	MakeName	(0x103e8b54,	"start_usb_stack");
	MakeName	(0x103e8c60,	"bsd_printf");
	MakeName	(0x103e8c78,	"bsd_panic");
	MakeName	(0x103e91b4,	"bsd_free2");
	MakeName	(0x103e91b8,	"j_msc2_free");
	MakeName	(0x103e91bc,	"bsd_malloc");
	MakeName	(0x103e9338,	"snprintf");
//	MakeName	(0XFFFFFFFF,	"j_strcpy");:0xfffffff:0x10007efc
//	MakeName	(0XFFFFFFFF,	"j_strncmp");:0xfffffff:0x10007f00
//	MakeName	(0XFFFFFFFF,	"j_strcmp");:0xfffffff:0x10007f04
//	MakeName	(0XFFFFFFFF,	"j_strlen");:0xfffffff:0x10007f08
//	MakeName	(0XFFFFFFFF,	"j_memset_1");:0xfffffff:0x10007f0c
//	MakeName	(0XFFFFFFFF,	"j_memcpy_1");:0xfffffff:0x10007f10
	MakeName	(0x103e94a0,	"_tsleep");
	MakeName	(0x103e95a4,	"usbd_delay_ms");
	MakeName	(0x103fa0a0,	"errno_addr");
	MakeName	(0x103fb4b4,	"pthread_create");
	MakeName	(0x103fc76c,	"pthread_join");
	MakeName	(0x103fc8f8,	"mutex_destroy");
	MakeName	(0x103fd718,	"is_nonzero");
	MakeName	(0x103fdf34,	"isalpha");
	MakeName	(0x103fdf60,	"isascii");
	MakeName	(0x103fdf70,	"isdigit");
	MakeName	(0x103fdf84,	"islower");
	MakeName	(0x103fdfb0,	"isupper");
	MakeName	(0x103fdfc4,	"isxdigit");
	MakeName	(0x103fe000,	"tolower");
	MakeName	(0x103fe010,	"toupper");
	MakeName	(0x103fe020,	"calloc");
	MakeName	(0x103fe05c,	"free");
	MakeName	(0x103fe0d0,	"malloc");
	MakeName	(0x103fe1a0,	"realloc");
	MakeName	(0x10400790,	"fprintf");
	MakeName	(0x10400828,	"printf");
	MakeName	(0x10400860,	"unknown_vsprintf_");
	MakeName	(0x104008b0,	"sprintf");
	MakeName	(0x104008e4,	"_vfprintf");
	MakeName	(0x10400960,	"_vprintf");
	MakeName	(0x104009e4,	"_vsnprintf");
	MakeName	(0x10400a38,	"_vsprintf");
	MakeName	(0x104013bc,	"vsprintf_limit256");
	MakeName	(0x104021b0,	"sscanf");
	MakeName	(0x1040314c,	"file_undef1");
	MakeName	(0x1040322c,	"fclose");
	MakeName	(0x10403298,	"feof");
	MakeName	(0x104032c8,	"ferror");
	MakeName	(0x104032f8,	"flush_stream_sub");
	MakeName	(0x10403360,	"fflush");
	MakeName	(0x104033dc,	"fget_sub");
	MakeName	(0x104035b8,	"fgetc");
	MakeName	(0x10403658,	"fgets");
	MakeName	(0x104037fc,	"file_undef2");
	MakeName	(0x104038a4,	"file_undef3");
	MakeName	(0x104039d0,	"freopen");
	MakeName	(0x10403a0c,	"fopen");
	MakeName	(0x10403bb0,	"fread");
	MakeName	(0x10403da4,	"fseek");
	MakeName	(0x10403ef8,	"ftell");
	MakeName	(0x10404038,	"fwrite");
	MakeName	(0x104042d8,	"getc");
	MakeName	(0x10404340,	"putc");
	MakeName	(0x104043b0,	"puts");
	MakeName	(0x104043f4,	"remove");
	MakeName	(0x104045c0,	"ungetc");
//	MakeName	(0XFFFFFFFF,	"atoi");:0x10404658:0x104046e0
	MakeName	(0x10404aa0,	"rand");
//	MakeName	(0XFFFFFFFF,	"srand");:0xfffffff:0x1002acd0
	MakeName	(0x10404b4c,	"strtod");
	MakeName	(0x10404d28,	"strtol_sub");
	MakeName	(0x10404e54,	"strtol");
	MakeName	(0x10404fb8,	"strtoul");
	MakeName	(0x10405020,	"memchr");
	MakeName	(0x1040509c,	"memcmp");
	MakeName	(0x10405134,	"memcpy");
	MakeName	(0x10405138,	"memmove");
	MakeName	(0x1040546c,	"memset");
	MakeName	(0x104055d0,	"strcat");
	MakeName	(0x10405604,	"strchr");
	MakeName	(0x10405628,	"strcmp");
	MakeName	(0x10405678,	"strcpy");
	MakeName	(0x10405714,	"strerror");
	MakeName	(0x1040573c,	"strlen");
	MakeName	(0x10405764,	"strncat");
	MakeName	(0x104057f8,	"strncmp");
	MakeName	(0x104058ac,	"strncpy");
	MakeName	(0x10405984,	"strpbrk");
	MakeName	(0x104059d4,	"strrchr");
	MakeName	(0x104059fc,	"strstr");
	MakeName	(0x10405a6c,	"strtok");
	MakeName	(0x10405be0,	"__OS_formatDate");
	MakeName	(0x10407194,	"_memcpy");
	MakeName	(0x10407838,	"memrev");
	MakeName	(0x10407b1c,	"atof");
	MakeName	(0x104081c4,	"fputc");
	MakeName	(0x10408368,	"strtoul?");
	MakeName	(0x104091e0,	"chdir");
	MakeName	(0x10409340,	"close");
	MakeName	(0x104094c4,	"closedir");
	MakeName	(0x10409db0,	"getcwd");
	MakeName	(0x1040a130,	"mkdir");
	MakeName	(0x1040a2b0,	"open");
	MakeName	(0x1040a5ec,	"opendir");
	MakeName	(0x1040b10c,	"slash_to_backslash_in_path");
	MakeName	(0x1040b1e8,	"posix_file_init");
	MakeName	(0x1040b484,	"read");
	MakeName	(0x1040b780,	"readdir");
	MakeName	(0x1040b8a0,	"rename");
	MakeName	(0x1040baec,	"rmdir");
	MakeName	(0x1040bc84,	"stat");
	MakeName	(0x1040bf60,	"unlink");
	MakeName	(0x1040c1e8,	"write");
	MakeName	(0x1040caa8,	"lua_cursor_show");
	MakeName	(0x1040ccfc,	"j_NU_Open");
	MakeName	(0x1040d1e4,	"NU_Done");
	MakeName	(0x1040d250,	"NU_Get_Next");
	MakeName	(0x1040d2b0,	"NU_Get_First");
	MakeName	(0x1040d5f0,	"NU_Current_Dir");
	MakeName	(0x1040d67c,	"NU_Set_Current_Dir");
	MakeName	(0x1040d74c,	"NU_Flush");
	MakeName	(0x1040d790,	"NU_Truncate");
	MakeName	(0x1040d7dc,	"NU_Seek");
	MakeName	(0x1040d830,	"NU_Write");
	MakeName	(0x1040d884,	"NU_Read");
	MakeName	(0x1040d920,	"NU_Delete");
	MakeName	(0x1040d960,	"NU_Close");
	MakeName	(0x1040d9b8,	"NU_Open");
	MakeName	(0x1040da40,	"NU_FreeSpace");
	MakeName	(0x10413a50,	"FfxDriverDiskCreate");
	MakeName	(0x104232fc,	"FfxDclAssertFired");
	MakeName	(0x1045ab9c,	"luaO_pushvfstring");
	MakeName	(0x1045d40c,	"SHA1_Update");
	MakeName	(0x10477bc0,	"alloc_ehci_local");
	MakeName	(0x10477db8,	"ehci_unknownvendor_attach");
	MakeName	(0x10477fac,	"alloc_ucompdev");
	MakeName	(0x10478338,	"unknown_match2");
	MakeRptCmt	(0x104788e0,	"SUSPEND");
	MakeName	(0x10478d14,	"uhub_explore");
	MakeRptCmt	(0x10479288,	"power");
	MakeName	(0x10479434,	"bus_generic_resume");
	MakeName	(0x1047946c,	"bus_generic_shutdown");
	MakeRptCmt	(0x10479648,	"UHF_PORT_RESET");
	MakeName	(0x104797a4,	"bus_generic_suspend");
	MakeRptCmt	(0x104798c4,	"SUSPEND");
	MakeName	(0x104798f8,	"uhub_detach");
	MakeName	(0x10479a10,	"uhub_attach");
	MakeRptCmt	(0x10479a60,	"%s");
	MakeRptCmt	(0x10479a6c,	"%s\\n");
	MakeName	(0x10479f94,	"uhub_match");
	MakeName	(0x1047a23c,	"usb_attach");
	MakeName	(0x1047a428,	"usbd_find_idesc");
	MakeName	(0x1047a878,	"usb_disconnect_port");
	MakeName	(0x1047ac20,	"usbd_setup_pipe");
	MakeName	(0x1047ad64,	"usbd_fill_iface_data");
	MakeName	(0x1047af98,	"usbd_set_config_index");
	MakeName	(0x1047b5d8,	"usbd_reset_port");
	MakeName	(0x1047b890,	"usbd_new_device");
	MakeRptCmt	(0x1047bb74,	"usbd_remove_device ?");
	MakeName	(0x1047c200,	"usbd_devinfo");
	MakeName	(0x1047c520,	"usbd_setup_xfer");
	MakeName	(0x1047c5e4,	"usbd_setup_isoc_xfer");
	MakeName	(0x1047c640,	"usbd_get_xfer_status");
	MakeName	(0x1047c680,	"usbd_get_config_descriptor");
	MakeName	(0x1047c688,	"usbd_get_interface_descriptor");
	MakeName	(0x1047c690,	"usbd_get_device_descriptor");
	MakeName	(0x1047c698,	"usbd_interface2endpoint_descriptor");
	MakeName	(0x1047c6b4,	"usbd_abort_pipe");
	MakeName	(0x1047c714,	"usbd_interface_count");
	MakeName	(0x1047c730,	"usbd_interface2device_handle");
	MakeName	(0x1047c73c,	"usbd_device2interface_handle");
	MakeName	(0x1047c76c,	"usbd_pipe2device_handle");
	MakeName	(0x1047c774,	"usbd_get_endpoint_descriptor");
	MakeName	(0x1047c938,	"usbd_get_quirks");
	MakeName	(0x1047c9dc,	"wakeup");
	MakeName	(0x1047cadc,	"usbd_endpoint_count");
	MakeName	(0x1047cb68,	"usbd_start_next");
	MakeName	(0x1047cd78,	"usbd_free_xfer");
	MakeName	(0x1047ce34,	"usbd_close_pipe");
	MakeName	(0x1047ceb0,	"usbd_alloc_xfer");
	MakeName	(0x1047cfd0,	"usbd_transfer");
	MakeName	(0x1047d3bc,	"usbd_sync_transfer");
	MakeName	(0x1047d3cc,	"usbd_do_request_flags_pipe");
	MakeName	(0x1047d5d8,	"usbd_do_request_flags");
	MakeName	(0x1047d618,	"usbd_do_request");
	MakeName	(0x1047d640,	"usbd_get_interface");
	MakeName	(0x1047d698,	"usbd_set_interface");
//	MakeName	(0XFFFFFFFF,	"usbd_clear_endpoint_stall");:0x1047d350:0x1047d734
	MakeName	(0x1047d7a0,	"usbd_open_pipe_ival");
	MakeName	(0x1047d8f0,	"usbd_open_pipe_intr");
	MakeRptCmt	(0x1047d944,	"inlined usbd_setup_xfer");
	MakeName	(0x1047d9dc,	"usbd_open_pipe");
	MakeName	(0x1047d9f8,	"usbd_intr_transfer");
	MakeName	(0x1047dab0,	"usbd_bulk_transfer");
	MakeName	(0x1047db70,	"usbd_intr_transfer_cb");
	MakeName	(0x1047db80,	"usbd_bulk_transfer_cb");
	MakeName	(0x1047dbdc,	"usbd_set_port_feature");
	MakeName	(0x1047dc2c,	"usbd_clear_port_feature");
	MakeName	(0x1047dd1c,	"usbd_get_port_status");
	MakeName	(0x1047e7c8,	"ehci_intr1");
	MakeName	(0x1047e974,	"ehci_poll");
	MakeName	(0x1047ea08,	"ehci_roothub_exec");
	MakeName	(0x1047f084,	"ehci_freem");
	MakeName	(0x1047f988,	"ehci_check_intr");
	MakeName	(0x10480388,	"ehci_allocm");
	MakeName	(0x104803b8,	"ehci_allocx");
	MakeName	(0x104813ac,	"ehci_rem_qh");
	MakeName	(0x1048143c,	"ehci_device_ctrl_close");
	MakeName	(0x10481478,	"ehci_abort_xfer");
	MakeName	(0x10481624,	"ehci_device_ctrl_abort");
	MakeName	(0x10481628,	"j_ehci_abort_xfer_0");
	MakeName	(0x1048162c,	"j_ehci_abort_xfer_1");
	MakeName	(0x10481a78,	"ehci_open");
	MakeName	(0x10481e9c,	"bsd_free");
	MakeRptCmt	(0x10482a40,	"Texas Instruments ID");
	MakeRptCmt	(0x10482a50,	"TI-Nspire ?");
	MakeName	(0x10482ec4,	"alloc_jhid_general");
	MakeName	(0x1048326c,	"jhid_attach");
	MakeName	(0x104835b4,	"jhid_match");
	MakeRptCmt	(0x104835d8,	"HID");
	MakeRptCmt	(0x10485020,	"usb_gadget_info. Never reached.");
	MakeName	(0x10485368,	"dma_alloc");
	MakeName	(0x10485f4c,	"utf16_strlen");
	MakeName	(0x10489860,	"__rt_udiv_2");
	MakeName	(0x10489954,	"__rt_udiv");
	MakeName	(0x1048997c,	"__rt_udiv_3");
	MakeName	(0x10489a9c,	"__rt_sdiv");
	MakeName	(0x1048a4bc,	"lua_number2integer");
	MakeName	(0x1048adb8,	"_ll_udiv");
	MakeName	(0x1048bdf0,	"blowfish_encrypt");
	MakeName	(0x1048c330,	"blowfish_decrypt");
	MakeName	(0x1048c888,	"blowfish_initialize_ctx");
	MakeName	(0x1048ca88,	"cert_decrypt");
	MakeName	(0x1048d968,	"blowfish_encrypt_8bit_unused");
//	MakeName	(0XFFFFFFFF,	"j_string_set_utf16");:0xfffffff:0x10744be4
	MakeName	(0x1052a294,	"j_TMT_Retreive_Clock_0");
	MakeName	(0x10551654,	"j_SMC_Delete_Semaphore_0");
	MakeName	(0x105522f4,	"j_SMC_Delete_Semaphore_1");
	MakeName	(0x105522f8,	"j_j_SMC_Delete_Semaphore_1");
	MakeName	(0x10553238,	"j_SMC_Delete_Semaphore_2");
	MakeName	(0x1055323c,	"j_j_SMC_Delete_Semaphore_2");
	MakeName	(0x10553998,	"j_SMC_Delete_Semaphore_3");
//	MakeName	(0XFFFFFFFF,	"j_msc2_free_1");:0xfffffff:0xfffffff
	MakeName	(0x1057215c,	"registerNotifyCb");
//	MakeName	(0XFFFFFFFF,	"j_j_free");:0xfffffff:0x100004c0
	MakeName	(0x1058512c,	"j_j_free_15");
//	MakeName	(0XFFFFFFFF,	"j_j_free_17");:0xfffffff:0x10585948
//	MakeName	(0XFFFFFFFF,	"j_j_free_18");:0xfffffff:0x10585948
//	MakeName	(0XFFFFFFFF,	"j_j_free_19");:0xfffffff:0x10585948
//	MakeName	(0XFFFFFFFF,	"j_j_free_20");:0xfffffff:0x10585948
//	MakeName	(0XFFFFFFFF,	"j_j_free_23");:0xfffffff:0x10585948
	MakeName	(0x10597314,	"ascii2utf16_with_alloc");
	MakeName	(0x105b5508,	"string_free_0");
	MakeName	(0x105b554c,	"j_string_new_1");
	MakeName	(0x105dc3e8,	"show_dialog_box?");
	MakeName	(0x105f4f9c,	"_show_2NumericInput");
	MakeName	(0x105f54a8,	"_show_1NumericInput");
	MakeName	(0x105f58a8,	"TI_DM_1NumericInput_System");
//	MakeName	(0XFFFFFFFF,	"TI_DM_1NumericInput_PartialFunc");:0xfffffff:0x105f58a8
	MakeName	(0x105f5eb8,	"j_unknown_TI_ZIPArchive_Open");
	MakeName	(0x106163c8,	"__OS_drawProgramEditor");
	MakeName	(0x10652f2c,	"getfunc");
	MakeName	(0x106c0970,	"j_string_concat_utf16");
//	MakeName	(0XFFFFFFFF,	"j_string_str");:0xfffffff:0x100c59c8
//	MakeName	(0XFFFFFFFF,	"j_string_free");:0xfffffff:0x10000001
//	MakeName	(0XFFFFFFFF,	"j_string_new");:0xfffffff:0x10000001
//	MakeName	(0XFFFFFFFF,	"j_msc2_free_2");:0xfffffff:0x10000001
	MakeName	(0x10805510,	"j_SMC_Delete_Semaphore_4");
	MakeName	(0x10807f18,	"getcurrenv");
	MakeName	(0x10807f64,	"lua_xmove");
	MakeName	(0x10808020,	"lua_setlevel");
	MakeName	(0x1080802c,	"lua_atpanic");
	MakeName	(0x1080803c,	"lua_gettop");
	MakeName	(0x10808050,	"lua_settop");
	MakeName	(0x108080ac,	"lua_remove");
	MakeName	(0x108080fc,	"lua_insert");
	MakeName	(0x108081ac,	"lua_pushvalue");
	MakeName	(0x108081dc,	"lua_type");
	MakeName	(0x108081fc,	"lua_typename");
	MakeName	(0x10808218,	"lua_iscfunction");
	MakeName	(0x10808244,	"lua_isstring");
	MakeName	(0x10808260,	"lua_isuserdata");
	MakeName	(0x108082b4,	"lua_tocfunction");
	MakeName	(0x108082e8,	"lua_touserdata");
	MakeName	(0x10808318,	"lua_tothread");
	MakeName	(0x10808334,	"lua_topointer");
	MakeName	(0x10808394,	"lua_pushnil");
	MakeName	(0x108083b0,	"lua_pushnumber");
	MakeName	(0x108083d0,	"lua_pushinteger");
	MakeName	(0x10808400,	"lua_pushboolean");
	MakeName	(0x10808428,	"lua_pushlightuserdata");
	MakeName	(0x10808448,	"lua_pushthread");
	MakeName	(0x1080847c,	"lua_getmetatable");
	MakeName	(0x108084e8,	"lua_getfenv");
	MakeName	(0x10808728,	"lua_setfenv");
	MakeName	(0x108087e0,	"lua_newuserdata");
	MakeName	(0x10808840,	"lua_concat");
//	MakeName	(0XFFFFFFFF,	"lua_pushlstring");:0x108088dc:0x10809058
	MakeName	(0x1080893c,	"lua_next");
	MakeName	(0x1080897c,	"lua_error");
	MakeName	(0x1080898c,	"lua_gc");
	MakeName	(0x10808a80,	"lua_dump");
	MakeName	(0x10808ad0,	"lua_load");
	MakeName	(0x10808b1c,	"lua_cpcall");
	MakeName	(0x10808b58,	"lua_pcall");
	MakeName	(0x10808be0,	"lua_pushcclosure");
	MakeName	(0x10808cf4,	"f_Ccall");
	MakeName	(0x10808d70,	"lua_call");
	MakeName	(0x10808dac,	"lua_setmetatable");
	MakeName	(0x10808e6c,	"lua_rawseti");
	MakeName	(0x10808efc,	"lua_rawset");
	MakeName	(0x10808f88,	"lua_pushstring");
	MakeName	(0x10808fbc,	"lua_setfield");
	MakeName	(0x10809024,	"lua_settable");
//	MakeName	(0XFFFFFFFF,	"lua_createtable");:0x108088dc:0x10809058
	MakeName	(0x108090b8,	"lua_rawgeti");
	MakeName	(0x108090f8,	"lua_rawget");
	MakeName	(0x1080912c,	"lua_getfield");
	MakeName	(0x10809190,	"lua_gettable");
	MakeName	(0x108091b8,	"lua_pushvfstring");
	MakeName	(0x108091f4,	"lua_pushfstring");
	MakeName	(0x10809244,	"lua_objlen");
	MakeName	(0x108092bc,	"lua_tolstring");
	MakeName	(0x10809348,	"lua_tointeger");
	MakeName	(0x10809388,	"lua_tonumber");
	MakeName	(0x108093c8,	"lua_isnumber");
	MakeName	(0x108093fc,	"lua_lessthan");
	MakeName	(0x10809450,	"lua_equal");
	MakeName	(0x108094bc,	"lua_rawequal");
	MakeName	(0x1080950c,	"lua_replace");
	MakeName	(0x10809610,	"lua_newthread");
	MakeName	(0x10809658,	"lua_checkstack");
	MakeName	(0x108096d4,	"libsize");
	MakeName	(0x108096fc,	"luaL_buffinit");
	MakeName	(0x10809714,	"getS");
	MakeName	(0x10809730,	"luaL_newstate");
	MakeName	(0x10809760,	"Lua_unprotected_error");
	MakeName	(0x10809790,	"l_alloc");
	MakeName	(0x108097bc,	"luaL_loadbuffer");
	MakeName	(0x108097e0,	"luaL_loadstring");
	MakeName	(0x1080980c,	"emptybuffer");
	MakeName	(0x1080984c,	"errfile");
	MakeName	(0x108098b4,	"luaL_loadfile");
	MakeName	(0x10809b08,	"getF");
	MakeName	(0x10809b88,	"luaL_unref");
	MakeName	(0x10809c04,	"luaL_ref");
	MakeName	(0x10809ce0,	"adjuststack");
	MakeName	(0x10809d6c,	"luaL_addvalue");
	MakeName	(0x10809e0c,	"luaL_prepbuffer");
	MakeName	(0x10809e30,	"luaL_addlstring");
	MakeName	(0x10809f70,	"luaL_addstring");
	MakeName	(0x10809f98,	"luaL_pushresult");
	MakeName	(0x10809fbc,	"luaL_findtable");
	MakeName	(0x1080a0c8,	"luaL_gsub");
	MakeName	(0x1080a184,	"luaL_newmetatable");
	MakeName	(0x1080a1f8,	"luaL_getmetafield");
	MakeName	(0x1080a264,	"luaL_callmeta");
	MakeName	(0x1080a2e0,	"luaL_where");
	MakeName	(0x1080a378,	"luaL_error");
	MakeName	(0x1080a3cc,	"luaI_openlib");
	MakeName	(0x1080a578,	"luaL_register");
	MakeName	(0x1080a580,	"luaL_checkstack");
	MakeName	(0x1080a5b0,	"luaL_argerror");
	MakeName	(0x1080a6a4,	"luaL_checkany");
	MakeName	(0x1080a6d4,	"luaL_typerror");
	MakeName	(0x1080a720,	"tag_error");
	MakeName	(0x1080a748,	"luaL_checkinteger");
	MakeName	(0x1080a794,	"luaL_optinteger");
	MakeName	(0x1080a7c8,	"luaL_checknumber");
	MakeName	(0x1080a830,	"luaL_optnumber");
	MakeName	(0x1080a86c,	"luaL_checklstring");
	MakeName	(0x1080a8a4,	"luaL_optlstring");
	MakeName	(0x1080a900,	"luaL_checktype");
	MakeName	(0x1080a930,	"luaL_checkudata");
	MakeName	(0x1080a9bc,	"luaL_checkoption");
	MakeName	(0x1080aa50,	"luaB_print");
	MakeName	(0x1080aa58,	"luaB_yield");
	MakeName	(0x1080aa74,	"lua_status");
	MakeName	(0x1080ab08,	"luaL_auxresume");
	MakeName	(0x1080ac08,	"luaB_auxwrap");
	MakeName	(0x1080ac94,	"luaB_costatus");
	MakeName	(0x1080acec,	"luaB_corunning");
	MakeName	(0x1080ad10,	"load_aux");
	MakeName	(0x1080ad3c,	"luaB_coresume");
	MakeName	(0x1080adcc,	"luaB_cocreate");
	MakeName	(0x1080ae40,	"luaB_cowrap");
	MakeName	(0x1080ae68,	"auxopen");
	MakeName	(0x1080aea8,	"base_open");
	MakeName	(0x1080afd0,	"luaopen_base");
	MakeName	(0x1080affc,	"luaB_pcall");
	MakeName	(0x1080b050,	"luaB_xpcall");
	MakeName	(0x1080b0b4,	"luaB_pairs");
	MakeName	(0x1080b0f4,	"luaB_error");
	MakeName	(0x1080b164,	"luaB_unpack");
	MakeName	(0x1080b288,	"luaB_type");
	MakeName	(0x1080b2c4,	"luaB_tostring");
	MakeName	(0x1080b3e0,	"luaB_tonumber");
	MakeName	(0x1080b4fc,	"luaB_setmetatable");
	MakeName	(0x1080b6c8,	"luaB_setfenv");
	MakeName	(0x1080b7a8,	"luaB_select");
	MakeName	(0x1080b84c,	"ipairsaux");
	MakeName	(0x1080b8ac,	"luaB_ipairs");
	MakeName	(0x1080b8f0,	"luaB_rawset");
	MakeName	(0x1080b93c,	"luaB_rawget");
	MakeName	(0x1080b97c,	"luaB_rawequal");
	MakeName	(0x1080b9bc,	"luaB_assert");
	MakeName	(0x1080ba18,	"luaB_loadstring");
	MakeName	(0x1080ba70,	"luaB_load");
	MakeName	(0x1080bad4,	"generic_reader");
	MakeName	(0x1080bb70,	"luaB_getmetatable");
	MakeName	(0x1080bbc0,	"luaB_getfenv");
	MakeName	(0x1080bc10,	"luaB_gcinfo");
	MakeName	(0x1080bc38,	"luaB_collectgarbage");
	MakeName	(0x1080bd34,	"luaB_newproxy");
	MakeName	(0x1080be3c,	"luaB_next");
	MakeName	(0x1080be84,	"currentpc");
	MakeName	(0x1080bedc,	"currentline");
	MakeName	(0x1080bf58,	"lua_getstack");
	MakeName	(0x1080bff4,	"getluaproto");
	MakeName	(0x1080c838,	"kname");
	MakeName	(0x1080c870,	"isinstack");
	MakeName	(0x1080c8d4,	"info_tailcall");
	MakeName	(0x1080c92c,	"funcinfo");
	MakeName	(0x1080ca6c,	"luaG_errormsg");
	MakeName	(0x1080cb14,	"luaG_runerror");
	MakeName	(0x1080cb5c,	"luaG_ordererror");
	MakeName	(0x1080cbb0,	"getobjname");
	MakeName	(0x1080cd38,	"luaG_typeerror");
	MakeName	(0x1080ce3c,	"getfuncname");
	MakeName	(0x1080cef8,	"auxgetinfo");
	MakeName	(0x1080d0c4,	"findlocal");
	MakeName	(0x1080d1ac,	"collectvalidlines");
	MakeName	(0x1080d26c,	"lua_getinfo");
	MakeName	(0x1080d5e0,	"lua_yield");
	MakeName	(0x1080d624,	"luaD_seterrorobj");
	MakeName	(0x1080d750,	"restore_stack_limit");
	MakeName	(0x1080d784,	"resetstack");
	MakeName	(0x1080ddf0,	"luaD_rawrunprotected");
	MakeName	(0x1080de54,	"luaD_pcall");
	MakeName	(0x1080dfb8,	"lua_resume");
	MakeName	(0x1080e398,	"resume");
	MakeName	(0x1080e438,	"luaD_call");
	MakeName	(0x1080ec44,	"luaF_getlocalname");
	MakeName	(0x1080f078,	"luaF_newCclosure");
	MakeName	(0x1080f0c8,	"luaF_close");
	MakeName	(0x1080fa94,	"luaC_separateudata");
	MakeName	(0x10810960,	"luaopen_math");
	MakeName	(0x108114b4,	"luaM_realloc_");
	MakeName	(0x108115dc,	"load_lua_libs");
	MakeName	(0x108119c4,	"luaO_rawequalObj");
	MakeName	(0x10811a4c,	"luaO_chunkid");
	MakeName	(0x10814b14,	"preinit_state");
	MakeName	(0x10814bac,	"close_state");
	MakeName	(0x10814c2c,	"lua_close");
	MakeName	(0x10814ca0,	"lua_newstate");
	MakeName	(0x10814dc4,	"stack_init");
	MakeName	(0x10814ea0,	"callallgcTM");
	MakeName	(0x10814ea4,	"f_luaopen");
	MakeName	(0x10814f3c,	"luaE_newthread");
	MakeName	(0x10814fb4,	"luaS_newudata");
	MakeName	(0x1081502c,	"luaS_resize");
	MakeName	(0x10815224,	"l_setbit");
	MakeName	(0x10816084,	"lua_toboolean");
	MakeName	(0x10817048,	"scanformat");
	MakeName	(0x10817628,	"luaopen_string");
	MakeName	(0x10818884,	"sethvalue");
	MakeName	(0x10818908,	"luaopen_table");
	MakeName	(0x108195b8,	"luaT_init");
	MakeName	(0x1081a84c,	"luaV_lessthan");
	MakeName	(0x1081a97c,	"luaV_equalval");
	MakeName	(0x1081aa6c,	"luaV_settable");
	MakeName	(0x1081aca0,	"luaV_gettable");
	MakeName	(0x1081b350,	"tonumber");
	MakeName	(0x1081fad8,	"luaX_init");
//	MakeName	(0XFFFFFFFF,	"j_unknown_TI_AllocateBlock_");:0xfffffff:0x108e9244
	MakeName	(0x108e951c,	"j_j_free_21");
//	MakeName	(0XFFFFFFFF,	"_show_msgUserInput");:0xfffffff:0x10001b28
	MakeName	(0x108f0a34,	"lua_var_recall");
	MakeName	(0x1091ea4c,	"j_strncpy");
	MakeName	(0x1093c464,	"j_j_free_22");
	MakeName	(0x1093fea8,	"j_j_j_free_24");
	MakeName	(0x10942544,	"isprint");
//	MakeName	(0XFFFFFFFF,	"j_SMC_Delete_Semaphore_6");:0xfffffff:0x102c0351
//	MakeName	(0XFFFFFFFF,	"j_msc2_free_4");:0xfffffff:0x102c0351
	MakeName	(0x10959d60,	"j_j_free_25");
	MakeName	(0x10959d64,	"j_unknown_TI_AllocateBlock__0");
	MakeName	(0x10986bcc,	"lua_math__evalexpr");
	MakeName	(0x109a5834,	"j_j_free_26");
	MakeName	(0x109a8a00,	"j_j_free_27");
	MakeName	(0x109a91d4,	"a84chdrvr");
	MakeName	(0x109a91e0,	"a84chuser");
	MakeName	(0x109a921c,	"a84cfuser");
	MakeName	(0x109a9228,	"a84cfdrvr");
	MakeName	(0x109ad2b8,	"a1_2_1");
//	MakeName	(0XFFFFFFFF,	"a02x02x02x02x02");:0x109ade7c:0x109ade80
	MakeName	(0x109ae400,	"a1_2");
	MakeName	(0x109ae420,	"a1_7");
	MakeName	(0x109ae430,	"a64");
//	MakeName	(0XFFFFFFFF,	"a8_0");:0xfffffff:0x109c84cc
	MakeName	(0x109ae44c,	"a0_95");
//	MakeName	(0XFFFFFFFF,	"a7");:0xfffffff:0x109b7da4
	MakeName	(0x109af264,	"a10");
	MakeName	(0x109af26c,	"a11");
	MakeName	(0x109af274,	"a12_3");
	MakeName	(0x109af27c,	"a16");
	MakeName	(0x109af284,	"a24");
	MakeName	(0x109af2e8,	"a_bmp");
	MakeName	(0x109af664,	"a30sD");
	MakeName	(0x109af678,	"a30sS");
	MakeName	(0x109af68c,	"a30sD_D_D_D");
	MakeName	(0x109af6a8,	"a30s0x08x");
	MakeName	(0x109af6c0,	"a30sXXXXXX");
//	MakeName	(0XFFFFFFFF,	"a8s25s3s");:0xfffffff:0x109c3e80
//	MakeName	(0XFFFFFFFF,	"a8s2d22s3d");:0xfffffff:0x109c3e80
	MakeName	(0x109b2578,	"a02x_0");
	MakeName	(0x109b267c,	"a02d02d02d_03d");
	MakeName	(0x109b5b08,	"a0x02x0x02x0x02");
	MakeName	(0x109b7308,	"a_tns");
	MakeName	(0x109b7610,	"a031m");
	MakeName	(0x109b7618,	"a133m");
	MakeName	(0x109b7620,	"a037m");
	MakeName	(0x109b7628,	"a14533m");
	MakeName	(0x109b7634,	"a0m");
	MakeName	(0x109b8770,	"a0x");
	MakeName	(0x109b9188,	"a08u0c");
	MakeName	(0x109bcf14,	"a_ns_svc_");
//	MakeName	(0XFFFFFFFF,	"a0x02x");:0xfffffff:0xfffffff
//	MakeName	(0XFFFFFFFF,	"a0x08zx");:0xfffffff:0x109b1dbb
//	MakeName	(0XFFFFFFFF,	"a02x");:0xfffffff:0xfffffff
	MakeName	(0x109bee18,	"a_dylib");
	MakeName	(0x109c1658,	"a04xService");
	MakeName	(0x109c1ac4,	"a2_0_0");
	MakeName	(0x109c2a48,	"a0el");
	MakeName	(0x109c2aa8,	"a1keyword");
	MakeName	(0x109c355c,	"a1PinfoErrinfo_");
	MakeName	(0x109c3e78,	"a10000");
	MakeName	(0x109c3e80,	"a8s8sS");
	MakeName	(0x109c3e98,	"a8s08xS");
	MakeName	(0x109c3ed0,	"a8s3s3s6s");
	MakeName	(0x109c3ef4,	"a8s3s3d6s");
	MakeName	(0x109c3f08,	"a8s3s3d3s3d08x5");
	MakeName	(0x109c3f30,	"a8s3s3s3s3s8s5s");
	MakeName	(0x109c6a98,	"a2_10");
	MakeName	(0x109c7710,	"a2dEditorShould");
	MakeName	(0x109c777c,	"a0Status");
	MakeName	(0x109c77dc,	"a0");
	MakeName	(0x109c7bec,	"a1PerrinfoRterr");
	MakeName	(0x109c8fa4,	"a08x");
	MakeName	(0x109ce998,	"a1varstats");
	MakeName	(0x109ce9a4,	"a2varstats");
	MakeName	(0x109cf758,	"a1SelfErrinfo_r");
	MakeName	(0x109cf774,	"a2deditorIsNotU");
	MakeName	(0x109cfc48,	"a_ver");
	MakeName	(0x109cfc58,	"a_devmod");
	MakeName	(0x109cfc68,	"a_ffunc");
	MakeName	(0x109cfc78,	"a_debug");
	MakeName	(0x109cfc88,	"a_trace");
	MakeName	(0x109cfc90,	"a_gccol");
	MakeName	(0x109cfc98,	"a_gcp");
	MakeName	(0x109cfca0,	"a_gcsm");
	MakeName	(0x109cfca8,	"a_script");
//	MakeName	(0XFFFFFFFF,	"a_mem");:0xfffffff:0xfffffff
	MakeName	(0x109d0fa0,	"a_loaded");
	MakeName	(0x109ef624,	"a_l");
//	MakeName	(0XFFFFFFFF,	"a2_2");:0xfffffff:0xfffffff
//	MakeName	(0XFFFFFFFF,	"a2_3");:0xfffffff:0x10a2914a
//	MakeName	(0XFFFFFFFF,	"a3_0_0");:0xfffffff:0x10a2914a
	MakeName	(0x109f0a68,	"a_res");
//	MakeName	(0XFFFFFFFF,	"a13");:0xfffffff:0xfffffff
	MakeName	(0x109f1014,	"a3_0");
	MakeName	(0x109f1760,	"a_14r");
	MakeName	(0x109f1778,	"a_12f_0");
	MakeName	(0x109f1798,	"a00");
	MakeName	(0x109f179c,	"a0000_010_00_10");
	MakeName	(0x109f19d8,	"a0LengthRealloc");
	MakeName	(0x109f1b78,	"a0000xmnp");
	MakeName	(0x109f2b18,	"a1To5ColumnsSup");
	MakeName	(0x109f3ad4,	"a2dEditorPointe");
	MakeName	(0x109f8c70,	"a0123456789abcd");
	MakeName	(0x109f95b4,	"a2dEditorParent");
	MakeName	(0x109fae84,	"a0_0");
	MakeName	(0x109fe320,	"a_");
//	MakeName	(0XFFFFFFFF,	"a0_1");:0xfffffff:0xfffffff
//	MakeName	(0XFFFFFFFF,	"a9e999");:0xfffffff:0xfffffff
	MakeName	(0x10a00008,	"a255");
	MakeName	(0x10a00010,	"a31");
	MakeName	(0x109fb68c,	"a00_1");
	MakeName	(0x10a017fc,	"a12u");
	MakeName	(0x10a01db8,	"a02d02d02d02d_0");
	MakeName	(0x10a025e0,	"a02x02x02x02x_0");
	MakeName	(0x10a02c48,	"a10sSS");
	MakeName	(0x10a02c60,	"a10dSS");
	MakeName	(0x10a03108,	"odd_parity");
	MakeName	(0x10a0954c,	"a0_2");
//	MakeName	(0XFFFFFFFF,	"a_Tpconfig_gene");:0xfffffff:0x10a09d69
	MakeName	(0x10a0bd88,	"a2_1");
	MakeName	(0x10a0c1f8,	"a0_001");
	MakeName	(0x10a0c204,	"a0_1_0");
	MakeName	(0x10a0c20c,	"a14");
	MakeName	(0x10a0c398,	"a3dFunctionGrap");
	MakeName	(0x10a0c3c4,	"a3dParametricGr");
	MakeName	(0x10a0c3f4,	"a3dScatterPlotG");
	MakeName	(0x10a0c6ac,	"a0_1_");
	MakeName	(0x10a0daa8,	"a5");
	MakeName	(0x10a0f910,	"a3dgraphingview");
	MakeName	(0x10a0f9c0,	"a3dgraphingvi_0");
	MakeName	(0x10a0fa58,	"a3dfunction");
	MakeName	(0x10a0fd3c,	"a3dgraphtype");
	MakeName	(0x10a11e00,	"a0Ls");
	MakeName	(0x10a11e0c,	"a1Ls");
	MakeName	(0x10a11e3c,	"a__");
	MakeName	(0x10a12e64,	"a_SummaryDBlock");
	MakeName	(0x10a12fbc,	"a_13e");
	MakeName	(0x10a12fc8,	"a_13f");
//	MakeName	(0XFFFFFFFF,	"a00000000000000");:0x109ac4ba:0x109ac4bc
	MakeName	(0x10a1d754,	"a0_");
	MakeName	(0x10a1f9c8,	"a02x02x02x02x_1");
	MakeName	(0x10a1f9e8,	"a29s17s3d3_2f3u");
	MakeName	(0x10a20580,	"a000000093701aa");
	MakeName	(0x10a20cc0,	"a_tno");
	MakeName	(0x10a20cc8,	"a_tnc");
	MakeName	(0x10a216fc,	"a35s02x02x02x02");
	MakeName	(0x10a21ad4,	"a02x02x02x02x_2");
	MakeName	(0x10a21af8,	"a0NspireCradleD");
	MakeName	(0x10a221ac,	"a0NspireUpgrade");
	MakeName	(0x10a22a2c,	"keywords_ini");
//	MakeName	(0XFFFFFFFF,	"a0123456789an_e");:0x10a259bc:0x10a25a54
//	MakeName	(0XFFFFFFFF,	"a0123456789an_0");:0x10a25a54:0x10a25a54
	MakeName	(0x10a25aa0,	"a0500");
	MakeName	(0x10a2d568,	"a02d02d02d02d02");
	MakeName	(0x10a2d7d4,	"a04d02d02d02d02");
	MakeName	(0x10a30620,	"a66666666666666");
	MakeName	(0x10a31824,	"a3des");
	MakeName	(0x10a31c14,	"a0x12");
	MakeName	(0x10a33348,	"a_Msg");
	MakeName	(0x10a34b24,	"a802_1xAuthenti");
	MakeName	(0x10a36be0,	"a84clk");
	MakeName	(0x10a36be8,	"a84cdrvsm");
	MakeName	(0x10a36bfc,	"a84chisr");
	MakeName	(0x10a36c10,	"a84chhisr");
	MakeName	(0x10a37428,	"a00000008");
	MakeName	(0x10a37434,	"a00000000002");
	MakeName	(0x10a37440,	"a8463847412");
	MakeName	(0x10a3755c,	"a02d");
	MakeName	(0x10a37570,	"a2d");
	MakeName	(0x10a380bc,	"a_3s_3s3d_2d_2d");
	MakeName	(0x10a386e8,	"a0123456789ab_2");
	MakeName	(0x10a386fc,	"a0123456789ab_3");
	MakeName	(0x10a388e0,	"a3u");
	MakeName	(0x10a388ec,	"a100_0");
	MakeName	(0x10a3914c,	"a2_10_1150_0");
	MakeName	(0x10a39308,	"a3u_0");
	MakeName	(0x10a3932c,	"a2_10_1150");
	MakeName	(0x10a3936c,	"a0123456789ab_4");
	MakeName	(0x10a39380,	"a0123456789ab_5");
	MakeName	(0x10a39910,	"a0123456789ab_0");
	MakeName	(0x10a39b7c,	"a_Lu");
//	MakeName	(0XFFFFFFFF,	"a9");:0xfffffff:0x10a39ce8
	MakeName	(0x10a39e40,	"a0123456789ab_6");
	MakeName	(0x10a39fd0,	"a09lu");
	MakeName	(0x10a3b9d8,	"a2csenc");
	MakeName	(0x10a3b9e0,	"a2ssenc");
	MakeName	(0x10a3b9e8,	"a2sch_a");
	MakeName	(0x10a3b9f0,	"a2sch_b");
	MakeName	(0x10a3b9f8,	"a2gsh_a");
	MakeName	(0x10a3ba00,	"a2gsh_b");
	MakeName	(0x10a3ba08,	"a2scmka");
	MakeName	(0x10a3ba10,	"a2scmkb");
	MakeName	(0x10a3ba18,	"a2scf_a");
	MakeName	(0x10a3ba20,	"a2scf_b");
	MakeName	(0x10a3ba28,	"a2scc_a");
	MakeName	(0x10a3ba30,	"a2scc_b");
	MakeName	(0x10a3ba38,	"a2scc_c");
	MakeName	(0x10a3ba40,	"a2scc_d");
	MakeName	(0x10a3ba48,	"a2gsv_a");
	MakeName	(0x10a3ba50,	"a2gsv_b");
	MakeName	(0x10a3ba58,	"a2gsf_a");
	MakeName	(0x10a3ba60,	"a2gsf_b");
	MakeName	(0x10a3ba68,	"a2gch_a");
	MakeName	(0x10a3ba70,	"a2gch_b");
	MakeName	(0x10a3ba78,	"a2gch_c");
	MakeName	(0x10a3ba80,	"a2ssh_a");
	MakeName	(0x10a3ba88,	"a2ssh_b");
	MakeName	(0x10a3ba90,	"a2gcmka");
	MakeName	(0x10a3ba98,	"a2ssv_a");
	MakeName	(0x10a3baa0,	"a2ssv_b");
	MakeName	(0x10a3baa8,	"a2ssv_c");
	MakeName	(0x10a3bab0,	"a2gcf_a");
	MakeName	(0x10a3bab8,	"a2gcf_b");
	MakeName	(0x10a3bac0,	"a2ssf_a");
	MakeName	(0x10a3bac8,	"a2ssf_b");
	MakeName	(0x10a3bad0,	"a2src_a");
	MakeName	(0x10a3bad8,	"a2src_b");
	MakeName	(0x10a3bae0,	"a2src_c");
	MakeName	(0x10a3bae8,	"a2src_d");
	MakeName	(0x10a3baf0,	"a2x9gsc");
	MakeName	(0x10a3baf8,	"a2x9gcc");
	MakeName	(0x10a3bb00,	"a3flush");
	MakeName	(0x10a3bb08,	"a3wch_a");
	MakeName	(0x10a3bb10,	"a3wch_b");
	MakeName	(0x10a3bb18,	"a3rsh_a");
	MakeName	(0x10a3bb20,	"a3rsh_b");
	MakeName	(0x10a3bb28,	"a3rsc_a");
	MakeName	(0x10a3bb30,	"a3rsc_b");
	MakeName	(0x10a3bb38,	"a3rskea");
	MakeName	(0x10a3bb40,	"a3rskeb");
	MakeName	(0x10a3bb48,	"a3rcr_a");
	MakeName	(0x10a3bb50,	"a3rcr_b");
	MakeName	(0x10a3bb58,	"a3rsd_a");
	MakeName	(0x10a3bb60,	"a3rsd_b");
	MakeName	(0x10a3bb68,	"a3wcc_a");
	MakeName	(0x10a3bb70,	"a3wcc_b");
	MakeName	(0x10a3bb78,	"a3wcc_c");
	MakeName	(0x10a3bb80,	"a3wcc_d");
	MakeName	(0x10a3bb88,	"a3wckea");
	MakeName	(0x10a3bb90,	"a3wckeb");
	MakeName	(0x10a3bb98,	"a3wcv_a");
	MakeName	(0x10a3bba0,	"a3wcv_b");
	MakeName	(0x10a3bba8,	"a3wccsa");
	MakeName	(0x10a3bbb0,	"a3wccsb");
	MakeName	(0x10a3bbb8,	"a3wfina");
	MakeName	(0x10a3bbc0,	"a3wfinb");
	MakeName	(0x10a3bbc8,	"a3rccsa");
	MakeName	(0x10a3bbd0,	"a3rccsb");
	MakeName	(0x10a3bbd8,	"a3rfina");
	MakeName	(0x10a3bbe0,	"a3rfinb");
	MakeName	(0x10a3bbe8,	"a3whr_a");
	MakeName	(0x10a3bbf0,	"a3whr_b");
	MakeName	(0x10a3bbf8,	"a3whr_c");
	MakeName	(0x10a3bc00,	"a3rch_a");
	MakeName	(0x10a3bc08,	"a3rch_b");
	MakeName	(0x10a3bc10,	"a3rch_c");
	MakeName	(0x10a3bc18,	"a3wsh_a");
	MakeName	(0x10a3bc20,	"a3wsh_b");
	MakeName	(0x10a3bc28,	"a3wsc_a");
	MakeName	(0x10a3bc30,	"a3wsc_b");
	MakeName	(0x10a3bc38,	"a3wskea");
	MakeName	(0x10a3bc40,	"a3wskeb");
	MakeName	(0x10a3bc48,	"a3wcr_a");
	MakeName	(0x10a3bc50,	"a3wcr_b");
	MakeName	(0x10a3bc58,	"a3wsd_a");
	MakeName	(0x10a3bc60,	"a3wsd_b");
	MakeName	(0x10a3bc68,	"a3rcc_a");
	MakeName	(0x10a3bc70,	"a3rcc_b");
	MakeName	(0x10a3bc78,	"a3rckea");
	MakeName	(0x10a3bc80,	"a3rckeb");
	MakeName	(0x10a3bc88,	"a3rcv_a");
	MakeName	(0x10a3bc90,	"a3rcv_b");
	MakeName	(0x10a3bc98,	"a23wcha");
	MakeName	(0x10a3bca0,	"a23wchb");
	MakeName	(0x10a3bca8,	"a23rsha");
	MakeName	(0x10a3bcb0,	"a23rcha");
	MakeName	(0x10a3bcb8,	"a23rchb");
	MakeName	(0x10a3c56c,	"a0Length");
	MakeName	(0x10a3cac8,	"a0001");
	MakeName	(0x10a3e368,	"a0parvtxx");
	MakeName	(0x10a3e37c,	"a0parvtxy");
	MakeName	(0x10a3e390,	"a0parstdx");
	MakeName	(0x10a3e3a4,	"a0parstdy");
	MakeName	(0x10a3e3b8,	"a0circlegraphic");
	MakeName	(0x10a3e3e4,	"a0circlegraph_0");
	MakeName	(0x10a3e408,	"a0ellipsecenter");
	MakeName	(0x10a3e428,	"a0hyperbolaew");
	MakeName	(0x10a3e444,	"a0hyperbolans");
	MakeName	(0x10a3e460,	"a0conicgeneral");
	MakeName	(0x10a3e47c,	"a0lineslopeinte");
	MakeName	(0x10a3e4a4,	"a0linevertical");
	MakeName	(0x10a3e4c0,	"a0linestandard");
	MakeName	(0x10a3e4e0,	"a1keyword1keywo");
	MakeName	(0x10a3f5b0,	"a0Buffersize");
	MakeName	(0x10a3f8a8,	"a1D2editor_fm_t");
	MakeName	(0x10a41aa4,	"a0abs");
	MakeName	(0x10a41ab0,	"a0deriv");
	MakeName	(0x10a41ac0,	"a0fraction");
	MakeName	(0x10a41ad4,	"a0integral");
	MakeName	(0x10a41ae8,	"a0limit");
	MakeName	(0x10a41af8,	"a0logn");
	MakeName	(0x10a41b04,	"a0nroot");
	MakeName	(0x10a41b14,	"a0piecewise");
	MakeName	(0x10a41b2c,	"a0power");
	MakeName	(0x10a41b3c,	"a0product");
	MakeName	(0x10a41b50,	"a0sqrt");
	MakeName	(0x10a41b5c,	"a0sum");
	MakeName	(0x10a41b68,	"a0system");
	MakeName	(0x10a41b78,	"a0dms");
	MakeName	(0x10a41d00,	"a0PnodepoolNfre");
	MakeName	(0x10a41da8,	"a0Uintptr_tPnod");
	MakeName	(0x10a43328,	"a1angle");
	MakeName	(0x10a43388,	"a0Switchw");
	MakeName	(0x10a434a4,	"a1circle");
	MakeName	(0x10a435ac,	"a2Y");
	MakeName	(0x10a435c0,	"a2_4");
	MakeName	(0x10a435d0,	"a2");
	MakeName	(0x10a43784,	"a0_6");
	MakeName	(0x10a438cc,	"a0comment");
	MakeName	(0x10a43cc8,	"a1ArgcArgc3");
	MakeName	(0x10a43fd8,	"a1doc");
	MakeName	(0x10a44248,	"a0el_0");
	MakeName	(0x10a4527c,	"a0func");
	MakeName	(0x10a453e4,	"a0gray");
	MakeName	(0x10a4596c,	"a1keyword_0");
	MakeName	(0x10a45b94,	"a1line");
	MakeName	(0x10a45fc0,	"a1lineseg");
	MakeName	(0x10a460d0,	"a0list");
	MakeName	(0x10a46318,	"a0mathsubscript");
	MakeName	(0x10a46628,	"a0matrix");
	MakeName	(0x10a46c50,	"a0mline");
	MakeName	(0x10a46f2c,	"a0mlstatement");
	MakeName	(0x10a476c0,	"a1para");
	MakeName	(0x10a47a7c,	"a0paren");
	MakeName	(0x10a47d0c,	"a0prgm");
	MakeName	(0x10a47f48,	"a0WcscmpGetcstr");
	MakeName	(0x10a48040,	"a0WcscmpGetcs_0");
	MakeName	(0x10a48278,	"a1ray");
	MakeName	(0x10a48380,	"a1rtline");
	MakeName	(0x10a48968,	"a1rtri");
	MakeName	(0x10a48b60,	"a1subhead");
	MakeName	(0x10a48c70,	"a1subscrp");
	MakeName	(0x10a48e98,	"a1supersc");
	MakeName	(0x10a490dc,	"a1_1");
	MakeName	(0x10a490e4,	"a0text");
	MakeName	(0x10a49600,	"a1title");
	MakeName	(0x10a49704,	"a1tri");
	MakeName	(0x10a49808,	"a1vector");
	MakeName	(0x10a49910,	"a1widgetnode");
	MakeName	(0x10a49fc0,	"a1word");
	MakeName	(0x10a4b594,	"a2_5");
	MakeName	(0x10a4b5a4,	"a2Y_0");
	MakeName	(0x10a4b5bc,	"a2Y_1");
	MakeName	(0x10a4b5d4,	"a2X");
	MakeName	(0x10a4b60c,	"a2_6");
	MakeName	(0x10a4b61c,	"a21");
	MakeName	(0x10a4ef94,	"a4BitAsyncIrqMo");
	MakeName	(0x10a4f404,	"a802_3AmsduFram");
	MakeName	(0x10a51300,	"a0123456789ab_7");
	MakeName	(0x10a5240c,	"a2_1_0");
	MakeName	(0x10a5281c,	"a1mbps");
	MakeName	(0x10a52828,	"a2mbps");
	MakeName	(0x10a52834,	"a5_5mbps");
	MakeName	(0x10a52840,	"a11mbps");
	MakeName	(0x10a5284c,	"a6mbps");
	MakeName	(0x10a52858,	"a9mbps");
	MakeName	(0x10a52864,	"a12mbps");
	MakeName	(0x10a52870,	"a18mbps");
	MakeName	(0x10a5287c,	"a24mbps");
	MakeName	(0x10a52888,	"a36mbps");
	MakeName	(0x10a52894,	"a48mbps");
	MakeName	(0x10a528a0,	"a54mbps");
	MakeName	(0x10a53530,	"a2_2x");
	MakeName	(0x10a53560,	"a2_2x2_2x2_2x2_");
	MakeName	(0x10a53d14,	"a_kernelalloc");
	MakeName	(0x10a53d34,	"a_kernelallocir");
	MakeName	(0x10a53d58,	"a_kernelfree");
	MakeName	(0x10a53d7c,	"a_kernelfreeirq");
	MakeName	(0x10a53dc0,	"a_sdio_busdrive");
	MakeName	(0x10a53dd8,	"a_sdio_busdri_0");
	MakeName	(0x10a53f50,	"a_kernelalloc_0");
	MakeName	(0x10a53f60,	"a_kernelfree_0");
	MakeName	(0x10a57158,	"a_res_0");
	MakeName	(0x10a5718c,	"a2dtemplates");
	MakeName	(0x10a58a1c,	"a0S");
	MakeName	(0x10a58a20,	"a1S");
	MakeName	(0x10a5c8a4,	"a0123456789");
	MakeName	(0x10a5c8bc,	"a_E");
	MakeName	(0x10a5c8c8,	"a_G");
	MakeName	(0x10a5c8d4,	"a_F");
	MakeName	(0x10a5c95c,	"a_F_0");
	MakeName	(0x10a5ccd0,	"a1_3");
//	MakeName	(0XFFFFFFFF,	"a012345");:0x10a5ccdc:0x10a5cd58
	MakeName	(0x10a5cd20,	"a01245");
//	MakeName	(0XFFFFFFFF,	"a01234567");:0x10a5ccdc:0x10a5cd58
	MakeName	(0x10a5cdb4,	"a0134678");
//	MakeName	(0XFFFFFFFF,	"a012345678");:0x10a5ccdc:0x10a5cd58
	MakeName	(0x10a5ce6c,	"a01234");
	MakeName	(0x10a5cea4,	"a0123");
	MakeName	(0x10a5d17c,	"a9876_54321");
	MakeName	(0x10a5d23c,	"a_2f");
	MakeName	(0x10a5d788,	"a2ndParameterIs");
//	MakeName	(0XFFFFFFFF,	"a3_10_0");:0xfffffff:0xfffffff
	MakeName	(0x10a5f440,	"a_0f");
	MakeName	(0x10a5f44c,	"a_11e");
	MakeName	(0x10a5f458,	"a_11f");
	MakeName	(0x10a61dd4,	"a_SetPickypix_0");
	MakeName	(0x10a61e54,	"a_SetPickypixel");
//	MakeName	(0XFFFFFFFF,	"a8");:0xfffffff:0x109c84cc
	MakeName	(0x10a63294,	"a0__0");
	MakeName	(0x10a6329c,	"a0_3");
	MakeName	(0x10a632a4,	"a0_0_0");
	MakeName	(0x10a632b0,	"a00_0");
	MakeName	(0x10a632f8,	"a1_X");
	MakeName	(0x10a63304,	"a1_9");
	MakeName	(0x10a63310,	"a1_Y");
	MakeName	(0x10a6331c,	"a0_8");
	MakeName	(0x10a6335c,	"a1X_1");
	MakeName	(0x10a63364,	"a1_X_0");
	MakeName	(0x10a63370,	"a1Y");
	MakeName	(0x10a63378,	"a1_Y_0");
	MakeName	(0x10a63384,	"a0XY");
	MakeName	(0x10a63394,	"a0X2");
	MakeName	(0x10a633a4,	"a0Y2");
	MakeName	(0x10a633b4,	"a0X_0");
	MakeName	(0x10a633c0,	"a0Y");
	MakeName	(0x10a633cc,	"a0XY_0");
	MakeName	(0x10a633dc,	"a0X2_0");
	MakeName	(0x10a633ec,	"a0Y2_0");
	MakeName	(0x10a633fc,	"a0X_1");
	MakeName	(0x10a63408,	"a0Y_0");
	MakeName	(0x10a63414,	"a0XY_1");
	MakeName	(0x10a63424,	"a0X2_1");
	MakeName	(0x10a63434,	"a0Y2_1");
	MakeName	(0x10a63444,	"a0X");
	MakeName	(0x10a63450,	"a0Y_1");
	MakeName	(0x10a6345c,	"a0_XY");
	MakeName	(0x10a6346c,	"a0_X2");
	MakeName	(0x10a6347c,	"a0_Y2");
	MakeName	(0x10a6348c,	"a0_X");
	MakeName	(0x10a63498,	"a0_Y");
	MakeName	(0x10a634a4,	"a0_XY_0");
	MakeName	(0x10a634b4,	"a0_X2_0");
	MakeName	(0x10a634c4,	"a0_Y2_0");
	MakeName	(0x10a634d4,	"a0_X_0");
	MakeName	(0x10a634e0,	"a0_Y_0");
	MakeName	(0x10a634ec,	"a0_XY_1");
	MakeName	(0x10a634fc,	"a0_X_1");
	MakeName	(0x10a63504,	"a2_7");
	MakeName	(0x10a6350c,	"a0_Y2_1");
	MakeName	(0x10a6351c,	"a0__1");
	MakeName	(0x10a63528,	"a0_Y_1");
	MakeName	(0x10a63534,	"a0_9");
	MakeName	(0x10a63540,	"a0__2");
	MakeName	(0x10a6354c,	"a1_10");
	MakeName	(0x10a6355c,	"a1_11");
	MakeName	(0x10a63564,	"a1_12");
	MakeName	(0x10a6356c,	"a1_13");
	MakeName	(0x10a63574,	"a1_14");
	MakeName	(0x10a6358c,	"a0X2_2");
	MakeName	(0x10a63598,	"a0X_2");
	MakeName	(0x10a635a0,	"a0Y2_2");
	MakeName	(0x10a635ac,	"a0Y_2");
	MakeName	(0x10a635b4,	"a0XY_2");
	MakeName	(0x10a635c0,	"a0_10");
	MakeName	(0x10a635d0,	"a0_11");
	MakeName	(0x10a635dc,	"a0_12");
	MakeName	(0x10a635ec,	"a0_14");
	MakeName	(0x10a635f8,	"a0XY_3");
	MakeName	(0x10a63c30,	"a4Tstep5");
	MakeName	(0x10a63c54,	"a2_11");
	MakeName	(0x10a63d08,	"a6_28");
	MakeName	(0x10a63d14,	"a0_13");
	MakeName	(0x10a644a4,	"a1_0");
//	MakeName	(0XFFFFFFFF,	"a0_4");:0xfffffff:0x109a9464
	MakeName	(0x10a68bd4,	"a5hds");
	MakeName	(0x10a6c568,	"a2du3");
	MakeName	(0x10a75e14,	"a0_0ThizMvunit");
	MakeName	(0x10a75e28,	"a0_0ThizMuunit");
	MakeName	(0x10a76c20,	"a_x");
	MakeName	(0x10a78e7c,	"a1_4");
	MakeName	(0x10a7c550,	"a_14g_0");
	MakeName	(0x10a7c98c,	"a1X");
	MakeName	(0x10a7d9f4,	"a2_9");
	MakeName	(0x10a7da08,	"a21_0");
	MakeName	(0x10a7da20,	"a2_8");
	MakeName	(0x10a7e970,	"a1_2_0");
//	MakeName	(0XFFFFFFFF,	"a2_0");:0xfffffff:0x10a7e988
	MakeName	(0x10a7e9a8,	"a12");
	MakeName	(0x10a7e9f4,	"a12_2");
	MakeName	(0x10a7ea28,	"a12345");
	MakeName	(0x10a7ea58,	"a1234");
	MakeName	(0x10a7ec80,	"a1");
	MakeName	(0x10a7ed54,	"a1_8");
	MakeName	(0x10a7ed64,	"a1X_0");
	MakeName	(0x10a7fa9c,	"a123");
	MakeName	(0x10a7fab0,	"a100");
	MakeName	(0x10a7fabc,	"a1X23");
	MakeName	(0x10a7fc38,	"a1Bound");
	MakeName	(0x10a7fc4c,	"a12_0");
	MakeName	(0x10a7fc60,	"a0X1_2");
	MakeName	(0x10a7fc88,	"a0X01");
	MakeName	(0x10a7fc9c,	"a0X1_21_3");
	MakeName	(0x10a7fcc8,	"a1_5");
	MakeName	(0x10a7fe30,	"a12_1");
	MakeName	(0x10a7feb4,	"a3");
	MakeName	(0x10a7fee4,	"a3Zzz_dummy2");
	MakeName	(0x10a8089c,	"a0X1");
	MakeName	(0x10a808b0,	"a0X21X2");
	MakeName	(0x10a808d8,	"a0X3");
	MakeName	(0x10a80910,	"a0X41X32X23X4");
	MakeName	(0x10a8095c,	"a0X1_0");
	MakeName	(0x10a8096c,	"a01X");
	MakeName	(0x10a8097c,	"a01LnX");
	MakeName	(0x10a80998,	"a0Sin1X23");
	MakeName	(0x10a8120c,	"a_12f");
	MakeName	(0x10a8407c,	"a_kernelfree_1");
	MakeName	(0x10a840bc,	"a_kernelalloc_1");
	MakeName	(0x10ab0154,	"a_g");
	MakeName	(0x10ab0160,	"a_version");
	MakeName	(0x10ab1034,	"a0_7");
	MakeName	(0x10ab1460,	"a_14g");
	MakeName	(0x10ab183c,	"a_error_");
	MakeName	(0x10ab184c,	"a0y");
	MakeName	(0x10ab1858,	"a0_14g");
	MakeName	(0x10ab5fd8,	"a0123456789ab_1");
	MakeName	(0x10ab7aec,	"a0_15");
	MakeName	(0x10ab7fb4,	"a08lx");
	MakeName	(0x10ab8270,	"a64Bytes");
	MakeName	(0x10ab828c,	"a64And128Bytes");
	MakeName	(0x10ab82a8,	"a128And256Bytes");
	MakeName	(0x10ab82c4,	"a256And512Bytes");
	MakeName	(0x10ab82e0,	"a512And1kBytes");
//	MakeName	(0XFFFFFFFF,	"a1kAnd2kBytes");:0x10ab82fc:0x10ab8318
//	MakeName	(0XFFFFFFFF,	"a2kAnd4kBytes");:0x10ab82fc:0x10ab8318
	MakeName	(0x10ab8334,	"a4kAnd8kBytes");
	MakeName	(0x10ab8350,	"a8kAnd16kBytes");
	MakeName	(0x10ab836c,	"a16kAnd32kBytes");
	MakeName	(0x10ab8388,	"a32kAnd64kBytes");
	MakeName	(0x10ab83a4,	"a64kAnd128kByte");
	MakeName	(0x10ab83c0,	"a128kAnd256kByt");
	MakeName	(0x10ab83dc,	"a256kBytes");
	MakeName	(0x10abeab4,	"a35maxtitle");
	MakeName	(0x10ac1518,	"a333333u333333u");
	MakeName	(0x10ac46f8,	"a333333u33333_1");
	MakeName	(0x10ac6110,	"a04d02d02d");
	MakeName	(0x10ac6834,	"a4u");
	MakeName	(0x10ac7094,	"a04lx");
	MakeName	(0x10ac709c,	"a4e00");
	MakeName	(0x10ac7290,	"a_wav");
//	MakeName	(0XFFFFFFFF,	"a_0123456789Abc");:0x10ac7a70:0x10ac7a70
	MakeName	(0x10ac86b4,	"a_htm");
	MakeName	(0x10ac8868,	"a20902OriginalU");
	MakeName	(0x10ac888c,	"a15442CombinedG");
	MakeName	(0x10ac88b0,	"a13061FullFormB");
	MakeName	(0x10ac88d4,	"a6763SimpleForm");
	MakeName	(0x10ac88f8,	"a5411FullFormBi");
	MakeName	(0x10ac891c,	"a3755SimpleForm");
	MakeName	(0x10ac8b88,	"a01");
	MakeName	(0x10ac8b8c,	"a100_2");
	MakeName	(0x10ac8b90,	"a101");
	MakeName	(0x10ac9054,	"a1st");
	MakeName	(0x10ac9058,	"a2nd");
	MakeName	(0x10ac905c,	"a3rd");
	MakeName	(0x10ac9060,	"a4th");
	MakeName	(0x10ac909c,	"a_60s_60s_60s");
	MakeName	(0x10ac9578,	"a_kernelfree_2");
	MakeName	(0x10ac959c,	"a_kernelalloc_2");
	MakeName	(0x10ac95d0,	"a_kernelfree_3");
	MakeName	(0x10ac95dc,	"a_deletemessage");
	MakeName	(0x10ac95f0,	"a_kernelalloc_3");
	MakeName	(0x10ac9600,	"a_createmessage");
	MakeName	(0x10ac9614,	"a4_4x");
	MakeName	(0x10ac961c,	"a2_2x_0");
	MakeName	(0x10aca8f0,	"a100_1");
	MakeName	(0x10acad0c,	"a0_00000");
	MakeName	(0x10acad58,	"a02d02dAt02d02d");
	MakeName	(0x10acb4b8,	"a1_6");
//	MakeName	(0XFFFFFFFF,	"a0_5");:0xfffffff:0xfffffff
	MakeName	(0x10ace17c,	"a201010221712");
	MakeName	(0x10acea14,	"a0_16");
	MakeName	(0x10ad3a64,	"a201104131515");
	MakeName	(0x10b989a4,	"a201111141718");
//	MakeName	(0XFFFFFFFF,	"a201111141719");:0x10ba16ec:0x10bab66c
//	MakeName	(0XFFFFFFFF,	"a201111141719_0");:0x10ba16ec:0x10bab66c
//	MakeName	(0XFFFFFFFF,	"a201111141720");:0x10bb7acc:0x10bc55b8
//	MakeName	(0XFFFFFFFF,	"a201111141720_0");:0x10bb7acc:0x10bc55b8
	MakeName	(0x10bdb668,	"a201201031513");
	MakeName	(0x10c0f110,	"a201111141708");
	MakeName	(0x10c1868c,	"a201111141709");
//	MakeName	(0XFFFFFFFF,	"a201111141710");:0x10c22aac:0x10c2f80c
//	MakeName	(0XFFFFFFFF,	"a201111141710_0");:0x10c22aac:0x10c2f80c
//	MakeName	(0XFFFFFFFF,	"a201111141712");:0x10c3ded8:0x10c55568
//	MakeName	(0XFFFFFFFF,	"a201111141712_0");:0x10c3ded8:0x10c55568
//	MakeName	(0XFFFFFFFF,	"a201111141715");:0x10c8b278:0x10d4119c
//	MakeName	(0XFFFFFFFF,	"a201111141716");:0x10c950bc:0x10ca013c
	MakeName	(0x10c9c548,	"a_K");
	MakeName	(0x10c9ffb8,	"a0_17");
//	MakeName	(0XFFFFFFFF,	"a201111141716_0");:0x10c950bc:0x10ca013c
//	MakeName	(0XFFFFFFFF,	"a201111141717");:0x10cada6c:0x10cbc988
//	MakeName	(0XFFFFFFFF,	"a201111141717_0");:0x10cada6c:0x10cbc988
	MakeName	(0x10cd4c64,	"a201201031516");
	MakeName	(0x10cea8cc,	"a0_18");
//	MakeName	(0XFFFFFFFF,	"a201111141713");:0x10d0d5cc:0x10d1780c
//	MakeName	(0XFFFFFFFF,	"a201111141713_0");:0x10d0d5cc:0x10d1780c
//	MakeName	(0XFFFFFFFF,	"a201111141714");:0x10d22e6c:0x10d31204
//	MakeName	(0XFFFFFFFF,	"a201111141714_0");:0x10d22e6c:0x10d31204
//	MakeName	(0XFFFFFFFF,	"a201111141715_0");:0x10c8b278:0x10d4119c
	MakeName	(0x10d5abe8,	"a201111141715_1");
	MakeName	(0x10d96bb0,	"a201111141735");
	MakeName	(0x10d9d028,	"a201201311245");
	MakeName	(0x10da6408,	"a201111141732");
//	MakeName	(0XFFFFFFFF,	"a201111141733");:0x10db105c:0x10dbe53c
//	MakeName	(0XFFFFFFFF,	"a201111141733_0");:0x10db105c:0x10dbe53c
//	MakeName	(0XFFFFFFFF,	"a201111141733_1");:0x10db105c:0x10dbe53c
	MakeName	(0x10de54b4,	"a201111141734");
	MakeName	(0x10e1c458,	"a201111141721");
//	MakeName	(0XFFFFFFFF,	"a201111141723");:0x10e26458:0x10e31844
//	MakeName	(0XFFFFFFFF,	"a201111141723_0");:0x10e26458:0x10e31844
//	MakeName	(0XFFFFFFFF,	"a201111141724");:0x10e3f684:0x10e4e694
//	MakeName	(0XFFFFFFFF,	"a201111141724_0");:0x10e3f684:0x10e4e694
	MakeName	(0x10e6873c,	"a201111141725");
//	MakeName	(0XFFFFFFFF,	"a201111141729");:0x10ea2b48:0x10ead3a8
//	MakeName	(0XFFFFFFFF,	"a201111141729_0");:0x10ea2b48:0x10ead3a8
	MakeName	(0x10eb9580,	"a201201311243");
	MakeName	(0x10ec8018,	"a201111141730");
	MakeName	(0x10ed74b0,	"a201111141731");
	MakeName	(0x10ef2fd0,	"a201111141731_0");
	MakeName	(0x10f30434,	"a201111141726");
//	MakeName	(0XFFFFFFFF,	"a201111141727");:0x10f3b094:0x10f47680
//	MakeName	(0XFFFFFFFF,	"a201111141727_0");:0x10f3b094:0x10f47680
//	MakeName	(0XFFFFFFFF,	"a201111141727_1");:0x10f3b094:0x10f47680
	MakeName	(0x10f672c0,	"a201111141728");
	MakeName	(0x10f83f98,	"a201111141729_1");
	MakeName	(0x10fca93c,	"keypad_type");
//	MakeName	(0XFFFFFFFF,	"a1Byte");:0x10fdb550:0x10fdb790
//	MakeName	(0XFFFFFFFF,	"a10Bytes");:0x10fdb598:0x10fdb7d8
//	MakeName	(0XFFFFFFFF,	"a1Byte_0");:0x10fdb550:0x10fdb790
	MakeName	(0x10fe4fdc,	"a112204112915");
//	MakeName	(0XFFFFFFFF,	"a_TpbhnaMtBgn9v");:0x10ff821f:0x11024168
	MakeName	(0x1103526c,	"a1mL2mL2mS5mL5m");
	MakeName	(0x110352a4,	"a7d7d7d7d7d7d_0");
	MakeName	(0x1104a114,	"a04x___");
	MakeName	(0x1104a11c,	"a02x_1");
	MakeName	(0x1104a124,	"a02x_2");
	MakeName	(0x11076b3c,	"a2_12");
	MakeName	(0x11076b4a,	"a3_1");
	MakeName	(0x11076bd8,	"a4Nstep5");
	MakeName	(0x1107a478,	"a3p6pPapfpgpgph");
	MakeName	(0x1107b374,	"a_02468Bdfhj");
//	MakeName	(0XFFFFFFFF,	"gui_gc_global_GC_ptr");:0x10000000:0x10000001
//	MakeName	(0XFFFFFFFF,	"stdin");:0x10000000:0x10000001
//	MakeName	(0XFFFFFFFF,	"stdout");:0x10000000:0x10000001
//	MakeName	(0XFFFFFFFF,	"stderr");:0x10000000:0x10000001

}
