---
name: ng-annotate
description: >-
  Comment Ninja Gaiden routines and instructions in player-facing language.
  Use when naming or commenting a label, annotating a statement, revisiting
  older unannotated code, or writing anything in prg/*.asm comments.
---

# Annotations

Annotate (comment) labels whenever we have a solid picture of what that routine is doing (80% coverage or better).

Annotations should be in the context of the game itself — not overly obtuse and hard to understand for the average person.

Examples of good annotations:

- subtract -1 from life
- use sword
- add 100 to score

Examples of bad annotations:

- `; ten frames, then the other exit` (without any other context)
- `; bank 4, A = table byte` (unclear what it means; too technical)

Additionally, annotate single statements, with short, concise information whenever purpose is known definitively. Statement annotations can be technical, but not overly so — one should not need to have an intimate knowledge of hardware to understand its meaning.

When revisiting older unannotated code, do annotate if enough information becomes known to annotate.

## Where they go

Label comment: the block directly above the label. Below 80%, leave it off. A bare name is fine.

Statement comment: end of that line only. If the purpose is not definite, leave the line bare.
