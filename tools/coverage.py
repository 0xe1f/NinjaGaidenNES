#!/usr/bin/env python3
# Disassembly progress for Shields.io. Not test coverage.
#
#   tools/coverage.py                  # print the report
#   tools/coverage.py --json
#   tools/coverage.py --badges DIR     # endpoint JSON (and coverage.md)
#
# The 16-byte iNES header is outside the KiB total. A remaining auto
# label is one letter plus four hex digits (l8002, b800F). Op comments
# are instruction lines with a ';'. Sub comments are named jsr targets
# whose next real line is an opcode and whose lines above include a
# comment with a letter. @ locals are named. jmp targets are not subs.

import argparse
import json
import re
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PRG_SIZE = 16 * 1024
CHR_SIZE = 8 * 1024
HEADER = 16
PRG_BANKS = 8
CHR_BANKS = 16

AUTO_NAME = re.compile(r"^[A-Za-z][0-9A-Fa-f]{4}$")
LABEL_DEF = re.compile(r"^[ \t]*([A-Za-z_@.][\w.]*)[ \t]*:")
INCBIN = re.compile(
    r'\.incbin[ \t]+"([^"]+)"'
    r"(?:[ \t]*,[ \t]*([^,;\n]+)"
    r"(?:[ \t]*,[ \t]*([^,;\n]+))?)?",
    re.I,
)
OPCODE = re.compile(
    r"""^[ \t]*
        (?:[A-Za-z_@.][\w.]*[ \t]*:[ \t]*)?
        (adc|and|asl|bcc|bcs|beq|bit|bmi|bne|bpl|brk|bvc|bvs|clc|cld|
         cli|clv|cmp|cpx|cpy|dec|dex|dey|eor|inc|inx|iny|jmp|jsr|lda|
         ldx|ldy|lsr|nop|ora|pha|php|pla|plp|rol|ror|rti|rts|sbc|sec|
         sed|sei|sta|stx|sty|tax|tay|tsx|txa|txs|tya)
        \b
    """,
    re.I | re.X,
)
JSR_TGT = re.compile(r"\bjsr[ \t]+([A-Za-z_@.][\w.]*)\b", re.I)
BIN_NAME = re.compile(r"(prg|chr)/(bank\d+)\.bin$", re.I)


def _code(line: str) -> str:
    return line.split(";", 1)[0]


def _is_auto(name: str) -> bool:
    return bool(AUTO_NAME.match(name))


def _int_tok(s: str) -> int:
    s = s.strip().replace("_", "")
    if s.lower().startswith("$"):
        return int(s[1:], 16)
    if s.lower().startswith("0x"):
        return int(s, 16)
    return int(s, 0)


def _bin_size(rel: str) -> int:
    path = ROOT / rel
    if path.is_file():
        return path.stat().st_size
    m = BIN_NAME.fullmatch(rel)
    if not m:
        return 0
    return PRG_SIZE if m.group(1).lower() == "prg" else CHR_SIZE


def _incbin_len(rel: str, off: str | None, length: str | None) -> int:
    size = _bin_size(rel)
    if not size:
        return 0
    o = _int_tok(off) if off and off.strip() else 0
    if length and length.strip():
        return max(0, _int_tok(length))
    return max(0, size - o)


def _window_for_file(path: Path) -> str | None:
    try:
        rel = path.resolve().relative_to(ROOT)
    except ValueError:
        return None
    if len(rel.parts) == 2 and rel.parts[0] in {"prg", "chr"}:
        if re.fullmatch(r"bank\d{2}", path.stem):
            return f"{rel.parts[0]}/{path.stem}"
    return None


def _window_for_bin(rel: str) -> str | None:
    m = BIN_NAME.fullmatch(rel)
    if not m:
        return None
    return f"{m.group(1).lower()}/{m.group(2).lower()}"


def _source_files() -> list[Path]:
    found: list[Path] = []
    master = ROOT / "NinjaGaiden.asm"
    if master.is_file():
        found.append(master)
    for folder in ("prg", "chr"):
        directory = ROOT / folder
        if not directory.is_dir():
            continue
        for path in sorted(directory.rglob("*")):
            if path.suffix.lower() in {".asm", ".inc"} and path.is_file():
                found.append(path)
    return found


def _next_is_opcode(lines: list[str], i: int) -> bool:
    rest = lines[i].split(":", 1)[-1]
    if OPCODE.match(rest):
        return True
    j = i + 1
    while j < len(lines):
        if not _code(lines[j]).strip():
            j += 1
            continue
        return bool(OPCODE.match(lines[j]))
    return False


