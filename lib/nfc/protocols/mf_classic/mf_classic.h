#pragma once

// Upstream wrapper: delegate all MfClassic types and APIs to the enhanced
// Momentum overlay implementation under lib/nfc. This ensures there is a
// single canonical definition while keeping all upstream functions available.

#include <lib/nfc/protocols/mf_classic/mf_classic.h>
