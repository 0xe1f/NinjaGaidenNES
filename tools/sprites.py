#!/usr/bin/env python3
# Gameplay sprites. One PNG per actor. Frames of that actor share a row.
# A shot or other piece he carries is the next row; its own frames stay
# on that row. Cell headers are the picture number, same style as the
# tile sheets.
#
#   python3 tools/sprites.py
#
# Writes gfx/sprites/*.png. Pictures and colors are bank 02. The pattern
# bank and the last two sprite palettes come from the first room that
# enemy stands in.

import re
import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "gfx" / "sprites"

SCALE = 6
GAP = 2
LAB_SCALE = 2
BG = (0x20, 0x28, 0x30)
# Transparent pixels inside a cell. The darker gap around that block is the
# hairline between cells, same as the Vampire Killer sheets.
OFF = (0x30, 0x3A, 0x44)
INK = (200, 200, 205)

# 2C02 palette. Index 0 of a sprite is transparent.
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
LABEL = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*):")
WORD = re.compile(r"\.word\s+(\$[0-9A-Fa-f]+|[A-Za-z_][A-Za-z0-9_]*)")

# One sheet. Each row is the frames of one thing: the actor, then a shot,
# then anything else he brings with him. A picture is claimed by the
# longest matching prefix, so stone_man_ring stays off the stone man row.
# filename, which picture table, enemy type whose room supplies the
# pattern banks and the last two palettes, then rows.
# Falling power-ups. The picture index, then how far into its colors the
# second set starts. 5 and 10 ninpo share picture $19; 5 and 10 points
# share $22. The low bits of $E619 pick that second set.
PICKUPS = [
    (0x19, 0),
    (0x19, 2),
    (0x1A, 0),
    (0x20, 0),
    (0x21, 0),
    (0x22, 0),
    (0x22, 2),
    (0x1B, 0),
    (0x1C, 0),
    (0x1E, 0),
    (0x1F, 0),
    (0x1D, 0),
    (0x29, 0),
]

SHEETS = [
    ("ryu", "ryu", 0x00, [
        ["ryu_"],
        ["throwing_star_"],
        ["windmill_star_"],
        ["jump_and_slash_"],
        ["fire_wheel_"],
        ["invincible_fire_wheel_"],
    ]),
    # Lanterns are filled in below. The same picture index is a different
    # object in each area, because the tiles come from that area's background bank.
    ("boxer", "enemy", 0x00, [["boxer_"]]),
    ("machine_gunner", "enemy", 0x01, [["machine_gunner_"], ["machine_gun_bullet_"]]),
    ("thrower", "enemy", 0x02, [["thrower_"], ["axe_"]]),
    ("batter", "enemy", 0x03, [["batter_"]]),
    ("knife_thrower", "enemy", 0x04, [["knife_thrower_"], ["knife_"]]),
    ("bazooka_soldier", "enemy", 0x05, [["crouching_soldier_"], ["crouching_soldier_bullet_"]]),
    ("jump_kicker", "enemy", 0x06, [["jump_kicker_"]]),
    ("runner", "enemy", 0x07, [["running_soldier_"]]),
    ("bat", "enemy", 0x08, [["bat_"]]),
    ("dog", "enemy", 0x09, [["dog_"]]),
    ("bird", "enemy", 0x0B, [["bird_"]]),
    ("jetpack_ninja", "enemy", 0x0C, [["jetpack_ninja_"], ["shuriken_"]]),
    ("green_ninja", "enemy", 0x0D, [["running_ninja_", "enemy_pic_36"]]),
    ("stone_man", "enemy", 0x0E, [["stone_man_"], ["stone_man_ring_"]]),
    ("ghoul", "enemy", 0x0F, [["ghoul_"]]),
    ("death", "enemy", 0x00, [["death_"]]),
    ("barbarian", "enemy", 0x17, [["barbarian_"]]),
    ("bomberhead", "enemy", 0x18, [
        ["bomberhead_pic_4A", "bomberhead_pic_4B", "bomberhead_pic_4C", "bomberhead_pic_4D"],
        ["bomberhead_pic_4E", "bomberhead_pic_4F", "bomberhead_pic_50",
         "bomberhead_pic_51", "bomberhead_pic_6C", "bomberhead_pic_84"],
    ]),
    ("basaquer", "enemy", 0x19, [
        ["basaquer_pic_52", "basaquer_pic_53"],
        ["basaquer_pic_54"],
    ]),
    ("kelbeross", "enemy", 0x1B, [
        ["kelbeross_pic_55", "enemy_pic_56", "kelbeross_pic_57"],
        ["enemy_pic_58", "kelbeross_pic_59", "kelbeross_pic_5A"],
    ]),
    ("bloody_malth", "enemy", 0x1E, [
        ["bloody_malth_pic_", "enemy_pic_5E"],
        ["bloody_malth_lightning_"],
    ]),
    ("masked_devil", "enemy", 0x21, [
        ["masked_devil_pic_6A", "masked_devil_pic_6B"],
        ["masked_devil_pic_77"],
        ["masked_devil_fight_"],
    ]),
    ("jaquio", "enemy", 0x25, [
        ["jaquio_pic_70", "enemy_pic_6D", "enemy_pic_6E", "enemy_pic_6F"],
        ["jaquio_pic_73", "jaquio_pic_74", "enemy_pic_71", "enemy_pic_72"],
        ["enemy_pic_75", "enemy_pic_76"],
    ]),
    ("final_boss", "enemy", 0x28, [
        ["final_boss_pic_7C", "final_boss_pic_7D"],
        ["final_boss_pic_80", "final_boss_pic_81", "final_boss_pic_82", "final_boss_pic_83"],
        ["final_boss_fireballs_"],
    ]),
    ("explosion", "enemy", 0x17, [["explosion_"]]),
]


