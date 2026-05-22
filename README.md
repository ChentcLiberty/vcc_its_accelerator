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
  - 通用 `ITS 1D` 核已落地，统一支持 `DCT2 / DST7 / DCT8`
  - `ITS 1D` directed 自检已通过，覆盖 `8-point / 32-point` 和一次单拍输出反压
  - `ITS 1D` 的轻量 `UVM` 也已落地并通过 `VCS UVM` smoke 回归
  - 通用 `ITS 2D 8x8` 壳子已落地，`DCT8 8x8` 和 `DST7 8x8` 用例都已通过 directed 回归
  - `ITS 2D 8x8` 的 `DCT8 -> DCT8` 轻量 `UVM` 也已落地并通过 `VCS UVM` smoke 回归
  - `ITS 2D 8x8` 的 `DST7 -> DST7` 轻量 `UVM` 也已落地并通过 `VCS UVM` smoke 回归
  - 通用 `ITS 2D 16x16` 壳子第一版已落地，`DCT8 16x16` directed 回归已通过
  - `ITS 2D 16x16` 的 `DST7 16x16` directed 回归也已通过
  - `ITS 2D 16x16` 的 `DCT8 -> DCT8` 轻量 `UVM` 也已落地并通过 `VCS UVM` smoke 回归
  - `ITS 2D 16x16` 的 `DST7 -> DST7` 轻量 `UVM` 也已落地并通过 `VCS UVM` smoke 回归
  - `ITS 2D 16x16` 的 `DCT8/DST7` 两条 `UVM` 路径已进一步收成共享验证骨架
  - 官方接口顶层第一版已落地，已打通 `it_info / it_data_addr / it_data_in_req / it_data_out[39:0] / it_done`
  - 官方接口顶层第一版 directed 已扩到：
    - `4x4 DCT2 + LFNST`
    - `8x8 DCT8`
    - `16x16 DCT8`
    - unsupported 模式
    - 一次 `it_data_out_req` 单拍反压
- `IDCT2`
  - 第一版 `1D` RTL 已落地
  - 对应的块级设计说明和验证说明已补
  - `tb_idct2_1d_core.sv` 已通过 `VCS` 自检
  - 轻量 `UVM` 骨架已落地并通过 `VCS UVM` smoke 回归
  - 本轮验证记录已归档到 `09_reports`
  - `4x4` 的 `LFNST -> 列向 IDCT2` 子链路已落地并通过 directed 联调
  - 这条子链路的轻量 `UVM` 也已落地并通过 `VCS UVM` smoke 回归
  - `4x4` 完整二维 `LFNST -> 列IDCT2 -> 行IDCT2` 已落地并通过 directed 联调
  - 这条二维链路的轻量 `UVM` 也已落地并通过 `VCS UVM` smoke 回归
  - 通用 `transpose buffer` 已抽成独立可综合模块
  - `4x4` 二维链路已改成复用 `transpose buffer`
  - `transpose buffer` 已支持转置写入，并通过 directed 回归
  - `8x8` 二维 `IDCT2` 路径已落地并通过 directed 回归
  - `8x8` 二维 `IDCT2` 的轻量 `UVM` 也已落地并通过 `VCS UVM` smoke 回归
  - `16x16` 二维 `IDCT2` 路径已落地并通过 directed 回归
  - `16x16` 二维 `IDCT2` 的轻量 `UVM` 也已落地并通过 `VCS UVM` smoke 回归
  - 下一步把这套共享 `16x16 UVM` 骨架往更大块型或更多 transform 组合继续复用

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

## 当前顶层状态

- 第一版官方接口顶层： [its_top_official_if_stage1.v](./05_rtl/its_top_official_if_stage1.v)
- 当前已支持：
  - `4x4 DCT2 + optional LFNST`
  - `8x8 DCT2 / DST7 / DCT8`
  - `16x16 DCT2 / DST7 / DCT8`
- 当前限制：
  - 只支持平方块
  - `8x8/16x16` 当前要求 `tr_type_hor == tr_type_ver`
  - `8x8/16x16` 当前要求 `lfnst_idx = 0`
  - `32x32/64x64` 还没接进这版顶层
  - 这版顶层当前还没有配套 `UVM`，目前是增强版 directed smoke

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
