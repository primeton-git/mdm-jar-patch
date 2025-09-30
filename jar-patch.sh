#!/bin/bash

# @author CHINESE (mailto: lizw@primeton.com)
# @version 1.0.0 2024-08-20
# @description The patch tool for MDM server.

set -e

# 脚本功能：根据Java源文件列表提取JAR中的相关类文件并生成补丁包
# 使用方法：./extract_classes.sh sources.txt mdm-core.jar

# 参数校验
if [ $# -ne 2 ] || [ ! -f "$1" ] || [ ! -f "$2" ]; then
    echo "Usage: $0 <java_source_list> <jar_file>"
    echo "Example: $0 sources.txt mdm-core.jar"
    exit 1
fi

# 输入参数
JAVA_SOURCES="$1"
TARGET_JAR="$2"
[[ -n "${PATCH_TIMESTAMP}" ]] || PATCH_TIMESTAMP="$(date +%Y%m%d)"
TEMP_DIR=$(mktemp -d)
echo "TEMP_DIR=${TEMP_DIR}"
OUTPUT_DIR="${TEMP_DIR}/output"

# 创建临时目录结构
mkdir -p "${OUTPUT_DIR}"

# 解压目标JAR到临时目录（保留完整路径）
echo "[INFO ] Extracting JAR contents with unzip..."
unzip -qd "${TEMP_DIR}" "${TARGET_JAR}"

while IFS= read -r SOURCE_PATH; do
    # 处理每个Java源文件
    if [[ "${SOURCE_PATH}" == *".java" ]]; then
      # 转换为类文件路径（.java -> .class）
      CLASS_FILE="${SOURCE_PATH%.java}.class"
      CLASS_PACKAGE=$(dirname "${CLASS_FILE}")

      # 查找并复制主类文件（保留目录结构）
      echo "[INFO ] Processing main class: ${CLASS_FILE}"
      find "${TEMP_DIR}" -type f -path "*/${CLASS_FILE}" -print0 | while IFS= read -r -d '' FILE; do
          RELATIVE_PATH="${FILE#${TEMP_DIR}/}"
          DEST_PATH="${OUTPUT_DIR}/${RELATIVE_PATH}"
          mkdir -p "$(dirname "${DEST_PATH}")"
          cp -v "${FILE}" "${DEST_PATH}"
      done

      # 提取内部类（处理Foo$Bar.class格式）
      BASE_CLASS="${CLASS_FILE##*/}"
      INNER_PATTERN="*/${CLASS_FILE%/*}/${BASE_CLASS%.*}\$*.class"

      echo "[INFO ] Extracting inner classes for: ${BASE_CLASS}"
      find "${TEMP_DIR}" -type f -path "${INNER_PATTERN}" -print0 | while IFS= read -r -d '' FILE; do
          RELATIVE_PATH="${FILE#${TEMP_DIR}/}"
          DEST_PATH="${OUTPUT_DIR}/${RELATIVE_PATH}"
          mkdir -p "$(dirname "${DEST_PATH}")"
          cp -v "${FILE}" "${DEST_PATH}"
      done

    else # 非class文件则直接拷贝就行（暂时不考虑EOS逻辑流之类的资源）
      if [[ -f "${TEMP_DIR}/${SOURCE_PATH}" ]]; then
        DEST_PATH=$(dirname "${OUTPUT_DIR}/${SOURCE_PATH}")
        [[ -d "${DEST_PATH}" ]] || mkdir -p "${DEST_PATH}"
        cp -f "${TEMP_DIR}/${SOURCE_PATH}" "${DEST_PATH}"
      else
        echo "[WARN ] Skip not found file: ${TEMP_DIR}/${SOURCE_PATH}"
      fi
    fi
done < "${JAVA_SOURCES}"


# 生成新JAR文件名（保留原JAR名+补丁日期）
JAR_BASENAME=$(basename "${TARGET_JAR}" .jar)
NEW_JAR="${JAR_BASENAME}-patch-${PATCH_TIMESTAMP}-MDMWH-${BUG_NUMBER:-unkown}.jar"
if [[ -n "${PATCH_OUTPUT_DIR}" ]]; then
    [[ -d "${PATCH_OUTPUT_DIR}" ]] || mkdir -p "${PATCH_OUTPUT_DIR}"
    PATCH_OUTPUT_DIR=$(cd "${PATCH_OUTPUT_DIR}" && pwd)
    NEW_JAR="${PATCH_OUTPUT_DIR}/${NEW_JAR}"
else
    NEW_JAR=$(dirname "${TARGET_JAR}")/"${NEW_JAR}"
fi

# 压缩临时目录为ZIP格式JAR文件（保留目录结构）
echo "[INFO ] Creating new ZIP archive: ${NEW_JAR}"
cd "${OUTPUT_DIR}" || exit
[[ -f "${NEW_JAR}" ]] && rm -f "${NEW_JAR}"
zip -r0 "${NEW_JAR}" . --exclude "*.tmp" --exclude "*.log"
which md5sum && echo "[INFO ] Calculating MD5 checksum for: ${NEW_JAR}" && md5sum "${NEW_JAR}" > "${NEW_JAR}.md5"
which sha256sum && echo "[INFO ] Calculating SHA256 checksum for: ${NEW_JAR}" && sha256sum "${NEW_JAR}" > "${NEW_JAR}.sha256sum"

# 清理临时文件
echo "[INFO ] Cleaning up temporary files... ${TEMP_DIR}"
rm -rf "${TEMP_DIR}"

echo "[INFO ] New JAR created: ${NEW_JAR}"
