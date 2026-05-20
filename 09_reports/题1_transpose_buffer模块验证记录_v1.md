# 题1 transpose buffer 模块验证记录 v1

时间：`2026-05-20`

## 本轮目标

新增独立的：

- [its_transpose_buffer.v](../05_rtl/its_transpose_buffer.v)

并让二维 `4x4` 链路从内部寄存器阵列切到这个通用模块。

## 新增文件

- [its_transpose_buffer.v](../05_rtl/its_transpose_buffer.v)
- [tb_its_transpose_buffer.sv](../06_tb/tb_its_transpose_buffer.sv)
- [run_vcs_its_transpose_buffer.sh](../08_scripts/run_vcs_its_transpose_buffer.sh)
- [题1_transpose_buffer设计_v1.md](../02_架构设计/题1_transpose_buffer设计_v1.md)
- [题1_transpose_buffer验证说明_v1.md](../03_验证计划/题1_transpose_buffer验证说明_v1.md)

## 计划验证项

1. 普通行视图读
2. 转置视图读
3. 越界读返回 `0`
4. `clear` 后内容清空
5. 二维 `4x4` directed 回归
6. 二维 `4x4` UVM smoke 回归

## 实际结果

- `transpose buffer` directed：
  - 运行命令：`./08_scripts/run_vcs_its_transpose_buffer.sh`
  - 结果：`PASS tb_its_transpose_buffer`
- 二维 `4x4` directed 回归：
  - 运行命令：`./08_scripts/run_vcs_lfnst_idct2_2d4.sh`
  - 结果：`PASS tb_lfnst_idct2_2d4_core`
- 二维 `4x4` UVM smoke 回归：
  - 运行命令：`./08_scripts/run_vcs_lfnst_idct2_2d4_uvm.sh`
  - 结果：`UVM_ERROR = 0`，`UVM_FATAL = 0`

## 结论

这轮重构把二维链路里的中间矩阵缓存抽成独立模块后：

- 新模块自身功能通过
- 原有二维 directed 闭环没有回退
- 原有二维 `UVM` smoke 闭环也没有回退

所以当前可以把 `its_transpose_buffer` 视为后续更大块型扩展的稳定中间层。
