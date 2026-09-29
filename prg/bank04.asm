; PRG file bank 04, switched in at $8000-$BFFF.
; The cutscenes. Reset calls this with 0. When an area ends,
; bank 07 calls it with that area's cutscene number.

scene          = $0300 ; which cutscene is playing
wait_lo        = $0301 ; frames left in this wait
wait_hi        = $0302 ; the rest of that wait. Each one is 256 frames
script_done    = $0303 ; the script has finished
script_at      = $0304 ; which byte of the script
shade_left     = $0305 ; shades left in the fade. 0 means it is not fading
shade_wait     = $0306 ; frames until the next shade
fade_mode      = $0307 ; bit 7 jumps several shades, and starts from black
fade_which     = $0308 ; bit 7 starts at the first color. Bit 6 does not stop after the background
shade_load     = $0309 ; the wait between shades, used again
flash_left     = $030A ; gray flashes left. 0 means it is not flashing
flash_time     = $030B ; frames until the picture flips to gray or back
shot_on        = $030C ; the picture is moving through a shot
shot_i         = $030D ; which shot
shot_delay     = $030E ; frames before the next place, used again
shot_left      = $030F ; frames left before that place
shot_at        = $0310 ; where the shot is in its list
tile_base      = $0311 ; where the tiles are drawn
tile_base_hi   = $0312 ; the rest of that place
band_count     = $031D ; how many bands the picture is split into. 0 means none
band_lo        = $031E ; how far this band is scrolled
band_hi        = $031F ; the rest, and which screen
band_hold      = $0326 ; how long to wait before the next band
band_hold_hi   = $0327 ; the rest of that wait
band_speed     = $032E ; how fast this band scrolls
band_speed_hi  = $032F ; the rest of that speed
bg_left        = $0336 ; background pictures still to draw
actor_left     = $033C ; moving pictures still to place
camera_flags   = $0384 ; bit 7 switches the pictures at the split
which_screen   = $0385 ; the second screen. 0 is the usual one
split_on       = $0386 ; the sprite that splits the picture is in use
colors_due     = $0388 ; load the colors when this step ends
split_chr      = $038A ; pictures for the lower part of the screen
backdrop       = $038B ; the background color
palette_set    = $038C ; which colors. Four for the background, then four for the sprites
color_packet   = $03A0 ; the colors, ready to send. 32 of them, at $3F00
colors         = $03A3 ; those colors
chr_bank1      = $59   ; background patterns
script_ptr     = $0A   ; the script being read
tile_ptr       = $E8   ; the tiles being copied
pad_last       = $EA   ; buttons held on the previous frame
scroll_x_lo    = $A0   ; the fraction under the sideways scroll
scroll_x       = $A1   ; how far the picture is scrolled sideways
scroll_y_lo    = $A6   ; the fraction under the up and down scroll
scroll_y       = $A7   ; how far it is scrolled up and down
scroll_dx_lo   = $E0   ; the fraction under the sideways speed
scroll_dx      = $E1   ; how fast it scrolls sideways
scroll_dy_lo   = $E2   ; the fraction under the up and down speed
scroll_dy      = $E3   ; how fast it scrolls up and down
sprites        = $0200 ; where the sprites are

; --- $8000  Play the cutscene in A. Reset passes 0, the opening. An area passes its own number.
play_cutscene:
        sei
        cld
        pha
; The call list at the end of this bank points here, inside the setup.
; Clear the cutscene's memory.
clear_scene:
        lda #$00
        tax
; One byte of that memory.
zero_byte:
        sta scene,x
; The next byte. All 256 of them.
zero_next:
        dex
        bne zero_byte
; The scene number goes back into the first byte.
scene_byte:
        pla
        sta scene
        lda #$3F
        sta color_packet+2                  ; the colors live at $3F00
        lda #$20
        sta color_packet                    ; 32 of them
        lda #$B0
        sta z:ppuctrl_shadow                ; NMI on, 8x16 sprites, background patterns at $1000
        lda #$1E
        sta z:ppumask_shadow                ; sprites and background on
        jsr write_control                   ; MMC1 control $1E
        lda #$00
        sta z:nmi_latch
        jsr wait_frame
        lda #$C0
        jsr black_colors                    ; every color turns black
        jsr wait_frame
        lda #$04
        sta z:prg_bank                      ; this bank
        lda #$0F
        sta backdrop                        ; black
        lda #$10
        sta z:chr_bank0                     ; sprite tiles
        sta chr_bank1                       ; background tiles
        sta split_chr                       ; and below the split
; --- $8046  Show the cutscene.
show_cutscene:
        jsr fill_screens
        jsr hide_sprites
        lda scene
        bne run_script
        jsr run_script                      ; 0 is the opening
        lda script_done
        bne show_cutscene                   ; it finished, so play it again
        lda z:pad_cur
        and #$E6                            ; A, B, Select, Down, and Left
        cmp #$E6                            ; all of them held
        bne opening_skipped
; --- $8061  Those five were held when Start skipped the opening.
sound_test:
        lda #$00
        sta palette_set
        sta palette_set+2
        sta palette_set+3
        lda #$9A
        sta palette_set+4                     ; the sprites
        lda #$53
        sta palette_set+1
        lda #$0F
        sta backdrop                        ; black
        lda #$20
        sta z:picture_at_hi                 ; where this picture goes
        lda #$C0
        sta z:picture_at
        lda #$1C
        ldx #$80                            ; draw it from bank 06
        jsr call_bank
        lda #$21
        sta z:picture_at_hi                 ; where this picture goes
        lda #$E4
        sta z:picture_at
        lda #$3E
        ldx #$80                            ; and the second picture
        jsr call_bank
        lda #$C0
        jsr load_colors                     ; background and sprites
        jsr send_colors
        jsr wait_frame
        lda #$06
        sta a:prg_bank
        ldx #$81                            ; the sound test, in bank 06
        jmp call_bank
; --- $80AE  Start skipped the opening, and those five were not held.
opening_skipped:
        lda #$0D
        jsr run_script
        lda script_done
        bne show_cutscene                   ; that script finished, so play the opening again
        lda #$0C
        jsr run_script                      ; Start skipped it, so the game can start
        rts
; --- $80BE  Play one script.
run_script:
        asl
        tax
        lda script_list,x
        sta script_ptr
        lda script_list+1,x
        sta script_ptr+1
        ldy #$00
        sty script_at
        sty script_done
        sty wait_lo
        sty wait_hi
        sty shade_left
        sty flash_left
        sty line_on
        sty shot_on
        sty band_count
        lda #$0F
        jsr split_sprite                    ; the split sits near the top
; --- $80EC  One frame of the script.
script_frame:
        jsr cutscene_frame
        lda shade_left
        beq check_flash                     ; not fading
        jsr darken_colors
; The fade ran, or there was none.
check_flash:
        lda flash_left
        beq check_line                      ; not flashing
        jsr gray_flash
; A line is showing.
check_line:
        lda line_on
        beq check_shot
        ldx #$43                            ; read it
        jsr call_bank
; The picture may be moving through a shot.
check_shot:
        lda shot_on
        beq move_pictures                   ; it is not
        jsr scroll_step
; Move the pictures, do the next step, and draw them.
move_pictures:
        ldx #$41                            ; move the pictures
        jsr call_bank
        jsr step_script
        ldx #$42                            ; draw them
        jsr call_bank
        jsr hide_from
        lda scene
        cmp #$0B                            ; Act VI, stage 5 is not skipped
        beq script_ended
        jsr buttons_pressed
        and #$10                            ; Start
        bne end_cutscene
; See if the script has finished.
script_ended:
        lda script_done
        beq script_frame
        lda scene
        cmp #$0B                            ; Act VI, stage 5
        bne end_cutscene
        jmp $FFDA                           ; the game ends
; --- $813E  The cutscene is over.
end_cutscene:
        lda #$C0
        jsr black_colors                    ; every color turns black
        lda #$02
        sta sound                           ; a sound plays when a cutscene ends
        jsr wait_frame
        lda #$00
        sta z:nmi_latch
        sta scroll_x
        sta scroll_y
        sta shade_left
        sta flash_left
        sta line_on
        sta shot_on
        bit PPUSTATUS
        sta PPUSCROLL                       ; the picture sits at the top left
        sta PPUSCROLL
        lda #$1E
        jsr write_control
        lda z:ppuctrl_shadow
        and #$FC                            ; the first screen
        sta PPUCTRL
        sta z:ppuctrl_shadow
        jsr fill_screens
        jsr hide_sprites
        rts
; --- $817D  Hide every sprite but the first.
hide_sprites:
        ldx #$04                            ; leave the split
        bne hide_at
; --- $8181  Hide sprites from this one on.
hide_from:
        ldx sprite_i
        beq sprites_hidden                  ; there are none
; Hide this sprite.
hide_at:
        lda #$F8                            ; below the picture
; The next sprite.
hide_next:
        sta sprites,x
        inx
        inx
        inx
        inx
        bne hide_next
sprites_hidden:
        rts
; --- $8192  Fill the screens.
fill_screens:
        jsr picture_off
        lda #$20                            ; the first screen
        jsr fill_screen
        lda #$24
        ldy which_screen
        beq fill_second                     ; the usual second screen
        lda #$28                            ; the other screen
; The second screen.
fill_second:
        jsr fill_screen
        jsr picture_on
        rts
; --- $81AA  Fill one screen with the empty tile.
fill_screen:
        bit PPUSTATUS
        sta PPUADDR
        lda #$00
        sta PPUADDR
        lda #blank_tile                     ; the empty tile
        ldx #$04
        ldy #$C0
; One empty tile. 960 of them, the whole screen.
fill_byte:
        sta PPUDATA
        dey
        bne fill_byte
        dex
        bne fill_byte
        ldy #$40
        lda #$00                            ; the first colors
; The colors for that screen.
fill_attr:
        sta PPUDATA
        dey
        bne fill_attr
        rts
; --- $81CF  Hide the picture.
picture_off:
        lda z:ppuctrl_shadow
        and #$7F                            ; NMI off, so the fill is not seen
        sta PPUCTRL
        lda z:ppumask_shadow
        and #$E6                            ; background and sprites off
        sta PPUMASK
        rts
; --- $81DE  Show the picture.
picture_on:
        lda z:ppuctrl_shadow
        sta PPUCTRL
        lda z:ppumask_shadow
        sta PPUMASK
        rts
; --- $81E9  Write the cartridge control. One bit at a time.
write_control:
        sta MMC1_CTRL
        lsr
        sta MMC1_CTRL
        lsr
        sta MMC1_CTRL
        lsr
        sta MMC1_CTRL
        lsr
        sta MMC1_CTRL
        rts
; --- $81FD  Turn these colors black.
; Bit 6 starts at the last color. Bit 7 does not stop before the background.
black_colors:
        sta $0339
        ldy #$1F
        lda #$0F                            ; black
        bit $0339
        bvs write_black                     ; start at the last color
        ldy #$10                            ; start at the sprites
; This color turns black.
write_black:
        sta colors,y
        bit $0339
        bmi next_black                      ; keep going
        cpy #$11
        beq black_sent                      ; stop before the background
; The next color, down toward the first.
next_black:
        dey
        bpl write_black
black_sent:
        jsr send_colors
        rts
; --- $821E  Send the tiles to the screen.
send_tiles:
        lda tiles_handed
        bne tiles_sent                      ; this frame already sent them
        lda #$03
        sta z:packet+1
        lda #<tile_buf
        sta z:packet
        inc tiles_handed
tiles_sent:
        rts
; --- $822F  Send the colors to the screen.
; The tiles wait until the next frame.
send_colors:
        lda #$03
        sta z:packet+1
        lda #<color_packet
        sta z:packet
        inc tiles_handed
        rts
; --- $823B  One frame of the cutscene.
; Wait until NMI, then scroll.
cutscene_frame:
        ldx z:nmi_latch
        beq cutscene_frame
        inx
        stx z:nmi_latch                     ; NMI stored $FF. This clears it
        stx tile_buf                        ; and clears this frame's tiles
        stx packet_i
        stx tiles_handed
        lda split_on
        beq frame_scroll                    ; the picture is not split
; Wait until the split has passed.
split_clear:
        bit PPUSTATUS
        bvs split_clear
; Wait until the split is reached again.
split_hit:
        bit PPUSTATUS
        bvc split_hit
; Scroll each band, then the whole picture.
frame_scroll:
        ldx #$00
        lda band_count
        bne do_bands
        rts                                 ; the picture is not split into bands
; How many bands are left.
do_bands:
        sta $00
        sta $01
; One band.
scroll_one_band:
        jsr scroll_band
        ldy band_hold,x
        lda band_hold_hi,x
; Wait, so the next band is lower on the screen.
burn_band:
        dey
        bne burn_band
        sec
        sbc #$01
        bcs burn_band
        inx
        inx
        dec $00
        bne scroll_one_band
        bit camera_flags
        bpl add_speeds                      ; the pictures stay
        lda #$22
        sta PPUADDR
        lda #$80
        sta PPUADDR                         ; the split is at this row
        lda split_chr
        jsr set_chr1                        ; pictures for the lower part
; Add each band's speed to how far it is scrolled.
add_speeds:
        ldx #$00
; The next band. The low byte clears the carry.
next_band_pair:
        clc
; One byte of that scroll. The high byte keeps the carry.
add_band_byte:
        lda band_lo,x
        adc band_speed,x
        sta band_lo,x
        inx
        txa
        and #$01
        bne add_band_byte
        dec $01
        bne next_band_pair
        lda scroll_dx_lo
        clc
        adc scroll_x_lo
        sta scroll_x_lo
        lda scroll_dx
        adc scroll_x
        sta scroll_x
        lda #$00
        rol                                 ; crossed 256 pixels
        bit scroll_dx
        bpl nametable_bit
        eor #$01                            ; scrolling left flips the other way
