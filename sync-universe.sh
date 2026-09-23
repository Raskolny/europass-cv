#!/usr/bin/env bash
# =============================================================================
#  sync-universe.sh — keep the typst/packages submission in step with this
#                     repository, without ever shipping unreleased code.
# =============================================================================
#  WHY THIS EXISTS
#
#  The package is developed here but submitted to a *fork of typst/packages*,
#  where files must be physically copied (submodules are forbidden).  Pushing
#  here does **not** update that PR — the copy is manual, and it silently rots.
#  Review of typst/packages#5905 found the bundled README and CHANGELOG stale.
#
#  THE TWO FAILURE MODES THIS GUARDS AGAINST
#
#   1. Stale docs — the bundle describes an older package than the one shipped.
#   2. Leaked future code — `main` carries unreleased work (1.1.0's
#      signature-image, spacing changes, new lang.toml keys, country-convention
#      examples).  A submitted version is **frozen**: copying `main` over it
#      would publish 1.1.0 features under a 1.0.0 label.
#
#  So the bundle is held to two different baselines at once:
#
#    FROZEN  must equal the release tag `v<version>` verbatim.  These are the
#            files that affect compiled output:
#              lib.typ  lang.toml  LICENSE  NOTICE.md  thumbnail.png
#              assets/**  examples/*.typ
#
#    LIVE    synced from the working tree, because they are documentation and
#            are written to stay correct across versions (unreleased features
#            are explicitly labelled as such):
#              README.md
#              CHANGELOG.md          (the `## [Unreleased]` section is dropped)
#              template/main.typ     (guarded: see below)
#
#    NEVER   must be absent from the bundle (repository-only, per typst.toml's
#            `exclude` and typst/packages docs/tips.md):
#              fonts/  build.sh  build-examples.sh  verify.sh  sync-universe.sh
#              .github/  social-preview.typ  social-preview.png  output.pdf
#              examples/pdf/  .gitignore  .pkgcache/  .devin/  preview.png
#              PUBLISHING.md  CONTRIBUTING.md  ROADMAP.md
#
#    MANUAL  typst.toml is never written: the submission declares a `[template]`
#            table that this development manifest deliberately lacks (see
#            ROADMAP.md).  Its shared `[package]` fields are compared and any
#            mismatch is reported for a human to reconcile.
#
#  THE template/main.typ GUARD
#
#  main.typ is LIVE so that documentation-only fixes reach the submission, but
#  that would also let real feature code leak into a frozen version.  The sync
#  therefore strips `//` comment lines from both the working tree's main.typ and
#  the tag's, and refuses to write unless the *code* is identical.
#
#  Usage:
#    ./sync-universe.sh <packages-fork-dir>            # report, then sync
#    ./sync-universe.sh <packages-fork-dir> --check    # report only; exit 1 on
#                                                      # drift (CI-friendly)
#    ./sync-universe.sh <packages-fork-dir> --force    # sync even while a
#                                                      # review hold is active
#
#  THE REVIEW HOLD
#
#  If `.universe-review-pending` exists in the repository root, the sync reports
#  drift as usual but refuses to write.  While a typst/packages review is open,
#  the submitted bundle must stay exactly as the reviewer last saw it: pushing
#  new commits to the PR branch silently invalidates their review and makes them
#  re-read everything.  Development on `main` is unaffected -- only the copy
#  into the fork is held.  Delete the marker once the review is resolved, or
#  pass --force to override deliberately.
# =============================================================================
set -euo pipefail
cd "$(dirname "$0")"

FORK="${1:-}"
shift || true
MODE="sync"
FORCE=0
for arg in "$@"; do
  case "$arg" in
    --check) MODE="--check" ;;
    --force) FORCE=1 ;;
    *) echo "error: unknown option: $arg" >&2; exit 2 ;;
  esac
done

if [ -z "$FORK" ]; then
  cat >&2 <<'EOF'
usage: ./sync-universe.sh <packages-fork-dir> [--check] [--force]

  <packages-fork-dir>   a sparse clone of your typst/packages fork:
                          git clone --depth 1 --no-checkout --filter=tree:0 \
                            git@github.com:Raskolny/packages.git
                          cd packages
                          git sparse-checkout init
                          git sparse-checkout set packages/preview/rasko-europass
                          git checkout rasko-europass-1.0.0

  --check               report drift and write nothing; exit 1 on drift
  --force               sync even though .universe-review-pending is present
EOF
  exit 2
fi

HOLD_MARKER=".universe-review-pending"

NAME=$(sed -n 's/^name *= *"\(.*\)"/\1/p' typst.toml | head -1)
VERSION=$(sed -n 's/^version *= *"\(.*\)"/\1/p' typst.toml | head -1)
if [ -z "$NAME" ] || [ -z "$VERSION" ]; then
  echo "error: cannot read name/version from typst.toml" >&2
  exit 1
fi
TAG="v$VERSION"

DEST="$FORK/packages/preview/$NAME/$VERSION"
if [ ! -d "$FORK/packages/preview" ]; then
  echo "error: $FORK does not look like a typst/packages checkout (no packages/preview/)" >&2
  exit 1
