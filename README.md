# 华为杯题1 VVC反变换模块（ITS）设计

英文项目名：`VVC Inverse Transform System (ITS) Design`

当前主线：`华为杯赛题一`

当前阶段目标：

- 明确官方要求和实现边界
- 优先打通 `LFNST + IDCT/DCT8/DST7` 的参考模型
- 建立可综合 RTL 骨架和自检验证框架

## 当前状态

- `LFNST`
  - Python 参考模型已完成
  - 矩阵提取脚本已完成
  - ROM 化 RTL 和模块级自检 testbench 已通过
- `DCT2 / DCT8 / DST7`
  - 已开始补矩阵提取和 1D 参考模型
  - `inverse_transform_tables.json` 已生成
  - `DCT8/DST7 32-point` 当前为“附件前 16 行精确 + 后 16 行解析式补齐”
- `IDCT2`
  - 第一版 `1D` RTL 已落地
  - 对应的块级设计说明和验证说明已补
  - `tb_idct2_1d_core.sv` 已通过 `VCS` 自检
  - 轻量 `UVM` 骨架已落地并通过 `VCS UVM` smoke 回归
  - 本轮验证记录已归档到 `09_reports`
  - `4x4` 的 `LFNST -> 列向 IDCT2` 子链路已落地并通过 directed 联调

## 目录说明

- [00_题面资料](./00_题面资料)
  - 原始题面相关资料和本地附件
- [01_需求分析](./01_需求分析)
  - 官方要求、实现边界、阶段目标
- [02_架构设计](./02_架构设计)
  - 微架构拆解、模块划分、关键风险
- [03_验证计划](./03_验证计划)
  - 参考模型、向量来源、模块级和顶层级验证策略
- [04_实施计划](./04_实施计划)
  - 第一周开工清单和后续推进顺序

## 当前结论

- 主赛题确定为 `题1 VVC反变换模块（ITS）设计`
- 不把 `题9` 作为主赛题
- 题1比题9更适合和现有 `TPU SoC / 视频链路 / Viterbi` 三项目能力线衔接

## 对应官方赛题口径

当前仓库内容和文档统一按官方赛题标题组织：

- `VVC反变换模块（ITS）设计`
- 核心范围包括：
  - `LFNST`
  - `DCT2`
  - `DCT8`
  - `DST7`
  - `1点/拍` 输入
  - `4点/拍` 输出
  - `500MHz` 目标

## 当前最小可落地路径

1. 先做 `LFNST` 参考模型和 RTL
2. 再做 `1D IDCT2 / IDCT8 / IDST7` 核
3. 再包成 `2D ITS top`
4. 最后补齐所有块大小、模式组合和吞吐优化

## 关键资料

- 官方赛题页：
  - https://cpipc.acge.org.cn/cw/contestNews/detail/10/2c9080189bd54d54019c07ea1f561497?page=2
- 官方矩阵下载：
  - https://cpipc.acge.org.cn/sysFile/downFile.do?fileId=e45f3cabe73841c1848eabbf58b95eff
- 本地 LFNST 文档：
  - [Low frequency non.docx](./00_题面资料/Low%20frequency%20non.docx)
- 本地比赛链接：
  - [华为比赛链接.txt](./00_题面资料/华为比赛链接.txt)
- 开源项目调研：
  - [题1_可复用开源项目调研.md](./01_需求分析/题1_可复用开源项目调研.md)
