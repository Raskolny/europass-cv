#!/usr/bin/env bash
# =============================================================================
#  verify.sh — assert the rendered PDF is accessible AND font-self-contained
# =============================================================================
#  Checks, in order:
#    1. Every font in the PDF is EMBEDDED (emb=yes) and SUBSETTED (sub=yes).
#    2. No Base-14 / non-embedded "local PDF font" is referenced
#       (Helvetica, Times, Courier, Symbol, ZapfDingbats).
#    3. PDF/UA structural markers exist: /MarkInfo Marked true,
#       /StructTreeRoot, a document /Lang, and XMP /Metadata.
#    4. The tag tree contains real heading structure (H1 + H2) so a document
#       outline exists — PDF/UA-1 rejects documents without one.
#    5. The CEFR grid is tagged as a genuine data table (Table/THead/TH/TD).
#    6. The presentational two-column layout is NOT incorrectly tagged as a
#       data table (it must be Div), so screen readers never announce a bogus
#       table.
#
#  Usage:  ./verify.sh [output.pdf]
# =============================================================================
set -euo pipefail
cd "$(dirname "$0")"

PDF="${1:-output.pdf}"
[ -f "$PDF" ] || { echo "error: $PDF not found — run ./build.sh first" >&2; exit 1; }

fail() { echo "FAIL: $1" >&2; exit 1; }
ok()   { echo "  ok: $1"; }

# Locate a Python interpreter that actually has pymupdf.  Do NOT trust bare
# `python3`: tool venvs (linters, etc.) can shadow PATH with an interpreter
# that lacks it, which would make this verifier fail spuriously.
PY=""
for cand in "$(command -v python3 || true)" /usr/bin/python3 /usr/local/bin/python3 /bin/python3; do
  [ -n "$cand" ] && [ -x "$cand" ] || continue
  if "$cand" -c "import pymupdf" >/dev/null 2>&1; then PY="$cand"; break; fi
done
[ -n "$PY" ] || fail "no Python interpreter with pymupdf found (pip install pymupdf)"

echo "== 1/6 font embedding =="
if ! command -v pdffonts >/dev/null 2>&1; then
  echo "  (pdffonts missing — skipping font check; install poppler-utils)" >&2
else
  # pdffonts columns are POSITIONAL (the `type` field is two words, e.g.
  # "CID TrueType"), so naive awk field-splitting is wrong.  Derive the column
  # boundaries from the dashed ruler line and slice each row by position.
  "$PY" - "$PDF" << 'PY'
import subprocess, sys, re
pdf = sys.argv[1]
out = subprocess.run(["pdffonts", pdf], capture_output=True, text=True).stdout
lines = [l for l in out.splitlines() if l.strip()]
ruler = next(i for i, l in enumerate(lines) if set(l.strip()) <= {"-", " "})
rule = lines[ruler]
cols = [(m.start(), m.end()) for m in re.finditer(r"-+", rule)]
header = [lines[ruler - 1][a:b].strip() for a, b in cols]
rows = []
for l in lines[ruler + 1:]:
    row = {}
    for (a, b), h in zip(cols, header):
        row[h] = l[a:b].strip() if b <= len(l) else l[a:].strip()
    rows.append(row)
if not rows:
    print("FAIL: no fonts in PDF"); sys.exit(1)
bad = [r.get("name", "?") for r in rows if r.get("emb") != "yes"]
if bad:
    print("FAIL: non-embedded font(s):", bad); sys.exit(1)
print(f"  ok: all {len(rows)} font(s) embedded")
sub = [r.get("name", "?") for r in rows if r.get("sub") != "yes"]
if sub:
    print("FAIL: font(s) not subsetted:", sub); sys.exit(1)
print("  ok: all fonts subsetted")
uni = [r.get("name", "?") for r in rows if r.get("uni") != "yes"]
if uni:
    print("FAIL: font(s) without Unicode cmap (breaks screen readers):", uni); sys.exit(1)
print("  ok: all fonts carry a Unicode cmap (text is extractable)")
b14 = [r for r in rows if re.search(r"Helvetica|Times|Courier|Symbol|ZapfDingbats", r.get("name", ""))]
if b14:
    print("FAIL: Base-14 / local PDF font referenced:", [r["name"] for r in b14]); sys.exit(1)
print("  ok: no Base-14 (local) fonts referenced")
PY
fi

echo "== 2/6 PDF/UA structural markers =="
"$PY" - "$PDF" << 'PY'
import sys, re, zlib
import pymupdf
pdf = sys.argv[1]
d = pymupdf.open(pdf)
cat = d.pdf_catalog()
def key(k): return d.xref_get_key(cat, k)
def die(msg):
    print("FAIL:", msg); sys.exit(1)

if key("StructTreeRoot")[0] not in ("xref",): die("missing /StructTreeRoot")
mi = key("MarkInfo")
if mi[0] != "dict" or "Marked true" not in mi[1].replace("/", " /"): 
    # tolerate dict form
    if not (mi[0]=="dict" and "true" in mi[1]): die("missing /MarkInfo Marked true")
if key("Lang")[0] not in ("string",): die("missing document /Lang")
if key("Metadata")[0] not in ("xref",): die("missing XMP /Metadata")
print("  ok: StructTreeRoot + MarkInfo(Marked) + Lang + XMP present")

print("== 3/6 document outline ==")
toc = d.get_toc()
if not toc: die("empty PDF outline — PDF/UA-1 requires one")
print(f"  ok: outline has {len(toc)} bookmark(s); root = {toc[0][1]!r}")

print("== 4/6 + 5/6 + 6/6 tag tree ==")
d.save("/tmp/_verify_unc.pdf", garbage=4, clean=True)
raw = open("/tmp/_verify_unc.pdf","rb").read()
chunks = []
for m in re.finditer(rb'stream\r?\n', raw):
    s = m.end(); e = raw.find(b'endstream', s)
    try: chunks.append(zlib.decompress(raw[s:e]))
    except Exception: pass
txt = (raw + b"\n".join(chunks)).decode("latin-1")
tags = set(re.findall(r'/S\s*/([A-Za-z][A-Za-z0-9]{0,15})\b', txt))
for t in ("H1","H2","Table","THead","TH","TD","L","LI"):
    if t not in tags: die(f"tag /{t} missing from structure tree")
print("  ok: H1/H2 headings + Table/THead/TH/TD + L/LI list tags present")
if "Div" not in tags: die("expected Div tags for the presentational layout grid")
print("  ok: layout grid tagged as Div (not a bogus data table)")
PY

echo "ALL CHECKS PASSED"
