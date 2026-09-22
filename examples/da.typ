// Europass CV example — Danish (da).
// Persona of Dansk nationality.  Demonstrates lang="da" end to end.
// Conventions (discussion #3): Denmark customarily omits photo, date of birth,
// gender and any signature/date at the foot (anti-discrimination practice and
// lean-CV custom).  Unverified convention - corrections welcome in #3.
#import "@preview/rasko-europass:1.0.0": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "da",
  title: "Curriculum Vitae — Mette Jensen",
  author: "Mette Jensen",

  name: "Mette Jensen",
  address: "Example Street 1",
  city: "København",
  phone: "+00 000 000 000",
  email: "da@europass.example",
  nationality: "Dansk",

  work-experience: (
    cv-entry(
      date-start: "2021",
      date-end: "",
      title: "Senior softwareingeniør",
      organization: "European Tech Solutions",
      location: "København",
      description: [
        - Ledede et team på seks ingeniører inden for cloud-native tjenester.
      ],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013",
      date-end: "2015",
      title: "Cand.it i datalogi",
      organization: "Københavns Universitet",
      location: "København",
    ),
  ),

  mother-tongue: "Dansk",
  other-languages: (
    (
      lang: "Engelsk",
      listening: "C1",
      reading: "C1",
      interaction: "B2",
      production: "B2",
      writing: "C1",
    ),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],
)
