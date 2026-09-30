; PRG file bank 06, switched in at $8000-$BFFF.
; Cutscene pictures, the lines that are spoken, and the sound test.
; Bank 04 calls here to draw on the background, and to run the sound test.

; --- $8000  Draw this picture on the background.
; The call list at the end of this bank points here.
draw_picture:
        jmp f8006

; --- $8003  The sound test.
start_sound_test:
        jmp run_sound_test

; The call list points here, inside the drawing.
f8006:
        jsr hide_picture
f8009:
        lda call_num                    ; which picture
f800C:
        asl
        tax
        lda picture_list,x
        sta $00
        lda picture_list+1,x
        sta $01
        ldy #$00
        lda ($00),y
        iny
        tax
        and #$1F
        sta chr_bank1                   ; background tiles
        txa
        lsr
        lsr
        lsr
        lsr
        and #$0E
        tax                             ; which set of tiles
        lda picture_parts,x
        sta $02
        lda picture_parts+1,x
        sta $03
        lda picture_parts+6,x           ; and its colors
        sta $04
        lda picture_parts+7,x
        sta $05
        lda ($00),y
        iny
        sty $07
        tax
        lsr
        lsr
        lsr
        lsr
        sta $0337                       ; how many across
        asl
        asl
        eor #$FF
        adc #$41
        sta $0E                         ; how far down to the next row
        txa
        and #$0F
        sta $0338                       ; how many down
        jsr aim_screen
f805C:
        lda $0337
        sta $06
f8061:
        ldy $07
        inc $07
        lda ($00),y
        pha
        tax
        lsr
        lsr
        lsr
        lsr
        lsr
        tay
        txa
        asl
        asl
        asl
        clc
        adc $02
        sta $08
        tya
        adc $03
        sta $09
        ldy #$00
f807F:
        lda ($08),y
        sta PPUDATA                     ; one tile
        iny
        cpy #$08
        beq f8095
        cpy #$04
        bne f807F
        lda #$20
        jsr seek_screen                 ; the row under it
        jmp f807F
f8095:
        jsr color_spot
        pla
        lsr
        tay
        lda ($04),y
        bcs f80A3
        lsr
        lsr
        lsr
        lsr
f80A3:
        and #$0F
        ldy #$F0
        bit $0389
        bpl f80B2
        asl
        asl
        asl
        asl
        ldy #$0F
f80B2:
        sty $033A
        bit $0389
        bvs f80F2                       ; this square runs into the next color cell
        jsr spread_color
        sta $0339
        lda PPUDATA
        lda PPUDATA
        ldx PPUSTATUS
        ldx $0D
        stx PPUADDR
        ldx $0C
        stx PPUADDR
        ldx PPUDATA
        ora PPUDATA
        and $033A
        ora $0339
        ldx PPUSTATUS
        ldx $0D
        stx PPUADDR
        ldx $0C
        stx PPUADDR
        sta PPUDATA
        jmp f812A
f80F2:
        tax
        and #$CC
        sta $0339
        txa
        and #$33
        sta $033B
        lda PPUDATA
        lda $033A
        tax
        ora #$33
        and PPUDATA
        ora $0339
        tay
        txa
        ora #$CC
        and PPUDATA
        ora $033B
        ldx PPUSTATUS
        ldx $0D
        stx PPUADDR
        ldx $0C
        stx PPUADDR
        sty PPUDATA
        sta PPUDATA
f812A:
        lda #$04
        jsr step_screen
        dec $06
        beq f8136
        jmp f8061
f8136:
        lda $0E
        jsr step_screen
        dec $0338
        beq f8143
        jmp f805C
f8143:
        lda #$3F
        sta PPUADDR                     ; back to the colors
        lda #$00
        sta PPUADDR
        sta PPUADDR
        sta PPUADDR
        jsr show_picture
        rts

; --- $8157  Hide the picture.
hide_picture:
        lda z:ppuctrl_shadow
        and #$7F                        ; NMI off
        sta PPUCTRL
        lda z:ppumask_shadow
        and #$E6                        ; hide the background and the sprites
        sta PPUMASK
        rts

; --- $8166  Show the picture.
show_picture:
        lda z:ppuctrl_shadow
        sta PPUCTRL
        lda z:ppumask_shadow
        sta PPUMASK
        rts

; --- $8171  Hand the tiles to the screen, if they have not gone yet.
hand_tiles:
        lda tiles_handed
        bne f8181
        lda #$03
        sta $2C
        lda #$C3
        sta z:packet
        inc tiles_handed
f8181:
        rts

; --- $8182  Hand the colors to the screen.
hand_colors:
        lda #$03
        sta $2C
        lda #$A0
        sta z:packet
        inc tiles_handed
        rts

; --- $818E  Call the routine picked from the list after this jsr.
pick_routine:
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

; --- $81A4  Spread this color across the square.
spread_color:
        pha
        lsr
        lsr
        and #$33
        sta $0339
        pla
        asl
        asl
        and #$CC
        ora $0339
        rts

; --- $81B5  Point at the screen, A tiles over.
seek_screen:
        clc
        adc z:picture_at
        pha
        lda z:picture_at_hi
        adc #$00
        bit PPUSTATUS
        sta PPUADDR
        pla
        sta PPUADDR
        rts

; --- $81C8  Move A tiles along the screen.
step_screen:
        clc
        adc z:picture_at
        sta z:picture_at
        lda z:picture_at_hi
        adc #$00
        sta z:picture_at_hi
        jsr aim_screen
        rts

; --- $81D7  Point at this place on the screen.
aim_screen:
        bit PPUSTATUS
        lda z:picture_at_hi
        sta PPUADDR
        lda z:picture_at
        sta PPUADDR
        rts

; --- $81E5  Where this place's color is stored.
color_spot:
        bit PPUSTATUS
        lda z:picture_at_hi
        tax
        ora #$03
        sta PPUADDR
        sta $0D
        txa
        and #$03
        sta $0339
        lda z:picture_at
        tax
        asl
        rol $0339
        asl
        php
        lda $0339
        asl
        asl
        asl
        sta $0339
        txa
        and #$1F
        lsr
        lsr
        ora $0339
        ora #$C0
        sta PPUADDR
        sta $0C
        ror
        plp
        ror
        and #$C0
        sta $0389
        rts

; --- $8222  Show a number, and play it as a sound.
; Down lowers it. Up raises it. Start resets the game.
; B plays a sound. A plays the number.
run_sound_test:
        ldx #$00
        stx $0C
        lda #$10
        sta a:chr_bank0                 ; the number's tiles
        lda #$87                        ; how high the number sits
        sta $0200
        sta $0204
        lda #$90
        sta z:ppuctrl_shadow            ; turn the picture on
        sta $0203
        lda #$98
        sta $0207
        stx $0202
        stx $0206
        lda #$0A                        ; how many tiles
        sta $03C3
        lda #$22                        ; behind the number
        sta $03C5
        lda #$2B
        sta $03C4
        stx $03D0
f8257:
        lda test_tiles,x
        sta $03C6,x
        inx
        cpx #$0A
        bne f8257
        jsr hand_tiles
f8265:
        ldx z:nmi_latch
        beq f8265
        inx
        stx z:nmi_latch
        stx tiles_handed
        jsr button_edge
        lsr
        lsr
        lsr
        bcc f8279
        dec $0C                         ; one lower
f8279:
        lsr
        bcc f827E
        inc $0C                         ; one higher
f827E:
        tax
        lda $0C
        bpl f8287
        lda #$4F                        ; the last number
        bne f828D
f8287:
        cmp #$50
        bcc f828D
        lda #$00                        ; the first number
f828D:
        sta $0C
        txa
        lsr
        bcc f8296
        jmp $FFDA                       ; the game resets
f8296:
        lsr
        lsr
        bcc f829F
        ldx #$02
        stx sound                       ; play a sound
f829F:
        lsr
        bcc f82A7
        lda $0C
        sta sound                       ; play this number
f82A7:
        lda $0C
        lsr
        lsr
        lsr
        lsr
        ora #$C0
        sta $0201                       ; the high digit
        lda $0C
        and #$0F
        ora #$C0
        sta $0205                       ; the low digit
        jmp f8265

; --- $82BE  Which buttons were just pressed.
button_edge:
        lda z:pad_cur
        tax
        and #$FF
        eor pad_last
        and z:pad_cur
        stx pad_last
        rts

; --- $82CA  Tiles on the sound test.
test_tiles:
        .byte $FA, $B9, $E1, $BA, $EC, $BC, $FA, $FA, $FA, $FA

; --- $82D4  Which picture to draw.
; The first byte picks the background tiles, and which set of blocks.
; The next byte is how many across, and how many down. Then the blocks.
picture_list:
        .word moon_field
        .word streaks
        .word moon_grass
        .word ryu_bust
        .word the_sword
        .word eyes_open
        .word eyes_hard
        .word eyes_closing
        .word eyes_shut
        .word irene_gun
        .word demon_statue
        .word irene_profile
        .word walter
        .word smith_back
        .word temple_moon
        .word field_trees
        .word temple_field
        .word jaquio_face
        .word broken_wall
        .word malth
        .word fathers_fight
        .word devil_mask
        .word father
        .word three_faces
        .word demon_claw
        .word grass
        .word ryu_runs
        .word bloody_hall
        .word title_ninja
        .word title_logo
        .word forest_top
        .word great_moon
        .word gold_armor
        .word blank_strip
        .word cell_door
        .word cell_open
        .word stone_wall
        .word roof_hole
        .word cia_agents
        .word looking_down
        .word foster_office
        .word red_close
        .word jungle
        .word irene_held
        .word ryu_profile
        .word ryu_face
        .word ryu_back
        .word father_wakes
        .word a_hand
        .word leaves
        .word blank_purple
        .word night_sky
        .word gold_statue
        .word small_statue
        .word presents
        .word blank_gray
        .word irene_held_close
        .word ryu_edge
        .word office_wall
        .word temple_hall
        .word temple_demon
        .word office_stripes
        .word push_start
        .word push_start_spare
        .word the_end

; --- $8356  The moon over the field.
moon_field:
        .byte $12, $8B, $5F, $08, $06, $09, $06, $11, $10, $12, $09, $0C, $0D, $13, $14, $07
        .byte $0A, $08, $0E, $0A, $0B, $15, $16, $09, $09, $11, $0D, $09, $0D, $17, $18, $06
        .byte $0E, $07, $09, $0E, $0F, $19, $1A, $09, $06, $0E, $06, $06, $09, $09, $06, $06
        .byte $06, $06, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01, $01, $01, $01
        .byte $01, $01, $02, $02, $02, $02, $02, $02, $02, $02, $03, $03, $03, $03, $03, $03
        .byte $03, $03, $04, $04, $04, $04, $04, $04, $04, $04
        .byte $05, $05, $05, $05, $05, $05, $05, $05

; --- $83B8  White streaks.
streaks:
        .byte $32, $84, $77, $73, $76, $79, $79, $25, $78, $7D, $74, $75, $25, $78, $7A, $7B
        .byte $25, $79, $77, $76, $79, $74, $75, $25, $78, $25, $73, $25, $78, $7A, $7B, $7C
        .byte $7D, $7D

; --- $83DA  The edge of the moon, and the grass.
moon_grass:
        .byte $3E, $84, $25, $25, $25, $25, $25, $38, $39, $25, $25, $25, $25, $25, $25, $3A
        .byte $3B, $25, $26, $26, $26, $26, $26, $26, $26, $26, $27, $27, $27, $27, $27, $27
        .byte $27, $27

; --- $83FC  Ryu, from the chest up.
ryu_bust:
        .byte $34, $24, $16, $1A, $17, $1B, $18, $1C, $19, $1D

; --- $8406  The Dragon Sword.
the_sword:
        .byte $34, $44, $08, $0C, $10, $13, $09, $0D, $11, $14, $0A, $0E, $12, $15, $0B, $0F
        .byte $10, $13

; --- $8418  Ryu's eyes.
eyes_open:
        .byte $15, $84, $06, $06, $20, $21, $22, $23, $06, $06, $06, $06, $28, $29, $2A, $2B
        .byte $06, $06, $06, $06, $2C, $2D, $2E, $2F, $06, $06, $06, $06, $24, $25, $26, $27
        .byte $06, $06

; --- $843A  Ryu's eyes, set hard.
eyes_hard:
        .byte $15, $84, $06, $06, $20, $21, $22, $23, $06, $06, $06, $06, $30, $31, $32, $33
        .byte $06, $06, $06, $06, $34, $35, $36, $37, $06, $06, $06, $06, $24, $25, $26, $27
        .byte $06, $06

; --- $845C  Ryu's eyes, closing.
eyes_closing:
        .byte $15, $84, $06, $06, $20, $21, $22, $23, $06, $06, $06, $06, $38, $39, $3A, $3B
        .byte $06, $06, $06, $06, $2C, $3C, $3D, $3E, $06, $06, $06, $06, $24, $25, $26, $27
        .byte $06, $06

; --- $847E  Ryu's eyes, shut.
eyes_shut:
        .byte $15, $84, $06, $06, $20, $21, $22, $23, $06, $06, $06, $06, $38, $40, $41, $3B
        .byte $06, $06, $06, $06, $2C, $42, $43, $2F, $06, $06, $06, $06, $24, $25, $26, $27
        .byte $06, $06

; --- $84A0  Irene Lew, holding a gun.
irene_gun:
        .byte $16, $86, $06, $06, $06, $06, $1B, $1D, $06, $06, $06, $06, $06, $06, $1C, $1E
        .byte $06, $06, $06, $06, $06, $06, $1F, $44, $06, $06, $06, $06, $06, $06, $3F, $45
        .byte $06, $06, $06, $06, $06, $46, $48, $4A, $06, $06, $06, $06, $06, $47, $49, $4B
        .byte $06, $06

; --- $84D2  A demon statue.
demon_statue:
        .byte $33, $24, $00, $04, $01, $05, $02, $06, $03, $07

; --- $84DC  Irene Lew, in profile.
irene_profile:
        .byte $33, $34, $1E, $22, $25, $1F, $23, $25, $20, $24, $25, $21, $25, $25

; --- $84EA  Walter Smith.
walter:
        .byte $34, $84, $25, $25, $25, $3C, $3E, $43, $25, $25, $25, $25, $25, $3D, $3F, $44
        .byte $25, $25, $25, $25, $25, $40, $41, $45, $25, $25, $25, $25, $25, $25, $42, $46
        .byte $47, $48

; --- $850C  Walter Smith, from behind.
smith_back:
        .byte $17, $84, $9D, $9E, $06, $06, $06, $A2, $9D, $9D, $9F, $A0, $06, $A9, $AC, $06
        .byte $A3, $A4, $A1, $06, $06, $AA, $AD, $06, $A5, $A7, $A1, $06, $06, $AB, $AE, $06
        .byte $A6, $A8

; --- $852E  The temple under the moon.
temple_moon:
        .byte $12, $8B, $B6, $BB, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $BC, $C0, $B6, $13, $D1
        .byte $B6, $B6, $B6, $BD, $C1, $B6, $15, $16, $B6, $B6, $B7, $D0, $C2, $B6, $17, $18
        .byte $B6, $B6, $B8, $BE, $C3, $B6, $D2, $1A, $B6, $B6, $B9, $BF, $C4, $B6, $B6, $B6
        .byte $B6, $B6, $BA, $B5, $C5, $B6, $B6, $B6, $B6, $B6, $C6, $C7, $C8, $C9, $C9, $C9
        .byte $C9, $C9, $CA, $CB, $CA, $CB, $CA, $CB, $CA, $CB, $CC, $CD, $CC, $CD, $CC, $CD
        .byte $CC, $CD, $CE, $CF, $CE, $CF, $CE, $CF, $CE, $CF

; --- $8588  The field and the trees.
field_trees:
        .byte $12, $8B, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6
        .byte $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6
        .byte $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6
        .byte $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $C9, $C9, $C9, $C9, $C9, $C9
        .byte $C9, $C9, $CA, $CB, $CA, $CB, $CA, $CB, $CA, $CB, $CC, $CD, $CC, $CD, $CC, $CD
        .byte $CC, $CD, $CE, $CF, $CE, $CF, $CE, $CF, $CE, $CF

; --- $85E2  The temple over the field.
temple_field:
        .byte $12, $8B, $B6, $B6, $B6, $B6, $B6, $BB, $B6, $B6, $B6, $B6, $B6, $B6, $B6, $BC
        .byte $C0, $B6, $B6, $B6, $B6, $B6, $B6, $BD, $C1, $B6, $B6, $B6, $B6, $B6, $B7, $D0
        .byte $C2, $B6, $B6, $B6, $B6, $B6, $B8, $BE, $C3, $B6, $B6, $B6, $B6, $B6, $B9, $BF
        .byte $C4, $B6, $B6, $B6, $B6, $B6, $BA, $B5, $C5, $B6, $C9, $C9, $C9, $C9, $C6, $C7
        .byte $C8, $C9, $CA, $CB, $CA, $CB, $CA, $CB, $CA, $CB, $CC, $CD, $CC, $CD, $CC, $CD
        .byte $CC, $CD, $CE, $CF, $CE, $CF, $CE, $CF, $CE, $CF

; --- $863C  The Jaquio.
jaquio_face:
        .byte $38, $64, $50, $52, $53, $54, $5E, $60, $51, $57, $55, $56, $5F, $61, $25, $58
        .byte $5A, $5B, $62, $25, $25, $59, $5C, $5D, $63, $25

