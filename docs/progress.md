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
  `test_sound` (`$C104`) plays the number until it is 0. `pick_stage`
  (`$C110`) then asks for the stage. `redraw_number` (`$C128`) draws
  it. `digit_inc` (`$C17B`) adds one and `digit_dec` (`$C180`)
  subtracts one. `release_pad` (`$C174`) waits until Start is let go.
  The boxer walks (`boxer_walk`, `$C1F9`), closes in (`boxer_close`,
  `$C21D`), waits (`boxer_wait`, `$C241`), jumps (`boxer_jump`,
  `$C259`), rises (`boxer_rise`, `$C26A`), punches (`boxer_punch`,
  `$C27C`), and lands (`boxer_land`, `$C2A3`). The machine gunner
  walks, paces, and fires (`gunner_walk` `$C2B6`, `gunner_pace`
  `$C2DC`, `gunner_fire` `$C307`). The thrower walks, paces, throws,
  and holds (`thrower_walk` `$C344`, `thrower_pace` `$C368`,
  `thrower_toss` `$C37E`, `thrower_hold` `$C3AE`). The batter chases
  and turns (`batter_chase` `$C3BD`, `batter_turn` `$C3E1`). The knife
  thrower walks and throws high, then low (`knife_arm` `$C402`,
  `knife_walk` `$C41B`, `knife_high` `$C431`, `knife_again` `$C466`,
  `knife_low` `$C487`, `knife_reset` `$C4BE`). The crouching soldier
  aims, fires, and aims again (`crouch_aim` `$C4D5`, `crouch_fire`
  `$C4F1`, `crouch_cycle` `$C51D`). The kicker walks, jumps in, pauses,
  spins a kick, and lands (`kicker_walk` `$C53C`, `kicker_near` `$C55A`,
  `kicker_pause` `$C577`, `kicker_kick` `$C58E`, `kicker_land`
  `$C5AE`). The runner runs, hops, and lands (`runner_go` `$C5C1`,
  `runner_hop` `$C5E5`, `runner_land` `$C5FF`). The bat swoops and bobs
  (`bat_swoop` `$C615`, `bat_bob` `$C64E`). The attacking dog runs and
  leaps (`hound_run` `$C67F`, `hound_leap` `$C6B3`). The waiting dog
  sits, wakes, and leaps (`dog_sit` `$C6D4`, `dog_wake` `$C6F5`,
  `dog_leap` `$C71A`). The bird matches Ryu's height and steers
  (`bird_rise` `$C739`, `bird_home` `$C75D`, `home_x` `$C76D`). The
  jetpack ninja hovers and throws (`jet_hover` `$C7AB`, `jet_aim`
  `$C7D7`, `jet_thrown` `$C80E`). The running ninja stands, runs,
  jumps, lands, and runs again (`ninja_stand` `$C828`, `ninja_run`
  `$C849`, `ninja_jump` `$C86B`, `ninja_land` `$C88C`, `ninja_resume`
  `$C8A3`). The stone man paces and throws his ring (`stone_start`
  `$C8BE`, `stone_pace` `$C8EA`, `stone_throw` `$C93B`, `stone_follow`
  `$C963`, `stone_rest` `$C9A9`). The ghouls hop (`ghoul_hop` `$C9BA`,
  `ghoul_bounce` `$C9EA`, `ghoul_land` `$CA13`, `lurker_wait` `$CA2E`,
  `lurker_wake` `$CA52`, `lurker_bounce` `$CA65`, `lurker_land`
  `$CA8E`). Their shots are `gun_shot` (`$CAA5`), `throw_axe`
  (`$CAE9`), `axe_fall` (`$CB30`), `throw_knife` (`$CB37`),
  `crouch_shot` (`$CB73`), `ninja_star` (`$CBC2`), `throw_ring`
  (`$CC0B`), and `ring_back` (`$CC4E`). `leave_actor` (`$D5B2`) is an
  action that changes nothing.
  `nmi_count` (`$BF`) counts up every frame. The Barbarian walks and
  swings his sword (`barbarian_setup` `$CCA5`, `barbarian_walk` `$CCC5`,
  `barbarian_stride` `$CCE1`, `barbarian_stop` `$CCEC`,
  `barbarian_hold` `$CD02`, `barbarian_turn` `$CD0D`,
  `barbarian_face` `$CD1E`, `barbarian_pause` `$CD2E`). Bomberhead
  swings his sickle (`bomber_setup` `$CD41`, `bomber_close` `$CD87`,
  `bomber_swing` `$CDA4`, `bomber_chase` `$CDC5`, `spawn_sickle`
  `$CDD6`). The sickle follows his pose (`sickle_place` `$CDFE`,
  `sickle_out` `$CE29`, `sickle_low` `$CE4E`). Basaquer jumps and
  fires three shots (`basaquer_enter` `$CE7F`, `basaquer_jump`
  `$CEA8`, `basaquer_land` `$CEC1`, `basaquer_turn` `$CEE3`,
  `basaquer_fire` `$CF01`, `shot_high` `$CF20`, `shot_mid` `$CF39`,
  `shot_low` `$CF52`, `spawn_shot` `$CF69`, `shot_release` `$CFA4`).
  Kelbeross is two of the same creature. They jump and breathe fire (`kelbeross_enter`
  `$CFB6`, `kelbeross_ready` `$D015`, `kelbeross_jump` `$D02D`,
  `kelbeross_breathe` `$D052`, `kelbeross_fire` `$D0A0`). Bloody Malth
  walks and calls lightning (`malth_enter` `$D0F7`, `malth_walk`
  `$D11A`, `malth_stop` `$D131`, `malth_call` `$D14D`, `malth_pose`
  `$D15B`, `malth_again` `$D170`, `call_lightning` `$D179`,
  `bolt_wait` `$D1C9`, `bolt_aim` `$D1DE`, `bolt_fall` `$D1FE`). The
  Masked Devil walks in from the right, swords out (`devil_walk`
  `$D223`, `devil_call` `$D256`). `devil_spawn` (`$D270`) puts a
  fireball in the middle of the room. `ball_steer_x` (`$D2B2`) and
  `ball_steer_y` (`$D2EC`) steer it toward him. `devil_still`
  (`$D32D`) is the orb, and it never moves. Jaquio floats and fires
  (`jaquio_enter` `$D35B`, `jaquio_pace` `$D394`, `jaquio_left`
  `$D3BA`, `jaquio_right` `$D3C9`, `jaquio_spawn` `$D3D8`,
  `jaquio_home` `$D40B`). The last boss is a large creature. His body
  is drawn behind the scenery. His head falls and slides left. His
  tail stays put. Crescents come out the whole fight (`final_enter`
  `$D443`,
  `final_watch` `$D480`, `final_fire` `$D492`, `spawn_head` `$D4BF`,
  `spawn_tail` `$D4F2`, `head_break` `$D52B`, `head_slide` `$D540`,
  `boss_shot` `$D55E`, `boss_shot_fall` `$D5AD`).
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
  health, the damage he does, and the points he is worth. `ground_kind`
  (`$A430`) is what each quarter of a block does to Ryu. Four tables,
  and the low bits of `area_gfx` pick one. The bytes after Act VI,
  stage 5 are these tables, not another room.
