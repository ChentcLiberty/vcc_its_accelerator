# 题1 ITS二维16x16 UVM共享骨架重构记录 v1

时间：`2026-05-22`

## 本轮目标

把 `ITS 2D 16x16` 的 `DCT8` 和 `DST7` 两条 `UVM` 路径从双份长 package 重构成共享骨架，减少重复代码，同时保持两条回归结果不变。

## 新增文件

- [its_2d16_uvm_common_pkg.sv](../06_tb/uvm_its_2d16/its_2d16_uvm_common_pkg.sv)
- [题1_ITS二维16x16_UVM共享骨架说明_v1.md](../03_验证计划/题1_ITS二维16x16_UVM共享骨架说明_v1.md)

## 改动文件

- [its_2d16_uvm_pkg.sv](../06_tb/uvm_its_2d16/its_2d16_uvm_pkg.sv)
- [its_2d16_dst7_uvm_pkg.sv](../06_tb/uvm_its_2d16_dst7/its_2d16_dst7_uvm_pkg.sv)
- [run_vcs_its_2d16_uvm.sh](../08_scripts/run_vcs_its_2d16_uvm.sh)
- [run_vcs_its_2d16_dst7_uvm.sh](../08_scripts/run_vcs_its_2d16_dst7_uvm.sh)
- [README.md](../README.md)
- [题1_验证策略_v1.md](../03_验证计划/题1_验证策略_v1.md)

## 实际运行

```bash
./08_scripts/run_vcs_its_2d16_uvm.sh
./08_scripts/run_vcs_its_2d16_dst7_uvm.sh
```

## 验证结果

- `DCT8 16x16 UVM` 重构后回归通过
- `DST7 16x16 UVM` 重构后回归通过
- 两条回归结果都是：
  - `UVM_ERROR = 0`
  - `UVM_FATAL = 0`

## 本轮结论

这次重构没有改变 `16x16` 两条 `UVM` 路径的功能结果，但把公共验证骨架收到了单点维护文件里。后续继续加 case 或继续上更大块型时，不需要再双份维护长 `package`。 
