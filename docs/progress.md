# Ninja Gaiden — progress

## End goal

The entire ROM should live in the repo as source: every byte is labelled
`.asm`, and `make verify` matches `NinjaGaiden.sha1`. No committed binaries
in the final state.

File banks stay separate. MMC1 maps one 16 KiB bank at `$8000` and keeps
bank 07 at `$C000`, so each switched bank can be its own file.

## Done

- Toolchain: ca65/ld65, cc65 V2.19 (`make tools`).
- Scaffold: `NinjaGaiden.asm` stitches the iNES header and 8 PRG + 16 CHR
  file banks. `make verify` matches the US dump.
- PRG bank 07 (`prg/bank07.asm`) is the fixed `$C000` bank. Named: MMC1
  control `$1E`, the play-frame gate (`frame_gate`, `to_hold`,
  `area_event`, `lose_life`), `set_prg` / `set_chr0` / `set_chr1`,
  `wait_nmi`, `sprite0_split`, `read_joy`, NMI, and the IRQ `RTI`.
  `timer` is `$63`, `ninpo` is `$64`, `health` is `$65`, `area` is `$6D`,
  `lives` is `$76`. `player_control` (`$EB7B`) moves Ryu for the frame and
  picks his action from the pad.
  `set_action` (`$F62D`) starts that action. `actor_kind` (`$C195`) is one
  entry per enemy, each pointing at that enemy's actions (`$C1ED`–`$D5B2`).
  `pick_area` (`$C0E9`) is a hidden stage select the game never calls.
  `$D63A`–`$E346` is the rest of a play frame: boss death, Ryu's weapons,
  lanterns and their power-ups, and each enemy's turn. `scroll_stage`
  (`$F1AC`) scrolls the stage when Ryu is in the middle of the screen.
  The rest of the bank is source too: spawning enemies, moving Ryu when
  the stage stays put, `next_area`, drawing, the clock and status bar,
  and the kick and snare samples. No `INCBIN` left in bank 07.
- PRG bank 02 (`prg/bank02.asm`) is the pictures and animation scripts
  the engine switches in at `$8000`. Pose tables, each action's pictures,
  and where the enemies and lanterns stand in a room.
- PRG bank 00 (`prg/bank00.asm`) is the areas and the rooms. The ground
  for each room, where Ryu enters, the act and stage, and each enemy's
  health, the damage he does, and the points he is worth.
- PRG bank 03 (`prg/bank03.asm`) is the sounds, switched in at `$8000`.
  NMI calls `play_sounds` (`$8000`) every frame. `start_sound` (`$8243`)
  starts the number in `sound` (`$0600`): the stage, a jump, the sword,
  a pickup. `stop_sound` (`$800B`) is sound `$25`, which stops whatever
  is playing. `read_notes` (`$82B9`) reads the next note. `note_pitch`
  (`$856E`) is how high it is, `note_length` (`$8586`) how long it lasts,
  and `loudness` (`$85B1`) how loud it gets. `write_channel` (`$80F4`)
  plays one channel. `note_loudness` (`$8161`) sets that loudness, then
  the pitch wobbles (`pitch_move`, `$81E0`): `pitch_note` (`$820A`),
  `pitch_up` (`$8225`), `pitch_higher` (`$823A`), `pitch_down` (`$81F0`),
  `pitch_lower` (`$8205`). `run_command` (`$837A`) runs one command from
  `sound_command` (`$838B`): jump, call, repeat, fade, slide the pitch,
  set the tone, or play a drum (`play_sample`, `$8535`). `sound_list`
  (`$877D`) is which sound each number plays.

## Next

- Disassemble another switched PRG bank. Banks 01, 04, 05, and 06 are
  still `INCBIN`. Bank 04 is the cutscenes `area_event` calls.
