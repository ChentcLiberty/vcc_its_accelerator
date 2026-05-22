# 题1 官方接口顶层第一版 UVM 验证说明 v1

## 验证对象

- [its_top_official_if_stage1.v](../05_rtl/its_top_official_if_stage1.v)

## 本轮目标

把官方接口顶层第一版从增强 directed，推进到一套轻量 `UVM` smoke 骨架，重点验证：

1. `it_info` 驱动
2. `it_data_in_req` 握手
3. 光栅地址装载
4. `40-bit` 输出打包
5. `it_done` 收尾
6. unsupported 模式不产出结果
7. `it_data_out_req` 单拍反压

## 本轮 UVM 结构

- interface：
  - [its_top_official_if_stage1_if.sv](../06_tb/uvm_its_top_official_if_stage1/its_top_official_if_stage1_if.sv)
- package：
  - [its_top_official_if_stage1_uvm_pkg.sv](../06_tb/uvm_its_top_official_if_stage1/its_top_official_if_stage1_uvm_pkg.sv)
- top：
  - [tb_its_top_official_if_stage1_uvm_top.sv](../06_tb/uvm_its_top_official_if_stage1/tb_its_top_official_if_stage1_uvm_top.sv)
- run script：
  - [run_vcs_its_top_official_if_stage1_uvm.sh](../08_scripts/run_vcs_its_top_official_if_stage1_uvm.sh)

## 参考策略

这版官方接口 UVM 不再在 scoreboard 里临时调用 live reference，而是统一改成“离线 golden 文件 + UVM 驱动”：

- [gen_official_if_stage1_expected.py](../08_scripts/gen_official_if_stage1_expected.py)

当前生成三组 stage1 golden：

1. `4x4 DCT2 + LFNST`
2. `8x8 DCT8`
3. `16x16 DCT8`

输出文件都放在 [06_tb/data](../06_tb/data) 下，内容是顶层 `10-bit` 饱和后的逐点期望值。

## 当前 case

1. `case_4x4_lfnst`
2. `case_8x8_dct8`
3. `case_16x16_dct8`
4. `case_unsupported`

其中 `case_16x16_dct8` 带一组 `out_req` 单拍反压。

## 运行方式

```bash
./08_scripts/run_vcs_its_top_official_if_stage1_uvm.sh
```

## 当前边界

这版 `UVM` 仍然只覆盖官方接口顶层第一版已支持的子集：

- `4x4 DCT2 + LFNST`
- `8x8 DCT8`
- `16x16 DCT8`
- unsupported 模式

还没有覆盖：

- `8x8 DCT2`
- `8x8 DST7`
- `16x16 DCT2`
- `16x16 DST7`
- 更复杂的多次反压或乱序输入场景
