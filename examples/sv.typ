// Europass CV example — Swedish (sv).
// Persona of Svensk nationality.  Demonstrates lang="sv" end to end.
// Conventions (discussion #3): Sweden customarily omits photo, date of birth,
// gender and any signature/date at the foot (anti-discrimination practice and
// lean-CV custom).  Unverified convention - corrections welcome in #3.
#import "@preview/rasko-europass:1.0.0": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "sv",
  title: "Curriculum Vitae — Elsa Andersson",
  author: "Elsa Andersson",

  name: "Elsa Andersson",
  address: "Example Street 1",
  city: "Stockholm",
  phone: "+00 000 000 000",
  email: "sv@europass.example",
  nationality: "Svensk",

  work-experience: (
    cv-entry(
      date-start: "2021",
      date-end: "",
      title: "Senior mjukvaruingenjör",
      organization: "European Tech Solutions",
      location: "Stockholm",
      description: [
        - Ledde ett team på sex ingenjörer inom cloud-native-tjänster.
      ],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013",
      date-end: "2015",
      title: "Civilingenjör i datateknik",
      organization: "KTH",
      location: "Stockholm",
    ),
  ),

  mother-tongue: "Svenska",
  other-languages: (
    (
      lang: "Engelska",
      listening: "C1",
      reading: "C1",
      interaction: "B2",
      production: "B2",
      writing: "C1",
    ),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],
)
