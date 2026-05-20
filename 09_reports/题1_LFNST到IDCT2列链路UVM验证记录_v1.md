# 题1 LFNST到IDCT2列链路UVM验证记录 v1

时间：`2026-05-20`

## 本轮目标

在现有 directed 联调之外，给 `LFNST -> 列向 IDCT2` 这条 `4x4` 子链路补一套轻量 `UVM` 骨架，并实际跑通。

## 新增文件

- [lfnst_idct2_col4_if.sv](../06_tb/uvm_lfnst_idct2_col4/lfnst_idct2_col4_if.sv)
- [lfnst_idct2_col4_uvm_pkg.sv](../06_tb/uvm_lfnst_idct2_col4/lfnst_idct2_col4_uvm_pkg.sv)
- [tb_lfnst_idct2_col4_uvm_top.sv](../06_tb/uvm_lfnst_idct2_col4/tb_lfnst_idct2_col4_uvm_top.sv)
- [run_vcs_lfnst_idct2_col4_uvm.sh](../08_scripts/run_vcs_lfnst_idct2_col4_uvm.sh)
- [题1_LFNST到IDCT2列链路UVM验证说明_v1.md](../03_验证计划/题1_LFNST到IDCT2列链路UVM验证说明_v1.md)

## 这版UVM实际做了什么

- 用 `sequence item` 描述一个子链路 case
- 用 `driver` 驱动：
  - `start`
  - `lfnst_tr_set_idx`
  - `lfnst_idx`
  - `x_bar`
  - `out_req`
- 用 `monitor` 采样输出组
- 用 `scoreboard` 按组与 golden 比较
- 在 interface 中补了输出反压保持断言

## 计划验证项

1. `bypass_case`
2. `lfnst_enabled_case`

并在 `lfnst_enabled_case` 中插入一次 `out_req` 单拍反压。

## 当前说明

这份记录已经补齐到“可复现并已实跑通过”的状态。

## 实际运行命令

```bash
./08_scripts/run_vcs_lfnst_idct2_col4_uvm.sh
```

脚本内部会：

1. 进入 `/tmp/lfnst_idct2_col4_uvm_build`
2. 用 `VCS + UVM-1.2` 编译
3. 运行 `./lfnst_idct2_col4_uvm_simv +UVM_NO_RELNOTES`

## 验证结果

`VCS UVM` 已通过。

关键日志结论：

- `Running test lfnst_idct2_col4_uvm_test`
- `CHAIN_SB` 依次检查：
  - `bypass_case`
  - `lfnst_enabled_case`
- `UVM_ERROR : 0`
- `UVM_FATAL : 0`

仿真结束时间：

- `895000 ps`

## 本轮发现的问题和修正

### 问题1：链路级反压不适合硬塞进 directed testbench

现象：

- directed 版本里把 `out_req` 拉低的时机放在拍边界之后，很容易观察到“已经前进到下一组”，而不是合法 hold 场景

修正：

- 把链路级反压检查放到 UVM driver + interface assertion 里
- 在 `lfnst_enabled_case` 中插入一次单拍 `out_req` 反压

### 问题2：共享目录上下文下的 VCS 链接问题

现象：

- `VCS UVM` 在共享目录上下文里 link/symlink 容易失败

修正：

- 运行脚本固定切到 `/tmp/lfnst_idct2_col4_uvm_build`
- 增加 `-Mdir=./csrc`

## 当前结论

这条 `4x4` 子链路现在已经具备两层验证闭环：

- directed 联调
- light UVM

后续继续做 `transpose buffer` 和完整 `2D ITS` 时，可以直接复用这套 transaction/scoreboard/assertion 模式。
