# 题1 ITS 1D UVM验证说明 v1

## 这版在做什么

这版不是替换已有 directed 自检，而是在通用 `ITS 1D` 核已经通过 directed 的基础上，补一套轻量 `UVM` 骨架。

当前覆盖对象：

- [its_1d_core.v](../05_rtl/its_1d_core.v)

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

- interface： [its_1d_if.sv](../06_tb/uvm_its_1d/its_1d_if.sv)
- package： [its_1d_uvm_pkg.sv](../06_tb/uvm_its_1d/its_1d_uvm_pkg.sv)
- top： [tb_its_1d_uvm_top.sv](../06_tb/uvm_its_1d/tb_its_1d_uvm_top.sv)
- 运行脚本： [run_vcs_its_1d_uvm.sh](../08_scripts/run_vcs_its_1d_uvm.sh)

## 当前 smoke case

1. `dct2_8_sparse4`
2. `dct8_8_full`
3. `dst7_8_full`
4. `dct8_32_full`
5. `dst7_32_full`

其中：

- `dct2_8_sparse4` 用来确认原 `DCT2` 路径在共享核中没有回退
- `dst7_8_full` 覆盖了一次单拍 `out_req` 反压

## 运行方式

```bash
./08_scripts/run_vcs_its_1d_uvm.sh
```

脚本固定在 `/tmp/its_1d_uvm_build` 下编译运行，避免共享目录上的 `VCS` link/symlink 问题。

## 当前验证结果

- `VCS UVM` 已跑通
- `UVM_ERROR = 0`
- `UVM_FATAL = 0`
- 已覆盖：
  - `DCT2 / DCT8 / DST7`
  - `8-point / 32-point`
  - `non_zero_size` 截断场景
  - 单拍 `out_req` 反压

## 当前意义

做到这一步后，题面里三类 `1D` 变换已经同时具备：

- directed 闭环
- 轻量 `UVM` smoke 闭环

后续把 `DCT8/DST7` 接入二维链路时，可以直接复用这套 transaction / scoreboard / assertion 结构。