fi
if ! git rev-parse -q --verify "refs/tags/$TAG" >/dev/null; then
  echo "error: tag $TAG not found — the FROZEN baseline is undefined." >&2
  echo "       Tag the release first, or edit VERSION in typst.toml." >&2
  exit 1
fi

FROZEN_FILES=(lib.typ lang.toml LICENSE NOTICE.md thumbnail.png)
FROZEN_DIRS=(assets examples)
NEVER=(build.sh build-examples.sh verify.sh sync-universe.sh
       social-preview.typ social-preview.png output.pdf .gitignore
       PUBLISHING.md CONTRIBUTING.md ROADMAP.md preview.png
       .universe-review-pending)
NEVER_DIRS=(fonts .github .pkgcache .devin examples/pdf)

drift=0
note() { printf '  %s\n' "$*"; }

# tagfile <path> — emit a frozen file's content from the release tag, or fail.
tagfile() { git show "$TAG:$1"; }

# strip_comments — reduce a Typst file to its code so that comment-only edits
# can be told apart from real changes.  Trailing and whole-line `//` comments
# are removed, then the blank lines they leave behind are dropped: without that
# last step, two versions differing only in how many lines a comment block
# occupies would compare unequal.
strip_comments() { sed -e 's#//.*##' -e '/^[[:space:]]*$/d'; }

echo "==> Package:  $NAME $VERSION   (FROZEN baseline: $TAG)"
echo "==> Bundle:   $DEST"
echo

# ---------------------------------------------------------------------------
#  FROZEN — must equal the release tag.
# ---------------------------------------------------------------------------
echo "==> FROZEN files (must equal $TAG)"
frozen_paths=()
for f in "${FROZEN_FILES[@]}"; do frozen_paths+=("$f"); done
for d in "${FROZEN_DIRS[@]}"; do
  [ -d "$d" ] || continue
  while IFS= read -r p; do
    case "$p" in examples/pdf/*) continue ;; esac
    frozen_paths+=("$p")
  done < <(git ls-tree -r --name-only "$TAG" -- "$d" | sort)
done

for p in "${frozen_paths[@]}"; do
  if [ ! -f "$DEST/$p" ]; then
    note "MISSING in bundle: $p"; drift=1
  elif tagfile "$p" | cmp -s - "$DEST/$p"; then
    note "same     $p"
  else
    note "DRIFT    $p  (bundle differs from $TAG — do not 'fix' by copying main;"
    note "         $p is frozen.  Diff with: git diff $TAG -- $p)"
    drift=1
  fi
done

# ---------------------------------------------------------------------------
#  LIVE — README.md, CHANGELOG.md, template/main.typ.
# ---------------------------------------------------------------------------
echo
echo "==> LIVE docs (synced from the working tree)"
if cmp -s README.md "$DEST/README.md"; then
  note "same     README.md"
else
  note "STALE    README.md"; drift=1
fi

# README links.  The typst/packages linter warns on any GitHub URL that points
# at the default branch, and it is right to: a reader of the *packaged* README
# who follows one lands on unreleased code.  Every versioned link must be pinned
# to this release's tag, so the pin has to be bumped on each release (see
# PUBLISHING.md §4).  Branch-less URLs — the CI badge, the clone URL, the repo
# root — are fine and are not reported.
echo
echo "==> README link pinning (versioned links must point at $TAG)"
pin_issues=0
while IFS= read -r url; do
  [ -n "$url" ] || continue
  case "$url" in
    */main/*|*/main.*|*refs/heads/main*)
      note "BRANCH   $url"
      note "         -> default-branch link: the linter warns, and a package user"
      note "            would fetch unreleased code.  Pin it to $TAG."
      pin_issues=1; drift=1 ;;
    */tree/v*|*/blob/v*|*/raw/v*|*refs/tags/v*)
      case "$url" in
        *"/$TAG/"*|*"tags/$TAG."*) : ;;
        *)
          note "STALEPIN $url"
          note "         -> pinned to a different release; expected $TAG."
          pin_issues=1; drift=1 ;;
      esac ;;
  esac
done < <(grep -oE 'https://[^)" )]*' README.md | sort -u)
if [ "$pin_issues" -eq 0 ]; then
  note "ok       every versioned link is pinned to $TAG"
fi

# CHANGELOG: bundle = repo minus the [Unreleased] section.
tmp_changelog=$(mktemp)
trap 'rm -f "$tmp_changelog"' EXIT
awk '/^## \[/ { skip = ($0 ~ /^## \[Unreleased\]/) } !skip { print }' \
  CHANGELOG.md > "$tmp_changelog"
if cmp -s "$tmp_changelog" "$DEST/CHANGELOG.md"; then
  note "same     CHANGELOG.md (minus [Unreleased])"
else
  note "STALE    CHANGELOG.md (minus [Unreleased])"; drift=1
fi

