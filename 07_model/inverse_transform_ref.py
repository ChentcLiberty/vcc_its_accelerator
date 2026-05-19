#!/usr/bin/env python3
"""Pure Python 1D inverse-transform reference model for Huawei Cup Problem 1."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Iterable, List, Sequence


TR_TYPE_ALIASES = {
    "0": "dct2",
    "1": "dst7",
    "2": "dct8",
    "dct2": "dct2",
    "dct-ii": "dct2",
    "dctii": "dct2",
    "dst7": "dst7",
    "dst-vii": "dst7",
    "dstvii": "dst7",
    "dct8": "dct8",
    "dct-viii": "dct8",
    "dctviii": "dct8",
}


def load_transform_db(json_path: Path) -> dict:
    return json.loads(json_path.read_text(encoding="utf-8"))


def normalize_tr_type(tr_type: str | int) -> str:
    key = str(tr_type).strip().lower()
    if key not in TR_TYPE_ALIASES:
        raise ValueError(f"Unsupported transform type: {tr_type}")
    return TR_TYPE_ALIASES[key]


def get_transform_matrix(db: dict, tr_type: str | int, size: int) -> List[List[int]]:
    tr_name = normalize_tr_type(tr_type)
    size_key = str(size)

    try:
        matrix = db["transforms"][tr_name][size_key]
    except KeyError as exc:
        raise ValueError(f"Transform {tr_name} does not support size {size}") from exc

    return matrix


def apply_transform_vector(
    x: Sequence[int],
    matrix: Sequence[Sequence[int]],
    non_zero_size: int | None = None,
) -> List[int]:
    size = len(matrix)
    if len(x) != size:
        raise ValueError(f"Expected input vector length {size}, got {len(x)}")

    if non_zero_size is None:
        non_zero_size = size

    if not 0 <= non_zero_size <= size:
        raise ValueError(f"non_zero_size must be in [0, {size}], got {non_zero_size}")

    outputs: List[int] = []
    for row in matrix:
        acc = 0
        for idx in range(non_zero_size):
            acc += int(row[idx]) * int(x[idx])
        outputs.append(acc)
    return outputs


def apply_inverse_transform(
    x: Sequence[int],
    tr_type: str | int,
    size: int,
    db: dict,
    non_zero_size: int | None = None,
) -> List[int]:
    matrix = get_transform_matrix(db, tr_type, size)
    return apply_transform_vector(x=x, matrix=matrix, non_zero_size=non_zero_size)


def build_demo_vector(size: int) -> List[int]:
    return list(range(1, size + 1))


def parse_vector_arg(text: str, size: int) -> List[int]:
    values = [int(part.strip()) for part in text.split(",") if part.strip()]
    if len(values) != size:
        raise ValueError(f"Expected {size} comma-separated integers, got {len(values)}")
    return values


def main() -> int:
    parser = argparse.ArgumentParser(description="Run a simple 1D inverse-transform reference-model demo.")
    parser.add_argument(
        "--json",
        type=Path,
        required=True,
        help="Path to inverse_transform_tables.json",
    )
    parser.add_argument(
        "--tr-type",
        type=str,
        default="dct2",
        help="Transform type: dct2 / dct8 / dst7 or 0 / 2 / 1",
    )
    parser.add_argument("--size", type=int, default=8)
    parser.add_argument("--non-zero-size", type=int, default=None)
    parser.add_argument(
        "--vector",
        type=str,
        default="",
        help="Optional comma-separated input vector",
    )
    args = parser.parse_args()

    db = load_transform_db(args.json)
    vector = parse_vector_arg(args.vector, args.size) if args.vector else build_demo_vector(args.size)
    outputs = apply_inverse_transform(
        x=vector,
        tr_type=args.tr_type,
        size=args.size,
        db=db,
        non_zero_size=args.non_zero_size,
    )

    print(f"Transform: {normalize_tr_type(args.tr_type)}")
    print(f"Size     : {args.size}")
    print(f"Input    : {vector}")
    print(f"Output   : {outputs}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
