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
  the picture is drawn, and `picture_at_hi` (`$E5`) is the high byte. The lines start at `$A7D5`. `new_line` and `line_in` break a line, `wait_text` waits about a second, `clear_text` waits and then wipes the text, `line_end` ends the line, `skip_ahead` skips ahead, and `start_picture` / `change_picture` set a picture. The staff roll is at `$B122`. The marks are the ones bank 05 reads.
  `call_bank_06` (`$BF98`) finishes a call from another bank and switches
  that bank back. `draw_routines` (`$BFB3`) is the list those calls use.
  `reset_copy_06` (`$BFDA`) is the same first instructions as reset.
- PRG bank 05 (`prg/bank05.asm`) is the pictures that move during a
  cutscene, and the lines that are spoken. Switched in at `$8000`.
  Every frame, bank 04 calls `move_actors` (`$8003`) before the script
  steps and `draw_actors` (`$8006`) after. `draw_actor` (`$8000`) draws
  one picture's sprites. `use_picture` (`$8013`) does that draw; A is
  the picture number times two. `next_group` (`$8025`) is the next group
  of tiles, and `next_tile` (`$8067`) is the next tile in it.
  `start_line` (`$800C`) starts the line
  the call was given. `read_text` (`$8009`) reads it while `line_on`
  (`$0313`) is set.
  `move_one` (`$80D6`) moves one of the four pictures. Kind 1 stays,
  kind 2 slides (`add_place`, `$80DD`), kind 3 walks a path
  (`follow_path`, `$8104`), and kind 4 slides and changes speed
  (`add_speed`, `$815D`). `draw_one` (`$8193`) draws one picture.
  `actor_move` (`$0340`) is how it moves; 0 means the slot is empty.
  `actor_x` (`$0342`) is where it stands, `actor_y` (`$0344`) how high,
  with the fractions in `actor_x_lo` (`$0341`) and `actor_y_lo`
  (`$0343`). `actor_flags` (`$0345`) bit 6 faces left. `actor_time`
  (`$0346`) is the frames left on this pose, `actor_pose` (`$0347`)
  which pose, and `actor_pic` (`$0348`) which picture. Bit 7 of that
  picks the pose from `pose_list` (`$8408`). Irene Lew is list 1 and
  list `$0A`. Walter Smith is list 2. The Jaquio is list `$08`.
  `pixel_shift` (`$83DF`) is how many pixels to shift a sprite.
  `picture_path` (`$84AB`) is where a picture walks. `actor_pics`
  (`$84B9`) is the pictures. The first byte is the sprite tiles, stored
  in `chr_bank0` (`$56`). `pose_time` (`$92C3`) is how long each pose
  stays. `sprite_i` (`$033F`) is the next sprite. `draw_x` (`$0381`),
  `draw_x_hi` (`$0382`), and `draw_y` (`$0383`) are where it is drawn.
  `draw_flags` (`$0380`) is the facing for that draw.
  `open_line` (`$83B4`) points `line_ptr` (`$E6`) at the line from
  `line_list` (`$92D0`). The lines run from `$93B2` through the staff
  roll. `read_char` (`$8210`) takes the next letter or command.
  `write_char` (`$8231`) puts the letter on screen with a blank above
  it. That blank is `blank_tile` (`$FA`). The box starts at `box_top`
  (`$22`), `box_left` (`$83`). `row_down` (`$40`) steps down one line.
  `letter_tile` (`$8396`) is the tile for that letter.
  `hand_text` (`$83A3`) hands the letters to the screen. `end_line`
  (`$8270`) finishes the line. `do_skip` (`$8276`) skips ahead.
  `next_row` (`$8296`) is the next line, and `indent_row` (`$830D`) is
  the next line, one letter in. `pause_line` (`$82CB`) waits about a
  second. `begin_clear` (`$82B0`) waits about three seconds, then
  `clear_column` (`$8327`) blanks the box one column at a time.
  `line_pose` (`$82D1`) plays a picture in one of the four slots, and
  `line_picture` (`$82F6`) shows one picture there.
  `line_i` (`$0314`) is which byte of the line. `line_wait` (`$0315`)
  is the frames left before the next step. `line_speed` (`$0316`) is
  the frames between letters. `line_at` (`$0317`) and `line_at_hi`
  (`$0318`) are where the next letter is written. `line_job` (`$0319`)
  is 0 while reading and 1 while wiping. `line_col` (`$031A`) is how
  far along the row. `wipe_col` (`$031B`) is the column being wiped.
  `speed_copy` (`$031C`) keeps the letter delay during the wipe.
  `call_num` (`$0394`) is the number the call was given. `packet_i`
  (`$0395`) is where the next letter is added. `tile_buf` (`$03C3`)
  holds those letters. `tiles_handed` (`$0387`) means this frame's
  tiles were already handed over.
  `pick_entry` (`$80A8`) calls the routine picked from the list after
  the jsr. `call_bank_05` (`$BF98`) finishes a call from another bank
  and switches that bank back. `cutscene_routines` (`$BFB3`) is the
  list those calls use. `reset_copy_05` (`$BFDA`) is the same first
  instructions as reset.
- CHR file banks 00–15 (`chr/bank00.asm`–`chr/bank15.asm`) are the
  pattern tiles. MMC1 switches 4 KiB at a time, so each file is two
  banks. A room stores one of `$00`–`$0F` in `$56`, and NMI shows that
  at `$0000` for the sprites. Bank `$10`, the first half of file bank
  08, is the background. The letters there are the ones the text box
  writes: A–Z are tiles `$41`–`$5A` (`letter_A`–`letter_Z`) and a–z are
  `$61`–`$7A` (`letter_a`–`letter_z`). A cutscene picture's first byte
  is the sprite bank it needs, `$10`–`$15` or `$17`–`$1F`. A one-color
  tile is binary, one row per line. The left pixel is the high bit.

## Next

- None. Every file bank is `.asm`.
