; PRG file bank 04, switched in at $8000-$BFFF.
; The cutscenes. Reset calls this with 0. When an area ends,
; bank 07 calls it with that area's cutscene number.

; --- $8000  Play the cutscene in A. Reset passes 0, the opening. An area passes its own number.
play_cutscene:
        sei
        cld
        pha
; The call list at the end of this bank points here, inside the setup.
c8003:
        lda #$00
        tax
c8006:
        sta $0300,x
c8009:
        dex
        bne c8006
c800C:
        pla
        sta $0300
        lda #$3F
        sta $03A2
        lda #$20
        sta $03A0
        lda #$B0
        sta z:ppuctrl_shadow                ; NMI on, 8x16 sprites, background patterns at $1000
        lda #$1E
        sta z:ppumask_shadow                ; sprites and background on
        jsr write_control                   ; MMC1 control $1E
        lda #$00
        sta z:nmi_latch
        jsr wait_frame
        lda #$C0
        jsr black_colors
        jsr wait_frame
        lda #$04
        sta z:prg_bank                      ; this bank
        lda #$0F
        sta $038B
        lda #$10
        sta $56                             ; CHR bank 0
        sta $59                             ; CHR bank 1
        sta $038A
; --- $8046  Show the cutscene.
show_cutscene:
        jsr fill_screens
        jsr hide_sprites
        lda $0300
        bne run_script
        jsr run_script
        lda $0303
        bne show_cutscene                           ; the opening finished, so play it again
        lda z:pad_cur
        and #$E6                            ; A, B, Select, Down, and Left
        cmp #$E6                            ; all of them held
        bne opening_skipped
; --- $8061  Those five were held when Start skipped the opening.
sound_test:
        lda #$00
        sta $038C
        sta $038E
        sta $038F
        lda #$9A
        sta $0390
        lda #$53
        sta $038D
        lda #$0F
        sta $038B
        lda #$20
        sta z:picture_at_hi                ; where this picture goes
        lda #$C0
        sta z:picture_at
        lda #$1C
        ldx #$80
        jsr call_bank
        lda #$21
        sta z:picture_at_hi                ; where this picture goes
        lda #$E4
        sta z:picture_at
        lda #$3E
        ldx #$80
        jsr call_bank
        lda #$C0
        jsr load_colors
        jsr send_colors
        jsr wait_frame
        lda #$06
        sta a:prg_bank
        ldx #$81
        jmp call_bank                       ; the sound test
; --- $80AE  Start skipped the opening.
opening_skipped:
        lda #$0D
        jsr run_script
        lda $0303
        bne show_cutscene                           ; that script finished, so play the opening again
        lda #$0C
        jsr run_script
        rts
; --- $80BE  Play one script.
run_script:
        asl
        tax
        lda script_list,x
        sta $0A
        lda script_list+1,x
        sta $0B
        ldy #$00
        sty $0304
        sty $0303
        sty $0301
        sty $0302
        sty $0305
        sty $030A
        sty $0313
        sty $030C
        sty $031D
        lda #$0F
        jsr split_sprite
; --- $80EC  One frame of the script.
script_frame:
        jsr cutscene_frame
        lda $0305
        beq c80F7                           ; not fading
        jsr darken_colors
c80F7:
        lda $030A
        beq c80FF                           ; not flashing
        jsr gray_flash
c80FF:
        lda $0313
        beq c8109
        ldx #$43
        jsr call_bank
c8109:
        lda $030C
        beq c8111                           ; not moving through a shot
        jsr scroll_step
c8111:
        ldx #$41
        jsr call_bank
        jsr step_script
        ldx #$42
        jsr call_bank
        jsr hide_from
        lda $0300
        cmp #$0B                            ; Act VI, stage 5 is not skipped
        beq c812F
        jsr buttons_pressed
        and #$10                            ; Start
        bne end_cutscene
; See if the script has finished.
c812F:
        lda $0303
        beq script_frame
        lda $0300
        cmp #$0B                            ; Act VI, stage 5
        bne end_cutscene
        jmp $FFDA                           ; the game ends