; The other screen, when the scroll crosses it.
nametable_bit:
        eor z:ppuctrl_shadow
        sta z:ppuctrl_shadow
        lda scroll_dy_lo
        clc
        adc scroll_y_lo
        sta scroll_y_lo
        lda scroll_dy
        adc scroll_y
        cmp #$F0                            ; past the bottom of the screen
        bcc store_scroll_y
        bit a:scroll_dy
        bmi y_wrap_neg                      ; scrolling up
        clc
        adc #$10                            ; skip the hidden rows
        bcs store_scroll_y
; Scrolling up. Skip those rows the other way.
y_wrap_neg:
        sbc #$10
store_scroll_y:
        sta scroll_y
        rts
; --- $82E0  Scroll one band of the picture.
scroll_band:
        bit PPUSTATUS
        clc
        lda band_lo,x
        bpl band_positive
        sec                                 ; this band is on the other screen
band_positive:
        lda band_hi,x
        rol
        tay
        lda z:ppuctrl_shadow
        and #$FC                            ; which screen, from this band
        adc #$00
        sta PPUCTRL
        sty PPUSCROLL
        lda scroll_y
        sta PPUSCROLL
        rts
; --- $8301  Wait for the next frame.
wait_frame:
        ldx z:nmi_latch
        beq wait_frame
        inx
        stx z:nmi_latch                     ; NMI stored $FF. This clears it
        stx tile_buf                        ; and clears this frame's tiles
        stx tiles_handed
        stx packet_i
        rts
; --- $8312  Call the routine picked from the list after this jsr.
jump_table:
        asl
        tay
        pla
        sta $0E
        pla
        sta $0F
        iny
        lda ($0E),y
        tax
        iny
        lda ($0E),y
        sta $0F
        stx $0E
        jmp ($000E)
; --- $8328  Place the sprite that splits the picture.
; A is how high it sits.
split_sprite:
        sta sprites                         ; how high
        lda #$F8
        sta sprites+1                       ; an empty tile
        lda #$20
        sta sprites+2                       ; behind the background
        lda #$F8
        sta sprites+3                       ; at the right of the screen
        lda #$01
        sta split_on
        rts
; --- $8340  Load the colors.
; Bit 7 clear starts at the sprites. Bit 6 paints the background color and does not stop there.
load_colors:
        ldx #$00
        ldy #$00
        asl
        sta $00
        bcs read_set                        ; the background colors
        ldx #$11                            ; the sprite colors
        ldy #$04
; The next color set.
read_set:
        sty $01
next_palette_set:
        ldy $01
        inc $01
        lda palette_set,y
        ldy #$00
        asl
        bcc have_table                      ; the first list of colors
        ldy #$02                            ; the second list
have_table:
        pha
        lda cutscene_colors,y
        sta $02
        lda cutscene_colors+1,y
        sta $03
        pla
        sta $04
        lsr
        clc
        adc $04                             ; three colors in a set
        tay
; One of those colors. Every fourth is the background, and it is skipped.
copy_color:
        txa
        and #$03
        beq skip_color
        lda ($02),y
        sta colors,x
        iny
skip_color:
        inx
        txa
        and #$03
        bne copy_color
        lda $00
        bmi more_colors                     ; keep going into the sprites
        cpx #$11
        beq colors_ready                    ; stop after the background
more_colors:
        cpx #$20
        bne next_palette_set
colors_ready:
        lda $00
        bpl send_palette
        jsr fill_backdrop
send_palette:
        jsr send_colors
        rts
; --- $8398  Paint the background color into each set.
fill_backdrop:
        lda backdrop
        ldx #$00
; The background color of this set.
next_backdrop:
        sta colors,x
        inx
        inx
        inx
        inx
        cpx #$20                            ; all eight sets
        bne next_backdrop
        rts
; --- $83A9  Buttons just pressed.
buttons_pressed:
        lda z:pad_cur
        tax
        and #$FF
        eor pad_last
        and z:pad_cur                       ; held now, and not on the last frame
        stx pad_last
        rts
; --- $83B5  Do the next thing the script says.
; A step waits, then runs its commands.
step_script:
        lda wait_lo
        beq wait_high
        dec wait_lo                         ; one frame less
        rts
; The low half has run out.
wait_high:
        lda wait_hi
        beq read_step
        dec wait_hi
        dec wait_lo                         ; another 256 frames
        rts
; --- $83CA  The wait is over. The next two bytes are the next wait.
read_step:
        sta colors_due                      ; no colors are waiting
        jsr next_byte
        sta wait_lo
        jsr next_byte
        sta wait_hi
        and wait_lo
        cmp #$FF
        bne next_command
        lda #$01
        sta script_done                     ; both bytes were $FF. The script is over
; --- $83E5  This step is done.
step_done:
        lda shade_left
        bne step_leave                      ; a fade is using the colors
        lda colors_due
        beq step_leave
        lda #$C0
        jsr load_colors                     ; background, sprites, and the background color
step_leave:
        rts
; --- $83F5  The next command.
; The top two bits pick the group. The low six bits pick the command in that group.
next_command:
        jsr next_byte
        tax
        inx
        beq step_done                       ; $FF ends the commands for this step
        pha
        and #$3F
        tax
        pla
        and #$C0
        cmp #$40
        bcc flash_gray                      ; the small commands
        jmp place_on_screen                ; a picture, or a line
; --- $840A  Flash the picture gray.
flash_gray:
        dex
        bne one_frame
        jsr start_gray
        jmp next_command
; --- $8413  Wait one frame.
one_frame:
        dex
        bne move_camera
        jsr wait_frame
        jmp next_command
; --- $841C  Start a camera move, or stop one.
move_camera:
        jsr next_byte
        dex
        bne begin_fade
        tax
        bne camera_go
        sta band_count                      ; zero stops the camera
        beq next_command
camera_go:
        jsr start_scroll
        jmp next_command
; --- $8430  Start fading the colors.
begin_fade:
        dex
        bne pick_screens
        jsr start_fade
        jmp next_command
; --- $8439  Choose which way the screens sit.
pick_screens:
        dex
        bne cutscene_sound
        ldy #$00
        cmp #$1E                            ; the usual screens
        beq set_screens
        iny                                 ; the other way
set_screens:
        sty which_screen
        jsr write_control
        jmp next_command
; --- $844C  Play a sound. Any other number also turns colors black.
cutscene_sound:
        dex
        bne place_tiles
        sta sound                           ; play this sound
        beq next_command                    ; zero leaves the colors alone
; --- $8454  Draw tiles on the background.
place_tiles:
        dex
        bne pick_pictures
        sta tile_ptr
        jsr next_byte
        sta tile_ptr+1
        jsr next_byte
        sta tile_base
        jsr next_byte
        sta tile_base_hi
        jsr queue_tiles
        jmp next_command
; --- $8470  Choose the pictures.
pick_pictures:
        dex
        bne one_picture
        tax
        bpl upper_pictures
        and #$1F
        sta split_chr                       ; pictures for the lower part of the screen
        jmp next_command
; Pictures for the rest of the screen.
upper_pictures:
        sta a:chr_bank1
        jmp next_command
; --- $8484  One moving picture.
one_picture:
        dex
        bne tint_picture
        pha
        asl
        asl
        asl
        asl
        tax
        jsr picture_motion
        pla
        and #$E0
        sta actor_flags,x                   ; which way it faces, and how it is shown
        jmp next_command
; --- $8499  The background color, and how the picture is shown.
tint_picture:
        dex
        bne scroll_speed
        sta backdrop
        lda z:ppumask_shadow
        and #$1E                            ; keep the sprites and the background
        sta z:ppumask_shadow
        jsr next_byte
        ora z:ppumask_shadow                ; gray, or the red, green, and blue tint
        sta z:ppumask_shadow
        inc colors_due
        jmp next_command
; --- $84B2  How the picture scrolls.
; Zero stops the up and down scroll. $FF stops the sideways scroll.
; A negative byte changes the camera move. Any other byte stops one band per bit.
scroll_speed:
        dex
        bne pick_colors
        tax
        bne check_horizontal
        sta scroll_dy_lo                    ; stop moving up and down
        sta scroll_dy
        beq speed_done
; Not zero. $FF stops the sideways scroll.
check_horizontal:
        inx
        bne not_horizontal
        stx scroll_dx_lo                    ; stop moving sideways
        stx scroll_dx
        beq speed_done
; A negative byte is a camera move.
not_horizontal:
        bpl clear_band_speed
        jsr change_scroll
        jmp next_command
; Each bit that is set stops that band.
clear_band_speed:
        ldx #$00
band_bit:
        lsr
        bcc next_band_bit                   ; this band keeps scrolling
        pha
        lda #$00
        sta band_speed,x
        sta band_speed_hi,x
        pla
next_band_bit:
        inx
        inx
        cpx #$0A                            ; five bands
        bne band_bit
speed_done:
        jmp next_command
; --- $84E7  Which colors to use.
; The low half is how many. Bit 7 picks the sprites; otherwise the background.
pick_colors:
        dex
        bne play_shot
        tay
        and #$0F
        sta $00                             ; how many
        ldx #$04                            ; the sprites
        tya
        bmi store_color
        ldx #$00                            ; the background
store_color:
        jsr next_byte
        sta palette_set,x
        inx
        dec $00
        bne store_color
        inc colors_due
        jmp next_command
; --- $8507  Move through this shot.
play_shot:
        dex
        bne black_command
        ldy #$00
        sty shot_at
        iny
        sty shot_on
        tay
        asl
        sta shot_i
        lda shot_wait,y
        sta shot_delay
        sta shot_left
        jmp next_command
; --- $8524  Turn these colors black.
black_command:
        jsr black_colors
        jmp next_command
; --- $852A  Fill the screens, and draw on the background.
; The low six bits are how many pictures. Zero only fills the screens.
place_on_screen:
        cmp #$80
        bcs place_pictures
        txa
        bne fill_and_draw
        jsr fill_screens
        jmp next_command
fill_and_draw:
        stx bg_left
        jsr fill_screens
        jsr next_byte
        sta backdrop
        ldx #$01
; Three background color sets.
bg_palette_set:
        jsr next_byte
        sta palette_set,x
        inx
        cpx #$04
        bne bg_palette_set
; One picture, at the next place.
draw_bg:
        jsr next_byte
        asl
        tax
        lda screen_pos,x
        sta z:picture_at                    ; where this picture goes
        lda screen_pos+1,x
        sta z:picture_at_hi
        jsr next_byte
        ldx #$80                            ; draw it from bank 06
        jsr call_bank
        dec bg_left
        bne draw_bg
        inc colors_due
        jmp next_command
; --- $8572  Put pictures on screen, or hide them.
; The low six bits are how many. Zero hides them all.
place_pictures:
        cmp #$C0
        bcs say_line
        txa
        bne place_some
        jsr hide_pictures
        jmp next_command
place_some:
        stx actor_left
        ldx #$00
; The four sprite color sets.
read_sprite_set:
        jsr next_byte
        sta palette_set+4,x
        inx
        cpx #$04
        bne read_sprite_set
        ldx #$00
; One moving picture. Where it stands, how it faces, and which picture.
place_one:
        jsr next_byte
        sta actor_x,x
        jsr next_byte
        asl
        php
        lsr
        sta actor_y,x
        plp
        lda #$00
        sta actor_y_lo,x
        ror
        sta actor_x_lo,x                    ; half a pixel over, when that byte was negative
        jsr next_byte
        sta actor_flags,x
        jsr next_byte
        sta actor_pic,x
        tay
        bpl one_placed                      ; one picture, not a list of poses
        and #$7F
        tay
        lda pose_wait,y
        sta actor_time,x                    ; how long the first pose stays
        lda #$00
        sta actor_pose,x
one_placed:
        jsr picture_motion
        txa
        clc
        adc #$10                            ; the next picture
        tax
        dec actor_left
        bne place_one
        jsr hide_pictures                   ; hide the ones that were not just placed
        inc colors_due
        jmp next_command
; --- $85DD  Start a line. The low six bits are how long each letter waits.
say_line:
        stx line_speed
        jsr next_byte                       ; which line
        ldx #$44                            ; start it
        jsr call_bank
        jmp next_command
; --- $85EB  Hide the moving pictures.
; X is the first one to hide. $40 hides none.
hide_pictures:
        lda #$00
        cpx #$40
        beq hide_done
        cpx #$30
        beq hide_last
        cpx #$20
        beq hide_two
        cpx #$10
        beq hide_three
        sta actor_move                      ; the first picture
hide_three:
        sta actor_move+$10
hide_two:
        sta actor_move+$20
hide_last:
        sta actor_move+$30
hide_done:
        rts
; --- $860A  How this picture moves.
; It stays, it slides, it walks a path, or it slides and its speed changes.
picture_motion:
        jsr next_byte
        pha
        rol
        rol
        rol
        and #$03
        clc
        adc #$01
        sta actor_move,x
        tay
        pla
        and #$3F
        dey
        dey
        bmi motion_stay                     ; it stays
        bne motion_path
        asl
        asl
        tay
        lda slide_speed,y                   ; sideways
        sta $0349,x
        lda slide_speed+1,y
        sta $034A,x
        lda slide_speed+2,y                 ; up and down
        sta $034B,x
        lda slide_speed+3,y
        sta $034C,x
motion_stay:
        rts
; Walk a path. The byte picks the path, and how long it waits on the first place.
motion_path:
        dey
        bne motion_speed
        sta $0349,x                         ; which path
        tay
        lda path_wait,y
        sta $034A,x                         ; frames on this place
        lda #$00
        sta $034B,x                         ; the first place
        rts
; Slide, and change speed.
motion_speed:
        sta $00
        asl
        clc
        adc $00
        asl                                     ; six bytes each
        tay
        lda speed_change,y                  ; sideways
        sta $0349,x
        lda speed_change+1,y
        sta $034A,x
        lda speed_change+2,y                ; up and down
        sta $034B,x
        lda speed_change+3,y
        sta $034C,x
        lda speed_change+4,y                ; how much the sideways speed changes
        sta $034D,x
        lda speed_change+5,y                ; and the up and down speed
        sta $034F,x
        rts
