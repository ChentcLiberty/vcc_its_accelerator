#!/usr/bin/env python3
"""Extract inverse-transform matrices from the local Huawei Cup DOCX attachment.

The contest attachment stores:
- DCT2 as a 64-point base matrix split into two 64x16 column groups
- DST7 as explicit 4/8/16-point matrices plus a partial 32-point table
- DCT8 as explicit 4/8/16-point matrices plus a partial 32-point table

For DCT2, the smaller square transforms are derived from the 64-point base table
by row subsampling with step = 64 / nTbS, which matches the attachment data:
- 4-point  uses rows 0, 16, 32, 48
- 8-point  uses rows 0, 8, 16, ..., 56
- 16-point uses rows 0, 4, 8, ..., 60
- 32-point uses rows 0, 2, 4, ..., 62

For DST7 and DCT8, the attachment gives complete 4/8/16-point tables and the
first 16 rows of the 32-point table. The full 32-point matrices are generated
from the basis-function formula in the contest statement, then cross-checked
against the attached 16-row partial tables.
"""

from __future__ import annotations

import argparse
import json
import math
import re
import zipfile
from pathlib import Path
from typing import Dict, List


TR_TYPE_ID = {
    "dct2": 0,
    "dst7": 1,
    "dct8": 2,
}

KNOWN_DCT2_4 = [
    [64, 64, 64, 64],
    [83, 36, -36, -83],
    [64, -64, -64, 64],
    [36, -83, 83, -36],
]

KNOWN_DST7_4 = [
    [29, 55, 74, 84],
    [74, 74, 0, -74],
    [84, -29, -74, 55],
    [55, -84, 74, -29],
]

KNOWN_DCT8_4 = [
    [84, 74, 55, 29],
    [74, 0, -74, -74],
    [55, -74, -29, 84],
    [29, -74, 84, -55],
]


def extract_plain_text(docx_path: Path) -> List[str]:
    """Read DOCX word/document.xml and convert paragraph boundaries to lines."""
    with zipfile.ZipFile(docx_path, "r") as zf:
        xml_text = zf.read("word/document.xml").decode("utf-8")

    xml_text = xml_text.replace("</w:p>", "\n")
    xml_text = re.sub(r"<[^>]+>", "", xml_text)
    xml_text = xml_text.replace("−", "-")
    xml_text = xml_text.replace("&gt;", ">").replace("&lt;", "<").replace("&amp;", "&")

    return [line.strip() for line in xml_text.splitlines() if line.strip()]


def find_line(lines: List[str], marker: str, start_idx: int = 0) -> int:
    for idx in range(start_idx, len(lines)):
        if marker in lines[idx]:
            return idx
    raise ValueError(f"Failed to find marker: {marker}")


def parse_dense_rows(
    lines: List[str],
    start_idx: int,
    expected_rows: int,
    expected_cols: int,
) -> List[List[int]]:
    rows: List[List[int]] = []
    idx = start_idx

    while idx < len(lines) and len(rows) < expected_rows:
        numbers = re.findall(r"-?\d+", lines[idx])
        if len(numbers) == expected_cols:
            rows.append([int(num) for num in numbers])
        idx += 1

    if len(rows) != expected_rows:
        raise ValueError(
            f"Expected {expected_rows} rows x {expected_cols} cols, only parsed {len(rows)} rows"
        )

    return rows


def reconstruct_dct2_64(col0: List[List[int]], col16: List[List[int]]) -> List[List[int]]:
    """Rebuild the full 64x64 DCT2 matrix from the attachment split blocks."""
    if len(col0) != 64 or len(col16) != 64:
        raise ValueError("DCT2 split blocks must both have 64 rows")

    matrix: List[List[int]] = []
    for row_idx in range(64):
        row = [0] * 64
        row[0:16] = list(col0[row_idx])
        row[16:32] = list(col16[row_idx])

        sign = -1 if (row_idx & 1) else 1
        for col_idx in range(32, 48):
            row[col_idx] = sign * int(col16[row_idx][47 - col_idx])
        for col_idx in range(48, 64):
            row[col_idx] = sign * int(col0[row_idx][63 - col_idx])

        matrix.append(row)

    return matrix