; --- $813E  The cutscene is over.
end_cutscene:
        lda #$C0
        jsr black_colors
        lda #$02
        sta sound                           ; play a sound
        jsr wait_frame
        lda #$00
        sta z:nmi_latch
        sta $A1
        sta $A7
        sta $0305
        sta $030A
        sta $0313
        sta $030C
        bit PPUSTATUS
        sta PPUSCROLL
        sta PPUSCROLL
        lda #$1E
        jsr write_control
        lda z:ppuctrl_shadow
        and #$FC
        sta PPUCTRL
        sta z:ppuctrl_shadow
        jsr fill_screens
        jsr hide_sprites
        rts
; --- $817D  Hide every sprite but the first.
hide_sprites:
        ldx #$04
        bne c8186
; --- $8181  Hide sprites from this one on.
hide_from:
        ldx $033F
        beq c8191
c8186:
        lda #$F8
c8188:
        sta $0200,x
        inx
        inx
        inx
        inx
        bne c8188
c8191:
        rts
; --- $8192  Fill the screens.
fill_screens:
        jsr picture_off
        lda #$20
        jsr fill_screen
        lda #$24
        ldy $0385
        beq c81A3                           ; the usual second screen
        lda #$28                            ; the other screen
c81A3:
        jsr fill_screen
        jsr picture_on
        rts
; --- $81AA  Fill one screen.
fill_screen:
        bit PPUSTATUS
        sta PPUADDR
        lda #$00
        sta PPUADDR
        lda #$FA
        ldx #$04
        ldy #$C0
c81BB:
        sta PPUDATA
        dey
        bne c81BB
        dex
        bne c81BB
        ldy #$40
        lda #$00
c81C8:
        sta PPUDATA
        dey
        bne c81C8
        rts
; --- $81CF  Hide the picture.
picture_off:
        lda z:ppuctrl_shadow
        and #$7F
        sta PPUCTRL
        lda z:ppumask_shadow
        and #$E6
        sta PPUMASK
        rts
; --- $81DE  Show the picture.
picture_on:
        lda z:ppuctrl_shadow
        sta PPUCTRL
        lda z:ppumask_shadow
        sta PPUMASK
        rts
; --- $81E9  Write the cartridge control.
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
black_colors:
        sta $0339
        ldy #$1F
        lda #$0F
        bit $0339
        bvs c820B
        ldy #$10
c820B:
        sta $03A3,y
        bit $0339
        bmi c8217
        cpy #$11
        beq c821A
c8217:
        dey
        bpl c820B
c821A:
        jsr send_colors
        rts
; --- $821E  Send the tiles to the screen.
send_tiles:
        lda $0387
        bne c822E
        lda #$03
        sta $2C
        lda #$C3
        sta z:packet
        inc $0387
c822E:
        rts
; --- $822F  Send the colors to the screen.
send_colors:
        lda #$03
        sta $2C
        lda #$A0
        sta z:packet
        inc $0387
        rts
; --- $823B  One frame of the cutscene.
cutscene_frame:
        ldx z:nmi_latch
        beq cutscene_frame
        inx
        stx z:nmi_latch
        stx $03C3
        stx $0395
        stx $0387
        lda $0386
        beq c825A
; Wait for the sprite that splits the picture.
c8250:
        bit PPUSTATUS
        bvs c8250
c8255:
        bit PPUSTATUS
        bvc c8255
c825A:
        ldx #$00
        lda $031D
        bne c8262
        rts
c8262:
        sta $00
        sta $01
c8266:
        jsr scroll_band
        ldy $0326,x
        lda $0327,x
; Wait, so the next band is lower.
c826F:
        dey
        bne c826F
        sec
        sbc #$01
        bcs c826F
        inx
        inx
        dec $00
        bne c8266
        bit $0384
        bpl c8292
        lda #$22
        sta PPUADDR
        lda #$80
        sta PPUADDR
        lda $038A
        jsr set_chr1
c8292:
        ldx #$00
c8294:
        clc
c8295:
        lda $031E,x
        adc $032E,x
        sta $031E,x
        inx
        txa
        and #$01
        bne c8295
        dec $01
        bne c8294
        lda $E0
        clc
        adc $A0
        sta $A0
        lda $E1
        adc $A1
        sta $A1
        lda #$00
        rol
        bit $E1
        bpl c82BE
        eor #$01
