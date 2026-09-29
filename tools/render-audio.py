#!/usr/bin/env python3
"""Render every Ninja Gaiden sound to audio/music and audio/sfx.

Each piece is played by the game's own driver (PRG bank 03, with the drum
samples from bank 07). A repeating drum or bass figure keeps going until
every part of the piece has been heard once. The render stops when the
last part reaches the jump that would play it again. Effects that never
jump play until they go quiet.

Build NinjaGaiden.nes first (`make`). Writes 44100 Hz 16-bit mono WAV files.
"""

import argparse
import struct
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CPU_HZ = 1789773.0
FRAME_CYCLES = 29780.5
SAMPLE_RATE = 44100

READ_BYTE = 0x82CD
SOUND_JUMP = 0x83FA
SILENCE = 0x84D7
PLAY_SOUNDS = 0x8000
SOUND_LIST = 0x877D
SOUND_COUNT = 0x50

# Stage themes. The slug is the first place that theme is heard.
STAGE = {
    0x03: "act1-stage1",
    0x04: "act2-stage1",
    0x05: "act2-stage2",
    0x06: "act1-stage2",
    0x07: "act5-stage1",
    0x0B: "act3-stage2",
    0x0C: "act4-stage2",
    0x2B: "act6-stage4",
    0x2D: "act3-stage1",
    0x30: "act4-stage3",
    0x31: "act5-stage3",
}

EFFECT = {
    0x02: "cutscene-end",
    0x08: "thrown-weapon",
    0x0E: "jaquio",
    0x0F: "jump",
    0x11: "hurt",
    0x12: "enemy-dies",
    0x13: "pickup",
    0x14: "one-up",
    0x15: "health",
    0x16: "fire-wheel-burn",
    0x17: "star",
    0x18: "windmill",
    0x19: "fire-wheel",
    0x1A: "spinning-sword",
    0x1B: "beep",
    0x1C: "sickle",
    0x1E: "lightning",
    0x20: "gun",
    0x21: "crouch-shot",
    0x23: "lose-life",
    0x24: "start",
    0x35: "sword",
    0x3F: "hit",
    0x40: "boss-explode",
    0x41: "basaquer",
}

DUTY = (
    (0, 0, 0, 0, 0, 0, 0, 1),
    (0, 0, 0, 0, 0, 0, 1, 1),
    (0, 0, 0, 0, 1, 1, 1, 1),
    (1, 1, 1, 1, 1, 1, 0, 0),
)
TRI_SEQ = (
    15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
)
NOISE_PERIOD = (
    4, 8, 16, 32, 64, 96, 128, 160, 202, 254, 380, 508, 762, 1016, 2034, 4068,
)
DMC_RATE = (
    428, 380, 340, 320, 286, 254, 226, 214, 190, 160, 142, 128, 106, 84, 72, 54,
)
LENGTH = (
    10, 254, 20, 2, 40, 4, 80, 6, 160, 8, 60, 10, 14, 12, 26, 14,
    12, 16, 24, 18, 48, 20, 96, 22, 192, 24, 72, 26, 16, 28, 32, 30,
)

C, Z, I, D, V, N = 0x01, 0x02, 0x04, 0x08, 0x40, 0x80


def load_prg():
    nes = ROOT / "NinjaGaiden.nes"
    if not nes.exists():
        nes = ROOT / "reference" / "gaiden.nes"
    data = nes.read_bytes()
    if data[:4] != b"NES\x1a":
        raise SystemExit(f"{nes} is not an iNES ROM")
    bank3 = data[16 + 3 * 16384:16 + 4 * 16384]
    bank7 = data[16 + 7 * 16384:16 + 8 * 16384]
    prg = bytearray(bank3 + bank7)
    if prg[0] != 0xA2:
        raise SystemExit("bank 03 does not start at play_sounds")
    return prg


