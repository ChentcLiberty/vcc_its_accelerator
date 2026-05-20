# 题1 IDCT2 1D验证说明 v1

## 本轮验证目标

这轮不验证完整 `ITS`，只验证：

- `idct2_1d_core`

目标是确认三件事：

1. `DCT2` 系数表加载正确
2. `4点/拍` 输出节奏正确
3. `non_zero_size` 和 `out_req` 行为正确

## Golden来源

Golden 来自本地 Python 参考模型：

- [inverse_transform_ref.py](../07_model/inverse_transform_ref.py)
- [inverse_transform_tables.json](../07_model/inverse_transform_tables.json)

这两份文件已经能跑：

- `dct2`
- `dst7`
- `dct8`

当前 `IDCT2` testbench 只使用 `dct2` 分支。

## 本轮 directed case

建议覆盖 5 组：

1. `n_tbs = 4, non_zero_size = 4`
2. `n_tbs = 8, non_zero_size = 8`
3. `n_tbs = 16, non_zero_size = 8`
4. `n_tbs = 32, non_zero_size = 8`
5. `n_tbs = 64, non_zero_size = 16`

这几组的意义是：

- 先覆盖所有支持长度
- 再覆盖 `non_zero_size < n_tbs` 的部分累加场景

## 输出检查点

每一组都要检查：

- `in_ready` 是否只在 idle 时拉高
- `out_valid` 是否在启动后拉高
- `out_index_base` 是否按 `0, 4, 8, ...` 递增
- `out_last` 是否只在最后一组拉高
- `done` 是否只在整向量输出完成后给脉冲
- `out_data_0 ... out_data_3` 是否逐项等于 golden

## 反压检查

建议至少在一组 case 里插入一次 `out_req = 0`：

- `out_valid` 应保持有效
- `out_index_base` 应保持不变
- 输出数据应保持稳定

这能尽早确认后续顶层对接时的输出侧握手不会出问题。

## 当前不做的验证

这版暂时不做：

- 随机输入回归
- 全尺寸穷举
- 顶层 `LFNST -> transpose -> IDCT2` 联调
- 最终 `10-bit` 打包输出检查

这些都应该放在这版 block-level 自检稳定之后再加。