; --- $867F  The next byte of the script.
next_byte:
        ldy script_at
        lda (script_ptr),y
        iny
        bne script_next
        inc script_ptr+1
script_next:
        sty script_at
        rts
; --- $868D  Start fading the colors.
; The top bit jumps several shades and starts from black.
; The next two bits choose which colors. The rest is the wait between shades.
start_fade:
        tax
        lsr
        lsr
        and #$1F
        tay
        lda shade_delay,y
        sta shade_load
        sta shade_wait
        txa
        and #$80
        sta fade_mode
        txa
        ror
        ror
        ror
        and #$C0                            ; the low two bits choose the colors
        sta fade_which
        lda #$04
        sta shade_left                      ; four shades
        lda #$C0
        jsr load_colors
        bit fade_mode
        bpl fade_ready
        lda fade_which
        jsr black_colors                    ; start from black
fade_ready:
        rts
; --- $86C1  Start flashing the picture gray.
; It flips every other frame, 62 times, then the color comes back.
start_gray:
        lda #$3F
        pha
        lsr
        and #$70
        sta flash_time                      ; one frame between flips
        pla
        and #$1F
        asl
        sta flash_left                      ; 62 flips
        rts
; --- $86D2  Start this camera move.
; The top two bits say whether the pictures change at the split.
start_scroll:
        tay
        asl
        and #$7E
        tax
        lda camera_move,x
        sta $00
        lda camera_move+1,x
        sta $01
        tya
        and #$C0
        sta camera_flags
        ldy #$00
        sty shot_on
        sty scroll_x_lo
        sty scroll_y_lo
        lda ($00),y
        iny
        sta band_count
        sta $02                             ; bands still to copy
        lda z:ppuctrl_shadow
        and #$FC
        ora ($00),y                         ; which screen
        iny
        sta z:ppuctrl_shadow
        lda ($00),y
        iny
        sta sprites                         ; how high the split sits
        lda ($00),y
        iny
        sta scroll_x
        lda ($00),y
        iny
        sta scroll_y
        lda ($00),y
        iny
        sta scroll_dx_lo
        lda ($00),y
        iny
        sta scroll_dx
        lda ($00),y
        iny
        sta scroll_dy_lo
        lda ($00),y
        iny
        sta scroll_dy
        lda band_count
        beq scroll_ready                    ; no bands
        ldx #$00
; One band. Where it starts, how long until the next, and how fast it moves.
copy_band:
        lda ($00),y
        iny
        sta band_hi,x
        lda #$00
        sta band_lo,x
        lda ($00),y
        iny
        sta band_hold,x
        lda ($00),y
        iny
        sta band_hold_hi,x
        lda ($00),y
        iny
        sta band_speed,x
        lda ($00),y
        iny
        sta band_speed_hi,x
        inx
        inx
        dec $02
        bne copy_band
scroll_ready:
        rts
; --- $8756  Change that move.
; The picture stays where it is. The speeds change.
change_scroll:
        asl
        and #$7E
        tax
        lda camera_move,x
        sta $00
        lda camera_move+1,x
        sta $01
        ldy #$00
        lda ($00),y
        iny
        sta $02                             ; how many bands
        iny                                 ; skip the screen, the split, and where it is scrolled
        iny
        iny
        iny
        lda ($00),y
        iny
        sta scroll_dx_lo
        lda ($00),y
        iny
        sta scroll_dx
        lda ($00),y
        iny
        sta scroll_dy_lo
        lda ($00),y
        iny
        sta scroll_dy
        lda a:$02
        beq change_ready                    ; no bands
        ldx #$00
; This band's new speed. Where it is, and the wait, stay.
copy_speed:
        iny
        iny
        iny
        lda ($00),y
        iny
        sta band_speed,x
        lda ($00),y
        iny
        sta band_speed_hi,x
        inx
        inx
        dec $02
        bne copy_speed
change_ready:
        rts
; --- $87A0  One step darker.
darken_colors:
        lda shade_wait
        beq do_shade
        dec shade_wait
        rts
; The wait is over.
do_shade:
        lda shade_load
        sta shade_wait
        lda fade_mode
        bpl shade_colors
        lda #$C0
        jsr load_colors                     ; start this shade from the real colors
shade_colors:
        lda shade_left
        sec
        sbc #$01
        asl
        asl
        asl
        asl
        sta $00                             ; how far to jump, when the fade jumps
        ldy #$00
        bit fade_which
        bmi shade_one                       ; start at the first color
        ldy #$11                            ; start at the sprites
; One color.
shade_one:
        lda fade_mode
        bmi shade_jump                      ; jump several shades
        lda colors,y
        sec
        sbc #$10                            ; one shade darker
        bpl store_shade
        lda #$0F                            ; black
store_shade:
        sta colors,y
        bit fade_which
        bvs shade_next                      ; keep going
        cpy #$10
        beq shade_sent                      ; stop after the background
shade_next:
        iny
        cpy #$20
        bne shade_one
shade_sent:
        dec shade_left
        jsr send_colors
        rts
; Jump several shades. The low half of the color stays.
shade_jump:
        lda colors,y
        and #$F0
        sec
        sbc $00
        sta $01
        bmi shade_black
        lda colors,y
        and #$0F
        ora $01
        jmp store_shade
shade_black:
        lda #$0F                            ; black
        bne store_shade
; --- $880F  One step of the gray flash.
gray_flash:
        lda flash_time
        tax
        and #$07
        beq flip_gray
        dec flash_time                      ; one frame less
        rts
; Flip between gray and color, and count that wait again.
flip_gray:
        txa
        lsr
        lsr
        lsr
        lsr
        ora flash_time
        sta flash_time
        lda z:ppumask_shadow
        eor #$01                            ; gray, or color again
        sta z:ppumask_shadow
        dec flash_left
        bne flash_done
        lsr z:ppumask_shadow                ; the last flip leaves it in color
        asl z:ppumask_shadow
flash_done:
        rts
; --- $8836  Copy tiles into the list the screen draws.
; A zero ends the list. Bit 7 of a run writes down the column.
queue_tiles:
        ldy #$00
        ldx packet_i
; The next run.
tile_run:
        lda (tile_ptr),y
        sta tile_buf,x
        bne tile_bytes
        stx packet_i
        jsr send_tiles
        rts
tile_bytes:
        and #$7F
        sta $02                             ; how many tiles
        iny
        clc
        lda tile_base
        adc (tile_ptr),y
        sta tile_buf+1,x                    ; where they go
        iny
        lda tile_base_hi
        adc (tile_ptr),y
        sta tile_buf+2,x
        iny
        inx
        inx
        inx
; One tile of this run.
copy_tile:
        lda (tile_ptr),y
        sta tile_buf,x
        iny
        inx
        dec $02
        bne copy_tile
        beq tile_run
; --- $8871  The next place in this shot.
scroll_step:
        lda shot_left
        beq next_place
        dec shot_left
        rts
; The wait is over.
next_place:
        lda shot_delay
        sta shot_left
        ldx shot_i
        lda shot_place,x
        sta $00
        lda shot_place+1,x
        sta $01
        ldy shot_at
; A negative byte repeats the shot.
read_place:
        lda ($00),y
        bpl apply_place
        ldy #$00
        beq read_place
apply_place:
        lda z:ppuctrl_shadow
        and #$FC
        ora ($00),y                         ; which screen
        sta z:ppuctrl_shadow
        iny
        lda ($00),y
        iny
        sta scroll_x
        lda ($00),y
        iny
        sta scroll_y
        sty shot_at
        rts

; Frames between shades. 0 through 31.
shade_delay:
        .byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
        .byte $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $1D, $1E, $1F
; How long the first pose stays. The low half counts down. The high half is used again.
; Twenty of them.
pose_wait:
        .byte $44, $33, $33, $FF, $33, $22, $55, $33, $55, $22, $33, $33, $88, $33, $66, $66
        .byte $FF, $88, $AA, $33
; How long a picture waits on the first place of its path.
path_wait:
        .byte $44, $44
; Frames to wait before the next place.
shot_wait:
        .byte $00, $00
; Places the picture moves. Two lists.
shot_place:
        .byte $EB, $88, $F8, $88, $00, $01, $03, $00, $04, $00, $00, $00, $04, $00, $03, $01
        .byte $FF, $00, $00, $EF, $00, $01, $EF, $00, $00, $EE, $00, $00, $EF, $01, $FF, $EE
        .byte $FF
; A camera move. Twenty-eight of them.
camera_move:
        .byte $40, $89, $5D, $89, $6B, $89, $79, $89, $87, $89, $95, $89, $A3, $89, $B1, $89
        .byte $C4, $89, $CD, $89, $DB, $89, $E9, $89, $F7, $89, $0A, $8A, $1D, $8A, $2B, $8A
        .byte $39, $8A, $51, $8A, $5F, $8A, $6D, $8A, $80, $8A, $8E, $8A, $9C, $8A, $AA, $8A
        .byte $B8, $8A, $C6, $8A, $D4, $8A, $EC, $8A, $04, $00, $7C, $00, $00, $00, $00, $00
        .byte $00, $00, $07, $01, $F0, $FF, $00, $37, $01, $E0, $FF, $00, $73, $01, $D0, $FF
        .byte $00, $01, $00, $C0, $FF, $01, $00, $0F, $00, $00, $00, $00, $00, $00, $00, $02
        .byte $00, $00, $00, $01, $00, $80, $00, $00, $00, $00, $00, $00, $00, $02, $00, $00
        .byte $00, $01, $00, $80, $00, $00, $00, $08, $00, $00, $00, $02, $00, $00, $00, $01
        .byte $00, $80, $00, $00, $00, $F8, $00, $00, $00, $02, $00, $00, $00, $01, $01, $80
        .byte $00, $00, $80, $00, $00, $00, $00, $02, $00, $00, $00, $01, $00, $80, $00, $00
        .byte $80, $00, $00, $00, $00, $02, $00, $00, $00, $02, $00, $0F, $00, $E0, $00, $00
        .byte $18, $00, $80, $01, $0A, $00, $00, $00, $01, $00, $00, $00, $00, $01, $0F, $00
        .byte $00, $00, $00, $00, $00, $01, $01, $80, $00, $00, $00, $00, $00, $00, $00, $02
        .byte $00, $00, $00, $01, $00, $0F, $00, $A0, $00, $00, $80, $00, $00, $02, $00, $00
        .byte $00, $01, $00, $0F, $00, $00, $00, $00, $00, $00, $00, $02, $00, $00, $00, $02
        .byte $00, $8E, $00, $00, $40, $00, $00, $00, $00, $66, $01, $30, $00, $00, $02, $00
        .byte $40, $00, $02, $00, $2E, $00, $D0, $00, $00, $80, $00, $80, $9F, $05, $00, $00
        .byte $00, $70, $01, $00, $00, $01, $00, $80, $00, $00, $00, $08, $00, $00, $00, $02
        .byte $00, $00, $00, $01, $00, $80, $B0, $00, $00, $F8, $00, $00, $00, $02, $00, $00
        .byte $00, $03, $00, $30, $00, $00, $E0, $FF, $00, $00, $00, $70, $01, $F8, $FF, $00
        .byte $4F, $05, $C0, $FF, $00, $01, $00, $00, $FE, $01, $00, $80, $68, $00, $80, $FF
        .byte $00, $00, $00, $02, $00, $00, $00, $01, $00, $80, $80, $00, $00, $F8, $00, $00
        .byte $00, $02, $00, $00, $00, $02, $01, $8E, $00, $00, $C0, $FF, $00, $00, $80, $66
        .byte $01, $D0, $FF, $80, $02, $00, $C0, $FF, $01, $01, $80, $00, $00, $00, $08, $00
        .byte $00, $80, $02, $00, $00, $00, $01, $00, $80, $00, $00, $00, $00, $00, $00, $80
        .byte $02, $00, $00, $FC, $01, $01, $80, $80, $00, $80, $00, $00, $00, $00, $02, $00
        .byte $00, $00, $01, $00, $80, $80, $00, $80, $FF, $00, $00, $00, $02, $00, $00, $00
        .byte $01, $00, $80, $A0, $00, $00, $F0, $00, $00, $00, $02, $00, $00, $00, $01, $01
        .byte $80, $B0, $00, $00, $F8, $00, $00, $00, $02, $00, $00, $00, $03, $00, $0F, $00
        .byte $B0, $00, $00, $00, $04, $00, $9A, $02, $00, $00, $80, $BE, $05, $00, $00, $00
        .byte $70, $01, $00, $00, $03, $00, $0F, $00, $40, $00, $00, $00, $FC, $00, $9A, $02
        .byte $00, $00, $80, $BE, $05, $00, $00, $00, $70, $01, $00, $00
; How fast a picture slides. Sideways, then up and down.
; The second byte of each is the rest of that speed. Twenty-six of them.
slide_speed:
        .byte $00, $04, $00, $00, $00, $FC, $00, $00, $00, $04, $00, $FC, $00, $FC, $00, $FC
        .byte $00, $00, $00, $04, $C0, $FF, $00, $00, $40, $00, $00, $00, $10, $00, $30, $00
        .byte $C0, $FF, $E0, $FF, $00, $00, $40, $00, $80, $00, $00, $FE, $00, $FE, $00, $02
        .byte $80, $00, $00, $00, $00, $FC, $40, $00, $00, $F8, $00, $00, $E0, $FF, $00, $00
        .byte $F0, $FF, $00, $00, $20, $00, $00, $00, $80, $FF, $00, $00, $00, $00, $00, $02
        .byte $00, $00, $00, $FE, $08, $00, $0A, $00, $00, $00, $0A, $00, $04, $00, $20, $00
        .byte $00, $00, $10, $00, $00, $00, $0C, $00