def derive_dct2_square_matrix(base64: List[List[int]], size: int) -> List[List[int]]:
    if size not in (4, 8, 16, 32, 64):
        raise ValueError(f"Unsupported DCT2 size: {size}")

    if size == 64:
        return [list(row) for row in base64]

    step = 64 // size
    return [list(base64[row_idx][:size]) for row_idx in range(0, 64, step)]


def parse_dct2(lines: List[str]) -> Dict[str, List[List[int]]]:
    dct2_idx = find_line(lines, "DCT-II，trType = 0")
    size_idx = find_line(lines, "nTbs = 64", start_idx=dct2_idx)

    col0_idx = find_line(lines, "transMatrixCol0to15 =", start_idx=size_idx)
    col16_idx = find_line(lines, "transMatrixCol16to31 =", start_idx=col0_idx + 1)

    col0 = parse_dense_rows(lines, col0_idx + 1, expected_rows=64, expected_cols=16)
    col16 = parse_dense_rows(lines, col16_idx + 1, expected_rows=64, expected_cols=16)
    base64 = reconstruct_dct2_64(col0, col16)

    return {
        "4": derive_dct2_square_matrix(base64, 4),
        "8": derive_dct2_square_matrix(base64, 8),
        "16": derive_dct2_square_matrix(base64, 16),
        "32": derive_dct2_square_matrix(base64, 32),
        "64": derive_dct2_square_matrix(base64, 64),
    }


def parse_dense_square_section(lines: List[str], marker: str, sizes: List[int]) -> Dict[str, List[List[int]]]:
    section_idx = find_line(lines, marker)
    cursor = section_idx
    matrices: Dict[str, List[List[int]]] = {}

    for size in sizes:
        size_idx = find_line(lines, f"nTbs = {size}", start_idx=cursor)
        matrix_idx = find_line(lines, "transMatrix[ m ][ n ]", start_idx=size_idx)
        matrices[str(size)] = parse_dense_rows(lines, matrix_idx + 1, expected_rows=size, expected_cols=size)
        cursor = size_idx + 1

    return matrices


def parse_partial_32_section(lines: List[str], marker: str) -> List[List[int]]:
    section_idx = find_line(lines, marker)
    size_idx = find_line(lines, "nTbs = 32", start_idx=section_idx)
    col0_idx = find_line(lines, "transMatrixCol0to15 =", start_idx=size_idx)
    col16_idx = find_line(lines, "transMatrixCol16to31 =", start_idx=col0_idx + 1)

    col0 = parse_dense_rows(lines, col0_idx + 1, expected_rows=16, expected_cols=16)
    col16 = parse_dense_rows(lines, col16_idx + 1, expected_rows=16, expected_cols=16)
    return [list(col0[row_idx]) + list(col16[row_idx]) for row_idx in range(16)]


def round_half_away_from_zero(value: float) -> int:
    if value >= 0.0:
        return int(math.floor(value + 0.5))
    return -int(math.floor(-value + 0.5))


def generate_dst7_matrix(size: int) -> List[List[int]]:
    scale = 64.0 * math.sqrt(float(size))
    factor = math.sqrt(4.0 / (2 * size + 1))
    matrix: List[List[int]] = []

    for row_idx in range(size):
        row: List[int] = []
        for col_idx in range(size):
            value = scale * factor * math.sin(
                math.pi * (2 * row_idx + 1) * (col_idx + 1) / (2 * size + 1)
            )
            row.append(round_half_away_from_zero(value))
        matrix.append(row)

    return matrix


def generate_dct8_matrix(size: int) -> List[List[int]]:
    scale = 64.0 * math.sqrt(float(size))
    factor = math.sqrt(4.0 / (2 * size + 1))
    matrix: List[List[int]] = []

    for row_idx in range(size):
        row: List[int] = []
        for col_idx in range(size):
            value = scale * factor * math.cos(
                math.pi * (2 * row_idx + 1) * (2 * col_idx + 1) / (4 * size + 2)
            )
            row.append(round_half_away_from_zero(value))
        matrix.append(row)

    return matrix


