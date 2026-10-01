#!/usr/bin/env python3
# Stage backgrounds. One PNG per stage, named stage-bg-<act>-<stage>.
# A room is one row, columns in the order the ground is stored, so the
# scroll reads left to right. The next room of that stage is the next row.
# Background tiles and that room's colors only.
#
#   python3 tools/stages.py
#
# Writes gfx/stages/*.png. Ground is bank 00. Blocks are bank 01.
# The pattern bank is the area's background pictures (area_bg >> 3).

import re
import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "gfx" / "stages"

SCALE = 2
ROW_GAP = 8
BG = (0x20, 0x28, 0x30)

# Visible playfield: six 32px blocks, and the bottom 16px is below the
# nametable. queue_column writes 22 tile rows, starting at nametable row 8.
PLAY_H = 22 * 8

NES = (
    (84, 84, 84), (0, 30, 116), (8, 16, 144), (48, 0, 136),
    (92, 0, 112), (132, 0, 64), (152, 0, 16), (136, 16, 0),
    (100, 40, 0), (48, 64, 0), (0, 72, 0), (0, 64, 64),
    (0, 48, 96), (0, 0, 0), (0, 0, 0), (0, 0, 0),
    (152, 150, 152), (8, 76, 196), (48, 50, 236), (92, 30, 228),
    (136, 20, 176), (180, 20, 120), (196, 32, 32), (196, 60, 0),
    (172, 92, 0), (124, 124, 0), (56, 148, 0), (0, 136, 72),
    (0, 112, 152), (0, 0, 0), (0, 0, 0), (0, 0, 0),
    (236, 238, 236), (76, 154, 236), (120, 124, 236), (176, 98, 236),
    (228, 84, 236), (236, 88, 180), (236, 106, 100), (252, 160, 68),
    (248, 184, 0), (184, 208, 32), (120, 220, 72), (88, 248, 152),
    (0, 232, 216), (120, 120, 120), (0, 0, 0), (0, 0, 0),
    (236, 238, 236), (168, 204, 236), (188, 188, 236), (212, 178, 236),
    (236, 174, 236), (236, 174, 212), (236, 180, 176), (252, 216, 168),
    (252, 220, 120), (220, 236, 120), (184, 248, 152), (164, 248, 200),
    (164, 248, 236), (184, 184, 184), (0, 0, 0), (0, 0, 0),
)

BYTE = re.compile(r"\$([0-9A-Fa-f]+)|%([01]+)|([0-9]+)")
LABEL = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*):")
WORD = re.compile(r"\.word\s+(\$[0-9A-Fa-f]+|[A-Za-z_][A-Za-z0-9_]*)")
RES = re.compile(r"\.res\s+(\$[0-9A-Fa-f]+|[0-9]+)\s*,\s*(\$[0-9A-Fa-f]+|[0-9]+)")


def parse_tok(tok):
    m = BYTE.search(tok)
    if not m:
        return None
    if m.group(1) is not None:
        return int(m.group(1), 16)
    if m.group(2) is not None:
        return int(m.group(2), 2)
    return int(m.group(3), 10)


def labeled_bytes(path):
    out = {}
    order = []
    name = None
    buf = []
    for line in path.read_text().splitlines():
        m = LABEL.match(line)
        if m:
            if name is not None:
                out[name] = buf
                order.append(name)
            name = m.group(1)
            buf = []
            continue
        code = line.split(";", 1)[0]
        if name is None or ".byte" not in code:
            continue
        for tok in code.split(".byte", 1)[1].split(","):
            val = parse_tok(tok)
            if val is not None:
                buf.append(val)
    if name is not None:
        out[name] = buf
        order.append(name)
    return out, order


def byte_list(text, anchor):
    lines = text.splitlines()
    start = next(i for i, line in enumerate(lines) if line.startswith(anchor + ":"))
    vals = []
    for line in lines[start + 1:]:
        if LABEL.match(line):
            break
        code = line.split(";", 1)[0]
        if ".byte" not in code:
            continue
        for tok in code.split(".byte", 1)[1].split(","):
            val = parse_tok(tok)
            if val is not None:
                vals.append(val)
    return vals


def word_list(text, anchor):
    lines = text.splitlines()
    start = next(i for i, line in enumerate(lines) if line.startswith(anchor + ":"))
    words = []
    for line in lines[start + 1:]:
        if LABEL.match(line):
            break
        code = line.split(";", 1)[0]
        for m in WORD.finditer(code):
            words.append(m.group(1))
    return words


