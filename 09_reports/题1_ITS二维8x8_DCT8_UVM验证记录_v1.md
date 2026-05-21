# 题1 ITS二维8x8 DCT8 UVM验证记录 v1

时间：`2026-05-21`

## 本轮目标

给通用 `ITS 2D 8x8` 壳子的 `DCT8 -> DCT8` 路径补一层轻量 `UVM`，把二维共享壳子从 directed 推进到 `directed + UVM` 双层闭环。

## 新增文件

- [its_2d8_if.sv](../06_tb/uvm_its_2d8/its_2d8_if.sv)
- [its_2d8_uvm_pkg.sv](../06_tb/uvm_its_2d8/its_2d8_uvm_pkg.sv)
- [tb_its_2d8_uvm_top.sv](../06_tb/uvm_its_2d8/tb_its_2d8_uvm_top.sv)
- [run_vcs_its_2d8_uvm.sh](../08_scripts/run_vcs_its_2d8_uvm.sh)
- [题1_ITS二维8x8_DCT8_UVM验证说明_v1.md](../03_验证计划/题1_ITS二维8x8_DCT8_UVM验证说明_v1.md)

## 参考向量来源

full：

```bash
python3 ./07_model/its_2d_ref.py \
  --json ./07_model/inverse_transform_tables.json \
  --row-tr-type dct8 \
  --col-tr-type dct8 \
  --size 8
```

sparse：

```bash
python3 ./07_model/its_2d_ref.py \
  --json ./07_model/inverse_transform_tables.json \
  --row-tr-type dct8 \
  --col-tr-type dct8 \
  --size 8 \
  --non-zero-cols 4 \
  --non-zero-rows 4
```

## 实际运行

```bash
./08_scripts/run_vcs_its_2d8_uvm.sh
```

## 验证结果

- `VCS` 编译通过
- `UVM` 仿真通过
- 汇总结果：`UVM_ERROR = 0`
- 汇总结果：`UVM_FATAL = 0`

## 覆盖到的 case

1. `full8_case`
2. `sparse4_case`

## 额外检查

- `out_index_base`
- `out_last`
- `4 lane data`
- 单拍 `out_req` 反压保持
- `interface assertion` 输出保持
