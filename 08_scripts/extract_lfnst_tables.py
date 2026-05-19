#!/usr/bin/env python3
"""Extract LFNST matrices from the local Huawei Cup DOCX attachment.

The source document contains 16 scenarios:
- 8 cases for nTrs = 16
- 8 cases for nTrs = 48

This script parses the DOCX body text and emits a JSON file that can be
consumed by the Python reference model and later by RTL test generators.
"""

from __future__ import annotations

import argparse
import json
import re
import zipfile
from pathlib import Path
from typing import Dict, List


SCENARIO_RE = re.compile(
    r"场景(?P<scenario>\d+)：nTrs = (?P<ntrs>\d+)，lfnstTrSetIdx = (?P<set_idx>\d+)，lfnst_idx = (?P<lfnst_idx>\d+)"
)


def extract_plain_text(docx_path: Path) -> List[str]:
    """Read DOCX word/document.xml and convert paragraph boundaries to lines."""
    with zipfile.ZipFile(docx_path, "r") as zf:
        xml_text = zf.read("word/document.xml").decode("utf-8")

    xml_text = xml_text.replace("</w:p>", "\n")
    xml_text = re.sub(r"<[^>]+>", "", xml_text)
    xml_text = xml_text.replace("−", "-")
    xml_text = xml_text.replace("&gt;", ">").replace("&lt;", "<").replace("&amp;", "&")

    return [line.strip() for line in xml_text.splitlines() if line.strip()]


def parse_matrix_rows(lines: List[str], start_idx: int, expected_rows: int) -> List[List[int]]:
    """Collect matrix rows following a scenario header."""
    rows: List[List[int]] = []
    idx = start_idx

    while idx < len(lines) and len(rows) < expected_rows:
        numbers = re.findall(r"-?\d+", lines[idx])
        if len(numbers) == 16:
            rows.append([int(num) for num in numbers])
        idx += 1

    if len(rows) != expected_rows:
        raise ValueError(
            f"Expected {expected_rows} rows, but only collected {len(rows)} starting from line {start_idx}"
        )

    return rows


def parse_scenarios(lines: List[str]) -> Dict[str, object]:
    scenarios: List[Dict[str, object]] = []

    for idx, line in enumerate(lines):
        match = SCENARIO_RE.search(line)
        if not match:
            continue

        scenario_id = int(match.group("scenario"))
        ntrs = int(match.group("ntrs"))
        set_idx = int(match.group("set_idx"))
        lfnst_idx = int(match.group("lfnst_idx"))

        expected_rows = 16 if ntrs == 16 else 48
        matrix = parse_matrix_rows(lines, idx + 1, expected_rows)

        scenarios.append(
            {
                "scenario_id": scenario_id,
                "nTrs": ntrs,
                "lfnstTrSetIdx": set_idx,
                "lfnst_idx": lfnst_idx,
                "matrix": matrix,
            }
        )

    if len(scenarios) != 16:
        raise ValueError(f"Expected 16 scenarios, but parsed {len(scenarios)}")

    return {
        "source": "Low frequency non.docx",
        "scenario_count": len(scenarios),
        "scenarios": scenarios,
    }


def build_index(db: Dict[str, object]) -> Dict[str, object]:
    """Add a lookup-oriented index to the exported JSON payload."""
    lookup: Dict[str, Dict[str, Dict[str, List[List[int]]]]] = {"16": {}, "48": {}}

    for scenario in db["scenarios"]:
        ntrs_key = str(scenario["nTrs"])
        set_key = str(scenario["lfnstTrSetIdx"])
        idx_key = str(scenario["lfnst_idx"])

        lookup[ntrs_key].setdefault(set_key, {})
        lookup[ntrs_key][set_key][idx_key] = scenario["matrix"]

    db["lookup"] = lookup
    return db


def main() -> int:
    parser = argparse.ArgumentParser(description="Extract LFNST matrices from DOCX to JSON.")
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
    db = parse_scenarios(lines)
    db = build_index(db)

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(db, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    print(f"Wrote {db['scenario_count']} scenarios to {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
