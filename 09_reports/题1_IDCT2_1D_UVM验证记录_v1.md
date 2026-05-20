# 题1 IDCT2 1D UVM验证记录 v1

时间：`2026-05-20`

## 本轮目标

在现有 directed self-check testbench 之外，补一套可复用的轻量 `UVM` 骨架，用于后续题1模块级和联调级验证扩展。

## 新增文件

- [idct2_1d_if.sv](../06_tb/uvm_idct2_1d/idct2_1d_if.sv)
- [idct2_1d_uvm_pkg.sv](../06_tb/uvm_idct2_1d/idct2_1d_uvm_pkg.sv)
- [tb_idct2_1d_uvm_top.sv](../06_tb/uvm_idct2_1d/tb_idct2_1d_uvm_top.sv)
- [run_vcs_idct2_1d_uvm.sh](../08_scripts/run_vcs_idct2_1d_uvm.sh)
- [题1_IDCT2_1D_UVM验证说明_v1.md](../03_验证计划/题1_IDCT2_1D_UVM验证说明_v1.md)

## 这版UVM实际做了什么

- 用 `sequence item` 描述一个 `IDCT2` 输入 case
- 用 `driver` 驱动：
  - `start`
  - `n_tbs`
  - `non_zero_size`
  - `x_vec`
  - `out_req`
- 用 `monitor` 采样输出组
- 用 `scoreboard` 按组与 golden 比较
- 在 interface 中补了输出反压保持断言

## 计划验证项

与当前 directed self-check 保持一致：

1. `4, 4`
2. `8, 8`
3. `16, 8`
4. `32, 8`
5. `64, 16`

并在 `8-point` case 中插入一次 `out_req` 单拍反压。

## 实际运行命令

```bash
./08_scripts/run_vcs_idct2_1d_uvm.sh
```

脚本内部会：

1. 进入 `/tmp/idct2_1d_uvm_build`
2. 用 `VCS + UVM-1.2` 编译
3. 运行 `./idct2_1d_uvm_simv +UVM_NO_RELNOTES`

## 验证结果

`VCS UVM` 已通过。

关键日志结论：

- `Running test idct2_1d_uvm_test`
- `IDCT2_SB` 依次检查：
  - `case_4`
  - `case_8`
  - `case_16`
  - `case_32`
  - `case_64`
- `UVM_ERROR : 0`
- `UVM_FATAL : 0`

仿真结束时间：

- `765000 ps`

## 本轮发现的问题和修正

### 问题1：共享目录上下文下的 VCS 链接失败

现象：

- 直接在共享目录上下文里跑 UVM 编译时，`VCS` 在 link 阶段创建归档链接失败

修正：

- 运行脚本切到 `/tmp/idct2_1d_uvm_build`
- 增加 `-Mdir=./csrc`

### 问题2：timescale 口径需要统一

现象：

- UVM 编译时不适合让不同文件各自带不一致的 timescale 定义

修正：

- 统一在 `VCS` 命令行里使用 `-timescale=1ns/1ps`

## 当前结论

这套轻量 `UVM` 已经可以作为后续 `IDCT8 / IDST7 / LFNST -> IDCT2` 联调环境的模板继续复用。
