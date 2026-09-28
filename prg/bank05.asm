; PRG file bank 05, switched in at $8000-$BFFF.
; The pictures that move during a cutscene, and the lines that are spoken.
; Every frame, bank 04 calls here to move those pictures, draw them,
; and read the line.

call_num       = $0394 ; the number this call was given
chr_bank0      = $56   ; CHR bank 0. These pictures' sprites use these tiles
sprite_i       = $033F ; the next sprite to draw
draw_flags     = $0380 ; bit 6 faces left
draw_x         = $0381 ; where the picture is drawn
draw_x_hi      = $0382 ; past 256 pixels
draw_y         = $0383 ; how high it is drawn
tiles_handed   = $0387 ; this frame's tiles were already handed over
packet_i       = $0395 ; where the next letter is added
tile_buf       = $03C3 ; the letters waiting to go to the screen
line_on        = $0313 ; a line is showing
line_i         = $0314 ; which byte of the line
line_wait      = $0315 ; frames left before the next step
line_speed     = $0316 ; frames between letters
line_at        = $0317 ; where the next letter is written
line_at_hi     = $0318 ; the rest of that place
blank_tile     = $FA   ; the empty tile
box_top        = $22   ; the text box, near the bottom of the screen
box_left       = $83   ; its left side
row_down       = $40   ; down to the next line of text
line_job       = $0319 ; 0 reads the line, 1 wipes the box
line_col       = $031A ; letters so far on this row
wipe_col       = $031B ; the column being wiped
speed_copy     = $031C ; the delay between letters, kept while the box is wiped
line_ptr       = $E6   ; the line being read
actor_move     = $0340 ; how this picture moves. 0 means the slot is empty
actor_x_lo     = $0341 ; the fraction under where it stands
actor_x        = $0342 ; where it stands
actor_y_lo     = $0343 ; the fraction under how high it is
actor_y        = $0344 ; how high
actor_flags    = $0345 ; bit 6 faces left
actor_time     = $0346 ; frames left on this pose
actor_pose     = $0347 ; which pose
actor_pic      = $0348 ; which picture. Bit 7 picks the pose from a list

line_end       = $F8   ; the line is over
skip_ahead     = $F9   ; skip ahead by the next number
line_in        = $FA   ; the next line, one letter in
clear_text     = $FB   ; wait, then wipe the text box
wait_text      = $FC   ; wait about a second
start_picture  = $FD   ; set a picture. the next byte says which
change_picture = $FE   ; change that picture
new_line       = $FF   ; the next line

; --- $8000  Draw this picture's sprites.
; The call list at the end of this bank points here.
draw_actor:
        jmp b800F

; --- $8003  Move the pictures.
; Called every frame, before the script's next step.
move_actors:
        jmp b80BE

; --- $8006  Draw the pictures.
; Called every frame, after the script's next step.
draw_actors:
        jmp b8176

; --- $8009  Read the line.
; Called every frame while a line is showing.
read_text:
        jmp b81FD

; --- $800C  Start the line this call was given.
start_line:
        jmp open_line

; Which picture this call asked for.
b800F:
        lda call_num                         ; which picture
        asl                                  ; two bytes in the list

; --- $8013  Draw picture A. A is the picture number times two.
use_picture:
        tay
        lda actor_pics,y
        sta $00
        lda actor_pics+1,y
        sta $01
        ldy #$00
        lda ($00),y
        iny
        sta chr_bank0                        ; sprite tiles for this picture

; --- $8025  The next group of tiles. A high byte ends the picture.
next_group:
        lda ($00),y
        bpl b802A                            ; another group
        rts                                  ; the picture is done
b802A:
        iny
        tax
        lda pixel_shift,x                    ; how far sideways this group sits
        bit draw_flags
        bvc b8039                            ; not facing left
        eor #$FF                             ; turn the shift around
        sec
        sbc #$07                             ; one tile wide
b8039:
        sta $05                              ; the shift, facing the way the picture faces
        clc
        adc draw_x                           ; plus where the picture stands
        sta $02
        lda draw_x_hi
        bcc b8048
        eor #$01                             ; crossed 256 pixels
b8048:
        ldx $05
        bpl b804E
        eor #$01                             ; a leftward shift crosses back
b804E:
        lsr
        bcc b805D                            ; still on this screen
        tya
        lsr
        php
        adc ($00),y                          ; where the other side of this group is
        plp
        rol
        tay
        iny
        jmp next_group

; This side of the screen. The next byte is how many tiles.
b805D:
        lda ($00),y
        iny
        sta $03                              ; how many tiles
        sty $04
        ldx sprite_i                         ; the next sprite

; --- $8067  The next tile in this group.
next_tile:
        ldy $04
        lda ($00),y
        iny
        sta $0201,x                          ; which tile
        lda ($00),y
        iny
        sty $04
        sta $05
        lsr                                  ; how far down is in the top of the byte
        lsr
        lsr
        tay
        lda pixel_shift,y                    ; how far down it sits
        clc
        adc draw_y                           ; plus how high the picture is
        sta $0200,x                          ; how high this tile is
        lda $05
        and #$07                             ; its color and flip
        lsr
        bcc b808D                            ; not flipped
        ora #$40                             ; this tile is flipped
b808D:
        eor draw_flags                       ; and when the picture faces left
        sta $0202,x                          ; how it is flipped and colored
        lda $02
        sta $0203,x                          ; where it sits sideways
        inx
        inx
        inx
        inx
        dec $03
        bne next_tile
        stx sprite_i                         ; the next sprite
        ldy $04
        jmp next_group

; --- $80A8  Call the routine picked from the list after this jsr.
pick_entry:
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

; Each of the four pictures.
b80BE:
        ldx #$00
b80C0:
        ldy actor_move,x
        beq b80CC                            ; empty slot
        txa
        pha
        jsr move_one
        pla
        tax
b80CC:
        txa
        clc
        adc #$10                             ; the next picture
        tax
        cmp #$40                             ; all four
        bne b80C0
        rts

; --- $80D6  Move this picture.
; It stays, slides, walks a path, or changes speed.
move_one:
        dey
        bne b80DA
        rts                                  ; it stays put
b80DA:
        dey
        bne follow_path

; --- $80DD  Add its speed to where it stands.
add_place:
        clc
        lda $0349,x                          ; sideways speed
        adc actor_x_lo,x
        sta actor_x_lo,x
        lda $034A,x                          ; the rest of the sideways speed
        adc actor_x,x
        sta actor_x,x
        clc
        lda $034B,x                          ; up and down speed
        adc actor_y_lo,x
        sta actor_y_lo,x
        lda $034C,x                          ; the rest of the up and down speed
        adc actor_y,x
        sta actor_y,x
        rts

; --- $8104  Walk to the next place on its path.
follow_path:
        dey
        bne b8151
        lda $034A,x                          ; frames left on this spot
        tay
        and #$0F
        beq b8115                            ; time to move on
        dec $034A,x                          ; one frame less
        jmp b8126                            ; stay here
b8115:
        tya
        lsr
        lsr
        lsr
        lsr
        ora $034A,x                          ; count that wait again
        sta $034A,x
        inc $034B,x                          ; the next place
        inc $034B,x

; Put it on this place in the path.
b8126:
        lda $0349,x                          ; which path
        asl
        tay
        lda picture_path,y
        sta $00
        lda picture_path+1,y
        sta $01
        lda $034B,x                          ; where it is on the path
        tay
b8139:
        lda ($00),y
        bpl b8146                            ; a place on the path
        lda #$00                             ; the path repeats
        sta $034B,x
        tay
        jmp b8139
b8146:
        iny
        sta actor_x,x                        ; where it stands
        lda ($00),y
        iny
        sta actor_y,x                        ; how high
        rts

; Slide, and change its speed.
b8151:
        jsr add_place                        ; slide
        jsr add_speed                        ; change the sideways speed
        inx
        inx                                  ; now the up and down speed
        jsr add_speed
        rts

; --- $815D  Add this to its speed.
add_speed:
        clc
        lda $034D,x                          ; how much the speed changes
        asl
        ldy #$00
        bcc b8167
        dey                                  ; the change is negative
b8167:
        ror
        adc $0349,x
        sta $0349,x
        tya
        adc $034A,x
        sta $034A,x
        rts

; Leave the split sprite, then the four pictures.
b8176:
        lda #$04
        sta sprite_i                         ; leave the split sprite
        ldx #$00
b817D:
        ldy actor_move,x
        beq b8189                            ; empty slot
        txa
        pha
        jsr draw_one
        pla
        tax
b8189:
        txa
        clc
        adc #$10                             ; the next picture
        tax
        cpx #$40                             ; all four
        bne b817D
        rts

; --- $8193  Draw this picture.
draw_one:
        lda actor_x_lo,x
        asl
        lda actor_x,x
        rol
        sta draw_x                           ; where it is drawn
        lda #$00
        rol
        sta draw_x_hi                        ; past 256 pixels
        lda actor_y_lo,x
        asl
        lda actor_y,x
        rol
        sec
        sbc #$01                             ; one pixel higher
        sta draw_y                           ; how high it is drawn
        lda actor_flags,x
        sta draw_flags                       ; bit 6 faces left
        lda actor_time,x
        tay
        and #$0F
        beq b81C6                            ; time for the next pose
        dec actor_time,x                     ; one frame less
        jmp b81D4                            ; keep this pose

; The pose's time ran out.
b81C6:
        tya
        lsr
        lsr
        lsr
        lsr
        ora actor_time,x                     ; count that wait again
        sta actor_time,x
        inc actor_pose,x                     ; the next pose

; Draw whichever picture this pose is.
b81D4:
        lda actor_pic,x
        asl
        bcc b81F9                            ; one picture, not a list
        tay
        lda pose_list,y                      ; which list of poses
        sta a:$00
        lda pose_list+1,y
        sta a:$01
        ldy actor_pose,x

; The next pose in the list.
b81EA:
        lda ($00),y
        cmp #$FF                             ; the list repeats
        bne b81F8
        lda #$00
        tay
        sta actor_pose,x                     ; back to the first pose
        beq b81EA
b81F8:
        asl                                  ; that pose's picture
b81F9:
        jsr use_picture
        rts

; Wait out the pause, then read or wipe.
b81FD:
        lda line_wait
        beq b8206                            ; the wait is over
        dec line_wait                        ; one frame less
        rts                                  ; still waiting