- PRG bank 03 (`prg/bank03.asm`) is the sounds, switched in at `$8000`.
  NMI calls `play_sounds` (`$8000`) every frame. `start_sound` (`$8243`)
  starts the number in `sound` (`$0600`): the stage, a jump, the sword,
  a pickup. `stop_sound` (`$800B`) is sound `$25`, which fades out
  whatever is playing. Six sounds can wait. `channels` (`$0606`) is
  which tracks are playing. A track's note time is `note_left`
  (`$0607`), its length `note_hold` (`$0608`), and its loudness
  `loud_left` (`$0609`) and `loud_level` (`$060A`). The track is
  `track` (`$0627`): the notes, the loudness, the pitch, and where a
  called part returns. `track_tune` (`$06A7`) is added to the pitch.
  `wobble_on` (`$06AF`) makes it wobble around `pitch_low` (`$06B7`)
  and `pitch_high` (`$06BF`). `fade_left` (`$06C7`) counts down to the
  next step quieter, and `fade_load` (`$06CF`) is that wait. `period_hi`
  (`$06D7`) is the high pitch byte last sent. `sweep_off` (`$06DB`) is
  set while the pitch is not sliding. `drum_wait` (`$06DF`) holds a
  drum until it is allowed. The loudness shapes include `fade_down`,
  `swell_fade`, `rise_hold`, `fade_waver`, `fade_longer`, `fade_slow`,
  `fade_skip`, `fade_uneven`, and `waver_down`. Sound `$02` plays when
  a cutscene ends. `read_notes` (`$82B9`) reads the next note. `note_pitch`
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
  `hide_pictures` (`$85EB`) hides the moving pictures. `say_line`
  (`$85DD`) starts a line. The low six bits are how long each letter
  waits.
  `scene` (`$0300`) is which cutscene is playing. `wait_lo` (`$0301`)
  and `wait_hi` (`$0302`) are the frames left in this step. `script_done`
  (`$0303`) means the script has finished. `script_at` (`$0304`) is
  which byte, and `script_ptr` (`$0A`) points at the script.
  `shade_left` (`$0305`) is the shades left in a fade. `shade_wait`
  (`$0306`) is the frames until the next shade, and `shade_load`
  (`$0309`) is that wait used again. `fade_mode` (`$0307`) bit 7 jumps
  several shades and starts from black. `fade_which` (`$0308`) chooses
  which colors. `flash_left` (`$030A`) is the gray flashes left.
  `flash_time` (`$030B`) is the frames until the next flip.
  `shot_on` (`$030C`) means the picture is moving through a shot.
  `shot_i` (`$030D`) is which shot, `shot_delay` (`$030E`) the wait,
  `shot_left` (`$030F`) the frames left, and `shot_at` (`$0310`) where
  it is in the list. `band_count` (`$031D`) is how many bands the
  picture is split into. `band_lo` (`$031E`) is how far a band is
  scrolled, `band_hold` (`$0326`) how long until the next band, and
  `band_speed` (`$032E`) how fast it scrolls. `scroll_x` (`$A1`) and
  `scroll_y` (`$A7`) are the whole picture. `scroll_dx` (`$E1`) and
  `scroll_dy` (`$E3`) are how fast it moves. `camera_flags` (`$0384`)
  bit 7 switches the pictures at the split. `split_chr` (`$038A`) is
  those pictures. `which_screen` (`$0385`) is the second screen.
  `split_on` (`$0386`) means the split sprite is in use. `backdrop`
  (`$038B`) is the background color. `palette_set` (`$038C`) is which
  colors, four for the background and four for the sprites.
  `colors_due` (`$0388`) loads them when the step ends. `colors`
  (`$03A3`) are the 32 colors waiting to be sent. `tile_ptr` (`$E8`)
  is the tiles being copied, and `tile_base` (`$0311`) is where they
  go. `pad_last` (`$EA`) is the buttons held on the previous frame.
  `pose_wait` (`$88CF`) is how long the first pose stays.
  `path_wait` (`$88E3`) is how long a picture waits on the first place
  of its path. `slide_speed` (`$8B04`) is how fast a picture slides.
  `speed_change` (`$8B6C`) is a slide whose speed changes.
  Script `$0D` plays when Start skips the opening. If it finishes, the
  opening plays again. If Start skips it, script `$0C` plays and the
  game starts. `call_bank` (`$BF98`) calls a routine in another bank
  and switches this one back.
