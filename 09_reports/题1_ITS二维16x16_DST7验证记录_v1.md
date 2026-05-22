# 题1 ITS二维16x16 DST7验证记录 v1

时间：`2026-05-21`

## 本轮目标

在已经跑通 `DCT8 16x16` 的共享二维壳子上，再补 `DST7 16x16` 这条 directed 闭环，确认 `ITS 2D 16x16` 不是只对单一 transform 组合成立。

## 新增文件

- [tb_its_2d16_dst7_core.sv](../06_tb/tb_its_2d16_dst7_core.sv)
- [run_vcs_its_2d16_dst7.sh](../08_scripts/run_vcs_its_2d16_dst7.sh)
- [its_2d16_dst7_full_expected.memh](../06_tb/data/its_2d16_dst7_full_expected.memh)
- [its_2d16_dst7_sparse_expected.memh](../06_tb/data/its_2d16_dst7_sparse_expected.memh)
- [题1_ITS二维16x16_DST7验证说明_v1.md](../03_验证计划/题1_ITS二维16x16_DST7验证说明_v1.md)

## 参考向量生成

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
./08_scripts/run_vcs_its_2d16_dst7.sh
```

## 验证结果

- `VCS` 编译通过
- 仿真通过：`PASS tb_its_2d16_dst7_core`

## 覆盖到的 case

1. `full16_case`
2. `sparse8_case`

## 额外检查

- `out_index_base`
- `out_last`
- `done`
