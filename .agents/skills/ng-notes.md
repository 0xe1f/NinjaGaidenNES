---
name: ng-notes
description: >-
  Update docs/progress.md after every Ninja Gaiden conversion from
  INCBIN to .asm, and refresh progress and docs/game-notes.md in full
  detail before each commit. Use when a bank or block becomes source,
  when finishing a disassembly step, or when preparing a commit.
---

# Progress and notes

`docs/progress.md` and `docs/game-notes.md` move with the source. Same
certainty bar as `ng-annotate`: 80% or better. Leave out a name, a
caller, or a behavior the source does not show.

`make verify` still has to match. These files do not change ROM bytes.

## After every conversion

When a bank or a block stops being `INCBIN` and becomes `.asm`, update
`docs/progress.md` in that same step, before the conversion is done.

- **Done.** The file bank and, when known, the CPU window. What the new
  source is for, in the same player-facing language as the comments.
  Every routine, table, and RAM byte named in that step, with its
  address and what it does.
- **Next.** The next `INCBIN` bank or block. Say why that one is next
  when a caller or a table already points at it.

Leave the end goal as it is.

## Before each commit

Update both files from the source that is about to be committed, in as
much detail as that source supports, and include them in the commit.

`docs/progress.md` lists every converted bank under Done, with the named
entry points and what they do. Next is the concrete leftover.

`docs/game-notes.md` records every cart fact, RAM byte, and system that
is now definite: addresses, what the player sees, and how the pieces
connect (who calls it, what it reads, what it changes). Write for
someone who plays the game. A table when a list is the clearest form.
Prose for how a system works. Hardware detail only where it explains
that.

Re-read both files against the current `.asm` and fill anything they
omit. Do not pad them when nothing new is definite.