; --- $8656  The wall, broken open.
broken_wall:
        .byte $16, $84, $8F, $90, $8F, $8F, $90, $8F, $96, $9A, $91, $91, $91, $91, $95, $91
        .byte $97, $9B, $90, $8F, $8F, $90, $8F, $98, $9C, $06, $91, $95, $91, $91, $91, $99
        .byte $06, $06

; --- $8678  Malth.
malth:
        .byte $1A, $44, $52, $55, $59, $52, $53, $56, $5A, $5D, $54, $57, $5B, $5E, $06, $58
        .byte $5C, $06

; --- $868A  A scarred face, and a man under the moon.
fathers_fight:
        .byte $19, $64, $79, $7D, $52, $52, $87, $8B, $7A, $7E, $81, $84, $88, $8C, $7B, $7F
        .byte $82, $85, $89, $8D, $7C, $80, $83, $86, $8A, $8E

; --- $86A4  The masked devil.
devil_mask:
        .byte $3A, $44, $28, $2C, $30, $34, $29, $2D, $31, $35, $2A, $2E, $32, $36, $2B, $2F
        .byte $33, $37

; --- $86B6  Ryu's father.
father:
        .byte $17, $44, $06, $06, $06, $06, $06, $AF, $B2, $06, $06, $B0, $B3, $06, $06, $B1
        .byte $B4, $06

; --- $86C8  Three screaming faces.
three_faces:
        .byte $38, $64, $64, $25, $66, $6B, $25, $6F, $65, $25, $67, $6C, $25, $70, $6A, $25
        .byte $68, $6D, $25, $25, $25, $25, $69, $6E, $25, $71

; --- $86E2  A claw.
demon_claw:
        .byte $1D, $44, $06, $06, $4C, $4F, $06, $06, $4D, $50, $06, $06, $4E, $51, $06, $06
        .byte $06, $06

; --- $86F4  The grass.
grass:
        .byte $3F, $84, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25
        .byte $25, $25, $FC, $FD, $FC, $FD, $FC, $FD, $FC, $FD, $FE, $FF, $FE, $FF, $FE, $FF
        .byte $FE, $FF

; --- $8716  Ryu, running.
ryu_runs:
        .byte $11, $35, $60, $64, $06, $61, $65, $06, $62, $66, $06, $63, $67, $68, $06, $06
        .byte $69

; --- $8727  The Jaquio, and blood on the walls. No script draws this.
; The scene with Foster draws a close-up of him.
bloody_hall:
        .byte $3F, $64, $7E, $7F, $83, $86, $8A, $7E, $7E, $80, $84, $87, $8B, $7E, $7E, $81
        .byte $10, $88, $8C, $7E, $7E, $82, $10, $89, $8D, $7E

; --- $8741  The word NINJA. The title, the sound test, and the ending draw this.
title_ninja:
        .byte $5B, $84, $60, $61, $64, $67, $6A, $6E, $71, $74, $60, $62, $65, $68, $6B, $6F
        .byte $72, $75, $60, $63, $66, $69, $6C, $70, $73, $76, $1B, $1B, $1B, $1B, $1B, $1B
        .byte $1B, $1B

; --- $8763  The Ninja Gaiden logo.
title_logo:
        .byte $11, $52, $6A, $6C, $6E, $70, $72, $6B, $6D, $6F, $71, $73

; --- $876F  The top of the forest, and a path.
forest_top:
        .byte $3E, $83, $A0, $A1, $A2, $A1, $A3, $A1, $A2, $A0, $A4, $A5, $A4, $A5, $A6, $A7
        .byte $A4, $A5, $AA, $A9, $A8, $A9, $AA, $AB, $A8, $A9

; --- $8789  The moon.
great_moon:
        .byte $3E, $8E, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25
        .byte $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25
        .byte $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25
        .byte $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25
        .byte $25, $25, $25, $25, $4D, $8F, $93, $96, $25, $25, $25, $25, $4E, $10, $10, $97
        .byte $25, $25, $25, $49, $4F, $10, $10, $98, $9C, $25, $25, $4A, $72, $90, $94, $99
        .byte $9D, $25, $25, $4B, $85, $91, $95, $9A, $9E, $25, $25, $4C, $8E, $92, $92, $9B
        .byte $9F, $25

; --- $87FB  A man in gold armor and a purple cape.
gold_armor:
        .byte $1C, $84, $06, $06, $06, $D6, $DA, $06, $06, $06, $06, $06, $D3, $D7, $DB, $06
        .byte $06, $06, $06, $06, $D4, $D8, $DC, $06, $06, $06, $06, $06, $D5, $D9, $DD, $06
        .byte $06, $06

; --- $881D  A blank strip.
blank_strip:
        .byte $12, $84, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06
        .byte $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06
        .byte $06, $06

; --- $883F  The cell door.
cell_door:
        .byte $32, $64, $AC, $AF, $B4, $B8, $AC, $AF, $AC, $AF, $B5, $B9, $AD, $B0, $AD, $B0
        .byte $B6, $BA, $AE, $B1, $AE, $B1, $B7, $BB, $AE, $B1

; --- $8859  The cell door, open.
cell_open:
        .byte $32, $64, $AC, $AF, $BF, $C3, $AC, $AF, $AC, $AF, $C0, $25, $AD, $B0, $AD, $B0
        .byte $C1, $25, $AE, $B1, $AE, $B1, $C2, $25, $AE, $B1

; --- $8873  The stone wall.
stone_wall:
        .byte $32, $64, $AC, $B3, $AC, $B3, $AC, $C4, $B2, $BC, $AC, $B3, $AC, $C4, $AC, $AC
        .byte $BD, $BE, $BD, $C5, $AC, $AC, $B3, $C4, $B3, $AC

; --- $888D  A hole in the roof.
roof_hole:
        .byte $56, $64, $33, $33, $36, $3A, $3E, $33, $33, $33, $37, $3B, $3F, $33, $33, $34
        .byte $38, $3C, $40, $33, $33, $35, $39, $3D, $41, $33

; --- $88A7  Three men from the CIA, with guns.
cia_agents:
        .byte $34, $64, $C6, $CA, $C6, $CA, $C6, $CA, $C7, $CB, $CE, $D0, $D1, $D2, $C8, $CC
        .byte $C8, $CC, $C8, $CC, $C9, $CD, $CF, $CD, $C9, $CD

; --- $88C1  A face, looking down.
looking_down:
        .byte $3E, $44, $D3, $25, $25, $D8, $D4, $25, $25, $D9, $D5, $25, $25, $DA, $D6, $D7
        .byte $DC, $DB

; --- $88D3  Foster's office.
foster_office:
        .byte $35, $84, $DE, $DD, $DD, $DD, $DD, $DD, $E4, $E7, $DE, $DD, $DD, $DD, $DD, $DD
        .byte $E4, $E7, $DE, $DD, $DD, $DD, $DD, $DD, $E5, $E8, $DE, $DF, $E0, $E1, $E2, $E3
        .byte $E6, $E9

; --- $88F5  The Jaquio, close up. The scene with Foster draws this.
red_close:
        .byte $1F, $85, $DE, $E2, $06, $06, $06, $06, $06, $06, $DF, $E3, $06, $06, $06, $06
        .byte $06, $06, $E0, $E4, $06, $06, $06, $06, $06, $06, $E1, $E5, $06, $06, $06, $06
        .byte $06, $06, $06, $06, $06, $06, $06, $06, $06, $06

; --- $891F  The jungle.
jungle:
        .byte $56, $8B, $00, $00, $00, $00, $00, $00, $00, $00, $01, $02, $00, $01, $03, $01
        .byte $04, $03, $01, $04, $03, $00, $00, $01, $03, $00, $05, $07, $00, $07, $05, $05
        .byte $00, $07, $06, $08, $09, $08, $06, $06, $09, $08, $0A, $0A, $0A, $0A, $0A, $0A
        .byte $0A, $0A, $1B, $1B, $1B, $1B, $1B, $1B, $1B, $1B, $0B, $0F, $13, $17, $0B, $0F
        .byte $13, $17, $0C, $10, $14, $18, $0C, $10, $14, $18, $0D, $11, $15, $19, $0D, $11
        .byte $15, $19, $0E, $12, $16, $1A, $0E, $12, $16, $1A

; --- $8979  Irene Lew, and a masked man.
irene_held:
        .byte $1F, $44, $E6, $EA, $EE, $06, $E7, $EB, $EF, $F2, $E8, $EC, $F0, $F3, $E9, $ED
        .byte $F1, $F4

; --- $898B  Ryu, in profile.
ryu_profile:
        .byte $33, $84, $25, $25, $25, $25, $25, $F0, $F4, $F8, $25, $25, $25, $25, $25, $F1
        .byte $F5, $F9, $EA, $EC, $EE, $EA, $EC, $F2, $F6, $FA, $EB, $ED, $EF, $EB, $ED, $F3
        .byte $F7, $FB

; --- $89AD  Ryu's face.
ryu_face:
        .byte $5D, $84, $1B, $1B, $25, $28, $2C, $30, $1B, $1B, $1B, $1B, $26, $29, $2D, $31
        .byte $1B, $1B, $1B, $1B, $27, $2A, $2E, $32, $1B, $1B, $1B, $1B, $1B, $2B, $2F, $1B
        .byte $1B, $1B

; --- $89CF  The back of Ryu's head.
ryu_back:
        .byte $1C, $84, $06, $F5, $52, $FB, $06, $06, $06, $06, $06, $F6, $52, $FC, $06, $06
        .byte $06, $06, $06, $F7, $F9, $FD, $06, $06, $06, $06, $06, $F8, $FA, $FE, $06, $06
        .byte $06, $06

; --- $89F1  Ryu's father, close up.
father_wakes:
        .byte $57, $64, $1B, $1C, $20, $1B, $1B, $1B, $1B, $1D, $21, $1B, $1B, $1B, $1B, $1E
        .byte $22, $1B, $1B, $1B, $1B, $1F, $23, $24, $1B, $1B

; --- $8A0B  A hand.
a_hand:
        .byte $5D, $44, $1B, $42, $46, $1B, $1B, $43, $48, $1B, $1B, $44, $49, $1B, $1B, $45
        .byte $4A, $1B

; --- $8A1D  The leaves.
leaves:
        .byte $5C, $84, $4B, $4F, $4B, $4F, $4B, $4F, $51, $4F, $4C, $50, $4C, $4E, $4C, $50
        .byte $4C, $50, $4F, $4B, $4D, $52, $4F, $51, $4F, $4B, $50, $4C, $47, $4C, $50, $52
        .byte $50, $4C

; --- $8A3F  A blank purple strip.
blank_purple:
        .byte $33, $34, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25

; --- $8A4D  The night sky.
night_sky:
        .byte $5A, $44, $53, $55, $55, $54, $55, $55, $55, $55, $54, $55, $55, $53, $56, $56
        .byte $57, $57

; --- $8A5F  A demon statue, in gold.
gold_statue:
        .byte $53, $24, $58, $5C, $59, $5D, $5A, $5E, $5B, $5F

; --- $8A69  A small statue.
small_statue:
        .byte $17, $11, $74

; --- $8A6C  PRESENTS 1989.
presents:
        .byte $1B, $22, $75, $76, $77, $FF

; --- $8A72  A blank gray strip.
blank_gray:
        .byte $1F, $85, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06
        .byte $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06
        .byte $06, $06, $06, $06, $06, $06, $06, $06, $06, $06

; --- $8A9C  Irene Lew, and a masked man, closer.
irene_held_close:
        .byte $1F, $34, $E6, $EA, $EE, $E7, $EB, $EF, $E8, $EC, $F0, $E9, $ED, $F1

; --- $8AAA  The edge of Ryu's hair.
ryu_edge:
        .byte $13, $11, $78

; --- $8AAD  The office wall.
office_wall:
        .byte $35, $64, $DD, $DD, $DD, $DD, $DE, $DD, $DD, $DD, $DD, $DD, $DE, $DD, $DD, $DD
        .byte $DD, $DD, $DE, $DD, $DD, $DD, $DD, $DD, $DE, $DD

; --- $8AC7  The temple hall.
temple_hall:
        .byte $4D, $84, $7D, $7D, $81, $85, $81, $89, $81, $8D, $7E, $7F, $82, $84, $82, $8A
        .byte $82, $8E, $80, $80, $83, $86, $88, $8B, $86, $8F, $7F, $7F, $84, $87, $84, $8C
        .byte $87, $90

; --- $8AE9  The temple hall, and a demon.
temple_demon:
        .byte $4D, $84, $91, $95, $98, $81, $82, $85, $9C, $9C, $92, $96, $99, $82, $84, $84
        .byte $9D, $9D, $93, $97, $9A, $83, $86, $86, $9E, $9E, $94, $87, $9B, $84, $87, $87
        .byte $9F, $9F

; --- $8B0B  The office wall, and the curtains.
office_stripes:
        .byte $35, $84, $DD, $DD, $DE, $DD, $DD, $DD, $DE, $DD, $DD, $DD, $DE, $DD, $DD, $DD
        .byte $DE, $DD, $DD, $DD, $DE, $DD, $DD, $DD, $DE, $DD, $DD, $DD, $DE, $DD, $DD, $DD
        .byte $DE, $DD

; --- $8B2D  PUSH START, and the Tecmo license.
push_start:
        .byte $5B, $66, $1B, $1B, $1B, $1B, $1B, $1B, $1B, $A6, $A7, $A8, $A9, $1B, $1B, $1B
        .byte $1B, $1B, $1B, $1B, $A0, $A1, $A2, $A3, $A4, $A5, $1B, $AA, $AB, $AC, $AD, $1B
        .byte $AE, $AF, $B0, $B1, $B2, $B3

; --- $8B53  PUSH START, and the Tecmo license. No script draws this.
push_start_spare:
        .byte $5B, $64, $1B, $A6, $A7, $A8, $A9, $1B, $A0, $A1, $A2, $A3, $A4, $A5, $1B, $AA
        .byte $AB, $AC, $AD, $1B, $AE, $AF, $B0, $B1, $B2, $B3

; --- $8B6D  THE END.
the_end:
        .byte $5B, $21, $B7, $B8

; --- $8B71  Where a picture's tiles and colors are.
; Three sets. Tiles, then colors.
picture_parts:
        .word tiles_1
        .word tiles_2
        .word tiles_3
        .word colors_1
        .word colors_2
        .word colors_3

