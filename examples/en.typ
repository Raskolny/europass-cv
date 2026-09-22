// Europass CV example — English (en).
// Persona of Irish nationality.  Demonstrates lang="en" end to end.
// Conventions (discussion #3): Ireland customarily omits photo, date of birth,
// gender and any signature/date at the foot (anti-discrimination practice and
// lean-CV custom).  Unverified convention - corrections welcome in #3.
#import "@preview/rasko-europass:1.0.0": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "en",
  title: "Curriculum Vitae — Aoife Murphy",
  author: "Aoife Murphy",

  name: "Aoife Murphy",
  address: "Example Street 1",
  city: "Dublin",
  phone: "+00 000 000 000",
  email: "en@europass.example",
  nationality: "Irish",

  work-experience: (
    cv-entry(
      date-start: "2021",
      date-end: "",
      title: "Senior Software Engineer",
      organization: "European Tech Solutions",
      location: "Dublin",
      description: [- Led a team of six engineers on cloud-native services.],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013",
      date-end: "2015",
      title: "MSc in Computer Science",
      organization: "Trinity College Dublin",
      location: "Dublin",
    ),
  ),

  mother-tongue: "English",
  other-languages: (
    (
      lang: "French",
      listening: "C1",
      reading: "C1",
      interaction: "B2",
      production: "B2",
      writing: "C1",
    ),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],
)
