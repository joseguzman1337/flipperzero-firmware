/**
 * @file nfc_generic_event.h
 * @brief Generic Nfc stack event definitions.
 *
 * Events are the main way of passing information about, well, various events
 * that occur across the Nfc protocol stack.
 *
 * In order to subscribe to events from a certain instance, the user code must call
 * its corresponding start() function while providing the appropriate callback.
 * During this call, an additional context pointer can be provided, which will be passed
 * to the context parameter at the time of the callback execution.
 *
 * For additional information on how events are passed around and processed, see protocol-specific
 * poller and listener implementations found in the respectively named subfolders.
 *
 */
#pragma once

// Upstream wrapper: delegate NFC generic event definitions to the enhanced
// Momentum implementation under lib/nfc.

#include <lib/nfc/protocols/nfc_generic_event.h>

