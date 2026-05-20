# 题1 LFNST到IDCT2列链路验证记录 v1

时间：`2026-05-20`

## 本轮交付

- RTL： [lfnst_idct2_col4_core.v](../05_rtl/lfnst_idct2_col4_core.v)
- Testbench： [tb_lfnst_idct2_col4_core.sv](../06_tb/tb_lfnst_idct2_col4_core.sv)
- 运行脚本： [run_vcs_lfnst_idct2_col4.sh](../08_scripts/run_vcs_lfnst_idct2_col4.sh)
- 参考模型： [lfnst_idct2_chain_ref.py](../07_model/lfnst_idct2_chain_ref.py)
- 设计说明： [题1_LFNST到IDCT2列链路设计_v1.md](../02_架构设计/题1_LFNST到IDCT2列链路设计_v1.md)
- 验证说明： [题1_LFNST到IDCT2列链路验证说明_v1.md](../03_验证计划/题1_LFNST到IDCT2列链路验证说明_v1.md)

## 当前记录边界

这版已经完成 `VCS` directed 联调。

## 实际运行命令

```bash
./08_scripts/run_vcs_lfnst_idct2_col4.sh
```

脚本内部会：

1. 进入 `/tmp/lfnst_idct2_col4_build`
2. 用 `VCS` 编译：
   - `lfnst_core.v`
   - `idct2_1d_core.v`
   - `lfnst_idct2_col4_core.v`
   - `tb_lfnst_idct2_col4_core.sv`
3. 运行 `./lfnst_idct2_col4_simv`

## 实际结果

仿真结果：

```text
PASS tb_lfnst_idct2_col4_core
```

仿真结束时间：

- `705000 ps`

## 本轮覆盖点

已覆盖两组 directed case：

1. `lfnst_idx = 0` bypass
2. `lfnst_idx = 1, lfnst_tr_set_idx = 0`

每组都检查了：

- `out_row_base = 0 / 4 / 8 / 12`
- `out_last`
- `done`
- `out_data_0..3` 和 Python 子链路 golden 的逐点一致性

## 本轮发现的问题和修正

### 问题1：初版 expected 数值量级不对

现象：

- 直接手填的 expected 明显比实际 `IDCT2` 点积结果小一个量级

修正：

- 新增 [lfnst_idct2_chain_ref.py](../07_model/lfnst_idct2_chain_ref.py)
- 先用参考模型计算 `bypass` 和 `LFNST enabled` 两组 golden，再回填 testbench

### 问题2：初版 stall 注入时机不对

现象：

- directed testbench 里把 `out_req` 拉低的时机放在了拍边界之后，导致观察到的是“正常前进到下一组”，不是合法 hold 场景

修正：

- 这版先把 directed 联调收口到纯功能路径
- 链路级反压保持留到后续轻量 `UVM` 版本里做

## 当前结论

`4x4` 的 `LFNST -> 列向 IDCT2` 第一版子链路已经打通，可以继续进入：

- 列链路 `UVM` 化
- `transpose buffer`
- 行向第二次 `1D` 变换
