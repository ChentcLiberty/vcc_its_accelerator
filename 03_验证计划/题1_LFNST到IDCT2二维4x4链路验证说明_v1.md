# 题1 LFNST到IDCT2二维4x4链路验证说明 v1

## 这版验证什么

当前验证对象：

- [lfnst_idct2_2d4_core.v](../05_rtl/lfnst_idct2_2d4_core.v)

目标是确认：

1. `LFNST -> 列向 IDCT2 -> 行向 IDCT2` 的二维功能链路正确
2. 中间位宽扩展没有把二维结果截坏
3. 最终 `4点/拍` 行优先输出正确

## Golden来源

二维 golden 来自：

- [lfnst_idct2_2d4_ref.py](../07_model/lfnst_idct2_2d4_ref.py)

它内部复用了：

- [lfnst_idct2_chain_ref.py](../07_model/lfnst_idct2_chain_ref.py)
- [inverse_transform_ref.py](../07_model/inverse_transform_ref.py)
- [lfnst_ref.py](../07_model/lfnst_ref.py)

## 当前 case

### Case 1: bypass

- `lfnst_idx = 0`
- 验证：
  - `scan remap`
  - 列向 `IDCT2`
  - 行向 `IDCT2`

### Case 2: enabled

- `lfnst_idx = 1`
- `lfnst_tr_set_idx = 0`
- 验证完整二维链路

## 检查点

每个 case 都检查：

- `out_row_base = 0 / 4 / 8 / 12`
- `out_last`
- `done`
- `out_data_0..3` 与二维 Python golden 的逐点一致性

## 运行方式

```bash
./08_scripts/run_vcs_lfnst_idct2_2d4.sh
```

脚本会固定在 `/tmp/lfnst_idct2_2d4_build` 下编译和运行，避免共享目录上下文下的 `VCS` 链接问题。

## 当前边界

这版仍然是 directed 功能闭环版本：

- 不做随机回归
- 不做链路级 `UVM`
- 不做最终规范化输出检查

这轮目标很明确：

- 先把第一个 `4x4` 二维 `ITS` 功能闭环跑通
