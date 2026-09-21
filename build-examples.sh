#!/usr/bin/env bash
# =============================================================================
#  build-examples.sh — compile every examples/<lang>.typ to PDF
# =============================================================================
#  Examples import the package through its Universe specification
#  (`@preview/rasko-europass:1.0.0`), exactly as end users will.  To compile
#  them from this repository before publication, we materialise a local
#  package cache mirroring the Universe bundle and point Typst at it with
#  --package-path.
#
#  The project root MUST be the repository root (`--root .`) so that paths
#  inside the package cache resolve correctly.
#
#  Usage:  ./build-examples.sh [outdir]
# =============================================================================
set -euo pipefail
cd "$(dirname "$0")"

OUT="${1:-examples/pdf}"
mkdir -p "$OUT"

# Local package cache mirroring the Universe bundle (no fonts: Universe
# policy forbids shipping font binaries in a package).
CACHE=".pkgcache/preview/rasko-europass/1.0.0"
rm -rf .pkgcache
mkdir -p "$CACHE"
for f in lib.typ lang.toml typst.toml README.md LICENSE NOTICE.md thumbnail.png assets examples main.typ; do
  cp -r "$f" "$CACHE"/
done

ok=0; fail=0
for f in examples/*.typ; do
  c=$(basename "$f" .typ)
  if typst compile \
       --pdf-standard 1.7,ua-1 \
       --ignore-system-fonts \
       --font-path fonts \
       --package-path .pkgcache \
       --root . \
       "$f" "$OUT/$c.pdf"; then
    ok=$((ok+1))
  else
    fail=$((fail+1)); echo "FAIL: $c" >&2
  fi
done
echo "examples compiled: $ok ok, $fail failed -> $OUT/"
[ "$fail" -eq 0 ]
