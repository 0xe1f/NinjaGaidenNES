# Ninja Gaiden — notes

US dump `reference/gaiden.nes` (GoodNES *Ninja Gaiden (U) [!]*).
SHA-1 `ca513f841d75efeb33bb8099fb02beeb39f6bb9c`.

## Cart

| | |
|---|---|
| Publisher | Tecmo. Japan December 1988 (*Ninja Ryukenden*); USA March 1989 |
| iNES | mapper 1, 8 × 16 KiB PRG, 16 × 8 KiB CHR, no trainer, no battery |
| Board | SLROM, MMC1B2 (NesCartDB, NES-NG-USA). Mirroring is mapper-controlled |
| Header byte 6 | `$10` — mapper low nibble 1, horizontal bit. MMC1 can override it |
| PRG file | 128 KiB at file offset `$10`, banks `prg/bank00`–`bank07` |
| CHR file | 128 KiB at file offset `$20010`, banks `chr/bank00`–`bank15` |

Reset writes MMC1 control `$1E` (five stores to `$9FFF`, LSB first:
`0,1,1,1,1`). That is vertical mirroring, 16 KiB PRG with file bank 07
fixed at `$C000`, and 4 KiB CHR. File banks 00–06 are the `$8000` window.
`$C028` / `$C000` / `$C014` are the PRG, CHR0, and CHR1 writers. PRG is
shadowed at `$5C`.

`$63` counts down once a second (`$F7E4` reloads a 60-frame divider). `$FF`
is time-up. `$6D` indexes the bank-0 area tables (`$AF2C`, `$AF9A`, `$AFC6`).
Area 0 is Act I and area 1 is the Barbarian. After he dies there is a
cutscene, the Act II title card, and another cutscene before stage 2-1.
Area 2 is those scenes, not stage 2-1.
`$76` is lives, set to 2 at boot: `lose_life` decrements it, and below 0
shows game over and waits for Start.

`area_gfx` (`$AF00`) picks the pictures for this area, in bank 1.
`block_tiles` (`$8000`) is the four tiles in one block. `which_blocks`
(`$A000`) says which blocks to draw. `block_tile` (`$B000`) is the tile
drawn for that block. `show_screen` (`$F0F3`) draws a screen from
`screen_list` (`$B400`): black and white, the screen an area starts on,
game over, the stage select, or SOUND.

`player_control` (`$EB7B`) runs every play frame. `$8A` is Ryu's height,
`$89` his vertical speed, and `$87` the fraction under it. Each airborne
frame adds `$37` to that fraction. `$8A` at `$F8` or below is a pit.
A jumps (`$89` = `$FC`). On a regular wall he holds on, and jumping off
then grabbing it again climbs it. Up and Down climb only on steps.
B swings the sword. Up+B spends ninpo (`$64`) on
the equipped sub-weapon. `$84` bit 6 faces him left; bit 2 is airborne.
`$65` is Ryu's health, full at `$10`.

`run_enemies` (`$DD32`) gives every enemy on screen a turn. A lantern
appears when the screen reaches it (`spawn_lanterns`, `$D8D5`). Slashing it
drops the power-up inside. Power-up 4 is the Hourglass: every enemy freezes
for about five seconds (`$D0` bit 7). Power-up 2 is a 1-UP.

The weapon in `$C9` is one of: Throwing Star `$81` (3 ninpo, flies straight),
Windmill Throwing Star `$82` (5 ninpo, cuts through and comes back), Art of
the Fire Wheel `$80` (5 ninpo, three flames), Invincible Fire-Wheel `$84`
(a flame circles Ryu until it burns out; enemies cannot hurt him), or Jump
& Slash `$85` (a spinning sword; attack while jumping spends 5 ninpo and it
ends when he lands). Down and attack while jumping is the regular sword
and spends no ninpo.

`scroll_stage` (`$F1AC`) runs after `player_control`. When Ryu is in the
middle of the screen, the stage scrolls with him. Otherwise he moves.

