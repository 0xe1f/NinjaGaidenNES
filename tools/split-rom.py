#!/usr/bin/env python3
# Split the local Ninja Gaiden (U) iNES dump into INCBIN banks.
# PRG: 8 x 16 KiB -> prg/bankNN.bin. CHR: 16 x 8 KiB -> chr/bankNN.bin.

import sys
from pathlib import Path

PRG_BANKS = 8
CHR_BANKS = 16
PRG_SIZE = 16384
CHR_SIZE = 8192


def main() -> None:
    src = Path(sys.argv[1] if len(sys.argv) > 1 else "reference/gaiden.nes")
    data = src.read_bytes()
    if data[:4] != b"NES\x1a":
        raise SystemExit(f"{src} is not an iNES file")
    prg_n, chr_n, flags6 = data[4], data[5], data[6]
    if (prg_n, chr_n, flags6) != (PRG_BANKS, CHR_BANKS, 0x10):
        raise SystemExit(
            "expected Ninja Gaiden (U): 8x16 KiB PRG, 16x8 KiB CHR, mapper 1; "
            f"got prg={prg_n} chr={chr_n} flags6={flags6:#04x}"
        )
    off = 16
    prg = data[off : off + PRG_BANKS * PRG_SIZE]
    off += len(prg)
    chr_rom = data[off : off + CHR_BANKS * CHR_SIZE]
    if off + len(chr_rom) != len(data):
        raise SystemExit(f"size mismatch: file {len(data)}, used {off + len(chr_rom)}")

    prg_dir = Path("prg")
    chr_dir = Path("chr")
    prg_dir.mkdir(exist_ok=True)
    chr_dir.mkdir(exist_ok=True)
    for i in range(PRG_BANKS):
        prg_dir.joinpath(f"bank{i:02d}.bin").write_bytes(prg[i * PRG_SIZE : (i + 1) * PRG_SIZE])
    for i in range(CHR_BANKS):
        chr_dir.joinpath(f"bank{i:02d}.bin").write_bytes(
            chr_rom[i * CHR_SIZE : (i + 1) * CHR_SIZE]
        )
    print(f"split {src}: {PRG_BANKS} PRG banks, {CHR_BANKS} CHR banks")


if __name__ == "__main__":
    main()
