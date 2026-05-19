#!/usr/bin/env python3
"""Pure Python LFNST reference model for Huawei Cup Problem 1.

This module intentionally focuses on the LFNST stage only:
- load extracted matrices from JSON
- flatten the top-left 4x4 low-frequency region with the specified scan order
- apply the matrix multiply and clipping rule from the problem statement

Output remapping back into the full TU is left for the next integration step,
because the current priority is building a stable golden model for LFNST core
verification.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Iterable, List, Sequence


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


def clip3(lo: int, hi: int, value: int) -> int:
    return max(lo, min(hi, value))


def infer_ntrs(tu_width: int, tu_height: int) -> int:
    return 48 if (tu_width >= 8 and tu_height >= 8) else 16


def infer_non_zero_size(tu_width: int, tu_height: int) -> int:
    return 8 if ((tu_width == 4 and tu_height == 4) or (tu_width == 8 and tu_height == 8)) else 16


def flatten_top_left_4x4(block: Sequence[Sequence[int]]) -> List[int]:
    return [int(block[row][col]) for row, col in SCAN_ORDER_4X4]


def load_lfnst_db(json_path: Path) -> dict:
    return json.loads(json_path.read_text(encoding="utf-8"))


def get_lfnst_matrix(db: dict, ntrs: int, lfnst_tr_set_idx: int, lfnst_idx: int) -> List[List[int]]:
    if lfnst_idx == 0:
        raise ValueError("lfnst_idx = 0 means bypass, no LFNST matrix should be fetched")

    return db["lookup"][str(ntrs)][str(lfnst_tr_set_idx)][str(lfnst_idx)]


def apply_lfnst_vector(
    x_bar: Sequence[int],
    matrix: Sequence[Sequence[int]],
    non_zero_size: int,
) -> List[int]:
    if len(x_bar) != 16:
        raise ValueError(f"Expected x_bar length 16, got {len(x_bar)}")

    outputs: List[int] = []
    for row in matrix:
        acc = 0
        for idx in range(non_zero_size):
            acc += int(row[idx]) * int(x_bar[idx])
        outputs.append(clip3(-32768, 32767, (acc + 64) >> 7))
    return outputs


def apply_lfnst_from_block(
    block: Sequence[Sequence[int]],
    tu_width: int,
    tu_height: int,
    lfnst_tr_set_idx: int,
    lfnst_idx: int,
    db: dict,
) -> List[int]:
    ntrs = infer_ntrs(tu_width, tu_height)
    non_zero_size = infer_non_zero_size(tu_width, tu_height)
    x_bar = flatten_top_left_4x4(block)
    matrix = get_lfnst_matrix(db, ntrs, lfnst_tr_set_idx, lfnst_idx)
    return apply_lfnst_vector(x_bar, matrix, non_zero_size)


def build_demo_block() -> List[List[int]]:
    return [
        [1, 2, 3, 4],
        [5, 6, 7, 8],
        [9, 10, 11, 12],
        [13, 14, 15, 16],
    ]


def main() -> int:
    parser = argparse.ArgumentParser(description="Run a simple LFNST reference-model demo.")
    parser.add_argument(
        "--json",
        type=Path,
        required=True,
        help="Path to lfnst_tables.json",
    )
    parser.add_argument("--tu-width", type=int, default=4)
    parser.add_argument("--tu-height", type=int, default=4)
    parser.add_argument("--lfnst-tr-set-idx", type=int, default=0)
    parser.add_argument("--lfnst-idx", type=int, default=1)
    args = parser.parse_args()

    db = load_lfnst_db(args.json)
    block = build_demo_block()
    outputs = apply_lfnst_from_block(
        block=block,
        tu_width=args.tu_width,
        tu_height=args.tu_height,
        lfnst_tr_set_idx=args.lfnst_tr_set_idx,
        lfnst_idx=args.lfnst_idx,
        db=db,
    )

    print("Input 4x4 block:")
    for row in block:
        print(" ".join(f"{val:6d}" for val in row))

    print("\nFlattened x_bar:")
    print(flatten_top_left_4x4(block))

    print("\nLFNST output vector:")
    print(outputs)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