After a boss dies, `boss_death` keeps the explosions going and
`score_leftovers` turns leftover ninpo, then leftover time, into points.
The bosses are Barbarian, Bomberhead, Basaquer, Kelbeross, and Bloody Malth.

`actor_kind` (`$C195`) has one pointer per enemy, including the shots
they fire. Each pointer leads to that enemy's actions. Three numbers in
the list are unused. `pick_area` (`$C0E9`) is a hidden stage
select. Nothing in the game calls it. Up, A, B, and Start opens a sound
test first; picking 0 leaves that and then you pick the stage. A and
Right add one, A and Left subtract one, Start confirms.

## Cutscenes

When an area ends, `area_event` switches to bank 04 and calls
`play_cutscene` (`$8000`) with that area's byte from `cutscene`
(`$AF9A`). Reset calls the same entry with 0, the opening. The opening
plays again when it finishes. Start skips a cutscene, except Act VI,
stage 5 (`$0B`). When that one finishes, the game resets.

If A, B, Select, Down, and Left are held when Start skips the opening,
the sound test runs. Bank 06 shows a number. Down lowers it, Up raises
it, A plays that number, B plays a sound, and Start resets the game.
If those buttons are not held, another script plays. Start during that
one continues, and the game starts. If that script finishes on its own,
the opening plays again.

Bank 06 also draws the pictures on the cutscene background, at `picture_at`
(`$E4`). It holds a copy of the lines, through the staff roll. The copy
a cutscene reads is in bank 05.

## Sound

NMI switches to bank 03 and calls `play_sounds` (`$8000`) every frame.
The number in `sound` (`$0600`) indexes `sound_list` (`$877D`). `$25`
does not play a song; it stops whatever is playing. Start stores `$24`
and does not pause the game. The next Start clears that and plays the
stage music again. A note can fade, and its pitch can wobble.

Stage music:

| Number | Where |
|---|---|
| `$03` | Act I stage 1, Act V stage 2, Act VI stage 3 |
| `$04` | Act II stage 1, Act VI stage 1 |
| `$05` | Act II stage 2, Act IV stage 1 |
| `$06` | Act I stage 2, Act II stage 3, Act III stage 3, Act IV stage 4, Act VI stage 4 |
| `$07` | Act V stage 1, Act V stage 4, Act VI stage 5 |
| `$0B` | Act III stage 2, Act VI stage 2 |
| `$0C` | Act IV stage 2 |
| `$2B` | Act VI stage 4 |
| `$2D` | Act III stage 1 |
| `$30` | Act IV stage 3 |
| `$31` | Act V stage 3 |

Effects:

| Number | When |
|---|---|
| `$0D` | A thrown weapon ends |
| `$0E` | Jaquio fires |
| `$0F` | He jumps, and when he leaves the air |
| `$11` | Ryu is hurt |
| `$12` | An enemy dies |
| `$13` | A pickup, or points |
| `$14` | A 1-UP |
| `$15` | Health, or a lantern breaking |
| `$16` | While the Invincible Fire-Wheel burns |
| `$17` | The Throwing Star |
| `$18` | The Windmill Throwing Star |
| `$19` | Art of the Fire Wheel |
| `$1A` | The spinning sword, the stone man's ring, and the Masked Devil calling fireballs |
| `$1B` | The beep while the Hourglass runs, and when time is short |
| `$1C` | Bomberhead's sickle, and the last boss's fireballs |
| `$1E` | Bloody Malth calls the lightning |
| `$20` | The machine gunner fires |
| `$21` | The crouching soldier fires |
| `$23` | He loses a life |
| `$24` | Start is pressed |
| `$35` | The sword |
| `$3F` | An enemy is hit |
| `$40` | The boss explodes |
| `$41` | Basaquer and Kelbeross |

## Vectors

Last six bytes of PRG file bank 07:

| Vector | Address |
|---|---|
| NMI | `$F91A` |
| RESET | `$FFDA` |
| IRQ | `$FA1F` |

`$FFDA` is `INC $FFDA` / `JMP $C03E`. The INC addresses its own opcode.
