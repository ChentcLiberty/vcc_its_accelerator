# 题1 ITS二维16x16 DST7验证说明 v1

## 验证对象

- [its_2d16_core.v](../05_rtl/its_2d16_core.v)

## 这版做什么

这版在已经打通 `16x16 DCT8` 的共享二维壳子上，再补第二个 `16x16` transform 组合：

- `ROW_TR_TYPE = DST7`
- `COL_TR_TYPE = DST7`

对应文件：

- RTL： [its_2d16_core.v](../05_rtl/its_2d16_core.v)
- 2D模型： [its_2d_ref.py](../07_model/its_2d_ref.py)
- golden 生成脚本： [gen_its_2d_expected_memh.py](../08_scripts/gen_its_2d_expected_memh.py)
- directed TB： [tb_its_2d16_dst7_core.sv](../06_tb/tb_its_2d16_dst7_core.sv)
- 运行脚本： [run_vcs_its_2d16_dst7.sh](../08_scripts/run_vcs_its_2d16_dst7.sh)

## 当前验证点

1. `DST7 16x16 full`
2. `DST7 16x16 sparse8`
3. `out_index_base`
4. `out_last`
5. `done`

## 当前 case

1. `full16_case`
   - `non_zero_cols = 16`
   - `non_zero_rows = 16`
2. `sparse8_case`
   - `non_zero_cols = 8`
   - `non_zero_rows = 8`

## golden 来源

当前 directed 的期望值来自：

```bash
python3 ./08_scripts/gen_its_2d_expected_memh.py \
  --json ./07_model/inverse_transform_tables.json \
  --row-tr-type dst7 \
  --col-tr-type dst7 \
  --size 16 \
  --out ./06_tb/data/its_2d16_dst7_full_expected.memh
```

以及：

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

## 运行方式

```bash
./08_scripts/run_vcs_its_2d16_dst7.sh
```

## 当前边界

这版先收功能闭环，不把以下内容纳入当前 directed 范围：

- 单拍 `out_req` 反压保持
- `UVM`

## 本轮结果

- `VCS` directed 回归已通过
- 结果：`PASS tb_its_2d16_dst7_core`

## 当前意义

做到这一步后，`ITS 2D 16x16` 共享壳子已经至少验证过：

- `DCT8 -> DCT8`
- `DST7 -> DST7`

这说明 `16x16` 级别的共享二维调度不再绑死在单一 transform 组合上。