# template/main.typ: LIVE, but only while it differs from the tag by comments.
main_typ_ok=0
if [ -f "$DEST/template/main.typ" ]; then
  if tagfile main.typ | strip_comments | cmp -s - <(strip_comments < "$DEST/template/main.typ"); then
    if cmp -s main.typ "$DEST/template/main.typ"; then
      note "same     template/main.typ"; main_typ_ok=1
    else
      note "COMMENT-ONLY drift in template/main.typ (will refresh)"; drift=1
    fi
  else
    note "BLOCKED  template/main.typ: its *code* differs from $TAG."
    note "         main.typ is LIVE only for comment/doc fixes; syncing it now"
    note "         would publish unreleased code under $VERSION.  Resolve by hand."
    drift=1
  fi
else
  note "MISSING in bundle: template/main.typ"; drift=1
fi

# ---------------------------------------------------------------------------
#  NEVER — repository-only files must be absent.
# ---------------------------------------------------------------------------
echo
echo "==> Repository-only files (must be absent from the bundle)"
absent_ok=1
for bad in "${NEVER[@]}"; do
  if [ -e "$DEST/$bad" ]; then note "PRESENT  $bad  (must be removed)"; drift=1; absent_ok=0; fi
done
for bad in "${NEVER_DIRS[@]}"; do
  if [ -e "$DEST/$bad" ]; then note "PRESENT  $bad/  (must be removed)"; drift=1; absent_ok=0; fi
done
[ "$absent_ok" -eq 1 ] && note "none present — clean"

# ---------------------------------------------------------------------------
#  MANUAL — typst.toml.
# ---------------------------------------------------------------------------
echo
echo "==> typst.toml (never written; compared only)"
if [ ! -f "$DEST/typst.toml" ]; then
  note "MISSING in bundle: typst.toml"; drift=1
else
  for key in name version entrypoint license description repository compiler; do
    a=$(sed -n "s/^$key *= *\(.*\)/\1/p" typst.toml | head -1)
    b=$(sed -n "s/^$key *= *\(.*\)/\1/p" "$DEST/typst.toml" | head -1)
    if [ -z "$b" ]; then
      note "MISSING  [package] $key"; drift=1
    elif [ "$a" != "$b" ]; then
      note "DIFFERS  [package] $key"
      note "           repo:   $a"
      note "           bundle: $b"
      drift=1
    fi
  done
  if grep -q '^\[template\]' "$DEST/typst.toml"; then
    note "same     [package] fields; [template] table present"
  else
    note "MISSING  [template] table"; drift=1
  fi
  # The template thumbnail is stripped automatically; it must not be in exclude,
  # and no preview.png workaround should remain.
  if grep -q 'preview\.png' "$DEST/typst.toml"; then
    note "STALE    typst.toml still mentions preview.png"; drift=1
  fi
fi

echo
if [ "$drift" -eq 0 ]; then
  echo "==> OK: bundle is in sync with $TAG (frozen) and the working tree (docs)."
  exit 0
fi

if [ "$MODE" = "--check" ]; then
  echo "==> DRIFT DETECTED (check mode; nothing written)."
  echo "    Run: ./sync-universe.sh $FORK"
  exit 1
fi

# ---------------------------------------------------------------------------
#  Review hold — refuse to write while a typst/packages review is open.
# ---------------------------------------------------------------------------
if [ -f "$HOLD_MARKER" ] && [ "$FORCE" -eq 0 ]; then
  echo
  echo "==> HELD: $HOLD_MARKER is present, so nothing will be written."
  echo "    A typst/packages review is in progress and the submitted bundle must"
  echo "    stay exactly as the reviewer last saw it.  Development on main is"
  echo "    unaffected; only the copy into the fork is held."
  echo
  echo "    --- $HOLD_MARKER ---"
  sed 's/^/    /' "$HOLD_MARKER"
  echo "    ---"
  echo
  echo "    Once the review is resolved:  rm $HOLD_MARKER   (then re-run)"
  echo "    To override deliberately:     ./sync-universe.sh $FORK --force"
  exit 1
fi

# ---------------------------------------------------------------------------
#  Apply the LIVE part only.  FROZEN drift is never auto-fixed: overwriting a
#  frozen file from the working tree is exactly the bug this script prevents.
# ---------------------------------------------------------------------------
echo "==> Syncing LIVE docs (FROZEN drift, if any, needs a human)"
mkdir -p "$DEST"
cp -p README.md "$DEST/README.md";               note "wrote    README.md"
cp -p "$tmp_changelog" "$DEST/CHANGELOG.md";     note "wrote    CHANGELOG.md (dropped [Unreleased])"

if [ "$main_typ_ok" -eq 1 ] || { tagfile main.typ | strip_comments | cmp -s - <(strip_comments < main.typ); }; then
  mkdir -p "$DEST/template"
  cp -p main.typ "$DEST/template/main.typ";      note "wrote    main.typ -> template/main.typ"
fi

# Obsolete workaround from before the reviewer's R3: a duplicate of
# thumbnail.png committed only to act as the README banner.  Pruned on sync.
if [ -f "$DEST/preview.png" ]; then
  rm -f "$DEST/preview.png"; note "removed  preview.png"
fi

echo
echo "==> Done.  Review, then commit and push inside the fork:"
echo "      cd $FORK"
echo "      git status && git diff --stat"
echo "      git add -A && git commit && git push"
