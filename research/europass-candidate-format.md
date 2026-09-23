# The Europass `Candidate` document — engineering reference

Reference material for the `1.2.0` (XML sidecar) and `1.3.0` (XML embedded in
the PDF) roadmap items.  Everything here is an **observed fact about a data
format**, recorded so the work can be done without re-deriving it, and so any
claim in `ROADMAP.md` about the official format can be checked.

This file is deliberately descriptive.  It is not a comparison with this
package, and nothing in it should be read as one.  This project typesets CVs;
understanding the interchange format is simply what makes an optional
round-trip feature possible.

---

## 1. Method

Four sources, all of them things a member of the public can reach:

1. **A CV downloaded from the official editor** — the PDF carries its own data
   payload as an embedded file, so the document format is readable directly out
   of the artefact.  Two downloads were examined, taken some time apart; where
   they differ, both observations are recorded.
2. **The editor's client-side bundles.**  The editor is an Angular single-page
   application, so its interface strings are served to any browser as JSON.
   They were captured with a browser HAR export and reduced to script and JSON
   bodies only.  This is where the accepted file types, the import endpoint and
   its error semantics come from.
3. **The published Europass privacy statement** (PDF, linked from
   `europass.europa.eu`).  Cited in §7 only for the round-trip decision.
4. **`typst/packages` documentation and bundler source** — used for the
   packaging rules, not for anything Europass-specific.

Nothing here required authentication bypass, and no private API was probed
beyond what the public editor calls on its own.

**What is deliberately not stored.**  No HAR file, no extracted bundle, no
downloaded CV and no XML payload is committed to this repository.  A HAR
contains session cookies and auth tokens; a downloaded CV and its XML contain
real personal data.  `.gitignore` blocks `*.har` and `research/*.xml`, and
`*.pdf` is already blocked globally.  Only the structural observations below are
kept.

---

## 2. The `Candidate` document

The payload is an XML document named **`attachment.xml`**, carried inside the
downloaded PDF (see §4).  Its root element and namespaces:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Candidate
    xsi:schemaLocation="http://www.europass.eu/1.0 Candidate.xsd"
    xmlns="http://www.europass.eu/1.0"
    xmlns:oa="http://www.openapplications.org/oagis/9"
    xmlns:eures="http://www.europass_eures.eu/1.0"
    xmlns:hr="http://www.hr-xml.org/3"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
```

Key points:

- The document model is **HR-XML 3.0** (`http://www.hr-xml.org/3`) with OAGIS
  and EURES vocabularies layered on.  It is **not** ELM.  ELM — the European
  Learning Model, ~480 properties — is the model behind European Digital
  Credentials for Learning, which is a separate application profile from the CV.
  `ROADMAP.md` originally assumed an ELM subset for `1.2.0`; that was incorrect
  and has been corrected.
- The declared schema location is **not retrievable**.  Fetching
  `http://www.europass.eu/1.0/Candidate.xsd` returns a `308` whose `Location`
  header is malformed (`https://europass.europa.eu1.0/Candidate.xsd` — the path
  separator is missing), so the request does not resolve to a schema.  Practical
  consequence: the target format has to be defined from observed samples, and
  schema validation is not available to us or to a downstream consumer.

### 2.1 Document identity

Two identifiers appear at the top of the document:

```xml
<hr:DocumentID schemeID="…" schemeName="DocumentIdentifier"
               schemeAgencyName="EUROPASS" schemeVersionID="4.0"/>
<CandidateSupplier>
  <hr:PartyID schemeID="…" schemeName="PartyID"
              schemeAgencyName="EUROPASS" schemeVersionID="1.0"/>
```

`schemeAgencyName="EUROPASS"` is what marks a document as issued through the
platform.  A third-party generator cannot legitimately mint it, which is why
`ROADMAP.md` records that anything this package emits would be
*candidate-shaped* rather than official.

### 2.2 Element inventory

