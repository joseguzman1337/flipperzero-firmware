#include <furi_hal_bt_serial.h>
#include <services/dev_info_service.h>
#include <services/battery_service.h>
#include <services/serial_service.h>

#include <furi.h>

static BleServiceDevInfo* dev_info_service = NULL;
static BleServiceBattery* battery_service = NULL;
static BleServiceSerial* serial_service = NULL;

void furi_hal_bt_serial_start() {
    // Start device info
    if(!dev_info_service) {
        dev_info_service = ble_svc_dev_info_start();
    }
    // Start battery service
    if(!battery_service) {
        battery_service = ble_svc_battery_start(true);
    }
    // Start Serial service
    if(!serial_service) {
        serial_service = ble_svc_serial_start();
    }
}

void furi_hal_bt_serial_set_event_callback(
    uint16_t buff_size,
    FuriHalBtSerialCallback callback,
    void* context) {
    if(serial_service) {
        ble_svc_serial_set_callbacks(serial_service, buff_size, callback, context);
    }
}

void furi_hal_bt_serial_notify_buffer_is_empty() {
    if(serial_service) {
        ble_svc_serial_notify_buffer_is_empty(serial_service);
    }
}

void furi_hal_bt_serial_set_rpc_status(FuriHalBtSerialRpcStatus status) {
    if(serial_service) {
        ble_svc_serial_set_rpc_active(serial_service, status == FuriHalBtSerialRpcStatusActive);
    }
}

bool furi_hal_bt_serial_tx(uint8_t* data, uint16_t size) {
    if(!serial_service) {
        return false;
    }
    if(size > FURI_HAL_BT_SERIAL_PACKET_SIZE_MAX) {
        return false;
    }
    return ble_svc_serial_update_tx(serial_service, data, size);
}

void furi_hal_bt_serial_stop() {
    // Stop all services
    if(serial_service) {
        ble_svc_serial_stop(serial_service);
        serial_service = NULL;
    }
    if(battery_service) {
        ble_svc_battery_stop(battery_service);
        battery_service = NULL;
    }
    if(dev_info_service) {
        ble_svc_dev_info_stop(dev_info_service);
        dev_info_service = NULL;
    }
}
