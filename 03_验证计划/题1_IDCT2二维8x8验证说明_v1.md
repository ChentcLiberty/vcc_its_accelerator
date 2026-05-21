# 题1 IDCT2 二维8x8验证说明 v1

## 验证对象

- [idct2_2d8_core.v](../05_rtl/idct2_2d8_core.v)

## Golden来源

二维 `8x8` golden 来自：

- [idct2_2d_ref.py](../07_model/idct2_2d_ref.py)

当前 demo case 使用：

- 输入矩阵：`1..64` 按行优先展开
- `non_zero_cols = 8`
- `non_zero_rows = 8`

## 当前验证目标

1. 行向 `IDCT2` 到中间 buffer 的写入正确
2. 转置读列向量后，列向 `IDCT2` 结果正确
3. 转置写最终矩阵后，按行优先 `4点/拍` 输出正确
4. `out_req` 单拍反压时，输出组保持

## directed testbench

- [tb_idct2_2d8_core.sv](../06_tb/tb_idct2_2d8_core.sv)

运行脚本：

- [run_vcs_idct2_2d8.sh](../08_scripts/run_vcs_idct2_2d8.sh)

## 当前边界

这版还是 directed 闭环：

- 不做 `UVM`
- 不做随机矩阵回归
- 不做 `16x16` 及更大块型

目标很明确：

- 先把第一版 `8x8` 二维 `IDCT2` 大块型路径收稳

## 本轮实际结果

- `VCS` 编译通过
- directed 仿真通过
- 已检查：
  - `out_index_base`
  - `out_last`
  - `done`
  - 单拍 `out_req` 反压保持