def _preceded_by_docs(lines: list[str], i: int) -> bool:
    j = i - 1
    while j >= 0 and not lines[j].strip():
        j -= 1
    saw = False
    while j >= 0:
        s = lines[j].strip()
        if not s:
            j -= 1
            continue
        if s.startswith(";"):
            if re.search(r"[A-Za-z]", s[1:]):
                saw = True
            j -= 1
            continue
        break
    return saw


def _rom_bytes() -> int:
    return PRG_BANKS * PRG_SIZE + CHR_BANKS * CHR_SIZE


def scan() -> dict:
    rom_bytes = _rom_bytes()
    incbin_by_path: dict[str, int] = {}
    auto_keys: set[tuple[str, str]] = set()
    auto_by_window: dict[str, set[str]] = defaultdict(set)
    incbin_by_window: dict[str, int] = defaultdict(int)
    call_targets: set[str] = set()
    file_lines: list[tuple[Path, str | None, list[str]]] = []
    opcodes = 0
    commented = 0

    for path in _source_files():
        lines = path.read_text(errors="replace").splitlines()
        win = _window_for_file(path)
        file_lines.append((path, win, lines))
        for line in lines:
            code = _code(line)
            label = LABEL_DEF.match(code)
            if label and _is_auto(label.group(1)):
                name = label.group(1).lower()
                auto_keys.add((str(path), name))
                if win:
                    auto_by_window[win].add(name)
            inc = INCBIN.search(code)
            if inc:
                n = _incbin_len(inc.group(1), inc.group(2), inc.group(3))
                key = inc.group(1)
                incbin_by_path[key] = max(incbin_by_path.get(key, 0), n)
                bin_win = _window_for_bin(key)
                if bin_win:
                    incbin_by_window[bin_win] += n
            if not OPCODE.match(line):
                continue
            opcodes += 1
            if ";" in line:
                commented += 1
            for m in JSR_TGT.finditer(code):
                tgt = m.group(1)
                if not _is_auto(tgt):
                    call_targets.add(tgt.lower())

    subs = 0
    subs_doc = 0
    subs_by_window: dict[str, list[int]] = defaultdict(lambda: [0, 0])
    seen_subs: set[tuple[str, str]] = set()
    for path, win, lines in file_lines:
        for i, line in enumerate(lines):
            label = LABEL_DEF.match(_code(line))
            if not label:
                continue
            name = label.group(1)
            key = name.lower()
            if _is_auto(name) or key not in call_targets:
                continue
            if not _next_is_opcode(lines, i):
                continue
            ident = (str(path), key)
            if ident in seen_subs:
                continue
            seen_subs.add(ident)
            subs += 1
            doc = _preceded_by_docs(lines, i)
            if doc:
                subs_doc += 1
            if win:
                subs_by_window[win][0] += 1
                if doc:
                    subs_by_window[win][1] += 1

    # Stale bank bins from `make banks` stay on disk after that bank is
    # source. Only bytes still named by .incbin count as leftover.
    leftover = min(rom_bytes, sum(incbin_by_path.values()))
    labelled = max(0, rom_bytes - leftover)
    pct = round(100.0 * commented / opcodes, 1) if opcodes else 0.0
    subs_pct = round(100.0 * subs_doc / subs, 1) if subs else 0.0

    windows = []
    for name in sorted(set(auto_by_window) | set(incbin_by_window) | set(subs_by_window)):
        nsub, ndoc = subs_by_window.get(name, [0, 0])
        windows.append(
            {
                "name": name,
                "incbin": incbin_by_window.get(name, 0),
                "auto": len(auto_by_window.get(name, ())),
                "subs": nsub,
                "subs_doc": ndoc,
            }
        )

    return {
        "rom_bytes": rom_bytes,
        "header_bytes": HEADER,
        "labelled_bytes": labelled,
        "incbin_bytes": leftover,
        "auto_labels": len(auto_keys),
        "opcodes": opcodes,
        "commented": commented,
        "comment_pct": pct,
        "subs": subs,
        "subs_doc": subs_doc,
        "subs_pct": subs_pct,
        "windows": windows,
    }


