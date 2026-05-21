#!/usr/bin/env python3
"""Pure Python 2D inverse-transform reference model for Huawei Cup Problem 1."""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import List, Sequence

from inverse_transform_ref import apply_inverse_transform, load_transform_db


def flatten_matrix(matrix: Sequence[Sequence[int]]) -> List[int]:
    return [value for row in matrix for value in row]


def build_matrix_from_flat(values: Sequence[int], size: int) -> List[List[int]]:
    if len(values) != size * size:
        raise ValueError(f"Expected {size*size} values, got {len(values)}")
    return [list(values[row * size:(row + 1) * size]) for row in range(size)]


def apply_its_2d(
    matrix: Sequence[Sequence[int]],
    db: dict,
    row_tr_type: str = "dct2",
    col_tr_type: str = "dct2",
    non_zero_cols: int | None = None,
    non_zero_rows: int | None = None,
) -> List[List[int]]:
    size = len(matrix)
    if any(len(row) != size for row in matrix):
        raise ValueError("Input matrix must be square")

    if non_zero_cols is None:
        non_zero_cols = size
    if non_zero_rows is None:
        non_zero_rows = size

    row_stage: List[List[int]] = []
    for row in matrix:
        row_stage.append(
            apply_inverse_transform(
                x=row,
                tr_type=row_tr_type,
                size=size,
                db=db,
                non_zero_size=non_zero_cols,
            )
        )

    out = [[0 for _ in range(size)] for _ in range(size)]
    for col_idx in range(size):
        col_vec = [row_stage[row_idx][col_idx] for row_idx in range(size)]
        col_out = apply_inverse_transform(
            x=col_vec,
            tr_type=col_tr_type,
            size=size,
            db=db,
            non_zero_size=non_zero_rows,
        )
        for row_idx in range(size):
            out[row_idx][col_idx] = col_out[row_idx]
    return out


def build_demo_flat(size: int) -> List[int]:
    return list(range(1, size * size + 1))


def parse_vector_arg(text: str, size: int) -> List[int]:
    values = [int(part.strip()) for part in text.split(",") if part.strip()]
    if len(values) != size * size:
        raise ValueError(f"Expected {size*size} comma-separated integers, got {len(values)}")
    return values


def main() -> int:
    parser = argparse.ArgumentParser(description="Run a simple 2D inverse-transform reference-model demo.")
    parser.add_argument("--json", type=Path, required=True, help="Path to inverse_transform_tables.json")
    parser.add_argument("--row-tr-type", type=str, default="dct2")
    parser.add_argument("--col-tr-type", type=str, default="dct2")
    parser.add_argument("--size", type=int, default=8)
    parser.add_argument("--non-zero-cols", type=int, default=None)
    parser.add_argument("--non-zero-rows", type=int, default=None)
    parser.add_argument("--vector", type=str, default="", help="Optional comma-separated flattened matrix")
    args = parser.parse_args()

    db = load_transform_db(args.json)
    flat = parse_vector_arg(args.vector, args.size) if args.vector else build_demo_flat(args.size)
    matrix = build_matrix_from_flat(flat, args.size)
    output = apply_its_2d(
        matrix=matrix,
        db=db,
        row_tr_type=args.row_tr_type,
        col_tr_type=args.col_tr_type,
        non_zero_cols=args.non_zero_cols,
        non_zero_rows=args.non_zero_rows,
    )

    print(f"Row tr     : {args.row_tr_type}")
    print(f"Col tr     : {args.col_tr_type}")
    print(f"Size       : {args.size}")
    print(f"Input flat : {flat}")
    print("Output flat:")
    print(flatten_matrix(output))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
