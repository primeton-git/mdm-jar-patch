#!/bin/bash

# @author CHINESE (mailto: lizw@primeton.com)
# @version 1.0.0 2025-09-17
# @description The patch tool for MDM server.

SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"

# define artifact source
#export MAVEN_REPO_URL="http://192.168.2.1:8081/nexus/service/local/repositories/Primeton_Product_Stage/content"
#export MAVEN_REPO_URL="${HOME}/.m2/repository"
export MDM_SOURCE_PATH=${MDM_SOURCE_PATH:-/mnt/d/primeton/mdm/server-7.3/mdm-server}

[[ -z "${BUG_NUMBER}" ]] && echo "[ERROR] BUG_NUMBER required,  e.g. export BUG_NUMBER=424" && exit 1
export BUG_NUMBER

if [[ -n "${PATCH_OUTPUT_DIR}" ]]; then
  export PATCH_OUTPUT_DIR
else
  export PATCH_OUTPUT_DIR="${SCRIPT_DIR}/target/${BUG_NUMBER}"
fi

export PATCH_OUTPUT_ZIP=${PATCH_OUTPUT_ZIP:-yes}

if [[ -n "${PATCH_TIMESTAMP}" ]]; then
  export PATCH_TIMESTAMP
else
  export PATCH_TIMESTAMP=$(date +%Y%m%d)
fi

# for DevOps CI build and package
if [[ -d "${SCRIPT_DIR}/../mdm/mdm-server" ]]; then
  export MDM_SOURCE_PATH=$(cd "${SCRIPT_DIR}/../mdm/mdm-server" && pwd)
fi

# git show --name-only HEAD > "${SCRIPT_DIR}/bug/${BUG_NUMBER}.txt"
# git show --name-only f3c8fe9d46ac5a1f011ce0b005034bb3aaf730c8 > "${SCRIPT_DIR}/bug/${BUG_NUMBER}.txt"

"${SCRIPT_DIR}/mdm-patch.sh" "${SCRIPT_DIR}/bug/${BUG_NUMBER}.txt"
