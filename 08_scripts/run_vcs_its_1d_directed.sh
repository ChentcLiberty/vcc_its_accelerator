#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="/tmp/its_1d_directed_build"
SIMV="./its_1d_directed_simv"

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

# Build in /tmp to avoid VCS link/symlink failures on shared folders.
/home/jjt/install/synopsys/vcs/vcs/T-2022.06/bin/vcs \
  -full64 \
  -sverilog \
  -timescale=1ns/1ps \
  -Mdir=./csrc \
  "${ROOT_DIR}/05_rtl/its_1d_core.v" \
  "${ROOT_DIR}/06_tb/tb_its_1d_core.sv" \
  -o "${SIMV}"

"${SIMV}"
