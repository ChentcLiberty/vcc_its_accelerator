# 题1 ITS二维8x8 DST7验证说明 v1

## 验证对象

- [its_2d8_core.v](../05_rtl/its_2d8_core.v)

## 这版做什么

这版不是新增一套二维壳子，而是在已有通用 `ITS 2D 8x8` 壳子上，补第二个真实 transform 组合：

- `ROW_TR_TYPE = DST7`
- `COL_TR_TYPE = DST7`

对应文件：

- RTL： [its_2d8_core.v](../05_rtl/its_2d8_core.v)
- 2D模型： [its_2d_ref.py](../07_model/its_2d_ref.py)
- directed TB： [tb_its_2d8_dst7_core.sv](../06_tb/tb_its_2d8_dst7_core.sv)
- 运行脚本： [run_vcs_its_2d8_dst7.sh](../08_scripts/run_vcs_its_2d8_dst7.sh)

## 当前验证点

1. `DST7 8x8 full`
2. `DST7 8x8 sparse4`
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

full：

```bash
python3 ./07_model/its_2d_ref.py \
  --json ./07_model/inverse_transform_tables.json \
  --row-tr-type dst7 \
  --col-tr-type dst7 \
  --size 8
```

sparse：

```bash
python3 ./07_model/its_2d_ref.py \
  --json ./07_model/inverse_transform_tables.json \
  --row-tr-type dst7 \
  --col-tr-type dst7 \
  --size 8 \
  --non-zero-cols 4 \
  --non-zero-rows 4
```

## 运行方式

```bash
./08_scripts/run_vcs_its_2d8_dst7.sh
```

## 本轮结果

- `VCS` directed 回归已通过
- 结果：`PASS tb_its_2d8_dst7_core`

## 当前意义

做到这一步后，同一套 `ITS 2D 8x8` 壳子已经不止支持一个 transform 组合，而是至少验证过：

- `DCT8 -> DCT8`
- `DST7 -> DST7`

这说明共享二维调度壳子已经开始具备题目级复用价值。