; A picture that slides and speeds up. Sideways speed, up and down speed,
; then how much each one changes. Twelve of them.
speed_change:
        .byte $38, $00, $90, $FF, $00, $01, $E0, $FF, $90, $FF, $00, $01, $38, $00, $01, $00
        .byte $00, $01, $E0, $FF, $0F, $00, $00, $01, $00, $FC, $00, $00, $02, $10, $00, $04
        .byte $00, $00, $FC, $00, $00, $FC, $00, $00, $40, $00, $80, $04, $00, $03, $B8, $D0
        .byte $80, $FB, $00, $FD, $48, $30, $80, $03, $00, $FF, $C8, $F0, $80, $FC, $00, $01
        .byte $38, $10, $00, $01, $D0, $FF, $00, $03

; --- $8BB4  Where the cutscene colors are.
cutscene_colors:
        .byte $B8, $8B, $B7, $8C, $0F, $30, $36, $0F, $22, $36, $0F, $38, $2B, $0F, $19, $29
        .byte $0F, $10, $16, $0F, $26, $37, $0F, $10, $16, $35, $26, $16, $30, $10, $11, $0F
        .byte $33, $14, $12, $34, $14, $12, $16, $0F, $27, $26, $17, $32, $22, $35, $23, $10
        .byte $30, $22, $12, $25, $0F, $22, $12, $0F, $16, $36, $03, $27, $37, $03, $22, $37
        .byte $27, $22, $37, $0F, $30, $27, $0F, $26, $17, $36, $30, $25, $0F, $30, $10, $0F
        .byte $10, $26, $14, $24, $34, $0F, $26, $16, $0F, $26, $27, $0F, $16, $27, $0F, $2C
        .byte $36, $0F, $2C, $0C, $30, $32, $22, $3D, $37, $17, $36, $26, $17, $0F, $35, $17
        .byte $0F, $34, $14, $0F, $23, $24, $16, $26, $30, $0F, $11, $35, $0F, $11, $30, $37
        .byte $31, $30, $0F, $35, $16, $0F, $10, $16, $0F, $31, $16, $02, $15, $27, $16, $24
        .byte $27, $14, $17, $27, $14, $27, $30, $35, $24, $16, $12, $32, $36, $23, $32, $36
        .byte $12, $17, $23, $0F, $35, $00, $0F, $11, $01, $0F, $21, $01, $22, $12, $31, $02
        .byte $12, $22, $0F, $12, $36, $0F, $12, $17, $30, $17, $36, $00, $02, $02, $30, $38
        .byte $35, $0F, $37, $19, $0F, $02, $03, $0F, $00, $10, $0F, $35, $12, $0F, $07, $05
        .byte $0F, $27, $35, $0F, $31, $35, $0F, $18, $0A, $0F, $36, $26, $0F, $27, $17, $11
        .byte $16, $08, $26, $16, $08, $0F, $18, $30, $0F, $30, $17, $23, $34, $22, $0F, $20
        .byte $17, $0F, $36, $17, $0F, $14, $17, $23, $34, $12, $0F, $00, $07, $26, $30, $22
        .byte $0F, $0F, $0F, $06, $16, $26, $0F, $30, $30, $0F, $10, $30, $0F, $10, $00, $0F
        .byte $10, $30, $30, $30, $30, $26, $30, $0F, $26, $29, $0F, $26, $24, $0F, $26, $0F
        .byte $0F, $05, $14, $24, $15, $24, $34, $15, $14, $24, $34, $26, $15, $30, $26, $06
        .byte $25, $16, $05, $16, $38, $26, $16, $06, $26, $0F, $07, $13, $0F, $02, $17, $0F
        .byte $12, $13, $0F, $10, $07, $0F, $10, $00, $0F, $0F, $07, $07, $30, $30, $0F, $30
        .byte $30, $30, $30, $0F, $0F, $15, $15, $15, $15, $0F, $0F, $16, $06, $06, $26, $38
        .byte $0F, $26, $36, $12, $16, $14, $30, $22, $22, $04, $00, $00, $F8, $F8, $F8, $F8
        .byte $04, $20, $00, $F8, $F8, $F8, $F8, $00, $08, $00, $00, $F8, $28, $2A, $2C, $2E
        .byte $38, $F8, $F8, $08, $20, $00, $F8, $29, $2B, $2D, $2F, $39, $3B, $F8, $00, $08
        .byte $00, $00, $F8, $80, $82, $84, $86, $90, $92, $F8, $08, $20, $00, $F8, $81, $83
        .byte $85, $87, $91, $93, $F8, $00, $08, $00, $00, $F8, $88, $8A, $8C, $8E, $98, $9A
        .byte $F8, $08, $20, $00, $26, $89, $8B, $8D, $8F, $99, $9B, $30, $00, $08, $00, $00
        .byte $27, $A0, $A2, $A4, $A6, $B0, $B2, $31, $08, $20, $00, $F8, $F8, $F8, $A5, $A7
        .byte $B1, $B3, $F8, $00, $08, $00, $00, $01, $FA, $FA, $03, $FA, $05, $12, $10, $08
        .byte $20, $00, $13, $FA, $FA, $07, $08, $0A, $1D, $11, $00, $08, $00, $00, $13, $FA
        .byte $0C, $0E, $18, $1A, $1E, $FA, $08, $20, $00, $FA, $FA, $09, $FA, $FA, $0F, $1F
        .byte $49, $00, $08, $00, $00, $FA, $FA, $0B, $FA, $FA, $0D, $FA, $20, $08, $20, $00
        .byte $FA, $FA, $19, $FA, $FA, $1B, $FA, $21, $00, $08, $00, $00, $FA, $FA, $FA, $FA
        .byte $FA, $1C, $FA, $40, $08, $20, $00, $FA, $FA, $FA, $FA, $FA, $FA, $48, $41, $00
        .byte $88, $00, $00, $F8, $F8, $96, $97, $C0, $C1, $FA, $C3, $88, $01, $00, $F8, $F8
        .byte $F8, $F8, $F8, $F8, $C4, $C5, $00, $88, $00, $00, $F8, $F8, $F8, $F8, $F8, $F8
        .byte $C6, $C7, $88, $01, $00, $F8, $F8, $F8, $F8, $F8, $F8, $F8, $C2, $00, $09, $00
        .byte $00, $53, $F8, $F8, $F8, $F8, $F8, $F8, $F8, $54, $00, $87, $00, $00, $F8, $F8
        .byte $F8, $F8, $F8, $F8, $F0, $88, $01, $00, $F8, $F8, $F8, $F8, $F8, $F8, $F8, $F1
        .byte $00, $86, $00, $00, $F8, $F8, $F8, $F8, $F8, $E4, $85, $21, $00, $F8, $F8, $F8
        .byte $F8, $E5, $00, $88, $00, $00, $F8, $F8, $F8, $F8, $F8, $F8, $F8, $E7, $86, $41
        .byte $00, $F8, $F8, $F8, $F8, $F8, $E5, $00, $8A, $00, $00, $F8, $F8, $F8, $F8, $F8
        .byte $F8, $F8, $F8, $F8, $E4, $8A, $01, $00, $F8, $F8, $F8, $F8, $F8, $F8, $F8, $F8
        .byte $F8, $E6, $00, $02, $00, $00, $F0, $F0, $02, $08, $00, $FF, $FF, $02, $10, $00
        .byte $0F, $0F, $00, $02, $00, $00, $D0, $B0, $02, $08, $00, $DD, $FF, $02, $10, $00
        .byte $0D, $0F, $00, $01, $00, $00, $FA, $01, $08, $00, $FF, $00

; --- $8EA0  Places on the background.
screen_pos:
        .byte $80, $20, $00, $21, $80, $22, $40, $24, $C4, $20, $D0, $21, $CE, $21, $0C, $21
        .byte $08, $21, $48, $21, $00, $25, $80, $24, $00, $24, $04, $21, $48, $25, $14, $21
        .byte $14, $25, $0A, $21, $C0, $20, $80, $24, $CC, $25, $C0, $24, $08, $25, $8C, $22
        .byte $98, $21, $CC, $24, $A4, $21, $C0, $21, $04, $25, $0C, $25, $0A, $25, $4C, $21

; --- $8EE0  Which script a cutscene runs.
script_list:
        .word script_00                     ; The opening, and Act I, stage 1.
        .word script_01                     ; Act I, stage 2.
        .word script_02                     ; Act II, stage 3.
        .word script_03                     ; Act III, stage 3.
        .word script_04                     ; Act IV, stage 1.
        .word script_05                     ; Act IV, stage 4.
        .word script_06                     ; Act V, stage 3.
        .word script_07                     ; Act V, stage 4.
        .word script_08                     ; Act VI, stage 3.
        .word script_09                     ; Act VI, stage 4.
        .word script_0A                     ; Act VI, stage 4.
        .word script_0B                     ; Act VI, stage 5.
        .word script_0C                     ; Start skipped the one below. Then the game starts.
        .word script_0D                     ; Start skipped the opening. If this finishes, the opening plays again.

; The opening, and Act I, stage 1.
script_00:
        .byte $EF, $00, $05, $1E, $03, $48, $02, $81, $00, $00, $00, $53, $40, $30, $00, $32
        .byte $01, $43, $0F, $89, $00, $54, $12, $1C, $14, $36, $1A, $3E, $04, $B3, $FF, $3B
        .byte $00, $04, $32, $FF, $1D, $00, $09, $00, $49, $FF, $A5, $00, $03, $4A, $04, $BE
        .byte $FF, $00, $00, $0B, $00, $09, $00, $01, $FF, $01, $00, $06, $36, $0C, $04, $00
        .byte $86, $00, $54, $FF, $01, $00, $0C, $04, $00, $87, $00, $54, $FF, $01, $00, $0C
        .byte $04, $00, $88, $00, $54, $FF, $01, $00, $0C, $04, $00, $89, $00, $54, $FF, $01
        .byte $00, $0C, $04, $00, $86, $00, $54, $FF, $01, $00, $0C, $04, $00, $87, $00, $54
        .byte $FF, $01, $00, $0C, $04, $00, $88, $00, $54, $FF, $2B, $01, $0C, $04, $00, $53
        .byte $00, $00, $FF, $00, $00, $0E, $C0, $FF, $2B, $01, $05, $1F, $03, $40, $06, $26
        .byte $02, $41, $01, $01, $02, $03, $00, $00, $82, $04, $05, $00, $00, $1C, $54, $00
        .byte $00, $01, $5C, $50, $00, $01, $01, $04, $BF, $FF, $00, $00, $0E, $C0, $FF, $3B
        .byte $00, $03, $82, $02, $41, $02, $00, $00, $00, $01, $21, $81, $95, $96, $97, $98
        .byte $74, $2C, $60, $07, $01, $FF, $3B, $00, $81, $1C, $1B, $1D, $17, $0C, $2C, $60
        .byte $06, $01, $FF, $00, $00, $0E, $C0, $FF, $77, $00, $03, $84, $02, $41, $02, $03
        .byte $00, $00, $01, $19, $81, $96, $00, $00, $00, $64, $28, $20, $80, $01, $06, $37
        .byte $FF, $77, $00, $03, $83, $81, $1B, $00, $00, $00, $1A, $28, $60, $80, $01, $06
        .byte $37, $FF, $00, $00, $0E, $C0, $FF, $59, $00, $03, $84, $02, $41, $02, $20, $00
        .byte $00, $01, $01, $82, $95, $96, $97, $98, $00, $30, $20, $14, $01, $74, $2C, $40
        .byte $07, $80, $06, $37, $FF, $59, $00, $03, $83, $82, $1C, $1B, $1D, $17, $00, $30
        .byte $20, $14, $01, $08, $2C, $40, $06, $81, $06, $37, $FF, $00, $00, $0E, $C0, $FF
        .byte $3B, $00, $03, $84, $02, $41, $02, $03, $00, $00, $01, $19, $81, $96, $00, $00
        .byte $00, $64, $28, $20, $80, $01, $06, $37, $FF, $3B, $00, $03, $83, $81, $1B, $1B
        .byte $1D, $17, $1A, $28, $60, $80, $01, $06, $37, $FF, $1D, $00, $03, $84, $81, $96
        .byte $00, $00, $00, $64, $28, $20, $08, $43, $06, $35, $FF, $1D, $00, $03, $83, $81
        .byte $1B, $1B, $1D, $17, $1A, $28, $60, $08, $42, $06, $35, $FF, $00, $00, $0E, $C0
        .byte $FF, $77, $00, $03, $41, $02, $41, $01, $01, $02, $03, $00, $00, $82, $05, $04
        .byte $00, $00, $54, $3C, $00, $03, $C1, $20, $40, $00, $02, $C0, $FF, $77, $00, $01
        .byte $82, $05, $04, $00, $00, $45, $23, $00, $05, $01, $3A, $27, $00, $04, $01, $06
        .byte $36, $FF, $59, $00, $09, $01, $C2, $09, $00, $C3, $FF, $00, $00, $0E, $C0, $FF
        .byte $3B, $00, $05, $1E, $03, $82, $06, $27, $02, $41, $02, $03, $96, $00, $01, $02
        .byte $82, $05, $11, $1B, $96, $20, $14, $20, $0A, $01, $5C, $2F, $20, $0C, $01, $FF
        .byte $06, $00, $09, $20, $44, $FF, $14, $00, $82, $05, $11, $1B, $96, $20, $30, $20
        .byte $0B, $01, $5C, $2F, $20, $0C, $01, $06, $39, $FF, $77, $00, $82, $05, $11, $1B
        .byte $96, $20, $2E, $20, $0A, $01, $5C, $2F, $20, $0C, $01, $FF, $09, $00, $82, $05
        .byte $11, $1B, $96, $1E, $30, $20, $0A, $01, $5C, $2F, $20, $0C, $01, $FF, $09, $00
        .byte $82, $05, $11, $1B, $96, $1E, $30, $20, $0B, $01, $5C, $2F, $20, $0C, $01, $FF
        .byte $B1, $02, $C0, $00, $82, $05, $11, $1B, $96, $1A, $39, $20, $0B, $01, $5C, $2F
        .byte $20, $0C, $01, $FF, $95, $00, $04, $3F, $FF, $3B, $00, $02, $42, $0F, $12, $13
        .byte $14, $07, $03, $07, $03, $81, $15, $00, $00, $00, $40, $30, $00, $0D, $01, $04
        .byte $97, $FF, $93, $02, $C0, $01, $FF, $00, $00, $0E, $C0, $FF, $39, $02, $02, $41
        .byte $0F, $0E, $00, $00, $08, $04, $81, $0F, $00, $00, $00, $2C, $30, $00, $0E, $01
        .byte $C0, $02, $FF, $00, $00, $0E, $C0, $FF, $3B, $00, $02, $42, $0F, $12, $13, $14
        .byte $07, $03, $07, $03, $81, $15, $00, $00, $00, $40, $30, $00, $0D, $01, $04, $8F
        .byte $FF, $2B, $01, $C0, $03, $FF, $00, $00, $0E, $C0, $FF, $EF, $00, $02, $41, $02
        .byte $01, $10, $11, $01, $06, $81, $06, $07, $08, $00, $4C, $2C, $20, $10, $01, $C0
        .byte $04, $FF, $95, $00, $04, $3F, $06, $25, $FF, $FF, $FF

