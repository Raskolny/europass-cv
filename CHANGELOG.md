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

- **`research/europass-candidate-format.md`** — an engineering reference for the
  interchange format behind the `1.2.0` / `1.3.0` work: the `Candidate` root
  element and its namespaces, the 82-element inventory and its nesting, the
  `hr:DocumentID` identity constraint, how the payload travels inside the PDF
  (`/Names → /EmbeddedFiles`, with `/AF` observed in the newer artefact and no
  PDF/A-3 marking in either), the import endpoint and its 422/410 semantics, and
  a section-type-to-parameter map showing which official sections have no typed
  API here.  Deliberately descriptive rather than comparative, and deliberately
  free of personal data: no HAR, bundle, downloaded CV or extracted XML is
  committed, and `.gitignore` now blocks `*.har` and `research/*.xml`.
- **`sync-universe.sh` review hold** — while `.universe-review-pending` exists,
  the script still reports drift but refuses to write into the fork, so an
  in-flight `typst/packages` review cannot be silently invalidated by a further
  push to the PR branch.  `--force` overrides deliberately; deleting the marker
  lifts the hold.  Development on `main` is unaffected either way.
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
    so the Universe bundle stays small; all 24 examples reference it — active
    in the five signature-convention countries (`bg`, `el`, `hr`, `pl`, `ro`),
    kept as a commented-out instruction in the rest.

  Verified: `main.typ` (default rule path) and all 24 examples compile clean
  under `--pdf-standard 1.7,ua-1`, with the localised `/Alt` string present in
  every rendered PDF and the signature measured at 40 × 14 mm undistorted.

### Changed

- **Roadmap corrected against observed evidence.**  `1.2.0` no longer targets an
  *ELM subset*: the CV document model is `Candidate.xsd` in
  `http://www.europass.eu/1.0` built on HR-XML 3.0, while ELM belongs to the
  European Digital Credentials application profile.  The item also gains a
  cheaper test path (the importer accepts `.xml` directly, so a sidecar can be
  exercised without any PDF embedding), and records the constraint that a third
  party cannot mint `hr:DocumentID schemeAgencyName="EUROPASS"` — importable
  would not mean official.  In `1.3.0` the `/AF` question is **reopened** (the
  newer official export does carry it, so exact parity would need a
  pikepdf/qpdf post-process) while the PDF/A-3 half is closed (not observed in
  either artefact), and "verify what Europass tooling reads" is marked resolved.
- **`1.1.0` gained two documentation items** the research made necessary: name
  which of the four official templates this package reproduces, and add an
  explicit "what this is not" section to the README.  The `cv-section(..)` item
  now lists the nine official section types that have no typed parameter here,
  `publications` first because academic CVs for EU funding need it.

