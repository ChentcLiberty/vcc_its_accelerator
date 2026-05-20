# 题1 LFNST到IDCT2二维4x4链路UVM验证说明 v1

## 这版在做什么

这版是在已经通过 directed 的二维 `4x4` 闭环基础上，给：

- `LFNST`
- 列向 `IDCT2`
- 行向 `IDCT2`

这条完整二维链路补一套轻量 `UVM` 骨架。

当前覆盖对象：

- [lfnst_idct2_2d4_core.v](../05_rtl/lfnst_idct2_2d4_core.v)

## 当前方法学组件

- `interface`
- `sequence item`
- `sequence`
- `driver`
- `monitor`
- `scoreboard`
- `env`
- `test`
- `SVA hold assertion`

## 文件位置

- interface： [lfnst_idct2_2d4_if.sv](../06_tb/uvm_lfnst_idct2_2d4/lfnst_idct2_2d4_if.sv)
- package： [lfnst_idct2_2d4_uvm_pkg.sv](../06_tb/uvm_lfnst_idct2_2d4/lfnst_idct2_2d4_uvm_pkg.sv)
- top： [tb_lfnst_idct2_2d4_uvm_top.sv](../06_tb/uvm_lfnst_idct2_2d4/tb_lfnst_idct2_2d4_uvm_top.sv)
- 运行脚本： [run_vcs_lfnst_idct2_2d4_uvm.sh](../08_scripts/run_vcs_lfnst_idct2_2d4_uvm.sh)

## 当前 smoke case

1. `bypass_case`
   - `lfnst_idx = 0`
   - 验证二维 `scan remap + col IDCT2 + row IDCT2`
2. `lfnst_enabled_case`
   - `lfnst_idx = 1`
   - 验证完整二维链路
   - 在第 `1` 组输出后插入一次单拍 `out_req` 反压

## 运行方式

```bash
./08_scripts/run_vcs_lfnst_idct2_2d4_uvm.sh
```

脚本会固定在 `/tmp/lfnst_idct2_2d4_uvm_build` 下编译和运行，避免共享目录上下文下的 `VCS` link/symlink 问题。

## 本轮实际结果

- `VCS` 编译通过
- `UVM_ERROR = 0`
- `UVM_FATAL = 0`
- 已通过：
  - `bypass_case`
  - `lfnst_enabled_case`
  - `lfnst_enabled_case` 中第 `1` 组输出后的单拍 `out_req` 反压

本轮结果归档在：

- [题1_LFNST到IDCT2二维4x4链路UVM验证记录_v1.md](../09_reports/题1_LFNST到IDCT2二维4x4链路UVM验证记录_v1.md)

## 当前意义

做到这一步后，题1现在已经有三层验证形态：

- 单模块 directed/UVM
- 子链路 directed/UVM
- 二维闭环 directed/UVM

后面继续抽：

- 通用 `transpose buffer`
- 更大块型
- `DCT8 / DST7`

时，可以直接沿这套 transaction/scoreboard/assertion 模式扩。
