#ifndef NAVNET_H
#define NAVNET_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

#define DLLDECL __cdecl __declspec(dllimport)

typedef void *nn_ch_t;
typedef void *nn_nh_t;
typedef void *nn_oh_t;

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
DLLDECL int16_t TI_NN_PutFile(nn_nh_t nh, nn_oh_t oh, const char *local_path, const char *remote_path);

#ifdef __cplusplus
}
#endif

#endif