class APU:
    def __init__(self, prg):
        self.prg = prg
        self.reset()

    def reset(self):
        self.reg = [0] * 0x18
        self.length = [0, 0, 0, 0]
        self.phase = [0.0, 0.0, 0.0, 0.0]
        self.env = [0, 0, 0, 0]
        self.env_div = [0, 0, 0, 0]
        self.env_start = [False, False, False, False]
        self.linear = 0
        self.linear_reload = False
        self.sweep_div = [0, 0]
        self.sweep_reload = [False, False]
        self.noise_shift = 1
        self.noise_acc = 0.0
        self.dmc_addr = 0
        self.dmc_bytes = 0
        self.dmc_bits = 0
        self.dmc_cur = 0
        self.dmc_out = 0
        self.dmc_timer = 0.0
        self.hp = 0.0
        self.prev = 0.0

    def write(self, addr, val):
        idx = addr - 0x4000
        self.reg[idx] = val
        if addr in (0x4003, 0x4007, 0x400B, 0x400F):
            ch = idx // 4
            self.length[ch] = LENGTH[(val >> 3) & 31]
            self.phase[ch] = 0.0
            if ch < 2 or ch == 3:
                self.env_start[ch] = True
            if ch == 2:
                self.linear_reload = True
        elif addr in (0x4001, 0x4005):
            self.sweep_reload[(addr - 0x4001) // 4] = True
        elif addr == 0x4015:
            if val & 0x10:
                if self.dmc_bytes == 0 and self.dmc_bits == 0:
                    self._start_dmc()
            else:
                self.dmc_bytes = 0
                self.dmc_bits = 0

    def read_status(self):
        bit = 0x10 if (self.dmc_bytes or self.dmc_bits) else 0
        return bit

    def _start_dmc(self):
        self.dmc_addr = 0xC000 + self.reg[0x12] * 64
        self.dmc_bytes = self.reg[0x13] * 16 + 1
        self.dmc_bits = 0
        self.dmc_timer = DMC_RATE[self.reg[0x10] & 0x0F]

    def _timer(self, ch):
        base = ch * 4
        return self.reg[base + 2] | ((self.reg[base + 3] & 7) << 8)

    def _set_timer(self, ch, period):
        base = ch * 4
        self.reg[base + 2] = period & 0xFF
        self.reg[base + 3] = (self.reg[base + 3] & 0xF8) | ((period >> 8) & 7)

    def _clock_sweep(self, ch):
        reg = self.reg[1 + ch * 4]
        shift = reg & 7
        period = self._timer(ch)
        change = period >> shift
        if reg & 0x08:
            change = -change - (1 if ch == 0 else 0)
        target = period + change
        if self.sweep_div[ch] == 0 and (reg & 0x80) and shift and 8 <= period and target < 0x800:
            self._set_timer(ch, target & 0x7FF)
        if self.sweep_div[ch] == 0 or self.sweep_reload[ch]:
            self.sweep_div[ch] = (reg >> 4) & 7
            self.sweep_reload[ch] = False
        else:
            self.sweep_div[ch] -= 1

    def _sweep_mute(self, ch):
        reg = self.reg[1 + ch * 4]
        period = self._timer(ch)
        if period < 8:
            return True
        if (reg & 0x80) and (reg & 7):
            change = period >> (reg & 7)
            if reg & 0x08:
                change = -change - (1 if ch == 0 else 0)
            if period + change > 0x7FF:
                return True
        return False

    def _clock_envelope(self, ch):
        reg = self.reg[ch * 4]
        if self.env_start[ch]:
            self.env_start[ch] = False
            self.env[ch] = 15
            self.env_div[ch] = reg & 0x0F
            return
        if self.env_div[ch] == 0:
            self.env_div[ch] = reg & 0x0F
            if self.env[ch] > 0:
                self.env[ch] -= 1
            elif reg & 0x20:
                self.env[ch] = 15
        else:
            self.env_div[ch] -= 1

    def _clock_linear(self):
        if self.linear_reload:
            self.linear = self.reg[0x08] & 0x7F
        elif self.linear:
            self.linear -= 1
        if not (self.reg[0x08] & 0x80):
            self.linear_reload = False

    def _clock_length(self, ch):
        halt = self.reg[0x08] & 0x80 if ch == 2 else self.reg[ch * 4] & 0x20
        if not halt and self.length[ch]:
            self.length[ch] -= 1

    def _quarter(self):
        self._clock_envelope(0)
        self._clock_envelope(1)
        self._clock_envelope(3)
        self._clock_linear()

    def _half(self):
        self._clock_length(0)
        self._clock_length(1)
        self._clock_length(2)
        self._clock_length(3)
        self._clock_sweep(0)
        self._clock_sweep(1)

    def _pulse_level(self, ch):
        if not (self.reg[0x15] & (1 << ch)):
            return 0
        if self.length[ch] == 0 or self._sweep_mute(ch):
            return 0
        reg = self.reg[ch * 4]
        if reg & 0x10:
            return reg & 0x0F
        return self.env[ch]

    def _noise_level(self):
        if not (self.reg[0x15] & 0x08) or self.length[3] == 0:
            return 0
        reg = self.reg[0x0C]
        if reg & 0x10:
            return reg & 0x0F
        return self.env[3]

    def _dmc_clock(self, cycles):
        if self.dmc_bytes == 0 and self.dmc_bits == 0:
            return
        self.dmc_timer -= cycles
        rate = DMC_RATE[self.reg[0x10] & 0x0F]
        while self.dmc_timer <= 0 and (self.dmc_bytes or self.dmc_bits):
            self.dmc_timer += rate
            if self.dmc_bits == 0:
                self.dmc_cur = self.prg[self.dmc_addr - 0x8000]
                self.dmc_addr = self.dmc_addr + 1
                if self.dmc_addr > 0xFFFF:
                    self.dmc_addr = 0x8000
                self.dmc_bytes -= 1
                self.dmc_bits = 8
            if self.dmc_cur & 1:
                if self.dmc_out <= 125:
                    self.dmc_out += 2
            elif self.dmc_out >= 2:
                self.dmc_out -= 2
            self.dmc_cur >>= 1
            self.dmc_bits -= 1

    def render(self, n, out):
        """Append n samples. Frame-counter clocks fall during the frame."""
        if n <= 0:
            return
        cyc = CPU_HZ / SAMPLE_RATE
        marks = (
            int(n * 7457 / FRAME_CYCLES),
            int(n * 14913 / FRAME_CYCLES),
            int(n * 22371 / FRAME_CYCLES),
        )
        tri_on = (self.reg[0x15] & 0x04) and self.length[2] and self.linear and self._timer(2) >= 2
        p1 = self._pulse_level(0)
        p2 = self._pulse_level(1)
        noi = self._noise_level()
        duty1 = DUTY[(self.reg[0x00] >> 6) & 3]
        duty2 = DUTY[(self.reg[0x04] >> 6) & 3]
        t1 = self._timer(0)
        t2 = self._timer(1)
        tt = self._timer(2)
        step1 = (CPU_HZ / SAMPLE_RATE) / (2.0 * (t1 + 1)) if t1 else 0.0
        step2 = (CPU_HZ / SAMPLE_RATE) / (2.0 * (t2 + 1)) if t2 else 0.0
        stept = (CPU_HZ / SAMPLE_RATE) / (tt + 1) if tt else 0.0
        nreg = self.reg[0x0E]
        nper = NOISE_PERIOD[nreg & 0x0F]
        nmode = 6 if nreg & 0x80 else 1
        ph1, ph2, pht = self.phase[0], self.phase[1], self.phase[2]
        shift = self.noise_shift
        nacc = self.noise_acc
        hp, prev = self.hp, self.prev
        dmc = self.dmc_out
        for i in range(n):
            if i == marks[0] or i == marks[2]:
                self._quarter()
            elif i == marks[1]:
                self._quarter()
                self._half()
                t1 = self._timer(0)
                t2 = self._timer(1)
                step1 = (CPU_HZ / SAMPLE_RATE) / (2.0 * (t1 + 1)) if t1 else 0.0
                step2 = (CPU_HZ / SAMPLE_RATE) / (2.0 * (t2 + 1)) if t2 else 0.0
                p1 = self._pulse_level(0)
                p2 = self._pulse_level(1)
                tri_on = (self.reg[0x15] & 0x04) and self.length[2] and self.linear and self._timer(2) >= 2
            self._dmc_clock(cyc)
            dmc = self.dmc_out
            s1 = duty1[int(ph1) & 7] * p1 if p1 else 0
            s2 = duty2[int(ph2) & 7] * p2 if p2 else 0
            ph1 += step1
            ph2 += step2
            st = TRI_SEQ[int(pht) & 31] if tri_on else 0
            pht += stept
            nacc += cyc
            while nacc >= nper:
                nacc -= nper
                bit = (shift & 1) ^ ((shift >> nmode) & 1)
                shift = (shift >> 1) | (bit << 14)
            sn = noi if (shift & 1) == 0 else 0
            pulse = s1 + s2
            pout = 95.88 / (8128.0 / pulse + 100.0) if pulse else 0.0
            tnd = st / 8227.0 + sn / 12241.0 + dmc / 22638.0
            tout = 159.79 / (1.0 / tnd + 100.0) if tnd else 0.0
            x = pout + tout
            y = x - prev + 0.995 * hp
            prev = x
            hp = y
            out.append(y)
        self.phase[0], self.phase[1], self.phase[2] = ph1, ph2, pht
        self.noise_shift = shift
        self.noise_acc = nacc
        self.hp, self.prev = hp, prev
        # The last quarter-and-half of the frame counter lands just past this frame.
        self._quarter()
        self._half()


class CPU:
    def __init__(self, prg, apu):
        self.prg = prg
        self.apu = apu
        self.ram = bytearray(0x800)
        self.a = self.x = self.y = 0
        self.sp = 0xFF
        self.pc = 0
        self.p = 0x20
        self.seen = [set() for _ in range(8)]
        self.looped = False
        self.must_finish = set()
        self.looped_tracks = set()
        self.ended_tracks = set()
        self.song_done = False

    def reset_sound(self):
        self.ram = bytearray(0x800)
        self.a = self.x = self.y = 0
        self.sp = 0xFF
        self.p = 0x20
        self.seen = [set() for _ in range(8)]
        self.looped = False
        self.must_finish = set()
        self.looped_tracks = set()
        self.ended_tracks = set()
        self.song_done = False
        self.apu.reset()

    def _accounted(self):
        return self.must_finish <= (self.looped_tracks | self.ended_tracks)

    def flag(self, mask, on):
        if on:
            self.p |= mask
        else:
            self.p &= ~mask

    def set_nz(self, value):
        value &= 0xFF
        self.flag(Z, value == 0)
        self.flag(N, value & 0x80)
        return value

    def read(self, addr):
        if addr < 0x2000:
            return self.ram[addr & 0x07FF]
        if addr == 0x4015:
            return self.apu.read_status()
        if 0x4000 <= addr < 0x4018:
            return self.apu.reg[addr - 0x4000]
        if addr >= 0x8000:
            return self.prg[addr - 0x8000]
        return 0

    def write(self, addr, val):
        val &= 0xFF
        if addr < 0x2000:
            self.ram[addr & 0x07FF] = val
        elif 0x4000 <= addr < 0x4018:
            self.apu.write(addr, val)

    def push(self, val):
        self.ram[0x100 + self.sp] = val & 0xFF
        self.sp = (self.sp - 1) & 0xFF

    def pop(self):
        self.sp = (self.sp + 1) & 0xFF
        return self.ram[0x100 + self.sp]

    def fetch(self):
        val = self.read(self.pc)
        self.pc = (self.pc + 1) & 0xFFFF
        return val

    def fetch16(self):
        lo = self.fetch()
        hi = self.fetch()
        return lo | (hi << 8)

    def zp16(self, addr):
        return self.ram[addr] | (self.ram[(addr + 1) & 0xFF] << 8)

    def adc(self, val):
        a = self.a
        total = a + val + (self.p & C)
        self.flag(C, total > 0xFF)
        result = total & 0xFF
        self.flag(V, (~(a ^ val) & (a ^ result) & 0x80) != 0)
        self.a = self.set_nz(result)

    def sbc(self, val):
        self.adc(val ^ 0xFF)

    def cmp(self, reg, val):
        self.flag(C, reg >= val)
        self.set_nz(reg - val)

    def branch(self, take):
        off = self.fetch()
        if take:
            if off & 0x80:
                off -= 0x100
            self.pc = (self.pc + off) & 0xFFFF

    def step(self):
        if self.pc == READ_BYTE:
            track = self.ram[0xF2] >> 2
            if track < 8:
                self.seen[track].add((self.zp16(0xF4) + self.y) & 0xFFFF)
        elif self.pc == SILENCE:
            track = self.ram[0xF2] >> 2
            if track < 8:
                self.ended_tracks.add(track)
        elif self.pc == SOUND_JUMP:
            ptr = (self.zp16(0xF4) + self.y) & 0xFFFF
            target = self.read(ptr) | (self.read((ptr + 1) & 0xFFFF) << 8)
            here = (ptr - 1) & 0xFFFF
            track = self.ram[0xF2] >> 2
            # A jump back to a point this track already played is a loop.
            # A drum or bass figure may loop many times. The piece is over
            # once every track has either looped or ended.
            if track < 8 and target in self.seen[track] and target <= here:
                self.looped = True
                self.looped_tracks.add(track)
                # The last part to loop ends the piece. Earlier parts keep looping
                # until then, so a drum figure does not drop out halfway through.
                if self.must_finish and self._accounted():
                    self.song_done = True
                    self.pc = SILENCE
        op = self.fetch()
        self._op(op)

    def _op(self, op):
        a = self.a
        if op == 0xA9:
            self.a = self.set_nz(self.fetch())
        elif op == 0xA5:
            self.a = self.set_nz(self.read(self.fetch()))
        elif op == 0xB5:
            self.a = self.set_nz(self.read((self.fetch() + self.x) & 0xFF))
        elif op == 0xAD:
            self.a = self.set_nz(self.read(self.fetch16()))
        elif op == 0xBD:
            self.a = self.set_nz(self.read((self.fetch16() + self.x) & 0xFFFF))
        elif op == 0xB9:
            self.a = self.set_nz(self.read((self.fetch16() + self.y) & 0xFFFF))
        elif op == 0xA1:
            z = (self.fetch() + self.x) & 0xFF
            addr = self.ram[z] | (self.ram[(z + 1) & 0xFF] << 8)
            self.a = self.set_nz(self.read(addr))
        elif op == 0xB1:
            z = self.fetch()
            addr = self.ram[z] | (self.ram[(z + 1) & 0xFF] << 8)
            self.a = self.set_nz(self.read((addr + self.y) & 0xFFFF))
        elif op == 0xA2:
            self.x = self.set_nz(self.fetch())
        elif op == 0xA6:
            self.x = self.set_nz(self.read(self.fetch()))
        elif op == 0xB6:
            self.x = self.set_nz(self.read((self.fetch() + self.y) & 0xFF))
        elif op == 0xAE:
            self.x = self.set_nz(self.read(self.fetch16()))
        elif op == 0xBE:
            self.x = self.set_nz(self.read((self.fetch16() + self.y) & 0xFFFF))
        elif op == 0xA0:
            self.y = self.set_nz(self.fetch())
        elif op == 0xA4:
            self.y = self.set_nz(self.read(self.fetch()))
        elif op == 0xB4:
            self.y = self.set_nz(self.read((self.fetch() + self.x) & 0xFF))
        elif op == 0xAC:
            self.y = self.set_nz(self.read(self.fetch16()))
        elif op == 0xBC:
            self.y = self.set_nz(self.read((self.fetch16() + self.x) & 0xFFFF))
        elif op == 0x85:
            self.write(self.fetch(), a)
        elif op == 0x95:
            self.write((self.fetch() + self.x) & 0xFF, a)
        elif op == 0x8D:
            self.write(self.fetch16(), a)
        elif op == 0x9D:
            self.write((self.fetch16() + self.x) & 0xFFFF, a)
        elif op == 0x99:
            self.write((self.fetch16() + self.y) & 0xFFFF, a)
        elif op == 0x81:
            z = (self.fetch() + self.x) & 0xFF
            addr = self.ram[z] | (self.ram[(z + 1) & 0xFF] << 8)
            self.write(addr, a)
        elif op == 0x91:
            z = self.fetch()
            addr = self.ram[z] | (self.ram[(z + 1) & 0xFF] << 8)
            self.write((addr + self.y) & 0xFFFF, a)
        elif op == 0x86:
            self.write(self.fetch(), self.x)
        elif op == 0x96:
            self.write((self.fetch() + self.y) & 0xFF, self.x)
        elif op == 0x8E:
            self.write(self.fetch16(), self.x)
        elif op == 0x84:
            self.write(self.fetch(), self.y)
        elif op == 0x94:
            self.write((self.fetch() + self.x) & 0xFF, self.y)
        elif op == 0x8C:
            self.write(self.fetch16(), self.y)
        elif op == 0xAA:
            self.x = self.set_nz(a)
        elif op == 0xA8:
            self.y = self.set_nz(a)
        elif op == 0x8A:
            self.a = self.set_nz(self.x)
        elif op == 0x98:
            self.a = self.set_nz(self.y)
        elif op == 0xBA:
            self.x = self.set_nz(self.sp)
        elif op == 0x9A:
            self.sp = self.x
        elif op == 0x48:
            self.push(a)
        elif op == 0x68:
            self.a = self.set_nz(self.pop())
        elif op == 0x08:
            self.push(self.p | 0x30)
        elif op == 0x28:
            self.p = (self.pop() & ~0x10) | 0x20
        elif op == 0x29:
            self.a = self.set_nz(a & self.fetch())
        elif op == 0x25:
            self.a = self.set_nz(a & self.read(self.fetch()))
        elif op == 0x35:
            self.a = self.set_nz(a & self.read((self.fetch() + self.x) & 0xFF))
        elif op == 0x2D:
            self.a = self.set_nz(a & self.read(self.fetch16()))
        elif op == 0x3D:
            self.a = self.set_nz(a & self.read((self.fetch16() + self.x) & 0xFFFF))
        elif op == 0x39:
            self.a = self.set_nz(a & self.read((self.fetch16() + self.y) & 0xFFFF))
        elif op == 0x21:
            z = (self.fetch() + self.x) & 0xFF
            addr = self.ram[z] | (self.ram[(z + 1) & 0xFF] << 8)
            self.a = self.set_nz(a & self.read(addr))
        elif op == 0x31:
            z = self.fetch()
            addr = self.ram[z] | (self.ram[(z + 1) & 0xFF] << 8)
            self.a = self.set_nz(a & self.read((addr + self.y) & 0xFFFF))
        elif op == 0x09:
            self.a = self.set_nz(a | self.fetch())
        elif op == 0x05:
            self.a = self.set_nz(a | self.read(self.fetch()))
        elif op == 0x15:
            self.a = self.set_nz(a | self.read((self.fetch() + self.x) & 0xFF))
        elif op == 0x0D:
            self.a = self.set_nz(a | self.read(self.fetch16()))
        elif op == 0x1D:
            self.a = self.set_nz(a | self.read((self.fetch16() + self.x) & 0xFFFF))
        elif op == 0x19:
            self.a = self.set_nz(a | self.read((self.fetch16() + self.y) & 0xFFFF))
        elif op == 0x01:
            z = (self.fetch() + self.x) & 0xFF
            addr = self.ram[z] | (self.ram[(z + 1) & 0xFF] << 8)
            self.a = self.set_nz(a | self.read(addr))
        elif op == 0x11:
            z = self.fetch()
            addr = self.ram[z] | (self.ram[(z + 1) & 0xFF] << 8)
            self.a = self.set_nz(a | self.read((addr + self.y) & 0xFFFF))
        elif op == 0x49:
            self.a = self.set_nz(a ^ self.fetch())
        elif op == 0x45:
            self.a = self.set_nz(a ^ self.read(self.fetch()))
        elif op == 0x55:
            self.a = self.set_nz(a ^ self.read((self.fetch() + self.x) & 0xFF))
        elif op == 0x4D:
            self.a = self.set_nz(a ^ self.read(self.fetch16()))
        elif op == 0x5D:
            self.a = self.set_nz(a ^ self.read((self.fetch16() + self.x) & 0xFFFF))
        elif op == 0x59:
            self.a = self.set_nz(a ^ self.read((self.fetch16() + self.y) & 0xFFFF))
        elif op == 0x41:
            z = (self.fetch() + self.x) & 0xFF
            addr = self.ram[z] | (self.ram[(z + 1) & 0xFF] << 8)
            self.a = self.set_nz(a ^ self.read(addr))
        elif op == 0x51:
            z = self.fetch()
            addr = self.ram[z] | (self.ram[(z + 1) & 0xFF] << 8)
            self.a = self.set_nz(a ^ self.read((addr + self.y) & 0xFFFF))
        elif op == 0x69:
            self.adc(self.fetch())
        elif op == 0x65:
            self.adc(self.read(self.fetch()))
        elif op == 0x75:
            self.adc(self.read((self.fetch() + self.x) & 0xFF))
        elif op == 0x6D:
            self.adc(self.read(self.fetch16()))
        elif op == 0x7D:
            self.adc(self.read((self.fetch16() + self.x) & 0xFFFF))
        elif op == 0x79:
            self.adc(self.read((self.fetch16() + self.y) & 0xFFFF))
        elif op == 0x61:
            z = (self.fetch() + self.x) & 0xFF
            addr = self.ram[z] | (self.ram[(z + 1) & 0xFF] << 8)
            self.adc(self.read(addr))
        elif op == 0x71:
            z = self.fetch()
            addr = self.ram[z] | (self.ram[(z + 1) & 0xFF] << 8)
            self.adc(self.read((addr + self.y) & 0xFFFF))
        elif op == 0xE9:
            self.sbc(self.fetch())
        elif op == 0xE5:
            self.sbc(self.read(self.fetch()))
        elif op == 0xF5:
            self.sbc(self.read((self.fetch() + self.x) & 0xFF))
        elif op == 0xED:
            self.sbc(self.read(self.fetch16()))
        elif op == 0xFD:
            self.sbc(self.read((self.fetch16() + self.x) & 0xFFFF))
        elif op == 0xF9:
            self.sbc(self.read((self.fetch16() + self.y) & 0xFFFF))
        elif op == 0xE1:
            z = (self.fetch() + self.x) & 0xFF
            addr = self.ram[z] | (self.ram[(z + 1) & 0xFF] << 8)
            self.sbc(self.read(addr))
        elif op == 0xF1:
            z = self.fetch()
            addr = self.ram[z] | (self.ram[(z + 1) & 0xFF] << 8)
            self.sbc(self.read((addr + self.y) & 0xFFFF))
        elif op == 0xC9:
            self.cmp(a, self.fetch())
        elif op == 0xC5:
            self.cmp(a, self.read(self.fetch()))
        elif op == 0xD5:
            self.cmp(a, self.read((self.fetch() + self.x) & 0xFF))
        elif op == 0xCD:
            self.cmp(a, self.read(self.fetch16()))
        elif op == 0xDD:
            self.cmp(a, self.read((self.fetch16() + self.x) & 0xFFFF))
        elif op == 0xD9:
            self.cmp(a, self.read((self.fetch16() + self.y) & 0xFFFF))
        elif op == 0xC1:
            z = (self.fetch() + self.x) & 0xFF
            addr = self.ram[z] | (self.ram[(z + 1) & 0xFF] << 8)
            self.cmp(a, self.read(addr))
        elif op == 0xD1:
            z = self.fetch()
            addr = self.ram[z] | (self.ram[(z + 1) & 0xFF] << 8)
            self.cmp(a, self.read((addr + self.y) & 0xFFFF))
        elif op == 0xE0:
            self.cmp(self.x, self.fetch())
        elif op == 0xE4:
            self.cmp(self.x, self.read(self.fetch()))
        elif op == 0xEC:
            self.cmp(self.x, self.read(self.fetch16()))
        elif op == 0xC0:
            self.cmp(self.y, self.fetch())
        elif op == 0xC4:
            self.cmp(self.y, self.read(self.fetch()))
        elif op == 0xCC:
            self.cmp(self.y, self.read(self.fetch16()))
        elif op == 0x0A:
            self.flag(C, a & 0x80)
            self.a = self.set_nz((a << 1) & 0xFF)
        elif op == 0x06:
            self._rmw(self.fetch(), self._asl)
        elif op == 0x16:
            self._rmw((self.fetch() + self.x) & 0xFF, self._asl)
        elif op == 0x0E:
            self._rmw(self.fetch16(), self._asl)
        elif op == 0x1E:
            self._rmw((self.fetch16() + self.x) & 0xFFFF, self._asl)
        elif op == 0x4A:
            self.flag(C, a & 1)
            self.a = self.set_nz(a >> 1)
        elif op == 0x46:
            self._rmw(self.fetch(), self._lsr)
        elif op == 0x56:
            self._rmw((self.fetch() + self.x) & 0xFF, self._lsr)
        elif op == 0x4E:
            self._rmw(self.fetch16(), self._lsr)
        elif op == 0x5E:
            self._rmw((self.fetch16() + self.x) & 0xFFFF, self._lsr)
        elif op == 0x2A:
            carry = self.p & C
            self.flag(C, a & 0x80)
            self.a = self.set_nz(((a << 1) | carry) & 0xFF)
        elif op == 0x26:
            self._rmw(self.fetch(), self._rol)
        elif op == 0x36:
            self._rmw((self.fetch() + self.x) & 0xFF, self._rol)
        elif op == 0x2E:
            self._rmw(self.fetch16(), self._rol)
        elif op == 0x3E:
            self._rmw((self.fetch16() + self.x) & 0xFFFF, self._rol)
        elif op == 0x6A:
            carry = self.p & C
            self.flag(C, a & 1)
            self.a = self.set_nz((a >> 1) | (carry << 7))
        elif op == 0x66:
            self._rmw(self.fetch(), self._ror)
        elif op == 0x76:
            self._rmw((self.fetch() + self.x) & 0xFF, self._ror)
        elif op == 0x6E:
            self._rmw(self.fetch16(), self._ror)
        elif op == 0x7E:
            self._rmw((self.fetch16() + self.x) & 0xFFFF, self._ror)
        elif op == 0xE6:
            self._rmw(self.fetch(), self._inc)
        elif op == 0xF6:
            self._rmw((self.fetch() + self.x) & 0xFF, self._inc)
        elif op == 0xEE:
            self._rmw(self.fetch16(), self._inc)
        elif op == 0xFE:
            self._rmw((self.fetch16() + self.x) & 0xFFFF, self._inc)
        elif op == 0xC6:
            self._rmw(self.fetch(), self._dec)
        elif op == 0xD6:
            self._rmw((self.fetch() + self.x) & 0xFF, self._dec)
        elif op == 0xCE:
            self._rmw(self.fetch16(), self._dec)
        elif op == 0xDE:
            self._rmw((self.fetch16() + self.x) & 0xFFFF, self._dec)
        elif op == 0xE8:
            self.x = self.set_nz(self.x + 1)
        elif op == 0xC8:
            self.y = self.set_nz(self.y + 1)
        elif op == 0xCA:
            self.x = self.set_nz(self.x - 1)
        elif op == 0x88:
            self.y = self.set_nz(self.y - 1)
        elif op == 0x18:
            self.flag(C, False)
        elif op == 0x38:
            self.flag(C, True)
        elif op == 0x58:
            self.flag(I, False)
        elif op == 0x78:
            self.flag(I, True)
        elif op == 0xD8:
            self.flag(D, False)
        elif op == 0xF8:
            self.flag(D, True)
        elif op == 0xB8:
            self.flag(V, False)
        elif op == 0xEA:
            pass
        elif op == 0x24:
            self._bit(self.read(self.fetch()))
        elif op == 0x2C:
            self._bit(self.read(self.fetch16()))
        elif op == 0x4C:
            self.pc = self.fetch16()
        elif op == 0x6C:
            addr = self.fetch16()
            lo = self.read(addr)
            hi = self.read((addr & 0xFF00) | ((addr + 1) & 0xFF))
            self.pc = lo | (hi << 8)
        elif op == 0x20:
            addr = self.fetch16()
            ret = (self.pc - 1) & 0xFFFF
            self.push(ret >> 8)
            self.push(ret & 0xFF)
            self.pc = addr
        elif op == 0x60:
            lo = self.pop()
            hi = self.pop()
            self.pc = ((hi << 8 | lo) + 1) & 0xFFFF
        elif op == 0x40:
            self.p = (self.pop() & ~0x10) | 0x20
            lo = self.pop()
            hi = self.pop()
            self.pc = hi << 8 | lo
        elif op == 0x10:
            self.branch((self.p & N) == 0)
        elif op == 0x30:
            self.branch((self.p & N) != 0)
        elif op == 0x50:
            self.branch((self.p & V) == 0)
        elif op == 0x70:
            self.branch((self.p & V) != 0)
        elif op == 0x90:
            self.branch((self.p & C) == 0)
        elif op == 0xB0:
            self.branch((self.p & C) != 0)
        elif op == 0xD0:
            self.branch((self.p & Z) == 0)
        elif op == 0xF0:
            self.branch((self.p & Z) != 0)
        else:
            raise RuntimeError(f"opcode ${op:02X} at ${((self.pc - 1) & 0xFFFF):04X}")

    def _rmw(self, addr, fn):
        self.write(addr, fn(self.read(addr)))

    def _asl(self, val):
        self.flag(C, val & 0x80)
        return self.set_nz((val << 1) & 0xFF)

    def _lsr(self, val):
        self.flag(C, val & 1)
        return self.set_nz(val >> 1)

    def _rol(self, val):
        carry = self.p & C
        self.flag(C, val & 0x80)
        return self.set_nz(((val << 1) | carry) & 0xFF)

    def _ror(self, val):
        carry = self.p & C
        self.flag(C, val & 1)
        return self.set_nz((val >> 1) | (carry << 7))

    def _inc(self, val):
        return self.set_nz(val + 1)

    def _dec(self, val):
        return self.set_nz(val - 1)

    def _bit(self, val):
        self.flag(Z, (self.a & val) == 0)
        self.flag(N, val & 0x80)
        self.flag(V, val & 0x40)

    def call(self, addr):
        self.push(0xFF)
        self.push(0xFF)
        self.pc = addr
        steps = 0
        while self.pc != 0:
            self.step()
            steps += 1
            if steps > 250000:
                raise RuntimeError(f"sound driver did not return (pc=${self.pc:04X})")


def header_tracks(prg, addr):
    off = addr - 0x8000
    ids = []
    while prg[off] < 0x80 and len(ids) < 8:
        ids.append(prg[off])
        off += 3
    return ids


def render_sound(cpu, sound_id, max_frames):
    cpu.reset_sound()
    base = SOUND_LIST - 0x8000 + (sound_id - 1) * 2
    ptr = cpu.prg[base] | (cpu.prg[base + 1] << 8)
    cpu.must_finish = set(header_tracks(cpu.prg, ptr))
    cpu.ram[0x0600] = sound_id
    samples = []
    acc = 0.0
    quiet = 0
    for frame in range(max_frames):
        cpu.call(PLAY_SOUNDS)
        acc += SAMPLE_RATE * FRAME_CYCLES / CPU_HZ
        n = int(acc)
        acc -= n
        cpu.apu.render(n, samples)
        if cpu.song_done:
            break
        if cpu.ram[0x0606] == 0 and not (cpu.apu.dmc_bytes or cpu.apu.dmc_bits):
            quiet += 1
            if quiet >= 20 and frame > 2:
                break
        else:
            quiet = 0
    return samples, cpu.looped


def to_pcm(samples):
    if not samples:
        return []
    # The high-pass leaves a small tail. Scale to leave headroom.
    peak = max(abs(s) for s in samples)
    gain = 28000.0 / peak if peak > 1e-6 else 0.0
    pcm = [max(-32767, min(32767, int(s * gain))) for s in samples]
    fade = min(200, len(pcm))
    for i in range(fade):
        pcm[-1 - i] = int(pcm[-1 - i] * i / fade)
    return pcm


def write_wav(path, pcm):
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "w") as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(SAMPLE_RATE)
        out.writeframes(struct.pack("<" + "h" * len(pcm), *pcm))


