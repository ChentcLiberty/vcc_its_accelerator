# 题1 LFNST到IDCT2二维4x4链路验证记录 v1

时间：`2026-05-20`

## 本轮交付

- RTL： [lfnst_idct2_2d4_core.v](../05_rtl/lfnst_idct2_2d4_core.v)
- Testbench： [tb_lfnst_idct2_2d4_core.sv](../06_tb/tb_lfnst_idct2_2d4_core.sv)
- 运行脚本： [run_vcs_lfnst_idct2_2d4.sh](../08_scripts/run_vcs_lfnst_idct2_2d4.sh)
- 参考模型： [lfnst_idct2_2d4_ref.py](../07_model/lfnst_idct2_2d4_ref.py)
- 设计说明： [题1_LFNST到IDCT2二维4x4链路设计_v1.md](../02_架构设计/题1_LFNST到IDCT2二维4x4链路设计_v1.md)
- 验证说明： [题1_LFNST到IDCT2二维4x4链路验证说明_v1.md](../03_验证计划/题1_LFNST到IDCT2二维4x4链路验证说明_v1.md)

## 当前记录边界

这版已经完成 `VCS` directed 联调。

## 实际运行命令

```bash
./08_scripts/run_vcs_lfnst_idct2_2d4.sh
```

脚本内部会：

1. 进入 `/tmp/lfnst_idct2_2d4_build`
2. 用 `VCS` 编译：
   - `lfnst_core.v`
   - `idct2_1d_core.v`
   - `lfnst_idct2_col4_core.v`
   - `lfnst_idct2_2d4_core.v`
   - `tb_lfnst_idct2_2d4_core.sv`
3. 运行 `./lfnst_idct2_2d4_simv`

## 实际结果

仿真结果：

```text
PASS tb_lfnst_idct2_2d4_core
```

仿真结束时间：

- `1225000 ps`

## 本轮覆盖点

已覆盖两组 directed case：

1. `lfnst_idx = 0` bypass
2. `lfnst_idx = 1, lfnst_tr_set_idx = 0`

每组都检查了：

- `out_row_base = 0 / 4 / 8 / 12`
- `out_last`
- `done`
- `out_data_0..3` 和二维 Python golden 的逐点一致性

## 本轮发现的问题和修正

### 问题1：二维 expected 初版数值不对

现象：

- 手工预估的二维结果和 Python 模型不一致

修正：

- 新增 [lfnst_idct2_2d4_ref.py](../07_model/lfnst_idct2_2d4_ref.py)
- 先用二维参考模型计算 `bypass` 和 `LFNST enabled` 两组 golden，再回填 testbench

### 问题2：二维第二次 `IDCT2` 需要放大输入位宽

现象：

- 列向 `IDCT2` 输出已经是 `32-bit` 中间结果，直接沿用 `16-bit` 行向输入不合理

修正：

- 行向 `IDCT2` 实例改为 `DATA_W = 32`
- 行向累加位宽同步放大
- 最终输出在这版里保留为 `64-bit`

## 当前结论

第一个真正接近完整 `ITS` 的二维 `4x4` 闭环已经打通：

- `LFNST`
- 列向 `IDCT2`
- 行向 `IDCT2`

后续最自然的方向是：

- 给这条二维链路补轻量 `UVM`
- 抽通用 `transpose buffer`
- 把 `4x4` 经验扩展到更大块型
