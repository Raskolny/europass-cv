# Publishing checklist

This package is published in **two stages, in this order**: the GitHub
repository first, then Typst Universe.  Universe versions are **immutable**
and the listing displays `typst.toml`'s `repository`, so the repo (and its
`v1.0.0` tag) must exist *before* the Universe submission — otherwise fixing
the link later forces a pointless `1.0.1` bump.

## 0. Pre-flight (placeholders already resolved)

- [x] `typst.toml` → `authors = ["rasko-- <raskolny@gmail.com>"]` (Universe display name)
- [x] `typst.toml` → `repository = "https://github.com/Raskolny/europass-cv"`
- [x] `thumbnail.png` present at repo root and included in the package bundle.
      A `thumbnail` key is only valid inside a `[template]` table — unknown
      `[package]` fields are rejected by the bundler (it failed CI with
      `unknown fields in package: ["thumbnail"]`).  The submission therefore
      declares `[template]` (see §2): `thumbnail = "thumbnail.png"` there.
      `typst/packages` `docs/manifest.md` states the thumbnail "will
      automatically be excluded from the package files and **must not be
      referenced anywhere in the package**", and `bundler/src/main.rs` enforces
      the exclusion (`// Always ignore the thumbnail.`) — so the README banner
      cannot point at it relatively, or the image breaks for anyone reading the
      README from the downloaded archive.  It links to the repository's copy
      over HTTPS instead
      (`raw.githubusercontent.com/Raskolny/europass-cv/main/thumbnail.png`),
      which renders on Universe *and* offline.  An earlier submission worked
      around the rule by committing a byte-identical `preview.png`; review asked
      for the duplicate to go, and it has.
      This development repo stays flat (no `template/`) until 1.1.0.
- [x] README CI badge points at the real repository
- [x] Regenerate `thumbnail.png` if the visual design changed:
      `typst compile --ignore-system-fonts --font-path fonts --format png --ppi 150 --pages 1 main.typ thumbnail.png`
      (done for the 1.1.0 section-spacing change; whenever the thumbnail moves,
      also regenerate `social-preview.png` via `social-preview.typ`).

## 1. GitHub first

1. Create the public repository `Raskolny/europass-cv`.
2. Push this tree (build outputs are gitignored; do not commit
   `output.pdf` or `examples/pdf/`).
3. Confirm the CI workflow is green on the default branch.
4. Tag the release: `git tag -a v1.0.0 -m "rasko-europass 1.0.0" && git push origin v1.0.0`.
   The Universe version **must** correspond to this tag.

## 2. Typst Universe second

1. Fork <https://github.com/typst/packages>.
2. Clone the fork sparsely and populate
   `packages/preview/rasko-europass/1.0.0/` **with `sync-universe.sh`** — do
   not copy by hand (hand-copying is how the bundle went stale in the first
   place):

   ```bash
   git clone --depth 1 --no-checkout --filter=tree:0 \
     git@github.com:Raskolny/packages.git
   cd packages
   git sparse-checkout init
   git sparse-checkout set packages/preview/rasko-europass
   git checkout rasko-europass-1.0.0

   cd /path/to/europass-cv
   ./sync-universe.sh /path/to/packages --check   # report drift, write nothing
   ./sync-universe.sh /path/to/packages           # apply
   ```

   The script holds the bundle to **two baselines at once**, because a
   submitted version is frozen while `main` carries unreleased work:

   - **FROZEN** — `lib.typ`, `lang.toml`, `LICENSE`, `NOTICE.md`,
     `thumbnail.png`, `assets/**` and `examples/*.typ` must equal the release
     tag `v<version>` verbatim.  Drift here is *reported, never auto-fixed*:
     overwriting a frozen file from the working tree would publish 1.1.0
     features under a 1.0.0 label.
   - **LIVE** — `README.md`, `CHANGELOG.md` (minus its `## [Unreleased]`
     section) and `template/main.typ` are synced from the working tree, since
     they are documentation written to stay correct across versions.
     `template/main.typ` is additionally guarded: the sync refuses to write it
     unless it differs from the tag in `//` comments only.
   - **NEVER** — `fonts/`, the build/verify/sync scripts, `.github/`,
     `social-preview.*`, `output.pdf`, `examples/pdf/`, `.gitignore`,
     `.pkgcache/`, `.devin/`, `PUBLISHING.md`, `CONTRIBUTING.md`, `ROADMAP.md`
     and `preview.png` must be absent (`tips.md`, *What to commit? What to
     exclude?*).  Do **not** exclude `README.md` or `LICENSE`.
   - **MANUAL** — `typst.toml` is never written, because the submission
     declares a `[template]` table this development manifest deliberately lacks.
     Its shared `[package]` fields are compared and any mismatch is reported.

   The submission is a **template package**: `main.typ` lives at
   `template/main.typ` and the manifest declares

   ```toml
   [template]
   path = "template"
   entrypoint = "main.typ"
   thumbnail = "thumbnail.png"
   ```

   Then verify it the way `manifest.md` recommends, before pushing:

   ```bash
   F=/path/to/packages          # the fork
   R=/path/to/europass-cv       # this repo
   typst init @preview/rasko-europass:1.0.0 /tmp/t --package-path "$F/packages"
   cd /tmp/t
   typst compile --package-path "$F/packages" --pdf-standard 1.7,ua-1 \
     --font-path "$R/fonts" main.typ
   "$R/verify.sh" /tmp/t/main.pdf      # -> ALL CHECKS PASSED
   ```
3. Ensure the folder name matches `{name}/{version}` and that `typst.toml`'s
   `name`/`version` agree.
4. Open the submission PR against `typst/packages`, referencing the
   `v1.0.0` tag of `Raskolny/europass-cv`.
5. Reviewers will check: licence (MIT) and the licence of the repository-vendored
   fonts (Apache-2.0, documented in `fonts/README.md` and `NOTICE.md`; the font
   binaries themselves are excluded from the bundle), the thumbnail, the README
   `@preview` usage snippet, and that the compiler floor (`0.15.0`) is correct.

## 3. Web-only polish (GitHub UI; no API exists for these)

- **Topics** (already applied via `PUT /repos/{owner}/{repo}/topics`):
  `typst, typst-template, typst-package, cv, resume, curriculum-vitae, europass,
  pdf-ua, accessibility, i18n`.
- **Social preview**: GitHub has no REST endpoint for the Open-Graph preview
  image, so it must be uploaded in the UI:
  *Settings → Social preview → upload `social-preview.png`* (1280×640, <1 MB).
  The card is generated reproducibly by `social-preview.typ` (compile command
  in its header).  Do not upload `thumbnail.png` itself: it is A4 portrait and
  would crop badly in the 2:1 slot.

## 4. After publication

- Future releases: bump `version` in `typst.toml` per SemVer, add a
  `CHANGELOG.md` entry, tag `vX.Y.Z`, then submit the new version folder.
  Never edit an already-published version.
- The README already imports `@preview/rasko-europass:1.0.0`; bump that snippet
  only when a new major is released.