def slug_for(sound_id):
    return STAGE.get(sound_id) or EFFECT.get(sound_id) or ""


def is_music(sound_id, tracks, looped, seconds):
    if sound_id in EFFECT:
        return False
    if sound_id in STAGE:
        return True
    # A theme is a long arrangement. A short multi-channel sting stays with the effects.
    if seconds >= 8.0 and tracks >= 3:
        return True
    return looped and seconds >= 8.0 and tracks >= 2


def main():
    parser = argparse.ArgumentParser(description="Render Ninja Gaiden music and effects.")
    parser.add_argument("--only", help="render just this hex sound number, for a check")
    args = parser.parse_args()
    prg = load_prg()
    apu = APU(prg)
    cpu = CPU(prg, apu)
    only = int(args.only, 16) if args.only else None
    seen_ptr = {}
    rows = []
    for sound_id in range(1, SOUND_COUNT + 1):
        if sound_id == 0x25:
            continue
        ptr = prg[SOUND_LIST - 0x8000 + (sound_id - 1) * 2]
        ptr |= prg[SOUND_LIST - 0x8000 + (sound_id - 1) * 2 + 1] << 8
        if ptr in seen_ptr:
            continue
        seen_ptr[ptr] = sound_id
        if only is not None and sound_id != only:
            continue
        tracks = len(header_tracks(prg, ptr))
        likely = sound_id in STAGE or tracks >= 3
        samples, looped = render_sound(cpu, sound_id, 60 * (180 if likely else 30))
        raw_peak = max((abs(s) for s in samples), default=0.0)
        if raw_peak < 0.001:
            print(f"skip  {sound_id:02X}  silent", flush=True)
            continue
        pcm = to_pcm(samples)
        seconds = len(pcm) / SAMPLE_RATE
        music = is_music(sound_id, tracks, looped, seconds)
        folder = "music" if music else "sfx"
        slug = slug_for(sound_id)
        name = f"{sound_id:02X}-{slug}.wav" if slug else f"{sound_id:02X}.wav"
        path = ROOT / "audio" / folder / name
        if only is None:
            write_wav(path, pcm)
        else:
            write_wav(path, pcm)
        peak = max(abs(s) for s in pcm) if pcm else 0
        rows.append((folder, name, seconds, looped, tracks, peak))
        print(f"{folder:5} {name:28} {seconds:6.2f}s  tracks={tracks}  loop={int(looped)}  peak={peak}", flush=True)
    if only is None:
        music_n = sum(1 for r in rows if r[0] == "music")
        sfx_n = sum(1 for r in rows if r[0] == "sfx")
        print(f"{music_n} music, {sfx_n} effects")


if __name__ == "__main__":
    main()
