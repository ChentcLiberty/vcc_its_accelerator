# 题1 IDCT2 二维16x16 UVM验证说明 v1

## 验证对象

- [idct2_2d16_core.v](../05_rtl/idct2_2d16_core.v)

## 这版做什么

这版是在已经通过 directed 的 `16x16` 二维 `IDCT2` 基础上，补一套轻量 `UVM` smoke 环境。

对应文件：

- interface： [idct2_2d16_if.sv](../06_tb/uvm_idct2_2d16/idct2_2d16_if.sv)
- package： [idct2_2d16_uvm_pkg.sv](../06_tb/uvm_idct2_2d16/idct2_2d16_uvm_pkg.sv)
- top： [tb_idct2_2d16_uvm_top.sv](../06_tb/uvm_idct2_2d16/tb_idct2_2d16_uvm_top.sv)
- 脚本： [run_vcs_idct2_2d16_uvm.sh](../08_scripts/run_vcs_idct2_2d16_uvm.sh)

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

1. `full16_case`
   - `non_zero_cols = 16`
   - `non_zero_rows = 16`
   - 在第 `8` 组输出后插入一次单拍 `out_req` 反压
2. `sparse8_case`
   - `non_zero_cols = 8`
   - `non_zero_rows = 8`
   - 验证稀疏有效尺寸截断

## 运行方式

```bash
./08_scripts/run_vcs_idct2_2d16_uvm.sh
```

脚本固定在 `/tmp/idct2_2d16_uvm_build` 下编译和运行，避免共享目录上下文下的 `VCS` link/symlink 问题。

## 本轮结果

- `VCS UVM` smoke 回归已通过
- `UVM_ERROR = 0`
- `UVM_FATAL = 0`
- 已覆盖：
  - `full16_case`
  - `sparse8_case`
  - 第 `8` 组输出后的单拍 `out_req` 反压
  - `out_index_base / out_last / 4 lane data`

## 当前意义

做到这一步后，`16x16` 这条更大块型路径已经同时具备：

- directed 闭环
- 轻量 `UVM` smoke 闭环

后续继续扩到：

- `32x32`
- `DCT8 / DST7`
- 更复杂调度

时，可以直接沿用这套 transaction / scoreboard / assertion 结构。