; --- $8B7D  Tiles for the first set.
tiles_1:
        .byte $00, $02, $04, $00, $01, $03, $05, $03, $06, $10, $06, $10, $10, $07, $10, $10
        .byte $11, $12, $07, $12, $07, $11, $12, $11, $13, $14, $11, $15, $16, $11, $17, $1E
        .byte $13, $14, $11, $15, $14, $13, $14, $1E, $14, $17, $14, $17, $1A, $1C, $1A, $1C
        .byte $F8, $F8, $F8, $F8, $F8, $F8, $F8, $F8, $08, $08, $FA, $FA, $0A, $0C, $0C, $0E
        .byte $0E, $0E, $F8, $F8, $F8, $F8, $F8, $F8, $09, $0A, $0E, $18, $F8, $F8, $F8, $F8
        .byte $FA, $FA, $FA, $0C, $0C, $0E, $0A, $0E, $FA, $0C, $0E, $0E, $0A, $0E, $18, $F8
        .byte $F8, $F8, $0B, $F8, $0B, $08, $FA, $0D, $F8, $F8, $F8, $F8, $0B, $08, $0E, $18
        .byte $F8, $F8, $09, $0A, $F8, $F8, $F8, $09, $FA, $FA, $0D, $08, $0C, $0E, $0A, $0C
        .byte $0B, $F8, $F8, $F8, $FA, $0D, $0B, $08, $F8, $F8, $F8, $F8, $F8, $F8, $0B, $08
        .byte $F8, $F8, $F8, $F8, $08, $0C, $0E, $18, $20, $22, $24, $26, $21, $23, $25, $27
        .byte $33, $35, $37, $0B, $FC, $FC, $34, $36, $28, $FC, $FC, $FC, $29, $FC, $FC, $FC
        .byte $FC, $FC, $FC, $3A, $FC, $FC, $FC, $3B, $3F, $FC, $FC, $FC, $32, $FC, $FC, $FC
        .byte $FC, $FC, $FC, $3C, $FC, $FC, $FC, $3E, $19, $1B, $FC, $FC, $0F, $F8, $1D, $1F
        .byte $FC, $FC, $3D, $F8, $40, $42, $F8, $F8, $00, $02, $04, $06, $01, $03, $05, $07
        .byte $08, $0A, $0C, $0E, $09, $0B, $0D, $0F, $10, $12, $F8, $F8, $11, $13, $F8, $F8
        .byte $FA, $1A, $F8, $F8, $FA, $1B, $F8, $F8, $20, $22, $24, $26, $F8, $23, $25, $27
        .byte $00, $FC, $FC, $FC, $01, $FC, $02, $04, $03, $FE, $FE, $FE, $08, $0A, $0C, $FE
        .byte $FE, $FE, $FE, $FE, $FE, $09, $0B, $0D, $FA, $FA, $FA, $06, $FA, $FA, $FA, $05
        .byte $0E, $FC, $10, $12, $0F, $FC, $FC, $FC, $07, $11, $13, $FC, $FC, $FC, $FC, $FC
        .byte $18, $1A, $20, $22, $19, $1B, $21, $FC, $24, $26, $30, $32, $25, $27, $31, $33
        .byte $01, $14, $16, $1C, $FC, $15, $17, $1D, $1E, $1F, $28, $2A, $34, $36, $29, $2B
        .byte $2C, $2E, $23, $38, $2D, $2F, $FC, $FC, $38, $3A, $3C, $05, $39, $3B, $3D, $FA
        .byte $40, $42, $44, $46, $41, $43, $45, $47, $35, $37, $48, $4A, $FE, $3E, $49, $4B
        .byte $4C, $4E, $FC, $FC, $4D, $4F, $3F, $FC, $50, $52, $54, $56, $51, $53, $55, $57
        .byte $01, $14, $58, $5A, $FC, $15, $FC, $5B, $59, $1F, $28, $2A, $5C, $5E, $60, $62
        .byte $2C, $2E, $23, $64, $61, $63, $F8, $F8, $68, $6A, $3C, $05, $69, $6B, $3D, $FA
        .byte $40, $42, $65, $67, $41, $43, $45, $47, $5D, $5F, $6C, $6E, $FE, $66, $49, $4B
        .byte $6D, $6F, $F8, $F8, $4D, $4F, $70, $FC, $72, $52, $54, $56, $51, $53, $55, $57
        .byte $01, $14, $74, $76, $FC, $15, $FC, $77, $71, $1F, $28, $2A, $78, $7A, $7C, $7E
        .byte $2C, $2E, $23, $73, $86, $90, $F8, $F8, $80, $82, $3C, $05, $81, $6B, $3D, $FA
        .byte $83, $85, $87, $4A, $FE, $75, $49, $4B, $4C, $84, $F8, $F8, $4D, $4F, $3F, $FC
        .byte $91, $52, $54, $56, $51, $53, $55, $57, $F8, $F8, $2C, $2E, $F8, $F8, $2D, $2F
        .byte $92, $94, $96, $2A, $88, $8A, $93, $95, $2C, $8C, $8E, $98, $8D, $8F, $F8, $F8
        .byte $89, $8B, $48, $4A, $FE, $97, $49, $4B, $99, $9B, $F8, $F8, $4D, $4F, $9A, $FC
        .byte $30, $FA, $34, $36, $31, $FA, $35, $37, $38, $3A, $FA, $3E, $FA, $3B, $FA, $3F
        .byte $14, $16, $1C, $1E, $F8, $17, $1D, $1F, $F8, $F8, $45, $47, $F8, $F8, $F8, $F8
        .byte $28, $2A, $40, $42, $29, $2B, $41, $FA, $48, $4A, $15, $21, $49, $4B, $FA, $FA
        .byte $44, $46, $FA, $18, $43, $FA, $FA, $19, $39, $FA, $32, $3C, $FA, $FA, $33, $3D
        .byte $F8, $F8, $02, $04, $F8, $00, $03, $05, $F8, $01, $08, $0A, $F8, $F8, $09, $F8
        .byte $F8, $F8, $F8, $F8, $F8, $F8, $F8, $0B, $06, $F8, $F8, $10, $07, $11, $F8, $12
        .byte $0C, $0E, $18, $13, $0D, $0F, $FE, $19, $1A, $1C, $14, $F8, $1B, $1D, $F8, $F8
        .byte $FA, $FA, $FA, $FA, $FA, $FA, $FA, $FA, $FA, $FA, $FA, $09, $07, $FA, $FA, $03
        .byte $FA, $FA, $FA, $11, $1E, $48, $1E, $48, $28, $2A, $2C, $2E, $29, $2B, $2D, $2F
        .byte $FA, $82, $84, $86, $81, $83, $85, $87, $20, $F8, $F8, $22, $21, $F8, $25, $23
        .byte $14, $40, $42, $F8, $16, $FE, $44, $F8, $90, $92, $94, $96, $91, $93, $95, $97
        .byte $88, $8A, $8C, $FA, $89, $8B, $8D, $80, $47, $8E, $F8, $98, $F8, $8F, $F8, $99
        .byte $F8, $9A, $55, $9C, $F8, $9B, $FE, $9D, $FA, $FA, $FA, $07, $5F, $FA, $09, $FA
        .byte $5C, $FA, $FA, $FA, $1E, $48, $1E, $1E, $FA, $0D, $08, $FA, $FA, $0C, $0C, $0E
        .byte $F8, $00, $02, $04, $F8, $01, $03, $05, $F8, $0A, $0C, $0E, $09, $0B, $0D, $0F
        .byte $20, $22, $F8, $26, $F8, $F8, $F8, $27, $F8, $F8, $21, $24, $F8, $F8, $23, $25
        .byte $06, $10, $12, $F8, $07, $11, $13, $15, $18, $1A, $1C, $1E, $19, $1B, $1D, $1F
        .byte $30, $32, $34, $F8, $31, $33, $35, $37, $28, $2A, $2C, $2E, $29, $2B, $2D, $2F
        .byte $38, $F8, $F8, $F8, $39, $3B, $F8, $F8, $3A, $3C, $3E, $F8, $F8, $F8, $3D, $3F
        .byte $F8, $F8, $F8, $F8, $F8, $F8, $F8, $14, $F8, $F8, $F8, $14, $F8, $F8, $F8, $14
        .byte $F8, $F8, $F8, $F8, $16, $40, $42, $44, $FA, $40, $43, $45, $17, $40, $4A, $4C
        .byte $F8, $F8, $F8, $F8, $46, $50, $52, $54, $47, $51, $53, $55, $4E, $58, $5A, $5C
        .byte $F8, $F8, $F8, $F8, $56, $49, $4B, $4D, $57, $60, $62, $64, $5E, $61, $63, $65
        .byte $F8, $F8, $F8, $F8, $4F, $F8, $F8, $F8, $66, $F8, $F8, $F8, $67, $F8, $F8, $F8
        .byte $F8, $F8, $04, $06, $F8, $F8, $05, $07, $A0, $A0, $A4, $A6, $A1, $A3, $A5, $A7
        .byte $A4, $B0, $B2, $A6, $A5, $B1, $B3, $A7, $F8, $F8, $A8, $AA, $F8, $F8, $A9, $AB
        .byte $FC, $EC, $FE, $EE, $F0, $ED, $FE, $EF, $28, $2A, $2C, $2E, $F8, $2B, $2D, $2F
        .byte $F8, $F8, $29, $80, $F8, $F8, $F8, $81, $82, $84, $86, $90, $83, $85, $F8, $91
        .byte $88, $8A, $8C, $8E, $F8, $F8, $8D, $8F, $A0, $A2, $FA, $8B, $A1, $A3, $89, $FA
        .byte $A8, $AA, $AC, $F8, $A9, $AB, $AD, $F8, $38, $3A, $3C, $F8, $39, $3B, $3D, $F8
        .byte $92, $94, $96, $F8, $93, $95, $97, $F8, $FA, $FA, $A4, $A6, $89, $FA, $A5, $A7
        .byte $F8, $89, $FA, $FA, $F8, $F8, $89, $FA, $F8, $F8, $F8, $87, $F8, $F8, $F8, $F8
        .byte $FA, $FA, $FA, $FA, $FA, $8B, $FA, $3E, $FA, $3F, $6A, $6C, $69, $68, $6B, $6D
        .byte $C0, $C2, $C4, $6E, $C1, $C3, $C5, $F8, $8B, $FA, $FA, $78, $FA, $FA, $FA, $79
        .byte $FA, $FA, $7C, $7E, $6F, $7D, $7F, $F8, $C6, $D0, $D2, $D4, $C7, $D1, $D3, $D5
        .byte $F8, $F8, $F8, $F8, $D6, $F8, $F8, $F8, $7A, $7B, $FA, $FA, $F8, $F8, $FA, $FA
        .byte $F8, $F8, $FA, $FA, $F8, $F8, $FA, $FA, $F8, $D7, $FA, $FA, $98, $99, $FA, $8B
        .byte $9A, $9C, $9E, $FA, $9B, $9D, $9F, $FA, $50, $52, $50, $50, $52, $50, $50, $50
        .byte $51, $52, $50, $50, $52, $50, $50, $50, $50, $50, $50, $52, $50, $50, $52, $50
        .byte $50, $50, $50, $53, $50, $50, $52, $50, $F8, $F8, $F8, $F8, $51, $50, $52, $50
        .byte $F8, $F8, $F8, $54, $50, $50, $52, $50, $50, $50, $50, $52, $51, $50, $52, $50
        .byte $56, $55, $51, $50, $52, $57, $4C, $4D, $50, $50, $4E, $F8, $50, $51, $4F, $F8
        .byte $51, $52, $50, $50, $52, $50, $50, $58, $50, $5A, $5B, $F8, $59, $F8, $F8, $F8
        .byte $5C, $5E, $5F, $50, $5D, $F8, $F8, $60, $62, $F8, $F8, $F8, $63, $F8, $F8, $F8
        .byte $50, $64, $66, $F8, $61, $F8, $F8, $65, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE
        .byte $FE, $4E, $5A, $5C, $4E, $58, $5C, $F8, $FE, $FE, $4E, $5A, $FE, $FE, $4E, $58
        .byte $58, $5C, $F8, $F8, $5C, $F8, $F8, $F8, $FE, $4E, $5A, $5C, $FE, $4E, $58, $5C
        .byte $5E, $5D, $5F, $FE, $F8, $5E, $5D, $5F, $5E, $5F, $FE, $FE, $5E, $5D, $5F, $FE
        .byte $FE, $FE, $FE, $FE, $80, $82, $FE, $FE, $F8, $5E, $5F, $FE, $74, $76, $76, $76
        .byte $5E, $77, $F8, $F8, $5E, $77, $5F, $FE, $81, $83, $FE, $FE, $76, $76, $76, $76
        .byte $F8, $F8, $F8, $F8, $FE, $FE, $FE, $FE, $F8, $F8, $F8, $F8, $F8, $F8, $F8, $4F
        .byte $F8, $F8, $F8, $66, $F8, $F8, $67, $FA, $F8, $6A, $6C, $6E, $F8, $6B, $6D, $6F
        .byte $F8, $F8, $F8, $F8, $59, $5B, $F8, $F8, $70, $72, $F8, $F8, $71, $73, $75, $F8
        .byte $78, $7A, $7C, $7E, $79, $7B, $7D, $7F, $F8, $F8, $F8, $F8, $F8, $F8, $F8, $84
        .byte $F8, $F8, $F8, $86, $F8, $F8, $85, $87, $F8, $88, $8A, $8C, $F8, $89, $8B, $8D
        .byte $F8, $F8, $F8, $F8, $90, $91, $F8, $F8, $92, $94, $F8, $F8, $93, $95, $96, $F8
        .byte $8E, $98, $9A, $9C, $8F, $99, $9B, $9D, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
        .byte $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $49, $60, $49, $49, $49, $61
        .byte $49, $49, $49, $62, $49, $49, $49, $63, $49, $49, $49, $FC, $49, $49, $4B, $FC
        .byte $49, $49, $6A, $FC, $49, $49, $FC, $FC, $49, $49, $44, $46, $49, $49, $45, $47
        .byte $68, $49, $4C, $4E, $69, $6B, $4D, $4F, $50, $52, $54, $56, $51, $53, $55, $57
        .byte $58, $5A, $5C, $5E, $59, $5B, $5D, $5F, $FC, $FC, $82, $FC, $FC, $FC, $FC, $FC
        .byte $64, $49, $49, $49, $65, $49, $49, $49, $70, $72, $74, $76, $71, $73, $75, $77
        .byte $78, $7A, $7C, $7E, $79, $7B, $7D, $7F, $66, $80, $6C, $6E, $67, $FC, $6D, $6F
        .byte $FC, $82, $84, $86, $FC, $83, $85, $87, $FC, $FC, $81, $88, $FC, $FC, $5B, $89
        .byte $94, $96, $8C, $8E, $95, $97, $8D, $8F, $FC, $FC, $FC, $FC, $8F, $8A, $8E, $8F
        .byte $FC, $98, $99, $8D, $8A, $FC, $8B, $8A, $90, $92, $94, $96, $91, $93, $95, $97
        .byte $A0, $A2, $A4, $A6, $A1, $A3, $A5, $A7, $A6, $A0, $A4, $A2, $A7, $A5, $A3, $A1
        .byte $B0, $B2, $B4, $B6, $B1, $B3, $B5, $B3, $B0, $B2, $B4, $B6, $B3, $B1, $B3, $B5
        .byte $9A, $B3, $9E, $9C, $9B, $9D, $9F, $B7, $9A, $9C, $B3, $9E, $B7, $9B, $9F, $9D
        .byte $C0, $C2, $C4, $C6, $C1, $C3, $C5, $C7, $33, $35, $37, $F8, $FC, $FC, $D0, $D2
        .byte $F8, $3F, $FC, $FC, $F8, $F8, $1D, $1F, $F8, $F8, $44, $46, $F8, $F8, $45, $47
        .byte $F8, $F8, $52, $54, $F8, $50, $53, $55, $4C, $4E, $58, $5A, $4D, $4F, $59, $5B
        .byte $F8, $5C, $5E, $56, $F8, $5D, $5F, $57, $70, $72, $74, $76, $71, $73, $75, $77
        .byte $64, $51, $6C, $6E, $65, $FA, $6D, $6F, $78, $FA, $7C, $7E, $79, $66, $7D, $7F
        .byte $7A, $FA, $F8, $F8, $7B, $67, $F8, $F8, $80, $82, $F8, $F8, $81, $83, $84, $85
        .byte $86, $FA, $92, $90, $87, $91, $93, $F8, $94, $96, $C0, $F8, $95, $97, $C1, $F8
        .byte $23, $FA, $FA, $FA, $24, $25, $26, $27, $FA, $32, $34, $36, $30, $33, $35, $37
        .byte $FA, $50, $52, $54, $FA, $51, $53, $55, $FA, $FA, $4A, $4C, $FA, $FA, $4B, $4D
        .byte $FA, $FA, $FA, $FA, $56, $57, $FA, $FA, $4E, $58, $5A, $FA, $4F, $59, $5B, $31
        .byte $5C, $5E, $74, $76, $5D, $5F, $75, $77, $60, $62, $64, $66, $61, $63, $65, $FA
        .byte $F8, $28, $2A, $2C, $F8, $29, $2B, $2D, $F8, $80, $F8, $F8, $F8, $81, $F8, $F8
        .byte $F8, $F8, $A8, $AA, $F8, $F8, $8B, $8D, $F8, $F8, $A2, $A4, $88, $89, $A3, $A5
        .byte $2E, $38, $3A, $F8, $2F, $39, $3B, $3D, $86, $F8, $92, $94, $87, $F8, $93, $95
        .byte $A9, $AB, $9A, $F8, $8F, $99, $F7, $9D, $A6, $B0, $FE, $F8, $A7, $B1, $FE, $F8
        .byte $F8, $F8, $F8, $F8, $F8, $67, $70, $71, $72, $F6, $3E, $68, $73, $9C, $3F, $FC
        .byte $FA, $6A, $6C, $6E, $69, $6B, $6D, $6F, $78, $7A, $7C, $7E, $79, $7B, $7D, $7F
        .byte $96, $F8, $F8, $F8, $97, $F8, $F8, $F8, $C0, $F8, $F8, $F8, $C1, $F8, $F8, $F8
        .byte $FA, $C4, $C6, $F8, $C3, $C5, $C7, $C2, $F8, $88, $8A, $8C, $F8, $89, $8B, $FA
        .byte $F8, $A0, $FE, $A4, $F8, $A1, $8D, $A5, $F8, $F8, $A8, $AA, $F8, $F8, $A9, $AB
        .byte $F8, $F8, $F8, $A2, $F8, $F8, $F8, $A3, $AC, $FA, $FA, $FA, $AD, $FA, $FA, $FA
        .byte $8E, $98, $9A, $FA, $8F, $99, $9B, $FA, $A6, $F8, $F8, $F8, $A7, $F8, $F8, $F8
        .byte $FA, $F8, $F8, $F8, $FA, $F8, $F8, $F8, $AE, $F8, $F8, $F8, $AF, $F8, $F8, $F8
        .byte $9C, $F8, $F8, $F8, $9D, $9F, $F8, $F8, $AC, $AE, $F8, $F8, $AD, $AF, $F8, $F8