c82BE:
        eor z:ppuctrl_shadow
        sta z:ppuctrl_shadow
        lda $E2
        clc
        adc $A6
        sta $A6
        lda $E3
        adc $A7
        cmp #$F0                            ; past the bottom of the screen
        bcc c82DD
        bit a:$E3
        bmi c82DB
        clc
        adc #$10
        bcs c82DD
c82DB:
        sbc #$10
c82DD:
        sta $A7
        rts
; --- $82E0  Scroll one band of the picture.
scroll_band:
        bit PPUSTATUS
        clc
        lda $031E,x
        bpl c82EA
        sec
c82EA:
        lda $031F,x
        rol
        tay
        lda z:ppuctrl_shadow
        and #$FC
        adc #$00
        sta PPUCTRL
        sty PPUSCROLL
        lda $A7
        sta PPUSCROLL
        rts
; --- $8301  Wait for the next frame.
wait_frame:
        ldx z:nmi_latch
        beq wait_frame
        inx
        stx z:nmi_latch
        stx $03C3
        stx $0387
        stx $0395
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
split_sprite:
        sta $0200
        lda #$F8
        sta $0201
        lda #$20
        sta $0202
        lda #$F8
        sta $0203
        lda #$01
        sta $0386
        rts
; --- $8340  Load the colors.
load_colors:
        ldx #$00
        ldy #$00
        asl
        sta $00
        bcs c834D
        ldx #$11
        ldy #$04
c834D:
        sty $01
c834F:
        ldy $01
        inc $01
        lda $038C,y
        ldy #$00
        asl
        bcc c835D
        ldy #$02
c835D:
        pha
        lda cutscene_colors,y
        sta $02
        lda cutscene_colors+1,y
        sta $03
        pla
        sta $04
        lsr
        clc
        adc $04
        tay
c8370:
        txa
        and #$03
        beq c837B
        lda ($02),y
        sta $03A3,x
        iny
c837B:
        inx
        txa
        and #$03
        bne c8370
        lda $00
        bmi c8389
        cpx #$11
        beq c838D
c8389:
        cpx #$20
        bne c834F
c838D:
        lda $00
        bpl c8394
        jsr fill_backdrop
c8394:
        jsr send_colors
        rts
; --- $8398  Paint the background color into each set.
fill_backdrop:
        lda $038B
        ldx #$00
c839D:
        sta $03A3,x
        inx
        inx
        inx
        inx
        cpx #$20
        bne c839D
        rts
; --- $83A9  Buttons just pressed.
buttons_pressed:
        lda z:pad_cur
        tax
        and #$FF
        eor $EA
        and z:pad_cur
        stx $EA
        rts
; --- $83B5  Do the next thing the script says.
step_script:
        lda $0301
        beq c83BE
        dec $0301
        rts
; Still waiting.
c83BE:
        lda $0302
        beq read_step
        dec $0302
        dec $0301
        rts
; --- $83CA  The wait is over.
read_step:
        sta $0388
        jsr next_byte
        sta $0301                           ; how long to wait
        jsr next_byte
        sta $0302
        and $0301
        cmp #$FF
        bne next_command
        lda #$01
        sta $0303                           ; the script is over
; --- $83E5  This step is done.
step_done:
        lda $0305
        bne c83F4
        lda $0388
        beq c83F4
        lda #$C0
        jsr load_colors
c83F4:
        rts
; --- $83F5  The next command.
next_command:
        jsr next_byte
        tax
        inx
        beq step_done
        pha
        and #$3F
        tax
        pla
        and #$C0
        cmp #$40
        bcc flash_gray
        jmp place_on_screen
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
        bne c842A
        sta $031D
        beq next_command
c842A:
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
        beq c8443
        iny
c8443:
        sty $0385
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
        sta $E8
        jsr next_byte
        sta $E9
        jsr next_byte
        sta $0311
        jsr next_byte
        sta $0312
        jsr queue_tiles
        jmp next_command
; --- $8470  Choose the pictures.
pick_pictures:
        dex
        bne one_picture
        tax
        bpl c847E
        and #$1F
        sta $038A                           ; pictures for the lower part of the screen
        jmp next_command
c847E:
        sta a:$59                           ; CHR bank 1
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
        sta $0345,x
        jmp next_command
; --- $8499  The background color, and how the picture is shown.
tint_picture:
        dex
        bne scroll_speed
        sta $038B
        lda z:ppumask_shadow
        and #$1E
        sta z:ppumask_shadow
        jsr next_byte
        ora z:ppumask_shadow
        sta z:ppumask_shadow
        inc $0388
        jmp next_command
