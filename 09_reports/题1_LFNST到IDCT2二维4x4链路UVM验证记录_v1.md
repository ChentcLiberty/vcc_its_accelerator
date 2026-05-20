# 题1 LFNST到IDCT2二维4x4链路UVM验证记录 v1

时间：`2026-05-20`

## 本轮目标

在现有 directed 二维闭环之外，给 `LFNST -> 列向 IDCT2 -> 行向 IDCT2` 这条 `4x4` 链路补一套轻量 `UVM` 骨架，并实际跑通。

## 新增文件

- [lfnst_idct2_2d4_if.sv](../06_tb/uvm_lfnst_idct2_2d4/lfnst_idct2_2d4_if.sv)
- [lfnst_idct2_2d4_uvm_pkg.sv](../06_tb/uvm_lfnst_idct2_2d4/lfnst_idct2_2d4_uvm_pkg.sv)
- [tb_lfnst_idct2_2d4_uvm_top.sv](../06_tb/uvm_lfnst_idct2_2d4/tb_lfnst_idct2_2d4_uvm_top.sv)
- [run_vcs_lfnst_idct2_2d4_uvm.sh](../08_scripts/run_vcs_lfnst_idct2_2d4_uvm.sh)
- [题1_LFNST到IDCT2二维4x4链路UVM验证说明_v1.md](../03_验证计划/题1_LFNST到IDCT2二维4x4链路UVM验证说明_v1.md)

## 这版UVM实际做了什么

- 用 `sequence item` 描述一个二维链路 case
- 用 `driver` 驱动：
  - `start`
  - `lfnst_tr_set_idx`
  - `lfnst_idx`
  - `x_bar`
  - `out_req`
- 用 `monitor` 采样最终二维输出组
- 用 `scoreboard` 按组与二维 golden 比较
- 在 interface 中补了输出反压保持断言

## 验证项

1. `bypass_case`
2. `lfnst_enabled_case`

并在 `lfnst_enabled_case` 中插入一次 `out_req` 单拍反压。

## 实际运行命令

```bash
./08_scripts/run_vcs_lfnst_idct2_2d4_uvm.sh
```

脚本固定在 `/tmp/lfnst_idct2_2d4_uvm_build` 下编译和运行，规避共享目录上下文下的 `VCS` link/symlink 问题。

## 实际结果

- `VCS` 编译通过
- `UVM` 运行通过
- `UVM_ERROR = 0`
- `UVM_FATAL = 0`

scoreboard 通过的场景：

- `bypass_case`
- `lfnst_enabled_case`

额外覆盖的协议场景：

- 在 `lfnst_enabled_case` 中对第 `1` 组输出插入一次单拍 `out_req` 反压
- interface assertion 检查 `out_valid && !out_req` 时输出组保持

## 结论

这条 `4x4` 二维链路现在已经同时具备：

- directed 功能闭环
- 轻量 `UVM` smoke 闭环

后续继续往：

- 通用 `transpose buffer`
- 更大块型
- `DCT8 / DST7`

扩展时，可以沿用同一套 transaction、scoreboard 和 assertion 结构。
