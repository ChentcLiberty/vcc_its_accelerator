# 题1 ITS 二维大块型 DCT2 验证说明 v1

## 验证对象

- [its_2d_large_core.v](../05_rtl/its_2d_large_core.v)

## 本轮目标

先在模块级把大块型二维核收住，再把它接进官方接口顶层。模块级优先验证：

1. `32x32 DCT2`
2. `64x64 DCT2`
3. `4点/拍` 输出顺序
4. `out_index_base` 递增
5. 输出反压时的保持行为

## 新增文件

- directed TB：
  - [tb_its_2d_large_core.sv](../06_tb/tb_its_2d_large_core.sv)
- run script：
  - [run_vcs_its_2d_large_core.sh](../08_scripts/run_vcs_its_2d_large_core.sh)
- golden 生成：
  - [gen_its_2d_expected_memh.py](../08_scripts/gen_its_2d_expected_memh.py)
- golden 数据：
  - [its_2d32_dct2_full_expected.memh](../06_tb/data/its_2d32_dct2_full_expected.memh)
  - [its_2d64_dct2_full_expected.memh](../06_tb/data/its_2d64_dct2_full_expected.memh)

## 参考策略

golden 继续直接来自 Python 二维参考模型 [its_2d_ref.py](../07_model/its_2d_ref.py)，由：

- [gen_its_2d_expected_memh.py](../08_scripts/gen_its_2d_expected_memh.py)

生成 `64-bit` 二补码 `memh`。

## 当前 case

1. `32x32 DCT2 full`
2. `64x64 DCT2 full`

并额外检查：

- `32x32` 单次 `out_req` stall
- `64x64` 两次 `out_req` stall
- stall 期间 `out_valid` 维持
- stall 期间 `out_index_base / out_data[3:0]` 保持不变

## 运行方式

```bash
bash 08_scripts/run_vcs_its_2d_large_core.sh
```

## 当前边界

这轮只验证：

- `DCT2 -> DCT2`
- `32x32`
- `64x64`

还没有单独做：

- `32x32 DST7`
- `32x32 DCT8`
- sparse 输入的大块型模块级 directed
