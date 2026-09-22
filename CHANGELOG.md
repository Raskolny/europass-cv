# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Nothing released since `1.0.0`.  That version is submitted to Typst Universe as
[typst/packages#5905](https://github.com/typst/packages/pull/5905) and is
**frozen** — no further changes go into it.  Everything below lands in `1.1.0`.

Development for `1.1.0` happens directly on `main`; the submitted `1.0.0` stays
reachable through the immutable `v1.0.0` tag.

### Added

- **Optional handwritten signature** — `signature-image:` renders an uploaded
  signature in place of the paper-signing rule, which stays the `none` default.
  Closes the `feat/signature-image` WIP by resolving every issue its commit
  message recorded as blocking:
  - new `signature-alt:` parameter, localised for **all 24 languages** via a new
    `signature-alt` key in `lang.toml` (mirrors the existing `photo-alt`
    pattern), so the image is tagged and the PDF/UA-1 build passes;
  - the image is fitted to a **40 mm × 16 mm** box with `fit: "contain"`,
    preserving the aspect ratio and preventing a tall scan from overflowing the
    55 mm block;
  - asset strategy settled on **one shared vector**,
    `assets/signature-sample.svg` (1.4 KB), matching the existing
    `assets/photo-placeholder.svg` pattern instead of 24 per-example rasters,
    so the Universe bundle stays small; all 24 examples now exercise it.

  Verified: `main.typ` (default rule path) and all 24 examples compile clean
  under `--pdf-standard 1.7,ua-1`, with the localised `/Alt` string present in
  every rendered PDF and the signature measured at 40 × 14 mm undistorted.

### Changed

- **typstyle adopted as the declared formatter** for `.typ` sources, pinned in
  CI (`TYPSTYLE_VERSION`).  CI runs `typstyle --check` as a gate that *reports*
  but never rewrites, so no contributor is required to install anything.  The
  one-off canonicalisation of the 24 examples (previous entry's commit) was
  verified inert: all 25 rendered PDFs are pixel-, text- and outline-identical
  before and after.  typstyle 0.15.1 has no config file, so the pinned version
  plus its default flags (line width 80, indent 2) are the whole contract.
- **Section-title spacing** — each `H2` section heading now clears the section
  before it by `section-gap + 3.4mm`, while its blue rule is pulled 3.4mm
  closer to the title, so the rule reads as part of the heading and the
  heading reads as the start of a new block.  The previously orphaned
  `section-gap` constant is wired up.  Both gaps are real content space
  (`v()`), not block margins, because Typst silently drops the top margin of
  the first element inside a grid cell.  Measured on the rendered PDF against
  `1.0.0`: previous-section→title 7.03→24.67pt, title→rule 11.56→3.92pt,
  rule→content unchanged.

### Planned

Pending
[discussion #2](https://github.com/Raskolny/europass-cv/discussions/2):
`extra-fields:` for country-specific personal information, and an exported
`cv-section(..)` for user-defined trailing sections.

Also planned: richer PDF metadata (exposing `keywords` / `description`,
optionally outlining H3 entry titles for nested bookmarks).

## [1.0.0] — initial release

### Added

- **Faithful Europass layout**: asymmetric two-column grid (~25 % dates /
  ~75 % content) with the iconic unbroken vertical blue rule, official EU
  palette (`#164194`, `#575756`, `#F2F2F2`) and Open Sans typography.
- **Public API**: `europass-cv(..)`, `cv-entry(..)`, `language-grid(..)`,
  `skill-row(..)` — end users only fill fields in `main.typ`.
- **Full i18n for all 24 official EU languages** in a single translator-friendly
  `lang.toml` data file (section headers, personal-info labels, CEFR grid
  labels, A1–C2 descriptors, gender values, image alt-text, GDPR clause).
- **CEFR language self-assessment table** with contrast-safe (WCAG AA) shading
  and levels always emitted as real text.
- **Inclusive, omittable gender field**: `male` / `female` / `other`
  (non-binary, "X", *divers*) / `undeclared` (prefer not to say), free text, or
  omitted entirely — all localised.
- **GDPR / DPR 445 self-declaration** clause, localised per language.
- **Accessibility (PDF/UA-1)**: semantic `H1/H2/H3` headings producing a real
  document outline; presentational layout tagged as `Div` (never a bogus data
  table); CEFR grid tagged `Table/THead/TH/TD`; lists, links and alt text
  tagged; document title/author/language metadata set.
- **Self-contained fonts**: complete Open Sans family vendored in `fonts/`
  (Apache-2.0); builds run with `--ignore-system-fonts` so the rendered PDF
  embeds subsetted fonts and never falls back to local/Base-14 fonts.
- **Verification tooling**: `build.sh` (hermetic PDF/UA-1 build) and
  `verify.sh` (asserts font embedding, no Base-14 fallback, PDF/UA markers,
  outline and tag tree).
- **24 language examples** (`examples/<code>.typ`), one per language and
  nationality, compiled by `build-examples.sh`; each uses the anonymous,
  gender-neutral placeholder portrait `assets/photo-placeholder.svg`.
- **CI** (`.github/workflows/ci.yml`) running the hermetic build plus the
  accessibility and font-embedding verification on every push and PR.
- **Overridable typeface stack**: a `font:` parameter (default Open Sans),
  because Typst Universe policy forbids bundling font binaries in a package;
  the vendored `fonts/` directory serves repository builds only.
- **Package-spec imports**: `main.typ` and all examples import the package via
  `@preview/rasko-europass:1.0.0` (resolved in-repo through a local package
  cache), matching how end users consume it from Typst Universe.