; --- $84B2  How the picture scrolls.
scroll_speed:
        dex
        bne pick_colors
        tax
        bne c84BE
        sta $E2                             ; stop moving up and down
        sta $E3
        beq c84E4
c84BE:
        inx
        bne c84C7
        stx $E0                             ; stop moving sideways
        stx $E1
        beq c84E4
c84C7:
        bpl c84CF
        jsr change_scroll
        jmp next_command
c84CF:
        ldx #$00
c84D1:
        lsr
        bcc c84DE
        pha
        lda #$00
        sta $032E,x
        sta $032F,x
        pla
c84DE:
        inx
        inx
        cpx #$0A
        bne c84D1
c84E4:
        jmp next_command
; --- $84E7  Which colors to use.
pick_colors:
        dex
        bne play_shot
        tay
        and #$0F
        sta $00
        ldx #$04
        tya
        bmi c84F6
        ldx #$00
c84F6:
        jsr next_byte
        sta $038C,x
        inx
        dec $00
        bne c84F6
        inc $0388
        jmp next_command
; --- $8507  Move through this shot.
play_shot:
        dex
        bne black_command
        ldy #$00
        sty $0310
        iny
        sty $030C
        tay
        asl
        sta $030D
        lda shot_wait,y
        sta $030E
        sta $030F
        jmp next_command
; --- $8524  Turn these colors black.
black_command:
        jsr black_colors
        jmp next_command
; --- $852A  Fill the screens, and draw on the background.
place_on_screen:
        cmp #$80
        bcs place_pictures
        txa
        bne c8537
        jsr fill_screens
        jmp next_command
c8537:
        stx $0336
        jsr fill_screens
        jsr next_byte
        sta $038B
        ldx #$01
c8545:
        jsr next_byte
        sta $038C,x
        inx
        cpx #$04
        bne c8545
c8550:
        jsr next_byte
        asl
        tax
        lda screen_pos,x
        sta z:picture_at                  ; where this picture goes
        lda screen_pos+1,x
        sta z:picture_at_hi
        jsr next_byte
        ldx #$80
        jsr call_bank
        dec $0336
        bne c8550
        inc $0388
        jmp next_command
; --- $8572  Put pictures on screen, or hide them.
place_pictures:
        cmp #$C0
        bcs c85DD
        txa
        bne c857F
        jsr hide_pictures
        jmp next_command
c857F:
        stx $033C
        ldx #$00
c8584:
        jsr next_byte
        sta $0390,x
        inx
        cpx #$04
        bne c8584
        ldx #$00
c8591:
        jsr next_byte
        sta $0342,x
        jsr next_byte
        asl
        php
        lsr
        sta $0344,x
        plp
        lda #$00
        sta $0343,x
        ror
        sta $0341,x
        jsr next_byte
        sta $0345,x
        jsr next_byte
        sta $0348,x
        tay
        bpl c85C7
        and #$7F
        tay
        lda c88CF,y
        sta $0346,x
        lda #$00
        sta $0347,x
c85C7:
        jsr picture_motion
        txa
        clc
        adc #$10
        tax
        dec $033C
        bne c8591
        jsr hide_pictures
        inc $0388
        jmp next_command
; The other bank handles this command.
c85DD:
        stx $0316
        jsr next_byte
        ldx #$44
        jsr call_bank
        jmp next_command
; --- $85EB  Hide the moving pictures.
hide_pictures:
        lda #$00
        cpx #$40
        beq c8609
        cpx #$30
        beq c8606
        cpx #$20
        beq c8603
        cpx #$10
        beq c8600
        sta $0340
c8600:
        sta $0350
c8603:
        sta $0360
c8606:
        sta $0370
c8609:
        rts
; --- $860A  How this picture moves.
picture_motion:
        jsr next_byte
        pha
        rol
        rol
        rol
        and #$03
        clc
        adc #$01
        sta $0340,x
        tay
        pla
        and #$3F
        dey
        dey
        bmi c863E
        bne c863F
        asl
        asl
        tay
        lda c8B04,y
        sta $0349,x
        lda c8B04+1,y
        sta $034A,x
        lda c8B04+2,y
        sta $034B,x
        lda c8B04+3,y
        sta $034C,x