; --- $937D  Tiles for the second set.
tiles_2:
        .byte $F8, $28, $2A, $2C, $F8, $29, $2B, $2D, $F8, $80, $82, $84, $F8, $81, $83, $85
        .byte $F8, $88, $8A, $8C, $26, $89, $8B, $8D, $27, $A0, $A2, $A4, $F8, $F8, $F8, $A5
        .byte $2E, $38, $F8, $F8, $2F, $39, $3B, $F8, $86, $90, $92, $F8, $87, $91, $93, $F8
        .byte $8E, $98, $9A, $F8, $8F, $99, $9B, $30, $A6, $B0, $B2, $31, $A7, $B1, $B3, $F8
        .byte $F8, $F8, $FA, $02, $F8, $F8, $01, $03, $F8, $F8, $08, $0A, $F8, $F8, $09, $0B
        .byte $F8, $F8, $20, $22, $F8, $F8, $21, $23, $F8, $F8, $28, $2A, $F8, $F8, $FA, $2B
        .byte $04, $06, $FA, $FA, $05, $07, $FA, $FA, $0C, $0E, $18, $1A, $0D, $0F, $19, $1B
        .byte $24, $26, $30, $32, $25, $27, $31, $33, $2C, $2E, $FA, $FA, $2D, $2F, $FA, $FA
        .byte $FA, $FA, $FA, $FA, $FA, $FA, $FA, $FA, $14, $16, $40, $42, $15, $17, $41, $43
        .byte $1C, $1E, $48, $4A, $1D, $1F, $49, $4B, $FA, $FA, $F8, $F8, $FA, $FA, $F8, $F8
        .byte $10, $10, $F8, $F8, $11, $13, $F8, $F8, $1C, $00, $F8, $F8, $49, $4B, $F8, $F8
        .byte $FA, $FA, $80, $82, $FA, $FA, $81, $83, $FA, $FA, $88, $8A, $FA, $FA, $89, $8B
        .byte $FA, $FA, $A0, $A2, $FA, $FA, $A1, $A3, $FA, $FA, $A8, $AA, $FA, $FA, $A9, $AB
        .byte $84, $FA, $FA, $FA, $85, $87, $FA, $FA, $8C, $8E, $FA, $FA, $8D, $8F, $86, $FA
        .byte $A4, $A6, $B0, $B2, $A5, $A7, $B1, $B3, $AC, $AE, $B8, $BA, $AD, $AF, $B9, $BB
        .byte $3C, $3E, $68, $6A, $FC, $3F, $69, $6B, $94, $96, $C0, $C2, $FC, $97, $C1, $C3
        .byte $FC, $9E, $FE, $FE, $95, $FE, $FE, $3A, $9C, $FE, $FA, $F8, $9D, $9F, $FA, $F8
        .byte $6C, $6E, $78, $7A, $6D, $6F, $79, $7B, $C4, $C6, $D0, $D2, $C5, $F8, $D1, $F8
        .byte $C7, $F8, $F8, $F8, $3D, $D3, $F8, $F8, $F8, $F8, $F8, $F8, $F8, $F8, $F8, $F8
        .byte $F8, $F8, $F8, $F8, $54, $56, $55, $57, $5C, $5E, $5C, $5D, $5F, $F7, $5F, $F7
        .byte $00, $02, $04, $06, $01, $F8, $05, $F8, $08, $F8, $0C, $0E, $F8, $F8, $0D, $0F
        .byte $F8, $F8, $24, $26, $F8, $F8, $F8, $27, $F8, $F8, $F8, $0A, $F8, $F8, $F8, $0B
        .byte $10, $12, $F8, $F8, $F8, $13, $15, $17, $18, $1A, $1C, $F8, $19, $1B, $1D, $1F
        .byte $30, $32, $34, $36, $31, $33, $35, $37, $38, $3A, $3C, $3E, $39, $3B, $3D, $3F
        .byte $F8, $F8, $F8, $46, $41, $43, $45, $F8, $F8, $4A, $4C, $4E, $49, $4B, $4D, $4F
        .byte $60, $62, $64, $66, $61, $63, $65, $67, $68, $6A, $6C, $6E, $69, $6B, $6D, $6F
        .byte $50, $52, $54, $56, $51, $53, $F8, $57, $58, $5A, $F8, $5E, $59, $5B, $F8, $F8
        .byte $70, $72, $F8, $F8, $71, $73, $F8, $F8, $78, $F8, $F8, $F8, $79, $F8, $F8, $F8
        .byte $68, $FC, $6A, $92, $69, $FC, $FC, $93, $94, $96, $F8, $F8, $95, $97, $F8, $F8
        .byte $F8, $88, $FC, $8A, $F8, $89, $6B, $8B, $8C, $8E, $F8, $F8, $8D, $8F, $F8, $F8
        .byte $F8, $44, $46, $50, $F8, $45, $47, $51, $F8, $4C, $4E, $58, $F8, $4D, $4F, $59
        .byte $52, $54, $56, $64, $53, $55, $57, $65, $5A, $5C, $5E, $6C, $5B, $5D, $5F, $6D
        .byte $F8, $76, $FC, $FC, $F8, $F8, $F8, $F8, $FC, $FC, $72, $74, $F8, $F8, $73, $75
        .byte $F8, $78, $7A, $7C, $F8, $79, $7B, $7D, $66, $F8, $F8, $F8, $67, $F8, $F8, $F8
        .byte $6E, $F8, $F8, $F8, $6F, $F8, $F8, $F8, $FA, $F8, $F8, $F8, $77, $B4, $F8, $F8
        .byte $7E, $3E, $68, $6A, $7F, $3F, $69, $6B, $94, $96, $F8, $F8, $95, $97, $9C, $9E
        .byte $F8, $F8, $F8, $F8, $9D, $9F, $F8, $F8, $F8, $F8, $F8, $9A, $F8, $F8, $99, $9B
        .byte $F8, $9C, $9E, $9E, $F8, $9D, $9F, $FC, $F8, $A0, $A2, $A4, $A1, $A3, $A5, $A2
        .byte $A8, $AA, $AA, $AA, $A9, $AB, $AB, $AB, $F8, $F8, $F8, $F8, $F8, $F8, $A6, $A7
        .byte $F8, $AC, $98, $FA, $AD, $FA, $FA, $FA, $9B, $98, $FA, $FA, $98, $FA, $FA, $FA
        .byte $00, $02, $00, $02, $01, $03, $01, $03, $04, $06, $04, $06, $05, $F8, $05, $F8
        .byte $10, $12, $14, $16, $11, $F8, $15, $17, $F8, $42, $44, $46, $41, $43, $45, $47
        .byte $50, $52, $F8, $F8, $51, $53, $55, $57, $48, $4A, $4C, $4E, $49, $4B, $4D, $4F
        .byte $58, $5A, $5C, $5E, $59, $5B, $5D, $5F, $07, $F8, $F8, $F8, $F8, $F8, $13, $40
        .byte $08, $0A, $0C, $0E, $F8, $0B, $0D, $0F, $F8, $F8, $09, $54, $F8, $F8, $F8, $56
        .byte $60, $62, $64, $F8, $61, $63, $65, $F8, $F8, $72, $74, $76, $F8, $73, $75, $77
        .byte $18, $1A, $1C, $1E, $19, $1B, $1D, $1F, $20, $22, $24, $26, $21, $23, $25, $27
        .byte $F8, $32, $34, $F8, $31, $33, $F8, $F8, $F8, $F8, $F8, $F8, $30, $35, $F8, $F8
        .byte $F8, $F8, $36, $01, $F8, $F8, $37, $00, $F8, $F8, $F8, $05, $F8, $F8, $F8, $F8
        .byte $28, $2A, $2C, $2E, $29, $2B, $2D, $2F, $38, $3A, $3C, $F8, $39, $3B, $3D, $F8
        .byte $F8, $6E, $78, $F8, $F8, $6F, $79, $F8, $F8, $7A, $7C, $F8, $F8, $6F, $79, $F8
        .byte $80, $82, $84, $86, $81, $83, $85, $F8, $88, $8A, $8C, $F8, $89, $FC, $8D, $F8
        .byte $A0, $FC, $F8, $F8, $A1, $A3, $F8, $F8, $F8, $8B, $F8, $F8, $F8, $A2, $F8, $F8
        .byte $F8, $F8, $87, $7E, $F8, $F8, $7D, $7F, $90, $92, $94, $96, $F8, $93, $95, $97
        .byte $F8, $9A, $9C, $9E, $F8, $9B, $9D, $9F, $F8, $F8, $B4, $B6, $F8, $F8, $B5, $B7
        .byte $F8, $F8, $B2, $F8, $F8, $F8, $B3, $F8, $8E, $98, $91, $F8, $8F, $99, $F8, $F8
        .byte $F8, $A4, $A6, $F8, $F8, $A5, $F8, $F8, $A8, $B0, $F8, $F8, $A7, $B1, $F8, $F8
        .byte $B0, $B1, $B2, $FA, $B0, $B1, $B1, $B1, $48, $43, $43, $F8, $F8, $F8, $F8, $F8
        .byte $4A, $43, $F8, $F8, $41, $41, $48, $48, $F8, $F8, $F8, $F8, $48, $48, $41, $41
        .byte $F8, $F8, $F8, $4A, $F8, $F8, $F8, $F8, $F8, $43, $48, $41, $F8, $F8, $F8, $F8
        .byte $41, $41, $41, $41, $F8, $F8, $F8, $F8, $4A, $4A, $4A, $4A, $F8, $F8, $F8, $F8
        .byte $48, $48, $43, $43, $F8, $41, $41, $41, $43, $43, $F8, $F8, $48, $48, $48, $48
        .byte $F8, $43, $48, $48, $F8, $F8, $F8, $F8, $41, $41, $F8, $F8, $F8, $F8, $F8, $F8
        .byte $00, $02, $04, $06, $00, $02, $04, $06, $FA, $10, $12, $14, $FA, $11, $11, $15
        .byte $FA, $12, $12, $10, $FA, $1D, $13, $11, $FA, $14, $10, $12, $FA, $12, $11, $14
        .byte $FA, $10, $12, $12, $FA, $11, $11, $13, $16, $01, $FA, $FA, $17, $13, $FA, $FA
        .byte $12, $13, $FA, $FA, $13, $FA, $FA, $FA, $9E, $9E, $B0, $B0, $A2, $A4, $9E, $9E
        .byte $FA, $03, $FA, $05, $FA, $07, $08, $0A, $0C, $0E, $18, $1A, $09, $FA, $FA, $0F
        .byte $0B, $FA, $FA, $0D, $19, $FA, $FA, $1B, $FA, $FA, $FA, $1C, $FA, $FA, $FA, $FA
        .byte $12, $10, $12, $11, $1D, $11, $1D, $11, $1E, $FA, $10, $12, $1F, $49, $11, $11
        .byte $FA, $20, $12, $12, $FA, $21, $11, $1D, $FA, $40, $22, $10, $48, $41, $FA, $13
        .byte $A3, $FE, $FE, $B3, $AB, $AB, $AB, $AB, $AE, $B8, $BA, $B9, $AF, $FA, $FA, $FA
        .byte $FA, $FA, $FA, $FA, $B1, $B2, $FA, $FA, $B1, $B2, $FA, $BB, $9E, $B0, $B0, $B0
        .byte $B4, $A2, $B4, $A2, $AB, $AB, $AB, $AB, $B9, $BC, $BE, $BF, $FA, $FA, $FA, $BD
        .byte $FA, $FA, $FA, $FA, $FA, $FA, $BB, $B1, $B1, $B1, $B1, $B1, $B0, $B0, $B0, $B0
        .byte $F8, $F8, $F8, $F8, $B5, $B7, $F8, $F8, $FA, $C0, $C2, $F8, $FA, $FA, $FA, $B6
        .byte $FA, $FA, $FA, $9B, $FA, $FA, $9B, $9B, $FA, $FA, $FA, $FA, $B1, $B1, $B1, $9B
        .byte $C1, $B0, $FC, $9E, $9E, $9E, $A4, $A2, $B4, $A2, $C3, $C8, $AB, $AB, $AB, $AB
        .byte $CA, $F8, $F8, $F8, $9B, $E0, $F8, $F8, $FA, $C9, $CB, $F8, $9B, $9B, $E2, $F8
        .byte $9E, $A4, $E1, $F8, $A2, $C3, $C8, $E3, $AA, $AA, $AA, $E8, $AB, $AB, $AB, $E9
        .byte $EF, $C6, $C4, $C6, $C7, $C7, $D0, $C7, $C6, $C4, $C6, $C6, $D1, $D0, $D2, $C7
        .byte $C4, $C4, $EF, $C6, $D1, $C7, $C7, $C7, $C6, $C5, $C4, $C6, $D0, $D4, $D6, $C7
        .byte $C7, $D1, $C7, $D1, $D3, $D5, $D5, $D3, $C7, $D1, $C7, $D1, $D5, $D5, $D3, $D5
        .byte $C7, $D7, $CC, $CE, $D8, $DA, $DC, $DE, $CD, $CF, $C7, $D1, $E4, $E6, $E5, $E7
        .byte $EA, $EC, $D5, $D8, $EE, $EE, $FA, $FA, $D8, $EB, $ED, $ED, $FA, $EE, $FA, $ED
        .byte $EC, $D5, $D8, $ED, $EE, $EE, $FA, $FA, $D8, $D8, $EB, $DA, $FA, $FA, $FA, $FA
        .byte $D4, $D6, $D6, $D6, $D4, $D6, $D6, $D6, $D7, $D3, $D3, $D3, $D4, $D6, $D5, $D6
        .byte $D4, $D6, $D4, $D6, $D4, $D6, $D4, $D6, $D6, $D4, $D6, $FA, $D6, $D4, $D6, $FA
        .byte $D3, $D1, $D3, $FA, $D6, $D6, $D6, $FA, $D6, $D6, $D6, $FA, $D6, $D6, $D6, $FA
        .byte $D7, $D3, $D3, $D3, $D4, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
        .byte $FA, $FA, $FA, $FA, $C8, $FC, $FC, $FC, $FC, $FC, $C8, $FC, $FC, $FC, $CA, $CC
        .byte $C8, $FC, $CE, $D8, $FC, $FC, $DA, $DC, $FC, $FC, $FC, $FC, $C8, $FC, $C8, $FC
        .byte $FA, $FA, $FA, $FA, $FC, $FC, $FC, $C8, $FC, $C8, $FC, $FC, $CC, $CC, $FC, $FC
        .byte $D8, $D8, $FC, $C8, $DC, $DC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $C8, $FC, $C8
        .byte $D3, $D3, $D3, $D3, $D5, $D6, $D6, $D6, $D1, $D3, $D3, $D3, $D6, $D6, $D6, $D6
        .byte $D3, $D3, $D3, $D3, $D6, $D6, $D5, $D6, $FA, $FA, $FA, $FA, $FA, $C8, $C9, $CB
        .byte $FA, $FC, $FC, $DE, $FA, $FC, $CD, $CF, $FA, $C8, $D9, $DB, $FA, $FC, $DD, $DF
        .byte $FA, $FC, $FC, $DE, $FA, $C8, $C8, $DE, $FA, $FA, $FA, $FA, $F8, $F8, $F8, $F8
        .byte $D6, $D6, $D4, $D6, $D6, $D6, $D4, $D6, $D3, $D3, $D1, $D3, $D5, $D6, $D6, $D6
        .byte $F8, $F8, $F8, $F8, $F8, $F8, $F8, $12, $F8, $F8, $29, $B5, $F8, $F8, $F8, $BC
        .byte $F8, $B6, $E0, $E2, $F8, $B7, $FA, $E3, $F8, $BE, $E8, $FA, $F8, $BF, $E9, $FA
        .byte $F8, $F8, $F8, $F8, $BD, $F8, $F8, $F8, $FA, $E1, $F8, $F8, $E4, $F8, $F8, $F8
        .byte $E6, $F0, $F1, $F8, $E7, $FA, $E5, $F8, $FA, $FA, $EA, $F8, $FA, $FA, $FA, $F8
        .byte $F8, $F8, $29, $B5, $F8, $F8, $F8, $EB, $F8, $F2, $FA, $FA, $F8, $FA, $FA, $FA
        .byte $FA, $E1, $F8, $F8, $F3, $F8, $F8, $F8, $F8, $F8, $29, $B5, $F8, $F8, $F8, $F4
        .byte $FA, $E1, $F8, $F8, $F5, $F8, $F8, $F8, $FA, $FA, $FA, $D9, $FA, $FA, $FA, $F0
        .byte $FA, $FA, $FA, $DB, $FA, $FA, $FA, $F2, $FA, $FA, $D9, $F8, $FA, $FA, $F0, $F8
        .byte $FA, $FA, $DB, $F8, $FA, $FA, $F2, $F8, $F8, $F8, $F8, $F8, $F1, $FA, $FA, $FA
        .byte $DD, $FA, $FA, $FA, $F4, $FA, $FA, $FA, $DF, $FA, $FA, $FA, $F6, $FA, $FA, $FA
        .byte $F8, $DD, $FA, $FA, $F8, $F4, $FA, $FA, $F8, $DF, $FA, $FA, $F5, $F6, $FA, $FA
        .byte $F8, $F8, $F8, $F8, $FA, $FA, $FA, $F3, $79, $7B, $79, $7B, $7B, $79, $7B, $79
        .byte $7D, $F8, $7F, $7B, $7D, $F8, $7F, $79, $D0, $D2, $D4, $D4, $FC, $D3, $D5, $D5
        .byte $D4, $D4, $D6, $7B, $D5, $D5, $D7, $D0, $79, $7B, $FA, $FA, $F6, $FA, $FA, $FA
        .byte $FA, $FA, $FA, $7B, $FA, $FA, $FA, $D1, $79, $7B, $79, $7B, $D8, $79, $7B, $79
        .byte $79, $FC, $DA, $DC, $7B, $FC, $DB, $DD, $79, $FC, $DA, $DC, $7B, $FC, $D9, $FC
        .byte $79, $FC, $D9, $FC, $7B, $FC, $DB, $DD, $DC, $DC, $DC, $DC, $DE, $DD, $DD, $DD
        .byte $DC, $DC, $DC, $DC, $FC, $FC, $FC, $FC, $FC, $FC, $DF, $DF, $DE, $DD, $DD, $DD
        .byte $7C, $F8, $F8, $F8, $7D, $F4, $F8, $F8, $D4, $D6, $DC, $DE, $D5, $D7, $DD, $DF
        .byte $F8, $F8, $F8, $F8, $7C, $F6, $F8, $F8, $7D, $D6, $DC, $7C, $D5, $D7, $DD, $F5
        .byte $F8, $F8, $F8, $F8, $F8, $F8, $F8, $DE, $F6, $F8, $F7, $7D, $D8, $DA, $DB, $DF
        .byte $F8, $F8, $F8, $C8, $F8, $F8, $F8, $C9, $F8, $F8, $F8, $E0, $F8, $F8, $F8, $E1
        .byte $F8, $F8, $F8, $E8, $F8, $F8, $F8, $E9, $F6, $F8, $F8, $F8, $D8, $DA, $DA, $7C
        .byte $CA, $CC, $CE, $D9, $CB, $CD, $FE, $FE, $E2, $E4, $E6, $FE, $E3, $E5, $E7, $AB
        .byte $FC, $EC, $FE, $EE, $EB, $ED, $FE, $EF, $B8, $BA, $BC, $BE, $B9, $BB, $BD, $BF
        .byte $A8, $AA, $AC, $F8, $A9, $FA, $AD, $F8, $AE, $FA, $FA, $F8, $AF, $FA, $75, $F8
        .byte $B4, $FA, $B6, $F8, $B5, $FA, $B7, $F8, $A1, $A3, $F8, $F8, $CF, $EA, $7C, $F6
        .byte $F8, $F8, $F8, $F8, $F0, $F2, $F4, $F1, $F8, $F8, $F8, $F8, $F3, $F5, $EC, $EE
        .byte $AC, $AE, $B8, $BA, $AD, $AF, $B9, $BB, $BC, $BE, $E8, $EA, $BD, $BF, $E9, $AD

