# 题1 IDCT2 二维8x8验证记录 v1

时间：`2026-05-20`

## 本轮交付

本轮新增：

- RTL： [idct2_2d8_core.v](../05_rtl/idct2_2d8_core.v)
- Testbench： [tb_idct2_2d8_core.sv](../06_tb/tb_idct2_2d8_core.sv)
- 运行脚本： [run_vcs_idct2_2d8.sh](../08_scripts/run_vcs_idct2_2d8.sh)
- 二维参考模型： [idct2_2d_ref.py](../07_model/idct2_2d_ref.py)
- 设计说明： [题1_IDCT2二维8x8链路设计_v1.md](../02_架构设计/题1_IDCT2二维8x8链路设计_v1.md)
- 验证说明： [题1_IDCT2二维8x8验证说明_v1.md](../03_验证计划/题1_IDCT2二维8x8验证说明_v1.md)

## 计划验证项

1. `8x8` 二维 `IDCT2` 功能正确
2. `out_index_base` 以 `4` 为步长递增
3. `out_last`
4. `done`
5. 单拍 `out_req` 反压保持

## 实际结果

实际仿真命令：

```bash
./08_scripts/run_vcs_idct2_2d8.sh
```

实际结果：

- `VCS` 编译通过
- 仿真结果：`PASS tb_idct2_2d8_core`

本轮还额外检查了：

- `out_index_base` 以 `4` 为步长递增
- `out_last`
- `done`
- 在第 `3` 组输出后插入一次单拍 `out_req` 反压
- 反压期间输出组保持

## 结论

这版 `8x8` 二维 `IDCT2` 已经具备：

- 更大块型的完整 directed 功能闭环
- 双 buffer 数据路径
- 转置读列 + 转置写最终矩阵

后面继续往：

- `16x16`
- `DCT8 / DST7`
- 轻量 `UVM`

扩时，可以直接沿当前架构和验证骨架展开。