b8206:
        lda line_job                         ; 0 reads the line, 1 wipes the box
        jsr pick_entry
        .word read_char                 ; read the line
        .word clear_column              ; wipe the box

; --- $8210  The next letter, or a command.
read_char:
        ldy line_i
        inc line_i
        lda (line_ptr),y                     ; the next byte of the line
        cmp #line_end
        bcc write_char                       ; a letter
        sbc #line_end                        ; which command
        jsr pick_entry
        .word end_line                  ; line_end
        .word do_skip                   ; skip_ahead
        .word indent_row                ; line_in
        .word begin_clear               ; clear_text
        .word pause_line                ; wait_text
        .word line_pose                 ; start_picture
        .word line_picture              ; change_picture
        .word next_row                  ; new_line

; --- $8231  Put this letter on screen, with a blank above it.
write_char:
        jsr letter_tile
        ldx packet_i
        sta tile_buf+4,x                     ; the letter
        tya
        sta tile_buf+3,x                     ; the blank above it
        lda #$82                             ; two tiles, one below the other
        sta tile_buf,x
        lda line_at_hi                       ; where the letter goes
        sta tile_buf+2,x
        lda line_at
        sta tile_buf+1,x
        lda #$00                             ; end of the list, until the next letter
        sta tile_buf+5,x
        inc line_at                          ; the next space
        bne b825C
        inc line_at_hi
b825C:
        inc line_col                         ; one further along the row
        txa
        clc
        adc #$05                             ; the next letter is added after this one
        sta packet_i
        jsr hand_text
        lda line_speed                       ; frames between letters
        sta line_wait                        ; wait that long
        rts

; --- $8270  The line is over.
end_line:
        lda #$00
        sta line_on                          ; stop reading
        rts

; --- $8276  Skip ahead by the next number.
do_skip:
        ldy line_i
        lda (line_ptr),y
        inc line_i
        pha
        clc
        adc line_at                          ; move ahead by that many letters
        sta line_at
        bcc b828B
        inc line_at_hi
b828B:
        pla
        clc
        adc line_col                         ; and that far along the row
        sta line_col
        jmp read_char

; --- $8296  The next line.
next_row:
        lda #row_down                        ; down to the next line
        sec
        sbc line_col                         ; back to where the row started
        clc
        adc line_at
        sta line_at
        bcc b82A8
        inc line_at_hi
b82A8:
        lda #$00
        sta line_col                         ; the start of the row
        jmp read_char

; --- $82B0  Wait, then wipe the text box.
begin_clear:
        lda #$C0
        sta line_wait                        ; about three seconds
        lda line_speed                       ; keep the delay between letters
        sta speed_copy
        lda #$03
        sta line_speed
        lda #box_left
        sta wipe_col                         ; the left of the box
        lda #$01
        sta line_job                         ; wipe the box next
        rts

; --- $82CB  Wait about a second.
pause_line:
        lda #$3C
        sta line_wait                        ; about a second
        rts

; --- $82D1  Play this picture in that slot.
line_pose:
        ldy line_i
        lda (line_ptr),y
        inc line_i
        pha
        and #$C0                             ; which of the four pictures
        lsr
        lsr
        tax
        pla
        and #$3F                             ; which picture
        tay
        ora #$80                             ; its pose comes from a list
        sta actor_pic,x
        lda pose_time,y                      ; how long each pose stays
        sta actor_time,x
        lda #$00
        sta actor_pose,x                     ; the first pose
        jmp read_char

; --- $82F6  Show this one picture in that slot.
line_picture:
        ldy line_i
        lda (line_ptr),y
        inc line_i
        pha
        and #$C0                             ; which of the four pictures
        lsr
        lsr
        tax
        pla
        and #$3F                             ; which picture
        sta actor_pic,x
        jmp read_char

; --- $830D  The next line, one letter in.
indent_row:
        lda #row_down
        sec
        sbc line_col
        sec                                  ; one letter further in
        adc line_at
        sta line_at
        bcc b831F
        inc line_at_hi
b831F:
        lda #$00
        sta line_col                         ; the start of the row
        jmp read_char

; --- $8327  Blank one column of the text box.
clear_column:
        ldx packet_i
        lda #$88                             ; eight tiles, downward
        sta tile_buf,x
        lda wipe_col                         ; this column
        sta tile_buf+1,x
        lda #box_top                         ; the top of the box
        sta tile_buf+2,x
        lda #blank_tile                      ; blank
        sta tile_buf+3,x
        sta tile_buf+4,x
        sta tile_buf+5,x
        sta tile_buf+6,x
        sta tile_buf+7,x
        sta tile_buf+8,x
        sta tile_buf+9,x
        sta tile_buf+10,x
        lda #$00                             ; end of the list
        sta tile_buf+11,x
        txa
        clc
        adc #$0B                             ; the next column is added after this one
        sta packet_i
        ldx wipe_col
        inx
        cpx #$9D                             ; the right side of the box
        bcc b838F                            ; the box is not clear yet
        lda line_i
        clc
        adc line_ptr                         ; the rest of the line
        sta line_ptr
        bcc b8374
        inc line_ptr+1
b8374:
        lda #$00
        sta line_job                         ; read letters again
        sta line_col
        sta line_i
        lda #box_top                         ; back to the top left
        sta line_at_hi
        lda #box_left
        sta line_at
        lda speed_copy                       ; the delay between letters
        sta line_speed
b838F:
        stx wipe_col                         ; the next column
        jsr hand_text
        rts

; --- $8396  The tile for this letter.
letter_tile:
        cmp #$20
        bcc b83A0                            ; leave it
        cmp #$40
        bcs b83A0                            ; a letter stays as it is
        adc #$60                             ; a space or a mark
b83A0:
        ldy #blank_tile                      ; the blank above the letter
        rts

; --- $83A3  Hand the letters to the screen.
hand_text:
        lda tiles_handed
        bne b83B3                            ; already handed over this frame
        lda #$03
        sta $2C                              ; the letters are at $03C3
        lda #$C3
        sta z:packet                         ; the letters just written
        inc tiles_handed                     ; this frame's tiles are handed over
b83B3:
        rts

; --- $83B4  Point at that line, at the top left of the text box.
open_line:
        lda call_num                         ; which line
        asl
        tax
        lda line_list,x
        sta line_ptr
        lda line_list+1,x
        sta line_ptr+1
        ldy #$00
        sty line_i
        sty line_job
        sty line_wait
        sty line_col
        inc line_on                          ; the line is showing
        lda #box_top                         ; top left of the text box
        sta line_at_hi
        lda #box_left
        sta line_at
        rts

; --- $83DF  How many pixels to shift a sprite.
pixel_shift:
        .byte $E0, $E8, $F0, $F8, $00, $08, $10, $18, $D8, $20, $28, $30, $D0, $40, $C0, $B0
        .byte $B8, $38, $FC, $F2, $02, $04, $F7, $F1, $F6, $03, $F9, $01, $00, $00, $00, $00
        .byte $FC, $0C, $14, $1C, $24, $E6, $EC, $F4, $0C

; --- $8408  Which pictures a pose steps through.
pose_list:
        .word s8430
        .word s8433
        .word s8436
        .word s843F
        .word s8457
        .word s845A
        .word s845D
        .word s8460
        .word s8463
        .word s8466
        .word s846A
        .word s846D
        .word s8470
        .word s847A
        .word s847D
        .word s8487
        .word s848B
        .word s8490
        .word s849A
        .word s84A1

; Each list ends with $FF and then repeats.
s8430:
        .byte $08, $09, $FF

; Irene Lew.
s8433:
        .byte $17, $18, $FF

; Walter Smith.
s8436:
        .byte $19, $1A, $19, $19, $1A, $19, $1A, $1A, $FF
s843F:
        .byte $2C, $2C, $2C, $2D, $2D, $2D, $2D, $2E, $2E, $2E, $2E, $2E, $2E, $2E, $2E, $2E
        .byte $2E, $2E, $2E, $2E, $2E, $2E, $2E, $FF
s8457:
        .byte $30, $31, $FF
s845A:
        .byte $39, $3A, $FF
s845D:
        .byte $1F, $21, $FF
s8460:
        .byte $20, $21, $FF

; The Jaquio.
s8463:
        .byte $26, $27, $FF
s8466:
        .byte $34, $35, $4D, $FF

; Irene Lew.
s846A:
        .byte $23, $24, $FF
s846D:
        .byte $28, $29, $FF
s8470:
        .byte $46, $46, $46, $46, $47, $47, $48, $48, $47, $FF
s847A:
        .byte $57, $4D, $FF
s847D:
        .byte $58, $59, $5A, $5B, $5C, $5D, $62, $63, $64, $FF
s8487:
        .byte $62, $63, $64, $FF
s848B:
        .byte $65, $66, $67, $68, $FF
s8490:
        .byte $58, $59, $5A, $5B, $5C, $5D, $62, $63, $64, $FF
s849A:
        .byte $58, $59, $5D, $62, $63, $64, $FF
s84A1:
        .byte $58, $59, $5A, $5B, $5C, $5D, $62, $63, $64, $FF

; --- $84AB  Where a picture walks.
picture_path:
        .word s84AF
        .word s84B4

; Pairs of where it stands and how high. $FF starts the path over.
s84AF:
        .byte $74, $2A, $78, $2D, $FF
s84B4:
        .byte $08, $2A, $04, $2D, $FF

