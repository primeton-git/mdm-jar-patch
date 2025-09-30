#!/bin/bash

# @author CHINESE (mailto: lizw@primeton.com)
# @version 1.0.0 2025-09-17
# @description The patch tool for MDM server.

SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"

# Every bug timestamp
declare -A BUG_ARRAY=(
  ["424"]="20250917"
  ["449"]="20250928"
)

export BUG_NUMBER=${1:-424}
[[ -v BUG_ARRAY[${BUG_NUMBER}] ]] && export PATCH_TIMESTAMP=${BUG_ARRAY[${BUG_NUMBER}]}

"${SCRIPT_DIR}/mdm-build.sh"
