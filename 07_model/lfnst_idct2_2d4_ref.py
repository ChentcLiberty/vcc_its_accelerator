#!/usr/bin/env python3
"""Reference model for the 4x4 LFNST -> 2D IDCT2 chain."""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import List, Sequence

from inverse_transform_ref import apply_inverse_transform, load_transform_db
from lfnst_idct2_chain_ref import (
    apply_lfnst_then_column_idct2_4x4,
    build_demo_xbar,
    format_block,
)
from lfnst_ref import load_lfnst_db


def apply_lfnst_then_idct2_2d_4x4(
    x_bar: Sequence[int],
    lfnst_tr_set_idx: int,
    lfnst_idx: int,
    lfnst_db: dict,
    transform_db: dict,
) -> List[List[int]]:
    col_block = apply_lfnst_then_column_idct2_4x4(
        x_bar=x_bar,
        lfnst_tr_set_idx=lfnst_tr_set_idx,
        lfnst_idx=lfnst_idx,
        lfnst_db=lfnst_db,
        transform_db=transform_db,
    )

    out_block: List[List[int]] = []
    for row in range(4):
        row_out = apply_inverse_transform(
            x=col_block[row],
            tr_type="dct2",
            size=4,
            db=transform_db,
            non_zero_size=4,
        )
        out_block.append([int(v) for v in row_out])
    return out_block


def main() -> int:
    parser = argparse.ArgumentParser(description="Run the 4x4 LFNST -> 2D IDCT2 reference chain.")
    parser.add_argument("--lfnst-json", type=Path, required=True)
    parser.add_argument("--it-json", type=Path, required=True)
    parser.add_argument("--lfnst-tr-set-idx", type=int, default=0)
    parser.add_argument("--lfnst-idx", type=int, default=1)
    args = parser.parse_args()

    lfnst_db = load_lfnst_db(args.lfnst_json)
    transform_db = load_transform_db(args.it_json)
    x_bar = build_demo_xbar()
    out_block = apply_lfnst_then_idct2_2d_4x4(
        x_bar=x_bar,
        lfnst_tr_set_idx=args.lfnst_tr_set_idx,
        lfnst_idx=args.lfnst_idx,
        lfnst_db=lfnst_db,
        transform_db=transform_db,
    )

    print("Input x_bar:")
    print(x_bar)
    print("\n2D IDCT2 output block:")
    print(format_block(out_block))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
