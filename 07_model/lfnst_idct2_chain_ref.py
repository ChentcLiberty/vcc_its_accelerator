#!/usr/bin/env python3
"""Reference model for the 4x4 LFNST -> column-IDCT2 sub-chain."""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import List, Sequence

from inverse_transform_ref import apply_inverse_transform, load_transform_db
from lfnst_ref import apply_lfnst_vector, load_lfnst_db


SCAN_ORDER_4X4 = (
    (0, 0),
    (1, 0),
    (0, 1),
    (2, 0),
    (1, 1),
    (0, 2),
    (3, 0),
    (2, 1),
    (1, 2),
    (0, 3),
    (3, 1),
    (2, 2),
    (1, 3),
    (3, 2),
    (2, 3),
    (3, 3),
)


def remap_scan_vector_to_block_4x4(values: Sequence[int]) -> List[List[int]]:
    if len(values) != 16:
        raise ValueError(f"Expected 16 values, got {len(values)}")

    block = [[0 for _ in range(4)] for _ in range(4)]
    for idx, (row, col) in enumerate(SCAN_ORDER_4X4):
        block[row][col] = int(values[idx])
    return block


def apply_lfnst_then_column_idct2_4x4(
    x_bar: Sequence[int],
    lfnst_tr_set_idx: int,
    lfnst_idx: int,
    lfnst_db: dict,
    transform_db: dict,
) -> List[List[int]]:
    if len(x_bar) != 16:
        raise ValueError(f"Expected x_bar length 16, got {len(x_bar)}")

    if lfnst_idx == 0:
        lfnst_vector = [int(v) for v in x_bar]
    else:
        matrix = lfnst_db["lookup"]["16"][str(lfnst_tr_set_idx)][str(lfnst_idx)]
        lfnst_vector = apply_lfnst_vector(x_bar=x_bar, matrix=matrix, non_zero_size=8)

    lfnst_block = remap_scan_vector_to_block_4x4(lfnst_vector)

    out_block = [[0 for _ in range(4)] for _ in range(4)]
    for col in range(4):
        col_in = [lfnst_block[row][col] for row in range(4)]
        col_out = apply_inverse_transform(
            x=col_in,
            tr_type="dct2",
            size=4,
            db=transform_db,
            non_zero_size=4,
        )
        for row in range(4):
            out_block[row][col] = int(col_out[row])
    return out_block


def build_demo_xbar() -> List[int]:
    return [1, 5, 2, 9, 6, 3, 13, 10, 7, 4, 14, 11, 8, 15, 12, 16]


def format_block(block: Sequence[Sequence[int]]) -> str:
    return "\n".join(" ".join(f"{val:8d}" for val in row) for row in block)


def main() -> int:
    parser = argparse.ArgumentParser(description="Run the 4x4 LFNST -> column-IDCT2 reference sub-chain.")
    parser.add_argument("--lfnst-json", type=Path, required=True)
    parser.add_argument("--it-json", type=Path, required=True)
    parser.add_argument("--lfnst-tr-set-idx", type=int, default=0)
    parser.add_argument("--lfnst-idx", type=int, default=1)
    args = parser.parse_args()

    lfnst_db = load_lfnst_db(args.lfnst_json)
    transform_db = load_transform_db(args.it_json)
    x_bar = build_demo_xbar()
    out_block = apply_lfnst_then_column_idct2_4x4(
        x_bar=x_bar,
        lfnst_tr_set_idx=args.lfnst_tr_set_idx,
        lfnst_idx=args.lfnst_idx,
        lfnst_db=lfnst_db,
        transform_db=transform_db,
    )

    print("Input x_bar:")
    print(x_bar)
    print("\nColumn-IDCT2 output block:")
    print(format_block(out_block))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
