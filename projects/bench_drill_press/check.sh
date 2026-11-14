#!/usr/bin/env bash
# Run all assembly checks for every pose and tool; exit 1 on any failure.
# Usage: bash check.sh   (from this folder)
cd "$(dirname "$0")"
S=../../common/skills/openscad/scripts
out=$(python3 $S/asm.py bench_drill_press.scad --check --clash --brief "$@" 2>&1); rc=$?
echo "$out"
if [ $rc -ne 0 ] || echo "$out" | grep -q "Traceback" || echo "$out" | grep -qE "CHECK (FAIL|\?)|[1-9][0-9]* FAIL|ERROR|NOT WATERTIGHT|NON-MANIFOLD|EMPTY|[1-9][0-9]* overlapping|Assertion|PIECES"; then
  echo "check.sh: FAIL"; exit 1; fi
echo "check.sh: PASS"