c863E:
        rts
c863F:
        dey
        bne c8652
        sta $0349,x
        tay
        lda c88E3,y
        sta $034A,x
        lda #$00
        sta $034B,x
        rts
c8652:
        sta $00
        asl
        clc
        adc $00
        asl
        tay
        lda c8B6C,y
        sta $0349,x
        lda c8B6C+1,y
        sta $034A,x
        lda c8B6C+2,y
        sta $034B,x
        lda c8B6C+3,y
        sta $034C,x
        lda c8B6C+4,y
        sta $034D,x
        lda c8B6C+5,y
        sta $034F,x
        rts
; --- $867F  The next byte of the script.
next_byte:
        ldy $0304
        lda ($0A),y
        iny
        bne c8689
        inc $0B
c8689:
        sty $0304
        rts
; --- $868D  Start fading the colors.
start_fade:
        tax
        lsr
        lsr
        and #$1F
        tay
        lda shade_delay,y
        sta $0309
        sta $0306
        txa
        and #$80
        sta $0307
        txa
        ror
        ror
        ror
        and #$C0
        sta $0308
        lda #$04
        sta $0305
        lda #$C0
        jsr load_colors
        bit $0307
        bpl c86C0
        lda $0308
        jsr black_colors
c86C0:
        rts
; --- $86C1  Start flashing the picture gray.
start_gray:
        lda #$3F
        pha
        lsr
        and #$70
        sta $030B
        pla
        and #$1F
        asl
        sta $030A
        rts
; --- $86D2  Start this camera move.
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
        sta $0384
        ldy #$00
        sty $030C
        sty $A0
        sty $A6
        lda ($00),y
        iny
        sta $031D
        sta $02
        lda z:ppuctrl_shadow
        and #$FC
        ora ($00),y
        iny
        sta z:ppuctrl_shadow
        lda ($00),y
        iny
        sta $0200
        lda ($00),y
        iny
        sta $A1
        lda ($00),y
        iny
        sta $A7
        lda ($00),y
        iny
        sta $E0
        lda ($00),y
        iny
        sta $E1
        lda ($00),y
        iny
        sta $E2
        lda ($00),y
        iny
        sta $E3
        lda $031D
        beq c8755
        ldx #$00
c872C:
        lda ($00),y
        iny
        sta $031F,x
        lda #$00
        sta $031E,x
        lda ($00),y
        iny
        sta $0326,x
        lda ($00),y
        iny
        sta $0327,x
        lda ($00),y
        iny
        sta $032E,x
        lda ($00),y
        iny
        sta $032F,x
        inx
        inx
        dec $02
        bne c872C
c8755:
        rts
; --- $8756  Change that move.
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
        sta $02
        iny
        iny
        iny
        iny
        lda ($00),y
        iny
        sta $E0
        lda ($00),y
        iny
        sta $E1
        lda ($00),y
        iny
        sta $E2
        lda ($00),y
        iny
        sta $E3
        lda a:$02
        beq c879F
        ldx #$00
c878A:
        iny
        iny
        iny
        lda ($00),y
        iny
        sta $032E,x
        lda ($00),y
        iny
        sta $032F,x
        inx
        inx
        dec $02
        bne c878A
c879F:
        rts
; --- $87A0  One step darker.
darken_colors:
        lda $0306
        beq c87A9
        dec $0306
        rts
c87A9:
        lda $0309
        sta $0306
        lda $0307
        bpl c87B9
        lda #$C0
        jsr load_colors
c87B9:
        lda $0305
        sec
        sbc #$01
        asl
        asl
        asl
        asl
        sta $00
        ldy #$00
        bit $0308
        bmi c87CE
        ldy #$11
c87CE:
        lda $0307
        bmi c87F5
        lda $03A3,y
        sec
        sbc #$10                            ; one shade darker
        bpl c87DD
        lda #$0F                            ; black
c87DD:
        sta $03A3,y
        bit $0308
        bvs c87E9
        cpy #$10
        beq c87EE
c87E9:
        iny
        cpy #$20
        bne c87CE
c87EE:
        dec $0305
        jsr send_colors
        rts
