# 题1 ITS二维8x8 DST7验证记录 v1

时间：`2026-05-21`

## 本轮目标

在已经跑通 `DCT8 8x8` 的通用二维壳子上，再补 `DST7 8x8` 这条 directed 闭环，确认二维控制和共享 `ITS 1D` 接口没有绑死在 `DCT8`。

## 新增文件

- [tb_its_2d8_dst7_core.sv](../06_tb/tb_its_2d8_dst7_core.sv)
- [run_vcs_its_2d8_dst7.sh](../08_scripts/run_vcs_its_2d8_dst7.sh)
- [题1_ITS二维8x8_DST7验证说明_v1.md](../03_验证计划/题1_ITS二维8x8_DST7验证说明_v1.md)

## 参考向量生成

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

## 实际运行

```bash
./08_scripts/run_vcs_its_2d8_dst7.sh
```

## 验证结果

- `VCS` 编译通过
- 仿真通过：`PASS tb_its_2d8_dst7_core`

## 覆盖到的 case

1. `full8_case`
2. `sparse4_case`

## 额外检查

- `out_index_base`
- `out_last`
- `done`
- 单拍 `out_req` 反压保持
