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
#    --package-path          resolve the in-repo `@preview/rasko-europass`
#                            import from a local cache that mirrors the
#                            Universe bundle (see below).
#    --pdf-standard 1.7,ua-1 enforce PDF/UA-1 (ISO 14289-1) accessibility
#                            conformance at compile time.  Typst *fails the
#                            build* if the document would not be accessible
#                            (missing title, missing language, missing
#                            outline, untagged images, ...).
#
#  NOTE ON FONTS: ./fonts is vendored for reproducible *repository* builds.
#  Typst Universe policy forbids shipping font binaries inside a package, so
#  the package cache (and the published bundle) deliberately excludes them;
#  Universe users install Open Sans themselves or pass `font:`.
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

# Materialise a local package cache mirroring the Universe bundle so that
# main.typ's `@preview/rasko-europass:1.0.0` import resolves in-repo.
CACHE=".pkgcache/preview/rasko-europass/1.0.0"
rm -rf .pkgcache
mkdir -p "$CACHE"
for f in lib.typ lang.toml typst.toml README.md LICENSE NOTICE.md thumbnail.png assets examples main.typ; do
  cp -r "$f" "$CACHE"/
done

echo "==> Compiling main.typ -> $OUT  (hermetic fonts + PDF/UA-1)"
typst compile \
  --pdf-standard 1.7,ua-1 \
  --ignore-system-fonts \
  --font-path fonts \
  --package-path .pkgcache \
  main.typ "$OUT"

echo "==> Verifying accessibility + font embedding"
./verify.sh "$OUT"

echo "==> OK: $OUT is PDF/UA-1 conformant with fully embedded fonts."
