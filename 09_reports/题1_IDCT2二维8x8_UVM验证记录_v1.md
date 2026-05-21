# 题1 IDCT2 二维8x8 UVM验证记录 v1

时间：`2026-05-21`

## 本轮目标

在现有 directed `8x8` 二维 `IDCT2` 闭环之外，补一套轻量 `UVM` smoke 环境。

## 新增文件

- [idct2_2d8_if.sv](../06_tb/uvm_idct2_2d8/idct2_2d8_if.sv)
- [idct2_2d8_uvm_pkg.sv](../06_tb/uvm_idct2_2d8/idct2_2d8_uvm_pkg.sv)
- [tb_idct2_2d8_uvm_top.sv](../06_tb/uvm_idct2_2d8/tb_idct2_2d8_uvm_top.sv)
- [run_vcs_idct2_2d8_uvm.sh](../08_scripts/run_vcs_idct2_2d8_uvm.sh)
- [题1_IDCT2二维8x8_UVM验证说明_v1.md](../03_验证计划/题1_IDCT2二维8x8_UVM验证说明_v1.md)

## 计划验证项

1. `full8_case`
2. `sparse4_case`
3. `out_index_base`
4. `out_last`
5. 单拍 `out_req` 反压保持

## 实际结果

实际运行命令：

```bash
./08_scripts/run_vcs_idct2_2d8_uvm.sh
```

实际结果：

- `VCS` 编译通过
- `UVM_ERROR = 0`
- `UVM_FATAL = 0`

scoreboard 通过的场景：

- `full8_case`
- `sparse4_case`

额外覆盖的协议场景：

- `full8_case` 中第 `4` 组输出后的单拍 `out_req` 反压
- interface assertion 检查 `out_valid && !out_req` 时输出组保持

## 结论

这条 `8x8` 更大块型路径现在已经同时具备：

- directed 功能闭环
- 轻量 `UVM` smoke 闭环

后续继续往：

- `16x16`
- `DCT8 / DST7`
- 更复杂调度

扩时，可以沿用同一套 transaction、scoreboard 和 assertion 结构。
