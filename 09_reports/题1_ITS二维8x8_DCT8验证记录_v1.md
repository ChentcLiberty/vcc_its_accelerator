# 题1 ITS二维8x8 DCT8验证记录 v1

时间：`2026-05-21`

## 本轮目标

把共享 `ITS 1D` 核真正接进二维路径，做出第一条 `DCT8 8x8` 的可综合 RTL 闭环。

## 新增文件

- [its_2d8_core.v](../05_rtl/its_2d8_core.v)
- [its_2d_ref.py](../07_model/its_2d_ref.py)
- [tb_its_2d8_core.sv](../06_tb/tb_its_2d8_core.sv)
- [run_vcs_its_2d8.sh](../08_scripts/run_vcs_its_2d8.sh)
- [题1_ITS二维8x8核设计_v1.md](../02_架构设计/题1_ITS二维8x8核设计_v1.md)
- [题1_ITS二维8x8_DCT8验证说明_v1.md](../03_验证计划/题1_ITS二维8x8_DCT8验证说明_v1.md)

## 参考向量生成

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
./08_scripts/run_vcs_its_2d8.sh
```

## 验证结果

- `VCS` 编译通过
- 仿真通过：`PASS tb_its_2d8_core`

## 覆盖到的 case

1. `full8_case`
2. `sparse4_case`

## 额外检查

- `out_index_base`
- `out_last`
- `4 lane data`
- 单拍 `out_req` 反压保持