; --- $84B9  The pictures drawn as sprites.
; The first byte is the sprite tiles. Then groups of tiles.
; A byte at $80 or above ends the picture.
actor_pics:
        .word s858B
        .word s85A1
        .word s85AF
        .word s85C9
        .word s85E1
        .word s85FF
        .word s8617
        .word s8665
        .word s86B3
        .word s8705
        .word s8731
        .word s8745
        .word s8759
        .word s876F
        .word s878D
        .word s879B
        .word s87A5
        .word s87AF
        .word s87B9
        .word s87C3
        .word s87C9
        .word s87ED
        .word s8813
        .word s884D
        .word s885B
        .word s8869
        .word s8887
        .word s88A5
        .word s88CD
        .word s8901
        .word s894D
        .word s8967
        .word s8971
        .word s897B
        .word s8985
        .word s8987
        .word s89CD
        .word s8A13
        .word s8A59
        .word s8A73
        .word s8A8D
        .word s8AA9
        .word s8AC5
        .word s8B03
        .word s8B19
        .word s8B1F
        .word s8B27
        .word s8B3B
        .word s8B8B
        .word s8B91
        .word s8B97
        .word s8BB9
        .word s8C09
        .word s8C13
        .word s8C1D
        .word s8C27
        .word s8C61
        .word s8C97
        .word s8CBB
        .word s8CDF
        .word s8D09
        .word s8D2D
        .word s8D5B
        .word s8D65
        .word s8DB9
        .word s8DCB
        .word s8E1D
        .word s8E31
        .word s8E7B
        .word s8ECB
        .word s8F09
        .word s8F0F
        .word s8F15
        .word s8F1B
        .word s8F29
        .word s8F73
        .word s8FBD
        .word s8FF1
        .word s8FF3
        .word s9045
        .word s908F
        .word s90B1
        .word s90D3
        .word s90F5
        .word s9117
        .word s9139
        .word s915B
        .word s9165
        .word s916F
        .word s9175
        .word s917F
        .word s9187
        .word s9195
        .word s91A1
        .word s91B3
        .word s91C9
        .word s91DB
        .word s91EF
        .word s9209
        .word s9217
        .word s9229
        .word s9243
        .word s9263
        .word s9283
        .word s92A1
s858B:
        .byte $13, $03, $03, $00, $0A, $08, $1A, $20, $2A, $04, $03, $02, $0A, $0A, $1A, $22
        .byte $2A, $05, $01, $0C, $1A, $80
s85A1:
        .byte $13, $03, $02, $04, $10, $0E, $20, $04, $02, $06, $10, $24, $20, $80
s85AF:
        .byte $13, $02, $03, $10, $08, $18, $18, $32, $28, $03, $03, $12, $08, $1A, $18, $34
        .byte $28, $04, $03, $14, $08, $1C, $18, $36, $28, $80
s85C9:
        .byte $13, $03, $03, $16, $0A, $1E, $1A, $60, $2A, $04, $03, $40, $0A, $48, $1A, $62
        .byte $2A, $05, $02, $42, $0A, $4A, $1A, $80
s85E1:
        .byte $13, $02, $02, $18, $18, $32, $28, $03, $03, $44, $08, $1A, $18, $34, $28, $04
        .byte $03, $46, $08, $4C, $18, $36, $28, $05, $02, $50, $08, $4E, $18, $80
s85FF:
        .byte $13, $02, $01, $58, $22, $03, $03, $52, $12, $5A, $22, $64, $32, $04, $02, $54
        .byte $12, $5C, $22, $05, $01, $56, $12, $80
s8617:
        .byte $1E, $08, $01, $36, $03, $00, $01, $34, $03, $01, $03, $32, $01, $3A, $15, $46
        .byte $23, $02, $04, $30, $01, $4E, $15, $44, $23, $4C, $33, $03, $06, $52, $05, $18
        .byte $17, $5A, $15, $42, $23, $4A, $33, $62, $4B, $04, $05, $50, $05, $58, $11, $40
        .byte $23, $48, $33, $60, $4B, $05, $05, $22, $01, $2A, $11, $FC, $23, $1E, $33, $3E
        .byte $4B, $06, $05, $20, $03, $28, $13, $FC, $23, $1C, $33, $3C, $4B, $80
s8665:
        .byte $1E, $09, $01, $36, $02, $07, $01, $34, $02, $06, $03, $32, $00, $3A, $14, $46
        .byte $22, $05, $04, $30, $00, $38, $14, $44, $22, $4C, $32, $04, $06, $26, $04, $1A
        .byte $16, $2E, $14, $42, $22, $4A, $32, $62, $4A, $03, $05, $24, $04, $2C, $10, $40
        .byte $22, $48, $32, $60, $4A, $02, $05, $22, $00, $2A, $10, $FC, $22, $1E, $32, $3E
        .byte $4A, $01, $05, $20, $02, $28, $12, $FC, $22, $1C, $32, $3C, $4A, $80
s86B3:
        .byte $1C, $00, $02, $00, $10, $08, $20, $01, $02, $02, $10, $0A, $20, $02, $02, $04
        .byte $10, $0C, $20, $03, $03, $06, $10, $0E, $20, $20, $30, $20, $01, $36, $48, $04
        .byte $02, $10, $10, $22, $30, $05, $01, $12, $10, $06, $01, $14, $10, $07, $01, $16
        .byte $10, $21, $01, $18, $20, $22, $01, $1A, $20, $23, $01, $1C, $20, $24, $01, $1E
        .byte $20, $09, $02, $24, $30, $32, $48, $0A, $02, $26, $30, $34, $48, $0B, $01, $30
        .byte $30, $80
s8705:
        .byte $1C, $02, $02, $28, $10, $38, $20, $03, $02, $2A, $10, $3A, $20, $04, $02, $2C
        .byte $10, $3C, $20, $05, $04, $2E, $10, $3E, $20, $68, $30, $60, $48, $06, $03, $40
        .byte $20, $48, $30, $62, $48, $07, $02, $42, $20, $4A, $30, $80
s8731:
        .byte $1E, $02, $01, $72, $18, $03, $03, $7A, $0C, $74, $18, $7C, $2C, $04, $02, $76
        .byte $1A, $7E, $2C, $80
s8745:
        .byte $1E, $02, $02, $64, $18, $6C, $28, $03, $02, $66, $1C, $6E, $2C, $04, $02, $70
        .byte $1A, $78, $2A, $80
s8759:
        .byte $1E, $01, $01, $80, $26, $02, $01, $82, $26, $03, $01, $84, $26, $04, $01, $86
        .byte $26, $05, $01, $90, $26, $80
s876F:
        .byte $14, $01, $01, $90, $30, $02, $01, $92, $30, $03, $01, $98, $30, $04, $01, $9A
        .byte $30, $04, $01, $38, $10, $06, $01, $3A, $20, $07, $01, $3C, $20, $80
s878D:
        .byte $14, $03, $02, $35, $10, $61, $20, $04, $02, $37, $10, $63, $20, $80
s879B:
        .byte $15, $03, $01, $37, $27, $04, $01, $35, $27, $80
s87A5:
        .byte $15, $03, $01, $5F, $27, $04, $01, $5D, $27, $80
s87AF:
        .byte $15, $03, $01, $9D, $26, $04, $01, $9F, $26, $80
s87B9:
        .byte $15, $03, $01, $8B, $27, $04, $01, $89, $27, $80
s87C3:
        .byte $1A, $12, $01, $6B, $1E, $80
s87C9:
        .byte $10, $04, $10, $FE, $60, $FE, $60, $FE, $60, $FE, $60, $FE, $60, $FE, $60, $FE
        .byte $60, $FE, $60, $FE, $48, $FE, $48, $FE, $48, $FE, $48, $FE, $48, $FE, $48, $FE
        .byte $48, $FE, $48, $80
s87ED:
        .byte $1E, $02, $01, $08, $30, $03, $03, $0E, $22, $00, $18, $0A, $30, $04, $04, $10
        .byte $22, $16, $34, $02, $18, $14, $32, $05, $04, $12, $22, $0C, $30, $04, $18, $06
        .byte $28, $06, $01, $08, $31, $80
s8813:
        .byte $15, $00, $01, $B0, $30, $01, $01, $B2, $30, $02, $04, $C0, $00, $C8, $10, $A0
        .byte $22, $B4, $30, $03, $04, $C2, $00, $FE, $10, $A2, $22, $B6, $30, $04, $04, $C4
        .byte $00, $FE, $10, $A4, $22, $E0, $30, $05, $04, $C6, $00, $CA, $10, $A6, $22, $E2
        .byte $30, $06, $01, $CC, $30, $07, $01, $CE, $30, $80

; Irene Lew.
s884D:
        .byte $13, $03, $02, $5F, $16, $67, $36, $04, $02, $71, $36, $73, $32, $80

; Irene Lew.
s885B:
        .byte $13, $03, $02, $5F, $16, $75, $36, $04, $02, $77, $36, $7F, $32, $80

; Walter Smith.
s8869:
        .byte $14, $01, $02, $C0, $20, $70, $30, $02, $02, $C2, $20, $D2, $30, $03, $02, $C4
        .byte $20, $D4, $30, $04, $02, $C6, $20, $D6, $30, $05, $01, $D0, $20, $80

; Walter Smith.
s8887:
        .byte $14, $01, $02, $C8, $20, $70, $30, $02, $02, $CA, $20, $DA, $30, $03, $02, $CC
        .byte $20, $DC, $30, $04, $02, $CE, $20, $DE, $30, $05, $01, $D8, $20, $80
s88A5:
        .byte $12, $01, $02, $B8, $20, $E0, $30, $02, $03, $A8, $10, $BA, $20, $EC, $30, $03
        .byte $03, $AA, $10, $BC, $20, $EE, $30, $04, $02, $AC, $10, $BE, $20, $05, $02, $AE
        .byte $10, $E8, $20, $06, $01, $EA, $22, $80
s88CD:
        .byte $12, $04, $18, $FE, $08, $FE, $08, $FE, $08, $FE, $08, $FE, $08, $FE, $08, $FE
        .byte $08, $FE, $08, $FE, $18, $FE, $18, $FE, $18, $FE, $18, $FE, $18, $FE, $18, $FE
        .byte $18, $FE, $18, $FE, $28, $FE, $28, $FE, $28, $FE, $28, $FE, $28, $FE, $28, $FE
        .byte $28, $FE, $28, $80
s8901:
        .byte $17, $00, $03, $42, $1A, $4A, $2A, $62, $3A, $01, $04, $10, $10, $44, $1A, $4C
        .byte $2A, $64, $3A, $02, $06, $12, $00, $1A, $10, $46, $22, $32, $20, $50, $32, $3A
        .byte $30, $03, $04, $14, $00, $1C, $10, $34, $20, $3C, $30, $04, $05, $52, $0A, $16
        .byte $00, $1E, $10, $36, $20, $3C, $30, $05, $04, $54, $0A, $40, $00, $48, $10, $60
        .byte $20, $06, $02, $68, $20, $FC, $34, $0A, $01, $56, $32, $80
s894D:
        .byte $14, $10, $01, $F6, $20, $0E, $01, $EC, $20, $03, $01, $F6, $20, $04, $01, $EC
        .byte $20, $11, $01, $F6, $20, $0D, $01, $EC, $20, $80
