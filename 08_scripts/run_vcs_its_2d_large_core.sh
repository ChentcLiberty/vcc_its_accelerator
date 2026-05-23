#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="/tmp/its_2d_large_core_build"
SIMV="./its_2d_large_core_simv"

python3 "${ROOT_DIR}/08_scripts/gen_its_2d_expected_memh.py" \
  --json "${ROOT_DIR}/07_model/inverse_transform_tables.json" \
  --row-tr-type dct2 \
  --col-tr-type dct2 \
  --size 32 \
  --width 64 \
  --out "${ROOT_DIR}/06_tb/data/its_2d32_dct2_full_expected.memh"

python3 "${ROOT_DIR}/08_scripts/gen_its_2d_expected_memh.py" \
  --json "${ROOT_DIR}/07_model/inverse_transform_tables.json" \
  --row-tr-type dct2 \
  --col-tr-type dct2 \
  --size 64 \
  --width 64 \
  --out "${ROOT_DIR}/06_tb/data/its_2d64_dct2_full_expected.memh"

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

/home/jjt/install/synopsys/vcs/vcs/T-2022.06/bin/vcs \
  -full64 \
  -sverilog \
  -timescale=1ns/1ps \
  -Mdir=./csrc \
  "${ROOT_DIR}/05_rtl/its_1d_core.v" \
  "${ROOT_DIR}/05_rtl/its_transpose_buffer.v" \
  "${ROOT_DIR}/05_rtl/its_2d_large_core.v" \
  "${ROOT_DIR}/06_tb/tb_its_2d_large_core.sv" \
  -o "${SIMV}"

"${SIMV}"
