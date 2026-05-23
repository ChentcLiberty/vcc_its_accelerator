# 题1 官方接口顶层第一版 UVM 验证记录 v1

时间：`2026-05-23`

## 本轮目标

给官方接口顶层第一版补一套轻量 `UVM` smoke，把前一轮 directed 已经验证过的 stage1 子集收成：

- driver / monitor / scoreboard
- case 化输入
- golden 文件驱动
- `VCS UVM` 一键回归

然后在这一轮继续往接口级真实场景扩：

- sparse 输入
- 乱序地址装载
- 多次 `it_data_out_req` 反压

## 新增文件

- [gen_official_if_stage1_expected.py](../08_scripts/gen_official_if_stage1_expected.py)
- [official_if_stage1_4x4_lfnst_expected.txt](../06_tb/data/official_if_stage1_4x4_lfnst_expected.txt)
- [official_if_stage1_8x8_dct2_expected.txt](../06_tb/data/official_if_stage1_8x8_dct2_expected.txt)
- [official_if_stage1_8x8_dst7_expected.txt](../06_tb/data/official_if_stage1_8x8_dst7_expected.txt)
- [official_if_stage1_8x8_dct8_expected.txt](../06_tb/data/official_if_stage1_8x8_dct8_expected.txt)
- [official_if_stage1_8x8_dct2_sparse_expected.txt](../06_tb/data/official_if_stage1_8x8_dct2_sparse_expected.txt)
- [official_if_stage1_8x8_dst7_sparse_expected.txt](../06_tb/data/official_if_stage1_8x8_dst7_sparse_expected.txt)
- [official_if_stage1_16x16_dct2_expected.txt](../06_tb/data/official_if_stage1_16x16_dct2_expected.txt)
- [official_if_stage1_16x16_dst7_expected.txt](../06_tb/data/official_if_stage1_16x16_dst7_expected.txt)
- [official_if_stage1_16x16_dct8_expected.txt](../06_tb/data/official_if_stage1_16x16_dct8_expected.txt)
- [official_if_stage1_16x16_dct8_sparse_expected.txt](../06_tb/data/official_if_stage1_16x16_dct8_sparse_expected.txt)
- [its_top_official_if_stage1_if.sv](../06_tb/uvm_its_top_official_if_stage1/its_top_official_if_stage1_if.sv)
- [its_top_official_if_stage1_uvm_pkg.sv](../06_tb/uvm_its_top_official_if_stage1/its_top_official_if_stage1_uvm_pkg.sv)
- [tb_its_top_official_if_stage1_uvm_top.sv](../06_tb/uvm_its_top_official_if_stage1/tb_its_top_official_if_stage1_uvm_top.sv)
- [run_vcs_its_top_official_if_stage1_uvm.sh](../08_scripts/run_vcs_its_top_official_if_stage1_uvm.sh)

## 实际运行

```bash
./08_scripts/run_vcs_its_top_official_if_stage1_uvm.sh
```

## 预期覆盖

1. `case_4x4_lfnst`
2. `case_8x8_dct2`
3. `case_8x8_dst7`
4. `case_8x8_dct8`
5. `case_8x8_dct2_sparse`
6. `case_8x8_dst7_sparse`
7. `case_16x16_dct2`
8. `case_16x16_dst7`
9. `case_16x16_dct8`
10. `case_16x16_dct8_sparse`
11. `case_unsupported`

并额外检查：

- `case_16x16_dct8` 的单拍 `out_req` 反压
- `case_8x8_dst7_sparse` 的两次 `out_req` 反压
- `case_16x16_dct8_sparse` 的三次 `out_req` 反压
- sparse case 的乱序地址输入
- unsupported 模式不应产生任何 `it_data_out_vld`

## 本轮结果

- golden 生成通过
- `VCS UVM` 编译通过
- `UVM_ERROR = 0`
- `UVM_FATAL = 0`
- `UVM_INFO = 13`
- scoreboard 逐 case 检查通过：
  1. `case_4x4_lfnst`
  2. `case_8x8_dct2`
  3. `case_8x8_dst7`
  4. `case_8x8_dct8`
  5. `case_8x8_dct2_sparse`
  6. `case_8x8_dst7_sparse`
  7. `case_16x16_dct2`
  8. `case_16x16_dst7`
  9. `case_16x16_dct8`
  10. `case_16x16_dct8_sparse`
  11. `case_unsupported`

## 当前结论

这版已经把官方接口顶层第一版现有可用子集收成一套可复用的 `UVM` 骨架，并且实际跑通了 `VCS UVM` smoke。当前 `UVM` 不只覆盖 stage1 已支持模式全集，也已经补进了 sparse 输入、乱序地址和多次输出反压。后续主要是继续往 `32x32/64x64` 和更完整赛题模式矩阵推进。