- **typstyle adopted as the declared formatter** for `.typ` sources, pinned in
  CI (`TYPSTYLE_VERSION`).  CI runs `typstyle --check` as a gate that *reports*
  but never rewrites, so no contributor is required to install anything.  The
  one-off canonicalisation of the 24 examples (previous entry's commit) was
  verified inert: all 25 rendered PDFs are pixel-, text- and outline-identical
  before and after.  typstyle 0.15.1 has no config file, so the pinned version
  plus its default flags (line width 80, indent 2) are the whole contract.
- **Section-title spacing** — each `H2` section heading now clears the section
  before it by `section-gap` (8pt), while its blue rule is pulled 3.4mm closer
  to the title so it reads as part of the heading.  The previously orphaned
  `section-gap` constant is wired up.  Both gaps are real content space
  (`v()`), not block margins, because Typst silently drops the top margin of
  the first element inside a grid cell; the title→rule spacer is therefore a
  deliberately negative `v()`.  Measured on the rendered PDF against `1.0.0`:
  previous-section→title 7.03→15.03pt, title→rule 11.56→3.92pt, rule→content
  unchanged.
- **Housekeeping / doc coherence** — `thumbnail.png` regenerated for the new
  spacing and `social-preview.png` regenerated from it through a new
  *versioned* generator, `social-preview.typ` (the card was previously composed
  ad hoc, so it could not be reproduced); `social-preview.typ` is excluded from
  the Universe bundle.  The `typst.toml` comment that claimed the vendored
  fonts "ship with the package" — contradicting their presence in `exclude` —
  is corrected.  README and CONTRIBUTING no longer claim every example carries
  the placeholder portrait: lean-CV countries omit it, keeping the parameter as
  a commented-out instruction.

- **Docs accuracy pass (pre-review)** — the README now documents Typst's
  cross-package image-path resolution (a bare `signature-image: "…png"`
  string resolves *inside the package*, so user files must be passed as bytes
  via `read(.., encoding: none)`; same for `photo:`), marks the signature
  feature as unreleased **1.1.0** (it is not part of the published
  `@preview/rasko-europass:1.0.0`), drops the unsourced Europass-market
  paragraph (README and `main.typ` header) and the "GDPR-conscious" wording on
  the `gender` parameter, and rewords the PDF/UA-1 claim as compile-time
  enforcement plus automated checks.  The `thumbnail` notes in `typst.toml`
  and `PUBLISHING.md` no longer claim the file is "picked up by convention"
  (a `thumbnail` key is only valid in a `[template]` table, which this package
  does not declare), and `social-preview.png` joins `social-preview.typ` in
  `exclude` as dev-only output.  The `description` is shortened per the
  manifest guidelines, and the Universe submission
  ([typst/packages#5905](https://github.com/typst/packages/pull/5905)) was
  updated in kind: it now declares a `[template]` table
  (`template/main.typ` + `thumbnail.png`), drops the dev-only
  `.gitignore`/`PUBLISHING.md`/`CONTRIBUTING.md` from the package folder and
  carries the same comment/prose fixes.  This development repo adopts the
  `template/` structure in 1.1.0 (see ROADMAP.md).

- **Universe review response** — addresses
  [@elegaanz's review](https://github.com/typst/packages/pull/5905#pullrequestreview-5288070478)
  of [typst/packages#5905](https://github.com/typst/packages/pull/5905), whose
  premise is that the bundled README must be read *from Typst Universe*, not
  from GitHub:
  - `typst init @preview/rasko-europass:1.0.0` is now the lead quick-start
    path; the repository route is renamed *From the repository* and gains
    `git clone` **and** archive-download instructions;
  - every reference to `build.sh`, `build-examples.sh`, `verify.sh`, `fonts/`,
    `examples/` and `social-preview.*` is gathered under an explicit
    **repository-only** call-out, so a package user is never told to run a
    script that is not in the bundle;
  - font installation becomes a prominent call-out at the top of the README
    (Universe packages cannot ship font binaries) rather than a note buried
    halfway down, and the `1.0.0` "Self-contained fonts" claim above is scoped
    to repository builds;
  - `examples/` gains direct GitHub links, since Universe renders only the
    README;
  - the duplicate `preview.png` banner is dropped in favour of an absolute link
    to the repository's `thumbnail.png`.  A template thumbnail is stripped from
    the archive automatically and *must not be referenced anywhere in the
    package* (`typst/packages` `docs/manifest.md`), so the banner cannot point
    at it relatively; an absolute URL renders on Universe **and** in an offline
    reading of the packaged README.

  The submitted bundle was also found to be **stale**: `lib.typ`, `lang.toml`,
  `typst.toml`, `README.md`, `CHANGELOG.md`, `thumbnail.png` and all 24
  `examples/*.typ` had drifted from `main` because the package lives in a fork
  of `typst/packages` and was copied across by hand.  It is resynchronised, and
  `sync-universe.sh` now performs the copy and reports drift so this cannot
  silently recur.

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
- **Hermetic repository builds**: the development repository vendors the
  complete Open Sans family in `fonts/` (Apache-2.0) and compiles with
  `--ignore-system-fonts`, so the rendered PDF embeds subsetted fonts and never
  falls back to local/Base-14 fonts.  Font binaries cannot ship inside a
  Universe package — package users install Open Sans themselves or pass `font:`
  (see the *Overridable typeface stack* entry below).
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
