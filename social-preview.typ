// ============================================================================
//  social-preview.typ — generator for the 1280x640 GitHub Open-Graph card
// ============================================================================
//  GitHub's social-preview slot is 1280x640 (2:1); the A4 thumbnail.png would
//  crop badly there, so this file composes a dedicated card: marketing copy on
//  the left, the rendered first page ("paper" with a drop shadow) on the right.
//
//  Regenerate with (page is 1280pt x 640pt and --ppi 72 makes 1pt == 1px):
//
//    typst compile --ignore-system-fonts --font-path fonts --format png \
//      --ppi 72 social-preview.typ social-preview.png
//
//  Kept out of the Universe bundle via typst.toml's `exclude`.
// ============================================================================

#set page(width: 1280pt, height: 640pt, margin: 0pt, fill: rgb("#F5F6F8"))
#set text(font: "Open Sans", size: 20pt, fill: rgb("#575756"))
#set par(leading: 0.62em)

#let eu-blue = rgb("#164194")
#let eu-gray = rgb("#575756")
#let pill-bg = rgb("#E3E9F5")

#let pill(body) = box(
  fill: pill-bg,
  radius: 8pt,
  inset: (x: 18pt, y: 11pt),
)[#text(size: 20pt, weight: "bold", fill: eu-blue)[#body]]

// Top accent bar.
#place(top + left, block(width: 100%, height: 14pt, fill: eu-blue))

// ── Left: marketing copy ────────────────────────────────────────────────────
#place(
  top + left,
  dx: 64pt,
  dy: 60pt,
  block(width: 700pt)[
    #text(size: 22pt, weight: "bold", fill: eu-blue, tracking: 1.2pt)[
      TYPST UNIVERSE PACKAGE
    ]
    #v(2pt)
    #text(size: 74pt, weight: "bold", fill: eu-blue)[rasko-europass]
    #v(2pt)
    #text(size: 27pt, fill: eu-gray)[
      A faithful, accessible Europass CV \
      template for Typst
    ]
    #v(26pt)
    #grid(
      columns: (auto, auto),
      column-gutter: 96pt,
      row-gutter: 16pt,
      pill[PDF/UA-1 accessible], pill[24 EU languages],
      pill[CEFR language grid], pill[GDPR clause],
    )
    #v(40pt)
    #text(size: 20pt, fill: eu-gray)[
      github.com/Raskolny/europass-cv \
      MIT code · Open Sans (Apache-2.0) fonts
    ]
  ],
)

// ── Right: the rendered first page as a shadowed "paper" ────────────────────
#place(
  top + right,
  dx: -55pt,
  dy: 42pt,
  {
    // Drop shadow, offset down-right.
    place(
      dx: 10pt,
      dy: 10pt,
      block(width: 391pt, height: 553pt, fill: rgb("#D8DCE3")),
    )
    // The page itself, clipped to the paper box.
    block(
      width: 391pt,
      height: 553pt,
      stroke: 0.8pt + rgb("#C9CFDA"),
      clip: true,
    )[#image("thumbnail.png", width: 100%, height: 100%, fit: "cover")]
  },
)