def parse_bytes(text):
    vals = []
    for line in text.splitlines():
        code = line.split(";", 1)[0]
        if ".byte" not in code:
            continue
        for tok in code.split(".byte", 1)[1].split(","):
            m = BYTE.search(tok)
            if not m:
                raise SystemExit(f"bad byte {tok!r}")
            if m.group(1) is not None:
                vals.append(int(m.group(1), 16))
            elif m.group(2) is not None:
                vals.append(int(m.group(2), 2))
            else:
                vals.append(int(m.group(3), 10))
    return vals


def parse_chr(path):
    data = bytes(parse_bytes(path.read_text()))
    if len(data) != 8192:
        raise SystemExit(f"{path}: {len(data)} bytes")
    return data


def labeled_bytes(path):
    """Label -> the .byte values that follow it, up to the next label."""
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
            mm = BYTE.search(tok)
            if not mm:
                continue
            if mm.group(1) is not None:
                buf.append(int(mm.group(1), 16))
            elif mm.group(2) is not None:
                buf.append(int(mm.group(2), 2))
            else:
                buf.append(int(mm.group(3), 10))
    if name is not None:
        out[name] = buf
        order.append(name)
    return out, order


def word_list(text, anchor):
    """Labels or $FFFF from the .word list that starts at a label."""
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
            m = BYTE.search(tok)
            if not m:
                continue
            if m.group(1) is not None:
                vals.append(int(m.group(1), 16))
            elif m.group(2) is not None:
                vals.append(int(m.group(2), 2))
            else:
                vals.append(int(m.group(3), 10))
    return vals


def signed(n):
    return n - 256 if n >= 128 else n


def tile_rows(data, tile):
    base = tile * 16
    rows = []
    for y in range(8):
        lo = data[base + y]
        hi = data[base + 8 + y]
        rows.append([((hi >> bit) & 1) << 1 | ((lo >> bit) & 1) for bit in range(7, -1, -1)])
    return rows


def piece_pixels(chr_even, chr_odd, tile, attr):
    """One 8x16 sprite. Bit 0 of the tile picks the pattern table:
    even tiles are in the sprite bank, odd tiles in the background bank."""
    bank = chr_odd if tile & 1 else chr_even
    top = tile & 0xFE
    rows = tile_rows(bank, top) + tile_rows(bank, top + 1)
    if attr & 0x80:
        rows = rows[::-1]
    if attr & 0x40:
        rows = [row[::-1] for row in rows]
    return rows