; --- $9B7D  Tiles for the third set.
tiles_3:
        .byte $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $76, $70
        .byte $71, $73, $75, $77, $72, $74, $FE, $FE, $FE, $FE, $FE, $FE, $72, $74, $FE, $FE
        .byte $FE, $FE, $FE, $FE, $75, $77, $76, $70, $FE, $FE, $FE, $FE, $FE, $FE, $68, $6A
        .byte $6C, $6E, $78, $7A, $6D, $6F, $79, $7B, $FE, $67, $6A, $FE, $69, $6B, $7A, $7D
        .byte $80, $82, $7C, $7E, $81, $83, $79, $7F, $84, $68, $6A, $FE, $85, $87, $89, $86
        .byte $F8, $88, $8A, $F8, $F8, $F8, $F8, $F8, $F8, $F8, $F8, $8C, $F8, $F8, $F8, $8D
        .byte $F8, $F8, $F8, $8E, $F8, $F8, $F8, $8F, $90, $92, $90, $94, $FE, $91, $93, $95
        .byte $FE, $98, $9A, $9C, $FE, $99, $FE, $FE, $96, $9E, $9B, $F8, $97, $9F, $9D, $F8
        .byte $A0, $A2, $A4, $A6, $A1, $A3, $A5, $A7, $B0, $B2, $90, $92, $B1, $FE, $91, $93
        .byte $B3, $FE, $98, $9A, $B4, $FE, $99, $FE, $F8, $F8, $F8, $F8, $F8, $F8, $B5, $B7
        .byte $F8, $A8, $AA, $AC, $F8, $A9, $AB, $AD, $B6, $AE, $B8, $BA, $FE, $AF, $B9, $BB
        .byte $FE, $C0, $BC, $BE, $FE, $FE, $BD, $BF, $F8, $F8, $F8, $F8, $C1, $C3, $F8, $F8
        .byte $C4, $C6, $E8, $F8, $C5, $C7, $C2, $F8, $C8, $CA, $CC, $CE, $C9, $CB, $CD, $CF
        .byte $E0, $E2, $E4, $E6, $E1, $E3, $E5, $E7, $F8, $F8, $F8, $F8, $F8, $F8, $F8, $F8
        .byte $F8, $F8, $F8, $F8, $F8, $F8, $F8, $97, $F8, $F8, $F8, $9E, $F8, $F8, $F8, $9F
        .byte $F8, $F8, $F8, $B2, $F8, $F8, $F8, $B3, $A8, $AA, $AC, $AE, $A9, $AB, $FA, $AF
        .byte $F8, $F8, $F8, $F8, $B8, $BA, $B9, $BB, $B4, $B6, $FA, $E2, $B5, $B7, $E1, $E3
        .byte $BC, $BE, $E8, $EA, $BD, $BF, $E9, $EB, $D0, $D2, $D4, $FA, $D1, $D3, $D5, $E0
        .byte $D8, $DA, $D6, $F8, $D9, $DB, $D7, $AD, $F8, $F8, $76, $FA, $F8, $F8, $77, $FA
        .byte $F8, $F8, $15, $34, $F8, $F8, $F8, $35, $F8, $F8, $F8, $36, $F8, $F8, $F8, $37
        .byte $60, $3E, $68, $6A, $61, $3F, $69, $6B, $C0, $FC, $FC, $C2, $C1, $FC, $FC, $C3
        .byte $D0, $D2, $D4, $D6, $D1, $D3, $D5, $D7, $C4, $C6, $FC, $FC, $C5, $C7, $FC, $FC
        .byte $FC, $FC, $B4, $B6, $9E, $9F, $B5, $B7, $CA, $FC, $FC, $C8, $FC, $FC, $FC, $C9
        .byte $FC, $CE, $FC, $CC, $CB, $FC, $FC, $CD, $FC, $CF, $D8, $DA, $FC, $FC, $D9, $F8
        .byte $DC, $F8, $F8, $F8, $DD, $F8, $F8, $F8, $DE, $F8, $F8, $F8, $DF, $F8, $F8, $F8
        .byte $DB, $F8, $F8, $F8, $F8, $F8, $F8, $F8, $D0, $D1, $D0, $D1, $D1, $D0, $D1, $D0
        .byte $D0, $D1, $D0, $D1, $D1, $D0, $D1, $E9, $D0, $D1, $D0, $EA, $D1, $D0, $D1, $D0
        .byte $D0, $D1, $EB, $EC, $D1, $D0, $EE, $ED, $D0, $EF, $D3, $F8, $D2, $EC, $F8, $F8
        .byte $EE, $ED, $F8, $F8, $D3, $F8, $F8, $F8, $D4, $F8, $F8, $F8, $D5, $D4, $F8, $F8
        .byte $D6, $D7, $D8, $DA, $F8, $D6, $D7, $D8, $F8, $F8, $D6, $DC, $F8, $F8, $F8, $DE
        .byte $F8, $F8, $F8, $D9, $F8, $F8, $F8, $F8, $F8, $F8, $F8, $F0, $F8, $F8, $F8, $F1
        .byte $DB, $D1, $D0, $D1, $DA, $DB, $D1, $D0, $D8, $DA, $DB, $D1, $F8, $DF, $DD, $D0
        .byte $F2, $F4, $D0, $D1, $F3, $F5, $D1, $D0, $F6, $D1, $D0, $D1, $DD, $D0, $D1, $D0
        .byte $F8, $F8, $F8, $F8, $F8, $F8, $F8, $A8, $F8, $F8, $F8, $AA, $F8, $F8, $A9, $AB
        .byte $F8, $AC, $AE, $B8, $F8, $AD, $AF, $FE, $F8, $BA, $FE, $FE, $B9, $BB, $FE, $FE
        .byte $F8, $F8, $F8, $F8, $BD, $BF, $F8, $F8, $BE, $E8, $BE, $E8, $BD, $B1, $BD, $B1
        .byte $BC, $BE, $E2, $F8, $E0, $F8, $E3, $E1, $E4, $F8, $F0, $F2, $E5, $E7, $F1, $F3
        .byte $E8, $EA, $EC, $EE, $E9, $EB, $ED, $EF, $B0, $B2, $B1, $B6, $B1, $B3, $B5, $B7
        .byte $B1, $B6, $E0, $E2, $B4, $B7, $E1, $E3, $B8, $BA, $B4, $BC, $B9, $BB, $BD, $B4
        .byte $B8, $BA, $BE, $E8, $B9, $BB, $BD, $B1, $E0, $EA, $B4, $BC, $E1, $EB, $BD, $B4
        .byte $BF, $E9, $BE, $E8, $EB, $9E, $BD, $B1, $B8, $BA, $B1, $B6, $B9, $BB, $B4, $B7
        .byte $BE, $E8, $B1, $B6, $BD, $B1, $B5, $B7, $FA, $FA, $FA, $FA, $FA, $FA, $07, $FA
        .byte $FA, $07, $FA, $FA, $09, $FA, $FA, $FA, $FA, $FA, $FA, $FA, $FA, $FA, $FA, $FA
        .byte $FA, $FA, $FA, $FA, $1E, $48, $1E, $48, $FA, $FA, $FA, $FA, $1E, $48, $1E, $1E
        .byte $F8, $28, $2A, $2C, $F8, $29, $2B, $2D, $F8, $80, $82, $84, $F8, $81, $83, $85
        .byte $F8, $88, $8A, $8C, $26, $89, $8B, $8D, $27, $A0, $A2, $A4, $F8, $F8, $F8, $A5
        .byte $2E, $38, $F8, $F8, $2F, $39, $3B, $F8, $86, $90, $92, $F8, $87, $91, $93, $F8
        .byte $8E, $98, $9A, $F8, $8F, $99, $9B, $30, $A6, $B0, $B2, $31, $A7, $B1, $B3, $F8
        .byte $F8, $F8, $F8, $FA, $F8, $F8, $F8, $FA, $00, $FA, $04, $06, $01, $FA, $04, $06
        .byte $FA, $FA, $04, $06, $FA, $FA, $04, $06, $20, $FA, $04, $06, $21, $FA, $04, $06
        .byte $10, $12, $14, $16, $10, $13, $15, $16, $10, $FA, $FA, $16, $10, $FA, $FA, $1F
        .byte $10, $32, $FA, $36, $10, $33, $FA, $37, $F8, $14, $44, $46, $F8, $14, $44, $47
        .byte $F8, $14, $44, $15, $49, $14, $4D, $FA, $60, $62, $64, $FA, $61, $63, $65, $FA
        .byte $FA, $52, $28, $2A, $FA, $53, $29, $2B, $FA, $5A, $80, $82, $59, $5B, $81, $83
        .byte $FA, $72, $88, $8A, $71, $73, $89, $8B, $09, $00, $01, $FF, $00, $00, $0E, $C0
        .byte $2C, $2E, $38, $F8, $2D, $2F, $39, $3B, $84, $86, $90, $92, $85, $87, $91, $93
        .byte $F8, $8E, $98, $9A, $8D, $8F, $99, $9B, $3C, $3E, $68, $6A, $3D, $3F, $69, $6B
        .byte $94, $96, $C0, $C2, $95, $97, $C1, $C3, $9C, $9E, $C8, $CA, $9D, $9F, $C9, $CB
        .byte $6C, $6E, $6F, $F8, $6D, $F8, $F8, $F8, $C4, $F8, $F8, $F8, $C5, $F8, $F8, $F8
        .byte $CC, $CE, $F8, $F8, $CD, $F8, $F8, $F8, $00, $01, $08, $13, $F8, $F8, $F8, $F8
        .byte $C4, $C6, $F8, $F8, $FE, $C7, $F8, $F8, $CC, $CE, $6D, $F8, $CD, $CF, $F8, $F8
        .byte $F8, $F8, $F8, $C5, $F8, $F8, $F8, $F8, $78, $7A, $7C, $7E, $79, $7B, $7D, $7F
        .byte $D0, $D2, $D4, $D6, $D1, $D3, $D5, $D7, $02, $01, $05, $02, $06, $04, $02, $19
        .byte $04, $07, $06, $0C, $04, $06, $06, $00, $05, $10, $03, $11, $02, $06, $09, $19
        .byte $06, $06, $04, $02, $03, $06, $06, $19, $FC, $FC, $FC, $FC, $FC, $5E, $5B, $5B
        .byte $55, $55, $FC, $FC, $5E, $5B, $FC, $FC, $FC, $FC, $55, $55, $5B, $5B, $5E, $5B
        .byte $55, $55, $35, $FC, $5E, $5B, $5B, $FC, $FC, $FC, $FC, $FC, $5B, $5B, $FC, $FC
        .byte $0A, $34, $34, $35, $5E, $5B, $5E, $5B, $55, $55, $55, $0A, $5E, $5B, $5B, $37
        .byte $34, $34, $35, $FC, $5E, $5B, $5B, $FC, $4F, $5A, $FC, $FC, $5B, $5E, $0A, $5E
        .byte $1F, $4A, $55, $0A, $1B, $1E, $5B, $37, $1B, $1E, $34, $34, $1B, $1E, $5E, $5B
        .byte $4B, $1E, $55, $55, $1B, $4E, $5B, $5B, $4F, $5A, $55, $60, $5B, $5F, $5B, $62
        .byte $FC, $38, $61, $64, $FC, $FC, $63, $66, $35, $39, $69, $6C, $5B, $55, $6B, $6E
        .byte $55, $55, $C1, $C4, $5E, $5B, $5B, $C6, $FC, $0A, $31, $5A, $3C, $3D, $33, $5E
        .byte $65, $70, $71, $74, $67, $72, $73, $76, $6D, $78, $79, $7C, $6F, $7A, $7B, $7E
        .byte $C5, $D0, $D1, $37, $C7, $D2, $D3, $5B, $FC, $FC, $FC, $FC, $68, $5B, $FC, $FC
        .byte $C3, $FC, $55, $55, $FC, $5B, $5E, $5B, $75, $0A, $34, $34, $5B, $5B, $5E, $5B
        .byte $FC, $FC, $4F, $5A, $5B, $5B, $5B, $5E, $FC, $FC, $1F, $4A, $FC, $FC, $1B, $1E
        .byte $35, $FC, $4B, $1E, $5B, $FC, $1B, $4E, $55, $FC, $1B, $1E, $5B, $FC, $1B, $1E
        .byte $FC, $55, $03, $02, $FC, $01, $06, $06, $57, $0C, $06, $03, $02, $02, $06, $06
        .byte $06, $06, $06, $06, $5D, $06, $06, $0C, $5D, $12, $5D, $05, $03, $5D, $06, $02
        .byte $B4, $E2, $F8, $B6, $F8, $F8, $F8, $F8, $EC, $BC, $F8, $BD, $F8, $F8, $F8, $F8
        .byte $F8, $BF, $E8, $EA, $F8, $F8, $F8, $F8, $E8, $F8, $B4, $B7, $F8, $F8, $F8, $F8
        .byte $E0, $E2, $E1, $E9, $F8, $F8, $F8, $F8, $E3, $B4, $BC, $BE, $F8, $F8, $F8, $F8
        .byte $F8, $F8, $F8, $B8, $F8, $F8, $F8, $F8, $BA, $B9, $BB, $F8, $F8, $F8, $F8, $F8
        .byte $B9, $B4, $B6, $B5, $F8, $F8, $F8, $F8, $B4, $F8, $F8, $F8, $F8, $F8, $F8, $F8
        .byte $F8, $F8, $E3, $E4, $F8, $F8, $F8, $F8, $E0, $B7, $EC, $B9, $F8, $F8, $F8, $F8
        .byte $B7, $BC, $F8, $E7, $F8, $F8, $F8, $F8, $ED, $F8, $F8, $F8, $F8, $F8, $F8, $F8
        .byte $EC, $E4, $EC, $B4, $F8, $F8, $F8, $F8, $B7, $EC, $BC, $E1, $F8, $F8, $F8, $F8
        .byte $F8, $E1, $CF, $F8, $F8, $F8, $F8, $F8, $B6, $E2, $B7, $B5, $F8, $F8, $F8, $F8
        .byte $E4, $E0, $B6, $F8, $F8, $F8, $F8, $F8, $E4, $EC, $E0, $BE, $F8, $F8, $F8, $FA
        .byte $FA, $F8, $BD, $F8, $F8, $F8, $F8, $F8, $BF, $E8, $EA, $EA, $F8, $F8, $F8, $F8
        .byte $FA, $FA, $FA, $FA, $FA, $FA, $FA, $FA, $B2, $57, $A4, $F8, $B3, $3A, $A5, $F8
        .byte $A4, $B0, $A0, $F8, $A5, $B1, $A2, $F8

; --- $A145  Colors for the first set.
colors_1:
        .byte $FF, $FF, $FF, $05, $55, $55, $55, $55, $55, $5A, $AA, $AA, $AA, $AF, $5C, $C5
        .byte $AA, $AA, $A5, $AA, $BF, $FE, $B3, $FE, $BF, $FE, $B3, $FE, $BF, $FE, $3F, $E2
        .byte $FF, $3F, $3B, $81, $63, $FF, $55, $55, $55, $55, $56, $66, $F9, $99, $F5, $55
        .byte $55, $55, $55, $55, $55, $AA, $AA, $AA, $AA, $AA, $5A, $AA, $5A, $AA, $A9, $AA
        .byte $A5, $55, $55, $F5, $57, $55, $55, $D5, $55, $55, $55, $55, $55, $55, $5F, $FF
        .byte $FF, $FF, $FF, $FF, $F1, $1A, $47, $F5, $55, $55, $55, $55, $55, $55, $55, $55
        .byte $55, $55, $55, $55, $55, $55, $FF, $FF, $5A, $A5, $99, $59, $55, $55, $55, $56
        .byte $55, $59, $99, $5A, $AE, $5A, $AA, $FF, $FF, $FF, $F5, $AA, $AA, $AA, $AA, $AA

