#!/usr/bin/env python3
"""Generate stage-1 official-interface golden data for top-level UVM/directeds."""

from __future__ import annotations

import sys
from pathlib import Path
from typing import Iterable, List


ROOT = Path(__file__).resolve().parents[1]
MODEL_DIR = ROOT / "07_model"
sys.path.insert(0, str(MODEL_DIR))

from inverse_transform_ref import load_transform_db  # type: ignore  # noqa: E402
from its_2d_ref import apply_its_2d, build_demo_flat, build_matrix_from_flat, flatten_matrix  # type: ignore  # noqa: E402
from lfnst_idct2_2d4_ref import apply_lfnst_then_idct2_2d_4x4  # type: ignore  # noqa: E402
from lfnst_idct2_chain_ref import build_demo_xbar  # type: ignore  # noqa: E402
from lfnst_ref import load_lfnst_db  # type: ignore  # noqa: E402


def clip_lane10(value: int) -> int:
    return max(-512, min(511, int(value)))


def write_dec_file(path: Path, values: Iterable[int]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("".join(f"{int(value)}\n" for value in values), encoding="utf-8")


def gen_4x4_lfnst(lfnst_db: dict, transform_db: dict) -> List[int]:
    block = apply_lfnst_then_idct2_2d_4x4(
        x_bar=build_demo_xbar(),
        lfnst_tr_set_idx=0,
        lfnst_idx=1,
        lfnst_db=lfnst_db,
        transform_db=transform_db,
    )
    return [clip_lane10(v) for v in flatten_matrix(block)]


def gen_2d_dct8(size: int, transform_db: dict) -> List[int]:
    return gen_2d_same_tr(size=size, tr_name="dct8", transform_db=transform_db)


def gen_2d_same_tr(size: int, tr_name: str, transform_db: dict) -> List[int]:
    flat = build_demo_flat(size)
    matrix = build_matrix_from_flat(flat, size)
    out = apply_its_2d(
        matrix=matrix,
        db=transform_db,
        row_tr_type=tr_name,
        col_tr_type=tr_name,
        non_zero_cols=size,
        non_zero_rows=size,
    )
    return [clip_lane10(v) for v in flatten_matrix(out)]


def main() -> int:
    lfnst_json = ROOT / "07_model" / "lfnst_tables.json"
    transform_json = ROOT / "07_model" / "inverse_transform_tables.json"
    out_dir = ROOT / "06_tb" / "data"

    lfnst_db = load_lfnst_db(lfnst_json)
    transform_db = load_transform_db(transform_json)

    write_dec_file(
        out_dir / "official_if_stage1_4x4_lfnst_expected.txt",
        gen_4x4_lfnst(lfnst_db, transform_db),
    )
    write_dec_file(
        out_dir / "official_if_stage1_8x8_dct2_expected.txt",
        gen_2d_same_tr(8, "dct2", transform_db),
    )
    write_dec_file(
        out_dir / "official_if_stage1_8x8_dst7_expected.txt",
        gen_2d_same_tr(8, "dst7", transform_db),
    )
    write_dec_file(
        out_dir / "official_if_stage1_8x8_dct8_expected.txt",
        gen_2d_dct8(8, transform_db),
    )
    write_dec_file(
        out_dir / "official_if_stage1_16x16_dct2_expected.txt",
        gen_2d_same_tr(16, "dct2", transform_db),
    )
    write_dec_file(
        out_dir / "official_if_stage1_16x16_dst7_expected.txt",
        gen_2d_same_tr(16, "dst7", transform_db),
    )
    write_dec_file(
        out_dir / "official_if_stage1_16x16_dct8_expected.txt",
        gen_2d_dct8(16, transform_db),
    )

    print("Generated official-interface stage1 expected files:")
    print("  - official_if_stage1_4x4_lfnst_expected.txt")
    print("  - official_if_stage1_8x8_dct2_expected.txt")
    print("  - official_if_stage1_8x8_dst7_expected.txt")
    print("  - official_if_stage1_8x8_dct8_expected.txt")
    print("  - official_if_stage1_16x16_dct2_expected.txt")
    print("  - official_if_stage1_16x16_dst7_expected.txt")
    print("  - official_if_stage1_16x16_dct8_expected.txt")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
