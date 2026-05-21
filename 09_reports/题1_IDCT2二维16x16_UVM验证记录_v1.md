# 题1 IDCT2 二维16x16 UVM验证记录 v1

时间：`2026-05-21`

## 本轮目标

在现有 directed `16x16` 二维 `IDCT2` 闭环之外，补一套轻量 `UVM` smoke 环境。

## 新增文件

- [idct2_2d16_if.sv](../06_tb/uvm_idct2_2d16/idct2_2d16_if.sv)
- [idct2_2d16_uvm_pkg.sv](../06_tb/uvm_idct2_2d16/idct2_2d16_uvm_pkg.sv)
- [tb_idct2_2d16_uvm_top.sv](../06_tb/uvm_idct2_2d16/tb_idct2_2d16_uvm_top.sv)
- [run_vcs_idct2_2d16_uvm.sh](../08_scripts/run_vcs_idct2_2d16_uvm.sh)
- [题1_IDCT2二维16x16_UVM验证说明_v1.md](../03_验证计划/题1_IDCT2二维16x16_UVM验证说明_v1.md)

## 计划验证项

1. `full16_case`
2. `sparse8_case`
3. `out_index_base`
4. `out_last`
5. 单拍 `out_req` 反压保持

## 实际结果

- 实际运行命令：

```bash
./08_scripts/run_vcs_idct2_2d16_uvm.sh
```

- 结果：
  - `UVM_ERROR = 0`
  - `UVM_FATAL = 0`
- 覆盖到的 smoke case：
  - `full16_case`
  - `sparse8_case`
- 额外检查：
  - 第 `8` 组输出后的单拍 `out_req` 反压保持
  - `out_index_base` 按 `4` 递增
  - 末组 `out_last`
  - `4` 路输出数据与 golden 一致
