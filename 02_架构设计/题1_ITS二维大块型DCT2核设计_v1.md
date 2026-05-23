# 题1 ITS 二维大块型 DCT2 核设计 v1

## 目标

把当前已经打通的 `8x8 / 16x16` 二维 ITS 路径继续往大块型推进，先收两条最直接、最通用的路径：

- `32x32 DCT2`
- `64x64 DCT2`

这两条路径优先服务官方接口顶层，不先引入 `32x32 DST7/DCT8`，目的是先把：

- 大 TU 存储规模
- 列装载段数
- 输出组数
- 输出反压保持

这几个真正变难的点收住。

## 新增模块

- [its_2d_large_core.v](../05_rtl/its_2d_large_core.v)

## 设计思路

这颗核不是再复制一份 `32x32` 和 `64x64` 各自独立的 RTL，而是抽成一颗参数化的大块型二维核：

- `N_TBS=32`
- `N_TBS=64`
- `ROW_TR_TYPE / COL_TR_TYPE`

当前实际接入的是 `DCT2 -> DCT2`，但数据通路本身保留了 transform 类型参数，后面继续补 `32x32 DST7/DCT8` 时不需要重写整套状态机。

## 数据通路

整体还是标准两级二维 ITS：

1. 行向 `1D ITS`
2. 中间 `transpose buffer`
3. 列向 `1D ITS`
4. 结果 `transpose buffer`
5. `4点/拍` 行优先流出

和 `its_2d16_core.v` 的区别主要在两点：

- `x_in` 扩成 `64x64` 最大存储空间
- 列准备不再写死成 `4` 个段，而是按 `N_TBS/4` 自动迭代

## 状态机

核心状态仍然是：

- `S_IDLE`
- `S_PREP_ROW`
- `S_START_ROW`
- `S_RUN_ROW`
- `S_PREP_COL`
- `S_START_COL`
- `S_RUN_COL`
- `S_STREAM_OUT`

关键变化是 `S_PREP_COL`：

- `16x16` 时原来是固定 `4` 个 prep state
- 现在改成一个通用 `prep_seg_r`
- `32x32` 时循环 `8` 次
- `64x64` 时循环 `16` 次

这样可以在不复制状态名的前提下，把列向输入 `4点` 一组逐段装满。

## 存储组织

- 输入缓存：`x_in_r[0:4095]`
- 中间缓存：复用 [its_transpose_buffer.v](../05_rtl/its_transpose_buffer.v)
- 最终缓存：同样复用 `its_transpose_buffer`

中间缓存和最终缓存都统一用 `MAX_DIM=64`，这样 `32x32` 和 `64x64` 可以共用同一套地址组织。

## 输出组织

输出仍然保持：

- `4点/拍`
- `out_index_base` 行优先、每拍加 `4`

对于大块型，输出组数分别是：

- `32x32`：`256` 组
- `64x64`：`1024` 组

这也是为什么需要把 `out_group_r` 抬到比 `16x16` 更宽。

## 当前接入范围

当前这颗核已经被官方接口顶层 [its_top_official_if_stage1.v](../05_rtl/its_top_official_if_stage1.v) 用来新增：

- `32x32 DCT2`
- `64x64 DCT2`

暂时还没有在官方顶层里放开：

- `32x32 DST7`
- `32x32 DCT8`

这是刻意收边界，不是核本体做不到。
