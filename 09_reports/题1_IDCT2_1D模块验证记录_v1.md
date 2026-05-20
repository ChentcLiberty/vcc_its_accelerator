# 题1 IDCT2 1D模块验证记录 v1

时间：`2026-05-20`

## 本轮交付

本轮新增内容：

- RTL： [idct2_1d_core.v](../05_rtl/idct2_1d_core.v)
- Testbench： [tb_idct2_1d_core.sv](../06_tb/tb_idct2_1d_core.sv)
- ROM： [idct2_tables.memh](../05_rtl/idct2_tables.memh)
- 系数生成脚本： [gen_idct2_memh.py](../08_scripts/gen_idct2_memh.py)
- 设计说明： [题1_IDCT2_1D核设计_v1.md](../02_架构设计/题1_IDCT2_1D核设计_v1.md)
- 验证说明： [题1_IDCT2_1D验证说明_v1.md](../03_验证计划/题1_IDCT2_1D验证说明_v1.md)

## 验证命令

先生成 ROM：

```bash
python3 08_scripts/gen_idct2_memh.py \
  --json 07_model/inverse_transform_tables.json \
  --out 05_rtl/idct2_tables.memh
```

再在 `/tmp` 编译和仿真：

```bash
/home/jjt/install/synopsys/vcs/vcs/T-2022.06/bin/vcs -full64 -sverilog \
  05_rtl/idct2_1d_core.v \
  06_tb/tb_idct2_1d_core.sv \
  -o /tmp/idct2_vcs_build/idct2_1d_core_simv

/tmp/idct2_vcs_build/idct2_1d_core_simv
```

## 实际结果

仿真结果：

```text
PASS tb_idct2_1d_core
```

## 本轮覆盖点

已覆盖 directed case：

1. `n_tbs = 4,  non_zero_size = 4`
2. `n_tbs = 8,  non_zero_size = 8`
3. `n_tbs = 16, non_zero_size = 8`
4. `n_tbs = 32, non_zero_size = 8`
5. `n_tbs = 64, non_zero_size = 16`

并检查了：

- `4点/拍` 输出节奏
- `out_index_base` 递增
- `out_last`
- `done`
- `out_req` 单次反压保持
- 与 Python golden 的逐点一致性

## 当前结论

`IDCT2 1D` 第一版已经达到：

- 模块级功能正确
- 握手正确
- 可继续用于后续 `LFNST -> IDCT2` 串接

当前还没做的事：

- `IDCT8 / IDST7` RTL
- `LFNST -> IDCT2` 联调 testbench
- 顶层 `ITS` 稀疏输入装载和转置 buffer
- 面积/时序优化