def _kib(n: int) -> str:
    if n % 1024 == 0:
        return str(n // 1024)
    return f"{n / 1024:.1f}"


def _in_source_color(labelled: int, rom: int) -> str:
    if rom <= 0:
        return "lightgrey"
    if labelled >= rom:
        return "brightgreen"
    if labelled * 2 >= rom:
        return "yellow"
    return "orange"


def _named_color(n: int) -> str:
    if n == 0:
        return "brightgreen"
    if n <= 50:
        return "yellow"
    if n <= 200:
        return "orange"
    return "red"


def _comment_color(pct: float) -> str:
    if pct >= 50:
        return "brightgreen"
    if pct >= 20:
        return "yellow"
    if pct >= 5:
        return "orange"
    return "lightgrey"


def _badge_part(text: str) -> str:
    # Shields turns _ into a space, -- into a dash, and %2F into a slash.
    text = text.replace("%", "%25")
    text = text.replace("_", "__")
    text = text.replace("-", "--")
    text = text.replace(" ", "_")
    return text.replace("/", "%2F")


def static_badge_url(label: str, message: str, color: str) -> str:
    return (
        "https://img.shields.io/badge/"
        f"{_badge_part(label)}-{_badge_part(message)}-{color}?style=flat"
    )


def _endpoint(label: str, message: str, color: str) -> dict:
    return {
        "schemaVersion": 1,
        "label": label,
        "message": message,
        "color": color,
        "cacheSeconds": 300,
    }


def badge_fields(stats: dict) -> list[tuple[str, str, str]]:
    rom = stats["rom_bytes"]
    lab = stats["labelled_bytes"]
    auto = stats["auto_labels"]
    pct = stats["comment_pct"]
    return [
        ("in source", f"{_kib(lab)} / {_kib(rom)} KiB", _in_source_color(lab, rom)),
        ("named", f"{auto} left", _named_color(auto)),
        ("op comments", f"{pct:g}%", _comment_color(pct)),
        (
            "sub comments",
            f"{stats['subs_doc']} / {stats['subs']}",
            _comment_color(stats["subs_pct"]),
        ),
    ]


def badge_payloads(stats: dict) -> dict[str, dict]:
    names = {
        "in source": "in-source.json",
        "named": "named.json",
        "op comments": "op-comments.json",
        "sub comments": "sub-comments.json",
    }
    return {
        names[label]: _endpoint(label, message, color)
        for label, message, color in badge_fields(stats)
    }


def update_readme(path: Path, stats: dict) -> bool:
    # The repo is private, so Shields cannot fetch JSON from it. The
    # numbers live in the image URL instead.
    text = path.read_text()
    original = text
    for label, message, color in badge_fields(stats):
        url = static_badge_url(label, message, color)
        pattern = re.compile(
            r"(\[!\[)" + re.escape(label) + r"(\]\()[^)]+(\)\])"
        )
        text, n = pattern.subn(r"\1" + label + r"\2" + url + r"\3", text, count=1)
        if n != 1:
            raise SystemExit(f"README is missing the {label} shield")
    if text == original:
        return False
    path.write_text(text)
    return True


def write_badges(dest: Path, stats: dict) -> None:
    dest.mkdir(parents=True, exist_ok=True)
    (dest / "coverage.json").write_text(json.dumps(stats, indent=2) + "\n")
    (dest / "coverage.md").write_text(render(stats))
    for name, payload in badge_payloads(stats).items():
        (dest / name).write_text(json.dumps(payload, indent=2) + "\n")


def render(stats: dict) -> str:
    lines = [
        f"In source: {_kib(stats['labelled_bytes'])} / {_kib(stats['rom_bytes'])} KiB labelled `.asm`",
        f"Named: {stats['auto_labels']} auto labels left",
        f"Op comments: {stats['comment_pct']:g}% of opcode lines",
        f"Sub comments: {stats['subs_doc']} / {stats['subs']} preceded by docs",
    ]
    rows = [
        w
        for w in stats["windows"]
        if w["incbin"] > 0
        or w["auto"] > 0
        or (w.get("subs", 0) and w.get("subs_doc", 0) < w["subs"])
    ]
    if rows:
        lines.append("")
        lines.append("| Bank | INCBIN | Auto left | Sub comments |")
        lines.append("|---|---|---|---|")
        for w in rows:
            inc = f"{_kib(w['incbin'])} KiB" if w["incbin"] else "—"
            auto = w["auto"] or "—"
            nsub = w.get("subs", 0)
            subs = f"{w.get('subs_doc', 0)} / {nsub}" if nsub else "—"
            lines.append(f"| `{w['name']}` | {inc} | {auto} | {subs} |")
    return "\n".join(lines) + "\n"


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Disassembly progress badges")
    parser.add_argument("--badges", metavar="DIR", help="write Shields.io JSON here")
    parser.add_argument(
        "--readme",
        metavar="PATH",
        help="rewrite the coverage shield URLs in this file",
    )
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args(argv)
    stats = scan()
    if args.json:
        print(json.dumps(stats, indent=2))
    else:
        sys.stdout.write(render(stats))
    if args.badges:
        dest = Path(args.badges)
        if not dest.is_absolute():
            dest = ROOT / dest
        write_badges(dest, stats)
    if args.readme:
        readme = Path(args.readme)
        if not readme.is_absolute():
            readme = ROOT / readme
        update_readme(readme, stats)
    return 0


if __name__ == "__main__":
    sys.exit(main())
