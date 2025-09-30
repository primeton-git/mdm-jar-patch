#!/bin/bash

# @author CHINESE (mailto: lizw@primeton.com)
# @version 1.0.0 2025-09-28
# @description The patch tool for MDM server.

SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"

export BUG_NUMBER=449
export PATCH_TIMESTAMP=20250928

"${SCRIPT_DIR}/mdm-build.sh"
