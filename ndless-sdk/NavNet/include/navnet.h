#ifndef NAVNET_H
#define NAVNET_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

#define TI_NN_SERVICE_NULL 0x4001
#define TI_NN_SERVICE_ECHO 0x4002
#define TI_NN_SERVICE_ADDR 0x4003
#define TI_NN_SERVICE_TUNE 0x4004
#define TI_NN_DEVICE_INFO 0x4020
#define TI_NN_SCREEN_CAPTURE 0x4021
#define TI_NN_EVENT 0x4022
#define TI_NN_SHUTDOWN 0x4023
#define TI_NN_SCREEN_CAPTURE_RLE 0x4024
#define TI_NN_SERVICE_ACTIVITY 0x4041
#define TI_NN_SERVICE_TE_MLPDEV 0x4042
#define TI_NN_SERVICE_TE_RPC 0x4043
#define TI_NN_SERVICE_LOGIN 0x4050
#define TI_NN_SERVICE_MESSAGE 0x4051
#define TI_NN_SERVICE_HUB_CONNECTION 0x4054
#define TI_NN_SERVICE_SYNC 0x4060
#define TI_NN_SERVICE_INSTALLOS 0x4080
#define TI_NN_SERVICE_MHH 0x4090
#define TI_NN_SERVICE_EXTECHO 0x5000

#define DLLDECL __cdecl __declspec(dllimport)

struct _nn_ch;
typedef struct _nn_ch* nn_ch_t;
struct _nn_nh;
typedef struct _nn_nh* nn_nh_t;
struct _nn_oh;
typedef struct _nn_oh* nn_oh_t;

DLLDECL int16_t TI_NN_Init(const char *opts);
DLLDECL int16_t TI_NN_Shutdown(void);
DLLDECL nn_oh_t TI_NN_CreateOperationHandle(void);
DLLDECL int16_t TI_NN_DestroyOperationHandle(nn_oh_t oh);
DLLDECL int16_t TI_NN_NodeEnumInit(nn_oh_t oh);
DLLDECL int16_t TI_NN_NodeEnumNext(nn_oh_t oh, nn_nh_t *nh);
DLLDECL int16_t TI_NN_NodeEnumDone(nn_oh_t oh);
DLLDECL int16_t TI_NN_Connect(nn_nh_t nh, uint32_t service_id, nn_ch_t *ch);
DLLDECL int16_t TI_NN_Disconnect(nn_ch_t ch);
DLLDECL int16_t TI_NN_Write(nn_ch_t ch, void *buf, uint32_t data_size);
DLLDECL int16_t TI_NN_Read(nn_ch_t ch, uint32_t timeout_ms, void *buf, uint32_t buf_size, uint32_t *recv_size);
// unknown callback parameters
DLLDECL int16_t TI_NN_RegisterNotifyCallback(uint32_t filter_flags, void (*cb)(void));
DLLDECL uint32_t TI_NN_GetConnMaxPktSize(nn_ch_t ch);
DLLDECL int16_t TI_NN_StartService(uint32_t service_id, void *data, void (*cb)(nn_ch_t ch, void *data));
DLLDECL int16_t TI_NN_StopService(uint32_t service_id);
DLLDECL int16_t TI_NN_PutFile(nn_ch_t ch, nn_oh_t oh, const char *local_path, const char *remote_path);

#ifdef __cplusplus
}
#endif

#endif
