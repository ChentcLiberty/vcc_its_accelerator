# 题1 ITS二维8x8核设计 v1

## 设计对象

- [its_2d8_core.v](../05_rtl/its_2d8_core.v)

## 这版做什么

这版不是继续做一个只支持 `IDCT2` 的二维壳子，而是把 `8x8` 二维路径抽成了通用 `ITS 2D` 壳子：

- 行向变换复用 [its_1d_core.v](../05_rtl/its_1d_core.v)
- 列向变换复用 [its_1d_core.v](../05_rtl/its_1d_core.v)
- 中间和最终缓存继续复用 [its_transpose_buffer.v](../05_rtl/its_transpose_buffer.v)

当前通过参数指定：

- `ROW_TR_TYPE`
- `COL_TR_TYPE`

这意味着后面：

- `DCT8 -> DCT8`
- `DST7 -> DST7`
- `DCT2 -> DCT2`
- 以及潜在 mixed 组合

都可以复用同一套二维控制壳子。

## 当前接口

输入侧：

- `start`
- `non_zero_cols`
- `non_zero_rows`
- `x_in[0:63]`

输出侧：

- `4点/拍`
- `out_req` 反压
- `out_index_base`
- `out_last`
- `done`

## 核心结构

状态机沿用之前 `8x8 IDCT2` 的控制方式：

1. `S_PREP_ROW`
2. `S_START_ROW`
3. `S_RUN_ROW`
4. `S_PREP_COL_LO`
5. `S_PREP_COL_HI`
6. `S_START_COL`
7. `S_RUN_COL`
8. `S_STREAM_OUT`

也就是：

- 先按行做 `1D`
- 行结果写入 `mid buffer`
- 再按列从 `mid buffer` 读出，做第二次 `1D`
- 列结果转置写入 `final buffer`
- 最后按光栅顺序 `4点/拍` 流出

## 与旧版 `idct2_2d8_core` 的关系

这版本质上是把原来写死的 `IDCT2` 二维壳子泛化：

- 旧版只能接 `idct2_1d_core`
- 新版改成接 `its_1d_core`
- 变换类型由参数控制

这样做的好处是：

- 保留已经验证过的二维调度
- 把新增风险集中在 `ITS 1D` 接入层
- 后续 `DCT8/DST7` 不需要再复制一整套二维状态机

## 当前首个落地用例

这版 first-use case 是：

- `ROW_TR_TYPE = DCT8`
- `COL_TR_TYPE = DCT8`

也就是 `DCT8 8x8` 二维路径。

## 当前边界

- 当前先落 `8x8`
- 当前先做 directed 闭环，不急着直接上二维 UVM
- 输出继续保留中间精度，不做最终题面 `10-bit` 规范化

## 下一步

最自然的推进顺序是：

1. 用同一壳子补 `DST7 8x8`
2. 给 `ITS 2D 8x8` 补轻量 `UVM`
3. 再往 `16x16 / 32x32` 扩更大块型
