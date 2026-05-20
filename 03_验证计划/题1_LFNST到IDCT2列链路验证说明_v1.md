# 题1 LFNST到IDCT2列链路验证说明 v1

## 这版验证什么

当前验证对象：

- [lfnst_idct2_col4_core.v](../05_rtl/lfnst_idct2_col4_core.v)

目标是确认三件事：

1. `LFNST vector -> 4x4 block` 回填关系正确
2. `4x4 block -> per-column IDCT2` 调用关系正确
3. 外部 `4点/拍` 输出和反压保持正确

## Golden来源

这版黄金参考不再只靠单个模块模型，而是用子链路模型：

- [lfnst_idct2_chain_ref.py](../07_model/lfnst_idct2_chain_ref.py)

它内部复用了：

- [lfnst_ref.py](../07_model/lfnst_ref.py)
- [inverse_transform_ref.py](../07_model/inverse_transform_ref.py)

## 当前 case

### Case 1: bypass

- `lfnst_idx = 0`
- 不做 `LFNST`
- 直接把输入扫描向量回填成 `4x4`
- 再做列向 `IDCT2`

这个 case 的意义是：

- 单独验证 `scan remap + column IDCT2`

### Case 2: enabled

- `lfnst_idx = 1`
- `lfnst_tr_set_idx = 0`
- 先跑 `LFNST`
- 再回填成 `4x4`
- 再做列向 `IDCT2`

这个 case 的意义是：

- 验证真实的 `LFNST -> IDCT2` 链路

## 检查点

每个 case 都检查：

- `out_row_base = 0 / 4 / 8 / 12`
- `out_last` 只在最后一拍拉高
- `done` 只在整块输出完成后拉脉冲
- `out_data_0..3` 和 golden block 对齐

## 运行方式

```bash
./08_scripts/run_vcs_lfnst_idct2_col4.sh
```

脚本会固定在 `/tmp/lfnst_idct2_col4_build` 下编译和运行，避免共享目录上下文下的 `VCS` 链接问题。

## 当前边界

这版是 directed 联调版本，先把功能路径收稳：

- `bypass`
- `LFNST enabled`
- `scan remap`
- `per-column IDCT2`

链路级 `out_req` 反压检查没有放在这一版 directed testbench 里硬塞；后续更合适的做法是沿用当前 `IDCT2` 的方法学思路，给这条子链路补一版轻量 `UVM` 环境，再把 hold 行为放到 assertion 和 scoreboard 里检查。

这一步现在已经补上，对应文件见：

- [题1_LFNST到IDCT2列链路UVM验证说明_v1.md](./题1_LFNST到IDCT2列链路UVM验证说明_v1.md)
- [题1_LFNST到IDCT2列链路UVM验证记录_v1.md](../09_reports/题1_LFNST到IDCT2列链路UVM验证记录_v1.md)