def validate_formula_against_attachment(
    formula_matrix: List[List[int]],
    attachment_matrix: List[List[int]],
    transform_name: str,
    size: int,
    tolerance: int = 1,
) -> None:
    max_abs_err = 0
    for row_formula, row_attachment in zip(formula_matrix, attachment_matrix):
        for coeff_formula, coeff_attachment in zip(row_formula, row_attachment):
            max_abs_err = max(max_abs_err, abs(int(coeff_formula) - int(coeff_attachment)))

    if max_abs_err > tolerance:
        raise ValueError(
            f"{transform_name} {size}-point attachment cross-check failed (max_abs_err={max_abs_err})"
        )


def parse_dst7(lines: List[str]) -> Dict[str, List[List[int]]]:
    matrices = parse_dense_square_section(lines, "DST-VII，trType = 1", [4, 8, 16])
    partial_32 = parse_partial_32_section(lines, "DST-VII，trType = 1")
    formula_32 = generate_dst7_matrix(32)
    validate_formula_against_attachment(formula_32, partial_32, "DST7", 32)
    for row_idx in range(len(partial_32)):
        formula_32[row_idx] = list(partial_32[row_idx])
    matrices["32"] = formula_32
    return matrices


def parse_dct8(lines: List[str]) -> Dict[str, List[List[int]]]:
    matrices = parse_dense_square_section(lines, "DCT-VIII，trType = 2", [4, 8, 16])
    partial_32 = parse_partial_32_section(lines, "DCT-VIII，trType = 2")
    formula_32 = generate_dct8_matrix(32)
    validate_formula_against_attachment(formula_32, partial_32, "DCT8", 32)
    for row_idx in range(len(partial_32)):
        formula_32[row_idx] = list(partial_32[row_idx])
    matrices["32"] = formula_32
    return matrices


def validate_tables(db: Dict[str, object]) -> None:
    dct2 = db["transforms"]["dct2"]
    dst7 = db["transforms"]["dst7"]
    dct8 = db["transforms"]["dct8"]

    if dct2["4"] != KNOWN_DCT2_4:
        raise ValueError("DCT2 4x4 matrix validation failed")
    if dst7["4"] != KNOWN_DST7_4:
        raise ValueError("DST7 4x4 matrix validation failed")
    if dct8["4"] != KNOWN_DCT8_4:
        raise ValueError("DCT8 4x4 matrix validation failed")

    known_dct2_8_row1 = [89, 75, 50, 18, -18, -50, -75, -89]
    if dct2["8"][1] != known_dct2_8_row1:
        raise ValueError("DCT2 8x8 row-1 validation failed")


def build_db(lines: List[str]) -> Dict[str, object]:
    transforms = {
        "dct2": parse_dct2(lines),
        "dst7": parse_dst7(lines),
        "dct8": parse_dct8(lines),
    }

    db: Dict[str, object] = {
        "source": "Low frequency non.docx",
        "transforms": transforms,
        "lookup_by_id": {
            str(TR_TYPE_ID[name]): tables for name, tables in transforms.items()
        },
        "metadata": {
            "tr_type_id": TR_TYPE_ID,
            "supported_sizes": {
                "dct2": [4, 8, 16, 32, 64],
                "dst7": [4, 8, 16, 32],
                "dct8": [4, 8, 16, 32],
            },
            "notes": {
                "dct2": "4/8/16/32 are derived from the reconstructed 64-point base matrix by row stride 64/nTbS.",
                "dst7": "4/8/16 are parsed directly. For 32-point, the first 16 rows come from the attachment and the remaining 16 rows are generated analytically, with a <=1 coefficient cross-check against the partial table.",
                "dct8": "4/8/16 are parsed directly. For 32-point, the first 16 rows come from the attachment and the remaining 16 rows are generated analytically, with a <=1 coefficient cross-check against the partial table.",
            },
        },
    }

    validate_tables(db)
    return db


def main() -> int:
    parser = argparse.ArgumentParser(description="Extract inverse transform matrices from DOCX to JSON.")
    parser.add_argument(
        "--docx",
        type=Path,
        required=True,
        help="Path to Low frequency non.docx",
    )
    parser.add_argument(
        "--out",
        type=Path,
        required=True,
        help="Output JSON file path",
    )
    args = parser.parse_args()

    lines = extract_plain_text(args.docx)
    db = build_db(lines)

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(db, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    print(f"Wrote inverse transform tables to {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
