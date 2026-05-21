# 题1 transpose buffer 验证说明 v1

## 验证对象

- [its_transpose_buffer.v](../05_rtl/its_transpose_buffer.v)

## 这版验证什么

这版先验证三件事：

1. 行优先写入后，普通读视图是否正确
2. 同一份存储内容在转置读视图下是否正确
3. 转置写入后，普通读视图和转置读视图是否一致
4. 越界读和 `clear` 是否按预期工作

## directed testbench

对应 testbench：

- [tb_its_transpose_buffer.sv](../06_tb/tb_its_transpose_buffer.sv)

运行脚本：

- [run_vcs_its_transpose_buffer.sh](../08_scripts/run_vcs_its_transpose_buffer.sh)

## 当前测试场景

### 场景1：普通行视图

写入一个 `4x8` 矩阵后，检查：

- 第 `1` 行第 `0` 组
- 第 `2` 行第 `4` 组

### 场景2：转置视图

对同一个 `4x8` 矩阵，检查：

- 第 `0` 列
- 第 `3` 列
- 第 `7` 列

都能在转置视图下按“连续 `4` 点”读对。

### 场景3：边界和清空

检查：

- 普通视图越界列读返回 `0`
- 转置视图越界列读返回 `0`
- `clear` 后普通视图再读返回 `0`

### 场景4：转置写

检查：

- `wr_transpose = 1` 时固定列连续写入
- 再从普通行视图读取时，元素是否落在预期行列位置
- 再从转置视图读取时，向量是否保持一致

## 链路级回归

除了这个模块级 directed testbench，这轮还会继续回归：

- [run_vcs_lfnst_idct2_2d4.sh](../08_scripts/run_vcs_lfnst_idct2_2d4.sh)
- [run_vcs_lfnst_idct2_2d4_uvm.sh](../08_scripts/run_vcs_lfnst_idct2_2d4_uvm.sh)

目的不是重复验证 buffer 自身，而是确认二维 `4x4` 链路在接入独立 `transpose buffer` 后没有功能回退。
