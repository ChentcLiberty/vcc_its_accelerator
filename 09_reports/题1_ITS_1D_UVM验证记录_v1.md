# 题1 ITS 1D UVM验证记录 v1

时间：`2026-05-21`

## 本轮目标

给共享 `ITS 1D` 核补一套轻量 `UVM` smoke 环境，覆盖 `DCT2 / DCT8 / DST7` 三类 `1D` 变换。

## 新增文件

- [its_1d_if.sv](../06_tb/uvm_its_1d/its_1d_if.sv)
- [its_1d_uvm_pkg.sv](../06_tb/uvm_its_1d/its_1d_uvm_pkg.sv)
- [tb_its_1d_uvm_top.sv](../06_tb/uvm_its_1d/tb_its_1d_uvm_top.sv)
- [run_vcs_its_1d_uvm.sh](../08_scripts/run_vcs_its_1d_uvm.sh)
- [题1_ITS_1D_UVM验证说明_v1.md](../03_验证计划/题1_ITS_1D_UVM验证说明_v1.md)

## 实际运行

```bash
./08_scripts/run_vcs_its_1d_uvm.sh
```

## 验证结果

- `VCS` 编译通过
- `VCS UVM` 运行通过
- `UVM_ERROR = 0`
- `UVM_FATAL = 0`

## 覆盖到的 smoke case

1. `dct2_8_sparse4`
2. `dct8_8_full`
3. `dst7_8_full`
4. `dct8_32_full`
5. `dst7_32_full`

## 额外检查

- `out_index_base`
- `out_last`
- `4 lane data`
- 单拍 `out_req` 反压保持