; --- $A1C5  Colors for the second set.
colors_2:
        .byte $FF, $FF, $FF, $FF, $55, $55, $55, $55, $55, $55, $55, $55, $AB, $5A, $AD, $55
        .byte $55, $A5, $55, $55, $99, $55, $55, $55, $55, $55, $66, $55, $AA, $AA, $95, $66
        .byte $56, $A8, $88, $FF, $C5, $55, $55, $55, $FF, $E9, $69, $6A, $AA, $AA, $AA, $AA
        .byte $FF, $AA, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $5A
        .byte $AA, $AA, $A5, $FF, $FF, $AE, $EE, $55, $55, $55, $55, $55, $55, $55, $55, $55
        .byte $AA, $AA, $AA, $AA, $AA, $AA, $55, $55, $55, $55, $AA, $AA, $AA, $AA, $55, $5A
        .byte $AA, $AA, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55
        .byte $55, $55, $66, $6A, $AA, $AA, $AA, $AA, $55, $5A, $F5, $55, $55, $56, $55, $55

; --- $A245  Colors for the third set.
colors_3:
        .byte $AA, $AA, $A5, $55, $55, $5F, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $F5, $55, $56
        .byte $55, $55, $95, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55
        .byte $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $AA, $AA, $AA, $AA
        .byte $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $5F, $FF
        .byte $F5, $55, $55, $55, $55, $99, $95, $55, $55, $55, $55, $55, $56, $66, $FF, $FF
        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00

; --- $A2A2  The same bytes as the end of bank 04's scripts.
; Act VI, stage 5, from partway in, then the two scripts after it,
; through $A7D8. Bank 04 is the copy that runs.
        .byte $04, $7F, $FF, $77, $00, $05, $1E, $03, $41, $02, $42, $02, $39, $02, $1F, $00
        .byte $10, $0B, $0F, $FF, $77, $00, $03, $00, $0D, $01, $06, $43, $FF, $EF, $00, $81
        .byte $39, $90, $91, $9E, $60, $34, $00, $90, $01, $FF, $1D, $00, $84, $39, $90, $91
        .byte $9E, $6C, $38, $00, $8E, $01, $5C, $34, $00, $91, $01, $64, $28, $00, $92, $01
        .byte $58, $1C, $00, $93, $01, $06, $41, $FF, $3B, $00, $06, $41, $FF, $1D, $00, $06
        .byte $41, $FF, $1D, $00, $06, $41, $FF, $1D, $00, $06, $41, $FF, $D1, $00, $07, $1F
        .byte $8E, $1A, $21, $81, $39, $90, $91, $9E, $6C, $30, $20, $5E, $55, $06, $41, $FF
        .byte $59, $00, $09, $20, $57, $FF, $1B, $02, $06, $41, $09, $20, $58, $FF, $3B, $00
        .byte $07, $35, $8E, $D4, $20, $83, $39, $90, $91, $9E, $54, $28, $20, $5F, $58, $64
        .byte $28, $20, $60, $01, $5C, $20, $20, $61, $01, $06, $41, $FF, $59, $00, $07, $47
        .byte $8E, $D8, $20, $09, $21, $59, $06, $41, $FF, $D1, $00, $07, $5C, $8E, $96, $20
        .byte $09, $22, $58, $06, $41, $FF, $DF, $01, $09, $20, $01, $FF, $B3, $00, $09, $21
        .byte $01, $09, $22, $01, $FF, $77, $00, $03, $41, $FF, $2B, $01, $03, $4C, $81, $10
        .byte $11, $0B, $00, $A0, $48, $00, $3F, $45, $06, $33, $FF, $77, $00, $09, $00, $01
        .byte $0B, $FF, $0B, $03, $FF, $00, $00, $0E, $C0, $FF, $0D, $01, $03, $82, $02, $42
        .byte $02, $4F, $51, $48, $01, $2C, $18, $39, $81, $48, $23, $4C, $00, $4C, $30, $40
        .byte $23, $01, $C2, $55, $FF, $95, $00, $06, $46, $FF, $00, $00, $0E, $C0, $FF, $EF
        .byte $00, $02, $41, $02, $00, $00, $00, $01, $21, $81, $48, $23, $4E, $00, $58, $30
        .byte $00, $44, $01, $C2, $56, $FF, $00, $00, $0E, $C0, $FF, $BF, $03, $02, $41, $04
        .byte $23, $00, $00, $08, $30, $81, $39, $00, $00, $00, $44, $30, $00, $42, $01, $C2
        .byte $57, $FF, $00, $00, $0E, $C0, $FF, $95, $00, $02, $41, $02, $4F, $51, $48, $01
        .byte $2C, $81, $48, $23, $4E, $00, $4C, $30, $00, $44, $01, $C2, $58, $FF, $0D, $01
        .byte $81, $48, $23, $4C, $00, $4C, $30, $40, $23, $01, $FF, $00, $00, $0E, $C0, $FF
        .byte $67, $01, $02, $41, $02, $4F, $00, $00, $01, $2D, $81, $4C, $00, $00, $00, $40
        .byte $30, $00, $29, $01, $C2, $59, $FF, $00, $00, $0E, $C0, $FF, $D1, $00, $02, $41
        .byte $04, $23, $00, $00, $08, $30, $81, $39, $00, $00, $00, $44, $30, $00, $42, $01
        .byte $C2, $5A, $FF, $00, $00, $0E, $C0, $FF, $C1, $01, $02, $41, $02, $4F, $00, $00
        .byte $01, $2D, $81, $4C, $00, $00, $00, $40, $30, $00, $29, $01, $C2, $5B, $FF, $00
        .byte $00, $0E, $C0, $FF, $67, $01, $02, $41, $02, $4F, $51, $48, $01, $2C, $81, $48
        .byte $23, $4E, $00, $4C, $30, $00, $23, $01, $C2, $5C, $FF, $00, $00, $0E, $C0, $FF
        .byte $3F, $00, $02, $41, $09, $03, $00, $00, $01, $31, $82, $4F, $01, $20, $00, $20
        .byte $30, $00, $45, $01, $30, $2C, $00, $8C, $CB, $C2, $5D, $FF, $B3, $00, $81, $4F
        .byte $01, $20, $00, $20, $30, $00, $45, $01, $FF, $00, $00, $0E, $C0, $FF, $39, $02
        .byte $06, $34, $02, $41, $02, $4F, $51, $48, $01, $2C, $81, $48, $23, $4C, $00, $4C
        .byte $30, $40, $23, $01, $C2, $5E, $FF, $59, $00, $81, $48, $23, $4C, $00, $4C, $30
        .byte $40, $24, $01, $FF, $00, $00, $0E, $C0, $FF, $3F, $00, $03, $96, $02, $42, $14
        .byte $48, $4F, $00, $0A, $21, $01, $2E, $81, $48, $23, $00, $00, $29, $30, $20, $4A
        .byte $51, $04, $9F, $FF, $3B, $00, $0B, $FF, $09, $20, $01, $FF, $4F, $00, $0B, $96
        .byte $81, $48, $23, $00, $00, $31, $30, $20, $4B, $51, $FF, $77, $00, $0B, $FF, $09
        .byte $20, $01, $FF, $77, $00, $04, $1F, $FF, $1B, $02, $03, $96, $0B, $FF, $02, $42
        .byte $02, $48, $4F, $00, $0A, $21, $01, $2E, $81, $48, $23, $4C, $00, $4C, $30, $40
        .byte $23, $01, $04, $97, $C2, $5F, $FF, $00, $00, $0E, $C0, $FF, $2B, $01, $03, $82
        .byte $02, $41, $02, $4F, $00, $00, $01, $2D, $81, $4C, $00, $00, $00, $40, $30, $00
        .byte $29, $01, $C2, $60, $FF, $00, $00, $0E, $C0, $FF, $0D, $01, $02, $41, $02, $4F
        .byte $51, $48, $01, $2C, $81, $48, $23, $4E, $00, $4C, $30, $00, $43, $01, $C2, $61
        .byte $FF, $00, $00, $0E, $C0, $FF, $59, $00, $03, $87, $08, $9E, $05, $1E, $02, $42
        .byte $01, $3E, $3F, $00, $02, $1E, $03, $1F, $81, $10, $11, $0B, $00, $3C, $44, $00
        .byte $3F, $01, $0A, $01, $E0, $FF, $3B, $00, $0A, $02, $A0, $FF, $3B, $00, $0A, $13
        .byte $00, $FF, $3B, $00, $0A, $23, $00, $FF, $3B, $00, $0A, $33, $00, $FF, $B6, $02
        .byte $0A, $32, $00, $FF, $1D, $00, $04, $17, $FF, $B3, $00, $08, $90, $80, $05, $1E
        .byte $03, $9B, $06, $47, $FF, $0F, $00, $02, $41, $0F, $53, $00, $00, $0A, $1C, $FF
        .byte $0B, $03, $03, $89, $C2, $66, $FF, $00, $00, $0E, $C0, $FF, $1F, $00, $03, $83
        .byte $02, $42, $0F, $12, $13, $14, $1D, $03, $1D, $03, $81, $15, $00, $00, $00, $C0
        .byte $30, $00, $0D, $41, $FF, $85, $01, $03, $89, $09, $00, $01, $C2, $67, $FF, $00
        .byte $00, $0E, $C0, $FF, $1F, $00, $03, $84, $02, $41, $13, $11, $16, $09, $1E, $0B
        .byte $81, $01, $10, $11, $17, $B4, $30, $00, $17, $40, $FF, $53, $01, $03, $89, $09
        .byte $00, $01, $C2, $68, $FF, $00, $00, $0E, $C0, $FF, $0F, $00, $03, $9A, $02, $41
        .byte $0F, $0E, $00, $00, $16, $04, $82, $0F, $00, $00, $00, $2C, $51, $20, $4C, $01
        .byte $2C, $50, $00, $0E, $54, $FF, $85, $01, $03, $89, $81, $0F, $00, $00, $00, $2C
        .byte $30, $00, $0E, $01, $C2, $69, $FF, $00, $00, $0E, $C0, $FF, $1F, $00, $03, $83
        .byte $02, $41, $11, $2A, $06, $2C, $0A, $0C, $81, $06, $00, $00, $00, $C0, $30, $00
        .byte $19, $41, $FF, $ED, $02, $03, $89, $09, $00, $01, $C2, $6A, $FF, $00, $00, $0E
        .byte $C0, $FF, $0F, $00, $03, $9B, $02, $42, $0F, $0A, $A0, $0C, $1C, $11, $1C, $11
        .byte $82, $0A, $00, $00, $00, $40, $0F, $20, $4C, $01, $40, $10, $00, $1F, $53, $FF
        .byte $1B, $02, $03, $89, $81, $0A, $00, $00, $00, $40, $30, $00, $1F, $01, $C2, $6B
        .byte $FF, $00, $00, $0E, $C0, $FF, $1F, $00, $03, $84, $02, $41, $0F, $2F, $00, $00
        .byte $0A, $12, $82, $01, $09, $00, $00, $B4, $38, $00, $3E, $40, $A0, $2C, $00, $3D
        .byte $40, $FF, $67, $01, $03, $89, $09, $00, $01, $09, $01, $01, $C2, $6C, $FF, $00
        .byte $00, $0E, $C0, $FF, $1F, $00, $03, $83, $02, $41, $02, $01, $10, $11, $0A, $06
        .byte $81, $06, $07, $08, $00, $CC, $2C, $00, $10, $41, $FF, $67, $01, $03, $89, $09
        .byte $00, $01, $C2, $6D, $FF, $00, $00, $0E, $C0, $FF, $0F, $00, $03, $9A, $02, $41
        .byte $0F, $2D, $2E, $2F, $16, $13, $83, $2E, $30, $00, $00, $38, $51, $20, $4C, $01
        .byte $40, $51, $20, $4C, $01, $40, $50, $00, $40, $54, $FF, $67, $01, $03, $89, $81
        .byte $2E, $30, $00, $00, $40, $30, $00, $40, $01, $C2, $6E, $FF, $00, $00, $0E, $C0
        .byte $FF, $1F, $00, $03, $83, $02, $41, $02, $4F, $51, $48, $0A, $2C, $81, $48, $23
        .byte $4E, $00, $CC, $30, $00, $43, $41, $FF, $85, $01, $03, $89, $09, $00, $01, $C2
        .byte $6F, $FF, $00, $00, $0E, $C0, $FF, $B3, $00, $03, $82, $02, $80, $41, $0F, $00
        .byte $00, $00, $1F, $40, $04, $BE, $FF, $C1, $01, $CA, $70, $FF, $FE, $FF, $81, $00
        .byte $00, $00, $53, $40, $5C, $00, $32, $01, $04, $BD, $FF, $FF, $FF, $1F, $00, $80
        .byte $03, $54, $05, $1E, $06, $2A, $02, $42, $0F, $0D, $53, $00, $0D, $1A, $17, $1D
        .byte $FF, $1F, $00, $03, $55, $FF, $B3, $00, $0B, $01, $81, $A1, $9A, $9B, $9C, $58
        .byte $2C, $00, $50, $01, $04, $A9, $FF, $FF, $FF, $57, $02, $0A, $0F, $00, $03, $42
        .byte $03, $00, $02, $42, $0F, $53, $00, $00, $12, $1C, $1A, $3E, $80, $06, $02, $FF
        .byte $59, $00, $04

; --- $A7D5  The lines spoken in the cutscenes.
; The marks in these lines are the ones bank 05 reads.
.charmap $27, $25                       ; apostrophe
        .byte "?", new_line
        .byte new_line
        .byte new_line
        .byte "r is", new_line
        .byte "alive.", '"'
        .byte clear_text, '"', "Liar!", '"'
        .byte clear_text, '"', "No,", wait_text, " it is not a lie."
        .byte line_in, wait_text, "If you proceed further,", new_line
        .byte "you will see him.", new_line
        .byte clear_text, '"', "But it will be the last"
        .byte line_in, "thing you see.", '"', line_end
        .byte '"', "Ryu, you deserve praise", new_line
        .byte " for making it this far..", new_line
        .byte wait_text, wait_text, '"', "Where are you,"
        .byte line_in, "show yourself!", '"'
        .byte clear_text, '"', "...but even you cannot"
        .byte line_in, "defeat ", '"', "the masked", new_line
        .byte "devil", '"', line_end
        .byte '"', "No one can beat me.", '"', new_line
        .byte wait_text, new_line
        .byte '"', "Even... your father?", '"', line_end
        .byte '"', "What?!", '"', line_end
        .byte '"', "Your father was not"
        .byte line_in, "killed. he has been", new_line
        .byte "turned into ", '"', "the masked", new_line
        .byte "devil.", '"', line_end
        .byte '"', "No!", '"'
        .byte clear_text, '"', "It will be"
        .byte line_in, "entertaining to watch", new_line
        .byte "father and son fight to", new_line
        .byte "the death.", '"', line_end
        .byte '"', "Wake up, Father!", '"', line_end
        .byte '"', "No use.", wait_text, " He thinks only"
        .byte line_in, "of killing you.", line_end
        .byte '"', "So this is the hell"
        .byte line_in, "that Malth was talking", new_line
        .byte "about.", new_line
        .byte wait_text, "What shall I do?", line_end
        .byte '"', "I've got to think"
        .byte line_in, "clearly."
        .byte clear_text, '"', "Father's eyes... they"
        .byte line_in, "show he is controlled", new_line
        .byte "like a puppet.", new_line
        .byte "If I break the control...", line_end
        .byte '"', "But What is"
        .byte line_in, "controlling him?", new_line
        .byte wait_text, wait_text, wait_text, wait_text, "That's it!", '"', line_end
        .byte '"', "Father!", '"'
        .byte clear_text, '"', "... ", wait_text, "Where am I...?", new_line
        .byte wait_text, " Ryu... Are you Ryu?", '"', new_line
        .byte wait_text, new_line
        .byte '"', "Yes, Father.", '"', line_end
        .byte '"', "Damn, He's awake.", '"', line_end
        .byte '"', "The Jaquio!", '"', line_end
        .byte start_picture, $08, '"', "You both will die!", '"', change_picture, $27, line_end
        .byte '"', "Watch out!", '"', line_end
        .byte '"', "Ugh...!!!!", '"', new_line
        .byte wait_text, new_line
        .byte '"', "Father...", '"', line_end
        .byte '"', "Ryu...", wait_text, "you've got to", new_line
        .byte " ...get them for me.", '"', new_line
        .byte wait_text, new_line
        .byte '"', "Father!", '"', line_end
        .byte '"', "Your day has come,"
        .byte line_in, "Jaquio!", '"', line_end
        .byte '"', "Wake up father, wake up.", '"'
        .byte clear_text, '"', "Ryu...", wait_text, " I haven't got"
        .byte line_in, "much longer...", wait_text, "This", new_line
        .byte "temple is about to", new_line
        .byte "breake apart."
        .byte clear_text, '"', "Take that woman and"
        .byte line_in, "escape.", '"'
        .byte clear_text, '"', "What are you saying,"
        .byte line_in, "father.", new_line
        .byte "I can't just leave you!", '"'
        .byte clear_text, '"', "Ryu,", wait_text, " you are a man now.", wait_text
        .byte line_in, "My destiny is tied to", new_line
        .byte "the demon statue."
        .byte clear_text, '"', "Ryu,", wait_text, " good luck...", '"', line_end
        .byte '"', "Father,", wait_text, " father...!!!", '"', line_end
        .byte '"', "Father!!!", '"', line_end
        .byte wait_text, wait_text, '"', "Ryu...", '"', line_end
        .byte '"', "This is Sea Swallow...", '"', line_end
        .byte '"', "This is Foster."
        .byte line_in, "We detected the", new_line
        .byte "explosion from the", new_line
        .byte "satellite."
        .byte clear_text, '"', "Job well done. You are"
        .byte line_in, "to kill Ryu Hayabusa.", '"', line_end
        .byte '"', "What?", wait_text, " Kill Ryu?", new_line
        .byte wait_text, '"', "That's right."
        .byte line_in, "Then you are to steal", new_line
        .byte "the demon statues.", '"', line_end
        .byte start_picture, $0B, '"', "So this was your plan"
        .byte line_in, "all along ...", new_line
        .byte "I'll get you for this,Foster!", '"', change_picture, $29, line_end
        .byte '"', "Ryu, you...", '"', line_end
        .byte start_picture, $0B, '"', "I get two kinds of"
        .byte line_in, "payment.", new_line
        .byte change_picture, $29, wait_text, start_picture, $0B, "The first I have", new_line
        .byte "already received.", change_picture, $29, line_end
        .byte '"', "The second...", wait_text, " is you,"
        .byte line_in, "Foster!", '"', line_end
        .byte '"', "Ryu... wait...", '"', line_end
        .byte start_picture, $0A, '"', "Ryu,", change_picture, $23, wait_text, start_picture, $0A, " what is the"
        .byte line_in, "payment you have", new_line
        .byte "already recieved?", change_picture, $23
        .byte clear_text, '"', "She's right in front"
        .byte line_in, "of me.", '"', line_end
        .byte '"', "I don't even know your"
        .byte line_in, "name.", '"'
        .byte clear_text, start_picture, $0A, '"', "Irene,", change_picture, $23, wait_text, start_picture, $0A, " Irene Lew.", '"', change_picture, $23, line_end
        .byte start_picture, $0B, '"', "Well, Irene."
        .byte line_in, "Look, the sun is rising.", new_line
        .byte "Everything is so bright", new_line
        .byte "now.", change_picture, $29, line_end
        .byte '"', "the darkness is"
        .byte line_in, "finally over.", '"', line_end
        .byte '"', "Ryu!", '"', new_line
        .byte wait_text, '"', "Thank God your safe!", '"', line_end
        .byte '"', "Let's go, father."
        .byte line_in, wait_text, "Let's get out of this", new_line
        .byte "temple.", '"'
        .byte clear_text, '"', "Ryu, wait.", wait_text, " Before we"
        .byte line_in, "do, the demon statues...", new_line
        .byte wait_text, "we've got to throw them", new_line
        .byte "from the temple"
        .byte clear_text, '"', "while we've still got"
        .byte line_in, "time. Before the ", '"', "black", new_line
        .byte "moon", '"', " shines.", '"', line_end
        .byte '"', "Ryu, what's that?", '"', line_end
        .byte '"', "Is it a lunar eclipse?!"
        .byte line_in, wait_text, "That must be it.", new_line
        .byte "That's what the ", '"', "black", new_line
        .byte "moon", '"', " meant...."
        .byte clear_text, '"', "Oh, no!"
        .byte line_in, "The demon statue!", '"', line_end
        .byte skip_ahead, $08