; Act I, stage 2.
script_01:
        .byte $00, $00, $03, $85, $0B, $FF, $06, $28, $02, $81, $06, $07, $08, $00, $CC, $AC
        .byte $00, $0F, $45, $42, $02, $01, $10, $11, $0A, $21, $01, $05, $FF, $B3, $00, $03
        .byte $85, $FF, $47, $01, $C2, $05, $FF, $00, $00, $0E, $C0, $FF, $00, $00, $03, $86
        .byte $0B, $FF, $02, $42, $02, $01, $10, $11, $0A, $21, $01, $07, $81, $06, $07, $08
        .byte $00, $4C, $2C, $00, $11, $01, $FF, $81, $00, $C2, $06, $FF, $00, $00, $82, $06
        .byte $07, $08, $00, $4C, $AC, $00, $11, $45, $40, $30, $20, $15, $46, $FF, $94, $00
        .byte $03, $86, $C2, $07, $FF, $67, $01, $0B, $FF, $09, $00, $01, $09, $01, $01, $FF
        .byte $00, $00, $0E, $C0, $FF, $1D, $00, $03, $8D, $0B, $00, $80, $02, $41, $11, $9F
        .byte $18, $19, $0B, $09, $FF, $77, $00, $C2, $08, $FF, $3B, $00, $03, $8D, $FF, $59
        .byte $00, $0B, $00, $FF, $00, $00, $0E, $C0, $FF, $0E, $00, $03, $82, $02, $41, $02
        .byte $01, $10, $11, $01, $08, $81, $06, $07, $08, $00, $4C, $2C, $00, $12, $01, $FF
        .byte $77, $00, $0A, $00, $00, $0C, $08, $81, $82, $83, $84, $81, $81, $81, $81, $06
        .byte $3B, $FF, $B3, $00, $04, $3F, $06, $29, $FF, $1F, $00, $80, $0A, $33, $00, $03
        .byte $54, $05, $1E, $06, $2A, $02, $42, $0F, $0D, $53, $00, $0D, $1A, $17, $1D, $FF
        .byte $1F, $00, $03, $55, $FF, $B3, $00, $0B, $01, $81, $A1, $9A, $9B, $9C, $58, $2C
        .byte $00, $51, $01, $04, $A9, $FF, $00, $00, $0E, $C0, $FF, $EF, $00, $80, $02, $03
        .byte $82, $41, $33, $40, $41, $00, $0D, $22, $04, $BF, $06, $30, $FF, $D1, $00, $C2
        .byte $09, $FF, $1D, $00, $81, $54, $54, $54, $54, $47, $30, $20, $15, $45, $FF, $EF
        .byte $00, $09, $20, $01, $FF, $00, $00, $0E, $C0, $FF, $3B, $00, $02, $41, $0F, $40
        .byte $41, $00, $0D, $24, $81, $10, $3A, $00, $00, $38, $30, $00, $16, $01, $04, $BD
        .byte $FF, $B3, $00, $C2, $0A, $FF, $00, $00, $0E, $C0, $FF, $67, $01, $02, $41, $33
        .byte $40, $41, $00, $0D, $23, $81, $06, $07, $08, $00, $40, $30, $00, $15, $01, $04
        .byte $95, $C2, $0B, $FF, $00, $00, $0E, $C0, $FF, $49, $01, $80, $03, $82, $02, $42
        .byte $0F, $11, $16, $09, $07, $0A, $07, $0A, $C2, $0C, $FF, $00, $00, $0E, $C0, $FF
        .byte $09, $00, $03, $8E, $0B, $FF, $02, $42, $13, $11, $16, $09, $11, $0B, $0A, $32
        .byte $82, $01, $10, $11, $17, $34, $30, $00, $17, $01, $A4, $2E, $60, $07, $01, $FF
        .byte $B3, $00, $C2, $0D, $FF, $15, $00, $03, $8E, $09, $00, $41, $09, $61, $41, $FF
        .byte $75, $02, $0B, $FF, $09, $00, $01, $09, $61, $01, $FF, $15, $00, $03, $8F, $09
        .byte $00, $40, $09, $61, $40, $FF, $67, $01, $0B, $FF, $09, $00, $01, $09, $61, $01
        .byte $FF, $77, $00, $04, $3F, $06, $25, $FF, $FF, $FF

; Act II, stage 3.
script_02:
        .byte $19, $04, $05, $1F, $03, $8E, $02, $41, $02, $20, $00, $00, $01, $01, $82, $01
        .byte $10, $11, $17, $00, $30, $20, $14, $01, $08, $2C, $00, $07, $81, $C2, $0E, $06
        .byte $2D, $FF, $77, $00, $04, $3F, $FF, $1F, $00, $80, $03, $54, $05, $1E, $06, $2A
        .byte $02, $42, $0F, $0D, $53, $00, $0D, $1A, $17, $1D, $FF, $1F, $00, $03, $55, $FF
        .byte $B3, $00, $0B, $01, $81, $A1, $9A, $9B, $9C, $58, $2C, $00, $52, $01, $04, $A9
        .byte $FF, $00, $00, $0E, $C0, $FF, $1F, $00, $05, $1E, $03, $8E, $02, $42, $11, $2A
        .byte $06, $2C, $01, $21, $0A, $0C, $81, $06, $00, $00, $00, $C0, $30, $00, $19, $41
        .byte $FF, $77, $00, $0B, $FF, $09, $00, $01, $C2, $0F, $FF, $00, $00, $0E, $C0, $FF
        .byte $67, $01, $03, $82, $06, $31, $02, $41, $11, $00, $00, $00, $01, $21, $81, $10
        .byte $3A, $00, $00, $38, $30, $00, $16, $01, $C2, $10, $FF, $00, $00, $0E, $C0, $FF
        .byte $AF, $04, $02, $41, $11, $2A, $06, $2C, $01, $0C, $81, $06, $00, $00, $00, $40
        .byte $30, $00, $19, $01, $C2, $11, $FF, $00, $00, $0E, $C0, $FF, $77, $00, $02, $41
        .byte $11, $00, $00, $00, $01, $21, $81, $10, $3A, $00, $00, $38, $30, $00, $16, $01
        .byte $C2, $1F, $FF, $00, $00, $0E, $C0, $FF, $00, $00, $02, $03, $91, $0B, $FF, $42
        .byte $11, $2A, $06, $2C, $0A, $21, $01, $0C, $81, $06, $00, $00, $00, $0C, $30, $00
        .byte $19, $46, $FF, $0D, $01, $03, $91, $C2, $12, $FF, $A1, $03, $0B, $FF, $09, $00
        .byte $01, $FF, $00, $00, $0E, $C0, $FF, $9F, $05, $80, $03, $82, $02, $42, $0F, $11
        .byte $16, $09, $07, $0A, $07, $0A, $C2, $13, $FF, $00, $00, $0E, $C0, $FF, $0B, $03
        .byte $02, $41, $0F, $0E, $00, $00, $08, $04, $81, $0F, $00, $00, $00, $2C, $30, $00
        .byte $0E, $01, $C2, $14, $FF, $00, $00, $0E, $C0, $FF, $0B, $03, $02, $41, $11, $2A
        .byte $06, $2C, $01, $0C, $81, $06, $00, $00, $00, $40, $30, $00, $19, $01, $C2, $15
        .byte $FF, $00, $00, $0E, $C0, $FF, $CF, $02, $03, $82, $80, $02, $42, $0F, $00, $48
        .byte $09, $0D, $34, $0F, $0A, $C2, $16, $FF, $77, $00, $06, $25, $FF, $00, $00, $0E
        .byte $C0, $FF, $3B, $00, $06, $02, $02, $05, $1F, $03, $84, $41, $02, $20, $00, $00
        .byte $01, $01, $81, $46, $00, $00, $00, $64, $28, $00, $80, $01, $06, $37, $FF, $00
        .byte $00, $0E, $C0, $FF, $14, $00, $02, $03, $82, $42, $02, $09, $00, $00, $01, $21
        .byte $06, $35, $81, $46, $00, $00, $00, $90, $1C, $20, $09, $C4, $FF, $15, $00, $07
        .byte $1D, $8D, $CE, $21, $09, $20, $43, $06, $0F, $FF, $00, $00, $0E, $C0, $FF, $0B
        .byte $00, $02, $41, $21, $52, $00, $00, $0D, $25, $82, $46, $24, $00, $00, $7C, $4C
        .byte $20, $1C, $01, $52, $48, $00, $1B, $4A, $FF, $0F, $00, $82, $46, $24, $00, $00
        .byte $7C, $14, $20, $1C, $01, $58, $30, $00, $1B, $4A, $06, $35, $FF, $0F, $00, $09
        .byte $01, $4B, $FF, $B3, $00, $06, $0F, $09, $21, $01, $C2, $17, $FF, $0D, $00, $09
        .byte $21, $41, $06, $49, $FF, $3B, $00, $09, $21, $01, $FF, $00, $00, $0E, $C0, $FF
        .byte $4F, $00, $02, $41, $02, $00, $00, $00, $01, $21, $81, $10, $3A, $3B, $3C, $50
        .byte $30, $40, $33, $01, $C2, $18, $FF, $00, $00, $0E, $C0, $FF, $1F, $00, $05, $1E
        .byte $03, $8E, $02, $42, $11, $2A, $06, $2C, $01, $21, $0A, $0C, $81, $06, $00, $00
        .byte $00, $C0, $30, $00, $19, $41, $FF, $B3, $00, $0B, $FF, $09, $00, $01, $06, $2C
        .byte $C2, $19, $FF, $FF, $FF

