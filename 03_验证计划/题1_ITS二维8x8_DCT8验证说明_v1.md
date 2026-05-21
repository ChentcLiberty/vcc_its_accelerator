# 题1 ITS二维8x8 DCT8验证说明 v1

## 验证对象

- [its_2d8_core.v](../05_rtl/its_2d8_core.v)

## 这版做什么

这版先拿通用 `ITS 2D 8x8` 壳子的第一个真实用例收口：

- `ROW_TR_TYPE = DCT8`
- `COL_TR_TYPE = DCT8`

对应文件：

- RTL： [its_2d8_core.v](../05_rtl/its_2d8_core.v)
- 2D模型： [its_2d_ref.py](../07_model/its_2d_ref.py)
- directed TB： [tb_its_2d8_core.sv](../06_tb/tb_its_2d8_core.sv)
- 运行脚本： [run_vcs_its_2d8.sh](../08_scripts/run_vcs_its_2d8.sh)

## 当前验证点

1. `DCT8 8x8 full`
2. `DCT8 8x8 sparse4`
3. `out_index_base`
4. `out_last`
5. `done`
6. 单拍 `out_req` 反压保持

## 当前 case

1. `full8_case`
   - `non_zero_cols = 8`
   - `non_zero_rows = 8`
2. `sparse4_case`
   - `non_zero_cols = 4`
   - `non_zero_rows = 4`

## golden 来源

当前 directed 的期望值来自：

```bash
python3 ./07_model/its_2d_ref.py \
  --json ./07_model/inverse_transform_tables.json \
  --row-tr-type dct8 \
  --col-tr-type dct8 \
  --size 8
```

以及：

```bash
python3 ./07_model/its_2d_ref.py \
  --json ./07_model/inverse_transform_tables.json \
  --row-tr-type dct8 \
  --col-tr-type dct8 \
  --size 8 \
  --non-zero-cols 4 \
  --non-zero-rows 4
```

## 运行方式

```bash
./08_scripts/run_vcs_its_2d8.sh
```

## 本轮结果

- `VCS` directed 回归已通过
- 结果：`PASS tb_its_2d8_core`

## 下一步

这版先收 `DCT8 8x8`。后面最直接的是：

1. 用同一二维壳子补 `DST7 8x8`
2. 或给 `ITS 2D 8x8` 补轻量 `UVM`
