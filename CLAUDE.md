# Working rules for this repo

## Rule 1: No guessing, no assumptions
Every factual claim (hardware pinouts, chip capabilities, API availability,
library behaviour, product features) must come from a source that was actually
read in this session: datasheets, vendor docs, source code, or official
reference pages. Name the source next to the claim.

- If a fact cannot be verified, say "unverified" and either research it or ask
  the user. Never present a guess as fact, and never fill gaps from memory.
- Community libraries and blog posts can be wrong (example: the
  ESP32S3_SUPERMINI_PINOUT library mislabels S3 flash pins). Cross-check
  them against a primary source before relying on them.
- When the user asks a question, ask it as a multiple-choice question.

## Tooling notes
- OpenSCAD skill: `.claude/skills/openscad/`. In headless containers, wrap
  preview scripts with `xvfb-run -a`.
