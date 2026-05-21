# 题1 IDCT2 二维8x8 UVM验证说明 v1

## 验证对象

- [idct2_2d8_core.v](../05_rtl/idct2_2d8_core.v)

## 这版做什么

这版是在已经通过 directed 的 `8x8` 二维 `IDCT2` 基础上，补一套轻量 `UVM` smoke 环境。

对应文件：

- interface： [idct2_2d8_if.sv](../06_tb/uvm_idct2_2d8/idct2_2d8_if.sv)
- package： [idct2_2d8_uvm_pkg.sv](../06_tb/uvm_idct2_2d8/idct2_2d8_uvm_pkg.sv)
- top： [tb_idct2_2d8_uvm_top.sv](../06_tb/uvm_idct2_2d8/tb_idct2_2d8_uvm_top.sv)
- 脚本： [run_vcs_idct2_2d8_uvm.sh](../08_scripts/run_vcs_idct2_2d8_uvm.sh)

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

## 当前 smoke case

1. `full8_case`
   - `non_zero_cols = 8`
   - `non_zero_rows = 8`
   - 在第 `4` 组输出后插入一次单拍 `out_req` 反压
2. `sparse4_case`
   - `non_zero_cols = 4`
   - `non_zero_rows = 4`
   - 验证稀疏有效尺寸截断

## 运行方式

```bash
./08_scripts/run_vcs_idct2_2d8_uvm.sh
```

脚本固定在 `/tmp/idct2_2d8_uvm_build` 下编译和运行，避免共享目录上下文下的 `VCS` link/symlink 问题。

## 当前意义

做到这一步后，`8x8` 这条更大块型路径也会同时具备：

- directed 闭环
- 轻量 `UVM` smoke 闭环

后续继续扩到：

- `16x16`
- `DCT8 / DST7`
- 更复杂调度

时，可以直接沿用这套 transaction / scoreboard / assertion 结构。

## 本轮实际结果

- `VCS` 编译通过
- `UVM_ERROR = 0`
- `UVM_FATAL = 0`
- 已通过：
  - `full8_case`
  - `sparse4_case`
  - `full8_case` 中第 `4` 组输出后的单拍 `out_req` 反压