s8967:
        .byte $18, $03, $01, $66, $20, $04, $01, $70, $20, $80
s8971:
        .byte $18, $03, $01, $3E, $20, $04, $01, $68, $20, $80
s897B:
        .byte $18, $03, $01, $6A, $20, $04, $01, $6C, $20, $80
s8985:
        .byte $1F, $80

; Irene Lew.
s8987:
        .byte $1F, $01, $02, $28, $00, $80, $12, $02, $04, $2A, $00, $D8, $12, $8A, $22, $A2
        .byte $32, $12, $01, $E2, $2C, $03, $04, $2C, $00, $DA, $12, $8C, $22, $A4, $32, $04
        .byte $04, $2E, $00, $DC, $12, $8E, $22, $A6, $32, $05, $05, $38, $00, $DE, $12, $98
        .byte $22, $B2, $34, $B0, $32, $06, $04, $3A, $00, $92, $12, $9A, $22, $A0, $32, $07
        .byte $02, $3C, $00, $94, $12, $80

; Irene Lew.
s89CD:
        .byte $1F, $01, $02, $28, $00, $80, $12, $02, $04, $2A, $00, $D8, $12, $8A, $22, $A2
        .byte $32, $12, $01, $E4, $2C, $03, $04, $2C, $00, $DA, $12, $8C, $22, $A4, $32, $04
        .byte $04, $2E, $00, $DC, $12, $8E, $22, $A6, $32, $05, $05, $38, $00, $DE, $12, $98
        .byte $22, $B2, $34, $B0, $32, $06, $04, $3A, $00, $92, $12, $9A, $22, $A0, $32, $07
        .byte $02, $3C, $00, $94, $12, $80
s8A13:
        .byte $1F, $01, $02, $28, $00, $80, $12, $02, $04, $2A, $00, $D8, $12, $8A, $22, $A2
        .byte $32, $12, $01, $E6, $2C, $03, $04, $2C, $00, $DA, $12, $8C, $22, $A4, $32, $04
        .byte $04, $2E, $00, $DC, $12, $8E, $22, $A6, $32, $05, $05, $38, $00, $DE, $12, $98
        .byte $22, $B2, $34, $B0, $32, $06, $04, $3A, $00, $92, $12, $9A, $22, $A0, $32, $07
        .byte $02, $3C, $00, $94, $12, $80

; The Jaquio.
s8A59:
        .byte $18, $02, $02, $C0, $20, $C8, $30, $03, $02, $C2, $20, $CA, $30, $04, $02, $C4
        .byte $20, $CC, $30, $05, $02, $C6, $20, $CE, $30, $80

; The Jaquio.
s8A73:
        .byte $18, $02, $02, $D0, $20, $D8, $30, $03, $02, $D2, $20, $DA, $30, $04, $02, $D4
        .byte $20, $DC, $30, $05, $02, $D6, $20, $DE, $30, $80
s8A8D:
        .byte $17, $01, $01, $DC, $10, $02, $02, $DE, $10, $E4, $30, $03, $01, $E6, $30, $04
        .byte $01, $EC, $30, $05, $01, $F4, $10, $06, $01, $F6, $10, $80
s8AA9:
        .byte $17, $01, $01, $DC, $10, $02, $02, $DE, $10, $F0, $30, $03, $01, $F2, $30, $04
        .byte $01, $EE, $30, $05, $01, $F4, $10, $06, $01, $F6, $10, $80
s8AC5:
        .byte $15, $01, $02, $AE, $22, $EC, $32, $02, $02, $B8, $22, $FA, $32, $1A, $01, $F0
        .byte $16, $1B, $01, $F2, $16, $12, $01, $F4, $26, $03, $03, $A8, $10, $BA, $24, $EE
        .byte $34, $04, $03, $AA, $10, $BC, $24, $E4, $34, $05, $03, $AC, $10, $BE, $24, $FA
        .byte $32, $06, $02, $E8, $22, $FA, $32, $07, $02, $EA, $22, $E6, $32, $80
s8B03:
        .byte $17, $02, $01, $A0, $22, $03, $01, $A2, $22, $04, $01, $A4, $22, $05, $01, $A6
        .byte $22, $06, $01, $B0, $22, $80
s8B19:
        .byte $17, $04, $01, $C8, $20, $80
s8B1F:
        .byte $17, $04, $02, $C0, $10, $C8, $20, $80
s8B27:
        .byte $17, $03, $02, $C2, $10, $CA, $20, $04, $02, $C4, $10, $CC, $20, $05, $02, $C6
        .byte $10, $CE, $20, $80
s8B3B:
        .byte $19, $00, $01, $1A, $4A, $01, $02, $14, $32, $1C, $4A, $02, $04, $0E, $10, $26
        .byte $20, $16, $32, $1E, $4A, $13, $01, $10, $02, $03, $05, $00, $64, $08, $00, $20
        .byte $10, $40, $32, $48, $4A, $04, $05, $02, $60, $0A, $00, $22, $10, $42, $32, $4A
        .byte $4A, $14, $01, $12, $20, $15, $01, $18, $42, $05, $05, $0C, $00, $24, $10, $30
        .byte $12, $44, $32, $4C, $4A, $06, $02, $46, $32, $4E, $4A, $07, $01, $32, $4A, $80
s8B8B:
        .byte $19, $05, $01, $04, $60, $80
s8B91:
        .byte $19, $05, $01, $06, $60, $80
s8B97:
        .byte $1B, $00, $01, $78, $26, $01, $01, $7A, $26, $02, $01, $7C, $26, $03, $01, $7E
        .byte $26, $04, $01, $D0, $26, $05, $01, $D2, $26, $06, $01, $D4, $26, $07, $01, $D6
        .byte $26, $80
s8BB9:
        .byte $1A, $08, $01, $BE, $30, $00, $02, $B6, $20, $E8, $30, $01, $02, $E0, $20, $EA
        .byte $32, $02, $02, $E2, $20, $EC, $32, $03, $04, $A0, $00, $A8, $10, $E4, $22, $EE
        .byte $36, $04, $04, $A2, $00, $AA, $10, $E6, $24, $CC, $34, $05, $04, $A4, $00, $AC
        .byte $12, $F0, $24, $FA, $34, $06, $05, $A6, $00, $CA, $16, $AE, $12, $F2, $24, $F6
        .byte $34, $07, $03, $B0, $00, $B8, $14, $F4, $20, $09, $02, $B2, $00, $BA, $14, $80
s8C09:
        .byte $1D, $03, $01, $20, $18, $04, $01, $20, $19, $80
s8C13:
        .byte $1D, $03, $01, $22, $18, $04, $01, $22, $19, $80
s8C1D:
        .byte $1A, $03, $01, $C3, $1E, $04, $01, $C3, $1F, $80
s8C27:
        .byte $1A, $01, $02, $C4, $22, $CE, $32, $16, $01, $6B, $34, $02, $02, $C6, $22, $FE
        .byte $32, $03, $04, $B4, $00, $BC, $10, $D0, $22, $D8, $32, $04, $04, $7A, $00, $FE
        .byte $10, $D2, $22, $DA, $32, $05, $04, $74, $00, $7C, $14, $D4, $22, $DC, $34, $06
        .byte $04, $76, $00, $7E, $12, $D6, $22, $DE, $34, $80
s8C61:
        .byte $18, $17, $01, $EC, $30, $02, $02, $BA, $22, $E0, $32, $03, $03, $EE, $20, $BC
        .byte $22, $E2, $32, $04, $04, $AA, $10, $F4, $20, $BE, $22, $E4, $32, $05, $03, $AC
        .byte $10, $E8, $22, $E6, $32, $06, $03, $AE, $10, $EA, $24, $F0, $34, $07, $03, $B8
        .byte $10, $F6, $30, $F2, $34, $80
s8C97:
        .byte $1F, $02, $01, $82, $14, $03, $01, $84, $14, $12, $01, $B6, $28, $18, $01, $9E
        .byte $20, $19, $01, $C8, $20, $05, $02, $90, $14, $B2, $30, $06, $01, $D0, $32, $07
        .byte $01, $D2, $32, $80
s8CBB:
        .byte $1F, $02, $01, $82, $14, $03, $01, $84, $14, $12, $01, $B4, $28, $18, $01, $9E
        .byte $20, $19, $01, $C8, $20, $05, $02, $90, $14, $B2, $30, $06, $01, $D0, $32, $07
        .byte $01, $D2, $32, $80
s8CDF:
        .byte $1F, $04, $04, $FA, $00, $FA, $10, $FA, $20, $FA, $30, $05, $04, $FA, $00, $FA
        .byte $10, $FA, $20, $FA, $30, $06, $04, $FA, $00, $FA, $10, $FA, $20, $FA, $30, $07
        .byte $04, $FA, $00, $FA, $10, $FA, $20, $FA, $30, $80
s8D09:
        .byte $1F, $02, $01, $D4, $14, $03, $01, $D6, $14, $12, $01, $E0, $28, $18, $01, $CA
        .byte $20, $19, $01, $CC, $20, $05, $02, $CE, $14, $B2, $30, $06, $01, $D0, $32, $07
        .byte $01, $D2, $32, $80
s8D2D:
        .byte $17, $02, $03, $08, $10, $20, $20, $28, $30, $03, $04, $00, $00, $0A, $10, $22
        .byte $20, $2A, $30, $04, $04, $02, $00, $0C, $10, $24, $20, $2C, $30, $05, $03, $0E
        .byte $10, $26, $20, $2E, $30, $06, $03, $18, $10, $30, $20, $38, $30, $80
s8D5B:
        .byte $17, $03, $01, $04, $22, $04, $01, $06, $22, $80
s8D65:
        .byte $19, $01, $01, $1A, $5A, $02, $03, $58, $18, $14, $4A, $1C, $5A, $17, $01, $56
        .byte $0A, $03, $06, $34, $04, $54, $10, $5A, $20, $76, $30, $16, $4A, $1E, $5A, $04
        .byte $08, $36, $00, $60, $02, $50, $10, $52, $12, $5E, $2C, $5C, $20, $40, $4A, $48
        .byte $5A, $05, $08, $62, $02, $64, $10, $66, $12, $70, $20, $72, $22, $74, $32, $42
        .byte $4A, $4A, $5A, $06, $02, $44, $4A, $4C, $5A, $07, $02, $46, $4A, $4E, $5A, $09
        .byte $01, $32, $5A, $80
