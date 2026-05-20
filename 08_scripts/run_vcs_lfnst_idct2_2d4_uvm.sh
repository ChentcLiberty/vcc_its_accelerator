#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="/tmp/lfnst_idct2_2d4_uvm_build"
SIMV="./lfnst_idct2_2d4_uvm_simv"

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

/home/jjt/install/synopsys/vcs/vcs/T-2022.06/bin/vcs \
  -full64 \
  -sverilog \
  -timescale=1ns/1ps \
  -ntb_opts uvm-1.2 \
  -Mdir=./csrc \
  "${ROOT_DIR}/05_rtl/lfnst_core.v" \
  "${ROOT_DIR}/05_rtl/idct2_1d_core.v" \
  "${ROOT_DIR}/05_rtl/its_transpose_buffer.v" \
  "${ROOT_DIR}/05_rtl/lfnst_idct2_col4_core.v" \
  "${ROOT_DIR}/05_rtl/lfnst_idct2_2d4_core.v" \
  "${ROOT_DIR}/06_tb/uvm_lfnst_idct2_2d4/lfnst_idct2_2d4_if.sv" \
  "${ROOT_DIR}/06_tb/uvm_lfnst_idct2_2d4/lfnst_idct2_2d4_uvm_pkg.sv" \
  "${ROOT_DIR}/06_tb/uvm_lfnst_idct2_2d4/tb_lfnst_idct2_2d4_uvm_top.sv" \
  -o "${SIMV}"

"${SIMV}" +UVM_NO_RELNOTES
