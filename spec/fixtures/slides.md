---
align: center
footer: "**footer content**"
margin: 1 2
pager: "page %<page>d of %<total>d"
symbols: ascii
theme:
  header:
    - magenta
    - underline
  link: cyan
  list: green
  strong: blue
--- symbols: {base: ascii, override: {arrow: ">>"}}

# [Title](url)

* Item 1
* Item 2
* Item 3

--- align: left

Slide 1

--- pager: {text: slide %<page>d}

Slide 2

--- {align: right, footer: {text: "slide footer"}}

Slide 3

---

Summary
