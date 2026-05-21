# 题1 ITS 1D模块验证记录 v1

时间：`2026-05-21`

## 本轮目标

把 `DCT2/DST7/DCT8` 三类 `1D` 变换统一到一个可综合 RTL 核里，并完成第一版 directed 验证。

## 新增文件

- [its_1d_core.v](../05_rtl/its_1d_core.v)
- [its_1d_tables.memh](../05_rtl/its_1d_tables.memh)
- [gen_its_1d_memh.py](../08_scripts/gen_its_1d_memh.py)
- [tb_its_1d_core.sv](../06_tb/tb_its_1d_core.sv)
- [run_vcs_its_1d_directed.sh](../08_scripts/run_vcs_its_1d_directed.sh)
- [题1_ITS_1D核设计_v1.md](../02_架构设计/题1_ITS_1D核设计_v1.md)
- [题1_ITS_1D验证说明_v1.md](../03_验证计划/题1_ITS_1D验证说明_v1.md)

## 实际运行

生成 ROM：

```bash
python3 ./08_scripts/gen_its_1d_memh.py \
  --json ./07_model/inverse_transform_tables.json \
  --out ./05_rtl/its_1d_tables.memh
```

运行 directed：

```bash
./08_scripts/run_vcs_its_1d_directed.sh
```

## 验证结果

- `its_1d_tables.memh` 成功生成，共 `61440` 个 ROM word
- `VCS` 编译通过
- 仿真通过：`PASS tb_its_1d_core`

## 覆盖到的 case

1. `dct2_8_sparse4`
2. `dct8_8_full`
3. `dst7_8_full`
4. `dct8_32_full`
5. `dst7_32_full`

## 额外说明

- 中途发现第一次反压检查点放晚了一拍，最开始把“已消费的上一组输出”和“被阻塞的下一组输出”混在一起比了。
- bench 已修正成：先进入阻塞态，再检查被阻塞输出是否稳定一拍。
- 修正后 directed 回归通过。
