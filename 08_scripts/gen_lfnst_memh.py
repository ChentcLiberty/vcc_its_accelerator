#!/usr/bin/env python3
"""Generate a scenario-major LFNST ROM .memh from lfnst_tables.json."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def to_twos_complement_hex(value: int, width: int) -> str:
    if value < 0:
        value = (1 << width) + value
    digits = (width + 3) // 4
    return f"{value:0{digits}X}"


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate LFNST ROM memh file.")
    parser.add_argument("--json", type=Path, required=True, help="Path to lfnst_tables.json")
    parser.add_argument("--out", type=Path, required=True, help="Output memh path")
    parser.add_argument("--width", type=int, default=9, help="Coefficient storage width")
    args = parser.parse_args()

    db = json.loads(args.json.read_text(encoding="utf-8"))
    lines = []

    for scenario in db["scenarios"]:
        matrix = scenario["matrix"]
        row_count = 48
        col_count = 16

        for row_idx in range(row_count):
            if row_idx < len(matrix):
                row = matrix[row_idx]
            else:
                row = [0] * col_count

            for coeff in row:
                lines.append(to_twos_complement_hex(int(coeff), args.width))

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {len(lines)} ROM words to {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