s8DB9:
        .byte $1A, $01, $01, $C0, $20, $03, $01, $9E, $32, $04, $01, $C8, $32, $06, $01, $C2
        .byte $20, $80
s8DCB:
        .byte $19, $0F, $01, $AE, $00, $0E, $01, $B8, $10, $00, $01, $EE, $30, $01, $01, $BA
        .byte $20, $02, $01, $BC, $20, $03, $01, $BE, $20, $04, $03, $B0, $10, $E8, $20, $B4
        .byte $30, $05, $02, $B2, $10, $EA, $20, $06, $02, $EC, $20, $E4, $30, $07, $02, $CA
        .byte $10, $E6, $30, $09, $03, $DA, $00, $CC, $10, $F0, $30, $0A, $04, $DC, $00, $CE
        .byte $10, $C8, $20, $F2, $30, $0B, $03, $DE, $00, $D8, $10, $F4, $30, $11, $01, $F6
        .byte $30, $80
s8E1D:
        .byte $1B, $03, $02, $D8, $10, $F0, $20, $04, $02, $DA, $10, $F2, $20, $05, $02, $DC
        .byte $10, $F4, $20, $80
s8E31:
        .byte $1D, $00, $02, $40, $00, $48, $12, $01, $03, $42, $00, $4A, $12, $62, $22, $02
        .byte $04, $44, $00, $4C, $12, $64, $22, $6C, $32, $03, $04, $46, $00, $4E, $12, $66
        .byte $22, $6E, $32, $04, $04, $50, $00, $58, $12, $70, $22, $78, $32, $05, $04, $52
        .byte $00, $5A, $12, $72, $22, $7A, $32, $06, $04, $54, $00, $5C, $12, $74, $22, $7C
        .byte $32, $07, $03, $56, $00, $5E, $12, $7E, $32, $80
s8E7B:
        .byte $1D, $08, $01, $16, $32, $00, $03, $40, $00, $48, $12, $1E, $34, $01, $03, $42
        .byte $00, $4A, $12, $62, $22, $02, $04, $44, $00, $4C, $12, $64, $22, $6C, $32, $03
        .byte $04, $46, $00, $4E, $12, $66, $22, $6E, $32, $04, $04, $50, $00, $58, $12, $70
        .byte $22, $78, $32, $05, $04, $52, $00, $5A, $12, $72, $22, $7A, $32, $06, $04, $54
        .byte $00, $5C, $12, $74, $22, $7C, $32, $07, $03, $56, $00, $5E, $12, $7E, $32, $80
s8ECB:
        .byte $19, $01, $04, $CD, $10, $E5, $20, $CB, $22, $ED, $30, $02, $05, $C7, $00, $CF
        .byte $10, $FD, $12, $E7, $22, $EF, $32, $03, $04, $D1, $00, $D9, $12, $F1, $22, $C5
        .byte $32, $04, $03, $DB, $10, $F3, $22, $FB, $30, $05, $05, $D5, $00, $DD, $10, $F5
        .byte $22, $D3, $30, $D7, $32, $06, $03, $DF, $10, $F7, $20, $C9, $30, $80
s8F09:
        .byte $19, $04, $01, $B6, $24, $80
s8F0F:
        .byte $19, $04, $01, $E0, $24, $80
s8F15:
        .byte $19, $04, $01, $E2, $24, $80
s8F1B:
        .byte $1F, $03, $01, $43, $00, $04, $01, $45, $10, $05, $01, $47, $10, $80
s8F29:
        .byte $1D, $00, $04, $28, $00, $80, $12, $88, $22, $A0, $32, $01, $04, $2A, $00, $82
        .byte $12, $8A, $22, $A2, $32, $02, $04, $2C, $00, $84, $12, $8C, $22, $A4, $32, $03
        .byte $04, $2E, $00, $86, $12, $8E, $22, $A6, $32, $04, $04, $38, $00, $90, $12, $98
        .byte $22, $B0, $32, $05, $04, $3A, $00, $92, $12, $9A, $22, $B2, $32, $06, $03, $3C
        .byte $00, $94, $12, $9C, $22, $07, $01, $96, $12, $80
s8F73:
        .byte $1D, $00, $04, $28, $00, $80, $12, $88, $22, $A0, $32, $01, $04, $2A, $00, $82
        .byte $12, $8A, $22, $A2, $32, $02, $04, $2C, $00, $84, $12, $24, $22, $A4, $32, $03
        .byte $04, $2E, $00, $86, $12, $26, $22, $A6, $32, $04, $04, $38, $00, $90, $12, $30
        .byte $22, $B0, $32, $05, $04, $3A, $00, $92, $12, $32, $22, $B2, $32, $06, $03, $3C
        .byte $00, $94, $12, $9C, $22, $07, $01, $96, $12, $80
s8FBD:
        .byte $17, $02, $04, $FA, $00, $FA, $10, $FA, $20, $FA, $30, $03, $04, $FA, $00, $FA
        .byte $10, $FA, $20, $FA, $30, $04, $04, $FA, $00, $FA, $10, $FA, $20, $FA, $30, $05
        .byte $04, $FA, $00, $FA, $10, $FA, $20, $FA, $30, $06, $04, $FA, $00, $FA, $10, $FA
        .byte $20, $FA, $30, $80
s8FF1:
        .byte $11, $80
s8FF3:
        .byte $12, $00, $04, $20, $00, $28, $10, $30, $20, $2A, $30, $01, $04, $22, $00, $FC
        .byte $10, $FC, $20, $2C, $30, $02, $04, $24, $00, $FC, $10, $FC, $20, $2E, $30, $03
        .byte $04, $26, $00, $FC, $10, $FC, $20, $38, $30, $04, $04, $26, $01, $FC, $10, $FC
        .byte $20, $38, $31, $05, $04, $24, $01, $FC, $10, $FC, $20, $2E, $31, $06, $04, $22
        .byte $01, $FC, $10, $FC, $20, $2C, $31, $07, $04, $20, $01, $28, $11, $30, $21, $2A
        .byte $31, $80
s9045:
        .byte $1D, $00, $02, $40, $00, $48, $12, $01, $03, $42, $00, $4A, $12, $62, $22, $02
        .byte $04, $44, $00, $4C, $12, $F4, $22, $F6, $32, $03, $04, $46, $00, $4E, $12, $66
        .byte $22, $6E, $32, $04, $04, $50, $00, $58, $12, $70, $22, $78, $32, $05, $04, $52
        .byte $00, $5A, $12, $72, $22, $7A, $32, $06, $04, $54, $00, $5C, $12, $74, $22, $7C
        .byte $32, $07, $03, $56, $00, $5E, $12, $7E, $32, $80
s908F:
        .byte $11, $00, $01, $80, $18, $01, $01, $82, $18, $02, $01, $84, $18, $03, $01, $86
        .byte $18, $04, $01, $88, $18, $05, $01, $8A, $18, $06, $01, $8C, $18, $07, $01, $8E
        .byte $18, $80
s90B1:
        .byte $11, $00, $01, $80, $18, $01, $01, $82, $18, $02, $01, $84, $18, $03, $01, $86
        .byte $18, $04, $01, $88, $18, $05, $01, $8A, $18, $06, $01, $A0, $18, $07, $01, $A2
        .byte $18, $80
s90D3:
        .byte $11, $00, $01, $80, $18, $01, $01, $82, $18, $02, $01, $84, $18, $03, $01, $86
        .byte $18, $04, $01, $88, $18, $05, $01, $8A, $18, $06, $01, $A4, $18, $07, $01, $A6
        .byte $18, $80
s90F5:
        .byte $11, $00, $01, $80, $18, $01, $01, $82, $18, $02, $01, $84, $18, $03, $01, $86
        .byte $18, $04, $01, $88, $18, $05, $01, $8A, $18, $06, $01, $A8, $18, $07, $01, $AA
        .byte $18, $80
s9117:
        .byte $11, $00, $01, $80, $18, $01, $01, $82, $18, $02, $01, $84, $18, $03, $01, $86
        .byte $18, $04, $01, $88, $18, $05, $01, $8A, $18, $06, $01, $AC, $18, $07, $01, $AE
        .byte $18, $80
s9139:
        .byte $11, $00, $01, $80, $18, $01, $01, $82, $18, $02, $01, $84, $18, $03, $01, $86
        .byte $18, $04, $01, $88, $18, $05, $01, $8A, $18, $06, $01, $F4, $18, $07, $01, $F6
        .byte $18, $80
s915B:
        .byte $10, $04, $01, $DD, $22, $05, $01, $DF, $22, $80
s9165:
        .byte $12, $25, $01, $E2, $10, $22, $01, $E2, $10, $80
s916F:
        .byte $11, $12, $01, $9C, $22, $80
s9175:
        .byte $11, $03, $01, $9E, $22, $04, $01, $C0, $22, $80
s917F:
        .byte $11, $12, $02, $C2, $12, $C8, $22, $80
s9187:
        .byte $11, $03, $02, $CA, $12, $C6, $22, $04, $02, $C4, $12, $CC, $22, $80
s9195:
        .byte $11, $03, $02, $CE, $14, $B0, $24, $04, $01, $B2, $24, $80
s91A1:
        .byte $11, $02, $01, $B4, $24, $03, $01, $B6, $24, $04, $01, $B8, $24, $05, $01, $BA
        .byte $24, $80
s91B3:
        .byte $11, $03, $04, $75, $00, $7D, $10, $6D, $20, $BC, $30, $04, $04, $77, $00, $7F
        .byte $10, $6F, $20, $BE, $30, $80
s91C9:
        .byte $11, $03, $03, $69, $00, $51, $10, $90, $20, $04, $03, $D0, $00, $53, $10, $92
        .byte $20, $80
s91DB:
        .byte $11, $03, $04, $65, $00, $71, $10, $79, $20, $98, $30, $04, $03, $73, $10, $7B
        .byte $20, $9A, $30, $80
s91EF:
        .byte $11, $03, $05, $45, $00, $4D, $10, $55, $20, $5D, $30, $94, $48, $04, $05, $47
        .byte $00, $4F, $10, $57, $20, $5F, $30, $96, $48, $80
s9209:
        .byte $11, $27, $01, $D2, $26, $12, $01, $D4, $26, $15, $01, $D6, $26, $80