82 distinct element names were observed in a populated sample.  Counts vary with
content; the names are what matter for an emitter.

```text
Candidate · DocumentID · CandidateSupplier · PartyID · PartyName ·
PersonContact · PersonName · GivenName · FamilyName · PrecedenceCode ·
CandidatePerson · Communication · UseCode · Address · CountryCode ·
NationalityCode · BirthDate · PrimaryLanguageCode · CandidateProfile · ID ·
EmploymentHistory · EmployerHistory · OrganizationName · OrganizationContact ·
PositionHistory · PositionTitle · EmploymentPeriod · StartDate · EndDate ·
FormattedDateTime · CurrentIndicator · Description · City · CityName · Country ·
EducationHistory · EducationOrganizationAttendance · DegreeName ·
EducationLevelCode · AttendancePeriod · NumberOfCredit · CreditType ·
NationalClassification · OccupationalSkillsCovered · PersonQualifications ·
Skills · SkillsGroup · PersonCompetency · CompetencyID · CompetencyName ·
TaxonomyID · CompetencyDimension · CompetencyDimensionTypeCode · Score ·
ScoreText · Certifications · CourseCertifications · Licenses · CreativeWorks ·
ConferencesAndSeminars · NetworksAndMemberships · Projects · PublicationHistory ·
SocialAndPoliticalActivities · VoluntaryWorks · EmploymentReferences ·
HonourAward-equivalents via Section/Title · ClosingStatement · Statement ·
Date · Place · RenderingInformation · Design · Template · Color · FontSize ·
Logo · PageNumbers · SectionsOrder · Section · Title · Ongoing
```

Observed nesting, abbreviated to the first few levels:

```text
Candidate
├─ DocumentID
├─ CandidateSupplier
│  ├─ PartyID · PartyName · PrecedenceCode
│  └─ PersonContact › PersonName › GivenName · FamilyName
├─ CandidatePerson
│  ├─ PersonName › GivenName · FamilyName
│  ├─ Communication › UseCode · Address › CountryCode
│  └─ NationalityCode · BirthDate · PrimaryLanguageCode
└─ CandidateProfile
   ├─ ID
   ├─ EmploymentHistory › EmployerHistory
   │    ├─ OrganizationName
   │    ├─ OrganizationContact › Communication › Address › CityName · CountryCode
   │    └─ PositionHistory › PositionTitle · EmploymentPeriod ›
   │         StartDate/EndDate › FormattedDateTime · CurrentIndicator ·
   │         Description · City · Country
   ├─ EducationHistory › EducationOrganizationAttendance › …
   ├─ Skills › SkillsGroup › PersonCompetency › …
   ├─ PersonQualifications › EducationDegree › …
   ├─ Certifications · CourseCertifications · Licenses · Projects
   ├─ PublicationHistory · CreativeWorks · ConferencesAndSeminars
   ├─ NetworksAndMemberships · SocialAndPoliticalActivities · VoluntaryWorks
   ├─ EmploymentReferences
   ├─ ClosingStatement › Statement · Date · Place
   └─ RenderingInformation
```

### 2.3 `RenderingInformation`

Presentation choices are serialised alongside content:

```xml
<RenderingInformation>
  <Design>
    <Template>Template1</Template>
    <Color>…</Color>
    <FontSize>…</FontSize>
    <Logo>None</Logo>
    <PageNumbers>false</PageNumbers>
    <SectionsOrder>
      <Section><Title>education-training</Title></Section>
      <Section><Title>work-experience</Title></Section>
      …
    </SectionsOrder>
  </Design>
</RenderingInformation>
```

Two things follow.  First, the editor offers several layouts and themes — four
template identifiers are visible in its interface strings (`one`, `two`,
`legacy-two`, `legacy-four`) — so "the Europass layout" is not a single thing,
which is why `ROADMAP.md` `1.1.0` asks the README to name the one reproduced
here.  Second, an emitter has to decide what to put in this block; the safest
choice is whatever values correspond to the layout this package produces.

