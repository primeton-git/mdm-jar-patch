#!/bin/bash

# @author CHINESE (mailto: lizw@primeton.com)
# @version 1.0.0 2024-08-20
# @description The patch tool for MDM server.

SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"

set -e

# 参数校验
if [ $# -ne 1 ] || [ ! -f "$1" ]; then
    echo "Usage: $0 <mdm_java_source_list>"
    echo "e.g.   $0 ./git-change-sources.txt"
    exit 1
fi

# 输入参数
JAVA_SOURCES="$1"
TEMP_DIR=$(mktemp -d)
echo "TEMP_DIR=${TEMP_DIR}"

# 全局参数设置
export MDM_VERSION="${MDM_VERSION:-7.3.0}"

# 处理每个Java源文件，分发到各个模块下
while IFS= read -r line; do
    # e.g. mdm-server/mdm-core/src/com/primeton/mdm/management/spi/MDMBizDataExcelHandler.java
    # => mdm-core
    MDM_MODULE=$(echo "${line}" | cut -d'/' -f2)
    # => com/primeton/mdm/management/spi/MDMBizDataExcelHandler.java
    if [[ -z "${line}" ]] || [[ -z "${line// }" ]]; then
      echo "[INFO ] Skip empty line."
    elif [[ "${line}" == "#"* ]]; then
      echo "[INFO ] Skip comment line: ${line}"
    else
      JAVA_SRC_PATH=${line#*/*/*/*}
      echo "${JAVA_SRC_PATH}" >> "${TEMP_DIR}/${MDM_MODULE}.txt"
    fi
done < "${JAVA_SOURCES}"

#declare -A dict=([name]="Alice" [age]=28 [city]="New York")
# ARTIFACT_SOURCE="path"
if [[ -z "${ARTIFACT_SOURCE}" ]] && [[ -n "${MAVEN_REPO_PATH}" ]] && [[ -d "${MAVEN_REPO_PATH}" ]]; then
    echo "[INFO ] MAVEN_REPO_PATH=${MAVEN_REPO_PATH}"
    ARTIFACT_SOURCE="maven"
fi
if [[ -z "${ARTIFACT_SOURCE}" ]] && [[ -n "${MAVEN_REPO_URL}" ]]; then
    status_code=$(curl -s -o /dev/null -w "%{http_code}" $URL)
    if [ $status_code -ge 400 ]; then
        echo "[ERROR] ${MAVEN_REPO_URL} unavailable, STATUS_CODE=${status_code}"
    else
      echo "[INFO ] MAVEN_REPO_URL=${MAVEN_REPO_URL}"
      ARTIFACT_SOURCE="url"
    fi
fi
if [[ -z "${ARTIFACT_SOURCE}" ]] && [[ -n "${MDM_SOURCE_PATH}" ]] && [[ -d "${MDM_SOURCE_PATH}" ]]; then
    echo "[INFO ] MDM_SOURCE_PATH=${MDM_SOURCE_PATH}"
    ARTIFACT_SOURCE="src"
fi
if [[ -z "${ARTIFACT_SOURCE}" ]] && [[ -n "${ARTIFACT_PATH}" ]] && [[ -d "${ARTIFACT_PATH}" ]]; then
  echo "[INFO ] ARTIFACT_PATH=${ARTIFACT_PATH}"
  ARTIFACT_SOURCE="artifact"
fi
export ARTIFACT_SOURCE="${ARTIFACT_SOURCE:-default}" # Default use current directory: ${PWD}/artifacts

getArtifactFile() {
  artifactId="$1" # module
  case "${ARTIFACT_SOURCE}" in
    "maven")
      # e.g. com.primeton.mdm:mdm-core:jar:7.3.0
      artifactFile="${MAVEN_REPO_PATH}/com/primeton/mdm/${artifactId}/${MDM_VERSION}/${artifactId}-${MDM_VERSION}.jar"
      ;;
    "url")
      # e.g. https://repo1.maven.org/maven2/com/primeton/mdm/mdm-core/7.3.0/mdm-core-7.3.0.jar
      artifactURL="${MAVEN_REPO_URL}/com/primeton/mdm/${artifactId}/${MDM_VERSION}/${artifactId}-${MDM_VERSION}.jar"
      [[ -d "${TEMP_DIR}/artifacts" ]] || mkdir -p "${TEMP_DIR}/artifacts"
      artifactFile="${TEMP_DIR}/artifacts/${artifactId}-${MDM_VERSION}.jar"
      curl -s -o "${artifactFile}" "${artifactURL}"
      ;;
    "src")
      # e.g. mdm-core-7.3.0.jar
      artifactFile="${MDM_SOURCE_PATH}/${artifactId}/target/${artifactId}-${MDM_VERSION}.jar"
      ;;
    "artifact")
      # e.g. mdm-core-7.3.0.jar
      artifactFile="${ARTIFACT_PATH}/${artifactId}-${MDM_VERSION}.jar"
      ;;
    "default")
      # e.g. mdm-core-7.3.0.jar
      artifactFile="${PWD}/artifacts/${artifactId}-${MDM_VERSION}.jar"
      ;;
  esac
  echo "${artifactFile}"
}

ls -al "${TEMP_DIR}"

for f in `find "${TEMP_DIR}" -type f -name '*.txt'`; do
  echo "[INFO ] git-change-file: $f, content: "
  echo -e "\n-----------------------------------------------------------"
  cat "${f}"
  echo -e "-----------------------------------------------------------\n"
  cd "${TEMP_DIR}"
  artifactId=$(basename "${f%.txt}") # module-name
  jarFile=$(getArtifactFile "${artifactId}")
  echo "[INFO ] <JAR> artifactId=${artifactId} => ${jarFile}"
  ${SCRIPT_DIR}/jar-patch.sh "${f}" "${jarFile}"
done

# 清理临时文件
echo "[INFO ] Cleaning up temporary files... ${TEMP_DIR}"
rm -rf "${TEMP_DIR}"