s9217:
        .byte $11, $02, $01, $D8, $26, $03, $01, $DA, $26, $04, $01, $E0, $26, $05, $01, $E2
        .byte $26, $80
s9229:
        .byte $11, $02, $02, $E4, $16, $E8, $26, $03, $02, $E6, $16, $EA, $26, $04, $02, $EC
        .byte $16, $F0, $26, $05, $02, $EE, $16, $F2, $26, $80
s9243:
        .byte $11, $00, $02, $9C, $02, $9E, $1A, $01, $01, $C0, $1A, $03, $02, $9C, $62, $9E
        .byte $0A, $04, $02, $C0, $0A, $9C, $22, $06, $01, $9E, $2A, $07, $01, $C0, $2A, $80
s9263:
        .byte $11, $00, $02, $9E, $12, $9C, $2A, $01, $01, $C0, $12, $02, $01, $9C, $02, $03
        .byte $01, $9E, $1A, $04, $01, $C0, $1A, $05, $01, $9C, $32, $06, $01, $9C, $0A, $80
s9283:
        .byte $11, $00, $01, $9E, $2A, $01, $01, $C0, $2A, $02, $03, $9C, $62, $9E, $0A, $9C
        .byte $32, $03, $01, $C0, $0A, $04, $01, $9C, $2A, $06, $01, $9C, $22, $80
s92A1:
        .byte $11, $00, $01, $9C, $2A, $01, $01, $9C, $02, $02, $01, $9E, $22, $03, $02, $9E
        .byte $42, $C0, $22, $04, $02, $C0, $42, $9E, $2A, $05, $01, $C0, $2A, $07, $01, $9C
        .byte $12, $80

; --- $92C3  How long each pose stays.
; The high half is reloaded when the low half runs out.
pose_time:
        .byte $44, $33, $33, $FF, $33, $22, $55, $33, $55, $22, $33, $55, $AA

; --- $92D0  The lines spoken in the cutscenes.
line_list:
        .word t93B2
        .word t9421
        .word t94A9
        .word t9542
        .word t955C
        .word t9575
        .word t95A7
        .word t95B5
        .word t95D6
        .word t9603
        .word t964C
        .word t965C
        .word t96A0
        .word t96DF
        .word t9766
        .word t9815
        .word t9826
        .word t9860
        .word t9923
        .word t99DF
        .word t9ABE
        .word t9B38
        .word t9BCF
        .word t9C3D
        .word t9C61
        .word t9C73
        .word t9C89
        .word t9CDD
        .word t9CEB
        .word t9D20
        .word t9D36
        .word t9EA2
        .word t9EA8
        .word t9EB8
        .word t9EE9
        .word t9F29
        .word t9F49
        .word t9F77
        .word t9FB4
        .word tA0D7
        .word tA1D4
        .word tA280
        .word tA37D
        .word tA3D2
        .word tA45F
        .word tA46E
        .word tA48D
        .word tA4DD
        .word tA4E3
        .word tA515
        .word tA51C
        .word tA531
        .word tA551
        .word tA591
        .word tA5CE
        .word tA60E
        .word tA6AF
        .word tA5B7
        .word tA6CB
        .word tA6F5
        .word tA70F
        .word tA755
        .word tA76B
        .word tA78D
        .word tA85A
        .word tA8E2
        .word tA911
        .word tA91A
        .word tA963
        .word tA9AF
        .word tA9C2
        .word tA9EB
        .word tAA31
        .word tAAA3
        .word tAAD1
        .word tAB18
        .word tAB2C
        .word tAB3A
        .word tAB53
        .word tAB60
        .word tAB7B
        .word tABB3
        .word tABD0
        .word tACE3
        .word tACFB
        .word tAD07
        .word tAD12
        .word tAD2B
        .word tAD99
        .word tADE6
        .word tAE2F
        .word tAE3D
        .word tAE86
        .word tAEA7
        .word tAEB8
        .word tAF14
        .word tAF50
        .word tAF98
        .word tAFB8
        .word tAFD7
        .word tB0A1
        .word tB0B5
        .word tB123
        .word tB12F
        .word tB142
        .word tB15F
        .word tB176
        .word tB1BD
        .word tB1E8
        .word tB21C
        .word tB245
        .word tB25B
        .word tB2A2

.charmap $27, $25                       ; apostrophe
t93B2:
        .byte "With whom did father", new_line
        .byte "have a duel and lose?..", new_line
        .byte "For what reason did he", new_line
        .byte "fight and die?"
        .byte clear_text

        .byte "Even I don't know for", new_line
        .byte "sure.", line_end
t9421:
        .byte "The day after he", new_line
        .byte "disappeared, in father's", new_line
        .byte "room I found a letter", new_line
        .byte "addressed to me."
        .byte clear_text

        .byte "It said,", new_line
        .byte '"', "Ryu, I am on my way to"
        .byte line_in, "a life or death duel.", line_end
t94A9:
        .byte '"', "If it is destiny that I"
        .byte line_in, "not return, you are to", new_line
        .byte "take the Dragon sword", new_line
        .byte "of the Hayabusa family"
        .byte clear_text

        .byte '"', "and go to America and"
        .byte line_in, "see the archaeologist,", new_line
        .byte "Walter Smith.", line_end
t9542:
        .byte '"', "Ryu, be always brave...", '"', line_end
t955C:
        .byte '"', "I will get my revenge!", '"', line_end
t9575:
        .byte '"', "Who are they..."
        .byte line_in, "They seem to be", new_line
        .byte "following me...", '"', line_end
t95A7:
        .byte '"', "Who's there?", line_end
t95B5:
        .byte clear_text

        .byte '"', "Just a girl."
        .byte line_in, "Get out of here!", '"', line_end
t95D6:
        .byte '"', "I will, but first...", '"', new_line
        .byte wait_text, wait_text, new_line
        .byte '"', "What the .... ?!", '"', line_end
t9603:
        .byte '"', "Ow... ", wait_text, "Where... ", wait_text, new_line
        .byte " Where am I?", '"', new_line
        .byte wait_text, '"', "I see the anesthetic is"
        .byte line_in, "wearing off.", '"', line_end
t964C:
        .byte '"', "Who are you?!", '"', line_end
t965C:
        .byte '"', "Shhh. Don't make so"
        .byte line_in, "much noise...", new_line
        .byte "I've got a favor to ask", new_line
        .byte "of you.", '"', line_end
t96A0:
        .byte '"', "Here. Take this and", new_line
        .byte " escape.", '"', new_line
        .byte '"', "What is this ..."
        .byte line_in, "this statue?", '"', line_end
t96DF:
        .byte start_picture, $01, '"', "There's no time to", new_line
        .byte " explain. Hurry.", '"', change_picture, $17, new_line
        .byte wait_text, '"', "Hey, wait. Who are you?", wait_text
        .byte clear_text

        .byte '"', "Didn't you try to kill"
        .byte line_in, "me?", '"', wait_text
        .byte clear_text

        .byte start_picture, $01, '"', "Someone's coming."
        .byte line_in, "Be careful.", '"', change_picture, $17, line_end
t9766:
        .byte '"', "What is this bizarre"
        .byte line_in, "statue anyway?", new_line
        .byte "And who was that woman?", '"'
        .byte clear_text

        .byte "As I grew more and more", new_line
        .byte "suspicious, I went off", new_line
        .byte "to look for that"
        .byte clear_text

        .byte "supposed acquaintance", new_line
        .byte "of my father's, Mr.", new_line
        .byte "Smith.", line_end
t9815:
        .byte start_picture, $02, '"', "Who is it?", '"', change_picture, $19, line_end
t9826:
        .byte '"', "You must be"
        .byte line_in, "Walter Smith.", new_line
        .byte "The name's Ryu,", new_line
        .byte "Ryu Hayabusa.", '"', line_end
t9860:
        .byte start_picture, $02, '"', "Who? That sword,..."
        .byte line_in, change_picture, $19, wait_text, start_picture, $02, "Of course. You must be", new_line
        .byte "Ken Hayabusa's son.", '"', change_picture, $19
        .byte clear_text

        .byte '"', "In his last letter,"
        .byte line_in, "my father told me", new_line
        .byte "I should see you.", '"'
        .byte clear_text

        .byte start_picture, $02, '"', "Last letter?", change_picture, $19, wait_text, start_picture, $02, " I see ..."
        .byte line_in, change_picture, $19, wait_text, start_picture, $02, "So it is already begun.", '"', change_picture, $19, line_end
t9923:
        .byte start_picture, $02, '"', "Ken and I were on an"
        .byte line_in, "expedition to some old", new_line
        .byte "Amazon ruins.", change_picture, $19
        .byte clear_text

        .byte start_picture, $02, '"', "We found a strange"
        .byte line_in, "statue and stone tablet.", new_line
        .byte "On the tablet, it said..", '"', change_picture, $19
        .byte clear_text

        .byte '"', "Wait a minute. You mean"
        .byte line_in, "to tell that statue ...", '"', line_end
t99DF:
        .byte '"', "Yes, precisely."
        .byte line_in, "I thought it had been", new_line
        .byte "stolen."
        .byte clear_text

        .byte '"', "That demon statue"
        .byte line_in, "possesses enough evil", new_line
        .byte "power to destroy an", new_line
        .byte "entire nation."
        .byte clear_text

        .byte '"', "The demon came to this"
        .byte line_in, "earth and caused many", new_line
        .byte "deaths."
        .byte clear_text

        .byte '"', "But then SHINOBI"
        .byte line_in, "appeared to stop the", new_line
        .byte "demon.", line_end
t9ABE:
        .byte '"', "SHINOBI borrowed the"
        .byte line_in, "strength of the dragon", new_line
        .byte clear_text

        .byte '"', "and countered each of"
        .byte line_in, "the demon's spells and", new_line
        .byte "thus was able to", new_line
        .byte "overcome it.", line_end
t9B38:
        .byte start_picture, $02, '"', "Yet, though it was"
        .byte line_in, "defeated. the demon was", new_line
        .byte "not dead.", change_picture, $19
        .byte clear_text

        .byte start_picture, $02, '"', "So SHINOBI confined the"
        .byte line_in, "evil power of the demon", new_line
        .byte "in two statues", new_line
        .byte "of ", '"', "LIGHT", '"', " and ", '"', "SHADOW", '"', ".", change_picture, $19, line_end
