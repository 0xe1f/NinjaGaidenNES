# Ninja Gaiden (NES) — disassembly

[![verify](https://github.com/0xe1f/NinjaGaidenNES/actions/workflows/verify.yml/badge.svg)](https://github.com/0xe1f/NinjaGaidenNES/actions/workflows/verify.yml)
[![in source](https://img.shields.io/badge/in_source-256_%2F_256_KiB-brightgreen?style=flat)](https://github.com/0xe1f/NinjaGaidenNES/actions/workflows/verify.yml)
[![named](https://img.shields.io/badge/named-1145_left-red?style=flat)](https://github.com/0xe1f/NinjaGaidenNES/actions/workflows/verify.yml)
[![op comments](https://img.shields.io/badge/op_comments-4.6%25-lightgrey?style=flat)](https://github.com/0xe1f/NinjaGaidenNES/actions/workflows/verify.yml)
[![sub comments](https://img.shields.io/badge/sub_comments-133_%2F_136-brightgreen?style=flat)](https://github.com/0xe1f/NinjaGaidenNES/actions/workflows/verify.yml)

> This project is a human-guided, largely AI-executed workflow.

A work-in-progress, **byte-exact and reassemblable** disassembly of Tecmo's
*Ninja Gaiden* (1989, USA) for the NES — an MMC1 (SLROM) cart, 128 KiB PRG
and 128 KiB CHR.

The goal is a readable, commented, buildable source that reproduces the original
ROM exactly, so the game can be understood and modified.

## What's here

```
NinjaGaiden.asm     master file: iNES header + one INCBIN per file bank
NinjaGaiden.cfg     ld65 layout (header, 8 x 16 KiB PRG, 16 x 8 KiB CHR)
NinjaGaiden.sha1    SHA-1 of the original 256 KiB + header image (`make verify`)
prg/                PRG file banks (INCBIN leftovers are gitignored .bin)
chr/                CHR file banks
tools/              split-rom.py, install-cc65, coverage.py
docs/               reverse-engineering notes (`game-notes.md`, `progress.md`)
Makefile            build / verify
```

## Building

You need **ca65** and **ld65** from [cc65](https://github.com/cc65/cc65) **V2.19**
at `tools/ca65` and `tools/ld65`:

```sh
make tools      # clone and build cc65 V2.19 into tools/
make banks      # split reference/gaiden.nes (local dump, gitignored)
make verify     # assemble, then SHA-1 check against NinjaGaiden.sha1
make coverage   # local Shields JSON under generated/badges/
```

`make` alone produces `NinjaGaiden.nes` in the repo root (gitignored).
`NinjaGaiden.sha1` is the SHA-1 of the original iNES image. `make verify`
rebuilds and confirms the output matches it.

While a bank is still `INCBIN`, that `.bin` has to exist locally (`make banks`).
Once every bank is source, the dump is not required to assemble or verify.

## How it works

The image is a 16-byte iNES header, then 128 KiB PRG, then 128 KiB CHR.
PRG is split into 16 KiB file banks and CHR into 8 KiB file banks — the iNES
units, not yet the CPU windows MMC1 actually maps. Banks are converted from
raw binary into commented disassembly one at a time, and after every change
the ROM is rebuilt and SHA-1 checked so it stays byte-for-byte identical.

See `docs/game-notes.md` for the cart facts gathered so far, and
`docs/progress.md` for current status and next steps.

## License

Original work in this repository (tools, comments, documentation, labels,
and project structure) is licensed under the Apache License, Version 2.0.
See [`LICENSE`](LICENSE) and [`NOTICE`](NOTICE).

*Ninja Gaiden* is © 1988 Tecmo. This project does not relicense the original
game, ROM, graphics, or music.
