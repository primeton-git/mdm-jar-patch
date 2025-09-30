# 项目介绍

本项目用于抽取MDM项目的后的JAR文件内的资源文件，用于制作产品补丁的自动化工具。用户只要提供变更的源码文件列表并指定目标仓库或JAR文件目录，使用自动化脚本即可自动抽取变更的资源文件。

# 各模块JAR源文件路径或Maven仓库设置
支持五种设置（不管哪种JAR文件名必须符合Maven介质命名规范），有五种方式指定完整artifact介质路径，按需选择其中一个。

- (1) 本地Maven库路径， e.g. `~/.m2/repository`
- (2) 远程Maven库或URL， e.g. `http://192.168.2.1:8081/nexus/service/local/repositories/Primeton_Product_Stage/content`
- (3) 本地JAR文件目录， e.g. 解压启动JAR获得目录`BOOT-INF/lib`
- (4) 本地mdm-server源码目录（Maven打包之后才能使用）， e.g. `D:/primeton/mdm/mdm-server-7.3.0`
- (5) 默认为shell终端当前目录下：`./artifacts`

开发者在本机制作补丁情况下，本地开发时推荐使用方式1/4，指向脚本之前：使用方式1情况下必需要先进行`mvn install`，使用方式4情况下必需要先进行`mvn package`。

# 获取修复BUG或开发新特性涉及的变更源码文件列表

建议使用git相关命令一次或多次提取所需的变更源码文件列表，例如：

- `git show --name-only HEAD > bug/{BUG_NUMBER}.txt`
- `git show --name-only ${HASH_ID} > bug/{BUG_NUMBER}.txt`
- 
获取变更文件列表后，开发者可以按实际需要进行删减，此外变更描述文件内容支持注释行和空行。 e.g.
```text
# MDMWH-424, 20250917 -- New feature: batch op for OpenApi
# Git: f3c8fe9d46ac5a1f011ce0b005034bb3aaf730c8

mdm-server/mdm-core/src/com/primeton/mdm/core/client/API.java
mdm-server/mdm-core/src/com/primeton/mdm/management/controller/MDM8DataServiceController.java
mdm-server/mdm-core/src/com/primeton/mdm/management/service/v8/BizDataService.java
mdm-server/mdm-core/src/com/primeton/mdm/management/util/MDMDataModelTableHelper.java
mdm-server/mdm-core/src/com/primeton/mdm/management/vo/HandleResult.java
```

# 执行自动化脚本进行补丁文件制作

```shell
# export MDM_VERSION=7.3.0
export BUG_NUMBER=424
export PATCH_TIMESTAMP=20250917
./mdm-build.sh
```
制作完成后，开发者要检查一下制作的补丁文件是否正确，还要在测试环境进行相关验证后方可发布。
为了简化和记录补丁制作参数，可以编写`MDM-${BUG_NUMBER}.sh`脚本；或者是使用`DevOps构建任务`来制作补丁——填写BUG号和补丁时间戳执行即可（执行构建任务前，先把变更文件提交Git库或者直接当作执行参数）。


