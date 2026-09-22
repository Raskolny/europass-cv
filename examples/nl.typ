// Europass CV example — Dutch (nl).
// Persona of Nederlander nationality.  Demonstrates lang="nl" end to end.
// Conventions (discussion #3): Netherlands customarily omits photo, date of birth,
// gender and any signature/date at the foot (anti-discrimination practice and
// lean-CV custom).  Unverified convention - corrections welcome in #3.
#import "@preview/rasko-europass:1.0.0": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "nl",
  title: "Curriculum Vitae — Daan de Vries",
  author: "Daan de Vries",

  name: "Daan de Vries",
  address: "Example Street 1",
  city: "Amsterdam",
  phone: "+00 000 000 000",
  email: "nl@europass.example",
  nationality: "Nederlander",

  work-experience: (
    cv-entry(
      date-start: "2021",
      date-end: "",
      title: "Senior software-engineer",
      organization: "European Tech Solutions",
      location: "Amsterdam",
      description: [
        - Leidde een team van zes engineers voor cloud-native diensten.
      ],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013",
      date-end: "2015",
      title: "Master informatica",
      organization: "Universiteit van Amsterdam",
      location: "Amsterdam",
    ),
  ),

  mother-tongue: "Nederlands",
  other-languages: (
    (
      lang: "Engels",
      listening: "C1",
      reading: "C1",
      interaction: "B2",
      production: "B2",
      writing: "C1",
    ),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],
)
