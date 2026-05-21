#!/usr/bin/env python3
"""Generate memh golden vectors from the generic 2D ITS Python model."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path


def format_twos_complement(value: int, width: int) -> str:
    mask = (1 << width) - 1
    return f"{value & mask:0{width // 4}x}"


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate a memh golden file for a 2D ITS transform case.")
    parser.add_argument("--json", type=Path, required=True, help="Path to inverse_transform_tables.json")
    parser.add_argument("--row-tr-type", type=str, required=True)
    parser.add_argument("--col-tr-type", type=str, required=True)
    parser.add_argument("--size", type=int, required=True)
    parser.add_argument("--non-zero-cols", type=int, default=None)
    parser.add_argument("--non-zero-rows", type=int, default=None)
    parser.add_argument("--vector", type=str, default="", help="Optional comma-separated flattened input matrix")
    parser.add_argument("--width", type=int, default=64, help="Output word width in bits")
    parser.add_argument("--out", type=Path, required=True, help="Output memh path")
    args = parser.parse_args()

    model_dir = Path(__file__).resolve().parent.parent / "07_model"
    sys.path.insert(0, str(model_dir))

    from its_2d_ref import (  # pylint: disable=import-outside-toplevel
        apply_its_2d,
        build_demo_flat,
        build_matrix_from_flat,
        flatten_matrix,
        load_transform_db,
        parse_vector_arg,
    )

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

    values = flatten_matrix(output)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open("w", encoding="ascii") as fp:
        for value in values:
            fp.write(format_twos_complement(value, args.width))
            fp.write("\n")

    print(f"Wrote {len(values)} values to {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
