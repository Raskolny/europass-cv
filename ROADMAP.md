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
- **Findings about the official platform live in**
  [`research/europass-candidate-format.md`](research/europass-candidate-format.md).
  That file is the engineering reference for the `1.2.0`/`1.3.0` work below:
  wherever this roadmap asserts a fact about the official format, the evidence
  and the method are recorded there.

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
- [ ] **Scope the "faithful reproduction" claim precisely.**  The official
      editor offers four CV templates (`one`, `two`, `legacy-two`,
      `legacy-four`) plus colour, font-size, logo and page-number options, and
      serialises those choices in a `RenderingInformation` block.  The README
      should say which layout this package reproduces instead of implying there
      is only one.
- [ ] **Add an explicit "what this is not" section to the README.**  This
      package typesets a CV in the Europass layout; it is not the Europass
      platform, it cannot mint an official document identifier, and until
      `1.2.0` it emits no machine-readable output.  Stating the limits plainly
      is what makes the rest of the README worth trusting.
- Pending [discussion #2](https://github.com/Raskolny/europass-cv/discussions/2):
  `extra-fields:` and `cv-section(..)`.  Relevant new information: the official
  data model carries several section types this package has no typed API for —
  publications, projects, certifications, conferences and seminars, honours and
  awards, creative works, networks and memberships, voluntary work and
  recommendations.  A generic `cv-section(..)` would cover all of them at once.
  `publications` is the one most likely to be missed first, since academic CVs
  for EU funding need it.

## 1.2.0 — data layer & machine-readable Europass (Modification B, part 1)

- [ ] Introduce an internal **data model**; the current parameter API becomes a
      facade over it, keeping `1.x` non-breaking.  `.typ` and `.pdf` become
      projections of the data.
- [ ] **Structured dates** (enables locale-correct date formats, e.g. French
      month names in words); free-text dates remain accepted.
- [ ] **B1:** emit a **`Candidate` XML sidecar** next to the PDF — namespace
      `http://www.europass.eu/1.0`, schema `Candidate.xsd`, built on HR-XML 3.0
      (`http://www.hr-xml.org/3`) with OAGIS and EURES namespaces.
      **Not an ELM subset.**  ELM is the data model behind European Digital
      Credentials, which is a different application profile from the CV; this
      item was written on the assumption that the CV serialised ELM, and that
      assumption was wrong.  Element inventory and structure are recorded in
      [`research/europass-candidate-format.md`](research/europass-candidate-format.md).
      Note that the schema is not retrievable from its declared location, so the
      target is defined by observed samples rather than by validation.
- [ ] **B1 test path — do this first.**  The portal's importer accepts `.xml` as
      well as `.pdf`, so a hand-written sidecar can be exercised by uploading it
      directly.  That answers "is the shape right?" without writing any PDF
      embedding code, and without committing to a generator that may be wrong.
- [ ] **B1 constraint — importable is not official.**  A third party cannot mint
      `hr:DocumentID schemeAgencyName="EUROPASS"`; that identifier comes from
      the platform.  Whatever this package emits is therefore a
      candidate-shaped document whose acceptance is undocumented and may change
      at any time.  If it works, describe it as best-effort and unofficial, and
      never as producing an official Europass CV.
- [ ] **Decide the stance on round-tripping.**  Importing a CV means uploading
      personal data to the portal.  That is a legitimate user choice, but it
      must be an explicit and documented one, and never the default behaviour of
      any helper script in this repository.
- [ ] CI: a **data-level i18n assertion** (every language provides all required
      `lang.toml` keys), compensating for examples no longer rendering every
      feature once conventions omit some.

## 1.3.0 — Interactive CV: XML embedded in the PDF (Modification B, part 2)

- [ ] **B2:** embed the XML in the PDF via `pdf.attach` (verified working on
      Typst 0.15: output carries `/EmbeddedFiles`).
- [ ] Decide the **`/AF` (Associated Files) + PDF/A-3** stance.  *Reopened with
      new evidence:* the current official export **does** carry `/AF`, alongside
      the `/Names → /EmbeddedFiles` name tree, whereas an older export carried
      the name tree alone.  Typst emits `/EmbeddedFiles` but not `/AF`, so exact
      parity with the current format would need a `build.sh` post-process
      (pikepdf/qpdf).  **No PDF/A-3 marking was observed in either**, so that
      half of the question is closed.  Whether `/AF` matters for import is
      testable cheaply via the B1 test path above; if it does not, prefer
      accepting `/EmbeddedFiles` alone over taking on a post-processing
      dependency.
- [x] Verify what Europass tooling actually reads before committing to a format.
      **Resolved:** `Candidate` in `http://www.europass.eu/1.0` on HR-XML 3.0 —
      not ELM.  The importer answers HTTP 422 when a file carries no Europass
      payload and HTTP 410 when the payload is an older version of one, which is
      also why a PDF without embedded XML is rejected.  Evidence and method in
      `research/europass-candidate-format.md`.
- Carry-over: richer PDF metadata (`keywords` / `description`, optionally
  outlining H3 entry titles for nested bookmarks).

---

## Explicitly out of scope / deferred

- Interleaving custom sections *between* built-in sections — breaking API
  change, therefore `2.0.0` (discussion #2, Q3).
- The full ELM ontology (480+ properties).  Moot for the CV in any case: ELM is
  not the CV's data model, and `1.2.0` targets `Candidate.xsd` instead.
- Any claim of producing **official** Europass documents.  Official status
  rests on a platform-minted `hr:DocumentID` that a third-party template cannot
  generate.

## Process

Each release: bump `typst.toml` version per SemVer, add a `CHANGELOG.md` entry,
tag `vX.Y.Z`, open a new Universe PR referencing the tag.  Never edit a
published version.