def picture(shape, colors):
    count = shape[0]
    triples = shape[1:1 + count * 3]
    if len(triples) < count * 3:
        raise SystemExit(f"picture wants {count} pieces, has {len(triples) // 3}")
    # The first color set is what he uses. A second set, when there is
    # one, follows it. A short list continues into the next picture.
    attrs = colors[:count]
    pieces = []
    for i in range(count):
        tile, x, y = triples[i * 3:i * 3 + 3]
        attr = attrs[i] if i < len(attrs) else 0
        pieces.append((tile, signed(x), signed(y), attr))
    return pieces


def bounds(pieces):
    if not pieces:
        return 0, 8, 0, 16
    xs = [p[1] for p in pieces]
    ys = [p[2] for p in pieces]
    return min(xs), max(xs) + 8, min(ys), max(ys) + 16


def blit(canvas, origin, pieces, pals, chr_even, chr_odd):
    ox, oy = origin
    # The first piece is first in OAM, so it is drawn in front.
    for tile, x, y, attr in reversed(pieces):
        pal = pals[attr & 3]
        rows = piece_pixels(chr_even, chr_odd, tile, attr)
        for ry, row in enumerate(rows):
            py = oy + y + ry
            if py < 0 or py >= len(canvas):
                continue
            for rx, val in enumerate(row):
                px = ox + x + rx
                if val == 0 or px < 0 or px >= len(canvas[0]):
                    continue
                canvas[py][px] = NES[pal[val - 1] & 0x3F]


def _chunk(tag, data):
    return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)


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


def draw_label(buf, width, x, y, text):
    for ch in text:
        glyph = FONT[ch]
        for gy, row in enumerate(glyph):
            for gx, bit in enumerate(row):
                if bit != "1":
                    continue
                for yy in range(LAB_SCALE):
                    base = ((y + gy * LAB_SCALE + yy) * width + x + gx * LAB_SCALE) * 3
                    for xx in range(LAB_SCALE):
                        o = base + xx * 3
                        buf[o:o + 3] = bytes(INK)
        x += 4 * LAB_SCALE


def render_sheet(rows):
    """rows: list of list of (pic_id, pieces, pals, chr_even, chr_odd)."""
    lab_h = 5 * LAB_SCALE + 4
    laid = []
    for row in rows:
        boxes = [bounds(p) for _, p, _, _, _ in row]
        miny = min(b[2] for b in boxes)
        maxy = max(b[3] for b in boxes)
        content_h = maxy - miny
        cell_h = lab_h + content_h * SCALE
        frames = []
        row_w = GAP
        for (pic, pieces, pals, chr_even, chr_odd), box in zip(row, boxes):
            fw = box[1] - box[0]
            canvas = [[OFF] * fw for _ in range(box[3] - box[2])]
            blit(canvas, (-box[0], -box[2]), pieces, pals, chr_even, chr_odd)
            # Same origin on the row, so a short frame lines up with a tall one.
            oy = (box[2] - miny) * SCALE
            cell_w = fw * SCALE
            frames.append((pic, canvas, oy, cell_w))
            row_w += cell_w + GAP
        laid.append((frames, row_w, cell_h))
    width = max(row_w for _, row_w, _ in laid)
    height = GAP + sum(cell_h + GAP for _, _, cell_h in laid)
    buf = bytearray(width * height * 3)
    for i in range(width * height):
        o = i * 3
        buf[o:o + 3] = bytes(BG)
    y0 = GAP
    for frames, _, cell_h in laid:
        x0 = GAP
        for pic, canvas, oy, cell_w in frames:
            draw_label(buf, width, x0 + 2, y0 + 2, f"{pic:02X}")
            ty = y0 + lab_h + oy
            for y, row in enumerate(canvas):
                for x, rgb in enumerate(row):
                    for dy in range(SCALE):
                        for dx in range(SCALE):
                            o = ((ty + y * SCALE + dy) * width + x0 + x * SCALE + dx) * 3
                            buf[o:o + 3] = bytes(rgb)
            x0 += cell_w + GAP
        y0 += cell_h + GAP
    return width, height, bytes(buf)


