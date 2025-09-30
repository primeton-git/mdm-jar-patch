#!/bin/bash

# @author CHINESE (mailto: lizw@primeton.com)
# @version 1.0.0 2025-09-17
# @description The patch tool for MDM server.

SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"

# define artifact source
#export MAVEN_REPO_URL="http://192.168.2.1:8081/nexus/service/local/repositories/Primeton_Product_Stage/content"
#export MAVEN_REPO_URL="${HOME}/.m2/repository"
export MDM_SOURCE_PATH="/mnt/d/primeton/mdm/server-7.3/mdm-server"


export BUG_NUMBER="424"
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