- PRG bank 01 (`prg/bank01.asm`) is the stage pictures and a few whole
  screens, switched in at `$8000`. `area_gfx` picks the set. `block_tiles`
  (`$8000`) is the four tiles in one block. `which_blocks` (`$A000`) says
  which blocks to draw, two pairs in each entry. `block_tile` (`$B000`)
  is the tile drawn for that block. `screen_list` (`$B400`) is which
  screen to show. `screen_colors` (`$B40A`) is black and white.
  `area_screen` (`$B41E`) is shown when an area starts. `game_over`
  (`$B471`) is the game-over screen. `stage_select` (`$B47E`) is the
  stage select. `sound_screen` (`$B488`) says SOUND. Nothing calls
  `pick_area`, so those two never show. `reset_copy_01`
  (`$BFDA`) is the same first instructions as reset.
- PRG bank 06 (`prg/bank06.asm`) is the cutscene pictures and the lines
  that are spoken, switched in at `$8000`. `draw_picture` (`$8000`) draws
  picture A on the background. `picture_list` (`$82D4`) is which picture.
  `picture_parts` (`$8B71`) is where that picture's tiles and colors are.
  Three sets: `tiles_1` (`$8B7D`), `tiles_2` (`$937D`), `tiles_3` (`$9B7D`),
  then `colors_1` (`$A145`), `colors_2` (`$A1C5`), `colors_3` (`$A245`).
  A picture's first byte picks the background tiles and which set. The
  next byte is how many across and how many down. Each block is a
  4-by-2 tile patch. `moon_field` (`$8356`) is the moon over the field.
  `streaks` (`$83B8`) is white streaks. `moon_grass` (`$83DA`) is the
  edge of the moon and the grass. `ryu_bust` (`$83FC`) is Ryu from the
  chest up. `the_sword` (`$8406`) is the Dragon Sword. `eyes_open`
  (`$8418`), `eyes_hard` (`$843A`), `eyes_closing` (`$845C`), and
  `eyes_shut` (`$847E`) are Ryu's eyes. `irene_gun` (`$84A0`) is Irene
  Lew holding a gun. `demon_statue` (`$84D2`) is a demon statue.
  `irene_profile` (`$84DC`) is Irene in profile. `walter` (`$84EA`) is
  Walter Smith. `smith_back` (`$850C`) is Walter from behind.
  `temple_moon` (`$852E`) is the temple under the moon. `field_trees`
  (`$8588`) is the field and the trees. `temple_field` (`$85E2`) is the
  temple over the field. `jaquio_face` (`$863C`) is the Jaquio.
  `broken_wall` (`$8656`) is the wall broken open. `malth` (`$8678`) is
  Malth. `fathers_fight` (`$868A`) is a scarred face and a man under the
  moon. `devil_mask` (`$86A4`) is the masked devil. `father` (`$86B6`)
  is Ryu's father. `three_faces` (`$86C8`) is three screaming faces.
  `demon_claw` (`$86E2`) is a claw. `grass` (`$86F4`) is the grass.
  `ryu_runs` (`$8716`) is Ryu running. `bloody_hall` (`$8727`) is the
  Jaquio and blood on the walls. No script draws that picture. While
  Foster says a man took the ruins, the scene stamps this same figure.
  `title_ninja`
  (`$8741`) is the word NINJA. `title_logo` (`$8763`) is the Ninja
  Gaiden logo. `forest_top` (`$876F`) is the top of the forest.
  `great_moon` (`$8789`) is the moon. `gold_armor` (`$87FB`) is a man
  in gold armor and a purple cape. `blank_strip` (`$881D`) is a blank
  strip. `cell_door` (`$883F`) is the cell door, and `cell_open`
  (`$8859`) is that door open. `stone_wall` (`$8873`) is the stone
  wall. `roof_hole` (`$888D`) is a hole in the roof. `cia_agents`
  (`$88A7`) is three men from the CIA. `looking_down` (`$88C1`) is a
  face looking down. `foster_office` (`$88D3`) is Foster's office.
  `red_close` (`$88F5`) is a close-up in red. `jungle` (`$891F`) is
  the jungle. `irene_held` (`$8979`) is Irene and a masked man, and
  `irene_held_close` (`$8A9C`) is that picture closer. `ryu_profile`
  (`$898B`) is Ryu in profile. `ryu_face` (`$89AD`) is Ryu's face.
  `ryu_back` (`$89CF`) is the back of his head. `father_wakes`
  (`$89F1`) is Ryu's father, close up. `a_hand` (`$8A0B`) is a hand.
  `leaves` (`$8A1D`) is the leaves. `blank_purple` (`$8A3F`) is a blank
  purple strip. `night_sky` (`$8A4D`) is the night sky. `gold_statue`
  (`$8A5F`) is a demon statue in gold. `small_statue` (`$8A69`) is a
  small statue. `presents` (`$8A6C`) is PRESENTS 1989. `blank_gray`
  (`$8A72`) is a blank gray strip. `ryu_edge` (`$8AAA`) is the edge of
  Ryu's hair. `office_wall` (`$8AAD`) is the office wall.
  `office_stripes` (`$8B0B`) is that wall and the curtains.
  `temple_hall` (`$8AC7`) is the temple hall. `temple_demon` (`$8AE9`)
  is that hall and a demon. `push_start` (`$8B2D`) is PUSH START and
  the Tecmo license. `push_start_spare` (`$8B53`) is the same picture;
  no script draws it. `the_end` (`$8B6D`) is THE END. From `$A2A2`
  through `$A7D8` the bytes match the end of bank 04's scripts; bank
  04 is the copy that runs. `song_copy` (`$B2BE`) is the same songs as
  bank 03; this bank never plays them. `$BE78` is empty. `$BEDD` is
  more of those songs, and this bank never plays them.
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
  picks the pose from `pose_list` (`$8408`). `irene_poses` is list 1,
  pictures `$17` and `$18`. `irene_later` is list `$0A`, pictures `$23`
  and `$24`. `walter_poses` is list 2, pictures `$19` and `$1A`.
  `jaquio_poses` is list `$08`, pictures `$26` and `$27`.
  `run_poses` is list 0: `run_a` (`$08`) and `run_b` (`$09`), the two
  steps of a run. `malth_poses` is list `$06` and `malth_laughs` is
  list `$07`. `malth_mouth` (`$1F`) is Malth talking, `malth_open`
  (`$20`) is his mouth open, and `malth_laugh` (`$21`) is the laugh.
  He says "Have a nice day." `face_right` (`$06`) and `face_left`
  (`$07`) are the two profiles in the opening duel. `flat_sword`
  (`$0C`) is a sword held flat. `ryu_cliff` (`$2F`) is Ryu on the
  cliff with the sword. `tecmo_logo` (`$32`) is TECMO. `act_1`
  through `act_6` (`$50`–`$55`) are ACT I through ACT VI. `the_moon`
  (`$4E`) is the moon during the eclipse. `irene_e` (`$25`) is Irene
  Lew, one more mouth. `blank_frame` (`$4D`) draws nothing, and a pose
  rests there so the picture vanishes. `unused_blank` (`$22`) draws
  nothing, and no script shows it.
  `pixel_shift` (`$83DF`) is how many pixels to shift a sprite.
  `picture_path` (`$84AB`) is where a picture walks. `walk_right` steps
  to the right. `walk_left` steps to the left. `actor_pics`
  (`$84B9`) is the pictures. The first byte is the sprite tiles, stored
  in `chr_bank0` (`$56`). `pose_time` (`$92C3`) is how long each pose
  stays. `sprite_i` (`$033F`) is the next sprite. `draw_x` (`$0381`),
  `draw_x_hi` (`$0382`), and `draw_y` (`$0383`) are where it is drawn.
  `draw_flags` (`$0380`) is the facing for that draw.
  `open_line` (`$83B4`) points `line_ptr` (`$E6`) at the line from
  `line_list` (`$92D0`). Each line is named from what is said, from
  `ask_duel` through the staff roll (`staff_thanks`). `read_char`
  (`$8210`) takes the next letter or command.
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
  The number above each tile is the same one on `gfx/tiles/bankNN.png`.

## Next

- None. Every file bank is `.asm`.
