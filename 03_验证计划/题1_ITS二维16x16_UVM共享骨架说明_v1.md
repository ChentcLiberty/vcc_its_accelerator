# 题1 ITS二维16x16 UVM共享骨架说明 v1

## 这版做什么

这版不再继续复制 `DCT8` 和 `DST7` 两套几乎相同的 `16x16 UVM package`，而是把公共的：

- `case`
- `driver`
- `monitor`
- `scoreboard`
- `agent`
- `env`
- `base sequence`
- `base test`

统一收进一份共享骨架，`DCT8` 和 `DST7` 只各自保留最薄的一层：

- transform 对应的 `full/sparse` golden 路径
- transform 对应的 `smoke sequence`
- transform 对应的 `test`

## 对应文件

- 共享 interface： [its_2d16_if.sv](../06_tb/uvm_its_2d16/its_2d16_if.sv)
- 共享 package： [its_2d16_uvm_common_pkg.sv](../06_tb/uvm_its_2d16/its_2d16_uvm_common_pkg.sv)
- DCT8 package： [its_2d16_uvm_pkg.sv](../06_tb/uvm_its_2d16/its_2d16_uvm_pkg.sv)
- DST7 package： [its_2d16_dst7_uvm_pkg.sv](../06_tb/uvm_its_2d16_dst7/its_2d16_dst7_uvm_pkg.sv)
- DCT8 run script： [run_vcs_its_2d16_uvm.sh](../08_scripts/run_vcs_its_2d16_uvm.sh)
- DST7 run script： [run_vcs_its_2d16_dst7_uvm.sh](../08_scripts/run_vcs_its_2d16_dst7_uvm.sh)

## 共享边界

当前共享骨架统一了这几件事：

1. 输入激励装载
2. `out_req` 单拍反压注入
3. `done` 收尾检查
4. `out_index_base / out_last / 4 lane data` scoreboard
5. `memh` golden 读取
6. `env/agent/sequencer` 连接方式

当前仍然保持 transform 分开的部分只有：

1. `full/sparse` golden 文件路径
2. 具体 `smoke sequence`
3. 顶层 DUT 的 `ROW_TR_TYPE / COL_TR_TYPE`
4. 顶层 `run_test(...)` 名字

## 当前价值

这次重构的主要收益不是功能新增，而是把 `16x16` 的两条 `UVM` 路径收成统一维护点。后面如果要继续补：

- `DCT8/DST7` 更多 case
- 更大块型
- 更完整的随机化
- 更强的 assertion / coverage

就不需要再双份修改长 package。

## 本轮回归要求

重构后必须至少重新回归：

```bash
./08_scripts/run_vcs_its_2d16_uvm.sh
./08_scripts/run_vcs_its_2d16_dst7_uvm.sh
```

只有两条都通过，这次共享骨架重构才算收口。