; Act III, stage 3.
script_03:
        .byte $FD, $01, $05, $1F, $03, $84, $02, $41, $02, $20, $00, $00, $01, $01, $82, $01
        .byte $10, $11, $17, $7C, $30, $20, $14, $01, $74, $2C, $40, $07, $80, $06, $2D, $C2
        .byte $1A, $FF, $3B, $00, $04, $1F, $FF, $0F, $00, $05, $1E, $03, $82, $02, $41, $11
        .byte $00, $00, $00, $01, $21, $81, $10, $3A, $00, $00, $F0, $30, $00, $16, $40, $FF
        .byte $1D, $00, $09, $00, $01, $01, $FF, $77, $00, $C2, $1B, $06, $48, $FF, $00, $00
        .byte $0E, $C0, $FF, $49, $01, $06, $2B, $02, $41, $11, $35, $36, $37, $01, $0D, $81
        .byte $37, $11, $2D, $00, $38, $30, $20, $1D, $01, $C2, $1C, $FF, $00, $00, $0E, $C0
        .byte $FF, $77, $00, $02, $41, $02, $01, $10, $11, $01, $05, $81, $06, $07, $08, $00
        .byte $4C, $2C, $00, $0F, $01, $C2, $1D, $FF, $00, $00, $0E, $C0, $FF, $8B, $0A, $02
        .byte $41, $11, $35, $36, $37, $01, $0D, $81, $37, $11, $2D, $00, $38, $30, $20, $1D
        .byte $01, $C2, $1E, $FF, $00, $00, $0E, $C0, $FF, $95, $00, $06, $48, $02, $41, $02
        .byte $00, $00, $00, $01, $21, $81, $10, $3A, $3B, $3C, $50, $30, $40, $33, $01, $C2
        .byte $1F, $FF, $00, $00, $0E, $C0, $FF, $EF, $00, $80, $02, $41, $0C, $42, $00, $00
        .byte $0D, $26, $81, $01, $00, $00, $00, $40, $30, $00, $1E, $01, $C2, $20, $FF, $B3
        .byte $00, $04, $3F, $06, $29, $FF, $1F, $00, $80, $03, $54, $05, $1E, $06, $2A, $02
        .byte $42, $0F, $0D, $53, $00, $0D, $1A, $17, $1D, $FF, $1F, $00, $03, $55, $FF, $B3
        .byte $00, $0B, $01, $81, $A1, $9A, $9B, $9C, $58, $2C, $00, $53, $01, $04, $A9, $FF
        .byte $00, $00, $0E, $C0, $FF, $3B, $00, $03, $82, $02, $40, $FF, $A3, $01, $02, $41
        .byte $27, $43, $00, $00, $08, $27, $81, $43, $43, $43, $43, $40, $30, $00, $2A, $01
        .byte $06, $2E, $C2, $21, $FF, $1D, $00, $04, $07, $FF, $DF, $01, $02, $41, $30, $47
        .byte $19, $00, $01, $28, $81, $44, $3A, $45, $26, $40, $30, $00, $2A, $01, $C2, $22
        .byte $04, $8B, $FF, $00, $00, $0E, $C0, $FF, $EF, $00, $02, $41, $30, $47, $19, $00
        .byte $0D, $3A, $81, $10, $3A, $00, $00, $38, $30, $00, $16, $01, $C2, $1F, $FF, $00
        .byte $00, $0E, $C0, $FF, $B3, $00, $02, $41, $30, $47, $19, $00, $01, $28, $81, $44
        .byte $3A, $45, $26, $40, $30, $00, $2A, $01, $C2, $23, $FF, $00, $00, $0E, $C0, $FF
        .byte $DF, $01, $02, $41, $30, $47, $19, $00, $01, $3D, $82, $01, $10, $11, $17, $00
        .byte $30, $20, $14, $01, $08, $2C, $00, $07, $01, $C2, $24, $FF, $00, $00, $0E, $C0
        .byte $FF, $FD, $01, $02, $41, $30, $47, $19, $00, $01, $28, $81, $44, $3A, $45, $26
        .byte $40, $30, $00, $2A, $01, $C2, $25, $FF, $00, $00, $0E, $C0, $FF, $3B, $00, $02
        .byte $41, $30, $47, $19, $00, $01, $3D, $82, $01, $10, $11, $17, $00, $30, $20, $14
        .byte $01, $08, $2C, $00, $07, $01, $FF, $0B, $00, $04, $0A, $FF, $2F, $00, $0A, $00
        .byte $00, $0C, $04, $00, $9D, $00, $00, $04, $8A, $FF, $00, $00, $0E, $C0, $FF, $0F
        .byte $00, $05, $1E, $03, $83, $02, $42, $00, $49, $4A, $00, $12, $37, $15, $29, $82
        .byte $44, $3A, $45, $00, $98, $28, $00, $49, $01, $28, $30, $00, $2A, $01, $06, $3D
        .byte $C2, $26, $FF, $61, $07, $0B, $FF, $FF, $0F, $00, $03, $92, $06, $3D, $FF, $00
        .byte $00, $0B, $FF, $0C, $04, $00, $11, $44, $24, $08, $1F, $FF, $00, $00, $07, $87
        .byte $8E, $C8, $27, $FF, $00, $00, $07, $88, $8D, $C0, $24, $FF, $00, $00, $07, $9F
        .byte $8D, $00, $25, $FF, $00, $00, $07, $B6, $8D, $40, $25, $FF, $0E, $00, $07, $CD
        .byte $8D, $80, $25, $FF, $0F, $00, $03, $83, $09, $00, $41, $06, $3D, $C2, $27, $FF
        .byte $53, $06, $0B, $FF, $09, $00, $01, $FF, $0F, $00, $03, $92, $09, $00, $40, $06
        .byte $3D, $FF, $00, $00, $0B, $FF, $09, $00, $01, $0C, $04, $00, $11, $23, $09, $08
        .byte $13, $FF, $00, $00, $07, $77, $8E, $C8, $27, $FF, $00, $00, $07, $2C, $8D, $C0
        .byte $24, $FF, $00, $00, $07, $43, $8D, $00, $25, $FF, $00, $00, $07, $5A, $8D, $40
        .byte $25, $FF, $0E, $00, $07, $71, $8D, $80, $25, $FF, $0F, $00, $03, $83, $06, $3D
        .byte $C2, $28, $FF, $27, $05, $0B, $FF, $FF, $00, $00, $0E, $C0, $FF, $B3, $00, $03
        .byte $82, $02, $41, $00, $9D, $00, $00, $01, $3D, $82, $01, $10, $11, $17, $00, $30
        .byte $20, $14, $01, $08, $2C, $00, $07, $01, $C2, $1F, $FF, $00, $00, $0E, $C0, $FF
        .byte $DB, $05, $02, $41, $30, $47, $19, $00, $01, $28, $81, $44, $3A, $45, $26, $40
        .byte $30, $00, $2A, $01, $C2, $29, $04, $8B, $FF, $00, $00, $0E, $C0, $FF, $57, $02
        .byte $03, $82, $02, $41, $30, $47, $19, $00, $01, $3D, $82, $01, $10, $11, $17, $00
        .byte $30, $20, $14, $01, $08, $2C, $00, $07, $01, $C2, $2A, $FF, $00, $00, $0E, $C0
        .byte $FF, $73, $04, $02, $41, $30, $47, $19, $00, $01, $28, $81, $44, $3A, $45, $26
        .byte $40, $30, $00, $2A, $01, $C2, $2B, $FF, $00, $00, $0E, $C0, $FF, $2B, $01, $03
        .byte $82, $02, $41, $30, $47, $19, $00, $01, $3D, $82, $01, $10, $11, $17, $00, $30
        .byte $20, $14, $01, $08, $2C, $00, $07, $01, $C2, $2C, $FF, $00, $00, $0E, $C0, $FF
        .byte $1B, $02, $02, $41, $27, $43, $00, $00, $08, $27, $81, $43, $43, $43, $43, $40
        .byte $30, $00, $2A, $01, $C2, $2D, $FF, $59, $00, $04, $2B, $FF, $49, $01, $05, $1F
        .byte $03, $50, $02, $41, $13, $4D, $20, $03, $00, $2A, $81, $3F, $28, $00, $00, $88
        .byte $14, $00, $2B, $45, $06, $3E, $FF, $59, $00, $83, $3F, $28, $00, $00, $00, $78
        .byte $20, $14, $01, $35, $94, $00, $2B, $45, $35, $14, $00, $83, $C2, $FF, $1D, $00
        .byte $09, $01, $48, $09, $02, $47, $FF, $41, $00, $06, $3F, $FF, $31, $00, $09, $01
        .byte $01, $FF, $3B, $00, $09, $22, $47, $FF, $1D, $00, $06, $25, $04, $1B, $FF, $FF
        .byte $FF

; Act IV, stage 1.
script_04:
        .byte $1B, $02, $80, $05, $1E, $03, $53, $02, $42, $22, $38, $00, $03, $13, $0F, $00
        .byte $10, $06, $2F, $FF, $C1, $01, $82, $10, $11, $0B, $00, $88, $50, $00, $2F, $45
        .byte $88, $50, $00, $84, $45, $FF, $EF, $00, $0B, $FF, $0B, $07, $09, $00, $01, $09
        .byte $01, $01, $FF, $59, $00, $04, $3F, $FF, $FF, $FF

; Act IV, stage 4.
script_05:
        .byte $3B, $00, $05, $1E, $03, $82, $06, $4B, $02, $41, $0F, $0A, $A0, $0C, $0D, $11
        .byte $81, $0A, $00, $00, $00, $40, $30, $00, $1F, $01, $04, $BF, $FF, $A3, $01, $C2
        .byte $2E, $FF, $00, $00, $0E, $C0, $FF, $B3, $00, $02, $41, $02, $01, $10, $11, $01
        .byte $06, $81, $06, $07, $08, $00, $4C, $2C, $00, $10, $01, $C2, $2F, $FF, $00, $00
        .byte $0E, $C0, $FF, $85, $01, $02, $41, $0F, $0A, $A0, $0C, $0D, $11, $81, $0A, $00
        .byte $00, $00, $40, $30, $00, $1F, $01, $C2, $30, $FF, $00, $00, $0E, $C0, $FF, $1F
        .byte $00, $03, $83, $02, $41, $04, $48, $23, $4B, $16, $38, $82, $4C, $4B, $23, $00
        .byte $C0, $30, $00, $3B, $41, $B0, $30, $00, $39, $41, $C2, $31, $FF, $77, $00, $0B
        .byte $FF, $09, $00, $01, $09, $01, $01, $FF, $0F, $00, $09, $00, $4C, $FF, $0F, $00
        .byte $07, $E4, $8D, $14, $25, $FF, $00, $00, $07, $97, $8E, $D5, $27, $FF, $1E, $00
        .byte $07, $FB, $8D, $16, $25, $FF, $77, $00, $09, $00, $01, $FF, $00, $00, $0E, $C0
        .byte $FF, $2B, $01, $03, $82, $02, $41, $02, $01, $10, $11, $01, $06, $81, $06, $07
        .byte $08, $00, $4C, $2C, $00, $10, $01, $C2, $32, $FF, $00, $00, $0E, $C0, $FF, $EF
        .byte $00, $02, $41, $04, $48, $23, $4B, $08, $2B, $81, $4C, $4B, $23, $00, $30, $30
        .byte $00, $39, $01, $C2, $33, $FF, $00, $00, $0E, $C0, $FF, $67, $01, $02, $41, $0F
        .byte $0A, $A0, $0C, $0D, $11, $81, $0A, $00, $00, $00, $40, $30, $00, $1F, $01, $C2
        .byte $34, $FF, $00, $00, $0E, $C0, $FF, $67, $01, $02, $41, $0F, $2F, $00, $00, $01
        .byte $12, $82, $01, $09, $00, $00, $20, $2C, $00, $3D, $01, $34, $38, $00, $3E, $01
        .byte $C2, $35, $FF, $00, $00, $0E, $C0, $FF, $B3, $00, $02, $41, $0F, $0A, $A0, $0C
        .byte $0D, $11, $81, $0A, $00, $00, $00, $40, $30, $00, $1F, $01, $C2, $39, $FF, $00
        .byte $00, $0E, $C0, $FF, $3B, $00, $02, $41, $0F, $2F, $00, $00, $01, $12, $83, $01
        .byte $09, $00, $00, $20, $4C, $20, $4C, $01, $34, $38, $00, $3E, $01, $20, $2C, $00
        .byte $3D, $01, $FF, $0E, $00, $07, $12, $8E, $C3, $21, $06, $3B, $FF, $07, $00, $09
        .byte $02, $44, $FF, $77, $00, $09, $02, $01, $FF, $00, $00, $0E, $C0, $FF, $3B, $00
        .byte $06, $4C, $02, $41, $04, $48, $23, $4B, $08, $2B, $81, $4C, $4B, $23, $00, $30
        .byte $30, $00, $39, $01, $C2, $36, $FF, $2B, $01, $81, $4C, $4B, $23, $00, $30, $30
        .byte $00, $3C, $01, $FF, $1F, $00, $03, $84, $09, $00, $40, $FF, $3B, $00, $0B, $FF
        .byte $09, $00, $01, $FF, $00, $00, $0E, $C0, $FF, $37, $04, $03, $82, $02, $41, $0F
        .byte $0A, $A0, $0C, $0D, $11, $81, $0A, $00, $00, $00, $40, $30, $00, $1F, $01, $C2
        .byte $37, $FF, $00, $00, $0E, $C0, $FF, $A3, $01, $02, $41, $0F, $1A, $00, $00, $0D
        .byte $17, $81, $1A, $00, $00, $00, $40, $30, $00, $27, $01, $C2, $38, $FF, $77, $00
        .byte $04, $3F, $FF, $1F, $00, $80, $03, $54, $05, $1E, $06, $2A, $02, $42, $0F, $0D
        .byte $53, $00, $0D, $1A, $17, $1D, $FF, $1F, $00, $03, $55, $FF, $B3, $00, $0B, $01
        .byte $81, $A1, $9A, $9B, $9C, $58, $2C, $00, $54, $01, $04, $A9, $FF, $FF, $FF

; Act V, stage 3.
script_06:
        .byte $0F, $00, $03, $9A, $06, $4D, $02, $41, $0F, $2D, $2E, $2F, $16, $13, $83, $2E
        .byte $30, $00, $00, $38, $51, $20, $4C, $01, $40, $51, $20, $4C, $01, $40, $50, $00
        .byte $40, $54, $FF, $49, $01, $03, $89, $81, $2E, $30, $00, $00, $40, $30, $00, $40
        .byte $01, $C2, $3A, $FF, $00, $00, $0E, $C0, $FF, $2B, $01, $03, $82, $02, $41, $0F
        .byte $2D, $00, $00, $08, $33, $81, $10, $3B, $00, $00, $40, $30, $00, $16, $01, $C2
        .byte $3B, $FF, $00, $00, $0E, $C0, $FF, $75, $02, $02, $41, $0F, $2D, $2E, $2F, $08
        .byte $13, $81, $2E, $30, $00, $00, $40, $30, $00, $40, $01, $C2, $3C, $FF, $00, $00
        .byte $0E, $C0, $FF, $2B, $01, $02, $41, $0F, $2D, $00, $00, $08, $33, $81, $10, $3B
        .byte $00, $00, $40, $30, $00, $16, $01, $C2, $3D, $FF, $00, $00, $0E, $C0, $FF, $A3
        .byte $01, $02, $41, $0F, $2D, $2E, $2F, $08, $13, $81, $2E, $30, $00, $00, $40, $30
        .byte $00, $40, $01, $C2, $3E, $FF, $FF, $FF

; Act V, stage 4.
script_07:
        .byte $7F, $07, $03, $82, $06, $32, $02, $41, $0F, $32, $31, $33, $0D, $14, $81, $34
        .byte $00, $00, $00, $4C, $30, $00, $41, $01, $C2, $3F, $FF, $00, $00, $0E, $C0, $FF
        .byte $3B, $00, $06, $29, $02, $41, $02, $01, $10, $11, $01, $06, $81, $06, $07, $08
        .byte $00, $4C, $2C, $00, $10, $01, $C2, $1F, $FF, $77, $00, $04, $3F, $FF, $1F, $00
        .byte $80, $03, $54, $05, $1E, $06, $2A, $02, $42, $0F, $0D, $53, $00, $0D, $1A, $17
        .byte $1D, $FF, $1F, $00, $03, $55, $FF, $B3, $00, $0B, $01, $81, $A1, $9A, $9B, $9C
        .byte $58, $2C, $00, $55, $01, $04, $A9, $FF, $FF, $FF

