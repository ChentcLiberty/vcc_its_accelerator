# 题1 IDCT2 1D核设计 v1

## 目标

这一版只解决 `IDCT2` 的块级 `1D` 计算核：

- 支持 `4 / 8 / 16 / 32 / 64` 五种长度
- 输入一整个向量
- 输出保持 `4点/拍`
- 支持 `out_req` 反压
- 为后续 `LFNST -> IDCT2` 串接提供稳定子模块

这不是最终 `ITS top`，而是第一版可综合、可自检的小核。

## 当前接口

模块文件： [idct2_1d_core.v](../05_rtl/idct2_1d_core.v)

核心输入：

- `start`
- `n_tbs`
- `non_zero_size`
- `x_0 ... x_63`
- `out_req`

核心输出：

- `in_ready`
- `out_valid`
- `out_last`
- `out_index_base`
- `out_data_0 ... out_data_3`
- `done`
- `busy`

## 当前实现思路

### 1. 大小选择

`IDCT2` 只支持赛题要求的 5 个长度：

- `4`
- `8`
- `16`
- `32`
- `64`

模块启动时锁存 `n_tbs`，并选择对应的 ROM 表。

### 2. 系数存储

这版用 ROM 直接存 `DCT2` 矩阵：

- 表顺序：`4, 8, 16, 32, 64`
- 每个表统一按 `64 x 64` padded 布局存储
- 小尺寸矩阵未覆盖的行列全部补零

这样做的好处：

- RTL 地址计算简单
- 不需要运行时再做尺寸相关抽样
- testbench 和 Python model 更容易直接对拍

代价也明确：

- ROM 利用率不高
- 第一版不是最省面积的组织方式

这个取舍是刻意的，当前优先验证闭环，不优先压 ROM 面积。

### 3. 输入向量锁存

第一版在 `start` 时一次性锁存 `x_0 ... x_63`：

- 小尺寸只使用前 `n_tbs` 项
- `non_zero_size` 会进一步限制累加上界

这条设计假设与当前 block-level testbench 一致，后续接真实顶层时再改成 `stream loader + scratch buffer`。

### 4. 计算方式

当前每拍输出 4 个结果：

- `row_base`
- `row_base + 1`
- `row_base + 2`
- `row_base + 3`

每个结果都做一遍：

`sum(coeff[row][col] * x[col])`

本质上是 `4 lane` 并行的行向量点积。

### 5. 位宽

当前参数：

- 输入：`DATA_W = 16`
- 系数：`COEFF_W = 8`
- 累加：`ACC_W = 40`
- 输出：`OUT_W = 32`

这版输出的是原始点积结果，不在这里做赛题最终 `10-bit` 打包或顶层截位。

原因：

- 这里是 `1D` 子模块
- 现阶段优先保留中间结果精度
- 最终截位应放到 `ITS top` 的规范化/输出阶段处理

## 当前边界

这版 `idct2_1d_core` 还没有做这些事：

- 没有接真实 `it_data_in` 稀疏输入协议
- 没有和 `transpose buffer` 串接
- 没有做乘法器共享
- 没有做高频流水切分
- 没有做面积优化

所以它的定位很明确：

- `算法正确`
- `握手正确`
- `4点/拍` 输出节奏正确

## 下一步

这版通过后，下一步建议是：

1. 做 `tb_idct2_1d_core.sv`
2. 跑 `4/8/16/32/64` directed self-check
3. 把 `LFNST -> IDCT2` 串成第一条真实链路
