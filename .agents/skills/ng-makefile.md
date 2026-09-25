---
name: ng-makefile
description: >-
  Generate the Ninja Gaiden Makefile from NinjaGaiden.asm INCBIN banks
  and NinjaGaiden.cfg. Use when creating or updating the Makefile,
  adding or reordering a PRG or CHR file bank, or when the make bank
  list may have drifted from the asm.
---

# Makefile

`Makefile` is generated. Do not edit `PRG_BINS` or `CHR_BINS` by hand.

```sh
python3 tools/gen-makefile.py          # write Makefile
python3 tools/gen-makefile.py --check  # exit 1 if it would change
make verify
```

The script reads `.segment "PRG#"` / `.segment "CHR#"` from `NinjaGaiden.asm`.
Those ids must match `NinjaGaiden.cfg`, in the same order. Bin prerequisites
are `.incbin "prg/bankNN.bin"` and `.incbin "chr/bankNN.bin"`, including
inside a `.include`d file, once each. A ranged incbin of a bank that is
partly source still lists that bin. If `reference/gaiden.nes` is present,
its iNES unit counts must match the segment lists, not the leftover bins.
The script exits instead of writing when they disagree.

`reference/gaiden.nes` is a prerequisite of `make banks` only. `all` depends
on the leftover bin files and on `INCLUDES` (every `.include`), not on the dump.

A bank that is entirely `.asm` drops its `.incbin` and therefore its bin
prerequisite. The `.segment` stays. Regenerate, then `make verify`.