t9BCF:
        .byte '"', "...And the body of the"
        .byte line_in, "demon was confined in a", new_line
        .byte "temple."
        .byte clear_text

        .byte '"', "This one must be the"
        .byte line_in, '"', "SHADOW", '"', " statue.", new_line
        .byte "Therefore,...", '"', line_end
t9C3D:
        .byte '"', "And now I've got it."
        .byte line_in, "Bye, friend!", '"', line_end
t9C61:
        .byte '"', "What the ... ?", '"'
        .byte line_in, line_end
t9C73:
        .byte start_picture, $02, '"', "After him, Ryu!", '"', change_picture, $19, line_end
t9C89:
        .byte "After getting back the", new_line
        .byte "demon statue. I felt", new_line
        .byte "a strange premonition", new_line
        .byte "and hurried back.", line_end
t9CDD:
        .byte '"', "Dr. Smith!!", '"', line_end
t9CEB:
        .byte '"', "Ryu...", wait_text, " the ", '"', "LIGHT", '"'
        .byte line_in, "demon statue ...", wait_text, new_line
        .byte "was taken...", '"', line_end
t9D20:
        .byte '"', "The ", '"', "LIGHT", '"', " statue?", '"', line_end
t9D36:
        .byte '"', "Yes,", wait_text, " your father and I"
        .byte line_in, "...", wait_text, " we each kept one of", new_line
        .byte "the statues...", wait_text, " just in", new_line
        .byte "case."
        .byte clear_text

        .byte '"', "So that the two statues"
        .byte line_in, "would never become one."
        .byte clear_text

        .byte '"', "The demon's been asleep"
        .byte line_in, "for 700 years ...", wait_text, " and now", new_line
        .byte "it's starting to wake up"
        .byte clear_text

        .byte '"', "...whatever we do...", wait_text
        .byte line_in, "we've got to stop it."
        .byte clear_text

        .byte '"', "Got to get it back...", wait_text
        .byte line_in, "there's no choice...", wait_text, new_line
        .byte "you've got to become", new_line
        .byte "the Ninja Dragon...", '"'
        .byte clear_text

        .byte '"', "Dr. Smith!", wait_text, " Dr. Smith!", '"', line_end
t9EA2:
        .byte '"', "...", '"', line_end
t9EA8:
        .byte '"', "Come with us.", '"', line_end
t9EB8:
        .byte '"', "Welcome, Ryu Hayabusa."
        .byte line_in, "Sorry if I startled", new_line
        .byte "you.", line_end
t9EE9:
        .byte '"', "We are from the CIA"
        .byte line_in, "Special Auxiliary unit.", new_line
        .byte "My name's Foster.", '"', line_end
t9F29:
        .byte '"', "Getting right to the"
        .byte line_in, "point...", '"', line_end
t9F49:
        .byte '"', "Wait.", wait_text, " I want to know"
        .byte line_in, "why you killed Smith?", '"', line_end
t9F77:
        .byte '"', "We didn't kill him."
        .byte line_in, "But we'll fill you in", new_line
        .byte "on what we know.", '"', line_end
t9FB4:
        .byte '"', "In the upper reaches of"
        .byte line_in, "the Amazon, some", new_line
        .byte "ancient ruins were", new_line
        .byte "discovered."
        .byte clear_text

        .byte '"', "It seems the temple was"
        .byte line_in, "built more than 2000", new_line
        .byte "years ago."
        .byte clear_text

        .byte '"', "The discoverer was Dr."
        .byte line_in, "Smith, who studied the", new_line
        .byte "ruins for some time."
        .byte clear_text

        .byte '"', "But one day, he"
        .byte line_in, "suddenly sealed off the", new_line
        .byte "ruins."
        .byte clear_text

        .byte '"', "And ever since then"
        .byte line_in, "no one has gone close."
        .byte clear_text

        .byte line_end
tA0D7:
        .byte '"', "Later, however, a man"
        .byte line_in, "moved in and took over", new_line
        .byte "the ruins. His name is", new_line
        .byte "Guardia de mieux."
        .byte clear_text

        .byte '"', "He calls himself"
        .byte line_in, "the Jaquio."
        .byte clear_text

        .byte '"', "According to our"
        .byte line_in, "records, it seems that"
        .byte clear_text

        .byte '"', "the temple is not where"
        .byte line_in, "gods are worshipped but", new_line
        .byte "was built to imprison", new_line
        .byte "the body of the demon."
        .byte clear_text

        .byte line_end
tA1D4:
        .byte '"', "Therefore, evil spirits"
        .byte line_in, "are supposed to be held", new_line
        .byte "in the statue you have."
        .byte clear_text

        .byte '"', "Dr. Smith probably"
        .byte line_in, "already knew that."
        .byte clear_text

        .byte '"', "He was probably killed"
        .byte line_in, "by someone working for", new_line
        .byte "the Jaquio.", '"', line_end
tA280:
        .byte '"', "When a black moon"
        .byte line_in, "shines, Light and Dark", new_line
        .byte "break apart, the King", new_line
        .byte "of Darkness howls", '"'
        .byte clear_text

        .byte '"', "These were the last"
        .byte line_in, "words written on the", new_line
        .byte "stone tablet."
        .byte clear_text

        .byte '"', "If someone brings the"
        .byte line_in, "demon back to life, he", new_line
        .byte "will gain incredible", new_line
        .byte "power..."
        .byte clear_text

        .byte '"', "enough to control the"
        .byte line_in, "entire world.", '"', line_end
tA37D:
        .byte '"', "So you know about that?", '"'
        .byte clear_text

        .byte '"', "The woman who shot you"
        .byte line_in, "in the bar was one of", new_line
        .byte "our agents.", '"', line_end
tA3D2:
        .byte '"', "They are after you."
        .byte clear_text

        .byte '"', "Use this and go to"
        .byte line_in, "their headquaters.", new_line
        .byte "Get the demon statue", new_line
        .byte "back from them."
        .byte clear_text

        .byte '"', "Of course, you will be"
        .byte line_in, "paid for the work.", '"', line_end
tA45F:
        .byte '"', "If I say no?", '"', line_end
tA46E:
        .byte '"', "You know the answer to"
        .byte line_in, "that.", '"', line_end
tA48D:
        .byte start_picture, $06, '"', "You have come a long"
        .byte line_in, "way to bring me the", new_line
        .byte "demon statue.", new_line
        .byte "Now give it to me.", '"', change_picture, $1F, line_end
tA4DD:
        .byte '"', "No!", '"', line_end
tA4E3:
        .byte start_picture, $06, '"', "Do you know what you're", new_line
        .byte " saying.", '"', new_line
        .byte change_picture, $1F, new_line
        .byte wait_text, '"', "What?!", '"', line_end
tA515:
        .byte '"', "Ryu!", '"', line_end
tA51C:
        .byte '"', "You... you coward.", '"', line_end
tA531:
        .byte start_picture, $05, '"', "No, don't give it to"
        .byte line_in, "him.", '"', change_picture, $39, line_end
tA551:
        .byte start_picture, $06, '"', "Now, put down the demon"
        .byte line_in, "statue on the floor,", new_line
        .byte "and back up.", '"', change_picture, $1F, line_end
tA591:
        .byte '"', "Nice work. I guess"
        .byte line_in, "this is goodbye.", '"', line_end
tA5B7:
        .byte start_picture, $06, '"', "Have a nice day.", '"', change_picture, $1F, line_end
tA5CE:
        .byte '"', "Ah... ", '"', new_line
        .byte wait_text, '"', "Take the girl away."
        .byte line_in, "She is going to be a", new_line
        .byte "sacrifice.", '"', line_end
tA60E:
        .byte change_picture, $21, '"', "Ha, ha, ha..."
        .byte line_in, wait_text, start_picture, $06, "it's mine.", change_picture, $1F
        .byte clear_text

        .byte start_picture, $06, '"', "Tonight is the night"
        .byte line_in, "of rebirth which comes", new_line
        .byte "only once every 700", new_line
        .byte "years.", change_picture, $1F
        .byte clear_text

        .byte start_picture, $06, '"', "This world will"
        .byte line_in, "soon be mine.", new_line
        .byte start_picture, $07, "Ha, ha, ha...", wait_text, change_picture, $21, line_end
tA6AF:
        .byte change_picture, $27, '"', "Ha, ha, ha, ha, ha....", '"', wait_text, line_end
tA6CB:
        .byte '"', "I am Malth."
        .byte line_in, "You will never get past", new_line
        .byte "me.", '"', line_end
tA6F5:
        .byte '"', "Then I must defeat you!", '"', line_end
tA70F:
        .byte '"', "You are as bold as your"
        .byte line_in, "father.", wait_text, " But he is a", new_line
        .byte "much better swordsman.", '"', line_end
tA755:
        .byte '"', "You know my father?", '"', line_end
tA76B:
        .byte '"', "Come and fight, young"
        .byte line_in, "Hayabusa!", '"', line_end
tA78D:
        .byte '"', "You killed my father.", '"'
        .byte clear_text

        .byte '"', "Killed?", wait_text, " It is true"
        .byte line_in, "that we fought.", new_line
        .byte wait_text, "But your father is", new_line
        .byte "alive.", '"'
        .byte clear_text

        .byte '"', "Liar!", '"'
        .byte clear_text

        .byte '"', "No,", wait_text, " it is not a lie."
        .byte line_in, wait_text, "If you proceed further,", new_line
        .byte "you will see him.", new_line
        .byte clear_text

        .byte '"', "But it will be the last"
        .byte line_in, "thing you see.", '"', line_end
tA85A:
        .byte '"', "Ryu, you deserve praise", new_line
        .byte " for making it this far..", '"', new_line
        .byte wait_text, wait_text, '"', "Where are you,"
        .byte line_in, "show yourself!", '"'
        .byte clear_text

        .byte '"', "...but even you cannot"
        .byte line_in, "defeat ", '"', "the masked", new_line
        .byte "devil", '"', line_end
tA8E2:
        .byte '"', "No one can beat me.", '"', new_line
        .byte wait_text, new_line
        .byte '"', "Even... your father?", '"', line_end
tA911:
        .byte '"', "What?!", '"', line_end
tA91A:
        .byte '"', "Your father was not"
        .byte line_in, "killed. he has been", new_line
        .byte "turned into ", '"', "the masked", new_line
        .byte "devil.", '"', line_end
