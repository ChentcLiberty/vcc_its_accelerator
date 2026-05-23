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


def build_sparse_flat(size: int, entries: list[tuple[int, int]]) -> List[int]:
    flat = [0 for _ in range(size * size)]
    for addr, value in entries:
        flat[addr] = value
    return flat


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
    return gen_2d_same_tr_from_flat(size=size, tr_name=tr_name, flat=flat, transform_db=transform_db)


def gen_2d_same_tr_from_flat(
    size: int,
    tr_name: str,
    flat: List[int],
    transform_db: dict,
) -> List[int]:
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
    write_dec_file(
        out_dir / "official_if_stage1_8x8_dct2_sparse_expected.txt",
        gen_2d_same_tr_from_flat(
            8,
            "dct2",
            build_sparse_flat(
                8,
                [
                    (9, 17),
                    (0, -11),
                    (63, 29),
                    (18, -7),
                    (1, 5),
                    (45, -13),
                    (27, 9),
                    (8, -3),
                ],
            ),
            transform_db,
        ),
    )
    write_dec_file(
        out_dir / "official_if_stage1_8x8_dst7_sparse_expected.txt",
        gen_2d_same_tr_from_flat(
            8,
            "dst7",
            build_sparse_flat(
                8,
                [
                    (54, 12),
                    (7, -4),
                    (14, 19),
                    (28, -15),
                    (35, 6),
                    (42, -8),
                    (56, 21),
                    (3, -5),
                ],
            ),
            transform_db,
        ),
    )
    write_dec_file(
        out_dir / "official_if_stage1_16x16_dct8_sparse_expected.txt",
        gen_2d_same_tr_from_flat(
            16,
            "dct8",
            build_sparse_flat(
                16,
                [
                    (255, 31),
                    (0, -17),
                    (18, 9),
                    (35, -6),
                    (68, 15),
                    (85, -12),
                    (119, 7),
                    (136, -10),
                    (171, 13),
                    (188, -3),
                    (204, 11),
                    (221, -14),
                ],
            ),
            transform_db,
        ),
    )
    write_dec_file(
        out_dir / "official_if_stage1_32x32_dct2_expected.txt",
        gen_2d_same_tr(32, "dct2", transform_db),
    )
    write_dec_file(
        out_dir / "official_if_stage1_64x64_dct2_expected.txt",
        gen_2d_same_tr(64, "dct2", transform_db),
    )

    print("Generated official-interface stage1 expected files:")
    print("  - official_if_stage1_4x4_lfnst_expected.txt")
    print("  - official_if_stage1_8x8_dct2_expected.txt")
    print("  - official_if_stage1_8x8_dst7_expected.txt")
    print("  - official_if_stage1_8x8_dct8_expected.txt")
    print("  - official_if_stage1_8x8_dct2_sparse_expected.txt")
    print("  - official_if_stage1_8x8_dst7_sparse_expected.txt")
    print("  - official_if_stage1_16x16_dct2_expected.txt")
    print("  - official_if_stage1_16x16_dst7_expected.txt")
    print("  - official_if_stage1_16x16_dct8_expected.txt")
    print("  - official_if_stage1_16x16_dct8_sparse_expected.txt")
    print("  - official_if_stage1_32x32_dct2_expected.txt")
    print("  - official_if_stage1_64x64_dct2_expected.txt")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
