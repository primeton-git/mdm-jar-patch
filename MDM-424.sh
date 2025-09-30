#!/bin/bash

# @author CHINESE (mailto: lizw@primeton.com)
# @version 1.0.0 2025-09-17
# @description The patch tool for MDM server.

SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"

# git show --name-only HEAD > "${SCRIPT_DIR}/bug/${BUG_NUMBER}.txt"
# git show --name-only f3c8fe9d46ac5a1f011ce0b005034bb3aaf730c8 > "${SCRIPT_DIR}/bug/${BUG_NUMBER}.txt"

export BUG_NUMBER=424
export PATCH_TIMESTAMP=20250917

set -x

# "${SCRIPT_DIR}/mdm-patch.sh" "${SCRIPT_DIR}/bug/${BUG_NUMBER}.txt"
"${SCRIPT_DIR}/mdm-build.sh"
