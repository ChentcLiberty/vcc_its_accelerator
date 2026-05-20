#!/usr/bin/env python3
"""Generate a size-major IDCT2 ROM .memh from inverse_transform_tables.json."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


SIZE_ORDER = [4, 8, 16, 32, 64]
MAX_SIZE = 64


def to_twos_complement_hex(value: int, width: int) -> str:
    if value < 0:
        value = (1 << width) + value
    digits = (width + 3) // 4
    return f"{value:0{digits}X}"


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate IDCT2 ROM memh file.")
    parser.add_argument("--json", type=Path, required=True, help="Path to inverse_transform_tables.json")
    parser.add_argument("--out", type=Path, required=True, help="Output memh path")
    parser.add_argument("--width", type=int, default=8, help="Coefficient storage width")
    args = parser.parse_args()

    db = json.loads(args.json.read_text(encoding="utf-8"))
    lines = []

    for size in SIZE_ORDER:
        matrix = db["transforms"]["dct2"][str(size)]
        for row_idx in range(MAX_SIZE):
            if row_idx < size:
                row = [int(v) for v in matrix[row_idx]] + [0] * (MAX_SIZE - size)
            else:
                row = [0] * MAX_SIZE

            for coeff in row:
                lines.append(to_twos_complement_hex(coeff, args.width))

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {len(lines)} ROM words to {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