; Act VI, stage 3.
script_08:
        .byte $0F, $00, $03, $82, $06, $4C, $02, $41, $0F, $00, $00, $00, $01, $21, $81, $10
        .byte $3A, $11, $00, $80, $30, $60, $38, $4D, $C2, $40, $FF, $B3, $00, $09, $60, $01
        .byte $FF, $57, $02, $81, $10, $3A, $3B, $3C, $4B, $30, $60, $33, $01, $FF, $00, $00
        .byte $0E, $C0, $FF, $0D, $01, $80, $02, $41, $0F, $21, $22, $00, $08, $15, $81, $8D
        .byte $00, $00, $00, $40, $30, $00, $8D, $01, $04, $FE, $FF, $00, $00, $0E, $C0, $FF
        .byte $2B, $01, $02, $41, $0F, $01, $10, $11, $01, $06, $81, $06, $07, $08, $00, $4C
        .byte $2C, $20, $10, $01, $C2, $41, $FF, $00, $00, $0E, $C0, $FF, $B3, $00, $06, $48
        .byte $02, $41, $0F, $01, $10, $11, $01, $08, $81, $06, $07, $08, $00, $4C, $2C, $00
        .byte $12, $01, $C2, $42, $FF, $00, $00, $0E, $C0, $FF, $3B, $00, $02, $41, $00, $41
        .byte $18, $00, $01, $02, $82, $41, $41, $41, $18, $20, $14, $20, $0A, $01, $5C, $2F
        .byte $20, $0C, $01, $FF, $06, $00, $09, $20, $44, $FF, $14, $00, $82, $41, $41, $41
        .byte $18, $20, $30, $20, $0B, $01, $5C, $2F, $20, $0C, $01, $FF, $95, $00, $82, $41
        .byte $41, $41, $18, $20, $30, $20, $0A, $01, $5C, $2F, $20, $0C, $01, $C2, $43, $FF
        .byte $09, $00, $82, $41, $41, $41, $18, $1E, $30, $20, $0A, $01, $5C, $2F, $20, $0C
        .byte $01, $FF, $09, $00, $82, $41, $41, $41, $18, $1E, $30, $20, $0B, $01, $5C, $2F
        .byte $20, $0C, $01, $FF, $67, $01, $82, $41, $41, $41, $18, $1A, $39, $20, $0B, $01
        .byte $5C, $2F, $20, $0C, $01, $FF, $00, $00, $0E, $C0, $FF, $75, $02, $06, $4B, $02
        .byte $41, $0F, $00, $00, $00, $01, $21, $81, $10, $3A, $3B, $3C, $4B, $30, $60, $33
        .byte $01, $C2, $44, $FF, $00, $00, $0E, $C0, $FF, $07, $00, $02, $41, $0F, $00, $00
        .byte $00, $01, $21, $82, $01, $10, $11, $17, $00, $30, $20, $14, $01, $94, $2C, $40
        .byte $07, $41, $C2, $45, $FF, $2B, $01, $09, $41, $01, $FF, $00, $00, $0E, $C0, $FF
        .byte $2B, $01, $80, $02, $41, $0F, $21, $22, $00, $08, $15, $81, $8D, $00, $00, $00
        .byte $40, $30, $00, $8D, $01, $C2, $46, $FF, $00, $00, $0E, $C0, $FF, $00, $00, $03
        .byte $96, $0B, $FF, $02, $42, $0F, $01, $10, $11, $0A, $21, $01, $05, $81, $06, $07
        .byte $08, $00, $8C, $AC, $00, $0F, $45, $FF, $4E, $01, $03, $96, $C2, $47, $FF, $B3
        .byte $00, $0B, $FF, $09, $00, $01, $FF, $00, $00, $0E, $C0, $FF, $00, $00, $03, $97
        .byte $02, $42, $0F, $01, $10, $11, $0A, $21, $01, $05, $81, $06, $07, $08, $00, $0C
        .byte $AC, $00, $0F, $01, $FF, $4E, $01, $09, $00, $46, $C2, $48, $FF, $2B, $01, $0B
        .byte $FF, $09, $00, $01, $FF, $00, $00, $0E, $C0, $FF, $00, $00, $03, $85, $0B, $FF
        .byte $02, $42, $0F, $8A, $8B, $8C, $01, $3C, $0A, $3B, $81, $26, $26, $00, $00, $80
        .byte $30, $00, $56, $45, $FF, $5D, $01, $03, $85, $C2, $49, $FF, $1D, $00, $0B, $FF
        .byte $09, $00, $01, $FF, $05, $00, $03, $99, $09, $00, $40, $06, $48, $FF, $77, $00
        .byte $0B, $FF, $09, $00, $01, $01, $FF, $FF, $FF

; Act VI, stage 4.
script_09:
        .byte $93, $02, $05, $1E, $03, $82, $06, $4C, $02, $41, $01, $4F, $50, $00, $0D, $2F
        .byte $81, $10, $3A, $3B, $3C, $60, $30, $40, $37, $01, $C2, $4A, $FF, $00, $00, $0E
        .byte $C0, $FF, $0D, $01, $80, $40, $0C, $04, $00, $00, $00, $00, $C2, $4B, $FF, $00
        .byte $00, $0E, $C0, $FF, $95, $00, $02, $41, $0F, $0A, $A0, $0C, $0D, $11, $81, $0A
        .byte $00, $00, $00, $40, $30, $00, $1F, $01, $04, $BF, $FF, $00, $00, $0E, $C0, $FF
        .byte $B3, $00, $02, $41, $0F, $00, $00, $00, $01, $21, $81, $10, $3A, $3B, $3C, $4B
        .byte $30, $60, $33, $01, $C2, $4C, $FF, $00, $00, $0E, $C0, $FF, $77, $00, $02, $41
        .byte $0F, $1A, $00, $00, $0D, $17, $81, $1A, $00, $00, $00, $40, $30, $00, $27, $01
        .byte $C2, $4D, $FF, $00, $00, $0E, $C0, $FF, $77, $00, $06, $1E, $02, $41, $01, $25
        .byte $00, $00, $08, $18, $81, $26, $00, $00, $00, $50, $30, $00, $89, $01, $FF, $02
        .byte $00, $81, $26, $00, $00, $26, $50, $30, $00, $35, $4E, $FF, $03, $00, $09, $20
        .byte $4E, $06, $1D, $FF, $3B, $00, $09, $20, $01, $FF, $00, $00, $0E, $C0, $FF, $3B
        .byte $00, $03, $98, $0B, $FF, $02, $42, $01, $4F, $50, $00, $0A, $21, $01, $20, $82
        .byte $10, $3A, $3B, $26, $84, $34, $20, $36, $01, $1C, $30, $20, $37, $4F, $C0, $4E
        .byte $FF, $09, $00, $03, $98, $09, $21, $01, $FF, $03, $00, $0B, $FF, $09, $20, $4E
        .byte $FF, $03, $00, $09, $00, $4E, $FF, $09, $00, $83, $10, $3A, $3B, $26, $40, $30
        .byte $00, $13, $C5, $40, $30, $40, $13, $C6, $14, $B0, $20, $37, $01, $01, $C2, $4F
        .byte $06, $1E, $FF, $09, $00, $83, $10, $3A, $3B, $26, $40, $30, $00, $13, $C7, $40
        .byte $30, $40, $13, $C8, $14, $B0, $20, $37, $01, $06, $12, $FF, $09, $00, $83, $10
        .byte $3A, $3B, $26, $40, $30, $00, $13, $C9, $40, $30, $40, $13, $CA, $14, $B0, $20
        .byte $37, $01, $06, $12, $FF, $09, $00, $83, $10, $3A, $3B, $26, $40, $30, $00, $13
        .byte $C9, $40, $30, $40, $13, $CA, $14, $B0, $20, $37, $01, $06, $12, $FF, $0F, $00
        .byte $83, $10, $3A, $3B, $26, $40, $30, $00, $13, $C5, $40, $30, $40, $13, $C6, $14
        .byte $B0, $20, $37, $01, $06, $12, $FF, $B3, $00, $81, $10, $3A, $3B, $26, $14, $B0
        .byte $20, $37, $01, $FF, $00, $00, $0E, $C0, $FF, $67, $01, $02, $41, $02, $4F, $00
        .byte $00, $08, $16, $81, $37, $11, $2D, $00, $38, $30, $20, $1D, $01, $04, $97, $C2
        .byte $50, $FF, $00, $00, $0E, $C0, $FF, $00, $00, $03, $84, $06, $42, $02, $42, $01
        .byte $20, $00, $00, $0A, $06, $01, $01, $05, $1F, $81, $10, $3A, $11, $00, $40, $30
        .byte $00, $38, $01, $FF, $30, $00, $C2, $51, $FF, $31, $00, $81, $10, $3A, $3B, $3C
        .byte $40, $30, $00, $33, $01, $FF, $EF, $00, $08, $15, $05, $1E, $03, $89, $0C, $04
        .byte $00, $01, $10, $11, $81, $06, $07, $08, $00, $4C, $2C, $00, $10, $01, $01, $06
        .byte $36, $FF, $FF, $FF

; Act VI, stage 4.
script_0A:
        .byte $0F, $00, $03, $82, $06, $4E, $02, $41, $02, $00, $00, $00, $01, $21, $81, $48
        .byte $23, $4E, $00, $A0, $30, $00, $43, $41, $FF, $59, $00, $09, $00, $01, $C2, $62
        .byte $FF, $EF, $00, $81, $10, $3A, $00, $00, $40, $30, $00, $16, $01, $FF, $00, $00
        .byte $0E, $C0, $FF, $DF, $01, $02, $41, $02, $4F, $00, $00, $08, $16, $81, $37, $11
        .byte $2D, $00, $38, $30, $20, $1D, $01, $C2, $63, $FF, $83, $03, $06, $30, $FF, $00
        .byte $00, $0E, $C0, $FF, $0F, $00, $03, $82, $02, $41, $02, $00, $00, $00, $01, $21
        .byte $81, $48, $23, $4E, $00, $A0, $30, $00, $43, $41, $FF, $77, $00, $81, $48, $23
        .byte $4E, $00, $60, $30, $00, $4F, $01, $C2, $64, $FF, $00, $00, $0E, $C0, $FF, $7F
        .byte $00, $03, $41, $02, $41, $02, $39, $02, $1F, $00, $0E, $81, $3D, $54, $54, $54
        .byte $70, $28, $00, $4E, $50, $FF, $00, $00, $0E, $C0, $FF, $75, $02, $03, $82, $02
        .byte $41, $02, $01, $10, $11, $01, $08, $81, $06, $07, $08, $00, $4C, $2C, $00, $12
        .byte $01, $C2, $65, $FF, $00, $00, $0E, $C0, $FF, $3F, $01, $03, $41, $02, $41, $02
        .byte $39, $02, $1F, $00, $0E, $81, $3D, $54, $54, $54, $64, $28, $00, $4E, $50, $FF
        .byte $77, $00, $09, $00, $01, $06, $43, $01, $FF, $00, $00, $0E, $C0, $FF, $77, $00
        .byte $80, $03, $00, $0D, $00, $02, $42, $0F, $00, $48, $09, $0D, $34, $0F, $0A, $01
        .byte $FF, $3B, $00, $0A, $30, $00, $0C, $08, $85, $85, $85, $85, $85, $85, $85, $85
        .byte $04, $17, $FF, $FF, $FF