def room_of(foes, kind):
    for room, kinds in enumerate(foes):
        if kind in kinds:
            return room
    return None


def palettes_for(room, room_a, room_b, color_sets):
    def triple(index):
        return tuple(color_sets[index * 3:index * 3 + 3])
    return (triple(0), triple(1), triple(room_a[room]), triple(room_b[room]))


def banks_for(room, bg_pick, area_bg, first_room, chr_banks):
    """Sprite bank from the room, background bank from the area.
    prepare_area shifts the area's picture byte three times into $5A."""
    area = 0
    for i, start in enumerate(first_room):
        if start <= room:
            area = i
        else:
            break
    mmc = bg_pick[room] & 0x0F
    bg = area_bg[area] >> 3
    return mmc, chr_half(chr_banks, mmc), chr_half(chr_banks, bg)


def stamp(rows, table, room, by_table, bg_pick, area_bg, first_room,
          room_a, room_b, color_sets, chr_banks):
    mmc, even, odd = banks_for(room, bg_pick, area_bg, first_room, chr_banks)
    pals = palettes_for(room, room_a, room_b, color_sets)
    stamped = []
    for ids in rows:
        stamped.append([
            (pic, by_table[table][pic][1], pals, even, odd) for pic in ids
        ])
    return mmc, stamped


