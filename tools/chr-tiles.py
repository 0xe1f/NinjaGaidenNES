#!/usr/bin/env python3
# Contact sheets for the CHR file banks. One PNG per bank, one 8x8 tile
# per cell. The header is the tile's byte offset in that bank.
#
#   python3 tools/chr-tiles.py
#
# Writes gfx/tiles/bank00.png .. bank15.png. Source is chr/bankNN.asm.

import re
import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CHR = ROOT / "chr"
OUT = ROOT / "gfx" / "tiles"

BANKS = 16
BANK_SIZE = 8192
TILE = 16
COLS = 16

SCALE = 6
GAP = 2
LAB_SCALE = 2
BG = (0x20, 0x28, 0x30)
LABEL = (200, 200, 205)
# Index 0 is empty, 1 is bitplane 0, 2 is bitplane 1, 3 is both.
PALETTE = (
    (0x30, 0x3A, 0x44),
    (0x48, 0x68, 0xA8),
    (0xD0, 0x70, 0x40),
    (0xF0, 0xF0, 0xF0),
)

# 3x5 digits, same shapes as the Vampire Killer sheets.
FONT = {
    "0": ("111", "101", "101", "101", "111"),
    "1": ("010", "110", "010", "010", "111"),
    "2": ("111", "001", "111", "100", "111"),
    "3": ("111", "001", "111", "001", "111"),
    "4": ("101", "101", "111", "001", "001"),
    "5": ("111", "100", "111", "001", "111"),
    "6": ("111", "100", "111", "101", "111"),
    "7": ("111", "001", "010", "100", "100"),
    "8": ("111", "101", "111", "101", "111"),
    "9": ("111", "101", "111", "001", "111"),
    "A": ("010", "101", "111", "101", "101"),
    "B": ("110", "101", "110", "101", "110"),
    "C": ("011", "100", "100", "100", "011"),
    "D": ("110", "101", "101", "101", "110"),
    "E": ("111", "100", "110", "100", "111"),
    "F": ("111", "100", "110", "100", "100"),
}

BYTE = re.compile(r"\$([0-9A-Fa-f]+)|%([01]+)|([0-9]+)")


def parse_bank(path: Path) -> bytes:
    out = bytearray()
    for line in path.read_text().splitlines():
        code = line.split(";", 1)[0]
        if ".byte" not in code:
            continue
        for tok in code.split(".byte", 1)[1].split(","):
            m = BYTE.search(tok)
            if not m:
                raise SystemExit(f"{path}: bad byte {tok!r}")
            if m.group(1) is not None:
                out.append(int(m.group(1), 16))
            elif m.group(2) is not None:
                out.append(int(m.group(2), 2))
            else:
                out.append(int(m.group(3), 10))
    if len(out) != BANK_SIZE:
        raise SystemExit(f"{path}: {len(out)} bytes, expected {BANK_SIZE}")
    return bytes(out)


def tile_pixels(tile: bytes) -> list[list[int]]:
    grid = []
    for row in range(8):
        lo = tile[row]
        hi = tile[row + 8]
        grid.append([((hi >> bit) & 1) << 1 | ((lo >> bit) & 1) for bit in range(7, -1, -1)])
    return grid


def _chunk(tag: bytes, data: bytes) -> bytes:
    return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)


def write_png(path: Path, width: int, height: int, rgb: bytes) -> None:
    raw = bytearray()
    stride = width * 3
    for y in range(height):
        raw.append(0)
        raw += rgb[y * stride:(y + 1) * stride]
    png = b"\x89PNG\r\n\x1a\n"
    png += _chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
    png += _chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    png += _chunk(b"IEND", b"")
    path.write_bytes(png)


def draw_label(buf: bytearray, width: int, x: int, y: int, text: str) -> None:
    scale = LAB_SCALE
    for ch in text:
        glyph = FONT[ch]
        for gy, row in enumerate(glyph):
            for gx, bit in enumerate(row):
                if bit != "1":
                    continue
                for yy in range(scale):
                    base = ((y + gy * scale + yy) * width + x + gx * scale) * 3
                    for xx in range(scale):
                        o = base + xx * 3
                        buf[o:o + 3] = bytes(LABEL)
        x += 4 * scale



def render(data: bytes) -> tuple[int, int, bytes]:
    tiles = [tile_pixels(data[i:i + TILE]) for i in range(0, len(data), TILE)]
    rows = len(tiles) // COLS
    lab_h = 5 * LAB_SCALE + 4
    cell_w = 8 * SCALE
    cell_h = lab_h + 8 * SCALE
    width = COLS * cell_w + (COLS + 1) * GAP
    height = rows * cell_h + (rows + 1) * GAP
    buf = bytearray(width * height * 3)
    for i in range(width * height):
        o = i * 3
        buf[o:o + 3] = bytes(BG)
    for idx, grid in enumerate(tiles):
        x0 = GAP + (idx % COLS) * (cell_w + GAP)
        y0 = GAP + (idx // COLS) * (cell_h + GAP)
        draw_label(buf, width, x0 + 2, y0 + 2, f"{idx * TILE:04X}")
        ty = y0 + lab_h
        for y in range(8):
            for x in range(8):
                rgb = PALETTE[grid[y][x]]
                for dy in range(SCALE):
                    for dx in range(SCALE):
                        o = ((ty + y * SCALE + dy) * width + x0 + x * SCALE + dx) * 3
                        buf[o:o + 3] = bytes(rgb)
    return width, height, bytes(buf)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for n in range(BANKS):
        src = CHR / f"bank{n:02d}.asm"
        width, height, rgb = render(parse_bank(src))
        dest = OUT / f"bank{n:02d}.png"
        write_png(dest, width, height, rgb)
        print(f"{dest.relative_to(ROOT)}  {width}x{height}")


if __name__ == "__main__":
    main()