; Act VI, stage 5.
script_0B:
        .byte $E7, $08, $03, $82, $06, $4A, $02, $41, $02, $4F, $00, $00, $08, $16, $81, $37
        .byte $11, $2D, $00, $38, $30, $20, $1D, $01, $04, $97, $C2, $52, $FF, $00, $00, $0E
        .byte $C0, $FF, $B3, $00, $02, $41, $0F, $01, $10, $11, $01, $08, $81, $06, $07, $08
        .byte $00, $4C, $2C, $00, $12, $01, $C2, $53, $FF, $3B, $00, $04, $2B, $FF, $77, $00
        .byte $80, $02, $40, $0C, $04, $00, $54, $54, $54, $C2, $54, $FF, $EF, $00, $04, $7F
        .byte $FF, $77, $00, $05, $1E, $03, $41, $02, $42, $02, $39, $02, $1F, $00, $10, $0B
        .byte $0F, $FF, $77, $00, $03, $00, $0D, $01, $06, $43, $FF, $EF, $00, $81, $39, $90
        .byte $91, $9E, $60, $34, $00, $90, $01, $FF, $1D, $00, $84, $39, $90, $91, $9E, $6C
        .byte $38, $00, $8E, $01, $5C, $34, $00, $91, $01, $64, $28, $00, $92, $01, $58, $1C
        .byte $00, $93, $01, $06, $41, $FF, $3B, $00, $06, $41, $FF, $1D, $00, $06, $41, $FF
        .byte $1D, $00, $06, $41, $FF, $1D, $00, $06, $41, $FF, $D1, $00, $07, $1F, $8E, $1A
        .byte $21, $81, $39, $90, $91, $9E, $6C, $30, $20, $5E, $55, $06, $41, $FF, $59, $00
        .byte $09, $20, $57, $FF, $1B, $02, $06, $41, $09, $20, $58, $FF, $3B, $00, $07, $35
        .byte $8E, $D4, $20, $83, $39, $90, $91, $9E, $54, $28, $20, $5F, $58, $64, $28, $20
        .byte $60, $01, $5C, $20, $20, $61, $01, $06, $41, $FF, $59, $00, $07, $47, $8E, $D8
        .byte $20, $09, $21, $59, $06, $41, $FF, $D1, $00, $07, $5C, $8E, $96, $20, $09, $22
        .byte $58, $06, $41, $FF, $DF, $01, $09, $20, $01, $FF, $B3, $00, $09, $21, $01, $09
        .byte $22, $01, $FF, $77, $00, $03, $41, $FF, $2B, $01, $03, $4C, $81, $10, $11, $0B
        .byte $00, $A0, $48, $00, $3F, $45, $06, $33, $FF, $77, $00, $09, $00, $01, $0B, $FF
        .byte $0B, $03, $FF, $00, $00, $0E, $C0, $FF, $0D, $01, $03, $82, $02, $42, $02, $4F
        .byte $51, $48, $01, $2C, $18, $39, $81, $48, $23, $4C, $00, $4C, $30, $40, $23, $01
        .byte $C2, $55, $FF, $95, $00, $06, $46, $FF, $00, $00, $0E, $C0, $FF, $EF, $00, $02
        .byte $41, $02, $00, $00, $00, $01, $21, $81, $48, $23, $4E, $00, $58, $30, $00, $44
        .byte $01, $C2, $56, $FF, $00, $00, $0E, $C0, $FF, $BF, $03, $02, $41, $04, $23, $00
        .byte $00, $08, $30, $81, $39, $00, $00, $00, $44, $30, $00, $42, $01, $C2, $57, $FF
        .byte $00, $00, $0E, $C0, $FF, $95, $00, $02, $41, $02, $4F, $51, $48, $01, $2C, $81
        .byte $48, $23, $4E, $00, $4C, $30, $00, $44, $01, $C2, $58, $FF, $0D, $01, $81, $48
        .byte $23, $4C, $00, $4C, $30, $40, $23, $01, $FF, $00, $00, $0E, $C0, $FF, $67, $01
        .byte $02, $41, $02, $4F, $00, $00, $01, $2D, $81, $4C, $00, $00, $00, $40, $30, $00
        .byte $29, $01, $C2, $59, $FF, $00, $00, $0E, $C0, $FF, $D1, $00, $02, $41, $04, $23
        .byte $00, $00, $08, $30, $81, $39, $00, $00, $00, $44, $30, $00, $42, $01, $C2, $5A
        .byte $FF, $00, $00, $0E, $C0, $FF, $C1, $01, $02, $41, $02, $4F, $00, $00, $01, $2D
        .byte $81, $4C, $00, $00, $00, $40, $30, $00, $29, $01, $C2, $5B, $FF, $00, $00, $0E
        .byte $C0, $FF, $67, $01, $02, $41, $02, $4F, $51, $48, $01, $2C, $81, $48, $23, $4E
        .byte $00, $4C, $30, $00, $23, $01, $C2, $5C, $FF, $00, $00, $0E, $C0, $FF, $3F, $00
        .byte $02, $41, $09, $03, $00, $00, $01, $31, $82, $4F, $01, $20, $00, $20, $30, $00
        .byte $45, $01, $30, $2C, $00, $8C, $CB, $C2, $5D, $FF, $B3, $00, $81, $4F, $01, $20
        .byte $00, $20, $30, $00, $45, $01, $FF, $00, $00, $0E, $C0, $FF, $39, $02, $06, $34
        .byte $02, $41, $02, $4F, $51, $48, $01, $2C, $81, $48, $23, $4C, $00, $4C, $30, $40
        .byte $23, $01, $C2, $5E, $FF, $59, $00, $81, $48, $23, $4C, $00, $4C, $30, $40, $24
        .byte $01, $FF, $00, $00, $0E, $C0, $FF, $3F, $00, $03, $96, $02, $42, $14, $48, $4F
        .byte $00, $0A, $21, $01, $2E, $81, $48, $23, $00, $00, $29, $30, $20, $4A, $51, $04
        .byte $9F, $FF, $3B, $00, $0B, $FF, $09, $20, $01, $FF, $4F, $00, $0B, $96, $81, $48
        .byte $23, $00, $00, $31, $30, $20, $4B, $51, $FF, $77, $00, $0B, $FF, $09, $20, $01
        .byte $FF, $77, $00, $04, $1F, $FF, $1B, $02, $03, $96, $0B, $FF, $02, $42, $02, $48
        .byte $4F, $00, $0A, $21, $01, $2E, $81, $48, $23, $4C, $00, $4C, $30, $40, $23, $01
        .byte $04, $97, $C2, $5F, $FF, $00, $00, $0E, $C0, $FF, $2B, $01, $03, $82, $02, $41
        .byte $02, $4F, $00, $00, $01, $2D, $81, $4C, $00, $00, $00, $40, $30, $00, $29, $01
        .byte $C2, $60, $FF, $00, $00, $0E, $C0, $FF, $0D, $01, $02, $41, $02, $4F, $51, $48
        .byte $01, $2C, $81, $48, $23, $4E, $00, $4C, $30, $00, $43, $01, $C2, $61, $FF, $00
        .byte $00, $0E, $C0, $FF, $59, $00, $03, $87, $08, $9E, $05, $1E, $02, $42, $01, $3E
        .byte $3F, $00, $02, $1E, $03, $1F, $81, $10, $11, $0B, $00, $3C, $44, $00, $3F, $01
        .byte $0A, $01, $E0, $FF, $3B, $00, $0A, $02, $A0, $FF, $3B, $00, $0A, $13, $00, $FF
        .byte $3B, $00, $0A, $23, $00, $FF, $3B, $00, $0A, $33, $00, $FF, $B6, $02, $0A, $32
        .byte $00, $FF, $1D, $00, $04, $17, $FF, $B3, $00, $08, $90, $80, $05, $1E, $03, $9B
        .byte $06, $47, $FF, $0F, $00, $02, $41, $0F, $53, $00, $00, $0A, $1C, $FF, $0B, $03
        .byte $03, $89, $C2, $66, $FF, $00, $00, $0E, $C0, $FF, $1F, $00, $03, $83, $02, $42
        .byte $0F, $12, $13, $14, $1D, $03, $1D, $03, $81, $15, $00, $00, $00, $C0, $30, $00
        .byte $0D, $41, $FF, $85, $01, $03, $89, $09, $00, $01, $C2, $67, $FF, $00, $00, $0E
        .byte $C0, $FF, $1F, $00, $03, $84, $02, $41, $13, $11, $16, $09, $1E, $0B, $81, $01
        .byte $10, $11, $17, $B4, $30, $00, $17, $40, $FF, $53, $01, $03, $89, $09, $00, $01
        .byte $C2, $68, $FF, $00, $00, $0E, $C0, $FF, $0F, $00, $03, $9A, $02, $41, $0F, $0E
        .byte $00, $00, $16, $04, $82, $0F, $00, $00, $00, $2C, $51, $20, $4C, $01, $2C, $50
        .byte $00, $0E, $54, $FF, $85, $01, $03, $89, $81, $0F, $00, $00, $00, $2C, $30, $00
        .byte $0E, $01, $C2, $69, $FF, $00, $00, $0E, $C0, $FF, $1F, $00, $03, $83, $02, $41
        .byte $11, $2A, $06, $2C, $0A, $0C, $81, $06, $00, $00, $00, $C0, $30, $00, $19, $41
        .byte $FF, $ED, $02, $03, $89, $09, $00, $01, $C2, $6A, $FF, $00, $00, $0E, $C0, $FF
        .byte $0F, $00, $03, $9B, $02, $42, $0F, $0A, $A0, $0C, $1C, $11, $1C, $11, $82, $0A
        .byte $00, $00, $00, $40, $0F, $20, $4C, $01, $40, $10, $00, $1F, $53, $FF, $1B, $02
        .byte $03, $89, $81, $0A, $00, $00, $00, $40, $30, $00, $1F, $01, $C2, $6B, $FF, $00
        .byte $00, $0E, $C0, $FF, $1F, $00, $03, $84, $02, $41, $0F, $2F, $00, $00, $0A, $12
        .byte $82, $01, $09, $00, $00, $B4, $38, $00, $3E, $40, $A0, $2C, $00, $3D, $40, $FF
        .byte $67, $01, $03, $89, $09, $00, $01, $09, $01, $01, $C2, $6C, $FF, $00, $00, $0E
        .byte $C0, $FF, $1F, $00, $03, $83, $02, $41, $02, $01, $10, $11, $0A, $06, $81, $06
        .byte $07, $08, $00, $CC, $2C, $00, $10, $41, $FF, $67, $01, $03, $89, $09, $00, $01
        .byte $C2, $6D, $FF, $00, $00, $0E, $C0, $FF, $0F, $00, $03, $9A, $02, $41, $0F, $2D
        .byte $2E, $2F, $16, $13, $83, $2E, $30, $00, $00, $38, $51, $20, $4C, $01, $40, $51
        .byte $20, $4C, $01, $40, $50, $00, $40, $54, $FF, $67, $01, $03, $89, $81, $2E, $30
        .byte $00, $00, $40, $30, $00, $40, $01, $C2, $6E, $FF, $00, $00, $0E, $C0, $FF, $1F
        .byte $00, $03, $83, $02, $41, $02, $4F, $51, $48, $0A, $2C, $81, $48, $23, $4E, $00
        .byte $CC, $30, $00, $43, $41, $FF, $85, $01, $03, $89, $09, $00, $01, $C2, $6F, $FF
        .byte $00, $00, $0E, $C0, $FF, $B3, $00, $03, $82, $02, $80, $41, $0F, $00, $00, $00
        .byte $1F, $40, $04, $BE, $FF, $C1, $01, $CA, $70, $FF, $FE, $FF, $81, $00, $00, $00
        .byte $53, $40, $5C, $00, $32, $01, $04, $BD, $FF, $FF, $FF
; Start skipped the script below. Then the game starts.
script_0C:
        .byte $1F, $00, $80, $03, $54, $05, $1E, $06, $2A, $02, $42, $0F, $0D, $53, $00, $0D
        .byte $1A, $17, $1D, $FF, $1F, $00, $03, $55, $FF, $B3, $00, $0B, $01, $81, $A1, $9A
        .byte $9B, $9C, $58, $2C, $00, $50, $01, $04, $A9, $FF, $FF, $FF
; Start skipped the opening. If this finishes, the opening plays again.
script_0D:
        .byte $57, $02, $0A, $0F, $00, $03, $42, $03, $00, $02, $42, $0F, $53, $00, $00, $12
        .byte $1C, $1A, $3E, $80, $06, $02, $FF, $59, $00, $04, $3F, $FF, $FF, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $80, $FF, $00, $FF, $00, $FF, $04, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FE, $FF, $00, $FF, $80, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $14, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $A0, $FF, $00, $FF, $04, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $10, $00, $FF, $02, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $57, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $40, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $04, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $04
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $08, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $F7, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $7F, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $80, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $20, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $04, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $EF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FD, $00, $FF, $00, $FF, $FF, $00, $FF, $10, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $55, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $04, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $09, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $84, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $85, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $40, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $24, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $10, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $04, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $50, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $40, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $30, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $7F, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $80, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $04, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $01, $FF, $00, $FF, $04, $00, $FF, $00, $FF, $00, $FF, $01, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $40, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $F7, $00, $FF, $04
        .byte $BF, $00, $FF, $00, $FF, $FF, $00, $7F, $10, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $03, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $EF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $08, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $02, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $7F, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $01, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $04, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $10, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $8D, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $80, $FF, $00, $FF, $00, $FF, $00, $FC
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $7F, $00, $FF, $00, $F7, $FF, $00, $FF, $92, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $A0, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FE, $00, $FF, $1C, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $C8, $FF, $00, $FF, $00, $FF, $02, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $11, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $48, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $8C, $FF, $00, $FF, $00, $DF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $7F, $00, $FF, $00, $FF, $FF, $00, $FF, $09, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $18, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $BF, $00, $FF, $30, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $EF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $40, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $44, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $80, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $7F, $00, $FF, $00, $F7, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $04, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $F7, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $7F, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $01
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $DF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $04, $FF, $00, $FF, $00, $F7, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $01, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $04, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $04, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FE
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FB
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FE, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $BF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $F7, $00, $FF, $00, $FF, $FF, $00, $BF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $F7, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $02, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $02, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $02, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FE, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $02, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $02, $FF, $04
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $BF, $FF, $00, $FF, $00, $FF, $00, $EF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $01, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $DF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FD, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $EF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $04, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $01, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $01, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $7F, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $7F, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FE, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $7F, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $02, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $04, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $02, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $02, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $02, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $10, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $F7, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FD, $00, $FF, $04, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FE, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $DF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $BF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $04, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $EF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $7F, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
        .byte $02, $02, $02, $02, $02, $02, $02, $02, $09, $09, $09, $09, $09, $09, $09, $09
        .byte $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $0F, $0F, $0F, $0F
        .byte $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $15, $15, $15
        .byte $15, $15, $15, $15, $15, $15, $15, $15, $15, $25, $03, $03, $03, $03, $03, $03
        .byte $03, $03, $03, $03, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10
        .byte $0D, $0D, $0D, $0D, $0D, $0D, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $BF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $FF, $00, $FF, $00, $FF, $FF, $00, $FF, $00, $FF, $00, $FF, $00

; --- $BF98  Call a routine in another bank, then switch this one back.
call_bank:
        sta $0394                       ; which picture, when this call draws one
        txa
        pha
        rol
        rol
        rol
        and #$03
        ora #$04
        jsr set_prg+2                       ; switch the program bank, but do not remember it
        pla
        and #$3F
        jsr bank_routines
        lda z:prg_bank
        jsr set_prg
        rts
; --- $BFB3  Routines the other banks can call.
bank_routines:
        jsr jump_table
        .word play_cutscene
        .word clear_scene                   ; inside the setup above
        .word zero_byte
        .word zero_next
        .word scene_byte
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $D8, $A9, $10, $8D, $00, $20, $A9, $80, $8D, $00

; --- $BFDA  Same first instructions as reset.
reset_copy_04:
        inc $FFDA
        jmp $C03E
        .byte $FF, $9F, $4A, $CA, $D0, $F9, $4C, $00, $80, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $DA, $FF, $DA, $FF, $DA, $FF