def chr_half(banks, mmc):
    return banks[mmc // 2][(mmc % 2) * 4096:(mmc % 2 + 1) * 4096]


def main():
    bank02 = (ROOT / "prg" / "bank02.asm").read_text()
    bank00 = (ROOT / "prg" / "bank00.asm").read_text()
    labels, order = labeled_bytes(ROOT / "prg" / "bank02.asm")
    # A short color list continues into the following picture's colors.
    flat = []
    starts = {}
    for name in order:
        starts[name] = len(flat)
        flat.extend(labels[name])

    def colors_of(name, count, offset=0):
        raw = flat[starts[name] + offset:starts[name] + offset + count]
        if len(raw) < count:
            raise SystemExit(f"{name}: {len(raw)} colors for {count} pieces")
        return raw

    def load_table(anchor_shape, anchor_color):
        shapes = word_list(bank02, anchor_shape)
        cols = word_list(bank02, anchor_color)
        pics = []
        for i, (shape_name, color_name) in enumerate(zip(shapes, cols)):
            if shape_name.startswith("$"):
                continue
            shape = labels[shape_name]
            count = shape[0]
            pieces = picture(shape, colors_of(color_name, count))
            pics.append((i, shape_name, pieces, color_name))
        return pics

    enemy = load_table("enemy_shape", "enemy_color")
    ryu = load_table("ryu_shape", "ryu_color")
    by_table = {"enemy": {i: (n, p, c) for i, n, p, c in enemy},
                "ryu": {i: (n, p, c) for i, n, p, c in ryu}}

    def pieces_at(pic, offset):
        shape_name, _, color_name = by_table["ryu"][pic]
        shape = labels[shape_name]
        return picture(shape, colors_of(color_name, shape[0], offset))

    foes = []
    n = 0
    while True:
        anchor = f"foe_kind_{n:02X}"
        if anchor + ":" not in bank02:
            break
        foes.append(byte_list(bank02, anchor))
        n += 1
    bg_pick = byte_list(bank00, "bg_pick")
    room_a = byte_list(bank00, "room_colors_a")
    room_b = byte_list(bank00, "room_colors_b")
    color_sets = byte_list(bank00, "room_color_set")

    chr_banks = [parse_chr(ROOT / "chr" / f"bank{i:02d}.asm") for i in range(8)]

    used = set()
    # These are the falling items, not poses. Picture $29 is the spark
    # that sits with them. The weapon icons stay on Ryu's sheet too.
    for pic in (0x19, 0x1A, 0x20, 0x21, 0x22, 0x29):
        used.add(("ryu", pic))
    OUT.mkdir(parents=True, exist_ok=True)
    first_room = byte_list(bank00, "first_room")
    area_bg = byte_list(bank00, "area_bg")

    for name, table, kind, row_prefixes in SHEETS:
        catalog = enemy if table == "enemy" else ryu
        # Longest prefix wins, so a bullet is not also a frame of the shooter.
        # Rows stay in the order written: the actor, then what he fires.
        chosen = [[] for _ in row_prefixes]
        for pic, label, *_ in catalog:
            if (table, pic) in used:
                continue
            best = None
            best_len = -1
            for r, prefixes in enumerate(row_prefixes):
                for p in prefixes:
                    if label.startswith(p) and len(p) > best_len:
                        best = r
                        best_len = len(p)
            if best is not None:
                chosen[best].append(pic)
                used.add((table, pic))
        rows = []
        for ids in chosen:
            ids.sort()
            if ids:
                rows.append([pic for pic in ids])
        if not rows:
            raise SystemExit(f"{name}: no pictures")
        room = room_of(foes, kind)
        if room is None:
            room = 0
            print(f"{name}: type ${kind:02X} is not placed in a room, using room 0")
        mmc, stamped = stamp(rows, table, room, by_table, bg_pick, area_bg,
                             first_room, room_a, room_b, color_sets, chr_banks)
        width, height, rgb = render_sheet(stamped)
        dest = OUT / f"{name}.png"
        write_png(dest, width, height, rgb)
        frames = sum(len(r) for r in rows)
        print(f"{dest.relative_to(ROOT)}  {width}x{height}  {frames} frames  "
              f"room {room:02X} chr ${mmc:02X}")

    # One row per lantern, in the area that hangs it. Later areas reuse a
    # picture index with their own background bank, so those are their own rows.
    anim = byte_list(bank00, "lantern_anim")
    seen = set()
    lantern_rows = []
    for area, action in enumerate(anim):
        start = first_room[area]
        end = first_room[area + 1] if area + 1 < len(first_room) else start + 1
        if all(labels[f"lantern_at_{room:02X}"][0] == 0xFF for room in range(start, end)):
            continue
        raw = labels[f"lantern_action_{action:02X}"]
        pics = []
        i = 0
        while i + 1 < len(raw) and raw[i] != 0:
            pics.append(raw[i + 1])
            i += 2
        room = first_room[area]
        _, even, odd = banks_for(room, bg_pick, area_bg, first_room, chr_banks)
        bg = area_bg[area] >> 3
        key = (tuple(pics), bg)
        if key in seen:
            continue
        seen.add(key)
        pals = palettes_for(room, room_a, room_b, color_sets)
        lantern_rows.append([
            (pic, by_table["ryu"][pic][1], pals, even, odd) for pic in pics
        ])
        for pic in pics:
            used.add(("ryu", pic))
    width, height, rgb = render_sheet(lantern_rows)
    dest = OUT / "lantern.png"
    write_png(dest, width, height, rgb)
    frames = sum(len(r) for r in lantern_rows)
    print(f"{dest.relative_to(ROOT)}  {width}x{height}  {frames} frames  "
          f"{len(lantern_rows)} lanterns")

    # One row per power-up. $E60D is the picture, and $E619's low bits pick
    # a later color set of that same picture (10 ninpo, 10 points).
    _, even, odd = banks_for(0, bg_pick, area_bg, first_room, chr_banks)
    pals = palettes_for(0, room_a, room_b, color_sets)
    pickup_rows = [
        [(pic, pieces_at(pic, offset), pals, even, odd)]
        for pic, offset in PICKUPS
    ]
    width, height, rgb = render_sheet(pickup_rows)
    dest = OUT / "pickup.png"
    write_png(dest, width, height, rgb)
    print(f"{dest.relative_to(ROOT)}  {width}x{height}  {len(PICKUPS)} frames")

    left = []
    for table, catalog in (("enemy", enemy), ("ryu", ryu)):
        for pic, label, *_ in catalog:
            if (table, pic) not in used:
                left.append(f"{table} ${pic:02X} {label}")
    if left:
        print("not on a sheet:")
        for item in left:
            print(" ", item)


if __name__ == "__main__":
    main()
