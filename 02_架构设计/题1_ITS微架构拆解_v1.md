# 题1 ITS 微架构拆解 v1

## 目标

做一套可综合的 `ITS` 反变换 IP，覆盖：

- `LFNST`
- `IDCT2`
- `IDCT8`
- `IDST7`

满足：

- 输入：`1点/拍`
- 输出：`4点/拍`
- 支持流水

## 推荐顶层拆分

### 1. `its_cfg_regs`

职责：

- 锁存块大小、模式和 `LFNST` 配置
- 将题面参数翻译成内部控制信号

核心输入：

- `tu_width`, `tu_height`
- `transform_type_h`, `transform_type_v`
- `lfnst_enable`, `lfnstTrSetIdx`, `lfnst_idx`

### 2. `its_sparse_loader`

职责：

- 按光栅顺序接收输入非零点
- 装载到内部 `TU` buffer
- 对 LFNST 所需的左上低频区域做抽取

说明：

- 题面不只是给输入值，还给了 `it_data_addr[11:0]`
- 实际硬件需要利用 `it_data_addr` 将稀疏输入恢复到内部完整块布局
- 这一层会直接影响后续 buffer 组织方式

### 3. `lfnst_core`

职责：

- 对 `4x4` 低频区域展开
- 根据 `nTrs = 16 / 48` 选择矩阵
- 完成 `LFNST` 反二次变换
- 对输出做限幅

实现建议：

- 第一版直接用 ROM 系数 + MAC 阵列
- 先不急着做最省面积的共享乘法器
- 先把 `nTrs = 16 / 48` 和 `lfnst_idx / setIdx` 跑通

### 4. `its_1d_core`

职责：

- 完成 1D `IDCT2 / IDCT8 / IDST7`

实现建议：

- 做成参数化核：
  - `transform_type`
  - `length = 4 / 8 / 16 / 32 / 64`
- 第一版优先保证功能和位宽
- 第二版再考虑系数复用、时分复用或乘法器共享

### 5. `its_transpose_buffer`

职责：

- 完成 `列变换 -> 行变换` 的中间结果缓存
- 提供转置读写视图

实现建议：

- 优先用双口 SRAM / reg array 抽象
- 后续综合时再根据面积和时序选具体实现

### 6. `its_scheduler`

职责：

- 控制 `LFNST`、列变换、行变换、输出阶段切换
- 协调 buffer 读写
- 维护 `valid / done / busy`

### 7. `its_output_formatter`

职责：

- 将内部结果整理成 `光栅顺序`
- 保证输出为 `4点/拍`
- 按题面接口打包为 `it_data_out[39:0]`
- 受 `it_data_out_req` 反压控制

## 推荐数据通路

推荐用下面这条主链：

`it_info -> sparse_input(value+addr) -> TU buffer -> optional LFNST -> column 1D transform -> transpose buffer -> row 1D transform -> output reorder/pack -> 4-point output`

这样做的好处：

- 结构清晰
- 容易验证
- 后续做流水和时序切分比较直接

## 当前第一版实现策略

不建议第一版就追“最优架构”。建议：

- `LFNST` 单独做成一个明确可测的小核
- `1D` 反变换先做统一模板核
- 顶层先做正确性闭环，再压性能

## 关键风险点

### 风险1：矩阵和位宽不清楚

- 如果系数表导入流程不稳，后面所有验证都不可信
- 需要先把官方矩阵变成机器可读格式

### 风险2：输入“只输非零点”的真实含义

- 需要尽快确定输入协议是不是只送值，还是值+位置
- 如果题面没有补充，内部实现建议显式保留位置索引

### 风险3：`4点/拍` 和 `500MHz`

- 这是典型会把结构推向多 lane / 深流水的要求
- 第一版先正确，第二版再做高频切分

### 风险4：模式组合很多

- 真正难点不只是变换公式，而是多块型和控制分支
- 所以必须先建 `mode/config -> schedule` 的统一抽象

## 当前最推荐的比赛落地口径

如果后续要和现有主项目能力线统一，题1最好包装成：

- `VVC ITS 反变换加速IP`
- 强调：
  - 数据通路
  - buffer / SRAM
  - 固定点位宽
  - 验证闭环
  - PPA 优化
