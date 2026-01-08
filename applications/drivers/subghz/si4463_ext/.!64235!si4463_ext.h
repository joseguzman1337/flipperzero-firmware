/**
 * @file furi_hal_subghz.h
 * SubGhz HAL API
 */

#pragma once

#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>
#include <toolbox/level_duration.h>
#include <furi_hal_gpio.h>
#include "driver/si446x_regs.h"

#ifdef __cplusplus
extern "C" {
#endif

/** Switchable Radio Paths */
typedef enum {
    SubGhzDeviceSi4463ExtPathIsolate, /**< Isolate Radio from antenna */
    SubGhzDeviceSi4463ExtPath433, /**< Center Frquency: 433MHz. Path 1: SW1RF1-SW2RF2, LCLCL */
    SubGhzDeviceSi4463ExtPath315, /**< Center Frquency: 315MHz. Path 2: SW1RF2-SW2RF1, LCLCLCL */
    SubGhzDeviceSi4463ExtPath868, /**< Center Frquency: 868MHz. Path 3: SW1RF3-SW2RF3, LCLC */
} SubGhzDeviceSi4463ExtPath;

/* Mirror RX/TX async modulation signal to specified pin
 *
 * @warning    Configures pin to output mode. Make sure it is not connected
 *             directly to power or ground.
 *
 * @param[in]  pin   pointer to the gpio pin structure or NULL to disable
 */
void subghz_device_si4463_ext_set_async_mirror_pin(const GpioPin* pin);

/** Get data GPIO
 *
 * @return     pointer to the gpio pin structure
 */
const GpioPin* subghz_device_si4463_ext_get_data_gpio(void);

/** Initialize device
 *
 * @return     true if success
 */
bool subghz_device_si4463_ext_alloc(void);

/** Deinitialize device
 */
void subghz_device_si4463_ext_free(void);

/** Check and switch to power save mode Used by internal API-HAL
 * initialization routine Can be used to reinitialize device to safe state and
 * send it to sleep
 */
bool subghz_device_si4463_ext_is_connect(void);

/** Send device to sleep mode
 */
void subghz_device_si4463_ext_sleep(void);

/** Dump info to stdout
 */
void subghz_device_si4463_ext_dump_state(void);

// /** Load registers from preset by preset name
//  *
//  * @param      preset  to load
//  */
// void subghz_device_si4463_ext_load_preset(FuriHalSubGhzPreset preset);

void subghz_device_si4463_ext_mod_gpio_for_async(SI446X_Prop_Modem_Mod_Type_t modulation);

void subghz_device_si4463_ext_load_config(const uint8_t config[]);

void subghz_device_si4463_set_pa(uint8_t pa);

// /** Load PATABLE
//  *
//  * @param      data  8 uint8_t values
//  */
// void subghz_device_si4463_ext_load_patable(const uint8_t data[8]);

/** Write packet to FIFO
 *
 * @param      data  bytes array
 * @param      size  size
 */
void subghz_device_si4463_ext_write_packet(const uint8_t* data, uint8_t size);

/** Check if recieve pipe is not empty
 *
 * @return     true if not empty
 */
bool subghz_device_si4463_ext_rx_pipe_not_empty(void);

/** Check if recieved data crc is valid
 *
 * @return     true if valid
 */
bool subghz_device_si4463_ext_is_rx_data_crc_valid(void);

/** Read packet from FIFO
 *
 * @param      data  pointer
 * @param      size  size
 */
void subghz_device_si4463_ext_read_packet(uint8_t* data, uint8_t* size);

/** Flush rx FIFO buffer
 */
void subghz_device_si4463_ext_flush_rx(void);

/** Flush tx FIFO buffer
 */
void subghz_device_si4463_ext_flush_tx(void);

/** Shutdown Issue spwd command
 * @warning    registers content will be lost
 */
void subghz_device_si4463_ext_shutdown(void);

/** Reset Issue reset command
 * @warning    registers content will be lost
 */
void subghz_device_si4463_ext_reset(void);

/** Switch to Idle
 */
void subghz_device_si4463_ext_idle(void);

/** Switch to Recieve
 */
void subghz_device_si4463_ext_rx(void);

/** Switch to Transmit
 *
 * @return     true if the transfer is allowed by belonging to the region
 */
bool subghz_device_si4463_ext_tx(void);

/** Get RSSI value in dBm
 *
 * @return     RSSI value
 */
float subghz_device_si4463_ext_get_rssi(void);

/** Get LQI
 *
 * @return     LQI value
 */
uint8_t subghz_device_si4463_ext_get_lqi(void);

bool subghz_device_si4463_ext_get_properties(SI446X_Prop_t prop, uint8_t* data, uint8_t size);
bool subghz_device_si4463_ext_set_properties(SI446X_Prop_t prop, uint8_t* data, uint8_t size);

/** Check if frequency is in valid range
 *
 * @param      value  frequency in Hz
 *
 * @return     true if frequncy is valid, otherwise false
 */
bool subghz_device_si4463_ext_is_frequency_valid(uint32_t value);

/** Set frequency and path This function automatically selects antenna matching
 * network
 *
 * @param      value  frequency in Hz
 *
 * @return     real frequency in herz
 */
uint32_t subghz_device_si4463_ext_set_frequency_and_path(uint32_t value);

