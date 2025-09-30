#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"

export BUG_NUMBER="985"
# 有五种方式指定完整artifact介质路径
# 1) 本地Maven库路径， e.g. ~/.m2/repository
# 2) 远程Maven库或URL， e.g. http://192.168.2.1:8081/nexus/service/local/repositories/Primeton_Product_Stage/content
# 3) 本地JAR文件目录， e.g. 解压启动JAR获得目录BOOT-INF/lib
# 4) 本地mdm-server源码目录（Maven打包之后才能使用）
# 5) 默认为shell终端当前目录下：./artifacts

# 这里先选择(4)从源代码Maven编译输出目录target/下获取JAR文件
export MDM_SOURCE_PATH="/mnt/d/primeton/mdm/server-7.3/mdm-server"
export PATCH_OUTPUT_DIR="${SCRIPT_DIR}/target/${BUG_NUMBER}"
# 压缩补丁文件集合生成ZIP包
export PATCH_OUTPUT_ZIP="yes"
#export PATCH_TIMESTAMP=$(date +%Y%m%d)
export PATCH_TIMESTAMP=20250918


"${SCRIPT_DIR}/mdm-patch.sh" "${SCRIPT_DIR}/bug/${BUG_NUMBER}.txt"
