#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

uint8_t nfc_util_even_parity8(uint8_t data);

uint8_t nfc_util_even_parity32(uint32_t data);

uint8_t nfc_util_odd_parity8(uint8_t data);

void nfc_util_odd_parity(const uint8_t* src, uint8_t* dst, uint8_t len);

uint32_t nfc_util_bytes2num(const uint8_t* bytes, uint8_t len);
void nfc_util_num2bytes(uint32_t num, uint8_t len, uint8_t* bytes);

#ifdef __cplusplus
}
#endif