tA963:
        .byte '"', "No!", '"'
        .byte clear_text

        .byte '"', "It will be"
        .byte line_in, "entertaining to watch", new_line
        .byte "father and son fight to", new_line
        .byte "the death.", '"', line_end
tA9AF:
        .byte '"', "Wake up, Father!", '"', line_end
tA9C2:
        .byte '"', "No use.", wait_text, " He thinks only"
        .byte line_in, "of killing you.", line_end
tA9EB:
        .byte '"', "So this is my destiny"
        .byte line_in, "Malth was telling the", new_line
        .byte "truth.", new_line
        .byte wait_text, "What shall I do?", line_end
tAA31:
        .byte '"', "I've got to think"
        .byte line_in, "clearly."
        .byte clear_text

        .byte '"', "Father's eyes... they"
        .byte line_in, "show he is controlled", new_line
        .byte "like a puppet.", new_line
        .byte "If I break the control...", line_end
tAAA3:
        .byte '"', "But What is"
        .byte line_in, "controlling him?", new_line
        .byte wait_text, wait_text, wait_text, wait_text, "That's it!", '"', line_end
tAAD1:
        .byte '"', "Father!", '"'
        .byte clear_text

        .byte '"', "... ", wait_text, "Where am I...?", new_line
        .byte wait_text, " Ryu... Are you Ryu?", '"', new_line
        .byte wait_text, new_line
        .byte '"', "Yes, Father.", '"', line_end
tAB18:
        .byte '"', "Argh! He's awake.", '"', line_end
tAB2C:
        .byte '"', "The Jaquio!", '"', line_end
tAB3A:
        .byte start_picture, $08, '"', "You both will die!", '"', change_picture, $27, line_end
tAB53:
        .byte '"', "Watch out!", '"', line_end
tAB60:
        .byte '"', "Ugh...!!!!", '"', new_line
        .byte wait_text, new_line
        .byte '"', "Father...", '"', line_end
tAB7B:
        .byte '"', "Ryu...", wait_text, "you've got to", new_line
        .byte " ...get them for me.", '"', new_line
        .byte wait_text, new_line
        .byte '"', "Father!", '"', line_end
tABB3:
        .byte '"', "Your day has come,"
        .byte line_in, "Jaquio!", '"', line_end
tABD0:
        .byte '"', "Wake up father, wake up.", '"'
        .byte clear_text

        .byte '"', "Ryu...", wait_text, " I haven't got"
        .byte line_in, "much longer...", wait_text, "This", new_line
        .byte "temple is about to", new_line
        .byte "break apart."
        .byte clear_text

        .byte '"', "Take that woman and"
        .byte line_in, "escape.", '"'
        .byte clear_text

        .byte '"', "What are you saying,"
        .byte line_in, "father.", new_line
        .byte "I can't just leave you!", '"'
        .byte clear_text

        .byte '"', "Ryu,", wait_text, " you are a man now.", wait_text
        .byte line_in, "My destiny is tied to", new_line
        .byte "the demon statue."
        .byte clear_text

        .byte '"', "Ryu,", wait_text, " good luck...", '"', line_end
tACE3:
        .byte '"', "Father,", wait_text, " father...!!!", '"', line_end
tACFB:
        .byte '"', "Father!!!", '"', line_end
tAD07:
        .byte wait_text, wait_text, '"', "Ryu...", '"', line_end
tAD12:
        .byte '"', "This is Sea Swallow...", '"', line_end
tAD2B:
        .byte '"', "This is Foster."
        .byte line_in, "We detected the", new_line
        .byte "explosion from the", new_line
        .byte "satellite."
        .byte clear_text

        .byte '"', "Job well done. You are"
        .byte line_in, "to kill Ryu Hayabusa.", '"', line_end
tAD99:
        .byte '"', "What?", wait_text, " Kill Ryu?", '"', new_line
        .byte wait_text, '"', "That's right."
        .byte line_in, "Then you are to steal", new_line
        .byte "the demon statues.", '"', line_end
tADE6:
        .byte start_picture, $0B, '"', "So this was your plan"
        .byte line_in, "all along ...", new_line
        .byte "I'll get you for this,", new_line
        .byte "Foster!", '"', change_picture, $29, line_end
tAE2F:
        .byte '"', "Ryu, you...", '"', line_end
tAE3D:
        .byte start_picture, $0B, '"', "I get two kinds of"
        .byte line_in, "payment.", new_line
        .byte change_picture, $29, wait_text, start_picture, $0B, "The first I have", new_line
        .byte "already received.", change_picture, $29, line_end
tAE86:
        .byte '"', "The second...", wait_text, " is you,"
        .byte line_in, "Foster!", '"', line_end
tAEA7:
        .byte '"', "Ryu... wait...", '"', line_end
tAEB8:
        .byte start_picture, $0A, '"', "Ryu,", change_picture, $23, wait_text, start_picture, $0A, " what is the"
        .byte line_in, "payment you have", new_line
        .byte "already recieved?", change_picture, $23
        .byte clear_text

        .byte '"', "She's right in front"
        .byte line_in, "of me.", '"', line_end
tAF14:
        .byte '"', "I don't even know your"
        .byte line_in, "name.", '"'
        .byte clear_text

        .byte start_picture, $0A, '"', "Irene,", change_picture, $23, wait_text, start_picture, $0A, " Irene Lew.", '"', change_picture, $23, line_end
tAF50:
        .byte start_picture, $0B, '"', "Well, Irene."
        .byte line_in, "Look, the sun is rising.", new_line
        .byte "Everything is so bright", new_line
        .byte "now.", change_picture, $29, line_end
tAF98:
        .byte '"', "the darkness is"
        .byte line_in, "finally over.", '"', line_end
tAFB8:
        .byte '"', "Ryu!", '"', new_line
        .byte wait_text, '"', "Thank God your safe!", '"', line_end
tAFD7:
        .byte '"', "Let's go, father."
        .byte line_in, wait_text, "Let's get out of this", new_line
        .byte "temple.", '"'
        .byte clear_text

        .byte '"', "Ryu, wait.", wait_text, " Before we"
        .byte line_in, "do, the demon statues...", new_line
        .byte wait_text, "we've got to throw them", new_line
        .byte "from the temple"
        .byte clear_text

        .byte '"', "while we've still got"
        .byte line_in, "time. Before the ", '"', "black", new_line
        .byte "moon", '"', " shines.", '"', line_end
tB0A1:
        .byte '"', "Ryu, what's that?", '"', line_end
tB0B5:
        .byte '"', "Is it a lunar eclipse?!"
        .byte line_in, wait_text, "That must be it.", new_line
        .byte "That's what the ", '"', "black", new_line
        .byte "moon", '"', " meant...."
        .byte clear_text

        .byte '"', "Oh, no!"
        .byte line_in, "The demon statue!", '"', line_end
tB123:
        .byte skip_ahead, $08, "S T A F F", line_end
tB12F:
        .byte "STORY"
        .byte line_in, "  SAKURAZAKI", line_end
tB142:
        .byte "SCREENPLAY"
        .byte line_in, "  SAKURAZAKI"
        .byte line_in, " FAW", line_end
tB15F:
        .byte "IMAGE ILLUST"
        .byte line_in, "  RUNMARU", line_end
tB176:
        .byte "ART WORKS"
        .byte line_in, "  RUNMARU"
        .byte line_in, " PARCO"
        .byte line_in, "UMA"
        .byte clear_text

        .byte "ART WORKS"
        .byte line_in, "  NAGA"
        .byte line_in, " WILD TAGOU"
        .byte line_in, "NIWAKAMARU", line_end
tB1BD:
        .byte "PROGRAM WORKS"
        .byte line_in, "  MADOKA SOUTHERNAMI"
        .byte line_in, " MASITA", line_end
tB1E8:
        .byte "ASSISTANT", new_line
        .byte "   NOSUKE", new_line
        .byte "NES TRANSLATOR"
        .byte line_in, "  KEVIN & DANIEL", line_end
tB21C:
        .byte "SOUND DESIGN"
        .byte line_in, "  MORE YAMASAN"
        .byte line_in, " B.B"
        .byte line_in, "HAKASE"
        .byte line_in, line_end
tB245:
        .byte "DIRECTOR"
        .byte line_in, "  SAKURAZAKI", line_end
tB25B:
        .byte skip_ahead, $07, "AUDIO VISUAL"
        .byte line_in, "  COPYRIGHT MCMLXXXIX"
        .byte line_in, skip_ahead, $06, "TECMO LTD."
        .byte line_in, "ALL RIGHTS RESERVED.", line_end
tB2A2:
        .byte "  THANK YOU FOR PLAYING."
        .byte line_in, "   AND SEE YOU NEXT.", line_end

; --- $B2D0
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FB
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $40, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FE, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $10, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FB, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $20, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FB, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $10, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $20, $FF, $00, $FF, $00, $FF, $00, $FF, $20, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $10
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FD, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $10, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FE, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FD
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $10, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $EF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $08, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $20, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FD, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FE, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $08, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $40, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $F7, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $10, $FF, $00, $FF, $00, $FF, $40, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $40, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FB, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $BF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FD, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $40, $FF, $00, $FF, $00, $FF, $00, $FF, $20, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FE
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00

; --- $BF98  The rest of a call, once this bank is switched in.
; Then switch the other bank back.
call_bank_05:
        sta call_num                   ; which picture, or which line
        txa
        pha
        rol
        rol
        rol
        and #$03
        ora #$04
        jsr set_prg+2                  ; switch the program bank, but do not remember it
        pla
        and #$3F
        jsr cutscene_routines
        lda z:prg_bank
        jsr set_prg
        rts

; --- $BFB3  Routines the other banks can call.
cutscene_routines:
        jsr pick_entry
        .word draw_actor
        .word move_actors
        .word draw_actors
        .word read_text
        .word start_line
        .byte $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $D8, $A9, $00, $8D, $00, $20, $A9, $80, $8D, $00

; --- $BFDA  Same first instructions as reset.
reset_copy_05:
        inc $FFDA
        jmp $C03E
        .byte $FF, $9F, $4A, $CA, $D0, $F9, $4C, $00, $80, $FF, $00, $FF, $00, $FF, $00, $FF
        .byte $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $DA, $FF, $DA, $FF, $DA, $FF