### 2.4 Section types, mapped to this package's API

| Section in the data model | Typed parameter here |
| --- | --- |
| `EmploymentHistory` | `work-experience` (`cv-entry`) |
| `EducationHistory` / `PersonQualifications` | `education` (`cv-entry`) |
| `Skills` (incl. CEFR self-assessment) | `mother-tongue`, `other-languages`, `language-grid`, `skill-row`, the `*-skills` parameters |
| `Licenses` | `driving-licence` |
| `ClosingStatement` | `declaration`, `signature-place`, `signature-date`, `signature-image` |
| `PublicationHistory` | — |
| `Projects` | — |
| `Certifications` / `CourseCertifications` | — |
| `ConferencesAndSeminars` | — |
| `CreativeWorks` | — |
| `NetworksAndMemberships` | — |
| `SocialAndPoliticalActivities` | — |
| `VoluntaryWorks` | — |
| `EmploymentReferences` | — |

The gaps are reachable today by writing free Typst below the `#show:` rule,
which appends an extra section; there is simply no typed parameter for them.
This table is the evidence behind the `cv-section(..)` item in
[discussion #2](https://github.com/Raskolny/europass-cv/discussions/2) — one
generic constructor would cover every row marked "—".

---

## 3. Languages

The editor's own locale list for CV creation covers **30 languages**:

```text
bg cs da de el en es et fi fr ga hr hu is it lt lv me mk mt nl no pl pt ro sk sl sv tr uk
```

That is the 24 official EU languages — the set this package covers — plus
`is`, `no`, `tr`, `mk`, `me` and `uk`.  The site's interface offers one more
(`sr`) than the CV page links to, so "31 in the UI, 30 for the CV" is the
accurate statement.  Worth recording because an earlier draft of this project's
positioning quoted "32", which is not what the locale list shows.

---

## 4. How the XML travels inside the PDF

The payload is a genuine PDF embedded file, reachable from the document
catalog:

```text
/Type /Catalog
  /Names → << /EmbeddedFiles → << /Names [ <…attachment.xml>  N 0 R ] >> >>
  /AF    → [ N 0 R ]        ← present in the newer download, absent in the older
```

Observed differences between the two downloads examined:

| | older download | newer download |
| --- | --- | --- |
| `/Names → /EmbeddedFiles` name tree | present | present |
| embedded file name | `attachment.xml` | `attachment.xml` |
| `/AF` (Associated Files) | absent | present |
| PDF/A-3 identification | not present | not present |
| XML root, namespaces, `DocumentID` | as §2 | identical |

So the *document model* is stable across both, and only the container differs.
For `1.3.0` this matters in one specific way: Typst's `pdf.attach` emits
`/EmbeddedFiles` but not `/AF`, and the newer artefact does carry `/AF`.  No
PDF/A-3 marking was seen in either, so that part of the old roadmap question is
settled — `/AF` is the only open item, and whether it is actually required is
cheap to test (§5).

---

## 5. The import path

Facts taken from the editor's client-side bundles.

- **Endpoint:** `api/eprofile/europass-cv`.
- **Accepted types include `.pdf` and `.xml`.**  This is the single most useful
  item here: a sidecar can be tested by uploading the bare XML, with no PDF
  embedding involved.  `ROADMAP.md` `1.2.0` makes that the first step.
- **Error semantics** (from the client's `handlePdfError`):
  - **HTTP 422** → *"This CV is not a Europass compliant."* — no Europass
    payload found in the upload.
  - **HTTP 410** → *"The document you have uploaded contains an old format of
    the Europass documents. Unfortunately, Europass does not support these
    documents anymore."*
  - Success → *"Your file … has been successfully imported. Please, review your
    data."*  A partial parse yields a separate "some information are not
    correct" message.
- **What this tells us about the mechanism.**  The two distinct failures are
  informative: the service can tell "no Europass payload" apart from "Europass
  payload of an older version", which it could only do by reading a versioned
  payload inside the file.  Import is therefore a matter of carrying the right
  XML, not of proving where the PDF came from.  A related string — *"The
  language of the imported document is not supported"* — is consistent with
  `PrimaryLanguageCode` being read from the XML rather than from PDF metadata.
- **Partner imports are separate** and gated server-side: the client fetches
  `/eprofile/partner-switches/import` and `/eprofile/partner-switches/export`
  to decide which partner buttons to show.  Only EURES is named in the strings.
  Adding a partner is a platform-side decision, not something a third-party
  generator can enable.

**Caution.**  These are undocumented internals of a service that can change
without notice.  Anything built against them is best-effort, must be described
as unofficial, and should degrade quietly rather than promise a round trip.

---

## 6. Interface facts worth recording

From the editor's interface strings (10,617 keys), where they bear on the
roadmap:

- **Export formats offered:** PDF, Word and XML.
- **Gender field** offers five values: `male`, `female`, `other`,
  `do_not_indicate`, `not_specified`.  The internal key is `sex`; the label
  shown is "Gender".
- **Signature upload** is supported for both the CV and the cover letter, with a
  size limit.
- **Custom sections** are supported, with title, content, from/to dates, an
  "ongoing" flag and a link to a file or video.
- **Per-field export selection** exists: the export dialog lets a user include
  or omit date of birth, picture, sex, addresses, nationalities and so on
  individually.
- **No country-driven behaviour was found.**  Searching all 10,617 keys for
  `convention`, `country-specific`, `national format` and `local format` returns
  nothing.  This is the evidence behind the per-country-conventions work in
  `1.1.0`: the defaults this package applies per country are its own opinion,
  not a restatement of platform behaviour.  Absence of strings is not proof of
  absence of logic, but it is the only signal available from outside.
- **Application modules**, by translation-key count, give a sense of the
  platform's scope: `job-opportunities` 1,705, `profile` 856,
  `simplified-profile-wizard` 703, `compact-cv-editor` 651, `courses` 342,
  `application-tracker` 234, `my-library` 162, `skills-intelligence` 103,
  `profile-exporting` 102, and 47 more.  The CV editor is one module among many
  in a labour-market platform.  This is the reason `1.1.0` asks the README for an
  explicit "what this is not" section.

---

## 7. Round-tripping and personal data

Uploading a CV to the portal places personal data in a registered profile.  The
published privacy statement (DG EMPL, record reference `DPR-EC-04686.3`) states
that profile data is kept **for five years after the last login**, and lists
among the categories collected: identity documents, residence and work permits,
date and place of birth, nationality, CVs, cover letters, applications, and user
interaction data including consulted job vacancies and search queries.  It also
describes using profile data and platform activity to suggest jobs and courses,
with an opt-out.

None of that is a criticism — it is a documented, lawful, opt-outable service
that offers genuine value in exchange.  It is recorded here for one narrow
engineering reason: **`1.2.0` must not make round-tripping a default.**  If a
sidecar is emitted, uploading it stays a manual, informed, user-initiated act,
and no script in this repository should do it or suggest doing it silently.

---

## 8. Re-verifying any of this

The format facts can be re-checked from a single downloaded CV, without any of
the tooling used here:

```bash
# what is embedded, and how
pdfinfo your-europass-cv.pdf
python3 - <<'PY'
import pymupdf
d = pymupdf.open("your-europass-cv.pdf")
print(d.xref_object(d.pdf_catalog()))
for i in range(d.embfile_count()):
    print(d.embfile_info(i))
    open("attachment.xml", "wb").write(d.embfile_get(i))
PY

# the document model
head -c 600 attachment.xml
python3 -c "import xml.etree.ElementTree as E; \
  print(len({e.tag.split('}')[-1] for e in E.parse('attachment.xml').iter()}))"
```

Keep the outputs out of version control: `attachment.xml` and the PDF are
personal data, and `.gitignore` already blocks both.