def _num(text):
    return int(text[1:], 16) if text.startswith("$") else int(text)


def bank_image(path):
    """Bytes of a PRG bank, expanding .res, from the first data line."""
    data = bytearray()
    for line in path.read_text().splitlines():
        code = line.split(";", 1)[0].strip()
        if not code:
            continue
        m = RES.match(code)
        if m:
            data.extend([_num(m.group(2))] * _num(m.group(1)))
            continue
        if ".byte" not in code:
            continue
        for tok in code.split(".byte", 1)[1].split(","):
            val = parse_tok(tok)
            if val is not None:
                data.append(val)
    return bytes(data)


def parse_chr(path):
    data = bytes(b for line in path.read_text().splitlines()
                 for b in _line_bytes(line))
    if len(data) != 8192:
        raise SystemExit(f"{path}: {len(data)} bytes")
    return data


def _line_bytes(line):
    code = line.split(";", 1)[0]
    if ".byte" not in code:
        return
    for tok in code.split(".byte", 1)[1].split(","):
        val = parse_tok(tok)
        if val is not None:
            yield val


def chr_half(banks, mmc):
    return banks[mmc // 2][(mmc % 2) * 4096:(mmc % 2 + 1) * 4096]


def tile_rows(data, tile):
    base = tile * 16
    rows = []
    for y in range(8):
        lo = data[base + y]
        hi = data[base + 8 + y]
        rows.append([((hi >> bit) & 1) << 1 | ((lo >> bit) & 1) for bit in range(7, -1, -1)])
    return rows


def _chunk(tag, payload):
    return struct.pack(">I", len(payload)) + tag + payload + struct.pack(">I", zlib.crc32(tag + payload) & 0xFFFFFFFF)


def write_png(path, width, height, rgb):
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


def blit_16(buf, stride, chr4k, quartet, pal, backdrop, x, y):
    """One 16x16. block_tiles order is top-left, bottom-left, top-right, bottom-right."""
    spots = ((0, 0, 0), (0, 8, 1), (8, 0, 2), (8, 8, 3))
    colors = (backdrop, NES[pal[0]], NES[pal[1]], NES[pal[2]])
    for ox, oy, i in spots:
        rows = tile_rows(chr4k, quartet[i])
        for ty, row in enumerate(rows):
            for tx, pix in enumerate(row):
                o = ((y + oy + ty) * stride + (x + ox + tx)) * 3
                buf[o:o + 3] = bytes(colors[pix])


def render_room(columns, which, metas, attrs, chr4k, pals, backdrop):
    width = len(columns) * 32
    buf = bytearray(width * PLAY_H * 3)
    for i in range(width * PLAY_H):
        o = i * 3
        buf[o:o + 3] = bytes(backdrop)
    for c, blocks in enumerate(columns):
        for right in (0, 1):
            pair = 2 if right else 0
            for b, bid in enumerate(blocks):
                entry = which[bid * 4:bid * 4 + 4]
                attr = attrs[bid]
                if right:
                    up_pal = (attr >> 2) & 3
                    lo_pal = (attr >> 6) & 3
                else:
                    up_pal = attr & 3
                    lo_pal = (attr >> 4) & 3
                x = c * 32 + right * 16
                y_up = b * 32
                y_lo = y_up + 16
                blit_16(buf, width, chr4k, metas[entry[pair] * 4:entry[pair] * 4 + 4],
                        pals[up_pal], backdrop, x, y_up)
                if y_lo < PLAY_H:
                    blit_16(buf, width, chr4k, metas[entry[pair + 1] * 4:entry[pair + 1] * 4 + 4],
                            pals[lo_pal], backdrop, x, y_lo)
    return width, buf


def scale_rgb(width, height, rgb, scale):
    out_w = width * scale
    out_h = height * scale
    out = bytearray(out_w * out_h * 3)
    for y in range(height):
        row = rgb[y * width * 3:(y + 1) * width * 3]
        wide = bytearray()
        for x in range(width):
            wide += row[x * 3:x * 3 + 3] * scale
        for dy in range(scale):
            out[(y * scale + dy) * out_w * 3:(y * scale + dy + 1) * out_w * 3] = wide
    return out_w, out_h, out


def main():
    bank00 = (ROOT / "prg" / "bank00.asm").read_text()
    labels, _ = labeled_bytes(ROOT / "prg" / "bank00.asm")
    rooms = word_list(bank00, "room_layout")
    room_scroll = byte_list(bank00, "room_scroll")
    first_room = byte_list(bank00, "first_room")
    act_stage = byte_list(bank00, "act_stage")
    area_gfx = byte_list(bank00, "area_gfx")
    area_bg = byte_list(bank00, "area_bg")
    colors_a = byte_list(bank00, "area_colors_a")
    colors_b = byte_list(bank00, "area_colors_b")
    colors_c = byte_list(bank00, "area_colors_c")
    bg_pick = byte_list(bank00, "bg_pick")
    color_set = byte_list(bank00, "color_set")
    bg_color = byte_list(bank00, "bg_color")

    prg = bank_image(ROOT / "prg" / "bank01.asm")
    # $8000 block tiles, $A000 which blocks, $B000 the attribute byte.
    if prg[0x2000:0x2004] != bytes([0x37, 0x38, 0x2E, 0x30]):
        raise SystemExit("bank 01 image is not aligned at which_blocks")
    chr_banks = [parse_chr(ROOT / "chr" / f"bank{n:02d}.asm") for n in range(8)]

    def area_of(room):
        area = 0
        for i, start in enumerate(first_room):
            if start <= room:
                area = i
            else:
                break
        return area

    def pals_of(area):
        def triple(index):
            return tuple(color_set[index * 3:index * 3 + 3])
        return (
            triple(0),
            triple(colors_a[area]),
            triple(colors_b[area]),
            triple(colors_c[area]),
        )

    stages = {}
    order = []
    for room, name in enumerate(rooms):
        area = area_of(room)
        key = act_stage[area]
        if key not in stages:
            stages[key] = []
            order.append(key)
        raw = labels[name]
        # $53 is how many screens the room scrolls. One screen is already
        # on view, so the ground is that many screens plus one.
        need = ((room_scroll[room] & 0x7F) + 1) * 48
        if len(raw) < need or (len(raw) != need and room != len(rooms) - 1):
            raise SystemExit(f"{name}: {len(raw)} bytes, room is {need}")
        raw = raw[:need]
        columns = [raw[i:i + 6] for i in range(0, len(raw), 6)]
        gfx = area_gfx[area]
        which = prg[0x2000 + (gfx & 3) * 0x400:0x2000 + (gfx & 3) * 0x400 + 0x400]
        metas = prg[(gfx & 0x1C) * 0x100:(gfx & 0x1C) * 0x100 + 0x400]
        attrs = prg[0x3000 + (gfx & 3) * 0x100:0x3000 + (gfx & 3) * 0x100 + 0x100]
        mmc = area_bg[area] >> 3
        backdrop = NES[bg_color[bg_pick[room] >> 4]]
        width, rgb = render_room(columns, which, metas, attrs, chr_half(chr_banks, mmc),
                                  pals_of(area), backdrop)
        stages[key].append((name, width, rgb, backdrop))

    OUT.mkdir(parents=True, exist_ok=True)
    for key in order:
        rows = stages[key]
        act, stage = key >> 4, key & 0x0F
        # Two areas of act 6 stage 4 point at the same ground and the same colors.
        unique = []
        for row in rows:
            if unique and unique[-1][2] == row[2]:
                continue
            unique.append(row)
        width = max(w for _, w, _, _ in unique)
        gap = ROW_GAP if len(unique) > 1 else 0
        height = len(unique) * PLAY_H + (len(unique) - 1) * gap
        sheet = bytearray(width * height * 3)
        for i in range(width * height):
            o = i * 3
            sheet[o:o + 3] = bytes(BG)
        y = 0
        for _, w, rgb, _ in unique:
            for row in range(PLAY_H):
                sheet[(y + row) * width * 3:(y + row) * width * 3 + w * 3] = rgb[row * w * 3:(row + 1) * w * 3]
            y += PLAY_H + gap
        sw, sh, scaled = scale_rgb(width, height, sheet, SCALE)
        path = OUT / f"stage-bg-{act}-{stage}.png"
        write_png(path, sw, sh, scaled)
        names = ", ".join(n for n, _, _, _ in unique)
        print(f"{path.name}  {sw}x{sh}  {len(unique)} room(s)  {names}")


if __name__ == "__main__":
    main()
