# 题1 ITS二维16x16 DCT8验证记录 v1

时间：`2026-05-21`

## 本轮目标

把共享 `ITS 1D` 核继续往更大块型推进，先落一版 `DCT8 16x16` 的 directed 闭环，确认通用二维壳子不只停留在 `8x8`。

## 新增文件

- [its_2d16_core.v](../05_rtl/its_2d16_core.v)
- [tb_its_2d16_core.sv](../06_tb/tb_its_2d16_core.sv)
- [run_vcs_its_2d16.sh](../08_scripts/run_vcs_its_2d16.sh)
- [gen_its_2d_expected_memh.py](../08_scripts/gen_its_2d_expected_memh.py)
- [its_2d16_dct8_full_expected.memh](../06_tb/data/its_2d16_dct8_full_expected.memh)
- [its_2d16_dct8_sparse_expected.memh](../06_tb/data/its_2d16_dct8_sparse_expected.memh)
- [题1_ITS二维16x16核设计_v1.md](../02_架构设计/题1_ITS二维16x16核设计_v1.md)
- [题1_ITS二维16x16_DCT8验证说明_v1.md](../03_验证计划/题1_ITS二维16x16_DCT8验证说明_v1.md)

## 参考向量生成

full：

```bash
python3 ./08_scripts/gen_its_2d_expected_memh.py \
  --json ./07_model/inverse_transform_tables.json \
  --row-tr-type dct8 \
  --col-tr-type dct8 \
  --size 16 \
  --out ./06_tb/data/its_2d16_dct8_full_expected.memh
```

sparse：

```bash
python3 ./08_scripts/gen_its_2d_expected_memh.py \
  --json ./07_model/inverse_transform_tables.json \
  --row-tr-type dct8 \
  --col-tr-type dct8 \
  --size 16 \
  --non-zero-cols 8 \
  --non-zero-rows 8 \
  --out ./06_tb/data/its_2d16_dct8_sparse_expected.memh
```

## 实际运行

```bash
./08_scripts/run_vcs_its_2d16.sh
```

## 验证结果

- `VCS` 编译通过
- 仿真通过：`PASS tb_its_2d16_core`

## 覆盖到的 case

1. `full16_case`
2. `sparse8_case`

## 额外检查

- `out_index_base`
- `out_last`
- `done`

## 当前结论

这版已经证明共享 `ITS 1D` 核可以继续往 `16x16` 二维壳子复用，但当前 directed 还没有把单拍 `out_req` 反压重新纳回验证范围。
