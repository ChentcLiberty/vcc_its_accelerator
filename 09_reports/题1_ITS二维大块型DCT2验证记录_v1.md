# 题1 ITS 二维大块型 DCT2 验证记录 v1

时间：`2026-05-23`

## 本轮目标

给新加的 [its_2d_large_core.v](../05_rtl/its_2d_large_core.v) 做第一轮模块级闭环，先把：

- `32x32 DCT2`
- `64x64 DCT2`

收成可复用的大块型二维核。

## 新增文件

- [its_2d_large_core.v](../05_rtl/its_2d_large_core.v)
- [tb_its_2d_large_core.sv](../06_tb/tb_its_2d_large_core.sv)
- [run_vcs_its_2d_large_core.sh](../08_scripts/run_vcs_its_2d_large_core.sh)
- [its_2d32_dct2_full_expected.memh](../06_tb/data/its_2d32_dct2_full_expected.memh)
- [its_2d64_dct2_full_expected.memh](../06_tb/data/its_2d64_dct2_full_expected.memh)

## 实际运行

```bash
bash 08_scripts/run_vcs_its_2d_large_core.sh
```

## 覆盖内容

1. `32x32 DCT2 full`
2. `64x64 DCT2 full`
3. `out_index_base = group_idx * 4`
4. `32x32` 一次输出反压
5. `64x64` 两次输出反压
6. stall 期间输出保持

## 本轮结果

- `32x32` golden 生成通过
- `64x64` golden 生成通过
- `VCS` 编译通过
- 仿真通过
- 结果：`PASS tb_its_2d_large_core`

## 备注

这轮中途遇到过一次 false negative：

- 第一版 TB 在 consumer 刚把 `out_req` 拉低时，抓到了“下一组刚切换出来”的值
- RTL 本身没有错
- 后面把检查改成“连续两拍 stall hold 检查”后，结果收敛为 `PASS`

## 当前结论

大块型二维核已经在模块级把 `32x32/64x64 DCT2` 收住，可以继续安全地往官方接口顶层和更完整模式矩阵扩。
