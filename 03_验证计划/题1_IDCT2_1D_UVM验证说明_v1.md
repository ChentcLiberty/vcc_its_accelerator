# 题1 IDCT2 1D UVM验证说明 v1

## 这版在做什么

这版不是替换现有 directed self-check testbench，而是在其基础上补一套轻量 `UVM` 骨架，目标是把后续题1的模块级验证方法学立起来。

当前覆盖对象：

- `idct2_1d_core`

当前方法学组件：

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

- interface： [idct2_1d_if.sv](../06_tb/uvm_idct2_1d/idct2_1d_if.sv)
- package： [idct2_1d_uvm_pkg.sv](../06_tb/uvm_idct2_1d/idct2_1d_uvm_pkg.sv)
- top： [tb_idct2_1d_uvm_top.sv](../06_tb/uvm_idct2_1d/tb_idct2_1d_uvm_top.sv)
- 运行脚本： [run_vcs_idct2_1d_uvm.sh](../08_scripts/run_vcs_idct2_1d_uvm.sh)

## 运行方式

```bash
./08_scripts/run_vcs_idct2_1d_uvm.sh
```

脚本会固定在 `/tmp/idct2_1d_uvm_build` 下编译和运行。

这么做是为了避开共享目录上下文下的 `VCS` link/symlink 失败问题；切到 `/tmp` 本地目录后，`compile/elab/link/run` 都能稳定完成。

## 当前结构

### Driver

负责：

- 驱动 `start / n_tbs / non_zero_size / x_vec`
- 控制 `out_req`
- 将当前 case 的 expected transaction 发给 scoreboard

### Monitor

负责：

- 采样 `out_valid && out_req` 成功握手的输出组
- 输出 `base_idx / out_last / data[4]`

### Scoreboard

负责：

- 按 case 顺序消费 expected transaction
- 按组比较：
  - `out_index_base`
  - `out_last`
  - `out_data_0..3`

### Interface Assertion

当前加了一条很重要的 `hold_when_blocked` 断言：

- 当 `out_valid = 1` 且 `out_req = 0` 时
- 下一拍输出组必须保持不变

这正好对应题面的输出反压要求。

## 为什么现在上 UVM 是合适的

之前不急着上，是因为：

- 矩阵和 golden model 还没收稳

现在适合补 UVM，是因为：

- `LFNST` 已经有稳定 model 和 RTL
- `IDCT2` 已经有稳定 model、ROM、RTL 和 directed self-check
- 这时再引入方法学，能复用到后面的：
  - `IDCT8`
  - `IDST7`
  - `LFNST -> IDCT2`
  - 最终 `ITS top`

## 当前边界

这版 UVM 还是轻量版，不是大而全平台：

- 没接 Python DPI
- 没做约束随机
- 没做 coverage
- 没做多 agent 顶层系统验证

当前重点很明确：

- 建立可复用的 block-level UVM 骨架
- 用 transaction 和 scoreboard 取代纯手工过程式对拍

## 当前验证结果

- `VCS UVM` 已跑通
- `UVM_ERROR = 0`
- `UVM_FATAL = 0`
- 已覆盖：
  - `4-point`
  - `8-point`
  - `16-point`
  - `32-point`
  - `64-point`
  - `8-point` 单拍 `out_req` 反压

## 后续复用建议

后面最自然的扩展顺序是：

1. 给 `IDCT8 / IDST7` 复用同一套 agent/scoreboard 结构
2. 把 `LFNST` 也接成 transaction 化输入输出
3. 做 `LFNST -> IDCT2` 的联调 env
4. 再考虑顶层 `ITS` 的多阶段 reference compare
