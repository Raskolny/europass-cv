#!/usr/bin/env bash
# =============================================================================
#  build-examples.sh — compile every examples/<lang>.typ to PDF
# =============================================================================
#  Examples live in examples/ but import the package entrypoint one level up,
#  so the project root MUST be the repository root (`--root .`); otherwise
#  Typst treats examples/ as the root and "../lib.typ" escapes it.
#
#  Usage:  ./build-examples.sh [outdir]
# =============================================================================
set -euo pipefail
cd "$(dirname "$0")"

OUT="${1:-examples/pdf}"
mkdir -p "$OUT"

ok=0; fail=0
for f in examples/*.typ; do
  c=$(basename "$f" .typ)
  if typst compile \
       --pdf-standard 1.7,ua-1 \
       --ignore-system-fonts \
       --font-path fonts \
       --root . \
       "$f" "$OUT/$c.pdf"; then
    ok=$((ok+1))
  else
    fail=$((fail+1)); echo "FAIL: $c" >&2
  fi
done
echo "examples compiled: $ok ok, $fail failed -> $OUT/"
[ "$fail" -eq 0 ]
