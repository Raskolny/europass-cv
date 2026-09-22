// Europass CV example — Latvian (lv).
// Persona of Latviete nationality.  Demonstrates lang="lv" end to end.
// Conventions (discussion #3): Latvia customarily omits the signature/date block;
// photo and date of birth are kept, gender omitted.
// Unverified convention - corrections welcome in #3.
#import "@preview/rasko-europass:1.0.0": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "lv",
  title: "Curriculum Vitae — Līga Bērziņa",
  author: "Līga Bērziņa",

  name: "Līga Bērziņa",
  photo: "assets/photo-placeholder.svg",
  photo-alt: l("lv").at("photo-alt"),
  address: "Example Street 1",
  city: "Rīga",
  phone: "+00 000 000 000",
  email: "lv@europass.example",
  nationality: "Latviete",
  date-of-birth: "01/01/1990",

  work-experience: (
    cv-entry(
      date-start: "2021",
      date-end: "",
      title: "Vecākā programmatūras inženiere",
      organization: "European Tech Solutions",
      location: "Rīga",
      description: [
        - Vadīja sešu inženieru komandu cloud-native pakalpojumu izstrādē.
      ],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013",
      date-end: "2015",
      title: "Datorzinātņu maģistre",
      organization: "Latvijas Universitāte",
      location: "Rīga",
    ),
  ),

  mother-tongue: "Latviešu",
  other-languages: (
    (
      lang: "Angļu",
      listening: "C1",
      reading: "C1",
      interaction: "B2",
      production: "B2",
      writing: "C1",
    ),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],
)