; The staff roll.
        .byte "S T A F F", line_end
        .byte "STORY"
        .byte line_in, "  SAKURAZAKI", line_end
        .byte "SCREENPLAY"
        .byte line_in, "  SAKURAZAKI"
        .byte line_in, " FAW", line_end
        .byte "IMAGE ILLUST"
        .byte line_in, "  RUNMARU", line_end
        .byte "ART WORKS"
        .byte line_in, "  RUNMARU"
        .byte line_in, " PARCO"
        .byte line_in, "UMA"
        .byte clear_text, "   NAGA"
        .byte line_in, "  WILD TAGOU"
        .byte line_in, " NIWAKAMARU", line_end
        .byte "PROGRAM WORKS"
        .byte line_in, "  MADOKA SOUTHERNAMI"
        .byte line_in, " FAW", line_end
        .byte "ASSISTANT", new_line
        .byte "   NOSUKE", new_line
        .byte "NES TRANSLATOR"
        .byte line_in, "  DAREKASAN", line_end
        .byte "SOUND DESIGN"
        .byte line_in, "  MORE YAMASAN"
        .byte line_in, " B.B"
        .byte line_in, "HAKASE"
        .byte line_in, line_end
        .byte "DIRECTOR"
        .byte line_in, "  SAKURAZAKI", line_end
        .byte skip_ahead, $07, "AUDIO VISUAL"
        .byte line_in, "  COPYRIGHT MCMLXXXIX"
        .byte line_in, skip_ahead, $06, "TECMO LTD."
        .byte line_in, "ALL RIGHTS RESERVED.", line_end
        .byte "  THANK YOU FOR PLAYING."
        .byte line_in, "   AND SEE YOU NEXT.", line_end
.charmap $27, $27