c87F5:
        lda $03A3,y
        and #$F0
        sec
        sbc $00
        sta $01
        bmi c880B
        lda $03A3,y
        and #$0F
        ora $01
        jmp c87DD
c880B:
        lda #$0F                            ; black
        bne c87DD
; --- $880F  One step of the gray flash.
gray_flash:
        lda $030B
        tax
        and #$07
        beq c881B
        dec $030B
        rts
c881B:
        txa
        lsr
        lsr
        lsr
        lsr
        ora $030B
        sta $030B
        lda z:ppumask_shadow
        eor #$01                            ; gray
        sta z:ppumask_shadow
        dec $030A
        bne c8835
        lsr z:ppumask_shadow                ; color again
        asl z:ppumask_shadow
c8835:
        rts
; --- $8836  Copy tiles into the list the screen draws.
queue_tiles:
        ldy #$00
        ldx $0395
c883B:
        lda ($E8),y
        sta $03C3,x
        bne c8849
        stx $0395
        jsr send_tiles
        rts
c8849:
        and #$7F
        sta $02
        iny
        clc
        lda $0311
        adc ($E8),y
        sta $03C4,x
        iny
        lda $0312
        adc ($E8),y
        sta $03C5,x
        iny
        inx
        inx
        inx
c8864:
        lda ($E8),y
        sta $03C3,x
        iny
        inx
        dec $02
        bne c8864
        beq c883B
; --- $8871  The next place in this shot.
scroll_step:
        lda $030F
        beq c887A
        dec $030F
        rts
c887A:
        lda $030E
        sta $030F
        ldx $030D
        lda shot_place,x
        sta $00
        lda shot_place+1,x
        sta $01
        ldy $0310
c8890:
        lda ($00),y
        bpl c8898
        ldy #$00
        beq c8890
c8898:
        lda z:ppuctrl_shadow
        and #$FC
        ora ($00),y
        sta z:ppuctrl_shadow
        iny
        lda ($00),y
        iny
        sta $A1
        lda ($00),y
        iny
        sta $A7
        sty $0310
        rts

; Frames between shades. 0 through 31.
shade_delay:
        .byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
        .byte $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $1D, $1E, $1F
c88CF:
        .byte $44, $33, $33, $FF, $33, $22, $55, $33, $55, $22, $33, $33, $88, $33, $66, $66
        .byte $FF, $88, $AA, $33
; How one kind of picture moves.
c88E3:
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
; How one kind of picture moves.
c8B04:
        .byte $00, $04, $00, $00, $00, $FC, $00, $00, $00, $04, $00, $FC, $00, $FC, $00, $FC
        .byte $00, $00, $00, $04, $C0, $FF, $00, $00, $40, $00, $00, $00, $10, $00, $30, $00
        .byte $C0, $FF, $E0, $FF, $00, $00, $40, $00, $80, $00, $00, $FE, $00, $FE, $00, $02
        .byte $80, $00, $00, $00, $00, $FC, $40, $00, $00, $F8, $00, $00, $E0, $FF, $00, $00
        .byte $F0, $FF, $00, $00, $20, $00, $00, $00, $80, $FF, $00, $00, $00, $00, $00, $02
        .byte $00, $00, $00, $FE, $08, $00, $0A, $00, $00, $00, $0A, $00, $04, $00, $20, $00
        .byte $00, $00, $10, $00, $00, $00, $0C, $00
; How one kind of picture moves.
c8B6C:
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
        .word script_0C
        .word script_0D

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
script_0C:
        .byte $1F, $00, $80, $03, $54, $05, $1E, $06, $2A, $02, $42, $0F, $0D, $53, $00, $0D
        .byte $1A, $17, $1D, $FF, $1F, $00, $03, $55, $FF, $B3, $00, $0B, $01, $81, $A1, $9A
        .byte $9B, $9C, $58, $2C, $00, $50, $01, $04, $A9, $FF, $FF, $FF
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
        .word c8003                         ; inside the setup above
        .word c8006
        .word c8009
        .word c800C
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $D8, $A9, $10, $8D, $00, $20, $A9, $80, $8D, $00

; --- $BFDA  Same first instructions as reset.
reset_copy_04:
        inc $FFDA
        jmp $C03E
        .byte $FF, $9F, $4A, $CA, $D0, $F9, $4C, $00, $80, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $DA, $FF, $DA, $FF, $DA, $FF
