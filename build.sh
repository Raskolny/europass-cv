#!/usr/bin/env bash
# =============================================================================
#  build.sh — canonical, hermetic, PDF/UA-1 build for the Europass CV template
# =============================================================================
#  This is the ONE way the project is meant to be compiled.  The flags are
#  not cosmetic:
#
#    --ignore-system-fonts   never resolve a glyph from a font installed on
#                            the host machine.  The only source of truth is
#                            ./fonts, so the output is byte-for-byte
#                            reproducible on any machine.
#    --font-path fonts       point Typst at the vendored family.
#    --pdf-standard 1.7,ua-1 enforce PDF/UA-1 (ISO 14289-1) accessibility
#                            conformance at compile time.  Typst *fails the
#                            build* if the document would not be accessible
#                            (missing title, missing language, missing
#                            outline, untagged images, ...).
#
#  Usage:  ./build.sh [output.pdf]
# =============================================================================
set -euo pipefail
cd "$(dirname "$0")"

OUT="${1:-output.pdf}"

if ! command -v typst >/dev/null 2>&1; then
  echo "error: 'typst' is not on PATH.  Install Typst >= 0.15 (e.g. 'cargo install typst-cli')." >&2
  exit 1
fi

echo "==> Compiling main.typ -> $OUT  (hermetic fonts + PDF/UA-1)"
typst compile \
  --pdf-standard 1.7,ua-1 \
  --ignore-system-fonts \
  --font-path fonts \
  main.typ "$OUT"

echo "==> Verifying accessibility + font embedding"
./verify.sh "$OUT"

echo "==> OK: $OUT is PDF/UA-1 conformant with fully embedded fonts."