; --- $B2BE  The same songs as bank 03.
; This bank never plays them.
song_copy:
        .byte $8F, $0C, $FB, $0F, $F0, $10, $0C, $0C, $FB, $0F, $F0, $10, $0C, $FB, $0F, $F4
        .byte $20, $0C, $0C, $0C, $FB, $0F, $F0, $10, $0C, $FB, $0F, $F4, $20, $0C, $0C, $FB
        .byte $0F, $F0, $10, $0C, $0C, $EB, $04, $FB, $0F, $F4, $20, $89, $0C, $EC, $EC, $EB
        .byte $07, $FB, $0F, $F0, $10, $97, $0C, $FB, $0F, $F4, $20, $0C, $EC, $EB, $09, $FB
        .byte $0F, $F4, $20, $89, $0C, $EC, $FF, $04, $15, $B3, $05, $5A, $B3, $02, $9C, $B3
        .byte $07, $E6, $B3, $06, $17, $B4, $FF, $E2, $C0, $E3, $0C, $ED, $EB, $02, $E0, $05
        .byte $A1, $32, $E0, $04, $94, $32, $E0, $05, $A1, $30, $E0, $04, $94, $30, $E0, $05
        .byte $A1, $2B, $E0, $04, $94, $2B, $E0, $05, $A1, $2A, $E0, $04, $94, $2A, $EC, $EF
        .byte $E0, $05, $9C, $29, $94, $29, $ED, $2A, $9C, $2B, $94, $2B, $2A, $EF, $9C, $29
        .byte $94, $29, $ED, $2A, $9C, $2B, $94, $2B, $31, $E8, $1A, $B3, $E2, $40, $E3, $0B
        .byte $EB, $02, $E0, $05, $A1, $25, $E0, $04, $94, $25, $E0, $05, $A1, $24, $E0, $04
        .byte $94, $24, $E0, $05, $A1, $27, $E0, $04, $94, $27, $E0, $05, $A1, $27, $E0, $04
        .byte $94, $27, $EC, $E3, $0C, $E0, $05, $9C, $24, $94, $24, $24, $9C, $25, $94, $25
        .byte $25, $9C, $24, $94, $24, $24, $9C, $28, $94, $28, $28, $E8, $5C, $B3, $E0, $0E
        .byte $EB, $02, $EB, $03, $94, $22, $89, $22, $8A, $22, $89, $22, $94, $22, $22, $EC
        .byte $94, $22, $EB, $03, $89, $22, $8A, $22, $89, $22, $EC, $EC, $94, $29, $89, $29
        .byte $8A, $29, $89, $29, $94, $29, $29, $28, $89, $28, $8A, $28, $89, $28, $94, $28
        .byte $28, $27, $89, $27, $8A, $27, $89, $27, $94, $27, $27, $25, $89, $25, $8A, $25
        .byte $89, $25, $94, $25, $24, $E8, $9E, $B3, $E0, $11, $E3, $05, $EB, $02, $EB, $03
        .byte $94, $01, $89, $01, $8A, $01, $89, $01, $94, $01, $01, $EC, $94, $01, $EB, $03
        .byte $89, $01, $8A, $01, $89, $01, $EC, $EC, $EB, $04, $94, $01, $89, $01, $8A, $01
        .byte $89, $01, $94, $01, $01, $EC, $E8, $EA, $B3, $EB, $02, $EB, $03, $FB, $0F, $F0
        .byte $10, $94, $0C, $FB, $0F, $F0, $10, $89, $0C, $FB, $0F, $F0, $10, $8A, $0C, $FB
        .byte $0F, $F0, $10, $89, $0C, $FB, $0F, $F0, $10, $94, $0C, $FB, $0F, $F0, $10, $0C
        .byte $EC, $FB, $0F, $F0, $10, $94, $0C, $EB, $03, $FB, $0F, $F0, $10, $89, $0C, $FB
        .byte $0F, $F0, $10, $8A, $0C, $FB, $0F, $F0, $10, $89, $0C, $EC, $EC, $EB, $04, $FB
        .byte $0F, $F0, $10, $94, $0C, $FB, $0F, $F0, $10, $89, $0C, $FB, $0F, $F0, $10, $8A
        .byte $0C, $FB, $0F, $F0, $10, $89, $0C, $EB, $02, $FB, $0F, $F0, $10, $94, $0C, $EC
        .byte $EC, $E8, $17, $B4, $04, $92, $B4, $05, $0B, $B5, $02, $5B, $B5, $07, $65, $B5
        .byte $06, $80, $B5, $FF, $E0, $05, $E2, $80, $E3, $0A, $8F, $2A, $26, $30, $ED, $30
        .byte $93, $30, $E0, $04, $30, $ED, $E0, $05, $8F, $31, $ED, $31, $EF, $2A, $30, $ED
        .byte $30, $93, $30, $30, $E0, $04, $8F, $30, $EF, $E0, $05, $98, $0C, $E3, $0B, $EB
        .byte $02, $8A, $2A, $26, $30, $ED, $30, $30, $E0, $04, $30, $E0, $05, $EF, $0C, $31
        .byte $ED, $E0, $04, $31, $EF, $E0, $05, $2A, $30, $30, $ED, $30, $30, $E0, $04, $30
        .byte $E0, $05, $0C, $EF, $EC, $EB, $02, $31, $2A, $33, $ED, $33, $33, $E0, $04, $33
        .byte $EF, $0C, $E0, $05, $34, $ED, $E0, $04, $34, $EF, $E0, $05, $31, $33, $33, $ED
        .byte $33, $33, $E0, $04, $33, $EF, $0C, $E0, $05, $EC, $E8, $BD, $B4, $E0, $05, $E2
        .byte $80, $E3, $0B, $8F, $23, $23, $23, $23, $93, $23, $E0, $04, $23, $E0, $05, $8F
        .byte $23, $23, $23, $23, $23, $23, $93, $23, $E0, $04, $93, $23, $98, $0C, $EB, $02
        .byte $90, $23, $8A, $0C, $90, $23, $8A, $1A, $90, $21, $23, $8A, $0C, $90, $23, $8A
        .byte $25, $90, $26, $EC, $EB, $02, $90, $26, $8A, $0C, $90, $26, $8A, $21, $90, $24
        .byte $26, $8A, $0C, $90, $26, $8A, $28, $90, $29, $EC, $E8, $2C, $B5, $E0, $0E, $A6
        .byte $0C, $0C, $98, $0C, $E8, $2C, $B5, $E3, $05, $81, $00, $83, $10, $97, $10, $A6
        .byte $10, $10, $E0, $11, $8A, $01, $01, $01, $01, $01, $01, $01, $E0, $09, $01, $E8
        .byte $70, $B5, $A6, $0C, $0C, $FB, $0F, $F4, $20, $85, $0C, $FB, $0F, $F4, $20, $0C
        .byte $0C, $FB, $0F, $F4, $20, $0C, $EB, $02, $FB, $0F, $F4, $20, $0C, $0C, $EC, $FB
        .byte $0F, $F0, $10, $90, $0C, $FB, $0F, $F4, $20, $8A, $0C, $FB, $0F, $F0, $10, $0C
        .byte $FB, $0F, $F0, $10, $90, $0C, $FB, $0F, $F4, $20, $0C, $FB, $0F, $F0, $10, $0C
        .byte $FB, $0F, $F4, $20, $8A, $0C, $EB, $02, $FB, $0F, $F0, $10, $0C, $EC, $EB, $03
        .byte $FB, $0F, $F4, $20, $0C, $EC, $E8, $9D, $B5, $04, $E7, $B5, $05, $57, $B6, $02
        .byte $2E, $88, $07, $2E, $88, $06, $2E, $88, $FF, $E2, $80, $E3, $0A, $E9, $38, $B6
        .byte $E0, $05, $92, $27, $ED, $9A, $27, $E0, $04, $27, $E9, $38, $B6, $E0, $05, $92
        .byte $26, $ED, $26, $E0, $04, $26, $EF, $E0, $05, $8F, $28, $ED, $E0, $04, $95, $28
        .byte $EF, $E0, $05, $8F, $25, $ED, $E0, $04, $95, $25, $EF, $E0, $05, $8F, $26, $ED
        .byte $E0, $04, $95, $26, $EF, $E0, $05, $8F, $27, $E0, $04, $95, $27, $EF, $E0, $05
        .byte $9A, $28, $ED, $A2, $28, $E0, $04, $9A, $28, $FF, $E0, $05, $84, $35, $ED, $E0
        .byte $04, $90, $35, $EF, $E0, $05, $84, $32, $ED, $E0, $04, $90, $32, $EF, $E0, $05
        .byte $84, $2A, $ED, $E0, $04, $90, $2A, $EF, $EA, $E0, $05, $E2, $80, $E3, $0A, $A2
        .byte $23, $E0, $04, $92, $23, $25, $27, $2A, $E0, $05, $A2, $20, $E0, $04, $92, $0C
        .byte $1A, $20, $17, $E0, $05, $E3, $0B, $9A, $15, $16, $17, $18, $18, $18, $E0, $04
        .byte $18, $FF, $0C, $0C, $03, $86, $B6, $FF, $E0, $11, $81, $10, $E3, $00, $81, $04
        .byte $0C, $0A, $FF, $03, $95, $B6, $FF, $E0, $11, $81, $10, $E3, $00, $81, $0C, $0A
        .byte $08, $06, $FF, $01, $A8, $B6, $03, $D2, $B6, $FF, $FF, $E0, $00, $82, $0C, $E2
        .byte $80, $82, $0C, $E3, $05, $15, $13, $14, $12, $13, $11, $12, $10, $11, $0B, $10
        .byte $0A, $0B, $09, $0A, $08, $09, $07, $08, $06, $07, $05, $06, $04, $05, $03, $04
        .byte $02, $03, $01, $FF, $FF, $81, $10, $E0, $00, $82, $10, $E3, $03, $81, $10, $81
        .byte $0C, $0B, $E3, $01, $0B, $0A, $E3, $02, $0A, $09, $E3, $03, $09, $08, $E3, $04
        .byte $08, $07, $E3, $05, $07, $06, $E3, $06, $06, $05, $E3, $07, $05, $04, $E3, $08
        .byte $04, $03, $E3, $09, $03, $02, $E3, $0A, $02, $01, $E3, $0B, $01, $00, $FF, $01
        .byte $14, $B7, $03, $26, $B7, $FF, $E0, $09, $82, $0C, $E2, $80, $82, $0C, $E3, $00
        .byte $81, $10, $00, $11, $01, $10, $00, $FF, $81, $10, $E0, $09, $82, $10, $E3, $00
        .byte $81, $10, $82, $05, $83, $0E, $0D, $8E, $09, $FF, $00, $3F, $B7, $01, $66, $B7
        .byte $FF, $E0, $00, $81, $0C, $E2, $80, $0C, $E3, $07, $81, $48, $49, $44, $45, $40
        .byte $41, $38, $39, $34, $35, $30, $31, $28, $29, $24, $25, $20, $21, $31, $30, $35
        .byte $34, $39, $38, $40, $43, $46, $49, $FF, $82, $0C, $E0, $00, $0C, $E2, $50, $0C
        .byte $E3, $0C, $0C, $E8, $48, $B7, $00, $7B, $B7, $01, $9E, $B7, $FF, $E0, $00, $81
        .byte $0C, $E2, $80, $81, $0C, $E3, $07, $82, $E4, $86, $20, $E4, $86, $24, $E4, $86
        .byte $27, $E4, $86, $30, $E4, $86, $34, $E4, $86, $37, $E4, $86, $39, $96, $40, $FF
        .byte $83, $0C, $E5, $01, $81, $0C, $E8, $7B, $B7, $00, $AE, $B7, $01, $DE, $B7, $FF
        .byte $E0, $00, $81, $0C, $E2, $80, $0C, $E3, $07, $81, $10, $11, $14, $15, $18, $19
        .byte $20, $21, $24, $25, $28, $29, $30, $31, $34, $35, $38, $39, $40, $41, $44, $45
        .byte $48, $49, $50, $51, $54, $55, $58, $59, $60, $61, $64, $65, $68, $8F, $69, $FF
        .byte $82, $0C, $E0, $00, $83, $0C, $E2, $80, $0C, $E3, $0C, $0C, $E8, $B7, $B7, $01
        .byte $F1, $B7, $FF, $E0, $00, $E2, $40, $81, $0C, $E3, $03, $81, $37, $40, $0C, $37
        .byte $40, $0C, $37, $40, $FF, $03, $07, $B8, $FF, $E0, $00, $81, $10, $E3, $00, $81
        .byte $03, $09, $02, $FF, $03, $16, $B8, $FF, $E0, $00, $81, $10, $E3, $03, $81, $02
        .byte $04, $06, $08, $01, $03, $05, $07, $82, $10, $E8, $1C, $B8, $03, $2E, $B8, $FF
        .byte $E0, $00, $81, $10, $E3, $00, $81, $00, $01, $02, $03, $04, $05, $04, $05, $06
        .byte $05, $06, $07, $06, $07, $08, $07, $08, $09, $08, $09, $0A, $09, $0A, $0B, $0A
        .byte $0B, $0C, $0B, $0C, $0D, $0C, $0D, $0E, $0D, $0E, $96, $0F, $FF, $03, $5F, $B8
        .byte $FF, $E0, $00, $81, $10, $E3, $00, $81, $08, $09, $0A, $0B, $0F, $0E, $0D, $0C
        .byte $0B, $0A, $09, $08, $07, $06, $05, $04, $03, $04, $03, $02, $03, $02, $01, $02
        .byte $01, $96, $00, $FF, $01, $86, $B8, $FF, $E0, $05, $E2, $80, $E3, $00, $83, $2B
        .byte $82, $0C, $83, $2B, $FF, $01, $9A, $B8, $03, $CA, $B8, $FF, $E0, $00, $81, $0C
        .byte $E2, $40, $81, $0C, $E3, $07, $81, $00, $10, $20, $01, $11, $21, $03, $13, $23
        .byte $05, $15, $25, $24, $22, $14, $12, $23, $21, $13, $11, $22, $20, $12, $10, $0B
        .byte $0A, $09, $08, $07, $06, $05, $04, $03, $02, $01, $00, $FF, $82, $10, $E0, $00
        .byte $10, $E3, $05, $10, $E8, $34, $B8, $01, $DC, $B8, $03, $F9, $B8, $FF, $E0, $00
        .byte $81, $0C, $E2, $C0, $0C, $E3, $00, $01, $00, $04, $03, $0C, $0C, $10, $0B, $0A
        .byte $09, $08, $07, $06, $05, $04, $03, $02, $01, $00, $FF, $81, $10, $E0, $00, $10
        .byte $E3, $08, $00, $02, $04, $06, $01, $02, $03, $04, $82, $05, $06, $83, $07, $8E
        .byte $0C, $FF, $07, $14, $B9, $FF, $E0, $00, $81, $10, $E3, $00, $84, $0E, $0F, $0D
        .byte $0E, $0C, $0D, $E3, $01, $0B, $0C, $0A, $0B, $E3, $02, $09, $0A, $08, $09, $E3
        .byte $03, $07, $08, $E3, $04, $06, $07, $E3, $05, $05, $06, $E3, $06, $04, $05, $E0
        .byte $06, $9C, $04, $FF, $01, $49, $B9, $03, $4E, $B9, $FF, $E0, $05, $E3, $03, $FF
        .byte $FF, $01, $56, $B9, $03, $68, $B9, $FF, $E0, $11, $81, $0C, $E2, $00, $0C, $E3
        .byte $05, $EB, $10, $81, $00, $12, $82, $0C, $EC, $FF, $81, $10, $E0, $11, $10, $E3
        .byte $09, $EB, $10, $81, $0C, $04, $82, $10, $EC, $FF, $03, $7C, $B9, $FF, $E0, $00
        .byte $81, $10, $E3, $00, $81, $0A, $0B, $0C, $0D, $0C, $0B, $0A, $09, $08, $FF, $01
        .byte $94, $B9, $03, $AF, $B9, $FF, $E0, $00, $81, $0C, $E2, $40, $0C, $E3, $00, $84
        .byte $E4, $85, $10, $E3, $05, $E4, $85, $0B, $E3, $0A, $E4, $85, $0A, $E4, $85, $09
        .byte $FF, $81, $10, $E0, $00, $81, $10, $E3, $03, $0F, $05, $0E, $05, $0D, $05, $06
        .byte $07, $08, $09, $E3, $06, $8E, $07, $FF, $04, $D6, $B9, $05, $00, $BA, $02, $29
        .byte $BA, $07, $33, $BA, $06, $2E, $88, $FF, $E2, $80, $84, $0C, $E3, $00, $0C, $E0
        .byte $00, $81, $0C, $86, $E4, $85, $15, $FF, $E3, $05, $E4, $85, $14, $E3, $0A, $E4
        .byte $85, $13, $E4, $85, $12, $E4, $85, $11, $E4, $85, $10, $E4, $85, $0B, $E4, $85
        .byte $0A, $FF, $81, $0C, $E2, $C0, $84, $0C, $E3, $00, $8A, $0C, $E0, $06, $E4, $85
        .byte $18, $E3, $05, $E4, $85, $17, $E3, $0A, $E4, $85, $18, $E4, $85, $17, $E4, $85
        .byte $16, $E4, $85, $17, $E4, $85, $16, $E4, $85, $15, $FF, $82, $0C, $E0, $0C, $86
        .byte $0C, $ED, $96, $07, $FF, $83, $10, $E3, $00, $10, $82, $10, $E3, $00, $81, $10
        .byte $E0, $06, $81, $0F, $05, $0E, $05, $0D, $05, $06, $07, $08, $09, $0A, $0B, $0C
        .byte $0B, $0C, $0D, $0C, $0D, $0E, $A5, $0D, $FF, $06, $2E, $88, $04, $67, $BA, $05
        .byte $82, $BA, $02, $9B, $BA, $07, $AF, $BA, $FF, $E0, $04, $E2, $80, $E3, $09, $ED
        .byte $8B, $38, $37, $35, $2A, $2A, $92, $38, $8B, $37, $38, $35, $92, $37, $8B, $34
        .byte $38, $9A, $35, $FF, $E0, $04, $E2, $40, $E3, $0A, $97, $0C, $8B, $25, $25, $92
        .byte $35, $8B, $33, $35, $30, $92, $30, $8B, $30, $35, $9A, $30, $FF, $E0, $0D, $97
        .byte $0C, $8B, $1A, $1A, $0C, $21, $0C, $20, $30, $20, $0C, $23, $24, $E0, $0C, $25
        .byte $FF, $E0, $11, $E3, $05, $8B, $01, $02, $03, $EB, $02, $FB, $0F, $F0, $10, $8B
        .byte $01, $EC, $FB, $0F, $F4, $20, $02, $01, $FB, $0F, $F0, $10, $01, $EB, $02, $FB
        .byte $0F, $F4, $20, $01, $EC, $FB, $0F, $F0, $10, $01, $10, $EB, $03, $FB, $0F, $F4
        .byte $20, $01, $EC, $FF, $00, $E6, $BA, $FF, $E0, $00, $E2, $80, $E3, $00, $FF, $03
        .byte $F1, $BA, $FF, $E0, $11, $E3, $00, $81, $0F, $0E, $0D, $8A, $0A, $FF, $01, $03
        .byte $BB, $03, $13, $BB, $FF, $E0, $00, $E2, $80, $83, $0C, $0C, $E3, $0C, $81, $45
        .byte $E3, $00, $96, $5B, $FF, $E0, $00, $E3, $00, $82, $04, $05, $04, $05, $83, $04
        .byte $03, $84, $02, $FF, $03, $26, $BB, $FF, $E0, $00, $E3, $01, $81, $0A, $EB, $10
        .byte $06, $0B, $E3, $07, $07, $02, $05, $10, $10, $EC, $FF, $03, $3D, $BB, $FF, $E0
        .byte $00, $E3, $00, $81, $0A, $08, $82, $06, $04, $83, $01, $FF, $03, $4E, $BB, $FF
        .byte $E0, $00, $E3, $05, $ED, $84, $09, $85, $05, $FF, $01, $5F, $BB, $03, $6C, $BB
        .byte $FF, $E0, $00, $E2, $80, $E3, $00, $81, $09, $0A, $0B, $0A, $14, $FF, $E0, $11
        .byte $E3, $00, $81, $0F, $0E, $0D, $E3, $03, $8A, $0A, $FF, $FF, $00, $2E, $88, $01
        .byte $93, $BB, $02, $2E, $88, $03, $98, $BB, $04, $2E, $88, $05, $2E, $88, $06, $2E
        .byte $88, $07, $2E, $88, $FF, $81, $0C, $E8, $14, $B7, $E0, $00, $E3, $00, $81, $10
        .byte $0C, $04, $96, $0B, $FF, $FF, $04, $B4, $BB, $05, $C7, $BB, $07, $D3, $BB, $02
        .byte $2E, $88, $06, $2E, $88, $FF, $E0, $05, $E2, $00, $E3, $06, $90, $0A, $E5, $06
        .byte $0A, $E5, $0B, $0A, $E5, $03, $E8, $BB, $BB, $E0, $05, $E2, $80, $E3, $06, $ED
        .byte $90, $04, $E8, $CE, $BB, $E0, $00, $E3, $09, $81, $0D, $82, $03, $E8, $D7, $BB
        .byte $01, $E5, $BB, $03, $F1, $BB, $FF, $E0, $05, $E2, $C0, $E3, $00, $81, $01, $00
        .byte $00, $01, $FF, $E0, $00, $E3, $00, $82, $10, $81, $01, $0F, $0D, $0E, $0D, $83
        .byte $0F, $FF, $04, $2E, $88, $05, $2E, $88, $02, $2E, $88, $03, $3A, $BA, $06, $2E
        .byte $88, $07, $2E, $88, $FF, $00, $1A, $BC, $03, $2B, $BC, $FF, $E3, $00, $86, $E4
        .byte $85, $15, $E3, $05, $E4, $85, $14, $E3, $0A, $E4, $85, $13, $FF, $E0, $06, $E3
        .byte $03, $81, $0F, $05, $0E, $05, $0D, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0B
        .byte $0C, $0D, $0C, $0D, $0E, $96, $0C, $FF, $04, $2E, $88, $05, $2E, $88, $02, $2E
        .byte $88, $07, $56, $BC, $06, $2E, $88, $FF, $E0, $05, $E3, $03, $86, $00, $00, $01
        .byte $01, $02, $02, $03, $03, $85, $04, $04, $05, $05, $84, $06, $06, $07, $07, $83
        .byte $08, $08, $FF, $04, $81, $BC, $05, $1C, $BD, $06, $BF, $BD, $07, $C8, $BD, $02
        .byte $2E, $88, $FF, $E0, $00, $E2, $80, $E3, $0C, $81, $00, $E3, $0B, $00, $E3, $0A
        .byte $00, $E3, $09, $00, $E3, $08, $00, $E3, $07, $00, $E3, $06, $00, $E3, $05, $00
        .byte $E9, $C8, $BC, $E9, $C8, $BC, $E9, $C8, $BC, $E9, $C8, $BC, $E9, $C8, $BC, $E9
        .byte $C8, $BC, $E9, $C8, $BC, $E9, $C8, $BC, $E9, $C8, $BC, $E9, $C8, $BC, $FE, $38
        .byte $E9, $C8, $BC, $E9, $C8, $BC, $E9, $C8, $BC, $FF, $81, $E9, $F7, $BC, $15, $06
        .byte $11, $83, $10, $81, $10, $05, $09, $06, $E9, $F7, $BC, $05, $06, $07, $06, $05
        .byte $04, $05, $06, $07, $06, $05, $04, $E9, $F7, $BC, $05, $04, $05, $04, $05, $04
        .byte $E9, $F7, $BC, $82, $10, $06, $15, $08, $EA, $15, $11, $10, $06, $14, $10, $09
        .byte $05, $13, $09, $08, $04, $12, $08, $07, $03, $11, $07, $06, $02, $10, $06, $05
        .byte $01, $09, $05, $00, $04, $09, $05, $04, $00, $09, $05, $00, $04, $EA, $E0, $00
        .byte $E2, $80, $E3, $0C, $81, $01, $E3, $0B, $01, $E3, $0A, $01, $E3, $09, $01, $E3
        .byte $08, $01, $E3, $07, $01, $E3, $06, $01, $E3, $05, $01, $E9, $54, $BD, $E9, $54
        .byte $BD, $E9, $54, $BD, $E9, $54, $BD, $E9, $54, $BD, $E9, $54, $BD, $FE, $20, $E9
        .byte $54, $BD, $E9, $54, $BD, $FF, $81, $E9, $9A, $BD, $10, $05, $08, $11, $06, $09
        .byte $09, $04, $12, $E9, $9A, $BD, $82, $00, $01, $02, $E9, $9A, $BD, $81, $12, $09
        .byte $15, $82, $0B, $81, $06, $08, $04, $E9, $9A, $BD, $06, $05, $03, $04, $04, $03
        .byte $05, $82, $E9, $9A, $BD, $81, $07, $06, $08, $09, $08, $07, $08, $09, $08, $07
        .byte $E9, $9A, $BD, $00, $05, $00, $00, $05, $00, $00, $05, $EA, $10, $09, $08, $07
        .byte $06, $09, $08, $07, $06, $05, $08, $07, $06, $05, $04, $07, $06, $05, $04, $03
        .byte $06, $05, $04, $03, $06, $05, $03, $04, $06, $05, $04, $03, $06, $05, $03, $04
        .byte $EA, $E0, $0C, $ED, $EB, $21, $9D, $15, $EC, $FF, $E0, $0F, $E3, $0D, $81, $0A
        .byte $E3, $0C, $0A, $E3, $0B, $0A, $E3, $0A, $0A, $E3, $09, $0A, $E3, $08, $0A, $E3
        .byte $07, $0A, $E3, $06, $0A, $EB, $0A, $90, $0A, $98, $0A, $9D, $0A, $90, $0A, $98
        .byte $0A, $EC, $FE, $60, $EB, $20, $90, $0A, $EC, $FF, $00, $02, $BE, $01, $16, $BE
        .byte $04, $2A, $BE, $FF, $E0, $06, $E2, $80, $E3, $00, $84, $E4, $83, $30, $FE, $05
        .byte $EB, $08, $8B, $E4, $83, $30, $EC, $FF, $E0, $06, $E2, $80, $E3, $01, $84, $E4
        .byte $83, $27, $FE, $05, $EB, $08, $8B, $E4, $83, $27, $EC, $FF, $E0, $09, $E3, $00
        .byte $84, $06, $FE, $05, $EB, $08, $8B, $06, $EC, $FF, $FF, $00, $46, $BE, $01, $47
        .byte $BE, $02, $48, $BE, $03, $49, $BE, $FF, $FF, $FF, $FF, $FF, $02, $4E, $BE, $FF
        .byte $E0, $0C, $84, $48, $0C, $8A, $48, $84, $0C, $8D, $48, $92, $0C, $84, $48, $0C
        .byte $8A, $48, $84, $0C, $8D, $48, $FF, $04, $DD, $B9, $05, $0A, $BA, $02, $2F, $BA
        .byte $07, $3A, $BA, $FF, $01, $79, $BE, $03, $D3, $BE

; --- $BE78  Empty.
        .res 101, $FF

; --- $BEDD  More of the songs. This bank never plays them.
        .byte $48, $F7, $C8, $0E, $E0, $0F, $A4, $1C, $EC, $9F, $A4, $0D, $E5, $1E, $E4, $0E
        .byte $EC, $8E, $E4, $A4, $88, $EC, $1B, $E4, $0B, $E5, $1E, $F4, $0C, $B4, $0C, $F6
        .byte $DD, $E0, $9F, $40, $F7, $40, $F5, $40, $F7, $40, $E7, $40, $F3, $40, $F2, $40
        .byte $F3, $40, $F2, $FF, $40, $F6, $40, $FF, $40, $F3, $40, $F7, $40, $F3, $40, $F7
        .byte $40, $F6, $40, $01, $F2, $19, $CA, $13, $F3, $0B, $C1, $01, $F2, $13, $F2, $02
        .byte $F6, $0D, $D2, $FA, $53, $E0, $40, $E6, $03, $FA, $19, $F4, $10, $F1, $03, $DF
        .byte $47, $F3, $19, $40, $FD, $40, $FB, $40, $FB, $40, $F5, $40, $F3, $40, $E5, $40
        .byte $F7, $40, $F5, $FF, $40, $F7, $40, $FA, $40, $F7, $40, $FB, $40, $F6, $40, $E7
        .byte $40, $F1, $40, $09, $E3, $17, $F2, $0B, $E3, $09, $C0, $18, $E3, $17, $F0, $1B
        .byte $F4, $0F, $E0, $E0, $02, $D0, $19, $EA, $11, $E3, $11, $AA, $01, $E3, $19, $F0
        .byte $09, $F1, $1B, $40, $F6, $40, $F4, $40, $F6, $40, $F6, $40, $FF, $C0, $F6, $40
        .byte $F4, $40, $F5, $FE, $40, $F5, $40, $EF, $40, $F7, $50

; --- $BF98  The rest of a call, once this bank is switched in.
; Then switch the other bank back.
call_bank_06:
        sta call_num                    ; which picture, when this call draws one
        txa
        pha
        rol
        rol
        rol
        and #$03
        ora #$04
        jsr set_prg+2                   ; switch the program bank, but do not remember it
        pla
        and #$3F
        jsr draw_routines
        lda z:prg_bank
        jsr set_prg
        rts

; --- $BFB3  Routines the other banks can call.
draw_routines:
        jsr pick_routine
        .word draw_picture
        .word start_sound_test
        .word f8006                         ; inside the drawing
        .word f8009
        .word f800C
        .byte $00, $FE, $48, $EF, $48, $FF, $00, $FD, $48, $FC, $C8, $ED, $48, $EE, $C8, $E5
        .byte $D8, $A9, $10, $8D, $00, $20, $A9, $80, $8D, $00

; --- $BFDA  Same first instructions as reset.
reset_copy_06:
        inc $FFDA
        jmp $C03E
        .byte $FF, $FF, $4A, $CA, $D0, $F9, $4C, $F0, $FF, $E4, $0E, $E4, $10, $E8, $0F, $E4
        .byte $AC, $08, $E0, $0D, $A6, $09, $F7, $0C, $EC, $00, $DA, $FF, $DA, $FF, $DA, $FF
