---
name: ng-annotate
description: >-
  Name and comment Ninja Gaiden routines, data, and instructions in
  player-facing language while disassembling, investigating, or generating
  maps and spritesheets. Use when lifting a bank, naming a label or a
  repeated address, commenting a statement, revisiting older unannotated
  code, recording a definite finding, or writing anything in prg/*.asm
  comments.
---

# Annotations

Identification and annotation are part of disassembly, not a later pass.
When a bank or a block becomes source, name what is clear and comment it
in the same step, then update `docs/progress.md` (`ng-notes`). `make verify`
still has to match.

Certainty is 80% or better before a name or a label comment. Below that,
leave the address label and do not invent a name from a count, a guess,
or a table that lives in a bank we have not read. A statement comment
requires a definite purpose for that instruction. If it is not definite,
leave the line bare.

Annotate (comment) a label whenever we have that picture of what it does.

Annotations should be in the context of the game itself — not overly obtuse and hard to understand for the average person.

Examples of good annotations:

- subtract -1 from life
- use sword
- add 100 to score

Examples of bad annotations:

- `; ten frames, then the other exit` (without any other context)
- `; bank 4, A = table byte` (unclear what it means; too technical)

Additionally, annotate single statements, with short, concise information whenever purpose is known definitively. Statement annotations can be technical, but not overly so — one should not need to have an intimate knowledge of hardware to understand its meaning.

When revisiting older unannotated code, name and annotate if the picture is now clear enough.

Investigating the game, or generating a map or a spritesheet, is the same work as reading the source. When that work makes a picture clear enough to name, name it and comment it in the same step. The certainty bar, the player-facing wording, where the comment goes, and `make verify` still apply. A sheet or a map is not a reason to guess.

Unused artifacts, routines, data, and code get a label comment that says they are unused, and they are recorded in `docs/game-notes.md` (`ng-notes`).

Name a repeated address (a RAM byte, a flag, a table) when the same bar is met and the same thing is used in more than one place. One-off scratch stays numeric.

## Where they go

Label comment: the block directly above the label. Below 80%, leave the comment off and do not rename the label.

Statement comment: end of that line only. If the purpose is not definite, leave the line bare.

## Pixels

When a sprite or tile is monochrome and each row is 8 pixels or fewer, write the pixels in binary, one row per line. The leftmost pixel is the high bit. A picture taller than 8 rows is still binary, one row per line.

```
        .byte %00111100
        .byte %01000010
```

Only do this when those bytes are obviously the picture. Counts, tile numbers, positions, delays, and colors stay in hex. A wider row, or a picture that is not obvious, stays in hex too.
