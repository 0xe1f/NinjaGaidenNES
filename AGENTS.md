# NinjaGaiden

Byte-exact 6502 disassembly of Tecmo's *Ninja Gaiden* (NES, USA, 1989).

- Assembler: ca65/ld65 from cc65 **V2.19**, gitignored at `tools/ca65` and `tools/ld65` (`tools/install-cc65`). Same pin as `.github/workflows/verify.yml`.
- **Byte-exact round-trip at every step.** `make verify` must match `NinjaGaiden.sha1`. Run it after every edit. Never commit a change that breaks it.
- The local dump is `reference/gaiden.nes` (gitignored). `make banks` splits it into `prg/*.bin` and `chr/*.bin` (also gitignored). The committed SHA-1 is the check; an original dump is not required once a bank is source instead of `INCBIN`.
- Default split is one file bank per iNES unit: PRG `bank00`–`bank07` (16 KiB), CHR `bank00`–`bank15` (8 KiB). Do not merge those into CPU windows until this cart's MMC1 control register is named.
- Do not commit `*.nes`, `prg/*.bin`, or `chr/*.bin`.
- Game-only skills: `.agents/skills/ng-setup.md` (toolchain, dump, banks, verify), `ng-makefile.md` (`tools/gen-makefile.py`), and `ng-annotate.md` (names and comments, in the same step as disassembly, and only at the certainty bar that skill states). Do not hand-edit `PRG_BINS` / `CHR_BINS`. Do not copy MSX workbench skills here.

**End state.** Every ROM byte is labelled `.asm`. Leftover `INCBIN` is scaffold only.
