# 题1 ITS二维16x16 DST7 UVM验证记录 v1

时间：`2026-05-22`

## 本轮目标

给通用 `ITS 2D 16x16` 壳子的 `DST7 -> DST7` 路径补一层轻量 `UVM`，把大块型二维共享壳子的第二个 transform 组合推进到 `directed + UVM` 双层闭环。

## 新增文件

- [its_2d16_dst7_uvm_pkg.sv](../06_tb/uvm_its_2d16_dst7/its_2d16_dst7_uvm_pkg.sv)
- [tb_its_2d16_dst7_uvm_top.sv](../06_tb/uvm_its_2d16_dst7/tb_its_2d16_dst7_uvm_top.sv)
- [run_vcs_its_2d16_dst7_uvm.sh](../08_scripts/run_vcs_its_2d16_dst7_uvm.sh)
- [题1_ITS二维16x16_DST7_UVM验证说明_v1.md](../03_验证计划/题1_ITS二维16x16_DST7_UVM验证说明_v1.md)

## 参考向量来源

full：

```bash
python3 ./08_scripts/gen_its_2d_expected_memh.py \
  --json ./07_model/inverse_transform_tables.json \
  --row-tr-type dst7 \
  --col-tr-type dst7 \
  --size 16 \
  --out ./06_tb/data/its_2d16_dst7_full_expected.memh
```

sparse：

```bash
python3 ./08_scripts/gen_its_2d_expected_memh.py \
  --json ./07_model/inverse_transform_tables.json \
  --row-tr-type dst7 \
  --col-tr-type dst7 \
  --size 16 \
  --non-zero-cols 8 \
  --non-zero-rows 8 \
  --out ./06_tb/data/its_2d16_dst7_sparse_expected.memh
```

## 实际运行

```bash
./08_scripts/run_vcs_its_2d16_dst7_uvm.sh
```

## 验证结果

- `VCS` 编译通过
- `UVM` 仿真通过
- 汇总结果：`UVM_ERROR = 0`
- 汇总结果：`UVM_FATAL = 0`

## 覆盖到的 case

1. `full16_case`
2. `sparse8_case`

## 额外检查

- `out_index_base`
- `out_last`
- `4 lane data`
- 单拍 `out_req` 反压保持
- `interface assertion` 输出保持
