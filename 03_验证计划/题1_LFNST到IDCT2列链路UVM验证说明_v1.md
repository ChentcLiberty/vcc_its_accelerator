# 题1 LFNST到IDCT2列链路UVM验证说明 v1

## 这版在做什么

这版是在已经通过 directed 联调的基础上，给 `4x4` 的 `LFNST -> 列向 IDCT2` 子链路补一套轻量 `UVM` 骨架。

当前覆盖对象：

- [lfnst_idct2_col4_core.v](../05_rtl/lfnst_idct2_col4_core.v)

目标不是做大而全平台，而是把链路级方法学立起来：

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

- interface： [lfnst_idct2_col4_if.sv](../06_tb/uvm_lfnst_idct2_col4/lfnst_idct2_col4_if.sv)
- package： [lfnst_idct2_col4_uvm_pkg.sv](../06_tb/uvm_lfnst_idct2_col4/lfnst_idct2_col4_uvm_pkg.sv)
- top： [tb_lfnst_idct2_col4_uvm_top.sv](../06_tb/uvm_lfnst_idct2_col4/tb_lfnst_idct2_col4_uvm_top.sv)
- 运行脚本： [run_vcs_lfnst_idct2_col4_uvm.sh](../08_scripts/run_vcs_lfnst_idct2_col4_uvm.sh)

## 当前结构

### Driver

负责：

- 驱动 `start / lfnst_tr_set_idx / lfnst_idx / x_bar`
- 控制 `out_req`
- 将当前 case 的 expected transaction 发给 scoreboard

### Monitor

负责：

- 采样 `out_valid && out_req` 成功握手的输出组
- 输出 `row_base / out_last / data[4]`

### Scoreboard

负责：

- 按 case 顺序消费 expected transaction
- 按组比较：
  - `out_row_base`
  - `out_last`
  - `out_data_0..3`

### Interface Assertion

当前在 interface 中加了一条 `hold_when_blocked` 断言：

- 当 `out_valid = 1` 且 `out_req = 0`
- 下一拍：
  - `out_row_base` 必须保持
  - `out_last` 必须保持
  - `out_data_0..3` 必须保持

## 当前 smoke case

1. `bypass_case`
   - `lfnst_idx = 0`
   - 验证 `scan remap + column IDCT2`
2. `lfnst_enabled_case`
   - `lfnst_idx = 1`
   - 验证真实 `LFNST -> IDCT2` 链路
   - 在第 `1` 组输出后插入一次单拍 `out_req` 反压

## 运行方式

```bash
./08_scripts/run_vcs_lfnst_idct2_col4_uvm.sh
```

脚本会固定在 `/tmp/lfnst_idct2_col4_uvm_build` 下编译和运行，避免共享目录上下文下的 `VCS` link/symlink 问题。

## 当前意义

这版补完之后，题1的验证方法学就形成了两层：

- directed 联调：快速功能闭环
- light UVM：链路级 transaction + scoreboard + assertion

后面继续往：

- `transpose buffer`
- 行向第二次 `1D`
- 最终 `ITS top`

推进时，都可以沿这套模式扩。 

## 当前验证结果

- `VCS UVM` 已跑通
- `UVM_ERROR = 0`
- `UVM_FATAL = 0`
- 已覆盖：
  - `bypass_case`
  - `lfnst_enabled_case`
  - `lfnst_enabled_case` 单拍 `out_req` 反压
