# 题1 ITS二维8x8 DST7 UVM验证说明 v1

## 验证对象

- [its_2d8_core.v](../05_rtl/its_2d8_core.v)

## 这版做什么

这版在已经通过 directed 的 `ITS 2D 8x8 DST7 -> DST7` 路径上，再补一层轻量 `UVM`，把共享二维壳子的第二个真实 transform 组合也收成 `directed + UVM` 双层闭环。

对应文件：

- RTL： [its_2d8_core.v](../05_rtl/its_2d8_core.v)
- interface： [its_2d8_if.sv](../06_tb/uvm_its_2d8/its_2d8_if.sv)
- UVM package： [its_2d8_dst7_uvm_pkg.sv](../06_tb/uvm_its_2d8_dst7/its_2d8_dst7_uvm_pkg.sv)
- UVM top： [tb_its_2d8_dst7_uvm_top.sv](../06_tb/uvm_its_2d8_dst7/tb_its_2d8_dst7_uvm_top.sv)
- 运行脚本： [run_vcs_its_2d8_dst7_uvm.sh](../08_scripts/run_vcs_its_2d8_dst7_uvm.sh)

## 当前验证点

1. `DST7 8x8 full`
2. `DST7 8x8 sparse4`
3. `out_index_base`
4. `out_last`
5. `done`
6. 单拍 `out_req` 反压保持
7. `interface assertion` 输出保持

## 当前 case

1. `full8_case`
   - `non_zero_cols = 8`
   - `non_zero_rows = 8`
   - 在第 `4` 组输出后插入 `1` 拍 `out_req = 0`
2. `sparse4_case`
   - `non_zero_cols = 4`
   - `non_zero_rows = 4`

## UVM结构

- `driver`
- `monitor`
- `scoreboard`
- `agent`
- `env`
- `test`
- `interface assertion`

## golden 来源

当前 `UVM` smoke 的期望值来自：

```bash
python3 ./07_model/its_2d_ref.py \
  --json ./07_model/inverse_transform_tables.json \
  --row-tr-type dst7 \
  --col-tr-type dst7 \
  --size 8
```

以及：

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
./08_scripts/run_vcs_its_2d8_dst7_uvm.sh
```

## 本轮结果

- `VCS UVM` smoke 回归已通过
- 结果：`UVM_ERROR = 0`
- 结果：`UVM_FATAL = 0`

## 下一步

1. 把 `ITS 2D 8x8` 的 `DCT8 / DST7` 两条 `UVM` 路径进一步抽成更统一的共享验证骨架
2. 继续把共享 `ITS 1D` 核往更大块型二维路径推进
