#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"

export BUG_NUMBER="424"
#export MDM_SOURCE_PATH="/mnt/d/primeton/mdm/server-7.3/mdm-server"
export PATCH_OUTPUT_DIR="${SCRIPT_DIR}/target/${BUG_NUMBER}"
export PATCH_OUTPUT_ZIP="yes"
#export PATCH_TIMESTAMP=$(date +%Y%m%d)
export PATCH_TIMESTAMP=20250917

# for DevOps CI build and package
if [[ -d "${SCRIPT_DIR}/../mdm/mdm-server" ]]; then
  export MDM_SOURCE_PATH=$(cd "${SCRIPT_DIR}/../mdm/mdm-server" && pwd)
fi

# git show --name-only HEAD > "${SCRIPT_DIR}/bug/${BUG_NUMBER}.txt"
# git show --name-only f3c8fe9d46ac5a1f011ce0b005034bb3aaf730c8 > "${SCRIPT_DIR}/bug/${BUG_NUMBER}.txt"

"${SCRIPT_DIR}/mdm-patch.sh" "${SCRIPT_DIR}/bug/${BUG_NUMBER}.txt"
