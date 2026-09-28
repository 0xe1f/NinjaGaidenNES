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
- PRG bank 04 (`prg/bank04.asm`) is the cutscenes, switched in at `$8000`.
  Reset calls `play_cutscene` (`$8000`) with 0, the opening. `area_event`
  calls it with the number from `cutscene` (`$AF9A`). `run_script`
  (`$80BE`) plays one script from `script_list` (`$8EE0`). `step_script`
  (`$83B5`) does the next thing that script says. `next_command` (`$83F5`)
  reads one command: flash gray, wait a frame, move or stop the camera,
  fade, choose the screens, play a sound, draw tiles, choose the pictures,
  place one picture, tint, set the scroll, pick colors, play a shot, or
  turn the colors black. `picture_motion` (`$860A`) says how a picture
  moves. `camera_move` (`$8908`) is the twenty-eight camera moves.
  `shot_place` (`$88E7`) is where a shot moves. Start skips a cutscene.
  The opening plays again when it finishes. If A, B, Select, Down, and
  Left are held when Start skips it, `sound_test` (`$8061`) runs. Act VI,
  stage 5 does not skip; when that script finishes, the game resets.
  `end_cutscene` (`$813E`) finishes a cutscene. `black_colors` (`$81FD`)
  turns colors black. `send_colors` (`$822F`) and `send_tiles` (`$821E`)
  hand a list to the screen. `split_sprite` (`$8328`) places the sprite
  that splits the picture. `scroll_band` (`$82E0`) scrolls one band.
  `start_scroll` (`$86D2`) starts a camera move and `change_scroll`
  (`$8756`) changes it. `scroll_step` (`$8871`) moves to the next place
  in the shot. `start_fade` (`$868D`) and `darken_colors` (`$87A0`) fade
  the colors. `start_gray` (`$86C1`) and `gray_flash` (`$880F`) flash the
  picture gray. `queue_tiles` (`$8836`) copies tiles into the list the
  screen draws. `fill_backdrop` (`$8398`) paints the background color.
  `hide_pictures` (`$85EB`) hides the moving pictures. `call_bank`
  (`$BF98`) calls a routine in another bank and switches this one back.
- PRG bank 01 (`prg/bank01.asm`) is the stage pictures and a few whole
  screens, switched in at `$8000`. `area_gfx` picks the set. `block_tiles`
  (`$8000`) is the four tiles in one block. `which_blocks` (`$A000`) says
  which blocks to draw, two pairs in each entry. `block_tile` (`$B000`)
  is the tile drawn for that block. `screen_list` (`$B400`) is which
  screen to show. `screen_colors` (`$B40A`) is black and white.
  `area_screen` (`$B41E`) is shown when an area starts. `game_over`
  (`$B471`) is the game-over screen. `stage_select` (`$B47E`) is the
  stage select. `sound_screen` (`$B488`) says SOUND. `reset_copy_01`
  (`$BFDA`) is the same first instructions as reset.
- PRG bank 06 (`prg/bank06.asm`) is the cutscene pictures and the lines
  that are spoken, switched in at `$8000`. `draw_picture` (`$8000`) draws
  picture A on the background. `picture_list` (`$82D4`) is which picture.
  `picture_parts` (`$8B71`) is where that picture's tiles and colors are.
  `run_sound_test` (`$8222`) shows a number and plays it as a sound. Down
  lowers the number, Up raises it, Start resets the game, B plays a
  sound, and A plays the number. `button_edge` (`$82BE`) is which buttons
  were just pressed. `hide_picture` (`$8157`) hides the picture and
  `show_picture` (`$8166`) shows it. `aim_screen` (`$81D7`) points at a
  place on the screen. `seek_screen` (`$81B5`) points A tiles over, and
  `step_screen` (`$81C8`) moves along. `color_spot` (`$81E5`) is where
  that place's color is stored. `spread_color` (`$81A4`) spreads a color
  across the square. `hand_tiles` (`$8171`) hands the tiles to the screen.
  `hand_colors` (`$8182`) hands the colors over. `test_tiles` (`$82CA`)
  are the tiles on the sound test. `pick_routine` (`$818E`) calls the
  routine picked from the list after the jsr. `start_sound_test` (`$8003`)
  is that list's entry for the sound test. `picture_at` (`$E4`) is where
  the picture is drawn, and `picture_at_hi` (`$E5`) is the high byte. The lines start at `$A7D5`. `new_line` and `line_in` break a line, `wait_text` waits about a second, `clear_text` clears the text area and waits, `line_end` ends the line, `skip_ahead` skips ahead, and `start_picture` / `change_picture` set a picture. The staff roll is at `$B122`.
  `call_bank_06` (`$BF98`) finishes a call from another bank and switches
  that bank back. `draw_routines` (`$BFB3`) is the list those calls use.
  `reset_copy_06` (`$BFDA`) is the same first instructions as reset.

## Next

- Disassemble the last switched PRG bank. Bank 05 is still `INCBIN`.
  Every cutscene frame calls it, and it reads its own copy of the lines.
