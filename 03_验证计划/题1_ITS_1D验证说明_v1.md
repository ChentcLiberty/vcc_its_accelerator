# 题1 ITS 1D验证说明 v1

## 验证对象

- [its_1d_core.v](../05_rtl/its_1d_core.v)

## 这版做什么

这版针对新引入的通用 `ITS 1D` 核，先补一套 directed 自检，目标是先把：

- `DCT2`
- `DST7`
- `DCT8`

三类 `1D` 变换的功能正确性收稳。

对应文件：

- RTL： [its_1d_core.v](../05_rtl/its_1d_core.v)
- ROM： [its_1d_tables.memh](../05_rtl/its_1d_tables.memh)
- 脚本： [gen_its_1d_memh.py](../08_scripts/gen_its_1d_memh.py)
- Testbench： [tb_its_1d_core.sv](../06_tb/tb_its_1d_core.sv)
- 运行脚本： [run_vcs_its_1d_directed.sh](../08_scripts/run_vcs_its_1d_directed.sh)

## 当前验证点

1. `DCT2 8-point` 的兼容路径
2. `DCT8 8-point`
3. `DST7 8-point`
4. `DCT8 32-point`
5. `DST7 32-point`
6. `non_zero_size` 截断
7. `out_req` 单拍反压保持
8. `out_index_base / out_last / done`

## 当前 case

1. `dct2_8_sparse4`
2. `dct8_8_full`
3. `dst7_8_full`
4. `dct8_32_full`
5. `dst7_32_full`

其中：

- `dct2_8_sparse4` 用来确认原 `DCT2` 路径在通用核里没有被带坏
- `dst7_8_full` 插入了一次单拍 `out_req` 反压

## 运行方式

先生成 ROM：

```bash
python3 ./08_scripts/gen_its_1d_memh.py \
  --json ./07_model/inverse_transform_tables.json \
  --out ./05_rtl/its_1d_tables.memh
```

再跑 directed：

```bash
./08_scripts/run_vcs_its_1d_directed.sh
```

## 本轮结果

- `its_1d_tables.memh` 已成功生成
- `VCS` directed 回归已通过
- 结果：`PASS tb_its_1d_core`

## 下一步

这版先把功能闭环收稳。后续建议直接补：

1. `ITS 1D` 的轻量 `UVM`
2. `DCT8/DST7` 的二维路径
