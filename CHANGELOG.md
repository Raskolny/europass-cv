# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Nothing released since `1.0.0`.  That version is submitted to Typst Universe as
[typst/packages#5905](https://github.com/typst/packages/pull/5905) and is
**frozen** — no further changes go into it.  Everything below lands in `1.1.0`.

Work in progress lives on feature branches off `main`:

- `feat/signature-image` — optional `signature-image:` rendering an uploaded
  handwritten signature in place of the placeholder rule.  **Incomplete**: the
  commit message records the blocking issues (a missing `alt:` fails the
  PDF/UA-1 build; the example-asset strategy is undecided).

Planned, pending
[discussion #2](https://github.com/Raskolny/europass-cv/discussions/2):
`extra-fields:` for country-specific personal information, and an exported
`cv-section(..)` for user-defined trailing sections.

Also planned: section-title spacing, and richer PDF metadata (exposing
`keywords` / `description`, optionally outlining H3 entry titles for nested
bookmarks).

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
