# Roadmap

How to read this file:

- **`1.0.0` is frozen.** It is submitted to Typst Universe as
  [typst/packages#5905](https://github.com/typst/packages/pull/5905).  Universe
  versions are immutable, so every later release is a **new version folder and
  a new PR**; a published version is never edited.
- **`1.x` stays additive.** Anything breaking is `2.0.0` territory.
- **Anything that touches the "faithful Europass reproduction" claim goes
  through a public discussion first**, not a quiet commit.  Open consultations
  are linked below.
- GitHub **milestones** (`1.1.0`, `1.2.0`, `1.3.0`) mirror this file; this file
  is the prose, the milestones are the tracker.

---

## 1.0.0 — submitted, awaiting review

Frozen.  No further work; see the tag `v1.0.0`.

## 1.1.0 — localisation & per-country conventions (Modification A)

Consultation: [discussion #3](https://github.com/Raskolny/europass-cv/discussions/3).

- [x] Align each `examples/<code>.typ` to its country's CV conventions, with a
      header comment stating the (unverified) convention and pointing at #3.
      Uses the documented-as-improper simplification *country == language*.
- [ ] `country:` parameter, separate from `lang:`, supplying a policy profile
      that sets **defaults** (declaration/signature off, DOB/gender/photo
      omitted) which explicit user parameters always override.  Removes the
      country/language conflation.
- [ ] README section documenting the country profiles, with an explicit
      "verify your jurisdiction" note — conventions, not legal advice.
- [x] Housekeeping: regenerate `thumbnail.png` (was stale since the
      section-spacing change); fix the contradictory "fonts ship with the
      package" comment in `typst.toml` (they are in `exclude`).
- [ ] Adopt the submission's **template structure** in this repo: move
      `main.typ` to `template/main.typ`, declare `[template]` in `typst.toml`
      (done in typst/packages#5905; `build.sh`, CI and the README layout
      section must follow).
- Pending [discussion #2](https://github.com/Raskolny/europass-cv/discussions/2):
  `extra-fields:` and `cv-section(..)`.

## 1.2.0 — data layer & machine-readable Europass (Modification B, part 1)

- [ ] Introduce an internal **data model**; the current parameter API becomes a
      facade over it, keeping `1.x` non-breaking.  `.typ` and `.pdf` become
      projections of the data.
- [ ] **Structured dates** (enables locale-correct date formats, e.g. French
      month names in words); free-text dates remain accepted.
- [ ] **B1:** emit a Europass / ELM-subset **XML sidecar** next to the PDF.
      Scope limited to the subset the Europass CV actually serialises — *not*
      the full 480-property ELM ontology.
- [ ] CI: a **data-level i18n assertion** (every language provides all required
      `lang.toml` keys), compensating for examples no longer rendering every
      feature once conventions omit some.

## 1.3.0 — Interactive CV: XML embedded in the PDF (Modification B, part 2)

- [ ] **B2:** embed the XML in the PDF via `pdf.attach` (verified working on
      Typst 0.15: output carries `/EmbeddedFiles`).
- [ ] Decide the **`/AF` (Associated Files) + PDF/A-3** stance: Typst emits
      `/EmbeddedFiles` but not `/AF`; true Interactive-CV parity may need a
      `build.sh` post-process (pikepdf/qpdf) or accepting `/EmbeddedFiles` only.
- [ ] Verify what Europass tooling actually reads before committing to a format.
- Carry-over: richer PDF metadata (`keywords` / `description`, optionally
  outlining H3 entry titles for nested bookmarks).

---

## Explicitly out of scope / deferred

- Interleaving custom sections *between* built-in sections — breaking API
  change, therefore `2.0.0` (discussion #2, Q3).
- The full ELM ontology (480+ properties) — only the Europass-CV subset.

## Process

Each release: bump `typst.toml` version per SemVer, add a `CHANGELOG.md` entry,
tag `vX.Y.Z`, open a new Universe PR referencing the tag.  Never edit a
published version.
