---
name: ng-setup
description: >-
  Set up the Ninja Gaiden NES disassembly environment: cc65 V2.19,
  the local iNES dump, INCBIN file banks, and SHA-1 verify. Use when
  scaffolding this repo, installing ca65/ld65, splitting
  reference/gaiden.nes, or refreshing the build. Makefile generation
  is ng-makefile.
---

# Ninja Gaiden environment

Byte-exact ca65 project. Not MSX: do not use sjasmplus, a workbench
submodule, or Vampire Killer window files.

Makefile bytes come from `ng-makefile`. Do not hand-write `PRG_BINS` /
`CHR_BINS`.

## Pin

cc65 tag **V2.19** (`tools/install-cc65`, same tag in
`.github/workflows/verify.yml`). `ca65 --version` prints
`V2.18 - Git 5552824`. That string is the V2.19 tag. Do not bump it.

```sh
make tools      # tools/ca65 and tools/ld65, gitignored
```

## Dump

Local file: `reference/gaiden.nes` (gitignored). US *Ninja Gaiden (U)*,
iNES mapper 1, 8 × 16 KiB PRG, 16 × 8 KiB CHR. SHA-1 is
`NinjaGaiden.sha1`. Do not commit the image, `prg/*.bin`, or `chr/*.bin`.

```sh
make banks      # tools/split-rom.py -> prg/bankNN.bin, chr/bankNN.bin
```

`make banks` is the only step that needs the dump. `make` / `make verify`
need the bins (or later, source in place of `INCBIN`).

## Scaffold order

1. Probe the 16-byte iNES header before assuming mapper or bank size.
2. `NinjaGaiden.asm` — header bytes, then one `.incbin` per file bank.
   `NinjaGaiden.cfg` — one `PRG`/`CHR` segment per bank, same ids, same order.
3. `python3 tools/gen-makefile.py` (`ng-makefile`).
4. `make tools` if `tools/ca65` is missing.
5. `make banks` if the bins are missing.
6. `make verify`. Leave it green.

Naming and comments are part of this step, not a follow-up. Follow
`ng-annotate`: identify and annotate only where the certainty bar is met.
When that step replaces `INCBIN` with source, update `docs/progress.md`
in the same step (`ng-notes`).

File banks stay 16 KiB PRG and 8 KiB CHR until the MMC1 control register
is named. Do not merge them into CPU windows in this step.

## CI

`.github/workflows/verify.yml` builds ca65/ld65 from tag V2.19 and runs
`make verify`. It stays red while banks are `INCBIN`, because the bins
are gitignored. Do not commit bins to turn CI green.

The coverage job does not assemble. It runs `tools/coverage.py` and, on
a push to the default branch, force-pushes Shields.io JSON to an orphan
`badges` branch.

## README shields

Origin is `0xe1f/NinjaGaidenNES`. After the title, the README has the
verify badge and four endpoint badges: in source, named, op comments,
sub comments. URLs use that slug. Do not invent another. Do not put a
coverage table in the README. `make coverage` writes JSON under
`generated/badges/` and prints the report.

| Badge | Count | Done when |
|---|---|---|
| in source | PRG+CHR bytes not behind `.incbin` | every bank byte is `.asm` |
| named | remaining `Xhhhh` definitions (one letter, four hex digits) | none left |
| op comments | instruction lines with a `;` comment | long tail |
| sub comments | named `jsr` targets with a comment block immediately above | every called routine has docs |

The 16-byte iNES header is outside the KiB total. `@` locals are named.
`jmp` targets are not subs. A trailing `;` on the label line is not docs.
